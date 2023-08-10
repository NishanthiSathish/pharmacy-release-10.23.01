//===========================================================================
//
//							   PharmacyCultureInfo.cs
//
//  Provides culture specific pharmacy information, these can be accessed as 
//  static methods on the class.
//
//  Most of the class data comes from the WConfiguration table, and is stored
//  to the response cache.
//
//  Usage:
//  PharmacyCultureInfo.CountryCode             - Returns default country code for current site
//  PharmacyCultureInfo.CurrencySymbol          - returns currency symbol e.g. £, or $
//  PharmacyCultureInfo.SalesTaxName            - returns word for sales tax e.g. 'VAT' or 'GST'
//  PharmacyCultureInfo.CurrencyHundredth       - returns word for hundredth of monetary value e.g. 'penny' or 'cent'
//  PharmacyCultureInfo.CurrencyHundredths      - returns word for hundredths of monetary value e.g. 'pence' or 'cents'
//  PharmacyCultureInfo.NHSNumberDisplayName    - Country equivalent of NHS Number 
//  PharmacyCultureInfo.CaseNumberDisplayName   - Hospital specific name for case number
//  PharmacyCultureInfo.GetCountryCode          - returns default country code for a site
//  PharmacyCultureInfo.GetLanguageName         - returns language name for site (not cached)
//
//	Modification History:
//	21Jul09 XN  Written
//  05Jul13 XN  27252 Added methods CurrencyHundredth, CurrencyHundredths,
//              NHSNumberDisplayName and CaseNumberDisplayName
//  23Apr14 XN  Added method GetCountryCode, and updated CountryCode to use the method 88858
//              Changed country code to be read from WConfiguration.Key='LanguageCodes' instead of 'CountryCode' 
//  25Sep15 XN  Fixed CaseNumberDisplayName
//===========================================================================
using System.Globalization;
using System.Linq;

namespace ascribe.pharmacy.shared
{
    public class PharmacyCultureInfo
    {
        /// <summary>UK Country code 044    23Apr14 XN</summary>
        public const int UKCountryCode = 044;

        /// <summary>Gets the pharmacy country code for the site e.g. 044</summary>
        public static int CountryCode 
        { 
            get { return GetCountryCode(SessionInfo.SiteID); }
        }
        //public static int CountryCode     23Apr14 XN  updated CountryCode to GetCountryCode 88858
        //{ 
        //    get
        //    {
        //        string cachedName = string.Format("{0}.CountryCode", typeof(PharmacyCultureInfo).FullName);
        //
        //        // First try to read from cache
        //        object returnValue = PharmacyDataCache.GetFromContext(cachedName);
        //        if ( returnValue == null )
        //        {
        //            // Not in cache so read from database
        //            returnValue = WConfigurationController.LoadASetting(SessionInfo.SiteID, "D|SITEINFO", "", "Country", "044", false, typeof(int));
        //            PharmacyDataCache.SaveToContext(cachedName, returnValue);
        //        }
        //
        //        return (int)returnValue;
        //    }
        //}

        /// <summary>Gets the currency symbol used by the current site e.g. £ or $</summary>
        public static string CurrencySymbol
        { 
            get
            {
                string cachedName = string.Format("{0}.CurrencySymbol", typeof(PharmacyCultureInfo).FullName);

                // First try to read from cache
                object returnValue = PharmacyDataCache.GetFromContext(cachedName);
                if ( returnValue == null )
                {
                    // Not in cache so read from database
                    returnValue = WConfigurationController.LoadASetting(SessionInfo.SiteID, "A|COUNTRY.", "", "SymbolUnit", CultureInfo.CurrentCulture.NumberFormat.CurrencySymbol, true, typeof(string));
                    PharmacyDataCache.SaveToContext(cachedName, returnValue);
                }

                return (returnValue as string);
            }
        }

        /// <summary>Gets currency text for hundredth of a monetary value e.g. Penny</summary>
        public static string CurrencyHundredth
        { 
            get
            {
                string cachedName = string.Format("{0}.CurrencyHundredth", typeof(PharmacyCultureInfo).FullName);

                // First try to read from cache
                object returnValue = PharmacyDataCache.GetFromContext(cachedName);
                if ( returnValue == null )
                {
                    // Not in cache so read from database
                    returnValue = WConfigurationController.LoadASetting(SessionInfo.SiteID, "A|COUNTRY.", "", "Money/100", "Penny", true, typeof(string));
                    PharmacyDataCache.SaveToContext(cachedName, returnValue);
                }

                return (returnValue as string);
            }
        }

        /// <summary>Gets currency text for hundredths of a monetary value e.g. Pence</summary>
        public static string CurrencyHundredths
        { 
            get
            {
                string cachedName = string.Format("{0}.CurrencyHundredths", typeof(PharmacyCultureInfo).FullName);

                // First try to read from cache
                object returnValue = PharmacyDataCache.GetFromContext(cachedName);
                if ( returnValue == null )
                {
                    // Not in cache so read from database
                    returnValue = WConfigurationController.LoadASetting(SessionInfo.SiteID, "A|COUNTRY.", "", "Money/100s", "Pence", true, typeof(string));
                    PharmacyDataCache.SaveToContext(cachedName, returnValue);
                }

                return (returnValue as string);
            }
        }

        /// <summary>Gets the name for sales tax e.g. 'Tax' or 'GST'</summary>
        public static string SalesTaxName  
        { 
            get
            {
                string cachedName = string.Format("{0}.SalesTaxName", typeof(PharmacyCultureInfo).FullName);

                // First try to read from cache
                object returnValue = PharmacyDataCache.GetFromContext(cachedName);
                if ( returnValue == null )
                {
                    // Not in cache so read from database
                    returnValue = WConfigurationController.LoadASetting(SessionInfo.SiteID, "A|COUNTRY.", "", "SalesTax", "VAT", true, typeof(string));
                    PharmacyDataCache.SaveToContext(cachedName, returnValue);
                }

                return (returnValue as string);
            }
        }

        /// <summary>
        /// Returns the NHS Number display name used by the trust
        /// This is the name that the hospital\country gives the NHS number
        /// </summary>
        public static string NHSNumberDisplayName
        {
            get
            {
                string cachedName = string.Format("{0}.NHSNumberDisplayName", typeof(PharmacyCultureInfo).FullName);

                // First try to read from cache
                object returnValue = PharmacyDataCache.GetFromContext(cachedName);
                if ( returnValue == null )
                {
                    string sql = string.Format("Exec pGetPatientNHSNumberDisplayName {0}", SessionInfo.SessionID);
                    returnValue = Database.ExecuteSQLScalar<string>(sql);
                    PharmacyDataCache.SaveToContext(cachedName, returnValue);
                }

                return (returnValue as string);
            }
        }

        /// <summary>
        /// Returns the CaseNumber display name used by the trust
        /// This is the name that the hospital gives the case number (e.g. 'Hospital Number')
        /// </summary>
        public static string CaseNumberDisplayName
        {
            get
            {
                string cachedName = string.Format("{0}.CaseNumberDisplayName", typeof(PharmacyCultureInfo).FullName);

                // First try to read from cache
                object returnValue = PharmacyDataCache.GetFromContext(cachedName);
                if ( returnValue == null )
                {
                    string sql = string.Format("Exec pGetPatientCaseNumberDisplayName {0}", SessionInfo.SessionID);
                    returnValue = Database.ExecuteSQLScalar<string>(sql);
                    //if (string.IsNullOrEmpty(result))
                    //    returnValue = UKCountryCode;
                    //else
                    //    returnValue = result.ParseCSV<int>(",", true).FirstOrDefault();   Fixed 25Sep15 XN
                    PharmacyDataCache.SaveToContext(cachedName, returnValue);
                }

                return (returnValue as string);
            }
        }

        /// <summary>
        /// Returns default (first) country code for site 
        /// Category: D|SITEINFO
        /// Section:
        /// Key:LanguageCodes
        /// Default: 044
        /// XN 23Apr14 88858
        /// </summary>
        public static int GetCountryCode(int siteID)
        {
            string cachedName = string.Format("{0}.GetCountryCode[{1}]", typeof(PharmacyCultureInfo).FullName, siteID);

            // First try to read from cache
            object returnValue = PharmacyDataCache.GetFromContext(cachedName);
            if ( returnValue == null )
            {
                // Read from DB
                string sql = string.Format("SELECT Value FROM WConfiguration WHERE [Key]='LanguageCodes' AND [Section]='' AND [Category]='D|SITEINFO' AND SiteID={0}", siteID);
                string result = Database.ExecuteSQLScalar<string>(sql);

                // Select first item in list (if present)
                if (!string.IsNullOrEmpty(result))
                    returnValue = TrimQuotes(result).ParseCSV<int?>(",", true).FirstOrDefault();
                
                // Default to UK
                if (returnValue == null)
                    returnValue = UKCountryCode;

                // Save to cache
                PharmacyDataCache.SaveToContext(cachedName, returnValue);
            }

            return (int)returnValue;
        }

        /// <summary>
        /// Returns default (first) language name for site
        /// Category: D|SITEINFO
        /// Section:
        /// Key:LanguageNames
        /// Default: English
        /// XN 23Apr14 88858
        /// </summary>
        public static string GetLanguageName(int siteID)
        {
            // Read from DB
            string sql = string.Format("SELECT Value FROM WConfiguration WHERE [Key]='LanguageNames' AND [Section]='' AND [Category]='D|SITEINFO' AND SiteID={0}", siteID);
            string result = Database.ExecuteSQLScalar<string>(sql);

            // Select first item in list (if present)
            if (!string.IsNullOrEmpty(result))
                result = TrimQuotes(result).ParseCSV<string>(",", true).FirstOrDefault();
                
            // Default to English
            if (string.IsNullOrEmpty(result))
                result = "English";

            return result;
        }

        #region Private Methods
        /// <summary>Removes start and end " from string (if presnet)</summary>
        private static string TrimQuotes(string result)
        {
            if (result.StartsWith("\""))
                result = result.SafeSubstring(1, result.Length);
            if (result.EndsWith("\""))
                result = result.SafeSubstring(0, result.Length - 1);
            return result;
        }
        #endregion
    }
}
