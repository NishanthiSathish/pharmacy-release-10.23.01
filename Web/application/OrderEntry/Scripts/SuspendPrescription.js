//  Get RequestItems xmlNodeList reference - this is a reference to the node list containing the 
//  request items to be suspended - this can be used to check the "when required" status?
var colItems = window.dialogArguments;

function InitialisePage() {
    //05Feb13 Rams 30951 - Patient Locking - No locking occurs when suspending the same prescription at the same time
    if (document.body.getAttribute('IsRequestLocked') == 'true') {
        return;
    }
    var suspendTimeObject = new Date();
    
	var objFocus = document.getElementById("cmdOK");
	if (objFocus != null) {
		objFocus.focus();
	}

	disableRemainSuspended();
	
	var ctrl = document.getElementById("suspend_from_date");
	var objDateControl = new DateControl(ctrl);
	//	objDateControl.SetDate(new Date());
	if (document.body.getAttribute("FormattedSuspendOn") != '' && document.body.getAttribute("IsSingleDose").toLowerCase() != "true")
	{
	    objDateControl.SetDate(new Date(document.body.getAttribute("FormattedSuspendOn")));
	    document.getElementById("suspend_from").checked = true;

	    if (document.body.getAttribute("FormattedSuspendOnTime") != '') {
	        document.getElementById("suspend_from_time").value = document.body.getAttribute("FormattedSuspendOnTime");
	    } 
	    
	    enableSuspendFrom();
	}
	else
	{
	    objDateControl.SetDate(new Date());
	}
	
	if(document.body.getAttribute("RemainSuspendedUntil") == 'true')
	{
	    ctrl = document.getElementById("unsuspend_from");
	    ctrl.checked = true;
	    ctrl = document.getElementById("unsuspend_from_date");
	    objDateControl = new DateControl(ctrl);

	    if (document.body.getAttribute("FormattedUnsuspendOn") != '') {
	        objDateControl.SetDate(new Date(document.body.getAttribute("FormattedUnSuspendOn")));
	        document.getElementById("unsuspend_from_time").value = document.body.getAttribute("FormattedUnsuspendOnTime");
	    }
	    else 
	    {
	        objDateControl.SetDate(new Date());
	    }
	    
	    enableUnsuspendFrom();
	}   
	else if(document.body.getAttribute("RemainUnSuspendedForDoses") == 'true')
	{
	    ctrl = document.getElementById("unsuspend_by_dose");
        ctrl.checked = true;
	    document.getElementById("unsuspend_doses").value = document.body.getAttribute("UnSuspendAfterDose");
	    enableUnsuspendDoses();
    }
	else
	{
        ctrl = document.getElementById("unsuspend_manual");
        ctrl.checked = true;
    }

    if (document.body.getAttribute("IsWhenRequired").toLowerCase() == "true") {
        HideDoseControls(true);
    }
}

function disableRemainSuspended() {
    var ctrl;
    ctrl = document.getElementById("unsuspend_manual");
    ctrl.disabled = true;
    ctrl = document.getElementById("unsuspend_from");
    ctrl.disabled = true;
    ctrl = document.getElementById("unsuspend_from_date");
    ctrl.disabled = true;
    ctrl.className = "DisabledField";
    ctrl = document.getElementById("unsuspend_from_time");
    ctrl.disabled = true;
    ctrl.className = "DisabledField";
    
    ctrl = document.getElementById("unsuspend_from_date_button");
    ctrl.disabled = true;
    ctrl = document.getElementById("unsuspend_by_dose");
    ctrl.disabled = true;
    ctrl = document.getElementById("unsuspend_doses");
    ctrl.disabled = true;
    ctrl.className = "DisabledField";

    ctrl = document.getElementById("suspend_from_date");
    ctrl.disabled = true;
    ctrl.className = "DisabledField";
    ctrl = document.getElementById("suspend_from_date_button");
    ctrl.disabled = true;
    ctrl = document.getElementById("suspend_from_time");
    ctrl.disabled = true;
    ctrl.className = "DisabledField";
    
    ctrl = document.getElementById('selSuspensionReason');
    if(ctrl != undefined) 
    {
        ctrl.disabled = true;
        ctrl.className = "DisabledField";
    }
    
    ctrl = document.getElementById('txtSuspensionText');
    if(ctrl != undefined)
    {
        ctrl.disabled = true;
        ctrl.className = "DisabledField";
    }
}

function enableRemainSuspended() {
    var ctrl;
    ctrl = document.getElementById("unsuspend_manual");
    ctrl.disabled = false;
    
    ctrl = document.getElementById("unsuspend_from");
    ctrl.disabled = false;
    
    ctrl = document.getElementById("unsuspend_from_date");
    ctrl.disabled = false;
    ctrl.className = "MandatoryField";
    ctrl = document.getElementById("unsuspend_from_time");
    ctrl.disabled = false;
    ctrl.className = "StandardField";
    
    ctrl = document.getElementById("unsuspend_from_date_button");
    ctrl.disabled = false;

    if (document.body.getAttribute("IsSingleDose").toLowerCase() != 'true') {
        ctrl = document.getElementById("unsuspend_by_dose");
        ctrl.disabled = false;
        ctrl = document.getElementById("unsuspend_doses");
        ctrl.disabled = false;
    }
    else {
        ctrl = document.getElementById("unsuspend_by_dose");
        ctrl.disabled = true;
        ctrl = document.getElementById("unsuspend_doses");
        ctrl.disabled = true;
    }
    
    ctrl.className = "MandatoryField";
    ctrl = document.getElementById("unsuspend_doses_button");
    ctrl.disabled = false;
    
    if(document.getElementById("unsuspend_manual").checked)
    {
        disableUnsuspendDoses();
        disableUnsuspendFrom();
    }
    else if(document.getElementById("unsuspend_from").checked)
    {
        disableUnsuspendDoses();
    }
    else
    {
        disableUnsuspendFrom();
    }
    
    
    ctrl = document.getElementById('selSuspensionReason');
    if(ctrl != undefined)
    {
        ctrl.disabled = false;
        ctrl.className = (ctrl.getAttribute("mandatory") == "1" ? 'MandatoryField': 'StandardField') ;
    }
    
    ctrl = document.getElementById('txtSuspensionText');
    if(ctrl != undefined)
    {
        ctrl.disabled = false;
        ctrl.className = (ctrl.getAttribute("mandatory") == "1" ? 'MandatoryField': 'StandardField') ;
    }
}

function enableUnsuspendDoses() {
	disableUnsuspendFrom();

	var ctrl;

    ctrl = document.getElementById("unsuspend_doses");
	ctrl.disabled = false;
	ctrl.className = "MandatoryField";
}

function showSuspendInfo() {
    document.getElementById("warnings").style.visibility = "hidden";
	document.getElementById("suspendInfo").style.visibility = "visible";
	document.getElementById("prescriptionDetail").style.visibility = "visible";

	if (document.body.getAttribute("IsWhenRequired").toLowerCase() == "true") {
	    HideDoseControls(true);
	}	
}

function body_onKeydown(){
	switch (window.event.keyCode) {
		case 27:  //Escape key
			void CloseForm(false);
			break;
	}
}

function disableUnsuspendFrom() {
	document.getElementById("unsuspend_from_date").disabled = true;
	document.getElementById("unsuspend_from_date").className = "DisabledField";
	document.getElementById("unsuspend_from_date_button").disabled = true;
	document.getElementById("unsuspend_from_time").disabled = true;
	document.getElementById("unsuspend_from_time").className = "DisabledField";
}

function disableUnsuspendDoses() {
	var ctrl;
	ctrl = document.getElementById("unsuspend_doses");
	ctrl.disabled = true;
	ctrl.className = "DisabledField";
}

function enableSuspendFrom() {
    enableRemainSuspended();
	document.getElementById("suspend_from_date").disabled = false;
	document.getElementById("suspend_from_date").className = "MandatoryField";
    document.getElementById("suspend_from_date_button").disabled = false;
    document.getElementById("suspend_from_time").disabled = false;
    document.getElementById("suspend_from_time").className = "StandardField";
}

function enableSuspendNow() {
    enableRemainSuspended();
	document.getElementById("suspend_from_date").disabled = true;
	document.getElementById("suspend_from_date").className = "DisabledField";
	document.getElementById("suspend_from_date_button").disabled = true;
	document.getElementById("suspend_from_time").disabled = true;
	document.getElementById("suspend_from_time").className = "DisabledField";
}

function enableUnsuspendManual() {
	disableUnsuspendFrom();
	disableUnsuspendDoses();
}

function enableUnsuspendFrom() {
	disableUnsuspendDoses();
	
	document.getElementById("unsuspend_from_date").disabled = false;
	document.getElementById("unsuspend_from_date").className = "MandatoryField";
	document.getElementById("unsuspend_from_date_button").disabled = false;
	document.getElementById("unsuspend_from_time").disabled = false;
	document.getElementById("unsuspend_from_time").className = "StandardField";
}

//F0088636 ST 09Jun10 Restrict character count of control to specified length
function limitText(objCtrl, length) {
    if (objCtrl.value.length > length) 
    {
        objCtrl.value = objCtrl.value.substring(0, length);
        return false;
    }
    else {
        return true;
    }
}

function donotSuspendClick() {
	//disableUnsuspendFrom();
	//disableUnsuspendDoses();
    disableRemainSuspended();
}

function validateInput() {
    var strReturn;
	var strMessage = '';
	var objDateControl;
	var objSel;

	var dtFrom;
	var dtTo;
    var isBeingUnsuspended;

	//  Work out what has been entered
	
	//  From details
	strReturn = '<suspendinfo ';
	var ctrl = document.getElementById("donotsuspend");
	//
	if(ctrl.checked)
	{
	    strReturn += 'unsuspend_now="now" ';
	    isBeingUnsuspended = true;
	}

	if (document.getElementById("suspend_now").checked) {
		strReturn += 'from_type="now" ';
		dtFrom = new Date();

        // Immediate suspension so get the current date and time
	    strReturn += 'from_date="' + DateFromJSDate(dtFrom, "-") + " " + TimeFromJSDate(dtFrom) + '" ';
	} 
	else {
	    //29260 Dont check the dates if we are unsuspending or amending
	    if (!ctrl.checked)
        {
		    strReturn += 'from_type="from" ';
		    ctrl = document.getElementById("suspend_from_date");
		    objDateControl = new DateControl(ctrl);

		    if (objDateControl.ContainsValidDate()) {
		        if (HaveSuspendDetailsChanged() && IsSuspensionInThePast()) {
		            strMessage += 'The suspend date and time must be in the future<br/>';
		        }
		        
		        dtFrom = objDateControl.GetDate();
		        //  Makesure dtFrom represents midnight
		        dtFrom.setHours(0, 0, 0, 0);

		        var dtNow = new Date();
		        dtNow.setHours(0, 0, 0, 0);

//		        if (DateDiff(dtNow, dtFrom, 'd', true) < 0) {
//		            strMessage += 'The suspend date must be in the future<br/>';
//		        }

		        strReturn += 'from_date="' + Date2ddmmccyy(dtFrom) + ' ' + GetSuspendTime() + '" ';
		    }
		    else if (objDateControl.IsBlank())
		    {
		        strMessage += 'A suspend from date MUST be supplied<br/>';
		    }
		    else
		    {
		        strMessage += 'Incorrect suspend date format. It should be in the format: dd/mm/yyyy<br/>'; 
		    }
        }
        
	}
    
	//  To details
	ctrl = document.getElementById("unsuspend_manual");
	if (ctrl.checked)
	{
		strReturn += 'to_type="manual" ';
	} 
	else 
	{
		ctrl = document.getElementById("unsuspend_from");
		if (ctrl.checked)
		{
			strReturn += 'to_type="to" ';
		
			ctrl = document.getElementById("unsuspend_from_date");
			objDateControl = new DateControl(ctrl);

			if (objDateControl.ContainsValidDate())
			{
			    dtTo = objDateControl.GetDate();
			    strReturn += 'to_date="' + DateFromJSDate(dtTo, "-") + ' ' + GetUnsuspendTime() + '" ';

			    if (IsUnsuspendDateLaterThanSuspendDate() && !isBeingUnsuspended) {
			        strMessage += 'The unsuspend date and time must be later than the suspend date and time<br/>'; 
			    }

//                if(dtFrom != null && DateDiff(dtFrom, dtTo, 'd', true) <= 0)
//				{
//					strMessage += 'The unsuspend date must be later than the suspend date<br/>'; 
//				}
			}
			else if (objDateControl.IsBlank())
			{
			    strMessage += 'An unsuspend from date MUST be supplied<br/>';
			}
			else
			{
			    strMessage += 'Incorrect unsuspend date format. It should be in the format: dd/mm/yyyy<br/>';
			}
		}
		else
		{
			strReturn += 'to_type="doses" ';
			ctrl = document.getElementById("unsuspend_doses");
			var iDoses = ctrl.value;

			if (iDoses == '') {
				strMessage += 'Doses MUST be supplied'; 
			} else if (iDoses > 0) {
				strReturn += 'to_doses="' + iDoses + '" ';
			} else {
				strMessage += 'Doses MUST be greater than 0'; 
			} 
		}
	}

	if (document.getElementById("txtSuspensionText") != undefined)
	{
	    if (document.getElementById("txtSuspensionText").getAttribute("mandatory") == "1" && document.getElementById("txtSuspensionText").value == "") {
	        strMessage += 'Suspension text must be supplied<br>';
	    }
	    else {
	        strReturn += 'reason_text="' + XMLEscape(document.getElementById("txtSuspensionText").value) + '" ';
	    }
    }

    objSel = document.getElementById("selSuspensionReason");
    if (objSel != undefined && objSel != null) {
        if (objSel.getAttribute("mandatory") == "1" && objSel.options[objSel.selectedIndex].innerText == "") {
            strMessage += 'Suspension reason must be selected<br>';
        }
        else {
            strReturn += 'reason_lookupid="' + objSel.options[objSel.selectedIndex].getAttribute("dbid") + '" ';
            strReturn += 'reason_lookuptext="' + objSel.options[objSel.selectedIndex].innerText + '" ';
        }
    }

    if (document.getElementById("suspend_now").checked) {
        var noLongerRequiredAdmins = GetAdminsNoLongerRequired(window.parent.requestId, document.body.getAttribute("sid"));
        if (noLongerRequiredAdmins != null && noLongerRequiredAdmins != "0") {
            strReturn += 'no_longer_required_admins="' + noLongerRequiredAdmins + '" ';
        }
    }

    if (strMessage != '') {
		MessageBox('Warnings', strMessage, "Ok");

		return '';
	} else {
		strReturn += '/>';
		return strReturn;
	}
}

function GetAdminsNoLongerRequired(requestId, sessionId) {
    var result;
    $.ajax({
        type: "GET",
        url: V11Location(sessionId) + "/webapi/suspension/outstandingadminrequests/" + requestId,
        contentType: "application/json; charset=UTF-8",
        async: false,
        success: function (msg) {
                result = msg;
        },
        error: function (err, text, type) {
                var error = $.parseJSON(err.responseText);
        }
    });

    var outstandingRequests = JSON.parse(result)

    if (outstandingRequests.length <= 0) {
        return "";
    }

    var pageUrl = V11Location(sessionId) + "/Prescribing/Views/SelectNoLongerRequiredAdmins.aspx?SessionId=" + sessionId + "&requestId=" + requestId;
    var strFeatures = 'dialogHeight:600px;'
					+ 'dialogWidth:700px;'
					+ 'resizable:no;unadorned:no;'
					+ 'status:no;help:no;';
    
    var ret = window.showModalDialog(pageUrl, '', strFeatures);
    if (ret == 'logoutFromActivityTimeout') {
        window.returnValue = 'logoutFromActivityTimeout';
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    return ret;

}

function CloseForm(blnOkClicked) {
	// Called when the OK or Cancel buttons are clicked on the form
	// blnOKClicked:		true if the OK button was clicked, false if the Cancel button was clicked.

    var strReturn;
	
	if (blnOkClicked) {
	    //  Validate input
	    strReturn = validateInput();
	}
	else {
		//Cancel clicked; just return an empty string
		strReturn = 'cancelled';	
	} 

	if (strReturn != '') {
		window.parent.returnValue = strReturn;
		window.parent.close();
	}
}

function HideDoseControls(controlsShouldBeHidden) {
    if (controlsShouldBeHidden) {
        document.getElementById("suspendDoses").style.visibility = "hidden";
    }
}

function GetSuspendTime() {
    var suspendTime = document.getElementById("suspend_from_time").value;

    if (suspendTime != "" && suspendTime != null) {
        return suspendTime;
    }
    else 
    {
        return "00:00";
    }
}

function GetUnsuspendTime() {
    var unsuspendTime = document.getElementById("unsuspend_from_time").value;

    if (unsuspendTime != "" && unsuspendTime != null) {
        return unsuspendTime;
    }
    else {
        return "00:00";
    }
}

function HaveSuspendDetailsChanged() {
    var originalSuspendDate = new Date(document.body.getAttribute("FormattedSuspendOn"));
    var currentSuspendDate = ddmmccyy2Date(document.getElementById("suspend_from_date").value);
    var currentSuspendTime = document.getElementById("suspend_from_time").value;
    var originalSuspendTime = document.body.getAttribute("FormattedSuspendOnTime");

    if (DateDiff(currentSuspendDate, originalSuspendDate, 'd', true) != 0 || currentSuspendTime != originalSuspendTime) {
        return true;
    }

    return false;
}

function IsSuspensionInThePast() {
    var suspensionDate = ddmmccyy2Date(document.getElementById("suspend_from_date").value);
    var suspensionTime = GetSuspendTime();
    var dateNow = new Date();

    suspensionDate.setHours(suspensionTime.substr(0, 2));
    suspensionDate.setMinutes(suspensionTime.substr(3, 2));

    if (suspensionDate < dateNow) {
        return true;
    }

    return false;
}

function IsUnsuspendDateLaterThanSuspendDate() {
    var suspensionDate = ddmmccyy2Date(document.getElementById("suspend_from_date").value);
    var unsuspendDate = ddmmccyy2Date(document.getElementById("unsuspend_from_date").value);
    var suspensionTime = GetSuspendTime();
    var unsuspendTime = GetUnsuspendTime();

    suspensionDate.setHours(suspensionTime.substr(0, 2));
    suspensionDate.setMinutes(suspensionTime.substr(3, 2));

    unsuspendDate.setHours(unsuspendTime.substr(0, 2));
    unsuspendDate.setMinutes(unsuspendTime.substr(3, 2));

    // if the unsuspend date and time is earlier than the suspend date and time then return true
    // so that the user is alerted to there being an error.
    if (Date.parse(unsuspendDate.toUTCString()) <= Date.parse(suspensionDate.toUTCString())) {
        return true;
    }

    return false;   
}

function V11Location(SessionID) {
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    var strURL = '../sharedscripts/AppSettingRead.aspx'
			  + '?SessionID=' + SessionID
			  + '&Setting=ICW_V11Location';
    var v11Location = '';

    objHTTPRequest.open("POST", strURL, false); //false = syncronous                              
    objHTTPRequest.send("");
    v11Location = objHTTPRequest.responseText;

    return v11Location;
}
