//===========================================================================
//
//							PharmacyConverters.cs
//
//  Provides pharmacy specific convertion functions.
//
//  Currently supports
//      Convertion of vat code to rate
//
//  Usage
//  To returns vat rate for vat code 2 and site ID 24
//      PharmacyConverters.VatCodeToRate(24, 2)
//
//	Modification History:
//	15Apr09 XN  Written
//  27Apr09 XN  Removed all static variables by making them local, or storing
//              them in the pharmacy cache. To allow use as web app.
//  29Apr10 XN  Add a version of VatCodeToRate that can handle nulls
//===========================================================================
using System;
using System.Collections.Generic;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    public static class PharmacyConverters
    {
        #region Public Methods
        /// <summary>
        /// Conversion of vat code to rate.
        /// 
        /// Throws exception if vat code is invalid, for the site.
        /// 
        /// The rates are stored in the pharmacy data cache.
        /// Note: Use the context cache to allow rate changes to take effect 
        /// immediatly, incase web iste is not restarted. 
        /// </summary>
        /// <param name="siteID">Site the code is for</param>
        /// <param name="vatCode">Vat code</param>
        /// <returns>Vat rate</returns>
        public static decimal VatCodeToRate(int siteID, int vatCode)
        {
            string cachedName = string.Format("{0}.VatRate[{1}][{2}]", typeof(PharmacyConverters).FullName, siteID, vatCode);

            // Try to get the rate from the pharmacy data cache
            object vatRateObj = PharmacyDataCache.GetFromContext(cachedName);
            if (vatRateObj != null)
                return (decimal)vatRateObj;

            // Rate has not been loaded yet, so load now
            string key = string.Format("VAT({0})", vatCode);
            WConfiguration config = new WConfiguration();
            config.LoadBySiteCategorySectionAndKey(siteID, "D|WorkingDefaults", "", key);

            // No rates for this site so error
            if (config.Count != 1)
            {
                string msg = string.Format("No vat rates stored in WConfiguration for site ID {0} Vat Code {1}", siteID, vatCode);
                throw new ApplicationException(msg);
            }

            // Get the vat rate
            decimal vatRate = decimal.Parse(config[0].Value);

            // Add to pharmacy data cache
            PharmacyDataCache.SaveToContext(cachedName, vatRate);

            return vatRate;
        }
        public static decimal? VatCodeToRate(int siteID, int? vatCode)
        {
            return (vatCode.HasValue ? (decimal?)VatCodeToRate(siteID, vatCode.Value) : null);
        }
	    #endregion    
    }
}
