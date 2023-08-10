//===========================================================================
//
//							    PatternMatch.cs
// Used to test a string against a specific pattern mask.
//
// This is legacy cocde imported from the vb6 code (warts and all), 
// and should probably not be used for new patterns
// 
// Valid pattern mask characters are
//     *   matches any character, including space at that position
//     A   matches upper and lower case A to Z
//     B   matches any alphabetic character upper & lower case plus space
//     X   matches upper & lower case A to Z plus 0 to 9
//     9   matches 0 to 9
//     0   matches 0 to 9 and/or decimal point
//     .   matches a decimal point only
//     ' ' (ie one space) matches optional spaces at the end of string (only valid at the end of string)
//     
// If last char in string to PatternMatch a space then don't trim
// If pattern is empty string or null, then all characters and lengths are unconditionally valid
//
// The class also provides access to common patterns read from WConfiguration.D|STKMAINT.Data
// 
// Usage   
// Specify valid sequence of letters and numbers & optional trailing spaces
//     NSV code Pattern is 'AAA999A'
//     for New Zealand set Pattern to '999999 '
//
//	Modification History:
//	21Dec09 XN  Written
//  05Aug10 XN  Added EqualsNoCase, EqualsNoCaseTrimEnd as useful when dealing
//              with pharmacy data.
//  15Mar10 XN  Updated SafeSubstring so does not assert if 
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ascribe.pharmacy.shared
{
    /// <summary>
    /// Used to test a string against a specific pattern mask (see file header for more info)
    /// This is legacy cocde imported from the vb6 code (warts and all), and should probably not be used for new patterns.
    /// </summary>
    public static class PatternMatch
    {
        /// <summary>Returns the NSV code pattern (normally AAA999A). Empty string is setting does not exist.</summary>
        public static string NSVCodePattern
        {
            get 
            {
                string   config = WConfigurationController.LoadAndCache<string>("D|STKMAINT", "Data", "9", ",,,,,", false);
                string[] values = config.Split(',');
                if (values.Length < 6)
                    throw new ApplicationException("System Configuration Error:\r\nNSV code definition in WConfiguration.D|STKMAINT.Data.9 is invalid '" + config + "'");
                return values[5];
            }
        }

        /// <summary>
        /// Returns the Lookup code pattern (normally AAAA9999). 
        /// When testing lookup code pattern with PatternMatch.Validate trim the pattern to the length of test string (min 3 chars)
        ///             PatternMatch.Validate(value, PatternMatch.LookupCodePattern.SafeSubString(0, Math.Max(value.Length, 3)))
        /// Empty string is setting does not exist.
        /// </summary>
        public static string LookupCodePattern
        {
            get 
            {
                string   config = WConfigurationController.LoadAndCache<string>("D|STKMAINT", "Data", "1", ",,,,,", false);
                string[] values = config.Split(',');
                if (values.Length < 6)
                    throw new ApplicationException("System Configuration Error:\r\nNSV code definition in WConfiguration.D|STKMAINT.Data.1 is invalid '" + config + "'");
                return values[5];
            }
        }

        /// <summary>Returns the Local product code pattern (e.g. AAAAAAA). Empty string is setting does not exist.</summary>
        public static string LocalProductCodePattern
        {
            get 
            {
                string   config = WConfigurationController.LoadAndCache<string>("D|STKMAINT", "Data", "72", ",,,,,", false);
                string[] values = config.Split(',');
                if (values.Length < 6)
                    throw new ApplicationException("System Configuration Error:\r\nNSV code definition in WConfiguration.D|STKMAINT.Data.72 is invalid '" + config + "'");
                return values[5];
            }
        }

        /// <summary>Compares the string againts the pattern (see class summary info)</summary>
        /// <param name="value">string to test</param>
        /// <param name="pattern">Pattern to use</param>
        /// <returns>If string is valid</returns>
        public static bool Validate(string value, string pattern)
        {
            // Handle nulls as empty string
            value   = value   ?? string.Empty;
            pattern = pattern ?? string.Empty;

            // check is pattern contains optional space in the sttring
            if (pattern.TrimEnd().Contains(' '))
                throw new ApplicationException("System Configuration Error:\r\nPatternMatch called with pattern '" + pattern + "' containing embedded space(s)");

            // If pattern is empty the value is assumed to be valid
            // This seems strange, but it directly represents what happens in the old vb6 code, and works with rest of system
            if (string.IsNullOrEmpty(pattern))
                return true;

            // If value length is smaller or greater than pattern length (excluding optional spaces)
            // Test here to prevent argument out of range exception
            if ((value.Length < pattern.TrimEnd().Length) || (pattern.Length < value.Length))
                return false;

            int index = 0;
            for (index = 0; index < pattern.Length; index++)
            {
                switch (pattern[index])
                {
                case '*': break;   // Again seems incorrect, but it directly represnets what happens in old vb6 code (despite what it says in comment)
                case 'A': if (!char.IsLetter(value, index))                                 { return false; }; break;
                case 'B': if (!char.IsLetter(value, index)  && (value[index] != ' '))       { return false; }; break;
                case 'X': if (!char.IsLetter(value, index)  && !char.IsDigit(value, index)) { return false; }; break;
                case '9': if (!char.IsDigit (value, index))                                 { return false; }; break;
                case '0': if (!char.IsDigit (value, index)  && (value[index] != '.'))       { return false; }; break;
                case '.': if (value[index] != '.')                                          { return false; }; break;
                case ' ': if ((value.Length > index) && (value[index] != ' '))              { return false; }; break;
                default:
                    throw new ApplicationException("System Configuration Error:\r\nPatternMatch called with pattern of '" + pattern + "'\r\nInvalid pattern character '" + pattern[index] + "'");
                }
            }

            return true;    // All okay
        }
    }
}
