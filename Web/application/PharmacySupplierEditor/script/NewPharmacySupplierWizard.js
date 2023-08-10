/*

NewPharmacyWardWizard.js

Specific script for the new pharmacy supplier wizard.

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

function btnNext_onclick() 
{
    if ($('#fraFindSupplier').is(":visible"))
    {
        var supplierID = fraFindSupplier.GetSelectedSupplierID();
        var parameters = {
                            sessionID: sessionID,
                            siteID:    siteID,
                            supplierID:supplierID == '' ? null : parseInt(supplierID)
                         };

        var result = PostServerMessage("NewPharmacySupplierWizard.aspx/ValidateFindSupplier", JSON.stringify(parameters));
        if (result.d != '')
            $('#errorMessage').text( result.d );
        else 
            $('#hfFindSupplierID').val(supplierID);

        return result.d == '';
    }
}

// In the find supplier section if the user double clicks a supplier this method is called
// Will move the wizard to the next stage
function PharmacySupplierSelected() 
{
    $('#btnNext').click();
}

// Called when the supplier selection on FindSupplier page changes used to clear the error message
// 18Dec14 XN 106371
function PharmacySupplierChanged()
{
    $('#errorMessage').text(' ');
}