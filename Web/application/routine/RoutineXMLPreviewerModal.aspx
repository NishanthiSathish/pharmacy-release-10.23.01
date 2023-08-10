<%@ Page language="vb" %>
<% 
 Response.Buffer = true 
 Response.Expires = -1 
 Response.CacheControl = "No-cache" 
 %>
<%
    Dim sessionId As Integer = CInt(Request.QueryString("SessionID"))
%>
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=sessionId %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "RoutineXMLPreviewerModal.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>

<html>
<head>
<title>XML Result</title>
</head>

<frameset rows="95%,*">
	<frame src="RoutineXMLPreviewData.aspx">
	<frame src="../SharedScripts/CloseWindow.aspx" noresize scrolling="no" frameborder="0">
	<frame id="ActivityTimeOut" application="yes" style="display: none;"/>
</frameset>

</html>
