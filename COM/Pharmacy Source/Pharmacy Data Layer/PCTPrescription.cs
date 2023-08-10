//===========================================================================
//
//							PCTPrescription.cs
//
//  This class is a data layer representation of the PCT Prescription
//
//	Modification History:
//	24Nov11 AJK  Written
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
    /// Represents a row in the PCTPrescription table
    /// </summary>
    public class PCTPrescriptionRow : BaseRow
    {
        /// <summary>
        /// The BatchID primary key
        /// </summary>
        public int PCTPrescriptionID
        {
            get { return FieldToInt(RawRow["PCTPrescriptionID"]).Value; }
        }

        /// <summary>
        /// The request id for the prescription
        /// </summary>
        public int? RequestID_Prescription
        {
            get { return FieldToInt(RawRow["RequestID_Prescription"]); }
            set { RawRow["RequestID_Prescription"] = IntToField(value); }
        }

        /// <summary>
        /// The entity ID for the prescriber
        /// </summary>
        public int PrescriberEntityID
        {
            get { return FieldToInt(RawRow["PrescriberEntityID"]).Value; }
            set { RawRow["PrescriberEntityID"] = IntToField(value); }
        }

        /// <summary>
        /// The PCTOncologyPatientGroupID
        /// </summary>
        public int PCTOncologyPatientGroupingID
        {
            get { return FieldToInt(RawRow["PCTOncologyPatientGroupingID"]).Value; }
            set { RawRow["PCTOncologyPatientGroupingID"] = IntToField(value); }
        }

        /// <summary>
        /// The PrescriptionFormNumber
        /// </summary>
        public string PrescriptionFormNumber
        {
            get { return FieldToStr(RawRow["PrescriptionFormNumber"]); }
            set { RawRow["PrescriptionFormNumber"] = StrToField(value); }
        }

        /// <summary>
        /// The Special Authority Number
        /// </summary>
        public string SpecialAuthorityNumber
        {
            get { return FieldToStr(RawRow["SpecialAuthorityNumber"]); }
            set { RawRow["SpecialAuthorityNumber"] = StrToField(value); }
        }

        /// <summary>
        /// The entityid of the specialist endorser
        /// </summary>
        public int? SpecialistEndorserEntityID
        {
            get { return FieldToInt(RawRow["SpecialistEndorserEntityID"]); }
            set { RawRow["SpecialistEndorserEntityID"] = IntToField(value); }
        }

        /// <summary>
        /// The EndorsementDate
        /// </summary>
        public DateTime? EndorsementDate
        {
            get { return FieldToDateTime(RawRow["EndorsementDate"]); }
            set { RawRow["EndorsementDate"] = DateTimeToField(value); }
        }

        /// <summary>
        /// The FullWastage
        /// </summary>
        public bool FullWastage
        {
            get { return FieldToBoolean(RawRow["FullWastage"]).Value; }
            set { RawRow["FullWastage"] = BooleanToField(value); }
        }
    }

    /// <summary>
    /// Column information for the PCTPrescription table
    /// </summary>
    public class PCTPrescriptionColumnInfo : BaseColumnInfo
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public PCTPrescriptionColumnInfo() : base("PCTPrescription") { }

        /// <summary>
        /// The maximum length for the PrescriptionFormNumber field
        /// </summary>
        public int PrescriptionFormNumberLength { get { return tableInfo.GetFieldLength("PrescriptionFormNumber"); } }

        /// <summary>
        /// The maximum length for the SpecialAuthorityNumber field
        /// </summary>
        public int SpecialAuthorityNumberLength { get { return tableInfo.GetFieldLength("SpecialAuthorityNumber"); } }
    }

    /// <summary>
    /// Represents the SpecialAuthorityNumber table
    /// </summary>
    public class PCTPrescription : BaseTable<PCTPrescriptionRow, PCTPrescriptionColumnInfo>
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public PCTPrescription()
            : base("PCTPrescription", "PCTPrescriptionID")
        {
            UpdateSP = "pPCTPrescriptionUpdate";
        }

        /// <summary>
        /// Constructor with rowlocking option
        /// </summary>
        /// <param name="rowLocking">Lock rows</param>
        public PCTPrescription(RowLocking rowLocking)
            : base("PCTPrescription", "PCTPrescriptionID", rowLocking)
        {
            UpdateSP = "pPCTPrescriptionUpdate";
        }

        /// <summary>
        /// Load mechanism by PCTPrescriptionID
        /// </summary>
        /// <param name="PCTPrescriptionID">PCTPrescriptionID of the required PCTPrescription to be loaded</param>
        public void LoadByPCTPrescriptionID(int PCTPrescriptionID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "PCTPrescriptionID", PCTPrescriptionID);
            LoadRecordSetStream("pPCTPrescriptionByPCTPrescriptionID", parameters);
        }

        /// <summary>
        /// Load mechanism by RequestID
        /// </summary>
        /// <param name="PCTPrescriptionID">RequestID of the required PCTPrescription to be loaded</param>
        public void LoadByRequestID(int requestID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "RequestID", requestID);
            LoadRecordSetStream("pPCTPrescriptionByRequestID", parameters);
        }


    }
}
