//===========================================================================
//
//							       WReconcil.cs
//
//  Provides access to WReconcil table.
//
//  Classes are derived from BaseOrderRow
//
//  WReconcil table holds information about individual completed reconciliation lines.
//
//  SP for this object should return all fields from the WReconcil table, and a 
//  links in the following extra fields
//      WSupplier.Name         as supname
//      WSupplier.FullName     as supfullname    
//      WSupplier.SupplierType as WSupplier_SupplierType
//
//  Only supports reading, inserting and updating.
//
//	Modification History:
//	01Jun09 XN  Written
//  21Dec09 XN  Added support for updating rows, and load functions LoadByID,
//              LoadOpenBySiteOrderNumberAndNSVCode, and 
//              LoadOpenByLoadingNumberAndPrimaryBarcode (F0042698)
//  30Dec09 XN  Got all constructors to use pWReconcilUpdateAll sp
//  30May12 TH  Added DLO Fields
//  04Apr13 XN  Added PSO Fields to InsertRow
//  19May14 XN  Added LoadBySiteIDNSVCodeAndState 89162
//  19Aug14 XN  Now using BaseTable2
//  05Nov14 XN  Added LoadBySiteIDSupCodeAndState 103549
//  16Mar15 XN  LoadBySiteIDSupCodeAndState got it to load from WReconcil rather than WOrder 113851
//  30Jul15 XN  Added supcode to LoadBySiteIDNSVCodeAndState (renamed to LoadBySiteIDNSVCodeSupCodeAndState) 124545
//  22Jul16 XN  Added EDIProductIdentifier 126634 
//  25Jul16 XN  126634 Added EDIProductIdentifier
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Data;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Represents a record in the WReconcil table</summary>
    public class WReconcilRow : BaseOrderRow
    {
        public int WReconcilID
        { 
            get { return FieldToInt(RawRow["WReconcilID"]).Value; }
        }

        /// <summary>
        /// DB string field [Cost]
        /// Order line cost (excluding vat) per pack (in pence).
        /// Can be null if cost has not been calculated yet.
        /// </summary>
        public decimal? CostExVatPerPack
        { 
            get { return FieldStrToDecimal(RawRow["Cost"]);  }
            set { RawRow["Cost"] = DecimalToFieldStr(value, WReconcil.GetColumnInfo().CostExVatPerPackLength ); }
        }

        /// <summary>
        /// DB string field [ReconcileDate]
        /// Date the actual reconcliation has been performed (null if not done yet)
        /// </summary>
        public DateTime? ReconcileDate
        {
            get { return FieldStrDateToDateTime(RawRow["ReconcileDate"], DateType.DDMMYYYY);        }
            set { RawRow["ReconcileDate"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); }
        }

        public decimal? VATAmount
        {
            get { return FieldStrToDecimal(RawRow["VATAmount"]);  }
            set { RawRow["VATAmount"] = DecimalToFieldStr(value, WReconcil.GetColumnInfo().VATAmountLength, true); }
        }

        public decimal? ConversionFactor
        {
            get { return FieldStrToDecimal(RawRow["ConvFact"]);                                                          }
            set { RawRow["ConvFact"] = DecimalToFieldStr(value, WReconcil.GetColumnInfo().ConversionFactorLength, true); }
        }

        /// <summary>
        /// Set when EDI order is sent out
        /// Set to either EDIBarcode for the supplier profile, the EDILinkCode, primary barcode, or NSVCode
        /// 22Jul16 XN added 126634  
        /// </summary>
        public string EDIProductIdentifier
        {
            get { return FieldToStr(RawRow["EDIProductIdentifier"], trimString: true, nullVal: string.Empty); }
            set { RawRow["EDIProductIdentifier"] = StrToField(value, emptyStrAsNullVal: false);               }
        }
    }
    
    /// <summary>Provides column information about the WReconcil table</summary>
    public class WReconcilColumnInfo : BaseOrderColumnInfo
    {
        public WReconcilColumnInfo() : base("WReconcil") { }

        public int CostExVatPerPackLength  { get { return tableInfo.GetFieldLength("Cost");        } }
    }

    /// <summary>Represent the WReconcil table</summary>
    //public class WReconcil : BaseOrder<WReconcilRow, WReconcilColumnInfo> 19Aug14 XN now using BaseTable2
    public class WReconcil : BaseTable2<WReconcilRow, WReconcilColumnInfo>
    {
        public WReconcil() : base("WReconcil") { }

        /// <summary>
        /// Add new row, will default the following db columns
        ///     RevisionLevel = ''
        /// </summary>
        /// <returns>new reconcil row</returns>
        public override WReconcilRow Add()
        {
            WReconcilRow row = base.Add();
            row.RawRow["RevisionLevel"] = "A4";
            row.CreatedUser             = SessionInfo.UserInitials.SafeSubstring(0, WReconcil.GetColumnInfo().CreatedUserLength);
            row.InDispute               = false;
            row.InDisputeUser           = string.Empty;
            row.CodingSlipDate          = string.Empty;
            row.ReconcileDate           = null;
            row.InvoiceDate             = null;
            row.InvoiceNumber           = string.Empty;
            return row;
        }

        /// <summary>Get the reconcil by Id</summary>
        /// <param name="WReconcilID">Reconcil record ID</param>
        public void LoadByID(int WReconcilID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("WReconcilID",       WReconcilID);
            LoadBySP("pWReconcil", parameters);
        }

        /// <summary>
        /// Returns all the reconcil for a site, or nsv code, limited to a date.
        /// The sp returns extra NOrddate, NRecdate, Ncodingslipdate, and Ncodingslipdate, 
        /// fields but these are not exposed by the WReconcilRow oject as they are a legacy 
        /// issue and only used by the stores drug info (F4) screen
        /// </summary>
        /// <param name="siteID">ID of the site</param>
        /// <param name="NSVCode">nsv code</param>
        /// <param name="from">returns all orders from this date (set to null to return all)</param>
        public void LoadBySiteIDNSVCodeAndFromDate (int siteID, string NSVCode, DateTime? from)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteID",            siteID);
            parameters.Add("NSVCode",           NSVCode);
            parameters.Add("FromDate",          from ?? DateTimeExtensions.MinDBValue);
            LoadBySP("pWReconcilBySiteIDNSVCodeAndFromDate", parameters);
        }

        /// <summary>
        /// Used for the robot loading interface.
        /// Loads the reconcil records associated with an order connected to a loading for a specific drug primary barcode
        /// </summary>
        /// <param name="siteID">Order site ID</param>
        /// <param name="loadingNumber">robot loading number</param>
        /// <param name="barcode">Drug primary barcode</param>
        public void LoadOpenByLoadingNumberAndPrimaryBarcode(int siteID, int loadingNumber, string primaryBarocde)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteID",            siteID);
            parameters.Add("LoadingNumber",     loadingNumber);
            parameters.Add("Barcode",           primaryBarocde);
            LoadBySP("pWReconcilOpenBySiteLoadingNumberAndPrimaryBarcode", parameters);
        }

        /// <summary>Loads the lines, by site, supcode, and state 05nov14 XN 103549</summary>
        public void LoadBySiteIDSupCodeAndState(int siteID, string supCode, OrderStatusType[] status)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteID",            siteID);   
            parameters.Add("SupCode",           supCode);
            parameters.Add("States",            "'" + status.Select(s => EnumDBCodeAttribute.EnumToDBCode(s)).ToCSVString("','") + "'");
            LoadBySP( "pWReconcilBySiteIDSupCodeAndState", parameters );
        }

        /// <summary>Loads the order lines, by site, NSVCode, and state 19May14 XN 89162</summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="NSVCode">NSV code</param>
        /// <param name="supCode">Supplier code 30Jul15 XN Added 124545</param>
        /// <param name="status">Order status type of interest</param>
        public void LoadBySiteIDNSVCodeSupCodeAndState(int siteID, string NSVCode, string supCode, OrderStatusType[] status)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteID",            siteID);   
            parameters.Add("NSVCode",           NSVCode);
            parameters.Add("SupCode",           supCode);
            parameters.Add("States",            "'" + status.Select(s => EnumDBCodeAttribute.EnumToDBCode(s)).ToCSVString("','") + "'");
            LoadBySP( "pWReconcilBySiteIDNSVCodeSupCodeAndState", parameters );
        }

        ///// <summary>
        ///// Inserts row into the table
        ///// Overridden to patch up problems with sp be out of sync with db
        ///// </summary>
        ///// <param name="row"></param>
        //protected override void InsertRow(DataRow row)
        //{
        //    DataColumnCollection columns = Table.Columns;

        //    StringBuilder parameters = new StringBuilder();
        //    AddInputParam(parameters, "LocationID_Site", row["SiteID"],  GetTLDataType(columns["SiteID"].DataType));
        //    AddInputParam(parameters, "Code", row["Code"],  GetTLDataType(columns["Code"].DataType));
        //    AddInputParam(parameters, "convfact", row["ConvFact"],  GetTLDataType(columns["ConvFact"].DataType));
        //    AddInputParam(parameters, "cost", row["Cost"],  GetTLDataType(columns["Cost"].DataType));
        //    AddInputParam(parameters, "CreatedUser", row["CreatedUser"],  GetTLDataType(columns["CreatedUser"].DataType));
        //    AddInputParam(parameters, "custordno", row["CustOrdNo"],  GetTLDataType(columns["CustOrdNo"].DataType));
        //    AddInputParam(parameters, "description", row["Description"],  GetTLDataType(columns["Description"].DataType));
        //    AddInputParam(parameters, "Indispute", row["InDispute"],  GetTLDataType(columns["InDispute"].DataType));
        //    AddInputParam(parameters, "IndisputeUser", row["InDisputeUser"],  GetTLDataType(columns["InDisputeUser"].DataType));
        //    AddInputParam(parameters, "internalmethod", row["InternalMethod"],  GetTLDataType(columns["InternalMethod"].DataType));
        //    AddInputParam(parameters, "internalsiteno", row["InternalSiteNo"],  GetTLDataType(columns["InternalSiteNo"].DataType));
        //    AddInputParam(parameters, "invnum", row["InvNum"],  GetTLDataType(columns["InvNum"].DataType));
        //    AddInputParam(parameters, "IssueUnits", row["IssueUnits"],  GetTLDataType(columns["IssueUnits"].DataType));
        //    AddInputParam(parameters, "loccode", row["Loccode"],  GetTLDataType(columns["Loccode"].DataType));
        //    AddInputParam(parameters, "num", row["Num"],  GetTLDataType(columns["Num"].DataType));
        //    AddInputParam(parameters, "numprefix", row["NumPrefix"],  GetTLDataType(columns["NumPrefix"].DataType));
        //    AddInputParam(parameters, "orddate", row["OrdDate"],  GetTLDataType(columns["OrdDate"].DataType));
        //    AddInputParam(parameters, "ordtime", row["OrdTime"],  GetTLDataType(columns["OrdTime"].DataType));
        //    AddInputParam(parameters, "outstanding", row["Outstanding"],  GetTLDataType(columns["Outstanding"].DataType));
        //    AddInputParam(parameters, "paydate", row["PayDate"],  GetTLDataType(columns["PayDate"].DataType));
        //    AddInputParam(parameters, "pflag", row["PFlag"],  GetTLDataType(columns["PFlag"].DataType));
        //    AddInputParam(parameters, "pickno", row["PickNo"],  GetTLDataType(columns["PickNo"].DataType));
        //    AddInputParam(parameters, "qtyordered", row["QtyOrdered"],  GetTLDataType(columns["QtyOrdered"].DataType));
        //    AddInputParam(parameters, "recdate", row["RecDate"],  GetTLDataType(columns["RecDate"].DataType));
        //    AddInputParam(parameters, "received", row["Received"],  GetTLDataType(columns["Received"].DataType));
        //    AddInputParam(parameters, "Reconciledate", row["ReconcileDate"],  GetTLDataType(columns["ReconcileDate"].DataType));
        //    AddInputParam(parameters, "rectime", row["RecTime"],  GetTLDataType(columns["RecTime"].DataType));
        //    AddInputParam(parameters, "revisionlevel", row["RevisionLevel"],  GetTLDataType(columns["RevisionLevel"].DataType));
        //    AddInputParam(parameters, "ShelfPrinted", row["ShelfPrinted"],  GetTLDataType(columns["ShelfPrinted"].DataType));
        //    AddInputParam(parameters, "Status", row["Status"],  GetTLDataType(columns["Status"].DataType));
        //    AddInputParam(parameters, "Stocked", row["Stocked"],  GetTLDataType(columns["Stocked"].DataType));
        //    AddInputParam(parameters, "supcode", row["SupCode"],  GetTLDataType(columns["SupCode"].DataType));
        //    AddInputParam(parameters, "suppliertype", row["SupplierType"],  GetTLDataType(columns["SupplierType"].DataType));
        //    AddInputParam(parameters, "tofollow", row["ToFollow"],  GetTLDataType(columns["ToFollow"].DataType));
        //    AddInputParam(parameters, "urgency", row["Urgency"],  GetTLDataType(columns["Urgency"].DataType));
        //    AddInputParam(parameters, "VATAmount", row["VATamount"],  GetTLDataType(columns["VATamount"].DataType));
        //    AddInputParam(parameters, "VATInclusive", row["VatInclusive"],  GetTLDataType(columns["VatInclusive"].DataType));
        //    AddInputParam(parameters, "VATRateCode", row["VatRateCode"],  GetTLDataType(columns["VatRateCode"].DataType));
        //    AddInputParam(parameters, "VATRatePCT", row["VatRatePct"],  GetTLDataType(columns["VatRatePct"].DataType));
        //    AddInputParam(parameters, "CodingSlipDate", row["CodingSlipDate"],  GetTLDataType(columns["CodingSlipDate"].DataType));
        //    AddInputParam(parameters, "DeliveryNoteReference", row["DeliveryNoteReference"], GetTLDataType(columns["DeliveryNoteReference"].DataType));
        //    AddInputParam(parameters, "DLO", row["DLO"], GetTLDataType(columns["DLO"].DataType));
        //    AddInputParam(parameters, "DLOWard", row["DLOWard"], GetTLDataType(columns["DLOWard"].DataType));
        //    AddInputParam(parameters, "PSORequestID", row["PSORequestID"], GetTLDataType(columns["PSORequestID"].DataType));    // 04Apr13 XN Added PSO fields 

        //    int pk = dblayer.ExecuteInsertSP (SessionInfo.SessionID, TableName, parameters.ToString() );

        //    DataColumn pkcolumn = Table.Columns[PKColumnName];
        //    pkcolumn.ReadOnly = false;
        //    row[PKColumnName] = pk;
        //    pkcolumn.ReadOnly = true;
        //}
    }
}
