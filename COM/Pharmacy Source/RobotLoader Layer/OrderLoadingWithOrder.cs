//===========================================================================
//
//					   OrderLoadingWithOrderRow.cs
//
//  Provides access to a combined view of order loading, order loading details, 
//  Wsupplier, and WOrder tables.
//
//  Any sp for loading methods added to this object should include the following
//  columns
//      OrderLoadingID          - OrderLoading
//      LoadingNumber           - OrderLoading
//      CreatedUser_Name        - Entity
//      CreatedDateTime         - OrderLoading
//      UpdatedUser_Name        - Entity
//      UpdatedDateTime         - OrderLoading
//      Status                  - OrderLoading
//      OrderLoadingDetailID    - OrderLoadingDetails
//      WOrderNum               - OrderLoadingDetails
//      supname                 - WSupplier.Name
//      Outstanding             - Sum(WOrder.Outstanding)
//      QtyOrdered              - Sum(WOrder.QtyOrdered)
//
//  Only supports reading
//
//	Modification History:
//	18Jan10 XN Written (F0074142)
//  30Jan10 XN Added Recevied field, and removed active only flag from 
//             LoadBySiteLocationStateAndFromDate
//  08Feb10 XN  Added handling of deleted orders (F0042698)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.robotloading
{
    /// <summary>Represents a combined view of an order linked to an order loading table</summary> 
    public class OrderLoadingWithOrderRow : BaseRow
    {
        /// <summary>Comes from OrderLoading.OrderLoadingID</summary>
        public int OrderLoadingID
        {
            get { return FieldToInt(RawRow["OrderLoadingID"]).Value; }
        }

        /// <summary>Comes from OrderLoadingDetail.OrderLoadingDetailID</summary>
        public int OrderLoadingDetailID 
        { 
            get { return FieldToInt(RawRow["OrderLoadingDetailID"]).Value; }
        }

        /// <summary>Comes from OrderLoading.LoadingNumber</summary>
        public int LoadingNumber
        {
            get { return FieldToInt(RawRow["LoadingNumber"]).Value; }
        }

        /// <summary>Comes from OrderLoading.WOrderNum</summary>
        public int WOrderNum
        {
            get { return FieldToInt(RawRow["WOrderNum"]).Value; }
        }

        /// <summary>Comes from WSupplier.Code</summary>
        public string SupplierCode
        {
            get { return FieldToStr(RawRow["supcode"]); }
        }

        /// <summary>Comes from WSupplier.FullName</summary>
        public string SupplierFullName
        {
            get { return FieldToStr(RawRow["supfullname"], false, string.Empty); }
        }

        /// <summary>Comes from OrderLoading.Status</summary>
        public OrderLoadingStatus Status
        {
            get { return FieldIntToEnum<OrderLoadingStatus>(RawRow["Status"]).Value; }
        }

        /// <summary>Comes from OrderLoading.CreatedUser_Name</summary>
        public string CreatedUser_Name 
        { 
            get { return FieldToStr(RawRow["CreatedUser_Name"], true) ?? string.Empty; }
        }

        /// <summary>Comes from OrderLoading.CreatedDateTime</summary>
        public DateTime CreatedDateTime 
        { 
            get { return FieldToDateTime(RawRow["CreatedDateTime"]).Value; }
        }

        /// <summary>Comes from OrderLoading.UpdatedUser_Name (can be null)</summary>
        public string UpdatedUser_Name 
        { 
            get { return FieldToStr(RawRow["UpdatedUser_Name"], true) ?? string.Empty; }
        }

        /// <summary>Comes from OrderLoading.UpdatedDateTime</summary>
        public DateTime? UpdatedDateTime 
        { 
            get { return FieldToDateTime(RawRow["UpdatedDateTime"]); }
        }

        /// <summary>total number of received robot item's on order (true recevied amount)</summary>
        public decimal? CalculatedReceivedInPacks()
        {
            if (OutstandingInPacks.HasValue && QuantityOrderedInPacks.HasValue)
                return Math.Max(QuantityOrderedInPacks.Value - OutstandingInPacks.Value, 0m);
            else
                return null;                        
        }

        /// <summary>total number of outstanding robot item's on order.</summary>
        public decimal? OutstandingInPacks
        {
            get { return FieldToDecimal(RawRow["Outstanding"]); }
        }

        /// <summary>total number of robot item's on order</summary>
        public decimal? QuantityOrderedInPacks
        {
            get { return FieldToDecimal(RawRow["QtyOrdered"]); }
        }
    }
    
    /// <summary>Represents a combined view of an order linked to an order loading table</summary> 
    public class OrderLoadingWithOrder : BaseTable<OrderLoadingWithOrderRow, BaseColumnInfo>
    {
        public OrderLoadingWithOrder() : base("", "") { }

        /// <summary>
        /// Loads the data for all non deleted orders, by site, robot location, and from a specific date, order by status, and loading number desc
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="robotLocation">Robot location</param>
        /// <param name="fromDate">from a specific date</param>
        public void LoadByActiveOrderSiteLocationAndFromDate(int siteID, string robotLocation, DateTime fromDate)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "SiteID",        siteID);
            AddInputParam(parameters, "RobotLocation", robotLocation);
            AddInputParam(parameters, "fromDate",      fromDate);
            LoadRecordSetStream("pOrderLoadingByActiveOrderSiteLocationAndFromDate", parameters);
        }

        /// <summary>
        /// Loads the data for all deleted orders, by site, robot location, and from a specific date, order by status, and loading number desc
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="robotLocation">Robot location</param>
        /// <param name="fromDate">from a specific date</param>
        public void LoadByDeletedOrderSiteLocationAndFromDate(int siteID, string robotLocation, DateTime fromDate)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "SiteID",        siteID);
            AddInputParam(parameters, "RobotLocation", robotLocation);
            AddInputParam(parameters, "fromDate",      fromDate);
            LoadRecordSetStream("pOrderLoadingByDeletedOrderSiteLocationAndFromDate", parameters);
        }
    }
}
