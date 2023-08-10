<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AmmSupplyRequest.aspx.cs" Inherits="application_aMMWorkflow_AmmSupplyRequest" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx"               tagname="ProgressMessage" tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/PatientBanner/PatientBanner.ascx"   tagname="PatientBanner"   tagprefix="uc" %>   
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx"           tagname="GridControl"     tagprefix="uc" %>   
<%@ Register src="../pharmacysharedscripts/SecondCheck/SecondCheck.ascx"       tagName="SecondCheck"     tagPrefix="uc" %>
<%@ Register src="../pharmacysharedscripts/PharmacyLabelPanelControl.ascx"     tagName="PanelControl"    tagPrefix="uc" %>

<%@ Register src="../PharmacyLogViewer/DisplayLogRows.ascx" tagname="LogRows" tagprefix="uc" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>AMM Supply Request - <%= this.processor.SupplyRequest.BatchNumber %></title>
    <base target="_self" />

	<link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"                                 rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyGridControl.css"                        rel="stylesheet" type="text/css" />
    <link href="../../style/LabelPanelControl.css"                          rel="stylesheet" type="text/css" />
    <link href="style/AmmSupplyRequest.css"                                 rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.11.3.min.js"              async></script>
    <script type="text/javascript" src="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../sharedscripts/json2.js"                              async></script>
    <script type="text/javascript" src="../sharedscripts/ocs/OCSShared.js"                      async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/FileHandling.js"               defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyLabelPanelControl.js"  async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"           defer></script>
	<script type="text/javascript" src="../sharedscripts/icw.js"                                defer></script>
    <script type="text/javascript" src="../sharedscripts/ocs/OCSContextActions.js"              defer></script>
    <script type="text/javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"    defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/OCSProcessor.js"               defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/reports.js"                    defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/HelperWebService.js"           defer></script>
    <script type="text/javascript" src="script/AmmSupplyRequest.js"                             async></script>
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
    <script type="text/javascript">
        SizeAndCentreWindow("1005px", (screen.height - 140) + "px");
        
        var sessionId   = <%= SessionInfo.SessionID %>;
        var siteId      = <%= SessionInfo.SiteID %>;
        var viewSettings;
        var pnMainYScrollPos = 0;

    </script>
    </telerik:RadScriptBlock>

    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body onresize="body_onresize()" onunload="body_onunload();" onkeydown="body_onkeydown();" style="overflow-y: hidden" scroll="none">
    <form id="form1" runat="server" scroll="none">
    <telerik:RadScriptManager runat="server"  /> 
    <!-- update progress message -->
    <uc:ProgressMessage ID="progressMessage" runat="server" />
    
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="None" Skin="Web20" />
    <telerik:RadWindowManager ID="RadWindowManager1" runat="server" EnableShadow="true" />
    <div style="width:100%;margin:8px;background: white;" scroll="none">
        <div style="background-color: #D6DBEF; border-bottom: solid 2px #E7E7F7;">
            <telerik:RadToolBar ID="radToolbar" runat="server" Skin="Office2007" EnableRoundedCorners="true" EnableShadows="true" OnClientButtonClicked="function (sender, args) { eval(args.get_item().get_commandName()); }" ondragstart="return false;">
                <Items />
            </telerik:RadToolBar>
        </div>
        <div id="divDetails" style="font-size:12px;background:white;border-top:solid 5px #D6DBEF;border-bottom:solid 5px #D6DBEF;padding:5px;">
            <uc:PatientBanner ID="patientBanner" runat="server" />
            <div style="padding-top:5px;">
                <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                <ContentTemplate>
                    <span>Pharmacy Product: </span><asp:Label ID="lbPhamacyProduct" runat="server" Font-Bold="True" />
                    <span style="padding-left:8px;">Batch Number: </span><asp:Label ID="lbBatchNumber" runat="server" Font-Bold="True" />
				    <span style="padding-left:8px;">Expires: </span><asp:Label ID="lbExpires" runat="server" Font-Bold="True" />
                    <br />
                    <span>Dose: </span><asp:Label ID="lbDose" runat="server" Font-Bold="True" />
                    <span style="padding-left:8px;">Volume: </span><asp:Label ID="lbVolume" runat="server" Font-Bold="True" />
                    <span style="padding-left:8px;">Qty: </span><asp:Label ID="lbQty" runat="server" Font-Bold="True" />
                    <span style="padding-left:8px;">Created: </span><asp:Label ID="lbCreated" runat="server" Font-Bold="True" />
                    <br />
                    <span>Scheduled for: </span><asp:Label ID="lbWhen" runat="server" Font-Bold="True" />                    
                    <span style="padding-left:8px;">State: </span><asp:Label ID="lbState" runat="server" Font-Bold="True" />
                    <span style="padding-left:4px;"><asp:Label ID="lbStageUndone" runat="server" CssClass="UndoeAlert" Text="(steps have been undone - see history)" /></span>
                    <br />
                    <span>Printed Worksheet: </span><asp:Label ID="lbPrintedWorksheet" runat="server" Font-Bold="True" />
                    <span style="padding-left:8px;">Printed Label: </span><asp:Label ID="lbPrintedLabel" runat="server" Font-Bold="True" />
                    <span style="padding-left:8px;">Issue State: </span><asp:Label ID="lbIssueState" runat="server" Font-Bold="True" />
                </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>

        <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>
            <!-- warnings -->
            <div id="divMainWarning" runat="server" class="alert" style="width:100%;padding-top:5px;padding-bottom:5px;text-align:center;" />

            <asp:Panel ID="pnMain" runat="server" ScrollBars="Vertical">
            <asp:HiddenField ID="hfViewSettings" runat="server" />
            <table style="width: 100%">
                <colgroup>
                    <col style="width: 21%" />
                    <col style="width: 79%" />
                </colgroup>
                
                <!-- Waiting Scheduling -->                    
                <tr id="trWaitingScheduling" runat="server"> 
                    <td><asp:Label ID="lbStage0" runat="server" /></td>
                    <td class="ControlCell">
                        <div>
                        <asp:UpdatePanel ID="upWaitingScheduling" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>

                        <table cellspacing="8px;">
                            <colgroup>
                                <col style="width:120px;" />
                                <col style="width:140px;" />
                                <col style="width:80px;" />
                                <col style="width:180px;" />
                            </colgroup>
                        <tr>
                            <td>Scheduled for:</td>
                            <td>
                                <asp:TextBox ID="tbScheduleDate" runat="server" ReadOnly="True" CssClass="ReadOnly" />
                                <telerik:RadDatePicker ID="dpScheduleDate" runat="server" ShowPopupOnFocus="True" OnSelectedDateChanged="dpScheduleDate_OnSelectedDateChanged" AutoPostBack="True" Font-Size="10pt" Width="125px" Skin="Web20"  />
                            </td>
                            <td />
                            <td rowspan="2">
                                <asp:TextBox ID="lbWaitingScheduling" runat="server" ReadOnly="True" CssClass="ReadOnly" Width="100%" />
                                <asp:Label ID="lbShiftOverCapacity" runat="server" CssClass="OverCapacity" Text="Currently over capacity" Visible="false" />
                                <asp:Label ID="lbShiftNearCapacity" runat="server" CssClass="NearCapacity" Text="Near capacity"           Visible="false" />
                            </td>
                        </tr>
                        <tr>
                            <td>Shift:</td>
                            <td>
                                <asp:TextBox ID="tbScheduleShift" runat="server" ReadOnly="True" CssClass="ReadOnly" />
                                <asp:DropDownList ID="ddlScheduleShift" runat="server" Width="200px" OnSelectedIndexChanged="ddlScheduleShift_OnSelectedIndexChanged" AutoPostBack="true" />
                                <asp:HiddenField ID="hfConfirmShiftFull" runat="server"/>
                            </td>
                            <td style="vertical-align:bottom;">
                                <asp:Button ID="btnWaitingSchedulingSave" runat="server" CssClass="PharmButton" Text="Save" OnClick="Save_OnClick" />
                            </td>
                        </tr>
                        <tr>
                            <td id="lbWaitingSchedulingError" class="ErrorMessage" runat="server" colspan="2" />
                        </tr>
                        </table>

                        </ContentTemplate>
                        </asp:UpdatePanel>
                        </div>
                    </td>
                </tr>
                
                <!-- Waiting Production Tray -->
                <tr id="rWaitingProductionDivider" runat="server"><td colspan="2" class="DividerCell"><hr class="Divider" /></td></tr>
                <tr id="trWaitingProductionTray" runat="server"> 
                    <td><asp:Label ID="lbStage1" runat="server" /></td>
                    <td class="ControlCell">
                        <div>
                        <table cellspacing="8px;">
                            <colgroup>
                                <col style="width:120px;" />
                                <col style="width:140px;" />
                                <col style="width:280px;" />
                            </colgroup>                            
                        <tr>
                            <td>Production Tray:</td>
                            <td onkeydown="if(event.keyCode == 13) { $('#btnWaitingProductionTraySet').click(); }"><asp:TextBox runat="server" ID="tbProductionTrayBarcode" /></td>
                            <td>
                                <asp:Button ID="btnWaitingProductionTraySet" runat="server" CssClass="PharmButton" Text="Set" OnClick="Save_OnClick" />
                                <asp:TextBox ID="lbWaitingProductionTray" runat="server" ReadOnly="True" CssClass="ReadOnly" Width="100%" />
                            </td>
                        </tr>
                        <tr>
                            <td />
                            <td id="tdWaitingProductionTrayError" class="ErrorMessage" runat="server" colspan="2" />
                        </tr>
                        </table>
                        </div>
                    </td>
                </tr>
                
                <!-- Ready to assemble -->
                <tr id="trReadyToAssembleDivider" runat="server"><td colspan="2" class="DividerCell"><hr class="Divider" /></td></tr>
                <tr id="trReadyToAssemble" runat="server">
                    <td><asp:Label ID="lbStage2" runat="server" /></td>
                    <td class="ControlCell">
                        <asp:HiddenField ID="hfReadyToAssembleSelectedRowDBID"   runat="server" />
                        <asp:HiddenField ID="hfReadyToAssembleIfWizardDisplayed" runat="server" />
                        <div style="padding-bottom:10px;">Ingredient List:</div>
                        <div id="divReadyToAssemble" style="padding-right:10px;height:175px;width:100%;">
                            <uc:GridControl ID="gcReadyToAssemble" runat="server" EmptyGridMessage="None selected" EnableAlternateRowShading="True" EnableViewState="True" SortableColumns="False" />
                        </div>
                        <div style="width:100%;vertical-align:top;padding-top:10px;">
                            <span style="display:inline-block;width:80%">
                                <uc:PanelControl ID="pcReadyToAssemble" runat="server" style="width:100%" />
                            </span>
                            <span style="display:inline-block;vertical-align:top;">
                                <asp:Button ID="btnReadyToAssembleSelect" runat="server" Text="Select..." CssClass="PharmButton" OnClientClick="btnReadyToAssembleSelect_OnClientClick(); return false;" />
                                <asp:Button ID="btnReadyToAssembleFinish" runat="server" Text="Finished"  CssClass="PharmButton" OnClick="Save_OnClick" />
                                <asp:Button ID="btnReadyToAssembleRemove" runat="server" Text="Remove"    CssClass="PharmButton" OnClick="btnReadyToAssembleRemove_OnClick" />
                            </span>
                        </div>
                    </td>
                </tr>
                
                <!-- Read to Check -->
                <tr id="trReadToCheckDivider" runat="server"><td colspan="2" class="DividerCell"><hr class="Divider" /></td></tr>
                <tr id="trReadToCheck" runat="server">
                    <td><asp:Label ID="lbStage3" runat="server" /></td>
                    <td class="ControlCell">
                        <asp:HiddenField ID="hfCheckedItems" runat="server" Value="" />
                        <asp:HiddenField ID="hfReadToCheckIfEnabled"  runat="server" />
                        <asp:MultiView ID="mvReadyToCheck" runat="server">
                        <Views>
                            <asp:View ID="vSingleCheck" runat="server">
                                Login to confirm you have checked the ingredients<br />
                                <table>
                                    <tr style="vertical-align: top">
                                        <td onkeydown="if (event.keyCode == 13) { $('#btnReadyToCheck').click(); }" style="width:300px;">
                                            <uc:SecondCheck ID="ucReadyToCheckSingleCheck" runat="server" />    
                                        </td>
                                        <td>
                                            <asp:Button ID="btnReadyToCheckSingleCheck" runat="server" CssClass="PharmButton" Text="Checked" Width="125px" Height="50px" OnClientClick="return btnReadyToCheck_OnClick('ucReadyToCheckSingleCheck');" OnClick="Save_OnClick" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:View>

                            <asp:View ID="vIndividualCheck" runat="server">
                                Check each ingredient to confirm<br />
                                <div id="divReadyToCheckIndividualCheck" style="padding-right:10px;padding-bottom:10px;height:175px;width:100%;">
                                    <uc:GridControl ID="gcReadyToCheckIndividualCheck" runat="server" EmptyGridMessage="None selected" EnableAlternateRowShading="True" EnableViewState="True" SortableColumns="False" />
								</div>
							    <div style="width:80%;vertical-align:top;padding-top:10px;">
									<uc:PanelControl ID="pcReadyToCheckIndividualCheck" runat="server" style="width:100%" />
								</div>
								<div id="divReadyToCheckIndividualCheckError" class="ErrorMessage" runat="server">&nbsp;</div>
								
                                <table>
                                    <tr style="vertical-align: top">
                                        <td onkeydown="if (event.keyCode == 13) { $('#btnReadyToCheck').click(); }" style="width:300px;">
                                            <uc:SecondCheck ID="ucReadyToCheckIndividualCheck" runat="server" />    
                                        </td>
                                        <td>
                                            <asp:Button runat="server" CssClass="PharmButton" Text="Checked" Width="125px" Height="50px" OnClientClick="return btnReadyToCheck_OnClick('ucReadyToCheckIndividualCheck');" OnClick="Save_OnClick" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:View>

                            <asp:View ID="vSingleCheckSingleUser" runat="server">
                                <asp:Button runat="server" CssClass="PharmButton" Text="Checked" Width="125px" Height="50px" OnClick="Save_OnClick" />
                            </asp:View>

                            <asp:View ID="vIndividualCheckSingleUser" runat="server">
                                Check each ingredient to confirm<br />
                                <div id='divReadyToCheckIndividualCheckSingleUser' style="padding-right:10px;padding-bottom:10px;height:175px;width:100%;">
                                    <uc:GridControl ID="gcReadyToCheckIndividualCheckSingleUser" runat="server" EmptyGridMessage="None selected" EnableAlternateRowShading="True" EnableViewState="True" SortableColumns="False" />
                                </div>
							    <div style="width:80%;vertical-align:top;padding-top:10px;">
									<uc:PanelControl ID="pcReadyToCheckIndividualCheckSingleUser" runat="server" style="width:100%" />
								</div>								
								<div id="divReadyToCheckIndividualCheckSingleUserError" class="ErrorMessage" runat="server">&nbsp;</div>
                                <div style="padding-right:10px;padding-bottom:10px;width:100%;text-align: right">
                                    <asp:Button runat="server" CssClass="PharmButton" Text="Checked" Width="125px" Height="50px" OnClientClick="btnReadyToCheck_OnClick();" OnClick="Save_OnClick" />
                                </div>
                            </asp:View>
                            
                            <asp:View ID="vReadyToCheckLabel" runat="server">
                                <asp:TextBox ID="tbReadToCheck" 	runat="server" ReadOnly="True" CssClass="ReadOnly" Width="500px" />
                                <asp:TextBox ID="tbSelfCheckReason" runat="server" ReadOnly="True" CssClass="ReadOnly" Width="500px" />
                                <div id="divReadyToCheckLabel" runat="server" style="padding-right:10px;padding-bottom:10px;height:175px;width:100%;">
                                    <uc:GridControl ID="gcReadyToCheckLabel" runat="server" EmptyGridMessage="None selected" EnableAlternateRowShading="True" EnableViewState="True" SortableColumns="False" />
                                </div>
							    <div style="width:80%;vertical-align:top;padding-top:10px;">
									<uc:PanelControl ID="pcReadyToCheckLabel" runat="server" style="width:100%" />
								</div>								
                            </asp:View>
                        </Views>
                        </asp:MultiView>
                    </td>
                </tr>
                
                
                <!-- Ready to compound -->
                <tr><td colspan="2" class="DividerCell"><hr class="Divider" /></td></tr>
                <tr>
                    <td><asp:Label ID="lbStage4" runat="server" /></td>
                    <td class="ControlCell">
                        <asp:HiddenField ID="hfImageData" runat="server"/>
                        <div>
                            <div ID="divImageCaptureStores" runat="server">
                                <OBJECT 
					                id=objStores
                                    style="left:0px;top:0px;width:1px;height:1px"
					                codebase="../../../ascicw/cab/HEdit.cab" 
					                component="StoresCtl.ocx"
					                classid=CLSID:D0E003F3-1F55-48DA-8231-434BE54EF6E2 VIEWASTEXT>
					                <SPAN STYLE="color:red">ActiveX control failed to load! -- Please check browser security settings.</SPAN>
				                </OBJECT>
                            </div>
                            <table>
                                <tr style="vertical-align: top;">
                                    <td ID="tdImageCapture" runat="server">
                                        <SCRIPT language="javascript" for="ImageCapture" event="OnImageCaptured(asUniqueId,asFileName, binJPEGData)">ImageCapture_OnImageCaptured(asUniqueId, asFileName, binJPEGData);</SCRIPT>
                                        <object id='ImageCapture' height="225px" width="300px" classid="CLSID:9891C3B1-0B99-4262-9A96-8C6608AECAE8"></object>            
                                    </td>
                                    <td>
                                        <asp:Image id="imgManufacturedProduct" runat="server" Width="300px" Height="225px" Visible="true" BorderStyle="Solid" BorderColor="Black" BorderWidth="1px" ImageAlign="Top"/>                                           
                                    </td>
                                </tr>
                                <tr ID="trImageCaptureTakePicture" runat="server" style="height: 70px;">
                                    <td colspan="2"  style="text-align:center;">
                                        <button id="btnTakePicture" class="PharmButton" runat="server"
                                            style="width:125px;height:50px; visibility: visible;" 
                                            onclick="ImageCapture.ManualTrigger();">Take Picture</button>                                           
                                    </td>
                                </tr>
                            </table>
                            
                        </div>
                        <table style="width:87%;">
                        <tr>
                            <td style="text-align:left;">
                                <asp:Button ID="btnReadyToCompound" runat="server" CssClass="PharmButton" Width="125px" Height="50px" Text="Compounded" OnClick="Save_OnClick" OnClientClick="return btnReadyToCompound_onclick();" />
                            </td>
                            <td style="text-align:right;">
                            <asp:Button ID="btnReadyToCompoundShowMethod" runat="server" CssClass="PharmButton" Width="125px" Height="50px" Text="Show Method..." OnClick="btnReadyToCompoundShowMethod_OnClick" OnClientClick="btnReadyToCompoundShowMethod_onclick();" />
                            </td>
                        </tr>
                        </table>
                        <asp:TextBox ID="tbReadyToCompound" runat="server" ReadOnly="True" CssClass="ReadOnly" Width="500px" />
                        <asp:TextBox ID="tbReadyToCompoundNoPic" runat="server" ReadOnly="True" CssClass="ReadOnly" Width="500px" Text="<No picture taken>" />
                    </td>
                </tr>
                
                <!-- Label -->
                <tr id="trReadyToLabelDiv" runat="server"><td colspan="2" class="DividerCell"><hr class="Divider" /></td></tr>
                <tr id="trReadyToLabel" runat="server">
                    <td><asp:Label ID="lbStage5" runat="server" /></td>
                    <td class="ControlCell">
                        <asp:HiddenField ID="hfWLabelId"        runat="server" Value="" />
                        <asp:HiddenField ID="hfNumberOfLabels"  runat="server" Value="" />
                        <asp:MultiView ID="mvLabel" runat="server">
                        <Views>
                            <asp:View ID="vLabelEmpty" runat="server" />

                            <asp:View ID="vLabelDispensing" runat="server">
<% if (this.settings.isActiveXControlEnabled) %>
<% { %>
                                <div style="width:620px;height:250px;padding-bottom:8px;border:none;">
                                    <iframe id="fraDispensing" application="yes" style="width:660px;height:250px;border:none;" src="../Dispensing/ICW_Dispensing.aspx?SessionID=<%= SessionInfo.SessionID %>&AscribeSiteNumber=<%= SessionInfo.SiteNumber %>&WindowID=<%= Request["WindowID"] %>&EmbeddedMode=Y&ShowHeader=N"></iframe>
                                </div>
<% } %>
                                <asp:Button ID="btnLabel" runat="server" CssClass="PharmButton" Width="75px" Height="30px" Text="Label" OnClientClick="try { btnLabel_onclick(); } finally { return false; }" />
                            </asp:View>

                            <asp:View ID="vLabelLabel" runat="server">
                                <asp:TextBox ID="tbReadyToLabel" runat="server" ReadOnly="True" CssClass="ReadOnly" Width="500px" />
                            </asp:View>
                        </Views>
                        </asp:MultiView>
                    </td>
                </tr>

                <!-- Final Check -->
                <tr id="trFinalCheckDivider" runat="server"><td colspan="2" class="DividerCell"><hr class="Divider" /></td></tr>
                <tr id="trFinalCheck" runat="server">
                    <td><asp:Label ID="lbStage6" runat="server" /></td>
                    <td class="ControlCell">
                        <table id="tblFinalCheck" runat="server">
                            <tr style="vertical-align: top">
                                <td id="tdFinalCheckSecondCheck"  runat="server" onkeydown="if (event.keyCode == 13) { $('#btnFinalCheck').click(); }" style="width:300px;">
                                    <uc:SecondCheck ID="ucFinalCheck" runat="server" />
                                </td>
                                <td>
                                    <asp:Button ID="btnFinalCheck" runat="server" CssClass="PharmButton" Width="125px" Height="50px" Text="Checked" OnClientClick="return (typeof(validateSecondCheck) === 'function' ? validateSecondCheck(sessionId, 'ucFinalCheck'); : true);" OnClick="Save_OnClick" />
                                </td>
                            </tr>
                        </table>
                        <asp:TextBox ID="tbFinalCheck"       runat="server" ReadOnly="true" CssClass="ReadOnly" Width="500px" />
                        <asp:TextBox ID="tbFinalCheckReason" runat="server" ReadOnly="True" CssClass="ReadOnly" Width="500px" />
                    </td>
                </tr>
                
                <!-- Bond Store -->
                <tr id="trBondStoreDivider" runat="server" ><td colspan="2" class="DividerCell"><hr class="Divider" /></td></tr>
                <tr id="trBondStore" runat="server" >
                    <td><asp:Label ID="lbStage7" runat="server" /></td>
                    <td class="ControlCell">
                        <asp:Button ID="btnBondStore" runat="server" CssClass="PharmButton" Width="150px" Height="50px" Text="Release from Bond Store" OnClick="Save_OnClick" />
                        <asp:TextBox ID="tbBondStore" runat="server" ReadOnly="True" CssClass="ReadOnly" Width="500px" />                        
                    </td>
                </tr>
                
                <!-- Ready To Release -->
                <tr id="trReadyToReleaseDivider" runat="server"><td colspan="2" class="DividerCell"><hr class="Divider" /></td></tr>
                <tr id="trReadyToRelease" runat="server" >
                    <td><asp:Label ID="lbStage8" runat="server" /></td>
                    <td class="ControlCell">
                        <asp:Button ID="btnReadyToRelease" runat="server" CssClass="PharmButton" Width="150px" Height="50px" Text="Complete" OnClick="Save_OnClick" />
                        <asp:TextBox ID="tbReadyToRelease" runat="server" ReadOnly="True" CssClass="ReadOnly" Width="500px" />                        
                    </td>
                </tr>
            </table>
            </asp:Panel>
        </ContentTemplate>
        </asp:UpdatePanel>
            
        <div id="divBtns" style="width:100%;height:75px;border-top:solid 5px #D6DBEF;text-align:center;">
            <br />
            <asp:Button ID="btnOK" runat="server"  CssClass="PharmButton" Text="OK" OnClientClick="window.close();" Height="40px" Width="140px" />
        </div>
    </div>
    </form>
    
    <xml id="xmlStatusNoteFilter"><StatusNoteFilter action="include" /></xml>
</body>
</html>
