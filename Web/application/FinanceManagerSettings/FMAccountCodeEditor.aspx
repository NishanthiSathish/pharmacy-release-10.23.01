<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FMAccountCodeEditor.aspx.cs" Inherits="application_FinanceManagerSettings_FMAccountCodeEditor" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Register TagPrefix="icw" Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Account Code Editor</title>
    <base target=_self>
        
    <link href="../../style/icwcontrol.css" rel="stylesheet" type="text/css" />
    
    <script type="text/javascript">
        function form_onload() 
        {
            window.dialogHeight = "200px";
            window.dialogWidth  = "550px";
            
            window.dialogLeft   = (parseInt(window.dialogLeft) - (parseInt(window.dialogWidth)  / 2)) + "px";
            window.dialogTop    = (parseInt(window.dialogTop)  - (parseInt(window.dialogHeight) / 2)) + "px";
            
            $('#container').height(parseInt(window.dialogHeight) - 16);
        }
        
    </script> 
</head>
<body onload="form_onload()">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div>
        <icw:Container ID="container" runat="server">
        <asp:UpdatePanel ID="upPanel" runat="server" UpdateMode="Conditional">
        <ContentTemplate>    
            <icw:Form runat="server">
                <icw:ShortText  ID="tbCode"        runat="server" Caption="Code:"         Mandatory="true" />
                <icw:ShortText  ID="tbDescription" runat="server" Caption="Description:"  Mandatory="true" TextboxWidth="300px"   />
            </icw:Form>
               
            <br />
                    
            <div>            
                <icw:General runat="server">
                    <div style="float: right;">
                        <icw:Button ID="btnCancel" runat="server" CssClass="PharmButton" Caption="Cancel" AccessKey="C" />
                    </div>
                    <div style="float: right; margin-right: 20px">
                        <icw:Button ID="btnOK"     runat="server" CssClass="PharmButton" Caption="OK"     AccessKey="O" OnClick="btnOK_OnClick" />
                    </div>
                </icw:General>
            </div>             
        </ContentTemplate>
        </asp:UpdatePanel>                         
        </icw:Container>  
    </div>
    </form>
</body>
</html>
