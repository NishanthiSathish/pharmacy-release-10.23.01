<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PNSelectGlucoseProduct.ascx.cs" Inherits="application_PNViewAndAdjust_controls_PNSelectGlucoseProduct" %>
<%@ Register src="../../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>
<asp:HiddenField ID="hfSelectedProductPNCode"   runat="server" />
<asp:HiddenField ID="hfSelectedIngredient"      runat="server" />
<asp:HiddenField ID="hfTotalValue"              runat="server" />
<asp:HiddenField ID="hfRequestedNoMixing"       runat="server" />
<asp:HiddenField ID="hfUseCachedProcessorCopy"  runat="server" />
<asp:HiddenField ID="hfIncludeNoMixOption"      runat="server" />
        
<div onkeydown="PNSelectGlucoseProduct_onkeydown(event)">
    <asp:Label ID="lbCaption" runat="server" Text="Label"></asp:Label>
    <br />
    <br />
    <div style="width: 99%; height: 77%;">
        <gc:GridControl id="gridSelectGlucoseProduct" runat="server" EnableViewState="False" EnableTheming="False" JavaEventDblClick="if (typeof(ProgressWizard) == 'function') { ProgressWizard(); }" CellSpacing="0" CellPadding="2" />
    </div>
    <br />
    <div style="width:100%;text-align:center;">
        <asp:CustomValidator ID="gridSelectProductError" runat="server" ErrorMessage="Select item from list" CssClass="ErrorMessage"  ClientValidationFunction="PNSelectGlucoseProduct_validation" EnableViewState="false"></asp:CustomValidator>
        <asp:Label ID="lbValidationError" runat="server" Text="&nbsp;" CssClass="ErrorMessage"></asp:Label>
    </div>
    <asp:CheckBox ID="cbMixing" runat="server"/>
</div>        