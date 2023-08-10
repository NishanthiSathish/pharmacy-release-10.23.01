<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FMStockAccountSheetLayoutEditor.aspx.cs" Inherits="application_FinanceManagerSettings_FMStockAccountSheetLayoutEditor" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Import Namespace="ascribe.pharmacy.financemanagerlayer" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    
    <link href="../../style/application.css"         rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"    rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css" rel="stylesheet" type="text/css" />
    <link href="style/FinanceManagerSettings.css"    rel="stylesheet" type="text/css" />
        
    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.4.3.min.js"              ></script>
    <script type="text/javascript" src="../sharedscripts/icw.js"                          defer></script>    
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"       defer></script>    
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"  defer></script>
    <script type="text/javascript" src="scripts/FMStockAccountSheetLayoutEditor.js"       defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"           ></script>
    
    <script type="text/javascript">
        var sessionID                               = <%= SessionInfo.SessionID %>;
        var sectionType_OpeningBalance              = '<%= EnumDBCodeAttribute.EnumToDBCode(WFMStockAccountSheetSectionType.OpeningBalance)              %>';
        var sectionType_MainSection                 = '<%= EnumDBCodeAttribute.EnumToDBCode(WFMStockAccountSheetSectionType.MainSection)                 %>';
        var sectionType_AccountSection              = '<%= EnumDBCodeAttribute.EnumToDBCode(WFMStockAccountSheetSectionType.AccountSection)              %>';
        var sectionType_CalculatedClosingSection    = '<%= EnumDBCodeAttribute.EnumToDBCode(WFMStockAccountSheetSectionType.CalculatedClosingBalance)    %>';
        var sectionType_ActualClosingBalance        = '<%= EnumDBCodeAttribute.EnumToDBCode(WFMStockAccountSheetSectionType.ActualClosingBalance)        %>';
        var sectionType_ClosingBalanceDiscrepancies = '<%= EnumDBCodeAttribute.EnumToDBCode(WFMStockAccountSheetSectionType.ClosingBalanceDiscrepancies) %>';        
    </script>    
    
    <style type="text/css">html, body{height:90%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body scroll="no">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <div>
        <div style="float:left;">
            <b>Account Code:</b> <asp:Label ID="lbAccountCode" runat="server" />
        </div>            
        <div style="float:right; margin-right:5%;  margin-bottom: 10px;">
            <asp:UpdatePanel ID="upButtons" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="False">
            <ContentTemplate>    
                <asp:Button ID="btnAddSection" runat="server" CssClass="PharmButton" Height="23px" Width="100px" AccessKey="S" Text="Add Section" OnClientClick="btnAddSection_OnClick(); return false;" />
                <asp:Button ID="btnAddAccount" runat="server" CssClass="PharmButton" Height="23px" Width="100px" AccessKey="A" Text="Add Account" OnClientClick="btnAddAccount_OnClick(); return false;" />
                <asp:Button ID="btnEdit"       runat="server" CssClass="PharmButton" Height="23px"               AccessKey="E" Text="Edit"        OnClientClick="btnEdit_OnClick();       return false;" />
                <asp:Button ID="btnDelete"     runat="server" CssClass="PharmButton" Height="23px"               AccessKey="D" Text="Delete"      OnClientClick="btnDelete_OnClick();     return false;" />
            </ContentTemplate>
            </asp:UpdatePanel>        
        </div>
                    
        <div style="width: 95%; height: 95%;" onkeydown="grid_onkeydown('gridItemList', event);" >
            <asp:UpdatePanel ID="gridUpdatePanel" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="True">
            <ContentTemplate>    
                <gc:GridControl id="gridItemList" runat="server" EnableTheming="False" JavaEventDblClick="btnEdit_OnClick();" EmptyGridMessage="No finance manager balance sheet settings" CellSpacing="0" CellPadding="2" />
                <div id="gridItemListError" class="ErrorMessage" style="width:100%;text-align:center;">&nbsp;</div>
                <div style="float:right">
                    <asp:Button ID="btnRefresh" runat="server" CssClass="PharmButton" Height="23px" accesskey="R" Text="Refresh" UseSubmitBehavior="False" CausesValidation="False" OnClick="btnRefresh_OnClick" />
                </div>
            </ContentTemplate>
            </asp:UpdatePanel>        
        </div>        
    </div>   
    </form>
</body>
</html>
