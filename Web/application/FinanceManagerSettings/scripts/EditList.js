/*

EditList.js

Specific script for the EditList.aspx page.

*/

var searchString = '';              // Used to build up string for seach pattern
var lastSearchTime = new Date();    // Time out for search pattern

function grid_onkeydown(controlID, event) 
{
    switch (event.keyCode)  // Check which key was pressed
    {
    case 13:    // Enter
        if (getSelectedRowIndex(controlID) != null)
            btnEdit_onclick();
        break;
        
    case 46:    // delete
        if (getSelectedRowIndex(controlID) != null && $('#btnDelete').length > 0)
            btnDelete_onclick();
        break;

    default:    // Other key performs search of description
        if (!event.altKey && !event.altLeft && (getSelectedRowIndex(controlID) != null))
        {
            var charCode = String.fromCharCode(event.keyCode);
            if ((' ' <= charCode) && ('~' >= charCode))
            {
                // If timed out in 1 secs then clear search string
                var currentTime = new Date();
                if ((currentTime - lastSearchTime) > 1000)
                    searchString = '';

                // append to current search string
                searchString += charCode.toLowerCase();

                // get filter column
                var filterColumn = parseInt($('body').attr('FilterColumn'));

                // Do search
                //selectOnFilter(controlID, filterColumnIndex, searchString);
                var currentSelectedIndex = getSelectedRowIndex(controlID);
                var newSelectRow = findRowsContaining(controlID, currentSelectedIndex, 1, filterColumn, searchString, true, true);
                if (newSelectRow.length == 0)
                    newSelectRow = findRowsContaining(controlID, 0, 1, filterColumn, searchString, true, true);
                if (newSelectRow.length > 0)
                    selectRow(controlID, newSelectRow[0].rowIndex - 1);

                // Update search time                    
                lastSearchTime = new Date();
            }
        }
        break;
    }
}

// Called when user presses key in filter box
// updates the list filtering
function tbFilter_onkeyup()
{
    var filter = $('#tbFilter').val();
    filterList(filter);
}

// Called when user pases into filter box
// updates the list filtering
function tbFilter_onpaste()
{
    var filter    = $('#tbFilter').val();
    var clipboard = window.clipboardData.getData('Text');
    
    if (clipboard != undefined)
        filter += clipboard;
        
    filterList(filter);
}

// Filters the gird to only show items that contain the specified text
function filterList(filter)
{
    // get filter column
    var filterColumnIndex = parseInt($('body').attr('FilterColumn'));

    // Filter rows
    filterRows('gridItemList', filterColumnIndex, filter);
    
    // Update stripes
    refreshRowStripes('gridItemList');            
}

// Called when add button is clicked
// Allow user to add new record (calls method DisplayProductEditor())
function btnAdd_onclick()
{
    var recordID;
    
    ClearError();

    // Display add record form
    var dataType = $('body').attr('DataType');
    switch (dataType.toLowerCase())
    {
    case 'transactiontypes': recordID = DisplayEditor('FMTransactionTypeEditor.aspx', undefined); break;
    case 'accountcodes':     recordID = DisplayEditor('FMAccountCodeEditor.aspx',     undefined); break;
    case 'rules':            recordID = DisplayEditor('FMRule.aspx',                  undefined); break;
    }
        
    // If user saved then form returns record id so add to list
    if (recordID != undefined)
        __doPostBack('upButtons', 'Refresh:' + recordID);
}

// Called when edit button is clicked
// Allow user to edit selected record (calls method DisplayProductEditor())
function btnEdit_onclick()
{
    ClearError();         
    
    // Get selected row
    var selectedRow = getSelectedRow('gridItemList');
    if ((selectedRow.length == 1) && isRowVisisble(selectedRow))
    {
        // Get row id
        var recordID = selectedRow.attr('RecordID');
        
        // Display edit form
        var dataType = $('body').attr('DataType');
        switch (dataType.toLowerCase())
        {
        case 'transactiontypes': recordID = DisplayEditor('FMTransactionTypeEditor.aspx', recordID); break;
        case 'accountcodes':     recordID = DisplayEditor('FMAccountCodeEditor.aspx',     recordID); break;
        case 'rules':            recordID = DisplayEditor('FMRule.aspx',                  recordID); break;
        }

        // If user saved then updates the record
        if (recordID != undefined)
            __doPostBack('upButtons', 'Refresh:' + recordID);
    }
    else
        $('#gridItemListError').text('Select item from the grid.');
}

// Called when clone button is clicked
// Allows user to clone selected selected record (only works for rules)
function btnClone_onclick()
{
    ClearError();         
    
    // Get selected row
    var selectedRow = getSelectedRow('gridItemList');
    if ((selectedRow.length == 1) && isRowVisisble(selectedRow))
    {
        // Get row id
        var recordID = selectedRow.attr('RecordID');
        
        // Display edit form
        var dataType = $('body').attr('DataType');
        switch (dataType.toLowerCase())
        {
        case 'rules': recordID = DisplayEditor('FMRule.aspx', recordID, 'add'); break;
        }

        // If user saved then updates the record
        if (recordID != undefined)
            __doPostBack('upButtons', 'Refresh:' + recordID);
    }
    else
        $('#gridItemListError').text('Select item from the grid.');
}

function btnDelete_onclick()
{
    ClearError();         
    
    // Get selected row
    var selectedRow = getSelectedRow('gridItemList');
    if ((selectedRow.length == 1) && isRowVisisble(selectedRow))
    {
        // Get row id
        var recordID = selectedRow.attr('RecordID');
        // If user saved then updates the record
        if (recordID != undefined && confirm("OK to delete this item?"))
            __doPostBack('upButtons', 'Delete:' + recordID);
    }
    else
        $('#gridItemListError').text('Select item from the grid.');
}

// Clears the error message
function ClearError()
{
    $('#gridItemListError').html('&nbsp;');
}

// Adds or update row in grid with rowData
function UpdateGridRow(recordID, rowData)
{
    // Convert to HTML
    rowData = ImprovedXMLReturn(rowData);

    // Add or edit row
    var rowIndex = getRowIndexByAttribute('gridItemList', 'RecordID', recordID);
    if (rowIndex == -1) 
    {        
        addRow('gridItemList', rowData);
        rowIndex = getRowCount('gridItemList') - 1;
    }
    else if (rowData == '')
    {
        removeAt('gridItemList', rowIndex);
        rowIndex = -1;
    }
    else
        replaceRow('gridItemList', rowIndex, rowData);

    // Refresh stripes
    if (isAlternateRowShadingEnabled('gridItemList'))
        refreshRowStripes('gridItemList');
    
    // Ensure row is selected
    if (rowIndex > -1)
        selectRow('gridItemList', rowIndex);
    
    // Ensure it is in view
    if (rowIndex > -1 && !IsRowInView('gridItemList', rowIndex))
        scrollRowIntoView('gridItemList', rowIndex, false);
        
    $('#gridItemList').focus();
}

// Called wehn print button is clicked
// Calls web method EditList.aspx/SaveReportForPrinting to save the data to a session attribute
// Then calls icw print processor to print the report
// Xn 28Dec12 51139
function btnPrint_OnClick() 
{
    var parameters =
                {
                    sessionID:  parseInt(sessionID),
//                    siteNumber: parseInt(siteNumber),
                    title:      window.opener.document.getElementById('panelTitle').innerText,
                    filter:     $('#tbFilter').length > 0 ? $('#tbFilter').val() : '',
                    grid:       MarshalRows('gridItemList')
                };
    var result = PostServerMessage('EditList.aspx/SaveReportForPrinting', JSON.stringify(parameters));
    if (result != undefined) 
        window.opener.parent.ICWWindow().document.frames['fraPrintProcessor'].PrintReport(sessionID, result.d, 0, false, '');
}

function PostServerMessage(url, data)
{
    var result;
    $.ajax({
        type: "POST",
        url: url,
        data: data,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function(msg) 
        {
            result = msg;
        },
        error: function(jqXHR, textStatus, errorThrown) // XN 11Mar13 58517 Added error handling mainly for report printing
        {
            if (textStatus == 'error') 
            {
                var responseText = jQuery.parseJSON(jqXHR.responseText);
                alert('Failed due to error\r\n\r\n' + responseText.Message);
                // alert('Failed to create report due to error\r\n\r\n' + responseText.StackTrace); // for debug 
            }
        }
    });
    return result;
}

// On double click of the suppliers grid will popup finance manager editor.
// mode - is either add\edit can miss out, and then set to add if recorderID is undefined else edit
function DisplayEditor(url, recordID, mode) 
{
    var strURL           = document.URL;
    var intSplitIndex    = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    // add product and mode
    if (recordID != undefined)
        strURLParameters += "&RecordID=" + recordID.toString();

    if (mode != undefined)
        strURLParameters += "&Mode=" + mode;
    else if (recordID == undefined)
        strURLParameters += "&Mode=add";
    else
        strURLParameters += "&Mode=edit";

    // Pass reference to ICWWindow for printing
    var objArgs = new Object();
    objArgs.icwwindow = window.opener.parent.ICWWindow();

    // Displays the suppliers details window
    
    var ret = window.showModalDialog(url + strURLParameters, objArgs, 'center:yes; status:off');
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    return ret;
}