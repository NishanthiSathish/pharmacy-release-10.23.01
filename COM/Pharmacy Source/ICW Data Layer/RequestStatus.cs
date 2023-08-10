// -----------------------------------------------------------------------
// <copyright file="RequestStatus.cs" company="Ascribe">
//  Provides access to RequestStatus table, normally just returning the
//      RequestStatusID
//      RequestID
//      RequestType__RequestTypeID
//      Request__TableID
//      and single status item (status, note ID, created date, and entity ID)
//
//  Supports updating, reading.
//
// Modification History:
// 26Nov12 XN  Written
// 17Jan13 XN  Add method LoadSpecificColumnsByRequestIDs 46269
// 29May15 XN  Added LoadRequestDataForOCS, and GetRequestXMLDataForOCS
// 28Nov16 XN  Knock on effects to change in BaseTable2.WriteToAudtiLog 147104
// </copyright>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.icwdatalayer
{
    using System;
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using System.Linq;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>RequestStatus row</summary>
    public class RequestStatusRow : BaseRow
    {
        public int RequestStatusID
        {
            get { return FieldToInt(RawRow["RequestStatusID"]).Value; }
            set { RawRow["RequestStatusID"] = IntToField(value);      }
        }

        public int RequestID
        {
            get { return FieldToInt(RawRow["RequestID"]).Value; }
            set { RawRow["RequestID"] = IntToField(value);      }
        }

        public int RequestTypeID
        {
            get { return FieldToInt(RawRow["RequestType__RequestTypeID"]).Value; }
            set { RawRow["RequestType__RequestTypeID"] = IntToField(value);      }
        }

        public int TableID
        {
            get { return FieldToInt(RawRow["Request__TableID"]).Value; }
            set { RawRow["Request__TableID"] = IntToField(value);      }
        }

        /// <summary>Get a RequestStatus state</summary>
        public bool GetStatus(string status)
        {
            return FieldToBoolean(RawRow[status]).Value;
        }
        /// <summary>Set a RequestStatus state</summary>
        public void SetStatus(string status, bool enabled)
        {
            RawRow[status] = BooleanToField(enabled);
        }

        /// <summary>Get a RequestStatus state note ID</summary>
        public int? GetStatusNoteID(string status)
        {
            return FieldToInt(RawRow[status.Replace(' ', '_') + "__NoteID"]);
        }
        /// <summary>Set a RequestStatus state note ID</summary>
        public void SetStatusNoteID(string status, int? noteID)
        {
            RawRow[status.Replace(' ', '_') + "__NoteID"] = IntToField(noteID);
        }

        /// <summary>Get a RequestStatus state entity ID</summary>
        public int? GetStatusEntityID(string status)
        {
            return FieldToInt(RawRow[status.Replace(' ', '_') + "__EntityID"]);
        }
        /// <summary>Set a RequestStatus state entity ID</summary>
        public void SetStatusEntityID(string status, int? entityID)
        {
            RawRow[status.Replace(' ', '_') + "__EntityID"] = IntToField(entityID);
        }

        /// <summary>Get a RequestStatus state created date</summary>
        public DateTime? GetStatusCreatedDate(string status)
        {
            return FieldToDateTime(RawRow[status.Replace(' ', '_') + "__CreatedDate"]);
        }
        /// <summary>Set a RequestStatus state created date</summary>
        public void SetStatusCreatedDate(string status, DateTime? createdDate)
        {
            RawRow[status.Replace(' ', '_') + "__CreatedDate"] = DateTimeToField(createdDate);
        }
    }

    /// <summary>RequestStatus column info</summary>
    public class RequestStatusColumnInfo : BaseColumnInfo
    {
        public RequestStatusColumnInfo() : base("RequestStatus") { }
    }

    /// <summary>RequestStatus table</summary>
    public class RequestStatus : BaseTable2<RequestStatusRow, RequestStatusColumnInfo>
    {
        public RequestStatus() : base("RequestStatus") 
        {
            //this.writeToAudtiLog = false;  28Nov16 XN Knock on effects to change in BaseTable2.WriteToAudtiLog 147104 // ICW does not seem to log this table
            this.WriteToAudtiLog = false;   // ICW does not seem to log this table
        }

        /// <summary>Loads all specified RequestStatus's (but only loads 1 specific state)</summary>
        /// <param name="status">State to load link 'Request Cancellation', 'PNAuthorise'</param>
        /// <param name="requestIDs">List of request to load</param>
        public void LoadStatusByRequestIDs(string status, IEnumerable<int> requestIDs)
        {
            LoadBySQL("SELECT RequestStatusID, RequestID, Request__TableID, RequestType__RequestTypeID, [{0}], [{1}__NoteID], [{1}__EntityID], [{1}__CreatedDate] FROM RequestStatus (NOLOCK) WHERE RequestID in ({2})", 
                                status, 
                                status.Replace(' ', '_'),   
                                requestIDs.ToCSVString(","));
        }

        /// <summary>
        /// Loads all specified RequestStatus's (but only the columns passed in (best to always include RequestID)
        /// This may mean that some RequestStatusRow properties may not work unless you specififcally include them in the column list
        /// 17Jan13 XN 46269
        /// </summary>
        /// <param name="requestStatusColumns">List of colums to pass in (will add [] if needed)</param>
        /// <param name="requestIDs">List of request to load</param>
        public void LoadSpecificColumnsByRequestIDs(IEnumerable<string> requestStatusColumns, IEnumerable<int> requestIDs)
        {
            string requestStatusColumnsStr = requestStatusColumns.Select(s => (s[0] == '[') ? s : "[" + s + "]").ToCSVString(",");
            string requestIDsStr           = requestIDs.ToCSVString(",");
            LoadBySQL("SELECT {0} FROM RequestStatus (NOLOCK) WHERE RequestID in ({1})", requestStatusColumnsStr, requestIDsStr);
        }

        /// <summary>Returns a RequestStatus row by request ID (from the current loaded set)</summary>
        /// <param name="requestID">Request ID to get</param>
        /// <returns>RequestStatus row by request ID</returns>
        public RequestStatusRow FindByRequestID(int requestID)
        {
            return this.FirstOrDefault(r => r.RequestID == requestID);
        }

        /// <summary>Loads request status data that is need to pass to ICW OCSAction (see GetRequestXmlDataForOcs)</summary>
        /// <param name="requestId">Request ID</param>
        private void LoadRequestDataForOcs(int requestId)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("RequestID",        requestId);
            this.LoadBySP("pPharmacyGetRequestDataForOCS", parameters);            
        }

        /// <summary>
        /// Should not call this method directly instead use js method GetOCSActionDataForRequest
        /// Returns an xml string that contains Order Comms info, this can be passed to (js method) OCSAction 
        /// and provides info on the request's
        ///     type
        ///     If can stop or amend
        ///     motality
        ///     Cancellation
        ///     if complete
        ///     if expired
        /// data is returned in the form
        ///     {root}
        ///         {item class='request' dbid... tableid... description='' detail='' RequestTypeID... productid='0' autocommit='1', CanStopOrAmend... Motal... Cancelled... FullyResulted... Responses... Expired... />
        ///         {RequestType RequestTypeID... Description... Orderable.. ManualResponse='' />
        ///     {/root}
        /// </summary>
        /// <param name="requestId">Request id</param>
        /// <returns>xml string to be passed to OCSAction</returns>
        public static string GetRequestXMLDataForOCS(int requestId)
        {
            RequestStatus rs = new RequestStatus();
            rs.LoadRequestDataForOcs(requestId);

            RequestStatusRow row = rs.First();
            return
                string.Format(
                    "<root>" + 
                    "<item class='request' dbid='{0}' tableid='{1}' description=''  detail='' RequestTypeID='{2}' productid='0' autocommit='1' CanStopOrAmend='{3}' Mortal='{4}' Cancelled='{5}' FullyResulted='{6}' Responses='{7}' Expired='{8}' RequestType='{9}' />" +
                    "<RequestType RequestTypeID='{2}' Description='{9}' Orderable='1' ManualResponse='' />" + 
                    "</root>",
                                requestId,
                                row.TableID,
                                row.RequestTypeID,
                                row.GetStatus("CanStopOrAmend").ToOneZeorString(),
                                row.GetStatus("Mortal").ToOneZeorString(),
                                row.GetStatus("Request Cancellation").ToOneZeorString(),
                                row.GetStatus("Complete").ToOneZeorString(),
                                row.GetStatus("Responses").ToOneZeorString(),
                                row.GetStatus("Expired").ToOneZeorString(),
                                row.RawRow["RequestType__Description"]);
        }
    }
}
