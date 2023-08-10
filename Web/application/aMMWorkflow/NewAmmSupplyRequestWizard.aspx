<%@ Page Language="C#" AutoEventWireup="true" CodeFile="NewAmmSupplyRequestWizard.aspx.cs" Inherits="application_Manufacturing_NewAmmSupplyRequestWizard" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx"               tagname="ProgressMessage"   tagprefix="uc" %>
<%@ Register src="controls/aMMVolumeCalculation.ascx"                          tagname="VolumeCalculation" tagprefix="uc" %>
<%@ Register src="controls/aMMSyringeManager.ascx"                             tagName="SyringeManager"    tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/PatientBanner/PatientBanner.ascx"   tagname="PatientBanner"     tagprefix="uc" %>   

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=SessionInfo.SessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "NewAmmSupplyRequestWizard.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add AMM Supply Request</title>
    <base target="_self" />

	<link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"                                 rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.11.3.min.js"              async></script>
    <script type="text/javascript" src="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../sharedscripts/json2.js"                              defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"           defer></script>
    <script type="text/javascript" src="script/NewAmmSupplyRequestWizard.js"                    async></script>    
    <script type="text/javascript" src="script/aMMVolumeCalculation.js"                         defer></script>    
    <script type="text/javascript">
        SizeAndCentreWindow("860px", "710px");
    </script>
   

    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body onkeydown="if (event.keyCode==13) { $('#btnNext').click(); }">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <uc:ProgressMessage ID="progressMessage" runat="server" />
    <div class="icw-container-fixed" style="height:98%">
        <div style="margin-left:10px;margin-right:10px;" >
            <hr />
            <uc:PatientBanner ID="patientBanner" runat="server" />
            <div  style="padding-top:5px;">
                Prescription: <asp:Label ID="lbPrescription" runat="server" Font-Bold="True" /><br />
                Prescription Dose: <asp:Label ID="lbDose" runat="server" Font-Bold="True" />
            </div>
        </div>
        <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>
            <asp:HiddenField ID="hfCurrentStep" runat="server" />
            <div id="divPhamacyProductDescription" style="margin-left:10px;margin-right:10px;" >
                <asp:Label id="lbPhamacyProductDescription" runat="server" Text="Pharmacy Product: " Visible="False" /><asp:Label ID="lbPhamacyProduct" runat="server" style="font-weight: bold;" Text="&nbsp;"/>
            </div>
            <hr />

            <asp:MultiView ID="multiView" runat="server">
                <asp:View ID="vFindDrug" runat="server">
                    <asp:HiddenField ID="hfNSVCode" runat="server" />
                    <asp:HiddenField ID="hfFindDrugConfirmWarnings" runat="server" />
                    <div style="overflow-y:hidden;">
                        <iframe id="fraPharmacyProductSearch" application="yes" style="margin-top:-52px;width:100%;height:565px;" src="../PharmacyProductSearch/ICW_PharmacyProductSearch.aspx?SessionID=<%= SessionInfo.SessionID %>&SiteID=<%= SessionInfo.SiteID %>&WindowID=<%= Request["WindowID"] %>&EmbeddedMode=Y&VB6Style=N&AllowBNF=N&EnableSearching=N&CivasOnly=Y&InUseOnly=Y&RequestID=<%= this.requestIdParent %><%= string.IsNullOrEmpty(hfNSVCode.Value) ? string.Empty : "&SelectNSVCode=" + hfNSVCode.Value %>"></iframe>
                    </div>
                </asp:View>
                
                <asp:View ID="vSelectDetails" runat="server">
                    <div style="margin: 10px; vert-align: middle;">
                        <asp:Label runat="server" Width="255px" Text="Enter Number of doses:" Font-Bold="true" />
                        <asp:TextBox ID="tbNumberOfDoses" runat="server" Width="50px" />&nbsp;
                        <asp:Label id="errorMsgNumberOfDoses" CssClass="ErrorMessage" runat="server" Text="&nbsp" />
                    </div>
            

              <span runat="server" id="DisplayBatchNumber" Visible="false"> 					
                    <div style="margin: 10px; vert-align: middle;">
                        <asp:Label ID="lbBatchNo" runat="server" Width="255px" Text="Batch Number:" Font-Bold="true" />
                        <asp:TextBox ID="tbBatchNumber" runat="server" MaxLength="20" Width="165px" />&nbsp;                      
                        <asp:Label id="errorMsgBatchNumber" CssClass="ErrorMessage" runat="server" Text="&nbsp" />   
                     </div>
			  </span>
                    
                    <div style="margin-top:10px;margin-left:4px;font-weight:bold;font-style:italic;font-size:larger;">Select Volume</div>
                    <uc:VolumeCalculation ID="volumeCalculation" runat="server" />

                    <asp:Panel ID="pnSelectDetails" runat="server">
                        <hr style="width:80%;" />

                        <table style="margin:8px">
                        <colgroup>
                            <col style="width:255px" />
                            <col style="width:110px" />
                        </colgroup>
                        <tr>
                            <td style="vertical-align:top;font-weight:bold;">
                                <asp:Label ID="lblEpisodeMsg" runat="server" /><br />
                                Please select episode type
                            </td>
                            <td><asp:ListBox ID="lbEpisodeTypes" runat="server" Height="100px" SelectionMode="Single" AutoPostBack="false" /></td>
                            <td><asp:Label id="errorMsgEpisodeTypes" CssClass="ErrorMessage" runat="server" Text="&nbsp" /></td>
                        </tr>
                        </table>
                    </asp:Panel>
                </asp:View>

                <asp:View ID="vSelectSyringeFillType" runat="server">
                    <div style="margin:8px;">Syringe Manager</div>
                    <div style="margin-left:10px;margin-right:10px;width:100%">
                        <uc:SyringeManager ID="syringeManager" runat="server" />
                    </div>
                </asp:View>
            </asp:MultiView>

            <div style="width:100%;text-align:center;">
                <asp:Label id="errorMessage" CssClass="ErrorMessage" runat="server" Text="&nbsp" />
            </div>

            <div style="position:absolute;bottom:15px;right:25px;width:160px;text-align:right;z-index:99"> 
                <asp:Button ID="btnNext" runat="server" CssClass="PharmButton" Text="Next >" Width="75px" OnClientClick="return btnNext_onclick();" OnClick="btnNext_OnClick" AccessKey="N" />
            </div>

            <div style="position:absolute;bottom:15px;width:99%;text-align:center;"> 
                <asp:Button ID="btnCancel" runat="server" CssClass="PharmButton" Text="Cancel" AccessKey="C" Width="75px" OnClientClick="window.returnValue=null;window.close();return false;" />
            </div>
        </ContentTemplate>
        </asp:UpdatePanel>
    </div>       
    </form>
     <frame id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
