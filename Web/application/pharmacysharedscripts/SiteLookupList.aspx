<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SiteLookupList.aspx.cs" Inherits="application_pharmacysharedscripts_SiteLookupList" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register Src="../pharmacysharedscripts/PharmacyGridControl.ascx" TagName="GridControl" TagPrefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "SiteLookupList.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Select a Site</title>
    <base target="_self">

    <link href="../../style/PharmacyDefaults.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js" async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" async></script>
    <script type="text/javascript">
        SizeAndCentreWindow("300px", "400px");

        function btnOK_click() {
            var siteID = getSelectedRow('gcGrid').prop('SiteID');
            if (siteID == undefined) {
                $('#errorMsg').text('Select item from the list');   // 107895 27Jan15 XN
            }
            else {
                window.returnValue = siteID;
                window.close();
            }
        }

        function body_onkeydown(event) {
            switch (event.keyCode) {
                case 27: window.close(); break;
                case 13: event.cancelBubble = true; break;  // Need to cancel at this level else will cause post back (and hence not select and close)
            }
        }

        // Called when row is selected in the grid
        // Will post message to parent if embeddedMode
        function pharmacygridcontrol_onselectrow(controlID, rowindex) {
            clearError();
        }

        // Clear error message
        function clearError() {
            $('#errorMsg').html('&nbsp;');
        }
    </script>   
</head>
<body onkeydown="if (event.keyCode == 27) { window.close(); } else if (event.keyCode == 13 ) { event.cancelBubble = true; return false; }">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div style="margin: 10px;">
            <asp:UpdatePanel ID="updatePanel" runat="server">
                <ContentTemplate>
                    <br />
                    <!-- Search results grid -->
                    <div id="divGrid" style="height: 275px;">
                        <uc:GridControl ID="gcGrid" runat="server" JavaEventDblClick="btnOK_click" EnterAsDblClick="true" EnableAlternateRowShading="true" />
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>

            <div id="errorMsg" class="ErrorMessage" style="width: 100%; text-align: center;"></div>

            <!-- Spacer -->
            <hr id="hrButtons" runat="server" />

            <!-- OK\Cancel Buttons (right) -->
            <div id="divButtons" runat="server" style="width: 100%; margin-top: 5px; text-align: center;">
                <input id="btnOK" type="button" value="OK" class="PharmButton" onclick="btnOK_click()" />&nbsp;
            <input id="btnCancel" type="button" value="Cancel" class="PharmButton" onclick="window.close();" />
            </div>
        </div>         
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
