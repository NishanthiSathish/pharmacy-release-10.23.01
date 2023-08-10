<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PNAskAdjustIng.ascx.cs" Inherits="application_PNViewAndAdjust_controls_PNAskAdjustIng" %>
<div onkeydown="PNAskAdjustIng_onkeydown(event)">
    <asp:Label ID="lbMessage" runat="server" Text="Label"></asp:Label>
    <br />

    <asp:Panel ID="pnIngredientsToAdjust" runat="server">
        <p id="lbGeneralMessage" runat="server">Following have been altered:</p>
        <div style="padding-bottom: 10px; padding-left: 10px;">
            <asp:CheckBox ID="adjustSodium"    runat="server" Font-Size="12px" /><br />
            <asp:CheckBox ID="adjustPotassium" runat="server" Font-Size="12px" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnNonAdjustableIngredients" runat="server">
        <p>Following ingredients can not be adjusted to previous level as not enough product to compensate for increase:</p>
        <asp:BulletedList ID="nonAdjustableIngredients" runat="server" Font-Size="14px"></asp:BulletedList>
    </asp:Panel>
</div>