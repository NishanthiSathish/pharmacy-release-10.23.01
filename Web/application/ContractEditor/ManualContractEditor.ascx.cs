//===========================================================================
//
//					      ManualContractEditor.aspx.cs
//  
//  Allows user to manually edit a contract.
//
//  The control supports the IQuesScrlControl interface for easy plug into 
//  Pharmacy Product Editor.  
//
//  Control relies on ManualContractEditor.js
//
//  Usage
//  In the HTML page you will needed to
//  <%@ Register src="ManualContractEditor.ascx" tagname="ManualContractEditor"  tagprefix="uc" %>
//  :
//  <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"               async></script>
//  <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
//  <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
//  <script type="text/javascript" src="script/ManualContractEditor.js"                         async></script>
//  :
//  <uc:ManualContractEditor ID="manualContractEditor" runat="server" OnValidated="manualContractEditor_OnValidated" OnSaved="manualContractEditor_OnSaved" />
//
//
//  Initialise the control
//  manualContractEditor.Initalise("DFE432D", "SUPP1"); 
//
//
//  To save the changes first call
//  manualContractEditor.Validation();
//
//  Next when control validates successfully it will fire event Validated
//  Use this to save.
//  manualContractEditor_OnValidated()
//  {
//      manualContractEditor.Save();
//  }
//
//  When the control has saved data it will fire event OnSaved
//  manualContractEditor_OnSaved()
//  {
//      ScriptManager.RegisterStartupScript(this, this.GetType(), "alert('Saved');", true);
//  }
//    
//	Modification History:
//  31Jan14	XN 82443 Extracted from ManualContractEditor.aspx
//  10Mar14 XN 85921 Script error in Maniual contract editor.
//  30Apr14 XN 88842 Added Supplier Reference
//  28Oct14 XN 100212 Control of is tradename field is done if DSS item
//  08Jun15 XN 119361 Moved settings SitesAllowedForReplciation and SiteNumbersSelectedByDefault to 
//              desktop parameters ReplicateToSiteNumbers
//              DetermineIfSiteValidForReplication moved from ContractEditorSettings to ContractProcessor
//  31Jul16 XN 126641 Added EDI Barcode
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
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;
using System.Collections;

public partial class ManualContractEditor : System.Web.UI.UserControl, IQSViewControl
{
    #region Member Variables
    /// <summary>List of sites that are allowed for replication 08Jun15 XN 119361</summary>
    private List<int> replicateToSiteNumbers;

    /// <summary>List of sites selected by default for replication 08Jun15 XN 119361</summary>
    private List<int> siteNumbersSelectedByDefault; 
    #endregion

    #region Private Properties
    private string NSVCode
    {
        get { return hfNSVCode.Value;  }
        set { hfNSVCode.Value = value; } 
    }

    private string SupCode
    {
        get { return hfSupCode.Value;  }
        set { hfSupCode.Value = value; } 
    }
    #endregion

    #region Public Methods
    /// <summary>Initalise the control</summary>
    /// <param name="NSVCode">Profile NSVCode</param>
    /// <param name="supCode">Profile Supplier Code</param>
    public void Initalise(string NSVCode, string supCode)
    {
        this.NSVCode = NSVCode;
        this.SupCode = supCode;

        // Get currency symbol
        lbPrice.Text = string.Format(lbPrice.Text, PharmacyCultureInfo.CurrencySymbol);

        // Poplate control
        if (!string.IsNullOrEmpty(NSVCode) && !string.IsNullOrEmpty(supCode))
        {
            PopulateControl();
            PopulateSiteList();
            UpdateReplicateToSiteList();
        }

        // setup selection text boxes as readonly (done here so can have view state and it is readonly)
        this.GetAllControlsByType<TextBox>().Where(c => c.CssClass.Contains("selectedOption")).ToList().ForEach(c => c.Attributes.Add("readonly", "readonly"));
    }

    /// <summary>Refreshs the control data (reread it from the db)</summary>
    public void Refresh()
    {
        if (!string.IsNullOrEmpty(this.NSVCode) && !string.IsNullOrEmpty(this.SupCode))
        {
            PopulateControl();
            PopulateSiteList();
            UpdateReplicateToSiteList();
        }
    }

    /// <summary>Event fired when data saved to db</summary>
    public event SupplierCodeUpdatedEventHandler SupplierCodeUpdated;
    public delegate void SupplierCodeUpdatedEventHandler(string NSVCode, string supCode);
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        // If embedded in pharmacy Product editor then used EditableSiteNumbers instead of ReplicateToSiteNumbers 08Jun15 XN 119361
        string siteNumbers = string.Empty;
        if (this.Request.Params.AllKeys.Contains("ReplicateToSiteNumbers"))
        {
            siteNumbers = this.Request["ReplicateToSiteNumbers"];
        }
        else if (this.Request.Params.AllKeys.Contains("EditableSiteNumbers"))
        {
            siteNumbers = this.Request["EditableSiteNumbers"];
        }

        var replicateToSites = Site2.Instance().FindBySiteNumber(siteNumbers, true, CurrentSiteHandling.AtStart);
        this.replicateToSiteNumbers       = replicateToSites.Select(s => s.SiteNumber).ToList();
        this.siteNumbersSelectedByDefault = replicateToSites.FindBySiteNumber(this.Request["SiteNumbersSelectedByDefault"], allowAll: true).Select(s => s.SiteNumber).ToList();

        // Added lookup for EDI Barcode 31Jul16 XN 126641
        this.imgEdiBarcodeLookup.Attributes["onclick"]   = "imgEdiBarcodeLookup_onclick();";
        this.tbProposedEdiBarcode.Attributes["onkeydown"]= "if (event.keyCode == 13) { imgEdiBarcodeLookup_onclick(); return false; }";
        this.tbProposedEdiBarcode.Attributes["readonly"] = "readonly";
        
        // Deal with __postBack events
        string   target    = Request["__EVENTTARGET"];
        string   args      = Request["__EVENTARGUMENT"];
        string[] argParams = new string[0];
        if (!string.IsNullOrEmpty(args) && target == upMCE.ClientID)
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        if (argParams.Length > 0)
        {
            switch (argParams[0])
            {
            case "SelectedNewSites":    
                // When used selects new set of sites updates the site list
                UpdateReplicateToSiteList();
                break;

            case "SelectNewSupplierProfile":
                // When user select new supplier profile get supplier code and update then page
                {
                int wsupplierProfileID = int.Parse(argParams[1]);
                WSupplierProfileRow supplierProfileRow  = WSupplierProfile.GetByWSupplierProfileID(wsupplierProfileID);
                this.SupCode = supplierProfileRow.SupplierCode;                
                PopulateControl();
                PopulateSiteList();
                UpdateReplicateToSiteList();
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "SetFocus", "clearIsPageDirty(); $('#tbProposedContractReference').focus();", true);
                if (SupplierCodeUpdated != null)
                    SupplierCodeUpdated(this.NSVCode, this.SupCode);
                }
                break;

            case "SelectNewSupplier":
                // When user select new supplier update the page
                {
                this.SupCode = argParams[1];
                PopulateControl();
                PopulateSiteList();
                UpdateReplicateToSiteList();
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "SetFocus", "clearIsPageDirty(); $('#tbProposedContractReference').focus();", true);
                if (SupplierCodeUpdated != null)
                    SupplierCodeUpdated(this.NSVCode, this.SupCode);
                }
                break;

            case "ValidatedOK": 
                if (Validated != null) 
                    Validated();
                break;

            case "Save": 
                SaveData(); 
                break;
            }
        }
    }

    /// <summary>
    /// Called when date radio button is clicked
    /// Enable\Disable the date control
    /// </summary>
    protected void rbDates_OnCheckedChanged(object sender, System.EventArgs e)
    {
        dtProposedEndDate.Enabled   = rbProposedEndDateOption.Checked;
        dtProposedStartDate.Enabled = rbProposedStartDateOption.Checked;
    }
    #endregion

    #region IQSViewControl Members
    /// <summary>Validates the current values (validation success is reported by event Validated)</summary>
    public void Validate()
    {
        WExtraDrugDetailColumnInfo columnInfo = WExtraDrugDetail.GetColumnInfo();
        ErrorWarningList errors = new ErrorWarningList();
        string tempStr;
        DateTime? tempDateTime;
        string error;

        // Clear all existing errors
        this.GetAllControlsByType<HtmlGenericControl>().Where(c => c.Attributes["class"] == "ErrorMessage").ToList().ForEach(c => c.InnerHtml = string.Empty);

        // Check supplier selected (should always be one)
        if (StringExtensions.IsNullOrEmptyAfterTrim(this.SupCode))
            errors.AddError("Must select a supplier");

        // Contract reference
        if (!Validation.ValidateText(tbProposedContractReference, "Contract reference", typeof(string), true, columnInfo.NewContractNumberLength, out error))
            errors.AddError(error);

        // Price
        if (!Validation.ValidateText(tbProposedPrice, "Price", typeof(decimal), true, 0.0, 1000000, out error))
            errors.AddError(error);

        // Tradename
        //if (!Validation.ValidateText(tbProposedTradeName, "Trade name", typeof(string), false, columnInfo.NewSupplierTradeNameNumberLength, out error))   28Oct14 XN  100212
        if (trTradename.Visible && !Validation.ValidateText(tbProposedTradeName, "Trade name", typeof(string), false, columnInfo.NewSupplierTradeNameNumberLength, out error))
            errors.AddError(error);

        // Reference 30Apr14 XN 88842
        if (!Validation.ValidateText(tbProposedReference, "Reference", typeof(string), false, columnInfo.NewSupplierReferenceNumberLength, out error))
            errors.AddError(error);

        // Start date
        DateTime startDate = rbProposedStartDateToday.Checked ? DateTime.Today : dtProposedStartDate.SelectedDate.Value;
        if (startDate < DateTime.Today)
            errors.AddError("Earliest start date is today.");

        // End date
        DateTime endDate   = rbProposedEndDateForever.Checked ? DateTime.MaxValue : dtProposedEndDate.SelectedDate.Value;
        if (endDate <= startDate)
            errors.AddError("Start date must be before end date.");

        // Edi Link Code 30Jun16 XN 126641
        if (trEdiBarcode.Visible && !Validation.ValidateBarcode(tbProposedEdiBarcode, "EDI Barcode", false, out error))
            errors.AddError(error);
        else if (trEdiBarcode.Visible && !string.IsNullOrEmpty(tbProposedEdiBarcode.Text) && tdCurrentEdiBarcode.InnerText != tbProposedEdiBarcode.Text)
        {
            var siteIds = replicateToSiteNumbers.Select(s => Site2.GetSiteIDByNumber(s)).ToList();
            foreach(var siteId in siteIds)
            {
                QSValidationList validationInfo = new QSValidationList();
                WSupplierProfileQSProcessor.CheckIfEdiBarcodeInUse(siteId, this.NSVCode, this.SupCode, tdCurrentEdiBarcode.InnerText, tbProposedEdiBarcode.Text, startDate, endDate, "EDI Barcode", validationInfo); 
                foreach (var v in validationInfo)
                {
                    if (v.error)
                        errors.AddError(v.siteID, v.message);
                    else
                        errors.AddWarning(v.siteID, v.message);
                }
            }
        }

        // Display errors
        // done like this so works with pharmacy product editor
        //if (errors.Length > 0)
        //{
        //    errors.Insert(0, "<table cellspacing='10'><colgroup><col width='15px' valign='top' /><col width='100%' valign='top' /></colgroup><tr><td><img src='images/exclamation_red.gif' /></td><td>");
        //    errors.Append("</td></tr></table><br /><p>Updates were not saved</p>");
        //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", string.Format("alertEnh(\"{0}\");", errors), true);
        //}
        if (errors.GetErrors().Any())
        {
            string msg = errors.GetErrors().ToHtml() + "<br /><p>Updates were not saved</p>";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", string.Format("alertEnh(\"{0}\");", msg), true);
        }
        else if (errors.GetWarnings().Any())
        {
            int width = 50 + errors.GetLongestCharLength() * 7;
            string script = string.Format("confirmEnh(\"<div style='max-height:500px'>{0}<br /><p>Do you still want to save changes?</p></div>\", false, function() {{ __doPostBack('{1}', 'ValidatedOK'); }}, undefined, '{2}px');",  errors.ToHtml(), upMCE.ClientID, width);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", script, true);
        }

        if (!errors.Any() && Validated != null)
            Validated();
    }

    /// <summary>Event fired when data has been validated sucessfully</summary>
    public event ValidatedEventHandler Validated;
    
    /// <summary>Saves the current values in the web control to quesScrl (success is report by event Saved)</summary>
    public void Save()
    {
        this.DisplayDifferences();
    }
    
    /// <summary>Event fired when data has been saved to db</summary>
    public event SavedEventHandler Saved;

    /// <summary>Suppresses building of the control</summary>
    public bool SuppressControlCreation { get; set; }
    #endregion

    #region Private Methods
    /// <summary>Populate the control</summary>
    private void PopulateControl()
    {
        // Load product detial (so check if it is the primary supplier)
        WProductRow product = WProduct.GetByProductAndSiteID(this.NSVCode, SessionInfo.SiteID);
        if (product == null)
            throw new ApplicationException("Invalid product for this site (NSV Code: " + this.NSVCode + ")");
        bool isCurrentlyPrimarySupplier = !string.IsNullOrEmpty(this.SupCode) && this.SupCode.EqualsNoCaseTrimEnd(product.SupplierCode);

        // Load supplier (if none exists add empty one as makes easier to code)
        WSupplier supplier = new WSupplier();
        if (!string.IsNullOrEmpty(this.SupCode))
            supplier.LoadByCodeAndSiteID(this.SupCode, SessionInfo.SiteID);
        if (!supplier.Any())
            supplier.Add();

        // Load supplier profile (if none exists add empty one as makes easier to code)
        WSupplierProfile supplierProfile = new WSupplierProfile();
        if (!string.IsNullOrEmpty(this.SupCode))
            supplierProfile.LoadBySiteIDSupplierAndNSVCode(SessionInfo.SiteID, this.SupCode, this.NSVCode);
        if (!supplierProfile.Any())
        {
            WSupplierProfileRow row = supplierProfile.Add();
            row.SiteID              = SessionInfo.SiteID;
            row.NSVCode             = product.NSVCode;
            row.SupplierTradename   = product.Tradename;    // 28Oct14 XN  100212 Set default tradename from product
        }

        // Load extra drug detail
        WExtraDrugDetail extraDrugDetail = new WExtraDrugDetail();
        extraDrugDetail.LoadBySiteIDNSVCodeAndSupCode(SessionInfo.SiteID, this.NSVCode, this.SupCode);

        SetText(lbtnSupplier, supplier[0].Name);

        SetText(tdCurrentContractReference, supplierProfile[0].ContractNumber                                           );
        SetText(tdCurrentPrice,             supplierProfile[0].ContractPrice.ToMoneyString(MoneyDisplayType.Show, false));
        SetText(tdCurrentTradeName,         supplierProfile[0].SupplierTradename                                        );
        SetText(tdCurrentReference,         supplierProfile[0].SupplierReferenceNumber                                  );  // 30Apr14 XN 88842 Added Supplier Reference
        SetText(tdCurrentEdiBarcode,        supplierProfile[0].EdiBarcode                                               );  // 30Jun16 XN 126641

        // Get currently active extra drug detail
        WExtraDrugDetailRow activeExtraDrugDetailRow = extraDrugDetail.FindByIsActive();
        SetText(tdCurrentStartDate, (activeExtraDrugDetailRow == null) ? string.Empty : activeExtraDrugDetailRow.DateUpdated_ByOvernighJob.ToPharmacyDateString());
        SetText(tdCurrentEndDate,   (activeExtraDrugDetailRow == null) ? string.Empty : activeExtraDrugDetailRow.StopDate.ToPharmacyDateString()                 );

        SetText(tdCurrentIsPrimarySupplier, isCurrentlyPrimarySupplier.ToYesNoString());

        // Set proposed values (uses either proposed or currently active)
        WExtraDrugDetailRow dueExtraDrugDetailRow = extraDrugDetail.FindFirstByIsStillDue();
        if (dueExtraDrugDetailRow != null)
        {
            tbProposedContractReference.Text     = dueExtraDrugDetailRow.NewContractNumber;
            tbProposedPrice.Text                 = dueExtraDrugDetailRow.NewContractPrice.ToMoneyString(MoneyDisplayType.Show, false);
            dtProposedStartDate.SelectedDate     = dueExtraDrugDetailRow.DateOfChange ?? DateTime.Today;
            rbProposedStartDateOption.Checked    = dueExtraDrugDetailRow.DateOfChange > DateTime.Today;
            dtProposedEndDate.SelectedDate       = dueExtraDrugDetailRow.StopDate ?? DateTime.Today; 
            rbProposedEndDateOption.Checked      = dueExtraDrugDetailRow.StopDate != null;
            tbProposedTradeName.Text             = dueExtraDrugDetailRow.NewSupplierTradeName;
            tbProposedReference.Text             = dueExtraDrugDetailRow.NewSupplierReferenceNumber;    // 30Apr14 XN 88842 Added Supplier Reference
            tbProposedEdiBarcode.Text            = dueExtraDrugDetailRow.NewEDIBarcode;                 // 30Jun16 XN 126641
            cbProposedIsPrimarySupplier.Enabled  = !isCurrentlyPrimarySupplier;
            cbProposedIsPrimarySupplier.Checked  = !isCurrentlyPrimarySupplier && dueExtraDrugDetailRow.SetAsDefaultSupplier;
        }
        else
        {
            tbProposedContractReference.Text     = supplierProfile[0].ContractNumber;
            tbProposedPrice.Text                 = supplierProfile[0].ContractPrice == null ? string.Empty : (supplierProfile[0].ContractPrice / 100).ToString("F2");
            dtProposedStartDate.SelectedDate     = DateTime.Today;
            rbProposedStartDateOption.Checked    = false;
            dtProposedEndDate.SelectedDate       = (activeExtraDrugDetailRow == null) ? DateTime.Today : activeExtraDrugDetailRow.StopDate ?? DateTime.Today; 
            rbProposedEndDateOption.Checked      = (activeExtraDrugDetailRow == null) || (activeExtraDrugDetailRow.StopDate != null);
            tbProposedTradeName.Text             = supplierProfile[0].SupplierTradename;
            tbProposedReference.Text             = supplierProfile[0].SupplierReferenceNumber;  // 30Apr14 XN 88842 Added Supplier Reference
            tbProposedEdiBarcode.Text            = supplierProfile[0].EdiBarcode;               // 30Jun16 XN 126641
            cbProposedIsPrimarySupplier.Enabled  = !isCurrentlyPrimarySupplier;
            cbProposedIsPrimarySupplier.Checked  = false;
        }

        rbProposedStartDateToday.Checked = !rbProposedStartDateOption.Checked;
        rbProposedEndDateForever.Checked = !rbProposedEndDateOption.Checked;
        dtProposedStartDate.Enabled      = rbProposedStartDateOption.Checked;
        dtProposedEndDate.Enabled        = rbProposedEndDateOption.Checked; 

        hfOriginalContractReference.Value = tbProposedContractReference.Text;
        hfOriginalPrice.Value             = tbProposedPrice.Text;
        hfOriginalStartDate.Value         = rbProposedStartDateToday.Checked ? "Today"      : dtProposedStartDate.SelectedDate.ToPharmacyDateString();
        hfOriginalEndDate.Value           = rbProposedEndDateForever.Checked ? "Open ended" : dtProposedEndDate.SelectedDate.ToPharmacyDateString();
        hfOriginalTradeName.Value         = tbProposedTradeName.Text;
        hfOriginalReference.Value         = tbProposedReference.Text;   // 30Apr14 XN 88842 Added Supplier Reference
        hfOriginalEdiBarcode.Value        = tbProposedEdiBarcode.Text;  // 30Jun16 XN 126641
        hfOriginalIsPrimarySupplier.Value = cbProposedIsPrimarySupplier.Checked.ToYesNoString();

        // Determine if tradename field is displayed (uses WSupplierProfileQSProcessor as logic is a bit complex)   28Oct14 XN  100212
        WSupplierProfileQSProcessor processor = new WSupplierProfileQSProcessor(supplierProfile, new [] { SessionInfo.SiteID } );
        trTradename.Visible   = !processor.GetDSSMaintainedDataIndex().Contains( WSupplierProfileQSProcessor.DATAINDEX_TRADENAME );

        //Bug 184323 : EDI barcode should not be depenant on setting D|WINORD..EnableEDILinkCode
        //trEdiBarcode.Visible = Winord.EnableEdiLinkCode;
        
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

        // Rem previous values more for product editor 08Jun15 XN 119361
        var siteNumbersToSelect = cblSites.Items.Count == 0 ? this.siteNumbersSelectedByDefault : cblSites.Items.Cast<ListItem>().Where(li => li.Selected).Select(li => int.Parse(li.Text)).ToList();
        
        // Populate check list
        cblSites.Items.Clear();
        foreach (var s in ContractProcessor.DetermineIfSiteValidForReplication(siteNumbersToReplicate, this.NSVCode, this.SupCode, true, false))
        {
            ListItem li = new ListItem(s.siteNumber.ToString(), s.siteID.ToString());
            switch (s.validState)
            {
            case ContractProcessor.SiteValid.Yes:
                li.Enabled  = true;
                li.Selected = siteNumbersToSelect.Contains(s.siteNumber);
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

    /// <summary>Displays differences</summary>
    private void DisplayDifferences()
    {
        StringBuilder differences = new StringBuilder();
        string temp;

        // Contract Reference
        if (hfOriginalContractReference.Value != tbProposedContractReference.Text)
            differences.AppendFormat("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>", "Contract Reference", hfOriginalContractReference.Value.XMLEscape(), tbProposedContractReference.Text.XMLEscape());

        // Contract price
        if (hfOriginalPrice.Value != tbProposedPrice.Text)
            differences.AppendFormat("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>", "Price", hfOriginalPrice.Value.XMLEscape(), tbProposedPrice.Text.XMLEscape());

        // Start date
        temp = rbProposedStartDateToday.Checked ? "Today" : dtProposedStartDate.SelectedDate.ToPharmacyDateString();
        if (hfOriginalStartDate.Value != temp)
            differences.AppendFormat("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>", "Start Date", hfOriginalStartDate.Value.XMLEscape(), temp.XMLEscape());

        // End date
        temp = rbProposedEndDateForever.Checked ? "Open ended" : dtProposedEndDate.SelectedDate.ToPharmacyDateString();
        if (hfOriginalEndDate.Value != temp)
            differences.AppendFormat("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>", "End Date", hfOriginalEndDate.Value.XMLEscape(), temp.XMLEscape());

        // Tradename
        //if (hfOriginalTradeName.Value != tbProposedTradeName.Text)    28Oct14 XN  100212 Set SupplierTradename to product tradename by default
        if (trTradename.Visible && hfOriginalTradeName.Value != tbProposedTradeName.Text)
            differences.AppendFormat("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>", "Tradename", hfOriginalTradeName.Value.XMLEscape(), tbProposedTradeName.Text.XMLEscape());

        // Reference 30Apr14 XN 88842
        if (hfOriginalReference.Value != tbProposedReference.Text)
            differences.AppendFormat("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>", "Supplier Reference", hfOriginalReference.Value.XMLEscape(), tbProposedReference.Text.XMLEscape());

        // EDI Link Code 30Jun16 XN 126641
        if (trEdiBarcode.Visible && hfOriginalEdiBarcode.Value != tbProposedEdiBarcode.Text)
            differences.AppendFormat("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>", "EDI link Code", hfOriginalEdiBarcode.Value.XMLEscape(), tbProposedEdiBarcode.Text.XMLEscape());

        // Is Primary Supplier
        temp = cbProposedIsPrimarySupplier.Checked.ToYesNoString();
        if (hfOriginalIsPrimarySupplier.Value != temp)
            differences.AppendFormat("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>", "Is Primary Supplier", hfOriginalIsPrimarySupplier.Value, temp);

        // If difference then display
        // After use clicks yes to the message will post back to Save (which is caught in Page_PreRender which does the actual save)
        if (differences.Length > 0)
        {
            string msg = "<div style='max-height:600px;overflow-y:scroll;overflow-x:hidden;'>" + 
                            "<table cellspacing='10' width='400px' >" +
                            "<tr><td><b>Description</b></td><td><b>Was</b></td><td><b>Now</b></td></tr>" +
                            differences.ToString() +
                            "</table>" +
                         "</div><br /><p>OK to save the changes?</p>";
            string script = string.Format("confirmEnh(\"{0}\", true, function() {{ __doPostBack('{1}', 'Save') }}, undefined, '450px');", msg, upMCE.ClientID);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", script, true);
        }
    }

    /// <summary>Saves the current values to the DB</summary>
    public void SaveData()  
    {
        ContractInfo contractInfo = new ContractInfo();
        contractInfo.contractReference = tbProposedContractReference.Text;
        contractInfo.contractPrice     = decimal.Parse(tbProposedPrice.Text) * 100;
        contractInfo.startDate         = rbProposedStartDateToday.Checked ? DateTime.Today  : dtProposedStartDate.SelectedDate.Value;
        contractInfo.endDate           = rbProposedEndDateForever.Checked ? (DateTime?)null : dtProposedEndDate.SelectedDate;
        contractInfo.NSVCode           = this.NSVCode;
        contractInfo.setDefaultSupplier= cbProposedIsPrimarySupplier.Enabled && cbProposedIsPrimarySupplier.Checked;
        contractInfo.SupCode           = this.SupCode;
        //contractInfo.supplierTradename = tbProposedTradeName.Text;
        contractInfo.supplierTradename = trTradename.Visible ? tbProposedTradeName.Text : null; // 28Oct14 XN 100212 Control of is tradename field is done if DSS item
        contractInfo.supplierReference = tbProposedReference.Text;  // 30Apr14 XN 88842 Added Supplier Reference
        contractInfo.ediBarcode        = trEdiBarcode.Visible ? tbProposedEdiBarcode.Text : null; // 30Jun16 XN 126641

        contractInfo.siteIDs.AddRange(cblSites.CheckedItems().Select(li => int.Parse(li.Value)));
        contractInfo.siteIDs.Add(SessionInfo.SiteID);

        using (ContractProcessor processor = new ContractProcessor())
        {
            try
            {
                processor.Lock(contractInfo);
                processor.Update(contractInfo);

                if (this.Saved != null)
                    this.Saved();
            }
            catch (LockException lockException)
            {
                string script = string.Format("alertEnh('Records in use by user \"{0}\" (EntityID: {1}).\nPlease try again in a few minutes?')", lockException.GetLockerUsername(), lockException.GetLockerEntityID());
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "LockException", script, true);
            }
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

        // Show sites that are not avaiable for replication
        IEnumerable<string> siteNumbersNotAvailable = checkBoxes.Where(li => !li.Enabled).Select(li => li.Text.Split(' ')[0]);
        if (siteNumbersNotAvailable.Any())
            sitesLabel.Append("Cannot replicate to sites " + siteNumbersNotAvailable.ToCSVString(", "));

        lbtSites.Text = sitesLabel.ToString();
    }

    //private void SetText(IButtonControl control, string format, params object[] args) 85921 XN 10Mar14 script error
    private void SetText(IButtonControl control, string text)
    {
        //string text = string.Format(format, args).Trim();  85921 XN 10Mar14 script error
        control.Text = string.IsNullOrEmpty(text) ? "&nbsp;" : text;
    }

    //private void SetText(HtmlTableCell cell, string format, params object[] args)  85921 XN 10Mar14 script error
    private void SetText(HtmlTableCell cell, string text)
    {
        //string text = string.Format(format ?? string.Empty, args).Trim();  85921 XN 10Mar14 script error
        cell.InnerHtml = string.IsNullOrEmpty(text) ? "&nbsp;" : text;
    }
    #endregion
}