//===========================================================================
//
//							PCTPatient.cs
//
//  This class holds all business logic for handling PCT
//  patient objects
//
//  This file is comprised of a business object (PCTPatientLine),
//  a business process (PCTgPatientProcessor) and the business object
//  info (PCTPatientObjectInfo).
//  
//	Modification History:
//	09Nov11 AK  Written
//===========================================================================using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;


namespace ascribe.pharmacy.businesslayer
{
    public class PCTPatientLine : IBusinessObject
    {
        public int EntityID { get; set; }
        public string HUHCNo { get; set; }
        public DateTime? HUHCExp { get; set; }
        public bool CSC { get; set; }
        public DateTime? CSCExp { get; set; }
        public bool PermResHokianga { get; set; }
        public bool PHORegistered { get; set; } 
    }

    public class PCTPatientObjectInfo : IBusinessObjectInfo
    {
    }

    public class PCTPatientProcessor : BusinessProcess
    {
        public void Lock(PCTPatientLine patient)
        {
            PCTPatient patientSettings = new PCTPatient();
            patientSettings.LoadByEntityID(patient.EntityID);
            LockRows(patientSettings.Table, patientSettings.TableName, patientSettings.PKColumnName);
        }

        public void Update(PCTPatientLine patient)
        {
            using (PCTPatient patientSettings = new PCTPatient())
            {
                patientSettings.LoadByEntityID(patient.EntityID);
                if (patientSettings.Count == 0)
                {
                    patientSettings.Add();
                }
                patientSettings[0].CSC = patient.CSC;
                patientSettings[0].CSCExpiry = patient.CSCExp;
                patientSettings[0].EntityID = patient.EntityID;
                patientSettings[0].HUHCExpiry = patient.HUHCExp;
                patientSettings[0].HUHCNo = patient.HUHCNo;
                patientSettings[0].PermResHokianga = patient.PermResHokianga;
                patientSettings[0].PHORegistered = patient.PHORegistered;
                patientSettings.Save();
            }
        }

        public void ValidateForUpdate(PCTPatientLine patient)
        {
            string keyName = "EntityID";
            string keyValue = patient.EntityID.ToString();

            if (!string.IsNullOrEmpty(patient.HUHCNo) && patient.HUHCExp == null)
            {
                ValidationErrors.Add(new ValidationError(this, "HUHCExp", keyName, keyValue, ValidationError.PropertyNameTag + " is a required field", true));
            }
            if (patient.CSC && patient.CSCExp == null)
            {
                ValidationErrors.Add(new ValidationError(this, "CSCExp", keyName, keyValue, ValidationError.PropertyNameTag + " is a required field", true));
            }
            if (patient.CSC && patient.PermResHokianga)
            {
                ValidationErrors.Add(new ValidationError(this, "CSC", keyName, keyValue, ValidationError.PropertyNameTag + " cannot be selected with PermResHokianga", true));
            }
        }

        public PCTPatientLine LoadByEntityID(int entityID)
        {
            using (PCTPatient dbPatient = new PCTPatient())
            {
                dbPatient.LoadByEntityID(entityID);
                if (dbPatient.Count == 0)
                {
                    return NewPatient(entityID);
                }
                else
                {
                    return FillData(dbPatient[0]);
                }
            }
        }

        private PCTPatientLine NewPatient(int entityID)
        {
            PCTPatientLine patient = new PCTPatientLine();
            patient.CSC = false;
            patient.CSCExp = null;
            patient.HUHCExp = null;
            patient.EntityID = entityID;
            patient.HUHCNo = null;
            patient.PermResHokianga = false;
            patient.PHORegistered = false;
            return patient;
        }
        
        private PCTPatientLine FillData(PCTPatientRow dbPatientRow)
        {
            PCTPatientLine patient = new PCTPatientLine();
            patient.CSC = dbPatientRow.CSC;
            patient.CSCExp = dbPatientRow.CSCExpiry;
            patient.EntityID = dbPatientRow.EntityID;
            patient.HUHCExp = dbPatientRow.HUHCExpiry;
            patient.HUHCNo = dbPatientRow.HUHCNo;
            patient.PermResHokianga = dbPatientRow.PermResHokianga;
            patient.PHORegistered = dbPatientRow.PHORegistered;
            return patient;
        }
        
    }
}
