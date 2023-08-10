<%@ Control Language="C#" AutoEventWireup="true" CodeFile="AlternateBarcodeControl.ascx.cs" Inherits="application_PharmacyProductEditor_AlternateBarcodeControl" %>
<%@ Implements Interface="ascribe.pharmacy.quesscrllayer.IQSViewControl"  %>
<%@ Import     Namespace="ascribe.pharmacy.shared"                        %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>
<div id="divSBC" style="margin:10px;">
    <p style="font-style:italic">
        To add a barcode: Enter alternative GTIN barcode and press Add<br />
        To delete a barcode: Highlight from list and press Delete.  
    </p>
    Primary Barcode: <span id="spPrimaryBarcode" runat="server" />
    <br /><br />
    Currently available alternate barcodes:<br />

    <asp:UpdatePanel ID="upABC" runat="server">
    <ContentTemplate>
        <asp:HiddenField ID="hfQSProcessor"         runat="server" />
        <asp:HiddenField ID="hfAlternateBarcodes"   runat="server" />
        <asp:HiddenField ID="hfSelectedBarcode"     runat="server" />
        <asp:HiddenField ID="hfSupplierProfiles"    runat="server" />
        <asp:HiddenField ID="hfSuppressClearError"  runat="server" />
        <br />
        <div id="divGrid" style="height:250px;width:400px;" >
            <uc:GridControl ID="abcGrid" runat="server" JavaEventDblClick="btnOK_click" EnterAsDblClick="true" EnableAlternateRowShading="true" />
        </div>

        <br />

        <table>
            <tr style="vertical-align:middle">
                <td onkeydown="if (event.keyCode == 13) {{ window.event.cancelBubble = true; window.event.returnValue = false; $('#<%= btnAdd.ClientID %>').click(); }}"
                    onkeypress="MaskInput(this.children[0], digitsMask, undefined, <%= Barcode.GTIN14BarcodeLength %>)" 
                    onpaste="MaskInput(this.children[0], digitsMask, undefined, <%= Barcode.GTIN14BarcodeLength %>)" 
                    >
                    Barcode: <asp:TextBox ID="tbBarcode" runat="server" Width="125px" />
                </td>
                <td><asp:Button ID="btnAdd"     runat="server" Text="Add"    CssClass="PharmButtonSmall" OnClick="btnAdd_OnClick" /></td>
                <td>&nbsp;</td>
                <td><asp:Button ID="btnDelete"  runat="server" Text="Delete" CssClass="PharmButtonSmall" OnClick="btnDelete_OnClick" /></td>
            </tr>
        </table>
        <asp:Label id="lbError" runat="server" CssClass="ErrorMessage" EnableViewState="false" Text="&nbsp;" />
    </ContentTemplate>
    </asp:UpdatePanel>
</div>

