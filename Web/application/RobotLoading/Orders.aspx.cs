//===========================================================================
//
//							      Orders.aspx.cs
//
//  Contains tables to display available orders that can be added to a loading
//
//  Call the page with the follow parameters
//  SessionID       - ICW session ID
//  SiteID          - Pharmacy site
//  HideCost        - If cost values are to be displayed of keep hidden
//  RobotLocation   - Location of the robot if displaying the Robot column.
//  IsInModal       - (optional) if displayed in modal dialog
//  
//  Usage:
//  Orders.aspx?SessionID=123&SiteID=24&RobotLocation=A6&HideCost=No
//
//	Modification History:
//	16Dec09 XN  Written
//  02Feb10 XN  F0042698 changed column header name, and used full supplier name
//  29Apr10 XN  Replace old buisness layer classes with data layer classes
//  29Nov11 XN  Changes SaveToSession to SaveToDBSession, and GetFromSession tp GetFromDBSession
//  16May13 XN  61741 Prevent adding order with partial packs.
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Xml.Linq;
using _Shared;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.robotloading;
using ascribe.pharmacy.shared;

public partial class application_RobotLoading_Orders : System.Web.UI.Page, ICallbackEventHandler
{
    // Name used to cache the current selected orders to the database
    static readonly string NsvcodeToOrderCachedName = typeof(application_RobotLoading_Orders) + ".ExistingOrders";

    protected int    sessionID;         // Session ID
    protected int    siteID;            // site number
    protected string robotLocation;     // robot location
    protected MoneyDisplayType moneyDisplayType = MoneyDisplayType.Show;    // If money is displayed
    protected bool isInModal;           // If in modal page

    protected string callbackResult;

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

        // Get form parameters
        robotLocation = Request.QueryString["RobotLocation"];

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
            // Create orders grid
            orderItems.controlID = "orderItems";
            orderItems.EmptyGridMessage = string.Format("There are no available orders waiting to be received that have items for this robot location '{0}'", robotLocation);
            orderItems.JavaEventClick         = "gridcontrol_onclick";
            orderItems.JavaEventDblClick      = "gridcontrol_ondblclick";
            orderItems.JavaEventCheckBoxClick = "gridcontrol_checkboxclick";

            orderItems.AddColumn(string.Empty, 4, application_RobotLoading_controls_GridControl.ColumnType.Checkbox);
            orderItems.AddColumn("Order Number", 24);
            orderItems.AddColumn("Supplier",     24);
            orderItems.AddColumn("Created Date", 24);
            orderItems.AddColumn("Outstanding Packs for Robot", 24, application_RobotLoading_controls_GridControl.AlignmentType.Right);

            // Load avaiable orders (group so can count total outstanding value
            WOrder orders = new WOrder(); 
            orders.LoadByAvailableForRobotLoadingAndFromDate(siteID, robotLocation, LimitToDisplayLoadingsFromDate);
            var orderInfo = orders.GroupBy(o => o.OrderNumber).Select(o => new { OrderNumber     = o.Key, 
                                                                                 SupplierCode    = o.First().SupplierCode,   
                                                                                 SupplierFullName= o.First().SupplierFullName, 
                                                                                 DateTimeOrdered = o.First().DateTimeOrdered,
                                                                                 Outstanding     = o.Sum(i => i.OutstandingInPacks ?? 0)                                                                                
                                                                                });
            // Populate grid
            foreach (var order in orderInfo)
            {
                orderItems.AddRow();
                orderItems.SetCell(1, order.OrderNumber.ToString());
                orderItems.SetCell(2, string.Format("{0} - {1}", order.SupplierCode, order.SupplierFullName));
                orderItems.SetCell(3, order.DateTimeOrdered.ToPharmacyDateTimeString());
                orderItems.SetCell(4, order.Outstanding.ToString());

                orderItems.AddRowExtraAttribute(orderItems.RowCount - 1, "OrderNumber", order.OrderNumber.ToString());
            }
        }
    }

    /// <summary>Gets the limit to the display orders from date</summary>
    protected DateTime LimitToDisplayLoadingsFromDate
    {
        get
        {
            int limitInDays = SettingsController.Load<int>("Pharmacy", "RobotLoading", "LimitToDisplayOrdersFromDate", 356);
            return DateTime.Now.AddDays(-limitInDays);
        }
    }

    /// <summary>
    /// Gets the selected orders dictionary from the cache (if non exists returns null)
    /// Orders dictionary contains NSVCode to order number
    /// </summary>
    /// <returns>selected orders dictionary</returns>
    private Dictionary<string, int> GetNsvcodeToOrderDictionary()
    {
        // Get data from cache (db cache)
        string data = PharmacyDataCache.GetFromDBSession(NsvcodeToOrderCachedName);
        if (string.IsNullOrEmpty(data))
            return null;

        // Convert from XML to dictionary
        Dictionary<string, int> result = new Dictionary<string,int>();
        foreach (XElement e in XElement.Parse(data).Elements())
        {
            string nsvcode     = e.Attribute("NSVCode").Value;
            int    orderNumber;

            if (int.TryParse(e.Attribute("OrderNumber").Value, out orderNumber))
                result.Add(nsvcode, orderNumber);
        }

        // Return dictionary
        return result; 
    }

    /// <summary>
    /// Saves the dictionary to the cache in xml form
    ///     <NSVCodeToOrder>
    ///         <Item NSVCode='NSV value' OrderNumber='order number' />
    ///         <Item NSVCode='NSV value' OrderNumber='order number' />
    ///         <Item NSVCode='NSV value' OrderNumber='order number' />
    ///     </NSVCodeToOrder>
    /// </summary>
    /// <param name="nsvcodeToOrder">dictionary ot save</param>
    private void SetNsvcodeToOrderDictionary(Dictionary<string, int> nsvcodeToOrder)
    {
        // convert to xml
        XElement xmldata = new XElement("NSVCodeToOrder");
        foreach (string nsvcode in nsvcodeToOrder.Keys)
        {
            xmldata.Add(new XElement("Item", 
                                    new XAttribute("NSVCode",     nsvcode),
                                    new XAttribute("OrderNumber", nsvcodeToOrder[nsvcode])
                                    ));
        }

        // Save to database
        PharmacyDataCache.SaveToDBSession(NsvcodeToOrderCachedName, xmldata.ToString());
    }

    /// <summary>
    /// Validate the orders against the values in the dictionary
    /// Will return error if order contains an NSV code that already existing in nsvcodeToOrder
    /// </summary>
    /// <param name="order">order</param>
    /// <param name="nsvcodeToOrder">Existing selected orders</param>
    /// <returns>return error if order contains an NSV code that already existing in nsvcodeToOrder else empty string</returns>
    private string ValidateOrder(WOrder order, Dictionary<string, int> nsvcodeToOrder)
    {
        foreach (WOrderRow row in order)
        {
            int existingOrderNumber;

            if (nsvcodeToOrder.TryGetValue(row.NSVCode, out existingOrderNumber) && (existingOrderNumber != row.OrderNumber))
                return string.Format("Cannot add order {0} as it contains '{1} - {2}' which already exists on order {3}.<br />Please reselect.", row.OrderNumber, row.NSVCode, row.ProductDescription ?? string.Empty, existingOrderNumber);
        }

        return string.Empty;
    }

    /// <summary>
    /// Called by client side script
    /// Validate the order against the currently selected order (existing order)
    /// Will return error if order contains an NSV code that already existing in nsvcodeToOrder, in format
    ///     ValidationError:[message]
    /// If vald then returns
    ///     Valid
    /// The list of currently selected orders will be updated with newOrderNumber, and the 
    /// information stored in a cache, ready for the next call
    /// </summary>
    /// <param name="newOrderNumber">New order number</param>
    /// <param name="existingOrderNumbers">Existing order numbers</param>
    /// <returns>Error</returns>
    protected string ValidateOrder(int newOrderNumber, List<int> existingOrderNumbers)
    {
        WOrder order = new WOrder();

        // Get the selected orders from the db cache
        Dictionary<string,int> nsvcodeToOrder = GetNsvcodeToOrderDictionary();

        // If dictionary does not exsting the create (using the existing order list)
        if (nsvcodeToOrder == null)
        {
            nsvcodeToOrder = new Dictionary<string,int>();

            foreach (int orderNumber in existingOrderNumbers)
            {
                order.LoadBySiteAndOrderNumber(SessionInfo.SiteID, orderNumber, false);
                foreach (WOrderRow row in order)
                    nsvcodeToOrder[row.NSVCode] = orderNumber;
            }
        }

        // Remove any missing existing orders from the cache
        List<string> nsvcodeToRemove = new List<string>();
        foreach(int orderNumber in nsvcodeToOrder.Values.Distinct())
        {
            if (!existingOrderNumbers.Contains(orderNumber))
                nsvcodeToRemove.AddRange(nsvcodeToOrder.Where(i => i.Value == orderNumber).Select(i => i.Key));
        }
        nsvcodeToRemove.ForEach(i => nsvcodeToOrder.Remove(i));

        // Load the new order lines, and validate (check if order contains an NSV code that already existing in cache)
        order.LoadBySiteAndOrderNumber(SessionInfo.SiteID, newOrderNumber, false);
        string error = ValidateOrder(order, nsvcodeToOrder);
        if (!string.IsNullOrEmpty(error))
            return string.Format("ValidationError:{0}:{1}", newOrderNumber, error);

        // Check the order does not contian any part quantities
        // 16May13 61741 Prevent adding order with partial packs.
        ProductStock productStock = new ProductStock();
        productStock.LoadByOrderNumber(this.siteID, newOrderNumber);
        foreach (var o in order)
        {
            var productStockRow = productStock.FirstOrDefault(ps => ps.NSVCode == o.NSVCode);
            if (o.SiteID == this.siteID && productStockRow != null && productStockRow.Location.EqualsNoCaseTrimEnd(this.robotLocation) && o.QuantityOrderedInPacks != null)
            {
                decimal quqntityOrdered = o.QuantityOrderedInPacks.Value;
                if (Math.Abs(quqntityOrdered - (int)quqntityOrdered) >= 0.001M)
                    return string.Format("ValidationError:{0}:{1}", newOrderNumber, string.Format("Select order has a robot item {0} that is not in whole packs.", o.NSVCode));
            }
        }

        // As valid added to order to the cache 
        foreach (WOrderRow row in order)
            nsvcodeToOrder[row.NSVCode] = newOrderNumber;
        SetNsvcodeToOrderDictionary(nsvcodeToOrder);

        // Return order is valid
        return "Valid";
    }

    /// <summary>
    /// Called by client side script
    /// Creates a new order loading
    /// </summary>
    /// <param name="orderNumbers">Order numbers to add to the order loading</param>
    /// <returns>
    /// If created returns
    ///     Created:[Loading number]
    /// else
    ///     CreateError:[Error message]
    /// </returns>
    private string CreateLoading(List<int> orderNumbers)
    {
        // check if any orders selected
        if (!orderNumbers.Any())
            return "CreateError:Please select at least one order.";

        // Load and validate each order
        Dictionary<string,int> nsvcodeToOrder = new Dictionary<string,int>();
        int newLoadingNumber;

        WOrder order = new WOrder();
        foreach (int orderNumber in orderNumbers)
        {
            order.LoadBySiteAndOrderNumber(SessionInfo.SiteID, orderNumber, false);
            string error = ValidateOrder(order, nsvcodeToOrder);
            if (!string.IsNullOrEmpty(error))
                return "CreateError:" + error;

            foreach (WOrderRow row in order)
        		nsvcodeToOrder[row.NSVCode] = row.OrderNumber;
        }

        // Crate new order loading
        try
        {
            // Get new loading number
            newLoadingNumber = PharmacyCounter.GetNextCount(SessionInfo.SiteID, "RobotLoading", "LoadingNumber", "Location");

            using(ICWTransaction transaction = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                // Create the order loading
                OrderLoading orderLoadings = new OrderLoading();
                OrderLoadingRow orderLoading = orderLoadings.Add(newLoadingNumber);
                orderLoadings.Save();

                // Add the order numbers to the order loading
                OrderLoadingDetail orderLoadingDetails = new OrderLoadingDetail();
                foreach (int orderNumber in orderNumbers)
                    orderLoadingDetails.Add(orderLoading.OrderLoadingID, orderNumber);
                orderLoadingDetails.Save();

                transaction.Commit();
            }
        }
        catch (Exception ex)
        {
            return "CreateError:" + ex.Message;
        }

        // Remove the selected orders from cache
        PharmacyDataCache.SaveToDBSession(NsvcodeToOrderCachedName, string.Empty);

        // Returns order loading number
        return "Created:" + newLoadingNumber.ToString();
    }

    #region ICallbackEventHandler Members
    /// <summary>
    /// Callback event raised by client side java script
    /// Call using javascript code CallServer('SaveProductNotes("Notes message")', '');
    /// the results of the method called are returned by GetCallbackResult
    /// </summary>
    /// <param name="eventArgument">Event arguments</param>
    public void RaiseCallbackEvent(string eventArgument)
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
        string parameter  = eventArgument.Substring(startIndex + 1, endIndex - startIndex - 1);

        // Call the appropriate method
        List<int> existingWorderNumbers = new List<int>(); 
        switch(methodName.ToLower())
        {
            // Validate new order selectiong
        case "validateorder":
            int checkedWOrderNumber = 0;
            foreach (string orderNumber in parameter.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                existingWorderNumbers.Add(int.Parse(orderNumber));

            if (existingWorderNumbers.Any())
            {
                checkedWOrderNumber = existingWorderNumbers[0];
                existingWorderNumbers.RemoveAt(0);
            }

            callbackResult = ValidateOrder(checkedWOrderNumber, existingWorderNumbers); 
            break;

            // Create a new loading
        case "createloading":
            foreach (string orderNumber in parameter.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                existingWorderNumbers.Add(int.Parse(orderNumber));

            callbackResult = CreateLoading(existingWorderNumbers) + ":" + parameter;
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
