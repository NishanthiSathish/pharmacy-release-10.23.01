//===========================================================================
//
//						        SupplierDetails.aspx.cs
//
//  Popup page to display supplier, and suppliers product, information.
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Pharmacy site
//  HideCost            - 1 to hide prices\costs, else 0
//  NSVCode             - NSV code of pharmacy product to display.
//  SupplierCode        - supplier code
//  
//  Usage:
//  SupplierDetails.aspx?SessionID=123&AscribeSiteNumber=504&HideCost=1&NSVCode=AAA0001&SupplierCode=FALT1
//
//	Modification History:
//	23Jul09 XN  Written
//  29Apr10 XN  Replace old buisness layer classes with data layer classes
//  01Nov13 XN  Knock on changes after removal of ProductObjectInfo
//  24Jan17 XN  126634 and contract start and end time, and GTIN
//  11May18 GB  211742 Additional handling of expired contracts
//===========================================================================
using System;
using System.Linq;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_StoresDrugInfoView_SupplierDetails : System.Web.UI.Page
{
    protected string            SupplierCode     = string.Empty;            // Supplier code          
    protected string            NSVCode          = string.Empty;            // NSV code for product to display
    protected MoneyDisplayType  moneyDisplayType = MoneyDisplayType.Show;   // If prices\cost values are to be displayed

    protected void Page_Load(object sender, EventArgs e)
    {
        // Initialise the Session
        int sessionID = int.Parse(Request.QueryString["SessionID"]);
        int siteID    = int.Parse(Request.QueryString["SiteID"]);
        SessionInfo.InitialiseSessionAndSiteID ( sessionID, siteID );

        // Load in the query string parameters
        SupplierCode     = Request.QueryString["SupplierCode"];
        NSVCode          = Request.QueryString["NSVCode"];
        moneyDisplayType = (Request.QueryString["HideCost"] == "1") ? MoneyDisplayType.HideWithLeadingSpace : MoneyDisplayType.Show;

        lblTaxRate.Text = string.Format(lblTaxRate.Text, PharmacyCultureInfo.SalesTaxName);

        // Load supplier information
        WSupplier suppliers = new WSupplier();
        suppliers.LoadByCodeAndSiteID(SupplierCode, siteID);

        // Load supplier profile information
        WSupplierProfile supplierProfileProcessor = new WSupplierProfile();
        supplierProfileProcessor.LoadBySiteIDSupplierAndNSVCode(siteID, SupplierCode, NSVCode);
        WSupplierProfileRow profile = supplierProfileProcessor.FirstOrDefault();

        // Load product information
        WProductRow product = WProduct.GetByProductAndSiteID(NSVCode, siteID); // 24Jan17 XN 126634 Replaced load and find with Get
        
        WExtraDrugDetail extraDrugInfo = new WExtraDrugDetail();
        extraDrugInfo.LoadBySiteIDNSVCodeAndSupCode(siteID, this.NSVCode, this.SupplierCode);
        
        if (suppliers.Any())
        {
            // Update supplier specific information
            txtSupplierCode.Text = suppliers[0].Code;
            txtSupplierName.Text = suppliers[0].FullName;
            txtCostCentre.Text   = suppliers[0].CostCentre;
            txtOrderMethod.Text  = suppliers[0].Method.ToString();

            // Update supplier addresses, phone, and fax
            txtSupplierAddress.Text = suppliers[0].SupAddress.Trim();
            txtSupplierPhone.Text   = suppliers[0].SupTelNo;
            txtSupplierFax.Text     = suppliers[0].SupFaxNo;

            txtContractAddress.Text = suppliers[0].ContractAddress.Trim();
            txtContractPhone.Text   = suppliers[0].ContTelNo;
            txtContractFax.Text     = suppliers[0].ContFaxNo;

            txtInvoiceAddress.Text  = suppliers[0].InvAddress.Trim();
            txtInvoicePhone.Text    = suppliers[0].InvTelNo;
            txtInvoiceFax.Text      = suppliers[0].InvFaxNo;
        }

        if (profile != null)
        {
            // Update supplier profile information
            txtNSVCode.Text             = profile.NSVCode;
            txtSupplierTradename.Text   = profile.SupplierTradename;
            txtContractNo.Text          = profile.ContractNumber;
            txtContractPrice.Text       = profile.ContractPrice.ToMoneyString(moneyDisplayType);

            if (String.IsNullOrEmpty((profile.ContractNumber)) == false)
            {
                // Display the currently active or the last expired contract date and time 24Jan17 XN 126634 
                WExtraDrugDetailRow latestExtraDrugDetial = extraDrugInfo.FindLastByActiveOrExpired();
                if (latestExtraDrugDetial != null)
                {
                    txtContactStartDate.Text = latestExtraDrugDetial.DateOfChange.ToPharmacyDateString();
                    txtContactEndDate.Text = latestExtraDrugDetial.StopDate.ToPharmacyDateString();
                    if (latestExtraDrugDetial.IsExpired)
                        txtContactEndDate.CssClass += " ContractExpired";
                }
            }

            decimal reorderPackSize = profile.ReorderPackSize ?? 1;
            if (product.ConversionFactorPackToIssueUnits == 1)
                txtOuterSize.Text = string.Format("{0} {1}", reorderPackSize, product.PrintformV);
            else
                txtOuterSize.Text = string.Format("{0} x {1} {2}", reorderPackSize.ToString(WProduct.GetColumnInfo().ReorderPackSizeLength), product.ConversionFactorPackToIssueUnits, product.PrintformV);

            txtTaxRate.Text             = string.Format("{0} ({1})", profile.VATCode, profile.VATRate.ToPharmacyVATString());
            txtLastInvoiced.Text        = (profile.LastReconcilePriceExVatPerPack ?? 0m).ToMoneyString(moneyDisplayType);
            txtLastPaid.Text            = (profile.LastReceivedPriceExVatPerPack  ?? 0m).ToMoneyString(moneyDisplayType);
            txtGTIN.Text                = profile.EdiBarcode;                       // Added 24Jan17 XN 126634 
            txtLeadTime.Text            = profile.LeadTimeInDays.ToString("0.#");
            txtSupplierReference.Text   = profile.SupplierReferenceNumber;
        }
    }
}
