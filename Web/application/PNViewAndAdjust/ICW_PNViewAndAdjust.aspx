<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_PNViewAndAdjust.aspx.cs" Inherits="application_PNViewAndAdjust_ICW_PNViewAndAdjust" EnableEventValidation="false" %>
<%@ Import Namespace="ascribe.pharmacy.parenteralnutritionlayer" %>
<%@ Import Namespace="ascribe.pharmacy.icwdatalayer" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register src="controls/PNAddMethod.ascx"                    tagname="AddMethod"                     tagprefix="ws" %>
<%@ Register src="controls/PNSelectProduct.ascx"                tagname="SelectProduct"                 tagprefix="ws" %>
<%@ Register src="controls/PNselectIngredient.ascx"             tagname="selectIngredient"              tagprefix="ws" %>
<%@ Register src="controls/PNEnterVolume.ascx"                  tagname="EnterVolume"                   tagprefix="ws" %>
<%@ Register src="controls/PNmmolEntry.ascx"                    tagname="mmolEntry"                     tagprefix="ws" %>
<%@ Register src="controls/PNSelectIngredientWithQuantity.ascx" tagname="selectIngredientWithQuantity"  tagprefix="ws" %>
<%@ Register Src="controls/PNAskAdjustIng.ascx"                 tagname="AskAdjustIng"                  tagprefix="ws" %>
<%@ Register Src="controls/PNSetMethod.ascx"                    tagname="SetMethod"                     tagprefix="ws" %>
<%@ Register Src="controls/PNSelectGlucoseProduct.ascx"         tagname="SelectGlucoseProduct"          tagprefix="ws" %>
<%@ Register Src="controls/PNSelectAqueousOrLipid.ascx"         tagname="SelectAqueousOrLipid"          tagprefix="ws" %>
<%@ Register Src="controls/PNVolumeAndWeights.ascx"             tagname="VolumeAndWeights"              tagprefix="ws" %>
<%@ Register Src="controls/PNSummaryView.ascx"                  tagname="SummaryView"                   tagprefix="ws" %>
<%@ Register Src="controls/PNSelectStandardRegimen.ascx"        tagname="SelectStandardRegimen"         tagprefix="ws" %>
<%@ Register Src="controls/PNWizardMessage.ascx"                tagname="WizardMessage"                 tagprefix="ws" %>



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "ICW_PNViewAndAdjust.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%= SessionInfo.SessionID %>';
    var desktopURL = "../sharedscripts/CheckSessionExists.aspx";
    var pageName = "ICW_PNViewAndAdjust.aspx";
    //alert(sessionId);
    //alert(desktopURL + " " + pageName);
    windowModal_CheckSession(sessionId, desktopURL, "CheckSessionExists" + "|" + pageName);
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Regimen View and Adjust</title>
    <base target=_self>
    
    <link href="../../style/application.css"                                        rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"                                   rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyGridControl.css"                                rel="stylesheet" type="text/css" />
    <link href="../../Style/PN.css"                                                 rel="stylesheet" type="text/css" />
    <link href="scripts/jquery.tooltip.css"                                         rel="stylesheet" type="text/css" />
	<link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css"         rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"></script>
    <script type="text/javascript" src="../sharedscripts/json2.js"></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js"></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js"></script>
    <script type="text/javascript" src="../sharedscripts/ocs/OCSShared.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"></script>
    <script type="text/javascript" src="scripts/csspopup.js"></script>
    <script type="text/javascript" src="scripts/jquery.tooltip.min.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"></script>
    <script type="text/javascript" src="scripts/pnviewandadjust.js" ></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"></script>
    
    <script type="text/javascript">
        function HandleResultForTimeout(result) {
            //alert("Alert from reference! ");
            if (result == 'logoutFromActivityTimeout') {
                window.returnValue = 'logoutFromActivityTimeout';
                window.close();
                window.parent.close();
                window.parent.ICWWindow().Exit();
            }
        }
    </script>      
</head>
<body onload="form_onload();" onbeforeunload="form_onbeforeunload();" onunload="form_unload();" onkeydown="form_onkeydown(event)"
    SessionID=<%= this.sessionID %>
    SiteID=<%= SessionInfo.SiteID %>
    >
    <form id="form1" runat="server" EnableEventValidation="false">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div>
        <asp:UpdatePanel ID="upButtonsAndPatientDetails" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="false">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnAuthorise" />
            <asp:AsyncPostBackTrigger ControlID="btnEdit"      />
        </Triggers>
        <ContentTemplate>    
            <div id="ToolBar" runat="server" style="height:48px; background-color: #D6DBEF; border-bottom: solid 2px #E7E7F7; padding-top: 5px; padding-left: 8px">
                <table cellpadding="0" cellspacing="0" >
                    <tr>
                        <td><asp:Button ID="btnPrescription" runat="server" Text="Prescription" CssClass="ToolbarButton" ToolTip="View Prescription (Alt+P)"                    Enabled="false" OnClick="Prescription_OnClick" CausesValidation="False" AccessKey="P" /></td>
                        <td><asp:Button ID="btnRegimen"      runat="server" Text="Regimen"      CssClass="ToolbarButton" ToolTip="Enter or Amend Regimen Details (Alt+G)"       Enabled="false" OnClick="Regimen_OnClick"      CausesValidation="False" AccessKey="G" /></td>
                        <td><asp:Button ID="btnRequirements" runat="server" Text="Requirements" CssClass="ToolbarButton" ToolTip="Enter or Amend Regimen Requirements (Alt+Q)"  Enabled="false" OnClick="Requirements_OnClick" CausesValidation="False" AccessKey="Q" /></td>
                        <td class="ToolbarSeparator" ><asp:Button ID="btnPopulate"     runat="server"  Text="Populate"      CssClass="ToolbarButton" ToolTip="Auto populate or select standard regimen (Alt+R)"  Enabled="false" OnClick="Populate_OnClick"  CausesValidation="False" AccessKey="R" /></td>
                        <td><asp:Button ID="btnAdd"          runat="server" Text="Add"          CssClass="ToolbarButton" ToolTip="Add Product to Regimen (Alt+A)"       Enabled="false" OnClick="AddProduct_OnClick"     CausesValidation="False" AccessKey="A" /></td>
                        <td><asp:Button ID="btnReplace"      runat="server" Text="Replace"      CssClass="ToolbarButton" ToolTip="Replace Product in Regimen (Alt+H)"   Enabled="false" OnClick="ReplaceProduct_OnClick" CausesValidation="False" AccessKey="H" /></td>
                        <td class="ToolbarSeparator" ><asp:Button ID="btnDelete"       runat="server" Text="Delete"       CssClass="ToolbarButton" ToolTip="Remove Product from Regimen (Alt+D)"  Enabled="false" OnClick="DeleteProduct_OnClick" CausesValidation="False" AccessKey="D" /></td>
                        <td><asp:Button ID="btnSet"          runat="server" Text="Set"          CssClass="ToolbarButton" ToolTip="Set volume or calories (Alt+E)"         Enabled="false" OnClick="Set_OnClick" CausesValidation="false" AccessKey="E" /></td>
                        <td><asp:Button ID="btnMultiplyBy"   runat="server" Text="Multiply By"  CssClass="ToolbarButton" ToolTip="Multiply Regimen up or down (Alt+M)"    Enabled="false" OnClick="MultiplyBy_OnClick" CausesValidation="false" AccessKey="M" /></td>
                        <td><asp:Button ID="btnOverage"      runat="server" Text="Overage"      CssClass="ToolbarButton" ToolTip="Set overage volume (Alt+O)"             Enabled="false" OnClick="Overage_OnClick" CausesValidation="false" AccessKey="O" /></td>
                        <td><asp:Button ID="btnSummary"      runat="server" Text="Summary"      CssClass="ToolbarButton" ToolTip="Get regimen summary info (Alt+Y)"       Enabled="false" OnClick="Summary_OnClick" CausesValidation="False" AccessKey="Y" /></td>
                        <td class="ToolbarSeparator"><asp:Button ID="btnProductWeight"        runat="server" Text="Weights"      CssClass="ToolbarButton" ToolTip="Get volumes and weights (Alt+W)"  Enabled="false" OnClick="ProductWeight_OnClick" CausesValidation="False" AccessKey="W" /></td>
                        <td><asp:Button ID="btnEdit"     runat="server" Text="Edit"       CssClass="ToolbarButton" ToolTip="Edit regimen (Alt+E)" Enabled="false" OnClick="Edit_OnClick" CausesValidation="False" AccessKey="E" /></td>
                        <td><asp:Button ID="btnSave"     runat="server" Text="Save"        CssClass="ToolbarButton"      ToolTip="Save the regimen (Alt+S)"   Enabled="false" OnClick="Save_OnClick" CausesValidation="False" AccessKey="S" /></td>
                        <td class="ToolbarSeparator"><asp:Button ID="btnAuthorise"    runat="server" Text="Authorise"    CssClass="ToolbarButton" ToolTip="Authorise regimen (Alt+U)"  Enabled="false" OnClick="Authorise_OnClick" CausesValidation="False" AccessKey="U" /></td>
                        <td><asp:Button ID="btnExit"         runat="server" Text="Exit"         CssClass="ToolbarButton" ToolTip="Exit the regimen (Alt+X)"               Enabled="false" OnClientClick="askIfExit();" CausesValidation="False" AccessKey="X" /></td>
                    </tr>
                </table>
            </div>
            <asp:Panel ID="pnDetails" runat="server" CssClass="DetailsPanel">
                <span class="DetailsLabelFirst">Name: </span><asp:Label ID="lbName" runat="server" CssClass="DetailsValue" />
                <span class="DetailsLabel">DOB: </span><asp:Label ID="lbDOB" runat="server" CssClass="DetailsValue" />
                <asp:Label ID="lbNHSNumberDisplayName" runat="server" CssClass="DetailsLabel" /><asp:Label ID="lbNHSNumber" runat="server" CssClass="DetailsValue" />
                <asp:Label ID="lbCaseNoDisplayName" runat="server" CssClass="DetailsLabel" /><asp:Label ID="lbCaseNo" runat="server" CssClass="DetailsValue" />
                <br />                
                <span class="DetailsLabelFirst">Dosing Weight: </span><asp:Label ID="lbWeight" runat="server" CssClass="DetailsValue" />
                <span class="DetailsLabel">Status: </span><asp:Label ID="lbPatientStatus" runat="server" CssClass="DetailsValue" />
                <span class="DetailsLabel">Ward: </span><asp:Label ID="lbWard" runat="server" CssClass="DetailsValue" />
                <span class="DetailsLabel">Consultant: </span><asp:Label ID="lbConsultant" runat="server" CssClass="DetailsValue" />
                <hr />
                <span class="DetailsLabelFirst">Regimen: </span><asp:Label ID="lbRegimen" runat="server" CssClass="DetailsValue" />
                <br />
                <span class="DetailsLabelFirst">Route: </span><asp:Label ID="lbRoute" runat="server" CssClass="DetailsValue" />
                <span class="DetailsLabel">Type: </span><asp:Label ID="lbType" runat="server" CssClass="DetailsValue" />
                <span class="DetailsLabel" ID="lbSupplyLabel" runat="server">Supply: </span><asp:Label ID="lbSupply" runat="server" CssClass="DetailsValue" />
                <span class="DetailsLabel">Status: </span><asp:Label ID="lbSavedStatus" runat="server" CssClass="DetailsValue" />
                <br />
                <span class="DetailsLabelFirst">Glucose concentration: </span><asp:Label ID="lbGlucoseConcentration" runat="server" CssClass="DetailsValue" />
                <span class="DetailsLabel">Calorie ratio: </span><asp:Label ID="lbCalorieRatio" runat="server" CssClass="DetailsValue" />
                <span class="DetailsLabel">Overage: </span><asp:Label ID="lbOverage" runat="server" CssClass="DetailsValue" />
<% if(!string.IsNullOrEmpty(lbAdditionalInstructions.Text) || !string.IsNullOrEmpty(lbDispensingInstructions.Text)) %>                
<% { %>
                <hr />
<% } %>
<% if(!string.IsNullOrEmpty(lbAdditionalInstructions.Text)) %>                
<% { %>
                <span class="DetailsLabelFirst">Additional Instructions: </span><asp:Label ID="lbAdditionalInstructions" runat="server" CssClass="DetailsValue" />
                <br />
<% } %>
<% if(!string.IsNullOrEmpty(lbDispensingInstructions.Text)) %>                
<% { %>
                <span class="DetailsLabelFirst">Dispensing Instructions: </span><asp:Label ID="lbDispensingInstructions" runat="server" CssClass="DetailsValue" />
<% } %>
            </asp:Panel>    

            <div style="display:none;">
            <asp:UpdatePanel ID="upRegimenItems" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="false">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="btnPrescription"   />
                <asp:AsyncPostBackTrigger ControlID="btnRegimen"        />
                <asp:AsyncPostBackTrigger ControlID="btnRequirements"   />
                <asp:AsyncPostBackTrigger ControlID="btnAdd"            />
                <asp:AsyncPostBackTrigger ControlID="btnReplace"        />
                <asp:AsyncPostBackTrigger ControlID="btnSave"           />
                <asp:AsyncPostBackTrigger ControlID="btnDelete"         />
                <asp:AsyncPostBackTrigger ControlID="btnSet"            />
                <asp:AsyncPostBackTrigger ControlID="btnOverage"        />
                <asp:AsyncPostBackTrigger ControlID="btnMultiplyBy"     />
            </Triggers>
            <ContentTemplate>
                <asp:HiddenField ID="hfRequestID"           runat="server" />   <!-- required field -->
                <asp:HiddenField ID="hfCurrentRowPNCode"    runat="server" />
                <asp:HiddenField ID="hfCurrentColDBName"    runat="server" />
                <asp:HiddenField ID="hfViewAndAdjustInfo"   runat="server" />
                <asp:HiddenField ID="hfProcessor"           runat="server" />
                <asp:HiddenField ID="hfProcessorCopy"       runat="server" />
            </ContentTemplate>
            </asp:UpdatePanel>
            </div>
        </ContentTemplate>
        </asp:UpdatePanel>        
        
        <asp:Panel ID="gridPanel" runat="server" CssClass="GridPanel" ScrollBars="Both">
            <table id="PNGrid" bgcolor="white" border="1px" bordercolor="#6392CE" cellpadding="0" cellspacing="0" onkeydown="PNGrid_onkeydown(event)">
                <col width="<%= ColumnWidthProductName.ToString() %>px" align="left" title="Product" />                
<%              
                foreach (PNIngredientRow ing in PNIngredient.GetInstance().FindByForViewAdjust())
                    Response.Write("<col width='" + ColumnWidthIngredient.ToString() + "px' align='right' title='" + ing.DBName + "' PO4='" + (ing.DBName == PNIngDBNames.Phosphate).ToString().ToLower() + "' Volume='" + (ing.DBName == PNIngDBNames.Volume).ToString().ToLower() + "' colType='ingredient' />");
%>                  
                <col width="<%= ColumnWidthIngredient.ToString() %>px" align="right" title="mlPerKg" />                
                <thead>
                    <tr style="background-color: #EFEFF7; vertical-align: top;">
                        <td  style="padding:3px" onclick="__doPostBack('upWizard', 'AddByProduct');">Product</td>
<%              
    foreach (PNIngredientRow ing in PNIngredient.GetInstance().FindByForViewAdjust())
    {
        UnitRow unit = ing.GetUnit();
        if (unit != null)
        {
            string unitAbbreviation = ing.GetUnit().Abbreviation;
            switch (unitAbbreviation.ToLower())
            {
                case "microgram": unitAbbreviation = "micro<br />gram"; break;
                case "micromol": unitAbbreviation = "micro<br />mol"; break;
                case "nanomol": unitAbbreviation = "nano<br />mol"; break;
            }

            Response.Write("<td style='padding:3px' onclick='PNGrid_onclickheader(this);'>" + ing.ShortDescription + "<br />" + unitAbbreviation + "</td>");
        }
    }
%>                  
                        <td  style="padding:3px"  onclick="__doPostBack('upWizard', 'AdjustVolume');">ml/kg</td>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </asp:Panel>

        <!-- Wizard --> 
        <div id="blanket" style="display:none;"></div>
        <div id="wizardPopup" runat="server" class="popup" style="display:none;padding:10px;width:450px;height:500px;" onkeydown="wizardPopup_onkeydown(event)">
            <div style="text-align:right;"><img style="width: 8px; height: 8px;" src="../../images/Developer/close.gif" onclick="hidePopup('wizardPopup', 'blanket'); $('#PNGrid').focus();" /></div>            
            <asp:UpdatePanel ID="upWizard" runat="server" UpdateMode="Conditional">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="btnAdd"        />
                <asp:AsyncPostBackTrigger ControlID="btnReplace"    />
                <asp:AsyncPostBackTrigger ControlID="btnSet"        />
                <asp:AsyncPostBackTrigger ControlID="btnOverage"    />
                <asp:AsyncPostBackTrigger ControlID="btnPopulate" />
            </Triggers>
            <ContentTemplate>
                <asp:HiddenField ID="hfWizardType"          runat="server" />
                <asp:HiddenField ID="hfDefaultmmlEntryType" runat="server" />
                <asp:HiddenField ID="hfAskmmolEntryType"    runat="server" />
                <asp:Wizard ID="wizardAddProduct" runat="server" DisplaySideBar="False" Height="450px" Width="100%"
                    StepStyle-Wrap="True" StepStyle-VerticalAlign="Top"  
                    StepStyle-HorizontalAlign="Left"
                    onnextbuttonclick="wizard_NextButtonClick" OnFinishButtonClick="wizard_NextButtonClick" OnCancelButtonClick="wizard_CancelButtonClick" OnPreviousButtonClick="wizard_PreviousButtonClick" 
                    DisplayCancelButton="True">
                    <StepStyle HorizontalAlign="Left" VerticalAlign="Top" Wrap="True"></StepStyle>
                    <NavigationButtonStyle CssClass="PharmButton" />
                    <WizardSteps>
                        <asp:WizardStep ID="wsAddMethod" runat="server" Title="Add Method" AllowReturn="False">
                            <ws:AddMethod id="addMethodCtrl" runat="server" />        
                        </asp:WizardStep>
                        <asp:WizardStep ID="wsSelectProduct" runat="server" Title="Select Product" AllowReturn="False">
                            <ws:SelectProduct id="selectProductCtrl" runat="server" />        
                        </asp:WizardStep>
                        <asp:WizardStep ID="wsSelectIngredient" runat="server" Title="Select Ingredient" AllowReturn="False">
                            <ws:selectIngredient id="selectIngredientCtrl" runat="server" />        
                        </asp:WizardStep>
                        <asp:WizardStep ID="wsmmolEntry" runat="server" Title="mmol Entry" AllowReturn="False">
                            <ws:mmolEntry id="mmolEntryCtrl" runat="server" />        
                        </asp:WizardStep>
                        <asp:WizardStep ID="wsEnterVolume" runat="server" Title="Enter Volume" AllowReturn="False">
                            <ws:EnterVolume id="enterVolumeCtrl" runat="server" />        
                        </asp:WizardStep>
                        <asp:WizardStep ID="wsSelectIngredientWithQuantity" runat="server" Title="Select Ingredient" AllowReturn="False">
                            <ws:selectIngredientWithQuantity id="selectIngredientWithQuantityCtrl" runat="server" />        
                        </asp:WizardStep>
                        <asp:WizardStep ID="wsWizardMessage" runat="server" Title="Message" AllowReturn="False">
                            <ws:WizardMessage ID="wizardMessageCtrl" runat="server" />
                        </asp:WizardStep>       
                        <asp:WizardStep ID="wsSetMethod" runat="server" Title="Set Method" AllowReturn="False">
                            <ws:SetMethod id="setMethodCtrl" runat="server" />        
                        </asp:WizardStep>                        
                        <asp:WizardStep ID="wsEnterOverage" runat="server" Title="Enter Overage" AllowReturn="False">
                            <ws:EnterVolume id="enterOverageCtrl" runat="server" />        
                        </asp:WizardStep>
                        <asp:WizardStep ID="wsSelectGlucoseProduct" runat="server" Title="Select Glucose Product" AllowReturn="False">
                            <ws:SelectGlucoseProduct id="selectGlucoseProductCtrl" runat="server" />        
                        </asp:WizardStep>                        
                        <asp:WizardStep ID="wsSelectAqueousOrLipid" runat="server" Title="Select aqueous or lipid" AllowReturn="False">
                            <ws:SelectAqueousOrLipid id="selectAqueousOrLipidCtrl" runat="server" />        
                        </asp:WizardStep>      
                        <asp:WizardStep ID="wsSelectStandardRegimen" runat="server" Title="Select standard regimen" AllowReturn="False">
                            <ws:SelectStandardRegimen id="selectStandardRegimenCtrl" runat="server" />    
                        </asp:WizardStep>      
                    </WizardSteps> 
                </asp:Wizard>
            </ContentTemplate>
            </asp:UpdatePanel>
        </div>    

        <!-- Delete Message Box -->
        <div id="askAdjustMsgBox" style="display:none;">
            <asp:UpdatePanel ID="upAskAdjustMsgBox" runat="server" UpdateMode="Conditional">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="btnDelete"  />
            </Triggers>
            <ContentTemplate>
                <ws:AskAdjustIng id="msgBoxAskAdjustIng" runat="server" />
            </ContentTemplate>
            </asp:UpdatePanel>
        </div>    
        
        <!-- Multiply by Form -->
        <div id="multiplyByForm" class="popup" style="display:none;padding:10px;width:250px;height:400px;" onkeydown="MultiplyBy_onkeydown(event)">
        <div style="text-align:right;"><img style="width: 8px; height: 8px;" src="../../images/Developer/close.gif" onclick="$('#btnMultiplyByFormCancel').click();" /></div>            
        <asp:UpdatePanel ID="upMultiplyByForm" runat="server" UpdateMode="Conditional">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnMultiplyBy" />
            <asp:AsyncPostBackTrigger ControlID="btnMultiplyByFormOK" />
        </Triggers>
        <ContentTemplate>            
            <div id="multiplyByDiv">
                <div id="multiplyBySlider" class="multiplyBySlider" style="height: 260px;" >
                    <span class="MultiplyBySliderLabel" style="top: -3%">1%</span>
                    <span class="MultiplyBySliderLabel" style="top: 9.5%">25%</span>
                    <span class="MultiplyBySliderLabel" style="top: 22%">50%  Halve all ingredients</span>
                    <span class="MultiplyBySliderLabel" style="top: 34.5%">75%</span>
                    <span class="MultiplyBySliderLabel" style="top: 47%">100%  No change</span>
                    <span class="MultiplyBySliderLabel" style="top: 59.5%">125%</span>
                    <span class="MultiplyBySliderLabel" style="top: 72%">150%</span>
                    <span class="MultiplyBySliderLabel" style="top: 84.5%">175%</span>
                    <span class="MultiplyBySliderLabel" style="top: 97%">200%  Double all ingredients</span>
                </div>
            </div>
            
            <div style=" text-align: center; padding-top: 40px; padding-bottom: 30px;">
                <div>
                    <asp:Label ID="lbMultiplyBy" runat="server" Text="Percentage of regimen:"></asp:Label>&nbsp;<asp:TextBox ID="tbMultiplyBy" runat="server" Width="50px" MaxLength="6"></asp:TextBox>
                    <br />
                    <asp:Label ID="lbMultiplyByValueError" runat="server" Text="&nbsp;" CssClass="ErrorMessage"></asp:Label>
                </div>
            </div>

            <div style="position: absolute; bottom: 10; width: 100%; text-align: center;">
                <div style="width: 100%; height: 100%; text-align: center; vertical-align: bottom;">
                    <asp:Button ID="btnMultiplyByFormOK"     runat="server" CssClass="PharmButton" Text="OK"      OnClick="btnMultiplyByFormOK_OnClick" CausesValidation="false" />
                    &nbsp;&nbsp;&nbsp;
                    <asp:Button ID="btnMultiplyByFormCancel" runat="server" CssClass="PharmButton" Text="Cancel"  OnClientClick="hidePopup('multiplyByForm', 'blanket'); $('#PNGrid').focus(); return false;" />
                </div>
            </div>
        </ContentTemplate>
        </asp:UpdatePanel>
        </div>

        <!-- Weight and Volume message box -->
        <div id="weightAndVolumes" class="popup weightsAndVolumes" style="display:none;padding:10px;width:600px;height:450px;" onkeydown="weightAndVolumes_onkeydown(event)">
            <div style="text-align:right;"><img style="width: 8px; height: 8px;" src="../../images/Developer/close.gif" onclick="$('#btnWeightClose').click();" /></div>            
            <asp:UpdatePanel ID="upWeightAndVolumes" runat="server" UpdateMode="Conditional">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="btnProductWeight"  />
            </Triggers>
            <ContentTemplate>
                <ws:VolumeAndWeights id="weightsAndVolumeCtrl" runat="server" />
                
                <div style="display:block;position:absolute;bottom:10px;left:10px"><asp:Label ID="lbSupplyPeriod" runat="server" /></div>
                <div style="display:block;position:absolute;bottom:10px;left:45%"><asp:Button ID="btnWeightClose" runat="server" CssClass="PharmButton" Text="Close" OnClientClick="hidePopup('weightAndVolumes', 'blanket'); $('#PNGrid').focus(); return false;" /></div>
                <div style="display:block;position:absolute;bottom:10px;right:25px"><asp:Button ID="btnWeightFullWeight" runat="server" CssClass="PharmButton" Text="Show Full Volume"  Width="115px" style="background-position: bottom right" OnClick="WeightFullWeight_OnClick" CausesValidation="false" /></div>
            </ContentTemplate>
            </asp:UpdatePanel>
        </div>    
        
        <!-- Summary View message box -->
        <div id="summaryView" class="popup summaryView" style="display:none;padding:10px;width:600px;height:660px;" onkeydown="summaryView_onkeydown(event)">
            <div style="text-align:right;"><img style="width: 8px; height: 8px;" src="../../images/Developer/close.gif" onclick="$('#btnSummeryViewOK').click();" /></div>            
            <asp:UpdatePanel ID="upSummaryView" runat="server" UpdateMode="Conditional">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="btnSummary"  />
            </Triggers>
            <ContentTemplate>
                <ws:SummaryView id="summaryViewCtrl" runat="server" />

                <div style="display:block;position:absolute;bottom:8px;left:45%"><asp:Button ID="btnSummeryViewOK" runat="server" CssClass="PharmButton" Text="OK" OnClientClick="hidePopup('summaryView', 'blanket'); $('#PNGrid').focus(); return false;" /></div>
            </ContentTemplate>
            </asp:UpdatePanel>
        </div>    
                        
        <!-- Phosphate tooltip -->
        <div id="phosphateTooltip" style="display:none;">
            <table>
                <col align="left"  />
                <col align="right" />
                <col align="left"  />
                <tr>
                    <td>Organic:</td>
                    <td id="<%= PNIngDBNames.OrganicPhosphate %>"></td>
                    <td><%= PNIngredient.GetInstance().FindByDBName(PNIngDBNames.OrganicPhosphate).GetUnit().Abbreviation %></td>
                </tr>
                <tr>
                    <td>Inorganic:</td>
                    <td id="<%= PNIngDBNames.InorganicPhosphate %>"></td>
                    <td><%= PNIngredient.GetInstance().FindByDBName(PNIngDBNames.InorganicPhosphate).GetUnit().Abbreviation %></td>
                </tr>
                <tr class='TooltipTotalRow'>
                    <td>Total:</td>
                    <td id="<%= PNIngDBNames.Phosphate %>"></td>
                    <td><%= PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Phosphate).GetUnit().Abbreviation %></td>
                </tr>
            </table>            
        </div>

        
        <!-- Volume tooltip -->
        <div id="volumeTooltip" style="display:none;">
            <table>
                <col />
                <col />
                <col />
                <col />
                <col />
                <col />
                <tr>
                    <td colspan="6" id="ProductName" style="font-weight: bold; text-align: center;"></td>
                </tr>
                <tr style="vertical-align: top; text-align:right;">
                    <td style="font-weight: bold; text-align:left;">Volume</td>
                    <td>:</td>
                    <td id="Vol"></td>
                    <td>mL</td>
                    <td id="VolFull"></td>
                    <td tag="VolFullUnits">mL</td>
                </tr>
                <tr style="vertical-align: top; text-align:right;">
                    <td style="font-weight: bold; text-align:left;">Overage</td>
                    <td>:</td>
                    <td id="Overage"></td>
                    <td>mL</td>
                    <td id="OverageFull"></td>
                    <td tag="OverageFullUnits">mL</td>
                </tr>
                <tr class='TooltipTotalRow' style="vertical-align: top; text-align:right;">
                    <td style="font-weight: bold; text-align:left;"><span>Total</span><br /><span tag="Supply48Hr" style="font-size: 7pt; font-weight: normal;">48Hr Supply</span></td>
                    <td>:</td>
                    <td id="VolWithOverage"></td>
                    <td>mL</td>
                    <td id="VolWithOverageFull"></td>
                    <td tag="VolWithOverageFullUnits">mL</td>
                </tr>
            </table>            
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
    </div>       
    </form>
     <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
    <iframe id="CheckSessionExists" application="yes" style="display: none;"></iframe>
</body>
</html>
