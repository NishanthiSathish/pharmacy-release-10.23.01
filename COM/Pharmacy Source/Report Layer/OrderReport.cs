//===========================================================================
//
//						    OrderReport.cs
//
//  This class is used to get access to the OrderReport table.
//      
//	Modification History:
//	11Mar13 XN  58517 Added but needs needs filling out a later date
//  26Apr13 XN  53699 Added method SearchForReport
//  01Jun16 XN  154372 Added method GetReportByName
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.reportlayer
{
    /// <summary>Used for access in the OrderReport table</summary>
    public class OrderReport
    {
        /// <summary>Return if the report existing in the db (not case sensitive</summary>
        /// <param name="description">Report name</param>
        /// <returns>If report exists</returns>
        public static bool IfReportExists(string description)
        {
            return Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM OrderReport WHERE Description Like '{0}'", description) > 0;
        }

        /// <summary>Returns all report names from db with specified search string</summary>
        /// <param name="searchString">String to search for</param>
        /// <returns>List of report names</returns>
        public static IEnumerable<string> SearchForReport(string searchString)
        {
            return Database.ExecuteSQLSingleField<string>("SELECT Description FROM OrderReport WHERE Description Like '{0}'", searchString);
        }

        /// <summary>
        /// Returns the report RTF by description
        /// 1Jun16 XN 154372
        /// </summary>
        /// <param name="description">Report description (from OrderReport table)</param>
        /// <returns>RTF or null if the report does not exist</returns>
        public static string GetReportByName(string description)
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("CurrentSession", SessionInfo.SessionID);
            parameters.Add("Description",    description);
            return Database.ExecuteSQLScalar<string>("Exec pRichTextDocumentByDescription @CurrentSession, @Description", parameters);
        }
    }
}
