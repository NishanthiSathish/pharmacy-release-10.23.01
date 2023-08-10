//===========================================================================
//
//					      UpdateServiceControl.aspx.cs
//  
//  Allows users to lock certain fields on DSS controlled drugs, so that
//  they are not updated by DSS on web. 
//  This includes the following fields
//      Label description
//      Stores description
//      Warning Code
//      Warning Code 2
//      Instruction Code
//      Can Use Spoon
//  
//  The control supports the IQuesScrlControl interface for easy plug into 
//  Pharmacy Product Editor.  
//    
//	Modification History:
//  18Dec13	XN	78339 Created
//  10Mar14 XN  If not DSS drug then can't edit
//  29Apr14 XN  Update UpdateEnableControl to use site local value not master site value
//  16Jun14 XN  Updates to Validate, and DisplayDifferences, for QS ToHTML 88509
//  20Jan15 XN  Update SaveData to use new WPharmacyLogType 26734
//  28Jun14 XN  94414 Changed link to master from using NSVCode to Drug ID
//  01Sep14 XN  99660 fixed odd issue with repeated popup widow caused by rouge 255 key stroke
//  20Mar15 XN  114371 CreateCtrls can't use keys on Can Use Spoon fields as shift factors it out
//              114375 UpdateEnableControl corrected t Revert to Ascribe Version
//  07Mar16 XN  99381 Added simple edit mode
//  22Mar16 XN  99381 Fixed script issue so calls USC_control_onkeydown rather than control_onkeydown
//===========================================================================
using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using _Shared;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;

public partial class application_PharmacyProductEditor_UpdateServiceControl : System.Web.UI.UserControl, IQSViewControl
{
    #region Member Variables
    /// <summary>Use QSProcessor to get the processor</summary>
    private WProductQSProcessor qsprocessor;

    /// <summary>List of ques scroll control drugs</summary>
    private QSView qsView = new QSView();
    #endregion

    #region Private Properties
    /// <summary>Gets access to the QSProcessor (cached on page)</summary>
    private WProductQSProcessor QSProcessor
    {
        get 
        { 
            if (qsprocessor == null && !string.IsNullOrEmpty(hfQSProcessor.Value))
                qsprocessor = QSBaseProcessor.Create(hfQSProcessor.Value) as WProductQSProcessor;
            return qsprocessor;  
        }
        set 
        { 
            qsprocessor = value;
            hfQSProcessor.Value = qsprocessor.WriteXml();
        }
    }
    #endregion

    #region Public Methods
    /// <summary>Initalise the control</summary>
    public void Initalise(string NSVCode)
    {
        WProduct products = new WProduct();
        products.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID);

        this.QSProcessor = new WProductQSProcessor(products, new [] { SessionInfo.SiteID });

        WProductRow localProduct = this.QSProcessor.Products.FindBySiteID(SessionInfo.SiteID).First();
        SiteProductDataRow masterProduct = SiteProductData.GetByDrugIDAndMasterSiteID(localProduct.DrugID, 0);  // 04Jul14 XN Correct link to master is via Drug Id

        //int? trueDrugID = localProduct.GetTrueMasterDrugID();     04Jul14 XN Removed refereces to DSSMasterSiteLinkSite
        //SiteProductDataRow masterProduct = null;
        //if (trueDrugID != null)
        //    masterProduct = SiteProductData.GetByDrugIDAndMasterSiteID(trueDrugID.Value, 0); 

        // Create controls
        if (!this.qsView.Any())
            CreateCtrls();

        // Poplate control data
        this.QSProcessor.PopulateForEditor(qsView);
        this.QSProcessor.SetLookupItem(qsView);

        if (masterProduct == null)
        {
            divMain.Visible              = false;
            divNotDSSDrugWarning.Visible = true;
        }
        else
        {
            divMain.Visible              = true;
            divNotDSSDrugWarning.Visible = false;

            // Fill in master values
            lbDescription.Text          = masterProduct.LabelDescription;
            lbStoresDescription.Text    = masterProduct.StoresDescription;
            lbWarningCode.Text          = masterProduct.WarningCode;
            lbWarningCode2.Text         = masterProduct.WarningCode2;
            lbInstructionCode.Text      = masterProduct.InstructionCode;
            lbCanUseSpoon.Text          = masterProduct.CanUseSpoon.ToYesNoString().SafeSubstring(0, 1);

            // Set warnign code tooltips
            lbWarningCode.ToolTip       = WLookup.GetWarning    (SessionInfo.SiteID, lbWarningCode.Text     );
            lbWarningCode2.ToolTip      = WLookup.GetWarning    (SessionInfo.SiteID, lbWarningCode2.Text    );
            lbInstructionCode.ToolTip   = WLookup.GetInstruction(SessionInfo.SiteID, lbInstructionCode.Text );

            // Set clocked state
            cbDescription.Checked       = localProduct.LabelDescription_Locked;
            cbStoresDescription.Checked = localProduct.StoresDescription_Locked;
            cbWarningCode.Checked       = localProduct.WarningCode_Locked;
            cbWarningCode2.Checked      = localProduct.WarningCode2_Locked;
            cbInstructionCode.Checked   = localProduct.InstructionCode_Locked;
            cbCanUseSpoon.Checked       = localProduct.CanUseSpoon_Locked;

            // Update control state
            Lock_OnCheckedChanged(null, null);
        }
    }
    #endregion 

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack && !qsView.Any() && !this.SuppressControlCreation)
            CreateCtrls();  // Controls are dynamic so need to create

        // ensure the control that had focus before the postback has focus after 7Mar16 XN 99381
        var checkBoxWithFocus = string.IsNullOrEmpty(hfCheckBoxWithFocus.Value) ? cbDescription.ID : hfCheckBoxWithFocus.Value;
        ScriptManager.RegisterStartupScript(this, this.GetType(), "setFocus", string.Format("$('#{0}').focus();", checkBoxWithFocus), true);
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        string target = Request["__EVENTTARGET"];
        string args   = Request["__EVENTARGUMENT"];

        // Deal with __postBack events
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args) && target == upUSC.ClientID)
            argParams = args.Split(new char[] { ':' });

        switch (argParams[0])
        {
        case "Save": SaveData(); break;
        }
    }

    /// <summary>Called when lock checkbox is clicked will update the read-only state of the conrols</summary>
    protected void Lock_OnCheckedChanged(object sender, EventArgs e)
    {
        //UpdateEnableControl(WProductQSProcessor.DATAINDEX_DESCRIPTION,  cbDescription.Checked        ); XN 24Jun15 Local description change fix
        UpdateEnableControl(WProductQSProcessor.DATAINDEX_LABELDESCRIPTION,  cbDescription.Checked        );
        UpdateEnableControl(WProductQSProcessor.DATAINDEX_STORESDESCRIPTION, cbStoresDescription.Checked  );
        UpdateEnableControl(WProductQSProcessor.DATAINDEX_WARNCODE,          cbWarningCode.Checked        );
        UpdateEnableControl(WProductQSProcessor.DATAINDEX_WARNCODE2,         cbWarningCode2.Checked       );
        UpdateEnableControl(WProductQSProcessor.DATAINDEX_INSCODE,           cbInstructionCode.Checked    );
        UpdateEnableControl(WProductQSProcessor.DATAINDEX_CANUSESPOON,       cbCanUseSpoon.Checked        );
    }
    #endregion

    #region IQuesScrlControl Methods
    /// <summary>Validates the current values (validation success is reported by event Validated)</summary>
    public void Validate()
    {
        QSValidationList errors = QSProcessor.Validate(this.qsView);
        if (errors.Any())
        {
            string msg = errors.ToHTML( Sites.GetDictonarySiteIDToNumber() ) + "<br /><p>Updates were not saved</p>";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", string.Format("alertEnh(\"{0}\");", msg), true);
        }
        else
        {
            if (Validated != null)
                Validated();
        }
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

    /// <summary>Suppresses builing of the conrol</summary>
    public bool SuppressControlCreation { get; set; }
    #endregion 

    #region Private Methods
    /// <summary>Build the controls</summary>
    private void CreateCtrls()
    {
        QSDataInputItem item;

        qsView.Load("D|STKMAINT", "Views", "Data", WProductQSProcessor.VIEWINDEX_UPDATESERVICE, new int[] { SessionInfo.SiteID });
        
        // Description
        item = qsView.FindByDataIndex(WProductQSProcessor.DATAINDEX_LABELDESCRIPTION);
        trDescription.Cells[0].InnerText = item.description;
        trDescription.Cells[2].Controls.Add(item.inputControls.First());
        trDescription.Cells[2].Controls.OfType<TextBox>().First().Width = new Unit("300px");
        
        // Stores Description
        item = qsView.FindByDataIndex(WProductQSProcessor.DATAINDEX_STORESDESCRIPTION);
        trStoresDescription.Cells[0].InnerText = item.description;
        trStoresDescription.Cells[2].Controls.Add(item.inputControls.First());
        trStoresDescription.Cells[2].Controls.OfType<TextBox>().First().Width = new Unit("300px");
        
        // Warning Code
        item = qsView.FindByDataIndex(WProductQSProcessor.DATAINDEX_WARNCODE);
        trWarningCode.Cells[0].InnerText = item.description;
        trWarningCode.Cells[2].Controls.Add(item.inputControls.First());
        //item.inputControls.First().Attributes["onclick"] += "this.select();"; 7Mar16 XN 99381 moved to startup script below
        //item.inputControls.First().Attributes["onkeydown"] += "if (!event.shiftKey && event.keyCode != 255) { DoLookup(this); window.event.cancelBubble = true; window.event.returnValue = false; return false; }"; // XN 01Sep14 99660 fixed odd issue with repeated popup widow caused by rouge 255 key stroke

        // Warning Code 2
        item = qsView.FindByDataIndex(WProductQSProcessor.DATAINDEX_WARNCODE2);
        trWarningCode2.Cells[0].InnerText = item.description;
        trWarningCode2.Cells[2].Controls.Add(item.inputControls.First());
        //item.inputControls.First().Attributes["onclick"] += "this.select();"; 7Mar16 XN 99381 moved to startup script below
        //item.inputControls.First().Attributes["onkeydown"] += "if (!event.shiftKey && event.keyCode != 255) { DoLookup(this); window.event.cancelBubble = true; window.event.returnValue = false; return false; }"; // XN 01Sep14 99660 fixed odd issue with repeated popup widow caused by rouge 255 key stroke
        
        // Instruction Code
        item = qsView.FindByDataIndex(WProductQSProcessor.DATAINDEX_INSCODE);
        trInstructionCode.Cells[0].InnerText = item.description;
        trInstructionCode.Cells[2].Controls.Add(item.inputControls.First());
        //item.inputControls.First().Attributes["onclick"] += "this.select();"; 7Mar16 XN 99381 moved to startup script below
        //item.inputControls.First().Attributes["onkeydown"] += "if (!event.shiftKey && event.keyCode != 255) { DoLookup(this); window.event.cancelBubble = true; window.event.returnValue = false; return false; }"; // XN 01Sep14 99660 fixed odd issue with repeated popup widow caused by rouge 255 key stroke
        
        // Can Use Spoon
        item = qsView.FindByDataIndex(WProductQSProcessor.DATAINDEX_CANUSESPOON);
        trCanUseSpoon.Cells[0].InnerText = item.description;
        trCanUseSpoon.Cells[2].Controls.Add(item.inputControls.First());
        // item.inputControls.First().Attributes["onclick"] += "this.select();"; 7Mar16 XN 99381 moved to startup script below

        // Set the java functions called when 7Mar16 XN 99381
        //   Checkbox has focus - calls checkbox_onfocus to note the name of control with focus as postback looses focus
        //   Textbox  has focus - select textbox text
        //   Checkbox or textbox key down - calls control_onkeydown
        // Due to the way that ASP.NET checkboxes work it is better to do the onfocus at script level rather than in code behind
        string script = "$('#divUSC input[type=checkbox]').focus(function() { USC_checkbox_onfocus(this); });" +
                        "$('#divUSC input[type=text], #divUSC textarea').focus(function() { this.select(); });" +
                        "$('#divUSC input[type=checkbox], #divUSC input[type=text]').keydown(function() { return USC_control_onkeydown(this, event); })";
        ScriptManager.RegisterStartupScript(this, this.GetType(), "checkboxFocus", script, true);

        if (this.QSProcessor != null)
            this.QSProcessor.SetLookupItem(this.qsView);    // XN 30Jan14 Ensure we have the correct lookup
    }

    /// <summary>
    /// Changes the enabled\disabled state of the control
    /// If data is not locked down then the local version is replaced by ascribe version
    /// </summary>
    private void UpdateEnableControl(int index, bool enable)
    {
        TextBox ctrl = qsView.FindByDataIndex(index).inputControls.OfType<TextBox>().First();
        ctrl.Enabled = enable;

        // If not locally locked down update local with ascribe version
        if (!enable)
        {
            //WProductRow localProduct = this.QSProcessor.Products.FindBySiteID(SessionInfo.SiteID).First();    114375 XN 20Mar15 Update Service DSS Prod Won't Revert to Ascribe Ver
            //ctrl.Text = qsprocessor.GetValueForEditor(localProduct, index);

            Label lbl = ctrl.Parent.Parent.GetAllControlsByType<Label>().First();
            ctrl.Text = lbl.Text;
        }
        //  ctrl.Text = ((ctrl.Parent.Parent as HtmlTableRow).Cells[1].Controls[0] as Label).Text; 29Apr14 XN

        // If control is lookup ensure it state is still read-only (as setting enable prevents this)
        if (enable && qsView.FindByDataIndex(index).IsLookupOnly)
            ctrl.Attributes.Add("readonly", "readonly");
    }

    /// <summary>Returns difference between original value of the process and the controls current values</summary>
    /// <param name="quesScrl">Base QS processor (holds original values)</param>
    private QSDifferencesList GetDifferences()
    {
        WProductQSProcessor productProcessor = (this.QSProcessor as WProductQSProcessor);
        WProductRow product = productProcessor.Products.FindBySiteID(SessionInfo.SiteID).First();
        QSDifferencesList differences = new QSDifferencesList();
        differences.AddRange(CompareValues(productProcessor, WProductQSProcessor.DATAINDEX_LABELDESCRIPTION,   product.LabelDescription_Locked ));
        differences.AddRange(CompareValues(productProcessor, WProductQSProcessor.DATAINDEX_STORESDESCRIPTION,  product.StoresDescription_Locked));
        differences.AddRange(CompareValues(productProcessor, WProductQSProcessor.DATAINDEX_WARNCODE,           product.WarningCode_Locked      ));
        differences.AddRange(CompareValues(productProcessor, WProductQSProcessor.DATAINDEX_WARNCODE2,          product.WarningCode2_Locked     ));
        differences.AddRange(CompareValues(productProcessor, WProductQSProcessor.DATAINDEX_INSCODE,            product.InstructionCode_Locked  ));
        differences.AddRange(CompareValues(productProcessor, WProductQSProcessor.DATAINDEX_CANUSESPOON,        product.CanUseSpoon_Locked      ));
        return differences;
    }

    /// <summary>Displays differences</summary>
    private void DisplayDifferences()
    {
        // If difference then display
        // After use clicks yes to the message will post back to Save (which is caught in Page_PreRender which does the actual save)
        QSDifferencesList differences = GetDifferences();
        if (differences.Any())
        {
            string msg = string.Format("<div style='max-height:600px;overflow-y:scroll;overflow-x:hidden;'>{0}</div><br /><p>OK to save the changes?</p>", differences.ToHTML( Sites.GetDictonarySiteIDToNumber() ));
            string script = string.Format("confirmEnh(\"{0}\", true, function() {{ __doPostBack('{1}', 'Save') }}, undefined, '450px');", msg, upUSC.ClientID);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", script, true);
        }
    }    

    /// <summary>Saves the change to the db (also updates the WPharmacyLog labutils</summary>
    private void SaveData()
    {
        // Get difference for saving to WPharmacyLog
        QSDifferencesList differences = GetDifferences();

        // Build log message
        WPharmacyLog log = new WPharmacyLog();
        //log.BeginRow("labutils", this.QSProcessor.Products.First().NSVCode);  20Jan15 XN 26734
        var logRow = log.BeginRow(WPharmacyLogType.LabUtils, this.QSProcessor.Products.First().NSVCode);
        logRow.SiteID = null;
        foreach (var diff in differences)
        {
            log.AppendLineDetail("{0}\t Was : '{1}' Now : '{2}'", diff.description, diff.was, diff.now);
        }
        
        log.AppendLineDetail("SAVE");
        log.EndRow();

        // Update vallues
        int siteID = SessionInfo.SiteID;
        foreach(var product in this.QSProcessor.Products)
        {
            product.LabelDescription_Locked = cbDescription.Checked;
            product.LabelDescription        = this.qsView.FindByDataIndex(WProductQSProcessor.DATAINDEX_LABELDESCRIPTION).GetValueBySiteID(siteID);    
            product.StoresDescription_Locked= cbStoresDescription.Checked;
            product.StoresDescription       = this.qsView.FindByDataIndex(WProductQSProcessor.DATAINDEX_STORESDESCRIPTION).GetValueBySiteID(siteID);    
            product.WarningCode_Locked      = cbWarningCode.Checked;
            product.WarningCode             = this.qsView.FindByDataIndex(WProductQSProcessor.DATAINDEX_WARNCODE).GetValueBySiteID(siteID);    
            product.WarningCode2_Locked     = cbWarningCode2.Checked;
            product.WarningCode2            = this.qsView.FindByDataIndex(WProductQSProcessor.DATAINDEX_WARNCODE2).GetValueBySiteID(siteID);    
            product.InstructionCode_Locked  = cbInstructionCode.Checked;
            product.InstructionCode         = this.qsView.FindByDataIndex(WProductQSProcessor.DATAINDEX_INSCODE).GetValueBySiteID(siteID);    
            product.CanUseSpoon_Locked      = cbCanUseSpoon.Checked;
            product.CanUseSpoon             = BoolExtensions.PharmacyParseOrNull(this.qsView.FindByDataIndex(WProductQSProcessor.DATAINDEX_CANUSESPOON).GetValueBySiteID(siteID));
        }

        // Save
        using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
        {
            this.QSProcessor.Products.Save(updateModifiedDate: true);
            log.Save();
            trans.Commit();
        }

        // Send event data has been saved
        if (Saved != null)
            Saved();
    }

    /// <summary>Compares a items local version, with original version, and its lock state with the original lock state</summary>
    /// <param name="processor">Original QS data object</param>
    /// <param name="index">Data index to check</param>
    /// <param name="originalLockState">original lock state of the data</param>
    private QSDifferencesList CompareValues(WProductQSProcessor processor, int index, bool originalLockState)
    {
        QSDifferencesList differences = new QSDifferencesList();
        QSDataInputItem item = this.qsView.FindByDataIndex(index);
        int siteID = SessionInfo.SiteID;

        // Check if lock state has changed
        if (item.Enabled != originalLockState)
        {
            differences.Add(siteID:     siteID, 
                            description:item.description + " Locked", 
                            now:        item.Enabled.ToYesNoString(), 
                            was:        originalLockState.ToYesNoString());
        }

        // Check if local data has changed
        QSDifference? diff = item.CompareValues(siteID, processor.GetValueForEditor(processor.Products.First(), index));
        if (diff != null)
            differences.Add(diff.Value);

        return differences;
    }
    #endregion 
}
