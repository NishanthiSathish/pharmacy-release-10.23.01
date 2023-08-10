<%@ Control Language="C#" AutoEventWireup="true" CodeFile="QuesScrl.ascx.cs" Inherits="QuesScrl" %>
<%@ Implements Interface="ascribe.pharmacy.quesscrllayer.IQSViewControl"  %>
<%@ Register src="../SiteColourPanelControl.ascx" tagname="SiteColourPanelControl" tagprefix="uc" %>
<%@ Register src="../SiteNamePanelControl.ascx"   tagname="SiteNamePanelControl"   tagprefix="uc" %>
<style>
</style>
<div id="divGPE">
    <asp:UpdatePanel ID="upGPE" runat="server">
    <ContentTemplate>
        <asp:HiddenField ID="hfCategory"                runat="server" />
        <asp:HiddenField ID="hfSectionView"             runat="server" />
        <asp:HiddenField ID="hfSectionData"             runat="server" />
        <asp:HiddenField ID="hfKeyViewIndex"            runat="server" />    
        <asp:HiddenField ID="hfSiteIDs"                 runat="server" />
        <asp:HiddenField ID="hfForceReadOnlyPerSite"    runat="server" />
        <asp:HiddenField ID="hfRequiredDataFields"      runat="server" />
        <asp:HiddenField ID="hfQSProcessor"             runat="server" />
        <asp:HiddenField ID="hfAllowDisplayDifferences" runat="server" />  
        <asp:HiddenField ID="hfShowHeaderRow"           runat="server" />    
        <asp:HiddenField ID="hfSelectedCellID"          runat="server" />      
        <asp:HiddenField ID="hfSimpleEditMode"          runat="server" />

        <div id="divGPEContainer" runat="server" class="ScrollTableContainerIE">
            <asp:Table ID="tblGPE" runat="server" onkeydown="tblQuesScrlMain_onkeydown();" CellSpacing="0" CellPadding="0" />
        </div>
    </ContentTemplate>
    </asp:UpdatePanel>
</div>
