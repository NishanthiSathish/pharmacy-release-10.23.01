//===========================================================================
//
//							       WOrder.cs
//
//  Provides access to WOrder table
//
//  Classes are derived from BaseOrderRow
//
//  WOrder table holds information about individual order lines, from a 
//  pharmacy to drug suppliers, or other pharmacies
//
//  SP for this object should return all fields from the WOrder table, and a 
//  link to the following extra fields
//      WSupplier.Name         as supname
//      WSupplier.FullName     as supfullname    
//      WSupplier.SupplierType as WSupplier_SupplierType
//      WProduct.Description   as Description
//
//  Only supports reading, and updating
//
//	Modification History:
//	15Apr09 XN  Written
//  21Dec09 XN  Added support for updating a WOrder, and load functions
//              LoadByOrderNumberSiteIDAndNSVCode and 
//              LoadBySiteLoadingNumberAndPrimaryBarcode (F0042698)
//  18Jan10 XN  Added returning rows ProductDescription and load functions
//              LoadByAvailableForRobotLoading and 
//              LoadBySiteAndOrderNumber (F0042698)
//  08Feb10 XN  Added handling of deleted orders (F0042698)
//  29Apr10 XN  Updates from BaseOrderRow, and WProduct, and extended to replace 
//              business layer class OrderLine
//  19May14 XN  Added method LoadBySiteIDNSVCodeAndState (89162)
//  19Aug14 XN  Now using BaseTable2
//  05Nov14 XN  Added LoadBySiteIDSupCodeAndState 103549
//  30Jul15 XN  Added supcode to LoadBySiteIDNSVCodeAndState (renamed to LoadBySiteIDNSVCodeSupCodeAndState) 124545
//  25Jul16 XN  126634 Added EDIProductIdentifier
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Represents a record in the WOrder table</summary>
    public class WOrderRow : BaseOrderRow
    {
        public int WOrderID 
        { 
            get { return FieldToInt(RawRow["WOrderID"]).Value; }
        }

        /// <summary>
        /// DB string field [Cost]
        /// Order line cost (excluding vat) per pack (in pence).
        /// Can be null if cost has not been calculated yet.
        /// </summary>
        public decimal? CostExVatPerPack
        { 
            get { return FieldStrToDecimal(RawRow["Cost"]);  }
            set { RawRow["Cost"] = DecimalToFieldStr(value, WOrder.GetColumnInfo().CostExVatPerPackLength ); }
        }

        public decimal? VATAmount
        {
            get { return FieldStrToDecimal(RawRow["VATAmount"]);  }
            set { RawRow["VATAmount"] = DecimalToFieldStr(value, WOrder.GetColumnInfo().VATAmountLength, true); }
        }

        public decimal? ConversionFactor
        {
            get { return FieldStrToDecimal(RawRow["ConvFact"]);                                                          }
            set { RawRow["ConvFact"] = DecimalToFieldStr(value, WReconcil.GetColumnInfo().ConversionFactorLength, true); }
        }

        /// <summary>Stores or label description for the products order with the ! replaced with space</summary>
        public string ProductDescription
        {
            get { return FieldToStr(RawRow["ProductDescription"], trimString: true, nullVal: string.Empty).Replace('!', ' ');  }
        }

        /// <summary>
        /// Set when EDI order is sent out
        /// Set to either EDIBarcode for the supplier profile, the EDILinkCode, primary barcode, or NSVCode
        /// 22Jul16 XN added 126634  
        /// </summary>
        public string EDIProductIdentifier
        {
            get { return FieldToStr(RawRow["EDIProductIdentifier"], trimString: true, nullVal: string.Empty ); }
            set { RawRow["EDIProductIdentifier"] = StrToField(value, emptyStrAsNullVal: false);                }
        }

        /// <summary>
        /// Returns the true received amount in packs.
        /// As db Received is often incorrect.
        /// This is calculated from Quantity Ordered - Outstanding
        /// </summary>
        /// <returns>True recevied amount (null if qty order or outstanding is null)</returns>
        public decimal? CalculateReceivedInPacks()
        {
            if (QuantityOrderedInPacks.HasValue && OutstandingInPacks.HasValue)
                return Math.Max(QuantityOrderedInPacks.Value - OutstandingInPacks.Value, 0m);
            else
                return null;
        }

        /// <summary>
        /// Returns if the order is still ready to receive items
        /// Won't check if order has outstanding items
        /// </summary>
        /// <returns></returns>
        public bool CanReceive()
        {
            return (this.Status == OrderStatusType.WaitingToReceive);
        }

        /// <summary>
        /// Returns if the order is still ready to receive items, and there are enough outstanding item
        /// </summary>
        /// <returns>If can receive specified number of itmes</returns>
        public bool CanReceive(int count)
        {
            return (this.Status == OrderStatusType.WaitingToReceive) && (this.OutstandingInPacks >= count);
        }
    }
    
    /// <summary>Provides column information about the WOrder table</summary>
    public class WOrderColumnInfo : BaseOrderColumnInfo
    {
        public WOrderColumnInfo() : base("WOrder") { }

        public int CostExVatPerPackLength  { get { return tableInfo.GetFieldLength("Cost"); } }
    }

    /// <summary>Represent the WOrder table</summary>
    //public class WOrder : BaseOrder<WOrderRow, WOrderColumnInfo>  19Aug14 XN now using BaseTable2
    public class WOrder : BaseTable2<WOrderRow, WOrderColumnInfo>
    {
        public WOrder() : base("WOrder") { }

        /// <summary>
        /// Returns all the orders for a site, or nsv code, limited to a date.
        /// The sp returns extra NOrddate, and NRecdate, fields but these are not
        /// exposed by the WOrderRow oject as they are a legacy issue and only used 
        /// by the stores drug info (F4) screen
        /// </summary>
        /// <param name="siteID">ID of the site</param>
        /// <param name="NSVCode">nsv code</param>
        /// <param name="from">returns all orders from this date (set to null to return all)</param>
        public void LoadBySiteIDNSVCodeAndFromDate (int siteID, string NSVCode, DateTime? from)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("SiteID",           siteID);
            parameters.Add("NSVCode",          NSVCode);
            parameters.Add("FromDate",         from ?? DateTimeExtensions.MinDBValue);
            LoadBySP("pWOrderBySiteIDNSVCodeAndFromDate", parameters);
        }

        /// <summary>
        /// Loads the order lines, by site, order number, and NSVCode.
        /// </summary>
        /// <param name="NSVCode">order line NSV code</param>
        /// <param name="siteID">Order site ID</param>
        /// <param name="orderNumber">Order number</param>
        public void LoadByOrderNumberSiteIDAndNSVCode(string NSVCode, int siteID, int orderNumber)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("NSVCode",           NSVCode);
            parameters.Add("SiteID",            siteID);   
            parameters.Add("OrderNumber",       orderNumber);
            LoadBySP( "pWOrderByOrderNumberSiteAndNSVCode", parameters );
        }

        /// <summary>
        /// Used for the robot loading interface.
        /// Loads the order records associated with an order connected to a loading for a specific drug primary barcode
        /// </summary>
        /// <param name="siteID">Site Id</param>
        /// <param name="loadingNumber">robot loading number</param>
        /// <param name="barcode">Drug primary barcode</param>
        public void LoadBySiteLoadingNumberAndPrimaryBarcode(int siteID, int loadingNumber, string barcode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteID",            siteID);
            parameters.Add("LoadingNumber",     loadingNumber);
            parameters.Add("Barcode",           barcode);
            LoadBySP( "pWOrderBySiteLoadingNumberAndPrimaryBarcode", parameters );
        }

        /// <summary>
        /// Get all the order numbers that are avaiable for robot loading
        /// Will get orders that still have outstanding items and are waiting to 
        /// receive (Status 3) that are for the robot location, and don’t existing on an existing (active) order 
        /// </summary>
        /// <param name="siteID">robot site</param>
        /// <param name="robotLocation">Location of the robot</param>
        public void LoadByAvailableForRobotLoadingAndFromDate(int siteID, string robotLocation, DateTime fromDate)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteID",            siteID);
            parameters.Add("RobotLocation",     robotLocation);
            parameters.Add("fromDate",          fromDate);
            LoadBySP( "pWOrderByAvailableForRobotLoading", parameters );
        }

        /// <summary>Load order by order number</summary>
        /// <param name="siteID">robot site</param>
        /// <param name="orderNumber">Order number</param>
        /// <param name="includeDeleted">If deleted lines are to be loaded</param>
        public void LoadBySiteAndOrderNumber(int siteID, int orderNumber, bool includeDeleted)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteID",            siteID);
            parameters.Add("OrderNumber",       orderNumber);
            parameters.Add("IncludeDeleted",    includeDeleted);
            LoadBySP( "pWOrderBySiteAndOrderNumber", parameters );
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
            LoadBySP( "pWOrderBySiteIDNSVCodeSupCodeAndState", parameters );
        }

        /// <summary>Loads the order lines, by site, supcode, and state 05nov14 XN 103549</summary>
        public void LoadBySiteIDSupCodeAndState(int siteID, string supCode, OrderStatusType[] status)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteID",            siteID);   
            parameters.Add("SupCode",           supCode);
            parameters.Add("States",            "'" + status.Select(s => EnumDBCodeAttribute.EnumToDBCode(s)).ToCSVString("','") + "'");
            LoadBySP( "pWOrderBySiteIDSupCodeAndState", parameters );
        }
    }
}
