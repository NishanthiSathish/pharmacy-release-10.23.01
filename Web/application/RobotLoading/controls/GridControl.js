/*

                            GridControl.js


Scipts with number of helper functions for the GridControl.

All methods in this file will require a controlID, this should 
be the id of uniqueContainerID set in the C# code.

    gridControl.uniqueContainerID = "MyGrid";   
    
Lots of method require a row index this is zero based (top of list)
and also includes hidden items.
      
*/

// Call this manually to handle up/down key presses to change the selected row
function gridcontrol_onkeydown_internal(controlID, event)
{
    switch (event.keyCode)  // Check which key was pressed
    {
        case 38:    // up key
            var rowindex = getSelectedRowIndex(controlID);
            if (rowindex == null)
                rowindex = getNextVisibleRow(controlID, -1, 1);
            else
                rowindex = getNextVisibleRow(controlID, rowindex, -1);

            selectRow(controlID, rowindex);
            break;

        case 40:    // down key
            var rowindex = getSelectedRowIndex(controlID);
            if (rowindex == null)
                rowindex = getNextVisibleRow(controlID, -1, 1);
            else
                rowindex = getNextVisibleRow(controlID, rowindex, 1);

            selectRow(controlID, rowindex);
            break;
    }
}

// called by the grid control when a row is clicked (will selected that row)
function gridcontrol_onclick_internal(controlID, rowindex)
{
    selectRow(controlID, rowindex);
}

// Returns number of rows in the table
function getRowCount(controlID)
{
    return $('#' + controlID + ' tbody tr').length;
}

// Returns number of visible rows in the table
function getVisibleRowCount(controlID)
{
    var count = 0;

    $('#' + controlID + ' tbody tr').each(function()
    {
        count++;
    });

    return count;
}

// Returns the next visible row index
// startRowIndex - is the start row
// incremeant    - -1 to move up the table, 1 to move down the table
function getNextVisibleRow(controlID, startRowIndex, incremeant)
{
    var row;    
    if (incremeant < 0) 
    {
        // moving up the table so get all visible row below startRowIndex (up table)
        var rows = $.grep($('#' + controlID + ' tbody tr'), function(r)
                   {
                       var rowindex = parseInt(r.attributes['rowindex'].value);
                       return (r.currentStyle.display != 'none') && (rowindex < startRowIndex);
                   });

        // Get top row as wil be first row above startRowIndex             
        if (rows.length > 0) 
           row = rows[rows.length - 1];
    }
    else 
    {
        // moving down the table so get all visible row above startRowIndex (down table)
        var rows = $.grep($('#' + controlID + ' tbody tr'), function(r)
                   {
                      var rowindex = parseInt(r.attributes['rowindex'].value);
                      return (r.currentStyle.display != 'none') && (rowindex > startRowIndex);
                   });

        // Get bottom row as wil be last row below startRowIndex             
        if (rows.length > 0)
           row = rows[0];
    }

    // If no row defined then must alread be at top or bottom of list
    // else get index of new row
    return (row == undefined) ? startRowIndex : parseInt(row.attributes['rowindex'].value);
}

// Sets the spececified row as being the selected row
// The rows colour will also change
function selectRow(controlID, rowindex)
{
    // Remove existing selection
    var allRows = $('#' + controlID + ' tbody tr');
    allRows.removeClass('Selected');
    allRows.removeAttr('selected');

    // Select the row
    if (rowindex != undefined) 
    {
        var selectedRow = $('#' + controlID + ' tbody tr[rowindex=' + rowindex + ']');
        selectedRow.addClass('Selected');
        selectedRow.attr('selected', 'true');
    }
}

// Returns the row index of the selected row (or null if no row selected)
function getSelectedRowIndex(controlID)
{
    var rowindex = $('#' + controlID + ' tbody tr[selected]').attr('rowindex');
    return (rowindex == undefined) ? null : parseInt(rowindex);
}

// Returns the selected row (as jQuery item)
function getSelectedRow(controlID)
{
    return $('#' + controlID + ' tbody tr[selected]');
}

// Returns the row (as jQuery item)
function getRow(controlID, rowindex)
{
    return $('#' + controlID + ' tbody tr[rowindex=' + rowindex + ']');
}

// Returns the index of the row with the specified attribute value
// or null if the no row exists
function getRowIndexByAttribute(controlID, attributeName, attributeValue)
{
    var rowindex = $('#' + controlID + ' tbody tr[' + attributeName + '="' + attributeValue + '"]').attr('rowindex');
    return (rowindex == undefined) ? null : parseInt(rowindex);
}

// Returns the row with the specified attribute value (as jQuery item)
function getRowByAttribute(controlID, attributeName, attributeValue)
{
    return $('#' + controlID + ' tbody tr[' + attributeName + '="' + attributeValue + '"]');
}

// Returns if the rows check box is set
// Assumes only one checkable column
function getCheckedRow(controlID, rowindex)
{
    return $('#' + controlID + ' tbody tr[rowindex="' + rowindex + '"] input[type=checkbox]').attr('checked');
}

// Sets the checkbox for the row
// rowindex - row for the check 
// check    - if the row is to be checked or cleared
// Assumes only one checkable column
function setCheckedRow(controlID, rowindex, check)
{
    if (check)
        $('#' + controlID + ' tbody tr[rowindex="' + rowindex + '"] input[type=checkbox]').attr('checked', 'true');
    else
        $('#' + controlID + ' tbody tr[rowindex="' + rowindex + '"] input[type=checkbox]').removeAttr('checked');
}

// Toggles the check box state for the row
// Assumes only one checkable column
function toogleCheck(controlID, rowindex)
{
    setCheckedRow(controlID, rowindex, !getCheckedRow(controlID, rowindex));
}

// Returns a jquery array of all checked rows
// Assumes only one checkable column
function getCheckedRows(controlID)
{
    return $('#' + controlID + ' tbody tr input[type=checkbox][checked]');
}

// Removes the row at the specified index
function removeAt(controlID, rowindex)
{
    return $('#' + controlID + ' tbody tr[rowindex=' + rowindex + ']').remove();
}

// All odd visible row are given a lightyellow background, other row background colours are cleared
// Call after a row is removed or hidden
function refreshRowStripes(controlID)
{
    var visibleIndex = 0;

    $.each($('#' + controlID + ' tbody tr'), function()
    {
        if (this.currentStyle.display != 'none') {
            visibleIndex++;
            this.style.backgroundColor = (visibleIndex % 2 == 0) ? 'lightyellow' : '';
        }
    });
}