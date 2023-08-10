<%@ Page language="vb" %>
<html>
<head>
<title>Administer Immediate Doses</title>

<%
    Dim sessionId As Integer = CInt(Request.QueryString("SessionID"))
%>

<script type="text/javascript">
	//16Jan13   Rams    30541 -When you click on "X" on the patient administration stat doses rest of the Immediate administration messages are not displayed

	window.onbeforeunload = (function ()
	{
		if (!window.frames("fraImmediateAdmin").CloseFromFrame())
		{
			event.returnValue = "If you continue this will leave the dose awaiting administration";
		}
	});

	window.onunload = (function ()
	{
		strURL = "ImmediateAdmin.aspx?SessionID=<%= sessionId %>&Phase=closeNoAdmin";
		var objHttpRequest = new ActiveXObject("Microsoft.XMLHTTP");
		objHttpRequest.open("POST", strURL, false);
		objHttpRequest.send();
	});
</script>
	<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=sessionId %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "ImmediateAdmin_Modal.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>


<%
'---------------------------------------------------------------------------------------------------------
'
'ImmediateAdmin_Modal.aspx
'
'Querystring Params:
'
'SessionID:				(mandatory)
'
'Modification History:
'
'---------------------------------------------------------------------------------------------------------
%>

<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/OrderEntry.css">
</head>
<frameset>
	<frame id="fraImmediateAdmin" src="ImmediateAdmin.aspx?<%= Ascribe.Common.Context.QueryString %>" />
	<frame id="ActivityTimeOut" application="yes" style="display: none;"/>
</frameset>
</html>
