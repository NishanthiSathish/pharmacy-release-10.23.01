//===========================================================================
//
//						           Requisitions.aspx.cs
//
//  Displays information about due out, and issued orders for a site's drug.
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Pharmacy site
//  HideCost            - 1 to hide prices\costs, else 0
//  NSVCode             - NSV code of pharmacy product to display.
//  
//  Usage:
//  Requisitions.aspx?SessionID=123&AscribeSiteNumber=504&HideCost=1&NSVCode=AAA0001
//
//	Modification History:
//	23Jul09 XN  Written
//  29Apr10 XN  Replace old buisness layer classes with data layer classes
//  11Jan13 XN  Changed StoresDrugInfoViewSetting.Settings.Instance with StoresDrugInfoViewSettingSetting
//===========================================================================
using System;
using System.Linq;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_StoresDrugInfoView_Requisitions : System.Web.UI.Page
{
    protected string            NSVCode          = string.Empty;            // NSV code for product to display
    protected MoneyDisplayType  moneyDisplayType = MoneyDisplayType.Show;   // If prices\cost values are to be displayed

    protected WProductRow product = null;   // Product to display

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

            // fill the due out grid
            LoadDueOut();

            // fill the issued grid
            LoadIssued();
        }
    }

    /// <summary>
    /// Display the due out orders in a grid.
    /// These orders come from the WRequis table, and the list is limited to only display 
    /// due out orders (type 5 or 6) for the last LimitToDisplayRequisitionsDueOut days (from settings),
    /// By default the list is sorted by the WRequisSort configuration setting.
    /// </summary>
    private void LoadDueOut()
    {
        // Text to display if grid is empty
        dueOutGrid.EmptyGridMessage = "None owed to other sites.";

        // Load requisition data
        WRequis processor = new WRequis();
        processor.LoadBySiteIDNSVCodeAndFromDate(SessionInfo.SiteID, NSVCode, StoresDrugInfoViewSetting.LimitToDisplayRequisitionsDueOutFromDate);
        processor.Sort(StoresDrugInfoViewSetting.RequisitionSort);

        // Set grid title
        lblDueOut.Text = "Due out";
        if (StoresDrugInfoViewSetting.HasLimitToDisplayRequisitionsDueOut)
            lblDueOut.Text = lblDueOut.Text + string.Format(" (for last {0} days)", StoresDrugInfoViewSetting.LimitToDisplayRequisitionsDueOutInDays);

        // determine quantity units
        string qtyUnitsForHeader = ((product == null) || string.IsNullOrEmpty(product.PrintformV)) ? string.Empty : "(" + product.PrintformV + ")";

        // Add column headers
        dueOutGrid.AddColumn("Rec Num",      15);
        dueOutGrid.AddColumn("Order Date",   15);
        dueOutGrid.AddColumn("Date Rec",     15);
        dueOutGrid.AddColumn(string.Format("Qty {0}", qtyUnitsForHeader), 15, application_StoresDrugInfoView_controls_GridControl.AlignmentType.Right);
        dueOutGrid.AddColumn("Supplier",     40);

        // Add data
        foreach(WRequisRow requisitionLine in processor)
        {
            if ((requisitionLine.Status == OrderStatusType.Five) || (requisitionLine.Status == OrderStatusType.Six))
            {
                dueOutGrid.AddRow();

                dueOutGrid.SetCell ( 0, requisitionLine.RequisitionNumber );
                dueOutGrid.SetCell ( 1, requisitionLine.DateTimeOrdered.ToPharmacyDateString() );
                dueOutGrid.SetCell ( 2, requisitionLine.DateTimeReceived.ToPharmacyDateString() );
                dueOutGrid.SetCell ( 3, requisitionLine.OutstandingInPacksToWholePackString() );
                dueOutGrid.SetCell ( 4, "{0} - {1}", requisitionLine.SupplierCode, requisitionLine.SupplierName );
            }
        }                           
    }

    /// <summary>
    /// Display the issued orders in a grid
    /// These orders come from the WRequis table, and the list is limited to only display 
    /// due out orders (type WaitingPrintout, WaitingCulOnAppDate or Completed) for the last 
    /// LimitToDisplayRequisitionsIssued days (from settings),
    /// By default the list is sorted by the WRequisSort configuration setting.
    /// </summary>
    private void LoadIssued()
    {
        // Text to display if grid is empty
        issuedGrid.EmptyGridMessage = "No issue information on record.";

        // Load requisition data
        WRequis processor = new WRequis();
        processor.LoadBySiteIDNSVCodeAndFromDate(SessionInfo.SiteID, NSVCode, StoresDrugInfoViewSetting.LimitToDisplayRequisitionsIssuedFromDate);
        processor.Sort(StoresDrugInfoViewSetting.RequisitionSort);

        // Set grid title
        lblIssued.Text = "Issued";
        if (StoresDrugInfoViewSetting.HasLimitToDisplayRequisitionsIssued)
            lblIssued.Text = lblIssued.Text + string.Format(" (for last {0} days)", StoresDrugInfoViewSetting.LimitToDisplayRequisitionsIssuedInDays);

        // determine quantity units
        string qtyUnitsForHeader = ((product == null) || string.IsNullOrEmpty(product.PrintformV)) ? string.Empty : "(" + product.PrintformV + ")";

        // Add column headers
        issuedGrid.AddColumn("Rec Num",      10);
        issuedGrid.AddColumn("Order Date",   10);
        issuedGrid.AddColumn("Date Rec",     10);
        issuedGrid.AddColumn(string.Format("Qty {0}", qtyUnitsForHeader), 10, application_StoresDrugInfoView_controls_GridControl.AlignmentType.Right);
        issuedGrid.AddColumn("Supplier",     40);
        issuedGrid.AddColumn("Pick No.",     10);

        // Add data
        foreach(WRequisRow requisitionLine in processor)
        {
            if ((requisitionLine.Status == OrderStatusType.WaitingPrintout) ||  
                (requisitionLine.Status == OrderStatusType.WaitingCulOnAppDate) || 
                (requisitionLine.Status == OrderStatusType.Completed))
            {
                issuedGrid.AddRow();

                issuedGrid.SetCell ( 0, requisitionLine.RequisitionNumber );
                issuedGrid.SetCell ( 1, requisitionLine.DateTimeOrdered.ToPharmacyDateString() );
                issuedGrid.SetCell ( 2, requisitionLine.DateTimeReceived.ToPharmacyDateString() );
                issuedGrid.SetCell ( 3, requisitionLine.ReceivedInPacksToWholePackString() );
                issuedGrid.SetCell ( 4, "{0} - {1}", requisitionLine.SupplierCode, requisitionLine.SupplierName );
                issuedGrid.SetCell ( 5, requisitionLine.PickNumber.ToString() );
            }
        }                           
    }
}
