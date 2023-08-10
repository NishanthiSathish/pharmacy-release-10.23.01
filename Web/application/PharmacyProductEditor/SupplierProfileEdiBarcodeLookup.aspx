<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SupplierProfileEdiBarcodeLookup.aspx.cs" Inherits="application_PharmacyProductEditor_SupplierProfileEdiBarcodeLookup" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>
<%@ Import     Namespace="ascribe.pharmacy.shared"                        %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "SupplierDetails.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Select Barcode</title>
    <base target=_self>

    <link href="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css"                        rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"           defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/QuesScrl/QuesScrl.js"          defer></script>
    <script type="text/javascript">
        SizeAndCentreWindow("290px", "300px");

        // Called when key down is pressed
        function body_onkeyup(event)
        {
            var retVal = true;

            switch (event.keyCode)
            {
            case 13:
                btnOK_click();
                event.cancelBubble = true;
                break;
            case 27:
                window.close();
                break;
            case 38:    // up key
            case 40:    // down key
            case 33:    // Page up
            case 34:    // Page down
            case 36:    // Home
            case 35:    // End
                gridcontrol_onkeydown_internal('gcGrid', event);    // If using navigation keys in search box forward them to grid 27Aug14 XN 88922
                break;
            default:
               filterList();
               break;
            }

            return retVal;
        }

        function btnOK_click()
        {
            var barcode = getSelectedRow('gcGrid').prop('Barcode');
            if (barcode == undefined)
                $('#errorMsg').text('Select item from the list');
            else if (barcode == 'Add')
            {
                // Show the add alternative barcode text box
                $('#tbAddBarcode').val('');
                $('#divAddBarcode').dialog(
                {
                    modal: true,
                    buttons:
    	            {
    	                'OK': function () { btnAdd_click(); },
    	                'Cancel': function () { $(this).dialog("destroy"); }
    	            },
                    title: 'Emis Health',
                    focus: function (type, data) { $('#tbAddBarcode').focus(); },
                    closeOnEscape: true,
                    draggable: false,
                    resizable: false,
                    appendTo: 'form',
                    width: '280px'
                });
            }
            else
            {
                window.returnValue = barcode;
                window.close();
            }
        }

        function btnAdd_click()
        {
            __doPostBack('upAddBarcode', 'SaveAlternateBarcode');
        }

        // Filters the gird to only show items that contain the specified text
        function filterList()
        {
            $('#errorMsg').html('&nbsp;');

            // Filter rows
            filterRows('gcGrid', [ 0 ], $('#tbSearch').val());

            // If no row selected then select the first visible one in the list
            var rowcount = getVisibleRowCount('gcGrid');
            var row      = getSelectedRow('gcGrid');
            if (!isRowVisisble(row) || row.length == 0)
            {
                if (rowcount > 0)
                    selectRow('gcGrid', getNextVisibleRow('gcGrid', 0, 1));
                else
                    selectRow('gcGrid', undefined);
            }
        }
    </script>
</head>
<body onkeyup="return body_onkeyup(event);">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div style="padding:8px;overflow:hidden;">
        Select barcode from the list.
        <br />

        <br />
        <!-- Search results grid -->
        <div id="divGrid" style="height:140px;" >
            <uc:GridControl ID="gcGrid" runat="server" JavaEventDblClick="btnOK_click" EnterAsDblClick="true" EnableAlternateRowShading="true" />
        </div>
    
        <div id="errorMsg" class="ErrorMessage" style="width:100%;text-align:center;"></div> 

        <!-- Spacer -->
        <hr id="hrButtons" runat="server" />
        
        <!-- Search panel (left) -->
        <div id="divSearchText" runat="server" style="margin-top:5px;">
            <asp:Label ID="Label1"  runat="server" Text="Filter List:" />&nbsp;
            <asp:TextBox ID="tbSearch" runat="server" Width="150px" />&nbsp;
        </div>

        <!-- OK\Cancel Buttons (right) -->
        <div id="divButtons" runat="server" style="margin-top:15px;text-align:center;">
            <input id="btnOK"     type="button" value="OK"     class="PharmButton" onclick="btnOK_click()"   />&nbsp;
            <input id="btnCancel" type="button" value="Cancel" class="PharmButton" onclick="window.close();" />
        </div>
    </div>
    
    <div id="divAddBarcode" style="display:none">
        <asp:UpdatePanel ID="upAddBarcode" runat="server">
        <ContentTemplate>
            <asp:Label runat="server" Text="Enter alternative barcode" /><br /><br />
           <span onkeypress="MaskInput(this.children[0], digitsMask, undefined, <%= Barcode.GTIN14BarcodeLength %>)" 
                 onpaste="MaskInput(this.children[0], digitsMask, undefined, <%= Barcode.GTIN14BarcodeLength %>)">
            Barcode: <asp:TextBox ID="tbAddBarcode" runat="server" Width="160px" /><br />
            </span>
            <div id="divAddError" runat="server" style="text-align:center;" class="ErrorMessage">&nbsp;</div>
        </ContentTemplate>
        </asp:UpdatePanel>        
    </div>
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
