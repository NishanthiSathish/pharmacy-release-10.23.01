<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FMRule.aspx.cs" EnableEventValidation="False" Inherits="application_FinanceManagerSettings_FMRule" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik"  %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>
<%@ Register TagPrefix="icw" Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Accounting Rule Editor</title>
    <base target=_self>
        
    <link href="../../style/PharmacyDefaults.css"       rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"             rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css"    rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"        ></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>       
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" ></script>
    <script type="text/javascript" src="scripts/FMRule.js"                               ></script>
    <telerik:RadCodeBlock ID="CodeBlock" runat="server">
    <script type="text/javascript">
        SizeAndCentreWindow("600px", "600px");
    </script>        
    </telerik:RadCodeBlock>            

    <style type="text/css">html, body{height:98%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body onload="form_onload();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div style="padding:10px; padding-top:30px;">
        <icw:Container ID="container" runat="server" ShowHeader="false" FillBrowser="false" ControlToFocusId="txtSearch" Height="550px">
        <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>    
            <div style="position:absolute;top:5px;left:10px;">
                <telerik:RadTabStrip ID="radTabStrip" runat="server" MultiPageID="radMultiPage" SelectedIndex="0" OnClientTabSelecting="radTabStrip_OnTabSelecting" OnClientTabSelected="radTabStrip_OnTabSelected"> 
                    <Tabs>
                        <telerik:RadTab Text="1" PageViewID="vRule"   />
                        <telerik:RadTab Text="2" PageViewID="vFilter" />
                    </Tabs>
                </telerik:RadTabStrip>
            </div>

            <telerik:RadMultiPage ID="radMultiPage" runat="server" SelectedIndex="0">
                <telerik:RadPageView ID="vRule" runat="server">
                    <icw:Form runat="server" Caption="Posting Rule" style="margin-top: 0px; padding-top: 0px; margin-bottom: 0px; padding-bottom: 0px;" >   
                        <icw:ShortText  ID="txtCode"        runat="server" Caption="Code:"        Watermark="Code"                Mandatory="true" ErrorMessage="" />
                        <icw:ShortText  ID="txtDescription" runat="server" Caption="Description:" Watermark="General description" Mandatory="true" TextboxWidth="250px" />
                    </icw:Form>
                
                    <icw:General runat="server" align="center">
                        <table style="width:90%; margin-left: 8px;" >
                            <tr>
                                <td>&nbsp;</td>
                                <td style="text-align:center">Debit</td>
                                <td style="text-align:center">Credit</td>
                            </tr>
                            <tr>
                                <td>Cost</td>
                                <td align="left"><icw:List ID="lAccountCode_Debit"  runat="server" ShortListMaxItems="200" Mandatory="true" /></td>
                                <td align="left"><icw:List ID="lAccountCode_Credit" runat="server" ShortListMaxItems="200" Mandatory="true" /></td>
                            </tr>
                            <tr>
                                <td id="tdVatCaption" runat="server">VAT</td>
                                <td align="left"><icw:List ID="lAccountCode_Vat_Debit"  runat="server" ShortListMaxItems="200" /></td>
                                <td align="left"><icw:List ID="lAccountCode_Vat_Credit" runat="server" ShortListMaxItems="200" /></td>
                            </tr>
                        </table>
                        <br />
                        <div id="accountError" runat="server" class="ErrorMessage" style="width:100%;text-align:center;">&nbsp;</div>
                    </icw:General>   
            
                    <icw:Form runat="server" Caption="Data Conversion" style="margin-top: 0px; padding-top: 0px; margin-bottom: 0px; padding-bottom: 0px;" />
                    <icw:General runat="server" style="margin-top: 0px; padding-top: 0px; margin-bottom: 0px; padding-bottom: 0px;" >                               
                        <table style="width:90%; margin-left: 8px; margin-top: 0px" >
                            <tr>
                                <td>&nbsp;</td>
                                <td style="text-align:center">Cost</td>
                                <td style="text-align:center">Stock</td>
                            </tr>
                            <tr>
                                <td>Log Field Selection</td>
                                <td align="left"><icw:List ID="lCostField"   runat="server" ShowClearOption="false" InputControlDIVWidth="150px" Mandatory="true" AutoPostback="true" OnValueChanged="lCostField_OnValueChanged"  /></td>
                                <td align="left"><icw:List ID="lStockField"  runat="server" ShowClearOption="false" InputControlDIVWidth="150px" Mandatory="true" AutoPostback="true" OnValueChanged="lStockField_OnValueChanged" /></td>
                            </tr>
                            <tr>
                                <td>Multiply By</td>
                                <td align="left"><icw:List ID="lCostMultiply"   runat="server" ShowClearOption="false" InputControlDIVWidth="150px" Mandatory="true" ShortListMaxItems="10" AutoPostback="true" OnValueChanged="lCostMultiply_OnValueChanged"  /></td>
                                <td align="left"><icw:List ID="lStockMultiply"  runat="server" ShowClearOption="false" InputControlDIVWidth="150px" Mandatory="true" ShortListMaxItems="10" AutoPostback="true" OnValueChanged="lStockMultiply_OnValueChanged" /></td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td align="left"><icw:Label ID="lbCostMultiply"  runat="server" style="padding-left:10px;" /></td>
                                <td align="left"><icw:Label ID="lbStockMultiply" runat="server" style="padding-left:10px;" /></td>
                            </tr>
                        </table>
                    </icw:General>
                </telerik:RadPageView>

                <telerik:RadPageView ID="vFilter" runat="server">
                    <icw:Form ID="Form2" runat="server" Caption="Filters" style="margin-top: 0px; padding-top: 0px; margin-bottom: 0px; padding-bottom: 0px;" >   
                        <icw:List ID="lPharmacyLog"     runat="server" Caption="Pharmacy Log:"  Mandatory="true" ShowClearOption="false" AutoPostback="true" OnValueChanged="lPharmacyLog_OnValueChanged" />
                        <icw:List ID="lKind"            runat="server" Caption="Kind:"          Mandatory="true" ShowClearOption="false" />
                        <icw:List ID="lLabelType"       runat="server" Caption="Label Type:"                     ShowClearOption="false" ShortListMaxItems="30" />
                        <icw:List ID="lSite"            runat="server" Caption="Site:"          Mandatory="true" ShowClearOption="false" />                
                        <icw:List ID="lSupplierType"    runat="server" Caption="Supplier Type:" Mandatory="true" ShowClearOption="false" />
                    </icw:Form>
                
                    <icw:Form ID="Form3" runat="server">   
                        <icw:ShortText ID="txtNSVDescription"       runat="server" Caption="NSV Code:"          TextboxWidth="300px" /><asp:Button ID="btnNSVCode"     runat="server" CssClass="PharmButtonSmall" style="position:absolute; width:20px; height:20px;" Text="..." OnClientClick="btnNSVCode_OnClick(); return false;"     /><asp:Button ID="btnNSVCodeClear"     runat="server" CssClass="PharmButtonSmall" style="position:absolute; width:40px; height:20px;" Text="Clear" OnClientClick="btnNSVCodeClear_OnClick();     return false;"     />
                        <asp:HiddenField ID="hfNSVCode"             runat="server" />
                        <icw:ShortText ID="txtWardSupDescription"   runat="server" Caption="Orderlog Supplier:" TextboxWidth="300px" /><asp:Button ID="btnWardSupCode" runat="server" CssClass="PharmButtonSmall" style="position:absolute; width:20px; height:20px;" Text="..." OnClientClick="btnWardSupCode_OnClick(); return false;" /><asp:Button ID="btnWardSupCodeClear" runat="server" CssClass="PharmButtonSmall" style="position:absolute; width:40px; height:20px;" Text="Clear" OnClientClick="btnWardSupCodeClear_OnClick(); return false;"     />
                        <asp:HiddenField ID="hfSupplierID"          runat="server" />
                        <asp:HiddenField ID="hfWardSupCode"         runat="server" />
                        <icw:List ID="lCostPosNeg"  runat="server" Caption="Cost Value:"        ShowClearOption="false" />
                        <icw:List ID="lStockPosNeg" runat="server" Caption="Stock Quantity:"    ShowClearOption="false" />                
                    </icw:Form>   
            
                    <icw:Form runat="server" Caption="Extra SQL Filter" style="margin-top: 0px; padding-top: 0px; margin-bottom: 0px; padding-bottom: 0px;" />
                    <icw:General runat="server" style="margin-top: 0px; padding-top: 0px; margin-bottom: 0px; padding-bottom: 0px;" >   
                        <icw:LongText ID="txtExtraSQLFilter" runat="server" Columns="65" Rows="6" />
                    </icw:General>               
                </telerik:RadPageView>
            </telerik:RadMultiPage>                                
            
            <icw:General runat="server">
                <div style="position:absolute; bottom:25px; right:110px;">
                    <icw:Button ID="btnOK"     runat="server" CssClass="PharmButton" Caption="OK"     AccessKey="O" OnClick="btnOK_OnClick" />
                </div>
                <div style="position:absolute; bottom:25px; right:20px">
                    <icw:Button ID="btnCancel" runat="server" CssClass="PharmButton" Caption="Cancel" AccessKey="C" />
                </div>
            </icw:General>
        </ContentTemplate>
        </asp:UpdatePanel>      
        
        <asp:UpdatePanel ID="upMessageBox_ChangeWarning" runat="server" UpdateMode="Conditional">
        <ContentTemplate>    
            <asp:HiddenField ID="hfRecordID" runat="server" />
            <icw:MessageBox ID="mbChangeWarning" runat="server" Visible="false" Caption="Rebuild Data" Buttons="OK" OnOkClicked="mbChangeWarning_OkClicked" Height="175px" >
                <p>Changes will only be effective the following day.</p>
                <br />
            </icw:MessageBox>   
            
            <icw:MessageBox ID="mbDuplicateRule" runat="server" Visible="false" Caption="Duplicate Rule" Buttons="YesNo" OnYesClicked="mbDuplicateRule_YesClicked" Height="175px" >
                <p>Combination of log, kind, label type, site, NSVCode, ward\\supplier code type,<br />cost, and stock value is currently in use by rule <span id="spDuplicateRules" runat="server" /></p>
                <p>Do you still want to save?</p>
            </icw:MessageBox>
        </ContentTemplate>
        </asp:UpdatePanel>      
        
        </icw:Container>   
    </div>
    </form>
</body>
</html>
