<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_PharmacyProductEditor.aspx.cs" Inherits="application_PharmacyProductEditor_ICW_PharmacyProductEditor" EnableEventValidation="True" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register src="../pharmacysharedscripts/QuesScrl/QuesScrl.ascx"      tagname="QuesScrl"                  tagprefix="uc" %>
<%@ Register src="UpdateServiceControl.ascx"                            tagname="UpdateServiceControl"      tagprefix="uc" %>   
<%@ Register src="AlternateBarcodeControl.ascx"                         tagname="AlternateBarcodeControl"   tagprefix="uc" %>   
<%@ Register src="../pharmacysharedscripts/SiteColourPanelControl.ascx" tagname="SiteColourPanelControl"    tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SiteNamePanelControl.ascx"   tagname="SiteNamePanelControl"      tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx"        tagname="ProgressMessage"           tagprefix="uc" %>
<%@ Register src="../ContractEditor/ManualContractEditor.ascx"          tagname="ContractEditor"            tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SaveIndicatorControl.ascx"   tagname="SaveIndicator"             tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Pharmacy Product Editor</title>
    <base target="_self" />

    <link href="../../style/ScrollTableContainer.css"                       rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"                                 rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyGridControl.css"                        rel="stylesheet" type="text/css" />
	<link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../pharmacysharedscripts/QuesScrl/QuesScrl.css"             rel="stylesheet" type="text/css" />
    <link href="style/PharmacyProductEditor.css"                            rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../sharedscripts/icwcombined.js"                        defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"        defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/QuesScrl/QuesScrl.js"          defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/reports.js"                    defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/FileHandling.js"               defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/HelperWebService.js"           defer></script>
    <script type="text/javascript" src="../ContractEditor/script/ManualContractEditor.js"       defer></script>
    <script type="text/javascript" src="script/PharmacyProductEditor.js"                        async></script>
    <script type="text/javascript">
        var MNU_EDIT_SECTION        = 1;
        var sessionID               = <%= SessionInfo.SessionID  %>;
        var ascribeSiteNumber       = <%= SessionInfo.SiteNumber %>;
        var siteId                  = <%= SessionInfo.SiteID %>;
        var editableSiteNumbers     = '<%= editableSiteNumbers.ToCSVString(",")    %>';
        var URLtoken                = '<%= URLtoken              %>';
        var configurationEditor     = '<%= this.configurationEditor.ToString() %>';
        var applicationPath         = '<%= this.applicationPath.Replace("\\", "\\\\") %>';
    </script>

    <style type="text/css">html, body{height:93.5%}</style>  <!-- Ensure page is full height of screen -->    
</head>
<body onresize="body_onResize();" onload="body_onload();" onunload="body_unload();">
    <form id="form1" runat="server" onkeydown="form_onkeydown();" >
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="icw-container">
        <!-- update progress message -->
        <uc:ProgressMessage ID="progressMessage" runat="server" />
<% if (this.isActiveXControlEnabled) %>
<% { %>
        <OBJECT 
			id=objPharmacyProductEditor
			style="left:0px;top:0px;width:98%;height:25px"
			codebase="../../../ascicw/cab/HEdit.cab"
			component="productstockeditor.ocx"
			classid=CLSID:949B5120-FFE5-48A0-B51E-555FBF1294DE VIEWASTEXT>
			<PARAM NAME="_ExtentX" VALUE="16113">
			<PARAM NAME="_ExtentY" VALUE="11139">
			<SPAN STYLE="color:red">ActiveX control failed to load! -- Please check browser security settings.</SPAN>
		</OBJECT>
<% } %>

        <asp:Panel ID="pnMain" runat="server" DefaultButton="btnSave"> <!-- need to set default button  no other reason -->
        <table id="tbl" style="height:100%;" cellpadding="0" cellspacing="0">
            <tr style="vertical-align:top;">
                <td id="trViews" runat="server" class="ViewList" style="width:190px" onmousedown="trViews_onmousedown();">
                    <div class="ViewHeader">Select view:</div>
                </td>
                <td>
                    <table cellpadding="0" cellspacing="0" style="background-color:#DDDDDD; width:98%;height:25px;">
                        <tr>
                            <td><uc:SiteNamePanelControl ID="siteNamePanel" runat="server" /></td>
                            <td>&nbsp;</td>
                            <td style="width:5%;"><uc:SiteColourPanelControl ID="SiteColourPanelControl1" runat="server" /></td>
                        </tr>
                    </table>

                    <hr />

                    <asp:UpdatePanel ID="upView" runat="server">
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSave"               />
                        <asp:AsyncPostBackTrigger ControlID="btnPrintShelfLabel"    />
                    </Triggers>
                    <ContentTemplate>
                        <asp:HiddenField ID="hfViewIndex"               runat="server" />
                        <asp:HiddenField ID="hfNSVCode"                 runat="server" />
                        <asp:HiddenField ID="hfSupCode"                 runat="server" />
                        <asp:HiddenField ID="hfProductStockLocker"      runat="server" />
                        <asp:HiddenField ID="hfShelfEdgeLabelFliename"  runat="server" />

                        <table id="tblHeader">
                            <tr style="height:22px">
                                <td id="lbDescription" runat="server" class="titleProduct" style="width:75%"></td>
                                <td style="width:25%;text-align:right;"><uc:SaveIndicator ID="saveIndicator" runat="server" /></td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="lbPrescriptionTitle" runat="server">
                                        <span class="titleLabel">Prescription Link: </span>&nbsp;<span id="lbPrescription" runat="server" class="titleValue" /><br />
                                    </div>

                                    <div style="padding-top:3px;">
                                        <span class="titleLabel">Tradename:    </span>&nbsp;<span id="lbTradename"    runat="server" class="titleValue" /><br />
                                    </div>

                                    <div style="padding-top:3px;">
                                        <span class="titleLabel">Pack&nbsp;size:  </span>&nbsp;<span id="lbPackSize"   runat="server" class="titleValue" />&nbsp&nbsp
                                        <span class="titleLabel">NSV&nbsp;Code:   </span>&nbsp;<span id="lbNSVCode"    runat="server" class="titleValue" />&nbsp&nbsp
                                        <span class="titleLabel">Lookup&nbsp;Code:</span>&nbsp;<span id="lbLookupCode" runat="server" class="titleValue" /><br />
                                    </div>

                                    <div style="padding-top:3px;">
                                        <span id="lbSupCodeTitle" runat="server">
                                            <span class="titleLabel">Supplier&nbsp;Code:  </span>&nbsp;<span id="lbSupCode"    runat="server" class="titleValue" />&nbsp&nbsp
                                        </span>
                                        <span class="titleLabel">DSS&nbsp;Maintained: </span>&nbsp;<span id="lbDSS"        runat="server" class="titleValue" />&nbsp&nbsp
                                        <span class="titleLabel">Stores&nbsp;Only    </span>&nbsp;<span id="lbStoresOnly" runat="server" class="titleValue" />
                                    </div>
                                </td>
                                <td id="notFoundOnSites" runat="server" />
                            </tr>
                        </table>
                        
                        <hr />

                        <div id="divView" runat="server">
                            <asp:MultiView ID="multiView" runat="server">
                                <asp:View ID="vEditorControl" runat="server" >
                                    <uc:QuesScrl ID="editorControl" runat="server" ShowHeaderRow="true" OnValidated="control_OnValidated" OnSaved="control_OnSaved" />
                                </asp:View>
                                <asp:View ID="vUpdateServiceControl" runat="server">
                                    <uc:UpdateServiceControl ID="updateService" runat="server" OnValidated="control_OnValidated" OnSaved="control_OnSaved" />
                                </asp:View>
                                <asp:View ID="vAlternateBarcodeControl" runat="server">
                                    <uc:AlternateBarcodeControl ID="alternateBarcodes" runat="server" OnValidated="control_OnValidated" OnSaved="control_OnSaved" />
                                </asp:View>
                                <asp:View ID="vContractEditor" runat="server">
                                    <uc:ContractEditor ID="contractEditor" runat="server" OnSupplierCodeUpdated="contractEditor_OnSupplierCodeUpdated" OnValidated="control_OnValidated" OnSaved="control_OnSaved" />
                                </asp:View>
                            </asp:MultiView>
                        </div>
                    </ContentTemplate>
                    </asp:UpdatePanel>
                </td>
            </tr>
            <tr id="trButtons" style="vertical-align:top;height:50px;">
                <td class="ViewList" style="padding-left:5px;padding-right:5px;">
                    <asp:Button ID="btnAdd"  style="float:left;"  runat="server" CssClass="PharmButton" Text="Add..."  AccessKey="A" Width="85px" OnClientClick="btnAdd_OnClick();  return false;" />
                    <asp:Button ID="btnEdit" style="float:right;" runat="server" CssClass="PharmButton" Text="Edit..." AccessKey="E" Width="85px" OnClientClick="btnEdit_OnClick(); return false;" />
                </td>
                <td style="padding-left:10px;padding-right:35px;">
                    <table style="width:99%;" cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="text-align:left;width:33%;">
                            <asp:Button ID="btnItemEnquiry"     runat="server" CssClass="PharmButton" Text="Item Enquiry..."   Width="100px" OnClientClick="DisplayItemEnquiry(); return false;"         />&nbsp;&nbsp;
                            <asp:Button ID="btnPrintShelfLabel" runat="server" CssClass="PharmButton" Text="Print Shelf Label" Width="100px" OnClientClick="btnPrintShelfLabel_OnClick(); return false;" />&nbsp;&nbsp;
                        </td>
                        <td style="text-align:center;width:33%;">
                            <asp:Button ID="btnSave" runat="server" CssClass="PharmButton" Text="Save" AccessKey="S" OnClick="btnSave_OnClick" />&nbsp;&nbsp;
                        </td>
                        <td style="text-align:right;width:33%;">
                            <asp:UpdatePanel ID="upButtons" runat="server">
                            <ContentTemplate>
                                <asp:Button ID="btnChangeReport"    runat="server" CssClass="PharmButton" Text="Change Report..."                Width="110px" OnClientClick="ChangeReport_onclick(); return false;"      />&nbsp;&nbsp;
                                <asp:Button ID="btnSetPrimary"      runat="server" CssClass="PharmButton" Text="Set Primary"     Visible="false" Width="100px" OnClientClick="btnSetPrimary_OnClick(); return false;"     />&nbsp;&nbsp;
                                <asp:Button ID="btnDeleteSupplier"  runat="server" CssClass="PharmButton" Text="Delete Supplier" Visible="false" Width="100px" OnClientClick="btnDeleteSupplier_OnClick(); return false;" />&nbsp;&nbsp;
                            </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                    </table>
                </td>
            </tr>
        </table>    
        </asp:Panel>
    </div>
    </form>
</body>
</html>
