/*

PNEditList.js

Specific script for the PNEditList.aspx page.

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
    case 'allproducts':               recordID = DisplayPNProductEditor();                      break;
    case 'ingredientbyproduct':       recordID = DisplayPNRuleEditor('ingredientbyproduct');    break;
    case 'standardpaediatricregimen': recordID = DisplayPNStandardRegimenEditor('Paediatric');  break;
    case 'standardadultregimen':      recordID = DisplayPNStandardRegimenEditor('Adult');       break;
    case 'prescriptionproforma':      recordID = DisplayPNRuleEditor('prescriptionproforma');   break;
    case 'regimenvalidation':         recordID = DisplayPNRuleEditor('regimenvalidation'  );    break;
    }    
    // If user saved then form returns record id so add to list
    if (recordID != undefined) {      
        __doPostBack('upButtons', 'Refresh:' + recordID);  
    }
    //alert('recordID' + sessionStorage.getItem('logoutFromActivityTimeout'));
    // If user saved then updates the record
    //if (recordID != undefined)
    //    if (sessionStorage.getItem('logoutFromActivityTimeout') == 'true') {
    //        //alert('inside EditList.aspx');
    //        desktopURL = "../sharedscripts/ActivityTimeOut.aspx/ActivityTimeOut.aspx" + "?SessionID=0&closeWindow=1";
    //        //document.getElementById("ActivityTimeOut").src = desktopURL;
    //        $('#ActivityTimeOut').src = desktopURL;

    //    }
    //    else
    //        __doPostBack('upButtons', 'Refresh:' + recordID);
}

// Called when the add from request button is clicked (on used on the product editor screen)
// Allows a dss user to add a PN product from a dss request
// 25Nov15 XN  38321
function btnAddFromDSSRequest_onclick() 
{
    ClearError();

    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);
    strURLParameters += '&RequestType=PN';

    var drugDefRequestID = window.showModalDialog('SelectDrugRequest.aspx' + strURLParameters, '', 'status:off;center:Yes;');
    if (drugDefRequestID == 'logoutFromActivityTimeout') {
        drugDefRequestID = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (drugDefRequestID != undefined)
    {
        var recordID = DisplayPNProductEditor(undefined, drugDefRequestID);
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
        case 'allproducts':                 recordID = DisplayPNProductEditor(recordID);                        break;
        case 'ingredientbyproduct':         recordID = DisplayPNRuleEditor('ingredientbyproduct', recordID);    break;
        case 'standardpaediatricregimen':   recordID = DisplayPNStandardRegimenEditor('Paediatric', recordID);  break;
        case 'standardadultregimen':        recordID = DisplayPNStandardRegimenEditor('Adult', recordID);       break;
        case 'prescriptionproforma':        recordID = DisplayPNRuleEditor('prescriptionproforma', recordID);   break;
        case 'regimenvalidation':           recordID = DisplayPNRuleEditor('regimenvalidation', recordID);      break;
        }

        // If user saved then updates the record
        if (recordID != undefined)
            //if (sessionStorage.getItem('logoutFromActivityTimeout') == 'true') {
            //    alert('inside EditList.aspx');
            //    __doPostBack('logOut', 'Refresh:' + recordID);
                
            //}
            // else
            __doPostBack('upButtons', 'Refresh:' + recordID);
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
    else
        replaceRow('gridItemList', rowIndex, rowData);

    // Refresh stripes
    refreshRowStripes('gridItemList');
    
    // Ensure row is selected
    selectRow('gridItemList', rowIndex);
    
    // Ensure it is in view
    if (!IsRowInView('gridItemList', rowIndex))
        scrollRowIntoView('gridItemList', rowIndex, false);
        
    $('#gridItemList').focus();
}

// Called wehn print button is clicked
// Calls web method EditList.aspx/SaveReportForPrinting to save the data to a session attribute
// Then calls icw print processor to print the report
// Xn 28Dec12 51139
function btnPrint_OnClick() 
{
    if (isMultiSiteEditMode) 
    {
        $('#divSitesToPrint').dialog(
        {
            modal: true,
            buttons: [{ text: 'OK',     width: 80, click: function () { $(this).dialog('destroy'); Print(getSelectedRow('gridSites').attr('SiteNumber')); } },
                      { text: 'Cancel', width: 80, click: function () { $(this).dialog('destroy'); } }
                     ],
            title: 'Select site',
            open: function (type, data) { setTimeout(function () { selectRow('gridSites', 0); $('#gridSites').focus(); }, 250); },
            width: '400px',
            maxHeight: '400px',
            closeOnEscape: true,
            draggable: false,
            resizable: false,
            appendTo: 'form'
        })
    }
    else
        Print(siteNumber);
}

// Print report 
// XN 30Oct15 106278
function Print(siteNum) 
{
    var parameters =
                {
                    sessionID:  parseInt(sessionID),
                    siteNumber: parseInt(siteNum),
                    title:      window.opener.document.getElementById('panelTitle').innerText,
                    filter:     $('#tbFilter').val(),
                    grid:       MarshalRows('gridItemList')
                };
    var result = PostServerMessage('EditList.aspx/SaveReportForPrinting', JSON.stringify(parameters));
    if(result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        if (window.parent.ICWWindow())
            window.parent.ICWWindow().Exit();
    }
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