//===========================================================================
//
//						        SupplierInformation.aspx.cs
//
//  Displays detailed product stock information about a site's drug in a panel, and 
//  also lists of supplies in a grid.
//
//  Double click on a row on the suppliers grid will display a SupplierDetails.aspx
//  page in a separate window. This is done client side.
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Pharmacy site
//  HideCost            - 1 to hide prices\costs, else 0
//  NSVCode             - NSV code of pharmacy product to display.
//  
//  Usage:
//  SupplierInformation.aspx?SessionID=123&AscribeSiteNumber=504&HideCost=1&NSVCode=AAA0001
//
//	Modification History:
//	23Jul09 XN  Written
//  29Apr10 XN  Replace old buisness layer classes with data layer classes
//  05Aug10 XN  F0090910 V8 upgrade sites with 3 char suppliers codes can have
//                       space at end, causes problems spotting primary supplier
//  01Nov13 XN  Knock on changes after removal of ProductObjectInfo
//  18Dec13 XN  78339 Knock on changes after making LeadTimeInDays nullable
//  24Jul15 XN  87484 Increased width of contract reference field in grid
//  11Oct16 XN  87483 Pharmacy F4 screens - indicate if a Homecare supplier
//              Also changed to use the new pharmacy list control
//  20Jan17 XN  126634 - Replaced supplier info with configurable version & added User Fields 1,2,3
//  11May18 GB  211742 Additional handling of expired contracts
//===========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.quesscrllayer;

public partial class application_StoresDrugInfoView_SupplierInformation : System.Web.UI.Page
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
        moneyDisplayType = (Request.QueryString["HideCost"] == "1") ? MoneyDisplayType.HideWithLeadingSpace : MoneyDisplayType.Show;

        if (!IsPostBack)
        {
            // Load the product information
            WProduct productProcessor = new WProduct();
            productProcessor.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID);
            product = productProcessor.FirstOrDefault();

            // Load product supplier
            if (product != null)
                LoadProductInfo();

            // Load product supplier information
            if (product != null)
                LoadProductSupplier();
        }
    }

    /// <summary>
    /// Displays an panel detailing product stock information.
    /// 20Jan17 XN  126634 - Replaced supplier info with configurable version and added User Fields 1,2,3
    /// </summary>
    private void LoadProductInfo()
    {
        //productInfoLabelPanel.SetColumns ( 2 );

        //// Column 1
        //productInfoLabelPanel.AddLabel ( 0, "Minimum issue:", "{0} {1}", product.MinIssueInIssueUnits, product.PrintformV);
        //productInfoLabelPanel.AddLabel ( 0, "Maximum issue:", "{0} {1}", product.MaxIssueInIssueUnits, product.PrintformV);
        //productInfoLabelPanel.AddLabel ( 0, "Reorder quantity:", "{0} x {1} {2}", product.ReOrderQuantityInPacks.ToString(WProduct.GetColumnInfo().ReOrderQuantityInPacksLength), product.ConversionFactorPackToIssueUnits, product.PrintformV);
        //productInfoLabelPanel.AddLabel ( 0, "BNF code:", product.BNF );
        //productInfoLabelPanel.AddLabel ( 0, "Ledger code:", product.LedgerCode );
        //productInfoLabelPanel.AddLabel ( 0, "Therapeutic code:", product.TherapyCode );
        //productInfoLabelPanel.AddLabel ( 0, "Disp. pack size:", "{0}", product.mlsPerPack.ToString("0.###") );

        //// Column 2
        //productInfoLabelPanel.AddLabel ( 1, "Gains/Losses:", product.LossesGainExVat.ToMoneyString(moneyDisplayType) );
        //productInfoLabelPanel.AddLabel ( 1, "Stock take status:", product.StockTakeStatus.ToString() );
        //productInfoLabelPanel.AddLabel ( 1, "Date last checked:", product.LastStockTakeDateTime.ToPharmacyDateTimeString() );

        //DateTime? estimatedOutOfStockDate = product.EstimatedOutOfStockDate;
        //if (estimatedOutOfStockDate.HasValue)
        //{
        //    // if ((estimatedOutOfStockDate.Value - DateTime.Now).TotalDays <= product.LeadTimeInDays)  18Dec13	XN 78339
        //    if (((decimal)(estimatedOutOfStockDate.Value - DateTime.Now).TotalDays) <= (product.LeadTimeInDays ?? 0))
        //        productInfoLabelPanel.AddLabel ( 1, "Est. out of stock:", string.Empty);
        //    else
        //        productInfoLabelPanel.AddLabel ( 1, "Est. out of stock:", estimatedOutOfStockDate.ToPharmacyDateString());
        //}

        var accessors = new IQSDisplayAccessor[] { new WProductQSProcessor() };        
        productInfoLabelPanel.QSLoadConfiguration(SessionInfo.SiteID, "StoresDrugInfo", "Supplier Product Info");
        productInfoLabelPanel.SetColumnsQS();
        productInfoLabelPanel.AddLabelsQS(new BaseRow[] { product }, accessors);
    }

    /// <summary>
    /// Displays a grid of product suppliers
    /// Grid is order so primary supplier is first in list, and then by supplier name
    /// </summary>
    private void LoadProductSupplier()
    {
        // Text to display if grid is empty
        productSuppliersGrid.EmptyGridMessage = "There are no suppliers for this product.";

        // Load all the suppliers info for the drug
        WSupplierProfile processor = new WSupplierProfile();
        processor.LoadBySiteIDAndNSVCode(SessionInfo.SiteID, NSVCode);

        // Order the profile by if primary supplier, and then by name.
        IEnumerable<WSupplierProfileRow> supplierProfiles = processor.OrderBy( i => i.SupplierName ).OrderBy ( i => !i.SupplierCode.EqualsNoCaseTrimEnd(product.SupplierCode) );

        // Load all the suppliers (need to get info on if PSO supplier) 11Oct16 XN 87483
        WSupplier2 supplier = new WSupplier2();
        supplier.LoadBySiteAndCodes(SessionInfo.SiteID, processor.Select(c => c.SupplierCode));

        productSuppliersGrid.AddColumn("Supplier<br />Code",        8);
        productSuppliersGrid.AddColumn("Supplier<br />Description", 14);
        productSuppliersGrid.AddColumn("Primary<br />Supplier",     8, PharmacyGridControl.AlignmentType.Center);
        productSuppliersGrid.AddColumn("Trade Name",                14);
        productSuppliersGrid.AddColumn("Contract No.",              10,PharmacyGridControl.AlignmentType.Right);
        productSuppliersGrid.AddColumn("Contract<br />Price",       9, PharmacyGridControl.AlignmentType.Right);
        productSuppliersGrid.AddColumn("Outer Size<br />(packs)",   9, PharmacyGridControl.AlignmentType.Right);
        productSuppliersGrid.AddColumn(string.Format("{0} Value", PharmacyCultureInfo.SalesTaxName), 10, PharmacyGridControl.AlignmentType.Right);
        productSuppliersGrid.AddColumn("Last<br />Invoiced",        9, PharmacyGridControl.AlignmentType.Right);
        productSuppliersGrid.AddColumn("Last Paid",                 9, PharmacyGridControl.AlignmentType.Right);

        String contractExpiredStyle = "font-style: italic; color: Red;";

        foreach(WSupplierProfileRow profile in supplierProfiles)
        {
            productSuppliersGrid.AddRow();

            //productSuppliersGrid.SetRowTag ( productSuppliersGrid.RowCount - 1, profile.SupplierCode ); 11Oct16 XN 87483
            productSuppliersGrid.AddRowAttribute("supcode", profile.SupplierCode);

            // Is the supplier is a PSO supplier the make italic 11Oct16 XN 87483
            if (supplier.FindByCode(profile.SupplierCode) != null && supplier.FindByCode(profile.SupplierCode).PSOSupplier)
            {
                productSuppliersGrid.SetRowStyle("font-style:italic");
                productSuppliersGrid.AddRowAttribute("title", "PSO supplier");
            }
            
            WExtraDrugDetail extraDrugInfo = new WExtraDrugDetail();
            extraDrugInfo.LoadBySiteIDNSVCodeAndSupCode(profile.SiteID, profile.NSVCode, profile.SupplierCode);
            WExtraDrugDetailRow latestExtraDrugDetial = extraDrugInfo.FindLastByActiveOrExpired();


            productSuppliersGrid.SetCell(0, profile.SupplierCode);
            productSuppliersGrid.SetCell(1, profile.SupplierName);
            productSuppliersGrid.SetCell(2, profile.SupplierCode.EqualsNoCaseTrimEnd(product.SupplierCode).ToYesNoString() );
            productSuppliersGrid.SetCell(3, profile.SupplierTradename);
            productSuppliersGrid.SetCell(4, profile.ContractNumber);
            productSuppliersGrid.SetCell(5, profile.ContractPrice.ToMoneyString(moneyDisplayType));
            productSuppliersGrid.SetCell(6, "{0}", profile.ReorderPackSize.ToString(WSupplierProfile.GetColumnInfo().ReorderPackSizeLength));
            productSuppliersGrid.SetCell(7, "{0} ({1})", profile.VATCode, profile.VATRate.ToPharmacyVATString());
            productSuppliersGrid.SetCell(8, (profile.LastReconcilePriceExVatPerPack ?? 0m).ToMoneyString (moneyDisplayType));
            productSuppliersGrid.SetCell(9, profile.LastReceivedPriceExVatPerPack.ToMoneyString  (moneyDisplayType));

            if (latestExtraDrugDetial != null && latestExtraDrugDetial.IsExpired)
            {
                productSuppliersGrid.SetCellStyle(4, contractExpiredStyle);//ContractNumber
                productSuppliersGrid.SetCellStyle(5, contractExpiredStyle);//ContractPrice
            }
        }
    }
}