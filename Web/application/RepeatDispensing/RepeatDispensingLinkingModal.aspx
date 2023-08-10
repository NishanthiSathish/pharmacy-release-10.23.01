<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<!--#include file="../SharedScripts/ASPHeader.aspx"-->
<%

'									RepeatDispensingLinkingModal.aspx
'
'	Wrapper for RepeatDispensingLinkingModal.asp
'
'	15Nove05 ST Created

	dim lngSessionID as long
	lngSessionID = Request.QueryString("SessionID")

	dim lngDispensingID as long
	lngDispensingID = generic.clngx(Request.QueryString("DispensingID"))
	

%>
<html>
<head>
<title>Repeat Dispensing Linking</title>
	<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=lngSessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "RepeatDispensingLinkingModal.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>

</head>
<script language=javascript>
    window.dialogHeight = "350px";
    window.dialogWidth  = "540px";
</script>
<frameset rows=1 cols=1>
	<frame application="yes" src="RepeatDispensingLinking.aspx?SessionID=<%=lngSessionID%>&DispensingID=<%=lngDispensingID%>">
<frame id="ActivityTimeOut" application="yes" style="display: none;"/>
<frameset>
</html>