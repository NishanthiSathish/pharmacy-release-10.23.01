<%@ Page language="vb" %>
<!--#include file="ASPHeader.aspx"-->
<html>
<head>
<title>Grid Tester</title>
<script src="../sharedscripts/Grid.js"></script>
<link rel="stylesheet" type="text/css" href="../../style/application.css">
<link rel="stylesheet" type="text/css" href="../../style/controls.css">
<script language=javascript>
<!--

function window_onload()
{
	CTL_Grid_Draw("grdPolicy");
}

//-->
</script>

</head>

<body id="body" LANGUAGE=javascript onload="return window_onload()" scroll=no>

<table width=100% height=100% cellspacing=10 >
<tr>
<td>


<%
    strTextBox_XML = Ascribe.Common.Grid.CTL_Grid_TextBox(50, "")
    strDropDown_XML = Ascribe.Common.Grid.CTL_Grid_DropDown_Option_XML("A", "Allow") & Ascribe.Common.Grid.CTL_Grid_DropDown_Option_XML("D", "Deny this role") & Ascribe.Common.Grid.CTL_Grid_DropDown_Option_XML("L", "Deny ALL roles")
    strColumns_XML = Ascribe.Common.Grid.CTL_Grid_AddColumn("colID", "ID", 0, False, "", "") & Ascribe.Common.Grid.CTL_Grid_AddColumn("colAssigned", "Assigned", 0, True, "CheckBox", "") & Ascribe.Common.Grid.CTL_Grid_AddColumn("colPolicy", "Policy", 0, True, "TextBox", strTextBox_XML) & Ascribe.Common.Grid.CTL_Grid_AddColumn("colPermission", "Permission", 0, True, "DropDown", strDropDown_XML)
    Ascribe.Common.Grid.CTL_Grid("grdPolicy", strColumns_XML, TempPolicyData(), "100%", "100%", "Policies", True, "../images/security/Policy16.gif")
%>


</td>
</tr>
</table>

</body>
</html>
<script language="vb" runat="server">

    Dim strTextBox_XML As String
    Dim strDropDown_XML As String 
    Dim strColumns_XML As String 
    Function TempPolicyData() As String
        Dim strHTML As String = String.Empty
        strHTML = strHTML & "<Policies>"
        strHTML = strHTML & "	<Policy PolicyID=""0"" Checked=""0"" Detail=""Pharmacy""   Value=""A"" />"
        strHTML = strHTML & "	<Policy PolicyID=""1"" Checked=""1"" Detail=""Access""     Value=""D"" />"
        strHTML = strHTML & "	<Policy PolicyID=""2"" Checked=""0"" Detail=""Prescribe""  Value=""A"" />"
        strHTML = strHTML & "	<Policy PolicyID=""3"" Checked=""1"" Detail=""Update PMR"" Value=""A"" />"
        strHTML = strHTML & "	<Policy PolicyID=""4"" Checked=""0"" Detail=""Prescribe by non-licenced route"" Value=""L"" />"
        strHTML = strHTML & "</Policies>"
        TempPolicyData = strHTML
    End Function

</script>