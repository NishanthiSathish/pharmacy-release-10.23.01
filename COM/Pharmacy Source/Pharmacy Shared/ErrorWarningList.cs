// -----------------------------------------------------------------------
// <copyright file="ErrorWarningList.cs" company="Ascribe">
//      Copyright Ascribe Ltd    
// </copyright>
// <summary>
// Used to store validation errors and warnings
//  
// Modification History:
// 17Jan15 XN  Written
// 21Jul16 XN  126634 Added GetErrors, GetWarnings, and GetLongestCharLength
//             Moved ErrorWarningEnumeratorExtension to ToHTML
// 09Mar17 XN  179332 Update ToHtml to remove \r 
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.shared
{
    using System.Collections.Generic;
    using System.Data;
    using System.Linq;
    using System.Text;

    /// <summary>Info about the error</summary>
    public struct ErrorWarningInfo
    {
        /// <summary>Site where the error occurred (0 if not for any site)</summary>
        public int SiteId;

        /// <summary>If error (else warning)</summary>
        public bool Error;

        /// <summary>Message to display</summary>
        public string Message;
    }

    /// <summary>Holds list of QSValidationInfo validation items</summary>
    public class ErrorWarningList : List<ErrorWarningInfo>
    {
        /// <summary>Add error to the list</summary>
        /// <param name="format">Format sting</param>
        /// <param name="param">format string parameters</param>
        public void AddError(string format, params object[] param)
        {
            ErrorWarningInfo info = new ErrorWarningInfo();
            info.SiteId = 0;
            info.Error  = true;
            info.Message= string.Format(format, param);
            this.Add(info);
        }

        /// <summary>Add error to the list</summary>
        /// <param name="siteId">Site ID of the error</param>
        /// <param name="format">Format sting</param>
        /// <param name="param">format string parameters</param>
        public void AddError(int siteId, string format, params object[] param)
        {
            ErrorWarningInfo info = new ErrorWarningInfo();
            info.SiteId = siteId;
            info.Error  = true;
            info.Message= string.Format(format, param);
            this.Add(info);
        }

        /// <summary>Add warning to the list</summary>
        /// <param name="format">Format sting</param>
        /// <param name="param">format string parameters</param>
        public void AddWarning(string format, params object[] param)
        {
            ErrorWarningInfo info = new ErrorWarningInfo();
            info.SiteId = 0;
            info.Error  = false;
            info.Message= string.Format(format, param);
            this.Add(info);
        }

        /// <summary>Add warning to the list</summary>
        /// <param name="siteId">Site ID of the error</param>
        /// <param name="format">Format sting</param>
        /// <param name="param">format string parameters</param>
        public void AddWarning(int siteId, string format, params object[] param)
        {
            ErrorWarningInfo info = new ErrorWarningInfo();
            info.SiteId = siteId;
            info.Error  = false;
            info.Message= string.Format(format, param);
            this.Add(info);
        }

        /// <summary>Returns errors from the list 21Jul16 XN 126634</summary>
        /// <returns>List of errors</returns>
        public IEnumerable<ErrorWarningInfo> GetErrors()
        {
            return this.Where(e => e.Error);
        }

        /// <summary>Returns warnings from the list 21Jul16 XN 126634</summary>
        /// <returns>List of warnings</returns>
        public IEnumerable<ErrorWarningInfo> GetWarnings()
        {
            return this.Where(e => !e.Error);
        }

        /// <summary>Returns the longest error message char count (without cr) or an error 21Jul16 XN 126634</summary>
        /// <returns>longest error message char count</returns>
        public int GetLongestCharLength()
        {
            return this.Max(l => l.Message.Split('\n').Max(s => s.Length));
        }
    }

    /// <summary>Holds extension methods for IEnumerator{ErrorWarningInfo}</summary>
    public static class ErrorWarningEnumeratorExtension
    {
        /// <summary>Converts validation error and warnings to a HTML table in form
        ///     {Site Number 1}
        ///     {error icon} {error description 1}
        ///                  {error description 2}
        ///     :
        ///     {warning icon} {warning description 1}
        ///                    {warning description 2}
        /// <para />
        ///     {Site Number 2}
        ///     {error icon} {error description 1}
        ///                  {error description 2}
        ///     :
        /// </summary>
        /// <returns>HTML string for errors</returns>
        public static string ToHtml(this IEnumerable<ErrorWarningInfo> list)
        {
            StringBuilder msg = new StringBuilder();

            // If require read in all the sites
            var siteIdToNumber = new Dictionary<int,int>();
            if (list.Any(l => l.SiteId != 0))
            {
                siteIdToNumber = Database.ExecuteSQLDataTable("SELECT LocationID, SiteNumber FROM Site").Rows.OfType<DataRow>().ToDictionary(r => (int)r["LocationID"], r => (int)r["SiteNumber"]);
            }

            foreach (var validationInfoBySiteId in list.GroupBy(v => v.SiteId))
            {
                // Add Site number
                if (validationInfoBySiteId.Key != 0)
                {
                    msg.AppendFormat("Site {0:000}<br />", siteIdToNumber[validationInfoBySiteId.Key]);
                }

                msg.Append("<table cellspacing='10'><colgroup><col width='15px' valign='top' /><col width='100%' valign='top' /></colgroup>");

                // Add errors
                // var errorMsgs = validationInfoBySiteId.Where(e => e.Error).SelectMany(e => e.Message.Split('\n')).Distinct().ToList(); 09Mar17 XN  179332
                var errorMsgs = validationInfoBySiteId.Where(e => e.Error).SelectMany(e => e.Message.Split('\n')).Distinct().Select(e => e.Replace("\r", string.Empty)).ToList();
                if (errorMsgs.Any())
                {
                    msg.AppendFormat("<tr><td><img src='../../images/Developer/exclamation_red.gif' /></td><td>{0}</td></tr>", errorMsgs.Select(s => s.XMLEscape()).ToCSVString("<br />"));
                }

                // Add warnings
                var warningMsgs = validationInfoBySiteId.Where(e => !e.Error).SelectMany(e => e.Message.Split('\n')).Distinct().ToList();
                if (warningMsgs.Any())
                {
                    msg.AppendFormat("<tr><td><img src='../../images/Developer/exclamation_yellow.gif' /></td><td>{0}</td></tr>", warningMsgs.Select(s => s.XMLEscape()).ToCSVString("<br />"));
                }

                msg.AppendFormat("</table>");
            }

            return msg.ToString();
        }
    }
}
