//===========================================================================
//
//						        WardStock.aspx.cs
//
//  Displays detailed information about the stock levels on each ward.
//  A ward might appear twice in the list if it use two lists, or if the list 
//  has two line for the same drug.
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Pharmacy site
//  HideCost            - 1 to hide prices\costs, else 0
//  NSVCode             - NSV code of pharmacy product to display.
//  
//  Usage:
//  WardStock.aspx?SessionID=123&AscribeSiteNumber=504&HideCost=1&NSVCode=AAA0001
//
//	Modification History:
//	23Jul09 XN  Written
//  29Apr10 XN  Replace old buisness layer classes with data layer classes
//  31Dec14 XN  Changed control to use new Ward Stock List classes
//              Add list code column to distinguish when ward is used by two lists
//              Out of use ward are marked with ~ (same for lists) 69194
//              Increased size of date column 97963
//              Update to use new grid control
//  08Jan15 XN  Now grouping lines by list 107437
//===========================================================================
using System;
using System.Linq;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.wardstocklistlayer;

public partial class application_StoresDrugInfoView_WardStock : System.Web.UI.Page
{
    protected string            NSVCode          = string.Empty;            // NSV code for product to display
    protected MoneyDisplayType  moneyDisplayType = MoneyDisplayType.Show;   // If prices\cost values are to be displayed

    protected WProductRow product = null;      // Product to display

    protected void Page_Load(object sender, EventArgs e)
    {
        // Initalise the Session
        int sessionID = int.Parse(Request.QueryString["SessionID"]);
        int siteID    = int.Parse(Request.QueryString["SiteID"]);
        SessionInfo.InitialiseSessionAndSiteID ( sessionID, siteID );

        // Load in the query string parameters
        NSVCode          = Request.QueryString["NSVCode"];
        moneyDisplayType = (Request.QueryString["HideCost"] == "1") ? MoneyDisplayType.HideWithLeadingSpace : MoneyDisplayType.Show;

        if (!IsPostBack)
        {
            // Load the product information
            WProduct productProcessor = new WProduct();
            productProcessor.LoadByProductAndSiteID(NSVCode, siteID);
            product = productProcessor.FirstOrDefault();

            LoadWardStock();
        }
    }

    /// <summary>
    /// Displays a list of wards, and the stock level on the ward.
    /// This list is ordered by ward name
    /// 31Dec14 XN update with new ward stock structures
    /// 08Jan15 XN Now grouping lines by list 107437    
    /// </summary>
    protected void LoadWardStock()
    {
        string qtyUnits = (product == null) || string.IsNullOrEmpty(product.PrintformV) ? string.Empty : "(" + product.PrintformV + ")";

        // Set column headers
        wardStockGrid.AddColumn("Location",                                         38, PharmacyGridControl.ColumnType.Text );
        //wardStockGrid.AddColumn("Location Code",                                    13, PharmacyGridControl.ColumnType.Text );     08Jan15 XN Removed Location Code line as confusing 107437
        wardStockGrid.AddColumn("List Code",                                        13, PharmacyGridControl.ColumnType.Text );
        wardStockGrid.AddColumn(string.Format("Pack size<br/>{0}", qtyUnits),       13, PharmacyGridControl.ColumnType.Number,  PharmacyGridControl.AlignmentType.Center);
        wardStockGrid.AddColumn("Quantity",                                         10, PharmacyGridControl.ColumnType.Number,  PharmacyGridControl.AlignmentType.Right );
        //wardStockGrid.AddColumn(string.Format("Qty last issued<br/>{0}", qtyUnits), 13, PharmacyGridControl.ColumnType.Number,  PharmacyGridControl.AlignmentType.Right );    Believe qty is in issue units but not 100% sure so remove old code that displays units
        wardStockGrid.AddColumn("Qty last issued",                                  13, PharmacyGridControl.ColumnType.Number,  PharmacyGridControl.AlignmentType.Right );
        wardStockGrid.AddColumn("Date last issued",                                 13, PharmacyGridControl.ColumnType.DateTime,PharmacyGridControl.AlignmentType.Center);

        wardStockGrid.ColumnKeepWhiteSpace(0, true);
        wardStockGrid.ColumnKeepWhiteSpace(1, true);

        // Load in all the ward stock information for this particular drug.
        WWardProductListLine lines = new WWardProductListLine();
        lines.LoadByNSVCodeAndSite(NSVCode, SessionInfo.SiteID);

        // If any ward information then load in all list, and customer info for site as will need to reference it
        WWardProductList lists     = new WWardProductList();
        WCustomer        customers = new WCustomer();
        if (lines.Any())
        {
            lists.LoadBySiteAndInUse      (SessionInfo.SiteID, null);
            customers.LoadBySiteIDAndInUse(SessionInfo.SiteID, null);
        }

        //// Remove new wards as not interested in them 31Dec14 XN obsolete with new ward stock lists
        //List<WWardStockListRow> wardStockList = wardStockProcessor.ToList();
        //wardStockList = wardStockList.FindAll( i => !i.IsNewWard );

        // group lines by list
        // Remove lists not associated with a ward
        // and sort by ward in use, list in use, ward description, list code
        //  08Jan15 XN 107437 90835
        var sortedLists = from line in lines
                          group line by line.WWardProductListID into l
                          let list     = lists.FindByID(l.Key)
                          let customer = (list.WCustomerID == null) ? null : customers.FindByID(list.WCustomerID.Value)
                          where customer != null
                          orderby (customer.InUse && (customer.Ward_InUse ?? false)) descending, 
                                  list.InUse descending, 
                                  customer.Description, 
                                  list.Code
                          select new {
                                        lines    = l,
                                        listInfo = list,
                                        customer
                                      };

        // Display the stock information
        foreach(var list in sortedLists)
        {
            wardStockGrid.AddRow ();

            // Add location name (Code - Description) (prefix with ~ if ward not in use)
            bool   wardInUsed = list.customer.InUse && (list.customer.Ward_InUse ?? false);
            string location = (wardInUsed ? " " : "~") + list.customer.ToString();
            wardStockGrid.SetCell ( 0, location ); 

            // List code (prefixed with ~ if list no in use)
            wardStockGrid.SetCell ( 1, (list.listInfo.InUse ? " " : "~") + list.listInfo.Code );

            // Pack size (or Variable if different lines have different pack sizes) 08Jan15 XN 107437 90835
            var    packsizes = list.lines.Select(l => l.GetConversionFactorPackToIssueUnits()).Distinct().ToList();
            string packsize  = (packsizes.Count() == 1) ? packsizes.First().ToString() : "Variable";
            wardStockGrid.SetCell ( 2, packsize ); 

            // sum of topup level 08Jan15 XN 107437 90835
            var totalTopupLevel = list.lines.Sum(l => l.TopupLvl);
            wardStockGrid.SetCell(3, totalTopupLevel.ToString()); 
                
            // Get the last issued item and display Last Issued qty and date 08Jan15 XN 107437 90835
            var lastIssuedLine = list.lines.OrderByDescending(l => l.LastIssueDate).First();
            string lastIssued  = lastIssuedLine == null ? string.Empty : lastIssuedLine.LastIssue.ToString();   // Believe qty is in issue units but not 100% sure so remove old code that displays it in packs     lastIssuedInPack = string.Format("{0} x {1}", lastIssuedLine.LastIssue, lastIssuedLine.GetConversionFactorPackToIssueUnits()); 
            
            wardStockGrid.SetCell(4, lastIssued);
            wardStockGrid.SetCell(5, lastIssuedLine.LastIssueDate.ToPharmacyDateString());
        }
    }
}
