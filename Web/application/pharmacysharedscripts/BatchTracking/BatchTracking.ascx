<%@ Control Language="C#" AutoEventWireup="true" CodeFile="BatchTracking.ascx.cs" Inherits="application_pharmacysharedscripts_BatchTracking_BatchTracking" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<div>
    <asp:HiddenField ID="hfConfirmed"                   runat="server" />
    <asp:HiddenField ID="hfBatchTracking"               runat="server" />
    <asp:HiddenField ID="hfShowBatchTracking"           runat="server" />
    <asp:HiddenField ID="hfShowExpiryDate"              runat="server" />
    <asp:HiddenField ID="hfNSVCode"                     runat="server" />
    <asp:HiddenField ID="hfIfDrugHasAlternateBarcodes"  runat="server" />
    <table>
        <colgroup>
            <col />
            <col style="width:200px" />
            <col style="width:150px" />
        </colgroup>
        <tr id="trBarcode" runat="server">
            <td>Barcode:</td>
            <td><asp:TextBox ID="tbBarcode" runat="server" Width="200px" /></td>
            <td><asp:Label ID="lbBarcodeError" runat="server" CssClass="ErrorMessage" ></asp:Label></td>
        </tr>
        <tr id="trBatchNumber" runat="server">
            <td>Batch Number:</td>
            <td><asp:TextBox ID="tbBatchNumber" runat="server" Width="200px" /></td>
            <td><asp:Label ID="lbBatchNumberError" runat="server" CssClass="ErrorMessage" ></asp:Label></td>
        </tr>
        <tr id="trExpiryDate" runat="server">
            <td>Expiry:</td>
            <td><asp:TextBox ID="dpExpiryDate" runat="server" Width="75px" /></td>
            <td><asp:Label ID="lbExpiryError" runat="server" CssClass="ErrorMessage" ></asp:Label></td>
        </tr>
    </table>
</div>