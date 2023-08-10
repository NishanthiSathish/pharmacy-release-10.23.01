/*

OCSShared.js

Shared client script for various Order Comms functions
	
Function																Description
-------------------------------------------------------------------------------------------------------------
OrderEntryFeatures()												Returns a features string for passing to the showModalDialog
method, with the size of the window calculated based on the
current screen resolution.  Should always be used when showing
Order Entry modally to give a consistent approach.
	
EditAttachedNotes(SessionID, ItemType, ItemID)			Launches the attached notes editor.  Allows the viewing / 
editing of notes attached to request, response, and pending items.

	
Modification History:
12May03 AE  Written
24Jun03 AE  Added EditAttachedNotes function.
18Oct03 AE  Modified OrderEntryFeatures to make order entry smaller by default.
24Jun04 AE  Added PickProblem to shared script
17Jan07 ST  Added ViewDSSReason to view an override reason attached to a shown dss warning
22Feb12 CJM TFS24305 TrackChanges parameter added to OrderEntry(), and new parameter added to OrderEntryModal call
*/

//===========================================================================================
var PROBLEMPICKER_FEATURES = 'dialogHeight:500px; dialogWidth:800px;status:off;resizable:off; help:no';



//===========================================================================================
function OrderEntryFeaturesV11(Left, Top, Width, Height) {
    var strFeatures = new String();

    var intTop = 24;
    var intHeight = screen.height - 100;
    var intWidth = Math.min(screen.width - 32, 1024);
    var intLeft = (screen.width / 2) - (intWidth / 2);

    if (window.top.screenLeft >= screen.width) {
        intLeft += screen.width;
    }

    if (Width != undefined && Width > 0) intWidth = Width;
    if (Height != undefined && Height > 0) intHeight = Height;
    if (Left != undefined && Left > 0) intLeft = Left;
    if (Top != undefined && Top > 0) intTop = Top;

    strFeatures = 'dialogHeight:' + intHeight + 'px;'
					 + 'dialogWidth:' + intWidth + 'px;'
					 + 'dialogLeft:' + intLeft + 'px;'
					 + 'dialogTop:' + intTop + 'px;'
					 + 'resizable:yes;unadorned:no;'
					 + 'status:off;edge:raised;';

    return strFeatures;
}

//===========================================================================================
function OrderEntryFeatures(Left, Top, Width, Height) {

    //Standard size & features for showing order entry modally

    var strFeatures = new String();

    var intWidth;
    var intHeight;

    intWidth = screen.width / 1.1;
    intHeight = screen.height / 1.1;

    if (intWidth < 800)
    { intWidth = 800; }
    if (intHeight < 600)
    { intHeight = 600; }
    if (intWidth > 1024)
    { intWidth = 1024; }
    if (intHeight > 768)
    { intHeight = 768; }

    if (Width != undefined && Width > 0) intWidth = Width;
    if (Height != undefined && Height > 0) intHeight = Height;

    if (Top != undefined && Top > 0)
    { strFeatures += 'dialogTop:' + Top + 'px;'; }

    intWidth = Math.ceil(intWidth); 					//ceil (ceiling) rounds up to the nearest integer.  Nice method name guys!
    intHeight = Math.ceil(intHeight);

    strFeatures = 'dialogHeight:' + intHeight + 'px;'
					 + 'dialogWidth:' + intWidth + 'px;'
					 + 'resizable:yes;unadorned:no;'
					 + 'status:no;help:no;';

    if (Left != undefined && Left > 0)
    { strFeatures += 'dialogLeft:' + Left + 'px;'; }
    if (Top != undefined && Top > 0)
    { strFeatures += 'dialogTop:' + Top + 'px;'; }

    return strFeatures;
}

//===========================================================================================
function SupplyRequest(SessionID, OrdersXML, SupplyRequestType) {

    //Shows SupplyRequest.
    //Returns: string.  The return value from OrderEntry.



    //save the OrdersXML into SessionAttribute
    var strFeatures = 'dialogHeight: 700px;'
					 + 'dialogWidth: 1000px;'
					 + 'resizable:yes;unadorned:no;'
					 + 'status:no;help:no;';

    var strSendXML = OrdersXML.split('&amp;amp;').join('_amp_');
    strSendXML = strSendXML.split('&amp;').join('_amp_');
    var strURL = '../OrderEntry/OrderEntrySaver.aspx'
				  + '?SessionID=' + SessionID
				  + '&Mode=xmlput';
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", strURL, false);               										//false = syncronous                              
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send(strSendXML);


    var LocationV11 = V11Location(SessionID);

    //check if endwith "/"
    if (LocationV11.substr(-1) === "/") {

    }
    else {
        LocationV11 += "/";
    }

    strURL = LocationV11 + 'OrderComms/Views/OrderEntry/SupplyRequest.aspx' + '?SessionID=' + SessionID + '&SupplyRequestType=' + SupplyRequestType;
    var objArgs = new Object();
    objArgs.opener = self;
    if (window.dialogArguments == undefined) {
        objArgs.icwwindow = window.parent.ICWWindow();
    }
    else {
        objArgs.icwwindow = window.dialogArguments.icwwindow;
    }

    var v11Mask = ICWWindow().document.getElementById('v11Mask');
    v11Mask.style.display = 'block';
    v11Mask.style.top = 0;
    var retValue = window.showModalDialog(strURL, objArgs, strFeatures);
    v11Mask.style.display = 'none';
    if (retValue == 'logoutFromActivityTimeout') {
        retValue = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (retValue == 'cancel' || retValue == undefined) {
        //
    }
    else {
        ICWWindow().frames("fraPrintProcessor").DoPrint(SessionID, retValue);
    }
    return retValue;
}

//===========================================================================================
function PBSRequest(SessionID, OrdersXML, PBSRequestType, Mode) {

    //Shows PBS form.
    //Returns: string.  The return value from OrderEntry.



    //save the OrdersXML into SessionAttribute
    var strFeatures = 'dialogHeight: 740px;'
					 + 'dialogWidth: 1000px;'
					 + 'resizable:yes;unadorned:no;'
					 + 'status:no;help:no;';

    var strSendXML = OrdersXML.split('&amp;amp;').join('_amp_');
    strSendXML = strSendXML.split('&amp;').join('_amp_');
    var strURL = '../OrderEntry/OrderEntrySaver.aspx'
				  + '?SessionID=' + SessionID
				  + '&Mode=xmlput';
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", strURL, false);               										//false = syncronous                              
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send(strSendXML);


    var LocationV11 = V11Location(SessionID);

    //check if endwith "/"
    if (LocationV11.substr(-1) === "/") {

    }
    else {
        LocationV11 += "/";
    }

    strURL = LocationV11 + 'OrderComms/Views/PBS/PBSRequest.aspx' + '?SessionID=' + SessionID + '&PbsRequestType=' + PBSRequestType + '&Mode=' + Mode;

    var objArgs = new Object();
    objArgs.opener = self;
    if (window.dialogArguments == undefined) {
        objArgs.icwwindow = window.parent.ICWWindow();
    }
    else {
        objArgs.icwwindow = window.dialogArguments.icwwindow;
    }

    var v11Mask = ICWWindow().document.getElementById('v11Mask');
    v11Mask.style.display = 'block';
    v11Mask.style.top = 0;
    var retValue = window.showModalDialog(strURL, objArgs, strFeatures);
    v11Mask.style.display = 'none';
    if (retValue == 'logoutFromActivityTimeout') {
        retValue = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (retValue == '' || retValue == 'cancel' || retValue == undefined) {
        //
    }
    else {
        if (retValue == 'Success') {
            //User has pressed save that need not require printing, so there will not be any json data back from the order comms
        }
        else {
            //[{ "RequestId": 153, "TableId": 897, "RequestTypeId": 63, "OrderReportTypeId": 4}]
            var data = JSON.parse(retValue);
            var strXML = '<printitems>';
            var orderReportTypeId;
            for (i = 0; i < data.length; i++) {
                orderReportTypeId = data[i].OrderReportTypeId;
                strXML += '<item '
				  + 'tableid="' + data[i].TableId + '" '
				  + 'dbid="' + data[i].RequestId + '" '
				  + 'requesttypeid="' + data[i].RequestTypeId + '" '
				  + 'responsetypeid="' + 0 + '" '
				  + 'notetypeid="' + 0 + '" '
				  + '/>'
            }

            strXML += '</printitems>'

            ICWWindow().frames("fraPrintProcessor").PrintItems(SessionID, strXML, orderReportTypeId, false, "");
        }
    }
    return retValue;
}

function sendData(url, data) {
    var XHR = new XMLHttpRequest();
    var urlEncodedData = "";
    var urlEncodedDataPairs = [];
    var name;

    // We turn the data object into an array of URL encoded key value pairs.
    for (name in data) {
        urlEncodedDataPairs.push(encodeURIComponent(name) + '=' + encodeURIComponent(data[name]));
    }

    // We combine the pairs into a single string and replace all encoded spaces to 
    // the plus character to match the behaviour of the web browser form submit.
    urlEncodedData = urlEncodedDataPairs.join('&').replace(/%20/g, '+');

    // We setup our request
    XHR.open('POST', url);

    // We add the required HTTP header to handle a form data POST request
    XHR.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    XHR.setRequestHeader('Content-Length', urlEncodedData.length);

    // And finally, We send our data.
    XHR.send(urlEncodedData);
}

//===========================================================================================
function OrderEntry(SessionID, OrdersXML, DispensaryMode, DefaultCreationType, TrackChanges, MinimalisticMode, SendCaption, ShowHistoryTab) {

    //Shows OrderEntry.
    //Returns: string.  The return value from OrderEntry.

    //First, we fire the OrdersXML to the server where it is deposited into state.
    //Then we spawn OrderEntry, which retreives this XML.  This is to allow us to send
    //more than the 4096 bytes of XML that the dialogArguments property of showModalDialog allows.

    //do post
    var strSendXML = OrdersXML.split('&amp;amp;').join('_amp_');
    strSendXML = strSendXML.split('&amp;').join('_amp_');

    if (!IsInTestRig()) {
        var strURL = '../OrderEntry/OrderEntrySaver.aspx'
				      + '?SessionID=' + SessionID
				      + '&Mode=xmlput';
        var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
        objHTTPRequest.open("POST", strURL, false);               										//false = syncronous                              
        objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        objHTTPRequest.send(strSendXML);
    }
    else {
        var strURL = '../OrderEntry/OrderEntrySaver.aspx'
				      + '?SessionID=' + SessionID
				      + '&Mode=xmlput_testrig';
        var myData = {
            "dataXML": ""
        };

        myData.dataXML = strSendXML;

        sendData(strURL, myData);
    }

    //Now we show OrderEntry itself
    DispensaryMode = (DispensaryMode == true); 	//Ensure that DispensaryMode is a boolean				//12Mar07 AE  Corrected n00b-standard boolean logic error.

    strURL = '../OrderEntry/OrderEntryModal.aspx'
        + '?SessionID=' + SessionID
        + '&Action=load'
        + '&DispensaryMode=' + (DispensaryMode ? '1' : '0')
        + '&DefaultCreationType=' + DefaultCreationType
        + '&TrackChanges=' + TrackChanges;

    if (MinimalisticMode != undefined)
        strURL += '&MinimalisticMode=' + MinimalisticMode;

    if (SendCaption != undefined)
        strURL += '&SendCaption=' + SendCaption;

    if (ShowHistoryTab != undefined)
        strURL += '&ShowHistoryTab=' + ShowHistoryTab;

    //26Sep2009 JMei F0040487 Passing the caller self to modal dialog so that modal dialog can access its opener
    var objArgs = new Object();
    objArgs.opener = self;
    if (window.dialogArguments == undefined) {
        icw = ICWWindow();
    }
    else if (window.parent.ICWWindow != undefined && window.parent.ICWWindow() != null) {
        icw = window.parent.ICWWindow();
    }
    else {
        icw = window.dialogArguments.icwwindow;
    }

    var objArgs = new Object();
    objArgs.opener = self;
    objArgs.icwwindow = icw;

    var useV11 = UsingV11(SessionID);
    var isTemplate = strSendXML.substring(0, 10) == '<template>';

    if (useV11 && !isTemplate && !DispensaryMode) {
        if (icw != null) {
            var v11Mask = icw.document.getElementById('v11Mask');
            v11Mask.style.display = 'block';
            v11Mask.style.top = 0;
        }
        var retValue = window.showModalDialog(strURL, objArgs, OrderEntryFeaturesV11());
        if (retValue == 'logoutFromActivityTimeout') {
            retValue = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }
        if (retValue!=null && retValue != '' && retValue != 'cancel' && retValue != 'refresh') {
            CheckForPrinting(SessionID, retValue);
            CheckV11Return(SessionID, retValue);

        }
        if (icw != null) {
            v11Mask.style.display = 'none';
        }
        return retValue;
    }
    else {
        if (useV11 && !DispensaryMode) {
            strURL += '&V10=1';
        }

        var ret = window.showModalDialog(strURL, objArgs, OrderEntryFeatures());
        if (ret == 'logoutFromActivityTimeout') {
            ret = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }
        if (ret != null) return ret;

    }
}
//===========================================================================================

// BEGIN Call V11 Webservice
// base URL for the Ajax call to service
function TableHasSubform(SessionID, TableId, ErrorText) {
    var LocationV11 = V11Location(SessionID);

    if (LocationV11.substr(-1) != "/") {
        LocationV11 += "/";
    }
    var url = LocationV11 + "SubFormCheck/HasSubforms.aspx?sessionId=" + SessionID + "&tableIds=" + TableId;

    objHTTPRequest = (window.XMLHttpRequest) ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("GET", url, false);
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send();
    return HasResponseText(objHTTPRequest.responseText, ErrorText);
}

// END Webservice Call
//===========================================================================================

// BEGIN Call V11 Webservice
// base URL for the Ajax call to service
function OrdersHaveSubforms(SessionID, RequestIds, NoteIds, ErrorText) {
    var LocationV11 = V11Location(SessionID);

    if (LocationV11.substr(-1) != "/") {
        LocationV11 += "/";
    }
    var url = LocationV11 + "SubFormCheck/HasSubforms.aspx?sessionId=" + SessionID + "&requestIds=" + RequestIds + "&noteIds=" + NoteIds;

    objHTTPRequest = (window.XMLHttpRequest) ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("GET", url, false);
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send();
    return HasResponseText(objHTTPRequest.responseText, ErrorText);
}

// END Webservice Call

function HasResponseText(responseText, ErrorText) {
    if (responseText) {
        alert(ErrorText + responseText);
        return true;
    } else {
        return false;
    }
}

function OrderEntryByTemplate(SessionID, Template, DispensaryMode) {
    //Shows OrderEntry.
    //Returns: string.  The return value from OrderEntry.

    //Used to show OrderEntry for a given OrderTemplate name or ID.


    //Now we show OrderEntry itself
    DispensaryMode = (DispensaryMode == true); 	//Ensure that DispensaryMode is a boolean				//12Mar07 AE  Corrected n00b-standard boolean logic error.

    strURL = '../OrderEntry/OrderEntryModal.aspx'
	  	    + '?SessionID=' + SessionID
	  	    + '&Action=load'
			 + '&DispensaryMode=' + (DispensaryMode ? '1' : '0')
			 + '&OrderTemplate=' + Template;

    //26Sep2009 JMei F0040487 Passing the caller self to modal dialog so that modal dialog can access its opener
    var objArgs = new Object();
    objArgs.opener = self;
    if (window.dialogArguments == undefined) {
        objArgs.icwwindow = window.parent.ICWWindow();
    }
    else {
        objArgs.icwwindow = window.dialogArguments.icwwindow;
    }
    var ret = window.showModalDialog(strURL, objArgs, OrderEntryFeatures());
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (ret != null) return ret;
}

function CheckForPrinting(sessionID, savedItems) {
    var DOM = new ActiveXObject("MSXML2.DOMDocument");
    DOM.loadXML(savedItems);
    var notes = DOM.selectNodes("//attachednote");
    if (notes.length && notes.length > 0) {
        PrintItem(sessionID, notes, "batch", false);
    }

    var printBatches = DOM.selectNodes("//printBatch");
    if (printBatches.length && printBatches.length > 0) {
        for (var i = 0; i < printBatches.length; i++) {
            icw.document.frames['fraPrintProcessor'].PrintBatch(sessionID, printBatches[i].getAttribute("id"), false, null);
        }
    }
}

function CheckV11Return(sessionID, savedItems) {
    var objHTTPRequest = new ActiveXObject('Microsoft.XMLHTTP');
    var strUrl = '../OrderEntry/OrderEntrySaver_V11.aspx?SessionID=' + sessionID;

    objHTTPRequest.open('POST', strUrl, false); //false = syncronous                              
    objHTTPRequest.send(savedItems);
    if (objHTTPRequest.responseText.toLowerCase() == 'true' && HasImmediateAdmin(sessionID)) {
        strUrl = '../DrugAdministration/ImmediateAdmin_Modal.aspx'
		    + '?SessionID=' + sessionID
		    + '&Phase=startfast';

        var Features = 'dialogHeight:300px;'
		    + 'dialogWidth:450px;'
		    + 'resizable:no;unadorned:no;'
		    + 'status:no;help:no;';

        var ret = window.showModalDialog(strUrl, '', Features);
        if (ret == 'logoutFromActivityTimeout') {
            ret = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }

    }
}

//---------------------------------------------------------------------------------

function HasImmediateAdmin(sessionId) {
    var url = "../DrugAdministration/ImmediateAdminHelper.aspx/CheckImmediateAdmin";
    var sendData = "{'sessionId': '" + sessionId + "' }";
    var returnData = PostServerMessage(url, sendData);
    if (returnData == null || returnData == undefined) {
        return false;
    }
    return returnData.d;
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

//===========================================================================================

function EditAttachedNotes(SessionID, ItemType, ItemID, V11PendingID)
{

    //Display the notes editor for viewing / adding of attached notes.
    //
    //	SessionID:			Long; Standard SessionID
    //	ItemType:			one of:  pending, request, response
    //							The root type of the item whos notes are being edited.
    //	ItemID:				Long unique ID of the item.

    if (V11PendingID == undefined || V11PendingID == "undefined")
    {
        V11PendingID = "";
    }

    //Build the URL	
    var strURL = '../NotesEditor/NotesEditor.aspx'
				  + '?SessionID=' + SessionID
				  + '&Mode=' + ItemType
				  + '&ID=' + ItemID
				  + '&V11PendingID=' + V11PendingID;

    //Build the features string
    var strFeatures = 'dialogHeight:400px;'
						 + 'dialogWidth:600px;';

    var useV11 = UsingV11(SessionID);
    //var v11Mask = ICWWindow().document.getElementById('v11Mask');
    var v11Mask = undefined;
    if (useV11)
    {
        if (ICWWindow() != undefined)
        {
            v11Mask = ICWWindow().document.getElementById('v11Mask');
            v11Mask.style.display = 'block';
            v11Mask.style.top = 0;
        }
        strFeatures = OrderEntryFeaturesV11(undefined, undefined, 900, 680);
    }
    else
    {
        strFeatures = strFeatures
					+ 'resizable:yes;unadorned:no;'
					+ 'status:no;help:no;';
    }

    //Launch the editor
    var retValue = window.showModalDialog(strURL, '', strFeatures);
    if (retValue == 'logoutFromActivityTimeout') {
        window.returnValue = 'logoutFromActivityTimeout';
        retValue = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    else
        retValue = true;
    if (useV11 && v11Mask != undefined)
        v11Mask.style.display = 'none';
    return retValue;
}

//===========================================================================================
function ViewDSSReason(SessionID, ItemType, ItemID) {

    //Display the notes editor for viewing reasons why a dss warning was overridden
    //
    //	SessionID:			Long; Standard SessionID
    //	ItemType:			one of:  pending, request, response
    //							The root type of the item whos notes are being edited.
    //	ItemID:				Long unique ID of the item.

    var strMode = new String();

    //Build the URL	
    var strURL = '../DSSWarningsLogViewer/DSSNoteDialog.aspx'
				  + '?SessionID=' + SessionID
				  + '&RequestID=' + ItemID;

    //Build the features string
    var strFeatures = 'dialogHeight:600px;'
						 + 'dialogWidth:800px;'
						 + 'resizable:yes;unadorned:no;'
						 + 'status:no;help:no;';

    //Launch the editor
    
    var ret = window.showModalDialog(strURL, '', strFeatures);
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    if (ret != null) return ret;

}

//===========================================================================================
function SelectNoteType(SessionID) {

    //Show the note type picker, from which the user selects a note type.
    //Returns: | - delimited string as follows:
    //		notetypeid=xxx|tableid=123|description=abc 
    // or an empty string if the user canceled.

    var strFeatures = 'dialogHeight:400px;'
				 		 + 'dialogWidth:600px;'
				 		 + 'resizable:yes;'
				 		 + 'status:no;help:no;';

    // 26Mar04 ATW PRV uses this as well, so added climbing path to link - should work from both modules
    var strURL = '../WorkListV10/NoteTypePicker.aspx'
				  + '?SessionID=' + SessionID;

    var strReturn = window.showModalDialog(strURL, '', strFeatures);
    if (strReturn == 'logoutFromActivityTimeout') {
        strReturn = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if(strReturn) return strReturn;

}

//===========================================================================================
function SelectProblem() {

    //Show the problem picker and allow the user to select a problem.
    //Returns a string as follows:	
    //
    //	<ProblemText>,<ProblemID>
    //
    //	OR
    //
    //	'cancel'
    //
    //	If the user cancels.

    var strURL = '../../OrderCataloguePicker/OrderCataloguePickerWrapper.aspx'
				  + '?SessionID=' + document.body.getAttribute('sid')
				  + '&Description=Treatment Reasons'
				  + '&NoBasket=true';

    var strReturn = window.showModalDialog(strURL, '<root></root>', PROBLEMPICKER_FEATURES);
    if (strReturn == 'logoutFromActivityTimeout') {
        strReturn = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (strReturn == undefined)
    { strReturn = 'cancel'; }

    return strReturn;
}

//===========================================================================================

function ShowSuspensionDetailsDialog(SessionID, colItems) {

    //Determine the size to show the task picker in.
    var intWidth = 1000;
    var intHeight = 650;

    var strFeatures = 'dialogHeight:' + intHeight + 'px;'
						 + 'dialogWidth:' + intWidth + 'px;'
						 + 'resizable:no;status:no;help:no;';

    //  Save the request xml in session state to be picked up by the dialog
    //  Create the XML
    var strItem_XML = '<root>';
    for (i = 0; i < colItems.length; i++) {
        strItem_XML += CreateOrderEntryItemXML(colItems[i]) + '</item>';
    }
    strItem_XML += '</root>';

    //  Now save it
    var strURL = '../OrderEntry/SuspendPrescriptionSaver.aspx?SessionID=' + SessionID + '&Mode=savesuspendinfo';
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", strURL, false);               										//false = syncronous                              
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send(strItem_XML);

    //Show the suspension dialog
    var strURL = '../OrderEntry/SuspendPrescriptionModal.aspx?SessionID=' + SessionID;
    var strSuspensionInfo_XML = window.showModalDialog(strURL, colItems, strFeatures);
    if (strSuspensionInfo_XML == 'logoutFromActivityTimeout') {
        strSuspensionInfo_XML = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if(strSuspensionInfo_XML) return strSuspensionInfo_XML;
}

//===========================================================================================

function CheckOrderingFrequency(SessionID, strItemsXML) {

    //  Used to check that the current order is not being re-ordered withing the OrderingFrequency timespan (held on the
    //  RequestType)
    //
    //  Inputs:
    //		strItemsXML:  root node with <item> child elements.  This could be manually generated (when selecting items) or
    //					  be ther result of CollateDataFromForms() (when committing)
    //						<root/save>
    //							<item ocstype="request" ocstypeid="xxx" description=""/>
    //						</root/save>
    //
    //	Return value:	Boolean
    //		True:  There are no requests within the OrderingFrequequency period
    //		False: There is at least one request witin the OrderFrequencyPeriod
    // 

    var strMsg;
    var strReturn;
    var strResponseXML;

    var strURL = '../OrderEntry/OrderingFrequencyCheck.aspx'
				  + '?SessionID=' + SessionID;

    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", strURL, false);               										//false = syncronous                              
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send(strItemsXML);

    //  Check the response to see if any items have failed the test
    strResponseXML = objHTTPRequest.responseText;

    if (strResponseXML != '') {
        var xmlDOM = new ActiveXObject("MSXML2.DOMDocument");
        xmlDOM.loadXML(strResponseXML);
        if (xmlDOM.parseError.errorCode == 0) {

            strMsg = '';

            var xmlItems = xmlDOM.documentElement.childNodes;
            for (var x = 0; x < xmlItems.length; x++) {
                var xmlItem = xmlItems.item(x);

                //Now all returned items will have wwarnings
                //if (xmlItem.getAttribute("status") == "errors") {
                strMsg += "<b>" + xmlItem.getAttribute("description") + "</b>\n";
                var xmlErrors = xmlItem.selectNodes("result");
                for (var y = 0; y < xmlErrors.length; y++) {
                    var xmlError = xmlErrors.item(y);
                    switch (xmlError.getAttribute("type")) {
                        case "request":
                            strMsg += xmlError.getAttribute("description") + "  [last requested " + xmlError.getAttribute("date") + "]\n";
                            break;

                        case "response":
                            strMsg += xmlError.getAttribute("description") + "  [last response " + xmlError.getAttribute("date") + "]\n";
                            break;
                    }
                }
                strMsg += "\n";
                //}
            }

            if (strMsg != "") {
                strMsg = "The following items have already been ordered or have current responses\n\n" +
						 strMsg + "\nContinue?";

                strReturn = MessageBox('Warning', strMsg, 'yesno', '');
                switch (strReturn) {
                    case 'y':
                        return true;
                        break;
                    case 'n':
                        return false;
                        break;
                }
            }
            else {
                //  It has validated OK - there are no ordering frequency conflicts
                return true;
            }
        }
        else {
            //  The XML Returned is invalid
            MessageBox('Errors', 'Invalid XML Returned from server', 'ok', 'dialogHeight:200px;dialogWidth:300px;');
            return false;
        }
    } else {
        return true;
    }
}
//===========================================================================================
function StopOrder(SessionID, OrdersXML, DispensaryMode, strMode) {
    // Displays selection dialog for each item chosen from the worklist
    // allowing the user to choose which items to stop/cancel
    // Resulting items are then passed through to the normal order entry routines
    var strReturn;
    var strURL;

    // first save the data into session for picking up later
    SessionAttributeSet(SessionID, "OrderEntry/StopOrders", OrdersXML);
    strURL = '../OrderEntry/StopAndAmendModal.aspx'
	  	    + '?SessionID=' + SessionID
			+ '&Action=' + strMode;

    strReturn = window.showModalDialog(strURL, '', OrderEntryFeatures());
    //strReturn = window.showModalDialog(strURL, '', 'dialogHeight:800px;dialogWidth:1000px;resizable:yes;');
    if (strReturn == 'logoutFromActivityTimeout') {
        strReturn = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    //13May10 JMei F0086322 After close button on the right top corner or cancel button is clicked from Amend Item(s), refresh the page
    if (strReturn == "cancel" || strReturn == undefined) {
        strURL = GetSharedScriptsURL() + "Locking.aspx?SessionID=" + SessionID + "&action=unlock&ObjectType=request";
        m_objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
        m_objHTTPRequest.open("GET", strURL, false);
        m_objHTTPRequest.send();
        void RAISE_RequestChanged();
        void Refresh();
    }

    return strReturn;
}


//===========================================================================================
function SessionAttributeSet(lngSessionID, strAttribute, strValue) {
    //  Save session setting
    var strURL = '../sharedscripts/SessionAttribute.aspx'
				  + '?SessionID=' + lngSessionID
				  + '&Mode=set'
				  + '&Attribute=' + strAttribute;

    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", strURL, false); //false = syncronous                              
    objHTTPRequest.send(strValue);
    return objHTTPRequest.responseText;
}
//===========================================================================================
function SessionAttributeGet(lngSessionID, strAttribute) {

    //  Get session setting
    var strURL = '../sharedscripts/SessionAttribute.aspx'
				  + '?SessionID=' + lngSessionID
				  + '&Mode=get'
				  + '&Attribute=' + strAttribute;

    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", strURL, false); //false = syncronous                              
    objHTTPRequest.send('');
    return objHTTPRequest.responseText;
}

//===========================================================================================
function UsingV11(SessionID) {
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    var strURL = '../sharedscripts/SettingRead.aspx'
			  + '?SessionID=' + SessionID
			  + '&System=ICW'
			  + '&Section=OrderEntry'
			  + '&Key=UseV11';
    var blnUseV11 = false;

    objHTTPRequest.open("POST", strURL, false); //false = syncronous                              
    objHTTPRequest.send("");
    if (objHTTPRequest.responseText.toLowerCase() == "true") {
        blnUseV11 = true;
    }

    return blnUseV11;
}

function GetOrderDescription(description, contentsAreOptions) {
    if (!contentsAreOptions) {
        return description;
    }

    return description + ' (Multi route)';
}
