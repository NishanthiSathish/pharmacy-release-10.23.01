<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PNSelectAqueousOrLipid.ascx.cs" Inherits="application_PNViewAndAdjust_controls_PNSelectAqueousOrLipid" %>

<p>Select overage volume to adjust:</p>
<div style="padding-left: 10px;">
    <div>
        <asp:RadioButton ID="rbAqueous" runat="server" GroupName="radOverage" Text="&nbsp;Aqueous" Checked="True" />
    </div>
    <br />
    <div>
        <asp:RadioButton ID="rbLipid" runat="server" GroupName="radOverage" Text="&nbsp;Lipid" />
    </div>
</div>