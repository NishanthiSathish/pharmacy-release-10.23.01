/*

    				NewAmmSupplyRequestWizard.js


	Specific script for the NewAmmSupplyRequestWizard.aspx frame.

*/

function pageLoad()
{
    if ($('#lbPhamacyProductDescription').length == 0)
    {
        $('#divPhamacyProductDescription').hide();
    }
}

// Called when pharmacy product is selected
function PharmacyProductSelected(nsvCode)
{
    $('#hfNSVCode').val(nsvCode);
}        

// Called when pharamcy product selection is cleared
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