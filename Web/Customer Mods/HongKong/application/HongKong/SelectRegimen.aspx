<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SelectRegimen.aspx.cs" Inherits="application_HongKong_SelectRegimen" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Select Regimen</title>
    <base target=_self>

    <link href="../../style/PharmacyDefaults.css"    rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"    defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"      async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" async></script>

    <script type="text/javascript">
        SizeAndCentreWindow("540px", "500px");

        function body_onload()
        {
            setTimeout(function () { try { $('#gcGrid').focus() } catch (x) { } }, 250);
        }

        function btnOK_click()
        {
            var dbid = getSelectedRow('gcGrid').prop('RequestID');
            if (dbid == undefined)
            {
                $('#errorMsg').text('Select item from the list');   // 107895 27Jan15 XN
                return;
            }

            window.returnValue = dbid;
            window.close();
        }

        function btnView_click() 
        {
            var width = 1007;
            var height = 700;
            var left = (screen.width - width) / 2;
            var top = (screen.height - height)

            var dbid = getSelectedRow('gcGrid').prop('RequestID');
            if (dbid == undefined) 
            {
                $('#errorMsg').text('Select item from the list');   // 107895 27Jan15 XN
                return;
            }

            var url = '..\\PNViewAndAdjust\\ICW_PNViewAndAdjust.aspx' + getURLParameters() + '&mode=ViewReadOnly&RequestID=' + dbid;
            window.showModalDialog(url, '', 'dialogWidth:' + width + 'px; dialogHeight:' + height + 'px; status:off; left:' + left + 'px; top:' + top + 'px;');
        }

        function body_onkeydown(event)
        {
            switch (event.keyCode)
            {
            case 27: window.close();            break;
            case 13: event.cancelBubble = true; break;  // Need to cancel at this level else will cause post back (and hence not select and close)
            }
        }

        // Clear error message
        function clearError() {
            $('#errorMsg').html('&nbsp;');
        }
    </script> 
</head>
<body onload="body_onload();" onkeydown="if (event.keyCode == 27) { window.close(); } else if (event.keyCode == 13 ) { event.cancelBubble = true; return false; }">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div style="margin:10px;">
        <span>Select regimen for the new supply request</span>
        <br />

        <div id="divGrid" style="height:400px;" >
            <uc:GridControl ID="gcGrid" runat="server" JavaEventDblClick="btnOK_click" EnterAsDblClick="true" EnableAlternateRowShading="true" EmptyGridMessage="Patient does not have any regimens for the currrent episode" />
        </div>        
        <div id="errorMsg" class="ErrorMessage" style="width:100%;text-align:center;"></div> 

        <!-- Spacer -->
        <hr id="hrButtons" runat="server" />

        <!-- View button -->
        <div style="float:left; padding-left: 5px;margin-top:5px;vertical-align:middle;">
            <input id="btnView" type="button" value="View" class="PharmButton" onclick="btnView_click()" />
        </div>
    
        <!-- OK\Cancel Buttons (right) -->
        <div style="float:right; padding-right: 5px;margin-top:5px;vertical-align:middle;">
            <input id="btnOK"     type="button" value="OK"     class="PharmButton" onclick="btnOK_click()"   />&nbsp;
            <input id="btnCancel" type="button" value="Cancel" class="PharmButton" onclick="window.close();" />
        </div>
    </div>
    </form>
</body>
</html>
