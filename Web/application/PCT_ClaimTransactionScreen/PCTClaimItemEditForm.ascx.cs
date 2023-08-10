using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

public partial class application_PCT_ClaimTransactionScreen_PCTClaimItemEditForm : System.Web.UI.UserControl
{
    /// <summary>
    /// List of data indexes for the controls that should be disabled 
    /// 21Aug15 XN 126577
    /// </summary>
    /// <param name="dataIndexes">data indexes for the controls that should be disabled </param>
    public void DisableControls(IEnumerable<int> dataIndexes)
    {
        foreach(int dataIndex in dataIndexes)
        {
            switch (dataIndex)
            {
            case  1: SetTextBoxReadOnly(this.rtxtCategory); break;
            case  2: SetTextBoxReadOnly(this.rtxtPatientCategory); break;
            case  3: SetTextBoxReadOnly(this.rdatService); break;
            case  4: SetTextBoxReadOnly(this.tntbComponentNumber); break;
            case  5: SetTextBoxReadOnly(this.rtxtCSCorPHO); break;
            case  6: SetTextBoxReadOnly(this.rntbClaimCode); break;
            case  7: SetTextBoxReadOnly(this.tntbTotalComponent); break;
            case  8: SetTextBoxReadOnly(this.chkHUHC); break;
            case  9: SetTextBoxReadOnly(this.rntbQuantityClaimed); break;
            case 10: SetTextBoxReadOnly(this.rtxtPrescriberID); break;
            case 11: SetTextBoxReadOnly(this.rtxtSpecialAuth); break;
            case 12: SetTextBoxReadOnly(this.rtxtPUoM); break;
            case 13: SetTextBoxReadOnly(this.rtxtHPGC); break;
            case 14: SetTextBoxReadOnly(this.rntbDose); break;
            case 15: SetTextBoxReadOnly(this.rntbClaimAmount); break;
            case 16: SetTextBoxReadOnly(this.ttxtSpecialistID); break;
            case 17: SetTextBoxReadOnly(this.rntbDailyDose); break;
            case 18: SetTextBoxReadOnly(this.rntbCBSSubsidy); break;
            case 19: SetTextBoxReadOnly(this.rdatEndorsement); break;
            case 20: SetTextBoxReadOnly(this.chkPrescriptionFlag); break;
            case 21: SetTextBoxReadOnly(this.rntbCBSPacksize); break;
            case 22: SetTextBoxReadOnly(this.rtxtFlag); break;
            case 23: SetTextBoxReadOnly(this.chkDoseFlag); break;
            case 24: SetTextBoxReadOnly(this.rtxtFunder); break;
            case 25: SetTextBoxReadOnly(this.rtxtOncologyPatientGroup); break;
            case 26: SetTextBoxReadOnly(this.rtxtPrescriptionID); break;
            case 27: SetTextBoxReadOnly(this.rtxtFormNumber); break;
            case 28: SetTextBoxReadOnly(this.rtxtNHINumber); break;
            case 29: SetTextBoxReadOnly(this.rtxtPrescriptionSuffix); break;
            }
        }
    }

    /// <summary>
    /// Disabled the control. 
    /// TextBox is set read only, other items are disabled
    /// 21Aug15 XN 126577
    /// </summary>
    /// <param name="control">Control to disable</param>
    private void SetTextBoxReadOnly(WebControl control)
    {
        if (control is RadInputControl)
        {
            (control as RadInputControl).ReadOnly = true;
            (control as RadInputControl).ReadOnlyStyle.BorderStyle = BorderStyle.None;
            (control as RadInputControl).Attributes.Add("onfocus", "this.blur();");
        }
        else if (control is CheckBox)
        {
            control.Enabled = false;
        }
        else if (control is RadDatePicker)
        {
            control.Enabled = false;
        }
    }
}
