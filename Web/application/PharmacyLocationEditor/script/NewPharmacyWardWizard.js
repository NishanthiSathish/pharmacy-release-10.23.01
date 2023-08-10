/*

NewPharmacyWardWizard.js

Specific script for the new pharmacy ward wizard.

*/

function body_onload()
{
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(body_resize);
}

function body_onkeydown()
{
    switch (event.keyCode)
    {
    case 27: window.close();        event.cancelBubble = true; break;
    case 13: $('#btnNext').click(); event.cancelBubble = true; break;
    }

    if (event.cancelBubble)
        event.returnValue = false;
}

function body_resize()
{
    if ( $('#divEditorControl').is(":visible") )
    {
        GPEUpdateLocalVariables();
        divGPE_onResize();
    }
}

// Called when btnNext is clicked
// performs any client side validation for the form
function btnNext_OnClick()
{
    var ok = true;

    // If serach for form is displayed
    if ($('#gcSelectImportFromWard').is(":visible")) 
    {
        var row = getSelectedRow('gcSelectImportFromWard');
        if (row.length > 0) 
            $('#hfSelectImportFromWardCode').val( row.attr('Code') );
        else
        {
            $('#errorMessage').text('Select location from the list');
            ok = false;
        }
    }            
    return ok;
}