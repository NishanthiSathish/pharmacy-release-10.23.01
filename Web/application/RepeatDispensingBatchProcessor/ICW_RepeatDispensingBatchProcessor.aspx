<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_RepeatDispensingBatchProcessor.aspx.cs" Inherits="application_RepeatDispensing_RepeatDispensingBatches" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%-- 04Apr12 AJK 30997 Added new button "Process All", changed existing button labels --%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <!-- Don't change the title value, it is read in the associated Jscript file-->
    <title>Repeat Dispensing Batches</title>
<script language="javascript" src="../sharedscripts/ocs/OCSImages.js"></script>
<script language="javascript" src="../RepeatDispensing/scripts/RepeatDispensingBatches.js"></script>
<script language="javascript" src="../sharedscripts/icwfunctions.js"></script>
<script language="javascript" src="../sharedscripts/icw.js"></script>
<script language="javascript" src="../routine/script/RoutineSearch.js"></script>
<script type="text/javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>

<link href="../../style/application.css" rel="stylesheet" type="text/css" />
<link href="../../style/WorkListPaged.css" rel="stylesheet" type="text/css" />
<%
    //ICW.ICWParameter("Mode", "Batch status code to detrmine which batches to display", "N,L,I"); 
    //ICW.ICWParameter("Combined", "Combined display for new/labelled/issued batches", "No,Yes"); 
    //ICW.ICWParameter("ShowCombinedButton", "Shows the combined label and issue button if the desktop is combined", "No,Yes");
    //ICW.ICWParameter("SiteID", "The Site ID", ""); 
     %>
     
    <style type="text/css">html, body{height:100%}</style>  <!-- Ensure page is full height of screen -->
</head>

<script language="javascript">
</script>


<body id="body" onload="window_onload()">
<div id="xmlDIV">
<xml runat="server" id="xmlDataID"></xml>
</div>
    <form id="mainForm" runat="server">
        <table width=100% height="30px" cellpadding=0>
            <tr>
                <td align=left>
                    <asp:TextBox ID="txtRowID" runat="server" style="display:none" />
                    <asp:TextBox ID="txtMode" runat="server" style="display:none" />
                    <asp:TextBox ID="txtType" runat="server" style="display:none" />
                    <asp:TextBox ID="txtSiteID" runat=server style="display:none" />
                    <asp:TextBox ID="txtOCXURL" runat=server style="display:none" />
                    <asp:TextBox ID="txtXML" runat=server style="display:none" />
                    <asp:TextBox ID="txtSessionID" runat=server style="display:none" />
                    <asp:Button ID="btnBatches" runat="server" Text="Batches" CssClass=TabSelected onclick="btnBatches_Click" />
                    <asp:Button ID="btnPatients" runat="server" Text="Patients" CssClass=Tab onclick="btnPatients_Click" />
                </td>
                <td align=center>
                    <OBJECT 
			            id=objRepeatDispense 
			            style="left:0px;top:0px;width:0px;height:0px"
			            codebase="../../../ascicw/cab/HEdit.cab" 
			            component="RptDispCtl.ocx"
			            classid=CLSID:514E6CE1-9B4D-41E6-B922-B8D56063C5EC VIEWASTEXT>
			            <PARAM NAME="_ExtentX" VALUE="16113">
			            <PARAM NAME="_ExtentY" VALUE="11139">					
			            <SPAN STYLE="color:red">ActiveX control failed to load! -- Please check browser security settings.</SPAN>
		            </OBJECT>                
                </td>
                <td align=right>
                    <asp:Button ID="btnMedSchedule" runat="server" Text="Medicine Schedule " CssClass=ICWButton Enabled="false" 
                        onclick="btnMedSchedule_Click" Width="110px"  />
                    <asp:Button ID="btnRequirementsRpt" runat="server" Text="Requirements Report " CssClass=ICWButton Enabled="false" 
                        onclick="btnRequirementsRpt_Click" Width="130px"  />
                    <asp:Button ID="btnProcess" runat="server" Text="Process" CssClass=ICWButton Enabled="false" 
                        onclick="btnProcess_Click" Width="110px"  />
                    <asp:Button ID="btnProcessAll" runat="server" Text="Label and Issue" CssClass=ICWButton Enabled="false" 
                        Width="110px" onclick="btnProcessAll_Click" Visible="false"  />
                    <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass=ICWButton Enabled="false" 
                        onclick="btnDelete_Click" />
                    <asp:Button ID="btnSettings" runat="server" Text="Settings" CssClass=ICWButton onclick="btnSettings_Click" Enabled="false" 
                         />
                </td>            
            </tr>
        </table>
        <div id="tbl-container" style="height:expression(document.frames.frameElement.clientHeight - document.getElementById(&quot;tbl-container&quot;).offsetTop); width:100%; overflow:scroll;">
            <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />
            <asp:Repeater ID="rpt_Default" runat=server />
        </div>        
    </form>
    


</body>
</html>
