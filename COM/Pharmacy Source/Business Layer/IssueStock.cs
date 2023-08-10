// -----------------------------------------------------------------------
// <copyright file="IssueStock.cs" company="Emis Health Plc">
// Copyright Emis Health Plc
// </copyright>
// <summary>
// This class holds all business logic for handling issuing information.
//
// The process will update the following tables
//  ProductStocks       - row is locked
//  WBatchStockLevel    - row is locked
//  WPharmacyLog
//  PharmacyBondStore
//  WTranslog
//
// Currently this class has only been tested with AMM manufacturing and will 
// need to be tested with each new issue type.
//
// IssueType
// ---------
// The issue type does not related directly to a WTranslog Kind or LabelType, 
// but is intended to provide extra information, the mapping of IssueType to Kind or LabelType
// Is done in the Update method, and for a new type of issue, you may need to add new types or mappings
//  
// Usage:
// var line = new IssueStockLine();        
// line.QuantityInIssueUnits = 1;
// line.CostExVat               = (line.QuantityRequested / product.ConversionFactorPackToIssueUnits) * product.AverageCostExVatPerPack;
// line.CostCentreCode          = wardCode;
// line.IssueType               = IssueType.DispenseInPatient;
// line.LabelType               = WTranslogType.InPatient;
// line.NSVCode                 = product.NSVCode;
// line.RequestIdPrescription   = prescription.RequestID;
// line.RequestIdDispensing     = wlabel.RequestID;
// line.DirectionCode           = wlabel.DirectionCode;
// line.PrescriptionNumType     = PrescriptionNumType.PrescriptionNum;
// lines.Add(line);
// 
// using (IssueStockLineProcessor issueProcessor = new IssueStockLineProcessor())
// {
//      issueProcessor.Lock(SessionInfo.SiteID, new IssueStockLine[] { line });
//      issueProcessor.Update(SessionInfo.SiteID, episodeID, new IssueStockLine[] { line });
// }
//
// Modification History:
// 15Apr16 XN Created 123082
// 16Aug16 XN 160324 Complete errors with string or binary function truncated
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.businesslayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using _Shared;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.manufacturinglayer;
    using icwdatalayer;
    using pharmacy.shared;
    using pharmacydatalayer;

    /// <summary>Type of issue to perform</summary>
    public enum IssueType
    {
        /// <summary>Issuing a manufacturing ingredient (as part of manufacturing process)</summary>
        ManufactureIngredient,

        /// <summary>Issuing manufactured compound</summary>
        Manufacture,

        /// <summary>Issue to bond store</summary>
        Bond,

        /// <summary>In-patient dispensing</summary>
        DispenseInPatient,

        /// <summary>Out-patient dispensing</summary>
        DispenseOutPatient,

        /// <summary>Discharge dispensing</summary>
        DispenseDischarge,

        /// <summary>Leave dispensing</summary>
        DispenseLeave,
        
        /// <summary>Ward stock issue</summary>
        WardStock,

        /// <summary>PN issue</summary>
        ParenteralNutrition
    }

    /// <summary>Details on the line to issue</summary>
    public class IssueStockLine : IBusinessObject
    {
        /// <summary>NSV code to issue</summary>
        public string NSVCode { get; set; }

        /// <summary>Quantity of receipt line (in issue units) should be +ve value</summary>
        public decimal QuantityInIssueUnits  { get; set; }

        /// <summary>Batch number to issue from</summary>
        public string BatchNumber { get; set; }

        /// <summary>Overall manufactured product batch number (set if issuing an ingredient of a manufactured product)</summary>
        public string ManufacturingBatchNumber { get; set; }

        /// <summary>Batch expiry date</summary>
        public DateTime? BatchExpiryDate { get; set; }

        /// <summary>Prescription the issue is for</summary>
        public int? RequestIdPrescription  { get; set; }

        /// <summary>Dispensing ID the issue for</summary>
        public int? RequestIdDispensing { get; set; }

        /// <summary>Ward code to issue to</summary>
        public string CostCentreCode { get; set; }

        /// <summary>Type of issue</summary>
        public IssueType IssueType { get; set; }

        /// <summary>Issue label type</summary>
        public WTranslogType? LabelType { get; set; }

        /// <summary>Issue cost excluding vat (ONLY NEED FOR ManufactureBalance issue type)</summary>
        public decimal CostExVat { get; set; }
        
        /// <summary>Label direction code</summary>
        public string DirectionCode { get; set; }

        /// <summary>Gets or sets prescription number from use filepointer P|RXID.DAT to get the prescription number</summary>
        public string PrescriptionNum { get; set; }

        /// <summary>Civas does</summary>
        public decimal? CivasAmount { get; set; }

        /// <summary>Line from ward product list that the line is for</summary>
        public int? WWardProductListLineID { get; set; }

        /// <summary>If amm supply request item is issued under</summary>
        public int? RequestIdAmmSupplyRequest { get; set; }

        /// <summary>If amm supply request ingredient item is issued under</summary>
        public int? AmmSupplyRequestIngredientId { get; set; }

        /// <summary>If to suppress the move to bond store complete</summary>
        public bool BondStoreReturn { get; set; }
    }

    /// <summary>Stock issue line business process</summary>
    public class IssueStockLineProcessor : BusinessProcess
    {
        private WProduct         products        = new WProduct();
        private ProductStock     productStocks   = new ProductStock();
        private WBatchStockLevel batchStockLevel = new WBatchStockLevel();

        /// <summary>Locks all database rows that will form part of the update</summary>
        /// <param name="siteId">Site issue is for</param>
        /// <param name="issueStock">Stock lines to issue</param>
        public void Lock(int siteId, IEnumerable<IssueStockLine> issueStock)
        {
            batchStockLevel.RowLockingOption = LockingOption.HardLock;
            productStocks.RowLockingOption   = LockingOption.HardLock;

            foreach (var issue in issueStock)
            {
                // Load product data
                if (products.FindBySiteIDAndNSVCode(siteId, issue.NSVCode) == null)
                {
                    products.LoadByProductAndSiteID(issue.NSVCode, siteId, append: true);
                }

                // Load and lock stock data
                if (productStocks.FindBySiteIDAndNSVCode(siteId, issue.NSVCode) == null)
                {
                    productStocks.LoadBySiteIDAndNSVCode(issue.NSVCode, siteId, append: true);
                }

                // If batch number present then lock the batch stock
                if (issue.QuantityInIssueUnits != 0M && !string.IsNullOrEmpty(issue.BatchNumber) && 
                    batchStockLevel.FindBySiteIDNSVCodeAndBatchNumber(siteId, issue.NSVCode, issue.BatchNumber) == null)
                {
                    batchStockLevel.LoadBySiteIDNSVCodeAndBatchNumber(siteId, issue.NSVCode, issue.BatchNumber, append: true);
                }
            }
        }

        /// <summary>Performs the issues or returns</summary>
        /// <param name="siteId">Site issue is for</param>
        /// <param name="EpisodeId">Episode Id for patient drugs are being issues to (optional)</param>
        /// <param name="issueStock">Stock line to issue</param>
        public void Update(int siteId, int? episodeId, IEnumerable<IssueStockLine> issueStock)
        {
            BondStore         bondStore          = new BondStore();
            BondStoreComplete bondStoreComplete  = new BondStoreComplete();
            WTranslog         translog           = new WTranslog();
            WPharmacyLog      pharmacyLog        = new WPharmacyLog();
            int siteNumber                       = Site2.GetSiteNumberByID(siteId);
            var now                              = DateTime.Now;
            var batchStockLevelColumnInfo        = WBatchStockLevel.GetColumnInfo();
            var translogColumnInfo               = WTranslog.GetColumnInfo();

            // Get patient info
            EpisodeRow    episode    = (episodeId == null) ? null : Episode.GetByEpisodeID(episodeId.Value);
            PatientRow    patient    = (episode   == null) ? null : Patient.GetByEntityID (episode.EntityID);
            ConsultantRow consultant = (episodeId == null) ? null : Consultant.GetByEpisodeId(episodeId.Value);

            if (patient == null)
            {
                throw new ApplicationException(string.Format("Failed to find patient where EpisodeID={0}", episodeId));
            }

            // Create issue record for each line
            foreach (var issue in issueStock)
            {
                if (issue.QuantityInIssueUnits == 0M)
                    continue;
                
                var product = this.products.FindBySiteIDAndNSVCode(siteId, issue.NSVCode);
                if (product == null)
                {
                    throw new ApplicationException(string.Format("Issue: Failed to find WProduct NSVCode={0} site {1:000}", issue.NSVCode, siteNumber));
                }

                if (product.ConversionFactorPackToIssueUnits <= 0)
                {
                    throw new ApplicationException(string.Format("Issue: Invalid stores pack size for {0} site {1:000}", issue.NSVCode, siteNumber));
                }

                var productStock = this.productStocks.FindBySiteIDAndNSVCode(siteId, issue.NSVCode);
                if (productStock == null)
                {
                    throw new ApplicationException(string.Format("Product stock row has not been locked {0} site {1:000}", issue.NSVCode, siteNumber));
                }

                bool isIssueToPatient                = issue.IssueType == IssueType.DispenseDischarge || issue.IssueType == IssueType.DispenseInPatient || issue.IssueType == IssueType.DispenseLeave || issue.IssueType == IssueType.DispenseOutPatient;
                bool isReturn                        = issue.QuantityInIssueUnits < 0;
                bool isBondStoreIssue                = issue.CostCentreCode.EqualsNoCaseTrimEnd(PatMedSetting.Manufacturing.BondCostCenter(siteId));
                var  vatRate                         = WConfiguration.Load<bool>(siteId, "D|WorkingDefaults", string.Empty, "TransLogVAT", true, false) && product.VATRate != null ? product.VATRate.Value : 1M;
                var  originalAverageCostExVatPerPack = product.AverageCostExVatPerPack;
                var  newStockLevelInIssueUnits       = product.StockLevelInIssueUnits - issue.QuantityInIssueUnits;
                var  lossGainAdjustment              = 0M;

                // If stock level is going to go -ve then log
                if (issue.IssueType != IssueType.WardStock && !isReturn && (product.IfLiveStockControl ?? false) && newStockLevelInIssueUnits < 0 && product.StockLevelInIssueUnits > 0)
                {
                    var log = pharmacyLog.BeginRow(WPharmacyLogType.Negative, issue.NSVCode);
                    log.SiteID = siteId;
                    log.Detail = string.Format("Negative Stock Warning\nIssued: {0} Stock Lvl Was: {1}", issue.QuantityInIssueUnits.ToString(5), product.StockLevelInIssueUnits.ToString());
                }

                // Update batch stock level
                if (!string.IsNullOrEmpty(issue.BatchNumber) && 
                    (issue.IssueType == IssueType.Manufacture || issue.IssueType == IssueType.ManufactureIngredient || isIssueToPatient) && 
                    product.BatchTracking >= BatchTrackingType.OnReceiptWithExpiryAndConfirm)
                {
                    var batchStock = batchStockLevel.FindBySiteIDNSVCodeAndBatchNumber(siteId, issue.NSVCode, issue.BatchNumber);
                    if (batchStock == null && isReturn)
                    {
                        batchStock = batchStockLevel.Add();
                        batchStock.NSVCode          = product.NSVCode;
                        batchStock.SiteID           = siteId;
                        batchStock.Description      = product.ToString().SafeSubstring(0, batchStockLevelColumnInfo.DescriptionLength);
                        batchStock.BatchNumber      = issue.BatchNumber;
                        batchStock.ExpiryDate       = issue.BatchExpiryDate;
                    }
                    //else if (batchStock == null && !isReturn)
                    //{
                    //    throw new ApplicationException(string.Format("Issue: Invalid batch number {0} for {1} site {2:000}", issue.BatchNumber, issue.NSVCode, siteNumber));
                    //}

                    //05Aug16 KR Added. Bug 161647: aMM- Compounding after undoing the compounding doesn't work
                    //if (batchStock != null && ((decimal)batchStock.QuantityInPacks - (issue.QuantityInIssueUnits / product.ConversionFactorPackToIssueUnits)) < 0)
                    if (batchStock != null && ((decimal)batchStock.QuantityInPacks * product.ConversionFactorPackToIssueUnits - issue.QuantityInIssueUnits ) < -0.000001M)
                    {
                        throw new ApplicationException(string.Format("Issue: The amount issued for {0} site {1:000} cannot be fulfilled by all recorded batch {2} quantities.", issue.NSVCode, siteNumber, issue.BatchNumber));
                    }

                    if (batchStock != null)
                    {
                        batchStockLevel.UpdateStock(siteId, issue.NSVCode, issue.BatchNumber, -issue.QuantityInIssueUnits / product.ConversionFactorPackToIssueUnits);
                    }
                }
                
                // Updated losses and gains
                // Question should this be for all returns or just manufacturing?
                if (issue.IssueType != IssueType.WardStock && issue.IssueType != IssueType.Bond && !isReturn)
                {
                    decimal annualUsage = Math.Max(product.AnnualUsageInIssueUnits ?? 0M, 12M);
                    lossGainAdjustment = issue.QuantityInIssueUnits * (product.LossesGainExVat / (annualUsage / 12M));
                    if (Math.Abs(lossGainAdjustment) > Math.Abs(product.LossesGainExVat))
                    {
                        lossGainAdjustment = product.LossesGainExVat;
                    }

                    // Prevent -ve issue price
                    decimal costOfIssue = (productStock.AverageCostExVatPerPack * issue.QuantityInIssueUnits) / product.ConversionFactorPackToIssueUnits;
                    if (issue.QuantityInIssueUnits > 0 && (costOfIssue + lossGainAdjustment) < 0M)
                    {
                        lossGainAdjustment = 1M - costOfIssue;
                    }
                    else if (issue.QuantityInIssueUnits < 0 && (costOfIssue + lossGainAdjustment) > 0M)
                    {
                        lossGainAdjustment = -1M - costOfIssue;
                    }

                    productStock.LossesGainExVat -= lossGainAdjustment;

                    // Check the losses and gains (copy of SubPatMe.bas checklossgain)
                    annualUsage  = Math.Max(product.AnnualUsageInIssueUnits ?? 1M, 1M);
                    decimal lossGainMargin = product.LossesGainExVat / (annualUsage / 12M); 
                    if ((lossGainMargin > (3 * product.AverageCostExVatPerPack)) || (lossGainMargin < -product.AverageCostExVatPerPack))
                    {
                        pharmacyLog.BeginRow(WPharmacyLogType.GainLoss, issue.NSVCode).SiteID = siteId;
                        pharmacyLog.AppendLineDetail("Translog Stck lvl={0} ",      product.StockLevelInIssueUnits);
                        pharmacyLog.AppendLineDetail("PckSz={0} ",                  product.ConversionFactorPackToIssueUnits);
                        pharmacyLog.AppendLineDetail("Issue price={0}|",            product.AverageCostExVatPerPack.ToMoneyString(MoneyDisplayType.Show));
                        pharmacyLog.AppendLineDetail("Ann use={0} ",                product.AnnualUsageInIssueUnits);
                        pharmacyLog.AppendLineDetail("Qty issued={0} ",             issue.QuantityInIssueUnits);
                        pharmacyLog.AppendLineDetail("Resultant Losses/gains={0} ", product.LossesGainExVat);
                        pharmacyLog.EndRow();
                    }

                    // issuecost = Not set as code does not seem to do much with it!!!
                }

                // Question: Have not implemented this as seems to be for balancing transactions (rather than returns) so what is that?
                //if (issue.IssueType == IssueType.ManufactureReturn)
                //{
                //    decimal originalStockValueExVatPerPack = (product.StockLevelInIssueUnits / product.ConversionFactorPackToIssueUnits) * product.AverageCostExVatPerPack;
                //    decimal newStockLvlInIssueUnits        = Math.Abs(issue.QuantityInIssueUnits) + product.StockLevelInIssueUnits;
                //    decimal returnStockValueExVatPerPack   = issue.CostExVat;
                //    productStock.AverageCostExVatPerPack   = (Math.Abs(newStockLvlInIssueUnits) <= 0M) ? issue.CostExVat : ((originalStockValueExVatPerPack + returnStockValueExVatPerPack) / newStockLvlInIssueUnits) * product.ConversionFactorPackToIssueUnits;
                //}
                
                // Update stock levels
                if (issue.IssueType != IssueType.Bond)
                {
                    productStock.StockLevelInIssueUnits = (productStock.StockLevelInIssueUnits - (decimal)issue.QuantityInIssueUnits).To7Sf7Dp();

                    if (issue.IssueType != IssueType.WardStock && !isReturn)
                    {
                        productStock.UseThisPeriodInIssueUnits  += (double)issue.QuantityInIssueUnits;
                        productStock.LastIssuedDate             = now;
                    }
                }

                //if (issue.IssueType != WTranslogType.WardStock && (!issue.IsBondStoreIssue || (issue.IsReturn && issue.IssueType == WTranslogType.Manufacturing)))
                //{
                //    product.StockLevelInIssueUnits     -= (decimal)batch.QuantityInIssueUnits;
                //    product.UseThisPeriodInIssueUnits  += (double)batch.QuantityInIssueUnits;
                //}

                // write translog
                var tlog = translog.Add();
                tlog.NSVCode                            = product.NSVCode;
                tlog.ConversionFactorPackToIssueUnits   = product.ConversionFactorPackToIssueUnits;
                tlog.IssueUnits                         = product.PrintformV.SafeSubstring(0, translogColumnInfo.IssueUnitsLength); // 16Aug16 XN 160324 truncate to data field length
                tlog.QuantityInIssueUnits               = issue.QuantityInIssueUnits;
                tlog.CostExVat                          = issue.CostExVat.To7Sf7Dp();
                tlog.CostIncVat                         = (tlog.CostExVat * vatRate).To7Sf7Dp();
                tlog.VatCost                            = (tlog.CostIncVat - tlog.CostExVat).To7Sf7Dp();
                tlog.VatRate                            = vatRate; 
                tlog.VatCode                            = product.VATCode;
                tlog.WardCode                           = issue.CostCentreCode.SafeSubstring(0, translogColumnInfo.WardCodeLength);         // 16Aug16 XN 160324 truncate to data field length
                tlog.DirectionCode                      = issue.DirectionCode.SafeSubstring (0, translogColumnInfo.DirectionCodeLength);    // 16Aug16 XN 160324 truncate to data field length
                tlog.SiteNumber                         = siteNumber;
                tlog.SiteID                             = siteId;
                tlog.PrescriptionNum                    = issue.PrescriptionNum;
                tlog.BatchNumber                        = string.IsNullOrEmpty(issue.BatchNumber) ? (issue.ManufacturingBatchNumber ?? string.Empty) : issue.BatchNumber;
                tlog.BatchExpiryDate                    = issue.BatchExpiryDate;
                tlog.StockLevel                         = productStock.StockLevelInIssueUnits;
                tlog.StockValue                         = ((productStock.StockLevelInIssueUnits / product.ConversionFactorPackToIssueUnits) * productStock.AverageCostExVatPerPack).To7Sf7Dp();
                tlog.WWardProductListLineID             = issue.WWardProductListLineID ?? 0;
                tlog.RequestId_AmmSupplyRequest         = issue.RequestIdAmmSupplyRequest;
                tlog.AmmSupplyRequestIngredientId       = issue.AmmSupplyRequestIngredientId;
                tlog.RequestID_Prescription             = issue.RequestIdPrescription ?? 0;
                tlog.ProductId                          = product.ProductID ?? 0;
                tlog.EntityID                           = SessionInfo.EntityID;
                tlog.EntityID_Prescriber                = consultant == null ? 0            : consultant.EntityID;
                tlog.PatientID                          = patient    == null ? (int?)null   : patient.EntityID;
                tlog.CaseNumber                         = patient    == null ? string.Empty : patient.GetCaseNumber().SafeSubstring(0, translogColumnInfo.CaseNumberLength);            // 16Aug16 XN 160324 truncate to data field length
                tlog.ConsultantCode                     = consultant == null ? string.Empty : consultant.Code.SafeSubstring(0, translogColumnInfo.ConsultantCodeLength);                // 16Aug16 XN 160324 truncate to data field length
                tlog.ConsultantSpecialty                = episode    == null ? string.Empty : episode.GetSpecialty().SafeSubstring(0, translogColumnInfo.ConsultantSpecialtyLength);    // 16Aug16 XN 160324 truncate to data field length
                tlog.EpisodeID                          = episodeId ?? 0;
                tlog.DateTime                           = now;
                tlog.CivasAmount                        = issue.CivasAmount;

                var NHSNumberSplit = (patient == null) ? new string[0] : patient.GetNHSNumber().Split(' ');
                tlog.NHNumber      = NHSNumberSplit.Length == 0 ? string.Empty : NHSNumberSplit[0];
                tlog.NHNumberValid = NHSNumberSplit.Length > 1 && NHSNumberSplit[1].Trim(new [] {'(', ')'}).EqualsNoCase("VALID");

                switch (issue.IssueType)
                {
                case IssueType.ManufactureIngredient:
                    tlog.Kind       = WTranslogType.Manufacturing;
                    tlog.LabelType  = WTranslogType.Civas;
                    break;
                case IssueType.Manufacture:
                    tlog.Kind       = WTranslogType.Manufacturing;
                    tlog.LabelType  = WTranslogType.Manufacturing;
                    break;
                    case IssueType.Bond:
                    tlog.Kind      = WTranslogType.Manufacturing;
                    tlog.LabelType = WTranslogType.Manufacturing;
                    break;
                case IssueType.DispenseInPatient:
                    tlog.Kind       = WTranslogType.Inpatient;
                    tlog.LabelType  = issue.LabelType.Value;
                    break;
                case IssueType.DispenseOutPatient:
                    tlog.Kind       = WTranslogType.Outpatient;
                    tlog.LabelType  = issue.LabelType.Value;
                    break;
                case IssueType.DispenseDischarge:
                    tlog.Kind       = WTranslogType.Discharge;
                    tlog.LabelType  = issue.LabelType.Value;
                    break;
                case IssueType.DispenseLeave:
                    tlog.Kind       = WTranslogType.Leave;
                    tlog.LabelType  = issue.LabelType.Value;
                    break;
                default:
                    throw new ApplicationException("Issue.Update invalid issue type " + issue.IssueType.ToString());
                }

                // Question if the batch does not have an expiry should it be allowed to go to bond
                if (!string.IsNullOrWhiteSpace(issue.BatchNumber) && !string.IsNullOrWhiteSpace(PatMedSetting.Manufacturing.BondCostCenter(siteId)))
                {
                    if (bondStore.FindByNsvCodeAndBatchNumber(product.NSVCode, issue.BatchNumber) == null)
                        bondStore.LoadBySiteNsvCodeAndBatchNumber(siteId, product.NSVCode, issue.BatchNumber, true);
                    
                    if (issue.IssueType == IssueType.Bond && isReturn)
                    {
                        if (bondStoreComplete.FindByNsvCodeAndBatchNumber(product.NSVCode, issue.BatchNumber, true) == null)
                            bondStoreComplete.LoadBySiteNsvCodeAndBatchNumber(siteId, product.NSVCode, issue.BatchNumber, true);
                        bondStoreComplete.UpdateStock(issue.NSVCode, issue.BatchNumber, issue.QuantityInIssueUnits, true);
                        
                        var bondRow = bondStore.FindByNsvCodeAndBatchNumber(product.NSVCode, issue.BatchNumber);
                        if (bondRow == null)
                            bondRow = bondStore.Add(product);

                        bondRow.BatchNumber         = issue.BatchNumber;
                        bondRow.ExpiryDate          = issue.BatchExpiryDate;
                        bondRow.QuantityInIssueUnits+= -(double)issue.QuantityInIssueUnits;
                        bondRow.TotalCostExTax      += (double)tlog.CostExVat;
                        bondRow.TotalCostIncTax     += (double)tlog.CostIncVat;
                        bondRow.TotalCostTax        += (double)tlog.VatCost;
                    }
                    else if ((issue.IssueType == IssueType.Bond && !isReturn) || isIssueToPatient)
                    {
                        if (issue.BondStoreReturn)
                            bondStore.UpdateStock(issue.NSVCode, issue.BatchNumber, -issue.QuantityInIssueUnits);
                        else
                            bondStore.MoveToComplete(bondStoreComplete, issue.NSVCode, issue.BatchNumber, -issue.QuantityInIssueUnits);
                    }
                }

                //tlog.PPFlag = does not seem to be set in the db so have not set here assume this is okay
                //tlog.PrescriberID = does not seem to be set in the db so have not set here assume this is okay  
                // tlog.containers  Did not do these as don't seem to have data entered
                // tlog.Eventnumber
                // tlog.CustomerOrderNumber
                // tlog.InternalOrderNumber
                // tlog.CivasType
            }
            
            bool useTransaction = WConfiguration.Load<bool>(siteId, "D|ascribe", string.Empty, "WTranslogTransactionWrapper", true, false);
            using (ICWTransaction scope = new ICWTransaction(useTransaction ? ICWTransactionOptions.ReadCommited : ICWTransactionOptions.NoTransaction))
            {
                this.productStocks.Save();
                this.batchStockLevel.Save();
                pharmacyLog.Save();
                bondStore.Save();
                bondStoreComplete.Save();
                translog.Save();

                scope.Commit();
            }

            // Write rows to the interface file
            string paymentCategory = episode == null ? string.Empty : episode.GetPaymentCategory();
            if (translog.Any(t => (new TranslogInterfaceSettings(siteId, paymentCategory, t)).Enabled))
            {
                PharmacyInterface interfaceFile = new PharmacyInterface();
                WCustomer         wards         = new WCustomer();

                // Cache xml heap mappings (as don't change)
                string[] preXml = episode == null ? new string[0] : new string[] { patient.ToXmlHeap(), episode.ToXmlHeap() };

                // force read loading of product data as may of been update above
                products.Clear();   

                foreach (var row in translog)
                {
                    // Check if transaction row should be saved to interface file
                    TranslogInterfaceSettings settings = new TranslogInterfaceSettings(siteId, paymentCategory, row); // Note that this is correct it should use the SupplierInterfaceSettings for legacy reasons (both customer, and suppliers were in the WSupplier table)
                    if (settings.Enabled)
                    {
                        string wardCode = WConfiguration.LoadAndCache<string>(siteId, "D|GenInt", "TransactionWardMapper", row.WardCode, string.Empty, true);
                        if (products.FindBySiteIDAndNSVCode(siteId, row.NSVCode) == null)
                        {
                            products.LoadByProductAndSiteID(row.NSVCode, siteId, append: true);
                        }

                        if (wards.FindBySiteAndCode(siteId, wardCode) == null)
                        {
                            wards.LoadBySiteAndCode(siteId, wardCode, append: true);
                        }

                        interfaceFile.Initialise(settings);

                        // Parse interface data
                        preXml.ToList().ForEach(x => interfaceFile.ParseXml(x));                    
                        interfaceFile.ParseXml(products.FindBySiteIDAndNSVCode(siteId, row.NSVCode).ToXMLHeap());
                        interfaceFile.ParseXml(row.ToXMLHeap());
                        if (wards.FindBySiteAndCode(siteId, wardCode) != null)
                        {
                            interfaceFile.ParseXml(wards.FindBySiteAndCode(siteId, wardCode).ToXMLHeap());
                        }

                        // Parse extra parameters
                        interfaceFile.Parse("pPatientPaymentCategory", paymentCategory);
                        interfaceFile.Parse("tWard",                   wardCode);
                        interfaceFile.Parse("tWardXML",                wardCode.XMLEscape());
                        interfaceFile.Parse("pFlagDefault",            "Y".EqualsNoCase(row.PPFlag) ? "N" : row.PPFlag);

                        // And save
                        interfaceFile.Save();
                    }
                }
            }
        }

        /// <summary>
        /// Converts the episode type to an IssueType (only supports episode types InPatient, OutPatient, Leave, Discharge)
        /// e.g. EpisodeType.DispenseInPatient returns IssueType.InPatient
        /// </summary>
        /// <param name="episodeType">Episode type</param>
        /// <returns>Issue type</returns>
        public static IssueType GetIssueTypeFromEpisodeType(EpisodeType episodeType)
        {
            switch (episodeType)
            {
            case EpisodeType.InPatient:  return IssueType.DispenseInPatient;  break;
            case EpisodeType.OutPatient: return IssueType.DispenseOutPatient; break;
            case EpisodeType.Leave:      return IssueType.DispenseLeave;      break;
            case EpisodeType.Discharge:  return IssueType.DispenseDischarge;  break;
            default: throw new ApplicationException(string.Format("IssueStock.GetIssueTypeFromEpisodeType can not convert {0} to a valid issue type.", episodeType));
            }
        }

        /// <summary>Unlocks rows</summary>
        /// <param name="disposing">If disposing</param>
        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);

            if (disposing)
            {
                batchStockLevel.Dispose();
                productStocks.Dispose();
            }
        }
    }
}
