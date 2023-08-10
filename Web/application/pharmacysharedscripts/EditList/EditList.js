/*

					    EditList.js


	Specific script for the EditList.ascx control.
*/

// Called after postback
// Sets the selected cell to the one before the postback
function el_AfterPostBack(controlID)
{
    var selectedCell = el_GetSelectedCell(controlID);
    el_SetSelectedCell(controlID, selectedCell);
}

// Gets control container
function el_GetContainer(controlID)
{
    return $('#' + controlID + '_divELContainer');
}

// Gets control table
function el_GetTable(controlID)
{
    return $('#' + controlID + '_tblEL');
}

// Sets the selected cell
function el_SetSelectedCell(controlID, cell)
{
    if (cell == undefined || cell.length == 0)
        return;

    // End current edit operation
    el_EndEdit(controlID);

    // Clear selection class
    var oldSelectedCell = el_GetSelectedCell(controlID);
    oldSelectedCell.removeClass("selected");
    oldSelectedCell.children().removeClass("selected");

    // Set selection clas
    var control = cell.children(0);
    control.addClass("selected");
    cell.addClass   ("selected");

    // Update selection hidden value
    $('#' + controlID + '_hfSelectedCellID').val(cell.attr('id'));

    // Set focus
    cell.focus();

    // Scroll into view
    el_ScrolCellInToView(controlID, cell[0]);
}

// Set selected cell by col, and row
function el_SetSelectedCellByPos(controlID, col, row)
{
    var rows = $('tbody tr', el_GetTable(controlID));
    var newSelectedCell = rows.eq(row).children('td').eq(col);
    el_SetSelectedCell(controlID, newSelectedCell);
}

// Gets selected cell
function el_GetSelectedCell(controlID)
{
    var selectedCellID = $('#' + controlID + '_hfSelectedCellID').val();
    return $('#' + selectedCellID);
}

// Set cell value
function el_SetCellValue(cell, value)
{
    if (cell.children('input').length > 0)
    {
        var control = cell.children('input');
        control.val(value);
    }
    else
        cell[0].innerHTML = value;
}

// Get cell at position
function el_GetCell(controlID, col, row)
{
    return $('#' + controlID + ' tbody tr:eq(' + row + ') td:nth-child(' + col + ')');
}

// Resizes the control (call everytime parent resizes)
function el_onResize(controlID)
{
    var divView       = $('#' + controlID + '_divEL').parent();
    var container     = el_GetContainer(controlID);
    var table         = el_GetTable(controlID);
    var headerCells   = $('thead th', table);
    var colCount      = headerCells.length;

    // Set table height so get scroll bars
    container.height(divView.height()- 20);
    container.width (divView.width() - 16);

    // Add colgroup if not present
    if (table.children('colgroup').length == 0)
    {
        var colgroup = '<colgroup>';
        for (var c = 0; c < colCount; c++)
            colgroup += '<col />';
        colgroup += '</colgroup>';

        table.prepend(colgroup);
    }

    // calculate maximum require width of of the table
    var maxTableWidth = 0;
    headerCells.each( function(){ maxTableWidth += parseInt(this.getAttribute('maxWidth')); } );

    var widthMultiplier = container.width() / maxTableWidth;

    // Update width of each column
    maxTableWidth = 0;
    var cols = table.children('colgroup').children('col');
    headerCells.each( function( index )
        {
            var minWidth = parseInt(this.getAttribute('minWidth'));
            var maxWidth = parseInt(this.getAttribute('maxWidth'));
            var colWidth = maxWidth * widthMultiplier;

            if (colWidth < minWidth)
                colWidth = minWidth;
            else if (colWidth > maxWidth)
                colWidth = maxWidth;

            // Set column width
            cols.eq(index).width(colWidth);
            $('tr td:nth-child(' + index + 1 + ')', table).children('textarea').css('width', colWidth - 12); // Have to set width of textarea else won't expand (nth-child seems to be 1 based index)

            maxTableWidth += colWidth;
        } );

    table.width(maxTableWidth);
}

// Handle onkeydown events
function elTable_onkeydown(controlID)
{
    switch (event.keyCode)
    {
    case 9:     // Tab
        var cell = el_GetSelectedCell(controlID);
        if (cell.length != 0)
        {
            var rows     = $('tbody tr', el_GetTable(controlID));
            var rowIndex = rows.index(cell.parent());

            var cols     = rows.eq(rowIndex).children('td');
            var colIndex = cols.index(cell);

            if (event.shiftKey)
            {
                if (colIndex >   0)
                    el_MoveSelection(controlID, -1, 0);
                else if (rowIndex > 0)
                    el_MoveSelection(controlID, cols.length, -1);
            }
            else
            {
                if (colIndex < (cols.length - 1))
                    el_MoveSelection(controlID, 1, 0);
                else if (rowIndex < (rows.length - 1))
                    el_MoveSelection(controlID, -colIndex, 1);
            }

            window.event.cancelBubble = true; 
        }
        break;

    case 33:  // Page up
        var container   = el_GetContainer(controlID)[0];
        var selectedRow = el_GetSelectedCell(controlID).parent().eq(0);
        var headerHeight= $('thead th', el_GetTable(controlID)).height();
        var rows        = $('tbody tr', el_GetTable(controlID));

        if (selectedRow.prev().length > 0)
        {
            var currentIndex = rows.index(selectedRow);
            var scrollTopPos = container.scrollTop + headerHeight;
            var prevRow      = selectedRow.prev();
            if (prevRow.length > 0 && prevRow[0].offsetTop <= scrollTopPos)
                scrollTopPos -= (container.offsetHeight - headerHeight);

            for (var c = currentIndex; c > 0; c--)
            {
                if (rows[c].offsetTop <= scrollTopPos)
                    break;
            }
            el_MoveSelection(controlID, 0, c - currentIndex);
        }
        window.event.cancelBubble = true; 
        break;

    case 34:  // Page down
        var container   = el_GetContainer(controlID)[0];
        var selectedRow = el_GetSelectedCell(controlID).parent().eq(0);
        var headerHeight= $('thead th', el_GetTable(controlID)).height();
        var rows        = $('tbody tr', el_GetTable(controlID));

        if (selectedRow.next().length > 0)
        {
            var currentIndex    = rows.index(selectedRow);
            var rowCount        = rows.length;
            var scrollBottomPos = container.scrollTop + container.offsetHeight - headerHeight;
            var nextRow         = selectedRow.next();
            if (nextRow.length > 0 && (nextRow[0].offsetTop + nextRow[0].offsetHeight) > scrollBottomPos)
                scrollBottomPos += container.offsetHeight - headerHeight;

            for (var c = currentIndex; c < rowCount; c++)
            {
                if ((rows[c].offsetTop + rows[c].offsetHeight) >= scrollBottomPos)
                    break;
            }
            el_MoveSelection(controlID, 0, c - currentIndex);
        }
        window.event.cancelBubble = true; 
        break;
    case 35:  // End
        var selectedCell= el_GetSelectedCell(controlID);
        var selectedRow = selectedCell.parent().eq(0);
        var control     = selectedCell.children();
        if (selectedRow.length > 0 && control.prop('readonly') != false)
        {
            var rows         = $('tbody tr', el_GetTable(controlID));
            var currentIndex = rows.index(selectedRow);
            el_MoveSelection(controlID, 0, rows.length - currentIndex);
            window.event.cancelBubble = true;
        }
        break;
    case 36:  // Home
        var selectedCell= el_GetSelectedCell(controlID);
        var selectedRow = selectedCell.parent().eq(0);
        var control     = selectedCell.children();
        if (selectedRow.length > 0 && control.prop('readonly') != false)
        {
            var rows         = $('tbody tr', el_GetTable(controlID));
            var currentIndex = rows.index(selectedRow);
            el_MoveSelection(controlID, 0, -currentIndex);
            window.event.cancelBubble = true;
        }
        break;
    case 38:  // Up 
        var control = el_GetSelectedCell(controlID).children();
        if (!event.shiftKey)
        {
            el_MoveSelection(controlID, 0, -1);
            window.event.cancelBubble = true; 
        }
        break;
    case 40:  // Down
        var control = el_GetSelectedCell(controlID).children();
        if (!event.shiftKey)
        {
            el_MoveSelection(controlID, 0, 1);
            window.event.cancelBubble = true;
        }
        break;
    case 37:  // Left
        var control = el_GetSelectedCell(controlID).children();
        if (control.length == 0 || control.prop('readonly') != false)
        {
            el_MoveSelection(controlID, -1, 0);
            window.event.cancelBubble = true; 
        }
        break;
    case 39:  // Right
        var control = el_GetSelectedCell(controlID).children();
        if (control.length == 0 || control.prop('readonly') != false)
        {
            el_MoveSelection(controlID, 1, 0);
            window.event.cancelBubble = true; 
        }
        break;
    case 27:  // Esc
        var control = el_GetSelectedCell(controlID).children();
        if (control.length != 0 && control.prop('readonly') == false)
        {
            el_EndEdit(controlID);
            window.event.cancelBubble = true;
        }
        break;
    case 13:  // Enter
        var cell = el_GetSelectedCell(controlID);
        if (el_CanEditCell(cell))
        {
            if (el_IsCellBeingEdit(cell))
                el_EndEdit(controlID);                          // Currently editing so end
            else if (!event.shiftKey)
            {
                el_BeginEdit(controlID, true);
//                var baseControl = control.children();
//                if (baseControl.attr('type') == 'checkbox')
//                    baseControl.trigger('click');
            }

            window.event.cancelBubble = true; 
        }
        break;    
    case 32:  // Space 
        var control     = el_GetSelectedCell(controlID).children();
        var baseControl = control.children();
        if (control.attr('type') == 'submit')
        {
            control.trigger('click');
            window.event.cancelBubble = true; 
        }
        else if (baseControl.attr('type') == 'checkbox')
        {
            baseControl.trigger('click');
            window.event.cancelBubble = true; 
        }
        break;                        
    case 86: // V
        if (event.shiftKey && event.ctrlKey && $('#hfAllowMultiCopy').val() == 'true')
        {
            var control = el_GetSelectedCell(controlID).children();
            if (control.length != 0 && control.prop('disabled') == false)
            {
                var value = control.val();
                $('td input',    control.parent().parent()).val(value);
                $('td textarea', control.parent().parent()).val(value);
            }            
        }
        break;
    }

    if (window.event.cancelBubble)
        window.event.returnValue = false;
}

// called when cell is clicked
// Select cells and can put into edit mode
function elCell_onclick(controlID, cell)
{
    // if cell has child controls then check these
    if (cell.children('input').length > 0)
    {
        var control = cell.children()[0];

        // If button let normal event handling
        if (control.type == undefined || control.type == 'submit' || control.type == 'checkbox')
            return;

        // Note the currently selected range
        var selectedRange = (typeof document.selection != "undefined" && document.selection.type == "Text") ? document.selection.createRange() : undefined;
    }

    // select cell
    if (el_GetSelectedCell(controlID).attr('id') != cell.attr('id'))
        el_SetSelectedCell(controlID, cell);

    // If currently selecting range then start edit 20Mar14 XN
    if (selectedRange != undefined && selectedRange.text != '')
    {
        el_BeginEdit(controlID, false);
        selectedRange.select();
    }

    window.event.cancelBubble = true;   // Prevent bubbling up the double click (else end up with extra single click) 20Mar14 XN
    window.event.returnValue  = false;
}

// Called when cell is double clicked
// Selects cell, and puts in edit mode
function elCell_ondblclick(controlID, cell)
{
    // If on current selected item then return so normal mouse handle is enabled for control 20Mar14 XN
    if (el_GetSelectedCell(controlID).attr('id') != cell.attr('id'))
        el_SetSelectedCell(controlID, cell);

    // begin editing new cell
    el_BeginEdit(controlID, false);

    window.event.cancelBubble = true;   // Prevent bubbling up the double click (else end up with extra single click) 20Mar14 XN
    window.event.returnValue  = false;
}

// Called to start editing cell
function el_BeginEdit(controlID, autoSelectText)
{
    var cell    = el_GetSelectedCell(controlID);
    var control = el_GetSelectedCell(controlID).children();

    if (cell.attr('OnClientBeginEdit') != undefined)
        eval(cell.attr('OnClientBeginEdit'));
    else if (control.length != 0 && control.prop('readonly') == true)
    {
        if (control.prop('disabled') == false)
        {
            if (control.prop('type') == 'submit')
                control.click();
            else
            {
                control.removeProp('readonly');
                if (autoSelectText)
                    control.select();
                control.focus();
            }
        }
        else //if (control.attr('lookupOnly') != undefined) 86461 XN 18Mar14 always display error message even it item is not lookup
            alert('Field cannot be edited');
    }
}

// Called to end editing cell
function el_EndEdit(controlID)
{
    var control = el_GetSelectedCell(controlID).children();
    if (control.length != 0 && control.prop('disabled') == false)
    {
        if (document.selection)
            document.selection.empty();
        control.prop('readonly', 'readonly');

        // onchnage event does not always fire so manualy force it
        if (control[0].value != control[0].defaultValue)
            control.change();
    }
}

// Returns if the sepcified row is visible, and is in the current scroll window
function el_ScrolCellInToView(controlID, cell) 
{
    var container = el_GetContainer(controlID)[0];
    var header    = $('thead:first', container);
    var headerHeight = 0;
    if (header.length > 0)
        headerHeight = header[0].offsetHeight;

    // Get the position of the to and bottom of the row (relative to the top of the grid control)
    var rowTopPosition    = cell.offsetTop - container.scrollTop - headerHeight;
    var rowBottomPosition = cell.offsetTop + cell.offsetHeight - container.scrollTop;
    if (rowTopPosition < 0)
        $(container).scrollTop(cell.offsetTop - headerHeight);
    else if (rowBottomPosition > container.clientHeight)
        $(container).scrollTop(Math.min(rowTopPosition, cell.offsetTop + headerHeight - container.clientHeight));

    var fixedLeftColumnFirst = $('tr:last .fixedLeft:first', container)[0];
    var fixedLeftColumnLast  = $('tr:last .fixedLeft:last',  container)[0];
    var fixedLeftCellWidth   = fixedLeftColumnLast.offsetLeft - fixedLeftColumnFirst.offsetLeft + fixedLeftColumnLast.offsetWidth;

    var cellLeftPosition  = cell.offsetLeft - container.scrollLeft - fixedLeftCellWidth;
    var cellRightPosition = cell.offsetLeft + cell.offsetWidth - container.scrollLeft;
    if (cellLeftPosition < 0)
        $(container).scrollLeft(cell.offsetLeft - fixedLeftCellWidth);
    else if (cellRightPosition > container.clientWidth)
        $(container).scrollLeft(Math.min(cellLeftPosition, cell.offsetLeft + fixedLeftCellWidth - container.clientWidth));
}

// Moves selected sel by x and y (will limit to edges of table)
function el_MoveSelection(controlID,x,y)
{
    var selectedCell = el_GetSelectedCell(controlID);
    var rows         = $('tbody tr', el_GetTable(controlID));
    var hitLimit     = false;

    var rowIndex = rows.index(selectedCell.parent());
    var colIndex = rows.eq(rowIndex).children('td').index(selectedCell);

    rowIndex += y;
    if (rowIndex < 0)
        rowIndex = 0;
    if (rowIndex >= rows.length)
    {
        rowIndex = rows.length - 1;
        hitLimit = true;
    }

    colIndex += x;
    if (colIndex < 0)   
        colIndex = 0;   
    if (colIndex >= rows.eq(rowIndex).children('td').length)
    {
        colIndex = rows.eq(rowIndex).children('td').length - 1;
        hitLimit = true;
    }

    var newSelectedCell = rows.eq(rowIndex).children('td').eq(colIndex);

    if (newSelectedCell.attr('canSelect') == 'false')
    {
        if (!hitLimit)
            el_MoveSelection(controlID, x, y);
    }
    else
        el_SetSelectedCell(controlID, newSelectedCell);
}

// Determines if cell can be edited
function el_CanEditCell(cell)
{
    var control = cell.children();

    if (cell.attr('OnClientBeginEdit') != undefined)
        return true;
    else if (control.length != 0 && control.prop('readonly') == true)
        return true;
    else
        return false;
}

// Returns if the cell is being edited
function el_IsCellBeingEdit(cell)
{
    return cell.children().prop('readonly') == false
}
