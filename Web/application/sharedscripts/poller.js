//
// poller.js - Generic polling mechanism
//
// Works with specially constructed Helper.ashx pages
// These pages are expected to return a JSON object which has as a minimum a "proceed" attribute containing "yes" or "no"
// e.g. { "proceed" : "yes" }
//
// Version  By  Date
//  1.0     cjm 27-02-2012
//
// The clien Javascript will supply titles for the display plus an error message, and optionally
// methods to be invoked on success or timeout.
// The success method is passed the JSON object returned which may contain extra attributes etc..
//
// javascript example
//--------------------
// var url = "http://localhost/ICWWestern/application/ChairScheduling/ChairSchedulingHelper.ashx?method=pollingWait";
// var data = "test data";

// poller.SetDisplayInfo("Main Title", "Error Title", "Error Message xxxxxxxxxxxxxxxxxxxxxxx");
// poller.Wait(url, "testParam=" + encodeURIComponent(123456789), doCallback, doTimeout) || {};
//
// function doCallback(result) {
//    alert("callback " + result.proceed + "  " + result.test);
// }
//
// function doTimeout() {
//    alert("timeoutxxxxyyyyyy");
// }
//
// Helper example
//----------------
//    private const string MethodParameter = "method";
//    private const string PollingWaitMethod = "pollingWait";
//
//    public void ProcessRequest(HttpContext context)
//    {
//        string result = string.Empty;
//
//        context.Response.ContentType = "application/json; charset=utf-8";
//
//        // Check a method parameter has been supplied
//        string method = context.Request.QueryString[MethodParameter] ?? "";
//        if (!string.IsNullOrEmpty(method))
//        {
//            // Check the value of the method parameter is "polling"
//            if (method.Equals(PollingWaitMethod))
//            {
//                // Using the parameters supplied check whether the "proceed" condition has been met..
//                bool proceed = true;
//
//                string p = context.Request.Params["testParam"];
//                
//                // Return a standard JSON object containing the result plus the data sent in the call
//                result = "{ \"proceed\" : \"" + (proceed ? "yes" : "no") + "\" , \"testParam\" : \"" + p + "\" }";
//            }
//        }
//
//        context.Response.Write(result);
//    }

var pollerOptions = {
    "retryLimit": 10,
    "retryCount": 0,
    "delayRetry": 1000, /* 1000 = 1 second */
    "destination": "",
    "fnSuccessCallback": null,
    "fnTimeoutCallback": null,
    "title": "",
    "errorTitle": "",
    "errorMessage": ""
}

var poller = {

    // Use this to set the display titles and error message
    SetDisplayInfo: function(title, errorTitle, errorMessage) {
        pollerOptions.title = title;
        pollerOptions.errorTitle = errorTitle;
        pollerOptions.errorMessage = errorMessage;
    },

    // Use this to set the display titles and error message
    SetRetryOptions: function(retryLimit, delayRetry) {
        pollerOptions.retryLimit = retryLimit;
        pollerOptions.delayRetry = delayRetry;
    },

    // Send wraps up the AJAX call
    Send: function xmlhttpCall(url, data, async) {

        var xhttp = null,
			            asyncFlag = async || false,
			            response = null;

        xhttp = (window.XMLHttpRequest) ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");

        if (xhttp) {
            xhttp.onreadystatechange = function() {
                if (xhttp.readyState == 4 && xhttp.status == 200) {
                    response = xhttp.responseText;
                }
            };

            xhttp.open("POST", url, asyncFlag);
            xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhttp.send(data);

            return response;

        } else {
            return false;
        }
    },

    // Wait function to be called by clients
    Wait: function(url, data, successCallback, timeoutCallback) {
        // Set the callback to be called on success
        pollerOptions.fnSuccessCallback = successCallback;
        pollerOptions.fnTimeoutCallback = timeoutCallback;
        pollerOptions.destination = url;

        splash.setTitle(pollerOptions.title);
        splash.setErrorTitle(pollerOptions.errorTitle);
        splash.setModalError(pollerOptions.errorMessage);
        splash.openModalSplash(poller.Retry, poller.Cancel, null);

        //Make sure vars are reset
        pollerOptions.ajaxInProgress = false;
        pollerOptions.retryCount = 0;
        pollerOptions.killRequest = false;

        poller.Call(data);
    },

    Call: function(data) {
        if (pollerOptions.retryCount < pollerOptions.retryLimit) {

            var obj = poller.Send(pollerOptions.destination, data);
            var result = JSON.parse(obj);

            if (result.proceed == 'yes') {
                splash.closeModalSplash();
                pollerOptions.fnSuccessCallback(result);
            }
            else {
                pollerOptions.retryCount++;
                setTimeout(poller.Call, pollerOptions.delayRetry);
            }
        }
        else {
            // Make splash change to cancel button
            splash.cancelModalSplash();
            pollerOptions.fnTimeoutCallback();
        }
    },

    // Cancels the dialog
    Cancel: function() {
        splash.cancelModalSplash();

        // No more retries thanks
        pollerOptions.retryCount = pollerOptions.retryLimit;
    },

    // Cancels the dialog
    Close: function() {
        try {
            splash.closeModalSplash();
        } catch (Error) {
            // This really need the spalsh to handle being closed if it has not been opened..
        }
    },

    // Retries
    Retry: function() {
        // Reset retries and start over
        pollerOptions.retryCount = 0;
        splash.cancelModalSplash();

        splash.setTitle(pollerOptions.title);
        splash.setErrorTitle(pollerOptions.errorTitle);
        splash.setModalError(pollerOptions.errorMessage);
        splash.openModalSplash(poller.Retry, poller.Cancel, null);

        poller.Call();
    }
}
