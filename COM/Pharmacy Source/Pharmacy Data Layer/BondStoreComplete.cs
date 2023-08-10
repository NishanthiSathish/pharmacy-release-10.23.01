// -----------------------------------------------------------------------
// <copyright file="BondStoreComplete.cs" company="Emis Health Plc">
// Copyright Emis Health Plc
// </copyright>
// <summary>
// Provides access to BondStoreComplete table.
//
// The table is used to track batches going into and out of bond store complete table, 
// which can be the final stage of manufacturing for some sites.
//
//	Modification History:
//  25Apr16 XN  Created 154181
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

    /// <summary>Row in the PharmacyBondStoreComplete table</summary>
    public class BondStoreCompleteRow : BaseRow
    {
        public int PharmacyBondStoreCompleteID
        {
            get { return FieldToInt(RawRow["PharmacyBondStoreCompleteID"]).Value; }
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

        /// <summary>DB field code Expiry</summary>
        public DateTime? ExpiryDate
        {
            get { return FieldToDateTime(RawRow["Expiry"]);  }
            set { RawRow["Expiry"] = DateTimeToField(value); }
        }

        /// <summary>DB field code Issue_To_Bond</summary>
        public DateTime? IssueToBondDate
        {
            get { return FieldToDateTime(RawRow["Issue_To_Bond"]).Value;  }
            set { RawRow["Issue_To_Bond"] = DateTimeToField(value);       }
        }

        public string BatchNumber
        {
            get { return FieldToStr(RawRow["BatchNumber"]);  }
            set { RawRow["BatchNumber"] = StrToField(value); }
        }

        /// <summary>DB field code Qty</summary>
        public double QuantityInIssueUnits
        {
            get { return FieldToDouble(RawRow["Qty"]).Value;  }
            set { RawRow["Qty"] = DoubleToField(value);       }
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

        /// <summary>DB field [UserID]</summary>
        public string UserInitials
        {
            get { return FieldToStr(RawRow["UserID"], trimString: true, nullVal: string.Empty ); }
            set { RawRow["UserID"] = StrToField(value, emptyStrAsNullVal: false);            	 }
        }

        public string Terminal
        {
            get { return FieldToStr(RawRow["Terminal"], trimString: true, nullVal: string.Empty ); }
            set { RawRow["Terminal"] = StrToField(value, emptyStrAsNullVal: false);            	 }
        }

        public DateTime? Date
        {
            get { return FieldToDateTime(RawRow["Date"]);  }
            set { RawRow["Date"] = DateTimeToField(value); }
        }

        public string Note
        {
            get { return FieldToStr(RawRow["Note"], trimString: true, nullVal: string.Empty ); }
            set { RawRow["Note"] = StrToField(value, emptyStrAsNullVal: false);            	   }
        }

        public bool? Release
        {
            get { return FieldToBoolean(RawRow["Release"]);  }
            set { RawRow["Release"] = BooleanToField(value); }
        }
    }


    /// <summary>Table info for PharmacyBondStoreComplete table</summary>
    public class BondStoreCompleteColumnInfo : BaseColumnInfo
    {
        public BondStoreCompleteColumnInfo() : base("PharmacyBondStoreComplete") { }

        public int NSVCodeLength      { get { return tableInfo.GetFieldLength("NSVCode");      } }
        public int DescriptionLength  { get { return tableInfo.GetFieldLength("Description");  } }
        public int BatchNumberLength  { get { return tableInfo.GetFieldLength("BatchNumber");  } }
        public int UserInitialsLength { get { return tableInfo.GetFieldLength("UserID");       } }
        public int TerminalLength     { get { return tableInfo.GetFieldLength("Terminal");     } }
        public int NoteLength         { get { return tableInfo.GetFieldLength("Note");         } }
    }


    /// <summary>Represent the PharmacyBondStoreComplete table</summary>
    public class BondStoreComplete : BaseTable2<BondStoreCompleteRow, BondStoreCompleteColumnInfo>
    {
        public BondStoreComplete() : base("PharmacyBondStoreComplete") { }

        public BondStoreCompleteRow Add(BondStoreRow row)
        {
            var columnInfo = BondStoreComplete.GetColumnInfo();
            var newRow = base.Add();
            newRow.SiteID          = row.SiteID;
            newRow.NSVCode         = row.NSVCode;
            newRow.Description     = row.Description;
            newRow.ExpiryDate      = row.ExpiryDate;
            newRow.IssueToBondDate = row.IssueToBondDate;
            newRow.BatchNumber     = row.BatchNumber;
            newRow.UserInitials    = SessionInfo.UserInitials.SafeSubstring(0, columnInfo.UserInitialsLength);
            newRow.Terminal        = SessionInfo.Terminal.SafeSubstring(0, columnInfo.TerminalLength);
            newRow.Date            = DateTime.Now;
            newRow.Note            = string.Empty;
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
            this.LoadBySP(append, "pPharmacyBondStoreCompleteBySiteNSVCodeAndBatchNumber", parameters);
        }

        /// <summary>
        /// Locates and updates the stock value (if the stock level is 0 or -ve then row is removed
        /// Will NOT load the data form db, or save.
        /// </summary>
        /// <param name="NsvCode">Nsv code</param>
        /// <param name="batchNumber">batch number</param>
        /// <param name="quantityInPacks">quantity to add</param>
        public void UpdateStock(string NsvCode, string batchNumber, decimal quantityInIssueUnits, bool release)
        {
            var bond = this.FindByNsvCodeAndBatchNumber(NsvCode, batchNumber, release);
            if (bond != null)
            {
                double costExTaxPerIssueUnit = 0.0, costTaxPerIssueUnit = 0.0, costIncTaxPerIssueUnit = 0.0;
                if (bond.QuantityInIssueUnits > 0)
                {
                    costExTaxPerIssueUnit = bond.TotalCostExTax / bond.QuantityInIssueUnits;
                    costTaxPerIssueUnit   = bond.TotalCostIncTax/ bond.QuantityInIssueUnits;
                    costTaxPerIssueUnit   = bond.TotalCostTax   / bond.QuantityInIssueUnits;
                }
                
                bond.QuantityInIssueUnits += (double)quantityInIssueUnits;
                bond.TotalCostExTax  += (costExTaxPerIssueUnit * (double)quantityInIssueUnits);
                bond.TotalCostIncTax += (costTaxPerIssueUnit   * (double)quantityInIssueUnits);
                bond.TotalCostTax    += (costTaxPerIssueUnit   * (double)quantityInIssueUnits);

                if (bond.QuantityInIssueUnits <= 0)
                {
                    this.Remove(bond);
                }
            }
        }
    }

    /// <summary>Bond store enumerable extension methods</summary>
    public static class BondStoreCompleteEnumerableExtension
    {
        /// <summary>Gets the first BondStoreCompleteRow by NsvCode, and batch number</summary>
        /// <param name="list">List of BondStoreCompleteRow</param>
        /// <param name="NSVCode">NsvCode</param>
        /// <param name="batchNumber">Batch number</param>
        /// <returns>first BondStoreCompleteRow</returns>
        public static BondStoreCompleteRow FindByNsvCodeAndBatchNumber(this IEnumerable<BondStoreCompleteRow> list, string NSVCode, string batchNumber, bool release)
        {
            return list.FirstOrDefault(l => l.BatchNumber == batchNumber && l.NSVCode == NSVCode && l.Release == release);
        }
    }
}
