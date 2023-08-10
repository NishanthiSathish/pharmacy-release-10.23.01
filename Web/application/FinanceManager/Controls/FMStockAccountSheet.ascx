<%@ Control Language="C#" AutoEventWireup="true" CodeFile="FMStockAccountSheet.ascx.cs" Inherits="application_FinanceManager_controls_FMStockAccountSheet" %>
<%@ Register Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" TagPrefix="icw"     %>
<asp:Panel ID="pnStockAccountPanel" name="fmSheet" runat="server" Width="800px" style="padding-left:25px; padding-right:25px;">
    <div>
        <icw:Label ID="lbHospitalNam" runat="server" CssClass="fm-info" Text="Hospital Name" style="float:left;"/>  
        <icw:Label ID="lbDateCreated" runat="server" CssClass="fm-info" Text="01-May-12"     style="float:right;"/>
    </div>        

    <div style="text-align: center; margin: 0px; padding: 0px; width: 100%">
        <icw:Label ID="lbHeading"       runat="server" CssClass="fm-main-heading"   Text="Stock Balance Sheet"    /><br />
        <icw:Label ID="lbSites"         runat="server" CssClass="fm-info"           Text="Site No: 123 234 456"   /><br />
        <icw:Label ID="lbDatePeriod"    runat="server" CssClass="fm-info"           Text="Period: - "             /><br />
    </div>
        
    <hr />    
    
    <table width="100%">
        <tr style="text-align:justify;width:100%">
            <td style="text-align:left;">
                <a id="lbDrug" runat="server" class="fm-info" style="width:100%;">DUI051A - Something something</a>
            </td>
            <td>&nbsp;</td>
            <td style="text-align:right;">
                <a id="btnLog"      runat="server" class="fm-info" style="width:100%;cursor:pointer;"><img src="../../images/ocs/form.gif"       border="0" alt="LabUtils viewer"   /></a>&nbsp;
                <a id="btnSearch"   runat="server" class="fm-info" style="width:100%;cursor:pointer;"><img src="../../images/ocs/searchmore.png" border="0" alt="search for a drug" /></a>&nbsp;
                <a id="btnPrevious" runat="server" class="fm-info" style="width:100%;cursor:pointer;">&lt;&lt;</a>&nbsp;
                <a id="btnSummary"  runat="server" class="fm-info" style="width:100%;cursor:pointer;">S</a>&nbsp;
                <a id="btnNext"     runat="server" class="fm-info" style="width:100%;cursor:pointer;">&gt;&gt;</a>
            </td>
        </tr>
    </table>
    
    <hr />
    
    <asp:Table ID="table" runat="server" CssClass="fm-sa-table" CellSpacing="0" />

    <div id="divRebuildWarning" runat="server" style="text-align: center; margin: 10px; width: 100%">
        <span class="fm-info" style="color:#CC3300">Data has not been updated since last set of rule changes<br />(this will be done overnight)</span>
    </div>
</asp:Panel>