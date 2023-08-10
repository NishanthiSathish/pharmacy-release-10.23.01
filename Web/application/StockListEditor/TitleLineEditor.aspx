<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TitleLineEditor.aspx.cs" Inherits="application_StockListEditor_TitleLineEditor" %>
<%@ Register TagPrefix="icw" Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "TitleLineEditor.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Stock List Title Line Editor</title>
    <base target="_self" />

    <link href="../../style/icwcontrol.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script type="text/javascript">
        SizeAndCentreWindow('670px', '210px');
    </script>    
    <style type="text/css">html, body{height:98%}</style>  <!-- Ensure page is full height of screen -->    
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager runat="server" />
    <div>
        <icw:Container ID="container" runat="server" FillBrowser="true" Height="190px">

        <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>
            <icw:Form ID="frmMain" runat="server" CaptionZoneWidthPc="12" ControlZoneWidthPc="60" ErrorMessageZoneWidthPc="22" >
                <icw:ShortText ID="tbTitle" runat="server" Caption="Description" TextboxWidth="345px" MaxCharacters="1" />
            </icw:Form>

            <icw:General ID="General1" runat="server">
                <div style="position:absolute; bottom:45px; right:340px">
                    <icw:Button ID="btnOK"     runat="server" CssClass="PharmButton" ShortcutKey="O" Caption="OK" OnClick="btnOK_OnClick" />
                </div>
                <div style="position:absolute; bottom:45px; left:340px">
                    <icw:Button ID="btnCancel" runat="server" CssClass="PharmButton" ShortcutKey="C" Caption="Cancel" OnClick="btnCancel_OnClick" />
                </div>
            </icw:General>
        </ContentTemplate>
        </asp:UpdatePanel>

        </icw:Container>
    </div>        
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
