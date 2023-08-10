using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.parenteralnutritionlayer;

public partial class application_PNViewAndAdjust_controls_PNSelectIngredientWithQuantity : System.Web.UI.UserControl, IPNWizardCtrl
{
    protected void Page_Load(object sender, EventArgs e) { }

    /// <summary>Initalise list of ingredients</summary>
    /// <param name="ingredients">Ingredients to add to list</param>
    /// <param name="product">Product (for caption)</param>
    public void Initalise(IEnumerable<PNIngredientRow> ingredients, PNProductRow product, string defaultIngDBName, double volumeInml)
    {
        int defaultIngIndex = 0;

        lbCaption.Text = string.Format("Replace {0} while preserving which ingredient?", product);

        // Populate the grid
        gridSelectIngredient.AddColumn("Ingredient", 60, PharmacyGridControl.ColumnType.Text);
        gridSelectIngredient.AddColumn("Quantity",   30, PharmacyGridControl.ColumnType.Text);
        gridSelectIngredient.ColumnKeepWhiteSpace(1, true);
        gridSelectIngredient.SortableColumns = true;

        foreach (PNIngredientRow ing in ingredients)
        {
            // Build up quatity string
            string quantity = product.CalculateIngredientValue(ing.DBName, volumeInml).ToVDUString();
            if (string.IsNullOrEmpty(quantity))
                quantity = "      ";   // If no quantity add spaces for better positioning of unit abbreviation
            quantity += " " + ing.GetUnit().Abbreviation;

            gridSelectIngredient.AddRow();
            gridSelectIngredient.AddRowAttribute("DBName", ing.DBName);
            gridSelectIngredient.SetCell(0, ing.ToString());
            gridSelectIngredient.SetCell(1, quantity);

            if (ing.DBName == defaultIngDBName)
                defaultIngIndex = gridSelectIngredient.RowCount - 1;
        }

        // Select first row by default
        if (gridSelectIngredient.RowCount > 0)
        {
            string script = string.Format("selectRow('{0}', {1}); $('#{0}').focus();", gridSelectIngredient.ID, defaultIngIndex);
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "InitIngredientGrid", script, true);
        }
    }

    /// <summary>Returns the selected ingredient</summary>
    public PNIngredientRow GetSelectedIngredient()
    {
        return PNIngredient.GetInstance().FindByDBName(hfSelectedIngredientDBName.Value);
    }

    #region IPNWizardCtrl Members
    public void Initalise()
    {
        hfSelectedIngredientDBName.Value = string.Empty;
    }

    public int? RequiredHeight { get { return 450; } }

    public void Focus() { /* Done in init */ }

    public bool Validate(PNProcessor regimenProcess, PNViewAndAdjustInfo info) { return true; }
    #endregion
}
