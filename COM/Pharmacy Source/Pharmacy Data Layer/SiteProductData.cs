//===========================================================================
//
//							    SiteProductData.cs
//
//  Provides access to SiteProductData table.
//
//  Only supports reading, inserting and updating.
//
//  Also has methods for updating the SiteProductDataAlias table (as statics on SiteProductData)
//
//  You can't rely on the DrugID <10000000 to determie if the drug is DSS maintained need to 
//  always check against SiteProductData master row (so call IsDSSMaintained)
//
//	Modification History:
//	02Aug13 XN  24653 Written
//  01Nov13 XN  56701 Added lots of fields for product editor
//  18Dec13	XN	78339 Updates for Product Editor
//  29Jan14 XN  82431 Tidyup of Alias handling between SiteProductData and WProduct
//                    Add GetAlias, GetAliases, AddAlias, RemoveAllAliasByAliasGroup, RemoveAlias
//  03Feb14 XN  56071 Added append option to LoadBySiteIDAndNSVCode
//                    Added SiteProductDataEnumerableExtensions.FindByNSVCode
//  12Feb14 XN  56071 Added LoadByDrugIDAndSiteID and GetByDrugIDAndSiteID
//                    Replaced all List<SqlParameter>.Add with new add method
//  25Feb14 XN  56071 Added IsDSSMaintainedDrug and DSS
//  12Mar14 XN        Added field for DMandDReference
//  30Jun14 XN  94416 Updated IsDSSMaintainedDrug
//                    Added methods GetTrueMasterDrugID, GetTrueLocalDrugID, 
//                    LoadByDrugIDAndMasterSiteID and GetByDrugIDAndMasterSiteID
//                    Removed property DSS
//                    All of this is to make use of table DSSMasterSiteLinkSiteDrug
//                    to patch up mapping of drugs to the correct master Drug
//  04Jul14 XN  94416 Removed GetTrueMasterDrugID, GetTrueLocalDrugID and all 
//                    references to DSSMasterSiteLinkSiteDrug table
//  17Oct14 XN  88560 Add LoadByBNFAndMasterSiteID
//  24Sep15 XN  77778 Moved alias methods from SiteProductData to BaseTable2 
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using System.Data.SqlClient;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    public class SiteProductDataRow : BaseRow
    {
        public int SiteProductDataID
        {
            get { return FieldToInt(RawRow["SiteProductDataID"]).Value;   }
        }
        
        public string Code
        {
            get { return FieldToStr(RawRow["Code"], true);   }
            set { RawRow["Code"] = StrToField(value, false); } 
        }

        public string NSVCode
        {
            get { return FieldToStr(RawRow["siscode"], true);   }
            set { RawRow["siscode"] = StrToField(value, false); } 
        }

        public int DrugID
        {
            get { return FieldToInt(RawRow["DrugID"]) ?? 0; }
        }

        public string Barcode
        { 
            get { return FieldToStr(RawRow["Barcode"], true);   }
            set { RawRow["Barcode"] = StrToField(value, false); } 
        }

        public string LookupCode
        { 
            get { return FieldToStr(RawRow["Code"], true);   }
            set { RawRow["Code"] = StrToField(value, false); } 
        }

        /// <summary>DB int field convfact</summary>
        public int  ConversionFactorPackToIssueUnits 
        { 
            get { return FieldToInt(RawRow["convfact"]).Value;   } 
            set { RawRow["convfact"] = IntToField(value, false); } 
        }

        public int DSSMasterSiteID
        {
            get { return FieldToInt(RawRow["DSSMasterSiteID"]).Value;   } 
        }

        /// <summary>BNF code for the drug</summary>
        public string BNF 
        { 
            get { return StringExtensions.FormatBNF(FieldToStr(RawRow["BNF"], false, string.Empty)); } 
            set { RawRow["BNF"] = StrToField(value); } 
        }

        /// <summary>DM&D reference</summary>
        public long? DMandDReference
        {
            get { return FieldToLong(RawRow["DMandDReference"]); } 
            set { RawRow["DMandDReference"] = LongToField(value); } 
        }

        /// <summary>
        /// This is the issue units (will always be in lower case)
        /// If db field is null defaults to empty string.
        /// Can be an empty string if drug is of a non standard type.
        /// </summary>
        public string PrintformV 
        { 
            get { return FieldToStr(RawRow["printformv"], true, string.Empty).ToLower(); } 
            set { RawRow["printformv"] = FieldToStr(value);                              } 
        }

        public string   LabelDescription     
        { 
            get { return FieldToStr(RawRow["LabelDescription"], true, string.Empty);   } 
            set { RawRow["LabelDescription"] = FieldToStr(value);                      } 
        }

        public string   Tradename            
        { 
            get { return FieldToStr(RawRow["Tradename"], true, string.Empty);   } 
            set { RawRow["Tradename"] = FieldToStr(value);                      } 
        }

        public string   StoresDescription    
        { 
            get { return FieldToStr(RawRow["storesdescription"], true, string.Empty);  } 
            set { RawRow["storesdescription"] = FieldToStr(value);                     } 
        }
        
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

        public bool? IsCytotoxic 
        { 
            get { return FieldToBoolean(RawRow["Cyto"]);   } 
            //set { RawRow["Canusespoon"] = BooleanToField(value, "Y", "N"); } 18Dec13	XN	78339
            set { RawRow["Cyto"] = BooleanToField(value, "Y", "N", string.Empty); } 
        }

        public bool? IsCIVAS
        { 
            get { return FieldToBoolean(RawRow["CIVAS"]);  } 
            set { RawRow["CIVAS"] = BooleanToField(value); } 
        }

        /// <summary>unit of the active ingredient</summary>
        public string DosingUnits 
        { 
            get { return FieldToStr(RawRow["DosingUnits"], false, string.Empty); } 
            set { RawRow["DosingUnits"] = StrToField(value);                     } 
        }  

        public double? DosesPerIssueUnit
        { 
            get { return FieldToDouble(RawRow["DosesperIssueUnit"]);    } 
            set { RawRow["DosesperIssueUnit"] = DoubleToField(value);   } 
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

        public string DPSForm
        {
            get { return FieldToStr(RawRow["DPSForm"], false, string.Empty); } 
            set { RawRow["DPSForm"] = StrToField(value);                     } 
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

        public bool? CanUseSpoon             
        { 
            get { return FieldToBoolean(RawRow["Canusespoon"]);  } 
            // set { RawRow["Canusespoon"] = BooleanToField(value); }  18Dec13 XN 78339
            set { RawRow["Canusespoon"] = BooleanToField(value, "Y", "N"); } 
        }
        
        /// <summary>DB real field</summary>
        public decimal mlsPerPack  
        { 
            get { return FieldToDecimal(RawRow["mlsperpack"]) ?? 0m; } 
            set { RawRow["mlsperpack"] = DecimalToField(value);      } 
        }  
        
        /// <summary>
        /// Relates the WProduct to an ICW product
        /// If 0 then it is stores only item (see IsStoresOnly)
        /// 18Dec13	XN	78339
        /// </summary>
		public int? ProductID { get { return FieldToInt(RawRow["ProductId"]); } }

        /// <summary>If the product is only present in stored not given to patients (like a bottle) 18Dec13	XN	78339</summary>
        public bool IsStoresOnly { get { return !ProductID.HasValue || (ProductID.Value <= 0); } }
        
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
            //return (this.DrugID < 10000000 && this.ProductID != 0) || this.DSS; XN 30Jun14 94416 Only true way of determing if drug is dss maintained is to check if there is a dss master drug
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
        //    int? masterDrugID = Database.ExecuteScalar<int?>("pDSSMasterSiteLinkSiteDrugGetMasterDrugID", parameters); 
        //    if (masterDrugID == null)
        //        return this.DrugID;
        //    else if (masterDrugID < 0)
        //        return null;
        //    else
        //        return masterDrugID;
        //}

        ///// <summary>
        ///// Gets the true local DrugID (normaly same as this.DrugID assume this is a dss master drug row)
        ///// But might be different if there is entry for it in DSSMasterSiteLinkSiteDrug
        ///// XN 30Jun14 94416
        ///// </summary>
        //public int GetTrueLocalDrugID()
        //{
        //    List<SqlParameter> parameters = new List<SqlParameter>();
        //    parameters.Add("DrugID", this.DrugID);
        //    int? localSiteID = Database.ExecuteScalar<int?>("pDSSMasterSiteLinkSiteDrugGetSiteDrugID", parameters); 
        //    return localSiteID ?? this.DrugID;
        //}

        // XN 28Jun14 94416 Removed as now use DSSMasterSiteLinkSite table
        ///// <summary>
        ///// If drug is DSS maintained (ony significant for drugs with DrugID > 10000000)
        ///// Don't call property to see if durg is DSS maintained instead use IsDSSMaintainedDrug
        ///// </summary>
        //private bool DSS
        //{
        //    get { return FieldToBoolean(RawRow["DSS"]).Value; } 
        //    set { RawRow["DSS"] = BooleanToField(value);      } 
        //}

        #region Helper Methods
        /// <summary>Returns product description (either StoresDescription or LabelDescritpion)</summary>
        public override string ToString()
        {
            if (!string.IsNullOrEmpty(StoresDescription))
                return StoresDescription.Replace('!', ' ');
            else if (!string.IsNullOrEmpty(LabelDescription))
                return LabelDescription.Replace('!', ' ');
            else
                return string.Empty;
        }

        /// <summary>Loads and returns all alternative barcodes for this product 29Jan14 XN 82431 24Jul13 XN 24653</summary>
        /// <returns>alternative barcodes</returns>
        public IEnumerable<string> GetAlternativeBarcode()
        {
            return (new SiteProductData()).GetAliases<string>(this.SiteProductDataID, "AlternativeBarcode");
            //return SiteProductData.GetAliases<string>(this.SiteProductDataID, "AlternativeBarcode"); 24Sep15 XN  Moved alias methods from SiteProductData to BaseTable2 77778
        }

        // 29Jan14 XN  8243 Moved to SiteProductData.AddAlias
        ///// <summary>
        ///// Save alternate barcode
        ///// Unlike most aliases you can have multiple barcodes 
        ///// (so this method will just add a new one and not update old ones)
        ///// </summary>
        //public void SetAlternativeBarcode(string barcode)
        //{
        //    GenericTable siteProductDataAlias = new GenericTable("SiteProductDataAlias", "SiteProductDataAliasID");
        //    BaseRow row = siteProductDataAlias.Add();
        //    row.RawRow["SiteProductDataID"] = this.SiteProductDataID;
        //    row.RawRow["AliasGroupID"]      = Database.ExecuteSQLScalar<int>("SELECT AliasGroupID FROM AliasGroup WHERE Description='AlternativeBarcode'");
        //    row.RawRow["Alias"]             = barcode;
        //    row.RawRow["Default"]           = 1;
        //    siteProductDataAlias.Save();
        //}
        #endregion
    }

    /// <summary>Column information for the SiteProductData table</summary>
    public class SiteProductDataColumnInfo : BaseColumnInfo
    {
        public SiteProductDataColumnInfo() : base("SiteProductData") { }

        public int BarcodeLength  { get { return tableInfo.GetFieldLength("Barcode"); } }
    }

    /// <summary>Row in the SiteProductData table</summary>
    public class SiteProductData : BaseTable2<SiteProductDataRow,SiteProductDataColumnInfo>
    {
        public SiteProductData() : base("SiteProductData") { }

        /// <summary>Loads SiteProductDataRow by site ID, and NSVCode</summary>
        public void LoadBySiteIDAndNSVCode(int siteID, string NSVCode, bool append = false)
        // public void LoadBySiteIDAndNSVCode(int siteID, string NSVCode) 03Feb14 XN  56071
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("@SiteID",           siteID               );
            parameters.Add("@NSVCode",          NSVCode              );
            this.LoadBySP(append, "pSiteProductDataBySiteIDAndNSVCode", parameters);
            //this.LoadBySP("pSiteProductDataBySiteIDAndNSVCode", parameters); 03Feb14 XN  56071
        }

        /// <summary>Returns SiteProductDataRow by site ID, and NSVCode or null if there is none</summary>
        public static SiteProductDataRow GetBySiteIDAndNSVCode(int siteID, string NSVCode)
        {
            SiteProductData siteProductData = new SiteProductData();
            siteProductData.LoadBySiteIDAndNSVCode(siteID, NSVCode);
            return siteProductData.FirstOrDefault();
        }

        /// <summary>Returns SiteProductDataRow by NSVCode, and Master Site ID</summary>
        public static SiteProductDataRow GetByNSVCodeAndMasterSiteID(string NSVCode, int DSSMasterSiteID)
        {
            SiteProductData siteProductData = new SiteProductData();
            siteProductData.LoadByNSVCodeAndMasterSiteID(NSVCode, DSSMasterSiteID);
            return siteProductData.FirstOrDefault();
        }

        /// <summary>Loads SiteProductDataRow by NSVCode, and Master Site ID 18Dec13 XN	78339</summary>
        public void LoadByNSVCodeAndMasterSiteID(string NSVCode, int DSSMasterSiteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("@NSVCode",          NSVCode              );
            parameters.Add("@DSSMasterSiteID",  DSSMasterSiteID      );
            this.LoadBySP("pSiteProductDataByNSVCodeAndMasterSiteID", parameters);
        }

        /// <summary>Loads by code and master site ID (used by product search) 18Dec13 XN 78339</summary>
        public void LoadByTradenameAndMasterSiteID(string tradename, int DSSMasterSiteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID   );
            parameters.Add("tradename",        tradename               );
            parameters.Add("@DSSMasterSiteID",  DSSMasterSiteID        );
            LoadBySP("pSiteProductDataByTradenameAndMasterSiteID", parameters);
        }

        /// <summary>Loads by code and master site ID (used by product search) 18Dec13 XN 78339</summary>
        public void LoadByCodeAndMasterSiteID(string code, int DSSMasterSiteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("Code",             code                 );
            parameters.Add("@DSSMasterSiteID",  DSSMasterSiteID     );
            LoadBySP("pSiteProductDataByCodeAndMasterSiteID", parameters);
        }

        /// <summary>Loads by label description and master site ID (used by product search) 18Dec13 XN 78339</summary>
        public void LoadByLabelDescriptionAndMasterSiteID(string description, int DSSMasterSiteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("LabelDescription", description          );
            parameters.Add("@DSSMasterSiteID",  DSSMasterSiteID      );
            LoadBySP("pSiteProductDataByLabelDescriptionAndMasterSiteID", parameters);
        }

        /// <summary>
        /// Loads by barcode and master site ID (used by product search)
        /// Does not search alternate barcodes
        /// 18Dec13	XN	78339
        /// </summary>
        public void LoadByBarcodeAndMasterSiteID(string barcode, int DSSMasterSiteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("barcode",          barcode              );
            parameters.Add("DSSMasterSiteID",  DSSMasterSiteID      );
            LoadBySP("pSiteProductDataByBarcodeAndMasterSiteID", parameters);
        }

        /// <summary>Loads rows by and alias and DSS Master Site ID 18Dec13	XN	78339</summary>
        public void LoadByAliasGroupAliasAndMasterSiteID(string aliasGroup, string alias, int DSSMasterSiteID, bool append = false)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("AliasGroup", aliasGroup);
            parameters.Add("Alias", alias);
            parameters.Add("DSSMasterSiteID", DSSMasterSiteID);
            LoadBySP(append, "pSiteProductDataByAliasGroupAliasAndMasterSiteID", parameters);
        }

        /// <summary>Loads by SiteProductDataID 18Dec13	XN	78339</summary>
        public void LoadBySiteProductDataID(int siteProductDataID, bool append = false)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteProductDataID", siteProductDataID    );
            LoadBySP(append, "pSiteProductDataBySiteProductDataID", parameters);
        }

        /// <summary>Loads by DrugID and SiteID (12Feb14 XN 56071)</summary>
        public void LoadByDrugIDAndSiteID(int drugID, int siteID, bool append = false)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("DrugID",            drugID);
            parameters.Add("SiteID",            siteID);
            LoadBySP(append, "pSiteProductDataByDrugIDAndSiteID", parameters);
        }

        /// <summary>Loads by DrugID and DSS master site ID XN 30Jun14 94416</summary>
        public void LoadByDrugIDAndMasterSiteID(int drugID, int DSSMasterSiteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("DrugID",            drugID);
            parameters.Add("DSSMasterSiteID",   DSSMasterSiteID);
            LoadBySP("pSiteProductDatabyDrugIDAndMasterSiteID", parameters);
        }

        /// <summary>Loads by bnf (and all sub BNFs) and DSS master site ID 17Oct14 XN  88560</summary>
        public void LoadByBNFAndMasterSiteID(string bnf, int DSSMasterSiteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("BNF",               bnf);
            parameters.Add("DSSMasterSiteID",   DSSMasterSiteID);
            LoadBySP("pSiteProductDatabyBNFAndMasterSiteID", parameters);
        }

        /// <summary>Loads by DrugID and SiteID (12Feb14 XN 56071)</summary>
        public static SiteProductDataRow GetByDrugIDAndSiteID(int drugID, int siteID)
        {
            SiteProductData spd = new SiteProductData();
            spd.LoadByDrugIDAndSiteID(drugID, siteID);
            return spd.FirstOrDefault();
        }

        /// <summary>Loads by DrugID and DSS master site ID XN 30Jun14 94416</summary>
        public static SiteProductDataRow GetByDrugIDAndMasterSiteID(int drugID, int DSSMasterSiteID)
        {
            SiteProductData spd = new SiteProductData();
            spd.LoadByDrugIDAndMasterSiteID(drugID, DSSMasterSiteID);
            return spd.FirstOrDefault();
        }
    }

    /// <summary>Provides extension methods to IEnumerable{SiteProductDataRow} class 03Feb14 XN  56071</summary>
    public static class SiteProductDataEnumerableExtensions
    {
        /// <summary>Returns first item with specified NSVCode, else null</summary>
        public static SiteProductDataRow FindByNSVCode(this IEnumerable<SiteProductDataRow> siteProductData, string NSVCode)
        {
            return siteProductData.FirstOrDefault(s => s.NSVCode == NSVCode);
        }
    }
}
