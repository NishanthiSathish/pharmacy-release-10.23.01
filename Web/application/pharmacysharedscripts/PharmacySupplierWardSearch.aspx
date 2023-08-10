<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PharmacySupplierWardSearch.aspx.cs" Inherits="application_pharmacysharedscripts_PharmacySupplierWardSearch" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=SessionInfo.SessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "PharmacySupplierWardSearch.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title><%= this.caption %></title>

    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
    <link href="../../Style/OCSGrid.css"     rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.4.3.min.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"    async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"      async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" async></script>
     
    <script type="text/javascript">
        SizeAndCentreWindow("800px", "500px")
        
        var internalSelect = false;
        var forceSelection = <%= this.forceSelection.ToString().ToLower() %>;
        
        // Handles key down on the search text box
        function tbSearch_onkeydown(event)
        {
            switch (event.keyCode)
            {
            case 33:   // page up                
            case 34:   // page down              
            case 38:   // up arrow               
            case 40:   // down arrow
                gridcontrol_onkeydown_internal('gcSearchResults', event); 
                break;
            case 13: $('#btnOK').click(); break; // enter              
            }
        }         
        
        // Handles key up on the search text box
        function tbSearch_onkeyup(event)
        {
            switch (event.keyCode)
            {
            case 33: // page up               
            case 34: // page down               
            case 38: // up arrow               
            case 40: // down arrow
            case 13: // enter
                break;                
            default:
                updateGridSelection($('#tbSearch').val());
            }
        }      
        
        // Called when OK button is clicked
        // check row selected (if required)
        // Returns selected row details
        function btnOK_click()
        {
            var selectedRow = getSelectedRow('gcSearchResults');
            
            // If need to force selection 
            if (forceSelection && selectedRow.length == 0)
            {
                $('#lbInfo').show();            
                return;
            }

            // return selected row details
            if (selectedRow.length == 0)
                window.returnValue = undefined;
            else if (selectedRow.attr('WSupplierID') == undefined)  // User selected optional row (e.g. <All> or <New>)
                window.returnValue = '';
            else
                window.returnValue = selectedRow.attr('WSupplierID') + '|' + $('td:eq(0)', selectedRow).text() + '|' + $('td:eq(2)', selectedRow).text()
            window.close();                
        }
        
        // Called when user selects row in grid
        // Updates the tbSearch with rows SupCode
        function pharmacygridcontrol_onselectrow(controlID, rowindex)
        {
            if (!internalSelect && rowindex > -1)
            {
                var selectedSupCode = getSelectedRow('gcSearchResults').attr('SupCode');
                var tbSearch = $('#tbSearch');
                tbSearch.val(selectedSupCode);
                // tbSearch[0].select();
                try { tbSearch[0].select(); } catch(ex) {}    // sometime get script error here, but not too important that it selects the text 87544 XN 31Mar14
            }
                
            if (rowindex > -1)
                $('#lbInfo').hide();                
        }   
        
        // Called when user enters text in tbSearch
        // search list for supplier that starts with that supcode
        function updateGridSelection(supCode)
        {
            var selectIndex = -1;
            if (supCode.length > 0)
                selectIndex = findIndexOfFirstRowStartWith('gcSearchResults', 0, 0, supCode, false);

            internalSelect = true;
            selectRow('gcSearchResults', selectIndex == -1 ? undefined : selectIndex, true);
            internalSelect = false;
        }
    </script> 

</head>
<body onkeydown="if (event.keyCode == 27) { window.close(); }">    
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div style="margin:10px;">
        <asp:UpdatePanel ID="updatePanel" runat="server">
        <ContentTemplate>
            <!-- Search results grid -->
            <div style="height:375px">
                <uc:GridControl ID="gcSearchResults" runat="server" JavaEventDblClick="btnOK_click();" EmptyGridMessage="No suitable suppliers" />
            </div>
            
            <div style="width:100%;text-align:center;padding-top:5px;">
                <asp:Label ID="lbInfo" CssClass="BrokenRule_Text" runat="server" Text="Select item from list" style="display:none;" Width="100%" EnableViewState="False" />
            </div>

            <!-- Spacer -->
            <hr />
        
            <!-- Search panel -->
            <asp:Label   ID="lbSearchCaption" runat="server" Text="Enter code:" />&nbsp;
            <asp:TextBox ID="tbSearch"        runat="server" Width="75px"      />
            
            <!-- Sites panel -->
            <asp:Panel ID="sitesPanel" runat="server" Visible="false">
                <span>Select site:&nbsp;</span>
                <asp:DropDownList ID="ddlSites" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSites_OnSelectedIndexChanged"></asp:DropDownList>
            </asp:Panel>
                
            <span style="float:right; padding-right: 10px;">
                <input id="btnOK"     type="button" value="OK"     class="ICWButton" onclick="btnOK_click()"   />&nbsp;
                <input id="btnCancel" type="button" value="Cancel" class="ICWButton" onclick="window.close();" />
            </span>
        </ContentTemplate>            
        </asp:UpdatePanel>
    </div>        
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
