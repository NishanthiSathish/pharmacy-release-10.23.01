//===========================================================================
//
//							       OrderLoadingDetail.cs
//
//  Provides access to OrderLoadingDetail table.
//
//  OrderLoadingDetail table holds information about orders linked to a robot loading number.
//
//  Only supports reading, and inserting.
//
//	Modification History:
//	21Dec09 XN Written (F0074142)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.robotloading
{
    /// <summary>Represents a row in the OrderLoadingDetail table</summary>
    public class OrderLoadingDetailRow : BaseRow
    {
        public int OrderLoadingDetailID 
        { 
            get { return FieldToInt(RawRow["OrderLoadingDetailID"]).Value; }
        }

        public int WOrderNum
        {
            get { return FieldToInt(RawRow["WOrderNum"]).Value; }
            set { RawRow["WOrderNum"] = FieldToInt(value);      }
        }

        public int OrderLoadingID
        {
            get { return FieldToInt(RawRow["OrderLoadingID"]).Value; }
            set { RawRow["OrderLoadingID"] = FieldToInt(value);      }
        }
    }
    
    /// <summary>Provides column information about the OrderLoadingDetail table</summary>
    public class OrderLoadingDetailColumnInfo : BaseColumnInfo
    {
        public OrderLoadingDetailColumnInfo() : base("OrderLoadingDetail") { }
    }

    /// <summary>Represent the OrderLoadingDetail table</summary>
    public class OrderLoadingDetail : BaseTable<OrderLoadingDetailRow, OrderLoadingDetailColumnInfo>
    {
        public OrderLoadingDetail() : base("OrderLoadingDetail", "OrderLoadingDetailID") { }

        /// <summary>
        /// Creates and returns new order loading row for specified loading Id, and order number
        /// </summary>
        /// <param name="orderLoadingID">order loading ID</param>
        /// <param name="orderNumber">order number</param>
        /// <returns>Returns order loading row</returns>
        public OrderLoadingDetailRow Add(int orderLoadingID, int orderNumber)
        {
            OrderLoadingDetailRow row = base.Add();
            row.OrderLoadingID = orderLoadingID;
            row.WOrderNum      = orderNumber;
            return row;
        }
    }
}
