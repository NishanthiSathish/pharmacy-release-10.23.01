<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SupplierInformation.aspx.cs" Inherits="application_StoresDrugInfoView_SupplierInformation" %>

<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx"       tagname="GridControl"       tagprefix="uc1" %>
<%@ Register src="../pharmacysharedscripts/PharmacyLabelPanelControl.ascx" tagname="LabelPanelControl" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Supplier Information</title>
    
    <script src="../sharedscripts/lib/jquery-1.11.3.min.js"         type="text/javascript" defer></script>
    <script src="../pharmacysharedscripts/PharmacyGridControl.js"   type="text/javascript" defer></script>
    <script src="scripts/SupplierInformation.js"                    type="text/javascript" async></script>
    
	<link href="../../style/application.css"            rel="stylesheet" type="text/css" />
	<link href="../../style/PharmacyGridControl.css"    rel="stylesheet" type="text/css" />
    <link href="../../style/LabelPanelControl.css"      rel="stylesheet" type="text/css" />
</head>
<body id="bdyMain" scroll="no" style="width:100%;height:100%;margin:0px;" onkeydown="frameElement.ownerDocument.parentWindow.form_onkeydown(event)">
    <!-- Product info -->
    <asp:Label ID="lblProductInfo" runat="server" Text="Product Info" CssClass="PaneCaption" Width="100%"></asp:Label>
    <div style="width: 100%;">
        <uc1:LabelPanelControl ID="productInfoLabelPanel" runat="server" />
    </div>

    <br />
    
    <!-- Product supplier -->
    <asp:Label ID="lblProductSupplier" runat="server" Text="Product suppliers" CssClass="PaneCaption" Width="100%"></asp:Label>
    <div style="width: 100%; height: 193px;">
        <uc1:GridControl ID="productSuppliersGrid" runat="server" JavaEventDblClick="gridcontrol_ondblclick" EnterAsDblClick="true" />
    </div>
</body>
</html>
