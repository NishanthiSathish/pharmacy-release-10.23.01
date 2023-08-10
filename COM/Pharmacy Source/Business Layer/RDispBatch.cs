//===========================================================================
//
//							RDispBatch.cs
//
//  This class holds all business logic for handling repeat dispensing
//  batch object.
//
//	Modification History:
//	20May09 AK  Written
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
    /// Represents a repeat dispensing batch
    /// </summary>
    public class RepeatDispensingBatchLine : IBusinessObject
    {
        public int                                  BatchID                     { get; internal set; }
        public string                               Description                 { get; set; }
        public BatchStatus                          Status                      { get; set; }
        public int                                  Factor                      { get; set; }
        public List<RepeatDispensingPatientLine>    PatientList                 { get; set; }
        public int?                                 RepeatDispensingTemplateID  { get; set; }
        public DateTime?                            StartDate                   { get; set; }
        public int?                                 StartSlot                   { get; set; }
        public int?                                 TotalSlots                  { get; set; }
        public bool?                                Breakfast                   { get; set; }
        public bool?                                Lunch                       { get; set; }
        public bool?                                Tea                         { get; set; }
        public bool?                                Night                       { get; set; }
        public int?                                 BagLabelsPerPatient         { get; set; }
        public bool?                                SortByDate                  { get; set; }
        public int?                                 LocationID                  { get; set; }
        public string                               LocationDescription         { get; internal set; }
        public bool?                                IncludeManual               { get; set; }
    }

    /// <summary>
    /// Processes repeat dispensing batches
    /// </summary>
    public class RepeatDispensingBatchProcessor : BusinessProcess
    {
        /// <summary>
        /// Updates a repeat dispensing batch object and writes to the auditlog
        /// </summary>
        /// <param name="batch">RepeatDispensingBatchLine object to update</param>
        public void Update(RepeatDispensingBatchLine batch)
        {
            using (RepeatDispensingBatch dbBatch = new RepeatDispensingBatch())
            {
                if (batch.BatchID == 0)
                {
                    dbBatch.Add();
                }
                else
                {
                    dbBatch.LoadByBatchID(batch.BatchID);
                }
                dbBatch[0].Description = batch.Description;
                dbBatch[0].Status = batch.Status;
                dbBatch[0].Factor = batch.Factor;
                dbBatch[0].RepeatDispensingBatchTemplateID = batch.RepeatDispensingTemplateID;
                dbBatch[0].StartDate = batch.StartDate;
                dbBatch[0].StartSlot = batch.StartSlot;
                dbBatch[0].TotalSlots = batch.TotalSlots;
                dbBatch[0].Breakfast = batch.Breakfast;
                dbBatch[0].Lunch = batch.Lunch;
                dbBatch[0].Tea = batch.Tea;
                dbBatch[0].Night = batch.Night;
                dbBatch[0].BagLabelsPerPatient = batch.BagLabelsPerPatient;
                dbBatch[0].SortByDate = batch.SortByDate;
                dbBatch[0].LocationID = batch.LocationID;
                dbBatch[0].IncludeManual = batch.IncludeManual;
                dbBatch.Save();
                batch.BatchID = dbBatch[0].BatchID;
                int patientCount = 0;
                using (RepeatDispensingPatientProcessor patient = new RepeatDispensingPatientProcessor())
                {
                    List<RepeatDispensingPatientLine> selectedPatients = new List<RepeatDispensingPatientLine>();
                    selectedPatients = patient.LoadByBatchID(batch.BatchID);
                    patientCount = selectedPatients.Count;
                }
                if (batch.PatientList != null && batch.PatientList.Count > 0 && patientCount == 0)
                {
                    if (batch.PatientList != null)
                    {
                        foreach (RepeatDispensingPatientLine patient in batch.PatientList)
                        {
                            RepeatDispensingBatch.AddPatient(batch.BatchID, patient.EntityID);
                        }
                    }
                }
            }
            using (RepeatDispensingBatchAuditLog dbAuditLog = new RepeatDispensingBatchAuditLog())
            {
                dbAuditLog.Add();
                dbAuditLog[0].BatchID = batch.BatchID;
                dbAuditLog[0].EntityID = SessionInfo.EntityID;
                dbAuditLog[0].Status = batch.Status;
                dbAuditLog[0].DateChanged = DateTime.Now;
                dbAuditLog.Save();
            }
        }

        /// <summary>
        /// Validates a repeat dispensing batch object for update
        /// </summary>
        /// <param name="batch">RepeatDispensingBatchLine object to be validated</param>
        public void ValidateForUpdate(RepeatDispensingBatchLine batch)
        {
            string keyName = "BatchID";
            string keyValue = batch.BatchID.ToString();
            
            if (batch.Description == null)
            {
                ValidationErrors.Add(new ValidationError(this, "Description", keyName, keyValue, ValidationError.PropertyNameTag + " is required", true));
            }
            else
            {
                if (batch.Description.Length < 5)
                {
                    ValidationErrors.Add(new ValidationError(this, "Description", keyName, keyValue, ValidationError.PropertyNameTag + " must be at least 5 characters in length", true));
                }
                else
                {
                    if (batch.Description.Length > RepeatDispensingBatch.GetColumnInfo().DescriptionLength)
                    {
                        ValidationErrors.Add(new ValidationError(this, "Description", keyName, keyValue, ValidationError.PropertyNameTag + " length may not exceed " + RepeatDispensingBatch.GetColumnInfo().DescriptionLength.ToString() + " characters", true));
                    }
                    else
                    {
                        //Check the description is not in use by any active batch
                        using (RepeatDispensingBatch tempdbBatch = new RepeatDispensingBatch())
                        {
                            tempdbBatch.LoadActiveByDescription(batch.Description);
                            for (int i = 0; i < tempdbBatch.Count; i++)
                            {
                                if (batch.BatchID != tempdbBatch[i].BatchID)
                                {
                                    ValidationErrors.Add(new ValidationError(this, "Description", keyName, keyValue, string.Format(ValidationError.PropertyNameTag + " must be unique within active batches", tempdbBatch[i].BatchID.ToString()),true));
                                }
                            }
                        }
                    }
                }
            }
            if (batch.PatientList.Count == 0)
            {
                ValidationErrors.Add(new ValidationError(this, "PatientList", keyName, keyValue, "Batch must contain at least one patient", true));
            }
        }

        /// <summary>
        /// Returns a repeat dispensing batch object loaded by BatchID
        /// </summary>
        /// <param name="batchID">BatchID of the required repeat dispensing batch</param>
        /// <returns>RepeatDispensingBatchLine onject loaded</returns>
        public RepeatDispensingBatchLine LoadByBatchID(int batchID)
        {
            using (RepeatDispensingBatch dbBatch = new RepeatDispensingBatch())
            {
                dbBatch.LoadByBatchID(batchID);
                if (dbBatch.Count == 0)
                    throw new ApplicationException(string.Format("Batch not found (batchID={0})", batchID));
                return FillData(dbBatch[0]);
            }
        }

        /// <summary>
        /// Returns a list of repeat dispensing batch objects by requested status
        /// </summary>
        /// <param name="status">BatchStatus of the requested batches</param>
        /// <returns>List of batches</returns>
        public List<RepeatDispensingBatchLine> LoadByStatus(BatchStatus status)
        {
            List<RepeatDispensingBatchLine> batchList = new List<RepeatDispensingBatchLine>();
            using (RepeatDispensingBatch dbBatch = new RepeatDispensingBatch())
            {
                dbBatch.LoadByStatus(status);
                for (int i = 0; i < dbBatch.Count; i++)
                {
                    batchList.Add(FillData(dbBatch[i]));
                }
                return batchList;
            }
        }

        /// <summary>
        /// Returns a list of repeat dispensing batch objects which are at an active status
        /// </summary>
        /// <returns>List of batches</returns>
        public List<RepeatDispensingBatchLine> LoadAllActive()
        {
            List<RepeatDispensingBatchLine> batchList = new List<RepeatDispensingBatchLine>();
            using (RepeatDispensingBatch dbBatch = new RepeatDispensingBatch())
            {
                dbBatch.LoadAllActive();
                for (int i = 0; i < dbBatch.Count; i++)
                {
                    batchList.Add(FillData(dbBatch[i]));
                }
                return batchList;
            }
        }

        /// <summary>
        /// Copies data from the data layer object to a business layer object
        /// </summary>
        /// <param name="dbBatchRow">RepeatDispensingBatchRow object to source the data from</param>
        /// <returns>RepeatDispensingBatchLine business object filled with data</returns>
        private RepeatDispensingBatchLine FillData(RepeatDispensingBatchRow dbBatchRow)
        {
            RepeatDispensingBatchLine batch = new RepeatDispensingBatchLine();
            batch.BatchID = dbBatchRow.BatchID;
            batch.Description = dbBatchRow.Description;
            batch.Status = dbBatchRow.Status;
            batch.Factor = dbBatchRow.Factor;
            batch.RepeatDispensingTemplateID = dbBatchRow.RepeatDispensingBatchTemplateID;
            batch.StartDate = dbBatchRow.StartDate;
            batch.StartSlot = dbBatchRow.StartSlot;
            batch.TotalSlots = dbBatchRow.TotalSlots;
            batch.Breakfast = dbBatchRow.Breakfast;
            batch.Lunch = dbBatchRow.Lunch;
            batch.Tea = dbBatchRow.Tea;
            batch.Night = dbBatchRow.Night;
            batch.BagLabelsPerPatient = dbBatchRow.BagLabelsPerPatient;
            batch.SortByDate = dbBatchRow.SortByDate;
            batch.LocationID = dbBatchRow.LocationID;
            batch.LocationDescription = dbBatchRow.LocationDescription;
            RepeatDispensingPatientProcessor processor = new RepeatDispensingPatientProcessor();
            batch.PatientList = processor.LoadByBatchID(batch.BatchID);
            batch.IncludeManual = dbBatchRow.IncludeManual;
            return batch;
        }
    }
}
