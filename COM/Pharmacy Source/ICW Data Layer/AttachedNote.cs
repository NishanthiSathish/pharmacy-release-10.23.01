//===========================================================================
//
//							AttachedNote.cs
//
//  Provides access to AttachedNote table.
//
//  Classes are derived from Note.
//
//  Use AttachedNote to get an instance of the AttachedNote class.
//
//  AttachedNoteBase was used for hierarchies but is now deprecated
//
//  Only supports reading, inserting.
//
//	Modification History:
//	03Sep10 XN  Written (F0082255)
//  15Nov12 XN  TFS47487 moved GetAttachedNoteCountByType from request,
//              Added method LoadByNoteTypeIDAndRequestIDs
//  18Jan13 XN  Added method LoadByNoteTypeIDRequestIDsAndEnabled 46269 
//===========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Represents a record in the AttachedNote (and Note) table</summary>
    public class AttachedNoteRow : NoteRow
    {
        public bool Enabled
        {
            get { return FieldToBoolean(RawRow["Enabled"]).Value;   }
            set { RawRow["Enabled"] = BooleanToField(value);        }
        }
    }

    /// <summary>Provides column information about the AttachedNote table (and Note table)</summary>
    public class AttachedNoteColumnInfo : NoteColumnInfo
    {
        public AttachedNoteColumnInfo(string tableName) : base(tableName) { }

        public AttachedNoteColumnInfo() : base("AttachedNote") { }
    }

    /// <summary>Represent the AttachedNote table</summary>
    [Obsolete]
    public class AttachedNoteBase<T, C> : Note<T, C>
        where T : AttachedNoteRow, new()
        where C : AttachedNoteColumnInfo, new()
    {
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="tableName">Name of db table class is associated with</param>
        /// <param name="pkcolumnName">Name of db PK column for table</param>
        /// <param name="noteTypeName">Name of the associated note type (must be registered in ICW NoteType table)</param>
        public AttachedNoteBase(string tableName, string pkcolumnName, string noteTypeName) : base(tableName, pkcolumnName, noteTypeName) { }

        /// <summary>
        /// Adds a new row. 
        /// Defaults AttachedNote.Enabled to true
        /// Will also default values of Note (see Note.Add)
        /// </summary>
        /// <returns>New row</returns>
        public override T Add()
        {
            T newRow = base.Add();
            newRow.Enabled = true;
            return newRow;
        }
    }

    /// <summary>Represent the AttachedNote table</summary>
    public class AttachedNote : Note<AttachedNoteRow, AttachedNoteColumnInfo>
    {
        public AttachedNote() : base("AttachedNote", "NoteID", "Attached Note") { }

        /// <summary>
        /// Adds a new row. 
        /// Defaults AttachedNote.Enabled to true
        /// Will also default values of Note (see Note.Add)
        /// </summary>
        /// <returns>New row</returns>
        public override AttachedNoteRow Add()
        {
            AttachedNoteRow newRow = base.Add();
            newRow.Enabled = true;
            return newRow;
        }
        
        /// <summary>
        /// Adds a new row. 
        /// Defaults AttachedNote.Enabled to true, and sets the description
        /// Will also default values of Note (see Note.Add)
        /// 15Apr16 XN 123082
        /// </summary>
        /// <returns>New row</returns>
        public AttachedNoteRow Add(string description)
        {
            AttachedNoteRow newRow = base.Add();
            newRow.Enabled     = true;
            newRow.Description = description;
            return newRow;
        }

        /// <summary>Loads the notes (by note type), for all requestIDs requests</summary>
        /// <param name="noteTypeID">Note type</param>
        /// <param name="requestIDs">Requests</param>
        public void LoadByNoteTypeIDAndRequestIDs(int noteTypeID, IEnumerable<int> requestIDs)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "NoteTypeID", noteTypeID);
            AddInputParam(parameters, "RequestIDs", requestIDs.ToCSVString(","));
            LoadRecordSetStream("pAttachedNoteByRequestIDs", parameters);
        }

        /// <summary>Loads enabled notes (by note type), for all requestIDs requests</summary>
        /// <param name="noteTypeID">Note type</param>
        /// <param name="requestIDs">Requests</param>
        public void LoadByNoteTypeIDRequestIDsAndEnabled(int noteTypeID, IEnumerable<int> requestIDs)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "NoteTypeID", noteTypeID);
            AddInputParam(parameters, "RequestIDs", requestIDs.ToCSVString(","));
            LoadRecordSetStream("pAttachedNoteByRequestIDsAndEnabled", parameters);
        }        

        /// <summary>
        /// Returns a count of notes attached to the specified request by noteType description
        /// TFS47487 XN 15Nov12 moved from request
        /// </summary>
        /// <param name="requestID">The requestID of the request to be checked</param>
        /// <param name="noteType">The note type description to be checked</param>
        /// <returns>Count of attached notes of the specified type attached to the request</returns>
        public static int GetAttachedNoteCountByType(int requestID, string noteType)
        {
            AttachedNote attachNote = new AttachedNote();
            StringBuilder parameters = new StringBuilder();
            attachNote.AddInputParam(parameters, "RequestID", requestID);
            attachNote.AddInputParam(parameters, "NoteType", noteType);
            return attachNote.ExecuteScalar("pAttachedNoteCountByRequestIDAndNoteType", parameters);
        }
    }
}
