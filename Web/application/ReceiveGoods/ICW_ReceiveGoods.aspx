<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_ReceiveGoods.aspx.cs" Inherits="application_ReceiveGoods_ICW_ReceiveGoods" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<%@ Register src="controls/GridControl.ascx" tagname="GridControl" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<% 
    //ICW.ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", "") 
    //ICW.ICWParameter("RobotLocation", "Location that the robot handles drugs for e.g. A6", "") 
    //ICW.ICWParameter("OrderNumber", "Order number to reutrns product information for.", "") 
    //ICW.ICWParameter("HideCost", "Determines if prices\\costs values should be hidden from the user.", "No,Yes") 
%>
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%= SessionInfo.SessionID %>';
    var desktopURL = "../sharedscripts/CheckSessionExists.aspx";
    var pageName = "ICW_ReceiveGoods.aspx";
    //alert(sessionId);
    //alert(desktopURL + " " + pageName);
    windowModal_CheckSession(sessionId, desktopURL, "CheckSessionExists" + "|" + pageName);
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Receive Goods</title>
    
    <script type="text/javascript" src="../SharedScripts/jquery-1.3.2.js"></script>
    <script type="text/javascript" src="scripts/ICW_ReceiveGoods.js"></script>    
    
    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
	<link href="../../style/OCSGrid.css"     rel="stylesheet" type="text/css" />
</head>
<body id="gridBody" class="grid_body" onkeydown="form_onkeydown(event)">
    <form id="form1" runat="server">        
        <div style="width: 100%; text-align: center" class="PaneCaption">
            <br />
            <asp:Label ID="lblInfo" runat="server" Font-Bold="True" Text="<Label>" ></asp:Label>
            <br />
        </div>
    
        <div style="text-align: center" >
            <div style="width: 90%; height: 640px;">
                <uc1:gridcontrol ID="orderItemsGrid" runat="server" />
            </div>
        </div>
        
        <div style="text-align: center" >
            <asp:Label ID="lblDeletedItems" runat="server" CssClass="PaneCaptionFont" Visible="False" Text="Received {0} items on lines that have then been deleted." Width="90%"></asp:Label>
        </div>
        
        <br />
        
        <div style="text-align: center" >
            <button id="btnClose" type="button" class="ICWButton" onclick="close_onclick()" style="visibility:<%= isInModal ? "visible" : "hidden" %>" >Close</button>
        </div>        
    </form>
    <iframe id="CheckSessionExists" application="yes" style="display: none;"></iframe>
</body>
</html>
