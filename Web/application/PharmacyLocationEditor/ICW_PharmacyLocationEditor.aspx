<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_PharmacyLocationEditor.aspx.cs" Inherits="application_PharmacyLocationEditor_ICW_PharmacyLocationEditor" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register src="../pharmacysharedscripts/QuesScrl/QuesScrl.ascx"      tagname="QuesScrl"                  tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SiteColourPanelControl.ascx" tagname="SiteColourPanelControl"    tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SiteNamePanelControl.ascx"   tagname="SiteNamePanelControl"      tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx"        tagname="ProgressMessage"           tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SaveIndicatorControl.ascx"   tagname="SaveIndicator"             tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Pharmacy Location Editor</title>
    <base target="_self" />

	<link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/ScrollTableContainer.css"                       rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"                                 rel="stylesheet" type="text/css" />
    <link href="../pharmacysharedscripts/QuesScrl/QuesScrl.css"             rel="stylesheet" type="text/css" />
    <style>   
        .titleLabel
        {
            font-size: 12px;
            font-weight: bold;
        }
    
        .titleValue
        {
            font-size: 12px;
        }        
    </style>

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/QuesScrl/QuesScrl.js"          async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/reports.js"                    defer></script>
    <script type="text/javascript" src="script/PharmacyLocationEditor.js"                       async></script>
    <script type="text/javascript">
        var siteID              = <%= SessionInfo.SiteID %>;
        var sortBy              = '<%= sortSelectorColumn %>';
        var editableSiteNumbers = '<%= editableSiteNumbers.ToCSVString(",")    %>';
    </script>

    <%--<style type="text/css">html, body{height:96.5%}</style>  <!-- Ensure page is full height of screen -->    --%>
</head>
<body onload="body_onload();" onresize="body_resize();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <uc:ProgressMessage runat="server" />
    <div class="icw-container-fixed" style="padding-left:5px;padding-right:5px">
        <table cellpadding="0" cellspacing="0" style="background-color:#DDDDDD; width:100%;height:25px;">
            <tr>
                <td><uc:SiteNamePanelControl ID="siteNamePanel" runat="server" /></td>
                <td>&nbsp;</td>
                <td style="width:5%;"><uc:SiteColourPanelControl ID="SiteColourPanelControl1" runat="server" /></td>
            </tr>
        </table>

        <hr />

        <asp:UpdatePanel ID="upHeader" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <table style="width:100%;">
                <tr style="vertical-align:top;">
                    <td style="width:68%">
                        <span class="titleLabel">Location:</span>&nbsp;<span id="lbLocation" runat="server" class="titleValue" /><br />
                        <span class="titleLabel">HAP Location:</span>&nbsp;<span id="lbHAPLocation" runat="server" class="titleValue" />
                    </td>
                    <td id="notFoundOnSites" runat="server" style="width:25%;"></td>
                    <td style="width:7%;text-align:right;"><uc:SaveIndicator ID="saveIndicator" runat="server" /></td>
                </tr>
            </table>
        </ContentTemplate>
        </asp:UpdatePanel> 
                                
        <hr />

        <asp:UpdatePanel ID="upMain" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
        </Triggers>
        <ContentTemplate>
            <asp:HiddenField ID="hfSelectedCode" runat="server" />
            <asp:HiddenField ID="hfWCustomerID"  runat="server" />
            <div id="divEditorControl" style="padding-top:5px;padding-left:10px;height:95%;">
                <uc:QuesScrl ID="editorControl" runat="server" OnValidated="editorControl_OnValidated" OnSaved="editorControl_OnSaved" />
            </div>
        </ContentTemplate>
        </asp:UpdatePanel> 

        <hr style="width:100%;" />

        <div>
            <div style="position:absolute; bottom:20px; left:20px;">
                <span style="margin-left:0px" ><asp:Button ID="btnAdd"  runat="server" CssClass="PharmButton" Text="Add..."  AccessKey="A" OnClientClick="btnAdd_onclick(); return false;"  /></span>
                <span style="margin-left:10px"><asp:Button ID="btnEdit" runat="server" CssClass="PharmButton" Text="Edit..." AccessKey="E" OnClientClick="btnEdit_onclick(); return false;" /></span>
            </div>
            <div id='divSave' style="position:absolute; bottom:20px;">
                <asp:Button ID="btnSave" runat="server" CssClass="PharmButton" Text="Save"    AccessKey="S" OnClick="btnSave_OnClick" Width="100px" />
            </div>
            <div id="divChangeReport" style="position:absolute; bottom:20px;right:20px">
                <asp:Button ID="btnChangeReport" runat="server" CssClass="PharmButton" Text="Change Report..."  Width="100px" OnClientClick="ChangeReport_onclick(); return false;" />                
            </div>            
        </div>
    </div>
    </form>
</body>
</html>
