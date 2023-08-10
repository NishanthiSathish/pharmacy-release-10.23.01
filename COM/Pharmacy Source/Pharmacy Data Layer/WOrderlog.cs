//===========================================================================
//
//							       WOrderlog.cs
//
//  Provides access to WOrderlog table.
//
//  WOrderlog table holds pharmacy specific log data.
//
//  Only supports reading, and inserting. 
//  There are also functions to return monthly totals.
//  Data bound on web page DisplayLogRows.ascx
//
//  The following orderlog rows are not accessible as it is believed that they are 
//  not used.
//      Date3    
//      Time3,    
//      Qty3     
//      Info  
//      LinkedNum
//  
//	Modification History:
//	15Apr09 XN  Written
//  22Jul09 XN  Added functions GetMonthlyQuantityOrdered and 
//              GetMonthlyQuantityReceived to read in monthly totals.
//  21Dec09 XN  Allowed empty InvoiceNumbers to be saved as blank string rather
//              than null (F0042698).
//  02Nov10 AJK F0086901 Added DateInvoiced
//  02Nov10 AJK F0054531 Added DeliveryNoteReference
//  15Nov10 XN  F0086901 Made DateInvoiced, and DeliveryNoteReference optional, 
//              as some DB versions don't support it (present in 10.4, and 
//              then 10.6 onwards)
//  11Jan10 XN  F0086901 changed DateInvoiced, and DeliveryNoteReference 
//              to not be optional as will always be present in the db
//  02Jun11 XN  F0118610 Item enquiry screen need to show EDI orders in the 
//              historical order list
//  20Oct11 XN  When saves user initials got to use SafeSubString if initials too short
//  19Sep12 XN  Updated InsertRow as new fields (ContractNumber, ContractPrice, Contract)
//              have been added to pWorderlog 44321
//  05Jul13 XN  Moved to BaseTable2 and added KindRaw, LoadByCriteria 27252
//  27Jun14 XN  Initalised fields ContractNumber, ContractPrice, Contract, Date3, Time3, 
//              Qty3, Info, LinkedNum, in the add method (as this is what BaseTable did)
//              Changed ConversionFactor to save null as empty string. 43318
//  18Aug14 XN  GetMonthlyQuantityOrdered and GetMonthlyQuantityReceived 
//              Update to WHERE clause in summary view 86624 
//  28Nov16 XN Knock on effects to change in BaseTable2.WriteToAudtiLog 147104
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
 
namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Log entry type</summary>
    public enum WOrderLogType
    {
        [EnumDBCode("")]  Unknown,

        /// <summary>
        /// DB code 'D'
        /// When a direct order has been raised
        /// </summary>
        [EnumDBCode("D")]  Ordered,

        /// <summary>
        /// DB code 'I'
        /// When internal order placed (Buyer's end)
        /// </summary>
        [EnumDBCode("I")] OrderedInternal,

        /// <summary>
        /// DB code 'O'
        /// Create a new order on orders machine ord.supcode="INTER" for internal
        /// and "MODEM" for modem orders or raise an internal or modem order
        /// </summary>
        [EnumDBCode("O")] OrderedViaEDI,

        /// <summary>
        /// DB code 'F'
        /// When FTU order placed (edittype 2 goes to 3)
        /// </summary>
        [EnumDBCode("F")] OrderedFTU,

        /// <summary>
        /// DB code 'N'
        /// Delete orders already raised (Never to be received) also used when 
        /// modem or FTU orders are reinstated without transmission status 2 to 1
        /// </summary>
        [EnumDBCode("N")] DeletedRaisedOrders,

        /// <summary>
        /// DB code 'E'
        /// Issue a return when delivery note printed
        /// </summary>
        [EnumDBCode("E")] IssuedReturn,

        /// <summary>
        /// DB code 'R'
        /// Receive item
        /// </summary>
        [EnumDBCode("R")]  Receipt,

        /// <summary>
        /// DB code 'A'
        /// Adjust stock value
        /// </summary>
        [EnumDBCode("A")]  AdjustStockCost,

        /// <summary>
        /// DB code 'S'
        /// Adjust stock level
        /// </summary>
        [EnumDBCode("S")] AdjustStockLevel,

        /// <summary>DB code 'Q'</summary>
        [EnumDBCode("Q")]  BatchUpdate,

        /// <summary>DB code 'C'</summary>
        [EnumDBCode("C")]  CreateSupplier,

        /// <summary>DB code 'T'</summary>
        [EnumDBCode("T")]  ReconciliationTransaction,

        /// <summary>DB code 'B'</summary>
        [EnumDBCode("B")]  ReconciliationBalance,

        /// <summary>
        /// DB code 'H'
        /// Credit note reconciliation
        /// </summary>
        [EnumDBCode("H")]  CreditNoteReconciliationTransaction,

        /// <summary>
        /// DB code 'L'
        /// Balance of credit note reconciliation
        /// </summary>
        [EnumDBCode("L")]  CreditNoteReconciliationBalance,

        /// <summary>
        /// DB code 'K'
        /// Delete drug (Kill)
        /// </summary>
        [EnumDBCode("K")] DeleteDrug,

        /// <summary>
        /// DB code 'M'
        /// Make a new drug 
        /// </summary>
        [EnumDBCode("M")] AddDrug,

        /// <summary>
        /// DB code 'X'
        /// Delete an I or M ordered requisition
        /// </summary>
        [EnumDBCode("X")] DeletedIorMRequisition,
    }

    /// <summary>Represents a record in the WProduct table</summary>
    public class WOrderlogRow : BaseRow
    {
        public int WOrderLogID 
        {
            get { return FieldToInt(RawRow["WOrderLogID"]).Value; } 
        }

        /// <summary>
        /// DB string field [RevisionLevel] 
        /// (can't set as set by SetDefaults)
        /// </summary>
        public string RevisionLevel
        {
            get { return FieldToStr(RawRow["RevisionLevel"]);  } 
            internal set { RawRow["RevisionLevel"] = StrToField(value); }
        }

        public string OrderNumber
        {
            get { return FieldToStr(RawRow["OrderNum"]);  } 
            set { RawRow["OrderNum"] = StrToField(value); } 
        }

        public string NSVCode
        {
            get { return FieldToStr(RawRow["SisCode"]);  } 
            set { RawRow["SisCode"] = StrToField(value); } 
        }

        public decimal? ConversionFactor
        {
            get { return FieldStrToDecimal(RawRow["ConvFact"]);  } 
            set { RawRow["ConvFact"] = DecimalToFieldStr(value, WOrderlog.GetColumnInfo().ConversionFactorLength, true); } 
        }

        public string IssueUnits
        {
            get { return FieldToStr(RawRow["IssueUnits"]);  } 
            set { RawRow["IssueUnits"] = StrToField(value); } 
        }

        /// <summary>
        /// DB string field [DispId] 
        /// (can't set as set by SetDefaults)
        /// </summary>
        public string UserInitials
        {
            get { return FieldToStr(RawRow["DispId"]);  } 
            internal set { RawRow["DispId"] = StrToField(value); }
        }

        /// <summary>
        /// DB string field [Terminal] 
        /// (can't set as set by SetDefaults)
        /// </summary>
        public string Terminal
        {
            get { return FieldToStr(RawRow["Terminal"]);  } 
            internal set { RawRow["Terminal"] = StrToField(value); }
        }

        /// <summary>
        /// DB int field [DateOrd], and string field [TimeOrd] 
        /// </summary>
        public DateTime? DateTimeOrd
        {
            get 
            {
                DateTime? dateOrdered = FieldIntDateToDateTime(RawRow["DateOrd"], DateType.YYYYMMDD);
                TimeSpan? timeOrdered = FieldStrTimeToTimeSpan(RawRow["TimeOrd"]);

                if (dateOrdered.HasValue && timeOrdered.HasValue)
                    return dateOrdered.Value + timeOrdered.Value;
                else if (dateOrdered.HasValue)
                    return dateOrdered.Value;
                else
                    return null;
            }
            set 
            {
                RawRow["DateOrd"] = DateTimeToFieldIntDate(value, DBNull.Value, DateType.YYYYMMDD); 
                RawRow["TimeOrd"] = DateTimeToFieldStrTime(value, true); 
            } 
        }

        /// <summary>DB int field [DateRec], and string field [TimeRec]</summary>
        public DateTime? DateTimeRec
        {
            get 
            { 
                DateTime? dateReceived = FieldIntDateToDateTime(RawRow["DateRec"], DateType.YYYYMMDD);
                TimeSpan? timeReceived = FieldStrTimeToTimeSpan(RawRow["TimeRec"]);

                if (dateReceived.HasValue && timeReceived.HasValue)
                    return dateReceived.Value + timeReceived.Value;
                else if (dateReceived.HasValue)
                    return dateReceived.Value;  //  05Jul13 XN  Added conversion of just date 27252
                else 
                    return null;
            } 
            set 
            { 
                RawRow["DateRec"] = DateTimeToFieldIntDate(value, 0, DateType.YYYYMMDD); 
                RawRow["TimeRec"] = DateTimeToFieldStrTime(value, true);
            } 
        }

        /// <summary>DB string field [QtyOrd]</summary>
        public decimal? QuantityOrdered
        {
            get { return FieldStrToDecimal(RawRow["QtyOrd"]);  } 
            set { RawRow["QtyOrd"] = DecimalToFieldStr(value, WOrderlog.GetColumnInfo().QuantityOrderedLength, true); } 
        }

        /// <summary>DB string field [QtyRec]</summary>
        public decimal? QuantityReceived
        {
            get { return FieldStrToDecimal(RawRow["QtyRec"]);  } 
            set { RawRow["QtyRec"] = DecimalToFieldStr(value, WOrderlog.GetColumnInfo().QuantityReceivedLength, true); } 
        }

        /// <summary>DB string field [Cost]</summary>
        public decimal CostIncVat
        {
            get { return FieldStrToDecimal(RawRow["Cost"]).Value;  } 
            set { RawRow["Cost"] = DecimalToFieldStr(value, WOrderlog.GetColumnInfo().CostIncVatLength); } 
        }

        public decimal CostExVat
        {
            get { return FieldStrToDecimal(RawRow["CostExVat"]).Value;  } 
            set { RawRow["CostExVat"] = DecimalToFieldStr(value, WOrderlog.GetColumnInfo().CostExVatLength); } 
        }

        public decimal VatCost
        {
            get { return FieldStrToDecimal(RawRow["VatCost"]).Value;  } 
            set { RawRow["VatCost"] = DecimalToFieldStr(value, WOrderlog.GetColumnInfo().VatCostLength); } 
        }

        public int VatCode
        {
            get { return FieldToInt(RawRow["VatCode"]).Value;  } 
            set { RawRow["VatCode"] = IntToField(value); } 
        }

        public decimal VatRate
        {
            get { return FieldStrToDecimal(RawRow["VatRate"]).Value;  } 
            set { RawRow["VatRate"] = DecimalToFieldStr(value, WOrderlog.GetColumnInfo().VatRateLength); } 
        }

        /// <summary>
        /// Provides access to the raw kind
        /// 05Jul13 XN added 27252
        /// </summary>
        public string KindRaw
        {
            get { return FieldToStr(RawRow["Kind"]);  } 
        }

        public WOrderLogType Kind
        {
            get { return FieldToEnumByDBCode<WOrderLogType>(RawRow["Kind"]);  } 
            set { RawRow["Kind"] = EnumToFieldByDBCode(value); } 
        }

        /// <summary>DB string field [SupCode]</summary>
        public string SupplierCode
        {
            get { return FieldToStr(RawRow["SupCode"]);  } 
            set { RawRow["SupCode"] = StrToField(value); } 
        }

        /// <summary>DB int field [Site]</summary>
        public int SiteNumber
        {
            get { return FieldToInt(RawRow["Site"]).Value;  } 
            set { RawRow["Site"] = IntToField(value);       } 
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]).Value; } 
            set { RawRow["SiteID"] = IntToField(value);      } 
        }

        public string BatchNumber
        {
            get { return FieldToStr(RawRow["BatchNum"]);  } 
            set { RawRow["BatchNum"] = StrToField(value, false); } 
        }

        public DateTime? ExpiryDate
        {
            get { return FieldIntDateToDateTime(RawRow["ExpiryDate"], DateType.YYYYMMDD); } 
            set { RawRow["ExpiryDate"] = DateTimeToFieldIntDate(value, "", DateType.YYYYMMDD); } 
        }

        /// <summary>DB string field [InvNum]</summary>
        public string InvoiceNumber
        {
            get { return FieldToStr(RawRow["InvNum"]);  } 
            set { RawRow["InvNum"] = StrToField(value); } 
        }

        public decimal? StockLevel
        {
//            get { return FieldStrToDecimal(RawRow["StockLvl"]).Value;  } 05Jul13 XN  27252
            get { return FieldStrToDecimal(RawRow["StockLvl"]);  } 
            set { RawRow["StockLvl"] = DecimalToFieldStr(value, WOrderlog.GetColumnInfo().StockLevelLength, true); } 
        }

        public double? StockValue
        {
            get { return FieldToDouble(RawRow["StockValue"]);  } 
            set { RawRow["StockValue"] = DoubleToField(value); } 
        }

        /// <summary>
        /// DB int field [EntityID]
        /// (can't set as set by SetDefaults)
        /// </summary>
        public int EntityID
        {
            get { return FieldToInt(RawRow["EntityID"]).Value; } 
            internal set { RawRow["EntityID"] = IntToField(value); }
        }

        public DateTime? DateOrdered
        {
            get { return FieldToDateTime(RawRow["DateOrdered"]);  } 
            set { RawRow["DateOrdered"] = DateTimeToField(value);       } 
        }

        public DateTime DateReceived
        {
            get { return FieldToDateTime(RawRow["DateReceived"]).Value; } 
            set { RawRow["DateReceived"] = DateTimeToField(value);      } 
        }

        public string ReasonCode
        {
            get { return FieldToStr(RawRow["ReasonCode"]); } 
            set { RawRow["ReasonCode"] = StrToField(value);      } 
        }

        /// <summary>
        /// Date and time the log entry was saved to the database
        /// </summary>
        public DateTime LogDateTime
        {
            get { return FieldToDateTime(RawRow["LogDateTime"]).Value; }
        }

        /// <summary>Property will ignore it, or return null if field not present in db</summary>
        public DateTime? DateInvoiced //02Nov10 AJK F0086901 Added
        {
            get { return FieldToDateTime(RawRow["DateInvoiced"]);  }
            set { RawRow["DateInvoiced"] = DateTimeToField(value); }
        }

        /// <summary>Property will ignore it, or return null if field not present in db</summary>
        public string DeliveryNoteReference //02Nov10 AJK F0054531 Added DeliveryNoteReference
        {
            get { return FieldToStr(RawRow["DeliveryNoteReference"]);  }
            set { RawRow["DeliveryNoteReference"] = StrToField(value); }
        }

        /// <summary>
        /// Returns the drug description for the products order with the ! replaced with space
        ///     WProduct.[Description]  as ProductDescription     
        /// 05Jul13 XN added 27252
        /// </summary>
        public string ProductDescription
        {
            get 
            { 
                string result = string.Empty;
                if (this.RawRow.Table.Columns.Contains("ProductDescription"))
                {
                    result = FieldToStr(this.RawRow["ProductDescription"], trimString: true, nullVal: string.Empty);  
                }

                return result.Replace('!', ' ');
            }
        }
    }

    /// <summary>Represents monthly totals calculated from records in the WOrderlog</summary>
    public class WOrderlogMonthlyTotals
    {
        /// <summary>Month and year the total applies to</summary>
        public DateTime MonthYear               { get; internal set; }

        /// <summary>QtyOrd total for the month</summary>
        public decimal? QuantityOrderedInPacks  { get; internal set; }

        /// <summary>QtyRec total for the month</summary>
        public decimal? QuantityReceivedInPacks { get; internal set; }
    }

    /// <summary>Provides column information about the WOrderlog table</summary>
    public class WOrderlogColumnInfo : BaseColumnInfo
    {
        public WOrderlogColumnInfo() : base("WOrderlog") { }

        public int ConversionFactorLength { get { return tableInfo.GetFieldLength("ConvFact"); } }
        public int UserInitialsLength     { get { return tableInfo.GetFieldLength("DispId");   } }
        public int TerminalLength         { get { return tableInfo.GetFieldLength("Terminal"); } }
        public int CostIncVatLength       { get { return tableInfo.GetFieldLength("Cost");     } }
        public int CostExVatLength        { get { return tableInfo.GetFieldLength("CostExVat");} }
        public int VatCostLength          { get { return tableInfo.GetFieldLength("VatCost");  } }
        public int VatRateLength          { get { return tableInfo.GetFieldLength("VatRate");  } }  
        public int InvoiceLength          { get { return tableInfo.GetFieldLength("InvNum");   } }  
        public int StockLevelLength       { get { return tableInfo.GetFieldLength("StockLvl"); } }  
        public int QuantityOrderedLength  { get { return tableInfo.GetFieldLength("QtyOrd");   } }  
        public int QuantityReceivedLength { get { return tableInfo.GetFieldLength("QtyRec");   } }  
        public int ReassonCodeLength      { get { return tableInfo.GetFieldLength("ReasonCode");   } }
        public int OrderNumberLength      { get { return tableInfo.GetFieldLength("OrderNum"); } }
        public int DeliveryNoteReferenceLength { get { return tableInfo.GetFieldLength("DeliveryNoteReference"); } } //02Nov10 AJK F0054531 Added DeliveryNoteReference
    }

    /// <summary>Represent the WOrderlog table</summary>
    // public class WOrderlog : BaseTable<WOrderlogRow, WOrderlogColumnInfo> 05Jul13 XN  27252
    public class WOrderlog : BaseTable2<WOrderlogRow, WOrderlogColumnInfo>
    {
        public WOrderlog() : base("WOrderlog") 
        {
            //this.writeToAudtiLog = false;  28Nov16 XN Knock on effects to change in BaseTable2.WriteToAudtiLog 147104
            this.WriteToAudtiLog = false;
            this.extraExcludedColumns.Add("LogDateTime");   // Prevent saving LogDateTime as should be done by db 23May12 XN 27038
        }

        /// <summary>
        /// Adds a new row, and sets default values.
        /// </summary>
        /// <returns>New row</returns>
        public override WOrderlogRow Add()
        {
            WOrderlogColumnInfo columnInfo = WOrderlog.GetColumnInfo();
            WOrderlogRow newRow = base.Add();

            // Set common defaults
            newRow.RevisionLevel            = "A1"; // Should be set to software version number.
            newRow.UserInitials             = SessionInfo.UserInitials.SafeSubstring(0, columnInfo.UserInitialsLength);
            newRow.Terminal                 = SessionInfo.Terminal.SafeSubstring(0, columnInfo.TerminalLength);
            newRow.EntityID                 = SessionInfo.EntityID;
            newRow.ReasonCode               = string.Empty;
            newRow.DateTimeOrd              = null;
            newRow.DateTimeRec              = null;
            newRow.QuantityOrdered          = null;
            newRow.QuantityReceived         = null;
            newRow.BatchNumber              = string.Empty;
            newRow.ExpiryDate               = null;
            newRow.InvoiceNumber            = string.Empty;
            newRow.StockLevel               = null;
            newRow.StockValue               = 0.0;
            newRow.DateInvoiced             = null; //02Nov10 AJK F0086901 Added
            newRow.DeliveryNoteReference    = string.Empty; 
            newRow.RawRow["ContractNumber"] = string.Empty; 
            newRow.RawRow["ContractPrice"]  = string.Empty; 
            newRow.RawRow["Contract"]       = false; 
            newRow.RawRow["Date3"]          = string.Empty; // Unused field
            newRow.RawRow["Time3"]          = string.Empty; // Unused field
            newRow.RawRow["Qty3"]           = string.Empty; // Unused field
            newRow.RawRow["Info"]           = string.Empty; // Unused field
            newRow.RawRow["LinkedNum"]      = string.Empty; // Unused field
            return newRow;
        }

        /// <summary>
        /// Returns the monthly qty ordered totals, from the order log
        /// Will only set the MonthYear, and QuantityOrderedInPacks values in WOrderlogMonthlyTotals
        /// The date is compared against db field [DateOrd]
        /// </summary>
        /// <param name="siteID">Site id</param>
        /// <param name="NSVCode">NSV code</param>
        /// <param name="fromDate">earliest date to retrieve log rows from</param>
        /// <param name="types">orderlog types</param>
        /// <returns>List of qty ordered for each month</returns>
        public static List<WOrderlogMonthlyTotals> GetMonthlyQuantityOrdered( int siteID, string NSVCode, DateTime fromDate, params WOrderLogType[] types)
        {
            List<WOrderlogMonthlyTotals> list       = new List<WOrderlogMonthlyTotals>();
            List<SqlParameter>           parameters = new List<SqlParameter>();
            WOrderlog                    orderlog   = new WOrderlog();

            // Setup the parameters
            parameters.Add(new SqlParameter("@CurrentSessionID",    SessionInfo.SessionID ));
            parameters.Add(new SqlParameter("@SiteID",              siteID                ));
            parameters.Add(new SqlParameter("@NSVCode",             NSVCode               ));
            parameters.Add(new SqlParameter("@fromDate",            fromDate              ));
            //orderlog.AddInputParam(parameters, "SiteID",   siteID);
            //orderlog.AddInputParam(parameters, "NSVCode",  NSVCode);
            //orderlog.AddInputParam(parameters, "fromDate", fromDate); 
            // 05Jul13 XN 27252 Moved to BaseTable2

            // Setup Kinds parameters
            //string typesStr = types.Select(t => EnumDBCodeAttribute.EnumToDBCode<WOrderLogType>(t)).ToCSVString(string.Empty);  18Aug14 XN 86624 Update to WHERE clause in summary view
            string typesStr = "'" + types.Select(t => EnumDBCodeAttribute.EnumToDBCode<WOrderLogType>(t)).ToCSVString("','") + "'";
            parameters.Add(new SqlParameter("@Kinds", typesStr));
            //StringBuilder typesStr = new StringBuilder();
            //foreach (WOrderLogType t in types)
            //    typesStr.Append(EnumDBCodeAttribute.EnumToDBCode<WOrderLogType>(t));
            //orderlog.AddInputParam(parameters, "Kinds", typesStr);
            // 05Jul13 XN 27252 Moved to BaseTable2

            // Load in the monthly totals
            orderlog.LoadBySP("pWOrderlogMonthlyQtyOrdBySiteIDNSVCodeFromAndKinds", parameters);

            // Create a WOrderlogMonthlyTotals for each monthly total.
            foreach(DataRow row in orderlog.Table.Rows)
            {
                WOrderlogMonthlyTotals monthlyTotals = new WOrderlogMonthlyTotals();
                
                monthlyTotals.MonthYear              = new DateTime(Convert.ToInt32(row["Year"]), Convert.ToInt32(row["Month"]), 1);
                monthlyTotals.QuantityOrderedInPacks = (row["QtyOrdTotal"] == DBNull.Value) ? null : (decimal?)Convert.ToDecimal(row["QtyOrdTotal"]);

                list.Add ( monthlyTotals );
            }

            return list;
        }

        /// <summary>
        /// Returns the monthly qty received totals, from the order log
        /// Will only set the MonthYear, and QuantityReceivedInPacks values in WOrderlogMonthlyTotals
        /// The date is compared against db field [DateRec]
        /// </summary>
        /// <param name="siteID">Site id</param>
        /// <param name="NSVCode">NSV code</param>
        /// <param name="fromDate">earliest date to retrieve log rows from</param>
        /// <param name="types">orderlog types</param>
        /// <returns>List of qty received for each month</returns>
        public static List<WOrderlogMonthlyTotals> GetMonthlyQuantityReceived( int siteID, string NSVCode, DateTime fromDate, params WOrderLogType[] types)
        {
            List<WOrderlogMonthlyTotals> list       = new List<WOrderlogMonthlyTotals>();
            List<SqlParameter>           parameters = new List<SqlParameter>();
            WOrderlog                    orderlog   = new WOrderlog();
 
            // Setup the parameters
            parameters.Add(new SqlParameter("@CurrentSessionID",    SessionInfo.SessionID ));
            parameters.Add(new SqlParameter("@SiteID",              siteID                ));
            parameters.Add(new SqlParameter("@NSVCode",             NSVCode               ));
            parameters.Add(new SqlParameter("@fromDate",            fromDate              ));
            //orderlog.AddInputParam(parameters, "SiteID",   siteID);
            //orderlog.AddInputParam(parameters, "NSVCode",  NSVCode);
            //orderlog.AddInputParam(parameters, "fromDate", fromDate);
            // 05Jul13 XN 27252 Moved to BaseTable2

            //string typesStr = types.Select(t => EnumDBCodeAttribute.EnumToDBCode<WOrderLogType>(t)).ToCSVString(string.Empty);  18Aug14 XN 86624 Update to WHERE clause in summary view
            string typesStr = "'" + types.Select(t => EnumDBCodeAttribute.EnumToDBCode<WOrderLogType>(t)).ToCSVString("','") + "'";
            parameters.Add(new SqlParameter("@Kinds", typesStr));
            //StringBuilder typesStr = new StringBuilder();
            //foreach (WOrderLogType t in types)
            //    typesStr.Append(EnumDBCodeAttribute.EnumToDBCode<WOrderLogType>(t));
            //orderlog.AddInputParam(parameters, "Kinds", typesStr);
            // 05Jul13 XN 27252 Moved to BaseTable2

            // Load in the monthly totals
            orderlog.LoadBySP("pWOrderlogMonthlyQtyRecBySiteIDNSVCodeFromAndKinds", parameters);

            // Create a WOrderlogMonthlyTotals for each monthly total.
            foreach(DataRow row in orderlog.Table.Rows)
            {
                WOrderlogMonthlyTotals monthlyTotals = new WOrderlogMonthlyTotals();
                
                monthlyTotals.MonthYear               = new DateTime(Convert.ToInt32(row["Year"]), Convert.ToInt32(row["Month"]), 1);
                monthlyTotals.QuantityReceivedInPacks = (row["QtyRecTotal"] == DBNull.Value) ? null : (decimal?)Convert.ToDecimal(row["QtyRecTotal"]);

                list.Add ( monthlyTotals );
            }

            return list;
        }

        /// <summary>
        /// Loads log items by criteria specified (limited to row count)
        /// Uses sp pWOrderlogbyCriteriaNEW (note sp does not return all orderlog rows)
        /// 05Jul13 XN added 27252
        /// </summary>
        /// <param name="criteria">Criteria specified</param>
        /// <param name="maxRowCount">Max number of rows to returns</param>
        public void LoadByCriteria(string criteria, int maxRowCount)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SessionID",   SessionInfo.SessionID ));
            parameters.Add(new SqlParameter("@SQLWhere",    criteria.ToString()   ));
            parameters.Add(new SqlParameter("@MaximumRows", maxRowCount           ));
            LoadBySP("pWOrderlogbyCriteriaNEW", parameters);
        }

        // <summary>
        // Override the base class as the default pWOrderlogInsert has incorrect field names    
        // </summary>
        // <param name="row">Row to insert</param>
        // 05Jul13 XN 27252 Moved to BaseTable2
        //protected override void InsertRow(DataRow row)
        //{
        //    StringBuilder parameters = new StringBuilder();
        //    DataColumnCollection columns = Table.Columns;
        //    AddInputParam(parameters, "RevisionLevel",  row["RevisionLevel"], GetTLDataType(columns["RevisionLevel"].DataType));   
        //    AddInputParam(parameters, "OrderNum",       row["OrderNum"],      GetTLDataType(columns["OrderNum"].DataType));       
        //    AddInputParam(parameters, "SisCode",        row["SisCode"],       GetTLDataType(columns["SisCode"].DataType));             
        //    AddInputParam(parameters, "ConvFact",       row["ConvFact"],      GetTLDataType(columns["ConvFact"].DataType));           
        //    AddInputParam(parameters, "IssueUnits",     row["IssueUnits"],    GetTLDataType(columns["IssueUnits"].DataType));       
        //    AddInputParam(parameters, "DispId",         row["DispId"],        GetTLDataType(columns["DispId"].DataType));               
        //    AddInputParam(parameters, "Terminal",       row["Terminal"],      GetTLDataType(columns["Terminal"].DataType));           
        //    AddInputParam(parameters, "DateOrd",        row["DateOrd"],       GetTLDataType(columns["DateOrd"].DataType));             
        //    AddInputParam(parameters, "TimeOrd",        row["TimeOrd"],       GetTLDataType(columns["TimeOrd"].DataType));             
        //    AddInputParam(parameters, "DateRec",        row["DateRec"],       GetTLDataType(columns["DateRec"].DataType));             
        //    AddInputParam(parameters, "TimeRec",        row["TimeRec"],       GetTLDataType(columns["TimeRec"].DataType));        
        //    AddInputParam(parameters, "QtyOrd",         row["QtyOrd"],        GetTLDataType(columns["QtyOrd"].DataType));               
        //    AddInputParam(parameters, "QtyRec",         row["QtyRec"],        GetTLDataType(columns["QtyRec"].DataType));               
        //    AddInputParam(parameters, "Cost",           row["Cost"],          GetTLDataType(columns["Cost"].DataType));                   
        //    AddInputParam(parameters, "CostExVat",      row["CostExVat"],     GetTLDataType(columns["CostExVat"].DataType));         
        //    AddInputParam(parameters, "VatCost",        row["VatCost"],       GetTLDataType(columns["VatCost"].DataType));             
        //    AddInputParam(parameters, "VatCode",        row["VatCode"],       GetTLDataType(columns["VatCode"].DataType));             
        //    AddInputParam(parameters, "VatRate",        row["VatRate"],       GetTLDataType(columns["VatRate"].DataType));             
        //    AddInputParam(parameters, "Kind",           row["Kind"],          GetTLDataType(columns["Kind"].DataType));                   
        //    AddInputParam(parameters, "SupCode",        row["SupCode"],       GetTLDataType(columns["SupCode"].DataType));             
        //    AddInputParam(parameters, "Site",           row["Site"],          GetTLDataType(columns["Site"].DataType));                   
        //    AddInputParam(parameters, "SiteID",         row["SiteID"],        GetTLDataType(columns["SiteID"].DataType));               
        //    AddInputParam(parameters, "BatchNum",       row["BatchNum"],      GetTLDataType(columns["BatchNum"].DataType));           
        //    AddInputParam(parameters, "ExpiryDate",     row["ExpiryDate"],    GetTLDataType(columns["ExpiryDate"].DataType));       
        //    AddInputParam(parameters, "InvNum",         row["InvNum"],        GetTLDataType(columns["InvNum"].DataType));               
        //    AddInputParam(parameters, "StockLvl",       row["StockLvl"],      GetTLDataType(columns["StockLvl"].DataType));           
        //    AddInputParam(parameters, "StockValue",     row["StockValue"],    GetTLDataType(columns["StockValue"].DataType));       
        //    AddInputParam(parameters, "EntityID",       row["EntityID"],      GetTLDataType(columns["EntityID"].DataType));           
        //    AddInputParam(parameters, "DateOrdered",    row["DateOrdered"],   GetTLDataType(columns["DateOrdered"].DataType));     
        //    AddInputParam(parameters, "DateReceived",   row["DateReceived"],  GetTLDataType(columns["DateReceived"].DataType));   
        //    AddInputParam(parameters, "ReasonCode",     row["ReasonCode"],    GetTLDataType(columns["ReasonCode"].DataType));   

        //     15Nov10 XN F0086901 Made DateInvoiced, and DeliveryNoteReference optional, as some DB versions don't support it
        //    AddInputParam(parameters, "DeliveryNoteReference", row["DeliveryNoteReference"], GetTLDataType(columns["DeliveryNoteReference"].DataType)); //02Nov10 AJK F0054531 Added DeliveryNoteReference
        //    AddInputParam(parameters, "DateInvoiced", row["DateInvoiced"], GetTLDataType(columns["DateInvoiced"].DataType)); //02Nov10 AJK F0086901 Added

        //     19Sept XN New fields have been added to pWorderlog 44321
        //    AddInputParam(parameters, "ContractNumber", row["ContractNumber"], GetTLDataType(columns["ContractNumber"].DataType));
        //    AddInputParam(parameters, "ContractPrice",  row["ContractPrice"],  GetTLDataType(columns["ContractPrice"].DataType));
        //    AddInputParam(parameters, "Contract",       row["Contract"],       GetTLDataType(columns["Contract"].DataType));

        //     Following fields are in WOrderLog but are not used.
        //    AddInputParam(parameters, "Date3",          string.Empty,         GetTLDataType(columns["Date3"].DataType));             
        //    AddInputParam(parameters, "Time3",          string.Empty,         GetTLDataType(columns["Time3"].DataType));        
        //    AddInputParam(parameters, "Qty3",           string.Empty,         GetTLDataType(columns["Qty3"].DataType));        
        //    AddInputParam(parameters, "Info",           string.Empty,         GetTLDataType(columns["Info"].DataType));        
        //    AddInputParam(parameters, "LinkedNum",      string.Empty,         GetTLDataType(columns["LinkedNum"].DataType));  
      
        //    int pk = dblayer.ExecuteInsertSP ( SessionInfo.SessionID, TableName, parameters.ToString() );

        //    DataColumn pkcolumn = Table.Columns[PKColumnName];
        //    pkcolumn.ReadOnly = false;
        //    row[PKColumnName] = pk;
        //    pkcolumn.ReadOnly = true;
        //}
    }
}
