using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Web.Script.Services;
using TRNRTL10;

public partial class application_sharedscripts_OrderEntryIntegration : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string GetAmendOrderEntryParameters(string SessionID, string NoteGUID)
    {
        var objTransport = new TRNRTL10.Transport();
        var sessionId = int.Parse(SessionID);

        string paramsXML = objTransport.CreateInputParameterXML("NoteGUID", Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, NoteGUID);
        var parameters = objTransport.ExecuteSelectSP(sessionId, "pGetOrderEntryXMLLaunchDataAmend", paramsXML);

        var noteid = parameters.Tables[0].Rows[0]["NoteID"].ToString();
        var description = parameters.Tables[0].Rows[0]["Description"].ToString();
        var detail = parameters.Tables[0].Rows[0]["Detail"].ToString();
        var tableid = parameters.Tables[0].Rows[0]["TableID"].ToString();
        var notetypeid = parameters.Tables[0].Rows[0]["NoteTypeID"].ToString();

        string JSON = "{";
        JSON += "\"noteid\":\"" + noteid + "\",";
        JSON += "\"description\":\"" + description + "\",";
        JSON += "\"detail\":\"" + detail + "\",";
        JSON += "\"tableid\":\"" + tableid + "\",";
        JSON += "\"ocstypeid\":\"" + notetypeid + "\"";
        JSON += "}";

        return JSON;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string GetNewOrderEntryParameters(string SessionID, string TemplateGUID)
    {
        var objTransport = new TRNRTL10.Transport();
        var sessionId = int.Parse(SessionID);

        string paramsXML = objTransport.CreateInputParameterXML("OrderTemplateGUID", Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, TemplateGUID);
        var parameters = objTransport.ExecuteSelectSP(sessionId, "pGetOrderEntryXMLLaunchDataNew", paramsXML);

        var ordertemplateid = parameters.Tables[0].Rows[0]["OrderTemplateID"].ToString();
        var tableid = parameters.Tables[0].Rows[0]["TableID"].ToString();
        var notetypeid = parameters.Tables[0].Rows[0]["NoteTypeID"].ToString();
        var description = parameters.Tables[0].Rows[0]["Description"].ToString();

        string JSON = "{";
        JSON += "\"ordertemplateid\":\"" + ordertemplateid + "\",";
        JSON += "\"tableid\":\"" + tableid + "\",";
        JSON += "\"ocstypeid\":\"" + notetypeid + "\",";
        JSON += "\"description\":\"" + description + "\"";
        JSON += "}";

        return JSON;
    }
}