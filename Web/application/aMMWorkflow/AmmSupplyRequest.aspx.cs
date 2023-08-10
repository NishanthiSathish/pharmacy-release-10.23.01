// -----------------------------------------------------------------------
// <copyright file="AmmSupplyRequest.aspx.cs" company="Emis Health">
//   Copyright (c) Emis Health Plc. All rights reserved.
// </copyright>
// <summary>
// Part of the Aseptic Manufacture Module and is used to display an AMM 
// supply request
//
// The form will take the user through the process of manufacturing a drug
// which will include selecting a shift, and ingredients, and take picture 
// of the compounded product via a web cam.
//
// If will be possible to determine which stage the user can perform operations
// by passing in the FromStage and ToStage which determines what the user can update.
//
// It is also possible to control which buttons are displayed in the toolbar via URL 
// parameter buttons were each char in the string represents an EnumDBCode,
// for ToolbarButtonType with | used as a separator
// E.g. P|NE will represents mean that the following tool bar buttons
// will be displayed
//   ViewRx {Separator} AttachNote ReportError
//
// The Labeling control can get into a funny state if displayed while doing a 
// post-back it will display abstract "UserControl not in live state" error.
// To get over this all toolbar buttons that do post-backs are disabled when the 
// labeling control is displayed done via viewSetting.IfPreventPostBack.
// Also all message box should use alert, or confirm, else will be displayed behind user control.
//
//  The page expects the following URL parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Site number
//  SiteId          
//  RequestID           - AMM Supply Request ID
//  FromStage           - User allowed to makes changes from this Stage 
//  ToStage             - User allowed to makes changes to this Stage 
//  buttons             - Buttons to display in the tool bar (see above)
//  mode                - mode to open form either view, edit, or copy
// 
//  Modification History:
//  02Jul15 XN Created 39882
//  01Jul16 XN 157210 PopulateRequestDetails: qty should always be shown
//  26Aug16 XN 161234 Added one click worksheet, and label printing, and show method option
//  26Aug16 XN 161288 Added info panel to second check
// </summary
// -----------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.manufacturinglayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;
using Telerik.Web.UI;
using _Shared;

public partial class application_aMMWorkflow_AmmSupplyRequest : System.Web.UI.Page
{
    #region Data Types
    /// <summary>Toolbar button types</summary>
    private enum ToolbarButtonType
    {
        /// <summary>Used when parsing buttons for invalid values</summary>
        None,

        /// <summary>View Prescription</summary>
        [EnumDBCode("P")]
        ViewRx,

        /// <summary>View Note History</summary>
        [EnumDBCode("H")]
        ViewHisotry,

        /// <summary>add note</summary>
        [EnumDBCode("N")]
        AttachNote,

        /// <summary>Report Error</summary>
        [EnumDBCode("E")]
        ReportError,

        /// <summary>Perform undo operation</summary>
        [EnumDBCode("Z")]
        Undo,

        /// <summary>Cancel whole supply request</summary>
        [EnumDBCode("S")]
        Cancel,

        /// <summary>Print worksheet</summary>
        [EnumDBCode("W")]
        PrintWorksheet,

        /// <summary>Print Label</summary>
        [EnumDBCode("L")]
        PrintLabel,

        /// <summary>Issue items</summary>
        [EnumDBCode("I")]
        Issue,

        /// <summary>Return</summary>
        [EnumDBCode("R")]
        Return,

        /// <summary>Item enquiry</summary>
        [EnumDBCode("4")]
        ItemEnquiry,

        /// <summary>Log Viewer 02Aug16 XN 159413</summary>
        [EnumDBCode("V")]
        LogViewer,

        /// <summary>Separator for buttons</summary>
        [EnumDBCode("|")]
        Separator
    }

    /// <summary>Aseptic supply request view settings (also used javascript side AmmSupplyRequest.js)</summary>
    public struct aMMSupplyRequestViewSettings 
    {
        /// <summary>The supplier request Id</summary>
        public int RequestId;

        /// <summary>The supplier request Id parent (used client side)</summary>
        public int RequestId_Parent;

        /// <summary>If the form should be readonly (based on input parameter and lock state)</summary>
        public bool ReadOnly;

        /// <summary>Gets or sets state from which supply request will be shown</summary>
        public aMMState? FromStage;
        
        /// <summary>Gets or sets state to which supply request will be shown</summary>
        public aMMState? ToStage;

        /// <summary>Application path</summary>
        public string ApplicationPath;

        /// <summary>selected drug (used client side)</summary>
        public string NSVCode;

        /// <summary>If undo is available (based purely if state is >= FromStage)</summary>
        public bool IfCanUndo;

        /// <summary>If stop is available (based on if not complete or cancelled)</summary>
        public bool IfCanStop;

        /// <summary>If it is possible to print the worksheet</summary>
        public bool IfCanPrintWorksheet;

        /// <summary>If the prescription has been cancelled or expired (main same state as read-only but with a few exceptions)</summary>
        public bool IsPrescriptionCancelled;

        /// <summary>Set on labeling mode to prevent post-back (as this causes issues with the dispensing ctrl)</summary>
        public bool IfPreventPostBack;

        /// <summary>If the active x control is enabled</summary>
        public bool isActiveXControlEnabled;

        public int? SessionId;

        public int? SiteId; 

        /// <summary>
        /// Determines if the state is editable
        /// based on if form is read only, if state is current state and if it is in range FromStage and ToStage
        /// </summary>
        /// <param name="stateToTest">State to test</param>
        /// <param name="currentState">Current state</param>
        /// <returns>If state is editable</returns>
        public bool IsStateEditable(aMMState stateToTest, aMMState currentState)
        {
            return !this.ReadOnly && !this.IsPrescriptionCancelled && stateToTest == currentState && stateToTest >= this.FromStage && stateToTest <= this.ToStage;
        }
    }
    #endregion

    #region Member Variables
    /// <summary>view settings</summary>
    protected aMMSupplyRequestViewSettings settings;

    /// <summary>AMM processor</summary>
    protected aMMProcessor processor;

    /// <summary>URL string token</summary>
    protected string URLtoken;
    #endregion

    #region Event handlers
    /// <summary>The page_ load.</summary>
    /// <param name="sender">The sender.</param>
    /// <param name="e">The e.</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);
        if (this.IsPostBack)
        {
            // Load setting for post back
            this.settings  = JsonConvert.DeserializeObject<aMMSupplyRequestViewSettings>(hfViewSettings.Value);            
            this.processor = aMMProcessor.Create(this.settings.RequestId);
        }
        else
        {
            // Get parameters
            this.settings = new aMMSupplyRequestViewSettings();
            this.settings.FromStage                 = ConvertExtensions.ChangeType<aMMState?>(this.Request["StageFrom"], null);
            this.settings.ToStage                   = ConvertExtensions.ChangeType<aMMState?>(this.Request["StageTo"],   null);
            this.settings.RequestId                 = ConvertExtensions.ChangeType<int>(this.Request["RequestID"]);
            this.settings.ReadOnly                  = (this.Request["mode"] ?? string.Empty).EqualsNoCase("view");
            this.settings.ApplicationPath           = this.Request["ApplicationPath"] ?? string.Empty;
            this.settings.isActiveXControlEnabled   = string.IsNullOrEmpty(Request["ActiveXControl"]) || Request["ActiveXControl"].EqualsNoCaseTrimEnd("Enable");

            string buttons = this.Request["AMMSupplyRequestButtons"];

            // Create processor
            this.processor = aMMProcessor.Create(this.settings.RequestId);

            // Set extra view settings
            this.settings.NSVCode          = this.processor.SupplyRequest.NSVCode;
            this.settings.RequestId_Parent = this.processor.Prescription.RequestID;
            this.settings.ReadOnly         = this.settings.ReadOnly || this.processor.SupplyRequest.IsCancelled();
			this.settings.IfCanStop		   = !this.settings.ReadOnly && !this.processor.SupplyRequest.IsComplete();
            this.settings.IsPrescriptionCancelled = (this.processor.Prescription.StopDate ?? DateTime.MaxValue) < DateTime.Now || this.processor.Prescription.IsCancelled;

            if (!this.settings.ReadOnly)
            {
                try
                {
                    this.processor.LockSupplyRequest();
                }
                catch(LockException ex)
                {
                    string msg = string.Format("This record is being edited by {0} on {1} your changes will not be saved", ex.GetLockerName(), ex.GetTerminal());
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "lockError", "alert('" + msg.JavaStringEscape() + "');", true);
                    this.settings.ReadOnly = true;
                }
            }

            // Populate form
            this.PopulateToolbar(buttons);
            this.patientBanner.Initalise(this.processor.SupplyRequest.EpisodeID);
            this.PopulateRequestDetails();

            // update stage boxes
            this.UpdateStageBoxes();
            for (var a = aMMState.WaitingScheduling; a < aMMState.Completed; a++)
            {
                (this.FindControl("lbStage" + (int)a) as Label).Text = aMMSetting.StateString(a);
            }

            ScriptManager.RegisterStartupScript(this, this.GetType(), "setScrollPos", "scrollToActiveStage();", true);

            // Check if formula is still active
            List<string> warnings = new List<string>();
            if (this.processor.Formula.Status != WManufacturingStatus.Approved && this.processor.SupplyRequest.State != aMMState.Completed && !this.processor.SupplyRequest.GetStatus("Request Cancellation"))
            {
                warnings.Add("The formula is no longer approved.");
            }

            // Check patient ward is valid
            var ward = Ward.GetByEpisode(this.processor.SupplyRequest.EpisodeID);
            if (ward == null || string.IsNullOrEmpty(ward.Code))
            {
                warnings.Add("Patient does not have valid ward with ward code");
            }
            if (ward != null && ward.OutOfUse)
            {
                warnings.Add("Patient is on a ward that is marked out of use");
            }

            // display warnings
            if (warnings.Any())
            {
                string script = string.Format("alert('{0}');", warnings.ToCSVString("\n").JavaStringEscape());
                ScriptManager.RegisterStartupScript(this, this.GetType(), "warning", script, true);
            }
        }


        // Deal with __postBack events
        string target = Request["__EVENTTARGET"];
        string args   = Request["__EVENTARGUMENT"];
        
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        switch (argParams[0])
        {
        case "MoveNextStage":
            this.Save_OnClick(this, null);
            break;
        case "Undo":
            if (this.settings.IfCanUndo)
            {
                this.MoveBackStage();
            }
            break;
        case "Cancelled":
            this.settings.ReadOnly  = true;
			this.settings.IfCanStop	= false;
            this.UpdateStageBoxes();
            break;
        case "Issue":
            this.CheckCanIssue();
            break;
        case "Return":
            this.CheckCanReturn();
            break;
        case "IssueConfirmed":
            if (this.processor.SupplyRequest.IssueState < aMMIssueState.IssuedIngredients)
                this.Issue(true, aMMIssueState.IssuedIngredients);
            else if (this.processor.SupplyRequest.IssueState < aMMIssueState.IssuedToPatient)
                this.Issue(true, aMMIssueState.IssuedToPatient);
            break;
        case "ReturnConfirmed":
            if (this.processor.SupplyRequest.IssueState == aMMIssueState.IssuedToPatient)
                this.Return(true, aMMIssueState.IssuedIngredients);
            else if (this.processor.SupplyRequest.IssueState >= aMMIssueState.IssuedIngredients)
                this.Return(true, aMMIssueState.None);
            break;
        case "PrintWorksheet":
            // Will either do a print or a reprint
            // If doing a print this section might be called twice if the formula has two possible layouts
            // As the work sheet is still on a network share rather than the db, reading the file has to be done client side
            if (this.processor.SupplyRequest.IfPrintedWorksheet)
            {
                string worksheet = PharmacyLabelReprint.GetLabelByAmmSupplyRequestAndType(this.processor.SupplyRequest.RequestID, PharmacyLabelReprintType.Worksheet);
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "loadAndPrint", string.Format("var worksheet = JavaStringUnescape('{0}'); reprintWorksheet(worksheet);", worksheet.JavaStringEscape(quotesToEscape: "'")), true);
				processor.PrintedWorksheet(reprint: true);
            }
            else
            {
                string worksheetSelected = string.Empty;
                if (argParams.Length > 1)
                    worksheetSelected = argParams[1];   // selected work sheet name
                else if (processor.Formula.NumberOfLayoutsAvaiable() > 1)
                {
                    // There are more than 1 possible layout so ask user which one they want to print
                    string script = string.Format("selectSheet({0});", processor.Formula.WFormulaID);
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "askSelectSheet", script, true);
                }
                else
                {
                    // Select the layout
                    worksheetSelected = processor.Formula.Layout().FirstOrDefault(l => !string.IsNullOrWhiteSpace(l));
                    if (string.IsNullOrWhiteSpace(worksheetSelected))
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "formulaWithoutWorksheets", "alert('Formula has no worksheets.');", true);
                }

                // layout selected so print 
                if (!string.IsNullOrWhiteSpace(worksheetSelected))
                {
                    string filename       = WLayout.GetFilenameBySiteNameAndApproved(SessionInfo.SiteID, worksheetSelected).Replace("\\", "\\\\");
                    string methodfilename = WFormula.GetByNSVCodeSiteAndApproved(processor.Product.NSVCode, SessionInfo.SiteID).GetMethodFilename().Replace("\\", "\\\\");
                    bool   createLabel    = this.processor.Label == null;
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "loadAndPrint", string.Format("loadAndPrint('{0}', '{1}', '{2}', {3});", filename, methodfilename, worksheetSelected, createLabel.ToString().ToLower()), true);
                }
            }
            break;    
        case "PrintedLabel":    // Called once a label is printed or reprinted will log the fact
            var mode    = argParams[1];
            var labelId = int.Parse(argParams[2]);
            if (mode == "P")
            {
                this.processor.SupplyRequest.RequestIdWLabel = int.Parse(hfWLabelId.Value);
                this.processor.ResyncLabel(this.processor.SupplyRequest.RequestIdWLabel.Value);
            }
            this.processor.PrintedLabel(reprint: mode == "R");
            break;    
        case "LogViewer":   // 02Aug16 XN  159413 Added trans log viewer
            PharmacyDisplayLogRows.GeneralSearchCriteria generalSettings = new PharmacyDisplayLogRows.GeneralSearchCriteria();
            generalSettings.pharmacyLog      = PharmacyLogType.Translog;
            generalSettings.fromDate         = this.processor.SupplyRequest.CreatedDate;
            generalSettings.toDate           = this.processor.SupplyRequest.IsComplete() ? this.processor.LastAMMStateChangeNote.CreatedDate : DateTime.Now;
            generalSettings.siteNumbers      = new [] { SessionInfo.SiteNumber };
            generalSettings.groupBy          = false;
            generalSettings.moneyDisplayType = MoneyDisplayType.Show;
            generalSettings.useLogDateTime   = true;
            PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.GeneralSearchCriteria",  JsonConvert.SerializeObject(generalSettings));

            PharmacyDisplayLogRows.TranslogSearchCriteria translogSetting = new PharmacyDisplayLogRows.TranslogSearchCriteria();
            translogSetting.prescritionNumber = new []{ this.processor.SupplyRequest.PrescriptionNumber.ToString(), this.processor.SupplyRequest.BatchNumber };
            PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.LogSearchCriteria",  JsonConvert.SerializeObject(translogSetting));

            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "showLogViewer", string.Format("window.showModalDialog('../PharmacyLogViewer/DisplayLogRows.aspx?SessionID={0}&SiteID={1}', '', 'dialogHeight:735px; dialogWidth:865px; status:off; center:Yes');", SessionInfo.SessionID, SessionInfo.SiteID), true);
            break;
        case "AddIng": // Added ingredients so update expiry
            this.processor.UpdateSupplyRequestExpiry(save: true);
            break;
        }
    }

    /// <summary>
    /// Called before pre-rendering
    /// Save viewSettings
    /// </summary>
    /// <param name="sender">Event sender</param>
    /// <param name="e">Event args</param>
    protected void Page_PreRender(object sender, EventArgs e)
    {
        this.PopulateRequestDetails();
        this.PopulateWaitingScheduling();
        this.PopulateWaitingProductionTray();
        this.PopulateReadyToAssemble();
        this.PopulateReadyToCheck();
        this.PopulateReadyToLabel();
        this.PopulateReadyToCompound();
        this.PopulateFinalCheck();
        this.PopulateBondStore();
        this.PopulateReadyToRelease();

        //02Sep16 KR Added.  bug 161646 aMM - Not displaying the name of who Check assembled ingredients as it did
        if (this.gcReadyToCheckLabel.RowCount > 0)
            this.gcReadyToCheckLabel.SelectRow(0);
        this.settings.SiteId = SessionInfo.SiteID;
        this.settings.SessionId = SessionInfo.SessionID;
        this.settings.IfPreventPostBack     = (this.processor.SupplyRequest.State == aMMState.ReadyToLabel);
        this.settings.IfCanUndo             = this.processor.SupplyRequest.State > aMMState.WaitingScheduling && this.processor.SupplyRequest.State >= this.settings.FromStage && this.processor.SupplyRequest.State <= this.settings.ToStage;
        this.settings.IfCanPrintWorksheet   = aMMSetting.StagesAllowedToPrintWorksheet.Contains(this.processor.SupplyRequest.State);
        hfViewSettings.Value                = JsonConvert.SerializeObject(this.settings);
    }

    /// <summary>
    /// Called by different part of the form when updates need to be saved
    /// Will validate current stage, and move to next stage
    /// </summary>
    /// <param name="sender">Event sender</param>
    /// <param name="e">Event args</param>
    protected void Save_OnClick(object sender, EventArgs e)
    {
        if (this.ValidateCurrentStage())
        {
            this.MoveNextStage();
        }
    }
    #endregion

    #region Waiting Scheduling Stage
    /// <summary>Populate the waiting scheduling stage</summary>
    private void PopulateWaitingScheduling()
    {
        bool isEditable = this.settings.IsStateEditable(aMMState.WaitingScheduling, this.processor.SupplyRequest.State);

        if (isEditable && !this.IsPostBack)
        {
            DateTime now = DateTime.Now.ToStartOfDay();

            dpScheduleDate.MinDate      = now;
            dpScheduleDate.FocusedDate  = this.processor.Prescription.StartDate;
            if (this.processor.SupplyRequest.ManufactureDate == null || this.processor.SupplyRequest.ManufactureDate < now)
                dpScheduleDate.SelectedDate = now;
            else
                dpScheduleDate.SelectedDate = this.processor.SupplyRequest.ManufactureDate;

            this.UpdateScheduleShift(this.processor.SupplyRequest.ManufactureShiftID ?? -1);
        }
        else if (this.processor.SupplyRequest.State > aMMState.WaitingScheduling) 
        {
            tbScheduleDate.Text  = this.processor.SupplyRequest.ManufactureDate.ToPharmacyDateString();

            aMMShiftRow shift = aMMShift.GetById(this.processor.SupplyRequest.ManufactureShiftID.Value);
            tbScheduleShift.Text = (shift == null) ? string.Empty : shift.Description;

            AMMStateChangeNoteRow changeNote = this.processor.SupplyRequest.GetFirstChangeNoteAfterState(aMMState.WaitingScheduling);
            if (changeNote != null)
            {
                lbWaitingScheduling.Text = string.Format("by {0} on {1}", changeNote.GetPerson(), changeNote.CreatedDate.ToPharmacyDateTimeString());
            }

            lbShiftNearCapacity.Visible = lbShiftOverCapacity.Visible = false;
        }

        ddlScheduleShift.Visible         = isEditable;
        dpScheduleDate.Visible           = isEditable;
        btnWaitingSchedulingSave.Visible = isEditable;
        lbWaitingScheduling.Visible      = !isEditable;
        tbScheduleDate.Visible           = !isEditable;  
        tbScheduleShift.Visible          = !isEditable;
    }

    /// <summary>Validates if schedule has been selected</summary>
    /// <returns>If selected schedule is valid</returns>
    private bool ValidateWaitingScheduling()
    {
        bool ok = true;
        string error;

        // Validate date selected
        lbWaitingSchedulingError.InnerText = string.Empty;
        if (dpScheduleDate.SelectedDate == null || dpScheduleDate.SelectedDate < DateTime.Now.ToStartOfDay())
        {
            lbWaitingSchedulingError.InnerText = "Select a valid date";
            ok = false;
        }

        // Validate shift selection
        if (!Validation.ValidateDropDownList(ddlScheduleShift, "Shift", true, out error))
        {
            lbWaitingSchedulingError.InnerText = error;
            ok = false;
        }
        else if (ddlScheduleShift.SelectedValue == "-1")
        {
            lbWaitingSchedulingError.InnerText = "Select day that has shifts";
            ok = false;
        }

        // Validate that all slot are not currently filled (warns user)
        if (ok && hfConfirmShiftFull.Value<bool?>() != true)
        {
            var selectedShift = aMMShift.GetById(int.Parse(ddlScheduleShift.SelectedValue));
            var manuDate = selectedShift.CalculateManufactureDate(dpScheduleDate.SelectedDate.Value);

            var supplyRequestFreqency = aMMSupplyRequest.GetCountByManufactureDate(manuDate, manuDate);
            if (supplyRequestFreqency.Any() && supplyRequestFreqency.First().Value >= selectedShift.SlotsAvailable)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "slotsFilled", "setTimeout(function() { allSlotsFilledMsg(); }, 300);", true);
                ok = false;
            }
        }

        return ok;
    }

    /// <summary>
    /// Called when scheduled date is selected
    /// Will update the list of shifts
    /// </summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The event</param>
    protected void dpScheduleDate_OnSelectedDateChanged(object sender, EventArgs e)
    {
        int aMMSelectedShiftID = ConvertExtensions.ChangeType<int>(ddlScheduleShift.SelectedValue, -1);
        this.UpdateScheduleShift(aMMSelectedShiftID);
        this.ddlScheduleShift_OnSelectedIndexChanged(sender, e);
    }

    /// <summary>
    /// Called when ddlScheduleShift changes
    /// Will highlight if schedule is over capacity
    /// </summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The event</param>
    protected void ddlScheduleShift_OnSelectedIndexChanged(object sender, EventArgs e)
    {
        lbShiftNearCapacity.Visible = lbShiftOverCapacity.Visible = false;

        if (ddlScheduleShift.SelectedIndex != -1)
        {
            var temp = ddlScheduleShift.SelectedItem.Text.Split(new [] { '(', '/', ')' }, StringSplitOptions.RemoveEmptyEntries);

            if (temp.Length >= 3)
            {
                int slotsUsed     = int.Parse(temp[temp.Length - 2]);
                int slotsAvaiable = int.Parse(temp[temp.Length - 1]);

                if (slotsUsed > 0 && slotsUsed >= slotsAvaiable)
                    lbShiftOverCapacity.Visible = true;
                else if (slotsUsed > 1 && slotsUsed >= (slotsAvaiable * aMMSetting.Shifts.NearCapacityAsPercentatge / 100.0))
                    lbShiftNearCapacity.Visible = true;
            }
        }
    }

    /// <summary>Filters list of shifts based on ddlScheduleShift value</summary>
    /// <param name="aMMSelectedShiftID">Shift to select by default</param>
    private void UpdateScheduleShift(int aMMSelectedShiftID)
    {
        ddlScheduleShift.Items.Clear();

        if (dpScheduleDate.SelectedDate != null)
        {
            DateTime date = dpScheduleDate.SelectedDate.Value;
            DateTime now = DateTime.Now;

            // Get shifts
            var shift = aMMShift.GetAll().FindByDayOfWeek(date.DayOfWeek).OrderBy(d => d.StartTime).ToList();

            // Current allocation per shift
            var supplyRequestFreqency = aMMSupplyRequest.GetCountByManufactureDate(date.ToStartOfDay(), date.ToEndOfDay());

            // Fill list of shifts
            foreach (var s in shift)
            {
                int slotsFilled;
                if (s.CalculateEndDateForDay(date) > now)
                {
                    supplyRequestFreqency.TryGetValue(s.CalculateManufactureDate(date), out slotsFilled);
                    string description = string.Format("{0} ({1}/{2})", s, slotsFilled, s.SlotsAvailable);
                    ddlScheduleShift.Items.Add(new ListItem(description, s.AMMShiftID.ToString()));
                }
            }

            if (ddlScheduleShift.Items.Count == 0)
            {
                ddlScheduleShift.Items.Add(new ListItem("<No shifts for this day>", "-1"));
            }

            // Get selected shift
            var selectedItem = ddlScheduleShift.Items.FindByValue(aMMSelectedShiftID.ToString());
            if (selectedItem != null)
            {
                selectedItem.Selected = true;
            }
        }
    }
    #endregion

    #region Waiting Production Tray Stage
    /// <summary>Populate the waiting for product tray stage</summary>
    private void PopulateWaitingProductionTray()
    {
        // Production tray missing
        if (!aMMSetting.IfRequiresProductionTray)
        {
            trWaitingProductionTray.Visible = false;
            rWaitingProductionDivider.Visible = false;
            return;
        }

        // Populate
        bool isEditable = this.settings.IsStateEditable(aMMState.WaitingProductionTray, this.processor.SupplyRequest.State);
        this.tbProductionTrayBarcode.Text = this.processor.SupplyRequest.ProductionTrayBarcode;
        this.tbProductionTrayBarcode.ReadOnly = !isEditable;
        this.tbProductionTrayBarcode.CssClass = (this.processor.SupplyRequest.State > aMMState.WaitingProductionTray) ? "ReadOnly" : string.Empty;
        this.tbProductionTrayBarcode.Enabled  = (this.processor.SupplyRequest.State >= aMMState.WaitingProductionTray);
        this.tbProductionTrayBarcode.Attributes.Add("onfocus", "this.select();");
        this.tbProductionTrayBarcode.Attributes.Add("onkeydown", "if (event.keyCode == 13) { $('#btnWaitingProductionTraySet').click(); }");
        this.btnWaitingProductionTraySet.Visible = isEditable;
        
        this.lbWaitingProductionTray.Visible = false;
        if (this.processor.SupplyRequest.State > aMMState.WaitingProductionTray)
        {
            this.lbWaitingProductionTray.Visible = true;
            AMMStateChangeNoteRow changeNote = this.processor.SupplyRequest.GetFirstChangeNoteAfterState(aMMState.WaitingScheduling);
            if (changeNote != null)
            {
                lbWaitingProductionTray.Text = string.Format("by {0} on {1}", changeNote.GetPerson(), changeNote.CreatedDate.ToPharmacyDateTimeString());
            }
        }
    }

    /// <summary>Validates waiting for product tray stage</summary>
    /// <returns>if stage is valid</returns>
    private bool ValidateWaitingProductionTray()
    {
        bool ok = true;
        string error;

        // Check product tray barcode is filled in an valid
        ProductSearchType searchType = ProductSearchType.Barcode;
        if (!Validation.ValidateText(tbProductionTrayBarcode, string.Empty, typeof(string), true, Barcode.EAN13BarcodeLength, out error))
        {
            ok = false;
            tbProductionTrayBarcode.Focus();
            tdWaitingProductionTrayError.InnerHtml = error;
        }
        else if (tbProductionTrayBarcode.Text.Length != Barcode.EAN8BarcodeLength && tbProductionTrayBarcode.Text.Length != Barcode.EAN13BarcodeLength)
        {
            ok = false;
            tbProductionTrayBarcode.Focus();
            tdWaitingProductionTrayError.InnerHtml = string.Format("Barcode must be {0} or {1} characters", Barcode.EAN8BarcodeLength, Barcode.EAN13BarcodeLength);
        }
        else if (aMMSetting.ValidateTrayAgainstProductBarcode && ProductSearch.DoSearch(tbProductionTrayBarcode.Text, ref searchType, false).Any())
        {
            ok = false;
            tbProductionTrayBarcode.Focus();
            tdWaitingProductionTrayError.InnerHtml = "This is a product barcode";
        }

        // Check if product tray is already in use
        aMMSupplyRequestRow supplyRequest = null;
        if (ok)
            supplyRequest = aMMSupplyRequest.GetByProductionTrayAndActive(tbProductionTrayBarcode.Text);
        if (supplyRequest != null && supplyRequest.RequestID != this.processor.SupplyRequest.RequestID)
        {
            ok = false;
            var shiftWithSupplyRequest = aMMShift.GetById(supplyRequest.ManufactureShiftID ?? -1);
            var shift = (shiftWithSupplyRequest == null) ? string.Empty : " (Shift: " + supplyRequest.ManufactureDate.ToPharmacyDateString() + " " + shiftWithSupplyRequest.ToString() + ")";
            tbProductionTrayBarcode.Focus();
            tdWaitingProductionTrayError.InnerHtml = string.Format("Production tray in use at state '{0}'<br />Batch number {1}{2}", aMMSetting.StateString(supplyRequest.State), supplyRequest.BatchNumber, shift);
        }

        return ok;
    }
    #endregion

    #region Ready To Assemble Stage
    /// <summary>
    /// Populate ready to assemble stage
    /// Note that the stage kind of has two stages
    ///     First selected product, and perform batch tracking 
    ///     Second issue
    /// Both stages are performed by wizards
    /// </summary>
    private void PopulateReadyToAssemble()
    {
        var accessors = new IQSDisplayAccessor[] { new WProductQSProcessor(), new aMMSupplyRequestIngredientAccessor(), new PersonAccessor() };        

        // Fill QS panel
        pcReadyToAssemble.QSLoadConfiguration(SessionInfo.SiteID, "aMM", "Assembled Panel");
        pcReadyToAssemble.SetColumnsQS();
        pcReadyToAssemble.AddNamedLabelsQS();

        // Fill QS grid
        gcReadyToAssemble.QSLoadConfiguration(SessionInfo.SiteID, "aMM", "Assembled Grid");
        gcReadyToAssemble.AddColumnsQS();
        
        // Populate grid
        var supplyRequestIngredients = this.processor.SupplyRequestIngredients.OrderByDisplay().ToList();
        foreach (var ing in supplyRequestIngredients)
        {
            var product = this.processor.GetIngredientProduct(ing.NSVCode);
            var person  = this.processor.GetPerson(ing.AssembledByEntityId);

            (accessors[1] as aMMSupplyRequestIngredientAccessor).Product = product;
			(accessors[1] as aMMSupplyRequestIngredientAccessor).PersonAssembled = person;

            gcReadyToAssemble.AddRowQS(new BaseRow[] { ing, person, product }, accessors);
            gcReadyToAssemble.AddRowAttribute("DBID", ing.aMMSupplyRequestIngredientId.ToString());
            gcReadyToAssemble.AddRowAttributesQS(this.pcReadyToAssemble.QSDisplayItems, new BaseRow[] { ing, person, product }, accessors);

            // If ingredient has errors then highlight
            if (ing.HasError)
            {
                gcReadyToAssemble.SetRowBackgroundColour("#f2dede");
                gcReadyToAssemble.SetRowTextColour("#a94442");
            }
        }

        if (this.processor.SupplyRequest.State != aMMState.ReadyToAssemble)
        {
            // Not at ready to assemble stage so hide buttons
            btnReadyToAssembleSelect.Visible = false;
            btnReadyToAssembleRemove.Visible = false;
            btnReadyToAssembleFinish.Visible = false;
        }
        else if (this.processor.SupplyRequest.State == aMMState.ReadyToAssemble)
        {
            // Enabled ready to assemble stage
            bool finishedSelecting = this.processor.FindNextUnselectedIngredient() == -1;
            bool isEditable = this.settings.IsStateEditable(aMMState.ReadyToAssemble, this.processor.SupplyRequest.State);
            btnReadyToAssembleSelect.Visible = !finishedSelecting;
            btnReadyToAssembleSelect.Enabled = isEditable;
            btnReadyToAssembleFinish.Visible = finishedSelecting;            
            btnReadyToAssembleFinish.Enabled = isEditable;
            btnReadyToAssembleRemove.Visible = true;
            btnReadyToAssembleRemove.Enabled = isEditable;

            // If not already been auto displayed then open the ingredient wizard
            bool ifWizardDisplayed = BoolExtensions.PharmacyParseOrNull(hfReadyToAssembleIfWizardDisplayed.Value) ?? false;
            if (isEditable && !ifWizardDisplayed)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showIngredientWizard", "setTimeout(function(){ $('#btnReadyToAssembleSelect').click(); }, 200);", true);
                hfReadyToAssembleIfWizardDisplayed.Value = "1";
            }
        }

        // If row was selected then reselect
        if (!string.IsNullOrEmpty(hfReadyToAssembleSelectedRowDBID.Value))
        {
            var selectedDBID  = hfReadyToAssembleSelectedRowDBID.Value<int>();
            var selectedIndex = supplyRequestIngredients.FindIndex(i => i.aMMSupplyRequestIngredientId == selectedDBID);
            gcReadyToAssemble.SelectRow(selectedIndex);
        }
        else if (gcReadyToAssemble.RowCount > 0)
            gcReadyToAssemble.SelectRow(0);     // 02Aug16 XN  159413
    }

    /// <summary>
    /// Validates the ready to assembled stage
    /// Checks that all ingredients have been selected and issued
    /// </summary>
    /// <returns>if valid</returns>
    private bool ValidateReadyToAssemble()
    {
        return this.processor.FindNextUnselectedIngredient() == -1; // && this.processor.SupplyRequestIngredients.All(s => s.State == aMMSupplyRequestIngredientState.Committed);
    }
    
    /// <summary>
    /// Called when the ready to assemble remove button is clicked
    /// Removes the currently selected ingredient from the list
    /// </summary>
    /// <param name="sender">The sender</param>
    /// <param name="args">The args</param>
    protected void btnReadyToAssembleRemove_OnClick(object sender, EventArgs args)
    {
        if (!string.IsNullOrEmpty(hfReadyToAssembleSelectedRowDBID.Value))
        {
            // Get selected ingredient ID
            int selectedDBID = hfReadyToAssembleSelectedRowDBID.Value<int>();

            // find index of selected ingredient (used after remove to select next item in the list)
            var supplyRequestIngredients = this.processor.SupplyRequestIngredients.OrderByDisplay().ToList();
            var selectedIndex = supplyRequestIngredients.FindIndex(i => i.aMMSupplyRequestIngredientId == selectedDBID);

            // Remove the selected ingredient
            this.processor.SupplyRequestIngredients.RemoveAll(i => i.aMMSupplyRequestIngredientId == selectedDBID);
            this.processor.SupplyRequestIngredients.Save();
            this.processor.UpdateSupplyRequestExpiry(true);

            // Select next ingredient
            hfReadyToAssembleSelectedRowDBID.Value = (supplyRequestIngredients.Count > selectedIndex + 1) ? supplyRequestIngredients[selectedIndex + 1].aMMSupplyRequestIngredientId.ToString() : string.Empty;
        }
    }
    #endregion

    #region Ready To Check Stage
    /// <summary>Populate the read to check stage</summary>
    private void PopulateReadyToCheck()
    {
        if (aMMSetting.SecondCheck == aMMSecondCheckType.None)
        {
            trReadToCheck.Visible = false;
            trReadToCheckDivider.Visible = false;
            return;
        }

        if (this.processor.SupplyRequest.State <= aMMState.ReadyToCheck)
        {
            switch (aMMSetting.SecondCheck)
            {
            case aMMSecondCheckType.SingleCheck:
                mvReadyToCheck.SetActiveView(this.vSingleCheck);                
                break;
            case aMMSecondCheckType.IndividualCheck:
                mvReadyToCheck.SetActiveView(this.vIndividualCheck);
				if (this.processor.SupplyRequest.State == aMMState.ReadyToCheck)
                   this.PopulateSecondCheckGrid(this.gcReadyToCheckIndividualCheck, this.pcReadyToCheckIndividualCheck);
                break;
            case aMMSecondCheckType.SingleCheckSingleUser:
                mvReadyToCheck.SetActiveView(this.vSingleCheckSingleUser);
                break;
            case aMMSecondCheckType.IndividualCheckSingleUser:
                mvReadyToCheck.SetActiveView(this.vIndividualCheckSingleUser);
				if (this.processor.SupplyRequest.State == aMMState.ReadyToCheck)
				   this.PopulateSecondCheckGrid(this.gcReadyToCheckIndividualCheckSingleUser, this.pcReadyToCheckIndividualCheckSingleUser);
                break;
            }
            
            bool enabled = this.settings.IsStateEditable(aMMState.ReadyToCheck, this.processor.SupplyRequest.State);
            mvReadyToCheck.GetActiveView().GetAllControlsByType<Button>().ToList().ForEach(b => b.Enabled = enabled);
            mvReadyToCheck.GetActiveView().GetAllControlsByType<SecondCheck>().ToList().ForEach(b => b.Enabled = enabled);
            hfReadToCheckIfEnabled.Value = enabled.ToOneZeorString();

            tbSelfCheckReason.Text = tbReadToCheck.Text = string.Empty;  // Cleared in-case of undo

            if (aMMSetting.AllowSelfChecking)
            {
                var assembledByEntityId =  this.processor.SupplyRequestIngredients.Select(ing => ing.AssembledByEntityId ?? -1).Distinct().ToArray();
                ucReadyToCheckSingleCheck.EntityIDsForSelfCheck = ucReadyToCheckIndividualCheck.EntityIDsForSelfCheck = assembledByEntityId;
                ucReadyToCheckSingleCheck.SelfCheckReason = ucReadyToCheckIndividualCheck.SelfCheckReason = string.Empty;
            }
        }
        else if (this.processor.SupplyRequest.State > aMMState.ReadyToCheck)
        {
            mvReadyToCheck.SetActiveView(this.vReadyToCheckLabel);
            switch (this.processor.SupplyRequest.SecondCheckType)
            {
            case aMMSecondCheckType.SingleCheck:
            case aMMSecondCheckType.SingleCheckSingleUser:
                this.divReadyToCheckLabel.Visible = false;
                var ing = this.processor.SupplyRequestIngredients.FindDrugs().FirstOrDefault();
                if (ing == null)
                {
                    tbReadToCheck.Text = "No Items to Check";
                }
                else if (ing.CheckedByEntityId == null)
                {
                    tbReadToCheck.Text = "Not Checked";
                }
                else if (!tbReadToCheck.Text.StartsWith("Checked"))
                {
                    // Only set once
					tbReadToCheck.Text = string.Format("Checked by {0} on {1}", this.processor.GetPerson(ing.CheckedByEntityId), ing.CheckedByDate.ToPharmacyDateTimeString());
					tbSelfCheckReason.Text = string.IsNullOrEmpty(ing.SelfCheckReason) ? string.Empty : "Self Check Reason: " + ing.SelfCheckReason;
                }
                break;
            case aMMSecondCheckType.IndividualCheckSingleUser:
            case aMMSecondCheckType.IndividualCheck:
                tbReadToCheck.Visible     = false;
				tbSelfCheckReason.Visible = false;
                this.PopulateSecondCheckGrid(this.gcReadyToCheckLabel, this.pcReadyToCheckLabel);
                break;
            }
        }
    }

    /// <summary>Populate grid with second check info</summary>
    /// <param name="grid">Grid to populate</param>
    private void PopulateSecondCheckGrid(PharmacyGridControl grid, PharmacyLabelPanelControl panel = null)
    {
        var accessors = new IQSDisplayAccessor[] { new WProductQSProcessor(), new aMMSupplyRequestIngredientAccessor(), new PersonAccessor() };

        var currentlyCheckedIds = this.hfCheckedItems.Value.ParseCSV<int>(",", true).ToList();

        // Fill QS panel
		panel.QSLoadConfiguration(SessionInfo.SiteID, "aMM", "Check By Panel");
		panel.SetColumnsQS();
		panel.AddNamedLabelsQS();
        grid.QSLoadConfiguration(SessionInfo.SiteID, "aMM", "Check By Display");
        grid.AddColumn(string.Empty, 3, PharmacyGridControl.ColumnType.Checkbox, PharmacyGridControl.AlignmentType.Center);
        grid.AddColumnsQS();

        foreach (var ing in this.processor.SupplyRequestIngredients.OrderByDisplay())
        {
            var product = this.processor.GetIngredientProduct(ing.NSVCode);
            //02Sept16 KR Bug 161646 aMM - Not displaying the name of who Check assembled ingredients as it did
            var person = this.processor.GetPerson(ing.CheckedByEntityId);
            var accessor = accessors[1] as aMMSupplyRequestIngredientAccessor;
            accessor.Product = product;
			accessor.PersonChecked  = person;
           

            grid.AddRowQS(new BaseRow[] { ing, person, product }, accessors);
            grid.AddRowAttribute("DBID", ing.aMMSupplyRequestIngredientId.ToString());
			grid.AddRowAttributesQS(panel.QSDisplayItems, new BaseRow[] { ing, person, product }, accessors);
            if (ing.CheckedByEntityId != null)
            {
                grid.SetCheck(0, true);
                grid.AddRowAttribute("ReadOnlyCheckBox", "1"); // Prevents user from reselecting other persons checks
            }

            if (currentlyCheckedIds.Contains(ing.aMMSupplyRequestIngredientId))
            {
                grid.SetCheck(0, true);
            }
        }
    }

    /// <summary>Validate read to check stage (check all ingredients are checked)</summary>
    /// <returns>Validate Ready to check stage</returns>
    private bool ValidateReadyToCheck()
    {
        // Get list of entity's that assembled the ingredients
        IEnumerable<int> entityIdAssembledBy;

        // Get list of ingredients to check (depends on check type)
        List<aMMSupplyRequestIngredientRow> ingredientsToCheck = new List<aMMSupplyRequestIngredientRow>();
        int checkedByEntityId = -1;
		string selfCheckReason = string.Empty;
        switch (aMMSetting.SecondCheck)
        {
        case aMMSecondCheckType.SingleCheck:
			entityIdAssembledBy = this.processor.SupplyRequestIngredients.Select(i => i.AssembledByEntityId ?? -1);
            if (ucReadyToCheckSingleCheck.Validate(aMMSetting.AllowSelfChecking ? new List<int>() : entityIdAssembledBy.Distinct()))
            {
				ingredientsToCheck = this.processor.SupplyRequestIngredients.ToList(); 
				checkedByEntityId  = ucReadyToCheckSingleCheck.EntityId ?? -1;
				selfCheckReason    = ucReadyToCheckSingleCheck.SelfCheckReason;
            }
            break;
        case aMMSecondCheckType.IndividualCheck:
            {
            var ids = hfCheckedItems.Value.ParseCSV<int>(",", true).ToArray();
            entityIdAssembledBy = this.processor.SupplyRequestIngredients.FindByIDs(ids).Where(i => i.CheckedByEntityId == null).Select(i => i.AssembledByEntityId ?? -1);
            if (this.ucReadyToCheckIndividualCheck.Validate(aMMSetting.AllowSelfChecking ? new List<int>() : entityIdAssembledBy.Distinct()))
            {
				ingredientsToCheck = this.processor.SupplyRequestIngredients.FindByIDs(ids).Where(i => i.CheckedByEntityId == null).ToList();
				checkedByEntityId  = this.ucReadyToCheckIndividualCheck.EntityId ?? -1;
				selfCheckReason    = ucReadyToCheckIndividualCheck.SelfCheckReason;
            }
            }
            break;
        case aMMSecondCheckType.SingleCheckSingleUser:        
            ingredientsToCheck = this.processor.SupplyRequestIngredients.ToList();
            checkedByEntityId = SessionInfo.EntityID;
            break;
        case aMMSecondCheckType.IndividualCheckSingleUser:       
            {
            var ids = hfCheckedItems.Value.ParseCSV<int>(",", true).ToArray();
            ingredientsToCheck = this.processor.SupplyRequestIngredients.FindByIDs(ids).Where(i => i.CheckedByEntityId == null).ToList();
            checkedByEntityId = SessionInfo.EntityID;
            }
            break;
        }
		
		if (!ingredientsToCheck.Any())
		{
			switch (aMMSetting.SecondCheck)
			{
			case aMMSecondCheckType.IndividualCheck:		   divReadyToCheckIndividualCheckError.InnerHtml 		   = "Check ingredients from the list"; break;
			case aMMSecondCheckType.IndividualCheckSingleUser: divReadyToCheckIndividualCheckSingleUserError.InnerHtml = "Check ingredients from the list"; break;
			}
		}

        // Bit naughty but save the changes here
        DateTime now = DateTime.Now;
        foreach (var ing in ingredientsToCheck)
        {
            ing.CheckedByEntityId = checkedByEntityId;
            ing.CheckedByDate     = now;
			ing.SelfCheckReason   = (ing.AssembledByEntityId == ing.CheckedByEntityId ? selfCheckReason : string.Empty);
        }
        this.processor.SupplyRequestIngredients.Save();

        // Clear checked items
        hfCheckedItems.Value = string.Empty;

        // Can only move to next stage once everything has been checked
        return this.processor.SupplyRequestIngredients.All(i => i.CheckedByEntityId != null);
    }
    #endregion

    #region Ready To Compound Stage
    /// <summary>Populate the ready to compound stage</summary>
    private void PopulateReadyToCompound()
    {
        if (this.processor.SupplyRequest.State < aMMState.ReadyToCompound)
        {
            tdImageCapture.Visible              = false;
            trImageCaptureTakePicture.Visible   = false;
            divImageCaptureStores.Visible       = false;
            imgManufacturedProduct.Visible      = false;
            tbReadyToCompoundNoPic.Visible      = false;
            btnReadyToCompound.Enabled          = false;
            btnReadyToCompoundShowMethod.Enabled= false;
        }
        else if (this.processor.SupplyRequest.State == aMMState.ReadyToCompound)
        {
            tbReadyToCompound.Visible           = false;
            btnReadyToCompound.Visible          = true;
            btnReadyToCompoundShowMethod.Visible= true;
            tbReadyToCompoundNoPic.Visible      = false;
            btnReadyToCompound.Enabled          = this.settings.IsStateEditable(aMMState.ReadyToCompound, this.processor.SupplyRequest.State);
            btnReadyToCompoundShowMethod.Enabled= true;
            tbReadyToCompound.Text              = string.Empty;
            this.imgManufacturedProduct.ImageUrl= string.Empty;
            
            //start video capture if available
            bool showImageCapture = this.settings.isActiveXControlEnabled && aMMSetting.CaptureManufacturedImage && this.processor.SupplyRequest.State == aMMState.ReadyToCompound;
            if (showImageCapture)
            {
                if (btnReadyToCompound.Enabled)
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "startimagecapture", "EnableCapture();", true);
                else
                    btnTakePicture.Attributes.Add("disabled", "disabled");
            }
            
            tdImageCapture.Visible              = showImageCapture;
            trImageCaptureTakePicture.Visible   = showImageCapture;
            divImageCaptureStores.Visible       = showImageCapture;
            imgManufacturedProduct.Visible      = showImageCapture;

            if (btnReadyToCompound.Enabled)
                ScriptManager.RegisterStartupScript(this, this.GetType(), "startUp", "$('#btnReadyToCompound').focus();", true);    
        }
        else if (string.IsNullOrEmpty(tbReadyToCompound.Text))
        {                        
            // Only populate when needed

            // Disable controls if not capturing product image 
            tbReadyToCompoundNoPic.Visible = false;
            imgManufacturedProduct.Visible = false;
            if (aMMSetting.CaptureManufacturedImage)
            {
                byte[] imagedata = this.processor.SupplyRequest.GetCompoundedImage();
                if (imagedata != null && imagedata.Length > 0)
                {
                    string base64String = Convert.ToBase64String(imagedata, 0, imagedata.Length);
                    this.imgManufacturedProduct.ImageUrl = "data:image/jpeg;base64," + base64String;
                    imgManufacturedProduct.Visible = true;
                }
                else
                {
                    tbReadyToCompoundNoPic.Visible = true;
                }
            }
                    
            this.tdImageCapture.Visible              = false;
            this.trImageCaptureTakePicture.Visible   = false;
            this.divImageCaptureStores.Visible       = false;
            this.tbReadyToCompound.Visible           = true;
            this.btnReadyToCompound.Visible          = false;
            this.btnReadyToCompoundShowMethod.Visible= false;

            AMMStateChangeNoteRow changeNote = this.processor.SupplyRequest.GetFirstChangeNoteAfterState(aMMState.ReadyToCompound);
            if (changeNote != null)
            {                
                tbReadyToCompound.Text = string.Format("Compounded by {0} on {1}", changeNote.GetPerson(), changeNote.CreatedDate.ToPharmacyDateTimeString());
            }
        }
    }
    
    /// <summary>Validates Ready to compound stage</summary>
    /// <returns>Always returns true</returns>
    private bool ValidateReadyToCompound()
    {
        return true;
    }

    /// <summary>
    /// Called when the ready to compound show method is displayed
    /// 26Aug16 XN 161234 will get and parsed the method rtf
    /// </summary>
    protected void btnReadyToCompoundShowMethod_OnClick(object sender, EventArgs args)
    {
        string filename       = aMMSetting.MethodRtfFile.Replace("\\", "\\\\");
        string methodfilename = WFormula.GetByNSVCodeSiteAndApproved(processor.Product.NSVCode, SessionInfo.SiteID).GetMethodFilename().Replace("\\", "\\\\");
        ScriptManager.RegisterStartupScript(this, this.GetType(), "showMethodFnc", string.Format("setTimeout(function() {{ showMethod('{0}', '{1}'); }}, 0);", filename, methodfilename), true); 
    }
    #endregion

    #region Ready To Label Stage
    /// <summary>Populate the read to label stage</summary>
    private void PopulateReadyToLabel()
    {
        if (!aMMSetting.IfReadyToLabel)
        {
            trReadyToLabelDiv.Visible = false;
            trReadyToLabel.Visible    = false;
        }
        else if (this.processor.SupplyRequest.State < aMMState.ReadyToLabel)
        {
            mvLabel.ActiveViewIndex = mvLabel.Views.IndexOf(vLabelEmpty);
            //tbReadyToLabel.Visible = false;
            //btnReadyToLabel.Visible = true;
            //btnReadyToLabel.Enabled = this.settings.IsStateEditable(aMMState.ReadyToLabel, this.processor.SupplyRequest.State);
        }
        else if (this.processor.SupplyRequest.State == aMMState.ReadyToLabel)
        {
            mvLabel.ActiveViewIndex = mvLabel.Views.IndexOf(vLabelDispensing);
            
            var supplyRequest = this.processor.SupplyRequest;
            var formula       = this.processor.Formula;

            // Calculate the number of labels
            var numberOfLabels   = aMMProcessor.CalculateNumberOfContainers(supplyRequest.VolumeOfInfusionInmL.Value, this.processor.Product) * ((supplyRequest.QuantityRequested * formula.NumberOfLabels) + formula.ExtraLabels);
            hfNumberOfLabels.Value  = ((int)numberOfLabels).ToString();

            if (this.settings.isActiveXControlEnabled)
            {
                btnLabel.Attributes.Add("disabled", "disabled");
                string script = string.Format("connectToDispensingCtrl({0}, {1}, {2});", this.processor.Prescription.RequestID, supplyRequest.RequestID, supplyRequest.RequestIdWLabel == null ? "undefined" : supplyRequest.RequestIdWLabel.ToString());
                ScriptManager.RegisterStartupScript(this, this.GetType(), "connectLabelCtrl", script, true);
            }
            else
            {
                btnLabel.Width  = System.Web.UI.WebControls.Unit.Parse("150px");
                btnLabel.Height = System.Web.UI.WebControls.Unit.Parse("50px" );
            }
        }
        else if (string.IsNullOrEmpty(tbReadyToLabel.Text))
        {
            mvLabel.ActiveViewIndex = mvLabel.Views.IndexOf(vLabelLabel);

            AMMStateChangeNoteRow changeNote = this.processor.SupplyRequest.GetFirstChangeNoteAfterState(aMMState.ReadyToLabel);
            if (changeNote != null)
            {
                tbReadyToLabel.Text = string.Format("Labelled by {0} on {1}", changeNote.GetPerson(), changeNote.CreatedDate.ToPharmacyDateTimeString());
            }
        }
    }
    #endregion

    #region Final Check Stage
    /// <summary>Populate the final check stage</summary>
    public void PopulateFinalCheck()
    {
        if (aMMSetting.FinalCheck == aMMFinalCheckType.None)
        {
            trFinalCheck.Visible        = false;
            trFinalCheckDivider.Visible = false;
            tbFinalCheckReason.Text     = string.Empty;
        }
        else if (this.processor.SupplyRequest.State <= aMMState.FinalCheck)
        {
            btnFinalCheck.Visible           = true;
            btnFinalCheck.Enabled           = this.settings.IsStateEditable(aMMState.FinalCheck, this.processor.SupplyRequest.State);
            ucFinalCheck.Visible            = aMMSetting.FinalCheck == aMMFinalCheckType.SecondCheck;
            ucFinalCheck.Enabled            = btnFinalCheck.Enabled;
            if (aMMSetting.AllowSelfChecking)
                ucFinalCheck.EntityIDsForSelfCheck = new int[] { SessionInfo.EntityID };
            tblFinalCheck.Visible           = true;
            tdFinalCheckSecondCheck.Visible = ucFinalCheck.Visible;
            tbFinalCheck.Visible            = false;
            tbFinalCheckReason.Text         = string.Empty;

            if (this.processor.SupplyRequest.State == aMMState.FinalCheck)
                ucFinalCheck.Focus();
        }
        else if (string.IsNullOrEmpty(tbFinalCheck.Text))
        {
            // Only populate the first time around
            btnFinalCheck.Visible   = false;
            ucFinalCheck.Visible    = false;
            tblFinalCheck.Visible   = false;
            tbFinalCheck.Visible    = true;
            tbFinalCheckReason.Text = string.IsNullOrEmpty(this.processor.SupplyRequest.SelfCheckReason) ? string.Empty : "Self Check Reason: " + this.processor.SupplyRequest.SelfCheckReason;

            AMMStateChangeNoteRow changeNote = this.processor.SupplyRequest.GetFirstChangeNoteAfterState(aMMState.FinalCheck);
            if (changeNote != null)
            {
                tbFinalCheck.Text = string.Format("Final check by {0} on {1}", changeNote.GetPerson(), changeNote.CreatedDate.ToPharmacyDateTimeString());
            }
        }
    }

    /// <summary>Validates the final check stage</summary>
    /// <returns>If stage is valid</returns>
    public bool ValidateFinalCheck()
    {
        return aMMSetting.FinalCheck == aMMFinalCheckType.Button || ucFinalCheck.Validate();
    }
    #endregion

    #region Bond Store Stage
    /// <summary>Populate the bond store stage</summary>
    private void PopulateBondStore()
    {
        if (!this.processor.IfBondStore)
        {
            trBondStore.Visible = false;
            trBondStoreDivider.Visible = false;
        }
        else if (this.processor.SupplyRequest.State <= aMMState.BondStore)
        {
            tbBondStore.Visible = false;
            btnBondStore.Visible = true;
            btnBondStore.Enabled = this.settings.IsStateEditable(aMMState.BondStore, this.processor.SupplyRequest.State);
        }
        else if (string.IsNullOrEmpty(tbBondStore.Text))
        {
            // Load if not already populated
            tbBondStore.Visible = true;
            btnBondStore.Visible= false;

            AMMStateChangeNoteRow changeNote = this.processor.SupplyRequest.GetFirstChangeNoteAfterState(aMMState.BondStore);
            if (changeNote != null)
            {
                tbBondStore.Text = string.Format("Released from bond store by {0} on {1}", changeNote.GetPerson(), changeNote.CreatedDate.ToPharmacyDateTimeString());
            }
        }
    }

    /// <summary>Validate the bond store stage (always returns true)</summary>
    /// <returns>If stage is valid</returns>
    private bool ValidateBondStore()
    {
        return true;
    }
    #endregion

    #region Ready to Release Stage
    /// <summary>Populate the ready to release stage</summary>
    private void PopulateReadyToRelease()
    {
        if (!aMMSetting.IfReadyToRelease)
        {
            trReadyToRelease.Visible = false;
            trReadyToReleaseDivider.Visible = false;
        }
        else if (this.processor.SupplyRequest.State <= aMMState.ReadyToRelease)
        {
            tbReadyToRelease.Visible = false;
            btnReadyToRelease.Visible = true;
            btnReadyToRelease.Enabled = this.settings.IsStateEditable(aMMState.ReadyToRelease, this.processor.SupplyRequest.State);
        }
        else if (string.IsNullOrEmpty(tbReadyToRelease.Text))
        {
            // Load if not already populated
            tbReadyToRelease.Visible = true;
            btnReadyToRelease.Visible= false;

            AMMStateChangeNoteRow changeNote = this.processor.SupplyRequest.GetFirstChangeNoteAfterState(aMMState.ReadyToRelease);
            if (changeNote != null)
            {
                tbReadyToRelease.Text = string.Format("Completed by {0} on {1}", changeNote.GetPerson(), changeNote.CreatedDate.ToPharmacyDateTimeString());
            }
        }
    }

    /// <summary>Validate the ready to release stage (always return true)</summary>
    /// <returns>If stage is valid</returns>
    private bool ValidateReadyToRelease()
    {
        return true;
    }
    #endregion

    #region Web Methods
    /// <summary>
    /// Parse and print the the worksheet
    /// As the RTF template is on a network share, this is read client side and passed to this method
    /// Will return the completed RTF which will use objPrintCtrl to do the printing
    /// </summary>
    /// <param name="sessionId">Session id</param>
    /// <param name="siteId">Site id</param>
    /// <param name="requestIdAmmSupplyRequest">request id of the supply request</param>
    /// <param name="layoutName">layout to print</param>
    /// <param name="rtf">rtf template to print</param>
    /// <param name="methodRtf">rtf template for method file</param>
    /// <param name="saveToReprints">Save file to reprints</param>
    /// <param name="labelText">Label text</param>
    /// <param name="freeText">Free text string</param>
    /// <returns>Will return the completed RTF which will use objPrintCtrl to do the printing</returns>
    [WebMethod]
    public static string ParseReport(int sessionId, int siteId, int requestIdAmmSupplyRequest, string layoutName, string rtf, string methodRtf, bool saveToReprints, string labelText, string freeText)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionId, siteId);

        var processor       = aMMProcessor.Create(requestIdAmmSupplyRequest);
        var episode         = Episode.GetByEpisodeID(processor.SupplyRequest.EpisodeID);
        var person          = Patient.GetByEntityID(episode.EntityID);
        var layout          = WLayout.GetBySiteNameAndApproved(siteId, layoutName);
        var product         = processor.Product;
		var formula		    = processor.Formula;
        var supplyRequest   = processor.SupplyRequest;

        if (processor != null)
        {
            try
            {
                if (processor.Label == null)
                {
                    processor.Label = (new WLabel()).Add();
                    processor.Label.SiteID  = siteId;
                    processor.Label.Text    = labelText;
                }

                // Load rtf
                RTFParser parser = new RTFParser();
                parser.Read(rtf);
               
                // Parse processor first
                parser.Parse("method", methodRtf);
                parser.ParseXML(processor.ToHeapWorksheetXml(layoutName));
    
                // parse extra heap items
                parser.ParseXML(person.ToXmlHeap());
                parser.ParseXML(episode.ToXmlHeap());
                if (layout != null)
                    parser.ParseXML(layout.ToXmlHeap());
                parser.ParseXML(processor.Label.ToXmlHeap());
			    parser.ParseXML(product.ToXMLHeap());
			    parser.ParseXML(formula.ToXmlHeap());
                parser.ParseXML(supplyRequest.ToXmlHeap());
                parser.Parse("freetext", freeText);
			
                rtf = parser.ToString();
            }
            finally
            {
                if (processor.Label.RawRow.RowState == DataRowState.Added)
                    processor.Label = null;
            }

            // Save reprints
            if (saveToReprints)
                PharmacyLabelReprint.SaveByAmmSupplyRequest(requestIdAmmSupplyRequest, PharmacyLabelReprintType.Worksheet, rtf);

            // Mark that printed worksheet (if no layout then this is just as method print so don't log)
            if (!string.IsNullOrEmpty(layoutName))
                processor.PrintedWorksheet(reprint: false, layout: layoutName);

            // Add return
            return rtf;
        }
        else
            return null;
    }
    /// <summary>
    /// Read RTF from DB - needed for hosted
    /// </summary>
    /// <param name="sessionId">Session id</param>
    /// <param name="siteId">Site id</param>
    /// <param name="Name">Name of RTF</param>
    /// <returns>Will return the RTF template stored in the DB</returns>

    [WebMethod]
    public static string ReadRTF(int sessionId, int siteId, string Name)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionId, siteId);

        PharmacyRTFReport WrkSheetRTFReport = new PharmacyRTFReport();
        WrkSheetRTFReport.LoadRTFByNameandSiteID(Name, SessionInfo.SiteID);
        
        if (WrkSheetRTFReport == null)
            return string.Empty;
        else
            return WrkSheetRTFReport.First().Report;
       
    }

    /// <summary>Get a reprint of a worksheet or label</summary>
    /// <param name="sessionId">Session id</param>
    /// <param name="siteId">Site id</param>
    /// <param name="requestIdAmmSupplyRequest">request id of the supply request</param>
    /// <param name="type">Worksheet or label</param>
    /// <returns>Will return the completed RTF which will use objPrintCtrl to do the printing</returns>
    [WebMethod]
    public static string GetReprint(int sessionId, int siteId, int requestIdAmmSupplyRequest, PharmacyLabelReprintType type)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionId, siteId);

        var rtf = PharmacyLabelReprint.GetLabelByAmmSupplyRequestAndType(requestIdAmmSupplyRequest, type);
        if (string.IsNullOrWhiteSpace(rtf))
            return null;
        else
        {
            // Mark that printed worksheet
            var processor = aMMProcessor.Create(requestIdAmmSupplyRequest);
            if (type == PharmacyLabelReprintType.Worksheet)
                processor.PrintedWorksheet(reprint: true);
            else
                processor.PrintedLabel(reprint: true);
            
            return rtf;
        }
     }

    /// <summary>Removes all cached data</summary>
    /// <param name="sessionId">Session Id</param>
    /// <param name="requestId">AMM supply request ID</param>
    [WebMethod]
    public static void CleanUp(int sessionId, int requestId)
    {
        SessionInfo.InitialiseSession(sessionId);
        aMMProcessor.ClearCache(requestId, unlockRows: true);
    }
    
    [WebMethod]
	public static void SaveImage(int sessionId, string imageAsBase64)
	{
        SessionInfo.InitialiseSession(sessionId);
		ImageTable image = new ImageTable();
		image.Add();
		image[0].ImageType = ImageTableType.Photograph;
		image[0].Description = string.Empty;
		image[0].Detail = string.Empty;
		image[0].ImageData = Convert.FromBase64String(imageAsBase64);
		image[0].ImageDate = DateTime.Now;
		image[0].EntityID = SessionInfo.EntityID;
		image.Save();
	}

    /// <summary>Returns if anything has been issued for the supply request</summary>
    /// <param name="sessionId">Session id</param>
    /// <param name="requestIdAmmSupplyRequest">request id</param>
    /// <returns>if issued</returns>
    [WebMethod]
    public static bool HasIssued(int sessionId, int requestIdAmmSupplyRequest)
    {
        SessionInfo.InitialiseSession(sessionId);
        var issueState = Database.ExecuteSQLScalar<string>("SELECT IssueState FROM AMMSupplyRequest WHERE RequestID={0}", requestIdAmmSupplyRequest);
        return !string.IsNullOrWhiteSpace(issueState);
    }
    #endregion

    #region Private Methods
    /// <summary>Populate the toolbar</summary>
    /// <param name="buttons">Buttons to display (see file header)</param>
    private void PopulateToolbar(string buttons)
    {
        var buttonTypes = buttons.ToCharArray().Select(c => EnumDBCodeAttribute.DBCodeToEnum<ToolbarButtonType>(c.ToString()));

        foreach (ToolbarButtonType b in buttonTypes)
        {
            RadToolBarDropDown dropDown = null;
            RadToolBarButton button = null;
            string eventName = string.Empty;

            switch (b)
            {
            case ToolbarButtonType.ViewRx:
                button = new RadToolBarButton() { ImageUrl = "images/prescription.gif", Text = "View Rx", ToolTip = "View prescription (Alt+P)", Width = System.Web.UI.WebControls.Unit.Pixel(50) };
                eventName = "aMMSupplyRequest_ViewRx";
                break;
            case ToolbarButtonType.ViewHisotry:
                button = new RadToolBarButton() { ImageUrl = "images/History.gif", Text = "History", ToolTip = "View note history of supply request (Alt+H)", Width = System.Web.UI.WebControls.Unit.Pixel(50) };
                eventName = "aMMSupplyRequest_ViewHistory";
                break;
            case ToolbarButtonType.AttachNote:
                button = new RadToolBarButton() { ImageUrl = "images/attachNote.gif", Text = "Attach Note", ToolTip = "Add note to supply request", Width = System.Web.UI.WebControls.Unit.Pixel(70) };
                eventName = "aMMSupplyRequest_AttachNote";
                break;
            case ToolbarButtonType.ReportError:
                button = new RadToolBarButton() { ImageUrl = "images/error.gif", Text = "Error Note", ToolTip = "Report error for supply request (Alt+E)", Width = System.Web.UI.WebControls.Unit.Pixel(60) };
                eventName = "aMMSupplyRequest_ReportError";
                break;
            case ToolbarButtonType.Undo:
                button = new RadToolBarButton() { ImageUrl = "images/undo.gif", Text = "Undo", ToolTip = "Undo last operation (Alt+Z)", Width = System.Web.UI.WebControls.Unit.Pixel(45) };
                eventName = "aMMSupplyRequest_Undo";
                break;
            case ToolbarButtonType.Cancel:
                button = new RadToolBarButton() { ImageUrl = "images/stop.gif", Text = "Stop", ToolTip = "Cancel the current supply request (Alt+S)", Width = System.Web.UI.WebControls.Unit.Pixel(45) };
                eventName = "aMMSupplyRequest_Cancel";
                break;
            case ToolbarButtonType.PrintWorksheet:
                button = new RadToolBarButton() { ImageUrl = "images/print.gif", Text = "Worksheet", ToolTip = "Print worksheet for supply request", Width = System.Web.UI.WebControls.Unit.Pixel(65) };
                eventName = "aMMSupplyRequest_PrintWorksheet";
                break;
            case ToolbarButtonType.PrintLabel:
                button = new RadToolBarButton() { ImageUrl = "images/print.gif", Text = "Label", ToolTip = "Print label for supply request", Width = System.Web.UI.WebControls.Unit.Pixel(45) };
                eventName = "aMMSupplyRequest_PrintLabel";
                break;
            case ToolbarButtonType.Issue:
                button = new RadToolBarButton() { ImageUrl = "images/syringe.gif", Text = "Issue", ToolTip = "Issue supply request (Alt+I)", Width = System.Web.UI.WebControls.Unit.Pixel(50) };
                eventName = "aMMSupplyRequest_Issue";
                break;
            case ToolbarButtonType.Return:
                button = new RadToolBarButton() { ImageUrl = "images/return.gif", Text = "Return", ToolTip = "Return ingredient and undo manufacturing issue", Width = System.Web.UI.WebControls.Unit.Pixel(75) };
                eventName = "aMMSupplyRequest_Return";
                break;
            case ToolbarButtonType.ItemEnquiry:
                button = new RadToolBarButton() { ImageUrl = "images/item enquiry.gif", Text = "Item Enquiry", ToolTip = "Item enquiry for supply request drug", Width = System.Web.UI.WebControls.Unit.Pixel(75) };
                eventName = "aMMSupplyRequest_ItemEnquiry";
                break;
            case ToolbarButtonType.LogViewer:   // 02Aug16 XN  159413
                button = new RadToolBarButton() { ImageUrl = "images/log viewer.gif", Text = "Log Viewer", ToolTip = "Displays translog viewer", Width = System.Web.UI.WebControls.Unit.Pixel(75) };
                eventName = "aMMSupplyRequest_LogViewer";
                break;
            case ToolbarButtonType.Separator:
                button = new RadToolBarButton() { IsSeparator = true };
                break;
            }

            if (button != null && !string.IsNullOrEmpty(eventName))
            {
                button.CommandName = string.Format("{0}()", eventName);
                button.Attributes.Add("eventName", eventName);
            }

            if (button != null)
            {
                button.ImagePosition = ToolBarImagePosition.AboveText;
                //if (!button.IsSeparator)
                //    button.Width = Unit.Pixel(65);
                radToolbar.Items.Add(button);
            }
        }
    }

    /// <summary>Populate the request details panel</summary>
    private void PopulateRequestDetails()
    {
        var supplyRequest = this.processor.SupplyRequest;
        if (!this.IsPostBack)
        {
            var createdUser   = Person.GetByEntityID(this.processor.SupplyRequest.EntityID);
            var doseUnit      = ascribe.pharmacy.icwdatalayer.Unit.GetByUnitID(this.processor.SupplyRequest.UnitIdDose);

            lbPhamacyProduct.Text= string.Format("{0} - {1}", this.processor.Product.NSVCode, this.processor.Product);
            lbCreated.Text       = createdUser + " on " + supplyRequest.CreatedDate.ToPharmacyDateTimeString();
            lbBatchNumber.Text   = supplyRequest.BatchNumber;
            lbVolume.Text        = string.Format("{0:0.####} mL {1}", supplyRequest.VolumeOfInfusionInmL , supplyRequest.VolumeType);
            
            //if (supplierProfile.QuantityRequested == 1)  XN 1Jul16 157210 qty should always be shown
            //    lbDose.Text =  string.Format("{0} {1}", supplierProfile.Dose, doseUnit);
            //else
            //lbDose.Text = string.Format("{0} x {1} {2}", supplierProfile.QuantityRequested, supplierProfile.Dose, doseUnit);  XN 8Aug16 159843
            lbDose.Text = string.Format("{0} {1}", supplyRequest.Dose, doseUnit);
            lbQty.Text  = supplyRequest.QuantityRequested.Value.ToString();
        }

        lbWhen.Text = supplyRequest.ManufactureDate == null ? "Not Scheduled" : supplyRequest.ManufactureDate.ToPharmacyDateString() + " - " + aMMShift.GetById(supplyRequest.ManufactureShiftID.Value).ToString();

        DateTime? expiryDate = supplyRequest.ExpiryDate;
        //lbExpires.Text       = expiryDate == null ? "N\\A" : string.Format("{0} ({1})", expiryDate.ToPharmacyDateTimeString(), ConvertExtensions.FromMintues(this.processor.CalculateExpiryTimeInMintues().Value, orderMHD: false));
        lbExpires.Text       = expiryDate == null ? "N\\A" : expiryDate.ToPharmacyDateTimeString(); // 19Aug16 XN 160567 removed (1H 1D) expiry info

        lbState.Text = string.Format("{0}{1} by {2} on {3}", 
                                     aMMSetting.StateString(this.processor.SupplyRequest.State),                                             
                                     this.processor.LastAMMStateChangeNote.FromState > this.processor.LastAMMStateChangeNote.ToState ? " (undo)" : string.Empty,
                                     this.processor.GetPerson(this.processor.LastAMMStateChangeNote.EntityID),
                                     this.processor.LastAMMStateChangeNote.CreatedDate.ToPharmacyDateTimeString());
        lbStageUndone.Visible = this.processor.IfAnyStageUndone;

        lbPrintedWorksheet.Text = this.processor.SupplyRequest.IfPrintedWorksheet.ToYesNoString();
        lbPrintedLabel.Text     = this.processor.SupplyRequest.IfPrintedLabel.ToYesNoString();
        lbIssueState.Text       = aMMSetting.IssueStateString(this.processor.SupplyRequest.IssueState);
    }

    /// <summary>Update the coloring of the stage boxes</summary>
    private void UpdateStageBoxes()
    {
        var currentState = this.processor.SupplyRequest.State;
        var cancelled    = this.processor.SupplyRequest.IsCancelled();

        for (var s = aMMState.WaitingScheduling; s < aMMState.Completed; s++)
        {
            var label = (this.FindControl("lbStage" + (int)s) as Label);
            if (s < this.processor.SupplyRequest.State)
            {
                label.CssClass = "StageBox StageComplete";
            }
            else if (s == this.processor.SupplyRequest.State)
            {
                label.CssClass = "StageBox StageActive";
            }
            else if (cancelled || !settings.IsStateEditable(s, currentState))
            {
                label.CssClass = "StageBox StageLocked";
            }
            else
            {
                label.CssClass = "StageBox StageOpen";
            }
        }

        // Warn user if page is non-editable for any reason
        if (cancelled)
        {
            divMainWarning.InnerText = "This supply request has been cancelled";
            divMainWarning.Visible = true;
        }
        else if (this.settings.IsPrescriptionCancelled)
        {
            divMainWarning.InnerText = "The prescription has been cancelled";
            divMainWarning.Visible = true;
        }
        else if (this.settings.ReadOnly)
        {
            divMainWarning.InnerText = "You can't edit this AMM supply request";
            divMainWarning.Visible = true;
        }
        else if (!this.settings.IsStateEditable(this.processor.SupplyRequest.State, this.processor.SupplyRequest.State))
        {
            divMainWarning.InnerText = "You can't edit this AMM supply request (current stage not editable from this desktop)";
            divMainWarning.Visible = true;
        }
        else
        {
            divMainWarning.Visible = false;
        }
    }

    /// <summary>Validate the current stage</summary>
    /// <returns>If stage is valid</returns>
    private bool ValidateCurrentStage()
    {
        // clear existing error message
        this.GetAllControlsByType<HtmlContainerControl>().Where(c => c.Attributes["class"] != null && c.Attributes["class"].Contains("ErrorMessage")).ToList().ForEach(c => c.InnerHtml = "&nbsp;");
        
        // Validate current wizard step
        bool valid = true;
        switch (this.processor.SupplyRequest.State)
        {
        case aMMState.WaitingScheduling:     valid = this.ValidateWaitingScheduling();     break;
        case aMMState.WaitingProductionTray: valid = this.ValidateWaitingProductionTray(); break;
        case aMMState.ReadyToAssemble:       valid = this.ValidateReadyToAssemble();       break;
        case aMMState.ReadyToCheck:          valid = this.ValidateReadyToCheck();          break;
        case aMMState.ReadyToCompound:       valid = this.ValidateReadyToCompound();       break;
        case aMMState.FinalCheck:            valid = this.ValidateFinalCheck();            break;
        case aMMState.BondStore:             valid = this.ValidateBondStore();             break;
        case aMMState.ReadyToRelease:        valid = this.ValidateReadyToRelease();        break;
        }     

        return valid;
    }

    /// <summary>
    /// Save details for current stage and then
    /// move to next stage
    /// </summary>
    private void MoveNextStage()
    {
        int? enityId_Alternate = null; // Used for second check 
        DateTime now = DateTime.Now;
        bool issueIngredients = false;

        // Save current stage details
        switch (this.processor.SupplyRequest.State)
        {
        case aMMState.WaitingScheduling:
            var shift = aMMShift.GetById(int.Parse(ddlScheduleShift.SelectedValue));
            this.processor.SupplyRequest.ManufactureShiftID = shift.AMMShiftID;
            this.processor.SupplyRequest.ManufactureDate = shift.CalculateManufactureDate(dpScheduleDate.SelectedDate.Value);
            this.processor.UpdateSupplyRequestExpiry(); 
            break;

        case aMMState.WaitingProductionTray:
            this.processor.SupplyRequest.ProductionTrayBarcode = tbProductionTrayBarcode.Text;
            break;

        case aMMState.ReadyToCheck:
            this.tbReadToCheck.Text = string.Empty;     // Cleared so forces info to be reset incase of undo
            this.processor.SupplyRequest.SecondCheckType = aMMSetting.SecondCheck;
            switch (aMMSetting.SecondCheck)
            {
            case aMMSecondCheckType.SingleCheck:                enityId_Alternate = ucReadyToCheckSingleCheck.EntityId;          break;
            case aMMSecondCheckType.IndividualCheckSingleUser:  enityId_Alternate = this.ucReadyToCheckIndividualCheck.EntityId; break;
            }
            break;

        case aMMState.ReadyToCompound:
            this.tbReadyToCompound.Text = string.Empty; // Cleared so forces info to be reset incase of undo
            this.processor.SupplyRequest.CompoundingDate = now;
            this.processor.UpdateSupplyRequestExpiry(); 
            issueIngredients = true;
            
             //store the compounded image
            if (aMMSetting.CaptureManufacturedImage)
            {
                if (hfImageData.Value != null)
                {
                    var imagebytes = Convert.FromBase64String(hfImageData.Value);
                    this.processor.SupplyRequest.SetCompoundedImage(imagebytes);   

                    //Clear the hidden field data
                    hfImageData.Value = null;
                }
            }           
            break;

        case aMMState.ReadyToLabel:
            this.tbReadyToLabel.Text = string.Empty;    // Cleared so forces info to be reset in-case of undo
            if (!string.IsNullOrWhiteSpace(hfWLabelId.Value))
            {
                this.processor.SupplyRequest.RequestIdWLabel = int.Parse(hfWLabelId.Value);
                this.processor.SupplyRequest.IfHadLabelStage = true;
                this.processor.ResyncLabel(this.processor.SupplyRequest.RequestIdWLabel.Value);
                this.processor.PrintedLabel(reprint: false);
            }
            break;

        case aMMState.FinalCheck:
            enityId_Alternate = ucFinalCheck.Visible ? ucFinalCheck.EntityId : null;
            this.tbFinalCheck.Text = string.Empty;    // Cleared so forces info to be reset incase of undo
            this.processor.SupplyRequest.SelfCheckReason = ucFinalCheck.SelfCheckReason;
            break;
        
        case aMMState.BondStore:
            this.tbBondStore.Text = string.Empty;   // Cleared so forces info to be reset incase of undo
            break;
        
        case aMMState.ReadyToRelease:
            this.tbReadyToRelease.Text = string.Empty;   // Cleared so forces info to be reset incase of undo
            break;
        }

        // Move to next stage
        try
        {
            bool issued = true;
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                this.processor.MoveNextStage(enityId_Alternate);

                // Do the issuing here as easier to work out what the issuing state should be
                // Might of been best to have a function on processor to determine the next stage so can do this above.
                if (issueIngredients && this.processor.SupplyRequest.State > aMMState.ReadyToCompound)
                    issued = this.Issue(false, aMMIssueState.IssuedIngredients);

                switch (this.processor.SupplyRequest.State)
                {                
                case aMMState.BondStore:       issued = this.Issue(false, aMMIssueState.IssuedToBondStore);     break;
                case aMMState.ReadyToRelease:  issued = this.Issue(false, aMMIssueState.ReleasedFromBondStore); break;
                case aMMState.Completed:       issued = this.Issue(false, aMMIssueState.IssuedToPatient);       break;
                }

                if (issued)
                    trans.Commit();
            }

            // If set the auto close supply request when reached the last stage in the desktop
            if (this.settings.ToStage != null && this.processor.SupplyRequest.State > this.settings.ToStage && issued && aMMSetting.AutoCloseWhenLastDesktopStage)
            {
                this.ClosePage(this.settings.RequestId.ToString());
            }
        }
        catch (DBConcurrencyException)
        {
            // Reload the processor
            aMMProcessor.ClearCache(settings.RequestId);
            this.processor = aMMProcessor.Create(settings.RequestId);

            // Display warning to the user
            ScriptManager.RegisterStartupScript(this, this.GetType(), "UpdateByAnotherUser", "alert('Changes were not saved as already updated by another user.');", true);
        }

        // Update form
        this.UpdateStageBoxes();
        ScriptManager.RegisterStartupScript(this, this.GetType(), "setScrollPos", "scrollToActiveStage();", true);
    }

    /// <summary>
    /// Performs the issue
    /// The issue performed will depend on the current supply request IssueState.
    /// At the end of the process the supply request IssueState will be updated.
    /// Manual issues will be logged in the audit log.
    /// </summary>
    /// <param name="manualIssue">If user is doing manual issue (by clicking buttons on top of supply request)</param>
    /// <param name="forceIssueToPatient">forces the issue to the patient (if passed issue to ingredient stage)</param>
    /// <returns>Returns if issues went okay</returns>
    private bool Issue(bool manualIssue, aMMIssueState nextIssueState)
    {
        List<IssueStockLine>    lines               = new List<IssueStockLine>();
        aMMSupplyRequestRow     supplyRequest       = this.processor.SupplyRequest;
        WProductRow             product             = this.processor.Product;
        string                  ManuCostCentre      = PatMedSetting.Manufacturing.CostCenter();
        bool                    allowedMoveNextStage= false;
        IssueStockLine          line;

        if (supplyRequest.IssueState == aMMIssueState.None && nextIssueState >= aMMIssueState.IssuedIngredients)
        {
            // Issue ingredients
            foreach(var i in this.processor.SupplyRequestIngredients)
            {
                var ing = this.processor.GetIngredientProduct(i.NSVCode);
                line = new IssueStockLine();
                line.QuantityInIssueUnits           = (decimal)i.QtyInIssueUnits;
                line.CostExVat                      = (line.QuantityInIssueUnits / ing.ConversionFactorPackToIssueUnits) * ing.AverageCostExVatPerPack;
                line.BatchNumber                    = i.BatchNumber;
                line.ManufacturingBatchNumber       = supplyRequest.BatchNumber;
                line.BatchExpiryDate                = i.ExpiryDate;
                line.CostCentreCode                 = ManuCostCentre;
                line.IssueType                      = IssueType.ManufactureIngredient;
                line.NSVCode                        = i.NSVCode;
                line.RequestIdPrescription          = this.processor.Prescription.RequestID;
                line.RequestIdAmmSupplyRequest      = supplyRequest.RequestID;
                line.AmmSupplyRequestIngredientId   = i.aMMSupplyRequestIngredientId;
                line.CivasAmount                    = supplyRequest.QuantityRequested;
                line.PrescriptionNum                = supplyRequest.PrescriptionNumber.ToString();
                lines.Add(line);
            }

            // Issue compounded drug to MANU cost center
            line = new IssueStockLine();
            line.QuantityInIssueUnits       = -supplyRequest.QuantityRequested.Value;
            line.CostExVat                  = (line.QuantityInIssueUnits / product.ConversionFactorPackToIssueUnits) * product.AverageCostExVatPerPack;
            line.BatchNumber                = supplyRequest.BatchNumber;
            line.BatchExpiryDate            = supplyRequest.ExpiryDate;
            line.CostCentreCode             = ManuCostCentre;
            line.IssueType                  = IssueType.Manufacture;
            line.NSVCode                    = product.NSVCode;
            line.RequestIdPrescription      = this.processor.Prescription.RequestID;
            line.RequestIdAmmSupplyRequest  = supplyRequest.RequestID;
            line.CivasAmount                = supplyRequest.QuantityRequested;
            line.PrescriptionNum            = supplyRequest.PrescriptionNumber.ToString();
            lines.Add(line);
        
            allowedMoveNextStage = true;
        }

        if (this.processor.IfBondStore && supplyRequest.IssueState <= aMMIssueState.IssuedIngredients && nextIssueState == aMMIssueState.IssuedToBondStore)
        {
            // Bond store issue (only occurs if issued ingredients and there is a bond store)
            line = new IssueStockLine();        
            line.QuantityInIssueUnits       = -supplyRequest.QuantityRequested.Value;
            line.CostExVat                  = (supplyRequest.QuantityRequested.Value / product.ConversionFactorPackToIssueUnits) * product.AverageCostExVatPerPack;
            line.BatchNumber                = supplyRequest.BatchNumber;
            line.BatchExpiryDate            = supplyRequest.ExpiryDate;
            line.CostCentreCode             = PatMedSetting.Manufacturing.BondCostCenter();
            line.IssueType                  = IssueType.Bond;
            line.NSVCode                    = product.NSVCode;
            line.RequestIdPrescription      = this.processor.Prescription.RequestID;
            line.RequestIdAmmSupplyRequest  = supplyRequest.RequestID;
            line.PrescriptionNum            = supplyRequest.PrescriptionNumber.ToString();
            line.CivasAmount                = supplyRequest.QuantityRequested;
            lines.Add(line);
        
            allowedMoveNextStage = true;
        }

        if (this.processor.IfBondStore && supplyRequest.IssueState == aMMIssueState.IssuedToBondStore && nextIssueState >= aMMIssueState.ReleasedFromBondStore)
        {
            // Bond store return (only occurs if issued ingredients and there is a bond store)
            line = new IssueStockLine();        
            line.QuantityInIssueUnits       = supplyRequest.QuantityRequested.Value;
            line.CostExVat                  = (supplyRequest.QuantityRequested.Value / product.ConversionFactorPackToIssueUnits) * product.AverageCostExVatPerPack;
            line.BatchNumber                = supplyRequest.BatchNumber;
            line.BatchExpiryDate            = supplyRequest.ExpiryDate;
            line.CostCentreCode             = PatMedSetting.Manufacturing.BondCostCenter();
            line.IssueType                  = IssueType.Bond;
            line.NSVCode                    = product.NSVCode;
            line.RequestIdPrescription      = this.processor.Prescription.RequestID;
            line.RequestIdAmmSupplyRequest  = supplyRequest.RequestID;
            line.PrescriptionNum            = supplyRequest.PrescriptionNumber.ToString();
            line.CivasAmount                = supplyRequest.QuantityRequested;
            lines.Add(line);
        
            allowedMoveNextStage = true;
        }

        if (supplyRequest.IssueState <= aMMIssueState.ReleasedFromBondStore && nextIssueState == aMMIssueState.IssuedToPatient)
        {
            // Issue to patient (only occurs if ingredient issue is done and no bond store, or it has been release from bond store)

            var episode = Episode.GetByEpisodeID(supplyRequest.EpisodeID);
            var ward    = episode == null ? null : episode.GetWard();
        
            line = new IssueStockLine();        
            line.QuantityInIssueUnits       = supplyRequest.QuantityRequested.Value;
            line.CostExVat                  = (supplyRequest.QuantityRequested.Value / product.ConversionFactorPackToIssueUnits) * product.AverageCostExVatPerPack;
            line.BatchNumber                = supplyRequest.BatchNumber;
            line.BatchExpiryDate            = supplyRequest.ExpiryDate;
            line.CostCentreCode             = ward == null ? string.Empty : ward.Code;
            line.IssueType                  = IssueStockLineProcessor.GetIssueTypeFromEpisodeType(supplyRequest.EpisodeType);
            line.LabelType                  = WTranslogType.Manufacturing;
            line.NSVCode                    = product.NSVCode;
            line.RequestIdPrescription      = this.processor.Prescription.RequestID;
            line.RequestIdAmmSupplyRequest  = supplyRequest.RequestID;
            line.CivasAmount                = supplyRequest.QuantityRequested;
            line.PrescriptionNum            = supplyRequest.PrescriptionNumber.ToString();
            lines.Add(line);
        
            allowedMoveNextStage = true;
        }

        // Save issue to db
        try
        {
            using (IssueStockLineProcessor issueProcessor = new IssueStockLineProcessor())
            {
                issueProcessor.Lock(SessionInfo.SiteID, lines);
                issueProcessor.Update(SessionInfo.SiteID, supplyRequest.EpisodeID, lines);
            }

            if (allowedMoveNextStage)
                this.processor.UpdateIssueState(nextIssueState, manualIssue);

            return true;
        }
        catch (ApplicationException ex)
        {
            string script = "Failed to issue:\n" + ex.Message;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "error", "alert(JavaStringUnescape('" + script.JavaStringEscape() + "'))", true);
        }

        return false;
    }

    /// <summary>
    /// Performs the return
    /// The issue performed will depend on the current supply request IssueState.
    /// At the end of the process the supply request IssueState will be updated.
    /// Manual returns will be logged in the audit log.
    /// </summary>
    /// <param name="manualIssue">If user is doing manual return (by clicking buttons on top of supply request)</param>
    /// <returns>Returns if went okay</returns>
    private bool Return(bool manualIssue, aMMIssueState nextIssueState)
    {
        List<IssueStockLine> lines              = new List<IssueStockLine>();
        aMMSupplyRequestRow  supplyRequest      = this.processor.SupplyRequest;
        WProductRow          product            = this.processor.Product;
        string               ManuCostCentre     = PatMedSetting.Manufacturing.CostCenter();
        bool                 allowedMoveNextStage= false;
        IssueStockLine       line;

        // If issued to patient then return to patient
        if (supplyRequest.IssueState == aMMIssueState.IssuedToPatient && nextIssueState < aMMIssueState.IssuedToPatient)
        {
            line = new IssueStockLine();
            line.QuantityInIssueUnits       = -supplyRequest.QuantityRequested.Value;
            line.CostExVat                  = (line.QuantityInIssueUnits / product.ConversionFactorPackToIssueUnits) * product.AverageCostExVatPerPack;
            line.BatchNumber                = supplyRequest.BatchNumber;
            line.BatchExpiryDate            = supplyRequest.ExpiryDate;
            line.CostCentreCode             = ManuCostCentre;
            line.IssueType                  = IssueType.Manufacture;
            line.NSVCode                    = product.NSVCode;
            line.RequestIdPrescription      = this.processor.Prescription.RequestID;
            line.RequestIdAmmSupplyRequest  = supplyRequest.RequestID;
            line.CivasAmount                = supplyRequest.QuantityRequested;
            line.PrescriptionNum            = supplyRequest.PrescriptionNumber.ToString();
            lines.Add(line);

            allowedMoveNextStage = true;
        }

        if (this.processor.IfBondStore && !manualIssue && supplyRequest.IssueState >= aMMIssueState.ReleasedFromBondStore && nextIssueState < aMMIssueState.ReleasedFromBondStore)
        {
            // Bond store issue (only occurs if issued ingredients and there is a bond store)
            line = new IssueStockLine();        
            line.QuantityInIssueUnits       = -supplyRequest.QuantityRequested.Value;
            line.CostExVat                  = (supplyRequest.QuantityRequested.Value / product.ConversionFactorPackToIssueUnits) * product.AverageCostExVatPerPack;
            line.BatchNumber                = supplyRequest.BatchNumber;
            line.BatchExpiryDate            = supplyRequest.ExpiryDate;
            line.CostCentreCode             = PatMedSetting.Manufacturing.BondCostCenter();
            line.IssueType                  = IssueType.Bond;
            line.NSVCode                    = product.NSVCode;
            line.RequestIdPrescription      = this.processor.Prescription.RequestID;
            line.RequestIdAmmSupplyRequest  = supplyRequest.RequestID;
            line.PrescriptionNum            = supplyRequest.PrescriptionNumber.ToString();
            line.CivasAmount                = supplyRequest.QuantityRequested;
            lines.Add(line);

            allowedMoveNextStage = true;
        }

        if (this.processor.IfBondStore && !manualIssue && supplyRequest.IssueState >= aMMIssueState.IssuedToBondStore && nextIssueState < aMMIssueState.IssuedToBondStore)
        {
            // Bond store issue (only occurs if issued ingredients and there is a bond store)
            line = new IssueStockLine();        
            line.QuantityInIssueUnits       = supplyRequest.QuantityRequested.Value;
            line.CostExVat                  = (supplyRequest.QuantityRequested.Value / product.ConversionFactorPackToIssueUnits) * product.AverageCostExVatPerPack;
            line.BatchNumber                = supplyRequest.BatchNumber;
            line.BatchExpiryDate            = supplyRequest.ExpiryDate;
            line.CostCentreCode             = PatMedSetting.Manufacturing.BondCostCenter();
            line.IssueType                  = IssueType.Bond;
            line.NSVCode                    = product.NSVCode;
            line.RequestIdPrescription      = this.processor.Prescription.RequestID;
            line.RequestIdAmmSupplyRequest  = supplyRequest.RequestID;
            line.PrescriptionNum            = supplyRequest.PrescriptionNumber.ToString();
            line.CivasAmount                = supplyRequest.QuantityRequested;
            line.BondStoreReturn   = true;
            lines.Add(line);

            allowedMoveNextStage = true;
        }

        if (supplyRequest.IssueState >= aMMIssueState.IssuedIngredients && nextIssueState == aMMIssueState.None)
        {
            // Return ingredients
            foreach(var i in this.processor.SupplyRequestIngredients)
            {
                var ing = this.processor.GetIngredientProduct(i.NSVCode);
                line    = new IssueStockLine();

                line.QuantityInIssueUnits           = -(decimal)i.QtyInIssueUnits;
                line.CostExVat                      = (line.QuantityInIssueUnits / ing.ConversionFactorPackToIssueUnits) * ing.AverageCostExVatPerPack;
                line.BatchNumber                    = i.BatchNumber;
                line.ManufacturingBatchNumber       = supplyRequest.BatchNumber;
                line.BatchExpiryDate                = i.ExpiryDate;
                line.CostCentreCode                 = ManuCostCentre;
                line.IssueType                      = IssueType.ManufactureIngredient;
                line.NSVCode                        = i.NSVCode;
                line.RequestIdPrescription          = this.processor.Prescription.RequestID;
                line.RequestIdAmmSupplyRequest      = supplyRequest.RequestID;
                line.AmmSupplyRequestIngredientId   = i.aMMSupplyRequestIngredientId;
                line.CivasAmount                    = -supplyRequest.QuantityRequested;
                line.PrescriptionNum                = supplyRequest.BatchNumber;
                lines.Add(line);
            }
        
            // Return compounded drug to MANU cost center
            line = new IssueStockLine();        
            line.QuantityInIssueUnits       = supplyRequest.QuantityRequested.Value;
            line.CostExVat                  = (line.QuantityInIssueUnits / product.ConversionFactorPackToIssueUnits) * product.AverageCostExVatPerPack;
            line.BatchNumber                = supplyRequest.BatchNumber;
            line.BatchExpiryDate            = supplyRequest.ExpiryDate;
            line.CostCentreCode             = ManuCostCentre;
            line.IssueType                  = IssueType.Manufacture;
            line.NSVCode                    = product.NSVCode;
            line.RequestIdPrescription     = this.processor.Prescription.RequestID;
            line.RequestIdAmmSupplyRequest = supplyRequest.RequestID;
            line.CivasAmount                = supplyRequest.QuantityRequested;
            line.PrescriptionNum            = supplyRequest.BatchNumber;
            lines.Add(line);

            allowedMoveNextStage = true;
        }

        // Save return to db
        try
        {
            using (IssueStockLineProcessor issueProcessor = new IssueStockLineProcessor())
            {
                issueProcessor.Lock(SessionInfo.SiteID, lines);
                issueProcessor.Update(SessionInfo.SiteID, supplyRequest.EpisodeID, lines);
            }

            if (allowedMoveNextStage)
                this.processor.UpdateIssueState(nextIssueState, manualIssue);
            return true;
        }
        catch (ApplicationException ex)
        {
            string msg = "Failed to return:\n" + ex.Message;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "error", "alert(JavaStringUnescape('" + msg.JavaStringEscape() + "'));", true);
        }

        return false;
    }

    /// <summary>Move back to previous safe</summary>
    private void MoveBackStage()
    {
        bool moveBack = false;

        switch (this.processor.SupplyRequest.State)
        {
        case aMMState.ReadyToAssemble:
            // Undo ingredient individually (delete from DB)
            var lastAssembledDate = this.processor.SupplyRequestIngredients.Max(i => i.AssembledByDate);
            this.processor.SupplyRequest.ProductionTrayBarcode = string.Empty;  // XN 1Jun16 157114 Added 
            this.processor.SupplyRequestIngredients.RemoveAll(i => i.AssembledByDate == lastAssembledDate);
            this.processor.SupplyRequestIngredients.Save();
            this.processor.UpdateSupplyRequestExpiry(true);
            moveBack = !this.processor.SupplyRequestIngredients.Any();
            break;
        
        case aMMState.ReadyToCheck:
            // Undo ready to check individually
            var checkedByDate = this.processor.SupplyRequestIngredients.Max(i => i.CheckedByDate);
            this.processor.SupplyRequestIngredients.Where(i => i.CheckedByDate == checkedByDate).ToList().ForEach(i => i.ClearChecked());
            this.processor.SupplyRequestIngredients.Save();
            moveBack = this.processor.SupplyRequestIngredients.All(i => i.CheckedByDate == null);
            break;

        case aMMState.ReadyToLabel:
            // Checking for releasing ingredients is done below
            moveBack = true;
            break;

        case aMMState.FinalCheck:
            this.processor.SupplyRequest.SelfCheckReason = string.Empty;
            moveBack = true;
            break;

        case aMMState.BondStore:
            moveBack = this.Return(false, aMMIssueState.IssuedIngredients);
            break;

        case aMMState.ReadyToRelease:
            if (this.processor.IfBondStore)
                moveBack = this.Return(false, aMMIssueState.IssuedToBondStore);
            else
                moveBack = this.Return(false, aMMIssueState.IssuedIngredients);
            break;

        default:
            moveBack = true;
            break;
        }

        // If back stage is compounding then need to return ingredients
        // Very difficult to determine this so need to manually calculate
        if (moveBack)
        {
            var nextState = this.processor.SupplyRequest.State - 1;
            if (nextState == aMMState.BondStore && !this.processor.IfBondStore)
                nextState--;
            if (nextState == aMMState.FinalCheck && aMMSetting.FinalCheck == aMMFinalCheckType.None)
                nextState--;
            if (nextState == aMMState.ReadyToLabel && !aMMSetting.IfReadyToLabel)
                nextState--;

            if (nextState == aMMState.ReadyToCompound)
            {
                moveBack = this.Return(false, aMMIssueState.None);
                if (moveBack)
                {
                    this.processor.SupplyRequest.CompoundingDate = null;
                    this.processor.UpdateSupplyRequestExpiry(); 
                }
            }
        }

        if (moveBack)
        {
            this.processor.MoveBackStage();

            // If reached some stages need to do a bit of extra work to ensure the flow works
            switch (this.processor.SupplyRequest.State)
            {
            case aMMState.WaitingScheduling:
                // Clear waiting to schedule
                this.processor.ClearManufactureDate();
                break;

            case aMMState.ReadyToCheck:
                // Undo ready to check individually
                var checkedByDate = this.processor.SupplyRequestIngredients.Max(i => i.CheckedByDate);
                this.processor.SupplyRequestIngredients.Where(i => i.CheckedByDate == checkedByDate).ToList().ForEach(i => i.ClearChecked());
                this.processor.SupplyRequestIngredients.Save();
                break;

            // 26Aug16 KR Added. 161136 & 161135
            case aMMState.ReadyToCompound:
                if (aMMSetting.CaptureManufacturedImage)
                {
                    this.hfImageData.Value = string.Empty;
                    this.imgManufacturedProduct.ImageUrl = string.Empty;
                }

                if (!aMMSetting.IfReadyToLabel)
                    this.processor.ReturnLabel();
                break;
            
            case aMMState.ReadyToLabel:
                // Return the label (better done here than above as final check, and bond store stage might not be present)
                this.processor.ReturnLabel();
                break;
            }

            // If set the auto close supply request when reached the last stage in the desktop 02Aug16 XN  159413
            if (this.settings.FromStage != null && this.processor.SupplyRequest.State < this.settings.FromStage && aMMSetting.AutoCloseWhenLastDesktopStage)
                this.ClosePage(this.settings.RequestId.ToString());
        }

        // Update form
        this.UpdateStageBoxes();
        ScriptManager.RegisterStartupScript(this, this.GetType(), "setScrollPos", "scrollToActiveStage();", true);
    }
    
    /// <summary>
    /// Called when user clicks the issue button
    /// Checks the user can issue, and asks the user to confirm
    /// </summary>
    private void CheckCanIssue()
    {
        if (this.processor.SupplyRequest.State <= aMMState.ReadyToAssemble)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "cantIssue", "alert('Can only issue once ingredients have been gathered.');", true);
            return;
        }
        else if (this.processor.SupplyRequest.IssueState == aMMIssueState.IssuedToPatient)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "cantIssue", "alert('Has already been issued.');", true);
            return;
        }

        string msg = string.Empty;
        switch (this.processor.SupplyRequest.IssueState)
        {
        case aMMIssueState.None: 
            msg = "Do you want to issue ingredients?"; 
            break;
        case aMMIssueState.IssuedIngredients:
            msg = "Do you want to issue to patient?";
            if (this.processor.IfBondStore)
                msg += "\n(won't go to bond store)";
            break;
        case aMMIssueState.ReleasedFromBondStore:
        case aMMIssueState.IssuedToBondStore:
            msg = "Do you want to issue to patient?";             
            break;
        }

        ScriptManager.RegisterStartupScript(this, this.GetType(), "", "askToIssue('" + msg.JavaStringEscape(quotesToEscape: "'") + "');", true);
    }
        
    /// <summary>
    /// Called when user clicks the return button
    /// Checks the user can return, and asks the user to confirm
    /// </summary>
    private void CheckCanReturn()
    {
        var supplyRequest = this.processor.SupplyRequest;
        if (supplyRequest.IssueState == aMMIssueState.None)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "cantRetrun", "alert('Nothing has been issued yet.');", true);
        }
        else if (!this.settings.IsPrescriptionCancelled &&
                 ((supplyRequest.IssueState == aMMIssueState.IssuedIngredients && supplyRequest.State >  aMMState.ReadyToCompound) || 
                  (supplyRequest.IssueState >= aMMIssueState.IssuedToBondStore && supplyRequest.State >= aMMState.BondStore)))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "cantRetrun", "alert('Issuing is correct for supply request state\\nSo use undo instead.');", true);
        }
        else if (supplyRequest.IssueState < aMMIssueState.IssuedToPatient)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "returnConfirmCallBackFn(confirm('Return ingredient and undo manufacturing issue?'));", true);
        }
        else if (supplyRequest.IssueState == aMMIssueState.IssuedToPatient)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "", "returnConfirmCallBackFn(confirm('Return manufacturing product from patient?'));", true);
        }
    }

    #endregion
}
