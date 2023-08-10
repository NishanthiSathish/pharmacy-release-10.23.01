<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SupplierToContractEditor.aspx.cs" Inherits="application_ContractInformation_SupplierToContractEditor" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx" tagname="ProgressMessage" tagprefix="pc" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "SupplierToContractEditor.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Contract Editor for site <%= ascribe.pharmacy.shared.SessionInfo.SiteNumber.ToString() %></title>
    <base target=_self>
    
    <link href="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="style/SupplierToContractEditor.css"                         rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../sharedscripts/json2.js"                              defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
    <script type="text/javascript" src="script/SupplierToContractEditor.js"                     async></script>
    <script type="text/javascript">
        SizeAndCentreWindow("750px", "650px");
                
        var selectGTINByDefault = <%= ContractEditorSettings.ContractEditor.SelectGTINByDefault.ToString().ToLower() %>;
    </script>
    
    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->    
</head>
<body onload="form_onload();" onkeydown="form_onkeydown(event)" onbeforeunload="form_onbeforeunload();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div>
    <asp:UpdatePanel ID="upMain" runat="server">
    <ContentTemplate>        
        <asp:HiddenField runat="server" ID="hfSupCode"                    />
        <asp:HiddenField runat="server" ID="hfWExtraDrugDetailID_Pending" />
        <asp:HiddenField runat="server" ID="hfIsAMPP"        />
        <table runat="server" class="MainTable" id="tblMain" border="1" width="100%" >
            <thead>
                <tr display="none">
                    <td width="16%" />
                    
                    <td width="15%" />
                    <td width="27%" />
                    
                    <td width="13%" />
                    <td width="12%" />
                    <td width="10%" />
                    <td width="7%"  />
                </tr>
            </thead> 
            <tbody>
            <tr class="HeaderRow">
                <td />
                <td colspan="2" runat="server" id="AscribeHeader">
                    Pharmacy current data for:<br />
                    ACETAZOLAMIDE 250mg TABLETS (112)<br />
                    Pack size: 112<br />
                    NSV code: ABC123A<br />
                </td>
                <td colspan="4" runat="server" id="CMUHeader">
                    CMU Contract data for :
                    <br />
                    ACETAZOLAMIDE TABLETS 250MG<br />
                    Pack size: 112<br />
                    NPC code: DCD080<br />
                </td>
            </tr>
            <tr>
                <td>Order From</td>
                <td colspan="2"><asp:LinkButton runat="server" id="ascSupplier" CssClass="LinkButton" OnClientClick="lbtnSupplier_onclick(false); return false;" /></td> 
                <td colspan="4"><asp:Label runat="server" id="cmuOrderFrom" /></td>
            </tr>
            <tr>
                <td>Contract Reference</td>
                <td colspan="2" style="text-align:right"><asp:Label runat="server" id="ascContractReference" /></td>
                <td colspan="4" style="text-align:right"><asp:Label runat="server" id="cmuContractReference" /></td>
            </tr>
            <tr>
                <td>Price</td>
                <td colspan="2" style="text-align:right"><asp:Label runat="server" id="ascPrice" /></td>
                <td>Price</td>
                <td style="text-align:left"><asp:Label runat="server" id="cmuPrice" /></td>
                <td style="text-align:right">Min Qty</td>
                <td><asp:Label runat="server" id="cmuMinQty" /></td>
            </tr>
            <tr>
                <td>Valid</td>
                <td colspan="2" style="text-align:right"><asp:Label runat="server" id="ascValid" /></td>
                <td colspan="4" style="text-align:right"><asp:Label runat="server" id="cmuValid" /></td>
            </tr>
            <tr>
                <td>Trade name</td>
                <td colspan="2" runat="server" id="ascTradeName"></td>
                <td colspan="4"><asp:Label runat="server" id="cmuTradeName" /></td>
            </tr>
            
            <tr>
                <td colspan="3"></td>
                <td>Lead time</td>
                <td colspan="3"><asp:Label runat="server" id="cmuLeadTime" /></td>
            </tr>
            <tr>
                <td colspan="3" />
                <td>MOV</td>
                <td colspan="3" style="text-align:right"><asp:Label runat="server" id="cmuMinOrdValue" /></td>
            </tr>
            <tr>
                <td colspan="3" />
                <td>Delivery</td>
                <td colspan="3"><asp:Label runat="server" id="cmuDeliveryCharge" /></td>
            </tr>
            </tbody>
        </table>            

        <!-- select item table -->
        <table runat="server" class="MainTable" border="1" width="100%" >
            <thead>
                <tr display="none">
                    <td width="16%" />
                    <td width="21%" />
                    <td width="21%" />
                    <td width="42%" />
                </tr>
            </thead> 
            <tbody>
            <tr class="HeaderRow">
                <td></td>
                <td align="center">Pharmacy Current</td>
                <td align="center">Pharmacy Proposed</td>
                <td align="center" colspan="2"><asp:CheckBox runat="server" ID="cbImportCmuData" Text="Tick to import data" OnCheckedChanged="importDataCheckBox_OnCheckedChanged" AutoPostBack="true" /></td>
            </tr>
            <tr>
                <td>Contract reference</td>
                <td><asp:Label runat="server" ID="ascContractReferenceOption" /></td>
                <td><asp:TextBox runat="server" id="selectedContractReference" CssClass="selectedOption" TabIndex="-1" ReadOnly="true" /></td>
                <td><asp:TextBox runat="server" id="tbCmuContractReference" CssClass="selectedOption" TabIndex="-1" ReadOnly="true" /></td>
            </tr>
            <tr>
                <td>Price</td>
                <td><asp:Label runat="server" ID="ascPriceOption" /></td>
                <td><asp:TextBox runat="server" ID="selectedPrice" CssClass="selectedOption" TabIndex="-1" ReadOnly="true" /></td>
                <td><asp:TextBox runat="server" id="tbCmuPrice" CssClass="selectedOption" TabIndex="-1" ReadOnly="true" /></td>
            </tr>
            <tr>
                <td>Start date</td>
                <td><asp:Label runat="server" ID="ascStartDateOption" /></td>
                <td><asp:TextBox runat="server" id="selectedStartDate" CssClass="selectedOption" TabIndex="-1" ReadOnly="true" /></td>
                <td><asp:TextBox runat="server" id="tbCmuStartDate" CssClass="selectedOption" TabIndex="-1" ReadOnly="true" /></td>
            </tr>
            <tr>
                <td>End date</td>
                <td><asp:Label runat="server" ID="ascEndDateOption"    /></td>
                <td><asp:TextBox runat="server" id="selectedEndDate" CssClass="selectedOption" TabIndex="-1" ReadOnly="true" /></td>
                <td><asp:TextBox runat="server" id="tbCmuEndDate" CssClass="selectedOption" TabIndex="-1" ReadOnly="true" /></td>
            </tr>                    
            <tr>
                <td>Trade name</td>
                <td><asp:Label runat="server" ID="ascTradenameOption" /></td>
                <td><asp:TextBox runat="server" id="selectedTradename" CssClass="selectedOption" TabIndex="-1" ReadOnly="true" /></td>
                <td><asp:CheckBox runat="server" ID="cbCmuTradename" OnCheckedChanged="importDataCheckBox_OnCheckedChanged" AutoPostBack="true" ReadOnly="true" /></td>
            </tr>
            <tr>
                <td>GTIN code</td>
                <td><asp:Label runat="server" ID="ascGTINCodeOption" /></td>
                <td><asp:TextBox runat="server" id="selectedGTINCode" CssClass="selectedOption" TabIndex="-1" ReadOnly="true" /></td>
                <td><asp:CheckBox runat="server" ID="cbCmuGTINCode" Text="Use GTIN code" OnCheckedChanged="importDataCheckBox_OnCheckedChanged" AutoPostBack="true" ReadOnly="true" /></td>
            </tr>
            <tr id="trEdiBarcode" runat="server">
                <td>EDI link code</td>
                <td><asp:Label runat="server" ID="ascEdiBarcodeOption" /></td>
                <td><asp:TextBox runat="server" ID="selectedEdiBarcode" CssClass="selectedOption" TabIndex="-1" ReadOnly="true" /></td>
                <td><asp:CheckBox runat="server" ID="cbCumEdiBarcode" Text="Use GTIN code for EDI link" OnCheckedChanged="importDataCheckBox_OnCheckedChanged" AutoPostBack="true" ReadOnly="true" /></td>
            </tr>   
            <tr>
                <td>Primary Supplier</td>
                <td><asp:Label runat="server" ID="ascIsPrimarySupplier"       /></td>
                <td><asp:TextBox runat="server" id="selectedIsPrimarySupplier" CssClass="selectedOption" TabIndex="-1" ReadOnly="true" /></td>
                <td><asp:CheckBox runat="server" ID="cbCmuIsPrimarySupplier" Text="Set as primary supplier" OnCheckedChanged="importDataCheckBox_OnCheckedChanged" AutoPostBack="true" ReadOnly="true" /></td>
            </tr>   
            </tbody>
        </table>
        
        <br />
        
        <div style="position:absolute; bottom:10px; left:10px;">
            <asp:LinkButton runat="server" id="lbtSites" CssClass="LinkButton" Width="350px" OnClientClick="lbtSelectSites_onclick(); return false;" ToolTip="Click to change sites to replicate to" />
            
            <div id="divSites" style="display:none;">
                <div style="width:100%;height:100%">
                    Select sites to replicate to:<br />
                    <br />
                    <div style="max-height:400px;">
                        <asp:CheckBoxList runat="server" ID="cblSites" />
                    </div>
                </div>
            </div>
        </div>
        
        <div style="position:absolute; bottom:10px; right:10px;">
            <button class="PharmButton" onclick="ItemEnquiry_onclick();" style="width: 110px;">Item Enquiry</button>&nbsp;
            <asp:Button ID="btnSave" runat="server" CssClass="PharmButton" Text="Save" AccessKey="S" OnClick="btnSave_OnClick" />&nbsp;
            <button class="PharmButton" onclick="window.close();">Cancel</button>
        </div>    
        </ContentTemplate>            
        </asp:UpdatePanel>
                
        <!-- update progress message -->
        <pc:ProgressMessage id="progressMessage" runat="server" EnableTheming="False" EnableViewState="false" />
    </div>          
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
