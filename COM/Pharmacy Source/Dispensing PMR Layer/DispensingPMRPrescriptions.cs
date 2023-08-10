//===========================================================================
//
//					    DispensingPMRPrescriptions.cs
//
//  Class used to load and convert prescription, into HTML rows for display
//  in the dispensing PMR. The HTML returned will be in the from
//     {tr id='dispensing id' hasDispensings='...' canStopOrAmend='...' level='{3}' episodeID='...' requestTypeID='...' rowType='PN/Merged/Prescription' current='...' id_parent='...' {request status bit fields prefixed with SB_} FullyResulted='...' }
//         {td}+{/td}
//         {td}Description{/td}
//         {td}Last dispensing date{/td}
//         {tb}rxReason icon{/td}
//         {td}start date{/td}
//         {td}stop date{/td}
//         {td}RequestID{/td}
//         {td}attach note or dss warnings{/td}
//         {td}Patient Own icon{/td}
//         {td}Repeat dispensing column if shown{/td}
//     {/tr}
//
//  The class uses sp pPrescriptionByEpisodeForDispensing to load data for the 
//  main grid, or pPrescriptionListByMergedPrescription for merged prescriptions.
//
//  After calling the sp the method will then load relavent RequestStatus columns
//  this is a combination of the csv list of status notes in DispensingPMRViewSettings.StatusNotes
//  and extra columns required by ConvertToHTMLRows
//  If this method requires any new columns then adde them to GetAllRequestStatusColumns.
//
//  Usage:
//  To load all prescriptions for a patient, though asks for an episode id, actually 
//  loads all prescriptions for all episodes.
//  DispensingPMRViewSettings viewSettings = new DispensingPMRViewSettings();
//  DispensingPMRDispensings.GetHTMLPrescriptionRows(episodeID, null, viewSettings);
//
//  To all prescriptions under a merged prescription
//  DispensingPMRViewSettings viewSettings = new DispensingPMRViewSettings();
//  DispensingPMRDispensings.GetHTMLMergedPrescriptionRows(requestID_WPrescriptionMerge, null, viewSettings);
//
//	Modification History:
//  15Nov12 XN  TFS47487 Replace to improve speed of old DispensingPMR
//  16Jan13 XN  TFS47487 Minor HTML output issues and fixed the is 'current' attr
//                       Prevent duplicate rows (extra check)
//  17Jan13 XN  46269    Add only loading specific columns from RequestStatus,
//                       rather than using RequestStatus.*
//  21Jan13 XN  53875    Have to always return all RequestStatus bit fields, 
//                       as OrderComms might use them in some way
//  28Feb13 XN  37264    Added PSO column
//  22Mar13 XN  38889    Changed text of cancelled linked prescriptions (to include expired)
//  01Dec15 XN  136786   Added support for better attach note icon for merge prescription
//  09Dec15 TH  127949   When split dose labels have differeing repeats signal this on the rx with ??
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.dispensingpmrlayer
{
    /// <summary>Represents a record from the pPrescriptionByEpisodeForDispensing or pPrescriptionListByMergedPrescription sps</summary>
    public class DispensingPMRPrescriptionsRow : BaseRow
    {
        internal RequestStatusRow RequestStatusRow { get; set; }

        public int       RequestID                  { get { return FieldToInt(RawRow["RequestID"]).Value;                                          } }
        public string    Description                { get { return FieldToStr(RawRow["Description"]);                                              } }
        public DateTime  StartDate                  { get { return FieldToDateTime(RawRow["StartDate"]).Value;                                     } }
        public DateTime? StopDate                   { get { return FieldToDateTime(RawRow["StopDate"]);                                            } }
        public DateTime? LastDispensingDateTime     { get { return FieldToDateTime(RawRow["LastDispensingDate"]);                                  } } 
        public bool      MergePrescriptionCancelled { get { return FieldToBoolean(RawRow["MergePrescriptionCancelled"], false).Value;              } }
        public int       RepeatDispensing           { get { return FieldToInt(RawRow["RptDisp"]).Value;                                            } }
        public string    RxReason                   { get { return FieldToStr(RawRow["RxReason"], false, string.Empty);                            } }
        public bool      CanStopOrAmend             { get { return FieldToBoolean(RawRow["CanStopOrAmend"], false) ?? false;                       } }
        public string    DSSAlertTypes              { get { return FieldToStr(RawRow["DSSAlertTypes"], false, string.Empty);                       } }
        public int?      PrescriptionCreationTypeID { get { return FieldToInt(RawRow["PrescriptionCreationTypeID"]);                               } }
        public bool      HasChildAttchedNotes       { get { return this.RawRow.Table.Columns.Contains("HasChildAttchedNotes") ? FieldToBoolean(RawRow["HasChildAttchedNotes"]) ?? false : false; } } // 01Dec15 XN 136786 added

        public bool      HasDispensings             { get { return LastDispensingDateTime.HasValue; } }    

        // Following are read from RequestStatus 
        // IF YOU ADD PROPERTIES TO THIS SECTON THEN UPDATE METHOD GetAllRequestStatusColumns
        public int       RequestTypeID              { get { return RequestStatusRow.RequestTypeID;                                          } }
        public string    RequestType_Description    { get { return FieldToStr(RequestStatusRow.RawRow["RequestType__Description"]);         } }
        public int       EpisodeID                  { get { return FieldToInt(RequestStatusRow.RawRow["EpisodeOrder__EpisodeID"]).Value;    } }
        public bool      RequestCancellation        { get { return RequestStatusRow.GetStatus("Request Cancellation");                      } }
        public bool      PatientOwn                 { get { return RequestStatusRow.GetStatus("Patient Own");                               } }
        public bool      AttachedNote               { get { return RequestStatusRow.GetStatus("Attached Note");                             } }
        public bool      Complete                   { get { return RequestStatusRow.GetStatus("Complete");                                  } }

        /// <summary>Get the creation type description for the row</summary>
        public string  PrescriptionCreationType_Description 
        { 
            get      
            {
                ICWTypeData?  prescriptionCreationType = null;

                int? prescriptionCreationTypeID = PrescriptionCreationTypeID;
                if (prescriptionCreationTypeID.HasValue)
                    prescriptionCreationType = ICWTypes.GetTypeByRequestTypeID(ICWType.PrescriptionCreationType, prescriptionCreationTypeID.Value);

                return prescriptionCreationType.HasValue ? prescriptionCreationType.Value.Description : string.Empty;
            }
        }
    }

    /// <summary>Loads data from pPrescriptionByEpisodeForDispensing or pPrescriptionListByMergedPrescription sps</summary>
    public class DispensingPMRPrescriptions : BaseTable2<DispensingPMRPrescriptionsRow, BaseColumnInfo>
    {
        RequestStatus requestStatus = new RequestStatus(); 

        public DispensingPMRPrescriptions() { }

        #region Public Methods
        /// <summary>
        /// Loads all prescriptions for a patient (for all episode) given an episode, or loads a single prescription
        /// See file header for html layout     
        /// Uses sp defined in viewSettings.PrescriptionRoutine which is normally pPrescriptionByEpisodeForDispensing
        /// If the row is no longer loaded by sp (e.g. been cancelled) method will then return "remove".
        /// </summary>
        /// <param name="episodeID">Patient episode (optional)</param>
        /// <param name="requestID">Request to load (optional)</param>
        /// <param name="viewSettings"></param>
        /// <returns>HTML rows</returns>
        public string GetHTMLPrescriptionRows(int? episodeID, int? requestID, DispensingPMRViewSettings viewSettings)
        {
            // Load in the data
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID                                  ));
            parameters.Add(new SqlParameter("@EpisodeID",        (object)episodeID ?? DBNull.Value                      ));
            parameters.Add(new SqlParameter("@RequestID",        (object)requestID ?? DBNull.Value                      ));
            parameters.Add(new SqlParameter("@CurrentOnly",      viewSettings.ViewMode == DispensingPMRViewMode.Current ));
            LoadBySP(viewSettings.PrescriptionRoutine, parameters);

            // Load request status 17Jan13 XN  46269 
            if (this.Any())
                requestStatus.LoadSpecificColumnsByRequestIDs(this.GetAllRequiredRequestStatusColumns(), this.Select(r => r.RequestID));

            // If specific row selected and does not exist the say it's been removed
            if (requestID.HasValue && !this.Any())
                return "remove";

            // If just updating 1 row ensure only have 1 row in list incase sql not written correctly
            if (requestID.HasValue)
                this.RemoveAll(r => r.RequestID != requestID.Value);

            // convert rows to HTML
            return ConvertToHTMLRows(0, null, viewSettings);
        }

        /// <summary>
        /// Loads all prescriptions that are children of a merged prescription, or loads a single merged prescription row
        /// Uses sp pPrescriptionListByMergedPrescription
        /// See file header for html layout     
        /// If the row is no longer loaded by the sp (e.g. been cancelled) method will then return "remove".
        /// </summary>
        /// <param name="episodeID">Patient episode (optional)</param>
        /// <param name="requestID">Request to load (optional)</param>
        /// <param name="viewSettings"></param>
        /// <returns>HTML rows</returns>
        public string GetHTMLMergedPrescriptionRows(int requestID_WPrescriptionMerge, int? requestID, DispensingPMRViewSettings viewSettings)
        {
            // Load in the data
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@CurrentSessionID",              SessionInfo.SessionID                         ));
            parameters.Add(new SqlParameter("@RequestID_WPrescriptionMerge",  requestID_WPrescriptionMerge                  ));
            parameters.Add(new SqlParameter("@RequestID",                     (object)requestID            ?? DBNull.Value  ));
            parameters.Add(new SqlParameter("@CurrentOnly",                   viewSettings.ViewMode == DispensingPMRViewMode.Current));   
            LoadBySP("pPrescriptionListByMergedPrescription", parameters);

            // Load request status 17Jan13 XN  46269 
            if (this.Any())
                requestStatus.LoadSpecificColumnsByRequestIDs(this.GetAllRequiredRequestStatusColumns(), this.Select(r => r.RequestID));

            // If specific row selected and does not exist the say it's been removed
            if (requestID.HasValue && !this.Any())
                return "remove";

            // If just updating 1 row ensure only have 1 row in list incase sql not written correctly
            if (requestID.HasValue)
                this.RemoveAll(r => r.RequestID != requestID.Value);

            // convert rows to HTML
            return ConvertToHTMLRows(1, requestID_WPrescriptionMerge, viewSettings);
        }

        /// <summary>Extended base class function to set the DispensingPMRPrescriptionsRow.RequestStatusRow property 17Jan13 XN  46269 </summary>
        /// <param name="index">Row index (of loaded data).</param>
        /// <returns>data row</returns>
        public override DispensingPMRPrescriptionsRow this[int index]
        {
            get
            {
                DispensingPMRPrescriptionsRow row = base[index];
                row.RequestStatusRow = requestStatus.FindByRequestID(row.RequestID);
                return row;
            }
        }
        #endregion

        #region Protected Methods
        /// <summary>
        /// Returns a list of all RequestStatus columns needed by ConvertToHTMLRows, 
        /// Basically any column that is a bit, plus RequestID, RequestType__RequestTypeID, RequestType__Description, and EpisodeOrder__EpisodeID
        /// This data is cached in the web cache
        /// 17Jan13 XN  46269, 53875 
        /// </summary>
        /// <returns>all RequestStatus columns needed by ConvertToHTMLRows</returns>
        protected IEnumerable<string> GetAllRequiredRequestStatusColumns()
        {
            string cacheName = this.GetType().FullName + ".GetAllRequiredRequestStatusColumns";

            HashSet<string> requestStatusColumns = (HashSet<string>)PharmacyDataCache.GetFromCache(cacheName);
            if (requestStatusColumns == null)
            {
                IEnumerable<TableInfoRow> columnInfo = RequestStatus.GetColumnInfo().tableInfo.Where(c => c.Type.EqualsNoCase("tinyint") && !c.IsNullable);   
                requestStatusColumns = new HashSet<string>(columnInfo.Select(c => "[" + c.ColumnName + "]"));

                requestStatusColumns.Add("[RequestID]");
                requestStatusColumns.Add("[RequestType__RequestTypeID]");
                requestStatusColumns.Add("[RequestType__Description]");
                requestStatusColumns.Add("[EpisodeOrder__EpisodeID]");

                PharmacyDataCache.SaveToCache(cacheName, requestStatusColumns);
            }

            return requestStatusColumns;
        }

        /// <summary>Converts the prescriptions to html rows (see file header for details)</summary>
        /// <param name="requestID_Parent">ID of the parent prescription</param>
        /// <param name="viewSettings">View settings </param>
        /// <returns>HTML rows</returns>
        protected string ConvertToHTMLRows(int level, int? requestID_Parent, DispensingPMRViewSettings viewSettings)
        {
            StringBuilder str  = new StringBuilder();
            StringBuilder temp = new StringBuilder();
            HashSet<int> requestIDsAlreadyDone = new HashSet<int>();

            DateTime now        = DateTime.Now;
            DateTime today      = DateTime.Now.ToStartOfDay();
            DateTime yesterday  = today.AddDays(-1.0);

            if (!this.Any())
                return string.Empty;

            // Get list of bit field request status columns, and create list of attribute names suitable for HTML
            List<DataColumn> requestStatusColumns     = requestStatus.Table.Columns.OfType<DataColumn>().Where(c => c.DataType == typeof(Byte)).ToList();
            List<string>     requestStatusColHTMLName = requestStatusColumns.Select(c => c.ColumnName.Replace(" ", "_x0020_").TrimStart('[').TrimEnd('[')).ToList();

            foreach (var row in this)
            {
                // If already done this item then skip (with good SQL this should not happen but we are not all Adams!!!)
                if (!requestIDsAlreadyDone.Add(row.RequestID))
                    continue;

                // Start html row
                str.AppendFormat("<tr id='{0}' hasDispensings='{1}' canStopOrAmend='{2}' level='{3}' episodeID='{4}' requestTypeID='{5}' mergeCancelled='{6}' ", row.RequestID, 
                                                                                                                                             row.HasDispensings, 
                                                                                                                                             row.CanStopOrAmend.ToOneZeorString(), 
                                                                                                                                             level, 
                                                                                                                                             row.EpisodeID,  
                                                                                                                                             row.RequestTypeID,
                                                                                                                                             row.MergePrescriptionCancelled.ToOneZeorString());
                // Set row type
                if (row.RequestType_Description == "PN Prescription")
                    str.AppendFormat("rowType='{0}' ", DispensingPMRRowType.PN);
                else if (row.RequestType_Description == "Prescription Merge")
                    str.AppendFormat("rowType='{0}' ", DispensingPMRRowType.Merged);
                else
                    str.AppendFormat("rowType='{0}' ", DispensingPMRRowType.Prescription);

                // Set if row is current
                bool current = (row.StopDate == null || row.StopDate.Value > now || row.RequestType_Description == "Product Order") && !row.RequestCancellation;
                str.AppendFormat("current='{0}' ", current.ToOneZeorString());

                // set parent it (for merged prescriptions)
                if (requestID_Parent.HasValue)
                    str.AppendFormat("id_parent='{0}' ", requestID_Parent.Value);

                // add all bit request fields with field name prefixed with SB_
                for (int c = 0; c < requestStatusColumns.Count; c++)
                {
                    bool status = row.RequestStatusRow.GetStatus(requestStatusColumns[c].ColumnName);
                    str.AppendFormat("SB_{0}='{1}' ", requestStatusColHTMLName[c], status.ToOneZeorString());
                }

                // For legacy reasons add RequestStatus.Completed as FullyResulted
                str.AppendFormat("FullyResulted='{0}' ", row.Complete.ToOneZeorString());

                str.Append(">");

                // If dispensing or merged the show + icon
                str.Append("<td class='x' onclick='x_clk(this);'>");
                if (row.HasDispensings || row.RequestType_Description == "Prescription Merge")
                    str.Append("<img src='../../images/grid/imp_open.gif' width='15' />");
                else
                    str.Append("&nbsp;");
                str.Append("</td>");

                // Description  column images
                str.Append("<td colspan='7'>");
                for (int c=0; c < level; c++)
                    str.Append("&nbsp;&nbsp;&nbsp;");                
                if (level == 1)
                    str.Append("<img title='This is part of a merged prescription.' src='../../images/user/Arrows.gif' WIDTH='16' HEIGHT='16' />");
                string imageTitle = ICWWorklistImages.GetImageTitleByClass("Request", row.RequestType_Description);
                string image      = ICWWorklistImages.GetImageByClass    ("Request", row.RequestType_Description, string.Empty, row.PrescriptionCreationType_Description);
                if (!string.IsNullOrEmpty(image))
                    str.AppendFormat("<img title='{0}' src='../../images/ocs/{1}' WIDTH='16' HEIGHT='16' />", imageTitle, image);                

                // Description  column images
                if (row.MergePrescriptionCancelled)
                    str.Append("<span style='text-decoration: line-through;'>");
                str.Append(row.Description.RemoveNewLinesAndXMLEscape());
                if (row.MergePrescriptionCancelled)
                    str.AppendFormat("</span><br />(Items on this merged prescription have {0}been cancelled. Please re-link items before dispensing)", viewSettings.ViewMode == DispensingPMRViewMode.Current ? "expired, or " : string.Empty);
                str.Append("</td>");

                // Last dispensing date column
                DateTime? lastDispensingDate = row.LastDispensingDateTime;
                str.AppendFormat("<td ");
                if (lastDispensingDate.HasValue && lastDispensingDate.Value >= today)
                    str.AppendFormat("class='HighlightDate1' ");
                else if (lastDispensingDate.HasValue && lastDispensingDate.Value >= yesterday)
                    str.AppendFormat("class='HighlightDate2' ");

                // If have last dispensing time then display time as tooltip 
                // (as long a not at midnight as this is probably a date that was converted from old LastDate so time not valid)
                if (lastDispensingDate.HasValue && lastDispensingDate.Value != lastDispensingDate.Value.ToStartOfDay())
                    str.AppendFormat("title='{0}' ", lastDispensingDate.ToPharmacyTimeString());
                str.AppendFormat(">");

                if (lastDispensingDate.HasValue)
                    str.AppendFormat(lastDispensingDate.ToPharmacyDateString());
                else
                    str.AppendFormat("&nbsp;");
                str.AppendFormat("</td>");

                // RxReason if present column
                if (string.IsNullOrEmpty(row.RxReason))
                    str.Append("<td>&nbsp;</td>");
                else
                    str.AppendFormat("<td align='center'><img title =\"{0}\" src='../../images/user/rxReason.gif' width='15' height='15' align='center' /></td>", row.RxReason.RemoveNewLinesAndXMLEscape());

                str.AppendFormat("<td style='padding-right:5px;'>{0}</td>", row.StartDate.ToPharmacyDateString());
                str.AppendFormat("<td style='padding-right:5px;'>{0}</td>", row.StopDate.HasValue ? row.StopDate.ToPharmacyDateString() : "&nbsp;");
                str.AppendFormat("<td>{0}</td>", row.RequestID);

                // Attach note, and dss warnings icons column
                temp.Length = 0;

                // 01Dec15 XN 136786 added better attached notes
                if (row.AttachedNote && row.HasChildAttchedNotes)
                    temp.Append("<img title='This item and linked items have notes attached' src='../../images/ocs/classAttachedNoteDispPMRLink.gif' style='cursor:hand' onclick='attachedNoteIcon_onclick();' />");
                else if (row.AttachedNote && !row.HasChildAttchedNotes)
                    temp.Append("<img title='This item has notes attached.' src='../../images/ocs/classAttachedNote.gif' style='cursor:hand' onclick='attachedNoteIcon_onclick();' />");
                else if (row.HasChildAttchedNotes)
                    temp.Append("<img title='Linked items have notes attached.' src='../../images/ocs/classAttachedNoteDispPMRArrow.gif' />");

                // Duplication and range check warnings can be assigned two possible warning types values
                // so need to convert this to single warning values (for switch statement below)
                int[] DSSAlertTypes = row.DSSAlertTypes.Split(new [] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(s => int.Parse(s)).ToArray();
                for (int c = 0; c < DSSAlertTypes.Length; c++)
                {
                    switch (DSSAlertTypes[c])
                    {
                    case 6: DSSAlertTypes[c] = 3; break;    // Duplication
                    case 7: DSSAlertTypes[c] = 5; break;    // Range check
                    }
                }

                foreach (int alertType in DSSAlertTypes.Distinct()) // Distinct so don't get duplication caused by switch statement above
                {
                    switch (alertType)
                    {                    
                    case 1: temp.AppendFormat("<img title='Allergies have been overridden for this item' src='../../images/ocs/allergyOverride.gif' style='cursor:hand' onclick='DoAction_ViewDSSOverrides({0});' />",        row.RequestID); break;  // Allergy
                    case 2: temp.AppendFormat("<img title='Banned Routes have been overridden for this item' src='../../images/ocs/bannedRouteOverride.gif' style='cursor:hand' onclick='DoAction_ViewDSSOverrides({0});' />",row.RequestID); break;  // BannedRoute
                    case 3: temp.AppendFormat("<img title='Duplications have been overridden for this item' src='../../images/ocs/duplicationOverride.gif' style='cursor:hand' onclick='DoAction_ViewDSSOverrides({0});' />", row.RequestID); break;  // Duplication
                    case 4: temp.AppendFormat("<img title='Interactions have been overridden for this item' src='../../images/ocs/interactionOverride.gif' style='cursor:hand' onclick='DoAction_ViewDSSOverrides({0});' />", row.RequestID); break;  // Interaction
                    case 5: temp.AppendFormat("<img title='Range Checks have been overridden for this item' src='../../images/ocs/rangeCheckOverride.gif' style='cursor:hand' onclick='DoAction_ViewDSSOverrides({0});' />",  row.RequestID); break;  // RangeCheck
                    }
                }
                if (temp.Length == 0)
                    temp.Append("&nbsp;");
                str.AppendFormat("<td>{0}</td>", temp);

                // Patient own icon column
                if (row.PatientOwn)
                    str.AppendFormat("<td><img title='This item has Patients Own Medication Notes attached.' src='../../images/user/Note3.gif' WIDTH='16' HEIGHT='16' /></td>");
                else
                    str.Append("<td>&nbsp;</td>");

                // Repeat dispensing column (if shown)
                //int repeats;
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
                            case -1: str.Append("<td align='center' style='font-weight:bold;color:red;'>??</td>"); break;
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
                	str.Append("<td>&nbsp;</td>");

                str.Append("</tr>");
            }

            return str.ToString();
        }
        #endregion
    }
}
