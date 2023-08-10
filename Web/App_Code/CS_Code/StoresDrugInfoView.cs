//===========================================================================
//
//						        StoresDrugInfoView.cs
//
//  holds settings and configuration values for the pharmacy stores drug info
//  view (F4 screen).
//
//  These seetings include the
//  Limit to display history for orders, requisitions, and summary information tabs
//  Sort order settings for orders, and requisitions.
//
//  Usage:
//  To get limit to display for orders pending.
//  StoresDrugInfoViewSetting.LimitToDisplayOrdersPendingInDays
//  
//  To get from date to display for orders pending
//  StoresDrugInfoViewSetting.LimitToDisplayOrdersPendingFromDate
//
//  To get sort order for display of orders pending
//  StoresDrugInfoViewSetting.OrderSort
//  
//	Modification History:
//	23Jul09 XN  Written
//  11Jan13 XN  Removed inner class Setting, and just placed properties in outer class
//              Removed SettingAttr, and WConfigurationAttr, method of loading 
//              settings, now just using Load, or LoadAndCache.
//              Added Configuration stetting DisplayFormularyAsLetterOnly (38049)
//===========================================================================
using System;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;

/// <summary>
/// Summary description for StoresDrugInfoView
/// </summary>
public static class StoresDrugInfoViewSetting
{
    /// <summary>Limit to display pending orders (orders tab) in days (LimitToDisplayOrdersPending setting)</summary>
    public static int LimitToDisplayOrdersPendingInDays { get { return SettingsController.LoadAndCache<int>("Pharmacy", "Stores", "LimitToDisplayOrdersPending", 0); } } 

    /// <summary>If there is a limit to display pending orders (LimitToDisplayOrdersPending setting)</summary>
    public static bool HasLimitToDisplayOrdersPending { get { return (LimitToDisplayOrdersPendingInDays > 0); } }

    /// <summary>From date to display pending orders (LimitToDisplayOrdersPending setting)</summary>
    public static DateTime? LimitToDisplayOrdersPendingFromDate 
    { 
        get 
        { 
            if (HasLimitToDisplayOrdersPending)
                return DateTime.Now.Date.AddDays(-LimitToDisplayOrdersPendingInDays);
            else
                return null;
        }
    }

    /// <summary>Limit to display received orders (orders tab) in days (LimitToDisplayOrdersReceived setting)</summary>
    public static int LimitToDisplayOrdersReceivedInDays { get; private set; }

    /// <summary>If there is a limit to display received orders (LimitToDisplayOrdersReceived setting)</summary>
    public static bool HasLimitToDisplayOrdersReceived { get { return (LimitToDisplayOrdersReceivedInDays > 0); } }

    /// <summary>From date to display received orders (LimitToDisplayOrdersReceived setting)</summary>
    public static DateTime? LimitToDisplayOrdersReceivedFromDate 
    { 
        get 
        { 
            if (HasLimitToDisplayOrdersReceived)
                return DateTime.Now.Date.AddDays(-LimitToDisplayOrdersReceivedInDays);
            else
                return null;
        }
    }

    /// <summary>Limit to display requisition due out (requisition tab) in days (LimitToDisplayRequisitionsDueOut setting)</summary>
    public static int LimitToDisplayRequisitionsDueOutInDays { get { return SettingsController.LoadAndCache<int>("Pharmacy", "Stores", "LimitToDisplayRequisitionsDueOut", 0); } } 

    /// <summary>If there is a limit to display requisition due out (LimitToDisplayRequisitionsDueOut setting)</summary>
    public static bool HasLimitToDisplayRequisitionsDueOut { get { return (LimitToDisplayRequisitionsDueOutInDays > 0); } }

    /// <summary>From date to display requisition due out (LimitToDisplayRequisitionsDueOut setting)</summary>
    public static DateTime? LimitToDisplayRequisitionsDueOutFromDate 
    { 
        get 
        { 
            if (HasLimitToDisplayRequisitionsDueOut)
                return DateTime.Now.Date.AddDays(-LimitToDisplayRequisitionsDueOutInDays);
            else
                return null;
        }
    }

    /// <summary>Limit to display requisition issued (requisition tab) in days (LimitToDisplayRequisitionsIssued setting)</summary>
    public static int LimitToDisplayRequisitionsIssuedInDays { get { return SettingsController.LoadAndCache<int>("Pharmacy", "Stores", "LimitToDisplayRequisitionsIssued", 0); } } 

    /// <summary>If there is a limit to display requisition issued (LimitToDisplayRequisitionsIssued setting)</summary>
    public static bool HasLimitToDisplayRequisitionsIssued { get { return (LimitToDisplayRequisitionsIssuedInDays > 0); } }

    /// <summary>From date to display requisition issued (LimitToDisplayRequisitionsIssued setting)</summary>
    public static DateTime? LimitToDisplayRequisitionsIssuedFromDate 
    { 
        get 
        { 
            if (HasLimitToDisplayRequisitionsIssued)
                return DateTime.Now.Date.AddDays(-LimitToDisplayRequisitionsIssuedInDays);
            else
                return null;
        }
    }

    /// <summary>Limit to display summary information (summary information tab) in months (LimitToDisplaySummaryInformation setting)</summary>
    public static uint LimitToDisplaySummaryInformation { get { return SettingsController.LoadAndCache<uint>("Pharmacy", "Stores", "LimitToDisplaySummaryInformation", 12u); } } 

    /// <summary>
    /// From date to display summary information (LimitToDisplaySummaryInformation setting)
    /// Will always be from the first of the month
    /// </summary>
    public static DateTime LimitToDisplaySummaryInformationFromDate 
    { 
        get 
        {
            // Calculate the limit date
            DateTime limitDate = DateTime.Now.AddMonths ( -(int)LimitToDisplaySummaryInformation );

            // truncate the days off the limit date, so it will always before from the start of the month.
            return new DateTime ( limitDate.Year, limitDate.Month, 1 );
        }
    }

    /// <summary>Sort order for the pending orders tab (from configuration setting WOrderSort)</summary>
    public static string OrderSort { get { return WConfiguration.Load<string>(SessionInfo.SiteID, "D|WINORD", "ItemEnquiry", "WOrderSort", "NRecdate Desc", false);  } }

    /// <summary>Sort order for the received orders tab (from configuration setting WReconcilSort)</summary>
    public static string ReconcilSort { get { return WConfiguration.Load<string>(SessionInfo.SiteID, "D|WINORD", "ItemEnquiry", "WReconcilSort", "NRecdate Desc", false);  } }

    /// <summary>Sort order for both grids in requisition tab (from configuration setting WRequisSort)</summary>
    public static string RequisitionSort { get { return WConfiguration.Load<string>(SessionInfo.SiteID, "D|WINORD", "ItemEnquiry", "WRequisSort", "NRecdate Desc", false); } }

    /// <summary>If the formulary field on the F4 screen should be displayed as a Text (enum) or if false the single change code from the db. 11Jan13 XN (38049)</summary>
    public static bool DisplayFormularyAsLetterOnly { get { return WConfiguration.Load<bool>(SessionInfo.SiteID, "D|WINORD", "ItemEnquiry", "DisplayFormularyAsLetterOnly", false, false); } }

    /// <summary>Limit to display contracts (contracts tab) in years (LimitToDisplayContractsInYears setting)</summary>
    public static int LimitToDisplayContractsInYears { get { return SettingsController.Load<int>("Pharmacy", "Stores", "LimitToDisplayContractsInYears", 3); } } 
}
