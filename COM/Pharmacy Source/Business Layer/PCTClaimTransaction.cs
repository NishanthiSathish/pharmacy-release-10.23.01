//===========================================================================
//
//							PCTClaimTransaction.cs
//
//  This class holds all business logic for handling a PCT claim transaction
//  object.
//
//	Modification History:
//	09Dec11 AK  Written
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
    /// Represents a PCT Claim Transaction
    /// </summary>
    public class PCTClaimTransactionLine : IBusinessObject
    {
        public int PCTClaimTransactionID { get; internal set; }
        public int? PCTClaimFileID { get; set; }
        public string Category { get; set; }
        public int? ComponentNumber { get; set; }
        public int? TotalComponentNumber { get; set; }
        public string PrescriberID { get; set; }
        public string HealthProfessionalGroupCode { get; set; }
        public string SpecialistID { get; set; }
        public DateTime? EndorsementDate { get; set; }
        public string PrescriberFlag { get; set; }
        public string PCTOncologyPatientGrouping { get; set; }
        public string NHI { get; set; }
        public string PCTPatientCategory { get; set; }
        public string CSCorPHOStatusFlag { get; set; }
        public bool? HUHCStatusFlag { get; set; }
        public string SpecialAuthorityNumber { get; set; }
        public decimal? Dose { get; set; }
        public decimal? DailyDose { get; set; }
        public bool? PrescriptionFlag { get; set; }
        public bool? DoseFlag { get; set; }
        public string PrescriptionID { get; set; }
        public DateTime? ServiceDate { get; set; }
        public int? ClaimCode { get; set; }
        public decimal? QuantityClaimed { get; set; }
        public string PackUnitOfMeasure { get; set; }
        public int? ClaimAmount { get; set; }
        public int? CBSSubsidy { get; set; }
        public decimal? CBSPacksize { get; set; }
        public string Funder { get; set; }
        public string FormNumber { get; set; }
        public int? PCTTransactionStatusID { get; set; }
        public int? ParentID { get; set; }
        public DateTime? SupersededDate { get; set; }
        public int? SupersededByEntityID { get; set; }
        public DateTime? ScheduleDate { get; set; }
        public int? UniqueTransactionNumber { get; set; }
        public string PrescriptionSuffix { get; set; }
        public int? RequestID_Prescription { get; set; }
        public int? RequestID_Dispensing { get; set; }
        public bool? OnHold { get; set; }
        public bool? Modified { get; set; }
        public bool? Resubmission { get; set; }
        public bool? Credit { get; set; }
        public bool? ErrorResubmit { get; set; }
        public bool? ErrorCredit { get; set; }
        public bool? Removed { get; set; }
        public bool? RemovedSubmitted { get; set; }
        public string Status { get; set; }
    }

    /// <summary>
    /// Processes PCT Claim Transaction
    /// </summary>
    public class PCTClaimTransactionProcessor : BusinessProcess
    {
        /// <summary>
        /// Updates a PCT Claim Transaction object
        /// </summary>
        /// <param name="claimTransaction">PCTClaimTransactionLine object to update</param>
        public void Update(PCTClaimTransactionLine claimTransaction)
        {
            if (claimTransaction.Category != null && claimTransaction.Category.Length > PCTClaimTransaction.GetColumnInfo().CategoryLength)
            {
                string msg = string.Format("Category exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().CategoryLength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.CSCorPHOStatusFlag != null && claimTransaction.CSCorPHOStatusFlag.Length > PCTClaimTransaction.GetColumnInfo().CSCorPHOStatusFlagLength)
            {
                string msg = string.Format("CSCorPHOStatusFlag exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().CSCorPHOStatusFlagLength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.FormNumber != null && claimTransaction.FormNumber.Length > PCTClaimTransaction.GetColumnInfo().FormNumberLength)
            {
                string msg = string.Format("FormNumber exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().FormNumberLength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.PrescriptionID != null && claimTransaction.PrescriptionID.Length > PCTClaimTransaction.GetColumnInfo().PriescriptionIDLength)
            {
                string msg = string.Format("PrescriptionID exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().PriescriptionIDLength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.Funder != null && claimTransaction.Funder.Length > PCTClaimTransaction.GetColumnInfo().FunderLength)
            {
                string msg = string.Format("Funder exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().FunderLength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.HealthProfessionalGroupCode != null && claimTransaction.HealthProfessionalGroupCode.Length > PCTClaimTransaction.GetColumnInfo().HealthProfessionalGroupCodeLength)
            {
                string msg = string.Format("HealthProfessionalGroupCode exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().HealthProfessionalGroupCodeLength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.NHI != null && claimTransaction.NHI.Length > PCTClaimTransaction.GetColumnInfo().NHILength)
            {
                string msg = string.Format("NHI exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().NHILength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.PackUnitOfMeasure != null && claimTransaction.PackUnitOfMeasure.Length > PCTClaimTransaction.GetColumnInfo().PackUnitOfMeasureLength)
            {
                string msg = string.Format("PackUnitOfMeasure exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().PackUnitOfMeasureLength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.PCTOncologyPatientGrouping != null && claimTransaction.PCTOncologyPatientGrouping.Length > PCTClaimTransaction.GetColumnInfo().PCTOncologyPatientGroupingLength)
            {
                string msg = string.Format("PCTOncologyPatientGrouping exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().PCTOncologyPatientGroupingLength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.PCTPatientCategory != null && claimTransaction.PCTPatientCategory.Length > PCTClaimTransaction.GetColumnInfo().PCTPatientCategoryLength)
            {
                string msg = string.Format("PCTPatientCategory exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().PCTPatientCategoryLength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.PrescriberFlag != null && claimTransaction.PrescriberFlag.Length > PCTClaimTransaction.GetColumnInfo().PrescriberFlagLength)
            {
                string msg = string.Format("PrescriberFlag exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().PrescriberFlagLength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.PrescriberID != null && claimTransaction.PrescriberID.Length > PCTClaimTransaction.GetColumnInfo().PrescriberIDLength)
            {
                string msg = string.Format("PrescriberID exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().PrescriberIDLength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.SpecialAuthorityNumber != null && claimTransaction.SpecialAuthorityNumber.Length > PCTClaimTransaction.GetColumnInfo().SpecialAuthorityNumberLength)
            {
                string msg = string.Format("SpecialAuthorityNumber exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().SpecialAuthorityNumberLength.ToString());
                throw new ApplicationException(msg);
            }
            if (claimTransaction.SpecialistID != null && claimTransaction.SpecialistID.Length > PCTClaimTransaction.GetColumnInfo().SpecialistIDLength)
            {
                string msg = string.Format("SpecialistID exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().SpecialistIDLength.ToString());
                throw new ApplicationException(msg);
            }
            if (!claimTransaction.UniqueTransactionNumber.HasValue)
            {
                string msg = string.Format("UniqueTransactionNumber is required");
                throw new ApplicationException(msg);
            }
            if (claimTransaction.PrescriptionSuffix != null && claimTransaction.PrescriptionSuffix.Length > PCTClaimTransaction.GetColumnInfo().PrescriptionSuffixLength)
            {
                string msg = string.Format("PrescriptionSuffix exceeds maximum length of {0} characters", PCTClaimTransaction.GetColumnInfo().PrescriptionSuffixLength.ToString());
                throw new ApplicationException(msg);
            }
            if (!claimTransaction.RequestID_Prescription.HasValue)
            {
                string msg = string.Format("RequestID_Prescription is required");
                throw new ApplicationException(msg);
            }
            if (!claimTransaction.RequestID_Dispensing.HasValue)
            {
                string msg = string.Format("RequestID_Dispensing is required");
                throw new ApplicationException(msg);
            }

            using (PCTClaimTransaction dbClaimTransaction = new PCTClaimTransaction())
            {
                if (claimTransaction.PCTClaimTransactionID == 0)
                {
                    dbClaimTransaction.Add();
                }
                else
                {
                    dbClaimTransaction.LoadByPCTClaimTransactionID(claimTransaction.PCTClaimTransactionID);
                }
                dbClaimTransaction[0].Category = claimTransaction.Category;
                dbClaimTransaction[0].CBSPacksize = claimTransaction.CBSPacksize;
                dbClaimTransaction[0].CBSSubsidy = claimTransaction.CBSSubsidy;
                dbClaimTransaction[0].ClaimAmount = claimTransaction.ClaimAmount;
                dbClaimTransaction[0].ClaimCode = claimTransaction.ClaimCode;
                dbClaimTransaction[0].ComponentNumber = claimTransaction.ComponentNumber;
                dbClaimTransaction[0].CSCorPHOStatusFlag = claimTransaction.CSCorPHOStatusFlag;
                dbClaimTransaction[0].DailyDose = claimTransaction.DailyDose;
                dbClaimTransaction[0].Dose = claimTransaction.Dose;
                dbClaimTransaction[0].DoseFlag = claimTransaction.DoseFlag;
                dbClaimTransaction[0].EndorsementDate = claimTransaction.EndorsementDate;
                dbClaimTransaction[0].FormNumber = claimTransaction.FormNumber;
                dbClaimTransaction[0].Funder = claimTransaction.Funder;
                dbClaimTransaction[0].HealthProfessionalGroupCode = claimTransaction.HealthProfessionalGroupCode;
                dbClaimTransaction[0].HUHCStatusFlag = claimTransaction.HUHCStatusFlag;
                dbClaimTransaction[0].NHI = claimTransaction.NHI;
                dbClaimTransaction[0].PackUnitOfMeasure = claimTransaction.PackUnitOfMeasure;
                dbClaimTransaction[0].ParentID = claimTransaction.ParentID;
                dbClaimTransaction[0].PCTClaimFileID = claimTransaction.PCTClaimFileID;
                dbClaimTransaction[0].PCTOncologyPatientGrouping = claimTransaction.PCTOncologyPatientGrouping;
                dbClaimTransaction[0].PCTPatientCategory = claimTransaction.PCTPatientCategory;
                dbClaimTransaction[0].PCTTransactionStatusID = claimTransaction.PCTTransactionStatusID;
                dbClaimTransaction[0].PrescriberFlag = claimTransaction.PrescriberFlag;
                dbClaimTransaction[0].PrescriberID = claimTransaction.PrescriberID;
                dbClaimTransaction[0].PrescriptionFlag = claimTransaction.PrescriptionFlag;
                dbClaimTransaction[0].PrescriptionID = claimTransaction.PrescriptionID;
                dbClaimTransaction[0].QuantityClaimed = claimTransaction.QuantityClaimed;
                dbClaimTransaction[0].ServiceDate = claimTransaction.ServiceDate;
                dbClaimTransaction[0].SpecialAuthorityNumber = claimTransaction.SpecialAuthorityNumber;
                dbClaimTransaction[0].SpecialistID = claimTransaction.SpecialistID;
                dbClaimTransaction[0].SupersededByEntityID = claimTransaction.SupersededByEntityID;
                dbClaimTransaction[0].SupersededDate = claimTransaction.SupersededDate;
                dbClaimTransaction[0].TotalComponentNumber = claimTransaction.TotalComponentNumber;
                dbClaimTransaction[0].ScheduleDate = claimTransaction.ScheduleDate;
                dbClaimTransaction[0].UniqueTransactionNumber = claimTransaction.UniqueTransactionNumber;
                dbClaimTransaction[0].PrescriptionSuffix = claimTransaction.PrescriptionSuffix;
                dbClaimTransaction[0].RequestID_Dispensing = claimTransaction.RequestID_Dispensing;
                dbClaimTransaction[0].RequestID_Prescription = claimTransaction.RequestID_Prescription;
                dbClaimTransaction[0].OnHold = claimTransaction.OnHold;
                dbClaimTransaction[0].Modified = claimTransaction.Modified;
                dbClaimTransaction[0].Resubmission = claimTransaction.Resubmission;
                dbClaimTransaction[0].Credit = claimTransaction.Credit;
                dbClaimTransaction[0].ErrorResubmit = claimTransaction.ErrorResubmit;
                dbClaimTransaction[0].ErrorCredit = claimTransaction.ErrorCredit;
                dbClaimTransaction[0].Removed = claimTransaction.Removed;
                dbClaimTransaction[0].RemovedSubmitted = claimTransaction.RemovedSubmitted;
                dbClaimTransaction.Save();
                claimTransaction.PCTClaimTransactionID = dbClaimTransaction[0].PCTClaimTransactionID;
            }
        }

        public void UpdateStatus(PCTClaimTransactionLine claim)
        {
            string status = "";
            if (claim.OnHold.HasValue && (bool)claim.OnHold)
                status += "H ";
            if (claim.Modified.HasValue && (bool)claim.Modified)
                status += "M ";
            if (claim.Resubmission.HasValue && (bool)claim.Resubmission)
                status += "R ";
            if (claim.Credit.HasValue && (bool)claim.Credit)
                status += "C ";
            if (claim.ErrorResubmit.HasValue && (bool)claim.ErrorResubmit)
                status += "E ";
            if (claim.ErrorCredit.HasValue && (bool)claim.ErrorCredit)
                status += "Q ";
            if ((claim.Removed.HasValue && (bool)claim.Removed) || (claim.RemovedSubmitted.HasValue && (bool)claim.RemovedSubmitted))
                status += "X ";
            claim.Status = status.Trim();
        }

        /// <summary>
        /// Validates a PCT Claim Transaction object for update
        /// </summary>
        /// <param name="claimTransaction">PCTClaimTransactionLine object to be validated</param>
        public void ValidateForUpdate(PCTClaimTransactionLine claimTransaction)
        {
            string keyName = "PCTClaimTransactionID";
            string keyValue = claimTransaction.PCTClaimTransactionID.ToString();
        }

        /// <summary>
        /// Loads a PCT Claim Transaction by PCTClaimTransactionID
        /// </summary>
        /// <param name="pctClaimTransactionID">The primary key of the record</param>
        /// <returns>A PCTClaimTransactionLine object</returns>
        public PCTClaimTransactionLine LoadByPCTClaimTransactionID(int pctClaimTransactionID)
        {
            using (PCTClaimTransaction dbClaimTransaction = new PCTClaimTransaction())
            {
                dbClaimTransaction.LoadByPCTClaimTransactionID(pctClaimTransactionID);
                if (dbClaimTransaction.Count == 0)
                    throw new ApplicationException(string.Format("PCTClaimTransaction not found (PCTClaimTransactionID={0})", pctClaimTransactionID));
                return FillData(dbClaimTransaction[0]);
            }
        }

        /// <summary>
        /// Loads a PCT Claim Transaction set by PCTClaimFileID
        /// </summary>
        /// <param name="PCTClaimFileID">The PCTClaimFileID for the selected </param>
        /// <returns></returns>
        public List<PCTClaimTransactionLine> LoadByPCTClaimFileID(int PCTClaimFileID)
        {
            
            using (PCTClaimTransaction dbClaims = new PCTClaimTransaction())
            {
                List<PCTClaimTransactionLine> claims = new List<PCTClaimTransactionLine>();
                dbClaims.LoadByPCTClaimFileID(PCTClaimFileID);
                for (int i = 0; i < dbClaims.Count; i++)
                {
                    claims.Add(FillData(dbClaims[i]));
                }
                return claims;
            }
        }

        public PCTClaimTransactionLine CreateCopy(PCTClaimTransactionLine oldClaim)
        {
            PCTClaimTransactionLine newClaim = new PCTClaimTransactionLine();
            newClaim.Category = oldClaim.Category;
            newClaim.CBSPacksize = oldClaim.CBSPacksize;
            newClaim.CBSSubsidy = oldClaim.CBSSubsidy;
            newClaim.ClaimAmount = oldClaim.ClaimAmount;
            newClaim.ClaimCode = oldClaim.ClaimCode;
            newClaim.ComponentNumber = oldClaim.ComponentNumber;
            newClaim.Credit = oldClaim.Credit;
            newClaim.CSCorPHOStatusFlag = oldClaim.CSCorPHOStatusFlag;
            newClaim.DailyDose = oldClaim.DailyDose;
            newClaim.Dose = oldClaim.Dose;
            newClaim.DoseFlag = oldClaim.DoseFlag;
            newClaim.EndorsementDate = oldClaim.EndorsementDate;
            newClaim.ErrorCredit = oldClaim.ErrorCredit;
            newClaim.ErrorResubmit = oldClaim.ErrorResubmit;
            newClaim.FormNumber = oldClaim.FormNumber;
            newClaim.Funder = oldClaim.Funder;
            newClaim.HealthProfessionalGroupCode = oldClaim.HealthProfessionalGroupCode;
            newClaim.HUHCStatusFlag = oldClaim.HUHCStatusFlag;
            newClaim.Modified = oldClaim.Modified;
            newClaim.NHI = oldClaim.NHI;
            newClaim.OnHold = oldClaim.OnHold;
            newClaim.PackUnitOfMeasure = oldClaim.PackUnitOfMeasure;
            newClaim.ParentID = oldClaim.ParentID;
            newClaim.PCTClaimFileID = oldClaim.PCTClaimFileID;
            newClaim.PCTOncologyPatientGrouping = oldClaim.PCTOncologyPatientGrouping;
            newClaim.PCTPatientCategory = oldClaim.PCTPatientCategory;
            newClaim.PCTTransactionStatusID = oldClaim.PCTTransactionStatusID;
            newClaim.PrescriberFlag = oldClaim.PrescriberFlag;
            newClaim.PrescriberID = oldClaim.PrescriberID;
            newClaim.PrescriptionFlag = oldClaim.PrescriptionFlag;
            newClaim.PrescriptionID = oldClaim.PrescriptionID;
            newClaim.PrescriptionSuffix = oldClaim.PrescriptionSuffix;
            newClaim.QuantityClaimed = oldClaim.QuantityClaimed;
            newClaim.Removed = oldClaim.Removed;
            newClaim.RemovedSubmitted = oldClaim.RemovedSubmitted;
            newClaim.RequestID_Dispensing = oldClaim.RequestID_Dispensing;
            newClaim.RequestID_Prescription = oldClaim.RequestID_Prescription;
            newClaim.Resubmission = oldClaim.Resubmission;
            newClaim.ScheduleDate = oldClaim.ScheduleDate;
            newClaim.ServiceDate = oldClaim.ServiceDate;
            newClaim.SpecialAuthorityNumber = oldClaim.SpecialAuthorityNumber;
            newClaim.SpecialistID = oldClaim.SpecialistID;
            newClaim.Status = oldClaim.Status;
            newClaim.SupersededByEntityID = oldClaim.SupersededByEntityID;
            newClaim.SupersededDate = oldClaim.SupersededDate;
            newClaim.TotalComponentNumber = oldClaim.TotalComponentNumber;
            newClaim.UniqueTransactionNumber = oldClaim.UniqueTransactionNumber;
            return newClaim;
        }

        ///// <summary>
        ///// Loads a PCT claim transaction set by a service date range
        ///// </summary>
        ///// <param name="from">The date of the earliest transaction (inclusive)</param>
        ///// <param name="to">The date of the latest transaction (exclusive)</param>
        ///// <returns></returns>
        //public List<PCTClaimTransactionLine> LoadByServiceDateRangeAndSiteID(DateTime from, DateTime to, int siteID)
        //{
        //    using (PCTClaimTransaction dbClaims = new PCTClaimTransaction())
        //    {
        //        List<PCTClaimTransactionLine> claims = new List<PCTClaimTransactionLine>();
        //        dbClaims.LoadByServiceDateRangeAndSiteID(from, to, siteID);
        //        for (int i = 0; i < dbClaims.Count; i++)
        //        {
        //            claims.Add(FillData(dbClaims[i]));
        //        }
        //        return claims;
        //    }
        //}
        
        /// <summary>
        /// Fills the PCTClaimTransactionLine object with the database object data
        /// </summary>
        /// <param name="dbClaimTransactionRow">The database object to use to populate</param>
        /// <returns>The filled PCTClaimTransactionLine object</returns>
        private PCTClaimTransactionLine FillData(PCTClaimTransactionRow dbClaimTransactionRow)
        {
            PCTClaimTransactionLine claimTransaction = new PCTClaimTransactionLine();
            claimTransaction.Category = dbClaimTransactionRow.Category;
            claimTransaction.CBSPacksize = dbClaimTransactionRow.CBSPacksize;
            claimTransaction.CBSSubsidy = dbClaimTransactionRow.CBSSubsidy;
            claimTransaction.ClaimAmount = dbClaimTransactionRow.ClaimAmount;
            claimTransaction.ClaimCode = dbClaimTransactionRow.ClaimCode;
            claimTransaction.ComponentNumber = dbClaimTransactionRow.ComponentNumber;
            claimTransaction.CSCorPHOStatusFlag = dbClaimTransactionRow.CSCorPHOStatusFlag;
            claimTransaction.DailyDose = dbClaimTransactionRow.DailyDose;
            claimTransaction.Dose = dbClaimTransactionRow.Dose;
            claimTransaction.DoseFlag = dbClaimTransactionRow.DoseFlag;
            claimTransaction.EndorsementDate = dbClaimTransactionRow.EndorsementDate;
            claimTransaction.FormNumber = dbClaimTransactionRow.FormNumber;
            claimTransaction.Funder = dbClaimTransactionRow.Funder;
            claimTransaction.HealthProfessionalGroupCode = dbClaimTransactionRow.HealthProfessionalGroupCode;
            claimTransaction.HUHCStatusFlag = dbClaimTransactionRow.HUHCStatusFlag;
            claimTransaction.NHI = dbClaimTransactionRow.NHI;
            claimTransaction.PackUnitOfMeasure = dbClaimTransactionRow.PackUnitOfMeasure;
            claimTransaction.ParentID = dbClaimTransactionRow.ParentID;
            claimTransaction.PCTClaimFileID = dbClaimTransactionRow.PCTClaimFileID;
            claimTransaction.PCTClaimTransactionID = dbClaimTransactionRow.PCTClaimTransactionID;
            claimTransaction.PCTOncologyPatientGrouping = dbClaimTransactionRow.PCTOncologyPatientGrouping;
            claimTransaction.PCTPatientCategory = dbClaimTransactionRow.PCTPatientCategory;
            claimTransaction.PCTTransactionStatusID = dbClaimTransactionRow.PCTTransactionStatusID;
            claimTransaction.PrescriberFlag = dbClaimTransactionRow.PrescriberFlag;
            claimTransaction.PrescriberID = dbClaimTransactionRow.PrescriberID;
            claimTransaction.PrescriptionFlag = dbClaimTransactionRow.PrescriptionFlag;
            claimTransaction.PrescriptionID = dbClaimTransactionRow.PrescriptionID;
            claimTransaction.QuantityClaimed = dbClaimTransactionRow.QuantityClaimed;
            claimTransaction.ServiceDate = dbClaimTransactionRow.ServiceDate;
            claimTransaction.SpecialAuthorityNumber = dbClaimTransactionRow.SpecialAuthorityNumber;
            claimTransaction.SpecialistID = dbClaimTransactionRow.SpecialistID;
            claimTransaction.SupersededByEntityID = dbClaimTransactionRow.SupersededByEntityID;
            claimTransaction.SupersededDate = dbClaimTransactionRow.SupersededDate;
            claimTransaction.TotalComponentNumber = dbClaimTransactionRow.TotalComponentNumber;
            claimTransaction.ScheduleDate = dbClaimTransactionRow.ScheduleDate;
            claimTransaction.UniqueTransactionNumber = dbClaimTransactionRow.UniqueTransactionNumber;
            claimTransaction.PrescriptionSuffix = dbClaimTransactionRow.PrescriptionSuffix;
            claimTransaction.RequestID_Dispensing = dbClaimTransactionRow.RequestID_Dispensing;
            claimTransaction.RequestID_Prescription = dbClaimTransactionRow.RequestID_Prescription;
            claimTransaction.OnHold = dbClaimTransactionRow.OnHold;
            claimTransaction.Modified = dbClaimTransactionRow.Modified;
            claimTransaction.Resubmission = dbClaimTransactionRow.Resubmission;
            claimTransaction.Credit = dbClaimTransactionRow.Credit;
            claimTransaction.ErrorResubmit = dbClaimTransactionRow.ErrorResubmit;
            claimTransaction.ErrorCredit = dbClaimTransactionRow.ErrorCredit;
            claimTransaction.Removed = dbClaimTransactionRow.Removed;
            claimTransaction.RemovedSubmitted = dbClaimTransactionRow.RemovedSubmitted;
            UpdateStatus(claimTransaction);
            return claimTransaction;
        }
    }
}
