<%@ Control Language="C#" AutoEventWireup="true" CodeFile="FMAccountSheet.ascx.cs" Inherits="application_FinanceManager_Controls_FMAccountSheet" %>
<asp:Panel ID="pnAccountPanel" runat="server" Width="850px" style="padding-left:10px;" limitSize="true">
    <div>
        <asp:Label ID="lbHospitalNam" runat="server" CssClass="fm-info" Text="Hospital Name" style="float:left;"/>  
        <asp:Label ID="lbDateCreated" runat="server" CssClass="fm-info" Text="01-May-12"     style="float:right;"/>
    </div>        

    <div style="text-align: center; margin: 0px; padding: 0px; width: 100%">
        <asp:Label ID="lbHeading"       runat="server" CssClass="fm-main-heading"   Text="Stock Enquiry"          /><br />
        <asp:Label ID="lbSites"         runat="server" CssClass="fm-info"           Text="Site No: 123 234 456"   /><br />
        <asp:Label ID="lbDatePeriod"    runat="server" CssClass="fm-info"           Text="Period: - "             /><br />
    </div>
        
    <hr />    
    
    <div id="divTable" class="fm-grni-table" style="overflow-x: hidden; overflow-y: scroll;" >    
        <asp:Table ID="table" runat="server" CssClass="fm-as-table" CellSpacing="0" />
    </div>

    <div id="divRebuildWarning" runat="server" style="text-align: center; width: 100%">
        <span class="fm-info" style="color:#CC3300">Data has not been updated since last set of rule changes<br />(this will be done overnight)</span>
    </div>
</asp:Panel>