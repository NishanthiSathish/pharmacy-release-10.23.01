<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Notes.aspx.cs" Inherits="application_PharmacyWardEditor_Notes" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "Notes.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Notes</title>
    <base target=_self>

    <link href="../../style/PharmacyDefaults.css" rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"       rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../sharedscripts/inactivityTimeOut.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script type="text/javascript">
        SizeAndCentreWindow("850px", "600px");
    </script>   
</head>
<body>
    <form id="form1" runat="server" onkeydown="if (event.keyCode == 27) { window.close(); }">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div>
        <asp:UpdatePanel ID="upMain" runat="server" >
        <ContentTemplate>
            <asp:TextBox ID="tbText" runat="server" TextMode="MultiLine" Width="845px" Height="550px" />
            <br />
            <div style="position:absolute;right:10px;bottom:10px;">
                <asp:Button ID="btnOK" runat="server" CssClass="PharmButton" Text="OK" AccessKey="O" OnClick="btnOK_OnClick" />    
            </div>    
        </ContentTemplate>
        </asp:UpdatePanel>   
    </div>        
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
