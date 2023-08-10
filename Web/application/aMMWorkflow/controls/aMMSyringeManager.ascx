<%@ Control Language="C#" AutoEventWireup="true" CodeFile="aMMSyringeManager.ascx.cs" Inherits="application_aMMWorkflow_controls_aMMSyringeManager" %>
<%@ Register src="../../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>
<link href="../../style/PharmacyGridControl.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" async></script>    
<div id="divAMMSyringeManager" runat="server" style="margin:10px;">
    <div>
        The volume require is greater than can be delivered in one syringe.<br />
        Use the options below to determine how to produce the require syringe quantity.
    </div>
    <table cellpadding="8">
        <tr>
            <td><asp:RadioButton ID="rbEven" runat="server" Text="Split Volume Equally" GroupName="rb" AutoPostBack="False" /></td>
            <td><asp:Image runat="server" ImageUrl="../images/EvenSyringeSplit.png" /></td>
        </tr>            
        <tr>
            <td><asp:RadioButton ID="rbFullAndPart" runat="server" Text="Full and Part Split" GroupName="rb" AutoPostBack="False" /></td>
            <td><asp:Image runat="server" ImageUrl="../images/FullPartSyringeSplit.png" /></td>
        </tr>            
    </table>
    <br />
    <asp:Label ID="lbTotalPerDose" runat="server" /><br />
    <br />
    <div style="width:400px;text-align:center;">
        <div id="divEven" style="width:250px;display:none;">
            <uc:GridControl ID="gridEven" runat="server" EnableAlternateRowShading="true" />
        </div>
        <div id="divFullAndPart" style="width:250px;display:none;">
            <uc:GridControl ID="gridFullAndPart" runat="server" EnableAlternateRowShading="true" />
        </div>
    </div>
</div>
