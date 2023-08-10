var columnIngDBNames;
//var editedCellPreviousValue;  TFS31092 3Apr12 XN removed dead code
var po4ColumnIndex;
var volumeColumnIndex;
var multiplyByMin = 1;      // Min and max value in multiply by form
var multiplyByMax = 200;    // (if change these values need to update MultiplyBy_OnClick)
var hasSaved      = false;  // TFS30354  Due to problems with authorisation state on worklist not updating this line is not really needed and could be removed
var overagesAndVolumes;
var editing       = false;  // If currently editing a cell TFS31092 3Apr12 XN Added
var beginInputMouseDown = false;  // Set to true the first time the user clicks in the grid input, so known when to do full select and when to do partial (TFS31092 13Apr12 XN)
    
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
        }
    });
    return result;
}                

function getRowByPNCode(PNCode)
{
    return $('#PNGrid tbody tr[PNCode="' + PNCode + '"]');
}

function selectCell(cell)
{
    // Set the cell as active class
    $("#PNGrid tbody td.active").removeClass("active");
    $(cell).addClass("active");
    //$("#PNGrid").focus();

    // Set the cell as having focus without loosing scroll position
    var scrollPosition = -1;
    if ($(cell).parent().parent().length > 0)
        scrollPosition = $(cell).parent().parent()[0].scrollLeft;    
    cell.focus();
    if (scrollPosition != -1)
        $('#gridPanel').scrollLeft(scrollPosition);
    
    // Store details of selected row in the hidden field
    var rowPNCode = $(cell).parent().attr('PNCode');
    if (rowPNCode != undefined)
        $('#hfCurrentRowPNCode').val(rowPNCode);
    
    var colIndex = getCellIndex(cell).col
    $('#hfCurrentColDBName').val(columnIngDBNames[colIndex]);

    ensureCellIsInView(cell);
}

function ensureCellIsInView(cell)
{
    var table       = cell.parentNode.parentNode;
    var tableHeader = $('thead tr:eq(0)', tableHeader)[0];

    var colLeftPosition   = cell.offsetLeft - table.scrollLeft;
    var colRightPostion   = colLeftPosition + cell.offsetWidth;
    var rowTopPosition    = cell.offsetTop - table.scrollTop - tableHeader.offsetHeight;
    var rowBottomPosition = rowTopPosition + cell.offsetHeight;

    var scrollLeft = undefined;
    if (colRightPostion > table.clientWidth)
        scrollLeft = cell.offsetLeft + cell.offsetWidth - table.clientWidth;
    else if (colLeftPosition < 0)
        scrollLeft = cell.offsetLeft;

    if (scrollLeft != undefined)
        $('#gridPanel').scrollLeft(scrollLeft);

    var scrollTop = undefined;
    if (rowBottomPosition > table.clientHeight)                
        scrollTop = cell.offsetTop - tableHeader.offsetHeight + cell.offsetHeight;
    else if (rowTopPosition < 0)
        scrollTop = cell.offsetTop;

    if (scrollTop != undefined)
        $('#gridPanel').scrollTop(scrollTop);
}

function beginEditCell(input) 
{
    var row = $(input.parentNode.parentNode);
    var jinput = $(input);

    // perform action on row type
    switch (row.attr("RowType")) 
    {
        case "product":
            // If input is on product line that is not read only then store the value before change incase need to cancel
            if (jinput.prop("readonly") == false) 
            {
                jinput.attr("PreChangeValue", jinput.val());
                if (!editing)           // TFS31267 5Apr12 XN If dbl click in cell on 2nd click prevent reselecting all.
                    jinput.select();
                editing = true;                    
            }
            break;
        case "total":
            // Should launch wizard, but will do at later stage
            break;
    }
}

function endEditCell(input) 
{
    // TFS31092 13Apr12 XN Moved early on so ensures always gets out of eidt mode
    editing             = false;
    beginInputMouseDown = false;
    
    if (input == undefined)
        return;

    var cell = input.parentNode;
    var row = cell.parentNode;
    var cellIndex = getCellIndex(cell);
    var preChangeValue = $(input).attr('PreChangeValue');

    //editing = false;    // TFS31092 13Apr12 XN Moved further up

    // Clear selected text
    if (document.selection)
        document.selection.empty();

    // If no change then end
    // TFS31267 5Apr12 XN when escape from edited cell correctly reselect the cell
    //if ((preChangeValue == undefined) || (preChangeValue == input.value))     // TFS31092 13Apr12 XN Made cancelling of update less stringent as safer
    if (preChangeValue == input.value) 
    {
        // TFS31092 13Apr12 XN removed reselection as should be handled higher up
        //var selectedCell = $(document.activeElement).parent();
        //if (selectedCell.length == 0 || selectedCell[0].nodeName != 'TD')
        //    selectedCell = getSelectedCell();
        //selectCell(selectedCell[0]);
        return;
    }

    // Request ID                
    var requestID = parseInt($('#hfRequestID').val());
    if (isNaN(requestID))
        requestID = null;

    var parameters =
            {
                sessionID       : parseInt($('body').attr('SessionID')),
                siteID          : parseInt($('body').attr('SiteID')),
                PNCode          : row.attributes['PNCode'].value,
                value           : input.value,
                ingDBName       : columnIngDBNames[cellIndex.col],
                viewAndAdjustStr: $('#hfViewAndAdjustInfo').val(),
                requestID       : requestID,
                PNProcessorXML  : $('#hfProcessor').val()       //  03Apr13 XN Send cached processor to edit cell method
            };

    var result = PostServerMessage("ICW_PNViewAndAdjust.aspx/EditedCell", JSON.stringify(parameters));

    if ((result == undefined) || (result.d == "")) 
    {
        if (preChangeValue != '')
            input.value = preChangeValue;
    }
    else 
    {
        var data = JSON.parse(result.d);

        UpdateGrid(data.Regimen);
        SetStatus(data.Status);

        //  03Apr13 XN update cached processor
        $('#hfProcessor'    ).val(data.PNProcessorXML);
        $('#hfProcessorCopy').val(data.PNProcessorCopyXML);

        if (data.askAdjustPNCode != undefined)
            __doPostBack('upAskAdjustMsgBox', "AskAdjust:" + data.askAdjustPNCode);
    }
}

function getCaretPosition (oField) 
{    
    var iCaretPos = 0;    
    
    // Set focus on the element     
    oField.focus ();      
    
    // To get cursor position, get empty selection range     
    var oSel = document.selection.createRange ();      
    
    // Move selection start to 0 position     
    oSel.moveStart ('character', -oField.value.length);      
    
    // The caret position is selection length     
    iCaretPos = oSel.text.length;   

    return (iCaretPos);
}

function getSelectedCell()
{
    return $("#PNGrid tbody td.active");
}

function getSelectedInput()
{
    return $("#PNGrid tbody td.active input");
}

function getCellIndex(cell)
{
    if ($(cell).length == 0)
        return undefined;
    else
        return { col: $(cell)[0].cellIndex, row: $(cell).parent("tr")[0].sectionRowIndex };
}

function getCell(col, row)
{
    return $("#PNGrid tbody tr:eq(" + row.toString() + ") td:eq(" + col.toString() + ")")[0];
}

// Called when key pressed in PN grid
// Handles cursour movment around grid, and in cells
// Handles putting cell into and out of edit mode (via Enter)
// Handles canceling edit via escape
// Handles putting cell into edit mode number key press
// TFS31092 13Apr12 XN Major updates to let grid navigation work better.
function PNGrid_onkeydown(event) 
{
    switch (event.keyCode)  // Check which key was pressed
    {
        case 37:    // left
            var selectedCell = getSelectedCell();
            var pos          = getCellIndex(selectedCell);  // Get current cell done here as endEditCell might delete the cell
            if (pos == undefined)   // TFS31032  2Apr12  XN  Added check as after delete selected item may not exists
                return;
                
            // If editing then check if moving to next cell
            if (editing)
            {
                var selectedInput = $('input', selectedCell);
                if (selectedInput.length > 0)
                {
                    if (getCaretPosition(selectedInput[0]) != 0)
                        return;                                     // Still moving within the cell itself                    
                    endEditCell(selectedInput[0]);                    
                }
            }
            
            if (pos.col > 0)
                pos.col -= 1;
            var cell = getCell(pos.col, pos.row)
            selectCell(cell);

            // prevent postback of form
            window.event.cancelBubble = true; 
            window.event.returnValue = false;
            break;
        case 38:    // up key
            var selectedCell = getSelectedCell();
            var pos          = getCellIndex(selectedCell);  // Get current cell done here as endEditCell might delete the cell
            if (pos == undefined)   // TFS31032  2Apr12  XN  Added check as after delete selected item may not exists
                return;

            // If editing then end edit
            if (editing)
            {
                var selectedInput = $('input', selectedCell);
                if (selectedInput.length > 0)
                    endEditCell(selectedInput[0]);
            }

            if (pos.row > 0)
                pos.row -= 1;
            var cell = getCell(pos.col, pos.row)
            selectCell(cell);

            // prevent postback of form
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;
        case 39:    // right
            var selectedCell = getSelectedCell();
            var pos          = getCellIndex(selectedCell);  // Get current cell done here as endEditCell might delete the cell
            if (pos == undefined)   // TFS31032  2Apr12  XN  Added check as after delete selected item may not exists
                return;

            // If editing then check if moving to next cell or not
            if (editing)
            {
                var selectedInput = $('input', selectedCell);
                if (selectedInput.length > 0)
                {
                    var startPos = getCaretPosition(selectedInput[0], 'start');
                    var endPos   = document.selection.createRange().text.length;    // Check length of selected text, So if whole input is selected, and press right key moves to end rather than jumping to next cell
                    
                    if (startPos != selectedInput.val().length || endPos != 0)
                        return;                                     // Still moving within the cell itself                    
                    endEditCell(selectedInput[0]);                    
                }
            }

            if ((pos.col + 1) < getColumnCount())
                pos.col += 1;
            var cell = getCell(pos.col, pos.row)
            selectCell(cell);

            // prevent postback of form
            window.event.cancelBubble = true; 
            window.event.returnValue = false;
            break;
        case 40:    // down key
            var selectedCell = getSelectedCell();
            var pos          = getCellIndex(selectedCell);  // Get current cell done here as endEditCell might delete the cell
            if (pos == undefined)   // TFS31032  2Apr12  XN  Added check as after delete selected item may not exists
                return;

            // If editing then end edit
            if (editing)
            {
                var selectedInput = $('input', selectedCell);
                if (selectedInput.length > 0)
                    endEditCell(selectedInput[0]);
            }

            if ((pos.row + 1) < getRowCount())
                pos.row += 1;
            var cell = getCell(pos.col, pos.row)
            selectCell(cell);

            // prevent postback of form
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;
        case 13:    // Return
            var selectedCell = getSelectedCell();
            if (editing)
            {
                var selectedInput = $('INPUT', selectedCell);
                if (selectedInput.length > 0)
                    endEditCell(selectedInput[0]);  // take out of edit mode
            }
            else if (selectedCell.parent().attr('RowType') == 'total') 
            {
                // Enter key pressed on total line so launch add by ingredient wizard                
//                var pos = getCellIndex(selectedCell);
//                var column = $('#PNGrid col').eq(pos.col).filter('[colType="ingredient"]');
//                if (column.length > 0)
//                {
//                    var rowTotalOrPerKgType = (selectedCell.parent().attr('PNCode').toLowerCase() == 'totalinml') ? 'Total' : 'PerKg';    // TFS31243 5Apr12 XN When add by clicking on total row either add by total or per kg depending on total row selected
//                    __doPostBack('upWizard', 'AddByIngredient:' + column.attr('title') + ':' + rowTotalOrPerKgType + ':false');
//                } 
                editTotalCell(selectedCell);    // 12Sep14 95898 refactored into single function so can call from double click
            }
            else
            {
                // Enter key pressed on normal with value so begin edit
                var selectedInput = $('INPUT', selectedCell);
                if (selectedInput.length > 0 && !selectedInput[0].readOnly)
                    beginEditCell(selectedInput[0]);
            }
                                        
            // prevent postback of form
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;
        case 27:    // Esc          TFS31092 3Apr12 XN Added handling of escape
            var selectedCell = getSelectedCell();
            
            if (editing) 
            {
                var selectedInput = $('input', selectedCell);
                if (selectedInput.length > 0)
                {
                    var preChangeValue = selectedInput.attr('PreChangeValue');
                    if (preChangeValue != undefined && preChangeValue != '')
                        selectedInput.val(preChangeValue);
                        
                    endEditCell(selectedInput[0]);
                }
                
                // prevent postback of form
                window.event.cancelBubble = true;
                window.event.returnValue = false;
            }
            break;
        case 190:   // dot
        case 48:    // 0
        case 49:    // 1                                        
        case 50:    // 2
        case 51:    // 3                                   
        case 52:    // 4
        case 53:    // 5                                    
        case 54:    // 6
        case 55:    // 7                                   
        case 56:    // 8
        case 57:    // 9
        case 110:   // number keypad dot      TFS31092 3Apr12 XN Added handling of number keypad
        case 96:    // number keypad 0
        case 97:    // number keypad 1                                        
        case 98:    // number keypad 2
        case 99:    // number keypad 3                                   
        case 100:   // number keypad 4
        case 101:   // number keypad 5                                    
        case 102:   // number keypad 6
        case 103:   // number keypad 7                                   
        case 104:   // number keypad 8
        case 105:   // number keypad 9
            if (!editing)
            {
                var selectedInput = getSelectedInput();
                if (selectedInput.length > 0 && !selectedInput[0].readOnly)
                    beginEditCell(selectedInput[0]);
            }
            break;
            
        case 9:   // Tab
            // Disable as not handled by the logic for the grid
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;
    }
}

// Updates grid with jsonData
// (will either add or replace row)
// See ICW_PNViewAndAdjust.aspx.cs for details
// TFS31092 13Apr12 XN Major updates to how editing of and selection of cells works 
function UpdateGrid(jsonData) 
{
    var tableBody = $('#PNGrid tbody');
    var data = JSON.parse(jsonData);

    // Get currently selected item so can select it again at the end. 
    var selectedCellIndex = getCellIndex(getSelectedCell());
    
    // Take copy of overage and volume data
    overagesAndVolumes = data.OverageAndVolume;

    // Go through products to remove from the regimen
    for (var r = 0; r < data.Remove.length; r++) {
        var oldRow = getRowByPNCode(data.Remove[r]);
        if (oldRow != undefined)
            oldRow.remove();
    }

    if (data.Rows.length > 0)
        $('span[id="Edited"]', tableBody).html('&nbsp;');

    // Add or update rows in the grid
    for (var r = 0; r < data.Rows.length; r++) 
    {
        var newRow = data.Rows[r];
        var PNCode = $(newRow).attr('PNCode');
        var sortIndex = $(newRow).attr('SortIndex');
        var type = $(newRow).attr('RowType')

        var oldRow = getRowByPNCode(PNCode);

        if (oldRow.length > 0)
            oldRow.replaceWith(newRow);  // Replace existing row
        else 
        {
            // Add row                
            // Find position to add the row
            var rowsBefore = tableBody.children('tr').filter(function() 
                {
                    return parseInt(this.attributes['SortIndex'].value) > sortIndex;
                });

            // Insert or update row                       
            if (rowsBefore.length > 0)
                $(rowsBefore[0]).before(newRow);
            else
                tableBody.append(newRow);
        }

        // set the row event handlers
        var row = getRowByPNCode(PNCode);        
        $('td:eq(0)', row).mousedown        (function() { selectCell(this); });                                         // Handle clicking on PN product name column
        $('input',    row).bind("dragstart", function() { return false; });                                             // Prevent dragging and droppping in from the input 
        $('input',    row).focusout         (function() { if (editing && !this.readOnly) { endEditCell(this); } });     // When cell looses focus end the edit
        $('input',    row).mousedown        (function()                                                                 // Start editing in cell
                                                {
                                                    var input = getSelectedInput();
                                                    if (input[0] != this)                   // Only change edit and selected mode if current cell has changed
                                                    {                                                    
                                                        selectCell(this.parentNode);        // Select new cell (focusout will fire on currently edited cell ending the edit)
                                                        if (!this.readOnly) 
                                                        {
                                                            beginEditCell(this);            // Start editing cell
                                                            beginInputMouseDown = true;     // Allow mouse up to select all cell content (can't do here as release of mouse end edit)
                                                        }
                                                        else
                                                            return false;                   // 32007 XN 20Nov12 disable carat in non-editable fields
                                                    } 
                                                });   
        $('input',    row).mouseup          (function() 
                                                { 
                                                    if (beginInputMouseDown && editing)         // If input has just been placed in edit mode then select all cell text
                                                    { 
                                                        beginInputMouseDown = false; 
                                                        if (getSelectedInput().length > 0) 
                                                            getSelectedInput()[0].select();     // Select text on currently selected cell (rather than this input), as may mouse down on one item and mouse up in another
                                                    }
                                                });

        if (type == 'total') 
            $('input', row).dblclick(function() { editTotalCell($(this).parent()); });  // 12Sep14 XN 95898 double click on total cells will display 

        // Setup volume popup
        if (volumeColumnIndex > -1 && type == 'product') 
        {
            //$('td', row).eq(volumeColumnIndex).tooltip({ TFS29763 28Nov12 XN slight improvment to tooltip display
            $('td:eq(' + volumeColumnIndex + ') input', row).tooltip({
                delay: 0,
                track: false,
                fade: 250,
                extraClass: "pretty",
                bodyHandler: function() { return getVolumeTooltip($(this).parent().parent()) }
            });
        }

        // If has phosphate then setup the popup   TFS29763 28Nov12 XN Only display tooltip if the cell has a PO4 value
        //if (po4ColumnIndex > -1)  
        if (po4ColumnIndex > -1 && row.attr('Phosphate_mmol') != '' && (type == 'product' || type == 'total')) 
        {
            //$('td', row).eq(po4ColumnIndex).tooltip({
            $('td:eq(' + po4ColumnIndex + ') input', row).tooltip({
                delay: 0,
                track: false,
                fade: 250,
                extraClass: "pretty",
                bodyHandler: function() { return getPhosphateTooltip($(this).parent().parent()) }
            });
        }
    }

    // Reselect cell (this maybe different from the selected cell if user has clicked away)
    if (selectedCellIndex != undefined) 
        selectCell(getCell(selectedCellIndex.col, selectedCellIndex.row));
}    

// Returns contents of phosphateTooltip div having replaced the phosphate values with the ones in the row
// The tooltip displays total organic, inorganic and total phosphate content.
// Assuems the row has attributes like Phosphate_mmol="2.5" PhosphateInorganic_mmol="1.2" PhosphateOrganic_mmol="32.2"
// If one of the values is missing then it is replaced with "--" in the popup
function getPhosphateTooltip(row) 
{
    // Get the cells where the phosphate values will be placed form the popup        
    var cells = $('#phosphateTooltip td[id]');
    var count = cells.length;

    for (var c = 0; c < count; c++) 
    {
        // Get the cell and the phosphage value from the row
        var cell = cells.eq(c);
        var dbName = cell.attr('id');
        var value = $(row).attr(dbName);

        // Set the value replacing with '--' if not present
        if (value == "") 
        {
            cell.text("--");
            cell.next().hide();
        }
        else 
        {
            cell.text(value);
            cell.next().show();
        }
    }

    // Returns the div content
    return $('#phosphateTooltip').html();
}

// Returns contents of volumeTooltip div having replaced the values with the ones in the row
// The tooltip displays volume (volume full), overage for product (overage full).
// If one of the values is missing then it is replaced with empty string in the popup
// The volume data is held in javascript variable overagesAndVolumes (page level) 
// This is update from the UpdateGrid Method
function getVolumeTooltip(row) {
    var volumeTooltip = $('#volumeTooltip');

    if (row == undefined || overagesAndVolumes == undefined)
        return;

    $('#ProductName', volumeTooltip).text($("td:eq(0)", row).text());
    var PNCode = $(row).attr('PNCode');

    var overageAndVolume;
    for (var r = 0; r < overagesAndVolumes.Data.length; r++) {
        if (overagesAndVolumes.Data[r].PNCode == PNCode) {
            overageAndVolume = overagesAndVolumes.Data[r];
            break;
        }
    }

    if (overageAndVolume == undefined)
        return;

    // we dont have access to the vb code here so manually replicate the conversion from 24 to 48 hour values
    // as a reminder we double up the volumnes but not the overage
    var multiplier = overagesAndVolumes.Supply48Hrs ? 2 : 1;
    var vol = overageAndVolume.Vol * multiplier;
    var volFull = overageAndVolume.VolFull * multiplier;
    var overage = overageAndVolume.Overage * 1;
    var overageFull = overageAndVolume.OverageFull * 1;
    var totalVol = vol + overage;
    var totalVolFull = volFull + overageFull;

    $('td[id="Vol"]', volumeTooltip)
        .text(vol.toFixed(2));
    $('td[id="VolFull"]', volumeTooltip)
        .text(overageAndVolume.VolFull == null || overageAndVolume.VolFull === "" ? "" : volFull.toFixed(6));
    $('td[id="Overage"]', volumeTooltip)
        .text(overage.toFixed(2));
    $('td[id="OverageFull"]', volumeTooltip)
        .text(overageAndVolume.OverageFull == null || overageAndVolume.OverageFull === "" ? "" : overageFull.toFixed(6));
    $('td[id="VolWithOverage"]', volumeTooltip)
        .text(totalVol.toFixed(2));
    $('td[id="VolWithOverageFull"]', volumeTooltip)
        .text(overageAndVolume.VolWithOverageFull == null || overageAndVolume.VolWithOverageFull === "" ? "" : totalVolFull.toFixed(6));

    if (overagesAndVolumes.Supply48Hrs)
        $('span[tag="Supply48Hr"]', volumeTooltip).show();
    else
        $('span[tag="Supply48Hr"]', volumeTooltip).hide();

    if (overageAndVolume.VolFull == '')
        $('td[tag="VolFullUnits"]', volumeTooltip).hide();
    else
        $('td[tag="VolFullUnits"]', volumeTooltip).show();

    if (overageAndVolume.OverageFull == '')
        $('td[tag="OverageFullUnits"]', volumeTooltip).hide();
    else
        $('td[tag="OverageFullUnits"]', volumeTooltip).show();

    if (overageAndVolume.VolWithOverageFull == '')
        $('td[tag="VolWithOverageFullUnits"]', volumeTooltip).hide();
    else
        $('td[tag="VolWithOverageFullUnits"]', volumeTooltip).show();

    // Returns the div content
    return volumeTooltip.html();
}

function getColumnCount()
{
    return $('#PNGrid col').length;
}

function getRowCount()
{
    return $('#PNGrid tbody tr').length;
}

function PNGrid_onclickheader(header)
{
    var ingDBName = $('#PNGrid col').eq(header.cellIndex).attr('title');
    __doPostBack('upWizard', 'AddByIngredient:' + ingDBName + ':Total:true');    // TFS31243 5Apr12 XN When add by clicking header column ensure add by total row
}

function PNSelectProduct_validation(source, clientside_arguments)
{
    clientside_arguments.IsValid = (getSelectedRowIndex('gridSelectProduct') > -1) && ($('#wizardAddProduct_selectProductCtrl_hfSelectedProductPNCode').val() != '');
}

function PNSelectGlucoseProduct_validation(source, clientside_arguments)
{
    clientside_arguments.IsValid = (getSelectedRowIndex('gridSelectGlucoseProduct') > -1) && ($('#wizardAddProduct_selectGlucoseProductCtrl_hfSelectedProductPNCode_hfSelectedProductPNCode').val() != '');
}

function PNSelectIngredient_validation(source, clientside_arguments)
{
    clientside_arguments.IsValid = (getSelectedRowIndex('gridSelectIngredient') > -1) && ($('#wizardAddProduct_selectIngredientWithQuantityCtrl_hfSelectedIngredientDBName').val() != '');
}

function PNSelectStandardRegimen_validation(source, clientside_arguments)
{
    clientside_arguments.IsValid = (getSelectedRowIndex('#wizardAddProduct_selectStandardRegimenCtrl_gridSelectStandardRegimen') > -1);
}

function pharmacygridcontrol_onselectrow(controlID, rowindex)
{
    if (controlID == 'gridSelectProduct')
        $('#wizardAddProduct_selectProductCtrl_hfSelectedProductPNCode').val(getRow(controlID, rowindex).attr('PNCode'));
    else if (controlID == 'gridSelectGlucoseProduct') 
    {
        var pncode = getRow(controlID, rowindex).attr('PNCode');
        $('#wizardAddProduct_selectGlucoseProductCtrl_hfSelectedProductPNCode').val(pncode);
        
        //  21Mar13 XN  If user selects no glucose or water mix then hide mix button. (59607)
        $('#wizardAddProduct_selectGlucoseProductCtrl_cbMixing').visible(pncode != '---');
        $('label[for="wizardAddProduct_selectGlucoseProductCtrl_cbMixing"]').visible(pncode != '---');
    }
    else if (controlID == 'gridSelectIngredient')
        $('#wizardAddProduct_selectIngredientWithQuantityCtrl_hfSelectedIngredientDBName').val(getRow(controlID, rowindex).attr('DBName'));
    else if (controlID == 'gridSelectStandardRegimen')
        $('#wizardAddProduct_selectStandardRegimenCtrl_hfSelectedStandardRegimenID').val(getRow(controlID, rowindex).attr('StandardRegimenID'));
}

function form_onload(clientWidth)
{
    columnIngDBNames = new Array();

    // Setup update message
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(ShowProgressMsg);
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest  (HideProgressMsg);   

    // Store ingredient DBNames for all columns (stored in title attribute) in the columnIngDBNames
    var gridColumns = $('#PNGrid col');
    var colCount = gridColumns.length;
    for (var c = 0; c < colCount; c++)
        columnIngDBNames.push(gridColumns.eq(c)[0].title);

    // make note of the important column index
    var PO4Column    = $(gridColumns).filter("[PO4='true']");
    po4ColumnIndex   = $(gridColumns).index(PO4Column);
    var volumeColumn = $(gridColumns).filter("[Volume='true']");
    volumeColumnIndex= $(gridColumns).index(volumeColumn);

    // Clear current node
    $('#hfCurrentRowPNCode').val('');
    
    if (clientWidth != undefined)
    {
        // Determine maxWidth supported by screen
        var maxWidth;
        if (screen.width <= 1024)
            maxWidth = 1024;
        else if (screen.width <= 1152)
            maxWidth = 1150;
        else if (screen.width <= 1280)
            maxWidth = 1280;
        else
            maxWidth = 1400;

        // limit width to either maxWidth or required width
        var width = (maxWidth > clientWidth + 11) ? clientWidth + 11 : maxWidth;
        window.dialogWidth = width + "px";
        
        var height = 700;
        window.dialogHeight = height + "px";   
    }

}
function PNRegimenInfoView(sessionID, siteID,regimen_requstID) {
    var result = window.showModalDialog('PNRegimenDetails.aspx?SessionID=' + sessionID + '&SiteID=' + siteID + '&RequestID=' + regimen_requstID + '&Tab=Info', null, 'status:no;dialogHeight:575px;dialogWidth:600px;center:yes;');
    if (result == 'logoutFromActivityTimeout') {
        window.returnValue = 'logoutFromActivityTimeout';
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (result == true) { { __doPostBack('upButtonsAndPatientDetails', 'RefreshPatientDetails'); } }; $('#PNGrid').focus();
}

function PNRegimenRequirementsView(sessionID, siteID, regimen_requstID) {
    var result = window.showModalDialog('PNRegimenDetails.aspx?SessionID=' + sessionID + '&SiteID=' + siteID + '&RequestID=' + regimen_requstID + '&Tab=Requirements', null, 'status:no;dialogHeight:575px;dialogWidth:600px;center:yes;');
    if (result == 'logoutFromActivityTimeout') {
        window.returnValue = 'logoutFromActivityTimeout';
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (result == true) { { __doPostBack('upButtonsAndPatientDetails', 'RefreshPatientDetails'); } }; $('#PNGrid').focus();
}


function askIfExit() 
{
    // If exit message box is open then close that rather than redisplaying 
    if ($('#exitMsgBoxEvent').length > 0) 
    {
        $("#exitMsgBoxEvent").dialog("close");
        return false;
    }

    if ($('#lbSavedStatus').text() == 'Edited') {
        var tempDiv = '<div id="exitMsgBoxEvent" style="font-size:11px">Are you sure you want to navigate away from this page?<br /><br />If you press OK, your latest changes will be lost!<br /><br />Press OK to continue, or Cancel to stay on the current page.</div>';
        $(tempDiv).dialog({
            modal: true,
            buttons:
            {
                'OK': function () { $(this).dialog("close"); window.close(); },
                'Cancel': function () { $(this).dialog("close"); }
            },
            title: 'Exit',
            closeOnEscape: false,
            width: 400,
            resizable: false,
            zIndex: 9002,  // To put it infront of popup
            appendTo: 'form',
            focus: function (type, data) { $(this).siblings('.ui-dialog-buttonpane').find('button:eq(1)').focus(); },
            open: function () {
                var buttons = $('.ui-dialog-buttonpane button', $(this).parent());
                buttons.eq(1).css({ width: '85px' });   // Expand size 
            },
            close: function (type, data) {
                $('#exitMsgBoxEvent').remove(); // Ensure message box is removed 
                $('#PNGrid').focus();
            }
        });
    }
    else {
        window.close();
    }
}

function form_onbeforeunload() 
{
    if (event.clientY < 0 && $('#lbSavedStatus').text() == 'Edited')
        event.returnValue = 'If you press OK, your latest changes will be lost!';
}        

function form_unload()
{
    // Cleand up the form
    var parameters =
        {
            sessionID       : parseInt($('body').attr('SessionID')),
            requestID       : $('#hfRequestID').val() == '' ? null : parseInt($('#hfRequestID').val())
        };
    var result = PostServerMessage("ICW_PNViewAndAdjust.aspx/CleanUp", JSON.stringify(parameters));
window.returnValue = parameters.requestID;
}

function form_onkeydown(event) 
{
    // TFS31227 12Apr12 XN 
    // For usability if key press is picked up when form element is in focus,
    // and either the jquery ui dialog, or wizard is open, 
    // the shift focus to the visible form
    if ($('.ui-dialog').is(':visible') && document.activeElement.className.indexOf('ui-') == -1 && document.activeElement.nodeName.toUpperCase() != 'BUTTON')
        $('.ui-dialog-buttonpane button:last').focus();
    else if ($('#wizardPopup').is(':visible') && !isDescendant($('#wizardPopup')[0], document.activeElement))
    {
        switch ($('#hfWizardType').val())
        {
        case 'setCaloriesOrVolume':
            if ($('#gridSelectGlucoseProduct').is(':visible'))
                $('#gridSelectGlucoseProduct').focus(); 
            else
                $('#wizardAddProduct td:eq(0)').focus();                                
            break;
        default:
            $('#wizardAddProduct td:eq(0)').focus();    
            break;
        }
    }
//TFS31227 11Apr12 XN Changed exiting main view and adjust from being Esc to Alt+X
//    switch (event.keyCode)  // Check which key was pressed
//    {
//        case 27:    // Esc close Multiply by form
//            askIfExit();
//            window.event.cancelBubble = true;
//            window.event.returnValue = false;
//            break;
//    }        
}

// Handle key presses on Multiply by form
function MultiplyBy_onkeydown(event)
{
    // Prevent handling alKey (so can't hot key items on main toolbar) or shiftKey (so can't shift tab back to grid)
    // TFS29323 XN 20Mar12
    if (event.altKey || event.shiftKey) 
    {
        window.event.cancelBubble = true;
        window.event.returnValue = false;
    }

    switch (event.keyCode)  // Check which key was pressed
    {
        case 27:    // Esc close Multiply by form
            $('#btnMultiplyByFormCancel').click();
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;

        case 13:    // Return click ok in Multiply by form
            $('#btnMultiplyByFormOK').click();     
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;

        case 9:     // Tab key fixes problem if user tabs from cancel button forces it to focus slider
            if (document.activeElement.id == 'btnMultiplyByFormCancel')
                $('#multiplyBySlider').focus();
            break;
    }
}

function weightAndVolumes_onkeydown(event)
{
    // Prevent handling alKey (so can't hot key items on main toolbar) or shiftKey (so can't shift tab back to grid)
    // TFS29323 XN 20Mar12
    if (event.altKey || event.shiftKey) 
    {
        window.event.cancelBubble = true;
        window.event.returnValue = false;
    }

    switch (event.keyCode)  // Check which key was pressed
    {
    case 27:    // Esc close Multiply by form
        $('#btnWeightClose').click();
        window.event.cancelBubble = true;
        window.event.returnValue = false;
        break;
        
    case 9:     // Tab key fixes problem if user tabs from full weight button forces it to OK button TFS29323 XN 20Mar12
        if (document.activeElement.id == 'btnWeightFullWeight')
            $('#weightAndVolumes').focus();
        break;
    }
}

function summaryView_onkeydown(event)
{
    // Prevent handling alKey (so can't hot key items on main toolbar) or shiftKey (so can't shift tab back to grid)
    // TFS29323 XN 20Mar12
    if (event.altKey || event.shiftKey) 
    {
        window.event.cancelBubble = true;
        window.event.returnValue = false;
    }

    switch (event.keyCode)  // Check which key was pressed
    {
    case 13:    // Return close form
    case 27:    // Esc    close form
        $('#btnSummeryViewOK').click();
        window.event.cancelBubble = true;
        window.event.returnValue  = false;
        break;
        
    case 9:     // Tab key changes the selected tab on the view
        var button     = $('#summaryView input[class="TabSelected"]');
        var nextButton = button.next('input[class="Tab"]');
        var firstButton= $('#summaryView input[class="Tab"]:first');
        if (nextButton.length != 0) 
            nextButton.click();
        else if (firstButton.length != 0)
            firstButton.click();
        window.event.cancelBubble = true;
        window.event.returnValue  = false;
    }
}

function wizardPopup_onkeydown(event) 
{
    // Prevent handling alKey (so can't hot key items on main toolbar) or shiftKey (so can't shift tab back to grid)
    // TFS29323 XN 20Mar12
    if (event.altKey || event.shiftKey) 
    {
        window.event.cancelBubble = true;
        window.event.returnValue = false;
    }

    switch (event.keyCode)  // Check which key was pressed
    {
    case 27:    // Esc close form
        $('#wizardAddProduct_StartNavigationTemplateContainerID_CancelButton' ).click();
        $('#wizardAddProduct_StepNavigationTemplateContainerID_CancelButton'  ).click();
        $('#wizardAddProduct_FinishNavigationTemplateContainerID_CancelButton').click();
        window.event.cancelBubble = true;
        window.event.returnValue = false;
        break;

    case 9: // If tab key is pressed on cancel button then move back to next element in wizard prevents tabbing to grid TFS29323 XN 20Mar12
        if ((document.activeElement.id == 'wizardAddProduct_StartNavigationTemplateContainerID_CancelButton'  ) ||
            (document.activeElement.id == 'wizardAddProduct_StepNavigationTemplateContainerID_CancelButton'   ) ||
            (document.activeElement.id == 'wizardAddProduct_FinishNavigationTemplateContainerID_CancelButton' ))
        {
            if ($('#wizardAddProduct table.gridTable').length > 0)  // Check if form contains a grid then tab to this (else won't do it by default) TFS29323 XN 20Mar12
                $('#wizardAddProduct table tr[selected].GridRow').parent().parent().focus();
            else
                $('#wizardAddProduct').focus();
            window.event.cancelBubble = true;
            window.event.returnValue = false;
        }
        break;                    
        
    case 13:    // Enter clicks next button Wizard will do this normally except where previous button is present then it use this!!!
        $('#wizardAddProduct_StartNavigationTemplateContainerID_StartNextButton').click();
        $('#wizardAddProduct_StepNavigationTemplateContainerID_StepNextButton'  ).click();
        $('#wizardAddProduct_FinishNavigationTemplateContainerID_FinishButton'  ).click();
        window.event.cancelBubble = true;
        window.event.returnValue = false;
        break;

    }
}

// Initalise and displays multiply by form
function DisplayMultiplyByForm()
{
    // setup slider on multiply by form
    // slider works from 200 at top to 1 at bottom so need to reverse value
    $('#multiplyBySlider').slider({
        orientation: 'vertical',
        min: multiplyByMin,
        max: multiplyByMax,
        slide: function(e, ui) { $('#tbMultiplyBy').val(multiplyByMax - ui.value + multiplyByMin); }    // When slider moves update multiply text value (value has to be reversed see above)
    });

    // Set up key press handler
    $('#tbMultiplyBy').keyup(tbMultiplyBy_keyup);
    
    // Displays form
    popup('multiplyByForm', 'blanket');
    $('#tbMultiplyBy').focus();
}

// Called when user presses key in mutply text box
// Updates position of slider
function tbMultiplyBy_keyup()
{
    var value = parseInt($('#tbMultiplyBy').val());
    
    if (value != NaN)
    {
        // ensure value is in range
        if (value > multiplyByMax)
            value = multiplyByMax;
        if (value < multiplyByMin)
            value = multiplyByMin;

        // Update slider value (rem slider works with 200 at top to 1 at bottom so reverse)
        $('#multiplyBySlider').slider('value', multiplyByMax - value + multiplyByMin);
    }
}

function askUserAboutLargeGlucoseChanges(message)
{
    var tempDiv = '<div style="font-size:11px;">' + message + '</div>';
    $(tempDiv).dialog(
        {
			modal: true,
        	buttons: 
        	{
		        'Yes':    function()
		                    {
		                        // Set the mix option to true, and click the wizard finish button
		                        $('#wizardAddProduct_selectGlucoseProductCtrl_cbMixing').attr('checked', 'checked');
		                        $(this).dialog("close");
//		                        $('#wizardAddProduct_FinishNavigationTemplateContainerID_FinishButton').click(); removed as want to go back to glucose selection screen so mimicks v8  (59607)
		                    },
		        'No':     function()
		                    {
		                        // Set the hidden field hfRequestedNoMixing to ture, and click the wizard finish button
		                        $('#wizardAddProduct_selectGlucoseProductCtrl_hfRequestedNoMixing').val('true');
                                $(this).dialog("close");
                                $('#wizardAddProduct_FinishNavigationTemplateContainerID_FinishButton').click(); 
		                    },
		        'Cancel': function() { $(this).dialog("close"); }
		    },
		    title: 'Glucose level',
		    closeOnEscape: true,
		    draggable: false,
		    resizable: false,
            appendTo: 'form',
            focus: function (type, data) { $(this).siblings('.ui-dialog-buttonpane').find('button:eq(2)').focus(); },
            open: function () 
            {
                var buttons = $('.ui-dialog-buttonpane button', $(this).parent());
                buttons.eq(2).css({ width: '85px' });                                               // Expand size of cancel button
                $(this).parent().keydown(function (event) { return tabbingFix(event, this); });
            },
            close: function (type, data) { window.event.cancelBubble = true; window.event.returnValue = false; }
        });
}

// Used by stand reg wizard if user selects no glucose product (59607) 26Mar13 XN
function warnUserAboutGlucoseChanges(message) 
{
    var tempDiv = '<div style="font-size:11px">' + message + '</div>';
    $(tempDiv).dialog(
        {
            modal: true,
            buttons:
        	{
        	    'OK': function () {
        	        // Set the hidden field hfRequestedNoMixing to ture, and click the wizard finish button
        	        $('#wizardAddProduct_selectGlucoseProductCtrl_hfRequestedNoMixing').val('true');
        	        $(this).dialog("close");
        	        $('#wizardAddProduct_FinishNavigationTemplateContainerID_FinishButton').click();
        	    },
        	    'Cancel': function () { $(this).dialog("close"); }
        	},
            title: 'Volume change',
            closeOnEscape: true,
            draggable: false,
            resizable: false,
            width: 300,
            zIndex: 9009,  // To put it infront of popup
            appendTo: 'form',
            focus: function (type, data) { $(this).siblings('.ui-dialog-buttonpane').find('button:eq(1)').focus(); },
            open: function () {
                var buttons = $('.ui-dialog-buttonpane button', $(this).parent());
                buttons.eq(1).css({ width: '85px' });                                               // Expand size of cancel button
            },
            close: function (type, data) { window.event.cancelBubble = true; window.event.returnValue = false; }
        });
}

function askMultiplyByFactor(message, scale)
{
    var tempDiv = '<div style="font-size:11px">' + message + '</div>';
    $(tempDiv).dialog(
        {
            modal: true,
            buttons:
        	{
        	    'Yes': function() 
        	    {
        	        __doPostBack('upMultiplyByForm', 'Scale:' + scale);
        	        $(this).dialog("close");
        	    },
        	    'No': function() { $(this).dialog("close"); }
        	},
            title: 'Multiply by',
            resizable: false,
            zIndex: 9009,  // To put it infront of popup
            appendTo: 'form',
            focus: function (type, data) { $(this).siblings('.ui-dialog-buttonpane').find('button:eq(1)').focus(); },
            open: function () {
                setTimeout(function() { $('.ui-dialog-buttonpane button').focus(); }, 500); // Set no as focus button  only real way it will work
            },
            close: function(type, data) { window.event.cancelBubble = true; window.event.returnValue = false; delayedPNGridFocus(); }
        });
}

function SetStatus(jsonData)
{
    var Items = JSON.parse(jsonData);
    for (var c = 0; c < Items.length; c++)
        $('#' + Items[c].Key).text(Items[c].Value);
}

// Wanring message shown if user select standard regimen with unsuitalbe items
// Once the user excepts will move the wizard to the next stage
function warnAboutStandardRegimen(message) 
{
    var tempDiv = '<div style="font-size:11px">' + message + '</div>';
    $(tempDiv).dialog(
        {
            modal: true,
            buttons:
        	{
        	    'OK': function () {
                    //$(this).close();
                    $(this).dialog("destroy");  // 18Sept15 Found issue while testing that if populate for adult and shows (not in use error), then $(this).close() causes postback that claims it's new call to page which breaks the caching.
        	        $('#wizardAddProduct_StartNavigationTemplateContainerID_StartNextButton').click();  // Hedge your bets on if adult or pead wizard so try either button
        	        $('#wizardAddProduct_FinishNavigationTemplateContainerID_FinishButton').click();
        	    }
        	},
            title: 'Standard Regimen Warning',
            resizable: false,
            zIndex: 9002,  // To put it infront of popup
            appendTo: 'form',
            focus: function (type, data) { $(this).siblings('.ui-dialog-buttonpane').find('button:eq(0)').focus(); },
            open: function () {
                $(this).parent().keydown(function (event) { return tabbingFix(event, this); });
            },
            close: function () {
                $('#wizardAddProduct_StartNavigationTemplateContainerID_StartNextButton').click();  // Hedge your bets on if adult or pead wizard so try either button
                $('#wizardAddProduct_FinishNavigationTemplateContainerID_FinishButton').click();
            }
        });
}

// TFS31227 12Apr12 XN Called if key is pressed in PNSelectGlucoseProduct page
// If popup message box is displayed (and key press still being picked up shift focus to popup)
// If Alt+M is pressed then toogle mix checkbox state
function PNSelectGlucoseProduct_onkeydown(event)
{
    if ($('.ui-dialog').is(':visible') && document.activeElement.className.indexOf('ui-') == -1) {
        $('.ui-dialog-buttonpane').focus();
    }
    else if (event.keyCode == 77 && event.altKey) {
        var cbMixing = $('#wizardAddProduct_selectGlucoseProductCtrl_cbMixing');
        if (cbMixing.prop('checked') == true)
            cbMixing.removeAttr('checked');
        else
            cbMixing.attr('checked', 'checked');
    }
}

// TFS31227 12Apr12 XN Called if key is pressed in PNAskAdjustIng popup page
// If space is pressed on checkbox toggle state of checkbox
// If up arrow is pressed move to top checkbox
// If down arrow is pressed move to bottom checkbox
// If tab is pressed on checkbox move to OK button 
function PNAskAdjustIng_onkeydown(event)
{
    switch (event.keyCode)
    {
    case 32:    // Space
        var currentNode = $(document.activeElement);
        if (currentNode.is(':checkbox'))
        {
            if (currentNode.prop('checked') == true)
                currentNode.removeAttr('checked');
            else
                currentNode.attr('checked', 'checked');
                
            window.event.cancelBubble = true;
            window.event.returnValue = false;
        }
        break;
        
    case 38:    // Up arrow
        var currentNode = $(document.activeElement);
        if (currentNode.is(':checkbox'))
        {
            var checkboxes = $(':checkbox', currentNode.parent().parent())
            if (checkboxes[0] != currentNode[0])
                checkboxes.eq(0).focus();

            window.event.cancelBubble = true;
            window.event.returnValue = false;
        }
        break;

    case 40:    // Down arrow
        var currentNode = $(document.activeElement);
        if (currentNode.is(':checkbox')) 
        {
            var checkboxes = $(':checkbox', currentNode.parent().parent())
            if (checkboxes[0] == currentNode[0])
                checkboxes.eq(1).focus();

            window.event.cancelBubble = true;
            window.event.returnValue = false;
        }
        break;
        
    case 9:     // Tab
        var currentNode = $(document.activeElement);
        if (currentNode.is(':checkbox')) 
        {
            var button = $('.ui-dialog-buttonpane button:eq(0)');
            button.focus();    
            button.focus();    

            window.event.cancelBubble = true;
            window.event.returnValue = false;
            return false;
        }
        break;
        
    case 13:    // Enter
        var currentNode = $(document.activeElement);
        if (currentNode.is(':checkbox')) 
        {
            $('.ui-dialog-buttonpane button', $(this).parent()).eq(0).click();
            
            window.event.cancelBubble = true;
            window.event.returnValue = false;
        }               
        break;
    }    
}

// Returns if child is dewscendant of parent
function isDescendant(parent, child) 
{ 
    var node = child; 
    while (node != null) 
    { 
        if (node == parent) 
            return true; 
        node = node.parentNode; 
    } 
    
    return false; 
}

// TFS31227 12Apr12 XN (used by various parts of the wizard)
// Sets focus back to selected cell in grid after .5secs
function delayedPNGridFocus()
{ 
    setTimeout(function() 
        { 
            var selectedCell = getSelectedCell(); 
            if (selectedCell.length > 0) 
                selectedCell.focus(); 
        }, 600);
}

// Progresses the wizard to the next stage
function ProgressWizard() 
{
    $('#wizardAddProduct_FinishNavigationTemplateContainerID_FinishButton').click();
    $('#wizardAddProduct_StepNavigationTemplateContainerID_StepNextButton').click();
    $('#wizardAddProduct_StartNavigationTemplateContainerID_StartNextButton').click();
}

// Called when request to edit total cell is made
// if cell is total for ingredient will launch the add ingredient wizard
// 12Sep14 XN 95898
function editTotalCell(cell) 
{
    if (cell.parent().attr('RowType') == 'total')
    { 
        var pos = getCellIndex(cell);
        var column = $('#PNGrid col').eq(pos.col).filter('[colType="ingredient"]');
        if (column.length > 0)
        {
            var rowTotalOrPerKgType = (cell.parent().attr('PNCode').toLowerCase() == 'totalinml') ? 'Total' : 'PerKg';    // TFS31243 5Apr12 XN When add by clicking on total row either add by total or per kg depending on total row selected
            __doPostBack('upWizard', 'AddByIngredient:' + column.attr('title') + ':' + rowTotalOrPerKgType + ':false');
        }
    }
}
