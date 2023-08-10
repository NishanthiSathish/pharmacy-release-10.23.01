using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Net;
using System.Text;
using System.Xml;
using System.Xml.Serialization;

using ascribe.interfaces.scistoregeneral;

namespace ascribe.interfaces.scistorewebservicev41wrapper
{
    public class SCIStoreWebServiceV41Wrapper
    {
        private const string MODULE_NAME = "ascribe.interfaces.scistorewebservicev41wrapper.SCIStoreWebServiceV41Wrapper";
        private const string NO_MATCHES_FOUND_XML = "";

        private bool                    _debugMode = false;
        private string                  _sciStoreWebServiceUrl = string.Empty;
        private SCIStoreServicesPort    _webService;
        private OrderedDictionary       _patients = new OrderedDictionary();
        private SCIStoreGeneral         _general = new SCIStoreGeneral();

        public SCIStoreWebServiceV41Wrapper(bool DebugMode,
                                            string WebServiceUrl,
                                            string FriendlyName,
                                            string SystemCode,
                                            string Location,
                                            string Username,
                                            string ProxyServerAddress,
                                            string ProxyServerUserName,
                                            string ProxyServerPassword)
        {

            const string SUB_NAME = MODULE_NAME + ".SCIStoreWebServiceV41Wrapper";

            //N.B. Proxy Server functionality will not be coded in this version. I've included these
            //     parameters in case they are needed in the future.
            _debugMode = DebugMode;

            _sciStoreWebServiceUrl = WebServiceUrl;

            try
            {
                _webService = new SCIStoreServicesPort();

                //set the web service URL
                _webService.Url = _sciStoreWebServiceUrl;

                //instantiate the user redentials
                _webService.UserCredentials = new Credentials();

                //set the credentials
                CredentialsUserInfo creds = new CredentialsUserInfo();

                creds.FriendlyName = FriendlyName;

                creds.SystemCode = SystemCode;

                creds.SystemLocation = Location;

                creds.UserName = Username;

                _webService.UserCredentials.UserInfo = creds;

                if (_debugMode)
                    _general.LogDebug(SUB_NAME, "Instaniated SCIStoreServicesPort V4.1 Class.\n" + 
                                       "URL = '" + _sciStoreWebServiceUrl + "'\n" +
                                       "Location = '" + Location + "'\n" +
                                       "Username = '" + Username + "'\n");
            }

            catch(Exception e)
            {
                _general.LogError(SUB_NAME, e);

                throw e;
            }

        }

        private string SerializeClass(object ToSerialize)
        {
            const string SUB_NAME = MODULE_NAME + ".SerializeClass";

            string returnXml = "Failed to serial object of type " + ToSerialize.GetType();

            try
            {
                StringBuilder sb = new StringBuilder();

                XmlWriter w = XmlWriter.Create(sb);

                XmlSerializer s = new XmlSerializer(ToSerialize.GetType());

                s.Serialize(w, ToSerialize);

                returnXml = sb.ToString();
            }

            catch (Exception e)
            {
                _general.LogError(SUB_NAME, e);

                throw e;
            }

            return returnXml;
        }

        public string QueryPAS(string ChiNumber,
                                        string HospitalNumber,
                                        string Surname,
                                        string Forename,
                                        string DateOfBirth,
                                        bool IncludeAnonymous)
        {
            const string SUB_NAME = MODULE_NAME + ".QueryPAS";

            string queryResults = "";

            try
            {                
                FindADTcriteria c = new FindADTcriteria();

                FindPatientCriteria pc = new FindPatientCriteria();

                FindPatientBasicCriteria bc = new FindPatientBasicCriteria();

                c.PatientDetails = bc;

                FindPatientIDCriteria ids = new FindPatientIDCriteria();

                bc.Ids = ids;

                pc.Ids = ids;

                FindPatientNameCriteria nc = new FindPatientNameCriteria();

                bc.Name = nc;

                pc.Name = nc;

                if (HospitalNumber.Length > 0)
                {
                    ids.ID = HospitalNumber;

                    ids.IDcomparator = SearchComparator.begins;

                    ids.IDcomparatorSpecified = true;
                }

                if (ChiNumber.Length > 0)
                {
                    c.CHI = ChiNumber;

                    ids.ID = ChiNumber;

                    ids.IDcomparator = SearchComparator.equals;

                    ids.IDcomparatorSpecified = true;
                }

                if (Surname.Length > 0)
                {
                    nc.Surname = Surname;

                    nc.SurnameComparator = SearchComparator.begins;

                    nc.SurnameComparatorSpecified = true;
                }

                if (Forename.Length > 0)
                {
                    nc.Forename = Forename;

                    nc.ForenameComparator = SearchComparator.begins;

                    nc.ForenameComparatorSpecified = true;
                }

                if (DateOfBirth.Length > 0)
                {
                    bc.DateOfBirth = DateTime.Parse(DateOfBirth);

                    bc.DateOfBirthSpecified = true;

                    pc.Date = new FindPatientCriteriaDate();
                    
                    pc.Date.DateOfBirth = DateTime.Parse(DateOfBirth);

                    pc.Date.DateOfBirthSpecified = true;
                }

                c.ActionCode = "A";

                if (_debugMode)
                    _general.LogDebug(SUB_NAME, "Calling FindADT with '" + SerializeClass(c) + "'");

                //Search for ADT records in SCIStore. NB: SCIStore only currently has ADT details for In-patients.
                FindADTresponse admissions =  _webService.FindADT(c);

                if (admissions != null)
                {
                    if (_debugMode)
                    {
                        _general.LogDebug(SUB_NAME, "FindADT admissions returned " + admissions.ADTMessages.Length.ToString() + " results.");

                        _general.LogDebug(SUB_NAME, "FindADT returned: " + SerializeClass(admissions));
                    }

                    if (admissions.ADTMessages.Length > 0)
                        ConvertFindAdtResponses(admissions, null, null);
                }

               //Out-patients have not ADT records, so search for demographics
                FindPatientResponse fpr = _webService.FindPatient(pc);

                if (fpr != null)
                {
                    if (_debugMode)
                        _general.LogDebug(SUB_NAME, "FindPatient returned " + fpr.Patients.Length.ToString() + " results.");

                    ConvertFindPatientResponse(fpr);
                }

                //Convert the '' class to XML
                queryResults = SerializePatients();

                if (_debugMode)
                    _general.LogDebug(SUB_NAME, "QueryPAS returns '" + queryResults + "'");
            }

            catch (Exception e)
            {
                _general.LogError(SUB_NAME, e);

                throw e;
            }

            return queryResults;
        }

        private string SerializePatients()
        {
            const string SUB_NAME = MODULE_NAME + ".SerializePatients";

            //Create the XML understood by the EpisodeSelector

            StringBuilder sb = new StringBuilder();

            XmlWriter xw = XmlWriter.Create(sb);

            xw.WriteStartDocument();

            xw.WriteStartElement("root");

            if (_patients != null)
            {
                foreach (DictionaryEntry pat in _patients)
                {
                    Patient p = (Patient)pat.Value;

                    xw.WriteStartElement("Entity");

                    xw.WriteAttributeString("Class", "Entity");

                    xw.WriteAttributeString("RecordID", "0");

                    xw.WriteAttributeString("Description", p.Description);

                    xw.WriteAttributeString("DateText", p.DOB);

                    xw.WriteAttributeString("Status", string.Empty);

                    xw.WriteAttributeString("PatientStatusDescription", string.Empty);

                    xw.WriteAttributeString("CHINumber", p.ChiNumber);

                    xw.WriteAttributeString("patientId", p.PatientID);

                    xw.WriteAttributeString("_isForeign", "1");

                    if (p.episodes.Count > 0)
                    {
                        foreach (DictionaryEntry ep in p.episodes)
                        {
                            Episode e = (Episode)ep.Value;

                            xw.WriteStartElement("Episode");

                            xw.WriteAttributeString("Class", "Episode");

                            xw.WriteAttributeString("RecordID", "0");

                            xw.WriteAttributeString("Description", e.Description);

                            xw.WriteAttributeString("DateText", e.AdmissionDateTime);

                            xw.WriteAttributeString("Status", string.Empty);

                            xw.WriteAttributeString("EpisodeStatusDescription", e.PatientType);

                            xw.WriteAttributeString("EpisodeID_Parent", "0");

                            xw.WriteAttributeString("adtId", e.EpisodeID);

                            xw.WriteAttributeString("EpisodeNumber", e.EpisodeNumber);

                            xw.WriteAttributeString("_isForeign", "1");

                            xw.WriteEndElement();
                        }
                    }

                    xw.WriteEndElement();
                }
            }

            xw.WriteEndElement();

            xw.WriteEndDocument();

            xw.Flush();

            string returnXml = sb.ToString();

            if (_debugMode)
                _general.LogDebug(SUB_NAME, "EpisodeSelector XML : " + returnXml);

            return returnXml;
        }

        private void ConvertFindPatientResponse(FindPatientResponse fpr)
        {
            foreach (FindPatientItem fp in fpr.Patients)
            {
                Patient p = new Patient();

                string patientId = fp.PatientID;

                p.PatientID = patientId;

                if (fp.CHI != null)
                    p.ChiNumber = fp.CHI;

                if (fp.Name != null)
                    p.Name = fp.Name;

                if (fp.DateOfBirthSpecified)
                    p.DOB = fp.DateOfBirth.ToString("dd-MM-yyyy");

                if (fp.Sex != null)
                    p.Gender = fp.Sex;

                if (!_patients.Contains(patientId))
                    _patients.Add(patientId, p);
            }
        }

        private void ConvertFindAdtResponses(FindADTresponse admissions, FindADTresponse transfers, FindADTresponse discharges)
        {
            const string SUB_NAME = MODULE_NAME + "ConvertFindAdtResponses";

            if (admissions.ADTMessages.Length > 500)
                throw new ApplicationException("More than 500 matches returned. Please narrow the search criteria and search again.");

            foreach (FindADTItem fa in admissions.ADTMessages)
            {
                string adtId = fa.ADTDetails.ADTid;

                //read the adt message details to get Episode Number, Hospital, Ward, Consultant etc.
                GetADT ga = new GetADT();

                ga.ADTId = adtId;

                GetADTResponse ar = _webService.GetADT(ga);

                if (_debugMode)
                    _general.LogDebug(SUB_NAME, "GetADT returned: " + SerializeClass(ar));

                string patientId = fa.PatientDetails.PatientID;

                if (_patients[patientId] == null)
                {
                    Patient pat = new Patient();

                    pat.PatientID = patientId;

                    //read the CHI Number from the FindADTResponse
                    if (fa.PatientDetails.CHI != null)
                        pat.ChiNumber = fa.PatientDetails.CHI;

                    //if no CHI Number found in the FindADTResponse then try the GetADT response
                    if (pat.ChiNumber.Length.Equals(0))
                    {
                        ID_TYPE[] patientIds = ar.ADTinformation.MessageData.PatientInformation.BasicDemographics.PatientId;

                        if (patientIds != null)
                        {
                            foreach(ID_TYPE patId in patientIds)
                            {
                                if (patId.IdScheme.ToUpper().Equals("CHI"))
                                {
                                    pat.ChiNumber = patId.IdValue;

                                    break; ;
                                }
                            }
                        }
                    }

                    if (fa.PatientDetails.Name != null)
                        pat.Name = fa.PatientDetails.Name;

                    if (fa.PatientDetails.DateOfBirthSpecified)
                        pat.DOB = fa.PatientDetails.DateOfBirth.ToString("dd-MM-yyyy");

                    if (fa.PatientDetails.Sex != null)
                        pat.Gender = fa.PatientDetails.Sex;

                    _patients.Add(patientId, pat);
                }

                string episodeNumber = string.Empty;

                if (ar.ADTinformation.MessageData.ADTInformation.ADTid.RecordIdentifier != null)
                    episodeNumber = ar.ADTinformation.MessageData.ADTInformation.ADTid.RecordIdentifier;

                Patient p = (Patient) _patients[patientId];

                if (episodeNumber.Length > 0)
                {
                    if (p.episodes[episodeNumber] == null)
                    {
                        Episode e = new Episode();

                        e.EpisodeID = adtId;

                        e.EpisodeNumber = episodeNumber;

                        if (fa.ADTDetails.AdmissionDateTimeSpecified)
                            e.AdmissionDateTime = fa.ADTDetails.AdmissionDateTime.ToString();

                        if (fa.ADTDetails.DischargeDateTimeSpecified)
                            e.DischargeDateTime = fa.ADTDetails.DischargeDateTime.ToString();

                        ADTadmissionType at = (ADTadmissionType) ar.ADTinformation.MessageData.ADTInformation.ADTmessageContent.Item;

                        if (at != null)
                        {
                            ADTpatientCarePoint cp = at.AdmissionCarePoint;

                            if (cp != null)
                            {
                                ID_TYPE site = cp.Site;

                                if (site != null)
                                {
                                   if (site.IdValue != null)
                                        e.HospitalCode = site.IdValue;
                                }

                                MedicalFacility mf = cp.Location;

                                if (mf != null)
                                {
                                    if (mf.Description != null)
                                        e.Ward = mf.Description;
                                }
                            }
                        }

                        if (fa.ADTDetails.PatientType != null)
                            e.PatientType = fa.ADTDetails.PatientType;

                        if (ar.ADTinformation.MessageData.PatientInformation.ExtendedDemographics.Consultant.UnStructuredName != null)
                            e.Consultant = ar.ADTinformation.MessageData.PatientInformation.ExtendedDemographics.Consultant.UnStructuredName;

                        p.episodes.Add(adtId, e);
                    }
                }
            }

            if (transfers != null)
            {
                foreach (FindADTItem fa in transfers.ADTMessages)
                {
                    string patientId = fa.PatientDetails.PatientID;

                    if (_patients[patientId] == null)
                    {
                        Patient pat = new Patient();

                        pat.ChiNumber = fa.PatientDetails.CHI;

                        pat.Name = fa.PatientDetails.Name;

                        if (fa.PatientDetails.DateOfBirthSpecified)
                            pat.DOB = fa.PatientDetails.DateOfBirth.ToString("DD-MM-YYYY");

                        _patients.Add(patientId, pat);
                    }

                    string episodeId = fa.ADTDetails.ADTid;

                    Patient p = (Patient)_patients[patientId];

                    if (p.episodes[episodeId] == null)
                    {
                        Episode e = new Episode();

                        e.EpisodeID = episodeId;

                        if (fa.ADTDetails.AdmissionDateTimeSpecified)
                            e.AdmissionDateTime = fa.ADTDetails.AdmissionDateTime.ToString();

                        if (fa.ADTDetails.DischargeDateTimeSpecified)
                            e.DischargeDateTime = fa.ADTDetails.DischargeDateTime.ToString();

                        e.HospitalCode = fa.ADTDetails.HospitalCode;

                        e.PatientType = fa.ADTDetails.PatientType;
                    }
                }
            }

            if (discharges != null)
            {
                foreach (FindADTItem fa in discharges.ADTMessages)
                {
                    string patientId = fa.PatientDetails.PatientID;

                    if (_patients[patientId] == null)
                    {
                        Patient pat = new Patient();

                        pat.ChiNumber = fa.PatientDetails.CHI;

                        pat.Name = fa.PatientDetails.Name;

                        if (fa.PatientDetails.DateOfBirthSpecified)
                            pat.DOB = fa.PatientDetails.DateOfBirth.ToString("DD-MM-YYYY");

                        _patients.Add(patientId, pat);
                    }

                    string episodeId = fa.ADTDetails.ADTid;

                    Patient p = (Patient)_patients[patientId];

                    if (p.episodes[episodeId] == null)
                    {
                        Episode e = new Episode();

                        e.EpisodeID = episodeId;

                        if (fa.ADTDetails.AdmissionDateTimeSpecified)
                            e.AdmissionDateTime = fa.ADTDetails.AdmissionDateTime.ToString();

                        if (fa.ADTDetails.DischargeDateTimeSpecified)
                            e.DischargeDateTime = fa.ADTDetails.DischargeDateTime.ToString();

                        e.HospitalCode = fa.ADTDetails.HospitalCode;

                        e.PatientType = fa.ADTDetails.PatientType;
                    }
                }
            }
        }

        public XmlDocument ReadPAS(string PatientId, string AdtId)
        {
            const string SUB_NAME = MODULE_NAME + ".ReadPAS";

            XmlDocument responseXml = null;

            try
            {
                if (AdtId.Length > 0)
                {
                    //An in-patient episode selected, so read the adt message.
                    GetADT a = new GetADT();

                    a.ADTId = AdtId;

                    GetADTResponse r = _webService.GetADT(a);

                    if (r != null)
                    {
                        responseXml = new XmlDocument();

                        responseXml.LoadXml(SerializeClass(r));

                        if (_debugMode)
                            _general.LogDebug(SUB_NAME, "GetADT returned: " + responseXml.OuterXml);
                    }
                }
                else
                {
                    //Lifetime episode selected, so get the latest patient demographics only
                    GetPatient p = new GetPatient();

                    p.PatientID = PatientId;

                    GetPatientResponse pr = _webService.GetPatient(p);

                    if (pr != null)
                    {
                        responseXml = new XmlDocument();

                        responseXml.LoadXml(SerializeClass(pr));

                        if (_debugMode)
                            _general.LogDebug(SUB_NAME, "GetPatient returned: " + responseXml.OuterXml);
                    }
                }
            }

            catch (Exception e)
            {
                _general.LogError(SUB_NAME, e);

                throw e;
            }

            return responseXml;
        }

        public bool Login(string Username,
                          string Password)
        {
            const string SUB_NAME = MODULE_NAME + ".Login";

            bool loggedIn = false;

            try
            {
                if (_debugMode)
                    _general.LogDebug(SUB_NAME, "Logging in as '" + Username + "' with password '" + Password + "'");

                Login l = new Login();

                l.Username = Username;

                l.Password = Password;

                LoginTokenResponse r = _webService.Login(l);

                _webService.UserCredentials.Token = r.Token;

                loggedIn = true;

                if (_debugMode)
                    _general.LogDebug(SUB_NAME, "Logged in: Token = " + r.Token);
            }

            catch (Exception e)
            {
                _general.LogError(SUB_NAME, e);

                throw e;
            }

            return loggedIn;
        }

        public void Logout()
        {
            const string SUB_NAME = MODULE_NAME + ".Logout";

            try
            {
                if (_debugMode)
                    _general.LogDebug(SUB_NAME, "Logging out.");

                Logout l = new Logout();

                _webService.Logout(l);

                _webService.UserCredentials.Token = string.Empty;

                if (_debugMode)
                    _general.LogDebug(SUB_NAME, "Logged out.");
            }

            catch (Exception e)
            {
                _general.LogError(SUB_NAME, e);

                throw e;
            }
        }
    }

    internal class Patient
    {

        public OrderedDictionary episodes = new OrderedDictionary();
        public string Name = string.Empty;
        public string DOB = string.Empty;
        public string ChiNumber = string.Empty;
        public string PatientID = string.Empty;
        public string Gender = string.Empty;

        public Patient()
        {

        }

        public string Description
        {
            get
            {
                string desc = this.Name.Trim();

                if (this.Gender.Length > 0)
                    desc +=  " - " + Gender.Trim();

                if (this.DOB.Length > 0)
                    desc += " - " + this.DOB.Trim();

                //desc = desc.Trim() + ;

                if (this.ChiNumber.Length > 0)
                    desc += " - " + this.ChiNumber.Trim();

                return desc;
            }
        }
    }

    internal class Episode
    {
        public string EpisodeID = string.Empty;
        public string EpisodeNumber = string.Empty;
        public string AdmissionDateTime = string.Empty;
        public string DischargeDateTime = string.Empty;
        public string HospitalCode = string.Empty;
        public string PatientType = string.Empty;
        public string Ward = string.Empty;
        public string Consultant = string.Empty;

        public Episode()
        {
        }

        public string Description
        {
            get
            {
                string desc = EpisodeNumber.Trim();

                if (HospitalCode.Length > 0)
                    desc += " - " + HospitalCode.Trim();

                if (Ward.Length > 0)
                    desc += " - " + Ward.Trim();

                if (Consultant.Length > 0)
                    desc += " - " + Consultant.Trim();

                if (PatientType.Length > 0)
                    desc += " - " + PatientType.Trim();

                return desc;
            }
        }
    }
}
