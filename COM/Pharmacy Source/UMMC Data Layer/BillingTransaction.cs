//===========================================================================
//
//							BillingTransaction.cs
//
//  Provides access to BillingTransaction table.
//
//  Class is derived from AttachedNote (and then from Note)
//
//  The table holds detials of a dispensed drug the user has selected for billing.
//  This will be then picked up by and ascribe interface to an external system
//  This table is UMMC specific, and is only present in the UMMC custom script. 
//
//  A set of BillingTransaction are assoicated under a batch (in BillingTransactionBatch table)
//  this association is via the BillingTransactionBatch.NoteID to BillingTransaction.NoteID_Thread.
//  A BillingTransaction can have 1 or many WTranlogs associated with it via the 
/// BillingTransactionLinkWTranslog table.
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
using ascribe.pharmacy.icwdatalayer;

namespace ascribe.pharmacy.ummcdatalayer
{
    /// <summary>Represents a record in the BillingTransaction, AttachedNote, and Note tables</summary>
    public class BillingTransactionRow : AttachedNoteRow
    {
        public int? EntityID_Consultant
        {
            get { return FieldToInt(RawRow["EntityID_Consultant"]);  }
            set { RawRow["EntityID_Consultant"] = IntToField(value); }
        }

        public int? EpisodeID
        {
            get { return FieldToInt(RawRow["EpisodeID"]);  }
            set { RawRow["EpisodeID"] = IntToField(value); }
        }

        public int? LocationID_Ward
        {
            get { return FieldToInt(RawRow["LocationID_Ward"]);  }
            set { RawRow["LocationID_Ward"] = IntToField(value); }
        }

        public string NSVCode
        {
            get { return FieldToStr(RawRow["NSVCode"]);  }
            set { RawRow["NSVCode"] = StrToField(value); }
        }

        public string StoresDescription
        {
            get { return FieldToStr(RawRow["StoresDescription"]);  }
            set { RawRow["StoresDescription"] = StrToField(value); }
        }

        /// <summary>DB int field [Site]</summary>
        public int SiteNumber
        {
            get { return FieldToInt(RawRow["Site"]) ?? 0;  } 
            set { RawRow["Site"] = IntToField(value);       } 
        }

        public string PrescriptionNum
        {
            get { return FieldToStr(RawRow["PrescriptionNum"]);  }
            set { RawRow["PrescriptionNum"] = StrToField(value); }
        }

        /// <summary>DB float field Quantity</summary>
        public decimal QuantityInIssueUnits
        {
            get { return FieldToDecimal(RawRow["Quantity"]) ?? 0m; }
            set { RawRow["Quantity"] = DecimalToField(value);      }
        }

        /// <summary>DB float field Cost</summary>
        public decimal CostPerPackExVat
        {
            get { return FieldToDecimal(RawRow["Cost"]) ?? 0m; }
            set { RawRow["Cost"] = DecimalToField(value);      }
        }
    }

    /// <summary>Provides column information about the BillingTransaction, AttachedNote, and Note tables</summary>
    public class BillingTransactionColumnInfo : AttachedNoteColumnInfo
    {
        public BillingTransactionColumnInfo() : base("BillingTransaction") { }

        public int StoresDescriptionLength { get { return tableInfo.GetFieldLength("StoresDescription"); } }
    }

    /// <summary>Represent the BillingTransaction, AttachedNote, and Note tables</summary>
    public class BillingTransaction : AttachedNoteBase<BillingTransactionRow, BillingTransactionColumnInfo>
    {
        public BillingTransaction() : base("BillingTransaction", "NoteID", "BillingTransaction") 
        {            
        }

        /// <summary>Links a WTranslog rows with the billing transaction</summary>
        /// <param name="noteID_BillingTransaction">ID of billing transaction row</param>
        /// <param name="wtranslogIDs">IDs of translog row</param>
        public void AssociateBillingTransactionWithWTranslog(int noteID_BillingTransaction, IEnumerable<int> wtranslogIDs)
        {
            foreach(int wtranslogID in wtranslogIDs)
                this.InsertLink("BillingTransactionLinkWTranslog", "NoteID", noteID_BillingTransaction, "WTranslogID", wtranslogID);
        }
    }
}
