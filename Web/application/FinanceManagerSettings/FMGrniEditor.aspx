<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FMGrniEditor.aspx.cs" Inherits="application_FinanceManagerSettings_FMGrniEditor" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Register Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" TagPrefix="icw"     %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target=_self>
        
    <link href="../../style/icwcontrol.css" rel="stylesheet" type="text/css" />
    <style>
        body
        {
            background-color: White;        
        }
        
        #form1
        {
            background-color: White;        
        }
        
        #frmOpeningBalance
        {
            top:-50px;
        }
    </style>
        
    <style type="text/css">html, body{height:95%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body scroll="none">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <icw:Container id="containter" runat="server" Height="600px" Width="400px">
        <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>              
            <icw:Form ID="frmOpeningBalance" runat="server" Caption="Opening Balance">
                <icw:DateTime  runat="server"  ID="dtOpeningBalanceDate" Caption="Date"      Mandatory="True" Mode="Date"                                                    />
                <icw:Label     runat="server"  ID="dtOpeningBalanceDateError" Text="&nbsp;" CssClass="ErrorMessage " />
                <icw:Number    runat="server"  ID="tbOpeningBalance"     Caption="Value (£)" Mandatory="true" MaxCharacters="20" AllowNegativeNumbers="true" Mode="Float"    />
            </icw:Form>  
            
            <icw:General runat="server">
                <div style="float:right; margin-right:5px">
                    <icw:Button ID="btnSave" runat="server" CssClass="PharmButton" Caption="Save" AccessKey="S" OnClick="btnSave_OnClick" />
                </div>
            </icw:General>                      
        </ContentTemplate>
        </asp:UpdatePanel>
    </icw:Container>
    </form>
</body>
</html>
