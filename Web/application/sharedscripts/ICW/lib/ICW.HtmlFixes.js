(function () {

    var logger = window.ICW.MIN.GetLogger(window.location + "-ICW.HtmlFixes.js");

    logger.debug("Library Started loading");

    var fixListSelectionHighlight = function (list, evt) {

        list.document.parentWindow.setTimeout(function () {

            for (var i = 0; i < list.options.length; i++) {

                var style = list.options[i].style;

                    style.backgroundColor = style.backgroundColor;
                }
            });
    };

    var processFramesToFixHtml = function (frames) {

        var HasFrameBeenProcessed = "HtmlFixesHasFrameBeenProcessed";
        var HasDocumentBeenProcessed = "HtmlFixesHasDocumentBeenProcessed";
        var HasSelectBeenProcessed = "HtmlFixesHasSelectBeenProcessed";

        try {
            ICW.util.processFramesUsingTopFrame(frames,
                function (frame) {
                    if (frame[HasFrameBeenProcessed] == undefined) {

                        frame[HasFrameBeenProcessed] = true;

                        logger.debug("processFramesToFixHtml", "adding load event handler to the frame so if it refreshes, it can be processed again to stop events, readystatechange can't be used as the it will be lost during document refresh ");

                        ICW.util.addEvent(frame, 'load', processWindow);
                    }
                },
                function (frameWindow, frameDocument) {

                    if (frameDocument[HasDocumentBeenProcessed] == undefined) {

                        frameDocument[HasDocumentBeenProcessed] = true;

                        logger.debug("processFramesToFixHtml", "adding propertychange event handler to the frame so if new elements are added it can be processed again");

                        ICW.util.addEvent(frameDocument, "propertychange", processWindow);

                        ICW.util.documentReady(frameWindow, frameDocument, function (documentToWait) {

                            return function () {

                                logger.debug("processFramesToFixHtml", "processing document select on change event at", documentToWait.location);

                                var lists = documentToWait.getElementsByTagName("select");

                                for (var i = 0; i < lists.length; i++) {

                                    var list = lists[i];

                                    if (list[HasSelectBeenProcessed] == undefined) {
                                        list[HasSelectBeenProcessed] = true;

                                        ICW.util.addEvent(list, "keydown", function (listToFix) {
                                            return function (evt) {
                                                fixListSelectionHighlight(listToFix, evt);
                                            };
                                        } (list), true);
                                    }
                                }
                            };
                        } (frameDocument));
                    }
                });

        } catch (processFramesToFixHtmlEx) {
            logger.error("processFramesToFixHtml", "processFramesToFixHtmlEx", processFramesToFixHtmlEx);
        }
    };

    var processWindow = function () {

        try {
            logger.debug("processWindow");

            processFramesToFixHtml(window);
        } catch (processWindowEx) {
            logger.error("processWindow", "processWindowEx", processWindowEx);
        }
    };

    processWindow();

    logger.debug("Finished Loading");

    if (window.ICW == undefined) {
        window.ICW = {};
    }

    window.ICW.HtmlFixes = {};

})();