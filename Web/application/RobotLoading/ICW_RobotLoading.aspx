<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_RobotLoading.aspx.cs" Inherits="application_RobotLoading_ICW_RobotLoading" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<% 
    //ICW.ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", "") 
    //ICW.ICWParameter("RobotLocation", "Location that the robot handles drugs for e.g. A6", "") 
    //ICW.ICWParameter("HideCost", "Determines if prices\\costs values should be hidden from the user.", "No,Yes") 
%>
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%= SessionInfo.SessionID %>';
    var desktopURL = "../sharedscripts/CheckSessionExists.aspx";
    var pageName = "ICW_RobotLoading.aspx";
    //alert(sessionId);
    //alert(desktopURL + " " + pageName);
    windowModal_CheckSession(sessionId, desktopURL, "CheckSessionExists" + "|" + pageName);
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Robot Loading Information</title>
    
    <script type="text/javascript" src="scripts/ICW_RobotLoading.js"></script>    
    
    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
</head>
<body id="gridBody" class="grid_body" onkeydown="form_onkeydown(event)">
    <form id="form1" runat="server">
        <div>
            <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
            <asp:Label ID="lblInfo" runat="server" Text="Robot loading information for site {0} and location {1}." CssClass="PaneCaption" Width="100%" Font-Bold="True"></asp:Label>                

            <br />
                        
            <!-- View tabs -->
            <asp:UpdatePanel ID="upSelectedTab" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <!-- tabs -->        
                    <asp:Button CssClass="TabSelected" ID="btnOrders"   runat="server" Text="Orders"    onclick="btnOrders_Click" />
                    <asp:Button CssClass="Tab"         ID="btnLoadings" runat="server" Text="Loadings"  onclick="btnLoadings_Click" />

                    <!-- Selected tab page -->
   		            <iframe width="100%" height="640px" id="fraSelectedTab" src="<%= GetSelectedTabURL() %>?SessionID=<%= SessionInfo.SessionID %>&SiteID=<%= SessionInfo.SiteID %>&RobotLocation=<%= robotLocation %>&HideCost=<%= (moneyDisplayType == MoneyDisplayType.Show) ? "0" : "1" %>&IsInModal=<%= isInModal.ToString() %>" frameborder="0"></iframe>
	            </ContentTemplate>
            </asp:UpdatePanel>                    
    
            <br />
        </div>
    </form>
    <iframe id="CheckSessionExists" application="yes" style="display: none;"></iframe>
</body>
</html>
