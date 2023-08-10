<%@ Control Language="C#" AutoEventWireup="true" CodeFile="aMMVolumeCalculation.ascx.cs" Inherits="application_aMMWorkflow_controls_aMMVolumeCalculation" %>
<style>
    .AMMVolCalLabel 
    {
        font-weight: bold;    
    }
    
    .AMMVolCalValue 
    {
        font-weight: normal;
    }
</style>
<div id="divAMMVolumeCalculation" runat="server" style="margin:10px;">
<asp:HiddenField ID="hfValidCalculation" runat="server" />
<asp:HiddenField ID="hfNSVCode" runat="server" />
<table>
    <colgroup>
        <col style="width:235px" />
        <col style="width:20px"  />
        <col style="width:60px"  />
        <col style="width:60px"  />
        
        <col style="width:60px" />
        <col style="width:50px" />
        <col style="width:60px" />
        <col style="width:50px" />
    </colgroup>       
    <tr id="trPrescriptionDose" runat="server">
        <td class="AMMVolCalLabel">Prescription dose</td>
        <td />
        <td id="tdPrescriptionDose"      runat="server" />
        <td id="tdPrescriptionDoseUnits" runat="server" />
    </tr> 
    <tr>
        <td class="AMMVolCalLabel">Drug dose</td>
        <td />
        <td id="tdDrugDose"      runat="server" />
        <td id="tdDrugDoseUnits" runat="server" />
    </tr>
    <tr>
        <td class="AMMVolCalLabel">Initial drug concentration<br /><span id="spanInitialDrugConcDetail" runat="server" class="AMMVolCalValue">&nbsp;</span></td>
        <td />
        <td id="tdInitialDrugConc"      runat="server" />
        <td id="tdInitialDrugConcUnits" runat="server" />
    </tr>
    <tr>
        <td class="AMMVolCalLabel">Initial drug volume for dose</td>
        <td />
        <td id="tdInitialVolumeForDose"      runat="server" />
        <td id="tdInitialVolumeForDoseUnits" runat="server">mL</td>
    </tr>
    <tr>
        <td class="AMMVolCalLabel">Fixed volume</td>
        <td><asp:RadioButton ID="rbFixedVolume" runat="server" GroupName="VolumeType"/></td>
        <td id="tdFixedVolume"      runat="server"><asp:TextBox ID="tbFixedVolume" runat="server" Width="55px" /></td>
        <td id="tdFixedVolumeUnits" runat="server">mL</td>

        <td id="tdFixVolumeError" runat="server" class="ErrorMessage" />
    </tr>
    <tr>
        <td class="AMMVolCalLabel">Drug + nominal volume</td>
        <td><asp:RadioButton ID="rbDrugNominalVolume" runat="server" GroupName="VolumeType"/></td>
        <td><asp:TextBox ID="tbDrugNominalVolume" runat="server" Width="55px" /></td>
        <td id="tdDrugNominalVolumeUnits" runat="server">mL</td>
    </tr>
    <tr>
        <td>&nbsp;</td>
    </tr>
    <tr id="trVolCalRow">
        <td colspan="2" class="AMMVolCalLabel"><span runat="server" id="spanRuleMaxPercVolToAdd"></span>% rule will result in final volume of</td>
        <td id="tdRuleMaxPercVolToAdd" runat="server" />
        <td id="tdRuleMaxPercVolUnits" runat="server">mL</td>

        <td id="tdRuleEquation" runat="server" colspan="4" />
    </tr>
    <tr>
        <td colspan="2" class="AMMVolCalLabel">Manually set volume with conc limits</td>  
        <td id="tdConcLimitsFixedVolume"      runat="server" />
        <td id="tdConcLimitsFixedVolumeUnits" runat="server">mL</td>

        <td class="AMMVolCalLabel">Min Conc.</td>
        <td id="tdMinConc" runat="server" />
        <td class="AMMVolCalLabel">Max Conc.</td>
        <td id="tdMaxConc" runat="server" />
    </tr>
    <tr>
        <td id="tdErrorMsg" runat="server" colspan="8" style="text-align: center" class="ErrorMessage">&nbsp;</td>
    </tr>
</table>
</div>
