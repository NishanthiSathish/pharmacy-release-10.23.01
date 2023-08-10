//===========================================================================
//
//					    RobotSettings.cs
//
//  Provides an easy way to access the MechDisp settings from WConfiguration.
//
//  Currently the settings will be cached to the session cache.
//  Not sure if this is the best place, request cache seems too short, and 
//  long term cache makes it difficult to pick up the changes.
//  Session cache not so good for site with large number of users
//
//  Usage:
//  var robotLocation = "ROB";
//  var screenChar = RobotSetting.GetByLocationCode(robotLocation)FindItemScreenChar.    
//      
//	Modification History:
//	15Aug13 XN  Written 24653
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Represnets settings for a single robot</summary>
    public class RobotSetting
    {
        #region Public Properties
        /// <summary>WConfiguration section the robot is in</summary>
        public int SectionIndex { get; private set; }

        /// <summary>Drug location code for the robot</summary>
        public string LocationCode { get; private set; }

        /// <summary>Charcater displayed on screens to indicate the items is a robot item</summary>
        public string FindItemScreenChar { get; private set; }
        #endregion

        #region Public Static Methods
        /// <summary>
        /// Returns the robot settings for robot at give Section index (normal index start at 1)
        /// Else returns null
        /// </summary>
        public static RobotSetting GetBySectionIndex(int sectionIndex)
        {
            return GetSettings().FirstOrDefault(r => r.SectionIndex == sectionIndex);
        }

        /// <summary>Returns robot settings for robot at given location, else returns null</summary>
        public static RobotSetting GetByLocationCode(string code)
        {
            return GetSettings().FirstOrDefault(r => r.LocationCode.EqualsNoCaseTrimEnd(code));
        }

        /// <summary>Returns all robot settings for the site</summary>
        public static IEnumerable<RobotSetting> GetSettings()
        {
            string cacheName = "Pharmacy.RobotSettings." + SessionInfo.SiteID.ToString();

            List<RobotSetting> settings = PharmacyDataCache.GetFromSession(cacheName) as List<RobotSetting>;
            if (settings == null)
            {
                settings = new List<RobotSetting>();

                WConfiguration config = new WConfiguration();
                config.LoadBySiteAndCategory(SessionInfo.SiteID, "D|MechDisp");

                int totalSections = FindSetting<int>(config, string.Empty, "Total", 0);

                for(int sectionIndex = 1; sectionIndex <= totalSections; sectionIndex++)
                {
                    string sectionIndexStr = sectionIndex.ToString();
                    RobotSetting robotInfo = new RobotSetting();
                    robotInfo.SectionIndex        = sectionIndex;
                    robotInfo.LocationCode        = FindSetting(config, sectionIndexStr, "LocationCode",       string.Empty);
                    robotInfo.FindItemScreenChar  = FindSetting(config, sectionIndexStr, "FindItemScreenChar", string.Empty);
                    
                    settings.Add(robotInfo);
                }
                
                PharmacyDataCache.SaveToSession(cacheName, settings);
            }

            return settings;
        }
        #endregion

        #region Private Methods
        private static T FindSetting<T>(IEnumerable<WConfigurationRow> sectionRows, string section, string key, T defaultValue)
        {
            WConfigurationRow row = sectionRows.FirstOrDefault(r => r.Section.EqualsNoCaseTrimEnd(section) && r.Key.EqualsNoCaseTrimEnd(key));
            
            T result = defaultValue;
            if (row != null)
            {
                // Fail sliently as might break too much for one little config error
                try
                {
                    result = ConvertExtensions.ChangeType<T>(row.Value);
                }
                catch (Exception) { }
            }

            return result;
        }
        #endregion
    }
}
