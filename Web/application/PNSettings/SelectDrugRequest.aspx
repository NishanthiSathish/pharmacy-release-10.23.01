<!-- 
    Wrapper file for the DSS on Web SelectDrugRequest.aspx page required 
    as due to cross domain limitations it is not possible to get the return value when calling the actual SelectDrugRequest.aspx
    So the actual SelectDrugRequest.aspx will add the selected request id onto the hash url, and this page will pick it up, by
    continually polling CheckRequestSelected that checks if the embedded fram has the hash value set.
-->
<%@ Page language="C#" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<% SessionInfo.InitialiseSession(this.Request); %>
<% var sessionId = SessionInfo.SessionID; %>

<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=SessionInfo.SessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "SelectDrugRequest.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>

<html>
<head>
    <title>Select Drug Request</title>
</head>
<frameset rows="1" cols="1" onkeydown="form_onkeydown(event)" style="overflow-y:hidden">
    <frame id="fraSelectDrugRequest" application="yes" src="<%= SettingsController.Load("DSS", "DrugPublishing", "DSSWebSiteURL", string.Empty) %>/SelectRequest/SelectDrugRequest.aspx<%= Request.Url.Query %>" />
    <frame id="ActivityTimeOut" application="yes" style="display: none;"/>
</frameset>
</html>
