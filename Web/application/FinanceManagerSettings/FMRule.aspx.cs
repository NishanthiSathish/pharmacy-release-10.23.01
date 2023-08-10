//===========================================================================
//
//						        FMRule.aspx.cs
//
//  Allows user to add, edit, or clone an finance manager rule.
//
//  Call the page with the follow parameters
//  SessionID   - ICW session ID
//  Mode        - 'add' or 'edit'
//  RecordID    - Id of record if in edit mode then ID of item to edit
//                if in add mode id of record to clone from
//
//  Usage:
//  To add
//  FMRule.aspx?SessionID=123&Mode=add
//
//  To edit
//  FMRule.aspx?SessionID=123&Mode=edit&RecordID=4
//
//	Modification History:
//	23Apr13 XN  Written 53147
//  30May13 XN  Replaced IgnoreStock with StockFieldSelector (65498)
//  02Dec13 XN  Added VAT account codes 79631
//  07Jan14 XN  HTML Escape data returned from page 81147
//  08Jan14 XN  Add site to rule 81377
//  22Jan14 XN  Added cloning mode
//  18Mar14 XN  Changed duplicate rule error to warning.
//  18Jun14 XN  Get ward lookup to use new SelectPharmacyWard.aspx page 88509
//===========================================================================
using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.basedatalayer;

public partial class application_FinanceManagerSettings_FMRule : System.Web.UI.Page
{
    protected int  sessionID;
    protected int  recordID;
    protected bool addMode;

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        // Get SessionID
        sessionID  = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        // Get mode
        addMode = Request.QueryString["Mode"].EqualsNoCaseTrimEnd("add");
        if (!int.TryParse(Request["RecordID"], out recordID))
            recordID = -1;

        // Init the form (called independent of postback as lot of ICW controls do not maintain view state)
        Initialise();

        if (!Page.IsPostBack)
        {
            // Setup for depending on mode
            if (recordID > -1)
            {
                Edit(recordID);
                
                // If performing a clone the clear code and description
                if (addMode)
                {
                    txtCode.Value       = string.Empty;
                    txtDescription.Value= string.Empty;
                }
            }
        }
    }

    /// <summary>
    /// Called when pharmacy log selection changes
    /// 1. Populates kind list
    /// 2. Updates label type list
    /// 3. Updates the ward sup code text box
    /// </summary>
    protected void lPharmacyLog_OnValueChanged(object sender, EventArgs e)
    {
        PharmacyLogType pharmacyLog = EnumExtensions.ListItemValueToEnum<PharmacyLogType>(lPharmacyLog.SelectedValue);

        PopulateKindList();
        UpdateLabelType();
        UpdateWardSupCode(true);
        UpdateSupplierType();

        UpdateCostMultiplierField();
        UpdateCostMultiplierLabel();

        UpdateStockField(); // 30May13 XN  Replaced IgnoreStock with StockFieldSelector (65498)
        UpdateStockMultiplierField();
        UpdateStockMultiplierLabel();
    }

    /// <summary>
    /// Called when okay button is clicked, 
    /// 1. validates
    /// 2. saves
    /// 3. closes form
    /// </summary>
    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        if (Validate())
        {
            if (Save())
                ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseForm", string.Format("window.returnValue={0}; window.close();", recordID), true);
        }
    }

    /// <summary>
    /// Called when stock field is updated
    /// Enable\disables all other stock items in the list
    /// </summary>
    protected void lStockField_OnValueChanged(object sender, EventArgs e)
    {
        StockFieldChanged();
        UpdateStockMultiplierLabel();
    }

    /// <summary>
    /// Called when cost field is updated
    /// Enable\disables all other cost items in the list
    /// </summary>
    protected void lCostField_OnValueChanged(object sender, EventArgs e)
    {
        CostFieldChanged();
        UpdateCostMultiplierLabel();
    }

    protected void lStockMultiply_OnValueChanged(object sender, EventArgs e)
    {
        UpdateStockMultiplierLabel();
    }

    protected void lCostMultiply_OnValueChanged(object sender, EventArgs e)
    {
        UpdateCostMultiplierLabel();
    }

    /// <summary>
    /// Called when message box mbChangeWarning Ok button is clicked.
    /// Set Setting WFMSettings.General.RebuildLogs to ture to request rebuild at midnight, then closes the form
    /// </summary>
    protected void mbChangeWarning_OkClicked(object sender, Ascribe.Core.Controls.MessageBox.MessageBoxButtonClickEventArgs e)
    {
        WFMSettings.General.RebuildLogs = true;
        ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseForm", string.Format("window.returnValue={0}; window.close();", int.Parse(hfRecordID.Value)), true);
    }

    /// <summary>
    /// Called when message box mbDuplicateRule Yes button is clicked.
    /// Warns user of duplicate rule
    /// XN 18Mar14 Changed duplicate rule error to warning.
    /// </summary>
    protected void mbDuplicateRule_YesClicked(object sender, Ascribe.Core.Controls.MessageBox.MessageBoxButtonClickEventArgs e)
    {
        if (Save())
            this.ClosePage(recordID.ToString());
    }
    #endregion

    #region Private Methods
    /// <summary>Initialise the control</summary>
    private void Initialise()
    {
        // Clear error messages
        this.Controls.OfType<Control>().Desendants(c => c.Controls.OfType<Control>()).OfType<Ascribe.Core.Controls.ControlBase>().ToList().ForEach(c => c.ErrorMessage = string.Empty);

        // Some data is postback specific
        if (!this.IsPostBack)
        {
            // Set first site in init session (need for PharmacyCultureInfo)
            Sites sites = new Sites();
            sites.LoadAll(true);
            SessionInfo.InitialiseSessionAndSiteID(SessionInfo.SessionID, sites.First().SiteID);

            // Pharmacy log types
            lPharmacyLog.Items.AddRange(EnumExtensions.EnumToListItems(typeof(PharmacyLogType)));
            lPharmacyLog.Items.Remove(PharmacyLogType.Unknown.ToString());
            lPharmacyLog.Items.Remove(PharmacyLogType.PharmacyLog.ToString());

            // Kind
            PopulateKindList();

            // Label type
            WFMTransactionType tranactionType = new WFMTransactionType();
            tranactionType.LoadByPharmacyLogType(PharmacyLogType.Orderlog);
            lLabelType.Items.Add(new ListItem("<Any>", string.Empty));
            lLabelType.Items.AddRange(WFMSettings.RuleEditor.LabelTypes.ToCharArray().Select(l => new ListItem(l.ToString())).ToArray());
            lLabelType.SelectedIndex = 0;

            // Site     08Jan14 XN 81377
            lSite.Items.Add(new ListItem("<Any>", string.Empty));
            lSite.Items.AddRange(sites.Select(s => new ListItem(s.SiteNumber.ToString("000"), s.SiteID.ToString())).ToArray());

            // Supplier types
            lSupplierType.Items.AddRange(EnumExtensions.EnumToListItems(typeof(SupplierType)));
            lSupplierType.Items.FindByText(SupplierType.Unknown.ToString()).Text = "<Any>";
            lSupplierType.SelectedIndex = 0;

            // Positive\Negative
            lCostPosNeg.Items.Add (new ListItem("<Any>", WFMPositiveNegative.Any.ToString()));
            lCostPosNeg.Items.Add (new ListItem(">0",    WFMPositiveNegative.Positive.ToString()));
            lCostPosNeg.Items.Add (new ListItem("<0",    WFMPositiveNegative.Negative.ToString()));
            lCostPosNeg.SelectedIndex = 0;
            lStockPosNeg.Items.Add(new ListItem("<Any>", WFMPositiveNegative.Any.ToString()));
            lStockPosNeg.Items.Add(new ListItem(">0",    WFMPositiveNegative.Positive.ToString()));
            lStockPosNeg.Items.Add(new ListItem("<0",    WFMPositiveNegative.Negative.ToString()));
            lStockPosNeg.SelectedIndex = 0;

            tdVatCaption.InnerHtml = PharmacyCultureInfo.SalesTaxName;

            // Account code
            WFMAccountCode segment1Codes = new WFMAccountCode();
            segment1Codes.LoadAll();
            foreach(var code in segment1Codes)
            {
                string text  = code.ToStringWithFormatting(false);
                int    value = code.Code;

                lAccountCode_Debit.Items.Add     (new ListItem(text, value.ToString()));
                lAccountCode_Credit.Items.Add    (new ListItem(text, value.ToString()));
                lAccountCode_Vat_Debit.Items.Add (new ListItem(text, value.ToString()));
                lAccountCode_Vat_Credit.Items.Add(new ListItem(text, value.ToString()));
            }

            // Setup cost fields (fixed unlike stock, and multiply fields)
            lCostField.Items.Clear();
            lCostField.Items.Add("<Required>");
            lCostField.Items.Add("<Ignore>"  );

            // Initialise default values
            txtNSVDescription.Value     = "<Any>";
            txtWardSupDescription.Value = "<Any>";
        }

        // Get column info
        WFMRuleColumnInfo columnInfo = WFMRule.GetColumnInfo();

        // Code
        txtCode.MaxCharacters = columnInfo.CodeLength;
        if (!addMode)
        {
            txtCode.Controls.OfType<TextBox>().First().Attributes.Add("readonly", "readonly");
            txtCode.Controls.OfType<TextBox>().First().BorderStyle = BorderStyle.None;
        }

        // Description
        txtDescription.MaxCharacters = columnInfo.DescriptionLength;

        // Update ward and label type
        UpdateWardSupCode(false);
        UpdateLabelType();
        UpdateSupplierType();

        UpdateCostMultiplierField();
        UpdateCostMultiplierLabel();

        UpdateStockField();
        UpdateStockMultiplierField();
        UpdateStockMultiplierLabel();

        // Update NSV Code
        txtNSVDescription.MaxCharacters = int.MaxValue;
        txtNSVDescription.Controls.OfType<TextBox>().First().Attributes.Add("readonly", "readonly");
        txtNSVDescription.Controls.OfType<TextBox>().First().BorderStyle = BorderStyle.None;

        txtExtraSQLFilter.MaxCharacters = columnInfo.ExtraSQLFilterLength;

        // set client side onclick
        btnCancel.Attributes.Add("onclick",   "window.close(); return false;");
//        txtSearch.Attributes.Add("onkeydown", "search_OnKeyDown(event);"     ); 
    }

    /// <summary>Populate form data</summary>
    /// <param name="recordID">record to edit</param>
    private void Edit(int recordID)
    {
        WFMRuleRow rule = WFMRule.GetByID(recordID);

        txtCode.Value = rule.Code.ToString();
        txtDescription.Value = rule.Description;

        lPharmacyLog.SelectedIndex = lPharmacyLog.Items.IndexOf(lPharmacyLog.Items.FindByValue(rule.PharmacyLog.ToString()));
        PopulateKindList();
        UpdateWardSupCode(true);
        UpdateLabelType();

        lKind.SelectedIndex = lKind.Items.IndexOf(lKind.Items.FindByValue(rule.Kind));
        lLabelType.SelectedIndex    = lLabelType.Items.IndexOf(lLabelType.Items.FindByValue(rule.LabelType));
        lSite.SelectedIndex         = lSite.Items.IndexOf(lSite.Items.FindByValue(rule.LocationID_Site == null ? string.Empty : rule.LocationID_Site.ToString()));  // 08Jan14 XN 81377
        lSupplierType.SelectedIndex = EnumExtensions.EnumIndexInListView(lSupplierType.Items, rule.SupplierType);

        hfNSVCode.Value         = rule.NSVCode;
        txtNSVDescription.Value = string.IsNullOrEmpty(rule.NSVCode) ? "<Any>" : rule.GetNSVDescription();

        hfWardSupCode.Value     = (rule.PharmacyLog == PharmacyLogType.Orderlog) ? rule.SupCode : rule.WardCode;
        if (rule.PharmacyLog == PharmacyLogType.Orderlog && rule.SupplierID != null)
            hfSupplierID.Value = rule.SupplierID.Value.ToString();
        txtWardSupDescription.Value = (rule.PharmacyLog == PharmacyLogType.Orderlog) ? rule.GetSupplierDescription() : rule.GetWardDescription();
        if (string.IsNullOrEmpty(txtWardSupDescription.Value))
            txtWardSupDescription.Value = "<Any>";

        UpdateSupplierType();

        lCostPosNeg.SelectedIndex  = EnumExtensions.EnumIndexInListView(lCostPosNeg.Items,  rule.FilterOnCostPosNeg );
        lStockPosNeg.SelectedIndex = EnumExtensions.EnumIndexInListView(lStockPosNeg.Items, rule.FilterOnStockPosNeg);

        txtExtraSQLFilter.Value = rule.ExtraSQLFilter;

        lAccountCode_Credit.SelectedIndex = lAccountCode_Credit.Items.IndexOf (lAccountCode_Credit.Items.FindByValue (rule.AccountCode_Credit.ToString()   ));
        lAccountCode_Debit.SelectedIndex  = lAccountCode_Debit.Items.IndexOf  (lAccountCode_Debit.Items.FindByValue  (rule.AccountCode_Debit.ToString()    ));
        lAccountCode_Vat_Credit.SelectedIndex = lAccountCode_Vat_Credit.Items.IndexOf(lAccountCode_Vat_Credit.Items.FindByValue (rule.AccountCode_Vat_Credit.ToString() ));
        lAccountCode_Vat_Debit.SelectedIndex  = lAccountCode_Vat_Debit.Items.IndexOf (lAccountCode_Vat_Debit.Items.FindByValue  (rule.AccountCode_Vat_Debit.ToString()  ));

        lCostField.SelectedIndex  = EnumExtensions.EnumIndexInListView(lCostField.Items, rule.CostFieldRequired ? "<Required>" : "<Ignore>");

        UpdateCostMultiplierField();
        lCostMultiply.SelectedIndex = EnumExtensions.EnumIndexInListView(lCostMultiply.Items, rule.CostMultiply );
        CostFieldChanged();
        UpdateCostMultiplierLabel();

        UpdateStockField();
        lStockField.SelectedIndex = EnumExtensions.EnumIndexInListView(lStockField.Items, rule.StockFieldSelector ?? "<Ignore>" );  // 30May13 XN  Replaced IgnoreStock with StockFieldSelector (65498)
        UpdateStockMultiplierField();
        lStockMultiply.SelectedIndex = EnumExtensions.EnumIndexInListView(lStockMultiply.Items, rule.StockMultiply );
        StockFieldChanged();
        UpdateStockMultiplierLabel();
    }

    /// <summary>Validates form</summary>
    private bool Validate()
    {
        string error;
        bool[] tabOk = { true, true };
        
        Sites sites = new Sites();
        sites.LoadAll(true);

        // Code
        if (addMode)
        {
            if (!Validation.ValidateText(txtCode, "Code", typeof(int), true, 1000, 9999, out error))
            {
                txtCode.ErrorMessage = error;
                tabOk[0] = false;
            }
            if (tabOk[0] && !WFMRule.CheckCodeIsUnique(int.Parse(txtCode.Value).ToString("0000")))
            {
                txtCode.ErrorMessage = "Code is not unique.";
                tabOk[0] = false;
            }
        }

        // Description
        if (!Validation.ValidateText(txtDescription, "Description", typeof(string), true, out error))
        {
            txtDescription.ErrorMessage = error;
            tabOk[0] = false;
        }

        // Account codes (any set)
        if (lAccountCode_Debit.SelectedIndex == -1)
        {
            accountError.InnerHtml = "Need an account code";
            lAccountCode_Debit.ErrorMessage = accountError.InnerHtml;
            tabOk[0] = false;
        }
        if (lAccountCode_Credit.SelectedIndex == -1)
        {
            accountError.InnerHtml = "Need an account code";
            lAccountCode_Credit.ErrorMessage = accountError.InnerHtml;
            tabOk[0] = false;
        }
        if (lAccountCode_Debit.SelectedIndex != -1 && lAccountCode_Debit.SelectedIndex == lAccountCode_Credit.SelectedIndex)
        {
            accountError.InnerHtml = "Need to be different";
            lAccountCode_Debit.ErrorMessage = lAccountCode_Credit.ErrorMessage = accountError.InnerHtml;
            tabOk[0] = false;
        }

        // Account VAT codes (any set)
        if ((lAccountCode_Vat_Credit.SelectedIndex == -1 && lAccountCode_Vat_Debit.SelectedIndex != -1) ||
            (lAccountCode_Vat_Credit.SelectedIndex != -1 && lAccountCode_Vat_Debit.SelectedIndex == -1))
        {
            if (lAccountCode_Vat_Credit.SelectedIndex == -1)
                lAccountCode_Vat_Credit.ErrorMessage = accountError.InnerHtml = "If debit set need credit code";
            if (lAccountCode_Vat_Debit.SelectedIndex  == -1)
                lAccountCode_Vat_Debit.ErrorMessage = accountError.InnerHtml = "If credit set need debit code";
            tabOk[0] = false;
        }
        if (lAccountCode_Vat_Debit.SelectedIndex != -1 && lAccountCode_Vat_Debit.SelectedIndex == lAccountCode_Vat_Credit.SelectedIndex)
        {
            accountError.InnerHtml = "Need to be different";
            lAccountCode_Debit.ErrorMessage = lAccountCode_Credit.ErrorMessage = accountError.InnerHtml;
            tabOk[0] = false;
        }


        // Cost field options
        if (!Validation.ValidateList(lCostField, "Cost Field", true, out error))
        {
            lCostField.ErrorMessage = error;
            tabOk[0] = false;
        }
        if (!Validation.ValidateList(lStockField, "Stock Field", true, out error))
        {
            lStockField.ErrorMessage = error;
            tabOk[0] = false;
        }

        // Pharmacy Log
        if (!Validation.ValidateList(lPharmacyLog, "Pharmacy Log", true, out error))
        {
            lPharmacyLog.ErrorMessage = error;
            tabOk[1] = false;
        }

        // Kind
        if (!Validation.ValidateList(lKind, "Kind", true, out error))
        {
            lKind.ErrorMessage = error;
            tabOk[1] = false;
        }

        //// Check site NSV Code is correct for site
        //if (!string.IsNullOrEmpty(hfNSVCode.Value) && !string.IsNullOrEmpty(lSite.SelectedValue))
        //{
        //    string NSVCode          = hfNSVCode.Value;
        //    int    locationID_Site  = int.Parse(lSite.SelectedValue);
        //    if (WProduct.GetByProductAndSiteID(NSVCode, locationID_Site) != null)
        //    {
        //        lKind.ErrorMessage = string.Format("Product '{0}' not present on site '{1:000}'", NSVCode, sites.FindByID(locationID_Site).SiteNumber);
        //        tabOk[1] = false;
        //    }
        //}

        //// Check site Sup\Ward code is correct for site
        //if (!string.IsNullOrEmpty(hfWardSupCode.Value) && !string.IsNullOrEmpty(lSite.SelectedValue))
        //{
        //    string  code             = hfWardSupCode.Value;
        //    int     locationID_Site  = int.Parse(lSite.SelectedValue);
            
        //    if (WSupplier.GetBySupCodeAndSite(code, locationID_Site) == null)
        //    {
        //        lKind.ErrorMessage = string.Format("Supplier\\Ward '{0}' not present on site '{1:000}'", code, sites.FindByID(locationID_Site).SiteNumber);
        //        tabOk[1] = false;
        //    }
        //}

        // Check rule is unique
        if (tabOk.All(t => t == true))
        {
            PharmacyLogType       logType           = EnumExtensions.ListItemValueToEnum<PharmacyLogType>(lPharmacyLog.SelectedValue);
            string                kind              = lKind.SelectedValue;
            string                labelType         = lLabelType.SelectedValue;
            int?                  locationID_Site   = string.IsNullOrEmpty(lSite.SelectedValue) ? (int?)null : int.Parse(lSite.SelectedValue);
            string                NSVCode           = hfNSVCode.Value;
            string                wardCode          = logType == PharmacyLogType.Translog ? hfWardSupCode.Value : string.Empty;
            string                supCode           = logType == PharmacyLogType.Orderlog ? hfWardSupCode.Value : string.Empty;
            SupplierType          supplierType      = EnumExtensions.ListItemValueToEnum<SupplierType>(lSupplierType.SelectedValue);
            WFMPositiveNegative   costPosNeg        = EnumExtensions.ListItemValueToEnum<WFMPositiveNegative>(lCostPosNeg.SelectedValue);
            WFMPositiveNegative   stockPosNeg       = EnumExtensions.ListItemValueToEnum<WFMPositiveNegative>(lStockPosNeg.SelectedValue);

            WFMRule rule = new WFMRule();
            rule.LoadByMatchingParameters(logType, kind, labelType, locationID_Site, supplierType, NSVCode, wardCode, supCode, costPosNeg, stockPosNeg);
            var duplicateRules = rule.Where(r => this.addMode || r.WFMRuleID != recordID);  // Need to include addMode to caluse in the case of cloning
            if (duplicateRules.Any()) 
            {
                // XN 18Mar14 Changed duplicate rule error to warning.
                spDuplicateRules.InnerText = duplicateRules.First().Code.ToString("0000");
                mbDuplicateRule.Visible = true;
                upMessageBox_ChangeWarning.Update();
                tabOk[1] = false; // Set to false so flags that there is a validation error
            }
        }

        if (tabOk[0] == false)
            radMultiPage.SelectedIndex = radTabStrip.SelectedIndex = 0;
        else if (tabOk[1] == false)
            radMultiPage.SelectedIndex = radTabStrip.SelectedIndex = 1;

        return tabOk.All(t => t == true);
    }

    /// <summary>Save the data</summary>
    /// <returns>Returns if form should be closed</returns>
    private bool Save()
    {
        WFMRule rules = new WFMRule();
        WFMRuleRow rule;
        bool close = true;

        if (addMode)
            rule = rules.Add();
        else
        {
            rules.LoadByID(recordID);
            rule = rules[0];
        }

        rule.Code            = short.Parse(txtCode.Value);
        rule.Description     = txtDescription.Value.XMLUnescape();
        rule.PharmacyLog     = EnumExtensions.ListItemValueToEnum<PharmacyLogType>(lPharmacyLog.SelectedValue);
        rule.Kind            = lKind.SelectedValue;
        rule.LabelType       = lLabelType.SelectedValue;
        rule.LocationID_Site = string.IsNullOrEmpty(lSite.SelectedValue) ? (int?)null : int.Parse(lSite.SelectedValue); // 08Jan14 XN 81377
        rule.SupplierType    = EnumExtensions.ListItemValueToEnum<SupplierType>(lSupplierType.SelectedValue);
        if (rule.PharmacyLog == PharmacyLogType.Orderlog && !string.IsNullOrEmpty(hfSupplierID.Value))
            rule.SupplierID = int.Parse(hfSupplierID.Value);
        rule.SupCode         = (rule.PharmacyLog == PharmacyLogType.Orderlog) ? hfWardSupCode.Value : string.Empty;
        rule.WardCode        = (rule.PharmacyLog == PharmacyLogType.Translog) ? hfWardSupCode.Value : string.Empty;
        rule.NSVCode         = hfNSVCode.Value;
        rule.ExtraSQLFilter  = txtExtraSQLFilter.Value.XMLUnescape();

        rule.FilterOnCostPosNeg  = EnumExtensions.ListItemValueToEnum<WFMPositiveNegative>(lCostPosNeg.SelectedValue );
        rule.FilterOnStockPosNeg = EnumExtensions.ListItemValueToEnum<WFMPositiveNegative>(lStockPosNeg.SelectedValue);

        rule.AccountCode_Debit  = short.Parse(lAccountCode_Debit.SelectedValue);
        rule.AccountCode_Credit = short.Parse(lAccountCode_Credit.SelectedValue);

        rule.AccountCode_Vat_Debit  = lAccountCode_Vat_Debit.SelectedIndex  == -1 ? (short?)null : short.Parse(lAccountCode_Vat_Debit.SelectedValue);
        rule.AccountCode_Vat_Credit = lAccountCode_Vat_Credit.SelectedIndex == -1 ? (short?)null : short.Parse(lAccountCode_Vat_Credit.SelectedValue);

        rule.CostFieldRequired   = lCostField.SelectedValue.EqualsNoCase ("<Required>");
        rule.StockFieldSelector  = lStockField.SelectedValue.EqualsNoCase("<Ignore>") ? null : lStockField.SelectedValue;    // 30May13 XN  Replaced IgnoreStock with StockFieldSelector (65498)
        rule.CostMultiply        = lCostMultiply.SelectedValue;
        rule.StockMultiply       = lStockMultiply.SelectedValue;

        // If adding or changed data ask user if they want to rebuild the log
        if (addMode || rule.HasDataChanged())
        {
            mbChangeWarning.Visible = true;
            upMessageBox_ChangeWarning.Update();
            close = false;
        }

        rules.Save();
        recordID = rule.WFMRuleID;
        hfRecordID.Value = recordID.ToString();

        return close;
    }

    /// <summary>
    /// Populate kind list (depends on Pharmacy Log type)
    /// read from WFMTransactionType table
    /// </summary>
    private void PopulateKindList()
    {
        PharmacyLogType logType = EnumExtensions.ListItemValueToEnum<PharmacyLogType>(lPharmacyLog.SelectedValue);

        // Load
        WFMTransactionType kinds = new WFMTransactionType();
        kinds.LoadByPharmacyLogType(logType);

        // Get original value
        string selectedValue = lKind.SelectedValue;

        // Populate
        lKind.Items.Clear();
        lKind.Items.Add(new ListItem("<Any>", string.Empty));
        lKind.Items.AddRange(kinds.Select(k => new ListItem(k.ToString(), k.Kind)).ToArray());

        // Reselect value of disable
        lKind.Enabled       = (logType != PharmacyLogType.Unknown);
        lKind.SelectedIndex = lKind.Items.IndexOf(lKind.Items.FindByValue(selectedValue));
    }

    /// <summary>
    /// Update ward and sup code text box (depends on pharmacy log type)
    /// 1. Enable or disable
    /// 2. Set caption
    /// 3. Set read only
    /// </summary>
    private void UpdateWardSupCode(bool clear)
    {
        PharmacyLogType logType = EnumExtensions.ListItemValueToEnum<PharmacyLogType>(lPharmacyLog.SelectedValue);
        bool enable = false;

        switch (logType)
        {
        case PharmacyLogType.Orderlog: 
            enable = true;
            txtWardSupDescription.Caption = "Orderlog Supplier:";
            break;
        case PharmacyLogType.Translog: 
            enable = true;
            txtWardSupDescription.Caption = "Translog Ward:";
            break; 
        }

        txtWardSupDescription.Enabled         = enable;
        btnWardSupCode.Enabled                = enable;
        btnWardSupCodeClear.Enabled           = enable;
        txtWardSupDescription.MaxCharacters   = int.MaxValue;
        if (clear)
        {
            txtWardSupDescription.Value = "<Any>";
            hfSupplierID.Value           = string.Empty;
            hfWardSupCode.Value         = string.Empty;
        }

        // Set read only
        txtWardSupDescription.Controls.OfType<TextBox>().First().Attributes.Add("readonly", "readonly");
        txtWardSupDescription.Controls.OfType<TextBox>().First().BorderStyle = BorderStyle.None;
    }

    /// <summary>Updates LabelType list box(depends on pharmacy log type)</summary>
    private void UpdateLabelType()
    {
        if (EnumExtensions.ListItemValueToEnum<PharmacyLogType>(lPharmacyLog.SelectedValue) == PharmacyLogType.Translog)
            lLabelType.Visible          = true;
        else
        {
            lLabelType.Visible      = false;
            lLabelType.SelectedIndex= 0; // Any
        }
    }

    private void UpdateSupplierType()
    {
        if (EnumExtensions.ListItemValueToEnum<PharmacyLogType>(lPharmacyLog.SelectedValue) == PharmacyLogType.Translog)
        {
            lSupplierType.Visible       = false;
            lSupplierType.SelectedIndex = 0;    // Any
        }
        else
            lSupplierType.Visible   = true;
    }
    
    private void UpdateCostMultiplierField()
    {
        PharmacyLogType pharmacyLog = EnumExtensions.ListItemValueToEnum<PharmacyLogType>(lPharmacyLog.SelectedValue);
        string[] costMultiplierFields;

        if (pharmacyLog == PharmacyLogType.Orderlog)
            costMultiplierFields = WFMSettings.RuleEditor.OrderlogCostMultiplier.Split(new char[]{ ',' }, StringSplitOptions.RemoveEmptyEntries);
        else
            costMultiplierFields = WFMSettings.RuleEditor.TranslogCostMultiplier.Split(new char[]{ ',' }, StringSplitOptions.RemoveEmptyEntries);

        string selectedValue = lCostMultiply.SelectedValue;
        if (string.IsNullOrEmpty(selectedValue) && pharmacyLog != PharmacyLogType.Unknown)
            selectedValue = costMultiplierFields.FirstOrDefault();

        lCostMultiply.Items.Clear();
        lCostMultiply.Items.AddRange(costMultiplierFields.Select(v => new ListItem(v)).ToArray());
        lCostMultiply.SelectedIndex = lCostMultiply.Items.IndexOf(lCostMultiply.Items.FindByValue(selectedValue));
    }
    
    private void UpdateStockField()
    {
        PharmacyLogType pharmacyLog = EnumExtensions.ListItemValueToEnum<PharmacyLogType>(lPharmacyLog.SelectedValue);
        string[] stockFields;

        if (pharmacyLog == PharmacyLogType.Orderlog)
            stockFields = WFMSettings.RuleEditor.OrderlogStockFields.Split(new char[]{ ',' }, StringSplitOptions.RemoveEmptyEntries);
        else
            stockFields = WFMSettings.RuleEditor.TranslogStockFields.Split(new char[]{ ',' }, StringSplitOptions.RemoveEmptyEntries);

        string selectedValue = lStockField.SelectedValue;
        if (string.IsNullOrEmpty(selectedValue) && pharmacyLog != PharmacyLogType.Unknown)
            selectedValue = stockFields.FirstOrDefault();

        lStockField.Items.Clear();
        lStockField.Items.AddRange(stockFields.Select(v => new ListItem(v)).ToArray());
        lStockField.SelectedIndex = lStockField.Items.IndexOf(lStockField.Items.FindByValue(selectedValue));
    }
    
    private void UpdateStockMultiplierField()
    {
        PharmacyLogType pharmacyLog = EnumExtensions.ListItemValueToEnum<PharmacyLogType>(lPharmacyLog.SelectedValue);
        string[] stockMultiplierFields;

        if (pharmacyLog == PharmacyLogType.Orderlog)
            stockMultiplierFields = WFMSettings.RuleEditor.OrderlogStockMultiplier.Split(new char[]{ ',' }, StringSplitOptions.RemoveEmptyEntries);
        else
            stockMultiplierFields = WFMSettings.RuleEditor.TranslogStockMultiplier.Split(new char[]{ ',' }, StringSplitOptions.RemoveEmptyEntries);

        string selectedValue = lStockMultiply.SelectedValue;
        if (string.IsNullOrEmpty(selectedValue) && pharmacyLog != PharmacyLogType.Unknown)
            selectedValue = stockMultiplierFields.FirstOrDefault();

        lStockMultiply.Items.Clear();
        lStockMultiply.Items.AddRange(stockMultiplierFields.Select(v => new ListItem(v)).ToArray());
        lStockMultiply.SelectedIndex = lStockMultiply.Items.IndexOf(lStockMultiply.Items.FindByValue(selectedValue));
    }
    
    // 30May13 XN  Replaced IgnoreStock with StockFieldSelector (65498)
    private void StockFieldChanged()
    {
        bool showStockValue = !lStockField.SelectedValue.EqualsNoCase("<Ignore>");

        lStockPosNeg.Enabled    = showStockValue;
        lStockMultiply.Visible  = showStockValue;
        lbStockMultiply.Visible = showStockValue;

        if (!showStockValue)
            lStockPosNeg.SelectedIndex  = EnumExtensions.EnumIndexInListView(lStockPosNeg.Items, WFMPositiveNegative.Any);
    }

    private void CostFieldChanged()
    {
        bool showCostValue = !lCostField.SelectedValue.EqualsNoCase("<Ignore>");

        lCostPosNeg.Enabled    = showCostValue;
        lCostMultiply.Visible  = showCostValue;
        lbCostMultiply.Visible = showCostValue;

        if (!showCostValue)
            lCostPosNeg.SelectedIndex  = EnumExtensions.EnumIndexInListView(lStockPosNeg.Items, WFMPositiveNegative.Any);
    }
    
    private void UpdateStockMultiplierLabel()
    {
        lbStockMultiply.Text = string.Format("Total Issue Units = {0} * {1}", lStockField.SelectedValue, lStockMultiply.SelectedValue);
    }
    
    private void UpdateCostMultiplierLabel()
    {
        lbCostMultiply.Text = string.Format("Total Cost = Cost * {0}", lCostMultiply.SelectedValue);
    }
    #endregion
}
