<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Orders.aspx.cs" Inherits="application_RobotLoading_Orders" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Import Namespace="ascribe.pharmacy.pharmacydatalayer" %>

<%@ Register src="controls/GridControl.ascx" tagname="GridControl" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Orders Available for Robot Loading</title>

    <script type="text/javascript" src="controls/GridControl.js"></script>
    <script type="text/javascript" src="scripts/orders.js"></script>
    <script type="text/javascript" src="../SharedScripts/icwfunctions.js"></script>
    <script type="text/javascript" src="../SharedScripts/jquery-1.3.2.js"></script>
    
    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
	<link href="../../style/OCSGrid.css"     rel="stylesheet" type="text/css" />
</head>
<body id="gridBody" scroll="no" onkeydown="frame_onkeydown(event)" style="width:100%;height:100%;margin:0px;">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <asp:Label ID="lblInstructions" runat="server" CssClass="PaneCaption" Width="100%" Font-Bold="True">Select orders to go on a new loading.</asp:Label>
        <asp:Label ID="Label1" runat="server" CssClass="PaneCaption" Width="100%">&nbsp;If an order does not appear in the list it may already exist on an active loading, does not contain a drug for this robot location, or requires batch number or expiry date.</asp:Label>
    
        <div ID="orderItems" style="width: 100%;height: 515px">
            <uc1:gridcontrol ID="orderItems" runat="server" />
        </div>
              
        <div style="width: 100%; height: 50px; text-align: center">
            <asp:Label id="lbWarning" runat="server" style="color: #FF0000; width: 80%; font-weight: bold;">&nbsp;</asp:Label>
        </div>
                            
        <div style="height: 26px;">
            &nbsp;
            <button id="btnCreate" type="button" class="ICWButton" accesskey="C" onclick="create_onclick()" disabled="disabled"><u>C</u>reate...</button>
            &nbsp;
            <button id="btnInfo"   type="button" class="ICWButton" accesskey="I" onclick="info_onclick()"  disabled="disabled"><u>I</u>nfo...</button>
            &nbsp;
            <button id="btnClose" type="button" class="ICWButton" onclick="close_onclick()" style="visibility:<%= isInModal ? "visible" : "hidden" %>" >Close</button>
        </div>      
    </form>
</body>
</html>
