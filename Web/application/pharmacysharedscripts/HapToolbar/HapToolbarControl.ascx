<%@ Control Language="C#" AutoEventWireup="true" CodeFile="HapToolbarControl.ascx.cs" Inherits="HapToolbarControl" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<div id="<%= this.ID %>">
    <telerik:RadToolBar ID="radToolbar" runat="server" Skin="Office2007" OnClientButtonClicked="function (sender, args) {eval(args.get_item().get_commandName()); }">
        <Items />
    </telerik:RadToolBar>
</div>