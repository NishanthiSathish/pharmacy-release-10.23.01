/*

                    ICW_RepeatDispensingBatchTemplate.js


Specific script for the ICW_RepeatDispensingBatchTemplate pages.

*/

var REPEATDISPENSINGBATCHPROCESSORSCREEN_FEATURES = 'dialogHeight=475px; dialogWidth=725px; status:off; center: Yes';
var searchString = '';              // Used to build up string for seach pattern
var lastSearchTime = new Date();    // Time out for search pattern

function form_onload()
{
    selectRow('RDispTemplatesGrid', 0); 
    $('#RDispTemplatesGrid').focus();
    updateButtonStates();

    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(StartRequest);
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest  (EndRequest);
}

// called when key is press on form
function form_onkeydown(controlID, event) 
{
    switch (event.keyCode)  // Check which key was pressed
    {
    case 46:   // Del
        if (getSelectedRowIndex('RDispTemplatesGrid') != null)
            btnDelete_onclick();
        break;

    case 13:    // Enter
        if (getSelectedRowIndex('RDispTemplatesGrid') != null)
            btnEdit_onclick();
        break;
        
    case 27:    // ESC                
        window.close();
        break;

    default:    // Other key performs search of template description
        if (!event.altKey && !event.altLeft && (getSelectedRowIndex('RDispTemplatesGrid') != null)) 
        {
            var charCode = String.fromCharCode(event.keyCode);
            if ((' ' <= charCode) && ('~' >= charCode))
                findTemplate(charCode);
        }
        break;
    }
}

// Disable buttons, and show message on start of a request
function StartRequest()
{
    $('input').attr('disabled', 'disabled');
    $('#lbError').html("&nbsp;");
    $('#lbUpdating').html("Updating...");
}

// Enable buttons, and show message on start of a request
function EndRequest()
{
    updateButtonStates();
    $('#lbUpdating').html("&nbsp;");
}

// Called when edit button is clicked
// Allows user to edit template
function btnEdit_onclick() 
{
    var templateID = getSelectedRow('RDispTemplatesGrid').attr('RDispBatchTemplateID');
    DisplayTemplateEditor(templateID);
}

// Called when delete button is clicked
// does post back to delete selected row
// the server side code may ask user if they want to delete
function btnDelete_onclick() 
{
    var templateID = getSelectedRow('RDispTemplatesGrid').attr('RDispBatchTemplateID');
    __doPostBack('upButtons', 'Delete:' + templateID);
}

// Load repeat dispensing batch processor template editor
function DisplayTemplateEditor(templateID) 
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    strURLParameters += "&RepeatDispensingBatchTemplateID=" + templateID;
    strURLParameters += "&Mode=Template";

    // Displays the tempalte page
    var result = window.showModalDialog('RepeatDispensingBatchTemplateModal.aspx' + strURLParameters, '', REPEATDISPENSINGBATCHPROCESSORSCREEN_FEATURES);
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    // If changes have been made update the display
    if ((result != null) && (result != undefined) && (result != false))
    {
        __doPostBack('upButtons', 'Refresh:' + result);
        updateButtonStates();
    }

    $('#RDispTemplatesGrid').focus();
}

// Enables\disables a control
function EnableControl(controlID, enabled) 
{
    if (enabled)
        $('#' + controlID).removeAttr('disabled');
    else
        $('#' + controlID).attr('disabled', true);
}

// Update state of all buttons
function updateButtonStates() 
{
    var selectedItem = (getSelectedRowIndex('RDispTemplatesGrid') != null);
    EnableControl('btnEdit', selectedItem);
    EnableControl('btnDelete', selectedItem);
}

// moves to next selected template in list
// based on char code entered, and the current searchString
function findTemplate(charCode) 
{
    // If timed out in 1 secs then clear search string
    var currentTime = new Date();
    if ((currentTime - lastSearchTime) > 1000)
        searchString = '';

    // append to current search string
    searchString += charCode.toLowerCase();

    // get current and total row info
    var rowCount = getRowCount('RDispTemplatesGrid');
    var currentRowIndex = getSelectedRowIndex('RDispTemplatesGrid');
    var found = false;

    // Search from current row to end of list
    for (var r = currentRowIndex; r < rowCount; r++) {
        var description = getCell('RDispTemplatesGrid', r, 0).text().toLowerCase();
        if (description.indexOf(searchString) == 0) {
            selectRow('RDispTemplatesGrid', r);
            found = true;
            break;
        }
    }

    // If not found seach from to current row
    if (!found) {
        for (r = 0; r < currentRowIndex; r++) {
            description = getCell('RDispTemplatesGrid', r, 0).text().toLowerCase();
            if (description.indexOf(searchString) == 0) {
                selectRow('RDispTemplatesGrid', r);
                found = true;
                break;
            }
        }
    }

    // Update timeout
    lastSearchTime = new Date();
}

// Adds or update row in grid with rowData
function UpdateGridRow(templateID, rowData)
{
    rowData = ImprovedXMLReturn(rowData);

    var rowIndex = getRowIndexByAttribute('RDispTemplatesGrid', 'RDispBatchTemplateID', templateID);
    if (rowIndex == -1) 
    {
        addRow('RDispTemplatesGrid', rowData);
        rowIndex = getRowCount('RDispTemplatesGrid') - 1;
    }
    else
        replaceRow('RDispTemplatesGrid', rowIndex, rowData);

    refreshRowStripes('RDispTemplatesGrid');
    selectRow('RDispTemplatesGrid', rowIndex);
    
    if (!IsRowInView('RDispTemplatesGrid', rowIndex))
        scrollRowIntoView('RDispTemplatesGrid', rowIndex, false);
        
    $('#RDispTemplatesGrid').focus();
} 

// Remove the row with the specified template ID
function RemoveGridRow(templateID) 
{
    var rowCount = getRowCount('RDispTemplatesGrid');
    var rowIndex = getRowIndexByAttribute('RDispTemplatesGrid', 'RDispBatchTemplateID', templateID);
    var nextIndex = (rowIndex >= (rowCount - 1)) ? rowCount - 2 : rowIndex;

    removeAt('RDispTemplatesGrid', rowIndex);
    selectRow('RDispTemplatesGrid', nextIndex);
    updateButtonStates();
    refreshRowStripes('RDispTemplatesGrid');
    $('#RDispTemplatesGrid').focus();
}    
