<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FMTransactionTypeEditor.aspx.cs" Inherits="application_FinanceManagerSettings_FMTransactionTypeEditor" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Register TagPrefix="icw" Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Transaction Type Editor</title>
    <base target="_self" />
    
    <link href="../../style/icwcontrol.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>       
    <script type="text/javascript">
        SizeAndCentreWindow("550px", "200px");

        function form_onload() 
        {
            $('#container').height(parseInt(window.dialogHeight) - 16);
        }
    </script>        
</head>
<body onload="form_onload();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div>
        <icw:Container ID="container" runat="server" ShowHeader="false" FillBrowser="false" ControlToFocusId="tbDescription">
        <asp:UpdatePanel ID="upPanel" runat="server">
        <ContentTemplate>    
            <icw:Form ID="Form2" runat="server">
                <icw:ShortText  ID="tbPharmacyLog" runat="server" Caption="Transaction Log:"/>
                <icw:ShortText  ID="tbKind"        runat="server" Caption="Kind:"           />
                <icw:ShortText  ID="tbDescription" runat="server" Caption="Description:"     Mandatory="true" TextboxWidth="300px" />
            </icw:Form>
                
            <br />
                    
            <icw:General ID="General1" runat="server">
                <div style="float: right;">
                    <icw:Button ID="btnCancel" runat="server" CssClass="PharmButton" Caption="Cancel" AccessKey="C" />
                </div>
                <div style="float: right; margin-right: 20px">
                    <icw:Button ID="btnOK"     runat="server" CssClass="PharmButton" Caption="OK"     AccessKey="O" OnClick="btnOK_OnClick" />
                </div>
            </icw:General>
        </ContentTemplate>
        </asp:UpdatePanel>                         
        </icw:Container>
    </div>
    </form>
</body>
</html>
