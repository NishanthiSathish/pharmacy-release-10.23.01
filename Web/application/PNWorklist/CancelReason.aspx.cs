using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.icwdatalayer;
using Telerik.Web.UI;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.parenteralnutritionlayer;
using System.Text;

public partial class application_PNWorklist_CancelReason : System.Web.UI.Page
{
    int requestID;

    protected void Page_Load(object sender, EventArgs e)
    {
        int sessionID = int.Parse(Request.QueryString["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        requestID = int.Parse(Request.QueryString["RequestID"]);

        if (!this.IsPostBack)
        {
            LookupList reasonList = new LookupList();
            reasonList.LoadByDiscontinuationReason();
            ddlReasonForStopping.Items.Add(new RadComboBoxItem(string.Empty, string.Empty));
            foreach (LookupListRow item in reasonList.OrderBy(r => r.Descritpion))
                ddlReasonForStopping.Items.Add(new RadComboBoxItem(item.Descritpion, item.DBID.ToString()));

            Request request = new Request();
            request.LoadByRequestID(requestID);
            string requestType = ICWTypes.GetTypeByRequestTypeID(ICWType.Request, request[0].RequestTypeID).Value.Description;
            pageTitle.Text = "Stop " + requestType;

            ddlReasonForStopping.Focus();   // TFS31082  2Apr12  XN reason drop down should have focus by default
        }
    }

    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        if (this.Validate())
        {
            Request request = new Request();
            request.LoadByRequestID(requestID);

            if (request.Any())
            {
                request[0].Cancel(int.Parse(ddlReasonForStopping.SelectedValue), tbComments.Text, true);

                string requestType = ICWTypes.GetTypeByRequestTypeID(ICWType.Request, request[0].RequestTypeID).Value.Description;
                PNLog.WriteToLog(null, null, null, null, null, null, string.Format("Cancelled {0} {1}", requestType, request[0].RequestID), string.Empty);

                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Saved", "window.returnValue=" + requestID.ToString() + "; window.close();", true);
            }
        }
    }

    protected bool Validate()
    {
        bool ok = true;

        if (string.IsNullOrEmpty(ddlReasonForStopping.SelectedValue))
        {
            lbReasonForStoppingError.Text = "Please select reason for stopping item";
            ok = false;
        }

        return ok;
    }
}
