using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.parenteralnutritionlayer;

public partial class application_PNViewAndAdjust_controls_PNAddMethod : System.Web.UI.UserControl, IPNWizardCtrl
{
    protected void Page_Load(object sender, EventArgs e) { }

    public PNUtils.PNWizardType GetWizardType()
    {
        if (rbAddBymlProduct.Checked)
            return PNUtils.PNWizardType.bymlProduct;
        else if (rbAddByProduct.Checked)
            return PNUtils.PNWizardType.byProduct;
        else if (rbAddByIngredient.Checked)
            return PNUtils.PNWizardType.byIngredient;

        throw new ApplicationException("No Add method selected");
    }

    public void SetWizardType(PNUtils.PNWizardType wizardType)
    {
        rbAddBymlProduct.Checked  = (wizardType == PNUtils.PNWizardType.bymlProduct );
        rbAddByProduct.Checked    = (wizardType == PNUtils.PNWizardType.byProduct   );
        rbAddByIngredient.Checked = (wizardType == PNUtils.PNWizardType.byIngredient);
        
        // Set checked item as having focus
    }

    #region IPNWizardCtrl Members
    public void Initalise() 
    { 
        if (!this.Controls.OfType<RadioButton>().Any(r => r.Checked))
            rbAddBymlProduct.Checked = true;

        // Set checked item as having focus
        this.Controls.OfType<RadioButton>().First(r => r.Checked).Focus();
    }

    public int? RequiredHeight { get { return null; } }

    public void Focus()
    {
        if (this.Controls.OfType<RadioButton>().Any(r => r.Checked))
        {
            string ID = this.Controls.OfType<RadioButton>().First(r => r.Checked).ClientID;
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "PNAddMethodFocus", "$('#" + ID + "').focus();", true);
        }
    }

    public bool Validate(PNProcessor regimenProcess, PNViewAndAdjustInfo info) { return true; }
    #endregion 
}
