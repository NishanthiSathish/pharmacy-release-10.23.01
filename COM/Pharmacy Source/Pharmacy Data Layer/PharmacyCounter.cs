//===========================================================================
//
//					    PharmacyCounter.cs
//
//  Provides access to a PharmacyCounter table. 
//
//  Each cunter is broken down into site, system, section, and category
//  the class will handle getting the next count value, and incrementing 
//  the value and updating the database as needed.
//
//  The counter can be reset, on a daily bases, or on a sepcific date via the 
//  ResetType database fiels.
//
//  It is also possible to format the number returned to contain data information
//  as a pre of post fix to main count.
//  If FormatString is '{DateTime:yyMMdd}{Count:000}' count will be prefixed with the 
/// date, and then the count value filling the last 3 digits e.g. 100118010
//  If FormatString is '{Count:000}{DateTime:yyMMdd}' count will be prefixed with the 
/// date, and then the count value filling the last 3 digits e.g. 10100118
//  Date formating will be standard .NET date-time formatting values
//  Leave this db field blank if count value should not contain a string.
//
//  Only supports reading, and updating
//
//  Usage:
//  PharmacyCounter.GetNextCount(24, "RobotLoading", "Loading", "Number");
//
//	Modification History:
//	18Jan10 XN  Written (F0074142)
//  19Jan12 AJK Moved to Pharmacy Shared
//  02Aug16 XN  159413 GetNextCountStr added YearChar converter
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Defines how the counter is reset</summary>
    public enum PharmacyCounterResetType
    {
        None,
        Daily,
        ByDate
    };

    /// <summary>Represents a row in the PharmacyCounter table</summary>
    public class PharmacyCounterRow : BaseRow
    {
        public int PharmacyCounterID 
        { 
            get { return FieldToInt(RawRow["PharmacyCounterID"]).Value; }
        }

        public int SiteID 
        { 
            get { return FieldToInt(RawRow["SiteID"]).Value; }
            set { RawRow["SiteID"] = IntToField(value);      }
        }

        public string System 
        { 
            get { return FieldToStr(RawRow["System"]);  }
            set { RawRow["System"] = StrToField(value); }
        }

        public string Section 
        { 
            get { return FieldToStr(RawRow["Section"]);  }
            set { RawRow["Section"] = StrToField(value); }
        }

        public string Key 
        { 
            get { return FieldToStr(RawRow["Key"]);  }
            set { RawRow["Key"] = StrToField(value); }
        }

        /// <summary>Value of the last count</summary>
        public int LastCount 
        { 
            get { return FieldToInt(RawRow["LastCount"]).Value; }
            set { RawRow["LastCount"] = IntToField(value);      }
        }

        /// <summary>
        /// Format string used for the number (see header)
        /// Leave blank for normal count value
        /// </summary>
        public string FormatString
        { 
            get { return FieldToStr(RawRow["FormatString"]);  }
            set { RawRow["FormatString"] = StrToField(value); }
        }

        /// <summary>Date time the count was last updated</summary>
        public DateTime UpdateDateTime 
        { 
            get { return FieldToDateTime(RawRow["UpdateDateTime"]).Value; }
            set { RawRow["UpdateDateTime"] = DateTimeToField(value);      }
        }

        /// <summary>How the count is to be reset if at all</summary>
        public PharmacyCounterResetType? ResetType 
        { 
            get { return FieldStrToEnum<PharmacyCounterResetType>(RawRow["ResetType"], true) ?? PharmacyCounterResetType.None; }
            set { RawRow["ResetType"] = EnumToFieldStr(value);                                                                 }
        }

        /// <summary>If ResetType isByDate then defines the data and time the count is to be reset (else null)</summary>
        public DateTime? ResetDateTime
        {
            get { return FieldToDateTime(RawRow["ResetDateTime"]);  }
            set { RawRow["ResetDateTime"] = DateTimeToField(value); }
        }
    }
    
    /// <summary>Provides column information about the PharmacyCounter table</summary>
    public class PharmacyCounterColumnInfo : BaseColumnInfo
    {
        public PharmacyCounterColumnInfo() : base("PharmacyCounter") { }
    }

    /// <summary>Represent the PharmacyCounter table</summary>
    public class PharmacyCounter : BaseTable<PharmacyCounterRow, PharmacyCounterColumnInfo>
    {
        public PharmacyCounter(RowLocking rowLocking) : base("PharmacyCounter", "PharmacyCounterID", rowLocking) 
        {
            UpdateSP = "pPharmacyCounterUpdate";
            IncludeSessionLockInUpdate = true;
            IncludeSessionLockInInsert = true;
        }

        /// <summary>Loads in a pharmacy count by site, system, section, and key</summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="system">System</param>
        /// <param name="section">Section</param>
        /// <param name="key">Key</param>
        public void LoadBySiteSystemSetionAndKey(int siteID, string system, string section, string key)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "SiteID",     siteID);
            AddInputParam(parameters, "System",     system);
            AddInputParam(parameters, "Section",    section);
            AddInputParam(parameters, "Key",        key);
            LoadRecordSetStream("pPharmacyCounterBySiteSystemSetionAndKey", parameters);
        }

        /// <summary>
        /// Get the next count value
        /// Will fromat the count using the value from database
        /// After the method is called will also have updated the count value in the database.
        /// Method call should not be used in transaction (if possible) as uses pharmacy row locking
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="system">System</param>
        /// <param name="section">Section</param>
        /// <param name="key">Key</param>
        /// <returns>Next count value</returns>
        public static int GetNextCount(int siteID, string system, string section, string key)
        {
            string count = GetNextCountStr(siteID, system, section, key);
            int result;
            if (!int.TryParse(count, out result))
                throw new ApplicationException(string.Format("PharmacyCounter {0}.{1}.{2} for site {3} must be a integer value", system, section, key, Site2.GetSiteNumberByID(siteID)));
            return result;
        }

        /// <summary>
        /// Get the next count value
        /// Will fromat the count using the value from database
        /// After the method is called will also have updated the count value in the database.
        /// Method call should not be used in transaction (if possible) as uses pharmacy row locking
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="system">System</param>
        /// <param name="section">Section</param>
        /// <param name="key">Key</param>
        /// <returns>Next count value</returns>
        public static string GetNextCountStr(int siteID, string system, string section, string key)
        {
            PharmacyCounterRow counter;
            DateTime now = DateTime.Now;
            DateTime updateDateTime;
            DateTime resetDateTime;
            int nextCount = 1;

            // Update the count
            using (PharmacyCounter counters = new PharmacyCounter(RowLocking.Enabled))
            {
                // Get the count from the database
                counters.LoadBySiteSystemSetionAndKey(siteID, system, section, key);
                if (!counters.Any())
                    throw new ApplicationException(string.Format("Missing pharmacy counter for Site={0} System={1} Section={2} Key={3}", siteID, system, section, key));
                counter = counters[0];

                // Update the count
                nextCount = counter.LastCount + 1;

                // Determine if the count needs to be rest
                switch (counter.ResetType)
                {
                case PharmacyCounterResetType.Daily:
                    // If past midnight, and count was last updated before midnight then reset
                    updateDateTime = counter.UpdateDateTime;
                    if ((updateDateTime.Year != now.Year) || (updateDateTime.Month != now.Month) || (updateDateTime.Day != now.Day))
                        nextCount = 1;
                    break;

                case PharmacyCounterResetType.ByDate:
                    // If past date, and count last updated after date then reset
                    if (counter.ResetDateTime.HasValue)
                    {
                        resetDateTime = counter.ResetDateTime.Value;
                        updateDateTime = counter.UpdateDateTime;
                        if ((updateDateTime < resetDateTime) && (now >= resetDateTime))
                            nextCount = 1;
                    }
                    break;
                }

                // Saved updated value
                counter.UpdateDateTime = now;
                counter.LastCount = nextCount;
                counters.Save();
            }

            // Get the format string (default to xxxxxx)
            string str = counter.FormatString;
            if (string.IsNullOrEmpty(str))
                str = counter.LastCount.ToString("000000");

            // Build up parameter for format string
            List<object> parameters = new List<object>();
            if (str.Contains("DateTime"))
            {
                str = str.Replace("DateTime", parameters.Count.ToString());
                parameters.Add(now);
            }
            if (str.Contains("Count"))
            {
                str = str.Replace("Count", parameters.Count.ToString());
                parameters.Add(counter.LastCount);
            }
            if (str.Contains("YearChar"))   // 02Aug16 XN 159413 Added for AMM
            {
                str = str.Replace("YearChar", parameters.Count.ToString());
                if (now.Year <= 2025)
                    parameters.Add((char)(now.Year - 2000 + 65));   // 2000="A" [65], 2025="Z" [90]
                else if (now.Year <= 2051)
                    parameters.Add((char)(now.Year - 2026 + 97));   // 2026="a" [97], 2051="z" [122]
                else if (now.Year <= 2061)
                    parameters.Add((char)(now.Year - 2052 + 48));   // 2052="0" [48], 2061="9" [57]
            }

            // Format
            if (parameters.Any())
                str = string.Format(str, parameters.ToArray());

            return str;
        }
    }
}
