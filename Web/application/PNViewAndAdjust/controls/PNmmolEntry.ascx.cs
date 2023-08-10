//===========================================================================
//
//					  	        PNmmolEntry.aspx.cs
//
//  Control used in the PN add product wizard to allow selection of PN mmol entry type
//
//	Modification History:
//	15Nov11 XN  Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.icwdatalayer;

public partial class application_PNViewAndAdjust_controls_PNmmolEntry : System.Web.UI.UserControl, IPNWizardCtrl
{
    protected void Page_Load(object sender, EventArgs e) { }

    /// <summary>
    /// Initalise radio button text (for add method wizard)
    /// If adult regimen total button is checked by default
    /// If paediatric regimen total button is checked by default
    /// </summary>
    /// <param name="ageRange">Regimen age range (used to determine which radio button is selected by default)</param>
    /// <param name="productName">Product name</param>
    /// <param name="ingredientName">Ingredient name</param>
    /// <param name="ingredientUnits">Ingredient units</param>
    public void Initalise(AgeRangeType ageRange, string productName, string ingredientName, string ingredientUnits)
    {
        // Set caption, and radio button text
        lbCaption.Text = "Select entry by Total or per Kg using " + productName;
        rdTotal.Text = "Enter " + ingredientName + " as total " + ingredientUnits;
        rdPerKg.Text = "Enter " + ingredientName + " as " + ingredientUnits + "/kg";

        // Set default radio button
        rdTotal.Checked = (ageRange == AgeRangeType.Adult);
        rdPerKg.Checked = (ageRange == AgeRangeType.Paediatric);
    }

    /// <summary>
    /// Initalise radio button text (for set method volume or calories wizard)
    /// If adult regimen total button is checked by default
    /// If paediatric regimen total button is checked by default
    /// </summary>
    /// <param name="ageRange">Regimen age range (used to determine which radio button is selected by default)</param>
    /// <param name="dosingWeightInkg">Patient dosing weight</param>
    /// <param name="ingredientDBName">Ingredient DB name</param>
    /// <param name="processor">PN processor</param>
    public void Initalise(AgeRangeType ageRange, double dosingWeightInkg, PNIngredientRow setIngredient, PNProcessor processor)
    {
        UnitRow unit = setIngredient.GetUnit();
        double totalIng = processor.CalculateTotal(setIngredient.DBName);

        lbCaption.Text = string.Format("Enter {0} as total {1} or {1} per kg", setIngredient, unit.Abbreviation);
        rdTotal.Text   = string.Format("&nbsp;Total {0} = {1} {2}", setIngredient, totalIng.ToPNString(), unit.Abbreviation);
        rdPerKg.Text   = string.Format("&nbsp;{0} in {2} per kg = {1} {2}/kg", setIngredient, (totalIng / dosingWeightInkg).ToPNString(), unit.Abbreviation);

        // Set default radio button
        rdTotal.Checked = (ageRange == AgeRangeType.Adult);
        rdPerKg.Checked = (ageRange == AgeRangeType.Paediatric);
    }

    /// <summary>Returns the user's selection</summary>
    public PNUtils.mmolEntryType EntryType
    {
        get
        {
            if (rdTotal.Checked)
                return PNUtils.mmolEntryType.Total;
            if (rdPerKg.Checked)
                return PNUtils.mmolEntryType.PerKg;

            throw new ApplicationException("Invalid mmol entry selection");
        }
        set
        {
            rdTotal.Checked = (value == PNUtils.mmolEntryType.Total);
            rdPerKg.Checked = (value == PNUtils.mmolEntryType.PerKg);
        }
    }

    #region IPNWizardCtrl Members
    public void Initalise()
    {        
        lbCaption.Text = string.Empty;
        rdTotal.Text   = string.Empty;
        rdPerKg.Text   = string.Empty;
    }

    public int? RequiredHeight { get { return null; } }

    public void Focus()
    {
        if (this.Controls.OfType<RadioButton>().Any(r => r.Checked))
        {
            string ID = this.Controls.OfType<RadioButton>().First(r => r.Checked).ClientID;
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "PNmmolEntryFocus", "$('#" + ID + "').focus();", true);
        }
    }

    public bool Validate(PNProcessor regimenProcess, PNViewAndAdjustInfo info) { return true; }
    #endregion
}
