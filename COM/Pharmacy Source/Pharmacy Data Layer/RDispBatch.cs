//===========================================================================
//
//							RDispBatch.cs
//
//  This class is a data layer representation of the Repeat Dispensing Batch
//
//	Modification History:
//	20May09 AJK  Written
//  13May10 XN   Added CountByTemplateAndActive
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
    /// Represents a row in the RepeatDispensingBatch table
    /// </summary>
    public class RepeatDispensingBatchRow : BaseRow
    {
        /// <summary>
        /// The BatchID primary key
        /// </summary>
        public int BatchID
        {
            get { return FieldToInt(RawRow["RepeatDispensingBatchID"]).Value; }
        }

        /// <summary>
        /// Description of the batch
        /// </summary>
        public string Description
        {
            get { return FieldToStr(RawRow["BatchDescription"]); }
            set { RawRow["BatchDescription"] = StrToField(value); }
        }

        /// <summary>
        /// Current status for the batch
        /// </summary>
        public BatchStatus Status
        {
            get { return FieldToEnumViaDBLookup<BatchStatus>(RawRow["StatusID"]).Value; }
            set { RawRow["StatusID"] = EnumToFieldViaDBLookup<BatchStatus>(value); }
        }

        /// <summary>
        /// The multiplication factor for the batch output
        /// </summary>
        public int Factor
        {
            get { return FieldToInt(RawRow["Factor"]).Value; }
            set { RawRow["Factor"] = IntToField(value); }
        }

        /// <summary>
        /// Template the repeat dispensing batch is connected to
        /// </summary>
        public int? RepeatDispensingBatchTemplateID
        {
            get { return FieldToInt(RawRow["RepeatDispensingBatchTemplateID"]); }
            set { RawRow["RepeatDispensingBatchTemplateID"] = IntToField(value); }
        }

        /// <summary>
        /// The start date for the batch if JVM
        /// </summary>
        public DateTime? StartDate
        {
            get { return FieldToDateTime(RawRow["StartDate"]); }
            set { RawRow["StartDate"] = DateTimeToField(value); }
        }

        /// <summary>
        /// The start slot for the batch if JVM (1 = breakfast, 2 = lunch, 3 = tea, 4 = night)
        /// </summary>
        public int? StartSlot
        {
            get { return FieldToInt(RawRow["StartSlot"]); }
            set { RawRow["StartSlot"] = IntToField(value); }
        }

        /// <summary>
        /// The total number of slots in the JVM batch, for a 4 slot day (so including all disabled slots)
        /// </summary>
        public int? TotalSlots
        {
            get { return FieldToInt(RawRow["TotalSlots"]); }
            set { RawRow["TotalSlots"] = IntToField(value); }
        }

        /// <summary>
        /// Indicates if the breakfast slot is enabled for the JVM batch
        /// </summary>
        public bool? Breakfast
        {
            get { return FieldToBoolean(RawRow["Breakfast"]); }
            set { RawRow["Breakfast"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the lunch slot is enabled for the JVM batch
        /// </summary>
        public bool? Lunch
        {
            get { return FieldToBoolean(RawRow["Lunch"]); }
            set { RawRow["Lunch"] = BooleanToField(value); }
        }
        
        /// <summary>
        /// Indicates if the tea slot is enabled for the JVM batch
        /// </summary>
        public bool? Tea
        {
            get { return FieldToBoolean(RawRow["Tea"]); }
            set { RawRow["Tea"] = BooleanToField(value); }
        }
        
        /// <summary>
        /// Indicates if the night slot is enabled for the JVM batch
        /// </summary>
        public bool? Night
        {
            get { return FieldToBoolean(RawRow["Night"]); }
            set { RawRow["Night"] = BooleanToField(value); }
        }

        /// <summary>
        /// The number of bag labels to be printed for each patient
        /// </summary>
        public int? BagLabelsPerPatient
        {
            get { return FieldToInt(RawRow["BagLabelsPerPatient"]); }
            set { RawRow["BagLabelsPerPatient"] = IntToField(value); }
        }

        /// <summary>
        /// Indicates if the JVM batch is to be printed in administration date/time order, rather than alphabetically by patient
        /// </summary>
        public bool? SortByDate
        {
            get { return FieldToBoolean(RawRow["SortByDate"]); }
            set { RawRow["SortByDate"] = BooleanToField(value); }
        }

        public int? LocationID
        {
            get { return FieldToInt(RawRow["LocationID"]); }
            set { RawRow["LocationID"] = IntToField(value); }
        }

        public string LocationDescription
        {
            get { return FieldToStr(RawRow["LocationDescription"]); }
        }

        public bool? IncludeManual
        {
            get { return FieldToBoolean(RawRow["IncludeManual"]); }
            set { RawRow["IncludeManual"] = BooleanToField(value); }
        }
    }

    /// <summary>
    /// Column information for the RepeatDispensingBatch table
    /// </summary>
    public class RepeatDispensingBatchColumnInfo : BaseColumnInfo
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public RepeatDispensingBatchColumnInfo() : base("RepeatDispensingBatch") { }

        /// <summary>
        /// The maximum length for the description field
        /// </summary>
        public int DescriptionLength { get { return tableInfo.GetFieldLength("BatchDescription"); } }
    }

    /// <summary>
    /// Represents the RepeatDispensingBatch table
    /// </summary>
    public class RepeatDispensingBatch : BaseTable<RepeatDispensingBatchRow, RepeatDispensingBatchColumnInfo>
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public RepeatDispensingBatch() : base("RepeatDispensingBatch", "RepeatDispensingBatchID")
        {
            UpdateSP = "pRepeatDispensingBatchUpdate";
        }

        /// <summary>
        /// Constructor with rowlocking option
        /// </summary>
        /// <param name="rowLocking">Lock rows</param>
        public RepeatDispensingBatch(RowLocking rowLocking) : base("RepeatDispensingBatch", "RepeatDispensingBatchID", rowLocking)
        {
            UpdateSP = "pRepeatDispensingBatchUpdate";
        }

        /// <summary>
        /// Load mechanism by BatchID
        /// </summary>
        /// <param name="batchID">BatchID of the required batch to be loaded</param>
        public void LoadByBatchID(int batchID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "RepeatDispensingBatchID", batchID);
            LoadRecordSetStream("pRepeatDispensingBatchByBatchID", parameters);
        }

        /// <summary>
        /// Load mechanism by StatusID, gets all batches of the specified status
        /// </summary>
        /// <param name="statusID">StatusID required</param>
        public void LoadByStatus(BatchStatus status)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "StatusID", EnumViaDBLookupAttribute.ToLookupID<BatchStatus>(status));
            LoadRecordSetStream("pRepeatDispensingBatchByStatusID", parameters);
        }

        public void LoadAllActive()
        {
            StringBuilder parameters = new StringBuilder();
            LoadRecordSetStream("pRepeatDispensingBatchByActiveStatus", parameters);
        }

        /// <summary>
        /// Loads all batches of an active status with the specified description
        /// </summary>
        /// <param name="description">Description to be matched</param>
        public void LoadActiveByDescription(string description)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "Description", description);
            LoadRecordSetStream("pRepeatDispensingActiveBatchByDescription", parameters);
        }

        public static void AddPatient(int batchID, int entityID)
        {
            StringBuilder parameters = new StringBuilder();
            RepeatDispensingBatch batch = new RepeatDispensingBatch();
            batch.AddInputParam(parameters, "BatchID", batchID);
            batch.AddInputParam(parameters, "EntityID", entityID);
            batch.dblayer.ExecuteInsertLinkSP(SessionInfo.SessionID, "RepeatDispensingBatchLinkEntity", parameters.ToString());
        }

        /// <summary>Returns number of active batches attached to the template</summary>
        /// <param name="repeatDispensingBatchTemplateID">template ID</param>
        /// <returns>number of batches</returns>
        public static int CountByTemplateAndActive(int repeatDispensingBatchTemplateID)
        {
            // Get active batch status codes
            string activeStatusCodes = string.Empty;
            activeStatusCodes += EnumViaDBLookupAttribute.ToLookupDescription(BatchStatus.New);
            activeStatusCodes += EnumViaDBLookupAttribute.ToLookupDescription(BatchStatus.Labelled);
            activeStatusCodes += EnumViaDBLookupAttribute.ToLookupDescription(BatchStatus.Issued);
            
            RepeatDispensingBatch temp = new RepeatDispensingBatch();
            StringBuilder parameters = new StringBuilder();
            temp.AddInputParam(parameters, "RepeatDispensingBatchTemplateID", repeatDispensingBatchTemplateID);
            temp.AddInputParam(parameters, "StatusCodes",                     activeStatusCodes);
            return temp.ExecuteScalar("pRepeatDispensingBatchCountByTemplateAndStatus", parameters);
        }
    }
}
