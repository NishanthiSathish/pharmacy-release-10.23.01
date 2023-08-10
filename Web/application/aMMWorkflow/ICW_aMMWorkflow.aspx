<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_aMMWorkflow.aspx.cs" Inherits="application_aMMWorkflow_ICW_aMMWorkflow" %>
<%@ Import Namespace="ascribe.pharmacy.shared"       %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx"            tagname="ProgressMessage"           tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/HapToolbar/HapToolbarControl.ascx" tagname="Toolbar" tagPrefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>aMM Screening Desktop</title>

    <link href="../../style/application.css"                                rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../sharedscripts/lib/jqueryui/jquery-ui-1.8.17.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css"                        rel="stylesheet" type="text/css" />
    <style type="text/css">
        html, body{height:90%}   /* Ensure page is full height of screen */
    
        /* overrides the grid control when on header row to cause the selected state to be hidden (like main ICW) */
        tr[headerRow].Selected td
        {
            background-color: #676767;
        }    
    </style>       
    
    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../sharedscripts/json2.js"                              async></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.8.17.min.js"  defer></script>
    <script type="text/javascript" src="../sharedscripts/ocs/OCSShared.js"                      async></script>
	<script type="text/javascript" src="../sharedscripts/icw.js"                                defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/FileHandling.js"               defer></script>
    <script type="text/javascript" src="../sharedscripts/ocs/OCSContextActions.js"              defer></script>
    <script type="text/javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"    defer></script>
	<script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/HapToolbar/HapToolbarControl.js"          async></script>
	<script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/OCSProcessor.js"               defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/reports.js"                    defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/HelperWebService.js"           defer></script>
    <script type="text/javascript" src="script/aMMWorkflow.js"                                  async></script>
	
    <telerik:RadCodeBlock ID="CodeBlock" runat="server">
    <script>
        var sessionID              = <%= SessionInfo.SessionID %>;
        var siteID                 = <%= SessionInfo.SiteID    %>;
        var aMMSupplyRequestBtns   = '<%= this.Request["AMMSupplyRequestButtons"] %>';
        var productionTrayBarcode  = '';
        var viewSettings;
    </script>
    </telerik:RadCodeBlock>
</head>
<body scroll="no" onresize="body_onresize()">
    <form id="form1" runat="server" style="width:100%">
    <telerik:RadScriptManager runat="server" /> 
    
    <!-- update progress message -->
    <uc:ProgressMessage ID="progressMessage" runat="server" />
    
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" Skin="Web20" />
    <telerik:RadWindowManager ID="RadWindowManager1" runat="server" EnableShadow="true" />    
    <div>
    <asp:UpdatePanel ID="upDummy" runat="server" UpdateMode="Conditional"><ContentTemplate /></asp:UpdatePanel>
    
    <table width="100%" height="100%" cellpadding="0" cellspacing="0">	
	    <tr>
		    <td>  
                <uc:Toolbar ID="mainToolbar" runat="server" />
            </td>
        </tr>
        <tr id="trToolbarFilters" runat="server" Visible="False">
            <td style="vertical-align: middle; padding-left: 15px; padding-top: 3px;">
                <!-- Toolbar below actual surrounds the filter options to just can't put HTML Controls in RadToolBar, so have to trick it width of toolbar set in code depending on number of items -->
                <telerik:RadToolBar ID="radToolbarFilters" runat="server" Skin="Office2007" style="position: absolute; top:33px; left: 0px; z-index:-1;" Height="22px" Width="190" />
                <asp:Panel ID="pnDueDate" runat="server" Visible="false">
                    <span style="padding-right: 15px;vertical-align: middle;">Due Date:&nbsp;<telerik:RadComboBox ID="ddlDueDate" runat="server" OnSelectedIndexChanged="dropDownListFilter_OnSelectedIndexChanged" AutoPostBack="True" NoWrap="True" Width="100" Skin="Office2007" /></span>
                </asp:Panel>
                <asp:Panel ID="pnDateRange" runat="server" Visible="false">
                    <span style="padding-right: 15px;vertical-align: middle;">Date Range:&nbsp;<asp:TextBox ID="tbDateRangeFrom" runat="server" BorderStyle="None" BackColor="Transparent" Width="75px" />&nbsp;&nbsp;to&nbsp;&nbsp;<telerik:RadDatePicker ID="dpDateRangeTo" runat="server" OnSelectedDateChanged="dropDownListFilter_OnSelectedIndexChanged" AutoPostBack="true" Skin="Office2007" Width="100px" /></span>
                </asp:Panel>
            </td>
        </tr>
        <tr height="5px">
            <td><hr /></td>
        </tr>
        <tr height="100%">
            <td>
                <div id="gridDiv">
                <asp:UpdatePanel ID="upWorklist" runat="server" UpdateMode="Conditional">
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="ddlDueDate" />
                </Triggers>
                <ContentTemplate>
                    <asp:HiddenField ID="hfViewSettings" runat="server" />

                    <div id="divGrid" style="width:100%;">
                        <uc:GridControl ID="grid" runat="server" />
                    </div>
                </ContentTemplate>
                </asp:UpdatePanel>
                </div>
            </td>
        </tr>
        </table>  

    </div>
    
    <!-- find dialog -->
    <div id="divSearch" style="display:none;" onkeydown="if (event.keyCode == 13) { btnFindNext_onclick(); window.event.cancelBubble=true; window.event.returnValue=false; return false; }">
        Production Tray Barcode: <asp:TextBox ID="tbSearch" runat="server" Width="110px" onfocus="this.select();" />        
        <div style="text-align:center;margin-top:10px;"><span id="searchError" class="ErrorMessage">&nbsp;</span></div>
    </div>
    </form>

    <xml id="xmlStatusNoteFilter"><StatusNoteFilter action="include"><notetype description="ammformanufacture"/><notetype description="ammmanufacturecomplete"/></StatusNoteFilter></xml>
</body>
</html>
