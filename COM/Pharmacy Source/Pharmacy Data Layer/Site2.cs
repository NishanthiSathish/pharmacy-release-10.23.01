//===========================================================================
//
//							        Site2.cs
//
//  Provides access to Site table. 
//  This class replaces Sites, and SiteProcessor (bussiness layer)
//
//  All data in the class is cached so don't call directly instread use Site2.Instance()
//
//  Has function (Site2.GetDSSMasterSiteBySiteID) to get DSSMasterSite id (from DSSMasterSiteLinkSite table)
//
//  Provides access to the MasterSiteNumber held in the settings table, this 
//  site number is the site designated as the main site (function Site2.GetMasterSiteNumber)
//
//  Only supports reading from table.
//
//  Usage
//  Get a particular site by ID
//  Site2Row site = Site2.Instance().FindBySiteID(24);
//
//  Get a site ID by number
//  int siteID = Site2.GetSiteNumberByID(502);
//
//  Get list of all valid site names
//  var allSiteNames = Site2.Instance().ValidOnly().OrderBySiteNumber().Select(s => s.ToString());
//  
//	Modification History:
//	24Mar14 XN  Written
//  08Jun15 XN  119361 Added FindSiteIDByNumber, FindSiteNumberByID, and FindBySiteNumber to Site2EnumerableExtensions
//  17Jun15 XN  117765 Added CurrentSiteHandling
//  15Apr16 XN  123082 Added IsSingleUserOnly
//===========================================================================
namespace ascribe.pharmacy.pharmacydatalayer
{
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

    /// <summary>How the FindBySiteNumber method handles current site XN 17Jun15 117765</summary>
    public enum CurrentSiteHandling
    {
        /// <summary>Leave current site to where it is currently in the list</summary>
        NoChange,

        /// <summary>Place the current site a the start of the list, even if does not exist in list of sites</summary>
        AtStart,

        /// <summary>Remove current site from the list</summary>
        Remove
    }

    /// <summary>Information for a site (replaces Site and SiteRow)</summary>
    public class Site2Row : BaseRow
    {
        #region Public Properties
        public int SiteID       { get { return FieldToInt(RawRow["LocationID"]).Value; }    }
        public int SiteNumber   { get { return FieldToInt(RawRow["SiteNumber"]).Value; }    }

        /// <summary>
        /// Abbreviated name that one site known another site by
        /// Read from config D|Siteinfo..Hospabs (or AccountName if not present)
        /// </summary>
        public string LocalHospitalAbbreviation { get { return GetExtraField("LocalHospitalAbbreviation"); } }

        /// <summary>
        /// Abbreviated name for the hospital (from WConfiguration)
        /// Read from D|SITEINFO..ASC
        /// </summary>
        public string AbbreviatedName { get { return GetExtraField("AbbreviatedName"); } }

        /// <summary>
        /// Full name for the hospital (from WConfiguration)
        /// Read from D|SITEINFO..ASC
        /// </summary>
        public string FullName { get { return GetExtraField("FullName"); } }

        /// <summary>
        /// Account name for site 
        /// Read from D|SITEINFO..ASC
        /// </summary>
        public string AccountName { get { return GetExtraField("AccountName"); } }

        /// <summary>
        /// Returns if this is a single user site only
        /// Read from D|SITEINFO..ASC
        /// </summary>
        public bool IsSingleUserOnly { get { return BoolExtensions.PharmacyParseOrNull(GetExtraField("IsSingleUserOnly")) ?? false; } }

        /// <summary>
        /// Returns if extra fields have been loaded for this row
        /// 18May15 XN 117528
        /// </summary>
        private bool LoadedExtraFields
        {
            get
            {
                if (this.RawRow.Table.Columns.Contains("LoadedExtraFields"))
                {
                    return this.FieldToBoolean(this.RawRow["LoadedExtraFields"]) ?? false;
                }
                else 
                {
                    return false;
                }
            }
        }
        #endregion

        #region Public Methods
        /// <summary> 
        /// Returns site full name string in form 
        ///     {full name|abbreviated name} {account name} - {site number}
        /// </summary>
        public string ToFullNameString()
        {
            string name = string.IsNullOrEmpty(this.FullName) ? this.AbbreviatedName : this.FullName;
            return string.Format("{0} {1} - {2:000}", name, this.AccountName, this.SiteNumber);
        }

        /// <summary>Returns site name in {site number} - {localHospitalAbbreviation}</summary>
        public override string ToString()
        {
            return string.Format("{0:000} - {1}", this.SiteNumber, this.LocalHospitalAbbreviation);
        }

        /// <summary>Returns site number as sting (formatted to 3 digits)</summary>
        public string ToSiteNumberString()
        {
            return string.Format("{0:000}", this.SiteNumber);
        }
        #endregion
    
        #region Private Properties
        /// <summary>Gets extra fields value (load data if not present used for FullName, AccountName, etc)</summary>
        private string GetExtraField(string fieldName)
        {
            if (!this.LoadedExtraFields)
                LoadExtraFields();

            return this.RawRow[fieldName] as string;
        }

        /// <summary>Sets extra fields value, add column if needed (used for FullName, AccountName, etc)</summary>
        private void SetExtraField(string fieldName, Type type, object value)
        {
            if (!this.RawRow.Table.Columns.Contains(fieldName))
                this.RawRow.Table.Columns.Add(fieldName, type);
            this.RawRow[fieldName] = value;
        }

        /// <summary>Load in all the extra field values</summary>
        private void LoadExtraFields()
        {
            string   siteInfo      = WConfiguration.Load<string>(SiteID, "D|SITEINFO", string.Empty, "ASC", string.Empty, false);
            string[] siteInfoItems = new string[0];

            // Split out all the information
            if (!string.IsNullOrEmpty(siteInfo))
                siteInfoItems = EncryptionAlgorithms.DecodeHex(siteInfo).Split('|');

            // Retrive the information into site
            SetExtraField("AbbreviatedName", typeof(string), (siteInfoItems.Length >= 2) ? siteInfoItems[1].Trim() : string.Empty);
            SetExtraField("FullName",        typeof(string), (siteInfoItems.Length >= 3) ? siteInfoItems[2].Trim() : string.Empty);
            SetExtraField("AccountName",     typeof(string), (siteInfoItems.Length >= 4) ? siteInfoItems[3].Trim() : string.Empty);
            SetExtraField("IsSingleUserOnly",typeof(bool),   BoolExtensions.PharmacyParseOrNull((siteInfoItems.Length >= 5) ? siteInfoItems[4].Trim() : string.Empty) ?? false);

            // Get the local (current) sites abbreviated name for the site
            // Using configuration value 
            //      Category:D|SITEINFO 
            //      section: 
            //      Keys: Sitenumbers and Hospabs
            // First get config for site numbers for the current site, and lookup the site in this list
            // Then match that site against the Hospabs config (again for current site)
            int currentSiteID       = SessionInfo.HasSite ? SessionInfo.SiteID : Site2.GetSiteIDByNumber(Site2.GetMasterSiteNumber(true));
            var siteNumbers         = WConfiguration.LoadAndCache<string>(currentSiteID, "D|SITEINFO", string.Empty, "Sitenumbers", string.Empty, false).ParseCSV<int>   (",", true).ToList();
            int index               = siteNumbers.IndexOf(this.SiteNumber);
            var siteAbbreviations   = WConfiguration.LoadAndCache<string>(currentSiteID, "D|SITEINFO", string.Empty, "Hospabs",     string.Empty, false).ParseCSV<string>(",", true).ToList();
            string localHospitalAbbreviation = (siteAbbreviations.Count > index && index >= 0) ? siteAbbreviations[index] : this.RawRow["AccountName"] as string;
            SetExtraField("LocalHospitalAbbreviation", typeof(string), localHospitalAbbreviation);

            // MarkData as loaded
            SetExtraField("LoadedExtraFields", typeof(bool), true);
        }
        #endregion
    }

    /// <summary>ColumnInfo from site table</summary>
    public class Site2ColumnInfo : BaseColumnInfo
    {
        public Site2ColumnInfo() : base("Site") { }
    }

    /// <summary>
    /// Represents the Site table (replaces Sites and SiteProcessor)
    /// All data in the class is cached so don't call directly instread use Site2.Instance()
    /// </summary>
    public class Site2 : BaseTable2<Site2Row, Site2ColumnInfo>
    {
        /// <summary>Prevents a default instance of the <see cref="Site2"/> class from being created.</summary>
        private Site2() : base("Site", "LocationID") { }

        #region Public Static Methods
        /// <summary>Returns single instance of this class</summary>
        public static Site2 Instance()
        {
            string cacheName = typeof(Site2).FullName + ".GetInstance";

            // get cached data
            Site2 cacheData = PharmacyDataCache.GetFromCache(cacheName) as Site2;
            if (cacheData == null)
            {
                // Load
                cacheData = new Site2();
                cacheData.LoadAll();

                // Save back to cache
                PharmacyDataCache.SaveToCache(cacheName, cacheData);
            }

            return cacheData;
        }

        /// <summary>
        /// Returns SiteID for the site number (else returns 0 if invalid siteNumber)
        /// (08Jun15 XN 119361 Updated to use Site2EnumerableExtensions.FindSiteIDByNumber)
        /// </summary>
        /// <param name="siteNumber">Site number to find</param>
        /// <returns>SiteID or 0</returns>
        public static int GetSiteIDByNumber(int siteNumber)
        {
            return Site2.Instance().FindSiteIDByNumber(siteNumber);
        }

        /// <summary>
        /// Returns site number for the siteID (else returns 0 if invalid siteNumber)
        /// (08Jun15 XN 119361 Updated to use Site2EnumerableExtensions.FindSiteNumberByID)
        /// </summary>
        /// <param name="siteId">SiteID to find</param>
        /// <returns>Site Number or 0</returns>
        public static int GetSiteNumberByID(int siteId)
        {
            return Site2.Instance().FindSiteNumberByID(siteId);
        }

        /// <summary>
        /// Returns master site number defined by setting
        /// System: Pharmacy
        /// Section: General
        /// Key: MasterSiteNumber
        /// 
        /// If setting is not set and defaultToAny is true, returns first site number
        /// </summary>
        /// <param name="defaultToAny">If setting is not set will then return first site number (else will assert)</param>
        public static int GetMasterSiteNumber(bool defaultToAny)
        {            
            string cacheName = typeof(Site2).FullName + ".GetMasterSiteNumber[" + defaultToAny.ToString() + "]";

            int? siteNumber = PharmacyDataCache.GetFromCache(cacheName) as int?;
            if (siteNumber == null)
            {
                // Read the master site number (from settings table)
                siteNumber = SettingsController.Load<int?>("Pharmacy", "General", "MasterSiteNumber", null);
                if (siteNumber == null && defaultToAny)
                    siteNumber = Site2.Instance().ValidOnly().OrderBySiteNumber().First().SiteNumber;   // If not in settings table then get first in list

                if (siteNumber == null)
                    throw new ApplicationException("No master site set (Setting Pharmacy.General.MasterSiteNumber)");

                // save back to cache
                PharmacyDataCache.SaveToCache(cacheName, siteNumber);
            }

            return siteNumber.Value;
        }

        /// <summary>
        /// Returns DSS Master site Number from table DSSMasterSiteLinkSite 
        /// (returns 0 if site does not exist in DSSMasterSiteLinkSite table)
        /// </summary>
        public static int GetDSSMasterSiteBySiteID(int siteID)
        {
            string cacheName = typeof(Site2).FullName + ".GetDSSMasterSiteBySiteID";

            var siteIDToDSSMasterSite = PharmacyDataCache.GetFromCache(cacheName) as IDictionary<int,int>;
            if (siteIDToDSSMasterSite == null)
            {
                // Load values from DSSMasterSiteLinkSite
                GenericTable2 DSSMasterSiteLinkSite = new GenericTable2();
                List<SqlParameter> parameters = new List<SqlParameter>();
                DSSMasterSiteLinkSite.LoadBySQL("SELECT SiteID, DSSMasterSiteID FROM DSSMasterSiteLinkSite", parameters);
                siteIDToDSSMasterSite = DSSMasterSiteLinkSite.ToDictionary(k => (int)k.RawRow["SiteID"], v => (int)v.RawRow["DSSMasterSiteID"]);

                // save back to cahce
                PharmacyDataCache.SaveToCache(cacheName, siteIDToDSSMasterSite);
            }

            // return value or 0 if value not presnet
            return siteIDToDSSMasterSite.ContainsKey(siteID) ? siteIDToDSSMasterSite[siteID] : 0;
        }
        #endregion

        #region Private Methods
        /// <summary>Returns all sites for the site table</summary>
        private void LoadAll()
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            LoadBySP("pSiteLoadAll", parameters);
        }
        #endregion
    }

    public static class Site2EnumerableExtensions
    {
        public static Site2Row FindBySiteNumber(this IEnumerable<Site2Row> sites, int siteNumber)
        {
            return sites.FirstOrDefault(s => s.SiteNumber == siteNumber);
        }

        /// <summary>
        /// Returns list of site info by site number
        /// Ensured it keeps correct order 08Jun15 XN 119361 
        /// </summary>
        /// <param name="sites">List of sites</param>
        /// <param name="siteNumbers">List of site numbers</param>
        /// <returns>list of site info</returns>
        public static IEnumerable<Site2Row> FindBySiteNumber(this IEnumerable<Site2Row> sites, IEnumerable<int> siteNumbers)
        {
            return siteNumbers.Select(s => sites.FindBySiteNumber(s)).Where(s => s != null);
        }
        
        /// <summary>
        /// Returns site info for CSV list of site numbers
        /// Optionally if siteNumbersStr="All" the returns all sites
        /// 08Jun15 XN 119361 
        /// </summary>
        /// <param name="sites">List of sites</param>
        /// <param name="siteNumbersStr">CSV list of site numbers (or all)</param>
        /// <param name="allowAll">If to convert all to list of all sites</param>
        /// <param name="currentSite">Determines how the current site is handled</param>
        /// <returns>sites list</returns>
        public static IEnumerable<Site2Row> FindBySiteNumber(this IEnumerable<Site2Row> sites, string siteNumbersStr, bool allowAll = false, CurrentSiteHandling currentSite = CurrentSiteHandling.NoChange)
        {
            List<Site2Row> results;
            if (allowAll && siteNumbersStr.EqualsNoCaseTrimEnd("All"))
            {
                // All sites so return all
                results = sites.ValidOnly().OrderBySiteNumber().ToList();
            }
            else
            {
                // Convert CSV string, and add current site to start if needed
                List<int> siteNumbers = (siteNumbersStr ?? string.Empty).ParseCSV<int>(",", ignoreErrors: true).Distinct().ToList();
                results = sites.ValidOnly().FindBySiteNumber(siteNumbers).ToList();
            }

            // Remove current site from list
            if (currentSite != CurrentSiteHandling.NoChange && SessionInfo.HasSite)
            {
                int siteNumber = SessionInfo.SiteNumber;
                results.RemoveAll(s => s.SiteNumber == siteNumber);
            }

            // Add current site to start of list
            if (currentSite == CurrentSiteHandling.AtStart && SessionInfo.HasSite)
            {
                results.Insert(0, sites.FindBySiteNumber(SessionInfo.SiteNumber));
            }

            return results;
        }

        public static Site2Row FindBySiteID(this IEnumerable<Site2Row> sites, int siteID)
        {
            return sites.FirstOrDefault(s => s.SiteID == siteID);
        }

        /// <summary>
        /// Returns list of site info by site ID
        /// Ensured it keeps correct order 08Jun15 XN 119361 
        /// </summary>
        /// <param name="sites">List of sites</param>
        /// <param name="siteIDs">List of site IDs</param>
        /// <returns>list of site info</returns>
        public static IEnumerable<Site2Row> FindBySiteID(this IEnumerable<Site2Row> sites, IEnumerable<int> siteIDs)
        {
            return siteIDs.Select(s => sites.FindBySiteID(s)).Where(s => s != null);
        }

        /// <summary>Returns SiteID for the site number (else returns 0 if invalid siteNumber)</summary>
        /// <param name="sites">List of sites</param>
        /// <param name="siteNumber">Site number to find</param>
        /// <returns>SiteID or 0</returns>
        public static int FindSiteIDByNumber(this IEnumerable<Site2Row> sites, int siteNumber)
        {            
            Site2Row site = sites.FirstOrDefault(s => s.SiteNumber == siteNumber);
            return site == null ? 0 : site.SiteID;
        }

        /// <summary>Returns site number for the siteID (else returns 0 if invalid siteNumber)</summary>
        /// <param name="sites">List of sites</param>
        /// <param name="siteId">SiteID to find</param>
        /// <returns>Site Number or 0</returns>
        public static int FindSiteNumberByID(this IEnumerable<Site2Row> sites, int siteId)
        {
            Site2Row site = sites.FirstOrDefault(s => s.SiteID == siteId);
            return site == null ? 0 : site.SiteNumber;
        }

        public static IEnumerable<Site2Row> ValidOnly(this IEnumerable<Site2Row> sites)
        {
            return sites.Where(s => s.SiteID != 0 &&  s.SiteNumber != null);
        }

        public static IEnumerable<Site2Row> OrderBySiteNumber(this IEnumerable<Site2Row> sites)
        {
            return sites.OrderBy(s => s.SiteNumber);
        }
    }
}
