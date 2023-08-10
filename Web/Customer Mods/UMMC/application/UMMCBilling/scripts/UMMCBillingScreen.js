/*

UMMCBillingScreen.js


Specific script for the UMMCBillingScreen page.

*/

// Close the form if the escape key is pressed
function form_onkeydown(event) 
{
    switch (event.keyCode) 
    {
        case 27:    // Esc key closes the form
            window.close();
    }
}

// called when form loaded
// sets up the scripts to call when starting and ending a request
function form_onload() 
{
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(StartRequest);
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest  (EndRequest);
}

// Called when checkAll buttons is clicked, checks all items in the table
function checkAll_onclick()
{
    setCheckedAll('dispensingsGrid', 1, true);
}

// Called when uncheckAll buttons is clicked, unchecks all items in the table
function uncheckAll_onclick()
{
    setCheckedAll('dispensingsGrid', 0, true);
}

// Gets if billed transactions are to be highlighted
function highlightBilledTransactions()
{
    return ($('body').attr('highlightBilledTransactions').toLowerCase() == 'true')
}

// Called then the bill patient button is clicked
function billPatient_Click() 
{
    // Clear previous error message
    $('#errorMessageGrid').html(" ");

    // Get the checked rows, and marshal then up
    var rowsToBill = getCheckedRows('dispensingsGrid');
    var parsedBilledRowsAttrStr = MarshalRowAttributes(rowsToBill);
    
    // Save marshalled data for transferring to server side code
    $('#selectedTransactionIDs').val(parsedBilledRowsAttrStr);

    // If differentiating between billed, and unbilled, then ask user if they
    // only want to send billed, and save result for transfer to serve side
    $('#onlySendUnbilledItems').val('false');
    var selectedRowsContainBilledItems = rowsToBill.is('[billedstate=AllBilled], [billedstate=PartBilled]');
    if (highlightBilledTransactions() && selectedRowsContainBilledItems)
    {
        var msg = 'Selected dispensing may have already been billed\nClick Yes to only send unbilled items.\nClick No to re-bill all selected items.'
        switch (MessageBox('Billing', msg, "YesNo", ''))
        {
        case 'y': $('#onlySendUnbilledItems').val('true');  break;
        case 'n': $('#onlySendUnbilledItems').val('false'); break;
        default:
            event.returnValue = false;
            event.cancel = true;
            break;
        }
    }
}

function cancel_onclick() 
{
    window.close();
}

// Disable buttons, and show message on start of a request
function StartRequest(sender, e) 
{
    $('input').attr('disabled', 'disabled');
    $('button').attr('disabled', 'disabled');
    $('#errorMessageGrid').html(" ");
    $('#errorMessageDate').html(" ");
    $('#billResponseAction').val(" ");
    $('#updateMessage').html("Updating...");
    $('#updateMessage').show();
}

// Enable buttons, and show message on start of a request
function EndRequest(sender, e) 
{
    $('input').removeAttr('disabled');
    $('button').removeAttr('disabled');
    if (!highlightBilledTransactions())
        $('#rowHighlightKey').hide();
    $('#updateMessage').hide();
}

// Called by the server side code, so user is informed when billing completed
function BillingCompleted(closeForm) 
{
    // If highlighting billed transaction, the mark checked items
    if (highlightBilledTransactions())
    {
        var highlightColourAllBilled = $('body').attr('highlightColourAllBilled')
        getCheckedRows('dispensingsGrid').css('background-color', highlightColourAllBilled);
    }
        
    // Notify user        
    alert('Patient billing has been sent.');

    // Close form
    if (closeForm)
        window.close();
}

