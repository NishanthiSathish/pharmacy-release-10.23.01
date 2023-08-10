<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PNSummaryView.ascx.cs" Inherits="application_PNViewAndAdjust_controls_SummaryView" %>
<%@ Register src="../../pharmacysharedscripts/PharmacyGridControl.ascx"       tagname="GridControl" tagprefix="gc" %>
<%@ Register src="../../pharmacysharedscripts/PharmacyLabelPanelControl.ascx" tagname="LabelPanel"  tagprefix="lp" %>

<asp:HiddenField ID="hfRequestID" runat="server" />
<asp:Button CssClass="TabSelected" ID="btnPrescriptionDetails"  runat="server" Text="Prescription Details"   onclick="tab_OnClick" />
<asp:Button CssClass="Tab"         ID="btnClinicalSummary"      runat="server" Text="Clinical Summary"       onclick="tab_OnClick" />
<asp:Button CssClass="Tab"         ID="btnRegimenSummary"       runat="server" Text="Regimen Summary"        onclick="tab_OnClick" />
<asp:MultiView ID="multiView" runat="server">
    <asp:View ID="vPrescriptionDetails" runat="server">
        <div style="height:90%;width:90%;padding-top:10px">
            <lp:LabelPanel ID="lpPrescriptionDetails" runat="server" />
        </div>
    </asp:View>
    <asp:View ID="vClinicalSummary" runat="server">
        <div style="height:90%;width:90%;padding-top:10px">
            <lp:LabelPanel ID="lpClinicalSummary" runat="server" />
        </div>
    </asp:View>
    <asp:View ID="vRegimenSummary" runat="server">
        <div style="height:85%;width:100%;padding-top:5px;">
            Total of all ingredients in current regimen (24 Hours)<br />
            <span id="lbRegimenSummaryTotals" runat="server" /><br />
            <div style="width:100%;text-align:center;">
                <div style="text-align:left;"><gc:GridControl ID="gcRegimenSummary" runat="server" FontSize_Cell="11px" CellPadding="0" CellSpacing="0" /></div>
            </div>
        </div>
    </asp:View>
</asp:MultiView>