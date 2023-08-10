//===========================================================================
//
//							RDispPatientSettings.cs
//
//  This class is a data layer representation of the Repeat Dispensing Patient
//  settings.
//
//  SP for this object should return all fields from the RepeatDispensingPatient table, 
//  and a link to the following extra fields
//      RepeatDispensingBatchTemplate.Description as RepeatDispensingTemplate_Description
//
//	Modification History:
//	20May09 AJK  Written
//  15Mar11 TH   Added Additional Information for F0082043 - Repeat Dispensing schedule print
//  17May11 XN   Removed BagLabels, and added RepeatDispensingTemplateID
//               Added method CountByTemplateAndActive F0057909 
//  16Apr12 AJK  31236 Added Updated, UpdatedBy and UpdatedByDescription fields
//  17Jul12 AJK  38690 Added EpisodeID of active (if not lifetime) episode
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
    /// Represents a row in the RepeatDispensingPatient table
    /// </summary>
    public class RepeatDispensingPatientRow : BaseRow
    {
        /// <summary>
        /// Primary Key, read only
        /// </summary>
        public int RepeatDispensingPatientID
        {
            get { return FieldToInt(RawRow["RepeatDispensingPatientID"]).Value; }
            set { RawRow["RepeatDispensingPatientID"] = IntToField(value); }
        }

        /// <summary>
        /// The EntityID for the selected patient
        /// </summary>
        public int EntityID
        {
            get { return FieldToInt(RawRow["EntityID"]).Value; }
            set { RawRow["EntityID"] = IntToField(value); }
        }

        /// <summary>
        /// The number of days supply to dispense
        /// </summary>
        public int? SupplyDays
        {
            get { return FieldToInt(RawRow["SupplyDays"]); }
            set { RawRow["SupplyDays"] = IntToField(value); }
        }

        /// <summary>
        /// If dispensing is produced by an active dispensing machine
        /// This includes JVM or MTS's (ADM) machines
        /// </summary>
        public bool? ADM
        {
            get { return FieldToBoolean(RawRow["ADM"]); }
            set { RawRow["ADM"] = BooleanToField(value); }
        }

        /// <summary>
        /// Denotes if the patient is currently marked as active for repeat dispensing
        /// </summary>
        public bool? InUse
        {
            get { return FieldToBoolean(RawRow["InUse"]); }
            set { RawRow["InUse"] = BooleanToField(value); }
        }

        /// <summary>
        /// Supply pattern
        /// </summary>
        public SupplyPattern? SupplyPattern
        {
            get { return FieldToEnumViaDBLookup<SupplyPattern>(RawRow["SupplyPatternID"]); }
            set { RawRow["SupplyPatternID"] = EnumToFieldViaDBLookup<SupplyPattern>(value); }
        }
        /// <summary>
        /// AdditionalInformation. A piece of user text used on the printed medicine schedule
        /// </summary>
        public string AdditionalInformation
        {
            get { return FieldToStr(RawRow["AdditionalInformation"], false, string.Empty); }
            set { RawRow["AdditionalInformation"] = StrToField(value); }
        }

        /// <summary>
        /// Template ID assigned to the patient repeat dispening settings
        /// 16May11 XN Added
        /// </summary>
        public int? RepeatDispensingBatchTemplateID 
        {
            get { return FieldToInt(RawRow["RepeatDispensingBatchTemplateID"]);  }
            set { RawRow["RepeatDispensingBatchTemplateID"] = IntToField(value); }
        }

        /// <summary>
        /// Description of Template assigned to the patient repeat dispening settings
        /// 16May11 XN Added
        /// </summary>
        public string RepeatDispensingBatchTemplateDescription
        {
            get { return FieldToStr(RawRow["RepeatDispensingBatchTemplate_Description"], false, string.Empty);  }
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
            get { return FieldToStr(RawRow["UpdatedBy_Description"],true,string.Empty); }
        }

        /// <summary>
        /// The most recent, open, childless episodeID, reverting to lifetime episodeID if none found
        /// </summary>
        public int? EpisodeID
        {
            get { return FieldToInt(RawRow["EpisodeID"]); }
        }
    }

    /// <summary>
    /// Provides information of the RepeatDispensingPatient table's columns
    /// </summary>
    public class RepeatDispensingPatientBaseColumnInfo : BaseColumnInfo
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public RepeatDispensingPatientBaseColumnInfo() : base("RepeatDispensingPatient") { }
    }

    /// <summary>
    /// Represents the RepeatDispensingPatient table
    /// </summary>
    public class RepeatDispensingPatient : BaseTable<RepeatDispensingPatientRow, RepeatDispensingPatientBaseColumnInfo>
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public RepeatDispensingPatient() : base("RepeatDispensingPatient", "RepeatDispensingPatientID")
        {
            UpdateSP = "pRepeatDispensingPatientUpdate";
        }

        /// <summary>
        /// Load the settings for a selected patient
        /// </summary>
        /// <param name="entityID">EntityID of the requested patient</param>
        public void LoadByEntityID(int entityID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "EntityID", entityID);
            LoadRecordSetStream("pRepeatDispensingPatientByEntityID", parameters);
        }

        /// <summary>Returns number of patients linked to the template</summary>
        /// <param name="repeatDispensingBatchTemplateID">Repeat dispensing template ID</param>
        /// <returns>Number of patients linked to template</returns>
        public static int CountByTemplate(int repeatDispensingBatchTemplateID)
        {
            StringBuilder parameters = new StringBuilder();
            RepeatDispensingPatient temp = new RepeatDispensingPatient();
            temp.AddInputParam(parameters, "RepeatDispensingBatchTemplateID", repeatDispensingBatchTemplateID);
            return temp.ExecuteScalar("pRepeatDispensingPatientCountByTemplate", parameters);
        }

        /// <summary>Sets the repeat dispensing batch template ID to NULL</summary>
        /// <param name="repeatDispensingBatchTemplateID">Repeat dispensing template ID</param>
        public static void ClearRepeatDispensingBatchTemplateID(int repeatDispensingBatchTemplateID)
        {
            StringBuilder parameters = new StringBuilder();
            RepeatDispensingPatient temp = new RepeatDispensingPatient();
            temp.AddInputParam(parameters, "RepeatDispensingBatchTemplateID", repeatDispensingBatchTemplateID);
            temp.dblayer.ExecuteUpdateCustomSP(SessionInfo.SessionID, "pRepeatDispensingPatientClearTemplate", parameters.ToString());
        }
    }
}
