
//===========================================================================
//
//					    DispensingPMRDispensings.cs
//
//  Class used to load and convert dispensing into HTML rows for display 
//  in the dispensing PMR.  The HTML returned will be in the from
//     {tr id='dispensing id' rowType='Dispensing' id_parent='prescription id' level='2' current='1'}
//         {td}+{/td}
//         {td}Issue type{/td}
//         {td}NSV code{/td}
//         {td}Ward code{/td}
//         {td}Consultant code{/td}
//         {td}Dispenser initials{/td}
//         {td}site number{/td}
//         {td}Last disp date{/td}
//         {td}Last qty{/td}
//         {td}{/td}
//         {td}{/td}
//         {td}dispensing id{/td}
//         {td}{/td}
//         {td}{/td}
//         {td}Repeat dispensing column if shown{/td}
//     {/tr}    
//
//  The class uses sp pWLabelListByPrescription to load the data
//
//  Usage:
//  To load all dispensing under a prescription
//  DispensingPMRViewSettings viewSettings = new DispensingPMRViewSettings();
//  DispensingPMRDispensings.GetHTMLRows(requestID_Prescription, null, viewSettings);
//
//  To load a specific dispensing
//  DispensingPMRViewSettings viewSettings = new DispensingPMRViewSettings();
//  DispensingPMRDispensings.GetHTMLRows(requestID_Prescription, requestID_Dispensing, viewSettings);
//
//	Modification History:
//  15Nov12 XN  TFS47487 Replace to improve speed of old DispensingPMR
//  16Jan13 XN  TFS47487 Added closing tags to the img nodes
//                       Prevent duplicate rows (extra check)
//  22Jan13 XN           Fixed coloring of last dispensing time
//  28Feb13 XN  TFS37264 Added PSO column
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.dispensingpmrlayer
{
    /// <summary>Represents a record from the pWLabelListByPrescription</summary>
    public class DispensingPMRDispensingsRow : BaseRow
    {
        public int       RequestID                  { get { return FieldToInt            (RawRow["RequestID" ]).Value;                } }
        public string    Description                { get { return FieldToStr            (RawRow["Text"      ], false, string.Empty); } }
        public bool      SplitDose                  { get { return FieldToBoolean        (RawRow["SplitDose" ]).Value;                } } 
        public string    NSVCode                    { get { return FieldToStr            (RawRow["SisCode"   ], false, string.Empty); } } 
        public string    WardCode                   { get { return FieldToStr            (RawRow["WardCode"  ], false, string.Empty); } } 
        public string    ConsultantCode             { get { return FieldToStr            (RawRow["ConsCode"  ], false, string.Empty); } } 
        public string    DispenserUserInitials      { get { return FieldToStr            (RawRow["DispID"    ], false, string.Empty); } } 
        public string    IssType                    { get { return FieldToStr            (RawRow["IssType"   ], false, string.Empty); } } 
        public string    SiteName                   { get { return FieldToStr            (RawRow["SiteName"  ], false, string.Empty); } } 
        public int       SiteNumber                 { get { return FieldToInt            (RawRow["SiteNumber"]) ?? 0;                 } } 
        public DateTime? LastSavedDateTime          { get { return FieldToDateTime       (RawRow["LastSavedDateTime"]);               } } 
        public double?   LastQuantity               { get { return FieldToDouble         (RawRow["LastQty"   ]);                      } }
        public int       RepeatDispensing           { get { return FieldToInt            (RawRow["RptDisp"   ]).Value;                } }
        public bool      PSO           		    { get { return FieldToBoolean        (RawRow["PSO"       ], false).Value;         } }
    }

    /// <summary>Loads data from pWLabelListByPrescription sp</summary>
    public class DispensingPMRDispensings : BaseTable2<DispensingPMRDispensingsRow, BaseColumnInfo>
    {
        public DispensingPMRDispensings() { }

        #region Public Methods
        /// <summary>
        /// Loads either all the dispensing under a prescription, or a single dispensing (using pWLabelListByPrescription)
        ///     
        /// If the row is no longer loaded by sp (e.g. been cancelled) method will then return "remove".
        /// </summary>
        /// <param name="requestID_Parent">Prescription requestID</param>
        /// <param name="requestID">Dispensing requestID</param>
        /// <param name="viewSettings">View settings </param>
        /// <returns>HTML rows</returns>
        public string GetHTMLRows(int requestID_Parent, int? requestID,DispensingPMRViewSettings viewSettings)
        {
            // Load in the data
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@CurrentSessionID",        SessionInfo.SessionID               ));
            parameters.Add(new SqlParameter("@RequestID_Prescription",  requestID_Parent                    ));
            parameters.Add(new SqlParameter("@RequestID",               (object)requestID ?? DBNull.Value   ));
            LoadBySP("pWLabelListByPrescription", parameters);

            // If specific row selected and does not exist the say it's been removed
            if (requestID.HasValue && !this.Any())
                return "remove";

            // If just updating 1 row ensure only have 1 row in list incase sql not written correctly
            if (requestID.HasValue)
                this.RemoveAll(r => r.RequestID != requestID.Value);

            // convert rows to HTML
            return ConvertToHTMLRows(requestID_Parent, viewSettings);
        }
        #endregion

        #region Protected Methods
        /// <summary>Converts the dispensing to html rows (see file header for details)</summary>
        /// <param name="requestID_Parent">ID of the parent prescription</param>
        /// <param name="viewSettings">View settings </param>
        /// <returns>HTML rows</returns>
        protected string ConvertToHTMLRows(int requestID_Parent, DispensingPMRViewSettings viewSettings)
        {
            StringBuilder str = new StringBuilder();
            HashSet<int> requestIDsAlreadyDone = new HashSet<int>();

            DateTime now        = DateTime.Now;
            DateTime today      = DateTime.Now.ToStartOfDay();
            DateTime yesterday  = today.AddDays(-1.0);

            foreach (var row in this)
            {
                // If already done this item then skip (with good SQL this should not happen but we are not all Adams!!!)
                if (!requestIDsAlreadyDone.Add(row.RequestID))
                    continue;

                // Start row with basic attributes
                str.AppendFormat("<tr id='{0}' rowType='{1}' id_parent='{2}' level='2' current='1' >", row.RequestID, DispensingPMRRowType.Dispensing, requestID_Parent);

                str.Append("<td class='x'>&nbsp;</td>");    // open\close image column

                // Description column (with icon for split does)
                str.Append("<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");   // Add extra spaces
                if (row.SplitDose)
                    str.Append("<img title='This is a split dose dispensing.' src='../../images/user/SplitDispens.gif' WIDTH='16' HEIGHT='16' />");
                string description = row.Description.RemoveNewLinesAndXMLEscape();
                if (string.IsNullOrEmpty(description))
                    description = "&nbsp;";
                str.Append(description);
                str.Append("</td>");

                str.AppendFormat("<td>{0}</td>", row.IssType.RemoveNewLinesAndXMLEscape());                 // Issue type column
                str.AppendFormat("<td>{0}</td>", row.NSVCode);                                              // NSV code column
                str.AppendFormat("<td>{0}</td>", row.WardCode);                                             // Ward code column
                str.AppendFormat("<td>{0}</td>", row.ConsultantCode);                                       // Consultant code column
                str.AppendFormat("<td>{0}</td>", row.DispenserUserInitials.RemoveNewLinesAndXMLEscape());   // Dispenser initials column
                str.AppendFormat("<td title='{0}'>{1}</td>", row.SiteName, row.SiteNumber);                 // Site number column

                // Last dispensing date column
                DateTime? lastDispensingDate = row.LastSavedDateTime;
                str.AppendFormat("<td ");
                if (lastDispensingDate.HasValue && lastDispensingDate.Value >= today)
                    str.AppendFormat("class='HighlightDate1' ");
                else if (lastDispensingDate.HasValue && lastDispensingDate.Value >= yesterday)
                    str.AppendFormat("class='HighlightDate2' ");

                // If have last dispensing time then display time as tooltip 
                // (as long a not at midnight as this is probably a date that was converted from old LastDate so time not valid)
                if (row.LastSavedDateTime.HasValue && row.LastSavedDateTime.Value != row.LastSavedDateTime.Value.ToStartOfDay())
                    str.AppendFormat("title='{0}' ", row.LastSavedDateTime.ToPharmacyTimeString());
                str.AppendFormat(">");

                if (row.LastSavedDateTime.HasValue)
                    str.AppendFormat(row.LastSavedDateTime.ToPharmacyDateString());
                else
                    str.AppendFormat("&nbsp;");
                str.AppendFormat("</td>");

                str.AppendFormat("<td class='LastQty'>{0}</td>", row.LastQuantity.HasValue ? row.LastQuantity.Value.ToString("0.####") : "&nbsp;"); // Last Qty column
                str.Append("<td>&nbsp;</td>");                      // Start date column
                str.Append("<td>&nbsp;</td>");                      // stop date column
                str.AppendFormat("<td>{0}</td>", row.RequestID);    // Request ID column
                str.Append("<td>&nbsp;</td>");                      // Attach notes column
                str.Append("<td>&nbsp;</td>");                      // POM column

                // Repeat dispensing column (if shown)
                if (viewSettings.RepeatDispensing)
                {
                    if (row.RepeatDispensing > 10)
                    {
                        int repeats = (row.RepeatDispensing - 10);
                        str.AppendFormat("<td align='center' >{0}</td>", repeats);
                    }
                    else
                    {
                        switch (row.RepeatDispensing)
                        {
                            case 5: str.Append("<td align='center' style='font-weight:bold;color:red;'>?</td>"); break;
                            case 4: str.Append("<td><img title='This is a Robot Rpt Prescription.' src='../../images/user/Pill - Robot.gif' WIDTH='16' HEIGHT='16' /></td>"); break;
                            case 3: str.Append("<td><img title='This is an out of use Robot Rpt Prescription.' src='../../images/user/Pill - Robot - Not in use.gif' WIDTH='16' HEIGHT='16' /></td>"); break;
                            case 2: str.Append("<td><img title='This is an out of use Rpt Prescription.' src='../../images/user/Pill - Not in use.gif' WIDTH='16' HEIGHT='16' /></td>"); break;
                            case 1: str.Append("<td><img title='This is a Rpt Prescription.' src='../../images/user/Pill - in use.gif' WIDTH='16' HEIGHT='16' /></td>"); break;
                            default: str.Append("<td>&nbsp;</td>"); break;
                        }
                    }
                }

                // PSO column (if shown)                
                if (viewSettings.PSO)
                {
                    if (row.PSO)
                    	str.Append("<td><img title='This is a Patient Specific Order.' src='../../images/user/person.gif' WIDTH='16' HEIGHT='16' /></td>");
                    else
                    	str.Append("<td>&nbsp;</td>");
                }

                str.Append("</tr>");
            }

            return str.ToString();
        }
        #endregion
    }
}
