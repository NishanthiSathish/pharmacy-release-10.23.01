//===========================================================================
//
//							     DateTimeExtensions.cs
//
//  Provides extension methods for the DateTime data type
//
//  Usage:
//  
//  DateTime dt = new DateTime(2009, 07, 21, 14, 45);
//  dt.ToPharmacyDateTimeString() returns the string "21/07/2009 14:45"
//  
//	Modification History:
//	21Jul09 XN  Written
//  20Jun11 XN  Added method ToStartOfDay F0086605
//  24Jun11 XN  Added methods PharmacyParse, Overlap
//  25Oct11 XN  Fixed error in PharmacyParse
//  15May13 XN  Added ToEndOfDay method (27038)
//  02Aug13 XN  Added Max method 24653
//  05Jul13 XN  Added JavascriptParse method 27252
//  27Jun14 XN  Added DateTimeExtensions.PharmacyEpoch 43318
//  15Aug16 XN  159843 Added GetAgeStr, and GetAgeStr
//===========================================================================
using System;
using System.Globalization;
using System.Text;

namespace ascribe.pharmacy.shared
{
    public static class DateTimeExtensions
    {
        #region Constants
        public const string ShortDatePattern = "dd/MM/yyyy";   // Format for pharmacy date to string convert
        public const string TimePattern      = "HH:mm";        // Format for pharmacy time to string convert

        /// <summary>Represents the minimum valid SQL date time value.</summary>
        public static readonly DateTime MinDBValue = new DateTime(1753, 1, 1, 0, 0, 0);

        /// <summary>Represents the maximum valid SQL date time value.</summary>
        public static readonly DateTime MaxDBValue = new DateTime(9999, 12, 31, 23, 59, 59, 997);

        /// <summary>DB datetime epoch 30/12/1899 stored in the db in certain parts of pharamcy 27Jun14 XN 43318</summary>
        public static readonly DateTime PharmacyEpoch = new DateTime(1899,12,30,0,0,0,0);
        #endregion

        #region Extension methods
        /// <summary>
        /// Converts value to pharmacy standard format date string (as dd/MM/yyyy).
        /// null value return's an empty string.
        /// </summary>
        /// <param name="value">value to convert</param>
        /// <returns>pharmacy formatted date string</returns>
        public static string ToPharmacyDateString(this DateTime value)
        {
            return value.ToString(ShortDatePattern);
        }
        public static string ToPharmacyDateString(this DateTime? value)
        {
            if (value.HasValue)
                return value.Value.ToPharmacyDateString();
            else
                return string.Empty;
        }

        /// <summary>
        /// Converts value to pharmacy standard format time string (as HH:mm).
        /// null value return's an empty string.
        /// </summary>
        /// <param name="value">value to convert</param>
        /// <returns>pharmacy formatted time string</returns>
        public static string ToPharmacyTimeString(this DateTime value)
        {
            return value.ToString(TimePattern);
        }
        public static string ToPharmacyTimeString(this DateTime? value)
        {
            if (value.HasValue)
                return value.Value.ToPharmacyTimeString();
            else
                return string.Empty;
        }

        /// <summary>
        /// Converts value to pharmacy standard format datetime string (as dd/MM/yyyy HH:mm).
        /// null value return's an empty string.
        /// </summary>
        /// <param name="value">value to convert</param>
        /// <returns>pharmacy formatted datetime string</returns>
        public static string ToPharmacyDateTimeString(this DateTime value)
        {
            return value.ToString(ShortDatePattern + " " + TimePattern);
        }
        public static string ToPharmacyDateTimeString(this DateTime? value)
        {
            if (value.HasValue)
                return value.Value.ToPharmacyDateTimeString();
            else
                return string.Empty;
        }

        /// <summary>
        /// Returns date\time to start of the day
        /// e.g 23/04/2010 17:45:30 to 23/04/2010 00:00:00     
        /// </summary>
        /// <param name="value">Value to converts</param>
        /// <returns>Returns date\time to start of the day (or null if pass in null)</returns>
        public static DateTime ToStartOfDay(this DateTime value)
        {
            return value.Date;
        }
        public static DateTime? ToStartOfDay(this DateTime? value)
        {
            return (value.HasValue) ? (DateTime?)value.Value.Date : null;
        }

        /// <summary>
        /// Returns date\time to end of the day
        /// e.g 23/04/2010 17:45:30 to 23/04/2010 24:59:59.999
        /// </summary>
        /// <param name="value">Value to converts</param>
        /// <returns>Returns date\time to end of the day (or null if pass in null)</returns>
        public static DateTime ToEndOfDay(this DateTime value)
        {
            return value.Date.AddDays(1).AddTicks(-1);
        }
        public static DateTime? ToEndOfDay(this DateTime? value)
        {
            return (value.HasValue) ? (DateTime?)value.Value.Date.AddDays(1).AddTicks(-1) : null;
        }

        /// <summary>Returns the min of a or b</summary>
        public static DateTime Min(DateTime a, DateTime b)
        {
            return a < b ? a : b;
        }
	    
        /// <summary>Returns the max of a or b</summary>
        public static DateTime Max(DateTime a, DateTime b)
        {
            return a > b ? a : b;
        }

        /// <summary>Returns the patient's age formatted according to NHS guidance 159843 15Aug16 XN</summary>
        /// <param name="dob">dob</param>
        /// <param name="asOfDate">Of date</param>
        public static string GetAgeStr(this DateTime? dob, DateTime asOfDate)
        {
            return dob == null ? string.Empty : dob.Value.GetAgeStr(asOfDate);
        }

        /// <summary>Returns the patient's age formatted according to NHS guidance 159843 15Aug16 XN</summary>
        /// <param name="dob">dob</param>
        /// <param name="asOfDate">Of date</param>
        public static string GetAgeStr(this DateTime dob, DateTime asOfDate)
        {
            var ageSpan = asOfDate - dob;

            int years  = (dob.AddMilliseconds(ageSpan.TotalMilliseconds).Year - dob.Year);
            int months = (asOfDate.Month - dob.Month);

            // Subtract a month if the day is not yet passed
            if (asOfDate.Day < dob.Day)
                months -= 1;

            //If it is -1 then it should be 11 months
            if (months < 0)
                months = 12 + months;

            // Subtract a year if the birthday is not yet passed
            if (dob.Month > asOfDate.Month || (dob.Month == asOfDate.Month && dob.Day > asOfDate.Day))
                years -= 1;

            int totalMonths = (int)Math.Floor(months + (years * 12.0));
            int totalWeeks  = (int)Math.Floor(ageSpan.TotalDays / 7);

            StringBuilder ageStr = new StringBuilder();
            if (years >= 18)
                ageStr.AppendFormat("{0}y", years);
            else if (years >= 2)
                ageStr.AppendFormat("{0}y {1}m", years, months);
            else if (years >= 1)
            {
                var daysForMonths = asOfDate.Day - dob.Day;
                if (daysForMonths < 0)
                    daysForMonths = DateTime.DaysInMonth(asOfDate.Year, (asOfDate.Month - 1) == 0 ? 12 : asOfDate.Month - 1) - dob.Day + asOfDate.Day;
                ageStr.AppendFormat("{0}m {1}d", months + years * 12, daysForMonths);
            }
            else if (totalWeeks >= 4)
            {
                var daysForTotalWeeks = (int)Math.Floor(ageSpan.TotalDays - (totalWeeks * 7));
                ageStr.AppendFormat("{0}w {1}d", totalWeeks, daysForTotalWeeks);
            }
            else
                ageStr.AppendFormat("{0}d", (int)Math.Floor(ageSpan.TotalDays));

            return ageStr.ToString();
        }
        #endregion   

        #region Static Methods
        /// <summary>Converts a string created using ToPharmacyDateString, ToPharmacyTimeString or ToPharmacyDateTimeString to a date time value.</summary>
        /// <param name="value">string created using ToPharmacyDateString, ToPharmacyTimeString or ToPharmacyDateTimeString</param>
        /// <returns>Converted datetime (or null if string is null or empty)</returns>
        public static DateTime? PharmacyParse(string value)
        {
            IFormatProvider formatProvider = CultureInfo.CurrentCulture;
            DateTime result;

            // If nothing to convert return null
            if (string.IsNullOrEmpty(value))
                return null;

            // Split string at space so have date and time part
            string[] parts = value.Split(new char[] {' '}, StringSplitOptions.RemoveEmptyEntries);
            if ((parts.Length == 0) || (parts.Length > 2))
                throw new FormatException();

            // And convert
            if (parts.Length == 2)
                result = DateTime.ParseExact(parts[0], ShortDatePattern, CultureInfo.CurrentCulture) + DateTime.ParseExact(parts[1], TimePattern, CultureInfo.CurrentCulture).TimeOfDay;
            else if (parts[0].Length > TimePattern.Length)
                result = DateTime.ParseExact(parts[0], ShortDatePattern, CultureInfo.CurrentCulture);
            else
                result = DateTime.ParseExact(parts[0], TimePattern, CultureInfo.CurrentCulture);

            return result;
        }

        /// <summary>
        /// Converts a string created with Javascript eg new Date().toString() to a C# string
        /// Java script output the string in format like Tue Jul 12 16:00:00 GMT-0700 2011 
        /// 05Jul13 XN added 27252
        /// </summary>
        /// <returns>Converted datetime (or null if string is null or empty)</returns>
        public static DateTime? JavascriptParse(string value)
        {
            // If nothing to convert return null
            if (string.IsNullOrEmpty(value))
                return null;

            return DateTime.ParseExact(value, "ddd MMM d HH:mm:ss UTCzzz yyyy", CultureInfo.CurrentCulture);
        }

        /// <summary>
        /// Returns true if ranges overlap
        /// If one of the time ranges is a specific time point (rather than a range) then put start datetime equal to enddate
        /// </summary>
        public static bool Overlap(DateTime start1, DateTime end1, DateTime start2, DateTime end2, bool includeEquals)
        {
            if (includeEquals)
                return !((end1 <  start2) || (end2 <  start1));
            else
                return !((end1 <= start2) || (end2 <= start1));
        }
        #endregion
    }
}
