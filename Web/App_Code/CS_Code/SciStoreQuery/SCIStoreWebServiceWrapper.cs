using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Xsl;

using ascribe.interfaces.scistoregeneral;
using ascribe.interfaces.scistorewebservicev41wrapper;

namespace ascribe.interfaces.scistorewebservicewrapper
{
    public class SCIStoreWebServiceWrapper
    {
        private const string MODULE_NAME = "ascribe.interfaces.scistorewebservicewrapper.SCIStoreWebServiceWrapper";
        private const string NOT_IMPLEMENTED_ERROR_MSG = "The interface to SCI Store Version 6 has not been developed yet.";

        const string NO_MATCHES_FOUND_XML = "";

        private bool                            _debugMode = false;
        private int                             _sessionId = -1;
        private SciStoreSettings                _settings;
        private SCIStoreWebServiceV41Wrapper    _SciStoreV41Wrapper;
        private SCIStoreGeneral                 _general = new SCIStoreGeneral();

        public SCIStoreWebServiceWrapper(int SessionId,
                                         bool DebugMode)
        {
            _debugMode = DebugMode;

            _sessionId = SessionId;

            _settings = new SciStoreSettings(SessionId, DebugMode);

            switch (_settings.Version)
            {
                case SciStoreSettings.SciStoreVersion.V4_1:
                    _SciStoreV41Wrapper = new SCIStoreWebServiceV41Wrapper(_settings.DebugMode,
                                                                        _settings.SciStoreUrl,
                                                                        _settings.FriendlyName,
                                                                        _settings.SystemCode,
                                                                        _settings.Location,
                                                                        _settings.Username,
                                                                        _settings.ProxyServerAddress,
                                                                        _settings.ProxyServerUsername,
                                                                        _settings.ProxyServerPassword);
                    break;
                case SciStoreSettings.SciStoreVersion.V6_0:
                    throw new NotImplementedException(NOT_IMPLEMENTED_ERROR_MSG);
            }
        }

        public string QueryPAS(XmlDocument Criteria)
        {
            const string SUB_NAME = MODULE_NAME + ".QueryPAS";

            string returnXml = NO_MATCHES_FOUND_XML;

            try
            {
                if (_debugMode)
                    _general.LogDebug(SUB_NAME, "Criteria XML = " + Criteria.DocumentElement.OuterXml);

                //Read the search parameters from the EpisodeSelector criteria XML
                //13June11   Rams    F0120313 - Update SCIStore query
                string chiNumber = ReadCriteriaParameter(Criteria, "CHI_Number").Replace("%", "");
                string caseNumber = ReadCriteriaParameter(Criteria, "Case_No").Replace("%", "");
                string surname = ReadCriteriaParameter(Criteria, "Surname").Replace("%", "");
                string forename = ReadCriteriaParameter(Criteria, "Forename").Replace("%", "");
                string dob = ReadCriteriaParameter(Criteria, "DOB").Replace("%", "");

                //check that if we have a blank Chi Number and a Blank Hospital number that we have a surname and a forename or dateofbirth to search by.
                if (chiNumber.Length.Equals(0) && caseNumber.Length.Equals(0))
                {
                    if (surname.Length.Equals(0))
                        throw new ApplicationException("You must specify a surname if no CHI number or Hospital number is supplied in the search critera.");
                    else
                        if (forename.Length.Equals(0) && dob.Length.Equals(0))
                            throw new ApplicationException("You must specify a forename or a date of birth when searching by surname.");
                }

                //Call the SCI Store Web Service to query the SCI Store using the parameters 
                //from the EpisodeSelector.
                switch (_settings.Version)
                {
                    case SciStoreSettings.SciStoreVersion.V4_1:
                        returnXml = _SciStoreV41Wrapper.QueryPAS(chiNumber,
                                                                 caseNumber,
                                                                 surname,
                                                                 forename,
                                                                 dob,
                                                                 _settings.IncludeAnonymous);
                        break;
                    case SciStoreSettings.SciStoreVersion.V6_0:
                        throw new NotImplementedException(NOT_IMPLEMENTED_ERROR_MSG);
                }
            }

            catch (Exception e)
            {
                _general.LogError(SUB_NAME, e);

                throw e;
            }

            return returnXml;
        }
        
        public bool Login(string UserName,
                          string Password)
        {
            const string SUB_NAME = MODULE_NAME + ".Login";

            bool loggedOn = false;

            try
            {
                switch (_settings.Version)
                {
                    case SciStoreSettings.SciStoreVersion.V4_1:
                        loggedOn = _SciStoreV41Wrapper.Login(UserName,
                                                             Password);
                        break;
                    case SciStoreSettings.SciStoreVersion.V6_0:
                        throw new NotImplementedException(NOT_IMPLEMENTED_ERROR_MSG);
                }
            }

            catch (Exception e)
            {
                _general.LogError(SUB_NAME, e);

                throw e;
            }

            return loggedOn;
        }

        public void Logout()
        {
            const string SUB_NAME = MODULE_NAME + ".Logout";

            try
            {
                switch (_settings.Version)
                {
                    case SciStoreSettings.SciStoreVersion.V4_1:
                        _SciStoreV41Wrapper.Logout();
                        break;
                    case SciStoreSettings.SciStoreVersion.V6_0:
                        throw new NotImplementedException(NOT_IMPLEMENTED_ERROR_MSG);
                }
            }

            catch (Exception e)
            {
                _general.LogError(SUB_NAME, e);

                throw e;
            }
        }

        private string ReadCriteriaParameter(XmlDocument Criteria, string ParameterName)
        {
            string value = string.Empty;

            XmlNode node = Criteria.DocumentElement.SelectSingleNode("Parameter[@Name='" + ParameterName + "']/@Value");

            if (node != null)
                value = node.Value;

            if (value.Equals("%"))
                value = string.Empty;

            return value;
        }

        public XmlDocument ReadPAS(XmlDocument SelectedEpisode)
        {
            const string SUB_NAME = MODULE_NAME + ".ReadPAS";

            XmlDocument sciStoreData = null;

            try
            {
                string patientId = SelectedEpisode.DocumentElement.Attributes.GetNamedItem("patientId").Value;

                string adtId = string.Empty;

                XmlNode episode = SelectedEpisode.DocumentElement.SelectSingleNode("Episode/@adtId");

                if (episode != null)
                    adtId = episode.Value;

                if (_settings.DebugMode)
                    _general.LogDebug(SUB_NAME, "PatientID = '" + patientId + "' : AdtID = '" + adtId + "'");

                switch (_settings.Version)
                {
                    case SciStoreSettings.SciStoreVersion.V4_1:
                        sciStoreData = _SciStoreV41Wrapper.ReadPAS(patientId, adtId);
                        break;
                    case SciStoreSettings.SciStoreVersion.V6_0:
                        throw new NotImplementedException(NOT_IMPLEMENTED_ERROR_MSG);
                }
            }

            catch (Exception e)
            {
                _general.LogError(SUB_NAME, e);

                throw e;
            }

            return sciStoreData;
        }
    }
}
