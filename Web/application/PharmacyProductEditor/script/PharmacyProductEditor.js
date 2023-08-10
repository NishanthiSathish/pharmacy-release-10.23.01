/*

					    PharmacyProductEditor.js


	Specific script for the PharmacyProductEditor.aspx control.
*/

function body_onload()
{
    InitIsPageDirty();
    setSelectView($('#trViews button:first'));

    GPEInit();

    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(body_onResize);    
    body_onResize();

    if ($('#objPharmacyProductEditor').length > 0)
    {
        $('#objPharmacyProductEditor')[0].SetConnection(sessionID, ascribeSiteNumber, URLtoken);
        $('#objPharmacyProductEditor').hide();
    }
}

function body_unload()
{
    // Cleand up the form
    var parameters =
        {
            sessionID   : sessionID,
            lockDataXML : $('#hfProductStockLocker').val()
        };
    var result = PostServerMessage("ICW_PharmacyProductEditor.aspx/CleanUp", JSON.stringify(parameters));
}

// called when page resizes
// resizes the stock account panels so at max height
function body_onResize() 
{
    var divView       = $('#divView');
    var viewsRightPos = $('#trViews').offset().left + $('#trViews').width();
    var width         = $(window).width();
    var height        = $(window).height() * 0.935;
    var buttonHeight  = $('#trButtons').height();

    $('#tbl').width(width);

    divView.width (width - viewsRightPos);
    divView.height(height - divView.offset().top - buttonHeight);

    $('#tblHeader').width( width - viewsRightPos - 10 );

    $('#tblDrugButtons').width(width - viewsRightPos);

    divGPE_onResize();
}
        
function form_onkeydown()
{
    switch (event.keyCode)
    {
    case 115:     // F4
        DisplayItemEnquiry();
        break;

    case 38:  // Up
        if (event.shiftKey)
        {
            var buttons = $('#trViews button');
            var index   = buttons.index(getSelectedView());
            if (index > 0)
                setSelectView(buttons.eq(index - 1));
            window.event.cancelBubble = true;
        }
        break;
    case 40:  // Down
        if (event.shiftKey)
        {
            var buttons = $('#trViews button');
            var index   = buttons.index(getSelectedView());
            if (index < buttons.length - 1)
                setSelectView(buttons.eq(index + 1));
            window.event.cancelBubble = true;
        }
        break;
    }

    if (window.event.cancelBubble)
        window.event.returnValue = false;
}

function viewlist_onclick(viewbutton)
{
    setSelectView(viewbutton);
}

function setSelectView(viewbutton)
{
    if (!IsDirty())
    {
        $('#trViews button.ViewListSelected').removeClass('ViewListSelected');
                
//                var selectedView = $('#trViews button[key="' + viewIndexVal + '"]');
        viewbutton = $(viewbutton);
        viewbutton.addClass('ViewListSelected');
        viewbutton.focus();

        var viewIndex = viewbutton.attr('key');
        $('#hfViewIndex').val(viewIndex);
        $('#hfSupCode'  ).val('');

        Update(false, false);
    }
}

function getSelectedView()
{
    return $('#trViews button.ViewListSelected');
}

function Update(refresh, justSaved) 
{
    if (justSaved == undefined)
        justSaved = false;
    __doPostBack('upView', 'Update:' + refresh + ':' + justSaved);
}

function SelectSupplierProfile(viewIndex, NSVCode, supplierType)
{
    var strURL           = document.URL;
    var intSplitIndex    = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    // Get alternate supplier profile
    var url = '..\\pharmacysharedscripts\\PharmacySelectSupplierProfile.aspx' + strURLParameters + '&AddNewSupplierProfileOption=true&NSVCode=' + NSVCode + '&SupplierTypesFilter=' + supplierType;
    var result = window.showModalDialog(url, '', 'status:off; center:Yes;');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (result != undefined && result.split('|').length > 2)
    {
        // User selected a profile so update form    
        var supCode = result.split('|')[1];
        $('#hfSupCode').val(supCode);
        Update(true, false);
    }   

    // Profile selected so end
    if (result != '')
        return;

    // User opted to select a supplier so display select supplier form
    url = '..\\pharmacysharedscripts\\PharmacySupplierWardSearch.aspx' + strURLParameters + '&SupplierTypesFilter=' + supplierType;
    result = window.showModalDialog(url, '', 'status:off; center:Yes;');
    if (result == 'logoutFromActivityTimeout') {
        window.returnValue = 'logoutFromActivityTimeout';
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (result != undefined && result.split('|').length > 2)
    {
        var supCode = result.split('|')[1];
        $('#hfSupCode').val(supCode);
        Update(true, false);    // New supplier profile is not saved until user clicks the save buttons (so can't show Seved text)
    }   
}

function IsDirty()
{
    return isPageDirty && confirm("Changes have been made.\n\nClick Cancel to continue and lose your changes or OK to return to the editor");
}

function pageLoad() 
{
    window.document.getElementById('__EVENTARGUMENT').value = '';
}

function DisplayItemEnquiry()
{
    var NSVCode = $('#hfNSVCode').val();
    if (NSVCode != '')
    {    
        var strURL = document.URL;
        var intSplitIndex = strURL.indexOf('?');
        var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

        document.body.style.cursor = "wait";    
        strURLParameters += '&NSVCode=' + NSVCode;
        var ret = window.showModalDialog('../StoresDrugInfoView/ICW_StoresDrugInfoView.aspx' + strURLParameters, '', 'dialogHeight:735px; dialogWidth:865px; status:off; center: Yes'); // 30Jul15 XN 121034 Changed from using StoresDrugInfoViewModal.aspx to main ICW_StoresDrugInfoView.aspx'
        if (ret == 'logoutFromActivityTimeout') {
            ret = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }
        document.body.style.cursor = "default";
                
        window.event.cancelBubble = true;
    }
}

function btnAdd_OnClick()
{
    if (!IsDirty())
    {
        var strURL = document.URL;
        var intSplitIndex = strURL.indexOf('?');
        var strURLParameters = strURL.substring(intSplitIndex, strURL.length);       

        document.body.style.cursor = "wait";
        var result = window.showModalDialog('NewDrugWizard.aspx' + strURLParameters, undefined, 'center:yes; status:off');
        document.body.style.cursor = "default";
       if (result == 'logoutFromActivityTimeout' || sessionStorage.getItem('logoutFromActivityTimeout') == 'true') {
            result = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }
        if (result != null) 
        {
            $('#hfNSVCode').val(result);
            Update(false, true);
        }
    }
}

function btnEdit_OnClick()
{
    if (!IsDirty())
    {
        var strURL = document.URL;
        var intSplitIndex = strURL.indexOf('?');
        var strURLParameters = strURL.substring(intSplitIndex, strURL.length);       

        document.body.style.cursor = "wait";
        var url = '../PharmacyProductSearch/PharmacyProductSearchModal.aspx' + strURLParameters;
        var result = window.showModalDialog(url, undefined, 'center:yes; status:off');
        if (result == 'logoutFromActivityTimeout') {
            result = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }

        document.body.style.cursor = "default";

        if (result != null)
        {
            $('#hfNSVCode').val(result.split("|")[2]);
            Update(false, false);
        }
    }
}    

// Called when set primary supplier is clicked
// Checks data is saved, then ask if user wants to set supplier as primary, the does postback to set primary
function btnSetPrimary_OnClick()
{
    if (!IsDirty())
        confirmEnh("Are you sure you want to set " + $('#lbSupCode').text() + " as the primary supplier?", false, function() { __doPostBack('upView', 'SetPrimary');  });
}

// Called when delete supplier is clicked
// Asks the user if they are sure then does postback to delete
function btnDeleteSupplier_OnClick()
{
    confirmEnh("Are you sure you want to delete supplier " + $('#lbSupCode').text() + "?", false, function() { __doPostBack('upView', 'DeleteSupplier'); }, undefined, "350px");
}

// When user clicks right menu button, popups up a menu
function trViews_onmousedown()
{
    if (window.event.button == 2 && configurationEditor != 'None')
    {
	    var objPopup = new ICWPopupMenu();
        objPopup.AddItem('Edit settings...', MNU_EDIT_SECTION, true);		
	    objPopup.Show(window.event.screenX, window.event.screenY);
    }
}

// Called from right click context
function PopMenu_ItemSelected(selIndex, selDesc) 
{		
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);       

    if (selIndex == MNU_EDIT_SECTION)
    {
        var result = window.showModalDialog('PharmacyProductEditorSettings.aspx' + strURLParameters, undefined, 'center:yes; status:off');
        if (result == 'logoutFromActivityTimeout') {
            result = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }

        if (result != undefined)
            window.parent.parent.location.href = window.parent.parent.location.href;
    }
}

// Called when change report button is clicked
// Displays the change report for the current drug
// 18May15 XN 117528
function ChangeReport_onclick()
{
    var NSVCode = $('#hfNSVCode').val();
    if (NSVCode != '')
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
            ReportPharmacyLogDrugs(NSVCode, undefined, selectedSiteID, false);
    }
}

// Will load the RTF file from the network, and then parse and print it using the AscribePrintJob
// 24May16 XN added for shelf label printing via ascribe print job
function btnPrintShelfLabel_OnClick()
{
    if (IsDirty() || $('#hfNSVCode').val() == '')
        return;

    // Check parameters
    if (applicationPath == '')
    {
        alert("Desktop parameter ApplicationPath not set.");
        return;
    }

    var shelfEdgeLabelFliename = $('#hfShelfEdgeLabelFliename').val();

    // Show progress message
    ShowProgressMsg(this, undefined);
    //Get the filename only from the path
    // Parse rtf
    //Get the filename only from the path with no extension
    var rtffile1 = shelfEdgeLabelFliename.split('\\').pop().split('/').pop();
    var rtffile = rtffile1.replace(/\.[^.$]+$/, ''); //get rid of extension
    var parameters =
    {
        sessionId:  sessionID,
        siteId:     siteId,
        NSVCode:    $('#hfNSVCode').val(),
        //rtf: readFile(shelfEdgeLabelFliename)
        rtf:        rtffile
    };
    var result = PostServerMessage('ICW_PharmacyProductEditor.aspx/ParseShelfEdgeLabel', JSON.stringify(parameters));

    // If parsed okay then save file to network, and then print
    if (result != undefined)
    {
        var filename = GetLocalTempFilename(sessionID, siteId);
        writeFile(filename, result.d);
        AscribeVB6PrintJob(sessionID, siteId, applicationPath, filename, 'ShelfLbl', 1);
    }
    else 
        {
            alert("Missing shelf edge label RTF " + shelfEdgeLabelFliename);
        }
}

// Called when checkbox in the Update Service Control has focus 7Mar16 XN 99381
// notes the name of the control in hfCheckBoxWithFocus, so can select it after postback
function USC_checkbox_onfocus(cb) 
{
    $('input[id$=hfCheckBoxWithFocus]').val($(cb).attr('id'));
}

// Called when textbox, or checkbox in the Update Service Control has keypress 7Mar16 XN 99381
// if checkbox then moves the focus to the corresponding input control
// if textbox and is lookup, the displays the lookup 
function USC_control_onkeydown(input, event) 
{
    var returnVal = true;

    // ensure we have the input control 
    input = $(input);
    if (!input.is('input'))
        input = input.find('input');

    switch (event.keyCode) 
    {
    case 9:     // tab
    case 13:    // Enter
    case 16:    // Shift
    case 17:    // Ctrl
    case 18:    // Alt
    case 20:    // Caps
    case 27:    // Esc
        break;
    default:
        // Ignore handling space on checkbox as this is standard functionality
        if (input.attr('type') != 'checkbox' || event.keyCode != 32 /* space */) 
        {
            // If input is checkbox then find it's corresponding input box
            var isOnCheckbox = input.attr('type') == 'checkbox';
            if (isOnCheckbox)
                input = input.parent().parent().find('input[type=text], textarea');

            if (!input.is(':disabled')) 
            {
                if (input.attr('lookupOnly') != undefined) 
                {
                    // Input is a lookup contol so display the lookup form
                    DoLookup(input, String.fromCharCode((96 <= event.keyCode && event.keyCode <= 105) ? event.keyCode - 48 : event.keyCode));
                    returnVal = false;
                }
                else if (isOnCheckbox)
                {
                    // If focus is on checkbox then move focus to the input so use can start typing immediately
                    input.focus();
                    input.val(String.fromCharCode(event.keyCode));
                    returnVal = false;
                }

            }
        }
        break;
    }

    if (!returnVal) 
    {
        window.event.cancelBubble = true;
        window.event.returnValue = false;
    }

    return returnVal;
}

// Used by alternate barcode editor will store the selected barcode when user selects a new row 18Jul16 XN 126634
function pharmacygridcontrol_onselectrow(controlID, rowindex)
{
    if (controlID.endsWith('abcGrid'))
    {
        $('input[id$=hfSelectedBarcode]').val(getSelectedRow('abcGrid').attr('Barcode'));

        // When change selected row clear the error message (suppressed on post back to prevent loosing error) 10Oct16 XN 164388 
        if (parseBoolean($('input[id$=hfSuppressClearError]').val()) == false)
            $('[id$=lbError]').text('');
    }
    $('input[id$=hfSuppressClearError]').val('0');  // This is set server side to prevent suppression of clearing error message as issue on post back 10Oct16 XN 164388 
}

// Ensure that the report screen close if report creation is cancelled
function ssrsreport_cancelledcreation()
{
    $('.ui-dialog-content').dialog("destroy");
}
