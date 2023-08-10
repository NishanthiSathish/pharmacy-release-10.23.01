function ShowTimeOutPopup(sessionId, secondTimeOutValueInSeconds, v10Location) {
    var strURL = v10Location + '/application/ICW/SessionTimeOutModal.aspx'
        + '?SessionID=' + sessionId
        + '&secondSessionTimeOut=' + secondTimeOutValueInSeconds;
    //alert(strURL);
    var result = window.showModalDialog(strURL, '', 'dialogHeight:400px;dialogWidth:600px;resizable:no;unadorned:no;status:no;help:no;');
    //alert(result);
    if (result == null || result == 'logoutFromActivityTimeout') {
        inactivityTimeout_exit();
    }
}

function inactivityTimeout_exit() {
    try {
       //alert("inside inactivityTimeout_exit");
        window.returnValue = 'logoutFromActivityTimeout';
        window.close();
        window.parent.close();
        // Depending on where you are in the HAP the script may need little hand to help find Exit           
        window.parent.ICWWindow().Exit();

    }
    catch (err) {
        var txt = "There was an error on this page.\n\n";
        txt += "Error description: " + err.message + "\n\n";
        txt += "Click OK to continue.\n\n";
        alert(txt);
    }
}

function windowModal_SessionTimeOut(sessionId, modalUrl, frameName) {
    //setInterval(CallTimeOutFunction, 60000);

    function CallTimeOutFunction() {
        if (sessionId > 0) {
            var desktopUrl = modalUrl + "?sessionId=" + sessionId
            if (frameName.indexOf("|") > -1) {
                var sourcePage = frameName.substring(frameName.indexOf('|') + 1, frameName.length);
                //alert("sourcePage:" + sourcePage);
                frameName = frameName.substring(0, frameName.indexOf('|'));
            }

            var frameElement = document.getElementById(frameName);
            if (frameElement)
                frameElement.src = desktopUrl;
        }
    }
}


function windowModal_CheckSession(sessionId, modalUrl1, frameName) {
    setInterval(CallSessionExistsFunction, 62000);

    function CallSessionExistsFunction() {
        if (sessionId > 0) {
            var desktopUrl = modalUrl1 + "?sessionId=" + sessionId
            //alert("desktopUrl:" + desktopUrl);
            if (frameName.indexOf("|") > -1) {
                var sourcePage = frameName.substring(frameName.indexOf('|') + 1, frameName.length);
                //alert("sourcePage:" + sourcePage);
                frameName = frameName.substring(0, frameName.indexOf('|'));
                //alert("frameName:" + frameName);
            }

            var frameElement = document.getElementById(frameName);
            if (frameElement)
                frameElement.src = desktopUrl;
        }
    }
}