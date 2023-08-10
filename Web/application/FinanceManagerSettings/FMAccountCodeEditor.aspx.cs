//===========================================================================
//
//						  FMAccountCodeEditor.aspx.cs
//
//  Allows user to add or edit a finance manager account code.
//
//  Call the page with the follow parameters
//  SessionID   - ICW session ID
//  Mode        - 'add' or 'edit'
//  RecordID    - Id of record if in edit mode
//
//  Usage:
//  To add
//  FMAccountCodeEditor.aspx?SessionID=123&Mode=add
//
//  To edit
//  FMAccountCodeEditor.aspx?SessionID=123&Mode=edit&RecordID=4
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
using Ascribe.Core.Controls;

public partial class application_FinanceManagerSettings_FMAccountCodeEditor : System.Web.UI.Page
{
    protected int  sessionID;
    protected int  recordID;
    protected bool addMode;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Get SessionID
        sessionID  = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        // Get mode
        addMode = Request.QueryString["Mode"].EqualsNoCaseTrimEnd("add");
        if (!int.TryParse(Request["RecordID"], out recordID))
            recordID = -1;

        // Init the form (called independent of postback as lot of ICW controls do not maintain view state)
        Initialise();

        if (!Page.IsPostBack)
        {
            if (!addMode)
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
        if (Validate())
        {
            Save();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseForm", string.Format("window.returnValue={0}; window.close();", recordID), true);
        }
    }

    /// <summary>Initialise the control</summary>
    private void Initialise()
    {
        WFMAccountCodeColumnInfo baseColumnInfo = WFMAccountCode.GetColumnInfo();

        // Set first control with focus
        container.ControlToFocusId  = addMode ? tbCode.ID : tbDescription.ID;

        // Clear error messages
        this.Controls.OfType<Control>().Desendants(c => c.Controls.OfType<Control>()).OfType<ControlBase>().ToList().ForEach(c => c.ErrorMessage = string.Empty);

        // Setup code box (read-only in edit mode)
        tbCode.MaxCharacters = baseColumnInfo.CodeLength;
        if (!addMode)
        {
            tbCode.Controls.OfType<TextBox>().First().Attributes.Add("readonly", "readonly");
            tbCode.Controls.OfType<TextBox>().First().BorderStyle = BorderStyle.None;
        }

        // Setup description
        tbDescription.MaxCharacters = baseColumnInfo.DescriptionLength;

        // set client side onclick
        btnCancel.Attributes.Add("onclick", "window.close(); return false;");
    }

    /// <summary>Populate form data</summary>
    /// <param name="recordID">record to edit</param>
    private void Edit(int recordID)
    {
        WFMAccountCode accountCode = new WFMAccountCode();
        accountCode.LoadByID(recordID);

        tbCode.Value        = accountCode[0].Code.ToString();
        tbDescription.Value = accountCode[0].Description;
    }

    /// <summary>Validates form</summary>
    private bool Validate()
    {
        string error;
        bool ok = true;

        // Code
        if (addMode)
        {
            if (!Validation.ValidateText(tbCode, "Code", typeof(int), true, 100, 999, out error))
            {
                tbCode.ErrorMessage = error;
                ok = false;
            }
            if (ok && !WFMAccountCode.CheckCodeIsUnique(short.Parse(tbCode.Value)))
            {
                tbCode.ErrorMessage = "Code is not unique.";
                ok = false;
            }
        }

        // Description
        if (!Validation.ValidateText(tbDescription, "Description", typeof(string), true, out error))
        {
            tbDescription.ErrorMessage = error;
            ok = false;
        }

        return ok;
    }

    /// <summary>Save the data</summary>
    private void Save()
    {
        WFMAccountCode accountCode = new WFMAccountCode();
        if (addMode)
        {
            accountCode.Add();
            accountCode[0].Code = short.Parse(tbCode.Value);
        }
        else
            accountCode.LoadByID(recordID);

        accountCode[0].Description = tbDescription.Value.XMLUnescape();
        accountCode.Save();

        // Update record ID for add
        recordID = accountCode[0].WFMAccountCodeID;
    }
}
