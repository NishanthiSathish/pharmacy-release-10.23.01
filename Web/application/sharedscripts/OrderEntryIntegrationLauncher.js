// REQUIRED JS FILES TO BE INCLUDED
//  sharedscripts/icw.js
//  sharedscripts/ocs/OCSShared.js
/// <reference path="icw.js" />

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//---------------------------------------------
// -- Error Handling --------------------------
//---------------------------------------------
//
//  Errors come from all over the place, the database, COM. This is a function to parse the
//  errors and make them more readable to understand common errors.
//
function MessageIsOrContains(message, check) {
    return message == check || message.indexOf(check) > -1;
}

function ParseExceptionObject(ex) {
    if (ex.Message == "There is no row at position 0.") {
        if (ex.StackTrace.indexOf("GetAmendOrder") > -1) {
            alert("Supplied GUID does not match any existing notes.");
            return;
        }
        else if (ex.StackTrace.indexOf("GetNewOrder") > -1) {
            alert("OrderTemplate not found.");
            return;
        }
    }
    else if (MessageIsOrContains(ex.Message, "Conversion failed when converting from a character string to uniqueidentifier.")) {
        if (ex.StackTrace.indexOf("GetAmendOrder") > -1) {
            alert("Internal NoteGUID appears to not in the correct format.");
            return;
        }
        else if (ex.StackTrace.indexOf("GetNewOrder") > -1) {
            alert("Supplied OrderTemplateGUID was not in the correct format.");
            return;
        } else {
            alert("Supplied GUID in the LegalStatusVID JSON was not in the correct format.");
            return;
        }
    }
    else if (ex.Message.indexOf("Invalid Session ID") > -1) {
        alert("Invalid Session ID.");
        return;
    }
    alert(ex.Message);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function LoadOrderEntry_Amend(sessionID, noteID) {
    try {
        if (sessionID == undefined)
            return;

        var xmlBlob = CreateOrderEntryXMLBlob_Amend(sessionID, noteID);
        return OrderEntry(sessionID, xmlBlob, false, "undefined", "Hide Changes", true, null, true);
    } catch (ex) {
        ParseExceptionObject(ex);
    }
}

function LoadOrderEntry_Create(sessionID, templateID) {
    try {
        if (sessionID == undefined)
            return;

        var xmlBlob = CreateOrderEntryXMLBlob_Create(sessionID, templateID);
        return OrderEntry(sessionID, xmlBlob, false, "undefined", "Hide Changes", true, "Save");
    } catch (ex) {
        ParseExceptionObject(ex);
    }
}

function LoadOrderEntry_View(sessionID, templateID) {
    try {
        if (sessionID == undefined)
            return;

        var xmlBlob = CreateOrderEntryXMLBlob_View(sessionID, templateID);
        return OrderEntry(sessionID, xmlBlob, false, "undefined", "Hide Changes", true);
    } catch (ex) {
        ParseExceptionObject(ex);
    }
}

function GetJSONFromAjax(url, data) {
    var result;
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/json; charset=UTF-8",
        async: false,
        data: data,
        success: function (msg) {
            result = msg;
        },
        error: function (err, text, type) {
            var error = $.parseJSON(err.responseText);
            throw (error);
        }
    });

    return $.parseJSON(result.d);
}

function GetViewOrAmendOrderJSON(sessionId, noteId) {
    var url = ICWGetICWV10Location() + "/application/sharedscripts/OrderEntryIntegration.aspx/GetAmendOrderEntryParameters";
    var data = '{"SessionID":"' + sessionId + '","NoteGUID":"' + noteId + '"}';
    return GetJSONFromAjax(url, data);
}

function GetNewOrderJSON(sessionId, guid) {
    var url = ICWGetICWV10Location() + "/application/sharedscripts/OrderEntryIntegration.aspx/GetNewOrderEntryParameters";
    var data = '{"SessionID":"' + sessionId + '","TemplateGUID":"' + guid + '"}';
    return GetJSONFromAjax(url, data);
}


function CreateOrderEntryXMLBlob_Amend(sessionId, noteID) {
    var params = GetViewOrAmendOrderJSON(sessionId, noteID);

    var xmlBlob = '<amend><item class="note" id="' + params.noteid + '" ';
    xmlBlob += 'description="' + params.description + '" detail="' + params.detail + '" tableid="' + params.tableid + '" productid="null" ocstype="note" ocstypeid="' + params.ocstypeid + '" autocommit="null"></item></amend>';

    return xmlBlob;
}

function CreateOrderEntryXMLBlob_Create(sessionId, templateID) {
    var params = GetNewOrderJSON(sessionId, templateID);

    var xmlBlob = '<batchentry><item class="template" id="' + params.ordertemplateid + '" ';
    xmlBlob += 'tableid="' + params.tableid + '" ocstype="note" ocstypeid="' + params.ocstypeid + '" ordertemplateid="' + params.ordertemplateid + '" onselectwarninglogid="-1" description="' + params.description + '" ></item></batchentry>';

    return xmlBlob;
}

function CreateOrderEntryXMLBlob_View(sessionId, noteID) {
    var params = GetViewOrAmendOrderJSON(sessionId, noteID);

    var xmlBlob = '<display><item class="note" id="' + params.noteid + '" ';
    xmlBlob += 'description="' + params.description + '" detail="' + params.detail + '" tableid="' + params.tableid + '" productid="null" ocstype="note" ocstypeid="' + params.ocstypeid + '" autocommit="null"></item>'
    /*+ '<StatusNoteFilter action="exclude"> <notetype description=""/></StatusNoteFilter>'*/
               + '</display>';

    return xmlBlob;
}