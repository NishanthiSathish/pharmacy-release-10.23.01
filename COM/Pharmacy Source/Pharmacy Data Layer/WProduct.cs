//===========================================================================
//
//							    WProduct.cs
//
//  Provides access to WProduct view (does support editing and saving)
//
//  WProduct view provides a collection of data for a product. Despite being a
//  view does support editing, and saving, though does not support deleting, or
//  bulk inserts
//
//  You can't rely on the DrugID <10000000 to determie if the drug is DSS maintained need to 
//  always check against SiteProductData master row (so call IsDSSMaintained)
//
//  Only supports reading.
//
//	Modification History:
//	15Apr09 XN  Written
//  13May09 AJK Renamed to WProduct
//  15May09 AJK Added InUse and StockLvl
//  28May09 XN  Added many more properties to WProduct, and changed StockLvl, 
//              and ReOrderLevel, to StockLevelInIssueUnits, and 
//              ReOrderLevelInIssueUnits.
//              Added method LoadByProductIDAndSiteID
//  21Dec09 XN  Added PricingFlag property. Added load methods 
//              LoadBySiteLoadingNumberAndPrimaryBarcode 
//              and LoadBySiteIDAndBarcode (F0042698)
//  18Jan10 XN  Got StockLevelInIssueUnits to use correct convert function
//              and CanUseSpoon to allow null (F0074142)
//  29Apr10 XN  Made more robust against DB nulls, and extended to replace 
//              business layer class Product
//  16Jul10 XN  found instances where SisStock can be empty string
//  03Aug10 XN  Made IsStoresOnly return true if ProductID is null (F0088717)
//  22Mar11 XN  Added field LocalProductCode (WProduct.local) and methods
//              LoadBySiteIDAndDescription, LoadBySiteIDAndCode, 
//              LoadBySiteIDAndLocalProductCode, LoadBySiteIDAndTradename (F0092112)
//  17Jan11 XN  Added ExcludeFromPN flag
//  15May13 XN  Added ProductDetails with no site (27038)
//  24Jul13 XN  Added method GetAlternativeBarcode 24653
//  01Aug13 AJK Added load mecahnisms LoadBySiteProductDataIDAndSiteID and LoadBySiteIDAndAliasGroupAndAlias
//              Added static method AddSiteProductDataAlias
//  01Nov13 XN  56701 Added lots of fields for product editor
//  19Dec13 XN  78339 Moved to BaseTable2, and added Saveing function
//  29Jan14 XN  82431 Tidyup of Alias handling between SiteProductData and WProduct
//  30Jan14 XN  56701 Added properties MessageCode, InfusionTime, PipCode, MasterPip
//  12Feb14 XN  56071 Added LoadByDrugIDAndSiteID and GetByDrugIDAndSiteID
//                    Replaced all List<SqlParameter>.Add with new add method
//  25Feb14 XN  56071 Added DSS
//  12Mar14 XN        Added field for DMandDReference
//  09May14 XN  88858 Added methods LoadBySiteAndLookupCode and GetCountBySiteAndLookupCode
//  11Jun14 XN  88922 Added LoadByProductAndSiteID for multipl products
//  24Jun14 XN  43318 Update LoadByProductAndSiteID to load in 200 drugs at a time
//                    Implemented the new BaseTable2 locking mechanism
//                    Added FindBySiteIDAndNSVCode
//  30Jun14 XN  94416 Updated IsDSSMaintainedDrug, added method GetTrueMasterDrugID
//                    Remove setting DSS in add
//                    All of this is to make use of table DSSMasterSiteLinkSiteDrug
//                    to patch up mapping of drugs to the correct master Drug
//  01Jul14 XN        In save if addeding and already existing prevented saving
//                    (to avoid getting duplicate drugs)
//  04Jul14 XN  94416 Removed GetTrueMasterDrugID, GetTrueLocalDrugID and all 
//                    references to DSSMasterSiteLinkSiteDrug table
//  17Oct14 XN  88560 Add LoadBySiteIDAndBNF
//  28Oct14 XN  100212 Added GetTradename
//  11Nov14 XN  43318 Added ToXMLHeap
//  27Apr15 XN  98073 Added LabelDescriptionInPatient and LabelDescriptionOutPatient
//  06May15 XN  117528 Fixed issue with modified data not being updated correctly
//  19May15 XN  98073 Added LocalDescription
//  24Sep15 XN  77778 Moved alias methods from SiteProductData to BaseTable2 
//  12Jun15 XN  39882 Added LoadByProductIDVMPorAMP renamed MaxInfusionRate to MaxInfusionRateInmL
//  13Jul15 XN  39882 Added ValidateIssue, and ValidateStockLevel (replace vb6 method DoChkIssue)
//  14Apr16 XN  123082 Added ToLocalOrLabelString
//  26Apr16 XN  123082 DosingUnits trimmed field
//  15Jul16 XN  126634 Trimmed the NewEDILinkCode, LoadBySupplierAndEdiCode 
//  21Jul16 XN  126634 ProductDescription if drug does not exist got it to return empty string
//  24Jun16 XN  108889 Added SiteNumber and iAltSupCode to ToXMLHeap
//              Added outputting interface file from save
//  25Jul16 XN  126634 Added EDIBarcode
//  15Aug16 XN  108889 Added SiteNumber and iAltSupCode to ToXMLHeap
//              Added outputting interface file from save
//  17Aug16 XN  160445 In ParsexML added iVatCode
//  26Aug16 XN  161234 Updated iBatchTrack print tag due to changes in BatchTracking enum
//  2Nov16  XN  167058 make search case insensitive
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Xml;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Represents a record in the WProduct view</summary>
    public class WProductRow : BaseRow
    {
        #region ID Properties
        public string NSVCode             
        { 
            get { return FieldToStr(RawRow["siscode"], false, string.Empty);  } 
            set { RawRow["siscode"] = StrToField(value, false);               }
        }

        public int DrugID
        { 
            get { return FieldToInt(RawRow["Drugid"]) ?? 0; } 
            set { RawRow["Drugid"] = IntToField(value);      }
        }

        public int SiteID              
        { 
            get { return FieldToInt(RawRow["LocationID_Site"]).Value;   } 
            set { RawRow["LocationID_Site"] = IntToField(value);        }
        }
        public string Barcode 
        { 
            get { return FieldToStr(RawRow["barcode"], false, string.Empty);  } 
            set { RawRow["barcode"] = StrToField(value, false);               }
        }

        public int DSSMasterSiteID     
        { 
            get { return FieldToInt(RawRow["DSSMasterSiteID"]) ?? 0; } 
            set { RawRow["DSSMasterSiteID"] = IntToField(value);     } 
        }    
        
        public int SiteProductDataID   
        { 
            get { return FieldToInt(RawRow["SiteProductDataID"]) ?? 0; } 
            set { RawRow["SiteProductDataID"] = IntToField(value);     }
        }    

        public int ProductStockID      
        { 
            get { return FieldToInt(RawRow["ProductStockID"]) ?? 0; } 
            set { RawRow["ProductStockID"] = IntToField(value);     }
        }    

        public int WSupplierProfileID  
        { 
            get { return FieldToInt(RawRow["WSupplierProfileID"]) ?? 0; } 
            set { RawRow["WSupplierProfileID"] = FieldToInt(value);     }
        }    

        /// <summary>
        /// BNF code for the drug 
        /// 01Nov13 XN 56701 Got to format BNF correctly
        /// </summary>
        public string BNF 
        { 
            get { return StringExtensions.FormatBNF(FieldToStr(RawRow["BNF"], false, string.Empty)); } 
            set { RawRow["BNF"] = StrToField(value, false);                                          }
        }

        /// <summary>
        /// Relates the WProduct to an ICW product
        /// If 0 then it is stores only item (see IsStoresOnly)
        /// </summary>
		public int? ProductID 
        { 
            get { return FieldToInt(RawRow["ProductId"]);   } 
            set { RawRow["ProductId"] = IntToField(value);  }
        }

        /// <summary>
        /// Not unique code but used by pharmacists as quick look up items
        /// Drug description and type encoded in the code!
        /// </summary>
        public string Code 
        { 
            get { return FieldToStr(RawRow["code"], false, string.Empty); } 
            set { RawRow["code"] = StrToField(value, false);              } 
        }

        /// <summary>db field local</summary>
        public string LocalProductCode 
        { 
            get { return FieldToStr(RawRow["local"], false, string.Empty); } 
            set { RawRow["local"] = StrToField(value);                     }
        }

        /// <summary>DM&D reference</summary>
        public long? DMandDReference
        {
            get { return FieldToLong(RawRow["DMandDReference"]); } 
            set { RawRow["DMandDReference"] = LongToField(value); } 
        }

        /// <summary>db field [PIL2]</summary>
        public string CMICode
        {
            get { return FieldToStr(RawRow["PIL2"], false, string.Empty); } 
            set { RawRow["PIL2"] = StrToField(value); } 
        }

        public string EDILinkCode
        {
            //get { return FieldToStr(RawRow["EDILinkCode"], false, string.Empty); } 
            get { return FieldToStr(RawRow["EDILinkCode"], true,  string.Empty); }  // 28Jun16 XN 126641
            set { RawRow["EDILinkCode"] = StrToField(value);                     } 
        }

        /// <summary>
        /// EDI barcode from supplier profile
        /// 22Jul16 XN 126634 
        /// </summary>
        public string EDIBarcode
        {
            get { return FieldToStr(RawRow["EDIBarcode"], true, string.Empty); }
            set { RawRow["EDIBarcode"] = StrToField(value);                    } 
        }

        public string PASANPCCode
        {
            get { return FieldToStr(RawRow["PASANPCCode"], false, string.Empty); } 
            set { RawRow["PASANPCCode"] = StrToField(value);                     } 
        }
        #endregion

        #region Description Properties
        /// <summary>
        /// Gets the drug description (as same db field)
        /// either LocalDescription, StoresDescription, LabelDescription
        /// </summary>
        public string Description          
        { 
            get
            {
                string description = FieldToStr(RawRow["description"], true, string.Empty);

                // If created new row in code, then might be empty as can't set as read only, so manually get the value 8Jun15 XN 98073
                if (string.IsNullOrEmpty(description))
                {
                    if (!string.IsNullOrEmpty(this.LocalDescription))
                        description = this.LocalDescription;
                    else if (!string.IsNullOrEmpty(this.StoresDescription))
                        description = this.StoresDescription;
                    else if (!string.IsNullOrEmpty(this.LabelDescription))
                        description = this.LabelDescription;
                }
                
                return description;
            } 
        }
        
        public string LabelDescription     
        { 
            get { return FieldToStr(RawRow["LabelDescription"], true, string.Empty);   } 
            set { RawRow["LabelDescription"] = StrToField(value, false);               }
        }

        public string StoresDescription    
        { 
            internal get { return FieldToStr(RawRow["storesdescription"], true, string.Empty); } // Should not call this directly instead either use Description (as stores description comes from ProductStock XN 9Jun15 98073)
            set { RawRow["storesdescription"] = StrToField(value, false); }
        }

        public string Tradename
        { 
            get { return FieldToStr(RawRow["Tradename"], true, string.Empty);   } 
            set { RawRow["Tradename"] = StrToField(value, false);               }
        }

        /// <summary>Return the description text which is either LocalDescription, StoresDescription, LabelDescription</summary>
        /// <returns>Product description</returns>
        public override string ToString()
        {
            //if (!string.IsNullOrEmpty(StoresDescription))
            //    return StoresDescription.Replace('!', ' ');
            //else if (!string.IsNullOrEmpty(Description))
            //    return Description.Replace('!', ' ');
            //else
            //    return string.Empty;
            return this.Description.Replace('!', ' ');
        }

        /// <summary>Return the description text which is either LocalDescription, LabelDescription 14Apr16 XN 123082</summary>
        /// <returns>Product description</returns>
        public string ToLocalOrLabelString()
        {
            return (string.IsNullOrWhiteSpace(this.LocalDescription) ? this.LabelDescription : this.LocalDescription).Replace('!', ' ');
        }

        /// <summary>
        /// DB field [LabelInIssueUnits]
        /// Returns if the label printed in issue units.
        /// </summary>
        public bool? IsLabelInIssueUnits 
        { 
            get { return FieldToBoolean(RawRow["LabelInIssueUnits"]);  } 
            set { RawRow["LabelInIssueUnits"] = BooleanToField(value); }
        }
        #endregion

        #region Local Site Descriptions
        /// <summary>
        /// Gets or sets site specific in patient label description 
        /// DB field [ProductStock.LabelDescriptionInPatient]
        /// XN 27Apr15 98073
        /// </summary>        
        public string LabelDescriptionInPatient     
        { 
            get { return this.FieldToStr(this.RawRow["LabelDescriptionInPatient"], trimString: true, nullVal: string.Empty);    } 
            set { this.RawRow["LabelDescriptionInPatient"] = this.StrToField(value, emptyStrAsNullVal: true);                   }
        }

        /// <summary>
        /// Gets or sets site specific out patient label description 
        /// DB field [ProductStock.LabelDescriptionOutPatient]
        /// XN 27Apr15 98073
        /// </summary>        
        public string LabelDescriptionOutPatient     
        { 
            get { return this.FieldToStr(this.RawRow["LabelDescriptionOutPatient"], trimString: true, nullVal: string.Empty);   } 
            set { this.RawRow["LabelDescriptionOutPatient"] = this.StrToField(value, emptyStrAsNullVal: true);                  }
        }

        /// <summary>
        /// Gets or sets site specific local description 
        /// DB field [ProductStock.LocalDescription]
        /// XN 19May15 98073
        /// </summary>        
        public string LocalDescription     
        { 
            get { return this.FieldToStr(this.RawRow["LocalDescription"], trimString: true, nullVal: string.Empty);   } 
            set { this.RawRow["LocalDescription"] = this.StrToField(value, emptyStrAsNullVal: true);                  }
        }
        #endregion

        #region Unit of Measure Properties
        /// <summary>DB real field</summary>
        public decimal mlsPerPack  
        { 
            get { return FieldToDecimal(RawRow["mlsperpack"]) ?? 0m; }
            set { RawRow["mlsperpack"] = DecimalToField(value);      } 
        }  

        /// <summary>DB int field convfact</summary>
        public int  ConversionFactorPackToIssueUnits 
        { 
            get { return FieldToInt(RawRow["convfact"]).Value; } 
            set { RawRow["convfact"] = IntToField(value);      }
        }

        /// <summary>unit of the active ingredient</summary>
        public string  DosingUnits 
        { 
            //get { return FieldToStr(RawRow["DosingUnits"], false, string.Empty); }    28Apr16 XN 123082 trimmed field
            get { return FieldToStr(RawRow["DosingUnits"], true, string.Empty); } 
            set { RawRow["DosingUnits"] = StrToField(value);                    }
        }  

        public double? DosesPerIssueUnit
        { 
            get { return FieldToDouble(RawRow["DosesperIssueUnit"]);    } 
            set { RawRow["DosesperIssueUnit"] = DoubleToField(value);   } 
        }  

        /// <summary>
        /// This is the issue units (will always be in lower case)
        /// If db field is null defaults to empty string.
        /// Can be an empty string if drug is of a non standard type.
        /// </summary>
        public string PrintformV 
        { 
            get { return FieldToStr(RawRow["printformv"], true, string.Empty).ToLower(); } 
            set { RawRow["printformv"] = StrToField(value); }
        }

        /// <summary>
        /// Dose expansion form
        /// If db field is null defaults to empty string.
        /// </summary>
        public string DPSForm 
        { 
            get { return FieldToStr(RawRow["DPSForm"], true, string.Empty).ToLower(); } 
            set { RawRow["DPSForm"] = StrToField(value);                              }
        }


        /// <summary>
        /// Small text description of what the pack is (pack, bag, bottle).
        /// If db field is null defaults to empty string.
        /// Can be an empty string if drug is of a non standard type.
        /// </summary>
        public string StoresPack { get { return FieldToStr(RawRow["StoresPack"], true, string.Empty); } }
        #endregion

        #region Financial Properties
        /// <summary>
        /// DB int field vatrate
        /// (this is correct as db is wrong and field should say vatrate)
        /// </summary>
        public int? VATCode 
        { 
            get { return FieldToInt(RawRow["vatrate"]);  }  
            set { RawRow["VatRate"] = IntToField(value); }
        }
  
        /// <summary>
        /// Converts VATCode to a rate (uses the druges site id for the conversion).
        /// </summary>
        public decimal? VATRate { get { return PharmacyConverters.VatCodeToRate(SiteID, VATCode); } }
  
        /// <summary>
        /// DB string field [cost].
        /// Represents the average cost (excluding vat) of a pack for the current stock (in pence).
        /// </summary>
        public decimal AverageCostExVatPerPack  
        { 
            //get { return FieldStrToDecimal(RawRow["cost"]).Value; } XN 03Mar14 for product editor
            get { return FieldStrToDecimal(RawRow["cost"]) ?? 0; } 
            set { RawRow["cost"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().AverageCostIncVatPerPackLength); }
        }

        /// <summary>
        /// DB float field [lossesgains].
        /// Represents the total losses and gains (excluding vat, in pence).
        /// This can be used to prevent the average cost value from going -ve, or going too high.
        /// </summary>
        public decimal LossesGainExVat 
        { 
            get { return FieldToDecimal(RawRow["lossesgains"]).Value; } 
            set { RawRow["lossesgains"] = DecimalToField(value);      }
        }

        /// <summary>
        /// DB double field [sisListPrice]
        /// Represents the price of the drug, when it was last received from the supplier.
        /// Price is per pack, excluding vat, and in pence
        /// </summary>
        public decimal? LastReceivedPriceExVatPerPack 
        { 
            get { return FieldToDecimal(RawRow["sisListPrice"]); }
            set { RawRow["sisListPrice"] = DecimalToFieldStr(value, WSupplierProfile.GetColumnInfo().LastReceivedPriceExVatPerPackLength); }
        }

        /// <summary>
        /// DB double field [LastReconcilePrice]
        /// Price is per pack, excluding vat, and in pence
        /// </summary>
        public decimal? LastReconcilePriceExVatPerPack   
        { 
            get { return FieldToDecimal(RawRow["LastReconcilePrice"]); } 
            set { RawRow["LastReconcilePrice"] = DecimalToFieldStr(value, WSupplierProfile.GetColumnInfo().LastReconcilePriceExVatPerPackLength, true); }
        }         

        /// <summary>
        /// DB char fiel [pflag]
        /// If manual pricing, or auto pricing, or no pricing
        /// </summary>
        public PricingType PricingFlag { get { return FieldToEnumByDBCode<PricingType>(RawRow["pflag"]); } }
        #endregion

        #region Supplier Info Properties (mainly primary supplier info)
        /// <summary>
        /// DB string field SupplierTradeName
        /// Name given to the drug by the supplier.
        /// </summary>
        public string SupplierTradename 
        { 
            get { return FieldToStr(RawRow["SupplierTradeName"], false, string.Empty); } 
            set { RawRow["SupplierTradeName"] = StrToField(value);                     }
        }

        /// <summary>DB string field supcode</summary>
        public string SupplierCode 
        { 
            get { return FieldToStr(RawRow["supcode"], false, string.Empty); } 
            set { RawRow["supcode"] = StrToField(value, false);              }
        }

        /// <summary>DB string field altsupcode</summary>
        public string AlternateSupplierCode 
        { 
            get { return FieldToStr(RawRow["altsupcode"], false, string.Empty); } 
            set { RawRow["altsupcode"] = StrToField(value);                     }
        }

        /// <summary>DB string field leadtime</summary>
        public decimal? LeadTimeInDays 
        { 
            get { return FieldStrToDecimal(RawRow["leadtime"]); } 
            set { RawRow["leadtime"] = DecimalToFieldStr(value, WProduct.GetColumnInfo().LeadTimeLength, true); }
        }

        /// <summary>DB string field [ContNo]</summary>
        public string ContractNumber
        {
            get { return FieldToStr(RawRow["ContNo"], true, string.Empty); }
            set { RawRow["ContNo"] = StrToField(value);                    }
        }

        /// <summary>DB string field [ContPrice]</summary>
        public decimal? ContractPrice
        {
            get { return FieldStrToDecimal(RawRow["ContPrice"]);   }
            set { RawRow["ContPrice"] = DecimalToFieldStr(value, WProduct.GetColumnInfo().ContractPriceLength, true); }
        }
        
        /// <summary>
        /// Name used by the supplier for the drug
        /// DB string field [SuppRefNo]
        /// </summary>
        public string SupplierReferenceNumber
        {
            get { return FieldToStr(RawRow["SuppRefNo"], false, string.Empty);  }
            set { RawRow["SuppRefNo"] = StrToField(value);                      }
        }
        
        /// <summary>Eitehr uses the SupplierTradname but if blank will display the tradname field (will trim field) 28Oct14 XN 100212</summary>
        public string GetTradename()
        {
            return (string.IsNullOrWhiteSpace(this.SupplierTradename) ? this.Tradename : this.SupplierTradename).Trim();
        }
        #endregion

        #region Stores Properties 
        public DateTime? LastIssuedDate     
        { 
            get { return FieldStrDateToDateTime(RawRow["lastissued"],  DateType.DDMMYYYY);               } 
            set { RawRow["lastissued"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); } 
        }

        public DateTime? LastOrderedDate    
        { 
            get { return FieldStrDateToDateTime(RawRow["lastordered"], DateType.DDMMYYYY);  } 
            set { RawRow["lastordered"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); } 
        }

        /// <summary>
        /// If product is in use.
        /// Null's, and 'S' values are converted to true, as these are legacy issues with the data.
        /// </summary>
        public bool InUse 
        { 
            get { return FieldToBoolean(RawRow["InUse"], true).Value;               } 
            set { RawRow["InUse"] = BooleanToField(value, "Y", "N", string.Empty);  } 
        }

        /// <summary>
        /// DB string field [stocklvl].
        /// Represents the stock level in issues units.
        /// </summary>
        public decimal StockLevelInIssueUnits   
        { 
            get { return FieldStrToDecimal(RawRow["Stocklvl"]) ?? 0m; } 
            set { RawRow["stocklvl"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().StockLevelLength, false); }
        }

        /// <summary>DB string field [ReorderLvl]</summary>
        public decimal? ReorderLevelInIssueUnits 
        { 
            get { return FieldToDecimal(RawRow["ReorderLvl"]);} 
            set { RawRow["ReorderLvl"] = DecimalToFieldStr(value, WSupplierProfile.GetColumnInfo().ReorderLevelLength, true); }
        }

        /// <summary>DB string field [livestockctrl]</summary>
        public bool? IfLiveStockControl 
        { 
            get { return FieldToBoolean(RawRow["livestockctrl"]);            }
            set { RawRow["livestockctrl"] = BooleanToField(value, "Y", "N"); } 
        }

        /// <summary>
        /// DB int field [laststocktakedate], and string field [laststocktaketime]
        /// </summary>
        public DateTime? LastStockTakeDateTime
        {
            get 
            { 
                DateTime? dateReceived = FieldStrDateToDateTime(RawRow["laststocktakedate"], DateType.DDMMYYYY);
                TimeSpan? timeReceived = FieldStrTimeToTimeSpan(RawRow["laststocktaketime"]);

                if (dateReceived.HasValue && timeReceived.HasValue)
                    return dateReceived.Value + timeReceived.Value;
                else 
                    return null;
            }
            set 
            {
                RawRow["laststocktakedate"] = DateTimeToFieldStrDate(value, "", DateType.DDMMYYYY); 
                RawRow["laststocktaketime"] = DateTimeToFieldStrTime(value, true); 
            }  
        }

        public StockTakeStatusType StockTakeStatus 
        { 
            get { return FieldToEnumByDBCode<StockTakeStatusType>(RawRow["stocktakestatus"]); } 
            set { RawRow["stocktakestatus"] = EnumToFieldByDBCode(value);                     }
        }

        public decimal? ReorderPackSize          
        { 
            get { return FieldStrToDecimal(RawRow["ReorderPckSize"]); } 
            set { RawRow["ReorderPckSize"] = DecimalToFieldStr(value, WSupplierProfile.GetColumnInfo().ReorderPackSizeLength, true); }
        }

        public bool? ReCalculateAtPeriodEnd   
        { 
            get { return FieldToBoolean(RawRow["ReCalcatPeriodEnd"]); } 
            set { RawRow["ReCalcatPeriodEnd"] = BooleanToField(value, "Y", "N", string.Empty); }
        }

        /// <summary>
        /// DB string field reorderqty
        /// suggested reorder quantity (calucated from a number of factors).
        /// </summary>
        public decimal ReOrderQuantityInPacks 
        { 
            get { return FieldStrToDecimal(RawRow["reorderqty"]) ?? 0m; } 
            set { RawRow["reorderqty"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().ReOrderQuantityInPacksLength);} 
        }

        /// <summary>DB double field outstanding</summary>
        public double OutstandingInIssueUnits  
        { 
            get { return FieldToDouble(RawRow["outstanding"]).Value; } 
            set { RawRow["Outstanding"] = DoubleToField(value);      } 
        }

        /// <summary>
        /// Flag used to group products in to particular order cycle (e.g. cycle A, B, C)
        /// Cycles are user definable
        /// </summary>
        public string OrderCycle 
        { 
            get { return FieldToStr(RawRow["ordercycle"], true); } 
            set { RawRow["ordercycle"] = StrToField(value);      }
        }

        /// <summary>Order cycle length in days</summary>
        public int CycleLengthInDays 
        { 
            get { return FieldToInt(RawRow["cyclelength"]).Value; } 
            set { RawRow["cyclelength"] = IntToField(value);      }
        }

        /// <summary>
        /// DB string field sisstock
        /// If false then normal order as needed.
        /// </summary>
        public bool? IsStocked 
        { 
            get { return FieldToBoolean(RawRow["SisStock"]);                           } 
            set { RawRow["SisStock"] = BooleanToField(value, "Y", "N", string.Empty);  }
        }

        /// <summary>Shelf, bin, or other general location code</summary>
        public string Location  
        { 
            get { return FieldToStr(RawRow["loccode"],  true); } 
            set { RawRow["LocCode"] = StrToField(value); }
        }

        /// <summary>Shelf, bin, or other general location code</summary>
        public string Location2 
        { 
            get { return FieldToStr(RawRow["loccode2"], true); } 
            set { RawRow["loccode2"] = StrToField(value); }
        }    

        /// <summary>If the product is only present in stored not given to patients (like a bottle)</summary>
        public bool IsStoresOnly { get { return !ProductID.HasValue || (ProductID.Value == 0); } }

        /// <summary>DB field [datelastperiodend]|</summary>
        public DateTime? StartOfPeriod
        {
            get { return FieldStrDateToDateTime(RawRow["datelastperiodend"], DateType.DDMMYYYY); }
            set { RawRow["datelastperiodend"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); }
        }

        public double SafetyFactor
        {
            get { return FieldToDouble(RawRow["SafetyFactor"]).Value; }
            set { RawRow["SafetyFactor"] = DoubleToField(value); }
        }

        public double UsageDamping
        {
            get { return FieldToDouble(RawRow["usagedamping"]) ?? 0; }
            set { RawRow["usagedamping"] = DoubleToField(value);     }
        }

        public double UseThisPeriodInIssueUnits
        {
            get { return FieldToDouble(RawRow["UseThisPeriod"]) ?? 0; }
            set { RawRow["UseThisPeriod"] = DoubleToField(value);     }
        }
        
        /// <summary>Drug expiry time in minutes</summary>
        public int ExpiryTimeInMintues
        {
            get { return FieldToInt(RawRow["expiryminutes"]) ?? 0;  }
            set { RawRow["expiryminutes"] = IntToField(value);      }
        }

        /// <summary>Db code [ReconVol]</summary>
        public double? ReconstitutionVolumeInml
        {
            get { return FieldToDouble(RawRow["ReconVol"]);  } 
            set { RawRow["ReconVol"] = DoubleToField(value); } 
        }

        /// <summary>Db code [ReconAbbr]</summary>
        public string ReconstitutionAbbreviation
        {
            get { return FieldToStr(RawRow["ReconAbbr"], false, string.Empty); } 
            set { RawRow["ReconAbbr"] = StrToField(value);                     }
        }
        
        /// <summary>Db code [mgPerml]</summary>
        public double? FinalConcentrationInDoseUnitsPerml
        {
            get { return FieldToDouble(RawRow["mgPerml"]);  } 
            set { RawRow["mgPerml"] = DoubleToField(value); } 
        }

        /// <summary>Db code [MaxmgPerml]</summary>
        public double? MaxConcentrationInDoseUnitsPerml
        {
            get { return FieldToDouble(RawRow["MaxmgPerml"]);  } 
            set { RawRow["MaxmgPerml"] = DoubleToField(value); } 
        }

        /// <summary>Db code [MinmgPerml]</summary>
        public double? MinConcentrationInDoseUnitsPerml
        {
            get { return FieldToDouble(RawRow["MinmgPerml"]);  } 
            set { RawRow["MinmgPerml"] = DoubleToField(value); } 
        }

        /// <summary>Db code [Diluent1]</summary>
        public string DiluentAbbreviation1 
        { 
            get { return FieldToStr(RawRow["Diluent1"], false, string.Empty); } 
            set { RawRow["Diluent1"] = StrToField(value);                     }
        }

        /// <summary>Db code [Diluent2]</summary>
        public string DiluentAbbreviation2
        { 
            get { return FieldToStr(RawRow["Diluent2"], false, string.Empty); } 
            set { RawRow["Diluent2"] = StrToField(value);                     }
        }

        public string IVContainer
        {
            get { return FieldToStr(RawRow["IVContainer"], false, string.Empty).ToUpper(); } 
            set { RawRow["IVContainer"] = StrToField(value);                               }
        }

        /// <summary>Db code [DisplacementVolume]</summary>
        public double? DisplacementVolumeInml
        {
            get { return FieldToDouble(RawRow["DisplacementVolume"]);  } 
            set { RawRow["DisplacementVolume"] = DoubleToField(value); }
        }

        /// <summary>
        /// Patient Information Leaflet number (relates to a {PILnumber}.PIL file)
        /// Relates to value in WConfiguration "D|PILdesc", ""
        /// </summary>
        public int PILnumber
        {
            get { return FieldToInt(RawRow["PILnumber"]) ?? 0;} 
            set { RawRow["PILnumber"] = IntToField(value);    }
        }

        /// <summary>If the item is to be excluded from products suitable for PN</summary>
        public bool PNExclude 
        { 
            get { return FieldToBoolean(RawRow["PNExclude"], false).Value; } 
            set { RawRow["PNExclude"] = BooleanToField(value);             }
        }
        
        /// <summary>DB code [pflag]</summary>
        public bool IsReconcileIfZeroPrice
        {
            get { return FieldToBoolean(RawRow["pflag"], true).Value; } 
            set { RawRow["pflag"] = BooleanToField(value, "Y", "N");            } 
        }

        public bool EyeLabel
        {
            get { return FieldToBoolean(RawRow["EyeLabel"], false).Value; } 
            set { RawRow["EyeLabel"] = BooleanToField(value);            } 
        }

        public bool PSOLabel
        {
            get { return FieldToBoolean(RawRow["PSOLabel"], false).Value; } 
            set { RawRow["PSOLabel"] = BooleanToField(value);            } 
        }

        public int? ExpiryWarnDays
        {
            get { return FieldToInt(RawRow["ExpiryWarnDays"]);  } 
            set { RawRow["ExpiryWarnDays"] = IntToField(value); } 
        }
        #endregion

        #region General Properties
        /// <summary>Can be null in some database but not sure if should default to false or be kept as null</summary>
        public bool? CanUseSpoon 
        { 
            get { return FieldToBoolean(RawRow["Canusespoon"]); }
            set { RawRow["Canusespoon"] = BooleanToField(value, true, false); }
        }
        
        public bool? IssueWholePack          
        { 
            get { return FieldToBoolean(RawRow["issueWholePack"]);                          } 
            set { RawRow["issueWholePack"] = BooleanToField(value, "Y", "N", string.Empty); } 
        }      

        public decimal? MinIssueInIssueUnits    
        { 
            get { return FieldStrToDecimal(RawRow["minissue"]); } 
            set { RawRow["minissue"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().MinIssueInIssueUnitsLength, true); } 
        }

        public decimal? MaxIssueInIssueUnits    
        { 
            get { return FieldStrToDecimal(RawRow["maxissue"]); } 
            set { RawRow["maxissue"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().MaxIssueInIssueUnitsLength, true); } 
        }
        
        public string LedgerCode 
        { 
            get { return FieldToStr(RawRow["Ledcode"], false, string.Empty);} 
            set { RawRow["Ledcode"] = StrToField(value, false);             } 
        }

        /// <summary>
        /// Supposed to be therapeutic code for an item,  
        /// but tends to be used by other things (as user editable field)
        /// </summary>
        public string TherapyCode 
        { 
            get { return FieldToStr(RawRow["Therapcode"], false, string.Empty); } 
            set { RawRow["Therapcode"] = StrToField(value, false);              }
        }

        public BatchTrackingType BatchTracking 
        { 
            get { return FieldToEnumByDBCode<BatchTrackingType>(RawRow["BatchTracking"]);   } 
            set { RawRow["BatchTracking"] = EnumToFieldByDBCode<BatchTrackingType>(value);  } 
        }

        /// <summary>Returns the raw single char code from ProductStock.Formulary</summary>
        public string FormularyCode 
        { 
            get { return FieldToStr(RawRow["Formulary"]);         } 
            set { RawRow["Formulary"] = StrToField(value, false); }
        }

        /// <summary>
        /// Returns enum conversion of ProductStock.Formulary
        /// This won't work on one or two sites (like Plymouth) as they incorrectly use there own set of codes
        /// </summary>
        public FormularyType FormularyType  
        { 
            get { return FieldToEnumByDBCode<FormularyType>(RawRow["Formulary"]); } 
            set { RawRow["Formulary"] = EnumToFieldByDBCode(value);               }
        }

        /// <summary>
        /// DB string field [anuse]
        /// Number of issue units in a year
        /// </summary>
        public decimal? AnnualUsageInIssueUnits 
        { 
            get { return FieldStrToDecimal(RawRow["anuse"]); }
            set { RawRow["anuse"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().AnnualUsageInIssueUnitsLength, true); } 
        } 

        /// <summary>
        /// Calcualtes the estimated out of stock date
        ///     today + (stock level - outstanding) / daily usage
        ///     
        /// Returns null if annual usage is null, or days left till exipry -ve or => 32767    
        /// </summary>
        public DateTime? EstimatedOutOfStockDate
        {
            get
            {
                if (!AnnualUsageInIssueUnits.HasValue)
                    return null;

                decimal dailyRateOfUse = AnnualUsageInIssueUnits.Value / 365.25m;
                if (dailyRateOfUse == 0m)
                    return null;

                decimal daysLeft = (StockLevelInIssueUnits - (decimal)OutstandingInIssueUnits) / dailyRateOfUse;
                if ((daysLeft < 0m) || (daysLeft >= 32767m))
                    return null;

                return DateTime.Now.AddDays((double)daysLeft);
            }
        }

        /// <summary>DB string field [cyto]</summary>
        public bool? IsCytotoxic 
        { 
            get { return FieldToBoolean(RawRow["cyto"]);                          } 
            set { RawRow["cyto"] = BooleanToField(value, "Y", "N", string.Empty); } 
        }

        public bool? IsCIVAS
        { 
            get { return FieldToBoolean(RawRow["CIVAS"]);                          } 
            set { RawRow["CIVAS"] = BooleanToField(value, "Y", "N", string.Empty); } 
        }
        
        /// <summary>DB string field [message].</summary>
        public string Notes 
        { 
            get { return FieldToStr(RawRow["message"], false, string.Empty); } 
            set { RawRow["message"] = StrToField(value, false);              }
        }

        /// <summary>DB string field [UserMsg] 30Jan14 XN 56701</summary>
        public string MessageCode
        {
            get { return FieldToStr(RawRow["UserMsg"], true, string.Empty); } 
            set { RawRow["UserMsg"] = StrToField(value, false);              }
        }

        public string ExtraLabel
        {
            get { return FieldToStr(RawRow["extralabel"], false, string.Empty);  }
            set { RawRow["extralabel"] = StrToField(value); }
        }
        
        public double? MinDailyDose
        { 
            get { return FieldToDouble(RawRow["MinDailyDose"]);    } 
            set { RawRow["MinDailyDose"] = DoubleToField(value);   } 
        }  

        public double? MaxDailyDose
        { 
            get { return FieldToDouble(RawRow["MaxDailyDose"]);    } 
            set { RawRow["MaxDailyDose"] = DoubleToField(value);   } 
        }  

        public double? MinDoseFrequency
        { 
            get { return FieldToDouble(RawRow["MinDoseFrequency"]);    } 
            set { RawRow["MinDoseFrequency"] = DoubleToField(value);   } 
        }  

        public double? MaxDoseFrequency
        { 
            get { return FieldToDouble(RawRow["MaxDoseFrequency"]);    } 
            set { RawRow["MaxDoseFrequency"] = DoubleToField(value);   } 
        }  

        /// <summary>
        /// Also known as Fix Volume for CIVAS!
        /// Value is in ml (despite the fact it is a rate)
        /// </summary>
        public double? MaxInfusionRateInmL
        { 
            get { return FieldToDouble(RawRow["MaxInfusionRate"]);    } 
            set { RawRow["MaxInfusionRate"] = DoubleToField(value);   } 
        }  

        public double InfusionTime  // 30Jan14 XN  56701 Added
        {
            get { return FieldToDouble(RawRow["InfusionTime"]).Value;   } 
            set { RawRow["InfusionTime"] = DoubleToField(value);        } 
        }

        public string PIPCode       // 30Jan14 XN  56701 Added
        {
            get { return FieldToStr(RawRow["pipcode"], true, string.Empty); } 
            set { RawRow["pipcode"] = StrToField(value, true);              } 
        }

        public string MasterPIP     // 30Jan14 XN  56701 Added
        {
            get { return FieldToStr(RawRow["MasterPIP"], true, string.Empty); } 
            set { RawRow["MasterPIP"] = StrToField(value, true);              } 
        }
        #endregion

        #region Info Text
        public string PhysicalDescription
        { 
            get { return FieldToStr(RawRow["PhysicalDescription"], true, string.Empty);  } 
            set { RawRow["PhysicalDescription"] = FieldToStr(value);                     } 
        }

        public string WarningCode     
        { 
            get { return FieldToStr(RawRow["warcode"], true, string.Empty); } 
            set { RawRow["warcode"] = StrToField(value);                    } 
        }

        public string WarningCode2     
        { 
            get { return FieldToStr(RawRow["warcode2"], true, string.Empty); } 
            set { RawRow["warcode2"] = StrToField(value);                    } 
        }

        public string InstructionCode
        { 
            get { return FieldToStr(RawRow["inscode"], true, string.Empty); } 
            set { RawRow["inscode"] = StrToField(value);                    } 
        }

        public string LabelFormat
        {
            get { return FieldToStr(RawRow["LabelFormat"], false, string.Empty); }
            set { RawRow["LabelFormat"] = StrToField(value);                     }
        }
        
        public string UserField1
        {
            get { return FieldToStr(RawRow["UserField1"], false, string.Empty); }
            set { RawRow["UserField1"] = StrToField(value);                     }
        }
        
        public string UserField2
        {
            get { return FieldToStr(RawRow["UserField2"], false, string.Empty); }
            set { RawRow["UserField2"] = StrToField(value);                     }
        }
        
        public string UserField3
        {
            get { return FieldToStr(RawRow["UserField3"], false, string.Empty); }
            set { RawRow["UserField3"] = StrToField(value);                     }
        }
        
        public string DDDValue
        {
            get { return FieldToStr(RawRow["DDDValue"], false, string.Empty); }
            set { RawRow["DDDValue"] = StrToField(value);                     }
        }    
        
        public string DDDUnits
        {
            get { return FieldToStr(RawRow["DDDUnits"], false, string.Empty); }
            set { RawRow["DDDUnits"] = StrToField(value);                     }
        }    
        
        public string HIProduct
        {
            get { return FieldToStr(RawRow["HIProduct"], false, string.Empty); }
            set { RawRow["HIProduct"] = StrToField(value);                     }
        }    
        #endregion 

        #region User Info
        public DateTime? CreatedDate
        {
            get 
            { 
                DateTime? date = FieldStrDateToDateTime(RawRow["createddate"], DateType.DDMMYYYY);
                TimeSpan? time = FieldStrTimeToTimeSpan(RawRow["createdtime"]);

                if (date.HasValue && time.HasValue)
                    return date.Value + time.Value;
                else 
                    return null;
            }
            set 
            {
                RawRow["createddate"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); 
                RawRow["createdtime"] = DateTimeToFieldStrTime(value, true); 
            }  
        }

        public string CreatedByUserInitials
        {
            get { return FieldToStr(RawRow["CreatedUser"], false, string.Empty); } 
            set { RawRow["CreatedUser"] = StrToField(value); } 
        }

        public string CreatedOnTerminal
        {
            get { return FieldToStr(RawRow["createdterminal"], false, string.Empty); } 
            set { RawRow["createdterminal"] = StrToField(value); } 
        }

        public DateTime? ModifiedDate
        {
            get 
            { 
                DateTime? date = FieldStrDateToDateTime(RawRow["modifieddate"], DateType.DDMMYYYY);
                TimeSpan? time = FieldStrTimeToTimeSpan(RawRow["modifiedtime"]);

                if (date.HasValue && time.HasValue)
                    return date.Value + time.Value;
                else 
                    return null;
            }
            set 
            {
                RawRow["modifieddate"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); 
                RawRow["modifiedtime"] = DateTimeToFieldStrTime(value, true); 
            }  
        }

        public string ModifiedByUserInitials
        {
            get { return FieldToStr(RawRow["modifieduser"], false, string.Empty); } 
            set { RawRow["modifieduser"] = StrToField(value); } 
        }

        public string ModifiedOnTerminal
        {
            get { return FieldToStr(RawRow["modifiedterminal"], false, string.Empty); } 
            set { RawRow["modifiedterminal"] = StrToField(value); } 
        }
        #endregion

        #region Helper Methods
        /// <summary>Loads and returns all alternative barcodes for this product 29Jan14 XN 82431 24Jul13 XN 24653</summary>
        public IEnumerable<string> GetAlternativeBarcode()
        {
            return (new SiteProductData()).GetAliases<string>(this.SiteProductDataID, "AlternativeBarcode");
            //return SiteProductData.GetAliases<string>(this.SiteProductDataID, "AlternativeBarcode");   24Sep15 XN  Moved alias methods from SiteProductData to BaseTable2 77778     
        }

        /// <summary>
        /// Displays the reorder pack size as formatted string 
        /// if conversionFactorPackToIssueUnits = 1
        ///     {reorder pack size} {printform V}
        /// else
        ///     {reorder pack size} x {conversion factor} {printform V}
        /// </summary>
        public string ReorderPackSizeAsFormattedString()
        {
            decimal reorderPackSize = this.ReorderPackSize ?? 1;
            if (this.ConversionFactorPackToIssueUnits == 1)
                return string.Format("{0} {1}", reorderPackSize, this.PrintformV);
            else
                return string.Format("{0} x {1} {2}", reorderPackSize.ToString(WProduct.GetColumnInfo().ReorderPackSizeLength), this.ConversionFactorPackToIssueUnits, this.PrintformV);
        }
        
        /// <summary>
        /// If DSS Maintained drug
        /// Only true way is to determin if there is a dss maintained drug is to check if there is a master SiteProductData row
        /// XN 30Jun14 94416
        /// </summary>
        public bool IsDSSMaintainedDrug()
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("DrugID", this.DrugID);
            return Database.ExecuteSPReturnValue<bool>("pSiteProductDataIsDSSMaintained", parameters); 
            //return (this.DrugID >= 0 && this.DrugID < 10000000 && this.ProductID != 0) || FieldToBoolean(this.RawRow["DSS"]).Value;  XN 30Jun14 94416
        }

        ///// <summary>
        ///// Gets the true dss master id (normaly same as this.DrugID)
        ///// But might be different if there is entry for it in DSSMasterSiteLinkSiteDrug
        ///// NULL if DSSMasterSiteLinkSiteDrug forces the drug not to have a master (site only drug)
        ///// XN 30Jun14 94416
        ///// </summary>
        //public int? GetTrueMasterDrugID()
        //{
        //    List<SqlParameter> parameters = new List<SqlParameter>();
        //    parameters.Add("DrugID", this.DrugID);
        //    int? masterID = Database.ExecuteScalar<int?>("pDSSMasterSiteLinkSiteDrugGetMasterDrugID", parameters); 
        //    if (masterID == null)
        //        return this.DrugID;
        //    else if (masterID < 0)
        //        return null;
        //    else
        //        return masterID;
        //}

        /// <summary>
        /// Returns total stock value exc vat
        ///     (Stock level in Issue Units * Average Cost per pack) + losses and gains
        /// </summary>
        public decimal CalcStockValueExVat()
        {
            if (this.ConversionFactorPackToIssueUnits == 0)
                throw new ApplicationException(string.Format("Invalid conversion factor of zero for product {0} and site ID {1}", this.NSVCode, this.SiteID));

            return ((this.StockLevelInIssueUnits / this.ConversionFactorPackToIssueUnits) * this.AverageCostExVatPerPack) + this.LossesGainExVat;
        }
        #endregion

        #region Printing Methods
        /// <summary>
        /// Implementation of SUBPATME.BAS FillHeapDrugInfo method
        ///  The XML will be in the form
        ///     {Heap 
        ///         iCode="{code}"
        ///         iDescription="{description}"
        ///         :
        ///     /}
        ///     
        /// No longer supports fields
        ///     iDeluserid
        ///     iAltsupcode - present but always empty string
        ///     iDirectioncode
        ///     iAtc
        ///     iIndexed
        ///     iIndexedyn
        ///     iATCcode
        ///     iChemical
        ///     
        /// Many of the xml node names are in form iCost/100 which is not XML compatable.
        /// These have been xml escaped, but it is unclear if these are unescaed at other end (this has not been tested)
        /// 
        /// Also a lot of double, and decimal values have been converted directly to string without any rounding applied to them 
        /// </summary>
        /// <returns>XML print heap</returns>
        public string ToXMLHeap()
        {
            // Setup xml writer 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.Indent             = true;
            settings.NewLineOnAttributes= true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("Heap");
                xmlWriter.WriteAttributeString("iCode", this.Code);
                xmlWriter.WriteAttributeString("SiteNumber", Site2.GetSiteNumberByID(this.SiteID).ToString("000")); // 15Aug16 XN 108889 Added 
                string description = this.Description.Replace('!', ' ');
                xmlWriter.WriteAttributeString("iDescription", description);
                xmlWriter.WriteAttributeString("iDescriptionXML", description.XMLEscape());
                string descriptionTrim = description.SafeSubstring(0, WConfiguration.LoadAndCache<int>(this.SiteID, "D|genint", "StockInterface", "DescriptionTrim", 20, false));
                xmlWriter.WriteAttributeString("iDescriptionTrim", descriptionTrim);
                xmlWriter.WriteAttributeString("iDescriptionTrimXML", descriptionTrim.XMLEscape());
                xmlWriter.WriteAttributeString("iInuse", this.InUse.ToYNString());
                xmlWriter.WriteAttributeString("iTradename", this.Tradename);
                xmlWriter.WriteAttributeString("iCost", this.AverageCostExVatPerPack.ToString("0.####"));
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iCost/100"), (this.AverageCostExVatPerPack / 100).ToString("0.00"));
                xmlWriter.WriteAttributeString("iContno", this.ContractNumber);
                xmlWriter.WriteAttributeString("iSupcode", this.SupplierCode);
                xmlWriter.WriteAttributeString("iWarningcode2", this.WarningCode2);
                xmlWriter.WriteAttributeString("iLedcode", this.LedgerCode);
                xmlWriter.WriteAttributeString("iNSVcode", this.NSVCode);
                xmlWriter.WriteAttributeString("iBarcode", this.Barcode);
                xmlWriter.WriteAttributeString("iCyto", this.IsCytotoxic.ToYNString());
                xmlWriter.WriteAttributeString("iCivas", this.IsCIVAS.ToYNString());
                xmlWriter.WriteAttributeString("iFormulary", this.FormularyCode);
                xmlWriter.WriteAttributeString("iBnf", this.BNF);
                xmlWriter.WriteAttributeString("iReconvol", this.ReconstitutionVolumeInml.ToString());
                xmlWriter.WriteAttributeString("iReconabbr", this.ReconstitutionAbbreviation);
                xmlWriter.WriteAttributeString("iDiluent1abbr", this.DiluentAbbreviation1);
                xmlWriter.WriteAttributeString("iDiluent2abbr", this.DiluentAbbreviation2);
                xmlWriter.WriteAttributeString("iMaxmgPerml", this.MaxConcentrationInDoseUnitsPerml.ToString());
                xmlWriter.WriteAttributeString("iWarningcode", this.WarningCode);
                xmlWriter.WriteAttributeString("iInscode", this.InstructionCode);
                xmlWriter.WriteAttributeString("iLabelformat", this.LabelFormat);
                xmlWriter.WriteAttributeString("iExpirymin", this.ExpiryTimeInMintues.ToString());
                xmlWriter.WriteAttributeString("iExpiryDays", ((this.ExpiryTimeInMintues + 1339) / 1440).ToString());
                xmlWriter.WriteAttributeString("iStockedyn", this.IsStocked.ToYesNoString().PadRight(5, ' '));
                xmlWriter.WriteAttributeString("iStocked", this.IsStocked.ToYNString());
                xmlWriter.WriteAttributeString("iReordpcksize", this.ReorderPackSize.ToString());
                xmlWriter.WriteAttributeString("iPrintform", this.PrintformV);
                xmlWriter.WriteAttributeString("iMinissue", this.MinIssueInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iMaxissue", this.MaxIssueInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iReorderlevel", this.ReorderLevelInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iReorderquantity", this.ReOrderQuantityInPacks.ToString());
                xmlWriter.WriteAttributeString("iPackSize", this.ConversionFactorPackToIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iAnuse", this.AnnualUsageInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iMessage", this.Notes);
                xmlWriter.WriteAttributeString("iTherapcode", this.TherapyCode);
                xmlWriter.WriteAttributeString("iExtralabel", this.ExtraLabel);
                xmlWriter.WriteAttributeString("iStocklevel", this.StockLevelInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iSislistprice", this.LastReceivedPriceExVatPerPack.ToString());
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iSislistprice/100"), (this.LastReceivedPriceExVatPerPack / 100).ToString("0.00"));
                xmlWriter.WriteAttributeString("iContprice", this.ContractPrice.ToString());
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iContprice/100"), (this.ContractPrice / 100).ToString("0.00"));
                xmlWriter.WriteAttributeString("iLivestock", this.IfLiveStockControl.ToYNString());
                xmlWriter.WriteAttributeString("iLeadtime",this.LeadTimeInDays.ToString());
                xmlWriter.WriteAttributeString("iLeadtimeVal", this.LeadTimeInDays.ToString());
                xmlWriter.WriteAttributeString("iLocation", this.Location);
                xmlWriter.WriteAttributeString("iUsagedamping", this.UsageDamping.ToString());
                xmlWriter.WriteAttributeString("iSafetyfactor", this.SafetyFactor.ToString());
                xmlWriter.WriteAttributeString("iRecalcatperiodend", this.ReCalculateAtPeriodEnd.ToYNString());
                xmlWriter.WriteAttributeString("iLossesgains", this.LossesGainExVat.ToString());
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iLossesgains/100"), (this.LossesGainExVat / 100).ToString("0.00"));
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iDoses/Issunit"), this.DosesPerIssueUnit.ToString());
                xmlWriter.WriteAttributeString("iMlsperpack", this.mlsPerPack.ToString());
                xmlWriter.WriteAttributeString("iOrdercycle", this.OrderCycle);
                xmlWriter.WriteAttributeString("iCyclelength", this.CycleLengthInDays.ToString());
                xmlWriter.WriteAttributeString("iReconcileprice", this.LastReconcilePriceExVatPerPack.ToString());
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iReconcileprice/100"), (this.LastReconcilePriceExVatPerPack / 100).ToString("0.00"));
                xmlWriter.WriteAttributeString("iOutstanding", this.OutstandingInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iUseThisPeriod", this.UseThisPeriodInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iVATrate", this.VATRate == null ? string.Empty : this.VATRate.ToString("0.##"));
                xmlWriter.WriteAttributeString("iVATCode", this.VATCode == null ? string.Empty : this.VATCode.ToString());          // 17Aug16 XN 160445 Added
                xmlWriter.WriteAttributeString("iDosingunits", this.DosingUnits);
                xmlWriter.WriteAttributeString("iUsermessage", this.MessageCode);
                xmlWriter.WriteAttributeString("iMaxInfRate", this.MaxInfusionRateInmL.ToString());
                xmlWriter.WriteAttributeString("iMinmgPerml", this.MinConcentrationInDoseUnitsPerml.ToString());
                xmlWriter.WriteAttributeString("iInfusiontime", this.InfusionTime.ToString());
                xmlWriter.WriteAttributeString("iMgPerml", this.mlsPerPack.ToString());
                xmlWriter.WriteAttributeString("iIVcontainer", this.IVContainer);
                xmlWriter.WriteAttributeString("iDisplVol", this.DisplacementVolumeInml.ToString());
                xmlWriter.WriteAttributeString("iPILnumber", this.PILnumber.ToString());
                xmlWriter.WriteAttributeString("iDatelastperiodend", this.StartOfPeriod.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("iMindailydose", this.MinDailyDose.ToString());
                xmlWriter.WriteAttributeString("iMaxdailydose", this.MaxDailyDose.ToString());
                xmlWriter.WriteAttributeString("iMinDoseFreq", this.MinDoseFrequency.ToString());
                xmlWriter.WriteAttributeString("iMaxDoseFreq", this.MaxDoseFrequency.ToString());
                xmlWriter.WriteAttributeString("iLocalCode", this.LocalProductCode);
                xmlWriter.WriteAttributeString("iDSSform", this.DPSForm);
                xmlWriter.WriteAttributeString("iStoresdesc", (string.IsNullOrEmpty(this.LocalDescription) ? this.StoresDescription : this.LocalDescription).Replace('!', ' '));
                xmlWriter.WriteAttributeString("iGendesc", this.ToString());
                xmlWriter.WriteAttributeString("iStorespack", this.StoresPack);
                xmlWriter.WriteAttributeString("iLocation2", this.Location2);
                xmlWriter.WriteAttributeString("iPipCode", this.PIPCode);
                xmlWriter.WriteAttributeString("iMasterPip", this.MasterPIP);
                xmlWriter.WriteAttributeString("ilastissued", this.LastIssuedDate.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("ilastordered", this.LastOrderedDate.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("ibatchtracking", EnumDBCodeAttribute.EnumToDBCode(this.BatchTracking));
                xmlWriter.WriteAttributeString("ilaststocktakedate", this.LastStockTakeDateTime.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("ilaststocktaketime", this.LastStockTakeDateTime.ToPharmacyTimeString());
                xmlWriter.WriteAttributeString("iCreatedUser", this.CreatedByUserInitials);
                xmlWriter.WriteAttributeString("icreatedterminal", this.CreatedOnTerminal);
                xmlWriter.WriteAttributeString("icreateddate", this.CreatedDate.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("icreatedtime", this.CreatedDate.ToPharmacyTimeString());
                xmlWriter.WriteAttributeString("imodifieduser", this.ModifiedByUserInitials);
                xmlWriter.WriteAttributeString("imodifiedterminal", this.ModifiedOnTerminal);
                xmlWriter.WriteAttributeString("imodifieddate", this.ModifiedDate.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("imodifiedtime", this.ModifiedDate.ToPharmacyTimeString());
                xmlWriter.WriteAttributeString("iSuprefno", this.SupplierReferenceNumber);
                xmlWriter.WriteAttributeString("iSupTradeName", this.SupplierTradename);
                switch (this.BatchTracking)
                {
                case BatchTrackingType.OnReceipt :                      xmlWriter.WriteAttributeString("ibatchtrackingTxt", WConfiguration.LoadAndCache<string>(this.SiteID, "D|winord", string.Empty, "BatchTracking1", "Record Batch on Receipt",                               false)); break;
                case BatchTrackingType.OnReceiptWithExpiry :            xmlWriter.WriteAttributeString("ibatchtrackingTxt", WConfiguration.LoadAndCache<string>(this.SiteID, "D|winord", string.Empty, "BatchTracking2", "Record Batch and Expiry on Receipt",                    false)); break;
                case BatchTrackingType.OnReceiptWithExpiryAndConfirm :  xmlWriter.WriteAttributeString("ibatchtrackingTxt", WConfiguration.LoadAndCache<string>(this.SiteID, "D|winord", string.Empty, "BatchTracking3", "Record Batch and Expiry on Receipt & Confirm on Issue", false)); break;
                default :                                               xmlWriter.WriteAttributeString("ibatchtrackingTxt", WConfiguration.LoadAndCache<string>(this.SiteID, "D|winord", string.Empty, "BatchTracking4", "Batch Tracking Off",                                    false)); break;
                }
                //xmlWriter.WriteAttributeString("iBatchTrack", (this.BatchTracking > BatchTrackingType.None).ToYNString());    26Aug16 XN 161234 Updates in BatchTrackingType
                xmlWriter.WriteAttributeString("iBatchTrack", (this.BatchTracking > BatchTrackingType.One).ToYNString());
                if (this.ConversionFactorPackToIssueUnits > 0)
                {
                   xmlWriter.WriteAttributeString("iCostUnit", (this.AverageCostExVatPerPack / this.ConversionFactorPackToIssueUnits).ToString("0.####"));
                   xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iCost/100Unit"), ((this.AverageCostExVatPerPack / this.ConversionFactorPackToIssueUnits) / 100).ToString("0.00"));
                   xmlWriter.WriteAttributeString("iCostGross", (this.AverageCostExVatPerPack * this.VATRate).ToString("0.####"));
                   xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iCostGross/100"), ((this.AverageCostExVatPerPack * this.VATRate) / 100).ToString("0.00"));
                }
                else
                {
                   xmlWriter.WriteAttributeString("iCostUnit", "0");
                   xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iCost/100Unit"), "0");
                   xmlWriter.WriteAttributeString("iCostGross", "0");
                   xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iCostGross/100"), "0");
                }
                xmlWriter.WriteAttributeString("iDDDValue", this.RawRow["DDDValue"].ToString());
                xmlWriter.WriteAttributeString("iDDDUnits", this.RawRow["DDDUnits"].ToString());
                xmlWriter.WriteAttributeString("iUserField1", this.UserField1);
                xmlWriter.WriteAttributeString("iUserField2", this.UserField2);
                xmlWriter.WriteAttributeString("iUserField3", this.UserField3);
                xmlWriter.WriteAttributeString("iHIProduct", this.RawRow["HIProduct"].ToString());
                xmlWriter.WriteAttributeString("iEDILinkCode", this.EDILinkCode);
                xmlWriter.WriteAttributeString("iEDIBarcode", this.EDIBarcode);     // 22Jul16 XN 126634 
                xmlWriter.WriteAttributeString("iPASANPCCode", this.PASANPCCode);
                xmlWriter.WriteAttributeString("iPNExclude", this.PNExclude.ToYNString());
                xmlWriter.WriteAttributeString("iPSOLabel", this.PSOLabel.ToYNString());
                xmlWriter.WriteAttributeString("iEyeLabel", this.EyeLabel.ToYNString());
         
                xmlWriter.WriteAttributeString("iPhysicalDescription", this.PhysicalDescription);
                xmlWriter.WriteAttributeString("iLabelDescriptionInPatient", this.LabelDescriptionInPatient);
                xmlWriter.WriteAttributeString("iLabelDescriptionOutPatient", this.LabelDescriptionOutPatient);
                xmlWriter.WriteAttributeString("iLocalDescription", this.LocalDescription);
                xmlWriter.WriteAttributeString("iDrugDescription", this.ToString());

                xmlWriter.WriteAttributeString("drugdescription", this.LabelDescription + "  ");    // 26Apr16 XN  123082 Added
                xmlWriter.WriteAttributeString("iAltSupCode", string.Empty);    // 15Aug16 XN 108889 Added so clears on iAltSupCode

                xmlWriter.WriteEndElement();

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }
        #endregion

        #region Update Service Locking
        public bool LabelDescription_Locked
        {
            get { return FieldToBoolean(RawRow["LabelDescription_Locked"]) ?? true;       }
            set { RawRow["LabelDescription_Locked"] = BooleanToField(value, true, false); }
        }

        public bool StoresDescription_Locked
        {
            get { return FieldToBoolean(RawRow["StoresDescription_Locked"]) ?? true;       }
            set { RawRow["StoresDescription_Locked"] = BooleanToField(value, true, false); }
        }

        public bool WarningCode_Locked
        {
            get { return FieldToBoolean(RawRow["warcode_Locked"]) ?? true;       }
            set { RawRow["warcode_Locked"] = BooleanToField(value, true, false); }
        }

        public bool WarningCode2_Locked
        {
            get { return FieldToBoolean(RawRow["warcode2_Locked"]) ?? true;       }
            set { RawRow["warcode2_Locked"] = BooleanToField(value, true, false); }
        }

        public bool InstructionCode_Locked
        {
            get { return FieldToBoolean(RawRow["inscode_Locked"]) ?? true;       }
            set { RawRow["inscode_Locked"] = BooleanToField(value, true, false); }
        }

        public bool CanUseSpoon_Locked
        {
            get { return FieldToBoolean(RawRow["CanUseSpoon_Locked"]) ?? true;       }
            set { RawRow["CanUseSpoon_Locked"] = BooleanToField(value, true, false); }
        }
        #endregion

        /// <summary>
        /// Validates the ingredient for issue against this drug
        /// 1. Checks drug is in use
        /// 2. qtyInIssueUnits is within the min max issue value for the drug
        /// Replacement for VB method Formula1.bas DoChkIssue (will also need to call ValidateStockLevel)
        /// </summary>
        /// <param name="qtyInIssueUnits">Quantity to issue</param>
        /// <param name="qtyControlName">qtyInIssueUnits control's friendly name added to error message</param>
        /// <returns>any warning (all items are warnings)</returns>
        public ErrorWarningList ValidateIssue(double qtyInIssueUnits, string qtyControlName)
        {
            ErrorWarningList list = new ErrorWarningList();
            
            if (!this.InUse)
            {
                list.AddWarning("Drug no longer in use.");
            }

            if (qtyInIssueUnits > ((double?)this.MaxIssueInIssueUnits ?? 0))
            {
                list.AddWarning(string.Format("{0} above maximum of {1} {2}(s)", qtyControlName, this.MaxIssueInIssueUnits.ToString("0.####"), this.PrintformV).Trim());
            }

            if (qtyInIssueUnits < ((double?)this.MinIssueInIssueUnits ?? 0) && qtyInIssueUnits > 0)
            {
                list.AddWarning(string.Format("{0} below minimum of {1} {2}(s)", qtyControlName, this.MinIssueInIssueUnits.ToString("0.####"), this.PrintformV).Trim());
            }

            if (qtyInIssueUnits > 999999)
            {
                list.AddWarning((qtyControlName + " exceeds max allowed").Trim());
            }

            return list;
        }

        /// <summary>
        /// Validates stock level of the drug (only if live stock control && is ward stock item)
        /// Replacement for VB method Formula1.bas DoChkIssue (will also need to call ValidateIssue)
        /// </summary>
        /// <param name="qtyInIssueUnits">Quantity to issue</param>
        /// <param name="issueType">issue type</param>
        /// <param name="qtyControlName">qtyInIssueUnits control's friendly name added to error message</param>
        /// <param name="error">Error message created by validation</param>
        /// <returns>If quantity is valid for issue</returns>
        public bool ValidateStockLevel(double qtyInIssueUnits, WTranslogType issueType, string qtyControlName, out string error)
        {
            if ((this.IfLiveStockControl ?? true) && issueType != WTranslogType.WardStock && 
                ((double)this.StockLevelInIssueUnits - qtyInIssueUnits) < 0 && qtyInIssueUnits > 0)
            {
                error = (qtyControlName + " reduces stock levels below zero").Trim();
                return false;
            }

            error = string.Empty;
            return true;
        }
    }
    
    /// <summary>Provides column information about the WProduct view</summary>
    public class WProductColumnInfo : BaseColumnInfo
    {
        public WProductColumnInfo() : base("WProduct") { }

        public int NSVCodeLength                 { get { return tableInfo.GetFieldLength("siscode");            } } 
        public int SupplierCodeLength            { get { return tableInfo.GetFieldLength("supcode");            } } 
        public int StoresDescriptionLength       { get { return tableInfo.GetFieldLength("storesdescription");  } }
        public int LabelDescriptionLength        { get { return tableInfo.GetFieldLength("LabelDescription");   } }   
        public int PrintformVLength              { get { return tableInfo.GetFieldLength("PrintformV");         } }
        public int ReorderPackSizeLength         { get { return tableInfo.GetFieldLength("reorderqty");         } }
        public int OutstandingInIssueUnitsLength { get { return tableInfo.GetFieldLength("outstanding");        } }
        public int ReOrderQuantityInPacksLength  { get { return tableInfo.GetFieldLength("reorderqty");         } }
        public int MinIssueInIssueUnitsLength    { get { return tableInfo.GetFieldLength("minissue");           } }
        public int MaxIssueInIssueUnitsLength    { get { return tableInfo.GetFieldLength("maxissue");           } }
        public int mlsPerPackLength              { get { return tableInfo.GetFieldLength("mlsperpack");         } }
        public int NotesLength                   { get { return tableInfo.GetFieldLength("message");            } }
        public int BarcodeLength                 { get { return tableInfo.GetFieldLength("barcode");            } }
        public int CreatedOnTerminalLength       { get { return tableInfo.GetFieldLength("createdterminal");    } }
        public int CreatedByUserInitialsLength   { get { return tableInfo.GetFieldLength("CreatedUser");        } }
        public int ModifiedOnTerminalLength      { get { return tableInfo.GetFieldLength("modifiedterminal");   } }
        public int ModifiedByUserInitialsLength  { get { return tableInfo.GetFieldLength("modifieduser");       } }
        public int LeadTimeLength                { get { return tableInfo.GetFieldLength("leadtime");           } }
        public int ContractPriceLength           { get { return tableInfo.GetFieldLength("ContPrice");          } }
        public int ExtraLabelLength              { get { return tableInfo.GetFieldLength("extralabel");         } }
        public int LabelDescriptionInPatientLength { get { return tableInfo.GetFieldLength("LabelDescriptionInPatient");         } }  // XN 27Apr15 98073 Added 
        public int LabelDescriptionOutPatientLength{ get { return tableInfo.GetFieldLength("LabelDescriptionOutPatient");        } }  // XN 05May15 98073 Added 
        public int LocalDescriptionLength        { get { return tableInfo.GetFieldLength("LocalDescription");   } }                   // XN 19May15 98073 Added 
    }

    /// <summary>Represent the WProduct view</summary>
    public class WProduct : BaseTable2<WProductRow, WProductColumnInfo>
    {
        /// <summary>Constructor</summary>
        public WProduct() : base ("WProduct") { }

        #region Public methods
        /// <summary>Overrides base class to initalise variables (used by product editor so be carful when editing)</summary>
        public override WProductRow Add()
        {
            DateTime now = DateTime.Now;
            WProductRow newRow = base.Add();
            newRow.ProductID                = 0;
            newRow.ProductStockID           = 0;
            newRow.Code                     = string.Empty;
            newRow.LabelDescription         = string.Empty;
            newRow.InUse                    = true;
            newRow.Tradename                = string.Empty;
//            newRow.AverageCostExVatPerPack  = 0;
            newRow.ContractNumber           = null;         // Stores only sets it to null
            newRow.SupplierCode             = string.Empty;
            newRow.AlternateSupplierCode    = string.Empty;
            newRow.WarningCode              = string.Empty;
            newRow.WarningCode2             = string.Empty;
            newRow.LedgerCode               = string.Empty;
            newRow.NSVCode                  = string.Empty;
            newRow.Barcode                  = string.Empty;
            newRow.IsCytotoxic              = null;
            newRow.IsCIVAS                  = null;
            newRow.FormularyType            = FormularyType.Unknown;
            newRow.BNF                      = string.Empty;
            newRow.ReconstitutionVolumeInml = 0;
            newRow.ReconstitutionAbbreviation=string.Empty;   
            newRow.DiluentAbbreviation1     = string.Empty;
            newRow.DiluentAbbreviation2     = string.Empty;
            newRow.MaxConcentrationInDoseUnitsPerml = 0;
            newRow.InstructionCode          = string.Empty;
//            newRow.DirectionCode            = string.Empty;
            newRow.LabelFormat              = string.Empty;
            newRow.ExpiryTimeInMintues      = 0;
            newRow.IsStocked                = null;
            newRow.ReorderPackSize          = null;
            newRow.PrintformV               = string.Empty;
            newRow.MinIssueInIssueUnits     = null;
            newRow.MaxIssueInIssueUnits     = null;
            newRow.ReorderLevelInIssueUnits = null;
//            newRow.ReOrderQuantityInPacks   = 0;
//            newRow.ConversionFactorPackToIssueUnits = 0;
            newRow.AnnualUsageInIssueUnits  = null;
            newRow.Notes                    = string.Empty;
            newRow.TherapyCode              = string.Empty;
            newRow.ExtraLabel               = string.Empty;
//            newRow.StockLevelInIssueUnits   = 0;
            newRow.RawRow["stocklvl"]       = string.Empty;
            newRow.IfLiveStockControl       = null;
            newRow.LeadTimeInDays           = null;
            newRow.Location                 = string.Empty;
            newRow.Location2                = string.Empty;
            newRow.UsageDamping             = 0.75;
            newRow.SafetyFactor             = 1.2;
            newRow.ReCalculateAtPeriodEnd   = null;
            newRow.LossesGainExVat          = 0;
            newRow.DosesPerIssueUnit        = 0;
            newRow.mlsPerPack               = 0;
            newRow.OrderCycle               = string.Empty;
            newRow.CycleLengthInDays        = 0;
            newRow.LastReconcilePriceExVatPerPack = null;
            newRow.OutstandingInIssueUnits  = 0;
            newRow.UseThisPeriodInIssueUnits= 0;
            newRow.VATCode                  = null;
            newRow.DosingUnits              = string.Empty;
            newRow.MessageCode              = string.Empty;
            newRow.MinConcentrationInDoseUnitsPerml = 0;
            newRow.InfusionTime             = 0;
            newRow.FinalConcentrationInDoseUnitsPerml = 0;
            newRow.IVContainer              = string.Empty;
            newRow.DisplacementVolumeInml   = 0;
            newRow.PILnumber                = 0;
            newRow.StartOfPeriod            = null;
            newRow.MinDailyDose             = 0;
            newRow.MaxDailyDose             = 0;
            newRow.MinDoseFrequency         = 0;
            newRow.MaxDoseFrequency         = 0;
            newRow.LocalProductCode         = string.Empty;
            newRow.DPSForm                  = string.Empty;
            newRow.StoresDescription        = string.Empty;
            newRow.RawRow["StoresPack"]     = string.Empty;
            newRow.LastIssuedDate           = null;
            newRow.LastOrderedDate          = null;
            newRow.CreatedByUserInitials    = SessionInfo.UserInitials.SafeSubstring(0, WProduct.GetColumnInfo().CreatedByUserInitialsLength);
            newRow.CreatedOnTerminal        = SessionInfo.Terminal.SafeSubstring    (0, WProduct.GetColumnInfo().CreatedOnTerminalLength    );
            newRow.CreatedDate              = now;
            newRow.ModifiedByUserInitials   = SessionInfo.UserInitials.SafeSubstring(0, WProduct.GetColumnInfo().ModifiedByUserInitialsLength);
            newRow.ModifiedOnTerminal       = SessionInfo.Terminal.SafeSubstring(0, WProduct.GetColumnInfo().ModifiedOnTerminalLength        );
            newRow.ModifiedDate             = now;
            newRow.RawRow["batchtracking"]  = string.Empty;
            newRow.LastStockTakeDateTime    = null;
            newRow.IsReconcileIfZeroPrice   = true;
            newRow.IssueWholePack           = null;
            newRow.CMICode                  = string.Empty; 
            newRow.PIPCode                  = string.Empty; 
            newRow.MasterPIP                = string.Empty; 
            newRow.IsLabelInIssueUnits      = false;
            newRow.CanUseSpoon              = false;
            newRow.SiteProductDataID        = 0;
            newRow.DSSMasterSiteID          = 0;
            newRow.DrugID                   = 0;
            newRow.WSupplierProfileID       = 0;
            newRow.SupplierTradename        = string.Empty;
            newRow.SupplierReferenceNumber  = string.Empty;
            newRow.PhysicalDescription      = string.Empty;
            newRow.RawRow["DDDUnits"]       = string.Empty;
            newRow.RawRow["DDDValue"]       = string.Empty;
            newRow.UserField1               = string.Empty;
            newRow.UserField2               = string.Empty;
            newRow.UserField3               = string.Empty;
            newRow.RawRow["HIProduct"]      = string.Empty;
            newRow.EDILinkCode              = string.Empty;
            newRow.PASANPCCode              = string.Empty;
            newRow.PNExclude                = false;
            newRow.PSOLabel                 = false;
            newRow.EyeLabel                 = false;
            newRow.ExpiryWarnDays           = 0;
            newRow.MaxInfusionRateInmL      = 0;
            newRow.LabelDescription_Locked  = false;
            newRow.StoresDescription_Locked = false;
            newRow.WarningCode_Locked       = false;
            newRow.WarningCode2_Locked      = false;
            newRow.InstructionCode_Locked   = false;
            newRow.CanUseSpoon_Locked       = false;
            //newRow.RawRow["DSS"]            = false;  XN 30Jun14 94416 Removed field

            return newRow;
        }
             
        /// <summary>
        /// Loads the product information by NSVCode, and site ID
        /// 29May14 XN  88922 Added append
        /// </summary>
        public void LoadByProductAndSiteID(string NSVCode, int siteID, bool append = false)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("LocationID_Site",  siteID );
            parameters.Add("NSVcode",          NSVCode);
            LoadBySP(append, "pWProductSelectByNSV", parameters);
        }

        /// <summary>
        /// Loads the product infromation by NSVCodes and site ID
        /// It is not a good idea to use this method for normaly use as will be slow, so find another method
        /// 11Jun14 XN 88922
        /// 24Jun14 XN 43318 loads 200 drugs at a time
        /// </summary>
        public void LoadByProductAndSiteID(IEnumerable<string> NSVCodes, int siteID, bool append = false)
        {
            const int MaxItems = 200;
            int count = 0;

            // Load the data in batches for 200 else might be too slow
            while (count < NSVCodes.Count())
            {
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add("CurrentSessionID", SessionInfo.SessionID);
                parameters.Add("LocationID_Site",  siteID );
                parameters.Add("NSVcodes",         "'" + NSVCodes.Skip(count).Take(MaxItems).ToCSVString("','") + "'");
                LoadBySP(append || count > 0, "pWProductSelectByNSVCodesAndSite", parameters);

                count += MaxItems;
            }
        }

        /// <summary>
        /// Loads a single product row by Product ID, and site ID
        /// </summary>
        /// <param name="productID">Product ID</param>
        /// <param name="siteID">Site ID</param>
        public void LoadByProductIDAndSiteID(int productID, int siteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("LocationID_Site",  siteID   );
            parameters.Add("ProductID",        productID);
            LoadBySP("pWProductSelect", parameters);
        }

        /// <summary>
        /// Used for the robot loading interface.
        /// Loads the product record associated with an order connected to a loading for a specific drug primary barcode
        /// </summary>
        /// <param name="siteID">Site Id</param>
        /// <param name="loadingNumber">robot loading number</param>
        /// <param name="barcode">Drug primary barcode</param>
        public void LoadBySiteLoadingNumberAndPrimaryBarcode(int siteID, int loadingNumber, string barcode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("SiteID",         siteID);
            parameters.Add("LoadingNumber",  loadingNumber);
            parameters.Add("Barcode",        barcode);
            LoadBySP("pWProductBySiteLoadingNumberAndPrimaryBarcode", parameters);
        }

        /// <summary>
        /// Loads the product associated with the site ID and barcode
        /// </summary>
        /// <param name="siteID">Site Id</param>
        /// <param name="barcode">Product barcode</param>
        public void LoadBySiteIDAndBarcode(int siteID, string barcode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("SiteID",           siteID);
            parameters.Add("Barcode",          barcode);
            LoadBySP("pWProductBySiteIDAndPrimaryBarcode", parameters);
        }

        /// <summary>
        /// Loads the product associated with the site ID and description
        /// </summary>
        /// <param name="siteID">Site Id</param>
        /// <param name="barcode">Product description</param>
        public void LoadBySiteIDAndDescription(int siteID, string description)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("SiteID",           siteID);
            parameters.Add("Description",      description);
            LoadBySP("pWProductBysiteIDAndDescription", parameters);
        }

        /// <summary>
        /// Loads the product associated with the site ID and LookupCode (WProduct.Code)
        /// </summary>
        /// <param name="siteID">Site Id</param>
        /// <param name="Code">Code (WProduct.Code)</param>
        public void LoadBySiteIDAndCode(int siteID, string code)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("SiteID",           siteID);
            parameters.Add("Code",             code);
            LoadBySP("pWProductBysiteIDAndCode", parameters);
        }

        /// <summary>
        /// Loads the product associated with the site ID and localProductCode (WProduct.Local)
        /// </summary>
        /// <param name="siteID">Site Id</param>
        /// <param name="localProductCode">Local Product Code (WProduct.Local)</param>
        public void LoadBySiteIDAndLocalProductCode(int siteID, string localProductCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("SiteID",           siteID);
            parameters.Add("local",            localProductCode);
            LoadBySP("pWProductBysiteIDAndLocal", parameters);
        }

        /// <summary>
        /// Loads the product associated with the site ID and Tradename
        /// </summary>
        /// <param name="siteID">Site Id</param>
        /// <param name="tradename">Tradename</param>
        public void LoadBySiteIDAndTradename(int siteID, string tradename)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("SiteID",           siteID);
            parameters.Add("tradename",        tradename);
            LoadBySP("pWProductBysiteIDAndTradename", parameters);
        }

        /// <summary>
        /// Loads the product by site, alias group and alias.
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="aliasGroup">Description of the alias group</param>
        /// <param name="alias">The alias</param>
        public void LoadBySiteIDAndAliasGroupAndAlias(int siteID, string aliasGroup, string alias)
        {
            LoadBySiteIDAndAliasGroupAndAlias(siteID, aliasGroup, alias, false);
        }
        public void LoadBySiteIDAndAliasGroupAndAlias(int siteID, string aliasGroup, string alias, bool append)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("SiteID", siteID);
            parameters.Add("AliasGroup", aliasGroup);
            parameters.Add("Alias", alias);
            LoadBySP(append, "pWProductBySiteIDAndAliasGroupAndAlias", parameters);
        }

        /// <summary>Loads the product information by NSVCode</summary>
        /// <param name="NSVCode">Product NSV code</param>
        /// <param name="append">If data is to be appended 18May15 XN 117528</param>
        public void LoadByNSVCode(string NSVCode, bool append = false)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("NSVcode", NSVCode);
            this.LoadBySP(append, "pWProductByNSVCode", parameters);
        }

        /// <summary>Loads the product infromation by DrugID (only returns some fields)</summary>
        /// <param name="drugID">drug ID</param>
        /// <param name="siteID">Site ID (only used to get the MasterSiteID)</param>
        public void LoadAllSitesByDrugID(int drugID, int siteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("DrugID",           drugID);
            parameters.Add("SiteID",           siteID);
            LoadBySP("pWProducSelectAllSitesByDrugID", parameters);
        }

        /// <summary>Loads single the drug information by DrugID and site (12Feb14 XN 56071)</summary>
        /// <param name="drugID">drug ID</param>
        /// <param name="siteID">Site ID </param>
        public void LoadByDrugIDAndSiteID(int drugID, int siteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("DrugID",           drugID);
            parameters.Add("LocationID_Site",  siteID);
            LoadBySP("pWProductSelectByDrugID", parameters);
        }        

        /// <summary>Loads by bnf (and all sub BNFs) and DSS master site ID 17Oct14 XN  88560</summary>
        public void LoadBySiteIDAndBNF(int siteID, string BNF)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("SiteID",           siteID);
            parameters.Add("BNF",              BNF);
            LoadBySP("pWProductBysiteIDAndBNF", parameters);
        }

        /// <summary>
        /// Looks for drug that contains all the criteria
        /// NOTE: the underlying SP does not return all WProduct fields
        /// </summary>
        public void LoadByByCriteria(int siteID, string NSVCode, string barcode, string description, string code, string local, string tradname, string BNF)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SessionID",        SessionInfo.SessionID);
            parameters.Add("LocationID_Site",  siteID);
            parameters.Add("siscode",          NSVCode);
            parameters.Add("barcode",          barcode);
            parameters.Add("description",      description);
            parameters.Add("code",             code);
            parameters.Add("local",            local);
            parameters.Add("tradename",        tradname);
            parameters.Add("bnf",              BNF);
            LoadBySP("pWProductLookupByCriteria", parameters);
        }

        public void LoadBySiteAndWWardProductListID(int siteID, int wwardProductListID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("LocationID_Site",   siteID            );
            parameters.Add("WWardProductListID",wwardProductListID);
            LoadBySP("pWProductBySiteAndWWardProductListID", parameters);
        }

        /// <summary>
        /// Returns maxcount rows the relavent field use for the specified code
        ///     if WLookupContextType.Warning     then checks WProduct.warcode, WProduct.warcode2
        ///     if WLookupContextType.Instruction then checks WProduct.inscode
        ///     if WLookupContextType.UserMsg     then checks WProduct.UserMsg
        ///     if WLookupContextType.FFLabels    then checks WProduct.extralabel
        /// Will order the data by storesdescription.    
        /// 09May14 XN 88858 Creaeted
        /// </summary>
        /// <param name="siteID">site ID</param>
        /// <param name="contextType">Context type to check for</param>
        /// <param name="code">WLookup code</param>
        /// <param name="maxcount">Max number of rows to return</param>
        public void LoadBySiteAndLookupCode(int siteID, WLookupContextType contextType, string code, int maxcount)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("LocationID_Site",  siteID);
            parameters.Add("MaxCount",         maxcount);
            parameters.AddRange(CreateWLookupParameters(contextType, code));
            parameters.Add("OrderBy",          "storesdescription");
            LoadBySP("pWProductBySiteAndAnyField", parameters);
        }

        /// <summary>
        /// Loads drugs from product ID and replaced VMP or AMPs
        /// 12Jun15 XN  39882
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="productID">Product ID</param>
        /// <param name="productRouteID">Product Route ID</param>
        /// <param name="otherRoutes">If including other routes</param>
        public void LoadByProductIDVMPorAMP(int siteID, int productID, int productRouteID, bool otherRoutes)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SessionID",        SessionInfo.SessionID);
            parameters.Add("LocationID_Site",  siteID);
            parameters.Add("ProductID",        productID);
            parameters.Add("ProductRouteID",   productRouteID);
            this.LoadBySP(otherRoutes ? "pWProductLookupByProductID_VMPorAMP_OtherRoutes" : "pWProductLookupByProductID_VMPorAMP", parameters);
        }

        /// <summary>Loads drugs by supplier and Edi link code  15Jul16 XN  126634</summary>
        /// <param name="supCode">Supplier code</param>
        /// <param name="ediLinkCode">Edi link code</param>
        public void LoadBySupplierAndEdiCode(string supCode, string ediLinkCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SupCode",          supCode);
            parameters.Add("EDILinkCode",      ediLinkCode);
            this.LoadBySP("pWProductBySupplierAndEdiCode", parameters);
        }

        /// <summary>
        /// Returns count rows the relavent field use for the specified code
        ///     if WLookupContextType.Warning     then checks WProduct.warcode, WProduct.warcode2
        ///     if WLookupContextType.Instruction then checks WProduct.inscode
        ///     if WLookupContextType.UserMsg     then checks WProduct.UserMsg
        ///     if WLookupContextType.FFLabels    then checks WProduct.extralabel
        /// 09May14 XN 88858 Creaeted
        /// </summary>
        /// <param name="siteID">site ID</param>
        /// <param name="contextType">Context type to check for</param>
        /// <param name="code">WLookup code</param>
        public static int GetCountBySiteAndLookupCode(int siteID, WLookupContextType contextType, string code)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("LocationID_Site",  siteID);
            parameters.AddRange(CreateWLookupParameters(contextType, code));
            return Database.ExecuteScalar<int>("pWProductCountBySiteAndAnyField", parameters);
        }

        /// <summary>
        /// Override base class method, 
        /// as in DB it is as view so need to manually update classes SiteProductData, ProductStock, WSupplierProfile
        /// Does not support deletion
        /// This version will not update modified user, terminate and date fields
        /// Method throw LockException
        /// 06May15 XN 117528 
        /// </summary>
        public override void Save()
        {
            //this.Save(false); 15Aug16 XN 108889
            this.Save(updateModifiedDate: false, createInterfaceFile: false);
        }
        
        /// <summary>
        /// Override base class method, 
        /// as in DB it is as view so need to manually update classes SiteProductData, ProductStock, WSupplierProfile
        /// Does not support deletion
        /// Can based on setting update modified user, terminate and date fields
        /// Method throw LockException
        /// 06May15 XN 117528 
        /// </summary>
        /// <param name="updateModifiedDate">If modified fields (in ProductStock) should be updated 06May15 XN 117528</param>
        /// <param name="createInterfaceFile">Creates an interface file if the drug has changed in interfacing is enabled 15Aug16 XN 108889</param>
        public void Save(bool updateModifiedDate, bool createInterfaceFile = false)
        {
            SiteProductData  siteProductData = new SiteProductData();
            ProductStock     productStock    = new ProductStock();
            WSupplierProfile supplierProfile = new WSupplierProfile();

            SiteProductDataRow  siteProductDataRow;
            ProductStockRow     productStockRow;    
            WSupplierProfileRow supplierProfileRow;

            DateTime now = DateTime.Now;

            List<ProductStockRow> productStocksUpdateModDate = new List<ProductStockRow>();

            // Check there are no deletions
            if (this.DeletedItemsTable.Rows.Count > 0)
                throw new ApplicationException("WProduct does not support deletion.");

            // Get all modified records (get at start as state will change on save) 15Aug16 XN 108889
            var recordsToAdd    = createInterfaceFile ? this.Where(s => s.RawRow.RowState == DataRowState.Added   ).ToList() : new List<WProductRow>();
            var recordsToUpdate = createInterfaceFile ? this.Where(s => s.RawRow.RowState == DataRowState.Modified).ToList() : new List<WProductRow>();

            // Update conflict options
            siteProductData.ConflictOption = this.ConflictOption;
            productStock.ConflictOption    = this.ConflictOption;
            supplierProfile.ConflictOption = this.ConflictOption;

            productStock.RowLockingOption = LockingOption.HardLock;  // Need to lock    24Jun14 XN 43318 Changes to BaseTable2 locking

            try
            {
                foreach(var row in this)
                {
                    // Get rows that are added or modified
                    if (row.RawRow.RowState != DataRowState.Added && row.RawRow.RowState != DataRowState.Modified)
                        continue;

                    // if adding (check ProductStockID to make sure) the row and already existing in the db then skip saving 1Jul14 XN (prevents adding duplicate rows in the add wizard)
                    if (row.RawRow.RowState == DataRowState.Added && row.ProductStockID <= 0 && WProduct.GetByProductAndSiteID(row.NSVCode, row.SiteID) != null)
                        continue;

                    IEnumerable<string> changedColumns = row.GetChangedColumns().Select(c => c.ColumnName).ToList();

                    // Update SiteProductData

                    // Either get existing SiteProductData row (first try to load) or add new one
                    // Then copies the WProduct data to it
                    // Search via NSVCode and DSSMasterSiteID instead of SiteProductDataID as product editor add wizard uses 2 copies of the class so can try to insert twice (as both SiteProductDataID will be 0).
                    if (row.DrugID != null && !siteProductData.Any(s => s.NSVCode == row.NSVCode && s.DSSMasterSiteID == row.DSSMasterSiteID))
                    {
                        siteProductData.LoadByDrugIDAndSiteID(row.DrugID, row.SiteID, true);

                        // Try to get the row (if exist) so can update original values (for Optimistic locking used by product editor)
                        // this needs to be done at point of loading
                        siteProductDataRow = siteProductData.FirstOrDefault(s => s.NSVCode == row.NSVCode && s.DSSMasterSiteID == row.DSSMasterSiteID);
                        if (siteProductDataRow != null && row.RawRow.RowState != DataRowState.Added)
                        {
                            siteProductDataRow.CopyFrom(row, changedColumns, DataRowVersion.Original);
                            siteProductDataRow.RawRow.AcceptChanges();
                        }
                    }
                    if (!siteProductData.Any(s => s.NSVCode == row.NSVCode && s.DSSMasterSiteID == row.DSSMasterSiteID))
                        siteProductDataRow = siteProductData.Add();
                    else
                        siteProductDataRow = siteProductData.First(s => s.NSVCode == row.NSVCode && s.DSSMasterSiteID == row.DSSMasterSiteID);
                    siteProductDataRow.CopyFrom(row, changedColumns);

                    // If changes have been made then the all sites need their mod fields updated 06May15 XN 117528
                    if (updateModifiedDate && siteProductDataRow.HasDataChanged())
                    {
                        foreach (var s in Site2.Instance().ValidOnly())
                        {
                            if (productStock.FindBySiteIDAndNSVCode(s.SiteID, row.NSVCode) == null)
                                productStock.LoadBySiteIDAndNSVCode(row.NSVCode, s.SiteID, true);
                        }
                        
                        productStocksUpdateModDate.AddRange(productStock.Where(r => r.NSVCode == row.NSVCode));
                    }

                    // Update ProductStock

                    // Either gets existing ProductStock row gets new one
                    // Then copies the WProduct data to it
                    if (row.ProductStockID <= 0)
                        productStockRow = productStock.Add();
                    else
                    {
                        //  productStock.EnabledRowLocking = true;  // Need to lock  19Jun14 88987
                        productStockRow = productStock.FindByID(row.ProductStockID);    // Might of loaded above 06May15 XN 117528
                        if (productStockRow == null)
                        {
                            productStock.LoadByProductStockID(row.ProductStockID, true);
                            productStockRow = productStock.FindByID(row.ProductStockID);
                        }

                        // Remove columns that are duplicate of other tables and are not used 
                        // (so don't get false info about other users updating data when they have not)
                        var productStockColumnsChanged = changedColumns.ToList();
                        productStockColumnsChanged.RemoveAll(s => s.EqualsNoCase("BNF"));
                        productStockColumnsChanged.RemoveAll(s => s.EqualsNoCase("contno"));

                        // Update original values (needed for opermistic locking used by ProductEditor)
                        productStockRow.CopyFrom(row, productStockColumnsChanged, DataRowVersion.Original);
                        productStockRow.RawRow.AcceptChanges();
                    }
                    productStockRow.CopyFrom(row, changedColumns);
                    if (productStockRow.RawRow.RowState != DataRowState.Unchanged)
                    {
                        productStockRow.BNF            = null; // Not used so force to correct value
                        productStockRow.ContractNumber = null;

                        // Add to list of modified fields to update 06May15 XN 117528
                        productStocksUpdateModDate.Add(productStockRow);
                    }



                    // Update WSupplierProfile

                    // Either gets existing WSupplierProfile row or gets new one
                    // Then copies the WProduct data to it
                    if (row.WSupplierProfileID <= 0)
                        supplierProfileRow = supplierProfile.Add();
                    else
                    {
                        supplierProfile.LoadByWSupplierProfileID(row.WSupplierProfileID, true);
                        supplierProfileRow = supplierProfile.FindByID(row.WSupplierProfileID);

                        // Remove columns that are duplicate of other tables and are not used 
                        // (so don't get false info about other users updating data when they have not)
                        var supplierProfileColumnsChanged = changedColumns.ToList();
                        supplierProfileColumnsChanged.RemoveAll(s => s.EqualsNoCase("ReorderLvl"));
                        supplierProfileColumnsChanged.RemoveAll(s => s.EqualsNoCase("reorderqty"));
                        supplierProfileColumnsChanged.RemoveAll(s => s.EqualsNoCase("Tradename" ));

                        // Update original values (needed for opermistic locking used by ProductEditor)
                        supplierProfileRow.CopyFrom(row, supplierProfileColumnsChanged, DataRowVersion.Original);
                        supplierProfileRow.RawRow.AcceptChanges();
                    }
                    supplierProfileRow.CopyFrom(row, changedColumns);
                    if (supplierProfileRow.RawRow.RowState != DataRowState.Unchanged)
                    {
                        supplierProfileRow.NSVCode                  = row.NSVCode;   // Patch up NSVCode as its siscode in WProduct and NSVCode in WSupplierProfile so missed by CopyFrom
                        supplierProfileRow.ReorderLevelInIssueUnits = null; // Not used to so force to correct value
                        supplierProfileRow.ReOrderQuantityInPacks   = null;
                        //supplierProfileRow.Tradename                = null;   100212 15Oct14 XN Removed WSupplierProfile.Tradename from DB
                        
                        // Add to list of modified fields to update 06May15 XN 117528
                        productStocksUpdateModDate.Add(productStock.FindBySiteIDAndDrugID(row.SiteID, row.DrugID));
                    }
                }

                // Update the modified date (do at end so does not break the overoptimistic lock accept changes above (which is below the 
                if (updateModifiedDate)
                {
                    productStocksUpdateModDate.ForEach(r => r.UpdateModifiedDetails(now));
                }

                // Saves results
                using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.InheritTransaction))
                {
                    siteProductData.Save();
                    productStock.Save();
                    supplierProfile.Save();

                    trans.Commit();
                }

                // Update PKs
                foreach(var row in this)
                {
                    if (row.SiteProductDataID <= 0)
                        row.SiteProductDataID = siteProductData.First(s => s.DSSMasterSiteID == row.DSSMasterSiteID && s.NSVCode == row.NSVCode).SiteProductDataID;
                    if (row.ProductStockID <= 0)
                        row.ProductStockID = productStock.First(s => s.DrugID == row.DrugID && s.SiteID == row.SiteID).ProductStockID;
                    if (row.WSupplierProfileID <= 0)
                        row.WSupplierProfileID = supplierProfile.First(s => s.NSVCode == row.NSVCode && s.SupplierCode == row.SupplierCode && s.SiteID == row.SiteID).WSupplierProfileID;
                }

                // Write rows (only add or updated) to the interface file 15Aug16 XN 108889
                PharmacyInterface interfaceFile = new PharmacyInterface();
                foreach (var row in recordsToAdd.Concat(recordsToUpdate))
                {
                    IPharmacyInterfaceSettings settings = new StockInterfaceSettings(row.SiteID);
                    if (settings.Enabled)
                    {
                        interfaceFile.Initialise(settings);
                        interfaceFile.ParseXml(row.ToXMLHeap());
                        interfaceFile.Parse("iUpdateflag", recordsToAdd.Contains(row) ? "Create" : "Update");
                        interfaceFile.Save();
                    }
                }
            }
            finally
            {
                // Release locks
                siteProductData.Dispose();
                productStock.Dispose();
                supplierProfile.Dispose();
            }
        }

        /// <summary>Override base class as not supported for WProduct</summary>
        public override void SaveUsingBulkInsert()
        {
            throw new NotSupportedException();
        }
        #endregion

        #region Public Static Methods
        /// <summary>
        /// Validates the proudct notes field
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="NSVCode">NSV code</param>
        /// <param name="notes">notes to validate</param>
        /// <returns>List of validation errors</returns>
        public static List<ValidationError> ValidateNotes(int siteID, string NSVCode, string notes)
        {
            string propertyName = "Notes";
            string keyName = "SiteID:NSVCode";
            string keyValue = CreateValidationKey(siteID, NSVCode);
            string error;
            ValidationErrorList validationErrors = new ValidationErrorList();

            // Validate the notes length
            if (notes.Length > GetColumnInfo().NotesLength)
            {
                error = string.Format("{0} is too long (max allowed length {1}).", ValidationError.PropertyNameTag, GetColumnInfo().NotesLength);
                validationErrors.Add(new WProduct(), propertyName, keyName, keyValue, error, true);
            }

            // Get all validation related to this validation method
            return validationErrors;
        }

        /// <summary>
        /// Updates the product notes field.
        /// Data is saved to the db ProductStock.Message field
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="NSVCode">NSV code</param>
        /// <param name="notes">note value to save</param>
        [Obsolete("Use ProductStock")]
        public static void UpdateNotes(int siteID, string NSVCode, string notes)
        {
            using (ProductStock productStock = new ProductStock())
            {
                //  productStock.EnabledRowLocking = true;  // Need to lock  19Jun14 88987
                productStock.RowLockingOption = LockingOption.HardLock; // Changes to BaseTable2 locking  24Jun14 XN 43318

                // Load the product stock info that contains the notes
                productStock.LoadBySiteIDAndNSVCode(NSVCode, siteID);
                if (productStock.Count == 0)
                    throw new ApplicationException(string.Format("Failed to update product note as db does not exist (NSVCode:{0} site ID:{1})", NSVCode, siteID));

                // set the notes field
                productStock[0].Notes = notes;

                // save
                productStock.Save();
            }
        }

        // 29Jan14 XN 82431 Moved to SiteProductData (as statics AddAlias RemoveAlias)
        //public static void AddSiteProductDataAlias(int siteProductDataID, string aliasGroup, string alias, bool isDefault)
        //{
        //    // Get alias group ID
        //    int? aliasGroupID = Database.ExecuteSQLScalar<int?>("SELECT AliasGroupID FROM AliasGroup WHERE Description='{0}'", aliasGroup);
        //    if (aliasGroupID == null)
        //        throw new ApplicationException("Invalid alias group '" + aliasGroup + "'");

        //    GenericTable2 siteProductDataAlias = new GenericTable2("SiteProductDataAlias");
        //    List<SqlParameter> parameters = new List<SqlParameter>();
        //    BaseRow newRow = siteProductDataAlias.Add();
        //    newRow.RawRow["SiteProductDataID"] = siteProductDataID;
        //    newRow.RawRow["AliasGroupID"     ] = aliasGroupID;
        //    newRow.RawRow["Alias"            ] = alias;
        //    newRow.RawRow["Default"          ] = isDefault;
        //    siteProductDataAlias.Save();
        //}
        //
        //public static void RemoveSiteProductDataAlias(int siteProductDataID, string aliasGroup)
        //{
        //    // Get alias group ID
        //    int? aliasGroupID = Database.ExecuteSQLScalar<int?>("SELECT AliasGroupID FROM AliasGroup WHERE Description='{0}'", aliasGroup);
        //    if (aliasGroupID == null)
        //        throw new ApplicationException("Invalid alias group '" + aliasGroup + "'");
        //
        //    // Delete existing items
        //    GenericTable2 siteProductDataAlias = new GenericTable2("SiteProductDataAlias");
        //    List<SqlParameter> parameters = new List<SqlParameter>();
        //    parameters.Add(new SqlParameter("@SiteProductDataID", siteProductDataID ));
        //    parameters.Add(new SqlParameter("@AliasGroupID",      aliasGroupID      ));
        //    siteProductDataAlias.LoadBySQL("SELECT * FROM SiteProductDataAlias WHERE SiteProductDataID=@SiteProductDataID AND AliasGroupID=@AliasGroupID", parameters);
        //    siteProductDataAlias.RemoveAll();
        //    siteProductDataAlias.Save();
        //}
        //
        ///// <summary>Removes the site product data alias by alias group and value</summary>
        ///// <param name="aliasGroup">alias group</param>
        ///// <param name="value">alias value</param>
        //public static void RemoveSiteProductDataAlias(string aliasGroup, string alias)
        //{
        //    // Get alias group ID
        //    int? aliasGroupID = Database.ExecuteSQLScalar<int?>("SELECT AliasGroupID FROM AliasGroup WHERE Description='{0}'", aliasGroup);
        //    if (aliasGroupID == null)
        //        throw new ApplicationException("Invalid alias group '" + aliasGroup + "'");
        //
        //    // Delete existing items
        //    GenericTable2 siteProductDataAlias = new GenericTable2("SiteProductDataAlias");
        //    List<SqlParameter> parameters = new List<SqlParameter>();
        //    parameters.Add(new SqlParameter("@Alias",        alias       ));
        //    parameters.Add(new SqlParameter("@AliasGroupID", aliasGroupID));
        //    siteProductDataAlias.LoadBySQL("SELECT * FROM SiteProductDataAlias WHERE Alias=@Alias AND AliasGroupID=@AliasGroupID", parameters);
        //    siteProductDataAlias.RemoveAll();
        //    siteProductDataAlias.Save();
        //}

        /// <summary>
        /// Gets the product name (same as WProduct.ToString)
        /// There is a version of this method without site ID it is better to use the one requiring siteID
        /// 21Jul16 126634 if drug does not exist got it to return empty string
        /// </summary>
        /// <param name="NSVCode">Product nsv code</param>
        /// <param name="siteID">site id</param>
        /// <returns>product name</returns>
        public static string ProductDetails(string NSVCode, int siteID)
        {
            using (WProduct dbProducts = new WProduct())
            {
                dbProducts.LoadByProductAndSiteID(NSVCode, siteID);
                //if (dbProducts.Count == 0)
                   // throw new ApplicationException(string.Format("Product not found (NSVCode={0}, SiteID=(1))", NSVCode, siteID));    21Jul16 126634 removed and got it to return empty string
                return dbProducts.Any() ? dbProducts[0].ToString() : string.Empty;
            }
        } 
        public static string ProductDetails(string NSVCode)
        {
            string descritpion = descritpion = Database.ExecuteSQLScalar<string>("SELECT TOP 1 ISNULL(StoresDescription,labeldescription) FROM SiteProductData WHERE siscode = '{0}' AND DSSMasterSiteID<>0", NSVCode); 
            if (descritpion == null)
                descritpion = string.Empty;

            return descritpion.Replace('!', ' ');
        }

        /// <summary>Returns product information by NSVCode, and site ID (returns null if no matches)</summary>
        public static WProductRow GetByProductAndSiteID(string NSVCode, int siteID)
        {
            WProduct product = new WProduct();
            product.LoadByProductAndSiteID(NSVCode, siteID);
            return product.FirstOrDefault();
        }

        /// <summary>Returns a drug with specified drug ID and site (12Feb14 XN 56071)</summary>
        public static WProductRow GetByDrugIDAndSiteID(int drugID, int siteID)
        {
            WProduct product = new WProduct();
            product.LoadByDrugIDAndSiteID(drugID, siteID);
            return product.FirstOrDefault();
        }
        #endregion

        #region Private Methods
        /// <summary>
        /// Creates a validation key to uniquly identify a product
        /// </summary>
        /// <param name="siteID">site ID</param>
        /// <param name="NSVCode">NSV code</param>
        /// <returns>unique validation key</returns>
        private static string CreateValidationKey(int siteID, string NSVCode)
        {
            return siteID.ToString() + ":" + NSVCode;
        } 
        
        /// <summary>Returns SP parameters to use with sps pWProductBySiteAndAnyField, and pWProductCountBySiteAndAnyField for selected WLookup 09May14 XN 88858 Creaeted</summary>
        private static IEnumerable<SqlParameter> CreateWLookupParameters(WLookupContextType contextType, string code)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            switch (contextType)
            {
            case WLookupContextType.Warning:
                parameters.Add("FieldName1", "warcode");
                parameters.Add("Value1", code);
                parameters.Add("FieldName2", "warcode2");
                parameters.Add("Value2", code);
                break;
            case WLookupContextType.Instruction:
                parameters.Add("FieldName1", "inscode");
                parameters.Add("Value1", code);
                parameters.Add("FieldName2", string.Empty);
                parameters.Add("Value2", string.Empty);
                break;
            case WLookupContextType.UserMsg:
                parameters.Add("FieldName1", "UserMsg");
                parameters.Add("Value1", code);
                parameters.Add("FieldName2", string.Empty);
                parameters.Add("Value2", string.Empty);
                break;
            case WLookupContextType.FFLabels:
                parameters.Add("FieldName1", "extralabel");
                parameters.Add("Value1", code);
                parameters.Add("FieldName2", string.Empty);
                parameters.Add("Value2", string.Empty);
                break;
            default:
                throw new ApplicationException("WLookupContext type " + contextType.ToString() + " not used by WProduct");
            }
            return parameters;
        }
        #endregion
    }

    /// <summary>Provides extension methods to IEnumerable{WProductRow} class</summary>
    public static class WProductRowEnumerableExtensions
    {
        /// <summary>Returns all product with the specified site ID</summary>
        public static IEnumerable<WProductRow> FindBySiteID(this IEnumerable<WProductRow> products, int siteID)
        {
            return products.Where(p => p.SiteID == siteID);
        }

        /// <summary>Returns the product by site and NSVCode 24Jun14 XN 43318</summary>
        public static WProductRow FindBySiteIDAndNSVCode(this IEnumerable<WProductRow> products, int siteID, string NSVCode)
        {
            //return products.FirstOrDefault(p => p.SiteID == siteID && p.NSVCode == NSVCode); 167058 XN 2Nov16 make search case insensitive
            return products.FirstOrDefault(p => p.SiteID == siteID && p.NSVCode.EqualsNoCaseTrimEnd(NSVCode));
        }
    }
}
