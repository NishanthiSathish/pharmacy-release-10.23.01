/*
aMM supply request script
*/
// called on each returns from server

var sessionId;
var siteId;

function pageLoad()
{
    viewSettings = JSON.parse($('#hfViewSettings').val());
    sessionId = viewSettings.SessionId;
    siteId = viewSettings.SiteId;
    UpdateToolbarButtons();
    body_onresize();
    debounceAll();

    // Set ready check grid to min height XN 8Aug16 159843
    resizeGridToMin('divReadyToAssemble',                       'gcReadyToAssemble'                         );
    resizeGridToMin('divReadyToCheckIndividualCheck',           'gcReadyToCheckIndividualCheck'             );
    resizeGridToMin('divReadyToCheckIndividualCheckSingleUser', 'gcReadyToCheckIndividualCheckSingleUser'   );
    resizeGridToMin('divReadyToCheckLabel',                     'gcReadyToCheckLabel'                       );

    // disable all check boxes that are read only
    if ($('#hfReadToCheckIfEnabled').val() == '1')
        $('#trReadToCheck tr[ReadOnlyCheckBox] input:checked').attr('disabled', 'disabled');
    else
        $('#trReadToCheck input[type=checkbox]').attr('disabled', 'disabled');

    if ($('#pnMain').scrollTop() == 0)
        $('#pnMain').scrollTop(pnMainYScrollPos);

    Sys.WebForms.PageRequestManager.getInstance().remove_beginRequest(beginRequestHandler);
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(beginRequestHandler);

    window.document.getElementById('__EVENTARGUMENT').value = '';

    ReadyToAssembleUpdateLabels();
}

// Called when page is going back to server
function beginRequestHandler()
{
    pnMainYScrollPos = $('#pnMain').scrollTop();
}

// Resize the page
function body_onresize()
{
    var panel = $('#pnMain');
    var btns  = $('#divBtns');
    panel.height(document.body.clientHeight - Math.max(panel.offset().top, 172) - btns.height() - 15);
}

// Called when page closes will clean up data from the cache
function body_onunload() {

    //19Aug16 KR Added Bug 160552 : aMM- Compounding - Camera stops displaying the preview  when something is done on compounding screen
    var imagecapture = document.getElementById("ImageCapture");
    if (imagecapture) imagecapture.DisableCapture();

    window.returnValue = viewSettings.RequestId.toString(); 

    // Clean up cached data
    var parameters =
        {
            sessionId : sessionId,
            requestId : viewSettings.RequestId
        };
    PostServerMessage("AmmSupplyRequest.aspx/CleanUp", JSON.stringify(parameters));
}

function body_onkeydown()
{
    switch (event.keyCode)
    {
    case 27: window.close(); break; //escape
    case 38: // up
    case 40: // down
        gridcontrol_onkeydown_internal('gcReadyToAssemble', event);
        break;
    }
}

// Called when read to check button is clicked will save all checked ingredients to hfCheckedItems
function btnReadyToCheck_OnClick(secondCheckControlId)
{
    if (secondCheckControlId != undefined && typeof(validateSecondCheck) === 'function' && !validateSecondCheck(sessionId, secondCheckControlId))
		return false;
	
	var ids = '';
    getCheckedRows('gcReadyToCheckIndividualCheck').each(function()
    {
        ids += $(this).attr('DBID') + ',';
    });
    getCheckedRows('gcReadyToCheckIndividualCheckSingleUser').each(function()
    {
        ids += $(this).attr('DBID') + ',';
    });

    $('#hfCheckedItems').val(ids);
	
	return true;
}

// Call when view prescription button is clicked
// Will display the prescription
function aMMSupplyRequest_ViewRx() 
{
    var result = GetOCSActionDataForRequest(sessionId, viewSettings.RequestId_Parent);
    if (result != undefined)
    	OCSAction(sessionId, OCS_VIEW, result.xmlItem, result.xmlType, undefined, xmlStatusNoteFilter, null, null);    
}

// Call when view history button is clicked
// Displays the supply request note history
function aMMSupplyRequest_ViewHistory() 
{
    var url = '../pharmacysharedscripts/SSRSReport.aspx?SessionID=' + sessionId + '&SiteID=' + siteId + '&ReportFile=Manufacturing\\aMMSupplyRequestHistory.rdlc&SP=pAMMRequestHistory&Params=RequestID:' + viewSettings.RequestId + '&Title=AMM Supply Request History&ShowPrintButton=No';
    var ret = window.showModalDialog(url, '', 'status:off; center:Yes');
    if (ret == 'logoutFromActivityTimeout') {
        window.returnValue = 'logoutFromActivityTimeout';
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

}

// Called when view attach note button is clicked
// Will display the attach note
function aMMSupplyRequest_AttachNote() 
{ 
    var result = GetOCSActionDataForRequest(sessionId, viewSettings.RequestId);
    if (result != undefined)
        OCSAction(sessionId, OCS_ANNOTATE, result.xmlItem, result.xmlType, undefined, xmlStatusNoteFilter, null, null);    
}

// Called when add report error is displayed
// Will display aMM report error page
function aMMSupplyRequest_ReportError() 
{    
   var ret= window.showModalDialog('../aMMWorkflow/AMMReportError.aspx' + getURLParameters(), '', 'status:off; center:Yes');
    if (ret == 'logoutFromActivityTimeout') {
        window.returnValue = 'logoutFromActivityTimeout';
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }


}

// Call when item enquiry button is clicked
// Will display the item enquiry screen for the drug
function aMMSupplyRequest_ItemEnquiry() {
    var strURLParameters = getURLParameters();
    strURLParameters += '&NSVCode=' + viewSettings.NSVCode;
    var ret = window.showModalDialog('../StoresDrugInfoView/ICW_StoresDrugInfoView.aspx' + strURLParameters, '', 'dialogHeight:735px; dialogWidth:865px; status:off; center:Yes');
    if (ret == 'logoutFromActivityTimeout') {
        window.returnValue = 'logoutFromActivityTimeout';
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
}

// Called when log viewer button is clicked
// Will display the translog viewer for the drug
function aMMSupplyRequest_LogViewer() {

    //19Aug16 KR Added Bug 160552 : aMM- Compounding - Camera stops displaying the preview  when something is done on compounding screen
    var imagecapture = document.getElementById("ImageCapture");
    if (imagecapture) imagecapture.DisableCapture();

    __doPostBack('upMain', 'LogViewer');
}

// Call when view undo button is clicked
// Undoes current stage
function aMMSupplyRequest_Undo() 
{
    __doPostBack('upMain', 'Undo');
}

// Call when view stop button is clicked
// Stop the supplier request
function aMMSupplyRequest_Cancel() {
    
    var parameters ={
                        sessionId:                  sessionId,
                        requestIdAmmSupplyRequest:  viewSettings.RequestId
                    };
    var result = PostServerMessage('AmmSupplyRequest.aspx/HasIssued', JSON.stringify(parameters));
    if (result != undefined && result.d)
    {
        if (!confirm('Stock has been issued.\nIf you continue, then manually return stock to the correct level.\nOK to continue.'))
            return;
    }

    SaveCanelOrderToState(sessionId, viewSettings.RequestId, 'Supply Request');
	
	var url = '../OrderEntry/StopItemsModal.aspx?SessionID=' + sessionId + '&Action=load&DispensaryMode=0';
    var result = window.showModalDialog(url, null, OrderEntryFeaturesV11());
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

	if (result == 'refresh') 
		__doPostBack('upMain', 'Cancelled');
}

// Call when print worksheet button is clicked
// Prints the worksheet
function aMMSupplyRequest_PrintWorksheet() {

    //19Aug16 KR Added Bug 160552 : aMM- Compounding - Camera stops displaying the preview  when something is done on compounding screen
    var imagecapture = document.getElementById("ImageCapture");
    if (imagecapture) imagecapture.DisableCapture();

    if (viewSettings.ApplicationPath == '') 
    {
        alert("Desktop parameter ApplicationPath not set.");
        return;
    }

    ShowProgressMsg(this, undefined);

    __doPostBack('upMain', 'PrintWorksheet');
}

// Call when reprint worksheet button is clicked
// Reprints the worksheet
function reprintWorksheet() 
{
    ShowProgressMsg(this, undefined);

    var filename  = GetLocalTempFilename(sessionId, siteId);
    writeFile(filename, worksheet);
    AscribeVB6PrintJob(sessionId, siteId, viewSettings.ApplicationPath, filename, 'ManWkSheet', 1);
}

// Call when print label button is clicked (either does a print or a reprint)
// Prints the worksheet
function aMMSupplyRequest_PrintLabel() 
{   
	var mode = ($('#lbPrintedLabel').text() == 'Yes') ? 'R' : 'P';	
	var parameters = getURLParameters() + "&PrintMode=" + mode;
		
    var wlabelId = window.showModalDialog('AmmLabel.aspx' + parameters, '', 'status:off;center:Yes');
    if (wlabelId == 'logoutFromActivityTimeout') {
        wlabelId = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

	if (wlabelId != undefined)
		__doPostBack('upMain', 'PrintedLabel:' + mode + ':'  + wlabelId);
}

// Call when issue button is clicked
// Issues something?
function aMMSupplyRequest_Issue() {

    //19Aug16 KR Added Bug 160552 : aMM- Compounding - Camera stops displaying the preview  when something is done on compounding screen
    var imagecapture = document.getElementById("ImageCapture");
    if(imagecapture) imagecapture.DisableCapture();

    __doPostBack('upMain', 'Issue');
}

// Call when return button is clicked
// return something?
function aMMSupplyRequest_Return() {

    //19Aug16 KR Added Bug 160552 : aMM- Compounding - Camera stops displaying the preview  when something is done on compounding screen
    var imagecapture = document.getElementById("ImageCapture");
    if (imagecapture) imagecapture.DisableCapture();

    __doPostBack('upMain', 'Return');
}

// called when btnReadyToAssembleSelect onclick is called
function btnReadyToAssembleSelect_OnClientClick()
{
    window.showModalDialog('IngredientWizard.aspx' + getURLParameters(), '', 'status:off; center: Yes');
    __doPostBack('upMain', 'AddIng'); // refresh
}

function btnReadyToCheck_OnClientClick()
{
    var strURLParameters = getURLParameters();
    var res = window.showModalDialog('../aMMWorkflow/aMMCheckWizard.aspx' + strURLParameters, '', 'status:off;center:Yes');
    if (res == 'ok')
        __doPostBack('upMain', 'MoveNextStage');
}

function btnReadyToCompoundShowMethod_onclick()
{
    //19Aug16 KR Added Bug 160552 : aMM- Compounding - Camera stops displaying the preview  when something is done on compounding screen
    var imagecapture = document.getElementById("ImageCapture");
    if (imagecapture) imagecapture.DisableCapture();
}

function showMethod(filename, methodFilename)
{
    ShowProgressMsg(this, undefined);
    //var rtf = readFile(filename);                                        // read rtf template from network
    //19Jun17 TH Replaced call above to read from DB (TFS 174878)
    var rtffile1 = filename.split('\\').pop().split('/').pop();
    var rtffile2 = rtffile1.replace(/\.[^.$]+$/, ''); //get rid of extension
    if (filename.toLowerCase().indexOf('wksheets\\') > 0) {
        rtffile2 = 'WRKSHEET|' + rtffile2;
    }
    var rtfparameters =
    {
        sessionId: sessionId,
        siteId: siteId,
        Name: rtffile2
    };

    var rtfdata = PostServerMessage('AmmSupplyRequest.aspx/ReadRTF', JSON.stringify(rtfparameters));
    var rtf = rtfdata.d;
    //19Jun17 TH End (TFS 174878)

    //var methodRtf = ifFileExists(methodFilename) ? readFile(methodFilename) : '';  // read rtf of method file
    //19Jun17 TH Replaced call above to read from DB (TFS 174878)
    var methodfile = methodFilename.split('\\').pop().split('/').pop();
    var methodfile2 = methodfile.replace(/\.[^.$]+$/, ''); //get rid of extension

    if (methodFilename.toLowerCase().indexOf("wksheets\\") > 0) {
        methodfile2 = "WRKSHEET|" + methodfile2;
    }

    var methodparameters =
    {
        sessionId: sessionId,
        siteId: siteId,
        Name: methodfile2
    };
    var methodRtfdata = PostServerMessage('AmmSupplyRequest.aspx/ReadRTF', JSON.stringify(methodparameters));
    var methodRtf = methodRtfdata.d
    //19Jun17 TH End (TFS 174878)

    var savedRtf  = false;

    if (rtf != undefined)
    {
        // Parse rtf
        var parameters =
        {
            sessionId:                  sessionId,
            siteId:                     siteId,
            requestIdAmmSupplyRequest:  viewSettings.RequestId,
            layoutName:                 '',
            rtf:                        rtf,
            methodRtf:                  methodRtf,
            saveToReprints:             false,
            labelText:                  '',
            freeText:                   ''
        };

        var result = PostServerMessage('AmmSupplyRequest.aspx/ParseReport', JSON.stringify(parameters));
        if (result != undefined)
        {
            filename = GetLocalTempFilename(sessionId, siteId);
            writeFile(filename, result.d);
            savedRtf = true;
        }
    }

    HideProgressMsg(this, undefined);

    if (savedRtf)
    {
        window.showModalDialog('ViewMethod.aspx?localFile=' + filename, '', 'status:off;center:Yes;resizable:Yes');
        deleteFile(filename);
    }
}

// Update the state of the buttons
function UpdateToolbarButtons()
{
    var radToolbar = $find("radToolbar");

    //ToolMenuEnable(radToolbar, "aMMSupplyRequest_AttachNote",  !viewSettings.ReadOnly );
    ToolMenuEnable(radToolbar, "aMMSupplyRequest_ReportError", 		!viewSettings.ReadOnly );
    ToolMenuEnable(radToolbar, "aMMSupplyRequest_Undo",             !viewSettings.ReadOnly && viewSettings.IfCanUndo && !viewSettings.IsPrescriptionCancelled);
    ToolMenuEnable(radToolbar, "aMMSupplyRequest_Cancel",      		!viewSettings.ReadOnly && viewSettings.IfCanStop);
    ToolMenuEnable(radToolbar, "aMMSupplyRequest_PrintLabel",       !viewSettings.ReadOnly && !viewSettings.IfPreventPostBack && !viewSettings.IsPrescriptionCancelled);
    ToolMenuEnable(radToolbar, "aMMSupplyRequest_ReprintLabel",     !viewSettings.ReadOnly && !viewSettings.IfPreventPostBack && !viewSettings.IsPrescriptionCancelled);
    ToolMenuEnable(radToolbar, "aMMSupplyRequest_PrintWorksheet",  	!viewSettings.ReadOnly && viewSettings.IfCanPrintWorksheet && !viewSettings.IfPreventPostBack && !viewSettings.IsPrescriptionCancelled);
    ToolMenuEnable(radToolbar, "aMMSupplyRequest_ReprintWorksheet", !viewSettings.ReadOnly && viewSettings.IfCanPrintWorksheet && !viewSettings.IfPreventPostBack && !viewSettings.IsPrescriptionCancelled);
    ToolMenuEnable(radToolbar, "aMMSupplyRequest_Issue",       		!viewSettings.ReadOnly && !viewSettings.IfPreventPostBack && !viewSettings.IsPrescriptionCancelled);
    ToolMenuEnable(radToolbar, "aMMSupplyRequest_PrintIssue",       !viewSettings.ReadOnly && !viewSettings.IfPreventPostBack && !viewSettings.IsPrescriptionCancelled);
    ToolMenuEnable(radToolbar, "aMMSupplyRequest_Return",           !viewSettings.ReadOnly && !viewSettings.IfPreventPostBack);
    ToolMenuEnable(radToolbar, "aMMSupplyRequest_LogViewer",        !viewSettings.IfPreventPostBack);
}

// Updates the state of the toolbar
function ToolMenuEnable(toolbar, eventName, enable)
{
    var button = null;
    if (toolbar != null)
        button = toolbar.findItemByAttribute("eventName", eventName);

    if (button != null)
        button.set_enabled(enable);
}

// Scroll panel to currently active stage
function scrollToActiveStage()
{
    var activeStage = $('.StageActive');
    if (activeStage.length == 0)
        return;

    // If at second check stage (and no second check gird) then ensure the user can see the ready to assemble ingredients
    var mainPanel = $('#pnMain');
    if (activeStage.attr('id') == 'lbStage3' && $('#gcReadyToCheckIndividualCheck').length == 0 && $('#gcReadyToCheckIndividualCheckSingleUser').length == 0)
        pnMainYScrollPos = $('#lbStage2').parent().parent().offset().top - mainPanel.offset().top;
    else
        pnMainYScrollPos = activeStage.parent().parent().offset().top - mainPanel.offset().top;
    mainPanel.scrollTop(pnMainYScrollPos);

    // For some odd reason need to let the above complete processing before setting focus
    setTimeout(function() { $('input:visible:enabled', activeStage.parent().parent()).first().focus(); }, 60);
}

// Called at validate waiting for schedule stage and all of the slots are currenlty filled
// Warns user, and set hfConfirmShiftFull that they have confirmed
function allSlotsFilledMsg()
{
    var ulr = '../pharmacysharedscripts/Confirm.aspx?DefaultButton=Cancel&Msg=' + URLEscape('All available slots are filled for this shift.<br />Do you want to continue?');
    if (window.showModalDialog(ulr))
    {
         $('#hfConfirmShiftFull').val('1'); 
         $('#btnWaitingSchedulingSave').click();
    }
}

// Updates the label at the bottom of the screen
function ReadyToAssembleUpdateLabels(grid, panel)
{
    var row = getSelectedRow(grid);
    if (row.length == 0)
        clearLabels(panel); // No row selected so clear bottom panel
    else
    {
        // populate panel row panel details
        $(getAllPanelLabelNames(panel)).each(function() 
        { 
            setPanelLabelHtml(panel, this, row.attr(this)); 
        });
    }
}

// Called when item in grid is selected
function pharmacygridcontrol_onselectrow(controlID, rowindex)
{
    if (controlID == 'gcReadyToAssemble')
    {
        // Store selected item from the ready to assemble grid
        $('#hfReadyToAssembleSelectedRowDBID').val(getSelectedRow('gcReadyToAssemble').attr('DBID'));
        ReadyToAssembleUpdateLabels('gcReadyToAssemble', 'pcReadyToAssemble');
    }
    else if (controlID == 'gcReadyToCheckIndividualCheck')
        ReadyToAssembleUpdateLabels('gcReadyToCheckIndividualCheck', 'pcReadyToCheckIndividualCheck');
    else if (controlID == 'gcReadyToCheckIndividualCheckSingleUser')
        ReadyToAssembleUpdateLabels('gcReadyToCheckIndividualCheckSingleUser', 'pcReadyToCheckIndividualCheckSingleUser');
    else if (controlID == 'gcReadyToCheckLabel')
        ReadyToAssembleUpdateLabels('gcReadyToCheckLabel', 'pcReadyToCheckLabel');
}

// Called when user confirms they want to go ahead with the issue
// Will then implement the issue
function issueConfirmCallBackFn(arg) 
{
    if (arg) 
        __doPostBack('upMain', 'IssueConfirmed');
}

// Called when user confirms they want to go ahead with the return
// Will then implement the return
function returnConfirmCallBackFn(arg) 
{
    if (arg)
        __doPostBack('upMain', 'ReturnConfirmed');
}

// Called by server to allow the user to select a worksheet to print
function selectSheet(wformulaId) 
{
    var strURLParameters = getURLParameters();
    var url = 'SelectWorksheet.aspx' + strURLParameters + '&wformulaId=' + wformulaId;
    if (url == 'logoutFromActivityTimeout') {
        url = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (url)
        var selectedItem = window.showModalDialog(url);
    if (selectedItem != undefined) 
        __doPostBack('upMain', 'PrintWorksheet:' + selectedItem);
}

// Loads rtf file from the network, and parses it on the server, and then prints
function loadAndPrint(filename, methodFilename, layout, createLabel) 
{
    ShowProgressMsg(this, undefined);

    //Now send file Name only - we need to get these from the DB (TFS 174878)
    var rtffile1 = filename.split('\\').pop().split('/').pop();
    var rtffile2 = rtffile1.replace(/\.[^.$]+$/, ''); //get rid of extension
    if (filename.toLowerCase().indexOf('wksheets\\') > 0) {
        rtffile2 = 'WRKSHEET|' + rtffile2; 
    }
    var rtfparameters =
    {
        sessionId: sessionId,
        siteId: siteId,
        Name: rtffile2
    };
    var rtfdata = PostServerMessage('AmmSupplyRequest.aspx/ReadRTF', JSON.stringify(rtfparameters));

    //var methodRtf = ifFileExists(methodFilename) ? readFile(methodFilename) : '';  // read rtf of method file
    //Now send file Name only - we need to get these from the DB (TFS 174878)
    var methodfile = methodFilename.split('\\').pop().split('/').pop();
    var methodfile2 = methodfile.replace(/\.[^.$]+$/, ''); //get rid of extension

    if (methodFilename.toLowerCase().indexOf("wksheets\\") > 0) {
        methodfile2 = "WRKSHEET|" + methodfile2;
    }
    
    var methodparameters =
    {
        sessionId: sessionId,
        siteId: siteId,
        Name: methodfile2
    };
    var methodRtfdata = PostServerMessage('AmmSupplyRequest.aspx/ReadRTF', JSON.stringify(methodparameters));

    

    var printing  = false;
    var label     = '';
    var freetext  = '';

    //if (rtf == undefined)  //21Jun17 TH Replaced (TFS 187187)
    if (rtfdata == undefined) //22Jun17 TH Made right case !!
        return;

    // if rtf contains freetext option then ask user to enter it 22Aug16 XN 160920
    //if (rtf.toLowerCase().indexOf('[freetext]') >= 0)
    if (rtfdata.d.toLowerCase().indexOf('[freetext]') >= 0)
    {
        var strURL = new String();
        var astrURL = new Array();
        var intCount = new Number();
        var strMessageBoxURL = new String();
        var objArgs = new Object();

        // If title not specific then set default
        objArgs.title   = 'EMIS Health ICW';
        objArgs.button1 = 'OK,y';
        objArgs.button2 = 'Cancel,x';
        objArgs.mask    = 'ANY';
        objArgs.defaultValue = '';
        objArgs.text    = 'Enter one line of free text, if desired';
        objArgs.required = false;

        freetext = window.showModalDialog('../sharedscripts/InputBox.htm', objArgs, 'dialogHeight:200px;dialogWidth:300px;resizable:yes;status:no;help:no;');
        if (freetext == null || freetext == undefined)
            freetext = '';
    }

    if (createLabel)
    {
        var parameters = getURLParameters();
        parameters += "&PrintMode=T";
        label = window.showModalDialog('AmmLabel.aspx' + parameters, '', 'status:off;center:Yes;');
        if (label == 'logoutFromActivityTimeout') {
            label = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }

    }

    var methodRtf = '';
    if (methodRtfdata != undefined)
        methodRtf =methodRtfdata.d;

    var parameters =
    {
        sessionId                   : sessionId,
        siteId                      : siteId,
        requestIdAmmSupplyRequest   : viewSettings.RequestId,
        layoutName                  : layout,
        rtf                         : rtfdata.d,
        methodRtf                   : methodRtf,   
        saveToReprints              : true,
        labelText                   : label,
        freeText                    : freetext
    };

    var result = PostServerMessage('AmmSupplyRequest.aspx/ParseReport', JSON.stringify(parameters));
    if (result != undefined && result.d != null)
    {
        var filename = GetLocalTempFilename(sessionId, siteId);
        writeFile(filename, result.d);
        AscribeVB6PrintJob(sessionId, siteId, viewSettings.ApplicationPath, filename, 'ManWkSheet', 1);
		$('#lbPrintedWorksheet').text('Yes');
        printing = true;
    }
    else {
        alert("Missing Worksheet RTF " + filename);
    }

    if (!printing)
    {
        HideProgressMsg(this, undefined);
    }
}

// Initialise the dispensing control
function connectToDispensingCtrl(requestId_Prescription, requestId_AmmSupplyRequest, RequestId_Dispensing) 
{
    $(document.getElementById('fraDispensing').document).ready(function ()
    {
        setTimeout(function ()
        {
            if (document.getElementById('fraDispensing').contentWindow != undefined)
            {
                document.getElementById('fraDispensing').contentWindow.RefreshStateForAmm(requestId_Prescription, requestId_AmmSupplyRequest, RequestId_Dispensing);
                $('#btnLabel').enable(true);
            }
        }, 1500);
    });
}

// Called when ready to compound button is clicked
function btnReadyToCompound_onclick()
{
    var ok = true;
    if ($('#ImageCapture').length > 0 && $('#hfImageData').length > 0 && $.trim($('#hfImageData').val()).length == 0)
        ok = confirm('Do you want to compound without taking\na picture of the completed product?');
    return ok;
}

// Called when label button is clicked
function btnLabel_onclick()
{
    if (viewSettings.isActiveXControlEnabled)
        var wlabelId = document.getElementById('fraDispensing').contentWindow.PrintLabel(viewSettings.RequestId, parseInt($('#hfNumberOfLabels').val()), true, true);
    if (wlabelId != 0) 
    {
        $('#hfWLabelId').val(wlabelId);
        __doPostBack('upMain', 'MoveNextStage');
    }
}

// ask use if they want to issue, and if so the postback confirmation
// 25May16 XN 154185
function askToIssue(msg)
{
    if (confirm(msg))
        __doPostBack('upMain', 'IssueConfirmed');
}

// All code below is to do with image capture.

// Function that called when ImageCapture control takes a picture
function ImageCapture_OnImageCaptured(asUniqueId, asFileName, binJPEGData) {
    var picture = document.getElementById("imgManufacturedProduct");
    var hidden = document.getElementById("hfImageData");
    var objStores = document.getElementById("objStores");
   
   //set the new image in the local browser
    picture.src = asFileName;
    
    //set the hidden field to a base64 encoded version of the image for saving on the server
    hidden.value = objStores.ConvertTobase64(asFileName);
}


function EnableCapture() {
    var imagecapture = document.getElementById("ImageCapture");
    var btnTakePicture = document.getElementById("btnTakePicture");
    
    if (imagecapture.EnableCapture()) {
        try {
            
            if (imagecapture.AllowManualTrigger())
                btnTakePicture.style.display = ""; 
            else
                btnTakePicture.style.display = "none";             
        }
        catch (ex) {
            btnTakePicture.style.display = "none";
        }
    }
}

// Resize the grid to the min required to show all rows (min height is 83px)
// div - div that the grid is in
// grid- name of the grid
// XN 8Aug16 159843
function resizeGridToMin(div, grid)
{
    if ($('#' + div).length > 0)
    {
        var totalHeight = 0;
        getVisibleRows(grid).each(function ()
        {
            totalHeight += this.offsetHeight;
        });
        totalHeight = Math.max(totalHeight + 10, 83);
        $('#' + div).height(totalHeight + 'px');
    }
}
