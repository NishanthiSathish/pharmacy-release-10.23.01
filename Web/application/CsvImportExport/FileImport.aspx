<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FileImport.aspx.cs" Inherits="application_CsvImportExport_FileImport" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "FileImport.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>File Import</title>
    <base target=_self>

    <link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/application.css"                                rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.11.3.min.js"              async></script>
    <script type="text/javascript" src="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  async></script>
	<script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
    <script type="text/javascript">
        SizeAndCentreWindow('500px', '225px');
    </script>
    
</head>
<body scroll="none">
    <form id="form1" runat="server">
    <asp:ScriptManager runat="server"></asp:ScriptManager>
    <div style="padding:5px;">
        <div style="margin-top:3px;margin-bottom:3px;">Select a comma-separated values file <asp:Label ID="lbFileType" runat="server" /> to import<br /></div>
        <asp:FileUpload ID="fuFileUpload"   runat="server" Width="460px" />
        <asp:CheckBox   ID="cbIfHasHeaders" runat="server" Text="My data has header row" /><br />

        <div id="errorMessage" class="ErrorMessage" runat="server">&nbsp</div>

        <div style="position:absolute;bottom:15px;width:95%;text-align:center;z-index:99"> 
            <asp:Button ID="btnImport" runat="server" CssClass="PharmButton" Text="Import" AccessKey="I" Width="75px" OnClick="btnImport_OnClick" />&nbsp;&nbsp;
            <asp:Button ID="btnCancel" runat="server" CssClass="PharmButton" Text="Cancel" AccessKey="C" Width="75px" OnClientClick="window.returnValue=null;window.close();return false;" />
        </div>
    </div>        
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
