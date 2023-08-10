// -----------------------------------------------------------------------
// <copyright file="ICW_aMMWorkflow.aspx.cs" ccompany="Ascribe Ltd.">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
// Part of the Aseptic Manufacture Module and is used to display a list of 
// prescriptions and\or supply requests in the system. The desktop is used for 
// both the AMM Screening, and AMM Workflow desktops.
//
//  The worklist can be populated by sps
//      pAMMSupplyRequestFromParent
//      pAMMPrescriptionScreening
//
//  The list can be used as a single, or two level list (with prescription and supply request)
//  Separate routines can be used to populate each level of this list.
//  SPs for level 1 will be passed parameters
//      SiteID      - current site ID
//      RequestID   - only set if need to update single row in the list
//      EpisodeID   - currently selected episode if desktop parameter SelectEpidode is false
//      WardID      - currently selected ward
//      DueDate     - currently selected due date
//  SPs for level 2 will be passed parameters
//      SiteID           - current site ID
//      RequestID        - only set if need to update single row in the list
//      RequestID_Parent - Parent request for the current level
//      WardID           - currently selected ward
//      DueDate          - currently selected due date
//
//  The page expects the following URL parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Site number
//  SelectEpisode       - True to use this application as a way of selecting an episode
//  RoutineLevel1       - SPs to run for level 1 and 2 of the work list
//  RoutineLevel2
//  ShowDueDate         - if to show due date list
//  DefaultDueDate      - default due date for the list
//  AMMSupplyRequestButtons-Buttons that can be displayed on AMM Supply Request
//  DisplayForNextShifts- Number of shifts supply request to be displayed for
//  FromStage           - Show supply request from this stage
//  ToStage             - Show supply request to this stage
//  ReadOnly            - If desktop is read-only
//  SpecificShift       - Show supply requests for specific shift only.
// 
//  Modification History:
//  31May15 XN Created 39882
//  15Aug16 XN 159843 Added Date Range parameter
//  26Aug16 XN 161234 Fixed script error and removed dead code
// </summary
// -----------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using Ascribe.Core.Extensions;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.manufacturinglayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;
using Telerik.Web.UI;
using Newtonsoft.Json.Converters;

public partial class application_aMMWorkflow_ICW_aMMWorkflow : System.Web.UI.Page
{
    #region Constants
    /// <summary>Data keys required from the level 1 sp</summary>
    protected static readonly string[] Level1DataKeys = new[] { "RequestID", "RequestType", "RequestTypeID", "EpisodeID", "EntityID", "HasChildren", "AMMManufactureComplete", "AMMForManufacture", "Priority", "Barcode", "ManufactureShiftID", "ManufactureDate", "Complete", "Request Cancellation" };

    /// <summary>Data keys required from the level 2 sp</summary>
    protected static readonly string[] Level2DataKeys = new[] { "RequestID", "RequestType", "RequestTypeID", "RequestID_Parent", "Priority", "EpisodeID", "EntityID", "Barcode", "Complete", "Request Cancellation"  };
    //protected static readonly string[] Level2DataKeys = new[] { "RequestID", "RequestType", "RequestTypeID", "RequestID_Parent", "Priority", "Barcode", "Complete", "Request Cancellation"  }; 02Aug16 XN  159413 added EpisodeID, EntityID
    #endregion

    #region Data Types
    /// <summary>Aseptic manufacturing module view settings</summary>
    public struct aMMWorflowViewSettings 
    {
        /// <summary>Gets or sets a value indicating whether worklist is used as a way of selecting an episode</summary>
        public bool SelectEpisode;

        /// <summary>Gets or sets the routines used to populate the worklist (normally 2 routines for each level)</summary>
        public string[] Routine;

        /// <summary>Gets or sets a value indicating whether if worklist is read-only</summary>
        public bool ReadOnly;

        /// <summary>Gets or sets the selected from date will always be lower than ToDate (depends on if using due date or date range)</summary>
        public DateTime? FromDate;

        /// <summary>Gets or sets the selected to date will always be lower than FromDate (depends on if using due date or date range)</summary>
        public DateTime? ToDate;

        /// <summary>Gets or sets the selected episode id</summary>
        public int? SelectedEpisodeID;

        /// <summary>Gets or sets if supply requests are shown for next x shifts</summary>
        public  int? ShowForNextShifts;

        /// <summary>Gets or sets state from which supply request will be shown</summary>
        public aMMState? FromStage;
        
        /// <summary>Gets or sets state to which supply request will be shown</summary>
        public aMMState? ToStage;

        /// <summary>Application path</summary>
        public string ApplicationPath;

        /// <summary>Supply request buttons</summary>
        public string AmmSupplyRequestButtons;

        /// <summary>Gets the note type ID for the AMMForManufacture note</summary>
        public int NoteTypeID_ForManufacture;
        
        /// <summary>Gets the note type ID for the AMMManufactureComplete note</summary>
        public int NoteTypeID_ManufactureComplete;

        /// <summary>The supply request type ID (from ICW request types table</summary>
        public int RequestTypeID_SupplyRequest;

        /// <summary>If rows are divided by shift section headers</summary>
        public bool ShiftSectionHeader;

        //22Aug16 KR Added. 160246 aMMShifts are not displayed correctly in aMM Waiting Production Tray
        /// <summary>Gets or sets the specific shift</summary>
        public int? ShiftID;
    }
    #endregion

    #region Member Variables
    /// <summary>AMM workflow view settings </summary>
    protected aMMWorflowViewSettings viewSettings = new aMMWorflowViewSettings();

    #endregion

    #region Events Handlers
    /// <summary>The page_ load</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The event args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        if (this.IsPostBack)
        {
            this.viewSettings = JsonConvert.DeserializeObject<aMMWorflowViewSettings>(hfViewSettings.Value);
        }
        else
        {
            // Get parameters
            this.viewSettings.ReadOnly                      = ConvertExtensions.ChangeType<bool>(this.Request["ReadOnly"],          false);
            this.viewSettings.SelectEpisode                 = ConvertExtensions.ChangeType<bool>(this.Request["SelectEpisode"],     true);
            this.viewSettings.ShowForNextShifts             = ConvertExtensions.ChangeType<int?>(this.Request["ShowForNextShifts"], null);
            this.viewSettings.FromStage                     = ConvertExtensions.ChangeType<aMMState?>(this.Request["StageFrom"],    null);
            this.viewSettings.ToStage                       = ConvertExtensions.ChangeType<aMMState?>(this.Request["StageTo"],      null);
            this.viewSettings.NoteTypeID_ForManufacture     = ICWTypes.GetTypeByDescription(ICWType.Note,   "AMMForManufacture").Value.ID;
            this.viewSettings.NoteTypeID_ManufactureComplete= ICWTypes.GetTypeByDescription(ICWType.Note,   "AMMManufactureComplete").Value.ID;
            this.viewSettings.RequestTypeID_SupplyRequest   = ICWTypes.GetTypeByDescription(ICWType.Request,"Supply Request").Value.ID;
            this.viewSettings.AmmSupplyRequestButtons       = this.Request["AMMSupplyRequestButtons"];
            this.viewSettings.ApplicationPath               = this.Request["ApplicationPath"] ?? string.Empty;
            this.viewSettings.ShiftSectionHeader            = ConvertExtensions.ChangeType<bool>(this.Request["ShiftSectionHeader"],false);

           this.viewSettings.Routine = new [] { this.Request["RoutineLevel1"], this.Request["RoutineLevel2"] };
            if (string.IsNullOrEmpty(this.viewSettings.Routine[0]))
            {
                this.Response.Redirect("~\\application\\pharmacysharedscripts\\DesktopError.aspx?ErrorMessage=Need to set a desktop parameter RoutineLevel1");    
                return;
            }

            // Setup due date filter
            this.trToolbarFilters.Visible = true;
            if (BoolExtensions.PharmacyParseOrNull(this.Request["ShowDueDate"]) ?? false)
            {
                pnDueDate.Visible = true;
                var defaultDueDate = this.Request["DefaultDueDate"] ?? "-1";
                
                LookupList lookup = new LookupList();
                lookup.LoadByAMMDateRangePast();

                ddlDueDate.Items.AddRange(lookup.Select(w => new RadComboBoxItem(w.Descritpion, w.DBID.ToString())).ToArray());
                ddlDueDate.SelectedIndex = ddlDueDate.Items.FindItemIndexByValue(defaultDueDate);
                if (ddlDueDate.SelectedIndex == -1)
                    ddlDueDate.SelectedIndex = 0;

                this.viewSettings.FromDate= DateTime.Now.ToStartOfDay();
                this.viewSettings.ToDate  = DateTime.Now.AddDays(int.Parse(ddlDueDate.SelectedValue)).ToEndOfDay();
                this.radToolbarFilters.Width = new System.Web.UI.WebControls.Unit("190px");
            }

            // Setup date range filter
            if (BoolExtensions.PharmacyParseOrNull(this.Request["ShowDateRange"]) ?? false)
            {
                pnDateRange.Visible = true;
                dpDateRangeTo.MaxDate     = DateTime.Today;
                dpDateRangeTo.SelectedDate= DateTime.Today;

                this.viewSettings.ToDate    = dpDateRangeTo.SelectedDate.Value.ToEndOfDay();
                this.viewSettings.FromDate  = this.viewSettings.ToDate.Value.AddDays(-aMMSetting.Worklist.DateRangeInDays); 
                this.radToolbarFilters.Width= new System.Web.UI.WebControls.Unit("350px");
                this.tbDateRangeFrom.Text   = this.viewSettings.FromDate.ToPharmacyDateString();
            }

            this.trToolbarFilters.Visible = this.trToolbarFilters.GetAllControlsByType<System.Web.UI.WebControls.Panel>().Any(p => p.Visible);

            // If episode mode, and no episode (read from state table)
            if (!this.viewSettings.SelectEpisode)
            {
                this.viewSettings.SelectedEpisodeID = (new GENRTL10.StateRead()).GetKey(SessionInfo.SessionID, "Episode");
            }

            // 22Aug16 KR Added. 160246 aMMShifts are not displayed correctly in aMM Waiting Production Tray
            // Use DisplayForNextShifts to calculate the ToDate if set
            if (this.viewSettings.ShowForNextShifts != null)
            {
                int displayForshifts = this.viewSettings.ShowForNextShifts ?? 0;
                {
                    this.viewSettings.ToDate = aMMShift.CalculateTimeToEndOfNthShift(DateTime.Now, displayForshifts);
                    this.viewSettings.FromDate = null;
                }  
            }

            // Setup the shift filter. If a shift is specified, determine the shift ID
            string shiftName = this.Request["SpecificShift"] ?? string.Empty;
            if (shiftName != string.Empty)
            {
                var shift = aMMShift.GetAll().FirstOrDefault(s => s.Description.EqualsNoCase(shiftName));
                this.viewSettings.ShiftID = (shift!=null) ? shift.AMMShiftID : (int?) null;
            }
            else
            {
                this.viewSettings.ShiftID = (int?) null;
            }
           
            // Populate grid
            PopulateGrid(this.grid, GetLevel1Table(null, this.viewSettings), 0, Level1DataKeys, this.viewSettings);

            if (this.grid.RowCount > 0)
            {
                string script = string.Format("if ($('#grid').is(':visible')) {{ visible = true; viewSettings = JSON.parse($('#hfViewSettings').val()); selectRow('grid', {0}); }}", viewSettings.ShiftSectionHeader && this.grid.RowCount > 0 ? 1 : 0);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "selectFirstRow", "setTimeout(function() { " + script + "}, 500);", true);
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
        // Refresh whole grid
        case "refresh":
            {
            var requestId       = argParams.Length > 1 ? argParams[1] : (string)null;
            var requestIdParent = argParams.Length > 2 ? argParams[2] : (string)null;
            
            PopulateGrid(this.grid, GetLevel1Table(null, this.viewSettings), 0, Level1DataKeys, this.viewSettings);
            if (this.grid.RowCount > 0)
            {                
                int rowIndex = -1;
                if (rowIndex < 0 && !string.IsNullOrEmpty(requestId))
                    rowIndex = this.grid.FindIndexByAttrbiuteValue("RequestID", requestId);
                if (rowIndex < 0 && !string.IsNullOrEmpty(requestIdParent))
                    rowIndex = this.grid.FindIndexByAttrbiuteValue("RequestID", requestIdParent); // if was child row then would of collapsed on refresh so select parent
                if (rowIndex < 0)
                    rowIndex = viewSettings.ShiftSectionHeader ? 1 : 0;
                this.grid.SelectRow(rowIndex);
            }
            }
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
        this.tbDateRangeFrom.Attributes["readonly"] = "readonly";
        hfViewSettings.Value = JsonConvert.SerializeObject(this.viewSettings, new IsoDateTimeConverter());
    }

    /// <summary>
    /// Called when the due date or selected ward changes
    /// Will update the list with the new filter values
    /// </summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The event args</param>
    protected void dropDownListFilter_OnSelectedIndexChanged(object sender, EventArgs e)
    {
        // Update the filter options
        if (pnDateRange.Visible)
        {
            this.viewSettings.ToDate    = dpDateRangeTo.SelectedDate.Value.ToEndOfDay();
            this.viewSettings.FromDate  = this.viewSettings.ToDate.Value.AddDays(-aMMSetting.Worklist.DateRangeInDays); 
            this.tbDateRangeFrom.Text = this.viewSettings.FromDate.ToPharmacyDateString();
        }
        else if (pnDueDate.Visible)
        {
            this.viewSettings.FromDate= DateTime.Now.ToStartOfDay();
            this.viewSettings.ToDate  = DateTime.Now.AddDays(int.Parse(ddlDueDate.SelectedValue)).ToEndOfDay();
        }
        else
        {
            this.viewSettings.ToDate   = null;
            this.viewSettings.FromDate = null;
        }

        PopulateGrid(this.grid, GetLevel1Table(null, this.viewSettings), 0, Level1DataKeys, this.viewSettings);
        if (this.grid.RowCount > 0)
        {
            grid.SelectRow(0);
        }
    }
    #endregion

    #region WebMethods
    /// <summary>Returns the HTML data for a row in the grid</summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="siteID">Site ID</param>
    /// <param name="requestID">Request id of the row to get</param>
    /// <param name="level">Current level of the row in the grid</param>
    /// <param name="viewSettings">AMM workflow view settings</param>
    /// <returns>HTML data for row in the grid</returns>
    [WebMethod]
    public static string GetRow(int sessionID, int siteID, int requestID, int level, aMMWorflowViewSettings viewSettings)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);

        // Create a grid control
        Page page = new Page();
        PharmacyGridControl grid = (page.LoadControl("application/pharmacysharedscripts/PharmacyGridControl.ascx") as PharmacyGridControl);
        grid.ID = "grid";

        // Populate the grid (for a single row)
        switch (level)
        {
        case 0:    
            PopulateGrid(grid, GetLevel1Table(requestID, viewSettings), level, Level1DataKeys, viewSettings, true);
            break;
        case 1:                    
            PopulateGrid(grid, GetLevel2Table(requestID, null, viewSettings), level, Level2DataKeys, viewSettings, true);
            break;
        }

        // Return the grid rows
        return (grid.RowCount == 0) ? string.Empty : grid.ExtractHTMLRows(0, grid.RowCount).ToCSVString(string.Empty);
    }

    /// <summary>Gets all child elements of row in the grid</summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="siteID">Site ID</param>
    /// <param name="requestID_Parent">Parent row request id</param>
    /// <param name="viewSettings">AMM workflow view settings</param>
    /// <returns>HTML data for row in the grid</returns>
    [WebMethod]
    public static string GetChildRows(int sessionID, int siteID, int requestID_Parent, aMMWorflowViewSettings viewSettings)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);

        // Create a grid control
        Page page = new Page();
        PharmacyGridControl grid = (page.LoadControl("application/pharmacysharedscripts/PharmacyGridControl.ascx") as PharmacyGridControl);
        grid.ID = "grid";

        // Populate the grid with child elements
        PopulateGrid(grid, GetLevel2Table(null, requestID_Parent, viewSettings), 1, Level2DataKeys, viewSettings);

        // Return the grid rows
        return (grid.RowCount == 0) ? string.Empty : grid.ExtractHTMLRows(0, grid.RowCount).ToCSVString(string.Empty);
    }

    /// <summary>Toggle the request priority state</summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="requestID">Request ID to toggle priority stage</param>
    /// <param name="viewSettings">AMM workflow view settings</param>
    [WebMethod]
    public static void TogglePriority(int sessionID, int requestID, aMMWorflowViewSettings viewSettings)
    {
        SessionInfo.InitialiseSession(sessionID);

        // Call manually so prevents update time being updated, and hence any conflicts
        Database.ExecuteSQLNonQuery("UPDATE aMMSupplyRequest SET Priority=~Priority WHERE RequestID={0}",  requestID);
    }

    /// <summary>Get supply request manufacture date</summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="requestID">Request ID to toggle priority stage</param>
    /// <returns>supply request manufacture date</returns>
    [WebMethod]
    public static string GetAmmSupplyRequestManufactureDate(int sessionID, int requestID)
    {
        SessionInfo.InitialiseSession(sessionID);
        var supplyRequest = aMMSupplyRequest.GetByRequestID(requestID);
        return supplyRequest == null ? (string)null : supplyRequest.ManufactureDate.ToString();
    }
    #endregion

    #region Private Methods
    /// <summary>
    /// Loads the data for top level for the grid
    /// Can call method for a single row (by setting requestId) or
    /// it will load all items for either selected episode and\or ward and due date
    /// </summary>
    /// <param name="requestId">Set to load data for just a single row</param>
    /// <param name="viewSettings">AMM workflow view settings</param>
    /// <returns>loaded data</returns>
    private static GenericTable2 GetLevel1Table(int? requestId, aMMWorflowViewSettings viewSettings)
    {
        DateTime now = DateTime.Now;
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.Add("SiteID",        SessionInfo.SiteID      );
        parameters.Add("RequestID",     requestId               );
        parameters.Add("EpisodeID",     viewSettings.SelectEpisode ? (int?)null : (viewSettings.SelectedEpisodeID ?? -1));
        parameters.Add("FromStage",     viewSettings.FromStage  );
        parameters.Add("ToStage",       viewSettings.ToStage    );
        parameters.Add("ShiftID",       viewSettings.ShiftID    );  // 22Aug16 KR Added. 160246 aMMShifts are not displayed correctly in aMM Waiting Production Tray
        parameters.Add("ToDate",        viewSettings.ToDate     );
        parameters.Add("FromDate",      viewSettings.FromDate   );

        GenericTable2 table = new GenericTable2("level1Data");
        table.LoadBySP(viewSettings.Routine[0], parameters);

        return table;
    }

    /// <summary>Loads the second level data for the grid</summary>
    /// <param name="requestId">Set to load data for a single row</param>
    /// <param name="requestIdParent">load data under a parent request</param>
    /// <param name="viewSettings">AMM workflow view settings</param>
    /// <returns>loaded data</returns>
    private static GenericTable2 GetLevel2Table(int? requestId, int? requestIdParent, aMMWorflowViewSettings viewSettings)
    {
        DateTime now = DateTime.Now;
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.Add("SiteID",            SessionInfo.SiteID      );
        parameters.Add("RequestID",         requestId               );
        parameters.Add("RequestID_Parent",  requestIdParent         );
        parameters.Add("FromStage",         viewSettings.FromStage  );
        parameters.Add("ToStage",           viewSettings.ToStage    );

        GenericTable2 table = new GenericTable2("level2Data");
        table.LoadBySP(viewSettings.Routine[1], parameters);

        return table;
    }

    /// <summary>
    /// Populate the grid with the selected data
    /// Any data keys are stored as row attributes
    /// Method will also set grid properties like OnClientExpand, and EnableAlternateRowShading
    /// </summary>
    /// <param name="grid">Grid to populate</param>
    /// <param name="data">Data to populate grid with</param>
    /// <param name="level">Row level (1 or 2)</param>
    /// <param name="dataKeys">list of column names in data that are to be used as data keys</param>
    /// <param name="viewSettings">AMM work-flow view settings</param>
    /// <param name="singleRowUpdate">Single row update</param>
    private static void PopulateGrid(PharmacyGridControl grid, GenericTable2 data, int level, string[] dataKeys, aMMWorflowViewSettings viewSettings, bool singleRowUpdate = false)
    {
        DataColumnCollection dataColumns = data.Table.Columns;
        bool shiftSectionHeader = viewSettings.ShiftSectionHeader && !singleRowUpdate && dataColumns.Contains("ManufactureShiftID") && dataColumns.Contains("ManufactureDate");
        bool hasExpandColumn = !string.IsNullOrWhiteSpace(viewSettings.Routine[1]);
        HashSet<int> requestIdAddedSoFar = new HashSet<int>();
        DateTime? lastManufactureDate = DateTime.MaxValue;
        int? lastManufactureShiftID = -1;
        aMMShift shifts = null;

        // Set grid properties
        grid.CellSpacing = 0;
        grid.CellPadding = 2;
        grid.EnterAsDblClick = true;
        grid.EnableAlternateRowShading = true;
        grid.JavaEventDblClick = "aMMWorkflow_View();";
        grid.JavaEventOnRowSelected= "grid_OnRowSelected";
        grid.OnClientGetChildRows = "grid_OnClientGetChildRows";

        // Create grid columns
        if (hasExpandColumn)
        {
            grid.AddColumn(string.Empty, 3, PharmacyGridControl.ColumnType.ChildRowButton);            
        }

        int missingWidthColumnCount = 0;
        foreach (DataColumn col in dataColumns)
        {
            if (!dataKeys.Contains(col.ColumnName))
            {                
                switch (col.ColumnName)
                {
                case "HasAttachedNote": 
                    grid.AddColumn(string.Empty, 3); 
                    //grid.ColumnXMLEscaped(grid.ColumnCount - 1, false);
                    break;
                case "Date":
                    grid.AddColumn(col.ColumnName, 22); 
                    break;
                case "Due Date":
                    grid.AddColumn(col.ColumnName, 16); 
                    grid.ColumnAllowTextWrap(grid.ColumnCount - 1, true);
                    break;
                case "Manufacture Date":
                    grid.AddColumn(col.ColumnName, 14); 
                    break;
                case "BatchNumber":
                case "Batch Number":
                    grid.AddColumn(col.ColumnName, 12); 
                    break;
                default:
                    grid.AddColumn(col.ColumnName, 0);
                    grid.ColumnAllowTextWrap(grid.ColumnCount - 1, true);
                    grid.ColumnKeepWhiteSpace(grid.ColumnCount - 1, true);
                    missingWidthColumnCount++;
                    break;
                }

                grid.ColumnXMLEscaped(grid.ColumnCount - 1, false);
            }
        }
        
        // Split remaining width between the standard columns
        int totolColumnWidth = grid.GetColumnsTotalWidth();
        for (int c = 0; c < grid.ColumnCount; c++)
        {
            if (grid.GetColumnWidth(c) == 0)
            {
                grid.SetColumnWidth(c, (100 - totolColumnWidth) / missingWidthColumnCount);
            }
        }

        // If suitable order by shifts
        if (shiftSectionHeader)
            shifts = aMMShift.GetAll();

        // Populate table data
        foreach (DataRow row in data.Table.Rows)
        {
            // If date or shift has changed then add section header
            if (shiftSectionHeader)
            {
                var manufactureDate    = row["ManufactureDate"   ] == DBNull.Value ? (DateTime?)null : (DateTime)row["ManufactureDate"];
                var manufactureShiftID = row["ManufactureShiftID"] == DBNull.Value ? (int?)null      : (int)row["ManufactureShiftID"];
                if (lastManufactureDate != manufactureDate || lastManufactureShiftID != manufactureShiftID)
                {
                    grid.AddRow();
                    grid.SetRowBackgroundColour("#676767");
                    grid.SetRowStyle("font-weight:bold;font-style:italic;color:white;");
                    grid.AddRowAttribute("headerRow", "true");
                    grid.SetCell(0, manufactureShiftID == null ? "Unscheduled" : manufactureDate.ToPharmacyDateString() + " - " + shifts.FindByID(manufactureShiftID.Value).ToString());
                    grid.SetCellColSpan(0, grid.ColumnCount);
                    
                    lastManufactureDate    = manufactureDate;
                    lastManufactureShiftID = manufactureShiftID;
                }
            }

            // Prevent duplicate rows (belt and braces) 122540 XN 07Jul15
            int requestId = (int)row["RequestID"];
            if (requestIdAddedSoFar.Contains(requestId))
                continue;
            requestIdAddedSoFar.Add(requestId);

            // Add row
            grid.AddRow();
            grid.SetRowLevel(level);
            if (dataColumns.Contains("HasChildren") && (bool)row["HasChildren"] == true)
            {
                grid.SetShowChildRows(false);
            }

            // If priority row set row text as red
            if (dataColumns.Contains("Priority") && ((bool)row["Priority"]) == true)
            {
                grid.SetRowTextColour("red");    
            }

            // Populate cells
            int gridColIndex = hasExpandColumn ? 1 : 0;
            foreach (DataColumn col in dataColumns)
            {
                if (dataKeys.Contains(col.ColumnName))
                {
                    // Set data keys are row attributes
                    grid.AddRowAttribute(col.ColumnName.Replace(' ', '_'), row[col.ColumnName].ToString());
                }
                else if (col.ColumnName == "HasAttachedNote")
                {
                    // Store attached note state as icon
                    if ((bool)row[col.ColumnName])
                    {
                        grid.SetCell(gridColIndex, "<img title='This item has notes attached.' src='../../images/ocs/classAttachedNote.gif' style='cursor:hand' onclick='attachedNoteIcon_onclick(this);' />");
                    }

                    gridColIndex++;
                }
                else
                {   
                    // Set standard cell text
                    grid.SetCell(gridColIndex, row[col.ColumnName].ToString().XMLEscape().Replace("\r", "<br/>"));
                    gridColIndex++;
                }                                
            }
        }
    }
    #endregion
}