<%@ Control Language="C#" AutoEventWireup="true" CodeFile="DisplayLogRows.ascx.cs" Inherits="PharmacyDisplayLogRows" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>
<script type="text/javascript" >
    function resizeLog() 
    {
        var height = $(window).height() - $('#divLogGrid').offset().top - 20;
        $('#divLogGrid').height(height);
        $('#logGrid'   ).height(height);
    }
</script>
<div id="divCriteria" align="left" style="padding-left:5px;">
    <table id="tblInfo" cellpadding="0" cellpadding="0">
        <tr id="trGroupByMsgTranslog" runat="server"><td colspan="2">ISSUE/RETURN GROUPED BY PRODUCT</td></tr>
        <tr id="trGroupByMsgOrderlog" runat="server"><td colspan="2">RECEIVED GROUPED BY PRODUCT</td></tr>
        <tr align="left">
            <td>Log file:</td>
            <td><asp:Label ID="lbLogFile"  runat="server" /></td>
        </tr>        
        <tr align="left">
            <td>From date:</td>
            <td><asp:Label ID="lbDate" runat="server" /></td>
        </tr>        
        <tr id="trProductRow" runat="server" align="left">
            <td>Product:</td>
            <td><asp:Label ID="lbProduct"  runat="server" /></td>
        </tr>        
        <tr align="left">
            <td>Search for:</td>
            <td><asp:Label ID="lbSearchFor"  runat="server" /></td>
        </tr>        
        <tr align="left">
            <td>Site code:</td>
            <td><asp:Label ID="lbSiteCode" runat="server" /></td>
        </tr>
    </table>
</div>
<br />
<asp:Label ID="lbReachedMaxRowCount" runat="server" CssClass="ErrorMessage"  Width="100%" TextAlign="Center" Text="Criteria returns {0} or more records. Only the first {0} will be used." Visible="false" />
<div id="divLogGrid" style="padding-left:5px;">
    <uc:GridControl ID="logGrid" runat="server" CellPadding="1" CellSpacing="0" SortableColumns="true" ShowSortImage="false" EnableColumnHeaderBorder="false" />
</div>
