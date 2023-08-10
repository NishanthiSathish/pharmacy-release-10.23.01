// -----------------------------------------------------------------------
// <copyright file="AMMReportError.aspx.cs" company="Emis Health">
//   Copyright (c) Emis Health Plc. All rights reserved.
// </copyright>
// <summary>
// Allows reporting a AMM error
//
// The page expects the following URL parameters
// SessionID           - ICW session ID
// RequestID           - AMM Supply Request ID
// 
//  Modification History:
//  02Jul15 XN Created 39882
// </summary
// -----------------------------------------------------------------------
using System;
using System.Web.UI.WebControls;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.manufacturinglayer;
using ascribe.pharmacy.shared;

public partial class application_aMMWorkflow_AMMReportError : System.Web.UI.Page
{
    /// <summary>AMM Supply request ID</summary>
    private int requestId;

    /// <summary>Page load</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The event</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSession(this.Request);
        
        // get parameters
        this.requestId = ConvertExtensions.ChangeType<int>(this.Request["RequestID"]);

        if (!this.IsPostBack)
        {            
            // Initialise the patient banner
            patientBanner.Initalise(EpisodeOrder.GetEpisodeIdByRequestId(this.requestId));

            // Populate the reason list
            LookupList lookup = new LookupList();
            lookup.LoadByAMMReportErrorReasons();

            lsReason.Items.Clear();
            foreach(var l in lookup)
            {
                lsReason.Items.Add(new ListItem(l.Descritpion, l.DBID.ToString()));
            }
        }
    }

    /// <summary>
    /// Called when the OK button is clicked
    /// Validate and saves the note against the request
    /// </summary>
    /// <param name="sender">The send</param>
    /// <param name="e">The e</param>
    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        bool ok = true;
        string error;

        // Validation
        ok &= Validation.ValidateList(this.lsReason, string.Empty, true, out error);
        lsReason.ErrorMessage = error;

        ok &= Validation.ValidateText(this.tbComments, string.Empty, typeof(string), false, AMMReportError.GetColumnInfo().CommentsLength, out error);
        tbComments.ErrorMessage = error;

        if (ok)
        {
            // Save 
            AMMReportError errorNote = new AMMReportError();
            errorNote.Add(int.Parse(lsReason.SelectedValue), tbComments.Value);

            errorNote.Save();
            Database.InsertLink("NoteLinkRequest", "RequestID", this.requestId, "NoteID", errorNote[0].NoteID);

            // Close the page
            this.ClosePage(errorNote[0].NoteID.ToString());
        }
    }
}