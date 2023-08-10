using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Text;
using System.Web.Configuration;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Xsl;

using GENRTL10;
using Ascribe.EpisodeQuery;

namespace ascribe.interfaces.scistoregeneral
{
    public class SCIStoreGeneral
    {

        public void LogDebug(string SubroutineName, string Msg)
        {
            if (!SubroutineName.EndsWith("()"))
                SubroutineName += "()";

            if (Msg.Length + SubroutineName.Length + 3 > 32766)
                Msg = Msg.Substring(0, 32766 - SubroutineName.Length - 3);

            EventLog ev = new EventLog("Application");

            ev.Source = "SCIStoreQuery";

            ev.WriteEntry(SubroutineName + " : " + Msg, EventLogEntryType.Information, 0, 0);

            ev.Close();

            ev.Dispose();
        }

        public void LogError(string SubroutineName, Exception e)
        {
            if (!SubroutineName.EndsWith("()"))
                SubroutineName += "()";

            Exception temp = e;

            EventLog ev = new EventLog("Application");

            ev.Source = "SCIStoreQuery";

            while (temp != null)
            {
                string entry = SubroutineName + " : " +
                               temp.Message + "\n" +
                               temp.Source + "\n" +
                               temp.StackTrace + "\n";

                if (entry.Length > 32766)
                    entry = entry.Substring(0, 32766);

                ev.WriteEntry(entry,
                              EventLogEntryType.Error);

                temp = temp.InnerException;
            }

            ev.Close();

            ev.Dispose();
        }

        private string ParseFunctions(string argValue)
        {
            string parsed = argValue;

            if (argValue.StartsWith("::"))
            {
                switch (argValue.ToLower())
                {
                    case "::now()":
                        parsed = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss");
                        break;
                    default:
                        throw new ApplicationException("Unknown function found in value attribute - " + argValue);
                }

            }

            return parsed;
        }

        public string TransformXML(string SciStoreXml, 
                                   XmlDocument XsltArguments,
                                   bool DebugMode)
        {
            const string SUB_NAME = "TransformXML";

            string xformedXML = string.Empty;

            XmlDocument srcXml = new XmlDocument();

            srcXml.LoadXml(SciStoreXml);

            string ascXml = "";

            if (srcXml.InnerXml.Length > 0)
            {
                try
                {
                    XsltArgumentList args = new XsltArgumentList();
                    XPathNavigator nav = null;
                    XslCompiledTransform xform = new XslCompiledTransform();

                    //Create the XmlWriter that will hold the transformed XML
                    StringBuilder sb = new StringBuilder();
                    XmlWriter xw = XmlWriter.Create(sb);

                    //needs to do any mapping here prior to transform
                    //PerformMapping(ref srcXml);

                    if (DebugMode)
                    {
                        LogDebug(SUB_NAME, "XML after mapping performed: " + srcXml.OuterXml);
                    }

                    //add any arguments
                    if (XsltArguments.DocumentElement.HasChildNodes)
                    {
                        foreach (XmlNode arg in XsltArguments.DocumentElement.ChildNodes)
                        {
                            args.AddParam(arg.Attributes.GetNamedItem("name").Value,
                                          arg.Attributes.GetNamedItem("namespaceUri").Value,
                                          ParseFunctions(arg.Attributes.GetNamedItem("value").Value));
                        }
                    }

                    //transform the XML
                    nav = srcXml.CreateNavigator();

                    xform.Transform(nav, args, xw);

                    //read the transformed XML from the XmlWriter object using the base StringBuilder object.
                    ascXml = sb.ToString();
                }

                catch (Exception e)
                {
                    throw e;
                }
            }

            xformedXML = ascXml;

            if (DebugMode)
            {
                LogDebug(SUB_NAME, "Transformed message : " + ascXml);
            }

            return xformedXML;
        }
    }

    public class SciStoreSettings
    {
        private const string MODULE_NAME = "ascribe.interfaces.scistoregeneral.Settings";
        private const string SYSTEM_NAME = "EpisodeSelectorQuery";
        private const string SECTION_NAME = "SciStoreQuery";

        private bool            _debugMode;
        private bool            _includeAnonymous;
        private int             _sessionId;
        private SciStoreVersion _version;
        private string          _sciStoreUrl;
        private string          _friendlyName;
        private string          _systemCode;
        private string          _location;
        private string          _username;
        private string          _password;
        private string          _proxyAddress;
        private string          _proxyUsername;
        private string          _proxyPassword;
        private XmlDocument     _argDefinition;

        public enum SciStoreVersion
        {
            V4_1 = 1,
            V6_0 = 2
        }

        public SciStoreSettings(int SessionID,
                                bool DebugMode)
        {
            const string SUB_NAME = MODULE_NAME + ".Settings()";
            try
            {
                _debugMode = DebugMode;

                _sessionId = SessionID;

                ReadSettingsFromWebConfig(DebugMode);
            }

            catch (Exception e)
            {
                SCIStoreGeneral g = new SCIStoreGeneral();

                g.LogError(SUB_NAME, e);

                throw e;
            }
        }

        private void ReadSettingsFromWebConfig(bool DebugMode)
        {
            SettingRead s = new SettingRead();

            string version = s.GetValue(_sessionId,
                                        SYSTEM_NAME,
                                        SECTION_NAME,
                                        "SCIStoreVersion",
                                        string.Empty);

            switch (version.ToUpper())
            {
                case "V4.1":
                    _version = SciStoreVersion.V4_1;
                    break;
                case "V6.0":
                    _version = SciStoreVersion.V6_0;
                    break;
                default:
                    throw new ApplicationException("Invalid value found in the configuration parameter 'SCIStoreVersion'. Valid values are 'V4.1' or 'V6.0'.");
            }

            _sciStoreUrl  = s.GetValue(_sessionId,
                                        SYSTEM_NAME,
                                        SECTION_NAME,
                                        "SciStoreWebServiceUrl",
                                        string.Empty);

            string includeAnon = s.GetValue(_sessionId,
                                        SYSTEM_NAME,
                                        SECTION_NAME,
                                        "IncludeAnonymousRecords",
                                        string.Empty);

            _includeAnonymous = false;

            if (includeAnon.ToUpper().Equals("TRUE"))
                _includeAnonymous = true;

            _systemCode = s.GetValue(_sessionId,
                                        SYSTEM_NAME,
                                        SECTION_NAME,
                                        "SystemCode",
                                        string.Empty);

            _location = s.GetValue(_sessionId,
                                        SYSTEM_NAME,
                                        SECTION_NAME,
                                        "Location",
                                        string.Empty);

            _friendlyName = s.GetValue(_sessionId,
                                        SYSTEM_NAME,
                                        SECTION_NAME,
                                        "FriendlyName",
                                        string.Empty);

            _username = s.GetValue(_sessionId,
                                        SYSTEM_NAME,
                                        SECTION_NAME,
                                        "Username",
                                        string.Empty);

            _password = s.GetValue(_sessionId,
                                   SYSTEM_NAME,
                                   SECTION_NAME,
                                   "Password",
                                   string.Empty);

            _proxyAddress = s.GetValue(_sessionId,
                                        SYSTEM_NAME,
                                        SECTION_NAME,
                                        "ProxyServerAddress",
                                        string.Empty);

            _proxyUsername = s.GetValue(_sessionId,
                                        SYSTEM_NAME,
                                        SECTION_NAME,
                                        "ProxyServerUsername",
                                        string.Empty);

            _proxyPassword = s.GetValue(_sessionId,
                                        SYSTEM_NAME,
                                        SECTION_NAME,
                                        "ProxyServerPassword",
                                        string.Empty);
        }

        public bool DebugMode
        {
            get
            {
                return _debugMode;
            }
        }

        public bool IncludeAnonymous
        {
            get
            {
                return _includeAnonymous;
            }
        }

        public SciStoreVersion Version
        {
            get
            {
                return _version;
            }
        }

        public string SciStoreUrl
        {
            get
            {
                return _sciStoreUrl;
            }
        }

        public string FriendlyName
        {
            get
            {
                return _friendlyName;
            }
        }

        public string SystemCode
        {
            get
            {
                return _systemCode;
            }
        }

        public string Location
        {
            get
            {
                return _location;
            }
        }

        public string Username
        {
            get
            {
                return _username;
            }
        }

        public string Password
        {
            get
            {
                return _password;
            }
        }

        public string ProxyServerAddress
        {
            get
            {
                return _proxyAddress;
            }
        }

        public string ProxyServerUsername
        {
            get
            {
                return _proxyAddress;
            }
        }

        public string ProxyServerPassword
        {
            get
            {
                return _proxyUsername;
            }
        }

        public XmlDocument XsltArguments
        {
            get
            {
                return _argDefinition;
            }
        }
    }
}
