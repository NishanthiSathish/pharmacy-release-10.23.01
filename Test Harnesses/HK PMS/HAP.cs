//-----------------------------------------------------------------------
// <copyright file="HAP.cs" company="Emis Health">
//   Copyright (c) Emis Health Plc. All rights reserved.
// </copyright>
// <summary>
// Basically this is the form that host a web browser for the HAP
// See Form1 for the processes
// 
// Modification History:
// 15Oct15 XN Created 77977 
// </summary
// -----------------------------------------------------------------------
namespace HK_PMS
{
    using System;
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using System.Diagnostics;
    using System.Linq;
    using System.Security.Principal;
    using System.Transactions;
    using System.Windows.Forms;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.icwdatalayer;
    using ascribe.pharmacy.shared;
    using System.Xml;
    using System.Text;

    /// <summary>form that host a web browser for the HAP</summary>
    public partial class HAP : Form
    {
        /// <summary>Type of call to the hap</summary>
        public enum CallType
        {
            /// <summary>Add PN Prescription</summary>
            [EnumDBCode("N")]
            PNNew,

            /// <summary>View PN regimen</summary>
            [EnumDBCode("V")]
            PNView,

            /// <summary>Modify PN regimen</summary>
            [EnumDBCode("M")]
            PNModify,

            /// <summary>New PN supply request</summary>
            [EnumDBCode("S")]
            PNNewSupplyRequest,

            /// <summary>Cancel PN Regimen</summary>
            PNCancel, 

            /// <summary>Display CIVAS desktop</summary>
            [EnumDBCode("")]
            CIVAS
        }

        /// <summary>Connection state of the form</summary>
        private enum HapConnectionState
        {
            /// <summary>Logging in</summary>
            Login,

            /// <summary>Sending patient\prescription\desktop details to EIE</summary>
            SendPatientDetails,

            /// <summary>Launch the hap</summary>
            LaunchHAP,

            /// <summary>Read the regimen description</summary>
            ReadDescription,

            /// <summary>Canceling patient</summary>
            CancelPatient, 

            /// <summary>Complete loading the hap</summary>
            Complete,

            /// <summary>Logging out</summary>
            Logout
        }

        /// <summary>Current state</summary>
        private HapConnectionState state;

        /// <summary>session id once the user has logged on</summary>
        private int emisSessionId = 0;

        /// <summary>Details (patient\prescription) entered on main form</summary>
        PatientPrescriptionDetails details;

        /// <summary>Type of call PN or CIVAS</summary>
        private CallType callType;

        /// <summary>MSHTA processor used to display main HAP</summary>
        private Process mshtaProcessor = new Process();

        /// <summary>PN descritpion returned at the end</summary>
        public string PnDescription { get; private set; }

        /// <summary>Constructor</summary>
        /// <param name="details">Details (patient\prescription) entered on main form</param>
        /// <param name="callType">Type of call PN or CIVAS</param>
        public HAP(PatientPrescriptionDetails details, CallType callType)
        {
            InitializeComponent();
            details.ICWBaseURL = details.ICWBaseURL.TrimEnd('/');
            this.details    = details;
            this.callType   = callType;
        }

        /// <summary>
        /// Called when the form is loaded
        /// launches the connection wizard
        /// </summary>
        /// <param name="sender">The sender</param>
        /// <param name="e">The event args</param>
        private void HAP_Load(object sender, EventArgs e)
        {
            this.state = HapConnectionState.Login;
            this.MoveToNextStage();
        }

        /// <summary>
        /// Called when web browser completed the current stage
        /// Moves the connection to the next stage
        /// </summary>
        /// <param name="sender">The sender</param>
        /// <param name="e">The event args</param>
        private void webBrowser_DocumentCompleted(object sender, WebBrowserDocumentCompletedEventArgs e)
        {
            this.MoveToNextStage();
        }

        /// <summary>
        /// Called when the form closes
        /// logs the user out (requires canceling the close to allow the operation to complete then re-closed in MoveToNextStage)
        /// 
        /// </summary>
        /// <param name="sender">The sender</param>
        /// <param name="e">The event args</param>
        private void HAP_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (this.emisSessionId != 0)
            {
                this.state = this.details.UseEIE ?  HapConnectionState.ReadDescription : HapConnectionState.Logout;
                this.MoveToNextStage();
                e.Cancel = true;
            }
        }

        /// <summary>Moves to the next stage</summary>
        private void MoveToNextStage()
        {
            switch (this.state)
            {
            case HapConnectionState.Login:
                {
                // Start the login
                this.lbState.Text = "Login";
                string[] userInfo = WindowsIdentity.GetCurrent().Name.Split('\\');
                this.state = this.callType == CallType.PNCancel ? HapConnectionState.CancelPatient : HapConnectionState.SendPatientDetails;
                string url = string.Format("{0}/application/ICW/trusted.aspx?method=LoginAD&Domainname={1}&Username={2}&Computername={3}&Override=True", this.details.ICWBaseURL, userInfo[0], userInfo[1], Environment.MachineName); 
                this.webBrowser.Navigate(url);
                }
                break;

            case HapConnectionState.SendPatientDetails:
                {
                // After login completes moves to next stage
                // If okay document text will be "<ICWResult success='1'><Session id='{number}'/></ICWResult>"
                this.lbState.Text = "Send Patient Info " + (this.details.UseEIE ? " via EIE" : " direct to DB");
                HtmlDocument doc = this.webBrowser.Document;
                HtmlElement  elem= doc.All.OfType<HtmlElement>().FirstOrDefault(t => t.TagName == "SESSION");
                if (elem == null || string.IsNullOrWhiteSpace(elem.GetAttribute("id")))
                {
                    this.emisSessionId = -1;
                    MessageBox.Show("Login failed\n" + doc.Body.InnerHtml);
                }
                else
                {
                    this.state = HapConnectionState.LaunchHAP;
                    this.emisSessionId = int.Parse(elem.GetAttribute("id"));

                    try
                    {
                        if (this.details.UseEIE)
                            this.SendPatientPrescriptionViaEIE();
                        else 
                            this.SendPatientPrescriptionViaDB();
                    }
                    catch(Exception ex)
                    {
                        MessageBox.Show(ex.Message + "\n\n" + ex.StackTrace);
                    }
                }
                }
                break;

            case HapConnectionState.LaunchHAP:
                {
                // Patient details have been saved so launch the HAP
                this.state = HapConnectionState.ReadDescription;

                this.lbState.Text = "Launch HAP";
                string url = string.Format("{0}/application/ICW/trusted.aspx?method=Launch&SessionID={1}&DisplayNavigation=False", this.details.ICWBaseURL, this.emisSessionId); 
                mshtaProcessor.StartInfo = new ProcessStartInfo("mshta.EXE", url);
                mshtaProcessor.Start();
                mshtaProcessor.WaitForExit();
                this.MoveToNextStage();
                }
                break;
 
            case HapConnectionState.ReadDescription:
                {
                this.state = HapConnectionState.Logout;
                this.lbState.Text = "Reading Description";
                if (this.details.UseEIE)
                    this.ReadDescriptionViaEIE();
                else
                    this.ReadDescriptionViaDB();
                }
                break;

            case HapConnectionState.CancelPatient:
                {
                this.lbState.Text = "Sending cancel via EIE";
                HtmlElement  elem= this.webBrowser.Document.All.OfType<HtmlElement>().FirstOrDefault(t => t.TagName == "SESSION");
                if (elem == null || string.IsNullOrWhiteSpace(elem.GetAttribute("id")))
                {
                    this.emisSessionId = -1;
                    MessageBox.Show("Login failed\n" + this.webBrowser.Document.Body.InnerHtml);
                }
                else
                {
                    this.state = HapConnectionState.Logout;
                    this.emisSessionId = int.Parse(elem.GetAttribute("id"));
                    this.CancelRequestViaEIE();
                }
                }
                break;

            case HapConnectionState.Logout:
                {
                // Have logged out so just 0 session ID, and close from
                this.lbState.Text = "Logout";
                string url = string.Format("{0}/application/ICW/trusted.aspx?method=Logout&SessionID={1}", this.details.ICWBaseURL, this.emisSessionId); 
                this.webBrowser.Navigate(url);
                this.emisSessionId = 0;
                this.Close();
                }
                break;
            }
        }

        /// <summary>
        /// Save the patient data to the DB
        /// In real life this is done by the EIE
        /// </summary>
        private void SendPatientPrescriptionViaDB()
        {
            SessionInfo.InitialiseSession(emisSessionId);

            // Alias groups
            int aliasGroupIdCaseNumber             = ICWTypes.GetTypeByDescription(ICWType.AliasGroup, "CaseNumber"     ).Value.ID;
            //int aliasGroupIdHAEpisodeKey           = ICWTypes.GetTypeByDescription(ICWType.AliasGroup, "HAEpisodeKey"   ).Value.ID;
            int aliasGroupIDWSpecialtyCodes        = ICWTypes.GetTypeByDescription(ICWType.AliasGroup, "WSpecialtyCodes").Value.ID;
            int aliasGroupIDExternalPrescriptionID = ICWTypes.GetTypeByDescription(ICWType.AliasGroup, "ExternalPrescriptionID").Value.ID;
            int entityRoleIDConsultant             = Database.ExecuteSQLScalar<int>("SELECT EntityRoleID FROM EntityRole WHERE Description='Consultant'");
            int tableIDPNPrescription              = ICWTypes.GetTypeByDescription(ICWType.Request, "PN Prescription").Value.TableID.Value;
            int requestTypeIDPNPrescription        = ICWTypes.GetTypeByDescription(ICWType.Request, "PN Prescription").Value.ID;
            int entityTypeIdConsultant             = Database.ExecuteSQLScalar<int>("SELECT EntityTypeID FROM EntityType WHERE Description='Consultant'");
            int tableIDConsultant                  = Database.ExecuteSQLScalar<int>("SELECT TableID FROM [Table] WHERE Description='Consultant'");
            List<SqlParameter> parameteres = new List<SqlParameter>();

            int? entityId = Database.ExecuteSQLScalar<int?>("SELECT EntityID FROM EntityAlias WHERE AliasGroupID={0} AND Alias='{1}' AND [Default]=1", aliasGroupIdCaseNumber, this.details.HospitalNumber);

            // Add\Update patient data
            GenericTable2 patient = new GenericTable2("Patient", "Person", "Entity");
            if (entityId == null)
            {
                patient.Add();
                patient[0].RawRow["EntityTypeID"]= Database.ExecuteSQLScalar<int?>("SELECT EntityTypeID FROM EntityType WHERE Description='Patient'");
                patient[0].RawRow["TableID"]     = Database.ExecuteSQLScalar<int?>("SELECT TableID FROM [Table] WHERE Description='Patient'");
            }
            else
            {
                parameteres.Clear();
                parameteres.Add("CurrentSessionID", this.emisSessionId);
                parameteres.Add("EntityID",         entityId );
                patient.LoadBySP("pPatientForPharmacy", parameteres);
            }

            patient[0].RawRow["Description"] = (this.details.Surname + " " + this.details.Forname.TrimStart()[0]).ToUpper();
            patient[0].RawRow["DOB"]         = this.details.DOB.Date;
            patient[0].RawRow["Forename"]    = this.details.Forname;
            patient[0].RawRow["Surname"]     = this.details.Surname;
            patient[0].RawRow["GenderID"]    = EnumViaDBLookupAttribute.ToLookupID(this.details.Sex);
            patient[0].RawRow["NHSNumber"]   = this.details.HKID;

            // Add\Update entity extra info
            GenericTable2 entityExtraInfo = new GenericTable2("EntityExtraInfo");
            if (entityId != null)
            {
                parameteres.Clear();
                parameteres.Add("EntityID", entityId );
                entityExtraInfo.LoadBySQL("SELECT * FROM EntityExtraInfo WHERE EntityID=@EntityID", parameteres);
            }

            if (!entityExtraInfo.Any() && (!string.IsNullOrWhiteSpace(this.details.ChineseName) || this.details.languageType != null))
                entityExtraInfo.Add();
            
            if (entityExtraInfo.Any())
            {
                entityExtraInfo[0].RawRow["ChineseName"]                = this.details.ChineseName;
                entityExtraInfo[0].RawRow["PatientPreferredLanguageID"] = this.details.languageType == null ? (object)DBNull.Value : Database.ExecuteSQLScalar<int>("SELECT PatientPreferredLanguageID FROM PatientPreferredLanguage WHERE Description='{0}'", (object)this.details.languageType.Value);
            }

            // Add\Update episode info
            GenericTable2 episode = new GenericTable2("Episode");
            parameteres.Clear();
            parameteres.Add("HAEpisodeKey", this.details.HAEpisodeKey );
            parameteres.Add("EntityID",     entityId ?? -1 );
            episode.LoadBySQL("SELECT e.* FROM Episode e JOIN EpisodeExtraInfo eei ON e.EpisodeID=eei.EpisodeID AND HAEpisodeKey=@HAEpisodeKey AND e.EntityID=@EntityID", parameteres);
            if (!episode.Any())
            {
                episode.Add();
                episode[0].RawRow["DateCreated"]      = DateTime.Now;
                episode[0].RawRow["EndDate"]          = DBNull.Value;
                episode[0].RawRow["StatusID"]         = 0;
                episode[0].RawRow["EpisodeID_Parent"] = Database.ExecuteSQLScalar<int?>("select TOP 1 EpisodeID from Episode where EntityID={0} and Episode.EpisodeID_Parent = 0 order by EpisodeID", entityId ?? -1) ?? 0;
            }

            episode[0].RawRow["Description"]   = this.details.EpisodeDescription;
            episode[0].RawRow["EpisodeTypeID"] = EnumViaDBLookupAttribute.ToLookupID(this.details.PatientStatus);
            episode[0].RawRow["StartDate"]     = this.details.EpisodeStartDate;

            // Add\Update episode extra info
            GenericTable2 episodeExtraInfo = new GenericTable2("EpisodeExtraInfo");
            parameteres.Clear();
            parameteres.Add("EpisodeID", episode[0].RawRow["EpisodeID"] == DBNull.Value ? -1 : (int)episode[0].RawRow["EpisodeID"]);
            episodeExtraInfo.LoadBySQL("SELECT * FROM EpisodeExtraInfo WHERE EpisodeID=@EpisodeID", parameteres);
            if (!episodeExtraInfo.Any())
            {
                episodeExtraInfo.Add();
            }
            episodeExtraInfo[0].RawRow["HAEpisodeKey"]    = this.details.HAEpisodeKey;
            episodeExtraInfo[0].RawRow["PatientCategory"] = this.details.PatientCategory.SafeSubstring(0, 2);

            // Get ward
            var ward = Ward.GetByWardCode(this.details.WardCode);

            // Add\Update consultant
            GenericTable2 consultant = new GenericTable2("Consultant", "Person", "Entity");
            parameteres.Clear();
            parameteres.Add("CurrentSessionID", this.emisSessionId);
            parameteres.Add("Code",             this.details.MOCode);
            consultant.LoadBySP("pConsultantByCode", parameteres);
            if (!consultant.Any())
            {
                consultant.Add();
                consultant[0].RawRow["EntityTypeID"] = entityTypeIdConsultant;
                consultant[0].RawRow["TableID"]      = tableIDConsultant;
            }
            consultant[0].RawRow["Title"]       = this.details.MOTitle;
            consultant[0].RawRow["Forename"]    = this.details.MOForname;
            consultant[0].RawRow["Surname"]     = this.details.MOSurname;
            consultant[0].RawRow["Description"] = this.details.MOSurname.ToUpper() + ", " + this.details.MOForname.ToLower().ToUpperFirstLetter() + " (" + this.details.MOTitle + ")";

            // Add\Update specialty
            GenericTable2 specialty = new GenericTable2("Specialty");
            int? specialtyID = null;
            if (!string.IsNullOrWhiteSpace(this.details.SpecialtyCode))
            {
                specialtyID = Database.ExecuteSQLScalar<int?>("SELECT SpecialtyID FROM SpecialtyAlias WHERE AliasGroupID={0} AND Alias='{1}' AND [Default]=1", aliasGroupIDWSpecialtyCodes, this.details.SpecialtyCode);
                if (specialtyID == null)
                {
                    specialty.Add();
                    specialty[0].RawRow["out_of_use"] = false;
                }
                specialty[0].RawRow["Description"] = this.details.SpecialtyDesc;
                specialty[0].RawRow["Detail"     ] = this.details.SpecialtyDesc;
            }

            // Get the desktop id
            int desktopId = Database.ExecuteSQLScalar<int>("SELECT TOP 1 DesktopID FROM Desktop WHERE Description='{0}'", this.callType == CallType.CIVAS ? this.details.CIVASDesktopName : this.details.PNDesktopName);

            var transOptions = new TransactionOptions();
            transOptions.IsolationLevel = System.Transactions.IsolationLevel.ReadCommitted;

            using (TransactionScope trans = new TransactionScope(TransactionScopeOption.Required, transOptions))
            {
                // Save patient
                patient.Save();
                entityId = (int)patient[0].RawRow["EntityID"];

                // Save extra info
                if (entityExtraInfo.Any())
                    entityExtraInfo[0].RawRow["EntityID"] = entityId;
                entityExtraInfo.Save();

                // Save episode
                episode[0].RawRow["EntityID"] = entityId;
                episode.Save();
                int episodeId = (int)episode[0].RawRow["EpisodeID"];

                // save episodeExtraInfo
                episodeExtraInfo[0].RawRow["EpisodeID"] = episodeId;
                episodeExtraInfo.Save();

                // Save consultant
                consultant.Save();
                int consultantId = (int)consultant[0].RawRow["EntityID"];

                // Save specialty
                specialty.Save();
                if (specialty.Any())
                    specialtyID = (int)specialty[0].RawRow["SpecialtyID"];

                // Save EntityAlias info
                patient.RemoveAllAliasByAliasGroup(entityId.Value, "CaseNumber");
                patient.AddAlias(entityId.Value, "CaseNumber", this.details.HospitalNumber, true);
                patient.RemoveAllAliasByAliasGroup(entityId.Value, "HospitalCode");
                patient.AddAlias(entityId.Value, "HospitalCode", this.details.HAHospitalCode.ToString(), true);
                patient.RemoveAllAliasByAliasGroup(entityId.Value, "HKID");
                patient.AddAlias(entityId.Value, "HKID", this.details.HKID, true);

                // Save EpisodeAlias info
                //episode.RemoveAllAliasByAliasGroup(episodeId, "PatientCategory");
                //episode.AddAlias(episodeId, "PatientCategory", this.details.PatientCategory, true);
                //episode.RemoveAllAliasByAliasGroup(episodeId, "HAEpisodeKey");
                //episode.AddAlias(episodeId, "HAEpisodeKey", this.details.HAEpisodeKey, true);

                // Save consultant code
                consultant.RemoveAllAliasByAliasGroup(consultantId, "WConsultantCodes");
                consultant.AddAlias(consultantId, "WConsultantCodes", this.details.MOCode, true);

                // Save specialty
                if (specialtyID != null)
                {
                    specialty.RemoveAllAliasByAliasGroup(specialtyID.Value, "WSpecialtyCodes");
                    specialty.AddAlias(specialtyID.Value, "WSpecialtyCodes", this.details.SpecialtyCode, true);
                }

                // Save episode location
                Database.ExecuteSQLNonQuery("UPDATE EpisodeLocation SET Active=(CASE WHEN LocationID={0} THEN 1 ELSE 0 END) WHERE EpisodeID={1}", ward.LocationID, episodeId);
                if (Database.ExecuteSQLScalar<int?>("SELECT TOP 1 1 FROM EpisodeLocation WHERE EpisodeID={0} AND LocationID={1}", episodeId, ward.LocationID) == null)
                    Database.ExecuteSQLNonQuery("INSERT INTO EpisodeLocation (EpisodeID, LocationID, [Active]) VALUES ({0}, {1}, 1)", episodeId, ward.LocationID);

                // Save ResponsibleEpisodeEntity
                Database.ExecuteSQLNonQuery("UPDATE ResponsibleEpisodeEntity SET Active=(CASE WHEN EntityID={0} THEN 1 ELSE 0 END) WHERE EpisodeID={1}", consultantId, episodeId);
                if (Database.ExecuteSQLScalar<int?>("SELECT TOP 1 1 FROM ResponsibleEpisodeEntity WHERE EpisodeID={0} AND EntityID={1}", episodeId, consultantId) == null)
                    Database.ExecuteSQLNonQuery("INSERT INTO ResponsibleEpisodeEntity (EpisodeID, EntityID, EntityRoleID, [Active]) VALUES ({0}, {1}, {2}, 1)", episodeId, consultantId, entityRoleIDConsultant);

                // Save specialty
                if (specialtyID != null)
                {
                    if (Database.ExecuteSQLScalar<int?>("SELECT TOP 1 1 FROM EntityLinkSpecialty WHERE EntityID={0} AND SpecialtyID={1}", consultantId, specialtyID) == null)
                        Database.ExecuteSQLNonQuery("INSERT INTO EntityLinkSpecialty (EntityID, SpecialtyID) VALUES ({0}, {1})", consultantId, specialtyID);
                }

                SessionInfo.SaveAttribute("RequestAlias/BedNumber",              this.details.bedNumber);
                SessionInfo.SaveAttribute("RequestAlias/ExternalPrescriptionID", this.details.selectPMSPrescriptionID.ToString());
                SessionInfo.SaveAttribute("RequestAlias/ExistingExternalPrescriptionID", this.details.existingPMSPrescriptionID.ToString());

                // If PN save the prescription information
                switch (this.callType)
                {
                case CallType.PNNew:
                    SessionInfo.SaveAttribute("RequestAlias/mode", "N");
                    break;

                case CallType.PNNewSupplyRequest:
                    SessionInfo.SaveAttribute("RequestAlias/mode",  "S");
                    break;

                case CallType.PNModify:
                    SessionInfo.SaveAttribute("RequestAlias/mode", "M");
                    break;

                case CallType.PNView:
                    SessionInfo.SaveAttribute("RequestAlias/mode", "V");
                    break;
                }

                // Save state info
                SessionInfo.SetStatePKByTable("Entity",  entityId.Value);
                SessionInfo.SetStatePKByTable("Episode", episodeId     );
                SessionInfo.SetStatePKByTable("Desktop", desktopId     );

                trans.Complete();
            }

            // Move to next stage
            webBrowser_DocumentCompleted(this, null);
        }

        /// <summary>Send patient data via EIE</summary>
        private void SendPatientPrescriptionViaEIE()
        {
            SessionInfo.InitialiseSession(emisSessionId);

            try
            {
                XmlWriterSettings settings = new XmlWriterSettings();
                settings.Encoding = Encoding.ASCII;

                StringBuilder str = new StringBuilder();
                using (XmlWriter xml = XmlWriter.Create(str, settings))
                {
                    xml.WriteStartElement("PatientAndEpisodeInfo");
                
                    xml.WriteStartElement("PatientIdentifiers");
                    xml.WriteElementString("HKID", this.details.HKID);
                    xml.WriteElementString("HospitalNumber", this.details.HospitalNumber);
                    xml.WriteEndElement();

                    xml.WriteStartElement("PatientNames");
                    xml.WriteElementString("PatientForename", this.details.Forname);
                    xml.WriteElementString("PatientSurname", this.details.Surname);
                    xml.WriteElementString("ChineseName",    this.details.ChineseName);
                    xml.WriteEndElement();

                    xml.WriteStartElement("PatientDetails");
                    xml.WriteElementString("DateOfBirth", this.details.DOB.ToString("yyyy-MM-dd"));
                    xml.WriteElementString("Sex", this.details.Sex.ToString().Substring(0, 1));
                    xml.WriteElementString("Language", this.details.languageType == null ? string.Empty : EnumDBCodeAttribute.EnumToDBCode(this.details.languageType.Value));
                    xml.WriteEndElement();

                    xml.WriteElementString("PmsPnId",         this.callType == CallType.CIVAS ? string.Empty : this.details.selectPMSPrescriptionID.ToString());
                    xml.WriteElementString("ExistingPmsPnId", this.callType != CallType.PNNewSupplyRequest ? string.Empty : this.details.existingPMSPrescriptionID.ToString());
                    xml.WriteElementString("DesktopName", this.callType == CallType.CIVAS ? this.details.CIVASDesktopName : this.details.PNDesktopName);
                    xml.WriteElementString("Mode", EnumDBCodeAttribute.EnumToDBCode(this.callType));

                    xml.WriteStartElement("EpisodeInformation");
                    xml.WriteElementString("HAEpisodeKey", this.details.HAEpisodeKey);
                    xml.WriteElementString("EpisodeDescription", this.details.EpisodeDescription);
                    xml.WriteElementString("EpisodeStartDate", this.details.EpisodeStartDate.ToString("yyyy-MM-dd"));
                    xml.WriteElementString("HAHospitalCode", this.details.HAHospitalCode.ToString());
                    xml.WriteElementString("WardCode", this.details.WardCode);
                    xml.WriteElementString("PatientCategory", this.details.PatientCategory.SafeSubstring(0, 2));
                    xml.WriteElementString("PatientStatus", this.details.PatientStatus.ToString().Substring(0, 1));
                    xml.WriteElementString("BedNumber", this.details.bedNumber);
                    xml.WriteEndElement();

                    xml.WriteStartElement("Specialty");
                    xml.WriteElementString("SpecialtyCode", this.details.SpecialtyCode);
                    xml.WriteElementString("SpecialtyDescription", this.details.SpecialtyDesc);
                    xml.WriteEndElement();

                    xml.WriteStartElement("MedicationOfficer");
                    xml.WriteElementString("MedicationOfficerCode", this.details.MOCode);
                    xml.WriteElementString("MedicationOfficerTitle", this.details.MOTitle);
                    xml.WriteElementString("MedicationOfficerForename", this.details.MOForname);
                    xml.WriteElementString("MedicationOfficerSurname", this.details.MOSurname);
                    xml.WriteEndElement();

                    xml.WriteEndElement();

                    xml.Flush();
                    xml.Close();
                }

                // Remove the 
                string result = null;
                using (EIE.IntegrationWebServiceClient webService = new EIE.IntegrationWebServiceClient("WSHttpBinding_IIntegrationWebService", this.details.EIEBaseURL))
                {
                    result = webService.Write(SessionInfo.SessionID.ToString(), "PMS", "PMSPATEP", str.ToString());
                }

                if (string.IsNullOrEmpty(result))
                {
                    throw new ApplicationException("Failed to get a reply from the EIE web service:\n" + this.details.EIEBaseURL);
                }
                else
                {
                    System.Xml.Linq.XElement resultXml = System.Xml.Linq.XElement.Parse(result);
                    if (resultXml.Attribute("Success") == null || !BoolExtensions.PharmacyParse(resultXml.Attribute("Success").Value))
                    {
                        var errorElem = resultXml.Element("Errors").Element("Error");
                        throw new ApplicationException(errorElem.Attribute("Message").Value);
                    }
                }
            
                // Move to next stage
                webBrowser_DocumentCompleted(this, null);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message + "\n\n" + ex.StackTrace);
            }
        }

        /// <summary>Read the PN description from the db via the EIE</summary>
        private void ReadDescriptionViaEIE()
        {
            try
            {
                XmlWriterSettings settings = new XmlWriterSettings();
                settings.Encoding = Encoding.ASCII;

                StringBuilder str = new StringBuilder();
                using (XmlWriter xml = XmlWriter.Create(str, settings))
                {
                    xml.WriteStartElement("parameters");
                    xml.WriteStartElement("parameter");
                    xml.WriteAttributeString("name", "PMSPNID");
                    xml.WriteAttributeString("value", details.selectPMSPrescriptionID.ToString());
                    xml.WriteEndElement();
                    xml.WriteEndElement();

                    xml.Flush();
                    xml.Close();
                }

                // Remove the 
                string result = null;
                using (EIE.IntegrationWebServiceClient webService = new EIE.IntegrationWebServiceClient("WSHttpBinding_IIntegrationWebService", this.details.EIEBaseURL))
                {
                    result = webService.Read(SessionInfo.SessionID.ToString(), "PMS", "PMSPNID", str.ToString());
                }

                if (string.IsNullOrEmpty(result))
                {
                    throw new ApplicationException("Failed to get a reply from the EIE web service:\n" + this.details.EIEBaseURL);
                }
                else
                {
                    System.Xml.Linq.XElement resultXml = System.Xml.Linq.XElement.Parse(result);
                    if (resultXml.Attribute("Success") != null && BoolExtensions.PharmacyParse(resultXml.Attribute("Success").Value) && resultXml.Element("results").Element("results").Element("PnRequestReply") != null)
                    {
                        this.PnDescription = resultXml.Element("results").Element("results").Element("PnRequestReply").Attribute("PnDescription").Value;
                    }
                }
            
                // Move to next stage
                webBrowser_DocumentCompleted(this, null);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message + "\n\n" + ex.StackTrace);
            }
        }

        /// <summary>Read request name from db</summary>
        private void ReadDescriptionViaDB()
        {
            var desc = Database.ExecuteSQLScalar<string>("SELECT r.Description FROM Request r JOIN RequestAlias ra ON r.RequestID=ra.RequestID WHERE ra.Alias='{0}' AND ra.AliasGroupID={1} AND ra.[Default]=1 ORDER BY r.RequestID desc", this.details.selectPMSPrescriptionID, ICWTypes.GetTypeByDescription(ICWType.AliasGroup, "ExternalPrescriptionID").Value.ID); 
            this.PnDescription = desc;
            webBrowser_DocumentCompleted(this, null);
        }

        /// <summary>Called to cancel a request via the EIE</summary>
        private void CancelRequestViaEIE()
        {
            SessionInfo.InitialiseSession(emisSessionId);

            try
            {
                XmlWriterSettings settings = new XmlWriterSettings();
                settings.Encoding = Encoding.ASCII;

                StringBuilder str = new StringBuilder();
                using (XmlWriter xml = XmlWriter.Create(str, settings))
                {
                    xml.WriteStartElement("PNRequestCancellation");
                    xml.WriteElementString("PmsPnId", this.details.selectPMSPrescriptionID.ToString());
                    xml.WriteElementString("Reason", details.CancelReason);
                    xml.WriteEndElement();

                    xml.Flush();
                    xml.Close();
                }

                // Remove the 
                string result = null;
                using (EIE.IntegrationWebServiceClient webService = new EIE.IntegrationWebServiceClient("WSHttpBinding_IIntegrationWebService", this.details.EIEBaseURL))
                {
                    result = webService.Write(SessionInfo.SessionID.ToString(), "PMS", "PMSCAN", str.ToString());
                }

                if (string.IsNullOrEmpty(result))
                {
                    throw new ApplicationException("Failed to get a reply from the EIE web service:\n" + this.details.EIEBaseURL);
                }
                else
                {
                    System.Xml.Linq.XElement resultXml = System.Xml.Linq.XElement.Parse(result);
                    if (resultXml.Attribute("Success") == null || !BoolExtensions.PharmacyParse(resultXml.Attribute("Success").Value))
                    {
                        var errorElem = resultXml.Element("Errors").Element("Error");
                        throw new ApplicationException(errorElem.Attribute("Message").Value);
                    }
                }
            
                // Move to next stage
                webBrowser_DocumentCompleted(this, null);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message + "\n\n" + ex.StackTrace);
            }
        }
    }
}
