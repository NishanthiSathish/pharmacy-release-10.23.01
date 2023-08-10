<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_ContractImport.aspx.cs" Inherits="application_ContractImport_ICW_ContractImport" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Register src="../pharmacysharedscripts/SiteColourPanelControl.ascx" tagname="SiteColourPanelControl" tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SiteNamePanelControl.ascx"   tagname="SiteNamePanelControl"   tagprefix="uc" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%
    //ICW.ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", "") 
%>
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%= SessionInfo.SessionID %>';
    var desktopURL = "../sharedscripts/CheckSessionExists.aspx";
    var pageName = "ICW_ContractImport.aspx";
    //alert(sessionId);
    //alert(desktopURL + " " + pageName);
    windowModal_CheckSession(sessionId, desktopURL, "CheckSessionExists" + "|" + pageName);
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    
    <link href="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    
    <script src="../sharedscripts/lib/jquery-1.6.4.min.js"               type="text/javascript" async></script>
    <script src="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  type="text/javascript" defer></script>
    <script src="../sharedscripts/lib/json2.js"                          type="text/javascript" defer></script>
    <script src="../pharmacysharedscripts/pharmacyscript.js"             type="text/javascript" defer></script>
    <script src="../sharedscripts/lib/jquery.blockUI.js"                 type="text/javascript" defer></script>
<%--    <script type="text/javascript" src="../sharedscripts/icw.js"></script>--%>    
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
    <script type="text/javascript">
            var sessionID = <%= SessionInfo.SessionID %>;

            function PostServerMessage(url, data)
            {
	            var result;
	            $.ajax({
		            type: "POST",
		            url: url,
		            data: data,
		            contentType: "application/json; charset=utf-8",
		            dataType: "json",
		            async: false,
		            success: function(msg)
		            {
			            result = msg;
		            }
	            });
	            return result;
	        } 

            function form_onunload()
            {
               var parameters = { sessionID: sessionID };
               PostServerMessage("ICW_ContractImport.aspx/CleanUp", JSON.stringify(parameters));
            }
            
            function form_onkeydown(event)
            {
                switch (event.keyCode)
                {
                case 115: LaunchItemEnquiry(); break;    // F4
                }
            }       
            
            // Called when grid created to size grid
            // XN 30Dec14 101819
            function RadGrid1_OnGridCreated(sender, args)
            {
                resizeGrid();
            }
            
            function RadGrid1_ActiveRowChanged(sender, args)
            {
               if (sender.get_masterTableView().get_selectedItems().length < 1 || sender.get_masterTableView().get_selectedItems()[0].get_id() != args.get_id())
                   args.get_tableView().selectItem($get(args.get_id()));           
            }
            
            function FileUploaded() 
            {
                var myButton = $find("<%= btnProcess.ClientID %>");
                myButton.set_visible(true);
                myButton.set_enabled(true);
            }
            
            function FileRemoved()
            {
                var myButton = $find("<%= btnProcess.ClientID %>");
                myButton.set_visible(false);
                myButton.set_enabled(false);
            }

            function LaunchProductSearch() {

                var strURL = document.URL;
                var intSplitIndex = strURL.indexOf('?');
                var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

                var result = window.showModalDialog('../PharmacyProductSearch/PharmacyProductSearchModal.aspx' + strURLParameters + '&VB6Style=false', '', 'dialogHeight:600px; dialogWidth:850px; status:off; center: Yes');
                if (result == 'logoutFromActivityTimeout') {
                    result = null;
                    window.close();
                    window.parent.close();
                    window.parent.ICWWindow().Exit();
                }

                if (result != null) {
                    var hdnSPDID = document.getElementById("<%= hdnSiteProductDataID.ClientID %>");
                    if (result.indexOf("|") > -1) 
                    {
                        hdnSPDID.value = result.substring(0, result.indexOf("|"));
                        __doPostBack('upPanel', 'LinkProductToNPCCOde:' + hdnSPDID.value);
                    }
                }
            }

            function LaunchAddNew() 
            {                
                // Validate selection!!
                var cmuContractID = document.getElementById('hdnCMUContractID').value;
                if (cmuContractID == '')
                {
                    alert('Select a CMU contract row');
                    return;
                }
                
                var nsvCode = document.getElementById('hdnNSVCode').value;
                if (nsvCode == '')
                {
                    alert('Need to link a product to the contract row');
                    return;
                }               
                
                // Build url string
                var strURL = document.URL;
                var intSplitIndex = strURL.indexOf('?');
                var strURLParameters = strURL.substring(intSplitIndex, strURL.length);
                strURLParameters += '&PharmacyCMUContractID=' + cmuContractID;
                strURLParameters += '&NSVCode='               + nsvCode;
                
                // Call contract editor
                var result = window.showModalDialog('SupplierToContractEditor.aspx' + strURLParameters, '', 'status:off; center: Yes');
                if (result == 'logoutFromActivityTimeout') {
                    result = null;
                    window.close();
                    window.parent.close();
                    window.parent.ICWWindow().Exit();
                }

                if (result != undefined)
                    __doPostBack('upPanel', 'NewSupplier:' + result);
            }

            function LaunchEditDetails() 
            {
                // Validate selection!!
                var cmuContractID = $('#hdnCMUContractID').val();
                if (cmuContractID == '')
                {
                    alert('Select a contract row');
                    return;
                }
                
                var nsvCode           = $('#hdnNSVCode'          ).val();
                var supplierProfileID = $('#hdnSupplierProfileID').val();
                if (nsvCode == '' || supplierProfileID == '')
                {
                    alert('Need to link a product to the contract row');
                    return;
                }
                
                var isExternamSupplier = $('#hdnIsExtrernalSupplier').val();
                if (isExternamSupplier.toLowerCase() != 'true')
                {                
                    alert("Supplier is an internal supplier.");
                    return;
                }
                
                // Build url string
                var strURL = document.URL;
                var intSplitIndex = strURL.indexOf('?');
                var strURLParameters = strURL.substring(intSplitIndex, strURL.length);
                strURLParameters += '&PharmacyCMUContractID=' + cmuContractID;
                strURLParameters += '&WSupplierProfileID='    + supplierProfileID;
                strURLParameters += '&NSVCode='               + nsvCode;
                
                // Call contract editor
                var result = window.showModalDialog('SupplierToContractEditor.aspx' + strURLParameters, '', 'status:off; center: Yes');
                if (result == 'logoutFromActivityTimeout') {
                    ret = null;
                    window.close();
                    window.parent.close();
                    window.parent.ICWWindow().Exit();
                }

                if (result != undefined)
                    __doPostBack('upPanel', 'NewSupplier:' + result);
            }
            
            function LaunchItemEnquiry()
            {
                var strURL           = document.URL;
                var intSplitIndex    = strURL.indexOf('?');
                var strURLParameters = strURL.substring(intSplitIndex, strURL.length);
                var NSVCode          = $('#hdnNSVCode').val();

                //  check if product is selected XN 8Jun15 119082
                if (NSVCode == '')
                {
                    if ($('#hdnCMUContractID').val() == '')
                        alert('No CMU product selected');
                    else 
                        alert('Need to link a product to the contract row');
                }
                else
                {
                    strURLParameters += '&NSVCode=' + $('#hdnNSVCode').val();
                    var ret = window.showModalDialog('../StoresDrugInfoView/ICW_StoresDrugInfoView.aspx' + strURLParameters, '', 'dialogHeight:735px; dialogWidth:865px; status:off; center: Yes'); // 30Jul15 XN 121034 Changed from using StoresDrugInfoViewModal.aspx to main ICW_StoresDrugInfoView.aspx'
                    if (ret == 'logoutFromActivityTimeout') {
                        ret = null;
                        window.close();
                        window.parent.close();
                        window.parent.ICWWindow().Exit();
                    }
                }
            }
        
            // Called to better size grid
            // XN 30Dec14 101819
            function resizeGrid()
            {
                var radGrid1 = $find("<%= RadGrid1.ClientID %>");
                if (radGrid1 != undefined && radGrid1.get_visible())
                {
                    var windowHeight      = $(window).height();
                    var heightMainTable   = 300;                                // hardcode to 300 as it can change size (so 300px is the max t should be)
                    var heightGridHeader  = $(radGrid1.GridHeaderDiv).height(); // height of grid header 
                    var heightGridFooter  = $(".rgPager").height();             // height of grid footer
                    var extraSpacing      = 70;                                 // height of extra item like site header, and spaces

                    var gridHeight  = windowHeight - heightMainTable - heightGridHeader - heightGridFooter - extraSpacing;

                    // Grid does not need to be bigger than 300 else will be needless white space at bottom
                    if (gridHeight > 350)
                        gridHeight = 350;
                    if (gridHeight > 0)
                        radGrid1.GridDataDiv.style.height = gridHeight + "px";
                }
            }        
    </script>
    </telerik:RadScriptBlock>

</head>
<body onunload="form_onunload();" onkeydown="form_onkeydown(event);">
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" Skin="Web20" />
    <form id="frmMain" runat="server">
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server">
    </telerik:RadStyleSheetManager>
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
        <Scripts>
            <asp:ScriptReference Assembly="Telerik.Web.UI" Name="Telerik.Web.UI.Common.Core.js">
            </asp:ScriptReference>
            <asp:ScriptReference Assembly="Telerik.Web.UI" Name="Telerik.Web.UI.Common.jQuery.js">
            </asp:ScriptReference>
            <asp:ScriptReference Assembly="Telerik.Web.UI" Name="Telerik.Web.UI.Common.jQueryInclude.js">
            </asp:ScriptReference>
        </Scripts>
    </telerik:RadScriptManager>
    <telerik:RadAjaxPanel ID="upPanel" runat="server" ClientEvents-OnRequestStart="$.blockUI();" ClientEvents-OnResponseEnd="$.unblockUI();">
    <table id="tblUploadFile" runat="server">
        <tr style="padding-top: 5px;">
            <td style="padding-top: 5px;">
                <telerik:RadAsyncUpload ID="RadAsyncUpload1" runat="server" AllowedFileExtensions="csv"
                    Culture="English (United Kingdom)" OnFileUploaded="RadAsyncUpload1_FileUploaded"
                    Skin="Web20" TemporaryFileExpiration="00:10:00" OnClientFileUploaded="FileUploaded" OnClientFileUploadRemoved="FileRemoved"
                    TemporaryFolder="../../App_Data/RadUploadTemp" MaxFileInputsCount="1" DisablePlugins="true">
                    <Localization Select="Select File" />
                </telerik:RadAsyncUpload>
            </td>
            <td style="padding-top: 5px;">
                <telerik:RadButton ID="btnProcess" runat="server" Text="Process File" Skin="Web20" Enabled="False" OnClick="btnProcess_Click" AutoPostBack="true" style="display:none;" />
            </td>
        </tr>
    </table>
    <table width="100%" onresize="resizeGrid();">
        <tr>
            <td>
                <table id="tableSiteInfo" runat="server" cellpadding="0" cellspacing="0" style="width: 1020px; height:25px; background-color: #DDDDDD;">
                    <tr>
                        <td><uc:SiteNamePanelControl ID="siteNamePanel" runat="server" /></td>
                        <td id="siteInfoText" runat="server" style="text-align:right; padding-right:8px;" >&nbsp;</td>
                        <td style="width:4%;"><uc:SiteColourPanelControl ID="siteColourPanel" runat="server" /></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr runat="server" id="rowGrid">
            <td>
                <telerik:RadGrid ID="RadGrid1" runat="server" AllowFilteringByColumn="True" AllowSorting="True"
                    CellSpacing="0" GridLines="None" Skin="Web20" OnNeedDataSource="RadGrid1_NeedDataSource"
                    OnPreRender="RadGrid1_PreRender" AutoGenerateColumns="False" Width="1020px" AllowPaging="True"
                    OnSelectedIndexChanged="RadGrid1_SelectedIndexChanged">
                    <GroupingSettings CaseSensitive="false" />
                    <MasterTableView DataKeyNames="PharmacyCMUContractID">
                        <CommandItemSettings ExportToPdfText="Export to PDF"></CommandItemSettings>
                        <RowIndicatorColumn Visible="True" FilterControlAltText="Filter RowIndicator column">
                            <HeaderStyle Width="20px"></HeaderStyle>
                        </RowIndicatorColumn>
                        <ExpandCollapseColumn Visible="True" FilterControlAltText="Filter ExpandColumn column">
                            <HeaderStyle Width="20px"></HeaderStyle>
                        </ExpandCollapseColumn>
                        <Columns>
                            <telerik:GridBoundColumn AutoPostBackOnFilter="True" DataField="GenericDescription"
                                FilterControlAltText="Filter description" HeaderText="Description" HeaderTooltip="Generic description"
                                UniqueName="GenericDescription" ShowFilterIcon="False" HeaderStyle-Width="30%">
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn AllowFiltering="False" DataField="PackSize" FilterControlAltText="Filter PackSize column"
                                HeaderText="Pack Size" HeaderStyle-Width="70px" ShowFilterIcon="False" UniqueName="PackSize" ItemStyle-HorizontalAlign="Right">
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn AllowFiltering="False" DataField="BrandName" FilterControlAltText="Filter BrandName column"
                                HeaderText="Brand Name" UniqueName="BrandName" HeaderStyle-Width="15%">
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn AutoPostBackOnFilter="True" DataField="NPCCode" FilterControlAltText="Filter NPC Code column"
                                HeaderText="NPC Code" HeaderStyle-Width="75px" UniqueName="NPCCode" ShowFilterIcon="False" ItemStyle-HorizontalAlign="Right">
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn AllowFiltering="False" AllowSorting="False" DataField="MinOrderQuantity"
                                FilterControlAltText="Filter Min Qty column" HeaderText="Min Qty" HeaderTooltip="Minimum Order Quantity"
                                HeaderStyle-Width="65px" UniqueName="MinQty" ShowFilterIcon="False" ItemStyle-HorizontalAlign="Right">
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn AllowFiltering="False" AllowSorting="False" DataField="OrderFrom"
                                FilterControlAltText="Filter OrderFrom column" HeaderText="Order From" UniqueName="OrderFrom"
                                 HeaderStyle-Width="25%">
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn AllowFiltering="False" DataField="PriceInPounds" FilterControlAltText="Filter Price column"
                                HeaderText="Price (£)" UniqueName="Price" DataType="System.Decimal" HeaderStyle-Width="65px" ItemStyle-HorizontalAlign="Right">
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn AllowFiltering="False" DataField="RecordStatusStartDate"
                                DataType="System.DateTime" FilterControlAltText="Filter From column" DataFormatString="{0:dd/MM/yyyy}"
                                HeaderText="From" HeaderTooltip="Record status start date" UniqueName="From"
                                HtmlEncode="false" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Right">
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn AllowFiltering="False" DataField="RecordStatusEndDate" DataType="System.DateTime"
                                FilterControlAltText="Filter From column" DataFormatString="{0:dd/MM/yyyy}" HeaderText="End"
                                HeaderTooltip="Record status end date" UniqueName="End" HtmlEncode="false" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Right">
                            </telerik:GridBoundColumn>
                        </Columns>
                        <EditFormSettings>
                            <EditColumn FilterControlAltText="Filter EditCommandColumn column">
                            </EditColumn>
                        </EditFormSettings>
                    </MasterTableView>
                    <ClientSettings EnablePostBackOnRowClick="True">
                        <Selecting AllowRowSelect="True" />
                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                        <ClientEvents OnGridCreated="RadGrid1_OnGridCreated" />
                    </ClientSettings>
                    <FilterMenu EnableImageSprites="False">
                    </FilterMenu>
                </telerik:RadGrid>
            </td>
        </tr>
        <tr>
            <td>
                <table runat="server" id="tblMain" border="1" style="font-family: Arial" width="1020px">
                    <thead>
                        <tr display="none">
                            <td width="100px" />

                            <td width="130px" />
                            <td width="100px" />
                            <td width="130px" />
                            
                            <td width="460px" />
                        </tr>
                    </thead>
                    <tbody>
                        <tr style="background-color: #537AB8; color: #FFFFFF;">
                            <td />
                            <td colspan="3" runat="server" id="CMUHeader" style="vertical-align: text-top;" />
                            <td runat="server" id="AscribeHeader" style="vertical-align: text-top;" />
                        </tr>
                        <tr>
                            <td>
                                Order From
                            </td>
                            <td colspan="3" runat="server" id="cmuOrderFrom">
                            </td>
                            <td id="ascSupplierType">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Contract
                            </td>
                            <td colspan="3" runat="server" id="cmuContractReference">
                            </td>
                            <td runat="server" id="priContractReference">
                            </td>
                        </tr>
                        <tr>
                            <td>Price (£)</td>
                            <td runat="server" id="cmuPrice" />
                            <td style="text-align:right;" >Min Qty</td>
                            <td runat="server" id="cmuMinQty" />
                            <td runat="server" id="priPrice" />
                        </tr>
                        <tr>
                            <td>
                                Valid
                            </td>
                            <td colspan="3" runat="server" id="cmuValid">
                            </td>
                            <td runat="server" id="priValid">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Trade name
                            </td>
                            <td colspan="3" runat="server" id="cmuTradeName">
                            </td>
                            <td runat="server" id="priTradeName">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Lead time
                            </td>
                            <td colspan="3" runat="server" id="cmuLeadTime">
                            </td>
                            <td runat="server" id="tdNavigate" rowspan="3">
                                <div>
                                    <telerik:RadSlider ID="rsliderProfiles" runat="server" Skin="Web20" Visible="false" DecreaseText="Previous" IncreaseText="Next" LiveDrag="False"  AutoPostBack="True" Width="445px" OnValueChanged="rsliderProfiles_OnValueChanged" /><br />
                                    <telerik:RadAjaxPanel ID="upHiddenFields" runat="server">
                                        <asp:HiddenField ID="hdnLoaded"                      Value="0"      runat="server" />
                                        <asp:HiddenField ID="hdnSiteProductDataID"           Value=""       runat="server" />
                                        <asp:HiddenField ID="hdnNSVCode"                     Value=""       runat="server" />
                                        <asp:HiddenField ID="hdnSupplierProfileID"           Value=""       runat="server" />
                                        <asp:HiddenField ID="hdnCMUContractID"               Value=""       runat="server" />
                                        <asp:HiddenField ID="hdnIsExtrernalSupplier"         Value="false"  runat="server" />
                                        
                                        <asp:Button id="btnProdSearch"  OnClientClick="LaunchProductSearch(); return false;" runat="server" Width="140px" Accesskey="l" Text="Edit Link"    />
                                        <asp:Button id="btnDeleteLink"  OnClick="btnDeleteLink_OnClick"                      runat="server" Width="140px" Accesskey="d" Text="Delete Link"  />
                                        <asp:Button id="btnItemEnquiry" OnClientClick="LaunchItemEnquiry(); return false;"   runat="server" Width="140px" Text="Item Enquiry"  />
                                        <br />
                                        <asp:Button id="btnEdit"                    OnClientClick="LaunchEditDetails(); return false;"  runat="server" Width="140px" Accesskey="e" Text="Edit Details"      />
                                        <asp:Button id="btnAddNew"                  OnClientClick="LaunchAddNew(); return false;"       runat="server" Width="140px" Accesskey="n" Text="Add Sup Profile"   />
                                        <asp:Button id="btnDeleteSupplierProfile"   OnClick="btnDeleteSupplierProfile_OnClick"          runat="server" Width="140px" Text="Delete Sup Profile" />
                                    </telerik:RadAjaxPanel>            
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                MOV (£)
                            </td>
                            <td colspan="3" runat="server" id="cmuMinOrdValue">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Delivery (£)
                            </td>
                            <td colspan="3" runat="server" id="cmuDeliveryCharge">
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
    </table>
    </telerik:RadAjaxPanel>
    </form>
    <iframe id="CheckSessionExists" application="yes" style="display: none;"></iframe>
</body>
</html>
