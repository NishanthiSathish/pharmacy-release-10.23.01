<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<!--#include file="../../application/SharedScripts/ASPHeader.aspx"-->

<%
    Dim lngSessionID As String
%>
<%
    'PBSFastRepeatSearchModal.aspx
    '
    'Wrapper for PatientEpisodeEditor.aspx
    '
    '15Nove05 ST Created
    lngSessionID = Request.QueryString("SessionID")
%>
<script src="../../application/sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=lngSessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../../application/sharedscripts/ActivityTimeOut.aspx";
    var pageName = "PBSFastRepeatSearchModal.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>

<html>
<head>
<title>PBS Patient Editor</title>
</head>
<frameset rows=1 cols=1>
	<frame application=yes src="../PBSEntityPanel/PBSFastRepeatSearch.aspx?SessionID=<%= lngSessionID %>">
        <frame id="ActivityTimeOut" application="yes" style="display: none;"/>
<frameset>
</html>
