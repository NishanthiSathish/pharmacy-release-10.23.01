﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace TextControlEditorPharmacyClient.Properties {
    
    
    [global::System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.VisualStudio.Editors.SettingsDesigner.SettingsSingleFileGenerator", "16.6.0.0")]
    internal sealed partial class Settings : global::System.Configuration.ApplicationSettingsBase {
        
        private static Settings defaultInstance = ((Settings)(global::System.Configuration.ApplicationSettingsBase.Synchronized(new Settings())));
        
        public static Settings Default {
            get {
                return defaultInstance;
            }
        }
        
        [global::System.Configuration.UserScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.DefaultSettingValueAttribute("950, 800")]
        public global::System.Drawing.Size LastWindowSize {
            get {
                return ((global::System.Drawing.Size)(this["LastWindowSize"]));
            }
            set {
                this["LastWindowSize"] = value;
            }
        }
        
        [global::System.Configuration.UserScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.DefaultSettingValueAttribute("50, 50")]
        public global::System.Drawing.Point LastWindowPos {
            get {
                return ((global::System.Drawing.Point)(this["LastWindowPos"]));
            }
            set {
                this["LastWindowPos"] = value;
            }
        }
        
        [global::System.Configuration.UserScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.DefaultSettingValueAttribute("Normal")]
        public global::System.Windows.Forms.FormWindowState LastWindowState {
            get {
                return ((global::System.Windows.Forms.FormWindowState)(this["LastWindowState"]));
            }
            set {
                this["LastWindowState"] = value;
            }
        }
        
        [global::System.Configuration.UserScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.DefaultSettingValueAttribute("10")]
        public int RecentFilesMaxItemCount {
            get {
                return ((int)(this["RecentFilesMaxItemCount"]));
            }
            set {
                this["RecentFilesMaxItemCount"] = value;
            }
        }
        
        //[global::System.Configuration.UserScopedSettingAttribute()]
        //[global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        //public global::System.Collections.Generic.List<TX_Text_Control_Words.UserInfo> KnownUsers {
        //    get {
        //        return ((global::System.Collections.Generic.List<TX_Text_Control_Words.UserInfo>)(this["KnownUsers"]));
        //    }
        //    set {
        //        this["KnownUsers"] = value;
        //    }
        //}
        
        [global::System.Configuration.UserScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        public global::System.Collections.Specialized.StringCollection RecentFiles {
            get {
                return ((global::System.Collections.Specialized.StringCollection)(this["RecentFiles"]));
            }
            set {
                this["RecentFiles"] = value;
            }
        }
    }
}
