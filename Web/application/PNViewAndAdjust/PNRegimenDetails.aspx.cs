//===========================================================================
//
//						    PNRegimenDetails.aspx.cs
//
//  Displays regimen details, and requirments form.
//
//  Call the page with the follow parameters
//  SessionID   - ICW session ID
//  SiteID      - SiteID the regimen is on 
//  RequestID   - Regimen request ID
//  Tab         - Tab selected by default (either 'Requirements', 'Regimen'), regimen is the default
//
//  The form does not access db directly, but instead calls PNProcessor.GetFromCache
//  to get the regimen, and updates this directly (does not save them to db)
//
//  On requirements page whenever user changes text for pead regimens this needs to update 
//  total value this is done via
//      text_Changed                - java method that fires when ingredients update
//          ingredient_TextChanged  - web method called to calc new total value
//  Data is passed from web method to client side using struct IngredientTextChangedResult
//  
//  Usage:
//  PNRegimenDetails.aspx?SessionID=123&SiteID=29&RequestID=15&Tab=Requirements
//
//	Modification History:
//	20Mar12 XN  Written
//  25Mar12 XN  TFS29994 Added more advance regimen name generation, and 
//              modification number. So regimen name can fit on label
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;

public partial class application_PNViewAndAdjust_PNRegimenDetails : System.Web.UI.Page
{
    #region Data Types
    // Used to pass data from ingredient_TextChanged to client side
    private struct IngredientTextChangedResult
    {
        public string value;
        public string value_PerKilo;
    };
    #endregion

    #region Private Members
    private PNProcessor processor;
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        int  sessionID  = int.Parse(Request["SessionID"]);
        int  siteID     = int.Parse(Request["SiteID"]);
        
        int? requestID = null;
        if (!string.IsNullOrEmpty(Request["RequestID"]))
            requestID = int.Parse(Request["RequestID"]);
        
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);

        // Get regimen info from cache
        processor = PNProcessor.GetFromCache(requestID, false);

        // Rebuild details view (done everytime as controls are dynamically created)
        // TFS30506 28Mar12 XN Moved creationg of requirements before set focus
        RequirementsView(this.IsPostBack);

        if (!this.IsPostBack)
        {
            RegimenView();

            // TFS30506 28Mar12 XN Set focus on first control when page is displayed
            if (Request["Tab"] == "Requirements")
            {
                SelectTab(btnRequirements);
                TextBox tb = tbIngredients.Rows[0].Cells.Cast<TableCell>().Select(c => c.Controls[0]).OfType<TextBox>().FirstOrDefault();
                if (tb != null)
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "Focus", string.Format("$('#{0}').focus(); $('#{0}').select();", tb.UniqueID), true);
            }
            else
            {
                SelectTab(btnRegimen);
                tbRegimenName.Focus();
            }
        }

        // Rebuild details view (done everytime as controls are dynamically created)
        //RequirementsView(this.IsPostBack);    TFS30506 28Mar12 XN Moved creationg of requirements before set focu
    }

    /// <summary>
    /// Called when one of the tab buttons is clicked.
    /// Displays the tab screen
    /// </summary>
    protected void tab_OnClick(object sender, EventArgs e)
    {
        SelectTab(sender as Button);
    }

    /// <summary>
    /// Called when OK button is clicked
    /// Validates and saves data (back to the cache)
    /// </summary>
    protected void OK_Click(object sender, EventArgs e)
    {
        bool close = false;

        if (!processor.Regimen.IsLocked)
            close = true;
        else if (Validate())
        {
            Save();
            close = true;
        }

        if (close)
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Close", "window.close(); window.returnValue = true;", true);
    }

    /// <summary>
    /// Called when IsCombined checkbox is clicked
    /// Hides\display lipid overage text box
    /// </summary>
    protected void IsCombined_CheckedChanged(object sender, EventArgs e)
    {
        UpdateInfusionAndOverage();
    }

    /// <summary>
    /// Called when Supply48Hrs checkbox is clicked
    /// Display warning message
    /// </summary>
    protected void Supply48Hrs_CheckedChanged(object sender, EventArgs e)
    {
        UpdateInfusionAndOverage();
    }
    #endregion

    #region Web Methods
    /// <summary>
    /// Web method called when user changes ingredient text 
    /// Returns json string version of IngredientTextChangedResult
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="requestID">Regimen request ID</param>
    /// <param name="dbName">Ingredient being updated</param>
    /// <param name="value">Value enterd by user</param>
    /// <returns>Returns json string version of IngredientTextChangedResult</returns>
    [WebMethod]
    public static string ingredient_TextChanged(int sessionID, int? requestID, string dbName, string value)
    {
        SessionInfo.InitialiseSession(sessionID);

        PNIngredientRow             ing      = PNIngredient.GetInstance().FindByDBName(dbName);
        IngredientTextChangedResult result   = new IngredientTextChangedResult();
        PNProcessor                 processor= PNProcessor.GetFromCache(requestID, false);
        double  valueDbl;

        result.value         = value;
        result.value_PerKilo = string.Empty;

        if (double.TryParse(value, out valueDbl))
        {
            result.value = valueDbl.ToPNString();
            if (result.value == "0.00")
                result.value = "0";

            // TFS30506 28Mar12 XN Got RequirementView and ingredient_TextChanged to display value in same format
            if (processor.Prescription.AgeRage == AgeRangeType.Paediatric)
                result.value_PerKilo = string.Format("({0:0.##} {1})", (valueDbl * processor.Prescription.DosingWeightInkg).To3SigFigish(), ing.GetUnit().Abbreviation);
        }

        return JsonConvert.SerializeObject(result);
    }
    #endregion

    #region Private Methods
    /// <summary>Selects and displays the tab, based on tab button</summary>
    /// <param name="tabButton">tab button selected</param>
    private void SelectTab(Button tabButton)
    {
        btnRegimen.CssClass    = "Tab";
        btnRequirements.CssClass  = "Tab";

        if (tabButton == btnRegimen)
        {
            btnRegimen.CssClass = "TabSelected";
            multiView.ActiveViewIndex = 0;
        }
        else if (tabButton == btnRequirements)
        {
            btnRequirements.CssClass = "TabSelected";
            multiView.ActiveViewIndex = 1;
        }
    }

    /// <summary>Updates infusion duration boxes, based on if regimen is combined or not</summary>
    private void UpdateInfusionAndOverage()
    {
        divInfusionHoursLipid.Visible = !cbIsCombined.Checked;
        if (cbIsCombined.Checked)
            lbInfusionHoursAqueousOrCombined.InnerText = "Hours for combined infusion";
        else
            lbInfusionHoursAqueousOrCombined.InnerText = "Hours for aqueous infusion";

        divOverageLipid.Visible              = !cbIsCombined.Checked;
        lbOverageAqueousOrCombined.InnerText = (cbIsCombined.Checked ? "Overage combined" : "Overage aqueous")  + (cbSupply48Hrs.Checked ? " (48 Hrs)" : " (24 Hrs)");
        lbOverageLipid.InnerText             = "Overage lipid" + (cbSupply48Hrs.Checked ? " (48 Hrs)" : " (24 Hrs)");
    }

    /// <summary>Populates the main regimen view</summary>
    private void RegimenView()
    {
        bool enabled  = processor.Regimen.IsLocked;
        bool readOnly = !enabled;

        tbRegimenName.Text        = processor.Regimen.ExtractBaseName();    //  TFS29994 25Mar12 XN  Added more advance regimen name generation, and modification number. So regimen name can fit on label
        tbRegimenName.ReadOnly    = readOnly;
        cbIsCombined.Checked      = processor.Regimen.IsCombined;
        cbIsCombined.Enabled      = enabled;
        cbCentralLineOnly.Checked = processor.Regimen.CentralLineOnly;
        cbCentralLineOnly.Enabled = enabled;
        divSupply48Hrs.Visible    = PNSettings.Prescribing.Allow48HourBags() || processor.Regimen.Supply48Hours;
        cbSupply48Hrs.Checked     = processor.Regimen.Supply48Hours;
        cbSupply48Hrs.Enabled     = enabled;

        tbInfusionHoursAqueousOrCombined.Text   = processor.Regimen.InfusionHoursAqueousOrCombined.ToString("#");
        tbInfusionHoursAqueousOrCombined.ReadOnly= readOnly;
        tbInfusionHoursLipid.Text               = processor.Regimen.InfusionHoursLipid.ToString("#");
        tbInfusionHoursLipid.ReadOnly           = readOnly;
        divInfusionHoursLipid.Visible           = !cbIsCombined.Checked;

        //TFS30748 29Mar12 XN removed being able to set syringe info from regimen details 
        //syringeDiv.Visible           = processor.Prescription.PerKiloRules;
        //cbSupplyLipidSyringe.Checked = processor.Regimen.SupplyLipidSyringe;
        //cbSupplyLipidSyringe.Enabled = enabled;
        //tbNumberOfSyringes.Text      = processor.Regimen.NumberOfSyringes.ToString();
        //tbNumberOfSyringes.ReadOnly  = readOnly;

        tbOverageAqueousOrCombined.Text     = processor.Regimen.OverageAqueousOrCombined == null ? string.Empty : processor.Regimen.OverageAqueousOrCombined.Value.ToPNString();
        tbOverageAqueousOrCombined.ReadOnly = readOnly;
        tbOverageLipid.Text                 = processor.Regimen.OverageLipid             == null ? string.Empty : processor.Regimen.OverageLipid.Value.ToPNString();
        tbOverageLipid.ReadOnly             = readOnly;
        divOverageLipid.Visible             = !cbIsCombined.Checked;

        if (tbOverageAqueousOrCombined.Text == "0.00")
            tbOverageAqueousOrCombined.Text = "0";
        if (tbOverageLipid.Text == "0.00")
            tbOverageLipid.Text = "0";

        UpdateInfusionAndOverage();
    }

    /// <summary>Populates the main requirment view</summary>
    private void RequirementsView(bool postback)
    {
        lbDosingWeight.Text = string.Format("Dosing weight {0} kg", processor.Prescription.DosingWeightInkg);
        bool readOnly = !processor.Regimen.IsLocked;

        double weightDiv = processor.Prescription.PerKiloRules ? processor.Prescription.DosingWeightInkg : 1.0;
        DataColumnCollection colums = processor.Regimens.Table.Columns;
        IEnumerable<PNIngredientRow> ingredients = PNIngredient.GetInstance().Where(i => i.ForPrescribing && colums.Contains(i.DBName)).OrderBySortIndex();
        foreach (PNIngredientRow ingredient in ingredients)
        {
            TableRow newRow = new TableRow();
            TableCell cell;
            string  unitStr  = ingredient.GetUnit().Abbreviation;
            double? ingValue = processor.Regimen.GetIngredient(ingredient.DBName);;

            // Add ingredient label
            cell = new TableCell();
            cell.Style["border-bottom"] = "solid 1px #9CCFFF";
            Label name = new Label();
            name.Text  = ingredient.Description.ToUpperFirstLetter() + "&nbsp;";
            name.Width = Unit.Parse("125px");
            cell.Controls.Add(name);
            newRow.Cells.Add(cell);

            // Add ingredient textbox
            cell = new TableCell();
            cell.Style["border-bottom"] = "solid 1px #9CCFFF";
            TextBox value = new TextBox();
            value.ID = ingredient.DBName;
            value.Attributes["LongName"] = ingredient.Description;
            value.ReadOnly = readOnly;
            cell.Controls.Add(value);
            newRow.Cells.Add(cell);
            if (!ingValue.HasValue && readOnly)
            {
                value.Width = new Unit(100, UnitType.Pixel);
                value.Style.Add(HtmlTextWriterStyle.Color,     "Maroon");
                value.Style.Add(HtmlTextWriterStyle.FontStyle, "italic");
                value.Text = "       Not entered.";
                cell.ColumnSpan = 3;
            }
            else
            {
                value.Width = new Unit(55.0, UnitType.Pixel);
                value.Style.Add(HtmlTextWriterStyle.TextAlign, "right");
                if (ingValue.HasValue)
                {
                    value.Text = (ingValue.Value / weightDiv).ToPNString();
                    if (value.Text == "0.00")
                        value.Text = "0";
                    value.Attributes.Add("OriginalVersion", value.Text);    // TFS30506 28Mar12 XN Added to prevent unneeded calles to ingredient_TextChanged causing calculated total value to be changed incorrectly
                }
                value.Attributes.Add("onblur", "text_Changed(this)");
            }

            if (ingValue.HasValue || !readOnly)
            {
                // Add unit label
                cell = new TableCell();
                cell.Style["border-bottom"] = "solid 1px #9CCFFF";
                Label units = new Label();
                units.Width = Unit.Parse("75px");
                if ((ingValue == null) && readOnly)
                    units.Text = "&nbsp;";
                else
                    units.Text = "&nbsp;" + unitStr + (this.processor.Prescription.PerKiloRules ? " /kg" : string.Empty);
                cell.Controls.Add(units);
                newRow.Cells.Add(cell);

                // PerKilo label
                cell = new TableCell();
                cell.Style["border-bottom"] = "solid 1px #9CCFFF";
                TextBox perKilo = new TextBox();
                perKilo.ID = ingredient.DBName + "_PerKilo";
                perKilo.Width = Unit.Parse("110px");
                perKilo.ForeColor = System.Drawing.Color.FromArgb(183, 0, 0);
                perKilo.TabIndex = -1;
                perKilo.Style["border"] = "none";
                perKilo.Attributes["readonly"] = "readonly";
                if (processor.Prescription.PerKiloRules && ingValue != null)
                    perKilo.Text = string.Format("({0:0.##} {1})", ingValue.Value.To3SigFigish(), ingredient.GetUnit().Abbreviation);   // TFS30506 28Mar12 XN Got RequirementView and ingredient_TextChanged to display value in same format
                cell.Controls.Add(perKilo);
                newRow.Cells.Add(cell);
            }

            tbIngredients.Rows.Add(newRow);
        }
    }

    /// <summary>Validates the regimen</summary>
    private bool Validate()
    {
        string error;
        bool OK = true;

        // Clear all error labels
        Page.Controls.OfType<Control>().Desendants(i => i.Controls.OfType<Control>()).OfType<Label>().Where(l => l.CssClass == "ErrorMessage").ToList().ForEach(t => t.Text="&nbsp;");

        // Regimen tab
        if (!Validation.ValidateText(tbRegimenName, string.Empty, typeof(string), true, PNRegimen.GetColumnInfo().DescriptionLength - 18, out error))   // TFS29994 Description lenght - modification text which is appended on
        {
            lbRegimenNameError.Text = error;
            tbRegimenName.Focus();
            SelectTab(btnRegimen);
            OK = false;
        }
        if (!Validation.ValidateText(tbInfusionHoursAqueousOrCombined, string.Empty, typeof(int), true, 0, 99, out error)) 
        {
            lbInfusionHoursAqueousOrCombinedError.Text = error;
            tbInfusionHoursAqueousOrCombined.Focus();
            SelectTab(btnRegimen);
            OK = false;
        }
        if (!cbIsCombined.Checked && !Validation.ValidateText(tbInfusionHoursLipid, string.Empty, typeof(int), true, 0, 99, out error))
        {
            lbInfusionHoursLipidError.Text = error;
            tbInfusionHoursLipid.Focus();
            SelectTab(btnRegimen);
            OK = false;
        }
        //TFS30748 29Mar12 XN removed being able to set syringe info from regimen details 
        //if (processor.Prescription.PerKiloRules && !Validation.ValidateText(tbNumberOfSyringes, string.Empty, typeof(int), true, 0, 99, out error))
        //{
        //    lbNumberOfSyringesError.Text = error;
        //    tbNumberOfSyringes.Focus();
        //    SelectTab(btnRegimen);
        //    OK = false;
        //}
        if (!Validation.ValidateText(tbOverageAqueousOrCombined, string.Empty, typeof(double), true, 0, 9999, out error)) 
        {
            lbOverageAqueousOrCombinedError.Text = error;
            tbOverageAqueousOrCombined.Focus();
            SelectTab(btnRegimen);
            OK = false;
        }
        if (!cbIsCombined.Checked && !Validation.ValidateText(tbOverageLipid, string.Empty, typeof(double), true, 0, 9999, out error))
        {
            lbOverageLipidError.Text = error;
            tbOverageLipid.Focus();
            SelectTab(btnRegimen);
            OK = false;
        }

        // Requiments tab
        IEnumerable<TextBox> tbs = tbIngredients.Controls.OfType <Control>().Desendants(c => c.Controls.OfType<Control>()).OfType<TextBox>().Where(t => t.Attributes["LongName"] != null);
        foreach (TextBox tbIng in tbs)
        {            
            if (!Validation.ValidateText(tbIng, tbIng.Attributes["LongName"], typeof(double), false, 0.0, 10000.0, out error))
            {
                lbIngredientError.Text = error;
                tbIng.Focus();
                if (OK)
                    SelectTab(btnRequirements);   // Select detail tab but only if not errors on main tab
                OK = false;
                break;
            }
        }

        return OK;
    }

    /// <summary>Saves the regimen</summary>
    private void Save()
    {
        // Regmien tab
        processor.Regimen.IsCombined      = cbIsCombined.Checked;
        processor.Regimen.CentralLineOnly = cbCentralLineOnly.Checked;
        processor.Regimen.Supply48Hours   = cbSupply48Hrs.Checked;

        processor.Regimen.InfusionHoursAqueousOrCombined = int.Parse(tbInfusionHoursAqueousOrCombined.Text);
        if (!cbIsCombined.Checked)
            processor.Regimen.InfusionHoursLipid = int.Parse(tbInfusionHoursLipid.Text);

        //TFS30748 29Mar12 XN removed being able to set syringe info from regimen details 
        //if (processor.Prescription.PerKiloRules)
        //{
        //    processor.Regimen.SupplyLipidSyringe = cbSupplyLipidSyringe.Checked;
        //    processor.Regimen.NumberOfSyringes   = int.Parse(tbNumberOfSyringes.Text);
        //}

        processor.Regimen.OverageAqueousOrCombined = double.Parse(tbOverageAqueousOrCombined.Text);
        if (!cbIsCombined.Checked)
            processor.Regimen.OverageLipid = double.Parse(tbOverageLipid.Text);

        // Reguiment tab
        double weightMulti = processor.Prescription.PerKiloRules ? processor.Prescription.DosingWeightInkg : 1.0;
        IEnumerable<TextBox> tbs = tbIngredients.Controls.OfType <Control>().Desendants(c => c.Controls.OfType<Control>()).OfType<TextBox>().Where(t => t.Attributes["LongName"] != null);
        foreach (TextBox tbIng in tbs)
        {
            double? value = string.IsNullOrEmpty(tbIng.Text) ? (double?)null : double.Parse(tbIng.Text) * weightMulti;
            processor.Regimen.SetIngredient(tbIng.ID, value);
        }

        processor.Regimen.CreateName(tbRegimenName.Text);   //  TFS29994 25Mar12 XN  Added more advance regimen name generation, and modification number. So regimen name can fit on label
    }
    #endregion
}
