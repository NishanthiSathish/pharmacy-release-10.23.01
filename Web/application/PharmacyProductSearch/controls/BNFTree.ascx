<%@ Control Language="C#" AutoEventWireup="true" CodeFile="BNFTree.ascx.cs" Inherits="application_PharmacyProductSearch_controls_BNFTree" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<div id="divBNFTree" onClientNodeSelected="<%= this.OnClientNodeSelected %>">
    <asp:HiddenField ID="hfSelectedBNFValue" runat="server" />
    <telerik:RadTreeView ID="BNFtree" runat="server" OnClientNodeClicking="BNFtree_onNodeClicking" Height="100%" Skin="Web20" BackColor="White" MultipleSelect="false"  />
</div>