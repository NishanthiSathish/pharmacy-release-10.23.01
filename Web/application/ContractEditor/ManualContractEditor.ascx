<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ManualContractEditor.ascx.cs" Inherits="ManualContractEditor" %>
<%@ Implements Interface="ascribe.pharmacy.quesscrllayer.IQSViewControl"  %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<link href="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
<link href="../ContractEditor/style/ManualContractEditor.css"           rel="stylesheet" type="text/css" />
<div id="divMCE">
<asp:UpdatePanel ID="upMCE" runat="server">
<ContentTemplate>        
    <asp:HiddenField runat="server" ID="hfSupCode" />
    <asp:HiddenField runat="server" ID="hfNSVCode" />
    <table runat="server" class="MainTable" id="tblMain" border="1" width="100%" >
        <thead>
            <tr>
                <td width="20%" />
                <td width="40%" />
                <td width="40%" />
            </tr>
        </thead> 
        <tbody>
        <tr>
            <td rowspan="3">Supplier</td>
            <td rowspan="3" colspan="2">
                <asp:LinkButton runat="server" id="lbtnSupplier" CssClass="LinkButton" OnClientClick="lbtnSupplier_onclick(false); return false;" /><br />
                <asp:Label runat="server" ID="lbSupplierError" Text="&nbsp;" EnableViewState="false" CssClass="ErrorMessage" />                    
            </td> 
        </tr>
                
        <tr><td>&nbsp;</td></tr>
        <tr><td>&nbsp;</td></tr>
                
        <tr class="HeaderRow">
            <td style="border: none; background-color: White;" />
            <td align="center">Pharmacy Current</td>
            <td align="center">Pharmacy Proposed</td>
        </tr>
        <tr>
            <td>Contract Reference</td>
            <td runat="server" id="tdCurrentContractReference" />
            <td>
                <asp:TextBox runat="server" id="tbProposedContractReference" Width="98%" />
                <asp:HiddenField id="hfOriginalContractReference" runat="server" />
            </td>
        </tr>
        <tr>
            <td><asp:Label runat="server" id="lbPrice" Text="Price ({0})" /></td>
            <td runat="server" id="tdCurrentPrice" />
            <td>
                <asp:TextBox runat="server" id="tbProposedPrice" Width="98%" />
                <asp:HiddenField id="hfOriginalPrice" runat="server" />
            </td>
        </tr>
        <tr>
            <td>Start Date</td>
            <td runat="server" id="tdCurrentStartDate" />
            <td>
                <asp:RadioButton runat="server" ID="rbProposedStartDateToday" GroupName="StartDate" OnCheckedChanged="rbDates_OnCheckedChanged" AutoPostBack="true" Text="Today" Checked="true" />
                <br />
                        
                <asp:RadioButton runat="server" ID="rbProposedStartDateOption" GroupName="StartDate" OnCheckedChanged="rbDates_OnCheckedChanged" AutoPostBack="true"/>&nbsp;&nbsp;
                <telerik:RadDatePicker ID="dtProposedStartDate" runat="server" Skin="Web20" Culture="English (United Kingdom)">
                    <Calendar UseRowHeadersAsSelectors="False" UseColumnHeadersAsSelectors="False" ViewSelectorText="x" Skin="Web20" ShowRowHeaders="False"></Calendar>
                    <DatePopupButton ImageUrl="" HoverImageUrl=""></DatePopupButton>
                    <DateInput ID="DateInput1" runat="server" DisabledStyle-ForeColor="black" Font-Names="Arial" Font-Size="10"> 
                        <IncrementSettings InterceptArrowKeys="False" InterceptMouseWheel="False" />
                        <DisabledStyle ForeColor="Black"></DisabledStyle>
                    </DateInput>
                </telerik:RadDatePicker>
                <asp:HiddenField id="hfOriginalStartDate" runat="server" />
            </td>
        </tr>
        <tr>
            <td>End Date</td>
            <td runat="server" id="tdCurrentEndDate" />
            <td style="border-right: none">
                <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional" >
                <ContentTemplate>
                    <asp:RadioButton runat="server" ID="rbProposedEndDateOption" GroupName="EndDate" OnCheckedChanged="rbDates_OnCheckedChanged" AutoPostBack="true" Checked="true" />&nbsp;&nbsp;
                    <telerik:RadDatePicker ID="dtProposedEndDate" runat="server" Skin="Web20" Culture="English (United Kingdom)" Enabled="false">
                        <Calendar UseRowHeadersAsSelectors="False" UseColumnHeadersAsSelectors="False" ViewSelectorText="x" Skin="Web20" ShowRowHeaders="False"></Calendar>
                        <DatePopupButton ImageUrl="" HoverImageUrl=""></DatePopupButton>
                        <DateInput ID="DateInput2" runat="server" DisabledStyle-ForeColor="black" Font-Names="Arial" Font-Size="10"> 
                            <IncrementSettings InterceptArrowKeys="False" InterceptMouseWheel="False" />
                            <DisabledStyle ForeColor="Black"></DisabledStyle>
                        </DateInput>
                    </telerik:RadDatePicker>
                    <br />                  
                                  
                    <asp:RadioButton runat="server" ID="rbProposedEndDateForever" GroupName="EndDate" OnCheckedChanged="rbDates_OnCheckedChanged" AutoPostBack="true" Text="Open ended" />
                    <asp:HiddenField id="hfOriginalEndDate" runat="server" />                
                </ContentTemplate>                        
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr id="trTradename" runat="server">
            <td>Trade name</td>
            <td runat="server" id="tdCurrentTradeName" />
            <td>
                <asp:TextBox runat="server" id="tbProposedTradeName" Width="98%" />
                <asp:HiddenField id="hfOriginalTradeName" runat="server" />                
            </td>
        </tr>
        <tr>
            <td>Supplier Reference</td>
            <td runat="server" id="tdCurrentReference" />
            <td>
                <asp:TextBox runat="server" id="tbProposedReference" Width="98%" />
                <asp:HiddenField id="hfOriginalReference" runat="server" />                
            </td>
        </tr>
        <tr id="trEdiBarcode" runat="server">
            <td>GTIN Barcode - Shift - F1 for list</td>
            <td runat="server" id="tdCurrentEdiBarcode" />
            <td>
                <asp:Image runat="server" ID="imgEdiBarcodeLookup" ImageUrl="..\\pharmacysharedscripts\\QuesScrl\\display_list_button.gif" AlternateText="Select value" Width="15px" Height="15px" />
                <asp:TextBox runat="server" ID="tbProposedEdiBarcode" Width="110px" BorderStyle="None" />
                <asp:HiddenField ID="hfOriginalEdiBarcode" runat="server" />
            </td>
        </tr>
        <tr>
            <td>Primary Supplier</td>
            <td runat="server" id="tdCurrentIsPrimarySupplier" />
            <td>
                <asp:CheckBox runat="server" ID="cbProposedIsPrimarySupplier" />
                <asp:HiddenField id="hfOriginalIsPrimarySupplier" runat="server" />                
            </td>
        </tr>   
        </tbody>
    </table>
            
    <br />
            
    <div>
        <asp:LinkButton runat="server" id="lbtSites" CssClass="LinkButton" Width="350px" OnClientClick="lbtSelectSites_onclick(); return false;" ToolTip="Click to change sites to replicate to" />
                
        <div id="divSites" style="display:none;">
            <div style="width:100%;height:100%">
                Select sites to replicate to:<br />
                <br />
                <div style="max-height:250px;">
                    <asp:CheckBoxList runat="server" ID="cblSites" />
                </div>                            
            </div>
        </div>
    </div>
</ContentTemplate>        
</asp:UpdatePanel>
</div>