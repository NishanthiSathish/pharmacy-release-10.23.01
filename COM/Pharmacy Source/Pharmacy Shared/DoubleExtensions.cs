//===========================================================================
//
//							     DoubleExtensions.cs
//
//	Provides a number of extension methods to the double data type.
//
//  Usage:
//  decimal val = 45634.43;
//  val.ToMoneyString() returns "£ 456.34"
//      
//	Modification History:
//	15May13 XN  Written (27038)
//  16Jun15 XN  Added ToString option for double? 39882
//  14Apr16 XN  Added To7Sf7Dp 123082
//  26Apr16 XN  Added ToSigFig 123082
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ascribe.pharmacy.shared
{
    public static class DoubleExtensions
    {
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
        /// <returns>Decimal as money value string</returns>
        public static string ToMoneyString(this double value, MoneyDisplayType displayType)
        {
            return ToMoneyString((double?)value, displayType);
        }
        public static string ToMoneyString(this double? value, MoneyDisplayType displayType)
        {
            string currecnySymbol = PharmacyCultureInfo.CurrencySymbol;
            string money;

            if (displayType == MoneyDisplayType.Hide)
                money = currecnySymbol + "*****";
            else if (displayType == MoneyDisplayType.HideWithLeadingSpace)
                money = currecnySymbol + " ****";
            else if (!value.HasValue)
                money = string.Empty;
            else
            {
                double valueInPounds = Math.Round(value.Value, 0, MidpointRounding.AwayFromZero) / 100.0;
                money = string.Format("{0} {1:F2}", currecnySymbol, valueInPounds);
            }

            return money;
        }

        /// <summary>
        /// decimal? does not have a ToString(format) function by default so created one here
        /// If value is null then return empty string.
        /// 16Jun15 XN 39882
        /// </summary>
        /// <param name="value">value to convert to string</param>
        /// <param name="format">A numerical format string</param>
        /// <returns>formated value or empty string</returns>
        public static string ToString(this double? value, string format)
        {
            return value.HasValue ? value.Value.ToString(format) : string.Empty;
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
        public static double To7Sf7Dp(this double value)
        {
            string valStr = Math.Abs((float)value).ToString("E");    // forcing to float force to 7SigFig
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
                    value = Math.Sign(value) * Math.Round(double.Parse(mantissaStr), mantissaStr.Length - 3, MidpointRounding.AwayFromZero) * double.Parse("1E" + expoent.ToString());

                    // Limit to 7 decimal places
                    value = Math.Round(value, 7, MidpointRounding.AwayFromZero);
                }
                else
                {
                    value = Math.Sign(value) * double.Parse(valStr);  // Handle the larger numbers
                }
            }

            return value;
        }

        /// <summary>Converts the double to the specified number of sig figs</summary>
        /// <param name="value">Value to convert</param>
        /// <param name="sigFigs">number of sig figs</param>
        /// <returns>Converts the doubel to specified number of sig figs</returns>
        public static double ToSigFig(this double value, int sigFigs)
        {
            string valStr = Math.Abs(value).ToString("E");    
            int    expPos = valStr.IndexOf('E');

            if (expPos > 0)
            {
                string mantissaStr = valStr.SafeSubstring(0, expPos);
                string expoentStr  = valStr.SafeSubstring(expPos + 1);
                int    expoent     = int.Parse(expoentStr);

                // Rebuild number (the round in the middle will reduce the number of dp by when 7 or more sig fig)
                value = Math.Sign(value) * Math.Round(double.Parse(mantissaStr), sigFigs - 1, MidpointRounding.AwayFromZero) * double.Parse("1E" + expoent.ToString());
            }

            return value;
        }
    }
}
