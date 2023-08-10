//===========================================================================
//
//					    PharmacyEIEIntegrationService.cs
//
//  Web service called by the EIE Pharmacy Integration Reply Component, to pass 
//  messages received by the EIE to the pharmacy web for decoding and processing 
//
//	Modification History:
//	03Oct13 XN  74592 Upgrade of Pharamcy to .NET4 means robot loader does 
//                    not work with the EIE which is still .NET2
//                    Fixed by moving the robot loader reply component to the web site
//===========================================================================
using System;
using System.Web.Services;
using ascribe.interfaces.replycomponents.robotloaderreplycomponent;
using ascribe.interfaces.replycomponents.pecosreplycomponent;

using ascribe.pharmacy.shared;

/// <summary>
/// Summary description for PharmacyEIEIntegrationService
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class PharmacyEIEIntegrationService : System.Web.Services.WebService 
{
    /// <summary>
    /// Called by the EIE Pharmacy Integration Reply Component.
    /// Called when it receives a message.
    /// Will process the message and set the replyText, returns false if error occured processing the message
    /// 
    /// The method uses the following setting
    /// System:  PharmacyReplyComponent
    /// Section: {instanceName}
    /// Key:     ReplyComponentType
    /// To determine which module to load to process the message current supported values are
    /// RobotLoading - Loads the RobotLoader reply component to process the message
    /// </summary>
    /// <param name="sessionId">Session ID</param>
    /// <param name="instanceName">Instance name</param>
    /// <param name="debugMode">If in debug mode</param>
    /// <param name="interfaceComponentId">Interface component Id</param>
    /// <param name="messageID">Message ID</param>
    /// <param name="messageText">Message text</param>
    /// <param name="replyText">Message reply text</param>
    /// <returns>If errors are created when processing the message</returns>
    [WebMethod]
    public bool GenerateReply(int sessionId, string instanceName, bool debugMode, int interfaceComponentId, Guid messageID, string messageText, out string replyText) 
    {
        SessionInfo.InitialiseSession(sessionId);
        bool messageErrored = false;

        replyText = null;

        string componentType = SettingsController.Load("PharmacyReplyComponent", instanceName, "ReplyComponentType", string.Empty);
        switch (componentType.ToLower())
        {
        case "robotloading": 
            RobotLoading replyComponent = new RobotLoading(sessionId, instanceName, debugMode, interfaceComponentId);
            if (messageID != Guid.Empty)
                replyText = replyComponent.GenerateReply(messageID, messageText);
            messageErrored = replyComponent.HasMessageErrored;
            break;
        case "pecos":
            PECOS pecos = new PECOS();
            if (messageID != Guid.Empty)
                replyText = pecos.ProcessMessage(sessionId, messageID, messageText, instanceName, interfaceComponentId);
            messageErrored = pecos.HasMessageErrored;
            break;
        default:
            throw new ApplicationException(string.Format("Invalid PharmacyReplyComponent type '{0}' (set via setting System: PharmacyReplyComponent Section: {1} Key: PharmacyReplyComponentType)", componentType, instanceName));
        }

        return messageErrored;
    }
}
