using System;
using System.Web.Services;
using System.Xml;
using Ascribe.Common;
using Ascribe.Xml;

public partial class application_DrugAdministration_ImmediateAdminHelper : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    [WebMethod]
    public static bool CheckImmediateAdmin(int sessionId)
    {
        string immediateItemsXml = Generic.SessionAttribute(sessionId, DrugAdministrationConstants.IA_ITEMS);
        if (immediateItemsXml.Contains("<items>"))
        {
            immediateItemsXml = "<ImmediateAdmin>" + new OCSRTL10.PrescriptionRead().GetImmediateAdminDetailsByPrescriptionXML(sessionId, immediateItemsXml) + "</ImmediateAdmin>";
            Generic.SessionAttributeSet(sessionId, DrugAdministrationConstants.IA_ITEMS, immediateItemsXml);
        }
        XmlDocument immediateDoc = new XmlDocument();
        immediateDoc.TryLoadXml(immediateItemsXml);
        bool immediateAdmin = (new GENRTL10.SettingRead().GetValue(sessionId, "OCS", "DrugAdministration", "SuppressImmediateAdminPrompt", "0") == "0");
        XmlNodeList allAdminRequests = immediateDoc.SelectNodes("//ImmediateAdmin/Prescription");
        XmlNodeList homelyRemedies = immediateDoc.SelectNodes("//ImmediateAdmin/Prescription[@CreationType='Homely Remedy']");
        return (allAdminRequests.Count > 0 && (immediateAdmin || homelyRemedies.Count > 0));
    }
}
