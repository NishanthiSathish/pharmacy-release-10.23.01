using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.parenteralnutritionlayer;

public partial class application_PNViewAndAdjust_controls_PNSelectAqueousOrLipid : System.Web.UI.UserControl, IPNWizardCtrl
{
    protected void Page_Load(object sender, EventArgs e) 
    { 
    }

    public void Initalise(PNProcessor regimenProcessor, PNViewAndAdjustInfo info)
    {
        rbAqueous.Enabled = regimenProcessor.RegimenItems.FindByAqueousOrLipid(PNProductType.Aqueous).Any();
        rbLipid.Enabled   = regimenProcessor.RegimenItems.FindByAqueousOrLipid(PNProductType.Lipid  ).Any();

        // Esnure only the first enabled items is checed
        this.Controls.OfType<RadioButton>().ToList().ForEach(r => r.Checked = false);
        RadioButton firstEnabled = this.Controls.OfType<RadioButton>().FirstOrDefault(r => r.Enabled);
        if (firstEnabled != null)
            firstEnabled.Checked = true;
    }

    public PNProductType GetSelection()
    {
        if (rbAqueous.Checked)
            return PNProductType.Aqueous;
        else if (rbLipid.Checked)
            return PNProductType.Lipid;
        else
            return PNProductType.Combined;
    }

    public void SetSelection(PNProductType type)
    {
        rbAqueous.Checked = (type == PNProductType.Aqueous);
        rbLipid.Checked   = (type == PNProductType.Lipid  );
    }

    #region IPNWizardCtrl Members
    public void Initalise() { }

    public int? RequiredHeight { get { return null; } }

    public void Focus()
    {
        if (this.Controls.OfType<RadioButton>().Any(r => r.Checked))
        {
            string ID = this.Controls.OfType<RadioButton>().First(r => r.Checked).ClientID;
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "PNSelectAqueousOrLipidFocus", "$('#" + ID + "').focus();", true);
        }
    }

    public bool Validate(PNProcessor regimenProcess, PNViewAndAdjustInfo info) { return true; }
    #endregion 
}
