/*
ICW
*/

(function () {

    var logger = window.ICW.MIN.GetLogger(window.location + "-ICW.libs.js");

    logger.debug("Library Started loading");

    // "cache" useful methods, so they don't
    // have to be resolved every time they're used
    var push = Array.prototype.push,
        slice = Array.prototype.slice,
        toString = Object.prototype.toString,

        isArray = function (o) {
            toString.call(o) === '[object Array]';
        },

        toArray = (function () {
            try {
                // Return a basic slice() if the environment
                // is okay with converting NodeLists to
                // arrays using slice()

                slice.call(document.childNodes);

                return function (arrayLike) {
                    return slice.call(arrayLike);
                };

            } catch (e) { }
            // Otherwise return the slower approach
            return function (arrayLike) {

                var ret = [], i = -1, len = arrayLike.length;

                while (++i < len) {
                    ret[i] = arrayLike[i];
                }

                return ret;

            };
        })();

    /*
    ICW.utils

    Usage Example:

    ICW.util.loadFrames()
    ICW.util.arrayContains(array, value) : Boolean
    ICW.util.objectContains(associateArrayObject, value) : Boolean
    ICW.util.stopPropagation(event) : False
    ICW.util.addFrame(WindowObj)
    */
    var util = null;

    util = (function () {

        var objTopWindow = top.window.frames,
		arrFrames = [],
		MaxDepth = 10;

        var AddToArray = function (obj) {
            if (typeof obj.document !== "undefined") {
                arrFrames.push(obj);
                return true;
            }
            return false;
        };

        var DeleteFromArray = function (obj) {
            if (typeof obj !== "undefined") {
                arrFrames.splice(arrFrames.indexOf(obj), 1);
                return true;
            }
            return false;
        };

        var FrameLoop = function (objFrames) {
            var MD = MaxDepth;
            if (MD > 0) {
                if (objFrames !== null) {
                    for (var k = 0; k < objFrames.frames.length; k++) {
                        var tmp = objFrames.frames[k];
                        AddToArray(tmp);
                        FrameLoop(tmp);
                    }
                    MD--;
                }
            }
        };

        var GetFrameAndChildFrames = function (objFrame) {
            /// <summary>
            /// Returns an array of containing the specified frame and its child frames.
            /// </summary>
            /// <param name="objFrame" type="Window">
            ///    The frame which will be search for shild frames.
            /// </param>
            /// <returns type="Array" />
            /// </summary>
            var MD = MaxDepth;
            var childFrames = [];
            if (MD > 0) {
                if (objFrame !== null) {
                    childFrames = [objFrame];
                    for (var k = 0; k < objFrame.frames.length; k++) {
                        var tmp = objFrame.frames[k];
                        childFrames = childFrames.concat(GetFrameAndChildFrames(tmp));
                    }
                    MD--;
                }
            }
            return childFrames;
        };

        var BroadcastFunctionCall = function () {
            var frames = null,
			args = Array.prototype.slice.call(arguments),
			fn = args.shift();

            frames = ICW.util.getFrames();

            for (arrCount = 0; arrCount < frames.length; arrCount++) {
                if (typeof (frames[arrCount][fn]) === "function") {
                    frames[arrCount][fn].apply(null, args.concat(Array.prototype.slice.call(arguments)));
                }
            }
        };

        var BroadcastFnCallToFrameAndChildFrames = function () {
            /// <summary>
            /// Calls the specified function <paramref name="functionName" /> to <paramref name="objFrame" /> and its child windows.
            /// </summary>
            /// <param name="functionName" type="string">
            ///    The name of the function to call on each child window.
            /// </param>
            /// <param name="objFrame" type="Window">
            ///    The frame and its children on which the specified function will be called.
            /// </param>
            /// </summary>
            var frames = null,
			args = Array.prototype.slice.call(arguments),
			fn = args.shift(),
			objFrame = args.shift();

            frames = GetFrameAndChildFrames(objFrame);

            for (var arrCount = 0; arrCount < frames.length; arrCount++) {
                if (typeof (frames[arrCount][fn]) === "function") {
                    frames[arrCount][fn].apply(null, args.concat(Array.prototype.slice.call(arguments)));
                }
            }
        };

        return {
            broadcastFnCall: BroadcastFunctionCall,

            /// <summary>
            /// Calls the specified function <paramref name="functionName" /> to <paramref name="objFrame" /> and its child windows.
            /// </summary>
            /// <param name="functionName" type="string">
            ///    The name of the function to call on each child window.
            /// </param>
            /// <param name="objFrame" type="Window">
            ///    The frame and its children on which the specified function will be called.
            /// </param>
            /// </summary>
            broadcastFnCallToFrameAndChildFrames: BroadcastFnCallToFrameAndChildFrames,

            arrayContains: function (arr, value) {
                var arrCount = arr.length;
                while (arrCount--) {
                    if (arr[arrCount] == value) {
                        return true;
                    }
                }
                return false;
            },

            objectContains: function (obj, value) {
                for (var sKey in obj) {
                    if (obj[sKey] == value) { return true; }
                }
                return false;
            },

            stopPropagation: function (evt) {
                evt.returnValue = false;
                evt.cancelBubble = true;

                if (evt.stopPropagation) { evt.stopPropagation(); }
                return false;
            },

            /* Frame Management */
            loadFrames: function () {
                arrFrames.length = 0;
                AddToArray(objTopWindow);
                FrameLoop(objTopWindow);
            },

            addFrame: function (f) {
                AddToArray(f);
            },

            getFrames: function (c) {
                if (arrFrames.length < 1 || c !== null) { this.loadFrames(); }
                return arrFrames;
            },

            getFrameAndChildFrames: function (c) {
                /// <summary>
                /// Returns an array of containing the specified frame and its child frames.
                /// </summary>
                /// <param name="objFrame" type="Window">
                ///    The frame which will be search for shild frames.
                /// </param>
                /// <returns type="Array" />
                /// </summary>
                return GetFrameAndChildFrames(c);
            }
        };

    })();    /*
ICW.utils.keyboard

Usage Example:

ICW.util.keyboard.keys
ICW.util.keyboard.attachEvent() 
ICW.util.keyboard.getTopWindow()
*/

    util.keyboard = (function () {
        //"private" variables:
        var 
		objTopWindow = top.window.frames, localFrameArray,
        /* Keyboard Keys {"F1": 112, "F2": 113, "F3": 114, "F4": 115, "F5": 116, "F6": 117, "F7": 118, "F9": 120, "F11": 122, "F12": 123, "ESC": 27, "RETURN": 13, "BKSP": 8};*/
		KEYS = { "F1": 112, "F2": 113, "F3": 114, "F4": 115, "F5": 116, "F6": 117, "F7": 118, "F9": 120, "F11": 122, "F12": 123, "ESC": 27, "RETURN": 13, "BKSP": 8, "ALT": 18, "F": 70, "HOME": 36, "LEFTARROW": 37, "RIGHTARROW": 39, "CTRL": 17, "R": 82, "N": 78, "W": 87, "E": 69, "O": 79, "L": 76, "I": 73, "H": 72, "S": 83, "Z": 90, "D": 68, "B": 66 },
		KEYOVERRIDES = { /*"F4": KEYS.F4,*/"F5": KEYS.F5, "F6": KEYS.F6, "F11": KEYS.F11, "ALT": KEYS.ALT, "F": KEYS.F, "HOME": KEYS.HOME, "RIGHTARROW": KEYS.RIGHTARROW, "LEFTARROW": KEYS.LEFTARROW, "BKSP": KEYS.BKSP, "CTRL": KEYS.CTRL, "R": KEYS.R, "N": KEYS.N, "W": KEYS.W, "E": KEYS.E, "O": KEYS.O, "L": KEYS.L, "I": KEYS.I, "H": KEYS.H, "S": KEYS.S, "Z": KEYS.Z, "D": KEYS.D, "B": KEYS.B };

        //"private" methods:	
        var AttachEvent = function () {

            var ev = function (e) {
                try {
                    var evt = (e) ? e : window.event,
				charCode;
                    if (evt === null) { evt = this.ownerDocument.parentWindow.event || this.parentWindow.event; /*IE doesnt capture scope correctly*/ }
                    charCode = evt.keyCode || evt.which;

                    if (ICW.util.objectContains(KEYOVERRIDES, charCode)) {

                        /* Run against KeyBoard Events */
                        if (!KeyboardEvents(charCode, evt)) {

                            /* Cancel/Void/Exit Event Bubble */
                            try {
                                evt.keyCode = 0;
                            } catch (y) { /* Technically keyCode only has a get method */
                            }
                            if (charCode != KEYS.HOME) {
                                return ICW.util.stopPropagation(evt);
                            } else {
                                return false;
                            }
                        }
                    }

                    /* Necessary to handle contaminated global scoped functions within the ICW
                    that override and unnecessarily cancel functionality beyond their visual scope */
                    //if(typeof(existing) == "function"){ existing(); }

                    return true;
                } catch (x) { }
            };

            localFrameArray = ICW.util.getFrames();

            for (var i = 0; i < localFrameArray.length; i++) {
                var existing;
                //BM19082011 TFS Ref. 11383. added the 'object' check below to block frames that have no document from getting through.
                if (typeof (localFrameArray[i].document) == "object") {
                    var currentElement = localFrameArray[i].document.body || localFrameArray[i].document;
                    currentElement.onkeydown = ev;
                    currentElement.oncontextmenu = noMenu;
                    currentElement.onhelp = noHelp;

                    //currentElement.onunload = function(){ setTimeout("ICW.util.keyboard.init()",1); };
                }
            }

        };

        function noMenu() {
            return false;
        };

        function noHelp() {
            return false;
        }

        var KeyboardEvents = function (c, e) {

            var ctrlKeys = { "F": KEYS.F, "S": KEYS.S, "H": KEYS.H, "I": KEYS.I, "L": KEYS.L, "O": KEYS.O, "E": KEYS.E, "W": KEYS.W, "N": KEYS.N, "R": KEYS.R, "D": KEYS.D, "B": KEYS.B };
            var altKeys = { "RIGHTARROW": KEYS.RIGHTARROW, "LEFTARROW": KEYS.LEFTARROW, "BKSP": KEYS.BKSP, "HOME": KEYS.HOME, "Z": KEYS.Z };

            // CTRL + KEY
            if (e.ctrlKey) {
                if (ICW.util.objectContains(ctrlKeys, c)) {
                    return false;
                }
            }
            // ALT + KEY
            if (e.altKey) {
                if (ICW.util.objectContains(altKeys, c)) {
                    return false;
                }
            }

            // FUNCTION KEYS ETC
            switch (c) {
                case KEYS.F6:
                    return false;
                    break;
                case KEYS.F5:
                    try {
                        // Changed to reload Desktop properly
                        DesktopWindow().location.reload();
                        // top.ActiveWin.location.reload();
                    }
                    catch (x) { }
                    break;
                //case KEYS.F4:             
                //	if(SessionIDGet() > 1){             
                //		var logoutPrompt = confirm("Are you sure you want to log out?");             
                //		if(logoutPrompt && typeof(ICWWindow) == "function"){ ICWWindow().Logout();/*ICW Scoped Function*/ }             
                //	}             
                //	break;             
                case KEYS.F11:
                    return false;
                    break;
                default:
                    return true;
            }
        };


        //Public Fields/Methods
        return {

            keys: KEYS,

            init: function () {
                ICW.util.loadFrames();
                AttachEvent();
            },

            getTopWindow: function () {
                return objTopWindow === undefined ? window.frames : objTopWindow.window.frames;
            },

            attachEvent: function () {
                if (localFrameArray.length < 1) { ICW.util.getFrames(); }
                AttachEvent();
            }
        };

    })(); /*
ICW.utils.screen

Usage Example:

ICW.util.screen.init(document,window);
ICW.util.screen.pageWidth();
ICW.util.screen.pageHeight();
ICW.util.screen.posLeft();
ICW.util.screen.posRight();
ICW.util.screen.posBottom();
ICW.util.screen.absYPosition(docElement);
ICW.util.screen.absXPosition(docElement);

*/

    util.screen = (function () {
        //"private" variables:
        var doc,
		win;

        //"private" method:
        var isInitialised = function () {
            return (doc && win) ? true : false;
        };

        //the returned object here will become ICW.util.screen:
        return {

            init: function (d, w) {
                //assigns document and window scope
                doc = d;
                win = w;
            },

            pageWidth: function () {
                if (isInitialised()) {
                    return win.innerWidth !== null ? win.innerWidth : doc.documentElement && doc.documentElement.clientWidth ? doc.documentElement.clientWidth : doc.body !== null ? doc.body.clientWidth : null;
                }
            },

            pageHeight: function () {
                if (isInitialised()) {
                    return win.innerHeight !== null ? win.innerHeight : doc.documentElement && doc.documentElement.clientHeight ? doc.documentElement.clientHeight : doc.body !== null ? doc.body.clientHeight : null;
                }
            },

            posLeft: function () {
                if (isInitialised()) {
                    return typeof win.pageXOffset != 'undefined' ? win.pageXOffset : doc.documentElement && doc.documentElement.scrollLeft ? doc.documentElement.scrollLeft : doc.body.scrollLeft ? doc.body.scrollLeft : 0;
                }
            },

            posTop: function () {
                if (isInitialised()) {
                    // viewport vertical scroll offset
                    var verticalOffset;
                    if (win.pageYOffset) { verticalOffset = win.pageYOffset; }
                    else if (doc.documentElement && doc.documentElement.scrollTop) { verticalOffset = doc.documentElement.scrollTop; /*IE6 Strict */ }
                    else if (doc.body) { verticalOffset = doc.body.scrollTop; /* >IE6 */ }
                    return verticalOffset;
                }
            },


            posRight: function () {
                if (isInitialised()) {
                    return this.posLeft() + this.pageWidth();
                }
            },

            posBottom: function () {
                if (isInitialised()) {
                    return this.posTop() + this.pageHeight();
                }
            },

            absYPosition: function (oEle, bWithinDesktop) {
                var tmp = 0;
                while (oEle !== null) {
                    tmp += oEle.offsetTop;
                    oEle = oEle.offsetParent;
                }
                if (bWithinDesktop) tmp += window.document.body.clientHeight - window.frames[2].frames[1].document.body.clientHeight;
                return tmp;
            },

            absXPosition: function (oEle, bWithinDesktop) {
                var tmp = 0;
                while (oEle !== null) {
                    tmp += oEle.offsetLeft;
                    oEle = oEle.offsetParent;
                }
                if (bWithinDesktop) tmp += window.document.body.clientWidth - window.frames[2].frames[1].document.body.clientWidth;
                return tmp;
            }

        };

    })();

    util.getIframeWindowAndDocument = function (frameRef) {

        var frameDetails = {
            window: undefined,
            document: undefined
        };

        if (frameRef.contentWindow) {
            frameDetails.window = frameRef.contentWindow;
            frameDetails.document = frameRef.contentWindow.document;
        } else {
            if (frameRef.contentDocument) {
                frameDetails.window = frameRef.contentWindow;
                frameDetails.document = frameRef.contentDocument;
            } else {
                if (frameRef.location) {
                    frameDetails.window = frameRef;
                    frameDetails.document = frameRef.document;
                } else {
                    frameDetails = undefined;
                }
            }
        }

        return frameDetails;
    }

    util.documentReady = function (documentWindow, documentToCheck, onDocumentReadyFunc) {

        var documentReadyEventHandler = function() {
            if (documentToCheck.readyState != undefined && (documentToCheck.readyState == "loading" || documentToCheck.body == null)) {

                logger.debug("documentReady", "adding readystatechange event handler to the frame document because the document is still loading and the document body is not available. When the document body is available it will be processed again", documentToCheck.location);

                ICW.util.addEvent(documentToCheck, "readystatechange", documentReadyEventHandler);
            } else {

                if (documentWindow.Sys && documentWindow.Sys.WebForms && documentWindow.Sys.WebForms.PageRequestManager) {
                    var pageRequestManager = documentWindow.Sys.WebForms.PageRequestManager.getInstance();
                    pageRequestManager.remove_endRequest(onDocumentReadyFunc)
                    pageRequestManager.add_endRequest(onDocumentReadyFunc);
                }

                onDocumentReadyFunc();
            }
        };

        documentReadyEventHandler();
    }

    // add event method
    util.addEvent = function (element, event, fn) {
        try {
            var eventHandler = function () {

                try {

                    var eventHandlerElementWhichFiredTheEvent = element;

                    var eventHandlerEventName = event;

                    var documentReadyEventHandler = function (myArguments) {

                        try {
                            var documentReadyEventHandlerElementWhichFiredTheEvent = element;

                            var documentReadyEventHandlerEventName = event;

                            logger.debug("documentReadyEventHandler", "documentReadyEventHandlerEventName", documentReadyEventHandlerEventName, "documentReadyEventHandlerElementWhichFiredTheEvent", documentReadyEventHandlerElementWhichFiredTheEvent, "myArguments", myArguments);

                            fn.apply(this, myArguments);
                        }
                        catch (documentReadyEventHandlerEx) {
                            logger.error("documentReadyEventHandler", "documentReadyEventHandlerEx", documentReadyEventHandlerEx);
                        }
                    };

                    logger.debug("eventHandler", "eventHandlerEventName", eventHandlerEventName, "eventHandlerElementWhichFiredTheEvent", eventHandlerElementWhichFiredTheEvent);

                    documentReadyEventHandler(arguments);
                }
                catch (eventEx) {
                    logger.error("eventHandler", "eventEx", eventEx);
                }
            };

            if (element.addEventListener) {
                element.addEventListener(event, eventHandler, false);
            } else {
                if (element.attachEvent) {
                    element.attachEvent('on' + event, eventHandler);
                };
            }
        } catch (addEventEx) {
            logger.error("addEvent", "addEventEx", addEventEx);
        }
    }

    var processFrames = function (frames, processFrameElement, processFrameDocument) {

        logger.debug("processFrames", "frames is defined", frames != undefined);

        try {
            frames = frames.frameElement ? [frames.frameElement] : frames.document ? [frames] : frames;

            for (var i = 0; i < frames.length; i++) {

                var frame = frames[i];

                processFrameElement(frame);

                var frameDetails = ICW.util.getIframeWindowAndDocument(frame);

                if (frameDetails) {

                    var frameDocument = frameDetails.document;

                    processFrameDocument(frameDetails.window, frameDocument);

                    var tagsToSearchFor = ["frame", "iframe", "frameset", "body"];

                    for (var n = 0; n < tagsToSearchFor.length; n++) {

                        var tag = null;
                        var innerframes = null;

                        tag = tagsToSearchFor[n];
                        innerframes = frameDocument.getElementsByTagName(tag);

                        if (innerframes.length != 0) {
                            processFrames(innerframes, processFrameElement, processFrameDocument);
                        }
                    }
                }
            }
        } catch (processFramesEx) {
            logger.error("processFrames", "processFramesEx", processFramesEx);
        }
    };

    util.processFramesUsingTopFrame = function (frames, processFrameElement, processFrameDocument) {

        logger.debug("ICW.util.processFramesUsingTopFrame");

        try {
            if (window.ICWWindow && window.ICWWindow() && window != window.ICWWindow() && ICWWindow().ICW && ICWWindow().ICW.util) {
                if (ICWWindow() != undefined) {
                    logger.debug("ICW.util.processFramesUsingTopFrame", "using the top frame, because the event will be lost and will show the context menu");

                    ICWWindow().ICW.util.processFramesUsingTopFrame(frames, processFrameElement, processFrameDocument);
                } else {
                    processFrames(frames, processFrameElement, processFrameDocument);
                }
            } else {
                processFrames(frames, processFrameElement, processFrameDocument);
            }
        } catch (processFramesUsingTopFrameEx) {
            logger.error("ICW.util.processFramesUsingTopFrame", "processFramesUsingTopFrameEx", processFramesUsingTopFrameEx);
        }
    };

    logger.debug("Finished Loading");

    if (window.ICW == undefined) {
        window.ICW = {};
    }

    window.ICW.util = util;

})();