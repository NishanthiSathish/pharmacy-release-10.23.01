//===========================================================================
//
//							    QSDifferences.cs
//
//  Used to store difference between original and new values, by the QuesScrl module
//  
//	Modification History:
//	23Jan14 XN  Written
//  16Jun14 XN  Got ToHTML to use siteIDToNumber dictionary 88509
//              (as removed pharmacy data layer dependancy)
//  26Oct15 XN  ToHTM set column width so columns line up 106278 
//  04Aug16 XN  Update ToHTM to handle cr 159565
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.quesscrllayer
{
    /// <summary>Holds difference information between original and new values (used by QuesScrl)</summary>
    public struct QSDifference
    {
        public int siteID;
        public int dataIndex;       // 18May15 XN 117528 added
        public string description;
        public string was;
        public string now;
    }

    /// <summary>List of QSDifference's</summary>
    public class QSDifferencesList : List<QSDifference>
    {
        /// <summary>Adds the difference to the list</summary>
        public void Add(int siteID, string description, string now, string was)
        {
            QSDifference d = new QSDifference()
                                {
                                    siteID      = siteID,
                                    description = description,
                                    now         = now,
                                    was         = was
                                };
            this.Add(d);
        }

        /// <summary>
        /// Converts the list of difference into a HTML table
        /// {Site Number 001}
        ///                 Was         Now
        /// {Description1}   {Value1}    {Value2}    
        /// {Description2}   {Value1}    {Value2}    
        /// 
        /// {Site Number 002}
        ///                 Was         Now
        /// {Description1}   {Value1}    {Value2}    
        /// {Description2}   {Value1}    {Value2}    
        /// </summary>
        /// <param name="siteIDToNumber">Dictionary of site id to number (only if want site id on form)</param>
        public virtual string ToHTML(IDictionary<int,int> siteIDToNumber = null)
        {
            StringBuilder msg = new StringBuilder();
            foreach (var diff in this.GroupBy(d => d.siteID))
            {
                int siteID = diff.Key;
                if (siteIDToNumber != null)
                    msg.AppendFormat(string.Format("Site {0:000}<br />", siteIDToNumber[siteID]));

                //msg.AppendFormat("<table cellspacing='10' width='400px' ><tr><td><b>Description</b></td><td><b>Was</b></td><td><b>Now</b></td></tr>");   26Oct15 XN  ToHTM set column width so columns line up 106278 
                msg.AppendFormat("<table cellspacing='2' width='400px'><colgroup><col width='40%'/><col width='30%'/><col width='30%'/></colgroup><tr><td><b>Description</b></td><td><b>Was</b></td><td><b>Now</b></td></tr>");
                foreach (QSDifference d in diff)
                    msg.AppendFormat("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>", d.description.XMLEscape(), d.was.XMLEscape().Replace("\r\n", "<br />"), d.now.XMLEscape().Replace("\r\n", "<br />")); // 04Aug16 XN  Update ToHTM to handle cr 159565
                msg.AppendFormat("</table><br />");
            }

            return msg.ToString();
        }
    }
}
