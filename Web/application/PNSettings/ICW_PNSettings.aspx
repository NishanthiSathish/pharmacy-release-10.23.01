<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_PNSettings.aspx.cs" Inherits="application_PN_Settings_ICW_PNSettings" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<% 
    //ICW.ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", "") 
%>

<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%= SessionInfo.SessionID %>';
    var desktopURL = "../sharedscripts/CheckSessionExists.aspx";
    var pageName = "ICW_PNSettings.aspx";
    //alert(sessionId);
    //alert(desktopURL + " " + pageName);
    windowModal_CheckSession(sessionId, desktopURL, "CheckSessionExists" + "|" + pageName);
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">    
    <title>PN Settings</title>
    
    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PN.css"          rel="stylesheet" type="text/css" />
        
    <script type="text/javascript" src="../SharedScripts/jquery-1.3.2.js"></script>
    <script type="text/javascript" src="../PNSettings/scripts/PNSettings.js"></script>
    
    <style type="text/css">html, body{height:100%}</style>  <!-- Ensure page is full height of screen -->    
</head>
<body SessionID="<%= SessionInfo.SessionID %>"
      SiteID="<%= SessionInfo.SiteID %>"
      >
    <form id="form1" runat="server" class="PNSettings">
    <div>
        <table height="100%" cellpadding="0" cellspacing="0">
            <tr height="100%">
                <td style="vertical-align: top;">
                    <div id="menu" class="menu" style="height:100%; width: 220px;">
                        <div class="menuHeader">Products</div>
                        <input type="button" value="All Products"          class="menuItem" onclick="menuItem_onclick(this, 'EditList', 'AllProducts', 'All Products');" /><br />
                        <input type="button" value="Ingredient by Product" class="menuItem" onclick="menuItem_onclick(this, 'EditList', 'IngredientByProduct', 'Ingredient By Product');" /><br />
                        <div class="menuHeader">Regimens</div>
                        <input type="button" value="Standard - Paediatric" class="menuItem" onclick="menuItem_onclick(this, 'EditList', 'StandardPaediatricRegimen', 'Standard Paediatric Regimen');" /><br />
                        <input type="button" value="Standard - Adult"      class="menuItem" onclick="menuItem_onclick(this, 'EditList', 'StandardAdultRegimen', 'Standard Adult Regimen');" /><br />
                        <input type="button" value="Prescription Proforma" class="menuItem" onclick="menuItem_onclick(this, 'EditList', 'PrescriptionProforma', 'Prescription Proforma');" /><br />
                        <input type="button" value="Validation"            class="menuItem" onclick="menuItem_onclick(this, 'EditList', 'RegimenValidation', 'Regimen Validation');" /><br />
                        <div class="menuHeader">Defaults</div>
                        <input type="button" value="Defaults - Paediatric" class="menuItem" onclick="menuItem_onclick(this, 'Settings', 'Paediatric', 'Paediatric Defaults');" /><br />
                        <input type="button" value="Defaults - Adult"      class="menuItem" onclick="menuItem_onclick(this, 'Settings', 'Adult',      'Adult Defaults' );" /><br />
                    </div>
                </td>
                <td width="100%" id="tdSetting" style="display:none; padding-left:10px;">
                    <div id="panelTitle" class="menuHeader" style="width:100%;"></div>        
                    <hr class="menuHeader" style="width:95%;" />
        
                    <iframe width="100%" height="90%" id="fraSelectedItem" src="" frameborder="0" />
                </td>
            </tr>
        </table>
    </div>
    </form>
    <iframe id="CheckSessionExists" application="yes" style="display: none;"></iframe>
</body>
</html>
