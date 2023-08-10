// -----------------------------------------------------------------------
// <copyright file="StatusNotesProcessor.cs" company="Ascribe">
//
//  This class holds business logic for setting\clearing status notes.
//
//  The class provides an easier alternative to the standard ICW status note functions
//
//  The class has 2 main methods that can be used to change a request's state
//     SetStateQuickProcess - provides a quick method of changing a request's state 
//                            by-passing normal status note pre-condition validation,
//                            displaying order coms form, and printing.
//                            Used when changing status from server side.
//     SetStateFullProcess  - Provides full status note handling including pre-condition
//                            validation, displaying order coms form, and printing. 
//                            Used when changing status from client side by call javascript
//                            method SetStatusNoteState in file OCSProcessor.js
//                             
//  SetStateQuickProcess
//  -------------------- 
//  When setting status note method will
//      Insert lines to AttachedNote and Note
//      Links request via RequestLinkAttachedNote
//      Updates RequestStatus
//  When clearing status note method will 
//      Insert line to CancellationNote (and hence Note)
//      Links note to cancelation note via CancellationNoteLinkNote
//      Clears AttachedNote.Enabled
//      Clears RequestStatus
//
//  SetStateFullProcess
//  -------------------
//  As this method may require performing actions like asking users questions it will normal
//  be called via client side SetStatusNoteState in file OCSProcessor.js, 
//  This client side method will then call this class using web service OCSProcessor.asmx
//  Currently this method does not support the following ICW status note functions
//      User Authorisation
//      Support for response types
//      Mandatory discontinuation reason
//  The client side method SetStatusNoteState will handle asking the user pre-condition questions,
//  displaying, order coms questions, and printing
//  
//  Usage:
//  To set the PNAuthorised state, using SetStateQuickProcess (from server side)
//  StatusNotesProcessor.SetStateQuickProcess("PNAuthorised", new [] { 12432 }, true, null)
//
//  To set the PNAuthorised state, using SetStateFullProcess (from client side)
//  <script language="javascript" type="text/javascript" src="../pharmacysharedscripts/OCSProcessor.js" defer></script>
//   :
//  var noteTypeID = button.attr('notetypeid');
//  var noteTypeID = row.attr('requesttypeid');
//  var requestIDs = new Array(parseInt(row.attr('requestID'));
//  SetStatusNoteState(sessionID, noteTypeID, requestTypeID, requestIDs, true)
//      
// Modification History:
// 26Nov12 XN  Created
// 18Jun13 XN  Fixed issue with EnableRequestStatus if status data is bool  
//             also issue with DisableRequestStatus (extra checks)
// 29May15 XN  Updated SetStateFullProcess to resolve precondition from routine table
// </copyright>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.businesslayer
{
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.shared;
using OCSRTL10;

    /// <summary>Status notes business object</summary>
    public class StatusNotesProcessor : BusinessProcess
    {
        #region Public Data Types
        /// <summary>
        /// Sent from client side to indicate return data type.
        /// NOTE: Change to this object may require changes to client side OCSProcessor.js file
        /// </summary>
        public enum ValidationReturnType
        {
            /// <summary>When method called first time (no return data)</summary>
            None,

            /// <summary>When user confirms precondition question</summary>
            PreconditionResult,

            /// <summary>Note data return from order coms form</summary>
            NoteTypeData
        }

        /// <summary>
        /// Return result form SetStateFullProcess, object is used javascript 
        /// NOTE: Change to this object may require changes to client side OCSProcessor.js file
        /// </summary>
        public struct ValidationResult
        {
            public string resultType;       // string instead of enum as JSON serializer converts enums to int by default (can be one of Passed, Failed, Question, NoChange)
            public string errorMsg;         // Error message to display to user
            public string postOperation;    // javascript function to perform (use eval to run)
        }
        #endregion

        #region Private Data Types
        private class ValidationException : Exception
        {
            private string resultType;
            private string postOperation;

            public ValidationException(string resultType, string errorMsg, string postOperation) : base(errorMsg ?? string.Empty)
            {
                this.resultType     = resultType;
                this.postOperation  = postOperation;
            }

            public ValidationResult GetValidationResult()
            {
                return new ValidationResult() { resultType    = this.resultType, 
                                                errorMsg      = this.Message,
                                                postOperation = this.postOperation };
            }
        }
        #endregion

        #region Private Member Varaibles
        // Return types for ValidationResult
        private static readonly string ValidationResultType_Failed   = "Failed";    // state change failed 
        private static readonly string ValidationResultType_Question = "Question";  // Precondition needs user to answer a question
        private static readonly string ValidationResultType_NoChange = "NoChange";  // Request all ready at requested state
        private static readonly string ValidationResultType_Passed   = "Passed";    // state has been updated
        #endregion

        #region Public Methods
        /// <summary>
        /// Changes the request state by-passing usual icw
        ///     pre-condition validation
        ///     displaying order coms form
        ///     printing
        /// See file header for full implementation
        /// </summary>
        /// <param name="status">Status note to set</param>
        /// <param name="requestIDs">Request IDs to update</param>
        /// <param name="enable">Enable state</param>
        /// <param name="noteFieldToValue">Data to set in note type table</param>
        public static void SetStateQuickProcess(string status, IEnumerable<int> requestIDs, bool enable, IDictionary<string,string> noteFieldToValue)
        {
            List<int> lockedRows = new List<int>();

            // Load request status
            RequestStatus requestStatus = new RequestStatus();
            requestStatus.LoadStatusByRequestIDs(status, requestIDs);

            try
            {
                // Lock requests
                LockRequests(requestIDs, lockedRows);

                if (enable)
                {
                    // Get note type data
                    ICWTypeData? statusNote = ICWTypes.GetTypeByDescription(ICWType.Note, status);
                    if (statusNote == null)
                        throw new ApplicationException("Invalid note type '" + status + "'");

                    int    tableID_NoteType   = statusNote.Value.TableID.Value;
                    string tableName_NoteType = TableInfo.GetTableName(tableID_NoteType);

                    // Enable the status
                    EnableRequestStatus(status, statusNote.Value.ID, tableID_NoteType, tableName_NoteType, requestStatus, noteFieldToValue);
                }
                else
                    DisableRequestStatus(status, requestStatus);    // Disable state
            }
            finally
            {
                UnlockRows(lockedRows); // Unlock rows
            }
        }

        /// <summary>
        /// Changes request state using full ICW request state process.
        /// Should be called from client side using method SetStatusNoteState in file OCSProcessor.js rather than being called directly
        /// See file header for full implementation
        /// </summary>
        /// <param name="noteTypeID">Note type to update</param>
        /// <param name="requestTypeID">Request type for note</param>
        /// <param name="requestIDs">Request IDs to update</param>
        /// <param name="enable">Enable state</param>
        /// <param name="returnType">returnData type (sent from client method SetStatusNoteState)</param>
        /// <param name="returnData">data from client method SetStatusNoteState</param>
        /// <returns></returns>
        public static ValidationResult SetStateFullProcess(int noteTypeID, int requestTypeID, IEnumerable<int> requestIDs, bool enable, StatusNotesProcessor.ValidationReturnType returnType, string returnData)
        {
            StringBuilder postOperation = new StringBuilder();
            List<int> lockedRows = new List<int>();

            try
            {
                // Get status note being updated
                RequestTypeStatusNoteRow statusNote = RequestTypeStatusNote.GetByNoteTypeAndRequestType(noteTypeID, requestTypeID);
    
                // If status note has a precondition (and if not already done so) then check it
                if (!string.IsNullOrEmpty(statusNote.PreconditionRoutine) && returnType < ValidationReturnType.PreconditionResult)
                {
                    // Exec precondition check
                    //MetaDataRead metaDataRead = new MetaDataRead();
                    //string routine = metaDataRead.ConvertRoutineDescriptionToName(statusNote.PreconditionRoutine); XN 29May15 Precondition used to should be read from routine table
                    var routine = ascribe.pharmacy.icwdatalayer.Routine.GetByDescription(statusNote.PreconditionRoutine);
                    if (routine == null)
                    {
                        throw  new ApplicationException("Precondition routine '" + statusNote.PreconditionRoutine + "' missing from routine table");
                    }

                    List<SqlParameter> parameters = new List<SqlParameter>();
                    parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID));
                    parameters.Add(new SqlParameter("ItemIDList",       requestIDs.ToCSVString(",")));
                    parameters.Add(new SqlParameter("BaseType",         "Request"));
                    parameters.Add(new SqlParameter("StatusChange",     enable ? "Enable" : "Disable"));
                    string failedConditions = Database.ExecuteScalar<string>(routine.Name, parameters);

                    if (!string.IsNullOrEmpty(failedConditions))
                    {
                        if (statusNote.StopOnError && failedConditions.StartsWith("ERROR:"))
                        {
                            // Precondition failed so error
                            string errorMsg = statusNote.NoteType_Description + "\r\n\r\n" + failedConditions.Replace("ERROR:", string.Empty);
                            throw new ValidationException(ValidationResultType_Failed, errorMsg.JavaStringEscape(), null);
                        }
                        else
                        {
                            // Need to check with user so return and ask question (if user confirms will return to this method)
                            postOperation.AppendFormat("NotePreConditionConfirm('{0}')", failedConditions.JavaStringEscape());
                            throw new ValidationException(ValidationResultType_Question, null, postOperation.ToString());
                        }
                    }
                }

                // Lock requests
                LockRequests(requestIDs, lockedRows);

                // Load the reuqest status information (for this note type)
                RequestStatus requestStatus = new RequestStatus();
                requestStatus.LoadStatusByRequestIDs(statusNote.NoteType_Description, requestIDs);

                // Check items are not different state
                if (requestStatus.GroupBy(r => r.GetStatus(statusNote.NoteType_Description)).Count() > 1)
                        throw new ValidationException(ValidationResultType_Failed, "Selected item(s) are at different states.", null);

                // Check items are not at different states
                if (requestStatus.First().GetStatus(statusNote.NoteType_Description) == enable && !statusNote.AllowDuplicates)
                        throw new ValidationException(ValidationResultType_NoChange, string.Format("Item(s) selected have already been marked as '{0}', so they have been left unchanged.", enable ? statusNote.ApplyVerb : statusNote.DeactivateVerb), null);

                // If status note has a form then display
                Dictionary<string,string> noteFieldToValue = new Dictionary<string,string>();
                if (enable && statusNote.HasForm)
                {
                    // If not shown form yet the return and display
                    if (returnType < ValidationReturnType.NoteTypeData)
                    {
                        postOperation.AppendFormat("GetNoteData({0}, '{1}')", SessionInfo.SessionID, statusNote.TableName);
                        throw new ValidationException(ValidationResultType_Question, null, postOperation.ToString());
                    }

                    // From has been shown so extract data
                    XElement noteData = XElement.Parse(returnData);
                    foreach (var noteDataAttr in noteData.Descendants("attribute"))
                        noteFieldToValue.Add(noteDataAttr.Attribute("name").Value, noteDataAttr.Attribute("value").Value);
                }

                // Update status note
                if (enable)
                    EnableRequestStatus(statusNote.NoteType_Description, statusNote.NoteTypeID, statusNote.TableID, statusNote.TableName, requestStatus, noteFieldToValue);
                else
                    DisableRequestStatus(statusNote.NoteType_Description, requestStatus);

                // If enabling then perform print
                if (enable)
                {
                    postOperation.AppendLine("{");
                    postOperation.Append("var strXML = \"<printitems>");
                    foreach (var requestStatusRow in requestStatus)
                        postOperation.AppendFormat("<item tableid='{0}' dbid='{1}' requesttypeid='{2}' responsetypeid='' notetypeid='{3}' />", requestStatusRow.TableID, requestStatusRow.RequestID, requestStatusRow.RequestTypeID, statusNote.NoteTypeID);
                    postOperation.AppendLine("</printitems>\";");
                    postOperation.AppendFormat("ICWWindow().document.frames['fraPrintProcessor'].PrintItems({0}, strXML, 4, false, '');", SessionInfo.SessionID);
                    postOperation.AppendLine("}");
                    throw new ValidationException(ValidationResultType_Passed, null, postOperation.ToString());
                }
            }
            catch (ValidationException ex)
            {
                return ex.GetValidationResult();    // Does not mean it has failed as may return to client side for more info
            }
            catch (Exception ex)
            {
                return new ValidationResult() { resultType = ValidationResultType_Failed, errorMsg=ex.Message.JavaStringEscape() };
            }
            finally
            {
                UnlockRows(lockedRows);
            }

            // All okay and nothing more to do
            return new ValidationResult() { resultType = ValidationResultType_Passed, errorMsg=null, postOperation=null };
        }
        #endregion

        #region Private Methods
        /// <summary>
        /// Enable request state, updates 
        ///     Insert lines to AttachedNote and Note
        ///     Links request via RequestLinkAttachedNote
        ///     Updates RequestStatus
        /// </summary>
        /// <param name="status">State to update</param>
        /// <param name="noteTypeID">Note type for state</param>
        /// <param name="tableID_noteType">note type table (inherited from AttachNote)</param>
        /// <param name="tableName_noteType">name of note type table</param>
        /// <param name="requestStatus">Request status row that holds the request</param>
        /// <param name="noteFieldToValue">Data to set in note type table</param>
        private static void EnableRequestStatus(string status, int noteTypeID, int tableID_noteType, string tableName_noteType, RequestStatus requestStatus, IDictionary<string, string> noteFieldToValue)
        {
            BaseTable2<AttachedNoteRow, AttachedNoteColumnInfo> note = null;
            DateTime now = DateTime.Now;

            // Create note type table (as can vary between notes needs to be created dynamically)
            if (tableName_noteType == "AttachedNote")
                note = new BaseTable2<AttachedNoteRow, AttachedNoteColumnInfo>("AttachedNote", "Note"); // note type does not have own table
            else
                note = new BaseTable2<AttachedNoteRow, AttachedNoteColumnInfo>(tableName_noteType, "AttachedNote", "Note");

            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                // Create status note for request
                foreach (int requestID in requestStatus.Select(r => r.RequestID))
                {
                    // Create the attached note
                    AttachedNoteRow noteRow = note.Add();
                    noteRow.Enabled         = true;
                    noteRow.NoteTypeID      = noteTypeID;
                    noteRow.TableID         = tableID_noteType;
                    noteRow.EntityID        = SessionInfo.EntityID;
                    noteRow.NoteID_Thread   = 0;
                    noteRow.Description     = status;
                    noteRow.CreatedDate     = now;

                    // Set fields from attach note form
                    if (noteFieldToValue != null)
                    {
                        foreach (var noteField in noteFieldToValue)
                        {
                            if (!note.Table.Columns.Contains(noteField.Key))    // Check attach note table has all correct fields (from form)
                                throw new ApplicationException(string.Format("Missing column [{0}] from notetype table [{1}]", noteField.Key, tableName_noteType));

                            // Set the data type after conversion (18Jan13 XN)
                            Type columnType = note.Table.Columns[noteField.Key].DataType;
                            switch (columnType.Name.ToLower())
                            {
                            case "boolean": noteRow.RawRow[noteField.Key] = BoolExtensions.PharmacyParse(noteField.Value);   break;
                            default       : noteRow.RawRow[noteField.Key] = Convert.ChangeType(noteField.Value, columnType); break;
                            }
                        }
                    }

                    // Save now to get noteID
                    note.Save();

                    // Create link to request
                    Database.InsertLink("RequestLinkAttachedNote", "RequestID", requestID, "NoteID", noteRow.NoteID);

                    // Update the status
                    RequestStatusRow requestStatusRow = requestStatus.FindByRequestID(requestID);
                    requestStatusRow.SetStatusNoteID     (status, noteRow.NoteID     );
                    requestStatusRow.SetStatusEntityID   (status, noteRow.EntityID   );
                    requestStatusRow.SetStatusCreatedDate(status, noteRow.CreatedDate);
                }
                requestStatus.Save();

                trans.Commit();
            }
        }

        /// <summary>
        /// Clears request state, updates 
        ///     Insert line to CancellationNote (and hence Note)
        ///     Links note to cancelation note via CancellationNoteLinkNote
        ///     Clears AttachedNote.Enabled
        ///     Clears RequestStatus
        /// </summary>
        /// <param name="status">State to update</param>
        /// <param name="requestStatus">Request status row that holds the request</param>
        private static void DisableRequestStatus(string status, RequestStatus requestStatus)
        {
            ICWTypeData? statusNoteType       = ICWTypes.GetTypeByDescription(ICWType.Note, status);
            ICWTypeData? cancellationNoteType = ICWTypes.GetTypeByDescription(ICWType.Note, "Cancellation Note");
            CancellationNote cancelNotes = new CancellationNote();
            DateTime now = DateTime.Now;

            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                foreach (int requestID in requestStatus.Select(r => r.RequestID))
                {
                    RequestStatusRow requestStatusRow = requestStatus.FindByRequestID(requestID);
                    int? originalNoteID = requestStatusRow.GetStatusNoteID(status);

                    if (originalNoteID == null && statusNoteType != null)
                    {
                        // If RequestStatus does not contain the last note ID (can happen) then check AttachNote
                        // This should be a rare occurance, just a saftey check  (18Jan13 XN)
                        AttachedNote a = new AttachedNote(); 
                        a.LoadByNoteTypeIDRequestIDsAndEnabled(statusNoteType.Value.ID, new [] {requestID});
                        originalNoteID = a.Select(i => (int?)i.NoteID).FirstOrDefault();
                    }

                    if (cancellationNoteType.HasValue && originalNoteID.HasValue)
                    {
                        // Create cancellation note
                        CancellationNoteRow cancelNote = cancelNotes.Add();
                        cancelNote.CreatedDate              = now;
                        cancelNote.Description              = "Cancellation Note";
                        cancelNote.DiscontinuationReasonID  = null;
                        cancelNote.EntityID                 = SessionInfo.EntityID;
                        cancelNotes.Save();     // Save to get note ID

                        // Create the link to original note
                        int cancelationNoteID = cancelNote.NoteID;
                        Database.InsertLink("CancellationNoteLinkNote", "NoteID", cancelationNoteID, "NoteID_Cancelled", originalNoteID.Value);
                    }

                    // Clear original note
                    if (originalNoteID.HasValue)
                        Database.ExecuteSQLNonQuery("UPDATE AttachedNote SET [Enabled]=0 WHERE NoteID={0}", originalNoteID);

                    // And update status
                    requestStatusRow.SetStatusNoteID     (status, null);
                    requestStatusRow.SetStatusEntityID   (status, null);
                    requestStatusRow.SetStatusCreatedDate(status, null);
                }
                requestStatus.Save();

                trans.Commit();
            }
        }

        /// <summary>Uses ICW method of locking rows</summary>
        /// <param name="requestIDs">Request IDs to lock</param>
        /// <param name="lockedRows">List of rows that were locked</param>
        private static void LockRequests(IEnumerable<int> requestIDs, List<int> lockedRows)
        {
            RequestLock requestLock = new RequestLock();
            foreach (int requestId in requestIDs)
            {
                string result = requestLock.LockRequest(SessionInfo.SessionID, requestId, false);
                if (!string.IsNullOrEmpty(result))
                    throw new ValidationException(ValidationResultType_Failed, "Request is locked by different terminal.", null);

                lockedRows.Add(requestId);
            }
        }

        /// <summary>Unlock all row locked with method LockRows</summary>
        private static void UnlockRows(IEnumerable<int> lockedRequestIDs)
        {
            RequestLock requestLock = new RequestLock();
		    foreach (int requestId in lockedRequestIDs)
            {
                try
                {
			        requestLock.UnlockMyRequestLock(SessionInfo.SessionID, requestId);
                }
                catch (Exception)  { }
            }
        }
        #endregion
    }
}
