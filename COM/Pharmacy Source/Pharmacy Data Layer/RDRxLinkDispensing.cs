//===========================================================================
//
//							       RDRxLinkDispensing.cs
//
//  Provides access to RepeatDispensingPrescriptionLinkDispensing table.
//
//	Modification History:
//	07Jul09 AK  Written
//  01May11 TH  Added JVM Flag in linking record
//  04Nov11 XN  TFS 18576 Added method IsPrescriptionInLinkedDispensing
//  16Apr12 AJK 31239 Added Updated, UpdatedBy and UpdatedByDescription fields
//  15Aug13 TH  70134 Added RepeatTotal, RepeatRemaining, PrescriptionExpiry fields for DoC
//===========================================================================
using System.Text;
using ascribe.pharmacy.basedatalayer;
using System;
using ascribe.pharmacy.shared;
using System.Data;

namespace ascribe.pharmacy.pharmacydatalayer
{
    public class RDRxLinkDispensingRow : BaseRow
    {
        public int RDRxLinkDispensingID
        {
            get { return FieldToInt(RawRow["RepeatDispensingPrescriptionLinkDispensingID"]).Value; }
        }

        public int PrescriptionID
        {
            get { return FieldToInt(RawRow["PrescriptionID"]).Value; }
            set { RawRow["PrescriptionID"] = IntToField(value); }
        }

        public int DispensingID
        {
            get { return FieldToInt(RawRow["DispensingID"]).Value; }
            set { RawRow["DispensingID"] = IntToField(value); }
        }

        public bool InUse
        {
            get { return FieldToBoolean(RawRow["InUse"]).Value; }
            set { RawRow["InUse"] = BooleanToField(value); }
        }

        public bool JVM
        {
            get { return FieldToBoolean(RawRow["JVM"]).Value; }
            set { RawRow["JVM"] = BooleanToField(value); }
        }

        public double Quantity
        {
            get { return FieldToDouble(RawRow["Quantity"]).Value; }
            set { RawRow["Quantity"] = DoubleToField(value); }
        }

        /// <summary>
        /// When the settings were last updated
        /// </summary>
        public DateTime? Updated
        {
            get { return FieldToDateTime(RawRow["Updated"]); }
            set { RawRow["Updated"] = DateTimeToField(value); }
        }

        /// <summary>
        /// The EntityID of the person who last updated the settings
        /// </summary>
        public int? UpdatedBy
        {
            get { return FieldToInt(RawRow["UpdatedBy"]); }
            set { RawRow["UpdatedBy"] = IntToField(value); }
        }

        /// <summary>
        /// The description of the person who last updated the settings
        /// </summary>
        public string UpdatedByDescription
        {
            get { return FieldToStr(RawRow["UpdatedBy_Description"], true, string.Empty); }
        }

        /// <summary>
        /// The Repeat Total of the rx
        /// </summary>
        public int? RepeatTotal
        {
            get { return FieldToInt(RawRow["RepeatTotal"]); }
            set { RawRow["RepeatTotal"] = IntToField(value); }
        }

        /// <summary>
        /// The remaining Repeats of the rx
        /// </summary>
        public int? RepeatRemaining
        {
            get { return FieldToInt(RawRow["RepeatRemaining"]); }
            set { RawRow["RepeatRemaining"] = IntToField(value); }
        }

        /// <summary>
        /// The Prescription Expiry Date (for repeat Dispensing)
        /// </summary>
        public DateTime? PrescriptionExpiry
        {
            get { return FieldToDateTime(RawRow["PrescriptionExpiry"]); }
            set { RawRow["PrescriptionExpiry"] = DateTimeToField(value); }
        }
    }

    public class RDRxLinkDispensingColumnInfo : BaseColumnInfo
    {
        public RDRxLinkDispensingColumnInfo() : base("RepeatDispensingPrescriptionLinkDispensing") { }
    }

    public class RDRxLinkDispensing : BaseTable<RDRxLinkDispensingRow, RDRxLinkDispensingColumnInfo>
    {
        public RDRxLinkDispensing()
            : base("RepeatDispensingPrescriptionLinkDispensing", "RepeatDispensingPrescriptionLinkDispensingID")
        {
            UpdateSP = "pRepeatDispensingPrescriptionlinkDispensingUpdate";
            IncludeSessionLockInInsert = true;
            IncludeSessionLockInUpdate = true;
        }

        public RDRxLinkDispensing(RowLocking rowLocking)
            : base("RepeatDispensingPrescriptionLinkDispensing", "RepeatDispensingPrescriptionLinkDispensingID", rowLocking)
        {
            UpdateSP = "pRepeatDispensingPrescriptionlinkDispensingUpdate";
            IncludeSessionLockInInsert = true;
            IncludeSessionLockInUpdate = true;
        }

        public void LoadByRepeatDispensingPrescriptionLinkDispensingID(int repeatDispensingPrescriptionLinkDispensingID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "RepeatDispensingPrescriptionLinkDispensingID", repeatDispensingPrescriptionLinkDispensingID);
            LoadRecordSetStream("pRepeatDispensingPrescriptionLinkDispensingSelect", parameters);
        }

        public void LoadByDispensingID(int dispensingID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "DispensingID", dispensingID);
            LoadRecordSetStream("pRepeatDispensingPrescriptionLinkDispensingByDispensingID", parameters);
        }

        public void LoadByPrescriptionID(int prescriptionID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "PrescriptionID", prescriptionID);
            LoadRecordSetStream("pRepeatDispensingPrescriptionLinkDispensingByPrescriptionID", parameters);
        }

        /// <summary>Returns true if prescription request is in an linked dispensing</summary>
        /// <param name="requestID">Prescription request</param>
        /// <param name="mustBeInUse">If only interested in in-use items</param>
        /// <returns>If prescription is in a linked dispensing</returns>
        public static bool IsPrescriptionInLinkedDispensing(int requestID, bool mustBeInUse)
        {
            StringBuilder parameters = new StringBuilder();
            RDRxLinkDispensing table = new RDRxLinkDispensing();

            table.AddInputParam(parameters, "requestID_Prescription", requestID);
            table.AddInputParam(parameters, "mustBeInUse",            mustBeInUse);
            return (table.ExecuteScalar("pFirstRxLinkDispensingIDByRequestIDAndActive", parameters) > 0);
        }
    }
}
