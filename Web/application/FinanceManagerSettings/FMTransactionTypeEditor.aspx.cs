//===========================================================================
//
//						FMTransactionTypeEditor.aspx.cs
//
//  Allows user to edit an finance manager transaction types.
//
//  Call the page with the follow parameters
//  SessionID   - ICW session ID
//  Mode        - 'edit'
//  RecordID    - Id of record if in edit mode
//
//  Usage:
//  To edit
//  FMTransactionTypeEditor.aspx?SessionID=123&Mode=edit&RecordID=4
//
//	Modification History:
//	23Apr13 XN  Written 53147
//  07Jan14 XN  HTML Escape data returned from page 81147
//===========================================================================
using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.shared;

public partial class application_FinanceManagerSettings_FMTransactionTypeEditor : System.Web.UI.Page
{
    protected int sessionID;
    protected int recordID;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Get SessionID
        sessionID  = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        // Get record ID only ever adding
        int.TryParse(Request["RecordID"], out recordID);

        // Init the form (called independent of postback as lot of ICW controls do not maintain view state)
        Initialise();

        if (!Page.IsPostBack)
        {
            // Setup for depending on mode
            if (Request.QueryString["Mode"].EqualsNoCaseTrimEnd("add"))
                throw new ApplicationException("Add mode is not supported");
            else
                Edit(recordID);
        }
    }

    /// <summary>
    /// Called when okay button is clicked, 
    /// 1. validates
    /// 2. saves
    /// 3. closes form
    /// </summary>
    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        // Validate
        string error;
        if (!Validation.ValidateText(tbDescription, "Description", typeof(string), true, out error))
        {
            tbDescription.ErrorMessage = error;
            return;
        }

        // Save
        WFMTransactionType transactionType = new WFMTransactionType();
        transactionType.LoadByID(recordID);
        transactionType[0].Description = tbDescription.Value.XMLUnescape();
        transactionType.Save();

        // Close form
        ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseForm", string.Format("window.returnValue={0}; window.close();", recordID), true);
    }

    /// <summary>Initialise the control</summary>
    private void Initialise()
    {
        WFMTransactionTypeColumnInfo baseColumnInfo = WFMTransactionType.GetColumnInfo();

        // Log type 
        tbPharmacyLog.MaxCharacters = 10;
        tbPharmacyLog.Controls.OfType<TextBox>().First().Attributes.Add("readonly", "readonly");
        tbPharmacyLog.Controls.OfType<TextBox>().First().BorderStyle = BorderStyle.None;

        // Kind
        tbKind.MaxCharacters = baseColumnInfo.KindLength;
        tbKind.Controls.OfType<TextBox>().First().Attributes.Add("readonly", "readonly");
        tbKind.Controls.OfType<TextBox>().First().BorderStyle = BorderStyle.None;

        // Description
        tbDescription.MaxCharacters = baseColumnInfo.DescriptionLength;

        // set client side onclick
        btnCancel.Attributes.Add("onclick", "window.close(); return false;");
    }

    /// <summary>Populate form data</summary>
    /// <param name="recordID">record to edit</param>
    private void Edit(int recordID)
    {
        WFMTransactionType transactionType = new WFMTransactionType();
        transactionType.LoadByID(recordID);

        tbPharmacyLog.Value = transactionType[0].PharmacyLog.ToString();
        tbKind.Value        = transactionType[0].Kind;
        tbDescription.Value = transactionType[0].Description;
    }
}
