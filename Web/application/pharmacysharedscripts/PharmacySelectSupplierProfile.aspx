<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PharmacySelectSupplierProfile.aspx.cs" Inherits="application_pharmacysharedscripts_PharmacySelectSupplierProfile" %>
<%@ OutputCache Location="None" VaryByParam="None" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=SessionInfo.SessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "PharmacySelectSupplierProfile.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Select Option</title>
    <base target=_self>
    
    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
    <link href="../../Style/OCSGrid.css"     rel="stylesheet" type="text/css" />
    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->   
    
    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.4.3.min.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"      async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" async></script>

    <script type="text/javascript">
        SizeAndCentreWindow("600px", "300px")
        
        // Called when key is pressed on form
        function form_onkeydown(event)
        {
            switch (event.keyCode)
            {
            case 13:    // Enter
                if (!$(document.activeElement).is('button') && !$(document.activeElement).is('input[type="button"]'))
                    $('#btnOK').click();
                break;
            case 27:    // Esc
                $('#btnCancel').click();            
                break;
            }            
        }

        // Called when ok button is clicked
        // If item selected then sets reutnr value, and closes form
        function btnOK_click()
        {
            var row      = getSelectedRow     ('gcSearchResults');
            var rowIndex = getSelectedRowIndex('gcSearchResults');
            
            if (rowIndex > -1)
            {
                if (row.attr('SupCode') == undefined)
                    window.returnValue = '';
                else
                    window.returnValue = row.attr('WSupplierProfileID') + '|' + row.attr('SupCode') + '|' + getCell('gcSearchResults', rowIndex, 1).text();            
                window.close();
             }
        }
    </script>
   

</head>
<body onload="$('#gcSearchResults').focus();" onkeydown="form_onkeydown(event);">
    <form id="form1" runat="server">
    <div style="margin:10px;">
        Select Supplier Profile<br />
        <br />

        <div style="height:225px">
            <uc:GridControl ID="gcSearchResults" runat="server" JavaEventDblClick="btnOK_click();" EmptyGridMessage="No suitable suppliers for this product" EnableAlternateRowShading="true" />
        </div>        
            
        <span style="float:right; padding-right: 10px;">
            <input id="btnOK"     type="button" value="OK"     class="ICWButton" onclick="btnOK_click()"   />&nbsp;
            <input id="btnCancel" type="button" value="Cancel" class="ICWButton" onclick="window.close();" />
        </span>        
    </div>        
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
