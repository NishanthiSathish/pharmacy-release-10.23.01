//===========================================================================
//
//						     PNRuleEditor.aspx.cs
//
//  Allows user to add or edit a rule.
//
//  Call the page with the follow parameters
//  SessionID                   - ICW session ID
//  SiteID                      - site ID
//  Mode                        - 'add' or 'edit'
//  PNRuleID                    - Id of record if in edit mode
//  RuleType                    - Rule type id (e.g.ingredientbyproduct, prescriptionproforma, regimenvalidation)
//  ReplicateToSiteNumbers      - Sites allowed to replicate to (optional)
//  SiteNumbersSelectedByDefault- Replicate to sites selected by default (optional)
//
//  User is only allowed to add new products based on WConfiguration setting
//  Category: D|PN
//  Section:  {RuleType}RuleEditor
//  Key:      AllowAdding
//
//  Fields that the user is allowed to edit is based on WConfiguration setting
//  Category: D|PN
//  Section:  {RuleType}RuleEditor
//  Key:      EditableFields
//  This provides a comma separated list of fields names. 
//
//  As basic validation for this page is shared with DssCustomisation page 
//  validation functions are performed by PNSettingsProcessor
//  
//  In IngredientByProduct mode 
//      critical checkbox is hidden
//      ingredient section is displayed (ingriedient to product )
//  In PrescriptionProforma mode 
//      critical checkbox is hidden
//      ingredients section is displayed (list of ingredients)
//  In RegimenValidation mode
//      critical checkbox is displayed
//      ingredient section is hidden
//  
//  Usage:
//  To add a rule
//  PNRuleEditor.aspx?SessionID=123&SiteID=24&Mode=add&DataType=IngredientByProduct
//
//  To edit a rule
//  PNRuleEditor.aspx?SessionID=123&SiteID=24&Mode=edit&PNRuleID=4&DataType=IngredientByProduct
//
//	Modification History:
//	31Oct11 XN  Written
//  23May12 XN  TFS32067 Updated form with missing DB value
//  29Jun12 XN  TFS36841 Don't force entry of Update Info for dss master db only
//  08Dec12 XN  TFS29186 Allow user to print out the PN product data.
//  26Oct15 XN  106278 Made it a multi site editor
//  7Jun16 XN   155170 Initialise fixed issue with product drop down not populated
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using _Shared;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;

public partial class application_PNSettings_PNRuleEditor : System.Web.UI.Page
{
    #region Constants
    /// <summary>Format for pharmacy date to long time string convert</summary>
    static readonly string LastModDateTimePattern = "dd/MM/yyyy HH:mm:ss.fff";
    #endregion

    #region Member variables
    /// <summary>If the form is in add or edit mode</summary>
    protected bool addMode = false;

    /// <summary>List of sites that are allowed for replication 26Oc15 XN 106278</summary>
    private List<Site2Row> replicateToSites;

    /// <summary>List of sites selected by default for replication 26Oc15 XN 106278</summary>
    private List<int> siteNumbersSelectedByDefault; 

    /// <summary>If in multi site edit mode 26Oc15 XN 106278</summary>
    private bool isMultiSiteEditMode;

    /// <summary>Type or rule e.g. Validation proforma</summary>
    protected RuleType ruleType;
    #endregion
    
    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        // Read parameters
        this.addMode                      = this.Request.QueryString["Mode"].EqualsNoCaseTrimEnd("add");
        this.replicateToSites             = Site2.Instance().FindBySiteNumber(this.Request["ReplicateToSiteNumbers"], true, CurrentSiteHandling.AtStart).ToList();
        this.siteNumbersSelectedByDefault = replicateToSites.FindBySiteNumber(this.Request["SiteNumbersSelectedByDefault"], allowAll: true).Select(s => s.SiteNumber).ToList();
        this.isMultiSiteEditMode          = this.replicateToSites.Count > 1;

        switch (Request["RuleType"].ToLower())
        {
        case "ingredientbyproduct":  ruleType = RuleType.IngredientByProduct;  break;
        case "prescriptionproforma": ruleType = RuleType.PrescriptionProforma; break;
        case "regimenvalidation":    ruleType = RuleType.RegimenValidation;    break;
        default: throw new ApplicationException("Invalid rule type " + Request["RuleType"]);
        }

        // As the list of ingredients controls are dynamically created
        // need to do this everytime form is loaded else will be lost
        CreateIngredients();

        if (!Page.IsPostBack)
        {
            // Update site lists (26Oc15 XN 106278)
            this.PopulateSiteList();
            this.UpdateReplicateToSiteList();

            // Setup for depending on mode
            if (this.addMode)
            {
                string logMessage = string.Format("User has started to add a new rule {0} (type {1}).\n{2}", ruleType, Request["RuleType"], lbtSites.Text);
                PNLog.WriteToLog(SessionInfo.SiteID, logMessage);
                Add();
            }
            else
            {
                int ruleID = int.Parse(Request["RuleID"]);
                PNLog.WriteToLog(SessionInfo.SiteID, null, null, null, ruleID, null, "User is viewing rule.\n" + lbtSites.Text, string.Empty);

                Edit(ruleID);
            }
        }
    }

    /// <summary>PreRender used to handle event args so dynamic controls have time to be populated 26Oct15 XN 106278</summary>
    protected override void OnPreRender(EventArgs e)
    {
        // Deal with __postBack events
        string   args      = Request["__EVENTARGUMENT"];
        string[] argParams = new string[0];
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        if (argParams.Length > 0)
        {
            switch (argParams[0])
            {
            case "PrintSite":
                // Print the data for the site
                int siteId = int.Parse(argParams[1]);
                this.Print(siteId);
                break;

            case "SelectedNewSites":    
                // When used selects new set of sites updates the site list
                UpdateReplicateToSiteList();

                // Update state to log
                int? pnRuleId = this.addMode ? (int?)null : int.Parse(hfRuleID.Value);
                PNLog.WriteToLog(SessionInfo.SiteID, null, null, null, pnRuleId, null, "Updated replication state\n" + lbtSites.Text, string.Empty);
                break;

            case "Save":
                bool saveOk = (this.ruleType == RuleType.PrescriptionProforma ? this.SaveProforma() : this.SaveRule());
                if (saveOk)
                {
                    this.ClosePage(this.hfRuleID.Value);
                }
                break;
            }
        }

        base.OnPreRender(e);
    }

    /// <summary>
    /// Called when save button is clicked 
    /// Validates, displays difference (in multi site mode), and saves a product
    /// 27Oct15 XN Updated for multi site editing 106278
    /// </summary>
    protected void Save_Click(object sender, EventArgs e)
    {
        var selectedReplicateToSiteIds = this.GetSelectedReplicateToSiteIds();
        if (this.ruleType == RuleType.PrescriptionProforma)
        {
            // Loads the rules (loads nothing for add mode)
            PNRulePrescriptionProforma rules = new PNRulePrescriptionProforma();
            rules.LoadByRuleNumber(int.Parse(this.addMode ? this.tbRuleNumber.Text : this.hfPNRuleNumber.Value));

            // Get rows selected for updating (need for validation and displaying differences)
            var selectedReplicateToSiteRules = rules.Where(r => selectedReplicateToSiteIds.Contains(r.LocationID_Site));

            // Validate and save (if multi site edit mode will display differences)
            if (this.Validate(selectedReplicateToSiteRules) && !this.DisplayDifferences(selectedReplicateToSiteRules))
            {
                if (this.SaveProforma())
                {
                    this.ClosePage(hfRuleID.Value);
                }
            }
        }
        else
        {
            // Loads the rules (loads nothing for add mode)
            PNRule rules = new PNRule();
            if (!this.addMode)
            {
                rules.LoadByRuleNumber(int.Parse(this.hfPNRuleNumber.Value));
            }

            // Get rows selected for updating (need for validation and displaying differences)
            var selectedReplicateToSiteRules = rules.Where(r => selectedReplicateToSiteIds.Contains(r.LocationID_Site));

            // Validate and save (if multi site edit mode will display differences)
            if (this.Validate(selectedReplicateToSiteRules) && !this.DisplayDifferences(selectedReplicateToSiteRules))
            {
                if (this.SaveRule())
                {
                    this.ClosePage(hfRuleID.Value);
                }
            }
        }
    }


    /// <summary>
    /// Called when print button is clicked.
    /// Generates XML to use with the report, and saves it to the session attribute
    /// Uses report 'Pharmacy Print Form Report {sitenumber}'
    /// 27Oct15 XN 106278 If multi site editor then display popup box to allow selection of site
    /// </summary>
    protected void Print_Click(object sender, EventArgs e)
    {
        if (this.isMultiSiteEditMode)
        {
            gridSites.AddColumn("Site", 100);
            foreach (var site in this.replicateToSites)
            {
                gridSites.AddRow();
                gridSites.AddRowAttribute("SiteID", site.SiteID.ToString());
                gridSites.SetCell(0, site.ToString());
            }
            gridSites.SelectRow(0);

            ScriptManager.RegisterStartupScript(this, this.GetType(), "showSitesToPrint", "showSitesToPrint();", true);
        }
        else
        {
            this.Print(SessionInfo.SiteID);
        }
    }

        
    /// <summary>
    /// Prints report for the site
    /// 27Oct15 XN 106278
    /// </summary>
    /// <param name="siteId">Site id</param>
    private void Print(int siteId)
    {
        ReportPrintForm report = new  ReportPrintForm();
        int siteNumber = Sites.GetNumberBySiteID(siteId);

        // Title (depends on report type)
        switch (ruleType)
        {
        case RuleType.IngredientByProduct:  report.Initialise("Emis Health PN Ingredient by Product", siteNumber); break;
        case RuleType.PrescriptionProforma: report.Initialise("Emis Health PN Prescription Proforma", siteNumber); break;
        case RuleType.RegimenValidation:    report.Initialise("Emis Health PN Regimen Validation",    siteNumber); break;
        }

        // General section
        report.StartNewSection("General");
        report.AddValue(lbRuleNumber,  tbRuleNumber    );
        report.AddValue(lbDescription, tbDescription   );
        report.AddValue(lbInUse,       cbInUse         );
        report.AddValue(lbPerKilo,     cbPerKilo       );

        // Details section
        report.StartNewSection("Details");
        report.AddValue(lbExplanation.InnerText, !tbExplanation.ReadOnly, tbExplanation.Text.Replace("[cr]", "\n"));
        report.AddEmptyLine();
        report.AddValue(lbRuleSQL, tbRuleSQL);
        if (cbCritical.Visible)
        {
            report.AddEmptyLine();
            report.AddValue(lbCritical, cbCritical);
        }

        // Ingredient section (for ingredient by product)
        if (ddlPNProduct.Visible && tbIngredient.Visible)
        {
            report.StartNewSection("Ingredient");
            report.AddValue(tbIngredient.Text + " supplied by ", ddlPNProduct.Enabled, ddlPNProduct.SelectedItem.Text);
        }

        // Ingredients section (for performa)
        if (this.ruleType == RuleType.PrescriptionProforma)
        {
            report.StartNewSection("Ingredients");
            report.AddValue(lbVol, tbVol);
            PNIngredient ingredients = PNIngredient.GetInstance();
            foreach (TextBox tbIng in GetAllIngredientTextBoxes())
            {
                PNIngredientRow ing = ingredients.FindByDBName(tbIng.ID);
                report.AddValue(string.Format("{0} ({1})", ing.Description.ToUpperFirstLetter(), ing.UnitDescription), !tbIng.ReadOnly, tbIng.Text);
            }
        }

        // Update info
        report.StartNewSection("Update info");
        report.AddValue("Last modified by", false, lbModifiedInfo.Text.Replace("Last modified by ", string.Empty));
        report.AddValue("Update info", !tbInfo.ReadOnly, tbInfo.Text);

        // Save report xml to session attribute
        report.Save();

        // Register script to perform the print
        // XN 11Mar13 58517 Help testing if report does not exist
        string reportName = report.GetReportName();
        if (OrderReport.IfReportExists(reportName))
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", string.Format("window.dialogArguments.icwwindow.document.frames['fraPrintProcessor'].PrintReport({0}, '{1}', 0, false, '');", SessionInfo.SessionID, reportName), true);
        else
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", string.Format("alert(\"Report not found '{0}'\");", reportName), true);
    }
    #endregion

    #region Public Methods
    /// <summary>Puts the from in add mode</summary>
    public void Add()
    {
        // Check if allowed to add
        if (!PNSettings.RuleEditor.GetAllowAdding(this.ruleType))
            throw new ApplicationException("You are not allowed to add PN rules. Call Emis Health DSS support services to have new rules added to your system.");

        // Initialise the form controls
        Initialise();

        // set the form controls
        tbRuleNumber.Text   = PNRule.GetNextRuleNumberBySiteIDAndType(SessionInfo.SiteID, this.ruleType).ToString();
        hfPNRuleNumber.Value= tbRuleNumber.Text;
        hfRuleID.Value      = "-1";
        hfOpenDate.Value    = string.Empty;

        if (this.ruleType == RuleType.PrescriptionProforma)
            GetAllIngredientTextBoxes().ForEach(i => i.Text = "0");
    }

    /// <summary>Puts form into edit mode</summary>
    /// <param name="ruleID">ID of the rule being edited</param>
    public void Edit(int ruleID)
    {
        // Set open date before loading 26Oct15 XN 106278
        hfOpenDate.Value = DateTime.Now.ToString(LastModDateTimePattern);

        // Get the rule
        PNRuleRow rule;
        if (this.ruleType == RuleType.PrescriptionProforma)
        {
            PNRulePrescriptionProforma rules = new PNRulePrescriptionProforma();
            rules.LoadByID(ruleID);
            rule = rules.First();
        }
        else
        {
            PNRule rules = new PNRule();
            rules.LoadByID(ruleID);
            rule = rules.First();
        }

        // Initialise the form controls
        Initialise();
        
        hfRuleID.Value      = rule.PNRuleID.ToString();
        hfPNRuleNumber.Value= rule.RuleNumber.ToString();

        // Set General items
        tbRuleNumber.Text       = rule.RuleNumber.ToString();
        tbDescription.Text      = rule.Description;
        cbInUse.Checked         = rule.InUse;
        cbPerKilo.Checked       = rule.PerKilo;

        // Set Detail items
        tbExplanation.Text  = rule.Explanation;
        tbRuleSQL.Text      = rule.RuleSQL;
        cbCritical.Checked  = rule.Critical;    // TFS32067 updates for PN part of DSS on the web

        // Ingredient
        //ListItem ingredientListItem = ddlIngredient.Items.FindByValue(rule.Ingredient);
        //if (ingredientListItem == null)
        //{
        //    ingredientListItem = new ListItem(rule.Ingredient, rule.Ingredient);
        //    ddlIngredient.Items.Add(ingredientListItem);
        //}
        //ddlIngredient.SelectedValue = rule.Ingredient;
        tbIngredient.Text = rule.Ingredient; // 22Feb12 AJK Changed ddl to tb

        ListItem pnProductListItem = ddlPNProduct.Items.FindByValue(rule.PNCode);
        if (pnProductListItem == null)
        {
            pnProductListItem = new ListItem(rule.PNCode, rule.PNCode);
            ddlPNProduct.Items.Add(pnProductListItem);
        }
        ddlPNProduct.SelectedValue = rule.PNCode;

        // Prescription proforma
        if (this.ruleType == RuleType.PrescriptionProforma)
        {
            PNRulePrescriptionProformaRow proforma = rule as PNRulePrescriptionProformaRow;
            tbVol.Text = (proforma.GetIngredient(PNIngDBNames.Volume) ?? 0.0).ToString("0.######");
            foreach (TextBox tbIng in GetAllIngredientTextBoxes())
            {
                double? value = proforma.GetIngredient(tbIng.ID);
                tbIng.Text = (value ?? 0.0).ToString("0.######");
            }
        }

        // Update info (Last modified by XN on 15/04/11 15:16 terminal Fred)
        bool hasBeenModified = false;
        StringBuilder modifiedInfo = new StringBuilder("Last modified");
        if (!string.IsNullOrEmpty(rule.LastModifiedUserInitials))
        {
            modifiedInfo.Append(" by ");
            modifiedInfo.Append(rule.LastModifiedUserInitials);
            hasBeenModified = true;
        }
        if (rule.LastModifiedDate.HasValue)
        {
            modifiedInfo.Append(" on ");
            modifiedInfo.Append(rule.LastModifiedDate.ToPharmacyDateTimeString());
            hasBeenModified = true;
        }
        if (!string.IsNullOrEmpty(rule.LastModifiedTerminal))
        {
            modifiedInfo.Append(" terminal ");
            modifiedInfo.Append(rule.LastModifiedTerminal);
            hasBeenModified = true;
        }
        lbModifiedInfo.Text = hasBeenModified ? modifiedInfo.ToString() : "Never been modified";
        tbInfo.Text         = rule.DSSInfo;
    }
    #endregion

    #region Private Methods
    /// <summary>If this is the DSS master db  29Jun12 XN TFS36841</summary>
    private bool IsDSSMasterDB()
    {
        return SettingsController.Load<bool>("Security", "Settings", "DSSMaster", false) && (Sites.GetNumberBySiteID(SessionInfo.SiteID) == 0);
    }

    /// <summary>
    /// Create the controls for the list of ingredients for the product.
    /// This is done dynamically
    /// </summary>
    private void CreateIngredients()
    {
        // Get list of ingredients
        // Filter to ones that have a field in the PNIngredient table
        PNRulePrescriptionProformaColumnInfo pnProformaColumns = PNRulePrescriptionProforma.GetColumnInfo();
        List<PNIngredientRow> ingredients = (from i in PNIngredient.GetInstance()
                                             where pnProformaColumns.FindColumnByName(i.DBName) != null && (i.DBName != PNIngDBNames.Volume)
                                             orderby i.SortIndex
                                             select i).ToList();

        for (int i = 0; i < ingredients.Count; i++)
        {
            PNIngredientRow ingredient = ingredients[i];
            TableRow newRow = new TableRow();
            TableCell cell;

            // Ingredients displayed in 2 colums so get the correct panel
            if (i < (ingredients.Count / 2))
                tbIngredientsLeft.Rows.Add(newRow);
            else
                tbIngredientsRigth.Rows.Add(newRow);

            // Add ingredient label
            cell = new TableCell();
            cell.Style["border-bottom"] = "solid 1px #9CCFFF";
            Label name = new Label();
            name.Text = ingredient.Description.ToUpperFirstLetter() + "&nbsp;";
            cell.Controls.Add(name);
            newRow.Cells.Add(cell);

            // Add ingredient textbox
            cell = new TableCell();
            cell.Style["border-bottom"] = "solid 1px #9CCFFF";
            TextBox value = new TextBox();
            value.ID = ingredient.DBName;
            value.Attributes["LongName"] = ingredient.Description;
            value.Width = new Unit(55.0, UnitType.Pixel);
            value.Style["text-align"] = "right";
            cell.Controls.Add(value);
            newRow.Cells.Add(cell);

            // Add unit label
            cell = new TableCell();
            cell.Style["border-bottom"] = "solid 1px #9CCFFF";
            Label units = new Label();
            units.Text = "&nbsp;" + ingredient.UnitDescription;
            cell.Controls.Add(units);
            newRow.Cells.Add(cell);

            // Add attribute to select all cell text on focus
            value.Attributes["onfocus"] = "'this.select()'";
        }
    }

    /// <summary>Gets all the ingredients text boxes</summary>
    private List<TextBox> GetAllIngredientTextBoxes()
    {        
        IEnumerable<TextBox> leftPanel = tbIngredientsLeft.Controls.OfType <Control>().Desendants(c => c.Controls.OfType<Control>()).OfType<TextBox>();
        IEnumerable<TextBox> rigthPnnel= tbIngredientsRigth.Controls.OfType<Control>().Desendants(c => c.Controls.OfType<Control>()).OfType<TextBox>();

        return leftPanel.Union(rigthPnnel).ToList();
    }

    /// <summary>
    /// Initialise the controls to be readonly depending on WConfiguration setting
    ///  Category: D|PN
    ///  Section:  {RuleType}RuleEditor
    ///  Key:      EditableFields
    /// </summary>
    private void Initialise()
    {
        HashSet<string> editableFields = PNSettings.RuleEditor.GetEditableFields(this.ruleType);
        //bool showCustomisationButtons = !addMode && SettingsController.Load<bool>("Security", "Settings", "DSSMaster", false) && (Sites.GetNumberBySiteID(siteID) == 0);  29Jun12 XN TFS36841
        bool showCustomisationButtons = !addMode && IsDSSMasterDB();

        // Clean the form
        IEnumerable<Control> pageControls = Page.Controls.OfType<Control>().Desendants(i => i.Controls.OfType<Control>()).ToList();
        pageControls.OfType<TextBox>().ToList().ForEach (t => t.Text    = string.Empty);
        pageControls.OfType<CheckBox>().ToList().ForEach(t => t.Checked = false       );
        pageControls.OfType<Label>().Where(l => l.CssClass == "ErrorMessage").ToList().ForEach(t => t.Text="&nbsp;");

        // General
        tbRuleNumber.ReadOnly   = !(addMode || editableFields.Contains("rulenumber"));
        tbDescription.ReadOnly  = !(addMode || editableFields.Contains("description"));
        btnDescription.Visible  = !tbDescription.ReadOnly && showCustomisationButtons;
        cbInUse.Enabled         =   addMode || editableFields.Contains("inuse");
        cbPerKilo.Enabled       =   addMode || editableFields.Contains("perkilo");

        // Details
        tbExplanation.ReadOnly  = !(addMode || editableFields.Contains("explanation"));
        if (tbExplanation.ReadOnly)
            tbExplanation.BackColor = Color.FromArgb(235, 235, 235);
        btnExplanation.Visible = !tbExplanation.ReadOnly && showCustomisationButtons;

        tbRuleSQL.ReadOnly  = !(addMode || editableFields.Contains("rulesql"));
        if (tbRuleSQL.ReadOnly)
            tbRuleSQL.BackColor = Color.FromArgb(235, 235, 235);
        btnRuleSQL.Visible = !tbRuleSQL.ReadOnly && showCustomisationButtons;

        cbCritical.Enabled      =   addMode || editableFields.Contains("critical");
        pnCritical.Visible      = (this.ruleType == RuleType.RegimenValidation);

        // Ingredients (only for ingredients that are in PNProduct table)
        if (this.ruleType == RuleType.IngredientByProduct)
        {
            var ingredientsAsListItems = PNIngredient.GetInstance().OrderBy(p => p.ShortDescription).FindByForPNProduct(false).Select(i => new ListItem(i.ShortDescription, i.ShortDescription));
            //ddlIngredient.Items.Clear();
            //ddlIngredient.Items.Add(new ListItem(string.Empty, string.Empty));
            //ddlIngredient.Items.AddRange(ingredientsAsListItems.ToArray());
            //ddlIngredient.Enabled = addMode || editableFields.Contains("ingredient");
            tbIngredient.ReadOnly = !(addMode || editableFields.Contains("ingredient")); // 22Feb12 AJK Changed ddl to tb

            PNProduct products = new PNProduct();
            //products.LoadBySite(SessionInfo.SessionID);   7Jun16 155170 XN    // Don't use cached products as may not of been reloaded yet.
            products.LoadBySite(SessionInfo.SiteID);       // Don't use cached products as may not of been reloaded yet.
            var productAsListItems = products.Where(p => p.InUse).OrderBy(p => p.PNCode).Select(p => new ListItem(p.PNCode + " - " + p.Description, p.PNCode));
            ddlPNProduct.Items.Clear();
            ddlPNProduct.Items.Add(new ListItem(string.Empty, string.Empty));
            ddlPNProduct.Items.AddRange(productAsListItems.ToArray());
            ddlPNProduct.Enabled = addMode || editableFields.Contains("ingredientproduct");
        }
        pnIngredientSection.Visible = (this.ruleType == RuleType.IngredientByProduct);

        // Prescription proforma
        if (this.ruleType == RuleType.PrescriptionProforma)
        {
            tbVol.ReadOnly = !addMode && !editableFields.Contains("ingredients");
            GetAllIngredientTextBoxes().ForEach(i => i.ReadOnly = !addMode && !editableFields.Contains("ingredients"));
        }
        pnProformaIngredient.Visible = (this.ruleType == RuleType.PrescriptionProforma);

        // Update info
        tbInfo.ReadOnly = !(addMode || editableFields.Contains("info"));
        if (tbInfo.ReadOnly)
            tbInfo.BackColor = Color.FromArgb(235, 235, 235);
    }

    /// <summary>
    /// Validates the forms data
    /// Only validates writable controls
    /// 26Oct15 XN 106278 Update to support multiple sites
    /// </summary>
    /// <param name="rule">Rule to validate (null if adding new) used to check editing times</param>
    /// <returns>If valid form data</returns>
    private bool Validate(IEnumerable<PNRuleRow> rules)
    {
        PNIngredient    ingredients = PNIngredient.GetInstance();
        PNRuleColumnInfo columnInfo = PNRule.GetColumnInfo();
        string error = string.Empty;
        bool ok = true;

        // Get the time the page was opened
        DateTime? openDate = null;
        if (!string.IsNullOrEmpty(hfOpenDate.Value))
            openDate = DateTime.ParseExact(hfOpenDate.Value, LastModDateTimePattern, CultureInfo.CurrentCulture);

        // If editing and date of db record is older than the open date then error
        if (openDate != null && rules.Any(p => p.LastModifiedDate != null && openDate < p.LastModifiedDate))
        {
            StringBuilder errorMsg = new StringBuilder();
            errorMsg.Append("Product has been updated by another user.<br />");
            foreach (var r in rules.Where(p => p.LastModifiedDate != null && openDate < p.LastModifiedDate))
            {
                errorMsg.Append("User: " + r.LastModifiedUserInitials.Replace("'", "\\'") + "<br />");
                errorMsg.Append("Date: " + r.LastModifiedDate.ToPharmacyDateString() + "<br />");
                if (this.isMultiSiteEditMode)
                {
                    errorMsg.AppendFormat("Site: {0:000}<br />", Site2.GetSiteNumberByID(r.LocationID_Site));
                }
                errorMsg.Append("<br />");
                errorMsg.Append("Please cancel your changes, refresh list of rule, and re-edit.");
            }
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "EditByAnotherUser", "alertEnh('" + errorMsg + "');", true);
            return false;
        }

        // Clear all error labels
        Page.Controls.OfType<Control>().Desendants(i => i.Controls.OfType<Control>()).OfType<Label>().Where(l => l.CssClass == "ErrorMessage").ToList().ForEach(t => t.Text="&nbsp;");

        // General information
        if (tbRuleNumber.Visible && !tbRuleNumber.ReadOnly)
        {
            if (!PNSettingsProcessor.RangeValidationPNRule(columnInfo, tbRuleNumber, lbRuleNumberError, "rulenumber", this.ruleType))
                ok = false;
            else
            {
                foreach (int siteId in this.GetSelectedReplicateToSiteIds())
                {
                    PNRuleRow matchingRuleNumber = PNRule.GetBySiteIDAndRuleNumber(siteId, int.Parse(tbRuleNumber.Text));
                    if (matchingRuleNumber != null && !rules.Any(r => r.PNRuleID == matchingRuleNumber.PNRuleID))
                    {
                        lbRuleNumberError.Text = "Rule number not unique" + (this.isMultiSiteEditMode ? " site " + Site2.GetSiteNumberByID(siteId).ToString() : string.Empty);
                        ok = false;
                        break;
                    }
                }
            }
        }

        if (tbDescription.Visible && !tbDescription.ReadOnly && !PNSettingsProcessor.RangeValidationPNRule(columnInfo, tbDescription, lbDescriptionError, "description", this.ruleType))
            ok = false;

        // Details
        if (tbExplanation.Visible && !tbExplanation.ReadOnly && !PNSettingsProcessor.RangeValidationPNRule(columnInfo, tbExplanation, lbExplanationError, "explanation", this.ruleType))
            ok = false;
        if (tbRuleSQL.Visible && !tbRuleSQL.ReadOnly && !PNSettingsProcessor.RangeValidationPNRule(columnInfo, tbRuleSQL, lbRuleSQLError, "rulesql", this.ruleType))
            ok = false;

        // Ingredients
        //if (ddlIngredient.Visible && ddlIngredient.Enabled && ddlPNProduct.Visible && ddlPNProduct.Enabled)
        if (tbIngredient.Visible && tbIngredient.Enabled && ddlPNProduct.Visible && ddlPNProduct.Enabled) // 22Feb12 AJK Changed ddl to tb
        {
            //if (!Validation.ValidateDropDownList(ddlIngredient, "Ingredient", true, out error))
            if (!Validation.ValidateText(tbIngredient, "Ingredient", typeof(string), true, columnInfo.IngredientLength, out error)) // 22Feb12 AJK Changed ddl to tb
            {
                lbIngredientError.Text = error;
                ok = false;
            }
            else if (!Validation.ValidateDropDownList(ddlPNProduct, "Product", true, out error))
            {
                lbIngredientError.Text = error;
                ok = false;
            }
            else 
            {
                foreach (int siteId in this.GetSelectedReplicateToSiteIds())
                {
                    PNProductRow product = PNProduct.GetBySiteIDAndPNCode(siteId, ddlPNProduct.SelectedValue);
                    if (product == null)
                    {
                        lbIngredientError.Text = "Invalid product" + (this.isMultiSiteEditMode ? " site " + Site2.GetSiteNumberByID(siteId).ToString() : string.Empty);
                        ok = false;
                        break;
                    }
                    else if (product != null && !cbPerKilo.Checked && !product.ForAdult)   // check if rule for adult, product is for adult
                    {
                        lbIngredientError.Text = "Product is not for adults" + (this.isMultiSiteEditMode ? " site " + Site2.GetSiteNumberByID(siteId).ToString() : string.Empty);
                        ok = false;
                        break;
                    }
                    else if (product != null && cbPerKilo.Checked && !product.ForPaediatric) // check if rule for paed, product is for paed
                    {
                        lbIngredientError.Text = "Product is not for paediatrics" + (this.isMultiSiteEditMode ? " site " + Site2.GetSiteNumberByID(siteId).ToString() : string.Empty);
                        ok = false;
                        break;
                    }
                }
            }
        }

        // Prescription proforma
        if (this.ruleType == RuleType.PrescriptionProforma)
        {
            if (!tbVol.ReadOnly && !Validation.ValidateText(tbVol, string.Empty, typeof(double), true, 0.0, double.MaxValue, out error))
            {
                lbVolError.Text = error;
                ok = false;
            }
            foreach (TextBox tbIng in GetAllIngredientTextBoxes())
            {
                if (!tbIng.ReadOnly && !Validation.ValidateText(tbIng, tbIng.Attributes["LongName"], typeof(double), true, 0.0, double.MaxValue, out error))
                {
                    lbProformaIngredientError.Text = error;
                    ok = false;
                    break;
                }
            }
        }

        // Update Info
        if (tbInfo.Visible && !tbInfo.ReadOnly && !PNSettingsProcessor.RangeValidationPNRule(columnInfo, tbInfo, lbInfoError, "info", this.ruleType))
            ok = false;

        return ok;
    }

    /// <summary>
    /// If multi site mode, and not adding, will display all the difference, and ask if the form should be saved
    /// 26Oct15 XN 106278
    /// </summary>
    /// <param name="products">Original rules from db</param>
    /// <returns>If difference form is displayed</returns>
    private bool DisplayDifferences(IEnumerable<PNRuleRow> rules)
    {
        // If not in multi site mode then returned
        if (!this.isMultiSiteEditMode)
        {
            return false;
        }

        QSDifferencesList differences = new QSDifferencesList();
        
        // Add site where rule will be inserted to the list
        var siteWithOutRule = (from s in this.GetSelectedReplicateToSiteIds() where rules.FindFirstBySiteId(s) == null select s).ToList();
        siteWithOutRule.ForEach(s => differences.Add(s, "New item", "Will add item", string.Empty));

        // Compare product values
        this.CompareValues(differences, rules, r => r.RuleNumber.ToString(),     tbRuleNumber.Text,                  "Rule Number");
        this.CompareValues(differences, rules, r => r.Description,               tbDescription.Text,                 "Description");
        this.CompareValues(differences, rules, r => r.InUse.ToYesNoString(),     cbInUse.Checked.ToYesNoString(),    "In-Use"     );
        this.CompareValues(differences, rules, r => r.PerKilo.ToYesNoString(),   cbPerKilo.Checked.ToYesNoString(),  "Per Kilo"   );
        this.CompareValues(differences, rules, r => r.Explanation,               tbExplanation.Text,                 "Explanation");
        this.CompareValues(differences, rules, r => r.RuleSQL,                   tbRuleSQL.Text,                     "Rule SQL"   );
            
        if (cbCritical.Visible)
        {
            this.CompareValues(differences, rules, r => r.Critical.ToYesNoString(), cbCritical.Checked.ToYesNoString(), "Critical");
        }   

        if (ddlPNProduct.Visible)
        {
            this.CompareValues(differences, rules, r => r.PNCode, ddlPNProduct.SelectedValue, "PN Product");
        }

        if (pnIngredientSection.Visible)
        {
            this.CompareValues(differences, rules, r => r.Ingredient, tbIngredient.Text, "Ingredient");
        }

        var proformas = rules.OfType<PNRulePrescriptionProformaRow>();
        if (pnProformaIngredient.Visible && proformas.Any())
        {
            this.CompareValues(differences, proformas, r => (r.GetIngredient(PNIngDBNames.Volume) ?? 0.0).ToString("0.######"), tbVol.Text, PNIngDBNames.Volume);
            foreach (TextBox tbIng in GetAllIngredientTextBoxes())
            {
                this.CompareValues(differences, proformas, r => (r.GetIngredient(tbIng.ID) ?? 0.0).ToString("0.######"), tbIng.Text, tbIng.ID);
            }
        }   

        this.CompareValues(differences, rules, r => r.DSSInfo, tbInfo.Text, "DSS Info");

        // Display any difference in a popup
        if (differences.Any())
        {
            string msg = string.Format("<div style='max-height:500px;overflow-y:scroll;overflow-x:hidden;'>{0}</div><br /><p>OK to save the changes?</p>", differences.ToHTML( Sites.GetDictonarySiteIDToNumber() ));
            string script = string.Format("confirmEnh(\"{0}\", true, function() {{ __doPostBack('{1}', 'Save') }}, undefined, '450px');", msg, updatePanel.ClientID);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Info", script, true);
        }
        else
        {
            string script = "confirmEnh(\"No changes have been made.<br /><br />Close the editor?\", true, function() {{ window.close(); }}, undefined, '450px');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Info", script, true);
        }

        return true;
    }

    /// <summary>
    /// if was and now are different will add the item to differences
    /// Will only compare items that have been edited
    /// 26Oct15 XN 106278
    /// </summary>
    /// <param name="differences">List of differences</param>
    /// <param name="rules">list of rules to check (should only be the rules for sites selected for replication)</param>
    /// <param name="funcWas">function to get the existing value from the rule</param>
    /// <param name="now">what the new value is</param>
    /// <param name="description">Control name</param>
    private void CompareValues<T>(QSDifferencesList differences, IEnumerable<T> rules, Func<T,string> funcWas, string now, string description) where T : PNRuleRow, new()
    {
        // If the item has been edited (different from what is in the DB)
        // Then log the difference, and check all other sites (if not different then don't compare other sites)
        var rule  = rules.FindFirstBySiteId(SessionInfo.SiteID);
        if (rule == null || funcWas.Invoke(rule) != now)
        {
            // Check all sites
            foreach (var r in rules)
            {
                if (funcWas.Invoke(r) != now)
                {
                    differences.Add(r.LocationID_Site, description, now, funcWas.Invoke(r));
                }
            }
        }
    }

    /// <summary>Fill rule row from the from</summary>
    /// <param name="rule">Rule to fill</param>
    private void FillRule(PNRuleRow rule)
    {
        rule.RuleType        = this.ruleType;

        // General
        rule.RuleNumber      = int.Parse(tbRuleNumber.Text);
        rule.Description     = tbDescription.Text;
        rule.InUse           = cbInUse.Checked;
        rule.PerKilo         = cbPerKilo.Checked;

        // Details
        rule.Explanation     = tbExplanation.Text;
        rule.RuleSQL         = tbRuleSQL.Text;
        rule.Critical        = cbCritical.Visible && cbCritical.Checked;

        // Ingredients
        rule.PNCode          = ddlPNProduct.Visible  ? ddlPNProduct.SelectedValue  : string.Empty;
        //rule.Ingredient = ddlIngredient.Visible ? ddlIngredient.SelectedValue : string.Empty;
        rule.Ingredient      = tbIngredient.Visible ? tbIngredient.Text : string.Empty; // 22Feb12 AJK Changed ddl to tb

        // Update info
        rule.LastModifiedDate= DateTime.Now;
        rule.LastModifiedUserInitials = SessionInfo.UserInitials.SafeSubstring(0, PNRule.GetColumnInfo().LastModifiedUserInitialsLength);
        rule.LastModifiedTerminal     = SessionInfo.Terminal.SafeSubstring    (0, PNRule.GetColumnInfo().LastModifiedTerminalLength);
        rule.DSSInfo         = tbInfo.Text;
    }

    /// <summary>Fill rule proforma from the from</summary>
    /// <param name="rule">Rule to fill</param>
    private void FillPrescriptionProforma(PNRulePrescriptionProformaRow proforma)
    {
        proforma.SetIngredient(PNIngDBNames.Volume, double.Parse(tbVol.Text));
        foreach (TextBox tbIng in GetAllIngredientTextBoxes())
        {
            double? value = string.IsNullOrEmpty(tbIng.Text) ? (double?)null : double.Parse(tbIng.Text);
            proforma.SetIngredient(tbIng.ID, value);
        }
    }

    /// <summary>Save form rule data</summary>
    private bool SaveRule()
    {
        Dictionary<PNRuleRow,string> ruleToLog = new Dictionary<PNRuleRow,string>();
        PNRuleColumnInfo columnInfo = PNRule.GetColumnInfo();
        PNRule rulesTemp = new PNRule();
        StringBuilder log = new StringBuilder();
        bool bOK = false;

        PNRule rules = new PNRule();
        if (!this.addMode)
        {
            rules.LoadByRuleNumber(int.Parse(hfPNRuleNumber.Value));
        }

        // Save to each of sites selected for replication
        foreach (var siteId in this.GetSelectedReplicateToSiteIds())
        {
            PNRuleRow ruleOringal = rulesTemp.Add();

            PNRuleRow rule = rules.FindFirstBySiteId(siteId);
            if (rule == null)
            {
                rule = rules.Add();
                rule.LocationID_Site = siteId;
            }
            else
            {                
                ruleOringal.CopyFrom(rule); // If editing exist row take copy (for log)
            }

            // Fill rule data (if new row or row for main site then fill from form data)
            // If replicate to site then update only the rows that have been edit
            if (siteId == SessionInfo.SiteID || rule.RawRow.RowState == DataRowState.Added)
            {
                this.FillRule(rule);
            }
            else
            {
                var copyFromRow = rules.FindFirstBySiteId(SessionInfo.SiteID);
                rule.CopyFrom(copyFromRow, copyFromRow.GetChangedColumns().Select(c => c.ColumnName));
            }

            // Generate log
            log.Clear();
            if (rule.RawRow.RowState == DataRowState.Added)
            {
                PNLog.AddDataRow(log, "Adding new rule (Rule Number: " + rule.RuleNumber + ")", rule.RawRow);
            }
            else
            {
                log.AppendLine("Updated following rule details (Rule Number: " + rule.RuleNumber + "):");
                PNLog.CompareDataRow(log, ruleOringal.RawRow, rule.RawRow);
            }

            ruleToLog.Add(rule, log.ToString());
        }

        // Save
        try
        {
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                rules.Save();
                foreach (var item in ruleToLog)
                {
                    PNRuleRow r = (item.Key as PNRuleRow);
                    PNLog.WriteToLog(r.LocationID_Site, null, null, null, r.PNRuleID, null, item.Value, string.Empty);
                }
                trans.Commit();
            }

            // Update hidden fields
            hfPNRuleNumber.Value = rules.FindFirstBySiteId(SessionInfo.SiteID).RuleNumber.ToString();
            hfRuleID.Value       = rules.FindFirstBySiteId(SessionInfo.SiteID).PNRuleID.ToString();

            bOK = true;
        }
        catch (DBConcurrencyException)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "EditByAnotherUser", "alert('Rule has been recently modified, and can't be saved. Refresh list and try again.');", true);
        }

        return bOK;
    }

    /// <summary>Save form proforma data</summary>
    private bool SaveProforma()
    {
        Dictionary<PNRuleRow,string> ruleToLog = new Dictionary<PNRuleRow,string>();
        PNRuleColumnInfo columnInfo = PNRulePrescriptionProforma.GetColumnInfo();
        PNRulePrescriptionProforma proformasTemp = new PNRulePrescriptionProforma();
        StringBuilder log = new StringBuilder();
        bool bOK = false;

        PNRulePrescriptionProforma proformas = new PNRulePrescriptionProforma();
        if (!this.addMode)
        {
            proformas.LoadByRuleNumber(int.Parse(hfPNRuleNumber.Value));
        }

        // Save to each of sites selected for replication
        foreach (var siteId in this.GetSelectedReplicateToSiteIds())
        {
            PNRulePrescriptionProformaRow proformaOringal = proformasTemp.Add();

            PNRulePrescriptionProformaRow proforma = proformas.FindFirstBySiteId(siteId);
            if (proforma == null)
            {
                proforma = proformas.Add();
                proforma.LocationID_Site = siteId;
            }
            else
            {
                proformaOringal.CopyFrom(proforma); // If editing exist row take copy (for log)
            }

            // Fill rule data (if new row or row for main site then fill from form data)
            // If replicate to site then update only the rows that have been edit
            if (siteId == SessionInfo.SiteID || proforma.RawRow.RowState == DataRowState.Added)
            {
                this.FillRule(proforma);
                this.FillPrescriptionProforma(proforma);
            }
            else
            {
                var copyFromRow = proformas.FindFirstBySiteId(SessionInfo.SiteID);
                proforma.CopyFrom(copyFromRow, copyFromRow.GetChangedColumns().Select(c => c.ColumnName));
            }

            // Generate log
            log.Clear();
            if (proforma.RawRow.RowState == DataRowState.Added)
            {
                PNLog.AddDataRow(log, "Adding new rule (Rule Number: " + proforma.RuleNumber + ")", proforma.RawRow);
            }
            else
            {
                log.AppendLine("Updated following rule details (Rule Number: " + proforma.RuleNumber + "):");
                PNLog.CompareDataRow(log, proformaOringal.RawRow, proforma.RawRow);
            }

            ruleToLog.Add(proforma, log.ToString());
        }

        // Save
        try
        {
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                proformas.Save();
                foreach (var item in ruleToLog)
                {
                    PNRuleRow r = (item.Key as PNRuleRow);
                    PNLog.WriteToLog(r.LocationID_Site, null, null, null, r.PNRuleID, null, item.Value, string.Empty);
                }
                trans.Commit();
            }

            // Update hidden fields
            hfPNRuleNumber.Value = proformas.FindFirstBySiteId(SessionInfo.SiteID).RuleNumber.ToString();
            hfRuleID.Value       = proformas.FindFirstBySiteId(SessionInfo.SiteID).PNRuleID.ToString();

            bOK = true;
        }
        catch (DBConcurrencyException)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "EditByAnotherUser", "alert('Rule has been recently modified, and can't be saved. Refresh list and try again.');", true);
        }

        return bOK;
    }


    /// <summary>
    /// Populate the list of sites check list (for HK)
    /// 26Oct15 XN 106278
    /// </summary>
    private void PopulateSiteList()
    {
        // Populate check list
        cblSites.Items.Clear();
        foreach (var s in this.replicateToSites)
        {
            if (s.SiteNumber != SessionInfo.SiteNumber)
            {
                ListItem li = new ListItem(s.ToString(), s.SiteID.ToString());
                li.Selected = this.siteNumbersSelectedByDefault.Contains(s.SiteNumber);
                cblSites.Items.Add(li);
            }
        }
    }

    /// <summary>
    /// Updates the replicate to sites message depending on sites selected
    /// 26Oct15 XN 106278
    /// </summary>
    private void UpdateReplicateToSiteList()
    {
        StringBuilder  sitesLabel = new StringBuilder();
        List<ListItem> checkBoxes = cblSites.Items.OfType<ListItem>().ToList();

        // If only no sites then don't show replicate text
        if (checkBoxes.Count == 0)
        {
            lbtSites.Visible = false;
            return;
        }

        // List sites being replicated to
        IEnumerable<string> siteNumbersSelected = checkBoxes.Where(li => li.Selected).Select(li => li.Text.Split(' ')[0]);
        if (siteNumbersSelected.Any())
        {
            sitesLabel.AppendFormat("Replicate to sites {0}<br />", siteNumbersSelected.ToCSVString(","));
        }
        else if (cblSites.Items.OfType<ListItem>().Any(c => c.Enabled))
        {
            sitesLabel.Append("No sites selected for replication<br />");
        }
        else
        {
            sitesLabel.Append("No sites available for replication<br />");
        }

        // List sites not replicated to
        IEnumerable<string> siteNumbersNotSelected = checkBoxes.Where(li => li.Enabled && !li.Selected).Select(li => li.Text.Split(' ')[0]);
        if (siteNumbersNotSelected.Any())
        {
            sitesLabel.AppendFormat("Will not replicate to sites {0}<br />", siteNumbersNotSelected.ToCSVString(","));
        }

        // Show sites that are not available for replication (not currently used but keep in just in-case)
        IEnumerable<string> siteNumbersNotAvailable = checkBoxes.Where(li => !li.Enabled).Select(li => li.Text.Split(' ')[0]);
        if (siteNumbersNotAvailable.Any())
        {
            sitesLabel.Append("Cannot replicate to sites " + siteNumbersNotAvailable.ToCSVString(", "));
        }
        lbtSites.Text = sitesLabel.ToString();
    }

    /// <summary>
    /// Returns list of site ids included for replication to
    /// Will always include the current site though it does not appear in the list
    /// 26Oct15 XN 106278
    /// </summary>
    /// <returns>Returns list of sites ids selected to replicate to plus current site</returns>
    private IEnumerable<int> GetSelectedReplicateToSiteIds()
    {
        List<int> results = new List<int>();
        results.Add(SessionInfo.SiteID);
        results.AddRange(cblSites.Items.Cast<ListItem>().Where(s => s.Selected).Select(s => int.Parse(s.Value)));
        return results;
    }
    #endregion
}
