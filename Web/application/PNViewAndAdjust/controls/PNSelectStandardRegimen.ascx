<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PNSelectStandardRegimen.ascx.cs" Inherits="application_PNViewAndAdjust_controls_PNSelectStandardRegimen" %>
<%@ Register src="../../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>
<asp:HiddenField ID="hfSelectedStandardRegimenID"    runat="server" />
<asp:HiddenField ID="hfWarnedUsersAboutRegimenItems" runat="server" />
        
<p>Select standard regimen<br /> 
(or choose to auto populate from regimen requirements)</p>
<div style="width: 100%; height: 80%;">
    <gc:GridControl id="gridSelectStandardRegimen" runat="server" EnableViewState="False" EnableTheming="False" CellSpacing="0" CellPadding="2" />
</div>
<br />
<div style="width:100%;text-align:center;">
    <asp:CustomValidator ID="gridStandardRegimenError" runat="server" ErrorMessage="Select item from list" CssClass="ErrorMessage"  ClientValidationFunction="PNSelectStandardRegimen_validation" EnableViewState="false"></asp:CustomValidator>
    <asp:Label ID="lbValidationError" runat="server" Text="&nbsp;" CssClass="ErrorMessage"></asp:Label>
</div>