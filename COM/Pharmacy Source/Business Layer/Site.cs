//===========================================================================
//
//							            Site.cs
//
//  These classes hold business logic for handling site data.
//
//	Modification History:
//	22Jul09 XN  Written
//  22Mar11 XN  Added LoadAll method (F0092112)
//  18Dec13 XN  Added LocalHospitalAbbreviation 78339
//===========================================================================
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using System.Collections.Generic;
using System.Linq;

namespace ascribe.pharmacy.businesslayer
{
    /// <summary>Site business object</summary>
    public class Site : IBusinessObject
    {
        public int    SiteID                    { get; set; }
        public int    Number                    { get; set; }
        public string AbbreviatedName           { get; set; }
        public string FullName                  { get; set; }
        public string AccountName               { get; set; }
        
        /// <summary>
        /// Read from config D|Siteinfo..Hospabs
        /// (uses AbbreviatedName if local does not exist)
        /// 18Dec13 XN 78339
        /// </summary>
        public string LocalHospitalAbbreviation { get; set; } 

        /// <summary>
        /// Returns site info in form
        ///     {full name|abbreviated name} {account name} - {site number}
        /// </summary>
        public override string ToString()
        {
            string name = string.IsNullOrEmpty(this.FullName) ? this.AbbreviatedName : this.FullName;
            return string.Format("{0} {1} - {2:000}", name, this.AccountName, this.Number);
        }
    }

    /// <summary>Site business processor</summary>
    public class SiteProcessor : BusinessProcess
    {
        /// <summary>
        /// Gets the site number by id
        /// </summary>
        /// <param name="siteID">site ID</param>
        /// <returns>Site number</returns>
        public static int GetNumberBySiteID (int siteID)
        {
            return Sites.GetNumberBySiteID(siteID);
        }

        /// <summary>
        /// Gets the site id by number
        /// </summary>
        /// <param name="siteID">site number</param>
        /// <returns>Site id</returns>
        public static int GetSiteIDByNumber (int number)
        {
            return Sites.GetSiteIDByNumber(number);
        }

        /// <summary>
        /// Loads in the site by ID
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <returns>Site info</returns>
        public Site LoadBySiteID(int siteID)
        {
            Site site = new Site();

            site.SiteID = siteID;
            site.Number = GetNumberBySiteID(siteID);

            LoadSiteNameInfo(site);

            return site;
        }

        /// <summary>
        /// Loads in the site by Number
        /// </summary>
        /// <param name="siteID">Site number</param>
        /// <returns>Site info</returns>
        public Site LoadBySiteNumber(int number)
        {
            Site site = new Site();

            site.SiteID = GetSiteIDByNumber(number);
            site.Number = number;

            LoadSiteNameInfo(site);

            return site;
        }

        /// <summary>Sets the site name information</summary>
        /// <param name="site">site to update</param>
        private void LoadSiteNameInfo(Site site)
        {
            string   siteInfo      = WConfiguration.LoadAndCache<string>(site.SiteID, "D|SITEINFO", string.Empty, "ASC", string.Empty, false);
            string[] siteInfoItems = new string[0];

            // Split out all the information
            if (!string.IsNullOrEmpty(siteInfo))
                siteInfoItems = EncryptionAlgorithms.DecodeHex(siteInfo).Split('|');

            // Retrive the information into site
            if (siteInfoItems.Length >= 2)
                site.AbbreviatedName = siteInfoItems[1].Trim();
            if (siteInfoItems.Length >= 3)
                site.FullName = siteInfoItems[2].Trim();
            if (siteInfoItems.Length >= 4)
                site.AccountName = siteInfoItems[3].Trim();

            // Get the local (current) sites abbreviated name for the site
            // Using configuration value 
            //      Category:D|SITEINFO 
            //      section: 
            //
            // First get config for site numbers for the current site, and lookup the site in this list
            // Then match that site against the Hospabs config (again for current site)
            // 18Dec13 XN 78339
            int currentSiteID       = SessionInfo.HasSite ? SessionInfo.SiteID : Sites.GetMasterSiteNumber(true);
            var siteNumbers         = WConfiguration.LoadAndCache<string>(currentSiteID, "D|SITEINFO", string.Empty, "Sitenumbers", string.Empty, false).ParseCSV<int>   (",", true).ToList();
            int index               = siteNumbers.IndexOf(site.Number);
            var siteAbbreviations   = WConfiguration.LoadAndCache<string>(currentSiteID, "D|SITEINFO", string.Empty, "Hospabs",     string.Empty, false).ParseCSV<string>(",", true).ToList();
            if (siteAbbreviations.Count > index && index >= 0)
                site.LocalHospitalAbbreviation = siteAbbreviations[index];
            else
                site.LocalHospitalAbbreviation = site.AbbreviatedName;
        }

        /// <summary>
        /// opies data from a site data layer object into a site business layer object
        /// </summary>
        /// <param name="dbSiteRow">Site row from the data layer used for data source</param>
        /// <returns>Filled site object</returns>
        private Site FillData(SiteRow dbSiteRow)
        {
            Site site = new Site();
            site.SiteID = dbSiteRow.SiteID;
            site.Number = dbSiteRow.SiteNumber;
            LoadSiteNameInfo(site);
            return site;
        }

        /// <summary>
        /// Loads all sites in the db
        /// </summary>
        /// <param name="excludeInvalid">excluding ones with site ID or number equal to 0 (default is false)</param>
        /// <returns>List of site objects</returns>
        public List<Site> LoadAll()
        {
            return LoadAll(false);
        }
        public List<Site> LoadAll(bool excludeInvalid)
        {
            List<Site> sites = new List<Site>();
            using (Sites dbSites = new Sites())
            {
                dbSites.LoadAll(excludeInvalid);
                for (int i = 0; i < dbSites.Count; i++)
                    sites.Add(FillData(dbSites[i]));
                return sites;
            }
        }
    }
}
