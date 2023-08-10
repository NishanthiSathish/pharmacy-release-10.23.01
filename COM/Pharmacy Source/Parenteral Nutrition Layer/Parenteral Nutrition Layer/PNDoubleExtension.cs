//===========================================================================
//
//					     PNDoubleExtension.cs
//
//  Provides extension methods to the double class.
//
//  This will provide the following helper methods for handling double values 
//  in PN
//  
//  To3SigFigish - Rounds double to 3 significant figures (ish)
//                 however does not go below 2 decimal places, and does not 
//                 round figures above the decimal place.
//                 e.g. 0.0001 goes to 0.00
//                      0.025  goes to 0.03
//                      0.111  goes to 0.11
//                      1.111  goes to 1.11
//                      11.111 goes to 11.1
//                      111.11 goes to  111
//
//  ToPNString   - Converts double to suitable string format for To3SigFigish
//                 function above. Note no need to call To3SigFigish before ToPNString
//                 e.g. 0.03 displayes "0.03"
//                      0.11 displayes "0.11"
//                      1.11 displayes "1.11"
//                      11.1 displayes "11.1"
//                      111  displayes "111"
//                  Usage   (0.111).ToPNString() returns "0.11"
//
//  ToVDUString  - Converts double to sutiable string format to display in view 
//                 and adjust screen.
//                 e.g. 0.001 displayes ""
//                      0.03  displayes "0.03"
//                      0.11  displayes "0.11"
//                      1.11  displayes "1.11"
//                      11.1  displayes "11.1"
//                      111   displayes "111"
//                      1111  displayes >10K

//  IsZero      - Returns if number is zero (test down to 0.00001, or specified number of dp)
//
//	Modification History:
//	15Nov11 XN  Written
//  02Jun16 XN  154627 Fix the infusion rate to display correct rounding 
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    public static class PNDoubleExtension
    {
        /// <summary>
        /// Rounds double to 1Dp or 3Sf also pads left to 4 spaces
        /// e.g. 0.0001 goes to 0.0
        ///      0.025  goes to 0.0
        ///      0.111  goes to 0.1
        ///      1.111  goes to 1.1
        ///      11.111 goes to 11.1
        ///      111.11 goes to 111
        /// 02Jun16 XN 154627 Fix the infusion rate to display correct rounding      
        /// </summary>
        public static string To2SigFigString(this double value)
        {
            //value += 0.00001;

            //// round to 0.00
            //double pos_value = Math.Abs(Math.Round(value, 2, MidpointRounding.AwayFromZero));
            
            //if (pos_value > 9.99)
            //    return Math.Round(value, 0, MidpointRounding.AwayFromZero).ToString("#");      // round items in 100s to 000
            //else
            //    return Math.Round(value, 1, MidpointRounding.AwayFromZero).ToString("0.0");   // round items in 10s to 00.0
            
            double pos_value = Math.Abs(value);
            
            if (pos_value >= 9999.5)
                return Math.Round(value, 0, MidpointRounding.AwayFromZero).ToString("#").PadLeft(4,' ');
            else if (pos_value > 99.4)
                return Math.Round(value, 0, MidpointRounding.AwayFromZero).ToString("####").PadLeft(4,' ');
            else if (pos_value > 9.999)
                return Math.Round(value, 1, MidpointRounding.AwayFromZero).ToString("##.0").PadLeft(4,' ');
            else if (pos_value > 0)
                return Math.Round(value, 1, MidpointRounding.AwayFromZero).ToString("0.0").PadLeft(4,' ');
            else
                return "   0";
        }

        /// <summary>
        /// Rounds double to 3 significant figures (ish)
        /// however does not go below 2 decimal places, and does not
        /// round figures above the decimal place.
        /// e.g. 0.0001 goes to 0.00
        ///      0.025  goes to 0.03
        ///      0.111  goes to 0.11
        ///      1.111  goes to 1.11
        ///      11.111 goes to 11.1
        ///      111.11 goes to  111
        /// </summary>
        public static double To3SigFigish(this double value)
        {
            value += 0.000001;

            // round to 0.00
            double pos_value = Math.Abs(Math.Round(value, 2, MidpointRounding.AwayFromZero));
            
            if (pos_value > 99.99)
                value = Math.Round(value, 0, MidpointRounding.AwayFromZero);   // round items in 100s to 000
            else if (pos_value > 9.99)
                value = Math.Round(value, 1, MidpointRounding.AwayFromZero);   // round items in 10s to 00.0
            else
                value = Math.Round(value, 2, MidpointRounding.AwayFromZero);   // round items in 1s and below to 00.00

            return value;
        }
        public static double? To3SigFigish(this double? value)
        {
            return value.HasValue ? value.Value.To3SigFigish() : (double?)null;
        }

        /// <summary>
        /// Rounds double to 1Dp or 3Sf also pads left to 4 spaces
        /// e.g. 0.0001 goes to 0.0
        ///      0.025  goes to 0.0
        ///      0.111  goes to 0.1
        ///      1.111  goes to 1.1
        ///      11.111 goes to 11.1
        ///      111.11 goes to 111
        /// 02Jun16 XN  154627 Added
        /// </summary>
        /// <param name="value">Value to convert</param>
        /// <returns>converted string</returns>
        public static string To3SigFigString(this double value)
        {
            double pos_value = Math.Abs(value);
            
            if (pos_value >= 9999.5)
                return value.To3SigFigish().ToString("####").PadLeft(4,' ');
            else if (pos_value > 99.4)
                return value.To3SigFigish().ToString("####").PadLeft(4,' ');
            else if (pos_value > 9.999)
                return value.To3SigFigish().ToString("##.0").PadLeft(4,' ');
            else if (pos_value > 0)
                return value.To3SigFigish().ToString("0.0#").PadLeft(4,' ');
            else
                return "   0";
        }

        /// <summary>
        /// Converts double string to suitable format for To4SigFigish
        /// e.g. 0.0031  displayes "0.003"
        ///      0.1111  displayes "0.111"
        ///      1.1111  displayes "1.111"
        ///      11.111  displayes "111.1"
        ///      111.11  displayes "111.1"
        ///      1111    displayes "1111"
        /// </summary>
        public static string To4SigFigString(this double value)
        {
            value += 0.000001;

            // round to 0.00
            double pos_value = Math.Abs(Math.Round(value, 3, MidpointRounding.AwayFromZero));
            
            if (pos_value > 999.99)
                return Math.Round(value, 0, MidpointRounding.AwayFromZero).ToString("#");       // round items in 1000s to 000
            else if (pos_value > 99.99)
                return Math.Round(value, 1, MidpointRounding.AwayFromZero).ToString("0.0");     // round items in 100s to 000
            else if (pos_value > 9.99)
                return Math.Round(value, 2, MidpointRounding.AwayFromZero).ToString("0.00");    // round items in 100s to 000
            else
                return Math.Round(value, 3, MidpointRounding.AwayFromZero).ToString("0.000");   // round items in 1s and below to 00.00
        }

        /// <summary>
        /// Converts double string to suitable format for To3SigFigish
        /// function above. 
        /// Note No need to call To3SigFigish before ToPNString
        /// e.g. 0.03 displayes "0.03"
        ///      0.11 displayes "0.11"
        ///      1.11 displayes "1.11"
        ///      11.1 displayes "11.1"
        ///      111  displayes "111"
        /// </summary>
        public static string ToPNString(this double value)
        {
            value = value.To3SigFigish();

            if (value > 99.99)
                return value.ToString("#");
            else if (value > 9.99)
                return value.ToString("0.0");
            else            
                return value.ToString("0.00");
        }

        /// <summary>Converts the double string to in full format (6 dp)</summary>
        /// <param name="blankIfNoDiff">If true and value is same at 3 Sig Figish return blank string</param>
        public static string ToPNFullString(this double value, bool blankIfNoDiff)
        {
            return blankIfNoDiff && (value.To3SigFigish() - value).IsZero(6) ? string.Empty :  value.ToString("0.000000");
        }

        /// <summary>
        /// Converts double to sutiable string format to display in view
        /// and adjust screen.
        /// e.g. 0.001 displayes ""
        ///      0.03  displayes "0.03"
        ///      0.11  displayes "0.11"
        ///      1.11  displayes "1.11"
        ///      11.1  displayes "11.1"
        ///      111   displayes "111"
        ///      1111  displayes >10K
        /// </summary>
        public static string ToVDUString(this double value)
        {
            double absValue = Math.Abs(value).To3SigFigish();

            if (value > 9999.99)
                return ">10K";
            else if (absValue > 99.99)
                return value.ToString("#");
            else if (absValue > 9.99)
                return value.ToString("0.0");
            else if (absValue < 0.01)
                return string.Empty;
            else            
                return value.ToString("0.0#");
        }

        /// <summary>
        /// Converts double to sutiable string format, 
        /// but unlike ToVDUString, zero values will return zero
        /// e.g. 0.001 displayes "0"
        ///      other results are same as ToVDUString
        /// </summary>
        public static string ToVDUIncludeZeroString(this double value)
        {
            string result = value.ToVDUString();
            return string.IsNullOrEmpty(result) ? "0" : result;
        }

        /// <summary>Returns if number is zero (test down to 0.00001)</summary>
        public static bool IsZero(this double value)
        {
            return Math.Abs(value) < 0.00001;        
        }

        /// <summary>
        /// Returns if number is zero (test down to sepcfied decimal places)
        /// 0.001.IsZero(2) returns true
        /// </summary>
        public static bool IsZero(this double value, int decimalPlaces)
        {
            return Math.Abs(Math.Round(value, decimalPlaces, MidpointRounding.AwayFromZero)) < Math.Pow(10.0, -decimalPlaces);        
        }
    }
}
