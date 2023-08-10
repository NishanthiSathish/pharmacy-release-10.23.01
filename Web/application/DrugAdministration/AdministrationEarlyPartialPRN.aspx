<%@ Page Language="VB" %>
<%@ Import Namespace="Ascribe.Common" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%
    Dim url As String
    Dim sessionId As Integer
    Dim dssCheckResult As String
    
    sessionId = CInt(Request.QueryString("SessionID"))
    dssCheckResult = Request.QueryString("dssresult")
    Generic.RetrieveAndStore(sessionId, CStr(DA_ARBTEXTID_EARLY))
    
    url = "ArbtextPicker.aspx" & _
          "?SessionID=" & sessionId & _
          "&dssresult=" & dssCheckResult & _
          "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate") & _
          "&" + DA_DESTINATION_URL + "=AdministrationPartial.aspx" & _
          "&" + DA_REFERING_URL + "=AdministrationPrescriptionDetail.aspx" & _
          "&" + DA_ARBTEXTTYPE + "=" + ARBTEXTTYPE_PARTIAL_ADMIN_REASON & _
          "&" + DA_PROMPT + "=" + TXT_ENTER_PARTIAL_ADMIN_REASON

    Response.Redirect(url)
%>
