/*

ShiftEditor.js

Specific script for the ShiftEditor.aspx page.

*/

// Called when add button is click
// Will open aMMShiftEditor.aspx page
function btnAdd_onclick()
{
    var parameters = getURLParameters();
    var result = window.showModalDialog('aMMShiftEditor.aspx' + parameters, '', 'status:off;center:Yes');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (result != undefined)
        __doPostBack('updatePanel', 'Refresh:' + result);
}

// Called when edit button is click
// Will open aMMShiftEditor.aspx page
function btnEdit_onclick()
{
    // Check single row selected
    var row = getSelectedRow('gcShifts');
    if (row.length == 0)
    {
        alert('Select a row from the list.');
        return;
    }
    else if (getSelectedRows('gcShifts').length > 1)
    {
        alert('Select single row.');
        return;
    }

    // Open the shift editor
    var parameters = getURLParameters();
    parameters += '&AMMShiftID=' + row.attr('DBID');
    var result = window.showModalDialog('aMMShiftEditor.aspx' + parameters, '', 'status:off;center:Yes');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (result != undefined)
    {
        // Update the list
        __doPostBack('updatePanel', 'Refresh:' + row.attr('DBID'));
    }

    $('#gcShifts').focus();
}

// Called when the delete button clicked
// Deletes the currently selected row
function btnDelete_onclick()
{
    // Check row selected
    var rows = getSelectedRows('gcShifts');
    if (rows.length == 0)
    {
        alert('Select a row from the list.');
        return;
    }

    // Get ids of items to delete
    var itemsToDelete = $.map(getSelectedRows('gcShifts'), function(r) { return $(r).attr("DBID"); });

    // Confirm with user an delete
    var msg = 'Delete selected shift(s)?<br /><br />Any existing AMM Supply Request(s) will stay<br />on the current shift until completed.';
    confirmEnh(msg,
               false,
               function () { __doPostBack('updatePanel', 'Delete:' + toCSV(itemsToDelete, ',')); $('#gcShifts').focus(); },
               function () { $('#gcShifts').focus();  });
}