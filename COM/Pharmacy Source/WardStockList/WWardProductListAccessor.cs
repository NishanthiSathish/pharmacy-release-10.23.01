//===========================================================================
//
//                  WWardProductListAccessor.cs
//
//  Accessor class for WWardProductListRow
//
//  Supports interface IQSDisplayAccessor
//  
//	Modification History:
//  02Oct14 XN  Written 98658
//===========================================================================
using System;
using System.Collections.Generic;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.wardstocklistlayer
{
    public class WWardProductListAccessor : IQSDisplayAccessor
    {
        private Dictionary<int,WCustomerRow> cachedCustomers = new Dictionary<int,WCustomerRow>();

        #region IQSDisplayAccessor Members
        /// <summary>the main supported BaseRow type for the accessor (will be WWardProductListRow)</summary>
        public Type SupportedType { get { return typeof(WWardProductListRow); } }

        /// <summary>Tag name for the accessor (links to name in the DB)</summary>
        public string AccessorTag { get { return "Stock List"; } }

        /// <summary>Returns string suitable for display (on panels and grids) for selected value (propertyName)</summary>
        /// <param name="r">Base row should be of type (WWardProductListRow)</param>
        /// <param name="dataType">Column QS data type</param>
        /// <param name="propertyName">Name of property to return the value for (or special tag name e.g. {description})</param>
        /// <param name="formatOption">Format option for the value</param>
        public string GetValueForDisplay(BaseRow r, int dataIndex, QSDataType dataType, string propertyName, string formatOption)
        {
            WWardProductListRow row = (r as WWardProductListRow);

            switch (propertyName.ToLower())
            {
            case "ward" :   // 108628 16Jan14 XN Updates to display
                string text = string.Empty;
                WCustomerRow customer = null;
                if (row.WCustomerID != null)
                {
                    if (!cachedCustomers.TryGetValue(row.WCustomerID.Value, out customer) )
                    {
                        customer = WCustomer.GetByID(row.WCustomerID.Value);
                        cachedCustomers.Add(row.WCustomerID.Value, customer);
                        text = customer.ToString().XMLEscape();
                    }
                }

                if (customer == null && formatOption.ToLower().Contains("highlight_not_linked"))
                {
                    text = "<span style='font-style:italic;color:red;'>Not Linked</span>";
                }

                if (customer != null && !customer.InUse)
                {
                    return "<span style='font-style:italic;color:red;'>" + text + "</span>";
                }

                return text;

            case "sitenumber" :
                return row.SiteID == null ? "All sites" : Sites.GetNumberBySiteID(row.SiteID.Value).ToString("000");

            case "inuse":// 108628 16Jan14 XN Updates to display
                if (!row.InUse && formatOption.ToLower().Contains("highlight_out_of_use"))
                {
                    return "<span style='font-style:italic;color:red;'>No</span>";
                }
                break;  // Fall through to standard QSHelper.PharmacyPropertyReader
            }

            return QSHelper.PharmacyPropertyReader(row, dataType, propertyName, formatOption);
        }

        #endregion
    }
}
