//===========================================================================
//
//					SupplierToContractEditor.aspx.cs
//
//  Allows user to select which parts of the CMU contract they want to select.
//
//  They can also select which the date range the CMU contract comes into
//  affect (see ContractProcessor for more details
//
//  The user can select which sites to replicate the contract to this is controlled
//  by ICW settings
//  Pharamcy.ContractEditor.SelectGTINByDefault - If GTIN is selected by default
//
//  The page expects the following URL parameters
//  SessionID               - ICW session ID
//  AscribeSiteNumber       - Site number
//  NSVCode                 - Drug contract is for
//  PharmacyCMUContractID   - CMU contract ID
//  WSupplierProfileID      - Supplier profile contract is linked to (optional to force user to select one)
//  HideCost                - (Optional) if costs are to be hidden default is false
//  ReplicateToSiteNumbers  - Which site contract information can be replicated to
//  SiteNumbersSelectedByDefault - Site selected for replication by default
// 
//  Usage:
//  SupplierToContractEditor.aspx?SessionID=123&AscribeSiteNumber=3232&NSVCode=DUV324H&PharmacyCMUContractID=45
//
//	Modification History:
//	02Aug13 XN   24653 Created
//  30Apr14 XN   88842 Small update to Save for Supplier Reference.
//  28Oct14 XN   100212 Control of is tradename field is done if DSS item
//  08Jun15 XN  119361 Moved settings SitesAllowedForReplciation and SiteNumbersSelectedByDefault to 
//              desktop parameters ReplicateToSiteNumbers
//              DetermineIfSiteValidForReplication moved from ContractEditorSettings to ContractProcessor
//  25Jul16 XN  126634 Added EDIBarcode, Validation changed to use ErrorWarningList
//  10Oct16 XN  164385, 164386 CMU contract import warn if barcode is wrong, GTIN as EDI barcode
//  01Feb18 NS  Bug# 203675-Pharmacy CMU contract editor - does not support 12 or 14 digit barcodes
//  07Feb18 DR  Bug 204021 - Pharmacy CMU contract editor - Set GTIN as barcode field available when it should not be
//  12Feb18 DR  Bug 204642 - Pharmacy CMU contract editor - Replace the "Yes" text for GTIN and EDI Barcode with their actual values
//  13Feb18 DR  Bug 204951 - Pharmacy CMU contract editor - Further changes to wording
//  29Mar18 DR  Bug 205805 - CMU contract editor - The Tradename field is not shown if try and edit details more than once
//  06Apr18 DR  Bug 205805 - CMU contract editor - The Tradename field is not shown if try and edit details more than once
//                         - Include AMPP Indicator 
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.quesscrllayer;

public partial class application_ContractInformation_SupplierToContractEditor : System.Web.UI.Page
{
    #region Constants
    private static readonly string TodayStartText = "Today";
    private static readonly string EmptyEndText   = "Forever";
    #endregion

    #region Member Variables
    protected int               _pharmacyCMUContractID;
    protected int               _WSupplierProfileID;
    protected string            _NSVCode;
    protected MoneyDisplayType  _moneyDisplayType = MoneyDisplayType.Show;
    protected string            _supCode;
    protected bool              _isAMPP;

    /// <summary>List of sites that are allowed for replication 08Jun15 XN 119361</summary>
    private List<int> replicateToSiteNumbers;

    /// <summary>List of sites selected by default for replication 08Jun15 XN 119361</summary>
    private List<int> siteNumbersSelectedByDefault;
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, null);

        // Get URL parameter
        this._pharmacyCMUContractID         = int.Parse(this.Request["PharmacyCMUContractID"]);
        this._WSupplierProfileID            = string.IsNullOrEmpty(this.Request["WSupplierProfileID"]) ? -1 : int.Parse(this.Request["WSupplierProfileID"]);
        this._NSVCode                       = this.Request["NSVCode"];
        this._moneyDisplayType              = (this.Request.QueryString["HideCost"] == "1") ? MoneyDisplayType.HideWithLeadingSpace : MoneyDisplayType.Show;
        this._supCode                       = hfSupCode.Value;
        this._isAMPP                        = string.IsNullOrEmpty(hfIsAMPP.Value) ? false : Convert.ToBoolean(hfIsAMPP.Value);
        
        var replicateToSites = Site2.Instance().FindBySiteNumber(this.Request["ReplicateToSiteNumbers"], true, CurrentSiteHandling.AtStart);
        this.replicateToSiteNumbers       = replicateToSites.Select(s => s.SiteNumber).ToList();
        this.siteNumbersSelectedByDefault = replicateToSites.FindBySiteNumber(this.Request["SiteNumbersSelectedByDefault"], allowAll: true).Select(s => s.SiteNumber).ToList();

        //Bug 184323 : EDI barcode should not be depenant on setting D|WINORD..EnableEDILinkCode
        //trEdiBarcode.Visible = Winord.EnableEdiLinkCode;    //  25Jul16 XN  126634

        if (!this.IsPostBack)
        {
            // Load supplier profile and get sup code so can be used by rest of system
            WSupplierProfileRow profileRow = WSupplierProfile.GetByWSupplierProfileID(_WSupplierProfileID);
            if (profileRow != null)
                _supCode = profileRow.SupplierCode;

            // Populate screen
            PopulateCMUData();
            PopulateAscribeData();
            PopulateSelectedData();
            PopulateSiteList();
            UpdateReplicateToSiteList();
        }

        // Deal with __postBack events
        string   args      = Request["__EVENTARGUMENT"];
        string[] argParams = new string[0];
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        if (argParams.Length > 0)
        {
            switch (argParams[0])
            {
            case "SelectedNewSites":    
                // When used selects new set of sites updates the site list
                UpdateReplicateToSiteList();
                PopulateSelectedData();         //  25Jul16 XN  126634 Added as EDI Barcode can depend on the sites selected
                break;

            case "SelectNewSupplierProfile":
                // When user select new supplier profile get supplier code and update then page
                {
                int wsupplierProfileID = int.Parse(argParams[1]);
                WSupplierProfileRow supplierProfileRow  = WSupplierProfile.GetByWSupplierProfileID(wsupplierProfileID);
                _supCode = supplierProfileRow.SupplierCode;                
                PopulateAscribeData();
                PopulateSelectedData();
                PopulateSiteList();
                UpdateReplicateToSiteList();
                }
                break;

            case "SelectNewSupplier":
                // When user select new supplier update the page
                {
                _supCode = argParams[1];
                PopulateAscribeData();
                PopulateSelectedData();
                PopulateSiteList();
                UpdateReplicateToSiteList();
                }
                break;

            case "Save":
                // Save page after warning message
                Save();
                break;
            }
        }

        hfSupCode.Value = _supCode;
        hfIsAMPP.Value  = _isAMPP.ToString();
    }

    /// <summary>Called when save button is clicked (validates and saves)</summary>
    protected void btnSave_OnClick(object sender, EventArgs e)
    {
        if (Validate())
            Save();
    }
    
    /// <summary>
    /// Called when one of the check boxes for selecting data to import is ticked
    /// Will update the middle colum or propsed values
    /// </summary>
    protected void importDataCheckBox_OnCheckedChanged(object sender, EventArgs e)
    {
        PopulateSelectedData();
    }
    #endregion

    #region Private Methods
    /// <summary>
    /// Populate all the ascribe data in the from
    /// This is the existing contract information read from the WSupplierProfile, and WExtraDrugDetail tables
    /// </summary>
    private void PopulateAscribeData()
    {
        DateTime today = DateTime.Now.ToStartOfDay();

        // Load WProudct data
        WProductRow productRow = WProduct.GetByProductAndSiteID(_NSVCode, SessionInfo.SiteID);
        if (productRow == null)
            throw new ApplicationException(string.Format("Invalid NSVCode: {0}", _NSVCode));

        // Load supplier profile data
        // If none exist create blank one (so easier to process)
        WSupplierProfile supplierprofile = new WSupplierProfile();
        supplierprofile.LoadBySiteIDSupplierAndNSVCode(SessionInfo.SiteID, _supCode, _NSVCode);
        if (!supplierprofile.Any())
        {
            WSupplierProfileRow supplierprofileRow = supplierprofile.Add(); 
            supplierprofileRow.SiteID              = SessionInfo.SiteID;
            supplierprofileRow.NSVCode             = productRow.NSVCode;
            supplierprofileRow.SupplierTradename   = productRow.Tradename;  // 28Oct14 XN  100212 Set SupplierTradename to product tradename by default (needed for WSupplierProfileQSProcessor)
        }
        bool isCurrentSupplierPrimarySupplier = supplierprofile[0].SupplierCode.EqualsNoCaseTrimEnd(productRow.SupplierCode);

        // Load supplier data
        // If none exist create blank one (so easier to process)
        WSupplier supplier = new WSupplier();
        supplier.LoadByCodeAndSiteID(_supCode, SessionInfo.SiteID);
        if (!supplier.Any())
            supplier.Add();

        // Load extra drug detail data
        WExtraDrugDetail extraDrugDetail = new WExtraDrugDetail();
        extraDrugDetail.LoadBySiteIDNSVCodeAndSupCode(SessionInfo.SiteID, _NSVCode, _supCode);

        // build up pack size and create ascribe headers
        decimal reorderPackSize = productRow.ReorderPackSize ?? 1;
        string  packSize;
        if (productRow.ConversionFactorPackToIssueUnits == 1)
            packSize = string.Format("{0} {1}", reorderPackSize, productRow.PrintformV);
        else
            packSize = string.Format("{0} x {1} {2}", reorderPackSize.ToString(WProduct.GetColumnInfo().ReorderPackSizeLength), productRow.ConversionFactorPackToIssueUnits, productRow.PrintformV);
        SetCell(AscribeHeader, "Pharmacy current data for:<br />{0}<br />Pack size: {1}<br />NSV code: {2}", productRow.ToString(), packSize, productRow.NSVCode);

        // Set supplier name
        ascSupplier.Text = supplier[0].ToString();

        WExtraDrugDetailRow activeDetailRow = extraDrugDetail.FindByIsActive();
        SetLabel(ascValid,           activeDetailRow == null || activeDetailRow.DateOfChange == null ? string.Empty : string.Format("{0} to {1}", activeDetailRow.DateOfChange.ToPharmacyDateString(), activeDetailRow.StopDate.ToPharmacyDateString()));
        SetLabel(ascStartDateOption, activeDetailRow == null ? string.Empty : activeDetailRow.DateUpdated_ByOvernighJob.ToPharmacyDateString() );
        SetLabel(ascEndDateOption,   activeDetailRow == null ? string.Empty : activeDetailRow.StopDate.ToPharmacyDateString()                  );

        // Set the GTIN code
        string cmuGTIN    = cbCmuGTINCode.Attributes["GTIN"];
        bool cmuGTINInUse = cmuGTIN.EqualsNoCaseTrimEnd(productRow.Barcode) || productRow.GetAlternativeBarcode().Any(b => cmuGTIN.EqualsNoCaseTrimEnd(b));
        SetLabel(ascGTINCodeOption, cmuGTINInUse ? cmuGTIN : string.Empty);

        SiteProductDataRow masterProduct = SiteProductData.GetByDrugIDAndMasterSiteID(productRow.DrugID, 0);

        _isAMPP = masterProduct != null && !string.IsNullOrEmpty(masterProduct.Tradename);

        string tradename;
        string tradenameHTML;
        if (masterProduct != null)
            tradename = string.IsNullOrEmpty(masterProduct.Tradename) ? supplierprofile[0].SupplierTradename : masterProduct.Tradename;
        else
            tradename = string.IsNullOrEmpty(supplierprofile[0].SupplierTradename) ? productRow.Tradename : supplierprofile[0].SupplierTradename;

        tradenameHTML = !_isAMPP ? tradename : "<span style='float: left;'>" + tradename + "</span><span style='float: right; color: white; background-color: coral; font-style: italic; font-weight: bold;'>&nbsp;AMPP&nbsp;</span>";

        SetCell(ascTradeName, tradenameHTML);
        SetLabel(ascTradenameOption, tradename);

        // Set profile specific settings
        SetLabel(ascContractReference,       supplierprofile[0].ContractNumber                                );
        SetLabel(ascPrice,                   supplierprofile[0].ContractPrice.ToMoneyString(_moneyDisplayType));
        SetLabel(ascContractReferenceOption, supplierprofile[0].ContractNumber                                );
        SetLabel(ascPriceOption,             supplierprofile[0].ContractPrice.ToMoneyString(_moneyDisplayType));
        SetLabel(ascIsPrimarySupplier,       isCurrentSupplierPrimarySupplier.ToYesNoString()                 ); 
   
        if (trEdiBarcode.Visible)
            SetLabel(ascEdiBarcodeOption, supplierprofile[0].EdiBarcode);   //  25Jul16 XN  126634 Added

        // Get pending detial if non exists create blank one (so easier to process)
        WExtraDrugDetailRow pendingDetailRow = extraDrugDetail.FindFirstByIsStillDue();
        if (pendingDetailRow == null)
        {
            pendingDetailRow = extraDrugDetail.Add();
            hfWExtraDrugDetailID_Pending.Value = string.Empty;
        }
        else
            hfWExtraDrugDetailID_Pending.Value = pendingDetailRow.WExtraDrugDetailID.ToString();
    }

    /// <summary>Updates the middle column of proposed values depending on what used has selected to import</summary>
    private void PopulateSelectedData()
    {
        bool importDataChecked = cbImportCmuData.Checked;

        // Load in the relavent WExtraDrugDetail row
        WExtraDrugDetail extraDrugDetail = new WExtraDrugDetail();
        if (string.IsNullOrEmpty(hfWExtraDrugDetailID_Pending.Value))
            extraDrugDetail.Add();
        else
        {
            int  wextraDrugDetailID_Pending = int.Parse(hfWExtraDrugDetailID_Pending.Value);
            extraDrugDetail.LoadByID(wextraDrugDetailID_Pending);
        }

        bool gtinOriginalCode = cbCmuGTINCode.Enabled;

        // Enabled the extra option check boxes
        cbCmuTradename.Enabled         = importDataChecked && !_isAMPP;
        cbCmuGTINCode.Enabled          = importDataChecked && string.IsNullOrEmpty(ascGTINCodeOption.Text.Replace("&nbsp;", string.Empty));
        cbCmuIsPrimarySupplier.Enabled = importDataChecked && !BoolExtensions.PharmacyParse(ascIsPrimarySupplier.Text);

        // If optional check boxes are disabled, then uncheck
        if (!cbCmuTradename.Enabled)
            cbCmuTradename.Checked = false;
        if (gtinOriginalCode != cbCmuGTINCode.Enabled)
            cbCmuGTINCode.Checked = cbCmuGTINCode.Enabled ? ContractEditorSettings.ContractEditor.SelectGTINByDefault : false;
        if (!cbCmuIsPrimarySupplier.Enabled)
            cbCmuIsPrimarySupplier.Checked = false;

        // Added Edi Barcode
        // Enabled if either current drug has GTIN, or cmu GTIN is selected, and any of the site don't have the GTIN selected
        // 25Jul16 XN  126634
        if (trEdiBarcode.Visible)
        {
            //string cmuGTIN = cbCmuGTINCode.Attributes["GTIN"];
            //var selectedSiteIDs = cblSites.CheckedItems().Select(li => int.Parse(li.Value)).Concat(new [] { SessionInfo.SiteID });
            //WSupplierProfile supplierProfiles = new WSupplierProfile();
            //supplierProfiles.LoadBySupplierAndNSVCode(this._supCode, this._NSVCode);
            //bool allSitesHaveEdiBarcodeSetToGtin = !supplierProfiles.Any() || supplierProfiles.Where(sp => selectedSiteIDs.Contains(sp.SiteID)).All(sp => sp.EdiBarcode == cmuGTIN); 164386 10Oct16 XN GTIN as EDI barcode should always be enabled

            //cbCumEdiBarcode.Enabled = importDataChecked && (BoolExtensions.PharmacyParse(ascGTINCodeOption.Text) || cbCmuGTINCode.Checked) && allSitesHaveEdiBarcodeSetToGtin;  164385 10Oct16 XN validate barcode correctly

            bool siteHasEdiBarcodeSetToGtin = cbCmuGTINCode.Attributes["GTIN"].EqualsNoCaseTrimEnd(ascEdiBarcodeOption.Text);

            cbCumEdiBarcode.Enabled = importDataChecked && (!string.IsNullOrEmpty(ascGTINCodeOption.Text.Replace("&nbsp;", string.Empty)) || cbCmuGTINCode.Checked) && !siteHasEdiBarcodeSetToGtin;
            if (cbCumEdiBarcode.Enabled == false)
                cbCumEdiBarcode.Checked = ContractEditorSettings.ContractEditor.SelectEdiBarcodeByDefault;
        }

        // Update the proposed column text
        // Will either be the a due WExtraDrugDetail item, or the cmu data if selected to import
        selectedContractReference.Text = importDataChecked                                   ? tbCmuContractReference.Text      : extraDrugDetail[0].NewContractNumber;
        selectedPrice.Text             = importDataChecked                                   ? tbCmuPrice.Text                  : extraDrugDetail[0].NewContractPrice.ToMoneyString(_moneyDisplayType);
        selectedStartDate.Text         = importDataChecked                                   ? tbCmuStartDate.Text              : extraDrugDetail[0].DateOfChange.ToPharmacyDateString();
        selectedEndDate.Text           = importDataChecked                                   ? tbCmuEndDate.Text                : extraDrugDetail[0].StopDate.ToPharmacyDateString();
        selectedGTINCode.Text          = importDataChecked && cbCmuGTINCode.Checked          ? cbCmuGTINCode.Attributes["GTIN"] : string.Empty;
        selectedIsPrimarySupplier.Text = importDataChecked && cbCmuIsPrimarySupplier.Checked ? "Yes"                            : string.Empty;
        selectedEdiBarcode.Text        = importDataChecked && cbCumEdiBarcode.Checked        ? cbCmuGTINCode.Attributes["GTIN"] : string.Empty;  // 25Jul16 XN  126634

        if (!_isAMPP)
            selectedTradename.Text = importDataChecked && cbCmuTradename.Checked ? cbCmuTradename.Text : extraDrugDetail[0].NewSupplierTradeName;
        else
            selectedTradename.Text = string.Empty;
    }

    /// <summary>Populate CMU data in the form</summary>
    private void PopulateCMUData()
    {
        DateTime today = DateTime.Now.ToStartOfDay();

        // Load in data
        CMUContractRow cmuContractRow = CMUContract.GetByID(_pharmacyCMUContractID);
        if (cmuContractRow == null)
            throw new ApplicationException(string.Format("Invlaid PharmacyCMUContractID: {0}", _pharmacyCMUContractID));
            
        SetCell(CMUHeader, "Contract data for:<br />{0}<br />Pack size: {1}&nbsp;&nbsp;&nbsp;&nbsp;Supplier: {2}<br />NPC code: {3}<br />", cmuContractRow.GenericDescription, 
                                                                                                                                            cmuContractRow.PackSize, 
                                                                                                                                            cmuContractRow.SupplierCode, 
                                                                                                                                            cmuContractRow.NPCCode);

        SetLabel(cmuOrderFrom,           cmuContractRow.OrderFrom                            );
        SetLabel(cmuContractReference,   cmuContractRow.ContractCode                         );
        SetLabel(cmuPrice,               "{0} {1}", PharmacyCultureInfo.CurrencySymbol, cmuContractRow.PriceInPounds.ToString());
        SetLabel(cmuMinQty,              cmuContractRow.MinOrderQuantity                     );
        SetLabel(cmuValid,               "{0} to {1}", cmuContractRow.RecordStatusStartDate.ToPharmacyDateString(), cmuContractRow.RecordStatusEndDate.ToPharmacyDateString());
        SetLabel(cmuTradeName,           cmuContractRow.BrandName                            );
        SetLabel(cmuLeadTime,            cmuContractRow.LeadTime                             );
        SetLabel(cmuMinOrdValue,         cmuContractRow.MinTotalOrderValueFormattedString()  );
        SetLabel(cmuDeliveryCharge,      cmuContractRow.DeliveryInformation                  );

        tbCmuContractReference.Text = cmuContractRow.ContractCode;
        tbCmuPrice.Text             = string.Format("{0} {1}", PharmacyCultureInfo.CurrencySymbol, cmuContractRow.PriceInPounds.ToString());
        if (cmuContractRow.RecordStatusStartDate != null && cmuContractRow.RecordStatusStartDate > today)
            tbCmuStartDate.Text = cmuContractRow.RecordStatusStartDate.ToPharmacyDateString();
        else 
            tbCmuStartDate.Text = TodayStartText;
        tbCmuEndDate.Text           = cmuContractRow.RecordStatusEndDate.ToPharmacyDateString();
        cbCmuTradename.Text         = cmuContractRow.BrandName;

        cbCmuGTINCode.Text = string.Format("GTIN code {0}", cmuContractRow.GTIN);
        cbCmuGTINCode.Attributes.Add("GTIN", cmuContractRow.GTIN);
    }

    /// <summary>
    /// Populate the list of sites check list
    /// will add a check item for each site in setting Pharamcy.ContractEditor.SitesAllowedForReplciation
    /// But will disable the site if does not support the product, or the supplier
    /// </summary>
    private void PopulateSiteList()
    {
        // Remove current site from list  08Jun15 XN 119361
        var siteNumbersToReplicate = this.replicateToSiteNumbers.ToList();
        siteNumbersToReplicate.Remove(SessionInfo.SiteNumber);

        // Populate check list
        cblSites.Items.Clear();
        foreach (var s in ContractProcessor.DetermineIfSiteValidForReplication(siteNumbersToReplicate, this._NSVCode, this._supCode, true, false))
        {
            ListItem li = new ListItem(s.siteNumber.ToString("000"), s.siteID.ToString());
            switch (s.validState)
            {
            case ContractProcessor.SiteValid.Yes:
                li.Enabled  = true;
                li.Selected = this.siteNumbersSelectedByDefault.Contains(s.siteNumber);
                break;
            case ContractProcessor.SiteValid.NoSupportedDrug:
                li.Enabled  = false;
                li.Text = li.Text + " - Drug not found";
                break;
            case ContractProcessor.SiteValid.NoSupportedSupplier:
                li.Enabled  = false;
                li.Text = li.Text + " - Supplier not found";
                break;
            }

            cblSites.Items.Add(li);
        }
    }

    /// <summary>Updates the replicate to sites message depending on sites selected</summary>
    private void UpdateReplicateToSiteList()
    {
        StringBuilder sitesLabel = new StringBuilder();
        List<ListItem> checkBoxes = cblSites.Items.OfType<ListItem>().ToList();

        // List sites being replicated to
        IEnumerable<string> siteNumbersSelected = checkBoxes.Where(li => li.Selected).Select(li => li.Text.Split(' ')[0]);
        if (siteNumbersSelected.Any())
            sitesLabel.AppendFormat("Replicate to sites {0}", siteNumbersSelected.ToCSVString(","));
        else if (cblSites.Items.OfType<ListItem>().Any(c => c.Enabled))
            sitesLabel.Append("No sites selected for replication");
        else
            sitesLabel.Append("No sites available for replication");
        sitesLabel.Append("<br />");

        // List sites not replicated to
        IEnumerable<string> siteNumbersNotSelected = checkBoxes.Where(li => li.Enabled && !li.Selected).Select(li => li.Text.Split(' ')[0]);
        if (siteNumbersNotSelected.Any())
        {
            sitesLabel.AppendFormat("Will not replicate to sites {0}", siteNumbersNotSelected.ToCSVString(","));
            sitesLabel.Append("<br />");
        }

        // Show sites that are not available for replication
        IEnumerable<string> siteNumbersNotAvailable = checkBoxes.Where(li => !li.Enabled).Select(li => li.Text.Split(' ')[0]);
        if (siteNumbersNotAvailable.Any())
            sitesLabel.Append("Cannot replicate to sites " + siteNumbersNotAvailable.ToCSVString(", "));

        lbtSites.Text = sitesLabel.ToString();
    }

    /// <summary>
    /// Validate Form
    /// Added EDI Barcode, and replaced existing error handling with ErrorWarningList
    /// 25Jul16 XN 126634 
    /// </summary>
    private bool Validate()
    {
        ErrorWarningList errors = new ErrorWarningList();
        DateTime today        = DateTime.Today;
        DateTime maxDateTime  = DateTime.MaxValue;
        string tempStr, error;
        decimal tempDec;

        WExtraDrugDetailColumnInfo columnInfo = WExtraDrugDetail.GetColumnInfo();

        CMUContractRow cmuContractRow = CMUContract.GetByID(_pharmacyCMUContractID);
        if (cmuContractRow == null)
            throw new ApplicationException(string.Format("Invalid PharmacyCMUContractID: {0}", _pharmacyCMUContractID));

        // Check if anything selected
        if (!this.GetAllControlsByType<CheckBox>().Any(cb => (cb.Parent is HtmlTableCell) && cb.Checked))
            errors.AddError("No changes selected.");

        // Contract reference
        if (!Validation.ValidateText(selectedContractReference, "Contract reference", typeof(string), true, columnInfo.NewContractNumberLength, out error))
            errors.AddError(error);

        // Contract Price 
        tempStr = selectedPrice.Text.Replace(PharmacyCultureInfo.CurrencySymbol, string.Empty).Trim();
        if (!string.IsNullOrEmpty(tempStr) && !decimal.TryParse(tempStr, out tempDec))
            errors.AddError("Invalid price");

        // Date range
        DateTime dtCMUStartDate      = DateTimeExtensions.Max(cmuContractRow.RecordStatusEndDate ?? today, today);
        DateTime dtCMUEndDate        = cmuContractRow.RecordStatusEndDate ?? maxDateTime;
        DateTime dtSelectedStartDate = selectedStartDate.Text == string.Empty || selectedStartDate.Text == TodayStartText ? today       : DateTimeExtensions.PharmacyParse(selectedStartDate.Text).Value;
        DateTime dtSelectedEndDate   = selectedEndDate.Text   == string.Empty || selectedEndDate.Text   == EmptyEndText   ? maxDateTime : DateTimeExtensions.PharmacyParse(selectedEndDate.Text  ).Value;

        if (dtSelectedEndDate < dtSelectedStartDate)
            errors.AddError("End date before start date");
        if (dtSelectedEndDate < dtCMUEndDate)
            errors.AddWarning("Proposed end date before CMU end date");
        if (dtSelectedStartDate > dtCMUStartDate)
            errors.AddWarning("Proposed start date after CMU start date");

        // Tradename
        //if (cbCmuTradename.Checked && !Validation.ValidateText(selectedTradename, "Tradename", typeof(string), false, columnInfo.NewSupplierTradeNameNumberLength, out error)) 28Oct14 XN  100212
        if (!_isAMPP && cbCmuTradename.Checked && !Validation.ValidateText(selectedTradename, "Tradename", typeof(string), false, columnInfo.NewSupplierTradeNameNumberLength, out error))
            errors.AddError(error);

        // GTNI code
        string cmuGTIN = cbCmuGTINCode.Attributes["GTIN"];     

        if (cbCmuGTINCode.Checked && !String.IsNullOrWhiteSpace(cmuGTIN))
        {
            string errorMsg = string.Empty;
            if (!Barcode.ValidateGTINBarcode(cmuGTIN, false, out errorMsg))
                errors.AddError(errorMsg);
        }

        // Use GTIN code for EDI link
        if (trEdiBarcode.Visible && !errors.Any() && cbCumEdiBarcode.Checked)
        {
            QSValidationList validationInfo = new QSValidationList();
            foreach (var siteID in this.cblSites.CheckedItems().Select(li => int.Parse(li.Value)))
            {
                var supplierProfile = WSupplierProfile.GetBySiteIDSupplierAndNSVCode(siteID, this._NSVCode, this._supCode);
                var originalBarocde = (supplierProfile == null ? string.Empty : supplierProfile.EdiBarcode);
                WSupplierProfileQSProcessor.CheckIfEdiBarcodeInUse(siteID, this._NSVCode, this._supCode, originalBarocde, cmuGTIN, dtSelectedStartDate, dtSelectedEndDate, "EDI Barcode", validationInfo);
            }
            foreach (var v in validationInfo)
            {
                if (v.error)
                    errors.AddError(v.siteID, v.message);
                else
                    errors.AddWarning(v.siteID, v.message);
            }
        }

        // Display error or warning
        if (errors.GetErrors().Any())
        {
            string msg = errors.GetErrors().ToHtml() + "<br /><p>Updates were not saved</p>";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "BrokenRules", string.Format("alertEnh(\"{0}\");", msg), true);
        }
        else if (errors.GetWarnings().Any())
        {
            int width = 50 + errors.GetLongestCharLength() * 7;
            string script = string.Format("confirmEnh(\"<div style='max-height:500px'>{0}<br /><p>Do you want to continue?</p></div>\", false, function() {{ __doPostBack('upMain', 'Save'); }}, undefined, '{1}px');",  errors.ToHtml(), width);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "BrokenRules", script, true);
        }

        return !errors.Any();
    }

    /// <summary>Saves the CMU data an then closes the form</summary>
    private void Save()
    {
        // Check if no changes then nothing to save
        if (!this.GetAllControlsByType<CheckBox>().Any(cb => (cb.Parent is HtmlTableCell) && cb.Checked))
        {
            this.ClosePage(true);
            return;
        }

        string priceStr = selectedPrice.Text.Replace(PharmacyCultureInfo.CurrencySymbol, string.Empty).Trim();
        ContractInfo contractInfo = new ContractInfo();
        contractInfo.Barcode            = cbCmuGTINCode.Enabled && cbCmuGTINCode.Checked ? cbCmuGTINCode.Attributes["GTIN"] : null;
        contractInfo.contractPrice      = string.IsNullOrEmpty(priceStr) ? (decimal?)null : Decimal.Parse(priceStr) * 100;
        contractInfo.contractReference  = selectedContractReference.Text;
        contractInfo.startDate          = selectedStartDate.Text == string.Empty || selectedStartDate.Text == TodayStartText ? DateTime.Today : DateTimeExtensions.PharmacyParse(selectedStartDate.Text).Value;
        contractInfo.endDate            = selectedEndDate.Text   == string.Empty || selectedEndDate.Text   == EmptyEndText   ? (DateTime?)null: DateTimeExtensions.PharmacyParse(selectedEndDate.Text  );
        contractInfo.NSVCode            = _NSVCode;
        contractInfo.setDefaultSupplier = cbCmuIsPrimarySupplier.Enabled && cbCmuIsPrimarySupplier.Checked;
        contractInfo.SupCode            = _supCode;
        contractInfo.supplierTradename  = !_isAMPP ? selectedTradename.Text : null;  // 28Oct14 XN 100212 Control of is tradename field is done if DSS item
        contractInfo.supplierReference  = string.Empty; // 30Apr14 XN 88842 Added Supplier Reference
        contractInfo.ediBarcode         = trEdiBarcode.Visible && cbCumEdiBarcode.Checked ? cbCmuGTINCode.Attributes["GTIN"] : null;

        contractInfo.siteIDs.AddRange(cblSites.CheckedItems().Select(li => int.Parse(li.Value)));
        contractInfo.siteIDs.Add(SessionInfo.SiteID);

        using (ContractProcessor processor = new ContractProcessor())
        {
            try
            {
                // Lock and save data
                processor.Lock(contractInfo);
                processor.Update(contractInfo);
              
                // Get the WSupplierProfileID of the updated item
                string wsupplierPofileID = null;
                WSupplierProfileRow profileRow = WSupplierProfile.GetBySiteIDSupplierAndNSVCode(SessionInfo.SiteID, _supCode, _NSVCode);
                    if (profileRow != null)
                        wsupplierPofileID = profileRow.WSupplierProfileID.ToString();
                // Close page (returning WSupplierProfileID)
                this.ClosePage(wsupplierPofileID, true);
            }
            catch (LockException lockException)
            {
                string script = string.Format("alertEnh('Records in use by user \"{0}\" (EntityID: {1}).\nPlease try again in a few minutes?')", lockException.GetLockerUsername(), lockException.GetLockerEntityID());
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "LockException", script, true);
            }
        }
    }

    private void SetLabel(Label label, string format, params object[] args)
    {
        string text = string.Format(format ?? string.Empty, args).Trim();
        label.Text = string.IsNullOrEmpty(text) ? "&nbsp;" : text;
    }

    private void SetCell(HtmlTableCell cell, string format, params object[] args)
    {
        string text = string.Format(format ?? string.Empty, args).Trim();
        cell.InnerHtml = string.IsNullOrEmpty(text) ? "&nbsp;" : text;
    }
    
    #endregion
}