using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
//using ascribeplc.interfaces.common.settingcomponent;
using ascribe.pharmacy.shared;

namespace ascribe.interfaces.replycomponents.robotloaderreplycomponent
{
    /// <summary>
    /// Holds the configuration settings
    /// </summary>
    public class Config
    {
        #region Constants
        private const string SYSTEM_NAME = "PharmacyReplyComponent";

        /// <summary>Robot name setting key name</summary>
        private const string ROBOT_NAME_KEY = "RobotName";

        /// <summary>Robot site setting key name</summary>
        private const string ROBOT_SITE_KEY = "SiteNumber";

        /// <summary>Robot location setting key name</summary>
        private const string ROBOT_LOCATION = "Location";

        /// <summary>If to test if any db rows are locked when ask for drug input right</summary>
        private const string ROBOT_TEST_DB_LOCK_ON_ASK = "TestDBLockOnAsk";
        #endregion

        #region Constructor
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="sessionId">Session ID</param>
        /// <param name="instancename">Name of interface instance code is running in</param>
        /// <param name="debugMode">If in debug mode</param>
        /// <param name="interfaceComponentId">Interface component ID</param>
        public Config(int sessionId,
                      string instancename,
                      bool debugMode,
                      int interfaceComponentId)
        {
            DebugMode = debugMode;
            SessionID = sessionId;
            InstanceName = instancename;
            InterfaceComponentId = interfaceComponentId;
        } 
        #endregion

        #region Public Properties
        public bool     DebugMode               { get; private set; }
        public string   InstanceName            { get; private set; }
        public int      SessionID               { get; private set; }
        public int      InterfaceComponentId    { get; private set; }

        public string   RobotName               { get { return SettingsController.LoadAndCache<string>(SYSTEM_NAME, InstanceName, ROBOT_NAME_KEY,           string.Empty);    } }
        public string   Location                { get { return SettingsController.LoadAndCache<string>(SYSTEM_NAME, InstanceName, ROBOT_LOCATION,           string.Empty);    } }
        public bool     TestDBLockOnAsk         { get { return SettingsController.LoadAndCache<bool>  (SYSTEM_NAME, InstanceName, ROBOT_TEST_DB_LOCK_ON_ASK,true);            } }

        public int SiteNumber
        { 
            get 
            {   
                int robotSiteKey = SettingsController.LoadAndCache<int>(SYSTEM_NAME, InstanceName, ROBOT_SITE_KEY, -1);
                if (robotSiteKey == -1)
                    throw new ApplicationException(string.Format("Invalid site number Setting: system {0} section {1} key {2})", SYSTEM_NAME, InstanceName, ROBOT_SITE_KEY));
                return robotSiteKey;
            } 
        }
        #endregion
    }
}