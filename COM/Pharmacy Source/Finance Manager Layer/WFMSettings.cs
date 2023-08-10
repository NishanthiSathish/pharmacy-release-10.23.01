//===========================================================================
//
//							     WFMSettings.cs
//
//  Provides access to finance manager settings. Once accessed the settings 
//  are cached per a web request.
//
//	Modification History:
//	02MAy13 XN  Written 27038
//  16Sep13 XN  Added AccountSheet (for account sheet) 73326 
//  17Sep13 XN  Converted WFMAccountCode.Code, WFMRule.Code from string to short
//  09Jan13 XN  Added WFMSettings.StockAccountSheet.DisplayColumns
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;

namespace ascribe.pharmacy.financemanagerlayer
{
    public static class WFMSettings
    {
        public static class StockAccountSheet
        {
            public static short                           AccountCode                { get { return SettingsController.LoadAndCache<short> ("FinanceManager", "StockAccountSheet", "AccountCode",                110           ); } }
            public static string                          OrderlogViewerColumns      { get { return SettingsController.LoadAndCache<string>("FinanceManager", "StockAccountSheet", "OrderlogViewerColumns",      string.Empty  ); } }
            public static string                          TranslogViewerColumns      { get { return SettingsController.LoadAndCache<string>("FinanceManager", "StockAccountSheet", "TranslogViewerColumns",      string.Empty  ); } }
            public static string                          CombinedLogViewerColumns   { get { return SettingsController.LoadAndCache<string>("FinanceManager", "StockAccountSheet", "CombinedlogViewerColumns",   string.Empty  ); } }
            public static FMStockAccountSheetColumnType[] DisplayColumns 
            { 
                get 
                { 
                    string displayColumnsStr = SettingsController.Load<string>("FinanceManager","StockAccountSheet","DisplayColumns",Enum.GetNames(typeof(FMStockAccountSheetColumnType)).ToCSVString(","));
                    return displayColumnsStr.Split(',').Select(c => (FMStockAccountSheetColumnType)Enum.Parse(typeof(FMStockAccountSheetColumnType), c)).ToArray();
                } 
            }
        }

        public static class AccountSheet
        {
            public static int    DateRangeLimitInMonths { get { return SettingsController.LoadAndCache<int>   ("FinanceManager", "AccountSheet", "DateRangeLimitInMonths",  12          ); } }
            public static string LogViewerColumns       { get { return SettingsController.LoadAndCache<string>("FinanceManager", "AccountSheet", "LogViewerColumns",        string.Empty); } }
        }

        public static class GrniSheet
        {
            public static IEnumerable<short>    AccountCode         { get { return SettingsController.LoadAndCache<string>   ("FinanceManager", "GrniSheet", "AccountCode",        "210,220"        ).Split(',').Select(c => short.Parse(c)); } }
            public static int                   MonthlyGrouping     { get { return SettingsController.LoadAndCache<int>      ("FinanceManager", "GrniSheet", "MonthlyGrouping",    3                ); } }
            public static int                   MonthRange          { get { return SettingsController.LoadAndCache<int>      ("FinanceManager", "GrniSheet", "MonthRange",         9                ); } }
            public static string                LogViewerColumns    { get { return SettingsController.LoadAndCache<string>   ("FinanceManager", "GrniSheet", "LogViewerColumns",   string.Empty     ); } }
            public static DateTime OpeningBalanceDate  
            { 
                get { return DateTimeExtensions.PharmacyParse(SettingsController.LoadAndCache("FinanceManager", "GrniSheet", "OpeningBalanceDate", DateTimeExtensions.MinDBValue.ToPharmacyDateString())).Value; } 
                set { SettingsController.Save<string>("FinanceManager", "GrniSheet", "OpeningBalanceDate", value.ToPharmacyDateString());                                                                        }
            }
            public static double OpeningBalance
            { 
                get { return SettingsController.LoadAndCache<double>("FinanceManager", "GrniSheet", "OpeningBalance", 0f); } 
                set { SettingsController.Save<double>("FinanceManager", "GrniSheet", "OpeningBalance", value);             }
            }
        }

        public static class StockAccountEditor
        {
            public static bool AllowAdd    { get { return SettingsController.LoadAndCache<bool>("FinanceManager", "StockAccountEditor", "AllowAdd",    false); } }
            public static bool AllowDelete { get { return SettingsController.LoadAndCache<bool>("FinanceManager", "StockAccountEditor", "AllowDelete", false); } }
        }

        public static class RuleEditor
        {
            public static string LabelTypes             { get { return SettingsController.LoadAndCache<string>("FinanceManager", "RuleEditor", "LabelTypes",             "ABEHILRTV"                            ); } }
            //public static string OrderlogCostFields     { get { return SettingsController.LoadAndCache<string>("FinanceManager", "RuleEditor", "OrderlogCostFields",     "CostExVat,Cost,<Ignore>"              ); } }  As
            public static string OrderlogCostMultiplier { get { return SettingsController.LoadAndCache<string>("FinanceManager", "RuleEditor", "OrderlogCostMultiplier", "1,-1,QtyRec,-QtyRec,QtyOrd,-QtyOrd"   ); } } // Adding items here requires updating pWFMLogCachePopulate
            public static string OrderlogStockFields    { get { return SettingsController.LoadAndCache<string>("FinanceManager", "RuleEditor", "OrderlogStockFields",    "QtyRec,QtyOrd,<Ignore>"               ); } }
            public static string OrderlogStockMultiplier{ get { return SettingsController.LoadAndCache<string>("FinanceManager", "RuleEditor", "OrderlogStockMultiplier","1,-1,ConvFact,-ConvFact"              ); } } // Adding items here requires updating pWFMLogCachePopulate 
            public static string TranslogCostFields     { get { return SettingsController.LoadAndCache<string>("FinanceManager", "RuleEditor", "TranslogCostFields",     "CostExTax,Cost,<Ignore>"              ); } }
            public static string TranslogCostMultiplier { get { return SettingsController.LoadAndCache<string>("FinanceManager", "RuleEditor", "TranslogCostMultiplier", "1,-1,Qty,-Qty"                        ); } } // Adding items here requires updating pWFMLogCachePopulate
            public static string TranslogStockFields    { get { return SettingsController.LoadAndCache<string>("FinanceManager", "RuleEditor", "TranslogStockFields",    "Qty,<Ignore>"                         ); } }
            public static string TranslogStockMultiplier{ get { return SettingsController.LoadAndCache<string>("FinanceManager", "RuleEditor", "TranslogStockMultiplier","1,-1,ConvFact,-ConvFact"              ); } } // Adding items here requires updating pWFMLogCachePopulate
        }

        public static class General
        {
            public static bool RebuildLogs 
            { 
                get { return SettingsController.LoadAndCache<bool>("FinanceManager", "General", "RebuildLogs", false); } 
                set { SettingsController.Save<bool>               ("FinanceManager", "General", "RebuildLogs", value); } 
            }
            public static bool TestingMode           { get { return SettingsController.LoadAndCache<bool>("FinanceManager", "General", "TestingMode",           false); } }
            public static bool TestingUpdateTimeMode { get { return SettingsController.LoadAndCache<bool>("FinanceManager", "General", "TestingUpdateTimeMode", false); } }

            public static bool ShowAddStockAccountSheet { get { return SettingsController.LoadAndCache("FinanceManager", "General", "ShowAddStockAccountSheet",   true); } }
            public static bool ShowAddAccountSheet      { get { return SettingsController.LoadAndCache("FinanceManager", "General", "ShowAddAccountSheet",        true); } }
            public static bool ShowAddGRNISheet         { get { return SettingsController.LoadAndCache("FinanceManager", "General", "ShowAddGRNISheet",           true); } }

            /// <summary>
            /// Returns list of sites allowed when creating a blance sheet 
            /// System: FinanceManager
            /// Section: General
            /// Key: AllowedSites
            /// Value: list of site numbers (if setting is blank in db will return all sites)
            /// </summary>
            public static IEnumerable<int> AllowedSites
            {
                get
                {
                    List<int> siteNumbers = new List<int>();
                    string value = SettingsController.Load("FinanceManager", "General", "AllowedSites", string.Empty);

                    if (value.EqualsNoCaseTrimEnd("All"))
                    {
                        // If no sites in list then add all the sites
                        Sites sites = new Sites();
                        sites.LoadAll(true);
                        siteNumbers = sites.Select(s => s.SiteNumber).ToList();
                    }
                    else
                    {
                        // Parse sites
                        string[] sitesSelectedByDefaultStr = value.Split(new [] { ',' });
                        foreach(string siteNumberStr in sitesSelectedByDefaultStr)
                        {
                            int siteNumber;
                            if (int.TryParse(siteNumberStr, out siteNumber))
                                siteNumbers.Add(siteNumber);
                        }
                    }

                    return siteNumbers;
                }
            }

            /// <summary>
            /// Returns list of sites selected by default for replication
            /// System: FinanceManager
            /// Section: AllowedSites
            /// Key: SitesSelectedByDefault
            /// Value: list of site numbers (if setting is blank in db will return all sites)
            /// </summary>
            public static IEnumerable<int> SiteNumbersSelectedByDefault
            {
                get
                {
                    List<int> siteNumbers = new List<int>();
                    string value = SettingsController.Load("FinanceManager", "General", "SiteNumbersSelectedByDefault", string.Empty);

                    if (value.EqualsNoCaseTrimEnd("All"))
                    {
                        // If no sites in list then add all the sites
                        Sites sites = new Sites();
                        sites.LoadAll(true);
                        siteNumbers = sites.Select(s => s.SiteNumber).ToList();
                    }
                    else
                    {
                        // Parse sites
                        string[] sitesSelectedByDefaultStr = value.Split(new [] { ',' });
                        foreach(string siteNumberStr in sitesSelectedByDefaultStr)
                        {
                            int siteNumber;
                            if (int.TryParse(siteNumberStr, out siteNumber))
                                siteNumbers.Add(siteNumber);
                        }
                    }

                    return siteNumbers;
                }
            }
        }
    }
}
