//==============================================================================================
//
//      					    ICW_PharmacySupplierEditor.aspx.cs
//
//  ICW desktop for the pharamcy supplier editor. 
//  Uses QuesScrl and allows single or multiple sites editing depending on desktop editor
//
//  The class uses values from WConfiguration Category D|WSupplier2
//  All the data is read from WSupplier2
//
//  On bottom right of desktop displays if message when changes have been made to the form.
//  Done via client side timer (1 secs) that updates the text based on the dirty state.
//
//  The desktop has the following desktop parameters
//  AscribeSiteNumber       - Main ascribe site number for the desktop
//  EditableSiteNumbers     - CSV list of other sites the user can edit (default none) can use "All" for all sites
//  ConfigurationEditor     - if allowed to edit desktop configuration (options are None,Desktop)
//  ImportFromSiteNumbers   - Used by add wizard, and is a CSV list site numbers user is allowed to import from default is All
//  ShowAddExternalSupplier }
//  ShowAddInternalSupplier }   - Controls add options avaiable to the user
//  ShowAddFromOther        }
//
//	Modification History:
//	16Jun14 XN  Written
//  27Aug14 XN  Indicate when item has been saved 95415 
//  31Oct14 XN  Added sortSelector 102842
//  17Nov14 XN  Indicate when items are saved  104369 
//  18Nov14 XN  Added show add options   
//  18May15 XN  Added Change Report button
//  13Jul16 XN  158049 desktop parameter changed from ShowAddFromOther to ShowAddOtherSite
//==============================================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.icwdatalayer;

public partial class application_PharmacySupplierEditor_ICW_PharmacySupplierEditor : System.Web.UI.Page
{
    #region Variables
    /// <summary>List of editable sites</summary>
    protected List<int> editableSiteNumbers;

    /// <summary>Column to sort the location selector (used client side only)</summary>
    protected string sortSelectorColumn;
    
    private bool showAddExternalSupplier= true;
    private bool showAddInternalSupplier= true;
    private bool showAddFromOther       = true;
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        // Get list of editable sites (and add main site to it)
        if (Request["EditableSiteNumbers"].EqualsNoCaseTrimEnd("All"))
        {
            Sites sites = new Sites();
            sites.LoadAll();
            editableSiteNumbers = sites.Select(s => s.SiteNumber).ToList();
        }
        else
            editableSiteNumbers = (Request["EditableSiteNumbers"] ?? string.Empty).ParseCSV<int>(",", true).ToList();
        
        // Remove current site if present, and readd (so will always be first in list)
        editableSiteNumbers.Remove(SessionInfo.SiteNumber);
        editableSiteNumbers.Insert(0, SessionInfo.SiteNumber);

        // If more than 1 site then show site header row QuesSctrl
        this.editorControl.ShowHeaderRow = editableSiteNumbers.Count > 1;

        // Get sort selector column
        sortSelectorColumn = Request["SortSelector"] ?? "Code";

        // Get the currently allowed add options 18Nov14 XN
        showAddExternalSupplier = BoolExtensions.PharmacyParse(Request["ShowAddExternalSupplier"] ?? "true");
        showAddInternalSupplier = BoolExtensions.PharmacyParse(Request["ShowAddInternalSupplier"] ?? "true");
        //showAddFromOther        = BoolExtensions.PharmacyParse(Request["ShowAddFromOther"]        ?? "true"); 13Jul16 XN 158049
        showAddFromOther        = BoolExtensions.PharmacyParse(Request["ShowAddOtherSite"]        ?? "true");

        btnAdd.Visible = showAddExternalSupplier || showAddInternalSupplier || showAddFromOther;
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        string args = Request["__EVENTARGUMENT"];

        // Deal with __postBack events
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' });

        switch (argParams[0])
        {
        case "LoadItem":
            bool   justSaved= BoolExtensions.PharmacyParse(argParams[1]);   // 17Nov14 XN  Indicate when items are saved  104369
            string code     = argParams[2];
            LoadItem(code, true, justSaved);
            break;
        }
    }

    /// <summary>
    /// Called when save button is clicked
    /// Calls the editorControl Validate method
    /// </summary>
    protected void btnSave_OnClick(object sender, EventArgs e)
    {
        if (!string.IsNullOrWhiteSpace(this.hfSelectedCode.Value))
            this.editorControl.Validate();
    }

    /// <summary>
    /// Called when editorControl has been validated
    /// Calls the editorControl method Save
    /// </summary>
    protected void editorControl_OnValidated()
    {
        this.editorControl.Save();
    }

    /// <summary>
    /// Called when editorControl has been saved
    /// Clears the dirty flag
    /// </summary>
    protected void editorControl_OnSaved()
    {
        // reload (puts everything right)
        LoadItem(this.hfSelectedCode.Value, false, true);
    }
    #endregion

    #region Private Methods
    /// <summary>Loads the supplier into QuesScroll</summary>
    /// <param name="code">Supplier code</param>
    /// <param name="selectFirstRow">If to reselect first</param>
    /// <param name="showSaved">If to show save button</param>
    private void LoadItem(string code, bool selectFirstRow, bool showSaved)
    {
        // Load all supplier
        WSupplier2 supplier = new WSupplier2();
        supplier.LoadByCode(code);

        WSupplier2Row mainRow = supplier.FindBySiteID(SessionInfo.SiteID).First();

        // Get sits
        Sites sites = new Sites();
        sites.LoadAll(true);

        // Populate header
        lbSupplier.InnerText = mainRow.Code + " - " + mainRow.FullName;
        var notFoundOnFollowingSites = sites.FindSiteIDBySiteNumber(editableSiteNumbers).Where(s => !supplier.FindBySiteID(s).Any() );
        if (notFoundOnFollowingSites.Any())
            notFoundOnSites.InnerHtml = "<b>Not available on sites:</b> " + sites.FindSiteNumberByID(notFoundOnFollowingSites).Select(s => s.ToString("000")).ToCSVString(", ");
        upHeader.Update();

        // Populate QuesScroll
        WSupplier2Accessor processor = new WSupplier2Accessor(supplier, sites.FindSiteIDBySiteNumber(editableSiteNumbers));
        this.editorControl.Initalise(processor, "D|WSupplier2", "Views", "Data", WSupplier2Accessor.VIEWINDEX_EDITOR, true, selectFirstRow);

        this.hfSelectedCode.Value = code;
        this.hfWSupplierID.Value  = mainRow.WSupplier2ID.ToString();
        this.Title                = this.editorControl.QSView.ViewDescription;

        ScriptManager.RegisterStartupScript(this, this.GetType(), "clearDrityFlag", "clearIsPageDirty();", true);                       

        saveIndicator.ShowSavedText(showSaved); // 17Nov14 XN  Indicate when items are saved  104369
        saveIndicator.Update();
    }
    #endregion
}