/*

FMBalanceSheetLayoutEditor.js

Specific script for the FMBalanceSheetLayoutEditor.aspx page.

*/

function grid_onkeydown(controlID, event) 
{
    switch (event.keyCode)  // Check which key was pressed
    {
        case 13:    // Enter
            if (getSelectedRowIndex(controlID) != null)
                btnEdit_OnClick();
            break;

        case 46:    // delete
            if (getSelectedRowIndex(controlID) != null && $('#btnDelete').length > 0)
                btnDelete_OnClick();
            break;
    }
}

// Adds or update row in grid with rowData
function UpdateGridRow(recordID, rowData) 
{
    // Convert to HTML
    rowData = ImprovedXMLReturn(rowData);

    // Add or edit row
    var rowIndex = getRowIndexByAttribute('gridItemList', 'RecordID', recordID);
    if (rowIndex == -1) {
        addRow('gridItemList', rowData);
        rowIndex = getRowCount('gridItemList') - 1;
    }
    else if (rowData == '') {
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

// Called when Add Section button is clicked
// Only allowed if on Opening Balance, Main Section, or Account Section
// Lauches the FMBalanceSheetSection.apsx form in add mode
function btnAddSection_OnClick() 
{
    if (!ValidateSelectedRow('create', false, new Array(sectionType_OpeningBalance, sectionType_MainSection, sectionType_AccountSection)))
        return;

    var updateRowID = DisplayEditor('FMStockAccountSheetSection.aspx', undefined, undefined, getSelectedRow('gridItemList').attr('RecordID'));
    if (updateRowID)
        __doPostBack('gridUpdatePanel', 'Refresh:' + updateRowID);    
}

// Called when Add Section button is clicked
// Only allowed if on Main Section, or Account Section
// Lauches the FMBalanceSheetSubSection.apsx form in add mode
function btnAddAccount_OnClick()
{
    if (!ValidateSelectedRow('create', true, new Array(sectionType_MainSection, sectionType_AccountSection)))
        return;
        
    var selectedRow   = getSelectedRow('gridItemList');
    var selectedRowID = selectedRow.attr('RecordID');
    var sectionType   = selectedRow.attr('SectionType');
    var parentID      = (sectionType == sectionType_MainSection) ? selectedRowID : selectedRow.attr('RecordID_Parent');

    updateRowID = DisplayEditor('FMStockAccountSheetSubSection.aspx', undefined, parentID, selectedRowID);
    if (updateRowID)
        __doPostBack('gridUpdatePanel', 'Refresh:' + updateRowID);
}

// Called when Edit button is clicked
// Lauches FMBalanceSheetSection.apsx or FMBalanceSheetSubSection.apsx form in edit mode
function btnEdit_OnClick()
{
    if (!ValidateSelectedRow('edit', true, new Array(sectionType_OpeningBalance, sectionType_MainSection, sectionType_AccountSection, sectionType_CalculatedClosingSection, sectionType_ActualClosingBalance, sectionType_ClosingBalanceDiscrepancies)))
        return;

    var selectedRow = getSelectedRow('gridItemList');
    var updateRowID;
    if (selectedRow.attr('SectionType') == sectionType_AccountSection)
        updateRowID = DisplayEditor('FMStockAccountSheetSubSection.aspx', selectedRow.attr('RecordID'), undefined, undefined);
    else
        updateRowID = DisplayEditor('FMStockAccountSheetSection.aspx', selectedRow.attr('RecordID'), undefined, undefined);

    if (updateRowID)
        __doPostBack('gridUpdatePanel', 'Refresh:' + updateRowID);
}

// Called when Delete button is clicked
// Only allowed if on Main Section, or Account Section
// Lauches FMBalanceSheetSection.apsx\Delete or FMBalanceSheetSubSection.apsx\Delete
function btnDelete_OnClick()
{
    if (!ValidateSelectedRow('delete', true, new Array(sectionType_MainSection, sectionType_AccountSection)))
        return;
        
    if (!confirm('Do you want to delete this item.'))
        return;
        
    var selectedRow = getSelectedRow('gridItemList');            
    var recordID    = parseInt(selectedRow.attr('RecordID'));

    // Call the delete method
    var parameters =  {                
                        sessionID: sessionID,
                        recordID:  recordID 
                      };                              
    if (selectedRow.attr('SectionType') == sectionType_MainSection)
        PostServerMessage("FMStockAccountSheetSection.aspx/Delete", JSON.stringify(parameters));
    else
        PostServerMessage("FMStockAccountSheetSubSection.aspx/Delete", JSON.stringify(parameters));
        
    // Refresh the grid        
    __doPostBack('gridUpdatePanel', 'Refresh:' + recordID);                
}

// Validates if the row is selected and type of row selected
function ValidateSelectedRow(operation, required, sectionTypesAllowed)
{
    $('#gridItemListError').text('');
    
    // Check if row is selected
    var selectedRow = getSelectedRow('gridItemList');
    if (required && selectedRow.length == 0)
    {
        $('#gridItemListError').text('Select a section from the list.');
        return false;
    }
    
    if (selectedRow.length > 0)
    {
        // Check the row type
        var sectionType = selectedRow.attr('SectionType');
        if ($.inArray(sectionType, sectionTypesAllowed) == -1)
        {
            $('#gridItemListError').text('You can\'t ' + operation + ' a section at this level.');
            return false;
        }
    }    
    
    return true;    
}

// On double click of the grid will popup finance manager editor.
// Note that this method is used by FinanceManager\ICW_FinanceManager.aspx
function DisplayEditor(url, recordID, recordID_parent, recordID_insertAfter) 
{
    var strURL           = document.URL;
    var intSplitIndex    = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    // add mode, and ids
    strURLParameters += (recordID == undefined) ? "&Mode=add" : "&Mode=edit";
    if (recordID != undefined)
        strURLParameters += "&RecordID=" + recordID.toString();
    if (recordID_parent != undefined)
        strURLParameters += "&RecordID_Parent=" + recordID_parent.toString();
    if (recordID_insertAfter != undefined)
        strURLParameters += "&RecordID_insertAfter=" + recordID_insertAfter.toString();
    
    // Pass reference to ICWWindow for printing
    var objArgs = new Object();
    if (window.opener != undefined)
        objArgs.icwwindow = window.opener.parent.ICWWindow();
    
    // Displays the suppliers details window
    
    var ret=window.showModalDialog("../FinanceManagerSettings/" + url + strURLParameters, objArgs, 'center:yes; status:off');
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    return ret;

}

// Selelt a row by record id
function selectRowByID(recordID)
{        
    selectRow('gridItemList', getRowIndexByAttribute('gridItemList', 'RecordID', recordID));
}

