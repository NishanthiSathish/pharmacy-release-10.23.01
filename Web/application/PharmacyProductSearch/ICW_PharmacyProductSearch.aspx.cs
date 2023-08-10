//===========================================================================
//
//						  ICW_PharmacyProductSearch.aspx.cs
//
//  Allows user to search pharmacy drugs. This is a copy of vb6 item enquiry screen,
//  however it does not yet cover all the features of the original omissions include
//      Displaying robot information
//      F2 for editing WProduct.Message
//       
//  Search is done against WProduct.Description however it is also possible for user to 
//  do a search against 
//        Tradename         - prefix with ?
//        Barcode           - if 8 or 13 chars all digits (search primary and alternate barcodes)
//        NSVCode           - if in nsv code pattern (see WCondiguration.D|STKMAINT.Data.9)
//        Code              - if 2 to 8 chars and follows code pattern (see WCondiguration.D|STKMAINT.Data.1)
//        Local             - if local pattern (see WCondiguration.D|STKMAINT.Data.72)
//                            or start with val in WCondiguration.D|STKMAINT.Data.LocalCodePrefix
//        Product & route   - prefix with ¦ or %C2%A6 for URL
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - (optional) Pharmacy site
//  SiteID              - (optional) SiteID
//  HideCost            - (optional) Yes\No option if user is to see prices\costs details
//  EmbeddedMode        - (optional) if page is embedded in another page (hides Ok/Cancel buttons), and cause ICW event
//  VB6Style            - (optional) if screen is in blue vb6 or newer white style.
//  SearchText          - (optional) Search text to initialise the control with
//  SelectNSVCode       - (optional) NSVCode selected by default (requires SearchText that returns items including the selected item)
//  MasterMode          - (optional) Yes\No If yes then only searches SiteProductData, else searches WProduct (default is no so uses WProduct)
//  AllowBNF            - (optional) Yes\No If yes then if user presses Alt+B will display the BNF lookup tree (default yes)
//  EnableSearching     - (optional) Yes\No if to allow user from searching for any item, otherwise user can only select the items (default yes)
//  ProductRouteID      - (optional) Used when searching by product and route to define the route
//  AutoSelectSingleItem- (optional) Auto select if list only has single item
//  RequestID           - (optional) Will search for suitable drugs based on a request ID (only support standard, doseless, or infusion prescription types)
//  CivasOnly           - (optional) If display CIVAS only (from WFormula)
//  InUseOnly           - (optional) If to only display in-use items (default is false so show both in and out of use items)
//  AllowStoresOnly     - (optional) Yes\No. If yes display Stores-only Items, else exclude them.
//
//  The page will return the selected SiteProductDataID, and description as
//      {SiteProductDataID|Description|NSVCode}
//
//  When in embeddedMode the page will call the following client side methods on the holding page
//      PharmacyProductSelected(NSVCode, siteProductDataID)     - when row is selected in the grid
//      PharmacyProductSelectionCleared()                       - when all rows are deselected in the  grid
//      PharmacyProductDoubleClicked(NSVCode, siteProductDataID)- when row double clicked in the gird    
//
//  To be responsive when a search is done the form will load the relevant rows into the
//  gird server side (with a SiteProductDataID attribute for each row), and then populate an xml 
//  island with the data to display in the panel, in from 
//          <Row SiteProductID="54842">
//              <NSVCode>DVX456F</NSVCode>
//              <Code></Code>
//              <Local>FGDEX</Local>
//              :
//          </Row>
//          :
//  The java side method pharmacygridcontrol_onselectrow will transfer data from xml island to panel.
//  This is done after a 0.25sec timer to prevent slow scrolling on large lists (might be improved
//  by returning the above xml in json format, and then updating from here)
//
//  Usage:
//  ICW_PharmacyProductSearch.aspx?SessionID=123&AscribeSiteNumber=700&HideCost=No
//
//  to search by product id 15445, and product route ID 5 will also hide the search text box, and auto select single item
//  ICW_PharmacyProductSearch.aspx?SessionID=123&AscribeSiteNumber=700&HideCost=No&SearchText=%C2%A615445&ProductRouteID=5&EnableSearching=Y&AutoSelectSingleItem=Y
//
//  In prescription search mode to search for drugs for a prescription will also hide the search text box, and auto select single item
//  ICW_PharmacyProductSearch.aspx?SessionID=123&AscribeSiteNumber=700&HideCost=No&RequestID=53465&EnableSearching=Y&AutoSelectSingleItem=Y
//
//	Modification History:
//	01Mar10 XN  Written
//  11Jan13 XN  Added Configuration stetting DisplayFormularyAsLetterOnly (38049)
//  23Apr13 XN  Added returns NSVCode (53147)
//  09Aug13 XN  Added EmbeddedMode, and VB6Style options (24653)
//              Coloured the Stock level column, and formular field in red italics
//  15Aug13 XN  Added robot indicator column 24653, and only updated the bottom 
//              panel on a 0.25sec interval
//  19Dec13 XN  Added search on SiteProductData only (78339)
//  23Jun14 XN  If doing master mode tradename search the display actual drug name (not tradename)
//  17Oct14 XN  88560 Add BNF search on Alt+B
//  28Oct14 XN  Updated PopulatePanel to use GetTradaname() 100212 
//  01Dec14 XN  Added description to client side events PharmacyProductSelected and PharmacyProductDoubleClicked (105480)
//  18Feb15 XN  Prevent user adding two spaces and then doing search
//  31Mar15 XN  114237 Added support for order by tradename (so generic's appear first in list) 
//  05May15 XN  Allow user to type text to move selection in grid 40374
//  08May15 XN  Renamed ProductSeatchType to ProductSearchType 111893 
//  12Jun15 XN  39882 Added VMPandAMP searching (with route filtering), plus searching on prescription,
//              auto select single item, and ability to load CIVAS only items
//  13Jul15 XN  39882 Added ability to load in use only items
//  13May16 XN  39882 PopulatePanel reset labels if called twice to prevent error
//  05Jul16 XN  157126 Fixed issue if list goes over limit then crash when selecting some drugs
//  08Aug16 KR  159583 Added AllowStoresOnly parameter when searching
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

using ascribe.pharmacy.manufacturinglayer;

using Unit = System.Web.UI.WebControls.Unit;

public partial class application_PharmacyProductSearch_ICW_PharmacyProductSearch : System.Web.UI.Page
{
    #region Constants
    /// <summary>Min search string len</summary>
    private const int MinSearchStringLength = 2;

    /// <summary>Max search string len</summary>
    private const int MaxSearchStringLength = 14;

    /// <summary>Limit number of results returned</summary>
    private const int LimitResultsCount = 700;    
    #endregion

    #region Member Variables
    /// <summary>If prices\cost values are to be displayed</summary>
    protected MoneyDisplayType moneyDisplayType = MoneyDisplayType.Show;

    /// <summary>xml island of product details to display in bottom panel (see )</summary>
    protected StringBuilder productDetails = new StringBuilder();

    /// <summary>If page embedded in another</summary>
    protected bool embeddedMode;

    /// <summary>If page in blue vb6 style or standard white</summary>
    protected bool vb6Style;

    /// <summary>Pharmacy site number</summary>
    protected int? siteNumber = null;

    /// <summary>If search SiteProductData</summary>
    protected bool masterMode = false;

    /// <summary>If BNF lookup tree is allowed 17Oct14 XN 88560</summary>
    protected bool allowBNF = true;

    /// <summary>If the search box is displayed</summary>
    protected bool enableSearching = true;

    /// <summary>If doing product search then adds the route filter</summary>
    protected int productRouteID = 0;

    /// <summary>If to filter the list of drugs to just WFormula items</summary>
    protected bool CivasOnly = false;

    /// <summary>If to only display in-use items</summary>
    protected bool inUseOnly = false;

    /// <summary>If to search for drug from a prescription</summary>
    protected int requestID = 0;

    /// <summary>Whether to display AllowsStoresOnly items</summary>
    protected bool allowStoresOnly = false;

    /// <summary>Auto select if list only has single item</summary>
    protected bool autoSelectSingleItem = false;
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        // Get Session ID
        SessionInfo.InitialiseSession(this.Request);   // Session ID needs to be set first but will be reset once got site details

        // Get site number
        string siteNumberStr = Request.QueryString["AscribeSiteNumber"];
        int? siteNumber = null;
        if (siteNumberStr != null)
            siteNumber = int.Parse(siteNumberStr);

        // Get SiteID
        string siteIDStr = Request.QueryString["SiteID"];
        int? siteID = null;
        if (!string.IsNullOrEmpty(siteIDStr))
            siteID = int.Parse(siteIDStr);

        // Get other url parameters
        this.embeddedMode           = BoolExtensions.PharmacyParse(this.Request["EmbeddedMode"]         ?? "false");
        this.vb6Style               = BoolExtensions.PharmacyParse(this.Request["VB6Style"]             ?? "true");
        this.masterMode             = BoolExtensions.PharmacyParse(this.Request["MasterMode"]           ?? "false");
        this.allowBNF               = BoolExtensions.PharmacyParse(this.Request["AllowBNF"]             ?? "true");   // 17Oct14 XN  88560 Added
        this.enableSearching        = BoolExtensions.PharmacyParse(this.Request["EnableSearching"]      ?? "true");   // 12Jun15 XN 39882
        this.CivasOnly              = BoolExtensions.PharmacyParse(this.Request["CivasOnly"]            ?? "false");
        this.inUseOnly              = BoolExtensions.PharmacyParse(this.Request["InUseOnly"]            ?? "false");  // 13Jul15 XN 39882
        this.allowStoresOnly        = BoolExtensions.PharmacyParse(this.Request["AllowStoresOnly"]      ?? "true");  // 08Aug16 KR 159583 Added  
        this.autoSelectSingleItem   = BoolExtensions.PharmacyParse(this.Request["AutoSelectSingleItem"] ?? "false");  // 12Jun15 XN 39882
        this.productRouteID         = ConvertExtensions.ChangeType<int>(this.Request["ProductRouteID"], 0); // 12Jun15 XN 39882
        this.requestID              = ConvertExtensions.ChangeType<int>(this.Request["RequestID"],      0); // 12Jun15 XN 39882

        if (!this.enableSearching && this.allowBNF)
        {
            throw new ApplicationException("Can't have EnableSearching=false and AllowBNF=true");   // 12Jun15 XN 39882
        }

        // If no site number or id then get from drop down list (or in master mode get master site number)
        if (siteNumber == null && siteID == null)
        {
            if (masterMode)
                siteNumber = Sites.GetMasterSiteNumber(true);
            else
            {
                // Site not passed in so display site drop down list (and try displaying site number from this)
                this.sitesPanel.Visible = true;
                if (!string.IsNullOrEmpty(this.ddlSites.SelectedValue))
                    siteNumber = int.Parse(this.ddlSites.SelectedValue);
            }
        }

        // Initialise the session
        if (siteNumber != null)
            SessionInfo.InitialiseSessionAndSiteNumber(SessionInfo.SessionID, siteNumber.Value);
        else if (siteID != null)
            SessionInfo.InitialiseSessionAndSiteID(SessionInfo.SessionID, siteID.Value);

        // Determine if cost is displayed from desktop parameter (default is show)
        string hideCost = Request.QueryString["HideCost"];
        this.moneyDisplayType = (!string.IsNullOrEmpty(hideCost) && BoolExtensions.PharmacyParse(hideCost)) ? MoneyDisplayType.HideWithLeadingSpace : MoneyDisplayType.Show;

        if (!this.IsPostBack)
        {
            // Set java side handling of OnKeyDown
            this.tbSearch.Text = this.Request["SearchText"];
            this.tbSearch.Attributes["onkeydown"] += "tbSearch_onkeydown(event)";
            this.tbSearch.Attributes["onclick"]   += "$('#tbSearch')[0].select();";

            // Set standard view to begin with 17Oct14 XN  88560
            //PopulateStandardSearchView();
            if (this.enableSearching)
            {
                this.PopulateStandardSearchView();
            }
            else
            {
                this.PopulateDrugLookupView();  // Hide search box 12Jun15 XN 39882
            }

            // Initialise form (empty setup
            if (this.sitesPanel.Visible)
                PopulateSiteList();

            if (this.requestID != 0)
                this.PerformSearch(requestID, Request["SelectNSVCode"]);    // 12Jun15 XN 39882 do search via prescription
            else if (!string.IsNullOrEmpty(this.tbSearch.Text))
                PerformSearch(this.tbSearch.Text, Request["SelectNSVCode"]);
            else if (this.masterMode)
            {
                PopulateSearchResultsMasterMode(new WProduct(), ProductSearchType.Any);
                PopulatePanelMasterMode(new WProduct());
            }
            else
            {
                PopulateSearchResults(new WProduct(), ProductSearchType.Any);
                PopulatePanel(new WProduct());
            }

            divButtons.Visible = !this.embeddedMode;

            // If auto select single item and only 1 item in list then select and close
            // Disabled for other route select as might not be clear to user
            // 12Jun15 XN 39882
            if (this.autoSelectSingleItem && !cbAllRoutes.Checked && gcSearchResults.RowCount == 1)
                ScriptManager.RegisterStartupScript(this, this.GetType(), "autoSelectFirstITem", "btnOK_click();", true);
        }

        string args = Request["__EVENTARGUMENT"];

        // Deal with __postBack events
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' });

        switch (argParams[0])
        {
        case "ToggleBNFDisplay":
            if ( mvOption.ActiveViewIndex == 0 )
                PopulateBNFSearchView();
            else
                PopulateStandardSearchView();
            PopulateSearchResults(new WProduct(), ProductSearchType.Any);
            PopulatePanel(new WProduct());
            break;
        case "SelectedBNF":
            string bnf = argParams[1];
            PerformBNFSearch(bnf);
            break;
        }
    }

    /// <summary>
    /// Show textbox search view.
    /// Reset search results grid size
    /// 17Oct14 XN  88560
    /// </summary>
    private void PopulateStandardSearchView()
    {
        mvOption.ActiveViewIndex = 0;
        var height = Unit.Parse( divStandardSearch.Style[HtmlTextWriterStyle.Height] ).Value;
        divSearchResults.Style[HtmlTextWriterStyle.Height] = (325 - height).ToString() + "px";
    }

    /// <summary>
    /// Show and populate BNF search tree.
    /// Reset search results grid size
    /// 17Oct14 XN  88560
    /// </summary>
    private void PopulateBNFSearchView()
    {
        mvOption.ActiveViewIndex = 1;
        bnfTree.Initalise();
        divSearchResults.Style[HtmlTextWriterStyle.Height] = (325 - pnBnfTree.Height.Value).ToString() + "px";
    }
    
    /// <summary>
    /// Hides both the textbox search view, and BNF search tree
    /// Reset search results grid size
    /// 12Jun15 XN 39882
    /// </summary>
    private void PopulateDrugLookupView()
    {
        mvOption.ActiveViewIndex = -1;
        divSearchResults.Style[HtmlTextWriterStyle.Height] = "325px";
    }

    /// <summary>
    /// Called when the search button is clicked.
    /// Searshed WProduct, and populates the grid, and panel
    /// </summary>
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        PerformSearch(tbSearch.Text, null);
    }    
    
    /// <summary>
    /// Called when all routes check box is clicked
    /// Searches and populates the grid and panel
    /// 12Jun15 XN 39882
    /// </summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The event args</param>
    protected void cbAllRoutes_OnCheckedChanged(object sender, EventArgs e)
    {
        this.PerformSearch(tbSearch.Text, null);
    }
    #endregion

    #region Private Members
    /// <summary>Does the actual product search 19Dec13 XN 78339</summary>
    /// <param name="searchText">Text to search on</param>
    /// <param name="selectNSVCode">NSV Code to select by default</param>
    private void PerformSearch(string searchText, string selectNSVCode)
    {
        ProductSearchType searchType    = ProductSearchType.Any;
        WProduct          searchResults = new WProduct();

        string searchString = searchText.ToUpper().Replace('&', ' ');

        // Test search string is correct length first
        // if (searchString.Length < MinSearchStringLength) XN 18Feb15 prevent user adding two spaces
        if (searchString.Trim().Length < MinSearchStringLength)
            this.gcSearchResults.EmptyGridMessage = "Minimum number of characters is " + MinSearchStringLength.ToString();
        // else if (searchString.Length > MaxSearchStringLength) XN 18Feb15 prevent user adding two spaces
        else if (searchString.Trim().Length > MaxSearchStringLength)
            this.gcSearchResults.EmptyGridMessage = "Maximum number of characters is " + MaxSearchStringLength.ToString();
        else
        {
            // Do search
            searchResults = ProductSearch.DoSearch(searchString, ref searchType, this.masterMode, SessionInfo.SiteID, cbAllRoutes.Checked,  this.productRouteID);

            // filter to CIVAS only items 12Jun15 XN 39882
            if (this.CivasOnly)
            {
                var civasNSVCodes = WFormula.GetNSVCodeBySiteApproved(SessionInfo.SiteID);
                searchResults.RemoveAll(p => !civasNSVCodes.Contains(p.NSVCode));
                searchResults.DeletedItemsTable.AcceptChanges();
            }

            // filter AllowStoresOnly items 08Aug16 KR 159583
            if (!this.allowStoresOnly)
            {
                searchResults.RemoveAll(p => p.IsStoresOnly);
                searchResults.DeletedItemsTable.AcceptChanges();
            }

            // filter to InUse only items 13Jul15 XN 39882
            if (this.inUseOnly)
            {
                searchResults.RemoveAll(p => !p.InUse);
                searchResults.DeletedItemsTable.AcceptChanges();
            }

            // Set empty text message
            if (searchType == ProductSearchType.VmpAmpAmpp)
            {
                this.gcSearchResults.EmptyGridMessage = string.Format("Product {0} not found{1}{2}{3}{4} in site {5}<br /><br />If this Product code exists, it may not be in use<br />or it may not be available in this department", 
                                                                                searchString.TrimStart('¦'), 
                                                                                this.CivasOnly || this.inUseOnly ? " for" : string.Empty, 
                                                                                this.inUseOnly ? " in-use" : string.Empty,
                                                                                this.CivasOnly ? " CIVAS" : string.Empty, 
                                                                                this.CivasOnly || this.inUseOnly ? " items" : string.Empty, 
                                                                                SessionInfo.SiteNumber);
            }
            else
            {
                this.gcSearchResults.EmptyGridMessage = string.Format("No {0} found for '{1}'", this.CivasOnly ? "CIVAS items" : "results", searchString);
            }
        }

        // Populate grid and panel
        if (this.masterMode)
        {
            // Ordering done here so same for grid and panel and items don't get missed when reach limit 05Jul16 XN 157126
            var orderedSearchResults = searchResults.OrderBy(s => s.Tradename)      // 31Mar15 XN 114237 Added support for order by tradename (so generic's appear first in list) 
                                                    .OrderBy(s => s.PrintformV)
                                                    .OrderBy(s => s.mlsPerPack)
                                                    .OrderBy(s => s.ToString())
                                                    .Take(LimitResultsCount).ToList();

            this.PopulateSearchResultsMasterMode(orderedSearchResults, searchType);
            this.PopulatePanelMasterMode(orderedSearchResults);
            //this.PopulateSearchResultsMasterMode(searchResults, searchType); 05Jul16 XN 157126
            //this.PopulatePanelMasterMode(searchResults); 05Jul16 XN 157126
        }
        else
        {
            // Ordering done here so same for grid and panel and items don't get missed when reach limit 05Jul16 XN 157126
            var orderedSearchResults = searchResults.OrderBy(s => s.PrintformV)
                                                    .OrderBy(s => s.mlsPerPack)
                                                    .OrderBy(s => s.ToString())
                                                    .Take(LimitResultsCount).ToList();

            this.PopulateSearchResults(orderedSearchResults, searchType);
            this.PopulatePanel(orderedSearchResults);
            //this.PopulateSearchResults(searchResults, searchType); 05Jul16 XN 157126
            //this.PopulatePanel(searchResults); 05Jul16 XN 157126
        }

        // If limit results then notify user    05Jul16 XN 157126 moved from inside PopulateSearchResults due to changes above
        if (searchResults.Count > LimitResultsCount)    
            this.lbInfo.Text = "Only first" + LimitResultsCount.ToString() + " items will be displayed";

        // Select default drug
        if (!string.IsNullOrEmpty(selectNSVCode))
        {
            int selectedIndex = this.gcSearchResults.FindIndexByAttrbiuteValue("NSVCode", selectNSVCode);
            if (selectedIndex != -1)
                gcSearchResults.SelectRow(selectedIndex);
        }

        // Display all routes option if VmpAmpAmpp search (and off route dispensing is enabled)
        // If no items in list will automatically do an off route search (notifies user)
        // 12Jun15 XN 39882
        cbAllRoutes.Visible = (searchType == ProductSearchType.VmpAmpAmpp) && WConfiguration.Load(SessionInfo.SiteID, "D|PATMED", string.Empty, "EnableOffRouteDispensing", false, false);
        if (cbAllRoutes.Visible && !cbAllRoutes.Checked && gcSearchResults.RowCount == 0 && this.productRouteID != 0)
        {
            cbAllRoutes.Checked = true;
            this.PerformSearch(searchText, selectNSVCode);
            if (gcSearchResults.RowCount > 0)
            {
                string msg = WConfiguration.Load(SessionInfo.SiteID, "D|PATMED", string.Empty, "OnlyOffRouteProductsAvailableWarningText", "No products for this route are available. Displaying off route matches only.", false);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "allRouteFiltering", string.Format("alert('{0}'); $('#gcSearchResults').focus();", msg.JavaStringEscape()), true);
            }
        }
    }

    /// <summary>
    /// Filters list of search results by BNF code
    /// 17Oct14 XN  88560
    /// </summary>
    private void PerformBNFSearch(string bnf)
    {
        ProductSearchType searchType    = ProductSearchType.BNF;
        WProduct          searchResults = new WProduct();

        // Perform search
        if (string.IsNullOrEmpty(bnf) || bnf.Length <= 2)
            gcSearchResults.EmptyGridMessage = "Select a sub chapter";
        else
        {
            searchResults = ProductSearch.DoSearch(bnf, ref searchType, this.masterMode);

            // filter to CIVAS only items 12Jun15 XN 39882
            if (this.CivasOnly)
            {
                var civasNSVCodes = WFormula.GetNSVCodeBySiteApproved(SessionInfo.SiteID);
                searchResults.RemoveAll(p => !civasNSVCodes.Contains(p.NSVCode));
                searchResults.DeletedItemsTable.AcceptChanges();
            }

            // filter to InUse only items 13Jul15 XN 39882
            if (this.inUseOnly)
            {
                searchResults.RemoveAll(p => !p.InUse);
                searchResults.DeletedItemsTable.AcceptChanges();
            }

            gcSearchResults.EmptyGridMessage = string.Format("No results found for{0}{1}{2} BNF chapter '{3}'", 
                                                                    this.inUseOnly ? " in-use" : string.Empty,
                                                                    this.CivasOnly ? " CIVAS"  : string.Empty, 
                                                                    this.CivasOnly || this.inUseOnly ? " items under" : string.Empty, 
                                                                    bnf);
        }

        // Populate grid and panel
        if (this.masterMode)
        {
            // Ordering done here so same for grid and panel and items don't get missed when reach limit 05Jul16 XN 157126
            var orderedSearchResults = searchResults.OrderBy(s => s.Tradename)      // 31Mar15 XN 114237 Added support for order by tradename (so generic's appear first in list) 
                                                    .OrderBy(s => s.PrintformV)
                                                    .OrderBy(s => s.mlsPerPack)
                                                    .OrderBy(s => s.ToString())
                                                    .Take(LimitResultsCount).ToList();

            this.PopulateSearchResultsMasterMode(orderedSearchResults, searchType);
            this.PopulatePanelMasterMode(orderedSearchResults);
            //this.PopulateSearchResultsMasterMode(searchResults, searchType);  05Jul16 XN 157126
            //this.PopulatePanelMasterMode(searchResults);                      05Jul16 XN 157126
        }
        else
        {
            // Ordering done here so same for grid and panel and items don't get missed when reach limit 05Jul16 XN 157126
            var orderedSearchResults = searchResults.OrderBy(s => s.PrintformV)
                                                    .OrderBy(s => s.mlsPerPack)
                                                    .OrderBy(s => s.ToString())
                                                    .Take(LimitResultsCount).ToList();

            this.PopulateSearchResults(orderedSearchResults, searchType);
            this.PopulatePanel(orderedSearchResults);
            //this.PopulateSearchResults(searchResults, searchType);    05Jul16 XN 157126
            //this.PopulatePanel(searchResults);                        05Jul16 XN 157126
        }

        // If limit results then notify user    05Jul16 XN 157126 moved from inside PopulateSearchResults due to changes above
        if (searchResults.Count > LimitResultsCount)    
            this.lbInfo.Text = "Only first" + LimitResultsCount.ToString() + " items will be displayed";

        gcSearchResults.SelectRow(0);
    }

    /// <summary>
    /// Perform search from a prescription
    /// Will gets the prescriptions product Id (if infusion then from primary ingredient) and product route Id
    /// Will the force the form to so a VmpOrAmp search
    /// </summary>
    /// <param name="requestID">Prescription ID</param>
    /// <param name="selectNSVCode">NSVCode to select by default</param>
    private void PerformSearch(int requestID, string selectNSVCode)
    {
        PrescriptionRow prescription = Prescription.GetByRequestID(requestID);
        if (prescription == null)
        {
            this.gcSearchResults.EmptyGridMessage = "Not a standard, doseless, or infusion, prescription type";
        }
        else
        {
            // Force an VmpOrAmp search (prefix with ¦)
            this.productRouteID = prescription.ProductRouteID;
            this.PerformSearch("¦" + prescription.ProductID, selectNSVCode);
        }
    }

    /// <summary>Populates the sites drop down list</summary>
    private void PopulateSiteList()
    {
        SiteProcessor siteProcessor = new SiteProcessor();
        IEnumerable<Site> sites = siteProcessor.LoadAll(true);

        ddlSites.Items.Clear();
        foreach (Site site in sites)
            ddlSites.Items.Add(new ListItem(site.ToString(), site.Number.ToString()));
    }

    /// <summary>Populates grid with search results (normal mode)</summary>
    /// <param name="searchResults">Search results to display</param>
    /// <param name="searchType">Search type that was performed</param>
    private void PopulateSearchResults(IEnumerable<WProductRow> searchResults, ProductSearchType searchType)
    {
        // Load robot location, and screen char
        IDictionary<string,string> robotLocationToScreenCharMap = new Dictionary<string,string>();
        if (this.siteNumber.HasValue)
            RobotSetting.GetSettings().ToDictionary(r => r.LocationCode, r => r.FindItemScreenChar);

        // Setup the orders table columns
        this.gcSearchResults.AddColumn("Description", robotLocationToScreenCharMap.Any() ? 58 : 62);
        this.gcSearchResults.AddColumn("Stock", 9, PharmacyGridControl.ColumnType.Text,    PharmacyGridControl.AlignmentType.Center);
        this.gcSearchResults.AddColumn("Pack", 10, PharmacyGridControl.ColumnType.Number,   PharmacyGridControl.AlignmentType.Right );
        this.gcSearchResults.AddColumn("Cost", 10, PharmacyGridControl.ColumnType.Money,    PharmacyGridControl.AlignmentType.Right );
        this.gcSearchResults.AddColumn("Unit",  9, PharmacyGridControl.ColumnType.Text,     PharmacyGridControl.AlignmentType.Right );
        if (robotLocationToScreenCharMap.Any())
            this.gcSearchResults.AddColumn(string.Empty, 4, PharmacyGridControl.ColumnType.Text, PharmacyGridControl.AlignmentType.Center);
        this.gcSearchResults.ColumnXMLEscaped    (1, false);
        this.gcSearchResults.ColumnKeepWhiteSpace(4, true );

        this.gcSearchResults.SortableColumns = true;
        this.gcSearchResults.EnableAlternateRowShading = true;

        string namePrfix = (searchType == ProductSearchType.Tradename) ? "~" : string.Empty;

        //var orderedSearchResults = searchResults.OrderBy(s => s.PrintformV)   05Jul16 XN 157126
        //                                        .OrderBy(s => s.mlsPerPack)
        //                                        .OrderBy(s => s.ToString())
        //                                        .Take(LimitResultsCount);

        // Add each row from search results
        //foreach (WProductRow row in orderedSearchResults) 05Jul16 XN 157126
        foreach (WProductRow row in searchResults)
        {
            this.gcSearchResults.AddRow();
            this.gcSearchResults.AddRowAttribute("SiteProductDataID", row.SiteProductDataID.ToString());
            this.gcSearchResults.AddRowAttribute("NSVCode",           row.NSVCode);
            this.gcSearchResults.SetCell(0, namePrfix + row.ToString());

            // Stock level
            string stock = string.Empty;
            if (row.StockLevelInIssueUnits < decimal.Zero)
                stock = "<span style='color:red;font-style:italic;'>NEG</span>";
            else if (row.StockLevelInIssueUnits == decimal.Zero)
                stock = "<span style='color:red;font-style:italic;'>OUT</span>";
            this.gcSearchResults.SetCell(1, stock);

            this.gcSearchResults.SetCell(2, row.mlsPerPack.ToString("0.###"));
            this.gcSearchResults.SetCell(3, (row.AverageCostExVatPerPack / row.ConversionFactorPackToIssueUnits).ToMoneyString(moneyDisplayType));
            this.gcSearchResults.SetCell(4, " " + row.PrintformV);
            
            // If robot item add indicator
            if (robotLocationToScreenCharMap.ContainsKey(row.Location))
                this.gcSearchResults.SetCell(5, robotLocationToScreenCharMap[row.Location]);
        }

        //// If limit results then notify user
        //if (searchResults.Count() > LimitResultsCount)    05Jul16 XN 157126
        //    this.lbInfo.Text = "Only first" + LimitResultsCount.ToString() + " items will be displayed";
    }

    /// <summary>Populates grid with with search resutls (master mode)</summary>
    /// <param name="searchResults">Search results to display (needs to be displayed in search order)</param>
    /// <param name="searchType">Search type that was performed</param>
    private void PopulateSearchResultsMasterMode(IEnumerable<WProductRow> searchResults, ProductSearchType searchType)
    {
        // Setup the orders table columns
        this.gcSearchResults.AddColumn("Description", 81);
        this.gcSearchResults.AddColumn("Pack", 10, PharmacyGridControl.ColumnType.Number,   PharmacyGridControl.AlignmentType.Right );
        this.gcSearchResults.AddColumn("Unit",  9, PharmacyGridControl.ColumnType.Text,     PharmacyGridControl.AlignmentType.Right );
        this.gcSearchResults.ColumnKeepWhiteSpace(2, true );

        this.gcSearchResults.SortableColumns = true;
        this.gcSearchResults.EnableAlternateRowShading = true;

        string namePrfix = (searchType == ProductSearchType.Tradename) ? "~" : string.Empty;

        //var orderedSearchResults = searchResults.OrderBy(s => s.Tradename)      05Jul16 XN 157126 // 31Mar15 XN 114237 Added support for order by tradename (so generic's appear first in list) 
        //                                        .OrderBy(s => s.PrintformV)
        //                                        .OrderBy(s => s.mlsPerPack)
        //                                        .OrderBy(s => s.ToString())
        //                                        .Take(LimitResultsCount);

        // Add each row from search results
        //foreach (WProductRow row in orderedSearchResults) 05Jul16 XN 157126
        foreach (WProductRow row in searchResults)
        {
            this.gcSearchResults.AddRow();
            this.gcSearchResults.AddRowAttribute("SiteProductDataID", row.SiteProductDataID.ToString());
            this.gcSearchResults.SetCell(0, namePrfix + row.ToString());

            this.gcSearchResults.SetCell(1, row.mlsPerPack.ToString("0.###"));
            this.gcSearchResults.SetCell(2, " " + row.PrintformV);
        }

        //// If limit results then notify user
        //if (searchResults.Count() > LimitResultsCount)    05Jul16 XN 157126
        //    this.lbInfo.Text = "Only first" + LimitResultsCount.ToString() + " items will be displayed";
    }

    /// <summary>
    /// Populates panel at bottom of screen  (normal mode)
    /// Only really setup labels in panel an builds up the xml island that contains the data to display in the panel for each row in the table.
    /// Java side methods will then populate the panel when a row is selected in the grid
    /// See file header for xml island layout.
    /// </summary>
    /// <param name="searchResults">Search results to display</param>
    private void PopulatePanel(IEnumerable<WProductRow> searchResults)
    {
        this.lpcProductDetail.SetColumns(4);

        // Column 1
        this.lpcProductDetail.SetColumnWidth(0, 19);
        this.lpcProductDetail.AddNamedLabel(0, "NSVCode", "NSV Code:", string.Empty);
        this.lpcProductDetail.AddNamedLabel(0, "Code", "Code:", string.Empty);
        this.lpcProductDetail.AddNamedLabel(0, "Local", "Local:", string.Empty);
        if (searchResults.Any(r => r.LocalProductCode.Length > 10))
            this.lpcProductDetail.SetValueStyles(0, this.lpcProductDetail.GetLabelCount(0) - 1, "font-size:x-small; white-space: nowrap;");
        else
            this.lpcProductDetail.SetValueStyles(0, this.lpcProductDetail.GetLabelCount(0) - 1, "font-size:small; white-space: nowrap;");

        // Column 2
        this.lpcProductDetail.SetColumnWidth(1, 16);
        this.lpcProductDetail.AddNamedLabel(1, "Live", "Live:", string.Empty);
        this.lpcProductDetail.AddNamedLabel(1, "Stocked", "Stocked:", string.Empty);
        this.lpcProductDetail.AddNamedLabel(1, "InUse", "In Use:", string.Empty);
        this.lpcProductDetail.AddNamedLabel(1, "StoresOnly", "Stores Only:", string.Empty);

        // Column 3
        this.lpcProductDetail.SetColumnWidth(2, 20);
        this.lpcProductDetail.AddNamedLabel(2, "Formulary", "Formulary:", string.Empty);
        this.lpcProductDetail.AddNamedLabel(2, "Locations", "Locations:", string.Empty);

        // Column 4
        this.lpcProductDetail.SetColumnWidth(3, 45);
        this.lpcProductDetail.AddNamedLabel(3, "StockLevel", "Stock Level:", string.Empty);
        this.lpcProductDetail.AddNamedLabel(3, "Cost", "Cost:", string.Empty);
        this.lpcProductDetail.AddNamedLabel(3, "Tradename", "Tradename:", string.Empty);
        this.lpcProductDetail.SetValueStyles(3, this.lpcProductDetail.GetLabelCount(3) - 1, "font-size:small; white-space: nowrap;");
        this.lpcProductDetail.AddNamedLabel(3, "Message", "Message:", string.Empty);
        this.lpcProductDetail.SetValueStyles(3, this.lpcProductDetail.GetLabelCount(3) - 1, "font-size:small; white-space: nowrap;");

        // Build up the xml island
        XmlWriterSettings xmlSettings = new XmlWriterSettings();
        xmlSettings.OmitXmlDeclaration = true;

        productDetails.Length  = 0; // 13May16 XN 39882
        using (XmlWriter xmlProductDetails = XmlWriter.Create(productDetails, xmlSettings))
        {
            xmlProductDetails.WriteStartElement("Product");
            foreach (WProductRow row in searchResults.Take(LimitResultsCount))
            {
                xmlProductDetails.WriteStartElement("Row");
                xmlProductDetails.WriteAttributeString("SiteProductDataID", row.SiteProductDataID.ToString());

                // Column 1
                xmlProductDetails.WriteElementString("NSVCode", row.NSVCode);
                xmlProductDetails.WriteElementString("Code", row.Code);
                xmlProductDetails.WriteElementString("Local", row.LocalProductCode);

                // Column 2
                xmlProductDetails.WriteElementString("Live", row.IfLiveStockControl.ToYesNoString());
                xmlProductDetails.WriteElementString("Stocked", row.IsStocked.ToYesNoString());
                xmlProductDetails.WriteElementString("InUse", row.InUse.ToYesNoString());
                xmlProductDetails.WriteElementString("StoresOnly", row.IsStoresOnly.ToYesNoString());

                // Column 3
                // 11Jan13 XN 38049 If setting is on then only display the formulary code directly from the DB
//              xmlProductDetails.WriteElementString("Formulary", row.Formulary.ToString());                
                bool displayFormularyAsLetterOnly = WConfiguration.Load<bool>(SessionInfo.SiteID, "D|WINORD", "ItemEnquiry", "DisplayFormularyAsLetterOnly", false, false);
                string formularyLabel = displayFormularyAsLetterOnly ? row.FormularyCode : row.FormularyType.ToString();
                if (row.FormularyType != FormularyType.Yes)
                    formularyLabel = "<span style='color:red;font-style:italic;'>" + formularyLabel + "</span>";
                xmlProductDetails.WriteStartElement("Formulary");
                xmlProductDetails.WriteAttributeString("isHTML", "1");
                xmlProductDetails.WriteElementString("Formulary", formularyLabel);
                xmlProductDetails.WriteEndElement();

                string locations = row.Location;
                if (!string.IsNullOrEmpty(row.Location2))
                    locations += ", " + row.Location2;
                xmlProductDetails.WriteElementString("Locations", locations);

                // Column 4
                string storesPack = string.IsNullOrEmpty(row.StoresPack) ? "pack" : row.StoresPack.ToLower();
                string stockLevel = string.Format("{0:0.##} {1} (or {2:0.##} {3})", row.StockLevelInIssueUnits, row.PrintformV, row.StockLevelInIssueUnits / row.ConversionFactorPackToIssueUnits, storesPack);
                xmlProductDetails.WriteElementString("StockLevel", stockLevel);
                xmlProductDetails.WriteElementString("Cost", string.Format("{0} for 1 x {1} {2}", row.AverageCostExVatPerPack.ToMoneyString(moneyDisplayType), row.ConversionFactorPackToIssueUnits, row.PrintformV));
                //xmlProductDetails.WriteElementString("Tradename", row.Tradename);  28Oct14 XN 00212 
                xmlProductDetails.WriteElementString("Tradename", row.GetTradename());
                xmlProductDetails.WriteElementString("Message", row.Notes);

                xmlProductDetails.WriteEndElement();
            }
            xmlProductDetails.WriteEndElement();
        }
    } 

    /// <summary>
    /// Populates panel at bottom of screen (master mode)
    /// Only really setup labels in panel an builds up the xml island that contains the data to display in the panel for each row in the table.
    /// Java side methods will then populate the panel when a row is selected in the grid
    /// See file header for xml island layout.
    /// </summary>
    /// <param name="searchResults">Search results to display</param>
    private void PopulatePanelMasterMode(IEnumerable<WProductRow> searchResults)
    {
        this.lpcProductDetail.SetColumns(1);

        // Column 1
        this.lpcProductDetail.SetColumnWidth(0, 95);
        this.lpcProductDetail.AddNamedLabel(0, "NSVCode", "NSV Code:", string.Empty);
        this.lpcProductDetail.AddNamedLabel(0, "Code", "Code:", string.Empty);
        this.lpcProductDetail.AddNamedLabel(0, "StoresOnly", "Stores Only:", string.Empty);
        this.lpcProductDetail.AddNamedLabel(0, "Tradename", "Tradename:", string.Empty);
        this.lpcProductDetail.SetValueStyles(0, this.lpcProductDetail.GetLabelCount(0) - 1, "white-space: nowrap;");

        // Build up the xml island
        XmlWriterSettings xmlSettings = new XmlWriterSettings();
        xmlSettings.OmitXmlDeclaration = true;

        using (XmlWriter xmlProductDetails = XmlWriter.Create(productDetails, xmlSettings))
        {
            xmlProductDetails.WriteStartElement("Product");
            foreach (WProductRow row in searchResults.Take(LimitResultsCount))
            {
                xmlProductDetails.WriteStartElement("Row");
                xmlProductDetails.WriteAttributeString("SiteProductDataID", row.SiteProductDataID.ToString());

                // Column 1
                xmlProductDetails.WriteElementString("NSVCode", row.NSVCode);
                xmlProductDetails.WriteElementString("Code", row.Code);
                xmlProductDetails.WriteElementString("StoresOnly", row.IsStoresOnly.ToYesNoString());
                xmlProductDetails.WriteElementString("Tradename", row.Tradename);

                xmlProductDetails.WriteEndElement();
            }
            xmlProductDetails.WriteEndElement();
        }
    } 
    #endregion
}
