<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Contracts.aspx.cs" Inherits="application_StoresDrugInfoView_Contracts" %>

<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Supplier Contract Updates</title>

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.11.3.min.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"></script>

    <link href="../../style/application.css"         rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css" rel="stylesheet" type="text/css" />
</head>
<body id="bdyMain" scroll="no" style="width:100%;height:100%;margin:0px;" onkeydown="frameElement.ownerDocument.parentWindow.form_onkeydown(event)">
    <form id="form1" runat="server">
    <div>
        <!-- Upcoming\\active contracts -->
        <asp:Label ID="lblActiveAndUpcoming" runat="server" Text="Active and upcoming contracts" CssClass="PaneCaption" Width="100%" />
        <div style="width: 100%; height: 173px;">
            <uc1:GridControl ID="activeAndUpcomingGrid" runat="server" EnableAlternateRowShading="true" SortableColumns="true" />
        </div>      
    
        <br />
    
        <!-- Expired contracts -->
        <asp:Label ID="lblHistoricalContracts" runat="server" Text="Expired contracts (for last {0} years)" CssClass="PaneCaption" Width="100%" />
        <div style="width: 100%; height: 173px;">
            <uc1:GridControl ID="expiredContractsGrid" runat="server" EnableAlternateRowShading="true" SortableColumns="true" />
        </div>      
    </div>
    </form>
</body>
</html>
