//===========================================================================
//
//						         ProductInfoPanel.aspx.cs
//
//  Displays information about a site's drug.
// 
//  The form allow notes to be edits by pressing the edit button, or pressing F2.
//
//  Call the page with the follow parameters
//  SessionID               - ICW session ID
//  AscribeSiteNumber       - Pharmacy site
//  HideCost                - 1 to hide prices\costs, else 0
//  NSVCode                 - NSV code of pharmacy product to display.
//  Robot                   - Name of robot if item is robot item (optional)
//  
//  Usage:
//  ProductInfoPanel.aspx?SessionID=123&AscribeSiteNumber=504&HideCost=1&NSVCode=AAA0001
//
//	Modification History:
//	23Jul09 XN  Written
//  08Apr10 XN  F0083101 Tradename is too long
//  29Apr10 XN  Replace old buisness layer classes with data layer classes
//  04Aug10 XN  F0088717 Added stores only row to product info panel along 
//              bottom as InUse can't be "S".
//  15Jul11 XN  F0118239 Add robot stock level to F4 screen
//  11Jan13 XN  Changed StoresDrugInfoViewSetting.Settings.Instance with StoresDrugInfoViewSettingSetting
//  01Nov13 XN  Knock on changes after removal of ProductObjectInfo
//  18Dec13 XN  78339 Knock on changes after making LeadTimeInDays nullable
//  12Sep14 XN  100201 Got LoadProductInfo to used GetTradename
//  11Oct16 XN  156490 F4 product information screens - log changes made using the F2 Notes 'Edit' button
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.basedatalayer;

public partial class application_StoresDrugInfoView_ProductInfoPanel : System.Web.UI.Page
{
    protected string            NSVCode         = string.Empty;            // NSV code for product to display
    protected MoneyDisplayType  moneyDisplayType= MoneyDisplayType.Show;   // If prices\cost values are to be displayed
    protected string            robotName       = string.Empty;            // name of robot that item is in
    //protected string            callbackResult         = string.Empty;   11Oct16 XN 156490 removed             // results to return from a RaiseCallbackEvent callback 

    protected void Page_Load(object sender, EventArgs e)
    {
        //// Add callserver function to the script 11Oct16 XN  156490 removed
        //String cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
        //String callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
        //Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "CallServer", callbackScript, true);

        // Initalise the Session
        int sessionID = int.Parse(Request.QueryString["SessionID"]);
        int siteID    = int.Parse(Request.QueryString["SiteID"]);
        SessionInfo.InitialiseSessionAndSiteID ( sessionID, siteID );

        // Load in the query string parameters
        NSVCode          = Request.QueryString["NSVCode"];
        moneyDisplayType = (Request.QueryString["HideCost"] == "1") ? MoneyDisplayType.HideWithLeadingSpace : MoneyDisplayType.Show;

        // Load robot item enquiry issues
        robotName = Request.QueryString["Robot"] ?? string.Empty;
        
        if (!IsPostBack)
            LoadProductInfo();

        // Deal with __postBack events 11Oct16 XN 156490
        string   args      = Request["__EVENTARGUMENT"];
        string[] argParams = new string[0];
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        if (argParams.Length > 0)
        {
            switch (argParams[0])
            {
            case "SaveNote":  
                var note = argParams.Skip(1).ToCSVString(":");
                if (ValidateNote(note) && SaveNote(note))
                    lblNotesData.Text = note;
                else
                    lblNotesData.Text = WProduct.GetByProductAndSiteID(this.NSVCode, SessionInfo.SiteID).Notes;
                break;
            }
        }
    }

    /// <summary>Validate the note 11Oct16 XN 156490</summary>
    /// <param name="note">Note text</param>
    /// <returns>If valid</returns>
    private bool ValidateNote(string note)
    {
        bool ok = true;

        if (note.Length > WProduct.GetColumnInfo().NotesLength)
        {
            string script = string.Format("alertEnh('Notes must be less than {0} characters', function() {{ lblEditNotes_onclick(\"{1}\"); }}); ", WProduct.GetColumnInfo().NotesLength, note);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "validateFailed", script, true);
            ok = false;
        }

        return ok;
    }

    /// <summary>Save the note back to the DB 11Oct16 XN 156490</summary>
    /// <param name="note">note text</param>
    /// <returns>If saved</returns>
    private bool SaveNote(string note)
    {
        bool saved = false;

        try
        {
            using (ProductStock productStock = new ProductStock())
            {
                productStock.RowLockingOption = LockingOption.HardLock;
                productStock.LoadBySiteIDAndNSVCode(this.NSVCode, SessionInfo.SiteID);
                productStock[0].Notes = note;
                productStock.Save(saveToPharmacyLog: true);
                saved = true;
            }
        }
        catch (LockException ex)
        {
            string script = string.Format("alertEnh('Records in use by user \"{0}\" (EntityID: {1}).<br />Please try again in a few minutes?')", ex.GetLockerUsername(), ex.GetLockerEntityID());
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", script, true);
        }

        return saved;
    }

    /// <summary>
    /// Displays the product info in 3 columns
    /// </summary>
    protected void LoadProductInfo()
    {
        // Load the product information
        WProduct productProcessor = new WProduct();
        productProcessor.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID);        

        WProductRow product = productProcessor.FirstOrDefault(); 
        if (product == null)
            return;

        pnlProductInfoPanel.SetColumns(3);

        // Column 1
        pnlProductInfoPanel.SetColumnWidth(0, 34);

        pnlProductInfoPanel.AddLabel(0, "Cost:", "{0} for 1 x {1} {2}", product.AverageCostExVatPerPack.ToMoneyString(moneyDisplayType), product.ConversionFactorPackToIssueUnits, product.PrintformV);
        pnlProductInfoPanel.AddLabel(0, "NSV Code:",                    product.NSVCode);
        pnlProductInfoPanel.AddLabel(0, "Code:",                        product.Code);

        string locations = product.Location;
        if (!string.IsNullOrEmpty(product.Location2))
            locations += ", " + product.Location2;
        pnlProductInfoPanel.AddLabel(0, "Locations:", locations);

        // pnlProductInfoPanel.AddLabel(0, "Lead time:", "{0:0.#} days", product.LeadTimeInDays);   18Dec13	XN 78339
        pnlProductInfoPanel.AddLabel(0, "Lead time:", "{0:0.#} days", product.LeadTimeInDays ?? 0);

        string orderCycle;
        if (string.IsNullOrEmpty(product.OrderCycle))
            orderCycle = "Not on cyclical ordering";
        else
            orderCycle = string.Format("{0} every {1} days", product.OrderCycle, product.CycleLengthInDays);
        pnlProductInfoPanel.AddLabel(0, "Order cycle:", orderCycle);

        string tracking;
        switch (product.BatchTracking)
        {
        case BatchTrackingType.OnReceipt:                     tracking = "Batch number on receipt";       break;
        case BatchTrackingType.OnReceiptWithExpiry:           tracking = "Batch & expiry on receipt";     break;
        case BatchTrackingType.OnReceiptWithExpiryAndConfirm: tracking = "Batch/expiry on receipt/issue"; break;
        default:tracking = "Not on batch tracking";         break;
        }
        pnlProductInfoPanel.AddLabel(0, "Tracking:", tracking);

        // Add the supplier tradename (if too large then reduce the font size)
        //string supplierTradename = (product.SupplierTradename ?? string.Empty).Trim(); 12Sep14 XN 100201 If supplier tradename is blank default to tradename
        //string supplierTradename = (string.IsNullOrWhiteSpace(product.SupplierTradename) ? product.Tradename : product.SupplierTradename).Trim();  28Oct14 XN  100212
        string supplierTradename = product.GetTradename();
        pnlProductInfoPanel.AddLabel(0, "Tradename:", supplierTradename);
        if (supplierTradename.Length >= 30)
            pnlProductInfoPanel.SetValueStyles(0, pnlProductInfoPanel.GetLabelCount(0) - 1, "font-size:x-small; white-space: nowrap;");
        else if (supplierTradename.Length >= 25)
            pnlProductInfoPanel.SetValueStyles(0, pnlProductInfoPanel.GetLabelCount(0) - 1, "font-size:small; white-space: nowrap;");
        else
            pnlProductInfoPanel.SetValueStyles(0, pnlProductInfoPanel.GetLabelCount(0) - 1, "white-space: nowrap;");

        // Column 2
        pnlProductInfoPanel.SetColumnWidth(1, 34);

        string storesPack = string.IsNullOrEmpty(product.StoresPack) ? "pack" : product.StoresPack.ToLower();
        string stockLevel = string.Format("{0:0.##} {1} (or {2:0.##} {3})", product.StockLevelInIssueUnits, product.PrintformV, product.StockLevelInIssueUnits / product.ConversionFactorPackToIssueUnits, storesPack);
        pnlProductInfoPanel.AddLabel(1, "Stock Level:", stockLevel);

        if (!string.IsNullOrEmpty(robotName))
            pnlProductInfoPanel.AddNamedLabel(1, "RobotStockLevel", robotName + " Stock Level [F4]:", string.Empty);

        pnlProductInfoPanel.AddLabel(1, "Reorder Level:", "{0} {1}",    product.ReorderLevelInIssueUnits, product.PrintformV); 

        decimal reorderPackSize = product.ReorderPackSize ?? 1;
        string  outerSize;
        if (product.ConversionFactorPackToIssueUnits == 1)
            outerSize = string.Format("{0} {1}", reorderPackSize, product.PrintformV);
        else
            outerSize = string.Format("{0} x {1} {2}", reorderPackSize.ToString(WProduct.GetColumnInfo().ReorderPackSizeLength), product.ConversionFactorPackToIssueUnits, product.PrintformV);
        pnlProductInfoPanel.AddLabel(1, "Outer Sizing:",                outerSize);

        string outstanding;
        if ( product.OutstandingInIssueUnits == 0 )
            outstanding = string.Format ("{0:0.###} {1}", product.OutstandingInIssueUnits, product.PrintformV );
        else
            outstanding = string.Format ("{0:0.###} x {1} {2}", product.OutstandingInIssueUnits, product.ConversionFactorPackToIssueUnits, product.PrintformV );
        pnlProductInfoPanel.AddLabel(1, "Outstanding:",                 outstanding);

        pnlProductInfoPanel.AddLabel(1, "Annual usage:", "{0:0} {1}",   product.AnnualUsageInIssueUnits ?? 0, product.PrintformV);
        pnlProductInfoPanel.AddLabel(1, "Date last ordered:",           product.LastOrderedDate.ToPharmacyDateString());
        pnlProductInfoPanel.AddLabel(1, "Date last issued:",            product.LastIssuedDate.ToPharmacyDateString());

        // Column 3
        pnlProductInfoPanel.SetColumnWidth(2, 22);

        pnlProductInfoPanel.AddLabel(2, "Live:",                product.IfLiveStockControl.ToYesNoString());
        pnlProductInfoPanel.AddLabel(2, "Stocked:",             product.IsStocked.ToYesNoString());
        pnlProductInfoPanel.AddLabel(2, "In Use:",              product.InUse.ToYesNoString()); 
        pnlProductInfoPanel.AddLabel(2, "Stores Only:",         product.IsStoresOnly.ToYesNoString());
//        pnlProductInfoPanel.AddLabel(2, "Formulary:",           product.Formulary.ToString());
        pnlProductInfoPanel.AddLabel(2, "Formulary:",           StoresDrugInfoViewSetting.DisplayFormularyAsLetterOnly ? product.FormularyCode : product.FormularyType.ToString()); // 11Jan13 XN 38049 If setting is on then only display the formulary code directly from the DB
        pnlProductInfoPanel.AddLabel(2, "Cytotoxic:",           product.IsCytotoxic.ToYesNoString());
        pnlProductInfoPanel.AddLabel(2, "Reorder calculation:", product.ReCalculateAtPeriodEnd.ToYesNoString());    

        // Set notes
        lblNotesData.Text = product.Notes.Trim();

        // Display if product is on order waiting authorisation
        WOrder orderProcessor = new WOrder();
        orderProcessor.LoadBySiteIDNSVCodeAndFromDate ( SessionInfo.SiteID, product.NSVCode, null );
        lblWaitingAuth.Visible = orderProcessor.Any( i => (i.Status == OrderStatusType.WaitingAuthorisation) );
    }

    // 11Oct16 XN 156490 removed below and replaced with a __doPostBack
    ///// <summary>
    ///// Updates the text displayed in the notes field
    ///// </summary>
    //public void DisplayProductNote()
    //{
    //    // Can't assume the product is loaded as mabe called as part of an update
    //    WProduct productProcessor = new WProduct();
    //    productProcessor.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID);
    //    lblNotesData.Text = productProcessor[0].Notes.Trim();
    //}

    ///// <summary>
    ///// Validates the product notes and if okay saves to ProductStock table.
    ///// Called from the javascript via RaiseCallbackEvent, validation is error 
    ///// returned to the javascript through method GetCallbackResult
    ///// </summary>
    ///// <param name="productNotes">Notes to display</param>
    ///// <returns>Validation error message empty of notes saved okay</returns>
    //public string SaveProductNotes(string productNotes)
    //{
    //    // Validate product notes and if okay then save
    //    List<ValidationError> errorList = WProduct.ValidateNotes(SessionInfo.SiteID, NSVCode, productNotes);
    //    if (!errorList.Any())
    //        WProduct.UpdateNotes(SessionInfo.SiteID, NSVCode, productNotes);

    //    // Creare a multi line error message
    //    StringBuilder error = new StringBuilder();
    //    errorList.ForEach( i => error.AppendLine(i.ToString()) );
    //    return error.ToString();
    //}

    ///// <summary>
    ///// Call back event raised by client side java script
    ///// Call using javascript code CallServer('SaveProductNotes("Notes message")', '');
    ///// the results of the method called are returned by GetCallbackResult
    ///// </summary>
    ///// <param name="eventArgument">Event arguments</param>
    //public void RaiseCallbackEvent(String eventArgument)
    //{
    //    callbackResult = string.Empty;

    //    if (string.IsNullOrEmpty(eventArgument))
    //        return;
        
    //    // Extract the brackets for the method call
    //    int startIndex = eventArgument.IndexOf('(');
    //    int endIndex   = eventArgument.LastIndexOf(')');
    //    if ((startIndex < 0) || (endIndex < 0))
    //        return;

    //    // Get the method name and parameters
    //    string methodName = eventArgument.Substring(0, startIndex).Trim().ToLower();
    //    string parameter  = eventArgument.Substring(startIndex + 2, endIndex - startIndex - 3);

    //    // Call the appropriate method
    //    switch(methodName)
    //    {
    //    case "saveproductnotes": 
    //        callbackResult = SaveProductNotes(parameter); 
    //        break;
    //    }
    //}

    ///// <summary>
    ///// Returns the result of RaiseCallbackEvent
    ///// </summary>
    ///// <returns>result of RaiseCallbackEvent</returns>
    //public string GetCallbackResult()
    //{
    //    return callbackResult;
    //}
}
