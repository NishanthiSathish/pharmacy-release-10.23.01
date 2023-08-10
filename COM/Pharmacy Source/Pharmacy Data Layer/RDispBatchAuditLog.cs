//====================================================================================
//
//							RDispBatchAuditLog.cs
//
//  This class is a data layer representation of the Repeat Dispensing Batch AuditLog
//
//	Modification History:
//	27May09 AJK  Written
//====================================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{

    /// <summary>
    /// Represents a row in the RepeatDispensingBatchAuditLog table
    /// </summary>
    public class RepeatDispensingBatchAuditLogRow : BaseRow
    {
        /// <summary>
        /// The BatchAuditLogID primary key
        /// </summary>
        public int BatchAuditLogID
        {
            get { return FieldToInt(RawRow["RepeatDispensingBatchAuditLogID"]).Value; }
        }

        /// <summary>
        /// Batch ID of the batch changed
        /// </summary>
        public int BatchID
        {
            get { return FieldToInt(RawRow["RepeatDispensingBatchID"]).Value; }
            set { RawRow["RepeatDispensingBatchID"] = IntToField(value); }
        }

        /// <summary>
        /// Status the batch is being changed to
        /// </summary>
        public BatchStatus Status
        {
            get { return FieldToEnumViaDBLookup<BatchStatus>(RawRow["StatusID"]).Value; }
            set { RawRow["StatusID"] = EnumToFieldViaDBLookup<BatchStatus>(value); }
        }

        /// <summary>
        /// The date and time the batch was changed, read only
        /// </summary>
        public DateTime DateChanged
        {
            get { return FieldToDateTime(RawRow["DateChanged"]).Value; }
            set { RawRow["DateChanged"] = DateTimeToField(value); }
        }

        /// <summary>
        /// EntityID of the user who updated the batch
        /// </summary>
        public int EntityID
        {
            get { return FieldToInt(RawRow["EntityID"]).Value; }
            set { RawRow["EntityID"] = IntToField(value); }
        }
    }

    /// <summary>
    /// Column information for the RepeatDispensingBatchAuditLog table
    /// </summary>
    public class RepeatDispensingBatchAuditLogColumnInfo : BaseColumnInfo
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public RepeatDispensingBatchAuditLogColumnInfo() : base("RepeatDispensingBatchAuditLog") { }
    }

    /// <summary>
    /// Represents the RepeatDispensingBatch table
    /// </summary>
    public class RepeatDispensingBatchAuditLog : BaseTable<RepeatDispensingBatchAuditLogRow, RepeatDispensingBatchAuditLogColumnInfo>
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public RepeatDispensingBatchAuditLog()
            : base("RepeatDispensingBatchAuditLog", "RepeatDispensingBatchAuditLogID")
        {
        }
    }


}
