// -----------------------------------------------------------------------
// <copyright file="OCSProcessor.asmx.cs" company="Ascribe">
//  Web service used to perform order comms processes like 
//      set request status notes
//      get OCS action data
//  used with javacsript file OCSProcessor.js
//
// Modification History:
// 26Nov12 XN  Written
// 28May15 XN  Converted to more general purpose OCSProcessor added GetOCSActionDataForRequest
// 23May16 XN  39882 Added SaveCanelOrderToState 
// </copyright>
// -----------------------------------------------------------------------
using System.Web.Services;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.shared;

/// <summary>
/// Summary description for (from previous call to this message)
/// </summary>
[WebService(Namespace = "http://ascribe.com/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[System.Web.Script.Services.ScriptService]
public class OCSProcessor : System.Web.Services.WebService
{
    /// <summary>
    /// Set a request's status notes directly in DB
    /// See StatusNotesProcessor.cs for full details
    /// Don't call this method directly instead use the method in OCSProcessor.js
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="noteTypeID">Note type ID</param>
    /// <param name="requestTypeID">Request Type ID</param>
    /// <param name="requestIDs">List of request to set</param>
    /// <param name="enable">If note is enabled or disabled</param>
    /// <param name="returnType">Return type for message asked to user (from previous call to this message)</param>
    /// <param name="returnData">Return data from message asked to user (from previous call to this message)</param>
    /// <returns>Operation to be performed</returns>
    [WebMethod]
    public StatusNotesProcessor.ValidationResult SetStatusNoteState(int sessionID, int noteTypeID, int requestTypeID, int[] requestIDs, bool enable, StatusNotesProcessor.ValidationReturnType returnType, string returnData)
    {
        SessionInfo.InitialiseSession(sessionID);
        return StatusNotesProcessor.SetStateFullProcess(noteTypeID, requestTypeID, requestIDs, enable, returnType, returnData);
    }

    /// <summary>
    /// Gets the Order Comms XML data need to pass to OCSAction
    /// See RequestStatus.GetRequestXMLDataForOCS for full details
    /// Don't call this method directly instead use the method in OCSProcessor.js
    /// </summary>
    /// <param name="sessionId">session id</param>
    /// <param name="requestId">request id</param>
    /// <returns>Order comms XML data <see cref="string"/></returns>
    [WebMethod]
    public string GetOCSActionDataForRequest(int sessionId, int requestId)
    {
        SessionInfo.InitialiseSession(sessionId);
        return RequestStatus.GetRequestXMLDataForOCS(requestId);
    }

    /// <summary>Saves the entity and episode to the state table</summary>
    /// <param name="sessionId">Current session</param>
    /// <param name="entityId">Entity ID</param>
    /// <param name="episodeId">Episode ID</param>
    [WebMethod]
    public void SaveEpisodeToState(int sessionId, int entityId, int episodeId)
    {
        GENRTL10.State state = new GENRTL10.State();
        state.SetKey(sessionId, "Episode", episodeId);
        state.SetKey(sessionId, "Entity",  entityId);        
    }

    /// <summary>Will save OrderEntry/StopOrders, and OrderEntry/OrdersXML to state 23May16 XN 39882</summary>
    /// <param name="sessionId">Current session</param>
    /// <param name="requestId">RequestId to cancel</param>
    /// <param name="requestType">Type of request RequestType tale e.g. PNRegimen</param>
    [WebMethod]
    public void SaveCanelOrderToState(int sessionId, int requestId, string requestType)
    {
        SessionInfo.InitialiseSession(sessionId);

        ICWTypeData typeData = ICWTypes.GetTypeByDescription(ICWType.Request, requestType).Value;
        string ordersXML = string.Format("<cancel><item class=\"request\" id=\"{0}\" description=\"\" detail=\"\" tableid=\"{1}\" productid=\"0\" ocstype=\"request\" ocstypeid=\"{2}\" autocommit=\"1\" /></cancel>", requestId, typeData.TableID, typeData.ID);
        PharmacyDataCache.SaveToDBSession("OrderEntry/StopOrders", ordersXML);
        PharmacyDataCache.SaveToDBSession("OrderEntry/OrdersXML",  ordersXML);
    }
}