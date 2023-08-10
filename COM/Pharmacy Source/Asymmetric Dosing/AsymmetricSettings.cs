//===========================================================================
//
//					        AsymmetricSetting.cs
//
//  Class to access asymmetric settings from db
//
//	Modification History:
//	24Jul11 XN  Written
//  20Apr12 XN  TFS32378, TFS32370 Added settings PreventLinkIfStartAndEndTimesOverlap,
//              IncludeRxPatientReasonCheck, AllowMatchingRxReasons, 
//              AllowLinkingEmptyAndNonEmptyRxReasons
//  15Sep15 XN  129200 Added settings AllowLinkingIfProductFormDoesNotMatch, 
//              AllowLinkingEmptyAndNonEmptyProductForm, AllowLinkingInfusionPrescription
//===========================================================================
namespace ascribe.pharmacy.asymmetricdosing
{
using System.Linq;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.shared;

    /// <summary>asymmetric settings from db</summary>
    public static class AsymmetricSettings
    {
        /// <summary>Max number of allowed prescription in an asymmetric link</summary>
        public static int MaxLinkedItems { get { return SettingsController.LoadAndCache<int>("Pharmacy", "PrescriptionMerge", "MaxLinkedItems", 6); } }

        /// <summary>Max number of allowed scheduled slots in an asymmetric link</summary>
        public static int MaxScheduledSlots { get { return SettingsController.LoadAndCache<int>("Pharmacy", "PrescriptionMerge", "MaxScheduledSlots", 6); } }

        /// <summary>Allowed between prescription dosages, before warning is displayed</summary>
        public static int RangeWarningMultiplier { get { return SettingsController.LoadAndCache<int>("Pharmacy", "PrescriptionMerge", "RangeWarningMultiplier", 10); } }

        /// <summary>If to test prescription start and stop times overlap</summary>
        public static bool TestPrescriptionConsecutaiveStartStopDates { get { return SettingsController.LoadAndCache<bool>("Pharmacy", "PrescriptionMerge", "TestPrescriptionConsecutaiveStartStopDates", true); } }

        /// <summary>Prevent link if start and end times overlap (else allow link)</summary>
        public static bool PreventLinkIfStartAndEndTimesOverlap { get { return SettingsController.LoadAndCache<bool>("Pharmacy", "PrescriptionMerge", "PreventLinkIfStartAndEndTimesOverlap", false); } }

        /// <summary>If to include RxPatientReason in the RxReason checks</summary>
        public static bool IncludeRxPatientReasonCheck { get { return SettingsController.LoadAndCache<bool>("Pharmacy", "PrescriptionMerge", "IncludeRxPatientReasonCheck", false); } }
 
        /// <summary>If allowed to link prescriptions that have matching RxReasons (else prescriptions with RxReasons are instantly rejected)</summary>
        public static bool AllowMatchingRxReasons { get { return SettingsController.LoadAndCache<bool>("Pharmacy", "PrescriptionMerge", "AllowMatchingRxReasons", false); } }

        /// <summary>If allowed to link empty RxReasons with non empty RxReasons</summary>
        public static bool AllowLinkingEmptyAndNonEmptyRxReasons { get { return SettingsController.LoadAndCache<bool>("Pharmacy", "PrescriptionMerge", "AllowLinkingEmptyAndNonEmptyRxReasons", false); } }

        /// <summary>If allowed to link prescriptions if product forms do not match 15Sep15 XN 129200</summary>
        public static bool AllowLinkingIfProductFormDoesNotMatch { get { return SettingsController.LoadAndCache<bool>("Pharmacy", "PrescriptionMerge", "AllowLinkingIfProductFormDoesNotMatch", false); } }

        /// <summary>If allowed to link prescriptions if one item has an null product form and other does not 15Sep15 XN 129200</summary>
        public static bool AllowLinkingEmptyAndNonEmptyProductForm { get { return SettingsController.LoadAndCache<bool>("Pharmacy", "PrescriptionMerge", "AllowLinkingEmptyAndNonEmptyProductForm", false); } }

        /// <summary>If allowed to link infusion prescriptions 15Sep15 XN 129200</summary>
        public static bool AllowLinkingInfusionPrescription { get { return SettingsController.LoadAndCache<bool>("Pharmacy", "PrescriptionMerge", "AllowLinkingInfusionPrescription", true); } }

        /// <summary>Returns the allowed ProductRouteIDs for infusions 16Sep15 XN 129200</summary>
        public static int[] AllowedInfusionRoutes
        {
            get
            {
                const string cacheName = "AsymmetricSettings.AllowedInfusionRoutes";
                
                int[] routes = PharmacyDataCache.GetFromContext(cacheName) as int[];
                if (routes == null)
                {
                    // Read the name string
                    string routesString = SettingsController.Load<string>("Pharmacy", "PrescriptionMerge", "AllowedInfusionRoutes", string.Empty);

                    // Load the routes
                    ProductRoute productRoutes = new ProductRoute();
                    productRoutes.LoadAll();

                    // If all return all ProductRouteID else filter to ones for the setting
                    if ("All".EqualsNoCaseTrimEnd(routesString))
                    {
                        routes = productRoutes.Select(r => r.ProductRouteID).ToArray();
                    }
                    else
                    {
                        routes = routesString.Split(',').Select(r => productRoutes.FindByDescription(r.Trim())).Where(r => r != null).Select(r => r.ProductRouteID).ToArray();    
                    }
                    
                    PharmacyDataCache.SaveToContext(cacheName, routes);
                }

                return routes;
            } 
        } 
    }
}
