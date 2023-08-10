// --------------------------------------------------------------------------------------------------------------------
// <copyright file="HospitalDetails.cs" company="Ascribe Ltd.">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
//  Used to get the Full, Account, and Abbreviated Name of a hospital for a site for the configuration table
//  
//  Usage
//  HospitalDetails details = new HospitalDetails()
//  details.LoadBySiteID(19);
//  details.FullName    
//      
//  Modification History:
//  11Mar13 XN Created 
// </summary>
// --------------------------------------------------------------------------------------------------------------------
namespace ascribe.pharmacy.reportlayer
{
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

    /// <summary>Get Full, Account, and Abbreviated Name of a hospital for a site for the configuration table</summary>
    internal class HospitalDetails
    {
        /// <summary>Gets full name for hospital</summary>
        public string FullName { get; private set; }

        /// <summary>Gets account name for hospital</summary>
        public string AccountName { get; private set; }

        /// <summary>Gets abbreviated name for hospital</summary>
        public string AbbreviatedName { get; private set; }

        /// <summary>load details for the site from the configuration table</summary>
        /// <param name="siteID">Site ID</param>
        public void LoadBySiteID(int siteID)
        {
            string siteInfo = Database.ExecuteSQLScalar<string>("SELECT [Value] FROM WConfiguration WHERE [Key]='ASC' AND SiteID={0} AND Section='' AND Category='D|SITEINFO'", siteID) ?? string.Empty;
            if (siteInfo.StartsWith("\""))
            {
                siteInfo = siteInfo.SafeSubstring(1, siteInfo.Length - 1);
            }
            
            if (siteInfo.EndsWith("\""))
            {
                siteInfo = siteInfo.SafeSubstring(0, siteInfo.Length - 1);
            }
            
            string[] siteInfoItems = EncryptionAlgorithms.DecodeHex(siteInfo).Split('|');

            this.FullName        = (siteInfoItems.Length >= 3) ? siteInfoItems[2].Trim() : string.Empty;    // Full name
            this.AccountName     = (siteInfoItems.Length >= 4) ? siteInfoItems[3].Trim() : string.Empty;    // Account Name
            this.AbbreviatedName = (siteInfoItems.Length >= 2) ? siteInfoItems[1].Trim() : string.Empty;    // Abbreviated Name
        }
    }
}
