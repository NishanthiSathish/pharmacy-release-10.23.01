<!--	
                                PharmacyProductSearchModal.aspx

	Wrapper for ICW_PharmacyProductSearch.aspx

	21Mar11 XN Created
-->
<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>

<%  
    Dim lngSessionID As Integer
    lngSessionID = CInt(Request.QueryString("SessionID"))
    %>

<html>
<head>
    <title>Pharmacy Product Search</title>

    <script type="text/javascript" src="scripts/ICW_PharmacyProductSearch.js"></script>

    <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=lngSessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "PharmacyProductSearchModal.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);

    </script>

    <script type="text/javascript">
        window.dialogHeight = "605px";
        window.dialogWidth  = "850px";    
    </script>        
</head>
<frameset rows="1" cols="1" onkeypress="body_onkeydown(event)">
    <frame application="yes" src="ICW_PharmacyProductSearch.aspx<%= Request.Url.Query %>&IsInModal=yes" />
    <frame id="ActivityTimeOut" application="yes" style="display: none;"/>
</frameset>
</html>
