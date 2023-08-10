<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Reconstitution and Dilution</title>
    <!-- F0049164 ST 06Apr09  Added function to resize dynamically sized iframe contents -->
    <script language="javascript">
        function resizeIframeToFitContent(iframe) {
            iframe.height = document.frames[iframe.id].document.body.scrollHeight;
        }
    </script>
</head>

<%
    '
    ' ReconstitutionDiluentModal.aspx
    '
    ' Wrapper for diluent information so that dialog is displayed as a modal dialog
    '
    ' Apr08 ST  Written
    ' Mar10 ST  Added handling and passing through of order template id
    Dim lngSessionID As Integer
    Dim lngRequestID As Integer
    Dim blnTemplateMode As Boolean
    Dim blnDisplayMode As Boolean
    Dim OrderTemplateID As Integer
    
    lngSessionID = CInt(Request.QueryString("SessionID"))
    lngRequestID = CInt(Request.QueryString("RequestID"))
    blnTemplateMode = Request.QueryString("TemplateMode")
    blnDisplayMode = Request.QueryString("DisplayMode")
    OrderTemplateID = CInt(Request.QueryString("OrderTemplateID"))
%>
<%  'F0082460 ST 31Mar10 Changed height handling again as modal dialog is now not resizable %>
    <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=lngSessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "ReconstitutionDiluentModal.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>


<body style="height:100%;">
    <!-- F0049164 ST  26Mar09   Added extra tags to div and iframe to force height and prevent multiple vertical scrollbars -->
    <div align="center">
        <iframe id="fraReconstitutionDiluent" style="height:100%;width:100%;" scrolling="yes" application="yes" frameborder="0" src="Diluents.aspx?SessionID=<%=lngSessionID %>&RequestID=<%=lngRequestID%>&TemplateMode=<%=blnTemplateMode %>&OrderTemplateID=<%=OrderTemplateID %>&DisplayMode=<%=blnDisplayMode %>"></iframe>
        <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
    </div>
</body>
</html>
