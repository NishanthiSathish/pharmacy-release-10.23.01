//===========================================================================
//
//							     DecimalExtension.cs
//
//	Provides a number of extension methods to the decimal data type.
//
//  Usage:
//
//  decimal val = 456.3443;
//  val.ToString(6) returns "456.34"
//
//  decimal? val = null
//  val.ToString(6) returns ""
//
//  decimal val = 45634.43;
//  val.ToMoneyString() returns "£ 456.34"
//
//  decimal val = 1.175;
//  val.ToPharmacyVATString() return "17.5%"
//      
//	Modification History:
//	15Apr09 XN  Written
//  27Apr09 XN  Ensuered static variables are readonly to allow use as web app.
//  28May09 XN  Moved from base data layer to pharmacy shared
//              Add ToMoneyString extension methods
//  21Jul09 XN  Add ToPharmacyVATString and ToWholePackString methods
//  24Jul09 XN  Got ToWholePackString to support decimal?
//  31Oct11 XN  added constants MaxDBValue, MinDBValue
//  20Feb15 XN  Updated ToString to allow it to convert 1000.ToString(4) as "1000"
//              originally would convert to 1E+03 which would not fit the width
//  14Apr16 XN  Added To7Sf7Dp 123082
//===========================================================================
using System;
using System.Globalization;

namespace ascribe.pharmacy.shared
{
    public static class DecimalExtensions
    {
        #region Constants
        private readonly static char ZeroValue         = '0';   // Used to trim trailing zeros
        private readonly static char DecimalSeparator  = NumberFormatInfo.CurrentInfo.NumberDecimalSeparator[0];   // Used to trim trailing decimal place

        /// <summary>Max value to save to db (also nicer for validation than decimal.MaxValue)</summary>
        public const decimal MaxDBValue = 1E28M;
        /// <summary>Min value to save to db (also nicer for validation than decimal.MinValue)</summary>
        public const decimal MinDBValue = -1E28M;
        #endregion

        #region Extension Methods
        /// <summary>
        /// decimal? does not have a ToString(format) function by default so created one here
        /// If value is null then return empty string.
        /// </summary>
        /// <param name="value">value to convert to string</param>
        /// <param name="format">A numerical format string</param>
        /// <returns>formated value or empty string</returns>
        public static string ToString(this decimal? value, string format)
        {
            if (value.HasValue)
                return value.Value.ToString(format);
            else
                return string.Empty;
        }

        /// <summary>
        /// Converts a decimal value to a fixed length string. 
        /// Values after the decimal point are rounded using Symmetric Arithmetic Rounding
        /// (rounds .5 away from 0)
        /// e.g. 
        ///     456.3     formated to string length 6 would be 456.3
        ///     456.3443  formated to string length 6 would be 456.34
        ///     456.3453  formated to string length 6 would be 456.35
        ///     456.3463  formated to string length 6 would be 456.35
        ///     -456.3443 formated to string length 6 would be -456.3
        ///     -456.3543 formated to string length 6 would be -456.4
        ///     -456.3643 formated to string length 6 would be -456.4
        ///     3.0450    formated to string length 4 would be 3.05
        ///     -3.0450   formated to string length 5 would be -3.05
        ///     -3.0350   formated to string length 5 would be -3.04
        ///     4563443   formated to string length 6 would be 5E+006
        ///     4563443   formated to string length 5 would throw application exception
        ///     null      formated to blank string
        /// </summary>
        /// <param name="value">Value to format</param>
        /// <param name="stringLength">String length</param>
        /// <returns>Decimal as string</returns>
        public static string ToString(this decimal value, int stringLength)
        {
            string convertFormatter = string.Format("f{0}", stringLength);  // conversion formatter where decimal places equal string length (gives starting point)
            string valueAsString    = value.ToString(convertFormatter);     // standard value as string
            
            // Determine position of the decimal place
            int indexOfDP = valueAsString.IndexOf(DecimalSeparator);
            if (indexOfDP == -1)
                throw new ApplicationException("Failed to convert decimal to fixed length string.");

            // Calculate number of decimal places that can fit into the string.
            int numberOfDP = stringLength - indexOfDP - 1;

            // If whole number can fit then return string 
            // with max number of decimal places
            if (numberOfDP >= 0)
            {
                convertFormatter = "0.".PadRight(numberOfDP + 2, '#');
                return value.ToString(convertFormatter);
            }

            // Check if whole number will fit 20Feb15 XN
            valueAsString = valueAsString.TrimEnd(new[] { '0' }).TrimEnd(new[] { '.' });
            if (valueAsString.Length == stringLength)
            {
                return valueAsString;
            }

            // string can't fit so try scientific notation
            convertFormatter = string.Format("E{0}", stringLength);
            valueAsString = value.ToString(convertFormatter);

            // Calculate number of decimal places that can fit into the string.
            int indexOfExponent = valueAsString.IndexOf("E");
            indexOfDP = valueAsString.IndexOf(NumberFormatInfo.CurrentInfo.CurrencyDecimalSeparator);
            numberOfDP = stringLength - indexOfDP - (valueAsString.Length - indexOfExponent);

            // If can fit then return the value
            if (numberOfDP >= 0)
            {
                convertFormatter = string.Format("E{0}", numberOfDP);
                return value.ToString(convertFormatter);
            }

            // Won't fit so fail
            throw new ApplicationException("Failed to convert decimal to fixed length string.");
        }
        public static string ToString(this decimal? value, int stringLength)
        {
            if (value.HasValue)
                return value.Value.ToString(stringLength);
            else
                return string.Empty;
        }

        /// <summary>
        /// Takes a decimal value that represents a monetary value in pence, and
        /// returns a string that represents that value in pounds formatted to 
        /// two decimal places, rounding to the nearest pence, with values exactly 
        /// on 0.5 pence rounded away from zero.
        /// e.g. 
        ///              2.49999  returns £ 0.02
        ///              2.5	  returns £ 0.03
        ///              2.6      returns £ 0.03
        ///              -2.49999 returns £ -0.02
        ///              -2.5     returns £ -0.03
        ///              -2.6     returns £ -0.03
        ///              
        /// The currency symbol comes from PharmacyCultureInfo.Instance.CurrencySymbol
        /// 
        /// Null values will return an empty string without a currency symbol
        /// 
        /// For displayType is MoneyDisplayType.Hide, or MoneyDisplayType.HideWithLeadingSpace
        /// the method will always return £*****, or £ **** (even if the value is null)
        /// </summary>
        /// <param name="value">Value to convert in pence</param>
        /// <param name="displayType">If money value can be displayed</param>
        /// <param name="showCurrencySymbol">If to show currency symbol</param>
        /// <returns>Decimal as money value string</returns>
        public static string ToMoneyString(this decimal value, MoneyDisplayType displayType)
        {
            return ToMoneyString((decimal?)value, displayType, true);
        }
        public static string ToMoneyString(this decimal? value, MoneyDisplayType displayType)
        {
            return ToMoneyString(value, displayType, true);
        }
        public static string ToMoneyString(this decimal? value, MoneyDisplayType displayType, bool showCurrencySymbol)
        {
            string currecnySymbol = string.Empty;
            if (showCurrencySymbol)
                currecnySymbol = PharmacyCultureInfo.CurrencySymbol;

            string money;
            if (displayType == MoneyDisplayType.Hide)
                money = currecnySymbol + "*****";
            else if (displayType == MoneyDisplayType.HideWithLeadingSpace)
                money = currecnySymbol + " ****";
            else if (!value.HasValue)
                money = string.Empty;
            else
            {
                if (showCurrencySymbol)
                    currecnySymbol += " ";

                decimal valueInPounds = Math.Round(value.Value, 0, MidpointRounding.AwayFromZero) / 100;
                money = string.Format("{0}{1:F2}", currecnySymbol, valueInPounds);
            }

            return money;
        }

        /// <summary>
        /// Converts a pharmacy vat value stored as 1.175 to a string of 17.5%
        /// If decimal is null returns blank string.
        /// </summary>
        /// <param name="value">decimal value that repesents a vat rate</param>
        /// <returns>Vat rate as string of e.g. 17.5%</returns>
        public static string ToPharmacyVATString(this decimal value)
        {
            return ((value - 1m) * 100m).ToString() + "%";
        }
        public static string ToPharmacyVATString(this decimal? value)
        {
            return (value.HasValue) ? value.Value.ToPharmacyVATString() : string.Empty;
        }

        /// <summary>
        /// Assumes the decimal value is a quantity in packs.
        /// 
        /// If the quantity is a whole pack it is displayed in the format
        ///     {value} x {conversionFactorPackToIssueUnits}
        /// If it is a part pack (or printInIssueUnits is set) the format is
        ///     {value}
        ///     
        /// value is rounded if it's fractional part is less or greater than 
        /// 1/8th and 7/8th to prevent rounding issues.
        /// 
        /// Value is displayed to 2 decimal places.
        /// </summary>
        /// <param name="valueInPacks">quantity in packs</param>
        /// <param name="conversionFactorPackToIssueUnits">Conversion factor</param>
        /// <param name="printInPacks">Force printing in packs, default as false. Often set from SessionInfo.PrintInPack and item supplier type.</param>
        /// <returns>Value in issue units with correct formatting</returns>
        public static string ToWholePackString(this decimal valueInPacks, int conversionFactorPackToIssueUnits, bool printInPacks)
        {
            // Determine if part pack
            bool partPacks = (valueInPacks - Math.Truncate(valueInPacks)) != decimal.Zero;

            // Determine value in issue units and it part issue unit
            decimal qtyInIssueUnits            = valueInPacks * conversionFactorPackToIssueUnits;
            decimal fractionalPartOfIssueUnits = (qtyInIssueUnits - Math.Truncate(qtyInIssueUnits));
            bool    partIssueUnits             = (fractionalPartOfIssueUnits > 0.125m) && (fractionalPartOfIssueUnits < 0.875m);

            if (partPacks && !partIssueUnits)
                return Math.Round(qtyInIssueUnits).ToString();  // part of pack but not part issue unit so round and print in issue units
            if (partPacks && partIssueUnits)
                return qtyInIssueUnits.ToString("0.##");        // part of pack and part issue unit so don't round and print in issue units
            else if (printInPacks)                              // whole pack so print as {value} x {conversion factor}
                return string.Format("{0} x {1}", valueInPacks.ToString("f0"), conversionFactorPackToIssueUnits);
            else                                                
                return qtyInIssueUnits.ToString("0.##");        // forced to print in issue units
        }
        public static string ToWholePackString(this decimal? valueInPacks, int conversionFactorPackToIssueUnits, bool printInPacks)
        {
            if (valueInPacks.HasValue)
                return valueInPacks.Value.ToWholePackString(conversionFactorPackToIssueUnits, printInPacks);
            else
                return string.Empty;
        }


        /// <summary>
        /// Rounds value to 7 significant figures, and max of 7 decimal places
        /// If the value is 7 or more significant figures will round the decimal places by one value
        /// This replace the vb6 method dp!, though does vary slightly
        /// e.g. 1.234567    goes to  1.23457   same for vb6 dp
        ///     -1.234567    goes to -1.23457   same for vb6 dp
        ///      1.23456     goes to  1.23456   same for vb6 dp
        ///      1.23E-07    goes to  0         same for vb6 dp 
        ///      0.123456789 goes to  0.123457  same for vb6 dp 
        ///      0.012345678 goes to  0.012346  vb6 dp goes to 0.0123456 
        ///      0.001234567 goes to  0.001235  vb6 dp goes to 0.0012345 
        /// XN 18Mar16 123082
        /// </summary>
        public static decimal To7Sf7Dp(this decimal value)
        {
            string valStr = Math.Abs((float)value).ToString("E");   // forcing to float force to 7SigFig
            int    expPos = valStr.IndexOf('E');

            if (expPos > 0)
            {
                string mantissaStr = valStr.SafeSubstring(0, expPos);
                string expoentStr  = valStr.SafeSubstring(expPos + 1);
                int    expoent     = int.Parse(expoentStr);

                if (expoent <= -7)
                    value = 0;  // Too small so set to 0
                else if (expoent < 0 || (mantissaStr.Length >= 8 && expoent < 6))
                {
                    // Rebuild number (the round in the middle will reduce the number of dp by when 7 or more sig fig)
                    value = Math.Sign(value) * Math.Round(decimal.Parse(mantissaStr), mantissaStr.Length - 3, MidpointRounding.AwayFromZero) * decimal.Parse("1E" + expoent.ToString(), System.Globalization.NumberStyles.Float);
                    
                    // Limit to 7 decimal places
                    value = Math.Round(value, 7, MidpointRounding.AwayFromZero);
                }
                else
                {
                    value = Math.Sign(value) * decimal.Parse(valStr, System.Globalization.NumberStyles.Float);  // Handle the larger numbers
                }
            }

            return value;
        }
        #endregion 
    };
}
