//===========================================================================
//
//					  	    PNSelectIngredient.aspx.cs
//
//  Control used in the PN add product wizard to allow selection of PN ingredient
//  Ingredients are display in list box in from 
//      <ingredient unit> of <ingredient>
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

public partial class application_PNViewAndAdjust_controls_PNSelectIngredient : System.Web.UI.UserControl, IPNWizardCtrl
{
    protected void Page_Load(object sender, EventArgs e) { }

    /// <summary>Initalise list of ingredients</summary>
    /// <param name="ingredients">Ingredients to add to list</param>
    /// <param name="productName">Product name (for caption)</param>
    /// <param name="includeVolume">If to include volume in list of ingredients also need to be in ingredients)</param>
    public void Initalise(IEnumerable<PNIngredientRow> ingredients, string productName, bool includeVolume)
    {
        // Set caption on control
        if (string.IsNullOrEmpty(productName))
            lbCaption.Text = "Select ingredient to adjust";
        else
            lbCaption.Text = "Enter " + productName + " by...";

        lbIngredients.Items.Clear();

        foreach (PNIngredientRow ing in ingredients)
        {
            if (includeVolume || (ing.DBName != PNIngDBNames.Volume))
                lbIngredients.Items.Add(new ListItem(ing.GetUnit().Abbreviation + " of " + ing.Description, ing.DBName));
        }

        lbIngredients.SelectedIndex = 0;
    }

    public PNIngredientRow GetSelectedIngredient()
    {
        return PNIngredient.GetInstance().FindByDBName(lbIngredients.SelectedValue);
    }

    public void SetIngredient(string dbName)
    {
        ListItem selectedItem = lbIngredients.Items.FindByValue(dbName); 
        lbIngredients.SelectedIndex = lbIngredients.Items.IndexOf(selectedItem);
        lbIngredients.SelectedValue = dbName;
    }

    #region IPNWizardCtrl Members
    public void Initalise()
    {
        lbIngredients.Items.Clear();
        lbCaption.Text = string.Empty;
    }

    public int? RequiredHeight { get { return 450; } }

    public void Focus()
    {
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "PNSelectIngredientFocus", string.Format("$('#{0}').focus();", lbIngredients.ClientID), true);
    }

    public bool Validate(PNProcessor regimenProcess, PNViewAndAdjustInfo info) { return true; }
    #endregion
}
