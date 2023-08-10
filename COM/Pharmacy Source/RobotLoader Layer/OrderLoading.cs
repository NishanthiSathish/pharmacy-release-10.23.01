//===========================================================================
//
//							       OrderLoading.cs
//
//  Provides access to OrderLoading table.
//
//  OrderLoading table holds information about orders linked to a robot loading number.
//  The link comes from the OrderLoadingDetail table, but OrderLoading contains extra
//  helper methods to read this table with out getting the rows directly.
//
//  Only supports reading, and inserting
//
//	Modification History:
//	21Dec09 XN Written (F0074142)
//===========================================================================
using System;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.robotloading
{
    // Order loading status information
    public enum OrderLoadingStatus
    {
        Active    = 1,
        Completed = 2,
    };

    /// <summary>Represents a row in the order loading table</summary>
    public class OrderLoadingRow : BaseRow
    {
        public int OrderLoadingID 
        { 
            get { return FieldToInt(RawRow["OrderLoadingID"]).Value; }
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]).Value; }
            set { RawRow["SiteID"] = IntToField(value);      }
        }

        public int LoadingNumber 
        { 
            get { return FieldToInt(RawRow["LoadingNumber"]).Value; }
            set { RawRow["LoadingNumber"] = IntToField(value);      }
        }

        public OrderLoadingStatus Status
        {
            get { return FieldIntToEnum<OrderLoadingStatus>(RawRow["Status"]).Value; }
            set { RawRow["Status"] = EnumToFieldInt<OrderLoadingStatus>(value);      }
        }

        public int CreatedUser_EntityID 
        { 
            get { return FieldToInt(RawRow["CreatedUser_EntityID"]).Value; }
            set { RawRow["CreatedUser_EntityID"] = IntToField(value);      }
        }

        public DateTime CreatedDateTime 
        { 
            get { return FieldToDateTime(RawRow["CreatedDateTime"]).Value; }
            set { RawRow["CreatedDateTime"] = DateTimeToField(value);      }
        }

        public int UpdatedUser_EntityID 
        { 
            get { return FieldToInt(RawRow["UpdatedUser_EntityID"]).Value; }
            set { RawRow["UpdatedUser_EntityID"] = IntToField(value);      }
        }

        public DateTime UpdatedDateTime 
        { 
            get { return FieldToDateTime(RawRow["UpdatedDateTime"]).Value; }
            set { RawRow["UpdatedDateTime"] = DateTimeToField(value);      }
        }

        /// <summary>Return orders associated with this loading and it's the specified barcode</summary>
        /// <param name="primaryBarcode">product barcode that the order must contain</param>
        /// <returns>Orders associated with this loading</returns>
        public WOrder GetOrders(string primaryBarcode)
        {
            WOrder order = new WOrder();
            order.LoadBySiteLoadingNumberAndPrimaryBarcode(this.SiteID, this.LoadingNumber, primaryBarcode);
            return order;
        }

        /// <summary>Returns the product associated with this loading and it's the specified barcode</summary>
        /// <param name="barcode">products barcode that the order must contain</param>
        /// <returns>product assocaited with this loading (null if none present)</returns>
        public WProductRow GetDrug(string barcode)
        {
            WProduct product = new WProduct();
            product.LoadBySiteLoadingNumberAndPrimaryBarcode(this.SiteID, this.LoadingNumber, barcode);
            return product.Any() ? product.First() : null;
        }
    }

    
    /// <summary>Provides column information about the OrderLoading table</summary>
    public class OrderLoadingColumnInfo : BaseColumnInfo
    {
        public OrderLoadingColumnInfo() : base("OrderLoading") { }
    }


    /// <summary>Represent the OrderLoading table</summary>
    public class OrderLoading : BaseTable<OrderLoadingRow, OrderLoadingColumnInfo>
    {
        public OrderLoading() : base("OrderLoading", "OrderLoadingID") 
        {  
            this.UpdateSP = "pOrderLoadingUpdate";
        }

        /// <summary>Creates a new loading with the specified loading number (status is set to Active)</summary>
        /// <param name="loadingNumber">new loading number</param>
        /// <returns>new order loading</returns>
        public OrderLoadingRow Add(int loadingNumber)
        {
            OrderLoadingRow row = base.Add();

            row.LoadingNumber       = loadingNumber;
            row.SiteID              = SessionInfo.SiteID;
            row.Status              = OrderLoadingStatus.Active;
            row.CreatedDateTime     = DateTime.Now;
            row.CreatedUser_EntityID= SessionInfo.EntityID;

            return row;
        }

        /// <summary>
        /// Loads an order loading by loading number
        /// </summary>
        /// <param name="siteID">Site Id</param>
        /// <param name="loadingNumber">loading number</param>
        public void LoadBySiteAndLoadingNumber(int siteID, int loadingNumber)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "SiteID",        siteID);
            AddInputParam(parameters, "LoadingNumber", loadingNumber);
            LoadRecordSetStream("pOrderLoadingBySiteAndLoadingNumber", parameters);
        }

        /// <summary>
        /// Loads an order loading by ID
        /// </summary>
        /// <param name="ID">Order Loading ID</param>
        public void LoadByID(int orderLoadingID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "OrderLoadingID", orderLoadingID);
            LoadRecordSetStream("pOrderLoadingByID", parameters);
        }

        /// <summary>Gets an order loading by loading number</summary>
        /// <param name="siteID">Site Id</param>
        /// <param name="loadingNumber">loading number</param>
        /// <returns>order loading</returns>
        static public OrderLoadingRow GetBySiteAndLoadingNumber(int siteID, int loadingNumber)
        {
            OrderLoading orderLoading = new OrderLoading();
            orderLoading.LoadBySiteAndLoadingNumber(siteID, loadingNumber);
            return (orderLoading.Any()) ? orderLoading[0] : null;
        }

        /// <summary>Links a reconil item with an order loading</summary>
        /// <param name="orderLoadingID">ID of order loading row</param>
        /// <param name="reconcilID">ID of reconcil row</param>
        static public void AssociateOrderLoadingWithReconcil(int orderLoadingID, int reconcilID)
        {
            OrderLoading orderLoading = new OrderLoading();
            orderLoading.InsertLink("wReconcilLinkOrderLoading", "wReconcilID", reconcilID, "OrderLoadingID", orderLoadingID);
        }
    }
}
