//==============================================================================================
//
//      					            NewPharmacyWardWizard.aspx.cs
//
//  Allows user to add a new ward (via a wizard)
//
//  There are two add options 
//      Create New
//      Import from Other Sites
//
//  Steps for the wizard are
//      Create New -> enter code -> fill in customer details -> select sites to import to
//      Import from Other site -> Select site -> Select Customer -> fill in customer detials -> select sites to import to
//
//  The desktop has the following desktop parameters
//  AscribeSiteNumber       - Main ascribe site number for the desktop
//  ImportToSiteNumbers     - CSV list of sites the user can import to or "All" for all sites (default All)
//  ImportFromSiteNumbers   - CSV list of sites the user can import from or "All" for all sites (default All)
//  ShowAddNew              }
//  ShowAddFromOtherSite    }   - Controls add options avaiable to the user
//
//	Modification History:
//	17Jun14 XN  Written
//  03Set14 XN  Rewrite to simpliy
//  31Oct14 XN  Added sortWardsBy 102842
//  18Nov14 XN  Added show add options   
//  19Nov14 XN  104568 Alow to show more the 14 sites import from and to panels
//  09Nov14 XN  105861 resized from to ensure error message can be seen
//==============================================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_PharmacyWardEditor_NewPharmacyWardWizard : System.Web.UI.Page
{
    #region Data Types
    /// <summary>List of steps in the wizard</summary>
    protected enum WizardSteps
    {
        /// <summary>Select the add method</summary>
        AddType,

        /// <summary>Select import from site</summary>
        SelectImportFromSite,

        /// <summary>Select import from ward</summary>
        SelectImportFromWard,

        /// <summary>Allows user to enter new code</summary>
        EnterNewCode,

        /// <summary>edit new ward settings</summary>
        EditorControl,

        /// <summary>List sites to import to</summary>
        SelectImportToSites,
    }

    /// <summary>Add method</summary>
    protected enum AddType
    {
        CreateNew           = 0,
        ImportFromOtherSite = 1,
    }
    #endregion

    #region Constants
    private const int MaxSitesPerColumns = 20;  // 19Nov14 XN 104568 Alow to show more the 14 sites import from and to panels
    private const int MaxColumns         = 3;   // 19Nov14 XN 104568 Alow to show more the 14 sites import from and to panels
    #endregion

    #region Variables
    /// <summary>List of site the ward can be imported from</summary>
    private List<int> importFromSiteNumbers;

    /// <summary>List of site the ward can be imported to</summary>
    private List<int> importToSiteNumbers;

    /// <summary>Sort ward list by this column</summary>
    protected string sortWardsBy;
    
    private bool showAddNew           = true;
    private bool showAddFromOtherSite = true;
    #endregion

    #region Properties
    /// <summary>Current step in the wizard</summary>
    protected WizardSteps CurrentStep { get { return (WizardSteps)Enum.Parse(typeof(WizardSteps), hfCurrentStep.Value); } }
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        // Get list of import to sites (and remove curent site)
        string importToSiteNumbersStr = Request["ImportToSiteNumbers"] ?? string.Empty;
        if (importToSiteNumbersStr.EqualsNoCaseTrimEnd("All"))
        {
            Sites sites = new Sites();
            sites.LoadAll(true);
            importToSiteNumbers = sites.Select(s => s.SiteNumber).ToList();
        }
        else
            importToSiteNumbers = importToSiteNumbersStr.ParseCSV<int>(",", true).ToList();
        importToSiteNumbers.Remove(SessionInfo.SiteNumber);   // Remove current site

        // Get list of import from sites (and remove curent site)
        string importFromSiteNumbersStr = Request["ImportFromSiteNumbers"] ?? string.Empty;
        if (importFromSiteNumbersStr.EqualsNoCaseTrimEnd("All"))
        {
            Sites sites = new Sites();
            sites.LoadAll(true);
            importFromSiteNumbers = sites.Select(s => s.SiteNumber).ToList();
        }
        else
            importFromSiteNumbers = importFromSiteNumbersStr.ParseCSV<int>(",", true).ToList();
        importFromSiteNumbers.Remove(SessionInfo.SiteNumber);   // Remove current site

        sortWardsBy = Request["SortBy"];

        showAddNew           = BoolExtensions.PharmacyParse(Request["ShowAddNew"]           ?? "true");
        showAddFromOtherSite = BoolExtensions.PharmacyParse(Request["ShowAddFromOtherSite"] ?? "true");

        if (!this.IsPostBack)
        {
            // Start the wizard
            SetStep(WizardSteps.AddType);
            PopulateAddType();
        }
    }

    /// <summary>
    /// Called when next button is clicked
    /// Validates current stage in wizard, then moves to next stage is wizard
    /// </summary>
    protected void btnNext_OnClick(object sender, EventArgs e)
    {
        // Validate current wizard step
        bool valid = true;
        switch(this.CurrentStep)
        {
        case WizardSteps.AddType:              valid = ValidateAddType();             break;
        case WizardSteps.SelectImportFromSite: valid = ValidateSelectImportFromSite();break;
        case WizardSteps.SelectImportFromWard: valid = ValidateSelectImportFromWard();break;
        case WizardSteps.EnterNewCode:         valid = ValidateEnterNewCode(true);    break;
        case WizardSteps.EditorControl:        valid = ValidateEditorControl();       break;    
        case WizardSteps.SelectImportToSites:  valid = ValidateSelectImportToSites(); break;
        }

        // If valid move to next stage in wizard
        if (valid)
        {
            switch (this.GetAddType())
            {
            case AddType.CreateNew          : WizardCreateNew();            break;
            case AddType.ImportFromOtherSite: WizardImportFromOtherSite();  break;
            }
        }
    }    

    protected void btnCheck_OnClick(object sender, EventArgs e)
    {
        ValidateEnterNewCode(false);
    }
    #endregion

    #region Coordinate Wizard methods
    /// <summary>
    /// Coordinates create new wizard
    /// Steps are 
    ///     Select Add method
    ///     Enter new code
    ///     Fill in Editor Control
    ///     Select Import to Sites
    /// </summary>
    private void WizardCreateNew()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.AddType:   
            PopulateEnterNewCode();
            SetStep(WizardSteps.EnterNewCode);
            break;        
        case WizardSteps.EnterNewCode:
            PopulateEditorControl();
            SetStep(WizardSteps.EditorControl);            
            if (!this.importToSiteNumbers.Any())
                btnNext.Text = "Finish";
            break;
        case WizardSteps.EditorControl:
            if (!this.importToSiteNumbers.Any())
                Save();
            else
            {
                PopulateSelectImportToSites();
                SetStep(WizardSteps.SelectImportToSites);
                btnNext.Text = "Finish";
            }
            break;  
        case WizardSteps.SelectImportToSites:
            Save();
            break;  
        }
    }

    /// <summary>
    /// Coordinates create new wizard
    /// Steps are 
    ///     Select Add method
    ///     Select site
    ///     Select Pharamcy ward
    ///     Fill in Editor Control
    ///     Select Import to Sites
    /// </summary>
    private void WizardImportFromOtherSite()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.AddType:   
            PopulateSelectImportFromSite();
            SetStep(WizardSteps.SelectImportFromSite);
            break;        
        case WizardSteps.SelectImportFromSite:
            PopulateSelectImportFromWard();
            SetStep(WizardSteps.SelectImportFromWard);
            break;
        case WizardSteps.SelectImportFromWard:
            PopulateEditorControl();
            SetStep(WizardSteps.EditorControl);            
            break;
        case WizardSteps.EditorControl:
            if (this.importToSiteNumbers.Any())
            {
                PopulateSelectImportToSites();
                btnNext.Text = "Finish";
            }
            else
                Save();
            SetStep(WizardSteps.SelectImportToSites);
            break;
        case WizardSteps.SelectImportToSites:
            Save();
            break;  
        }
    }
    #endregion

    #region AddType Page
    /// <summary>Initalises the add type page</summary>
    private void PopulateAddType()
    {
        if (!this.showAddNew)
            rblAddType.Items.Remove(rblAddType.Items.FindByValue( ((int)AddType.CreateNew           ).ToString()) );
        if (!this.showAddFromOtherSite)
            rblAddType.Items.Remove(rblAddType.Items.FindByValue( ((int)AddType.ImportFromOtherSite ).ToString()) );

        if (rblAddType.Items.Count > 1)
            rblAddType.Items[0].Selected = true;    // Select first item in list
        else if (rblAddType.Items.Count == 1)
        {
            // Skip current stage and move to next
            rblAddType.Items[0].Selected = true;
            btnNext_OnClick(this, null);                                         
        }
        else
            ScriptManager.RegisterStartupScript(this, this.GetType(), "AddNotAllowed", "alertEnh('Option not available', function() { window.close() });", true);   // no add options

        rblAddType.Focus();
    }

    /// <summary>returns true</summary>
    private bool ValidateAddType() { return true; }

    /// <summary>Get the selected add type</summary>
    private AddType GetAddType()
    {
        return (AddType)int.Parse(rblAddType.SelectedValue);
    }
    #endregion

    #region SelectImportFromSite Page
    /// <summary>
    /// Populate SelectImportFromSite page
    /// Populates import site list from URL ImportFromSiteNumbers
    /// </summary>
    private void PopulateSelectImportFromSite()
    {
        if (rblSelectImportFromSite.Items.Count == 0)
        {
            SiteProcessor siteProcessor = new SiteProcessor(); 
            var sites = siteProcessor.LoadAll(true);

            // Add each site from importFromSiteNumbers
            foreach (var s in importFromSiteNumbers)
            {
                var site = sites.FirstOrDefault(c => c.Number == s);
                if (site != null)
                {
                    string name = string.Format("{0} - {1:000}", site.LocalHospitalAbbreviation, site.Number);
                    rblSelectImportFromSite.Items.Add(new ListItem(name, site.SiteID.ToString()));
                }
            }

            // Select first by default
            if (rblSelectImportFromSite.Items.Count > 0)
                rblSelectImportFromSite.SelectedIndex = 0;
            else
                errorMessage.Text = "No other sites available.";

            // If greater than 20 sites then add more columns
            // if more than 60 sites then show scroll bar
            // XN 19Nov14 104568 
            int columnCount = (rblSelectImportFromSite.Items.Count / MaxSitesPerColumns) + 1;
            if (columnCount > 1)
            {
                rblSelectImportFromSite.RepeatColumns = Math.Min(columnCount, MaxColumns);
                rblSelectImportFromSite.RepeatLayout  = RepeatLayout.Table;
                if ( columnCount > MaxColumns )
                    pnSelectImportFromSite.ScrollBars = ScrollBars.Vertical;
            }
        }

        // Ensure control has focus
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "focus", "$('#rblSelectImportFromSite [checked]').focus();", true);
    }

    /// <summary>Validates SelectImportFromSite page (always returns true)</summary>
    private bool ValidateSelectImportFromSite() { return true; }

    /// <summary>Returns selected import from site ID for SelectImportFromSite page</summary>
    private int GetSelectedImportFromSiteID()
    {
        return string.IsNullOrEmpty(rblSelectImportFromSite.SelectedValue) ? -1 : int.Parse(rblSelectImportFromSite.SelectedValue);
    }    
    #endregion

    #region SelectImportFromWard Page
    /// <summary>
    /// Populate list of import from wards
    /// The list will contain customers from selected site that DO NOT exist on current site
    /// 31Oct14 XN 102842 Major updates to take into account sortLocator and take into account SupplierNameType
    /// </summary>
    private void PopulateSelectImportFromWard() 
    { 
        int selectedImportFromSiteNumber = Sites.GetNumberBySiteID( this.GetSelectedImportFromSiteID() );
        SupplierNameType nameType        = Winord.Defaults.SupplierShortName;

        // Load all customer for the site selected by user
        WCustomer otherSiteCustomers = new WCustomer();
        otherSiteCustomers.LoadBySiteIDAndInUse(this.GetSelectedImportFromSiteID(), null);

        // Load all customers for this site
        WCustomer thisSiteCustomers = new WCustomer();
        thisSiteCustomers.LoadBySiteIDAndInUse(SessionInfo.SiteID, null);
        var thisSiteCustomerCodes = thisSiteCustomers.Select(s => s.Code).OrderBy(s => s);

        // Setup grid headers
        gcSelectImportFromWard.AddColumn("Code", 10);
        switch ( nameType )
        {
        case SupplierNameType.ShortName : 
            this.gcSelectImportFromWard.AddColumn("Short Name", 89); 
            this.gcSelectImportFromWard.ColumnAllowTextWrap(1, true);
            break;
        case SupplierNameType.ShortAndLongName : 
            this.gcSelectImportFromWard.AddColumn("Short Name", 34); 
            this.gcSelectImportFromWard.AddColumn("Long Name",  55); 
            this.gcSelectImportFromWard.ColumnAllowTextWrap(1, true);
            this.gcSelectImportFromWard.ColumnAllowTextWrap(2, true);
            break;
        case SupplierNameType.FullName :
            this.gcSelectImportFromWard.AddColumn("Full Name", 89); 
            this.gcSelectImportFromWard.ColumnAllowTextWrap (1, true);
            break;
        }

        // Sort the list 30Oct14 102842
        // First convert list to ID, code, and description
        // And then sort by either code, or description.
        // 30Oct14 102842 Allow sorting of Pharmacy ward list selector
        var list = from c in otherSiteCustomers
                   select new { WCustomerID = c.WCustomerID,
                                Code        = c.Code,
                                Description = c.ToNameString(nameType),
                                Detail      = (nameType == SupplierNameType.ShortAndLongName) ? this.AppendNameAddess(c.FullName, c.Address) : string.Empty };
        list = sortWardsBy.EqualsNoCase("Description") ? list.OrderBy(c => c.Description.ToUpper()) : list.OrderBy(c => c.Code.ToUpper());

        foreach (var c in list)
        {
            // Check if code exists on the current site
            if ( !thisSiteCustomerCodes.Contains(c.Code) )
            {
                gcSelectImportFromWard.AddRow();
                gcSelectImportFromWard.AddRowAttribute("Code", c.Code);
                gcSelectImportFromWard.SetCell(0, c.Code        );
                gcSelectImportFromWard.SetCell(1, c.Description );

                if ( nameType == SupplierNameType.ShortAndLongName )
                    gcSelectImportFromWard.SetCell(2, c.Detail ); 
            }
        }

        // Select first row (or show empty message)
        if (gcSelectImportFromWard.RowCount > 0)
            ScriptManager.RegisterStartupScript(this, this.GetType(), "SelectFirtsRow", "selectRow('gcSelectImportFromWard', 0); $('#gcSelectImportFromWard').focus();", true);
        else
            gcSelectImportFromWard.EmptyGridMessage = string.Format("Site {0:000} does not contain any new locations, that are not covered by site {1:000}", selectedImportFromSiteNumber, SessionInfo.SiteNumber);

        hfHeaderSuffix.Value = "from <b>Site " + selectedImportFromSiteNumber.ToString("000") + "</b>";
    }

    /// <summary>Returns ture (as one item is always selected</summary>
    private bool ValidateSelectImportFromWard() { return true; }

    /// <summary>Get the selected import from locatino code</summary>
    private string GetSelectImportFromLocationCode()
    {
        return hfSelectImportFromWardCode.Value;
    }
    #endregion

    #region EnterNewCode Page
    /// <summary>Populate the enter new code textbox</summary>
    private void PopulateEnterNewCode()
    {
        tbCode.Attributes["onclick"] += "this.select();";
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "SetFocus", "try { $('#tbCode').focus(); }catch(ex) {}", true);
    }

    /// <summary>
    /// Validate the new code 
    ///     check entered correctly, 
    ///     Check Unique
    ///     Notify user if linked to HAP location
    /// Method can be called when the Check button is clicked as well as the next button
    /// </summary>
    /// <param name="hasClickedNextButton">If method is called when next button is click</param>
    private bool ValidateEnterNewCode(bool hasClickedNextButton)
    {
        string error;
        bool ok = true;

        if (!Validation.ValidateText(tbCode, "Code", typeof(string), true, WCustomer.GetColumnInfo().CodeLength, out error))
        {
            errorMessage.Text = error;
            ok = false;
        }

        // check if code is in use (location and supplier)
        string code  = GetNewCode();       
        if (!WCustomer.IsCodeUnique(code, SessionInfo.SiteID))
        {
            errorMessage.Text = "Code is already in use";
            ok = false;
        }

        // check if linked to HAP location 
        // (not really an error, but user need to be informed before moving to next stage)
        tbWardCodeCheckInfo.InnerHtml = string.Empty;   // Clear old message
        if (ok && hfLastCheckedCode.Value != tbCode.Text)
        {
            StringBuilder msg = new StringBuilder();

            WardRow ward = Ward.GetByWardCode(code);
            if (ward == null)
                msg.Append("This will be a pharmacy only location.<br />");
            else
            {
                msg.AppendFormat("This will link to HAP location {0} (WWardCode {1})<br />", ward.ToString().XMLEscape(), ward.Code.XMLEscape());
                if (ward.OutOfUse)
                    msg.Append("<span class='ErrorMessage' style='font-style:italic;'>HAP ward is marked out of use</span><br />");
            }

            if (hasClickedNextButton)
                msg.Append("<br />Click Next button again to continue.");
            tbWardCodeCheckInfo.InnerHtml = msg.ToString();

            ok = false;
        }

        // Remeber the last code checked (used for next button)
        hfLastCheckedCode.Value = tbCode.Text;

        // If not okay then select the box again
        if (!ok && hasClickedNextButton)
            ScriptManager.RegisterStartupScript(this, this.GetType(), "SelectCodeBox", "try{ $('#tbCode').focus(); $('#tbCode')[0].select(); }catch(ex) { }", true);

        return ok;
    }

    /// <summary>Return newly entered code</summary>
    private string GetNewCode()
    {
        return tbCode.Text.ToUpper().Trim();
    }
    #endregion

    #region EditorControl page
    /// <summary>Populates the editor control with the new ward</summary>
    private void PopulateEditorControl()
    {
        WCustomerColumnInfo columnInfo = WCustomer.GetColumnInfo();

        // Create the ward
        WCustomer customer = new WCustomer();
        WCustomerRow row = customer.Add();

        switch (this.GetAddType())
        {
        case AddType.CreateNew:
            row.Code  = this.GetNewCode();
            row.SiteID= SessionInfo.SiteID;          

            // Load and populate from the HAP ward
            WardRow ward = Ward.GetByWardCode(row.Code);    
            if (ward != null)
            {
                row.Description = ward.Description.SafeSubstring(0, columnInfo.DescriptionLength);
                row.FullName    = ward.ToString().SafeSubstring (0, columnInfo.FullNameLength   );
            }

            this.hfHeaderSuffix.Value = "<b>" + row.Code + "</b>" + (ward == null ? " <span class='ErrorMessage'>(pharmacy only location)</span>" : string.Empty);
            break;

        case AddType.ImportFromOtherSite:
            WCustomer fromOtherSite = new WCustomer();
            fromOtherSite.LoadBySiteAndCode(this.GetSelectedImportFromSiteID(), this.GetSelectImportFromLocationCode());
            if (fromOtherSite.Any())
            {
                // Not really need but best to be safe so get all columns and remove PK as adding new row
                // then copy all data, and rest the site ID
                List<string> columnNames = customer.Table.Columns.OfType<DataColumn>().Select(c => c.ColumnName).ToList();
                columnNames.Remove(customer.GetPKColumnName());
                row.CopyFrom(fromOtherSite.First(), columnNames);
                row.SiteID = SessionInfo.SiteID;
            }

            this.hfHeaderSuffix.Value = "<b>" + row.Code + "</b>" + (Ward.GetByWardCode(row.Code) == null ? " <span class='ErrorMessage'>(pharmacy only location)</span>" : string.Empty);
            break;
        }

        // Populate the editor control
        WCustomerAccessor processor = new WCustomerAccessor( customer, new int[] { SessionInfo.SiteID } );
        editorControl.Initalise(processor, "D|WCustomer", "Views", "Data", 1, false);

        // resize grid
        ScriptManager.RegisterStartupScript(this, this.GetType(), "resize", "divGPE_onResize();", true);
    }

    /// <summary>
    /// Validates DisplayEditor page
    /// Requires postback to perform full validation
    /// </summary>
    private bool ValidateEditorControl()
    {
        if (hfDisplayEditorValidated.Value == "1")
            return true;    // Validation has passed after postback so return true
        else
        {
            // Validate will display errors to user, and then postback with hfDisplayEditorValidated set to 1
            editorControl.Validate();
            return false;
        }

    }

    /// <summary>Get access to the WCustomerProcessor for the editor control</summary>
    private WCustomerAccessor GetEditorControlProcessor()
    {
        return editorControl.QSProcessor as WCustomerAccessor;
    }

    /// <summary>
    /// Called when QuesScrl on DisplayEditor page is validated sucessfully
    /// Will set hfDisplayEditorValidated to 1 so when ValidateDisplayEditor is called will return that validation has passed
    /// </summary>
    protected void editorControl_OnValidated()
    {
        // Cause postback to try validation again
        hfDisplayEditorValidated.Value = "1";
        ScriptManager.RegisterStartupScript(this, this.GetType(), "Validated", "$('#btnNext').click()", true);
    }
    #endregion

    #region SelectImportToSites page
    /// <summary>Populate the list of site the user is allowed to import the ward to</summary>
    private void PopulateSelectImportToSites()
    {
        // Save values to cached data
        editorControl.QSProcessor.Save(editorControl.QSView, false);

        // Get current ward detaisl
        WCustomerRow newRow = GetEditorControlProcessor().Customers.First();;

        List<Site> sites = new SiteProcessor().LoadAll();

        foreach(int siteNumber in this.importToSiteNumbers)
        {
            Site site = sites.FirstOrDefault(s => s.Number == siteNumber);
            if (site != null)
            {
                // Add site to the list
                string text = string.Format("{0} - {1:000}", site.LocalHospitalAbbreviation, site.Number);
                ListItem li = new ListItem(text, site.SiteID.ToString());

                if ( !WCustomer.IsCodeUnique(newRow.Code, site.SiteID) )
                {
                    // Ward already exists on the site (with same ward code)
                    li.Text    += " - (code in use by site for location or supplier)";
                    li.Enabled = false;
                }

                cblSelectImportToSites.Items.Add(li);
            }
        }

        // If greater than 20 sites then add more columns
        // if more than 60 sites then show scroll bar
        // XN 19Nov14 104568 
        int columnCount = (cblSelectImportToSites.Items.Count / MaxSitesPerColumns) + 1;
        if (columnCount > 1)
        {
            cblSelectImportToSites.RepeatColumns = Math.Min(columnCount, MaxColumns);
            cblSelectImportToSites.RepeatLayout  = RepeatLayout.Table;
            if ( columnCount > MaxColumns )
                pnSelectImportToSites.ScrollBars = ScrollBars.Vertical;
        }

        cblSelectImportToSites.Focus();

        this.hfHeaderSuffix.Value = " - <b>" + (newRow.Code + " - " + newRow.Description).XMLEscape() + "</b>";
    }

    /// <summary>
    /// Validates select import to site
    /// Always returns true
    /// </summary>
    private bool ValidateSelectImportToSites()
    {
        return true;
    }

    /// <summary>Get list of selected site IDs (from import to site page)</summary>
    private IEnumerable<int> GetSelectImportToSitesIDs()
    {
        return cblSelectImportToSites.CheckedItems().Select(s => int.Parse(s.Value));
    }
    #endregion

    #region Helper Methods
    /// <summary>Append the name and the address (with comma inbetween)</summary>
    private string AppendNameAddess(string name, string address)
    {
        string result = string.Empty;
        if (!string.IsNullOrEmpty(name))
            result += name.TrimEnd(new [] { '.' });
        if (!string.IsNullOrEmpty(address))
            result += ", " + address;
        return result;
    }

    /// <summary>
    /// Set the next step the wizard is moving to
    /// Also set the title prefix for the next step (depends on step type)
    /// </summary>
    /// <param name="nextStep">Step to move to</param>
    private void SetStep(WizardSteps nextStep)
    {
        string headerPrefix = string.Empty;

        switch (nextStep)
        {
        case WizardSteps.AddType             : headerPrefix = "Choose Add Method";              multiView.SetActiveView(vAddType);              break;
        case WizardSteps.SelectImportFromSite: headerPrefix = "Select import from site";        multiView.SetActiveView(vSelectImportFromSite); break;
        case WizardSteps.SelectImportFromWard: headerPrefix = "Select pharmacy location";       multiView.SetActiveView(vSelectImportFromWard); break;
        case WizardSteps.EnterNewCode        : headerPrefix = "Enter new code";                 multiView.SetActiveView(vEnterNewCode);         break;
        case WizardSteps.EditorControl       : headerPrefix = "Enter details for ";             multiView.SetActiveView(vEditorControl);        break;
        case WizardSteps.SelectImportToSites : headerPrefix = "Select other sites to import to";multiView.SetActiveView(vSelectImportToSites);  break;
        }

        // Save step
        hfCurrentStep.Value = nextStep.ToString();
        spanHeader.InnerHtml = headerPrefix + " " + hfHeaderSuffix.Value;
    }

    /// <summary>Save the sites to disk</summary>
    private void Save()
    {
        // Save values to cached data
        editorControl.QSProcessor.Save(editorControl.QSView, false);

        WCustomer    customer = new WCustomer();
        WCustomerRow firstRow = GetEditorControlProcessor().Customers.First();

        customer.LoadByCode(firstRow.Code);
        
        WCustomerRow newRow = customer.FindBySiteID( SessionInfo.SiteID ).FirstOrDefault();
        if ( newRow == null )
            newRow = customer.Add();        // Prevents duplicates
        newRow.CopyFrom(firstRow);

        foreach (int siteID in this.GetSelectImportToSitesIDs())
        {
            newRow = customer.FindBySiteID(siteID).FirstOrDefault();
            if ( newRow == null )
                newRow = customer.Add();    // Prevents duplicates
            newRow.CopyFrom(firstRow);
            newRow.SiteID = siteID;
        }

        customer.Save();

        // And close
        this.ClosePage(firstRow.Code);
    }
    #endregion
}