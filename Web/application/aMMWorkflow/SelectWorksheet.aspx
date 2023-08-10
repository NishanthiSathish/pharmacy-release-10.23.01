<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SelectWorksheet.aspx.cs" Inherits="application_aMMWorkflow_SelectWorksheet" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "SelectWorksheet.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>EMIS Health</title>
    <base target="_self" />

    <link href="../../style/PharmacyDefaults.css" rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"       rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"   defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script type="text/javascript">
        SizeAndCentreWindow("250px", "175px");
    </script>
    
    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body onkeydown="if (event.keyCode==27) { $('#btnCancel').click(); }">
    <form id="form1" runat="server">
    <div style="margin:5px">
    <div class="icw-container-fixed" style="height:95%;">
        <div style="padding-top:8px;padding-left:8px;">
            Select sheet to print.<br />
            <div style="padding-top:5px;padding-left:10px;vertical-align:top;">
                <asp:RadioButtonList ID="lbSheetToPrint" runat="server" Height="75px" AutoPostBack="false" CellSpacing="0" CellPadding="0" />
            </div>
        </div>
          
        <div style="position:absolute;bottom:20px;width:99%;text-align:center;"> 
            <asp:Button ID="btnOk"     runat="server" CssClass="PharmButton" Text="OK"     AccessKey="O" Width="75px" OnClientClick="window.returnValue=$('#lbSheetToPrint [checked]').val();window.close();return false;" />&nbsp;&nbsp;&nbsp;
            <asp:Button ID="btnCancel" runat="server" CssClass="PharmButton" Text="Cancel" AccessKey="C" Width="75px" OnClientClick="window.returnValue=undefined;window.close();return false;" />
        </div>          
    </div>
    </div>         
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
