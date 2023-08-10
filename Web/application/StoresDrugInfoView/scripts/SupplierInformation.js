/*

								SupplierInformation.js


	Specific script for the SupplierInformation frame.

*/

var SUPPLIERINFO_FEATURES = 'dialogHeight:710px; dialogWidth:450px; status:off';

// On double click of the suppliers grid will popup supplier info.
function gridcontrol_ondblclick(rowIndex) 
{
    var strURL           = document.URL;
    var intSplitIndex    = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    var supcode = getRow('productSuppliersGrid', rowIndex).attr('supcode');
    if (supcode != undefined)
    {
        // Displays the suppliers details window
        strURLParameters += "&SupplierCode=" + supcode;
        var result=window.showModalDialog('SupplierDetails.aspx' + strURLParameters,'',SUPPLIERINFO_FEATURES)
        //window.showModalDialog('SupplierDetailsModal.aspx' + strURLParameters, '', SUPPLIERINFO_FEATURES)  XN 24Jan17 126634 - Changes to the supplier info screen
        if (result == 'logoutFromActivityTimeout') {
            result = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }
    }
}
