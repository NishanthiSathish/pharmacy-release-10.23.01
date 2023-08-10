//===========================================================================
//
//						                    Utils.cs
//
//  Util functions for the ward stock list layer.
//
//  Includes classes
//      QSValidationListForLine  - 
//      QSDifferencesListForLine - Extends QSDifferences base class for WWardProductListLineAccessor
//  
//	Modification History:
//	17Dec15 XN  Written 38034
//===========================================================================
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.wardstocklistlayer
{
    /// <summary>
    /// Extends QSValidation base class for WWardProductListLineAccessor 
    /// So can customize the HTML messages for WWardProductListLine (as don't use Site info)
    /// </summary>
    internal class QSValidationListForLine : QSValidationList
    {
        private WWardProductListLine lines;        

        public QSValidationListForLine(WWardProductListLine lines)
        {
            this.lines = lines;
        }

        /// <summary>Overrides the base class so groups validation errors by line rather than by site</summary>
        public override string ToHTML(IDictionary<int,int> map = null)
        {
            WWardProductList lists = new WWardProductList ();
            lists.LoadBySiteAndInUse(SessionInfo.SiteID);

            StringBuilder msg = new StringBuilder();
            foreach (var validationInfoByID in this.GroupBy(v => v.siteID)) // siteID is actually line ID
            {
                // Add ward list info
                if (this.lines != null)
                {
                    WWardProductListLineRow line = this.lines.FindByID(validationInfoByID.Key);
                    WWardProductListRow     list = lists.FindByID(line.WWardProductListID);

                    msg.AppendFormat("List '{0}' line {1}<br />", list, line.DisplayIndex + 1);
                }

                msg.Append("<table cellspacing='10'><colgroup><col width='15px' valign='top' /><col width='100%' valign='top' /></colgroup>");

                // Add errors
                var errorMsgs = validationInfoByID.Where(e => e.error).SelectMany( e => e.message.Split('\n') ).Distinct().ToList();
                if (errorMsgs.Any())
                    msg.AppendFormat("<tr><td><img src='../../images/Developer/exclamation_red.gif' /></td><td>{0}</td></tr>", errorMsgs.Select(s => s.XMLEscape()).ToCSVString("<br />"));

                // Add warnings
                var warningMsgs = validationInfoByID.Where(e => !e.error).SelectMany( e => e.message.Split('\n') ).Distinct().ToList();
                if (warningMsgs.Any())
                    msg.AppendFormat("<tr><td><img src='../../images/Developer/exclamation_yellow.gif' /></td><td>{0}</td></tr>", warningMsgs.Select(s => s.XMLEscape()).ToCSVString("<br />"));

                msg.AppendFormat("</table>");
            }

            return msg.ToString();
        }
    }

    /// <summary>
    /// Extends QSDifferences base class for WWardProductListLineAccessor 
    /// So can customize the HTML messages for WWardProductListLine (as don't use Site info)
    /// </summary>
    internal class QSDifferencesListForLine : QSDifferencesList
    {
        private WWardProductListLine lines;        

        public QSDifferencesListForLine(WWardProductListLine lines)
        {
            this.lines = lines;
        }

        /// <summary>Overrides the base class so groups validation errors by line rather than by site</summary>
        public override string ToHTML(IDictionary<int,int> map = null)
        {
            WWardProductList lists = new WWardProductList ();
            lists.LoadBySiteAndInUse(SessionInfo.SiteID);

            StringBuilder msg = new StringBuilder();
            foreach (var diff in this.GroupBy(d => d.siteID)) // siteID is actually line ID
            {
                // Add grouping text
                WWardProductListLineRow line = this.lines.FindByID(diff.Key);
                WWardProductListRow     list = lists.FindByID(line.WWardProductListID);
                msg.AppendFormat("List '{0}' line {1}<br />", list.ToString().Trim(), line.DisplayIndex + 1);

                // Add each change
                msg.AppendFormat("<table cellspacing='10' width='400px' ><tr><td><b>Description</b></td><td><b>Was</b></td><td><b>Now</b></td></tr>");
                foreach (QSDifference d in diff)
                    msg.AppendFormat("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>", d.description.XMLEscape(), d.was.XMLEscape(), d.now.XMLEscape());
                msg.AppendFormat("</table><br />");
            }

            return msg.ToString();
        }

        /// <summary>Converts the list of difference to an RTF table</summary>
        public string ToRTF()
        {
            StringBuilder rtf = new StringBuilder();

            WWardProductList lists = new WWardProductList ();
            lists.LoadBySiteAndInUse(SessionInfo.SiteID);

            rtf.AppendLine(@"\row{{ }}");

            foreach (var diff in this.GroupBy(d => d.siteID)) // siteID is actually line ID
            {
                // Add grouping text
                WWardProductListLineRow line = this.lines.FindByID(diff.Key);
                WWardProductListRow     list = lists.FindByID(line.WWardProductListID);

                RTFTable table = new RTFTable();

                rtf.AppendFormat(@"\row\trleft{0}{{List '{1}' line {2}}}\row", table.LeftMarginInTwips, list.ToString().Replace(@"\", @"\\"), line.DisplayIndex + 1);
                rtf.AppendLine();

                table.AddColumn("Description", 50, RTFTable.AlignmentType.Left); 
                table.AddColumn("Was",         25, RTFTable.AlignmentType.Center); 
                table.AddColumn("Now",         25, RTFTable.AlignmentType.Center);

                // Add each change
                foreach (QSDifference d in diff)
                {
                    table.NewRow();
                    table.AddCell(d.description.Replace(@"\", @"\\"));
                    table.AddCell(d.was.Replace(@"\", @"\\"));
                    table.AddCell(d.now.Replace(@"\", @"\\"));
                }

                rtf.Append( table.ToString() );
                rtf.AppendLine(@"\row");
            }

            return rtf.ToString();
        }
    }
}
