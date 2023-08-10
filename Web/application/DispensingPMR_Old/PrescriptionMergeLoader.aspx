<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PrescriptionMergeLoader.aspx.cs" Inherits="application_DispensingPMR_PrescriptionMergeLoader" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="Ascribe.Common" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<body>
<table id="tblLoader" width="100%" RequestID_WPrescriptionMerge=<%= requestID_WPrescriptionMerge %> RequestID_Dispensing="<%= requestID_Dispensing %>"  RepeatDispensing=<%= RepeatDispensing %> >
<%   
    Page page = this.Page;
    DispensingPMR_old.RenderPrescriptions(ref page, sessionID, xmldoc, 1, ifPSO); 
%>
</table>

<script>
	window.parent.PrescriptionMergesLoaded(<%= requestID_WPrescriptionMerge %>, <%= requestID_Dispensing %>);
</script>

</body>
</html>
