//===========================================================================
//
//							    WProductQSProcessor.cs
//
//  Maps the fields in WProduct to QuesScrl data indexes stores in WConfiguration
//
//  Supports interface IQSDisplayAccessor
//  
//	Modification History:
//	23Jan14 XN  Written
//  12Mar14 XN  Added field for DMandDReference
//  19Mar14 XN  86646 Fixed error returning MinConcentration field (also corrected
//              validation of Min\Max and Final Concentration 
//  25Mar14 XN  Update service view is avaiable to all
//  16Jun14 XN  Moved from QS layer to pharmacy layer 88509
//              Validation replaced \r\n with \n so places line breaks when convert to HTML
//  26Jun14 XN  Fixed issue with validation when it raise exception did not display error correctly
//  08Sep14 XN  Added support for IQSDisplayAccessor 
//  20Jan15 XN  Update Save to use new WPharmacyLogType 26734
//  30Apr15 XN  Added support for LabelDescriptionInPatient, and LabelDescriptionOutPatient 98073
//              GetDSSMaintainedDataIndex if field is locked so user editable then outside of DSS control 98073
//  18May15 XN  Update Save for changes in WProductQSProcessor 18May15 XN 117528
//  30Jul15 XN  Moved the validation of the Vat code to ValidateVATCode 124545
//  03Mar16 XN  Improved lookup list 99381
//  22Mar16 XN  Updated GetProductEditorViews to prevent object ref crash if missing views
//  13Jul15 XN  Added extra format options for conversionfactorpacktoissueunits, and stocklevelinissueunits 39882
//  18Jul16 XN  Added ValidateAlternateBarcode as now shared by different forms 126634
//  24Jun16 XN  Create interface file on save 108889
//  15Aug16 XN  Create interface file on save 108889
//  20Jan17 XN  126634 - Updated GetValueForDisplay Added for configurable F4 supplier info panel
//  11Apr18 DR  Bug 209612 - Pharmacy Product Editor - Can edit Product Tradename field against a VMPP maintained by DSS when should not be able to
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    using System.Data;
    using System.Text;

    /// <summary>Maps the fields in WProduct to QuesScrl data indexes stores in WConfiguration</summary>
    public class WProductQSProcessor : QSBaseProcessor, IQSDisplayAccessor
    {
        #region Important View Indexes
        public const int VIEWINDEX_ROBOT_CONFIGURATION      = 1010;
        public const int VIEWINDEX_UPDATESERVICE            = 1020;
        public const int VIEWINDEX_GLOBAL_PRODUCT_FIELDS    = 1021;
        public const int VIEWINDEX_ALTERNATE_BARCODES       = -1;
        public const int VIEWINDEX_EDIT_SUPPLIERPROFILE     = -4;
        public const int VIEWINDEX_EDIT_SUPPLIER_CONTRACT   = -5;
        public const int VIEWINDEX_SEND_TO_ROBOT            = -14;

        // View indexes when adding
        public const int VIEWINDEX_ADD_BY_IMPORT_FROM_MASTER = 1003;
        public const int VIEWINDEX_ADD_BY_IMPORT_FROM_SITE   = 1004;
        public const int VIEWINDEX_ADD_FROM_MP               = 1005;
        public const int VIEWINDEX_ADD_FROM_NMP              = 1006;
        public const int VIEWINDEX_ADD_STORES_ONLY           = 1007;
        public const int VIEWINDEX_IMPORT_TO_SITES           = 1008;
        public const int VIEWINDEX_ADD_COPY_EXISTING         = 1009;
        #endregion

        #region Important Data Indexes
        public const int DATAINDEX_LABELDESCRIPTION             = 2;
        public const int DATAINDEX_TRADENAME                    = 3;
        public const int DATAINDEX_COST                         = 4;
        public const int DATAINDEX_NSVCODE                      = 9;
        public const int DATAINDEX_BARCODE                      = 10;
        public const int DATAINDEX_WARNCODE                     = 15;       
        public const int DATAINDEX_INSCODE                      = 16;
        public const int DATAINDEX_LASTRECEIVEDPRICE            = 34;
        public const int DATAINDEX_LOCATION                     = 37;
        public const int DATAINDEX_WARNCODE2                    = 68;
        public const int DATAINDEX_STORESDESCRIPTION            = 82;
        public const int DATAINDEX_LOCATION2                    = 86;
        public const int DATAINDEX_CANUSESPOON                  = 121;    
        public const int DATAINDEX_LABELDESCRIPTIONINPATIENT    = 138;  // Added 30Apr15 XN 98073
        public const int DATAINDEX_LABELDESCRIPTIONOUTPATIENT   = 139;  // Added 05May15 XN 98073
        public const int DATAINDEX_STORESDESCRIPTION_PRODUCTSTOCK=140;  // Added 19May15 XN 98073
        public const int DATAINDEX_DESCRIPTION                  = 150;  // Added 19May15 XN 98073 (general description for the drug ToString version readonly)
        #endregion

        #region Private Properites
        private MoneyDisplayType moneyDisplayType;
        #endregion

        #region Public Properties
        public WProduct     Products { get; private set; }
        public WPharmacyLog Log      { get; private set; }
        #endregion

        #region Constuctor
        public WProductQSProcessor() : base(null) { }
    
        public WProductQSProcessor(MoneyDisplayType moneyDisplayType) : base(null)
        {
            this.moneyDisplayType = moneyDisplayType;
        }

        public WProductQSProcessor(WProduct products, IEnumerable<int> siteIDs) : base(siteIDs)
        {
            this.Products = products;
            this.Log      = new WPharmacyLog(); 
            this.SiteIDs  = siteIDs.Where(s => products.Any(p => p.SiteID == s)).ToList();
        }
        #endregion

        #region Public Methods
        /// <summary>
        /// If drug is a dss drug returns list of DSS Maintained Data Indexes.
        /// if DSS on web is enabled (Setting System.Reference.DSSUpdateServiceInUse), gets list from Setting Security.Settings.DSS Maintained Fields
        /// if DSS on web is not enabled, gets list from WConfiguration (D|STKMAINT.Editor.DSS Maintained Fields)
        /// </summary>
        public int[] GetDSSMaintainedDataIndex()
        {
            List<int> returnValue = new List<int>();

            WProductRow product = this.Products.FirstOrDefault();
            if (product != null && product.IsDSSMaintainedDrug())
            {
                if (SettingsController.Load<bool>("System", "Reference", "DSSUpdateServiceInUse", false))
                {
                    returnValue = SettingsController.Load<string>("Security", "Settings", "DSS Maintained Fields", string.Empty).ParseCSV<int>(",", true).ToList();
                }
                else
                {
                    returnValue = WConfiguration.Load<string>(SessionInfo.SiteID, "D|STKMAINT", "Editor", "DSS Maintained Fields", string.Empty, false).ParseCSV<int>(",", true).ToList();
                }

                // Remove non editable state if the field is locked (so allowed to edit field) 98073 XN 27Apr15 
                if (product.WarningCode_Locked)         { returnValue.Remove(DATAINDEX_WARNCODE);           }
                if (product.WarningCode2_Locked)        { returnValue.Remove(DATAINDEX_WARNCODE2);          }
                if (product.InstructionCode_Locked)     { returnValue.Remove(DATAINDEX_INSCODE);            }
                if (product.CanUseSpoon_Locked)         { returnValue.Remove(DATAINDEX_CANUSESPOON);        }
                if (product.StoresDescription_Locked)   { returnValue.Remove(DATAINDEX_STORESDESCRIPTION);  }
                if (product.LabelDescription_Locked)    { returnValue.Remove(DATAINDEX_LABELDESCRIPTION);   }
            }

            return returnValue.ToArray();
        }

        /// <summary>Given set of view indexes, returns dictionary of view index to description for the product editor</summary>
        /// <param name="viewIndexes">List of view indexes</param>
        /// <returns>dictionary of view indexes to description</returns>
        public static IDictionary<int, string> GetProductEditorViews(IEnumerable<int> viewIndexes)
        {
            List<int> viewIndexList = viewIndexes.ToList();
            return GetProductEditorViews(false).
                            Where(i => viewIndexList.Contains(i.Key)).
                            OrderBy(i => viewIndexList.IndexOf(i.Key)).
                            ToDictionary(v => v.Key, v => v.Value);
        }

        /// <summary>Returns dictionary of all view index (to description) for the product editor</summary>
        /// <param name="filterToValidOnly">If it filter out views that would not be valid</param>
        /// <returns>dictionary of all view indexes to description</returns>
        public static IDictionary<int, string> GetProductEditorViews(bool filterToValidOnly)
        {
            Dictionary<int, string> restuls = new Dictionary<int,string>();

            WConfiguration config = new WConfiguration();
            config.LoadBySiteCategoryAndSection(SessionInfo.SiteID, "D|STKMAINT", "Views");

            int total = 1000;
            var totalRow = config.FindByKey("Total");
            if (totalRow != null)
                int.TryParse(totalRow.Value, out total);

            foreach (var viewRow in config)
            {
                string[] viewInfo = viewRow.Value.Split(new [] {','}, 2);
                int index;

                if (int.TryParse(viewRow.Key, out index) && (!filterToValidOnly || index <= total) && viewInfo.Length > 0)
                    restuls[index] = viewInfo[0];
            }

            if (config.FindByKey(WProductQSProcessor.VIEWINDEX_GLOBAL_PRODUCT_FIELDS.ToString()) != null)   // XN 22Mar16 prevent object ref crash
                restuls[WProductQSProcessor.VIEWINDEX_GLOBAL_PRODUCT_FIELDS ] = config.FindByKey(WProductQSProcessor.VIEWINDEX_GLOBAL_PRODUCT_FIELDS.ToString()).Value.Split(new [] {','}, 2)[0];
            if (config.FindByKey(WProductQSProcessor.VIEWINDEX_ROBOT_CONFIGURATION.ToString()) != null)     // XN 22Mar16 prevent object ref crash
                restuls[WProductQSProcessor.VIEWINDEX_ROBOT_CONFIGURATION   ] = config.FindByKey(WProductQSProcessor.VIEWINDEX_ROBOT_CONFIGURATION.ToString  ()).Value.Split(new [] {','}, 2)[0];
            restuls[WProductQSProcessor.VIEWINDEX_SEND_TO_ROBOT         ] = "Send Product Info to Robot";
            restuls[WProductQSProcessor.VIEWINDEX_ALTERNATE_BARCODES    ] = "Alternate Barcode";
            restuls[WProductQSProcessor.VIEWINDEX_EDIT_SUPPLIERPROFILE  ] = "Edit Supplier Profile";
            restuls[WProductQSProcessor.VIEWINDEX_EDIT_SUPPLIER_CONTRACT] = "Edit Supplier Contract";
            //if (!filterToValidOnly || SettingsController.Load<bool>("System", "Reference", "DSSUpdateServiceInUse", false))   25Mar14 XN Update service view is avaiable to all
            if (config.FindByKey(WProductQSProcessor.VIEWINDEX_UPDATESERVICE.ToString()) != null)           // XN 22Mar16 prevent object ref crash
                restuls[WProductQSProcessor.VIEWINDEX_UPDATESERVICE] = config.FindByKey(WProductQSProcessor.VIEWINDEX_UPDATESERVICE.ToString  ()).Value.Split(new [] {','}, 2)[0];

            return restuls;
        }
        
        /// <summary>Used by grid, and panel, to convert special field values to string</summary>
        /// <param name="row">BaseRow being processed</param>
        /// <param name="fieldName">Name of field to convert normally in {} values</param>
        /// <param name="formatString">Format string for field</param>
        /// <returns>Converted field value</returns>
        public string FieldConvterFunction(object row, string fieldName, string formatString)
        {
            WProductRow product = (row as WProductRow);

            switch (fieldName.ToLower())
            {
            case "{description}":           return product.ToString();
            case "{cost}":                  return product.AverageCostExVatPerPack.ToMoneyString(this.moneyDisplayType);
            case "{leadtimeindays}":        return product.LeadTimeInDays.ToString("0.#");
            case "{reorderquantity}":       return product.RawRow["reorderqty"] == DBNull.Value ? string.Empty : product.ReOrderQuantityInPacks.ToString(ProductStock.GetColumnInfo().ReOrderQuantityInPacksLength);
            case "{saftyfactor}":           return product.SafetyFactor.ToString("0.####");
            case "{usagedamping}":          return product.UsageDamping.ToString("0.####");
            case "{usethisperiod}":         return product.UseThisPeriodInIssueUnits.ToString("0.####");
            case "{mlsperpack}":            return product.mlsPerPack.ToString("0.####");
            case "{outstanding}":           return product.OutstandingInIssueUnits.ToString("0.####");
            case "{doses}":                 return product.DosesPerIssueUnit == null ? string.Empty : product.DosesPerIssueUnit.Value.ToString("0.####");
            case "{reconstitutionvolume}":  return product.ReconstitutionVolumeInml == null  ? string.Empty : product.ReconstitutionVolumeInml.Value.ToString("0.#####");
            case "{finalcon}":              return product.FinalConcentrationInDoseUnitsPerml.Value.ToString("0.#####");
            case "{maxcon}":                return product.MaxConcentrationInDoseUnitsPerml == null ? string.Empty : product.MaxConcentrationInDoseUnitsPerml.Value.ToString("0.#####");
            case "{mincon}":                return product.MinConcentrationInDoseUnitsPerml == null ? string.Empty : product.MinConcentrationInDoseUnitsPerml.Value.ToString("0.#####");
            case "{displacementvol}":       return product.DisplacementVolumeInml == null ? string.Empty : product.DisplacementVolumeInml.Value.ToString("0.####");
            case "{infusiontime}":          return product.InfusionTime.ToString("0.####");
            case "{maxinfusionrate}":       return product.RawRow["MaxInfusionRate"] == DBNull.Value ? string.Empty : ((double)product.RawRow["MaxInfusionRate"]).ToString("0.####");
            case "{lastrecprice}":          return product.LastReconcilePriceExVatPerPack == null ? string.Empty : product.LastReconcilePriceExVatPerPack.ToString();
            case "{mindailydose}":          return product.MinDailyDose == null ? string.Empty : product.MinDailyDose.Value.ToString("0.####");
            case "{maxdailydose}":          return product.MaxDailyDose == null ? string.Empty : product.MaxDailyDose.Value.ToString("0.####");
            case "{mindosefreq}":           return product.MinDoseFrequency == null ? string.Empty : product.MinDoseFrequency.Value.ToString("0.####");
            case "{maxdosefreq}":           return product.MaxDoseFrequency == null ? string.Empty : product.MaxDoseFrequency.Value.ToString("0.####");
            case "{lastissueddate}":        return product.LastIssuedDate.ToPharmacyDateString();
            case "{lastorderddate}":        return product.LastOrderedDate.ToPharmacyDateString();
            case "{batchtracking}":         return product.BatchTracking.ToString();
            }

            return string.Empty;
        }

        /// <summary>
        /// Validates alternate barcode
        ///     1. Can check barcode is an EAN-13 EAN-8 or GTIN barcode
        ///     2. Checks that the value is filled in
        ///     3. check barcode is not the same as the primary
        ///     4. Check barcode is not currently in the list of alternate barcodes
        /// 18Jul16 XN 126634
        /// </summary>
        /// <param name="tbBarcode">Barcode control</param>
        /// <param name="ctrlName">Control name</param>
        /// <param name="error">Error if return false</param>
        /// <returns>Returns false if not valid</returns>
        public bool ValidateAlternateBarcode(TextBox tbBarcode, string ctrlName, out string error)
        {
            string newBarcode = tbBarcode.Text.Trim();

            if (!this.Products.Any())
                throw new ApplicationException("No products loaded to get alternate ");

            if (!Validation.ValidateBarcode(tbBarcode, ctrlName, true, out error))
                return false;

            var product = this.Products.First();    // only need to top one as alternate barcodes are on SiteProductData
            if (newBarcode == product.Barcode)
            {
                error = "Must be different to primary barcode";
                return false;
            }        
        
            if (product.GetAlternativeBarcode().Contains(newBarcode))
            {
                error = "Barcode already exists";
                return false;
            }

            return true;
        }
        #endregion

        #region Overridden Methods
        /// <summary>Returns a list of data field indexes whose values must be filled in by user</summary>
        public override HashSet<int> GetRequiredDataIndexes(QSView qsView)
        {
            HashSet<int> requiredDataFieldMap = new HashSet<int>( base.GetRequiredDataIndexes(qsView) );

            requiredDataFieldMap.Add(1);    // Code
            requiredDataFieldMap.Add(2);    // Label Description
            requiredDataFieldMap.Add(4);    // Cost
            requiredDataFieldMap.Add(6);    // Supplier code
            requiredDataFieldMap.Add(9);    // NSVCode
            requiredDataFieldMap.Add(10);   // Barcode
            requiredDataFieldMap.Add(13);   // Formulary
            requiredDataFieldMap.Add(23);   // PrintformV
            requiredDataFieldMap.Add(24);   // MinIssueInIssueUnits
            requiredDataFieldMap.Add(25);   // MaxIssueInIssueUnits
            requiredDataFieldMap.Add(26);   // ReorderLevelInIssueUnits
            requiredDataFieldMap.Add(27);   // ReOrderQuantityInPacks
            requiredDataFieldMap.Add(28);   // ReOrderPackSize
            requiredDataFieldMap.Add(36);   // Live Stock
            requiredDataFieldMap.Add(38);   // Start of period
            requiredDataFieldMap.Add(39);   // Safety factor
            requiredDataFieldMap.Add(40);   // Usage damping default
            requiredDataFieldMap.Add(42);   // In use
            requiredDataFieldMap.Add(49);   // Tax
            requiredDataFieldMap.Add(50);   // Dosing units
            requiredDataFieldMap.Add(51);   // DosesPerIssueUnit
            requiredDataFieldMap.Add(58);   //
            requiredDataFieldMap.Add(59);   // Max Concentration in Dose Units/ml
            requiredDataFieldMap.Add(60);   // Min Concentration in Dose Units/ml 19Mar14 XN 86646 Added as required field
            requiredDataFieldMap.Add(67);   // PIL number
            //requiredDataFieldMap.Add(72);   // Local product code
            requiredDataFieldMap.Add(120);  // Label in issue Units

            return requiredDataFieldMap;
        }

        /// <summary>Called to update qsView with all the values (from processor data)</summary>
        public override void PopulateForEditor(QSView qsView)
        {
            foreach(int siteID in this.SiteIDs)
            {
                WProductRow wproductRow = Products.FindBySiteID(siteID).FirstOrDefault();

                foreach(var qsDataInputItem in qsView)
                    qsDataInputItem.SetValueBySiteID(siteID, this.GetValueForEditor(wproductRow, qsDataInputItem.index));
            }
        }

        /// <summary>Returns mapped data index value as string</summary>
        public string GetValueForEditor(BaseRow row, int index)
        {
            try
            {
                WProductRow product = row as WProductRow;
                switch (index)
                {
                case   1: return product.Code.TrimEnd();
                case   2: return product.LabelDescription.TrimEnd();
                case   3: return product.Tradename.TrimEnd();
                case   4: return product.RawRow["cost"].ToString().TrimEnd();
                case   5: return product.ContractNumber.TrimEnd();
                case   6: return product.SupplierCode.TrimEnd();
                case   7: return product.RawRow["altsupcode"].ToString().TrimEnd();    // Not really supported any more
                case   8: return product.LedgerCode.TrimEnd();
                case   9: return product.NSVCode.TrimEnd();
                case  10: return product.Barcode.TrimEnd();
                case  11: return product.IsCytotoxic.ToYNString();
                case  12: return product.IsCIVAS.ToYNString();
                case  13: return product.FormularyCode.TrimEnd();
                case  14: return product.BNF.TrimEnd();
                case  15: return product.WarningCode.TrimEnd();
                case  16: return product.InstructionCode.TrimEnd();
//                case  17: return product.DirectionCode.TrimEnd();
                case  18: return product.LabelFormat.TrimEnd();
                case  19: return product.ExpiryTimeInMintues.ToString().TrimEnd();
                case  20: return product.IsStocked.ToYNString(); 
                case  21: return product.LeadTimeInDays.ToString("0.#");
                case  22: return product.ReorderPackSize.ToString();
                case  23: return product.PrintformV.TrimEnd();
                case  24: return product.MinIssueInIssueUnits.ToString();
                case  25: return product.MaxIssueInIssueUnits.ToString();
                case  26: return product.ReorderLevelInIssueUnits.ToString();
                case  27: return product.RawRow["reorderqty"] == DBNull.Value ? string.Empty : product.ReOrderQuantityInPacks.ToString(ProductStock.GetColumnInfo().ReOrderQuantityInPacksLength);
                case  28: return product.ConversionFactorPackToIssueUnits.ToString();
                case  29: return product.AnnualUsageInIssueUnits.ToString();
                case  30: return product.Notes.TrimEnd();
                case  31: return product.TherapyCode.TrimEnd();
                case  32: return product.ExtraLabel.TrimEnd();
                case  33: return product.StockLevelInIssueUnits.ToString();
                case  34: return product.LastReceivedPriceExVatPerPack.ToString();
                case  35: return product.ContractPrice.ToString();
                case  36: return product.IfLiveStockControl.ToYNString();
                case  37: return product.Location.TrimEnd();
                case  38: return product.StartOfPeriod.ToPharmacyDateString();
                case  39: return product.SafetyFactor.ToString("0.####");
                case  40: return product.UsageDamping.ToString("0.####");
                case  41: return product.UseThisPeriodInIssueUnits.ToString("0.####");
                case  42: return product.InUse ? "Y" : "N";
                case  43: return product.mlsPerPack.ToString("0.####");
                case  44: return product.ReCalculateAtPeriodEnd.ToYNString();
                case  45: return product.LossesGainExVat.ToString();
                case  46: return product.OrderCycle.TrimEnd();
                case  47: return product.CycleLengthInDays.ToString();
                case  48: return product.OutstandingInIssueUnits.ToString("0.####");
                case  49: return product.VATCode.ToString();
                case  50: return product.DosingUnits.TrimEnd();
                case  51: return product.DosesPerIssueUnit == null ? string.Empty : product.DosesPerIssueUnit.Value.ToString("0.####");
                case  55: return product.MessageCode;
                case  56: return product.ReconstitutionVolumeInml == null  ? string.Empty : product.ReconstitutionVolumeInml.Value.ToString("0.#####");
                case  57: return product.ReconstitutionAbbreviation.TrimEnd();
                case  58: return product.FinalConcentrationInDoseUnitsPerml.Value.ToString("0.#####");
                case  59: return product.MaxConcentrationInDoseUnitsPerml == null ? string.Empty : product.MaxConcentrationInDoseUnitsPerml.Value.ToString("0.#####");
                //case  60: return product.MinConcentrationInDoseUnitsPerml == null ? string.Empty : product.MaxConcentrationInDoseUnitsPerml.Value.ToString("0.#####"); 19Mar14 XN 86646 got to return correct value
                case  60: return product.MinConcentrationInDoseUnitsPerml == null ? string.Empty : product.MinConcentrationInDoseUnitsPerml.Value.ToString("0.#####");
                case  61: return product.DiluentAbbreviation1.TrimEnd();
                case  62: return product.DiluentAbbreviation2.TrimEnd();
                case  63: return product.IVContainer.TrimEnd();
                case  64: return product.DisplacementVolumeInml == null ? string.Empty : product.DisplacementVolumeInml.Value.ToString("0.####");
                case  65: return product.InfusionTime.ToString("0.####");
                case  66: return product.RawRow["MaxInfusionRate"] == DBNull.Value ? string.Empty : ((double)product.RawRow["MaxInfusionRate"]).ToString("0.####");
                case  67: return product.PILnumber.ToString();
                case  68: return product.WarningCode2.TrimEnd();
                case  71: return product.LastReconcilePriceExVatPerPack == null ? string.Empty : product.LastReconcilePriceExVatPerPack.ToString();
                case  72: return product.LocalProductCode.TrimEnd();
                case  73: return product.MinDailyDose == null ? string.Empty : product.MinDailyDose.Value.ToString("0.####");
                case  74: return product.MaxDailyDose == null ? string.Empty : product.MaxDailyDose.Value.ToString("0.####");
                case  75: return product.MinDoseFrequency == null ? string.Empty : product.MinDoseFrequency.Value.ToString("0.####");
                case  76: return product.MaxDoseFrequency == null ? string.Empty : product.MaxDoseFrequency.Value.ToString("0.####");
                case  81: return product.DPSForm.TrimEnd();
                case  82: return product.StoresDescription.TrimEnd();
                case  83: return product.RawRow["storespack"] == DBNull.Value ? string.Empty : product.RawRow["storespack"].ToString();
                case  86: return product.Location2.TrimEnd();
                case  87: return product.LastIssuedDate.ToPharmacyDateString();
                case  88: return product.LastOrderedDate.ToPharmacyDateString();
                case  89: return product.CreatedByUserInitials.TrimEnd();
                case  90: return product.CreatedOnTerminal.TrimEnd();
                case  91: return product.RawRow["createddate"] == DBNull.Value ? string.Empty : product.RawRow["createddate"].ToString().TrimEnd();
                case  92: return product.RawRow["createdtime"] == DBNull.Value ? string.Empty : product.RawRow["createdtime"].ToString().TrimEnd();
                case  93: return product.ModifiedByUserInitials.TrimEnd();
                case  94: return product.ModifiedOnTerminal.TrimEnd();
                case  95: return product.RawRow["modifieddate"] == DBNull.Value ? string.Empty : product.RawRow["modifieddate"].ToString().TrimEnd();
                case  96: return product.RawRow["modifiedtime"] == DBNull.Value ? string.Empty : product.RawRow["modifiedtime"].ToString().TrimEnd();
                case  97: return product.RawRow["batchtracking"]== DBNull.Value ? string.Empty : product.RawRow["batchtracking"].ToString().TrimEnd();
                case  98: return product.IsReconcileIfZeroPrice.ToYNString();
                case  99: return product.IssueWholePack.ToYNString();
                case 116: return product.CMICode.TrimEnd();                
                case 118: return product.PIPCode;
                case 119: return product.MasterPIP;
                case 120: return product.IsLabelInIssueUnits.ToYNString();
                case 121: return product.CanUseSpoon.ToYNString();
                case 122: return product.PhysicalDescription.TrimEnd();
                case 123: return product.RawRow["DDDValue"] == DBNull.Value ? string.Empty : product.RawRow["DDDValue"].ToString().TrimEnd();
                case 124: return product.RawRow["DDDUnits"] == DBNull.Value ? string.Empty : product.RawRow["DDDUnits"].ToString().TrimEnd();
                case 125: return product.RawRow["UserField1"] == DBNull.Value ? string.Empty : product.RawRow["UserField1"].ToString().TrimEnd();
                case 126: return product.RawRow["UserField2"] == DBNull.Value ? string.Empty : product.RawRow["UserField2"].ToString().TrimEnd();
                case 127: return product.RawRow["UserField3"] == DBNull.Value ? string.Empty : product.RawRow["UserField3"].ToString().TrimEnd();
                case 128: return product.RawRow["HIProduct"] == DBNull.Value ? string.Empty : product.RawRow["HIProduct"].ToString().TrimEnd();
                case 129: return product.EDILinkCode.TrimEnd();
                case 130: return product.PASANPCCode.TrimEnd();
                case 131: return product.PNExclude.ToYNString();
                //case 132: return "OK";    20Mar14 86723 Now done in SetLookupItem so maintained after view state
                //case 133: return "Edit";
                case 134: return product.EyeLabel.ToYNString();
                case 135: return product.PSOLabel.ToYNString();
                case 136: return product.ExpiryWarnDays.ToString();
                case 137: return product.DMandDReference.ToString();
                case 138: return product.LabelDescriptionInPatient;
                case 139: return product.LabelDescriptionOutPatient;
                case 140: return product.LocalDescription;
                }
            }
            catch(Exception)
            {
            }

            return string.Empty;
        }

        /// <summary>Call to setup all the lookups in QSView</summary>
        public override void SetLookupItem(QSView qsView)
        {
            foreach(int siteID in this.SiteIDs)
            {
                bool addMode = (Products.FindBySiteID(siteID).First().RawRow.RowState == System.Data.DataRowState.Added);

                if (qsView.ContainsDataIndex(6)) // Sup Code
                {
                    qsView.FindByDataIndex(6).SetLookupMap(siteID, "|", 1, "pharmacysharedscripts\\PharmacySupplierWardSearch.aspx?SessionID={0}&SiteID={1}&SupplierTypesFilter=ES&Title=Choose a Supplier Code&DefaultSupCode={{currentValue}}", SessionInfo.SessionID, siteID);
                    if (addMode)
                        qsView.FindByDataIndex(6).infoText = "Shift-F1 for list";
                    else
                    {
                        qsView.FindByDataIndex(6).GetBySiteID(siteID).Enabled = false;  // force read-only
                        qsView.FindByDataIndex(6).infoText = "(to change use Set Primary Supplier)";    // Does not seem to work
                    }
                }

                // BNF
                if (qsView.ContainsDataIndex(14))
                    qsView.FindByDataIndex(14).SetLookupMap(siteID, @"PharmacyProductEditor\BNFLookup.aspx?SessionID={0}&SiteID={1}&Depth=0&SelectedBNF={{currentValue}}", SessionInfo.SessionID, siteID);

                //string temp = string.Format(@"PharmacyReferenceData\ReferenceDataSelector.aspx?SessionID={0}&SiteID={1}&Title=Warnings&Info=Select Warning&contextType={2}&selectedDBID={{currentValue}}&ExtraLines=¡,,<No Warning>", SessionInfo.SessionID, siteID, WLookupContextType.Warning);     28Oct14 XN 102938 removed ¡ as not needed
                string temp = string.Format(@"PharmacyReferenceData\ReferenceDataSelector.aspx?SessionID={0}&SiteID={1}&Title=Warnings&Info=Select Warning&contextType={2}&selectedDBID={{currentValue}}&ExtraLines=,,<No Warning>", SessionInfo.SessionID, siteID, WLookupContextType.Warning);
                if (qsView.ContainsDataIndex(15))
                    qsView.FindByDataIndex(15).SetLookupMap(siteID, temp);  // Waring code
                if (qsView.ContainsDataIndex(68))
                    qsView.FindByDataIndex(68).SetLookupMap(siteID, temp);  // Waring code 2

                // Instruction code
                if (qsView.ContainsDataIndex(16))   
                    qsView.FindByDataIndex(16).SetLookupMap(siteID, @"PharmacyReferenceData\ReferenceDataSelector.aspx?SessionID={0}&SiteID={1}&Title=Instructions&Info=Select Instruction&contextType={2}&selectedDBID={{currentValue}}&ExtraLines=,,<No Instruction>", SessionInfo.SessionID, siteID, WLookupContextType.Instruction);

                // Issue units
                if (qsView.ContainsDataIndex(23))
                    qsView.FindByDataIndex(23).SetLookupMap(siteID, @"pharmacysharedscripts\PharmacyLookupList.aspx?SessionID={0}&SiteID={1}&Title=Issue Units&Info=Select Issue Units&sp=pPharmacyPrintFormVLookupList&Params=CurrentSessionID:{0}&Columns=Issue Unit,98&selectedDBID={{currentValue}}&SearchType=TypeAndSelect&SearchColumns=0&SearchText={{typedText}}", SessionInfo.SessionID, siteID);
                    //qsView.FindByDataIndex(23).SetLookupMap(siteID, @"pharmacysharedscripts\PharmacyLookupList.aspx?SessionID={0}&SiteID={1}&Title=Issue Units&Info=Select Issue Units&sp=pPharmacyPrintFormVLookupList&Params=CurrentSessionID:{0}&Columns=Issue Unit,98&selectedDBID={{currentValue}}", SessionInfo.SessionID, siteID); 3Mar16 XN 99381
            
                string sortBy = WConfiguration.Load(siteID, "D|ascribe", string.Empty, "LookupSortby", string.Empty, false);
                if (qsView.ContainsDataIndex(32))   // Extra Label Code
                    qsView.FindByDataIndex(32).SetLookupMap(siteID, @"PharmacyReferenceData\ReferenceDataSelector.aspx?SessionID={0}&SiteID={1}&Title=Label Format&Info=Select Label Format&contextType={2}&selectedDBID={{currentValue}}&ExtraLines=,,<None>", SessionInfo.SessionID, siteID, WLookupContextType.FFLabels);
                if (qsView.ContainsDataIndex(49))   // Vat Code
                    qsView.FindByDataIndex(49).SetLookupMap(siteID, @"pharmacysharedscripts\PharmacyLookupList.aspx?SessionID={0}&SiteID={1}&Title={2}&Info=Choose {2} Code&sp=pTaxLookup&Params=CurrentSessionID:{0},SiteID:{1}&Columns=Code,15,Description,85&selectedDBID={{currentValue}}&SearchType=TypeAndSelect&SearchColumns=0&SearchText={{typedText}}&Width=300&Height=400", SessionInfo.SessionID, siteID, PharmacyCultureInfo.SalesTaxName);
                    //qsView.FindByDataIndex(49).SetLookupMap(siteID, @"pharmacysharedscripts\PharmacyLookupList.aspx?SessionID={0}&SiteID={1}&Title={2}&Info=Choose {2} Code&sp=pTaxLookup&Params=CurrentSessionID:{0},SiteID:{1}&Columns=Code,15,Description,85&selectedDBID={{currentValue}}&Width=300&Height=400", SessionInfo.SessionID, siteID, PharmacyCultureInfo.SalesTaxName); 3Mar16 XN 99381
                if (qsView.ContainsDataIndex(50))   // Dosing Unit
                    qsView.FindByDataIndex(50).SetLookupMap(siteID, @"pharmacysharedscripts\PharmacyLookupList.aspx?SessionID={0}&SiteID={1}&Title=Dosing Units&Info=Choose Dosing Units&sp=pPharmacyDosingUnitLookup&Params=CurrentSessionID:{0},SiteID:{1}&Columns=Dosing Units,98&selectedDBID={{currentValue}}&SearchType=TypeAndSelect&SearchColumns=0&SearchText={{typedText}}&Width=300&Height=700", SessionInfo.SessionID, siteID);
                    //qsView.FindByDataIndex(50).SetLookupMap(siteID, @"pharmacysharedscripts\PharmacyLookupList.aspx?SessionID={0}&SiteID={1}&Title=Dosing Units&Info=Choose Dosing Units&sp=pPharmacyDosingUnitLookup&Params=CurrentSessionID:{0},SiteID:{1}&Columns=Dosing Units,98&selectedDBID={{currentValue}}&Width=300&Height=700", SessionInfo.SessionID, siteID); 3Mar16 XN 99381

                // Message Code
                if (qsView.ContainsDataIndex(55))
                    qsView.FindByDataIndex(55).SetLookupMap(siteID, @"PharmacyReferenceData\ReferenceDataSelector.aspx?SessionID={0}&SiteID={1}&Title=Message Code&Info=Choose Message Code&contextType={2}&selectedDBID={{currentValue}}&ExtraLines=,,<None>", SessionInfo.SessionID, siteID, WLookupContextType.UserMsg);

                // PIL (Patient information leaflets)
                if (qsView.ContainsDataIndex(67))    
                    qsView.FindByDataIndex(67).SetLookupMap(siteID, @"PharmacyProductEditor\PILLookup.aspx?SessionID={0}&SiteID={1}&SelectedPIL={{currentValue}}", SessionInfo.SessionID, siteID);

                if (qsView.ContainsDataIndex(132))
                    (qsView.FindByDataIndex(132).GetBySiteID(siteID) as Button).Text = "OK";
                if (qsView.ContainsDataIndex(133))
                    (qsView.FindByDataIndex(133).GetBySiteID(siteID) as Button).Text = "Edit";
            }
        }

        /// <summary>Called to validate the web controls in QSView</summary>
        /// <returns>Returns list of validation error or warnings</returns>
        public override QSValidationList Validate(QSView qsView)
        {
            QSValidationList validationInfo = new QSValidationList();
            WProductColumnInfo columnInfo = WProduct.GetColumnInfo();
            HashSet<int> required = this.GetRequiredDataIndexes(qsView);

            foreach (var siteID in SiteIDs)
            {
                WProductRow productRow = Products.FindBySiteID(siteID).FirstOrDefault();
                if (productRow == null)
                    continue;

                int productStockID    = productRow.ProductStockID;
                int siteProductDataID = productRow.SiteProductDataID;
                bool addMode          = (Products.FindBySiteID(siteID).First().RawRow.RowState == System.Data.DataRowState.Added);
                bool CIVAS            = productRow.IsCIVAS ?? false;
                if (!qsView.ValueIsNullOrEmpty(12, siteID))
                    CIVAS = ConvertExtensions.ChangeType<bool>(qsView.GetValueByDataIndexAndSiteID(12, siteID));
            
                foreach(QSDataInputItem item in qsView)
                {
                    try
                    {
                        WebControl webCtrl = item.GetBySiteID(siteID);
                        if (webCtrl is Label || !item.Enabled)
                            continue;

                        string value = item.GetValueBySiteID(siteID);
                        string error = string.Empty;

                        // 16Oct14 XN 102125 allow setting item mandatory via config
                        if (item.ForceMandatory && string.IsNullOrWhiteSpace(value))
                            validationInfo.AddError(siteID, "Please enter " + item.description + " value");

                        switch(item.index)
                        {
                        case 1: // Code
                            //if (!PatternMatch.Validate(value, PatternMatch.LookupCodePattern)) XN 11Jul14 fixed issue with pattern match where user can enter a shorter code than pattern
                            int patternLength = Math.Max(3, value.Length);   // Min length is 3
                            if (!PatternMatch.Validate(value, PatternMatch.LookupCodePattern.SafeSubstring(0, patternLength)))   // yes it does trim the lookup pattern to the length
                                validationInfo.AddError(siteID, item.description + " invalid should be " + PatternMatch.LookupCodePattern.SafeSubstring(0, patternLength));
                            break;
                        case 2: // Label Description
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.LabelDescriptionLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 4: // Cost
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(decimal), required.Contains(item.index), 0, Double.MaxValue, out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 6: // Supplier code
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.SupplierCodeLength), out error))
                                validationInfo.AddError(siteID, error);
                            else if (WSupplier.GetBySupCodeAndSite(value, siteID) == null)
                                validationInfo.AddError(siteID, "Supplier '" + value + "' not supported by site.");
                            break;
                        case 9: // NSVCode
                            (webCtrl as TextBox).Text = (webCtrl as TextBox).Text.ToUpper();
                            string nsvcode = (webCtrl as TextBox).Text;
                            if (!PatternMatch.Validate(nsvcode, PatternMatch.NSVCodePattern))
                                validationInfo.AddError(siteID, item.description + " invalid should be " + PatternMatch.NSVCodePattern);
                            else
                            {
                                SiteProductData siteProductData = new SiteProductData();
                                siteProductData.LoadBySiteIDAndNSVCode(siteID, nsvcode);
                                if (productRow.SiteProductDataID <= 0 && siteProductData.Any())
                                    validationInfo.AddError(siteID, "NSVCode in use for different product");

                                WProduct product_temp = new WProduct();
                                product_temp.LoadByNSVCode(nsvcode);
                                if (product_temp.Any(p => p.ProductStockID != productRow.ProductStockID && p.DrugID != productRow.DrugID))
                                    validationInfo.AddError(siteID, "NSVCode in use for different product");

                                if (productRow.DrugID > 0)
                                {
                                    product_temp.LoadAllSitesByDrugID(productRow.DrugID, productRow.SiteID);
                                    if (product_temp.Any(p => p.ProductStockID != productRow.ProductStockID && !p.NSVCode.EqualsNoCaseTrimEnd(nsvcode)))
                                        validationInfo.AddError(siteID, "Product in use for a different NSVCode");
                                }
                            }
                            break;
                        case 10: // Barcode
                            //if (string.IsNullOrWhiteSpace(value) || addMode)  85489 XN prevent being able to add duplicate barcode
                            if (string.IsNullOrWhiteSpace(value))
                            {
                                string NSVCode = productRow.NSVCode;
                                if (qsView.ContainsDataIndex(9) || !PatternMatch.Validate(NSVCode, PatternMatch.NSVCodePattern))
                                    NSVCode = qsView.GetValueByDataIndexAndSiteID(9, siteID);
                                    
                                if (string.IsNullOrEmpty(NSVCode))
                                    validationInfo.AddError(siteID, "Barcode not entered");
                                else if (string.IsNullOrWhiteSpace(value))
                                {
                                    validationInfo.AddWarning(siteID, "Dummy barcode created");
                                    (webCtrl as TextBox).Text = Barcode.GenerateEANDrugBarcode(NSVCode);
                                }
                            }
                            else if (value.Length != Math.Min(item.maxLength, columnInfo.BarcodeLength))
                                validationInfo.AddError(siteID, "Barcode must be {0} characters", Math.Min(item.maxLength, columnInfo.BarcodeLength));
                            else
                            {
                                GenericTable2 results = new GenericTable2();
                                List<SqlParameter> parameters = new List<SqlParameter>();
                                parameters.Add(new SqlParameter("CurrentSessionID",  SessionInfo.SessionID));
                                parameters.Add(new SqlParameter("DSSMasterSiteID",   Database.ExecuteSQLScalar<int>("SELECT TOP 1 DSSMasterSiteID FROM DSSMasterSiteLinkSite WHERE SiteID={0}", SessionInfo.SiteID)));
                                parameters.Add(new SqlParameter("SiteProductDataID", siteProductDataID));
                                parameters.Add(new SqlParameter("barcode",           value));
                                results.LoadBySP("pWProductCheckForBarcodeDuplication", parameters);
                                if (results.Any())
                                {
                                    string productDescription= results.First().RawRow["Description"].ToString().Trim().Replace("!", " ");
                                    string siteDescription   = results.Select(r => r.RawRow["SiteDescription"]).ToCSVString(",");

                                    validationInfo.AddError(siteID, "Re-Enter barcode: {0} already in use by {1} in {2}", value, productDescription, siteDescription);
                                }
                            }
                            break;
                        case 13: // Formulary
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), 1, out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 14: // BNF
                            if (value.ToCharArray().Any(c => !Char.IsDigit(c) && c != '.'))
                                validationInfo.AddError(siteID, "BNF Code is invalid");
                            break;
                        case 15: // Warning Code
                            if (!string.IsNullOrWhiteSpace(value) && value != "¡" && !WLookup.IfExists(siteID, value, WLookupContextType.Warning, PharmacyCultureInfo.GetCountryCode(siteID)))  // The check for ¡ comes from old Vb6 world were can have this char if user selects no warning
                                validationInfo.AddError(siteID, "Invalid " + item.description + " '" + value + "'");
                            break;
                        case 16: // Instruction Code
                            if (!string.IsNullOrWhiteSpace(value) && value != "¡" && !WLookup.IfExists(siteID, value, WLookupContextType.Instruction, PharmacyCultureInfo.GetCountryCode(siteID)))  // The check for ¡ comes from old Vb6 world were can have this char if user selects no warning
                                validationInfo.AddError(siteID, "Invalid " + item.description + " '" + value + "'");
                            break;
                        case 19: // Expiry time
                            if (!string.IsNullOrWhiteSpace(value) && ConvertExtensions.ToMinutes(value) == null)
                                validationInfo.AddError(siteID, "Invalid " + item.description + " '" + value + "'");
                            break;
                        case 23:    // PrintformV
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), WProduct.GetColumnInfo().PrintformVLength, out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 24:    // MinIssueInIssueUnits
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(decimal), required.Contains(item.index), item.maxLength, out error))
                                validationInfo.AddError(siteID, error);

                            // Get the max issue
                            decimal? maxIssueInIssueUnits = null;
                            if (qsView.ContainsDataIndex(25))
                                maxIssueInIssueUnits = qsView.GetValueByDataIndexAndSiteID<decimal>(25, siteID);
                            else 
                                maxIssueInIssueUnits = productRow.MaxIssueInIssueUnits;

                            // Ensure min is less than max
                            if (maxIssueInIssueUnits != null && maxIssueInIssueUnits < decimal.Parse(value))
                                validationInfo.AddError(siteID, "Min issue must be equal or less than max issue");
                            break;
                        case 25:    // MaxIssueInIssueUnits
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(decimal), required.Contains(item.index), item.maxLength, out error))
                                validationInfo.AddError(siteID, error);

                            // Get the min issue
                            decimal? minIssueInIssueUnits = null;
                            if (qsView.ContainsDataIndex(24))
                                minIssueInIssueUnits = qsView.GetValueByDataIndexAndSiteID<decimal>(24, siteID);
                            else 
                                minIssueInIssueUnits = productRow.MinIssueInIssueUnits;

                            // Ensure min is less than max
                            if (minIssueInIssueUnits != null && decimal.Parse(value) < minIssueInIssueUnits)
                                validationInfo.AddError(siteID, "Min issue must be equal or less than max issue");
                            break;
                        case 26:    // ReorderLevelInIssueUnits
                            bool ifLiveStock = productRow.IfLiveStockControl ?? false;
                            if (!qsView.ValueIsNullOrEmpty(36, siteID))
                                ifLiveStock = ConvertExtensions.ChangeType<bool>(qsView.GetValueByDataIndexAndSiteID(36, siteID));

                            if (ifLiveStock && !Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error + " as stock control is live ");
                            break;
                        case 27:    // ReOrderQuantityInPacks
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(double), required.Contains(item.index), 0, Double.MaxValue, out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 28:    // ReOrderPackSize
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(double), required.Contains(item.index), 1, Double.MaxValue, out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 32:    // Extra label code
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), WProduct.GetColumnInfo().ExtraLabelLength, out error))
                                validationInfo.AddError(siteID, error);
                            else if (!string.IsNullOrWhiteSpace(value) && !WLookup.IfExists(siteID, value, WLookupContextType.FFLabels, PharmacyCultureInfo.GetCountryCode(siteID)))
                                validationInfo.AddError(siteID, "Invalid " + item.description + " '" + value + "'");
                            break;
                        case 36:    // Live Stock
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(bool), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 38:    // Start of period
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(DateTime), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 39:    // Safety factor
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(double), required.Contains(item.index), 0.000001, double.MaxValue, out error))
                            {
                                (webCtrl as TextBox).Text = "1.2";
                                validationInfo.AddWarning(siteID, "Safety factor missing: Setting to 1.2 as default");
                            }
                            break;
                        case 40:    // Usage damping default
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(double), required.Contains(item.index), 0.000001, double.MaxValue, out error))
                            {
                                (webCtrl as TextBox).Text = "0.75";
                                validationInfo.AddWarning(siteID, "Usage damping missing: Setting to 0.75 as default");
                            }
                            break;
                        case 42:    // In use
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(bool), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            else if (productRow.InUse != BoolExtensions.PharmacyParse(value) && BoolExtensions.PharmacyParse(value) == false /* check only apply if setting item out of use */
                                     && WConfiguration.Load<bool>(siteID, "D|STKMAINT", "Validation", "InUseExtraChecks", true, false))
                            {
                                // check stock level 102114 XN 15Oct14
                                var stockLevelInIssueUnits = productRow.StockLevelInIssueUnits;
                                if (!qsView.ValueIsNullOrEmpty(33, siteID))
                                    stockLevelInIssueUnits = ConvertExtensions.ChangeType<decimal>(qsView.GetValueByDataIndexAndSiteID(33, siteID));
                                if (stockLevelInIssueUnits > 0)
                                    validationInfo.AddWarning(siteID, item.description + ": Stock level is not 0");

                                // check losses and gains 102114 XN 15Oct14
                                var lossesGains = productRow.LossesGainExVat;
                                if (!qsView.ValueIsNullOrEmpty(45, siteID))
                                    lossesGains = ConvertExtensions.ChangeType<decimal>(qsView.GetValueByDataIndexAndSiteID(45, siteID));
                                if (lossesGains > 0)
                                    validationInfo.AddWarning(siteID, item.description + ": Item has losses and gains");

                                // Test if there are any outstanding orders 102114 XN 15Oct14 
                                WOrder orders = new WOrder();
                                string outstandingOrderStates = WConfiguration.Load(siteID, "D|STKMAINT", "Validation", "InUseOutstandingOrderStates", string.Empty, false);
                                if (!string.IsNullOrEmpty(outstandingOrderStates))
                                    orders.LoadBySiteIDNSVCodeSupCodeAndState(siteID, productRow.NSVCode, null, outstandingOrderStates.ToCharArray().Select(c => EnumDBCodeAttribute.DBCodeToEnum<OrderStatusType>(c.ToString())).ToArray());
                                    //orders.LoadBySiteIDNSVCodeSupCodeAndState(siteID, productRow.NSVCode, outstandingOrderStates.ToCharArray().Select(c => EnumDBCodeAttribute.DBCodeToEnum<OrderStatusType>(c.ToString())).ToArray()); 30Jul15 XN added extra supcode parameter 124545
                                
                                WRequis requis = new WRequis();
                                string requisOrderStates = WConfiguration.Load(siteID, "D|STKMAINT", "Validation", "InUseOutstandingRequisStates", string.Empty, false);
                                if (!string.IsNullOrEmpty(requisOrderStates))
                                    requis.LoadBySiteIDNSVCodeAndState(siteID, productRow.NSVCode, requisOrderStates.ToCharArray().Select(c => EnumDBCodeAttribute.DBCodeToEnum<OrderStatusType>(c.ToString())).ToArray());                                

                                if (orders.Any(o => o.Status == OrderStatusType.WaitingAuthorisation || o.Status == OrderStatusType.WaitingTransmissionConfirmation))
                                {
                                    validationInfo.AddError(siteID, item.description + ": Cannot be changed as part of an order awaiting authorisation");
                                }
                                if (orders.Any(o => o.Status == OrderStatusType.WaitingToReceive))
                                {
                                    validationInfo.AddWarning(siteID, item.description + ": Item is part of an order awaiting receipt");
                                }
                                if (orders.Any(o => o.Status == OrderStatusType.Return))
                                {
                                    validationInfo.AddWarning(siteID, item.description + ": Item is part of an order awaiting return to supplier");
                                }
                                if (requis.Any())
                                {
                                    validationInfo.AddWarning(siteID, item.description + ": Item is part of an outstanding requisition");
                                }

                                // Check if on stock lists 102114 XN 19Feb15
                                if (WConfiguration.Load<bool>(siteID, "D|STKMAINT", "Validation", "CheckIfOnWardStock", false, false))
                                {
                                    var ifOnStockList = Database.ExecuteSQLSingleField<int>("SELECT TOP 1 1 FROM WWardStockList WHERE NSVCode='{0}' AND SiteID={1}", productRow.NSVCode, siteID);
                                    if (ifOnStockList.Any())
                                    {
                                        validationInfo.AddWarning(siteID, item.description + ": Item is on a stock list");
                                    }
                                }

                                // Check if on formulary 102114 XN 19Feb15 
                                if (WConfiguration.Load<bool>(siteID, "D|STKMAINT", "Validation", "CheckIfInFormulary", false, false))
                                {
                                    var ifOnFormulary = Database.ExecuteSQLSingleField<int>("SELECT TOP 1 1 FROM WFormula WHERE LocationID_Site={0} AND (NSVCode='{1}' OR code1='{1}' OR code2='{1}' OR code3='{1}' OR code4='{1}' OR code5='{1}' OR code6='{1}' OR code7='{1}' OR code8='{1}' OR code9='{1}' OR code10='{1}' OR code11='{1}' OR code12='{1}' OR code13='{1}' OR code14='{1}' OR code15='{1}')", siteID, productRow.NSVCode);
                                    if (ifOnFormulary.Any())
                                    {
                                        validationInfo.AddWarning(siteID, item.description + ": Item is on a manufacturing formula");
                                    }
                                }

                                // Check if on formulary 102114 XN 19Feb15 
                                if (WConfiguration.Load<bool>(siteID, "D|STKMAINT", "Validation", "CheckIfInStockTake", false, false))
                                {
                                    var ifOnFormulary = Database.ExecuteSQLSingleField<int>("SELECT TOP 1 1 FROM WStockTake WHERE NSVCode='{0}' AND LocationID_Site={1}", productRow.NSVCode, siteID);
                                    if (ifOnFormulary.Any())
                                    {
                                        validationInfo.AddWarning(siteID, item.description + ": Item is on a live stock take");
                                    }
                                }
                            }
                            break;
                        case 49:    // Tax
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(int), required.Contains(item.index), 0, 9, out error))
                                validationInfo.AddError(siteID, error);
                            else if (productRow.VATCode != int.Parse(value))    
                            {
                                ValidateVATCode(siteID, productRow.NSVCode, productRow.SupplierCode, validationInfo); // XN 30Jul15 124545 Moved to method that can be shared with WSupplierProfileQSProcessor
                            }
                            break;
                        case 50:    // Dosing units
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 51:    // DosesPerIssueUnit
                            if (CIVAS && !Validation.ValidateText(webCtrl, item.description, typeof(double), required.Contains(item.index), 0, Double.MaxValue, out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 55:    // Message code
                            if (!string.IsNullOrWhiteSpace(value) && !WLookup.IfExists(siteID, value, WLookupContextType.UserMsg, PharmacyCultureInfo.CountryCode))
                                validationInfo.AddError(siteID, "Invalid " + item.description + " '" + value + "'");
                            break;
                        case 58:    // Final concentration in dose units
                            // if (CIVAS && !Validation.ValidateText(webCtrl, item.description, typeof(double), required.Contains(item.index), 0, Double.MaxValue, out error))  19Mar14 XN 86646 don't allow 0
                            if (CIVAS)
                            {
                                if (!Validation.ValidateText(webCtrl, item.description, typeof(double), required.Contains(item.index), 0, Double.MaxValue, out error))
                                    validationInfo.AddError(siteID, error);
                                else if (double.Parse(value) == 0.0)    // Can't have 0
                                    validationInfo.AddError(siteID, "Enter valid " + item.description);
                            }
                            break;
                        case 59:    // Max Concentration in Dose Units/ml
                            // if (CIVAS && !Validation.ValidateText(webCtrl, item.description, typeof(double), required.Contains(item.index), 0, Double.MaxValue, out error))  19Mar14 XN 86646 don't allow 0
                            if (CIVAS)
                            {
                                if (!Validation.ValidateText(webCtrl, item.description, typeof(double), required.Contains(item.index), 0, Double.MaxValue, out error))
                                    validationInfo.AddError(siteID, error);
                                else if (double.Parse(value) == 0.0)    // Can't have 0
                                    validationInfo.AddError(siteID, "Enter valid " + item.description);
                            }
                            break;
                        case 60:    // Min Concentration in Dose Units/ml  19Mar14 XN 86646 added validation
                            if (CIVAS)
                            {
                                if (!Validation.ValidateText(webCtrl, item.description, typeof(double), required.Contains(item.index), 0, Double.MaxValue, out error))
                                    validationInfo.AddError(siteID, error);
                                else if (double.Parse(value) == 0.0)    // Can't have 0
                                    validationInfo.AddError(siteID, "Enter valid " + item.description);
                            }
                            break;
                        case 65: // CIVAS Infuse in minutes (only allowed 1H or 4D, etc not W or Y)
                            if (!string.IsNullOrWhiteSpace(value) && (ConvertExtensions.ToMinutes(value) == null || "WY".Contains(value.SafeSubstring(value.Length - 1, 1))) )
                                validationInfo.AddError(siteID, "CIVAS: Infuse in minutes is invalid");
                            break;
                        case 67:    // PIL number
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(int), true, 0, 32767, out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 68:    // warning code 2
                            string warningCode = productRow.WarningCode;
                            if (qsView.ContainsDataIndex(15))
                                warningCode = qsView.GetValueByDataIndexAndSiteID(15, siteID);

                            if (!string.IsNullOrWhiteSpace(warningCode) && string.IsNullOrWhiteSpace(value))
                                validationInfo.AddWarning(siteID, item.description + " is blank");
                            else if (!string.IsNullOrWhiteSpace(value) && value != "¡" && !WLookup.IfExists(siteID, value, WLookupContextType.Warning, PharmacyCultureInfo.GetCountryCode(siteID)))  // The check for ¡ comes from old Vb6 world were can have this char if user selects no warning
                                validationInfo.AddError(siteID, "Invalid " + item.description + " '" + value + "'");
                            break;
                        case 72: // Local product code
                            if (!string.IsNullOrEmpty(value))
                            {
                                if (!PatternMatch.Validate(value, PatternMatch.LocalProductCodePattern))
                                    validationInfo.AddError(siteID, item.description + " invalid should be " + PatternMatch.LocalProductCodePattern);
                                else if (WConfiguration.Load<bool>(SessionInfo.SiteID, "D|STKMAINT", "Data", "LocalCodeUnique", true, false))
                                {
                                    WProduct product = new WProduct();
                                    product.LoadBySiteIDAndLocalProductCode(SessionInfo.SiteID, value);
                                    if (product.Any(p => p.ProductStockID != productStockID))
                                        validationInfo.AddError(siteID, "RE-ENTER local code: {0} already in use by {1}", value, product.First(p => p.ProductStockID != productStockID).ToString());
                                }
                            }
                            break;
                        case 120:   // Label in Issue Units
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 137: 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(long), false, 0, long.MaxValue, out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 138: // Label Description In Patient 30Apr15 XN 98073
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.LabelDescriptionInPatientLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 139: // Label Description Out Patient 05May15 XN 98073
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.LabelDescriptionOutPatientLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case 140: // ProductStock.StoresDescritpion 19May15 XN 98073
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.LocalDescriptionLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        }
                    }
                    catch (Exception ex)
                    {
                        //validationInfo.AddError(siteID, "Failed validating {0}\n{1}", item.description, ex.GetAllMessaages().Select(t => "\t" + t)); XN 26Jun14
                        validationInfo.AddError(siteID, "Failed validating {0}\n{1}", item.description, ex.GetAllMessaages().ToCSVString("\n"));
                    }
                }
            }

            return validationInfo;
        }

        /// <summary>Called to get difference between QS data and (original) process data</summary>
        public override QSDifferencesList GetDifferences(QSView qsView)
        {
            QSDifferencesList differences = new QSDifferencesList();
            foreach (int siteID in this.SiteIDs)
            {
                WProductRow product = this.Products.FindBySiteID(siteID).First();

                foreach (QSDataInputItem item in qsView)
                {
                    if (item.Enabled)
                    {
                        QSDifference? difference = item.CompareValues(siteID, this.GetValueForEditor(product, item.index));
                        if (difference != null)
                            differences.Add(difference.Value);
                    }
                }
            }
            return differences;
        }

        /// <summary>Save the values from QSView to the DB (or just localy)</summary>
        /// <param name="qsView">QueScrl controls that hold the data</param>
        /// <param name="saveToDB">If the qsView data is to be saved to the DB (or just updated local data)</param>
        public override void Save(QSView qsView, bool saveToDB)
        {
            QSDifferencesList   differences = this.GetDifferences(qsView);
            QSValidationList    validation = this.Validate(qsView);
            DateTime            now         = DateTime.Now;

            foreach (int siteID in this.SiteIDs)
            {
                WProductRow productRow  = Products.FindBySiteID(siteID).FirstOrDefault();
                if (productRow == null)
                    continue;

                foreach (QSDataInputItem item in qsView)
                {
                    if (!item.Enabled || item.CompareValues(siteID, GetValueForEditor(productRow, item.index)) == null)
                        continue;

                    string value = item.GetValueBySiteID(siteID);
                    switch(item.index)
                    {
                    case   1: productRow.Code                   = value; break;
                    case   2: productRow.LabelDescription       = value; break;
                    case   3: productRow.Tradename              = value; break;
                    case   4: productRow.AverageCostExVatPerPack= decimal.Parse(value); break;
                    case   5: productRow.ContractNumber         = value; break;
                    case   6: productRow.SupplierCode           = value; break;
                    case   7: productRow.RawRow["altsupcode"]   = value; break;
                    case   8: productRow.LedgerCode             = value; break; 
                    case   9: productRow.NSVCode                = value; break; 
                    case  10: productRow.Barcode                = value; break;
                    case  11: productRow.IsCytotoxic            = BoolExtensions.PharmacyParseOrNull(value); break;
                    case  12: productRow.IsCIVAS                = BoolExtensions.PharmacyParseOrNull(value); break;
                    case  13: productRow.FormularyCode          = value; break;
                    case  14: productRow.BNF                    = value; break;
                    case  15: productRow.WarningCode            = value; break;
                    case  16: productRow.InstructionCode        = value; break;
//                    case  17: productRow.DirectionCode          = value; break;
                    case  18: productRow.LabelFormat            = value; break;
                    case  19: productRow.ExpiryTimeInMintues    = (int)(ConvertExtensions.ToMinutes(value) ?? 0.0); break;
                    case  20: productRow.IsStocked              = BoolExtensions.PharmacyParseOrNull(value); break;
                    case  21: productRow.LeadTimeInDays         = string.IsNullOrWhiteSpace(value) ? (decimal?)null : decimal.Parse(value); break;
                    case  22: productRow.ReorderPackSize        = string.IsNullOrWhiteSpace(value) ? (decimal?)null : decimal.Parse(value); break;
                    case  23: productRow.PrintformV             = value; break;
                    case  24: productRow.MinIssueInIssueUnits   = decimal.Parse(value); break;
                    case  25: productRow.MaxIssueInIssueUnits   = decimal.Parse(value); break;
                    case  26: productRow.ReorderLevelInIssueUnits=string.IsNullOrWhiteSpace(value) ? (decimal?)null : decimal.Parse(value); break;
                    case  27: productRow.ReOrderQuantityInPacks = decimal.Parse(value); break;
                    case  28: productRow.ConversionFactorPackToIssueUnits= int.Parse(value); break;
                    case  29: productRow.AnnualUsageInIssueUnits= string.IsNullOrWhiteSpace(value) ? (decimal?)null : decimal.Parse(value); break;
                    case  30: productRow.Notes                  = value; break;
                    case  31: productRow.TherapyCode            = value; break;
                    case  32: productRow.ExtraLabel             = value; break;
                    case  33: productRow.StockLevelInIssueUnits = decimal.Parse(value); break;
                    case  34: productRow.LastReceivedPriceExVatPerPack = string.IsNullOrWhiteSpace(value) ? (decimal?)null : decimal.Parse(value); break;
                    case  35: productRow.ContractPrice          = string.IsNullOrWhiteSpace(value) ? (decimal?)null : decimal.Parse(value); break;
                    case  36: productRow.IfLiveStockControl     = BoolExtensions.PharmacyParseOrNull(value); break;
                    case  37: productRow.Location               = value; break;
                    case  38: productRow.StartOfPeriod          = DateTimeExtensions.PharmacyParse(value); break;
                    case  39: productRow.SafetyFactor           = double.Parse(value); break;
                    case  40: productRow.UsageDamping           = double.Parse(value); break;
                    case  41: productRow.UseThisPeriodInIssueUnits = double.Parse(value); break;
                    case  42: productRow.InUse                  = BoolExtensions.PharmacyParse(value); break;
                    case  43: productRow.mlsPerPack             = decimal.Parse(value); break;
                    case  44: productRow.ReCalculateAtPeriodEnd = BoolExtensions.PharmacyParseOrNull(value); break;
                    case  45: productRow.LossesGainExVat        = decimal.Parse(value); break;
                    case  46: productRow.OrderCycle             = value; break;
                    case  47: productRow.CycleLengthInDays      = int.Parse(value); break;
                    case  48: productRow.OutstandingInIssueUnits= double.Parse(value); break;
                    case  49: productRow.VATCode                = string.IsNullOrWhiteSpace(value) ? (int?)null : int.Parse(value); break;
                    case  50: productRow.DosingUnits            = value; break;
                    case  51: productRow.DosesPerIssueUnit      = string.IsNullOrWhiteSpace(value) ? (double?)null : double.Parse(value); break;
                    case  55: productRow.MessageCode            = value; break;
                    case  56: productRow.ReconstitutionVolumeInml  = string.IsNullOrWhiteSpace(value) ? (double?)null : double.Parse(value); break;
                    case  57: productRow.ReconstitutionAbbreviation= value; break;
                    case  58: productRow.FinalConcentrationInDoseUnitsPerml= string.IsNullOrWhiteSpace(value) ? (double?)null : double.Parse(value); break;
                    case  59: productRow.MaxConcentrationInDoseUnitsPerml= string.IsNullOrWhiteSpace(value) ? (double?)null : double.Parse(value); break;
                    case  60: productRow.MinConcentrationInDoseUnitsPerml= string.IsNullOrWhiteSpace(value) ? (double?)null : double.Parse(value); break;
                    case  61: productRow.DiluentAbbreviation1   = value; break;
                    case  62: productRow.DiluentAbbreviation2   = value; break;
                    case  63: productRow.IVContainer            = value; break;
                    case  64: productRow.DisplacementVolumeInml = string.IsNullOrWhiteSpace(value) ? (double?)null : double.Parse(value); break;
                    case  65: productRow.RawRow["InfusionTime"] = ConvertExtensions.ToMinutes(value) ?? 0; break;
                    case  66: productRow.RawRow["MaxInfusionRate"] = value; break;
                    case  67: productRow.PILnumber              = int.Parse(value); break;
                    case  68: productRow.WarningCode2           = value; break;
                    case  71: productRow.LastReconcilePriceExVatPerPack = string.IsNullOrWhiteSpace(value) ? (decimal?)null : decimal.Parse(value); break;
                    case  72: productRow.LocalProductCode       = value; break;
                    case  73: productRow.MinDailyDose           = string.IsNullOrWhiteSpace(value) ? (double?)null : double.Parse(value); break;
                    case  74: productRow.MaxDailyDose           = string.IsNullOrWhiteSpace(value) ? (double?)null : double.Parse(value); break;
                    case  75: productRow.MinDoseFrequency       = string.IsNullOrWhiteSpace(value) ? (double?)null : double.Parse(value); break;
                    case  76: productRow.MaxDoseFrequency       = string.IsNullOrWhiteSpace(value) ? (double?)null : double.Parse(value); break;
                    case  81: productRow.DPSForm                = value; break;
                    case  82: productRow.StoresDescription      = value; break;
                    case  83: productRow.RawRow["storespack"]   = value; break;
                    case  86: productRow.Location2              = value; break;
                    case  87: productRow.LastIssuedDate         = string.IsNullOrWhiteSpace(value) ? (DateTime?)null : DateTime.Parse(value); break;
                    case  88: productRow.LastOrderedDate        = string.IsNullOrWhiteSpace(value) ? (DateTime?)null : DateTime.Parse(value); break;
                    case  89: productRow.CreatedByUserInitials  = value; break;
                    case  90: productRow.CreatedOnTerminal      = value; break;
                    case  91: productRow.RawRow["createddate"]  = value; break;
                    case  92: productRow.RawRow["createdtime"]  = DateTime.Parse(value); break;
                    case  93: productRow.ModifiedByUserInitials = value; break;
                    case  94: productRow.ModifiedOnTerminal     = value; break;
                    case  95: productRow.RawRow["modifieddate"] = value; break;
                    case  96: productRow.RawRow["modifiedtime"] = value; break;
                    case  97: productRow.RawRow["batchtracking"]= value; break;
                    case  98: productRow.IsReconcileIfZeroPrice = BoolExtensions.PharmacyParse(value); break;
                    case  99: productRow.IssueWholePack         = BoolExtensions.PharmacyParseOrNull(value); break;
                    case 116: productRow.CMICode                = value; break;
                    case 118: productRow.PIPCode                = value; break;
                    case 119: productRow.MasterPIP              = value; break;
                    case 120: productRow.IsLabelInIssueUnits    = BoolExtensions.PharmacyParseOrNull(value); break;
                    case 121: productRow.CanUseSpoon            = BoolExtensions.PharmacyParseOrNull(value); break;
                    case 122: productRow.PhysicalDescription    = value; break;
                    case 123: productRow.RawRow["DDDValue"]     = value; break;
                    case 124: productRow.RawRow["DDDUnits"]     = value; break;
                    case 125: productRow.RawRow["UserField1"]   = value; break;
                    case 126: productRow.RawRow["UserField2"]   = value; break;
                    case 127: productRow.RawRow["UserField3"]   = value; break;
                    case 128: productRow.RawRow["HIProduct"]    = value; break;
                    case 129: productRow.EDILinkCode            = value; break;
                    case 130: productRow.PASANPCCode            = value; break;
                    case 131: productRow.PNExclude              = BoolExtensions.PharmacyParse(value); break;
                    case 134: productRow.EyeLabel               = BoolExtensions.PharmacyParse(value); break;
                    case 135: productRow.PSOLabel               = BoolExtensions.PharmacyParse(value); break;
                    case 136: productRow.ExpiryWarnDays         = string.IsNullOrWhiteSpace(value) ? (int?)null : int.Parse(value); break;
                    case 137: productRow.DMandDReference        = string.IsNullOrWhiteSpace(value) ? (long?)null: long.Parse(value); break;
                    case 138: productRow.LabelDescriptionInPatient =string.IsNullOrWhiteSpace(value)? null       : value; break; 
                    case 139: productRow.LabelDescriptionOutPatient=string.IsNullOrWhiteSpace(value)? null       : value; break;
                    case 140: productRow.LocalDescription=string.IsNullOrWhiteSpace(value)? null   : value; break;
                    }
                }
            }

            // Log warnings 19Feb15 XN 102114
            var validationWarnings = validation.Where(d => !d.error);
            if (validationWarnings.Any())
            {
                foreach (var warning in validationWarnings.GroupBy(d => d.siteID))
                {
                    WPharmacyLogRow logRow = Log.BeginRow(WPharmacyLogType.LabUtils, this.Products[0].NSVCode);
                    logRow.SiteID   = warning.Key;
                    logRow.DateTime = now;
                    Log.AppendLineDetail("WARNINGS");
                    warning.ToList().ForEach(d => Log.AppendLineDetail(d.message));
                    Log.EndRow();
                }
            }

            // Log changes that are part of SiteProductData (so not siteID) 18May15 XN 117528
            var siteProductDataIndexes = WConfiguration.Load(SessionInfo.SiteID, "D|STKMAINT", "AuditLog", "SiteProductDataIndexes", string.Empty, false).ParseCSV<int>(",", false);
            var differenceForSiteProductData = differences.Where(d => siteProductDataIndexes.Contains(d.dataIndex))
                                                          .GroupBy(d => d.dataIndex)
                                                          .ToList();
            if (differenceForSiteProductData.Any())
            {
                WPharmacyLogRow logRow = Log.BeginRow(WPharmacyLogType.LabUtils, this.Products[0].NSVCode);
                logRow.SiteID   = null;
                logRow.DateTime = now;
                differenceForSiteProductData.ForEach(d => Log.AppendLineDetail("{0}\t Was : '{1}' Now : '{2}'", d.Last().description, d.Last().was, d.Last().now));
                Log.AppendLineDetail("SAVE");
                Log.EndRow();
            }

            // Log changes that are not part of SiteProductData (so has siteID) 18May15 XN 117528
            var otherDifferences = differences.Where(d => !siteProductDataIndexes.Contains(d.dataIndex))
                                                          .GroupBy(d => d.siteID)
                                                          .ToList();
            if (otherDifferences.Any())
            {
                foreach (var diff in otherDifferences)
                {
                    WPharmacyLogRow logRow = Log.BeginRow(WPharmacyLogType.LabUtils, this.Products[0].NSVCode);
                    logRow.SiteID   = diff.Key;
                    logRow.DateTime = now;
                    diff.ToList().ForEach(d => Log.AppendLineDetail("{0}\t Was : '{1}' Now : '{2}'", d.description, d.was, d.now));
                    Log.AppendLineDetail("SAVE");
                    Log.EndRow();
                }
            }

            // Save
            if (saveToDB)
            {
                using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    //this.Products.Save(updateModifiedDate: true);  15Aug16 XN 108889 create interface file on save  
                    this.Products.Save(updateModifiedDate: true, createInterfaceFile: true);   
                    Log.Save();
                    trans.Commit();
                }
            }
        }

        /// <summary>Writes object data to XML writer</summary>
        public override void WriteXml(XmlWriter writer)
        {
            base.WriteXml(writer);
            this.Products.WriteXml(writer);
            this.Log.WriteXml(writer);
        }

        /// <summary>Reads object data from XML reader</summary>
        public override void ReadXml(XmlReader reader)
        {
            base.ReadXml(reader);
            this.Products = new WProduct();
            this.Products.ReadXml(reader);
            this.Log = new WPharmacyLog();
            this.Log.ReadXml(reader);
        }
                
        /// <summary>Called when QS data time button is clicked</summary>
        /// <param name="qsView">QueScrl controls</param>
        /// <param name="index">Index of the button clicked</param>
        /// <param name="siteID">site ID</param>
        override public void ButtonClickEvent(QSView qsView, int index, int siteID)
        { 
            switch (index)
            {
            case 132:   // Exchange primary and secondary locations
                QSDataInputItem qsLocation  = qsView.FindByDataIndex(DATAINDEX_LOCATION);
                QSDataInputItem qsLocation2 = qsView.FindByDataIndex(DATAINDEX_LOCATION2);
                if (qsLocation != null && qsLocation2 != null)
                {
                    string location  = qsLocation.GetValueBySiteID(siteID);
                    string location2 = qsLocation2.GetValueBySiteID(siteID);
                    
                    qsLocation.SetValueBySiteID (siteID, location2);
                    qsLocation2.SetValueBySiteID(siteID, location );
                }
                break;
            case 133:   // Abbreviation rule editor
                WebControl button = qsView.FindByDataIndex(index).GetBySiteID(siteID);
                string script = string.Format("var res=window.showModalDialog('AbbreviationRule.aspx?SessionID={0}&SiteID={1}', '', 'status:off; center:Yes;'); if (res == 'logoutFromActivityTimeout') {res = null; window.close(); window.parent.close();window.parent.ICWWindow().Exit();}", SessionInfo.SessionID, siteID); 
                script = "setTimeout(function() { " + script + "}, 200)";   // Use timer to allow form behind to size correct or goes bit funny 85845 XN 07Mar14 
                ScriptManager.RegisterStartupScript(button, button.GetType(), "ArbRules", script, true);
                break;
            }
        }
        #endregion

        #region IQSDisplayAccessor Members
        /// <summary>the main supported BaseRow type for the accessor (will be WProductRow)</summary>
        public Type SupportedType { get { return typeof(WProductRow); } }

        /// <summary>Tag name for the accessor (links to name in the DB)</summary>
        public string AccessorTag { get { return "Product"; } }

        /// <summary>Returns string suitable for display (on panels and grids) for selected value (propertyName)</summary>
        /// <param name="r">Base row should be of type (WProductRow)</param>
        /// <param name="dataType">Column QS data type</param>
        /// <param name="propertyName">Name of property to return the value for (or special tag name e.g. {description})</param>
        /// <param name="formatOption">Format option for the value</param>
        public string GetValueForDisplay(BaseRow r, int dataIndex, QSDataType dataType, string propertyName, string formatOption)
        {
            WProductRow row = (r as WProductRow);
            switch (propertyName.ToLower())
            {
            case "{description}"            : return row.ToString().XMLEscape();
            //case "reorderquantityinpacks"   : return row.RawRow["reorderqty"] == DBNull.Value ? string.Empty : row.ReOrderQuantityInPacks.ToString(ProductStock.GetColumnInfo().ReOrderQuantityInPacksLength);
            case "reorderquantityinpacks"   : // 20Jan17 XN  126634 - Added for configurable F4 supplier info panel
                if (row.RawRow["reorderqty"] == DBNull.Value)
                    return string.Empty;

                switch (formatOption.ToLower())
                {
                case "per pack with units": return string.Format("{0} x {1} {2}", row.ReOrderQuantityInPacks.ToString(WProduct.GetColumnInfo().ReOrderQuantityInPacksLength), row.ConversionFactorPackToIssueUnits, row.PrintformV);
                default:                    return row.ReOrderQuantityInPacks.ToString(ProductStock.GetColumnInfo().ReOrderQuantityInPacksLength);
                }
            case "safetyfactor"             : 
            case "usagedamping"             : 
            case "usethisperiodinissueunits": 
            case "mlsperpack"               : 
            case "outstandinginissueunits"  : 
            case "dosesperissueunit"        : 
            case "displacementvolumeinml"   : 
            case "infusiontime"             : 
            case "maxinfusionrate"          : 
            case "mindailydose"             : 
            case "maxdailydose"             : 
            case "mindosefrequency"         : 
            case "maxdosefrequency"         : 
                if (string.IsNullOrEmpty(formatOption)) 
                    formatOption = "0.####";
                break;
            case "reconstitutionvolumeinml"             : 
            case "finalconcentrationindoseunitsperml"   :
            case "maxconcentrationindoseunitsperml"     :
            case "minconcentrationindoseunitsperml"     :
                if (string.IsNullOrEmpty(formatOption)) 
                    formatOption = "0.#####";
                break;
            case "leadtimeindays":
                if (string.IsNullOrEmpty(formatOption)) 
                    formatOption = "0.#";
                break;
            case "averagecostexvatperpack":
                switch (formatOption.ToLower())
                {
                case "with pack size": return string.Format("{0} for 1 x {1} {2}", row.AverageCostExVatPerPack.ToMoneyString(this.moneyDisplayType), row.ConversionFactorPackToIssueUnits, row.PrintformV);
                default: return row.AverageCostExVatPerPack.ToMoneyString(this.moneyDisplayType);
                }
            case "conversionfactorpacktoissueunits":      
                switch (formatOption.ToLower())
                {
                case "with units": return row.ConversionFactorPackToIssueUnits + " " + row.PrintformV;  // 13Jul15 XN 39882 Added 
                default: return row.ConversionFactorPackToIssueUnits.ToString();
                }  
            case "stocklevelinissueunits":
                switch (formatOption.ToLower())
                {
                case "detailed":    // 13Jul15 XN 39882 Added
                    string storesPack = string.IsNullOrEmpty(row.StoresPack) ? "pack" : row.StoresPack.ToLower();
                    return string.Format("{0:0.##} {1} (or {2:0.##} {3})", row.StockLevelInIssueUnits, row.PrintformV, row.StockLevelInIssueUnits / row.ConversionFactorPackToIssueUnits, storesPack);
                default:
                    return row.StockLevelInIssueUnits.ToString("0.##");
                }
            case "minissueinissueunits":    // 20Jan17 XN 126634 - Added for configurable F4 supplier info panel
                switch (formatOption.ToLower())
                {
                case "with units": return string.Format("{0:0.####} {1}", row.MinIssueInIssueUnits, row.PrintformV);
                default: return string.Format("{0:0.####}", row.MinIssueInIssueUnits);
                }
            case "maxissueinissueunits":    // 20Jan17 XN 126634 - Added for configurable F4 supplier info panel
                switch (formatOption.ToLower())
                {
                case "with units": return string.Format("{0:0.####} {1}", row.MaxIssueInIssueUnits, row.PrintformV);
                default: return string.Format("{0:0.####}", row.MaxIssueInIssueUnits);
                }
            case "estimatedoutofstockdate": // 20Jan17 XN 126634 - Added for configurable F4 supplier info panel
                switch(formatOption.ToLower())
                {
                case "empty if less than lead time": 
                    if (row.EstimatedOutOfStockDate == null ||
                        ((decimal)(row.EstimatedOutOfStockDate.Value - DateTime.Now).TotalDays) <= (row.LeadTimeInDays ?? 0))
                        return string.Empty;
                    else
                        return row.EstimatedOutOfStockDate.ToPharmacyDateString();
                default:
                    return row.EstimatedOutOfStockDate.ToPharmacyDateString();                        
                }
            }            

            return QSHelper.PharmacyPropertyReader(row, dataType, propertyName, formatOption);
        }
        #endregion

        #region Helper Methods
        /// <summary>
        /// Validate that the product is not in any outstanding orders or reconcil's
        /// 30Jul15 XN 124545 made into a method so can be shared with WSupplierProfileQSProcessor
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="NSVCode">NSV code</param>
        /// <param name="supCode">supplier code</param>
        /// <param name="validationInfo">Validation list</param>
        public static void ValidateVATCode(int siteID, string NSVCode, string supCode, QSValidationList validationInfo)
        {
            // Check that there are no outstanding orders
            WOrder orders = new WOrder();
            string outstandingOrderStates = WConfiguration.Load(siteID, "D|STKMAINT", "Validation", "TaxOutstandingOrderStates", string.Empty, false);
            if (!string.IsNullOrEmpty(outstandingOrderStates))
            {
                orders.LoadBySiteIDNSVCodeSupCodeAndState(siteID, NSVCode, supCode, outstandingOrderStates.ToCharArray().Select(c => EnumDBCodeAttribute.DBCodeToEnum<OrderStatusType>(c.ToString())).ToArray());
            }

            // Check that there are no outstanding reconciliation
            WReconcil reconcil = new WReconcil();
            string reconcilOrderStates = WConfiguration.Load(siteID, "D|STKMAINT", "Validation", "TaxReconcilOrderStates", string.Empty, false);
            if (!string.IsNullOrEmpty(reconcilOrderStates))
            {
                reconcil.LoadBySiteIDNSVCodeSupCodeAndState(siteID, NSVCode, supCode, reconcilOrderStates.ToCharArray().Select(c => EnumDBCodeAttribute.DBCodeToEnum<OrderStatusType>(c.ToString())).ToArray());
            }

            // If any outstanding items the error
            if (orders.Any() || reconcil.Any())
            {
                validationInfo.AddError(siteID, "Tax: Can't change as outstanding orders/credit notes");
            }
        }
        #endregion
    }
}
