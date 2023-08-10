//===========================================================================
//
//							      BoolExtensions.cs
//
//  Provides extension methods for the Boolean data type
//
//  Usage:
//
//  true.ToYesNoString()  returns "Yes"
//  false.ToYesNoString() returns "No"
//
//  BoolExtensions.PharmacyParse("Yes") return true;
//
//	Modification History:
//	21Jul09 XN  Written
//  20Oct11 XN  Added method TryPharmacyParse
//  15Nov12 XN  Added method ToOneZeorString (TFS47487)
//  01Nov13 XN  Added methof PharmacyParseOrNull, minor update to PharmacyParse
//===========================================================================
using System;
using System.Linq;

namespace ascribe.pharmacy.shared
{
    public static class BoolExtensions
    {
        #region Constants
        private static readonly string[] TrueStrings = new string[] { "Y", "YES", "1", "-1", "T", "TRUE", bool.TrueString };
        private static readonly string[] FalseStrings = new string[] { "N", "NO", "0", "F", "FALSE", bool.FalseString };        
        #endregion

        #region Extension methods
        /// <summary>
        /// Returns true as "Yes", and false as "No"
        /// </summary>
        /// <param name="value">Value to convert to yes\no string</param>
        /// <returns>Yes or No string</returns>
        public static string ToYesNoString(this bool value)
        {
            return value ? "Yes" : "No";
        }
        public static string ToYesNoString(this bool? value)
        {
            if (value.HasValue)
                return value.Value ? "Yes" : "No";
            else
                return string.Empty;
        }        

        /// <summary>Returns true as "Y", and false as "N"</summary>
        /// <param name="value">Value to convert to yes\no string</param>
        /// <returns>Y or N string</returns>
        public static string ToYNString(this bool value)
        {
            return value ? "Y" : "N";
        }
        public static string ToYNString(this bool? value)
        {
            if (value.HasValue)
                return value.Value ? "Y" : "N";
            else
                return string.Empty;
        }        

        /// <summary>
        /// Returns true as "1" and false as "0"
        /// </summary>
        /// <param name="value">Value to convert to 1\0 string</param>
        /// <returns>1 or 0 string</returns>
        public static string ToOneZeorString(this bool value)
        {
            return value ? "1" : "0";
        }
        public static string ToOneZeorString(this bool? value)
        {
            if (value.HasValue)
                return value.Value ? "1" : "0";
            else
                return string.Empty;
        }
        #endregion

        #region Static methods
		/// <summary>
        /// Converts a string to a bool  (case insensitive)
        ///     "Y", "YES", "1", "-1", "T" or "TRUE" converted to true
        ///     "N", "NO", "0", "F" or "FALSE" converted to false
        ///     
        /// Throws format or null reference, exception if value can't be converted.
        /// </summary>
        /// <param name="value">String value to convert</param>
        /// <returns>parsed bool</returns>
        public static bool PharmacyParse(string value)
        {
            // value = value.ToUpper(); 01Nov13 moved to below check for if null

            if (value == null)
                throw new NullReferenceException();

            value = value.ToUpper();
            if (TrueStrings.Contains(value))
                return true;
            else if (FalseStrings.Contains(value))
                return false;
            else
            {
                string error = string.Format("Can't convert {0} to bool.", value);
                throw new FormatException(error);
            }
        }

		/// <summary>
        /// Converts a string to a bool  (case insensitive)
        ///     "Y", "YES", "1", "-1", "T" or "TRUE" converted to true
        ///     "N", "NO", "0", "F" or "FALSE" converted to false
        ///     
        /// Else returns null
        /// </summary>
        /// <param name="value">String value to convert</param>
        public static bool? PharmacyParseOrNull(string value)
        {
            if (value == null)
                return null;

            value = value.ToUpper();
            if (TrueStrings.Contains(value))
                return true;
            else if (FalseStrings.Contains(value))
                return false;
            else
                return null;
        }

		/// <summary>
        /// Converts a string to a bool (case insensitive)
        ///     "Y", "YES", "1", "-1", "T" or "TRUE" converted to true
        ///     "N", "NO", "0", "F" or "FALSE" converted to false
        ///     
        /// A return value indicates whether the conversion succeeded or failed.
        /// </summary>
        /// <param name="value">String value to convert</param>
        /// <returns>parsed bool</returns>
        public static bool TryPharmacyParse(string value, out bool boolValue)
        {
            try
            {
                boolValue = BoolExtensions.PharmacyParse(value);
                return true;
            }
            catch (Exception )
            {
                boolValue = false;
                return false;
            }
        }
	    #endregion    
    }
}
