<%@ Page language="vb" %>
<% 
 Response.Buffer = true 
 Response.Expires = -1 
 Response.CacheControl = "No-cache" 
 %>
<%
    Dim sessionId As Integer = CInt(Request.QueryString("SessionID"))
%>

<html>
<%
    Dim strTitle As String 
%>
<%
    strTitle = Request.QueryString("Action") & " Item(s)"
%>
<head>
<%
    '---------------------------------------------------------------------------------------------------------
    '
    'StopAndAmendModal.aspx
    '
    'Querystring Params:
    '
    '
    'Modification History:
    '
    '---------------------------------------------------------------------------------------------------------
%>
<title><%= strTitle %></title>
<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/TemplateEditor.css" />
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=sessionId %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "StopAndAmendModal.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>

</head>
<frameset>
	<frame src="StopAndAmend.aspx?<%= Ascribe.Common.Context.QueryString %>" />
    <frame id="ActivityTimeOut" application="yes" style="display: none;"/>s
</frameset>
</html>
