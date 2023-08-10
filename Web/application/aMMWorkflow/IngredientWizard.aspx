<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IngredientWizard.aspx.cs" Inherits="application_aMMWorkflow_IngredientWizard" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<%--<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>--%>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx"               tagname="ProgressMessage"   tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/PatientBanner/PatientBanner.ascx"   tagname="PatientBanner"     tagprefix="uc" %>   
<%@ Register src="../pharmacysharedscripts/BatchTracking/BatchTracking.ascx"   tagname="BatchTracking"     tagprefix="uc" %>   

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "IngredientWizard.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add Ingredients</title>
    <base target="_self" />

    <link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"                                 rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../sharedscripts/json2.js"                              defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"           defer></script>
    <script type="text/javascript" src="script/IngredientWizard.js"                             async></script>
    <script type="text/javascript">
        SizeAndCentreWindow("860px", "710px");
    </script>
     

    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body onkeydown="body_onkeydown();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <uc:ProgressMessage ID="progressMessage" runat="server" />
    <div class="icw-container-fixed" style="height:98%">
        <div style="margin-left:10px;margin-right:10px;" >
            <hr />
            <uc:PatientBanner ID="patientBanner" runat="server" />
            <div style="padding-top:5px;">
                <span>Pharmacy Product: </span><asp:Label ID="lbPhamacyProduct" runat="server" Font-Bold="True" />
                <br />
                <span>Batch Number: </span><asp:Label ID="lbBatchNumber" runat="server" Font-Bold="True" />
                <span style="padding-left:10px;">Dose: </span><asp:Label ID="lbDose" runat="server" Font-Bold="True" />
                <span style="padding-left:10px;">Volume: </span><asp:Label ID="lbVolume" runat="server" Font-Bold="True" />
            </div>
            <hr />
        </div>
        <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>
            <asp:HiddenField ID="hfCurrentStep"            runat="server" />
            <asp:HiddenField ID="hfCurrentIngredientIndex" runat="server" />
            <asp:HiddenField ID="hfIfSavedData"            runat="server" />
            <asp:HiddenField ID="hfErrorMessage"           runat="server" />
            <asp:HiddenField ID="hfSteps"                  runat="server" />

            <asp:MultiView ID="multiView" runat="server">
                <asp:View ID="vSelectIngredient" runat="server">
                    <asp:HiddenField ID="hfSearchText" runat="server" />
                    <asp:HiddenField ID="hfNSVCode" runat="server" />
                    <div style="overflow-y:hidden;">
                        <iframe id="fraPharmacyProductSearch" application="yes" style="margin-top:-52px;width:100%;height:565px;" src="../PharmacyProductSearch/ICW_PharmacyProductSearch.aspx?SessionID=<%= SessionInfo.SessionID %>&SiteID=<%= SessionInfo.SiteID %>&WindowID=<%= Request["WindowID"] %>&EmbeddedMode=Y&VB6Style=N&AllowBNF=N&InUseOnly=Y&EnableSearching=N&SearchText=<%= this.hfSearchText.Value %>&<%= string.IsNullOrEmpty(this.hfNSVCode.Value) ? string.Empty : "&SelectNSVCode=" + this.hfNSVCode.Value %>"></iframe>
                    </div>
                    <div style="width:100%;text-align:center;">
                        <asp:Label id="errorMessage" CssClass="ErrorMessage" runat="server" Text="&nbsp" />
                    </div>
                </asp:View>
                
                <asp:View ID="vEnterQuantity" runat="server" >
                    <asp:HiddenField ID="hfEnterQuantityConfirm" runat="server" />
                    <table style="margin: 10px;">
                        <tr>
                            <td>Issuing: </td>
                            <td><asp:Label ID="lbIngredient" runat="server" /></td>
                        </tr>
                        <tr>
                            <td>Total amount to issue: </td>
                            <td><asp:Label ID="lbTotalToIssue" runat="server" /></td>
                        </tr>
                        <tr>
                            <td>Amount remaining: </td>
                            <td><asp:Label ID="lbStillToIssue" runat="server" /></td>
                        </tr>
                        <tr><td>&nbsp;</td></tr>
                        <tr>
                            <td>Issue: </td>
                            <td><asp:TextBox ID="tbAmountToIssue" runat="server" Width="75px" />&nbsp;<asp:Label ID="lbIssueUnits" runat="server" />(s)</td>
                        </tr>
                        <tr>
                            <td />
                             <td><asp:Label ID="lbAmountToIssueError" runat="server" CssClass="ErrorMessage" /></td>
                        </tr>
                    </table>
                </asp:View>
                
                <asp:View ID="vBatchTracking" runat="server">
                    <div style="margin:10px;">
                    Enter barcode details for <asp:Label ID="lbBatchTrackingProduct" runat="server" Font-Bold="True" /><br />
                    <br />
                    <asp:UpdatePanel ID="upBatchTracking" runat="server">                        
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="ucBatchTracking" />
                    </Triggers>
                    <ContentTemplate>                        
                        <uc:BatchTracking ID="ucBatchTracking" runat="server" />
                    </ContentTemplate>
                    </asp:UpdatePanel>
                    </div>
                </asp:View>
            </asp:MultiView>

            <div style="position:absolute;bottom:15px;right:25px;width:160px;text-align:right;z-index:99">
                <asp:Button ID="btnBack" runat="server" CssClass="PharmButton" Text="< Back" Width="75px" OnClick="btnBack_OnClick" AccessKey="B" />
                <asp:Button ID="btnNext" runat="server" CssClass="PharmButton" Text="Next >" Width="75px" OnClientClick="return btnNext_onclick();" OnClick="btnNext_OnClick" AccessKey="N" />
            </div>

            <div style="position:absolute;bottom:15px;width:99%;text-align:center;"> 
                <asp:Button ID="btnCancel" runat="server" CssClass="PharmButton" Text="Cancel" AccessKey="C" Width="75px" OnClientClick="window.returnValue=$('#hfIfSavedData').val();window.close();return false;" />
            </div>
        </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    </form>
         <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
