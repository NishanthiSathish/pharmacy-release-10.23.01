//===========================================================================
//
//						      ContractEditorSettings.cs
//
//  holds settings for the contract editor, and CMU contract editor.
//
//	Modification History:
//	02Aug13 XN  Written
//  08Jun15 XN  119361 Moved SiteValid, SiteInfo, and DetermineIfSiteValidForReplication to ContractProcessor
//              Setting Pharmacy.ContractEditor.SitesAllowedForReplciation and Pharmacy.ContractEditor.SiteNumbersSelectedByDefault 
//              are now desktop parameters
//  25Jul16 XN  126634 Added SelectEdiBarcodeByDefault
//===========================================================================
using ascribe.pharmacy.shared;

/// <summary>Settings for CMU contract editor</summary>
public static class ContractEditorSettings
{
    public static class ContractEditor
    {
        /// <summary>
        /// Returns if GTIN is selected by default
        /// System: Pharmacy
        /// Section: ContractEditor
        /// Key: SelectGTINByDefault
        /// </summary>
        public static bool SelectGTINByDefault
        {
            get { return SettingsController.Load("Pharmacy", "ContractEditor", "SelectGTINByDefault", true); }
        }

        /// <summary>
        /// Returns if 'Use GTIN code for EDI link' is selected by default
        /// System: Pharmacy
        /// Section: ContractEditor
        /// Key: SelectEdiBarcodeByDefault
        /// 25Jul16 XN  126634
        /// </summary>
        public static bool SelectEdiBarcodeByDefault
        {
            get { return SettingsController.Load("Pharmacy", "ContractEditor", "SelectEdiBarcodeByDefault", false); }
        }

        /// <summary>
        /// Returns if Contract Import is allowed 
        /// System: Pharmacy
        /// Section: ContractEditor
        /// Key: ContractImport
        /// </summary>
        public static bool ContractImport
        {
            get { return SettingsController.Load<bool>("Pharmacy", "ContractEditor", "ContractImport", false); }
        }
    }
}
