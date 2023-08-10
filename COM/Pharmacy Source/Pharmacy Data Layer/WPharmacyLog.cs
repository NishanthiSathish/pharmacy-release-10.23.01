// --------------------------------------------------------------------------------------------------------------------
// <copyright company="Ascribe Ltd." file="WPharmacyLog.cs">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
//  Provides access to WPharmacyLog table.
//
//  SP for this object should return all fields from the WPharmacyLog table, and a 
//  links in the following extra fields
//      Person.Initials
//
//  WPharmacyLog table holds pharmacy log data that used to be in files like labutils.log, mediate.log, negative.log, gainloss.log
//
//  Only supports inserting, and reading
//
//  Usage
//  To automatically generate a log from a data set 
//  Notice sup is saved first so has pks updated, then save log which will automatically update it's DBIDs with PK values.
//      WSupplier2 sup = new WSupplier2();
//      sup.Add();
//      
//      WPharmacyLog log = new WPharmacyLog();
//      log.AddRange(sup, 
//                   "WSupplier2", 
//                   r => r.Code,
//                   r => r.SiteID);
//
//      sup.Save(); // Save sup first
//      log.Save(); // Save will now cause the DBIDs to the updated
//
//  Modification History:
//  15Nov13 XN  Written
//  09Jan14 XN  Added LoadByCriteria
//  26Apr14 XN  Added AddRange 88858
//  26Apr14 XN  Added AddRange 88858
//  28Apr14 XN  Updated AddRange
//  14Oct14 XN  When deleting add full details of row being deleted 43318
//  20Jan15 XN  Changed WPharmacyLog to have a WPharmacyLogTypeID rather than Description column to improve indexing 26734
//  08May15 XN  Update WPharmacyLogRow for changes in BaseRow (change field from static to instance for error handling improvements)
//  25Aug15 XN  In Add checks if there is a SessionInfo.SiteID 
//  14Apr16 XN  123082 Added items to WPharmacyLogType
//  28Nov16 XN  Knock on effects to change in BaseTable2.WriteToAudtiLog 147104
// </summary>
namespace ascribe.pharmacy.pharmacydatalayer
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Data.SqlClient;
    using System.Linq;
    using System.Text;

    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>Represents log types (from WPharmacyLogType table)</summary>
    [EnumViaDBLookup(TableName = "WPharmacyLogType", PKColumn = "WPharmacyLogTypeID", DescriptionColumn = "Description")]
    public enum WPharmacyLogType
    {
        /// <summary>Labutils log type used for editing product data</summary>
        LabUtils,

        /// <summary>Customer log type used for editing wards</summary>
        WCustomer,

        /// <summary>WSupplier2 log type used fro editing suppliers</summary>
        WSupplier2,

        /// <summary>WWardProductList log type used fro editing Ward Stock Lists</summary>
        WWardProductList,

        /// <summary>WWardProductList log type used fro editing Ward Stock Lists lines</summary>
        WWardProductListLines,

        [EnumDBDescription("Reference Data Editors")]
        ReferenceDataEditors,

        /// <summary>Errors from the pharmacy transport layer 25Aug15 XN</summary>
        PharmacyTransport,

        /// <summary>gainloss log type used for recording changes in the loss\gain changes 14Apr16 XN 123082</summary>
        GainLoss,

        /// <summary>Track when cost of product goes -ve 14Apr16 XN 123082</summary>
        Negative
    }

    /// <summary>Row in the WPharmacyLog</summary>
    public class WPharmacyLogRow : BaseRow
    {
        /// <summary>Gets DB field WPharmacyLogID</summary>
        public int WPharmacyLogID { get { return this.FieldToInt(this.RawRow["WPharmacyLogID"]).Value; } }

        /// <summary>
        /// Gets or sets DB field WPharmacyLogType
        /// If the type does not exists in the db it will be automatically added
        /// </summary>
        public WPharmacyLogType WPharmacyLogType
        {
            get { return this.FieldToEnumViaDBLookup<WPharmacyLogType>(this.RawRow["WPharmacyLogTypeID"]).Value;   } 
            set { this.RawRow["WPharmacyLogTypeID"] = this.EnumToFieldViaDBLookup<WPharmacyLogType>(value, true);  }
        }

        /// <summary>Gets or sets DB field DateTime</summary>
        public DateTime DateTime
        {
            get { return this.FieldToDateTime(this.RawRow["DateTime"]).Value; } 
            set { this.RawRow["DateTime"] = this.DateTimeToField(value);      }
        }

        /// <summary>Gets or sets DB field SessionID</summary>
        public int SessionID
        {
            get { return this.FieldToInt(this.RawRow["SessionID"]).Value; } 
            set { this.RawRow["SessionID"] = this.IntToField(value);      }
        }

        /// <summary>Gets or sets DB field SiteID</summary>
        public int? SiteID
        {
            get { return this.FieldToInt(this.RawRow["SiteID"]);  } 
            set { this.RawRow["SiteID"] = this.IntToField(value); }
        }

        /// <summary>Gets or sets DB field NSVCode</summary>
        public string NSVCode
        {
            get { return this.FieldToStr(this.RawRow["NSVCode"], false, string.Empty); } 
            set { this.RawRow["NSVCode"] = this.StrToField(value, false);              }
        }

        /// <summary>Gets or sets DB field EntityID_User</summary>
        public int? EntityID_User
        {
            get { return this.FieldToInt(this.RawRow["EntityID_User"]);  } 
            set { this.RawRow["EntityID_User"] = this.IntToField(value); }
        }

        /// <summary>Gets DB field Initials</summary>
        public string Initials
        {
            get { return this.FieldToStr(this.RawRow["Initials"]);  } 
        }

        /// <summary>
        /// Gets or sets DB field Terminal
        /// Automatically truncates the terminal name to max allowed by the field
        /// </summary>
        public string Terminal
        {
            get { return this.FieldToStr(this.RawRow["Terminal"], true, string.Empty);                                                    } 
            set { this.RawRow["Terminal"] = this.StrToField(value.SafeSubstring(0, WPharmacyLog.GetColumnInfo().TerminalLength), false);  }
        }

        /// <summary>Gets or sets DB field Detail</summary>
        public string Detail
        {
            get { return this.FieldToStr(this.RawRow["Detail"], false, string.Empty); } 
            set { this.RawRow["Detail"] = this.StrToField(value, false);             }
        }

        /// <summary>Gets or sets DB field State</summary>
        public int? State
        {
            get { return this.FieldToInt(this.RawRow["State"]);  } 
            set { this.RawRow["State"] = this.IntToField(value); }
        }

        /// <summary>Gets or sets DB field Thread</summary>
        public int? Thread
        {
            get { return this.FieldToInt(this.RawRow["Thread"]);  } 
            set { this.RawRow["Thread"] = this.IntToField(value); }
        }

        /// <summary>Gets or sets DB field DBID</summary>
        public int? DBID
        {
            get { return this.FieldToInt(this.RawRow["DBID"]);  } 
            set { this.RawRow["DBID"] = this.IntToField(value); }
        }
    }

    /// <summary>Column info in the WPharmacyLog</summary>
    public class WPharmacyLogColumnInfo : BaseColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="WPharmacyLogColumnInfo"/> class.</summary>
        public WPharmacyLogColumnInfo() : base("WPharmacyLog") { }

        /// <summary>Gets length of DB field Terminal</summary>
        public int TerminalLength { get { return this.tableInfo.GetFieldLength("Terminal");    } }

        /// <summary>Gets length of DB field DescriptionLength</summary>
        public int DescriptionLength { get { return this.tableInfo.GetFieldLength("Description"); } }

        /// <summary>Gets length of DB field Detail</summary>
        public int DetailLength { get { return this.tableInfo.GetFieldLength("Detail");      } }
    }

    /// <summary>Represent the WPharmacyLog table</summary>
    public class WPharmacyLog : BaseTable2<WPharmacyLogRow, WPharmacyLogColumnInfo>
    {
        #region Data Types
        /// <summary>Keeps track of the low to new data row to update the PK</summary>
        private struct LogToNewRowLink
        {
            /// <summary>Log row</summary>
            public WPharmacyLogRow logRow;
            
            /// <summary>Data row</summary>
            public DataRow row;

            /// <summary>PK column name</summary>
            public string rowPKName;
        }
        #endregion
        
        #region Private Fields
        /// <summary>Used by BeginRow, AppendDetail, AppendLineDetail, and EndRow</summary>
        private StringBuilder currentRowDetial = new StringBuilder();

        /// <summary>If using BeginRow to write to current row</summary>
        private bool writingRow = false;

        /// <summary>
        /// Used by AddRange when data set passed if it has new lines this object is used to keep track of which newlines links to the pharmacy log lines.
        /// So when log is saved with go through the object and read in the pk value for all the new rows to update the log row DBID.
        /// </summary>
        private List<LogToNewRowLink> logToNewRowList = new List<LogToNewRowLink>();
        #endregion

        /// <summary>Initializes a new instance of the <see cref="WPharmacyLog"/> class.</summary>
        public WPharmacyLog() : base("WPharmacyLog") 
        { 
            // as already a log, don't bother writing to 
            //this.writeToAudtiLog = false;  28Nov16 XN Knock on effects to change in BaseTable2.WriteToAudtiLog 147104
            this.WriteToAudtiLog = false;
        }

        #region Public Methods
        /// <summary>
        /// Adds a new row, and sets default values
        ///     DateTime
        ///     SessionID
        ///     SiteID
        ///     EntityID_User
        ///     Terminal
        /// </summary>
        /// <returns>New row</returns>
        public override WPharmacyLogRow Add()
        {
            WPharmacyLogRow newRow = base.Add();
            newRow.DateTime         = DateTime.Now;
            newRow.SessionID        = SessionInfo.SessionID;
            newRow.SiteID           = SessionInfo.HasSite ? SessionInfo.SiteID : (int?)null;    // 25Aug15 XN added check site set
            newRow.EntityID_User    = SessionInfo.EntityID;
            newRow.Terminal         = SessionInfo.Terminal.SafeSubstring(0, WPharmacyLog.GetColumnInfo().TerminalLength);
            newRow.State            = 0;
            newRow.Thread           = 0;
            return newRow;
        }

        /// <summary>
        /// Will add each row that has been laterd in table, as a row in the WPharmayLog
        /// If row is delete will log this as
        ///     DELETED '{identifier}'
        /// If row is added will log as
        ///     ADDED 
        ///     {column name}: {column value} 
        ///     {column name}: {column value} 
        ///     :
        /// If row updated will log as
        ///     UPDATED '{identifier}'
        ///     {column name}: Was {column value} Now {column value}
        ///     {column name}: Was {column value} Now {column value}
        ///     :
        /// </summary>
        /// <typeparam name="T">BaseRow type or table</typeparam>
        /// <typeparam name="C">BaseColumn type or table</typeparam>
        /// <param name="table">table to check</param>
        /// <param name="logType">Log type for the row</param>
        /// <param name="identifierFunc">Function to get an identifing property for the row e.g. r => r.Code</param>
        /// <param name="siteIDFunc">Function to get siteID for the row e.g. r => r.SiteID</param>
        /// <param name="NSVCodeFunc">Function to get NSVCode for the row (or null if no NSVCode) e.g. r => r.NSVCode</param>
        public void AddRange<T,C>(BaseTable2<T,C> table, WPharmacyLogType logType, Func<T,string> identifierFunc, Func<T,int> siteIDFunc, Func<T,string> NSVCodeFunc = null) where T : BaseRow, new() where C : BaseColumnInfo, new()
        {
            DateTime now = DateTime.Now;
            StringBuilder detail = new StringBuilder();
            string pkColumn = table.GetPKColumnName();

            // Add deleted items to pharmacy log (these are held in separate table in BaseTable2)
            using (DataTable deletedItemsTable = table.DeletedItemsTable.Copy())
            {
                // Have gotton a copy of DeletedItemsTable so can reject changes, 
                // else will error if try to access deleted rows data
                deletedItemsTable.RejectChanges();

                // Add each delete row to pharmacy log
                foreach (DataRow row in deletedItemsTable.Rows)
                {
                    T r = new T();
                    r.RawRow = row;

                    WPharmacyLogRow log = this.Add();
                    log.DateTime        = now;
                    log.SiteID          = siteIDFunc.Invoke(r);
                    log.WPharmacyLogType= logType;
                    log.NSVCode         = NSVCodeFunc == null ? string.Empty : NSVCodeFunc.Invoke(r);
                    log.Detail          = string.Format("DELETED '{0}'\n", identifierFunc.Invoke(r) ?? string.Empty);
                    log.DBID            = string.IsNullOrEmpty(pkColumn) ? (int?)null : (int)r.RawRow[pkColumn];
                }
            }

            // Add added and updated items to the pharmacy log
            foreach (T r in table)
            {
                // If no changes to row then skip
                if (r.RawRow.RowState != DataRowState.Added && r.RawRow.RowState != DataRowState.Modified)
                    continue;

                // Create log row
                WPharmacyLogRow log = this.Add();
                log.DateTime        = now;
                log.SiteID          = siteIDFunc.Invoke(r);
                log.WPharmacyLogType= logType;
                log.NSVCode         = NSVCodeFunc == null ? string.Empty : NSVCodeFunc.Invoke(r);

                // Create log message
                detail.Length = 0;
                if (r.RawRow.RowState == DataRowState.Added)
                {
                    // Row has been added
                    detail.AppendLine("ADDED");
                    foreach (DataColumn c in table.Table.Columns.OfType<DataColumn>())
                    {
                        if (!c.ColumnName.EqualsNoCase(pkColumn) && !BaseTable2<T,C>.ExcludedColumns.Contains(c.ColumnName))
                        {
                            object currentValue = r.RawRow[c];
                            detail.AppendFormat("{0}: {1}\n", c.ColumnName, currentValue == DBNull.Value ? string.Empty : "'" + currentValue  + "'");
                        }
                    }

                    // If PK can't update the DBID at this stage as data will not have been saved to the DB so 
                    // keep track of the log and data row, and update on save.
                    if (!string.IsNullOrEmpty(pkColumn))
                    {
                        this.logToNewRowList.Add(new LogToNewRowLink() { logRow = log, row = r.RawRow, rowPKName = pkColumn });
                    }
                }
                else
                {
                    // Row has been modified
                    log.DBID = string.IsNullOrEmpty(pkColumn) ? (int?)null : (int)r.RawRow[table.GetPKColumnName()];
                    detail.AppendFormat("UPDATED {0}\n", identifierFunc.Invoke(r) ?? string.Empty);
                    foreach (DataColumn c in r.GetChangedColumns())
                    {
                        object originalValue= r.RawRow[c, DataRowVersion.Original];
                        object currentValue = r.RawRow[c];

                        detail.AppendFormat("{0}: Was {1} Now {2}\n", 
                                                    c.ColumnName, 
                                                    originalValue== DBNull.Value ? string.Empty : "'" + originalValue + "'",
                                                    currentValue == DBNull.Value ? string.Empty : "'" + currentValue  + "'" 
                                                    ); 
                    }
                }
                log.Detail = detail.ToString();
            }
        }

        /// <summary>
        /// ******** This is a duplicate of code in WardCodes feature branch this is the master ***********
        /// Will add each row that has been altered in table, as a row in the WPharmacyLog
        /// If row is delete will log this as
        ///     DELETED '{identifier}'
        /// If row is added will log as
        ///     ADDED 
        ///     {column name}: {column value} 
        ///     {column name}: {column value} 
        ///     :
        /// If row updated will log as
        ///     UPDATED '{identifier}'
        ///     {column name}: Was {column value} Now {column value}
        ///     {column name}: Was {column value} Now {column value}
        ///     :
        /// </summary>
        /// <typeparam name="T">BaseRow type or table</typeparam>
        /// <typeparam name="C">BaseColumn type or table</typeparam>
        /// <param name="table">table to check</param>
        /// <param name="logType">Log type for the rows WPharmacyLog.WPharmacyLogType</param>
        /// <param name="identifierFunc">Function to get a property to identify the row e.g. r => r.Code</param>
        /// <param name="siteIDFunc">Function to get siteID for the row e.g. r => r.SiteID</param>
        /// <param name="NSVCodeFunc">Function to get NSVCode for the row (or null if no NSVCode) e.g. r => r.NSVCode</param>
        /// <param name="threadFunc">Function to set the WPharmacyLog.Thread field to</param>
        /// <param name="extraExcludeCollumns">Extra columns to exclude from the log (will automatically exclude items like _TableVersion, _QA, PK, etc)</param>
        public void AddRange<T, C>(
                                  BaseTable2<T, C> table, 
                                  WPharmacyLogType logType,
                                  Func<T, string>  identifierFunc, 
                                  Func<T, int?>    siteIDFunc, 
                                  Func<T, string>  NSVCodeFunc          = null,
                                  Func<T, int?>    threadFunc           = null,
                                  string[]         extraExcludeCollumns = null) where T : BaseRow, new() where C : BaseColumnInfo, new()
        {
            DateTime now = DateTime.Now;
            StringBuilder detail = new StringBuilder();
            string pkColumn = table.GetPKColumnName();
            int maxDetailLength = WPharmacyLog.GetColumnInfo().DetailLength;

            if (extraExcludeCollumns == null)
            {
                extraExcludeCollumns = new string[0];
            }

            // Add deleted items to pharmacy log (these are held in separate table in BaseTable2)
            if (table.DeletedItemsTable != null)    // 2Dec14 XN prevent error if delete item table not created (newly created table)
            {
                using (DataTable deletedItemsTable = table.DeletedItemsTable.Copy())
                {
                    // Have gotton a copy of DeletedItemsTable so can reject changes, 
                    // else will error if try to access deleted rows data
                    deletedItemsTable.RejectChanges();

                    // Add each delete row to pharmacy log
                    foreach (DataRow row in deletedItemsTable.Rows)
                    {
                        T r = new T();
                        r.RawRow = row;

                        WPharmacyLogRow log = this.Add();
                        log.DateTime        = now;
                        log.SiteID          = siteIDFunc.Invoke(r);
                        log.WPharmacyLogType= logType;
                        log.NSVCode         = NSVCodeFunc == null ? string.Empty : NSVCodeFunc.Invoke(r);
                        log.Thread          = threadFunc  == null ? null         : threadFunc.Invoke(r);
                        log.DBID            = string.IsNullOrEmpty(pkColumn) ? (int?)null : (int)r.RawRow[pkColumn];

                        // Set detail 
                        var changeColumns = r.RawRow.Table.Columns.Cast<DataColumn>();
                        changeColumns = changeColumns.Where(c => !c.ColumnName.EqualsNoCase(pkColumn) && !BaseTable2<T,C>.ExcludedColumns.Contains(c.ColumnName) && !extraExcludeCollumns.Contains(c.ColumnName)).ToList();
                        detail.Length = 0;
                        detail.AppendLine("DELETED");
                        foreach (DataColumn c in changeColumns)
                        {
                            object currentValue = r.RawRow[c, DataRowVersion.Original];
                            detail.AppendFormat("{0}: {1}\n", c.ColumnName, currentValue == DBNull.Value ? string.Empty : "'" + currentValue  + "'");
                        }

                        if (detail.Length > maxDetailLength)
                        {
                            detail.Length = maxDetailLength; // Limit to max description length
                        }
                        
                        log.Detail = detail.ToString();
                    }
                }
            }                

            // Add added and updated items to the pharmacy log
            for (int pos = 0; pos < table.Count; pos++)
            {
                T r = table[pos];

                // If no changes to row then skip
                if (r.RawRow.RowState != DataRowState.Added && r.RawRow.RowState != DataRowState.Modified)
                {
                    continue;
                }

                // Get if there are any columns that have changed (might not be for modified where extraExcludeCollumns is set)
                var changeColumns = r.GetChangedColumns().Where(c => !c.ColumnName.EqualsNoCase(pkColumn) && !BaseTable2<T,C>.ExcludedColumns.Contains(c.ColumnName) && !extraExcludeCollumns.Contains(c.ColumnName)).ToList();
                if (!changeColumns.Any())
                {
                    continue;
                }

                // Create log row
                WPharmacyLogRow log = this.Add();
                log.DateTime        = now;
                log.SiteID          = siteIDFunc.Invoke(r);
                log.WPharmacyLogType= logType;
                log.NSVCode         = NSVCodeFunc == null ? string.Empty : NSVCodeFunc.Invoke(r);
                log.Thread          = threadFunc  == null ? null         : threadFunc.Invoke(r);

                // Create log message
                detail.Length = 0;
                if (r.RawRow.RowState == DataRowState.Added)
                {
                    // Row has been added
                    detail.AppendLine("ADDED");
                    foreach (DataColumn c in changeColumns)
                    {
                        object currentValue = r.RawRow[c];
                        detail.AppendFormat("{0}: {1}\n", c.ColumnName, currentValue == DBNull.Value ? string.Empty : "'" + currentValue  + "'");
                    }

                    // If PK can't update the DBID at this stage as data will not have been saved to the DB so 
                    // keep track of the log and data row, and update on save.
                    if (!string.IsNullOrEmpty(pkColumn))
                    {
                        this.logToNewRowList.Add(new LogToNewRowLink() { logRow = log, row = r.RawRow, rowPKName = pkColumn });
                    }
                }
                else
                {
                    // Row has been modified
                    log.DBID = string.IsNullOrEmpty(pkColumn) ? (int?)null : (int)r.RawRow[table.GetPKColumnName()];
                    detail.AppendFormat("UPDATED {0}\n", identifierFunc.Invoke(r) ?? string.Empty);
                    foreach (DataColumn c in changeColumns)
                    {
                        object originalValue= r.RawRow[c, DataRowVersion.Original];
                        object currentValue = r.RawRow[c];

                        detail.AppendFormat(
                            "{0}: Was {1} Now {2}\n",
                            c.ColumnName,
                            originalValue == DBNull.Value ? string.Empty : "'" + originalValue + "'",
                            currentValue == DBNull.Value ? string.Empty : "'" + currentValue  + "'"); 
                    }
                }

                if (detail.Length > maxDetailLength)
                {
                    detail.Length = maxDetailLength; // Limit to max description length
                }
                
                log.Detail = detail.ToString();
            }
        }

        /// <summary>
        /// Adds a new row to the system, for starting writing to
        /// Use function AppendDetail, AppendLineDetail, and EndRow
        /// </summary>
        /// <param name="logType">Log type for the row</param>
        /// <param name="NSVCode">optional NSVCode for the row</param>
        /// <returns>New row</returns>
        public WPharmacyLogRow BeginRow(WPharmacyLogType logType, string NSVCode)
        {
            // End wiriting of previous row
            if (this.writingRow)
            {
                this.EndRow();
            }

            // Create new row
            WPharmacyLogRow newRow = this.Add();
            newRow.WPharmacyLogType = logType;
            newRow.NSVCode          = NSVCode;

            // Reset
            this.writingRow              = true;
            this.currentRowDetial.Length = 0;

            return newRow;
        }

        /// <summary>Appends text to the current row details field (must call EndRow when finished)</summary>
        /// <param name="format">Format string</param>
        /// <param name="param">Parameters for format string</param>
        public void AppendDetail(string format, params object[] param)
        {
            this.currentRowDetial.AppendFormat(format, param);
        }

        /// <summary>Appends line to current row details field (must call EndRow when finished)</summary>
        /// <param name="format">Format string</param>
        /// <param name="param">Parameters for format string</param>
        public void AppendLineDetail(string format, params object[] param)
        {
            this.currentRowDetial.AppendLine(string.Format(format, param));
        }

        /// <summary>
        /// Called when finished using AppendDetail, and AppendLineDetail for current row
        /// will finish writing the current row.
        /// </summary>
        public void EndRow()
        {
            if (!this.writingRow)
            {
                return;
            }
            
            this.writingRow = false;

            this.Last().Detail = this.currentRowDetial.ToString();

            this.currentRowDetial.Length = 0;
        }

        /// <summary>
        /// Loads log items by criteria specified (limited to row count)
        /// Uses sp pWPharmacyLogByCriteria
        /// </summary>
        /// <param name="criteria">Criteria specified</param>
        /// <param name="maxRowCount">Max number of rows to returns</param>
        public void LoadByCriteria(string criteria, int maxRowCount)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();

            parameters.Add(new SqlParameter("@SessionID",   SessionInfo.SessionID   ));
            parameters.Add(new SqlParameter("@SQLWhere",    criteria                ));
            parameters.Add(new SqlParameter("@MaximumRows", maxRowCount             )); 

            base.LoadBySP("pWPharmacyLogByCriteria", parameters);
        }

        /// <summary>Overrides the base class to write to orderlog</summary>
        public override void Save()
        {
            this.UpdateDBID();
            base.Save();
        }

        /// <summary>
        /// Call after AddRange to force DBID fields to be updated (for newly added rows)
        /// Note that the Save method will call this method anyway, but there are occasions were you might need to update the DBIDs before calling save.
        /// </summary>
        public void UpdateDBID()
        {
            // Update the pharmacy log row with the DBID
            foreach (var link in this.logToNewRowList)
            {
                object dbid = link.row[link.rowPKName];
                if (dbid == DBNull.Value)
                {
                    System.Diagnostics.Debug.Fail("When using WPharmacyLog.AddRange call the method first. Then save dataset passed, and afterwards call save on WPharmacyLog (so WPharmacyLog can read back pk of newly added rows).");
                }
                else
                {
                    link.logRow.DBID = (int)dbid;
                }
            }
            
            this.logToNewRowList.Clear();
        }
        #endregion
    }
}
