using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;

public partial class application_PNWorklist_Terms : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        int siteID;
        int sessionID;
        siteID = int.Parse(Request.QueryString["SiteID"]);
        sessionID = int.Parse(Request.QueryString["SessionID"]);
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);
        string cancelled = Request.QueryString["Cancelled"];
        if (cancelled == "true")
        {
            string cancelledMessage = (string)WConfiguration.Load<string>(siteID, "D|PN", "Accept", "CancelMessage", "You have decided not to accept the PN license agreement.", false);
            spnCancelled.InnerHtml = cancelledMessage.Replace("[cr]", "<BR/>");
            divAgree.Visible = false;
        }
        else if (!this.IsPostBack)
        {
            string message = (string)WConfiguration.Load<string>(siteID, "D|PN", "Accept", "Message", "WARNING[cr][cr]This program must only be used by suitably qualified personnel. The user must fully understand the use of this program before clinical usage, and must carefully review the package insert of all pharmaceutical products to assess their suitability for each patient.[cr][cr]The decision regarding which products to prescribe and in what quantity rests solely with the treating physician. The user accepts that no information from this program can be interpreted as a prescription or recommendation to prescribe.", false);
            if (!string.IsNullOrEmpty(message))
            {
                spnMessage.InnerHtml = message.Replace("[cr]", "<BR/>");
            }
            string message2 = (string)WConfiguration.Load<string>(siteID, "D|PN", "Accept", "Message2", "", false);
            if (!string.IsNullOrEmpty(message2))
            {
                spnMessage2.InnerHtml = message2.Replace("[cr]", "<BR/>");
            }
            string prompt = (string)WConfiguration.Load<string>(siteID, "D|PN", "Accept", "Prompt", "Confirm acceptance of the conditions of use by pressing the [Accept] button, otherwise press the [Cancel] button.", false);
            if (!string.IsNullOrEmpty(prompt))
            {
                spnPrompt.InnerHtml = prompt.Replace("[cr]", "<BR/>");
            }
            divCancelled.Visible = false;
        }
    }

    protected void HandleAccept(object sender, EventArgs e)
    {
        string key = "PN|Terms|Suppress|WindowID=" + Request["WindowID"];
        PharmacyDataCache.SaveToDBSession(key, "true");
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Close", "window.returnValue = 'accepted'; window.close()", true);
    }
}
