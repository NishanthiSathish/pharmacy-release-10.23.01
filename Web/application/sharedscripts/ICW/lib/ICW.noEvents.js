// By Garry Pritchard 14/08/14 - Stop user form using IE right mouse click, F KEYS and other IE shortcut keys
if (window.ICW == undefined) {
    window.ICW = {};
};
ICW.noEvents = (function () {

    var logger = window.ICW.MIN.GetLogger(window.location + "-ICW.noEvents.js");

    logger.debug("Library Started loading");

    // list of keys and the keycode id
    var keys = {
        "F1": 112,
        "F2": 113,
        "F3": 114,
        "F4": 115,
        "F5": 116,
        "F6": 117,
        "F7": 118,
        "F9": 120,
        "F11": 122,
        "F12": 123,
        "ESC": 27,
        "RETURN": 13,
        "BKSP": 8,
        "ALT": 18,
        "HOME": 36,
        "LEFTARROW": 37,
        "RIGHTARROW": 39,
        "CTRL": 17,
        "A": 65,
        "B": 66,
        "C": 67,
        "D": 68,
        "E": 69,
        "F": 70,
        "G": 71,
        "H": 72,
        "I": 73,
        "J": 74,
        "K": 75,
        "L": 76,
        "M": 77,
        "N": 78,
        "O": 79,
        "P": 80,
        "Q": 81,
        "R": 82,
        "S": 83,
        "T": 84,
        "U": 85,
        "V": 86,
        "W": 87,
        "X": 88,
        "Y": 89,
        "Z": 90
    };

    // keys we need to override
    var keyOverrides = {
        "F5": keys.F5,
        "F6": keys.F6,
        "F11": keys.F11,
        "F3": keys.F3,
        "F7": keys.F7,
        "F12": keys.F12,
        "F4": keys.F4,
        "ALT": keys.ALT,
        "HOME": keys.HOME,
        "RIGHTARROW": keys.RIGHTARROW,
        "LEFTARROW": keys.LEFTARROW,
        "BKSP": keys.BKSP,
        "CTRL":
            keys.CTRL,
        "F": keys.F,
        "R": keys.R,
        "N": keys.N,
        "W": keys.W,
        "E": keys.E,
        "O": keys.O,
        "L": keys.L,
        "I": keys.I,
        "H": keys.H,
        "S": keys.S,
        "Z": keys.Z,
        "D": keys.D,
        "B": keys.B
    };

    var noEvent = function (e) {

        logger.debug("noEvent", "Event Stopped");

        var evt = getWindowEvent(e);

        if (evt) {
            evt.returnValue = false;
        }

        return false;
    };

    // 7Apr15 XN 115431 Added to allow selection of text in input\textarea's controls (like normal HTA mode)
    var textSelectEventHandler = function () {

        logger.debug("textSelectEventHandler");

        var evt = null;

        try {
            evt = window.event;
            if (evt === null) {
                evt = (this.ownerDocument == null) ? this.parentWindow.event : this.ownerDocument.parentWindow.event;
                logger.debug("evt", evt);
            }

            if (evt != null && (evt.srcElement.nodeName == "INPUT" || evt.srcElement.nodeName == "TEXTAREA")) {
                logger.debug("Allowing event", "evt", evt);
                return true;
            }
        } catch (textSelectEventHandlerEx) {
            logger.error("textSelectEventHandler", "evt", evt, "textSelectEventHandlerEx", textSelectEventHandlerEx);
        }

        logger.debug("textSelectEventHandler", "Preventing event", "evt", evt);

        return false;
    };

    var objectContains = function (obj, value) {
        for (var sKey in obj) {
            if (obj[sKey] == value) {
                return true;
            }
        }
        return false;
    };

    var keyboardEventHandler = function (e) {

        logger.debug("keyboardEventHandler", "e", e);

        var evt = null;
        var charCode = null;

        try {
            evt = (e) ? e : window.event;

            if (evt === null) {
                evt = this.ownerDocument.parentWindow.event || this.parentWindow.event; /*IE doesn't capture scope correctly*/
            }

            logger.debug("keyboardEventHandler", "evt", evt);

            charCode = evt.keyCode || evt.which;

            logger.debug("keyboardEventHandler", "charCode", charCode);

            if (objectContains(keyOverrides, charCode)) {
                if (!shouldAllowKey(charCode, evt)) {
                    try {
                        evt.keyCode = 0;

                    } catch (evtkeyCodeEx) {
                        logger.error("keyboardEventHandler", "shouldAllowKey", "evt", evt, "evtkeyCodeEx", evtkeyCodeEx);
                    }
                    return false;
                }
            }

            isBackspaceKey(evt);

        } catch (keyboardEventHandlerEx) {
            logger.error("keyboardEventHandler", "keyboardEventHandlerEx", keyboardEventHandlerEx);
        }

        return true;
    };

    var getWindowEvent = function (e) {
        var evt = null;
        var charCode = null;

        try {
            evt = (e) ? e : window.event;

            logger.debug("getWindowEvent", "evt", evt);

            if (evt === null) {

                /*IE doesn't capture scope correctly*/

                if (this.ownerDocument.parentWindow) {
                    evt = this.ownerDocument.parentWindow.event;
                }

                if (evt === null) {
                    if (this.parentWindow) {
                        evt = this.parentWindow.event;
                    }
                }
            }

        } catch (isGetWindowEventEx) {
            logger.error("getWindowEvent", "isGetWindowEventEx", isGetWindowEventEx);
        }

        logger.debug("getWindowEvent", "evt", evt);

        return evt;
    };

    var isBackspaceKey = function (e) {

        logger.debug("isBackspaceKey", "e", e);

        var evt = null;
        var charCode = null;

        try {
            evt = getWindowEvent(e);

            logger.debug("isBackspaceKey", "evt", evt);

            if (evt.srcElement) {
                if (evt.srcElement.nodeName == "TEXTAREA" || (evt.srcElement.nodeName == "INPUT" && (evt.srcElement.type.toLowerCase() == "text" || evt.srcElement.type.toLowerCase() == "password"))) {

                    logger.debug("isBackspaceKey", "Allowing event as it happened within input control such as text box, text area, input", evt);

                    return true;
                }
            }

            charCode = evt.keyCode || evt.which;

            logger.debug("isBackspaceKey", "charCode", charCode);

            var backspaceCharCode = 8;

            if (charCode == backspaceCharCode) {

                if (evt.preventDefault) {
                    evt.preventDefault();

                } else {
                    evt.returnValue = false;
                }

                logger.debug("Preventing Backspace Key based navigation", "evt", evt);
            }

        } catch (isBackspaceKeyEx) {
            logger.error("isBackspaceKey", "isBackspaceKeyEx", isBackspaceKeyEx);
        }

        logger.debug("isBackspaceKey", "Backspace not detected. Allowing event", "evt", evt);

        return true;
    };

    var shouldAllowKey = function (c, e) {

        logger.debug("shouldAllowKey", "c", c, "e", e);

        try {

            var ctrlKeys = { "F": keys.F, "S": keys.S, "H": keys.H, "L": keys.L, "O": keys.O, "E": keys.E, "N": keys.N, "R": keys.R, "D": keys.D, "B": keys.B };
            var altKeys = { "RIGHTARROW": keys.RIGHTARROW, "LEFTARROW": keys.LEFTARROW, "BKSP": keys.BKSP, "HOME": keys.HOME, "Z": keys.Z };

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

            if (e.altKey && c == keys.F12) {

                logger.debug("shouldAllowKey", "Developer tools opening! added alert will not work without it? for developers");

                alert('Developer tools opening!');

                return true;
            }

            // FUNCTION KEYS ETC
            switch (c) {
                case keys.F2:
                    return true;

                case keys.F3:
                    return true;

                case keys.F4:
                    return true;

                case keys.F5:
                    try {
                        DesktopWindow().location.reload();
                    } catch (shouldAllowKeyEx) {
                        logger.error("shouldAllowKey", "shouldAllowKeyEx", shouldAllowKeyEx);
                    }
                    break;

                case keys.F6:
                    return true;

                case keys.F7:
                    return true;

                case keys.F8:
                    return true;

                case keys.F9:
                    return true;

                case keys.F11:
                    return false;

                case keys.F12:
                    return false;

                default:
                    return true;
            }

        } catch (shouldAllowKeyEx) {
            logger.error("shouldAllowKey", "shouldAllowKeyEx", shouldAllowKeyEx);
        }

        return false;
    };

    var processFramesToStopEvents = function (frames) {

        var HasFrameBeenProcessed = "noEventsHasFrameBeenProcessed";
        var HasDocumentBeenProcessed = "noEventsHasDocumentBeenProcessed";

        try {
            ICW.util.processFramesUsingTopFrame(frames, 
            function(frame) {
                if (frame[HasFrameBeenProcessed] == undefined) {

                    frame[HasFrameBeenProcessed] = true;

                    logger.debug("processFramesToStopEvents", "adding load event handler to the frame so if it refreshes, it can be processed again to stop events, readystatechange can't be used as the it will be lost during document refresh ");

                    ICW.util.addEvent(frame, 'load', processWindow);
                }
            },
            function (frameWindow, frameDocument) {

                if (frameDocument[HasDocumentBeenProcessed] == undefined) {

                    frameDocument[HasDocumentBeenProcessed] = true;

                    frameDocument.oncontextmenu = noEvent;
                    frameDocument.onhelp = noEvent;
                    frameDocument.onselectstart = textSelectEventHandler; //  7Apr15 XN 115431 frameDocument.onselectstart = noEvent;

                    logger.debug("processFramesToStopEvents", "adding propertychange event handler to the frame so if new elements are added it can be processed again to stop events");

                    ICW.util.addEvent(frameDocument, "propertychange", processWindow);

                    ICW.util.documentReady(frameWindow, frameDocument, function (documentToWait) {

                        return function() {

                            logger.debug("processFramesToStopEvents", "binding to document body event at", documentToWait.location);

                            ICW.util.addEvent(documentToWait.body, "keydown", keyboardEventHandler, true);

                            ICW.util.addEvent(documentToWait.body, "dragstart", noEvent, true);

                            ICW.util.addEvent(documentToWait.body, "drop", noEvent, true);
                        };

                    } (frameDocument));                    
                }
            });

        } catch (processFramesToStopEventsEx) {
            logger.error("processFramesToStopEvents", "processFramesToStopEventsEx", processFramesToStopEventsEx);
        }
    };

    var processWindow = function () {

        try {
            logger.debug("processWindow");

            processFramesToStopEvents(window);
        } catch (processWindowEx) {
            logger.error("processWindow", "processWindowEx", processWindowEx);
        }
    };

    processWindow();

    logger.debug("Finished Loading");

    //external api:
    return {
        load: processWindow,
        noIEEvent: noEvent,
        keyboardEvent: keyboardEventHandler,
        noIEEventOnAllFrames: function (frames) {
            processFramesToStopEvents(frames);
        }
    };
})();
