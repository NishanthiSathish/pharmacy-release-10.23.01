<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PNStandardRegimen.aspx.cs" Inherits="application_PNSettings_PNStandardRegimen" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>
<%@ Register src="../PNViewAndAdjust/controls/PNSelectProduct.ascx" tagname="SelectProduct"  tagprefix="ws" %>
<%@ Register src="../PNViewAndAdjust/controls/PNEnterVolume.ascx"   tagname="EnterVolume"    tagprefix="ws" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target=_self>
    
    <link href="../../style/application.css"                                rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyGridControl.css"                        rel="stylesheet" type="text/css" />
    <link href="../../style/PN.css"                                         rel="stylesheet" type="text/css" />
	<link href="../sharedscripts/lib/jqueryui/jquery-ui-1.8.17.redmond.css" rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.4.3.min.js"></script>
    <script type="text/javascript" src="../sharedscripts/json2.js"></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.8.17.min.js"></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js" defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"></script>
    <script type="text/javascript" src="scripts/PNStandardRegimenEditor.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"></script>
    
    <script type="text/javascript">
        function form_onload() 
        {
            Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(ShowProgressMsg);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(HideProgressMsg);
            
            document.getElementById('tbRegimenName').focus();
        }
    </script>
     
    <style type="text/css">
        html, body{height:90%}
        #gridItemList{min-height: 150px;}
    </style>  
    
    <title>PN Standard Regimen Editor</title>
</head>
<body scroll="no"
      onload="form_onload();">
    <form id="form1" runat="server" defaultbutton="btnSave">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <div>
        <asp:Panel ID="Panel1" runat="server" CssClass="PNSettings" Height="625px" ScrollBars="Vertical" >
            <br />
            <asp:UpdatePanel ID="updatePanel1" runat="server" UpdateMode="Conditional">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="btnAdd"    />
                <asp:AsyncPostBackTrigger ControlID="btnEdit"   />
                <asp:AsyncPostBackTrigger ControlID="btnRemove" />
                <asp:AsyncPostBackTrigger ControlID="btnSave"   />
                <asp:AsyncPostBackTrigger ControlID="btnPrint"  />
            </Triggers>
            <ContentTemplate>
                <asp:HiddenField ID="hfPNStandardRegimenID" runat="server" />
                <asp:HiddenField ID="hfLastModifiedDate"    runat="server" />
                <asp:HiddenField ID="hfRegimenItems"        runat="server" />
                <asp:HiddenField ID="hfDefaultSiteID"       runat="server" />
                <asp:HiddenField ID="hfSelectedPNCode"      runat="server" />
                <div class="Section">
                    <span class="SectionHeader">General</span>
                    <span class="SectionControls">
                        <span ID="lbRegimenName" runat="server" class="EditControlLabel">Regimen Name</span><asp:TextBox ID="tbRegimenName" runat="server" Width="300px" /><br />
                        <span class="EditControlLabel">&nbsp;</span><asp:Label ID="lbRegimenNameError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" ></asp:Label><br />
                        <span ID="lbDescription" runat="server" class="EditControlLabel">Description</span><asp:TextBox ID="tbDescription" runat="server" Width="300px" /><br />
                        <span class="EditControlLabel">&nbsp;</span><asp:Label ID="lbDescriptionError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" ></asp:Label><br />
                        <span ID="lbInUse" runat="server" class="EditControlLabel">In use:</span><asp:CheckBox ID="cbInUse" runat="server" /><br />
                        <span ID="lbPerKilo" runat="server" class="EditControlLabel">PerKilo:</span><asp:CheckBox ID="cbPerKilo" runat="server" /><br />
                    </span>
                </div>
            </ContentTemplate>
            </asp:UpdatePanel>
            
            <div class="Section">
                <table cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                        <td span class="SectionHeader">Products</td>
                        <td colspan="3"><gc:GridControl id="gridItemList" runat="server" EnableTheming="False" JavaEventDblClick="$('#btnEdit').click();" /></td>
                    </tr>
                    <tr style="padding-top:10px;">
                        <td></td>
                        <td>
                            <asp:Button ID="btnAdd"    runat="server" Text="Add.."  CssClass="PharmButton" Height="23px" accesskey="A" onclick="Add_OnClick"     UseSubmitBehavior="False" CausesValidation="False" />&nbsp;&nbsp;
                            <asp:Button ID="btnEdit"   runat="server" Text="Edit.." CssClass="PharmButton" Height="23px" accesskey="E" onclientclick="if (!HasSelectedProduct()) {return;}" onclick="Edit_OnClick"    UseSubmitBehavior="False" CausesValidation="False" />&nbsp;&nbsp;
                            <asp:Button ID="btnRemove" runat="server" Text="Remove" CssClass="PharmButton" Height="23px" accesskey="D" onclientclick="if (!HasSelectedProduct()) {return;}" onclick="Remove_OnClick"  UseSubmitBehavior="False" CausesValidation="False" />                    
                        </td>
                        <td>&nbsp;</td>
                        <td style="width:250px"><div id="gridItemListError" class="ErrorMessage" style="width:100%;text-align:center;">&nbsp;</div></td>
                    </tr>
                </table>
            </div>
            
            <asp:UpdatePanel ID="updatePanel2" runat="server" UpdateMode="Conditional">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="btnAdd"    />
                <asp:AsyncPostBackTrigger ControlID="btnEdit"   />
                <asp:AsyncPostBackTrigger ControlID="btnRemove" />
                <asp:AsyncPostBackTrigger ControlID="btnSave"   />
                <asp:AsyncPostBackTrigger ControlID="btnPrint"  />
            </Triggers>
            <ContentTemplate>
                <div class="Section">
                    <span class="SectionHeader">Update Info</span><asp:Label ID="lbModifiedInfo" runat="server" /><br />
                    <span class="SectionHeader">&nbsp;</span><asp:TextBox ID="tbInfo" runat="server" Width="500px" Height="150px" TextMode="MultiLine" /><br />
                    <span class="SectionHeader">&nbsp;</span><asp:Label ID="lbInfoError" runat="server" CssClass="ErrorMessage" />
                </div>
            </ContentTemplate>
            </asp:UpdatePanel>
        </asp:Panel>    
        <div style="text-align:center; width: 100%; padding-top: 20px;">
            <table style="width: 100%">
                <tr>
                    <td style="width:33%">&nbsp;</td>
                    <td style="text-align:center; width:33%">
                        <asp:Button CssClass="PharmButton" ID="btnSave"   runat="server" Text="Save"   AccessKey="S" OnClick="Save_Click" CausesValidation="False" />&nbsp;&nbsp;&nbsp;
                        <asp:Button CssClass="PharmButton" ID="btnCancel" runat="server" Text="Cancel" AccessKey="C" OnClientClick="window.close(); return false;" />
                    </td>
                    <td style="text-align:right; width:33%">
                        <asp:Button CssClass="PharmButton" ID="btnPrint"  runat="server" Text="Print"  AccessKey="P" OnClick="Print_Click" UseSubmitBehavior="False" CausesValidation="False" />&nbsp;&nbsp;
                    </td>
                </tr>
            </table>
        </div>
    </ContentTemplate>
    </asp:UpdatePanel>
    </div>

    <!-- Wizard --> 
    <div id="wizardPopup" class="popup" style="display:none;padding-top:10px;height:450px;" onkeydown="wizardPopup_onkeydown(event);">
        <asp:UpdatePanel ID="upWizard" runat="server" UpdateMode="Conditional">        
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnAdd"    />
            <asp:AsyncPostBackTrigger ControlID="btnEdit"   />
        </Triggers>
        <ContentTemplate>
            <asp:Wizard ID="wizardAddProduct" runat="server" DisplaySideBar="False" Height="280px" Width="100%"
                StepStyle-Wrap="True" StepStyle-VerticalAlign="Top"  
                StepStyle-HorizontalAlign="Left"
                onnextbuttonclick="wizard_NextButtonClick" OnFinishButtonClick="wizard_NextButtonClick" OnCancelButtonClick="wizard_CancelButtonClick" 
                DisplayCancelButton="True">
                <StepStyle HorizontalAlign="Left" VerticalAlign="Top" Wrap="True"></StepStyle>
                <NavigationButtonStyle CssClass="PharmButton" />
                <WizardSteps>
                    <asp:WizardStep ID="wsSelectProduct" runat="server" Title="Select Product" AllowReturn="False">
                        <div style="width:410px;height:275px;">
                            <ws:SelectProduct id="selectProductCtrl" runat="server" />        
                        </div>
                    </asp:WizardStep>
                    <asp:WizardStep ID="wsEnterVolume" runat="server" Title="Enter Volume" AllowReturn="False">
                        <ws:EnterVolume id="enterVolumeCtrl" runat="server" />        
                    </asp:WizardStep>
                </WizardSteps> 
            </asp:Wizard>
        </ContentTemplate>
        </asp:UpdatePanel>
    </div>    

    <!-- update progress message -->
    <div id="divUpdateProgress" style="display:none;position:absolute;width:100%;z-index:9900;top:0px;left:0px;height:100%;">
    <table width=100% height=100% style="display:none;">
    <tr valign=center>
	    <td align=center>
            <div class="ICWStatusMessage" style="vertical-align:middle;height:75px;"><img src="../../images/Developer/spin_wait.gif" /><span id="spanMsg">Processing...</span></div>
        </td>
    </tr>     
    </table>           
    </div>   
    </form>
    </body>
</html>
