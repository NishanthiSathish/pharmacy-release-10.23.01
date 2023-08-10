<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DrugLineEditor.aspx.cs" Inherits="application_StockListEditor_DrugLineEditor" %>
<%@ Register TagPrefix="icw" Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "DrugLineEditor.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Stock List Drug Line Editor</title>
    <base target="_self" />

    <link href="../../style/icwcontrol.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script type="text/javascript" src="script/DrugLineEditor.js"                   async></script>
    <script type="text/javascript">
        SizeAndCentreWindow('670px', '375px');
    </script>
    
    <style type="text/css">html, body{height:98%}</style>  <!-- Ensure page is full height of screen -->    
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager runat="server" />
    <div>
        <icw:Container ID="container" runat="server" FillBrowser="true" Height="326px">
            <icw:Form ID="frmDrugInfo" runat="server" Caption="Stock list line details">
                <icw:Label ID="lbInfo" runat="server" />
            </icw:Form>

            <asp:UpdatePanel ID="upMain" runat="server">
            <ContentTemplate>

            <icw:Form runat="server" CaptionZoneWidthPc="10" ControlZoneWidthPc="68" ErrorMessageZoneWidthPc="16" >
                <icw:ShortText ID="tbDescription" runat="server" Caption="Description" Mandatory="true" TextboxWidth="400px" MaxCharacters="1" />
                <icw:Number    ID="numPackSize"   runat="server" Caption="Pack Size"   Mandatory="true" Mode="Integer"       MaxCharacters="1" />
                <asp:ImageButton ID="imgRevertDescription" runat="server" OnClick="imgRevert_OnClick" ToolTip="Click to revert to product description" Width="16" Height="16" ImageUrl="~/images/User/undo.gif" style="position:absolute;" />
                <asp:ImageButton ID="imgRevertPackSize"    runat="server" OnClick="imgRevert_OnClick" ToolTip="Click to revert to product pack size"   Width="16" Height="16" ImageUrl="~/images/User/undo.gif" style="position:absolute;" />
            </icw:Form>

            <icw:Form runat="server" CaptionZoneWidthPc="10" ControlZoneWidthPc="68" ErrorMessageZoneWidthPc="16" >
                <icw:Number    ID="numQuantity" runat="server" Caption="Quantity" Mode="Integer" Mandatory="true" MaxCharacters="1" />
                <icw:List      ID="lDLOLabel"   runat="server" ShowClearOption="false" />
                <icw:ShortText ID="tbComment"   runat="server" Caption="Comment" TextboxWidth="345px" MaxCharacters="1" />
            </icw:Form>            

            <icw:General runat="server">
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
