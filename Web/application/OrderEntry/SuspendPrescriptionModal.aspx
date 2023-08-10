<%@ Page language="vb" %>
<html>
<head>

<%
    'SUSPENDPRESCRIPTIONMODAL.aspx
    '
    'This page is used to define the details of the suspension
    '
    'The actual mechanics are held in SuspendPrescription.aspx; because of the
    'weird behaviour of submit() when used in a modal dialog (ie it forces open in
    'new window), we have to use this page as a wrapper.
    '
    'The page takes query string parameters as follows:
    '
    'SessionID 	(mandatory)						      :		The standard security token
    'XML List	(mandatory)	 						:      ID of Request/Response/PendingItem from which to display notes
    '
    'ReturnValue:				'cancel' if no changes were made, xml string containing parameters if anything
    'was modified.
    '
    '-----------------------------------------------------------------------
    'Modification History:
    '23Feb07 CJM  Written
    '14May12 ST   Tidied code and change frameset to iframe
    '05Feb13 Rams 30951 - Patient Locking - No locking occurs when suspending the same prescription at the same time
    '-----------------------------------------------------------------------
    
    Dim objSettingRead As GENRTL10.SettingRead
    Dim strReasonLookup As String
    Dim strReasonText As String
    Dim sessionId As Integer
    
    sessionId = CInt(Request.QueryString("SessionID"))
    
    ' F0073085 ST 27Apr10 Read settings for suspension reasons
    objSettingRead = New GENRTL10.SettingRead()
    strReasonLookup = objSettingRead.GetValue(sessionId, "OCS", "OrderEntry", "SuspensionReasonLookup", "Disabled")
    strReasonText = objSettingRead.GetValue(sessionId, "OCS", "OrderEntry", "SuspensionReasonText", "Disabled")
%>

<script type="text/javascript" language="javascript">
    window.returnValue = 'cancelled';
    
    var requestId;
    window.onunload = (function() {
        if (requestId > 0) {
            strURL = "SuspendPrescriptionSaver.aspx?SessionID=<%= SessionID %>&Mode=unlockrequest&RequestId=" + requestId;
            var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
            objHTTPRequest.open("POST", strURL, false);
            objHTTPRequest.send();
        }
    });
</script>
    <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=sessionId %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "SUSPENDPRESCRIPTIONMODAL.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>

<title>Manage Suspensions</title>
</head>

<body>
    <iframe id="fraOnly" src="SuspendPrescription.aspx?<%= Ascribe.Common.Context.QueryString %>&ReasonLookup=<%=strReasonLookup %>&ReasonText=<%=strReasonText %>" style="height:100%;width:1000px;border:none;" scrolling="no" application="yes"></iframe>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>

</html>
