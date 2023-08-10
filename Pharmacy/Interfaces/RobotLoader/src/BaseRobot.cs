//===========================================================================
//
//							        BaseRobot.cs
//
//  Handled base robot interface class.
//  When initalised will load in all the message templates from the 
//  RobotLoadingMsgTemplate table into the decoder object
//
//	Modification History:
//	16Dec09 XN  Written
//  02Oct13 XN  74592 Upgrade of Pharamcy to .NET4 means robot loader does
//              not work with the EIE which is still .NET2
//              Fixed by moving the robot loader reply component to the web site
//===========================================================================
using System;
using System.Linq;
using ascribe.pharmacy.robotloading;
using ascribe.pharmacy.icwdatalayer;
//using ascribeplc.interfaces.common.EIELogger;
//using ascribeplc.interfaces.common.messagecomponent;

namespace ascribe.interfaces.replycomponents.robotloaderreplycomponent
{
    /// <summary>Interface base robot class</summary>
    internal abstract class BaseRobot
    {
        #region Member Variables
        /// <summary>Name of the robot</summary>
        protected string robotName;

        /// <summary>Robot decoder class</summary>
        protected HL7Decoder decoder = new HL7Decoder();

        /// <summary>Interface engine log</summary>
        protected EIELogger log;

        /// <summary>Interface engine config class</summary>
        protected Config config;
        #endregion

        #region Public Methods
		/// <summary>
        /// Constructor
        /// </summary>
        /// <param name="robotName">Name of the robot (must match name in RobotLoadingMsgTemplate table)</param>
        /// <param name="log">Interface engine log</param>
        /// <param name="config">Interface engine config class</param>
        public BaseRobot(string robotName, EIELogger log, Config config)
        {
            this.robotName = robotName;
            this.log       = log;
            this.config    = config;
        }

        /// <summary>Initalises the robot interface</summary>
        public virtual void Initalise()
        {
            // Loads the robot
            RobotLoaderMsgTemplate msgTemplate = new RobotLoaderMsgTemplate();
            msgTemplate.LoadByRobotName(robotName);

            // Check get enough data
            if (!msgTemplate.Any())
            {
                string msg = string.Format("No message templated defined for in table {0} for robot {1}", msgTemplate.TableName, robotName);
                throw new ApplicationException(msg);
            }

            // Check there is only one received header
            if (msgTemplate.Count(t => t.MessageType == RobotLoaderMsgType.ReceivedHeader) == 0)
            {
                string msg = string.Format("Need a received header message in table {0} for robot {1}", msgTemplate.TableName, robotName);
                throw new ApplicationException();
            }
            if (msgTemplate.Count(t => t.MessageType == RobotLoaderMsgType.ReceivedHeader) != 1)
            {
                string msg = string.Format("Only allowed 1 received header message in table {0} for robot {1}", msgTemplate.TableName, robotName);
                throw new ApplicationException();
            }

            // Check there is only one reply header
            if (msgTemplate.Count(t => t.MessageType == RobotLoaderMsgType.ReplyHeader) == 0)
            {
                string msg = string.Format("Need a received header message in table {0} for robot {1}", msgTemplate.TableName, robotName);
                throw new ApplicationException();
            }
            if (msgTemplate.Count(t => t.MessageType == RobotLoaderMsgType.ReplyHeader) != 1)
            {
                string msg = string.Format("Only allowed 1 received header message in table {0} for robot {1}", msgTemplate.TableName, robotName);
                throw new ApplicationException();
            }

            // Read in received header template
            RobotLoaderMsgTemplateRow receivedHeader = msgTemplate.First(t => t.MessageType == RobotLoaderMsgType.ReceivedHeader);
            this.decoder.SetReceiverHeaderTemplate(receivedHeader.MessageTemplate);

            // Read in received message template
            foreach(RobotLoaderMsgTemplateRow row in msgTemplate.Where(t => t.MessageType == RobotLoaderMsgType.Received))
                this.decoder.AddReceiverTemplate(row.Name, row.MessageTemplate);

            // Read in reply header template
            RobotLoaderMsgTemplateRow replyHeader = msgTemplate.First(t => t.MessageType == RobotLoaderMsgType.ReplyHeader);
            this.decoder.SetReplyHeaderTemplate(replyHeader.MessageTemplate);

            // Read in reply message template
            foreach(RobotLoaderMsgTemplateRow row in msgTemplate.Where(t => t.MessageType == RobotLoaderMsgType.Reply))
                this.decoder.AddReplyTemplate(row.Name, row.MessageTemplate);
        }

        /// <summary>
        /// Overridden in derived classes to reply to a message
        /// </summary>
        /// <param name="messageID">Message ID</param>
        /// <param name="messageText">Message</param>
        /// <returns>Reply message</returns>
        public abstract string GenerateReply(Guid messageID, string messageText); 
	    #endregion    
    }
}
