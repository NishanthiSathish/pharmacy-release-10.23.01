//===========================================================================
//
//							    WBatchStockLevel.cs
//
//  Provides access to WBatchStockLevel table.
//
//  The table is used to track batch information. Each batch is identified by site, 
//  product, and batch number. Not all pharmacies make use of batch tracking.
//
//	Modification History:
//	15Apr09 XN  Written
//  15Apr16 XN  Moved to BaseTable2 123082
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Row in the WBatchStockLevel table</summary>
    public class WBatchStockLevelRow : BaseRow
    {
        public int WBatchStockLevelID
        {
            get { return FieldToInt(RawRow["WBatchStockLevelID"]).Value; }
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
            get { return FieldToStr(RawRow["Batchnumber"]);  }
            set { RawRow["Batchnumber"] = StrToField(value); }
        }

        public DateTime? ExpiryDate
        {
            get { return FieldToDateTime(RawRow["Expiry"]);  }
            set { RawRow["Expiry"] = DateTimeToField(value); }
        }

        public double QuantityInPacks
        {
            get { return FieldToDouble(RawRow["qty"]).Value;  }
            set { RawRow["qty"] = DoubleToField(value);       }
        }

        public override string ToString()
        {
            return BatchNumber;
        }
    }

    /// <summary>Table info for WBatchStockLevel table</summary>
    public class WBatchStockLevelColumnInfo : BaseColumnInfo
    {
        public WBatchStockLevelColumnInfo() : base("WBatchStockLevel") { }

        public int DescriptionLength { get { return tableInfo.GetFieldLength("Description"); } }
        public int BatchNumberLength { get { return tableInfo.GetFieldLength("Batchnumber"); } }
    }


    /// <summary>Represent the WBatchStockLevel table</summary>
    public class WBatchStockLevel : BaseTable2<WBatchStockLevelRow, WBatchStockLevelColumnInfo>
    {
        public WBatchStockLevel() : base("WBatchStockLevel") { }
        //{
        //    UpdateSP = "pWBatchStockLevelUpdate";
        //}

        public override WBatchStockLevelRow Add()
        {
            var newRow = base.Add();
            newRow.SiteID          = SessionInfo.SiteID;
            newRow.QuantityInPacks = 0;
            return newRow;
        }

        /// <summary>
        /// Loads the batches by site, and NSVCode
        /// </summary>
        /// <param name="siteID">Batch site ID</param>
        /// <param name="NSVCode">Batch product NSV code</param>
        public void LoadBySiteIDAndNSVCode(int siteID, string NSVCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",   SessionInfo.SessionID);
            parameters.Add("LocationID_Site",    siteID);
            parameters.Add("NSVCode",            NSVCode);
            this.LoadBySP("pWBatchStockLevelbySiteandNSVCode", parameters);
        }

        /// <summary>
        /// Loads a batch by site, NSVCode, and batch number.
        /// </summary>
        /// <param name="siteID">Batch site ID</param>
        /// <param name="NSVCode">Batch product NSV code</param>
        /// <param name="batchNumber">Batch number</param>
        /// <param name="append">If batch should be appended to the existing list</param>
        public void LoadBySiteIDNSVCodeAndBatchNumber(int siteID, string NSVCode, string batchNumber, bool append)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteID",            siteID);
            parameters.Add("NSVCode",           NSVCode);
            parameters.Add("Batchnumber",       batchNumber);
            this.LoadBySP(append, "pWBatchStockLevelbySiteIDNSVCodeAndBatchnumber", parameters);
        }

        ///// <summary>
        ///// Override the base class as the default pWBatchStockLevelInsert is incorrect     
        ///// as parameter LocationID_Site should be SiteID
        ///// </summary>
        ///// <param name="row">Row to insert</param>
        //protected override void InsertRow(DataRow row)
        //{
        //    DataColumnCollection columns = Table.Columns;

        //    StringBuilder parameters = new StringBuilder();
        //    AddInputParam(parameters, "LocationID_Site",    row["SiteID"],      GetTLDataType(columns["SiteID"].DataType));   
        //    AddInputParam(parameters, "NSVCode",            row["NSVCode"],     GetTLDataType(columns["NSVCode"].DataType));   
        //    AddInputParam(parameters, "Description",        row["Description"], GetTLDataType(columns["Description"].DataType));   
        //    AddInputParam(parameters, "BatchNumber",        row["BatchNumber"], GetTLDataType(columns["BatchNumber"].DataType));   
        //    AddInputParam(parameters, "Expiry",             row["Expiry"],      GetTLDataType(columns["Expiry"].DataType));   
        //    AddInputParam(parameters, "Qty",                row["Qty"],         GetTLDataType(columns["Qty"].DataType));   
            
        //    int pk = dblayer.ExecuteInsertSP ( SessionInfo.SessionID, TableName, parameters.ToString() );

        //    DataColumn pkcolumn = Table.Columns[PKColumnName];
        //    pkcolumn.ReadOnly = false;
        //    row[PKColumnName] = pk;
        //    pkcolumn.ReadOnly = true;
        //}

        /// <summary>
        /// Locates and updates the stock value (if the stock level is 0 or -ve then row is removed
        /// Will NOT load the data form db, or save.
        /// </summary>
        /// <param name="siteId">site Id</param>
        /// <param name="NsvCode">Nsv code</param>
        /// <param name="batchNumber">batch number</param>
        /// <param name="quantityInPacks">quantity to add</param>
        public void UpdateStock(int siteId, string NsvCode, string batchNumber, decimal quantityInPacks)
        {
            var batch = this.FindBySiteIDNSVCodeAndBatchNumber(siteId, NsvCode, batchNumber);
            if (batch != null)
            {
                batch.QuantityInPacks += (double)quantityInPacks;
                if (batch.QuantityInPacks <= 0)
                {
                    this.Remove(batch);
                }
            }
        }
    }

    /// <summary>Bond store enumerable extension methods</summary>
    public static class WBatchStockLevelEnumerableExtension
    {
        /// <summary>Gets the first WBatchStockLevelRow by site, NsvCode, and batch number</summary>
        /// <param name="list">List of WBatchStockLevelRows</param>
        /// <param name="siteId">site Id</param>
        /// <param name="NSVCode">NsvCode</param>
        /// <param name="batchNumber">Batch number</param>
        /// <returns>first WBatchStockLevelRow</returns>
        public static WBatchStockLevelRow FindBySiteIDNSVCodeAndBatchNumber(this IEnumerable<WBatchStockLevelRow> list, int siteId, string NSVCode, string batchNumber)
        {
            return list.FirstOrDefault(l => l.BatchNumber == batchNumber && l.NSVCode == NSVCode && l.SiteID == siteId);
        }
    }
}
