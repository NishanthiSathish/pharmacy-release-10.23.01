/*

                    loading.js


Specific script for the loading.js frame.

Handles key and button presses.

*/

var currentTable;   // Table that currently has focus

// Called when the page is loaded
// Setups the loading, and orders grids
// Set robotLoadingItems as the current table
function onload() 
{
    displayOrdersForLoading();
    showCompletedLoadings(false);

    currentTable = 'robotLoadingItems';
        
    $('#lbWarning').hide();
}

// Handles key presses on the robot laoding info screen.
function frame_onkeydown(event)
{
    switch (event.keyCode)  // Check which key was pressed
    {
    case 27:    // ESC (close the form only works when page is called from Pharmacy stores application)
        this.parent.window.close();
        break;

    case 38:    // Up/down keys changes selectred rows (if robotLoadingItems gird then update display in orders grid)
    case 40:
        gridcontrol_onkeydown_internal(currentTable, event);
        if (currentTable == 'robotLoadingItems') 
        {
            orderLoadingID = getSelectedRow('robotLoadingItems').attr('OrderLoadingID');
            displayOrdersForLoading(orderLoadingID);
        }
        updateButtonStates();        
        break;            
    }
}

// On click of the robotLoadingItems grid will update the orders grid, and button states
function robotLoadingItems_onclick(row)
{
    currentTable = 'robotLoadingItems';

    orderLoadingID = getSelectedRow('robotLoadingItems').attr('OrderLoadingID');
    displayOrdersForLoading(orderLoadingID);

    updateButtonStates();
}

// On click of the orderItems grid will update the button states
function orderItems_onclick(row)
{
    currentTable = 'orderItems';
    updateButtonStates();
}

// On double clicking of the orderItems grid will display the receive goods screen
function orderItems_ondblclick(rowIndex) 
{
    var orderNumber = getRow('orderItems', rowIndex).attr('OrderNumber');
    parent.displayReceiveGoodsScreen(orderNumber);
}

// Called when include completed checkbox is clicked 
// Displays or hides completd loadings, on the loading grid
function cbIncludeCompleted_onclick()
{
    showCompletedLoadings(document.forms[0].cbIncludeCompleted.checked)
}

// Called when the Complete button is clicked
// If loading selected, will then call server side method Complete.
function complete_onclick()
{
    $('#lbWarning').hide();

    if (getSelectedRowIndex('robotLoadingItems') == null) 
    {
        $('#lbWarning').text("Select a loading to be marked as completd");
        $('#lbWarning').show();
    }
    else 
    {
        var orderLoadingID = getSelectedRow('robotLoadingItems').attr('OrderLoadingID');
        var answer = ICWConfirm('OK to confirm that loading has completed.', 'OK,Cancel', 'Loading Number');
        if (answer == 'OK') 
        {
            StartRequest();
            CallServer('Complete("' + orderLoadingID + '")', '');
        }
    }
}

// Called when the Info button is clicked
// If a order item is selected, will display the receive goods screen
function info_onclick()
{
    var orderNumber = getSelectedRow('orderItems').attr('OrderNumber');
    if (orderNumber != undefined)
        parent.displayReceiveGoodsScreen(orderNumber);
}

// When the cancel button is clicked closes the window
function close_onclick()
{
    this.parent.window.close();
}

// Updates the state of the complete, and info buttons
function updateButtonStates()
{
    // If selected robot loading is active, will enable complete button
    var completeButtonEnabled = getSelectedRow('robotLoadingItems').attr('Status') == 'Active';
    EnableControl('btnComplete', completeButtonEnabled);

    // If order item is selected will enable info button
    var infoButtonEnabled = getSelectedRow('orderItems').length > 0;
    EnableControl('btnInfo', infoButtonEnabled);
}

// Will show orders that are under the order loading
function displayOrdersForLoading(orderLoadingID)
{
    selectRow('orderItems');
    $('#orderItems tbody tr').hide();
    if (orderLoadingID != undefined)
        getRowByAttribute('orderItems', 'OrderLoadingID', orderLoadingID).show();
}

// Shows\hides completed loadings
function showCompletedLoadings(show) 
{
    selectRow('robotLoadingItems');
    displayOrdersForLoading();

    if (show)
        $('#robotLoadingItems tbody tr[Status="Completed"]').show();
    else
        $('#robotLoadingItems tbody tr[Status="Completed"]').hide();

    updateButtonStates();
    refreshRowStripes('robotLoadingItems');
    refreshRowStripes('orderItems');
}

// Result form server after complete, or info button has been clicked
// Information in the retValue should be in the format
//              [Return date type]:[return data : sepearated]
function ReceiveServerData(retValue)
{
    EndRequest();
    
    if (retValue != '') 
    {
        var items = retValue.split('¦');

        switch (items[0].toLowerCase()) 
        {
            // Order was compeleted sucessfully so update completed row
            case 'complete':            
            var orderLoadingID = items[1];
            var status = items[2];
            var compltedBy = items[3];
            var completedDate = items[4];
            var updatedRow = $('#robotLoadingItems tbody tr[OrderLoadingID="' + orderLoadingID + '"]');

            // Update completed row details
            $(updatedRow.selector + ' td:eq(3) span').text(status);
            updatedRow.attr('Status', status);
            $(updatedRow.selector + ' td:eq(4) span').text(compltedBy);
            $(updatedRow.selector + ' td:eq(5) span').text(completedDate);

            // Hide\display completed row
            showCompletedLoadings(document.forms[0].cbIncludeCompleted.checked);

            // Refresh striping
            refreshRowStripes();
            break;

        case 'error':
            // Failed to complete loading so show error
            var message = items[1];
            $('#lbWarning').text(message);
            $('#lbWarning').show();
            break;
        }

        document.body.style.cursor = "default";
    }
}

// Enables\disables a control
function EnableControl(controlID, enabled) 
{
    if (enabled)
        $('#' + controlID).removeAttr('disabled');
    else
        $('#' + controlID).attr('disabled', true);
}

// Disable buttons, and show message on start of a request
function StartRequest()
{
    $('button').attr('disabled', true);
    $('tbody tr input[type=checkbox]').attr('disabled', true);
}

// Enable buttons, and show message on start of a request
function EndRequest()
{

    updateButtonStates();
    $('tbody tr input[type=checkbox]').removeAttr('disabled');
}