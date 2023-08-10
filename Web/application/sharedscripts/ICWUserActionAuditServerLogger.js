/// <reference path="jquery-1.3.2.js" />

(function (declarationWindow, jQuery, string) {

    var ICWUserActionAuditLogger = null;

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

    function IsInTestRig() {
        return String(window.top.location).toUpperCase().indexOf("TESTRIG.ASPX") !== -1;
    }

    function GetICWUserActionAuditServerLogger() {
        /// <summary>
        /// Returns a singleton instance of the logger.
        /// </summary>
        /// <returns type="log4javascript.Logger" />

        if (ICWUserActionAuditLogger == null) {
            if (!IsInTestRig()) {
                ICWUserActionAuditLogger = declarationWindow.GetICWLogger(window.location.pathname + "-ICWUserActionAuditServerLogger.js");
            } else {
                ICWUserActionAuditLogger = {
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

        return ICWUserActionAuditLogger;
    }

    jQuery(document).ajaxError(function (event, jqXHR, ajaxSettings, thrownError) {
        GetICWUserActionAuditServerLogger().fatal("jQuery(document).ajaxError", jqXHR.responseText);
        GetICWUserActionAuditServerLogger().debug("jQuery(document).ajaxError", jqXHR.responseText, "event", event, "jqXHR", jqXHR, "ajaxSettings", ajaxSettings, "thrownError", thrownError);
    });

    var ICWUserActionAuditServerLogger = function (icwV11Location, sessionId, loggerName,  windowWhichOwnsLogger) {

        var windowWhichOwnsLoggerToUse = windowWhichOwnsLogger || window;

        function SaveLogToServer(vmLogToSave) {

            jQuery.post(string.format("{0}/webapi/UserActionAuditLog/savelog/?sessionId={1}", icwV11Location, sessionId), vmLogToSave, function (data) {
                GetICWUserActionAuditServerLogger().info("done saving user action audit log");
                GetICWUserActionAuditServerLogger().debug("done saving user action audit log", "data", data);
            });

        };

        function Log(level, message) {

            var vmLog = new VMLog();

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

    declarationWindow.ICWUserActionAuditServerLogger = ICWUserActionAuditServerLogger;
})(window, jQuery, String);