//===========================================================================
//
//							ProductSearch.cs
//
//  This class performs a search on the WProduct view, and is a copy of the 
//  vb SUBPATME - FillDrugList. 
//  
//  The class can search WProduct or SiteProductData on 
//        Tradename     - does a partial search (finds tradename that start with specified string)
//        Barcode       - does an exact search
//        NSVCode       - does an exact search
//        Code          - does a partial search (finds codes that start with specified string)
//        Local         - does an exact search (only when searching WProduct)
//        Description   - does a partial search (finds tradename that start with specified string)
//        Product & route-does VMP AMP AMPP search by product route, and other routes (not supported in master mode)
//
//  The search field can be controlled by searchType input parameter, or by format 
//  characters added to the search string
//        Tradename     - prefix with ?
//        Barcode       - if 8 or 13 chars all digits
//        NSVCode       - if in nsv code patther (see WCondiguration.D|STKMAINT.Data.9)
//        Code          - if 2 to 8 chars and follows code pattern (see WCondiguration.D|STKMAINT.Data.1)
//        Local         - if local pattern (see WCondiguration.D|STKMAINT.Data.72)
//                        or start with val in WCondiguration.D|STKMAINT.Data.LocalCodePrefix
//        Product & route-prefix with ¦
//
//  The description search ignores all non alpha numeric characters.
//
//  When searching in master mode the search results returned are still WProduct, but with only
//  the SiteProductData fields filled in.
//
//  Usage:
//  ProductSearchType searchType = ProductSearchType.Any
//  ProductSearch.DoSearch("Parac", ref searchType, false);
//      
//	Modification History:
//	21Mar11 XN  Written
//  09Aug13 XN  When searching on barcode, added search on alternate barcode 24653 
//  25Nov13 XN  Added search in master mode 78339
//  23Jun14 XN  remove ? before doing tradename search (similar for local code search)
//  17Oct14 XN  88560 Add BNF lookup
//  14Oct14 XN  For master barcode search made sure alternate barcode search appends 43318
//  08May15 XN  Renamed ProductSeatchType to ProductSearchType 111893 
//  26Oct15 XN  Added option site Id to DoSearch 106278
//  12Jun15 XN  Added product & route searching 39882
//===========================================================================
using System;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.businesslayer
{
    /// <summary>Which WProduct field to search</summary>
    public enum ProductSearchType
    {
        /// <summary>Uses most appropriate search method</summary>
        Any,

        /// <summary>Search for VMP AMP AMPP via ProductID 12Jun15 XN 39882</summary>
        VmpAmpAmpp,

        Tradename,
        Barcode,
        NSVCode,
        Code,
        /// <summary>Search WPRoduct.Local field</summary>
        LocalProductCode,
        Description,
        BNF     // 17Oct14 XN  88560 Add BNF lookup
    }

    /// <summary>Class to search WProduct, copy of method SUBPATME - FillDrugList</summary>
    public static class ProductSearch
    {
        /// <summary>Performs search (see file header for details)</summary>
        /// <param name="searchString">Search string</param>
        /// <param name="searchType">search type</param>
        /// <param name="searchMaster">If to search master drug file (returned WProductRow will only contian SiteProductData fields) 25Nov13 XN 78339</param>
        /// <param name="siteId">Allows searching site that is not the current site (null for current site or if searching master) 26Oct15 XN 106278</param>
        /// <param name="searchOtherRoutes">When doing ProductSearchType.VmpAmpAmpp if to search other routes 12Jun15 XN 39882</param>
        /// <param name="productRouteID">When doing ProductSearchType.VmpAmpAmpp specifies the route to search 12Jun15 XN 39882</param>
        /// <returns>result table</returns>
        public static WProduct DoSearch(string searchString, ref ProductSearchType searchType, bool searchMaster, int? siteId = null, bool searchOtherRoutes = false, int productRouteID = 0)
        {
            //
            // First determine data on which the search is to be done (can be set externally if needed)
            //

            // VMPAMPAMPP  12Jun15 XN 39882
            if (!searchMaster && searchString.StartsWith("¦") && (searchType == ProductSearchType.Any))
            {
                searchString = searchString.Substring(1);
                searchType   = ProductSearchType.VmpAmpAmpp;
            }
            
            // Test string is valid for VMPAMPAMPP 12Jun15 XN 39882
            if ((searchType == ProductSearchType.VmpAmpAmpp && !searchString.All(char.IsDigit)) || searchMaster)
            {
                searchType = ProductSearchType.Any;
            }

            // Tradename 
            // (slight variation form original vb6 as that would remove all non alpha numeric chars from search string rather than replace)
            if (searchString.StartsWith("?") && (searchType == ProductSearchType.Any))
                searchType = ProductSearchType.Tradename;
            if (searchType == ProductSearchType.Tradename)
            {
                searchString = searchString.SafeSubstring(1, searchString.Length);	//  23Jun14 XN  remove ? before doing tradename search 
                searchString = searchString.Replace(c => !char.IsLetterOrDigit(c), '%');
                searchString = searchString.Replace("%%", "%"); // Remove runs of %
            }

            // Barcode
            string errorMsg = string.Empty;
            if ((searchType == ProductSearchType.Any) && (Barcode.ValidateGTINBarcode(searchString, false, out errorMsg)))
                searchType = ProductSearchType.Barcode;

            // NSV Code
            if ((searchType == ProductSearchType.Any) && PatternMatch.Validate(searchString, PatternMatch.NSVCodePattern))
                searchType = ProductSearchType.NSVCode;

            // Lookup Code 
            if ((searchType == ProductSearchType.Any) && (searchString.Length >= 2) && (searchString.Length <= 8))
            {
                string lookupCodePattern = PatternMatch.LookupCodePattern;
                lookupCodePattern = lookupCodePattern.Substring(0, Math.Min(searchString.Length, lookupCodePattern.Length));

                if (PatternMatch.Validate(searchString, lookupCodePattern))
                    searchType = ProductSearchType.Code;
            }

            // Local product code (not is master mode 25Nov13 XN 78339)
            if (!searchMaster && (searchType == ProductSearchType.Any) && PatternMatch.Validate(searchString, PatternMatch.LocalProductCodePattern))
                searchType = ProductSearchType.LocalProductCode;

            // Local product code prefix (not is master mode 25Nov13 XN 78339)
            if (!searchMaster && searchType == ProductSearchType.Any)
            {
                string localCodePrefix = WConfigurationController.LoadAndCache<string>("D|STKMAINT", "Data", "LocalCodePrefix", "=", false);
                if (searchString.StartsWith(localCodePrefix) && (searchString.Length > localCodePrefix.Length))
                {
	                searchString = searchString.SafeSubstring(localCodePrefix.Length, searchString.Length);	//  23Jun14 XN  remove local code prefix before doing tradename search 
                    searchType = ProductSearchType.LocalProductCode;
                }
            }

            // normal search
            if (searchType == ProductSearchType.Any)
                searchType = ProductSearchType.Description;
            if (searchType == ProductSearchType.Description)
            {
                // Ignore non alpha numeric chars
                searchString = searchString.Replace(c => !char.IsLetterOrDigit(c) && (c != '.'), '%');
                searchString = searchString.Replace("%%", "%"); // Remove runs of %
            }

            WProduct searchResults = new WProduct();
            if (searchMaster)
            {
                // now do the search on SiteProductData  (25Nov13 XN 78339)
                SiteProductData products = new SiteProductData();
                switch (searchType)
                {
                case ProductSearchType.Tradename         : products.LoadByTradenameAndMasterSiteID         (searchString + "%", 0); break;
                case ProductSearchType.NSVCode           : products.LoadByNSVCodeAndMasterSiteID           (searchString, 0);       break;
                case ProductSearchType.Code              : products.LoadByCodeAndMasterSiteID              (searchString + "%", 0); break;
                case ProductSearchType.Description       : products.LoadByLabelDescriptionAndMasterSiteID  (searchString + "%", 0); break;
                case ProductSearchType.Barcode           : 
                    products.LoadByBarcodeAndMasterSiteID(searchString, 0);       
                    products.LoadByAliasGroupAliasAndMasterSiteID("AlternativeBarcode", searchString, 0, true);  // 14Oct14 XN 43318 For master barcode search made sure alternate barcode search appends // 09Aug13 XN added search on alternate barcode 24653    
                    break;
                case ProductSearchType.BNF               : products.LoadByBNFAndMasterSiteID (searchString + "%", 0); break;  // 17Oct14 XN  88560 Add BNF lookup
                }

                // Copy rows from SiteProductData to WProduct
                foreach (SiteProductDataRow row in products)
                    searchResults.Add().CopyFrom(row);
            }
            else
            {
                siteId = siteId ?? SessionInfo.SiteID;  // 26Oct15 XN 106278 Add optional site Id 

                // now do the search on WProduct
                switch (searchType)
                {
                case ProductSearchType.VmpAmpAmpp        : searchResults.LoadByProductIDVMPorAMP          (siteId.Value, int.Parse(searchString), productRouteID, searchOtherRoutes); break; // 12Jun15 XN 39882
                case ProductSearchType.Tradename         : searchResults.LoadBySiteIDAndTradename         (siteId.Value, searchString + "%"); break;
                case ProductSearchType.NSVCode           : searchResults.LoadByProductAndSiteID           (searchString, SessionInfo.SiteID); break;
                case ProductSearchType.Code              : searchResults.LoadBySiteIDAndCode              (siteId.Value, searchString + "%"); break;
                case ProductSearchType.LocalProductCode  : searchResults.LoadBySiteIDAndLocalProductCode  (siteId.Value, searchString);       break;
                case ProductSearchType.Description       : searchResults.LoadBySiteIDAndDescription       (siteId.Value, searchString + "%"); break;
                case ProductSearchType.Barcode           : 
                    searchResults.LoadBySiteIDAndBarcode(siteId.Value, searchString);       
                    searchResults.LoadBySiteIDAndAliasGroupAndAlias(siteId.Value, "AlternativeBarcode", searchString, true);  // 09Aug13 XN added search on alternate barcode 24653    
                    break;
                case ProductSearchType.BNF               : searchResults.LoadBySiteIDAndBNF (siteId.Value, searchString + "%"); break; // 17Oct14 XN  88560 Add BNF lookup
                }
            }

            return searchResults;
        }
    }
}
