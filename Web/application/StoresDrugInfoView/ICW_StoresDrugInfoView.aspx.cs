//===========================================================================
//
//						ICW_StoresDrugInfoView.aspx.cs
//
//  Container window for the vairous frames of the pharmacy stores drug F4 
//  screen info view. Displays Ordering, Requisition, Supplier, Summary and
//  Ward, information for a sites drug.
//
//  The tabs display the following information
//  Ordering            - Ordering.aspx           - Displays pending and received orders. 
//  Requisitions        - Requisitions.aspx       - Displays due out, and issues orders.
//  Summary Information - SummaryInformation.aspx - Displays order, received, issued qty grouped by months 
//  Supplier Information- SupplierInformation.aspx- Displays product stock information, and list of suppliers
//  Ward Stock          - WardStock.aspx          - Displays ward stock levels
//  Contract Updates    - ContractUpdates.aspx    - Displays upcoming\expired contracts
//
//  Along the bottom of the page is a product info panel (ProductInfoPanel.aspx)
//  that displays general information about the product
//
//  Call the page with the follow parameters
//  SessionID               - ICW session ID
//  AscribeSiteNumber       - Pharmacy site
//  SiteID                  -
//  HideCost                - Yes\No option if user is to see prices\costs details
//  NSVCode                 - NSV code of pharmacy product to display.
//  Robot                   - Name of robot if item is robot item (optional)
//  
//  Usage:
//  ICW_StoresDrugInfoView.aspx?SessionID=123&AscribeSiteNumber=504&HideCost=Yes&NSVCode=AAA0001
//
//	Modification History:
//	23Jul09 XN  Written
//  29Apr10 XN  Replace old buisness layer classes with data layer classes
//  08Jul11 XN  F0122458 Added error messge it can't find product
//  15Jul11 XN  F0118239 Add robot stock level to F4 screen
//  01Jul15 XN  Added support for SiteID 39882
//  15Jul16 XN  Added contract tab 126634
//===========================================================================
using System;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.shared;
using Ascribe.Common;
using ascribe.pharmacy.pharmacydatalayer;
using System.Web.UI.WebControls;

public partial class application_StoresDrugInfoView_ICW_StoresDrugInfoView : System.Web.UI.Page
{
    /// <summary>Enum to represent the tabs on the form</summary>
    protected enum TabPageType
    {
        Ordering,
        Requisitions,
        SupplierInformation,
        SummaryInformation,
        WardStock,
        Contracts,
    };

    protected WProductRow      product          = null;                     // Product being displayed
    protected MoneyDisplayType moneyDisplayType = MoneyDisplayType.Show;    // If money is displayed

    protected int    sessionID;                // Session ID
    protected int    siteNumber;               // site number
    protected string NSVCode;                  // product NSV code
    protected string robotName;                // name of robot that item is in

    /// <summary>Property to get set selected tab (cahced to view)</summary>
    protected TabPageType SelectedTab
    {
        get { return (TabPageType)(ViewState["SelectedTab"] ?? TabPageType.Ordering); }
        set 
        { 
            ViewState["SelectedTab"] = value;             
            UpdatedTabButtons();
        }
    }

    /// <summary>
    /// Set the page header, and if required increments the selected tab
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);  // Use new InitialiseSessionAndSite to handle SiteID  01Jul15 XN 39882
        sessionID  = SessionInfo.SessionID;
        siteNumber = SessionInfo.SiteNumber;

        // Load in the query string parameters
        NSVCode = Request.QueryString["NSVCode"] ?? string.Empty;

        // Determine if cost is displayed from desktop parameter (default is show)
        string hideCost = Request.QueryString["HideCost"];
        if ( !string.IsNullOrEmpty(hideCost) && BoolExtensions.PharmacyParse(hideCost) ) 
            moneyDisplayType = MoneyDisplayType.HideWithLeadingSpace;
        else
            moneyDisplayType = MoneyDisplayType.Show; 
  
        // Load robot item enquiry issues
        robotName = Request.QueryString["Robot"] ?? string.Empty;

        if ( !IsPostBack )
        {
            // Load site info
            SiteProcessor siteProcessor = new SiteProcessor();
            Site site = siteProcessor.LoadBySiteID(SessionInfo.SiteID);

            // Load product information
            WProduct processor = new WProduct();
            processor.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID);
            product = processor.FirstOrDefault();
            if (product != null)
            {
                // Display product description
                lblProductDescription.Text = Generic.XMLEscape(product.ToString());

                // Display site description
                string name = string.IsNullOrEmpty(site.FullName) ? site.AbbreviatedName : site.FullName;
                string siteDescription = string.Format("Site ({0} {1}) - {2}", name, site.AccountName, site.Number);
                lblSiteDescription.Text = Generic.XMLEscape(siteDescription);
            }
            else
            {
                string msg = string.Format("Product \\'{0}\\' not fully supported by site {1}.", NSVCode, siteNumber);
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "ProductNotValid", "alert('" + msg + "');window.close();", true); // Close the current window            	
            }
        }

        // If requested increments to the next selected tab
        // when the esc button is pressed on the form
        string eventTarget = Request["__EVENTARGUMENT"];
        if (!string.IsNullOrEmpty(eventTarget))
        {
            switch (eventTarget.ToLower())
            {
            case "incrementtab": IncrementSelectedTab(); break;
            }
        }
    }

    /// <summary>
    /// Called when the Ordering tab is selected to display ordering page
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnOrdering_Click(object sender, EventArgs e)
    {
        SelectedTab = TabPageType.Ordering;        
    }

    /// <summary>
    /// Called when the Requisition tab is selected to display requisition page
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnRequisitions_Click(object sender, EventArgs e)
    {
        SelectedTab = TabPageType.Requisitions;
    }

    /// <summary>
    /// Called when the Supplier Information tab is selected to display Supplier Information page
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSupplierInformation_Click(object sender, EventArgs e)
    {
        SelectedTab = TabPageType.SupplierInformation;
    }

    /// <summary>
    /// Called when the Summary tab is selected to display Summary page
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSummaryInformation_Click(object sender, EventArgs e)
    {
        SelectedTab = TabPageType.SummaryInformation;
    }

    /// <summary>
    /// Called when the Ward Stock tab is selected to display Ward Stock page
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnWardStock_Click(object sender, EventArgs e)
    {
        SelectedTab = TabPageType.WardStock;
    }

    /// <summary>Called when the Contract tab is selected to display Contract page</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void btnContracts_Click(object sender, EventArgs e)
    {
        SelectedTab = TabPageType.Contracts;
    }

    /// <summary>
    /// Get the name of the page to display for the currently selected tab
    /// </summary>
    /// <returns>Web page name</returns>
    protected string GetSelectedTabURL()
    {
        switch (SelectedTab)
        {
        case TabPageType.Ordering:            return "Ordering.aspx";            
        case TabPageType.Requisitions:        return "Requisitions.aspx";        
        case TabPageType.SupplierInformation: return "SupplierInformation.aspx"; 
        case TabPageType.SummaryInformation:  return "SummaryInformation.aspx";  
        case TabPageType.WardStock:           return "WardStock.aspx"; 
        case TabPageType.Contracts:           return "Contracts.aspx";
        default: return string.Empty;
        }
    }

    /// <summary>Increments the tab, looping back to start if currently on the last tab</summary>
    protected void IncrementSelectedTab()
    {
        int index = ((int)SelectedTab) + 1;

        if (index >= Enum.GetValues(typeof(TabPageType)).Length)
            index = 0;

        SelectedTab = (TabPageType)index;
    }

    /// <summary>Updates the selected state of the tab buttons.</summary>
    protected void UpdatedTabButtons()
    {
        // Clear all existing tab button states
        upSelectedTab.GetAllControlsByType<Button>().ForEach(c => c.CssClass = "Tab");

        // Set selected tab button state
        switch (SelectedTab)
        {
        case TabPageType.Ordering           : btnOrdering.CssClass            = "TabSelected"; break;
        case TabPageType.Requisitions       : btnRequisitions.CssClass        = "TabSelected"; break;
        case TabPageType.SupplierInformation: btnSupplierInformation.CssClass = "TabSelected"; break;
        case TabPageType.SummaryInformation : btnSummaryInformation.CssClass  = "TabSelected"; break;
        case TabPageType.WardStock          : btnWardStock.CssClass           = "TabSelected"; break;
        case TabPageType.Contracts          : btnContracts.CssClass           = "TabSelected"; break;
        }
    }
}
