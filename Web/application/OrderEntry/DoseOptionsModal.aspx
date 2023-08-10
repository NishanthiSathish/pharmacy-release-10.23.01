<%@ Page Language="VB" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Dose Options</title>
</head>

<%
    Dim lngSessionID As Integer
    Dim strDoseUnit As String
    Dim strDose As String
    Dim strRoutine As String
    Dim RoundToNearest As Double
    Dim ToMaximumOf As Double
    Dim blnAllowOverride As Boolean
    Dim blnReevaluate As Boolean
    
    
    lngSessionID = CInt(Request.QueryString("SessionID"))
    strDose = CStr(Request.QueryString("Dose"))
    strRoutine = CStr(Request.QueryString("Routine"))
    strDoseUnit = CStr(Request.QueryString("DoseUnit"))
    
    RoundToNearest = CDblX(Request.QueryString("RoundToNearest"))
    ToMaximumOf = CDblX(Request.QueryString("ToMaximumOf"))
    
    blnAllowOverride = CBoolX(Request.QueryString("AllowOverride"))
    blnReevaluate = CBoolX(Request.QueryString("Reevaluate"))
    
%>
    <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=lngSessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "DoseOptionsModal.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>


<body>
    <div>
        <!-- F0049435 ST 27Mar09    Changed height of iframe so that it fills the entire dialog -->
        <iframe id="fraDoseOptions" height="450" style="width:100%; min-height:100%;" application="yes" frameborder="0" scrolling="no" src="DoseOptions.aspx?SessionID=<%=lngSessionID%>&DoseUnit=<%=strDoseUnit%>&Dose=<%=strDose%>&Routine=<%=strRoutine%>&RoundToNearest=<%=RoundToNearest%>&ToMaximumOf=<%=ToMaximumOf%>&AllowOverride=<%=blnAllowOverride%>&Reevaluate=<%=blnReevaluate%>"></iframe>
        <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
    </div>
</body>
</html>
