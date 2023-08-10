//===========================================================================
//
//							    WLookup.cs
//
//  Provides access to WLookup table (and functions for WLookupContext table)
//  
//  Lookups are sorted by site and context (read from WLookupContext table)
//  where a context can be warning, instruction, flabel.
//
//  The most important methods on the class are
//      To get the value of a lookup from code
//          GetWanring          - only in-use items
//          GetInstruction      - only in-use items
//          GetFinanceReason    - even if not in-use
//          GetFreeFormatLabel  - even if not in-use
//      Or to get a list of lookups for a site (will only list InUse=true items)
//          LoadBySiteAndContext
//
//  Warings and instructions require special handling as can be supplier by dss, or be lanuage specific.
//  The way the lookup is selected is as follow
//      First check for a local language specific version of the lookup (e.g. warning.061)
//      Next check for dss language specific version of the lookup (e.g. warning.061.dss)
//      Next check for dss UK version of the lookup (e.g. warning.044.dss)
//
//  As well as reading data from WLookup the class provides extra functions
//      WLookup.GetWLookupContextID - returns context ID from WLookupContext table
//      WLookup.IfExists            - If lookup code existing  (either site specific, dss country specific, or dss english)
//      WLookup.IfDSSExists         - If dss lookup code existing
//      WLookup.IsDSSMaintained     - returns if context is dss maintained
//      WLookup.GetLanguageCodes    - returns all lanugage codes support by a context (from WLookupContext)
//      WLookup.IsMulitLanguage     - if context supports multi language
//
//  Supports reading, updating, inserting, and deleting
//  Any changes will be written to the WPharmacyLog (under 'Reference Data Editors')
//
//  Usage
//  Load value for a warning
//  string value = WLookup.GetWarning(SessionInfo.SiteID, "10");
//
//  Load value for a free format labels (fflabels)
//  string value = WLookup.GetFreeFormatLabel(SessionInfo.SiteID, "FT");
// 
//  Load all warnings for site
//  WLookup lookup = new WLookup();
//  lookup.LoadBySiteAndContext(SessionInfo.SiteID, WLookupContextType.Warning);
//
//	Modification History:
//	19Dec13 XN  Written
//  28Apr14 XN  Major overhaul 88858
//  26Aug14 XN  limited Warnings limited to 3 lines
//  23Feb15 XN  Added WLookupRow.ToXMLHeap as removed from Report layer
//  01Jun16 XN  Updated ToXMLHeap to clear down unused StdLbl print elements 154372
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
using System.Data;
using System.Xml;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>WLookupContext type</summary>
    public enum WLookupContextType
    {
        Warning,
        Instruction,
        /// <summary>Drug Message Codes</summary>
        UserMsg,
        /// <summary>Financial reason codes</summary>
        Reason,
        /// <summary>Free Format Labels</summary>
        FFLabels,
    }

    /// <summary>WLookup row</summary>
    public class WLookupRow : BaseRow
    {
        public int WLookupID 
        { 
            get { return FieldToInt(this.RawRow["WLookupID"]).Value; }
        }

        public int WLookupContextID
        {
            get { return FieldToInt(this.RawRow["WLookupContextID"]).Value; }
            set { this.RawRow["WLookupContextID"] = IntToField(value);      }
        }

        public int SiteID
        {
            get { return FieldToInt(this.RawRow["SiteID"]).Value; }
            set { this.RawRow["SiteID"] = IntToField(value);      }
        }

        public string Code
        {
            get { return FieldToStr(this.RawRow["Code"], true); }
            set { this.RawRow["Code"] = StrToField(value);      }
        }

        /// <summary>
        /// Returns the value 
        /// Will replace EndOfLine char(30) with new line
        /// </summary>
        public string Value
        {
            get { return FieldToStr(this.RawRow["Value"], false, string.Empty).Replace("\x1E", "\r\n"); }    // Should not trim allows user to put in empty text, Replace EndOfLine char(30) with new line
            set { this.RawRow["Value"] = StrToField(value);                                            }
        }

        /// <summary>
        /// Strips the colour information from the value 
        /// e.g.        1!A Warning 2!2nd Lines 
        /// becomes     A Warning 2nd Lines
        /// Replaces vb6 function StripColourInfo
        /// </summary>
        public string ValueWithoutColourInfo()
        {
            StringBuilder value = new StringBuilder(this.Value);
            for (int c = 1; c < value.Length; c++)
            {
                if (value[c] == '!')
                    value.Remove(c - 1, 2);
            }            
            return value.ToString();
        }

        public bool InUse
        {
            get { return FieldToBoolean(RawRow["InUse"], true).Value; }
            set { RawRow["InUse"] = BooleanToField(value);            }
        }

        /// <summary>
        /// Creates XML heap for WLookup
        /// Implementation of PRNTCTRL.BAS printextralabel method
        /// The XML will be in the form
        ///     {Heap}
        ///         {StdLbl1A}
        ///         {StdLbl2A}
        ///         :
        ///     {/Heap}
        /// Each line of the WLookup.Value will be a different StdLbl item
        /// </summary>
        /// <returns>XML for lookup</returns>
        public string ToXMLHeap()
        {
            string[] value = this.Value.Split(new [] { "\r\n" }, StringSplitOptions.None);
            int c = 0;

            // Setup xml writer 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.Indent             = true;
            settings.NewLineOnAttributes= true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("Heap");
                for (c = 0; c < value.Length; c++)
                {
                    xmlWriter.WriteAttributeString(string.Format("StdLbl{0}A", c + 1), value[c].Replace("\n", string.Empty));
                }
                for (; c < 15; c++)
                {
                    xmlWriter.WriteAttributeString(string.Format("StdLbl{0}A", c + 1), string.Empty);   // 1Jun16 XN 154372 Added as moving printing to ascribe print job
                }
                xmlWriter.WriteEndElement();

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }
    }

    /// <summary>Column info for WLookup</summary>
    public class WLookupColumnInfo : BaseColumnInfo
    {
        public WLookupColumnInfo() : base("WLookup") { }

        private int CodeLength  { get { return base.FindColumnByName("Code" ).Length; } }
        private int ValueLength { get { return base.FindColumnByName("Value").Length; } }

        /// <summary>
        /// The allowed length for Code depends on context type
        ///     Warning     6 chars
        ///     Instruction 6 chars
        ///     UserMsg:    4 chars
        ///     FFLabels:   4 chars
        ///     Reason:     4 chars
        /// </summary>
        public int GetCodeLength(WLookupContextType wlookupContextType)
        {
            switch (wlookupContextType)
            {
            case WLookupContextType.Warning:     return 6;
            case WLookupContextType.Instruction: return 6;
            case WLookupContextType.UserMsg:     return 4;
            case WLookupContextType.FFLabels:    return 4;
            case WLookupContextType.Reason:      return 4;
            default: return CodeLength;
            }
        }

        /// <summary>
        /// The allowed length for Value depends on context type
        ///     Instructions 35 chars
        ///     Reason 30 chars
        ///     All others length of db value field (1024)
        /// </summary>
        public int GetValueLength(WLookupContextType wlookupContextType)
        {
            switch (wlookupContextType)
            {
            case WLookupContextType.Instruction: return 35;
            case WLookupContextType.Reason:      return 30;
            default: return ValueLength;
            }
        }

        /// <summary>
        /// Number of lines allowed in the value field specific context
        ///     Reason 1 line
        ///     Instructions 1 line
        ///     UserMsg int.Max lines
        ///     All others 10
        /// </summary>
        public int GetValueMaxNumberOfLines(WLookupContextType wlookupContextType)
        {
            switch (wlookupContextType)
            {
            case WLookupContextType.Reason:      return 1;
            case WLookupContextType.Instruction: return 1;
            case WLookupContextType.Warning:     return 3;  // 26Aug14 XN added on Mr Simmons request
            case WLookupContextType.UserMsg:     return int.MaxValue;
            default: return 10;
            }
        }
    }

    /// <summary>Provides access to the WLookup table</summary>
    public class WLookup : BaseTable2<WLookupRow, WLookupColumnInfo>
    {
        public WLookup() : base("WLookup") { }

        #region Useful Public Methods
        /// <summary>
        /// Returns the warning description for the code or null if not presnet (will load only inuse items)
        ///     First tires local language specific code (context warning.{language code})
        ///     Next tires dss language specific code (context warning.{language code}.dss)
        ///     Finally tires dss english code (context warning.044.dss)
        /// Replaces vb6 method SubPatMe.bas GetWarCode
        /// </summary>
        public static string GetWarning(int siteID, string code)
        {
            WLookup lookup = new WLookup();
            lookup.LoadByCodeSiteContextAndCountryCode(code, siteID, WLookupContextType.Warning, true, PharmacyCultureInfo.CountryCode);
            if (!lookup.Any())
                lookup.LoadByCodeSiteDSSContextAndCountryCode(code, siteID, WLookupContextType.Warning, true, PharmacyCultureInfo.CountryCode);
            if (!lookup.Any() && PharmacyCultureInfo.CountryCode != PharmacyCultureInfo.UKCountryCode)
                lookup.LoadByCodeSiteDSSContextAndCountryCode(code, siteID, WLookupContextType.Warning, true, PharmacyCultureInfo.UKCountryCode);

            return lookup.Any() ? lookup.First().Value : null;
        }

        /// <summary>
        /// Returns the instruction description for the code or null if not presnet (will load only inuse items)
        ///     First tires local language specific code (context instruction.{language code})
        ///     Next tires dss language specific code (context instruction.{language code}.dss)
        ///     Finally tires dss english code (context instruction.044.dss)
        /// Replaces vb6 method SubPatMe.bas GetInsCode
        /// </summary>
        public static string GetInstruction(int siteID, string code)
        {
            WLookup lookup = new WLookup();
            lookup.LoadByCodeSiteContextAndCountryCode(code, siteID, WLookupContextType.Instruction, true, PharmacyCultureInfo.CountryCode);
            if (!lookup.Any())
                lookup.LoadByCodeSiteDSSContextAndCountryCode(code, siteID, WLookupContextType.Instruction, true, PharmacyCultureInfo.CountryCode);
            if (!lookup.Any() && PharmacyCultureInfo.CountryCode != PharmacyCultureInfo.UKCountryCode)
                lookup.LoadByCodeSiteDSSContextAndCountryCode(code, siteID, WLookupContextType.Instruction, true, PharmacyCultureInfo.UKCountryCode);

            return lookup.Any() ? lookup.First().Value : null;
        }

        /// <summary>Returns Reason description for the code or null if not presnet (will load even if not inuse)</summary>
        public static string GetFinanceReason(int siteID, string code)
        {
            WLookup lookup = new WLookup();
            lookup.LoadByCodeSiteContextAndCountryCode(code, siteID, WLookupContextType.Reason);
            return lookup.Any() ? lookup.First().Value : null;
        }

        /// <summary>Returns FFLabel description for the code or null if not presnet (will load even if not inuse)</summary>
        public static string GetFreeFormatLabel(int siteID, string code)
        {
            WLookup lookup = new WLookup();
            lookup.LoadByCodeSiteContextAndCountryCode(code, siteID, WLookupContextType.FFLabels);
            return lookup.Any() ? lookup.First().Value : null;
        }

        /// <summary>
        /// Load all in-use warnings for a site
        ///     Will load site specific warnings
        ///     then dss country specific warnings (if dss maintained context)
        ///     the dss uk specific warnings (if dss multi language context)
        /// Replaces vb6 method SubPatMe.bas ListWarnings and ListInstructions
        /// </summary>
        public void LoadBySiteAndContext(int siteID, WLookupContextType contextType)
        {
            int countryCode = PharmacyCultureInfo.GetCountryCode(siteID);

            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteID",            siteID               );
            parameters.Add("WLookupContextID1", GetWLookupContextID(contextType, false, countryCode));

            if (WLookup.IsDSSMaintained(contextType))
                parameters.Add("WLookupContextID2", GetWLookupContextID(contextType, true, countryCode));
            else
                parameters.Add("WLookupContextID2", null);

            if (countryCode != PharmacyCultureInfo.UKCountryCode && WLookup.IsDSSMaintained(contextType) && WLookup.IsMulitLanguage(contextType))
                parameters.Add("WLookupContextID3", GetWLookupContextID(contextType, true, PharmacyCultureInfo.UKCountryCode));
            else
                parameters.Add("WLookupContextID3", null);

            LoadBySP("pWLookupBySiteAndContext", parameters);
        }
        #endregion

        #region Public Methods
        /// <summary>Loads in-use lookup for all sites, and context (for the specific country code) but for local site data (will not load dss site data)</summary>
        /// <param name="append">If data to be append to dataset</param>
        /// <param name="siteIDs">List of site IDs to load in</param>
        /// <param name="wlookupContextType">context</param>
        /// <param name="countryCode">Country code to load (or null if context does not support country code)</param>
        public void LoadBySitesContextAndCountryCode(bool append, IEnumerable<int> siteIDs, WLookupContextType wlookupContextType, int? countryCode = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",   SessionInfo.SessionID                                      );
            parameters.Add("SiteIDs",            siteIDs.ToCSVString(",")                                   );
            parameters.Add("WLookupContextID",   GetWLookupContextID(wlookupContextType, false, countryCode));
            parameters.Add("InUse",              true                                                       );            
            LoadBySP(append, "pWLookupBySiteIDsAndContext", parameters);
        }

        /// <summary>Loads in-use lookup for all sites, and context (for the specific country code) but for dss site data (will not load local site data)</summary>
        /// <param name="append">If data to be append to dataset</param>
        /// <param name="siteID">site to load in</param>
        /// <param name="wlookupContextType">context</param>
        /// <param name="countryCode">Country code to load (or null if context does not support country code)</param>
        public void LoadBySiteDSSContextAndCountryCode(bool append, int siteID, WLookupContextType wlookupContextType, int? countryCode = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",   SessionInfo.SessionID                                      );
            parameters.Add("SiteIDs",            siteID.ToString()                                          );
            parameters.Add("WLookupContextID",   GetWLookupContextID(wlookupContextType, true, countryCode) );
            parameters.Add("InUse",              true                                                       );            
            LoadBySP(append, "pWLookupBySiteIDsAndContext", parameters);
        }

        /// <summary>Loads a lookup by code, site, and context (for the specific country code) but for local site data (will not load dss site data)</summary>
        /// <param name="code">Code to load</param>
        /// <param name="siteID">site to load in</param>
        /// <param name="wlookupContextType">context</param>
        /// <param name="inUse">if true load inuse only, false load not inuse only, if null load inuse or not in use</param>
        /// <param name="countryCode">Country code to load (or null if context does not support country code)</param>
        public void LoadByCodeSiteContextAndCountryCode(string code, int siteID, WLookupContextType wlookupContextType, bool? inUse = null, int? countryCode = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("SiteID",           siteID               );
            parameters.Add("Code",             code                 );
            parameters.Add("WLookupContextID", GetWLookupContextID(wlookupContextType, false, countryCode) );
            parameters.Add("InUse",            inUse                 );
            LoadBySP("pWLookupByCodeSiteAndContext", parameters);
        }

        /// <summary>Loads a lookup by code, site, and context (for the specific country code) but for dss site data (will not load local site data)</summary>
        /// <param name="code">Code to load</param>
        /// <param name="siteID">site to load in</param>
        /// <param name="wlookupContextType">context</param>
        /// <param name="inUse">if true load inuse only, false load not inuse only, if null load inuse or not in use</param>
        /// <param name="countryCode">Country code to load (or null if context does not support country code)</param>
        public void LoadByCodeSiteDSSContextAndCountryCode(string code, int siteID, WLookupContextType wlookupContextType, bool? inUse = null, int? countryCode = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("SiteID",           siteID               );
            parameters.Add("Code",             code                 );
            parameters.Add("WLookupContextID", GetWLookupContextID(wlookupContextType, true, countryCode) );
            parameters.Add("InUse",            inUse                 );
            LoadBySP("pWLookupByCodeSiteAndContext", parameters);
        }

        /// <summary>Loads lookup by code, context (for the specific country code) for all sites, but for local site data (will not load dss site data)</summary>
        /// <param name="code">Code to load</param>
        /// <param name="wlookupContextType">context</param>
        /// <param name="inUse">if true load inuse only, false load not inuse only, if null load inuse or not in use</param>
        /// <param name="countryCode">Country code to load (or null if context does not support country code)</param>
        public void LoadByCodeContextAndCountryCode(string code, WLookupContextType wlookupContextType, bool? inUse = null, int? countryCode = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("Code",             code                 );
            parameters.Add("WLookupContextID", GetWLookupContextID(wlookupContextType, false, countryCode) );
            parameters.Add("InUse",            inUse                );
            LoadBySP("pWLookupByCodeAndContext", parameters);
        }

        /// <summary>Overriden to write changes to WPharmacyLog (under 'Reference Data Editors')</summary>
        public override void Save()
        {
            WPharmacyLog log = new WPharmacyLog();
            log.AddRange(this, WPharmacyLogType.ReferenceDataEditors, r => r.Code, r => r.SiteID);
            base.Save();
            log.Save();
        }
        #endregion

        #region Public Static Methods
        /// <summary>Returns the WLookupContextID (read from cached data)</summary>
        /// <param name="wlookupContextType">Context type</param>
        /// <param name="dss">if need dss context ID (only if context supports DSS context ID)</param>
        /// <param name="countryCode">if need country specific context ID (only if context supports difference languages)</param>
        /// <returns>Returns WLookupContextID or -1</returns>
        public static int GetWLookupContextID(WLookupContextType wlookupContextType, bool dss, int? countryCode = null)
        {
            // Build up context name
            StringBuilder wlookupContext = new StringBuilder(wlookupContextType.ToString().ToLower());

            // If context supports country code then add code to context name
            if (IsMulitLanguage(wlookupContextType))
                wlookupContext.AppendFormat(".{0:000}", countryCode ?? PharmacyCultureInfo.CountryCode);

            // If context supports dss version add to context name
            if (dss)
            {
                if (IsDSSMaintained(wlookupContextType))
                    wlookupContext.Append(".dss"); 
                else
                    throw new ApplicationException("Requested a dss context for a WLookupContext '" + wlookupContextType + "' that is not supported by DSS.");
            }

            // Get ID from cached list
            int wlookupContextID;
            if (!GetWLookupContextIDByDescription().TryGetValue(wlookupContext.ToString(), out wlookupContextID))
                wlookupContextID = -1;

            return wlookupContextID;
        }

        /// <summary>Returns if context is DSS maintained (has entry in WLookupContext that ends with '.dss')</summary>
        public static bool IsDSSMaintained(WLookupContextType wlookupContextType)
        {
            string contextStart = wlookupContextType.ToString().ToLower();
            return GetWLookupContextIDByDescription().Where(s => s.Key.StartsWith(contextStart)).Any(s => s.Key.EndsWith(".dss"));
        }

        /// <summary>
        /// Returns all language codes for the context in the db (will contain duplicates) 
        /// or empty list if context is not language dependant
        /// </summary>
        public static IEnumerable<int> GetLanguageCodes(WLookupContextType wlookupContextType)
        {
            string contextStart = wlookupContextType.ToString().ToLower();
            int result;

            foreach (var wlookupContext in GetWLookupContextIDByDescription().Keys)
            {
                if (wlookupContext.StartsWith(contextStart))
                {
                    foreach(var part in wlookupContext.Split(new [] { '.' }))
                    {
                        if (part.Length == 3 && int.TryParse(part, out result))
                            yield return result;
                    }
                }
            }
        }

        /// <summary>Returns if the context can support multiple languages (even if db only contains english)</summary>
        public static bool IsMulitLanguage(WLookupContextType wlookupContextType)
        {
            return GetLanguageCodes(wlookupContextType).Any();
        }

        /// <summary>Returns if the code exists in the WLookup table (either site specific, dss country specific, or dss english)</summary>
        public static bool IfExists(int siteID, string code, WLookupContextType wlookupContextType, int? countryCode = null)
        {
            List<int> wlookupContextID = new List<int>();
            wlookupContextID.Add(WLookup.GetWLookupContextID(wlookupContextType, false, countryCode ));   // site specific
            if (WLookup.IsDSSMaintained(wlookupContextType))
            {
                wlookupContextID.Add(WLookup.GetWLookupContextID(wlookupContextType, true,  countryCode                      ));   // dss country specific
                wlookupContextID.Add(WLookup.GetWLookupContextID(wlookupContextType, true,  PharmacyCultureInfo.UKCountryCode));   // dss english
            }
            return Database.ExecuteSQLScalar<int?>("SELECT TOP 1 1 FROM WLookup WHERE Code='{0}' AND SiteID={1} AND WLookupContextID in ({2})", code, siteID, wlookupContextID.Distinct().ToCSVString(",")).HasValue;
        }

        /// <summary>Returns if dss code exists in the WLookup table (is country specific)</summary>
        public static bool IfDSSExists(int siteID, string code, WLookupContextType wlookupContextType, int countryCode)
        {
            int wlookupContextID = WLookup.GetWLookupContextID(wlookupContextType, true, countryCode);
            return Database.ExecuteSQLScalar<int?>("SELECT TOP 1 1 FROM WLookup WHERE Code='{0}' AND SiteID={1} AND WLookupContextID={2}", code, siteID, wlookupContextID).HasValue;
        }
        #endregion

        #region Private Methods
        /// <summary>Gets dictionary of WLookupContext description (lower case), to WLookupContextID data is cached in long term memory</summary>
        private static IDictionary<string,int> GetWLookupContextIDByDescription()
        {
            string cachName = typeof(WLookup).FullName + ".GetWLookupContextIDByDescription";

            // Check if the data is cached
            IDictionary<string,int> wlookupContextToID = (IDictionary<string,int>)PharmacyDataCache.GetFromCache(cachName);
            if (wlookupContextToID == null)
            {
                // Read from WLookupContext
                GenericTable2 wlookupContextTbl = new GenericTable2("WLookupContext");
                wlookupContextTbl.LoadBySQL("SELECT WLookupContextID, Context FROM WLookupContext", new SqlParameter[0]);
                
                // convert to dictionary and save to cache
                wlookupContextToID = wlookupContextTbl.ToDictionary(v => v.RawRow["Context"].ToString().ToLower(), k => (int)k.RawRow["WLookupContextID"]);
                PharmacyDataCache.SaveToCache(cachName, wlookupContextToID);
            }

            return wlookupContextToID;
        }
        #endregion
    }
}
