//===========================================================================
//
//							       Request.cs
//
//  Provides access to Request table.
//
//  Supports updating, reading, and inserting.
//
//	Modification History:
//	30Jun09 AJK  Written
//  01Dec11 XN   Added updating, and inserting support.
//  23Jan12 XN   Added GetRequestType() as virtual method, for SupplyRequest
//  16Mar12 XN   Added GetStatus (TFS28157)
//  13Apr12 AJK  31212 Added AttachedNoteCountByType
//  15Nov12 XN   TFS47487 Change Request to derive from BaseTable2, 
//               added method LoadByIDs, moved AttachedNoteCountByType to AttachedNote
//  7Oct13  XN   73427 RequestRow.Cancel checked if db has cancelled column before doing update on it.
//  11Sep14 XN   88799 added method GetByRequestID
//  01Jul15 XN   Added RequestRow.LinkNote 39882
//  15Oct15 XN   77977 Fixed is with Request constructor
//===========================================================================
namespace ascribe.pharmacy.icwdatalayer
{
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

    public class RequestRow  : BaseRow
    {
        public int RequestID
        {
            get { return FieldToInt(RawRow["RequestID"]).Value; }
        }
        public int RequestID_Parent
        {
            get { return FieldToInt(RawRow["RequestID_Parent"]).Value; }
            set { RawRow["RequestID_Parent"] = IntToField(value); }
        }
        public int RequestTypeID
        {
            get { return FieldToInt(RawRow["RequestTypeID"]).Value; }
            set { RawRow["RequestTypeID"] = IntToField(value);      }
        }
        public int TableID
        {
            get { return FieldToInt(RawRow["TableID"]).Value; }
            set { RawRow["TableID"] = IntToField(value);      }
        }
        public int EntityID
        {
            get { return FieldToInt(RawRow["EntityID"]).Value; }
            set { RawRow["EntityID"] = IntToField(value);      }
        }
        public int ScheduleID
        {
            get { return FieldToInt(RawRow["ScheduleID"]).Value; }
            set { RawRow["ScheduleID"] = IntToField(value);      }
        }
        public DateTime CreatedDate
        {
            get { return FieldToDateTime(RawRow["CreatedDate"]).Value; }
            set { RawRow["CreatedDate"] = DateTimeToField(value);      }
        }
        public DateTime RequestDate
        {
            get { return FieldToDateTime(RawRow["RequestDate"]).Value; }
            set { RawRow["RequestDate"] = DateTimeToField(value);      }
        }
        public string Description
        {
            get { return FieldToStr(RawRow["Description"]);    }
            set { RawRow["Description"] = StrToField(value);   }
        }
        public int? RequestID_Batch
        {
            get { return FieldToInt(RawRow["RequestID_Batch"]);  }
            set { RawRow["RequestID_Batch"] = IntToField(value); }
        }
        public int? CommitBatchID
        {
            get { return FieldToInt(RawRow["CommitBatchID"]);  }
            set { RawRow["CommitBatchID"] = IntToField(value); }
        }

        /// <summary>
        /// Cancels the request (setting the cancelation note), and all child requests if needed
        /// Child request have same cancellation note as parent
        /// Best to call this method in a transaction
        /// </summary>
        /// <param name="discontinuationReasonID">Reason for cancelation</param>
        /// <param name="detail">Detailed info on cancelation</param>
        /// <param name="cancelAllChildren">If all child items are to be cancelled.</param>
        public virtual void Cancel(int discontinuationReasonID, string detail, bool cancelAllChildren)
        {
            // Prep list of item to cancel with current item
            List<int> requestIDs = new List<int>();
            requestIDs.Add(this.RequestID);

            // Find all child items to cancel and add them to list
            IEnumerable<int> currentParent = requestIDs;
            while (cancelAllChildren && currentParent.Any())
            {
                var children = Database.ExecuteSQLSingleField<int>("select RequestID from RequestStatus where ([Request Cancellation]=0) AND (Request__RequestID_Parent in ({0}))", currentParent.ToCSVString(","));
                requestIDs.AddRange(children);

                currentParent = children;
            }

            // Create cancelation note for each request to cancel
            RequestCancellation requestCancellation = new RequestCancellation();
            CancellationNote    cancellationNote    = new CancellationNote();
            DateTime now = DateTime.Now;
            int entityID = SessionInfo.EntityID;;

            foreach (int requestID in requestIDs.Distinct())
            {
                RequestCancellationRow newRow = requestCancellation.Add();
                newRow.CreatedDate             = now;
                newRow.Description             = "Cancellation for item " + requestID.ToString();
                newRow.Detail                  = detail;
                newRow.DiscontinuationReasonID = discontinuationReasonID;
                newRow.EntityID                = entityID;
                newRow.RequestID               = requestID;

                CancellationNoteRow newCancellationNote = cancellationNote.Add();
                newCancellationNote.CreatedDate             = now;
                newCancellationNote.Description             = "Cancellation for item " + requestID.ToString();
                newCancellationNote.DiscontinuationReasonID = discontinuationReasonID;
                newCancellationNote.EntityID                = entityID;
            }

            requestCancellation.Save();        
            cancellationNote.Save();

            // Cancel all request, and save the child item
            //string sql = string.Format("UPDATE RequestStatus SET cancelled=1, [Request Cancellation]=1, [Request_Cancellation__NoteID]=@NoteID, [Request_Cancellation__CreatedDate]=@CreatedDate, [Request_Cancellation__EntityID]=@EntityID where RequestID in ({0})", requestIDs.ToCSVString(","));
            string sql = "UPDATE RequestStatus SET ";
            if (Database.ExecuteSQLScalar<int?>("select TOP 1 1 from sys.columns where name='cancelled' and Object_ID=OBJECT_ID('RequestStatus')") != null) // TFS 73427 XN 7Oct13 Check cancelled column exists
                sql += "cancelled=1, "; // TFS 73427 XN 7Oct13 not all db have the cancelled column!
            sql += string.Format("[Request Cancellation]=1, [Request_Cancellation__NoteID]=@NoteID, [Request_Cancellation__CreatedDate]=@CreatedDate, [Request_Cancellation__EntityID]=@EntityID where RequestID in ({0})", requestIDs.ToCSVString(","));

            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@NoteID",      requestCancellation.First().NoteID  ));
            parameters.Add(new SqlParameter("@CreatedDate", now      ));
            parameters.Add(new SqlParameter("@EntityID",    entityID ));
            Database.ExecuteSQLNonQuery(sql, parameters);
        }

        /// <summary>Returns if request has been cancelled</summary>
        public bool IsCancelled()
        {
            return Database.ExecuteSQLScalar<bool?>("SELECT [Request Cancellation] FROM RequestStatus WHERE RequestID={0}", this.RequestID) ?? false;
        }

        /// <summary>Returns a request status (from RequestStatus)</summary>
        /// <param name="status">RequestStatus db field</param>
        public bool GetStatus(string status)
        {
            string sql = string.Format("SELECT [{0}] FROM RequestStatus WHERE RequestID={1}", status, this.RequestID);
            return Database.ExecuteSQLScalar<bool?>(sql) ?? false;
        }

        /// <summary>
        /// Used to set simple status that just require an attached note to process
        /// When setting status
        ///     Add attached note 
        ///     Update RequestStatus
        /// When clearing status
        ///     Add cancelation note
        ///     Will clear any previous AttachedNote.Enable flag
        ///     Update RequestStatus
        /// </summary>
        /// <param name="status">RequestStatus field to set</param>
        /// <param name="state">State on or off</param>
        public virtual void SetStatus(string status, bool state)
        {
            DateTime now = DateTime.Now;

            // If state is same as existing state then do nothing
            bool existingState = Database.ExecuteSQLScalar<bool>("SELECT [{0}] FROM RequestStatus WHERE RequestID={1}", status, this.RequestID);
            if (state == existingState)
                return;

            if (state)
            {
                // Create status note for request
                AttachedNote attachNotes = new AttachedNote();
                AttachedNoteRow attachNote = attachNotes.Add();
                attachNote.CreatedDate = now;
                attachNote.Description = status;
                attachNote.Enabled     = true;
                attachNote.EntityID    = SessionInfo.EntityID;
                attachNotes.Save();

                // Create link to request
                Database.InsertLink("RequestLinkAttachedNote", "RequestID", this.RequestID, "NoteID", attachNote.NoteID);

                // Update the status
                string sql = string.Format("UPDATE RequestStatus SET [{0}]=1, [{0}__NoteID]=@NoteID, [{0}__CreatedDate]=@CreatedDate, [{0}__EntityID]=@EntityID where RequestID=@RequestID", status);
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add(new SqlParameter("@NoteID",      attachNote.NoteID));
                parameters.Add(new SqlParameter("@CreatedDate", attachNote.CreatedDate));
                parameters.Add(new SqlParameter("@EntityID",    attachNote.EntityID));
                parameters.Add(new SqlParameter("@RequestID",   this.RequestID));
                Database.ExecuteSQLNonQuery(sql, parameters);
            }
            else
            {
                int originalNoteID = Database.ExecuteSQLScalar<int>("SELECT {0}__NoteID FROM RequestStatus WHERE RequestID={1}", status, this.RequestID);

                int? cancellationNoteID = null;
                if (ICWTypes.GetTypeByDescription(ICWType.Note, "Cancellation Note").HasValue)
                {
                    // Create cancellation note
                    CancellationNote cancelNotes = new CancellationNote();
                    CancellationNoteRow cancelNote = cancelNotes.Add();
                    cancelNote.CreatedDate             = now;
                    cancelNote.Description             = "Cancellation Note";
                    cancelNote.DiscontinuationReasonID = null;
                    cancelNote.EntityID = SessionInfo.EntityID;
                    cancelNotes.Save();

                    cancellationNoteID = cancelNote.NoteID;

                    // Create the link to original note
                    Database.InsertLink("CancellationNoteLinkNote", "NoteID", cancellationNoteID.Value, "NoteID_Cancelled", originalNoteID);
                }

                // Clear original note
                Database.ExecuteSQLNonQuery("UPDATE AttachedNote SET [Enabled]=0 WHERE NoteID={0}", originalNoteID);

                // And update status
                string sql = string.Format("UPDATE RequestStatus SET [{0}]=0, [{0}__NoteID]=@NoteID, [{0}__CreatedDate]=@CreatedDate, [{0}__EntityID]=@EntityID where RequestID=@RequestID", status);
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add(new SqlParameter("@NoteID",      cancellationNoteID));
                parameters.Add(new SqlParameter("@CreatedDate", now));
                parameters.Add(new SqlParameter("@EntityID",    SessionInfo.EntityID));
                parameters.Add(new SqlParameter("@RequestID",   this.RequestID));
                Database.ExecuteSQLNonQuery(sql, parameters);
            }
        }

        /// <summary>REturns if request is marked as complete (RequestStatus.Complete == 1)</summary>
        public bool IsComplete()
        {
            return Database.ExecuteSQLScalar<bool?>("SELECT [Complete] FROM RequestStatus WHERE RequestID={0}", this.RequestID) ?? false;
        }

        /// <summary>
        /// Completes the request
        ///     Writes a response in the the response table
        ///     update RequestStatus.Complete to 1
        /// Only works for simple response type that don't have their onw response derived table    
        /// </summary>
        /// <param name="responseType">Response type to write to the response table.</param>
        public void Complete(string responseType)
        {
            if (!IsComplete())
            {
                ICWTypeData? type = ICWTypes.GetTypeByDescription(ICWType.Response, responseType);
                if (!type.HasValue)
                    throw new ApplicationException("Invalid ResponseType '" + responseType + "'");

                // Create the response
                Response repsones = new Response();
                ResponseRow repsone     = repsones.Add();
                repsone.Description     = responseType;
                repsone.RequestID       = this.RequestID;
                repsone.ResponseTypeID  = type.Value.ID;
                repsone.ShortDescription= responseType;
                repsone.TableID         = type.Value.TableID ?? 0;
                repsones.Save();

                // Update the status
                Database.ExecuteSQLNonQuery("UPDATE RequestStatus SET Responses=(Responses+1), Complete=1 where RequestID={0}", this.RequestID);
            }
        }

        /// <summary>Inserts link into NoteLinkRequest 01Jul15 XN 39882</summary>
        /// <param name="noteId">Note ID</param>
        public void LinkNote(int noteId)
        {
            Database.InsertLink("NoteLinkRequest", "RequestID", this.RequestID, "NoteID", noteId);
        }
    }

    public class RequestColumnInfo : BaseColumnInfo
    {
        public RequestColumnInfo() : base("Request") { }

        public RequestColumnInfo(string inheritiedTableName) : base(inheritiedTableName) { }

        public int DescriptionLength { get { return base.FindColumnByName("Description").Length; } }
    }

    // public class Request : BaseTable<RequestRow, RequestColumnInfo>    // 15Nov12 XN TFS47487 
    public class Request : BaseTable2<RequestRow, RequestColumnInfo>
    {
        //public Request() : base("Request", "RequestID") 15Oct15 XN 77977 Invalid table RequestID
        public Request() : base("Request") { }

        public void LoadByRequestID(int requestID)
        {
            //StringBuilder parameters = new StringBuilder();       15Nov12 XN TFS47487 now using BaseTable2
            //AddInputParam(parameters, "RequestID", requestID);
            //LoadRecordSetStream("pRequestRawSelect", parameters);

            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID));
            parameters.Add(new SqlParameter("RequestID",        requestID));
            LoadBySP("pRequestRawSelect", parameters);
        }

        //public static int AttachedNoteCountByType(int requestID, string noteType)
        //{
        //    Request request = new Request();
        //    StringBuilder parameters = new StringBuilder();
        //    request.AddInputParam(parameters, "RequestID", requestID);
        //    request.AddInputParam(parameters, "NoteType", noteType);
        //    return request.ExecuteScalar("pAttachedNoteCountByRequestIDAndNoteType", parameters);
        //}

        /// <summary>Loads all request rows (should not really use for very large number of rows)</summary>
        /// <param name="requestIDs">Request IDs to load</param>
        public void LoadByIDs(IEnumerable<int> requestIDs)
        {
            LoadBySQL("SELECT * FROM Request (NOLOCK) WHERE RequestID in ({0})", requestIDs.ToCSVString(","));
        }

        /// <summary>Returns the request with the selected request ID or null  11Sep14 XN 88799</summary>
        public static RequestRow GetByRequestID(int requestID)
        {
            Request request = new Request();
            request.LoadByRequestID(requestID);
            return request.FirstOrDefault();
        }
    }

    public class RequestBaseTable<T,C> : BaseTable2<T, C>
        where T : RequestRow, new()
        where C : RequestColumnInfo, new()
    {
        public RequestBaseTable(string tableName, params string[] inhertiedTableNames) : base(tableName, inhertiedTableNames) { }

        #region Public Methods
        /// <summary>Adds a new row, and sets default values.</summary>
        /// <returns>New row</returns>
        public override T Add()
        {
            T newRow = base.Add();

            ICWTypeData requestType = GetRequestType();

            // Get the request type (for the parent table)
            // Set common defaults
            newRow.RequestTypeID = requestType.ID;
            newRow.TableID       = this.GetTableID();
            newRow.EntityID      = SessionInfo.EntityID;
            newRow.CreatedDate   = DateTime.Now;
            newRow.Description   = requestType.Description;
            newRow.ScheduleID    = 0;

            return newRow;
        }
        #endregion

        #region Protected Methods
        /// <summary>Get the RequestType for the Request done by TableID</summary>
        protected virtual ICWTypeData GetRequestType()
        {
            ICWTypeData? requestType = ICWTypes.GetTypeByTableID(ICWType.Request, this.GetTableID());
            if (requestType == null)
                throw new ApplicationException(string.Format("Request type info for table '{0}' is not in RequestType table (searching by RequestType.TableID={1})", this.TableName, this.GetTableID()));
            return requestType.Value;
        }
        #endregion

    }
}
