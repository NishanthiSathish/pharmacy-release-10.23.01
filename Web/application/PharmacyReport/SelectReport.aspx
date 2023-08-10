<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SelectReport.aspx.cs" Inherits="application_PharmacyReport_SelectReport" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "SelectReport.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Report Selection</title>
    
    <link href="../../style/PharmacyDefaults.css"    rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/jquery-1.3.2.js"                async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"      async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" async></script>
    <script>
        SizeAndCentreWindow("350px", "320px");

        function btnOK_click() 
        {
            window.returnValue = getSelectedRow('gcGrid').attr("index");
            window.close();
        }
    </script>
   
</head>
<body>
    <form id="form1" runat="server">
    <div class="container" style="margin:10px;">
        <asp:Label ID="lbInfo" runat="server" Text="Select report from the list" />
        <br />
        
        <!-- grid  -->
        <br />
        <div>
            <div id="divGrid" style="width:330px;height:200px;" >
                <uc:GridControl ID="gcGrid" runat="server" JavaEventDblClick="btnOK_click" EnterAsDblClick="true" EnableAlternateRowShading="true" EmptyMessage="No reports setup in desktop parameters" />
            </div>
        </div>

        <!-- Spacer -->
        <hr id="hrButtons" runat="server" />
        
        <!-- OK\Cancel Buttons (right) -->
        <div id="divButtons" runat="server" style="float:right; padding-right: 10px;margin-top:5px;">
            <input id="btnOK"     type="button" value="OK"     class="PharmButton" onclick="btnOK_click()"   />&nbsp;
            <input id="btnCancel" type="button" value="Cancel" class="PharmButton" onclick="window.close();" />
        </div>
    </div>         
    </form>
     <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
