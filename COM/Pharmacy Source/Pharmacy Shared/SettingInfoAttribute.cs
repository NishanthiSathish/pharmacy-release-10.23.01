//===========================================================================
//
//							SettingInfoAttribute.cs
//
//	Class used to define attributes, that can then be used by the 
//  SettingsController to populate properties with values from Settings table.
//  The attribute will only work on properties.
//
//  Usage:
//  Create .NET class with properties that are given the following attribute tag
//
//  internal class LockResultsSettings
//  {
//    [SettingInfo(System = "Pharmacy", Section = "Locking", Key = "LockResultsRetries", Default = "5")]
//    public int LockResultsRetries { get; set; }
//
//    [SettingInfo(System = "Pharmacy", Section = "Locking", Key = "LockResultsRetryInterval", Default = "500")]
//    public int LockResultsRetryInterval { get; set; }
//  }
//
//  Then use SettingsController to load the settings
//
//  LockResultsSettings settings = new LockResultsSettings(); 
//  SettingsController.Load<LockResultsSettings>(settings);
//      
//	Modification History:
//	19Jan09 XN  Written
//  29May09 XN  Moved from Base Data Layer to Pharmacy Shared
//===========================================================================
using System;

namespace ascribe.pharmacy.shared
{
    [AttributeUsage(AttributeTargets.Property)] 
    public class SettingInfoAttribute : Attribute
    {
        /// <summary>System value (can be blank)</summary>
        public string System        { get; set; }

        /// <summary>Section value (can be blank)</summary>
        public string Section       { get; set; }

        /// <summary>Setting key name</summary>
        public string Key           { get; set; }

        /// <summary>Default value for setting</summary>
        public string Default       { get; set; }

        /// <summary>Description of setting supplied in constructor (can be blank)</summary>
        public string Description   { get; set; }
    }
}
