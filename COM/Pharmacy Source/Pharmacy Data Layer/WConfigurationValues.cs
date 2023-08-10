//===========================================================================
//
//							   WConfigurationValues.cs
//
//  Provides accesss to the actual general settings from WConfiguration
//
//  Usage
//  Winord.Defaults.SupplierShortName
//  
//	Modification History:
//	31Oct14 XN  Written 102842
//  14Apr16 XN  123082 Added SiteInfo.PatientDataSiteNumber, SiteInfo.PatientDataSiteId, 
//              and classes WorkingDefaults, Terminal
//  24May16 XN  Replaced DispdataDRV and DispdataDRVBySite 124812
//  15Jul16 XN  Added Winord.EnableEdiLinkCode 126634
//===========================================================================
using ascribe.pharmacy.shared;
using System.IO;

namespace ascribe.pharmacy.pharmacydatalayer
{
    public static class Winord
    {
        public static class Defaults
        {
            /// <summary>Used to determine sort order to display the Supplier or Location in various list</summary>
            public static SupplierNameType SupplierShortName
            {
                get
                {
                    // Get setting
                    string supplierShortName = WConfiguration.Load<string>(SessionInfo.SiteID, "D|Winord", "defaults", "SupplierShortName", "N", false);

                    bool shortName;
                    BoolExtensions.TryPharmacyParse(supplierShortName, out shortName);

                    // Convert to SupplierNameType
                    if (supplierShortName.EqualsNoCaseTrimEnd("B"))
                        return SupplierNameType.ShortAndLongName;
                    else if(shortName)
                        return SupplierNameType.ShortName;
                    else
                        return SupplierNameType.FullName;
                }
            }
        }

        /// <summary>If EDI link code is required D|WINORD..EnableEDILinkCode 15Jul16 XN 126634</summary>
        public static bool EnableEdiLinkCode { get { return WConfiguration.LoadAndCache(SessionInfo.SiteID, "D|WINORD", string.Empty, "EnableEDILinkCode", false, false); } }
    }

    public static class SiteInfo
    {
        //public static string DispdataDRV { get { return DispdataDRVBySite(SessionInfo.SiteID); } }
        //public static string DispdataDRVBySite(int siteID) 
        //{ 
        //    return WConfiguration.LoadAndCache<string>(siteID, "D|Siteinfo", string.Empty, "DispdataDRV", string.Empty, false); 
        //}
        
        /// <summary>
        /// Returns config setting D|Siteinfo..DispdataDRV will also append the dispdata.{site number}
        ///     {DispdataDRV}\dispdata.{site number}
        /// 24May16 XN replaced DispdataDRV and DispdataDRVBySite
        /// </summary>
        /// <param name="siteID">optional site id</param>
        /// <returns>setting</returns>
        public static string DispdataDRV(int? siteID = null) 
        { 
            int siteId = siteID ?? SessionInfo.SiteID;
            return Path.Combine(WConfiguration.LoadAndCache<string>(siteId, "D|Siteinfo", string.Empty, "DispdataDRV", string.Empty, false), string.Format("dispdata.{0:000}", Site2.GetSiteNumberByID(siteId)));
        }

        /// <summary>
        /// Access to patient data external site number 
        /// config setting D|Siteinfo.patdataEXT (default current site)
        /// 14Apr16 XN 123082
        /// </summary>
        /// <param name="siteId">current site id</param>
        /// <returns>site number</returns>
        public static int PatientDataSiteNumber(int? siteId = null)
        {
            siteId = siteId ?? SessionInfo.SiteID;
            int siteNumber = Site2.Instance().FindByID(siteId.Value).IsSingleUserOnly ? 1 : Site2.GetSiteNumberByID(siteId.Value);
            return WConfiguration.LoadAndCache<int>(siteId.Value, "D|Siteinfo", string.Empty, "patdataEXT", siteNumber, false); 
        }

        /// <summary>
        /// Access to patient data external site id 
        /// config setting D|Siteinfo.patdataEXT (default current site)
        /// 14Apr16 XN 123082
        /// </summary>
        /// <param name="siteId">current site id</param>
        /// <returns>site Id</returns>
        public static int PatientDataSiteId(int? siteId = null)
        {
            return Site2.GetSiteIDByNumber(SiteInfo.PatientDataSiteNumber(siteId));
        }
    }

    /// <summary>Access to D|Terminal setting 14Apr16 XN 123082</summary>
    public static class Terminal
    {
        /// <summary>Returns D|Terminal.{terminal to 15 chars}.LocalFilePath or if does not exist D|Terminal.default.LocalFilePath</summary>
        /// <param name="siteId">current site id</param>
        /// <returns>local file path</returns>
        public static string LocalFilePath(int? siteId = null)
        {
            siteId = siteId ?? SessionInfo.SiteID;
            string result = WConfiguration.LoadAndCache<string>(siteId.Value, "D|Terminal", SessionInfo.Terminal, "LocalFilePath", null, false);
            if (result == null)
                result = WConfiguration.LoadAndCache<string>(siteId.Value, "D|Terminal", "default", "LocalFilePath", "c:", false);
            return result;
        }
    }
}
