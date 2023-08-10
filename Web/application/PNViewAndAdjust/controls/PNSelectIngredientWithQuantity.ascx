<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PNSelectIngredientWithQuantity.ascx.cs" Inherits="application_PNViewAndAdjust_controls_PNSelectIngredientWithQuantity" %>
<%@ Register src="../../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>
<asp:HiddenField ID="hfSelectedIngredientDBName" runat="server" />

<asp:Label ID="lbCaption" runat="server" Text="Label"></asp:Label><br />
<br />
<div style="width: 99%; height: 85%;">
    <gc:GridControl id="gridSelectIngredient" runat="server" EnableViewState="False" EnableTheming="False" JavaEventDblClick="if (typeof(ProgressWizard) == 'function') { ProgressWizard(); }" CellSpacing="0" CellPadding="2" />
</div>
<br />
<div style="width:100%;text-align:center;">
    <asp:CustomValidator ID="gridSelectIngredientError" runat="server" ErrorMessage="Select item from list" CssClass="ErrorMessage"  ClientValidationFunction="PNSelectIngredient_validation" EnableViewState="false"></asp:CustomValidator>
</div>