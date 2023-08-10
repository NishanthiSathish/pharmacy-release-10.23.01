// -----------------------------------------------------------------------
// <copyright file="BondStore.cs" company="Emis Health Plc">
// Copyright Emis Health Plc
// </copyright>
// <summary>
// Provides access to PharmacyBondStore table.
//
// The table is used to track batches going into and out of bond store, 
// which can be the final stage of manufacturing for some sites.
//
//	Modification History:
//  15Apr16 XN  Created 123082
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.pharmacydatalayer
{
    using System;
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using System.Linq;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>Row in the PharmacyBondStore table</summary>
    public class BondStoreRow : BaseRow
    {
        public int PharmacyBondStoreID
        {
            get { return FieldToInt(RawRow["PharmacyBondStoreID"]).Value; }
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]).Value;  }
            set { RawRow["SiteID"] = IntToField(value);       }
        }

        public string NSVCode
        {
            get { return FieldToStr(RawRow["NSVCode"]);  }
            set { RawRow["NSVCode"] = StrToField(value); }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"]);  }
            set { RawRow["Description"] = StrToField(value); }
        }

        public string BatchNumber
        {
            get { return FieldToStr(RawRow["BatchNumber"]);  }
            set { RawRow["BatchNumber"] = StrToField(value); }
        }

        /// <summary>DB field code Expiry</summary>
        public DateTime? ExpiryDate
        {
            get { return FieldToDateTime(RawRow["Expiry"]);  }
            set { RawRow["Expiry"] = DateTimeToField(value); }
        }

        /// <summary>DB field code Qty</summary>
        public double QuantityInIssueUnits
        {
            get { return FieldToDouble(RawRow["Qty"]).Value;  }
            set { RawRow["Qty"] = DoubleToField(value);       }
        }

        /// <summary>DB field code Issue_To_Bond</summary>
        public DateTime? IssueToBondDate
        {
            get { return FieldToDateTime(RawRow["Issue_To_Bond"]).Value;  }
            set { RawRow["Issue_To_Bond"] = DateTimeToField(value);       }
        }

        /// <summary>
        /// This is the quantity of the manufactured product that is used for QA testing
        /// DB field code QAQty
        /// </summary>
        public double QAQuantityinIssueUnits
        {
            get { return FieldToDouble(RawRow["QAQty"]).Value;  }
            set { RawRow["QAQty"] = DoubleToField(value);       }
        }

        public double TotalCostExTax
        {
            get { return FieldToDouble(RawRow["TotalCostExTax"]).Value;  }
            set { RawRow["TotalCostExTax"] = DoubleToField(value);       }
        }

        public double TotalCostTax
        {
            get { return FieldToDouble(RawRow["TotalCostTax"]).Value;  }
            set { RawRow["TotalCostTax"] = DoubleToField(value);       }
        }

        public double TotalCostIncTax
        {
            get { return FieldToDouble(RawRow["TotalCostIncTax"]).Value;  }
            set { RawRow["TotalCostIncTax"] = DoubleToField(value);       }
        }
    }


    /// <summary>Table info for PharmacyBondStore table</summary>
    public class BondStoreColumnInfo : BaseColumnInfo
    {
        public BondStoreColumnInfo() : base("PharmacyBondStore") { }

        public int NSVCodeLength     { get { return tableInfo.GetFieldLength("NSVCode");     } }
        public int DescriptionLength { get { return tableInfo.GetFieldLength("Description"); } }
        public int BatchNumberLength { get { return tableInfo.GetFieldLength("BatchNumber"); } }
    }


    /// <summary>Represent the PharmacyBondStore table</summary>
    public class BondStore : BaseTable2<BondStoreRow, BondStoreColumnInfo>
    {
        public BondStore() : base("PharmacyBondStore") { }

        public BondStoreRow Add(WProductRow product)
        {
            var newRow = base.Add();
            newRow.Description            = product.ToLocalOrLabelString();
            newRow.IssueToBondDate        = DateTime.Now;
            newRow.NSVCode                = product.NSVCode;
            newRow.SiteID                 = product.SiteID;
            newRow.QuantityInIssueUnits   = 0.0;
            newRow.QAQuantityinIssueUnits = 0.0; 
            newRow.TotalCostExTax         = 0.0;
            newRow.TotalCostIncTax        = 0.0;
            newRow.TotalCostTax           = 0.0;
            return newRow;
        }

        /// <summary>
        /// Adds new bond store row
        /// Copies values from BondStoreComplete, does not include quantity or totals.
        /// </summary>
        /// <param name="row">BondStoreComplete  row</param>
        /// <returns>new BondStore row</returns>
        public BondStoreRow Add(BondStoreCompleteRow row)
        {
            var columnInfo = BondStore.GetColumnInfo();
            var newRow = base.Add();
            newRow.SiteID          = row.SiteID;
            newRow.NSVCode         = row.NSVCode;
            newRow.Description     = row.Description;
            newRow.ExpiryDate      = row.ExpiryDate;
            newRow.IssueToBondDate = row.IssueToBondDate;
            newRow.BatchNumber     = row.BatchNumber;
            newRow.QuantityInIssueUnits   = 0.0;
            newRow.QAQuantityinIssueUnits = 0.0; 
            newRow.TotalCostExTax         = 0.0;
            newRow.TotalCostIncTax        = 0.0;
            newRow.TotalCostTax           = 0.0;
            return newRow;
        }

        /// <summary>Loads the batches by site, and NSVCode, and batch number</summary>
        /// <param name="siteID">Batch site ID</param>
        /// <param name="NSVCode">Batch product NSV code</param>
        /// <param name="batchNumber">Batch number</param>
        /// <param name="append">appends row</param>
        public void LoadBySiteNsvCodeAndBatchNumber(int siteID, string NSVCode, string batchNumber, bool append = false)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SiteID",     siteID);
            parameters.Add("NSVCode",    NSVCode);
            parameters.Add("batchNumber",batchNumber);
            this.LoadBySP(append, "pPharmacyBondStoreBySiteNSVCodeAndBatchNumber", parameters);
        }

        /// <summary>
        /// Locates and updates the stock value (if the stock level is 0 or -ve then row is removed
        /// Will NOT load the data form db, or save.
        /// </summary>
        /// <param name="NsvCode">Nsv code</param>
        /// <param name="batchNumber">batch number</param>
        /// <param name="quantityInPacks">quantity to add</param>
        public void UpdateStock(string NsvCode, string batchNumber, decimal quantityInIssueUnits)
        {
            var bond = this.FindByNsvCodeAndBatchNumber(NsvCode, batchNumber);
            if (bond != null)
            {
                double costExTaxPerIssueUnit = 0.0, costTaxPerIssueUnit = 0.0, costIncTaxPerIssueUnit = 0.0;
                if (bond.QuantityInIssueUnits > 0)
                {
                    costExTaxPerIssueUnit = bond.TotalCostExTax / bond.QuantityInIssueUnits;
                    costIncTaxPerIssueUnit= bond.TotalCostIncTax/ bond.QuantityInIssueUnits;
                    costTaxPerIssueUnit   = bond.TotalCostTax   / bond.QuantityInIssueUnits;
                }
                
                bond.QuantityInIssueUnits += (double)quantityInIssueUnits;
                if (bond.QuantityInIssueUnits <= 0)
                {
                    this.Remove(bond);
                }
                else
                {
                    bond.TotalCostExTax  = costExTaxPerIssueUnit * bond.QuantityInIssueUnits;
                    bond.TotalCostIncTax = costIncTaxPerIssueUnit* bond.QuantityInIssueUnits;
                    bond.TotalCostTax    = costTaxPerIssueUnit   * bond.QuantityInIssueUnits;
                }
            }
        }

        /// <summary>Moves the rows from BondStore to BondStoreComplete</summary>
        /// <param name="bondStoreComplete">BondStoreComplete</param>
        /// <param name="NsvCode">Nsv code</param>
        /// <param name="batchNumber">batch number</param>
        /// <param name="quantityInPacks">quantity to add</param>
        public void MoveToComplete(BondStoreComplete bondStoreComplete, string NsvCode, string batchNumber, decimal quantityInIssueUnits)
        {
            // Get the row in the bond store
            var bondStoreRow = this.FindByNsvCodeAndBatchNumber(NsvCode, batchNumber);
            if (bondStoreRow == null)
                return;
            
            // Load the row in the bond store complete 
            if (bondStoreComplete.FindByNsvCodeAndBatchNumber(NsvCode, batchNumber, release: true) == null)
                bondStoreComplete.LoadBySiteNsvCodeAndBatchNumber(bondStoreRow.SiteID, NsvCode, batchNumber, true);
            if (bondStoreComplete.FindByNsvCodeAndBatchNumber(NsvCode, batchNumber, release: true) == null)
            {
                double costExTaxPerIssueUnit = 0.0, costTaxPerIssueUnit = 0.0, costIncTaxPerIssueUnit = 0.0;
                if (bondStoreRow.QuantityInIssueUnits > 0)
                {
                    costExTaxPerIssueUnit = bondStoreRow.TotalCostExTax / bondStoreRow.QuantityInIssueUnits;
                    costIncTaxPerIssueUnit= bondStoreRow.TotalCostIncTax/ bondStoreRow.QuantityInIssueUnits;
                    costTaxPerIssueUnit   = bondStoreRow.TotalCostTax   / bondStoreRow.QuantityInIssueUnits;
                }
                
                var newRow = bondStoreComplete.Add(bondStoreRow);
                newRow.TotalCostExTax  = costExTaxPerIssueUnit  * -(double)quantityInIssueUnits;
                newRow.TotalCostIncTax = costIncTaxPerIssueUnit * -(double)quantityInIssueUnits;
                newRow.TotalCostTax    = costTaxPerIssueUnit    * -(double)quantityInIssueUnits;
                newRow.QuantityInIssueUnits   = -(double)quantityInIssueUnits;
                newRow.QAQuantityinIssueUnits = 0;
                newRow.Release                = true;
            }
            else
                bondStoreComplete.UpdateStock(NsvCode, batchNumber, -quantityInIssueUnits, true);
            
            // Move the stock from bond store to bond store complete
            this.UpdateStock(NsvCode, batchNumber, quantityInIssueUnits);
        }
    }

    /// <summary>Bond store enumerable extension methods</summary>
    public static class BondStoreEnumerableExtension
    {
        /// <summary>Gets the first BondStoreRow by NsvCode, and batch number</summary>
        /// <param name="list">List of BondStoreRow</param>
        /// <param name="NSVCode">NsvCode</param>
        /// <param name="batchNumber">Batch number</param>
        /// <returns>first BondStoreRow</returns>
        public static BondStoreRow FindByNsvCodeAndBatchNumber(this IEnumerable<BondStoreRow> list, string NSVCode, string batchNumber)
        {
            return list.FirstOrDefault(l => l.BatchNumber == batchNumber && l.NSVCode == NSVCode);
        }
    }
}
