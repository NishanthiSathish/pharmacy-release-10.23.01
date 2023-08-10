// Called when pharamcy product is selected
function PharmacyProductSelected(nsvCode, siteProductDataID)
{
    NSVCode = nsvCode;
}        

// Called when pharamcy product selection is cleared
function PharmacyProductSelectionCleared()
{
    NSVCode = '';
}	 

// Called when pharmacy product is double clicked, will launch the contract editor
function PharmacyProductDoubleClicked(nsvCode, siteProductDataID)
{
    NSVCode = nsvCode;
    $('#btnEditContract').click();
}

//  called when key presses
function form_onkeydown(event)
{
    switch (event.keyCode)
    {
    case 115: $('#btnItemEnquiry').click(); break; // F4
    }
}	    

// Called when item enquiry button is clicked, launches the F4 screen
function btnItemEnquiry_onclick()
{
    if (NSVCode == '')
    {
        alertEnh('Select product from the list<br />');
        return;
    }
    
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);
    
    strURLParameters += '&NSVCode=' + NSVCode;
    var ret = window.showModalDialog('../StoresDrugInfoView/ICW_StoresDrugInfoView.aspx' + strURLParameters, '', 'dialogHeight:735px; dialogWidth:865px; status:off; center: Yes'); // 30Jul15 XN 121034 Changed from using StoresDrugInfoViewModal.aspx to main ICW_StoresDrugInfoView.aspx'
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    SetFocusToProductSearchGrid();
}

// Called when edit contract button is clicked, will launch the contract editor
function btnEditContract_onclick()
{
    if (NSVCode == '')
    {
        alertEnh('Select product from the list<br />');
        return;
    }
    
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);
    
    strURLParameters += '&NSVCode=' + NSVCode;
    var ret=window.showModalDialog('../ContractEditor/ManualContractEditor.aspx' + strURLParameters, '', 'status:off;center:Yes');	        
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    SetFocusToProductSearchGrid();
}  

// Called when delte supplier profile button is pressed, will allow user to select which profile to delete
function btnDeleteSupplierProfile_onclick()
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);
    
    // Displays supplier profile selector form
    strURL = '..\\pharmacysharedscripts\\PharmacySelectSupplierProfile.aspx' + strURLParameters + '&SupplierTypesFilter=E&NSVCode=' + NSVCode;
    var result = window.showModalDialog(strURL, '', 'status:off; center:Yes;');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (result != undefined && result.split('|').length > 1)
    {
        // Check on server is profile can be deleted
        var wsupplierProfileID = result.split('|')[0];
        __doPostBack('upUpdatePanel', 'CanDeleteSupplierProfile:' + wsupplierProfileID);
    }
    else
        SetFocusToProductSearchGrid();
}

// Reselect the pharmacy product search grid, but does it after 250ms
// Useful for calling after popup message boxes
function SetFocusToProductSearchGrid()
{
    setTimeout(function() { fraPharmacyProductSearch.SetFocusToGrid(); }, 250);
}