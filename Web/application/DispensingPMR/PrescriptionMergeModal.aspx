<!--	
                                PrescriptionMergeModal.aspx

	Wrapper for PrescriptionMergeModal.aspx

	17Jun11 XN Created
-->
<%@ Page language="vb" %>
<%
    Dim sessionId As Integer = CInt(Request.QueryString("SessionID"))
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=sessionId %>';
    //alert('sessionId ' + sessionId);    
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "PrescriptionMergeModal.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>

<html>
<head>
    <title>Prescription Linking</title>

    <script type="text/javascript" src="script/PrescriptionMerge.js"></script>
</head>
<script language=javascript>
    window.dialogHeight = "650px";
    window.dialogWidth  = "900px";
</script>
<frameset rows="1" cols="1"  onkeydown="form_onkeydown(event)">
	<frame application="yes" src="PrescriptionMerge.aspx<%= Request.Url.Query %>&IsInModal=yes">
    <frame id="ActivityTimeOut"  application="yes" allowtransparency="true"  style="display: none;"> </frame>
<frameset>
<html>