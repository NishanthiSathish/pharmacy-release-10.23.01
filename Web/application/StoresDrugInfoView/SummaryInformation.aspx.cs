//===========================================================================
//
//						        SummaryInformation.aspx.cs
//
//  Displays historical ordering information grouped by month this includes 
//  items ordered, issued, and received.
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Pharmacy site
//  HideCost            - 1 to hide prices\costs, else 0
//  NSVCode             - NSV code of pharmacy product to display.
//  
//  Usage:
//  SummaryInformation.aspx?SessionID=123&AscribeSiteNumber=504&HideCost=1&NSVCode=AAA0001
//
//	Modification History:
//	23Jul09 XN  Written
//  29Apr10 XN  Replace old buisness layer classes with data layer classes
//  11Jan13 XN  Changed StoresDrugInfoViewSetting.Settings.Instance with StoresDrugInfoViewSettingSetting
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_StoresDrugInfoView_SummaryInformation : System.Web.UI.Page
{
    protected string            NSVCode          = string.Empty;            // NSV code for product to display
    protected MoneyDisplayType  moneyDisplayType = MoneyDisplayType.Show;   // If prices\cost values are to be displayed

    WProductRow product = null;   // Product to display

    protected void Page_Load(object sender, EventArgs e)
    {
        // Initalise the Session
        int sessionID = int.Parse(Request.QueryString["SessionID"]);
        int siteID    = int.Parse(Request.QueryString["SiteID"]);
        SessionInfo.InitialiseSessionAndSiteID ( sessionID, siteID );

        // Load in the query string parameters
        NSVCode          = Request.QueryString["NSVCode"];
        moneyDisplayType = BoolExtensions.PharmacyParse(Request.QueryString["HideCost"]) ? MoneyDisplayType.HideWithLeadingSpace : MoneyDisplayType.Show;

        if (!IsPostBack)
        {
            // Load the product information
            WProduct productProcessor = new WProduct();
            productProcessor.LoadByProductAndSiteID(NSVCode, siteID);
            product = productProcessor.FirstOrDefault();

            LoadSummaryInformation();
        }
    }

    /// <summary>
    /// Display the summary information about the orders grouped by month
    /// for last LimitToDisplaySummaryInformation months (from settings)
    /// 
    /// Quantity Ordered  - Read from WOrderlog.QtyOrd date compared to WOrderlog.DateOrd
    /// Quantity Received - Read from WOrderlog.QtyRec date compared to WOrderlog.DateRec
    /// Quantity Issued   - Read from WTranslog.Qty    date compared to WTranslog.Date
    /// </summary>
    protected void LoadSummaryInformation()
    {
        // Set label text
        lblOrderingIssuing.Text = string.Format(lblOrderingIssuing.Text, StoresDrugInfoViewSetting.LimitToDisplaySummaryInformation);

        // Text to display if grid is empty
        orderingIssuingGrid.EmptyGridMessage = "Product has not been ordered or issued.";

        string qtyUnits = (product == null) || string.IsNullOrEmpty(product.StoresPack) ? "pack" : product.StoresPack.ToLower();

        // Set column headers
        orderingIssuingGrid.AddColumn("Year & Month", 25, application_StoresDrugInfoView_controls_GridControl.AlignmentType.Center);
        orderingIssuingGrid.AddColumn(string.Format("Quantity Ordered ({0})",  qtyUnits), 25, application_StoresDrugInfoView_controls_GridControl.AlignmentType.Right);
        orderingIssuingGrid.AddColumn(string.Format("Quantity Received ({0})", qtyUnits), 25, application_StoresDrugInfoView_controls_GridControl.AlignmentType.Right);
        orderingIssuingGrid.AddColumn(string.Format("Quantity Issued ({0})",   qtyUnits), 25, application_StoresDrugInfoView_controls_GridControl.AlignmentType.Right);

        // Get list of elements and order in descending order.
        HistoricalInfoProcessor orderlogProcessor = new HistoricalInfoProcessor();
        List<MonthlyTotals> monthlyTotalsList = orderlogProcessor.LoadMonthlyTotalsBySiteIDNSVCodeAndFrom(SessionInfo.SiteID, NSVCode, StoresDrugInfoViewSetting.LimitToDisplaySummaryInformationFromDate );
        monthlyTotalsList.Reverse();

        // Add each row to the table
        foreach(MonthlyTotals monthlyTotal in monthlyTotalsList)
        {
            orderingIssuingGrid.AddRow ();

            orderingIssuingGrid.SetCell ( 0, monthlyTotal.monthYear.ToString ( "MMM-yyyy" ) ); 
            orderingIssuingGrid.SetCell ( 1, monthlyTotal.quantityOrderedInPacks.ToString (MonthlyTotalsObjectInfo.QuantityOrderedInPacksLength)  ); 
            orderingIssuingGrid.SetCell ( 2, monthlyTotal.quantityReceivedInPacks.ToString(MonthlyTotalsObjectInfo.QuantityReceivedInPacksLength) ); 
            orderingIssuingGrid.SetCell ( 3, monthlyTotal.quantityIssuedInPacks.ToString  ("0.#") ); 
        }
    }
}
