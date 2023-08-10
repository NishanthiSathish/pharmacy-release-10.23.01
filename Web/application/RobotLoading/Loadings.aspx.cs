//===========================================================================
//
//							      Loading.aspx.cs
//
//  Contains two tables the first displaying active (and completed) loadings
//  and the second containing order for the selected loading.
//
//  Call the page with the follow parameters
//  SessionID       - ICW session ID
//  SiteID          - Pharmacy site
//  HideCost        - If cost values are to be displayed of keep hidden
//  RobotLocation   - Location of the robot if displaying the Robot column.
//  IsInModal       - (optional) if displayed in modal dialog
//  
//  Usage:
//  Loading.aspx?SessionID=123&SiteID=24&RobotLocation=A6&HideCost=No
//
//	Modification History:
//	16Dec09 XN  Written
//  02Feb10 XN  F0042698 added expected number of items
//===========================================================================
using System;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.robotloading;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;

public partial class application_RobotLoading_Loadings : System.Web.UI.Page, ICallbackEventHandler
{
    protected int    sessionID;     // Session ID
    protected int    siteID;        // site number
    protected string robotLocation; // robot location
    protected MoneyDisplayType moneyDisplayType = MoneyDisplayType.Show;    // If money is displayed
    protected bool   isInModal;     // If in modal page
    protected string callbackResult;// Callback result

    protected void Page_Load(object sender, EventArgs e)
    {
        // Add callserver function to the script
        String cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
        String callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
        Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "CallServer", callbackScript, true);

        // Initalise the Session
        sessionID = int.Parse(Request.QueryString["SessionID"]);
        siteID    = int.Parse(Request.QueryString["SiteID"]);
        SessionInfo.InitialiseSessionAndSiteID ( sessionID, siteID );

        // Get the robot location 
        robotLocation = Request.QueryString["RobotLocation"] ?? string.Empty;

        // Determine if cost is displayed from desktop parameter (default is show)
        string hideCost = Request.QueryString["HideCost"];
        if ( !string.IsNullOrEmpty(hideCost) && BoolExtensions.PharmacyParse(hideCost) ) 
            moneyDisplayType = MoneyDisplayType.HideWithLeadingSpace;
        else
            moneyDisplayType = MoneyDisplayType.Show;

        // Determine if this is a modal form (used to display hide close button)
        isInModal = BoolExtensions.PharmacyParse(Request.QueryString["IsInModal"] ?? "false");

        if (!IsPostBack)
        {
            // Load in the order loading, and orders info
            OrderLoadingWithOrder data = new OrderLoadingWithOrder();
            data.LoadByActiveOrderSiteLocationAndFromDate(siteID, robotLocation, LimitToDisplayLoadingsFromDate);

            // Load in the deleted orders
            OrderLoadingWithOrder deletedOrders = new OrderLoadingWithOrder();
            deletedOrders.LoadByDeletedOrderSiteLocationAndFromDate(siteID, robotLocation, LimitToDisplayLoadingsFromDate);

            // Setup the robobt location table
            robotLoadingItems.controlID = "robotLoadingItems";
//            robotLoadingItems.JavaEventOnKeyDown = "frame_onkeydown";
            robotLoadingItems.JavaEventClick = "robotLoadingItems_onclick";

            robotLoadingItems.AddColumn("Loading Number", 10);
            robotLoadingItems.AddColumn("Created By",     25);
            robotLoadingItems.AddColumn("Created Date",   15);
            robotLoadingItems.AddColumn("Status",         10);
            robotLoadingItems.AddColumn("Completed By",   25);
            robotLoadingItems.AddColumn("Completed Date", 15);

            // Select just the loading data
            var query = data.Select(r => new { r.OrderLoadingID, 
                                               r.LoadingNumber, 
                                               r.CreatedUser_Name, 
                                               r.CreatedDateTime, 
                                               r.Status, 
                                               r.UpdatedUser_Name, 
                                               r.UpdatedDateTime }).Distinct();

            // Populate the loading grid
            foreach(var loading in query)
            {
                robotLoadingItems.AddRow();

                robotLoadingItems.AddRowExtraAttribute(robotLoadingItems.RowCount - 1, "OrderLoadingID", loading.OrderLoadingID.ToString());
                robotLoadingItems.AddRowExtraAttribute(robotLoadingItems.RowCount - 1, "Status",         loading.Status.ToString());

                robotLoadingItems.SetCell(0, loading.LoadingNumber.ToString());
                robotLoadingItems.SetCell(1, loading.CreatedUser_Name);
                robotLoadingItems.SetCell(2, loading.CreatedDateTime.ToPharmacyDateTimeString());
                robotLoadingItems.SetCell(3, loading.Status.ToString());
                robotLoadingItems.SetCell(4, loading.UpdatedUser_Name);
                if (loading.UpdatedDateTime.HasValue)
                    robotLoadingItems.SetCell(5, loading.UpdatedDateTime.Value.ToPharmacyDateTimeString());
            }

            // Setup the orders table
            orderItems.controlID = "orderItems";
            orderItems.JavaEventClick    = "orderItems_onclick";
            orderItems.JavaEventDblClick = "orderItems_ondblclick";

            orderItems.AddColumn ("Order Number",                    15);
            orderItems.AddColumn ("Supplier",                        65);
            orderItems.AddColumn ("Robot Packs Received / Expected", 20, application_RobotLoading_controls_GridControl.AlignmentType.Right);
            orderItems.ColumnKeepWhiteSpace(2, true);

            // Populate the orders table
            foreach (OrderLoadingWithOrderRow row in data)
            {
                decimal? receivedInPacks        = row.CalculatedReceivedInPacks();   // Can't use receive as it is not correct
                decimal? quantityOrderedInPacks = row.QuantityOrderedInPacks;
 
                // Get if there are any deleted items on this order (and have received any deleted items)
                //      received         = received + received on deleted item count 
                //      quantity ordered = quantity ordered + quantity ordered on deleted item count
                OrderLoadingWithOrderRow deletedOrderRow = deletedOrders.FirstOrDefault(o => (o.LoadingNumber == row.LoadingNumber) && (o.WOrderNum == row.WOrderNum));
                if (deletedOrderRow != null)
                {
                    decimal? deletedOrdersReceivedInPacks = deletedOrderRow.CalculatedReceivedInPacks();
                    if (deletedOrdersReceivedInPacks.HasValue && deletedOrdersReceivedInPacks > 0m)
                    {
                        receivedInPacks = (receivedInPacks ?? 0m) + deletedOrdersReceivedInPacks.Value;
                        quantityOrderedInPacks = (quantityOrderedInPacks ?? 0m) + deletedOrderRow.QuantityOrderedInPacks;
                    }
                }

                orderItems.AddRow();

                orderItems.AddRowExtraAttribute(orderItems.RowCount - 1, "OrderLoadingID",       row.OrderLoadingID.ToString());
                orderItems.AddRowExtraAttribute(orderItems.RowCount - 1, "OrderLoadingDetailID", row.OrderLoadingDetailID.ToString());
                orderItems.AddRowExtraAttribute(orderItems.RowCount - 1, "OrderNumber",          row.WOrderNum.ToString());

                orderItems.SetCell(0, row.WOrderNum.ToString());
                orderItems.SetCell(1, string.Format("{0} - {1}", row.SupplierCode, row.SupplierFullName));
                orderItems.SetCell(2, string.Format("{0} / {1}", receivedInPacks.ToString(WOrder.GetColumnInfo().OutstandingInPacksLength), quantityOrderedInPacks.ToString(WOrder.GetColumnInfo().QuantityOrderedInPacksLength).PadLeft(4)));
            }
        }
    }

    /// <summary>Gets the limit to the display loadings from date</summary>
    protected DateTime LimitToDisplayLoadingsFromDate
    {
        get
        {
            int limitInDays = SettingsController.Load<int>("Pharmacy", "RobotLoading", "LimitToDisplayLoadingsFromDate", 90);
            return DateTime.Now.AddDays(-limitInDays);
        }
    }

    /// <summary>
    /// Called by the client side script to marks a loading a complete
    /// Will either return
    ///     Compelte:[Order loadig ID]:[State]:[Users full name]:[Completed date and time]
    /// or
    ///     Error:[error message]
    /// </summary>
    /// <param name="orderLoadingID">ID of the order loading to complted</param>
    /// <returns>Return data</returns>
    private string Complete(int orderLoadingID)
    {
        OrderLoading loading = new OrderLoading();
        loading.LoadByID(orderLoadingID);

        if (!loading.Any())
            return "Error:Invalid order loading";

        DateTime now = DateTime.Now;

        loading[0].Status               = OrderLoadingStatus.Completed;
        loading[0].UpdatedDateTime      = now;
        loading[0].UpdatedUser_EntityID = SessionInfo.EntityID;
        loading.Save();

        return string.Format("Complete¦{0}¦{1}¦{2}¦{3}", orderLoadingID, OrderLoadingStatus.Completed, SessionInfo.Fullname, now.ToPharmacyDateTimeString());
    }

    #region ICallbackEventHandler Members
    /// <summary>
    /// Callback event raised by client side java script
    /// Call using javascript code CallServer('SaveProductNotes("Notes message")', '');
    /// the results of the method called are returned by GetCallbackResult
    /// </summary>
    /// <param name="eventArgument">Event arguments</param>
    public void RaiseCallbackEvent(String eventArgument)
    {
        callbackResult = string.Empty;

        if (string.IsNullOrEmpty(eventArgument))
            return;
        
        // Extract the brackets for the method call
        int startIndex = eventArgument.IndexOf('(');
        int endIndex   = eventArgument.LastIndexOf(')');
        if ((startIndex < 0) || (endIndex < 0))
            return;

        // Get the method name and parameters
        string methodName = eventArgument.Substring(0, startIndex).Trim().ToLower();
        string parameter  = eventArgument.Substring(startIndex + 2, endIndex - startIndex - 3);

        // Call the appropriate method
        switch(methodName.ToLower())
        {
        case "complete": 
            callbackResult = Complete(int.Parse(parameter)); 
            break;
        }
    }

    /// <summary>Returns RaiseCallbackEvent result</summary>
    /// <returns>RaiseCallbackEvent result</returns>
    public string GetCallbackResult()
    {
        return callbackResult;
    }
    #endregion
}
