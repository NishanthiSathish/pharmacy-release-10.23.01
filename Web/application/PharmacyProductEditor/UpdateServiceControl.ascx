<%@ Control Language="C#" AutoEventWireup="true" CodeFile="UpdateServiceControl.ascx.cs" Inherits="application_PharmacyProductEditor_UpdateServiceControl" %>
<%@ Implements Interface="ascribe.pharmacy.quesscrllayer.IQSViewControl"  %>
<div id="divUSC">
    <div id="divMain" runat="server">
        <asp:UpdatePanel ID="upUSC" runat="server">
        <ContentTemplate>
            <asp:HiddenField ID="hfQSProcessor"       runat="server" />
            <asp:HiddenField ID="hfCheckBoxWithFocus" runat="server" />
            <table>
                <colgroup>
                    <col style="width:145px;text-align:left" />
                    <col style="width:295px;"                />
                    <col />
                    <col style="text-align:left"   />
                    <col style="text-align:center" />
                </colgroup>
                <thead>
                    <tr>
                        <td>&nbsp;</td>
                        <td style="text-align:center">Emis Health Version</td>
                        <td style="text-align:center" colspan="2">Local Version</td>
                        <td style="text-align:center">Lock Local Version</td>
                    </tr>
                </thead>
                <tbody>
                    <tr id="trDescription" runat="server">
                        <td />
                        <td><asp:Label ID="lbDescription" runat="server" Width="295px" /></td>
                        <td colspan="2" />
                        <td><asp:CheckBox   ID="cbDescription" runat="server" AutoPostBack="true" OnCheckedChanged="Lock_OnCheckedChanged" /></td>
                    </tr>
                    <tr id="trStoresDescription" runat="server">
                        <td />
                        <td><asp:Label ID="lbStoresDescription" runat="server" Width="295px" /></td>
                        <td colspan="2" />
                        <td><asp:CheckBox ID="cbStoresDescription" runat="server" AutoPostBack="true" OnCheckedChanged="Lock_OnCheckedChanged" /></td>
                    </tr>
                    <tr id="trWarningCode" runat="server">
                        <td />
                        <td><asp:Label ID="lbWarningCode" runat="server" Width="50px" /></td>
                        <td />
                        <td>Shift+F1 for list</td>
                        <td><asp:CheckBox ID="cbWarningCode" runat="server" AutoPostBack="true" OnCheckedChanged="Lock_OnCheckedChanged" /></td>
                    </tr>
                    <tr id="trWarningCode2" runat="server">
                        <td />
                        <td><asp:Label ID="lbWarningCode2" runat="server" Width="50px" /></td>
                        <td />
                        <td>Shift+F1 for list</td>
                        <td><asp:CheckBox ID="cbWarningCode2" runat="server" AutoPostBack="true" OnCheckedChanged="Lock_OnCheckedChanged" /></td>
                    </tr>
                    <tr id="trInstructionCode" runat="server">
                        <td />
                        <td><asp:Label ID="lbInstructionCode" runat="server" Width="50px" /></td>
                        <td />
                        <td>Shift+F1 for list</td>
                        <td><asp:CheckBox ID="cbInstructionCode" runat="server" AutoPostBack="true" OnCheckedChanged="Lock_OnCheckedChanged" /></td>
                    </tr>
                    <tr id="trCanUseSpoon" runat="server">
                        <td />
                        <td><asp:Label ID="lbCanUseSpoon" runat="server" Width="25px" /></td>
                        <td colspan="2" />
                        <td><asp:CheckBox ID="cbCanUseSpoon" runat="server" AutoPostBack="true" OnCheckedChanged="Lock_OnCheckedChanged" /></td>
                    </tr>
                </tbody>
            </table>
        </ContentTemplate>
        </asp:UpdatePanel>
        <br />
        <p style="font-style:italic;font-size:15px;color:#FF0000;font-weight:bold;">
            Changes made here will affect all stockholdings on your system.<br />
            <br />
            Only tick the ‘Lock Local version’ box if you wish to edit and maintain your own different version of the selected field.<br />
            Where the DSS on the Web service is installed, this will prevent any updates provided from overwriting this field.<br />
            In MOST cases, you should leave the box UNTICKED, so that you always have the most up-to-date version from Emis Health.
        </p>
    </div>
    <div id="divNotDSSDrugWarning" runat="server" class="ErrorMessage" style="width:100%; height:100%; vertical-align:middle; text-align:center;">Not a DSS Maintained Drug</div>
</div>
