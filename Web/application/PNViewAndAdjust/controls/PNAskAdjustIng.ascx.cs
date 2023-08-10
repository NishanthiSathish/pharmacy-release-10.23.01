//===========================================================================
//
//					  	    PNAskAdjustIng.aspx.cs
//
//  Control used in the PN add product wizard to determine if Na, or K values
//  have changed from the last update, and asks the user if they want to save 
//  matain the original values.
//
//  Note: A lot of the calcuations in this control, and the calculation to determine
//  if the ingredient values should be adjusted, need to go into the PNProcessor class
//
//	Modification History:
//	15Nov11 XN  Written
//  12Apr12 XN  TFS31585 Replaced CheckBoxList with 2 checkboxes so can implement 
//              keyboard navigation!
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.shared;

public partial class application_PNViewAndAdjust_controls_PNAskAdjustIng : System.Web.UI.UserControl, IPNWizardCtrl
{
    PNProcessor  originalRegimen;
    PNProcessor  newRegimen;
    PNProductRow productBeingEdited;

    protected void Page_Load(object sender, EventArgs e)
    {

    }

    /// <summary>Setup form to determine if Na, or K can be adjusted</summary>
    /// <param name="msg">Message to show at top of form</param>
    /// <param name="productBeingEdited">Product that has been edited</param>
    /// <param name="originalRegimen">Original regimen values</param>
    /// <param name="newRegimen">New regimen values</param>
    /// <param name="viewAndAdjustInfo">info</param>
    /// <returns>If there is any ask adjust info to display</returns>
    public bool AskAdjust(string msg, PNProductRow productBeingEdited, PNProcessor originalRegimen, PNProcessor newRegimen, PNViewAndAdjustInfo viewAndAdjustInfo)
    {
        lbMessage.Text = msg.Replace("\n", "<br />");        

        PNProduct    products   = PNProduct.GetInstance();
        PNIngredient ingredient = PNIngredient.GetInstance();

        this.originalRegimen    = originalRegimen;
        this.newRegimen         = newRegimen;
        this.productBeingEdited = productBeingEdited;

        pnIngredientsToAdjust.Visible = true;   // If this is not visible can't set children as visible
        adjustSodium.Visible          = false;
        adjustPotassium.Visible       = false;
        nonAdjustableIngredients.Items.Clear();

        // Determine if levels can be maintained
        if (newRegimen.AskAdjustNa && (productBeingEdited.PNCode != originalRegimen.NaClPNCode) && (newRegimen.RegimenItems.Count() > 1))
            AskForIngredient(ingredient.FindByDBName(PNIngDBNames.Sodium),    products.FindByPNCode(originalRegimen.NaClPNCode), "NaCl");
        if (newRegimen.AskAdjustK &&  (productBeingEdited.PNCode != originalRegimen.KClPNCode) && (newRegimen.RegimenItems.Count() > 1))
            AskForIngredient(ingredient.FindByDBName(PNIngDBNames.Potassium), products.FindByPNCode(originalRegimen.KClPNCode ), "KCl");

        // hide or display the panels if they have data
        pnIngredientsToAdjust.Visible      = AnyIngredientsToAdjust;
        pnNonAdjustableIngredients.Visible = (nonAdjustableIngredients.Items.Count > 0);

        //if (ingredientsToAdjust.Items.Count > 0)
        //    ingredientsToAdjust.Focus();

        // Update the general message based on number entered
        if (adjustPotassium.Visible && adjustSodium.Visible)
            lbGeneralMessage.InnerText = "The following have been altered:";
        else
            lbGeneralMessage.InnerText = "The following has been altered:";

        return AnyIngredientsToAdjust || (nonAdjustableIngredients.Items.Count > 0);
    }

    /// <summary>
    /// Performs the re-adjustment of regimen Na, and K back to their original value.
    /// </summary>
    /// <param name="originalRegimen">Original regimen values</param>
    /// <param name="newRegimen">New regimem values</param>
    /// <param name="viewAndAdjustInfo">info</param>
    public void PerformAdjust(PNProcessor originalRegimen, PNProcessor newRegimen, PNViewAndAdjustInfo viewAndAdjustInfo)
    {
        this.originalRegimen = originalRegimen;
        this.newRegimen      = newRegimen;

        if (AnyIngredientsToAdjust)
        {
            if (adjustPotassium.Visible && adjustPotassium.Checked)
                PerformAdjust(PNIngDBNames.Potassium);
            if (adjustSodium.Visible    && adjustSodium.Checked)
                PerformAdjust(PNIngDBNames.Sodium);
        }
    }

    private void PerformAdjust(string ingDBName)
    {
        PNProduct products = PNProduct.GetInstance();
        double originalIngTotal = originalRegimen.CalculateTotals(new string[]{ingDBName}).First();
        double newIngTotal      = newRegimen.CalculateTotals     (new string[]{ingDBName}).First();
        double ingValueOffset   = 0.0;

        // Get the product used to maintain the ingredient
        PNProductRow product = null;
        if (ingDBName == PNIngDBNames.Sodium)
            product = products.FindByPNCode(originalRegimen.NaClPNCode);
        else if (ingDBName == PNIngDBNames.Potassium)
            product = products.FindByPNCode(originalRegimen.KClPNCode);

        // Get the ingredient offset value need to maintain original total
        PNRegimenItem item = newRegimen.RegimenItems.FindByPNCode(product.PNCode);
        if (item == null)
            ingValueOffset = originalIngTotal - newIngTotal;
        else
        {
            double ingValueFromProduct = product.CalculateIngredientValue(ingDBName, item.VolumneInml);
            ingValueOffset = ingValueFromProduct - (newIngTotal - originalIngTotal);
        }
            
        // Calcuate products volume 
        double? volume = product.CalculateVolume(ingDBName, ingValueOffset);
        if (volume.HasValue)
            newRegimen.UpdateItem(product.PNCode, volume.Value);
    }

    /// <summary>
    /// This does NOT determine if the message box is displayed, 
    /// but instead returns if user can select the ingredient to adjust.
    /// </summary>
    public bool AnyIngredientsToAdjust { get { return adjustSodium.Visible || adjustPotassium.Visible; } }

    /// <summary>
    /// Determine if ingredient value can be maintained and either add it to list
    /// of possible ingredient to adjust or to the list of item that can't be maintained
    /// </summary>
    /// <param name="ing">Ingredint to check</param>
    /// <param name="productIngIsSuppliedBy">Product that is used to supply the ingredient</param>
    /// <param name="ingAdjustName">Product display name</param>
    private void AskForIngredient(PNIngredientRow ing, PNProductRow productIngIsSuppliedBy, string ingAdjustName)
    {
        double originalIngTotal = this.originalRegimen.CalculateTotals(new string[]{ing.DBName}).First();
        double newIngTotal      = this.newRegimen.CalculateTotals     (new string[]{ing.DBName}).First();

        double IngDifference = newIngTotal - originalIngTotal;

        if (!IngDifference.IsZero(2) && originalIngTotal > 0.0)
        {
            PNRegimenItem itemIngIsSuppliedBy = originalRegimen.RegimenItems.FindByPNCode(productIngIsSuppliedBy.PNCode);
            double ingTotalByProduct = 0.0;

            if (itemIngIsSuppliedBy != null)
                ingTotalByProduct = productIngIsSuppliedBy.CalculateIngredientValue(ing.DBName, itemIngIsSuppliedBy.VolumneInml);

            // If there is enough of the product then allow user the option to maintain ingredient level
            // else add to list of item's that can't be maintainted 
            if ((ingTotalByProduct - IngDifference) >= 0.0)
            {
                CheckBox cb = (ing.DBName == PNIngDBNames.Sodium) ? adjustSodium : adjustPotassium;
                cb.Visible = true;
                cb.Text    = string.Format("Return {0} to previous level of {1} {2} by amending {3}", ing.Description.ToUpperFirstLetter(), originalIngTotal.ToPNString(), ing.GetUnit().Abbreviation, ingAdjustName);
                cb.Checked = true;
            }
            else
            {
                string msg = string.Format("{0} adjusted from {1} {2} not enough {3} present", ing.Description.ToUpperFirstLetter(), originalIngTotal.ToPNString(), ing.GetUnit().Abbreviation, ingAdjustName);
                nonAdjustableIngredients.Items.Add(msg);
            }
        }
    }

    #region IPNWizardCtrl Members
    public void Initalise()
    {
        adjustSodium.Visible    = false;
        adjustPotassium.Visible = false;
        nonAdjustableIngredients.Items.Clear();
    }

    public int? RequiredHeight { get { return null; } }

    public void Focus() { }

    public bool Validate(PNProcessor regimenProcess, PNViewAndAdjustInfo info) { return true; }
    #endregion
}
