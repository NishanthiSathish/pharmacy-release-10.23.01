//===========================================================================
//
//					                    Utils.cs
//
//  Dispensing PMR Utils class
//
//	Modification History:
//  15Nov12 XN  TFS47487 Replace to improve speed of old DispensingPMR
//  17Jan13 XN  46269 Add DispensingPMRViewSettings.StatusNotes
//  21Jan13 XN  53875 Remvoe StatusNotes as always need all request status fields
//  28Feb13 XN  37264 Added PSO column
//  07Mar13 XN  58256 Update Utils.RemoveNewLinesAndXMLEscape so adds space between dispensing instructinos text
//  22Mar13 XN  43495 Added EnableEMMRestrictions
//  19Jun13 XN  66246 Added SelectEpisode to fix issues for selecting episodes
//  18Jul13 XN  60657 Ensured JSON convert of DispensingPMRViewSettings.ViewMode is to a string rather than int
//                    Added DispensingPMRViewSettings.AllowMultiSelect setting
//  11Sep13 XN  72983 Added eMMAllowsPrescribing
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace ascribe.pharmacy.dispensingpmrlayer
{
    /// <summary>Dispensing PMR mode (Current or History)</summary>
    public enum DispensingPMRViewMode
    {
        Current,
        History
    }

    /// <summary>
    /// Dispensing PMR row type
    /// NOTE: Renaming or removing any types in this enum will need to be reflected in the DispensingPMR.js
    /// as the structure is passed to and from the clinet using JSON
    /// </summary>
    public enum DispensingPMRRowType
    {
        Prescription,
        PN,
        Merged,
        Dispensing
    }

    /// <summary>
    /// Used to hold view settings like (mode, if repeat dispensing
    /// NOTE: Renaming or removing any fields in structure will need to be reflected in the 
    /// DispensingPMR.js as the structure is passed to and from the clinet using JSON
    /// </summary>
    public struct DispensingPMRViewSettings
    {
        /// <summary>View mode (current or history)</summary>
        [JsonConverter(typeof(StringEnumConverter))]    // 60657 18Jul13 XN When convert to JSON string ensure if converts as string rather than int
        public DispensingPMRViewMode ViewMode;

        /// <summary>Repeat dispensing mode</summary>
        public bool RepeatDispensing;
        
        /// <summary>PSO mode</summary>
        public bool PSO;

        /// <summary>If enabling emm Restrictions</summary>
        public bool EnableEMMRestrictions;
        
        /// <summary>If user is allowed to prescribed based on setting EnableEMMRestrictions and if on EMM ward</summary>
        public bool eMMAllowsPrescribing;

        /// <summary>Prescription routine</summary>
        public string PrescriptionRoutine;

        /// <summary>If selecting a row in the PMR cause episode select event to fire (normaly used for multiple entity select) 66246 19Jun13 XN</summary>
        public bool SelectEpisode;

        /// <summary>If multi select is allowed for the desktop (basically if SelectEpisode is enabled the multi select is disabled) 60657 25Jul13 XN</summary>
        public bool AllowMultiSelect;
    }

    internal static class Utils
    {
        /// <summary>Removes cr, lf, form-feed, and record sep (0x1e) also XML escapes string</summary>
        public static string RemoveNewLinesAndXMLEscape(this string val)
        {
            StringBuilder str = new StringBuilder(val);
            str.Replace("\n",   string.Empty);  // line-feed (next line)
//            str.Replace("\r",   string.Empty);  XN 7Mar13 58256 no space between dispensing instructinos on different lines.
            str.Replace("\r",   " ");           // carriage-return 
            str.Replace("\f",   string.Empty);  // form-feed
            str.Replace("\x1E", string.Empty);  // record separator

            string returnVal = str.ToString().TrimEnd();
            return (returnVal == string.Empty) ? "&nbsp;" : returnVal.XMLEscape(false);
        }
    }
}
