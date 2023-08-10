//===========================================================================
//
//					    ManualContractEditor.aspx.cs
//
//  Allows user to manually edit a contract.
//
//  The page expects the following URL parameters
//  SessionID               - ICW session ID
//  AscribeSiteNumber       - Site number
//  NSVCode                 - NSV code 
//  WSupplierProfileID      - (optional) WSupplierProfileID
//  SupCode                 - (optional) supplier code
// 
//  Usage:
//  ManualContractEditor.aspx?SessionID=123&AscribeSiteNumber=3232&NSVCode=DFH574S
//
//	Modification History:
//	09Aug13 XN   24653 Created
//  03Feb14 XN   82433 Moved main part of contract editor to control so can 
//               be used in Pharmacy Product Editor.
//  28Oct14 XN  100212
//===========================================================================
using System;
using System.Linq;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;

public partial class application_ContractEditor_ManualContractEditor : System.Web.UI.Page
{
    private string NSVCode;
    private string supCode;

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        NSVCode = Request["NSVCode"];
        supCode = Request["SupCode"];

        if (!this.IsPostBack)
        {
            PopulateHeader();
            contractEditor.Initalise(NSVCode, supCode);
        }
    }

    /// <summary>Called when supplier code is updated (updates the header)</summary>
    protected void contractEditor_OnSupplierCodeUpdated(string NSVCode, string supCode)
    {
        this.supCode = supCode;                
        PopulateHeader();
    }

    /// <summary>Called when contract editor has validate successfully all the data (will then save)</summary>
    protected void contractEditor_OnValidated()
    {
        contractEditor.Save();
    }

    /// <summary>Called when contract editor has saved the data (closes the form)</summary>
    protected void contractEditor_OnSaved()
    {
        this.ClosePage(true);
    }

    /// <summary>
    /// Called when the save button is clicked 
    /// Validates and save the data
    /// </summary>
    protected void btnSave_OnClick(object sender, EventArgs e)
    {
        contractEditor.Validate();                
    }
    #endregion

    private void PopulateHeader()
    {
        SiteProductDataRow siteProductDataRow = SiteProductData.GetBySiteIDAndNSVCode(SessionInfo.SiteID, NSVCode);
        if (siteProductDataRow == null)
            throw new ApplicationException("Invalid NSVCode " + NSVCode);

        // Load supplier profile (if none exists add empty one as makes easier to code)
        WSupplierProfile supplierProfile = new WSupplierProfile();
        if (!string.IsNullOrEmpty(supCode))
            supplierProfile.LoadBySiteIDSupplierAndNSVCode(SessionInfo.SiteID, supCode, NSVCode);
        if (!supplierProfile.Any())
        {
            WSupplierProfileRow row = supplierProfile.Add();
            row.SiteID              = SessionInfo.SiteID;
            row.NSVCode             = siteProductDataRow.NSVCode;
            row.SupplierTradename   = siteProductDataRow.Tradename; // Set tradename from product (needed for WSupplierProfileQSProcessor)
        }

        // build up packSize
        string packSize = supplierProfile[0].ReorderPackSizeAsFormattedString(siteProductDataRow.ConversionFactorPackToIssueUnits, siteProductDataRow.PrintformV);
        AscribeHeader.InnerHtml = string.Format("{0}<br />Pack size: {1}<br />NSV code: {2}", siteProductDataRow.ToString(), packSize, NSVCode);
        
        // Display tradename if user cannot edit    28Oct14 XN  100212
        WSupplierProfileQSProcessor processor = new WSupplierProfileQSProcessor(supplierProfile, new [] { SessionInfo.SiteID });
        if ( processor.GetDSSMaintainedDataIndex().Contains(WSupplierProfileQSProcessor.DATAINDEX_TRADENAME) )
            AscribeHeader.InnerHtml += "<br />Trade name: " + (string.IsNullOrWhiteSpace(supplierProfile.First().SupplierTradename) ? siteProductDataRow.Tradename : supplierProfile.First().SupplierTradename).Trim();
    }
}
