//===========================================================================
//
//							      PNSettings.cs
//
//  Provides access to PN WConfiguration settings. Once accessed he settings 
//  are cached per a web request.
//
//  Items uder PNSettings.Defaults will be access baded on AgeRangeType 
//  (adult, or paediatric), and regimen type (aqueous, lipid, mixed).
//
//	Modification History:
//	20Oct11 XN Written
//  10Sep14 XN 95618 Added setting PNSetting.ViewAndAdjust.SetRegimenNameToStandardRegimenName
//  18Mar15 XN PNSettings.Prescribing.DefaultSiteNumber made Obsolete
//  15Oct15 XN Added new setting D|PN.Worklist.AutoSelectPrescription 77977
//  21Oct15 XN Added new setting D|PN.PNSupplyRequest.NumberOfDaysRquired 77772 
//  26Oct15 XN Updates for HK multi site editor 106278 
//===========================================================================
using System.Linq;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using System.Collections.Generic;
using System;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    public enum AgeRangeType
    {
        Adult,
        Paediatric,
    }

    public static class PNSettings
    {
        /// <summary>Max number of products allowed in a regimen</summary>
        public const int MaxNumberOfProductsInRegimen = 18;

        /// <summary>Settings for product editor screen</summary>
        public static class PNProductEditor
        {
            /// <summary>
            /// Gets list of editabled fields in PN Product editor
            /// Category: D|PN
            /// Section: PNProductEditor
            /// Key: EditableFields
            /// </summary>
            public static HashSet<string> EditableFields
            {
                get
                {
                    string fields = WConfiguration.LoadAndCache<string>(SessionInfo.SiteID, "D|PN", "PNProductEditor", "EditableFields", string.Empty, false).ToLower();
                    return new HashSet<string>(fields.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries));
                }
            }

            /// <summary>
            /// If user is allowed the add new product in PN Product editor
            /// Category: D|PN
            /// Section: PNProductEditor
            /// Key: AllowAdding
            /// </summary>
            public static bool AllowAdding
            {
                get { return WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|PN", "PNProductEditor", "AllowAdding", false, false); }
            }
        }

        /// <summary>Settings for rules settings screen</summary>
        public static class RuleEditor
        {
            /// <summary>
            /// Gets list of editabled fields in PN Rule editor
            /// Category: D|PN
            /// Section: {rule type}RuleEditor
            /// Key: EditableFields
            /// </summary>
            public static HashSet<string> GetEditableFields(RuleType ruleType)
            {
                string fields = WConfiguration.LoadAndCache<string>(SessionInfo.SiteID, "D|PN", GetRuleTypeSectionString(ruleType) + "RuleEditor", "EditableFields", string.Empty, false).ToLower();
                return new HashSet<string>(fields.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries));
            }

            /// <summary>
            /// If user is allowed the add new rule in PN Rule editor
            /// Category: D|PN
            /// Section: {rule type}RuleEditor
            /// Key: AllowAdding
            /// </summary>
            public static bool GetAllowAdding(RuleType ruleType)
            {
                return WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|PN", GetRuleTypeSectionString(ruleType) + "RuleEditor", "AllowAdding", false, false);
            }

            /// <summary>Converts a rule type to the WConfiguration section prefix (yngredient, regimen)</summary>
            private static string GetRuleTypeSectionString(RuleType ruleType)
            {
                switch (ruleType)
                {
                case RuleType.IngredientByProduct:  return "Ingredient";
                case RuleType.PrescriptionProforma: return "Proforma";
                case RuleType.RegimenValidation:    return "Regimen";
                default: return string.Empty;
                }
            }
        }

        /// <summary>Settings for standard regimen screen</summary>
        public static class PNStandardRegimen
        {
            /// <summary>
            /// Gets list of editabled fields in PN Standard Regimen editor
            /// Category: D|PN
            /// Section: StandardRegimenEditor
            /// Key: EditableFields
            /// </summary>
            public static HashSet<string> EditableFields
            {
                get 
                {
                    string fields = WConfiguration.LoadAndCache<string>(SessionInfo.SiteID, "D|PN", "StandardRegimenEditor", "EditableFields", string.Empty, false).ToLower();
                    return new HashSet<string>(fields.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries));
                }
            }

            /// <summary>
            /// If user is allowed the add new rule in PN Standard Regimen editor
            /// Category: D|PN
            /// Section: StandardRegimenEditor
            /// Key: AllowAdding
            /// </summary>
            public static bool AllowAdding
            {
                get { return WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|PN", "StandardRegimenEditor", "AllowAdding", false, false); }
            }
        }

        /// <summary>Class containing all the defaults settings</summary>
        public static class Defaults
        {
            /// <summary>
            /// If separate amino and fat labels.
            /// Category: D|PN
            /// Section: {age range type}Default
            /// Key: SeparateAqueousAndLipidLabels
            /// </summary>
            public static bool GetSeparateAqueousAndLipidLabels(AgeRangeType ageRangeType, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                return WConfiguration.LoadAndCache<bool>(siteId ?? SessionInfo.SiteID, "D|PN", section, "SeparateAqueousAndLipidLabels", false, false);
            }
            public static void SetSeparateAqueousAndLipidLabels(AgeRangeType ageRangeType, bool value, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                WConfiguration.Save<bool>(siteId ?? SessionInfo.SiteID, "D|PN", section, "SeparateAqueousAndLipidLabels", value, false);
            }


            /// <summary>
            /// If to calculate drip rate in ml/hr.
            /// Category: D|PN
            /// Section: {age range type}Default
            /// Key: CalcDripRatemlPerHour
            /// </summary>
            public static bool GetCalcDripRatemlPerHour(AgeRangeType ageRangeType, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                return WConfiguration.LoadAndCache<bool>(siteId ?? SessionInfo.SiteID, "D|PN", section, "CalcDripRatemlPerHour", false, false);
            }
            public static void SetCalcDripRatemlPerHour(AgeRangeType ageRangeType, bool value, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                WConfiguration.Save<bool>(siteId ?? SessionInfo.SiteID, "D|PN", section, "CalcDripRatemlPerHour", value, false);
            }

            /// <summary>
            /// If Baxa interface is in use.
            /// Category: D|PN
            /// Section: {age range type}Default
            /// Key: BaxaCompounderInUse
            /// </summary>
            public static bool GetBaxaCompounderInUse(AgeRangeType ageRangeType, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                return WConfiguration.LoadAndCache<bool>(siteId ?? SessionInfo.SiteID, "D|PN", section, "BaxaCompounderInUse", false, false);
            }
            public static void SetBaxaCompounderInUse(AgeRangeType ageRangeType, bool value, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                WConfiguration.Save(siteId ?? SessionInfo.SiteID, "D|PN", section, "BaxaCompounderInUse", value, false);
            }

            /// <summary>
            /// If issuing is enabled.
            /// Category: D|PN
            /// Section: {age range type}Default
            /// Key: IssueEnabled
            /// </summary>
            public static bool GetIssueEnabled(AgeRangeType ageRangeType, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                return WConfiguration.LoadAndCache<bool>(siteId ?? SessionInfo.SiteID, "D|PN", section, "IssueEnabled", false, false);
            }
            public static void SetIssueEnabled(AgeRangeType ageRangeType, bool value, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                WConfiguration.Save(siteId ?? SessionInfo.SiteID, "D|PN", section, "IssueEnabled", value, false);
            }

            /// <summary>
            /// If returning is enabled.
            /// Category: D|PN
            /// Section: {age range type}Default
            /// Key: ReturnEnabled
            /// </summary>
            public static bool GetReturnEnabled(AgeRangeType ageRangeType, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                return WConfiguration.LoadAndCache<bool>(siteId ?? SessionInfo.SiteID, "D|PN", section, "ReturnEnabled", false, false);
            }
            public static void SetReturnEnabled(AgeRangeType ageRangeType, bool value, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                WConfiguration.Save(siteId ?? SessionInfo.SiteID, "D|PN", section, "ReturnEnabled", value, false);
            }

            /// <summary>
            /// Overage volume ml.
            /// Category: D|PN
            /// Section: {age range type}Default
            /// Key: {regimen type}OverageVolumeInml
            /// </summary>
            public static int GetOverageVolumeInml(AgeRangeType ageRangeType, PNProductType regimenType, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                string key     = GetRegimenTypeKeyString(regimenType)       + "OverageVolumeInml";
                return WConfiguration.LoadAndCache<int>(siteId ?? SessionInfo.SiteID, "D|PN", section, key, 0, false);
            }
            public static void SetOverageVolumeInml(AgeRangeType ageRangeType, PNProductType regimenType, int value, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                string key     = GetRegimenTypeKeyString(regimenType)       + "OverageVolumeInml";
                WConfiguration.Save(siteId ?? SessionInfo.SiteID, "D|PN", section, key, value, false);
            }

            /// <summary>
            /// Expiry in days.
            /// Category: D|PN
            /// Section: {age range type}Default
            /// Key: {regimen type}ExpiryInDays
            /// </summary>
            public static int GetExpiryInDays(AgeRangeType ageRangeType, PNProductType regimenType, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                string key     = GetRegimenTypeKeyString(regimenType)       + "ExpiryInDays";
                return WConfiguration.LoadAndCache<int>(siteId ?? SessionInfo.SiteID, "D|PN", section, key, 4, false);
            }
            public static void SetExpiryInDays(AgeRangeType ageRangeType, PNProductType regimenType, int value, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                string key     = GetRegimenTypeKeyString(regimenType)       + "ExpiryInDays";
                WConfiguration.Save(siteId ?? SessionInfo.SiteID, "D|PN", section, key, value, false);
            }

            /// <summary>
            /// Number of labels.
            /// Category: D|PN
            /// Section: {age range type}Default
            /// Key: {regimen type}NumberOfLabels
            /// </summary>
            public static int GetNumberOfLabels(AgeRangeType ageRangeType, PNProductType regimenType, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                string key     = GetRegimenTypeKeyString(regimenType)       + "NumberOfLabels";
                return WConfiguration.LoadAndCache<int>(siteId ?? SessionInfo.SiteID, "D|PN", section, key, 2, false);
            }
            public static void SetNumberOfLabels(AgeRangeType ageRangeType, PNProductType regimenType, int value, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                string key     = GetRegimenTypeKeyString(regimenType)       + "NumberOfLabels";
                WConfiguration.Save(siteId ?? SessionInfo.SiteID, "D|PN", section, key, value, false);
            }

            /// <summary>
            /// Number of labels.
            /// Category: D|PN
            /// Section: {age range type}Default
            /// Key: {regimen type}InfusionDurationInHours
            /// </summary>
            public static int GetInfusionDurationInHours(AgeRangeType ageRangeType, PNProductType regimenType, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                string key     = GetRegimenTypeKeyString(regimenType)       + "InfusionDurationInHours";
                return WConfiguration.LoadAndCache<int>(siteId ?? SessionInfo.SiteID, "D|PN", section, key, 24, false);
            }
            public static void SetInfusionDurationInHours(AgeRangeType ageRangeType, PNProductType regimenType, int value, int? siteId = null)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "Default";
                string key     = GetRegimenTypeKeyString(regimenType)       + "InfusionDurationInHours";
                WConfiguration.Save(siteId ?? SessionInfo.SiteID, "D|PN", section, key, value, false);
            }
        }

        public static class ViewAndAdjust
        {
            /// <summary>
            /// If to adjust sodium level back to original value
            /// Category: D|PN
            /// Section: {age range type}General
            /// Key: AdjustNa
            /// </summary>
            public static bool GetAdjustNa(AgeRangeType ageRangeType)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "ViewAndAdjust";
                return WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|PN", section, "AdjustNa", (ageRangeType == AgeRangeType.Paediatric), false);
            }
            public static void SetAdjustNa(AgeRangeType ageRangeType, bool value)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "ViewAndAdjust";
                WConfiguration.Save(SessionInfo.SiteID, "D|PN", section, "AdjustNa", value, false);
            }

            /// <summary>
            /// If to adjust potassium level back to original value
            /// Category: D|PN
            /// Section: {age range type}General
            /// Key: AdjustK
            /// </summary>
            public static bool GetAdjustK(AgeRangeType ageRangeType)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "ViewAndAdjust";
                return WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|PN", section, "AdjustK", (ageRangeType == AgeRangeType.Paediatric), false);
            }
            public static void SetAdjustK(AgeRangeType ageRangeType, bool value)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "ViewAndAdjust";
                WConfiguration.Save(SessionInfo.SiteID, "D|PN", section, "AdjustK", value, false);
            }

            /// <summary>If new (non standard) regimen should be auto populated</summary>
            public static bool GetAutoPopulateNewRegimen(AgeRangeType ageRangeType)
            {
                string section = GetAgeRangeTypeSectionString(ageRangeType) + "ViewAndAdjust";
                return WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|PN", section, "AutoPopulateNewRegimen", true, false);
            }

            /// <summary>If rows should be keep on the blackboard after authorisation (default is to remove)</summary>
            public static bool GetKeepRowsOnBlackboard()
            {
                return WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|PN", "ViewAndAdjust", "KeepRowsOnBlackboard", false, false);
            }

            /// <summary>If when standard regimen selected replace the regimen name with the standard 10Sep14 XN 95618</summary>
            public static bool SetRegimenNameToStandardRegimenName
            {
                get { return WConfiguration.Load<bool>(SessionInfo.SiteID,  "D|PN", "ViewAndAdjust", "SetRegimenNameToStandardRegimenName", true, false); }
            }

            /// <summary>If when regimen name is created it uses the full dosing weight 18Sep14 XN 30679</summary>
            public static bool SetRegimenNameToFullDosingWeightText
            {
                get { return WConfiguration.Load<bool>(SessionInfo.SiteID,  "D|PN", "ViewAndAdjust", "SetRegimenNameToFullDosingWeightText", false, false); }
            }
        }

        /// <summary>Class containing default settings for a worklist</summary>
        public static class Worklist
        {
            /// <summary>
            /// If true and there is an entry in SessionAttribute where Attribute=OrderEntry/OrdersXML and xml contains a PN request id
            /// then when the worklist is first open the request will be selected by default
            /// Category: D|PN
            /// Section:  Worklist
            /// Key:      AutoSelectPrescription
            /// 15Oct15 XN 77977
            /// </summary>
            public static bool AutoSelectPrescription
            {
                get { return WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|PN", "Worklist", "AutoSelectPrescription", false, false); }
            }

            /// <summary>
            /// If site is allowed to copy a prescription (for HK)
            /// Category: D|PN
            /// Section:  Worklist
            /// Key:      AllowCopyPrescription
            /// 20Pct15 XN
            /// </summary>
            public static bool AllowCopyPrescription
            {
                get { return WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|PN", "Worklist", "AllowCopyPrescription", true, false); }
            }
        }

        public static class Constants
        {
            /// <summary>
            /// Return number of kcal per gram of glucose (default 4kcal/gram)
            /// Category: D|PN
            /// Section: Constants
            /// Key: kcalPerGramGlucose
            /// </summary>
            public static double GetkcalPerGramGlucose()
            {
                return WConfiguration.LoadAndCache<double>(SessionInfo.SiteID, "D|PN", "Constants", "kcalPerGramGlucose", 4, false);
            }

            /// <summary>
            /// Return number of kcal per gram of fat (default 10kcal/gram)
            /// Category: D|PN
            /// Section: Constants
            /// Key: kcalPerGramFat
            /// </summary>
            public static double GetkcalPerGramFat()
            {
                return WConfiguration.LoadAndCache<double>(SessionInfo.SiteID, "D|PN", "Constants", "kcalPerGramFat", 10, false);
            }
        }

        public static class PrintSetting
        {
            /// <summary>
            /// Return if printed surname forename, or forename surname (only affects patname21 element)
            /// Category: D|PN
            /// Section: PrintSetting
            /// Key: SurnameForename
            /// </summary>
            public static bool GetSurnameForname()
            {
                return WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|PN", "PrintSetting", "SurnameForename", false, false);
            }

            /// <summary>
            /// Return if print name with or without commas (only affects patname21 element)
            /// Category: D|PN
            /// Section: PrintSetting
            /// Key: CommaSeparatedName
            /// </summary>
            public static bool GetCommaSeparatedName()
            {
                return WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|PN", "PrintSetting", "CommaSeparatedName", true, false);
            }
        }

        public static class Prescribing
        {
            // 18Mar15 XN made Obsolete
            [Obsolete("Used in prescribing but not in pharmacy")]
            public static int? DefaultSiteNumber { get { return SettingsController.LoadAndCache<int?>("PN", "Prescribing", "DefaultSiteNumber", null); } }
        
            /// <summary>If system allows 48 Hours bags</summary>
            public static bool Allow48HourBags()
            {
                return SettingsController.LoadAndCache<bool>("PN", "Prescribing", "Allow48Hours", true);
            }
        }

        public static class WeightAge
        {
            /// <summary>
            /// Gets weight range for particular age, there can be any number of these
            /// Each line should be as follows
            ///     Age,{WeighttFemaleLow},{WeighttFemaleHigh},{WeighttMaleLow},{WeighttMaleHigh},{WeighttUnknownLow},{WeighttUnknownHigh}
            /// Will filter the list of the gender, and orders by age
            /// Category: D|PN
            /// Section:  WeightAge
            /// Key:      {number}
            /// </summary>
            public static List<WeightAgeInfo> GetWeightAge(GenderType gender)
            {
                IDictionary<string,string> lines = WConfigurationController.LoadByCategoryAndSection(SessionInfo.SiteID, "D|PN", "WeightAge", false);
                List<WeightAgeInfo> weightAge = new List<WeightAgeInfo>();

                foreach (string line in lines.Values)
                {
                    string[] items = line.Split(new char[] {','}, StringSplitOptions.RemoveEmptyEntries);
                    if (items.Count() != 7)
                        continue;

                    int age;
                    if (!int.TryParse(items[0].Trim(), out age))
                        continue;

                    WeightAgeInfo info = new WeightAgeInfo();

                    info.age = age;

                    switch (gender)
                    {
                    case GenderType.Female:
                        if (!double.TryParse(items[1].Trim(), out info.WeightLow))
                            continue;
                        if (!double.TryParse(items[2].Trim(), out info.WeightHeight))
                            continue;
                        break;

                    case GenderType.Male:
                        if (!double.TryParse(items[3].Trim(), out info.WeightLow))
                            continue;
                        if (!double.TryParse(items[4].Trim(), out info.WeightHeight))
                            continue;
                        break;

                    default:
                        if (!double.TryParse(items[5].Trim(), out info.WeightLow))
                            continue;
                        if (!double.TryParse(items[6].Trim(), out info.WeightHeight))
                            continue;
                        break;
                    }

                    weightAge.Add(info);
                }

                return weightAge.OrderBy(i => i.age).ToList();
            }
        }

        /// <summary>Class for PNSupplyRequest settings</summary>
        public static class PNSupplyRequest
        {
            /// <summary>Gets the setting for the number of days required D|PN.PNSupplyRequest.NumberOfDaysRequired 21Oct15 77772 XN</summary>
            public static string NumberOfDaysRequired { get { return WConfiguration.Load<string>(SessionInfo.SiteID, "D|PN", "PNSupplyRequest", "NumberOfDaysRequired", string.Empty, false); } }
        }

        /// <summary>Converts an age range type to the WConfiguration, section prefix (Adult, or Paed)</summary>
        private static string GetAgeRangeTypeSectionString(AgeRangeType ageRangeType)
        {
            switch (ageRangeType)
            {
            case AgeRangeType.Adult:      return "Adult";
            case AgeRangeType.Paediatric: return "Paed";
            default: return string.Empty;
            }
        }

        /// <summary>Converts a PNProdctType to a WConfiguration, key prefix (Aqueous, Lipid, or Mixed)</summary>
        private static string GetRegimenTypeKeyString(PNProductType regimenType)
        {
            switch (regimenType)
            {
            case PNProductType.Aqueous: return "Aqueous";
            case PNProductType.Lipid:   return "Lipid";
            case PNProductType.Combined:   return "Combined";
            default: return string.Empty;
            }
        }
    }
}
