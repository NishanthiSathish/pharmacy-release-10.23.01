<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ShiftEditor.ascx.cs" Inherits="application_aMMSettings_controls_ShiftEditor" %>
<%@ Register src="../../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>
<div style="width:95%;height:100%;">
    <asp:UpdatePanel ID="updatePanel" runat="server">
    <ContentTemplate>
        <div style="float:left;padding-bottom:8px;">
            Setup the shifts that are available for AMM manufacturing
        </div>
        <div style="float:right;padding-bottom:8px;">
            <input ID="btnAdd"    type="button" class="PharmButton" style="height:23px;padding-right:8px;" accesskey="A" onclick="btnAdd_onclick();"     value="Add"    />
            <input ID="btnEdit"   type="button" class="PharmButton" style="height:23px;padding-right:8px;" accesskey="E" onclick="btnEdit_onclick();"    value="Edit"   />
            <input ID="btnDelete" type="button" class="PharmButton" style="height:23px;padding-right:8px;" accesskey="D" onclick="btnDelete_onclick();"  value="Delete" />
        </div>
        <gc:GridControl id="gcShifts" runat="server" EnableTheming="False" JavaEventDblClick="btnEdit_onclick();" EnterAsDblClick="true" EnableAlternateRowShading="true" AllowMultiSelect="true" />
    </ContentTemplate>
    </asp:UpdatePanel>
</div>
