//===========================================================================
//
//							        LookupList.cs
//
//	Provides quick lookup functions for ICW data
//
//  These are normaly used in search routine, or lookup list 
//  e.g. Allow user to select from list of site
//
//	Modification History:
//	23Apr13 XN  Written 53147
//  22Aug14 XN  Converted LoadByWard, LoadByPNDaysPast, and LoadByDiscontinuationReason
//              to non XML version as XML comes back different on some live servers
//  30May15 XN  Added LoadByAMMDateRangePast
//  02Jul15 XN  Added LoadByAMMReportErrorReasons 39882
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    public class LookupListRow : BaseRow
    {
        public int DBID
        {
            get { return (int)FieldToInt(RawRow["DBID"]); }
        }

        public string Descritpion
        {
            get { return FieldToStr(RawRow["Description"], true, string.Empty); }
        }
    }

    /// <summary>Provides column information about the PNProduct table</summary>
    public class LookupListColumnInfo : BaseColumnInfo
    {
        public LookupListColumnInfo() : base("PNProduct") { }
    }

    public class LookupList : BaseTable2<LookupListRow, BaseColumnInfo>
    {
        public LookupList() : base("LookupList") { }

        /// <summary>Returns all wards</summary>
        public void LoadByWard()
        {
            //LoadFromXMLString("Exec pWardLookupList {0}", SessionInfo.SessionID); 22Aug14 XN
            LoadBySQL("Exec pWardLookupListNonXML {0}", SessionInfo.SessionID);
        }

        /// <summary>Returns all wards contining the search text</summary>
        /// <param name="searchText">Search text</param>
        public void LoadByWard(string searchText)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID));
            parameters.Add(new SqlParameter("@SearchText",       searchText));
            LoadBySP("pWardLookupBySearchText", parameters);
        }

        public void LoadByPNDaysPast()
        {
            //LoadFromXMLString("Exec pPNDateRangesPast {0}", SessionInfo.SessionID); 22Aug14 XN
            LoadBySQL("Exec pPNDateRangesPast {0}", SessionInfo.SessionID);
        }

        /// <summary>Calls pAMMDateRangePast to load amm date range past</summary>
        public void LoadByAMMDateRangePast()
        {
            this.LoadBySP("pAMMDateRangePast", new SqlParameter[0]);
        }

        public void LoadByDiscontinuationReason()
        {
            //LoadFromXMLString("Exec pDiscontinuationReasonList {0}", SessionInfo.SessionID); 22Aug14 XN
            LoadBySQL("Exec pDiscontinuationReasonListNonXML {0}", SessionInfo.SessionID);
        }

        /// <summary>Load the AMM report error reasons 02Jul15 XN 39882</summary>
        public void LoadByAMMReportErrorReasons()
        {
            this.LoadBySP("pAMMReportErrorReasons", new SqlParameter[0]);
        }
    }
}
