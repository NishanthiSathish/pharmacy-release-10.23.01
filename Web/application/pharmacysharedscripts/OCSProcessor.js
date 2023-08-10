/*

OCSProcessor.js

Web service used to perform order comms processes like 
    set request status notes
    get OCS action data
    Save episode to state
    Save OCS cancel action to state

Usage:
To set the PNAuthorised state, using SetStateFullProcess (from client side)
    <script language="javascript" type="text/javascript" src="../pharmacysharedscripts/OCSProcessor.js" defer></script>
    :
    var noteTypeID = button.attr('notetypeid');
    var noteTypeID = row.attr('requesttypeid');
    var requestIDs = new Array(parseInt(row.attr('requestID'));
    SetStatusNoteState(sessionID, noteTypeID, requestTypeID, requestIDs, true);
*/

// called when status button is clicked
// Changes the state of the note type
// Returns ture if state has been changed
function SetStatusNoteState(sessionID, noteTypeID, requestTypeID, requestIDs, enable, returnData)
{
    var ok = false;
    
    // Call web service
    var parameters =
    {
        sessionID       : parseInt(sessionID), 
        noteTypeID      : parseInt(noteTypeID),
        requestTypeID   : parseInt(requestTypeID),
        requestIDs      : requestIDs,
        enable          : enable,
        returnType      : returnData == undefined ? 'None' : returnData.returnType,
        returnData      : returnData == undefined ? null   : returnData.returnData
    };
    var result = PostServerMessage("../pharmacysharedscripts/OCSProcessor.asmx/SetStatusNoteState", JSON.stringify(parameters));
    
    if (result != undefined && result.d != "") 
    {
        var data = result.d;
        
        // If message to display then show
        if (data.errorMsg != null && data.errorMsg != '')
            alert(JavaStringUnescape(data.errorMsg));
         
        // If javascript to run (calls this method if java script returns data)
        if (data.postOperation != null && data.postOperation != '')
        {
            var returnData = eval (data.postOperation);
            if (returnData != null)
                ok = SetStatusNoteState(sessionID, noteTypeID, requestTypeID, requestIDs, enable, returnData);
        }                

        // If all okay return true
        if (data.resultType == "Passed" || data.resultType == "NoChange")
            ok = true;            
    }
    
    return ok;
}        

// Called by PharamcyStateProcessor when state needs order comms form details
function GetNoteData(sessionID, tableName)
{
    var icwWin  = ICWWindow();
    var v11Mask = undefined;
    if (icwWin != null)
    {
        v11Mask = icwWin.document.getElementById('v11Mask');
        v11Mask.style.display = 'block';
        v11Mask.style.top     = 0;
    }

    // If no v11 location defined the get
    if (typeof(V11Location) == undefined || typeof(V11Location) == 'undefined')
    {
        var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
        var strURL = '../sharedscripts/AppSettingRead.aspx?SessionID=' + sessionID + '&Setting=ICW_V11Location';
        objHTTPRequest.open("POST", strURL, false);
        objHTTPRequest.send("");
        V11Location = objHTTPRequest.responseText;
    }

    // Call order comms from
    var NoteData = window.showModalDialog(V11Location + '/OrderComms/Views/OrderEntry/AttachedNoteDataEntry.aspx?sessionID=' + sessionID + '&TableName=' + tableName, '', OrderEntryFeaturesV11());
    if (NoteData == 'logoutFromActivityTimeout') {
        NoteData = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (v11Mask != undefined)
        v11Mask.style.display = 'none';

    if (NoteData != undefined && NoteData != 'cancel')
    {
        // Return data
        return {
                 returnType : 'NoteTypeData',
                 returnData : NoteData 
               };
    }
    else
        return null;
}

// Called by PharamcyStateProcessor when PreCondition question needs confirmation
function NotePreConditionConfirm(msg)
{
    msg = JavaStringUnescape(msg);
    if (confirm(msg))
    {
        return  {
                    returnType : 'PreconditionResult',
                    returnData : null 
                };
    }
    else
        return null;
}

// Get the OCS action data that can be passed to OCSAction for the request
// returns an object containing two parameter {xmlItem, xmlType} to be passed to OCSAction
function GetOCSActionDataForRequest(sessionId, requestId) {
    //02Sep16   Rams    161716 - aMM worklist - Double clicking on a Shift Section Header errors
    if (requestId == null || requestId == undefined || isNaN(requestId))  {
        return undefined;
    }

    var parameters = 
    {
        sessionId: parseInt(sessionId),
        requestId: parseInt(requestId)
    }
    var result = PostServerMessage("../pharmacysharedscripts/OCSProcessor.asmx/GetOCSActionDataForRequest", JSON.stringify(parameters));    

    if (result != undefined && result.d != "") 
    {
        var xmlDoc = new ActiveXObject("MSXML2.DOMDocument");
        xmlDoc.loadXML(result.d);
        return {
                 xmlItem: xmlDoc.childNodes[0].childNodes[0],
                 xmlType: xmlDoc.childNodes[0].childNodes[1]          
               };
    } 
    else
        return undefined;
}

// Will save the episode and entity id to the state table
// Used when sending RAISE_EpisodeSelected event
function SaveEpisodeToState(sessionId, entityId, episodeId) {

    var parameters =
    {
        sessionId  : parseInt(sessionId),
        entityId   : parseInt(entityId),
        episodeId  : parseInt(episodeId)
    }
    PostServerMessage("../pharmacysharedscripts/OCSProcessor.asmx/SaveEpisodeToState", JSON.stringify(parameters));
}

// Will save OrderEntry/StopOrders, and OrderEntry/OrdersXML to state so to cancel a request after calling this 
// method all you need to do is call ../OrderEntry/StopItemsModal.aspx?SessionID={0}&Action=load&DispensaryMode=0 to ask user to stop the items
// requestId    - RequestId to cancel
// requestType  - Type of request RequestType tale e.g. PNRegimen
// Currently only works for RequestType's but could be used with NoteType
function SaveCanelOrderToState(sessionId, requestId, requestType)
{
    var parameters =
    {
        sessionId:   parseInt(sessionId),
        requestId:   parseInt(requestId),
        requestType: requestType
    }
    PostServerMessage("../pharmacysharedscripts/OCSProcessor.asmx/SaveCanelOrderToState", JSON.stringify(parameters));
}