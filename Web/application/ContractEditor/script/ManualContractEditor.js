/*

								ManualContractEditor.js


	Specific script for the ManualContractEditor.ascx control.

*/

// called when supplier link is clicked (allows user to change selected suplier profile)
function lbtnSupplier_onclick(closeIfNoneSelected)
{
    var strURL           = document.URL;
    var intSplitIndex    = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);
    var upMainID         = $('div[id$="upMCE"]').attr("id");

    // Displays supplier profile selector form
    strURL = '..\\pharmacysharedscripts\\PharmacySelectSupplierProfile.aspx' + strURLParameters + 
                                                                '&NSVCode=' + $('input[id$="hfNSVCode"]').val() + 
                                                                '&DefaultSupCode=' + $('input[id$="hfSupCode"]').val() + 
                                                                '&AddNewSupplierProfileOption=true&SupplierTypesFilter=E';
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
            __doPostBack(upMainID, 'SelectNewSupplierProfile:' + wsupplierProfileID);
        }
    }   

    // If nothing selected then end
    if (result == undefined && closeIfNoneSelected)
        window.close();
    if (result != '')
        return;

    // User opted to select a supplier so display select supplier form
    strURL = '..\\pharmacysharedscripts\\PharmacySupplierWardSearch.aspx' + strURLParameters + '&DefaultSupCode=' + $('input[id$="hfSupCode"]').val() + '&SupplierTypesFilter=E';
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
            __doPostBack(upMainID, 'SelectNewSupplier:' + supCode);
        }
    }   

    // If nothing selected then end
    if (result == undefined && closeIfNoneSelected)
        window.close();
}

// Called when select sites buton is clicked
// Displays the site selection box
function lbtSelectSites_onclick()
{
    var upMainID = $('div[id$="upMCE"]').attr("id");

    // If no sites in list don't display (08Jun15 XN 119361)
    if ($('#divSites input').length == 0)
        return;

    $('#divSites').dialog(
        {
            modal: true,
            buttons: [  { text: 'OK',     click: function() { $(this).dialog('destroy'); __doPostBack(upMainID, 'SelectedNewSites'); } },
                        { text: 'Cancel', click: function() { $(this).dialog('destroy'); } }      
                        ],
            title: 'Select sites',
            open: function(type, data) { $(this).parents('.ui-dialog-buttonpane button:eq(0)').focus(); },
            width: '350px',
            maxHeight: '400px',
            closeOnEscape: true,
            draggable: false,
            resizable: false,
            appendTo: 'form'
        })
}

// Called when Edi Barcode lookup button is clicked will display the SupplierProfileEdiBarcodeLookup page
function imgEdiBarcodeLookup_onclick()
{
    var parameters = getURLParameters(); // will already contain the NSVCode
    parameters += '&SelectedBarcode=' + $('input[id$=tbProposedEdiBarcode]').val();
    if (getURLParameter('NSVCode') == undefined)
        parameters += '&NSVCode=' + $('input[id$="hfNSVCode"]').val();

    var result = window.showModalDialog('../PharmacyProductEditor/SupplierProfileEdiBarcodeLookup.aspx' + parameters, undefined, 'center:yes; status:off');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (result != undefined)
    {
        $('input[id$=tbProposedEdiBarcode]').val(result);
        setIsPageDirty();
    }
}