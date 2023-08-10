/*

                           PharmacyGridControl.js


Scipts with number of helper functions for the PharmacyGridControl.

All methods in this file will require a unique ID, this should 
be the id of grid control set in the web page .

    <uc1:GridControl ID="userGrid" runat="server" />  
    
Lots of methods require a row index this is zero based (top of list)
      
*/

// Call this manually to handle up/down key presses to change the selected row
function gridcontrol_onkeydown_internal(controlID, event)
{
    switch (event.keyCode)  // Check which key was pressed
    {
        case 38:    // up key
            // Get index of next visible row, from selected index (or set to top)
            var rowindex = getSelectedRowIndex(controlID);
            if (rowindex == null)
                rowindex = getNextVisibleRow(controlID, -1, 1);
            else
                rowindex = getNextVisibleRow(controlID, rowindex, -1);

            // mark the row as selected
            //selectRow(controlID, rowindex);   29May14 XN 88922 Added multi select
            if (event.shiftKey)
                selectRow(controlID, rowindex, undefined, 'extend');
            else
                selectRow(controlID, rowindex, undefined, 'single');

            // scroll the row into view
            if (!IsRowInView(controlID, rowindex))
                scrollRowIntoView(controlID, rowindex, true);

            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;

        case 40:    // down key
            // Get index of next visible row, from selected index (or set to bottom)
            var rowindex = getSelectedRowIndex(controlID);
            if (rowindex == null)
                rowindex = getNextVisibleRow(controlID, -1, 1);
            else
                rowindex = getNextVisibleRow(controlID, rowindex, 1);

            // mark the row as selected
            //selectRow(controlID, rowindex);   29May14 XN 88922 Added multi select
            if (event.shiftKey)
                selectRow(controlID, rowindex, undefined, 'extend');
            else
                selectRow(controlID, rowindex, undefined, 'single');

            // scroll the row into view
            if (!IsRowInView(controlID, rowindex))
                scrollRowIntoView(controlID, rowindex, false);

            window.event.cancelBubble = true;
            window.event.returnValue = false;            
            break;

        case 37: // Left
            {
            var rowIndex = getSelectedRowIndex(controlID);
            if (isShowChildRows(controlID, rowIndex) != undefined)
                setShowChildRows(controlID, rowIndex, false, true);
            }
            break;

        case 39: // Right
            {
            var rowIndex = getSelectedRowIndex(controlID);
            if (isShowChildRows(controlID, rowIndex) != undefined)
                setShowChildRows(controlID, rowIndex, true, true);
            }
            break;

        case 33:    // Page up
            var currentRowIndex = getSelectedRowIndex(controlID);
            if (currentRowIndex > 0) {
                // Get info
                var firstIndexInView = getFirstIndexInView(controlID);
                var numberRowsInView = parseInt(countRowsInView(controlID) - 0.5);

                // Calc row to move to
                if (firstIndexInView == 0)
                    nextRowIndex = 0;
                else if (firstIndexInView < (currentRowIndex - 1))
                    nextRowIndex = firstIndexInView;
                else
                    nextRowIndex = getNextVisibleRow(controlID, firstIndexInView, -numberRowsInView)
                nextRowIndex = Math.max(nextRowIndex, 0);

                // mark the row as selected
                //selectRow(controlID, nextRowIndex);   29May14 XN 88922 Added multi select
                if (event.shiftKey)
                    selectRow(controlID, nextRowIndex, undefined, 'extend');
                else
                    selectRow(controlID, nextRowIndex, undefined, 'single');

                // scroll the row into view
                if (!IsRowInView(controlID, nextRowIndex))
                    scrollRowIntoView(controlID, nextRowIndex, true);
            }

            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;

        case 34:    // Page down
            var currentRowIndex = getSelectedRowIndex(controlID);
            var rowCount        = getRowCount(controlID);
            if (currentRowIndex < rowCount) 
            {
                // Get info
                var lastIndexInView  = getLastIndexInView(controlID);
                var numberRowsInView = parseInt(countRowsInView(controlID) - 0.5);

                // Calc row to move to
                var nextRowIndex = (lastIndexInView > currentRowIndex) ? lastIndexInView : getNextVisibleRow(controlID, lastIndexInView, numberRowsInView);
                nextRowIndex = Math.min(Math.floor(nextRowIndex), rowCount - 1);

                // mark the row as selected
                //selectRow(controlID, nextRowIndex);   29May14 XN 88922 Added multi select
                if (event.shiftKey)
                    selectRow(controlID, nextRowIndex, undefined, 'extend');
                else
                    selectRow(controlID, nextRowIndex, undefined, 'single');

                // scroll the row into view
                if (!IsRowInView(controlID, nextRowIndex))
                    scrollRowIntoView(controlID, nextRowIndex, false);
            }

            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;

        case 36:    // Home
            var rows = getVisibleRows(controlID);
            if (rows.length > 0)
            {
                // Get actual index of first visible row
                var rowIndex = $('#' + controlID + ' tbody tr').index(rows[0]);
                
                // mark the row as selected
                //selectRow(controlID, rowIndex);   29May14 XN 88922 Added multi select
                if (event.shiftKey)
                    selectRow(controlID, nextRowIndex, undefined, 'extend');
                else
                    selectRow(controlID, nextRowIndex, undefined, 'single');

                // scroll the row into view
                if (!IsRowInView(controlID, rowIndex))
                    scrollRowIntoView(controlID, rowIndex, true);
            }

            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;


        case 35:    // End
            var rows = getVisibleRows(controlID);
            if (rows.length > 0)
            {
                // Get actual index of last visible row
                var rowIndex = $('#' + controlID + ' tbody tr').index(rows[rows.length - 1]);
                
                // mark the row as selected
                //selectRow(controlID, rowIndex);
                if (event.shiftKey)
                    selectRow(controlID, nextRowIndex, undefined, 'extend');
                else
                    selectRow(controlID, nextRowIndex, undefined, 'single');

                // scroll the row into view
                if (!IsRowInView(controlID, rowIndex))
                    scrollRowIntoView(controlID, rowIndex, false);
            }

            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;

        case 32:    // when space bar clicked if the contains one check box then toogle state
            var rowIndex = getSelectedRowIndex(controlID);
            if ((rowIndex != null) && ($('input[type=checkbox]', getRow(controlID, rowIndex)).length == 1)) 
            {
                // toogleCheck(controlID, rowIndex); replace with click event below so works better 01Jul15 XN 114905

                window.event.cancelBubble = true;
                window.event.returnValue = false;

                // Use click so does not bybass other events
                $('input[type=checkbox]', getRow(controlID, rowIndex)).click(); // 01Jul15 XN 114905
            }
            break;     
        case 13:    // Return
            if ($('#' + controlID).attr('enterAsDblClick') == 'True')
            {
                getSelectedRow(controlID).dblclick();
                window.event.cancelBubble = true;    // XN 30Jun14 
                window.event.returnValue = false;    // XN 30Jun14 
            }
            break;
    }
}

// Returns number of rows that can be displayed, in scroll view area in the table
// Returned value includes fraction of rows
function countRowsInView(controlID) 
{
    var table     = $('#' + controlID)[0];
    var rows      = getVisibleRows(controlID);
    var headerRow = $('thead tr:eq(0)', table);

    // Calculate row height
    var rowHeight = 23;
    if (rows.length > 0)
        rowHeight = rows[0].clientHeight;

    // Calculate number of rows
    return (table.clientHeight - headerRow.height() - 20) / rowHeight;        
}

// Returns the index of the top row in view (-1 if no rows in view)
// even if it is only partialy in view
function getFirstIndexInView(controlID) 
{
    var table = $('#' + controlID)[0];
    var rows  = getVisibleRows(controlID);
    var headerRow = $('thead tr:eq(0)', table);

    var scrollTop = table.scrollTop + headerRow.height();
    
    for (var r = 0; r < rows.length; r++) 
    {
        if (rows[r].offsetTop > scrollTop)
            return $('#' + controlID + ' tbody tr').index(rows[r]);
    }

    return -1;
}

// Returns the index of the last row in view (-1 if no rows in view)
// even if it is only partialy in view
function getLastIndexInView(controlID) 
{
    var table     = $('#' + controlID)[0];
    var rows      = getVisibleRows(controlID);
    var headerRow = $('thead tr:eq(0)', table);
    
    var scrollBottom = table.scrollTop + table.clientHeight - headerRow.height() - 20;

    for (var r = 0; r < rows.length; r++) 
    {
        if (rows[r].offsetTop > scrollBottom)
            return $('#' + controlID + ' tbody tr').index(rows[r]);
    }

    return -1;
}

function scrollRowIntoView(controlID, rowindex, directionUp)
{
    // can't use scrollIntoView else whole page scrolls (or does not work) so have to do manually
    var row = getRow(controlID, rowindex);
    var table = $('#' + controlID);
    var headerRow = $('thead tr:eq(0)', table);
    
    if (row.length == 0)    // Add to prevent script error if no row 16Aug13 XN
        return;
    
    if (directionUp)
    {
        var scrollTopPosition = row[0].offsetTop - headerRow[0].offsetHeight;
        table.scrollTop(scrollTopPosition);
    }
    else
    {
        var scrollTopPosition = row[0].offsetTop + headerRow[0].offsetHeight - table[0].clientHeight;
        table.scrollTop(scrollTopPosition);
    }
}

// called by the grid control when a row is clicked (will selected that row)
function gridcontrol_onclick_internal(controlID, rowindex)
{
    //selectRow(controlID, rowindex);  29May14 XN 88922 Added multi select
    if (event.shiftKey)
        selectRow(controlID, rowindex, undefined, 'extend');    // Extend selection
    else if (event.ctrlKey)
    {
        if (getRow(controlID, rowindex).hasClass('MultiSelect') && getSelectedRows(controlID).length > 1)
        {
            // If clicking on row that is alread selected (then deselect)
            unselectRow(controlID, rowindex);
            if (getSelectedRow(controlID).length == 0)
                selectRow(controlID, getSelectedRows(controlID)[0].rowIndex - 1, undefined, 'add'); // Set focust to another row
        }
        else
            selectRow(controlID, rowindex, undefined, 'add');   // Add to seletion
    }
    else
        selectRow(controlID, rowindex, undefined, 'single');    
}

// Returns number of rows in the table
function getRowCount(controlID)
{
    return $('#' + controlID + ' tbody tr').length;
}

// Returns number of visible rows in the table
// This is the number of rows where display is not none,
// and is not dependant on if the row is in scroll view 
function getVisibleRowCount(controlID)
{
    return getVisibleRows(controlID).length;
}

// Returns all visible rows in the table
// These are rows where display is not none, and is not dependant on if the row is in scroll view 
function getVisibleRows(controlID)
{
    return $('#' + controlID + ' tbody tr:not([display="none"])');
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
        var rows = $('#' + controlID + ' tbody tr:lt(' + startRowIndex + '):not([display="none"])');
                    
        if (rows.length >= -incremeant)
            row = rows[rows.length + incremeant];   // Get row specified by increment
        else if (getVisibleRows(controlID).length > 0)         
            row = getVisibleRows(controlID)[0];     // If before start then select first item
    }
    else 
    {
        // moving down the table so get all visible row above startRowIndex (down table)
        var rows = $('#' + controlID + ' tbody tr:gt(' + startRowIndex + '):not([display="none"])');

        if (rows.length >= incremeant)
           row = rows[incremeant - 1];   // Get row specified by increment
        else
        {
           var count = getVisibleRows(controlID).length;
           if (count > 0)
               row = getVisibleRows(controlID)[count - 1];    // If after last then select last item
        }
    }

    // If no row defined then must alread be at top or bottom of list
    // else get index of new row
    return (row == undefined) ? startRowIndex : $('#' + controlID + ' tbody tr').index(row);
}

// Returns rows containing a string (case insenitive)
// controlID    - grid control ID
// startrow     - index of start row
// count        - number to return (set to undefined for all rows)
// column       - column to search (set to undefined to all columns)
// searchString - string to search for
// visibleOnly  - if only to display visible rows (default is true)
// Need the jqueryExtensions.js to use this method
function findRowsContaining(controlID, startrow, count, column, searchString, visibleOnly)
{
    var rows = $('#' + controlID + ' tbody tr').slice(startrow);
    if ((visibleOnly == undefined) || visibleOnly)
        rows = rows.not('[display="none"]');

    // 26Jun14 XN added ability to search whole row and remove ability to find rows not containing text
    //if ((contains == undefined) || contains)
    //    rows = rows.filter(function(index) { return $('td:eq(' + column + ') span:containsi(\'' + searchString + '\')', this).length > 0 });
    //else
    //    rows = rows.filter(function(index) { return $('td:eq(' + column + ') span:not(:containsi(\'' + searchString + '\'))', this).length > 0 });

    var selectCellString = (column == undefined) ? 'td' : 'td:eq(' + column + ')';
    selectCellString += ' span:containsi(\'' + searchString + '\')';
    rows = rows.filter(function(index) { return $(selectCellString, this).length > 0 });

    if (count != undefined)
        rows = rows.splice(0, count);

    return rows;
}

// Returns index of first row starting with a string (case insenitive)
// Returns -1 if can't find a row
// controlID    - grid control ID
// startrow     - index of start row
// column       - column to search
// searchString - string to search for
// visibleOnly  - if only to display visible rows (default is true)
// Need the jqueryExtensions.js to use this method
function findIndexOfFirstRowStartWith(controlID, startrow, column, searchString, visibleOnly)
{
    var rows       = $('#' + controlID + ' tbody tr');
    var testString = 'td:eq(' + column + ') span';
    
    searchString = searchString.toLowerCase();
    if (visibleOnly == undefined)
        visibleOnly = true;
    
    for (var r = 0; r < rows.length; r++)
    {
        var row = $(rows[r]);
        
        if (!visibleOnly || row.attr('display') != 'none')
        {
            if ($(testString, row).text().toLowerCase().indexOf(searchString) == 0)
                return r;
        }
    }
    
    return -1;
}

// Sets the spececified row as being the selected row
// The rows colour will also change
function selectRow(controlID, rowindex, scrollIntoView, selectType)
{
    var rows = $('#' + controlID + ' tbody tr');

    var currentlySelectedRows = rows.filter('.MultiSelect');
    var oldSelectedRow        = currentlySelectedRows.filter('.Selected'   );

    // Force to single select if multi select is not supported 29May14 XN 88922
    if (selectType == undefined || $('#' + controlID).attr('allowMultiSelect').toLowerCase() == "false")
        selectType = 'single';

    // If single select remove all mult select items 29May14 XN 88922
    if (selectType == 'single')
        currentlySelectedRows.removeClass('MultiSelect');

    // Remove existing selection
    oldSelectedRow.removeClass('Selected');
    oldSelectedRow.removeAttr ('selected');

    // Select the row(s)
    if (rowindex != undefined) 
    {
        //var selectedRow = $('#' + controlID + ' tbody tr:eq(' + rowindex + ')'); 29May14 XN 88922 Added multi select
        //selectedRow.addClass('Selected');

        if (selectType == 'extend') 
        {
            // Get previous row that has focus
            var selectedRowIndex = (oldSelectedRow.length == 0) ? rowindex : oldSelectedRow[0].rowIndex - 1;

            // Get range of selection (between previous and new row)
            var startIndex = Math.min(selectedRowIndex, rowindex);
            var endIndex   = Math.max(selectedRowIndex, rowindex);

            // Select rows
            rows.slice(startIndex, endIndex).addClass('MultiSelect')
        }

        var selectedRow = rows.eq(rowindex);
        selectedRow.addClass('Selected MultiSelect');
        selectedRow.attr('selected', 'true');
    }
    
    // If requested will scoll selected row into view
    if (scrollIntoView == undefined)
        scrollIntoView = false;
    if (scrollIntoView && rowindex != undefined && !IsRowInView(controlID, rowindex))
        scrollRowIntoView(controlID, rowindex, false);    

    // Call oselectrow event
    if (typeof(pharmacygridcontrol_onselectrow) == 'function')
        pharmacygridcontrol_onselectrow(controlID, rowindex);
    else
    {
        var JavaEventOnRowSelected = $('#' + controlID).attr('JavaEventOnRowSelected');
        //if (JavaEventOnRowSelected.length > 0)   3Sept14 XN Fixed script error
        if (JavaEventOnRowSelected != undefined && JavaEventOnRowSelected.length > 0)
            eval(JavaEventOnRowSelected + '(' + rowindex + ')');
    }        
}

// Unselects the row
// Only really of use with multi select (after there may not be a row that has focus)
// 29May14 XN 88922
function unselectRow(controlID, rowIndex)
{
    tr = $('#' + controlID + ' tbody tr:eq(' + rowIndex + ')');
    tr.attr('tabindex', -1);
    tr.removeClass('MultiSelect');
    tr.removeClass('Selected');
    tr.removeAttr('selected');

    // Call onunselectrow event
    if (typeof(pharmacygridcontrol_onunselectrow) == 'function')
        pharmacygridcontrol_onunselectrow(controlID, rowIndex);
    else
    { 
        var JavaEventOnRowUnselected = $('#' + controlID).attr('JavaEventOnRowUnselected');
        if (JavaEventOnRowUnselected.length > 0)
            eval(JavaEventOnRowUnselected + '(' + rowIndex + ')');
    }        
}

// Returns the row index of the selected row (or null if no row selected)
function getSelectedRowIndex(controlID)
{
    var tableBody   = $('#' + controlID + ' tbody');
    var selectedRow = $('tr[selected]', tableBody);
    var rowindex = $('tr', tableBody).index(selectedRow);
    
    return (rowindex == -1) ? null : rowindex;
}

// Returns the selected row (as jQuery item)
function getSelectedRow(controlID)
{
    return $('#' + controlID + ' tbody tr[selected]:first');
}

// Returns the selected rows (as jquery list)
// Only really of use with multi select but will work in single select mode
// 29May14 XN 88922
function getSelectedRows(controlID)
{
    return $('#' + controlID + ' tbody tr.MultiSelect');
}

// Returns the row (as jQuery item)
function getRow(controlID, rowindex)
{
    return $('#' + controlID + ' tbody tr:eq(' + rowindex + ')');
}

// Returns the index of the row with the specified attribute value
// or null if the no row exists
function getRowIndexByAttribute(controlID, attributeName, attributeValue)
{
    var tableBody    = $('#' + controlID + ' tbody');
    var attributeRow = $('tr[' + attributeName + '="' + attributeValue + '"]', tableBody);
    var rowindex     = $('tr', tableBody).index(attributeRow);
    
    return (rowindex == undefined) ? null : rowindex;
}

// Returns the row with the specified attribute value (as jQuery item)
function getRowByAttribute(controlID, attributeName, attributeValue)
{
    return $('#' + controlID + ' tbody tr[' + attributeName + '="' + attributeValue + '"]');
}

// Returns if the rows check box is set
// Assumes only one checkable column
// 01Jul15 XN 39882 handle both attr and prop
function getCheckedRow(controlID, rowindex)
{
    var checkbox = $('#' + controlID + ' tbody tr:eq(' + rowindex + ') input[type=checkbox]');
    return (checkbox.prop == undefined) ? checkbox.attr('checked') : checkbox.prop('checked');
}

// Sets the checkbox for the row
// rowindex - row for the check 
// check    - if the row is to be checked or cleared
// Assumes only one checkable column
// 01Jul15 XN 39882 handle both attr and prop
function setCheckedRow(controlID, rowindex, check)
{
    var checkbox = $('#' + controlID + ' tbody tr:eq(' + rowindex + ') input[type=checkbox]');
    if (check)
        (checkbox.prop == undefined) ? checkbox.attr('checked', 'checked') : checkbox.prop('checked', 'checked');
    else
        (checkbox.prop == undefined) ? checkbox.removeAttr('checked') : checkbox.removeProp('checked');
}

// Sets the checkbox for all items in the table
// check        - if the row is to be checked or cleared
// visibleOnly  - if to only set checked on visible items (display!=none) does not effect items in scroll view
// Assumes only one checkable column
// 01Jul15 XN 39882 handle both attr and prop
function setCheckedAll(controlID, check, visibleOnly)
{
    var checkboxes;

    if (visibleOnly)
        checkboxes = $('#' + controlID + ' tbody tr:not([display="none"]) input[type=checkbox]');
    else
        checkboxes = $('#' + controlID + ' tbody tr input[type=checkbox]');

    if (check)
        (checkboxes.prop == undefined) ? checkboxes.attr('checked', 'checked') : checkboxes.prop('checked', 'checked');
    else
        (checkboxes.prop == undefined) ? checkboxes.removeAttr('checked') : checkboxes.removeProp('checked');
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
    return $('#' + controlID + ' tbody tr input[type=checkbox]:checked').parent().parent().parent();
}

// Returns a jquery array of all unchecked rows
// Assumes only one checkable column
function getUncheckedRows(controlID) {
    return $('#' + controlID + ' tbody tr input[type=checkbox]:not(:checked)').parent().parent().parent();
}

function getCell(controlID, rowIndex, columnIndex)
{
    return $('#' + controlID + ' tbody tr:eq(' + rowIndex + ') td:eq(' + columnIndex + ')')
}

// Adds the html data to end of table
function addRow(controlID, htmlRow)
{
    $('#' + controlID + ' tbody:first').append(htmlRow);
}

// Shows or hides all the rows
// use this rather than the jquery show or hide method,
// as rows need separate display="none" attribe to work
// rows     - rows to hide/shows
// visible  - if rows to be shown or hiddne
function showRows(rows, visible)
{
    if (visible)
    {
        rows.removeAttr('display');
        rows.show();
    }
    else
    {
        rows.attr('display', 'none');
        rows.hide();
    }    
}

// Allows a row to be shown or hidden
// use this rather than the jquery show or hide method,
// as rows need separate display="none" attribe to work
// rowIndex - index of row
// visible  - if rows to be shown or hiddne
function setRowVisible(controlID, rowIndex, visible)
{
    var row = getRow(controlID, rowIndex);
    showRows(row, visible);
}

// returns if the row is in a visible state
function isRowVisisble(row)
{
    return $(row).attr('display') != 'none';
}

// returns if row shading is enabled
function isAlternateRowShadingEnabled(controlID)
{
    return $('#' + controlID).attr('enableAlternateRowShading').toLowerCase() == "true";
}

// get column index by attribute 18Aug15 XN 126594
function GetColumnIndexByAttribute(controlID, key, value)
{
    var col = $('#' + controlID + ' thead th');
    return col.index(col.filter(':[' + key + '="' + value + '"]'));
}

// Sets all rows that contain the searchString to visible, and hides other rows
// Search is case insenitive
// controlID    - grid control ID
// columnIndexes- column index array to search on (e.g. [1,2]), can also handle single column index value (e.g. 1)
// searchString - string to search for
function filterRows(controlID, columnIndexes, searchString)
{
    var rows = $('#' + controlID + ' tbody tr');
    var searchStringLowerCase = searchString.toLowerCase();

    // If columnIndexes is single value not array then convert to array 27Aug14 XN 88922
    if (columnIndexes.length == undefined)
        columnIndexes = [ columnIndexes ];

    $.each(rows, function(index, row)
    {
        // cheack each cell (stop when found first cell contain text)
        var containsText = false;
        for (var pos = 0; pos < columnIndexes.length && !containsText; pos++)
        {
            var cellIndex = columnIndexes[pos];
            var cellText  = row.getElementsByTagName('td')[cellIndex].getElementsByTagName('span')[0].innerText;
            containsText  = (cellText.toLowerCase().indexOf(searchStringLowerCase) >= 0);
        }
        //var cellText = row.getElementsByTagName('td')[columnIndex].getElementsByTagName('span')[0].innerText;  27Aug14 XN 88922
        //var containsText = (cellText.toLowerCase().indexOf(searchStringLowerCase) >= 0);

        showRows($(row), containsText);
    });
}

// Replace table row with html
function replaceRow(cotrolID, rowIndex, htmlRow)
{
    getRow(cotrolID, rowIndex).replaceWith(htmlRow);
}

// Removes the row at the specified index
function removeAt(controlID, rowindex)
{
    return $('#' + controlID + ' tbody tr:eq(' + rowindex + ')').remove();
}

// All odd visible row are given a lightyellow background, other row background colours are cleared
// Call after a row is removed
function refreshRowStripes(controlID)
{
    var rows      = getVisibleRows(controlID);
    var hadLevels = (rows.length > 0) && (rows.eq(0).attr('level') != undefined);

    if (hadLevels)
    {
        var levelIndex = [0,0,0,0,0];

        $.each(rows, function(index, item)
        {
            var level = Number(item.attributes('level').value);

            if (levelIndex[level] % 2 == 0)
            {        
                switch (level)
                {
                case 0: item.style.backgroundColor = 'lightyellow'; break;
                case 1: item.style.backgroundColor = '#EDEDFF'; break;
                case 2: item.style.backgroundColor = '#EAF7FF'; break;
                }                
            }
            else
                item.style.backgroundColor = '';

            levelIndex[level] = levelIndex[level] + 1;
        });
    }
    else
    {
        $.each(rows, function(index, item)
        {
            item.style.backgroundColor = (index % 2 == 0) ? 'lightyellow' : '';
        });
        
    }
}

function gridcontrol_onshowchildrows_internal(controlID, imgControl)
{
    var onClientGetChildRows = $('#' + controlID).attr('OnClientGetChildRows');
    var row                  = $(imgControl.parentElement.parentElement.parentElement);
    var expanded             = $(row).attr('showchildrows') == '1';
    var rows                 = $('#' + controlID + ' tbody tr');

    if (onClientGetChildRows != undefined && onClientGetChildRows != '')
    {
        if (expanded)
        {
            var level = row.attr('level');            
            row.nextUntil('tr[level="' + level + '"]').remove();
        }
        else
        {
            var returnVal = eval(onClientGetChildRows + '("' + controlID + '", ' + rows.index(row) + ')');
            if (returnVal == undefined || returnVal != '')
                row.after(returnVal);
            else
                expanded = undefined;
        }

        setShowChildRows(controlID, rows.index(row), !expanded, false);
        if ($('#' + controlID).attr('enableAlternateRowShading').toLowerCase() == 'true')    
            refreshRowStripes(controlID);
    }
}

// Returns true if child rows icon is open
//         false if child rows icon is closed
//         null if there is no child row icon
function isShowChildRows(controlID, rowIndex)
{
    switch (getRow(controlID, rowIndex).attr('showchildrows'))
    {
    case '1': return true;
    case '0': return false;
    default: return undefined;
    }
}

// If true show child rows icon will be open
// If false show child rows icon will be closed
// If null there will be no child row icon
// controlID      - Control ID
// rowIndex       - row index
// showChildRows  - Show child rows
// forceEventFire - if true will cause the child rows to be show or displayed as needed
function setShowChildRows(controlID, rowIndex, showChildRows, forceEventFire)
{
    var cols         = $('#' + controlID + ' thead td[colindex]');
    var colIndex     = cols.index($(' [columntype="ExpandButton"]', cols));
    var row          = getRow(controlID, rowIndex);
    var expandImg    = $('img', getCell(controlID, rowIndex, colIndex));
    var currentState = row.attr('showchildrows');

    if (currentState != showChildRows)
    {
        if (forceEventFire)
            gridcontrol_onshowchildrows_internal(controlID, expandImg[0]);
        else
        {
            switch (showChildRows)
            {
            case true:  
                expandImg.attr('src', '../../images/grid/imp_closed.gif');
                expandImg.css('width', '15px');
                row.attr('showchildrows', '1'); 
                break;
            case false: 
                expandImg.attr('src', '../../images/grid/imp_open.gif');
                expandImg.css('width', '15px');
                row.attr('showchildrows', '0'); 
                break;
            default: 
                expandImg.attr('src', '');
                expandImg.css('width', '0');
                row.removeAttr('showchildrows'); 
                break;
            }
        }
    }
}

// Returns the row level (can be undefined if no level was set on the server)
function getRowLevel(controlID, rowIndex)
{
    var level = getRow(controlID, rowIndex).attr('level');
    return level == undefined ? undefined : parseInt(level);
}

// Returns if the specified row is visible, and is in the current scroll window
function IsRowInView(controlID, rowindex) 
{
    var row = getRow(controlID, rowindex)[0];
    if (row == null)    // Add to prevent script error if no row 16Aug13 XN
        return;
        
    var table = row.offsetParent.offsetParent;

    // Get the height of the header row
    var tableHeaderHeight = 0;
    var headerRow = $('thead tr:eq(0)', table);
    if (headerRow.length > 0)
        tableHeaderHeight = headerRow[0].offsetHeight;

    // Get the position of the to and bottom of the row (relative to the top of the grid control)
    var rowTopPosition    = row.offsetTop - table.scrollTop - tableHeaderHeight;
    var rowBottomPosition = row.offsetTop + row.offsetHeight - table.scrollTop;

    // return if row is outside viewable are of the grid control
    return ((rowBottomPosition <= table.clientHeight) && (rowTopPosition >= 0));
}

// marshalles all the row attributes into a single string 
// rows are spearated by cr (char 13), and attributes by rs (record separator char 30)
// e.g.
//  {attr name}={value}rs{attr name}={value}rscr{attr name}={value}rs{attr name}={value}rscr{attr name}={value}rs{attr name}={value}rscr
//
// method will filter out all standard attributes (like style, width etc.)
function MarshalRowAttributes(rows)
{
    // List of standard attibutes
    var standardAttributes = 'language,dataFld,onmouseup,oncontextmenu,class,style,onrowexit,onbeforepaste,onactivate,lang,onmousemove,onmove,onselectstart,oncontrolselect,onkeypress,oncut,onpaste,onrowenter,onmousedown,onmouseup,onreadystatechange,onbeforedeactivate,hidefocus,' + 
                                   'dir,onkeydown,onkeyup,onlosecapture,ondrag,ondragstart,oncellchange,onfilterchange,onrowsinserted,ondatasetcomplete,onmousewheel,ondragenter,onblur,onresizeend,onerrorupdate,onbeforecopy,ondblclick,ondatasetchanged,ondeactivate,onpropertychange,ondragover,' +
                                    'onhelp,ondragend,onbeforeeditfocus,disabled,onfocus,accessKey,onscroll,onbeforeactivate,onbeforecut,dataSrc,onclick,oncopy,onfocusin,tabIndex,onbeforeupdate,ondataavailable,onmovestart,onmouseout,onmouseenter,onlayoutcomplete,implementation,onafterupdate,' +
                                    'ondragleave,vAlign,align,borderColor,borderColorLight,chOff,bgColor,borderColorDark,ch,height,width,sizcache,sizset,'
    // separator characters
    var rs = String.fromCharCode(30);
    var cr = String.fromCharCode(13);
    
    var attributes = '';
    
    // Iterate each row
    $.each(rows, function(index, element) 
    {
        // Iterate each attribute
        for(var c = 0; c < element.attributes.length; c++)
        {
            var attr = element.attributes[c];
            
            // If attribute has been spcified and is not part of the standard list (see above add it to the string)
            if (attr.specified && 
                (standardAttributes.indexOf(attr.name + ',') == -1)) 
                attributes += attr.name + '=' + attr.value + rs;
        }
        
        // add row separator
        attributes += cr;
    });
    
    return attributes;
}

// marshalles the table data (excluding attributes) into a single string
// rows are spearated by rscr (char 30 and char 13), and columns by rs (record separator char 30)
// The header column also contains width, and column alignment info in form separeated by unit separator (char 31)
//      
//
// e.g.
//  {attr name}={value}rs{attr name}={value}rscr{attr name}={value}rs{attr name}={value}rscr{attr name}={value}rs{attr name}={value}rscr
//
// method will filter out all standard attributes (like style, width etc.)
// XN 28Dec12 (51139)
function MarshalRows(controlID)
{
    var gridStr = '';

    // separator characters
    var cr = String.fromCharCode(13);
    var rs = String.fromCharCode(30);
    var us = String.fromCharCode(31);

    var hearderRow = $('#' + controlID + ' thead tr th');
    $.each(hearderRow, function()
    {
        gridStr += this.innerHTML.substring(0, this.innerHTML.indexOf('<IMG ')) + us;
        gridStr += this.attributes['width'].value.replace('%', '') + us;
        gridStr += this.attributes['colalignment'].value + rs;
    });
    gridStr += cr;
                    
    var allRows = $('#' + controlID + ' tbody tr');
    $.each(allRows, function() 
        {
            $.each($('td span', this), function() 
                {
                    gridStr += this.innerHTML + rs;
                });
            gridStr += cr;
        });
        
    return gridStr;        
}

// function will return 
//       1 if a.hash > b.hash
//      -1 if a.hash < b.hash
//       0 if a.hash = b.hash
function sortFunction(a, b) 
{
    if (a.hash > b.hash)
        return 1;
    else if (a.hash < b.hash)
        return -1;
    else 
        return 0;
}

// Converts a pharmacy date string in format dd-mm-yyyy to a date object
// return null if conversion fails
// Not used by this class, but maybe useful in future
function convertPharmacyDateStringToDate(dateString) 
{
    try 
    {
        if (dateString.length < 10)
            return null;

        var temp;

        // Convert day
        temp = dateString.substring(0, 2);
        while (temp.charAt(0) == '0')   // Remove leading spaces as parseInt will assume it is octal
            temp = temp.substring(1);
        var day = parseInt(temp);   

        // Convert month
        temp = dateString.substring(3, 5);
        while (temp.charAt(0) == '0')   // Remove leading spaces as parseInt will assume it is octal
            temp = temp.substring(1);
        var month = parseInt(temp) - 1;

        // Convert year
        temp = dateString.substring(6);
        while (temp.charAt(0) == '0')   // Remove leading spaces as parseInt will assume it is octal
            temp = temp.substring(1);
        var year = parseInt(temp);

        return new Date(year, month, day)
    }
    catch (ex) 
    {
        return null;
    }
}

// returns cell text as a object, depending on dataType
//  if dataType is DateTime converts cell from dd/mm/yyyy format to yyyymmdd as this is faster than converting to date (or null if invalid date)
//  if dataType is Number   converts cell to numeric value (will ignore any leading or tailing non numeric characters) (or null if invalid date)
//  otherwise method just returns cell as a string.
function convertDataType(cell, dataType) 
{
    var cellText = cell.innerText;

    try
    {
        switch (dataType) {
            case 'DateTime':    // convert from dd/mm/yyyy to yyyymmdd as quicker than converting to date
                return cellText.substring(6) + cellText.substring(3, 5) + cellText.substring(0, 2);
            case 'Number':
                var val = parseFloat(cellText);
                return isNaN(val) ? Number.MAX_VALUE : val;
            case 'Money':
                var val = cellText.substring(2, cellText.length);
                return parseFloat(val);
            default: 
                return new String(cellText).toLowerCase();
        }
    }
    catch(ex)
    {
        return null;
    }
}

// Called when a column header is clicked, will cause the column to be sorted
function columnheader_onclick(id, columnIndex) 
{
    var table       = $('#' + id);
    var tableBody   = $('#' + id + ' tbody');
    var columnHeader= $('#' + id + ' thead th:eq(' + columnIndex + ')');
    
    // Get row data type
    var dataType = columnHeader.attr('columntype');

    // create array of rows and hash values
    var rowHash = [];
    tableBody.children().each(function(index, element)
    {
        var cell = element.children[columnIndex];
        rowHash[rowHash.length] = { row: $(element), hash: convertDataType(cell, dataType) };
    });

    // get existing sort column, and direction
    // XN 30Oct14 Fixed script error when click column headers
    if (table.prop == undefined)
    {
        var sortDir             = table.attr('sortdir').toLowerCase();
        var previousColumnIndex = table.attr('sortcolumnindex');          
    }
    else
    {
        var sortDir             = table.prop('sortdir').toLowerCase();
        var previousColumnIndex = table.prop('sortcolumnindex');
    }

    // determine new sort direction
    sortDir = ((sortDir == 'asc') && (previousColumnIndex == columnIndex)) ? 'desc' : 'asc';
        
    // sort data        
    rowHash.sort(sortFunction);
    if (sortDir == 'desc')
        rowHash.reverse();    
    
    // rebuild table
    tableBody.children().remove();
    for (var c = 0; c < rowHash.length; c++)
        tableBody.append(rowHash[c].row);

    // If alternate row shading is enabled then refresh
    if (table.attr('enableAlternateRowShading').toLowerCase() == "true")
        refreshRowStripes(id);

    // Store new sort column, and direction
    // XN 30Oct14 Fixed script error when click column headers
    if (table.prop == undefined)
    {
        table.attr('sortcolumnindex', columnIndex);
        table.attr('sortdir',         sortDir);
    }
    else
    {
        table.prop('sortcolumnindex', columnIndex);
        table.prop('sortdir',         sortDir);
    }

    // update the sort image on the header
    $('thead th #imgSort',  table       ).attr('src', '../../images/ocs/classSetEmpty.gif');
    $('#imgSort',           columnHeader).attr('src', (sortDir == 'asc') ? '../../images/ocs/sortAsc.gif' : '../../images/ocs/sortDesc.gif');
}

