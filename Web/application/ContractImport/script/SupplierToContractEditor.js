// Initialise the from
function form_onload()
{
    // Set form to mark as dirty if anything changed
    InitIsPageDirty();
    
    // If no supplier selected then launch the supplier selector forms
    if ($('#hfSupCode').val() == '')
        lbtnSupplier_onclick(true);
}

// Called when form is about to close
// If form dirty ask user if really want to close
function form_onbeforeunload() 
{
    if (isPageDirty)
        event.returnValue = 'If you press OK, your latest changes will be lost!';
}   

//  called when key presses
function form_onkeydown(event)
{
    switch (event.keyCode)
    {
    case 115: ItemEnquiry_onclick(); break; // F4
    case 27 : window.close();        break; // esc
    }
}

function ItemEnquiry_onclick()
{
    var strURL           = document.URL;
    var intSplitIndex    = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);
    var ret = window.showModalDialog('../StoresDrugInfoView/ICW_StoresDrugInfoView.aspx' + strURLParameters, '', 'dialogHeight:735px; dialogWidth:865px; status:off; center: Yes'); // 30Jul15 XN 121034 Changed from using StoresDrugInfoViewModal.aspx to main ICW_StoresDrugInfoView.aspx'
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
}

// Called when select site link is clicked
// Displays list of sites to replicate to 
function lbtSelectSites_onclick()
{
    // If no sites in list don't display (08Jun15 XN 119361)
    if ($('#divSites input').length == 0)
        return;

    $('#divSites').dialog(
        {
            modal: true,
            buttons: [{ text: 'OK',     click: function() { $(this).dialog('destroy'); __doPostBack('upMain', 'SelectedNewSites'); } },
                      { text: 'Cancel', click: function() { $(this).dialog('destroy'); } }      
                     ],
            title: 'Select sites',
            open: function(type, data) { $(this).parents('.ui-dialog-buttonpane button:eq(0)').focus(); },
            width: '600px',
            maxHeight: '400px',
            closeOnEscape: true,
            draggable: false,
            resizable: false,
            appendTo: 'form'
        })
}

// Called when supplier link is clicked
// Displays supplier profile selector form, and is user select new supplier will then display select supplier form
function lbtnSupplier_onclick(closeIfNoneSelected)
{
    var strURL           = document.URL;
    var intSplitIndex    = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);
    
    // Displays supplier profile selector form
    strURL = '..\\pharmacysharedscripts\\PharmacySelectSupplierProfile.aspx' + strURLParameters + '&DefaultSupCode=' + $('#hfSupCode').val() + '&AddNewSupplierProfileOption=true&SupplierTypesFilter=E';
    var result = window.showModalDialog(strURL, '', 'status:off; center:Yes;');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (result != undefined && result.split('|').length > 1)
    {
        // User selected a profile so update form
        if (!isPageDirty || confirm("You will loose your existing changes.\nDo you want to continue?") == true)
        {                
            var wsupplierProfileID = result.split('|')[0];
            __doPostBack('upMain', 'SelectNewSupplierProfile:' + wsupplierProfileID);
            setIsPageDirty();
        }
    }   

    // If nothing selected then end
    if (result == undefined && closeIfNoneSelected)
        window.close();
    if (result != '')
        return;
       
    // User opted to select a supplier so display select supplier form
    strURL = '..\\pharmacysharedscripts\\PharmacySupplierWardSearch.aspx' + strURLParameters + '&DefaultSupCode=' + $('#hfSupCode').val() + '&SupplierTypesFilter=E';
    result = window.showModalDialog(strURL, '', 'status:off; center:Yes;');
    if (result == 'logoutFromActivityTimeout') {
        window.returnValue = 'logoutFromActivityTimeout';
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (result != undefined && result.split('|').length > 1)
    {
        // User selected a supplier so update form
        if (!isPageDirty || confirm("You will loose your existing changes.\nDo you want to continue?") == true)
        {                
            var supCode = result.split('|')[1];
            __doPostBack('upMain', 'SelectNewSupplier:' + supCode);
            setIsPageDirty();
        }
    }   

    // If nothing selected then end
    if (result == undefined && closeIfNoneSelected)
        window.close();
}