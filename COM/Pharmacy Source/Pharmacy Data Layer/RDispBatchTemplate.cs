//===========================================================================
//
//							       RDispBatchTemplate.cs
//
//  Provides access to RepeatDispensingBatchTemplate table.
//
//	Modification History:
//	03May11 AJK Written
//  16May11 XN  Added Logical deletes
//===========================================================================
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>
    /// Represents a repeat dispensing batch template row in the database
    /// </summary>
    public class RepeatDispensingBatchTemplateRow : BaseRow
    {
        /// <summary>
        /// The primary key
        /// </summary>
        public int RepeatDispensingBatchTemplateID
        {
            get { return FieldToInt(RawRow["RepeatDispensingBatchTemplateID"]).Value; }
        }

        /// <summary>
        /// The description of the batch
        /// </summary>
        public string Description
        {
            get { return FieldToStr(RawRow["Description"]); }
            set { RawRow["Description"] = StrToField(value); }
        }

        /// <summary>
        /// The LocationID (or SiteID) for the template, used for location filtering
        /// </summary>
        public int? LocationID
        {
            get { return FieldToInt(RawRow["LocationID"]); }
            set { RawRow["LocationID"] = IntToField(value); }
        }

        public string LocationDescription
        {
            get { return FieldToStr(RawRow["LocationDescription"]); }
        }

        /// <summary>
        /// Indicates if the patient selection is to include in-patients
        /// </summary>
        public bool InPatient
        {
            get { return FieldToBoolean(RawRow["InPatient"]).Value; }
            set { RawRow["InPatient"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the patient selection is to include out-patients
        /// </summary>
        public bool OutPatient
        {
            get { return FieldToBoolean(RawRow["OutPatient"]).Value; }
            set { RawRow["OutPatient"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the patient selection is to include discharge patients
        /// </summary>
        public bool Discharge
        {
            get { return FieldToBoolean(RawRow["Discharge"]).Value; }
            set { RawRow["Discharge"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the patient selection is to include patients on leave
        /// </summary>
        public bool Leave
        {
            get { return FieldToBoolean(RawRow["Leave"]).Value; }
            set { RawRow["Leave"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the patient selection should select all patients by default
        /// </summary>
        public bool SelectPatientsByDefault
        {
            get { return FieldToBoolean(RawRow["SelectPatientsByDefault"]).Value; }
            set { RawRow["SelectPatientsByDefault"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates the number of bag labels per patient
        /// </summary>
        public int BagLabels
        {
            get { return FieldToInt(RawRow["BagLabels"]).Value; }
            set { RawRow["BagLabels"] = IntToField(value); }
        }

        /// <summary>
        /// Indicates whether the batch should use a JVM packer robot
        /// </summary>
        public bool JVM
        {
            get { return FieldToBoolean(RawRow["JVM"]).Value; }
            set { RawRow["JVM"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if a JVM batch should default the start date to tomorrow
        /// </summary>
        public bool? JVMDefaultStartTomorrow
        {
            get { return FieldToBoolean(RawRow["JVMDefaultStartTomorrow"]); }
            set { RawRow["JVMDefaultStartTomorrow"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates the duration of the JVM batch
        /// </summary>
        public int? JVMDuration
        {
            get { return FieldToInt(RawRow["JVMDuration"]); }
            set { RawRow["JVMDuration"] = IntToField(value); }
        }

        /// <summary>
        /// Indicates if the JVM batch should use the breakfast slot
        /// </summary>
        public bool? JVMBreakfast
        {
            get { return FieldToBoolean(RawRow["JVMBreakfast"]); }
            set { RawRow["JVMBreakfast"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the JVM batch should use the lunch slot
        /// </summary>
        public bool? JVMLunch
        {
            get { return FieldToBoolean(RawRow["JVMLunch"]); }
            set { RawRow["JVMLunch"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the JVM batch should use the teatime slot
        /// </summary>
        public bool? JVMTea
        {
            get { return FieldToBoolean(RawRow["JVMTea"]); }
            set { RawRow["JVMTea"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the JVM batch should use the night time slot
        /// </summary>
        public bool? JVMNight
        {
            get { return FieldToBoolean(RawRow["JVMNight"]); }
            set { RawRow["JVMNight"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the JVM batch should include manually dispensed items
        /// </summary>
        public bool? JVMIncludeManual
        {
            get { return FieldToBoolean(RawRow["JVMIncludeManual"]); }
            set { RawRow["JVMIncludeManual"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the JVM run should sort it's output by admin slot rather than alphabetically by patient
        /// </summary>
        public bool? JVMSortByAdminSlot
        {
            get { return FieldToBoolean(RawRow["JVMSortByAdminSlot"]); }
            set { RawRow["JVMSortByAdminSlot"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the template is in-use
        /// </summary>
        public bool InUse
        {
            get { return FieldToBoolean(RawRow["InUse"]).Value; }
            set { RawRow["InUse"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the template is deleted
        /// </summary>
        public bool _Deleted
        {
            get { return FieldToBoolean(RawRow["_Deleted"]).Value; }
            set { RawRow["_Deleted"] = BooleanToField(value); }
        }

        /// <summary>Returns template descritpion</summary>
        public override string ToString()
        {
            return Description;
        }
    }

    /// <summary>
    /// Returns column information for the repeat dispensing batch template table
    /// </summary>
    public class RepeatDispensingBatchTemplateColumnInfo : BaseColumnInfo
    {
        public RepeatDispensingBatchTemplateColumnInfo() : base("RepeatDispensingBatchTemplate") { }
    }

    /// <summary>
    /// Represents the repeat dispensing batch template table
    /// </summary>
    public class RepeatDispensingBatchTemplate : BaseTable<RepeatDispensingBatchTemplateRow, RepeatDispensingBatchTemplateColumnInfo>
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public RepeatDispensingBatchTemplate()
            : base("RepeatDispensingBatchTemplate", "RepeatDispensingBatchTemplateID")
        {
            UpdateSP = "pRepeatDispensingBatchTemplateUpdate";
            IncludeSessionLockInInsert = true;
            IncludeSessionLockInUpdate = true;
            UseLogicalDelete           = true;
        }

        /// <summary>
        /// Constructor with row locking
        /// </summary>
        /// <param name="rowLocking">Indicates if the row should be locked</param>
        public RepeatDispensingBatchTemplate(RowLocking rowLocking)
            : base("RepeatDispensingBatchTemplate", "RepeatDispensingBatchTemplateID", rowLocking)
        {
            UpdateSP = "pRepeatDispensingBatchTemplateUpdate";
            IncludeSessionLockInInsert = true;
            IncludeSessionLockInUpdate = true;
        }

        /// <summary>
        /// Loads templates by a specific ID
        /// </summary>
        /// <param name="repeatDispensingBatchTemplateID">The primary key of the template</param>
        public void LoadByRepeatDispensingBatchTemplateID(int repeatDispensingBatchTemplateID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "RepeatDispensingBatchTemplateID", repeatDispensingBatchTemplateID);
            //LoadRecordSetStream("pRepeatDispensingBatchTemplateSelect", parameters);
            LoadRecordSetStream("pRepeatDispensingBatchTemplateSelect", parameters);
        }

        public void LoadByDescription(string description)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "Description", description);
            LoadRecordSetStream("pRepeatDispensingBatchTemplateByDescription", parameters);
        }

        /// <summary>
        /// Loads all templates
        /// </summary>
        public void LoadAll()
        {
            StringBuilder parameters = new StringBuilder();
            LoadRecordSetStream("pRepeatDispensingBatchTemplateLoadAll", parameters);
        }

        /// <summary>
        /// Loads all templates which are marked as in-use
        /// </summary>
        public void LoadInUse()
        {
            StringBuilder parameters = new StringBuilder();
            LoadRecordSetStream("pRepeatDispensingBatchTemplateLoadActive", parameters);
        }

        /// <summary>Returns templates by a specific ID (null if does not exists)</summary>
        /// <param name="repeatDispensingBatchTemplateID">The primary key of the template</param>
        /// <returns>templates by a specific ID (null if does not exists)</returns>
        public static RepeatDispensingBatchTemplateRow GetByByRepeatDispensingBatchTemplateID(int repeatDispensingBatchTemplateID)
        {
            RepeatDispensingBatchTemplate template = new RepeatDispensingBatchTemplate();
            template.LoadByRepeatDispensingBatchTemplateID(repeatDispensingBatchTemplateID);
            return template.Any() ? template[0] : null;
        }
    }
}
