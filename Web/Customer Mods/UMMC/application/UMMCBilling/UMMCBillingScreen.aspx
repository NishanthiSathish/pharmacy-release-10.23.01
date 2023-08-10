<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UMMCBillingScreen.aspx.cs" Inherits="application_bespoke_UMMC_Billing_UMMCBillingScreen" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<%@ Register src="~/application/pharmacysharedscripts/PharmacyLabelPanelControl.ascx" tagname="LabelPanel"  tagprefix="lp" %>
<%@ Register src="~/application/pharmacysharedscripts/PharmacyGridControl.ascx"       tagname="GridControl" tagprefix="gc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>UMMC Billing Interface</title>
    
    <script type="text/javascript" src="scripts/UMMCBillingScreen.js"></script>    
    <script type="text/javascript" src="../../application/sharedscripts/icw.js"></script>    
    <script type="text/javascript" src="../../application/sharedscripts/DateLibs.js"></script>
    <script type="text/javascript" src="../../application/sharedscripts/Controls.js"></script>
    <script type="text/javascript" src="../../application/sharedscripts/icwfunctions.js"></script>
    <script type="text/javascript" src="../../application/SharedScripts/jquery-1.3.2.js"></script>
    <script type="text/javascript" src="../../application/pharmacysharedscripts/PharmacyGridControl.js"></script>
    
    <link href="../../style/application.css"        rel="stylesheet" type="text/css" />
    <link href="../../style/LabelPanelControl.css"  rel="stylesheet" type="text/css" />
    <link href="../../style/OCSGrid.css"            rel="stylesheet" type="text/css" />
</head>
<body onkeydown="form_onkeydown(event)" onload="form_onload()" 
        highlightBilledTransactions   ="<%= this.HighlightBilledTransactions   %>" 
        closeFormAfterBillingComplted ="<%= this.CloseFormAfterBillingComplted %>" 
        highlightColourAllBilled      ="<%= this.HighlightColourAllBilled  %>"
        highlightColourPartBilled     ="<%= this.HighlightColourPartBilled %>"
        highlightColourNonBilled      ="<%= this.HighlightColourNonBilled  %>" >
    <form id="form1" runat="server" style="width: 100%; text-align: center;">
        <!-- AsyncPostBackTimeOut in ScriptManager sets WebForms.PageRequestManager has a tiemout of 600secs (10mins) -->
        <asp:ScriptManager ID="ScriptManager1" runat="server" AsyncPostBackTimeOut="600"></asp:ScriptManager>
        <asp:HiddenField ID="selectedTransactionIDs" runat="server"></asp:HiddenField>
        <asp:HiddenField ID="onlySendUnbilledItems"  runat="server"></asp:HiddenField>        
        
        <br />
        <h2 style="text-align: center">Calculate Costs</h2>
            
        <div style="height: 150px; width: 550px">       
            <!-- Patient info pannel -->         
            <div style="text-align: left; width: 100%;"><lp:LabelPanel id="patientInfo" runat="server" /></div>
            
            <br />
            
            <!-- date range selection boxes --> 
            <asp:UpdatePanel ID="upDateRange" runat="server" UpdateMode="Conditional">
                <ContentTemplate>     
                    <table>
                        <tr>
                            <td style="width: 130px; text-align: left;">Billing transactions for (inclusive)</td>
                            <td><asp:TextBox ID="startDate" runat="server" validchars="DATE:dd/mm/yyyy" onkeypress="MaskInput(this);" onPaste="MaskInput(this)" Width="75px" /></td>
                            <td><img src="..\..\images\ocs\show-calendar.gif" onclick="ShowMonthViewWithDate(startDate, startDate ,startDate.value);" style="border: 0"></td>
                            <td style="width: 30px;">to</td>
                            <td><asp:TextBox ID="endDate" runat="server" validchars="DATE:dd/mm/yyyy" onkeypress="MaskInput(this);" onPaste="MaskInput(this)" Width="75px" /></td>
		                    <td><img src="..\..\images\ocs\show-calendar.gif" onclick="ShowMonthViewWithDate(endDate, endDate, endDate.value);" style="border: 0"></td>
		                    <td style="width: 130px; text-align: centre;"><asp:Button ID="Update" runat="server" class="ICWButton" Text="Update" accesskey="U" OnClick="Update_Click" /></td>
                        </tr>
                    </table>
                    
                    <!-- date range error message -->
                    <asp:Label ID="errorMessageDate" runat="server" style="color: #FF0000; width: 80%; font-weight: bold;" EnableViewState="False">&nbsp;</asp:Label>
                </ContentTemplate>
            </asp:UpdatePanel>                            
        </div>  

        <!-- list of dispesning gid -->
        <div style="width: 97%; text-align: left; margin-bottom: 3px;">
            <button id="checkAll"   class="ICWButton" style="font-size: x-small; width: 70px" accesskey="C" onclick="checkAll_onclick()"   ><u>C</u>heck All</button>
            <button id="uncheckAll" class="ICWButton" style="font-size: x-small; width: 70px" accesskey="N" onclick="uncheckAll_onclick()" >U<u>n</u>check All</button>
        </div>            
        <asp:UpdatePanel ID="upDispensingsGrid" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <div style="width: 97%;height: 300px;"><gc:GridControl id="dispensingsGrid" runat="server" /></div>                
            </ContentTemplate>
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="Update" /> 
            </Triggers> 
        </asp:UpdatePanel>
        
        <!-- Buttons, legend, and error message at bottom of screen -->         
        <div style="width: 95%; text-align: right">
            <asp:UpdatePanel ID="upBillPatient" runat="server" UpdateMode="Conditional">
                <ContentTemplate> 
                    <div style="width: 100%; height: 20px; text-align: center">
                        <asp:Label ID="updateMessage"    runat="server" style="color: #FF0000; width: 80%; font-weight: bold;" EnableViewState="False">&nbsp;</asp:Label>
                        <asp:Label ID="errorMessageGrid" runat="server" style="color: #FF0000; width: 80%; font-weight: bold;" EnableViewState="False">&nbsp;</asp:Label>
                    </div>  
                
                    <table>
                        <tr>
                            <td style="text-align: left; width: 300px;">
                                <asp:Panel ID="rowHighlightKey" runat="server" EnableViewState="True" style="width: 300px;" Visible="False">
                                    <table style="font-size: x-small;">
                                        <tr>
                                            <td colspan="2" style="font-weight: bold; text-decoration: underline;">Shading Key</td>
                                        </tr>
                                        <tr>
                                            <td style="background-color: <%= this.HighlightColourAllBilled %>; width: 15px;">&nbsp;</td>
                                            <td>Drug has been fully billed.&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td style="background-color: <%= this.HighlightColourPartBilled %>; width: 15px;">&nbsp;</td>
                                            <td>Only part of drug quantity has been billed.&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td style="background-color: <%= this.HighlightColourNonBilled %>; width: 15px;">&nbsp;</td>
                                            <td>Not yet billed.&nbsp;</td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                            </td>                                                   
                            
                            <td style="width: 100%;"></td>
                        
                            <td><asp:Button ID="billPatient" runat="server" class="ICWButton" Text="Bill Patient" accesskey="B" onclick="billPatient_Click" OnClientClick="billPatient_Click()" /></td>
                            <td><asp:Button ID="cancel"      runat="server" class="ICWButton" Text="Cancel" OnClientClick="cancel_onclick()" /></td>
                        </tr>
                    </table>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </form>
</body>
</html>
