<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PNSelectProduct.ascx.cs" Inherits="application_PNViewAndAdjust_controls_PNSelectProduct" %>
<%@ Register src="../../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>
<asp:HiddenField ID="hfSelectedProductPNCode" runat="server" />

<asp:Label ID="lbCaption" runat="server" Text="Label"></asp:Label><br />
<br />
<div style="width: 95%; height: 81%;">
    <gc:GridControl id="gridSelectProduct" runat="server" EnableViewState="False" EnableTheming="False" JavaEventDblClick="if (typeof(ProgressWizard) == 'function') { ProgressWizard(); }" CellSpacing="0" CellPadding="2" />
</div>
<br />
<div style="width:100%;text-align:center;">
    <asp:CustomValidator ID="gridSelectProductError" runat="server" ErrorMessage="Select item from list" CssClass="ErrorMessage"  ClientValidationFunction="PNSelectProduct_validation" EnableViewState="false"></asp:CustomValidator>
</div>