var m_intStatusTimer = 0;																//Timer for StatusMessage

function StatusMessage(strMsg, intTop, intLeft, timerMilliseconds){

//displays a message in the status panel.  Use blank string to hide the message, 
//OR set timerMilliseconds to be the number of milliseconds for which the message should appear.
//intTop, intLeft, timerMilliseconds are all optional and can be ignored/set to null if desired.

	if (intTop == undefined) intTop = null;
	if (intLeft == undefined) intLeft = null;
	if (document.getElementById('statusPanel') != 'undefined' && document.getElementById('statusPanel') != undefined) {
	    statusPanel.all['sp_text'].innerText = strMsg;
	    if (strMsg != '') {
	        if (intTop == null) intTop = (document.body.offsetHeight / 2) - (statusPanel.offsetHeight / 2);
	        if (intLeft == null) intLeft = (document.body.offsetWidth / 2) - (statusPanel.offsetWidth / 3);
	        statusPanel.style.top = intTop;
	        statusPanel.style.left = intLeft;
	        statusPanel.style.visibility = 'visible';
	        statusPanel.all['sp_img'].style.display = 'block';
	    }
	    else {
	        statusPanel.style.visibility = 'hidden';
	        statusPanel.all['sp_img'].style.display = 'none';
	    }
	}
    if (timerMilliseconds != undefined && Number(timerMilliseconds) > 0){
		m_intStatusTimer = window.setTimeout("StatusMessage('')", Number(timerMilliseconds));
	}
	else {
	//new message, clear any existing timer
		window.clearTimeout(m_intStatusTimer);
	}
}


