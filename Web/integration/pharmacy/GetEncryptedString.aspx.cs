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
using secrtl_c;

// 28Jun12 AJK 36929 Created to replace GetConnectionString

public partial class integration_pharmacy_GetEncryptedString : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "text/plain";
        Response.Clear();
        int sessionId = 0;
        string token = string.Empty;

        if (Request["SessionID"] != null && Request["SessionID"] != string.Empty)
        {
            sessionId = int.Parse(Request["SessionID"]);
        }
        if (Request["Token"] != null && Request["Token"] != string.Empty)
        {
            token = Request["Token"];
        }
        if (token != string.Empty && sessionId > 0)
        {
            
            // Decide what data to respond with
            int ss = _Shared.udtConsts.SECURITY_SESSION_ID;
            GENRTL10.SettingRead settingReaad = new GENRTL10.SettingRead();
            if (settingReaad.GetValue(ss, "Pharmacy", "Database", "ConnectViaWebsite", "False") == "True")
            {
                try
                {
                    Response.Write(TokenGenerator.GetEncryptedSymmetricKey(token, sessionId));
                }
                catch (Exception ex)
                {
                    string test = string.Empty;
                    Response.Write(test);
                }
            }
            else
            {
                try
                {
                    Response.Write(TokenGenerator.GetEncryptedConnectionString(token, sessionId));
                }
                catch (Exception ex)
                {
                    string test = string.Empty;
                    Response.Write(test);
                }
            }
            
        }
    }
}
