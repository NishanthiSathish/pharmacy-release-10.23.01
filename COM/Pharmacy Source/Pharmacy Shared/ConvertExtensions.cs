//===========================================================================
//
//							    ConvertExtensions.cs
//
//  Provides extra conversion methods
//
//  Usage
//  ConvertExtensions.ChangeType<int?>("343")                   // return 343
//  ConvertExtensions.ChangeType<int?>(null)                    // return null
//  ConvertExtensions.ChangeType<bool>("Yes")                   // return true
//  ConvertExtensions.ChangeType<bool>("0")                     // return false
//  ConvertExtensions.ChangeType<WLookupContextType>("Warning") // return WLookupContextType.Warning
//
//  ConvertExtensions.ToMinutes("4")        // Returns 4
//  ConvertExtensions.ToMinutes("1H")       // Returns 60
//  ConvertExtensions.ToMinutes("1H 1D")    // Returns 1500
//
//  ConvertExtensions.FromMinutes(4)        // Returns 4M
//  ConvertExtensions.FromMinutes(60)       // Returns 1H
//  ConvertExtensions.FromMinutes(1500)     // Returns 1D 1H
//  
//	Modification History:
//	23Apr14 XN  Add support for Enums to ConvertExtensions 88858
//  10Jun15 XN  Added ChangeType
//  01Jul15 XN  Added FromMinutes 39882
//  19Aug16 XN  Allowed FromMintues to change order outputs results 160567
//  28Nov16 XN  Added SqlToNETType 147104
//===========================================================================
namespace ascribe.pharmacy.shared
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Reflection;

    public static class ConvertExtensions
    {
        /// <summary>
        /// Converts value to type T
        /// if value == null and T supports null then will return null
        /// if T is bool and value is string will use BoolExtensions.PharmacyParse
        /// if T is Enum and value is string will use Enum.Parse not case specific
        /// else uses Convert.ChangeType
        /// </summary>
        public static T ChangeType<T>(object value)
        {
            Type type           = typeof(T);
            Type underlyingType = Nullable.GetUnderlyingType(type);      
            Type baseType       = type.BaseType;
            
            if (underlyingType != null)     
            {         
                if (value == null)             
                    return default(T);          
                
                // return (T)Convert.ChangeType(value, underlyingType); 56701 XN 01Nov13 Improved conversion of null reference types  
                type    = underlyingType;
                baseType= type.BaseType;
            }   

            if (type == typeof(bool) && value.GetType() == typeof(string))
            {
                // 56701 XN 01Nov13 
                // If nullable type and is null or empyt string return null
                if (underlyingType != null && string.IsNullOrEmpty(value as string))
                    return (T)(object)null;
                
                return (T)(object)BoolExtensions.PharmacyParse(value as string);    // 15Aug13 XN Added 24653
            }
            else if (baseType != null && baseType.Name.EqualsNoCase("Enum") && value.GetType() == typeof(string))
                return (T)Enum.Parse(type, value as string, true);  // 23Apr14 XN Added 88858
            else     
                return (T)Convert.ChangeType(value, type);
        }

        /// <summary>Use basic ChangeType conversion, if can't convert or null then returns default value</summary>
        /// <typeparam name="T">Type to convert to</typeparam>
        /// <param name="value">Value to convert</param>
        /// <param name="defaultValue">Default to return if can't convert</param>
        /// <returns>Converted value</returns>
        public static T ChangeType<T>(object value, T defaultValue)
        {
            try
            {
                object obj = ChangeType<T>(value); 
                return obj == null ? defaultValue : (T)obj;
            }
            catch (Exception)
            {
                return defaultValue;
            }    
        }

        /// <summary>
        /// Convert SQL data type to .NET data type
        /// 28Nov16 XN 147104
        /// </summary>
        /// <param name="sqlType">SQL data type</param>
        /// <returns>.NET data type</returns>
        public static Type SqlToNETType(string sqlType)
        {
            switch(sqlType.ToLower())
            {
            case "text": 
            case "ntext":
            case "varchar":
            case "nchar":
            case "char":            
            case "nvarchar":        return typeof(string);
            case "uniqueidentifier":return typeof(Guid);
            case "smallint":        return typeof(short);
            case "int":             return typeof(int);
            case "float":           return typeof(double);
            case "datetime":        return typeof(DateTime);
            case "decimal":         return typeof(decimal);
            case "bit":             return typeof(bool);
            case "tinyint":         return typeof(byte);
            }

            throw new ApplicationException("Unsupported SQL type " + sqlType);      
        }

        /// <summary>
        /// Converts val from value string to a time in minutes, can use post fix value with H, D, W, Y
        /// and will return the minute representation of this. So
        ///     4  will return 4
        ///     1H will return 60
        ///     1D will return 1440
        ///     1W will return 1440 * 7      = 10080
        ///     1Y will return 1440 * 365.25 = 525960
        ///     1H 1D will return 1500
        ///     
        /// Returns null if val is null, empty or white space, or if can't convert to double or invalid postfix char
        /// </summary>
        public static double? ToMinutes(string str)
        {
            double result = 0.0;

            // check if null
            if (string.IsNullOrWhiteSpace(str))
                return null;

            foreach(string s in str.Split(new []{' '}, StringSplitOptions.RemoveEmptyEntries))
            {
                string val = s.Trim();

                // Extract unit postfix
                string unit = string.IsNullOrEmpty(val) ? string.Empty : val.SafeSubstring(val.Length - 1, 1);

                // Convert value to double
                string valueStr = char.IsDigit(unit[0]) ? val : val.SafeSubstring(0, val.Length - 1);
                double value;
                if (!double.TryParse(valueStr, out value))
                    return null;

                // Convert to mins
                switch (unit.ToUpper())
                {
                case "H": value *= 60;              break;
                case "D": value *= 1440;            break;
                case "W": value *= 1440 * 7;        break;
                case "Y": value *= 1440 * 365.25;   break;
                case "" : break;            
                default: 
                    // If unsupported postfix and not number then return null
                    if (!Char.IsDigit(unit, 0) && unit != ".")
                        return null;
                    break;
                }

                result += value;
            }

            return result;
        }

        /// <summary>
        /// Converts value to string broken into M, H, D, W, Y
        ///     4                      will return 4M
        ///     60                     will return 1H 
        ///     1440                   will return 1D 
        ///     1440 * 7 = 10080       will return 1W 
        ///     1440 * 365.25 = 525960 will return 1Y 
        ///     1500                   will return 1H 1D 
        ///     1500                   will return 1D 1H  (of orderMHD is false)
        /// 1Jul15 XN 39882
        /// </summary>
        /// <param name="valueInMins">Value to convert</param>
        /// <param param name="orderMHD">If to order the out put lost item first 19Aug16 XN 160567</param>
        /// <returns>String representation of the value</returns>
        public static string FromMintues(int valueInMins, bool orderMHD = true)
        {
            List<string> parts = new List<string>();
            int temp;
            
            // Year
            temp = (int)Math.Floor(valueInMins / (1440.0 * 365.25));
            if (temp != 0)
            {
                parts.Add(temp + "Y");
                valueInMins -= (int)Math.Floor(temp * 1440.0 * 365.25);
            }

            // Week 
            temp = (int)Math.Floor(valueInMins / (1440.0 * 7));
            if (temp != 0)
            {
                parts.Add(temp + "W");
                valueInMins -= (int)(temp * 1440.0 * 7);
            }

            // Day
            temp = (int)Math.Floor(valueInMins / 1440.0);
            if (temp != 0)
            {
                parts.Add(temp + "D");
                valueInMins -= (int)(temp * 1440.0);
            }

            // Hour
            temp = (int)Math.Floor(valueInMins / 60.0);
            if (temp != 0)
            {
                parts.Add(temp + "H");
                valueInMins -= (int)(temp * 60.0);
            }

            // Minute
            if (valueInMins != 0)
            {
                parts.Add(valueInMins + "M");
            }

            if (orderMHD)
                parts.Reverse();
            return parts.ToCSVString(" ");
        }

        [Obsolete("This method of configurable grids is not needed anymore (now replaced with QuesScrol configuration)")]
        public static string PharmacyPropertyReader(object row, string fieldName, string fieldFormat, Func<object,string,string,string> fieldConvterFunction)
        {
            string text = string.Empty;
            Type   type = (row == null) ? null : row.GetType();

            if (row == null)
                text = string.Empty;
            else if (fieldName.Contains("{") && fieldConvterFunction != null)
                text = fieldConvterFunction(row, fieldName, fieldFormat);       // Use fieldConvterFunction to convert the field
            else
            {
                object valueObj = null;

                // Try reading value from object
                if (valueObj == null)
                {
                    PropertyInfo property = type.GetProperty(fieldName);
                    if (property != null)
                        valueObj = property.GetValue(row, null);
                }

                // Try reading value from BaseRow as DB field
                if (valueObj == null && type.Name.EqualsNoCaseTrimEnd("BaseRow"))
                {
                    valueObj = ((DataRow)type.GetProperty("RawRow").GetValue(row, null))[fieldName];
                    if (valueObj == DBNull.Value)
                        valueObj = null;
                }

                if (valueObj != null)
                {
                    // Convert field to string
                    if (string.IsNullOrEmpty(fieldFormat))
                    {
                        if (valueObj is Boolean)
                            text = ((bool)valueObj).ToYesNoString();
                        else
                            text = valueObj.ToString();
                    }
                    else if (fieldFormat.Contains("{")) 
                        text = string.Format(fieldFormat, valueObj);
                    else
                    {
                        // Special conversion functions
                        switch (fieldFormat.Trim().ToLower())
                        {
                        case "pharmacydate"         : text = ((DateTime)valueObj).ToPharmacyDateString();      break;
                        case "pharmacydatecoloured" : 
                            DateTime value = ((DateTime)valueObj);
                            if (value.Date == DateTime.Now.Date)
                                text = "<span style='color:red;font-weight:bold;'>" + value.ToPharmacyDateString() + "</span>";
                            else if (value.Date == DateTime.Now.Date.AddDays(-1))
                                text = "<span style='color:red;font-style:italic;'>" + value.ToPharmacyDateString() + "</span>";
                            else
                                text = value.ToPharmacyDateString();
                            break;
                        case "pharmacytime"         : text = ((DateTime)valueObj).ToPharmacyTimeString();      break;
                        case "pharmacydatetime"     : text = ((DateTime)valueObj).ToPharmacyDateTimeString();  break;
                        }
                    }
                }
            }

            return text;
        }
    }
}

