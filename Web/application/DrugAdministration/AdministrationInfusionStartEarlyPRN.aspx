<%@ Page Language="VB" %>
<%@ Import Namespace="Ascribe.Common" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%
    Dim url As String
    Dim sessionId As Integer

    sessionId = CInt(Request.QueryString("SessionID"))
    Generic.RetrieveAndStore(sessionId, CStr(DA_ARBTEXTID_EARLY))
    
    url = "AdministrationDateEntry.aspx" & "?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate") & _
          "&DateEntryPrompt=Please indicate the time at which the infusion was STARTED. (Press to change)" & "&InfusionAction=Started"

    Response.Redirect(url)
%>