<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PNSelectIngredient.ascx.cs" Inherits="application_PNViewAndAdjust_controls_PNSelectIngredient" %>
<asp:Label ID="lbCaption" runat="server" Text="Label"></asp:Label>
<br /><br />
<div style="padding-left: 5px;">
    <asp:ListBox ID="lbIngredients" runat="server" Height="85%" Width="99%" onkeypress="if (event.keyCode == 13) $('#wizardAddProduct_StepNavigationTemplateContainerID_StepNextButton').click();" ondblclick="if (typeof(ProgressWizard) == 'function') { ProgressWizard(); }" ></asp:ListBox>
</div>
