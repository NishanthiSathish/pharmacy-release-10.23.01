//===========================================================================
//
//							   ICW_DispensingPMR.aspx.cs
//
//  Dispensing PMR grid. Is usually used in the same desktop as the Dispensing.aspx. 
//  Combined these two panes are used to display a patient PMR, order prescriptions, 
//  and dispense drugs.
//
//  Unlike the original dispensing PMR this new version does not have to have a full 
//  refresh to update the grid, instead it uses web methods (via their equivalent java script methods)
//      RefreshRow      - Refreshes a single row
//      FetchChildRows  - Fetches all child rows (merged prescriptions and\or dispensing replaces DispensingLoader.aspx, and PrescriptionMergeLoader.aspx 
//      RefreshGrid     - refresh whole grid
//  To the extent that OnLoad is only ever call on page refreash everything else is done on Web Method call.
// 
//  The code that generates the grid has been moved from DispensingPMR.vb to the pharmacy 'Dispensing PMR Layer' dll
//
//  To make dispensing PMR more human readable the row attributes between the old 
//  and new PMR are as follows
//      Old attribute           New Attribute       Description
//      i and D_ID              id                  Request id of row
//      c and pres_row          rowType             One of PN, Merged, Prescription, Dispensing
//          ic                  current             if current prescription 1 or 0
//          e                   episodeID           episode id
//          rt                  requestTypeID       Request type ID
//          chld                hasDispensings      if prescription has dispensing
//          csa                 canStopOrAmend      Can stop or amend
//          level               Level               level in grid 
//                                                      0 - prescriptions 
//                                                      1 - prescription as part of merge
//                                                      2 - Dispensing
//          p                   id_parent           parent prescription id (for merged prescriptions, and dispensing)
//          FullyResulted       FullyResulted       If row fully resulted (legacy item)
//          SB_{RequestStatus}  SB_{RequestStatus}  request status
//
//          t                                       Removed (table ID)
//          prod                                    Removed (product ID)    
//          ac                                      Removed (auto commit)
//          pct                                     Removed (creation type)
//          mergeCancelled      mergeCancelled      If mereged prescription cancelled (due to a prescription being cancelled)
//      
//  Usage:
//  ICW_DispensingPMR.aspx?SessionID=123&WindowID=3232&EpisodeID=4565&View=Current&StatusNoteFilterAction=include&StatusNoteFilter=
//
//  SessionID               - ICW session ID
//  WindowID                - ICW Desktop window id
//  EpisodeID               - Current episode
//  View                    - Current or History
//  StatusNoteFilterAction  - include or exclude 
//  StatusNoteFilter        - filter for state note
//  PSO                     - If in PSO mode
//  EnableEMMRestrictions   - If desktop parameter EnableEMMRestrictions is enabled
//  eMMAllowsPrescribing    - If EnableEMMRestrictions=true and patient is on emm ward (sp fPatientIsOneMMWard) then value is false 
//                            preventing adding, amending, or cancelling prescriptions.
//  
//	Modification History:
//	15Nov12 XN   TFS47487 Created
//  16Jan13 XN   TFS47487 updated RefreshGrid to only touch db if episode selected
//  18Jan13 XN   TFS46269 removed RequestStatus.* from PMR sps
//  21Jan13 XN   TFS53875 Removed StatusNotes as always need all request status 
//                        bit fields, as maybe used by Order Comms 
//  28Feb13 XN   TFS37264 Added PSO column
//  22Mar13 XN   TFS43495 Added enforcing eMM restrictions (read-only mode)
//  18Jul13 XN   TFS60657 Added delete key cause prescriptions to be cancelled
//                        Simplified the UpdateToolbarButtons js function for multi select
//                        Directly serialised the viewSettings to the aspx
//                        Disable multi select if in select episode mode  
//  19Jun13 XN   TFS65836 Got the SelectEpiosde option to work
//  14Aug13 XN   70138 Added support for FastRepeat prescription selection
//               See FastRepeatSearch.aspx 
//  11Sep13 XN   Update fix for 49908 so olny updates grid, and some javaside variables 
//               instead of doing full page postback to prevent script errors 72983
//               Also had to make changes to the fast repeat
//  10Apr14 TH   Ensure status filtering is correctly conveyed to order coms to limit buttons there (TFS 85597)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Services;
using System.Web.UI;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.dispensingpmrlayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.shared;
using Ascribe.Common; //10Apr14 TH Added

public partial class application_DispensingPMR_ICW_DispensingPMR : System.Web.UI.Page
{
    #region Member Variables
    protected int                       sessionID;
    protected int                       episodeID;
    protected DispensingPMRViewSettings viewSettings;
    protected string                    title                     = string.Empty;
    protected string                    mainToolbar               = string.Empty;
    protected string                    statusToolbar             = string.Empty;
//    protected string                    requestID_SelectAtStart   = string.Empty; 11Spet13 XN 72983 prevent script error by not doing complete post back
//    protected bool                      autoDispenseAtStart       = false;
    protected string                    strStatusNoteFilter_XML   = string.Empty;  //10Apr14 TH Added
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        // Initialise session
        sessionID = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession (sessionID);

        // Get selected episode 22Mar13 XN TFS43495
        // Note: This code and the viewSettings should be moved inside of the postback, and use json to decode on postback
        GENRTL10.StateRead stateRead = new GENRTL10.StateRead();
        episodeID = stateRead.GetKey(sessionID, "Episode");
        stateRead = null;

        // Get windows parameters
        // Note: This code and selected epiosde code above should be moved inside of the postback, and use json to decode on postback
        viewSettings.ViewMode            = Request["View"].EqualsNoCaseTrimEnd("Current") ? DispensingPMRViewMode.Current : DispensingPMRViewMode.History;
        viewSettings.RepeatDispensing    = BoolExtensions.PharmacyParse(Request["RepeatDispensing"] ?? "false");
        viewSettings.PSO 	         	 = BoolExtensions.PharmacyParse(Request["PSO"] ?? "false");
//        viewSettings.EnableEMMRestrictions=BoolExtensions.PharmacyParse(Request["EnableEMMRestrictions"] ?? "false") && Episode.IsOneMMWard(episodeID); // 22Mar13 XN TFS43495
        viewSettings.EnableEMMRestrictions=BoolExtensions.PharmacyParse(Request["EnableEMMRestrictions"] ?? "false");
        viewSettings.eMMAllowsPrescribing= GetIfeMMAllowsPrescribingFromServer(sessionID, episodeID, viewSettings.EnableEMMRestrictions);   // 11Spet13 XN 72983 prevent script error by not doing complete post back
        viewSettings.SelectEpisode       = BoolExtensions.PharmacyParse(Request["SelectEpisode"] ?? "false");
        viewSettings.AllowMultiSelect    = !viewSettings.SelectEpisode; // 60657 18Jul13 XN Disable multi select if in select episode mode

        viewSettings.PrescriptionRoutine = Request["PrescriptionRoutine"];
        if (string.IsNullOrEmpty(viewSettings.PrescriptionRoutine))
            viewSettings.PrescriptionRoutine = "PrescriptionByEpisodeForDispensing";
        viewSettings.PrescriptionRoutine = "p" + viewSettings.PrescriptionRoutine.Replace(" ", "_");

	strStatusNoteFilter_XML = StatusNoteToolbar.StatusNoteFilterXML(this.Request["StatusNoteFilter"], this.Request["StatusNoteFilterAction"]); //10Apr14 TH Added

        if (!this.IsPostBack)
        {
            // Get selected episode 22Mar13 XN TFS43495
//            GENRTL10.StateRead stateRead = new GENRTL10.StateRead();
//            episodeID = stateRead.GetKey(sessionID, "Episode");
//            stateRead = null;

            // Generate main toolbar
            ToolMenu toolMenu = new ToolMenu();
            toolMenu.LoadByWindowID(int.Parse(Request["WindowID"]));
            mainToolbar = GenerateToolBar(toolMenu);

            // Get page title
            if (toolMenu.Any())
                this.title = toolMenu.First().WindowDescription;

            // Generate status note toolbar
            string statusNoteFilterAction = Request["StatusNoteFilterAction"] ?? string.Empty;
            string statusNoteFilter       = Request["StatusNoteFilter"]       ?? string.Empty;
            if (!(statusNoteFilterAction.EqualsNoCaseTrimEnd("include") && string.IsNullOrEmpty(statusNoteFilter))) 
            {
                IEnumerable<RequestTypeStatusNoteRow> requestTypeStatusNotes = RequestTypeStatusNote.GetForDispensingPMR();
                statusToolbar = GenerateStatusToolBar(requestTypeStatusNotes, statusNoteFilterAction, statusNoteFilter);
            }
            panStatusButtonsToolbar.Visible = !string.IsNullOrEmpty(statusToolbar);

            //  11Spet13 XN 72983 prevent script error by not doing complete post back
            //// If prescription is stored in the DB session chache then ensure it is disepnsed at startup.
            //// Part of Fast Repeat
            //requestID_SelectAtStart = PharmacyDataCache.GetFromSession("Prescription") as string;
            //autoDispenseAtStart     = (PharmacyDataCache.GetFromSession("AutoDispense") as bool?) ?? false;
            //
            //PharmacyDataCache.RemoveFromSession("Prescription");
            //PharmacyDataCache.RemoveFromSession("AutoDispense");
        }

        //this.Page.ClientScript.RegisterStartupScript(this.GetType(), "StartupScript", "Sys.Application.add_load(function() { form_onload(); });", true);
    }

    #region Web Methods
    /// <summary>Returns the dispensing grid HTML rows for the patient</summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="episodeID">An episode ID for patient</param>
    /// <param name="viewSettings">view settings</param>
    /// <returns>HTML rows</returns>
    [WebMethod]
    static public string RefreshGrid(int sessionID, int episodeID, DispensingPMRViewSettings viewSettings)
    {
        string html = string .Empty;

        if (viewSettings.SelectEpisode || episodeID != -1)
        {
            SessionInfo.InitialiseSession(sessionID);
            DispensingPMRPrescriptions prescriptions = new DispensingPMRPrescriptions();
            html = prescriptions.GetHTMLPrescriptionRows(episodeID, null, viewSettings);
        }

        return html;
    }

    /// <summary>Gets dispensing and/or merged prescription for given parent</summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="requestID_Prescription">Parent prescription</param>
    /// <param name="rowType">Row type</param>
    /// <param name="viewSettings">view settings</param>
    [WebMethod]
    static public string FetchChildRows(int sessionID, int requestID_Parent, DispensingPMRRowType rowType, DispensingPMRViewSettings viewSettings)
    {
        SessionInfo.InitialiseSession(sessionID);

        string prescriptionRows = string.Empty;
        string dispensingRows   = string.Empty;

        // Get merged prescription
        if (rowType == DispensingPMRRowType.Merged)
        {
            DispensingPMRPrescriptions prescriptions = new DispensingPMRPrescriptions();
            prescriptionRows = prescriptions.GetHTMLMergedPrescriptionRows(requestID_Parent, null, viewSettings);
        }

        // Get dispensing
        DispensingPMRDispensings dispensings = new DispensingPMRDispensings();
        dispensingRows = dispensings.GetHTMLRows(requestID_Parent, null, viewSettings);

        return dispensingRows + prescriptionRows;
    }

    /// <summary>Refresh a single row</summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="requestID_Parent">parent prescription (for dispensing\merged prescriptions or null</param>
    /// <param name="requestID">row to update</param>
    /// <param name="rowType">Row type</param>
    /// <param name="viewSettings">view settings</param>
    /// <returns>HTML row</returns>
    [WebMethod]
    static public string RefreshRow(int sessionID, int? requestID_Parent, int requestID, DispensingPMRRowType rowType, DispensingPMRViewSettings viewSettings)
    {
        SessionInfo.InitialiseSession(sessionID);

        DispensingPMRPrescriptions prescriptions;
        DispensingPMRDispensings   dispensings;

        switch (rowType)
        {
        case DispensingPMRRowType.Dispensing:
            dispensings = new DispensingPMRDispensings();
            return dispensings.GetHTMLRows(requestID_Parent.Value, requestID, viewSettings);

        default:
            prescriptions = new DispensingPMRPrescriptions();
            if (requestID_Parent.HasValue)
                return prescriptions.GetHTMLMergedPrescriptionRows(requestID_Parent.Value, requestID, viewSettings);
            else
                return prescriptions.GetHTMLPrescriptionRows(null, requestID, viewSettings);
        }
    }

    /// <summary>
    /// Called when row selected in episode select mode
    /// Saves selected episode and entity to session state
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="episodeID">Episode to save</param>
    [WebMethod]
    public static void SaveSelectedEpisodeToState(int sessionID, int episodeID)
    {
        SessionInfo.InitialiseSession(sessionID);
        
        GENRTL10.State state = new GENRTL10.State();
        state.SetKey(sessionID, "Episode", episodeID);
        state.SetKey(sessionID, "Entity",  Episode.GetEntityID(episodeID));
    }
    
    /// <summary>
    /// Called to determin if user is allowed to create, amend, or stop a presctipion
    /// based on setting EnableEMMRestrictions and on eMM ward
    /// 11Spet13 XN 72983 prevent script error by not doing complete post back
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="episodeID">Episode ID</param>
    /// <param name="enableEMMRestrictions">If emm rescritctions enabled</param>
    [WebMethod]
    public static bool GetIfeMMAllowsPrescribingFromServer(int sessionID, int episodeID, bool enableEMMRestrictions)
    {
        SessionInfo.InitialiseSession(sessionID);
        return !(enableEMMRestrictions && Episode.IsOneMMWard(episodeID));
    }
    #endregion

    #region Protected Methods
    /// <summary>Builds up the main toolbar</summary>
    /// <param name="toolMenu">tool menu to build</param>
    /// <returns>tool menu as string</returns>
    protected string GenerateToolBar(ToolMenu toolMenu)
    {
        StringBuilder toolbar = new StringBuilder();
        foreach (ToolMenuRow toolMenuRow in toolMenu)
        {
            // Get button image
            string image = string.Empty;
            if (!string.IsNullOrEmpty(toolMenuRow.GetFullButtonImagePath()))
                image = toolMenuRow.GetFullButtonImagePath();

            // Get button on click event
            string onclick = string.Empty;
            if (!string.IsNullOrEmpty(toolMenuRow.EventName))
                onclick = string.Format("onclick='btnToolBar_onclick(\"{0}\",\"{1}\",{2})'", toolMenuRow.EventName, toolMenuRow.ButtonData, toolMenuRow.WindowID);

            // get button text
            string description = toolMenuRow.Description;
            if (!string.IsNullOrEmpty(toolMenuRow.HotKey))
            {
                // Underline the hot key
                string[] val = description.Split(new string[] { toolMenuRow.HotKey }, 2, StringSplitOptions.None);
                if (val.Length == 2)
                    description = string.Format("{0}<u>{1}</u>{2}", val[0], toolMenuRow.HotKey, val[1]);
            }

            // Build the button
            toolbar.AppendFormat("<button id='{0}' class='ToolButton ToolbarButton' disabled tabindex='-1' hideFocus {1} accesskey='{2}'><img class='ToolImage ToolbarButtomImage' src=\"{3}\" tabindex='-1' unselectable='on' title='{4}' />&nbsp;{5}&nbsp;</button>",
                                    toolMenuRow.EventName,
                                    onclick, 
                                    toolMenuRow.HotKey, 
                                    image,
                                    toolMenuRow.Detail.XMLEscape(),
                                    description);
        }


        return toolbar.ToString();
    }

    /// <summary>Build status toolbar</summary>
    /// <param name="statusNotes">Status notes</param>
    /// <param name="statusNoteFilterAction">filter action</param>
    /// <param name="statusNoteFilter">filter</param>
    /// <returns>return status note toolbar</returns>
    private string GenerateStatusToolBar(IEnumerable<RequestTypeStatusNoteRow> statusNotes, string statusNoteFilterAction, string statusNoteFilter)
    {
        // Get list of status notes to display
        HashSet<string> statusNoteFilterList = new HashSet<string>();
        if (!string.IsNullOrEmpty(statusNoteFilter))
            statusNoteFilterList = new HashSet<string>(statusNoteFilter.Split(new []{ ',' }, StringSplitOptions.RemoveEmptyEntries).Select(s => s.Trim().ToLower()));
        if (statusNoteFilterAction.EqualsNoCaseTrimEnd("include"))
            statusNotes = statusNotes.Where(s => statusNoteFilterList.Contains(s.NoteType_Description.ToLower()));
        else
            statusNotes = statusNotes.Where(s => !statusNoteFilterList.Contains(s.NoteType_Description.ToLower()));

        // Group by names (as will be 1 for each request type) and order
        var statusNoteByNoteType = statusNotes.GroupBy(sn => sn.NoteType_Description);

        StringBuilder toolbar = new StringBuilder();
        foreach (var grouped_sn in statusNoteByNoteType)
        {
            // Get the first status note row in the group (as should be all the same)
            RequestTypeStatusNoteRow sn = grouped_sn.OrderBy(r => r.RequestTypeStatusNoteID).First();
		    bool isStatusButton = sn.TypeOfNote == TypeOfNoteType.Status;

            // Create button
            toolbar.Append("<button class='ToolButton ToolbarButton' disabled tabindex='-1' hideFocus onclick='NoteTypeToggle(this);'");
            toolbar.AppendFormat("ApplyVerb='{0}' ",                       sn.ApplyVerb);
            toolbar.AppendFormat("DeactivateVerb='{0}' ",                  sn.DeactivateVerb);
            toolbar.AppendFormat("notetypeid='{0}' ",                      sn.NoteTypeID.ToString());
            toolbar.AppendFormat("requestStatusRowAttr='SB_{0}' ",         sn.NoteType_Description.Replace(" ", "_x0020_"));                 
            toolbar.AppendFormat("requesttypeids=',{0},' ",                grouped_sn.Select(s => s.RequestTypeID).ToCSVString(","));   // CSV list of request types Ids (has coma at start and end so easy to search)
            toolbar.AppendFormat("isStatusButton='{0}' ", 		   		   isStatusButton.ToOneZeorString());	
            toolbar.Append(">");

            // Add button image, and text
            toolbar.AppendFormat("<img id='imgStatusNote' class='ToolImage ToolbarButtomImage' src=\"../../images/ocs/{0}\" tabindex='-1' unselectable='on' />", isStatusButton ? "checkbox.gif" : "stamp.gif");
            toolbar.AppendFormat("&nbsp;<span id='ButtonText' style=''>{0}</span>", sn.ApplyVerb);

            toolbar.Append("</button>");
        }

        return toolbar.ToString();
    }
    #endregion
}
