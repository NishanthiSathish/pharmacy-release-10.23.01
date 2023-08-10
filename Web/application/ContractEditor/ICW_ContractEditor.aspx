<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_ContractEditor.aspx.cs" Inherits="application_ContractEditor_ICW_ContractEditor" %>

<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx" tagname="ProgressMessage" tagprefix="pc" %>
<%@ Register src="../pharmacysharedscripts/SiteColourPanelControl.ascx" tagname="SiteColourPanelControl" tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SiteNamePanelControl.ascx"   tagname="SiteNamePanelControl"   tagprefix="uc" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%= SessionInfo.SessionID %>';
    var desktopURL = "../sharedscripts/CheckSessionExists.aspx";
    var pageName = "ICW_ContractEditor.aspx";
    //alert(sessionId);
    //alert(desktopURL + " " + pageName);
    windowModal_CheckSession(sessionId, desktopURL, "CheckSessionExists" + "|" + pageName);
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Contract Editor</title>
    
   <link href="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
   <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
   <style type="text/css">html, body{height:100%}</style>  <!-- Ensure page is full height of screen -->
           
   <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"              async></script>
   <script type="text/javascript" src="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.min.js" async></script>
   <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"            defer></script>
   <script type="text/javascript" src="script/ICW_ContractEditor.js"                          defer></script>
   <script type="text/javascript">
        var NSVCode = '';
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div style="height:100%">
        <!-- Dummy update panel used by __doPostBack so does not cause screen refresh -->
        <asp:UpdatePanel ID="upUpdatePanel" runat="server">
        <ContentTemplate />        
        </asp:UpdatePanel>

        <table cellpadding="0" cellspacing="0" style="margin-left:20px; width:97%; background-color:#DDDDDD;height:25px;">
            <tr>
                <td><uc:SiteNamePanelControl ID="siteNamePanel" runat="server" /></td>
                <td>&nbsp;</td>
                <td style="width:4%;"><uc:SiteColourPanelControl ID="siteColourPanel" runat="server" /></td>
            </tr>
        </table>

        <div>
            <iframe id="fraPharmacyProductSearch" application="yes" width="100%" height="575px" src="../PharmacyProductSearch/ICW_PharmacyProductSearch.aspx?SessionID=<%= SessionInfo.SessionID %>&WindowID=<%= windowID %>&AscribeSiteNumber=<%= SessionInfo.SiteNumber %>&EmbeddedMode=true&VB6Style=false"></iframe>
        </div>
        
        <div style="float: right; padding-right: 15px;">
            <button class="PharmButton" style="width:125px" id="btnItemEnquiry"            onclick="btnItemEnquiry_onclick();"                       >Item Enquiry</button>&nbsp;
            <button class="PharmButton" style="width:125px" id="btnEditContract"           onclick="btnEditContract_onclick();"         accesskey="E">Edit Contract</button>&nbsp;
            <button class="PharmButton" style="width:125px" id="btnDeleteSupplierProfile"  onclick="btnDeleteSupplierProfile_onclick()" accesskey="D">Delete Sup Profile</button>
        </div>    
                
        <!-- update progress message -->
        <pc:ProgressMessage id="progressMessage" runat="server" EnableTheming="False" EnableViewState="false" />
    </div>
    </form>
    <iframe id="CheckSessionExists" application="yes" style="display: none;"></iframe>
</body>
</html>
