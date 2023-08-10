//===========================================================================
//
//						  SelectPharmacyWard.aspx.cs
//
//  Allows user to search for a ward. 
//  This is a copy of vb6 ask supplier form in Supplier.bas asksupplier (for supplier type W)
//
//  If a site number or name parameter is not supplied to form will display drop down list for user to choose.
//  
//  Based on WConfiguration setting 
//  Category: D|SiteInfo
//  Section:  
//  Key:      UseOldWSupplierScreens
//  Page will either use new WCustomer table or WSupplier table (SupplierType L or W)
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
//  ShowPharmacyOnlyColumn- (optional) If to show the pharmacy only indicates if it pharmacy ward is linked to 
//                         hap ward 
//  SortBy              - (optional) Sort list by this column
//
//  The page will return the selected WCustomerID, Code as
//      {WCustomerID|Code|Description}
//  if nothing selected returns undefined
//  if optionalRow selected returns string -1|OptionalRow Text
//      
//  Usage:
//  SelectPharmacyWard.aspx?SessionID=123&AscribeSiteNumber=700
//
//	Modification History:
//	17Jul13 XN  Written 88509
//  02Sep14 XN  88509 Added ShowPharmacyOnlyColumn option
//              Remove cost centre column
//              checked searching to filter list by code, and description
//  31Oct14 XN  Added SortBy 102842
//  22Dec14 XN  106906 Ensure display error if ward is not selected
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_PharmacyWardEditor_SelectPharmacyWard : System.Web.UI.Page
{
    #region Constants
    private readonly string HAPNotInUseText = "(HAP ward not in use)";
    #endregion

    #region Data Types
    #endregion

    #region Member Variables
    /// <summary>default code to select</summary>
    protected string defaultCode;

    /// <summary>Optional row to display e.g. {Add}</summary>
    protected string optionalRow;

    /// <summary>If the list should only show in-use wards</summary>
    protected bool inUseOnly;

    /// <summary>If pharmayc only column is displayed (if pharmacy ward is linked to hap ward) 02Sep14 XN 88509</summary>
    protected bool showPharmacyOnlyColumn;

    /// <summary>Sort by this column</summary>
    protected string sortBy;
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
        defaultCode             = Request["DefaultCode"] ?? string.Empty;
        optionalRow             = Request["OptionalRow"] ?? string.Empty;    
        inUseOnly               = BoolExtensions.PharmacyParse(Request["InUseOnly"]             ?? "true" );
        showPharmacyOnlyColumn  = BoolExtensions.PharmacyParse(Request["ShowPharmacyOnlyColumn"]?? "false");    // 02Sep14 XN  88509
        sortBy                  = Request["SortBy"] ?? "Code";

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

            // Initialise grid 
            // As should always be done (and can depend on ddlSites) it is done in pre render stage
            // 3Sept14 XN moved from PreRender to Load
            PopulateHeader();
            if (WConfiguration.Load<bool>(SessionInfo.SiteID, "D|SiteInfo", string.Empty, "UseOldWSupplierScreens", false, false))
            {
                this.gcGrid.EmptyGridMessage="No wards setup for this site " + SessionInfo.SiteNumber.ToString("000") + " (in WSupplier table)";
                PopulateGridFromWSupplier();
            }
            else
            {
                this.gcGrid.EmptyGridMessage="No wards setup for this site " + SessionInfo.SiteNumber.ToString("000") + " (in WCustomer table)";
                PopulateGridFromWCustomer();
            }

            // Set initial search text
            tbSearch.Text = defaultCode;
        }
    }

    //protected void Page_PreRender(object sender, EventArgs e) 3Sept14 XN removed as not needed
    //{
    //    // Initialise grid
    //    // As should always be done (and can depend on ddlSites) it is done in pre render stage
    //    PopulateHeader();
    //    if (WConfiguration.Load<bool>(SessionInfo.SiteID, "D|SiteInfo", string.Empty, "UseOldWSupplierScreens", false, false))
    //    {
    //        this.gcGrid.EmptyGridMessage="No wards setup for this site " + SessionInfo.SiteNumber.ToString("000") + " (in WSupplier table)";
    //        PopulateGridFromWSupplier();
    //    }
    //    else
    //    {
    //        this.gcGrid.EmptyGridMessage="No wards setup for this site " + SessionInfo.SiteNumber.ToString("000") + " (in WCustomer table)";
    //        PopulateGridFromWCustomer();
    //    }
    //}

    /// <summary>
    /// Called when user changes the select site
    /// Updates the grid with based on the new site
    /// </summary>
    protected void ddlSites_OnSelectedIndexChanged(object sender, EventArgs e)
    {
        int siteID = int.Parse(ddlSites.SelectedValue);
        SessionInfo.InitialiseSessionAndSiteID(SessionInfo.SessionID, siteID);
        //ScriptManager.RegisterStartupScript(this, this.GetType(), "UpdateGridSelection", "updateGridSelection(true); $('#tbSearch')[0].select();", true); 02Sep14 XN  88509
        ScriptManager.RegisterStartupScript(this, this.GetType(), "UpdateGridSelection", "filterList(true); $('#tbSearch')[0].select();", true);
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
            WCustomer customer = new WCustomer();
            customer.LoadByID(int.Parse(hfSelectedID.Value));
            returnValue = hfSelectedID.Value + "|" + customer.First().Code + "|" + customer.First().ToString();
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
        //this.gcGrid.AddColumn("Cost centre", 15); 02Sep14 XN  88509

        switch (Winord.Defaults.SupplierShortName)
        {
        case SupplierNameType.ShortName : 
            //this.gcGrid.AddColumn("Short Name", 74); 
            //this.gcGrid.ColumnAllowTextWrap(2, true); 02Sep14 XN  88509
            this.gcGrid.AddColumn("Short Name", this.showPharmacyOnlyColumn ? 74 : 89); 
            this.gcGrid.ColumnAllowTextWrap(1, true);
            break;
        case SupplierNameType.ShortAndLongName : 
            //this.gcGrid.AddColumn("Short Name", 29); 
            //this.gcGrid.AddColumn("Long Name",  45); 
            //this.gcGrid.ColumnAllowTextWrap(2, true);
            //this.gcGrid.ColumnAllowTextWrap(3, true); 02Sep14 XN  88509
            this.gcGrid.AddColumn("Short Name", this.showPharmacyOnlyColumn ? 27 : 34); 
            this.gcGrid.AddColumn("Long Name",  this.showPharmacyOnlyColumn ? 47 : 55); 
            this.gcGrid.ColumnAllowTextWrap(1, true);
            this.gcGrid.ColumnAllowTextWrap(2, true);
            break;
        case SupplierNameType.FullName :
            //this.gcGrid.AddColumn("Full Name", 74); 
            //this.gcGrid.ColumnAllowTextWrap (2, true); 02Sep14 XN  88509
            this.gcGrid.AddColumn("Full Name", this.showPharmacyOnlyColumn ? 74 : 89); 
            this.gcGrid.ColumnAllowTextWrap (1, true);
            break;
        }

        // added pharmacy only columnn if requested
        // 02Sep14 XN  88509
        if (this.showPharmacyOnlyColumn)
        {
            this.gcGrid.AddColumn("Pharmacy Only", 15, PharmacyGridControl.AlignmentType.Center); 
            this.gcGrid.ColumnAllowTextWrap (this.gcGrid.ColumnCount - 1, true);
        }
    }

    /// <summary>Populates the grid with list of items from the WCusomter table</summary>
    private void PopulateGridFromWCustomer()
    {
        SupplierNameType supplierNameDisplayType = Winord.Defaults.SupplierShortName;
        List<WardRow> hapWards = null;
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
        WCustomer customers = new WCustomer();
        customers.LoadBySiteIDAndInUse(SessionInfo.SiteID, this.inUseOnly ? true : (bool?)null);

        // First convert list to ID, code, and description
        // And then sort by either code, or description.
        // 30Oct14 102842 Allow sorting of Pharmacy ward list selector
        var list = from c in customers
                   select new { WCustomerID = c.WCustomerID,
                                Code        = c.Code,
                                Description = c.ToNameString(supplierNameDisplayType),
                                Detail      = (supplierNameDisplayType == SupplierNameType.ShortAndLongName) ? this.AppendNameAddess(c.FullName, c.Address) : string.Empty };
        list = this.sortBy.EqualsNoCase("Description") ? list.OrderBy(s => s.Description) : list.OrderBy(s => s.Code);

        // If showing PharmacyOnly column load HAP ward codes (and if ward is in use) 02Sep14 XN  88509
        IDictionary<string,List<WardRow>> hapWardCodesToWard = new Dictionary<string,List<WardRow>>();
        if (this.showPharmacyOnlyColumn)
            hapWardCodesToWard = Ward.GetAll().GroupBy(w => w.Code).ToDictionary(w => w.Key, w => w.AsEnumerable().ToList());

        // Add each row from search results
        foreach (var row in list)
        {
            if (StringExtensions.IsNullOrEmptyAfterTrim(row.Code))
                continue;
            
            // Add supplier
            this.gcGrid.AddRow();
            this.gcGrid.AddRowAttribute("ID",   row.WCustomerID.ToString());
            this.gcGrid.AddRowAttribute("Code", row.Code                  );
            this.gcGrid.SetCell(0, row.Code        );
            this.gcGrid.SetCell(1, row.Description ); 

            if ( supplierNameDisplayType == SupplierNameType.ShortAndLongName )
                this.gcGrid.SetCell(2, row.Detail ); 

            // display pharmcy only ward state (options are Y, (HAP ward not in use), blank (if not pharmacy only)  02Sep14 XN  88509
            if (this.showPharmacyOnlyColumn)
            { 
                if (!hapWardCodesToWard.TryGetValue(row.Code, out hapWards))
                    this.gcGrid.SetCell(gcGrid.ColumnCount - 1, "Yes");
                else if (hapWards.All(w => w.OutOfUse))
                    this.gcGrid.SetCell(gcGrid.ColumnCount - 1, HAPNotInUseText);
            }

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
        List<WardRow> hapWards = null;
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
        suppliers.LoadBySiteIDAndSupplierTypes(SessionInfo.SiteID, new SupplierType[] { SupplierType.Ward, SupplierType.List });

        // First convert list to ID, code, and description
        // And then sort by either code, or description.
        // 30Oct14 102842 Allow sorting of Pharmacy ward list selector
        var list = from c in suppliers
                   select new { SupplierID  = c.SupplierID,
                                Code        = c.Code,
                                Description = c.ToNameString(supplierNameDisplayType),
                                Detail      = (supplierNameDisplayType == SupplierNameType.ShortAndLongName) ? this.AppendNameAddess(c.FullName, c.SupAddress) : string.Empty };
        list = this.sortBy.EqualsNoCase("Description") ? list.OrderBy(s => s.Description) : list.OrderBy(s => s.Code);

        // If showing PharmacyOnly column load HAP ward codes (and if ward is in use)  02Sep14 XN  88509
        IDictionary<string,List<WardRow>> hapWardCodesToWard = new Dictionary<string,List<WardRow>>();
        if (this.showPharmacyOnlyColumn)
            hapWardCodesToWard = Ward.GetAll().GroupBy(w => w.Code).ToDictionary(w => w.Key, w => w.AsEnumerable().ToList());

        // Add each row from search results
        foreach (var row in list)
        {
            if (StringExtensions.IsNullOrEmptyAfterTrim(row.Code))
                continue;

            // Add supplier
            this.gcGrid.AddRow();
            this.gcGrid.AddRowAttribute("ID",   row.SupplierID.ToString());
            this.gcGrid.AddRowAttribute("Code", row.Code                  );
            this.gcGrid.SetCell(0, row.Code        );
            this.gcGrid.SetCell(1, row.Description ); 

            if ( supplierNameDisplayType == SupplierNameType.ShortAndLongName )
                this.gcGrid.SetCell(2, row.Detail); 

            // display pharmcy only ward state (options are Y, (HAP not in use), blank (if not pharmacy only)  02Sep14 XN  88509
            if (this.showPharmacyOnlyColumn)
            { 
                if (!hapWardCodesToWard.TryGetValue(row.Code, out hapWards))
                    this.gcGrid.SetCell(gcGrid.ColumnCount - 1, "Yes");
                else if (hapWards.All(w => w.OutOfUse))
                    this.gcGrid.SetCell(gcGrid.ColumnCount - 1, HAPNotInUseText);
            }

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