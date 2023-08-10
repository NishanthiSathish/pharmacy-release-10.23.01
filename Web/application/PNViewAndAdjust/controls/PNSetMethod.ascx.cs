//===========================================================================
//
//					  	        PNSetMethod.ascx.cs
//
//  First step in set volume and calories wizard.
//  Ask user to select volume, or calories
//
//  There is also a glucose options (that is never visiable)
//  to allow the set glucose to use the same wizard as the volume, and calories 
//
//	Modification History:
//	29Dec11 XN  Written
//===========================================================================
using System;
using System.Linq;
using System.Web.UI.WebControls;
using ascribe.pharmacy.parenteralnutritionlayer;
using System.Web.UI;

public partial class application_PNViewAndAdjust_controls_PNSetMethod : System.Web.UI.UserControl, IPNWizardCtrl
{
    protected void Page_Load(object sender, EventArgs e) { }

    public PNIngredientRow GetIngredientToSet()
    {
        if (rbSetByVolume.Checked)
            return PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Volume);
        else if (rbSetByCalories.Checked)
            return PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Calories);
        else if (rbSetByGlucose.Checked)
            return PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Glucose);

        throw new ApplicationException("No set method selected");
    }

    public void SetIngredientToSet(PNIngredientRow ingredient)
    {
        rbSetByVolume.Checked   = (ingredient.DBName == PNIngDBNames.Volume  );
        rbSetByCalories.Checked = (ingredient.DBName == PNIngDBNames.Calories);
        rbSetByGlucose.Checked  = (ingredient.DBName == PNIngDBNames.Glucose );
    }

    #region IPNWizardCtrl Members
    public void Initalise()
    {
        if (!this.Controls.OfType<RadioButton>().Any(r => r.Checked))
            rbSetByVolume.Checked = true;
    }

    public int? RequiredHeight { get { return null; } }

    public void Focus()
    {
        if (this.Controls.OfType<RadioButton>().Any(r => r.Checked))
        {
            string ID = this.Controls.OfType<RadioButton>().First(r => r.Checked).ClientID;
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "PNSetMethodFocus", "$('#" + ID + "').focus();", true);
        }
    }

    public bool Validate(PNProcessor regimenProcess, PNViewAndAdjustInfo info) { return true; }
    #endregion 
}
