//===========================================================================
//
//							Receipt.cs
//
//  This class holds all business logic for handling receipt information.
//
//  This file is comprised of a business object (ReceiptLine),
//  a business process (ReceiptLineProcessor) and the business object
//  info (ReceiptLineObjectInfo).
//  
//  Usage:
//
//  ReceiptLine myReceiptLine = new ReceiptLine();
//  myReceiptLine.OrderNumber = "123456";
//  myReceiptLine.MoreToCome  = false;
//  myReceiptLine.NSVCode     = "AS456G";
//  myReceiptLine.SiteNumber  = "342";
//  myReceiptLine.Batches.Add(new Batch() { Number="23232", ExpiryDate=new DateTime(2010, 11, 12), QuantityInPacks=5 });
//
//  using(ReceiptProcessor processor = new ReceiptProcessor())
//  {
//      ReceiptProcessor.Lock(myReceiptLine);
//      ReceiptProcessor.Update(myReceiptLine);
//  }
//      
//	Modification History:
//	15Apr09 XN  Written
//  21Dec09 XN  Moved from UHB Sage interface into main pharmacy system (F0042698)
//              Added reconciliation, and allow integration into robot loading
//  30Jan10 XN  WORder.LocCode should not be used to read a products location
//              use ProductStock.LocCode instead
//  29Apr10 XN  Updates from BaseOrderRow, and WProduct
//  11Nov10 XN  Fixed problem with invalid vat value not giving correct results
//  22Nov13 XN  78339 knock on effects from LockResult changes
//  19Aug14 XN  Updates as WOrder, and WReconcil moved to BaseTable2
//  28Nov16 XN  Updated Lock to use GetPKColumnName 147104
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;
using _Shared;

namespace ascribe.pharmacy.businesslayer
{
    /// <summary>
    /// Receipt line business object
    /// </summary>
    public class ReceiptLine : IBusinessObject
    {
        public ReceiptLine()
        {
            Batches = new List<Batch>();

            AllowOverReceiving             = false;
            AllowReceivingOnCompletedOrder = false;
        }

        public struct Batch
        {
            public string    Number          { get; set; }
            public DateTime? ExpiryDate      { get; set; }
            public decimal   QuantityInPacks { get; set; }
        }

        public int OrderNumber { get; set; }

        public string  NSVCode          { get; set; }
        public int     SiteNumber       { get; set; }

        /// <summary>
        /// Quantity of receipt line (in packs)
        /// As receipts don't always require batches, this value needs to be set manually.
        /// </summary>
        public decimal QuantityInPacks  { get; set; }

        /// <summary>
        /// Used to assoicate an existing reconil line with the receipt line.
        /// If no reconcil line is set then an open one will be automatcially assigned
        /// Value will be set after update is performed 
        /// </summary>
        public int? WReconcilID { get; set; }

        public List<Batch> Batches{ get; set; }

        /// <summary>
        /// Set to true if allowed to over receive items (default is false)
        /// (used by robot loading interface)
        /// </summary>
        public bool AllowOverReceiving { get; set; }

        /// <summary>
        /// Set to true if allowed to receive items on order that is completd (default is false)
        /// (used by robot loading interface)
        /// </summary>
        public bool AllowReceivingOnCompletedOrder { get; set; }
    }

    /// <summary>
    /// Receipt line business object info
    /// </summary>
    public class ReceiptLineObjectInfo : IBusinessObjectInfo
    {
        public static int NSVCodeLength          { get { return WProduct.GetColumnInfo().NSVCodeLength;              } }
        public static int BatchNumberLength      { get { return WBatchStockLevel.GetColumnInfo().BatchNumberLength;  } }
        public static int QuantityInPacksLength  { get { return ProductStock.GetColumnInfo().StockLevelLength;       } }
    }

    /// <summary>
    /// Receipt line business process
    /// </summary>
    public class ReceiptLineProcessor : BusinessProcess
    {
        /// <summary>
        /// Locks all database rows that will form part of the update
        /// </summary>
        /// <param name="receipt">receipt that is to be updated</param>
        public void Lock(ReceiptLine receipt)
        {
            // Load site data
            int siteNumber = receipt.SiteNumber;
            int siteID     = Sites.GetSiteIDByNumber(siteNumber);
            if ( siteID == 0 )
            {
                string msg = string.Format("Invalid site number {0}", siteNumber);
                throw new ApplicationException(msg);
            }

            // Lock WOrder rows
            WOrder order = new WOrder();
            order.LoadByOrderNumberSiteIDAndNSVCode(receipt.NSVCode, siteID, receipt.OrderNumber);
            LockRows(order.Table, order.TableName, order.GetPKColumnName());

            // Lock ProductStock rows
            ProductStock productStock = new ProductStock();
            productStock.LoadBySiteIDAndNSVCode(receipt.NSVCode, siteID);
            LockRows(productStock.Table, productStock.TableName, productStock.GetPKColumnName());

            // Load WReconcil rows
            WReconcil reconcil = new WReconcil();
            if (receipt.WReconcilID.HasValue)
                reconcil.LoadByID(receipt.WReconcilID.Value);
            //LockRows(reconcil.Table, reconcil.TableName, reconcil.PKColumnName); 19Aug14 XN WReconcil moved to BaseTable2
            LockRows(reconcil.Table, reconcil.TableName, reconcil.GetPKColumnName());

            // Lock WBatchStockLevel rows
            WBatchStockLevel batchStockLvl = new WBatchStockLevel();
            foreach(ReceiptLine.Batch batch in receipt.Batches)
                batchStockLvl.LoadBySiteIDNSVCodeAndBatchNumber(siteID, receipt.NSVCode, batch.Number, true);
            LockRows(batchStockLvl.Table, batchStockLvl.TableName, batchStockLvl.GetPKColumnName());
        }

        /// <summary>
        /// Updates the database tables when received new receipt line.
        /// </summary>
        /// <param name="receipt">new receipt line</param>
        public void Update(ReceiptLine receipt)
        {
            DateTime now = DateTime.Now;    // Used to set record times to now

            // If not receving anything then nohting to do
            if (receipt.QuantityInPacks == 0)
                return;

            // check not returning goods
            if (receipt.QuantityInPacks < 0)
                throw new ApplicationException("Does not support return of goods");

            // Load site data
            int siteNumber = receipt.SiteNumber;
            int siteID     = Sites.GetSiteIDByNumber(siteNumber);
            if ( siteID == 0 )
            {
                string msg = string.Format("Invalid site number {0}", siteNumber);
                throw new ApplicationException(msg);
            }
            
            // Load WOrder row
            WOrder orders = new WOrder();
            orders.LoadByOrderNumberSiteIDAndNSVCode(receipt.NSVCode, siteID, receipt.OrderNumber);
            if ( orders.Count == 0 )
            {
                string msg = string.Format("Invalid order item for order number={0}, NSV code={1} and site={2}", receipt.OrderNumber, receipt.NSVCode, receipt.SiteNumber);
                throw new ApplicationException(msg);
            }

            // Assert if order is not set to waiting (and as long as not allowing receiving on completed order for robot loading module)
            WOrderRow orderRow = orders.FirstOrDefault(o => o.Status == OrderStatusType.WaitingToReceive);
            if ((orderRow == null) && receipt.AllowReceivingOnCompletedOrder)
                orderRow = orders.FirstOrDefault();
            if (orderRow == null)
            {
                string msg = string.Format("Received receipt line for completed order number={0}, NSV code={1} and site={2}", receipt.OrderNumber, receipt.NSVCode, receipt.SiteNumber);
                throw new ApplicationException(msg);
            }

            // Load WProduct row
            WProduct product = new WProduct();
            product.LoadByProductAndSiteID(receipt.NSVCode, siteID);
            if ( product.Count == 0 )
            {
                string msg = string.Format("Invalid product item for NSV code={0} and site={1}", receipt.NSVCode, siteID);
                throw new ApplicationException(msg);
            }

            // Load ProductStock row
            ProductStock productStock = new ProductStock();
            productStock.LoadBySiteIDAndNSVCode(receipt.NSVCode, siteID);
            if ( productStock.Count == 0 )
            {
                string msg = string.Format("Invalid product stock item for NSV code={0} and site={1}", receipt.NSVCode, siteID);
                throw new ApplicationException(msg);
            }

            // Load WReconcil rows
            WReconcil reconcil = new WReconcil();
            if (receipt.WReconcilID.HasValue)
                reconcil.LoadByID(receipt.WReconcilID.Value);

            // Load WSupplierProfile row
            // It is possible to have an order that is not related to a WSupplierProfile row
            // so don't need to check if it exists
            WSupplierProfile supplierProfile = new WSupplierProfile();
            supplierProfile.LoadBySiteIDSupplierAndNSVCode(siteID, orderRow.SupplierCode, receipt.NSVCode);

            WOrderlog orderLog = new WOrderlog();
            WBatchStockLevel batchStockLvl = new WBatchStockLevel();

            // Prevent div by zero errors
            if (product[0].ConversionFactorPackToIssueUnits == 0)
            {
                string msg = string.Format("Invalid conversion factor of zero for product ID {0} and site ID {1}", product[0].NSVCode, product[0].SiteID);
                throw new ApplicationException(msg);
            }

            // check if there is a vat value
            if (!product[0].VATRate.HasValue)
            {
                string msg = string.Format("Invalid vat code for product {0} and site ID {1}", product[0].NSVCode, product[0].SiteID);
                throw new ApplicationException(msg);
            }

            // Get the vat rate
            decimal vatRate = product[0].VATRate.Value;

            // Calculate the new stock level
            decimal originalStockLevelInIssueUnits= productStock[0].StockLevelInIssueUnits;
            decimal newStockLevelInIssueUnits     = originalStockLevelInIssueUnits + (receipt.QuantityInPacks * product[0].ConversionFactorPackToIssueUnits);
            decimal newStockLevelInPacks          = newStockLevelInIssueUnits / product[0].ConversionFactorPackToIssueUnits; 

            // Calculate original stock value 
            // (does not include losses and gains as this gets over large number of problems)!
            decimal originalStockValueExVat  = ((originalStockLevelInIssueUnits / product[0].ConversionFactorPackToIssueUnits) * productStock[0].AverageCostExVatPerPack) /*+ productStock[0].LossesGainExVat*/;

            // Calculate receipt stock value 
            decimal receiptStockValueExVat   = (orderRow.CostExVatPerPack ?? 0) * receipt.QuantityInPacks;

            // Calculate new stock value 
            decimal newStockValueExVat = originalStockValueExVat + receiptStockValueExVat;

            // Calculate new average cost                        
            decimal originalAverageCostExVatPerPack = productStock[0].AverageCostExVatPerPack;
            decimal newAverageCostExVatPerPack      = newStockValueExVat / newStockLevelInPacks;

            // update Product stock data
            // (does not update losses and gains as this gets over large number of problems)!
            productStock[0].StockLevelInIssueUnits  = newStockLevelInIssueUnits;
            productStock[0].AverageCostExVatPerPack = newAverageCostExVatPerPack;

            // update supplier profile
            // It is possible to have an order that is not related to a WSupplierProfile row.
            if (supplierProfile.Any())
                supplierProfile[0].LastReceivedPriceExVatPerPack = orderRow.CostExVatPerPack ?? 0;

            // Assert if received more items than ordered.
            if (!receipt.AllowReceivingOnCompletedOrder && (orderRow.Status != OrderStatusType.WaitingToReceive))
                throw new ApplicationException("Received receipt line for completed order.");
            if (!receipt.AllowOverReceiving && ((orderRow.OutstandingInPacks ?? 0) < receipt.QuantityInPacks))
                throw new ApplicationException("Received more items than originally ordered.");

            // update the order info
            orderRow.OutstandingInPacks = Math.Max(orderRow.OutstandingInPacks.Value - receipt.QuantityInPacks, 0m);

            // Set received to amount we expect to receive in the next delivery.
            // So maybe 0 if figure is set by EDI or internal (so should stay at 0)
            // If manual preset to full amount outstanding.
            orderRow.ReceivedInPacks = Math.Min(orderRow.OutstandingInPacks.Value, orderRow.ReceivedInPacks.Value);

            // Close off the order if received everything
            if (orderRow.OutstandingInPacks == 0m)
                orderRow.Status = OrderStatusType.Completed;

            // add orderlog entry for receipt
            WOrderlogRow receiptLog = orderLog.Add();
            receiptLog.Kind             = WOrderLogType.Receipt;
            receiptLog.OrderNumber      = orderRow.OrderNumber.ToString();
            receiptLog.NSVCode          = orderRow.NSVCode;
            receiptLog.ConversionFactor = product[0].ConversionFactorPackToIssueUnits;
            receiptLog.IssueUnits       = product[0].PrintformV;
            receiptLog.DateTimeOrd      = orderRow.DateTimeOrdered;
            receiptLog.DateTimeRec      = now;
            receiptLog.QuantityOrdered  = orderRow.OutstandingInPacks; 
            receiptLog.QuantityReceived = receipt.QuantityInPacks;
            receiptLog.VatRate          = vatRate;
            receiptLog.VatCode          = product[0].VATCode.Value;
            receiptLog.SupplierCode     = orderRow.SupplierCode;
            receiptLog.SiteID           = siteID;
            receiptLog.SiteNumber       = siteNumber;
            receiptLog.StockLevel       = newStockLevelInIssueUnits;
            receiptLog.StockValue       = Convert.ToDouble(newStockValueExVat + productStock[0].LossesGainExVat);
            receiptLog.DateOrdered      = orderRow.DateTimeOrdered;
            receiptLog.DateReceived     = now;
            receiptLog.CostIncVat       = (orderRow.CostExVatPerPack ?? 0) * vatRate;
            receiptLog.CostExVat        = (orderRow.CostExVatPerPack ?? 0);
            receiptLog.VatCost          = receiptLog.CostIncVat - receiptLog.CostExVat;

            // Add reconciliation transaction
            // If a free item and cost is 0 then don't add a reconcil record.
            WReconcilRow reconcilRow = null;
            if (!((product[0].PricingFlag == PricingType.None) && orderRow.CostExVatPerPack.HasValue && (orderRow.CostExVatPerPack.Value == 0)))
            {
                // If coming from robot loading then see if there is a transaction assoicated with this loading
                if (reconcil.Any())
                    reconcilRow = reconcil.First();
                else
                {
                    reconcilRow = reconcil.Add();
                    reconcilRow.NumPrefix               = orderRow.NumPrefix;
                    reconcilRow.ToFollow                = orderRow.ToFollow;
                    reconcilRow.Urgency                 = orderRow.Urgency;
                    reconcilRow.IssueUnits              = orderRow.IssueUnits;
                    reconcilRow.Stocked                 = orderRow.Stocked;
                    reconcilRow.Description             = orderRow.Description;
                    reconcilRow.CustOrdNo               = orderRow.CustOrdNo;
                    reconcilRow.SupplierType            = orderRow.SupplierType;
                    reconcilRow.ConversionFactor        = orderRow.ConversionFactor;
                    reconcilRow.NSVCode                 = orderRow.NSVCode;
                    reconcilRow.Status                  = OrderStatusType.Received;
                    reconcilRow.OrderNumber             = orderRow.OrderNumber;
                    reconcilRow.SiteID                  = orderRow.SiteID;
                    reconcilRow.DateTimeOrdered         = orderRow.DateTimeOrdered;
                    reconcilRow.DateTimeReceived        = now;
                    reconcilRow.Location                = productStock[0].Location;
                    reconcilRow.SupplierCode            = orderRow.SupplierCode;
                    reconcilRow.PickNumber              = orderRow.PickNumber;
                    reconcilRow.InternalMethod          = orderRow.InternalMethod;
                    reconcilRow.PFlag                   = orderRow.PFlag;
                    reconcilRow.VATAmount               = orderRow.VATAmount;
                    reconcilRow.VATRatePct              = orderRow.VATRatePct;
                    reconcilRow.VATInclusive            = orderRow.VATInclusive;
                    reconcilRow.VATCode                 = orderRow.VATCode;
                    reconcilRow.QuantityOrderedInPacks  = orderRow.QuantityOrderedInPacks;
                    reconcilRow.InternalSiteNo          = orderRow.InternalSiteNo;
                    reconcilRow.ShelfPrinted            = orderRow.ShelfPrinted;
                    reconcilRow.CostExVatPerPack        = orderRow.CostExVatPerPack ?? 0;
                }

                // Update reconciled records
                reconcilRow.OutstandingInPacks = orderRow.OutstandingInPacks;
                reconcilRow.ReceivedInPacks = receipt.QuantityInPacks + (reconcilRow.ReceivedInPacks ?? 0);
            }

            // update the batch stock level
            foreach(ReceiptLine.Batch batch in receipt.Batches)
            {
                // Can't have an expiry date and no batch number 
                if (batch.ExpiryDate.HasValue && string.IsNullOrEmpty(batch.Number))
                    throw new ApplicationException(string.Format("Can't have a batch with an expiry date ({0}), and no batch number.", batch.ExpiryDate.Value.Date));

                // If no batch number then do add to the batch stock level table
                if (string.IsNullOrEmpty(batch.Number))
                    continue;

                batchStockLvl.LoadBySiteIDNSVCodeAndBatchNumber(siteID, receipt.NSVCode, batch.Number, true);
                WBatchStockLevelRow batchRow = batchStockLvl.FirstOrDefault( i => i.BatchNumber == batch.Number );

                if ( batchRow == null )
                {
                    // Batch does not exist so insert new one
                    batchRow = batchStockLvl.Add();
                    batchRow.BatchNumber    = batch.Number;
                    batchRow.NSVCode        = receipt.NSVCode;
                    batchRow.SiteID         = siteID;
                    batchRow.Description    = product[0].LabelDescription.Replace('!', ' ');
                    batchRow.ExpiryDate     = batch.ExpiryDate;
                    batchRow.QuantityInPacks= 0;
                }
                batchRow.QuantityInPacks += Convert.ToDouble(batch.QuantityInPacks);

                // add orderlog entry for batch
                WOrderlogRow batchLog = orderLog.Add();
                batchLog.Kind             = WOrderLogType.BatchUpdate;
                batchLog.OrderNumber      = orderRow.OrderNumber.ToString();
                batchLog.NSVCode          = orderRow.NSVCode;
                batchLog.ConversionFactor = product[0].ConversionFactorPackToIssueUnits;
                batchLog.IssueUnits       = product[0].PrintformV;
                batchLog.DateTimeRec      = now;
                batchLog.QuantityOrdered  = orderRow.QuantityOrderedInPacks; 
                batchLog.QuantityReceived = batch.QuantityInPacks;
                batchLog.CostIncVat       = receiptLog.CostIncVat;
                batchLog.CostExVat        = receiptLog.CostExVat;
                batchLog.VatCost          = receiptLog.VatCost;
                batchLog.VatCode          = product[0].VATCode.Value; // If vat rate is valid then vat code is valid
                batchLog.VatRate          = vatRate;
                batchLog.SupplierCode     = orderRow.SupplierCode;
                batchLog.SiteID           = siteID;
                batchLog.SiteNumber       = siteNumber;
                batchLog.BatchNumber      = batch.Number;
                batchLog.ExpiryDate       = batch.ExpiryDate;
                batchLog.InvoiceNumber    = batch.Number.Substring(0, Math.Min(batch.Number.Length, WOrderlog.GetColumnInfo().InvoiceLength));
                batchLog.DateOrdered      = batch.ExpiryDate;
                batchLog.DateReceived     = now;
            }

            using(ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                productStock.Save();
                supplierProfile.Save();
                orders.Save();
                reconcil.Save();
                batchStockLvl.Save();
                orderLog.Save();

                scope.Commit();
            }

            // Update reconcil record associated with this receipt (done at end incase we added a new record so need to save to get ID)
            if (!receipt.WReconcilID.HasValue)
                receipt.WReconcilID = reconcilRow.WReconcilID;
        }
    }
}
