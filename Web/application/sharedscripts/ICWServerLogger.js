/// <reference path="jquery-1.3.2.js" />

(function (declarationWindow, jQuery, string) {

    var VMLogEntry = function () {
        this.Date;
        this.DateNumeral;
        this.Thread;
        this.Level;
        this.Logger;
        this.Message;
        this.Exception;
    };

    var VMLog = function () {
        this.SessionId = -1;
        this.IsLoggingEnabled = false;
        this.Entries = [];
    };

    var LogLevel = {
        INFO: "INFO",
        DEBUG: "DEBUG",
        TRACE: "TRACE",
        WARN: "WARN",
        ERROR: "ERROR",
        FATAL: "FATAL"
    };

    var ICWServerLoggerAppLogger = null;

    function IsInTestRig() {
        return String(window.top.location).toUpperCase().indexOf("TESTRIG.ASPX") !== -1;
    }

    function GetICWServerLoggerAppLogger() {
        /// <summary>
        /// Returns a singleton instance of the logger.
        /// </summary>
        /// <returns type="log4javascript.Logger" />

        if (ICWServerLoggerAppLogger == null) {
            if (!IsInTestRig()) {
                ICWServerLoggerAppLogger = declarationWindow.GetICWLogger(window.location.pathname + "-ICWServerLogger.js");
            } else {
                ICWServerLoggerAppLogger = {
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
        }

        return ICWServerLoggerAppLogger;
    }

    jQuery(document).ajaxError(function (event, jqXHR, ajaxSettings, thrownError) {
        GetICWServerLoggerAppLogger().fatal("jQuery(document).ajaxError", jqXHR.responseText);
        GetICWServerLoggerAppLogger().debug("jQuery(document).ajaxError", jqXHR.responseText, "event", event, "jqXHR", jqXHR, "ajaxSettings", ajaxSettings, "thrownError", thrownError);
    });

    var icwServerLogger = function (icwV11Location, sessionId, loggerName, windowWhichOwnsLogger) {

        var windowWhichOwnsLoggerToUse = windowWhichOwnsLogger || window;

        function SaveLogToServer(vmLogToSave) {

            jQuery.post(string.format("{0}/webapi/icwlog/savelog", icwV11Location), vmLogToSave, function (data) {
                GetICWServerLoggerAppLogger().info("done saving to server log");
                GetICWServerLoggerAppLogger().debug("done saving to server log", "data", data);
            });

        };

        function Log(level, message) {

            var vmLog = new VMLog();
            vmLog.SessionId = sessionId;

            var vmLogEntry = new VMLogEntry();
            vmLogEntry.Date = new Date().toJSON();
            vmLogEntry.Logger = loggerName;
            vmLogEntry.Level = level;
            vmLogEntry.Message = message;
            vmLogEntry.Thread = windowWhichOwnsLoggerToUse.location.href.substr(0, 255);

            vmLog.Entries.push(vmLogEntry);

            SaveLogToServer(vmLog);
        };

        return {
            trace: function(message) {
                Log(LogLevel.TRACE, message);
            },

            debug: function(message) {
                Log(LogLevel.DEBUG, message);
            },

            info: function(message) {
                Log(LogLevel.INFO, message);
            },

            warn: function(message) {
                Log(LogLevel.WARN, message);
            },

            error: function(message) {
                Log(LogLevel.ERROR, message);
            },

            fatal: function(message) {
                Log(LogLevel.FATAL, message);
            }
        };
    };

    declarationWindow.ICWServerLogger = icwServerLogger;
})(window, jQuery, String);