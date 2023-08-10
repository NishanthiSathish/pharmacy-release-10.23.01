//===========================================================================
//
//							        RobotLoading.cs
//
//  This provides an interface engine reply component for Pharmacy RobotLoading 
//  The type of robot support by the interface is defined in Settings table under
//  System:  RobotLoaderReplyComponent
//  Section: <Interface Instance name>
//  Key:     RobotName
//  
//  There are also keys for defining site and location robot is associated with.
//
//  The robot will also require received, and reply, mesages templates from the 
//  RobotLoaderMsgTemplate table.
//
//	Modification History:
//	16Dec09 XN  Written
//  02Oct13 XN  74592 Upgrade of Pharamcy to .NET4 means robot loader does
//              not work with the EIE which is still .NET2
//              Fixed by moving the robot loader reply component to the web site
//===========================================================================
using System;
using ascribe.pharmacy.shared;
//using ascribeplc.interfaces.common.EIELogger;
//using ascribeplc.interfaces.common.messagecomponent;
//using ascribeplc.interfaces.common.tablecomponent;
using ascribe.pharmacy.icwdatalayer;

namespace ascribe.interfaces.replycomponents.robotloaderreplycomponent
{
    /// <summary>Interface engine reply component</summary>
    public class RobotLoading
    {
        #region Member variables
        private Config      _config;                    // Configuration info for UHB Sage Message Processor
        private int         _interfaceComponentId = -1; // Interface component ID
        private EIELogger   _log;                       // Interface engine EIELogger 
        private BaseRobot   _robot = null;              // Robot class used to process the message
        #endregion

        #region Constructor
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="sessionId">Session ID</param>
        /// <param name="instanceName">Interface engine instance name (set in config file)</param>
        /// <param name="debugMode">If interface engine is in debug mode (set in config file)</param>
        /// <param name="interfaceComponentId">Interface DB component ID</param>
        public RobotLoading(int sessionId,
                                string instanceName,
                                bool debugMode,
                                int interfaceComponentId)
        {
            _interfaceComponentId = interfaceComponentId;

            _log = new EIELogger(instanceName);

            _config = new Config(sessionId,
                                 instanceName,
                                 debugMode,
                                 interfaceComponentId);
        } 
        #endregion

        /// <summary>
        /// Called when need to send a message reply
        /// </summary>
        /// <param name="messageID">message ID</param>
        /// <param name="messageText">message</param>
        /// <returns>reply message</returns>
        public string GenerateReply(Guid messageID, string messageText)
        {
            // Initalise the pharmacy data layer session information
            SessionInfo.InitialiseSessionAndSiteNumber(_config.SessionID, _config.SiteNumber);

            //Message reply = null;
            string reply = null;
            try
            {
                // Load robot data
                if (_robot == null)
                    _robot = LoadRobot();

                // Process message and generate reply message
                reply = _robot.GenerateReply(messageID, messageText);

                //// Save the reply
                //reply.Save(_config.SessionID, _config.InterfaceComponentId, Message.MessageStatusKeys.Created);
            }
            catch (Exception ex)
            {
                // If error log to interface engine tables
                _log.LogError(_config.SessionID, _config.InterfaceComponentId, ex, 0, string.Empty, messageID);
            }

            return reply;
        }

        public bool HasMessageErrored
        {
            get { return _log.HasMessageErrored; }
        }

        /// <summary>Creates robot of correct type by looking up robot from Settings table</summary>
        /// <returns>Base robot type</returns>
        private BaseRobot LoadRobot()
        {
 	        BaseRobot robot = null;

            // Create robot of corret type
            string robotName = _config.RobotName.ToLower();
            if (robotName == RowaRobot.Name.ToLower())
                robot = new RowaRobot(_log, _config); 
            else
                throw new ApplicationException(string.Format("Invalid robot name {0}", _config.RobotName));

            // Initalises the robot
            robot.Initalise();

            return robot;
        }
    }
}
