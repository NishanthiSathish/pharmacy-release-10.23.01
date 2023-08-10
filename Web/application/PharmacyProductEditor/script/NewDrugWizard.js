/*

					    NewDrugWizard.js


	Specific script for the NewDrugWizard.aspx control.
*/

function body_onkeydown()
{
    switch (event.keyCode)
    {
    case 27:    // Esc
        if ($('.ui-dialog-content').dialog("isOpen") != true)
        {
            window.close();        
            event.cancelBubble = true; 
        }
        break; 

    case 13:    // Enter
        if ($('.ui-dialog-content').dialog("isOpen") != true)
        {
            $('#btnNext:visible').click(); 
            event.cancelBubble = true; 
        }
        break; 
    }

    if (event.cancelBubble)
        event.returnValue = false;
}

// Called when pharamcy product is selected
function PharmacyProductSelected(nsvCode, siteProductDataID)
{
    $('#hfNSVCode').val(nsvCode);
}        

// Called when pharamcy product selection is cleared
function PharmacyProductSelectionCleared()
{
    $('#hfNSVCode').val('');
}	 

// Called when pharmacy product is double clicked
function PharmacyProductDoubleClicked(nsvCode, siteProductDataID)
{
    $('#hfNSVCode').val(nsvCode);
    $('#btnNext').click();
}

// Called when pharamcy lookup list is selected
function PharmacyLookupListSelected(DBID)
{
    if ($('#fraICWProductSearch').is(":visible"))
        $('#hfProductID').val(DBID);
    else if ($('#fraAMPPList').is(":visible"))
        $('#hfAMPPProductID').val(DBID);
}        

// Called when pharamcy lookup list selection is cleared
function PharmacyLookupListSelectionCleared()
{
    if ($('#fraICWProductSearch').is(":visible"))
        $('#hfProductID').val('');
    else if ($('#fraAMPPList').is(":visible"))
        $('#hfAMPPProductID').val('');
}	 

// Called when pharmacy lookup list is double clicked
function PharmacyLookupListDoubleClicked(DBID)
{
    $('#btnNext').click();
}

function btnNext_OnClick() 
{
    var ok = true;
    if ($('#fraPharmacyProductSearch').is(":visible") && $('#hfNSVCode').val() == '')
    {
        $('#errorMessage').text('Select a product from the list');
        ok = false;
    }            
    else if ($('#fraICWProductSearch').is(":visible") && $('#hfProductID').val() == '')
    {
        $('#errorMessage').text('Select a product from the list');
        ok = false;
    }            
    else if ($('#hfAMPPProductID').is(":visible") && $('#hfProductID').val() == '')
    {
        $('#errorMessage').text('Select a product from the list');
        ok = false;
    }            

    // 1Jul14 XN to prevent duplicate drug lines disable (hide next button)
    $('#btnNext').visible(false);

    return ok;
}
