//===========================================================================
//
//						  SelectPharmacySupplier.aspx.cs
//
//  Allows user to search for an supplier (internal or external). 
//  This is a copy of vb6 ask supplier form in Supplier.bas asksupplier (for supplier type W)
//
//  If a site number or name parameter is not supplied to form will display drop down list for user to choose.
//  
//  Based on WConfiguration setting 
//  Category: D|SiteInfo
//  Section:  
//  Key:      UseOldWSupplierScreens
//  Page will either use new WSupplier2 table or WSupplier table (SupplierType E or S)
//       
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - (optional) Pharmacy site
//  SiteID              - (optional) Pharmacy site (if a site parameter is not supplied will display drop down list for user to choose)
//  DefaultCode         - (optional) default code to select
//  OptionalRow         - (optional) row shown at top of list (e.g. <All>, <New>) if user 
//                        selecting this row returns empty string. 
//                        So to add item <All> call url as &OptionalRow=%3CAll%3E
//                        Replaces vb6 asksupplier parameter Code% (where Code%=1 would be <All> and Code%=2 would be <New>)
//  InUseOnly           - (optional) If to display wards that are in use only (Y or N) default is Y
//                        Replaces vb6 asksupplier parameter DisplayNotInuse%
//  SortBy              - (optional) Sort list by this column
//
//  The page will return the selected WSupplier2ID, Code as
//      {WSupplier2ID|Code|Description}
//  if nothing selected returns undefined
//  if optionalRow selected returns string -1|OptionalRow Text
//      
//  Usage:
//  SelectPharmacySupplier.aspx?SessionID=123&AscribeSiteNumber=700
//
//	Modification History:
//	25Jun14 XN  Written 88506
//  31Oct14 XN  Added SortBy 102842
//  24Nov14 XN  Added cost center columne 104903
//  22Dec14 XN  106906 changed supplier selection form to filter out rows when typeing to box
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using System.Web.UI.WebControls;

public partial class application_PharmacySupplierEditor_SelectPharmacySupplier : System.Web.UI.Page
{
    #region Member Variables
    /// <summary>default code to select</summary>
    protected string defaultCode;

    /// <summary>Optional row to display e.g. {Add}</summary>
    protected string optionalRow;

    /// <summary>If the list should only show in-use wards</summary>
    protected bool inUseOnly;

    /// <summary>Sort by this column</summary>
    protected string sortBy;

    protected bool embeddedMode = false;
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSession(this.Request);

        // do not have to define site (as will display a drop down list to allow selection of site)
        if (Request["SiteID"] != null || Request["AscribeSiteNumber"] != null)
            SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);
        else if (!string.IsNullOrWhiteSpace(ddlSites.SelectedValue))
            SessionInfo.InitialiseSessionAndSiteID(SessionInfo.SessionID, int.Parse(ddlSites.SelectedValue));

        // Get parameters
        defaultCode     = Request["DefaultCode"] ?? string.Empty;
        optionalRow     = Request["OptionalRow"] ?? string.Empty;    
        inUseOnly       = BoolExtensions.PharmacyParse(Request["InUseOnly"] ?? "true" );
        sortBy          = Request["SortBy"] ?? "Code";
        embeddedMode    = BoolExtensions.PharmacyParseOrNull(Request["EmbeddedMode"]) ?? false;

        if (!this.IsPostBack)
        {
            // Set java side handling of OnKeyDown
            this.tbSearch.Attributes["onkeyup"] += "tbSearch_onkeyup(event)";

            // Site not passed in so display site drop down list (and try displaying site number from this)
            if (!SessionInfo.HasSite)
            {
                this.sitesPanel.Visible = true;
                PopulateSiteList();
            }

            // Set initial search text
            tbSearch.Text = defaultCode;
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        // Initialise grid
        // As should always be done (and can depend on ddlSites) it is done in pre render stage
        PopulateHeader();
        if (WConfiguration.Load<bool>(SessionInfo.SiteID, "D|SiteInfo", string.Empty, "UseOldWSupplierScreens", false, false))
        {
            this.gcGrid.EmptyGridMessage="No wards setup for this site " + SessionInfo.SiteNumber.ToString("000") + " (in WSupplier table)";
            PopulateGridFromWSupplier();
        }
        else
        {
            this.gcGrid.EmptyGridMessage="No wards setup for this site " + SessionInfo.SiteNumber.ToString("000") + " (in WSupplier2 table)";
            PopulateGridFromWSupplier2();
        }
    }

    /// <summary>
    /// Called when user changes the select site
    /// Updates the grid with based on the new site
    /// </summary>
    protected void ddlSites_OnSelectedIndexChanged(object sender, EventArgs e)
    {
        int siteID = int.Parse(ddlSites.SelectedValue);
        SessionInfo.InitialiseSessionAndSiteID(SessionInfo.SessionID, siteID);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "UpdateGridSelection", "updateGridSelection(true); $('#tbSearch')[0].select();", true);
    }

    /// <summary>
    /// Called when okay button is clicked
    /// Closes the page returniong selected id and code
    /// </summary>
    protected void btnOk_OnClick(object sender, EventArgs e)
    {
        string returnValue = string.Empty;
        if (hfSelectedID.Value != "-1")
        {
            WSupplier2 supplier = new WSupplier2();
            supplier.LoadByID(int.Parse(hfSelectedID.Value));
            returnValue = hfSelectedID.Value + "|" + supplier.First().Code + "|" + supplier.First().ToString();
        }
        else
            returnValue = hfSelectedID.Value + "|" + this.optionalRow;

        this.ClosePage(returnValue);
    }
    #endregion

    #region Private Members
    /// <summary>Populates the sites drop down list</summary>
    private void PopulateSiteList()
    {
        SiteProcessor siteProcessor = new SiteProcessor();
        IEnumerable<Site> sites = siteProcessor.LoadAll(true);

        ddlSites.Items.Clear();
        foreach (Site site in sites)
            ddlSites.Items.Add(new ListItem(site.ToString(), site.SiteID.ToString()));

        // Set site
        SessionInfo.InitialiseSessionAndSiteID(SessionInfo.SessionID, int.Parse(ddlSites.SelectedItem.Value));
    }

    /// <summary>Populates the grid header</summary>
    private void PopulateHeader()
    {
        this.gcGrid.SortableColumns           = true;
        this.gcGrid.EnableAlternateRowShading = true;
        this.gcGrid.HorizontalScrollBar       = true;

        // Setup the orders table columns
        this.gcGrid.AddColumn("Code", 10);
        switch (Winord.Defaults.SupplierShortName)
        {
        case SupplierNameType.ShortName : 
            this.gcGrid.AddColumn("Short Name", 74); 
            this.gcGrid.ColumnAllowTextWrap(1, true);
            break;
        case SupplierNameType.ShortAndLongName : 
            this.gcGrid.AddColumn("Short Name", 29); 
            this.gcGrid.AddColumn("Long Name",  45); 
            this.gcGrid.ColumnAllowTextWrap(1, true);
            this.gcGrid.ColumnAllowTextWrap(2, true);
            break;
        case SupplierNameType.FullName :
            this.gcGrid.AddColumn("Full Name", 74); 
            this.gcGrid.ColumnAllowTextWrap (1, true);
            break;
        }
        this.gcGrid.AddColumn("Cost centre", 15);
    }

    /// <summary>Populates the grid with list of items from the WSupplier2 table</summary>
    private void PopulateGridFromWSupplier2()
    {
        SupplierNameType supplierNameDisplayType = Winord.Defaults.SupplierShortName;
        int selectedRowIndex = 0;

        // Add the optional row e.g. <All> or <New>
        if (!string.IsNullOrEmpty(this.optionalRow))
        {
            this.gcGrid.AddRow();
            this.gcGrid.AddRowAttribute("ID",   "-1");
            this.gcGrid.AddRowAttribute("Code", this.optionalRow);
            this.gcGrid.SetCell(0, this.optionalRow);
        }

        // Load suppliers
        WSupplier2 suppliers = new WSupplier2();
        suppliers.LoadBySiteIDAndInUse(SessionInfo.SiteID, this.inUseOnly ? true : (bool?)null);

        // First convert list to ID, code, and description
        // And then sort by either code, or description.
        // 30Oct14 102842 Allow sorting of Pharmacy ward list selector
        var list = from c in suppliers
                   select new { WSupplier2ID= c.WSupplier2ID,
                                Code        = c.Code,
                                CostCentre  = c.CostCentre,
                                Description = c.ToNameString(supplierNameDisplayType),
                                Detail      = (supplierNameDisplayType == SupplierNameType.ShortAndLongName) ? this.AppendNameAddess(c.FullName, c.SupplierAddress) : string.Empty };
        list = this.sortBy.EqualsNoCase("Description") ? list.OrderBy(s => s.Description) : list.OrderBy(s => s.Code);

        // Add each row from search results
        foreach (var row in list)
        {
            if (StringExtensions.IsNullOrEmptyAfterTrim(row.Code))
                continue;

            // Add supplier
            this.gcGrid.AddRow();
            this.gcGrid.AddRowAttribute("ID",   row.WSupplier2ID.ToString());
            this.gcGrid.AddRowAttribute("Code", row.Code                  );
            this.gcGrid.SetCell(0, row.Code        );
            this.gcGrid.SetCell(1, row.Description ); 

            if ( supplierNameDisplayType == SupplierNameType.ShortAndLongName )
            {
                this.gcGrid.SetCell(2, row.Detail ); 
                this.gcGrid.SetCell(3, row.CostCentre  );
            }
            else 
                this.gcGrid.SetCell(2, row.CostCentre  );

            // If its is the default code the select  02Sep14 XN  88509
            if (row.Code == defaultCode)
                selectedRowIndex = this.gcGrid.RowCount - 1;
        }

        // If items in list the select one  02Sep14 XN  88509
        if (this.gcGrid.RowCount > 0)
            ScriptManager.RegisterStartupScript(this, this.GetType(), "SelectRow", string.Format("selectRow('gcGrid', {0}, true);", selectedRowIndex), true);
    }

    /// <summary>Populates the grid with list of items from the WSupplier table</summary>
    private void PopulateGridFromWSupplier()
    {
        SupplierNameType supplierNameDisplayType = Winord.Defaults.SupplierShortName;
        int selectedRowIndex = 0;

        // Add the optional row e.g. <All> or <New>
        if (!string.IsNullOrEmpty(this.optionalRow))
        {
            this.gcGrid.AddRow();
            this.gcGrid.AddRowAttribute("ID",   "-1");
            this.gcGrid.AddRowAttribute("Code", this.optionalRow);
            this.gcGrid.SetCell(0, this.optionalRow);
        }

        // Load suppliers
        WSupplier suppliers = new WSupplier();
        suppliers.LoadBySiteIDAndSupplierTypes(SessionInfo.SiteID, new SupplierType[] { SupplierType.External, SupplierType.Stores });

        // First convert list to ID, code, and description
        // And then sort by either code, or description.
        // 30Oct14 102842 Allow sorting of Pharmacy ward list selector
        var list = from c in suppliers
                   select new { SupplierID  = c.SupplierID,
                                Code        = c.Code,
                                CostCentre  = c.CostCentre,
                                Description = c.ToNameString(supplierNameDisplayType),
                                Detail      = (supplierNameDisplayType == SupplierNameType.ShortAndLongName) ? this.AppendNameAddess(c.FullName, c.SupAddress) : string.Empty };
        list = this.sortBy.EqualsNoCase("Description") ? list.OrderBy(s => s.Description) : list.OrderBy(s => s.Code);

        // Add each row from search results
        foreach (var row in list)
        {
            if (StringExtensions.IsNullOrEmptyAfterTrim(row.Code))
                continue;

            // Add supplier
            this.gcGrid.AddRow();
            this.gcGrid.AddRowAttribute("ID",   row.SupplierID.ToString());
            this.gcGrid.AddRowAttribute("Code", row.Code                  );
            this.gcGrid.SetCell(0, row.Code       );
            this.gcGrid.SetCell(1, row.Description ); 

            if ( supplierNameDisplayType == SupplierNameType.ShortAndLongName )
            {
                this.gcGrid.SetCell(2, row.Detail ); 
                this.gcGrid.SetCell(3, row.CostCentre  );
            }
            else 
                this.gcGrid.SetCell(2, row.CostCentre  );

            // If its is the default code the select  02Sep14 XN  88509
            if (row.Code == defaultCode)
                selectedRowIndex = this.gcGrid.RowCount - 1;
        }

        // If items in list the select one  02Sep14 XN  88509
        if (this.gcGrid.RowCount > 0)
            ScriptManager.RegisterStartupScript(this, this.GetType(), "SelectRow", string.Format("selectRow('gcGrid', {0}, true);", selectedRowIndex), true);
    }

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
    #endregion
}