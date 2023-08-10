//===========================================================================
//
//						  PharmacySupplierWardSearch.aspx.cs
//
//  Allows user to search supplier. This is a copy of vb6 ask supplier form
//  in Supplier.bas asksupplier
//       
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - (optional) Pharmacy site
//  SiteID              - (optional) Pharmacy site
//  DefaultSupCode      - (optional) default supcode to select
//  SupCodeFilter       - (optional) CSV list of supcode for suppliers to display in list
//                        Replaces vb6 asksupplier parameter Filter$ where Filter$='PROFILES'
//  OptionalRow         - (optional) row shown at top of list (e.g. <All>, <New>) if user 
//                        selecting this row returns empty string. 
//                        So to add item <All> call url as &OptionalRow=%3CAll%3E
//                        Replaces vb6 asksupplier parameter Code% (where Code%=1 would be <All> and Code%=2 would be <New>)
//  SupplierTypesFilter - (optional) Supplier type codes to filter list of suppliers default is empty string for all suppliers
//                        (e.g. W - for ward, ES - for external or stores)
//                        Replaces vb6 asksupplier parameter Filter$
//  Title               - (optional) title to display on page (e.g. Enter Supplier Code) default is 'Enter Supplier Code'
//                        Replaces vb6 asksupplier parameter Caption$
//  DisplayNotInUse     - (optional) If to display suppliers that are not in use (Y or N) default is N
//                        Replaces vb6 asksupplier parameter DisplayNotInuse%
//  PSOOnly             - (optional) If to display PSO only suppliers (Y or N) default is N
//                        Replaces vb6 asksupplier parameter blPSO%
//  ForceSelection      - (optional) If user must select supplier when clicking okay button (Y or N) default is Y
//
//  The page will return the selected WSupplierID, supcode and description as
//      {WSupplierID|SupCode|Description}
//  if nothing selected returns undefined
//  if optionalRow selected returns empty string
//      
//
//  Usage:
//  PharmacySupplierWardSearch.aspx?SessionID=123&AscribeSiteNumber=700
//
//	Modification History:
//	17Jul13 XN  Written 24653
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_pharmacysharedscripts_PharmacySupplierWardSearch : System.Web.UI.Page
{
    #region Data Types
    /// <summary>
    /// Supplier name type to display read from WConfiguration setting
    /// Category: D|Winord
    /// Section: defaults
    /// Key: SupplierShortName    
    /// 
    /// if value is B           then SupplierNameType.ShortAndLongName
    /// if value is Y. T, 1, -1 then SupplierNameType.ShortName
    /// All others SupplierNameType.FullName
    /// </summary>
    protected enum SupplierNameType
    {
        ShortName,
        ShortAndLongName,
        FullName
    }
    #endregion

    #region Member Variables
    /// <summary>Session ID</summary>
    protected int sessionID;

    /// <summary>Site ID (can be null not passed in on query string in which case site dropdown is displayed)</summary>
    protected int? siteID;

    /// <summary>default supplier code to select</summary>
    protected string defaultSupCode;

    /// <summary>List of supplier codes to filter the list to</summary>
    protected IEnumerable<string> supCodeFilter;

    /// <summary>Optional row to display e.g. {Add}</summary>
    protected string optionalRow;

    /// <summary>List of supplier type codes to filter list to (empty string for all supplier types)</summary>
    protected string supplierTypesFilter;

    /// <summary>Cation to display in top of window</summary>
    protected string caption;
    
    /// <summary>If to display not in use suppliers</summary>
    protected bool displayNotInUse;

    /// <summary>If to display PSO only suppliers</summary>
    protected bool psoOnlySuppliers;

    /// <summary>If user must select a supplier before the form will close with OK</summary>
    protected bool forceSelection;
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        // Get Session ID
        sessionID = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        // Get SiteID (could come in as AscribeSiteNumber or SiteID)
        siteID = null;
        int tempSite;
        string siteStr = Request["SiteID"];
        if (siteID == null && !string.IsNullOrEmpty(siteStr) && int.TryParse(siteStr, out tempSite))
            siteID = tempSite;
        siteStr = Request["AscribeSiteNumber"];
        if (siteID == null && !string.IsNullOrEmpty(siteStr) && int.TryParse(siteStr, out tempSite))
            siteID = Sites.GetSiteIDByNumber(tempSite);

        // Get URL parameters
        defaultSupCode      = Request["DefaultSupCode"]      ?? string.Empty;
        supCodeFilter       = (Request["SupCodeFilter"]      ?? string.Empty).Split(new [] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        optionalRow         = Request["OptionalRow"]         ?? string.Empty;    
        supplierTypesFilter = Request["SupplierTypesFilter"] ?? string.Empty;
        caption             = (Request["Title"]              ?? "Enter Supplier Code");
        displayNotInUse     = BoolExtensions.PharmacyParse(Request["DisplayNotInUse"] ?? "false");
        psoOnlySuppliers    = BoolExtensions.PharmacyParse(Request["PSOOnly"]         ?? "false");
        forceSelection      = BoolExtensions.PharmacyParse(Request["ForceSelection"]  ?? "true" );

        if (!this.IsPostBack)
        {
            // Set java side handling of OnKeyDown
            this.tbSearch.Attributes["onkeydown"] += "tbSearch_onkeydown(event)";
            this.tbSearch.Attributes["onkeyup"]   += "tbSearch_onkeyup(event)";
            this.tbSearch.MaxLength = WSupplier.GetColumnInfo().CodeLength;

            // If only display wards change search caption
            if (supplierTypesFilter == EnumDBCodeAttribute.EnumToDBCode(SupplierType.Ward))
                lbSearchCaption.Text = "Enter Ward Code";

            // Site not passed in so display site drop down list (and try displaying site number from this)
            if (siteID == null)
            {
                this.sitesPanel.Visible = true;
                PopulateSiteList();
            }

            // Initialise form (empty setup)
            PopulateSuppliersGrid();

            // Set initial search text
            tbSearch.Text = this.defaultSupCode;

            // Select item by default supcode passed else first item in grid
            string script = string.Empty;
            if (!string.IsNullOrEmpty(this.defaultSupCode))
                script = string.Format("updateGridSelection('{0}');", tbSearch.Text);
            else if (gcSearchResults.RowCount > 0)
                script = "selectRow('gcSearchResults', 0);";
            // ScriptManager.RegisterStartupScript(this, this.GetType(), "UpdateGridSelection", script + " $('#tbSearch')[0].select();", true); 87544 XN 31Mar14 get odd javascript error so put in try catch
            ScriptManager.RegisterStartupScript(this, this.GetType(), "UpdateGridSelection", script + " try { $('#tbSearch')[0].select(); } catch(ex) {}", true);
        }
    }

    /// <summary>
    /// Called when user changes the select site
    /// Updates the grid with based on the new site
    /// </summary>
    protected void ddlSites_OnSelectedIndexChanged(object sender, EventArgs e)
    {
        siteID = int.Parse(ddlSites.SelectedValue);
        PopulateSuppliersGrid();
        ScriptManager.RegisterStartupScript(this, this.GetType(), "UpdateGridSelection", string.Format("updateGridSelection('{0}'); $('#tbSearch')[0].select();", tbSearch.Text), true);
    }
    #endregion

    #region Private Methods
    /// <summary>Populates the sites drop down list</summary>
    private void PopulateSiteList()
    {
        SiteProcessor siteProcessor = new SiteProcessor();
        IEnumerable<Site> sites = siteProcessor.LoadAll(true);

        ddlSites.Items.Clear();
        foreach (Site site in sites)
            ddlSites.Items.Add(new ListItem(site.ToString(), site.SiteID.ToString()));

        // Set site
        this.siteID = int.Parse(ddlSites.SelectedItem.Value);
    }

    /// <summary>
    /// Get the SupplierShortName from WConfiguration setting (not cached)
    /// Category: D|Winord
    /// Section: defaults
    /// Key: SupplierShortName
    /// </summary>
    private SupplierNameType SupplierNameDisplayType
    {
        get
        {
            // Get setting
            string supplierShortName = WConfiguration.Load<string>(siteID.Value, "D|Winord", "defaults", "SupplierShortName", "N", false);

            bool shortName;
            BoolExtensions.TryPharmacyParse(supplierShortName, out shortName);

            // Convert to SupplierNameType
            if (supplierShortName.EqualsNoCaseTrimEnd("B"))
                return SupplierNameType.ShortAndLongName;
            else if(shortName)
                return SupplierNameType.ShortName;
            else
                return SupplierNameType.FullName;
        }
    }


    /// <summary>Populate suppliers grid with with suppliers</summary>
    private void PopulateSuppliersGrid()
    {
        SupplierNameType supplierNameDisplayType = this.SupplierNameDisplayType;
        int selectedRowIndex = 0;

        this.gcSearchResults.SortableColumns           = true;
        this.gcSearchResults.EnableAlternateRowShading = true;
        this.gcSearchResults.HorizontalScrollBar       = true;

        // Setup the orders table columns
        this.gcSearchResults.AddColumn("Code",        10);
        this.gcSearchResults.AddColumn("Cost centre", 15);

        switch (supplierNameDisplayType)
        {
        case SupplierNameType.ShortName : 
            this.gcSearchResults.AddColumn("Short Name", 74); 
            this.gcSearchResults.ColumnAllowTextWrap(2, true);
            break;
        case SupplierNameType.ShortAndLongName : 
            this.gcSearchResults.AddColumn("Short Name", 29); 
            this.gcSearchResults.AddColumn("Long Name",  45); 
            this.gcSearchResults.ColumnAllowTextWrap(2, true);
            this.gcSearchResults.ColumnAllowTextWrap(3, true);
            break;
        case SupplierNameType.FullName :
            this.gcSearchResults.AddColumn("Full Name", 74); 
            this.gcSearchResults.ColumnAllowTextWrap (2, true);
            break;
        }

        // Add the optional row e.g. <All> or <New>
        if (!string.IsNullOrEmpty(this.optionalRow))
        {
            this.gcSearchResults.AddRow();
            this.gcSearchResults.AddRowAttribute("SupCode", this.optionalRow);
            this.gcSearchResults.SetCell(0, this.optionalRow);
        }

        // Get supplier filter
        SupplierType[] supplierTypes = supplierTypesFilter.ToCharArray().Select(c => EnumDBCodeAttribute.DBCodeToEnum<SupplierType>(c.ToString()) ).ToArray();

        // Load suppliers
        WSupplier suppliers = new WSupplier();
        suppliers.LoadBySiteIDAndSupplierTypes(this.siteID.Value, supplierTypes);

        // Add each row from search results
        foreach (var row in suppliers.OrderBy(s => s.Code))
        {
            // skip rows that are not full filled by filter conditions
            if (this.psoOnlySuppliers && !row.PSOSupplier)
                continue;
            if (StringExtensions.IsNullOrEmptyAfterTrim(row.Code))
                continue;
            if (!this.displayNotInUse && !(row.InUse ?? true))
                continue;
            if (this.supCodeFilter.Any() && !this.supCodeFilter.ContainsNoCase(row.Code))
                continue;

            // Add supplier
            this.gcSearchResults.AddRow();
            this.gcSearchResults.AddRowAttribute("WSupplierID", row.SupplierID.ToString());
            this.gcSearchResults.AddRowAttribute("SupCode",     row.Code                 );
            this.gcSearchResults.SetCell(0, row.Code);
            if (!StringExtensions.IsNullOrEmptyAfterTrim(row.WardCode) &&  row.WardCode != row.Code)
                this.gcSearchResults.SetCell(1, "({0})", row.WardCode);

            switch (supplierNameDisplayType)
            {
            case SupplierNameType.ShortName :             
                this.gcSearchResults.SetCell(2, this.AppendNameAddess(row.Name, row.SupAddress)); 
                break;
            case SupplierNameType.ShortAndLongName : 
                this.gcSearchResults.SetCell(2, row.Name    ); 
                this.gcSearchResults.SetCell(3, this.AppendNameAddess(row.FullName, row.SupAddress)); 
                break;
            case SupplierNameType.FullName :
                string name =  StringExtensions.IsNullOrEmptyAfterTrim(row.FullName) ? row.Name : row.FullName;
                this.gcSearchResults.SetCell(2, this.AppendNameAddess(name, row.SupAddress)); 
                break;
            }
        }
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
