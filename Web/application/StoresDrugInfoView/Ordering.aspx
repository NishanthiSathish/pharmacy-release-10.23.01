<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Ordering.aspx.cs" Inherits="application_StoresDrugInfoView_Ordering" %>

<%@ Register src="controls/GridControl.ascx" tagname="GridControl" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Ordering Information</title>
    
	<link href="../../style/application.css"   rel="stylesheet" type="text/css" />
	<link href="../../style/OCSGrid.css"       rel="stylesheet" type="text/css" />
</head>
<body id="bdyMain" scroll="no" style="width:100%;height:100%;margin:0px;" onkeydown="frameElement.ownerDocument.parentWindow.form_onkeydown(event)">
    <!-- Pending orders grid -->
    <asp:Label ID="lblPendingOrders" runat="server" Text="Pending orders (for last {0} days)" CssClass="PaneCaption" Width="100%"></asp:Label>
    <div style="width: 100%; height: 173px;">
        <uc1:GridControl ID="pendingOrdersGrid" runat="server" />
    </div>      
    
    <br />
    
    <!-- Received orders grid -->
    <asp:Label ID="lblReceivedOrders" runat="server" 
        Text="Received Orders (for last {0} days)" CssClass="PaneCaption" 
        Width="100%"></asp:Label>
    <div style="width: 100%; height: 173px;">
        <uc1:GridControl ID="receivedOrdersGrid" runat="server" />
    </div>      
</body>
</html>
