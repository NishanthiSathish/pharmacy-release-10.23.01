/*

StockListEditor.js

Specific script for the stock list editor page.

*/

function pageLoad()
{
    window.document.getElementById('__EVENTARGUMENT').value = '';

    // Convert ward stock list controller
    controller = JSON.parse($('#hfController').val());

    // Update size and states
    body_onresize();
    updateGridSelectedRowsFromController();
    UpdateToolbarButtons();
    UpdateLabels();
    updateTotalCost( controller.TotalCostFormatted );

    // Might call this too many times as done on each post back, no harm but better is only does once.
    var objStoresControl = $('#objStoresControl');
    if (objStoresControl.length > 0)
        objStoresControl.hide();
}

// Called when body is resized
// Ensures grid is full height
function body_onresize()
{
    var grid   = $('#divGrid');
    var panels = $('#tblInfoPanels');
    var windowHeight = $(window).height() * 0.935;

    var height = windowHeight - panels.height() - grid.offset().top;

    grid.height(height);
}

// Called when page is closed
// Removed all cached data from db
function body_unload()
{
    // Clean up the form
    var parameters =
        {
            sessionID : sessionID,
            siteID    : siteID,
            controller: controller
        };
    PostServerMessage("ICW_StockListEditor.aspx/CleanUp", JSON.stringify(parameters));
}

// Called when line in grid is clicked
// If right mouse button then show contextMenu
function grid_OnClick(rowIndex)
{
    if (event.button == 2)
    {
        // Update row selection
        if (!getRow('grid', rowIndex).is('.MultiSelect'))
            selectRow('grid', rowIndex, undefined, event.ctrlKey ? 'add' : 'single');

        // Display context menu
        var menu = $find("contextMenu");
        menu.show(event);
    }
}

// Called when key is pressed in grid
// If press down arrow, and currently on last row in grid, then display new  drug wizard
function divGrid_onkeyup()
{
    switch (event.keyCode)
    {
    case 40:
        // If clicked down arrow on grid (on last line) 
        // Then popup add new line below option
        if (prevSelectedIDOnDownKey[1] == controller.SelectedLineID && (getSelectedRowIndex('grid') == getRowCount('grid') - 1) && controller.CanEdit)
            DisplayNewLineWizard('below', 'Drug');
        break;
    }
}

// Called when key is pressed in grid
// Handle special key combinations e.g. Ctrl+C copy, Del for delete
function divGrid_onkeydown()
{
    var handledEvent = false;

    switch (event.keyCode)
    {
    case 67 : if (event.ctrlKey) { handledEvent = radToolbarClick("WardStockList_Copy" );    } break;  // C
    case 88 : if (event.ctrlKey) { handledEvent = radToolbarClick("WardStockList_Cut"  );    } break;  // X
    case 86 : if (event.ctrlKey) { handledEvent = radToolbarClick(event.shiftKey ? "WardStockList_PasteBelow" : "WardStockList_PasteAbove"); } break; // V
    case 70 : if (event.ctrlKey) { handledEvent = radToolbarClick("WardStockList_Find");     } break;  // F     16Jan14 XN 108211 Added default Ctrl+F for find
    case 114: handledEvent = radToolbarClick("WardStockList_Find"        );         break; // F3
    case 115: handledEvent = radToolbarClick("WardStockList_ItemEnquiry" );         break; // F4
    case 116: handledEvent = radToolbarClick( event.shiftKey ? "WardStockList_InsertDrugBelow" : "WardStockList_InsertDrugAbove"); break; // F5
    case 117: // F6
    case 46 : // Del
        handledEvent = radToolbarClick("WardStockList_Delete"); 
        break;
    case 119: handledEvent = event.shiftKey ? radToolbarClick("WardStockList_FindIssue")  : radToolbarClick("WardStockList_Issue");  break; // F8
    case 120: handledEvent = event.shiftKey ? radToolbarClick("WardStockList_FindReturn") : radToolbarClick("WardStockList_Return"); break; // F9
    }

    if (handledEvent)
    {
        event.cancelBubble = true;
        event.returnValue  = false;
    }
}

// called to manually click toolbar button via an button event name
function radToolbarClick(eventName)
{
    var button = $find("radToolbar").findItemByAttribute("eventName", eventName);
    if (button == null)
        button = $find("contextMenu").findItemByAttribute("eventName", eventName);

    if (button != null && button.get_enabled())
        button.click();
}

// Called when toolbar new button is clicked
// Displays new list properties from
function WardStockList_New()
{
    if (!IsDirty())
    {
        var strURLParameters = getURLParameters();
        strURLParameters = queryAddOrReplace(strURLParameters, 'mode', 'add');
        strURLParameters = queryAddOrReplace(strURLParameters, 'visibleToWard', '1');    
        result = window.showModalDialog('ListProperties.aspx' + strURLParameters, undefined, 'status:off;');
        if (result == 'logoutFromActivityTimeout') {
            result = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }
        if (result != undefined)
            __doPostBack('upMain', 'NewList:' + result);
        $('#grid').focus();
    }
}

// Called when toolbar open button is clicked
// Displays list selector form
function WardStockList_Open()
{
    if (!IsDirty())
    {
        var strURLParameters = getURLParameters();
        strURLParameters += '&Title=Select List';
        strURLParameters += '&Info=Select ward stock list to open';
        if (controller.SelectListByTerminal)
        {
            strURLParameters += '&SP=pWWardProductListByLocationForLookup';
            strURLParameters += '&Params=siteID:' + siteID + ",locationID:" + controller.TerminalID + ",SortBy:" + sortSelectorColumn;
        }
        else
        {
            strURLParameters += '&SP=pWWardProductListForLookup';
            strURLParameters += '&Params=siteID:' + siteID + ",SortBy:" + sortSelectorColumn + ",InUseOnly:" + (controller.Mode == 'Editable' ? '0' : '1');
        }
        strURLParameters += '&Columns=Code,10,Site,10,Full Name,59,In Use,10'
        strURLParameters += '&selectedDBID=' + controller.WardProductListID;
        strURLParameters += '&Width=650';
        strURLParameters += '&SearchType=Basic';
        strURLParameters += '&BasicSearchColumns=0,2';
        var result = window.showModalDialog('../pharmacysharedscripts/PharmacyLookupList.aspx' + strURLParameters, undefined, 'status:off;');
        if (result == 'logoutFromActivityTimeout') {
            window.returnValue = 'logoutFromActivityTimeout';
            result = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }
        if (result != null)
            __doPostBack('upMain', 'OpenList:' + result);
        $('#grid').focus();
    }
}

// Called when toolbar save button is clicked
// Saves changes
function WardStockList_Save()
{
    __doPostBack('upMain', 'Save');
}

// Called when toolbar save as new button is clicked
// Saves all list lines as new list
function WardStockList_SaveAsNew()
{
    var strURLParameters = getURLParameters();
    strURLParameters = queryAddOrReplace(strURLParameters, 'mode',          'add');
    strURLParameters = queryAddOrReplace(strURLParameters, 'visibleToWard', '0');    
    var result = window.showModalDialog('ListProperties.aspx' + strURLParameters, undefined, 'status:off;');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (result != undefined)
        __doPostBack('upMain', 'SaveAs:' + result);
    $('#grid').focus();
}

// Called when toolbar save as CSV button is clicked
// Saved the grid as a CSV file
function WardStockList_SaveAsCSV()
{
    var headingInfo = '';
    var cr = String.fromCharCode(13);   // row separator characters

    // Convert to table to CSV string
    //var gridStr = ConvertTableToCSV('grid'); 13Jul16 XN 157982 fix Save As CSV
    var gridStr = ConvertTableToCSV($('#grid'));

    // Perform save as
    document.frames['fraSaveToCSV'].SetSaveAsData($('#hfNameForCSVFile').val(), headingInfo + gridStr + cr);
    $('#grid').focus();
}

// Called when toolbar save as interface is clicked
// Uses activeX controls to save a win CE file format
function WardStockList_SaveAsInterface() 
{
    if (!IsDirty())
    {
        __doPostBack('upDummy', 'ExportWinCE');
        $('#grid').focus();
    }
}

// Called when toolbar copy is clicked
function WardStockList_Copy()
{
    if (controller.MultiSelectLineIDs.length == 0)
        return;

    CopyCut('Copy');
}

// Called when toolbar cut is clicked
function WardStockList_Cut()
{
    if (controller.MultiSelectLineIDs.length == 0)
        return;

    // Check if there are open requis 20nov14 XN
    var parameters =
        {
            sessionID : sessionID,
            siteID    : siteID,
            controller: controller
        };
    var openRequisMsg = '';
    var result = PostServerMessage("ICW_StockListEditor.aspx/HasOpenRequisitions", JSON.stringify(parameters));
    if (result != undefined && result.d != '' && result.d.length > 0) 
    {
        openRequisMsg = 'There are open requisitions for the following:<br />';
        for(var c = 0; c < result.d.length; c++)
            openRequisMsg += result.d[c] + '<br />';
        openRequisMsg += '<br />';
    }        

    // Either cut (or display warning if there are open requisition)
    if (openRequisMsg == '')
        CopyCut('Cut'); 
    else
    {
        confirmEnh('<div style="max-height:500px;">' + openRequisMsg + 'Are you sure you want to cut the line(s)?</div>', 
                   false, 
                   function() { CopyCut('Cut');     }, 
                   function() { $('#grid').focus(); },
                   450);
    }
}

// Perform the copy or cut operation
function CopyCut(mode)
{
    // check row is selected
    if (controller.MultiSelectLineIDs.length == 0)
        return;

    if (controller.MultiSelectLineIDs.length > 100)
    {
        alertEnh('Limited to 100 lines');
        return;
    }

    document.body.style.cursor = "wait";

    // Tell server to remove data 
    var parameters =
        {
            sessionID : sessionID,
            siteID    : siteID,
            mode      : mode,
            controller: controller
        };
    var result = PostServerMessage("ICW_StockListEditor.aspx/CopyCut", JSON.stringify(parameters));

    if (result != undefined && result.d != '')
    {
        // place on clipboard
        controller = JSON.parse( result.d );
        window.clipboardData.setData('Text', controller.returnData );

        // Update controller
        controller.returnData = null;
        SaveController();

        // Remove 
        if (mode == 'Cut')
        {
            // Remove from grid
            getSelectedRows('grid').remove();
            setIsPageDirty();

            // Update selection
            updateTotalCost( controller.TotalCostFormatted );
            updateGridSelectedRowsFromController();
            UpdateLabels();
        }
    }

    document.body.style.cursor = "default";

    $('#grid').focus();
}

// Called when toolbar paste above is clicked
function WardStockList_PasteAbove()
{
    var clipboardText = window.clipboardData.getData("Text");
    __doPostBack('upDummy', 'Paste:above:' + clipboardText);
    setIsPageDirty();
}

// Called when toolbar paste below is clicked
function WardStockList_PasteBelow()
{
    var clipboardText = window.clipboardData.getData("Text");
    __doPostBack('upDummy', 'Paste:below:' + clipboardText);
    setIsPageDirty();
}

// Called when toolbar insert drug above is clicked
// Displays new drug wizard
function WardStockList_InsertDrugAbove()
{
    // Normal mode adds above but if use shift key then adds below (only place to do this as key press handled by other parts of ICW)
    DisplayNewLineWizard( event.shiftKey ? 'below' : 'above', 'Drug');
}

// Called when toolbar insert drug below is clicked
// Displays new drug wizard
function WardStockList_InsertDrugBelow()
{
    // Normal mode adds above but if use shift key then adds above (only place to do this as key press handled by other parts of ICW)
    DisplayNewLineWizard( event.shiftKey ? 'above' : 'below', 'Drug');
}

// Called when toolbar insert title above is clicked
// Displays new title form
function WardStockList_InsertTitleAbove()
{
    // Normal mode adds above but if use shift key then adds below (only place to do this as key press handled by other parts of ICW)
    DisplayNewLineWizard( event.shiftKey ? 'below' : 'above', 'Title');
}

// Called when toolbar insert title below is clicked
// Displays new title form
function WardStockList_InsertTitleBelow()
{
    // Normal mode adds above but if use shift key then adds above (only place to do this as key press handled by other parts of ICW)
    DisplayNewLineWizard( event.shiftKey ? 'above' : 'below', 'Title');
}

// Display either new drug, or new line wizard
function DisplayNewLineWizard(insertMode, lineType)
{
    var strURLParameters       = getURLParameters();
    var originalSelectedLineID = controller.SelectedLineID;
    var NSVCode = '';
    var allowStoresOnlyparam = '';
    
    if (lineType == 'Drug') {

        //08Aug16 KR Added. TFS 159583
        switch (allowStoresOnly.toString()) {
            case '0':
                allowStoresOnlyparam = '&AllowStoresOnly=false&InUseOnly=true';
                break;
            case '-1':
                allowStoresOnlyparam = '&AllowStoresOnly=true&InUseOnly=true';
                break;
            case '1':
                allowStoresOnlyparam = '&AllowStoresOnly=true&InUseOnly=false';
                break;
            default:
                allowStoresOnlyparam = '&AllowStoresOnly=true&InUseOnly=true';
                break;
        }
        // Let user to select product
        var result = window.showModalDialog('../PharmacyProductSearch/PharmacyProductSearchModal.aspx' + strURLParameters + '&VB6Style=false' + allowStoresOnlyparam, '', 'dialogHeight:600px; dialogWidth:850px; status:off; center: Yes');
        if (result == 'logoutFromActivityTimeout') {
            result = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }
        if (result == null)
        {
            $('#grid').focus();
            return;
        }

        NSVCode = result.split('|')[2];
    }

    // Display the drug or title editor
    strURLParameters += '&AddMode=true';
    strURLParameters += '&controller='   + ReplaceString(JSON.stringify(controller), ".", UrlParameterEscapeChar);  //  01Apr15 XN  escaped control parameter 115152 (else page will not display in HTAless mode)
    strURLParameters += '&NSVCode='      + NSVCode;
    strURLParameters += '&AboveOrBelow=' + insertMode;

    switch (lineType)
    {
    case 'Drug' : var result = window.showModalDialog('DrugLineEditor.aspx'  + strURLParameters, undefined, 'status:off;'); break;
    case 'Title': var result = window.showModalDialog('TitleLineEditor.aspx' + strURLParameters, undefined, 'status:off;'); break;
    }
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (result == null)
        $('#grid').focus();
    else
    {
        // Save new grid
        controller = JSON.parse(result);
        SaveController();
        __doPostBack('upDummy', 'AddLine:' + insertMode + ':' + controller.SelectedLineID + ':' + originalSelectedLineID );
        setIsPageDirty();
    }
}

// Called when toolbar delete is clicked
// Delete the selected ward stock list lines
function WardStockList_Delete()
{
    // check row is selected
    if (controller.MultiSelectLineIDs.length == 0)
        return;

    var parameters =
        {
            sessionID : sessionID,
            siteID    : siteID,
            controller: controller
        };

    // Get open requis 20nov14 XN
    var openRequisMsg = '';
    var result = PostServerMessage("ICW_StockListEditor.aspx/HasOpenRequisitions", JSON.stringify(parameters));
    if (result != undefined && result.d != '' && result.d.length > 0) 
    {
        openRequisMsg = 'There are open requisitions for the following:<br />';
        for(var c = 0; c < result.d.length; c++)
            openRequisMsg += result.d[c] + '<br />';
        openRequisMsg += '<br />';
    }

    confirmEnh('<div style="max-height:500px;">' + openRequisMsg + 'Are you sure you want to delete the line(s)?</div>', false, function() 
    {
            document.body.style.cursor = "wait";

            // Tell server to remove data 
            var result = PostServerMessage("ICW_StockListEditor.aspx/Delete", JSON.stringify(parameters));
            if (result != undefined && result.d != '')
            {
                controller = JSON.parse( result.d );
                SaveController();

                // Remove from grid
                getSelectedRows('grid').remove();
                setIsPageDirty();

                // Update selection
                updateTotalCost( controller.TotalCostFormatted );
                updateGridSelectedRowsFromController();
                UpdateLabels();
            }

            document.body.style.cursor = "default";
            $('#grid').focus();
        },
        function () 
        {
            $('#grid').focus(); 
        },
        450);
}

// Called when toolbar move up is clicked
// Moves selected lines up the grid
function WardStockList_MoveUp()
{
    // check row is selected and not top row
    if (controller.MultiSelectLineIDs.length == 0)
        return;

    // Check block is not already at bottom of list then do nothing
    var firstRowDBID = parseInt(getRow('grid', 0).attr('DBID'));
    if ($.inArray(firstRowDBID, controller.MultiSelectLineIDs) < 0)
    {
        document.body.style.cursor = "wait"

        // move the rows
        for(var c = 0; c < controller.MultiSelectLineIDs.length; c++)
        {
            var row = getRowByAttribute('grid', 'DBID', controller.MultiSelectLineIDs[c]);
            row.prev().before(row);
        }

        // Update the rows on the server
        updateOrderOnServer();

        // Ensure the rows are in view 108334 19Jan14 XN ensure row is in view
        if (controller.MultiSelectLineIDs.length > 0)
        {
            // Get row with lowest index
            var firstRowIndex = getRowIndexByAttribute('grid', 'DBID', controller.MultiSelectLineIDs[0]);
            var lastRowIndex  = getRowIndexByAttribute('grid', 'DBID', controller.MultiSelectLineIDs[controller.MultiSelectLineIDs.length - 1]);
            var lowestIndex = firstRowIndex < lastRowIndex ?  firstRowIndex : lastRowIndex;

            // scroll the row into view
            if (!IsRowInView('grid', lowestIndex))
                scrollRowIntoView('grid', lowestIndex, true);
        }                

        // set dirty
        setIsPageDirty();

        document.body.style.cursor = "default"
    }

    $('#grid').focus();
}

// Called when toolbar move down is clicked
// Moves selected lines down the grid
function WardStockList_MoveDown()
{
    // check row is selected and not top row
    if (controller.MultiSelectLineIDs.length == 0)
        return;

    // Check block is not already at bottom of list then do nothing
    var lastRowDBID = parseInt(getRow('grid', getRowCount('grid') - 1).attr('DBID'));
    if ($.inArray(lastRowDBID, controller.MultiSelectLineIDs) < 0)
    {
        document.body.style.cursor = "wait"

        // move the rows
        for(var c = controller.MultiSelectLineIDs.length - 1; c >= 0; c--)
        {
            var row = getRowByAttribute('grid', 'DBID', controller.MultiSelectLineIDs[c]);
            row.next().after(row);
        }

        // Update the rows on the server
        updateOrderOnServer();

        // Ensure the rows are in view 108334 19Jan14 XN ensure row is in view
        if (controller.MultiSelectLineIDs.length > 0)
        {
            // Get row with highest index
            var firstRowIndex = getRowIndexByAttribute('grid', 'DBID', controller.MultiSelectLineIDs[0]);
            var lastRowIndex  = getRowIndexByAttribute('grid', 'DBID', controller.MultiSelectLineIDs[controller.MultiSelectLineIDs.length - 1]);
            var highesttIndex = firstRowIndex < lastRowIndex ? lastRowIndex : firstRowIndex;

            // scroll the row into view
            if (!IsRowInView('grid', highesttIndex))
                scrollRowIntoView('grid', highesttIndex, false);
        }

        // set dirty
        setIsPageDirty();

        document.body.style.cursor = "default"
    }

    $('#grid').focus();
}

// notifies the cached data on the server that order of rows in the list has been updated
function updateOrderOnServer()
{
    // Get the new world order
    var rows = $('#grid tbody tr');
    var rowDBID = new Array();
    for (var c = 0; c < rows.length; c++)
        rowDBID.push( parseInt(rows.eq(c).attr('DBID')) );

    // Tell server of the changes
    var parameters =
        {
            sessionID : sessionID,
            siteID    : siteID,
            controller: controller,
            rowIDs    : rowDBID
        };
    PostServerMessage("ICW_StockListEditor.aspx/UpdateOrder", JSON.stringify(parameters), true);
}

// Called when sort title asc button is clicked
// Sort item by description asc
function WardStockList_SortTitleAsc()
{
    __doPostBack('upMain', 'Sort:TitleAsc');
}

// Called when sort title asc button is clicked
// Sort item by description desc
function WardStockList_SortTitleDes()
{
    __doPostBack('upMain', 'Sort:TitleDes');
}

// Called when sort title asc button is clicked
// Sort item by NSVCode asc
function WardStockList_SortNSVCodeAsc()
{
    __doPostBack('upMain', 'Sort:NSVCodeAsc');
}

// Called when sort title asc button is clicked
// Sort item by NSVCode desc
function WardStockList_SortNSVCodeDes()
{
    __doPostBack('upMain', 'Sort:NSVCodeDes');
}

// Called when the find button is clicked
// displays a modeless form that allows the user to search for an item in the list
// search will be on any displayed in the gird + barcode (done by looking up barcode on server and then doing search against NSV Code)
function WardStockList_Find()
{
    $('#tbFind').val('');
    $('#divFind').dialog(
        {
            modal: false,
            buttons:
    	    {
    	        'Find Next' : function() { btnFindNext_onclick($('#tbFind'), $('#findError'), ''); },
    	        'Close'     : function() { $(this).dialog("destroy"); $('#grid').focus();             } 
    	    },
            close: function() { $('#grid').focus(); }, // 27Jan15 XN 10922
            title: 'Find',
            focus: function() { $('#tbFind').select(); $('#tbFind').focus(); },
            closeOnEscape: true,
            draggable: true,
            resizable: false,
            appendTo: 'form',
            width: 425
        });
}

// Called when the find issue button is clicked
// displays a modeless form that allows the user to search via barcode, and issue an item in the list
// search will be on barcode (done by looking up barcode on server and then doing search against NSV Code)
// 15Jul15 XN 123057 Added
function WardStockList_FindIssue()
{
    $('#spnIssueReturn').text('issue');
    $('#tbFindIssueReturn').val('');
    $('#divFindIssueReturn').dialog(
        {
            modal: false,
            buttons:
    	    {
    	        'Issue' : { text:   'Issue', 
                            id:     'btnJqueryDialogOK',
                            click:  function() { btnFindNext_onclick($('#tbFindIssueReturn'), $('#findIssueReturnError'), 'I'); }
                          },
    	        'Close' : function() { $(this).dialog("destroy"); $('#grid').focus();                      } 
    	    },
            close: function() { $('#grid').focus(); }, // 27Jan15 XN 10922
            title: 'Find and Issue',
            focus: function() { $('#tbFindIssueReturn').select(); $('#tbFindIssueReturn').focus(); },
            closeOnEscape: true,
            draggable: true,
            resizable: false,
            appendTo: 'form',
            width: 425
        });
}

// Called when the find return button is clicked
// displays a modeless form that allows the user to search via barcode, and return an item in the list
// search will be on barcode (done by looking up barcode on server and then doing search against NSV Code)
// 15Jul15 XN 123057 Added
function WardStockList_FindReturn()
{
    $('#spnIssueReturn').text('return');
    $('#tbFindIssueReturn').val('');
    $('#divFindIssueReturn').dialog(
        {
            modal: false,
            buttons:
    	    {
    	        'Return' :{ text:   'Return', 
                            id:     'btnJqueryDialogOK',
                            click:  function() { btnFindNext_onclick($('#tbFindIssueReturn'), $('#findIssueReturnError'), 'R'); }
                          },
    	        'Close' : function() { $(this).dialog("destroy"); $('#grid').focus();                      } 
    	    },
            close: function() { $('#grid').focus(); }, // 27Jan15 XN 10922
            title: 'Find and Return',
            focus: function() { $('#tbFindIssueReturn').select(); $('#tbFindIssueReturn').focus(); },
            closeOnEscape: true,
            draggable: true,
            resizable: false,
            appendTo: 'form',
            width: 425
        });
}

// Called when Issue button id clicked
// Performs issue (from server)
function WardStockList_Issue()
{
    if (controller.Mode == 'TemporaryEdit' || !isPageDirty)
        __doPostBack('upDummy', 'PerformActiveXOpertaion:I:0:0');
    else
        alertEnh('Save changes to continue');
}

// Called when Return button id clicked
// Performs issue (from server)
function WardStockList_Return()
{
    if (controller.Mode == 'TemporaryEdit' || !isPageDirty)
        __doPostBack('upDummy', 'PerformActiveXOpertaion:R:0:0');
    else
        alertEnh('Save changes to continue');
}

// Called when the find button in the modeless search box is clicked
// search will be on any displayed in the gird + barcode (done by looking up barcode on server and then doing search against NSV Code)
// tbFindControl     - find text box control
// findErrorControl  - error control
// barcodeIssueReturn- if do issue (I)\return (R) after find
// 15Jul15 XN 123057 Added barcode issue
function btnFindNext_onclick(tbFindControl, findErrorControl, barcodeIssueReturn)
{
    var findText    = tbFindControl.val();
    var startIndex  = getSelectedRowIndex('grid') + 1; // start search from next row in the list

    if (findText == '')
    {
        findErrorControl.text('Enter search string');
        tbFindControl.focus();
        return;
    }

    // If Find and Issue\Return the show progress bar 27Jul15 XN
    if (barcodeIssueReturn != undefined && barcodeIssueReturn != '')
        ShowProgressMsg();

    if ( isBarcode(findText) )
    {
        // If barcode the get list of NSVCodes that use that barcode (can return more than 1 NSVCode code)
        var parameters = 
        {
            sessionID:   sessionID,
            siteID:      siteID,
            barcode:     findText
        }
        var result = PostServerMessage('ICW_StockListEditor.aspx/GetNSVCodesByBarcode', JSON.stringify(parameters));
        if (result.d != undefined) 
            findText = result.d;
    }
    else
        findText = [ findText ];    // Convert find text to array

    var columIndex = (barcodeIssueReturn != '') ? GetColumnIndexByAttribute('grid', 'QSDataIndex', '4') : undefined;    // data index 4 is stock list line NSV Code 18Aug15 XN 126594 Added 

    // Go through the list of items to search for text.
    // Can be more than 1 search term so find first item before, and after current item
    var currentIndexFound = false;
    var closestIndexBefore= Number.MAX_VALUE;
    var closestIndexAfter = Number.MAX_VALUE;
    for (var t = 0; t < findText.length; t++)
    {
        var newRow = findRowsContaining('grid', startIndex, 1, columIndex, findText[t], true, false);
        if (newRow.length == 0 && startIndex != 1)
            newRow = findRowsContaining('grid', 0, 1, columIndex, findText[t], true, false);

        if (newRow.length != 0) 
        {
            var newRowIndex = newRow[0].rowIndex;

            if (newRowIndex > startIndex && newRowIndex < closestIndexAfter)
                closestIndexAfter = newRowIndex;
            else if (newRowIndex < startIndex && newRowIndex < closestIndexBefore)
                closestIndexBefore= newRowIndex;
            else (newRowIndex == startIndex)
                currentIndexFound = true;
        }
    }

    // Prefer first index after current item, 
    // if not found then get first index before current item
    // Else use current index (if valid find) 
    var newIndex = Number.MAX_VALUE;
    if (closestIndexAfter != Number.MAX_VALUE) 
        newIndex = closestIndexAfter;
    else if (closestIndexBefore != Number.MAX_VALUE)
        newIndex = closestIndexBefore;
    else if (currentIndexFound)
        newIndex = startIndex;

    // Select new index else error
    if (newIndex == Number.MAX_VALUE)
    {
        findErrorControl.text('Not found');
        tbFindControl.focus();
        HideProgressMsg(); // Only really of use with Find and Issue\Return 27Jul15 XN
    }
    else
    {
        findErrorControl.text(' ');
        selectRow('grid', newIndex - 1, true);
        updateControllerSelectedRowsFromGrid();

        // 15Jul15 XN 123057 Added issue\return options
        switch (barcodeIssueReturn)
        {
        case 'I': radToolbarClick('WardStockList_Issue');  break; 
        case 'R': radToolbarClick('WardStockList_Return'); break;
        }
    }
}

// Called when then list properties button is clicked
// Displays the list properties form
function WardStockList_ListProperties()
{
    var strURLParameters = getURLParameters();
    strURLParameters += '&mode=edit';
    strURLParameters += '&controller=' + ReplaceString(JSON.stringify(controller), ".", UrlParameterEscapeChar);    //  01Apr15 XN  escaped control parameter 115152 (else page will not display in HTAless mode)

    var result = window.showModalDialog('ListProperties.aspx' + strURLParameters, undefined, 'status:off;');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (result == undefined)
    {
        $('#grid').focus();
        return;
    }
    
    __doPostBack('upMain', 'UpdateListProperties:' + result);
}

// Called when then delete list button is clicked
// Will ask user to confirm and will then delete the list
function WardStockList_DeleteList()
{
    if (controller.WardProductListID > 0)
        confirmEnh('Are you sure you want to delete this list?', false, function() { __doPostBack('upMain', 'DeleteList'); }, function() { $('#grid').focus(); });
}

// Called when log view button is clicked
// Displays log viewer for currently selected lines
function WardStockList_LogView()
{
    displayLogView(controller.SelectedLineID, null, null);
}

// Called when item enquiry button is clicked
// displays item enquiry for currently selected line
function WardStockList_ItemEnquiry()
{
    var selectedRow = getSelectedRow('grid');

    if (controller.MultiSelectLineIDs.length == 0)
        alertEnh('Select a line from the list.', function() { $('#grid').focus(); });   // Error msg if no line selected 19Jan14 XN 108413 
    else if (controller.MultiSelectLineIDs.length > 1)
        alertEnh('Only select a single line.', function() { $('#grid').focus(); });     // Error msg if more than 1 line selected 19Jan14 XN 108413 
    else if (selectedRow.attr('NSVCode') == undefined)
        alertEnh('Select a drug line.', function() { $('#grid').focus(); });            // Error msg if title line selected 19Jan14 XN 108413 
    else
    {
        var strURLParameters = getURLParameters();
        strURLParameters += '&NSVCode=' + selectedRow.attr('NSVCode');
        var ret = window.showModalDialog('../StoresDrugInfoView/ICW_StoresDrugInfoView.aspx' + strURLParameters, '', 'dialogHeight:735px; dialogWidth:865px; status:off; center:Yes');    // 30Jul15 XN 121034 Changed from using StoresDrugInfoViewModal.aspx to main ICW_StoresDrugInfoView.aspx'
        if (ret == 'logoutFromActivityTimeout') {
            ret = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }
        $('#grid').focus();
    }
}

// Called when lock button is clicked
// Toggles locking of list
function WardStockList_Lock()
{
    if (!IsDirty())
        __doPostBack('upMain', 'Lock');
}

// Called when row in gird is selected
// Updates labels, and updates caching of down key
function pharmacygridcontrol_onselectrow(controlID, rowindex)
{
    if (!loadingPage)
    {
        updateControllerSelectedRowsFromGrid();
        UpdateLabels();
    }

    // Used to monitor if click the down key on the last row to auto popup insert below option.
    prevSelectedIDOnDownKey[1] = prevSelectedIDOnDownKey[0]
    prevSelectedIDOnDownKey[0] = controller.SelectedLineID;
}

// Called when row in gird is unselected
// Updates labels
function pharmacygridcontrol_onunselectrow(controlID, rowindex)
{
    updateControllerSelectedRowsFromGrid();
    UpdateLabels();
}

// If line has multiple issue (on last issue day) on then the last issue day text is a hyperlink that will call this method
function lastIssueDate_click(DBID, fromDate, toDate) 
{
    displayLogView(DBID, fromDate, toDate);
}

// Performs the operation needed to display the translog log view 
function displayLogView(DBID, fromDate, toDate) 
{
    document.body.style.cursor = "wait";

    // Save the log viewer settings to the SessionAttribute DB table
    var data = 
    {
        sessionID:   sessionID,
        siteID:      siteID,
        controller:  controller,
        WWardProductListLineID: DBID,
        fromDate:    fromDate,
        toDate:      toDate
    }
    var result = PostServerMessage('ICW_StockListEditor.aspx/SaveLogViewerSearchCriteria', JSON.stringify(data));

    document.body.style.cursor = "default";

    if (result.d == '')
    {
        // Display the pharmacy log
        var newParemters = '';
        newParemters += '?SessionID=' + sessionID;
        newParemters += '&SiteID='    + siteID;
       var result= window.showModalDialog("../PharmacyLogViewer/DisplayLogRows.aspx" + newParemters, undefined, 'center:yes; status:off');
        //if (result == 'logoutFromActivityTimeout') {
        //    result = null;
        //    window.close();
        //    window.parent.close();
        //    window.parent.ICWWindow().Exit();
        //}
        $('#grid').focus();
    }
    else
        alertEnh(result.d, function() { $('#grid').focus(); });
}

// Updates the WardStockListController of the currently selected line ID
function updateControllerSelectedRowsFromGrid()
{
    var selectedRow = getSelectedRow('grid');
    if (selectedRow.length > 0)
        controller.SelectedLineID = parseInt(selectedRow.attr('DBID'));

    var lines = getSelectedRows('grid');
    controller.MultiSelectLineIDs = new Array();
    for (var l = 0; l < lines.length; l++)
    {
        DBID = parseInt(lines[l].getAttribute('DBID'));
        controller.MultiSelectLineIDs.push(DBID);
    }
    
    SaveController();
}

// Updates the grid to display the currently selected lines as specified in the WardStockListController
function updateGridSelectedRowsFromController()
{
    loadingPage = true;

    if (controller.SelectedLineID != -1)
        selectRow('grid', getRowIndexByAttribute('grid', 'DBID', controller.SelectedLineID), true);

    // This might be ssssssllllooooooooooooowwwwwwwwwwwwwwwwwwwwww
    for(var l = 0; l < controller.MultiSelectLineIDs.length; l++)
        selectRow('grid', getRowIndexByAttribute('grid', 'DBID', controller.MultiSelectLineIDs[l]), false, 'add');

    loadingPage = false;
}

// Called when grid line is double clicked
// Displays drug or title editor
function grid_OnDblClick()
{    
    if (!controller.CanEdit || controller.Mode == 'TemporaryEdit')
    {
        event.cancelBubble = true;  // Needed else the alert panel below is never shown
        event.returnValue = false;

        switch (controller.Mode)
        {
        case "Editable"      : alertEnh('Editing requires the list to be locked', function() { $('#grid').focus(); }); break;
        case "TemporaryEdit" : alertEnh("Can't edit in temporary edit mode"     , function() { $('#grid').focus(); }); break;
        }
        return;
    }

    var selectedRow = getRowByAttribute('grid', 'DBID', controller.SelectedLineID);

    var strURLParameters = getURLParameters();
    strURLParameters += '&mode=edit';
    strURLParameters += '&controller=' + ReplaceString(JSON.stringify(controller), ".", UrlParameterEscapeChar);    //  01Apr15 XN  escaped control parameter 115152 (else page will not display in HTAless mode)
    strURLParameters += '&NSVCode='    + selectedRow.attr('NSVCode');
    if ( selectedRow.attr('lineType') == 'Drug' )
        var result = window.showModalDialog('DrugLineEditor.aspx' + strURLParameters, undefined, 'status:off;');
    else if ( selectedRow.attr('lineType') == 'Title' )
        var result = window.showModalDialog('TitleLineEditor.aspx' + strURLParameters, undefined, 'status:off;');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (result != null)
    {
        controller = JSON.parse(result);
        SaveController();
        __doPostBack('upDummy', 'UpdateLine');
        setIsPageDirty();
    }
}

// Will either add, replace or add above\below (defined by mode) the line in row XML
// DBID is either the line to replace, or line the new lines is to be inserted above or below
function updateLines(controllerStr, DBID, rowXML, mode)
{
    document.body.style.cursor = "wait";
    
    controller = JSON.parse( XMLUnescape(controllerStr) );
    SaveController();

    rowXML = XMLUnescape(rowXML);

    // Perform the operation
    switch (mode)
    {
    case 'add':
        addRow('grid', rowXML);
        break;
    case 'replace':
        replaceRow('grid', getRowIndexByAttribute('grid', 'DBID', DBID), rowXML);
        break;
    case 'above'  : 
        var selectedRow = getRowByAttribute('grid', 'DBID', DBID);
        if (selectedRow.length > 0)
            selectedRow.before(rowXML);
        else 
            addRow('grid', rowXML); // If grid was empty
        break;
    case 'below': 
        var selectedRow = getRowByAttribute('grid', 'DBID', DBID);
        if (selectedRow.length > 0)
            selectedRow.after(rowXML);                     
        else 
            addRow('grid', rowXML); // If grid was empty
        break;
    }

    // Update the other bits
    updateGridSelectedRowsFromController();
    UpdateLabels();
    updateTotalCost(controller.TotalCostFormatted);

    document.body.style.cursor = "default";    
}

// Update the cost label
function updateTotalCost(totalCost) 
{
    setPanelLabel('pnlListPanel', '{totalcost}', totalCost); 
}

// When context menu is clicked will call the appropriate event associated with the menu item (in menu item value)
function contexMenu_OnClicked(sender, args)
{
    var menuItem = args.get_item();
    eval(menuItem.get_value());
}

// when context menu is displayed will update the state of all buttons
function contexMenu_OnShowing(sender, args)
{
    var radToolbar = $find("radToolbar");
    var contextMenu= $find("contextMenu");

    $(contextMenu.get_allItems()).each(function()
        {
            var button = radToolbar.findItemByAttribute("eventName", this.get_attributes().getAttribute("eventName"));
            if (button != null)
                this.set_enabled(button.get_enabled());
        });
}

// Updates the label at the bottom of the screen
function UpdateLabels()
{
    if (controller.MultiSelectLineIDs.length != 0)
    {
        var row = getRowByAttribute('grid', 'DBID', controller.SelectedLineID);
        if (row.length == 0)
            return;
        row = row[0];

        // populate panel row panel details
        $(getAllPanelLabelNames('pnlRowPanel')).each(function() 
        { 
            setPanelLabelHtml('pnlRowPanel', this, row.getAttribute(this)); 
        });
    }
    else    
        clearLabels('pnlRowPanel'); // No row selected so clear bottom panel
}

// Update toolbar buttons state
function UpdateToolbarButtons()
{
    var radToolbar = $find("radToolbar");
    var contextMenu= $find("contextMenu");

    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_New",             controller.Mode != 'ViewOnly' );   // so disabled in readonly mode
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_Save",            controller.CanEdit && controller.Mode == 'Editable');
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_SaveAs",          controller.WardProductListID != -1 && controller.Mode == 'Editable' );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_SaveAsNew",       controller.WardProductListID != -1 && controller.CanEdit && controller.Mode == 'Editable');
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_SaveAsCSV",       controller.WardProductListID != -1 && controller.Mode == 'Editable');  // 104458 XN 17Nov14 Allow Save As without being in edit mode
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_SaveAsInterface", controller.WardProductListID != -1 && controller.Mode == 'Editable');
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_Copy",            controller.CanEdit );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_Cut",             controller.CanEdit );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_Paste",           controller.CanEdit );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_InsertDrugAbove", controller.CanEdit );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_InsertDrugBelow", controller.CanEdit );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_InsertTitleAbove",controller.CanEdit );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_InsertTitleBelow",controller.CanEdit );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_Delete",          controller.CanEdit );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_MoveUp",          controller.CanEdit );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_MoveDown",        controller.CanEdit );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_Sort",            controller.CanEdit );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_Find",            controller.WardProductListID != -1);
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_FindIssue",       controller.WardProductListID != -1 && controller.CanUse ); // 15Jul15 XN 123057 Added
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_FindReturn",      controller.WardProductListID != -1 && controller.CanUse && !controller.SelectListByTerminal ); // 15Jul15 XN 123057 Added
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_Issue",           controller.WardProductListID != -1 && controller.CanUse );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_Return",          controller.WardProductListID != -1 && controller.CanUse && !controller.SelectListByTerminal );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_ListProperties",  controller.CanEdit );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_DeleteList",      controller.WardProductListID != -1 && controller.CanEdit); // XN 10Dec14 105841 Disable delete list if new list
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_LogView",         controller.WardProductListID != -1 );
    ToolMenuEnable(radToolbar, contextMenu, "WardStockList_Lock",            controller.WardProductListID != -1 && controller.CanUse && controller.Mode != 'ViewOnly');
}

// Updates the state of the toolbar
function ToolMenuEnable(radToolbar, contextMenu, buttonName, enable)
{
    var button = null;
    if (radToolbar != null)
        button = radToolbar.findItemByAttribute("eventName", buttonName);

    if (button != null)
        button.set_enabled(enable);
    else 
    {
        // If not button then check if the menu item is present (as some menu items don't have buttons)
        var menuItem = contextMenu.findItemByAttribute("eventName", buttonName);
        if (menuItem != null)
            menuItem.set_enabled(enable);
    }
}

// If from is dirty will ask user if they want to save
// returns true if form is dirty, and user want's to save changes
function IsDirty()
{
    // don't display message in temp edit mode
    return controller.Mode != 'TemporaryEdit' && 
           isPageDirty && 
           window.showModalDialog('../pharmacysharedscripts/Confirm.aspx?Msg=Changes have been made.<br /><br />Click Cancel to continue and lose your changes or OK to return to the editor.&EscapeReturnValue=true&DefaultButton=OK');
}

// Saves the WardStockListController to hfController as JSON string
function SaveController()
{
    $('#hfController').val(JSON.stringify(controller));
}
