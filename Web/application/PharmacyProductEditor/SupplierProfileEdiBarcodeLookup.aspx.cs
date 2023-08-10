// -----------------------------------------------------------------------
// <copyright file=".cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Displays list of alternate barcodes for user to select from 
// Also has options None, and "Add Barcode.."
// (add barcode is why this is a custom look instead of a standard lookup)
// Add barcode will add a barcode to the list of alternate barcodes
// 
// The page expects the following URL parameters
// NSVCode         - NSV code to load
// SelectedBarcode - Selected supplier barcode
//
// Modification History:
// 18Jul16 XN  Created
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Linq;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using _Shared;

public partial class application_PharmacyProductEditor_SupplierProfileEdiBarcodeLookup : System.Web.UI.Page
{
    #region Member Variables
    /// <summary>NSVCode passed in as command parameter</summary>
    private string NSVCode;

    /// <summary>The barcode that should be selected by default</summary>
    private string selectedBarcode;
    #endregion

    /// <summary>Called when page is loaded</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        // Get parameters
        this.NSVCode         = this.Request["NSVCode"];
        this.selectedBarcode = this.Request["SelectedBarcode"] ?? string.Empty;
        
        if (!this.IsPostBack)
        {
            // Create table
            gcGrid.AddColumn("Barcode", 99, PharmacyGridControl.ColumnType.Text, PharmacyGridControl.AlignmentType.Left);

            gcGrid.AddRow();
            gcGrid.AddRowAttribute("Barcode", string.Empty);
            gcGrid.SetCell(0, "<None>");

            SiteProductDataRow spd = SiteProductData.GetBySiteIDAndNSVCode(SessionInfo.SiteID, NSVCode);
            foreach (var barcode in spd.GetAlternativeBarcode().OrderBy(b => b))
            {
                gcGrid.AddRow();
                gcGrid.AddRowAttribute("Barcode", barcode);
                gcGrid.SetCell(0, barcode);
            }
        
            gcGrid.AddRow();
            gcGrid.AddRowAttribute("Barcode", "Add");
            gcGrid.SetCell(0, "<Add Barcode...>");

            int selectedRowIndex = gcGrid.FindIndexByAttrbiuteValue("Barcode", selectedBarcode);
            gcGrid.SelectRow(Math.Max(selectedRowIndex, 0));

            tbSearch.Focus();
        }

        // Setup client side events
        this.tbSearch.Attributes["onkeyup"]     += "body_onkeyup(event)";
        this.tbSearch.Attributes["onpaste"]     += "filterList()";  
        this.tbAddBarcode.Attributes["onkeyup"] += "if (event.keyCode==13) { btnAdd_click(); }";
        this.tbAddBarcode.Attributes["onfocus"] += "this.select();";

        // Deal with __postBack events
        string   args      = Request["__EVENTARGUMENT"];
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' });

        switch (argParams[0])
        {
        case "SaveAlternateBarcode": 
            // Called when saving alternate barcodes
            if (this.ValidateAlternateBarcode())
            {
                this.SaveAlternateBarcode(); 
                this.ClosePage(this.tbAddBarcode.Text);
            }
            break;
        }
    }

    /// <summary>Validates the alternate barcode</summary>
    /// <returns>If barcode is valid</returns>
    protected bool ValidateAlternateBarcode()
    {
        WProduct products = new WProduct();
        products.LoadByProductAndSiteID(this.NSVCode, SessionInfo.SiteID);
        WProductQSProcessor processor = new WProductQSProcessor(products, new [] { SessionInfo.SiteID });
        string error;

        if (!processor.ValidateAlternateBarcode(tbAddBarcode, string.Empty, out error))
        {
            divAddError.InnerText = error;
            return false;
        }

        return true;
    }

    /// <summary>Save the alternate barcode</summary>
    protected void SaveAlternateBarcode()
    {
        var newBarcode = tbAddBarcode.Text.Trim();

        // Get product to add barcodes to
        SiteProductData spd = new SiteProductData();
        spd.LoadBySiteIDAndNSVCode(SessionInfo.SiteID, this.NSVCode);

        // Write to log
        WPharmacyLog log = new WPharmacyLog();
        log.BeginRow(WPharmacyLogType.LabUtils, this.NSVCode);
        log.AppendLineDetail("Added alternate barcode(s): " + newBarcode);
        log.EndRow();

        // And save
        using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
        {
            log.Save();
            spd.AddAlias(spd[0].SiteProductDataID, "AlternativeBarcode", newBarcode, true);
            trans.Commit();
        }
    }
}