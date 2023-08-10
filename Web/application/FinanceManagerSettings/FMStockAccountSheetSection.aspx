<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FMStockAccountSheetSection.aspx.cs" Inherits="application_FinanceManagerSettings_FMStockAccountSheetSection" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Register Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" TagPrefix="icw"     %>
<%@ Register Assembly="Telerik.Web.UI"        Namespace="Telerik.Web.UI"        TagPrefix="telerik" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Section Editor</title>
    <base target=_self>
        
    <link href="../../style/icwcontrol.css" rel="stylesheet" type="text/css" />
    
    <script type="text/javascript">
        window.dialogHeight = "290px";
        window.dialogWidth  = "550px";
    </script>
        
    <style type="text/css">html, body{height:90%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <div>
    <icw:Container runat="server" ControlToFocusId="tbSectionDescription" Height="100%">
        <asp:UpdatePanel ID="upButtons" runat="server">
        <ContentTemplate>              
            <icw:General runat="server">
                <table>
                    <tr>
                        <td>Description:</td>
                        <td>
                        <icw:ShortText  ID="tbSectionDescription" runat="server" Caption="" TextboxWidth="300px" />
                        </td>
                    </tr>
                    <tr>
                        <td>Section Colour:</td>
                        <td><telerik:RadColorPicker ID="backgroundColorPicker" runat="server" PaletteModes="HSB" ShowIcon="True" style="margin-left:10px;" /></td> 
                    </tr>
                    <tr>
                        <td>Text Colour:</td>
                        <td><telerik:RadColorPicker ID="textColorPicker" runat="server" PaletteModes="HSB" ShowIcon="True" style="margin-left:10px;" /></td> 
                    </tr>
                </table>
            </icw:General>            
                
            <icw:General runat="server">
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
