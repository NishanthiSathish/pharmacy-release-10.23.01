//===========================================================================
//
//						           Ordering.aspx.cs
//
//  Displays information about pending and received orders for a site's drug.
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Pharmacy site
//  HideCost            - 1 to hide prices\costs, else 0
//  NSVCode             - NSV code of pharmacy product to display.
//  
//  Usage:
//  Ordering.aspx?SessionID=123&AscribeSiteNumber=504&HideCost=1&NSVCode=AAA0001
//
//	Modification History:
//	23Jul09 XN  Written
//  29Apr10 XN  Replace old buisness layer classes with data layer classes
//  09Sep10 XN  Added showing delivery notes on received orders(if info captured)
//  11Jan13 XN  Changed StoresDrugInfoViewSetting.Settings.Instance with StoresDrugInfoViewSettingSetting
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;

public partial class application_StoresDrugInfoView_Ordering : System.Web.UI.Page
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
        NSVCode   = Request.QueryString["NSVCode"];
        moneyDisplayType = BoolExtensions.PharmacyParse(Request.QueryString["HideCost"]) ? MoneyDisplayType.HideWithLeadingSpace : MoneyDisplayType.Show;

        if (!IsPostBack)
        {
            // Load the product information
            WProduct productProcessor = new WProduct();
            productProcessor.LoadByProductAndSiteID(NSVCode, siteID);
            product = productProcessor.FirstOrDefault();

            // fill the pending orders grid
            LoadPendingOrders();

            // fill the received orders grid
            LoadReceivedOrdersOrders();
        }
    }

    /// <summary>
    /// If deliver note reference should be displayed. 
    /// Comes from configuration setting
    /// System:  D|Winord
    /// Section: Receipt
    /// Key:     CaptureDeliveryRef
    /// </summary>
    protected bool ShowDeliveryNoteReference
    {
        get { return (bool)WConfigurationController.LoadAndCache<bool>("D|Winord", "Receipt", "CaptureDeliveryRef", "N", false); }
    }

    /// <summary>
    /// Display the pending orders in a grid
    /// These orders come from the WOrder table, and the list is limited to only 
    /// display pending orders (type WaitingToReceive) for the last 
    /// LimitToDisplayOrdersPending days (from StoresDrugInfoViewSetting),
    /// By default the list is sorted by the WOrderSort configuration StoresDrugInfoViewSetting.
    /// </summary>
    protected void LoadPendingOrders()
    {
        // Text to display if grid is empty
        pendingOrdersGrid.EmptyGridMessage = "Not on order.";

        // Set grid title
        lblPendingOrders.Text = "Pending orders";
        if (StoresDrugInfoViewSetting.HasLimitToDisplayOrdersPending)
            lblPendingOrders.Text = lblPendingOrders.Text + string.Format(" (for last {0} days)", StoresDrugInfoViewSetting.LimitToDisplayOrdersPendingInDays);

        // Load pending orderes
        WOrder processor = new WOrder();
        processor.LoadBySiteIDNSVCodeAndFromDate(SessionInfo.SiteID, NSVCode, StoresDrugInfoViewSetting.LimitToDisplayOrdersPendingFromDate);
        processor.Sort(StoresDrugInfoViewSetting.OrderSort);

        // determine quantity units
        string qtyUnitsForHeader = ((product == null) || string.IsNullOrEmpty(product.PrintformV)) ? string.Empty : "(" + product.PrintformV + ")";

        // Add column headers
        pendingOrdersGrid.AddColumn("Order Num",    25);
        pendingOrdersGrid.AddColumn("Order Date",   25);
        pendingOrdersGrid.AddColumn(string.Format("Qty {0}", qtyUnitsForHeader), 20, application_StoresDrugInfoView_controls_GridControl.AlignmentType.Right);
        pendingOrdersGrid.AddColumn("Supplier",     30);
        
        // Add data
        foreach(WOrderRow orderLine in processor)
        {
            if (orderLine.Status == OrderStatusType.WaitingToReceive)
            {
                pendingOrdersGrid.AddRow();

                pendingOrdersGrid.SetCell ( 0, orderLine.OrderNumber.ToString() );
                pendingOrdersGrid.SetCell ( 1, orderLine.DateTimeOrdered.ToPharmacyDateString() );
                pendingOrdersGrid.SetCell ( 2, "{0} x {1}", orderLine.OutstandingInPacks.ToString(WOrder.GetColumnInfo().OutstandingInPacksLength), product.ConversionFactorPackToIssueUnits );
                pendingOrdersGrid.SetCell ( 3, "{0} - {1}", orderLine.SupplierCode, orderLine.SupplierName );
            }
        }
    }

    /// <summary>
    /// Display the received orders in a grid
    /// These orders come from the WReconcil table, and the list is limited to only 
    /// display pending orders for the last LimitToDisplayOrdersReceived days (from StoresDrugInfoViewSetting),
    /// and reconciliation items of type Received, WaitingPrintout, and WaitingCulOnAppDate
    /// By default the list is sorted by the ReconcilSort configuration setting.
    /// </summary>
    protected void LoadReceivedOrdersOrders()
    {
        // Text to display if grid is empty
        receivedOrdersGrid.EmptyGridMessage = "No received orders on record.";

        // Set grid title
        lblReceivedOrders.Text = "Received orders";
        if (StoresDrugInfoViewSetting.HasLimitToDisplayOrdersReceived)
            lblReceivedOrders.Text = lblReceivedOrders.Text + string.Format(" (for last {0} days)", StoresDrugInfoViewSetting.LimitToDisplayOrdersReceivedInDays);

        // Load received orders
        WReconcil processor = new WReconcil();
        processor.LoadBySiteIDNSVCodeAndFromDate(SessionInfo.SiteID, NSVCode, StoresDrugInfoViewSetting.LimitToDisplayOrdersReceivedFromDate);
        processor.Sort(StoresDrugInfoViewSetting.ReconcilSort);

        // determine quantity units
        string qtyUnitsForHeader = ((product == null) || string.IsNullOrEmpty(product.PrintformV)) ? string.Empty : "(" + product.PrintformV + ")";

        // Add column headers
        receivedOrdersGrid.AddColumn("Order Num",    10);
        receivedOrdersGrid.AddColumn("Order Date",   10);
        receivedOrdersGrid.AddColumn("Date Rec",     10);
        receivedOrdersGrid.AddColumn(string.Format ("Qty {0}", qtyUnitsForHeader), 10, application_StoresDrugInfoView_controls_GridControl.AlignmentType.Right);
        receivedOrdersGrid.AddColumn(ShowDeliveryNoteReference ? "Supplier & Reference" : "Supplier", 25); // If showing delivery note reference the add to header
        receivedOrdersGrid.AddColumn("Inv. Date.",   10);
        receivedOrdersGrid.AddColumn("Inv. Ref.",    15);
        receivedOrdersGrid.AddColumn("Cost",         10, application_StoresDrugInfoView_controls_GridControl.AlignmentType.Right);
        receivedOrdersGrid.ColumnKeepWhiteSpace(7, true);

        // Add data
        foreach(WReconcilRow reconcilLine in processor)
        {
            if ((reconcilLine.Status == OrderStatusType.Received)  || 
                (reconcilLine.Status == OrderStatusType.WaitingPrintout) || 
                (reconcilLine.Status == OrderStatusType.WaitingCulOnAppDate))
            {
                receivedOrdersGrid.AddRow();

                receivedOrdersGrid.SetCell ( 0, reconcilLine.OrderNumber.ToString() );
                receivedOrdersGrid.SetCell ( 1, reconcilLine.DateTimeOrdered.ToPharmacyDateString() );
                receivedOrdersGrid.SetCell ( 2, reconcilLine.DateTimeReceived.ToPharmacyDateString() );
                receivedOrdersGrid.SetCell ( 3, "{0}{1} x {2}", (reconcilLine.OutstandingInPacks != 0) ? "¤" : "", reconcilLine.ReceivedInPacks.ToString(WReconcil.GetColumnInfo().ReceivedInPacksLength), product.ConversionFactorPackToIssueUnits );
                
                // If delivery note is captured then show it under the supplier name (on two lines)
                List<string> supplierReference = new List<string>();
                supplierReference.Add(string.Format("{0} - {1}", reconcilLine.SupplierCode, reconcilLine.SupplierName));
                if (ShowDeliveryNoteReference && !string.IsNullOrEmpty(reconcilLine.DeliveryNoteReference))
                    supplierReference.Add(reconcilLine.DeliveryNoteReference);
                receivedOrdersGrid.SetCell ( 4, receivedOrdersGrid.RowCount - 1, supplierReference.ToArray() );

                receivedOrdersGrid.SetCell ( 5, reconcilLine.InvoiceDate.ToPharmacyDateString() );
                receivedOrdersGrid.SetCell ( 6, reconcilLine.InvoiceNumber );

                decimal  qtyOrderInPacks = reconcilLine.QuantityOrderedInPacks ?? 0m;
                bool     isCredit        = (qtyOrderInPacks < 0m);
                decimal? cost            = (isCredit && reconcilLine.CostExVatPerPack.HasValue) ? -reconcilLine.CostExVatPerPack : reconcilLine.CostExVatPerPack;
                string   displayCost     = string.Format("{0} {1}", cost.ToMoneyString(moneyDisplayType), isCredit ? "Cr" : "   ");
                receivedOrdersGrid.SetCell ( 7, displayCost );
            }
        }
    }
}
