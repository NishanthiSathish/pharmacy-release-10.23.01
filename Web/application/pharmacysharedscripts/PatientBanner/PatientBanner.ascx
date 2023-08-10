<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PatientBanner.ascx.cs" Inherits="application_pharmacysharedscripts_PatientBanner_PatientBanner" %>
<div style="font-size: 12px;width: 100%;">
    <asp:Label ID="lbName" runat="server" Font-Bold="True" />
    <span style="padding-left:10px;">Born: </span><asp:Label ID="lbDOB" runat="server" Font-Bold="True" />
    <span style="padding-left:10px;">Gender: </span><asp:Label ID="lbGender" runat="server" Font-Bold="True" />
    <asp:Label ID="lbNHSNumberDisplayName" runat="server" style="padding-left:10px;" /><asp:Label ID="lbNHSNumber" runat="server" Font-Bold="True"  />
    <asp:Label ID="lbCaseNoDisplayName" runat="server" style="padding-left:10px;" /><asp:Label ID="lbCaseNo" runat="server" Font-Bold="True"  />
    <br />                
    <span>Status: </span><asp:Label ID="lbPatientStatus" runat="server" Font-Bold="True"  />
    <span style="padding-left:10px;">Ward: </span><asp:Label ID="lbWard" runat="server" Font-Bold="True"  />
    <span style="padding-left:10px;">Consultant: </span><asp:Label ID="lbConsultant" runat="server" Font-Bold="True"  />
    <br />
    <span id="lbHeightDisplayName" runat="server">Height: </span><asp:Label ID="lbHeight" runat="server" Font-Bold="True"  />&nbsp;<asp:Label ID="lbHeightExpired" runat="server" style="color:red; font-weight:bold;" Text="Expired" Visible="false" />
    <span id="lbWeightDisplayName" runat="server" style="padding-left:10px;">Weight: </span><asp:Label ID="lbWeight" runat="server" Font-Bold="True"  />&nbsp;<asp:Label ID="lbWeightExpired" runat="server" style="color:red; font-weight:bold;" Text="Expired" Visible="false" />
    <span id="lbBSADisplayName" runat="server" style="padding-left:10px;">BSA: </span><asp:Label ID="lbBSA" runat="server" Font-Bold="True"  />&nbsp;<asp:Label ID="lbBSAExpired" runat="server" style="color:red; font-weight:bold;" Text="Expired" Visible="false" />
</div>