// -----------------------------------------------------------------------
// <copyright file="ManufacturingSettings.cs" company="Emis Health">
//      Emis Health Ltd  
// </copyright>
// <summary>
// PatMed.Manufacturing and aMM Settings from WConfiguration
//
// Modification History:
// 17Jun15 XN Created 39882
// 15Aug16 XN 159843 Made AlwaysAskExpiryDate, and AlwaysAskBatchTracking null able
//            Added aMMSetting.Worklist.DateRangeInDays
// 15Aug16 KR 160312. Made CaptureManufacturedImage setting terminal specific
// 19Aug16 XN 160567 Added IsExpiryDateFromShiftStartDate
// 25Aug16 XN 161234 Added IfReadyToLabel and MethodRtfFile
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.manufacturinglayer
{
    using ascribe.pharmacy.pharmacydatalayer;
    using ascribe.pharmacy.shared;
    using System.Collections.Generic;
    using System.Linq;
    using System.IO;

    /// <summary>Type of second check to perform</summary>
    public enum aMMSecondCheckType
    {
        /// <summary>No second check</summary>
        None,

        /// <summary>Just single check</summary>
        [EnumDBCode("S")]
        SingleCheck,
        
        /// <summary>User confirms individual items</summary>
        [EnumDBCode("I")]
        IndividualCheck,

        /// <summary>Standard button for single check single user</summary>
        [EnumDBCode("SS")]
        SingleCheckSingleUser,

        /// <summary>Standard button for single check single user</summary>
        [EnumDBCode("IS")]
        IndividualCheckSingleUser
    }

    /// <summary>Type of process used for the final check</summary>
    public enum aMMFinalCheckType
    {
        /// <summary>No final check</summary>
        [EnumDBCode("")]
        None,

        /// <summary>Button user can confirm</summary>
        [EnumDBCode("B")]
        Button,

        /// <summary>Another user has to logon to confirm</summary>
        [EnumDBCode("S")]
        SecondCheck
    }

    /// <summary>Access to D|PatMed settings 14Apr16 XN 123082</summary>
    public static class PatMedSetting
    {
        /// <summary>Access to D|PatMed.Manufacturing settings 14Apr16 XN 123082</summary>
        public static class Manufacturing
        {
            /// <summary>Gets the cost center used for the Bond store</summary>
            /// <param name="siteId">Site id (else will use the current site)</param>
            /// <returns>Cost center used for bond store</returns>
            public static string BondCostCenter(int? siteId = null) { return WConfiguration.LoadAndCache(siteId ?? SessionInfo.SiteID, "D|PatMed", "Manufacturing", "BONDCostCentre",           "BOND", false); }

            /// <summary>Gets the cost center used for QA</summary>
            /// <param name="siteId">Site id (else will use the current site)</param>
            /// <returns>Cost center used for QA</returns>
            public static string QACostCenter(int? siteId = null)           { return WConfiguration.LoadAndCache(siteId ?? SessionInfo.SiteID, "D|PatMed", "Manufacturing", "QACostCentre",             "QA",   false); }

            /// <summary>Gets the cost center used for manufacturing</summary>
            /// <param name="siteId">Site id (else will use the current site)</param>
            /// <returns>Cost center used for manufacturing</returns>
            public static string CostCenter(int? siteId = null)             { return WConfiguration.LoadAndCache(siteId ?? SessionInfo.SiteID, "D|PatMed", "Manufacturing", "CostCentre",               "MANU", false); }
        }
    }

    /// <summary>aMM settings</summary>
    public static class aMMSetting
    {
        /// <summary>Settings for new drug wizard</summary>
        public static class NewDrugWizard
        {
            /// <summary>Gets the default volume type for the new drug wizard</summary>
            public static aMMVolumeType DefaultVolumeType { get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "NewDrugWizard", "DefaultVolumeType", aMMVolumeType.Fixed, false); } }

            /// <summary>Gets the max % of volume for the new drug wizard</summary>
            public static double MaxPercentageOfVolume { get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "NewDrugWizard", "MaxPercentageOfVolume", 10.0d, false); } }

            /// <summary>Gets the default number of doses</summary>
            public static string DefaultNumberOfDoses { get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "NewDrugWizard", "DefaultNumberOfDoses", "1", false); } }

            /// <summary>Gets the default syringe fill volume</summary>
            public static aMMSyringeFillType DefaultSyringeFillType { get { return EnumDBCodeAttribute.DBCodeToEnum<aMMSyringeFillType>(WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "NewDrugWizard", "DefaultSyringeFillType", "E", false)); } }
        
            /// <summary>Gets max number of syringes allowed</summary>
            public static int MaxNumberOfSyringes { get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "NewDrugWizard", "MaxNumberOfSyringes", 6, false); } }
        }

        /// <summary>Setting for the ingredient wizard</summary>
        public static class IngredientWizard
        {
            /// <summary>If should always ask for drug expiry date in ingredient wizard</summary>
            public static bool? AlwaysAskExpiryDate { get { return BoolExtensions.PharmacyParseOrNull(WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "IngredientWizard", "AlwaysAskExpiryDate", string.Empty, false)); } }
            //public static bool AlwaysAskExpiryDate { get { return  WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "IngredientWizard", "AlwaysAskExpiryDate", false, false); } } 159843 15Aug16 XN

            /// <summary>If should always ask for drug batch details in ingredient wizard</summary>
            public static bool? AlwaysAskBatchTracking { get { return BoolExtensions.PharmacyParseOrNull(WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "IngredientWizard", "AlwaysAskBatchTracking", string.Empty, false)); } }
            //public static bool AlwaysAskBatchTracking { get { return  WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "IngredientWizard", "AlwaysAskBatchTracking", false, false); } } 159843 15Aug16 XN

            /// <summary>If should only warn if there is an error with the barcode in ingredient wizard</summary>
            public static bool WarnBarcodeError { get { return  WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "IngredientWizard", "WarnBarcodeError", true, false); } }

            /// <summary>If should only warn if there is an error with the batch number in ingredient wizard</summary>
            public static bool WarnBatchNumber { get { return  WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "IngredientWizard", "WarnBatchNumber", true, false); } }

            /// <summary>If should only warn if there is an error with the expiry in ingredient wizard</summary>
            public static bool WarnExpiry { get { return  WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "IngredientWizard", "WarnExpiry", true, false); } }
        }

        /// <summary>Settings for shifts</summary>
        public static class Shifts
        {
            /// <summary>Gets or sets percentage of shifts total capacity that is considered to be near capacity</summary>
            public static double NearCapacityAsPercentatge { get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "Shifts", "NearCapacityAsPercentatge", 80.0, false); } }
        }
        
        /// <summary>Settings for the main worklist 159843 15Aug16 XN</summary>
        public static class Worklist
        {
            /// <summary>Date range in days</summary>
            public static int DateRangeInDays
            {
                get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", "Worklist", "DateRangeInDays", 7, false); } 
            }
        }

        /// <summary>Gets a value indicating whether supply request require a production tray</summary>
        public static bool IfRequiresProductionTray { get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", string.Empty, "IfRequiresProductionTray", true, false); } }

        /// <summary>Gets type of second check to perform</summary>
        public static aMMSecondCheckType SecondCheck { get { return EnumDBCodeAttribute.DBCodeToEnum<aMMSecondCheckType>(WConfiguration.Load(SessionInfo.SiteID, "D|AMM", string.Empty, "SecondCheck", "S", false)); } }
		
        /// <summary>If user is allowed to do the checking themselves</summary>
		public static bool AllowSelfChecking { get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", string.Empty, "AllowSelfChecking", false, false); } }

        /// <summary>Gets the type of the final check</summary>
        public static aMMFinalCheckType FinalCheck { get { return EnumDBCodeAttribute.DBCodeToEnum<aMMFinalCheckType>(WConfiguration.Load(SessionInfo.SiteID, "D|AMM", string.Empty, "FinalCheck", "S", false)); } }

        /// <summary>
        /// Gets a value indicating whether site uses a bond store
        /// Don't call directly use aMMProcessor.IfBondStore instead
        /// </summary>
        internal static bool IfBondStore { get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", string.Empty, "IfBondStoreStage", true, false); } }

        /// <summary>Gets stage at which production tray is released</summary>
        public static aMMState ProductionTrayReleasedAfterStage { get { return (aMMState)WConfiguration.Load(SessionInfo.SiteID, "D|AMM", string.Empty, "ProductionTrayReleasedAfterStage", (int)aMMState.ReadyToRelease, false); } }

        /// <summary>If checking if product tray barcode is actual in use by a product</summary>
        public static bool ValidateTrayAgainstProductBarcode { get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", string.Empty, "ValidateTrayAgainstProductBarcode", true, false); } }

        /// <summary>Gets a value indicating whether site has a ready to Label stage 25Aug16 XN 161234 </summary>
        public static bool IfReadyToLabel { get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", string.Empty, "IfReadyToLabel", true, false); } }

        /// <summary>Gets a value indicating whether site has a ready to release stage</summary>
        public static bool IfReadyToRelease { get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", string.Empty, "IfReadyToRelease", true, false); } }

        /// <summary>Gets a value indicating whether supply request form will auto close when reaches the last stage in any desktop</summary>
        public static bool AutoCloseWhenLastDesktopStage { get { return WConfiguration.Load(SessionInfo.SiteID, "D|AMM", string.Empty, "AutoCloseWhenLastDesktopStage", true, false); } }

        /// <summary>Gets a value indicating whether a image of the compounded product can be captured</summary>
        public static bool CaptureManufacturedImage
        {
            get
            {
                // Check if image capture is set for individual terminal. If not use default value.
                if(WConfiguration.Load<string>(SessionInfo.SiteID, "D|TERMINAL", SessionInfo.Terminal,"CaptureManufacturedImage", null,false) != null)
                {
                    return WConfiguration.Load(SessionInfo.SiteID, "D|TERMINAL", SessionInfo.Terminal, "CaptureManufacturedImage", false, false); 
                }
                else
                {
                    return WConfiguration.Load(SessionInfo.SiteID, "D|TERMINAL", "Default", "CaptureManufacturedImage", false, false);     
                }
            }
        }

        /// <summary>If the drug expiry time is calculated from the start of the shift or from the compound data time</summary>
        public static bool IsExpiryDateFromShiftStartDate { get { return WConfiguration.LoadAndCache(SessionInfo.SiteID, "D|AMM", string.Empty, "ExpiryDateFromShiftStartDate", true, false); } }

        /// <summary>Stages at which the user is allowed to print a worksheet</summary>
        public static IEnumerable<aMMState> StagesAllowedToPrintWorksheet 
        { 
            get 
            { 
                string stages = WConfiguration.Load(SessionInfo.SiteID, "D|AMM", string.Empty, "StagesAllowedToPrintWorksheet", string.Empty, false);
                return stages.ToCharArray().Select(c => (aMMState)int.Parse(c.ToString()));
            } 
        }

        /// <summary>RTF method file to display (with path) 25Aug16 XN 161234 </summary>
        public static string MethodRtfFile 
        { 
            get 
            { 
                string filename = WConfiguration.Load(SessionInfo.SiteID, "D|AMM", string.Empty, "MethodRtfFile", "aMMMethod.rtf", false);
                if (!string.IsNullOrEmpty(filename))
                    filename = Path.Combine(SiteInfo.DispdataDRV(), "WKSHEETS", filename);
                return filename;
            }
        }

        /// <summary>Returns the correct name for the state (read from D|AMM..AMMSupplyRequestState({state index})</summary>
        /// <param name="state">The state</param>
        /// <returns>State name</returns>
        public static string StateString(aMMState state)
        {
            string key = "AMMSupplyRequestState(" + (int)state + ")";
            return WConfiguration.LoadAndCache(SessionInfo.SiteID, "D|AMM", string.Empty, key, state.ToString(), false);
        }

        /// <summary>Returns the correct name for the issue state (read from D|AMM..AMMSupplyRequestIssueState({state index})</summary>
        /// <param name="state">The state</param>
        /// <returns>State name</returns>
        public static string IssueStateString(aMMIssueState state)
        {
            string key = "AMMSupplyRequestIssueState(" + (int)state + ")";
            return WConfiguration.LoadAndCache(SessionInfo.SiteID, "D|AMM", string.Empty, key, state.ToString(), false);
        }
    }
}
