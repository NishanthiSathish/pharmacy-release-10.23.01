/*

    				IngredientWizard.js


	Specific script for the IngredientWizard.aspx page.

*/

// Called when key pressed in body
// Handles standard enter, and escape keys
function body_onkeydown()
{
    switch (event.keyCode)
    {
    case 13:    // Enter 
        if ($('.ui-dialog-content').length == 0 || $('.ui-dialog-content').dialog("isOpen") != true)
        {
            window.event.cancelBubble = true;
            window.event.returnValue  = false;
            $('#btnNext').click();
        }
        break; 
       
    case 27 :  // Escape
        window.returnValue = $('#hfIfSavedData').val();
        window.close();
        break;
    }
}

// Called when pharmacy product is selected
function PharmacyProductSelected(nsvCode)
{
    $('#hfNSVCode').val(nsvCode);
}        

// Called when pharmacy product selection is cleared
function PharmacyProductSelectionCleared()
{
    $('#hfNSVCode').val('');
}	 

// Called when pharmacy product is double clicked
function PharmacyProductDoubleClicked(nsvCode)
{
    $('#hfNSVCode').val(nsvCode);
    $('#btnNext').click();
}

// Called when next button is clicked
// Ensures user has selected a value
function btnNext_onclick() 
{
    var ok = true;
    if ($('#fraPharmacyProductSearch').is(":visible") && $('#hfNSVCode').val() == '')
    {
        $('#errorMessage').text('Select a product from the list');
        ok = false;
    }            

    // 1Jul14 XN to prevent duplicate insert (hide next button)
    $('#btnNext').visible(false);

    return ok;
}

// Called from server side to display quantity warnings
// if user accepts will set hfEnterQuantityConfirm to prevent warning being redisplayed
function enterQuantityWarn(message, focusControlId)
{
    confirmEnh  (message, 
                 false, 
                 function()
                 {
                     $('#hfEnterQuantityConfirm').val('1'); 
                     $('#btnNext').click();
                 },
                 function()
                 {
                     $('#' + focusControlId).focus();
                     $('#' + focusControlId)[0].select();
                 });
}

// Fired when batch tracking is filled in
// Move to next stage 22Aug16 XN 160920
function batchTrackingReady()
{
    $('#btnNext').click();
}