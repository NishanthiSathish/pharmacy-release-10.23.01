//===========================================================================
//
//						  FMGrniEditor.aspx.cs
//
//  Editor for GRNI sheet settings.
//  Currently just opening balance
//
//  Call the page with the follow parameters
//  SessionID   - ICW session ID
//
//	Modification History:
//	22Jan14 XN  Written 27252
//===========================================================================
using System;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.shared;

public partial class application_FinanceManagerSettings_FMGrniEditor : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSession(this.Request);

        if (!this.IsPostBack)
        {
            dtOpeningBalanceDate.Value = WFMSettings.GrniSheet.OpeningBalanceDate;
            tbOpeningBalance.Value     = (WFMSettings.GrniSheet.OpeningBalance / 100);
        }
    }

    protected void btnSave_OnClick(object sender, EventArgs e)
    {
        if (Validate())
        {
            WFMSettings.GrniSheet.OpeningBalanceDate = dtOpeningBalanceDate.Value.Value.Date;
            WFMSettings.GrniSheet.OpeningBalance     = tbOpeningBalance.Value.Value * 100.0;;
        }
    }

    /// <summary>Validates the from</summary>
    /// <returns>If all data is valid</returns>
    protected bool Validate()
    {
        bool ok = true;
        string error;

        // Date
        if (!Validation.ValidateDateTime(dtOpeningBalanceDate, "Date", true, DateTimeExtensions.MinDBValue, DateTime.Now, out error))
            ok = false;
        dtOpeningBalanceDateError.Text = string.IsNullOrEmpty(error) ? "&nbsp;" : error;

        // Value
        if (!Validation.ValidateText(tbOpeningBalance, "Value", typeof(double), true, out error))
            ok = false;
        tbOpeningBalance.ErrorMessage = error;

        return ok;
    }
}