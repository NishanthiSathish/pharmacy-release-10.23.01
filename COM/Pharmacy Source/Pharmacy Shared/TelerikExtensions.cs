// -----------------------------------------------------------------------
// <copyright file="TelerikExtensions.cs" company="Ascribe">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

namespace ascribe.pharmacy.shared
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Linq;
    using System.Text;
    using System.Web.UI;

    using Telerik.Web.UI;
    using System.Web.UI.WebControls;

    /// <summary>
    /// TODO: Update summary.
    /// </summary>
    public static class TelerikExtensions
    {
        public static void SetupColumns(GridBoundColumn column, string[] extraColumnsToHide )
        {
            if (column == null)
            {
                return;
            }
            
            column.HeaderStyle.HorizontalAlign = HorizontalAlign.Center;            

            if (column.Owner.DataKeyNames.Contains(column.UniqueName) || column.Owner.ClientDataKeyNames.Contains(column.UniqueName) || extraColumnsToHide.Contains(column.UniqueName))
            {
                column.Visible = false;
            }
            else if (column.DataType.Name == typeof(int).Name ||
                     column.DataType.Name == typeof(double).Name)
            {
                column.HeaderStyle.Width         = 100;
                column.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
            }
            else if (column.DataType.Name == typeof(DateTime).Name)
            {
                column.HeaderStyle.Width         = 100;
                column.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
                 column.DataFormatString = "{0:" + DateTimeExtensions.ShortDatePattern + " " + DateTimeExtensions.TimePattern + "}";
                //if (column.UniqueName == "Last Modified On" || column.UniqueName == "Created Date")    // Last modified on should show daate and time
                //    column.DataFormatString = "{0:" + DateTimeExtensions.ShortDatePattern + " " + DateTimeExtensions.TimePattern + "}";
                //else
                //    ((GridBoundColumn)column).DataFormatString = "{0:" + DateTimeExtensions.ShortDatePattern + "}";
            }
            else
            {
                column.ItemStyle.HorizontalAlign = HorizontalAlign.Left;                
            }
        }
        
        public static GridDataItem FindItemByKeyValueRecursivly<T>(this GridTableView view, string key, T value)
        {
            foreach (GridDataItem item in view.Items)
            {
                if (((T)item.GetDataKeyValue(key)).Equals(value))
                {
                    return item;
                }

                if (item.ChildItem != null)
                {
                    var childItem = (from v in item.ChildItem.NestedTableViews
                                     let c = v.FindItemByKeyValueRecursivly(key, value)
                                     where c != null
                                     select c).FirstOrDefault();
                    if (childItem != null)
                    {
                        return childItem;
                    }
                }
            }

            return null;
        }

        //public static void AddBoundColumn(GridTableView view, IEnumerable<DataColumn> columns, IEnumerable<string> extraColumnsToHide)
        //{
        //    string columnName   = column.UniqueName;
        //    string dataTypeName = column.DataType.Name;

        //    if (view.DataKeyNames.Contains(columnName) || view.ClientDataKeyNames.Contains(columnName) || extraColumnsToHide.Contains(columnName))
        //    {
        //        column.Visible = false;
        //    }
        //    else if (dataTypeName == typeof(int).Name || 
        //             dataTypeName == typeof(double).Name)
        //    {
        //        column.HeaderStyle.Width         = System.Web.UI.WebControls.Unit.Pixel(100);
        //        column.ItemStyle.Width           = column.HeaderStyle.Width;
        //        column.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
        //    }
        //    else if (dataTypeName == typeof(DateTime).Name)
        //    {
        //        column.HeaderStyle.Width         = System.Web.UI.WebControls.Unit.Pixel(100);
        //        column.ItemStyle.Width           = column.HeaderStyle.Width;
        //        column.ItemStyle.HorizontalAlign = HorizontalAlign.Center;

        //        if (table.Cast<DataRowView>().Select(c => c[columnName]).Any(c => c != DBNull.Value && ((DateTime)c).TimeOfDay.Ticks != 0))
        //        {
        //            ((GridBoundColumn)column).DataFormatString = "{0:" + DateTimeExtensions.ShortDatePattern + " " + DateTimeExtensions.TimePattern + "}";
        //        }
        //        else
        //        {
        //            ((GridBoundColumn)column).DataFormatString = "{0:" + DateTimeExtensions.ShortDatePattern + "}";
        //        }
        //    }
        //    else
        //    {
        //        column.HeaderStyle.HorizontalAlign = HorizontalAlign.Left;
        //    }
        //}

        public static void AddButtonColumn(GridTableView view, GridButtonColumnType buttonType, string headerText, string dataTextField, int widthInPixel)
        {
            GridButtonColumn col = new GridButtonColumn();
            view.Columns.Add(col);

            col.ButtonType          = buttonType;
            col.HeaderText          = headerText;
            col.DataTextField       = dataTextField;
            col.HeaderStyle.Width   = widthInPixel;
            col.ItemStyle.Width     = widthInPixel;
        }

        public static void AddBoundColumn(GridTableView view, Type dataType, string headerText, string dataTextField, int? widthInPixel = null, HorizontalAlign? align = null, string dataFormatString = "")
        {
            GridBoundColumn col = new GridBoundColumn();
            view.Columns.Add(col);

            col.HeaderText                  = headerText;
            col.DataField                   = dataTextField;
            col.DataType                    = dataType;
            col.DataFormatString            = dataFormatString;
            col.HeaderStyle.HorizontalAlign = HorizontalAlign.Center;

            if (dataType.Name == typeof(int).Name   || 
                dataType.Name == typeof(double).Name)
            {
                col.HeaderStyle.Width         = widthInPixel ?? 100;
                col.ItemStyle.Width           = widthInPixel ?? 100;
                col.ItemStyle.HorizontalAlign = align ?? HorizontalAlign.Right;   
            }
            else if (dataType.Name == typeof(DateTime).Name)
            {
                col.HeaderStyle.Width         = widthInPixel ?? 100;
                col.ItemStyle.Width           = widthInPixel ?? 100;
                col.ItemStyle.HorizontalAlign = align ?? HorizontalAlign.Center;   
            }
            else
            {
                if (widthInPixel != null)
                {
                    col.HeaderStyle.Width = widthInPixel.Value;
                    col.ItemStyle.Width   = widthInPixel.Value;
                }

                col.ItemStyle.HorizontalAlign = align ?? HorizontalAlign.Left;   
            }
        }
    }
}
