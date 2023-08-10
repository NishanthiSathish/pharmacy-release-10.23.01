// ===========================================================================
//
//                          Settings.cs
//
//  Settings for the Ward stock list
//  
//	Modification History:
//	08Jan14 XN  Written
// ===========================================================================
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.wardstocklistlayer
{
    /// <summary>Ward Stock List settings</summary>
    public class Settings
    {
        /// <summary>
        /// If site suport DLO
        /// config setting D|winord.DLO.AllowDLO
        /// </summary>
        public static bool AllowDLO { get { return WConfiguration.Load<bool>(SessionInfo.SiteID, "D|winord", "DLO", "AllowDLO", false, false); } }

        /// <summary>
        /// If allowed to issue to out of use wards
        /// config setting D|StockList..AllowIssueToOutOfUseWard (default false)
        /// </summary>
        public static bool AllowIssueToOutOfUseWard { get { return WConfiguration.Load<bool>(SessionInfo.SiteID, "D|StockList", string.Empty, "AllowIssueToOutOfUseWard", false, false); } }

        /// <summary>
        /// Time period for the trans log display in the Ward stock list
        /// config setting D|StockList.IssueLog.PeriodInDays (default 7)
        /// </summary>
        public static int IssueLogPeriodInDays { get { return WConfiguration.Load<int>(SessionInfo.SiteID, "D|StockList", "IssueLog", "PeriodInDays", 7, false); } }

        /// <summary>
        /// Kinds for the translog log display in the Ward stock list
        /// config setting D|StockList.IssueLog.Kind (default SP)
        /// </summary>
        public static IEnumerable<string> IssueLogKind { get { return WConfiguration.Load<string>(SessionInfo.SiteID, "D|StockList", "IssueLog", "Kind", "SP", false).ToCharArray().Select(c => c.ToString()); } }

        /// <summary>
        /// translog log columns to display in the Ward stock list
        /// config setting D|StockList.IssueLog.Columns (default null)
        /// </summary>
        public static string IssueLogColumns { get { return WConfiguration.Load<string>(SessionInfo.SiteID, "D|StockList", "IssueLog", "Columns", null, false); } }

        /// <summary>
        /// Status of outstnading WRequis items for translog items
        /// config setting D|StockList.Delete.OutstandingRequisState (default null)
        /// </summary>
        public static IEnumerable<OrderStatusType> OutstandingRequisState 
        { 
            get 
            { 
                string states = WConfiguration.Load<string>(SessionInfo.SiteID, "D|StockList", "Delete", "OutstandingRequisState", string.Empty, false);
                return states.ToCharArray().Select(c => EnumDBCodeAttribute.DBCodeToEnum<OrderStatusType>(c.ToString()));
            } 
        }

        //08Aug16 KR Added (tfs 159583)
        /// <summary>
        /// Stores only Items setting used for filtering products when searching.
        /// Use existing setting for compatibility
        /// config setting D|Winord.WardStock.AllowStoresOnly (default -1)
        /// </summary>
        public static int AllowStoresOnly { get { return WConfiguration.Load<int>(SessionInfo.SiteID, "D|WinOrd", "WardStock", "AllowStoresOnly", -1, false); } }
    }
}
