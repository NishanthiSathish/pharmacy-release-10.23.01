//===========================================================================
//
//							  WFMDailyStockLevels.cs
//
//	Provides functions for writing to the WFMDailyStockLevels table
//  Used by finance manager
//
//  Note that the table might not be held in the main ICW DB and might be in separate DB.
//
//  The table holds the stock levels for all drugs, for all sites
//  up to the end of the day. 
//  The table should be updated every night using pWFMDailyStockLevelPopulate
//  The data for the tables comes from the ProductStock, WOrderlog, and WTranslog tables.
//
//  The cache of daily stock level needs time to build up once enabled (and overnight 
//  job is set to run), it will take 2 days before the data is valid.
//  You can get earliest valid date from WFMDailyStockLevel.GetEarliestValidDate()
//  Also as the table is populated on an overnight job the data is only valid upto
//  midnight of the previous day (use WFMDailyStockLevel.GetLastDate())
//
//  Supports reading.
//  
//	Modification History:
//	09Jul13 XN  Written 27038
//  17Feb14 XN  Allowed setting StockValueExVat, StockValueIncVat, and StockValueVat
//              to ease calculation on stock account sheet (84499)
//  20Aug14 XN  Allowed it to use the a separate DB if needed.
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.financemanagerlayer
{
    /// <summary>Represents a row in the WFMDailyStockLevel table</summary>
    public class WFMDailyStockLevelRow : BaseRow
    {
        public string NSVCode                { get { return FieldToStr(RawRow["NSVCode"], true, string.Empty);      } }
        public int    LocationID_Site        { get { return FieldToInt(RawRow["LocationID_Site"]) ?? 0;             } }
        public double StockLevelInIssueUnits { get { return FieldToDouble(RawRow["StockLevelInIssueUnits"]) ?? 0.0; } }
        
        public double StockValueExVat        
        { 
            get { return FieldToDouble(RawRow["StockValueExVat"]) ?? 0.0; } 
            set { RawRow["StockValueExVat"] = DoubleToField(value);       } 
        }
        
        public double StockValueIncVat       
        { 
            get { return FieldToDouble(RawRow["StockValueIncVat"]) ?? 0.0; } 
            set { RawRow["StockValueIncVat"] = DoubleToField(value);       } 
        }
        
        public double StockValueVat          
        { 
            get { return FieldToDouble(RawRow["StockValueVat"]) ?? 0.0; } 
            set { RawRow["StockValueVat"] = DoubleToField(value);       } 
        }
    }

    /// <summary>Provides column information about the WFMDailyStockLevel table</summary>
    public class WFMDailyStockLevelColumnInfo : BaseColumnInfo
    {
        public WFMDailyStockLevelColumnInfo() : base("WFMDailyStockLevel") {}
    }

    /// <summary>Represent the WFMDailyStockLevel table</summary>
    public class WFMDailyStockLevel : BaseTable2<WFMDailyStockLevelRow, WFMDailyStockLevelColumnInfo>
    {
        public WFMDailyStockLevel() : base("WFMDailyStockLevel") 
        {
            this.SelectCommandTimeout = 2 * 60; // 2mins
        }

        /// <summary>Returns stock level at specific date and time, for single or all drugs, for a specified site (timeout for this sp is 2mins)</summary>
        /// <param name="dateTime">date and time (inclusive) the balance is required for</param>
        /// <param name="locationID_Sites">List of sites</param>
        /// <param name="NSVCode">product NSVCode (optional can be null)</param>
        public void LoadByDateSitesAndNSVCode(DateTime dateTime, IEnumerable<int> locationID_Sites, string NSVCode)
        {
            List<SqlParameter> paramenters = new List<SqlParameter>();
            paramenters.Add(new SqlParameter("DateTime",         dateTime                                                       ));
            paramenters.Add(new SqlParameter("NSVCode",          string.IsNullOrEmpty(NSVCode) ? (object)DBNull.Value : NSVCode ));
            paramenters.Add(new SqlParameter("LocationID_Sites", locationID_Sites.ToCSVString(",")                              ));
            LoadBySP("pPharmacyGetClosingBalance", paramenters);
        }

        /// <summary>
        /// Returns the last date in WFMDailStockLevel.
        /// Normally yesturday
        /// </summary>
        public static DateTime? GetLastDate()
        {
            //return Database.ExecuteSQLScalar<DateTime?>("SELECT MAX([DateTime]) FROM WFMDailyStockLevel");    20Aug14 XN table might be in a separate DB
            return FMDatabase.ExecuteSQLScalar<DateTime?>("SELECT MAX([DateTime]) FROM WFMDailyStockLevel");    
        }
        /// <summary>
        /// Returns earliest date of valid data in WFMDailStockLevel table
        /// This is 2 day after the earliest date in WFMDailStockLevel
        ///     - 1st day is for data being copied from ProductStock to WFMDailStockLevel (normal set to day before current date)
        ///     - 2nd day is to cover items in the log that occurred between when WFMDailStockLevel first populate and start of day so data not correct till 2nd day
        /// </summary>
        public static DateTime? GetEarliestValidDate()
        {
            //DateTime? dt = Database.ExecuteSQLScalar<DateTime?>("SELECT MIN([DateTime]) FROM WFMDailyStockLevel");    20Aug14 XN table might be in a separate DB
            DateTime? dt = FMDatabase.ExecuteSQLScalar<DateTime?>("SELECT MIN([DateTime]) FROM WFMDailyStockLevel");
            if (dt != null)
                dt = dt.Value.AddDays(2);
            return dt;
        }

        /// <summary>Overriden to get connection string from FM db 20Aug14 XN</summary>
        protected override string ConnectionString
        {
            get { return FMDatabase.ConnectionString; }
        }
    }
}
