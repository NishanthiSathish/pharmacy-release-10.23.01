//===========================================================================
//
//							        PNLog.cs
//
//  Provides access to PNLog table.
//
//  There are also a number of helper function on for creating the log entries.
//
//  PNLog table holds the PN data log.
//
//  There are also helper methods to manage adding DataSet's and DataRow to to the log
//  CompareDataRow
//  AddDataRow
//
//  Usage
//  PNLog.WriteToLog(siteID, null, null, null, null, "Writing to log", string.Empty);
//  or
//  PNLog.WriteToLog(siteID, "Writing to log");
//
//	Modification History:
//	20Oct11 XN Written
//  15May12 XN TFS32067 Update for DSS on Web
//  26Oct15 XN Added extra space in so reads better 106278
//  28Nov16 XN Knock on effects to change in BaseTable2.WriteToAudtiLog 147104
//===========================================================================
using System;
using System.Data;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using System.Collections.Generic;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    /// <summary>Represents a row in the PNLog table</summary>
    public class PNLogRow : BaseRow
    {
	    public int PNLogID { get { return FieldToInt(RawRow["PNLogID"]).Value; } }

        public DateTime Occurred 
        { 
            get { return FieldToDateTime(RawRow["Occurred"]).Value; } 
            set { RawRow["Occurred"] = DateTimeToField(value);      }
        }

        public string UserInitials
        { 
            get { return FieldToStr(RawRow["UserInitials"], false, string.Empty); } 
            set { RawRow["UserInitials"] = StrToField(value, false);              }
        }

        public int EntityID_User
        { 
            get { return FieldToInt(RawRow["EntityID_User"]).Value; } 
            set { RawRow["EntityID_User"] = IntToField(value);      }
        }

        public string TerminalName
        { 
            get { return FieldToStr(RawRow["TerminalName"], false, string.Empty); } 
            set { RawRow["TerminalName"] = StrToField(value, false);              }
        }

        public int? SiteNumber
        { 
            get { return FieldToInt(RawRow["SiteNumber"]);   } 
            set { RawRow["SiteNumber"] = IntToField(value);  }
        }

        public int? LocationID_Site
        { 
            get { return FieldToInt(RawRow["LocationID_Site"]);   } 
            set { RawRow["LocationID_Site"] = IntToField(value);  }
        }

        public int? EntityID_Patient
        { 
            get { return FieldToInt(RawRow["EntityID_Patient"]);   } 
            set { RawRow["EntityID_Patient"] = IntToField(value);  }
        }

        public int? EpisodeID
        { 
            get { return FieldToInt(RawRow["EpisodeID"]);   } 
            set { RawRow["EpisodeID"] = IntToField(value);  }
        }

        public int? PNProductID
        { 
            get { return FieldToInt(RawRow["PNProductID"]);   } 
            set { RawRow["PNProductID"] = IntToField(value);  }
        }

        public int? PNRuleID
        { 
            get { return FieldToInt(RawRow["PNRuleID"]);   } 
            set { RawRow["PNRuleID"] = IntToField(value);  }
        }

        public int? RequestID_Regimen
        { 
            get { return FieldToInt(RawRow["RequestID_Regimen"]);   } 
            set { RawRow["RequestID_Regimen"] = IntToField(value);  }
        }

        public string Description
        { 
            get { return FieldToStr(RawRow["Description"], false, string.Empty); } 
            set { RawRow["Description"] = StrToField(value, false);              }
        }

        public string StackTrace
        { 
            get { return FieldToStr(RawRow["StackTrace"], false, string.Empty); } 
            set { RawRow["StackTrace"] = StrToField(value, false);              }
        }
    }

    /// <summary>Provides column information about the PNLog table</summary>
    public class PNLogColumnInfo : BaseColumnInfo
    {
        public PNLogColumnInfo() : base("PNLog") { }

        public int UserInitialsLength { get { return tableInfo.GetFieldLength("UserInitials"); } }
        public int TerminalNameLength { get { return tableInfo.GetFieldLength("TerminalName");   } }
    }

    /// <summary>Represent the PNLog table</summary>
    public class PNLog : BaseTable2<PNLogRow, PNLogColumnInfo>
    {
        public PNLog() : base("PNLog") 
        { 
            //this.writeToAudtiLog = false;  28Nov16 XN Knock on effects to change in BaseTable2.WriteToAudtiLog 147104
            this.WriteToAudtiLog = false;
        }

        /// <summary>Write a PN log entry to the database (saved directly to the db)</summary>
        /// <param name="LocationID_Site">Site event occured on</param>
        /// <param name="EntityID_Patient">Patient the log event is linked to</param>
        /// <param name="EpisodeID">Patient episode log event is linked to</param>
        /// <param name="PNProductID">PN product log event is linked to</param>
        /// <param name="PNRuleID">PN rule event is linked to</param>
        /// <param name="RequestID_Regimen">PN regimen request ID</param>
        /// <param name="Description">log description</param>
        /// <param name="StackTrace">Stack trace for the log</param>
        public static void WriteToLog (int? LocationID_Site, int? EntityID_Patient, int? EpisodeID, int? PNProductID, int? PNRuleID, int? RequestID_Regimen, string Description, string StackTrace)
        {
            PNLog log = new PNLog();

            PNLogRow newRow = log.Add();
            newRow.Occurred        = DateTime.Now;
            newRow.UserInitials    = SessionInfo.UserInitials.SafeSubstring(0, PNLog.GetColumnInfo().UserInitialsLength);
            newRow.EntityID_User   = SessionInfo.EntityID;
            newRow.TerminalName    = SessionInfo.Terminal.SafeSubstring(0, PNLog.GetColumnInfo().TerminalNameLength);
            newRow.SiteNumber      = LocationID_Site.HasValue ? (int?)Sites.GetNumberBySiteID(LocationID_Site.Value) : null;
            newRow.LocationID_Site = LocationID_Site;
            newRow.EntityID_Patient= EntityID_Patient;
            newRow.EpisodeID       = EpisodeID;
            newRow.PNProductID     = PNProductID;
            newRow.PNRuleID        = PNRuleID;
            newRow.RequestID_Regimen=RequestID_Regimen;

            newRow.Description     = Description;
            newRow.StackTrace      = StackTrace;

            log.Save();
        }
        public static void WriteToLog(int? LocationID_Site, string Description)
        {
            WriteToLog (LocationID_Site, null, null, null, null, null, Description, string.Empty);
        }
            
        /// <summary>
        /// Adds all changes between all DB values of two DataRows to a string
        /// Changes are recorded as 
        /// Following changes made to '{object name}'
        ///     where {PK column name} = {PK value}
        ///     {column name}: from '{original}.{column value}' '{latest}.{column value}'
        /// </summary>
        /// <param name="log">Message the changes are to be added to</param>
        /// <param name="original">original lDataRow object</param>
        /// <param name="latest">updated DataRow object</param>
        /// <param name="logNoDifference">Logs if there are no difference between the items</param>
        public static void CompareDataRow(StringBuilder log, DataRow original, DataRow latest)
        {
            CompareDataRow(log, original, latest, true);
        }
        public static void CompareDataRow(StringBuilder log, DataRow original, DataRow latest, bool logNoDifference)
        {
            DataColumnCollection columns = original.Table.Columns;
            int startPos = log.Length;

            // Iterate through all properties (that related to a db field)
            foreach (DataColumn c in columns)
            {
                if (original.Table.Columns.Contains(c.ColumnName) && latest.Table.Columns.Contains(c.ColumnName))   // TFS32067 15May12 XN Update for DSS on Web
                {
                    object originalVal = original[c.ColumnName];
                    object latestVal   = latest[c.ColumnName];
                    string originalStr = (originalVal == null) || (originalVal == DBNull.Value) ? "null" : string.Format("'{0}'", originalVal);
                    string latestStr   = (latestVal   == null) || (latestVal   == DBNull.Value) ? "null" : string.Format("'{0}'", latestVal);

                    // If value has been modified then add it to the message
                    if (originalStr != latestStr)
                        log.AppendFormat("{0}: from {1} to {2}\r\n", c.ColumnName, originalStr, latestStr);
                }
            }

            // If any changes have been spotted then add header to the change message
            if (log.Length > startPos)
            {
                string prefix = "Following changes made to '" + original.Table.TableName + "'\r\n";
                if (original.Table.PrimaryKey.Count() == 1)
                {
                    string pkColName = original.Table.PrimaryKey[0].ColumnName;
                    prefix += "\twhere " + pkColName + "=" + original[pkColName] + " "; // 26Oct15 XN Added extra space in so reads better 106278
                }

                log.Insert(startPos, prefix);
            }
            else if (logNoDifference)
                log.AppendFormat("No changes detected to '{0}'\r\n", original.Table.TableName);
        }

        /// <summary>
        /// Adds all changes between all DB values of two DataRow's to a string
        /// </summary>
        /// <param name="log">Message the changes are to be added to</param>
        /// <param name="original">original DataRows</param>
        /// <param name="latest">updated DataRows</param>
        public static void CompareDataRows(StringBuilder log, IEnumerable<DataRow> original, IEnumerable<DataRow> latest)
        {
            int count        = Math.Max(original.Count(), latest.Count());
            int logStartSize = log.Length;

            for (int c = 0; c < count; c++)
            {
                if (original.Count() <= c)
                    PNLog.AddDataRow(log, "Added item", latest.ElementAt(c));
                else if (latest.Count() <= c)
                    PNLog.AddDataRow(log, "Removed item", original.ElementAt(c));
                else
                    PNLog.CompareDataRow(log, original.ElementAt(c), latest.ElementAt(c), false);
            }

            if (logStartSize == log.Length)
                log.Append("No changes detected.");
        }

        /// <summary>
        /// Adds all values from a DataRow to log
        /// The message format will be
        /// {header}
        ///     {column name}: {obj}.{column value}
        /// </summary>
        /// <param name="log">Message the values will be added to</param>
        /// <param name="header">Header message</param>
        /// <param name="obj">DataRow object to add to the log</param>
        public static void AddDataRow(StringBuilder log, string header, DataRow obj)
        {
            // Add header to message
            log.AppendLine (header);

            // Add each column value to message
            foreach (DataColumn c in obj.Table.Columns)
            {
                object objVal = obj[c];
                string obStr  = (objVal == null) || (objVal == DBNull.Value) ? "null" : string.Format("'{0}'", objVal);
                log.Append     (c.ColumnName);
                log.Append     (": ");
                log.Append     (obStr);
                log.AppendLine ();
            }
        }
    }
}
