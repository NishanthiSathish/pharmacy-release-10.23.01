/*
aMM workflow script
*/

//var lastSelectedRowIndex;
var visible;    // Keeps track of if the current page is visible when used in multi tab desktop

function pageLoad()
{
    viewSettings = JSON.parse($('#hfViewSettings').val());
    UpdateToolbarButtons();
    body_onresize();
    $('#grid').focus();

    // If page is doing the episode selection then set timer (bit bad but only way as no event for tab selection)
    // So if page becomes visible again update selected patient 22Aug16 XN 160920
    if (viewSettings.SelectEpisode)
    {
        setInterval(function ()
        {
            if (visible != $('#grid').is(':visible'))
            {
                visible = $('#grid').is(':visible');
                if (visible)
                {
                    var args = 'refresh';
                    var row = getSelectedRow('grid');
                    if (row.attr('RequestID') != undefined)
                        args += ':' + row.attr('RequestID');
                    __doPostBack('upWorklist', args);
                }
            }
        }, 550);
    }
}

function body_onresize()
{        
    // size grid correctly
    var grid = $('#grid');
    if (grid.length > 0)
    {
        var height = $(window).height() - grid.offset().top;
        if (height < 0)
            height = 0;
        grid.height(height);
    }
}

function grid_OnClientGetChildRows(controlID, rowIndex)
{
    var row        = getRow('grid', rowIndex);
    var requestId  = row.attr('RequestID');

    var parameters = {
                        sessionID:        sessionID,
                        siteID:           siteID,
                        requestID_Parent: parseInt(requestId),
                        viewSettings:       viewSettings
                        };
    var res = PostServerMessage("ICW_aMMWorkflow.aspx/GetChildRows", JSON.stringify(parameters));
    return (res == undefined) ? undefined : res.d;
}

// Called when row select
// Updates toolbar buttons
// Send out any ICW episode, or request events
function grid_OnRowSelected(force)
{
    var row = getSelectedRow('grid');

//    if (viewSettings.ShiftSectionHeader && row.is('[headerRow]')) 
//    {
//        if (lastSelectedRowIndex < row[0].rowIndex)
//            selectRow('grid', row[0].rowIndex + 1, false);
//        else if (row[0].rowIndex == 0)
//            selectRow('grid', 1, false);
//        else
//            selectRow('grid', row[0].rowIndex - 1, false);
//        return;
//    }
//    lastSelectedRowIndex = row.rowIndex;

    // Update toolbar buttons
    UpdateToolbarButtons();
    // Send out episode selected event
    if (viewSettings.SelectEpisode && $('#grid').is(':visible'))
    {
        if (row.length == 0)
            RAISE_EpisodeCleared();
        else
        {
            var entityID  = row.attr('EntityID' );       	     	
            var episodeID = row.attr('EpisodeID');
            if (entityID != undefined && episodeID != undefined && (viewSettings.SelectedEpisodeID != episodeID || force))
            {
                // Set the episode Id 
                viewSettings.SelectedEpisodeID = episodeID;
                SaveviewSettings();

                // Save episode to state table
                SaveEpisodeToState(sessionID, entityID, episodeID);

                // Send out event
                var jsonEntityEpisodeVid = ICW.clinical.episode.eventSelectedRaised(episodeID, 0, sessionID);
                RAISE_EpisodeSelected(jsonEntityEpisodeVid);
            }
        }
    }
}

// If user clicks attached note icon ensure row is select before calling DoAction(OCS_ANNOTATE)
// 66474 19Jun13 XN 
function attachedNoteIcon_onclick(ctrl) 
{
    var row      = $(ctrl).closest('tr');
    var rowIndex = row.closest('tbody').find('tr').index(row);
    selectRow('grid', rowIndex);
    HapToolbarClick(HapToolbar('mainToolbar'), 'aMMWorkflow_AttachedNotes');
}

// Update toolbar buttons state
function UpdateToolbarButtons()
{
    if (viewSettings == undefined)
    {
        return;    
    }

    var toolbar         = HapToolbar("mainToolbar");
    var readOnly        = viewSettings.ReadOnly;
    var row             = getSelectedRow('grid');
    var rowSelected     = row.length != 0 && !row.is('[headerRow]');
    var isSupplyeRequest= rowSelected && (row.attr('RequestTypeID') == viewSettings.RequestTypeID_SupplyRequest);

    // Update button state
    HapToolbarEnable(toolbar, "aMMWorkflow_View",                  rowSelected);
    HapToolbarEnable(toolbar, "aMMWorkflow_Copy",                  rowSelected && !readOnly);
    HapToolbarEnable(toolbar, "aMMWorkflow_CancelItem",            rowSelected && !readOnly && row.attr('Complete') == '0' && row.attr('Request_Cancellation') == '0');
    HapToolbarEnable(toolbar, "aMMWorkflow_Amend",                 rowSelected && !readOnly && !isSupplyeRequest);  
    HapToolbarEnable(toolbar, "aMMWorkflow_AttachedNotes",         rowSelected /*&& !readOnly*/);   // can't view only attached notes so need to just allow them to edit in read only
    HapToolbarEnable(toolbar, "aMMWorkflow_SupplyRequest",         rowSelected && !readOnly);
    HapToolbarEnable(toolbar, "aMMWorkflow_Priority",              rowSelected && !readOnly && isSupplyeRequest);
    HapToolbarEnable(toolbar, "aMMWorkflow_AMMManufactureComplete",rowSelected && !readOnly && !isSupplyeRequest);  
    HapToolbarEnable(toolbar, "aMMWorkflow_AMMForManufacture",     rowSelected && !readOnly && !isSupplyeRequest);  
    HapToolbarEnable(toolbar, "aMMWorkflow_PrintWorklist",         rowSelected && isSupplyeRequest);  
    HapToolbarEnable(toolbar, "aMMWorkflow_PrintLabel",            rowSelected && isSupplyeRequest);  

    // Set the check box on the Priority, AMMManufactureComplete, and AMMForManufacture buttons
    HapToolbarSetImage(toolbar, "aMMWorkflow_Priority",               isSupplyeRequest && row.attr('Priority')=='True' ? "../../images/ocs/checkbox-checked.gif" : "../../images/ocs/checkbox.gif");
    HapToolbarSetImage(toolbar, "aMMWorkflow_AMMManufactureComplete", !isSupplyeRequest && row.attr('AMMManufactureComplete')=='1' ? "../../images/ocs/checkbox-checked.gif" : "../../images/ocs/checkbox.gif");
    HapToolbarSetImage(toolbar, "aMMWorkflow_AMMForManufacture",      !isSupplyeRequest && row.attr('AMMForManufacture')=='1' ? "../../images/ocs/checkbox-checked.gif" : "../../images/ocs/checkbox.gif");
}

// Updates row in the grid (will also handle adding and removing)
// Calls server side method GetRow ro get the details about the row
// requestId                - id of the row to update
// level                    - level of the row to update
// lastRowRefresh           - if this is going to be the last row to refresh
// requestId_RowToReplace   - id of the row to be replaced
// requestId_Parent         - id of parent row
function updateRow(requestId, level, lastRowRefresh, requestId_RowToReplace, requestId_Parent)
{
    // Get the HTML row
    var parameters =
    {
        sessionID  : sessionID,
        siteID     : siteID,
        requestID  : requestId,
        level      : level,
        viewSettings : viewSettings
    };
    var result = PostServerMessage("ICW_aMMWorkflow.aspx/GetRow", JSON.stringify(parameters));    
    
    if (result != undefined)
    {
        // Get the existing rows index (or row to replace index)
        var rowIndex = getRowIndexByAttribute('grid', 'RequestID', requestId_RowToReplace == undefined ? requestId : requestId_RowToReplace);
        if (rowIndex == -1)
        {
            // Row does not currently exist so add
            if (requestId_Parent == undefined)
                addRow('grid', result.d);
            else
                getRowByAttribute('grid', 'RequestID', requestId_Parent).after(result.d);
            rowIndex = getRowIndexByAttribute('grid', 'RequestID', requestId);
        }
        else if (result.d == '')
        {
            // No data return so remove row
            var row = getRow('grid', rowIndex);

            // Remove all child rows
            var requestId_Parent = row.attr('RequestID_Parent');
            getRowByAttribute('grid', 'RequestID_Parent', requestId).remove();
            row.remove();

            // If no more children then hide the child row icon
            if (getRowIndexByAttribute('grid', 'RequestID_Parent', requestId_Parent).length == 0)
                setShowChildRows('grid', rowIndex, undefined, false);

            // If rows index is not present then select last row
            if (getRowCount('grid') <= rowIndex)
                rowIndex = getRowCount('grid') - 1;
        }
        else
        {
            // Replace row
            var expanded = isShowChildRows('grid', rowIndex);
            replaceRow('grid', rowIndex, result.d);
            setShowChildRows('grid', rowIndex, expanded, false);
        }

        // Reselect
        if (lastRowRefresh == true)
        {
            refreshRowStripes('grid');
            refreshSectionHeaderStyle();
            selectRow('grid', rowIndex, true);
        }
    }
}

// Saves the WardStockListviewSettings to hfViewSettings as JSON string
function SaveviewSettings()
{
    $('#hfViewSettings').val(JSON.stringify(viewSettings));
}

// will search through the grid for the production tray barcode
// if present will select the line and display the form
function findSupplyRequestByProductionTrayBarcode(barcode)
{
    var rowIndex = getRowIndexByAttribute('grid', 'Barcode', barcode);
    if (rowIndex != -1)
    {
        selectRow('grid', rowIndex);
        aMMWorkflow_View();
    }
    return rowIndex != -1;
}

// Called when view toolbar buttons is clicked
// Display prescription or supply request
function aMMWorkflow_View() {
    var row = getSelectedRow('grid');
    var requestId = parseInt(row.attr('RequestID'));
    var requestTypeId = row.attr('RequestTypeID');
    var level = parseInt(row.attr('level'));
    var updateType = 'none';

    // Display form
    if (requestTypeId == viewSettings.RequestTypeID_SupplyRequest) {
        // If the grid is divided by section header for each shift then need to workout if the user changes the 
        // shift so we can update the whole grid
        var manufactureDate = viewSettings.ShiftSectionHeader ? row.attr('ManufactureDate') : undefined;

        var parameters = getURLParameters();
        parameters += '&RequestID=' + requestId;
        parameters += '&mode=' + (viewSettings.ReadOnly ? 'view' : 'edit');

        var winparams = 'width=' + screen.width - 100;
        winparams += ', height=' + screen.height - 100;
        winparams += ', top=0, left=0'
        winparams += ', fullscreen=yes';
        winparams += ', directories=no';
        winparams += ', location=no';
        winparams += ', menubar=no';
        winparams += ', resizable=no';
        winparams += ', scrollbars=no';
        winparams += ', status=no';
        winparams += ', toolbar=no';

        var result = window.open('../aMMWorkflow/AmmSupplyRequest.aspx' + parameters, "", winparams);

        var timer = setInterval(function () {
            if (result.closed) {
                clearInterval(timer);
                if (result != undefined) {
                    if (viewSettings.ShiftSectionHeader) {
                        parameters = {
                            sessionID: sessionID,
                            requestID: requestId
                        };
                        result = PostServerMessage("ICW_aMMWorkflow.aspx/GetAmmSupplyRequestManufactureDate", JSON.stringify(parameters));
                        if (result != undefined && result.d != manufactureDate) {
                            updateType = 'all';
                        }
                        else {
                            updateType = 'singlerow';
                        }
                    }
                    else {
                        updateType = 'singlerow';
                    }
                    switch (updateType) {
                        case 'singlerow': updateRow(requestId, level, true); break;
                        case 'all': __doPostBack('upWorklist', 'refresh:' + requestId); break;
                    }
                    $('#grid').focus();
                }
            }
        }, 1000);
        // Determine if need to up the whole grid or just single row'
    }
    else {
        var result = GetOCSActionDataForRequest(sessionID, requestId);
        if (result != undefined) {
            updateType = 'singlerow';
            OCSAction(sessionID, OCS_VIEW, result.xmlItem, result.xmlType, undefined, xmlStatusNoteFilter, null, null);
        }
    }
    // Update grid 
    switch (updateType) {
        case 'singlerow': updateRow(requestId, level, true); break;
        case 'all': __doPostBack('upWorklist', 'refresh:' + requestId); break;
    }

    $('#grid').focus();
}
// Called when view toolbar buttons is clicked
// Display prescription or supply request
function aMMWorkflow_Copy()
{
    var row           = getSelectedRow('grid');
    var requestId     = parseInt(row.attr('RequestID'));
    var requestTypeId = row.attr('RequestTypeID');
    var level         = parseInt(row.attr('level'));

    if (requestTypeId == viewSettings.RequestTypeID_SupplyRequest)
    {
        requestId = CreateCopyAMMSupplyRequest(sessionID, siteID, requestId, viewSettings.SupplyRequestButtons);
        if (requestId != undefined)
            updateRow(requestId, level, true);
    }
    else
    {
        var result = GetOCSActionDataForRequest(sessionID, requestId);
        if (result != undefined)
    	    OCSAction(sessionID, OCS_REQUEST_REORDER, result.xmlItem, result.xmlType, undefined, xmlStatusNoteFilter, null, null);
        
        // For copy OCSAction does not return anything useful so can just do full update
        __doPostBack('upWorklist', 'refresh');
    }
}

// Called when item is canceled
// Calls order comms cancel method
function aMMWorkflow_CancelItem()
{
    var row             = getSelectedRow('grid');
    var requestId       = parseInt(row.attr('RequestID'));
    var requestTypeId   = row.attr('RequestTypeID');
    var level           = parseInt(row.attr('level'));
    var requestIdParent = row.attr('RequestID_Parent');

    if (requestTypeId == viewSettings.RequestTypeID_SupplyRequest)
    {
        var parameters = 
                {
                    sessionId:                 sessionID,
                    requestIdAmmSupplyRequest: requestId
                };
        var result = PostServerMessage('AmmSupplyRequest.aspx/HasIssued', JSON.stringify(parameters));
        if (result != undefined && result.d)
        {
            if (!confirm('Stock has been issued.\nIf you continue, then manually return stock to the correct level.\nOK to continue.'))
                return;
        }
    }

    // Cancel the request
    var result = GetOCSActionDataForRequest(sessionID, requestId);
    if (result != undefined)
    	OCSAction(sessionID, OCS_CANCEL, result.xmlItem, result.xmlType, undefined, xmlStatusNoteFilter, null, null);

    // Update row
    if (level > 0)
        updateRow(requestIdParent, level - 1, false);  // Update parent row if present
    updateRow(requestId, level, true);
    if (requestTypeId == viewSettings.RequestTypeID_SupplyRequest && getRowByAttribute('grid', 'RequestID_Parent', requestIdParent).length == 0)
        setShowChildRows('grid', getRowIndexByAttribute('grid', 'RequestID', requestIdParent), undefined, false);
    $('#grid').focus();
}

// Called when amend button is clicked
// Only valid for prescriptions
// Calls order comms amend method
function aMMWorkflow_Amend()
{
    var row         = getSelectedRow('grid');
    var requestId   = parseInt(row.attr('RequestID'));
    var level       = parseInt(row.attr('level'));
    var xmlItem, xmlType;

    // Perform the amend operation
    var result = GetOCSActionDataForRequest(sessionID, requestId);
    if (result != undefined)
    {
    	result = OCSAction(sessionID, OCS_CANCEL_AND_REORDER, result.xmlItem, result.xmlType, undefined, xmlStatusNoteFilter, null, null);
        if (result != undefined && result.toString().indexOf('<saveok ') >= 0)    /* needed result.toString() as OSCAction can return false */
            var newRequestId = parseInt($('saveok', $.parseXML(result)).attr('id'));
    }

    // Update the row
    if (requestId != undefined && newRequestId != undefined)
        updateRow(newRequestId, level, true, requestId);
    $('#grid').focus();
}

// Called when attached notes button is clicked
// Display the Order Comms attached notes form
function aMMWorkflow_AttachedNotes()
{
    var row       = getSelectedRow('grid');
    var requestId = parseInt(row.attr('RequestID'));
    var level     = parseInt(row.attr('level'));

    // Display attacjed notes form
    var result = GetOCSActionDataForRequest(sessionID, requestId);
    if (result != undefined)
        OCSAction(sessionID, OCS_ANNOTATE, result.xmlItem, result.xmlType, undefined, xmlStatusNoteFilter, null, null);

    // Update the row
    if (requestId != undefined)
        updateRow(requestId, level, true);
    $('#grid').focus();
}

// Called when supply request button is clicked
// Create new amm supply request
function aMMWorkflow_SupplyRequest()
{
    var row           = getSelectedRow('grid');
    var requestTypeId = row.attr('RequestTypeID');
    var level         = parseInt(row.attr('level'));
    var requestId;

    // Get prescription ID
    if (requestTypeId == viewSettings.RequestTypeID_SupplyRequest && row.has('[RequestID_Parent]').length != 0)
        requestId = row.attr('RequestID_Parent');
    else if (requestTypeId == viewSettings.RequestTypeID_SupplyRequest && row.has('[RequestID_Parent]').length == 0)
    {
        // Selected a supply request but there is no parent prescription (as supply request is top level) so end
        alert('Need to select a prescription');
        return;
    }
    else
    {
        requestId = row.attr('RequestID');
        level++;
    }

    // Display form
    var url = '../aMMWorkflow/NewAmmSupplyRequestWizard.aspx?SessionID=' + sessionID + '&SiteID=' + siteID + '&RequestID_Parent=' + requestId;
    var newRequestID = window.showModalDialog(url, '', 'status:off; center:Yes;');
    if (newRequestID == 'logoutFromActivityTimeout') {
        newRequestID = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (newRequestID != undefined)
    {
        var rowIndex = getRowIndexByAttribute('grid', 'RequestID', requestId);
        if (isShowChildRows('grid', rowIndex))
            updateRow(newRequestID, level, true, undefined, requestId);   // Row expanded so just update or add
        else
            setShowChildRows('grid', rowIndex, true, true); // Row not expanded so just add

        // Select new row
        rowIndex = getRowIndexByAttribute('grid', 'RequestID', newRequestID);
        selectRow('grid', rowIndex);
    }
    $('#grid').focus();
}

// Called when aMM Priority button is clicked
// Only works for supply requests
// Toggles row's priority status
function aMMWorkflow_Priority() 
{
    var row             = getSelectedRow('grid');
    var requestId       = parseInt(row.attr('RequestID'));
    var requestId_Parent= parseInt(row.attr('requestId_Parent'));
    var level           = parseInt(row.attr('level'));

    if (requestId != undefined) 
    {
        var parametersTogglePriority =
        {
            sessionID: sessionID,
            requestID: requestId,
            viewSettings: viewSettings
        };
        PostServerMessage("ICW_aMMWorkflow.aspx/TogglePriority", JSON.stringify(parametersTogglePriority));

        if (level > 0)
            updateRow(requestId_Parent, 0, false);  // Update parent row if present
        updateRow(requestId, level, true);
    }
    $('#grid').focus();
}

// Called when AMM Manufacture Complete button is clicked
// Only works for prescriptions
// Toggles row's AMM Manufacture Complete status
function aMMWorkflow_AMMManufactureComplete() 
{
    var row             = getSelectedRow('grid');
    var requestId       = parseInt(row.attr('RequestID'));
    var requestTypeId   = parseInt(row.attr('RequestTypeID'));
    var state           = parseBoolean(row.attr('AMMManufactureComplete'));
    var level           = parseInt(row.attr('level'));
    
    if (requestId != undefined)
    {
        SetStatusNoteState(sessionID, viewSettings.NoteTypeID_ManufactureComplete, requestTypeId, [ requestId ], !state);
        updateRow(requestId, level, true);
    }
    $('#grid').focus();
}

// Called when AMM For Manufacture button is clicked
// Only works for prescriptions
// Toggles row's AMM For Manufacture status
function aMMWorkflow_AMMForManufacture() 
{
    var row             = getSelectedRow('grid');
    var requestId       = parseInt(row.attr('RequestID'));
    var requestTypeId   = parseInt(row.attr('RequestTypeID'));
    var state           = parseBoolean(row.attr('AMMForManufacture'));
    var level           = parseInt(row.attr('level'));
    
    if (requestId != undefined)
    {
        SetStatusNoteState(sessionID, viewSettings.NoteTypeID_ForManufacture, requestTypeId, [ requestId ], !state);
        updateRow(requestId, level, true);
    }
    $('#grid').focus();
}

// Called when AMM Refresh button is clicked 22Aug16 XN 160920
// Refreshes the work list
function aMMWorkflow_Refresh() 
{
    __doPostBack('upWorklist', 'refresh');
}

// Called when Search button is clicked
// Displays the modeless search from
function aMMWorkflow_Search()
{
    $('#divSearch').dialog(
        {
            modal: false,
            buttons:
    	    {
    	        'Find'  : function() { btnFindNext_onclick();                         },
    	        'Close' : function() { $(this).dialog("destroy"); $('#grid').focus(); } 
    	    },
            close: function() { $('#grid').focus(); },
            title: 'Search for Supply Request',
            focus: function () { $('#tbSearch').select(); $('#tbSearch').focus(); },
            open: function () { $('#searchError').text(''); $('#tbSearch').val(''); },
            closeOnEscape: true,
            draggable: true,
            resizable: false,
            appendTo: 'form',
            width: 350
        });    
}

// Called when find button in the search from is clicked
// If the data entered is a valid barcode will then search the list and display the supply request
function btnFindNext_onclick()
{
    var barcode = $('#tbSearch').val();
    
    $('#searchError').text('');
    if (!isBarcode(barcode))
        $('#searchError').text('Invalid barcode');
    else if (!findSupplyRequestByProductionTrayBarcode(barcode))
        $('#searchError').text('Barcode not in the list');
        
    $('#tbSearch').focus();
}

// If pending item changes update grid        
function PHARMACY_PendingItemChanged()
{
	__doPostBack('upWorklist', 'refresh');
}
        
// Update selected episode
function PHARMACY_EpisodeSelected(vid)
{
    // Prevent handling event if should be raising event 22Aug16 XN 160920
    if (viewSettings.SelectEpisode)
        return;

    // Check episode and entity rows exist in the DB with the expected versions as specified in the vid parameter
    ICW.clinical.episode.episodeSelected.init(sessionID, vid, EntityEpisodeSyncSuccess);
            
    // Called if or when Entity & Episode exist in the DB at the correct versions
    function EntityEpisodeSyncSuccess(vid)
    {
        // Only update if changed
        viewSettings.SelectedEpisodeID = vid.EntityEpisode.vidEpisode.EpisodeID;
        SaveviewSettings();
        var requestIdSelected       = getSelectedRow('grid').attr('RequestID');
        var requestIdParentSelected = getSelectedRow('grid').attr('RequestID_Parent');
        __doPostBack('upWorklist', 'refresh:' + requestIdSelected + ':' + requestIdParentSelected);
    }            
}
       
// Clear the selected episode
function PHARMACY_EpisodeCleared()
{
    // Prevent handling event if should be raising event 22Aug16 XN 160920
    if (viewSettings.SelectEpisode)
        return;

    viewSettings.SelectedEpisodeID = -1;
    SaveviewSettings();
    __doPostBack('upWorklist', 'refresh');
}

// Raise episode selected event
function RAISE_EpisodeSelected(jsonEntityEpisodeVid)    
{
	ICWEventRaise();
}

// Raise episode cleared event
function RAISE_EpisodeCleared()    
{
	ICWEventRaise();
}

// Raise request selected event
function RAISE_RequestSelected(RequestID)
{
	ICWEventRaise();
}

// Raise request changed event (used by OCS)
function RAISE_RequestChanged()
{
    ICWEventRaise();
}

// Used by order coms
function Refresh() {}

// Refresh header rows (as can be overridden by refreshRowStripes)
function refreshSectionHeaderStyle()
{
    if (viewSettings.ShiftSectionHeader)
    {
        $('#grid tr[headerRow]').css('background-color', '#676767');
    }
}