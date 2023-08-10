/*

FMRule.js

Specific script for the FMRule.aspx page.

*/

// Called when form loads
// relays out the page
function form_onload() 
{
    $('#container').height(parseInt(window.dialogHeight) - 16);
    
//            Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(beginRequest);
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest  (endRequest  );
}

// Called when the NSV Code look up button is clicked 
// Displays the PharmacyProductSearch page to allow the user to select a drug
function btnNSVCode_OnClick() 
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    // Add site to query if present (else select master site) 08Jan14 XN 81377
    var siteID = GetSelectedSiteID();
    if (siteID == '')
        strURLParameters += '&MasterMode=Y';
    else
        strURLParameters += '&SiteID=' + siteID;
    
    var result = window.showModalDialog('../PharmacyProductSearch/PharmacyProductSearchModal.aspx' + strURLParameters, '', 'dialogHeight:600px; dialogWidth:850px; status:off; center: Yes');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (result != null)
    {
        var splitRes = result.split('|');
        if (splitRes.length > 2) 
        {
            $('[ID$="hfNSVCode"]'              ).val(splitRes[2]);
            $('[ID$="txtNSVDescription"] input').val(splitRes[2] + ' - ' + splitRes[1]);
        }
    }
}

// Called when the NSV Code clear button is clicked 
// Removes the drug NSV Code and description
function btnNSVCodeClear_OnClick()
{
    $('[ID$="hfNSVCode"]'              ).val('');
    $('[ID$="txtNSVDescription"] input').val('<Any>');
}

// Called when the Ward\Supplier look up button is clicked 
// Displays the PharmacySupplierWardSearch page to allow the user to select a drugParac
function btnWardSupCode_OnClick() 
{
    var strURLParameters = getURLParameters();
    strURLParameters += '&DefaultCode=' + $('[id$=hfWardSupCode]').val();   // 18Jun14 XN 88509

    // Add site to query if present 08Jan14 XN 81377
    var siteID = GetSelectedSiteID();
    if (siteID != '')
        strURLParameters += '&SiteID=' + siteID;

    var lPharmacyLog = $('.' + ICW.Controls.CSS.CONTROL_LIST + '[id$=lPharmacyLog]');    
    var logtype      = ICW.Controls.ShortText.GetValueForControl( lPharmacyLog[0] );

    var description = '<Any>';
    var code        = '';
    var supplierID  = '';
    
    if (logtype == 'Orderlog')
        var result = window.showModalDialog('../pharmacysharedscripts/PharmacySupplierWardSearch.aspx' + strURLParameters, '', 'status:off; center: Yes');
    else
        var result = window.showModalDialog('../PharmacyLocationEditor/SelectPharmacyWard.aspx' + strURLParameters, '', 'status:off; center: Yes'); // 18Jun14 XN 88509 use new SelectPharmacyWard.aspx page
    if (result == 'logoutFromActivityTimeout') {
        window.returnValue = 'logoutFromActivityTimeout';
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }


    if (result != null)
    {
        var splitRes = result.split('|');
        if (splitRes.length > 2) 
        {
//            description = splitRes[1] + ' - ' + splitRes[2]; 87070 XN 25Mar14 If cancel selected supplier\ward the should not clear current selection
//            code        = splitRes[1];
//            supplierID  = splitRes[0];
            $('[ID$="txtWardSupDescription"] input').val(splitRes[1] + ' - ' + splitRes[2]);
            $('[ID$="hfWardSupCode"]'              ).val(splitRes[1]                      );
            $('[ID$="hfSupplierID"]'               ).val(splitRes[0]                      );
        }
    }
    
//    $('[ID$="txtWardSupDescription"] input').val(description);    87070 XN 25Mar14 If cancel selected supplier\ward the should not clear current selection
//    $('[ID$="hfWardSupCode"]').val(code);
//    $('[ID$="hfSupplierID"]' ).val(supplierID);
}

// Called when the Ward\Sup clear button is clicked 
// Removes the drug Ward\Sup Code and description
function btnWardSupCodeClear_OnClick() 
{
    $('[ID$="hfSupplierID"]' ).val('');
    $('[ID$="hfWardSupCode"]').val('');
    $('[ID$="txtWardSupDescription"] input').val('<Any>');            
}

// Called when selecting a tab
// collapse and hides any select boxes with dropdowns open
function radTabStrip_OnTabSelecting()
{
    // collapse and hides any select boxes with dropdowns open 87072 XN 25Mar14
    $('select:visible').attr('size', 0);
    $('select:visible').hide();
}

// Called when tab selected
// select first item in selected tab
function radTabStrip_OnTabSelected()
{
    // sets focus to first item in selected tab 87072 XN 25Mar14
    if ($find('container_radTabStrip').get_selectedTab().get_index() == 0)
        ICW.Controls.Container.SetCurrentControl($('[ID$="txtCode"]')[0]);
    else
    {
        layoutExtraFilterTab();
        ICW.Controls.Container.SetCurrentControl($('[ID$="lPharmacyLog"]')[0]);
    }
}

function GetSelectedSiteID()
{
    var siteID = $('select[id*="_lSite_"] option[selected]').attr('value');
    return siteID == undefined ? '' : siteID;
}

// Called when line in ward\sup lookup is selected stores the select row DBID into hfSelectedDBID
function pharmacygridcontrol_onselectrow(controlID, rowindex)
{
    if (controlID == 'gcSearchResults')
        $('[id$="hfSelectedDBID"]').val(getRow(controlID, rowindex).attr('DBID'));
}

// Called when update request to page ends
// Re-layout the page
function endRequest()
{
    layoutExtraFilterTab();
}

// Correctly position the NSV Code, NSV Code clear, WardSup Code, WardSup Code clear buttons
function layoutExtraFilterTab() 
{
    if ($('[id$="txtNSVDescription"]').is(':visible'))
    {
        var pos   = $('[id$="txtNSVDescription"] input').position();
        var width = $('[id$="txtNSVDescription"] input').width();
        $('[id$="btnNSVCode"]').css({ top: pos.top + 'px' });
        $('[id$="btnNSVCode"]').css({ left: pos.left + width + 10 + 'px' });

        pos   = $('[id$="btnNSVCode"]').position();
        width = $('[id$="btnNSVCode"]').width();
        $('[id$="btnNSVCodeClear"]').css({ top: pos.top + 'px' });
        $('[id$="btnNSVCodeClear"]').css({ left: pos.left + width + 10 + 'px' });

        pos   = $('[id$="txtWardSupDescription"] input').position();
        width = $('[id$="txtWardSupDescription"] input').width();
        $('[id$="btnWardSupCode"]').css({ top: pos.top + 'px' });
        $('[id$="btnWardSupCode"]').css({ left: pos.left + width + 10 + 'px' });

        pos   = $('[id$="btnWardSupCode"]').position();
        width = $('[id$="btnWardSupCode"]').width();
        $('[id$="btnWardSupCodeClear"]').css({ top: pos.top + 'px' });
        $('[id$="btnWardSupCodeClear"]').css({ left: pos.left + width + 10 + 'px' });
    }
}
