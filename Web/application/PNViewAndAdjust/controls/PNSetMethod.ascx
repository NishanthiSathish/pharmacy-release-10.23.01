<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PNSetMethod.ascx.cs" Inherits="application_PNViewAndAdjust_controls_PNSetMethod" %>

<p>Select item to set:</p>
<div style="padding-left: 10px;">
    <asp:RadioButton ID="rbSetByVolume"   runat="server" GroupName="radSetMethod" Text="&nbsp;Volume"   Checked="True"  /><br /><br />
    <asp:RadioButton ID="rbSetByCalories" runat="server" GroupName="radSetMethod" Text="&nbsp;Calories"                 /><br /><br />
    <asp:RadioButton ID="rbSetByGlucose"  runat="server" GroupName="radSetMethod" Text="&nbsp;Glucose by %"             /><br /><br />
</div>