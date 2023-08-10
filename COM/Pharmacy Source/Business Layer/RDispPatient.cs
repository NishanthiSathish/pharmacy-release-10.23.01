//===========================================================================
//
//							RDispPatient.cs
//
//  This class holds all business logic for handling repeat dispensing
//  patient objects which are a combination of basic patient information
//  and their associated settings.
//
//  This file is comprised of a business object (RepeatDispensingPatientLine),
//  a business process (RepeatDispensingPatientProcessor) and the business object
//  info (RepeatDispensingPatientObjectInfo).
//  
//	Modification History:
//	20May09 AK  Written
//  15Mar11 TH  Added Additional Information for F0082043 - Repeat Dispensing schedule print
//  17May11 XN  Removed BagLabels, and added RepeatDispensingTemplateID F0057909 
//  16Apr12 AJK 31236 Added Updated, UpdatedBy and UpdatedByDescription fields
//===========================================================================
using System;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using System.Collections.Generic;
using ascribe.pharmacy.shared;
using System.Xml.Linq;
using System.Linq;
using ascribe.pharmacy.icwdatalayer;

// 20Mar12 AJK Changed references to PharmacyPatientInfo from RDispPatientInfo
namespace ascribe.pharmacy.businesslayer
{
    /// <summary>
    /// Represents a single repeat dispensing patient
    /// </summary>
    public class RepeatDispensingPatientLine : IBusinessObject
    {
        public int              EntityID                                 { get; set; }
        public string           FullName                                 { get; set; }
        public DateTime?        DOB                                      { get; set; }
        public string           Forename                                 { get; set; }
        public string           Surname                                  { get; set; }
        public int?             RepeatDispensingPatientID                { get; set; }
        public int?             SupplyDays                               { get; set; }
        public bool?            ADM                                      { get; set; }
        public bool?            InUse                                    { get; set; }
        public SupplyPattern?   SupplyPattern                            { get; set; }
        public string           HospitalNumber                           { get; set; }
        public string           AdditionalInformation                    { get; set; }
        public int?             RepeatDispensingBatchTemplateID          { get; set; }            // 16May11 XN Added
        public string           RepeatDispensingBatchTemplateDescription { get; internal set; }   // 16May11 XN Added
        public bool?            Available                                { get; internal set; }
        public string           MatchedDescription                       { get; internal set; }
        public int?             EpisodeID                                { get; internal set; }   // 09Jun11 TH Added
        public DateTime?        Updated                                  { get; internal set; } // 16Apr12 AJK 31236 Added
        public int?             UpdatedBy                                { get; set; }          // 16Apr12 AJK Added Added
        public string           UpdatedByDescription                     { get; internal set; } // 16Apr12 AJK 31236 Added
    }

    /// <summary>
    /// Returns information about the repeat dispensing patient structure
    /// </summary>
    public class RepeatDispensingPatientObjectInfo : IBusinessObjectInfo
    {
    }

    /// <summary>
    /// Processes repeat dispensing patient objects
    /// </summary>
    public class RepeatDispensingPatientProcessor : BusinessProcess
    {
        /// <summary>
        /// Locks the repeat dispensing patient setting table
        /// </summary>
        /// <param name="patient">Repeat dispensing patient setting object to lock</param>
        public void Lock(RepeatDispensingPatientLine patient)
        {
            RepeatDispensingPatient patientSettings = new RepeatDispensingPatient();
            patientSettings.LoadByEntityID(patient.EntityID);
            LockRows(patientSettings.Table, patientSettings.TableName, patientSettings.PKColumnName);
        }

        /// <summary>
        /// Updates the repeat dispensing patient settings table
        /// </summary>
        /// <param name="patient">Patient object to validate</param>
        public void Update(RepeatDispensingPatientLine patient)
        {
            using (RepeatDispensingPatient patientSettings = new RepeatDispensingPatient())
            {
                patientSettings.LoadByEntityID(patient.EntityID);
                if (patientSettings.Count == 0) // No existing record so add one
                {
                    patientSettings.Add();
                }
                patientSettings[0].EntityID = patient.EntityID;
                patientSettings[0].SupplyDays = patient.SupplyDays;
                patientSettings[0].ADM = patient.ADM;
                patientSettings[0].InUse = patient.InUse;
                patientSettings[0].SupplyPattern = patient.SupplyPattern;
                patientSettings[0].AdditionalInformation = patient.AdditionalInformation;
                patientSettings[0].RepeatDispensingBatchTemplateID = patient.RepeatDispensingBatchTemplateID;                     // 16May11 XN Added
                patientSettings[0].Updated = DateTime.Now; // 16Apr12 AJK 31236 Added
                patientSettings[0].UpdatedBy = SessionInfo.EntityID; // 16Apr12 AJK 31236 Added
                patientSettings.Save();
            }
        }

        /// <summary>
        /// Validates a patient object for update
        /// </summary>
        /// <param name="patient">Patient object to validate</param>
        public void ValidateForUpdate(RepeatDispensingPatientLine patient)
        {
            string keyName = "EntityID";
            string keyValue = patient.EntityID.ToString();
            RepeatDispensingValidation validation = new RepeatDispensingValidation();

            if (patient.SupplyDays == null)
            {
                ValidationErrors.Add(new ValidationError(this, "SupplyDays", keyName, keyValue, ValidationError.PropertyNameTag + " is a required field", true));
            }
            else
            {
                //If ADM is ttue then supply days must be in whole weeks
                if (patient.ADM != null && patient.ADM == true && patient.SupplyDays % 7 != 0 && (validation.GetPackerName() == "MTS"))
                {
                    ValidationErrors.Add(new ValidationError(this, "SupplyDays", keyName, keyValue, ValidationError.PropertyNameTag + " must be in a whole number of weeks", true));
                }
                if (patient.SupplyDays < 1 || patient.SupplyDays > 99)
                {
                    ValidationErrors.Add(new ValidationError(this, "SupplyDays", keyName, keyValue, ValidationError.PropertyNameTag + " must be between 1 and 99", true));
                }
            }
        }

        /// <summary>
        /// Loads a patient object by EntityID
        /// </summary>
        /// <param name="entityID">EntityID for the required patient</param>
        /// <returns>RepeatDispensingPatientLine object</returns>
        public RepeatDispensingPatientLine LoadByEntityID(int entityID)
        {
            using (PharmacyPatientInfo dbPatient = new PharmacyPatientInfo())
            {
                dbPatient.LoadByEntityID(entityID);
                if (dbPatient.Count == 0)
                    throw new ApplicationException(string.Format("Patient not found (entityID={0})", entityID));
                return FillData(dbPatient[0]);
            }
        }

        /// <summary>
        /// Returns a list of patient objects by BatchID
        /// </summary>
        /// <param name="batchID">BatchID for the selected batch of patients</param>
        /// <returns>List of RepeatDispensingPatientLine objects</returns>
        public List<RepeatDispensingPatientLine> LoadByBatchID(int batchID)
        {
            List<RepeatDispensingPatientLine> patientList = new List<RepeatDispensingPatientLine>();
            using (PharmacyPatientInfo dbPatient = new PharmacyPatientInfo())
            {
                dbPatient.LoadByBatchID(batchID);
                for (int i = 0; i < dbPatient.Count; i++)
                {
                    patientList.Add(FillData(dbPatient[i]));
                }
                return patientList;
            }
        }

        /// <summary>
        /// Takes an XDocment of entity elements and converts them to a list of repeat dispensing patients
        /// </summary>
        /// <param name="xDoc">XDocument containing entity elements to be converted</param>
        /// <returns></returns>
        public List<RepeatDispensingPatientLine> LoadByEntityXML(XDocument xDoc)
        {
            List<RepeatDispensingPatientLine> patientListXML = (from patient in xDoc.Descendants("Entity")
                                                                  orderby (string)patient.Attribute("Surname"), (string)(patient.Attribute("Forename") == null ? "" : patient.Attribute("Forename").Value)
                                                                select new RepeatDispensingPatientLine
                                                                {
                                                                  EntityID = int.Parse(patient.Attribute("EntityID").Value),
                                                                  DOB = (patient.Attribute("DOB") == null ? (DateTime?)null : (DateTime?)DateTime.Parse(patient.Attribute("DOB").Value)),
                                                                  Forename = (patient.Attribute("Forename") == null ? null : patient.Attribute("Forename").Value),
                                                                  Surname = patient.Attribute("Surname").Value,
                                                              }).ToList<RepeatDispensingPatientLine>();
            //return patientList;sysadmi
            List<RepeatDispensingPatientLine> patientList = new List<RepeatDispensingPatientLine>();
            foreach (RepeatDispensingPatientLine patientXML in patientListXML)
            {
                using (PharmacyPatientInfo dbPatient = new PharmacyPatientInfo())
                {
                    dbPatient.LoadByEntityID(patientXML.EntityID);
                    if (dbPatient.Count == 0)
                        throw new ApplicationException(string.Format("Patient not found (entityID={0})", patientXML.EntityID));
                    patientList.Add(FillData(dbPatient[0]));
                }
            }
            return patientList;
        }

        public List<RepeatDispensingPatientLine> LoadAvailable(int batchID)
        {
            List<RepeatDispensingPatientLine> patientList = new List<RepeatDispensingPatientLine>();
            using (PharmacyPatientInfo dbPatient = new PharmacyPatientInfo())
            {
                dbPatient.LoadAvailable(batchID);
                for (int i = 0; i < dbPatient.Count; i++)
                {
                    patientList.Add(FillData(dbPatient[i]));
                }
                return patientList;
            }
        }

        /// <summary>
        /// Copies data from a Patient data layer object into a RepeatDispensingPatientLine business layer object
        /// </summary>
        /// <param name="dbPatientRow">RDispPatientInfoRow from the data layer used for data source</param>
        /// <returns>Filled RepeatDispensingPatientLine object</returns>
        private RepeatDispensingPatientLine FillData(RDispPatientInfoRow dbPatientRow)
        {
            RepeatDispensingPatientLine patient = new RepeatDispensingPatientLine();
            patient.EntityID = dbPatientRow.EntityID;
            patient.FullName = dbPatientRow.FullName;
            patient.DOB = dbPatientRow.DOB;
            patient.Forename = dbPatientRow.Forename;
            patient.Surname = dbPatientRow.Surname;
            patient.RepeatDispensingPatientID = dbPatientRow.RepeatDispensingPatientID;
            patient.SupplyDays = dbPatientRow.SupplyDays;
            patient.ADM = dbPatientRow.ADM;
            patient.InUse = dbPatientRow.InUse;
            patient.SupplyPattern = dbPatientRow.SupplyPattern;
            patient.HospitalNumber = dbPatientRow.HospitalNumber;
            patient.AdditionalInformation = dbPatientRow.AdditionalInformation;  //17Mar11TH Added
            patient.RepeatDispensingBatchTemplateID = dbPatientRow.RepeatDispensingBatchTemplateID;   // 16May11 XN Added
            patient.RepeatDispensingBatchTemplateDescription = dbPatientRow.RepeatDispensingBatchTemplateDescription;  // 16May11 XN Added
            patient.Available = dbPatientRow.Available;
            patient.MatchedDescription = dbPatientRow.MatchedDescription;
            patient.EpisodeID = dbPatientRow.EpisodeID;   //09Jun11 TH Added
            patient.Updated = dbPatientRow.RepeatDispensingPatientSettingsUpdated; // 16Apr12 AJK 31236 Added
            patient.UpdatedBy = dbPatientRow.RepeatDispensingPatientSettingsUpdatedBy; // 16Apr12 AJK 31236 Added
            patient.UpdatedByDescription = dbPatientRow.RepeatDispensingPatientSettingsUpdatedByDescription; // 16Apr12 AJK 31236 Added
            return patient;
        }

        /// <summary>
        /// Returns the requested patients details as a string
        /// </summary>
        /// <param name="entityID">EntityID of the requested patient</param>
        /// <returns>String details of patient in format Forename Surname (DOB), HospitalNumber = X</returns>
        public static string PatientDetailsString(int entityID)
        {
            string output = "";
            using (PharmacyPatientInfo dbPatient = new PharmacyPatientInfo())
            {
                dbPatient.LoadByEntityID(entityID);
                if (dbPatient.Count == 0)
                    throw new ApplicationException(string.Format("Patient not found (entityID={0})", entityID));
                if (!string.IsNullOrEmpty(dbPatient[0].Surname))
                {
                    output = dbPatient[0].Surname;
                    if (!string.IsNullOrEmpty(dbPatient[0].Forename))
                    {
                        output = dbPatient[0].Forename + " " + output;
                    }
                }
                if (dbPatient[0].DOB.HasValue)
                    output += " (" + dbPatient[0].DOB.ToPharmacyDateString() + ")";
                if (dbPatient[0].HospitalNumber != null)
                    output += ", HospitalNumber = " + dbPatient[0].HospitalNumber;
            }
            return output;
        }

        /// <summary>
        /// Returns the requested patient and prescription details as a string
        /// </summary>
        /// <param name="entityID">EntityID of the requested patient</param>
        /// <param name="requestID">RequestID for the requested prescription</param>
        /// <returns>String details of the patient and prescription in the format Forename Surname (DOB), HospitalNumber = X, PrescriptionDescription = Y</returns>
        public static string PatientAndPrescriptionDetails(int entityID, int requestID)
        {
            string output = "";
            using (PharmacyPatientInfo dbPatient = new PharmacyPatientInfo())
            {
                dbPatient.LoadByEntityID(entityID);
                if (dbPatient.Count == 0)
                    throw new ApplicationException(string.Format("Patient not found (entityID={0})", entityID));
                if (!string.IsNullOrEmpty(dbPatient[0].Surname))
                {
                    output = dbPatient[0].Surname;
                    if (!string.IsNullOrEmpty(dbPatient[0].Forename))
                    {
                        output = dbPatient[0].Forename + " " + output;
                    }
                }
                if (dbPatient[0].DOB.HasValue)
                    output += " (" + dbPatient[0].DOB.ToPharmacyDateString() + ")";
                if (dbPatient[0].HospitalNumber != null)
                    output += ", HospitalNumber = " + dbPatient[0].HospitalNumber;
            }
            using (Request dbRequest = new Request())
            {
                dbRequest.LoadByRequestID(requestID);
                if (dbRequest.Count == 0)
                    throw new ApplicationException(string.Format("Request not found (requestID={0})", requestID));
                if (!string.IsNullOrEmpty(dbRequest[0].Description))
                {
                    output += ", PrescriptionDescription = " + dbRequest[0].Description;
                }
            }
            return output;
        }
    }
}
