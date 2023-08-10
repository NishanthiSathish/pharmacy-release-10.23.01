/*

                        orders.js


Specific script for the orders.js frame.

Handles key and button presses.

*/

// Handles key presses on the robot laoding info screen.
function frame_onkeydown(event)
{
    switch (event.keyCode)  // Check which key was pressed
    {
    case 27:    // ESC (close the form only works when page is called from Pharmacy stores application)
        this.parent.window.close();
        break;

    case 13:    // When cr pressed on selected row will display received goods screen
        var rowIndex = getSelectedRowIndex('orderItems');
        if (rowIndex != null) 
        {
            var orderNumber = getRow('orderItems', rowIndex).attr('OrderNumber');
            parent.displayReceiveGoodsScreen(orderNumber);
        }
        break;

    case 32:    // when space bar clicked toogle check of selected row and validate if needed
        var rowIndex = getSelectedRowIndex('orderItems');
        if (rowIndex != null) 
        {
            toogleCheck('orderItems', rowIndex);

            // If row now checked then validate
            if (getCheckedRow('orderItems', rowIndex)) 
            {
                gridcontrol_checkboxclick(rowIndex, 0);
                updateButtonStates();
            }
        }
        break;

    case 38:    // Up/down keys changes selectred rows (if robotLoadingItems gird then update display in orders grid)
    case 40:
        gridcontrol_onkeydown_internal('orderItems', event);
        updateButtonStates();
        break;
    }
}

// Called when row in orders grid is clicked
// Updates the button states
function gridcontrol_onclick(rowIndex)
{
    updateButtonStates();
}

// On double click of the orders grid will popup receive goods screen
function gridcontrol_ondblclick(rowIndex) 
{
    if (rowIndex != null) 
    {
        var orderNumber = getRow('orderItems', rowIndex).attr('OrderNumber');
        parent.displayReceiveGoodsScreen(orderNumber);
    }
}

// On check box click will call server side ValidateOrder methods to determine 
// If this order can be added to the list of existing orders
function gridcontrol_checkboxclick(row, column) 
{
    // Get the order number of the item that was clicked
    var checkOrderNumber = getRow('orderItems', row).attr('OrderNumber');
    
    // Get all the existing order numbers
    var existingOrderNumbers = '';
    $.each(getCheckedRows('orderItems'), function()
    {
        var orderNumber = this.parentElement.parentElement.parentElement.getAttribute('OrderNumber');
        if (orderNumber != checkOrderNumber)
            existingOrderNumbers += orderNumber + ',';
    });

    // Call server side method
    StartRequest();
    CallServer('ValidateOrder(' + checkOrderNumber + ',' + existingOrderNumbers + ')', '');
}

// Called when the create button is clicked
// Will create loading for all check orders
function create_onclick()
{
    var orderNumbers = '';

    $.each(getCheckedRows('orderItems'), function()
    {
        var orderNumber = this.parentElement.parentElement.parentElement.getAttribute('OrderNumber');
        orderNumbers += orderNumber + ',';
    });

    if (orderNumbers.length > 0)
        orderNumbers = orderNumbers.substr(0, orderNumbers.length - 1);

    // Call server side method
    StartRequest();
    CallServer('CreateLoading(' + orderNumbers + ')', '');
}

// Called when the info button is clicked
// Displays receive goods screen
function info_onclick()
{
    var rowIndex = getSelectedRowIndex('orderItems');

    if (rowIndex != null) 
    {
        var orderNumber = getRow('orderItems', rowIndex).attr('OrderNumber');
        parent.displayReceiveGoodsScreen(orderNumber);
    }
}

// When the cancel button is clicked closes the window
function close_onclick() 
{
    this.parent.window.close();
}

// Update the button states
function updateButtonStates()
{
    // If one order item is checked will enable the create button
    var anyChecked = ($('#orderItems tbody tr input[type=checkbox][checked]').length > 0);
    EnableControl('btnCreate', anyChecked);

    // If an order item row is selected will enable the info button
    var anySelected = ($('#orderItems tbody tr[selected]').length > 0);
    EnableControl('btnInfo', anySelected);
}

// Result form server after complete order validate server method is called
// Information in the retValue should be in the format
//              [Return date type]:[return data : sepearated]
function ReceiveServerData(retValue)
{
    EndRequest();
    
    if (retValue != '') 
    {
        var items = retValue.split(':');

        switch (items[0].toLowerCase()) 
        {
            // Check order validation failed so show error
            case 'validationerror':
                var orderNumber = items[1];
                var errorMsg = items[2];

                SetWarning(errorMsg);
                var rowIndex = getRowIndexByAttribute('orderItems', 'OrderNumber', orderNumber);
                setCheckedRow('orderItems', rowIndex, false);
                selectRow('orderItems');
                break;

            // Checked order is valid so clear any existing error
            case 'valid':
                SetWarning();
                break;

            // Call to create an order failed  
            // Display the error message
            case 'createerror':
                SetWarning(items[1]);
                break;

            // Order created, so display alert and remove rows added to loading
            case 'created':
                SetWarning();

                // Remove rows added to loading
                var loadingNumber = items[1];
                var orderNumbers = items[2].split(',');
                for (c = 0; c < orderNumbers.length; c++) 
                {
                    if (orderNumbers[c] != '') 
                    {
                        var rowIndex = getRowIndexByAttribute('orderItems', 'OrderNumber', orderNumbers[c]);
                        removeAt('orderItems', rowIndex);
                    }
                }
                refreshRowStripes('orderItems');
                
                // Update button states
                updateButtonStates();

                // display loading number
                alert("Created new loading '" + loadingNumber + "'");
                break;
        }

	$get('form1').style.cursor = "default";            
    }
}

// Sets the error text
function SetWarning(error) 
{
    if (error == undefined)
        $('#lbWarning').hide();
    else 
    {
        $('#lbWarning').html(error);
        $('#lbWarning').show();
    }
}

// Enables\disables a control
function EnableControl(controlID, enabled) {
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