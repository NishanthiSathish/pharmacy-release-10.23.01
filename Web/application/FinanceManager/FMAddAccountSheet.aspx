<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FMAddAccountSheet.aspx.cs" Inherits="application_FinanceManagerStockAccountSheet_FMAddAccountSheet" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Register Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" TagPrefix="icw"     %>

<script type="text/javascript">
    window.dialogHeight = '600px';
    window.dialogWidth  = '650px';
</script>
        
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Account Enquiry</title>
    <base target=_self>
        
    <link href="../../style/icwcontrol.css" rel="stylesheet" type="text/css" />
    
    <style type="text/css">html, body{height:95%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body scroll="none">
    <form runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <icw:Container id="containter" runat="server" Height="555px" >
        <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
        <ContentTemplate>              
            <icw:Form ID="frmAccountCode" runat="server" Caption="Account Code">
                <icw:List runat="server" ID="lsAccountCode" Caption="Account Code" Mandatory="True" ShowClearOption="false" ShortListMaxItems="50" />
            </icw:Form>
                
            <icw:Form runat="server" Caption="Date Range">
                <icw:DateTime runat="server" ID="dtStartDate" Mode="Date" Caption="Start Date" Mandatory="True" />
                <icw:DateTime runat="server" ID="dtEndDate"   Mode="Date" Caption="End   Date" Mandatory="True" />                
            </icw:Form>
                
            <icw:General runat="server" Caption="Select Site:" Mandatory="True">
                <asp:Panel ID="pnSiteList" runat="server" ScrollBars="Vertical" Height="150px" style="border: solid 1px #E4C48B">
                    <asp:CheckBoxList ID="cblSites" runat="server"/>
                </asp:Panel>
                <div style="width:100%;text-align:center">
                    <asp:Label ID="lbSiteError" runat="server" Text="&nbsp;" EnableViewState="false" CssClass="ErrorMessage" />
                </div>      
                <asp:Button ID="btnCheckAll"   runat="server" CssClass="PharmButtonSmall" Height="20px" Width="65px" Text="Check All"   OnClick="btnCheckAll_OnClick"   />&nbsp;
                <asp:Button ID="btnUnCheckAll" runat="server" CssClass="PharmButtonSmall" Height="20px" Width="65px" Text="Uncheck All" OnClick="btnUncheckAll_OnClick" />
            </icw:General>             
                
            <icw:General runat="server">
                <div style="float: right;">
                    <icw:Button ID="btnCancel" runat="server" CssClass="PharmButton" Caption="Cancel" AccessKey="C" />
                </div>
                <div style="float: right; margin-right: 20px">
                    <icw:Button ID="btnOK"     runat="server" CssClass="PharmButton" Caption="OK"     AccessKey="O" OnClick="btnOK_OnClick" />
                </div>
            </icw:General>             

            <icw:MessageBox ID="mbInvalidData" runat="server" Visible="false" Caption="Not enough data" OnOkClicked="btnMessageBox_OkClick" Buttons="OK" Height="110px" Width="300px">
                <icw:Label ID="lbInvalidData" runat="server" Text="Finance Manager has not been installed long enough,<br />to generate enough data for a stock balance sheet." />
            </icw:MessageBox>
        </ContentTemplate>
        </asp:UpdatePanel>
    </icw:Container>
    </form>
</body>
</html>
