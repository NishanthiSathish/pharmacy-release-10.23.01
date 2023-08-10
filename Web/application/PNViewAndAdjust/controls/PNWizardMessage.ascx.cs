using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.parenteralnutritionlayer;

public partial class application_PNViewAndAdjust_controls_PNWizardMessage : System.Web.UI.UserControl, IPNWizardCtrl
{
    protected void Page_Load(object sender, EventArgs e) { }

    public string Message { set { lbMessage.Text = value; } }

    #region IPNWizardCtrl Members
    public void Initalise() { }

    public int? RequiredHeight { get { return null; } }

    public void Focus() { }

    public bool Validate(PNProcessor regimenProcess, PNViewAndAdjustInfo info) { return true; }
    #endregion
}
