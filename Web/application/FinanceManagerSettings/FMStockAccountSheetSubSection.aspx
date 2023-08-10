<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FMStockAccountSheetSubSection.aspx.cs" Inherits="application_FinanceManagerSettings_FMBalanceSheetSubSection" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>
<%@ Register TagPrefix="icw" Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Sub Section Editor</title>
    <base target=_self>
    
    <link href="../../style/PharmacyGridControl.css"    rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"       rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"             rel="stylesheet" type="text/css" />
        
    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.4.3.min.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"      async></script>       
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" defer></script>
    
    <script type="text/javascript">
        SizeAndCentreWindow("550px", "350px");
        
        function pharmacygridcontrol_onselectrow(controlID, rowindex)
        {
            if (controlID == 'gridRules')
                $('[id$="hfSelectedRowIndex"]').val(rowindex.toString());  
        }        
    </script>
        
    <style type="text/css">html, body{height:94%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body scroll="none">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <div>
    <icw:Container runat="server" Height="100%">
        <asp:UpdatePanel runat="server">
        <ContentTemplate>          
            <icw:Form runat="server">
                <icw:ShortText ID="tbAccountDescription" runat="server" Caption="Description:"  TextboxWidth="300px"    />
            </icw:Form>

            <div style="width:80%; height:100px; margin-left: 50px" >
                Rules to use
                <gc:GridControl ID="gridRules" runat="server" EnableTheming="False" CellSpacing="0" CellPadding="2" />
                <asp:Label id="gridRulesError" runat="server" CssClass="ErrorMessage" Text="&nbsp;" />
                <asp:HiddenField ID="hfGridRules"        runat="server" />
                <asp:HiddenField ID="hfSelectedRowIndex" runat="server" />
            
                <div style="float:right;">    
                    <asp:Button ID="btnAdd"    runat="server" CssClass="PharmButtonSmall" Text="Add"    AccessKey="A" OnClick="btnAdd_OnClick"    />
                    <asp:Button ID="btnDelete" runat="server" CssClass="PharmButtonSmall" Text="Delete" AccessKey="D" OnClick="btnDelete_OnClick" />
                </div>
            </div>
            
            <br />
                
            <div style="float:right; margin-left:40px; margin-top:55px;">
                <asp:Button ID="btnOK"     runat="server" CssClass="PharmButton" Text="OK"     AccessKey="O" OnClick="btnOK_OnClick" />
                <asp:Button ID="btnCancel" runat="server" CssClass="PharmButton" Text="Cancel" AccessKey="C" />
            </div>

            <icw:MessageBox ID="mbRule" runat="server" Caption="" OnOkClicked="mbRuleOk_OnClick" Buttons="OKCancel" Visible="false" Height="150px" Width="320px">
                <icw:Form runat="server" Width="300px">
                    <icw:List ID="lRules" runat="server" Caption="Rule Code:" ShowClearOption="false" ShortListMaxItems="40" />
                </icw:Form>
            </icw:MessageBox>
        </ContentTemplate>
        </asp:UpdatePanel>
    </icw:Container>                
    </div>
    </form>
</body>
</html>
