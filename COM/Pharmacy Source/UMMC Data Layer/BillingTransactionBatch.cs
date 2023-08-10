//===========================================================================
//
//					    BillingTransactionBatch.cs
//
//  Provides access to BillingTransactionBatch table.
//
//  Class is derived from AttachedNote (and then from Note)
//
//  A row in the table will hold detials of batch that groups a set of billing 
//  transactions, each bach is normaly related to a single patient.  
//
//  BillingTransaction are assoicated with batchs, via BillingTransactionBatch.NoteID 
//  to BillingTransaction.NoteID_Thread.
//
//  SP for this object should return all fields from AttachedNote, and Note 
//  tables.
//
//  Only supports inserting.
//
//	Modification History:
//	03Sep10 XN  Written (F0082255)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;

namespace ascribe.pharmacy.ummcdatalayer
{
    /// <summary>Represents a record in the BillingTransactionBatch, AttachedNote, and Note tables</summary>
    public class BillingTransactionBatchRow : AttachedNoteRow
    {
        public int BillingTransactionBatchID
        {
            get { return FieldToInt(RawRow["BillingTransactionBatchID"]).Value; }
        }

        public int LocationID_Terminal
        {
            get { return FieldToInt(RawRow["LocationID_Terminal"]).Value; }
            set { RawRow["LocationID_Terminal"] = IntToField(value);      }
        }

        public int EntityID_Patient
        {
            get { return FieldToInt(RawRow["EntityID_Patient"]).Value; }
            set { RawRow["EntityID_Patient"] = IntToField(value);      }
        }

        /// <summary>
        /// Bit meaningless as this is current episode of patient.
        /// There is another episode on BillingTransaction and this makes more sense, as this is for prescription.
        /// </summary>
        public int EpisodeID_Patient
        {
            get { return FieldToInt(RawRow["EpisodeID_Patient"]).Value; }
            set { RawRow["EpisodeID_Patient"] = IntToField(value);      }
        }
    }

    /// <summary>Provides column information about the BillingTransactionBatch, AttachedNote, and Note tables</summary>
    public class BillingTransactionBatchColumnInfo : AttachedNoteColumnInfo
    {
        public BillingTransactionBatchColumnInfo() : base("BillingTransactionBatch") { }
    }

    /// <summary>Represent the BillingTransactionBatch, AttachedNote, and Note tables</summary>
    public class BillingTransactionBatch : AttachedNoteBase<BillingTransactionBatchRow, BillingTransactionBatchColumnInfo>
    {
        public BillingTransactionBatch() : base("BillingTransactionBatch", "NoteID", "BillingTransactionBatch") 
        {            
        }

        /// <summary>
        /// Returns WTranslogIDs that have currently been billed to the patient under the specified time range
        /// </summary>
        /// <param name="entityID">Patient ID</param>
        /// <param name="startDate">Start date and time</param>
        /// <param name="endDate">End date and time</param>
        /// <returns></returns>
        public static HashSet<int> GetBilledWTranslogIDs(int entityID, DateTime startDate, DateTime endDate)
        {
            GenericTable translogIDs = new GenericTable(string.Empty, string.Empty);
            translogIDs.LoadBySP("pBillingTransactionBatchGetWTranslogIDs", "EntityID_Patient", entityID, "StartDate", startDate, "EndDate", endDate);

            IEnumerable<int> billedWTranslogIDs = translogIDs.Select(i => (int)i.RawRow["WTranslogID"]).Distinct();
            return new HashSet<int>(billedWTranslogIDs);
        }
    }
}
