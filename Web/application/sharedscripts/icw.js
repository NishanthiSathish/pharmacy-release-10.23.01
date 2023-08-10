/// <reference path="../ICW/script/ICWPageScript.js" />

/*

icw.js
    
Include this in any page that will appear as a primary "application pane" in an ICW "Desktop"

*/


var __m_ICWEventWindowID = 0,
    IMAGE_PATH = "../../Images/User/",
    SHARED_SCRIPTS = "/Web/application/sharedscripts/",
    ICWWin = null;
//var ordersXML;

//=================================================================================================
//= Common Methods

function $ICWPageScriptJQuery() {
    /// <summary>
    /// This is the jQuery object found in the main ICW Window.
    /// </summary>
    
    var ICWWindow$ = ICWWindow().$;

    return arguments.length == 0 ? ICWWindow$ : ICWWindow$.apply(this, arguments);
}

var loadJS = function (file) {
    var script = document.createElement('script');
    script.src = file;
    script.type = 'text/javascript';
    document.getElementsByTagName('head')[0].appendChild(script);
};

var loadCSS = function (file) {
    var css = document.createElement('link');
    css.setAttribute("rel", "stylesheet");
    css.setAttribute("type", "text/css");
    css.setAttribute("href", file);
    document.getElementsByTagName('head')[0].appendChild(css);
};

(function() {
    var loadRelativeToWebsiteRootJS = function(jsFileLocationRelativeToWebsiteRoot, hasJsLoaded, nextScriptToLoad) {

        var loadNextScript = function() {
            if (nextScriptToLoad) {
                if (hasJsLoaded()) {
                    nextScriptToLoad();
                } else {
                    window.setTimeout(loadNextScript, 10);
                }
            }
        };

        var load = function() {

            if (hasJsLoaded()) {
                loadNextScript();
                return;
            }

            function GetWebSiteAddressFromScriptTagWhichLoadedThisScript() {
                var scripts = document.getElementsByTagName('script');
                var path = "";
                var mydir = "";

                for (var i = scripts.length - 1; i >= 0; i--) {
                    var scriptPath = scripts[i].src;
                    if (scriptPath.length > 0) {
                        path = scriptPath.split('?')[0]; // remove any ?query
                    }
                }

                if (path.indexOf("http://") != -1) {
                    mydir = path.split('/').slice(0, -1).join('/') + '/'; // remove last filename part of path
                }

                return mydir;
            }

            var mydir = GetWebSiteAddressFromScriptTagWhichLoadedThisScript();

            for (var i = 0; i < 5 && !hasJsLoaded(); i++) {
                loadJS(mydir + jsFileLocationRelativeToWebsiteRoot);

                jsFileLocationRelativeToWebsiteRoot = "../" + jsFileLocationRelativeToWebsiteRoot;
            }

            loadNextScript();
        };

        load();
    };

    try {
        loadRelativeToWebsiteRootJS("application/sharedscripts/ICW/lib/ICW.min.js?v=00.00.00.00", function() { return window.ICW != undefined && window.ICW.MIN != undefined; });
    } catch(ex) {

    }
})();

function ICWGetNullLogger(loggerName) {
    /// <summary>
    /// Returns an instance of the dummy logger with the specified name.
    /// </summary>
    /// <param name="loggerName"  type="string">
    ///    The name of the logger.
    /// </param>
    return {
        loggerName: function () {
            return loggerName;
        },
        trace: function () {
        },
        debug: function () {
        },
        info: function () {
        },
        warn: function () {
        },
        error: function () {
        },
        fatal: function () {
        }
    };
}

function ICWGetLogger(loggerName) {
    /// <summary>
    /// Returns an instance of the client logger with the specified name.
    /// </summary>
    /// <param name="loggerName"  type="string">
    ///    The name of the logger.
    /// </param>
    /// <returns type="log4javascript.Logger" />
    var nullLogger = ICWGetNullLogger(loggerName);

    if (window.top != window && window.top.ICWGetLogger) {
        return window.top.ICWGetLogger(loggerName);
    }

    function GetICWLogger(loggerName) {
        /// <summary>
        /// Returns an instance of the logger with a central popup appender configured.
        /// </summary>
        /// <param name="loggerName"  type="string">
        ///    The name of the logger.
        /// </param>
        /// <returns type="log4javascript.Logger" />
        var logger = log4javascript.getNullLogger();

        if (!log4javascript_disabled) {
            logger = log4javascript.getLogger(loggerName);

            if (window.IcwPopupAppender == null) {
                window.IcwPopupAppender = new log4javascript.PopUpAppender();
                var layout = new log4javascript.PatternLayout("%d %p %c %m{1} %n");
                IcwPopupAppender.setLayout(layout);
            }

            logger.addAppender(window.IcwPopupAppender);
        }

        return logger;
    }

    try {
        if (!IsInTestRig()) {
            return window.ICWWindow() ? window.ICWWindow().GetICWLogger(loggerName) : window.log4javascript ? GetICWLogger(loggerName) : nullLogger;
        } else {
            return nullLogger;
        }
    } catch(ex) {
        return nullLogger;
    }
}

function ICWGetServerLogger(loggerName) {
    /// <summary>
    /// Returns an instance of the server logger with the specified name.
    /// </summary>
    /// <param name="loggerName"  type="string">
    ///    The name of the logger.
    /// </param>
    /// <returns type="log4javascript.Logger" />
    var nullLogger = ICWGetNullLogger(loggerName);

    try {
        if (!IsInTestRig()) {
            return ICWWindow().GetICWServerLogger(loggerName, window);
        }
        else {
            return nullLogger;
        }
    } catch (ex) {
        return nullLogger;
    }
}

function ICWGetUserActionAuditServerLogger(loggerName) {
    /// <summary>
    /// Returns an instance of the user action audit server logger with the specified name.
    /// </summary>
    /// <param name="loggerName"  type="string">
    ///    The name of the logger.
    /// </param>
    /// <returns type="log4javascript.Logger" />
    var nullLogger = ICWGetNullLogger(loggerName);

    try {
        if (!IsInTestRig()) {
            return ICWWindow().GetICWUserActionAuditServerLogger(loggerName, window);
        }
        else {
            return nullLogger;
        }
    } catch (ex) {
        return nullLogger;
    }
}

function ICWGetAppUserActionAuditServerLogger() {
    /// <summary>
    /// Returns a singleton instance of the user action audit server logger.
    /// </summary>
    /// <returns type="log4javascript.Logger" />
    if (window.ICWAppUserActionAuditServerLogger == null) {
        window.ICWAppUserActionAuditServerLogger = ICWGetUserActionAuditServerLogger(window.location.pathname);
    }

    return window.ICWAppUserActionAuditServerLogger;
}

function ICWGetAppServerLogger() {
    /// <summary>
    /// Returns a singleton instance of the server logger.
    /// </summary>
    /// <returns type="log4javascript.Logger" />
    if (window.ICWAppServerLogger == null) {
        window.ICWAppServerLogger = ICWGetServerLogger(window.location.pathname);
    }

    return window.ICWAppServerLogger;
}

function ICWGetAppLogger() {
    /// <summary>
    /// Returns a singleton instance of the client logger.
    /// </summary>
    /// <returns type="log4javascript.Logger" />
    if (window.ICWAppLogger == null) {
        window.ICWAppLogger = ICWGetLogger(window.location.pathname);
    }

    return window.ICWAppLogger;
}

function GetICWJSFileLogger() {
    /// <summary>
    /// Returns an instance of the logger to be used by the icw.js file.
    /// </summary>
    /// <returns type="log4javascript.Logger" />
    if (window.ICWJSFileLogger == null) {
        window.ICWJSFileLogger = ICWGetLogger(window.location.pathname + " - ICW.js");
    }

    return window.ICWJSFileLogger;
}

function ICWGetAppRefresher() {
    /// <summary>
    /// Returns a singleton instance of the AppRefresher which is used to manage reloading of apps.
    /// </summary>
    /// <returns type="AppRefresher" />
    if (IsInTestRig()) {
        return true;
    }
    if (window.ICWAppRefresher == undefined) {
        window.ICWAppRefresher = ICWWindow().GetAppRefresher(window);
    }

    return window.ICWAppRefresher;
}

var ICWNotificationMessageType = ICWWindow() == undefined ? {} : ICWWindow().ICWNotificationType;

function ICWGetICWNotificationMessageButtonDetails() {
    /// <summary>
    /// Used to get an instance of <see ref="ICWNotificationButtonDetails" />.
    /// </summary>
    if (IsInTestRig()) {
        return null;
    }
    return ICWWindow().GetICWNotificationButtonDetails();
}

function ICWGetICWNotificationMessageDetails(callerWindow) {
    /// <summary>
    /// Used to get an instance of <see ref="ICWNotificationBarMessageDetails" />.
    /// </summary>
    if (IsInTestRig()) {
        return null;
    }
    return ICWWindow().GetICWNotificationMessageDetails(callerWindow || window);
}

function ICWShowMessageInNotificationBar(notificationDetails) {
    /// <summary>
    /// Used to message in the ICW notification bar.
    /// </summary>
    /// <param name="notificationDetails" type="ICWNotificationBarMessageDetails">
    /// Details about the notification message to display.
    /// Call <see ref="ICWGetICWNotificationMessageDetails()" /> to get an instance of <see ref="ICWNotificationBarMessageDetails" />.
    /// </param> 
    if (IsInTestRig()) {
        return;
    }
    ICWWindow().ShowMessageInICWNotificationBar(notificationDetails);
}

function ICWCloseNotificationBar(callerWindow) {
    /// <summary>
    /// Used to close ICW notification bar.
    /// </summary>
    if (IsInTestRig()) {
        return;
    }
    ICWWindow().CloseICWNotificationBar(ICWGetICWNotificationMessageDetails(callerWindow));
}

function ICWGetMutex(mutexName, getStubMutexIfICWWindowNotAvailable) {
    /// <summary>
    /// Returns an instance of the Mutex object which is used to acquire a lock.
    /// A unnamed mutex can only be used to acquire a lock compared to a named mutex where any mutex instance with that name can acquire a lock.
    ///
    /// Following methods are used try to execute the callback asynchronously only once a lock is acquired. The method doesn't keep on trying to acquire the lock and execute the callback.
    /// ICWGetMutex().lock(callback)
    /// ICWGetMutex().lock(callback, maxDuration)
    ///
    /// Following methods are used to execute the callback synchronously if a lock is acquired. The method doesn't keep on trying to acquire the lock and execute the callback.
    /// ICWGetMutex().trySyncLock(callback)
    /// ICWGetMutex().trySyncLock(callback, maxDuration)
    /// </summary>
    /// <param name="mutexName"  type="string">
    /// Optional. If the mutex name is specified than multiple instance can be used to acquire the lock.
    /// </param>
    /// <param name="getStubMutexIfICWWindowNotAvailable"  type="string">
    /// Optional. If set to true then returns a stub if ICWWindow not available.
    /// </param>
    /// <returns type="Mutex" />

    if (getStubMutexIfICWWindowNotAvailable && ICWWindow() == null) {

        return {
            lock: function(callback) {
                callback();
            },
            trySyncLock: function(callback) {
                callback();
            }
        };
    }

    return ICWWindow().GetMutex(mutexName, window);
}

function ICWSetLocationForSession(applicationKey, locationName) {
    /// <summary>
    /// Used by integrated applications (eg. JCC) to set the location for the session (TFS 79774)
    /// </summary>
    /// <param name="applicationKey"  type="string">
    /// A key to uniquely identify the integrated application eg. JCC
    /// </param>
    /// <param name="locationName"  type="string">
    /// The location name
    /// </param>
    var attributeName = applicationKey + "Location";

    ICWSetSessionAttribute(attributeName, locationName);
}

function ICWSetSessionAttribute(attributeName, value) {
    /// <summary>
    /// Used to set session attribute - currently used by the launcher framework
    /// </summary>
    /// <param name="value"  type="string">
    /// The value
    /// </param>
    /// <param name="attriuteName"  type="string">
    /// The attribute name
    /// </param>
    if (ICWWindow().SessionAttributeSet == undefined) {
        ICWWindow().$.getScript('../sharedscripts/SessionAttribute.js', function () {
            ICWWindow().SessionAttributeSet(GetCurrentSessionID(), attributeName, value);
        });
    }
    else {
        ICWWindow().SessionAttributeSet(GetCurrentSessionID(), attributeName, value);
    }
}

function ICWDisplayDesktopInModalDialog(desktopName, dialogOptions, objectToPassToTheDialog) {
    /// <summary>
    /// Loads the desktop specified by <param ref="desktopName" /> in a modal window.
    /// EpisodeSelected event is raised after modal dialog is closed if the desktop in the modal window assigns a value to window.returnValue.
    /// </summary>
    /// <param name="desktopName"  type="string">
    /// The name of the desktop
    /// </param>
    /// <param name="dialogOptions"  type="Object">
    /// An instance of object returned by ICWGetDesktopModalDialogOptionsInstance().
    /// </param>
    /// <param name="objectToPassToTheDialog"  type="Object">
    ///  Object passed to the dialog. Available in the dialog window via window.dialogAruguments.ObjectPassedIn.
    /// </param>
    /// <returns type="object">
    /// Result returned from the modal dialog.
    /// If a JSON string is assigned than an object is created from it and then returned.
    /// </return>
    GetICWJSFileLogger().info("ICWDisplayDesktopInModalDialog", "desktopName", "dialogOptions", "objectToPassToTheDialog");
    GetICWJSFileLogger().debug("ICWDisplayDesktopInModalDialog", "desktopName", desktopName, "dialogOptions", dialogOptions, "objectToPassToTheDialog", objectToPassToTheDialog);

    return ICWWindow().DisplayDesktopInModalDialog(desktopName, dialogOptions, objectToPassToTheDialog);
}

function ICWGetDesktopModalDialogOptionsInstance() {
    /// <summary>
    /// Returns an instance of dialogOptions object which can be used to customise how the modal dialog displays.
    /// </summary>
    /// <returns type="object">
    ///  {
    ///    DialogHeight: "700px",
    ///    DialogLeft: "",
    ///    DialogTop: "",
    ///    DialogWidth: "1000px",
    ///    Center: "yes",
    ///    DialogHide: "no",
    ///    Edge: "raised",
    ///    Resizable: "yes",
    ///    Scroll: "no",
    ///    Status: "no",
    ///    Unadorned: "no"
    /// }
    /// </return>
    return ICWWindow().GetDesktopModalDialogOptionsInstance();
}

Date.now = Date.now || function() { return new Date().valueOf(); };

String.prototype.nthIndexOf = function(searchString, nthOccurence) {
    /// <summary>
    /// Returns the <param ref="nthOccurence" /> occurence of <param ref="searchString" />.
    /// http: //stackoverflow.com/questions/14480345/how-to-get-the-nth-occurrence-in-a-string
    /// </summary>
    var l = this.length, i = -1;
    while (nthOccurence-- && i++ < l) {
        i = this.indexOf(searchString, i);
    }
    return i;
};

String.Empty = "";

String.IsNull = function(stringToCheck) {
    /// <summary>
    /// Checks whether the <param ref="stringToCheck" /> is null.
    /// </summary>
    return stringToCheck == undefined;
};

String.IsEmpty = function(stringToCheck) {
    /// <summary>
    /// Checks whether the <param ref="stringToCheck" /> is Empty.
    /// </summary>
    return stringToCheck == String.Empty;
};

String.IsNullOrEmpty = function(stringToCheck) {
    /// <summary>
    /// Checks whether the <param ref="stringToCheck" /> is null or empty.
    /// </summary>
    return String.IsNull(stringToCheck) || String.IsEmpty(stringToCheck);
};

String.IsWhiteSpace = function(stringToCheck) {
    /// <summary>
    /// Checks whether the <param ref="stringToCheck" /> is whitespace.
    /// </summary>
    return stringToCheck.length > 0 && stringToCheck.trim().length == 0;
};

String.IsNullOrWhiteSpace = function(stringToCheck) {
    /// <summary>
    /// Checks whether the <param ref="stringToCheck" /> is null or empty or has whitespace.
    /// </summary>
    return String.IsNullOrEmpty(stringToCheck) || String.IsWhiteSpace(stringToCheck);
};

function Sleep(milliSecondsToSleep) {
    var functionCallDateTime = Date.now();
    while (Date.now() - functionCallDateTime < milliSecondsToSleep) {
    }
}

var Watch = function (watchName) {

    var watchStartTime = null;

    this.Start = function () {
        GetLogger().info("Start");
        watchStartTime = Date.now();
        GetLogger().debug("Start", "watchStartTime", watchStartTime);
    };

    this.Elapsed = function (milliSecondsElapsed) {
        GetLogger().info("Elapsed");
        GetLogger().debug("Elapsed", "milliSecondsElapsed", milliSecondsElapsed);

        var milliSecondsElapsedUptilNow = 0;

        if (watchStartTime) {
            milliSecondsElapsedUptilNow = Date.now() - watchStartTime;
        }

        GetLogger().debug("Elapsed", "milliSecondsElapsed", milliSecondsElapsed, "watchStartTime", watchStartTime, "Date.now()", Date.now(), "milliSecondsElapsedUptilNow", milliSecondsElapsedUptilNow);

        return milliSecondsElapsedUptilNow > milliSecondsElapsed;
    };

    this.Reset = function () {
        GetLogger().info("Reset");
        GetLogger().debug("Reset");
        watchStartTime = null;
    };

    this.IsRunning = function () {
        GetLogger().info("IsRunning");
        GetLogger().debug("IsRunning", "watchStartTime", watchStartTime);
        return watchStartTime != undefined;
};

    function GetLogger() {

        function buildLogArguments(logArguments) {

            var builtArguments = [];

            builtArguments.push("Watch");
            builtArguments.push("watchName");
            builtArguments.push(watchName);

            for (var i = 0; i < logArguments.length; i++) {
                builtArguments.push(logArguments[i]);
            }

            return builtArguments;
        };

        return {
            trace: function () {
                GetICWJSFileLogger().trace.apply(GetICWJSFileLogger(), buildLogArguments(arguments));
            },
            debug: function () {
                GetICWJSFileLogger().debug.apply(GetICWJSFileLogger(), buildLogArguments(arguments));
            },
            info: function () {
                GetICWJSFileLogger().info.apply(GetICWJSFileLogger(), buildLogArguments(arguments));
            },
            warn: function () {
                GetICWJSFileLogger().warn.apply(GetICWJSFileLogger(), buildLogArguments(arguments));
            },
            error: function () {
                GetICWJSFileLogger().error.apply(GetICWJSFileLogger(), buildLogArguments(arguments));
            },
            fatal: function () {
                GetICWJSFileLogger().fatal.apply(GetICWJSFileLogger(), buildLogArguments(arguments));
            }
        };
    }
};

function TryCallFunction(functionToCall, exit) {

    var tryCall = true;

    var functionResult = null;

    var watch = new Watch("TryCallFunction");

    watch.Start();

    do {
        try {
            functionResult = functionToCall();

            tryCall = exit != undefined && exit(functionResult) == false;
        }
        catch (err) {
            GetICWJSFileLogger().error("TryCallFunction", "functionToCall", functionToCall, "exit", exit, "err", err);
        }
    }
    while (!watch.Elapsed(2000) && tryCall);

    return functionResult;
}

function GetWindowWhenReady(windowToCheckWhenReady) {

    if (windowToCheckWhenReady == undefined) {
        return null;
    }

    while (windowToCheckWhenReady.document.readyState != "complete") {
        Sleep(2000);
    }

    return windowToCheckWhenReady;
}

function FunctionExists(strFunctionName) {
    return (typeof (strFunctionName) === "function") ? true : false;
}

//= Prototype Extensions 
/* Check to ensure Array.push/pop prototype exists, creating one if it doesnt. */
if (!Array.prototype.push) {
    Array.prototype.push = function (x) {
        this[this.length] = x;

        return true;
    };
}

if (!Array.prototype.pop) {
    Array.prototype.pop = function () {
        var response = this[this.length - 1];
        this.length--;
        return response;
    };
}

/* String Trim strTrim(" string ") returns "string" */
var strTrim = function (s) { return s.replace(/^\s\s*/, '').replace(/\s\s*$/, ''); };
if (!String.prototype.trim) String.prototype.trim = function () { return this.replace(/^\s+|\s+$/g, ''); };

//=================================================================================================
function IsInTestRig() {
    /// <summary>
    /// Returns true if the page is running within a test rig hence <see ref="ICWWinodw()"  />
    /// would return null.
    /// </summary>
    return String(window.top.location).toUpperCase().indexOf("TESTRIG.ASPX") !== -1;
}
//=================================================================================================


//=================================================================================================
function DesktopWindow() {
    /// <summary>
    /// Gets the icw desktop window which hosts the application.
    /// </summary>
    /// <returns type="Window" />
    return ICWWindow().GetDesktopWindow(window);
}
//=================================================================================================
function ICWWindow() {
    /// <summary>
    /// Pointer created in ICW.aspx; single point of reference to the Window object in an accessible location.
    /// Null would be returned where ICW.js is used in modal windows as zero scope is passed in the ICW framework
    /// </summary>
    /// <returns type="Window" />
    /*
    var lngFrameLimit = 99,//Self-imposed nested frame limit
    objICWWindow = window,
    objHTMLTag = objICWWindow.document.all("html"),
    strTagName = "";
    
    while (true) {
    ++count;
    if (objHTMLTag !== null) {
    strTagName = objHTMLTag.className;
    }
    if (strTagName == "_ICW") {
    break;
    }
    if (lngFrameLimit == 0 || objICWWindow.parent == undefined || objICWWindow.parent == null || objICWWindow.location.href == objICWWindow.parent.location.href) {
    throw "Error: Hit top window: icw.js: ICWWindow(): " + window.location.href + ". This error can sometimes occur if ICW Events are raised from modal dialog boxes.";
    break;
    }
    objICWWindow = objICWWindow.parent;
    objHTMLTag = objICWWindow.document.all("html");
    lngFrameLimit--;
    }
    return objICWWindow;
    */
    if (top.ptrICW) {
        return top.ptrICW;
    }

    if (window.dialogArguments && window.dialogArguments.top && window.dialogArguments.top.ptrICW) {
        return window.dialogArguments.top.ptrICW;
    }

    return null;
}



//=================================================================================================
function ICWWindowIsVisible() {
    /// <summary>
    ///   Checks whether application window is visible to the user.
    /// </summary>
    /// <param name="appWindow"  type="Window">
    ///    The window to check.
    /// </param>
    /// <returns type="Bool" />

    if (IsInTestRig()) return true;

    return ICWWindow().ICW_IsWindowVisible(window);
}
//=================================================================================================

//=================================================================================================
function ToolMenuWindow() {
    GetICWJSFileLogger().debug("Called ToolMenuWindow");

    if (window.ICWToolMenuWindow == undefined) {
        window.ICWToolMenuWindow = ICWWindow().GetICWDesktopToolMenuWindow(window);
    }

    return window.ICWToolMenuWindow;
}

//=================================================================================================
function BannerWindow() {
    return ICWWindow().frames["fraBanner"];
}

//=================================================================================================

function CubicleWindow() {
    return ICWWindow().frames["fraCubicle"];
}

//=================================================================================================
function ShortcutBarWindow() {
    return CubicleWindow().frames["fraShortcutBar"];
}

//=================================================================================================
function ICWEventWindowID() {
    // 05Sep03 PH	Can be used in an event listener to return the ID of the Window that 
    //					raised the event. Returns 0 if not in an event.
    return __m_ICWEventWindowID;
}

//=================================================================================================

//SIK --The new SecurityEditor needs to raise these events. As I have to use the window.parent from within the 
//    -- SecurityEditor I need the RAISE wrappers to enable the event get raised properly
function RAISE_Security_User_Selected(UserID, UserName) {
    ICWEventRaise();
}

function RAISE_Security_User_Status_Change(IsOutOfUse, UserName, UserGuid) {
    ICWEventRaise();
}

function RAISE_Security_Role_Selected(RoleID, RoleName) {
    ICWEventRaise();
}

//SIK

function ICWEventRaise() {
    /// <summary>
    /// Used to raise icw events.
    /// Should be called from within functions which following the following naming convention.
    /// RAISE_EventName e.g. RAISE_EpisodeCleared
    ///
    /// Change History:
    /// 01Jul03 PH	Is meant to exist in an ICW "RAISE_MyEvent" stub.
    ///					Reads the signature of the calling function and use that info to broadcast
    ///					and ICW event. The name of the event broadcast is the calling function 
    ///					name minus the "RAISE_" prefix, and the parameters of the event are the 
    ///					parameters of the calling function.
    /// 05Sep03 PH	Changed so that events do not get broadcast back to the calling window.
    /// 18Feb11 PH	Added support for JSON parameters
    /// </summary>

    if (IsInTestRig()) return true;

    GetICWJSFileLogger().info("ICWEventRaise");

    __m_ICWEventWindowID = ICWWindowID();

    GetICWJSFileLogger().trace("ICWEventRaise", "__m_ICWEventWindowID", __m_ICWEventWindowID);

    var strFunctionText = String(ICWEventRaise.caller);

    GetICWJSFileLogger().trace("ICWEventRaise", "strFunctionText", strFunctionText);

    if (strFunctionText.indexOf("RAISE_") == -1) {

        GetICWJSFileLogger().trace("RK    If you are getting this error then it may be because you are running the ASP.Net Dev Server. Running in IIS will avert this issue");

        GetICWJSFileLogger().trace("Event System Error: Events can only be raised from with RAISE event stubs");

        alert("Event System Error: Events can only be raised from with RAISE event stubs");

        return false;
    }
    if (window.location.href.indexOf(".aspx") == -1) {

        GetICWJSFileLogger().trace("Event System Error: Events can only be raised from .aspx pages");

        alert("Event System Error: Events can only be raised from .aspx pages");

        return false;
    }

    var intEventNameStart = (strFunctionText.indexOf("_") + 1),
        intEventNameEnd = strFunctionText.indexOf("(", intEventNameStart + 1),
        strEventName = strFunctionText.substring(intEventNameStart, intEventNameEnd),

        objArguments = ICWEventRaise.caller.arguments,
        intParamLength = objArguments.length,
        strParams = "";

    GetICWJSFileLogger().trace("ICWEventRaise", "intEventNameStart", intEventNameStart, "intEventNameEnd", intEventNameEnd, "strEventName", strEventName, "objArguments", objArguments, "intParamLength", intParamLength);

    // 18Feb11 PH Added support for JSON string parameters
    if (intParamLength == 1 && (typeof objArguments[0]) == "string" && (objArguments[0]).charAt(0) == '{') {

        GetICWJSFileLogger().trace("ICWEventRaise", "This is a Desktop Event that contain a single JSON object parameter");

        var jsonString = objArguments[0];

        GetICWJSFileLogger().trace("ICWEventRaise", "jsonString", jsonString);

        // Escape it, so it can be used in an Eval, later.
        var jsonStringEscaped = jsonString
            .replace(/\"/g, '\\\"')
            .replace(/\r/g, " ")
            .replace(/\t/g, " ")
            .replace(/\n/g, " ");

        GetICWJSFileLogger().trace("ICWEventRaise", "jsonStringEscaped", jsonStringEscaped);

        ICWEventBroadcast(strEventName, jsonStringEscaped, __m_ICWEventWindowID, 0);
    }
    else if (intParamLength > 0) {

        GetICWJSFileLogger().trace("ICWEventRaise", "This is an non-JSON Desktop Event, so use old-style multi-parameter broadcast mechanism");

        for (var intIndex = 0; intIndex < intParamLength; intIndex++) {
            strParams += (", " + FormatArgument(objArguments[intIndex]));
        }

        var script = 'ICWEventBroadcast("' + strEventName + '"' + strParams + ', ' + __m_ICWEventWindowID + ', 0)';

        GetICWJSFileLogger().trace("ICWEventRaise", "This is an non-JSON Desktop Event, so use old-style multi-parameter broadcast mechanism");

        window.execScript(script);
    }
    else if (intParamLength == 0) { 

        GetICWJSFileLogger().trace("ICWEventRaise", "SIK 25072011 handle events without parameters. <strParams> is not exactly needed but it will be an empty string at this point.");

        window.execScript('ICWEventBroadcast("' + strEventName + '"' + strParams + ', ' + __m_ICWEventWindowID + ', 0)');
    }

    __m_ICWEventWindowID = 0;

    // CA 28/09/2015 - US:129656
    //  Added special case for when the event raised an an EpisodeSelected event.
    //  Make a call to the v11 ICWInternal WebService to log it.
    if (strEventName == 'EpisodeSelected') {
        var terminalId = ICWWindow().body.getAttribute("terminalId");
        if (isNaN(terminalId) || terminalId <= 0) {
            alert('Please activate the Terminal, all actions will be monitored.');
        }
        var strEpisodeVidJSON = FormatArgument(objArguments[0]);
        var episodeVid = JSON.parse(strEpisodeVidJSON.substring(1, strEpisodeVidJSON.length - 1));
        var sessionId = GetCurrentSessionID();
        var episodeGUID = episodeVid.EntityEpisode.vidEpisode.GUID;
        var data = { sessionId: sessionId, episodeGUID: "{" + episodeGUID + "}" };
        var url = ICWGetICWV11Location() + "/ICWInternal.asmx/LogContextChange";

        $ICWPageScriptJQuery().ajax({
            type: "POST",
            url: url,
            data: JSON.stringify(data),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: true
        });
    }

    GetICWJSFileLogger().trace("ICWEventRaise", "Event Handled");
    
    return true;
}



// Should be used to wrapper an ICW Application URL to auto-include the WindowID QueryString variable in the URL
function ICWURL(strURL) {

    strURL += strURL.indexOf("?") === -1 ? "?" : "&";
    strURL += ("WindowID=" + ICWWindowID());

    return strURL;
}

// Returns the value of the given key within the query string, empty string if not found
function QueryString(strKey, queryStr, objWindow) {
    var i,
        result = "",
        windowToUseForQuerStringSearch = objWindow != undefined ? objWindow : window,
        parameters = queryStr != null ? queryStr.substr(1).split("&") : windowToUseForQuerStringSearch.location.search.substr(1).split("&"),
        param;

    for (i = 0; i < parameters.length; i++) {
        param = parameters[i].split("=");

        if (param[0].toLowerCase() == strKey.toLowerCase()) {
            result = param[1];
            break;
        }
    }

    return result;
}

// Return the window ID, 0 if not found
function ICWWindowID() {
    try {
        return parseInt(QueryString("WindowID"), 10);
    }
    catch (e) {
        return 0;
    }
}

// Puts " (double quotes) around a variable, if it's a string.
function FormatArgument(MyArgument) {
    switch (typeof (MyArgument)) {
        case "string":
            return ('"' + MyArgument + '"');
            break;
        default:
            return MyArgument;
            break;
    }
}

// CA - 23/09/2014 - BUG: 100600 
//      Functionality that changed which was missed out when the branches were being merged into trunk.
//
function ICWWindowHeightChange(newHeight) {
    ICWWindow().WindowHeightChange(newHeight, window);
}
//
// End BUG: 100600

//=================================================================================================
function ICWEventBroadcast(strEventName) {
    // 31May03 PH	Raises an ICW event, by getting the Desktop window, then traversing all child frames,and 
    //				attempting to call the specified event handler on each window. Any addition parameters
    //				included in the call to this function, are passed through in the broadcasted event calls.

    var strParams;
    var intLength;
    var intIndex;

    intLength = arguments.length;
    if (intLength > 1) {
        strParams = FormatArgument(arguments[1]);
        for (intIndex = 2; intIndex < intLength; intIndex++) {
            strParams += ", " + FormatArgument(arguments[intIndex]);
        }
    }

    var desktopWindows = ICWWindow().GetAllDesktopWindows();

    for (var desktopWindow in desktopWindows) {
        ICWEventBroadcastToChilden(desktopWindows[desktopWindow], strEventName, strParams, __m_ICWEventWindowID, 0, false);
    }
}

//=================================================================================================
function ICWEventBroadcastToChilden(objWindow, strEventName, strParams, lngWindowID_Source, lngWindowID_Target, blnOnlyVisbleWindows) {
    // 31May03 PH	See ICWEventBroadcast, above.

    var intLength;
    var intIndex;
    var nodelist;
    var node;
    var objWindow_Target;
    var blnFireEvent;

    var xmldoc;

    // Lee Mulholland 14th August 2012
    // Added to call Event Registration Code from ICW.aspx

    // Fahad Zafar 21st September 2012
    // Bug 44414 - Prevent ICW_BroadcastRegisteredEvent from being called when this method is recursively called
    if (ICWEventBroadcastToChilden.caller != ICWEventBroadcastToChilden)
        ICWWindow().ICW_BroadcastRegisteredEvent(strEventName, strParams, lngWindowID_Source, lngWindowID_Target, window);

    // WindowData exists on the ICW Desktop, TabStrip, and Spitter pages
    xmldoc = objWindow.document.all("WindowData");
    if (xmldoc == null) {
        // If we're here, then objWindow is likely to be App page, as opposed to a TabStrip or a Splitter,
        // so we'll see if we can fire the event on it.
        FireEvent(20, strEventName, strParams, objWindow, blnOnlyVisbleWindows);
    }
    else {
        // If we're here, then objWindow is the ICW Desktop, TabStrip or a Splitter,
        // so recurce through all its windows to firing events...
        nodelist = objWindow.document.all("WindowData").selectNodes("//Window");
        intLength = nodelist.length;

        for (intIndex = 0; intIndex < intLength; intIndex++) {
            node = nodelist(intIndex);
            objWindow_Target = objWindow.frames["fra" + node.getAttribute("ID")];
            switch (Number(node.getAttribute("Type"))) {
                case 1: // Pane window type
                    if (lngWindowID_Target <= 0) {
                        // If no target window specified then send event to all windows, 
                        //	except the source window

                        blnFireEvent = (Number(node.getAttribute("ID")) != lngWindowID_Source);
                    }
                    else {
                        // If a target window IS specified then send event to the target window only
                        blnFireEvent = (Number(node.getAttribute("ID")) == lngWindowID_Target);
                    }

                    if (blnFireEvent) {
                        if (typeof (eval("objWindow_Target.EVENT_" + strEventName)) == "function") {
                            FireEvent(20, strEventName, strParams, objWindow_Target, blnOnlyVisbleWindows);
                        }
                    }
                    break;

                default: // tabstrip or splitter windows - process child windows
                    //01Mar2010    Rams    F0079170 - javascript error after selecting report editor - Added check to see if window is loaded
                    //all it needs is a minor time delay which needs the document to be fully loaded, presuming this loop will provide that delay required.
                    var tryCount = 0;
                    while (tryCount < 4) {
                        if (typeof objWindow_Target.ICWWindowIsVisible == 'function') {
                            ICWEventBroadcastToChilden(objWindow_Target, strEventName, strParams, lngWindowID_Source, lngWindowID_Target, blnOnlyVisbleWindows);
                            break;
                        }
                        tryCount++;
                    }
                    break;
            }

        }
    }
}

//27112012 DM reversal of dominant logic, checks for document.readyState first, if loaded checks for Event
function FireEvent(callCount, strEventName, strParams, objWindow_Target, blnOnlyVisbleWindows) {
    if (document.readyState != "complete") {
        if (callCount == 0) {
            alert("Timed out calling " + strEventName);
            return;
        }
        if (callCount > 0) {
            callCount--;
            var func = function () {
                FireEvent(callCount, strEventName, strParams, objWindow_Target, blnOnlyVisbleWindows);
            };
            window.setTimeout(func, 500);
        }
    }
    else {
        if (!blnOnlyVisbleWindows || (objWindow_Target.ICWWindowIsVisible != undefined && objWindow_Target.ICWWindowIsVisible())) {
            if (eval("objWindow_Target.EVENT_" + strEventName)) {
                eval("objWindow_Target.EVENT_" + strEventName + "(" + strParams + ")");
            }
        }
    }
}

//=================================================================================================
function FormatArgument(MyArgument) {
    // 31May03 Puts " (double quotes) around a variable, if it's a string. 

    switch (typeof (MyArgument)) {
        case "string":
            return '"' + MyArgument + '"';
            break;
        default:
            return MyArgument;
            break;
    }
}

//=================================================================================================
function ICWStatusShow(strText) {
    var objWindow = ICWWindow();
    if (objWindow.document.all("fraStatus").getAttribute("icwopened") != "yes") {
        objWindow.frames("fraStatus").MessageSet(strText);
        objWindow.document.all("fraStatus").style.display = "";
    }
}

//=================================================================================================
function ICWStatusHide() {
    var objWindow = ICWWindow();
    if (objWindow.document.all("fraStatus").getAttribute("icwopened") != "yes") {
        objWindow.document.all("fraStatus").style.display = "none";
    }
}

//=================================================================================================
function ICWWindowExtraCaptionSet(strText) {
    document.getElementById("spnICWExtraCaptionText").innerText = strText;
}

//=================================================================================================
function ICWWindowUserCaptionSet(strText) {
    document.getElementById("spnICWUserCaptionText").innerText = strText;
}

//=================================================================================================

// --------------------------Toolbar code----------------------------------
// Event handling code for ICW and Window Toolbar.
//
// Click events on toolbar icons are captured below in 'btnToolBar_onclick' 
// which calls the function ICWToolbar_onclick(EventName, WindowID)
// You must script this into your own application web pages in order to capture
// this event. Passes through EventName. This can then be
// handled however you like within your own code.
//
// Example of use;
//
// function ICWToolbar_onclick(EventName, WindowID)
// {
//     alert("EventName: " + EventName + " WindowID: " + WindowID);
// }
//
// 17Jun03 DB Created
// ----------------------------------------------------------------------

//=================================================================================================
function ToolbarHighlightOn(objToolbarTD) {
    // Handles a mouse enter event for toolbars. Changes the class to
    // one with a border

    if (!objToolbarTD.parentNode.parentNode.parentNode.parentNode.disabled) {
        objToolbarTD.className = "toolbarHover";
    }
}

//=================================================================================================
function ToolbarHighlightOff(objToolbarTD) {
    // Handles a mouse leave event for toolbars. Sets the class back to normal

    objToolbarTD.className = "toolbarNormal";
}

//=================================================================================================
function btnToolBar_onmousedown(objToolbarButton) {
    // Event code to capture mousedown event for toolbar button

    // Set the class back to Selected
    if (!objToolbarButton.disabled) {
        this.className = "toolbarSelected";
    }
}

//=================================================================================================
function btnToolBar_onmouseup(objToolbarButton) {
    // Event code to capture mouseup event for toolbar button

    // Set the class back to hover
    this.className = "toolbarHover";
}

function btnToolBar_onclick(EventName, EventParameter, WindowID) {
    // Captures a toolbar button click and passes it up to the ICW container for processing
    var Parameter = "'" + EventParameter + "'";
    if (IsInTestRig()) {
        eval("window.EVENT_" + EventName + "(" + Parameter + ")");
    } else {
        ICWWindow().ICWToolbar_onclick(EventName, Parameter, WindowID);
    }
}

function ICWToolMenuEnable(strEventName, blnEnabled) {
    /// <summary>
    ///   Enables or disables the menu item which has <paramref name="strEventName" />.
    /// </summary>
    /// <param name="strEventName"  type="String">
    ///    This is the substring of the javascript function defined on the page e.g. TestA from EVENT_TestA.
    /// </param>
    /// <param name="blnEnabled"  type="Boolean">
    ///    If set to true the menu is enabled else disabled.
    /// </param>
    if (!IsInTestRig()) {
        GetICWJSFileLogger().info("ICWToolMenuEnable", "strEventName", "blnEnabled");
        GetICWJSFileLogger().debug("ICWToolMenuEnable", "strEventName", strEventName, "blnEnabled", blnEnabled);
    }

    if (IsInTestRig()) {
        ICWWindowToolBarEnable(window, 0, strEventName, blnEnabled);
    } else {
        ICWWindowToolBarEnable(window, ICWWindowID(), strEventName, blnEnabled);
    }
}

//=================================================================================================
function ICWWindowToolBarEnable(objWindow, intWindowID, strEventName, blnEnabled) {
    var xmlnodelist,
    xmlnode,
    intIndex,
    imgToolMenu,
    btnToolMenu,
    xmldoc = objWindow.document.all("xmlICWToolbar");

    if (xmldoc != null) {
        xmlnodelist = xmldoc.selectNodes("//ToolMenu[@EventName='" + strEventName + "']");
        for (intIndex = 0; intIndex < xmlnodelist.length; intIndex++) {
            xmlnode = xmlnodelist(intIndex);

            imgToolMenu = objWindow.document.getElementById("imgICWToolMenu_" + xmlnode.getAttribute("ToolMenuID"));
            if (imgToolMenu != null) {
                if (blnEnabled) {
                    imgToolMenu.style.filter = "";
                }
                else {
                    imgToolMenu.style.filter = "progid:DXImageTransform.Microsoft.BasicImage(grayscale=0)";
                }
            }

            btnToolMenu = objWindow.document.getElementById("btnToolBar_" + xmlnode.getAttribute("ToolMenuID"));
            if (btnToolMenu != null) {
                btnToolMenu.disabled = !blnEnabled;
                if (blnEnabled) {
                    btnToolMenu.style.filter = "";
                }
                else {
                    btnToolMenu.style.filter = "progid:DXImageTransform.Microsoft.Alpha(Opacity=75)";
                }
            }
        }
    }

    if (!IsInTestRig()) {
        ToolMenuWindow().ICWMenuEnable(intWindowID, strEventName, blnEnabled);
    }
}

//=================================================================================================
function ICWToolMenuOverride(strEventName, strCaption, strPictureName) {
    //17May07 AE  Added ability to change image here as well
    if (!IsInTestRig()) {
        ToolMenuWindow().ICWToolMenuOverride(strEventName, strCaption, strPictureName);
    }
    ICWToolOverride(strEventName, strCaption, strPictureName);
}

//=================================================================================================
function ICWToolOverride(strEventName, strCaption, strPictureName) {
    /* 
    21Feb07 CJM Added ability to change image as well
    */

    var xmldoc;
    var xmlNodeList;
    var xmlNode;

    xmldoc = document.all("xmlICWToolbar");
    if ((xmldoc != null) && !((strCaption == null) && (strPictureName == null))) // added check on menutext for classes that have no CopyPhrase etc.
    {
        xmlNodeList = xmldoc.selectNodes("//ToolMenu[@EventName='" + strEventName + "']");

        for (var i = 0; i < xmlNodeList.length; i++) {
            xmlNode = xmlNodeList[i];

            if (strCaption != null) {
                tdToolMenu = document.getElementById("tdICWToolMenu_" + xmlNode.getAttribute("ToolMenuID"));
                if (tdToolMenu != null) {
                    tdToolMenu.innerText = strCaption;
                }
            }

            if (strPictureName != null) {
                imgToolMenu = document.getElementById("imgICWToolMenu_" + xmlNode.getAttribute("ToolMenuID"));
                if (imgToolMenu != null) {
                    imgToolMenu.src = IMAGE_PATH + strPictureName;
                }
            }
        }
    }
}

//=================================================================================================
function ICWToolMenuList(lngWindowID, blnEnabledOnly) {

    //Return a reference to an iXMLNodeList containing a list of all menu items for the specified window.
    //If blnEnabledOnly is true, only enabled items are included in the list.
    //Returns undefined if there is no menu.
    //07Feb05 AE  Written

    var DOM = ToolMenuWindow().document.all['xmlToolMenu'];

    if (DOM != undefined) {
        var strXPath = '//ToolMenu';
        if (blnEnabledOnly) {
            strXPath += '[(@WindowID="' + lngWindowID + '") and (@Enabled="1")]';
        }
        else {
            strXPath += '[@WindowID="' + lngWindowID + '"]';
        }
        return DOM.selectNodes(strXPath);
    }
}

//=================================================================================================
function IsICWEventEnabledInMenu(SessionID, EventName, WindowID) {
    // 19Apr06 PH Checks to see if the specified action is available and enabled in the ICW toolbar.

    var lngWindowID = ICWWindowID();
    var colItems = ICWToolMenuList(lngWindowID, true);

    if (colItems != undefined && colItems.length > 0) {																		//27Feb06 AE  Added check for length > 0
        for (i = 0; i < colItems.length; i++) {
            if (colItems[i].getAttribute('EventName') == EventName) {
                return true;
            }
        }
    }
    return false;
}

//=================================================================================================
// 24Jun2009 JMei method for removing a variable from querystring array
// query format: {[variable1=y],[variable2=yy],[variable3=yyy],[variable4=yyyy]}
function RemoveVariable(query, key) {
    var queryvalue, i;
    for (i = 0; i < query.length; i++) {
        queryvalue = query[i].split("=");
        if (queryvalue[0] == key) {
            query.splice(i, 1);
        }
    }
    return query;
}

function GetVariable(query, key) {
    var queryvalue, i;
    for (i = 0; i < query.length; i++) {
        queryvalue = query[i].split("=");
        if (queryvalue[0] == key) {
            return queryvalue[1];
        }
    }
    return "";
}
//=================================================================================================

//16Jul10   Rams    F0083243 - Additional Login support for Symphony Integration
//24Aug10   MK      Changes the interface to allow a sessionID parameter
//13dec10   Rams    Removed SessionID being passed as a param and
//                  created a new function that can be called across to get the CurrentSessionID
//01Nov11   Mattius Bug 8326 - Changed to ICWValidateLogin which returns either a Username if Successful and
//                  an empty string if not
function ICWValidateLogin(username) {
    var url = "../ICW/AdditionalLogin.aspx?SessionID=" + GetCurrentSessionID();

    if (username != null && username.length > 0) {
        url = url + "&Username=" + username;
    }

    var retval = window.showModalDialog(url, "", "center:yes;status:no;dialogWidth:640px;dialogHeight:480px");
    if (retval == 'logoutFromActivityTimeout') {
        retval = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (retval == null) { retval = ''; }

    return retval;
}

//16Jul10   Rams    F0083243 - Additional Login support for Symphony Integration
function IsGUID(source) {
    if (source != undefined && source !== null) {
        var guidRegEx = new RegExp("^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$");

        return source.match(guidRegEx);
    }
    return false;
}

//Added as part of RFC F0097938 - Function accepts desktop descriptions, checks for the matching name in the top.menumap object created in ToolMenu.aspx
//and passes the ID and Name arguments as required by NavigateToApplication.
var NavigateToApplicationByName = function(strDescription) {

    function getWindow(tagName) {
        if (isNaN(top.menuMap[tagName])) {
            return false;
        }
        return top.menuMap[tagName];
    }

    var tmpInt = getWindow(strTrim(strDescription));
    if (tmpInt !== false) {
        ICWWindow().NavigateToApplication(tmpInt, strDescription);
        return true;
    } else {
        return false;
    }
};


/// <summary>
///     Find Window by FileName to retrieve the WindowID
///	  Returns WindowID if found; otherwise returns 0
/// </summary>
/// <param name="str" domElement="false">
///    FileName to search for, must be a string, must not be null
/// </param>
/// <returns type="Int" />
var ICWFindWindowIdByPageName = function (str) {
    var frames = null,
        arrCount = -1;
    function getFileName(winObj) {
        var tmp = winObj.location.pathname.split("/");
        return String(tmp[tmp.length - 1]).toLowerCase();
    }

    if ((typeof str === "string") && (typeof ICWWindow().ICW.util.getFrames === "function")) {
        frames = ICWWindow().ICW.util.getFrames();
        arrCount = frames.length;
        while (arrCount--) {
            if (getFileName(frames[arrCount]) == String(str).toLowerCase()) {
                return QueryString("WindowID", frames[arrCount].location.search) || 0;
            }
        }
        return 0;
    }
};

/// <summary>
///     Finds a window object by its Window ID 
///	  Returns Window object or Null if not found
/// </summary>
/// <param name="iID" domElement="false">
///    Accepts Window ID
/// </param>
/// <returns type="Window[Object]" />
var findWindowByID = function(iID) {
    var frames = null, arrCount = 0;
    if (FunctionExists(ICWWindow().ICW.util.getFrames)) {
        frames = ICWWindow().ICW.util.getFrames();
        arrCount = frames.length;

        while (arrCount--) {
            if ((frames[arrCount].location.search.length > 0) && (QueryString("WindowID", frames[arrCount].location.search) == iID)) {
                return frames[arrCount];
            }
        }
    }
    return null;
};


/// <summary>
///     Finds a window object by its Window ID 
///	  Returns Position & Dimensions based on frameElement
/// </summary>
/// <param name="ICWWinID" domElement="false">
///    Accepts Window ID
/// </param>
/// <returns type="Object" />
var ICWWindowDimensions = function (ICWWinID, RelativeOffset) {
    var winByID = findWindowByID,
        win, ICWScreen;

    if (typeof (RelativeOffset) == 'undefined') {
        RelativeOffset = true;
    }

    if ((!isNaN(ICWWinID)) && (ICWWinID > 0) && (typeof ICWWindow().ICW.util.screen === "object")) {
        win = winByID(Number(ICWWinID));
        if (win !== null) {
            ICWWindow().ICW.util.screen.init(win.parent.document, win.parent);
            return {
                top: RelativeOffset == false ? window.screenTop : ICWWindow().ICW.util.screen.absYPosition(win.frameElement, true),
                left: RelativeOffset == false ? window.screenLeft : ICWWindow().ICW.util.screen.absXPosition(win.frameElement, true),
                height: win.frameElement.height,
                width: win.frameElement.width
            };
        }
    }
    return null;
};

var Desktops_QueryClose = function () {
    /// <summary>
    ///     Queries available windows for permission to run the desktop close event
    ///	  'raises' desktop close event (called across available frames)
    ///	  Returns true if the event was raised; false if it wasnt.
    /// </summary>
    /// <returns type="Bool" />
    return ICWWindow().DesktopsQueryClose();
};

var Desktop_QueryClose = function () {
    /// <summary>
    ///     Queries available windows in the current visible desktop for permission to run the desktop close event
    ///	  'raises' desktop close event (called across available frames)
    ///	  Returns true if the event was raised; false if it wasnt.
    /// </summary>
    /// <returns type="Bool" />
    return ICWWindow().DesktopQueryClose();
};

var ICWQueryEvent = function (eventName) {
    /// <summary>
    ///   Queries available windows to vote on whether to broadcast the specified event to it.
    ///	  Returns true if the event is allowed to be raised by all windows; false if it is not allowed.
    /// </summary>
    /// <param name="eventName"  type="string">
    ///    The name of the event
    /// </param>
    /// <returns type="Bool" />
    if (!IsInTestRig()) {
        return ICWWindow().DesktopsICWQueryEvent(eventName);
    } else {
        return true;
    }
};


var ICWTabEnable = function (bEnable) {
    /// <summary>
    ///    Should Be Called from within the IFRAME(tab) wishing to be disabled.
    /// </summary>
    /// <param name="bEnable" domElement="false">
    ///    True enables frames related tab, disabled disables
    /// </param>
    /// <returns type="Void" />
    var targetFrameTab,
        ICWWin = ICWWindow(),
        tabStrip = ICWWin.ICWFindWindowIdByPageName("tabstrip.aspx"),
        tabWindow = ICWWin.findWindowByID(tabStrip);

    targetFrameTab = "tabfor" + window.frameElement.id;

    if (bEnable) {
        tabWindow.document.getElementById(targetFrameTab).disabled = "";
    } else {
        tabWindow.document.getElementById(targetFrameTab).disabled = "disabled";
    }

};

// Return the ICW Session ID, 0 if not found
function GetCurrentSessionID() {
    try {
        var queryString = QueryString("SessionID");
        if (queryString == null || queryString == "") {
            return parseInt(ICWWindow().SessionIDGet(), 10);
        }
        else {
            return parseInt(queryString, 10);
        }
    }
    catch (e) {
        return 0;
    }
}

function ICWGetSettingAsBoolean(system, section, key, defaultvalue, role) {

    GetICWJSFileLogger().info("ICWGetSettingAsBoolean");
    GetICWJSFileLogger().debug("ICWGetSettingAsBoolean", "system", system, "section", section, "key", key, "defaultvalue", defaultvalue, "role", role);

    var result = ICWGetSetting(system, section, key, defaultvalue, role).toLowerCase() === "true";

    GetICWJSFileLogger().debug("ICWGetSettingAsBoolean", "system", system, "section", section, "key", key, "defaultvalue", defaultvalue, "role", role, "result", result);

    return result;
}

//14Dec10 ST    F0103979 Retrieves a setting value for the specified item.
function ICWGetSetting(system, section, key, defaultvalue, role) {

    GetICWJSFileLogger().info("ICWGetSetting");
    GetICWJSFileLogger().debug("ICWGetSetting", "system", system, "section", section, "key", key, "defaultvalue", defaultvalue, "role", role);

    if (role == null || role == undefined) {
        role = "";
    }

    var url = "../sharedscripts/ICWHelper.aspx?Mode=ICWGetSetting",
        data = "sessionID=" + GetCurrentSessionID()
                + "&system=" + system
                + "&section=" + section
                + "&key=" + key
                + "&defaultvalue=" + defaultvalue
                + "&role=" + role,
    objHTTPRequest = (window.XMLHttpRequest) ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", url, false);
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send(data);

    var result = objHTTPRequest.responseText || "";

    GetICWJSFileLogger().debug("ICWGetSetting", "system", system, "section", section, "key", key, "defaultvalue", defaultvalue, "role", role, "result", result, "url", url);

    return result;
}


// ASpeak13/02/2014 TFS REF:72446 - adding ability to get a setting with a specific sessionID
function ICWGetSettingWithSessionID(sessionid, system, section, key, defaultvalue) {

    GetICWJSFileLogger().info("ICWGetSettingWithSessionID");
    GetICWJSFileLogger().debug("ICWGetSettingWithSessionID", "sessionid", sessionid, "system", system, "section", section, "key", key, "defaultvalue", defaultvalue);

    var url = "../sharedscripts/ICWHelper.aspx?Mode=ICWGetSetting",
        data = "sessionID=" + sessionid
                + "&system=" + system
                + "&section=" + section
                + "&key=" + key
                + "&defaultvalue=" + defaultvalue,
    objHTTPRequest = (window.XMLHttpRequest) ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", url, false);
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send(data);

    var result = objHTTPRequest.responseText || "";

    GetICWJSFileLogger().debug("ICWGetSettingWithSessionID", "sessionid", sessionid, "system", system, "section", section, "key", key, "defaultvalue", defaultvalue, "result", result, "url", url);

    return result;
}
/*
//Set/Get State
var SetState = function(strKey, strValue) {

if (top.window.name == "" || typeof (top.window.name) != String) {
var setup = { ICWVID: "", SESSION: GetCurrentSessionID(), DATE: null };
top.window.name = JSON.stringify(setup);
}

strKey = strKey.toUpperCase();

var dataStore = JSON.parse(top.window.name);
dataStore[String(strKey)] = strValue;
top.window.name = JSON.stringify(dataStore);

return true;
};

var GetState = function(strKey) {
var jsonReturn = "";

if (top.window.name === "" || typeof (top.window.name) !== "string") {
var setup = { ICWVID: "", SESSION: GetCurrentSessionID(), DATE: null };
top.window.name = JSON.stringify(setup);
}

strKey = strKey.toUpperCase();

jsonReturn = JSON.parse(top.window.name);
return jsonReturn[strKey] ? jsonReturn[strKey] : {};

};
*/

//========================================================================================================
//  SimpleSplash 
//      Use to cover a pane with a transparency and a message when doing potentially long callbacks
//      etc.  Simple version of the splash object below.
//      Use:    
//          ICWSimpleSplash_Initialise() - creates the html elements, call before _Show()
//          ICWSimpleSplash_Show(message) - displays the splash screen and the message
//          ICWSimpleSplash_Hide()       - hides it again.
//=======================================================================================================


function ICWSimpleSplash_Initialise() {

    if (document.getElementById('_simpleSplash') == undefined) {
        var _simpleSplash = document.createElement('DIV');
        var _msg = document.createElement('P');
        _msg.style.fontFamily = 'arial';
        _msg.style.fontSize = '10pt';
        _msg.style.padding = '10px';
        _msg.style.width = '100px';
        _msg.style.top = '50px';
        _msg.style.left = '20px';
        _msg.style.position = 'absolute';
        _msg.style.backgroundColor = '#ffffff';
        _msg.style.border = 'black 1px solid';
        _msg.style.filter = 'alpha(opacity=100)';
        _msg.style.zIndex = '9999';
        _msg.setAttribute("id", "_simpleSplashMsg");
        _msg.style.display = 'none';
        _simpleSplash.appendChild(_msg);
        _simpleSplash.setAttribute("id", "_simpleSplash");
        _simpleSplash.style.display = 'none';
        _simpleSplash.style.backgroundColor = '#c0c0c0';
        _simpleSplash.style.position = 'absolute';
        _simpleSplash.style.height = '100%';
        _simpleSplash.style.width = '100%';
        _simpleSplash.style.zIndex = '9991';
        _simpleSplash.style.filter = 'alpha(opacity=90)';

        document.body.insertBefore(_simpleSplash, document.body.firstChild);
        document.body.insertBefore(_msg, document.body.firstChild);
    }
}

function ICWSimpleSplash_Show(strMessage, functionToCallWhileSplashShown) {
    var s = document.getElementById("_simpleSplash");
    var m = document.getElementById("_simpleSplashMsg");
    s.style.display = 'block';

    if (strMessage) {
    m.innerHTML = strMessage;
    m.style.display = 'block';
    }

    //Need a slight delay before calling the next bit otherwise the screen doesn't render.
    if (functionToCallWhileSplashShown) {
    window.setTimeout(functionToCallWhileSplashShown, 5);
    }
}

function ICWSimpleSplash_Hide() {
    var s = document.getElementById('_simpleSplash');
    if (s != undefined) { s.style.display = 'none'; }
    var m = document.getElementById("_simpleSplashMsg");
    if (m != undefined) { m.style.display = 'none'; }

}

//============End SimpleSplash ==============================
var splash = (function () {

    var showSplashWindowInterval;
    var splashFocusInterval;
    var isSplashScreenOpen = false;
    var mutex = ICWGetMutex(undefined, true);

    var messageElementId = "messagebox";
    var detailsElementId = "detailsbox";
    var showDetailsElementId = "showdetailslink";
    var cancelButtonElementId = "cancelthickbox";
    var refreshButtonElementId = "refreshthickbox";
    var acceptButtonElementId = "acceptthickbox";

    var SplashOption = function() {

        function initilialise(objectToInitialise) {
            objectToInitialise.ptrWindow = window;
            objectToInitialise.blnIsOpen = false;
            objectToInitialise.blnShowSpinner = true;
            objectToInitialise.objData = null;
            objectToInitialise.strMessage = "Loading Data";
            objectToInitialise.strErrorTitle = "Patient Not Found";
            objectToInitialise.fnRefreshCallback = null;
            objectToInitialise.fnCancelCallback = null;
            objectToInitialise.fnAcceptCallback = null;
            objectToInitialise.strError = "&nbsp;";
            objectToInitialise.strErrorDetails = "";
            objectToInitialise.overlayElementId = "tboverlay";
            objectToInitialise.windowElementId = "tbwindow";
            objectToInitialise.blnShowAsWindow = false;
            objectToInitialise.popup = null;
            objectToInitialise.blnRemoveMenuAccesskeysWhileShowing = false;
            objectToInitialise.strCancelButtonText = "Cancel";
            objectToInitialise.strRefreshButtonText = "Retry";
            objectToInitialise.strAcceptButtonText = "Accept";
            objectToInitialise.blnInCancelDisplayMode = false;
            objectToInitialise.blnInRetryDisplayMode = false;
        }

        initilialise(this);

        function CopySourceOptionsToDestinationOptionObject(optSrc, optDes) {
            GetICWJSFileLogger().info("CopySourceOptionsToDestinationOptionObject");
            GetICWJSFileLogger().debug("CopySourceOptionsToDestinationOptionObject", "optSrc", optSrc, "optDes", optDes);

            var copy = optDes;
            copy.ptrWindow = optSrc.ptrWindow;
            copy.blnIsOpen = optSrc.blnIsOpen;
            copy.blnShowSpinner = optSrc.blnShowSpinner;
            copy.objData = optSrc.objData;
            copy.strMessage = optSrc.strMessage;
            copy.strErrorTitle = optSrc.strErrorTitle;
            copy.fnRefreshCallback = optSrc.fnRefreshCallback;
            copy.fnCancelCallback = optSrc.fnCancelCallback;
            copy.fnAcceptCallback = optSrc.fnAcceptCallback;
            copy.strError = optSrc.strError;
            copy.strErrorDetails = optSrc.strErrorDetails;
            copy.overlayElementId = optSrc.overlayElementId;
            copy.windowElementId = optSrc.windowElementId;
            copy.blnShowAsWindow = optSrc.blnShowAsWindow;
            copy.popup = optSrc.popup;
            copy.blnRemoveMenuAccesskeysWhileShowing = optSrc.blnRemoveMenuAccesskeysWhileShowing;
            copy.strCancelButtonText = optSrc.strCancelButtonText;
            copy.strRefreshButtonText = optSrc.strRefreshButtonText;
            copy.strAcceptButtonText = optSrc.strAcceptButtonText;
            copy.blnInCancelDisplayMode = optSrc.blnInCancelDisplayMode;
            copy.blnInRetryDisplayMode = optSrc.blnInRetryDisplayMode;
            copy.blnInAcceptDisplayMode = optSrc.blnInAcceptDisplayMode;
            return copy;
        }

        this.Reset = function() {
            initilialise(this);
        };

        this.CopyTo = function(optDes) {
            GetICWJSFileLogger().info("CopyTo");
            GetICWJSFileLogger().debug("CopyTo", "optDes", optDes);

            CopySourceOptionsToDestinationOptionObject(this, optDes);
        };
    };

    var opt = new SplashOption();

    var currentlyShowingSplashOpt = new SplashOption();

    function _GetSplashWindowHeight(optionToUse) {
        GetICWJSFileLogger().info("_GetSplashWindowHeight");
        GetICWJSFileLogger().debug("_GetSplashWindowHeight", "optionToUse", optionToUse);

        var windowToDisplayRelativeToJqueryObject = $ICWPageScriptJQuery(optionToUse.ptrWindow);
        return (windowToDisplayRelativeToJqueryObject.height() - 12) + "px";
    }

    function _GetSplashWindowWidth(optionToUse) {
        GetICWJSFileLogger().info("_GetSplashWindowWidth");
        GetICWJSFileLogger().debug("_GetSplashWindowWidth", "optionToUse", optionToUse);

        var windowToDisplayRelativeToJqueryObject = $ICWPageScriptJQuery(optionToUse.ptrWindow);
        return (windowToDisplayRelativeToJqueryObject.width() - 12) + "px";
    }

    function _GetSplashWindowPosTop(optionToUse) {
        GetICWJSFileLogger().info("_GetSplashWindowPosTop");
        GetICWJSFileLogger().debug("_GetSplashWindowPosTop", "optionToUse", optionToUse);
        return optionToUse.ptrWindow.screenTop + "px";
    }

    function _GetSplashWindowPosLeft(optionToUse) {
        GetICWJSFileLogger().info("_GetSplashWindowPosLeft");
        GetICWJSFileLogger().debug("_GetSplashWindowPosLeft", "optionToUse", optionToUse);
        return optionToUse.ptrWindow.screenLeft + "px";
    }

    function _ShowModelessDialog(optionsToUse) {
        GetICWJSFileLogger().info("_ShowModelessDialog");
        GetICWJSFileLogger().debug("_ShowModelessDialog", "optionsToUse", optionsToUse);

        var currentDialogHeight = _GetSplashWindowHeight(optionsToUse);
        var currentDialogWidth = _GetSplashWindowWidth(optionsToUse);
        var currentDialogTop = _GetSplashWindowPosTop(optionsToUse);
        var currentDialogLeft = _GetSplashWindowPosLeft(optionsToUse);

        var myDialog = ICWShowModelessDialog(ICWGetICWV10Location() + "/application/sharedscripts/blank.htm", "", ICWWindow().String.format("dialogHeight:{0};dialogWidth:{1};dialogTop:{2};dialogLeft:{3};scroll=no", currentDialogHeight, currentDialogWidth, currentDialogTop, currentDialogLeft));

        var currentDialogAdjustedHeight = myDialog.dialogHeight;
        var currentDialogAdjustedWidth = myDialog.dialogWidth;
        var currentDialogAdjustedTop = myDialog.dialogTop;
        var currentDialogAdjustedLeft = myDialog.dialogLeft;
        var optiontoUseForRepos = optionsToUse;

        return {
            document: function () {
                return myDialog.document;
            },
            reposition: function (optiontoSet) {

                optiontoUseForRepos = optiontoSet;

                if (optiontoUseForRepos) {
                    var newPossibleDialogHeight = _GetSplashWindowHeight(optiontoUseForRepos);
                    if (currentDialogHeight != newPossibleDialogHeight) {
                        currentDialogHeight = newPossibleDialogHeight;
                        currentDialogAdjustedHeight = newPossibleDialogHeight;
                    }

                    var newPossibleDialogWidth = _GetSplashWindowWidth(optiontoUseForRepos);
                    if (currentDialogWidth != newPossibleDialogWidth) {
                        currentDialogWidth = newPossibleDialogWidth;
                        currentDialogAdjustedWidth = newPossibleDialogWidth;
                    }

                    var newPossibleDialogTop = _GetSplashWindowPosTop(optiontoUseForRepos);
                    if (currentDialogTop != newPossibleDialogTop) {
                        currentDialogTop = newPossibleDialogTop;
                        currentDialogAdjustedTop = newPossibleDialogTop;
                    }

                    var newPossibleDialogLeft = _GetSplashWindowPosLeft(optiontoUseForRepos);
                    if (currentDialogLeft != newPossibleDialogLeft) {
                        currentDialogLeft = newPossibleDialogLeft;
                        currentDialogAdjustedLeft = newPossibleDialogLeft;
                    }
                }

                if (myDialog.dialogHeight != currentDialogAdjustedHeight) {
                    myDialog.dialogHeight = currentDialogAdjustedHeight;
                    currentDialogAdjustedHeight = myDialog.dialogHeight;
                }

                if (myDialog.dialogWidth != currentDialogAdjustedWidth) {
                    myDialog.dialogWidth = currentDialogAdjustedWidth;
                    currentDialogAdjustedWidth = myDialog.dialogWidth;
                }

                if (myDialog.dialogTop != currentDialogAdjustedTop) {
                    myDialog.dialogTop = currentDialogAdjustedTop;
                    currentDialogAdjustedTop = myDialog.dialogTop;
                }

                if (myDialog.dialogLeft != currentDialogAdjustedLeft) {
                    myDialog.dialogLeft = currentDialogAdjustedLeft;
                    currentDialogAdjustedLeft = myDialog.dialogLeft;
                }
            },
            focus: function () {
                myDialog.focus();
            },
            close: function () {
                myDialog.close();
            },
            closed: function () {
                return myDialog.closed;
            }
        };
    }

    function _GetDocumentToInsertSplash(optionsToUse, callWhenDocumentReady) {

        GetICWJSFileLogger().info("_GetDocumentToInsertSplash");
        GetICWJSFileLogger().debug("_GetDocumentToInsertSplash", "optionsToUse", optionsToUse, "callWhenDocumentReady", callWhenDocumentReady);

        var newDocumentCreated = false;

        if (optionsToUse.blnShowAsWindow) {

            GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "optionsToUse.blnShowAsWindow", optionsToUse.blnShowAsWindow);

            var isWindowsWhichNeedsToBeOverlayedVisibleToUser = _IsWindowsWhichNeedsToBeOverlayedVisibleToUser(optionsToUse);

            GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "isWindowsWhichNeedsToBeOverlayedVisibleToUser", isWindowsWhichNeedsToBeOverlayedVisibleToUser);

            if (isSplashScreenOpen) {

                var isSplashWindowClosed = _CheckSplashWindowIsClosed(optionsToUse);

                GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "isSplashWindowClosed", isSplashWindowClosed);

                if (isSplashWindowClosed) {

                    if (isWindowsWhichNeedsToBeOverlayedVisibleToUser) {
                        GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "isSplashWindowClosed && isSplashScreenOpen", isSplashWindowClosed && isSplashScreenOpen);

                        optionsToUse.popup = _ShowModelessDialog(optionsToUse);

                        GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "optionsToUse.popup");

                        opt.popup = optionsToUse.popup;

                        GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "opt.popup = optionsToUse.popup");

                        currentlyShowingSplashOpt.popup = optionsToUse.popup;

                        GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "currentlyShowingSplashOpt.popup = optionsToUse.popup");

                        optionsToUse.ptrWindow.attachEvent('onunload', function () { CloseModalSplashFunc(); });

                        GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "optionsToUse.ptrWindow.attachEvent");

                        newDocumentCreated = true;

                        GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "new splash window created");

                        callWhenDocumentReady(optionsToUse.popup.document(), newDocumentCreated, GetFunctionName(_GetDocumentToInsertSplash));
                    } else {
                        GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "Window not meant to be visible so not creating a window");
                    }
                } else {

                    GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "Not creating a new splash window as one already exists");

                    callWhenDocumentReady(optionsToUse.popup.document(), newDocumentCreated);
                }
            } else {
                GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "Window not meant to be open so not creating a window");
            }

        } else {

            GetICWJSFileLogger().trace("_GetDocumentToInsertSplash", "Using specified ptrWindow document rather than create a new splash window and use its document.");

            callWhenDocumentReady(optionsToUse.ptrWindow.document, newDocumentCreated);
        }

        GetICWJSFileLogger().debug("_GetDocumentToInsertSplash", "Finished");
    }

    function _IsWindowsWhichNeedsToBeOverlayedVisibleToUser(optionsToUse) {

        GetICWJSFileLogger().info("_IsWindowsWhichNeedsToBeOverlayedVisibleToUser");
        GetICWJSFileLogger().debug("_IsWindowsWhichNeedsToBeOverlayedVisibleToUser", "optionsToUse", optionsToUse);

        var isWindowToOverlayVisible = $ICWPageScriptJQuery(optionsToUse.ptrWindow.document.documentElement).is(":visible");

        GetICWJSFileLogger().trace("_IsWindowsWhichNeedsToBeOverlayedVisibleToUser", "isWindowToOverlayVisible", isWindowToOverlayVisible);

        return isWindowToOverlayVisible;
    }

    function _GetFormattedErrorTitle(strErrorTitle) {
        return strErrorTitle + '&hellip;';
    }

    function _GetFormattedMessage(strMessage) {
        return strMessage + '&hellip;';
    }

    function _GetTopMessage(optionsToUse) {

        if (optionsToUse.blnInCancelDisplayMode) {
            if (optionsToUse.strErrorTitle.length == 0) {
                return _GetFormattedMessage(optionsToUse.strMessage);
            } else {
                return _GetFormattedErrorTitle(optionsToUse.strErrorTitle);
            }
        } else {
            return optionsToUse.strMessage;
        }
    }

    function _GetWarnMessage(optionsToUse) {

        if (optionsToUse.blnInCancelDisplayMode) {
            if (optionsToUse.strErrorTitle.length == 0) {
                return "";
            } else {
                return optionsToUse.strError;
            }
        } else {
            return optionsToUse.strError;
        }
    }

    function _GetWarnMessageDetails(optionsToUse) {

        if (optionsToUse.blnInCancelDisplayMode) {
            if (optionsToUse.strErrorTitle.length == 0) {
                return "";
            } else {
                return optionsToUse.strErrorDetails;
            }
        } else {
            return optionsToUse.strErrorDetails;
        }
    }

    function _GetSplashImgSrc(optionsToUse) {
        if (optionsToUse.blnShowSpinner) {
            if (optionsToUse.blnInCancelDisplayMode) {
                if (optionsToUse.strErrorTitle.length == 0) {
                    return ICWGetICWV10Location() + "/images/ajax-loader-stopped.gif";
                } else {
                    return "";
                }
            } else {
                return ICWGetICWV10Location() + "/images/Developer/ajax-loader.gif";
            }
        } else {
            return "";
        }
    }

    function _ShouldShowSplashImg(optionsToUse) {
        if (optionsToUse.blnShowSpinner) {
            if (optionsToUse.blnInCancelDisplayMode) {
                if (optionsToUse.strErrorTitle.length == 0) {
                    return true;
                } else {
                    return false;
                }
            } else {
                return true;
            }
        } else {
            return false;
        }
    }

    function _OpenModalSplashFuncProcessor() {

        GetICWJSFileLogger().info("_OpenModalSplashFuncProcessor");
        GetICWJSFileLogger().debug("_OpenModalSplashFuncProcessor");

        if (isSplashScreenOpen) {
            GetICWJSFileLogger().trace("_OpenModalSplashFuncProcessor", "Going to create a update splash");

            _UpdateModalSplash(opt);

        } else {
            GetICWJSFileLogger().trace("_OpenModalSplashFuncProcessor", "Going to create a new splash");

            isSplashScreenOpen = true;
            opt.blnIsOpen = true;
            currentlyShowingSplashOpt.blnIsOpen = true;

            if (opt.blnRemoveMenuAccesskeysWhileShowing) {
                ICWWindow().GetCurrentVisibleICWToolMenuWindow().BackupAndRemoveMenuKeyboardAccessKeys();
            } else {
                ICWWindow().GetCurrentVisibleICWToolMenuWindow().RestoreICWMenuKeyboardAccessKeys();
            }

            _GetDocumentToInsertSplash(opt, function (documentToInsertSplash, newDocumentToInsertSplashCreated, callerName) {
                var documentToInsertSplashJqueryObject = $ICWPageScriptJQuery(documentToInsertSplash);

                var creatingNewModal = true;
                _RenderOrUpdateRenderSplash(opt, creatingNewModal, documentToInsertSplash, documentToInsertSplashJqueryObject);

                opt.CopyTo(currentlyShowingSplashOpt);

            });
        }

        _ShowSplashWindowIfNeededAndEnsureVisibilityAsRequired(currentlyShowingSplashOpt);

        GetICWJSFileLogger().debug("_OpenModalSplashFuncProcessor", "Finished");
    }

    function _UpdateModalSplash(optionToUse) {

        GetICWJSFileLogger().info("_UpdateModalSplash");
        GetICWJSFileLogger().debug("_UpdateModalSplash", "optionToUse", optionToUse);

        _GetDocumentToInsertSplash(optionToUse, function (documentToInsertSplash, newDocumentToInsertSplashCreated, callerName) {

            var documentToInsertSplashJqueryObject = $ICWPageScriptJQuery(documentToInsertSplash);

            GetICWJSFileLogger().trace("_OpenModalSplashFuncProcessor", "Processing document which is based on new options", "documentToInsertSplash", documentToInsertSplash != undefined, "newDocumentToInsertSplashCreated", newDocumentToInsertSplashCreated, "caller name", callerName);

            _GetDocumentToInsertSplash(currentlyShowingSplashOpt, function (documentCurrentlyShowingSplash, newDocumentCurrentlyShowingSplashCreated) {

                GetICWJSFileLogger().trace("_OpenModalSplashFuncProcessor", "Processing old document which is based on old options", "documentCurrentlyShowingSplash", documentCurrentlyShowingSplash != undefined, "newDocumentCurrentlyShowingSplashCreated", newDocumentCurrentlyShowingSplashCreated, "caller name", GetFunctionName(_OpenModalSplashFuncProcessor));

                GetICWJSFileLogger().trace("_OpenModalSplashFuncProcessor", "opt.blnShowAsWindow", optionToUse.blnShowAsWindow, "documentToInsertSplash != documentCurrentlyShowingSplash", documentToInsertSplash != documentCurrentlyShowingSplash, "documentToInsertSplash.location", documentToInsertSplash.location, "documentCurrentlyShowingSplash.location", documentCurrentlyShowingSplash.location);

                var creatingNewModal = documentToInsertSplash != documentCurrentlyShowingSplash || newDocumentCurrentlyShowingSplashCreated;

                if (creatingNewModal) {

                    GetICWJSFileLogger().trace("_OpenModalSplashFuncProcessor", "Splash already open, hence closing it as it needs to be rendered somewhere else");

                    _RemoveRenderedSplash();

                    if (optionToUse.blnRemoveMenuAccesskeysWhileShowing) {
                        ICWWindow().GetCurrentVisibleICWToolMenuWindow().BackupAndRemoveMenuKeyboardAccessKeys();
                    } else {
                        ICWWindow().GetCurrentVisibleICWToolMenuWindow().RestoreICWMenuKeyboardAccessKeys();
                    }
                }

                optionToUse.blnIsOpen = true;
                currentlyShowingSplashOpt.blnIsOpen = true;

                _RenderOrUpdateRenderSplash(optionToUse, newDocumentToInsertSplashCreated || creatingNewModal, documentToInsertSplash, documentToInsertSplashJqueryObject);

                optionToUse.CopyTo(currentlyShowingSplashOpt);
            });
        });
    }

    function _RenderOrUpdateRenderSplash(optionsToUse, creatingNewModal, documentToInsertSplash, documentToInsertSplashJqueryObject) {

        GetICWJSFileLogger().info("_RenderOrUpdateRenderSplash");
        GetICWJSFileLogger().debug("_RenderOrUpdateRenderSplash", "optionsToUse", optionsToUse, "creatingNewModal", creatingNewModal, "documentToInsertSplash", documentToInsertSplash != undefined, "documentToInsertSplashJqueryObject", documentToInsertSplashJqueryObject.get(0).location, "caller name", GetFunctionName(_RenderOrUpdateRenderSplash));

        var isDocumentBlank = true;

        try {
            isDocumentBlank = documentToInsertSplashJqueryObject.get(0).documentElement.innerHTML == "<HEAD></HEAD>\r\n<BODY></BODY>";
        } catch (e) {
            //if this errored then it seems pretty likely that the document is indeed blank
        }

        if (creatingNewModal || isDocumentBlank) {
            GetICWJSFileLogger().trace("_RenderOrUpdateRenderSplash", "Rendering new splash screen");

            _RenderSplashScreen(optionsToUse, documentToInsertSplash, documentToInsertSplashJqueryObject);

        } else {
            GetICWJSFileLogger().trace("_RenderOrUpdateRenderSplash", "Updating Rendering Updating splash screen");

            _RenderUpdateSplash(optionsToUse, documentToInsertSplashJqueryObject);
        }

        _WireUpUserDefinedEventHandlers(optionsToUse, documentToInsertSplashJqueryObject);

        GetICWJSFileLogger().debug("_RenderOrUpdateRenderSplash", "Finished");
    }

    function _RenderSplashScreen(optionsToUse, documentToInsertSplash, documentToInsertSplashJqueryObject) {

        GetICWJSFileLogger().info("_RenderSplashScreen");
        GetICWJSFileLogger().debug("_RenderSplashScreen", "optionsToUse", optionsToUse, "documentToInsertSplash", documentToInsertSplash != undefined);

        var icwV10Location = ICWGetICWV10Location();

        if (optionsToUse.blnShowAsWindow) {
            if (documentToInsertSplash.styleSheets.length == 0) {
                var applicationStyle = documentToInsertSplash.createElement("link");
                applicationStyle.rel = "stylesheet";
                applicationStyle.type = "text/css";
                applicationStyle.href = icwV10Location + "/style/applicationWithoutPreventDrag.css";
                documentToInsertSplash.documentElement.firstChild.appendChild(applicationStyle);
            }
        }

        // Open the dialog
        var tboverlay = documentToInsertSplash.createElement("div");
        tboverlay.setAttribute("id", optionsToUse.overlayElementId);
        tboverlay.innerHTML = '<!--  Overlay -->';
        documentToInsertSplash.body.insertBefore(tboverlay, documentToInsertSplash.body.firstChild);

        //iframe shim to put overlay over objects (e.g. symphony)
        var shim = documentToInsertSplash.createElement("div");
        shim.setAttribute("id", optionsToUse.overlayElementId + "shim");
        shim.innerHTML = "<iframe style=\"width:100%;height:100%;position:absolute;top:0;left:0;filter:alpha(opacity=0);\" frameborder=\"0\" scrolling=\"no\">shimmy</iframe>";
        documentToInsertSplash.body.insertBefore(shim, documentToInsertSplash.body.firstChild);

        var warningMessage = _GetWarnMessage(optionsToUse);
        var warningMessageDetails = _GetWarnMessageDetails(optionsToUse);

        var tbwindow = documentToInsertSplash.createElement("div");
        tbwindow.setAttribute("id", optionsToUse.windowElementId);
        tbwindow.innerHTML = "<div id=\"win\"> " +
                                "<p id=\"topMessage\" style=\"font-weight:bold;font-family:arial;\">" + _GetTopMessage(optionsToUse) + "<\/p>" +
                                "<img id=\"splashimg\" " + (_ShouldShowSplashImg(optionsToUse) ? "" : "style=\"display:none\"") + " hspace=\"2\" vspace=\"2\" src=\"" + _GetSplashImgSrc(optionsToUse) + "\" height=\"16px\" width=\"16px\" />" +
                                "<p id=\"" + messageElementId + "\">" + warningMessage + "</p>" +
                                "<p id=\"" + detailsElementId + "\" style=\"display:none;\" onclick=\"window.clipboardData.setData('Text', this.innerHTML);\" title=\"Click to copy message.\">" + warningMessageDetails + "<\/p> " +
            " <a href=\"#\" id=\"" + showDetailsElementId + "\" " + (warningMessageDetails == "" ? " style=\"display:none\" " : "") + "\">Show details</a>" +
            " <input type=\"button\" id=\"" + acceptButtonElementId + "\" " + (optionsToUse.fnAcceptCallback == null ? " style=\"display:none\" " : "") + " value=\"" + optionsToUse.strAcceptButtonText + " \" \/> <br \/> " +
            " <input type=\"button\" id=\"" + refreshButtonElementId + "\"" + (optionsToUse.fnRefreshCallback == null ? " style=\"display:none\" " : "") + " value=\"" + optionsToUse.strRefreshButtonText + " \" \/> <br \/> " +
            " <input type=\"button\" id=\"" + cancelButtonElementId + "\"" + (optionsToUse.fnCancelCallback == null ? " style=\"display:none\" " : "") + " value=\"" + optionsToUse.strCancelButtonText + " \" \/> " +
            " <\/div>";
        documentToInsertSplash.body.insertBefore(tbwindow, documentToInsertSplash.body.firstChild);

        documentToInsertSplashJqueryObject.find("#" + showDetailsElementId).bind("click", function () {
            documentToInsertSplashJqueryObject.find("#" + detailsElementId).toggle();
            $(this).toggle();
        });

        GetICWJSFileLogger().debug("_RenderSplashScreen", "Finished");
    }

    function _RenderUpdateSplash(optionsToUse, documentToInsertSplashJqueryObject) {

        GetICWJSFileLogger().info("_RenderUpdateSplash");
        GetICWJSFileLogger().debug("_RenderUpdateSplash", "optionsToUse", optionsToUse, "documentToInsertSplashJqueryObject.length", documentToInsertSplashJqueryObject.length);

        documentToInsertSplashJqueryObject.find("#" + optionsToUse.elementId).attr("id", optionsToUse.elementId);

        var topMessageJqueryObject = documentToInsertSplashJqueryObject.find("#topMessage");

        var topMessage = _GetTopMessage(optionsToUse);

        if (topMessageJqueryObject.html() != topMessage) {
            topMessageJqueryObject.html(topMessage);
        }

        var splashImgJqueryObject = documentToInsertSplashJqueryObject.find("#splashimg");

        var splashImgShouldBeShownDisplayCss = _ShouldShowSplashImg(optionsToUse) ? "" : "none";

        if (splashImgJqueryObject.css("display") != splashImgShouldBeShownDisplayCss) {
            splashImgJqueryObject.css("display", splashImgShouldBeShownDisplayCss);
        }

        var splashImgSrc = _GetSplashImgSrc(optionsToUse);

        if (splashImgJqueryObject.attr("src") != splashImgSrc) {
            splashImgJqueryObject.attr("src", splashImgSrc);
        }

        _UpdateInputValue(documentToInsertSplashJqueryObject, cancelButtonElementId, optionsToUse.strCancelButtonText);

        _UpdateInputValue(documentToInsertSplashJqueryObject, refreshButtonElementId, optionsToUse.strRefreshButtonText);

        _UpdateInputValue(documentToInsertSplashJqueryObject, acceptButtonElementId, optionsToUse.strAcceptButtonText);

        var warnMessageJqueryObject = documentToInsertSplashJqueryObject.find("#" + messageElementId);
        var warnMessage = _GetWarnMessage(optionsToUse);

        if (warnMessageJqueryObject.html() != warnMessage) {
            warnMessageJqueryObject.html(warnMessage);
        }

        var detailsMessageJqueryObject = documentToInsertSplashJqueryObject.find("#" + detailsElementId);
        var detailsMessage = _GetWarnMessageDetails(optionsToUse);

        if (detailsMessageJqueryObject.html() != detailsMessage) {
            detailsMessageJqueryObject.html(detailsMessage);

            if (detailsMessage != "") {
                documentToInsertSplashJqueryObject.find("#" + showDetailsElementId).show();
            } else {
                documentToInsertSplashJqueryObject.find("#" + showDetailsElementId).hide();
            }
        }
    }

    function _UpdateInputValue(documentJqueryObjectToFindElementIn, inputElementId, newValue) {

        GetICWJSFileLogger().info("_UpdateInputValue");
        GetICWJSFileLogger().debug("_UpdateInputValue", "documentJqueryObjectToFindElementIn != undefined", documentJqueryObjectToFindElementIn != undefined, "inputElementId", inputElementId, "newValue", newValue);

        var inputElementJqueyObject = documentJqueryObjectToFindElementIn.find("#" + inputElementId);

        if (inputElementJqueyObject.val() != newValue) {
            inputElementJqueyObject.val(newValue);
        }
    }

    function _WireUpUserDefinedEventHandlers(optionsToUse, documentToInsertSplashJqueryObject) {

        GetICWJSFileLogger().info("_WireUpUserDefinedEventHandlers");
        GetICWJSFileLogger().debug("_WireUpUserDefinedEventHandlers", "optionsToUse", optionsToUse, "documentToInsertSplashJqueryObject", documentToInsertSplashJqueryObject.get(0).location);

        var cancelButtonJqueryObject = documentToInsertSplashJqueryObject.find("#" + cancelButtonElementId);
        var refreshButtonJqueryObject = documentToInsertSplashJqueryObject.find("#" + refreshButtonElementId);
        var acceptButtonJqueryObject = documentToInsertSplashJqueryObject.find("#" + acceptButtonElementId);

        cancelButtonJqueryObject.unbind("click");
        refreshButtonJqueryObject.unbind("click");
        acceptButtonJqueryObject.unbind("click");

        if (optionsToUse.fnCancelCallback != null) {
            cancelButtonJqueryObject.bind("click", CancelButtonPressedFunc);
            cancelButtonJqueryObject.show();
        } else {
            cancelButtonJqueryObject.hide();
        }

        if (optionsToUse.fnRefreshCallback != null) {
            refreshButtonJqueryObject.bind("click", RefreshButtonPressedFunc);
            refreshButtonJqueryObject.show();
        } else {
            refreshButtonJqueryObject.hide();
        }

        if (optionsToUse.fnAcceptCallback != null) {
            acceptButtonJqueryObject.bind("click", AcceptButtonPressedFunc);
            acceptButtonJqueryObject.show();
        } else {
            acceptButtonJqueryObject.hide();
        }

        GetICWJSFileLogger().debug("_WireUpUserDefinedEventHandlers", "Finished");
    }

    function _RemoveRenderedSplash() {

        GetICWJSFileLogger().info("_RemoveRenderedSplash");
        GetICWJSFileLogger().debug("_RemoveRenderedSplash", "isSplashScreenOpen", isSplashScreenOpen);

        if (isSplashScreenOpen) {

            opt.blnIsOpen = false;
            currentlyShowingSplashOpt.blnIsOpen = false;

            _GetDocumentToInsertSplash(currentlyShowingSplashOpt, function (documentToInsertSplash) {

                var documentToInsertSplashJqueryObject = $ICWPageScriptJQuery(documentToInsertSplash);

                // Close the dialog
                if (!currentlyShowingSplashOpt.blnShowAsWindow) {

                    GetICWJSFileLogger().trace("_RemoveRenderedSplash", "Removing splash overlay");

                    var tboverlay = documentToInsertSplash.getElementById(currentlyShowingSplashOpt.overlayElementId);
                    if (tboverlay) {
                        tboverlay.parentNode.removeChild(tboverlay);
                    }

                    var shim = documentToInsertSplash.getElementById(currentlyShowingSplashOpt.overlayElementId + "shim");
                    if (shim) {
                        shim.parentNode.removeChild(shim);
                    }

                    var tbwindow = documentToInsertSplash.getElementById(currentlyShowingSplashOpt.windowElementId);
                    if (tbwindow) {
                        tbwindow.parentNode.removeChild(tbwindow);
                    }
                } else {
                    GetICWJSFileLogger().trace("_RemoveRenderedSplash", "Closing splash window");

                    _CloseSplashWindow();
                }
            });
        }

        GetICWJSFileLogger().debug("_RemoveRenderedSplash", "Finished");
    }

    function _CheckSplashWindowIsClosed(optionToUse) {

        GetICWJSFileLogger().info("_CheckSplashWindowIsClosed");
        GetICWJSFileLogger().debug("_CheckSplashWindowIsClosed", "optionToUse", optionToUse);

        var isSplashWindowClosed = optionToUse.popup == undefined || optionToUse.popup.closed();

        GetICWJSFileLogger().trace("_CheckSplashWindowIsClosed", "isSplashWindowClosed", isSplashWindowClosed);

        return isSplashWindowClosed;
    }

    function _CloseSplashWindow() {

        GetICWJSFileLogger().info("_CloseSplashWindow");
        GetICWJSFileLogger().debug("_CloseSplashWindow");

        if (!_CheckSplashWindowIsClosed(currentlyShowingSplashOpt)) {

            GetICWJSFileLogger().trace("_CloseSplashWindow", "Closing Window");

            currentlyShowingSplashOpt.popup.close();
            currentlyShowingSplashOpt.popup = null;
            opt.popup = null;
        } else {
            GetICWJSFileLogger().trace("_CloseSplashWindow", "Window already close");
        }

        GetICWJSFileLogger().debug("_CloseSplashWindow", "Finished");
    }

    function _ShowSplashWindowIfNeededAndEnsureVisibilityAsRequired(optionToUse) {

        GetICWJSFileLogger().info("_ShowSplashWindowIfNeededAndEnsureVisibilityAsRequired");
        GetICWJSFileLogger().debug("_ShowSplashWindowIfNeededAndEnsureVisibilityAsRequired", "optionToUse", optionToUse);

        _ShowSplashWindowIfNeeded(optionToUse);

        _SetTimerToEnsureSplashVisibilityAsWindowIfNeeded(optionToUse);

        GetICWJSFileLogger().debug("_ShowSplashWindowIfNeededAndEnsureVisibilityAsRequired", "Finished");
    }

    function _SetTimerToEnsureSplashVisibilityAsWindowIfNeeded(optionToUse) {

        GetICWJSFileLogger().info("_SetTimerToEnsureSplashVisibilityAsWindowIfNeeded");
        GetICWJSFileLogger().debug("_SetTimerToEnsureSplashVisibilityAsWindowIfNeeded", "optionToUse", optionToUse);

        if (!showSplashWindowInterval) {
            _ClearTimerToEnsureSplashVisibilityAsWindowIfNeeded();

            GetICWJSFileLogger().trace("_SetTimerToEnsureSplashVisibilityAsWindowIfNeeded", "Setting timer as one doesn't exists");

            if (optionToUse.blnShowAsWindow) {
                showSplashWindowInterval = setInterval(function () { mutex.trySyncLock(function () { _ShowSplashWindowIfNeeded(optionToUse); }); }, 10);
            }
        } else {
            GetICWJSFileLogger().trace("_SetTimerToEnsureSplashVisibilityAsWindowIfNeeded", "Not setting timer as one already exists");
        }

        if (!splashFocusInterval) {
            _ClearFocusTimer();

            if (optionToUse.blnShowAsWindow) {
                splashFocusInterval = setInterval(function () { mutex.trySyncLock(function () { optionToUse.popup.focus(); }); }, 1500);
            }
        }

        GetICWJSFileLogger().debug("_SetTimerToEnsureSplashVisibilityAsWindowIfNeeded", "Finished");
    }

    function _ClearTimerToEnsureSplashVisibilityAsWindowIfNeeded() {

        GetICWJSFileLogger().info("_ClearTimerToEnsureSplashVisibilityAsWindowIfNeeded");

        // Remove any old timer to show splash screen
        clearInterval(showSplashWindowInterval);
        showSplashWindowInterval = null;
    }

    function _ClearFocusTimer() {
        clearInterval(splashFocusInterval);
        splashFocusInterval = null;
    }

    function _ShowSplashWindowIfNeeded(optionToUse) {

        GetICWJSFileLogger().info("_ShowSplashWindowIfNeeded");
        GetICWJSFileLogger().debug("_ShowSplashWindowIfNeeded", "optionToUse", optionToUse);

        TryCallFunction(function () {

            GetICWJSFileLogger().trace("_ShowSplashWindowIfNeeded", "TryCallFunction");

            if (isSplashScreenOpen) {

                GetICWJSFileLogger().trace("_ShowSplashWindowIfNeeded", "isSplashScreenOpen", isSplashScreenOpen);

                if (_IsWindowsWhichNeedsToBeOverlayedVisibleToUser(optionToUse)) {

                    GetICWJSFileLogger().trace("_ShowSplashWindowIfNeeded", "Window to overlay with splash window is visible to user so now going to show splash window if needed and positioning it.");

                    _UpdateModalSplash(optionToUse);

                    if (optionToUse.blnShowAsWindow) {
                        GetICWJSFileLogger().trace("_ShowSplashWindowIfNeeded", "Splash Window being repositioned.");

                        optionToUse.popup.reposition(optionToUse);

                    }

                    GetICWJSFileLogger().trace("_ShowSplashWindowIfNeeded", "Window to overlay with splash window is visible to user so finished showing splash window if needed and positioning it if needed.");

                } else {

                    GetICWJSFileLogger().trace("_ShowSplashWindowIfNeeded", "Splash WIndow should not be visible hence getting rid of it");

                    _RemoveRenderedSplash();
                }

            } else {
                GetICWJSFileLogger().trace("_ShowSplashWindowIfNeeded", "clear timer as the option to show as window may be set to false while its being viewed.");
                _ClearTimerToEnsureSplashVisibilityAsWindowIfNeeded();
                _ClearFocusTimer();
            }
        });

        GetICWJSFileLogger().debug("_ShowSplashWindowIfNeeded", "Finished");
    }

    function _ToggleButtonToCancelText() {

        GetICWJSFileLogger().info("_ToggleButtonToCancelText");
        GetICWJSFileLogger().debug("_ToggleButtonToCancelText", "opt", opt);

        opt.CopyTo(currentlyShowingSplashOpt);

        _SwitchIntoCancelDisplayMode(currentlyShowingSplashOpt);

        _GetDocumentToInsertSplash(currentlyShowingSplashOpt, function (documentToInsertSplash, newDocumentCreated) {

            var documentToInsertSplashJqueryObject = $ICWPageScriptJQuery(documentToInsertSplash);

            // Cancel button pressed, so replace with Refresh button and Continue button
            if (currentlyShowingSplashOpt.fnCancelCallback) {
                if (currentlyShowingSplashOpt.fnRefreshCallback) {
                    documentToInsertSplashJqueryObject.find("#" + cancelButtonElementId).hide();
                    documentToInsertSplashJqueryObject.find("#" + refreshButtonElementId).show();
                }

                if (currentlyShowingSplashOpt.fnAcceptCallback) {
                    documentToInsertSplashJqueryObject.find("#" + cancelButtonElementId).hide();
                    documentToInsertSplashJqueryObject.find("#" + acceptButtonElementId).show();
                }
            }
        });
    }

    function _SwitchIntoCancelDisplayMode(optionToUse) {

        GetICWJSFileLogger().info("_SwitchIntoCancelDisplayMode");
        GetICWJSFileLogger().debug("_SwitchIntoCancelDisplayMode", "optionToUse", optionToUse);

        optionToUse.blnInCancelDisplayMode = true;

        _ShowSplashWindowIfNeeded(optionToUse);
    }

    function _CloseModalSplashFunc() {
        /// <summary>
        ///    Used to close the splash.
        /// </summary>
        /// <returns type="Void" />

        GetICWJSFileLogger().info("_CloseModalSplashFunc");

        GetICWJSFileLogger().debug("_CloseModalSplashFunc", "caller name", GetFunctionName(_CloseModalSplashFunc));

        GetICWJSFileLogger().trace("_CloseModalSplashFunc", "isSplashScreenOpen", isSplashScreenOpen);

        _ClearTimerToEnsureSplashVisibilityAsWindowIfNeeded();
        _ClearFocusTimer();

        if (currentlyShowingSplashOpt.blnRemoveMenuAccesskeysWhileShowing) {

            GetICWJSFileLogger().trace("CloseModalSplashFunc", "Restoring Menu Access Keys");

            ICWWindow().GetCurrentVisibleICWToolMenuWindow().RestoreICWMenuKeyboardAccessKeys();
        }

        _RemoveRenderedSplash();

        isSplashScreenOpen = false;

        GetICWJSFileLogger().debug("_CloseModalSplashFunc - Finished", "isSplashScreenOpen", isSplashScreenOpen);

    }

    function OpenModalSplashFunc(fnRefreshCallBackFunc, fnCancelCallBackFunc, objMyData) {

        mutex.lock(function () {
            opt.fnRefreshCallback = fnRefreshCallBackFunc;
            opt.fnCancelCallback = fnCancelCallBackFunc;

            _OpenModalSplashFuncProcessor();

        });
    }

    function CloseModalSplashFunc() {
        /// <summary>
        ///    Used to close the splash.
        /// </summary>
        /// <returns type="Void" />
        mutex.lock(function () {

            GetICWJSFileLogger().info("CloseModalSplashFunc");

            GetICWJSFileLogger().debug("CloseModalSplashFunc", "caller name", GetFunctionName(CloseModalSplashFunc));

            GetICWJSFileLogger().trace("CloseModalSplashFunc", "isSplashScreenOpen", isSplashScreenOpen);

            _CloseModalSplashFunc();

            GetICWJSFileLogger().debug("CloseModalSplashFunc - Finished", "isSplashScreenOpen", isSplashScreenOpen);
        });
    }

    function SetModalError(error) {
        mutex.lock(function () {
            opt.strError = error;
        });
    }

    function SetModalErrorDetails(error) {
        mutex.lock(function () {
            opt.strErrorDetails = error;
        });
    }

    // Can be called prior to OpenModalSplashFunc to set the Header message
    function SetTitle(text) {
        mutex.lock(function () {
            opt.strMessage = text;
        });
    }

    // Can be called prior to OpenModalSplashFunc to set the Header message
    function SetErrorTitle(text) {
        mutex.lock(function () {
            opt.strErrorTitle = text;
        });
    }

    function CancelModalSplashFunc() {
        mutex.lock(function () {
            _ToggleButtonToCancelText();
        });
    }

    function CancelButtonPressedFunc() {
        mutex.lock(function () {
            _ToggleButtonToCancelText();
            // Call cancel call back function, passing an user-defined data
            if (opt.fnCancelCallback) {
                opt.fnCancelCallback(opt.objData);
            }
        });
    }

    function AcceptButtonPressedFunc() {
        mutex.lock(function () {
            _ToggleButtonToCancelText();
            // Call continue call back function, passing an user-defined data
            if (opt.fnAcceptCallback) {
                opt.fnAcceptCallback(opt.objData);
            }
        });
    }

    function RefreshButtonPressedFunc() {
        mutex.lock(function () {
            TryCallFunction(function () {
                // Refresh button pressed, so call Refresh callback function
                opt.CopyTo(currentlyShowingSplashOpt);

                currentlyShowingSplashOpt.blnInCancelDisplayMode = false;
                currentlyShowingSplashOpt.blnInRefreshDisplayMode = true;

                _GetDocumentToInsertSplash(currentlyShowingSplashOpt, function (documentToInsertSplash, newDocumentCreated) {

                    var documentToInsertSplashJqueryObject = $ICWPageScriptJQuery(documentToInsertSplash);

                    // Refesh button pressed, so replace with Cancel button
                    if (currentlyShowingSplashOpt.fnCancelCallback) {
                        if (currentlyShowingSplashOpt.fnRefreshCallback) {
                            documentToInsertSplashJqueryObject.find("#" + cancelButtonElementId).show();
                            documentToInsertSplashJqueryObject.find("#" + refreshButtonElementId).hide();
                        }

                        if (currentlyShowingSplashOpt.fnAcceptCallback) {
                            documentToInsertSplashJqueryObject.find("#" + cancelButtonElementId).show();
                            documentToInsertSplashJqueryObject.find("#" + acceptButtonElementId).hide();
                        }
                    }
                });

                // Call refresh call back function, passing an user-defined data
                if (opt.fnRefreshCallback) {
                    opt.fnRefreshCallback(opt.objData);
                }
            });
        });
    }

    function SwitchIntoCancelDisplayMode() {
        mutex.lock(function () {
            TryCallFunction(function () {
                GetICWJSFileLogger().info("SwitchIntoCancelDisplayMode");
                GetICWJSFileLogger().debug("SwitchIntoCancelDisplayMode", "opt", opt);

                opt.CopyTo(currentlyShowingSplashOpt);

                _SwitchIntoCancelDisplayMode(currentlyShowingSplashOpt);
            });
        });
    }

    function ResetModalSplashFunc() {
        mutex.lock(function () {
            TryCallFunction(function () {
                GetICWJSFileLogger().info("ResetModalSplashFunc");
                GetICWJSFileLogger().debug("ResetModalSplashFunc", "opt", opt);

                _CloseModalSplashFunc();

                opt.Reset();

                currentlyShowingSplashOpt.Reset();
            });
        });
    }

    function _SplashMutexLock(functionToLock) {

        GetICWJSFileLogger().debug("_SplashMutexLock", "functionToLock", functionToLock);

        var functionToQueue = function () {

            GetICWJSFileLogger().info("_SplashMutexLock mutex.lock");
            GetICWJSFileLogger().debug("_SplashMutexLock mutex.lock", "functionToLock", functionToLock);

            functionToLock();
        };

        mutex.lock(functionToQueue);

        GetICWJSFileLogger().debug("_SplashMutexLock", "functionToLock", functionToLock);
    }

    function _SplashTrySyncLock(functionToLock) {

        GetICWJSFileLogger().debug("_SplashTrySyncLock", "functionToLock", functionToLock);

        var functionToQueue = function () {

            GetICWJSFileLogger().info("_SplashTrySyncLock mutex.trySyncLock");
            GetICWJSFileLogger().debug("_SplashTrySyncLock mutex.trySyncLock", "functionToLock", functionToLock);

            functionToLock();
        };

        mutex.trySyncLock(functionToQueue);

        GetICWJSFileLogger().debug("_SplashTrySyncLock", "functionToLock", functionToLock);
    }

    // Setup Splash object properties and methods
    return {
        option: opt,
        openModalSplash: OpenModalSplashFunc,
        closeModalSplash: CloseModalSplashFunc,
        cancelModalSplash: CancelModalSplashFunc,
        cancelButtonPressed: CancelButtonPressedFunc,
        refreshButtonPressed: RefreshButtonPressedFunc,
        setModalError: SetModalError,
        setTitle: SetTitle,
        setErrorTitle: SetErrorTitle,
        switchIntoCancelDisplayMode: SwitchIntoCancelDisplayMode,
        lock: _SplashMutexLock,
        trySyncLock: _SplashTrySyncLock,
        reset: ResetModalSplashFunc
    };

} ());

//----------------------------------------------------------------------------------------------

//23Mar11 PH F0112877 Return the type of installation (LIVE, TRAINING, TEST, UNKNOWN). 
// Installation type is determined by database name suffix.
function ICWGetInstallationType() {
    return ICWWindow().GetICWInstallationType();
}

function ICWGetICWV10Location() {
    /// <summary>
    /// Gets the ICW V10 Location.
    /// </summary>
    /// <returns type="String" />
    return ICWWindow().ICWV10LocationGet();
}

function ICWGetICWV11Location() {
    /// <summary>
    /// Gets the ICW V11 Location.
    /// </summary>
    /// <returns type="String" />
    return ICWWindow().ICWV11LocationGet();
}

//17may11  MK f0037899  during a major incident - display incident name in title bar
function ICWWindowUserCaptionVisible(isVisible) {
    document.getElementById("divPaneCaption").style.display = (isVisible ? "" : "None");
}

//////////////////////////////////////////////
// Register ICW Event on ICWWindow()
// eventname is as per ICW Desktop 
// events without the EVENT_ or RAISE_
//////////////////////////////////////////////
// eventWindow = window(DOM)
// eventName = eventName(string)
function RegisterEvent(eventWindow, eventName) {
    ICWWindow().ICW_RegisterEvent(eventWindow, eventName);
}

//////////////////////////////////////////////
// UnRegister ICW Event from ICWWindow()
// eventname is as per ICW Desktop 
// events without the EVENT_ or RAISE_
//////////////////////////////////////////////
// eventWindow = window(DOM)
// eventName = eventName(string)
function UnRegisterEvent(eventWindow, eventName) {
    //TFS 55786 - The test for ICWWindow() != null was added - Required to stop error message when the inactivity timeout stops the application while a desktop is being displayed as a modal dialogue
    if ((ICWWindow() != null) && (ICWWindow().ICW_UnRegisterEvent != null)) {
        ICWWindow().ICW_UnRegisterEvent(eventWindow, eventName);
    }
}

function ICWToggleShortcutBar(show) {
    /// <summary>
    /// Used to show or hide the shortcut bar.
    /// </summary>
    /// <param name="show"  type="bool">
    ///    If set to true then the shortcut bar is made visible.
    ///    If set to false then the shortcut bar is hidden.
    /// </param>
    ICWWindow().ToggleShortcutBar(show);
}

function EVENT_ICW_Deactivate() {

}

function EVENT_ICW_Activate() {

}

function EVENT_ICW_Desktop_Visible() {

}

function EVENT_ICW_Desktop_Hidden() {

}

function ICWShowModelessDialog(url, varArgIn, options) {
    return window.showModelessDialog(url, varArgIn, options);
}

function GetFunctionName(functionCalled) {
    var functionCalledString = String(functionCalled.caller);

    return functionCalledString.substr(0, functionCalledString.indexOf("("));
}

function ICWExecuteWhenTargetReady(target, functionToCall, interval, attempt) {
    if (target.window.document.readyState == 'complete') {
        functionToCall();
    } else {
        var secondsToAttemptFor = 10;
        var attemptLimit = secondsToAttemptFor / (interval / 1000);

        if (attempt == null) {
            attempt = 0;
        } else if (attempt >= attemptLimit) {
            return;
        }

        var call = function() {
            ICWExecuteWhenTargetReady(target, functionToCall, interval, attempt+1);
        };

        this.setTimeout(call, interval);
    }
}

(function() {

    var myICWInternal = window.ICWInternal = { };

    myICWInternal.OnDomReady = function(onDomReadyHandler) {

        $ICWPageScriptJQuery(document).ready(onDomReadyHandler);

        if (window.Sys && window.Sys.WebForms && window.Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(onDomReadyHandler);
        }
    };

    myICWInternal.OnFormChange = function(onFormChangeEventHandler) {

        var bindOnFormChangeEventHandler = function() {

            var $document = $ICWPageScriptJQuery(document);

            $document.find('select').change(onFormChangeEventHandler);

            $document.find('input[type=text], input[type=password], textarea').bind('keypress change paste propertychange', onFormChangeEventHandler);

            $document.find('input[type=radio], input[type=checkbox], .icw-checkbox-inner-control').click(onFormChangeEventHandler);
        };

        myICWInternal.OnDomReady(bindOnFormChangeEventHandler);
    };

    myICWInternal.jQuery = $ICWPageScriptJQuery;

    myICWInternal.AddSpaceToSentenceWithNoSpaces = function(sentenceWithNoSpaces) {
        var sentenceWithSpaces = "";

        for (var i = 0; i < sentenceWithNoSpaces.length; i++) {

            var nextCharIndex = (i + 1) < sentenceWithNoSpaces.length ? (i + 1) : i;

            if (new RegExp("[A-Z]").test(sentenceWithNoSpaces.charAt(i))
                && new RegExp("[a-z]").test(sentenceWithNoSpaces.charAt(nextCharIndex))) {
                sentenceWithSpaces = sentenceWithSpaces + (i == 0 ? "" : " ");
            }

            sentenceWithSpaces = sentenceWithSpaces + sentenceWithNoSpaces.charAt(i);
        }

        return sentenceWithSpaces;
    };
})();