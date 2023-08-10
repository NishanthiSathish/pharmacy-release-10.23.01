/*

PrescriptionMerge.js


Specific script for the PrescriptionLinking frame.

*/
var gridAsymetricCandidatesID = 'gridAsymetricCandidates';
var upAsymetricCandidatesErrorID = 'upAsymetricCandidatesError';
var lblAsymetricCandidatesErrorID = 'lblAsymetricCandidatesError';
var gridSelectedDrugID = 'gridSelectedDrug';
var hfSelectedDrugDataID = 'hfSelectedDrugData';
var lastCheckedRowIndex = -1;

// Called when form loads
function form_onload()
{
    // If any asymmetric candidate in first grid then select first item
    if (getRowCount(gridAsymetricCandidatesID) > 0) 
    {
        selectRow(gridAsymetricCandidatesID, 0);
        $('#' + gridAsymetricCandidatesID).focus();
    }
}

// Called when key is pressed in form
function form_onkeydown(id, event)
{
    switch (event.keyCode)  // Check which key was pressed
    {
        case 27:    // ESC (close the form only works when page is called from Pharmacy stores application)  
            window.close();
            break;
    }
}

// Called when item in main grid is clicked
function gridAsymetricCandidates_CheckBox_click(row, column)
{
    // Checked if row clicked    
    if (getCheckedRow(gridAsymetricCandidatesID, row)) 
    {
        lastCheckedRowIndex = row;

        // Get selected request
        var selectedRequestID = getRow(gridAsymetricCandidatesID, row).attr('RequestID')

        // get the data attributes of all selected rows
        var selectedRowAttrs = '';
        var index = -1;
        $.each(getCheckedRows(gridAsymetricCandidatesID), function(pos, element) 
        {
            selectedRowAttrs += element.attributes['Data'].value + '\n';
            if (selectedRequestID == element.attributes['RequestID'].value)
                index = pos;
        });

        // Add main prescription to the selected row attributes
        selectedRowAttrs += $('#' + hfSelectedDrugDataID).val();
        
        // send to server
        StartRequest();
        CallServer('newselection\n' + index.toString() + '\n' + selectedRowAttrs);
    }
    else 
    {
        // uncehecked so clear everything
        SetErrorMsg('', true);
        lastCheckedRowIndex = -1;
    }
}

// Called when ok button is clicked
// Create new merged prescription
function btnOK_onclick()
{
    var checkedRows = getCheckedRows(gridAsymetricCandidatesID);

    if (checkedRows.length > 0)
    {
        // Get selected row attributes
        var selectedRowAttrs = '';
        $.each(checkedRows, function(pos, element)
        {
            selectedRowAttrs += element.attributes['Data'].value + '\n';
        });

        selectedRowAttrs += $('#' + hfSelectedDrugDataID).val();

        // Send to server
        StartRequest();
        CallServer('create\n' + selectedRowAttrs);
    }
    else if (getRowCount(gridAsymetricCandidatesID) == 0)
        window.close();
    else if (ICWConfirm('Close without creating?', 'Yes,No', 'Ascribe - Prescription Linking', 'dialogHeight:80px;dialogWidth:200px;status:no;help:no;') == 'Yes')
        window.close();

    window.event.cancelBubble = true;
    window.event.returnValue = false;
}

// Called when server returns from CallServer
// replies can be
//  link=false\n{Warning message}
//  link=true\n{Error message}
//  created\n
function ReceiveServerData(retValue)
{
    EndRequest();

    if (retValue == '')
        return;

    // Splits reply
    var items = retValue.split('\n');

    switch (items[0].toLowerCase())
    {
        // Add prescription to link failed
        case 'link=false':
            if (lastCheckedRowIndex > -1)
                setCheckedRow(gridAsymetricCandidatesID, lastCheckedRowIndex, false);
            SetErrorMsg(items[1], false);
            break;

        // Add prescription to link succeeded
        case 'link=true':
            SetErrorMsg(items[1], true);
            break;

        // Creating prescription succeeded
        case 'created':
            // window.returnValue = true; 24Jul15 XN 114905 now returns new request ID
            window.returnValue = items.length < 2 ? undefined : items[1];
            window.close();
            break;

        // Operation failed
        default:
            SetErrorMsg(retValue, false);
            break;
    }
}

// Sets the error msg
function SetErrorMsg(error, warning)
{
    if ((error == undefined) || (error == ''))
        $('#' + lblAsymetricCandidatesErrorID).html('&nbsp;');
    else 
    {
        $('#' + lblAsymetricCandidatesErrorID).toggleClass('InfoMessage',  warning);
        $('#' + lblAsymetricCandidatesErrorID).toggleClass('ErrorMessage', !warning);

        $('#' + lblAsymetricCandidatesErrorID).html(error);
    }
}

// Disable buttons, and show message on start of a request
function StartRequest()
{
    $('button').attr('disabled', true);
    $('tbody tr input[type=checkbox]').attr('disabled', true);
    SetErrorMsg('Updating...', true);
}

// Enable buttons, and show message on start of a request
function EndRequest()
{
    $('button').removeAttr('disabled');
    $('tbody tr input[type=checkbox]').removeAttr('disabled');
    SetErrorMsg('', true);
}           

