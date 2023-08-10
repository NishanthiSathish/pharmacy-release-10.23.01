
//function form_onload()  12Aug13 XN 70138 FastRepeat 
function form_onload(autoDispenseAtStart, requestID_SelectAtStart) 
{
    // Enable\disable non request specific buttons
    // ToolMenuEnable('DispensingList_PrescriptionNew',    viewSettings.ViewMode == "Current" && m_EpisodeID > 0 && !viewSettings.EnableEMMRestrictions);  11Spet13 XN 72983 prevent script error by not doing complete post back // 22Mar13 XN 43495 Disable button if enforcing eMMRestrictions and on emm ward
    // ToolMenuEnable("DispensingList_PrescriptionNewPSO", m_EpisodeID > 0 && !viewSettings.EnableEMMRestrictions);  11Spet13 XN 72983 prevent script error by not doing complete post back // 22Mar13 XN 43495 Disable button if enforcing eMMRestrictions and on emm ward//14Feb13 TH  56201 Added PSO Rx Button
    // ToolMenuEnable('DispensingList_PrescriptionNewPCT', m_EpisodeID > 0 && !viewSettings.EnableEMMRestrictions);  11Spet13 XN 72983 prevent script error by not doing complete post back // 22Mar13 XN 43495 Disable button if enforcing eMMRestrictions and on emm ward  
    ToolMenuEnable('DispensingList_PrescriptionNew',    viewSettings.ViewMode == "Current" && m_EpisodeID > 0 && viewSettings.eMMAllowsPrescribing);  // 22Mar13 XN 43495 Disable button if enforcing eMMRestrictions and on emm ward
    ToolMenuEnable("DispensingList_PrescriptionNewPSO", m_EpisodeID > 0 && viewSettings.eMMAllowsPrescribing);  // 22Mar13 XN 43495 Disable button if enforcing eMMRestrictions and on emm ward//14Feb13 TH  56201 Added PSO Rx Button
    ToolMenuEnable('DispensingList_PrescriptionNewPCT', m_EpisodeID > 0 && viewSettings.eMMAllowsPrescribing);  // 22Mar13 XN 43495 Disable button if enforcing eMMRestrictions and on emm ward  
    ToolMenuEnable('DispensingList_PatientPrint',       m_EpisodeID > 0);
    ToolMenuEnable('DispensingList_PatientBagLabel',    m_EpisodeID > 0);
    ToolMenuEnable('DispensingList_UMMCBilling',        m_EpisodeID > 0);
    ToolMenuEnable('FastRepeat',                        true           ); 
    ToolMenuEnable('DispensingList_PatientInvoice',       m_EpisodeID > 0);   

    refreshRowStripes();
    worklist_resize();

//  11Spet13 XN 72983 prevent script error by not doing complete post back 
//    // If requested row to selected at start (12Aug13 XN 70138 FastRepeat)
//    var selectedRow = null;
//    if (requestID_SelectAtStart != null && requestID_SelectAtStart != '') {
//        var selectedRow = FindRow(requestID_SelectAtStart);
//        if (selectedRow != null)
//            RowSelect(selectedRow);
//    }

    // Select first row in grid and set focus
    var gridRows = $('#tbdy tr');         
    if (gridRows.length > 0)
        RowSelect(gridRows[0], 'single');
    SetFocus();


//  11Spet13 XN 72983 prevent script error by not doing complete post back
//    if (selectedRow == null) {
//        selectedRow = $('#tbdy tr:first');
//        if (selectedRow.length > 0)
//            RowSelect(selectedRow, 'single');
//        SetFocus();
//    }
//
//    // If auto dispense at start up (12Aug13 XN 70138 FastRepeat)
//    // Normaly when set requestID_SelectAtStart
//    if (autoDispenseAtStart)
//        Dispense();

    // Set postback progress message
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(ShowProgressMsg);
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(HideProgressMsg);
}

function worklist_resize()
{
    if ($('#tbl-container').length > 0)
    {
        var height = $(window).height() - $('#tbl-container').offset().top;
        if (height < 0)
            height = 0;
        $('#tbl-container').height(height);
    }
}
        
function DoAction(actionType, fpRefresh)
{
    //Wrapper to OCSAction, called from the toolbar/menu event handlers	
    PrepareOCSData();
    var strNewItem_XML = OCSAction_Batch(m_SessionID, actionType, xmlItem.selectNodes("root/*"), xmlType, fpRefresh, xmlStatusNoteFilter, null, null, DEFAULT_TRACKCHANGES_VALUE, undefined, true);
    SetFocus();
    return strNewItem_XML;
}  
        
function DoAction_ViewDSSOverrides(lngItemID) 
{
    var strURL = ICWLocation(m_SessionID) + '/application/DSSWarningsLogViewer/DSSOverriddenWarningsForRequestDisplay.aspx?SessionID=' + m_SessionID + '&requestId=' + lngItemID + '&Date=' + new Date().getTime().toString();
    var ret=window.showModalDialog(strURL, '', 'dialogHeight:700px;dialogWidth:1000px;resizable:yes;unadorned:no;status:no;help:no;');
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

}
        
function PrepareOCSData() 
{        
    var selectedRows = GetSelectedRows();
    var strItem_XML = '';
    var strType_XML = '';
    
    for(var r = 0; r < selectedRows.length; r++)
    {
        var tr = selectedRows[r];
        
        // Translate this grid's info into OrderComms lingo.
        strItem_XML += '<item class="request" dbid="' + tr.getAttribute('id') + '"'
				            + ' description="' + XMLEscape($(tr).children(1).innerText) + '"'														
				            + ' detail="' + XMLEscape($(tr).children(1).innerText) + '"'
				            + ' RequestTypeID="' + tr.getAttribute('requestTypeID') + '"'
				            + ' tableid=""'
				            + ' productid=""'
				            + ' autocommit=""'
				            + ' CreationType=""';
					        
        // Copy rest of attributes to ocsitem node
        for (var intIndex = 0; intIndex < tr.attributes.length; intIndex++) 
        {
            var strAttribName  = tr.attributes(intIndex).nodeName;
            if (strAttribName.substr(0, 3) == "SB_") 
            {
                strAttribName = strAttribName.substr(3, 999);
                strItem_XML += ' ' + strAttribName + '="' + tr.attributes(intIndex).nodeValue + '" ';
            }
        }
        strItem_XML += ' />';
        
        strType_XML += '<RequestType RequestTypeID="' + tr.getAttribute('requestTypeID') + '" Description="Prescription" Orderable="1" />';
    }

    xmlItem.XMLDocument.loadXML('<root>' + strItem_XML + '</root>');
    xmlType.XMLDocument.loadXML('<root>' + strType_XML + '</root>');
}        
        
function PrescriptionNewPCT() 
{
    var strXML = "";
    var strException = "";
    var Exceptions;
    var DOM;
    var lngHeight = 450;
    var lngWidth = 650;
    var ret;
    var undefined;

    var strReturn = new String();
    var blnShowOrderEntry = true;

    var lngPCTPrescriptionID = window.showModalDialog("../PCT/PCTPrescription.aspx?SessionID=" + m_SessionID, "",  "dialogHeight: " + lngHeight + "px; dialogWidth: " + lngWidth + "px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: No; status: No;");
    if (lngPCTPrescriptionID == 'logoutFromActivityTimeout') {
        lngPCTPrescriptionID = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if ((lngPCTPrescriptionID != '') && (lngPCTPrescriptionID != undefined))
    {

        intWidth = screen.width / 1.1; //27Nov06 ST Made wider
        intHeight = screen.height / 1.6;

        if (intWidth < 800) { intWidth = 800 };
        if (intHeight < 600) { intHeight = 600 };

        var strFeatures = 'dialogHeight:' + intHeight + 'px;dialogWidth:' + intWidth + 'px;resizable:no;status:no;help:no;';  // + 'resizable:yes;' XN 4Oct12 45896 It is a risk to have the task picker resizable!!!!!

        //Show the task picker:
        strURL = ICWLocation(m_SessionID) + '/application/TaskPicker/TaskPickerModal.aspx?SessionID=' + m_SessionID + '&Show_Contents=Yes&Show_Favourites=Yes&Show_Search=Yes&Use_Order_Basket=No'
                            + '&DispensaryMode=1&RequestTypeFilter=' + treatmentPlanRequestTypeID.toString() + '&HideFilteredTypes=true';        // XN 59791 25Mar13 fix task picker issue 23May05 AE  Use new taskpicker 

        var strArgs = '<root singleitemonly="1" />';

        //30Jun2010 JMei F0040487 Passing the caller self and a xml message to modal dialog so that modal dialog can access its opener
        var objArgs = new Object();
        objArgs.opener = self;
        objArgs.Message = strArgs;
        if (window.dialogArguments == undefined)
            objArgs.icwwindow = window.parent.ICWWindow();
        else
            objArgs.icwwindow = window.dialogArguments.icwwindow;

        var strNewItem_XML = window.showModalDialog(strURL, objArgs, strFeatures);
        if (strNewItem_XML == 'logoutFromActivityTimeout') {
            strNewItem_XML = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }


        //Deal with the items the user selected.
        //TaskPicker returns a blank string if the user cancels.
        if (strNewItem_XML != '' && strNewItem_XML != undefined && strNewItem_XML.indexOf('<saveok ') >= 0) 
        {
            //Item has been committed
            //Load the returned xml into our data island for parsing
            //Now search to make sure that there is at least one 'template' type node
            //Can only be a single item since we are forcing the task picker into "nobasket" mode
            var xmlDoc = $.parseXML(strNewItem_XML);
            var requestID_Prescription = Number($('saveok', xmlDoc).attr('id'));

            var strURL = '../PCT/PCTPrescription.aspx?SessionID=' + m_SessionID + '&Method=LinkPCTPrescription&PCTPRescriptionID=' + lngPCTPrescriptionID + '&RequestID_Prescription=' + requestID_Prescription;

            m_objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
            m_objHTTPRequest.open("GET", strURL, false);
            m_objHTTPRequest.send();

            // Reload self (also does dispensing)
            RefreshGrid(requestID_Prescription, true);
        }
        else
            SetFocus(); // 60286 02Apr13 XN Only set focus back to grid if not dispensing
    }
}
        
function PrescriptionNew() 
{
    var refreshed = false;

    //Determine the size to show the task picker in.
    //F0093562 09Aug10 JMei make sure Width of Task Picker is around 90% of screen width
    var intWidth = screen.width / 1.1; //27Nov06 ST Made wider
    var intHeight = screen.height / 1.6;

    if (intWidth < 800) { intWidth = 800 };
    if (intHeight < 600) { intHeight = 600 };

    var strFeatures = 'dialogHeight:' + intHeight + 'px;dialogWidth:' + intWidth + 'px;resizable:no;status:no;help:no;';  // + 'resizable:yes;' XN 4Oct12 45896 It is a risk to have the task picker resizable!!!!!

    //Show the task picker:
    var strURL = ICWLocation(m_SessionID) + '/application/TaskPicker/TaskPickerModal.aspx?SessionID=' + m_SessionID + '&Show_Contents=Yes&Show_Favourites=Yes&Show_Search=Yes&Use_Order_Basket=No' +
                            '&DispensaryMode=1&RequestTypeFilter=' + treatmentPlanRequestTypeID.toString() + '&HideFilteredTypes=true';    // XN 59791 25Mar13 fix task picker issue 23May05 AE  Use new taskpicker

    //30Jun2010 JMei F0040487 Passing the caller self and a xml message to modal dialog so that modal dialog can access its opener
    var objArgs = new Object();
    objArgs.opener = self;
    objArgs.Message = '<root singleitemonly="1" />';
    if (window.dialogArguments == undefined)
        objArgs.icwwindow = window.parent.ICWWindow();
    else
        objArgs.icwwindow = window.dialogArguments.icwwindow;

    var strNewItem_XML = window.showModalDialog(strURL, objArgs, strFeatures);
    if (strNewItem_XML == 'logoutFromActivityTimeout') {
        strNewItem_XML = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }


    //Deal with the items the user selected.
    //TaskPicker returns a blank string if the user cancels.
    if ((strNewItem_XML != '') && (strNewItem_XML != undefined)) 
    {
        if (strNewItem_XML.indexOf('<saveok ') >= 0) 
        {	                
            // Reload self
            var xmlDoc = $.parseXML(strNewItem_XML);
            var requestID_Prescription = Number($('saveok', xmlDoc).attr('id'));
            
            RefreshGrid(requestID_Prescription, true);
        }
        else
            SetFocus(); // 60286 02Apr13 XN Only set focus back to grid if not dispensing
    }
    else
        SetFocus(); // 60286 02Apr13 XN Only set focus back to grid if not dispensing
}      

function PrescriptionNewPSO() {
    var refreshed = false;

    var strReturn = new String();
    var blnShowOrderEntry = true;

    //Determine the size to show the task picker in.
    //F0093562 09Aug10 JMei make sure Width of Task Picker is around 90% of screen width
    var intWidth = screen.width / 1.1; //27Nov06 ST Made wider
    var intHeight = screen.height / 1.6;

    if (intWidth < 800) { intWidth = 800 };
    if (intHeight < 600) { intHeight = 600 };

    var strFeatures = 'dialogHeight:' + intHeight + 'px;dialogWidth:' + intWidth + 'px;resizable:no;status:no;help:no;';  // + 'resizable:yes;' XN 4Oct12 45896 It is a risk to have the task picker resizable!!!!!

    //Show the task picker:
    var strURL = ICWLocation(m_SessionID) + '/application/TaskPicker/TaskPickerModal.aspx?SessionID=' + m_SessionID + '&Show_Contents=Yes&Show_Favourites=Yes&Show_Search=Yes&Use_Order_Basket=No' +
                            '&DispensaryMode=1&RequestTypeFilter=' + treatmentPlanRequestTypeID.toString() + '&HideFilteredTypes=true';    // XN 59791 25Mar13 fix task picker issue 23May05 AE  Use new taskpicker


    //30Jun2010 JMei F0040487 Passing the caller self and a xml message to modal dialog so that modal dialog can access its opener
    var objArgs = new Object();
    objArgs.opener = self;
    objArgs.Message = '<root singleitemonly="1" />';
    if (window.dialogArguments == undefined)
		objArgs.icwwindow = window.parent.ICWWindow();
    else
    	objArgs.icwwindow = window.dialogArguments.icwwindow;

    var strNewItem_XML = window.showModalDialog(strURL, objArgs, strFeatures);
    if (strNewItem_XML == 'logoutFromActivityTimeout') {
        strNewItem_XML = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    //Deal with the items the user selected.
    //TaskPicker returns a blank string if the user cancels.
    if ((strNewItem_XML != '') && (strNewItem_XML != undefined)) {
        if (strNewItem_XML.indexOf('<saveok ') >= 0) 
        {																					//18Jun05 AE  Removed the 'refresh' return value; now refreshes if anything has been saved
            // Reload self
            var xmlDoc = $.parseXML(strNewItem_XML);
            var requestID_Prescription = Number($('saveok', xmlDoc).attr('id'));

            // Reload self
            RefreshGrid(requestID_Prescription, false);
            // Send refresh to Dispensing control
            RAISE_Dispensing_RefreshState(requestID_Prescription, -5);
        }
        else
            SetFocus(); // 60286 02Apr13 XN Only set focus back to grid if not dispensing
    }
    else
        SetFocus(); // 60286 02Apr13 XN Only set focus back to grid if not dispensing
}

function DataChangedRefreshGrid() 
{
    // Callback function from OCSAction, used to update the grid, if required
    var selectedRows = GetSelectedRows();
    var requestID_Prescription = selectedRows.length == 1 ? Number(selectedRows.attr("id")) : 0; //25Aug11 TH Added to retain current posn
    RAISE_NoteChanged();
    RefreshGrid(requestID_Prescription, false);
}              

function DataChangedRefreshRow() 
{
    // Callback function from OCSAction, used to update the grid, if required
    var selectedRows = GetSelectedRows();
    var requestID_Prescription = selectedRows.length == 1 ? Number(selectedRows.attr("id")) : 0; //25Aug11 TH Added to retain current posn
    RAISE_NoteChanged();
    RefreshRow(requestID_Prescription, true, false);
}              

function FindRow(requestID)
{
    var row = $('#tbdy tr[id="' + requestID + '"]:first');
    return row.length == 0 ? null : row[0];
}

function GetSelectedRows()
{
    return $('#tbdy tr.RowSelected');
}

// When called returns the epiosde ID of the current row
// Not so simple as it first looks, as if row is dispensing row then need to get parent to get the id
// 66246 19Jun13 XN 
function GetRowEpisodeID(tr) 
{
    tr = $(tr);
    var rowType   = tr.attr('rowType')
    var episodeID = (rowType == 'Dispensing') ? $('#tbdy tr[id="' + tr.attr('id_parent') + '"]').attr('EpisodeID') : tr.attr('EpisodeID');
    return Number(episodeID);
}

function GetFocusedRow()
{
    return $('#tbdy tr.RowFocus').first()[0];
}
        
function ToolMenuEnable(buttonName, enable)
{
//    var button = $('#' + buttonName)  XN 11Mar13 58326 Button not active if more than 1 button on same type on screen.
    var button = $('button[id="' + buttonName + '"]')
    if (button != null)
    {
        if (enable)
            button.removeAttr('disabled');
        else
            button.attr('disabled', 'disabled');
    }
}

function ClearControl() 
{
    if (!controlCleared)    // XN 15Nov12 TFS47487 Only if not currently cleared
    {
        RAISE_Dispensing_RefreshState(0, 0);
        controlCleared = true;
    }
}        

// Updates the dispensing control with the selected prescription info.
function RefreshControl() 
{
    var selectedRows = GetSelectedRows();
    var lngRequestID_Prescription = 0;
    var lngRequestID_Dispensing   = 0;
    
    if (selectedRows.length == 1) 
    {
        switch (selectedRows[0].getAttribute("rowType")) 
        {
        case "Prescription":    // Prescription
        case "Merged":          // Merged Prescription
            lngRequestID_Prescription = Number(selectedRows[0].getAttribute("id"));
            lngRequestID_Dispensing   = 0;
            break;

        case "Dispensing":      // Dispensing
            lngRequestID_Prescription = Number(selectedRows[0].getAttribute("id_parent"));
            lngRequestID_Dispensing   = Number(selectedRows[0].getAttribute("id"));
            break;
        }
    }
    controlCleared = false;
    RAISE_Dispensing_RefreshState(lngRequestID_Prescription, lngRequestID_Dispensing);
}        

function Dispense() 
{
    var selectedRows = GetSelectedRows();
    if (selectedRows.length == 1 && parseBoolean(selectedRows.attr("current"))) 
        RefreshControl();
}          

function GetHighlightedRowXML() 
{
    PrepareOCSData();
    return xmlItem.selectNodes("*");
}

function UpdateToolbarButtons() 
{
    // get info on row
//  var currentRow        = GetFocusedRows();     XN 07Mar13 58235 can return last unselected row
    var allSelectedRows     = GetSelectedRows();
    var currentRow          = allSelectedRows.first();
//  var allCanStopOrAmend   = !allSelectedRows.is('[canStopOrAmend="0"]');   // Can the prescription be stopped or amended 18Jul13 XN 60657 moved to single foreach
    var rowType             = currentRow.attr('rowType');                    // row type can be 'Prescription', 'Merged', 'PN', 'Dispensing'
//  var allCurrent          = !allSelectedRows.is('[current="0"]');          // If prescription is current else expired 18Jul13 XN 60657 moved to single foreach
    var level               = currentRow.attr('level');                      // Prescription level
    var selectionCount      = allSelectedRows.length;                        // Number of prescriptions selected
    var singleSelection     = selectionCount == 1;                           // if currently mulit select
//  var anyMergedCancelled  = allSelectedRows.is('[mergeCancelled="1"]');    // If any merge prescriptions is cancelled 18Jul13 XN 60657 moved to single foreach
    var currentRowParent    = $('#tbdy tr[id=' + currentRow.attr('id_parent') +  ']');  // Get the current row parent (only usefull for single selection)
    
    // multi select checks (simplified to single foreach 18Jul13 XN 60657)
//  var allSameLevel   = !allSelectedRows.is('[level!="'   + level   + '"]'); 18Jul13 XN 60657 moved to single foreach
//  var allSameRowType = !allSelectedRows.is('[rowType!="' + rowType + '"]'); 18Jul13 XN 60657 moved to single foreach
    var allSameLevel        = true;   // If all rows are at same level 
    var allSameRowType      = true;   // If all rows are of same type
    var allCanStopOrAmend   = true;   // Can all prescriptions be stopped or amended
    var allCurrent          = true;   // If prescription is current else expired
    var anyMergedCancelled  = false;  // If any merged prescriptions are cancelled
    var allArePrescriptions = true;   // If all selected items are Presription or PN Prescription
    allSelectedRows.each(function()
    {
        var row = $(this);
        if (row.attr('level') != level)
            allSameLevel = false;
        if (row.attr('rowType') != rowType)
            allSameRowType = false;
        if (row.attr('canStopOrAmend') == '0')
            allCanStopOrAmend = false;
        if (row.attr('current') == '0')
            allCurrent = false;
        if (row.attr('mergeCancelled') == '1')
            anyMergedCancelled = true;
        if (row.attr('rowType') != 'Prescription' && row.attr('rowType') != 'PN')
            allArePrescriptions = false;
    });
    
    PrepareOCSData();
    var colItems = xmlItem.selectNodes("root/*");

//    ToolMenuEnable('DispensingList_View',                  allArePrescriptions && selectionCount > 0); 18Jul13 XN 60657 moved to single foreach // All are Presription or PN Prescription 
    ToolMenuEnable('DispensingList_View',                  allArePrescriptions && selectionCount > 0);  // All are Presription or PN Prescription 
    ToolMenuEnable('DispensingList_AttachNotes',           singleSelection && rowType != 'Dispensing');
    ToolMenuEnable('DispensingList_Dispense', singleSelection && allCurrent && rowType != 'PN' && !anyMergedCancelled && (rowType != 'Dispensing' || currentRowParent.attr('mergeCancelled') != "1")); // XN 12Mar13 adding disabling of dispensing if parent prescrpition is a canelled merge prescription
    // ToolMenuEnable('DispensingList_CancelAndCopyItem',     singleSelection && allCanStopOrAmend && allCurrent && level == "0" && rowType == "Prescription" && OCSActionAvailable_Batch(OCS_CANCEL_AND_REORDER, colItems, xmlType) && !viewSettings.EnableEMMRestrictions);      11Spet13 XN 72983 prevent script error by not doing complete post back // 22Mar13 XN 43495 Disable button if enforcing eMMRestrictions and on emm ward
    // ToolMenuEnable('DispensingList_CancelItem',            allCanStopOrAmend && allCurrent && allSameLevel && level == "0" && allSameRowType && rowType == "Prescription" && OCSActionAvailable_Batch(OCS_CANCEL, colItems, xmlType) && !viewSettings.EnableEMMRestrictions);   11Spet13 XN 72983 prevent script error by not doing complete post back // 22Mar13 XN 43495 Disable button if enforcing eMMRestrictions and on emm ward
    ToolMenuEnable('DispensingList_CancelAndCopyItem',     singleSelection && allCanStopOrAmend && allCurrent && level == "0" && rowType == "Prescription" && OCSActionAvailable_Batch(OCS_CANCEL_AND_REORDER, colItems, xmlType) && viewSettings.eMMAllowsPrescribing);      // 22Mar13 XN 43495 Disable button if enforcing eMMRestrictions and on emm ward
    ToolMenuEnable('DispensingList_CancelItem',            allCanStopOrAmend && allCurrent && allSameLevel && level == "0" && allSameRowType && rowType == "Prescription" && OCSActionAvailable_Batch(OCS_CANCEL, colItems, xmlType) && viewSettings.eMMAllowsPrescribing);   // 22Mar13 XN 43495 Disable button if enforcing eMMRestrictions and on emm ward
    ToolMenuEnable('DispensingList_RPTDispLink',           singleSelection && rowType == 'Dispensing'); //10Jul09 TH Repeat liinking only available on current disp lines //08Sep11 TH Allow for history also TFS13476
    ToolMenuEnable('DispensingList_PrintSpecifiedReport',  singleSelection && rowType != 'PN');  // XN 30Jan11 Disabled for PN prescription 
    ToolMenuEnable('DispensingList_PrescriptionMerge',     singleSelection && allCurrent && ((rowType == 'Prescription' || rowType == 'Merged') && level == '0'));  // XN 16Jun11 F0041502 Asymmetric Dosing button
    ToolMenuEnable('DispensingList_DispenseNewDose',       singleSelection && allCurrent && rowType != 'Dispensing' && ((rowType == 'Prescription' && level == '0') || rowType == 'Merged') && !anyMergedCancelled); //22Aug11 TH disable splitting button on merged rx // 09Nov11 THTFS 18827	
    // ToolMenuEnable('DispensingList_PatientBagLabel',       singleSelection && rowType != 'PN');     XN 49672 not prescription dependant
    ToolMenuEnable("DispensingList_DispensePSO",           singleSelection && allCurrent && ((rowType == 'Prescription' && level == '0') || rowType == 'Merged')); // 09Nov11 THTFS 18827
    ToolMenuEnable("DispensingList_DispenseNewDosePSO",    singleSelection && allCurrent && ((rowType == 'Prescription' && level == '0') || rowType == 'Merged')); // 22Nov12 TH TFS 40895

     // For PSO
    if (viewSettings.PSO)
    {
        if (singleSelection && rowType == "Dispensing") 
            RAISE_Dispensing_info(Number(currentRow.attr("id"))); 
	    else
	        RAISE_Dispensing_info(0); 
    }

    var statusNoteButtons = $('#panStatusButtonsToolbar button');
    var statusNoteCount   = statusNoteButtons.length;
    for (var b = 0; b < statusNoteCount; b++)
    {
        var button         = $(statusNoteButtons[b]);
        var statusValue    = currentRow.attr(button.attr('requestStatusRowAttr'));
        var requestTypeIDs = button.attr("requesttypeids");
        var isStatusButton = button.attr("isStatusButton");
        
        if (singleSelection && statusValue != "" && requestTypeIDs.indexOf("," + currentRow.attr("RequestTypeID") + ",") > -1)
            button.removeAttr('disabled');
        else           
            button.attr('disabled', 'disabled');
            
	    if (isStatusButton == "1")
            $('img', button).attr("src", (singleSelection && statusValue == "1") ? "../../images/ocs/checkbox-checked.gif" : "../../images/ocs/checkbox.gif");
	    else
            $('#ButtonText', button).text((singleSelection && statusValue == "1") ? button.attr("deactivateverb") : button.attr("applyverb"));
    }
}

function RowSelect(tr, selectType, preventSettingFocus) 
{
    if (tr != null) 
    {
        //if (selectType == undefined) XN 60657 18Jul13 Disable multi select if in select episode mode
        if (selectType == undefined || !viewSettings.AllowMultiSelect)
            selectType = 'single';
            
        // deselect old row
        if (selectType == 'single')
            RowUnselect();

        if (selectType == 'extend') 
        {
            var focusRowIndex = (GetFocusedRow() == undefined) ? tr.rowIndex : GetFocusedRow().rowIndex;
            
            var startIndex = Math.min(focusRowIndex, tr.rowIndex);
            var endIndex   = Math.max(focusRowIndex, tr.rowIndex);

            if (startIndex == 1)
                $('#tbdy tr:lt(' + endIndex + ')').addClass('RowSelected'); // If start item is first index then don't use jquery gt as does not handle -ve's correctly
            else
                $('#tbdy tr:gt(' + (startIndex - 2) + '):lt(' + (endIndex - startIndex + 1) + ')').addClass('RowSelected');
        }
            
        $('#tbdy TR').removeClass('RowFocus');                    
            
        // reselect new row
        tr.tabIndex = 0;
        tr = $(tr);
        tr.addClass('RowSelected RowFocus');
        if (preventSettingFocus != true)        // 60557 04Apr13 XN prevent setting focus if dispensing control should have it
            tr.focus();
        UpdateToolbarButtons();

        PerformSelectEpisode(); // 66246 19Jun13 XN 
    }
}

function RowUnselect(tr)
{
    var selectedRows = (tr == undefined) ? GetSelectedRows() : $(tr);
    selectedRows.attr('tabindex', -1);
    selectedRows.removeClass('RowSelected');
    selectedRows.removeClass('RowFocus');

    if (tr != undefined) 
    {
        UpdateToolbarButtons();
        PerformSelectEpisode(); // 66246 19Jun13 XN 
    }
}

function SetFocus(tr)
{
    var gridRows   = $('#tbdy TR');
    var focusedRow = $(tr);

    if (focusedRow.length != 1)
        focusedRow = gridRows.filter('.RowFocus').first();
        
    if (focusedRow.length != 1)
        focusedRow = gridRows.filter('.RowSelected').first();

    gridRows.removeClass('RowFocus');
        
    if (focusedRow.length != 1)
    {
        try
        {
            document.getElementById("tbdy").focus();
        }
        catch (e)
        {}
    }
    else
    {
        focusedRow.focus();
        focusedRow.addClass('RowFocus');
    }
}
        
function grid_onclick() 
{
    var tr = event.srcElement;
    if (tr.nodeName != 'TR')
    {
        tr = tr.parentNode;     
        if (tr.nodeName != 'TR')    // Maybe in span so go up one again
            tr = tr.parentNode;
    }
        
    if (tr.nodeName == 'TR' && tr.attributes['id'] != undefined)
    {
        if (event.shiftKey)
            RowSelect(tr, 'extend');
        else if ($(tr).hasClass('RowSelected') && event.ctrlKey)
        {
            if (GetSelectedRows().length > 1)
            {
                RowUnselect(tr);
                SetFocus();
            }
        }
        else
            RowSelect(tr, event.ctrlKey ? 'add' : 'single');
            
        ClearControl();
    }
}        

function x_clk(td) 
{
    // folder has been opened or closed
    var tr = td.parentNode;
    SetFolderOpen(tr, tr.getAttribute("loaded") != "1" || tr.nextSibling.style.display == "none");
}        
        
function SetFolderOpen(tr, open, requestID_Dispensing)
{        
    // Toggle folder state between open/closed
    var row = $(tr);
    var parentID = Number(row.attr('id'));

    if (tr.firstChild.firstChild != null && tr.firstChild.firstChild != undefined && tr.firstChild.firstChild.tagName == "IMG")
    {
        $('img:first', row).attr('src', !open ? "../../images/grid/imp_open.gif" : "../../images/grid/imp_closed.gif");
        
        if (open && row.attr("loaded") != "1")
            FetchChildRows(parentID, requestID_Dispensing);
        else
        {
            // Create an array of if a specific child element is open
            var openlevel = new Array();
            for (var l = 0; l < 3; l++)
                openlevel[l] = open;
                
            var level = parseInt(row.attr('level'));

            // Iterate through all child elements (level > current level)
            // and hide or display item
            // if hide then hide all if, opening then only open if parent item state is open
            child = row[0].nextSibling;
            while (child != null && (child.getAttribute("level") > level)) 
            {
                var l = parseInt(child.getAttribute("level"));

                // If this item has children check if it's state is open or closed
                // (only effective if blnOpen is open else will always close)
                if (child.firstChild.firstChild.src != undefined)
                    openlevel[l + 1] = openlevel[l] && (child.firstChild.firstChild.src.indexOf('imp_closed.gif') >= 0);

                // Hide or display the items if the parent is being open or closed                        
                child.className = "";
                child.style.display = (!openlevel[l] ? "none" : "");
                child = child.nextSibling;
            }
            
            refreshRowStripes();
        }
            
        RowSelect(tr, "single");
    }
}

// If user clicks attached note icom ensure row is seleect before calling DoAction(OCS_ANNOTATE)
// 66474 19Jun13 XN 
function attachedNoteIcon_onclick() 
{
    grid_onclick();
    //DoAction(OCS_ANNOTATE);   19May14 XN 86630
    DoAction(OCS_ANNOTATE, DataChangedRefreshRow);

    // If merged prescription the update the parent 01Dec15 XN 136786
    var parentId = GetSelectedRows().attr('id_parent');
    if (parentId != undefined)
        RefreshRow(parentId);

    window.event.cancelBubble = true;
    window.event.returnValue = false;    
    return false;
}

function refreshRowStripes() 
{
    if (workListAlternateRowColour) 
    {
        var levelIndex = [0,0,0,0,0];
        
        $.each($('#tbdy tr'), function(index, item)
        {
            var level = Number(item.attributes('level').value);
            item.className = (levelIndex[level] % 2 == 1) ? 'RowOdd': 'RowLevel' + level + 'Even';
            levelIndex[level] = levelIndex[level] + 1;
        });
    }
}        

// Get dispensings for prescription
// requestID_Prescription - prescription that contains the dispensings
// requestID_Dispensing   - currently selected dispensing
// 46271 20Oct12 XN Use web method rather than calling dispensingLoader.aspx
function FetchChildRows(requestID_Prescription, requestID_Dispensing) 
{
    // Get dispensings
    var trPrescription = $(FindRow(requestID_Prescription));
    if (trPrescription.length == 0) // If multiple dispensing PMR on one desktop, can get the events from other dekstops (so just ignore these)
        return;

    var parameters =
                {
                    sessionID:        m_SessionID,
                    requestID_Parent: parseInt(requestID_Prescription),
                    rowType:          trPrescription.attr('rowType'),
                    viewSettings:     viewSettings
                };
    var result = PostServerMessage("ICW_DispensingPMR.aspx/FetchChildRows", JSON.stringify(parameters));

    if ((result != undefined) && (result.d != "")) 
    {
        trPrescription.attr("loaded", "1");

        // Remove existing dispesnings
        $("tr[id_parent='" + requestID_Prescription + "']").remove();

        // Add latest dispesnings
        trPrescription.after(result.d);

        refreshRowStripes();

        // Select row if needed
        if (Number(requestID_Dispensing) > 0) 
        {
            var trSearch = FindRow(requestID_Dispensing);
            if (trSearch != null) 
            {
                trSearch.scrollIntoView(false);
                //RowSelect(trSearch); 60557 04Apr13 XN prevent setting focus if dispensing control should have it
                RowSelect(trSearch, undefined, true);
            }
        }
    }
}


// Returns if the sepcified row is visible, and is in the current scroll window
// 22Jan13 XN add for doing Page Up and Page Down
function IsRowInView(row) 
{
    var scrollContainer = $('#tbl-container')[0];

    // Get the height of the header row
    var tableHeaderHeight = 0;
    var headerRow = $('#tbl thead tr:eq(0)');
    if (headerRow.length > 0)
        tableHeaderHeight = headerRow[0].offsetHeight;

    // Get the position of the to and bottom of the row (relative to the top of the grid control)
    var rowTopPosition = row.offsetTop - scrollContainer.scrollTop - tableHeaderHeight;
    var rowBottomPosition = row.offsetTop + row.offsetHeight - scrollContainer.scrollTop;

    // return if row is outside viewable are of the grid control
    return ((rowBottomPosition <= scrollContainer.clientHeight) && (rowTopPosition >= 0))
}

// 22Jan13 XN add for doing Page Up and Page Down
function scrollRowIntoView(row, directionUp) 
{
    // can't use scrollIntoView else whole page scrolls (or does not work) so have to do manually
    var scrollContainer = $('#tbl-container');
    var headerRow = $('#tbl thead tr:eq(0)');

    if (directionUp) {
        var scrollTopPosition = row.offsetTop - headerRow[0].offsetHeight;
        scrollContainer.scrollTop(scrollTopPosition);
    }
    else {
        var scrollTopPosition = row.offsetTop + headerRow[0].offsetHeight - scrollContainer[0].clientHeight;
        scrollContainer.scrollTop(scrollTopPosition);
    }
}

// 22Jan13 XN add Page Up and Page Down handling
function grid_onkeydown() 
{
    var focusedRow = GetFocusedRow();
    if (focusedRow == undefined)
        return;

    var selectType = event.shiftKey ? 'add' : 'single';

    switch (event.keyCode) 
    {
        case 36: // Home
            if (tbl.rows.length > 1) 
            {
                RowSelect(tbl.rows[1], selectType);
                tbl.rows[1].scrollIntoView(false);
                tbl.rows[1].focus();
            }
            event.returnValue = false;
            break;

        case 35: // End
            if (tbl.rows.length > 1) 
            {
                RowSelect(tbl.rows[1]);
                var tr = tbl.rows[tbl.rows.length - 1];
                while (tr.style.display == "none")
                    tr = tr.previousSibling;
                RowSelect(tr, selectType);
                tr.scrollIntoView(false);
            }
            event.returnValue = false;
            break;

        case 38: // Up
            var tr = focusedRow;
            if (tr.previousSibling != null) 
            {
                do {
                    tr = tr.previousSibling;
                } while (tr.style.display == "none")
                RowSelect(tr, selectType);
                tr.scrollIntoView(false);
                ClearControl();
            }
            event.returnValue = false;
            break;

        case 33:    // Page up
            var scrollContainer = $('#tbl-container');
            var headerRow = $('#tbl thead tr:eq(0)');

            // Determine where the top pos of the scroll container is (if currently at top move page up)
            var scrollTop = scrollContainer[0].scrollTop + headerRow.height();
            if (focusedRow.offsetTop <= scrollTop)
                scrollTop = Math.max(0, scrollTop - scrollContainer.height()) + headerRow.height();

            // Get list of rows with same parent (level 0 does not have a parent)
            var rowWithSameParent;
            if (focusedRow.getAttribute('id_parent') == null)
                rowWithSameParent = $('#tbdy tr:not([id_parent])');
            else
                rowWithSameParent = $('#tbdy tr[id_parent=' + focusedRow.getAttribute('id_parent') + ']');

            // find the first hidden row 
            var rowToSelect = null;
            for (var c = rowWithSameParent.length - 1; c > 0; c--) 
            {
                if (rowWithSameParent[c].offsetTop < scrollTop) 
                {
                    rowToSelect = rowWithSameParent[c];
                    break;
                }
            }

            // If not found row above scroll top select first with same parent
            if (rowToSelect == null)
                rowToSelect = rowWithSameParent[0];

            // If alreay at the top of the list of children move up to first visible parent
            if (rowToSelect == focusedRow && rowToSelect.getAttribute('level') != '0') 
            {
                var parentRow = $(focusedRow).prev('tr:not([display="none"])');
                if (parentRow.length > 0)
                    rowToSelect = parentRow[0];
            }

            // Select row
            if (rowToSelect != undefined) 
            {
                RowSelect(rowToSelect, selectType);
                if (!IsRowInView(rowToSelect))
                    scrollRowIntoView(rowToSelect, true);
                ClearControl();
            }

            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;

        case 40: // Down
            var tr = focusedRow;
            do {
                tr = tr.nextSibling;
            } while (tr != null && tr.style.display == "none")
            if (tr != null) 
            {
                RowSelect(tr, selectType);
                tr.scrollIntoView(false);
                ClearControl();
            }
            event.returnValue = false;
            break;

        case 34:    // Page down
            var scrollContainer = $('#tbl-container');
            var headerRow = $('#tbl thead tr:eq(0)');
            var rowHeight = 23;

            // Determine where the bottom pos of the scroll container is (if goes over bottom of girs then other code below handles this)
            var scrollBottom = scrollContainer[0].scrollTop + scrollContainer.height() - headerRow.height();
            if ((focusedRow.offsetTop + rowHeight) > scrollBottom)
                scrollBottom = scrollBottom + scrollContainer.height() + headerRow.height();

            // Get list of rows with same parent (level 0 does not have a parent)
            var rowWithSameParent;
            if (focusedRow.getAttribute('id_parent') == null)
                rowWithSameParent = $('#tbdy tr:not([id_parent])');
            else
                rowWithSameParent = $('#tbdy tr[id_parent=' + focusedRow.getAttribute('id_parent') + ']');

            // find the first hidden row below bottom of scroll
            var rowToSelect = null;
            for (var c = 0; c < rowWithSameParent.length; c++) 
            {
                if ((rowWithSameParent[c].offsetTop + rowHeight) > scrollBottom) 
                {
                    rowToSelect = rowWithSameParent[c];
                    break;
                }
            }

            // If not found row below scroll bottom select first with same parent
            if (rowToSelect == null)
                rowToSelect = rowWithSameParent[rowWithSameParent.length - 1];

            // If alreay at the bottom of the list of children move up to first visible parent
            if (rowToSelect == focusedRow && rowToSelect.getAttribute('level') != '0') 
            {
                var parentRow = $(focusedRow).next('tr:not([display="none"])');
                if (parentRow.length > 0)
                    rowToSelect = parentRow[0];
            }

            // Select row
            if (rowToSelect != undefined) 
            {
                RowSelect(rowToSelect, selectType);
                if (!IsRowInView(rowToSelect))
                    scrollRowIntoView(rowToSelect, false);
                ClearControl();
            }

            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;

        case 37: // Left
            if (focusedRow.nextSibling != null) 
            {
                if (focusedRow.getAttribute("loaded") == "1" && focusedRow.nextSibling.style.display != "none") // that are visible in an expanded folder
                    SetFolderOpen(focusedRow, false); // close folder
                else if (focusedRow.getAttribute("id_parent") != undefined) 
                {
                    // Move cursor to containing folder
                    var lngRequestID_Parent = Number(focusedRow.getAttribute("id_parent"));
                    var trParent = FindRow(lngRequestID_Parent);
                    trParent.scrollIntoView(false);
                    RowSelect(trParent, 'single');
                    ClearControl();
                }
            }
            event.returnValue = false;
            break;

        case 39: // Right
            switch (focusedRow.getAttribute("rowType")) 
            {
                case "Prescription": // Prescription
                case "Merged":
                    if (focusedRow.getAttribute("loaded") != "1" || focusedRow.nextSibling.style.display == "none") // that are not visible in a closed folder
                        SetFolderOpen(focusedRow, true);  // open folder
                    break;
            }
            event.returnValue = false;
            break;

        case 13: // Enter
            Dispense();
            event.returnValue = false;
            break;
            
        case 46: // Del     18Jul13 XN Pressing delete will call the cancel button
            var canelButton = $('#DispensingList_CancelItem');
            if (!canelButton.is(":disabled"))
                canelButton.click();
            break;
    }
}


// XN 11Jun11 F0041502 Added for Prescription linking
// Display the link form for exsiting prescriptions, and unlinks alreadt linked items
function PrescriptionMerge()
{
    var selectedRows = GetSelectedRows();
    if (selectedRows.length != 1)
        return;
    
    var requestID = selectedRows[0].getAttribute("id");

    if (selectedRows[0].getAttribute("rowType") == "Prescription")
    {
        var strURLParameters = '?SessionID=' + m_SessionID + '&RequestID=' + requestID + '&EpisodeID=' + m_EpisodeID;
        
        // Displays the Prescription Linking screen as a popup
        var result = window.showModalDialog('../DispensingPMR/PrescriptionMergeModal.aspx' + strURLParameters, '', 'status:off; center: Yes;');  // 24Jul15 XN 114905 now returns new request ID    
       if (result == 'logoutFromActivityTimeout') {
            result = null;
            window.close();
           window.parent.close();
           window.parent.ICWWindow().Exit();
        }
        if (result != undefined)
            RefreshGrid(result, false);
    }
    else if (selectedRows[0].getAttribute("rowType") == "Merged")
    {
        if (confirmPharmYesNo('Do you want to unlink this prescription?', false) == true)   // 24Jul15 XN 114905 use better confirm box
        {
            // Unlink
            var sendData = "{'sessionID': '" + m_SessionID + "', 'requestID': '" + requestID + "' }";
            PostServerMessage("../DispensingPMR/PrescriptionMerge.aspx/Unlink", sendData);
            RefreshGrid(requestID, false);
        }
    }

    SetFocus(); // 24Jul15 XN 114905 set focus back to grid all the time
}

function RefreshGrid(requestID, autoDispense)
{
    var parameters =
            {
                sessionID       : m_SessionID,
                episodeID       : m_EpisodeID,
                viewSettings    : viewSettings
            };
    var result = PostServerMessage("ICW_DispensingPMR.aspx/RefreshGrid", JSON.stringify(parameters));

    if (result != undefined) 
    {
        // delete all old children
        $('#tbdy tr').remove();
        if (result.d != "")         // Maybe empty string if grid is now e,pty 
            $('#tbdy').append(result.d);
        
        refreshRowStripes();

        var row = FindRow(requestID);
        if (row == null && $('#tbdy tr').length > 0)
        {
            row = $('#tbdy tr')[0];
            autoDispense = false;
        }
            
        if (row != null)    
        {
            RowSelect(row);
            row.scrollIntoView(false);

            //var autoDispense = parseBoolean(document.body.getAttribute("AutoDispense"));
            if (autoDispense)
                Dispense();
        }
        else
            UpdateToolbarButtons(); // 49908 XN 26Nov12 Disable other buttons

        if (!autoDispense)  // 60286 02Apr13 XN Only set focus back to grid if not dispensing
            SetFocus();                
            
        return true;                    
    }
    
    return false; 
}


// Refresh single prescription row in grid
// 46271 20Oct12 XN Refresh single prescription row
function RefreshRow(requestID, lastRowRefresh, dispense)
{
    var row = $(FindRow(requestID));
    var rowDeleted = false;
    
    if (row.length == 0)
        return;

    var parameters =
            {
                sessionID        : m_SessionID,
                requestID_Parent : row.attr('id_parent') == undefined ? null : parseInt(row.attr('id_parent')),
                requestID        : parseInt(requestID),
                rowType          : row.attr('rowType'),
                viewSettings     : viewSettings
            };
    var result = PostServerMessage("ICW_DispensingPMR.aspx/RefreshRow", JSON.stringify(parameters));

    if ((result != undefined) && (result.d != "")) 
    {
        if (result.d == 'remove')
        {
            // If web page returned remove then delete row and it's children
            var level = parseInt(row.attr('level'));
            var child = row.next();
            while (child.length > 0 && parseInt(child.attr("level")) > level) 
            {
                var temp = child.next();
                child.remove();
                child = temp;
            }
            row.remove();         
            
            // If no rows left then nothing more to do
            if (document.getElementById("tbdy").rows.length == 0)
            {
                UpdateToolbarButtons(); // 49908 XN 26Nov12 Disable other buttons           
                return;
            }

            // get to row for selection
            row = $(document.getElementById("tbdy").rows[0]);
            rowDeleted = true;
        }
        else             
        {
            var markedAsLoaded = row.is('[loaded="1"]');
            var openCloseImage;

            // 51136 Fix issue with warning icon showing against the +/-, or + showing when item is open against first refresh.
            var currentLevel  = row.attr('level');
            var nextItemLevel = row.next().attr('level');
            if (currentLevel != undefined && nextItemLevel != undefined && parseInt(currentLevel) < parseInt(nextItemLevel))
                openCloseImage = '../../images/grid/imp_closed.gif';        // If item already has children then force to open (as may of been closed previously
            else
                openCloseImage = $('td:first img', row).attr('src');
                        
            // Replace row and re get so can set focus
            row.replaceWith(result.d);            
            row = $(FindRow(requestID));

            if (markedAsLoaded)
                row.attr("loaded", "1");
            if ($('td:first img', row).length > 0 && openCloseImage != undefined)
                $('td:first img',row).attr('src', openCloseImage);  // 51136 Fix
        }
    }
    
    if (lastRowRefresh)
    {
        refreshRowStripes();
        
        // Reselect row
        if (row.length > 0)
            RowSelect(row[0]);
    
        // If appropriate dispense
        //var autoDispense = parseBoolean(document.body.getAttribute("AutoDispense"));
        //if (autoDispense && !rowDeleted) 
        if (dispense && !rowDeleted) 
            Dispense();
    }
}        

// called when status button is clicked
// Changes the state of the note type
function NoteTypeToggle(button)
{
    button = $(button);
    
    var selectedRows = GetSelectedRows();
    var requestIDs = new Array();
    $.each(selectedRows, function(index, value) { requestIDs[index] = parseInt(value.getAttribute('id')); });
    
    if (requestIDs.length == 0)
        return;
    
    var noteType = button.attr('requestStatusRowAttr');
    var enable   = selectedRows.first().attr(noteType) == '1' ? false : true;   // Toogle the state
    
    if (SetStatusNoteState(m_SessionID, button.attr('notetypeid'), selectedRows.first().attr('requesttypeid'), requestIDs, enable))
    {
        var id = selectedRows.first().attr('id');
        if (requestIDs.length > 1)
            RefreshGrid(id, false);
        else
            RefreshRow(id, true, false);
    }
}

// If desktop parameter SelectEpisode is enabled, will raise an ICW select event
// 65836 19Jun13 XN
function PerformSelectEpisode() 
{
    if (viewSettings.SelectEpisode) 
    {
        // Get episode ID of first row
        var selectedRows = GetSelectedRows();
        var episodeID = GetRowEpisodeID(selectedRows.first());
        var raiseSelectEpisode = episodeID != null && episodeID > 0;

        for (var c = 0; c < selectedRows.length && raiseSelectEpisode; c++) 
        {
            if (GetRowEpisodeID(selectedRows[c]) != episodeID)
                raiseSelectEpisode = false;
        }

        if (raiseSelectEpisode)   //DJH TFS13018
        {
            var parameters =
                {
                    sessionID: m_SessionID,
                    episodeID: parseInt(episodeID)
                };
            PostServerMessage("ICW_DispensingPMR.aspx/SaveSelectedEpisodeToState", JSON.stringify(parameters));

            // 21Feb11 PH Take ICW EpisodeID integer, convert to entity & episode versioned identifiers, and raise the ICW Episode Selected Event
            // Create JSON episode event data
            var jsonEntityEpisodeVid = ICW.clinical.episode.eventSelectedRaised(episodeID, 0, m_SessionID);
            // Raise episode event via ICW framework, using entity & episode versioned identifier
            RAISE_EpisodeSelected(jsonEntityEpisodeVid);
        }
        else
            RAISE_EpisodeCleared();     //DJH TFS13018
    }
}

function ICWLocation(SessionID) 
{
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    var strURL = '../sharedscripts/AppSettingRead.aspx'
			  + '?SessionID=' + SessionID
			  + '&Setting=ICW_Location';
    var v11Location = '';

    objHTTPRequest.open("POST", strURL, false); //false = syncronous                              
    objHTTPRequest.send("");
    v11Location = objHTTPRequest.responseText;

    return v11Location;
}


// Displays the fast repeat form
function ShowFastRepeat() 
{
    // Displays the fast repeater form
    var strURL = 'FastRepeatSearch.aspx?SessionID=' + m_SessionID;
    var result = window.showModalDialog(strURL, '', 'status:off; center:Yes;');
    if (result == 'logoutFromActivityTimeout') {
        result = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (result != undefined && result.split('|').length > 1) 
    {
        var splitResult = result.split('|');

        var episodeID   = parseInt(splitResult[0]);
        var requestID   = parseInt(splitResult[1]);
        var autoDispense= parseBoolean(splitResult[2]);

        // Send out episode selected event
        var jsonEntityEpisodeVid = ICW.clinical.episode.eventSelectedRaised(episodeID, 0, m_SessionID);
        RAISE_EpisodeSelected(jsonEntityEpisodeVid);

        // Refresh in controlled manner
        // window.location.reload();    11Spet13 XN 72983 prevent script error by not doing complete post back 
        SetNewPatientEpisode(episodeID, autoDispense, requestID);

        // 19Sep13 73809 XN If selected patient but no prescription on PMR then notify user
        if (FindRow(requestID) == null)
            alert('Patient has been located.\nHowever, the selected prescription cannot be located on this view');
    }
}

// Call when new paitent episode is selected 
// will update the grid, and viewSettings.eMMAllowsPrescribing variable
// 11Spet13 XN 72983 prevent script error by not doing complete post back 
// If request will select a row and update the grid
function SetNewPatientEpisode(episodeID, autoDispense, requestID_toSelect) 
{
    if (m_EpisodeID != episodeID) 
    {
        ClearControl();
        $('#tbdy').children().remove();

        m_EpisodeID = episodeID;

        // get eMMAllowsPrescribing setting depends on if on emm ward
        var parameters =
                    {
                        sessionID: m_SessionID,
                        episodeID: episodeID,
                        enableEMMRestrictions: viewSettings.EnableEMMRestrictions
                    };
        var result = PostServerMessage("ICW_DispensingPMR.aspx/GetIfeMMAllowsPrescribingFromServer", JSON.stringify(parameters));
        viewSettings.eMMAllowsPrescribing = (result != undefined) && (result.d != "") && parseBoolean(result.d);

        // Update grid
        RefreshGrid(0, false);
        form_onload();
        UpdateToolbarButtons(); // 49908 XN 26Nov12 Disable other buttons
    }

    // If requested row to selected at start (12Aug13 XN 70138 FastRepeat)
    if (requestID_toSelect != undefined) 
    {
        var selectedRow = FindRow(requestID_toSelect);
        if (selectedRow != null) 
        {
            RowSelect(selectedRow);

            // Dispens if selected
            if (autoDispense)
                Dispense();
        }
    }
}