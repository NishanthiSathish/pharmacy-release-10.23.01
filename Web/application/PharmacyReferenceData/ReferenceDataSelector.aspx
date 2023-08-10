<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ReferenceDataSelector.aspx.cs" Inherits="application_PharmacyReferenceData_ReferenceDataSelector" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title><%= this.title%></title>
    <base target="_self" />

    <link href="../../style/PharmacyDefaults.css"    rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css" rel="stylesheet" type="text/css" />
    <style>
        .ValueCell
        {
            max-height: 250px;
            overflow-y: auto;
        }        
    </style>

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"    defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"      async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" async></script>

    <script type="text/javascript">
        SizeAndCentreWindow("500px", "700px");

        var searchString   = '';
        var lastSearchTime = new Date();    // Time out for search pattern

        function body_onload()
        {
            setTimeout(function(){ try { $('#gcGrid').focus() } catch(x) { } },250); // Set focus using timer (else won't always get focus 86716 XN 19Mar14 scritp error ie8 if control not visisble
        }

        function body_onkeypress()
        {
            switch (event.keyCode)
            {
            case 27: // Escape
                window.close(); 
                break;
            default:
                DoSearch();
                break;
            }
        }

        function btnOK_click()
        {
            var dbid = getSelectedRow('gcGrid').prop('DBID');
            if (dbid == undefined)
                return;

            window.returnValue = dbid;
            window.close();
        }

        
        // Handles key up on the search text box
        function DoSearch()
        {
            // If timed out in 1 secs then clear search string
            var currentTime = new Date();
            if ((currentTime - lastSearchTime) > 1000)
                searchString = '';

            // append to current search string
            searchString += String.fromCharCode(event.keyCode).toLowerCase();

            // Do search
            var currentSelectedIndex = getSelectedRowIndex('gcGrid');
            var rowIndex = findIndexOfFirstRowStartWith('gcGrid', currentSelectedIndex, 0, searchString, true);
            if (rowIndex >= 0)
                selectRow('gcGrid', rowIndex, true);

            // Update search time                    
            lastSearchTime = new Date();
        }   
    </script> 
</head>
<body onload="body_onload();" onkeypress="body_onkeypress();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div style="margin:10px;">
        <asp:Label ID="lbInfo" runat="server" />
        <br />
        <br />

        <!-- Search results grid -->
        <div id="divGrid" style="height:590px;" >
            <uc:GridControl ID="gcGrid" runat="server" JavaEventDblClick="btnOK_click" EnterAsDblClick="true" EmptyGridMessage="No items available" SortableColumns="true" EnableAlternateRowShading="true" />
        </div>

        <!-- Spacer -->
        <hr id="hrButtons" runat="server" />
        
        <div id="divButtons" runat="server" style="float:right; padding-right: 5px; padding-top: 10px">
            <input id="btnOK"     type="button" value="OK"     class="PharmButton" onclick="btnOK_click()"   />&nbsp;
            <input id="btnCancel" type="button" value="Cancel" class="PharmButton" onclick="window.close();" />
        </div>
    </div>
    </form>
</body>
</html>
