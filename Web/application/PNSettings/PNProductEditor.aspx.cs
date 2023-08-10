//===========================================================================
//
//						     PNProductEditor.aspx.cs
//
//  Allows user to add or edit a product.
//
//  Call the page with the follow parameters
//  SessionID                   - ICW session ID
//  SiteID                      - site ID
//  Mode                        - 'add' or 'edit'
//  PNProductID                 - Id of record if in edit mode
//  ReplicateToSiteNumbers      - Sites allowed to replicate to (optional)
//  SiteNumbersSelectedByDefault- Replicate to sites selected by default (optional)
//
//  User is only allowed to add new products based on WConfiguration setting
//  Category: D|PN
//  Section:  PNProductEditor
//  Key:      AllowAdding
//
//  Fields that the user is allowed to edit is based on WConfiguration setting
//  Category: D|PN
//  Section:  PNProductEditor
//  Key:      EditableFields
//  This provides a comma separated list of fields names. 
//
//  As basic validation for this page is shared with DssCustomisation page 
//  validation functions are performed by PNSettingsProcessor
//  
//  Usage:
//  To add a product
//  PNProductEditor.aspx?SessionID=123&SiteID=24&Mode=add
//
//  To edit a product
//  PNProductEditor.aspx?SessionID=123&SiteID=24&Mode=edit&PNProductID=4
//
//	Modification History:
//	20Oct11 XN  Written
//  20Apr12 XN  TFS32337 for the dss customisation form used tag name 
//              PNIngDBNames.Volume rather than PNIngCode.Vol
//  29Jun12 XN  TFS36841 Don't Force update of Update Info for dss master db only
//  08Dec12 XN  TFS29186 Allow user to print out the PN product data.
//  04Jan13 XN  Add Print button (51139)
//  18Dec13	XN	78339 Knock on changes after moving ProductStock to BaseTable2
//              and making ProductSearch static.
//  24Jun14 XN  43318 BaseTable2 locking mechanism
//  12Sep14 XN  95647 if MaxmlTotal, MaxmlPerKg, SpGrav, mOsmperml, or gH2Operml
//              are 0 then displays blank in the boxes
//  08May15 XN  Renamed ProductSeatchType to ProductSearchType 111893 
//  27May15 XN  120004 link to pharmacy products not always holding Product flag
//  26Oct15 XN  106278 Made it a multi site editor
//  25Nov15 XN  38321 Allow adding a product from a DSS request
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
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;

public partial class application_PNSettings_PNProductEditor : System.Web.UI.Page
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

    /// <summary>DSS drug def request used to populate this form 25Nov15 XN 38321</summary>
    private int? dssDrugDefRequestId;
    #endregion

    #region Event handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        // Read parameters
        this.addMode                      = this.Request.QueryString["Mode"].EqualsNoCaseTrimEnd("add");
        this.replicateToSites             = Site2.Instance().FindBySiteNumber(this.Request["ReplicateToSiteNumbers"], true, CurrentSiteHandling.AtStart).ToList();
        this.siteNumbersSelectedByDefault = replicateToSites.FindBySiteNumber(this.Request["SiteNumbersSelectedByDefault"], allowAll: true).Select(s => s.SiteNumber).ToList();
        this.isMultiSiteEditMode          = this.replicateToSites.Count > 1;
        this.dssDrugDefRequestId          = string.IsNullOrWhiteSpace(this.Request["DSSDrugDefRequestID"]) ? (int?)null : int.Parse(this.Request["DSSDrugDefRequestID"]);

        // As the list of ingredients controls are dynamically created
        // need to do this every time form is loaded else will be lost
        CreateIngredients();

        if (!Page.IsPostBack)
        {
            // Update site lists (26Oc15 XN 106278)
            this.PopulateSiteList();
            this.UpdateReplicateToSiteList();

            // Setup for depending on mode
            if (this.addMode)
            {
                PNLog.WriteToLog(SessionInfo.SiteID, "User has started to add a product.\n" + lbtSites.Text);
                Add();

                // If running in DSS master db, and have drug request id then populate page from drug request
                // 25Nov15 XN  38321
                if (this.dssDrugDefRequestId != null && this.IsDSSMasterDB())
                {
                    this.PopulateFromDSSDrugDefRequest(PNUtils.GetDSSDrugDefRequest(this.dssDrugDefRequestId.Value));
                }
            }
            else
            {
                int pnProductID = int.Parse(Request["PNProductID"]);
                PNLog.WriteToLog(SessionInfo.SiteID, null, null, pnProductID, null, null, "User is viewing product.\n" + lbtSites.Text, string.Empty);

                Edit(pnProductID);
            }
        }
    }

    /// <summary>PreRender used to handle event args so dynamic controls have time to be populated</summary>
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
                int? pnProductId = this.addMode ? (int?)null : int.Parse(hfPNProductID.Value);
                PNLog.WriteToLog(SessionInfo.SiteID, null, null, pnProductId, null, null, "Updated replication state\n" + lbtSites.Text, string.Empty);
                break;

            case "Save":
                // Called when user has clicked OK display difference will save the data
                PNProduct products = new PNProduct();
                if (!this.addMode)
                {
                    products.LoadByPNCode(this.hfPNCode.Value);

                    // Remove rows for sites we are not updating (need for validation, displaying differences, and saving)
                    var selectedReplicateToSiteIds = this.GetSelectedReplicateToSiteIds();
                    products.RemoveAll(p => !selectedReplicateToSiteIds.Contains(p.LocationID_Site));
                    products.Table.AcceptChanges();
                    products.DeletedItemsTable.AcceptChanges();
                }

                if (this.Save(products))
                {
                    this.ClosePage(products.FindFirstBySiteId(SessionInfo.SiteID).PNProductID.ToString());
                }
                break;
            }
        }
    }

    /// <summary>
    /// Called when the save button is clicked 
    /// Validates, displays difference (in multi site mode), and saves a product 30Oct15 XN 106278
    /// </summary>
    protected void Save_Click(object sender, EventArgs e)
    {
        // Loads the product (loads nothing for add mode)
        PNProduct products = new PNProduct();
        products.LoadByPNCode(this.addMode ? this.tbPNCode.Text : this.hfPNCode.Value);

        // Remove rows for sites we are not updating (need for validation, displaying differences, and saving)
        var selectedReplicateToSiteIds = this.GetSelectedReplicateToSiteIds();
        products.RemoveAll(p => !selectedReplicateToSiteIds.Contains(p.LocationID_Site));
        products.Table.AcceptChanges();
        products.DeletedItemsTable.AcceptChanges();

        // Validate and save (if multi site edit mode will display differences)
        if (this.Validate(products) && !this.DisplayDifferences(products))
        {
            if (this.Save(products))
            {
                this.ClosePage(products.FindFirstBySiteId(SessionInfo.SiteID).PNProductID.ToString());
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

            //string script = string.Format("confirmEnh(\"\", true, function() {{ __doPostBack('{1}', 'Save') }}, undefined, '450px');", msg, updatePanel.ClientID);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "showSitesToPrint", "showSitesToPrint();", true);
        }
        else
        {
            this.Print(SessionInfo.SiteID);
        }
    }

    protected void RefreshProductList_Click(object sender, EventArgs e)
    {
        PopulateRelatedProductList(tbStockLookup.Text);
    }

    protected void cblSuppliedBy_SelectedIndexChanged(object sender, EventArgs e)
    {
        lbNoItemsSelected.Visible = !cblSuppliedBy.Items.Cast<ListItem>().Any(li => li.Selected);
    }
    #endregion

    #region Public Methods
    /// <summary>Puts the from in add mode</summary>
    public void Add()
    {
        // Check if allowed to add
        if (!PNSettings.PNProductEditor.AllowAdding)
            throw new ApplicationException("You are not allowed to add PN products. Call Emis Health DSS support services to have new products added to your system.");

        // Initialise the form controls
        Initialise();

        // Initialise all ingredients to 0 (easier for user)
        GetAllIngredientTextBoxes().ForEach(i => i.Text = "0");

        // set the form controls
        hfPNProductID.Value = "-1";
        hfPNCode.Value      = string.Empty;
        hfOpenDate.Value    = string.Empty;     // 26Oct15 XN 106278 Added
    }

    /// <summary>Puts form into edit mode</summary>
    /// <param name="pnProductID">ID of the product being edited</param>
    public void Edit(int pnProductID)
    {
        // Initialise the form controls
        Initialise();

        // Set open date before loading 26Oct15 XN 106278
        hfOpenDate.Value = DateTime.Now.ToString(LastModDateTimePattern);

        // Get the product
        PNProduct products = new PNProduct();
        products.LoadByID(pnProductID);
        PNProductRow product = products.First();

        hfPNProductID.Value = pnProductID.ToString();
        hfPNCode.Value      = product.PNCode;       // Added 26Oct15 XN 106278

        // Set General items
        tbDescription.Text      = product.Description;
        tbPNCode.Text           = product.PNCode;
        cbInUse.Checked         = product.InUse;
        cbForAdult.Checked      = product.ForAdult;
        cbForPaediatric.Checked = product.ForPaediatric;
        tbSortIndex.Text        = product.SortIndex.ToString();
        cbSharePacks.Checked    = product.SharePacks;

        // Set Detail items
        ddlAqueousOrLipid.SelectedIndex = EnumExtensions.EnumIndexInListView(ddlAqueousOrLipid, product.AqueousOrLipid);
        tbPreMix.Text     = product.PreMix.ToString();
        //tbMaxMlTotal.Text = product.MaxmlTotal.ToString("0.######");
        //tbMaxMlPerKg.Text = product.MaxmlPerKg.ToString("0.######");
        //tbSpGrav.Text     = product.SpGrav.ToString("0.######");
        //tbMOsmperml.Text  = product.mOsmperml.ToString("0.######");
        //tbGH2Operml.Text  = product.gH2Operml.ToString("0.######");   12Sep14 XN 95647 If values are 0 then display empty text box (except for mMOsmperml which is 0 for water)
        tbMaxMlTotal.Text = product.MaxmlTotal > 0.0 ? product.MaxmlTotal.ToString("0.######") : string.Empty;
        tbMaxMlPerKg.Text = product.MaxmlPerKg > 0.0 ? product.MaxmlPerKg.ToString("0.######") : string.Empty;
        tbSpGrav.Text     = product.SpGrav     > 0.0 ? product.SpGrav.ToString("0.######")     : string.Empty;
        tbMOsmperml.Text  = (product.mOsmperml  > 0.0 || product.PNCode == "WATI000") ? product.mOsmperml.ToString("0.######") : string.Empty;
        tbGH2Operml.Text  = product.gH2Operml  > 0.0 ? product.gH2Operml.ToString("0.######")   : string.Empty;

        // Get the related product list
        PopulateRelatedProductList(product.StockLookup);

        // Set Baxa Compounder items
        tbBaxaMMIg.Text   = product.BaxaMMIg;

        // Set Supplier items
        tbStockLookup.Text = product.StockLookup;

        // Set Ingredients
        tbContainerVol.Text = product.ContainerVolumeInml.ToString("0.######");

        foreach (TextBox tbIng in GetAllIngredientTextBoxes())
        {
            double? value = product.GetIngredient(tbIng.ID);
            tbIng.Text = (value ?? 0.0).ToString("0.######");
        }

        // Update info (Last modified by XN on 15/04/11 15:16 terminal Fred)
        bool hasBeenModified = false;
        StringBuilder modifiedInfo = new StringBuilder("Last modified");
        if (!string.IsNullOrEmpty(product.LastModifiedUserInitials))
        {
            modifiedInfo.Append(" by ");
            modifiedInfo.Append(product.LastModifiedUserInitials);
            hasBeenModified = true;
        }
        if (product.LastModifiedDate.HasValue)
        {
            modifiedInfo.Append(" on ");
            modifiedInfo.Append(product.LastModifiedDate.Value.ToPharmacyDateTimeString());
            hasBeenModified = true;
        }
        if (!string.IsNullOrEmpty(product.LastModifiedTerminal))
        {
            modifiedInfo.Append(" terminal ");
            modifiedInfo.Append(product.LastModifiedTerminal);
            hasBeenModified = true;
        }
        lbModifiedInfo.Text = hasBeenModified ? modifiedInfo.ToString() : "Never been modified";
        tbInfo.Text         = product.DSSInfo;
        tbInfo.Visible      = (tbInfo.Enabled && !tbInfo.ReadOnly) || !string.IsNullOrWhiteSpace(tbInfo.Text);
    }
    
    /// <summary>Populate the controls on the form from the DSS drug definition request (this is from the customer and packages db) 25Nov15 XN  38321</summary>
    /// <param name="dssDrugDefRequestId">Drug def request id</param>
    public void PopulateFromDSSDrugDefRequest(DataRow drugDefRequestRow)
    {
        tbDescription.Text      = GetValue(drugDefRequestRow, "Description");
        cbForAdult.Checked      = (bool)drugDefRequestRow["ForAdult"];
        cbForPaediatric.Checked = (bool)drugDefRequestRow["ForPaed"];
        tbPreMix.Text           = GetValue(drugDefRequestRow, "PreMix");
        ddlAqueousOrLipid.SelectedIndex = (drugDefRequestRow["AqueousOrLipid"] as string) == "A" ? 0 : 1;
        tbMaxMlTotal.Text       = GetValue(drugDefRequestRow, "MaxmLTotal");
        tbMaxMlPerKg.Text       = GetValue(drugDefRequestRow, "MaxmLPerKg");
        cbSharePacks.Checked    = drugDefRequestRow["SharePacks"] != DBNull.Value && (bool)drugDefRequestRow["SharePacks"];
        tbMOsmperml.Text        = GetValue(drugDefRequestRow, "MOsmperml");
        tbGH2Operml.Text        = GetValue(drugDefRequestRow, "gH2OpermL");
        tbSpGrav.Text           = GetValue(drugDefRequestRow, "SpGrav");
        tbContainerVol.Text     = GetValue(drugDefRequestRow, "ContainerVol_mL");

        this.GetAllIngredientTextBoxes().ForEach(tb => tb.Text = this.GetValue(drugDefRequestRow, tb.ID));
    }

    private string GetValue(DataRow drugDefRequestRow, string columnName)
    {
        return (!drugDefRequestRow.Table.Columns.Contains(columnName) || drugDefRequestRow[columnName] == DBNull.Value) ? string.Empty : drugDefRequestRow[columnName].ToString();
    }
    #endregion

    #region Private Methods
    /// <summary>If this is the DSS master db 29Jun12 XN TFS36841</summary>
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
        PNProductColumnInfo pnProductColumns = PNProduct.GetColumnInfo();
        List<PNIngredientRow> ingredients = (from i in PNIngredient.GetInstance()
                                             where pnProductColumns.FindColumnByName(i.DBName) != null
                                             orderby i.SortIndex
                                             select i).ToList();

        for (int i = 0; i < ingredients.Count; i++)
        {
            PNIngredientRow ingredient = ingredients[i];
            TableRow newRow = new TableRow();
            TableCell cell;

            // Ingredients displayed in 2 colums so get the correct panel
            if (i <= (ingredients.Count / 2))
                tbIngredientsLeft.Rows.Add(newRow);
            else
                tbIngredientsRigth.Rows.Add(newRow);

            // Add ingredient label
            cell = new TableCell();
            cell.Style["border-bottom"] = "solid 1px #9CCFFF";
            Label name = new Label();
            name.Text = ingredient.Description + "&nbsp;";
            cell.Controls.Add(name);
            newRow.Cells.Add(cell);

            // Add ingredient textbox
            cell = new TableCell();
            cell.Style["border-bottom"] = "solid 1px #9CCFFF";
            TextBox value = new TextBox();
            value.ID = ingredient.DBName;
            value.Attributes["LongName"] = ingredient.Description;
            value.Width = new Unit(50.0, UnitType.Pixel);
            value.Style["text-align"] = "right";
            cell.Controls.Add(value);
            newRow.Cells.Add(cell);

            // Dss customisation button
            cell = new TableCell();
            Button btnDssCustomisation = new Button();
            btnDssCustomisation.OnClientClick = string.Format("DisplayDssCustomisation('{0}'); return false;", ingredient.DBName); 
            btnDssCustomisation.CssClass      = "PharmButton";
            btnDssCustomisation.Text          = "...";
            btnDssCustomisation.Width         = Unit.Pixel(15);
            btnDssCustomisation.Height        = Unit.Pixel(20);
            btnDssCustomisation.Visible       = false;
            cell.Controls.Add(btnDssCustomisation);
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
    ///  Section:  PNProductEditor
    ///  Key:      EditableFields
    /// </summary>
    private void Initialise()
    {
        HashSet<string> editableFields = PNSettings.PNProductEditor.EditableFields;
        Type pnProductRowType = typeof(PNProductRow);
        //bool showCustomisationButtons = !addMode && SettingsController.Load<bool>("Security", "Settings", "DSSMaster", false) && (Sites.GetNumberBySiteID(siteID) == 0);  29Jun12 XN TFS36841
        bool showCustomisationButtons = !addMode && IsDSSMasterDB();

        // Clean the form
        IEnumerable<Control> pageControls = Page.Controls.OfType<Control>().Desendants(i => i.Controls.OfType<Control>()).ToList();
        pageControls.OfType<TextBox>().ToList().ForEach (t => t.Text    = string.Empty);
        pageControls.OfType<CheckBox>().ToList().ForEach(t => t.Checked = false       );
        pageControls.OfType<Label>().Where(l => l.CssClass == "ErrorMessage").ToList().ForEach(t => t.Text="&nbsp;");

        // General
        tbDescription.ReadOnly      = !addMode && !editableFields.Contains("description");
        btnDescription.Visible      = !tbDescription.ReadOnly && showCustomisationButtons;
        tbPNCode.ReadOnly           = !addMode && !editableFields.Contains("pncode");
        cbInUse.Enabled             =  addMode || editableFields.Contains("inuse");
        cbForAdult.Enabled          =  addMode || editableFields.Contains("foradult");
        cbForPaediatric.Enabled     =  addMode || editableFields.Contains("forpaed");
        tbSortIndex.ReadOnly        = !addMode && !editableFields.Contains("sortindex");
        cbSharePacks.Enabled        =  addMode || editableFields.Contains("sharepacks");

        // Details
        ddlAqueousOrLipid.Items.Clear();
        ddlAqueousOrLipid.Items.Add(new ListItem(PNProductType.Aqueous.ToString(), PNProductType.Aqueous.ToString()));
        ddlAqueousOrLipid.Items.Add(new ListItem(PNProductType.Lipid.ToString(),   PNProductType.Lipid.ToString()));
        ddlAqueousOrLipid.SelectedIndex = 0;
        ddlAqueousOrLipid.Enabled   = addMode  || editableFields.Contains("aqueousorlipid");
        tbPreMix.ReadOnly           = !addMode && !editableFields.Contains("premix");
        btnPreMix.Visible           = !tbPreMix.ReadOnly && showCustomisationButtons;
        tbMaxMlTotal.ReadOnly       = !addMode && !editableFields.Contains("maxmltotal");
        btnMaxMlTotal.Visible       = !tbMaxMlTotal.ReadOnly && showCustomisationButtons;
        tbMaxMlPerKg.ReadOnly       = !addMode && !editableFields.Contains("maxmlperkg");
        btnMaxMlPerKg.Visible       = !tbMaxMlPerKg.ReadOnly && showCustomisationButtons;
        tbSpGrav.ReadOnly           = !addMode && !editableFields.Contains("spgrav");
        btnSpGrav.Visible           = !tbSpGrav.ReadOnly && showCustomisationButtons;
        tbMOsmperml.ReadOnly        = !addMode && !editableFields.Contains("mosmperml");
        btnMOsmperml.Visible        = !tbMOsmperml.ReadOnly && showCustomisationButtons;
        tbGH2Operml.ReadOnly        = !addMode && !editableFields.Contains("gh2operml");
        btnGH2Operml.Visible        = !tbGH2Operml.ReadOnly && showCustomisationButtons;

        // Supplied by options
        cblSuppliedBy.Enabled       = addMode  || editableFields.Contains("suppliedby");
        tbStockLookup.ReadOnly      = !addMode && !editableFields.Contains("stocklookup");
        btnStockLookup.Visible      = !tbStockLookup.ReadOnly && showCustomisationButtons;

        // For Baxa Compounder
        tbBaxaMMIg.ReadOnly         = !addMode && !editableFields.Contains("baxammig");
        btnBaxaMMIg.Visible         = !tbBaxaMMIg.ReadOnly && showCustomisationButtons;

        // Update info
        tbInfo.ReadOnly             = !addMode && !editableFields.Contains("info");
        if (tbInfo.ReadOnly)
        {
            tbInfo.BackColor   = Color.FromArgb(235, 235, 235);
            tbInfo.BorderStyle = BorderStyle.None;
            tbInfo.Attributes["onfocus"] = "this.parentNode.focus();";
        }

        // Ingredients
        tbContainerVol.ReadOnly         = !addMode && !editableFields.Contains("ingredient");
        btnContainerVol.Visible         = !tbContainerVol.ReadOnly && showCustomisationButtons;
        //btnContainerVol.OnClientClick   = string.Format("DisplayDssCustomisation('{0}'); return false;", PNIngCode.Vol);
        btnContainerVol.OnClientClick   = string.Format("DisplayDssCustomisation('{0}'); return false;", "ContainerVol_mL");    // TFS32067 18May12 Needs to be same as PNProduct.ContainerVol_mL so can't user PNIngDBName.Volume
        GetAllIngredientTextBoxes().ForEach(i => i.ReadOnly = !addMode && !editableFields.Contains("ingredient"));
        tbIngredientsLeft.Controls.OfType  <Control>().Desendants(c => c.Controls.OfType<Control>()).OfType<Button>().ToList().ForEach(i => i.Visible = btnContainerVol.Visible);
        tbIngredientsRigth.Controls.OfType <Control>().Desendants(c => c.Controls.OfType<Control>()).OfType<Button>().ToList().ForEach(i => i.Visible = btnContainerVol.Visible);
    }

    /// <summary>
    /// Validates the forms data
    /// Only validates writable controls
    /// 26Oct15 XN 106278 Update to support multiple sites
    /// </summary>
    /// <param name="product">Products to validate (empty if adding new product) used to check editing time</param>
    /// <returns>If valid form data</returns>
    private bool Validate(PNProduct products)
    {
        PNProductColumnInfo columnInfo = PNProduct.GetColumnInfo();
        string error = string.Empty;
        bool ok = true;

        // Get the time the page was opened
        DateTime? openDate = null;
        if (!string.IsNullOrEmpty(hfOpenDate.Value))
            openDate = DateTime.ParseExact(hfOpenDate.Value, LastModDateTimePattern, CultureInfo.CurrentCulture);

        // If editing and date of db record is older than the open date then error
        if (openDate != null && products.Any(p => p.LastModifiedDate != null && openDate < p.LastModifiedDate))
        {
            StringBuilder errorMsg = new StringBuilder();
            errorMsg.Append("Product has been updated by another user.<br />");
            foreach (var p in products.Where(p => p.LastModifiedDate != null && openDate < p.LastModifiedDate))
            {
                errorMsg.Append("User: " + p.LastModifiedUserInitials.Replace("'", "\\'") + "<br />");
                errorMsg.Append("Date: " + p.LastModifiedDate.ToPharmacyDateString() + "<br />");
                if (this.isMultiSiteEditMode)
                {
                    errorMsg.AppendFormat("Site: {0:000}<br />", Site2.GetSiteNumberByID(p.LocationID_Site));
                }
                errorMsg.Append("<br />");
            }
            errorMsg.Append("Please cancel your changes, refresh list of product, and re-edit.");

            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "EditByAnotherUser", "alertEnh('" + errorMsg + "');", true);
            return false;
        }

        // Clear all error labels
        Page.Controls.OfType<Control>().Desendants(i => i.Controls.OfType<Control>()).OfType<Label>().Where(l => l.CssClass == "ErrorMessage").ToList().ForEach(t => t.Text="&nbsp;");

        // General information
        if (!tbDescription.ReadOnly)        
        {
            if (!PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbDescription, lbDescriptionError, "description", string.Empty))
                ok = false;
            else
            {
                PNProduct temp = new PNProduct();
                foreach (int siteId in this.GetSelectedReplicateToSiteIds())
                {
                    temp.LoadBySiteIDAndDescription(siteId, tbDescription.Text);
                    if (temp.Any() && products.FindByPNProductID(temp[0].PNProductID) == null)
                    {
                        lbDescriptionError.Text = "Name is not unique" + (this.isMultiSiteEditMode ? " site " + Site2.GetSiteNumberByID(siteId).ToString() : string.Empty);
                        ok = false;
                        break;
                    }
                }
            }
        }

        if (!tbPNCode.ReadOnly)        
        {
            if (!PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbPNCode, lbPNCodeError, "pncode", string.Empty))
                ok = false;
            else
            {
                PNProduct temp = new PNProduct();
                foreach (int siteId in this.GetSelectedReplicateToSiteIds())
                {
                    temp.LoadBySiteIDAndPNCode(siteId, tbPNCode.Text);
                    if (temp.Any() && products.FindByPNProductID(temp[0].PNProductID) == null)
                    {
                        lbPNCodeError.Text = "Not unique" + (this.isMultiSiteEditMode ? " site " + Site2.GetSiteNumberByID(siteId).ToString() : string.Empty);
                        ok = false;
                        break;
                    }
                }
            }
        }

        if (!tbSortIndex.ReadOnly)
        {
            if (!PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbSortIndex, lbSortIndexError, "pncode", string.Empty))
                ok = false;
            else
            {
                PNProduct temp = new PNProduct();
                foreach (int siteId in this.GetSelectedReplicateToSiteIds())
                {
                    temp.LoadBySiteIDAndSortIndex(siteId, int.Parse(tbSortIndex.Text));
                    if (temp.Any() && products.FindByPNProductID(temp[0].PNProductID) == null)
                    {
                        lbSortIndexError.Text = "Not unique" + (this.isMultiSiteEditMode ? " site " + Site2.GetSiteNumberByID(siteId).ToString() : string.Empty);
                        ok = false;
                        break;
                    }
                }
            }
        }


        // Details
        if (!tbPreMix.ReadOnly && !PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbPreMix, lbPreMixError, "premix", string.Empty))
            ok = false;
        if (!tbMaxMlTotal.ReadOnly && !PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbMaxMlTotal, lbMaxMlTotalError, "maxmltotal", string.Empty))
            ok = false;
        if (!tbMaxMlPerKg.ReadOnly && !PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbMaxMlPerKg, lbMaxMlPerKgError, "maxmlperkg", string.Empty))
            ok = false;
        if (!tbSpGrav.ReadOnly && !PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbSpGrav, lbSpGravError, "spgrav", string.Empty))
            ok = false;
        if (!tbMOsmperml.ReadOnly)
        {
            if (!PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbMOsmperml, lbMOsmpermlError, "mosmperml", string.Empty))
                ok = false;
            else if (tbPNCode.Text == "WATI000" && string.IsNullOrWhiteSpace(tbMOsmperml.Text))
            {
                // 12Sep14 XN 95647 WATI000 can be 0
                lbMOsmpermlError.Text = "enter a value";
                ok = false;
            }
            else if (tbPNCode.Text != "WATI000" && !string.IsNullOrWhiteSpace(tbMOsmperml.Text) && double.Parse(tbMOsmperml.Text) <= 0)
            {
                // 12Sep14 XN 95647 If 0 will now display blank (so prevent user from entering 0)
                // Have to check mOsmperml here as need to check if product is water which can be 0
                // (MaxMlTotal, MaxMlPerKg, SpGrav, and GH2Operml are checked in PNSettingsProcessor.RangeValidationPNProduct) 
                lbMOsmpermlError.Text = "must be greater than 0 or blank";
                ok = false;
            }
        }
        if (!tbGH2Operml.ReadOnly && !PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbGH2Operml, lbGH2OpermlError, "gh2operml", string.Empty))
            ok = false;
        if (!tbBaxaMMIg.ReadOnly && !PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbBaxaMMIg, lbBaxaMMIgError, "baxammig", string.Empty))
            ok = false;

        // Ingredients
        if (!tbContainerVol.ReadOnly && !PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbContainerVol, lbContainerVolError, "ingredient", string.Empty))
            ok = false;
        foreach (TextBox tbIng in GetAllIngredientTextBoxes())
        {            
            if (!tbIng.ReadOnly && !PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbIng, lbIngredientError, "ingredient", tbIng.Attributes["LongName"]))
            {
                ok = false;
                break;
            }
        }

        // Supplied by
        if (!tbStockLookup.ReadOnly && !PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbStockLookup, lbStockLookupError, "stocklookup", string.Empty))
            ok = false;

        // Update Info
        if (!tbInfo.ReadOnly && !PNSettingsProcessor.RangeValidationPNProduct(columnInfo, tbInfo, lbInfoError, "info", string.Empty))
            ok = false;

        return ok;
    }

    /// <summary>
    /// If multi site mode, and not adding, will display all the difference, and ask if the form should be saved
    /// 26Oct15 XN 106278
    /// </summary>
    /// <param name="products">Original product from db</param>
    /// <returns>If difference form is displayed</returns>
    private bool DisplayDifferences(PNProduct products)
    {
        // If not in multi site mode then returned
        if (!this.isMultiSiteEditMode)
        {
            return false;
        }

        QSDifferencesList differences = new QSDifferencesList();
        
        // Add site where rule will be inserted to the list
        var siteWithOutProduct = (from s in this.GetSelectedReplicateToSiteIds() where products.FindFirstBySiteId(s) == null select s).ToList();
        siteWithOutProduct.ForEach(s => differences.Add(s, "New Drug", "Will add drug", string.Empty));

        // Compare product values
        this.CompareValues(differences, products, p => p.Description,                    tbDescription.Text,                      "Description"     );
        this.CompareValues(differences, products, p => p.PNCode,                         tbPNCode.Text,                           "PNCode"          );
        this.CompareValues(differences, products, p => p.InUse.ToYesNoString(),          cbInUse.Checked.ToYesNoString(),         "In-Use"          );
        this.CompareValues(differences, products, p => p.ForAdult.ToYesNoString(),       cbForAdult.Checked.ToYesNoString(),      "For Adult"       );
        this.CompareValues(differences, products, p => p.ForPaediatric.ToYesNoString(),  cbForPaediatric.Checked.ToYesNoString(), "For Paediatric"  );
        this.CompareValues(differences, products, p => p.SortIndex.ToString(),           tbSortIndex.Text,                        "Sort Index"      );
        this.CompareValues(differences, products, p => p.SharePacks.ToYesNoString(),     cbSharePacks.Checked.ToYesNoString(),    "Share Packs"     );
        this.CompareValues(differences, products, p => p.AqueousOrLipid.ToString(),      ddlAqueousOrLipid.SelectedValue,         "Aqueous or lipid");
        this.CompareValues(differences, products, p => p.PreMix.ToString(),              tbPreMix.Text,                           "Pre Mix"         );
        this.CompareValues(differences, products, p => p.MaxmlTotal > 0.0 ? p.MaxmlTotal.ToString("0.######") : string.Empty, tbMaxMlTotal.Text, "Max ml Total" );
        this.CompareValues(differences, products, p => p.MaxmlPerKg > 0.0 ? p.MaxmlPerKg.ToString("0.######") : string.Empty, tbMaxMlPerKg.Text, "Max ml per Kg");
        this.CompareValues(differences, products, p => p.SpGrav     > 0.0 ? p.SpGrav.ToString("0.######")     : string.Empty, tbSpGrav.Text,     "Sp Grav."     );
        this.CompareValues(differences, products, p => (p.mOsmperml  > 0.0 || p.PNCode == "WATI000") ? p.mOsmperml.ToString("0.######")  : string.Empty,  tbMOsmperml.Text, "MOsm per ml");
        this.CompareValues(differences, products, p => p.gH2Operml  > 0.0 ? p.gH2Operml.ToString("0.######")  : string.Empty,tbGH2Operml.Text,   "gH2O per ml"  );

        this.CompareValues(differences, products, p => p.ContainerVolumeInml.ToString("0.######"), tbContainerVol.Text, "Container Volume");

        // Compare ingredient values
        PNIngredient ingredients = PNIngredient.GetInstance();
        foreach (TextBox tbIng in GetAllIngredientTextBoxes())
        {
            var ingredient = ingredients.FindByDBName(tbIng.ID);
            this.CompareValues(differences, products, p => (p.GetIngredient(tbIng.ID) ?? 0.0).ToString("0.######"), tbIng.Text, string.Format("{0} ({1})", ingredient.Description, ingredient.UnitDescription));
        }

        // Compare supplier lookup
        this.CompareValues(differences, products, p => p.StockLookup, tbStockLookup.Text, "Stock Lookup");

        foreach(var p in products)
        {
            // Compare supplied by 
            ProductSearchType searchType = ProductSearchType.Any;
            WProduct pharmacyProducts = ProductSearch.DoSearch(tbStockLookup.Text, ref searchType, false, p.LocationID_Site);

            // Get changes to supplied by ingredients
            var changedItems = from li in cblSuppliedBy.Items.Cast<ListItem>()
                               let pp = pharmacyProducts.FindBySiteIDAndNSVCode(p.LocationID_Site, li.Value)
                               where pp != null && li.Selected == pp.PNExclude
                               select li;
            if (changedItems.Any())
            {
                differences.Add(p.LocationID_Site, "Supplied by", "<Updated>", string.Empty);
            }
        }

        this.CompareValues(differences, products, p => p.BaxaMMIg, tbBaxaMMIg.Text, "Baxa MMig");

        foreach(var p in products)
        {
            if (p.DSSInfo != tbInfo.Text)
            {
                differences.Add(p.LocationID_Site, "DSS Info", "<Updated>", string.Empty);
            }
        }

        // Display any difference in a popup
        if (differences.Any())
        {
            string msg = string.Format("<div style='max-height:500px;overflow-y:scroll;overflow-x:hidden;'>{0}</div><br /><p>OK to save the changes?</p>", differences.ToHTML( Sites.GetDictonarySiteIDToNumber() ));
            string script = string.Format("confirmEnh(\"{0}\", true, function() {{ __doPostBack('{1}', 'Save') }}, undefined, '450px');", msg, updatePanel.ClientID);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", script, true);
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
    /// <param name="products">list of products to check (should only be the products for sites selected for replication)</param>
    /// <param name="funcWas">function to get the existing value from the product</param>
    /// <param name="now">what the new value is</param>
    /// <param name="description">Control name</param>
    private void CompareValues(QSDifferencesList differences, IEnumerable<PNProductRow> products, Func<PNProductRow,string> funcWas, string now, string description)
    {
        // If the item has been edited (different from what is in the DB)
        // Then log the difference, and check all other sites (if not different then don't compare other sites)
        var product = products.FindFirstBySiteId(SessionInfo.SiteID);
        if (product == null || funcWas.Invoke(product) != now)
        {
            // Check all sites
            foreach (var p in products)
            {
                if (funcWas.Invoke(p) != now)
                {
                    differences.Add(p.LocationID_Site, description, now, funcWas.Invoke(p));
                }
            }
        }
    }

    /// <summary>
    /// Save form data
    /// 26Oct15 XN 106278 Update to multi site editor mode
    /// </summary>
    /// <param name="products">List of product to save to</param>
    private bool Save(PNProduct products)
    {
        PNProduct productsTemp = new PNProduct();  
        ProductStock productStock = new ProductStock();
        PNProductColumnInfo columnInfo = PNProduct.GetColumnInfo();
        Dictionary<PNProductRow,string> productToLog = new Dictionary<PNProductRow,string>();
        List<WProductRow> updateSuppliedByRows = new List<WProductRow>();
        StringBuilder log = new StringBuilder();
        DateTime now = DateTime.Now;
        bool bOK = false;        

        // Save to each of sites selected for replication
        foreach (var siteId in this.GetSelectedReplicateToSiteIds())
        {
            PNProductRow productOringal = productsTemp.Add();
            
            PNProductRow product = products.FindFirstBySiteId(siteId);
            if (product == null)
            {
                product = products.Add();
            }
            else
            {
                productOringal.CopyFrom(product);
            }

            // Fill rule data (if new row or row for main site then fill from form data)
            // If replicate to site then update only the rows that have been edit
            if (siteId == SessionInfo.SiteID || product.RawRow.RowState == DataRowState.Added)
            {
                // General
                product.LocationID_Site = siteId;
                product.Description     = tbDescription.Text;
                product.PNCode          = tbPNCode.Text;
                product.InUse           = cbInUse.Checked;
                product.ForAdult        = cbForAdult.Checked;
                product.ForPaediatric   = cbForPaediatric.Checked;
                product.SortIndex       = int.Parse(tbSortIndex.Text);
                product.SharePacks      = cbSharePacks.Checked;

                // Details
                product.AqueousOrLipid  = EnumExtensions.ListItemValueToEnum<PNProductType>(ddlAqueousOrLipid.SelectedValue);
                product.PreMix          = int.Parse(tbPreMix.Text);
                product.MaxmlTotal      = string.IsNullOrEmpty(tbMaxMlTotal.Text) ? 0 : double.Parse(tbMaxMlTotal.Text);
                product.MaxmlPerKg      = string.IsNullOrEmpty(tbMaxMlPerKg.Text) ? 0 : double.Parse(tbMaxMlPerKg.Text);
                product.SpGrav          = string.IsNullOrEmpty(tbSpGrav.Text    ) ? 0 : double.Parse(tbSpGrav.Text);
                product.mOsmperml       = string.IsNullOrEmpty(tbMOsmperml.Text ) ? 0 : double.Parse(tbMOsmperml.Text);
                product.gH2Operml       = string.IsNullOrEmpty(tbGH2Operml.Text ) ? 0 : double.Parse(tbGH2Operml.Text);
                product.BaxaMMIg        = tbBaxaMMIg.Text;
                product.DSSInfo         = tbInfo.Text;
                product.ContainerVolumeInml = double.Parse(tbContainerVol.Text);
                product.LastModifiedDate= now;
                product.LastModifiedUserInitials = SessionInfo.UserInitials.SafeSubstring(0, columnInfo.LastModifieUserInitialsLength);
                product.LastModifiedTerminal     = SessionInfo.Terminal.SafeSubstring    (0, columnInfo.LastModifiedTerminalLength);

                // Get ingredient values
                foreach (TextBox tbIng in GetAllIngredientTextBoxes())
                {
                    double? value = string.IsNullOrEmpty(tbIng.Text) ? (double?)null : double.Parse(tbIng.Text);
                    product.SetIngredient(tbIng.ID, value);
                }

                // Supplier info
                product.StockLookup = tbStockLookup.Text;
            }
            else
            {
                // Not for main site or new drug so just update items that have been edited
                var copyFromRow = products.FindFirstBySiteId(SessionInfo.SiteID);
                product.CopyFrom(copyFromRow, copyFromRow.GetChangedColumns().Select(c => c.ColumnName));
            }

            // Determine which pharmacy product has changed it's supplier selected states
            ProductSearchType searchType = ProductSearchType.Any;
            WProduct pharmacyProducts = ProductSearch.DoSearch(tbStockLookup.Text, ref searchType, false, siteId);

            foreach (ListItem item in cblSuppliedBy.Items)
            {
                WProductRow wp = pharmacyProducts.FindBySiteIDAndNSVCode(siteId, item.Value);
                if ((wp != null) && (wp.PNExclude == item.Selected))
                {
                    wp.PNExclude = !item.Selected;
                    updateSuppliedByRows.Add(wp);
                }
            }

            // Generate log
            log.Clear();
            if (product.RawRow.RowState == DataRowState.Added)
                PNLog.AddDataRow(log, "Adding new product (" + product.Description + " - " + product.PNCode + ")", product.RawRow);
            else
            {
                log.AppendLine("Updated following product details (" + product.Description + " - " + product.PNCode + "):");
                PNLog.CompareDataRow(log, productOringal.RawRow, product.RawRow);
            }

            var excludedItems = updateSuppliedByRows.Where(p => p.SiteID == siteId && p.PNExclude);
            if (excludedItems.Any())
            {
                log.AppendLine();
                log.AppendLine("Following pharmacy products added to excluded list:" + excludedItems.Select(p => p.NSVCode).ToCSVString(","));
            }
                
            var includedItems = updateSuppliedByRows.Where(p => p.SiteID == siteId && !p.PNExclude);
            if (includedItems.Any())
            {
                log.AppendLine();
                log.AppendLine("Following pharmacy products added to included list:" + includedItems.Select(p => p.NSVCode).ToCSVString(","));
            }

            productToLog.Add(product, log.ToString());
        }

        try
        {
            // Load, lock, and updated the product stock rows 
            productStock.RowLockingOption = LockingOption.HardLock;
            productStock.LoadByProductStockIDs(updateSuppliedByRows.Select(p => p.ProductStockID).ToArray());
            foreach (var ps in productStock)
            {
                ps.PNExclude = updateSuppliedByRows.First(p => p.ProductStockID == ps.ProductStockID).PNExclude;
            }

            // Save
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                products.Save();
                productStock.Save();
                foreach(var s in productToLog)
                {
                    PNProductRow product = s.Key as PNProductRow;
                    PNLog.WriteToLog(product.LocationID_Site, null, null, product.PNProductID, null, null, s.Value, string.Empty);
                }
                trans.Commit();
            }
            productStock.UnlockRows();

            // Update hidden fields
            hfPNCode.Value      = products.FindFirstBySiteId(SessionInfo.SiteID).PNCode;
            hfPNProductID.Value = products.FindFirstBySiteId(SessionInfo.SiteID).PNProductID.ToString();

            bOK = true;
        }
        catch (DBConcurrencyException)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "EditByAnotherUser", "alert('Product has been recently modified, and can't be saved. Refresh list and try again.');", true);
        }
        finally
        {
            productStock.Dispose();
        }

        return bOK;
    }

    private void PopulateRelatedProductList(string stockLookup)
    {
        // Get currently selected items
        List<string> selectedItems = new List<string>();
        foreach (ListItem item in cblSuppliedBy.Items)
        {
            if (item.Selected)
                selectedItems.Add(item.Value);
        }

        // Clear list
        cblSuppliedBy.Items.Clear();

        // Populate list of related products
        if (stockLookup.Length >= 3)
        {
            ProductSearchType searchType = ProductSearchType.Any;
            //ProductSearch search = new ProductSearch();
            //WProduct pharmacyProducts = ProductSearch.DoSearch(stockLookup, ref searchType);  18Dec13	XN 78339 Made ProductSearch static 
            WProduct pharmacyProducts = ProductSearch.DoSearch(stockLookup, ref searchType, false);
            foreach (WProductRow pharmacyProduct in pharmacyProducts)
            {
                ListItem newItem = new ListItem(pharmacyProduct.ToString(), pharmacyProduct.NSVCode);
                newItem.Selected = !pharmacyProduct.PNExclude || selectedItems.Contains(pharmacyProduct.NSVCode);
                cblSuppliedBy.Items.Add(newItem);
            }
            lbNoItemsToSupply.Visible = !pharmacyProducts.Any();
            lbStockLookupError.Text = string.Empty;
        }
        else if (this.IsPostBack)   // 29Jun12 XN Does not need to display when first opened.
        {
            lbNoItemsToSupply.Visible = true;
            lbStockLookupError.Text = "Minimum 3 characters";
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
        report.Initialise("Emis Health PN Product", Sites.GetNumberBySiteID(siteId));

        // General section
        report.StartNewSection("General");
        report.AddValue(lbDescription,   tbDescription  );
        report.AddValue(lbPNCode,        tbPNCode       );
        report.AddValue(lbInUse,         cbInUse        );
        report.AddValue(lbForAdult,      cbForAdult     );
        report.AddValue(lbForPaediatric, cbForPaediatric);
        report.AddValue(lbSortIndex,     tbSortIndex    );
        report.AddValue(lbSharePacks,    cbSharePacks   );

        // Details section
        report.StartNewSection("Detail");
        report.AddValue(lbAqueousOrLipid, ddlAqueousOrLipid   );
        report.AddValue(lbPreMix,         tbPreMix            );
        report.AddValue(lbMaxMlTotal,     tbMaxMlTotal        );
        report.AddValue(lbMaxMlPerKg,     tbMaxMlPerKg        );
        report.AddValue(lbSpGrav,         tbSpGrav            );
        report.AddValue(lbMOsmperml,      tbMOsmperml         );
        report.AddValue(lbGH2Operml,      tbGH2Operml         );

        // Ingredients section
        PNIngredient ingredients = PNIngredient.GetInstance();
        report.StartNewSection("Ingredients");
        report.AddValue(lbContainerVol,   tbContainerVol);
        foreach (TextBox tbIng in GetAllIngredientTextBoxes())
        {
            PNIngredientRow ing = ingredients.FindByDBName(tbIng.ID);
            report.AddValue(string.Format("{0} ({1})", ing.Description, ing.UnitDescription), !tbIng.ReadOnly, tbIng.Text);
        }

        // Supplied by section
        report.StartNewSection("Supplied by");
        StringBuilder suppliedBy = new StringBuilder();
        foreach (ListItem item in cblSuppliedBy.Items)
        {
            if (item.Selected)
                suppliedBy.AppendLine(item.Text);
        }
        report.AddValue("Supplied by", cblSuppliedBy.Enabled, suppliedBy.ToString());

        // Baxa info section
        report.StartNewSection("Baxa Info");
        report.AddValue(lbBaxaMMIg, tbBaxaMMIg);

        // Update info section
        report.StartNewSection("Update info");
        report.AddValue("Last modified by", false, lbModifiedInfo.Text.Replace("Last modified by ", string.Empty));
        report.AddValue("Update info", !tbInfo.ReadOnly, tbInfo.Text);

        // Save report xml to session attribute
        report.Save();

        // Check report exist in db
        // XN 11Mar13 58517 Help testing if report does not exist
        string reportName = report.GetReportName();
        if (OrderReport.IfReportExists(reportName))
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", string.Format("window.dialogArguments.icwwindow.document.frames['fraPrintProcessor'].PrintReport({0}, '{1}', 0, false, '');", SessionInfo.SessionID, reportName), true);
        else
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", string.Format("alert(\"Report not found '{0}'\");", reportName), true);
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
