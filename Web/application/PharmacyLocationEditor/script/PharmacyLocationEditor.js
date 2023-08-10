/*

PharmacyLocationEditor.js

Specific script for the new pharmacy ward wizard.

*/

// Called when page is loaded
function body_onload()
{
    body_resize();
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(body_resize);    

    InitIsPageDirty();
    GPEInit();

    DisplayPharmacyWardList('', '', sortBy);
}

// Called on postback
function pageLoad()
{
    window.document.getElementById('__EVENTARGUMENT').value = '';
}

// Called when page is resized
function body_resize()
{
    var divSave         = $('#divSave');
    var width           = $(window).width();
    var height          = $(window).height();
    var divEditorControl= $('#divEditorControl');
    var divContainer    = $('div.icw-container-fixed');
            
    divSave.css('left', (width - divSave.width()) / 2);
    divEditorControl.height( height - divEditorControl.offset().top - 110 );
    divEditorControl.width ( width * 0.95 );
    divContainer.height    ( height - 40  );

    divGPE_onResize();
}

// Called when add button is clicked
// Displays the new ward wizard screen
function btnAdd_onclick()
{
    if (IsDirty())
        return;

    var result = window.showModalDialog('NewPharmacyWardWizard.aspx' + getURLParameters(), '', 'status:off; center:Yes;');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (result != undefined)
        __doPostBack('upMain', 'LoadCustomer:true:' + result);
}

// Called when edit button is clicked
// Displays the ward select screen
function btnEdit_onclick()
{
    if (IsDirty())
        return;

    DisplayPharmacyWardList($('#hfSelectedCode').val(), '', sortBy);
}

// Call to allow user to select a pharmacy ward
function DisplayPharmacyWardList(defaultCode, optionalRow, sortBy)
{
    var strURLParameters = getURLParameters();

    strURLParameters += '&DefaultCode=' + defaultCode;
    strURLParameters += '&OptionalRow=' + optionalRow;
    strURLParameters += '&ForceSelection=true';
    strURLParameters += '&InUseOnly=false';
    strURLParameters += '&ShowPharmacyOnlyColumn=true';
    strURLParameters += '&SortBy='      + sortBy;

    // Get alternate supplier profile
    var result = window.showModalDialog('SelectPharmacyWard.aspx' + strURLParameters, '', 'status:off; center:Yes;');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (result != undefined && result.split('|').length > 1)
    {
        var code = result.split('|')[1];
        if (code == optionalRow)
            $('#btnAdd').click();
        else
            __doPostBack('upMain', 'LoadCustomer:false:' + code);
    }            
}

// Returns if a pages is dirty
function IsDirty()
{
    return isPageDirty && confirm("Changes have been made.\n\nClick Cancel to continue and lose your changes or OK to return to the editor");
}

// Called when change report button is clicked
// Displays the change report for the current customer
// 18May15 XN 117528
function ChangeReport_onclick()
{
    var wcustomerID = $('#hfWCustomerID').val();
    if (wcustomerID != '')
    {
        var strURLParameters = getURLParameters();
        strURLParameters += '&SiteNumbers=' + editableSiteNumbers;
        strURLParameters += '&AutoSelectSingle=Y';

        var selectedSiteID = window.showModalDialog('../pharmacysharedscripts/SiteLookupList.aspx' + strURLParameters, undefined, 'center:yes; status:off');
        if (selectedSiteID == 'logoutFromActivityTimeout') {
            selectedSiteID = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }
        if (selectedSiteID != undefined)
            ReportPharmacyLogWCustomer(wcustomerID, undefined, false);
    }
}