<%@ WebHandler Language="C#" Class="Log4JavascriptHelper" %>

using System;
using System.Globalization;
using System.Web;
using System.Web.SessionState;

public class Log4JavascriptHelper : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        const string ICW_EnableJavaScriptLogging = "ICW_EnableJavaScriptLogging";

        bool? doesClientWantToEnableJavascriptLogging = null;

        var clientWantsToEnableJavascriptLoggingValueAvailable =
            context.Request.UrlReferrer != null && context.Request.UrlReferrer.Query.ToLowerInvariant().Contains(ICW_EnableJavaScriptLogging.ToLowerInvariant());

        if (clientWantsToEnableJavascriptLoggingValueAvailable)
        {
            doesClientWantToEnableJavascriptLogging = context.Request.UrlReferrer.Query.ToLowerInvariant().Contains(string.Format("{0}=true", ICW_EnableJavaScriptLogging.ToLowerInvariant()));
        }

        int userSessionId;
        int.TryParse(GetQueryString(context, "SessionID"), out userSessionId);

        if (doesClientWantToEnableJavascriptLogging.HasValue)
        {
            StoreInICWSession(userSessionId, ICW_EnableJavaScriptLogging, doesClientWantToEnableJavascriptLogging);

            context.Session[ICW_EnableJavaScriptLogging] = doesClientWantToEnableJavascriptLogging;
        }
        else
        {
            doesClientWantToEnableJavascriptLogging = GetValueFromICWSession(userSessionId, ICW_EnableJavaScriptLogging);

            if (doesClientWantToEnableJavascriptLogging.HasValue)
            {
                context.Session[ICW_EnableJavaScriptLogging] = doesClientWantToEnableJavascriptLogging;
            }
            else
            {
                doesClientWantToEnableJavascriptLogging = (bool?)context.Session[ICW_EnableJavaScriptLogging];

                StoreInICWSession(userSessionId, ICW_EnableJavaScriptLogging, doesClientWantToEnableJavascriptLogging);
            }
        }

        bool enableJavaScriptLogging;

        if (doesClientWantToEnableJavascriptLogging.HasValue)
        {
            enableJavaScriptLogging = doesClientWantToEnableJavascriptLogging.GetValueOrDefault();
        }
        else
        {
            var serverWantsJavascriptLogging =
                System.Configuration.ConfigurationManager.AppSettings[ICW_EnableJavaScriptLogging];

            bool.TryParse(serverWantsJavascriptLogging, out enableJavaScriptLogging);
        }

        var log4javascriptFile = string.Format("{0}/application/sharedscripts/log4javascript/js/log4javascript.js?v=00.00.00.00", Ascribe.Common.ICW.GetV10Location());

        context.Response.ClearHeaders();
        
        context.Response.Cache.SetETag(DateTime.Now.ToString(CultureInfo.InvariantCulture));
        
        context.Response.ContentType = "application/x-javascript";
        
        context.Response.Cache.SetCacheability(HttpCacheability.Private);
        
        context.Response.Cache.SetExpires(DateTime.MaxValue);
        
        context.Response.Write(string.Format(@"

        // NOTE: Set this variable to false to enable log4javascript logging or set the AppSetting 'ICW_EnableJavaScriptLogging' in the web.config
        // http://log4javascript.org/docs/manual.html#enabling
        var log4javascript_disabled = {0};

        (function() {{

            function addEvent(element, event, fn) {{
                try {{
                    var eventHandler = function() {{
                        var elementWhichFiredTheEvent = element;
                        var eventName = event;

                        fn.apply(this, arguments);

                    }}

                    if (element.addEventListener) {{
                        element.addEventListener(event, eventHandler, false);
                    }} else {{
                        if (element.attachEvent) {{
                            element.attachEvent('on' + event, eventHandler);
                        }};
                    }}
                }}
                catch (addEventEx) {{
                }}
            }};

            var documentReady = function(functionToExecute) {{
                if (document.readyState == 'loading' || document.body == null) {{
                    addEvent(document, 'readystatechange', functionToExecute);
                }}
                else {{
                    functionToExecute();
                }}
            }};

            var loadJS = function (file) {{
                    var script = document.createElement('script');
                    script.src = file;
                    script.type = 'text/javascript';
                    document.getElementsByTagName('head')[0].appendChild(script);
            }};
    
            if(log4javascript_disabled)
            {{
                if(!window.log4javascript)
                {{
                    var getDummyLogger = function() {{
                                return {{
                                    trace: function() {{
                                    }},
                                    debug: function() {{
                                    }},
                                    info: function() {{
                                    }},
                                    warn: function() {{
                                    }},
                                    error: function() {{
                                    }},
                                    fatal: function() {{
                                    }}
                                }};
                            }};

                    window.log4javascript = {{
                        getNullLogger : getDummyLogger,
                        getLogger : getDummyLogger,
                        PopUpAppender : function() {{
                            this.setLayout = function() {{         
                            }};
                        }},
                        PatternLayout : function() {{
                        }}
                    }};
                }}
            }}
            else
            {{   
                var loadLog4javascriptFile = function() {{
                    loadJS('{1}');
                }};

                if(!window.log4javascript) {{
                    // if this page is the top level ICW page
                    if(window.top.ptrICW == window) {{
                       loadLog4javascriptFile();
                    }}
                    else {{
                        // if this page is not a child of top level ICW page
                        if(!window.top.ptrICW){{
                            loadLog4javascriptFile();
                        }}           
                    }}
                }}
            }}
        }})();", (!enableJavaScriptLogging).ToString().ToLower(), log4javascriptFile));

    }

    private static bool? GetValueFromICWSession(int userSessionId, string key)
    {
        bool? value = null;

        if (userSessionId > 0)
        {
            var sessionAttributeValue = Ascribe.Common.Generic.SessionAttribute(
                userSessionId,
                key);

            bool convertedValue;
            bool.TryParse(sessionAttributeValue, out convertedValue);

            value = string.IsNullOrWhiteSpace(sessionAttributeValue) ? (bool?)null : convertedValue;
        }

        return value;
    }

    private static string GetQueryString(HttpContext context, string key)
    {
        string queryStringKey = string.Format("{0}=", key.ToLowerInvariant());

        string value = null;

        if (context.Request.UrlReferrer != null)
        {
            var queryStringToSearch = context.Request.UrlReferrer.Query.ToLowerInvariant();

            var continueKeySearch = true;

            for (var stringToSearchIndex = 0; stringToSearchIndex < queryStringToSearch.Length && continueKeySearch; stringToSearchIndex++)
            {
                for (int keyIndex = stringToSearchIndex, queryStringKeyIndex = 0;
                    keyIndex < queryStringToSearch.Length && queryStringKeyIndex < queryStringKey.Length
                    && continueKeySearch;
                    keyIndex++, queryStringKeyIndex++)
                {
                    if (queryStringToSearch[keyIndex] != queryStringKey[queryStringKeyIndex])
                    {
                        break;
                    }

                    if (queryStringKeyIndex != (queryStringKey.Length - 1))
                    {
                        continue;
                    }

                    keyIndex++;

                    for (var valueIndex = keyIndex;
                         valueIndex < queryStringToSearch.Length && char.IsNumber(queryStringToSearch[valueIndex]);
                         valueIndex++)
                    {
                        value += context.Request.UrlReferrer.Query[valueIndex];
                    }

                    continueKeySearch = false;
                }
            }
        }

        return value;
    }

    private static void StoreInICWSession(int userSessionId, string key, bool? value)
    {
        if (userSessionId > 0)
        {
            Ascribe.Common.Generic.SessionAttributeSet(userSessionId, key, value.HasValue ? value.GetValueOrDefault().ToString() : (string)null);
        }
    }

    public bool IsReusable
    {
        get { return true; }
    }
}