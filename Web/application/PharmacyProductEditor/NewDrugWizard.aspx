<%@ Page Language="C#" AutoEventWireup="true" CodeFile="NewDrugWizard.aspx.cs" Inherits="application_PharmacyProductEditor_NewDrugWizard" %>

<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register Src="../pharmacysharedscripts/ProgressMessage.ascx" TagName="ProgressMessage" TagPrefix="uc" %>
<%@ Register Src="../pharmacysharedscripts/QuesScrl/QuesScrl.ascx" TagName="QuesScrl" TagPrefix="uc" %>
<%@ Register Src="../pharmacysharedscripts/PharmacyGridControl.ascx" TagName="GridControl" TagPrefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "NewDrugWizard.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add New Product</title>
    <base target="_self" />

    <link href="../../style/ScrollTableContainer.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css" rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css" rel="stylesheet" type="text/css" />
    <link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../pharmacysharedscripts/QuesScrl/QuesScrl.css" rel="stylesheet" type="text/css" />
    <style>
        .icw-title {
            font-weight: bold;
            font-size: 12px;
        }
    </style>

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js" async></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js" async></script>
    <script type="text/javascript" src="../sharedscripts/icwcombined.js" defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js" defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js" async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/QuesScrl/QuesScrl.js" defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" defer></script>
    <script type="text/javascript" src="script/NewDrugWizard.js" async></script>
   
    <script type="text/javascript">
        SizeAndCentreWindow("860px", "710px");
    </script>



    <style type="text/css">
        html, body {
            height: 99%
        }
    </style>
    <!-- Ensure page is full height of screen -->
</head>
<body onkeydown="body_onkeydown();" onload="GPEInit();">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="icw-container" style="height: 98%">
            <uc:ProgressMessage ID="progressMessage" runat="server" />

            <!-- update progress message -->
            <asp:UpdatePanel ID="upMain" runat="server">
                <ContentTemplate>
                    <asp:HiddenField ID="hfCurrentStep" runat="server" />
                    <asp:HiddenField ID="hfProducts" runat="server" />

                    <div id="divHeader" runat="server" style="margin-top: 10px; margin-left: 10px; margin-right: 10px;">
                        <asp:HiddenField ID="hfHeaderSuffix" runat="server" />
                        <hr />
                        <span id="spanHeader" runat="server" class="icw-title" />
                        <hr />
                    </div>

                    <asp:MultiView ID="multiView" runat="server">
                        <asp:View ID="vSelectAddMethodType" runat="server">
                            <div style="margin: 10px">
                                <br />

                                <asp:RadioButtonList ID="rblSelectAddMethod" runat="server" CellPadding="5">
                                    <asp:ListItem Text="Import Product from DSS Master File" Value="0" Selected="True" />
                                    <asp:ListItem Text="Import Product from Other Site" Value="1" />
                                    <asp:ListItem Text="Medicinal Product" Value="2" />
                                    <asp:ListItem Text="Non-Medicinal Product" Value="3" />
                                    <asp:ListItem Text="Stores Only Product" Value="4" />
                                    <asp:ListItem Text="Copy Existing" Value="5" />
                                </asp:RadioButtonList>
                            </div>
                        </asp:View>

                        <asp:View ID="vFindDrug" runat="server">
                            <div style="margin-top: 10px; margin-left: 10px; margin-right: 10px;">
                                <asp:HiddenField ID="hfFindDrugExtraParams" runat="server" />
                                <asp:HiddenField ID="hfNSVCode" runat="server" />
                                <iframe id="fraPharmacyProductSearch" application="yes" width="100%" height="570px" src="../PharmacyProductSearch/ICW_PharmacyProductSearch.aspx?SessionID=<%= SessionInfo.SessionID %>&WindowID=<%= Request["WindowID"] %>&EmbeddedMode=true&VB6Style=false<%= hfFindDrugExtraParams.Value %>"></iframe>
                            </div>
                        </asp:View>

                        <asp:View ID="vFindProduct" runat="server">
                            <div style="margin: 10px">
                                <asp:HiddenField ID="hfFindProductParams" runat="server" />
                                <asp:HiddenField ID="hfProductID" runat="server" />
                                <iframe id="fraICWProductSearch" application="yes" width="100%" height="610px" src="../pharmacysharedscripts/PharmacyLookupList.aspx?SessionID=<%= SessionInfo.SessionID %>&WindowID=<%= Request["WindowID"] %>&EmbeddedMode=true&SearchType=PostBack&MinSearchChars=3<%= hfFindProductParams.Value %>"></iframe>
                            </div>
                        </asp:View>

                        <asp:View ID="vNMPList" runat="server">
                            <div style="margin: 10px">
                                <asp:RadioButtonList ID="rblNMPList" runat="server" CellSpacing="10" />
                            </div>
                        </asp:View>

                        <asp:View ID="vMedicalProductAddType" runat="server">
                            <div style="margin: 10px">
                                <asp:HiddenField ID="hfConfirmedMsg" runat="server" />
                                <br />

                                <asp:RadioButtonList ID="rblMedicalProductAddType" runat="server" CellPadding="5">
                                    <asp:ListItem Text="Add New Pharmacy Item" Value="0" Selected="True" />
                                    <asp:ListItem Text="Create New Product From Existing Pharmacy Product" Value="1" />
                                </asp:RadioButtonList>
                            </div>
                        </asp:View>

                        <asp:View ID="vAMPPList" runat="server">
                            <div style="margin: 10px">
                                <asp:HiddenField ID="hfAMPPListExtraParams" runat="server" />
                                <asp:HiddenField ID="hfAMPPProductID" runat="server" />
                                <asp:HiddenField ID="hfAMPPConfirm" runat="server" />
                                <iframe id="fraAMPPList" application="yes" width="100%" height="550px" src="../pharmacysharedscripts/PharmacyLookupList.aspx?SessionID=<%= SessionInfo.SessionID %>&WindowID=<%= Request["WindowID"] %>&EmbeddedMode=true&<%= hfAMPPListExtraParams.Value %>"></iframe>
                            </div>
                        </asp:View>

                        <asp:View ID="vSelectImportFromSite" runat="server">
                            <div style="margin: 10px">
                                <br />

                                <asp:Panel ID="pnSelectImportFromSite" runat="server" Height="525px">
                                    <!- scrolls if over 60 sites -->
                                <asp:RadioButtonList ID="rblSelectImportFromSite" runat="server" CellPadding="2" Width="650px" />
                                    <!- adds columns for over 20 sites -->
                                </asp:Panel>
                            </div>
                        </asp:View>


                        <asp:View ID="vHTMLInfoPanel" runat="server">
                            <div id="divHTMLInfoPanel" runat="server" style="margin: 10px;" />
                        </asp:View>


                        <asp:View ID="vDisplayEditor" runat="server">
                            <asp:HiddenField ID="hfDisplayEditorValidated" runat="server" />
                            <br />
                            <div id="divDisplayEditor" style="margin: 10px; height: 570px">
                                <uc:QuesScrl ID="editorControl" runat="server" OnValidated="editorControl_OnValidated" OnSaved="editorControl_OnSaved" />
                            </div>
                        </asp:View>


                        <asp:View ID="vSelectImportToSites" runat="server">
                            <div style="margin: 10px">
                                <asp:Button ID="btnCheckAll" runat="server" CssClass="PharmButtonSmall" Width="65px" OnClientClick="$('#cblSelectImportToSites :checkbox:enabled').prop('checked', true ); return false;" Text="Check All" />&nbsp;&nbsp;
                            <asp:Button ID="btnUncheckAll" runat="server" CssClass="PharmButtonSmall" Width="65px" OnClientClick="$('#cblSelectImportToSites :checkbox:enabled').prop('checked', false); return false;" Text="Uncheck All" />
                                <br />
                                <br />

                                <asp:Panel ID="pnSelectImportToSites" runat="server" Height="525px">
                                    <!- scrolls if over 60 sites -->
                                <asp:CheckBoxList ID="cblSelectImportToSites" runat="server" CellPadding="2" Width="650px" />
                                    <!- adds columns for over 20 sites -->
                                </asp:Panel>
                            </div>
                        </asp:View>


                        <asp:View ID="vEditMultipleSites" runat="server">
                            <asp:HiddenField ID="hfEditMultipleSitesValidated" runat="server" />
                            <br />
                            <div id="divEditMultipleSites" style="margin: 10px; height: 570px">
                                <uc:QuesScrl ID="editMultipleSites" runat="server" ShowHeaderRow="true" OnValidated="editMultipleSites_Validated" />
                            </div>
                        </asp:View>


                        <asp:View ID="vMessage" runat="server">
                            <div id="divMessage" style="margin: 10px;">
                                <br />

                                <div style="margin: 10px;">
                                    <span id="spanMessage" runat="server" />
                                </div>
                            </div>
                        </asp:View>
                    </asp:MultiView>

                    <div class="ErrorMessage" runat="server" id="errorMessage" style="width: 100%; text-align: center;" />

                    <!-- Dispite being in order Cancel then Next on screen have Next button first so looks selected by default       -->
                    <!-- Set z-index so button is above cancel (that takes full screen width) and so prevents problems when clicking -->
                    <div style="position: absolute; bottom: 25px; right: 25px; width: 160px; text-align: right; z-index: 99">
                        <asp:Button ID="btnNext" runat="server" CssClass="PharmButton" Text="Next >" Width="75px" OnClick="btnNext_OnClick" OnClientClick="return btnNext_OnClick();" AccessKey="N" />
                    </div>

                    <div style="position: absolute; bottom: 25px; width: 99%; text-align: center;">
                        <asp:Button ID="btnCancel" runat="server" CssClass="PharmButton" Text="Cancel" Width="75px" OnClientClick="window.returnValue=null;window.close();return false;" AccessKey="C" />
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>            
        </div>        
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
