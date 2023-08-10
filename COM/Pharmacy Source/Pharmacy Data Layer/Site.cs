//===========================================================================
//
//							        Site.cs
//
//  Provides access to Site table.
//
//  Only supports reading from table.
//  
//	Modification History:
//	15Apr09 XN  Written
//  27Apr09 XN  BaseTable.AddInputParam is no longer static (part of the 
//              webification process)
//  23May13 XN  Added FindBySiteNumber (27038)
//  22Jul13 XN  Added FindSiteNumberByID (27252)
//  24Nov13 XN  78339 Added FindSiteNumberByID, FindSiteIDBySiteNumber (multiple items),
//              GetMasterSiteNumber, GetDSSMasterSiteID 78339
//  13Jan14 XN  Made FindSiteNumberByID, and FindSiteIDBySiteNumber (multiple items)
//              maintain list order
//  16Jun14 XN  Added GetDictonarySiteIDToNumber, and ToDictonarySiteIDToNumber (88509)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    public class SiteRow : BaseRow
    {
        public int SiteID 
        { 
            get { return FieldToInt(RawRow["LocationID"]).Value; }
        }

        public int SiteNumber
        {
            get { return FieldToInt(RawRow["SiteNumber"]).Value; }
        }
    }

    public class Sites : BaseTable<SiteRow, BaseColumnInfo>
    {
        public Sites() : base("Site", "LocationID")
        {
        }

        /// <summary>
        /// Returns the db SiteID for the site number
        /// </summary>
        /// <param name="siteNumber">Site number</param>
        /// <returns>SiteID</returns>
        public static int GetSiteIDByNumber(int siteNumber)
        {
            StringBuilder parameters = new StringBuilder();
            Sites sites = new Sites();
            sites.AddInputParam(parameters, "SiteNumber", siteNumber);
            return sites.ExecuteScalar( "pLocationID_SitebySiteNumber", parameters );
        }

        /// <summary>
        /// Returns the db site number for the site id
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <returns>Site Number</returns>
        public static int GetNumberBySiteID(int siteID)
        {
            StringBuilder parameters = new StringBuilder();
            Sites sites = new Sites();
            sites.AddInputParam(parameters, "SiteID", siteID);
            return sites.ExecuteScalar( "pLocationID_SiteNumberbySite", parameters );
        }

        /// <summary>
        /// Returns master site number defined by setting
        /// System: Pharmacy
        /// Section: General
        /// Key: MasterSiteNumber
        /// 
        /// If setting is not set and defaultToAny is true, returns first site number
        /// 22Nov13 XN 78339
        /// </summary>
        /// <param name="defaultToAny">If setting is not set will then return first site number (else will assert)</param>
        public static int GetMasterSiteNumber(bool defaultToAny)
        {            
            int? siteNumber = SettingsController.Load<int?>("Pharmacy", "General", "MasterSiteNumber", null);
            if (siteNumber == null && defaultToAny)
            {
                Sites sites = new Sites();
                sites.LoadAll(true);
                if (sites.Any())
                    siteNumber = sites.OrderBy(s => s.SiteNumber).First().SiteNumber;
            }

            if (siteNumber == null)
                throw new ApplicationException("No master site set (Setting Pharmacy.General.MasterSiteNumber)");

            return siteNumber.Value;
        }


        /// <summary>Returns DSS Master site Number from table DSSMasterSiteLinkSite</summary>
        public static int GetDSSMasterSiteID(int siteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID));
            parameters.Add(new SqlParameter("SiteID",           siteID               ));
            return Database.ExecuteSPReturnValue<int>("pGetDSSMasterSiteIDbySiteID", parameters);
        }

        /// <summary>Returns a dictonary of site ID to number (loaded from the DB)</summary>
        /// <param name="excludeInvalid">If to include valid items</param>
        public static IDictionary<int,int> GetDictonarySiteIDToNumber(bool excludeInvalid = false)
        {
            Sites sites = new Sites();
            sites.LoadAll(excludeInvalid);
            return sites.ToDictonarySiteIDToNumber();
        }

        /// <summary>
        /// Returns all sites for the site table
        /// </summary>
        /// <param name="excludeInvalid">excluding ones with site ID or number equal to 0 (default is false)</param>
        public void LoadAll()
        {
            LoadAll(false);
        }
        public void LoadAll(bool excludeInvalid)
        {
            StringBuilder parameters = new StringBuilder();
            if (excludeInvalid)
                LoadRecordSetStream("pSiteLoadAllExcludingInvalid", parameters);
            else
                LoadRecordSetStream("pSiteLoadAll", parameters);
        }

        /// <summary>
        /// Returns first site with specified site number (or null if site does not exist)
        /// 23May12 XN  27038
        /// </summary>
        public SiteRow FindBySiteNumber(int siteNumber)
        {
            return this.FirstOrDefault(s => s.SiteNumber == siteNumber);
        }

        /// <summary>Returns first site number with specified site id (or null if site does not exist)</summary>
        public int? FindSiteNumberByID(int locationID_Site)
        {
            SiteRow siteRow = this.FirstOrDefault(s => s.SiteID == locationID_Site);
            return (siteRow == null) ? (int?)null : siteRow.SiteNumber;
        }

        /// <summary>
        /// Returns all site IDs for a siteNumber 22Nov13 XN 78339
        /// The order of the return items is the same as the input items
        /// </summary>
        public IEnumerable<int> FindSiteNumberByID(IEnumerable<int> siteIDs)
        {
            foreach(var siteID in siteIDs)
            {
                SiteRow site = this.FindByID(siteID);
                if (site != null)
                    yield return site.SiteNumber;
            }
        }

        /// <summary>Returns first site ID with specified site number (or null if site does not exist)</summary>
        public int? FindSiteIDBySiteNumber(int siteNumber)
        {
            SiteRow siteRow = this.FirstOrDefault(s => s.SiteNumber == siteNumber);
            return (siteRow == null) ? (int?)null : siteRow.SiteID;
        }

        /// <summary>
        /// Returns all site IDs for a siteNumber 22Nov13 XN 78339
        /// The order of the return items is the same as the input items
        /// </summary>
        public IEnumerable<int> FindSiteIDBySiteNumber(IEnumerable<int> siteNumbers)
        {
            foreach(var siteNumber in siteNumbers)
            {
                SiteRow site = this.FindBySiteNumber(siteNumber);
                if (site != null)
                    yield return site.SiteID;
            }
        }
    }

    /// <summary>Enumerator class for sites</summary>
    public static class SiteEnumerator
    {
        /// <summary>Returns a dictonary of site ID to number</summary>
        public static IDictionary<int,int> ToDictonarySiteIDToNumber(this IEnumerable<SiteRow> sites) 
        {
            return sites.ToDictionary(s => s.SiteID, s => s.SiteNumber);
        }
    }
}
