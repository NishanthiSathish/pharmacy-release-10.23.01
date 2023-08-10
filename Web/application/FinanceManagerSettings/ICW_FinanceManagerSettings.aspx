<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_FinanceManagerSettings.aspx.cs" Inherits="application_FinanceManagerSettings_ICW_FinanceManagerSettings" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<% 
%>
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%= SessionInfo.SessionID %>';
    var desktopURL = "../sharedscripts/CheckSessionExists.aspx";
    var pageName = "ICW_RepeatDispensingBatchTemplate.aspx";
    //alert(sessionId);
    //alert(desktopURL + " " + pageName);
    windowModal_CheckSession(sessionId, desktopURL, "CheckSessionExists" + "|" + pageName);
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Finance Manager Settings</title>
    
    <link href="../../style/application.css"      rel="stylesheet" type="text/css" />
    <link href="style/FinanceManagerSettings.css" rel="stylesheet" type="text/css" />
        
    <script type="text/javascript" src="../SharedScripts/jquery-1.3.2.js"></script>
    <script type="text/javascript" src="scripts/FinanceManagerSettings.js"></script>
    
    <script type="text/javascript">
        var sessionID = <%= SessionInfo.SessionID  %>;
    </script>    
    
    <style type="text/css">html, body{height:100%}</style>  <!-- Ensure page is full height of screen -->   
</head>
<body>
    <form id="form1" runat="server" class="FinanceManagerSettings">
    <div>
        <table height="100%" cellpadding="0" cellspacing="0">
            <tr height="100%">
                <td style="vertical-align: top;">
                    <div id="menu" class="menu" style="height:100%; width: 250px;">
                        <div class="menuHeader">Account Codes</div>
                        <input type="button" value="Transaction Type Editor"  class="menuItem" onclick="menuItem_onclick(this, 'EditList.aspx', 'TransactionTypes', 'Transaction Type Editor');" /><br />
                        <input type="button" value="Account Code Editor"      class="menuItem" onclick="menuItem_onclick(this, 'EditList.aspx', 'AccountCodes',     'Account Code Editor'    );" /><br />
                        <div class="menuHeader">Accounting Rules</div>
                        <input type="button" value="Accounting Rule Editor" class="menuItem" onclick="menuItem_onclick(this, 'EditList.aspx', 'Rules', 'Accounting Rule Editor');" /><br />
                        <div class="menuHeader">Sheets</div>
                        <input type="button" value="Stock Balance Sheet" class="menuItem" onclick="menuItem_onclick(this, 'FMStockAccountSheetLayoutEditor.aspx', 'StockAccountSheet', 'Stock Balance Sheet');" /><br />
                        <input type="button" value="GRNI"                class="menuItem" onclick="menuItem_onclick(this, 'FMGrniEditor.aspx',                    'GrniSheet',         'GRNI Sheet');"          /><br />
                    </div>
                </td>
                <td width="100%" id="tdSetting" style="display:none; padding-left:10px;">
                    <div id="panelTitle" class="menuHeader" style="width:100%;"></div>        
                    <hr class="menuHeader" style="width:95%;" />
        
                    <iframe width="100%" height="90%" id="fraSelectedItem" src="" frameborder="0" application="yes" />
                </td>
            </tr>
        </table>    
    </div>
    </form>
    <iframe id="CheckSessionExists" application="yes" style="display: none;"></iframe>
</body>
</html>
