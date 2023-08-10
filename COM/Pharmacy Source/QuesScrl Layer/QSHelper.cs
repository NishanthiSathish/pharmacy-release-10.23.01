//===========================================================================
//
//							    QSHelper.cs
//
//  Helper class for QuesScrl
//
//  Currently supports methods
//      PharmacyPropertyReader - returns a property value in a formatted string
//
//	Modification History:
//  08Sep14 XN  Written 98658
//  01Jul15 XN  Fixed possible error where could not read DataRow values as 
//              did not try to get correct base class 39882
//===========================================================================
using System;
using System.Data;
using System.Reflection;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.quesscrllayer
{
    public static class QSHelper
    {
        /// <summary>
        /// Given a row object (normally derived from BaseRow) will return value of the formated propertyName 
        /// 
        /// Will try to get value of property from row (with name propertyName), if not present (and row is of type BaseRow)
        /// will try to get the DB field (with name propertyName), 
        /// otherwise return empty string
        /// 
        /// the default format options are as follows
        ///     Date     - Standard Now & Yesturday Colours
        ///                     If today then red bold (in HTML span)
        ///                     If tommorrow then red italic (in HTML span)
        ///                     else standard dd/mm/yyyy
        ///                Otherwise dd/mm/yyyy
        ///     DateTime - dd/mm/yyyy HH:MM          
        ///     Time     - HH:MM
        ///     Enum     - DBCode
        ///                     Returns the DB code for the Enum
        ///                Otherwise enum text as a string
        ///     Money    - £ {value} the formatOption can be the standard MoneyDisplayType valueas as text
        ///     Number   - formatOption is the standard C# format options for the number (e.g. 0.0##)
        ///     Bool     - returns Yes or No
        /// </summary>
        /// <param name="row">object to read property value (normally derived from BaseRow)</param>
        /// <param name="dataType">Data type of property</param>
        /// <param name="propertyName">Name of property (or can be DB field name is row is BaseRow type)</param>
        /// <param name="formatOption">format options</param>
        public static string PharmacyPropertyReader(object row, QSDataType dataType, string propertyName, string formatOption)
        {
            Type type = row.GetType();
            object valueObj = null;

            // Try reading value from object
            if (valueObj == null)
            {
                PropertyInfo property = type.GetProperty(propertyName);
                if (property != null)
                    valueObj = property.GetValue(row, null);
            }

            // Try reading value from BaseRow as DB field
            // if (valueObj == null && type.Name == "BaseRow") Fixed issue 01Jul15 XN 39882
            if (valueObj == null && type.BaseType.Name == "BaseRow")
            {
                DataRow dbrow = type.GetProperty("RawRow").GetValue(row, null) as DataRow;
                if (dbrow != null && dbrow.Table.Columns.Contains(propertyName))
                {
                    valueObj = dbrow[propertyName];
                }

                if (valueObj == DBNull.Value)
                {
                    valueObj = null;
                }
            }

            if (valueObj == null)
                return string.Empty;

            // Convert field to string
            switch (dataType)
            {
            case QSDataType.Date:
                {
                DateTime value = (DateTime)valueObj;
                if (formatOption.Contains("Now & Yesturday Colours"))
                {
                    if (value.Date == DateTime.Now.Date)
                    {
                        return "<span style='color:red;font-weight:bold;'>" + value.ToPharmacyDateString() + "</span>";
                    }
                    else if (value.Date == DateTime.Now.Date.AddDays(-1))
                    {
                        return "<span style='color:red;font-style:italic;'>" + value.ToPharmacyDateString() + "</span>";
                    }
                }

                return value.ToPharmacyDateString();
                }

            case QSDataType.DateTime: 
                {
                DateTime value  = (DateTime)valueObj;
                string valueStr = formatOption.Contains("dateOnly")
                                        ? value.ToPharmacyDateString()
                                        : value.ToPharmacyDateTimeString();

                if (formatOption.Contains("Now & Yesturday Colours"))
                {
                    if (value.Date == DateTime.Now.Date)
                    {
                        valueStr = "<span style='color:red;font-weight:bold;'>" + valueStr + "</span>";
                    }
                    else if (value.Date == DateTime.Now.Date.AddDays(-1))
                    {
                        valueStr = "<span style='color:red;font-style:italic;'>" + valueStr + "</span>";
                    }
                }
                
                return valueStr;
                }

            case QSDataType.Time:
                return ((DateTime)valueObj).ToPharmacyTimeString();

            case QSDataType.Enum:
                switch (formatOption.ToLower())
                {
                case "dbcode":return EnumDBCodeAttribute.EnumToDBCode(valueObj.GetType(), valueObj);
                default: return valueObj.ToString().XMLEscape();
                }

            case QSDataType.Money:
                bool isDecimal = (valueObj.GetType().Name == "Decimal");
                switch (formatOption.ToLower())
                {
                case "hide":                 return isDecimal ? ((decimal)valueObj).ToMoneyString(MoneyDisplayType.Hide)                 : ((double)valueObj).ToMoneyString(MoneyDisplayType.Hide);
                case "hidewithleadingspace": return isDecimal ? ((decimal)valueObj).ToMoneyString(MoneyDisplayType.HideWithLeadingSpace) : ((double)valueObj).ToMoneyString(MoneyDisplayType.HideWithLeadingSpace);
                default: return isDecimal ? ((decimal)valueObj).ToMoneyString(MoneyDisplayType.Show) : ((double)valueObj).ToMoneyString(MoneyDisplayType.Show);
                }

            case QSDataType.Number:
                int start = formatOption.IndexOf("Format:");
                string formater = string.Empty;
                if (start > -1)
                {
                    start += 7;
                    int end = formatOption.IndexOf(" ", start);
                    if (end == -1)
                    {
                        end = formatOption.Length;
                    }
                    formater = formatOption.SafeSubstring(start, end);
                }
                return string.IsNullOrEmpty(formatOption) ? valueObj.ToString() : string.Format("{0:" + formater + "}", valueObj);

            case QSDataType.Bool:
                bool valueBool = ((bool)valueObj);
                return valueBool.ToYesNoString();

            default:
                return valueObj.ToString().XMLEscape();
            }
        }
    }
}
