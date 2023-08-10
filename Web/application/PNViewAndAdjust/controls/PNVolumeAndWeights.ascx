<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PNVolumeAndWeights.ascx.cs" Inherits="application_PNViewAndAdjust_controls_PNVolumeAndWeights" %>
<%@ Register src="../../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>

<div style="width: 95%; height: 77%;">
    <table id="tableVolumeAndWeights" runat="server" style="width: 100%;" cellpadding="0" cellspacing="0">
        <thead>
            <tr>
                <td style="text-align:left; width:30%; font-weight: bold;">Product</td>
                <td colspan="2" style="text-align:center; width:25%; font-weight: bold;">Regimen</td>
                <td colspan="2" style="text-align:center; width:25%; font-weight: bold;">Including Overage</td>
            </tr>
            <tr>
                <td></td>
                <td style="text-align:center; width:15%; font-weight: bold;">Volume</td>
                <td style="text-align:center; width:10%; font-weight: bold;">Weight</td>
                <td style="text-align:center; width:15%; font-weight: bold;">Volume</td>
                <td style="text-align:center; width:10%; font-weight: bold;">Weight</td>
            </tr>
        </thead>
        <tbody>
        </tbody>
    </table>
</div>