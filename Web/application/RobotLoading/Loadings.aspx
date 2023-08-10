<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Loadings.aspx.cs" Inherits="application_RobotLoading_Loadings" %>

<%@ Import Namespace="Ascribe.Common" %>

<%@ Register src="controls/GridControl.ascx" tagname="GridControl" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Existing loadings</title>
    
    <script type="text/javascript" src="controls/GridControl.js"></script>
    <script type="text/javascript" src="scripts/loadings.js"></script>
    <script type="text/javascript" src="../SharedScripts/icwfunctions.js"></script>
    <script type="text/javascript" src="../SharedScripts/jquery-1.3.2.js"></script>
    
    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
	<link href="../../style/OCSGrid.css"     rel="stylesheet" type="text/css" />
</head>
<body onload="onload()" scroll="no" onkeydown="frame_onkeydown(event)">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="True"></asp:ScriptManager>
        <asp:Label ID="lblInstructions" runat="server" Text="Displays list of active\completed loadings." CssClass="PaneCaption" Width="100%" Font-Bold="True"></asp:Label>                

        <div ID="robotLoadingItems" style="width: 100%;height: 260px">
            <uc1:gridcontrol ID="robotLoadingItems" runat="server" />
        </div>
              
        <br />    
                    
        <div ID="orderItems" style="width: 100%;height: 260px">
            <uc1:gridcontrol ID="orderItems" runat="server" />
        </div>
        
        <div style="width: 100%; height: 30px; text-align: center">
            <asp:Label id="lbWarning" runat="server" style="color: #FF0000; width: 80%; font-weight: bold;">&nbsp;</asp:Label>
        </div>
                            
        <!-- button -->        
        <div>
            &nbsp;
            <input id="cbIncludeCompleted" type="checkbox" onclick="cbIncludeCompleted_onclick()" />Include completed loadings        
            
            <br /><br />
            
            &nbsp;&nbsp;
            <button id="btnComplete" type="button" class="ICWButton" accesskey="C" onclick="complete_onclick()" disabled="disabled"><u>C</u>omplete</button>
            &nbsp;
            <button id="btnInfo"     type="button" class="ICWButton" accesskey="I" onclick="info_onclick()"   disabled="disabled"><u>I</u>nfo...</button>
            &nbsp;
            <button id="btnClose" type="button" class="ICWButton" onclick="close_onclick()" style="visibility:<%= isInModal ? "visible" : "hidden" %>" >Close</button>
         </div>
    </form>
</body>
</html>
