//===========================================================================
//
//							   ICW_ReceiveGoods.cs
//
//  Display goods to be received on an order.
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Pharmacy site
//  OrderNumber         - Number for the order to be displayed
//  HideCost            - If cost values are to be displayed of keep hidden
//  RobotLocation       - (optional) Location of the robot if displaying the Robot column.
//  IsInModal           - (optional) if displayed in modal dialog
//  
//  Usage:
//  ICW_ReceiveGoods.aspx?SessionID=123&AscribeSiteNumber=504&RobotLocation=A6&OrderNumber=10131&HideCost=No
//
//	Modification History:
//	16Dec09 XN  Written
//  02Feb10 XN  F0042698 added and removed columns for robot loading
//  18Mar10 XN  F0080744 fixed problem with robot item not at top of order info screen
//              F0080745 add manual robot loading item
//  29Apr10 XN  Replace old buisness layer classes with data layer classes
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;

public partial class application_ReceiveGoods_ICW_ReceiveGoods : System.Web.UI.Page
{
    protected int    sessionID;     // Session ID
    protected int    siteNumber;    // site number
    protected int    orderNumber;   // Order Number
    protected string robotLocation; // robot location
    protected MoneyDisplayType moneyDisplayType = MoneyDisplayType.Show;    // If money is displayed
    protected bool   isInModal;     // If in modal dialog

    protected void Page_Load(object sender, EventArgs e)
    {
        // Initalise the Session
        sessionID = int.Parse(Request.QueryString["SessionID"]);
        siteNumber= int.Parse(Request.QueryString["AscribeSiteNumber"]);
        SessionInfo.InitialiseSessionAndSiteNumber ( sessionID, siteNumber );

        // Load in the robot loading location
        robotLocation = Request.QueryString["RobotLocation"] ?? string.Empty;

        // Load in the order number
        string orderNumberStr = Request.QueryString["OrderNumber"] ?? string.Empty;
        int.TryParse(orderNumberStr, out orderNumber);

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
            // Load in the order (deleted items are not displayed in grid but noted in text at bottom of form)
            WOrder order = new WOrder();
            order.LoadBySiteAndOrderNumber(SessionInfo.SiteID, orderNumber, true);

            // Load in the stock
            ProductStock stock = new ProductStock();
            stock.LoadByOrderNumber(SessionInfo.SiteID, orderNumber);

            // Fill in the title for the page
            lblInfo.Text = string.Format("Receive Goods for Order {0}", orderNumber);
            if (order.Any() && !string.IsNullOrEmpty(order.First().SupplierCode))
                lblInfo.Text += string.Format(" - {0} ({1})", order.First().SupplierCode, order.First().SupplierName);

            // Setup the table
            orderItemsGrid.EmptyGridMessage = string.Format("No order for order number {0}", orderNumber);
            orderItemsGrid.AllowClick    = true;
            orderItemsGrid.AllowDblClick = true;  // Enabled when F4 screens are added to the project
            orderItemsGrid.controlID = "orderItemsGrid";

            orderItemsGrid.AddColumn("Description",       60);
            orderItemsGrid.AddColumn("Quantity on Order", 10, application_ReceiveGoods_controls_GridControl.AlignmentType.Right);
            orderItemsGrid.AddColumn("To Follow",         10, application_ReceiveGoods_controls_GridControl.AlignmentType.Right);
            orderItemsGrid.AddColumn("Quantity received", 10, application_ReceiveGoods_controls_GridControl.AlignmentType.Right);
            if (!string.IsNullOrEmpty(robotLocation))
                orderItemsGrid.AddColumn("Robot", 10, application_ReceiveGoods_controls_GridControl.AlignmentType.Center);

            // For robot loading screen orders are to be sorted if it is robot item (Automatic, Manual, No), and then product description.
            // Any changes to the sorting will need to take this into account.
            // Also remove deleted orders
            IEnumerable<WOrderRow> sortedOrders = from o in order
                                                  where o.Status != OrderStatusType.Deleted
                                                  let s = stock.FirstOrDefault(s => (s.NSVCode == o.NSVCode))
                                                  let isRobotItem = (s == null) ? RobotItem.No : s.IsRobotItem(robotLocation)
                                                  orderby (int)isRobotItem, o.ProductDescription 
                                                  select o;

            // Populate the table
            foreach (WOrderRow orderRow in sortedOrders)
            {
                // Can't use receive as it is not correct
                decimal? received = null;   
                if (orderRow.OutstandingInPacks.HasValue && orderRow.QuantityOrderedInPacks.HasValue)
                    received = Math.Max(orderRow.QuantityOrderedInPacks.Value - orderRow.OutstandingInPacks.Value, 0m);

                // check if it is a robot item
                bool robotItem = stock.Any(s => (s.NSVCode == orderRow.NSVCode) && (s.Location == robotLocation));

                orderItemsGrid.AddRow();

                orderItemsGrid.AddRowExtraAttribute(orderItemsGrid.RowCount - 1, "WOrderID", orderRow.WOrderID.ToString());
                orderItemsGrid.AddRowExtraAttribute(orderItemsGrid.RowCount - 1, "NSVCode",  orderRow.NSVCode);

                orderItemsGrid.SetCell(0, orderRow.ProductDescription);
                orderItemsGrid.SetCell(1, orderRow.QuantityOrderedInPacks.ToString(WOrder.GetColumnInfo().QuantityOrderedInPacksLength));
                orderItemsGrid.SetCell(2, orderRow.OutstandingInPacks.ToString(WOrder.GetColumnInfo().OutstandingInPacksLength));
                orderItemsGrid.SetCell(3, received.ToString(WOrder.GetColumnInfo().ReceivedInPacksLength));

                // Set the robot item column text
                ProductStockRow stockItem = stock.FirstOrDefault(s => (s.NSVCode == orderRow.NSVCode));
                string robotItemText = "No";
                if (stockItem != null)
                {
                    switch (stockItem.IsRobotItem(robotLocation))
                    {
                    case RobotItem.Automatic: robotItemText = "Yes";    break;
                    case RobotItem.Manual:    robotItemText = "Manual"; break;
                    case RobotItem.No:        robotItemText = "No";     break;
                    }
                }
                orderItemsGrid.SetCell(4, robotItemText);
            }

            // Update information on any deleted items in the order
            decimal deletedItemsReceived = order.Where(o => o.Status == OrderStatusType.Deleted).Sum(o => o.CalculateReceivedInPacks() ?? 0m);
            if (deletedItemsReceived > 0m)
            {
                lblDeletedItems.Text    = string.Format(lblDeletedItems.Text, deletedItemsReceived);
                lblDeletedItems.Visible = true;
            }
        }
    }
}
