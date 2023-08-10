/// <reference path="../icw.js" />
/// <reference path="../lib/json2.js" />
/* 
Required 
*/

/* 
Clinical Module
*/

window.ICW = (window.ICW || {});

ICW.clinical = (function () {

    var jsonLibLocation = "application/sharedscripts/lib/json2.js";

    function LoadJSONLibrary() {
        //JSON functionality is integrated into IE8+ this script provides for IE7
        if (typeof (window.JSON) == "undefined") {
            loadJS("../../" + jsonLibLocation);
        }

        return window.JSON;
    }

    LoadJSONLibrary();

    function IsInTestRig() {
        return String(window.top.location).toUpperCase().indexOf("TESTRIG.ASPX") !== -1;
    }

    var NullLogger = {
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

    function GetLogger(logger) {
        /// <summary>
        /// Returns an instance of the icw server logger.
        /// </summary>
        /// <returns type="log4javascript.Logger" />

        var loggerToReturn = null;

        if (!IsInTestRig()) {
            loggerToReturn = logger(window.location.pathname + "-ClinicalModules.js");
        } else {
            loggerToReturn = NullLogger;
        }

        return loggerToReturn;
    }

    return {
        LoadJSONLibrary: LoadJSONLibrary,
        Mutex: ICWGetMutex(undefined, true),
        UserActionAuditServerLogger: GetLogger(function (loggerName) { return ICWGetUserActionAuditServerLogger(loggerName); }),
        ServerLogger: GetLogger(function (loggerName) { return ICWGetAppServerLogger(loggerName); }),
        ClientLogger: GetLogger(function (loggerName) { return ICWGetAppLogger(); })
    };
})();

ICW.clinical.apiCallDetails = function () {
    var _apiCalledDateTime = new Date(Date.now());
    var _patientContextCheckTimer = null;
    var _watch = new Watch("ICW.clinical.apiCallDetails");

    _watch.Start();

    this.GetApiCalledDateTime = function () {
        return _apiCalledDateTime;
    };
    this.Reset = function () {
        this.ResetPatientContextCheckTimer();

        _watch.Reset();
    };
    this.ResetPatientContextCheckTimer = function () {
        if (_patientContextCheckTimer) {
            clearTimeout(_patientContextCheckTimer);
        }
    };
    this.StartPatientContextCheckTimer = function (functionToCallOnTimeout, howOftenInMilliseconds) {

        if (!_watch.IsRunning) {
            _watch.Start();
        }

        this.ResetPatientContextCheckTimer();

        _patientContextCheckTimer = setTimeout(functionToCallOnTimeout, howOftenInMilliseconds);
    };
    this.Elapsed = function (milliSecondsElapsed) {
        return _watch.Elapsed(milliSecondsElapsed);
    };
    this.IsRunning = function () {
        return _patientContextCheckTimer != undefined;
    }
};

/* Clinical Episode */
ICW.clinical.episode = (function () {

    // Private Variables
    var jsonURL = "../sharedscripts/ClinicalModules/EpisodeEventHelper.ashx",
        session = 0,

    // Private Methods

    PatientIdentifier = function (g, v) {
        function PatientIdentifier() {
            this.GUID = String(g) || "";
            this.VersionNumber = Number(v) || 0;
        }

        return new PatientIdentifier();
    };


    function xmlhttpCall(url, method, passData, async) {

        var xhttp = null,
            asyncFlag = async || false,
            response = null;

        xhttp = (window.XMLHttpRequest) ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");

        if (xhttp) {
            xhttp.onreadystatechange = function () {
                if (xhttp.readyState == 4 && xhttp.status == 200) {
                    response = xhttp.responseText;
                }
            };


            xhttp.open(method || "GET", url, asyncFlag);
            xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhttp.send(passData);

            return response;

        } else {
            return false;
        }
    }

    function ajaxCall(url, method, passData) {
        xmlhttpCall(url, method, passData, true);
    }

    function compareObject(o1, o2) {
        for (var p in o1) {
            if (o1[p] !== o2[p]) {
                return false;
            }
        }
        for (var p in o2) {
            if (o1[p] !== o2[p]) {
                return false;
            }
        }
        return true;
    }


    // Initialization
    (function init() {
        addJsonToWindow();
    })();

    function addJsonToWindow() {
        // only call private functions or variables!
        /*
        if (typeof (GetCurrentSessionID) == "function") {
        session = GetCurrentSessionID();
        }
        */
        if (window.top.window.name == "" || typeof (window.top.window.name) != String) {
            var setup = { ICWVID: "", SESSION: session, DATE: null };
            if ((typeof (JSON) != "undefined") && (typeof JSON.stringify == 'function'))//BM15082011 added the check stringify, the method was being called b4 it was created and was giving "object doesnt support this property  or method" error
            {
                window.top.window.name = JSON.stringify(setup);
            }
        }
    }


    //Expose Private Methods / Public Methods
    return {
        //Overload to allow native apps (worklist etc) to indicate that they are native; then we avoid checking for GUID synchronization on receipt of the even
        eventSelectedRaised: function (episode, entity, session, sourceSystem) { /*: Returns Object */
            if (sourceSystem == undefined) sourceSystem = '_unknownsource_';
            addJsonToWindow();
            var tmp = JSON.parse(window.top.window.name);
            tmp.ICWVID = JSON.parse(xmlhttpCall(jsonURL + "?episode=" + episode + "&session=" + session + "&entity=" + (entity || "") + "&method=rEpisodeSelected", "GET") || {});
            //topWinName = JSON.stringify(tmp);     //AE removed as not referenced anywhere
            tmp.ICWVID.EntityEpisode['sourceSystem'] = sourceSystem;
            return JSON.stringify(tmp.ICWVID);
        }
        ,
        eventSelectedCalled: function (episodeGuid, entityGuid, session, url) { /*: Returns Object */
            return (!url) ? xmlhttpCall(jsonURL + "?episodeguid=" + episodeGuid + "&entityguid=" + entityGuid + "&session=" + session + "&method=eEpisodeSelected", "GET") : xmlhttpCall(url, "GET");
        },

        compareVersionIdentifier: function (currentVID, eventVID) { /*: Returns Bool*/

            try {
                currentVID = typeof (currentVID) === "string" ? JSON.parse(currentVID) : currentVID;
                eventVID = typeof (eventVID) === "string" ? JSON.parse(eventVID) : eventVID;

                /* VID Stored in window.top.window.name - built by raised */
                var CEnVID = currentVID.EntityEpisode.vidEntity.Version,
                    CEpVID = currentVID.EntityEpisode.vidEpisode.Version,
                /* VID Captured by EVENT */
                    EEnVID = eventVID.EntityEpisode.vidEntity.Version,
                    EEpVID = eventVID.EntityEpisode.vidEpisode.Version;

                return (EEnVID < CEnVID || EEpVID < CEpVID) ? false : true;
            }
            catch (e) {
                return false;
            }
        },

        setURL: jsonURL,

        createPatientIdentifier: PatientIdentifier
    };

})();

ICW.clinical.episode.episodeSelected = (function () {

    var opt = {
        "retryLimit": 10,
        "retryCount": 0,
        "delayRetry": 1000, /* 1000 = 1 second */
        "destination": "",
        "raisedVersionIdentifier": null,
        "raisedVersionIdentifierString": "",
        "fnSuccessCallback": null,
        "versionIdentifiersMatched": false,
        "errorMessage": "",
        "suppressSplash": false
    };


    function init(session, pVID, fnSuccessCallBackFunc, destinationSystem) {

        ICW.clinical.ClientLogger.info("init");
        ICW.clinical.ClientLogger.debug("init", "session", session, "pVID", pVID, "fnSuccessCallBackFunc", fnSuccessCallBackFunc, "destinationSystem", destinationSystem);

        if (!pVID) {

            ICW.clinical.ClientLogger.trace("init", "You must raise the version identifier for the event comparison to take place", "pVID", pVID);

            alert("You must raise the version identifier for the event comparison to take place");
        }

        opt.raisedVersionIdentifierString = pVID;
        opt.raisedVersionIdentifier = JSON.parse(pVID);

        ICW.clinical.ClientLogger.trace("init", "opt", opt);

        var destinationSystemName = '_unknowndestination_';

        if (destinationSystem != undefined && destinationSystem != null) {

            destinationSystemName = destinationSystem.toString().toLowerCase();

            ICW.clinical.ClientLogger.trace("init", "DestinationSystem has been passed in hence going to use it,", "destinationSystemName", destinationSystemName);

        } else {
            ICW.clinical.ClientLogger.trace("init", "DestinationSystem has not been passed in,", "destinationSystemName", destinationSystemName);
        }

        if (destinationSystemName == sourceSystemFromVID(opt.raisedVersionIdentifier)) {

            ICW.clinical.ClientLogger.trace("init", "if raised and received by the same system, (such as from a HAP work list to the HAP patient banner)- don't bother checking for GUID sync as it's all in the same database!");

            fnSuccessCallBackFunc(opt.raisedVersionIdentifier);
        }
        else {

            ICW.clinical.ClientLogger.trace("init", "source and destination systems are different, or we don't know = check that the GUID we have matches one on the server");

            opt.destination = "../sharedscripts/ClinicalModules/EpisodeEventHelper.ashx?" + "episodeguid=" + opt.raisedVersionIdentifier.EntityEpisode.vidEpisode.GUID + "&entityguid=" + opt.raisedVersionIdentifier.EntityEpisode.vidEntity.GUID + "&session=" + session + "&method=eEpisodeSelected";
            opt.fnSuccessCallback = fnSuccessCallBackFunc;

            if (ICW.clinical.patientContextCheck.ShouldStopUserWhenRecordExistsAtAnIncorrectVersionInHAP()) {

                ICW.clinical.ClientLogger.trace("init", "checking whether HAP has latest patient record");

                if (!opt.suppressSplash) {

                    ICW.clinical.ClientLogger.trace("init", "showing splash before making request to the HAP server for current patient context");

                    try {
                        ICWSimpleSplash_Initialise();
                        ICWSimpleSplash_Show('Loading...', startEventRequest);
                    } catch (e) {

                        ICW.clinical.ClientLogger.trace("init", "error while showing splash before making request to the HAP server for current patient context", "e", e);

                        startEventRequest();
                    }
                }
                else {

                    ICW.clinical.ClientLogger.trace("init", "suppressing showing splash before making request to the HAP server for current patient context");

                    startEventRequest();
                }
            } else {

                ICW.clinical.ClientLogger.trace("init", "Not going to check whether raised patient context matches HAP patient context", "opt.raisedVersionIdentifier", opt.raisedVersionIdentifier);

                ICW.clinical.ClientLogger.trace("init", "Going to execute success function", "opt.fnSuccessCallback", opt.fnSuccessCallback, "opt.raisedVersionIdentifier", opt.raisedVersionIdentifier);

                opt.fnSuccessCallback(opt.raisedVersionIdentifier);
            }

        }

    }

    //Receiving Events call this to determine if the VID was sent from an ICW app, or an integrated one.
    function sourceSystemFromVID(vid) {

        ICW.clinical.ClientLogger.info("startEventRequest");
        ICW.clinical.ClientLogger.debug("startEventRequest", "vid", vid);

        try {
            return vid.EntityEpisode.sourceSystem.toString().toLowerCase();
        } catch (e) {
            ICW.clinical.ClientLogger.error("sourceSystemFromVID", "vid", vid, "e", e);
        }

        return '_unknownsource_';
    }

    function startEventRequest() {

        ICW.clinical.ClientLogger.info("startEventRequest");
        ICW.clinical.ClientLogger.debug("startEventRequest");

        //Make sure vars are reset
        opt.ajaxInProgress = false;
        opt.retryCount = 0;
        opt.killRequest = false;

        try {
            ICWSimpleSplash_Hide();
        } catch (e) {

            ICW.clinical.ClientLogger.error("startEventRequest", "Error hiding simple splash", "e", e);
        }

        try {
            eventAjaxCall();
        }
        catch (e) {

            ICW.clinical.ClientLogger.error("startEventRequest", "error calling eventAjaxCall", "e", e);

            splash.option.blnShowSpinner = false;
            splash.option.strMessage = '';
            splash.option.strError = '';
            if (e.Message != undefined) splash.option.strError = e.Message + '\n\n';
            splash.option.strError += 'Try reloading this desktop; if the problem persists, please contact your System Administrator';
            splash.option.strMessage = 'Error occurred retrieving data.';
            splash.openModalSplash(RefreshButtonPressed, CancelButtonPressed, null);
        }
    }

    // Cancel button pressed on Modal Splash
    function CancelButtonPressed() {

        ICW.clinical.ClientLogger.info("CancelButtonPressed");
        ICW.clinical.ClientLogger.debug("CancelButtonPressed");

        splash.cancelModalSplash();

        // No more retries thanks
        opt.retryCount = opt.retryLimit;
    }

    // Refresh button pressed on Modal Splash
    function RefreshButtonPressed() {

        ICW.clinical.ClientLogger.info("RefreshButtonPressed");
        ICW.clinical.ClientLogger.debug("RefreshButtonPressed");

        // Reset retries and start over
        opt.retryCount = 0;
        eventAjaxCall();
    }

    // Called every time we want to check is the entity and episode ids exist at the correct version
    function eventAjaxCall() {

        ICW.clinical.ClientLogger.info("eventAjaxCall");
        ICW.clinical.ClientLogger.debug("eventAjaxCall");

        ICW.clinical.ClientLogger.trace("eventAjaxCall", "opt.retryCount", opt.retryCount, "opt.retryLimit", opt.retryLimit);

        if (opt.retryCount < opt.retryLimit) {

            ICW.clinical.ClientLogger.trace("eventAjaxCall", "checking again whether HAP has latest patient record", "opt.destination", opt.destination);

            var eVidString = ICW.clinical.episode.eventSelectedCalled(null, null, null, opt.destination);

            ICW.clinical.ClientLogger.trace("eventAjaxCall", "latest HAP patient context details", "eVidString", eVidString);

            var eVid = JSON.parse(eVidString);

            if (eVid != null && eVid != undefined && eVid.EntityEpisode != null && eVid.EntityEpisode != undefined) {

                ICW.clinical.ClientLogger.trace("eventAjaxCall", "There is a patient in context in HAP", "raised patient context", opt.raisedVersionIdentifier, "HAP Patient context retrieved", eVid);

                if (ICW.clinical.episode.compareVersionIdentifier(opt.raisedVersionIdentifier, eVid)) {

                    ICW.clinical.ClientLogger.trace("eventAjaxCall", "The raised patient context and the patient context in HAP match");

                    splash.closeModalSplash();
                    opt.versionIdentifiersMatched = true;
                    opt.fnSuccessCallback(eVid);

                } else {

                    ICW.clinical.ClientLogger.trace("eventAjaxCall", "The raised patient context and the patient context in HAP don't match", "HAP patient context", eVid);

                    opt.retryCount++;

                    ICW.clinical.ClientLogger.trace("eventAjaxCall", "Number of times tried checking raised patient context and the patient context in HAP match", "opt.retryCount", opt.retryCount);

                    opt.errorMessage = "\
                                <span style=\"font-weight:bold;\">Entity Guid&nbsp;<\/span><span>" + eVid.EntityEpisode.vidEntity.GUID + "<\/span><br\/> \
                                <span style=\"font-weight:bold;\">Entity Version&nbsp;<\/span><span>" + eVid.EntityEpisode.vidEntity.Version + "<\/span><br\/> \
                                <span style=\"font-weight:bold;\">Entity Description&nbsp;<\/span><span>" + eVid.EntityEpisode.vidEntity.EntityDescription + "<\/span><br\/> \
                                <span style=\"font-weight:bold;\">Episode Guid&nbsp;<\/span><span>" + eVid.EntityEpisode.vidEpisode.GUID + "<\/span><br\/> \
                                <span style=\"font-weight:bold;\">Episode Version&nbsp;<\/span><span>" + eVid.EntityEpisode.vidEpisode.Version + "<\/span><br\/>";

                    ICW.clinical.ClientLogger.trace("eventAjaxCall", "Going to retry checking HAP patient context with delay", "opt.delayRetry", opt.delayRetry);

                    setTimeout(eventAjaxCall, opt.delayRetry);
                }
            } else {

                ICW.clinical.ClientLogger.trace("eventAjaxCall", "There is no patient in context in HAP", "raised patient context", opt.raisedVersionIdentifier, "HAP Patient context retrieved", eVid);

                opt.retryCount++;

                ICW.clinical.ClientLogger.trace("eventAjaxCall", "Number of times tried checking raised patient context and the patient context in HAP match", "opt.retryCount", opt.retryCount);

                opt.errorMessage = "<span>Patient Not Found<\/span><br\/>";

                ICW.clinical.ClientLogger.trace("eventAjaxCall", "Going to retry checking HAP patient context with delay", "opt.delayRetry", opt.delayRetry);

                setTimeout(eventAjaxCall, opt.delayRetry);
            }
        } else {

            ICW.clinical.ClientLogger.trace("eventAjaxCall", "Stopping checking whether HAP has latest patient record");

            // Make splash change to cancel button
            splash.setModalError(opt.errorMessage);

            ICW.clinical.ClientLogger.trace("eventAjaxCall", "Going to show cancel modal");

            splash.cancelModalSplash();
        }

    }

    return {
        option: opt,
        init: init
    };

})();

ICW.clinical.patientContextCheck = (function () {

    var ICWCurrentPatientContextSwitchRequest = null;

    var PatientContextStatusInHAP = {
        EntityRecordMissing: 'EntityRecordMissing',
        EpisodeRecordMissing: 'EpisodeRecordMissing',
        EntityRecordOutOfDate: 'EntityRecordOutOfDate',
        EpisodeRecordOutOfDate: 'EpisodeRecordOutOfDate'
    };

    function ShowPatientContextSwitchWaitingMessageInAWindow() {

        ICW.clinical.ClientLogger.info("ShowPatientContextSwitchWaitingMessageInAWindow");
        ICW.clinical.ClientLogger.debug("ShowPatientContextSwitchWaitingMessageInAWindow");

        var result = ICWGetSettingAsBoolean("ICW", "ClinicalModules", "ShowPatientContextSwitchWaitingMessageInAWindow", "false");

        ICW.clinical.ClientLogger.trace("ShowPatientContextSwitchWaitingMessageInAWindow", "result", result);

        return result;
    }

    function StopUserWhenRecordExistsAtAnIncorrectVersionInHAP() {

        ICW.clinical.ClientLogger.info("StopUserWhenRecordExistsAtAnIncorrectVersionInHAP");
        ICW.clinical.ClientLogger.debug("StopUserWhenRecordExistsAtAnIncorrectVersionInHAP");

        var result = ICWGetSettingAsBoolean("ICW", "ClinicalModules", "StopUserWhenRecordExistsAtAnIncorrectVersionInHAP", "true");

        ICW.clinical.ClientLogger.trace("StopUserWhenRecordExistsAtAnIncorrectVersionInHAP", "result", result);

        return result;
    }

    function GetPatientRecordNotUptoDateWarningMessage() {

        ICW.clinical.ClientLogger.info("GetPatientRecordNotUptoDateWarningMessage");
        ICW.clinical.ClientLogger.debug("GetPatientRecordNotUptoDateWarningMessage");

        var result = ICWGetSetting("ICW", "ClinicalModules", "PatientRecordNotUptoDateWarningMessage", "WARNING: Patient details may be out of date");

        ICW.clinical.ClientLogger.trace("GetPatientRecordNotUptoDateWarningMessage", "result", result);

        return result;
    }

    function GetPatientRecordNotFoundWarningMessage() {

        ICW.clinical.ClientLogger.info("GetPatientRecordNotFoundWarningMessage");
        ICW.clinical.ClientLogger.debug("GetPatientRecordNotFoundWarningMessage");

        var result = ICWGetSetting("ICW", "ClinicalModules", "PatientRecordNotFoundWarningMessage", "WARNING: Patient details not available, please contact system administrator and check local screens for correct patient");

        ICW.clinical.ClientLogger.trace("GetPatientRecordNotFoundWarningMessage", "result", result);

        return result;
    }

    function ShowPatientContextStatusInHAPMessage(patientContextSwitchDetails) {

        var icwNotificationMessageDetails = ICWGetICWNotificationMessageDetails(patientContextSwitchDetails.callerWindow);

        switch (patientContextSwitchDetails.patientContextStatusInHAP) {
            case PatientContextStatusInHAP.EntityRecordMissing:
            case PatientContextStatusInHAP.EpisodeRecordMissing:
                {
                    icwNotificationMessageDetails.Message = GetPatientRecordNotFoundWarningMessage();
                }
                break;
            case PatientContextStatusInHAP.EntityRecordOutOfDate:
            case PatientContextStatusInHAP.EpisodeRecordOutOfDate:
                {
                    icwNotificationMessageDetails.Message = GetPatientRecordNotUptoDateWarningMessage();
                }
                break;
        }

        icwNotificationMessageDetails.Type = ICWNotificationMessageType.WARNING;

        var notificationButtonDetails = ICWGetICWNotificationMessageButtonDetails();
        notificationButtonDetails.Name = "Retry Setting Patient Record In Context";
        notificationButtonDetails.OnClick = GetRetryPatientContextSwitchFunc(patientContextSwitchDetails);
        icwNotificationMessageDetails.ButtonsDetails.push(notificationButtonDetails);

        ICWShowMessageInNotificationBar(icwNotificationMessageDetails);
    }

    function GetRetryPatientContextSwitchFunc(patientContextSwitchDetailsToUse) {

        var strEntityGuid = patientContextSwitchDetailsToUse.entityGuidToPutIntoContext;
        var strEpisodeGuid = patientContextSwitchDetailsToUse.episodeGuidToPutIntoContext;
        var strEntityVersion = patientContextSwitchDetailsToUse.entityVersionToPutIntoContext;
        var strEpisodeVersion = patientContextSwitchDetailsToUse.episodeVersionToPutIntoContext;

        return function () {
            if (strEntityGuid && strEpisodeGuid) {
                SetState_EntityAndEpisode(strEntityGuid, strEpisodeGuid, strEntityVersion, strEpisodeVersion);
            } else {
                SetState_Entity(strEntityGuid, strEntityVersion);
            }
        };
    }

    function EnsurePatientContextSwitch(patientContextSwitchDetails) {

        ICW.clinical.Mutex.lock(function () {

            ICWCloseNotificationBar(patientContextSwitchDetails.callerWindow);

            ICW.clinical.ClientLogger.info("EnsurePatientContextSwitch");
            ICW.clinical.ClientLogger.debug("EnsurePatientContextSwitch", "patientContextSwitchDetails", patientContextSwitchDetails);

            var json = ICW.clinical.LoadJSONLibrary();

            var ep = null;

            try {
                var NoPatientContextInICW = "";
                var currentPatientContextInICW = GetState_EntityEpisodeJson();
                if (currentPatientContextInICW != NoPatientContextInICW) {
                    ep = json.parse(currentPatientContextInICW);
                }
            } catch (e) {
                ICW.clinical.ClientLogger.error("EnsurePatientContextSwitch", "patientContextSwitchDetails", patientContextSwitchDetails, "e", e);
            }

            if (ep && typeof ep == "object") {
                if (patientContextSwitchDetails.episodeGuidToPutIntoContext != undefined && ep.EntityEpisode.vidEpisode.GUID.toLowerCase() != patientContextSwitchDetails.episodeGuidToPutIntoContext.toLowerCase()) {
                    patientContextSwitchDetails.patientContextStatusInHAP = PatientContextStatusInHAP.EpisodeRecordMissing;
                    ShowPatientContextSwitchMessageAndSchedulePatientContextSet(patientContextSwitchDetails);
                } else {
                    if (patientContextSwitchDetails.entityGuidToPutIntoContext != undefined && ep.EntityEpisode.vidEntity.GUID.toLowerCase() != patientContextSwitchDetails.entityGuidToPutIntoContext.toLowerCase()) {
                        patientContextSwitchDetails.patientContextStatusInHAP = PatientContextStatusInHAP.EntityRecordMissing;
                        ShowPatientContextSwitchMessageAndSchedulePatientContextSet(patientContextSwitchDetails);
                    } else {
                        if (patientContextSwitchDetails.episodeVersionToPutIntoContext != undefined && ep.EntityEpisode.vidEpisode.Version != patientContextSwitchDetails.episodeVersionToPutIntoContext) {
                            patientContextSwitchDetails.patientContextStatusInHAP = PatientContextStatusInHAP.EpisodeRecordOutOfDate;
                            ShowPatientContextSwitchMessageAndSchedulePatientContextSet(patientContextSwitchDetails);
                        } else {
                            if (patientContextSwitchDetails.entityVersionToPutIntoContext != undefined && ep.EntityEpisode.vidEntity.Version != patientContextSwitchDetails.entityVersionToPutIntoContext) {
                                patientContextSwitchDetails.patientContextStatusInHAP = PatientContextStatusInHAP.EntityRecordOutOfDate;
                                ShowPatientContextSwitchMessageAndSchedulePatientContextSet(patientContextSwitchDetails);
                            } else {
                                ClosePatientContextSwitchMessage(patientContextSwitchDetails.clinicalModulesApiCallDetails);
                            }
                        }
                    }
                }
            } else {
                if (patientContextSwitchDetails) {
                    patientContextSwitchDetails.patientContextStatusInHAP = PatientContextStatusInHAP.EntityRecordMissing;
                    ShowPatientContextSwitchMessageAndSchedulePatientContextSet(patientContextSwitchDetails);
                }
            }
        });
    }


    function ShowPatientContextSwitchMessageAndSchedulePatientContextSet(patientContextSwitchDetails) {

        ICW.clinical.ClientLogger.info("ShowPatientContextSwitchMessageAndSchedulePatientContextSet");
        ICW.clinical.ClientLogger.debug("ShowPatientContextSwitchMessageAndSchedulePatientContextSet", "patientContextSwitchDetails", patientContextSwitchDetails);

        if (ShouldContinueCheckingPatientContextSwitch(patientContextSwitchDetails)) {

            if (patientContextSwitchDetails.clinicalModulesApiCallDetails == undefined) {
                patientContextSwitchDetails.clinicalModulesApiCallDetails = new ICW.clinical.apiCallDetails();
            }

            if (ICWCurrentPatientContextSwitchRequest && ICWCurrentPatientContextSwitchRequest != patientContextSwitchDetails.clinicalModulesApiCallDetails) {
                ResetClinicalModulesApiCallDetails(ICWCurrentPatientContextSwitchRequest);
            }

            var contextSwitchMaxDurationMilliseconds = ICWGetSetting("ICW", "ClinicalModules", "ContextSwitchMaxDuration", "10") * 1000;

            if (patientContextSwitchDetails.clinicalModulesApiCallDetails.Elapsed(contextSwitchMaxDurationMilliseconds)) {
                SwitchToPatientNotFoundState(patientContextSwitchDetails);
            } else {
                StartPatientContextSwitchCheck(patientContextSwitchDetails);
            }
        }
    }

    function SwitchToPatientNotFoundState(patientContextSwitchDetails) {

        ICW.clinical.ClientLogger.info("SwitchToPatientNotFoundState");
        ICW.clinical.ClientLogger.debug("SwitchToPatientNotFoundState", "patientContextSwitchDetails", patientContextSwitchDetails);

        splash.lock(function () {

            var errorMessage = "Record not found";

            var errorTitle = "Record Not Found";

            switch (patientContextSwitchDetails.patientContextStatusInHAP) {
                case PatientContextStatusInHAP.EntityRecordOutOfDate:
                    errorTitle = "Patient details out of date";
                    errorMessage = ICWGetSetting("ICW", "ClinicalModules", "OutOfDatePatientRecordMessage", "The record for this patient is out of date, please report to your administrator.");
                    break;
                case PatientContextStatusInHAP.EpisodeRecordOutOfDate:
                    errorTitle = "Episode details out of date";
                    errorMessage = ICWGetSetting("ICW", "ClinicalModules", "OutOfDateEpisodeRecordMessage", "The record for this episode is out of date, please report to your administrator.");
                    break;
                case PatientContextStatusInHAP.EntityRecordMissing:
                    errorTitle = "Patient record not found";
                    errorMessage = ICWGetSetting("ICW", "ClinicalModules", "MissingPatientRecordMessage", "The record for this patient could not be found, please report to your administrator.");
                    break;
                case PatientContextStatusInHAP.EpisodeRecordMissing:
                    errorTitle = "Episode record not found";
                    errorMessage = ICWGetSetting("ICW", "ClinicalModules", "MissingEpisodeRecordMessage", "The record for this episode could not be found, please report to your administrator.");
                    break;
            }

            splash.option.ptrWindow = ICWWindow();
            splash.option.strErrorTitle = errorTitle;
            splash.option.blnShowAsWindow = true;
            splash.option.strError = errorMessage;
            splash.option.blnShowSpinner = false;
            splash.option.strErrorDetails = ICWWindow().String.format("Please click on this message to copy it.<br/> Entity Guid: {0} <br/> Entity Version: {1} <br /> Episode Guid: {2} <br/> Episode Version: {3} <br/> DateTime Api Called: {4} {5}",
                                                                patientContextSwitchDetails.entityGuidToPutIntoContext,
                                                                patientContextSwitchDetails.entityVersionToPutIntoContext,
                                                                patientContextSwitchDetails.episodeGuidToPutIntoContext,
                                                                patientContextSwitchDetails.episodeVersionToPutIntoContext,
                                                                patientContextSwitchDetails.clinicalModulesApiCallDetails.GetApiCalledDateTime().toDateString(),
                                                                patientContextSwitchDetails.clinicalModulesApiCallDetails.GetApiCalledDateTime().toTimeString());
            splash.option.strMessage = "";

            if (!StopUserWhenRecordExistsAtAnIncorrectVersionInHAP()) {
                splash.option.strAcceptButtonText = "Accept and continue";
                splash.option.fnAcceptCallback = function () {
                    ICW.clinical.Mutex.lock(function () {
                        var message = ICWWindow().String.format("User has chosen to proceed when the patient record could not be put into context with the following details. Entity Guid: {0}, Episode Version: {1}, Entity Guid: {2}, Episode Version: {3}",
                                                                 patientContextSwitchDetails.entityGuidToPutIntoContext,
                                                                 patientContextSwitchDetails.entityVersionToPutIntoContext,
                                                                 patientContextSwitchDetails.episodeGuidToPutIntoContext,
                                                                 patientContextSwitchDetails.episodeVersionToPutIntoContext);
                        ICW.clinical.ClientLogger.warn(message);
                        ICW.clinical.UserActionAuditServerLogger.warn(message);
                        ShowPatientContextStatusInHAPMessage(patientContextSwitchDetails);
                        CancelPatientContextSwitchCheck(patientContextSwitchDetails);
                    });
                };
            }

            splash.option.strRefreshButtonText = "Try again";
        });

        OpenPatientContextSwitchMessage(patientContextSwitchDetails, function () {
            ICW.clinical.Mutex.lock(function () {
                CancelPatientContextSwitchCheck(patientContextSwitchDetails);
                EnsurePatientContextSwitch(patientContextSwitchDetails);
            });
        });

        splash.switchIntoCancelDisplayMode();
    }

    function StartPatientContextSwitchCheck(patientContextSwitchDetails) {

        ICW.clinical.ClientLogger.info("StartPatientContextSwitchCheck - Begin");
        ICW.clinical.ClientLogger.debug("StartPatientContextSwitchCheck - Begin", "patientContextSwitchDetails", patientContextSwitchDetails);

        ICWCurrentPatientContextSwitchRequest = patientContextSwitchDetails.clinicalModulesApiCallDetails;

        splash.lock(function () {
            ICW.clinical.ClientLogger.trace("StartPatientContextSwitchCheck", "Started Setting Splash settings", "patientContextSwitchDetails", patientContextSwitchDetails);

            splash.option.ptrWindow = ICWWindow();
            splash.option.blnShowAsWindow = ShowPatientContextSwitchWaitingMessageInAWindow();
            splash.option.blnRemoveMenuAccesskeysWhileShowing = true;
            splash.option.strCancelButtonText = "Clear Selected " + (patientContextSwitchDetails.episodeGuidToPutIntoContext == undefined ? "Patient" : "Episode");
            splash.option.strErrorTitle = "";
            splash.option.strError = "";
            splash.option.strMessage = ICWGetSetting("ICW", "ClinicalModules", "UnsucessfulEntityOrEpsiodeContextSwitchMessage", "Please wait! Waiting for Patient Context to switch successfully.");
            splash.option.strAcceptButtonText = "";
            splash.option.strRefreshButtonText = "";

            ICW.clinical.ClientLogger.trace("StartPatientContextSwitchCheck", "Finished Setting Splash settings", "patientContextSwitchDetails", patientContextSwitchDetails);
        });

        OpenPatientContextSwitchMessage(patientContextSwitchDetails);

        patientContextSwitchDetails.clinicalModulesApiCallDetails.StartPatientContextCheckTimer(function () { patientContextSwitchDetails.setPatientContextDelegate(patientContextSwitchDetails.clinicalModulesApiCallDetails); }, 1000);

        ICW.clinical.ClientLogger.debug("StartPatientContextSwitchCheck - Finish", "patientContextSwitchDetails", patientContextSwitchDetails);
        ICW.clinical.ClientLogger.info("StartPatientContextSwitchCheck - Finish");
    }

    function CancelPatientContextSwitchCheck(patientContextSwitchDetails) {

        ICW.clinical.ClientLogger.info("CancelPatientContextSwitchCheck");
        ICW.clinical.ClientLogger.debug("CancelPatientContextSwitchCheck", "patientContextSwitchDetails", patientContextSwitchDetails);

        ClearPatientContextCheckTimer(patientContextSwitchDetails.clinicalModulesApiCallDetails);

        patientContextSwitchDetails.clinicalModulesApiCallDetails = undefined;

        ClosePatientContextSwitchMessage(patientContextSwitchDetails.clinicalModulesApiCallDetails);
    }

    function ClearPatientContextInHAP() {

        ICW.clinical.ClientLogger.info("ClearPatientContextInHAP");
        ICW.clinical.ClientLogger.debug("ClearPatientContextInHAP");

        ClearEpisode();

        function RAISE_EpisodeCleared(msg) {
            ICWEventRaise();
        }

        RAISE_EpisodeCleared("Unable to set patient context");

        if (window.EVENT_EpisodeCleared != undefined) {
            window.EVENT_EpisodeCleared();
        }
    }

    function OpenPatientContextSwitchMessage(patientContextSwitchDetails, retryPatientContextSwitchFunc) {

        ICW.clinical.ClientLogger.info("OpenPatientContextSwitchMessage");
        ICW.clinical.ClientLogger.debug("OpenPatientContextSwitchMessage", "patientContextSwitchDetails", patientContextSwitchDetails, "retryPatientContextSwitchFunc", retryPatientContextSwitchFunc);

        splash.openModalSplash(retryPatientContextSwitchFunc, function () {
            ICW.clinical.Mutex.lock(function () {
                CancelPatientContextSwitchCheck(patientContextSwitchDetails);
                ClearPatientContextInHAP();
                ICWCloseNotificationBar(patientContextSwitchDetails.callerWindow);
            });
        });
    }

    function ClosePatientContextSwitchMessage(clinicalModulesApiCallDetails) {

        ICW.clinical.ClientLogger.info("ClosePatientContextSwitchMessage");
        ICW.clinical.ClientLogger.debug("ClosePatientContextSwitchMessage", "clinicalModulesApiCallDetails", clinicalModulesApiCallDetails);

        ResetClinicalModulesApiCallDetails(clinicalModulesApiCallDetails);

        splash.reset();
    }

    function ResetClinicalModulesApiCallDetails(clinicalModulesApiCallDetails) {

        ICW.clinical.ClientLogger.info("ResetClinicalModulesApiCallDetails");
        ICW.clinical.ClientLogger.debug("ResetClinicalModulesApiCallDetails", "clinicalModulesApiCallDetails", clinicalModulesApiCallDetails);

        if (clinicalModulesApiCallDetails) {
            clinicalModulesApiCallDetails.Reset();
        }
    }

    function ClearPatientContextCheckTimer(clinicalModulesApiCallDetails) {

        ICW.clinical.ClientLogger.info("ClearPatientContextCheckTimer");
        ICW.clinical.ClientLogger.debug("ClearPatientContextCheckTimer", "clinicalModulesApiCallDetails", clinicalModulesApiCallDetails);

        if (clinicalModulesApiCallDetails) {
            clinicalModulesApiCallDetails.ResetPatientContextCheckTimer();
        }
    }

    function ShouldContinueCheckingPatientContextSwitch(patientContextSwitchDetails) {

        ICW.clinical.ClientLogger.info("ShouldContinueCheckingPatientContextSwitch");
        ICW.clinical.ClientLogger.debug("ShouldContinueCheckingPatientContextSwitch", "patientContextSwitchDetails");

        var intialCheck = patientContextSwitchDetails.clinicalModulesApiCallDetails == undefined;
        var continueFurtherChecks = intialCheck ? undefined : patientContextSwitchDetails.clinicalModulesApiCallDetails.IsRunning();

        return intialCheck || continueFurtherChecks;
    }

    var stateSwitchDetails = {
        entityGuidToPutIntoContext: undefined,
        episodeGuidToPutIntoContext: undefined,
        entityVersionToPutIntoContext: undefined,
        episodeVersionToPutIntoContext: undefined,
        setPatientContextDelegate: undefined,
        clinicalModulesApiCallDetails: undefined,
        patientContextStatusInHAP: undefined,
        callerWindow: undefined
    };

    var clearPatientContextSwitchDetails = function () {

        if (stateSwitchDetails.clinicalModulesApiCallDetails) {
            stateSwitchDetails.clinicalModulesApiCallDetails.ResetPatientContextCheckTimer();
        }

        stateSwitchDetails.entityGuidToPutIntoContext = undefined;
        stateSwitchDetails.episodeGuidToPutIntoContext = undefined;
        stateSwitchDetails.entityVersionToPutIntoContext = undefined;
        stateSwitchDetails.episodeVersionToPutIntoContext = undefined;
        stateSwitchDetails.setPatientContextDelegate = undefined;
        stateSwitchDetails.clinicalModulesApiCallDetails = undefined;
        stateSwitchDetails.patientContextStatusInHAP = undefined;
        stateSwitchDetails.callerWindow = undefined;
    };

    return {
        ClearStateSwitchDetails: clearPatientContextSwitchDetails,
        EnsureStateSwitch: EnsurePatientContextSwitch,
        ShouldStopUserWhenRecordExistsAtAnIncorrectVersionInHAP: StopUserWhenRecordExistsAtAnIncorrectVersionInHAP,
        StateSwitchDetails: stateSwitchDetails
    };
})();

function CreateEntityEpisodeJson(entityGuid, entityVersion, episodeGuid, episodeVersion, sourceSystem) {
    /// <summary>
    /// Constructs an EntityEpisode JSON string, in the following format:
    ///     Example EntityEpisode JSON string. Note: The sourcesystem, EntityID and EpisodeID are for internal ICW use only.
    /// 
    /// {
    /// "EntityEpisode" : {
    ///     "sourceSystem" : "ICW",
    ///     "vidEpisode" : { 
    ///                         "GUID" : "09CB7DEE-DD56-4378-AECD-E1DD1C54E9AF",
    ///                         "Version" : 1, 
    ///                         "EpisodeID" : 123
    ///                     },
    ///      "vidEntity" : {
    ///                     "GUID" : "DEBD52F7-9CF7-46C3-8B44-688A95B100D0",
    ///                     "Version" : 1, 
    ///                     "EntityID" : 123 
    ///                     }
    ///                 }
    /// }
    /// </summary>
    /// <returns type="String" />
    ICW.clinical.ClientLogger.info("CreateEntityEpisodeJson");
    ICW.clinical.ClientLogger.debug("CreateEntityEpisodeJson", "entityGuid", entityGuid, "entityVersion", entityVersion, "episodeGuid", episodeGuid, "episodeVersion", episodeVersion, "sourceSystem", sourceSystem);

    if (window.ICWWindow) {
        if (window != window.ICWWindow()) {
            return window.ICWWindow().CreateEntityEpisodeJson(entityGuid, entityVersion, episodeGuid, episodeVersion, sourceSystem);
        }
    }

    if (sourceSystem == null) sourceSystem = "";

    return '{"EntityEpisode" : { "sourceSystem" : "' + sourceSystem + '", "vidEpisode" : { "GUID" : "' + episodeGuid + '", "Version" : ' + episodeVersion + ' }, "vidEntity" : { "GUID" : "' + entityGuid + '", "Version" : ' + entityVersion + ' }}}';
}

function GetState_EntityEpisodeJson() {
    /// <summary>
    /// Gets the current ICW entity and episode from session state. 
    /// if there is no entity in session state than itar return empty string.
    /// </summary>
    /// <returns type="String" />
    ICW.clinical.ClientLogger.info("GetState_EntityEpisodeJson");

    if (window.ICWWindow) {
        if (window != window.ICWWindow()) {
            return window.ICWWindow().GetState_EntityEpisodeJson();
        }
    }

    var sessionId = GetCurrentSessionID();
    var url = ICWGetICWV10Location() + "/application/sharedscripts/ClinicalModules/EpisodeEventHelper.ashx?session=" + sessionId + "&method=GetCurrentEntityEpisodeJson";

    var objHttpRequest = (window.XMLHttpRequest) ? new window.XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
    objHttpRequest.open("POST", url, false);
    objHttpRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHttpRequest.send();

    return objHttpRequest.responseText || "";
}


function SetState_EntityAndEpisode(strEntityGuid, strEpisodeGuid, strEntityVersion, strEpisodeVersion, clinicalModulesApiCallDetails, skipEnsureStateSwitch, callerWindow) {
    /// <summary>
    /// Set the current ICW entity and episode into session state. 
    /// Entity and Episode must exist, and the episode must belong to the entity
    /// </summary>
    /// <param name="strEntityGuid"  type="String">
    /// Entity Guid belonging to the patient record.
    /// </param>
    /// <param name="strEpisodeGuid"  type="String">
    /// Episode Guid belonging to the patient's episode record.
    /// </param>
    /// <param name="strEntityVersion"  type="String">
    /// Version of the patient record.
    /// </param>
    /// <param name="strEpisodeVersion"  type="String">
    /// Version of the episode record.
    /// </param>
    ICW.clinical.ClientLogger.info("SetState_EntityAndEpisode");
    ICW.clinical.ClientLogger.debug("SetState_EntityAndEpisode", "strEntityGuid", strEntityGuid, "strEpisodeGuid", strEpisodeGuid, "strEntityVersion", strEntityVersion, "strEpisodeVersion", strEpisodeVersion, "clinicalModulesApiCallDetails", clinicalModulesApiCallDetails);

    if (window.ICWWindow) {
        if (window != window.ICWWindow()) {
            return window.ICWWindow().SetState_EntityAndEpisode(strEntityGuid, strEpisodeGuid, strEntityVersion, strEpisodeVersion, clinicalModulesApiCallDetails, skipEnsureStateSwitch, window);
        }
    }

    var sessionId = GetCurrentSessionID();
    var url = ICWGetICWV10Location() + "/application/sharedscripts/ClinicalModules/EpisodeEventHelper.ashx?episodeguid=" + strEpisodeGuid + "&session=" + sessionId + "&entityguid=" + strEntityGuid + "&method=SetEntityEpisode";

    var objHttpRequest = (window.XMLHttpRequest) ? new window.XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
    objHttpRequest.open("POST", url, false);
    objHttpRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHttpRequest.send();

    var response = objHttpRequest.responseText || "";

    if (!skipEnsureStateSwitch) {
        ICW.clinical.patientContextCheck.ClearStateSwitchDetails();

        var patientContextSwitchDetails = ICW.clinical.patientContextCheck.StateSwitchDetails;
        patientContextSwitchDetails.entityGuidToPutIntoContext = strEntityGuid;
        patientContextSwitchDetails.episodeGuidToPutIntoContext = strEpisodeGuid;
        patientContextSwitchDetails.entityVersionToPutIntoContext = strEntityVersion;
        patientContextSwitchDetails.episodeVersionToPutIntoContext = strEpisodeVersion;
        patientContextSwitchDetails.setPatientContextDelegate = function (clinicalModulesApiCallDetailsToPassToApi) { SetState_EntityAndEpisode(strEntityGuid, strEpisodeGuid, strEntityVersion, strEpisodeVersion, clinicalModulesApiCallDetailsToPassToApi, skipEnsureStateSwitch, callerWindow); };
        patientContextSwitchDetails.clinicalModulesApiCallDetails = clinicalModulesApiCallDetails;
        patientContextSwitchDetails.callerWindow = callerWindow;

        ICW.clinical.patientContextCheck.EnsureStateSwitch(patientContextSwitchDetails);
    }

    return response;
}


function SetState_Entity(strEntityGuid, strEntityVersion, clinicalModulesApiCallDetails, callerWindow) {
    /// <summary>
    /// Set the current ICW entity into session state.
    /// The Entity must exist.
    /// The episode will be automatically set to the lifetime episode of the entity.
    /// </summary>
    /// <param name="strEntityGuid"  type="String">
    /// Entity Guid belonging to the patient record.
    /// </param>
    /// <param name="strEntityVersion"  type="String">
    /// Version of the patient record.
    /// </param>
    ICW.clinical.ClientLogger.info("SetState_Entity");
    ICW.clinical.ClientLogger.debug("SetState_Entity", "strEntityGuid", strEntityGuid, "strEntityVersion", strEntityVersion, "clinicalModulesApiCallDetails", clinicalModulesApiCallDetails);

    if (window.ICWWindow) {
        if (window != window.ICWWindow()) {
            return window.ICWWindow().SetState_Entity(strEntityGuid, strEntityVersion, clinicalModulesApiCallDetails, window);
        }
    }

    var sessionId = GetCurrentSessionID();
    var url = ICWGetICWV10Location() + "/application/sharedscripts/ClinicalModules/EpisodeEventHelper.ashx?session=" + sessionId + "&entityguid=" + strEntityGuid + "&method=SetEntity";

    var objHttpRequest = (window.XMLHttpRequest) ? new window.XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
    objHttpRequest.open("POST", url, false);
    objHttpRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHttpRequest.send();

    var response = objHttpRequest.responseText || "";

    ICW.clinical.patientContextCheck.ClearStateSwitchDetails();

    var patientContextSwitchDetails = ICW.clinical.patientContextCheck.StateSwitchDetails;
    patientContextSwitchDetails.entityGuidToPutIntoContext = strEntityGuid;
    patientContextSwitchDetails.entityVersionToPutIntoContext = strEntityVersion;
    patientContextSwitchDetails.setPatientContextDelegate = function (clinicalModulesApiCallDetailsToPassToApi) { SetState_Entity(strEntityGuid, strEntityVersion, clinicalModulesApiCallDetailsToPassToApi, callerWindow); };
    patientContextSwitchDetails.clinicalModulesApiCallDetails = clinicalModulesApiCallDetails;
    patientContextSwitchDetails.callerWindow = callerWindow;
    
    ICW.clinical.patientContextCheck.EnsureStateSwitch(patientContextSwitchDetails);

    return response;
}

function ClearEpisode() {
    /// <summary>
    /// Clear episode event removes the selected episode and entity from the session state
    /// </summary>
    ICW.clinical.ClientLogger.info("ClearEpisode");
    ICW.clinical.ClientLogger.debug("ClearEpisode");

    if (window.ICWWindow) {
        if (window != window.ICWWindow()) {
            return window.ICWWindow().ClearEpisode();
        }
    }

    var sessionId = GetCurrentSessionID();
    var url = "../sharedscripts/ClinicalModules/EpisodeEventHelper.ashx?session=" + sessionId + "&method=ClearEpisode";

    var objHttpRequest = (window.XMLHttpRequest) ? new window.XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
    objHttpRequest.open("POST", url, false);
    objHttpRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHttpRequest.send();

    var response = objHttpRequest.responseText || "";

    return response;
}

function CanContinueEpisodeContextChange() {
    /// <summary>
    /// Checks with all the running applications whether the episode context can be changed.
    /// </summary>
    ICW.clinical.ClientLogger.info("CanContinueEpisodeContextChange");
    ICW.clinical.ClientLogger.debug("CanContinueEpisodeContextChange");

    if (window.ICWWindow) {
        if (window != window.ICWWindow()) {
            return window.ICWWindow().CanContinueEpisodeContextChange();
        }
    }

    var continueEpisodeChange = true;

    if (!ICWQueryEvent("EpisodeSelected")) {

        continueEpisodeChange =
            confirm("There are unsaved changes in open applications which will be lost if you continue.\r\nPlease confirm you wish to proceed!\r\nPress cancel to check open applications.");

    }

    return continueEpisodeChange;
}