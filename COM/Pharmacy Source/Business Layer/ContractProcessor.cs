//===========================================================================
//
//					    ContractProcessor.cs
//
//  This class holds all business logic for handling contract information.
//
//  This file is comprised of a business object (ContractInfo),
//  a business process (ContractProcessor).
//
//  When setting contract information the contract can start from today, or 
//  any point in the future (by setting the contractInfo.StartDate).
//  When the contract comes into effect WSupplierProfile will be updated with the
//  contract details (done by the overnight job data is held in WExtraDrugDetail table).
//  If the contract is to take place today then WSupplierProfile will be
//  updated immediately (when Update is called).
//  If the drug does not have a WSupplierProfile one will be created when Update
//  is called, but the contract information will not be set until the contract start date.
//
//  ContractInfo
//  ------------
//  Requires the following fields to be filled in
//          NSVCode
//          SupCode
//          siteIDs
//          StartDate
//          EndDate - Can be null if contract lasts for ever
//  The followings fields are set in WSupplierProfile between start and end dates.
//  Once end date is reached overnight job will clear fields in WSupplierProfile.
//  Set to blank if don't want to change existing contract reference
//          contractReference 
//          contractPrice
//  The followings fields are set at start of contract, but remain set once end
//  date has been reached 
//          supplierTradename - set to null if not to change existing value
//          setDefaultSupplier- If false will not change a primary to alternative supplier
//  The following field will be set instantly Update is called independent of time
//  Set to blank if don't want to change existing contract reference
//          Barcode - Can only set if one does not exist
//  
//  Usage:
//
//  ContractInfo contractInfo   = new ContractInfo();
//  contractInfo.NSVCode            = "AS456G";
//  contractInfo.SupCode            = "SUPP1";
//  contractInfo.contractReference  = "457362";
//  contractInfo.StartDate          = DateTime.Today;
//  contractInfo.siteIDs.Add(15);
//
//  using(ContractProcessor processor = new ContractProcessor())
//  {
//      ContractProcessor.Lock(processor);
//      ContractProcessor.Update(processor);
//  }
//      
//	Modification History:
//	03Aug13 XN  Written
//  22Nov13 XN  78339 knock on effects from LockResult changes
//  29Jan14 XN  82431 Updates due to changes in SiteProductData
//  30Apr14 XN  88842 Added Supplier Reference 
//  28Oct14 XN  100212 Set SupplierTradename to product tradename by default
//  18May15 XN  117528 Got the save to update the ProductStock modified date, and log changes
//  08Jun15 XN  119361 Moved SiteValid, SiteInfo, and DetermineIfSiteValidForReplication from ContractEditorSettings to ContractProcessor
//  24Sep15 XN  Moved alias methods from SiteProductData to BaseTable2 77778
//  30Jun16 XN  Added EDI Link code 126641
//  25Jul16 XN  126634 prevent updating EdiBarcode if not set
//  28Nov16 XN  Updated Lock to use GetPKColumnName 147104
//===========================================================================

namespace ascribe.pharmacy.businesslayer
{
using System;
using System.Collections.Generic;
using System.Linq;
using _Shared;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

    /// <summary>Contract info business object</summary>
    public class ContractInfo : IBusinessObject
    {
        public string    NSVCode;
        public string    SupCode;
        public List<int> siteIDs;

        /// <summary>Start date of the contract</summary>
        public DateTime startDate;

        /// <summary>End date of the contract (or null if contract last for ever)</summary>
        public DateTime? endDate;

        /// <summary>
        /// Contract reference number to be set between start and end dates
        /// Set to blank if don't want to change existing contract reference
        /// </summary>
        public string contractReference;

        /// <summary>
        /// Contract price to be set between start and end dates
        /// Set to blank if don't want to change existing contract price
        /// </summary>
        public decimal? contractPrice;

        /// <summary>
        /// Supplier tradename to be set, comes into effect when startDate occurs, but once set is not removed
        /// Set to null if don't want to change existing tradename.
        /// </summary>
        public string  supplierTradename;

        /// <summary>
        /// Supplier reference to be set, comes into effect when startDate occurs, but once set is not removed
        /// 30Apr14 XN 88842
        /// </summary>
        public string supplierReference;

        /// <summary>
        /// Added EDI barcode
        /// 30Jun16 XN  126641
        /// </summary>
        public string ediBarcode;

        /// <summary>
        /// Barcode to set on SiteProductData (only set if one does not exist)
        /// Updates immediately and is not dependant on start or end date
        /// Set to blank if don't want to change existing barcode
        /// </summary>
        public string Barcode;

        /// <summary>
        /// Set to true to setup supplier a primary supplier for site
        /// Comes into effect when startDate occurs, but once set is not removed
        /// Note setting to false will not change a primary supplier to be being an alternative supplier
        /// </summary>
        public bool setDefaultSupplier;

        public ContractInfo()
        {
            this.siteIDs = new List<int>();
        }
    }

    public class ContractProcessor : BusinessProcess
    {
        /// <summary>Validity of the site for replication (08Jun15 XN 119361 moved from ContractEditorSettings)</summary>
        public enum SiteValid
        {
            /// <summary>Is valid</summary>
            Yes,

            /// <summary>Drug not supported on this site</summary>
            NoSupportedDrug,

            /// <summary>Drug has no supported supplier</summary>
            NoSupportedSupplier,

            /// <summary>Can't perform operation as is primary supplier</summary>
            NoIsPrimarySupplier
        }

        /// <summary>Info on if site is suitable for replication (08Jun15 XN 119361 moved from ContractEditorSettings)</summary>
        public struct SiteInfo
        {
            /// <summary>Validity of the site for replication</summary>
            public SiteValid validState;

            /// <summary>Site ID</summary>
            public int siteID;

            /// <summary>Site number</summary>
            public int siteNumber;
        }

        /// <summary>Locks all database rows that will form part of the update</summary>
        public void Lock(ContractInfo contractInfo)
        {
            // Lock ProductStock rows (lock only when start date is today as only updates ProductStock immediatly when contract start data is today)
            if (contractInfo.startDate == DateTime.Today)
            {
                ProductStock productStock = new ProductStock();
                foreach (int siteID in contractInfo.siteIDs)
                    productStock.LoadBySiteIDAndNSVCode(contractInfo.NSVCode, siteID, true);
                LockRows(productStock.Table, productStock.TableName, productStock.GetPKColumnName());
            }
        }

        /// <summary>Updates the database tables with new contract information</summary>
        public void Update(ContractInfo contractInfo)
        {
            WProduct         product                = new WProduct();
            SiteProductData  siteProductData        = new SiteProductData();
            WExtraDrugDetail extraDrugDetail        = new WExtraDrugDetail();
            WSupplierProfile supplierProfile        = new WSupplierProfile();
            WSupplierProfile otherSupplierProfile   = new WSupplierProfile();   // 30Jun16 XN 126641 Added
            ProductStock     productStock           = new ProductStock();
            DateTime         now                    = DateTime.Now;
            DateTime         today                  = DateTime.Today;

            // Check require fields are set
            if (StringExtensions.IsNullOrEmptyAfterTrim(contractInfo.NSVCode))
                throw new ApplicationException(string.Format("Invalid NSVCode '{0}'", contractInfo.NSVCode));
            if (StringExtensions.IsNullOrEmptyAfterTrim(contractInfo.SupCode))
                throw new ApplicationException(string.Format("Invalid Supplier Code '{0}'", contractInfo.SupCode));
            if (contractInfo.startDate < today)
                throw new ApplicationException("Can't set contract to start in the past");

            // Load in all existing data (loads data from any site for speed)
            extraDrugDetail.LoadByNSVCodeAndSupCode(contractInfo.NSVCode, contractInfo.SupCode);
            supplierProfile.LoadBySupplierAndNSVCode(contractInfo.SupCode, contractInfo.NSVCode);

            // Update data for each site
            foreach (int siteID in contractInfo.siteIDs)
            {
                // Set extra drug detail (create new if needed)
                // This is used by overnight job if contract information is to be set at a later date
                WExtraDrugDetailRow extraDrugDetailRow = extraDrugDetail.FindBySiteID(siteID).FindFirstByIsStillDue();
                if (extraDrugDetailRow == null)
                {
                    extraDrugDetailRow = extraDrugDetail.Add();
                    extraDrugDetailRow.LocationID_Site            = siteID;
                    extraDrugDetailRow.NSVCode                    = contractInfo.NSVCode;
                    extraDrugDetailRow.SupCode                    = contractInfo.SupCode;
                }

                extraDrugDetailRow.NewContractNumber        = contractInfo.contractReference;
                extraDrugDetailRow.NewContractPrice         = contractInfo.contractPrice;
                extraDrugDetailRow.DateOfChange             = contractInfo.startDate;
                extraDrugDetailRow.StopDate                 = contractInfo.endDate;
                extraDrugDetailRow.NewSupplierTradeName     = contractInfo.supplierTradename;
                extraDrugDetailRow.NewSupplierReferenceNumber=contractInfo.supplierReference;   // 30Apr14 XN 88842 Added Supplier Reference
                extraDrugDetailRow.NewEDIBarcode            = contractInfo.ediBarcode;          // 30Jun16 XN 126641 EDI Link Code
                extraDrugDetailRow.SetAsDefaultSupplier     = contractInfo.setDefaultSupplier;
                extraDrugDetailRow.UpdatedBy                = SessionInfo.UserInitials.SafeSubstring(0, WExtraDrugDetail.GetColumnInfo().UpdatedByLength);
                extraDrugDetailRow.DateEntered              = now;
                extraDrugDetailRow.DateUpdated_ByOvernighJob= (contractInfo.startDate == today) ? today : (DateTime?)null;

                // If WSupplierProfile row does not exist then add one now (so does not needed by overnight job)
                WSupplierProfileRow supplierProfileRow = supplierProfile.FirstOrDefault(sp => sp.SiteID == siteID);
                if (supplierProfileRow == null)
                {
                    product.LoadByProductAndSiteID(contractInfo.NSVCode, siteID);
                    if (!product.Any())
                        throw new ApplicationException(string.Format("No WProduct info for NSCVode {0} site ID {1}", contractInfo.NSVCode, siteID));

                    supplierProfileRow = supplierProfile.Add();
                    supplierProfileRow.SupplierCode                    = contractInfo.SupCode;
                    supplierProfileRow.NSVCode                         = contractInfo.NSVCode;
                    supplierProfileRow.LeadTimeInDays                  = (decimal?)product[0].LeadTimeInDays;
                    supplierProfileRow.ReorderPackSize                 = null;
                    supplierProfileRow.LastReceivedPriceExVatPerPack   = product[0].LastReceivedPriceExVatPerPack;
                    supplierProfileRow.LastReconcilePriceExVatPerPack  = null;
                    supplierProfileRow.SiteID                          = siteID;
                    supplierProfileRow.VATCode                         = product[0].VATCode;
                    supplierProfileRow.SupplierReferenceNumber         = string.Empty;
                    supplierProfileRow.ContractNumber                  = string.Empty;
                    supplierProfileRow.ContractPrice                   = null;
                    //supplierProfileRow.SupplierTradename               = string.Empty;    28Oct14 XN  100212 Set SupplierTradename to product tradename by default  
                    supplierProfileRow.SupplierTradename               = string.IsNullOrWhiteSpace(contractInfo.supplierTradename) ? product[0].Tradename : contractInfo.supplierTradename;
                }

                // If contract information is to be set today then update wsupplierprofile immediately
                if (contractInfo.startDate == today)
                {
                    // Only update if fields are not blank
                    if (!string.IsNullOrEmpty(contractInfo.contractReference))
                    {
                        supplierProfileRow.ContractNumber           = contractInfo.contractReference;
                        supplierProfileRow.ContractPrice            = contractInfo.contractPrice;  
                        //supplierProfileRow.SupplierTradename        = contractInfo.supplierTradename; 28Oct14 XN  100212 Set SupplierTradename to product tradename by default  
                        supplierProfileRow.SupplierReferenceNumber  = contractInfo.supplierReference;   // 30Apr14 XN 88842 Added Supplier Reference
                        if ( contractInfo.supplierTradename != null )
                            supplierProfileRow.SupplierTradename = contractInfo.supplierTradename;  // 28Oct14 XN  100212 Set SupplierTradename to product tradename by default
                        if (contractInfo.ediBarcode != null)
                            supplierProfileRow.EdiBarcode = contractInfo.ediBarcode;      // 25Jul16 XN  126634 prevent updating EdiBarcode if not set // 30Jun16 XN  126641 Added

                        // Update the modified details 18May15 XN 117528
                        if (supplierProfileRow.HasDataChanged() && supplierProfileRow.IsPrimarySupplier())
                        {
                            productStock.LoadBySiteIDAndNSVCode(contractInfo.NSVCode, siteID, true);
                            productStock.FindBySiteIDAndNSVCode(siteID, contractInfo.NSVCode).UpdateModifiedDetails(now);
                        }
                    }

                    // Set primary supplier if selected
                    if (contractInfo.setDefaultSupplier)
                    {
                        // Only load if not already load as might be loaded above 18May15 XN 117528
                        ProductStockRow productStockRow = productStock.FindBySiteIDAndNSVCode(siteID, contractInfo.NSVCode);
                        if (productStockRow == null)
                        {
                            productStock.LoadBySiteIDAndNSVCode(contractInfo.NSVCode, siteID, true);
                            productStockRow = productStock.FindBySiteIDAndNSVCode(siteID, contractInfo.NSVCode);
                        }                        

                        if (productStockRow != null && !productStockRow.PrimarySupplierCode.EqualsNoCaseTrimEnd(contractInfo.SupCode))
                        {
                            productStockRow.PrimarySupplierCode = contractInfo.SupCode;
                            productStockRow.UpdateModifiedDetails(now); // Update the modified details 18May15 XN 117528
                        }
                    }

                    // load in other supplier profiles that need edi barcode clearing 30Jun16 XN  126641
                    if (!string.IsNullOrWhiteSpace(contractInfo.ediBarcode))
                    {
                        otherSupplierProfile.LoadBySiteIDSupplierAndEdiBarcode(siteID, contractInfo.SupCode, contractInfo.ediBarcode);
                        (from sp in otherSupplierProfile where sp.NSVCode != contractInfo.NSVCode select sp).ForEach(sp => sp.EdiBarcode = string.Empty);
                    }
                }
            }

            // Set barcode if does not have a barcode (or alternate barcode set)
            if (!string.IsNullOrEmpty(contractInfo.Barcode))
            {
                siteProductData.LoadBySiteIDAndNSVCode(contractInfo.siteIDs.First(), contractInfo.NSVCode);
                if (!siteProductData.Any())
                    throw new ApplicationException(string.Format("Invalid NSVCode '{0}'", contractInfo.NSVCode));

                if (!contractInfo.Barcode.EqualsNoCaseTrimEnd(siteProductData[0].Barcode) && 
                    !siteProductData[0].GetAlternativeBarcode().Any(b => contractInfo.Barcode.EqualsNoCaseTrimEnd(b)))
                {
                    (new SiteProductData()).AddAlias(siteProductData[0].SiteProductDataID, "AlternativeBarcode", contractInfo.Barcode, true);
                    //SiteProductData.AddAlias(siteProductData[0].SiteProductDataID, "AlternativeBarcode", contractInfo.Barcode, true); 24Sep15 XN  Moved alias methods from SiteProductData to BaseTable2 77778
                }
            }

            // And save
            using(ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                siteProductData.Save();
                productStock.Save(saveToPharmacyLog: true);
                supplierProfile.Save(updateModifiedDate: false, saveToPharmacyLog: true);
                extraDrugDetail.Save();
                otherSupplierProfile.Save(updateModifiedDate: true, saveToPharmacyLog: true);   // Added 30Jun16 XN  126641

                scope.Commit();
            }
        }
    
        /// <summary>
        /// Returns which sites in siteNumber list are valid for the drug and suppliers provided.
        /// Checks that WProduct exists for the site and drug.
        /// Checks that a supplier exists for the site.
        /// 08Jun15 XN 119361 moved from ContractEditorSettings
        /// </summary>
        /// <param name="siteNumbers">List of sites to check</param>
        /// <param name="NSVCode">product to determine if site supported by</param>
        /// <param name="supCode">supplier to determine if site supported by</param>
        /// <param name="includeIfPrimarySupplier">Checks if supplier is primary for site</param>
        /// <param name="limitToProductsSites">If to limit to just sites for this product</param>
        /// <returns>sites in siteNumber list are valid for the drug and suppliers</returns>
        public static IEnumerable<SiteInfo> DetermineIfSiteValidForReplication(IEnumerable<int> siteNumbers, string NSVCode, string supCode, bool includeIfPrimarySupplier, bool limitToProductsSites)
        {
            var validSites = new List<ContractProcessor.SiteInfo>();

            // Get list of sites so known which are valid
            Site2 sites = Site2.Instance();
            
            // Get list of WProduct so known which sites support the product
            WProduct products = new WProduct();
            products.LoadByNSVCode(NSVCode);

            // Get list of Wsupplier so know which sites support the supplier
            List<int> supplierSiteIDs;
            if (limitToProductsSites)
            {
                WSupplierProfile profile = new WSupplierProfile();
                profile.LoadBySupplierAndNSVCode(supCode, NSVCode);
                supplierSiteIDs = profile.Select(s => s.SiteID).ToList();
            }
            else
            {
                WSupplier suppliers = new WSupplier();
                suppliers.LoadByCode(supCode);
                supplierSiteIDs = suppliers.Where(s => s.Type == SupplierType.External).Select(s => s.SiteID).ToList();
            }

            foreach (int s in siteNumbers)
            {
                SiteInfo siteInfo = new SiteInfo();
                siteInfo.siteID = sites.FindSiteIDByNumber(s);
                siteInfo.siteNumber = s;

                if (!products.Any(prod => prod.SiteID == siteInfo.siteID))
                {
                    siteInfo.validState = SiteValid.NoSupportedDrug;     // Drug not supported by site so disable site check box
                }
                else if (!includeIfPrimarySupplier && products.First(prod => prod.SiteID == siteInfo.siteID).SupplierCode.EqualsNoCaseTrimEnd(supCode))
                {
                    siteInfo.validState = SiteValid.NoIsPrimarySupplier; // Supplier is primary supplier for sites (and opted to exclude these
                }
                else if (!supplierSiteIDs.Contains(siteInfo.siteID))
                {
                    siteInfo.validState = SiteValid.NoSupportedSupplier; // Supplier not supported by site so disable site check box
                }
                else
                {
                    siteInfo.validState = SiteValid.Yes;
                }

                validSites.Add(siteInfo);
            }

            return validSites;
        }
    }
}
