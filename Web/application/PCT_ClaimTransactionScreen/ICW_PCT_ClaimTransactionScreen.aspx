<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_PCT_ClaimTransactionScreen.aspx.cs" Inherits="application_PCT_ClaimTransactionScreen_ICW_PCT_ClaimTransactionScreen" %>
<%@ Import Namespace="ascribe.pharmacy.shared"              %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Register src="PCTClaimItemEditForm.ascx"   tagname="PCTClaimItemEditForm"   tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%= SessionInfo.SessionID %>';
    var desktopURL = "../sharedscripts/CheckSessionExists.aspx";
    var pageName = "ICW_PCT_ClaimTransactionScreen.aspx";
    //alert(sessionId);
    //alert(desktopURL + " " + pageName);
    windowModal_CheckSession(sessionId, desktopURL, "CheckSessionExists" + "|" + pageName);
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Untitled Page</title>

    <script type="text/javascript" id="telerikClientEvents1">
//<![CDATA[

	function RadGrid1_OnRowSelected(sender,args)
	{
	    //15May13 AJK 64302 Added clientside event for changing hold button text
	    var grid = sender;
	    var MasterTable = grid.get_masterTableView(); var row = MasterTable.get_dataItems()[args.get_itemIndexHierarchical()];
	    var cell = MasterTable.getCellByColumnUniqueName(row, "Status");
	    if (cell.innerHTML.indexOf("H") !== -1) {
	        document.getElementById("btnHold").value = 'Off Hold';
	    }
	    else {
	        document.getElementById("btnHold").value = 'On Hold';
	    }
	}
//]]>
</script>
</head>
<body>
<%-- 04Apr12 AJK 31204 Added <NOBR> tags to all dataformatstrings in Grid1 columns to ensure that rows to do increase in height --%>
<%
    //ICW.ICWParameter("SiteNumber", "The Site Number", ""); 
     %>
    <script type="text/javascript">
        function CloseForm(sender, args)
        {
            window.close();
        }
        function alertCallBackFn(arg) 
        {
            window.close();
        }
        function alertUserResponse(arg)
        {
            switch (arg)
            {
                case true:
                    var hfunc = document.getElementById('<%= hdnFunction.ClientID %>');
                    hfunc.value = 'SubmitClaimFile';
                    document.forms["form1"].submit();
                    break;
                case false:
                    break;
                default:
                    break;
            }
        }
        function callConfirm()
        {
            //var hasHeld = window["<%= hdnHasHeld.ClientID %>"];
            var hasHeld = document.getElementById('<%= hdnHasHeld.ClientID %>');
            if (hasHeld.value == 'true')
            {
                var oConfirm = radconfirm('This claim file contains claim lines which have been marked as On Hold. If you wish to continue and submit this claim file the On Hold items will be moved into the next available open claim file. Do you wish to continue?', alertUserResponse);
                var elementList = $telerik.$('.rwPopupButton', oConfirm.get_popupElement());
                setTimeout(function ()
                {
                    elementList[1].focus();
                }, 0);
            }
            else
            {
                var hfunc = document.getElementById('<%= hdnFunction.ClientID %>');
                hfunc.value = 'SubmitClaimFile';
                document.forms["form1"].submit();
            }
        }
    </script>

    <form id="form1" runat="server"> 
        <asp:ScriptManager ID="ScriptManager1" runat="server">
            <Scripts>
                <asp:ScriptReference Name="Telerik.Web.UI.Common.Core.js" Assembly="Telerik.Web.UI" />
            </Scripts>
        </asp:ScriptManager>
        <input type="hidden" runat="server" id="hdnEditMode" />
        <input type="hidden" runat="server" id="hdnFunction" />
        <input type="hidden" runat="server" id="hdnHasHeld" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" Skin="Web20" 
            DecoratedControls="All" />
        <telerik:RadWindowManager ID="RadWindowManager1" runat="server">
        </telerik:RadWindowManager>
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadGrid1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadGrid11" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Web20">
        </telerik:RadAjaxLoadingPanel>
        <table>
            <tr>
                <td rowspan=2>
                    <asp:Panel ID="pnlHospitalDetails" runat="server" GroupingText="Hospital Details">
                        <table>
                            <tr>
                                <td>
                                    <label>SLA Number</label>
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="rtxtSLANumber" runat="server" Width="200px" ReadOnly=true>
                                    </telerik:RadTextBox>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    <label>Hospital Name/Address</label>
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="rtxtHospital" runat="server" Rows="6" 
                                        TextMode="MultiLine" Skin="Web20" Wrap="False" Width="200px" ReadOnly=true>
                                    </telerik:RadTextBox>
                                </td>
                            </tr>
                        </table>
                    </asp:Panel>
                </td>
                <td valign=top  rowspan=2>
                    <asp:Panel ID="pnlClaimSelection" runat="server" GroupingText="Claim Selection" >
                        <table>
                            <tr>
                                <td></td>
                                <td>
                                    <asp:RadioButton ID="optOpenClaims" runat="server" Text="Open Claims" 
                                        GroupName="optgClaimTypes" oncheckedchanged="optOpenClaims_CheckedChanged" AutoPostBack=true Skin="Web20"  />&nbsp
                                    <asp:RadioButton ID="optSubmittedClaims" runat="server" Text="Submitted Claims" 
                                        GroupName="optgClaimTypes" 
                                        oncheckedchanged="optSubmittedClaims_CheckedChanged" AutoPostBack=true Skin="Web20"  />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <label>File ID</label>
                                </td>
                                <td>
                                    <telerik:RadComboBox ID="rcboFiles" runat="server" Width="210px" Skin="Web20" 
                                        onselectedindexchanged="rcboFiles_SelectedIndexChanged" AutoPostBack=true>
                                    </telerik:RadComboBox>
                                </td>
                            </tr>
                        </table>
                    </asp:Panel>
                </td>
                <td valign=top  rowspan=2>
                    <asp:Panel ID="pnlClaimSummary" runat="server" GroupingText="Claim Summary" >
                        <table>
                            <tr>
                                <td>
                                    <label>Number of Lines</label>
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="rtxtNumberOfLines" Skin="Web20"  runat="server" Width="80px" ReadOnly=true>
                                    </telerik:RadTextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <label>Total Claim Value</label>
                                </td>
                                <td>
                                    <telerik:RadNumericTextBox ID="rntxtTotalClaimValue" runat="server" Skin="Web20" 
                                        Culture="English (New Zealand)" Type="Currency" Width="80px" ReadOnly=true>
                                    </telerik:RadNumericTextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <label>Recalculated Claim Value</label>
                                </td>
                                <td>
                                    <telerik:RadNumericTextBox ID="rntxtRecalculatedClaimValue" runat="server" Skin="Web20" 
                                        Culture="English (New Zealand)" Type="Currency" Width="80px" ReadOnly=true>
                                    </telerik:RadNumericTextBox>
                                </td>
                            </tr>
                        </table>
                    </asp:Panel>
                </td>
                <td valign=top>
                    <asp:Panel ID="pnlClaimDateDetails" runat="server" GroupingText="Claim Date Details" >
                        <table>
                            <tr>
                                <td>
                                    <label>Claim Date</label>
                                </td>
                                <td>
                                    <telerik:RadDateInput ID="rdatClaimDate" runat="server" Width="70px" ReadOnly=true Skin="Web20" > 
                                    </telerik:RadDateInput>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <label>File Date</label>
                                </td>
                                <td>
                                    <telerik:RadDateInput ID="rdatFileDate" runat="server" Width="70px" ReadOnly=true Skin="Web20" >
                                    </telerik:RadDateInput>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <label>Schedule Date</label>
                                </td>
                                <td>
                                    <telerik:RadDateInput ID="rdatScheduleDate" runat="server" Width="70px" ReadOnly=true Skin="Web20" >
                                    </telerik:RadDateInput>
                                </td>
                            </tr>
                        </table>
                    </asp:Panel>
                </td>
            </tr>
            <tr>
                <td align=right valign=bottom>
                    <button runat="server" id="btnSubmitClaim" onclick="callConfirm()" width="60px">Submit Claim</button>
                </td>
            </tr>
            <tr>
                <td colspan=7>
                    <hr />
                </td>
            </tr>
        </table>
       
        <telerik:RadGrid ID="RadGrid1" runat="server" AutoGenerateColumns="False" 
            CellSpacing="0" GridLines="None" AllowSorting="True" 
            onneeddatasource="RadGrid1_NeedDataSource" AllowPaging="True" 
            Height="430px" onitemdatabound="RadGrid1_ItemDataBound" PageSize="14" 
            oneditcommand="RadGrid1_EditCommand" 
            onpageindexchanged="RadGrid1_PageIndexChanged"
            onsortcommand="RadGrid1_SortCommand" onupdatecommand="RadGrid1_UpdateCommand" 
            Skin="Web20" oncancelcommand="RadGrid1_CancelCommand" 
            onprerender="RadGrid1_PreRender" >
        <HeaderContextMenu CssClass="GridContextMenu GridContextMenu_Default"></HeaderContextMenu>

        <MasterTableView DataKeyNames="PCTClaimTransactionID">
            <CommandItemSettings ExportToPdfText="Export to PDF"></CommandItemSettings>

            <RowIndicatorColumn FilterControlAltText="Filter RowIndicator column">
            </RowIndicatorColumn>

            <ExpandCollapseColumn FilterControlAltText="Filter ExpandColumn column">
            </ExpandCollapseColumn>

            <Columns>
                <telerik:GridEditCommandColumn FilterControlAltText="Filter EditCommandColumn column">
                </telerik:GridEditCommandColumn>
                
                <telerik:GridBoundColumn DataField="Status" 
                    FilterControlAltText="Filter Status column" HeaderText="Status" 
                    UniqueName="Status" DataFormatString="<nobr>{0}</nobr>">
                </telerik:GridBoundColumn>
                
                <telerik:GridBoundColumn FilterControlAltText="Filter Category column" 
                    HeaderText="Category" MaxLength="1" UniqueName="Category"  DataFormatString="<nobr>{0}</nobr>"
                    DataField="Category">
                </telerik:GridBoundColumn>
                <telerik:GridNumericColumn AllowFiltering="False" AllowSorting="False" 
                    DataType="System.Int32" DecimalDigits="0" 
                    FilterControlAltText="Filter ComponentNumber column" Groupable="False" 
                    HeaderText="Comp#" HeaderTooltip="Component Number" ShowSortIcon="False"  DataFormatString="<nobr>{0}</nobr>"
                    UniqueName="ComponentNumber" DataField="ComponentNumber">
                </telerik:GridNumericColumn>
                <telerik:GridNumericColumn AllowFiltering="False" AllowSorting="False" 
                    DataType="System.Int32" DecimalDigits="0" 
                    FilterControlAltText="Filter TotalComponentNumber column" Groupable="False" 
                    HeaderText="TotalComp" HeaderTooltip="Total Component Number" 
                    ShowSortIcon="False" UniqueName="TotalComponentNumber"  DataFormatString="<nobr>{0}</nobr>"
                    DataField="TotalComponentNumber">
                </telerik:GridNumericColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter PrescriberID column" 
                    UniqueName="PrescriberID" HeaderText="Prescriber ID" MaxLength="10"  DataFormatString="<nobr>{0}</nobr>"
                    DataField="PrescriberID">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter Health Professional Group Code column" 
                    HeaderText="HPGC" HeaderTooltip="Health Professional Group Code" MaxLength="2"  DataFormatString="<nobr>{0}</nobr>"
                    UniqueName="HealthProfessionalGroupCode" 
                    DataField="HealthProfessionalGroupCode">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter SpecialistID column" 
                    HeaderText="Specialist ID" HeaderTooltip="Specialist ID" MaxLength="10"  DataFormatString="<nobr>{0}</nobr>"
                    UniqueName="SpecialistID" DataField="SpecialistID">
                </telerik:GridBoundColumn>
                <telerik:GridDateTimeColumn 
                    DataType="System.DateTime" 
                    FilterControlAltText="Filter Endorsement Date column" HeaderText="Endorsement" 
                    HeaderTooltip="Endorrsement Date" UniqueName="EndorsementDate"  DataFormatString="{0:dd/MM/yyyy}"
                    DataField="EndorsementDate" MinDate="1980-01-01">
                </telerik:GridDateTimeColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter Prescriber Flag column" 
                    HeaderText="Flag" HeaderTooltip="Prescriber Flag" MaxLength="1"  DataFormatString="<nobr>{0}</nobr>"
                    UniqueName="PrescriberFlag" DataField="PrescriberFlag">
                </telerik:GridBoundColumn>
                <telerik:GridNumericColumn DataType="System.Int16" DecimalDigits="0" 
                    FilterControlAltText="Filter Oncology Patient Grouping column"  DataFormatString="<nobr>{0}</nobr>"
                    HeaderText="GroupID" MaxLength="1" UniqueName="OncologyPatientGrouping" 
                    DataField="PCTOncologyPatientGrouping">
                </telerik:GridNumericColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter NHI Number column" 
                    HeaderText="NHI#" HeaderTooltip="NHI Number" MaxLength="7"  DataFormatString="<nobr>{0}</nobr>"
                    UniqueName="NHINumber" DataField="NHI">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter Patient Category column" 
                    HeaderText="Patient Category" MaxLength="1" UniqueName="PatientCategory"  DataFormatString="<nobr>{0}</nobr>"
                    DataField="PCTPatientCategory">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter CSC or PHO Status Flag column" 
                    HeaderText="CSC/PHO" HeaderTooltip="CSC or PHO Status Flag" MaxLength="1"  DataFormatString="<nobr>{0}</nobr>"
                    UniqueName="CSCorPHOStatusFlag" DataField="CSCorPHOStatusFlag">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter HUHC Status Flag column" 
                    HeaderText="HUHC" HeaderTooltip="HUHC Status Flag" MaxLength="1"  DataFormatString="<nobr>{0}</nobr>"
                    UniqueName="HUHCStatusFlag" DataField="HUHCStatusFlag">
                </telerik:GridBoundColumn>
                <telerik:GridNumericColumn DataType="System.Int32" DecimalDigits="0" 
                    FilterControlAltText="Filter Special Authority Number column" 
                    HeaderText="SA Num" HeaderTooltip="Special Authority Number"  DataFormatString="<nobr>{0}</nobr>"
                    UniqueName="SpecialAuthorityNumber" DataField="SpecialAuthorityNumber">
                </telerik:GridNumericColumn>
                <telerik:GridNumericColumn DataType="System.Decimal" DecimalDigits="4"  DataFormatString="<nobr>{0}</nobr>"
                    FilterControlAltText="Filter Dose column" HeaderText="Dose" MaxLength="11" 
                    UniqueName="Dose" DataField="Dose">
                </telerik:GridNumericColumn>
                <telerik:GridNumericColumn DecimalDigits="4" 
                    FilterControlAltText="Filter Daily Dose column" HeaderText="DailyDose"  DataFormatString="<nobr>{0}</nobr>"
                    UniqueName="DailyDose" DataField="DailyDose">
                </telerik:GridNumericColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter Prescription Flag column" 
                    HeaderText="Rx Flag" HeaderTooltip="Prescriptin Flag" MaxLength="1"  DataFormatString="<nobr>{0}</nobr>"
                    UniqueName="PrescriptionFlag" DataField="PrescriptionFlag">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter Dose Flag column" 
                    HeaderText="Dose Flag" MaxLength="1" UniqueName="DoseFlag"  DataFormatString="<nobr>{0}</nobr>"
                    DataField="DoseFlag">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter Prescription ID column" 
                    HeaderText="Rx ID" MaxLength="9" UniqueName="PrescriptionID" DataFormatString="<nobr>{0}</nobr>"
                    DataField="PrescriptionID">
                </telerik:GridBoundColumn>
                <telerik:GridBoundColumn DataField="PrescriptionSuffix"  DataFormatString="<nobr>{0}</nobr>"
                    FilterControlAltText="Filter Prescription ID Suffix column" HeaderText="Suffix" 
                    MaxLength="2" UniqueName="PrescriptionIDSuffix">
                </telerik:GridBoundColumn>
                <telerik:GridDateTimeColumn 
                    DataType="System.DateTime" FilterControlAltText="Filter Service Date column" 
                    HeaderText="ServiceDate" HeaderTooltip="Service Date"  DataFormatString="{0:dd/MM/yyyy}"
                    UniqueName="ServiceDate" DataField="ServiceDate" MinDate="1980-01-01">
                </telerik:GridDateTimeColumn>
                <telerik:GridNumericColumn DecimalDigits="0"  DataFormatString="<nobr>{0}</nobr>"
                    FilterControlAltText="Filter ClaimCode column" HeaderText="ClaimCode" UniqueName="ClaimCode" 
                    DataField="ClaimCode" MaxLength="16">
                </telerik:GridNumericColumn>
                <telerik:GridNumericColumn DecimalDigits="4"  DataFormatString="<nobr>{0}</nobr>"
                    FilterControlAltText="Filter QuantityClaimed column" HeaderText="Qty Claimed" 
                    HeaderTooltip="Quantity Claimed" MaxLength="11" 
                    UniqueName="QuantityClaimed" DataField="QuantityClaimed">
                </telerik:GridNumericColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter PackUnitOfMeasure column" 
                    HeaderText="PUoM" HeaderTooltip="Pack Unit of Measure" MaxLength="8"  DataFormatString="<nobr>{0}</nobr>"
                    UniqueName="PackUnitOfMeasure" DataField="PackUnitOfMeasure">
                </telerik:GridBoundColumn>
                <telerik:GridNumericColumn DecimalDigits="0"  DataFormatString="<nobr>{0}</nobr>"
                    FilterControlAltText="Filter ClaimAmount column" HeaderText="Amount" 
                    HeaderTooltip="Claim Amount" MaxLength="9" UniqueName="ClaimAmount" 
                    DataField="ClaimAmount">
                </telerik:GridNumericColumn>
                <telerik:GridNumericColumn DecimalDigits="0"  DataFormatString="<nobr>{0}</nobr>"
                    FilterControlAltText="Filter CBS Subsidy column" HeaderText="CBS Sub" 
                    HeaderTooltip="CBS Subisdy" MaxLength="9" UniqueName="CBSSubsidy" 
                    DataField="CBSSubsidy">
                </telerik:GridNumericColumn>
                <telerik:GridNumericColumn DecimalDigits="4"  DataFormatString="<nobr>{0}</nobr>"
                    FilterControlAltText="Filter CBS Packsize column" HeaderText="CBS Pack" 
                    HeaderTooltip="CBS Packsize" MaxLength="11" UniqueName="CBSPacksize" 
                    DataField="CBSPacksize">
                </telerik:GridNumericColumn>
                <telerik:GridBoundColumn FilterControlAltText="Filter Funder column"  DataFormatString="<nobr>{0}</nobr>"
                    HeaderText="Funder" MaxLength="3" UniqueName="Funder" DataField="Funder">
                </telerik:GridBoundColumn>
                <telerik:GridNumericColumn DecimalDigits="0" 
                    FilterControlAltText="Filter Form Number column" HeaderText="Form Num"  DataFormatString="<nobr>{0}</nobr>"
                    HeaderTooltip="Form Number" MaxLength="9" UniqueName="FormNumber" 
                    DataField="FormNumber">
                </telerik:GridNumericColumn>
            </Columns>

            <EditFormSettings UserControlName="PCTClaimItemEditForm.ascx" EditFormType="WebUserControl">
                <EditColumn FilterControlAltText="Filter EditCommandColumn column" 
                    UniqueName="EditCommandColumn1"></EditColumn>
            </EditFormSettings>
            <EditItemStyle BackColor="#C0C0FF" />
        </MasterTableView>

        <ClientSettings>
            <Selecting AllowRowSelect="True" EnableDragToSelectRows="False" />
            <ClientEvents OnRowSelected="RadGrid1_OnRowSelected" />
            <Scrolling AllowScroll="True" />
        </ClientSettings>

        <FilterMenu EnableImageSprites="False"></FilterMenu>
        
        
    </telerik:RadGrid>
        <br />
        <asp:Button ID="btnCredit" runat="server" Text="Credit" 
            onclick="btnCredit_Click" Enabled="false" />&nbsp
        <asp:Button ID="btnResend" runat="server" Text="Resend" Enabled="false" 
            onclick="btnResend_Click" />&nbsp
        <asp:Button ID="btnHold" runat="server" Text="On Hold" Enabled="false" 
            onclick="btnHold_Click" />&nbsp
        <asp:Button ID="btnRemove" runat="server" Text="Remove" 
            onclick="btnRemove_Click" />
        
    </form>
    <iframe id="CheckSessionExists" application="yes" style="display: none;"></iframe>
</body>
</html>
