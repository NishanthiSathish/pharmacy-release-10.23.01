<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PharmacyLookupList.aspx.cs" Inherits="application_pharmacysharedscripts_PharmacyLookupList" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script type="text/javascript" src="../sharedscripts/inactivityTimeOut.js" async></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         var isEmbeddedMode = '<%= embeddedMode.ToString().ToLower()%>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "PharmacyLookupList.aspx";
         if (isEmbeddedMode=='false')
             windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);         
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title><%= this.title%></title>
    <base target=_self>

    <link href="../../style/PharmacyDefaults.css"    rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"    defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"      async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" async></script>    
    
    <script type="text/javascript">
<% if (!this.embeddedMode) %>
<% { %>
        SizeAndCentreWindow("<%= this.width %>px", "<%= this.height %>px");
<% } %>

        var embeddedMode                = <%= this.embeddedMode.ToString().ToLower() %>;
        var searchType                  = '<%= this.searchType %>';
        var searchColumns               = <%= JsonConvert.SerializeObject(this.searchColumns) %>;
        var typeAndSelectSearchString   = '';           // 3Mar15 XN 99381 added 
        var typeAndSelectSearchTime     = new Date();   // 3Mar15 XN 99381 added 

        function body_onload()
        {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);
            EndRequestHandler();
        }

        // Called when key down is pressed 3Mar15 XN 99381
        function body_onkeydown(event)
        {
            var retVal = true;

            switch (event.keyCode)
            {
            case 13:
                event.cancelBubble = true;
                retVal = false;
                break;
            case 27:
                window.close();
                break;
            default:
                // If TypeAndSelect search mode then search that item on grid 3Mar15 XN 99381
                if (48 <= event.keyCode && event.keyCode <= 90 && !event.altKey && searchType == 'TypeAndSelect')
                    performGridSearch(String.fromCharCode(event.keyCode));
                break;
            }

            return retVal;
        }

        function btnOK_click()
        {
            var dbid = GetSelectedDBID();
            if (dbid == undefined)
            {
                $('#errorMsg').text('Select item from the list');   // 107895 27Jan15 XN
                return;
            }

            if (embeddedMode)
            { 
                if (window.parent.PharmacyLookupListDoubleClicked != undefined)  
                    window.parent.PharmacyLookupListDoubleClicked(dbid);
            
                event.returnValue  = false;   // Need else has odd effect in embedded mode 
                event.cancelBubble = true;  
            }
            else
            {        
                window.returnValue = dbid;
                window.close();
            }
        }

        function body_onkeydown(event)
        {
            switch (event.keyCode)
            {
            case 27: window.close();            break;
            case 13: event.cancelBubble = true; break;  // Need to cancel at this level else will cause post back (and hence not select and close)
            }
        }

        // Handles key presses on the search text box
        function tbSearch_onkeydown(event)
        {
            ///if (searchType != 'PostBack')    109218 27Jan15 XN    now handle PostBack, and Basic mode (moved items from tbSearch_onkeyup to tbSearch_onkeydown)
            //    return;

            switch (event.keyCode)  // Check which key was pressed
            {
            case 13:    // Enter
                if (searchType == 'PostBack')
                {
                    var btnSearch = $('#btnSearch');
                    if (btnSearch.is(':visible'))
                    {
                        btnSearch.click(); // Clicks search button          
                    }
                } 
                else
                {
                    btnOK_click();                      // 109218 27Jan15 XN Moved items from tbSearch_onkeyup to tbSearch_onkeydown
                }

                // XN 7Apr15 115480 Pressing enter key causes postback
                window.event.cancelBubble = true;
                window.event.returnValue = false;
                break;
            case 38:    // up key
            case 40:    // down key
            case 33:    // Page up
            case 34:    // Page down
            case 36:    // Home
            case 35:    // End
                gridcontrol_onkeydown_internal('gcGrid', event);    // If using navigation keys in search box forward them to grid 27Aug14 XN 88922
                break;
            }
        }

        // Handles key presses on the search text box (when in basic search mode) 
        // will filter list client side
        // 27Aug14 XN 88922
        function tbSearch_onkeyup(event)
        {
            if (searchType != 'Basic')
                return;

            switch (event.keyCode)  // Check which key was pressed
            {
            case 13:    // Enter
                //btnOK_click();        
                //window.event.cancelBubble = true; 
                //window.event.returnValue = false;     109218 27Jan15 XN moved to tbSearch_onkeydown
                break;
            case 38:    // up key
            case 40:    // down key
            case 33:    // Page up
            case 34:    // Page down
            case 36:    // Home
            case 35:    // End
                //gridcontrol_onkeydown_internal('gcGrid', event);   109218 27Jan15 XN moved to tbSearch_onkeydown // If using navigation keys in search box forward them to grid 
                break;
            default:
                filterList($('#tbSearch').val());
                break;
            }
        }

        // Handles key presses on the search text box (when in basic search mode) 27Aug14 XN 88922
        function tbSearch_onpaste(event)
        {
            if (searchType == 'Basic')
                filterList($('#tbSearch').val());
        }

        // Called when row is selected in the grid
        // Will post message to parent if embeddedMode
        function pharmacygridcontrol_onselectrow(controlID, rowindex)
        {
            // If embeded mode raise event that row selected
            if (embeddedMode && window.parent.PharmacyLookupListSelected != undefined)
            {
                var dbid = GetSelectedDBID();
                window.parent.PharmacyLookupListSelected(dbid);
            }
        }

        // Called when server request ends
        function EndRequestHandler()
        {
            //if (getRowCount('gcGrid') == 0)
            //if (searchType == 'PostBack' && getRowCount('gcGrid') == 0)  27Aug14 XN 88922
            if (searchType == 'PostBack' || searchType == 'Basic')
            {
                // If embeded mode raise ICW event that row selection cleared
                //if (embeddedMode && window.parent.PharmacyLookupListSelectionCleared != undefined)   27Aug14 XN 88922      
                if (embeddedMode && window.parent.PharmacyLookupListSelectionCleared != undefined && getRowCount('gcGrid') == 0)        
                    window.parent.PharmacyLookupListSelectionCleared();

                //setTimeout(function(){ $('#tbSearch')[0].select(); $('#tbSearch').focus(); },250); // Set focus using timer (else won't always get focus 86716 XN 19Mar14 scritp error ie8 if control not visisble
                setTimeout(function(){ try { $('#tbSearch')[0].select(); $('#tbSearch').focus(); } catch(ex) { } },250); // Set focus using timer (else won't always get focus)
            }
            else
                setTimeout(function(){ try { $('#gcGrid').focus() } catch(x) { } },250); // Set focus using timer (else won't always get focus 86716 XN 19Mar14 scritp error ie8 if control not visisble
                //setTimeout(function(){$('#gcGrid').focus()},250); // Set focus using timer (else won't always get focust
        
            // In embedded mode check the size of the grid
            if (embeddedMode)
            {
                $("#divGrid").height($(window).height() - 100 - (searchType == 'None' ? 0 : 30));   // 109218 update so better fix in embeded mode
                $('#divSearchText').width( $('#gcGrid').width() );
                $('#tbSearch').width($('#gcGrid').width() - 100 - $('#btnSearch').width()); 
            }
        }

        function GetSelectedDBID()
        {
            return getSelectedRow('gcGrid').prop('DBID');
        }

        // Filters the gird to only show items that contain the specified text   27Aug14 XN 88922
        function filterList(filter)
        {
            clearError();   // 107895 27Jan15 XN

            // Filter rows
            filterRows('gcGrid', searchColumns, filter);

            // If no row selected then select the first visible one in the list
            // var rowcount = getRowCount('gcGrid');     XN 107895 15Jan15 Only get list of visible rows
            var rowcount = getVisibleRowCount('gcGrid');
            var row      = getSelectedRow('gcGrid');
            if (!isRowVisisble(row) || row.length == 0)
            {
                if (rowcount > 0)
                    selectRow('gcGrid', getNextVisibleRow('gcGrid', 0, 1));
                else
                    selectRow('gcGrid', undefined); // XN 107895 15Jan15 remove selection if no row visible.
            }
        }

        // Moves the current highlighted to the line that starts with typeAndSelectSearchString 3Mar15 XN 99381
        // newChar is appended to typeAndSelectSearchString, which is cleared down if this method has not been called for 1sec
        function performGridSearch(newChar)
        {
            // If timed out in 1 secs then clear search string
            var currentTime = new Date();
            if ((currentTime - typeAndSelectSearchTime) > 1000)
                typeAndSelectSearchString = '';

            // append to current search string
            typeAndSelectSearchString += newChar;

            // Do search
            var currentSelectedIndex = getSelectedRowIndex('gcGrid');
            var newRowIndex = findIndexOfFirstRowStartWith('gcGrid', currentSelectedIndex, 0, typeAndSelectSearchString, true);
            if (newRowIndex > -1)
                selectRow('gcGrid', newRowIndex, true);

            // Update search time    
            typeAndSelectSearchTime = new Date();
        }

        // Clear error message
        // 107895 27Jan15 XN
        function clearError()
        {
            $('#errorMsg').html('&nbsp;');
        }
    </script>    
</head>
<body onload="body_onload();" onkeydown="return body_onkeydown(event);">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div style="margin:10px;<%= embeddedMode ? "margin-top:0px;margin-bottom:0px;" : string.Empty %>">
        <asp:Label ID="lbInfo" runat="server" />
        <br />

        <asp:UpdatePanel ID="updatePanel" runat="server">
        <ContentTemplate>
            <br />
            <!-- Search results grid -->
            <div id="divGrid" style="height:<%= this.height - 100 - (this.searchType == SearchType.None ? 0 : 30) %>px;" >
                <uc:GridControl ID="gcGrid" runat="server" JavaEventDblClick="btnOK_click" EnterAsDblClick="true" EnableAlternateRowShading="true" />
            </div>
        </ContentTemplate>            
        </asp:UpdatePanel>

        
        <div id="errorMsg" class="ErrorMessage" style="width:100%;text-align:center;"></div> 

        <!-- Spacer -->
        <hr id="hrButtons" runat="server" />
        
        <!-- Search panel (left) -->
        <div id="divSearchText" runat="server" style="float:left; width:60%; vertical-align:middle;margin-top:5px;">
            <asp:Label ID="Label1"  runat="server" Text="Filter List: " />&nbsp;
            <asp:TextBox ID="tbSearch" runat="server" Width="200px" />&nbsp;
            <asp:Button  ID="btnSearch"  runat="server" CssClass="PharmButton" Height="25px" Width="60px" Text="Search" onclick="btnSearch_Click" UseSubmitBehavior="false" />
        </div>

        <!-- OK\Cancel Buttons (right) -->
        <div id="divButtons" runat="server" style="float:right; padding-right: 10px;margin-top:5px;vertical-align:middle;">
            <input id="btnOK"     type="button" value="OK"     class="PharmButton" onclick="btnOK_click()"   />&nbsp;
            <input id="btnCancel" type="button" value="Cancel" class="PharmButton" onclick="window.close();" />
        </div>        
    </div>         
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
