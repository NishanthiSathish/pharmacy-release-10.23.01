<%@ Page Language="C#" AutoEventWireup="true" CodeFile="HonKongPatientEpisodeEditor.aspx.cs" Inherits="application_HongKong_HonKongPatientEpisodeEditor" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Extra Patient Info</title>
    <base target="_self" />
        
    <link rel="stylesheet" type="text/css" href="../../style/application.css"/>
        
    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"   async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>

    <script type="text/javascript">
        SizeAndCentreWindow('370px', '170px');
    </script>

    <style type="text/css">html, body{height:98%}</style>  <!-- Ensure page is full height of screen -->    
</head>
<body onkeydown="if (event.keyCode == 13) { $('#btnOK').click(); }">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="scriptManager" runat="server"></asp:ScriptManager>
    <div>
        <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>
            <div style="padding:10px;margin:10px;border: solid 1px black;background-color: white;width:325px;">
                <table>
                    <tr>
                        <td width="130">Chinese name:</td>
                        <td><asp:TextBox ID="tbChineseName" runat="server" maxlength="10" Width="175px" /></td>
                    </tr>
                    <tr>
                        <td>Preferred language:</td>
                        <td><asp:DropDownList ID="ddlPreferredLanguage" runat="server" CssClass="MandatoryField" Width="175px" /></td>
                    </tr>
                    <tr>
                        <td>Patient category:</td>
                        <td><asp:DropDownList ID="ddlPatientCategory" runat="server" Width="175px" /></td>
                    </tr>
                </table> 
            </div>

            <div style="position:absolute;bottom:15px;width:99%;text-align:center;"> 
                <asp:Button ID="btnOK" runat="server" CssClass="ICWButton" Text="OK" Width="60px" OnClick="btnOK_OnClick" AccessKey="O" />
            </div>

            <div style="position:absolute;bottom:15px;right:25px;width:160px;text-align:right;z-index:99"> 
                <asp:Button ID="btnCancel" runat="server" CssClass="ICWButton" Text="Cancel" AccessKey="C" Width="60px" OnClientClick="window.returnValue=null;window.close();return false;" />
            </div>                  
        </ContentTemplate>   
        </asp:UpdatePanel>
    </div>
    </form>
</body>
</html>
