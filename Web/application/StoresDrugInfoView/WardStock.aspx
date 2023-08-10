<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WardStock.aspx.cs" Inherits="application_StoresDrugInfoView_WardStock" %>

<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Ward Stock</title>
    
	<link href="../../style/application.css"          rel="stylesheet" type="text/css" />
	<link href="../../style/PharmacyGridControl.css"  rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" async></script>
</head>
<body id="bdyMain" scroll="no" style="width:100%;height:100%;" onkeydown="frameElement.ownerDocument.parentWindow.form_onkeydown(event)">
    <asp:Label ID="lblWardStock" runat="server" Text="Ward Stock info" CssClass="PaneCaption" Width="100%"></asp:Label>
    <div style="width: 100%; height: 370px;">
        <uc:GridControl ID="wardStockGrid" runat="server" EmptyGridMessage="Not stocked on any wards." EnableAlternateRowShading="true" CellPadding="0" CellSpacing="2" SortableColumns="true" />
    </div>
</body>
</html>
