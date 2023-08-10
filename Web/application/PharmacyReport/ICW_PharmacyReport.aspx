<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_PharmacyReport.aspx.cs" Inherits="application_PharmacyReport_ICW_PharmacyReport" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx" tagname="ProgressMessage" tagprefix="pc" %>
<%@ Register src="../pharmacysharedscripts/SiteColourPanelControl.ascx" tagname="SiteColourPanelControl" tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SiteNamePanelControl.ascx"   tagname="SiteNamePanelControl"   tagprefix="uc" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik"  %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx" tagname="ProgressMessage" tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <base target="_self" />
    
    <link href="../../style/PharmacyDefaults.css"   rel="stylesheet" type="text/css" />
    <link href="style/PharmacyReport.css"           rel="stylesheet" type="text/css" />

    <script language="javascript" type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"     async></script>
    <script language="javascript" type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"   async></script>
    <script language="javascript" type="text/javascript" src="script/ICW_PharmacyReport.js"                 async></script>
    <telerik:RadCodeBlock ID="CodeBlock" runat="server">
    <script>
        var sessionID      = <%= SessionInfo.SessionID               %>;
        var siteID         = <%= SessionInfo.SiteID                  %>;
        var autoPrint      = <%= this.AutoPrint.ToString().ToLower() %>;
        var reportInfoList = <%= JsonConvert.SerializeObject(this.ReportInfoList.ToArray()) %>;
    </script>
    </telerik:RadCodeBlock>

    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->    
</head>
<body onresize="body_onResize();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <div>

    <table cellpadding="0" cellspacing="0" style="margin-left:20px; width:97%; background-color:#DDDDDD;height:25px;">
        <tr>
            <td><uc:SiteNamePanelControl ID="siteNamePanel" runat="server" /></td>
            <td>&nbsp;</td>
            <td style="width:4%;"><uc:SiteColourPanelControl ID="siteColourPanel" runat="server" /></td>
        </tr>
    </table>
    
    <asp:UpdatePanel ID="upMain" runat="server">
    <ContentTemplate>    
    <div style="margin-left:15px;margin-right:15px;margin-top:5px;height:19px;">
        <telerik:RadTabStrip runat="server" ID="tabButtons" OnClientTabSelected="tabSelected" ScrollChildren="true" PerTabScrolling="true" ondragstart="return false;" > 
            <Tabs /> 
        </telerik:RadTabStrip>
    </div>    
        
    <div class="container" style="margin-top:9px;">
        <div id="divReports">&nbsp;</div>
        
        <hr />
                                
        <asp:Panel ID="pnFooter" runat="server" style="height:40px">
            <asp:UpdatePanel ID="upFooter" runat="server">
            <ContentTemplate>    
                <div style="float:left; margin-left:5px;">
                    <asp:Button ID="btnAddReport"       CssClass="PharmButton" Text="Add..." runat="server" AccessKey="A" Width="100px" OnClientClick="btnAddReport_OnClick();    return false;" />&nbsp;&nbsp;
                    <asp:Button ID="btnRemoveReport"    CssClass="PharmButton" Text="Remove" runat="server"               Width="100px" OnClientClick="btnRemoveReport_OnClick(); return false;" />
                </div>
            </ContentTemplate>    
            </asp:UpdatePanel>
        </asp:Panel>              
    </div>
    </ContentTemplate>    
    </asp:UpdatePanel>
                
    <!-- update progress message -->
    <pc:ProgressMessage id="progressMessage" runat="server" EnableTheming="False" EnableViewState="false" />
    </div>
    </form>
</body>
</html>
