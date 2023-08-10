//===========================================================================
//
//							   ICW_RobotLoading.cs
//
//  Container window for the vairous frames of the pharmacy stores robot loading
//  screen. Displays avaialbe orders, and loadings, information for a sites drug.
//
//  The tabs display the following information
//  Available Orders - Orders.aspx 
//  Loading          - Loadings.aspx
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Pharmacy site
//  HideCost            - If cost values are to be displayed of keep hidden
//  RobotLocation       - Location of the robot if displaying the Robot column.
//  IsInModal           - (optional) if displayed in modal dialog
//  
//  Usage:
//  ICW_RobotLoading.aspx?SessionID=123&AscribeSiteNumber=504&RobotLocation=A6&HideCost=No
//
//	Modification History:
//	16Dec09 XN  Written
//===========================================================================
using System;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.businesslayer;
using Ascribe.Common;

public partial class application_RobotLoading_ICW_RobotLoading : System.Web.UI.Page
{
    /// <summary>Enum to represent the tabs on the form</summary>
    protected enum TabPageType
    {
        Orders,
        Loadings,
    };

    protected int    sessionID;     // Session ID
    protected int    siteNumber;    // site number
    protected string robotLocation; // robot location
    protected MoneyDisplayType moneyDisplayType = MoneyDisplayType.Show;    // If money is displayed
    protected bool   isInModal;     // If displayed as modal dialog

    /// <summary>Property to get set selected tab (cahced to view)</summary>
    protected TabPageType SelectedTab
    {
        get { return (TabPageType)(ViewState["SelectedTab"] ?? TabPageType.Orders); }
        set 
        { 
            ViewState["SelectedTab"] = value;             
            UpdatedTabButtons();
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Initalise the Session
        sessionID  = int.Parse(Request.QueryString["SessionID"]);
        siteNumber = int.Parse(Request.QueryString["AscribeSiteNumber"]);

        SessionInfo.InitialiseSessionAndSiteNumber ( sessionID, siteNumber );

        // Load in the robot location
        robotLocation = Request.QueryString["RobotLocation"] ?? string.Empty;

        // Determine if cost is displayed from desktop parameter (default is show)
        string hideCost = Request.QueryString["HideCost"];
        if ( !string.IsNullOrEmpty(hideCost) && BoolExtensions.PharmacyParse(hideCost) ) 
            moneyDisplayType = MoneyDisplayType.HideWithLeadingSpace;
        else
            moneyDisplayType = MoneyDisplayType.Show;

        // Determine if this is a modal form (used to display hide close button)
        string isInModalStr = Request.QueryString["IsInModal"];
        if (string.IsNullOrEmpty(isInModalStr))
            isInModal = (Page.Parent == null);
        else
            isInModal = BoolExtensions.PharmacyParse(isInModalStr);

        if (!IsPostBack)
        {
            // Set the infromation displayed at the top of the form
            lblInfo.Text = Generic.XMLEscape(string.Format(lblInfo.Text, siteNumber, robotLocation));
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
    /// Called when the Orders tab is selected to display orders page
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnOrders_Click(object sender, EventArgs e)
    {
        SelectedTab = TabPageType.Orders;        
    }

    /// <summary>
    /// Called when the Loadings tab is selected to display loading page
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnLoadings_Click(object sender, EventArgs e)
    {
        SelectedTab = TabPageType.Loadings;
    }

    /// <summary>
    /// Get the name of the page to display for the currently selected tab
    /// </summary>
    /// <returns>Web page name</returns>
    protected string GetSelectedTabURL()
    {
        switch (SelectedTab)
        {
        case TabPageType.Orders:    return "Orders.aspx";            
        case TabPageType.Loadings:  return "Loadings.aspx";        
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
        btnOrders.CssClass   = "Tab";
        btnLoadings.CssClass = "Tab";

        // Set selected tab button state
        switch (SelectedTab)
        {
        case TabPageType.Orders     : btnOrders.CssClass   = "TabSelected"; break;
        case TabPageType.Loadings   : btnLoadings.CssClass = "TabSelected"; break;
        }
    }
}
