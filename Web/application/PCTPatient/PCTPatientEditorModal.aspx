<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<!--#include file="../SharedScripts/ASPHeader.aspx"-->
<%

	dim lngSessionID as long
	lngSessionID = Request.QueryString("SessionID")

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
    var pageName = "PCTPatientEditorModal.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>
<html>
<head>
<title>PCT Patient Editor</title>
</head>
<script language=javascript>
    window.dialogHeight = "220px";
    window.dialogWidth  = "450px";

</script>
  

<frameset rows=1 cols=1>
	<frame application=yes src="PCTPatientEditor.aspx?SiteID=<%=lngSiteID%>&SessionID=<%=lngSessionID%>&EntityID=<%=lngEntityID%>">
<frame id="ActivityTimeOut" application="yes" style="display: none;"/>
<frameset>
<html>