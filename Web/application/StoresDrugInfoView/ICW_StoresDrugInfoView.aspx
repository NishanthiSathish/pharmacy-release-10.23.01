<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_StoresDrugInfoView.aspx.cs" Inherits="application_StoresDrugInfoView_ICW_StoresDrugInfoView" %>

<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<% 
//ICW.ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", "") 
//ICW.ICWParameter("HideCost", "Determines if prices\\costs values should be hidden from the user.", "No,Yes") 
%>
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "ICW_StoresDrugInfoView.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Stores Drug Info View</title>

    <script type="text/javascript" src="../SharedScripts/jquery-1.3.2.js" async></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js" defer></script>
    <script type="text/javascript" src="../sharedscripts/icw.js" defer></script>
    <script type="text/javascript" src="scripts/ICW_StoresDrugInfoView.js" async></script> 
    
    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
</head>
<body id="gridBody" class="grid_body" style="height: 95%" onkeydown="form_onkeydown(event)">
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfKeyPress" runat="server" />
        <div>
            <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
            <asp:Label ID="lblProductDescription" runat="server" Text="&amp;nbsp;" CssClass="PaneCaption" Width="100%" Font-Bold="True"></asp:Label>
            <asp:Label ID="lblSiteDescription" runat="server" Text="&amp;nbsp;" CssClass="PaneCaption" Width="100%" Font-Bold="True"></asp:Label>

            <br />

            <!-- View tabs -->
            <asp:UpdatePanel ID="upSelectedTab" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <!-- tabs -->
                    <asp:Button CssClass="TabSelected" ID="btnOrdering" runat="server" Text="Ordering" OnClick="btnOrdering_Click" />
                    <asp:Button CssClass="Tab" ID="btnRequisitions" runat="server" Text="Requisitions" OnClick="btnRequisitions_Click" />
                    <asp:Button CssClass="Tab" ID="btnSupplierInformation" runat="server" Text="Supplier Information" OnClick="btnSupplierInformation_Click" />
                    <asp:Button CssClass="Tab" ID="btnSummaryInformation" runat="server" Text="Summary Information" OnClick="btnSummaryInformation_Click" />
                    <asp:Button CssClass="Tab" ID="btnWardStock" runat="server" Text="Ward Stock" OnClick="btnWardStock_Click" />
                    <asp:Button CssClass="Tab" ID="btnContracts" runat="server" Text="Contracts" OnClick="btnContracts_Click" />

                    <!-- Selected tab page -->
                    <iframe width="100%" height="395px" id="fraSelectedTab" src="<%= GetSelectedTabURL() %>?SessionID=<%= SessionInfo.SessionID %>&SiteID=<%= SessionInfo.SiteID %>&NSVCode=<%= NSVCode %>&HideCost=<%= (moneyDisplayType == MoneyDisplayType.Show) ? "0" : "1" %>" frameborder="0"></iframe>
                </ContentTemplate>
            </asp:UpdatePanel>            
            <!-- Spacer -->
            <hr />

            <iframe width="100%" height="245px" id="fraProductInfoPanel" frameborder="0" src="ProductInfoPanel.aspx?SessionID=<%= SessionInfo.SessionID %>&SiteID=<%= SessionInfo.SiteID %>&NSVCode=<%= NSVCode %>&HideCost=<%= (moneyDisplayType == MoneyDisplayType.Show) ? "0" : "1" %>&Robot=<%= robotName %>"></iframe>
         <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
        </div>
    </form>
</body>
</html>
