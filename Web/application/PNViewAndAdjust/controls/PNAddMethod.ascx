<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PNAddMethod.ascx.cs" Inherits="application_PNViewAndAdjust_controls_PNAddMethod" %>

<p>Select add method:</p>
<div style="padding-left: 10px;">
    <asp:RadioButton ID="rbAddBymlProduct"  runat="server" GroupName="radAddMethod" Text="&nbsp;Add by ml Product" Checked="True" /><br /><br />
    <asp:RadioButton ID="rbAddByProduct"    runat="server" GroupName="radAddMethod" Text="&nbsp;Add by Product"    /><br /><br />
    <asp:RadioButton ID="rbAddByIngredient" runat="server" GroupName="radAddMethod" Text="&nbsp;Add by Ingredient" /><br /><br />
</div>