//==============================================================================================
//
//      					            NewPharmacySupplierWizard.aspx.cs
//
//  Allows user to add a new supplier (via a wizard)
//
//  Ask user to optional select an ICW supplier
//  Then allows user to fill in supplier details
//  Then allows user to add the supplier to other sites
//
//  The desktop has the following desktop parameters
//  AscribeSiteNumber       - Main ascribe site number for the desktop
//  ImportFromSiteNumbers   - CSV list of sites the user can import from or "All" for all sites
//  EditableSiteNumbers     - CSV list of sites the user can import to   or "All" for all sites
//  ShowAddExternalSupplier }
//  ShowAddInternalSupplier }   - Controls add options avaiable to the user
//  ShowAddFromOther        }
//
//	Modification History:
//	26Jun14 XN  Written 88506
//  18Nov14 XN  Added show add options
//  19Nov14 XN  104568 Alow to show more the 14 sites import from and to panels   
//  27nov14 XN  Added Import from Site option
//  09Nov14 XN  105861 resized from to ensure error message can be seen (also got it to display error of no from sites selected)
//  22Dec14 XN  106906 changed supplier selection form to filter out rows when typeing to box
//  13Jul16 XN  158049 desktop parameter changed from ShowAddFromOther to ShowAddOtherSite
//==============================================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using System.Web.Services;

public partial class application_PharmacySupplierEditor_NewPharmacySupplierWizard : System.Web.UI.Page
{
    #region Data Types
    /// <summary>List of steps in the wizard</summary>
    protected enum WizardSteps
    {
        /// <summary>Select Add Method</summary>
        SelectAddMethod,

        /// <summary>Select site</summary>
        SelectSite,

        /// <summary>Allows user to select supplier from list</summary>
        FindSupplier,

        /// <summary>edit new settings</summary>
        EditorControl,

        /// <summary>List sites to import to</summary>
        SelectImportToSites,
    }

    /// <summary>Type of add method (first page of wizard)</summary>
    protected enum AddMethodType
    {
        /// <summary>Adding via external supplier</summary>
        ExternalSupplier = 0,

        /// <summary>Adding via other site</summary>
        InternalSupplier = 1,

        /// <summary>Adding from other site</summary>
        ImportFromOtherSite = 2,
    }
    #endregion

    #region Constants
    private const int MaxSitesPerColumns = 20;  // 19Nov14 XN 104568 Alow to show more the 14 sites import from and to panels
    private const int MaxColumns         = 3;   // 19Nov14 XN 104568 Alow to show more the 14 sites import from and to panels
    #endregion

    #region Variables
    private List<int> editableSiteNumbers;
    private List<int> importFromSiteNumbers;
    private bool showAddExternalSupplier= true;
    private bool showAddInternalSupplier= true;
    private bool showAddFromOther       = true;
    #endregion

    #region Properties
    /// <summary>Current step in the wizard</summary>
    protected WizardSteps CurrentStep { get { return (WizardSteps)Enum.Parse(typeof(WizardSteps), hfCurrentStep.Value); } }
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        Sites sites = new Sites();
        sites.LoadAll(true);

        // Get list of import from sites (and remove curent site)
        string editableSiteNumbersStr = Request["EditableSiteNumbers"] ?? string.Empty;
        if (editableSiteNumbersStr.EqualsNoCaseTrimEnd("All"))
            editableSiteNumbers = sites.Select(s => s.SiteNumber).ToList();
        else
            editableSiteNumbers = editableSiteNumbersStr.ParseCSV<int>(",", true).ToList();
        editableSiteNumbers.Remove(SessionInfo.SiteNumber);   // Remove current site

        // Get list of import from sites
        string importFromSiteNumbersStr = Request["ImportFromSiteNumbers"] ?? string.Empty;
        if (importFromSiteNumbersStr.EqualsNoCaseTrimEnd("All"))
            importFromSiteNumbers = sites.Select(s => s.SiteNumber).ToList();
        else
            importFromSiteNumbers = importFromSiteNumbersStr.ParseCSV<int>(",", true).ToList();
        importFromSiteNumbers.Remove(SessionInfo.SiteNumber);   // Remove current site

        showAddExternalSupplier = BoolExtensions.PharmacyParse(Request["ShowAddExternalSupplier"] ?? "true");
        showAddInternalSupplier = BoolExtensions.PharmacyParse(Request["ShowAddInternalSupplier"] ?? "true");
        //showAddFromOther        = BoolExtensions.PharmacyParse(Request["ShowAddFromOther"]        ?? "true");  13Jul16 XN 158049
        showAddFromOther        = BoolExtensions.PharmacyParse(Request["ShowAddOtherSite"]        ?? "true");

        if (!this.IsPostBack)
        {
            // Start the wizard
            SetStep(WizardSteps.SelectAddMethod);
            PopulateAddMethod();
        }
    }

    /// <summary>
    /// Called when next button is clicked
    /// Validates current stage in wizard, then moves to next stage is wizard
    /// </summary>
    protected void btnNext_OnClick(object sender, EventArgs e)
    {
        // Clear existing errors
        errorMessage.Text = "&nbsp;";

        // Validate current wizard step
        bool valid = true;
        switch(this.CurrentStep)
        {
        case WizardSteps.SelectAddMethod:    valid = ValidateSelectAddMethod();     break;
        case WizardSteps.SelectSite:         valid = ValidateSelectSite();          break;
        case WizardSteps.FindSupplier:       valid = ValidateFindSupplier();        break;
        case WizardSteps.EditorControl:      valid = ValidateEditorControl();       break;    
        case WizardSteps.SelectImportToSites:valid = ValidateSelectImportToSites(); break;
        }

        // If valid move to next stage in wizard
        if (valid)
        {
            switch(this.GetSelectedAddMethodType())
            {
            case AddMethodType.ExternalSupplier:     WizardExternalSupplier();  break;
            case AddMethodType.InternalSupplier:     WizardInternalSupplier();         break;
            case AddMethodType.ImportFromOtherSite:  WizardFromOtherSite();     break;
            }

        }
    }    
    #endregion

    #region Coordinate Wizard methods
    /// <summary>
    /// Coordinates external supplier wizard
    /// Steps are 
    ///     Fill in Editor Control
    ///     Select Import to Sites
    /// </summary>
    private void WizardExternalSupplier()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.SelectAddMethod:            
            WSupplier2 suppliers = new WSupplier2();
            suppliers.Add();
            suppliers[0].SiteID = SessionInfo.SiteID;
            suppliers[0].Type   = SupplierType.External;
            suppliers[0].Method = SupplierMethod.Direct;

            PopulateEditorControl( suppliers );

            SetStep(WizardSteps.EditorControl);
            if (!this.editableSiteNumbers.Any())
                btnNext.Text = "Finish";
            break;        
        case WizardSteps.EditorControl:
            if (this.editableSiteNumbers.Any())
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

    /// <summary>
    /// Coordinates internal supplier wizard
    /// Steps are 
    ///     Select site to add
    ///     Fill in Editor Control
    ///     Select Import to Sites
    /// </summary>
    private void WizardInternalSupplier()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.SelectAddMethod:  
            var sites = new Sites();
            sites.LoadAll(true);
            PopulateOtherSites(sites.Select(s => s.SiteNumber));
            SetStep(WizardSteps.SelectSite);
            break;
        case WizardSteps.SelectSite:
            WSupplier2 suppliers = new WSupplier2();            
            WSupplier2Row newRow = suppliers.Add();
            WSupplier2ColumnInfo columnInfo = WSupplier2.GetColumnInfo();
            Site site = (new SiteProcessor()).LoadBySiteID( GetSelectedSiteID() );

            // Copy the supplier details from the ICW side
            newRow.SiteID                          = SessionInfo.SiteID;
            newRow.Code                            = site.Number.ToString("000");
            newRow.Description                     = site.LocalHospitalAbbreviation.SafeSubstring(0, columnInfo.DescriptionLength);
            newRow.FullName                        = site.LocalHospitalAbbreviation.SafeSubstring(0, columnInfo.FullNameLength   );
            newRow.LocationID_PharmacyStockholding = site.SiteID;
            newRow.Type                            = SupplierType.Stores;
            newRow.Method                          = SupplierMethod.Internal;

            this.hfHeaderSuffix.Value = " - <b> Supplier: " + site.Number.ToString("000") + "</b>";

            PopulateEditorControl(suppliers);
            SetStep(WizardSteps.EditorControl);
            if (!this.editableSiteNumbers.Any())
                btnNext.Text = "Finish";
            break;        
        case WizardSteps.EditorControl:
            if (this.editableSiteNumbers.Any())
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

    /// <summary>
    /// Coordinates from other site wizard
    /// Steps are 
    ///     Select site to select from
    ///     Select supllier from other site
    ///     Fill in Editor Control
    ///     Select Import to Sites
    /// </summary>
    private void WizardFromOtherSite()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.SelectAddMethod:  
            PopulateOtherSites(this.importFromSiteNumbers);
            SetStep(WizardSteps.SelectSite);
            break;
        case WizardSteps.SelectSite:
            PopulateFindSupplier(string.Empty);
            SetStep(WizardSteps.FindSupplier);
            break;        
        case WizardSteps.FindSupplier:
            WSupplier2Row supplierFrom = WSupplier2.GetByID(this.GetFindSupplierID());

            WSupplier2 suppliers = new WSupplier2();
            suppliers.Add();
            suppliers[0].CopyFrom(supplierFrom);
            suppliers[0].SiteID = SessionInfo.SiteID;

            PopulateEditorControl(suppliers);
            SetStep(WizardSteps.EditorControl);
            if (!this.editableSiteNumbers.Any())
                btnNext.Text = "Finish";
            break;        
        case WizardSteps.EditorControl:
            if (this.editableSiteNumbers.Any())
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

    #region Add Method Page
    private void PopulateAddMethod() 
    { 
        if (!this.showAddExternalSupplier)
            rblSelectAddMethod.Items.Remove(rblSelectAddMethod.Items.FindByValue( ((int)AddMethodType.ExternalSupplier      ).ToString()) );
        if (!this.showAddInternalSupplier)
            rblSelectAddMethod.Items.Remove(rblSelectAddMethod.Items.FindByValue( ((int)AddMethodType.InternalSupplier      ).ToString()) );
        if (!this.showAddFromOther)
            rblSelectAddMethod.Items.Remove(rblSelectAddMethod.Items.FindByValue( ((int)AddMethodType.ImportFromOtherSite   ).ToString()) );

        if (rblSelectAddMethod.Items.Count > 1)
            rblSelectAddMethod.Items[0].Selected = true;    // Select first item in list
        else if (rblSelectAddMethod.Items.Count == 1)
        {
            // Skip current stage and move to next
            rblSelectAddMethod.Items[0].Selected = true;
            btnNext_OnClick(this, null);                                         
        }
        else
            ScriptManager.RegisterStartupScript(this, this.GetType(), "AddNotAllowed", "alertEnh('Option not available', function() { window.close() });", true);   // no add options

        rblSelectAddMethod.Focus();
    }

    private bool ValidateSelectAddMethod()
    {
        if (string.IsNullOrEmpty(rblSelectAddMethod.SelectedValue))
            errorMessage.Text = "Select an add method";
        return !string.IsNullOrEmpty(rblSelectAddMethod.SelectedValue);
    }

    private AddMethodType GetSelectedAddMethodType()
    {
        return (AddMethodType)int.Parse(rblSelectAddMethod.SelectedValue);
    }
    #endregion

    #region SelectImportFromSite Page
    /// <summary>
    /// Populate SelectImportFromSite page
    /// Populates import site list from URL ImportFromSiteNumbers
    /// </summary>    
    private void PopulateOtherSites(IEnumerable<int> siteNumbersToDisplay)
    {
        var sites = (new SiteProcessor()).LoadAll(true);
        
        WSupplier2 supplier = new WSupplier2();
        supplier.LoadBySiteIDAndInUse(SessionInfo.SiteID, false);

        foreach (var siteNumber in siteNumbersToDisplay)
        {
            var site = sites.FirstOrDefault(s => s.Number == siteNumber);
            if (site != null && site.SiteID != SessionInfo.SiteID)
            {
                string text = string.Format("{0} - {1:000}", site.LocalHospitalAbbreviation, site.Number);
                if (supplier.Any(sup => sup.LocationID_PharmacyStockholding == site.SiteID))
                    text += " (already in use)";    // Warn user but can have more that one supplier per site
                rblSelectSite.Items.Add( new ListItem(text, site.SiteID.ToString()) );
            }
        }

        if (rblSelectSite.Items.Count > 0)
            rblSelectSite.SelectedIndex = 0;
        else
            errorMessage.Text = "No other sites available.";

        // If greater than 20 sites then add more columns
        // if more than 60 sites then show scroll bar
        // XN 19Nov14 104568 
        int columnCount = (rblSelectSite.Items.Count / MaxSitesPerColumns) + 1;
        if (columnCount > 1)
        {
            rblSelectSite.RepeatColumns = Math.Min(columnCount, MaxColumns);
            rblSelectSite.RepeatLayout  = RepeatLayout.Table;
            if ( columnCount > MaxColumns )
                pnSelectSite.ScrollBars = ScrollBars.Vertical;
        }
    }

    private bool ValidateSelectSite()
    {
        if (string.IsNullOrEmpty(rblSelectAddMethod.SelectedValue))
            errorMessage.Text = "Select a site";
        return !string.IsNullOrEmpty(rblSelectAddMethod.SelectedValue);
    }

    private int GetSelectedSiteID()
    {
        return rblSelectSite.SelectedItem == null ? -1 : int.Parse(rblSelectSite.SelectedValue);
    }
    #endregion

    #region Find Drug Page
    private void PopulateFindSupplier(string selectedCode)
    {
        hfFindSupplierParams.Value = "&SiteID=" + this.GetSelectedSiteID();
        if (!string.IsNullOrEmpty(selectedCode))
            hfFindSupplierParams.Value += "&DefaultCode=" + selectedCode;
    }

    /// <summary>
    /// Validation done client side and using WebMethod ValidateFindSupplier
    /// So this method always returns true
    /// </summary>
    private bool ValidateFindSupplier()
    {
        return true;
    }

    /// <summary>
    /// Web method that does the actual validation of selected supplier
    /// Returns error message or empty string if no error
    /// </summary>
    [WebMethod]
    public static string ValidateFindSupplier(int sessionID, int siteID, int? supplierID)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);

        // Check if supplier is select
        if (supplierID == null)
            return "Select a supplier from the list";

        // Check if the supplier is on this site
        var supplierCode = WSupplier2.GetByID(supplierID.Value).Code;
        var supplier     = WSupplier2.GetBySiteIDAndCode(siteID, supplierCode);
        if (supplier != null)
            return "Supplier already in use by this site " + supplier.ToString();

        return string.Empty;
    }
    
    private int GetFindSupplierID()
    {
        return int.Parse(hfFindSupplierID.Value);
    }
    #endregion

    #region EditorControl page
    /// <summary>Populates the editor control with the new supplier</summary>
    private void PopulateEditorControl(WSupplier2 supplier)
    {
        // Populate the editor control
        WSupplier2Accessor accessor = new WSupplier2Accessor( supplier, new int[] { SessionInfo.SiteID } );
        switch (this.GetSelectedAddMethodType())
        {
        case AddMethodType.ExternalSupplier:    editorControl.Initalise(accessor, "D|WSupplier2", "Views", "Data", WSupplier2Accessor.VIEWINDEX_ADD_EXTERNALSUPPLIER, false); break;
        case AddMethodType.InternalSupplier:    editorControl.Initalise(accessor, "D|WSupplier2", "Views", "Data", WSupplier2Accessor.VIEWINDEX_ADD_INTERNALSUPPLIER, false); break;
        case AddMethodType.ImportFromOtherSite: editorControl.Initalise(accessor, "D|WSupplier2", "Views", "Data", WSupplier2Accessor.VIEWINDEX_ADD_OTHERSITE,        false); break;
        }   

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

    /// <summary>Get access to the WSupplier2Accessor for the editor control</summary>
    private WSupplier2Accessor  GetEditorControlAccessor()
    {
        return editorControl.QSProcessor as WSupplier2Accessor;
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
    /// <summary>Populate the list of site the user is allowed to import the supplier to</summary>
    private void PopulateSelectImportToSites()
    {
        // Save values to cached data
        editorControl.QSProcessor.Save(editorControl.QSView, false);

        // Get current supplier details
        WSupplier2Row newRow = GetEditorControlAccessor().Suppliers.First();
        int? stockholdingSiteID =  newRow.LocationID_PharmacyStockholding;

        List<Site> sites = new SiteProcessor().LoadAll();

        int? selectedSiteID = this.GetSelectedSiteID(); // If doing other site as supplier

        foreach(int siteNumber in this.editableSiteNumbers)
        {
            Site site = sites.FirstOrDefault(s => s.Number == siteNumber);
            if (site != null && stockholdingSiteID != site.SiteID)
            {
                // Add site to the list
                string text = string.Format("{0} - {1:000}", site.LocalHospitalAbbreviation, site.Number);
                ListItem li = new ListItem(text, site.SiteID.ToString());
                
                if ( !WSupplier2.IsCodeUnique(newRow.Code, site.SiteID) )
                {
                    // Supplier already exists on the site (with same ward code)
                    li.Text    += " - (already exists for site)";
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

        this.hfHeaderSuffix.Value = " - <b> Supplier: " + newRow.Code.XMLEscape() + "</b>";
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
        case WizardSteps.SelectAddMethod:    multiView.SetActiveView(vSelectAddMethod    ); headerPrefix = "Select add method";                 break;
        case WizardSteps.SelectSite:         multiView.SetActiveView(vSelectSite         ); headerPrefix = "Select site";                       break;
        case WizardSteps.FindSupplier:       multiView.SetActiveView(vFindSupplier       ); headerPrefix = "Select supplier";                   break;
        case WizardSteps.EditorControl:      multiView.SetActiveView(vEditorControl      ); headerPrefix = "Enter details for new supplier ";   break;
        case WizardSteps.SelectImportToSites:multiView.SetActiveView(vSelectImportToSites); headerPrefix = "Select other sites to import to";   break;
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

        WSupplier2    supplier = new WSupplier2();
        WSupplier2Row firstRow = GetEditorControlAccessor().Suppliers.First();

        supplier.LoadByCode( firstRow.Code );
        
        WSupplier2Row newRow = supplier.FindBySiteID( SessionInfo.SiteID ).FirstOrDefault();
        if ( newRow == null )
            newRow = supplier.Add();        // Prevents duplicates
        newRow.CopyFrom(firstRow);

        foreach (int siteID in this.GetSelectImportToSitesIDs())
        {
            newRow = supplier.FindBySiteID(siteID).FirstOrDefault();
            if ( newRow == null )
                newRow = supplier.Add();    // Prevents duplicates
            newRow.CopyFrom(firstRow);
            newRow.SiteID = siteID;
        }

        supplier.Save();

        // And close
        this.ClosePage(firstRow.Code);
    }
    #endregion
}