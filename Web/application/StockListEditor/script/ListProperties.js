/*

WardProductListEditor.js

Specific script for the select pharmacy ward list editor page.

*/

// called when form loads
function pageLoad() 
{
    body_resize();
}

// called when body is resized
// poisitions the ward, and ward clear buttons
function body_resize()
{
    var tbLocationDerscription = $('.' + ICW.Controls.CSS.CONTROL_SHORTTEXT + '[id$=txtLocationDescription] input');

    var pos   = tbLocationDerscription.position();
    var width = tbLocationDerscription.width();
    $('input[id$="btnLocation"]').css({ top:  pos.top  + 'px' });
    $('input[id$="btnLocation"]').css({ left: pos.left + width + 10 + 'px' });

    pos   = $('input[id$="btnLocation"]').position();
    width = $('input[id$="btnLocation"]').width();
    $('input[id$="btnLocationClear"]').css({ top:  pos.top  + 'px' });
    $('input[id$="btnLocationClear"]').css({ left: pos.left + width + 10 + 'px' });

    pos = $('input[id$="btnLocationClear"]').position();
    width = $('input[id$="btnLocationClear"]').width();
    $('span[id$="lblNotInUse"]').css({ top: pos.top + 'px' });
    $('span[id$="lblNotInUse"]').css({ left: pos.left + width + 20 + 'px' });
}

// Called when ward button is clicked 
// Will display pharmacy ward selector, and then update the Ward Description 
function btnLocation_OnClick()
{
    var strURLParameters = getURLParameters();

    strURLParameters += '&DefaultCode=' + $('input[id$=hfWCustomerCode]').val();
    strURLParameters += '&InUseOnly=true';

    // Get alternate supplier profile
    var result = window.showModalDialog('../PharmacyLocationEditor/SelectPharmacyWard.aspx' + strURLParameters, '', 'status:off; center:Yes;');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (result != undefined && result.split('|').length > 2)
    {
        var splitRes = result.split('|');
        var ID          = splitRes[0];
        var code        = splitRes[1];
        var description = splitRes[2];
        PopulateWard(ID, code, code + ' - ' + description);
    }
}

// Called when the clear button is clicked
// Will clear the pharmacy ward controls
function btnLocationClear_OnClick()
{
    PopulateWard('', '', '');
}

// Populate the pharmacy ward controls
function PopulateWard(wcustomerID, wcustomerCode, description)
{
    ICW.Controls.Container.SetValueForControl($('.' + ICW.Controls.CSS.CONTROL_SHORTTEXT + '[id$=txtLocationDescription]'), description);
    $('.' + ICW.Controls.CSS.CONTROL_CHECKBOX + '[id$=cbVisibleToLocation]:first').visible(wcustomerID != '');
    $('span[id$="lblNotInUse"]').visible(false);
    $('input[id$=hfWCustomerID]'  ).val(wcustomerID   );
    $('input[id$=hfWCustomerCode]').val(wcustomerCode );
}