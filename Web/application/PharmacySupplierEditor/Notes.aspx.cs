//===========================================================================
//
//					          Notes.aspx.cs
//
//  Displays the notes editor.
//
//  notes are saved to the WSupplier2ExtraData
//
//  The page expects the following URL parameters
//  SessionID   - ICW session ID
//  WSupplier2ID- row id to update (if does not exits will create one)
//  
//  Usage:
//  Notes.aspx?SessionID=123&WSupplier2ID=43
//
//	Modification History:
//	27Jun14 XN   43318 Created
//===========================================================================
using System;
using System.Linq;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_PharmacySupplierEditor_Notes : System.Web.UI.Page
{
    protected WSupplier2ExtraData extraData = new WSupplier2ExtraData();
    protected int supplier2ID;

    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSession(this.Request);

        supplier2ID = int.Parse(Request["WSupplier2ID"]);
        extraData.LoadByID(supplier2ID);

        if (!this.IsPostBack)
        {
            tbText.Text = extraData.Any() ? extraData.First().Notes : string.Empty;
            tbText.MaxLength = WSupplier2ExtraData.GetColumnInfo().NotesLength;
        }
    }

    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        if (extraData.Any() || !string.IsNullOrEmpty(tbText.Text))
        {
            var row = extraData.FirstOrDefault();
            if (row == null)
            {
                row              = extraData.Add();
                row.WSupplier2ID = supplier2ID;
            }
            row.Notes = tbText.Text;
            extraData.Save();
        }
        this.ClosePage();
    }
}