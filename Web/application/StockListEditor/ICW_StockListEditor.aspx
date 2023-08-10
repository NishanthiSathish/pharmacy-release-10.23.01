<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_StockListEditor.aspx.cs" Inherits="application_StockListEditor_ICW_StockListEditor" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Import Namespace="ascribe.pharmacy.wardstocklistlayer" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx"        tagname="GridControl"               tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/PharmacyLabelPanelControl.ascx"  tagname="LabelPanelControl"         tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SiteColourPanelControl.ascx"     tagname="SiteColourPanelControl"    tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SiteNamePanelControl.ascx"       tagname="SiteNamePanelControl"      tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx"            tagname="ProgressMessage"           tagprefix="uc" %>
<%@ Register src="../PharmacyLogViewer/DisplayLogRows.ascx"                 tagname="LogRows"                   tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SaveIndicatorControl.ascx"       tagname="SaveIndicator"             tagprefix="uc" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Stock List Editor</title>

    <link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css"                        rel="stylesheet" type="text/css" />
    <link href="../../style/LabelPanelControl.css"                          rel="stylesheet" type="text/css" />
    <link href="style/WardStockList.css"                                    rel="stylesheet" type="text/css" />   

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../sharedscripts/json2.js"                              async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"           defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyLabelPanelControl.js"  async></script>
    <script type="text/javascript" src="script/StockListEditor.js"                              async></script>
    <telerik:RadScriptBlock runat="server"> 
    <script type="text/javascript">
        var sessionID                = <%= SessionInfo.SessionID  %>;
        var siteID                   = <%= SessionInfo.SiteID     %>;
        var ascribeSiteNumber        = <%= SessionInfo.SiteNumber %>;        
        var controller;
        var lastRowSiteProductDataID = undefined;
        var timerHandle              = undefined;
        var loadingPage              = true;
        var prevSelectedIDOnDownKey  = new Array();
        var sortSelectorColumn       = '<%= sortSelectorColumn %>';
        var UrlParameterEscapeChar   = '<%= WardStockListController.UrlParameterEscapeChar %>';
        var allowStoresOnly          = '<%= Settings.AllowStoresOnly %>';
    </script>
    </telerik:RadScriptBlock>
</head>
<body onresize="body_onresize()" onunload="body_unload();">
    <form id="form1" runat="server" style="width:100%">
    <telerik:RadScriptManager runat="server" /> 
    <telerik:RadWindowManager ID="radWindowManager" runat="server" />

    <asp:UpdatePanel ID="upDummy" runat="server" ChildrenAsTriggers="false" EnableViewState="false" UpdateMode="Conditional" />

    <!-- update progress message -->
    <uc:ProgressMessage ID="progressMessage" runat="server" />

<% if (this.isActiveXControlEnabled) %>
<% { %>
        <OBJECT 
			id=objStoresControl
			style="left:0px;top:0px;width:98%;height:25px"
			codebase="../../../ascicw/cab/HEdit.cab"
			component="StoresCtl.ocx"
			classid=CLSID:D0E003F3-1F55-48DA-8231-434BE54EF6E2 VIEWASTEXT>
			<PARAM NAME="_ExtentX" VALUE="16113">
			<PARAM NAME="_ExtentY" VALUE="11139">
			<SPAN STYLE="color:red">ActiveX control failed to load! -- Please check browser security settings.</SPAN>
		</OBJECT>
<% } %>

    <asp:UpdatePanel ID="upTitle" runat="server" UpdateMode="Conditional" >
    <ContentTemplate>
        <asp:HiddenField ID="hfNameForCSVFile" runat="server" />    <!-- name to be used for CSV file -->
        <table cellpadding="0" cellspacing="0" style="background-color:#DDDDDD;width:100%;height:25px;">
            <tr>
                <td><uc:SiteNamePanelControl ID="siteNamePanel" runat="server" /></td>
                <td><%= controller.WardStockList.Any() ? string.Format("{0} ( {1} )", controller.WardStockList.First().Description, controller.WardStockList.First().Code) : "&nbsp;" %></td>
                <td style="width:25%;">&nbsp;</td>
                <td style="width:5%;"><uc:SiteColourPanelControl ID="SiteColourPanelControl1" runat="server" /></td>
            </tr>
        </table>
    </ContentTemplate>
    </asp:UpdatePanel>

    <asp:UpdatePanel ID="upToolbar" runat="server" UpdateMode="Conditional" >
    <ContentTemplate>
        <telerik:RadToolBar ID="radToolbar"  Skin="Office2007" runat="server" EnableRoundedCorners="true" EnableShadows="true" Width="100%" OnClientButtonClicked="function (sender, args) {eval(args.get_item().get_commandName()); }" ondragstart="return false;">
            <Items /> 
        </telerik:RadToolBar>
    </ContentTemplate>
    </asp:UpdatePanel>

    <asp:UpdatePanel ID="upMain" runat="server" UpdateMode="Conditional" >
    <ContentTemplate>
        <asp:HiddenField ID="hfController" runat="server" />
        <asp:HiddenField ID="hfClipboard"  runat="server" />

        <div id="divGrid" style="width:100%;" onkeydown="divGrid_onkeydown();" onkeyup="divGrid_onkeyup();">
            <uc:GridControl ID="grid" runat="server" CellSpacing="0" CellPadding="2" JavaEventDblClick="grid_OnDblClick();" JavaEventOnMouseDown="grid_OnClick" AllowMultiSelect="true" EnterAsDblClick="true" />
        </div>

        <hr style="width:100%;" />

        <table id="tblInfoPanels" style="width:100%;">
            <colgroup>
                <col style="width:50%" />
                <col style="width:41%" />
                <col style="width: 9%" />
            </colgroup>
            <tr id="trTempEditMessage" runat="server" style="height:20px">
                <td colspan="3"><div class="ErrorMessage" style="width:100%;text-align:center;">Please note that any changes you make will not be saved</div></td>
            </tr>
            <tr id="trLockingMessage" runat="server" style="height:20px">
                <td colspan="2"><div class="InfoMessage" style="width:100%;text-align:center;font-weight:bold;">Stock list is now locked and cannot be accessed by other users</div></td>
                <td style="text-align:right;"><uc:SaveIndicator id="saveIndicator" runat="server" /></td>
            </tr>
            <tr id="trInUseMessage" runat="server" style="height:20px">
                <td colspan="3"><div id="divInUseMessage" runat="server" class="IsUseMessage">Stock list in use by on</div></td>
            </tr>
            <tr id="trPanels" runat="server" style="vertical-align:top;">
                <td style="width:50%" class="PanelLeft"             ><uc:LabelPanelControl ID="pnlRowPanel"  runat="server" /></td>
                <td style="width:50%" class="PanelRight" colspan="2"><uc:LabelPanelControl ID="pnlListPanel" runat="server" /></td>
            </tr>
        </table>
    </ContentTemplate>
    </asp:UpdatePanel>

    <telerik:RadContextMenu runat="server" ID="contextMenu" EnableRoundedCorners="true" EnableShadows="true" OnClientItemClicked="contexMenu_OnClicked" OnClientShowing="contexMenu_OnShowing" />
     
    <div id="divFind" style="display:none;" onkeydown="if (event.keyCode == 13) { btnFindNext_onclick($('#tbFind'), $('#findError'), ''); window.event.cancelBubble=true; window.event.returnValue=false; return false; }">
        Enter either:<br/>
        &nbsp;&nbsp;string to be found in the information on screen<br/>
        &nbsp;&nbsp;or<br/>
        &nbsp;&nbsp;item barcode<br/>
        
        <p>Enter string: <asp:TextBox ID="tbFind" runat="server" Width="200px" /></p>

        <div style="text-align:center;"><span id="findError" class="ErrorMessage">&nbsp;</span></div>
    </div>
     
    <div id="divFindIssueReturn" style="display:none;" onkeydown="if (event.keyCode == 13) { $('#btnJqueryDialogOK').click(); window.event.cancelBubble=true; window.event.returnValue=false; return false; }">
        To <span id="spnIssueReturn"></span>&nbsp;enter item barcode:<br/>
        
        <p>Enter barcode: <asp:TextBox ID="tbFindIssueReturn" runat="server" Width="200px" /></p>

        <div style="text-align:center;"><span id="findIssueReturnError" class="ErrorMessage">&nbsp;</span></div>
    </div>
    </form>

    <iframe style="display:none;" id="fraSaveToCSV" src="../pharmacysharedscripts/SaveAs.aspx" border="0" frameborder="no" disabled noresize />
</body>
</html>
