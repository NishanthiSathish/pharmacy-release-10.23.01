/*
'-----------------------------------------------------------------------------------
' Shared server-side vb script for StatusNoteToolbar
' Currrently shared by Worklist and DispensingPMR
'-----------------------------------------------------------------------------------
*/

var m_SessionID;
var m_RequestList;
var m_ResponseList;
var m_NoteType;
var m_NoteGroupID;
var m_NoteData;
var m_DiscontinuationReason;
var m_PublishToBus;
var m_PostConditionRoutines;

var VALIDATION_PASS = 0;
var VALIDATION_FAIL = 1;
var VALIDATION_FAIL_LOCK = 2;

function StatusNoteButtonEnable(objButton, colItems) {
    //Based on the currently highlighted rows (held in colItems), enable or disable
    //objButton as appropriate.
    var i = 0;
    var lngRequestTypeId = 0;
    var lngResponseTypeId = 0;
    var lastVal = 0;
    var thisVal = 0;
    var blnEnable = true;
    var blnStatusButton = objButton.getAttribute('typeofnote') == 'Status';

    var strNoteType = objButton.getAttribute('notetype').split(' ').join('_x0020_'); 												//_x0020_ = placeholder for space character

    if (colItems.length == 0) {
        blnEnable = false;
    }
    else {
        lastVal = Number(colItems[0].getAttribute(strNoteType));
    }

    for (i = 0; i < colItems.length; i++) {
        var statusNotesDisabled = colItems[i].getAttribute('StatusNotesDisabled');
        if (statusNotesDisabled != null && statusNotesDisabled == "1") {
            blnEnable = false;
            break;
        }

        lngRequestTypeId = Number(colItems[i].getAttribute('RequestTypeID'));
        lngResponseTypeId = Number(colItems[i].getAttribute('ResponseTypeID'));

        // See if this button applies to the selected request/response
        if (
				!RequestTypeExistsInButton(objButton, lngRequestTypeId, colItems[i].getAttribute('ContentsAreOptions') == '1', colItems[i].getAttribute('IsOptionsSetChild') == '1')
				&&
				!ResponseTypeExistsInButton(objButton, lngResponseTypeId)
		   ) {
            //This button does not apply to this item.  Hence it is disabled.	
            blnEnable = false;
            break;
        }

        thisVal = Number(colItems[i].getAttribute(strNoteType));
        if (thisVal != lastVal) {
            //The value of this status on this item is different from the last item, hence this status is not available
            blnEnable = false;
            break;
        }
        lastVal = thisVal;
    }

    blnEnable = blnEnable & ItemsShouldBeEnabled(objButton, colItems);

    objButton.disabled = !blnEnable;

    if (blnStatusButton) {
        if (thisVal == 1) {
            objButton.all['imgStatusNote'].src = '../../images/ocs/checkbox-checked.gif';
        }
        else {
            objButton.all['imgStatusNote'].src = '../../images/ocs/checkbox.gif';
        }
    }
    else {
        objButton.all['imgStatusNote'].style.filter = blnEnable ? '' : 'progid:DXImageTransform.Microsoft.BasicImage(grayscale=1)';

        if (blnEnable && thisVal == 1) {
            objButton.all['txtStatusNote'].innerHTML = objButton.getAttribute('deactivateverb');
        }
        else {
            objButton.all['txtStatusNote'].innerHTML = objButton.getAttribute('applyverb');
        }
    }

    return blnEnable;
}

//=================================================================================================

function RequestTypeExistsInButton(objButton, lngID, itemIsOptionsSet, itemIsOptionsSetChild) {

    // Searches for requesttype data in status buttons
    lngID = Number(lngID);
    col = objButton.getElementsByTagName("requesttype");
    availableAnyway = false;
    for (var i = 0; i < col.length; i++) {
        var showInOptionsSet = col[i].getAttribute('showinoptionsset');
        if (Number(col[i].getAttribute("id")) == lngID) {
            if (!itemIsOptionsSetChild || showInOptionsSet == null || showInOptionsSet.toLowerCase() == 'true') {
                return true;
            }
        } else if (itemIsOptionsSet) {
            availableAnyway |= showInOptionsSet != null && showInOptionsSet.toLowerCase() == 'false';
        }
    }
    return availableAnyway;
    //return false;
}

//=================================================================================================

function ResponseTypeExistsInButton(objButton, lngID) {
    // Searches for responsetype data in status buttons
    lngID = Number(lngID);
    col = objButton.getElementsByTagName("responsetype");
    for (var i = 0; i < col.length; i++) {
        if (Number(col[i].getAttribute("id")) == lngID) {
            return true;
        }
    }
    return false;
}

//=================================================================================================
//F0109913 ST 04Mar11 Now breaks down the list of items into their request/response types and
//runs the old code against that 'group' of items.

function NoteTypeToggle(Button) {
    //Fires when a statusnote button is clicked.
    var bMultiSelect = false;
    var WorklistItems = null;

    // get publish to service bus boolean
    var bPublishToBus = false;
    var atrPublishToBus = document.body.getAttribute("publishToBus");

    if (atrPublishToBus && atrPublishToBus.toLowerCase() == "true") bPublishToBus = true;

    // only used with paged version of the worklist!
    if (document.body.getAttribute("pagelevel") != null && document.body.getAttribute("MultiSelect") != null) {
        bMultiSelect = CanMultiSelect(document.body.getAttribute("pagelevel"), document.body.getAttribute("MultiSelect"));
    }

    if (!bMultiSelect) {
        WorklistItems = GetHighlightedRowXML();
    }
    else {
        WorklistItems = GetMultiHighlightedRowXML();
    }

    if (WorklistItems == null) {
        return;
    }


    if (!StatusNoteButtonEnable(Button, WorklistItems)) {
        //Generic Status Note bits
        //Each status note results in the appearance of a button called cmdStatusNote.  Each button deals with one requesttype.
        var colStatusButtons = document.all['cmdStatusNote'];
        if (colStatusButtons != undefined) {
            if (colStatusButtons.length == undefined) {
                //Single button
                void StatusNoteButtonEnable(colStatusButtons, WorklistItems);
            }
            else {
                //Collection
                for (i = 0; i < colStatusButtons.length; i++) {
                    void StatusNoteButtonEnable(colStatusButtons[i], WorklistItems);
                }
            }
        }
        return;
    }

    //Fires when a statusnote button is clicked.
    //We've already established that the selected items have the same status WRT this button,
    //and hence require the same action.  But we'll check anyway...
    if (Button.disabled) {
        return;
    }
    var SessionID = document.body.getAttribute('sid');
    var Enabled = false;

    var StatusNoteUpdateDoc = PrepareStatusNoteUpdateXML(Button, WorklistItems);
    var NoteTypeNode = StatusNoteUpdateDoc.documentElement;
    var NoteType = NoteTypeNode.getAttribute("NoteType").split('_x0020_').join(' ');
    var NoteTypeID = NoteTypeNode.getAttribute("NoteTypeID");
    
    var RequestList = "";
    var ResponseList = "";

    var PostConditionRoutines = PreparePostconditionRoutinesXML();

    var StatusNotes = NoteTypeNode.selectNodes("//RequestTypeStatusNote")
    for (StatusNoteIndex = 0; StatusNoteIndex < StatusNotes.length; StatusNoteIndex++) {
        var StatusNote = StatusNotes[StatusNoteIndex];
        var PostConditionRoutine = StatusNote.getAttribute("PostconditionRoutine");
        var Items = StatusNote.childNodes;
        var ItemList = "";
        for (index = 0; index < Items.length; index++) {
            var Item = Items[index];
            if (ItemList.length > 0) {
                ItemList = ItemList + ",";
            }
            ItemList = ItemList + Item.getAttribute("RequestID");
            Enabled = Item.getAttribute("Enabled") == "1"
        }
        var ValidationResult = ValidateUpdate(SessionID, StatusNote, NoteTypeID, NoteType, "Request", Items, ItemList, Enabled, false);
        if (ValidationResult == VALIDATION_FAIL_LOCK) {
            Refresh();
            return;
        }
        else if (ValidationResult == VALIDATION_FAIL) {
            UnlockRequests(SessionID, ItemList);
            return;
        }
        if (RequestList.length > 0) {
            RequestList = RequestList + ",";
        }
        RequestList = RequestList + ItemList;

        if (PostConditionRoutine != null && PostConditionRoutine != '') {
            AddPostconditionRoutine(PostConditionRoutines, PostConditionRoutine, NoteType, ItemList);
        }
    }

    StatusNotes = NoteTypeNode.selectNodes("//ResponseTypeStatusNote")
    for (StatusNoteIndex = 0; StatusNoteIndex < StatusNotes.length; StatusNoteIndex++) {
        var StatusNote = StatusNotes[StatusNoteIndex];
        var PostConditionRoutine = StatusNote.getAttribute("PostconditionRoutine");
        var Items = StatusNote.childNodes;
        var ItemList = "";
        for (index = 0; index < Items.length; index++) {
            var Item = Items[index];
            if (ItemList.length > 0) {
                ItemList = ItemList + ",";
            }
            ItemList = ItemList + Item.getAttribute("ResponseID");
            Enabled = Item.getAttribute("Enabled") == "1"
        }
        var ValidationResult = ValidateUpdate(SessionID, StatusNote, NoteTypeID, NoteType, "Response", Items, ItemList, Enabled, false);
        //06Nov12   Rams    Think the following validations should be handled as like request
        if (ValidationResult == VALIDATION_FAIL_LOCK) {
            Refresh();
            return;
        }
        else if (ValidationResult == VALIDATION_FAIL) {
            UnlockRequests(SessionID, ItemList);
            return;
        }
        else if (ValidationResult != VALIDATION_PASS) {
            return;
        }
        if (ResponseList.length > 0) {
            ResponseList = ResponseList + ",";
        }
        ResponseList = ResponseList + ItemList;

        if (PostConditionRoutine != null && PostConditionRoutine != '') {
            AddPostconditionRoutine(PostConditionRoutines, PostConditionRoutine, NoteType, ItemList);
        }
    }

    Button.disabled = true; //13Mar07 CD
    document.body.setAttribute('userenabled', 'false'); //13Mar07 CD
    for (index = 0; index < WorklistItems.length; index++) {
        // 06Dec06 PH	Add note type add to each item so that the printing system can later use it to find all reports
        //				associated with the notetype.
        WorklistItems[index].setAttribute("NoteTypeID", NoteTypeID);
    }
    if (Enabled) {
        //A note of this type exists, so we deactivate it. (or rather, all such notes for all selected items)
        void fraSave.DisableAttachedNoteMultiple(SessionID, NoteType, RequestList, ResponseList, m_DiscontinuationReason, bPublishToBus);
    }
    else {
        var HasForm = NoteTypeNode.getAttribute("HasForm") == 'true';
        var IsPrintPreview = (document.body.getAttribute("IsPrintPreview") == "on");
        //Create a new note of that type.
        if (HasForm) {
            //Show order entry
            if (IsPrintPreview) {
                // 08Apr07 PH Cannot print-preview actions with complex forms
                alert("Buttons with forms cannot be print-previewed. Switch off Print-Preview before changing the status of this item.");
                Button.disabled = false;
            }
            else {
                var TableName = NoteTypeNode.getAttribute("TableName");
                var NoteData = GetNoteData(SessionID, TableName);

                if (!(NoteData == 'undefined' || NoteData == 'cancel')) {
                    //Save the note against the specified item(s)
                    fraSave.AttachSystemNote(SessionID, RequestList, ResponseList, NoteType, NoteData, undefined, undefined, bPublishToBus, PostConditionRoutines.documentElement.xml);

                    //Cache the data in case DSS checks fail and the user overrides the warnings
                    m_SessionID = SessionID;
                    m_RequestList = RequestList;
                    m_ResponseList = ResponseList;
                    m_NoteType = NoteType;
                    m_NoteGroupID = '';
                    m_NoteData = NoteData;
                    m_PostConditionRoutines = PostConditionRoutines;
                    
                    // 06Dec06 PH Call printing system to print any reports associated with the note type, in BATCH mode.
                    PrintItem(SessionID, WorklistItems, "batch", IsPrintPreview);
                }
                else {
                    document.body.setAttribute('userenabled', 'true');
                    Button.disabled = false; //13Mar07 CD
                }
            }
        }
        else {
            //No form, just a simple call to create a note
            // 08Apr07 PH When print-previewing, we dont write any status changes
            if (!IsPrintPreview) {
                fraSave.AttachSystemNote(SessionID, RequestList, ResponseList, NoteType, '', undefined, undefined, bPublishToBus, PostConditionRoutines.documentElement.xml);

                //Cache the data in case DSS checks fail and the user overrides the warnings
                m_SessionID = SessionID;
                m_RequestList = RequestList;
                m_ResponseList = ResponseList;
                m_NoteType = NoteType;
                m_NoteGroupID = '';
                m_NoteData = '';
                m_PostConditionRoutines = PostConditionRoutines;
            }
            // 06Dec06 PH Call printing system to print any reports associated with the note type, in BATCH mode.
            PrintItem(SessionID, WorklistItems, "batch", IsPrintPreview);
        }
    }
    UnlockRequests(SessionID, RequestList);
}

//=================================================================================================

function StatusNoteGroupEnable(objSpanElement, objSelectedItems)
//Based on the currently highlighted rows (held in SelectedItems), enable or disable
//SpanElement as appropriate.
{
    var objSelectElement = objSpanElement.getElementsByTagName("select")[0];
    var objOptionElements = objSelectElement.getElementsByTagName("option");
    var objOptionElement;
    var intRequestTypeId = 0;
    var intResponseTypeId = 0;
    var blnEnable = true;
    var intSelectIndex;  // stores index of select group option element relating to status of selected worklist items
    // loop through option items in select element and enable all options
    var optIndex;
    for (optIndex = 0; optIndex < objOptionElements.length; optIndex++) {
        objOptionElement = objOptionElements[optIndex];
        if (!(objOptionElement.id == 'optDefaultNote')) {
            objOptionElement.disabled = false;
            objOptionElement.style.color = '';
        }
    }

    if (objSelectedItems.length == 0) {
        blnEnable = false;
    }

    // loop through all selected worklist items to check item type against request / response types linked to note types in select group
    for (var index = 0; index < objSelectedItems.length; index++) {
        var statusNotesDisabled = objSelectedItems[index].getAttribute('StatusNotesDisabled');
        if (statusNotesDisabled != null && statusNotesDisabled == "1") {
            blnEnable = false;
            break;
        }
        // Need to disable admin and discharge groups for prescription options ordersets
        var noteGroupName = objSelectElement.getAttribute("notegroupname");

        if (document.body.getAttribute("disableDischargeGroup").toLowerCase() == "yes") {
            if (noteGroupName.toLowerCase() == 'discharge status') {
                var contentsAreOptions = objSelectedItems[index].getAttribute('ContentsAreOptions');
                if (contentsAreOptions != null && contentsAreOptions == "1") {
                    blnEnable = false;
                    break;
                }
            }
        }

        intRequestTypeId = Number(objSelectedItems[index].getAttribute('RequestTypeID'));
        intResponseTypeId = Number(objSelectedItems[index].getAttribute('ResponseTypeID'));
        // See if this element applies to the selected request/response
        if (
		    !RequestTypeExistsInButton(objSelectElement, intRequestTypeId, objSelectedItems[index].getAttribute('ContentsAreOptions') == '1', objSelectedItems[index].getAttribute('IsOptionsSetChild') == '1') &&
 		    !ResponseTypeExistsInButton(objSelectElement, intResponseTypeId)) {
            //This element does not apply to this item.  Hence it is disabled.	
            blnEnable = false;
            break;
        }
        // See if the selected item is a completed request and notegroup is Administration
        if (intRequestTypeId > 0) {
            if (objSelectedItems[index].getAttribute('AdministrationStatus') == 'Complete' && objSelectElement.getAttribute('notegroupname').toLowerCase() == 'administration') {
                //This element applies to a completed item.  Hence it is disabled.	
                blnEnable = false;
                break;
            }

            if (objSelectedItems[index].getAttribute('CreationType') == 'Pre Pack' && objSelectElement.getAttribute('notegroupname').toLowerCase() == 'administration') {
                blnEnable = false;
                break;
            }
        }
        // loop through select group option elements to check if it should be enabled and to check if its associated Note Type is currently set
        // It may be possible to have items in a Note Group with some Note Types allowed in worklist and others not. If we have a mix then
        // need to disabled the option
        var intSelectedNoteType = 0;
        for (optIndex = 0; optIndex < objOptionElements.length; optIndex++) {
            objOptionElement = objOptionElements[optIndex];
            var strNoteType = objOptionElement.getAttribute('notetype');
            if ((!(objOptionElement.id == 'optDefaultNote')) || (noteGroupName.toLowerCase() == 'administration' && objSelectedItems[index].getAttribute('ContentsAreOptions') == '1')) {
                // Check if current worklist item is applies to the NoteType attached to option element
                if (!RequestTypeExistsInButton(objOptionElement, intRequestTypeId, objSelectedItems[index].getAttribute('ContentsAreOptions') == '1', objSelectedItems[index].getAttribute('IsOptionsSetChild') == '1') && !ResponseTypeExistsInButton(objOptionElement, intResponseTypeId)) {
                    objOptionElement.disabled = true;
                    objOptionElement.style.color = '#C0C0C0';
                } else if (noteGroupName.toLowerCase() == 'administration' && objSelectedItems[index].getAttribute('ContentsAreOptions') == '1' && strNoteType.toLowerCase() != 'nurseadmin' && strNoteType.toLowerCase() != 'homeadmin') {
                    objOptionElement.disabled = true;
                    objOptionElement.style.color = '#C0C0C0';
                }
                if (objOptionElement.id != 'optDefaultNote') {
                    // check if note type related to option element is currently set for worklist item
                    // if it is set then check it is also the same for other selected worklist items
                    if (Number(objSelectedItems[index].getAttribute(strNoteType)) == 1) {
                        intSelectedNoteType = optIndex;
                    }
                    if (Number(objSelectedItems[index].getAttribute(strNoteType)) == 2) {
                        intSelectedNoteType = -1;
                    }
                }
            }
        }
        if (intSelectIndex == undefined) {
            intSelectIndex = intSelectedNoteType;
        }
        else {
            if (!(intSelectIndex == intSelectedNoteType)) {
                intSelectIndex = -1;
            }
        }
    }

    if (blnEnable) {
        objSelectElement.parentNode.disabled = false;
        objSelectElement.disabled = false;
        objSelectElement.selectedIndex = intSelectIndex;
    }
    else {
        objSelectElement.selectedIndex = -1;
        objSelectElement.disabled = true;
    }

    var disabledCount = 0;

    for (optIndex = 0; optIndex < objOptionElements.length; optIndex++) {
        objOptionElement = objOptionElements[optIndex];
        objOptionElement.disabled = !ItemsShouldBeEnabled(objOptionElement, objSelectedItems);

        if (objOptionElement.disabled) {
            disabledCount++;
        }
    }

    if (disabledCount == objOptionElements.length) {
        objSelectElement.parentNode.disabled = true;
    }

    return blnEnable;
}

//=================================================================================================
function NoteGroupToggle(Button) {
    var Span = Button.parentNode;
    if (Span.disabled) {
        return;
    }

    var WorklistItems = GetHighlightedRowXML();

    var Select = Span.getElementsByTagName("select")[0];
    var SelectedIndex = Select.selectedIndex;

    if (!StatusNoteGroupEnable(Span, WorklistItems)) {
        return;
    }

    Select.selectedIndex = SelectedIndex;

    var Option = Select.options[Select.selectedIndex];
    var SessionID = document.body.getAttribute('sid');
    var StatusNoteUpdateDoc = PrepareStatusNoteUpdateXML(Option, WorklistItems);

    var NoteGroupID = Select.getAttribute("notegroupid");
    var NoteGroupName = Select.getAttribute("notegroupname");

    var NoteTypeNode = StatusNoteUpdateDoc.documentElement;
    var NoteTypeID = NoteTypeNode.getAttribute("NoteTypeID");
    var NoteType = NoteTypeNode.getAttribute("NoteType").split('_x0020_').join(' ');

    var RequestList = "";
    var ResponseList = "";
    var PostConditionRoutines = PreparePostconditionRoutinesXML();

    if (!ValidateNoteGroup(SessionID, WorklistItems, NoteGroupName, NoteType)) {
        StatusNoteGroupEnable(Span, WorklistItems);
        return;
    }

    var StatusNotes = NoteTypeNode.selectNodes("//RequestTypeStatusNote")
    for (StatusNoteIndex = 0; StatusNoteIndex < StatusNotes.length; StatusNoteIndex++) {
        var StatusNote = StatusNotes[StatusNoteIndex];
        var PostConditionRoutine = StatusNote.getAttribute("PostconditionRoutine");
        var Items = StatusNote.childNodes;
        var ItemList = "";
        for (index = 0; index < Items.length; index++) {
            var Item = Items[index];
            if (ItemList.length > 0) {
                ItemList = ItemList + ",";
            }
            ItemList = ItemList + Item.getAttribute("RequestID");
        }
        var ValidationResult = ValidateUpdate(SessionID, StatusNote, NoteTypeID, NoteType, "Request", Items, ItemList, false, true, NoteGroupID);
        if (ValidationResult == VALIDATION_FAIL_LOCK) {
            Refresh();
            return;
        }
        else if (ValidationResult == VALIDATION_FAIL) {
            UnlockRequests(SessionID, ItemList);
            StatusNoteGroupEnable(Span, WorklistItems);
            return;
        }
        if (RequestList.length > 0) {
            RequestList = RequestList + ",";
        }

        if (PostConditionRoutine != null && PostConditionRoutine != '') {
            AddPostconditionRoutine(PostConditionRoutines, PostConditionRoutine, NoteType, ItemList);
        }

        RequestList = RequestList + ItemList;
    }

    StatusNotes = NoteTypeNode.selectNodes("//ResponseTypeStatusNote")
    for (StatusNoteIndex = 0; StatusNoteIndex < StatusNotes.length; StatusNoteIndex++) {
        var StatusNote = StatusNotes[StatusNoteIndex];
        var PostConditionRoutine = StatusNote.getAttribute("PostconditionRoutine");
        var Items = StatusNote.childNodes;
        var ItemList = "";
        for (index = 0; index < Items.length; index++) {
            var Item = Items[index];
            if (ItemList.length > 0) {
                ItemList = ItemList + ",";
            }
            ItemList = ItemList + Item.getAttribute("ResponseID");
        }
        var ValidationResult = ValidateUpdate(SessionID, StatusNote, NoteTypeID, NoteType, "Response", Items, ItemList, false, true, NoteGroupID);
        if (ValidationResult != VALIDATION_PASS) {
            StatusNoteGroupEnable(Span, WorklistItems);
            return;
        }
        if (ResponseList.length > 0) {
            ResponseList = ResponseList + ",";
        }

        if (PostConditionRoutine != null && PostConditionRoutine != '') {
            AddPostconditionRoutine(PostConditionRoutines, PostConditionRoutine, NoteType, ItemList);
        }

        ResponseList = ResponseList + ItemList;
    }

    //Lock Requests
    if (!LockRequests(SessionID, RequestList)) {
        alert("One of the requests selected is Locked via another terminal, please try again shortly.");
        Refresh();
        return;
    }


    Span.disabled = true; 			//13Mar07 CD
    document.body.setAttribute('userenabled', 'false'); 			//13Mar07 CD
    for (index = 0; index < WorklistItems.length; index++) {
        // 06Dec06 PH	Add note type add to each item so that the printing system can later use it to find all reports
        //				associated with the notetype.
        WorklistItems[index].setAttribute("NoteTypeID", NoteTypeID);
    }
    //Create a new note of that type.
    var HasForm = NoteTypeNode.getAttribute("HasForm") == 'true';
    var IsPrintPreview = (document.body.getAttribute("IsPrintPreview") == "on");
    if (HasForm) {
        //Show order entry 
        if (IsPrintPreview) {
            // 08Apr07 PH Cannot print-preview actions with complex forms
            alert("Buttons with forms cannot be print-previewed. Switch off Print-Preview before changing the status of this item.");
        }
        else {
            var TableName = NoteTypeNode.getAttribute("TableName");
            var NoteData = GetNoteData(SessionID, TableName);
            if (!(NoteData == 'undefined' || NoteData == 'cancel')) {
                //Save the note against the specified item(s)
                fraSave.UpdateGroupNote(SessionID, RequestList, ResponseList, NoteType, NoteGroupID, NoteData, PostConditionRoutines.documentElement.xml);

                //Cache the data in case DSS checks fail and the user overrides the warnings
                m_SessionID = SessionID;
                m_RequestList = RequestList;
                m_ResponseList = ResponseList;
                m_NoteType = NoteType;
                m_NoteGroupID = NoteGroupID;
                m_NoteData = NoteData;
                m_PostConditionRoutines = PostConditionRoutines;
                
                // 06Dec06 PH Call printing system to print any reports associated with the note type, in BATCH mode.
                PrintItem(SessionID, WorklistItems, "batch", IsPrintPreview);
            }
            else {
                // F0079163 ST 17Mar10 Added refresh if we cancel from the note window
                Refresh();
                UnlockRequests(SessionID, RequestList);
                return;
            }
        }
    }
    else {
        //No form, just a simple call to create a note
        // 08Apr07 PH When print-previewing, we dont write any status changes
        if (!IsPrintPreview) {
            fraSave.UpdateGroupNote(SessionID, RequestList, ResponseList, NoteType, NoteGroupID, '', PostConditionRoutines.documentElement.xml);

            //Cache the data in case DSS checks fail and the user overrides the warnings
            m_SessionID = SessionID;
            m_RequestList = RequestList;
            m_ResponseList = ResponseList;
            m_NoteType = NoteType;
            m_NoteGroupID = NoteGroupID;
            m_NoteData = '';
            m_PostConditionRoutines = PostConditionRoutines;
        }
        // 06Dec06 PH Call printing system to print any reports associated with the note type, in BATCH mode.
        PrintItem(SessionID, WorklistItems, "batch", IsPrintPreview);
    }

    UnlockRequests(SessionID, RequestList);
}

//=================================================================================================

function GetSelectedItemIDs(objSelectedItems) {
    var strSelectedIDs = '';
    for (var index = 0; index < objSelectedItems.length; index++) {
        if (strSelectedIDs != '') {
            strSelectedIDs += ',';
        }
        strSelectedIDs += objSelectedItems[index].getAttribute('dbid');
    }
    return strSelectedIDs;
}

//=================================================================================================

function UpdateSelectedNoteTypes(objSelectedItems, strNoteTypeID) {
    var objReturnItems = objSelectedItems;
    for (var index = 0; index < objReturnItems.length; index++) {
        // 06Dec06 PH	Add note type add to each item so that the printing system can later use it to find all reports
        //				associated with the notetype.
        objReturnItems[index].setAttribute("NoteTypeID", strNoteTypeID);
    }
    return objReturnItems;
}

//=================================================================================================

function ValidateNoteGroup(intSessionID, objSelectedItems, strNoteGroupName, strNoteType) {
    var strItemsXML = '<setnote notegroup="' + strNoteGroupName + '" notetype="' + strNoteType + '">';
    for (var index = 0; index < objSelectedItems.length; index++) {
        strItemsXML = strItemsXML + objSelectedItems[index].xml
    }
    strItemsXML = strItemsXML + '</setnote>'
    var strURL = '../OrderEntry/NoteGroupCheck.aspx' + '?SessionID=' + intSessionID;

    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", strURL, false);      //false = syncronous                              
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send(strItemsXML);

    //  Check the response to see if any items are invalid
    var strResponseXML = objHTTPRequest.responseText;
    var xmlDOM = new ActiveXObject("MSXML2.DOMDocument")
    xmlDOM.loadXML(strResponseXML);
    var InvalidItems = xmlDOM.documentElement.childNodes;
    var retVal = true;
    for (var index = 0; index < InvalidItems.length; index++) {
        var strMessage = InvalidItems[index].getAttribute("message")
        var strFeatures = 'dialogHeight:250px;'
				+ 'dialogWidth:500px;'
				+ 'resizable:no;'
				+ 'status:no;help:no;';
        Popmessage(strMessage, 'Warning!', strFeatures)
        retVal = false;
    }
    return retVal;
}

//=================================================================================================

function ValidateUpdate(SessionID, StatusNote, NoteTypeID, NoteType, DataClass, Items, ItemList, Enabled, IsNoteGroup, NoteGroupId) {
    var AllowDuplicates = StatusNote.getAttribute("AllowDuplicates") == "1";
    if (!IsNoteGroup && !AllowDuplicates && !Enabled) {
        if (DataClass == 'Request' && !LockRequests(SessionID, ItemList)) {
            alert("One of the requests selected is Locked via another terminal, please try again shortly.");
            return VALIDATION_FAIL_LOCK;
        }

        var existingNotes = GetExistingNoteIds(SessionID, NoteTypeID, DataClass, ItemList);

        if (existingNotes.length > 0) {
            var invalidDescriptions = "";
            for (var index = 0; index <= existingNotes.length; index++) {
                var Item = FindItemByDbId(Items, DataClass, existingNotes[index]);
                if (Item == null) continue;
                invalidDescriptions += Item.getAttribute("Detail") + "\n";
            }
            alert("The item(s) below have already been marked as '" + StatusNote.getAttribute("ApplyVerb") + "', so they have been left unchanged.\n\n" + invalidDescriptions);
            return VALIDATION_FAIL;
        }
    }

    var UserAuthentication = StatusNote.getAttribute("UserAuthentication") == "1";
    var PreconditionRoutine = StatusNote.getAttribute("PreconditionRoutine");
    var StopOnError = StatusNote.getAttribute("StopOnError") == "1";
    var DiscontinuationReasonMandatory = StatusNote.getAttribute("DiscontinuationReasonMandatory") == "1";
    var NoteVerb;
    var StatusChange;
    if (Enabled) {
        NoteVerb = StatusNote.getAttribute("DeactivateVerb");
        StatusChange = 'Disable';
    }
    else {
        m_DiscontinuationReason = null;
        NoteVerb = StatusNote.getAttribute("ApplyVerb");
        StatusChange = 'Enable';
    }

    if (UserAuthentication) {
        if (AuthenticateUser(SessionID) != 'Valid') {
            return VALIDATION_FAIL;
        }
    }

    if (IsNoteGroup) {
        var itemIds = ItemList.split(",");
        for (var i = 0; i < itemIds.length; i++) {
            var groupDisableUrl = '../OrderEntry/PreconditionRoutine.aspx?SessionID=' + SessionID + '&ItemIDList=' + itemIds[i] + '&BaseType=' + DataClass + '&NoteGroupIdToDisable=' + NoteGroupId;
            var groupDisableHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP");
            groupDisableHTTPRequest.open("GET", groupDisableUrl, false);
            groupDisableHTTPRequest.send();
            var groupDisablePreconditionResult = groupDisableHTTPRequest.responseText;

            if (groupDisablePreconditionResult != "") {
                if (StopOnError && groupDisablePreconditionResult.substr(0, 6) == "ERROR:") {
                    alert(groupDisablePreconditionResult.substr(6, groupDisableHTTPRequest.responseText.length - 6));
                    return VALIDATION_FAIL;
                } else {
                    if (!confirm(groupDisablePreconditionResult)) {
                        return VALIDATION_FAIL;
                    }
                }
            }
        }
    }

    if (!(PreconditionRoutine == null || PreconditionRoutine == "")) {
        var URL = '../OrderEntry/PreconditionRoutine.aspx?SessionID=' + SessionID + '&ItemIDList=' + ItemList + '&BaseType=' + DataClass + '&Routine=' + PreconditionRoutine + '&StatusChange=' + StatusChange;
        var myobjHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP");
        myobjHTTPRequest.open("GET", URL, false);
        myobjHTTPRequest.send();
        var PreconditionResult = myobjHTTPRequest.responseText;

        if (PreconditionResult != "") {
            if (StopOnError && PreconditionResult.substr(0, 6) == "ERROR:") {
                alert(NoteType + "\r\n\r\n" + PreconditionResult.substr(6, myobjHTTPRequest.responseText.length - 6));
                return VALIDATION_FAIL;
            }
            else {
                if (!confirm(NoteType + "\r\n\r\n" + PreconditionResult)) {
                    return VALIDATION_FAIL;
                }
            }
        }
    }

    if (Enabled && DiscontinuationReasonMandatory) {
        m_DiscontinuationReason = new Object();
        if (ShowStopReason(SessionID) == false) {
            return VALIDATION_FAIL;
        }
    }

    return VALIDATION_PASS;
}

//=================================================================================================

function AuthenticateUser(SessionID) {
    var URL = '../ICW/authenticatemodal.aspx'
				  	+ '?SessionID=' + SessionID

    var Features = 'dialogHeight:250px;'
					+ 'dialogWidth:400px;'
					+ 'resizable:no;unadorned:no;'
					+ 'status:no;help:no;';

    var Return = window.showModalDialog(URL, '', Features);
    if (Return == 'logoutFromActivityTimeout') {
        Return = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    return Return;
}

//=================================================================================================

function ShowStopReason(SessionID) {
    var URL = '../ICW/ReasonCapture.aspx'
				  	+ '?SessionID=' + SessionID;


    var Features = 'dialogHeight:300px;'
					+ 'dialogWidth:600px;'
					+ 'resizable:no;unadorned:no;'
					+ 'status:no;help:no;';

    var Return = window.showModalDialog(URL, '', Features);
    if (Return == 'logoutFromActivityTimeout') {
        Return = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (Return == null || Return.cancelselected == 'true') {
        alert('Cannot Save changes, Discontinuation Reason is mandatory');
        return false;
    }
    else {
        m_DiscontinuationReason = Return;
        return true;
    }

}

//=================================================================================================

function GetNoteData(SessionID, TableName) {
    var URL = V11Location(SessionID) + '/OrderComms/Views/OrderEntry/AttachedNoteDataEntry.aspx'
					+ '?SessionID=' + SessionID
					+ '&TableName=' + TableName;
    var v11Mask = ICWWindow().document.getElementById('v11Mask');

    v11Mask.style.display = 'block';
    v11Mask.style.top = 0;

    var NoteData = window.showModalDialog(URL, '', OrderEntryFeaturesV11());
    if (NoteData == 'logoutFromActivityTimeout') {
        NoteData = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    v11Mask.style.display = 'none';

    return NoteData;
}

//=================================================================================================

function slcNoteGroup_onpropertychange(SelectElement) {
    if (window.event.propertyName == 'selectedIndex') {
        var ButtonElement = SelectElement.parentNode.getElementsByTagName("button")[0];
        if (SelectElement.selectedIndex > -1) {
            if (SelectElement.options[SelectElement.selectedIndex].isDisabled) {
                SelectElement.selectedIndex = -1;
            }
            else {
                ButtonElement.disabled = false;
            }
        }
        else {
            ButtonElement.disabled = true;
        }
    }
}

//=================================================================================================

function ClearStatusNoteCache() {
    //Clear the cache
    m_SessionID = -1;
    m_RequestList = '';
    m_ResponseList = '';
    m_NoteType = '';
    m_NoteGroupID = '';
    m_NoteData = '';
    m_PostConditionRoutines = '';
}

//=================================================================================================

function DSSCheckOnFail(Override, DSSLogResults) {
    var SessionID = m_SessionID;
    var RequestList = m_RequestList;
    var ResponseList = m_ResponseList;
    var NoteType = m_NoteType;
    var NoteGroupID = m_NoteGroupID;
    var NoteData = m_NoteData;
    var PostConditionRoutines = m_PostConditionRoutines;
    ClearStatusNoteCache();
    //04Apr11   Rams    F0113638 - If DSS Checking is enabled against the screening note, when the screening note is applied, the worklist is not refreshed - see attachement - 10.06.00.31 - Norfolk
    //                  [Changed from (RequestList != '' && ResponseList != '') to (RequestList != '' || ResponseList != '')]
    if (Override && (RequestList != '' || ResponseList != '')) {
        if (NoteGroupID == '') {
            fraSave.AttachSystemNote(SessionID, RequestList, ResponseList, NoteType, NoteData, true, DSSLogResults, false, PostConditionRoutines.documentElement.xml);
        }
        else {
            fraSave.UpdateGroupNote(SessionID, RequestList, ResponseList, NoteType, NoteGroupID, NoteData, true, DSSLogResults, PostConditionRoutines.documentElement.xml);
        }
    }
    else {
        Refresh();
    }
}

//================================================================================================

function PostServerMessage(url, data) {
    var result;
    $.ajax({
        type: "POST",
        url: url,
        data: data,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (msg) {
            result = msg;
        }
    });
    return result;
}

//================================================================================================

function GetExistingNoteIds(sessionId, noteTypeId, baseType, typeIds) {
    var url = "../WorklistHelper/worklistHelper.aspx/GetExistingNoteIds"
    var sendData = "{'sessionId': '" + sessionId + "', 'noteTypeId': '" + noteTypeId + "', 'baseType': '" + baseType + "', 'typeIds': '" + typeIds + "' }";
    var returnData = PostServerMessage(url, sendData);
    if (returnData == null || returnData == undefined) {
        return [];
    }
    return returnData.d;
}

//================================================================================================

function LockRequests(sessionId, requestIds) {
    var url = "../WorklistHelper/worklistHelper.aspx/LockRequests"
    var sendData = "{'sessionId': '" + sessionId + "', 'requestIds': '" + requestIds + "' }";
    var returnData = PostServerMessage(url, sendData);
    if (returnData == null || returnData == undefined) {
        return null;
    }
    return returnData.d;
}

//================================================================================================

function UnlockRequests(sessionId, requestIds) {
    var url = "../WorklistHelper/worklistHelper.aspx/UnlockRequests"
    var sendData = "{'sessionId': '" + sessionId + "', 'requestIds': '" + requestIds + "' }";
    var returnData = PostServerMessage(url, sendData);
    if (returnData == null || returnData == undefined) {
        return null;
    }
    return returnData.d;
}

//================================================================================================

function FindItemByDbId(Items, DataClass, requestedDbId) {
    if (requestedDbId == null) return null;
    for (var index = 0; index <= Items.length; index++) {
        var dbid;
        if (DataClass == "Request") {
            dbid = Items[index].getAttribute("RequestID");
        }
        else {
            dbid = Items[index].getAttribute("ResponseID");
        }
        if (dbid != undefined && dbid != null && dbid != requestedDbId) continue;
        return Items[index];
    }
    return null;
}

//=================================================================================================

function GetRequestTypeDataForRequestTypeID(requestTypeID, noteTypeID) {
    var SessionID = document.body.getAttribute('sid');
    var strURL = '../sharedscripts/StatusNoteHelper.aspx' + '?SessionID=' + SessionID + '&RequestTypeID=' + requestTypeID + '&Mode=RequestType' + '&NoteTypeID=' + noteTypeID;
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", strURL, false);
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send("");

    var xmlDOM = new ActiveXObject('MSXML2.DOMDocument');
    xmlDOM.loadXML(objHTTPRequest.responseText);

    return xmlDOM.selectSingleNode("//RequestTypeStatusNote");
}

//=================================================================================================

function GetResponseTypeDataForResponseTypeID(responseTypeID, noteTypeID) {
    var SessionID = document.body.getAttribute('sid');
    var strURL = '../sharedscripts/StatusNoteHelper.aspx' + '?SessionID=' + SessionID + '&ResponseTypeID=' + responseTypeID + '&Mode=ResponseType' + '&NoteTypeID=' + noteTypeID;
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", strURL, false);
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send("");

    var xmlDOM = new ActiveXObject('MSXML2.DOMDocument');
    xmlDOM.loadXML(objHTTPRequest.responseText);

    return xmlDOM.selectSingleNode("//ResponseTypeStatusNote");
}

function GetRequestTypeForContentsAreOptions(objSrc) {
    var types = objSrc.getElementsByTagName("RequestType");
    for (var i = 0; i < types.length; i++) {
        var showinoptionsset = types[i].getAttribute("showinoptionsset");
        if (showinoptionsset != null && showinoptionsset.toLowerCase() == "false") {
            return types[i].getAttribute("id");
        }
    }
}

//=================================================================================================

function PreparePostconditionRoutinesXML() {
    var PostconditionDoc = new ActiveXObject('MSXML2.DOMDocument');
    PostconditionDoc.loadXML("<PostconditionRoutines></PostconditionRoutines>");

    return PostconditionDoc;
}

function AddPostconditionRoutine(PostconditionDoc, PostconditionRoutine, NoteType, ItemIDList) {
    var NODE_ELEMENT = 1;

    var Routine = PostconditionDoc.createNode(NODE_ELEMENT, "Routine", "");
    Routine.setAttribute("PostconditionRoutine", PostconditionRoutine);
    Routine.setAttribute("ItemIDList", ItemIDList);
    Routine.setAttribute("NoteType", NoteType);
    PostconditionDoc.documentElement.appendChild(Routine);
}

function PrepareStatusNoteUpdateXML(objSrc, colItems) {
    var NODE_ELEMENT = 1;   
    var NoteTypeID = objSrc.getAttribute("notetypeid");
    var NoteTypeName = objSrc.getAttribute("notetype");
    var NoteTypeDoc = new ActiveXObject('MSXML2.DOMDocument');
    NoteTypeDoc.loadXML("<NoteType><RequestTypes /><ResponseTypes /></NoteType>");
    var NoteType = NoteTypeDoc.documentElement;
    NoteType.setAttribute("NoteTypeID", NoteTypeID);
    NoteType.setAttribute("NoteType", NoteTypeName);
    NoteType.setAttribute("TableName", objSrc.getAttribute("tablename"));
    NoteType.setAttribute("HasForm", objSrc.getAttribute("hasform"));

    for (index = 0; index < colItems.length; index++) {
        var item = colItems[index];
        var Class = item.getAttribute("class");
        var dbid = item.getAttribute("dbid");
        var Enabled = item.getAttribute(NoteTypeName);
        var Detail = item.getAttribute("detail");
        if (Class == "request") {
            var RequestTypeID = item.getAttribute("RequestTypeID");
            var RequestType = NoteType.selectSingleNode("RequestTypes/RequestTypeStatusNote[@RequestTypeID='" + RequestTypeID + "']");
            if (RequestType == null && item.getAttribute("ContentsAreOptions") == "1") {
                RequestTypeID = GetRequestTypeForContentsAreOptions(objSrc);
            }
            if (RequestType == null) {
                RequestType = NoteType.selectSingleNode("RequestTypes").appendChild(GetRequestTypeDataForRequestTypeID(RequestTypeID, NoteTypeID));
            }

            if (RequestType != null) {
                var Request = NoteTypeDoc.createNode(NODE_ELEMENT, "Request", "");
                Request.setAttribute("RequestID", dbid);
                Request.setAttribute("Detail", Detail);
                Request.setAttribute("Enabled", Enabled == null ? "0" : Enabled);
                RequestType.appendChild(Request);
            }
        }
        else if (Class == "response") {
            var ResponseTypeID = item.getAttribute("ResponseTypeID");
            var ResponseType = NoteType.selectSingleNode("ResponseTypes/ResponseTypeStatusNote[@ResponseTypeID='" + ResponseTypeID + "']");
            if (ResponseType == null) {
                ResponseType = NoteType.selectSingleNode("ResponseTypes").appendChild(GetResponseTypeDataForResponseTypeID(ResponseTypeID, NoteTypeID));
            }
            if (ResponseType != null) {
                //06Nov2011 Rams    48137 - Clatterbridge - Chart on behal
                var Response = NoteTypeDoc.createNode(NODE_ELEMENT, "Response", "");
                Response.setAttribute("ResponseID", dbid);
                Response.setAttribute("Detail", Detail);
                Response.setAttribute("Enabled", Enabled == null ? "0" : Enabled);
                ResponseType.appendChild(Response);
            }
        }
    }
    return NoteTypeDoc;
}

function GetQueryString(name) {
    // Get the href of the current page
    var href = "";
    try {
        href = window.location.href;
    }
    catch (err) {
        // In IE9 window.location.href fails - ugh!
        // So we will use document.URL instead as this appears to work..
        //alert(err.description);
        href = document.URL;
    }

    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regexS = "[\\?&]" + name + "=([^&#]*)";
    var regex = new RegExp(regexS);
    var results = regex.exec(href);
    if (results == null) return "";
    else return results[1];
}


function ItemsShouldBeEnabled(obj, items) {

    var blnEnable = true;

    for (var i = 0; i < items.length; i++) {

        var lngRequestTypeId = Number(items[i].getAttribute('RequestTypeID'));
        var lngResponseTypeId = Number(items[i].getAttribute('ResponseTypeID'));

        if (lngRequestTypeId > 0) {
            blnEnable = blnEnable & ItemShouldBeEnabled(obj, "requesttype", lngRequestTypeId, items[i]);
        }

        if (lngResponseTypeId > 0) {
            blnEnable = blnEnable & ItemShouldBeEnabled(obj, "responsetype", lngResponseTypeId, items[i]);
        }
    }

    return blnEnable;
}


function ItemShouldBeEnabled(obj, tagName, lngRequestTypeId, item) {

    var itemHomelyRemedy = item.getAttribute('HomelyRemedy');

    if (itemHomelyRemedy == 1) {
        return false;
    }

    var itemFullyResulted = item.getAttribute('FullyResulted');
    var itemCancelled = item.getAttribute('Cancelled');
    var itemExpired = item.getAttribute('Expired');

    var isActive = itemFullyResulted != 1 & itemCancelled != 1 & itemExpired != 1;

    var requesttype;

    var col = obj.getElementsByTagName(tagName);

    for (var j = 0; j < col.length; j++) {
        if (col[j].id == lngRequestTypeId) {
            requesttype = col[j];
            break;
        }
    }

    if (requesttype == undefined) {
        return isActive;
    }

    // Check whether or not the item is closed and whether the button should be enabled in this situation
    var alterOnInactive = requesttype.getAttribute('AlterOnInactive');

    return isActive || alterOnInactive == 1;
}