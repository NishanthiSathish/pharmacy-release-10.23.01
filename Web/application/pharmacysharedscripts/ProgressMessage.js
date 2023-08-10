var progressMsgTimeoutID = null;

function SetupProgressMsg()
{
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(ShowProgressMsg);
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest  (HideProgressMsg);   
}

// Can force Progress message on if call this method without parameters
function ShowProgressMsg(sender, e) 
{
    var divUpdateProgress = $('div[id$="divUpdateProgress"]');
    divUpdateProgress.show();
    if (sender == undefined)
        $('div[id$="divUpdateProgress"] table').show(); // 27Jul15 XN Added allowing forcing it to be on
    else if (progressMsgTimeoutID == null)
        progressMsgTimeoutID = window.setTimeout(function () { $('div[id$="divUpdateProgress"] table').show(); }, 1500);
        //progressMsgTimeoutID = window.setTimeout(function() { $('div[id$="divUpdateProgress"] table').show(); }, 2000);  19Sep14 XN dropped to 1.5 secs
}

function HideProgressMsg(sender, e) 
{
    if (progressMsgTimeoutID != null) {
        clearTimeout(progressMsgTimeoutID);
        progressMsgTimeoutID = null;
    }

    var divUpdateProgress = $('div[id$="divUpdateProgress"]');
    divUpdateProgress.hide();
    $('table', divUpdateProgress).hide();
}