<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<!--#include file="../SharedScripts/ASPHeader.aspx"-->
<%

'									RepeatDispensingModal.aspx
'
'	Wrapper for RepeatDispensingModal.asp
'
'	15Nove05 ST Created

	dim lngSessionID as long
	lngSessionID = Request.QueryString("SessionID")

	dim lngEpisodeID as long
	lngEpisodeID = generic.clngx(Request.QueryString("EpisodeID"))
	
	dim strMode as string
	strMode = Request.QueryString("Mode")

	dim strWindowStyle as string
 	strWindowStyle = Request.QueryString("WindowStyle")
 	
 	dim lngEntityID as long
 	lngEntityID = generic.clngx(Request.QueryString("EntityID"))
 	
 	dim lngSiteID as long
 	lngSiteID = Request.QueryString("SiteID")
	

%>

<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=lngSessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "RepeatDispensingModal.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>


<html>
<head>
<title>Repeat Dispensing</title>
</head>
<script language=javascript>
    window.dialogHeight = "500px";
    window.dialogWidth  = "725px";

</script>
<frameset rows=1 cols=1>
	<frame application=yes src="../RepeatDispensing/RepeatDispensing.aspx?SiteID=<%=lngSiteID%>&SessionID=<%=lngSessionID%>&EpisodeID=<%=lngEpisodeID%>&EntityID=<%=lngEntityID%>&Mode=<%=strMode%>&WindowStyle=<%=strWindowStyle%>">
	<frame id="ActivityTimeOut" application="yes" style="display: none;"/>
<frameset>
</html>