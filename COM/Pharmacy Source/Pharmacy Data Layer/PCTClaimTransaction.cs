//===========================================================================
//
//							PCTClaimTransaction.cs
//
//  This class is a data layer representation of the PCT Claim Transaction
//
//	Modification History:
//	09Dec11 AJK  Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{

    /// <summary>
    /// Represents a row in the PCTClaimTransactionRow table
    /// </summary>
    public class PCTClaimTransactionRow : BaseRow
    {
        public int PCTClaimTransactionID
        {
            get { return FieldToInt(RawRow["PCTClaimTransactionID"]).Value; }
        }

        public int? PCTClaimFileID
        {
            get { return FieldToInt(RawRow["PCTClaimFileID"]); }
            set { RawRow["PCTClaimFIleID"] = IntToField(value); }
        }

        public string Category
        {
            get { return FieldToStr(RawRow["Category"]); }
            set { RawRow["Category"] = StrToField(value); }
        }

        public int? ComponentNumber
        {
            get { return FieldToInt(RawRow["ComponentNumber"]); }
            set { RawRow["ComponentNumber"] = IntToField(value); }
        }

        public int? TotalComponentNumber
        {
            get { return FieldToInt(RawRow["TotalComponentNumber"]); }
            set { RawRow["TotalComponentNumber"] = IntToField(value); }
        }

        public string PrescriberID
        {
            get { return FieldToStr(RawRow["PrescriberID"]); }
            set { RawRow["PrescriberID"] = StrToField(value); }
        }

        public string HealthProfessionalGroupCode
        {
            get { return FieldToStr(RawRow["HealthProfessionalGroupCode"]); }
            set { RawRow["HealthProfessionalGroupCode"] = StrToField(value); }
        }

        public string SpecialistID
        {
            get { return FieldToStr(RawRow["SpecialistID"]); }
            set { RawRow["SpecialistID"] = StrToField(value); }
        }

        public DateTime? EndorsementDate
        {
            get { return FieldToDateTime(RawRow["EndorsementDate"]); }
            set { RawRow["EndorsementDate"] = DateTimeToField(value); }
        }

        public string PrescriberFlag
        {
            get { return FieldToStr(RawRow["PrescriberFlag"]); }
            set { RawRow["PrescriberFlag"] = StrToField(value); }
        }

        public string PCTOncologyPatientGrouping
        {
            get { return FieldToStr(RawRow["PCTOncologyPatientGrouping"]); }
            set { RawRow["PCTOncologyPatientGrouping"] = StrToField(value); }
        }

        public string NHI
        {
            get { return FieldToStr(RawRow["NHI"]); }
            set { RawRow["NHI"] = StrToField(value); }
        }

        public string PCTPatientCategory
        {
            get { return FieldToStr(RawRow["PCTPatientCategory"]); }
            set { RawRow["PCTPatientCategory"] = StrToField(value); }
        }

        public string CSCorPHOStatusFlag
        {
            get { return FieldToStr(RawRow["CSCorPHOStatusFlag"]); }
            set { RawRow["CSCorPHOStatusFlag"] = StrToField(value); }
        }

        public bool? HUHCStatusFlag
        {
            get { return FieldToBoolean(RawRow["HUHCStatusFlag"]); }
            set { RawRow["HUHCStatusFlag"] = BooleanToField(value); }
        }

        public string SpecialAuthorityNumber
        {
            get { return FieldToStr(RawRow["SpecialAuthorityNumber"]); }
            set { RawRow["SpecialAuthorityNumber"] = StrToField(value); }
        }

        public decimal? Dose
        {
            get { return FieldToDecimal(RawRow["Dose"]); }
            set { RawRow["Dose"] = DecimalToField(value); }
        }

        public decimal? DailyDose
        {
            get { return FieldToDecimal(RawRow["DailyDose"]); }
            set { RawRow["DailyDose"] = DecimalToField(value); }
        }

        public bool? PrescriptionFlag
        {
            get { return FieldToBoolean(RawRow["PrescriptionFlag"]); }
            set { RawRow["PrescriptionFlag"] = BooleanToField(value); }
        }

        public bool? DoseFlag
        {
            get { return FieldToBoolean(RawRow["DoseFlag"]); }
            set { RawRow["DoseFlag"] = BooleanToField(value); }
        }

        public string PrescriptionID
        {
            get { return FieldToStr(RawRow["PrescriptionID"]); }
            set { RawRow["PrescriptionID"] = StrToField(value); }
        }

        public DateTime? ServiceDate
        {
            get { return FieldToDateTime(RawRow["ServiceDate"]); }
            set { RawRow["ServiceDate"] = DateTimeToField(value); }
        }

        public int? ClaimCode
        {
            get { return FieldToInt(RawRow["ClaimCode"]); }
            set { RawRow["ClaimCode"] = IntToField(value); }
        }

        public decimal? QuantityClaimed
        {
            get { return FieldToDecimal(RawRow["QuantityClaimed"]); }
            set { RawRow["QuantityClaimed"] = DecimalToField(value); }
        }

        public string PackUnitOfMeasure
        {
            get { return FieldToStr(RawRow["PackUnitOfMeasure"]); }
            set { RawRow["PackUnitOfMeasure"] = StrToField(value); }
        }

        public int? ClaimAmount
        {
            get { return FieldToInt(RawRow["ClaimAmount"]); }
            set { RawRow["ClaimAmount"] = IntToField(value); }
        }

        public int? CBSSubsidy
        {
            get { return FieldToInt(RawRow["CBSSubsidy"]); }
            set { RawRow["CBSSubsidy"] = IntToField(value); }
        }

        public decimal? CBSPacksize
        {
            get { return FieldToDecimal(RawRow["CBSPacksize"]); }
            set { RawRow["CBSPacksize"] = DecimalToField(value); }
        }

        public string Funder
        {
            get { return FieldToStr(RawRow["Funder"]); }
            set { RawRow["Funder"] = StrToField(value); }
        }

        public string FormNumber
        {
            get { return FieldToStr(RawRow["FormNumber"]); }
            set { RawRow["FormNumber"] = StrToField(value); }
        }

        public int? PCTTransactionStatusID
        {
            get { return FieldToInt(RawRow["PCTTransactionStatusID"]); }
            set { RawRow["PCTTransactionStatusID"] = IntToField(value); }
        }

        public int? ParentID
        {
            get { return FieldToInt(RawRow["ParentID"]); }
            set { RawRow["ParentID"] = IntToField(value); }
        }

        public DateTime? SupersededDate
        {
            get { return FieldToDateTime(RawRow["SupersededDate"]); }
            set { RawRow["SupersededDate"] = DateTimeToField(value); }
        }

        public int? SupersededByEntityID
        {
            get { return FieldToInt(RawRow["SupersededByEntityID"]); }
            set { RawRow["SupersededByEntityID"] = IntToField(value); }
        }

        public DateTime? ScheduleDate
        {
            get { return FieldToDateTime(RawRow["ScheduleDate"]); }
            set { RawRow["ScheduleDate"] = DateTimeToField(value); }
        }

        public int? UniqueTransactionNumber
        {
            get { return FieldToInt(RawRow["UniqueTransactionNumber"]); }
            set { RawRow["UniqueTransactionNumber"] = IntToField(value); }
        }

        public string PrescriptionSuffix
        {
            get { return FieldToStr(RawRow["PrescriptionSuffix"]); }
            set { RawRow["PrescriptionSuffix"] = StrToField(value); }
        }

        public int? RequestID_Prescription
        {
            get { return FieldToInt(RawRow["RequestID_Prescription"]); }
            set { RawRow["RequestID_Prescription"] = IntToField(value); }
        }

        public int? RequestID_Dispensing
        {
            get { return FieldToInt(RawRow["RequestID_Dispensing"]); }
            set { RawRow["RequestID_Dispensing"] = IntToField(value); }
        }

        public bool? OnHold
        {
            get { return FieldToBoolean(RawRow["OnHold"]); }
            set { RawRow["OnHold"] = BooleanToField(value); }
        }

        public bool? Modified
        {
            get { return FieldToBoolean(RawRow["Modified"]); }
            set { RawRow["Modified"] = BooleanToField(value); }
        }

        public bool? Resubmission
        {
            get { return FieldToBoolean(RawRow["Resubmission"]); }
            set { RawRow["Resubmission"] = BooleanToField(value); }
        }

        public bool? Credit
        {
            get { return FieldToBoolean(RawRow["Credit"]); }
            set { RawRow["Credit"] = BooleanToField(value); }
        }

        public bool? ErrorResubmit
        {
            get { return FieldToBoolean(RawRow["ErrorResubmit"]); }
            set { RawRow["ErrorResubmit"] = BooleanToField(value); }
        }

        public bool? ErrorCredit
        {
            get { return FieldToBoolean(RawRow["ErrorCredit"]); }
            set { RawRow["ErrorCredit"] = BooleanToField(value); }
        }

        public bool? Removed
        {
            get { return FieldToBoolean(RawRow["Removed"]); }
            set { RawRow["Removed"] = BooleanToField(value); }
        }

        public bool? RemovedSubmitted
        {
            get { return FieldToBoolean(RawRow["RemovedSubmitted"]); }
            set { RawRow["RemovedSubmitted"] = BooleanToField(value); }
        }
    }

    /// <summary>
    /// Column information for the PCTClaimTransaction table
    /// </summary>
    public class PCTClaimTransactionColumnInfo : BaseColumnInfo
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public PCTClaimTransactionColumnInfo() : base("PCTClaimTransaction") { }

        public int CategoryLength { get { return tableInfo.GetFieldLength("Category"); } }
        public int PrescriberIDLength { get { return tableInfo.GetFieldLength("PrescriberID"); } }
        public int HealthProfessionalGroupCodeLength { get { return tableInfo.GetFieldLength("HealthProfessionalGroupCode"); } }
        public int SpecialistIDLength { get { return tableInfo.GetFieldLength("SpecialistID"); } }
        public int PrescriberFlagLength { get { return tableInfo.GetFieldLength("PrescriberFlag"); } }
        public int PCTOncologyPatientGroupingLength { get { return tableInfo.GetFieldLength("PCTOncologyPatientGrouping"); } }
        public int NHILength { get { return tableInfo.GetFieldLength("NHI"); } }
        public int PCTPatientCategoryLength { get { return tableInfo.GetFieldLength("PCTPatientCategory"); } }
        public int CSCorPHOStatusFlagLength { get { return tableInfo.GetFieldLength("CSCorPHOStatusFlag"); } }
        public int SpecialAuthorityNumberLength { get { return tableInfo.GetFieldLength("SpecialAuthorityNumber"); } }
        public int PackUnitOfMeasureLength { get { return tableInfo.GetFieldLength("PackUnitOfMeasure"); } }
        public int FunderLength { get { return tableInfo.GetFieldLength("Funder"); } }
        public int FormNumberLength { get { return tableInfo.GetFieldLength("FormNumber"); } }
        public int PriescriptionIDLength { get { return tableInfo.GetFieldLength("PrescriptionID"); } }
        public int PrescriptionSuffixLength { get { return tableInfo.GetFieldLength("PrescriptionSuffix"); } }
    }

    /// <summary>
    /// Represents the PCTClaimTransaction table
    /// </summary>
    public class PCTClaimTransaction : BaseTable<PCTClaimTransactionRow, PCTClaimTransactionColumnInfo>
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public PCTClaimTransaction()
            : base("PCTClaimTransaction", "PCTClaimTransactionID")
        {
            UpdateSP = "pPCTClaimTransactionUpdate";
        }

        /// <summary>
        /// Returns the PCTTransactionStatusID for a given code
        /// </summary>
        /// <param name="code">The code for the status</param>
        /// <returns>The ID for the status record</returns>
        public static int GetTransactionStatusIDByCode(string code)
        {
            StringBuilder parameters = new StringBuilder();
            PCTClaimTransaction claim = new PCTClaimTransaction();
            claim.AddInputParam(parameters, "Code", code);
            return claim.ExecuteScalar("pPCTTransactionStatusByCode", parameters);
        }

        /// <summary>
        /// Constructor with rowlocking option
        /// </summary>
        /// <param name="rowLocking">Lock rows</param>
        public PCTClaimTransaction(RowLocking rowLocking)
            : base("PCTClaimTransaction", "PCTClaimTransactionID", rowLocking)
        {
            UpdateSP = "pPCTClaimTransactionUpdate";
        }

        /// <summary>
        /// Load mechanism by PCTClaimTransactionID
        /// </summary>
        /// <param name="PCTClaimTransactionID">PCTClaimTransactionID of the required PCTClaimTransaction to be loaded</param>
        public void LoadByPCTClaimTransactionID(int PCTClaimTransactionID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "PCTClaimTransactionID", PCTClaimTransactionID);
            LoadRecordSetStream("pPCTClaimTransactionByPCTClaimTransactionID", parameters);
        }

        /// <summary>
        /// Load mechanise by PCTClaimFileID
        /// </summary>
        /// <param name="PCTClaimFileID">PCTClaimFileID fo the required set of PCTClaimTransactions</param>
        public void LoadByPCTClaimFileID(int PCTClaimFileID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "PCTClaimFileID", PCTClaimFileID);
            LoadRecordSetStream("pPCTClaimTransactionByPCTClaimFileID", parameters);
        }

        ///// <summary>
        ///// Load mechanism by ServiceDate range
        ///// </summary>
        ///// <param name="from">Date of the earliest service date in the range (inclusive)</param>
        ///// <param name="to">Date of the latest service date in the range (exclusive)</param>
        //public void LoadByServiceDateRangeAndSiteID(DateTime from, DateTime to, int siteID)
        //{
        //    StringBuilder parameters = new StringBuilder();
        //    AddInputParam(parameters, "From", from);
        //    AddInputParam(parameters, "To", to);
        //    AddInputParam(parameters, "SiteID", siteID);
        //    LoadRecordSetStream("pPCTClaimTransactionByServiceDateRangeAndSiteID", parameters);
        //}

        ///// <summary>
        ///// Gets all open complete claims which have not been deleted or submitted.
        ///// </summary>
        //public void GetAllOpenClaimsBySiteID(int siteID)
        //{
        //    StringBuilder parameters = new StringBuilder();
        //    AddInputParam(parameters, "SiteID", siteID);
        //    LoadRecordSetStream("pPCTClaimTransactionLoadAllOpenDateOrderedBySiteID", parameters);
        //}
        
    }
}
