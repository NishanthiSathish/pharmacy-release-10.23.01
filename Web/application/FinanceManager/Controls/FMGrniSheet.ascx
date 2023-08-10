<%@ Control Language="C#" AutoEventWireup="true" CodeFile="FMGrniSheet.ascx.cs" Inherits="application_FinanceManager_controls_FMGrniSheet" %>
<asp:Panel ID="pnGRNIPanel" runat="server" Width="800px" style="padding-left:15px;" limitSize="true">
    <div>
        <asp:Label ID="lbHospitalNam" runat="server" CssClass="fm-info" Text="Hospital Name" style="float:left;"/>  
        <asp:Label ID="lbDateCreated" runat="server" CssClass="fm-info" Text="01-May-12"     style="float:right;"/>
    </div>        

    <div style="text-align: center; margin: 0px; padding: 0px; width: 100%">
        <asp:Label ID="lbHeading"   runat="server" CssClass="fm-main-heading" Text="Goods Received (Returned) Not Invoiced (Credited)"  /><br />
        <asp:Label ID="lbSites"     runat="server" CssClass="fm-info" Text="Site No: 123 234 456"  /><br />
        <asp:Label ID="lbUpToDate"  runat="server" CssClass="fm-info" Text="Period: - "            />
    </div>
    
    <hr />

    <div id="divTable" class="fm-grni-table" style="overflow-x: hidden; overflow-y: scroll;" >
        <asp:Table ID="table" runat="server" CellSpacing="0" />
    </div>
    
    <div id="divRebuildWarning" runat="server" style="text-align: center; margin: 10px; width: 100%">
        <span class="fm-info" style="color:#CC3300">Data has not been updated since last set of rule changes<br />(this will be done overnight)</span>
    </div>
</asp:Panel>