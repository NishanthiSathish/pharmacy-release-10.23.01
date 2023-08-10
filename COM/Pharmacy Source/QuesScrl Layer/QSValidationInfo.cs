//===========================================================================
//
//							    QSValidationInfo.cs
//
//  Used to store validation errors and warnings created by the QuesScrl module
//  
//	Modification History:
//	23Jan14 XN  Written
//  16Jun14 XN  Got ToHTML to use siteIDToNumber dictionary 88509
//              (as removed pharmacy data layer dependancy)
//              Also got it to replace \n with <br />
//  21Jul16 XN  126634 Added GetLongestCharLength
//===========================================================================
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.shared;
using System;

namespace ascribe.pharmacy.quesscrllayer
{
    /// <summary>Holds validation errors and warnings (used by QuesScrl)</summary>
    public struct QSValidationInfo
    {
        public int    siteID;
        public bool   error;
        public string message;
    }

    /// <summary>Holds list of QSValidationInfo validation items</summary>
    public class QSValidationList : List<QSValidationInfo>
    {
        /// <summary>Add error to the list</summary>
        /// <param name="siteID">Site ID of the error</param>
        /// <param name="format">Format sting</param>
        /// <param name="param">format string parameters</param>
        public void AddError(int siteID, string format, params object[] param)
        {
            QSValidationInfo info = new QSValidationInfo();
            info.siteID = siteID;
            info.error  = true;
            info.message= string.Format(format, param);
            Add(info);
        }

        /// <summary>Add warning to the list</summary>
        /// <param name="siteID">Site ID of the error</param>
        /// <param name="format">Format sting</param>
        /// <param name="param">format string parameters</param>
        public void AddWarning(int siteID, string format, params object[] param)
        {
            QSValidationInfo info = new QSValidationInfo();
            info.siteID = siteID;
            info.error  = false;
            info.message= string.Format(format, param);
            Add(info);
        }

        /// <summary>Returns the longest error message char count (without cr) or an error 21Jul16 XN 126634</summary>
        /// <returns>longest error message char count</returns>
        public int GetLongestCharLength()
        {
            return this.Max(l => l.message.Split('\n').Max(s => s.Length));
        }

        /// <summary>Converts validation error and warnings to a html table in form
        ///     {Site Number 1}
        ///     {error icon} {error description 1}
        ///                  {error description 2}
        ///     :
        ///     {warning icon} {warning description 1}
        ///                    {warning description 2}
        ///                    
        ///     {Site Number 2}
        ///     {error icon} {error description 1}
        ///                  {error description 2}
        ///     :
        /// </summary>
        /// <param name="siteIDToNumber">Dictionary of site id to number (only if want site id on form)</param>
        public virtual string ToHTML(IDictionary<int,int> siteIDToNumber = null)
        {
            StringBuilder msg = new StringBuilder();
            foreach (var validationInfoBySiteID in this.GroupBy(v => v.siteID))
            {
                // Add Site number
                if (siteIDToNumber != null)
                    msg.AppendFormat("Site {0:000}<br />", siteIDToNumber[validationInfoBySiteID.Key] );

                msg.Append("<table cellspacing='10'><colgroup><col width='15px' valign='top' /><col width='100%' valign='top' /></colgroup>");

                // Add errors
                var errorMsgs = validationInfoBySiteID.Where(e => e.error).SelectMany( e => e.message.Split('\n') ).Distinct().ToList();
                if (errorMsgs.Any())
                    msg.AppendFormat("<tr><td><img src='../../images/Developer/exclamation_red.gif' /></td><td>{0}</td></tr>", errorMsgs.Select(s => s.XMLEscape()).ToCSVString("<br />"));

                // Add warnings
                var warningMsgs = validationInfoBySiteID.Where(e => !e.error).SelectMany( e => e.message.Split('\n') ).Distinct().ToList();
                if (warningMsgs.Any())
                    msg.AppendFormat("<tr><td><img src='../../images/Developer/exclamation_yellow.gif' /></td><td>{0}</td></tr>", warningMsgs.Select(s => s.XMLEscape()).ToCSVString("<br />"));

                msg.AppendFormat("</table>");
            }

            return msg.ToString();
        }
    }
}
