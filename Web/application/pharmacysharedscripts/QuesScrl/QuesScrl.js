var digitsMask              = '^[0-9]+$';
var digitsAndDotMask        = '^[.]?[0-9]+[.]?[0-9]*$';
var digitsAndMinusMask      = '^[+-]?[0-9]*$';
var digitsDotAndMinusMask   = '^[+-]?[0-9]*[.]?[0-9]*$';

var GPEcontainer;
var GPEtable;
var GPEselectedCell;
var GPEhfSelectedCell;
var GPElastScrollPos;   // Only update on post back
var simpleEditMode;     // 2Mar16 XN 99381 simple edit mode

function GPEInit()
{
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(GPEbeginRequest);    
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest  (GPEendRequest);    
    GPEUpdateLocalVariables();
}

function GPEbeginRequest()
{
    if (GPEcontainer != undefined)
        GPElastScrollPos = GPEcontainer.scrollTop;
}

function GPEendRequest()
{
    GPEUpdateLocalVariables();
    if (GPEcontainer != undefined)
        GPEcontainer.scrollTop = GPElastScrollPos;  // Restore original scroll position
}

function GPEUpdateLocalVariables()
{
    GPEcontainer        = $('div[id*="divGPEContainer"]:first')[0];
    GPEtable            = $('table[id*="tblGPE"]:first tbody:eq(0)');
    GPEhfSelectedCell   = $('input[id*="hfSelectedCellID"]:first');
    simpleEditMode      = parseBoolean($('input[id$=hfSimpleEditMode]').val()); // 2Mar16 XN 99381 simple edit mode

    // 2Mar16 XN 99381 simple edit mode (show a button)
    var datetimefields = $('input[ctrlType=Date]:enabled');
    if (simpleEditMode)
    {
        datetimefields.datepicker({ showOn: "button",
                                    buttonImage: "../../images/formDesigner/calendar_view_day.png",
                                    buttonImageOnly: true,
                                    dateFormat: "dd/mm/yy"
                                });
        datetimefields.each(function (i, elem) 
                                {
                                    $(elem).insertAfter($(elem).next('img'));
                                });
    }

    // Restore selected cell or select first cell
    if ($('#' + GPEhfSelectedCell.val()).length == 0)
        GPESelectCell($('tr:eq(0) td:eq(2)', GPEtable));
    else
        GPESelectCell($('#' + GPEhfSelectedCell.val()).parent(), false);

    // Clear previous selection
    try
    {
        if (document.selection)
            document.selection.empty();
    }
    catch(err)
    {
    }
}

function MaskInput(ctrl, mask, modifiers, maxlength)
{
	// Get the insertion point
	var CurrentSelection = document.selection.createRange();
	var SelectionSize = CurrentSelection.text.length;
	CurrentSelection.moveStart('character', -ctrl.value.length);
	var InsertPoint = CurrentSelection.text.length - SelectionSize;

	//now check the input.
	switch (event.type)
	{
    case 'keypress':
		//Get the entered value
		thisCode = event.keyCode;

		if (thisCode != 13 && thisCode != 27 && thisCode != 9)  // Ignore control keys
		{						
			var incommingText = String.fromCharCode(thisCode);
            var finalText = ctrl.value.substr(0, InsertPoint) + incommingText + ctrl.value.substr(InsertPoint + SelectionSize, ctrl.value.length - InsertPoint - SelectionSize);

            // check length as multi line text boxes don't actually support length
		    if (maxlength > 0 && finalText.length > maxlength)
			    event.returnValue = false;
            else if (mask != undefined)
            {
			    //Check the single character against the list of valid ones.
                var regEx = new RegExp(mask, modifiers)
			    if (!regEx.test(finalText))
				    event.returnValue = false;
            }
		}
		break;

	case 'paste':
		//Get the incomming string
		var incommingText = window.clipboardData.getData('Text');
        var finalText = ctrl.value.substr(0, InsertPoint) + incommingText + ctrl.value.substr(InsertPoint + SelectionSize, ctrl.value.length - InsertPoint - SelectionSize);

		// Check that length doesnt exceed maxlength
		if (maxlength > 0 && finalText.length > maxlength)
			event.returnValue = false;
		else if (mask != undefined)
        {
            var regEx = new RegExp(mask, modifiers)
            if (!regEx.test(finalText))
			    event.returnValue = false;
        }
		break;
	}
}

function ConvertToUpper()
{
	switch (event.type)
	{
    case 'keypress':
        event.keyCode = String.fromCharCode(event.keyCode).toUpperCase().charCodeAt(0);
        break;

	case 'paste':
		var incommingText = window.clipboardData.getData('Text');
        window.clipboardData.setData('Text', incommingText.toUpperCase())
		break;
    }
}

function tblQuesScrlMain_onkeydown()
{
    switch (event.keyCode)
    {
    case 9:     // Tab
        var control  = $(GPEselectedCell).children();
        if (control.length != 0)
        {
            var trs      = GPEtable.children('tr');                                 // 2Mar16 XN 99381 simple edit mode
            var rowIndex = trs.index(control.parent().parent());
            var colIndex = trs.eq(rowIndex).children('td').index(control.parent());
            var cols     = trs.first().children('td').length - 2;                   // 2Mar16 XN 99381 simple edit mode
            var rows     = trs.length;                                              // 2Mar16 XN 99381 simple edit mode

            if (event.shiftKey)
            {
                if (colIndex > 2)
                    GPEMoveSelection(-1, 0);
                else if(rowIndex > 0)
                    GPEMoveSelection(cols - colIndex + 1, -1);  // 2Mar16 XN 99381 simple edit mode
            }
            else
            {
                if (colIndex <= cols)
                    GPEMoveSelection(1, 0);
                else if (rowIndex < rows - 1)
                    GPEMoveSelection(-colIndex, 1);
            }

            window.event.cancelBubble = true; 
        }
        break;

    case 112:  // F1
        if (event.shiftKey)
        {
            DoLookup($("[id*='QuesScrl'].selected"));
            window.event.cancelBubble = true; 
        }
        break;

    case 33:  // Page up
        var selectedRow = $(GPEselectedCell).parent().eq(0);
        var rows        = $('tr', GPEtable);

        if (selectedRow.prev().length > 0)
        {
            var currentIndex    = rows.index(selectedRow);
            var scrollTopPos    = GPEcontainer.scrollTop;
            if (selectedRow.prev().offset().top < scrollTopPos)
                scrollTopPos -= GPEcontainer.offsetHeight;

            for (var c = currentIndex; c > 0; c--)
            {
                if (rows[c].offsetTop < scrollTopPos)
                    break;
            }
            GPEMoveSelection(0, c-currentIndex);
        }
        window.event.cancelBubble = true; 
        break;
    case 34:  // Page down
        var selectedRow = $(GPEselectedCell).parent().eq(0);
        var rows        = $('tr', GPEtable);

        if (selectedRow.next().length > 0)
        {
            var currentIndex    = rows.index(selectedRow);
            var rowCount        = rows.length;
            var scrollBottomPos = GPEcontainer.scrollTop + GPEcontainer.offsetHeight;
            if ((selectedRow.next().offset().top + selectedRow.next().height()) > scrollBottomPos)
                scrollBottomPos += GPEcontainer.offsetHeight;

            for (var c = currentIndex; c < rowCount; c++)
            {
                if (rows[c].offsetTop > scrollBottomPos)
                    break;
            }
            GPEMoveSelection(0, c - currentIndex);
        }
        window.event.cancelBubble = true; 
        break;
    case 35:  // End
        var selectedRow = $(GPEselectedCell).parent().eq(0);
        var control     = $(GPEselectedCell).children();
        if (selectedRow.length > 0 && control.prop('readonly') != false)
        {
            var rows         = $('tr', GPEtable);
            var currentIndex = rows.index(selectedRow);
            GPEMoveSelection(0, rows.length - currentIndex);
            window.event.cancelBubble = true;
        }
        break;
    case 36:  // Home
        var selectedRow = $(GPEselectedCell).parent().eq(0);
        var control     = $(GPEselectedCell).children();
        if (selectedRow.length > 0 && control.prop('readonly') != false)
        {
            var rows         = $('tr', GPEtable);
            var currentIndex = rows.index(selectedRow);
            GPEMoveSelection(0, -currentIndex);
            window.event.cancelBubble = true;
        }
        break;
    case 38:  // Up 
        var control = $(GPEselectedCell).children();
        if (control.length != 0 && !event.shiftKey)
        {
            GPEMoveSelection(0, -1);
            window.event.cancelBubble = true; 
        }
        break;
    case 40:  // Down
        var control = $(GPEselectedCell).children();

        if (control.length != 0 && !event.shiftKey)
        {
            GPEMoveSelection(0, 1);
            window.event.cancelBubble = true;
        }
        break;
    case 37:  // Left
        var control = $(GPEselectedCell).children();
        if (control.length != 0 && control.prop('readonly') != false)
        {
            GPEMoveSelection(-1, 0);
            window.event.cancelBubble = true; 
        }
        break;
    case 39:  // Right
        var control = $(GPEselectedCell).children();
        if (control.length != 0 && control.prop('readonly') != false)
        {
            GPEMoveSelection(1, 0);
            window.event.cancelBubble = true; 
        }
        break;
    case 27:  // Esc
        var control = $(GPEselectedCell).children();
        //if (control.length != 0 && control.prop('readonly') == false)     3Mar16 XN 99381 added simple edit mode
        if (control.length != 0 && control.prop('readonly') == false && !UseSimpleEditModeForSelectedCell())
        {
            endEdit();
            window.event.cancelBubble = true;
        }
        break;
    case 13:  // Enter
        var control = $(GPEselectedCell).children();
        if (control.length != 0) 
        {
            //if (control.prop('readonly') == false)                        3Mar16 XN 99381 added simple edit mode
            if (control.prop('readonly') == false && !UseSimpleEditModeForSelectedCell())
                endEdit();                          // Currently editing so end
            else if (!event.shiftKey) 
            {
                // 2Mar16 XN 99381 simple edit mode
                if (!UseSimpleEditModeForSelectedCell())
                    beginEdit(true);
                else if (simpleEditMode && control.attr('lookupOnly') != undefined)
                    DoLookup(control);

                var baseControl = control.children();
                if (baseControl.attr('type') == 'checkbox')
                    baseControl.trigger('click');
            }
        }

        // If pressing shift then allow event to bubble up (else prevent) 2Mar16 XN 99381 simple edit mode
        //if (!event.shiftKey && !UseSimpleEditModeForSelectedCell()) 04Aug16 XN 159565 fix for simple edit mode to prevent cr in editor
        if (!event.shiftKey)
            window.event.cancelBubble = true; 
        break;
    case 32:  // Space 
        //var control     = $(GPEselectedCell).children();  3Mar16 XN 99381 just limit to input node types
        var control     = $(GPEselectedCell).children('input, textarea');
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
        else if (simpleEditMode && control.attr('lookupOnly') != undefined) // 2Mar16 XN 99381 simple edit mode
        {
            DoLookup(control);
            window.event.cancelBubble = true;
        }
        break;
    case 86: // V
        if (event.shiftKey && event.ctrlKey) 
        {
            var control = $(GPEselectedCell).children();
            if (control.length != 0 && control.prop('disabled') == false) 
            {
                var elemType = control.prop('nodeName');
                var value = control.val();
                //$('td input', control.parent().parent()).val(value);      3Mar16 XN 99381 simple edit mode
                //$('td textarea', control.parent().parent()).val(value);
                $('td ' + elemType, control.parent().parent()).each(function (index, elem) 
                {
                    if (value != $(elem).val())     // 2Mar16 XN 99381 simple edit mode
                    {
                        $(elem).val(value);
                        $(elem).change();    // 3Feb16 XN 143603 got unsave to work with ctrl+shift+V
                    }
                });
            }
        }
        break;
    default:
        // 2Mar16 XN 99381 if lookup control then display lookup (simple edit mode)
        var control = $(GPEselectedCell).children('input, textarea');
        if (simpleEditMode && event.keyCode >= 32 && event.keyCode <= 126 && control.attr('lookupOnly') != undefined)
            DoLookup(control, String.fromCharCode((96 <= event.keyCode && event.keyCode <= 105) ? event.keyCode - 48 : event.keyCode));
        break;
    }

    if (window.event.cancelBubble)
        window.event.returnValue = false;
}

function divGPE_onResize()
{
    GPEUpdateLocalVariables();  // XN 18Jun 14 88509 Always update as do resize after update so these can get out of sync

    var divView         = $('[id*="divGPE"]').parent();
    var table           = $('table', GPEcontainer).eq(0);
    var tbody           = $('tbody:eq(0)', table).eq(0);
    var firstCellLength = $('tr:first td:first', tbody).width();
    var secondCellLength= $('tr:first td:eq(1)', tbody).width();
    var cellCount       = $('tr:first td', tbody).length - 2;

    // Set table height so get scroll bars
    $(GPEcontainer).height(divView.height()- 20);
    $(GPEcontainer).width (divView.width() - 16);

    // calculate width of each column to use max space limited to 200 to 400px per column 
    var cellWidth = ($(GPEcontainer).width() - 16 - firstCellLength - secondCellLength) / cellCount;
    if (cellWidth < 200)
        cellWidth = 200;
    else if (cellWidth > 400)
        cellWidth = 400;

    // Set table width
    table.width((cellWidth * cellCount) + firstCellLength + secondCellLength);
    $('textarea', table).width(cellWidth - 12); // Have to set width of textarea else won't expand
    //$('tr td:first-child', tbody).css("width", firstCellLength + "px");
}

function GPEControl_onmousedown(control)
{
    // If button let normal event handling 20Mar14 XN
    if (control.type == undefined || control.type == 'submit' || control.type == 'checkbox')
        return;

    // Note the currently selected range 20Mar14 XN
    var selectedRange = (typeof document.selection != "undefined" && document.selection.type == "Text") ? document.selection.createRange() : undefined;

    // select cell
    var selectedControl = $(GPEselectedCell).children();
    if (selectedControl.attr('id') != control.id)
        GPESelectCell($(control.parentNode));

    // If currently selecting range then start edit 20Mar14 XN
    //if (selectedRange != undefined && selectedRange.text != '') 3Mar16 XN 99381 simple edit mode
    if (selectedRange != undefined && selectedRange.text != '' && !simpleEditMode)
    {
        beginEdit(false);
        selectedRange.select();
    }

    window.event.cancelBubble = true;   // Prevent bubbling up the double click (else end up with extra single click) 20Mar14 XN
    window.event.returnValue  = false;
}

// 2Mar16 XN 99381 removed as not used
//function GPEControl_ondblclick(control)
//{
//    // If on current selected item then return so normal mouse handle is enabled for control 20Mar14 XN
//    var selectedControl = $(GPEselectedCell).children();
//    if (selectedControl.attr('id') != control.id)
//        GPESelectCell($(control.parentNode));

//    // begin editing new cell
//    beginEdit(false);

//    window.event.cancelBubble = true;   // Prevent bubbling up the double click (else end up with extra single click) 20Mar14 XN
//    window.event.returnValue  = false;
//}

function GPEControl_onnouseup(control)
{
    // If input and enabled then select text in control 3Mar16 XN 99381
    if (typeof document.selection != "undefined" && document.selection.type == "Text" && document.selection.createRange().text == '' && $(GPEselectedCell).last().prop('disabled') == false)
    {
        $(GPEselectedCell).last().select();
    }

    window.event.cancelBubble = true;   // Prevent bubbling up the double click (else end up with extra single click) 20Mar14 XN
    window.event.returnValue  = false;
}

function beginEdit(autoSelectText)
{
    // var control = $(GPEselectedCell).children();     3Mar16 XN 99381
    var control = $(GPEselectedCell).children('input, textarea');
    if (control.length != 0 && control.prop('readonly') == true)
    {
        if (control.prop('disabled') == false)
        {
            if (control.prop('type') == 'submit')
                control.click();
            else if (control.attr('lookupOnly') != undefined)
                DoLookup($("[id*='QuesScrl'].selected"));
            else
            {
                control.removeProp('readonly');
                if (autoSelectText)
                    control.select();

                var topScrollPos = GPEcontainer.scrollTop;      //  15Oct14 XN 95914, 99382 Prevent jumping on screen in ie11 (seem to need to reset the scroll as focus causes it to jump to 0)
                
                control.focus();

                if (topScrollPos != GPEcontainer.scrollTop)     //  15Oct14 XN 95914, 99382 Prevent jumping on screen in ie11 (seem to need to reset the scroll as focus causes it to jump to 0)
                    GPEcontainer.scrollTop = topScrollPos;
            }

            // Show date/time picker for date data type
            if (control.attr('ctrlType') == 'Date')
                $("#" + control.attr("id")).datepicker({ dateFormat: "dd/mm/yy" });   // yy - is 4digit year in jquery
        }
        else //if (control.attr('lookupOnly') != undefined) 86461 XN 18Mar14 always display error message even it item is not lookup
            alert('Field cannot be edited');
    }
}

function endEdit()
{
    //var control = $(GPEselectedCell).children(); 3Mar16 XN 99381
    var control = $(GPEselectedCell).children('input, textarea');
    if (control.length != 0 && control.prop('disabled') == false)
    {
        if (document.selection)
            document.selection.empty();

        // 2Mar16 XN 99381 simple edit mode
        if (!simpleEditMode)
            control.prop('readonly', 'readonly');

        // onchnage event does not always fire so manualy force it
        if (control[0].value != control[0].defaultValue)
            control.change();
    }
}

// Called to display a lookup for the control (won't display if the control is not setup for lookup)
// control - Control to display lookup for
// keypress- key the user enter to display the look (used to auto select item in them list 3Mar16 XN 99381
function DoLookup(control, keypress)
{
    control = $(control);
    var lookupPageURL           = control.attr('LookupPage');
    var lookupResultIndex       = parseInt(control.attr('LookupResultIndex'));
    var lookupResultSeparator   = control.attr('LookupResultSeparator');

    //if (lookupPageURL != undefined)
    if (lookupPageURL != undefined && control.prop('readonly') == true)
    {
        if (control.prop('disabled') == false) 
        {
            // if ShowProgressMsg function exist display, as cursor dose not work think as function has not exited yet 3Mar16 XN 99381
            if (typeof ShowProgressMsg === 'function')
                ShowProgressMsg();

            lookupPageURL = ReplaceString("..\\" + lookupPageURL, "{currentValue}", URLEscape(control.val()));
            lookupPageURL = ReplaceString(lookupPageURL, "{typedText}", (keypress != undefined && keypress.match('[a-z,0-9]')) ? keypress : ' '); // Added auto select key 3Mar16 XN 99381

            var result = window.showModalDialog(lookupPageURL, undefined, 'center:yes; status:off');
            if (result == 'logoutFromActivityTimeout') {
                result = null;
                window.close();
                window.parent.close();
                window.parent.ICWWindow().Exit();
            }

            // if HideProgressMsg function exist hide, as cursor dose not work think as function has not exited yet 3Mar16 XN 99381
            if (typeof HideProgressMsg === 'function')
                HideProgressMsg();

            if (result != null)
            {
                if (lookupResultSeparator != undefined)
                    control.val(result.split(lookupResultSeparator)[lookupResultIndex]);
                else
                    control.val(result);
                setIsPageDirty();
            }
        }
        else
            alert('Field cannot be edited');
    }
}

// Returns if the sepcified row is visible, and is in the current scroll window
function ScrolCellInToView(cell) 
{
    var header = $('thead:first', GPEcontainer);
    var headerHeight = 0;
    if (header.length > 0)
        headerHeight = header[0].offsetHeight;

    // Get the position of the to and bottom of the row (relative to the top of the grid control)
    var rowTopPosition    = cell.offsetTop - GPEcontainer.scrollTop - headerHeight;
    var rowBottomPosition = cell.offsetTop + cell.offsetHeight - GPEcontainer.scrollTop;
    if (rowTopPosition < 0)
        $(GPEcontainer).scrollTop(cell.offsetTop - headerHeight);
    else if (rowBottomPosition > GPEcontainer.clientHeight) 
    {
        var difference = rowBottomPosition - GPEcontainer.clientHeight;
        $(GPEcontainer).scrollTop( $(GPEcontainer).scrollTop() + difference );  //  15Oct14 XN 95914, 99382 Corrected calculation of scroll position
    }

    var fixedLeftColumnFirst = $('tr:last .fixedLeft:first', GPEcontainer)[0];
    var fixedLeftColumnLast  = $('tr:last .fixedLeft:last',  GPEcontainer)[0];
    
    if (fixedLeftColumnFirst == undefined)
        return; // sanity check

    var fixedLeftCellWidth   = fixedLeftColumnLast.offsetLeft - fixedLeftColumnFirst.offsetLeft + fixedLeftColumnLast.offsetWidth;

    var cellLeftPosition  = cell.offsetLeft - GPEcontainer.scrollLeft - fixedLeftCellWidth;
    var cellRightPosition = cell.offsetLeft + cell.offsetWidth - GPEcontainer.scrollLeft;
    if (cellLeftPosition < 0)
        $(GPEcontainer).scrollLeft(cell.offsetLeft - fixedLeftCellWidth);
    else if (cellRightPosition > GPEcontainer.clientWidth)
        $(GPEcontainer).scrollLeft(Math.min(cellLeftPosition, cell.offsetLeft + fixedLeftCellWidth - GPEcontainer.clientWidth));

    // Update scroll pos (else will fail to show selected row after post back)
    GPElastScrollPos = GPEcontainer.scrollTop;
}

function GPESelectCell(cell, scrollInToView)
{
    if (cell == undefined || cell.length == 0)
        return;

    endEdit();

    $(GPEselectedCell).removeClass("selected");
    var control = $(GPEselectedCell).children('input, textarea');
    control.removeClass("selected");
    var originalId = control.attr('id');

    var control = cell.children('input, textarea');
    control.addClass("selected");
    cell.addClass   ("selected");

    var topScrollPos = GPEcontainer.scrollTop;  //  15Oct14 XN 95914, 99382 Prevent jumping on screen in ie11 (seem to need to reset the scroll as focus causes it to jump to 0)

    // 2Mar16 XN 99381 simple edit mode
    if (simpleEditMode && control.prop('disabled') == false && control.attr('lookupOnly') == undefined)
        control.focus();
    else
        cell.focus();

    if (topScrollPos != GPEcontainer.scrollTop) //  15Oct14 XN 95914, 99382 Prevent jumping on screen in ie11 (seem to need to reset the scroll as focus causes it to jump to 0)
        GPEcontainer.scrollTop = topScrollPos;

    GPEselectedCell = cell;
    GPEhfSelectedCell.val(control.attr('id'));

    if (scrollInToView == undefined || scrollInToView == true)
        ScrolCellInToView(cell[0]);
}

function GPEMoveSelection(x,y)
{
    var rows = GPEtable.children('tr:not([isSpacer])');

    var rowIndex = rows.index(GPEselectedCell.parent());
    var colIndex = rows.eq(rowIndex).children('td').index(GPEselectedCell);

    rowIndex += y;
    if (rowIndex < 0)
        rowIndex = 0;
    if (rowIndex >= rows.length)
        rowIndex = rows.length - 1;

    colIndex += x;
    if (colIndex < 2)   
        colIndex = 2;   // First row description, 2nd Madatory field
    if (colIndex >= rows.first().children('td').length)
        colIndex = rows.first().children('td').length - 1;

    var newSelectedCell = rows.eq(rowIndex).children('td').eq(colIndex);
    GPESelectCell(newSelectedCell);
}

// Returns if using simple edit mode for the selected cell
// 2Mar16 XN 99381 simple edit mode
function UseSimpleEditModeForSelectedCell()
{
    if(simpleEditMode)
    {
        var control = $(GPEselectedCell).children('input, textarea');
        return simpleEditMode && control.prop('disabled') == false && control.attr('lookupOnly') == undefined;
    }
    else
        return false;
}
