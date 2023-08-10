<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_UMMCBilling.aspx.cs" Inherits="application_bespoke_UMMC_Billing_ICW_UMMCBilling" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>UMMC Billing Interface</title>
    
    <script type="text/javascript" src="scripts/ICW_UMMCBilling.js"></script>    
    <script type="text/javascript" src="../../application/sharedscripts/icw.js"></script>        
    <script type="text/javascript" src="../../application/SharedScripts/jquery-1.3.2.js"></script>
    
    <link href="../../style/application.css"        rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server" style="text-align:right; vertical-align: middle;">
    <br />
    <div style="width:95%;">
        <button id="billing" type="button" class="ICWButton" accesskey="B" onclick="billing_click()" disabled="disabled" style="vertical-align: middle; width: 100px; height: 30px; margin-right: 25px;"><u>B</u>illing...</button>&nbsp;
    </div>
    </form>
</body>
</html>
