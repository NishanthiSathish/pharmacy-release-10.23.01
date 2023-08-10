<%@ Control Language="C#" AutoEventWireup="true" CodeFile="EditList.ascx.cs" Inherits="EditList" %>
<%@ Register src="../SiteColourPanelControl.ascx" tagname="SiteColourPanelControl" tagprefix="uc" %>
<%@ Register src="../SiteNamePanelControl.ascx"   tagname="SiteNamePanelControl"   tagprefix="uc" %>
<div id="divEL" runat="server" enableviewstate="false">
    <!-- Update panel needed for display issues -->
    <asp:UpdatePanel ID="upEL" runat="server">      
    <ContentTemplate>
        <asp:HiddenField id="hfSelectedCellID" runat="server" />
        <asp:HiddenField id="hfAllowMultiCopyStartColumn" runat="server" />
        <asp:HiddenField id="hfAllowMultiCopyEndColumn"   runat="server" />
        <div id="divELContainer" runat="server" class="ScrollTableContainerIE" enableviewstate="false">
            <asp:Table ID="tblEL" runat="server" CellSpacing="0" CellPadding="0" EnableViewState="false" />
        </div>
    </ContentTemplate>
    </asp:UpdatePanel>
</div>