//===========================================================================
//
//							       OrderLoading.cs
//
//  Provides access to OrderLoadingException table.
//
//  OrderLoadingException holds errors that occured while an order was being processed by a robot.
//
//  Only supports reading, and inserting
//
//	Modification History:
//	21Dec09 XN Written (F0074142)
//===========================================================================
using System;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.robotloading
{
    /// <summary>Represent the OrderLoadingException row</summary>
    public class OrderLoadingExceptionRow : BaseRow
    {
        public int OrderLoadingExceptionID
        { 
            get { return FieldToInt(RawRow["OrderLoadingExceptionID"]).Value; }
        }

        /// <summary>Order loading the exception is related to.</summary>
        public int OrderLoadingID
        { 
            get { return FieldToInt(RawRow["OrderLoadingID"]).Value; }
            set { RawRow["OrderLoadingID"] = IntToField(value);      }
        }

        /// <summary>Drug the exception is related to.</summary>
        public int? SiteProductDataID
        { 
            get { return FieldToInt(RawRow["SiteProductDataID"]);   }
            set { RawRow["SiteProductDataID"] = IntToField(value);  }
        }

        /// <summary>Exception description.</summary>
        public string Description
        { 
            get { return FieldToStr(RawRow["Description"]);   }
            set { RawRow["Description"] = StrToField(value);  }
        }

        /// <summary>Lookup ID user has assigned to the exception.</summary>
        public int? WLookupID
        { 
            get { return FieldToInt(RawRow["WLookupID"]);   }
            set { RawRow["WLookupID"] = IntToField(value);  }
        }

        /// <summary>Date and time exception occured</summary>
        public DateTime DateTime
        {
            get { return FieldToDateTime(RawRow["DateTime"]).Value;   }
            set { RawRow["DateTime"] = DateTimeToField(value);        }
        }
    }
    
    /// <summary>Provides column information about the OrderLoadingException table</summary>
    public class OrderLoadingExceptionColumnInfo : BaseOrderColumnInfo
    {
        public OrderLoadingExceptionColumnInfo() : base("OrderLoadingException") { }

        public int DescriptionLength  { get { return tableInfo.GetFieldLength("Description"); } }
    }

    /// <summary>Represent the OrderLoadingException table</summary>
    public class OrderLoadingException : BaseTable<OrderLoadingExceptionRow, OrderLoadingExceptionColumnInfo>
    {
        public OrderLoadingException() : base("OrderLoadingException", "OrderLoadingExceptionID") { }

        /// <summary>Adds an order loading exception to the list</summary>
        /// <param name="orderLoadingID">order loading id the exception is replated to</param>
        /// <param name="barcode">Drug barcode the exception is related to</param>
        /// <param name="description">Exception description</param>
        /// <returns>New order loading exception (or null if loading number is invalid)</returns>
        public OrderLoadingExceptionRow Add(int loadingNumber, string barcode, string description)
        {
            // Get the order loading ID
            int? orderLoadingID = null;
            OrderLoading loading = new OrderLoading();
            loading.LoadBySiteAndLoadingNumber(SessionInfo.SiteID, loadingNumber);
            if (loading.Any())
                orderLoadingID = loading[0].OrderLoadingID;

            // Get the drug ID
            int? drugID = null;
            WProductRow product = null;
            if (loading.Any())
                product = loading[0].GetDrug(barcode);
            if (product != null)
                drugID = product.SiteProductDataID;

            // Add new row
            OrderLoadingExceptionRow row = null;
            if (orderLoadingID.HasValue)
            {
                row = base.Add();
                row.OrderLoadingID      = orderLoadingID.Value;
                row.Description         = description;
                row.SiteProductDataID   = drugID;
                row.WLookupID           = null;
                row.DateTime            = DateTime.Now;
            }

            return row;
        }
    }
}
