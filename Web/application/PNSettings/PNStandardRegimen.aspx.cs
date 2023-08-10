//===========================================================================
//
//						     PNRuleEditor.aspx.cs
//
//  Allows user to add or edit a standard regimen.
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  Mode                - 'add' or 'edit'
//  PNStandardRegimenID - Id of record if in edit mode
//
//  User is only allowed to add new standard based on WConfiguration setting
//  Category: D|PN
//  Section:  PNStandardRegimen
//  Key:      AllowAdding
//
//  Fields that the user is allowed to edit is based on WConfiguration setting
//  Category: D|PN
//  Section:  PNStandardRegimen
//  Key:      EditableFields
//  This provides a comma separated list of fields names. 
//
//  Standard regimens are normaly created and maintained by customers 
//  (though we provide a default set)
//
//  Unlike other PN data sets standard regimen are not dependant on site, so 
//  there is only 1 set of standard regimen for a trust. 
//  However as they require a set of products (which are site dependant), 
//  they can be given a default site (else will use the lowest LocationID_Site PN site)
//  Category: PN
//  Section:  Prescribing
//  Key:      Allow48Hours
//
//  Usage:
//  To add a rule
//  PNStandardRegimen.aspx?SessionID=123&Mode=add
//
//  To edit a rule
//  PNStandardRegimen.aspx?SessionID=123&Mode=edit&PNStandardRegimenID=4
//
//	Modification History:
//	31Jan12 XN  Written
//  08Dec12 XN  TFS29186 Allow user to print out the PN product data.
//  18Mar15 XN  114207 get Standard Regimen editor to use ascribe site number
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
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;
using Ascribe.Common;
using Newtonsoft.Json;

public partial class application_PNSettings_PNStandardRegimen : System.Web.UI.Page
{
    #region Constants
    /// <summary>Format for pharmacy date to long time string convert</summary>
    static readonly string LastModDateTimePattern = "dd/MM/yyyy HH:mm:ss.fff";
    #endregion

    #region Member variables
    protected bool addMode = false;
    protected AgeRangeType ageRange;
    protected List<PNRegimenItem> regimenItems;
    #endregion

    #region Event handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        // 18Mar15 XN 114207 get Standard Regimen editor to use ascribe site number
        //sessionID  = int.Parse(Request["SessionID"]);
        //SessionInfo.InitialiseSession(sessionID);

        //if (!string.IsNullOrEmpty(hfDefaultSiteID.Value))
        //    defaultSiteID = int.Parse(hfDefaultSiteID.Value);
        //if (PNSettings.Prescribing.DefaultSiteNumber.HasValue)
        //    defaultSiteID = Sites.GetSiteIDByNumber(PNSettings.Prescribing.DefaultSiteNumber.Value);
        //else
        //    defaultSiteID = Database.ExecuteSQLScalar<int>("SELECT MIN(LocationID_Site) FROM PNProduct");
        //SessionInfo.InitialiseSessionAndSiteID(sessionID, defaultSiteID);

        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        ageRange = (AgeRangeType)Enum.Parse(typeof(AgeRangeType), Request["AgeRange"], true);

        if (!Page.IsPostBack)
        {
            // Force reload of products
            PNProduct.GetInstance(true);

            // Setup for depending on mode
            if (Request.QueryString["Mode"].EqualsNoCaseTrimEnd("add"))
            {
                PNLog.WriteToLog(SessionInfo.SiteID, "User has started to add a standard regimen.");
                Add();
            }
            else
            {
                int pnStandardRegimenID = int.Parse(Request["PNStandardRegimenID"]);
                PNLog.WriteToLog(SessionInfo.SiteID, null, null, null, null, null, "User is viewing a standard regimen:" + pnStandardRegimenID, string.Empty);

                Edit(pnStandardRegimenID);
            }
        }
        else
            regimenItems = JsonConvert.DeserializeObject<List<PNRegimenItem>>(hfRegimenItems.Value);
    }

    /// <summary>
    /// Called when the save button is clicked 
    /// Validates and saves a standard regimen
    /// </summary>
    protected void Save_Click(object sender, EventArgs e)
    {
        int pnPNStandardRegimenID = int.Parse(hfPNStandardRegimenID.Value);

        // Loads the standard regimen (loads nothing for add mode)
        PNStandardRegimen standardRegimens = new PNStandardRegimen();
        standardRegimens.LoadByID(pnPNStandardRegimenID);

        // Validate and save
        if (Validate(standardRegimens.FirstOrDefault()))
        {
            if (Save(pnPNStandardRegimenID, standardRegimens))
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Saved", "window.returnValue=" + standardRegimens[0].PNStandardRegimenID + "; window.close();", true);
        }
    }

    /// <summary>
    /// Called when print button is clicked.
    /// Generates XML to use with the report, and saves it to the session attribute
    /// Uses report 'Pharmacy Print Form Report {sitenumber}'
    /// </summary>
    protected void Print_Click(object sender, EventArgs e)
    {
        ReportPrintForm report = new  ReportPrintForm();
        //int siteNumber = Sites.GetNumberBySiteID(this.defaultSiteID); 18Mar15 XN 114207 get Standard Regimen editor to use ascribe site number
        int siteNumber = Sites.GetNumberBySiteID(SessionInfo.SiteID);

        report.Initialise("Emis Health PN Standard Regimen", siteNumber);

        // General section
        report.StartNewSection("General");
        report.AddValue(lbRegimenName, tbRegimenName);
        report.AddValue(lbDescription, tbDescription);
        report.AddValue(lbInUse,       cbInUse      );
        report.AddValue(lbPerKilo,     cbPerKilo    );

        // Product section
        report.StartNewSection("Products");
        foreach (PNRegimenItem item in this.regimenItems)
        {
            string volumeStr = item.VolumneInml.ToVDUIncludeZeroString() + (this.ageRange == AgeRangeType.Adult ? " ml" : " ml/kg");
            report.AddValue(item.GetProduct().Description, btnEdit.Enabled, volumeStr);
        }

        // Update info section
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

    protected void Add_OnClick(object sender, EventArgs e)
    {
        // Check have not reached max number of products
        if (this.regimenItems.Count() >= PNSettings.MaxNumberOfProductsInRegimen)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "MaxNumOfProducts", "alert('Reached max number of allowed regimen items.');", true);
            return;
        }

        InitaliseWizard("Add product");
        IEnumerable<PNProductRow> products = PNProduct.GetInstance().FindByAgeRange(ageRange).OrderBySortIndex();
        selectProductCtrl.Initalise(products, regimenItems, "Select product to add to standard regimen.", false);

        wizardAddProduct.ActiveStepIndex = 0;
        wizardAddProduct.ActiveStep.Controls.OfType<IPNWizardCtrl>().First().Focus();
    }

    protected void Edit_OnClick(object sender, EventArgs e)
    {
        string PNCode = hfSelectedPNCode.Value;
        if (string.IsNullOrEmpty(PNCode))
            return;

        InitaliseWizard("Edit product");

        PNProductRow product = PNProduct.GetInstance().FindByPNCode(PNCode);
        selectProductCtrl.Initalise(new PNProductRow[] {product}, regimenItems, string.Empty, false);
        selectProductCtrl.SetSelectedProduct (product);

        string caption = string.Format("Enter volume required of {0} in ml{1}", product, (ageRange == AgeRangeType.Paediatric) ? "/kg" : string.Empty);
        enterVolumeCtrl.Initalise(caption, regimenItems.FindByPNCode(PNCode).VolumneInml);

        wizardAddProduct.ActiveStepIndex = 1;
        wizardAddProduct.ActiveStep.Controls.OfType<IPNWizardCtrl>().First().Focus();
    }

    protected void Remove_OnClick(object sender, EventArgs e)
    {
        string PNCode = hfSelectedPNCode.Value;
        if (string.IsNullOrEmpty(PNCode))
            return;

        regimenItems.RemoveAll(i => i.PNCode == PNCode);
        hfRegimenItems.Value = JsonConvert.SerializeObject(regimenItems);

        string script = string.Format("var index = getRowIndexByAttribute('gridItemList', 'PNCode', '{0}'); removeAt('gridItemList', index);", PNCode);
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "RemoveItem", script, true);
        hfRegimenItems.Value = JsonConvert.SerializeObject(regimenItems);
        hfSelectedPNCode.Value = string.Empty;
    }
    #endregion

    #region Private Methods
    /// <summary>
    /// Called when wizard next, of finish buttons are clicked.
    /// Validates current page, and moves wizard to the next stage.
    /// Some wizard pages have client side validation
    /// </summary>
    protected void wizard_NextButtonClick(object sender, WizardNavigationEventArgs e)
    {
        // Get page
        WizardStepBase          currentStep = wizardAddProduct.WizardSteps[e.CurrentStepIndex];
        IPNWizardCtrl page        = currentStep.Controls.OfType<IPNWizardCtrl>().FirstOrDefault();

        // Validate page
        if ((page != null) && !page.Validate(null, new PNViewAndAdjustInfo()))
            e.Cancel = true;

        // If okay move the next page (depends on add method)
        if (!e.Cancel)
        {
            if (wizardAddProduct.ActiveStepIndex == 1)
            {
                PNProductRow product = selectProductCtrl.GetSelectedProduct();
                double volumeInml = enterVolumeCtrl.Value;

                PNRegimenItem item = regimenItems.FindByPNCode(product.PNCode);
                if (item == null)
                {
                    item = new PNRegimenItem(product.PNCode, volumeInml);
                    regimenItems.Add(item);
                }
                else
                    item.VolumneInml = volumeInml;

                CreateGrid();
                AddProductToGrid(item);

                string row = gridItemList.ExtractHTMLRows(0, 1)[0].Replace("\r\n", string.Empty);
                string script = string.Format("$('#wizardPopup').dialog('close'); $('#hfRegimenItems').val('{1}'); $('#hfSelectedPNCode').val('{2}'); UpdateGridRow('{0}');", Generic.XMLEscape(row), JsonConvert.SerializeObject(regimenItems), product.PNCode);
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", script, true);
            }
            else
            {
                PNProductRow product= selectProductCtrl.GetSelectedProduct();
                double? volume  = null;
                if (regimenItems.FindByPNCode(product.PNCode) != null)
                    volume = regimenItems.FindByPNCode(product.PNCode).VolumneInml;
                string caption = string.Format("Enter volume required of {0} in ml{1}", product, (ageRange == AgeRangeType.Paediatric) ? "/kg" : string.Empty);
                enterVolumeCtrl.Initalise(caption, volume);

                wizardAddProduct.ActiveStepIndex = wizardAddProduct.ActiveStepIndex + 1;
                wizardAddProduct.ActiveStep.Controls.OfType<IPNWizardCtrl>().First().Focus();
            }
        }
    }

    /// <summary>
    /// Called when add product wizard cancel button is clicked
    /// Hides the wizard
    /// </summary>
    protected void wizard_CancelButtonClick(object sender, EventArgs e)
    {
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "CancelWizard", "$('#wizardPopup').dialog('close');", true);
    }

    private void InitaliseWizard(string title)
    {
        IEnumerable<Control> controls = wizardAddProduct.WizardSteps.OfType<Control>().Desendants(c => c.Controls.OfType<Control>());
        foreach (IPNWizardCtrl page in controls.OfType<IPNWizardCtrl>())
            page.Initalise();

        string script = "$('#wizardPopup').dialog({"    +
                            "modal: true, "             + 
                            "resizable: false, "        + 
                            "width: '450px', "          + 
                            "title: '" + title + "', "  + 
                            "open: function(type, data) { $(this).parent().appendTo('form'); $(this).dialog('option', 'position', 'center'); }" +
                            "});";
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "ShowWizard", script, true);
    }

    private void CreateGrid()
    {
        gridItemList.AddColumn("Product", 75, PharmacyGridControl.ColumnType.Text  );
        gridItemList.AddColumn("Volume",  20, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Right);
        gridItemList.SortableColumns           = true;
        gridItemList.EnableAlternateRowShading = true;
        gridItemList.VerticalScrollBar         = false;
    }

    private void AddProductToGrid(PNRegimenItem item)
    {
        PNProductRow product = PNProduct.GetInstance().FindByPNCode(item.PNCode);

        gridItemList.AddRow();
        gridItemList.AddRowAttribute("PNCode",    product.PNCode);
        gridItemList.AddRowAttribute("SortIndex", product.SortIndex.ToString());
        gridItemList.SetCell(0, product.ToString());
        gridItemList.SetCell(1, item.VolumneInml.ToVDUIncludeZeroString() + (ageRange == AgeRangeType.Adult ? " ml" : " ml/kg"));
    }

    /// <summary>Puts the from in add mode</summary>
    private void Add()
    {
        addMode = true;

        // Check if allowed to add
        if (!PNSettings.PNStandardRegimen.AllowAdding)
            throw new ApplicationException("You are not allowed to add a standard regimen.");

        // Initialise the form controls
        Initialise();
        this.regimenItems = new List<PNRegimenItem>();

        // set the form controls
        hfRegimenItems.Value        = JsonConvert.SerializeObject(this.regimenItems);
        hfPNStandardRegimenID.Value = "-1";
        hfLastModifiedDate.Value    = string.Empty;
    }

    /// <summary>Puts form into edit mode</summary>
    /// <param name="pnStandardRegimenID">ID of the standard regimen being edited</param>
    public void Edit(int pnStandardRegimenID)
    {
        addMode = false;

        // Initalise the form controls
        Initialise();

        // Get the PNStandardRegimen
        PNStandardRegimen standardRegimens = new PNStandardRegimen();
        standardRegimens.LoadByID(pnStandardRegimenID);
        PNStandardRegimenRow standardRegimen = standardRegimens.First();
        
        hfPNStandardRegimenID.Value = pnStandardRegimenID.ToString();
        hfLastModifiedDate.Value = standardRegimen.LastModifiedDate.ToString(LastModDateTimePattern);

        // Set General items
        tbRegimenName.Text = standardRegimen.RegimenName;
        tbDescription.Text = standardRegimen.Description;
        cbInUse.Checked    = standardRegimen.InUse;
        cbPerKilo.Checked  = standardRegimen.PerKilo;

        // Add items to list
        regimenItems = standardRegimen.GetRegimenItems().Where(p => p.GetProduct() != null).OrderBySortIndex().ToList();
        foreach (PNRegimenItem item in regimenItems)
            AddProductToGrid(item);
        hfRegimenItems.Value = JsonConvert.SerializeObject(regimenItems);

        // Update info (Last modified by XN on 15/04/11 15:16 terminal Fred)
        bool hasBeenModified = false;
        StringBuilder modifiedInfo = new StringBuilder("Last modified");

        PersonRow person = standardRegimen.GetLastModifiedUser();
        if (person != null)
        {
            modifiedInfo.Append(" by ");
            modifiedInfo.Append(person.Description);
            hasBeenModified = true;
        }

        modifiedInfo.Append(" on ");
        modifiedInfo.Append(standardRegimen.LastModifiedDate.ToPharmacyDateTimeString());
        hasBeenModified = true;

        LocationRow location = standardRegimen.GetLastModifiedTerminal();
        if (location != null)
        {
            modifiedInfo.Append(" terminal ");
            modifiedInfo.Append(standardRegimen.LastModifiedTerminal);
            hasBeenModified = true;
        }
        lbModifiedInfo.Text = hasBeenModified ? modifiedInfo.ToString() : "Never been modified";
        tbInfo.Text         = standardRegimen.Information;
    }

    /// <summary>
    /// Initialise the controls to be readonly depending on WConfiguration setting
    ///  Category: D|PN
    ///  Section:  PNStandardRegimenEditor
    ///  Key:      EditableFields
    /// </summary>
    private void Initialise()
    {
        HashSet<string> editableFields = PNSettings.PNStandardRegimen.EditableFields;
        Type pnStandardRegimenRowType = typeof(PNStandardRegimenRow);

        // Clean the form
        IEnumerable<Control> pageControls = Page.Controls.OfType<Control>().Desendants(i => i.Controls.OfType<Control>()).ToList();
        pageControls.OfType<TextBox>().ToList().ForEach (t => t.Text    = string.Empty);
        pageControls.OfType<CheckBox>().ToList().ForEach(t => t.Checked = false       );
        pageControls.OfType<Label>().Where(l => l.CssClass == "ErrorMessage").ToList().ForEach(t => t.Text="&nbsp;");

        // General
        tbRegimenName.ReadOnly  = !addMode && !editableFields.Contains("regimenname");
        tbDescription.ReadOnly  = !addMode && !editableFields.Contains("description");
        cbInUse.Enabled         =  addMode || editableFields.Contains("inuse");
        cbPerKilo.Checked       = (this.ageRange == AgeRangeType.Paediatric);
        cbPerKilo.Enabled       =  editableFields.Contains("perkilo");

        // Standard Regimen
        CreateGrid();
        btnAdd.Visible          = addMode || editableFields.Contains("products");
        btnEdit.Visible         = addMode || editableFields.Contains("products");
        btnRemove.Visible       = addMode || editableFields.Contains("products");

        // Update info
        tbInfo.ReadOnly         = !addMode && !editableFields.Contains("info");
        if (tbInfo.ReadOnly)
            tbInfo.BackColor = Color.FromArgb(235, 235, 235);
    }

    /// <summary>
    /// Validates the forms data
    /// Only validates writable controls
    /// </summary>
    /// <param name="standardRegimen">Standard regimen to validate (null if adding) used to check editing time</param>
    /// <returns>If valid form data</returns>
    private bool Validate(PNStandardRegimenRow standardRegimen)
    {
        PNStandardRegimenColumnInfo columnInfo = PNStandardRegimen.GetColumnInfo();
        int pnStandardRegimenID = (standardRegimen == null) ? -1 : standardRegimen.PNStandardRegimenID;
        string error = string.Empty;
        bool ok = true;

        // Get the last modified date saved to the form
        DateTime? lastModifiedDate = null;
        if (!string.IsNullOrEmpty(hfLastModifiedDate.Value))
            lastModifiedDate = DateTime.ParseExact(hfLastModifiedDate.Value, LastModDateTimePattern, CultureInfo.CurrentCulture);

        // If editing and date of db record is not same as when form was open then error
        if (lastModifiedDate.HasValue && (standardRegimen != null))
        {
            if (lastModifiedDate != standardRegimen.LastModifiedDate)
            {
                StringBuilder errorMsg = new StringBuilder();
                errorMsg.Append("Standard regimen has been updated by another user.<br />");
                errorMsg.Append("User: " + standardRegimen.GetLastModifiedUser().Description.Replace("'", "\\'") + "<br />");
                errorMsg.Append("Date: " + standardRegimen.LastModifiedDate.ToPharmacyDateString() + "<br />");
                errorMsg.Append("<br />");
                errorMsg.Append("Please cancel your changes, refresh list of standard products, and re-edit.");

                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "EditByAnotherUser", "alertEnh('" + errorMsg + "');", true);
                return false;
            }
        }

        // Clear all error labels
        Page.Controls.OfType<Control>().Desendants(i => i.Controls.OfType<Control>()).OfType<Label>().Where(l => l.CssClass == "ErrorMessage").ToList().ForEach(t => t.Text="&nbsp;");

        // General information
        if (!tbRegimenName.ReadOnly)
        {
            if (!Validation.ValidateText(tbRegimenName, "regimen name", typeof(string), true, columnInfo.RegimenNameLength, out error))
            {
                lbRegimenNameError.Text = error;
                ok = false;
            }
            else
            {
                PNStandardRegimen standardRegimens = new PNStandardRegimen();
                standardRegimens.LoadByRegimenName(tbRegimenName.Text);
                if (standardRegimens.Any(p => p.PNStandardRegimenID != pnStandardRegimenID))
                {
                    lbRegimenNameError.Text = "Name is not unique.";
                    ok = false;
                }
            }
        }

        if (!tbDescription.ReadOnly && !Validation.ValidateText(tbDescription, "Description", typeof(string), false, columnInfo.DescriptionLength, out error))
        {
            lbDescriptionError.Text = error;
            ok = false;
        }

        // Update Info
        if (!tbInfo.ReadOnly && !Validation.ValidateText(tbInfo, "Info", typeof(string), false, out error))
        {
            lbInfoError.Text = error;
            ok = false;
        }

        return ok;
    }

    /// <summary>Save form data</summary>
    /// <param name="standardRegimen">List of standard regimens to save to</param>
    private bool Save(int pnStandardRegimenID, PNStandardRegimen pnStandardRegimens)
    {
        addMode = !pnStandardRegimens.Any();

        PNStandardRegimenRow        standardRegimen = addMode ? pnStandardRegimens.Add() : pnStandardRegimens.First(p => p.PNStandardRegimenID == pnStandardRegimenID);
        PNStandardRegimenColumnInfo columnInfo      = PNStandardRegimen.GetColumnInfo();
        bool bOK = false;
        
        // If editing exist row take copy (for log)
        PNStandardRegimen    standardRegimenTemp    = new PNStandardRegimen();  
        PNStandardRegimenRow standardRegimenOringal = standardRegimenTemp.Add();
        if (!addMode)
            standardRegimenOringal.CopyFrom(standardRegimen);

        // General
        standardRegimen.RegimenName  = tbRegimenName.Text;
        standardRegimen.Description  = tbDescription.Text;
        standardRegimen.InUse        = cbInUse.Checked;
        standardRegimen.PerKilo      = cbPerKilo.Checked;

        // Details
        standardRegimen.LastModifiedDate         = DateTime.Now;
        standardRegimen.LastModifiedEntityID_User= SessionInfo.EntityID;
        standardRegimen.LastModifiedTerminal     = SessionInfo.LocationID;
        standardRegimen.Information              = tbInfo.Text;

        // Generate log
        StringBuilder log = new StringBuilder();
        if (addMode)
            PNLog.AddDataRow(log, "Adding new standard regimen", standardRegimen.RawRow);
        else
        {
            log.AppendLine("Updated following standard regimen details:");
            PNLog.CompareDataRow(log, standardRegimenOringal.RawRow, standardRegimen.RawRow);
        }

        // Save
        try
        {
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                pnStandardRegimens.Save();
                PNLog.WriteToLog(SessionInfo.SiteID, null, null, null, null, null, log.ToString(), string.Empty);

                standardRegimen.SaveRegimenItems(regimenItems);

                trans.Commit();
            }

            bOK = true;
        }
        catch (DBConcurrencyException)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "EditByAnotherUser", "alert('Standard regimen has been recently modified, and can't be saved. Refresh list and try again.');", true);
        }

        return bOK;
    }
    #endregion
}
