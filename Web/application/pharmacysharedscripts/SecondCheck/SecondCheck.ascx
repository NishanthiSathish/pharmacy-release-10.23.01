<%@ Control Language="C#" AutoEventWireup="true" CodeFile="SecondCheck.ascx.cs" Inherits="SecondCheck" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<div id="secondCheck">
<table>
    <colgroup>
        <col style="width:80px" />
        <col style="width:200px" />
    </colgroup>
    <tr>
        <td>Username:</td>
        <td><asp:TextBox ID="tbUsername" runat="server" Width="200px"></asp:TextBox><br /></td>
    </tr>        
    <tr>
        <td>Password:</td>
        <td><asp:TextBox ID="tbPassword" runat="server" Width="200px" TextMode="Password" ></asp:TextBox><br /></td>
    </tr>        
    <tr id="trSelfCheckReasonRow1" runat="server">
        <td colspan="2">
            <span style="font-style:italic;">You are second checking yourself</span><br />
            Please enter a self check reason:
        </td>
		<td />
    </tr>
    <tr id="trSelfCheckReasonRow2" runat="server">
		<td colspan="2"><asp:TextBox ID="tbSelfCheckReason" runat="server" Width="280px" MaxLength="50" /></td>
        <td />
    </tr>
    <tr>
        <td colspan="2"><div id="divError" runat="server" class="ErrorMessage">&nbsp;</div></td>
        <td />
    </tr> 
</table>
<asp:HiddenField ID="hfEntityID"                runat="server"/>
<asp:HiddenField ID="hfShowSelfCheckReason"     runat="server"/>
<asp:HiddenField ID="hfEntityIDsForSelfCheck"   runat="server"/>
</div>