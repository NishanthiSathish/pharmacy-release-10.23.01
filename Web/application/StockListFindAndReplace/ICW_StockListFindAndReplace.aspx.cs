//===========================================================================
//
//						 ICW_StockListFindAndReplace.cs
//
//  Desktop for the ward stock list search and replace screen.
//
//  Uses a wizard to allow the user to fill in the details of the operation to perfrom
//      Find and Replace => Select Drug to replace => Select new drug => Select Stock List => Confirm
//      Find and Update  => Select Drug to update => Select Stock List => Update individual lines => Confirm
//      Find and Delete  => Select Drug to replace => Select Stock List => Confirm
//
//  Replace vb6 form sar.frm (frmSearch)
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Site number
//  SiteID              -
//  HideCost            - Passed to product search to hide cost from user
//  
//	Modification History:
//	08Jul14 XN  Written
//  01Sep14 XN  Converted to a wizard
//  17Dec14 XN  Added find and Update method
//  19Dec14 XN  Added revert button to replace page and other minor fixes
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.wardstocklistlayer;

public partial class application_StockListFindAndReplace_ICW_StockListFindAndReplace : System.Web.UI.Page
{
    #region Data Types
    /// <summary>List of steps in the wizard</summary>
    protected enum WizardSteps
    {
        /// <summary>Select Type</summary>
        SelectFindType,

        /// <summary>Search for a drug</summary>
        SearchFor,

        /// <summary>Replace options</summary>
        Replace,

        /// <summary>List to select</summary>
        SelectLists,

        /// <summary>Editor for each ward list item</summary>
        Editor,

        /// <summary>Info panel</summary>
        InfoPanel,
    }

    protected enum FindType
    {
        /// <summary>Find and replace wizard</summary>
        FindReplace = 0,

        /// <summary>Find and update wizard</summary>
        FindUpdate = 1,

        /// <summary>Find and delete wizard</summary>
        FindDelete = 2,
    }
    #endregion

    #region Variables
    protected bool   hideCost;
    protected string reportName;
    #endregion

    #region Properties
    /// <summary>Current step in the wizard</summary>
    protected WizardSteps CurrentStep { get { return (WizardSteps)Enum.Parse(typeof(WizardSteps), hfCurrentStep.Value); } }
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(Request, Response);

        reportName = Request["ReportName"];
        // Read in but only passed to product search form
        hideCost = BoolExtensions.PharmacyParse(Request["HideCost"] ?? "0");

        if (!this.IsPostBack)
        {
            // Start the wizard
            PopulateSelectFindType();
            SetStep(WizardSteps.SelectFindType);
        }

        string args = Request["__EVENTARGUMENT"];

        // Deal with __postBack events
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' });

        switch (argParams[0])
        {
        case "SelectedReplaceDrug":
            {
            var NSVCode = argParams[1];
            if (hfSearchForNSVCode.Value == NSVCode)
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "matchError", "alertEnh(\"Can't replace the same drug code.\");", true);
            else
            {
                // Called when replace drug is selected
                // Updates drug info, and status of buttons
                WProductRow drug = WProduct.GetByProductAndSiteID(NSVCode, SessionInfo.SiteID);
                lbReplaceNSVCode.Text     = drug.NSVCode;
                hfReplaceNSVCode.Value    = drug.NSVCode;
                tbReplaceDescription.Text = drug.ToString();
                tbReplacePackSize.Text    = drug.ConversionFactorPackToIssueUnits.ToString();

                PopulateDrugInfoPanel(pnReplaceDrugInfo, drug);
                UpdateReplaceCtrlState();
            }
            }
            break;
        }
    }

    /// <summary>
    /// Called when next button is clicked
    /// Validates current stage in wizard, then moves to next stage is wizard
    /// </summary>
    protected void btnNext_OnClick(object sender, EventArgs e)
    {
        // Validate current wizard step
        bool valid = true;
        switch(this.CurrentStep)
        {
        case WizardSteps.SelectFindType : valid = ValidateSelectFindType(); break;
        case WizardSteps.SearchFor      : valid = ValidateSearchFor();      break;
        case WizardSteps.Replace        : valid = ValidateReplace();        break;
        case WizardSteps.SelectLists    : valid = ValidateSelectLists();    break;
        case WizardSteps.Editor         : valid = VaildateEditor();         break;
        case WizardSteps.InfoPanel      : valid = ValidateInfoPanel();      break;
        }

        // If valid move to next stage in wizard
        if (valid)
        {
            switch (this.GetSelectedFindType())
            {
            case FindType.FindReplace: WizardFindReplace(); break;
            case FindType.FindUpdate : WizardFindUpdate();  break;
            case FindType.FindDelete : WizardFindDelete();  break;
            }            
        }
    }    

    /// <summary>
    /// Called when clear replace drug button is click 
    /// Removes the replace drug, and update info panel and status
    /// </summary>
    protected void btnClearReplaceNSVCode_OnClick(object sender, EventArgs e)
    {
        // Remove replace drug value 
        lbReplaceNSVCode.Text       = string.Empty;
        hfReplaceNSVCode.Value      = string.Empty;
        tbReplaceDescription.Text   = string.Empty;
        tbReplacePackSize.Text      = string.Empty;

        // Update state
        PopulateDrugInfoPanel(pnReplaceDrugInfo, null);
        UpdateReplaceCtrlState();
    }

    /// <summary>
    /// Called when check all button is clicked
    /// Check all ward stock list items
    /// </summary>
    protected void btnCheckAll_OnClick(object sender, EventArgs e)
    {
        foreach (var l in cblLists.Items.Cast<ListItem>())
        {
            if (l.Enabled)
                l.Selected = true;
        }
    }

    /// <summary>
    /// Called when uncheck all button is clicked
    /// Unchecks all ward stock list items
    /// </summary>
    protected void btnUncheckAll_OnClick(object sender, EventArgs e)
    {
        foreach (var l in cblLists.Items.Cast<ListItem>())
            l.Selected = false;
    }

    /// <summary>
    /// Called when revert button is clicked
    /// Converts either new description of pack size back to original value
    /// </summary>
    protected void imgRevert_OnClick(object sender, EventArgs e)
    {
        WProductRow product = WProduct.GetByProductAndSiteID(lbReplaceNSVCode.Text, SessionInfo.SiteID);
        if (product != null && sender == imgRevertDescription)
            tbReplaceDescription.Text = product.ToString();
        else if (product != null && sender == imgRevertPackSize)
            tbReplacePackSize.Text = product.ConversionFactorPackToIssueUnits.ToString(); 
    }    
    #endregion

    #region Coordinate Wizard methods
    /// <summary>
    /// Coordinates find and replace wizared
    /// Steps are 
    ///     Select Type
    ///     Search for drug
    ///     Replace with items
    ///     Select lists
    ///     Confirm
    /// </summary>
    private void WizardFindReplace()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.SelectFindType: 
            PopulateSearchFor();
            SetStep(WizardSteps.SearchFor);
            break;        
        case WizardSteps.SearchFor:
            var product = WProduct.GetByProductAndSiteID(this.GetSearchForNSVCode(), SessionInfo.SiteID);
            hfHeaderSuffix.Value = product.NSVCode + " - " + product.ToString();

            PopulateReplace();
            SetStep(WizardSteps.Replace);
            break;        
        case WizardSteps.Replace:
            PopulateSelectLists();
            SetStep(WizardSteps.SelectLists);
            break;        
        case WizardSteps.SelectLists:
            {
            SearchAndReplaceProcessor processor = new SearchAndReplaceProcessor(hfSearchForNSVCode.Value, 
                                                                                hfReplaceNSVCode.Value,
                                                                                tbReplaceDescription.Text.TrimEnd(),
                                                                                int.Parse(tbReplacePackSize.Text),
                                                                                cblLists.CheckedItems().Select(l => int.Parse(l.Value)).ToArray());
            PopulateInfoPanel(processor.GenerateHTMLInfo());                        
            SetStep(WizardSteps.InfoPanel);
            btnNext.Text = "Finish";
            }
            break;        
        case WizardSteps.InfoPanel:
            {
            SearchAndReplaceProcessor processor = new SearchAndReplaceProcessor(hfSearchForNSVCode.Value, 
                                                                                hfReplaceNSVCode.Value,
                                                                                tbReplaceDescription.Text.TrimEnd(),
                                                                                int.Parse(tbReplacePackSize.Text),
                                                                                cblLists.CheckedItems().Select(l => int.Parse(l.Value)).ToArray());
            PerformOperation(processor, "Replace operation complete.");
            }
            break;        
        }
    }

    /// <summary>
    /// Coordinates find and update wizared
    /// Steps are 
    ///     Select Type
    ///     Search for drug
    ///     Select lists
    ///     Allow editing of lines
    ///     Confirm
    /// </summary>
    private void WizardFindUpdate()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.SelectFindType: 
            PopulateSearchFor();
            SetStep(WizardSteps.SearchFor);
            break;        
        case WizardSteps.SearchFor:
            hfHeaderSuffix.Value = this.GetSearchForNSVCode() + " - " + WProduct.ProductDetails(this.GetSearchForNSVCode(), SessionInfo.SiteID);
            PopulateSelectLists();
            SetStep(WizardSteps.SelectLists);
            break;          
        case WizardSteps.SelectLists:
            PopulateEditor();
            SetStep(WizardSteps.Editor);
            break;          
        case WizardSteps.Editor:
            {
            SearchAndReplaceProcessor processor = new SearchAndReplaceProcessor(hfSearchForNSVCode.Value, 
                                                                                editorControl.QSProcessor as WWardProductListLineAccessor,
                                                                                editorControl.QSView);
            PopulateInfoPanel( processor.GenerateHTMLInfo() );      
            SetStep(WizardSteps.InfoPanel);
            btnNext.Text = "Finish";
            }
            break;          
        case WizardSteps.InfoPanel:
            {
            SearchAndReplaceProcessor processor = new SearchAndReplaceProcessor(hfSearchForNSVCode.Value, 
                                                                                editorControl.QSProcessor as WWardProductListLineAccessor,
                                                                                editorControl.QSView);
            PerformOperation(processor, "Replace operation complete.");
            }
            break;        
        }
    }

    /// <summary>
    /// Coordinates find and delete
    /// Steps are 
    ///     Select Type
    ///     Search for drug
    ///     Select lists
    ///     Confirm
    /// </summary>
    private void WizardFindDelete()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.SelectFindType: 
            PopulateSearchFor();
            SetStep(WizardSteps.SearchFor);
            break;        
        case WizardSteps.SearchFor:
            var product = WProduct.GetByProductAndSiteID(this.GetSearchForNSVCode(), SessionInfo.SiteID);
            hfHeaderSuffix.Value = product.NSVCode + " - " + product.ToString();

            PopulateSelectLists();
            SetStep(WizardSteps.SelectLists);
            break;          
        case WizardSteps.SelectLists:
            {
            SearchAndReplaceProcessor processor = new SearchAndReplaceProcessor(hfSearchForNSVCode.Value, 
                                                                                cblLists.CheckedItems().Select(l => int.Parse(l.Value)).ToArray());
            PopulateInfoPanel(processor.GenerateHTMLInfo());
            SetStep(WizardSteps.InfoPanel);
            btnNext.Text = "Finish";
            }
            break;        
        case WizardSteps.InfoPanel:
            {
            SearchAndReplaceProcessor processor = new SearchAndReplaceProcessor(hfSearchForNSVCode.Value, 
                                                                                cblLists.CheckedItems().Select(l => int.Parse(l.Value)).ToArray());
            PerformOperation(processor, "Delete operation complete.");
            }                        
            break;        
        }
    }
    #endregion

    #region SelectFindType page
    /// <summary>Populate select type method</summary>
    private void PopulateSelectFindType()  
    { 
        ScriptManager.RegisterStartupScript(this, this.GetType(), "populateSelectFindType", "setTimeout(function() { $('#rbFindAndReplace input:eq(0)').focus(); }, 500);", true);
    }

    /// <summary>Validates the find type (always returns ture)</summary>
    private bool ValidateSelectFindType() { return true; }

    /// <summary>Gets selecte Find type (Find and replace or find and delete)</summary>
    private FindType GetSelectedFindType()
    {
        if (rbFindAndReplace.Checked)
            return FindType.FindReplace;
        else if (rbFindAndUpdate.Checked)
            return FindType.FindUpdate;
        else if (rbFindAndDelete.Checked)
            return FindType.FindDelete;

        throw new ApplicationException("Invalid selection");
    }
    #endregion

    #region SearchFor page
    /// <summary>Populate the search for page</summary>
    private void PopulateSearchFor()
    {
        hfSearchForNSVCode.Value = string.Empty;
    }

    /// <summary>Validates search for page (done client side so method always returns true</summary>
    private bool ValidateSearchFor() { return true; }

    /// <summary>Gets the dugs NSV Code</summary>
    private string GetSearchForNSVCode()
    {
        return hfSearchForNSVCode.Value;
    }
    #endregion

    #region Replace page
    /// <summary>Populate the replace page</summary>
    private void PopulateReplace()
    {

        WProductRow currentProduct = WProduct.GetByProductAndSiteID(this.GetSearchForNSVCode(), SessionInfo.SiteID);
        lbCurrentNSVCode.Text     = currentProduct.NSVCode;
        lbCurrentDescription.Text = currentProduct.ToString();
        lbCurrentPackSize.Text    = string.Format("{0} {1}", currentProduct.ConversionFactorPackToIssueUnits, currentProduct.PrintformV);
        
        PopulateDrugInfoPanel(pnCurrentDrugInfo, currentProduct);

        //lbReplaceNSVCode.Attributes.Add("onkeydown", "if (event.keyCode == 13) { btnReplaceNSVCode_onclick(); }");
        btnReplaceNSVCode.Focus();
        lbReplaceNSVCode.Text       = string.Empty;
        hfReplaceNSVCode.Value      = string.Empty;
        tbReplaceDescription.Text   = string.Empty;
        tbReplacePackSize.Text      = string.Empty;

        PopulateDrugInfoPanel(pnReplaceDrugInfo, null);
        UpdateReplaceCtrlState();
    }

    /// <summary>Validate the replace page</summary>
    private bool ValidateReplace()
    {
        WWardProductListLineColumnInfo columnInfo = WWardProductListLine.GetColumnInfo();
        bool ok = true;
        string error;

        error = string.Empty;

        // Check user has searched for a drug
        if (string.IsNullOrWhiteSpace(hfReplaceNSVCode.Value))
        {
            ok = false;
            lbErrorMessage.Text = "No replacement item selected";
        }

        // Replacement Description
        if (ok && !Validation.ValidateText(tbReplaceDescription, "Replacement Description", typeof(int), true, columnInfo.DescriptionLength, out error))
        {
            ok = false;
            lbErrorMessage.Text = error;
        }

        // Replacement Pack Size
        if (ok && !Validation.ValidateText(tbReplacePackSize, "Replacement pack size", typeof(int), true, 0, int.MaxValue, out error))
        {
            ok = false;
            lbErrorMessage.Text = error;
        }

        return ok;
    }

    /// <summary>Update enable state of replace controls, and fill in replace pack size suffix.</summary>
    private void UpdateReplaceCtrlState()
    {
        bool selected = string.IsNullOrWhiteSpace(hfReplaceNSVCode.Value);
        
        // enable or disable contrls
        lbReplaceCode.Enabled           = !selected;
        lbReplaceNSVCode.Enabled        = !selected;
        lbReplaceDescription.Enabled    = !selected;
        tbReplaceDescription.Enabled    = !selected;
        imgRevertDescription.Enabled    = !selected;
        lbReplacePackSize.Enabled       = !selected;
        tbReplacePackSize.Enabled       = !selected;
        imgRevertPackSize.Enabled       = !selected;
        lbReplacePackSizeSuffix.Enabled = !selected;

        // either get pack size from replace with, or search for product
        string newNSVCode = string.Empty;
        if (!string.IsNullOrEmpty(hfReplaceNSVCode.Value))
            newNSVCode = hfReplaceNSVCode.Value;
        else if (!string.IsNullOrEmpty(hfSearchForNSVCode.Value))
            newNSVCode = hfSearchForNSVCode.Value;

        // Update pack size units
        if (newNSVCode != hfNSVCodeForRepeater.Value)
        {
            WProductRow product         = WProduct.GetByProductAndSiteID(newNSVCode, SessionInfo.SiteID);
            lbReplacePackSizeSuffix.Text= string.Format("{0} ({1} {0})", product.PrintformV, product.ConversionFactorPackToIssueUnits);
            hfNSVCodeForRepeater.Value  = newNSVCode;
        }
    }
    #endregion

    #region SelectLists page
    /// <summary>Populate the select stock list page</summary>
    private void PopulateSelectLists()
    {
        string NSVCode = this.GetSearchForNSVCode();

        // get ward stock lists that contain the drug
        WWardProductList list = new WWardProductList();
        list.LoadBySiteAndNSVCode(SessionInfo.SiteID, NSVCode);

        Sites sites = new Sites();
        sites.LoadAll();

        IDictionary<int,LockException> softLocks = (new SoftLockResults(list.TableName)).IsLockedByOtherUser( list.Select(l => l.WWardProductListID) );
        IDictionary<int,LockException> hardLocks = (new LockResults    (list.TableName)).IsLockedByOtherUser( list.Select(l => l.WWardProductListID) );

        // Add to list 
        cblLists.Items.Clear();
        foreach(var l in list.OrderBy(l => l.Code))
        {
            string text = string.Format("{0} - {1}", l.Code, l.Description);
            ListItem li = new ListItem(text, l.WWardProductListID.ToString());
            
            if ( softLocks.Keys.Contains(l.WWardProductListID) )
            {
                li.Text += string.Format(" (in use by {0})", softLocks[l.WWardProductListID].GetLockerName());
                li.Enabled = false;
            }
            else if ( hardLocks.Keys.Contains(l.WWardProductListID) )
            {
                li.Text += string.Format(" (locked by {0})", hardLocks[l.WWardProductListID].GetLockerName());
                li.Enabled = false;
            }

            cblLists.Items.Add(li);
        }

        cblLists.Focus();
    }

    /// <summary>Validate the the select stock list page</summary>
    private bool ValidateSelectLists()
    {
        bool ok = true;

        // Ward stock Lists 
        if (cblLists.Items.Count == 0)
        {
            ok = false;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "NoStockList", "alert('No stock list contains " + hfSearchForNSVCode.Value + "');", true);
        }
        else if (!cblLists.CheckedItems().Any())
        {
            ok = false;
            lbErrorMessage.Text = "No stock list selected";
        }

        return ok;
    }

    /// <summary>Returns WWardProductListIDs selected</summary>
    private IEnumerable<int> GetSelectedLists()
    {
        return cblLists.Items.Cast<ListItem>().Where(l => l.Selected).Select(l => int.Parse(l.Value));
    }
    #endregion

    #region Editor page
    /// <summary>Sets up the editor page with lines for the selected lists</summary>
    private void PopulateEditor()
    {
        var selectedWardListIDs = this.GetSelectedLists().ToList();

        WWardProductListLine lines = new WWardProductListLine();
        lines.LoadByNSVCodeAndSite(this.GetSearchForNSVCode(), SessionInfo.SiteID);

        // Remove lines not for selected lists (just remove from local table)
        lines.RemoveAll(l => !selectedWardListIDs.Contains(l.WWardProductListID));
        lines.Table.AcceptChanges();
        lines.DeletedItemsTable.Clear();

        // Populate the editor control
        WWardProductListLineAccessor accessor = new WWardProductListLineAccessor( lines );
        editorControl.Initalise(accessor, "D|WWardProductListLine", "Views", "Data", 1, false);

        // resize grid
        ScriptManager.RegisterStartupScript(this, this.GetType(), "resize", "divGPE_onResize();", true);
    }

    /// <summary>
    /// Validates editor page
    /// Requires postback to perform full validation
    /// </summary>
    private bool VaildateEditor()
    {
        bool valid = false;

        if ( hfEditorControlValidated.Value == "1" )
        {
            if ( editorControl.QSProcessor.GetDifferences( editorControl.QSView ).Any() )
                valid = true;   // Validation has passed after postback so return true;
            else 
                ScriptManager.RegisterStartupScript(this, this.GetType(), "NoChanged", "divGPE_onResize(); alertEnh('No changes have been made.');", true);
        }
        else
            editorControl.Validate();   // Validate will display errors to user, and then postback with hfEditorControlValidated set to 1

        return valid;
    }    

    /// <summary>Called when editor creates a new header will allow control to set it's own header text</summary>
    protected void editorControl_OnCreatedHeader(TableHeaderCell headerCell, int ID)
    {
        WWardProductListLineRow line = (editorControl.QSProcessor as WWardProductListLineAccessor).Lines.FindByID(ID);
        string listName              = this.cblLists.Items.FindByValue(line.WWardProductListID.ToString()).Text;
        headerCell.Text = listName;
    }

    /// <summary>
    /// Called when QuesScrl on Editor page is validated sucessfully
    /// Will set hfEditorControlValidated to 1 so when VaildateEditor is called will return that validation has passed
    /// </summary>
    protected void editorControl_OnValidated()
    {
        // Cause postback to try validation again
        hfEditorControlValidated.Value = "1";
        ScriptManager.RegisterStartupScript(this, this.GetType(), "Validated", "divGPE_onResize(); $('#btnNext').click()", true);
    }
    #endregion

    #region InfoPanel page
    /// <summary>Populate InfoPanel page</summary>
    /// <param name="htmlMsg">Message to display</param>
    private void PopulateInfoPanel(string htmlMsg)
    {
        divInfoPanel.InnerHtml = htmlMsg;
    }

    /// <summary>Validate InfoPanel page (always return true)</summary>
    private bool ValidateInfoPanel() { return true; }
    #endregion

    #region Helper methods
    /// <summary>
    /// Set the next step the wizard is moving to
    /// Also set the title prefix for the next step (depends on step type)
    /// </summary>
    /// <param name="nextStep">Step to move to</param>
    private void SetStep(WizardSteps nextStep)
    {
        string headerPrefix = string.Empty;
        string operation    = string.Empty;

        // Get operation text ( used by some sections in next switch )
        switch (this.GetSelectedFindType())
        {
        case FindType.FindReplace: operation = "Replace"; break;
        case FindType.FindUpdate:  operation = "Update";  break;
        case FindType.FindDelete:  operation = "Delete";  break;
        }

        // Setup next step in the multi view, and set the screen header text
        switch (nextStep)
        {
        case WizardSteps.SelectFindType:multiView.SetActiveView(vSelectFindType ); lbHeader.Text = "Select operation " + hfHeaderSuffix.Value;        break;
        case WizardSteps.SearchFor:     multiView.SetActiveView(vSearchFor      ); lbHeader.Text = "Select item to "  + operation.ToLower() + " " + hfHeaderSuffix.Value;  break;
        case WizardSteps.Replace:       multiView.SetActiveView(vReplace        ); lbHeader.Text = "Select item to replace for " + hfHeaderSuffix.Value; break;
        case WizardSteps.SelectLists:   
            multiView.SetActiveView(vSelectLists);
            if (this.GetSelectedFindType() == FindType.FindDelete)
                lbHeader.Text = "Select stock list to delete " + hfHeaderSuffix.Value + " from";  
            else
                lbHeader.Text = "Select stock list to " + operation + " for " + hfHeaderSuffix.Value;  
            break;
        case WizardSteps.Editor:    multiView.SetActiveView(vEditor   ); lbHeader.Text = "Update selected lines for " + hfHeaderSuffix.Value; break;
        case WizardSteps.InfoPanel: multiView.SetActiveView(vInfoPanel); lbHeader.Text = "Find and " + operation + " for " + hfHeaderSuffix.Value; break;
        }

        // Save step
        hfCurrentStep.Value = nextStep.ToString();
    }

    /// <summary>Populate drug info panel</summary>
    /// <param name="ctrl">Panel to populate</param>
    /// <param name="drug">Drug to populate with (can be null to set empty)</param>
    private void PopulateDrugInfoPanel(PharmacyLabelPanelControl ctrl, WProductRow drug)
    {
        ctrl.SetColumns(2);
        ctrl.AddLabel(0, "Pack Size:", drug == null ? string.Empty : drug.ConversionFactorPackToIssueUnits.ToString());
        ctrl.AddLabel(0, "Barcode:",   drug == null ? string.Empty : drug.Barcode);
        ctrl.AddLabel(1, "In Use:",    drug == null ? string.Empty : drug.InUse.ToYesNoString());
        ctrl.AddLabel(1, "Stores:",    drug == null ? string.Empty : drug.IsStoresOnly.ToYesNoString());
    }

    /// <summary>Performs the opertion</summary>
    private void PerformOperation(SearchAndReplaceProcessor processor, string completeMsg)
    {
        try
        {
            // Save report is needed
            if (cbPrintReport.Checked)
                processor.SaveReport();

            // Perform action
            processor.PerformAction();

            // Print report if requested
            if (cbPrintReport.Checked)
            {
                // Check report exist in db
                if (string.IsNullOrEmpty(reportName))
                    reportName = "Pharmacy General Report " + SessionInfo.SiteNumber.ToString();
                if (!OrderReport.IfReportExists(reportName))
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "missingReport", string.Format("alert('Report not found \"{0}\"');", reportName.JavaStringEscape()), true);
                else
                {
                    // save report
                    string script = string.Format("window.parent.ICWWindow().document.frames['fraPrintProcessor'].PrintReport({0}, '{1}', 0, false, '')", SessionInfo.SessionID, reportName);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "report", script, true);
                }
            }

            ScriptManager.RegisterStartupScript(this, this.GetType(), "restart", string.Format("alertEnh('{0}', function() {{ window.location = window.location; }});", completeMsg.XMLEscape()), true);
        }
        catch (LockException ex)
        {
            var wardStockList = WWardProductList.GetByID(ex.PK);
            string script = string.Format("alertEnh(\"'Cannot perform operation as {0} are locked by {1} on {2}\");", wardStockList.ToString().JavaStringEscape(), ex.GetLockerName().JavaStringEscape(), ex.GetTerminal().JavaStringEscape());
            ScriptManager.RegisterStartupScript(this, this.GetType(), "lockedError", script, true);
        }
    }
    
    /// <summary>Returns if the drug is on any ward stock list for the site</summary>
    [WebMethod]
    public static bool IsPresentOnWardStockList(int sessionID, int siteID, string NSVCode)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);
        WWardProductList list = new WWardProductList();
        list.LoadBySiteAndNSVCode(SessionInfo.SiteID, NSVCode);
        return list.Any();
    }
    #endregion
}