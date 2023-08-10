//===========================================================================
//
//							PCTPrescription.cs
//
//  This class holds all business logic for handling a PCT prescription
//  object.
//
//	Modification History:
//	25Nov11 AK  Written
//===========================================================================
using System;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using System.Collections.Generic;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.businesslayer
{
    /// <summary>
    /// Represents a PCT Prescription
    /// </summary>
    public class PCTPrescriptionLine : IBusinessObject
    {
        public int PCTPrescriptionID { get; internal set; }
        public int? RequestID_Prescription { get; set; }
        public int PrescriberEntityID { get; set; }
        public int PCTOncologyPatientGroupingID { get; set; }
        public string PrescriptionFormNumber { get; set; }
        public string SpecialAuthorityNumber { get; set; }
        public int? SpecialistEndorserEntityID { get; set; }
        public DateTime? EndorsementDate { get; set; }
        public bool FullWastage { get; set; }
    }

    /// <summary>
    /// Processes PCT Prescriptions
    /// </summary>
    public class PCTPrescriptionProcessor : BusinessProcess
    {
        /// <summary>
        /// Updates a PCT Prescription object
        /// </summary>
        /// <param name="batch">PCTPrescriptionLine object to update</param>
        public void Update(PCTPrescriptionLine rx)
        {
            using (PCTPrescription dbRx = new PCTPrescription())
            {
                if (rx.PCTPrescriptionID == 0)
                {
                    dbRx.Add();
                }
                else
                {
                    dbRx.LoadByPCTPrescriptionID(rx.PCTPrescriptionID);
                }
                dbRx[0].EndorsementDate = rx.EndorsementDate;
                dbRx[0].FullWastage = rx.FullWastage;
                dbRx[0].PCTOncologyPatientGroupingID = rx.PCTOncologyPatientGroupingID;
                dbRx[0].PrescriberEntityID = rx.PrescriberEntityID;
                dbRx[0].PrescriptionFormNumber = rx.PrescriptionFormNumber;
                dbRx[0].RequestID_Prescription = rx.RequestID_Prescription;
                dbRx[0].SpecialAuthorityNumber = rx.SpecialAuthorityNumber;
                dbRx[0].SpecialistEndorserEntityID = rx.SpecialistEndorserEntityID;
                dbRx.Save();
                rx.PCTPrescriptionID = dbRx[0].PCTPrescriptionID;
            }
        }

        /// <summary>
        /// Validates a PCT Prescription object for update
        /// </summary>
        /// <param name="rx">PCTPrescriptionLine object to be validated</param>
        public void ValidateForUpdate(PCTPrescriptionLine rx)
        {
            string keyName = "PCTPrescriptionID";
            string keyValue = rx.PCTPrescriptionID.ToString();
            if (rx.SpecialistEndorserEntityID != null && rx.EndorsementDate == null)
            {
                ValidationErrors.Add(new ValidationError(this, "EndorsementDate", keyName, keyValue, ValidationError.PropertyNameTag + " is required if the prescription has been ensdorsed by a specialist", true));
            }
            if (rx.PCTOncologyPatientGroupingID == null)
            {
                ValidationErrors.Add(new ValidationError(this, "PCTOncologyPatientGroupingID", keyName, keyValue, ValidationError.PropertyNameTag + " is required", true));
            }
            if (rx.PrescriberEntityID == 0)
            {
                ValidationErrors.Add(new ValidationError(this, "PrescriberEntityID", keyName, keyValue, ValidationError.PropertyNameTag + " is required", true));
            }
            if (string.IsNullOrEmpty(rx.PrescriptionFormNumber))
            {
                ValidationErrors.Add(new ValidationError(this, "PrescriptionFormNumber", keyName, keyValue, ValidationError.PropertyNameTag + " is required", true));
            }
        }

        /// <summary>
        /// Loads a PCT Prescription by PCTPrescriptionID
        /// </summary>
        /// <param name="pctPrescriptionID">The primary key of the record</param>
        /// <returns>A PCTPrescriptionLine object</returns>
        public PCTPrescriptionLine LoadByPCTPrescriptionID(int pctPrescriptionID)
        {
            using (PCTPrescription dbRx = new PCTPrescription())
            {
                dbRx.LoadByPCTPrescriptionID(pctPrescriptionID);
                if (dbRx.Count == 0)
                    throw new ApplicationException(string.Format("PCTPrescription not found (PCTPrescriptionID={0})", pctPrescriptionID));
                return FillData(dbRx[0]);
            }
        }

        /// <summary>
        /// Loads a PCT Prescription by RequestID of the prescription
        /// </summary>
        /// <param name="requestID">The prescriptio request ID</param>
        /// <returns>A PCTPrescriptionLine object</returns>
        public PCTPrescriptionLine LoadByRequestID(int requestID)
        {
            using (PCTPrescription dbRx = new PCTPrescription())
            {
                dbRx.LoadByRequestID(requestID);
                if (dbRx.Count == 0)
                    throw new ApplicationException(string.Format("PCTPrescription not found (RequestID_Prescription={0})", requestID));
                return FillData(dbRx[0]);
            }
        }

        /// <summary>
        /// Fills the PCTPRescriptionLine object with the database object data
        /// </summary>
        /// <param name="dbRxRow">The database object to use to populate</param>
        /// <returns>The filled PCTPrescriptionLine object</returns>
        private PCTPrescriptionLine FillData(PCTPrescriptionRow dbRxRow)
        {
            PCTPrescriptionLine rx = new PCTPrescriptionLine();
            rx.EndorsementDate = dbRxRow.EndorsementDate;
            rx.FullWastage = dbRxRow.FullWastage;
            rx.PCTOncologyPatientGroupingID = dbRxRow.PCTOncologyPatientGroupingID;
            rx.PCTPrescriptionID = dbRxRow.PCTPrescriptionID;
            rx.PrescriberEntityID = dbRxRow.PrescriberEntityID;
            rx.PrescriptionFormNumber = dbRxRow.PrescriptionFormNumber;
            rx.RequestID_Prescription = dbRxRow.RequestID_Prescription;
            rx.SpecialAuthorityNumber = dbRxRow.SpecialAuthorityNumber;
            rx.SpecialistEndorserEntityID = dbRxRow.SpecialistEndorserEntityID;
            return rx;
        }
    }
}
