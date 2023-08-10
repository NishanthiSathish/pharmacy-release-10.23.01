//===========================================================================
//
//					    RequestTypeStatusNote.cs
//
//  Provides access to RequestTypeStatusNote table.
//
//  sps used by this class should also return 
//      NoteType.Description
//      Table.TableName
//      Table.TableID
//
//  Only supports reading.
//
//	Modification History:
//  15Nov12 XN  Created TFS47487
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>RequestTypeStatusNote TypeOfNote field type</summary>
    public enum TypeOfNoteType
    {
        /// <summary>null or empty db code</summary>
        [EnumDBCode("")]  Unknown,
        [EnumDBCode("Status")] Status,
        [EnumDBCode("Workflow Action")] WorkflowAction
    }
    
    /// <summary>Represents a record in the RequestTypeStatusNote table</summary>
    public class RequestTypeStatusNoteRow : BaseRow
    {
        public int    RequestTypeStatusNoteID { get { return FieldToInt(RawRow["RequestTypeStatusNoteID"]).Value; } }
        public int    RequestTypeID           { get { return FieldToInt(RawRow["RequestTypeID"]).Value;           } }  
        public int    NoteTypeID              { get { return FieldToInt(RawRow["NoteTypeID"]).Value;              } }  
        public int    TableID                 { get { return FieldToInt(RawRow["TableID"]).Value;                 } } 

        public string ApplyVerb               { get { return FieldToStr(RawRow["ApplyVerb"],            true, string.Empty); } }
        public string DeactivateVerb          { get { return FieldToStr(RawRow["DeactivateVerb"],       true, string.Empty); } }
        public string NoteType_Description    { get { return FieldToStr(RawRow["NoteType_Description"], true, string.Empty); } }
        public string PreconditionRoutine     { get { return FieldToStr(RawRow["PreconditionRoutine"],  true, string.Empty); } } 
        public string TableName               { get { return FieldToStr(RawRow["TableName"],            true, string.Empty); } } 
        public TypeOfNoteType TypeOfNote      { get { return FieldToEnumByDBCode<TypeOfNoteType>(RawRow["TypeOfNote"]);      } }
        

        public bool DiscontinuationReasonMandatory { get { return FieldToBoolean(RawRow["DiscontinuationReasonMandatory"]).Value; } }
        public bool StopOnError                    { get { return FieldToBoolean(RawRow["StopOnError"]).Value;                    } }
        public bool AllowDuplicates                { get { return FieldToBoolean(RawRow["AllowDuplicates"]).Value;                } } 
        public bool UserAuthentication             { get { return FieldToBoolean(RawRow["UserAuthentication"]).Value;             } } 
        public bool HasForm                        { get { return TableName != "AttachedNote";                                    } }              
    }

    /// <summary>Represent the RequestTypeStatusNote table</summary>
    public class RequestTypeStatusNote : BaseTable2<RequestTypeStatusNoteRow, BaseColumnInfo>
    {
        public RequestTypeStatusNote() : base("RequestTypeStatusNote") { }

        #region Public methods
        /// <summary>Returns a RequestTypeStatusNote by note and request type</summary>
        /// <param name="noteTypeID">Note type</param>
        /// <param name="requestTypeID">Request Type</param>
        /// <returns>RequestTypeStatusNote or null</returns>
        static public RequestTypeStatusNoteRow GetByNoteTypeAndRequestType(int noteTypeID, int requestTypeID)
        {
            RequestTypeStatusNote requestTypeStatusNote = new RequestTypeStatusNote();
            requestTypeStatusNote.LoadByNoteTypeAndRequestType(noteTypeID, requestTypeID);
            return requestTypeStatusNote.FirstOrDefault();
        }

        /// <summary>
        /// Get all the RequestTypeStatusNote that could be displayed in dispensing PMR
        /// This information is cached
        /// </summary>
        /// <returns>RequestTypeStatusNote to display in dispensing PMR</returns>
        static public IEnumerable<RequestTypeStatusNoteRow> GetForDispensingPMR()
        {
            string cacheName = string.Format("{0}.GetForDispensingPMR", typeof(ICWTypes).FullName);

            // Try to get from cache
            RequestTypeStatusNote requestTypeStatusNote = PharmacyDataCache.GetFromCache(cacheName) as RequestTypeStatusNote;
            if (requestTypeStatusNote == null)
            {
                // No in cache so read from DB
                requestTypeStatusNote = new RequestTypeStatusNote();
                requestTypeStatusNote.LoadForDispensingPMR();

                // Save to cache
                PharmacyDataCache.SaveToCache(cacheName, requestTypeStatusNote);
            }

            return requestTypeStatusNote;
        }
        #endregion

        #region Private Methods
        /// <summary>Loads a RequestTypeStatusNote by note, and request type</summary>
        /// <param name="noteTypeID">Note type</param>
        /// <param name="requestTypeID">Request type</param>
        private void LoadByNoteTypeAndRequestType(int noteTypeID, int requestTypeID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID));
            parameters.Add(new SqlParameter("@NoteTypeID",    noteTypeID));
            parameters.Add(new SqlParameter("@RequestTypeID", requestTypeID));
            LoadBySP("pRequestTypeStatusNoteByNoteTypeAndRequestType", parameters);
        }

        /// <summary>Loads all RequestTypeStatusNote that could be displayed in dispensing PMR</summary>
        private void LoadForDispensingPMR()
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID));
            LoadBySP("pRequestTypeStatusNoteForDispensingPMR", parameters);
        }
        #endregion
    }
}
