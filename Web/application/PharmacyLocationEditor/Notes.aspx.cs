//===========================================================================
//
//					          Notes.aspx.cs
//
//  Displays the notes editor.
//
//  notes are saved to the WCustomerExtraData
//
//  The page expects the following URL parameters
//  SessionID   - ICW session ID
//  WCustomerID - row id to update (if does not exits will create one)
//  
//  Usage:
//  Notes.aspx?SessionID=123&WCustomerID=43
//
//	Modification History:
//	27Jun14 XN   43318 Created
//===========================================================================
using System;
using System.Linq;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_PharmacyWardEditor_Notes : System.Web.UI.Page
{
    protected WCustomerExtraData extraData = new WCustomerExtraData();
    protected int customerID;

    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSession(this.Request);

        customerID = int.Parse(Request["WCustomerID"]);
        extraData.LoadByID(customerID);

        if (!this.IsPostBack)
        {
            tbText.Text = extraData.Any() ? extraData.First().Notes : string.Empty;
            tbText.MaxLength = WCustomerExtraData.GetColumnInfo().NotesLength;
        }
    }

    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        if (extraData.Any() || !string.IsNullOrEmpty(tbText.Text))
        {
            var row = extraData.FirstOrDefault();
            if (row == null)
            {
                row             = extraData.Add();
                row.WCustomerID = customerID;
            }
            row.Notes = tbText.Text;
            extraData.Save();
        }
        this.ClosePage();
    }
}