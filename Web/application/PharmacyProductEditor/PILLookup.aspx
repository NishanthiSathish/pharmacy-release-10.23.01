<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PILLookup.aspx.cs" Inherits="application_PharmacyProductEditor_PILLookup" %>
<%@ Import Namespace="ascribe.pharmacy.shared"              %>

<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Patient Information Leaflets</title>

    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
    <link href="../../Style/OCSGrid.css"     rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"        async></script>
    <script type="text/javascript" src="../sharedscripts/icwcombined.js"                 defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"    defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"      async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" async></script>
    <script type="text/javascript">
        SizeAndCentreWindow("600px", "680px");

        function btnOK_click()
        {
            var selectedRow = getSelectedRow('gcPIL');
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
        <p>
            Select File
        </p>

        <!-- Search results grid -->
        <div style="height:570px">
            <uc:GridControl ID="gcPIL" runat="server" JavaEventDblClick="btnOK_click();" EmptyGridMessage="No patient information leaflets found" EnterAsDblClick="true" />
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
