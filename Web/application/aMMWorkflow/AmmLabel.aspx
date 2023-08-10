<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AmmLabel.aspx.cs" Inherits="application_aMMWorkflow_AmmLabel" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.11.3.min.js"  async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script>
        SizeAndCentreWindow("<%= this.printMode != "P" ? 0 : 660 %>px", "<%= this.printMode != "P" ? 0 : 300 %>px");

        function connectToDispensingCtrl(requestId_Prescription, requestId_AmmSupplyRequest, requestID_Dispensing) 
        {
            $(document.getElementById('fraDispensing').document).ready(function()
                {
                    document.getElementById('fraDispensing').contentWindow.RefreshStateForAmm(requestId_Prescription, requestId_AmmSupplyRequest, requestID_Dispensing); 
                });
        }

        function btnLabel_onclick() 
        {
            document.getElementById('fraDispensing').contentWindow.PrintLabel(<%= RequestId %>, <%= numberOfLabels %>, true, true);
            window.returnValue = <%= requestId_Dispensing %>;
            window.close();
        }

        function ReprintLabel(requestId_AmmSupplyRequest, requestID_Dispensing)
        {
            document.getElementById('fraDispensing').contentWindow.ReprintLabel(requestId_AmmSupplyRequest, requestID_Dispensing); 
            window.returnValue = requestID_Dispensing;
        }

        function GetLabelText(requestId_Prescription, requestId_AmmSupplyRequest, requestID_Dispensing)
        {
            $(document.getElementById('fraDispensing').document).ready(function()
                {                    
                    document.getElementById('fraDispensing').contentWindow.RefreshStateForAmm(requestId_Prescription, requestId_AmmSupplyRequest, requestID_Dispensing);
                    window.returnValue = document.getElementById('fraDispensing').contentWindow.GetLabelText(requestId_AmmSupplyRequest); 
                    window.close();
                });
        }
    </script>
</head>
<body scroll="none" style="background-color:#D6E3FF;" onkeydown="if (event.keyCode==13) { $('#btnCancel').click(); }">
    <form id="form1" runat="server" scroll="none">
    <div>
        <div style="width:620px;height:250px;padding-bottom:8px;border:none;">
            <iframe id="fraDispensing" application="yes" style="width:660px;height:250px;border:none;" src="../Dispensing/ICW_Dispensing.aspx?SessionID=<%= SessionInfo.SessionID %>&AscribeSiteNumber=<%= SessionInfo.SiteNumber %>&WindowID=<%= Request["WindowID"] %>&EmbeddedMode=Y&ShowHeader=N<%= this.printMode.ToUpper() == "P" ? "&EnableOnLoad=N" : string.Empty %>"></iframe>
        </div>

        <div style="position:absolute;bottom:15px;width:99%;text-align:center;"> 
            <asp:Button ID="btnLabel"  runat="server" CssClass="PharmButton" Text="Label"  AccessKey="L" Width="75px" OnClientClick="btnLabel_onclick(); return false;"                    />&nbsp;&nbsp;&nbsp;
            <asp:Button ID="btnCancel" runat="server" CssClass="PharmButton" Text="Cancel" AccessKey="C" Width="75px" OnClientClick="window.returnValue=null;window.close();return false;" />
        </div>
    </div>
    </form>
</body>
</html>
