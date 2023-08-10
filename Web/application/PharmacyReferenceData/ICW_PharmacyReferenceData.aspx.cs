//==============================================================================================
//
//      					    ICW_PharmacyReferenceData.aspx.cs
//
//  ICW desktop for the pharamcy reference data editor. 
//  Allows editing a single site or multiple sites depending on the desktop editor settings.
//
//  The page uses pharmacysharedscripts\EditList\EditList.ascx to display the data
//  and sets each cells onClientBeginEdit to call ReferenceDataEditor.aspx to edit the content
//
//  The class uses values from WLookup currenlty support
//      Warnings
//      Instructions
//      UserMsg (Drug message code)
//      FFLabels (Free Format labels)
//      Reasons (Finance reason codes)
//
//  To add a new type to the list requires
//      New button on the HTML page
//      In ICW_PharmacyReferenceData.aspx.cs  method btnView_OnClick convert button to WLookupContext enum
//      In ReferenceDataEditor.aspx.cs method Populate set page title for the WLookupContext enum
//      Add suitable values to WLookupColumnInfo methods
//          GetCodeLength
//          GetValueLength
//          GetValueMaxNumberOfLines
//          IfValueRequired
//
//  Though blank codes are not allowed they can be in the db (this list will replace them with !_), if the
//  user tries to edit an item with a blank code the code will be updated with !_ (mimicks what vb6 does)
//  This is far from perfect (but don't believe lots of sites have this issue)
//      if have entries in list with blank, and !_ codes then will get 2 rows in list
//      also adding with !_ will cause issues.
//
//  The page replace vb6 SupplierEditor.bas  Editors (just for lookup editors)
//
//  The desktop has the following desktop parameters
//  AscribeSiteNumber   - Main ascribe site number for the desktop
//  EditableSiteNumbers - CSV list of other sites the user can edit (default none) can use "All" for all sites
//
//	Modification History:
//	23Apr14 XN  Written
//  09Sep14 XN  prevent crash if no data type is selected 99608 
//==============================================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;

public partial class application_PharmacyReferenceData_ICW_PharmacyReferenceData : System.Web.UI.Page
{
    #region Constants
    public readonly static string CssEmptyCell   = "EmptyCell";
    public readonly static string CssValueCell   = "ValueCell";
    public readonly static string EmptyDSSCell   = "&lt;No DSS value set&gt;";
    public readonly static string EmptyLocalCell = "&lt;No value set&gt;";
    #endregion

    #region Variables
    /// <summary>List of all editable sites (including main site)</summary>
    protected List<int> editableSiteNumbers;

    protected bool showWarning;
    protected bool showInstructions;
    protected bool showDrugMsgCode;    
    protected bool showFreeFormatLabels;
    protected bool showFinanceReasonCode;

    protected bool readOnly;
    #endregion

    #region Protected Properties
    /// <summary>Returns the currently selected view (e.g. Warning, Instruction)</summary>
    protected WLookupContextType? SelectedView
    {
        get { return hfSelectedViewKey.Value<WLookupContextType?>(); }
        set { hfSelectedViewKey.Value = value.ToString();            }
    }

    /// <summary>Returns the currently actrive code filter applied to list</summary>
    protected string CurrentActiveFilter
    {
        get { return hfCurrentActiveFilter.Value;   }
        set { hfCurrentActiveFilter.Value = value;  }
    }
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        Sites sites = new Sites();
        sites.LoadAll(true);

        // Get list of editable sites
        if (Request["EditableSiteNumbers"].EqualsNoCaseTrimEnd("All"))
            editableSiteNumbers = sites.Select(s => s.SiteNumber).ToList();
        else
            editableSiteNumbers = (Request["EditableSiteNumbers"] ?? string.Empty).ParseCSV<int>(",", true).ToList();

        /// Add current Site to list
        editableSiteNumbers.Remove(SessionInfo.SiteNumber      ); // Prevent duplicates
        editableSiteNumbers.Insert(0,  SessionInfo.SiteNumber  );

        // Remove all invalid sites numbers
        editableSiteNumbers.RemoveAll(s => sites.FindSiteIDBySiteNumber(s) == null);

        // Get data to display
        showWarning             = BoolExtensions.PharmacyParse(Request["ShowWarnings"         ] ?? "Y");
        showInstructions        = BoolExtensions.PharmacyParse(Request["ShowInstructions"     ] ?? "Y");
        showDrugMsgCode         = BoolExtensions.PharmacyParse(Request["ShowDrugMsgCode"      ] ?? "Y");
        showFreeFormatLabels    = BoolExtensions.PharmacyParse(Request["ShowFreeFormatLabels" ] ?? "Y");
        showFinanceReasonCode   = BoolExtensions.PharmacyParse(Request["ShowFinanceReasonCode"] ?? "Y");

        readOnly = BoolExtensions.PharmacyParse(Request["ReadOnly"] ?? "Y");

        if (!this.IsPostBack)
        {
            PopulateViewButtons();

            // Select first visible view button
            // else show error if no visible view buttons
            var btnFirstVisibleView = upViews.GetAllControlsByType<Button>().FirstOrDefault(btn => btn.Visible);
            if (btnFirstVisibleView == null)
                ScriptManager.RegisterStartupScript(this, this.GetType(), "noViews", "alert('No views selected. Use the desktop editor to select data to display.');", true);
            else
                btnView_OnClick(btnFirstVisibleView, null);

            // List all the sites for the printer select site popup
            cblSites.Items.AddRange(editableSiteNumbers.Select(s => new ListItem(s.ToString("000"), sites.FindSiteIDBySiteNumber(s).ToString())).ToArray());
            if (cblSites.Items.Count == 1)
                cblSites.Items[0].Selected = true;

            // Set read only state
            //btnAdd.Visible   = !readOnly;                        XN 09Sept14 99608 prevent crash if no data type is selected
            btnAdd.Visible   = !readOnly && btnFirstVisibleView != null;
            btnEdit.Text     = readOnly ? "View..." : "Edit...";
            btnEdit.Visible  = btnFirstVisibleView != null;     // XN 09Sept14 99608 prevent crash if no data type is selected
            //btnDelete.Visible= !readOnly;                        XN 09Sept14 99608 prevent crash if no data type is selected
            btnDelete.Visible= !readOnly && btnFirstVisibleView != null;
            btnPrint.Visible = btnFirstVisibleView != null;     // XN 09Sept14 99608 prevent crash if no data type is selected
        }

        string args = Request["__EVENTARGUMENT"];

        // Deal with __postBack events
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' });

        switch (argParams[0])
        {
        case "Update":  // Update list
            {                
            string newCode = argParams.Skip(1).ToCSVString(":");    // Parameters 1 is new code added to list

            // Repopulate list
            PopulateView(this.SelectedView.Value, this.CurrentActiveFilter);
    
            // Find newly add item to list (or 0 if not present)
            int row = 0;
            for (int r = 0; r < editList.RowCount; r++) 
            {
                if (editList.GetCellValue(0, r).EqualsNoCase(newCode))
                {
                    row = r;
                    break;
                }
            }

            // Send request to resize, and select new item
            string script = string.Format(@"el_SetSelectedCellByPos('{0}', 0, {1});", editList.ID, row);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ViewUpdate", script, true);
            }
            break;
        case "Print":   // Print
            PopulateView(this.SelectedView.Value, this.CurrentActiveFilter);    // items might of changed so need to rebuild
            Print();
            break;
        }
    }

    /// <summary>
    /// Called when view item (like warning or instruction) is selected
    /// Update the list for the new view
    /// </summary>
    protected void btnView_OnClick(object sender, EventArgs args)
    {
        Button btn = sender as Button;
        WLookupContextType contextType;

        // Get context type for the view
        if (btn == btnWarnings)
            contextType = WLookupContextType.Warning;
        else if (btn == btnInstructions)
            contextType = WLookupContextType.Instruction;
        else if (btn == btnDrugMsgCode)
            contextType = WLookupContextType.UserMsg;
        else if (btn == btnFFLabel)
            contextType = WLookupContextType.FFLabels;
        else if (btn == btnReason)
            contextType = WLookupContextType.Reason;
        else 
            throw new ApplicationException("Invalid view button");

        // Show button as selected
        trViews.GetAllControlsByType<Button>().ToList().ForEach(b => b.CssClass = string.Empty);
        btn.CssClass = "ViewListSelected";

        // Update cached variable
        this.SelectedView = contextType;

        // Clear filters
        tbFilter.Text             = string.Empty;
        this.CurrentActiveFilter  = string.Empty;

        // Repopulate list
        PopulateView(contextType, string.Empty);

        // Resize, and select first item in list
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ViewUpdate", string.Format(@"el_SetSelectedCellByPos('{0}', 0, 0);", editList.ID), true);
    }

    /// <summary>
    /// Called when search button is clicked
    /// Reloads list with new view data
    /// </summary>
    public void btnSearch_OnClick(object sender, EventArgs args)
    {
        // Store filter value
        this.CurrentActiveFilter = tbFilter.Text;

        // Updates list with filter
        PopulateView(this.SelectedView.Value, this.CurrentActiveFilter);

        // Resize, and select first item in list
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ViewUpdate", string.Format(@"el_SetSelectedCellByPos('{0}', 0, 0);", editList.ID), true);
    }

    /// <summary>
    /// Called when clear filter button is clicked
    /// Reloads list with new view data
    /// </summary>
    public void btnClearFilter_OnClick(object sender, EventArgs args)
    {
        // Store filter value
        this.tbFilter.Text       = string.Empty;
        this.CurrentActiveFilter = string.Empty;

        // Updates list with filter
        PopulateView(this.SelectedView.Value, this.CurrentActiveFilter);

        // Resize, and select first item in list
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ViewUpdate", string.Format(@"el_SetSelectedCellByPos('{0}', 0, 0);", editList.ID), true);
    }
    #endregion

    #region Web Methods
    /// <summary>Returns a cells HTML content (WLookup.Value for site specific data only)</summary>
    /// <param name="sessionID">Session id</param>
    /// <param name="siteNumber">Site Number (of main site not the site being edited)</param>
    /// <param name="code">WLookup code</param>
    /// <param name="editingSiteNumber">site number being edited</param>
    /// <param name="contextType">WLookup context type</param>
    /// <returns>cells HTML content</returns>
    [WebMethod]
    public static string GetCellText(int sessionID, int siteNumber, string code, int editingSiteNumber, WLookupContextType contextType)
    {
        SessionInfo.InitialiseSessionAndSiteNumber(sessionID, siteNumber);

        WLookup wlookup = new WLookup();
        wlookup.LoadByCodeSiteContextAndCountryCode(code, Sites.GetSiteIDByNumber(editingSiteNumber), contextType, true, PharmacyCultureInfo.CountryCode);

        string cellText = wlookup.Any() ? wlookup.First().Value.Replace("\r\n", "<br />") : EmptyLocalCell;
        string cssStyle = wlookup.Any() ? CssValueCell : CssEmptyCell;
        return CreateCellText(cellText, cssStyle);
    }

    /// <summary>Determines if the code is in use by other products and returns appropriate message (else null)</summary>
    /// <param name="sessionID">Session id</param>
    /// <param name="siteNumber">Site Number (of main site not the site being edited)</param>
    /// <param name="code">WLookup code</param>
    /// <param name="editingSiteNumber">site number being edited</param>
    /// <param name="contextType">WLookup context type</param>
    /// <returns>empty cell text to be displayed in table</returns>
    [WebMethod]
    public static string CanDelete(int sessionID, int siteNumber, string code, int editingSiteNumber, WLookupContextType contextType)
    {
        const int MaxProductToCheck = 15;

        SessionInfo.InitialiseSessionAndSiteNumber(sessionID, siteNumber);

        int editingSiteID = Sites.GetSiteIDByNumber(editingSiteNumber);
        string msg = null;

        if ((contextType == WLookupContextType.Warning || contextType == WLookupContextType.Instruction || contextType == WLookupContextType.UserMsg || contextType == WLookupContextType.FFLabels) &&
            SettingsController.Load<bool>("Pharmacy", "ReferenceData", "CheckIfInUseBeforeDelete", true) &&
            (!WLookup.IsDSSMaintained(contextType) || !WLookup.IfDSSExists(editingSiteID, code, contextType, PharmacyCultureInfo.CountryCode)))
        {
            WProduct products = new WProduct();
            products.LoadBySiteAndLookupCode(editingSiteID, contextType, code, MaxProductToCheck);

            int foundCount = products.Count;
            if (foundCount >= MaxProductToCheck)
                foundCount = WProduct.GetCountBySiteAndLookupCode(editingSiteID, contextType, code);

            if (foundCount > 0)
            {
                msg = string.Format("<div>Code cannot be deleted as it is used by the following:<br /><div style='margin:5px'>{0}<b>{1}</b></div>Remove the code from these item(s) first.</div>", 
                                    products.Select(p => (p.NSVCode + " - " + p.ToString()).XMLEscape()).ToCSVString("<br />"), 
                                    foundCount > MaxProductToCheck ? "<br />Total of " + foundCount.ToString() + " products affected" : string.Empty);
            }
        }

        return msg;
    }

    /// <summary>Deletes WLookup, and returns empty cell text that should be displayed in table</summary>
    /// <param name="sessionID">Session id</param>
    /// <param name="siteNumber">Site Number (of main site not the site being edited)</param>
    /// <param name="code">WLookup code</param>
    /// <param name="editingSiteNumber">site number being edited</param>
    /// <param name="contextType">WLookup context type</param>
    /// <returns>empty cell text to be displayed in table</returns>
    [WebMethod]
    public static string Delete(int sessionID, int siteNumber, string code, int editingSiteNumber, WLookupContextType contextType)
    {
        SessionInfo.InitialiseSessionAndSiteNumber(sessionID, siteNumber);

        WLookup wlookup = new WLookup();
        wlookup.LoadByCodeSiteContextAndCountryCode(code, Sites.GetSiteIDByNumber(editingSiteNumber), contextType, null, PharmacyCultureInfo.CountryCode);
        wlookup.RemoveAll();
        wlookup.Save();

        return CreateCellText(EmptyLocalCell, CssEmptyCell);
    }
    #endregion

    #region Private Methods
    /// <summary>Sets which view buttons are visible based on desktop parameter</summary>
    private void PopulateViewButtons()
    {
        btnWarnings.Visible     = this.showWarning;
        btnInstructions.Visible = this.showInstructions;
        btnDrugMsgCode.Visible  = this.showDrugMsgCode;
        btnFFLabel.Visible      = this.showFreeFormatLabels;
        btnReason.Visible       = this.showFinanceReasonCode;
    }

    /// <summary>Populate the view (from WLookup)</summary>
    /// <param name="wlookupContextType">Context to load (from WLookup)</param>
    /// <param name="filterCode">Code to filte the list by (if item contains this code)</param>
    private void PopulateView(WLookupContextType wlookupContextType, string filterCode)
    {
        bool isDSSMainteined = WLookup.IsDSSMaintained(wlookupContextType);

        Sites sites = new Sites();
        sites.LoadAll();

        // get editable site IDs
        var editableSiteIDs = sites.FindSiteIDBySiteNumber(editableSiteNumbers).ToList();

        // If not english display language
        if (WLookup.IsMulitLanguage(wlookupContextType) && PharmacyCultureInfo.CountryCode != PharmacyCultureInfo.UKCountryCode) 
        {
            spanLanguageDescritpion.Visible = true;
            spanLanguageDescritpion.InnerHtml = "Language: <b>" + PharmacyCultureInfo.GetLanguageName(SessionInfo.SiteID) + "</b>";
        }
        else
            spanLanguageDescritpion.Visible = false;

        // Clear existing data
        editList.Clear();

        // Setup columns
        editList.AddColumn("Code", 75, 75, true);
        if (isDSSMainteined)
            editList.AddColumn("DSS Value", 300, 350, true);
        foreach (int siteID in editableSiteIDs)
            editList.AddColumn(siteID, 300, 400, siteID == SessionInfo.SiteID);

        //
        // Load data
        //

        // Load dss looks (if context has dss option)
        WLookup dsslookups = new WLookup();
        if (isDSSMainteined)
        {
            dsslookups.LoadBySiteDSSContextAndCountryCode(true, SessionInfo.SiteID, wlookupContextType, PharmacyCultureInfo.CountryCode);
            if (PharmacyCultureInfo.CountryCode != PharmacyCultureInfo.UKCountryCode)
                dsslookups.LoadBySiteDSSContextAndCountryCode(true, SessionInfo.SiteID, wlookupContextType, PharmacyCultureInfo.UKCountryCode);
        }

        // Load site specific data
        WLookup lookups = new WLookup();
        lookups.LoadBySitesContextAndCountryCode(true, editableSiteIDs, wlookupContextType, PharmacyCultureInfo.CountryCode);

        // Get complete list of codes (dss and local), and filter
        IEnumerable<string> codesTemp = dsslookups.Union(lookups).Select(s => s.Code).Distinct();
        if (!string.IsNullOrEmpty(filterCode))
        {
            filterCode = filterCode.ToLower();
            codesTemp = codesTemp.Where(c => c.ToLower().StartsWith(filterCode));
        }
        SortedList<string,string> codes = new SortedList<string,string>(codesTemp.ToDictionary(s => s));

        //
        // Populate table
        //

        // Add codes to table
        foreach(string code in codes.Keys)
        {
            editList.AddRow();
            SetEditListCell(0, editList.RowCount - 1, null, null, string.IsNullOrEmpty(code) ? "!_" : code);
        }

        // Add dss lookups to table (if any)
        if (isDSSMainteined)
        {
            // Add lookup to table
            foreach(WLookupRow l in dsslookups)
            {
                int r = codes.Keys.IndexOf(l.Code);
                if (r >= 0 && editList.GetCellInfo(1, r) == null)
                    SetEditListCell(1, r, null, null, CreateCellText(l.Value, CssValueCell));
            }

            // Fill in blank cells
            for (int r = 0; r < editList.RowCount; r++)
            {
                if (editList.GetCellInfo(1, r) == null)
                    SetEditListCell(1, r, null, null, CreateCellText(EmptyDSSCell, CssEmptyCell));
            }
        }

        // Populate all site specific data
        int siteIndexOffset = isDSSMainteined ? 2 : 1;
        foreach(WLookupRow l in lookups)
        {
            int c = editableSiteIDs.IndexOf(l.SiteID ) + siteIndexOffset;
            int r = codes.Keys.IndexOf     (l.Code   );

            if (r >= 0)
                SetEditListCell(c, r, l.Code, sites.FindSiteNumberByID(l.SiteID), CreateCellText(l.Value, CssValueCell));
        }

        // Fill in blank cells
        for (int c = siteIndexOffset; c < editList.ColumnCount; c++)
        {
            for (int r = 0; r < editList.RowCount; r++)
            {
                if (editList.GetCellInfo(c, r) == null)
                    SetEditListCell(c, r, codes.Keys[r], sites.FindSiteNumberByID(editList.GetColumnInfo(c).siteID), CreateCellText(EmptyLocalCell, CssEmptyCell));
            }
        }

        // Set view
        multiView.SetActiveView(vEditList);
    }

    /// <summary>Set cell in table</summary>
    /// <param name="col">Cell column</param>
    /// <param name="row">Cell row</param>
    /// <param name="code">Cell code (set as attribute Code) if null not set</param>
    /// <param name="siteNumber">Cell site number (set as attribute SiteNumber) if null not set</param>
    /// <param name="text">Text to set in cell</param>
    private void SetEditListCell(int col, int row, string code, int? siteNumber, string text)
    {
        // Set cell value
        editList.SetCellAsText(text, col, row);

        // Set code attibute
        if (code != null)
            editList.SetCellAttribute("Code", code, col, row);

        // Set site number attribute
        if (siteNumber != null)
            editList.SetCellAttribute("SiteNumber", siteNumber.Value.ToString("000"), col, row);

        // Set method to run to start edit
        editList.GetCellInfo(col, row).onClientBeginEdit = "$('#btnEdit').click()";
    }

    /// <summary>
    /// Returns the context for the cell 
    /// if text is empty
    ///     {div class='EmptyText'}[Empty Text]{/div}
    /// else
    ///     {div class='{cssClass}'}text{/div}
    /// </summary>
    /// <param name="text">Text for cell (replace \r\n with br)</param>
    /// <param name="cssClass">Cells div class</param>
    private static string CreateCellText(string text, string cssClass)
    {
        if (string.IsNullOrWhiteSpace(text))
            return "<div class='BalnkText'>[Empty Text]</div>";
        else
            return string.Format("<div class='{0}'>{1}</div>", cssClass, text.Replace("\r\n", "<br />"));
    }

    /// <summary>Prints list of reference data for the sites selected in cblSites</summary>
    private void Print()
    {
        string reportName = "Pharmacy General Report " + SessionInfo.SiteNumber.ToString();
        DateTime now = DateTime.Now;

        if (!OrderReport.IfReportExists(reportName))
            throw new ApplicationException(string.Format("Report not found '{0}'", reportName));

        if (cblSites.CheckedItems().Count() == 0)
            return;

        // Setup xml writer 
        XmlWriterSettings settings  = new XmlWriterSettings();
        settings.OmitXmlDeclaration = true;
        settings.ConformanceLevel   = ConformanceLevel.Fragment;

        // Create data
        StringBuilder xml = new StringBuilder();
        using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
        {
            xmlWriter.WriteStartElement("PNPrintData");

            // Report title
            xmlWriter.WriteStartElement("Title");
            xmlWriter.WriteAttributeString("title", upViews.GetAllControlsByType<Button>().First(b => b.CssClass.Contains("ViewListSelected")).Text);
            xmlWriter.WriteEndElement();

            // Hospital name
            xmlWriter.WriteStartElement("Info");
            xmlWriter.WriteAttributeString("hospname1", string.Empty);
            xmlWriter.WriteAttributeString("hospname2", string.Empty);
            xmlWriter.WriteAttributeString("hospname3", string.Empty);

            // User info
            xmlWriter.WriteAttributeString("UserID",   SessionInfo.UserInitials.RTFEscape());
            xmlWriter.WriteAttributeString("UserName", SessionInfo.Username.RTFEscape()    );
            xmlWriter.WriteAttributeString("today",    now.ToPharmacyDateString());
            xmlWriter.WriteAttributeString("TimeNow",  now.ToPharmacyTimeString());
            xmlWriter.WriteEndElement();

            // Grid data (including filter if specified)
            xmlWriter.WriteStartElement("Data");
            if (!string.IsNullOrEmpty(tbFilter.Text))
                xmlWriter.WriteAttributeString("InfoText", "List filtered by: " + tbFilter.Text.RTFEscape());
            xmlWriter.WriteStartAttribute("Table", string.Empty);
            foreach (var checkedSite in cblSites.CheckedItems())
            {
                int siteID = int.Parse(checkedSite.Value);
                xmlWriter.WriteString(CreateRTFTableForSite(siteID));
                if (cblSites.CheckedItems().Last() != checkedSite)
                    xmlWriter.WriteString("\\page");
            }
            xmlWriter.WriteEndAttribute();
            xmlWriter.WriteEndElement();

            xmlWriter.WriteEndElement();


            xmlWriter.Close();
        }

        PharmacyDataCache.SaveToDBSession("PharmacyGeneralReportAttribute", xml.ToString());

        string script = string.Format("window.parent.ICWWindow().document.frames['fraPrintProcessor'].PrintReport({0}, '{1}', 0, false, '')", SessionInfo.SessionID, reportName);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "Print", script, true); 
    }

    /// <summary>
    /// Returns the RTF table of reference data for the site
    /// Table will include the columns Code, DSS values (if presnet), and site value
    /// </summary>
    private string CreateRTFTableForSite(int siteID)
    {
        RTFTable            rtfTable         = new RTFTable();                               // RTF table to print
        List<int>           activeColumnIndex= new List<int>();                              // Column indexes to print
        List<Site>          sites            = (new SiteProcessor()).LoadAll();              // List of sites
        List<string[]>      lines            = new List<string[]>(editList.ColumnCount);     // all the lines for each cell in a row
        List<bool>          lineHasNoValue   = new List<bool>(editList.ColumnCount);         // if cells in a row have a value
        WLookupContextType  contextType      = SelectedView.Value;

        // Get the column for the selected site
        var columnForSite = editList.Columns.First(c => c.siteID == siteID);

        // Get index of all columns to print
        activeColumnIndex.Add(0);
        if (WLookup.IsDSSMaintained(contextType))
            activeColumnIndex.Add(1);
        activeColumnIndex.Add( editList.Columns.ToList().IndexOf(columnForSite) );

        // get total width of table
        int maxWidth        = activeColumnIndex.Sum(c => editList.GetColumnInfo(c).minWidth);
        var widthMultiplier = (activeColumnIndex.Count == 2 && WLookup.GetColumnInfo().GetValueLength(contextType) < 50) ? 0.5 : 1; // If only 2 columns and short message text then only use half page else looks bit odd

        // Create RTF columns
        foreach (int c in activeColumnIndex)
        {
            EditList.ColumnInfo col = editList.GetColumnInfo(c);
            double percentWidth = ((col.minWidth * 100.0) / maxWidth) * widthMultiplier;
            if (col.type == EditList.ColumnHeaderType.Text)
                rtfTable.AddColumn(col.text, (int)percentWidth, RTFTable.AlignmentType.Left);
            else
            {
                Site site = sites.First(s => s.SiteID == col.siteID);
                rtfTable.AddColumn(string.Format("{0} - {1:000}", site.LocalHospitalAbbreviation, site.Number), (int)percentWidth, RTFTable.AlignmentType.Left);
            }
        }

        // Create RTF table
        for (int r = 0; r < editList.RowCount; r++)
        {
            lines.Clear();
            lineHasNoValue.Clear();

            // As a cell can have more than 1 line then to print this need to split the lines into multiple rows
            foreach (int c in activeColumnIndex)
            {
                string value   = editList.GetCellValue(c, r);
                bool   noValue = false;

                // Remove the div and check if the cell is empty
                if (value.StartsWith("<div"))
                {
                    int startPos = value.IndexOf('>');
                    int endPos   = value.LastIndexOf('<');
                    if (startPos >= 0 && endPos >= 0)
                    {
                        value   = value.SafeSubstring(startPos + 1, endPos - startPos - 1);
                        noValue = value == EmptyLocalCell || value == EmptyDSSCell;
                    }
                }

                // Add the cell lines to list of lines for the row
                lineHasNoValue.Add(noValue);
                lines.Add( value.Split(new [] { "<br />" }, StringSplitOptions.None) );                    
            }

            // Now create a row for each line
            int maxlines = lines.Max(s => s.Length);
            int halfLines= (int)((maxlines + 0.5) / 2);
            for (int l = 0; l < maxlines; l++)
            {
                rtfTable.NewRow();
                for (int c = 0; c < lines.Count; c++)
                {
                    if (lineHasNoValue[c])
                    {   
                        // If not Value the print the no value text (centerred italic, and grey)
                        if (l == halfLines)
                            rtfTable.AddCell(EmptyLocalCell.XMLUnescape(), RTFTable.AlignmentType.Center, true, 14);
                    }
                    else if (lines[c].Length > l)
                        rtfTable.AddCell(lines[c][l]);
                    else
                        rtfTable.AddCell(string.Empty);
                }
            }
        }

        rtfTable.Close();

        return rtfTable.ToString();
    }
    #endregion
}