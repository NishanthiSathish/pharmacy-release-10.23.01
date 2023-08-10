<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PCTClaimItemEditForm.ascx.cs" Inherits="application_PCT_ClaimTransactionScreen_PCTClaimItemEditForm" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI"  %>

<script type="text/javascript">
    function HandleError(sender, eventArgs)
    {
        alert('Invalid value entered');
        setTimeout(function()
        {
            sender.clear();
        }, 10);
    }
</script>

<table>
    <tr>
        <td><label>Category</label></td>
        <td><telerik:RadTextBox ID="rtxtCategory" runat="server" MaxLength="1" Text='<%# DataBinder.Eval( Container, "DataItem.Category" ) %>' Skin="Web20" TabIndex="1"  /></td>
        <td><label>Patient Category</label></td>
        <td><telerik:RadTextBox ID="rtxtPatientCategory" runat="server" MaxLength="1"  TabIndex="11"  Text='<%# DataBinder.Eval( Container, "DataItem.PCTPatientCategory" ) %>' Skin="Web20"  /></td>
        <td><label>Service Date</label></td>
        <td><telerik:RadDatePicker ID="rdatService" runat="server"  TabIndex="21"  SelectedDate='<%# DataBinder.Eval( Container, "DataItem.ServiceDate" ) %>' /></td>
    </tr>
    <tr>
        <td><label>Component Number</label></td>
        <td><telerik:RadNumericTextBox ID="tntbComponentNumber"  TabIndex="2"  
                runat="server" MinValue="1" NumberFormat-DecimalDigits="0" 
                dbValue='<%# DataBinder.Eval( Container, "DataItem.ComponentNumber" ) %>' 
                Skin="Web20"  MaxValue="99" >
            <ClientEvents OnError="HandleError" />
<NumberFormat DecimalDigits="0" GroupSeparator=""></NumberFormat>
            </telerik:RadNumericTextBox>
        </td>
        <td><label>CSC or PHO Status</label></td>
        <td><telerik:RadTextBox ID="rtxtCSCorPHO" runat="server" MaxLength="1"  TabIndex="12"  Text='<%# DataBinder.Eval( Container, "DataItem.CSCorPHOStatusFlag" ) %>' Skin="Web20"  /></td>
        <td><label>Claim Code</label></td>
        <td><telerik:RadNumericTextBox ID="rntbClaimCode" runat="server" MinValue="0"  TabIndex="22"  Skin="Web20" 
                DBvalue='<%# DataBinder.Eval( Container, "DataItem.ClaimCode" ) %>'  >
<NumberFormat DecimalDigits="0" GroupSeparator=""></NumberFormat>
            </telerik:RadNumericTextBox>
        </td>
    </tr>
    <tr>
        <td><label>Total Component</label></td>
        <td><telerik:RadNumericTextBox ID="tntbTotalComponent" MaxValue="99"  TabIndex="3"  runat="server"  MinValue="1" NumberFormat-DecimalDigits="0" dbValue='<%# DataBinder.Eval( Container, "DataItem.TotalComponentNumber" ) %>' Skin="Web20"  >
                <ClientEvents OnError="HandleError" />

<NumberFormat DecimalDigits="0" GroupSeparator=""></NumberFormat>
            </telerik:RadNumericTextBox>
        </td>
        <td><label>HUHC Status</label></td>
        <td><asp:CheckBox ID="chkHUHC" runat="server"  TabIndex="13"  Checked='<%# (((bool?)DataBinder.Eval( Container, "DataItem.HUHCStatusFlag" )).HasValue && ((bool?)DataBinder.Eval(Container, "DataItem.HUHCStatusFlag")).Value) %>' Skin="Web20"  /></td>
        <td><label>Quantity Claimed</label></td>
        <td><telerik:RadNumericTextBox ID="rntbQuantityClaimed" runat="server"  Skin="Web20"  TabIndex="23"  
                MinValue="0" MaxValue="999999.9999" 
                dbValue='<%# DataBinder.Eval( Container, "DataItem.QuantityClaimed" ) %>' >
            <NumberFormat DecimalDigits="4" GroupSeparator="" />
            <ClientEvents OnError="HandleError" />
            </telerik:RadNumericTextBox>
        </td>
    </tr>
    <tr>
        <td><label>Prescriber ID</label></td>
        <td><telerik:RadTextBox ID="rtxtPrescriberID" runat="server"  TabIndex="4"  MaxLength="10" Text='<%# DataBinder.Eval( Container, "DataItem.PrescriberID" ) %>' Skin="Web20"  /></td>
        <td><label>Special Authority Number</label></td>
        <td><telerik:RadTextBox ID="rtxtSpecialAuth" runat="server" MaxLength="10"  TabIndex="14"  Text='<%# DataBinder.Eval( Container, "DataItem.SpecialAuthorityNumber" ) %>' Skin="Web20"  /></td>
        <td><label>Pack Unit of Measure</label></td>
        <td><telerik:RadTextBox ID="rtxtPUoM" runat="server"  TabIndex="24"  MaxLength="8" Text='<%# DataBinder.Eval( Container, "DataItem.PackUnitOfMeasure" ) %>' Skin="Web20"  /></td>
    </tr>
    <tr>
        <td><label>Health Professional Group Code</label></td>
        <td><telerik:RadTextBox ID="rtxtHPGC" runat="server" MaxLength="2"  TabIndex="5"   Text='<%# DataBinder.Eval( Container, "DataItem.HealthProfessionalGroupCode" ) %>' Skin="Web20"  /></td>
        <td><label>Dose</label></td>
        <td><telerik:RadNumericTextBox ID="rntbDose" runat="server"  TabIndex="15"  MinValue="0" Skin="Web20" 
                MaxValue="999999.9999" 
                dbValue='<%# DataBinder.Eval( Container, "DataItem.Dose" ) %>'  >
                <NumberFormat DecimalDigits="4" GroupSeparator="" />
                <ClientEvents OnError="HandleError" />
            </telerik:RadNumericTextBox>
        </td>
        <td><label>Claim Amount (c)</label></td>
        <td><telerik:RadNumericTextBox MaxValue="999999999"  ID="rntbClaimAmount" runat="server"  Skin="Web20"   TabIndex="25" 
                NumberFormat-DecimalDigits="0" 
                DBvalue='<%# DataBinder.Eval( Container, "DataItem.ClaimAmount" ) %>' MinValue="0">
                <NumberFormat DecimalDigits="0" GroupSeparator=""></NumberFormat>
                <ClientEvents OnError="HandleError" />              
            </telerik:RadNumericTextBox>
        </td>
    </tr>
    <tr>
        <td><label>Specialist ID</label></td>
        <td><telerik:RadTextBox ID="ttxtSpecialistID" runat="server"  TabIndex="6"  MaxLength="10"  Text='<%# DataBinder.Eval( Container, "DataItem.SpecialistID" ) %>' Skin="Web20"  /></td>
        <td><label>Daily Dose</label></td>
        <td><telerik:RadNumericTextBox ID="rntbDailyDose" runat="server"  TabIndex="16"   MinValue="0" 
                MaxValue="999999.9999" 
                dbValue='<%# DataBinder.Eval( Container, "DataItem.DailyDose" ) %>' >
            <NumberFormat DecimalDigits="4" GroupSeparator="" />
            <ClientEvents OnError="HandleError" />
            </telerik:RadNumericTextBox>
        </td>
        <td><label>CBS Subsidy (c)</label></td>
        <td><telerik:RadNumericTextBox ID="rntbCBSSubsidy" runat="server"  Skin="Web20"   TabIndex="26"  MaxValue="9999999999" MinValue="0"
                NumberFormat-DecimalDigits="0" 
                dbValue='<%# DataBinder.Eval( Container, "DataItem.CBSSubsidy" ) %>' >
                <NumberFormat DecimalDigits="0" GroupSeparator=""></NumberFormat>
                <ClientEvents OnError="HandleError" />
            </telerik:RadNumericTextBox>
        </td>
    </tr>
    <tr>
        <td><label>Endorsement Date</label></td>
        <td><telerik:RadDatePicker ID="rdatEndorsement" runat="server"  TabIndex="7"  SelectedDate='<%# DataBinder.Eval( Container, "DataItem.EndorsementDate" ) %>' /></td>
        <td><label>Prescription Flag</label></td>
        <td><asp:CheckBox ID="chkPrescriptionFlag" runat="server"  TabIndex="17"  Checked='<%# (((bool?)DataBinder.Eval( Container, "DataItem.PrescriptionFlag" )).HasValue && ((bool?)DataBinder.Eval(Container, "DataItem.PrescriptionFlag")).Value)  %>' /></td>
        <td><label>CBS Packsize</label></td>
        <td><telerik:RadNumericTextBox ID="rntbCBSPacksize" runat="server"  MinValue="0"  TabIndex="27" 
                MaxValue="999999.9999" 
                dbValue='<%# DataBinder.Eval( Container, "DataItem.CBSPacksize" ) %>' >
            <NumberFormat DecimalDigits="4" GroupSeparator="" />
            <ClientEvents OnError="HandleError" />
            </telerik:RadNumericTextBox>
        </td>
    </tr>
    <tr>
        <td><label>Prescriber Flag</label></td>
        <td><telerik:RadTextBox ID="rtxtFlag" runat="server" MaxLength="1"  TabIndex="8"  Text='<%# DataBinder.Eval( Container, "DataItem.PrescriberFlag" ) %>' /></td>
        <td><label>Dose Flag</label></td>
        <td><asp:CheckBox ID="chkDoseFlag" runat="server"  TabIndex="18"  Checked='<%# (((bool?)DataBinder.Eval( Container, "DataItem.DoseFlag" )).HasValue && ((bool?)DataBinder.Eval(Container, "DataItem.DoseFlag")).Value) %>' /></td>
        <td><label>Funder</label></td>
        <td><telerik:RadTextBox ID="rtxtFunder" runat="server" MaxLength="3"  TabIndex="28"  Text='<%# DataBinder.Eval( Container, "DataItem.Funder" ) %>' /></td>
    </tr>
    <tr>
        <td><label>Oncology Patient Group</label></td>
        <td><telerik:RadTextBox ID="rtxtOncologyPatientGroup" runat="server"  TabIndex="9"  MaxLength="1" Text='<%# DataBinder.Eval( Container, "DataItem.PCTOncologyPatientGrouping" ) %>' /></td>
        <td><label>Prescription ID</label></td>
        <td><telerik:RadTextBox ID="rtxtPrescriptionID" runat="server"  TabIndex="19"  MaxLength="9" Text='<%# DataBinder.Eval( Container, "DataItem.PrescriptionID" ) %>' /></td>
        <td><label>Form Number</label></td>
        <td><telerik:RadTextBox ID="rtxtFormNumber" runat="server"  TabIndex="29"  MaxLength="9" Text='<%# DataBinder.Eval( Container, "DataItem.FormNumber" ) %>' /></td>
    </tr>
    <tr>
        <td><label>NHI Number</label></td>
        <td><telerik:RadTextBox ID="rtxtNHINumber" runat="server" MaxLength="7" TabIndex="10"  Text='<%# DataBinder.Eval( Container, "DataItem.NHI" ) %>' /></td>
        <td><label>Prescription ID Suffix</label></td>
        <td><telerik:RadTextBox ID="rtxtPrescriptionSuffix" runat="server"  TabIndex="20"  MaxLength="2" Text='<%# DataBinder.Eval( Container, "DataItem.PrescriptionSuffix" ) %>' /></td>
        <td colspan=2 align=right>
            <asp:Button ID="rbtnEditUpdate" Text="Update" Skin="Web20"  runat=server  TabIndex="29"  CommandName="Update"></asp:Button>
            &nbsp
            <asp:Button ID="rbtnEditCancel" Text="Cancel" Skin="Web20"  runat=server  TabIndex="30"  CommandName="Cancel"></asp:Button>
            &nbsp&nbsp
        </td>
    </tr>
</table>