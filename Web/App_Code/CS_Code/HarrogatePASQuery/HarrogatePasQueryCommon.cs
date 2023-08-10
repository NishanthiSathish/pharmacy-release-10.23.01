using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Timers;

using System.Web;
using System.Xml;

using GENRTL10;
using ICWRTL10;

/// <summary>
/// Summary description for HarrogatePasQueryCommon
/// </summary>
public class HarrogatePasQueryCommon
{
    #region constants

        public const string APPLICATION_ERROR_CODE = "0002";
        public const string ALERT_MSG_TIMEOUT = "A response was not recieved from the PAS within the defined timeout period.";
        const string NO_PATIENT_FOUND_REPLY = "<root/>";

    #endregion

    #region enumerations

    public enum StateEngineStates
    {
        InitialiseEngine = 0,
        EngineInitialised = 1,
        LogonSent = 2,
        LogonReplyReceived = 3,
        LogonSuccessful = 4,
        EnquirySent = 5,
        EnquiryReplyReceived = 6,
        ContinueSent = 7,
        ContinueReplyReceived = 8,
        AllRepliesReceived = 9,
        LogoutSent = 10,
        LogoutReplyReceived = 11,
        SendContinue = 12,
        SendLogout = 13,
        CreateUpdate = 14,
        SendUpdate = 15,
        UpdateSent = 16,
        UpdateReplyReceived = 17,
        LoggedOut = 18,
        PatientNotFound = 100,
        TimeOut = 200,
        Disconnect = 300,
        Disconnected = 301,
        ShowErrorThenLogout = 400,
        ShowErrorThenExit = 401
    }

    #endregion

    #region class level variables

    private HarrogatePasQueryCommon.StateEngineStates _state = StateEngineStates.InitialiseEngine;
    private string _errMsg = string.Empty;
    private XmlDocument _patientsXml = new XmlDocument();
    private TcpClient _tcpClient = new TcpClient();
    private NetworkStream _tcpStream;
    private bool _timedout = false;
    private System.Timers.Timer _timer = new System.Timers.Timer();
    private bool _debugMode = false;

    #endregion

    public HarrogatePasQueryCommon()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public void ReadResponderInterfaceSettings(int SessionId, out int Timeout, out string ResponderIpAddr, out int ResponderPort, out string ResponderUserId, out string ResponderPwd, out string CallingSystemId, out string TerminalId)
    {
        const string CALLING_SYSTEM_KEY = "CallingSystemID";
        const string IP_ADDR_KEY = "ResponderIpAddress";
        const string IP_PORT_KEY = "ResponderPort";
        const string PWD_KEY = "ResponderPassword";
        const string SECTION_NAME = "HarrogatePASQuery";
        const string SP_NAME = "pTerminalBySessionIDXML";
        const string SYSTEM_NAME = "EpisodeSelectorQuery";
        const string TIMEOUT_KEY = "Timeout";
        const string USERNAME_KEY = "ResponderUserName";

        SettingRead s = new SettingRead();

        // add a configurable command timeout to ensure the search doesn't hang
        // default value is 3 minutes
        string timeout = s.GetValue(SessionId,
                                    SYSTEM_NAME,
                                    SECTION_NAME,
                                    TIMEOUT_KEY,
                                    "180");

        Timeout = int.Parse(timeout);

        //Read the IP Address used to connect to the PMS Responder
        ResponderIpAddr = s.GetValue(SessionId,
                                     SYSTEM_NAME,
                                     SECTION_NAME,
                                     IP_ADDR_KEY,
                                     "127.0.0.1");

        //Read the IP Port used to connect to the PMS Responder
        string port = s.GetValue(SessionId,
                                 SYSTEM_NAME,
                                 SECTION_NAME,
                                 IP_PORT_KEY,
                                 "12000");

        ResponderPort = int.Parse(port);

        //Read the user name that will be used to logon to the PMS Responder
        ResponderUserId = s.GetValue(SessionId,
                                     SYSTEM_NAME,
                                     SECTION_NAME,
                                     USERNAME_KEY,
                                     "PHAR");

        //Read the password that will be used to logon to the PMS Responder
        ResponderPwd = s.GetValue(SessionId,
                                  SYSTEM_NAME,
                                  SECTION_NAME,
                                  PWD_KEY,
                                  "ASCRIBE");

        //Read the CallingSystemID sent in each message header.
        CallingSystemId = s.GetValue(SessionId,
                                     SYSTEM_NAME,
                                     SECTION_NAME,
                                     CALLING_SYSTEM_KEY,
                                     "PHAR");

        //Read the Terminal 
        TerminalId = string.Empty;

        TRNRTL10.Transport t = new TRNRTL10.Transport();

        XmlDocument d = new XmlDocument();

        d.LoadXml(t.ExecuteSelectStreamSP(SessionId, SP_NAME, string.Empty));

        XmlNode n = d.SelectSingleNode("Terminal/@Description");

        if (n != null)
            TerminalId = n.Value;
    }

    private void DisconnectFromResponder(bool DebugMode, string ResponderAddress, int ResponderPort)
    {
        if (DebugMode)
            Log("DisconnectFromResponder(): Disconnecting from " + ResponderAddress + " port " + ResponderPort.ToString());

        if (_tcpStream != null)
        {
            _tcpStream.Close();

            _tcpStream = null;
        }

        if (_tcpClient.Connected)
        {
            _tcpClient.Close();
        }
    }

    private void ConnectToResponder(bool DebugMode, string ResponderAddress, int ResponderPort)
    {
        //Start the timer to timeout if no connection
        EnableTimer();

        if (DebugMode)
            Log("Connecting to " + ResponderAddress + " port " + ResponderPort.ToString());

        //Initiate connection to the Responder
        _tcpClient.Connect(ResponderAddress, ResponderPort);

        while ((_tcpClient.Connected.Equals(false)) && (!_timedout))
        {
            Thread.Sleep(10);
        }

        if (_tcpClient.Connected)
        {
            //Stop the timeout as we have a connection
            DisableTimer();

            //Set the next state for the StateEngine
            _state = StateEngineStates.EngineInitialised;

            //Open the comms channel across the TCPIP connection to the Responder.
            _tcpStream = _tcpClient.GetStream();

            if (DebugMode)
                Log("Connected to " + ResponderAddress + " port " + ResponderPort.ToString());
        }

        if (_timedout)
        {
            if (DebugMode)
                Log("Connection to " + ResponderAddress + " port " + ResponderPort.ToString() + " timed out.");

            _state = StateEngineStates.TimeOut;
        }

    }

    private void DisableTimer()
    {
        _timer.Stop();
    }

    private void EnableTimer()
    {
        _timedout = false;

        _timer.Start();
    }

    private void ProcessReply(int SessionId, bool DebugMode, string ReplyText, ref string ReturnXml)
    {
        //Process the message recieved from the Responder
        const int MESSAGE_TYPE_LENGTH = 10;
        const int TRANSACTION_TYPE_LENGTH = 10;

        if (DebugMode)
        {
            Log("Received Message: '" + ReplyText + "'.");
        }

        string output = string.Empty;

        switch (ReplyText.Substring(0, MESSAGE_TYPE_LENGTH).Trim())
        {
            case "ABORT":
                ProcessAbort(ReplyText);
                break;

            case "REJECT":
                ProcessReject(ReplyText);
                break;

            case "DATA":
                string transId = ReplyText.Substring(MESSAGE_TYPE_LENGTH, TRANSACTION_TYPE_LENGTH).Trim();

                if (transId.ToUpper().Equals("PNENQ"))
                    output = ProcessPnData(SessionId, DebugMode, ReplyText);

                if (transId.ToUpper().Equals("SNENQ"))
                    output = ProcessSnData(ReplyText);
                break;

            case "LOGON":
                ProcessLogon();
                break;

            case "LOGOUT":
                ProcessLogout();
                break;

            default:
                throw new ApplicationException("Unknown reply received - '" + ReplyText + "'");
        }

        if (output.Length > 0)
            ReturnXml = output;
    }

    private void ProcessLogout()
    {
        //set the state engine to logged out
        _state = StateEngineStates.LoggedOut;
    }

    private void ProcessLogon()
    {
        //Received a LOGON reply from Responder so set the state engine to LogonSuccessful
        _state = StateEngineStates.LogonSuccessful;
    }

    private string ProcessSnData(string ReplyText)
    {
        const int ADDR_LENGTH = 40;
        const int DOB_LENGTH = 8;
        const int PATIENT_NAME_LENGTH = 40;
        const int RECORD_LENGTH = 99;
        const int SEX_LENGTH = 1;
        const int UNIT_NUMBER_LENGTH = 10;

        //build the XML document for display in the Episode Selector
        string returnXml = string.Empty;

        //read the number of records returned
        int numOfRecs = int.Parse(ReplyText.Substring(137, 1));

        //foreach record build the patient xml
        for (int i = 1; i <= numOfRecs; i++)
        {
            //read the search match record
            string thisRecord = ReplyText.Substring(138 + ((i - 1) * RECORD_LENGTH), RECORD_LENGTH);

            //read the CaseNumber from this record
            string caseNumber = thisRecord.Substring(0, UNIT_NUMBER_LENGTH).Trim();

            //create an element called
            XmlElement entity = _patientsXml.CreateElement("Entity");

            //add the element to the class level XML document
            _patientsXml.DocumentElement.AppendChild(entity);

            //create the Class attribute
            XmlAttribute attributeClass = _patientsXml.CreateAttribute("Class");

            attributeClass.Value = "Entity";

            entity.Attributes.Append(attributeClass);

            //create the recordid attribute
            XmlAttribute attributeRecordId = _patientsXml.CreateAttribute("RecordID");

            attributeRecordId.Value = "0";

            entity.Attributes.Append(attributeRecordId);

            //read the date of birth
            string dob = thisRecord.Substring(UNIT_NUMBER_LENGTH + PATIENT_NAME_LENGTH + SEX_LENGTH, DOB_LENGTH).Trim();

            if (dob.Length.Equals(8))
                dob = dob.Substring(6, 2) + "/" + dob.Substring(4, 2) + "/" + dob.Substring(0, 4);

            //create the description attribute
            XmlAttribute desc = _patientsXml.CreateAttribute("Description");

            string descText = thisRecord.Substring(UNIT_NUMBER_LENGTH, PATIENT_NAME_LENGTH).Trim() + " " +
                              MapGender(thisRecord.Substring(UNIT_NUMBER_LENGTH + PATIENT_NAME_LENGTH, SEX_LENGTH)).Trim() + " - " +
                              dob + " - " +
                              thisRecord.Substring(0, UNIT_NUMBER_LENGTH).Trim();

            desc.Value = descText;

            entity.Attributes.Append(desc);

            //create the DateText attribute
            XmlAttribute entityDate = _patientsXml.CreateAttribute("DateText");

            entity.Attributes.Append(entityDate);

            //create the Status attribute
            entity.Attributes.Append(_patientsXml.CreateAttribute("Status"));

            //create the PatientStatusDescription attribute
            entity.Attributes.Append(_patientsXml.CreateAttribute("PatientStatusDescription"));

            //create the _isForeign attribute
            XmlAttribute isForeign = _patientsXml.CreateAttribute("_isForeign");

            isForeign.Value = "1";

            entity.Attributes.Append(isForeign);

            //add the CaseNumber to the XML so we can use it to query the responder if the user selects this patient.
            XmlAttribute entityCaseNumber = _patientsXml.CreateAttribute("_caseNumber");

            entityCaseNumber.Value = caseNumber;

            entity.Attributes.Append(entityCaseNumber);

            //create the lifetime episode
            XmlElement episode = _patientsXml.CreateElement("Episode");

            //add the episode element as a child of the Entity element
            entity.AppendChild(episode);

            //create the class attribute for the Episode element
            XmlAttribute epClass = _patientsXml.CreateAttribute("Class");

            epClass.Value = "Episode";

            episode.Attributes.Append(epClass);

            //create episode RecordID attribute
            XmlAttribute epRecordId = _patientsXml.CreateAttribute("RecordID");

            epRecordId.Value = "0";

            episode.Attributes.Append(epRecordId);

            //create the episode Description attribute
            XmlAttribute epDesc = _patientsXml.CreateAttribute("Description");

            epDesc.Value = "Lifetime Episode";

            episode.Attributes.Append(epDesc);

            //create the episode DateText attribute
            XmlAttribute epDate = _patientsXml.CreateAttribute("DateText");

            epDate.Value = dob;

            episode.Attributes.Append(epDate);

            //create the episode _isForeign attribute
            XmlAttribute epIsForeign = _patientsXml.CreateAttribute("_isForeign");

            epIsForeign.Value = "1";

            episode.Attributes.Append(epIsForeign);
        }

        //Set the state to 'SendContinue' to see if there are anymore matches.
        _state = StateEngineStates.SendContinue;

        return returnXml;
    }

    private string MapGender(string GenderCode)
    {
        switch (GenderCode.ToUpper())
        {
            case "1":
                return "Male";
            case "2":
                return "Female";
            default:
                return "Unknown";
        }
    }

    public void Log(string LogData)
    {
        //Ascribe.EpisodeQuery.EventLogger el = new Ascribe.EpisodeQuery.EventLogger();

        //el.CreateLogEntry(LogData, System.Diagnostics.EventLogEntryType.Information);

        Log(LogData, EventLogEntryType.Information);
    }

    public void Log(string LogData, EventLogEntryType Type)
    {
        if (LogData.Length > 32766)
            LogData = LogData.Substring(0, 32766);

        EventLog ev = new EventLog("Application");

        ev.Source = "ResponderInterface";

        ev.WriteEntry(LogData, Type, 0, 0);

        ev.Close();

        ev.Dispose();

    }

    private void ProcessAbort(string ReplyText)
    {
        //Received an ABORT message from the Responder

        //Build the Error message from the ABORT message details
        _errMsg = "The iCS Responder has returned an ABORT message\n\n" +
            "Abort Type: " + (ReplyText.Substring(50, 1).ToUpper().Equals("I") ? "Information" : "Fatal Error") + "\n" +
                  "Error number: " + ReplyText.Substring(51, 3) + "\n" +
                  "Error Description: " + ReplyText.Substring(54, 30).Trim() + "\n" +
                  "Current State: " + _state.ToString();

        if (_debugMode)
            Log("ProcessAbort() : " + _errMsg);

        //Set the stateengine to the next state
        switch (_state)
        {
            case StateEngineStates.LogonReplyReceived:
                _state = StateEngineStates.ShowErrorThenExit;
                break;

            case StateEngineStates.EnquiryReplyReceived:
                _state = StateEngineStates.PatientNotFound;
                break;

            case StateEngineStates.ContinueReplyReceived:
                _state = StateEngineStates.AllRepliesReceived;
                break;

            case StateEngineStates.LogoutReplyReceived:
                _state = StateEngineStates.ShowErrorThenExit;
                break;

            case StateEngineStates.UpdateReplyReceived:
                _state = StateEngineStates.ShowErrorThenLogout;
                break;

            default:
                throw new ApplicationException("ProcessAbort called from an invalid state. Current state is '" + _state.ToString() + "'.");
                break;
        }
    }

    private void Alert(string Message)
    {
        Log(Message, EventLogEntryType.Error);
    }

    private string WaitForReply()
    {
        //Wait for a reply from the Responder

        const int BUFFER_SIZE = 8192;

        bool replyReceived = false;
        string reply = string.Empty;

        //Set the timeout timer.
        EnableTimer();

        //while we have not received a reply or timed out
        while (!_timedout && !replyReceived && _tcpClient.Connected)
        {
            //Is there any date in the received channel from the Responder
            if (_tcpStream.DataAvailable)
            {
                //Data avialable so we have a reply

                //Disable the reply timeout timer
                DisableTimer();

                //Read the reply message from the Network Stream
                while (_tcpStream.DataAvailable)
                {
                    byte[] buffer = new byte[BUFFER_SIZE];

                    int bytesRead = _tcpStream.Read(buffer, 0, BUFFER_SIZE);

                    if (bytesRead > 0)
                    {
                        reply += ASCIIEncoding.ASCII.GetString(buffer, 0, bytesRead);
                    }
                }

                //We have received the whole message is there is a ASCII 13 character in the reply
                replyReceived = (reply.Contains("\r"));
            }
            else
            {
                //Wait 10ms before looking again.
                Thread.Sleep(10);
            }
        }

        if (_timedout)
            _state = StateEngineStates.TimeOut;
        else
        {
            if (replyReceived)
            {
                if (_debugMode)
                    Log("WaitForReply(): DataReceived = '" + reply.Replace("\r", "\\r") + "'");

                //remove the ASCII 13 character from the end of the reply
                reply = reply.Remove(reply.Length - 1);

                //set the next state for the state engine.
                switch (_state)
                {
                    case StateEngineStates.LogonSent:
                        _state = StateEngineStates.LogonReplyReceived;
                        break;

                    case StateEngineStates.EnquirySent:
                        _state = StateEngineStates.EnquiryReplyReceived;
                        break;

                    case StateEngineStates.ContinueSent:
                        _state = StateEngineStates.ContinueReplyReceived;
                        break;

                    case StateEngineStates.LogoutSent:
                        _state = StateEngineStates.LogoutReplyReceived;
                        break;

                    case StateEngineStates.UpdateSent:
                        _state = StateEngineStates.UpdateReplyReceived;
                        break;

                    default:
                        throw new ApplicationException("Unexpected reply received when in state '" + _state.ToString() + "'.");
                        break;
                }
            }
            else
                _state = StateEngineStates.Disconnected;
        }

        return reply;
    }

    private void WaitForState(StateEngineStates StateToWaitFor)
    {
        while (_state != StateToWaitFor)
        {
            if ((_state == StateEngineStates.Disconnected) ||
                (_state == StateEngineStates.TimeOut) ||
                (_state == StateEngineStates.ShowErrorThenExit) ||
                (_state == StateEngineStates.ShowErrorThenLogout))
                break;

            Thread.Sleep(10);
        }
    }

    private void SendMsg(bool DebugMode, string Msg, StateEngineStates NextState)
    {
        if (_tcpClient.Connected && (_tcpStream != null))
        {
            if (DebugMode)
                Log("Sending message '" + Msg + "'");

            Msg = Msg + "\r";

            byte[] toSend = Encoding.ASCII.GetBytes(Msg);

            _tcpStream.Write(toSend, 0, toSend.Length);

            _state = NextState;
        }
        else
            _state = StateEngineStates.Disconnected;
    }

    public string CreateUpdate(int SessionId,
                               bool DebugMode,
                               string Title,
                               string Surname,
                               string Forename,
                               string Forename2,
                               string Dob,
                               string Gender,
                               string NhsNumber,
                               string Address1,
                               string Address2,
                               string Address3,
                               string Address4,
                               string Postcode)
    {
        string callingSystemId;
        string localXml = string.Empty;
        string pwd;
        string responderIpAddress;
        int responderPort;
        int timeout;
        string userId;
        string terminalId;

        _debugMode = DebugMode;

        //Read the interface settings        
        ReadResponderInterfaceSettings(SessionId, out timeout, out responderIpAddress, out responderPort, out userId, out pwd, out callingSystemId, out terminalId);

        //setup the timer
        _timer.Interval = (timeout * 1000);

        _timer.AutoReset = false;

        _timer.Elapsed += new ElapsedEventHandler(TimerElapsed);

        //setup the TcpClient
        _tcpClient.SendTimeout = 500;

        _tcpClient.ReceiveTimeout =  0;

        _tcpClient.SendBufferSize = 0;

        //Reformat the DateOfBirth from DDMMCCYY to CCYYMMDD
        if (Dob.Length.Equals(8))
            Dob = Dob.Substring(4, 4) + Dob.Substring(2, 2) + Dob.Substring(0, 2);

        //remove the space if postcode length > 7 characters
        if (Postcode.Length > 7)
            Postcode = Postcode.Replace(" ", "");

        IcsNewPatient newPat = new IcsNewPatient(Title,
                                                 Surname,
                                                 Forename,
                                                 Forename2,
                                                 Dob,
                                                 Gender,
                                                 NhsNumber,
                                                 Address1,
                                                 Address2,
                                                 Address3,
                                                 Address4,
                                                 Postcode);

        localXml = CreatePatient(SessionId,
                                 DebugMode,
                                 newPat,
                                 responderIpAddress,
                                 responderPort,
                                 userId,
                                 callingSystemId,
                                 terminalId,
                                 pwd);

        if (_debugMode)
            Log("CreateUpdate() - ReplyXML = " + localXml);

        return localXml;
    }

    private string BuildHeader(string MsgType, string TransactionType, string UserId, string CallingSystemId, int MessageLength)
    {
        const int HEADER_LENGTH = 50;

        StringBuilder sb = new StringBuilder(HEADER_LENGTH, HEADER_LENGTH);

        sb.AppendFormat("{0, -10}", MsgType);

        sb.AppendFormat("{0, -10}", TransactionType);

        sb.AppendFormat("{0, -4}", UserId);

        sb.AppendFormat("{0, -3}", (HEADER_LENGTH + MessageLength).ToString());

        sb.AppendFormat("{0, -4}", CallingSystemId);

        //sb.AppendFormat("{0, -19)", BLANK);

        sb.Append(string.Empty.PadRight(19));

        return sb.ToString();
    }

    private string BuildLogon(string UserId, string CallingSystemId, string Terminal, string Password)
    {
        const int LOGON_MSG_LENGTH = 20;
        const string MSG_TYPE = "LOGON";

        StringBuilder sb = new StringBuilder(LOGON_MSG_LENGTH, LOGON_MSG_LENGTH);

        string terminal = Terminal;

        if (terminal.Length > 8)
            terminal = terminal.Substring(0, 8);

        sb.AppendFormat("{0, -8}", terminal);

        sb.AppendFormat("{0, -12}", Password);

        return BuildHeader(MSG_TYPE, string.Empty, UserId, CallingSystemId, LOGON_MSG_LENGTH) + sb.ToString();
    }

    private string BuildLogout(string UserId, string CallingSystemId)
    {
        const int LOGOUT_MSG_LENGTH = 0;
        const string MSG_TYPE = "LOGOUT";

        return BuildHeader(MSG_TYPE, string.Empty, UserId, CallingSystemId, LOGOUT_MSG_LENGTH);
    }

    private string BuildQuery(XmlDocument Criteria, string UserId, string CallingSystemId)
    {
        string msg = string.Empty;

        string caseNo = string.Empty;

        //read the case number from the criteria
        caseNo = ReadCriteriaAttribute(Criteria, "CaseNo");

        if (caseNo.Length.Equals(0))
        {
            //build the surname enquiry message
            msg = BuildSNENQ(Criteria, UserId, CallingSystemId);
        }
        else
        {
            //else do a case number search
            msg = BuildPNENQ(UserId, CallingSystemId, caseNo);
        }

        return msg;
    }

    private string BuildPNENQ(string UserId, string CallingSystemId, string CaseNumber)
    {
        const string MSG_TYPE = "REQUEST";
        const int PNENQ_LENGTH = 10;
        const string TRANS_TYPE = "PNENQ";

        StringBuilder sb = new StringBuilder();

        sb.AppendFormat("{0, -10}", CaseNumber);

        return BuildHeader(MSG_TYPE, TRANS_TYPE, UserId, CallingSystemId, PNENQ_LENGTH) + sb.ToString();
    }

    private string BuildSNENQ(XmlDocument Criteria, string UserId, string CallingSystemId)
    {
        const string MSG_TYPE = "REQUEST";

        return BuildEnquiry(Criteria, MSG_TYPE, UserId, CallingSystemId);
    }

    private string BuildCONTINUE(XmlDocument Criteria, string UserId, string CallingSystemId)
    {
        const string MSG_TYPE = "CONTINUE";

        return BuildEnquiry(Criteria, MSG_TYPE, UserId, CallingSystemId);
    }

    private string BuildEnquiry(XmlDocument Criteria, string MsgType, string UserId, string CallingSystemId)
    {
        const int ENQ_LENGTH = 87;
        const string TRANS_TYPE = "SNENQ";

        //read the search criteria
        string surname = ReadCriteriaAttribute(Criteria, "Surname").Replace("%", "");
        string forename = ReadCriteriaAttribute(Criteria, "Forename").Replace("%", "");
        string dob = ReadCriteriaAttribute(Criteria, "DOB");
        if (dob.Length > 0)
            dob = dob.Remove(10).Replace("-", "");
        string gender = ReadCriteriaAttribute(Criteria, "Sex").Replace("%", "");

        //Build the message
        StringBuilder sb = new StringBuilder();

        sb.AppendFormat("{0, -10}", string.Empty); //Patient Number
        sb.AppendFormat("{0, -30}", surname);
        sb.AppendFormat("{0, -30}", forename);
        sb.AppendFormat("{0, -4}", MapGenderCode(gender));
        if (dob.Length > 0)
            dob.Replace("-", "").Substring(0, 8);
        sb.AppendFormat("{0, -8}", dob);
        sb.Append(string.Empty.PadRight(3)); //Age
        sb.Append(string.Empty.PadRight(2)); //Age Range

        return BuildHeader(MsgType, TRANS_TYPE, UserId, CallingSystemId, ENQ_LENGTH) + sb.ToString();
    }

    private string MapGenderCode(string IcwGenderCode)
    {
        string pmsGenderCode = string.Empty;

        if (IcwGenderCode.Equals("1") || IcwGenderCode.Equals("2"))
            pmsGenderCode = IcwGenderCode;

        return pmsGenderCode;
    }

    private string BuildUpdate(IcsNewPatient NewPatient,
                               string UserId,
                               string CallingSystemId)
    {
        const string MSG_TYPE = "UPDATE";
        const string TRANS_TYPE = "PNENQ";
        const int UPDATE_LENGTH = 868;

        //Build the Responder message string
        StringBuilder sb = new StringBuilder(UPDATE_LENGTH, UPDATE_LENGTH);

        sb.AppendFormat("{0, -10}", string.Empty); //Patient Number - leave blank to signify this is a new patient.
        sb.AppendFormat("{0, -30}", NewPatient.surname);
        sb.AppendFormat("{0, -30}", NewPatient.firstForename);
        sb.AppendFormat("{0, -30}", NewPatient.secondForename);
        sb.AppendFormat("{0, -4}", NewPatient.title);
        sb.AppendFormat("{0, -1}", NewPatient.gender);
        sb.AppendFormat("{0, -8}", NewPatient.dob);
        sb.AppendFormat("{0, -8}", string.Empty); //Date of Death
        sb.AppendFormat("{0, -35}", NewPatient.addressLine1);
        sb.AppendFormat("{0, -30}", NewPatient.addressLine2);
        sb.AppendFormat("{0, -30}", NewPatient.addressLine3);
        sb.AppendFormat("{0, -30}", NewPatient.addressLine4);
        sb.AppendFormat("{0, -7}", NewPatient.postcode);
        sb.AppendFormat("{0, -8}", DateTime.Now.ToString("yyyyMMdd")); //Date Address Change
        sb.Append("E"); //Reason for change
        sb.AppendFormat("{0, -3}", string.Empty); //District Of Residence
        sb.AppendFormat("{0, -30}", string.Empty); //Telephone Number
        sb.AppendFormat("{0, -30}", string.Empty); //Alt Telephone Number
        sb.AppendFormat("{0, -1}", string.Empty); //Marital Status
        sb.AppendFormat("{0, -4}", string.Empty); //Religion Code
        sb.AppendFormat("{0, -17}", NewPatient.nhsNumber);
        //sb.AppendFormat("{0, -520)", string.Empty); //rest of the message
        sb.Append(string.Empty.PadRight(520));

        string msg = BuildHeader(MSG_TYPE, TRANS_TYPE, UserId, CallingSystemId, UPDATE_LENGTH) + sb.ToString();

        if (_debugMode)
            Log("BuildUpdate() - message = " + msg);

        return msg;
    }

    private string ReadCriteriaAttribute(XmlDocument Criteria, string AttributeName)
    {
        string value = string.Empty;

        XmlNode temp = Criteria.DocumentElement.SelectSingleNode("Parameter[@Name='" + AttributeName + "']/@Value");

        if (temp != null)
            value = temp.Value;

        if (value.Equals("%"))
            value = string.Empty;

        return value;
    }

    private string ReadPatient(int SessionId,
                               bool DebugMode,
                               string ResponderIpAddress,
                               int ResponderPort,
                               string UserId,
                               string CallingSystemId,
                               string Terminal,
                               string Password,
                               XmlDocument Criteria)
    {
        //This is routine that is the state engine that manages communication with the PMS responder.
        Ascribe.EpisodeQuery.BrokenRules b = new Ascribe.EpisodeQuery.BrokenRules();

        string replyMsg = string.Empty;
        
        string returnXml = string.Empty;

        _state = StateEngineStates.InitialiseEngine;

        Exception originalErr = null;

        do
        {
            string extraInfo = string.Empty;

            try
            {
                switch (_state)
                {
                    case StateEngineStates.InitialiseEngine:
                        extraInfo = "Initialising the Engine";
                        ConnectToResponder(DebugMode, ResponderIpAddress, ResponderPort);
                        break;

                    case StateEngineStates.EngineInitialised:
                        extraInfo = "Sending the Logon message";
                        SendMsg(DebugMode, BuildLogon(UserId, CallingSystemId, Terminal, Password), StateEngineStates.LogonSent);
                        break;

                    case StateEngineStates.LogonSent:
                        extraInfo = "Waiting for the LOGON response";
                        replyMsg = WaitForReply();
                        break;

                    case StateEngineStates.LogonReplyReceived:
                        extraInfo = "Processing the LOGON reply";
                        ProcessReply(SessionId, DebugMode, replyMsg, ref returnXml);
                        break;

                    case StateEngineStates.LogonSuccessful:
                        extraInfo = "sending a patient number or surname query";
                        SendMsg(DebugMode, BuildQuery(Criteria, UserId, CallingSystemId), StateEngineStates.EnquirySent);
                        break;

                    case StateEngineStates.EnquirySent:
                        extraInfo = "waiting for an enquiry response";
                        replyMsg = WaitForReply();
                        break;

                    case StateEngineStates.EnquiryReplyReceived:
                        extraInfo = "processing the enquiry response";
                        ProcessReply(SessionId, DebugMode, replyMsg, ref returnXml);
                        break;

                    case StateEngineStates.SendLogout:
                        extraInfo = "sending a logout";
                        SendMsg(DebugMode, BuildLogout(UserId, CallingSystemId), StateEngineStates.LogoutSent);
                        break;

                    case StateEngineStates.LogoutSent:
                        extraInfo = "waiting for the logout reply";
                        replyMsg = WaitForReply();
                        break;

                    case StateEngineStates.LogoutReplyReceived:
                        extraInfo = "processing the logout reply";
                        ProcessReply(SessionId, DebugMode, replyMsg, ref returnXml);
                        break;

                    case StateEngineStates.LoggedOut:
                        //Disconnect from the Repsonder
                        _state = StateEngineStates.Disconnect;
                        break;

                    case StateEngineStates.TimeOut:
                        extraInfo = "Setting the module level error message";
                        _errMsg = ALERT_MSG_TIMEOUT + "\nCurrent state = " + _state.ToString();

                        extraInfo = "Setting the next state to 'ShowErrorThenExit'";
                        if (_state >= StateEngineStates.LogonSuccessful)
                            _state = StateEngineStates.ShowErrorThenLogout;
                        else
                            _state = StateEngineStates.ShowErrorThenExit;
                        break;

                    case StateEngineStates.Disconnect:
                        DisconnectFromResponder(DebugMode, ResponderIpAddress, ResponderPort);
                        //exit
                        _state = StateEngineStates.Disconnected;
                        break;

                    case StateEngineStates.Disconnected:
                        if (DebugMode)
                            Log("Disconnected from " + ResponderIpAddress + " port " + ResponderPort.ToString());
                        break;

                    case StateEngineStates.ShowErrorThenLogout:
                        extraInfo = "Showing the user the error then logging out";
                        Alert(_errMsg);

                        returnXml = b.FormatBrokenRulesXml("0001", _errMsg);

                        extraInfo = "Setting the state to 'SendLogout'";
                        _state = StateEngineStates.SendLogout;
                        break;

                    case StateEngineStates.ShowErrorThenExit:
                        extraInfo = "Showing the user the error then logging out";
                        Alert(_errMsg);

                        returnXml = b.FormatBrokenRulesXml("0001", _errMsg);

                        extraInfo = "Setting next state to 'Disconnect'";
                        _state = StateEngineStates.Disconnect;
                        break;
                }
            }

            catch(Exception err)
            {
                if (originalErr == null)
                    originalErr = err;

                if (_state >= StateEngineStates.LogonSuccessful)
                    _state = StateEngineStates.ShowErrorThenLogout;

                if (_state < StateEngineStates.LogonSuccessful)
                    _state = StateEngineStates.ShowErrorThenExit;

                if (_state < StateEngineStates.EngineInitialised)
                    _state = StateEngineStates.Disconnected;               
            }

        } while ((_state != StateEngineStates.Disconnected) && (_tcpClient.Connected.Equals(true)));

        if (originalErr != null)
        {
            Exception tmpErr = originalErr;

            while (tmpErr != null)
            {
                Log(ErrorToMsg(tmpErr), EventLogEntryType.Error);

                tmpErr = tmpErr.InnerException;
            }

            throw new ApplicationException("An error occurred while interfacing with the iCS Responder.", originalErr);
        }

        return returnXml;
    }

    public string FindPatient(int SessionId, bool DebugMode, string CaseNumber)
    {
        string callingSystemId;
        string localXml = string.Empty;
        string pwd;
        string responderIpAddress;
        int responderPort;
        int timeout;
        string userId;
        string terminalId;
        XmlDocument criteria = new XmlDocument();

        _debugMode = DebugMode;

        //Read the interface settings
        ReadResponderInterfaceSettings(SessionId, out timeout, out responderIpAddress, out responderPort, out userId, out pwd, out callingSystemId, out terminalId);

        //setup the timer
        _timer.Interval = (timeout * 1000);

        _timer.AutoReset = false;

        _timer.Elapsed += new ElapsedEventHandler(TimerElapsed);

        //setup the TcpClient
        _tcpClient.SendTimeout = 500;

        _tcpClient.ReceiveTimeout = 500;

        _tcpClient.SendBufferSize = 0;

        // create the ICW search criteria XML
        criteria.LoadXml("<Parameters><Parameter Name=\"CaseNo\" DataType=\"0\" Direction=\"1\" Length=\"25\" Value=\"" + CaseNumber +
                         "\"/><Parameter Name=\"Surname\" DataType=\"0\" Direction=\"1\" Length=\"50\" Value=\"%\"/>" +
                         "<Parameter Name=\"Forename\" DataType=\"0\" Direction=\"1\" Length=\"50\" Value=\"%\"/>" +
                         "<Parameter Name=\"DOB\" DataType=\"6\" Direction=\"1\" Length=\"8\"/>" +
                         "<Parameter Name=\"NHSNumber\" DataType=\"0\" Direction=\"1\" Length=\"10\" Value=\"%\"/>" +
                         "<Parameter Name=\"Ward\" DataType=\"11\" Direction=\"1\" Length=\"4\"/>" +
                         "<Parameter Name=\"Consultant\" DataType=\"11\" Direction=\"1\" Length=\"4\"/></Parameters>");

        string returnXml = ReadPatient(SessionId,
                                       DebugMode,
                                       responderIpAddress,
                                       responderPort,
                                       userId,
                                       callingSystemId,
                                       terminalId,
                                       pwd,
                                       criteria);
        return returnXml;
    }

    private void ProcessReject(string ReplyText)
    {
        //Received a REJECT message from the Responder

        string rejectType = ReplyText.Substring(50, 1).ToUpper();

        //Build the Error message from the REJECT message details
        _errMsg = "The iCS Responder has returned a REJECT message\n\n" +
                  "Reject Type: " + (rejectType.Equals("R") ? "Reject" : rejectType) + "\n" +
                  "Error number: " + ReplyText.Substring(51, 4) + "\n" +
                  "Error Description: " + ReplyText.Substring(54, 76).Trim() + "\n" +
                  "Reject Field Number: " + ReplyText.Substring(130, 2) + "\n" +
                  "Current State: " + _state.ToString();

        if (_debugMode)
            Log("ProcessReject(): " + _errMsg);

        //Set the stateengine to the next state
        switch (_state)
        {
            case StateEngineStates.LogonReplyReceived:
                _state = StateEngineStates.ShowErrorThenExit;
                break;

            case StateEngineStates.EnquiryReplyReceived:
                _state = StateEngineStates.PatientNotFound;
                break;

            case StateEngineStates.ContinueReplyReceived:
                _state = StateEngineStates.AllRepliesReceived;
                break;

            case StateEngineStates.LogoutReplyReceived:
                _state = StateEngineStates.ShowErrorThenExit;
                break;

            case StateEngineStates.UpdateReplyReceived:
                _state = StateEngineStates.ShowErrorThenLogout;
                break;

            default:
                throw new ApplicationException("ProcessReject called from an invalid state. Current state is '" + _state.ToString() + "'.");
                break;
        }
    }

    private string ProcessPnData(int SessionId, bool DebugMode, string ReplyText)
    {
        //USe the data from the PNDATA reply to create the patient in the ICW database.
        const string TABLE_NAME = "HarrogateResponderPAS";

        string output = string.Empty;

        string caseNumber = ReplyText.Substring(50, 10).Trim();

        TRNRTL10.Transport t = new TRNRTL10.Transport();

        string pXml = t.CreateInputParameterXML("CaseNumber", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 10, caseNumber);

        pXml += t.CreateInputParameterXML("Surname", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 30, ReplyText.Substring(60, 30).Trim());

        pXml += t.CreateInputParameterXML("Forename1", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 30, ReplyText.Substring(90, 30).Trim());

        pXml += t.CreateInputParameterXML("Forename2", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 30, ReplyText.Substring(120, 30).Trim());

        pXml += t.CreateInputParameterXML("Title", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 4, ReplyText.Substring(150, 4).Trim());

        string gender = ReplyText.Substring(154, 1);

        int genderId = 3;

        switch(gender)
        {
            case "1":
            case "2":
                genderId = int.Parse(gender);
                break;
            default:
            genderId = 3;
            break;
        }

        pXml += t.CreateInputParameterXML("GenderId", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeInt, 4, genderId);

        object dob = DBNull.Value;

        string responderDob = ReplyText.Substring(155, 8).Trim();

        if (responderDob.Length > 0)
            dob = responderDob.Substring(0, 4) + "-" + responderDob.Substring(4, 2) + "-" + responderDob.Substring(6, 2);

        pXml += t.CreateInputParameterXML("DOB", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 8, dob);

        object dod = DBNull.Value;

        string responderDod = ReplyText.Substring(163, 8).Trim();

        if ((responderDod.Length > 0) && (!responderDod.Equals("00000000")))
            dod = responderDod.Substring(6, 2) + "-" + responderDod.Substring(4, 2) + "-" + responderDod.Substring(0, 4);

        pXml += t.CreateInputParameterXML("DOD", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 8, dod);

        pXml += t.CreateInputParameterXML("Address1", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 35, ReplyText.Substring(171, 35).Trim());

        pXml += t.CreateInputParameterXML("Address2", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 30, ReplyText.Substring(206, 30).Trim());

        pXml += t.CreateInputParameterXML("Address3", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 30, ReplyText.Substring(236, 30).Trim());

        pXml += t.CreateInputParameterXML("Address4", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 30, ReplyText.Substring(266, 30).Trim());

        pXml += t.CreateInputParameterXML("Postcode", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 7, ReplyText.Substring(296, 7).Trim());

        pXml += t.CreateInputParameterXML("Telephone", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 30, ReplyText.Substring(315, 30).Trim());

        pXml += t.CreateInputParameterXML("NhsNumber", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 17, ReplyText.Substring(380, 17).Trim());

        pXml += t.CreateInputParameterXML("GP", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 8, ReplyText.Substring(436, 8).Trim());

        pXml += t.CreateInputParameterXML("Practice", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 8, ReplyText.Substring(444, 8).Trim());

        if (_debugMode)
            Log("Calling pHarrogateResponderPASInsert with parameters: " + pXml);

        int id = t.ExecuteInsertSP(SessionId, TABLE_NAME, pXml);

        //Create the criteria xml as if it is a case number search.
        XmlDocument criteria = new XmlDocument();

        criteria.LoadXml("<Parameters><Parameter Name=\"Hospital_No\" DataType=\"0\" Direction=\"1\" Length=\"25\" Value=\"" + caseNumber +
                         "\"/><Parameter Name=\"Surname\" DataType=\"0\" Direction=\"1\" Length=\"50\" Value=\"%\"/>" +
                         "<Parameter Name=\"Forename\" DataType=\"0\" Direction=\"1\" Length=\"50\" Value=\"%\"/>" +
                         "<Parameter Name=\"DOB\" DataType=\"6\" Direction=\"1\" Length=\"8\"/>" +
                         "<Parameter Name=\"NHS_Number\" DataType=\"0\" Direction=\"1\" Length=\"10\" Value=\"%\"/>" +
                         "</Parameters>");

        ICWRTL10.RoutineRead rr = new RoutineRead();

        string routine = rr.ConvertRoutineDescriptionToName("Episode Selector");

        output = QueryICW(SessionId, DebugMode, routine, criteria.OuterXml);

        _state = StateEngineStates.SendLogout;

        return output;
    }

    private void TimerElapsed(object sender, ElapsedEventArgs e)
    {
        if (_debugMode)
            Log("TimerElapsed()");

        _timedout = true;
    }

    public string QueryPMS(int SessionId,
                           bool DebugMode,
                           string Routine,
                           string SearchCriteriaXml)
    {
        string callingSystemId;
        string localXml = string.Empty;
        string pwd;
        string responderIpAddress;
        int responderPort;
        int timeout;
        string userId;
        string terminalId;

        _debugMode = DebugMode;

        //Load the ICW generated search criteria into the DOM
        XmlDocument criteria = new XmlDocument();

        criteria.LoadXml(SearchCriteriaXml);

        //Read the interface settings        
        ReadResponderInterfaceSettings(SessionId, out timeout, out responderIpAddress, out responderPort, out userId, out pwd, out callingSystemId, out terminalId);

        //setup the timer
        _timer.Interval = (timeout * 1000);

        _timer.AutoReset = false;

        _timer.Elapsed += new ElapsedEventHandler(TimerElapsed);

        //setup the TcpClient
        _tcpClient.SendTimeout = 500;

        _tcpClient.ReceiveTimeout = 500;

        _tcpClient.SendBufferSize = 0;

        localXml = SearchForPatient(SessionId,
                                    DebugMode,
                                    Routine,
                                    criteria,
                                    responderIpAddress,
                                    responderPort,
                                    userId,
                                    callingSystemId,
                                    terminalId,
                                    pwd);

        return localXml;
    }

    private string SearchForPatient(int SessionId,
                                    bool DebugMode,
                                    string Routine,
                                    XmlDocument Criteria,
                                    string ResponderIpAddress,
                                    int ResponderPort,
                                    string UserId,
                                    string CallingSystemId,
                                    string Terminal,
                                    string Password)
    {
        //This is routine is the state engine that manages communication with the PMS responder.

        const string ALERT_MSG_TIMEOUT = "A response was not recieved from the PAS within the defined timeout period.";

        Ascribe.EpisodeQuery.BrokenRules b = new Ascribe.EpisodeQuery.BrokenRules();

        string replyMsg = string.Empty;

        string returnXml = string.Empty;

        Exception originalErr = null;

        _patientsXml.LoadXml(NO_PATIENT_FOUND_REPLY);

        do
        {
            string extraInfo = string.Empty;

            try
            {
                if (DebugMode)
                    Log("SearchForPatient(): State = " + _state.ToString());

                switch (_state)
                {
                    case StateEngineStates.InitialiseEngine:
                        extraInfo = "Initialising the Engine";
                        ConnectToResponder(DebugMode, ResponderIpAddress, ResponderPort);
                        break;

                    case StateEngineStates.EngineInitialised:
                        extraInfo = "Sending the Logon message";
                        SendMsg(DebugMode, BuildLogon(UserId, CallingSystemId, Terminal, Password), StateEngineStates.LogonSent);
                        break;

                    case StateEngineStates.LogonSent:
                        extraInfo = "Waiting for the LOGON response";
                        replyMsg = WaitForReply();
                        break;

                    case StateEngineStates.LogonReplyReceived:
                        extraInfo = "Processing the LOGON reply";
                        ProcessReply(SessionId, DebugMode, replyMsg, ref returnXml);
                        break;

                    case StateEngineStates.LogonSuccessful:
                        extraInfo = "sending a patient number or surname query";
                        SendMsg(DebugMode, BuildQuery(Criteria, UserId, CallingSystemId), StateEngineStates.EnquirySent);
                        break;

                    case StateEngineStates.EnquirySent:
                        extraInfo = "waiting for an enquiry response";
                        replyMsg = WaitForReply();
                        break;

                    case StateEngineStates.EnquiryReplyReceived:
                        extraInfo = "processing the enquiry response";
                        ProcessReply(SessionId, DebugMode, replyMsg, ref returnXml);

                        extraInfo = "Setting the returned status to 'Success'";
                        //sts = patRepSearch_Success;
                        break;

                    case StateEngineStates.SendContinue:
                        extraInfo = "get the next set of matching patients";
                        SendMsg(DebugMode, BuildCONTINUE(Criteria, UserId, CallingSystemId), StateEngineStates.ContinueSent);
                        break;

                    case StateEngineStates.ContinueSent:
                        extraInfo = "waiting for a continue response";
                        replyMsg = WaitForReply();
                        break;

                    case StateEngineStates.ContinueReplyReceived:
                        extraInfo = "processing the Continue response";
                        ProcessReply(SessionId, DebugMode, replyMsg, ref returnXml);
                        break;

                    case StateEngineStates.AllRepliesReceived:
                        //return the XML to be displayed in the EpisodeSelector
                        returnXml = _patientsXml.OuterXml;

                        _state = StateEngineStates.SendLogout;
                        break;

                    case StateEngineStates.PatientNotFound:
                        //set the reply message
                        replyMsg = NO_PATIENT_FOUND_REPLY;

                        //logout from the responder
                        _state = StateEngineStates.SendLogout;
                        break;

                    case StateEngineStates.SendLogout:
                        extraInfo = "sending a logout";
                        SendMsg(DebugMode, BuildLogout(UserId, CallingSystemId), StateEngineStates.LogoutSent);
                        break;

                    case StateEngineStates.LogoutSent:
                        extraInfo = "waiting for the logout reply";
                        replyMsg = WaitForReply();
                        break;

                    case StateEngineStates.LogoutReplyReceived:
                        extraInfo = "processing the logout reply";
                        ProcessReply(SessionId, DebugMode, replyMsg, ref returnXml);
                        break;

                    case StateEngineStates.LoggedOut:
                        //Disconnect from the Repsonder
                        _state = StateEngineStates.Disconnect;
                        break;

                    case StateEngineStates.TimeOut:
                        extraInfo = "Setting the module level error message";
                        _errMsg = ALERT_MSG_TIMEOUT + "\nCurrent state = " + _state.ToString();

                        extraInfo = "Setting the next state to 'ShowErrorThenExit'";
                        if (_state >= StateEngineStates.LogonSuccessful)
                            _state = StateEngineStates.ShowErrorThenLogout;
                        else
                            _state = StateEngineStates.ShowErrorThenExit;
                        break;

                    case StateEngineStates.Disconnect:
                        DisconnectFromResponder(DebugMode, ResponderIpAddress, ResponderPort);
                        //exit
                        _state = StateEngineStates.Disconnected;
                        break;

                    case StateEngineStates.Disconnected:
                        if (DebugMode)
                            Log("Disconnected from " + ResponderIpAddress + " port " + ResponderPort.ToString());
                        break;

                    case StateEngineStates.ShowErrorThenLogout:
                        extraInfo = "Showing the user the error then logging out";
                        Alert(_errMsg);

                        returnXml = b.FormatBrokenRulesXml("0001", _errMsg);

                        extraInfo = "Setting the state to 'SendLogout'";
                        _state = StateEngineStates.SendLogout;
                        break;

                    case StateEngineStates.ShowErrorThenExit:
                        extraInfo = "Showing the user the error then logging out";
                        Alert(_errMsg);

                        returnXml = b.FormatBrokenRulesXml("0001", _errMsg);

                        extraInfo = "Setting next state to 'Disconnect'";
                        _state = StateEngineStates.Disconnect;
                        break;
                }
            }

            catch (Exception err)
            {
                if (originalErr == null)
                    originalErr = err;

                if (_state >= StateEngineStates.LogonSuccessful)
                    _state = StateEngineStates.ShowErrorThenLogout;

                if (_state < StateEngineStates.LogonSuccessful)
                    _state = StateEngineStates.ShowErrorThenExit;

                if (_state < StateEngineStates.EngineInitialised)
                    _state = StateEngineStates.Disconnected;
            }

        } while ((_state != StateEngineStates.Disconnected) && (_tcpClient.Connected.Equals(true)));

        if (originalErr != null)
        {
            Exception tmpErr = originalErr;

            while (tmpErr != null)
            {
                Log(ErrorToMsg(tmpErr), EventLogEntryType.Error);

                tmpErr = tmpErr.InnerException;
            }

            throw new ApplicationException("An error occurred while interfacing with the iCS Responder.", originalErr);
        }

        if (returnXml.Length.Equals(0))
            returnXml = NO_PATIENT_FOUND_REPLY;

        return returnXml;
    }

    private string ErrorToMsg(Exception Err)
    {
        return Err.Message + "\n" + Err.StackTrace + "\n" + Err.Source;
    }

    private string CreatePatient(int SessionId,
                                 bool DebugMode,
                                 IcsNewPatient NewPatient,
                                 string ResponderIpAddress,
                                 int ResponderPort,
                                 string UserId,
                                 string CallingSystemId,
                                 string Terminal,
                                 string Password)
    {
        //This is routine that is the state engine that manages communication with the PMS responder.

        string replyMsg = string.Empty;

        string returnXml = string.Empty;

        string updateMsg = string.Empty;

        Exception originalErr = null;

        Ascribe.EpisodeQuery.BrokenRules b = new Ascribe.EpisodeQuery.BrokenRules();

        do
        {
            string extraInfo = string.Empty;

            try
            {
                if (DebugMode)
                    Log("CreatePatient() - State = " + _state.ToString());

                switch (_state)
                {
                    case StateEngineStates.InitialiseEngine:
                        extraInfo = "Initialising the Engine";
                        ConnectToResponder(DebugMode, ResponderIpAddress, ResponderPort);
                        break;

                    case StateEngineStates.EngineInitialised:
                        extraInfo = "Sending the Logon message";
                        SendMsg(DebugMode, BuildLogon(UserId, CallingSystemId, Terminal, Password), StateEngineStates.LogonSent);
                        break;

                    case StateEngineStates.LogonSent:
                        extraInfo = "Waiting for the LOGON response";
                        replyMsg = WaitForReply();
                        break;

                    case StateEngineStates.LogonReplyReceived:
                        extraInfo = "Processing the LOGON reply";
                        ProcessReply(SessionId, DebugMode, replyMsg, ref returnXml);
                        break;

                    case StateEngineStates.LogonSuccessful:
                        //Build the update message using the data in the Criteria XML document
                        extraInfo = "building an update message";
                        updateMsg = BuildUpdate(NewPatient, UserId, CallingSystemId);
                        _state = StateEngineStates.SendUpdate;
                        break;

                    case StateEngineStates.SendUpdate:
                        extraInfo = "sending an update";
                        //Send the update message to the Responder
                        SendMsg(DebugMode, updateMsg, StateEngineStates.UpdateSent);
                        break;

                    case StateEngineStates.UpdateSent:
                        extraInfo = "waiting for the update reply";
                        replyMsg = WaitForReply();
                        break;

                    case StateEngineStates.UpdateReplyReceived:
                        extraInfo = "processing the update reply";
                        //sts = patRepSearch_Success;
                        ProcessReply(SessionId, DebugMode, replyMsg, ref returnXml);
                        break;

                    case StateEngineStates.SendLogout:
                        extraInfo = "sending a logout";
                        SendMsg(DebugMode, BuildLogout(UserId, CallingSystemId), StateEngineStates.LogoutSent);
                        break;

                    case StateEngineStates.LogoutSent:
                        extraInfo = "waiting for the logout reply";
                        replyMsg = WaitForReply();
                        break;

                    case StateEngineStates.LogoutReplyReceived:
                        extraInfo = "processing the logout reply";
                        ProcessReply(SessionId, DebugMode, replyMsg, ref returnXml);
                        break;

                    case StateEngineStates.LoggedOut:
                        //Disconnect from the Repsonder
                        _state = StateEngineStates.Disconnect;
                        break;

                    case StateEngineStates.TimeOut:
                        extraInfo = "Setting the module level error message";
                        _errMsg = ALERT_MSG_TIMEOUT + "\nCurrent state = " + _state.ToString();

                        extraInfo = "Setting the next state to 'ShowErrorThenExit'";
                        if (_state >= StateEngineStates.LogonSuccessful)
                            _state = StateEngineStates.ShowErrorThenLogout;
                        else
                            _state = StateEngineStates.ShowErrorThenExit;
                        break;

                    case StateEngineStates.Disconnect:
                        DisconnectFromResponder(DebugMode, ResponderIpAddress, ResponderPort);
                        //exit
                        _state = StateEngineStates.Disconnected;
                        break;

                    case StateEngineStates.Disconnected:
                        if (DebugMode)
                            Log("Disconnected from " + ResponderIpAddress + " port " + ResponderPort.ToString());
                        break;

                    case StateEngineStates.ShowErrorThenLogout:
                        extraInfo = "Showing the user the error then logging out";
                        Alert(_errMsg);

                        returnXml = b.FormatBrokenRulesXml("0001", _errMsg);
                        
                        extraInfo = "Setting the state to 'SendLogout'";
                        _state = StateEngineStates.SendLogout;
                        break;

                    case StateEngineStates.ShowErrorThenExit:
                        extraInfo = "Showing the user the error then logging out";
                        Alert(_errMsg);

                        returnXml = b.FormatBrokenRulesXml("0001", _errMsg);

                        extraInfo = "Setting next state to 'Disconnect'";
                        _state = StateEngineStates.Disconnect;
                        break;
                }
            }

            catch(Exception err)
            {
                if (originalErr == null)
                    originalErr = err;

                if (_state >= StateEngineStates.LogonSuccessful)
                    _state = StateEngineStates.ShowErrorThenLogout;

                if (_state < StateEngineStates.LogonSuccessful)
                    _state = StateEngineStates.ShowErrorThenExit;

                if (_state < StateEngineStates.EngineInitialised)
                    _state = StateEngineStates.Disconnected;               
            }

        } while ((_state != StateEngineStates.Disconnected) && (_tcpClient.Connected.Equals(true)));

        if (originalErr != null)
        {
            Exception tmpErr = originalErr;

            while (tmpErr != null)
            {
                Log(ErrorToMsg(tmpErr), EventLogEntryType.Error);

                tmpErr = tmpErr.InnerException;
            }

            throw new ApplicationException("An error occurred while interfacing with the iCS Responder.", originalErr);
        }

        if (Ascribe.Common.BrokenRules.NoRulesBroken(returnXml))
        {
            //Set the new patient's lifetime episode to be in state
            XmlDocument result = new XmlDocument();

            result.LoadXml(returnXml);

            int entityId = -1;

            XmlNode entity = result.DocumentElement.SelectSingleNode("Entity/@RecordID");

            if (entity != null)
                entityId = int.Parse(entity.Value);

            int episodeId = -1;

            XmlNode episode = result.DocumentElement.SelectSingleNode("Entity/Episode/@RecordID");

            if (episode != null)
                episodeId = int.Parse(episode.Value);

            if ((entityId > 0) && (episodeId > 0))
            {
                GENRTL10.State st = new State();

                st.SetKey(SessionId, "Entity", entityId);

                st.SetKey(SessionId, "Episode", episodeId);

                st.SetKey(SessionId, "Request", 0);
            }
        }

        return returnXml;
    }


    public string QueryICW(int sessionId,
                            bool debugMode,
                            string routineName,
                            string searchCriteriaXml)
    {
        RoutineRead r = new RoutineRead();

        string dbXml = r.ExecuteByName(sessionId, routineName, searchCriteriaXml);

        string icwXml = r.FormatForOCSGrid(sessionId, dbXml);

        if (debugMode)
            Log("Local XML : " + icwXml);

        return icwXml;
    }
}

public struct IcsNewPatient
{
    public string title;
    public string surname;
    public string firstForename;
    public string secondForename;
    public string dob;
    public string gender;
    public string nhsNumber;
    public string addressLine1;
    public string addressLine2;
    public string addressLine3;
    public string addressLine4;
    public string postcode;

    public IcsNewPatient(string Title,
                         string Surname,
                         string FirstForename,
                         string SecondForename,
                         string Dob,
                         string Gender,
                         string NhsNumber,
                         string Address1,
                         string Address2,
                         string Address3,
                         string Address4,
                         string Postcode)
    {
        title = Title;

        surname = Surname;

        firstForename = FirstForename;

        secondForename = SecondForename;

        dob = Dob;

        gender = Gender;

        nhsNumber = NhsNumber;

        addressLine1 = Address1;

        addressLine2 = Address2;

        addressLine3 = Address3;

        addressLine4 = Address4;

        postcode = Postcode;
    }
}