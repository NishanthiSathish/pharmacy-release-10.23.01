/*

StockListFindAndReplace.js


Specific script for the wards stock list find and replace (delete) page (ICW_StockListFindAndReplace.aspx).

*/

function pageLoad()
{
    window.document.getElementById('__EVENTARGUMENT').value = '';
    $('#cblLists :checkbox').change(function () { $('#lbErrorMessage').text(' '); });   // 1Dec14 XN 105484 clear errror message when checkbox checked
}

// Called when pharamcy product is selected
function PharmacyProductSelected(nsvCode, siteProductDataID, description) 
{
    $('input[id$=hfSearchForNSVCode]'    ).val(nsvCode      );
    $('input[id$=hfSearchForDescription]').val(description  );
}        

// Called when pharamcy product selection is cleared
function PharmacyProductSelectionCleared()
{
    $('input[id$=hfSearchForNSVCode]').val('');
}	 

// Called when pharmacy product is double clicked
function PharmacyProductDoubleClicked(nsvCode, siteProductDataID, description)
{
    $('input[id$=hfSearchForNSVCode]'    ).val(nsvCode      );
    $('input[id$=hfSearchForDescription]').val(description  );
    $('input[id$=btnNext]').click();
}

// Called when btnReplaceNSVCode is clicked
// shows drug search from
function btnReplaceNSVCode_onclick()
{
    // get existing NSVcode
    var NSVCode = $('input[id$="hfReplaceNSVCode"]').val();

    // show drug search from
    NSVCode = findDrug(NSVCode);
    if (NSVCode != undefined)
    {
        // update page with new drug
        var upMain = $('div[id$="upMain"]');
        __doPostBack(upMain.attr('id'), 'SelectedReplaceDrug:' + NSVCode);
    }

    window.event.returnValue  = false;
    window.event.cancelBubble = true;
}

// Called when btnRestart is clicked
// If not first page then display message if they want to loose your changes, and if so will reload page
// 106968 23Dec14 XN
function btnRestart_OnClick()
{
    // Only show the 'loose your changes message' if first page
    if ( $('#vSelectFindType').is(':visible') || !confirm('Your changes have not been implemented yet.\n\nClick Cancel to continue and lose your changes or OK to return to the editor.') )
        window.location = window.location; 
}

// Called when btnNext is clicked
// performs any client side validation for the form
function btnNext_OnClick()
{
    var ok = true;

    // If serach for form is displayed
    if ($('iframe[id$=fraPharmacyProductSearch]').is(":visible")) 
    {
        // Check if user has selected a drug
        var searchForNSVCode = $('input[id$=hfSearchForNSVCode]').val();
        if (searchForNSVCode == '') 
        {
            alertEnh('Select an item from the list');
            $('input[type="text"]').focus();
            ok = false;
        }

        if (ok) 
        {
            // Checks if selected drug appears on a ward stock list
            var parameters = {
                                sessionID: sessionID,
                                siteID:    siteID,
                                NSVCode:   searchForNSVCode
                                };
            var result = PostServerMessage('ICW_StockListFindAndReplace.aspx/IsPresentOnWardStockList', JSON.stringify(parameters));
            if (result.d != undefined && !result.d) 
            {
                alertEnh('No stock list contains<br />&nbsp;&nbsp;&nbsp;' + searchForNSVCode + ' - ' + $('input[id$=hfSearchForDescription]').val(), undefined, '450px');
                $('input[type="text"]').focus();
                ok = false;
            }
        }
    }            
    return ok;
}

// Displays drug seearch from and return newly selected NSVCode or undefined
function findDrug(NSVCode) 
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    strURLParameters += "&SearchText=" + NSVCode;

    var result = window.showModalDialog('../PharmacyProductSearch/PharmacyProductSearchModal.aspx' + strURLParameters, '', 'dialogHeight:600px; dialogWidth:850px; status:off; center: Yes');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (result != null)
        return result.split('|')[2];
}