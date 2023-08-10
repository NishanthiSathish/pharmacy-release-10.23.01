<%@ Page Language="C#" AutoEventWireup="true" CodeFile="BNFLookup.aspx.cs" Inherits="application_PharmacyProductEditor_BNFLookup" %>

<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>BNF Chapter and section</title>

    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
    <link href="../../Style/OCSGrid.css"     rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"    defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"      async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" async></script>
    <script type="text/javascript">
        SizeAndCentreWindow("600px", "710px");

        function btnOK_click()
        {
            var selectedRow = getSelectedRow('gcBNF');
            var bnfCode     = selectedRow.attr('Code');
            if (bnfCode != '')
            {
                window.returnValue = bnfCode;
                window.close();
            }
        }
    </script>
</head>
<body onkeydown="if (event.keyCode == 27) { window.close(); }">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div style="margin:10px;">
        <!-- Search results grid -->
        <div style="height:650px">
            <uc:GridControl ID="gcBNF" runat="server" JavaEventDblClick="btnOK_click();" EmptyGridMessage="No BNF chapter or section found" EnterAsDblClick="true" />
        </div>

        <!-- Spacer -->
        <hr />
        
        <span style="float:right; padding-right: 10px;">
            <input id="btnOK"     type="button" value="OK"     class="ICWButton" onclick="btnOK_click()"   />&nbsp;
            <input id="btnCancel" type="button" value="Cancel" class="ICWButton" onclick="window.close();" />
        </span>
    </div>
    </form>
</body>
</html>
