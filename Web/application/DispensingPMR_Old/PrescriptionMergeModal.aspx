<!--	
                                PrescriptionMergeModal.aspx

	Wrapper for PrescriptionMergeModal.aspx

	17Jun11 XN Created
-->
<%@ Page language="vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

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
<frameset>
<html>