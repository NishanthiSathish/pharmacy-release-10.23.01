//===========================================================================
//
//							        BaseTable.cs
//
//	Base class for a class that represents a db table.
//
//  Once db rows have been loaded into the class (via LoadFromXMLString, 
//  or LoadRecordSetStream), it can be used as an enumerable list of BaseRow items.
//
//  The class should be inherited from rather than being used directly.  
//
//  Derived classes will need to 
//      1. Provide LoadBy functions to load db rows, via an sp.
//      2. Define the associated dervied BaseRow, and BaseColumnInfo classes to use.
//      3. If supporting updating it should set the UpdateSP property.
//
//  Usage:
//
//  public class WBatchStockLevel : BaseTable<WBatchStockLevelRow, WBatchStockLevelColumnInfo>
//  {
//      public WBatchStockLevel() : base("WBatchStockLevel", "WBatchStockLevelID") 
//      {
//          UpdateSP = "pWBatchStockLevelUpdate";
//      }
//
//      public WBatchStockLevel(RowLocking rowLocking) : base("WBatchStockLevel", "WBatchStockLevelID", rowLocking) 
//      {
//          UpdateSP = "pWBatchStockLevelUpdate";
//      }
//
//      public void LoadBySiteIDAndNSVCode(int siteID, string NSVCode)
//      {
//          StringBuilder parameters = new StringBuilder();
//          AddInputParam(parameters, "LocationID_Site",    siteID);   
//          AddInputParam(parameters, "NSVCode",            NSVCode);
//          LoadRecordSetStream( "pWBatchStockLevelbySiteandNSVCode", parameters );
//      }
//  }
//
//  To load in a number of new WBatchStockLevel items
//      WBatchStockLevel batches = new WBatchStockLevel();
//      batches.LoadBySiteIDAndNSVCode(26, "GT242F");
//      foreach(WBatchStockLevelRow batchRow in batches)
//          System.Diagnostics.Debug.WriteLine ( batchRow.BatchNumber );
//
//  To update an existing WBatchStockLevel item
//      WBatchStockLevel batches = new WBatchStockLevel();
//      batches.LoadBySiteIDAndNSVCode(26, "GT242F");
//      batches[0].QuantityInIssueUnits = batchRow.QuantityInIssueUnits + 1;
//      batches.Save();
//
//  To insert a new WBatchStockLevel item
//      WBatchStockLevel batches = new WBatchStockLevel();
//      WBatchStockLevelRow batchRow = batches.Add();
//      batchRow.SiteID                 = 26;
//      :    
//      batchRow.QuantityInIssueUnits   = 4;
//      batches.Save();
//
//  To delete a row WBatchStockLevel item
//      WBatchStockLevel batches = new WBatchStockLevel();
//      batches.LoadBySiteIDAndNSVCode(26, "GT242F");
//      batches.RemoveAt(0);
//      batches.Save();
//
//  To delete a row without loading the data
//      WBatchStockLevel batches = new WBatchStockLevel();
//      batches.DirectDelete(12332);
//
//  To get the column info on a WBatchStockLevel db column
//      int maxBathNumberLength = WBatchStockLevel.GetColumnInfo().BatchNumberLength    
//      
//	Modification History:
//	09Apr09 XN  Written
//  27Apr09 XN  Removed all static variables by making them local, or storing
//              them in the pharmacy cache. To allow use as web app.
//  29May09 XN  Added the Sort method
//  10Jul09 XN  Added delete functionality.
//  24Jul09 XN  Added another AddInputParameter method for datarows
//  21Dec09 XN  Extened AddInputParam so dates and times save to ms level.
//              Got GetTLDataType to support Int16
//  29Apr10 XN  Added ValidationErrors property in process of removing 
//              uneeded business layer classes
//  03Sep10 XN  F0082255
//              Added TableID property.
//              Got CreateEmpty to use GetColumnInfo instead of calling
//              TableInfo.LoadTableInfo directly, so can handle inherited tables.
//              Fixed bug in LoadFromXMLString. 
//  01Jun11 XN  Made GetTLDataType return varchar for StringBuilder type
//  07Jun11 XN  F0041502 Added asymmetric dosing
//  13May11 XN  Added excluding rows like _RowVersion from update and inserts
//              as these columns are not covered by pImportSingleTableMetaData
//              when creating defaults sps. 
//              Also added logical deletes
//  01Jun11 XN  Made GetTLDataType return varchar for StringBuilder type
//  07Jun11 XN  F0041502 Added asymmetric dosing
//  09Jun11 XN  Added handling of Nullable types to GetTLDataType method
//  20Apr12 XN  Updated LoadFromXMLString to always have a table present
//              even if no xml data read from db so does not crash TFS Urgent    
//  26Jul13 XN  Added GetColumnInfo_InstanceVersion and got class to use this method
//              instead of static GetColumnInfo (so Generic table can save) 24653
//  08May15 XN  Update FindByID for changes in BaseRow (change field from static to instance for error handling improvements)
//===========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using _Shared;
using TRNRTL10;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.basedatalayer
{
    /// <summary>Used to determine if row locking is enabled</summary>
    public enum RowLocking
    {
        Enabled,
        Disabled,
    };
 
    public class BaseTable<T,C> : IEnumerable<T>, IDisposable
        where T : BaseRow, new()
        where C : BaseColumnInfo, new()
    {
        #region Constants
        private const string SessionLockFieldName = "SessionLock";          // Name of the session lock field
        private const string DataSetTableName     = "Table";                // Active dataset table name
        private const string DeletedItemsTableName= "DeletedItemsTable";    // Name of the delete item table
        private static readonly string[] ExcludedColumns = new string[]{  "_RowVersion",      // Rows excluded from standard set of update delete sps
                                                                          "_RowGUID",
                                                                          "_TableVersion",
                                                                          "_QA",
                                                                          "_Deleted" };
        #endregion

        #region Member variables
        protected Transport dblayer = new Transport();  // ICW transport layer
        private   DataSet   dataSet = new DataSet();    // Dataset that contains all the rows (contains 2 table data table and deleted items table)

        public  RowLocking  rowLocking  = RowLocking.Disabled;   // If row locking enabled
        private LockResults lockResults = null;                  // Class used to handle locking
        #endregion

        #region Properites
        /// <summary>Stored procedure used when row needs to be updated.</summary>
        protected string UpdateSP { get; set; }

        /// <summary>If session lock field is included in update sp</summary>
        protected bool IncludeSessionLockInUpdate { get; set; }

        /// <summary>If session lock field is included in insert sp</summary>
        protected bool IncludeSessionLockInInsert { get; set; }

        /// <summary>If table uses logical deletes</summary>
        protected bool UseLogicalDelete { get; set; }

        /// <summary>DB table name (or view) the class relates to</summary>
        public string TableName { get; set; }

        /// <summary>PK column name for table</summary>
        public string PKColumnName { get; set; }        

        /// <summary>Returns number of rows loaded.</summary>
        public int Count
        {
            get { return (Table != null) ? Table.Rows.Count : 0; }
        }

        /// <summary>Provides access to the under lying dataset table</summary>
        public DataTable Table
        {
            get { return (dataSet.Tables.Count > 0) ? dataSet.Tables[DataSetTableName] : null; }
        }

        /// <summary>Provides access to the under lying deleted item database table</summary>
        public DataTable DeletedItemsTable
        {
            get { return dataSet.Tables.Contains(DeletedItemsTableName) ? dataSet.Tables[DeletedItemsTableName] : null; }
        }

        /// <summary>
        /// Read the TableID from the ICW [Table] table.
        /// Once read values are cached.
        /// If this table does not exists in ICW [Table] property will assert.
        /// </summary>
        protected int TableID
        {
            get
            {
                string cacheName = string.Format("{0}.TableID['{1}']", this.GetType().FullName, TableName);

                // Try reading the value from the cache
                int? tableID = (int?)PharmacyDataCache.GetFromCache(cacheName);
                if (!tableID.HasValue)
                {
                    // Read the value from the ICW [Table]
                    tableID = TableInfo.GetTableID(TableName);
                    if (tableID == -1 )
                        throw new ApplicationException(string.Format("Table {0} has not been registered in the ICW [Table] table.", TableName));

                    // Cache the value for future reference.
                    PharmacyDataCache.SaveToCache(cacheName, tableID.Value);
                }

                return tableID.Value;
            }
        }

        /// <summary>List of validation error objects</summary>
        public ValidationErrorList ValidationErrors { get; set; }
        #endregion

        #region Constructors
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="tableName">Name of db table class is associated with</param>
        /// <param name="pkcolumnName">Name of db PK column for table</param>
        /// <param name="rowLocking">If locking should be enable</param>
        public BaseTable (string tableName, string pkcolumnName, RowLocking rowLocking)
	    {
            this.TableName    = tableName;
            this.PKColumnName = pkcolumnName;
            this.rowLocking   = rowLocking; 
            this.lockResults  = new LockResults(tableName, pkcolumnName);
            this.IncludeSessionLockInUpdate = false;
            this.UseLogicalDelete = false;
            this.ValidationErrors = new ValidationErrorList();
	    }

        public BaseTable (string tableName, string pkcolumnName)
	    {
            this.TableName    = tableName;
            this.PKColumnName = pkcolumnName;
            this.lockResults  = new LockResults(tableName, pkcolumnName);
            this.IncludeSessionLockInUpdate = false;
            this.UseLogicalDelete = false;
            this.ValidationErrors = new ValidationErrorList();
	    }

        public BaseTable ()
	    {
            this.lockResults  = new LockResults(string.Empty, string.Empty);
            this.UseLogicalDelete = false;
            this.ValidationErrors = new ValidationErrorList();
        }
        #endregion

        ~BaseTable()
        {
            Dispose(false);
        }

        #region Public Methods
        /// <summary>
        /// Saves any changes (since last call to LoadBy or Save) to the database.
        /// </summary>
        public void Save()
        {
            // Iterate through all delete rows
            if (DeletedItemsTable != null)
            {
                foreach (DataRow row in DeletedItemsTable.Rows)
                    DeleteRow(row);
                DeletedItemsTable.Rows.Clear();
            }

            // Iterate through all insert\update rows
            if (Table != null)
            {
                foreach (DataRow row in Table.Rows)
                {
                    // If no changes to this row then skip to next row
                    if (row.RowState == DataRowState.Unchanged)
                        continue;

                    // Perform add or update as needed
                    switch (row.RowState)
                    {
                        case DataRowState.Added:    InsertRow(row); break;
                        case DataRowState.Modified: UpdateRow(row); break;
                    }

                    // Clear row state.
                    row.AcceptChanges();
                }
            }
        }

        /// <summary>
        /// Removes all data from dataset (will not save changes)
        /// All locks will be cleared.
        /// </summary>
        public void Clear()
        {
            // clear all locks
            this.UnlockRows();

            // Remove all data
            while (dataSet.Tables.Count > 0)
                dataSet.Tables.RemoveAt(0);
            dataSet.Clear();
        }

        /// <summary>
        /// Adds a new row to the data set.
        /// The row will not be saved to the database until Save is called.
        /// </summary>
        /// <returns>data row</returns>
        public virtual T Add()
        {
            // Need to create dataset table if it does not already exist.
            if (Table == null)
                CreateEmpty();

            // Create new row
            DataRow oRow = Table.NewRow();
            Table.Rows.Add(oRow);

            // Create row object of correct type, and initalise with dataset row.
            T oTRow = new T();
            oTRow.RawRow = oRow;
            return oTRow;
        }

        /// <summary>
        /// Remove the selected item from the list
        /// The database will not be updated till save is called.
        /// </summary>
        /// <param name="item">Row to remove</param>
        public virtual void Remove(T item)
        {
            DataRowState orignalState = item.RawRow.RowState;

            //item.RawRow.Delete();
            if (orignalState != DataRowState.Added)
                DeletedItemsTable.ImportRow(item.RawRow);
            Table.Rows.Remove(item.RawRow);
        }

        /// <summary>
        /// Removes all the rows.
        /// The database will not be updated till save is called.
        /// </summary>
        public void RemoveAll()
        {
            RemoveAll(this.ToList());
        }

        /// <summary>
        /// Removes all the rows that match the predicate
        /// The database will not be updated till save is called.
        /// </summary>
        /// <param name="match">condition for row to be removed</param>
        public void RemoveAll(Predicate<T> match)
        {
            List<T> itemsToRemove = new List<T>();

            foreach(T row in this)
            {
                if (match(row))
                    itemsToRemove.Add(row);
            }

            RemoveAll(itemsToRemove);
        }

        /// <summary>
        /// Removes all the rows that are in the items list
        /// The database will not be updated till save is called.
        /// </summary>
        /// <param name="items">Items to removes</param>
        public void RemoveAll(IEnumerable<T> items)
        {
            foreach(T item in items)
                Remove(item);
        }

        /// <summary>
        /// Removes item at specified index.
        /// The database will not be updated till save is called.
        /// </summary>
        /// <param name="index">Index of item to delete</param>
        public void RemoveAt(int index)
        {
            Remove(this[index]);
        }

        /// <summary>
        /// Removes count number of items from specified inex
        /// The database will not be updated till save is called.
        /// </summary>
        /// <param name="index">Start index</param>
        /// <param name="count">Number to delete</param>
        public void RemoveRange(int index, int count)
        {
            List<T> itemsToRemove = new List<T>();

            for (int c = 0; c < count; c++)
                itemsToRemove.Add(this[index + c]);

            RemoveAll(itemsToRemove);
        }

        /// <summary>
        /// Gets column info object for this table.
        /// This data is stored in the pharmacy data cache.
        /// </summary>
        /// <returns>column info object</returns>
        public static C GetColumnInfo()
        {
            string cachedName = typeof(C).FullName;
            C columnInfo;

            // Try to get the column info from the cach (else add)
            columnInfo = PharmacyDataCache.GetFromCache(cachedName) as C;
            if (columnInfo == null)
            {
                columnInfo = new C();
                PharmacyDataCache.SaveToCache(cachedName, columnInfo);
            }

            // If column info data not loaded then load
            if (!columnInfo.IsLoaded)
                columnInfo.LoadColumnInfo();

            // Return results
            return columnInfo;
        }

        /// <summary>
        /// Allows interation through the rows
        /// </summary>
        /// <param name="index">Row index (of loaded data).</param>
        /// <returns>data row</returns>
        public virtual T this[int index]
        {
            get
            {
                // Create row object of correct type, and initalise with dataset row.
                T row = new T();
                row.RawRow = Table.Rows[index];
                return row;
            }
        }

        /// <summary>
        /// Returns row with the specified PK ID
        /// </summary>
        /// <param name="id">PK ID</param>
        /// <returns>data row (or null if row does not exist)</returns>
        public T FindByID(int id)
        {
            // If no pk column defined then can't search
            if ((Table != null) && Table.Columns.Contains(PKColumnName))
            {
                foreach (T row in this)
                {
                    if (row.FieldToInt(row.RawRow[PKColumnName]) == id)
                        return row;
                }

            }

            return null;
        }

        /// <summary>
        /// Unlocks all the existing rows
        /// </summary>
        public void UnlockRows()
        {
            lockResults.UnlockRows();
        }

        /// <summary>
        /// Sorts the row as specified
        /// This method should only really be used straight after a load.
        /// </summary>
        /// <param name="orderby">string that contains column names and "ASC" or "DESC"</param>
        public void Sort(string orderby)
        {
            if (orderby == null)
                throw new NullReferenceException();

            // Create a view of a table and sort it
            DataTable table = Table;
            DataView  view  = new DataView(table);
            view.Sort = orderby;

            // Remove the old unsorted table from the dataset
            dataSet.Tables.Remove(table);

            // Get the sorted table from the view and assign it back to the dataset
            table = view.ToTable();
            table.TableName = DataSetTableName;
            dataSet.Tables.Add(table);
        }
        #endregion

        #region Protected methods
        /// <summary>
        /// Initialises the class for use without the need to call a LoadBy method.
        /// When called will 
        ///     1. Remove all existing data (ignoring any changes).
        ///     2. Reads in table information from database to initialise the dataset
        /// The Add function will calls this when needed.
        /// </summary>
        protected void CreateEmpty()
        {
            // Remove all existing data
            Clear();

            // Get information on the table from the database
            TableInfo tableInfo = this.GetColumnInfo_InstanceVersion().tableInfo;
            if (tableInfo.Count == 0)
            {
                string msg = string.Format("Failed to get table schema for '{0}'", TableName);
                throw new ApplicationException(msg);
            }

            // Gets or creates an active table
            DataTable defaultTable = Table;
            if (defaultTable == null)
                defaultTable = dataSet.Tables.Add(DataSetTableName);

            // Creats an empty delete table if required
            DataTable deleteTable = DeletedItemsTable;
            if (deleteTable == null)
                deleteTable = dataSet.Tables.Add(DeletedItemsTableName);

            // Set dataset schema from db information
            foreach (TableInfoRow row in tableInfo)
            {
                if (!defaultTable.Columns.Contains(row.ColumnName) && !ExcludedColumns.Contains(row.ColumnName))
                    defaultTable.Columns.Add(row.ColumnName, row.GetNETType());
                if (!deleteTable.Columns.Contains(row.ColumnName)  && !ExcludedColumns.Contains(row.ColumnName))
                    deleteTable.Columns.Add (row.ColumnName, row.GetNETType());
            }

            // The schema is just a basic version so can't really enforce constraints
            dataSet.EnforceConstraints = false;
        }

        /// <summary>
        /// Loads in data from a stored procedure that returns XML.
        /// The stored procedure should return a single table XML string (non nested xml).
        /// If locking is enabled for the class, then each row will be locked, after the method call.
        /// Unless append flag is set, exists records are removed (changes will not be saved), and exists locks are cleared.
        /// </summary>
        /// <param name="sp">Stored procedure name</param>
        /// <param name="parameters">Parameters in the stored procedure</param>
        /// <param name="append">If loaded data is to be append to current record set.</param>
        protected void LoadFromXMLString(string sp, StringBuilder parameters)
        {
            LoadFromXMLString(sp, parameters, false);
        }
        protected void LoadFromXMLString(string sp, StringBuilder parameters, bool append)
        {
            // Clear data if append not requested
            if (!append)
                Clear();

            // Execute sp through ICW transport layer
            string xml = "<root>" + dblayer.ExecuteSelectStreamSP(SessionInfo.SessionID, sp, parameters.ToString()) + "</root>";

            // Load the xml into local dataset
            DataSet newDataSet = new DataSet();
            newDataSet.ReadXml(new StringReader(xml), XmlReadMode.Auto);

            // If xml returns nothing then ensure we have a table in the system else everything will fall over TFS urgent
            if (newDataSet.Tables.Count == 0)
                newDataSet.Tables.Add();

            // If locking enabled then lock the rows
            if (rowLocking == RowLocking.Enabled)
            {
                using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    // lock the rows
                    lockResults.LockRows(newDataSet.Tables[0]);

                    // reload the data (incase things have changed since lock) into the local dataset 
                    newDataSet.Clear(); // remove existing items used get the ids
                    xml = "<root>" + dblayer.ExecuteSelectStreamSP(SessionInfo.SessionID, sp, parameters.ToString()) + "</root>";
                    newDataSet.ReadXml(new StringReader(xml), XmlReadMode.Auto);

                    // If xml returns nothing then ensure we have a table in the system else everything will fall over TFS urgent
                    if (newDataSet.Tables.Count == 0)
                        newDataSet.Tables.Add();

                    scope.Commit();
                }
            }

            // Remove the table from the local dataset (so can attach to class dataset)
            DataTable newTable = newDataSet.Tables[0];
            newDataSet.Tables.Remove(newTable);

            // Setup correct data table name, and disable constrains as not really valid in ICW.
            newTable.TableName = DataSetTableName;
            dataSet.EnforceConstraints = false;

            // Add or append the table to the existing class dataset.
            if (dataSet.Tables.Count == 0)
                dataSet.Tables.Add(newTable);
            else
                dataSet.Tables[DataSetTableName].Merge(newTable, true); // Only goes here if appending

            // Creats an empty delete table if required
            if (DeletedItemsTable == null)
            {
                DataTable deletedTable = Table.Clone();
                deletedTable.TableName = DeletedItemsTableName;
                dataSet.Tables.Add(deletedTable);
            }
        }

        /// <summary>
        /// Loads in data from a stored procedure that returns datasets.
        /// The stored procedure should return a singe table dataset
        /// If locking is enabled for the class, then each row will be locked, after the method call.
        /// Unless append flag is set, exists records are removed (changes will not be saved), and exists locks are cleared.
        /// </summary>
        /// <param name="sp">Stored procedure name</param>
        /// <param name="parameters">Parameters in the stored procedure</param>
        /// <param name="append">If loaded data is to be append to current record set.</param>
        protected internal void LoadRecordSetStream(string sp, StringBuilder parameters)
        {
            LoadRecordSetStream(sp, parameters, false);
        }
        protected internal void LoadRecordSetStream(string sp, StringBuilder parameters, bool append)
        {
            // Clear data if append not requested
            if (!append)
                Clear();

            // Execute sp through ICW transport layer
            DataSet ds = dblayer.ExecuteSelectSP(SessionInfo.SessionID, sp, parameters.ToString());

            // If locking enabled then lock the rows
            if (rowLocking == RowLocking.Enabled)
            {
                // TODO Need to check how transactions work with Sessions
                using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    // lock the rows
                    lockResults.LockRows(ds.Tables[0]);

                    // reload the data (incase things have changed since lock) into the local dataset 
                    ds.Clear();
                    ds = dblayer.ExecuteSelectSP(SessionInfo.SessionID, sp, parameters.ToString());

                    scope.Commit();
                }
            }

            // Remove the table from the local dataset (so can attach to class dataset)
            DataTable newTable = ds.Tables[0];
            ds.Tables.Remove(newTable);

            // Setup correct data table name, and disable constrains as not really valid in ICW.
            newTable.TableName = DataSetTableName;
            dataSet.EnforceConstraints = false;

            // Add or append the table to the existing class dataset.
            if (dataSet.Tables.Count == 0)
                dataSet.Tables.Add(newTable);
            else
                dataSet.Tables[DataSetTableName].Merge(newTable, true); // Only goes here if appending

            // Creats an empty delete table if required
            if (DeletedItemsTable == null)
            {
                DataTable deletedTable = Table.Clone();
                deletedTable.TableName = DeletedItemsTableName;
                dataSet.Tables.Add(deletedTable);
            }
        }

        /// <summary>
        /// For running stored procedures that return a scalar (integer) result)
        /// </summary>
        /// <param name="sp">Stored procedure name</param>
        /// <param name="parameters">Parameters in the stored procedure</param>
        /// <returns>Scalar results</returns>
        protected int ExecuteScalar(string sp, StringBuilder parameters)
        {
            return dblayer.ExecuteSelectReturnSP(SessionInfo.SessionID, sp, parameters.ToString());
        }

        /// <summary>
        /// Inserts a link between to tables into a link table
        /// </summary>
        /// <param name="linkTable">Link table the record is to be added to</param>
        /// <param name="field1"></param>
        /// <param name="pk1"></param>
        /// <param name="field2"></param>
        /// <param name="pk2"></param>
        protected void InsertLink(string linkTable, string field1, int pk1, string field2, int pk2)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, field1, pk1);
            AddInputParam(parameters, field2, pk2);
            dblayer.ExecuteInsertLinkSP(SessionInfo.SessionID, linkTable, parameters.ToString());
        }

        /// <summary>
        /// Called when a new row needs to be added to the database.
        /// This method can be overridded when custom insert actions need to be performed.
        /// The method expects the table to have a standard p{tablename}Insert stored procedure
        /// where each parameter in the stored procedure has the same name as the table column.
        /// </summary>
        /// <param name="row">Row to insert</param>
        protected virtual void InsertRow(DataRow row)
        {
            StringBuilder parameters = new StringBuilder();    // sp parameters
            BaseColumnInfo columnInfo = this.GetColumnInfo_InstanceVersion();        // table column info

            // add each field in the dataset row as a parameter
            // but only if the column is not the pk, 
            //                           not part of invalid column list (e.g. SessionLock)
            //                           and field name exists in the table (excludes joined tables)
            DataColumnCollection columns = Table.Columns;
            foreach (DataColumn column in columns)
            {
                if (!column.ColumnName.Equals(PKColumnName, StringComparison.InvariantCultureIgnoreCase) &&
                    (IncludeSessionLockInInsert || (column.ColumnName != SessionLockFieldName))          &&
                    (columnInfo.FindColumnByName(column.ColumnName) != null)                             &&
                    !ExcludedColumns.Contains(column.ColumnName))
                    AddInputParam(parameters, column.ColumnName, row[column.ColumnName], GetTLDataType(column.DataType));
            }

            // Perform the insert
            int pk = dblayer.ExecuteInsertSP(SessionInfo.SessionID, TableName, parameters.ToString());

            // update local dataset pk
            DataColumn pkcolumn = columns[PKColumnName];
            pkcolumn.ReadOnly = false;
            row[PKColumnName] = pk;
            pkcolumn.ReadOnly = true;
        }

        /// <summary>
        /// Called when a new row needs to be updated in the database.
        /// This method can be overridded when custom update actions need to be performed.
        /// The method expects the UpdateSP property to be set.
        /// Each parameter in the stored procedure has the same name as the table column.
        /// </summary>
        /// <param name="row">Row to updated</param>
        protected virtual void UpdateRow(DataRow row)
        {
            // check update sp name has been set
            if (string.IsNullOrEmpty(UpdateSP))
                throw new ApplicationException(string.Format("Update requested on table object '{0}' that does not have any suitable update stored procedure specified.", this.TableName));

            StringBuilder parameters = new StringBuilder(); // sp parameters
            BaseColumnInfo columnInfo = this.GetColumnInfo_InstanceVersion();    // table column info

            // add each field in the dataset row as a parameter
            // but only if the column is not part of invalid column list (e.g. SessionLock)
            // and field name exists in the table (excludes joined tables)
            DataColumnCollection columns = Table.Columns;
            foreach (DataColumn column in columns)
            {
                if ((columnInfo.FindColumnByName(column.ColumnName) != null)                    &&
                    (IncludeSessionLockInUpdate || (column.ColumnName != SessionLockFieldName)) &&
                    !ExcludedColumns.Contains(column.ColumnName))
                    AddInputParam(parameters, column.ColumnName, row[column.ColumnName], GetTLDataType(column.DataType));
            }

            // Perform the update
            dblayer.ExecuteUpdateCustomSP(SessionInfo.SessionID, UpdateSP, parameters.ToString());
        }

        /// <summary>
        /// Called when a new row needs to be deleted from the database.
        /// This method can be overridded when custom delete actions need to be performed.
        /// Each parameter in the stored procedure needs the same name as the table column.
        /// The method supports deletion of rows with single integer primary key, or from link tables.
        /// Note for pk deletions this method will call DirectDelete
        /// </summary>
        /// <param name="row">row to delete</param>
        protected virtual void DeleteRow(DataRow row)
        {
            TableInfo tableInfo = this.GetColumnInfo_InstanceVersion().tableInfo;
            IEnumerable<TableInfoRow> pkColumns = tableInfo.Where( i => i.IsPK );

            if (pkColumns.Count() == 0)
                throw new ApplicationException ("Can't delete row as table does not have a primary key.");
            if (!pkColumns.All(i => Table.Columns.Contains(i.ColumnName)))
                throw new ApplicationException ("Select statement used to get data from db does not contain all PK columns so delete operation can't be performed.");

            // Perform the delete.
            if (pkColumns.Count() == 1)       // Delete for table that has single primary key
            {             
                // Get primary key value
                int pk = int.Parse(row[pkColumns.First().ColumnName].ToString());

                // Perform delete
                DirectDelete(pk, UseLogicalDelete);
            }
            else if (pkColumns.Count() > 1)   // Delete for table that has multiple primary keys
            {
                // add each pk field to the parameter string
                StringBuilder parameters = new StringBuilder();    // sp parameters
                foreach (TableInfoRow column in pkColumns)
                    AddInputParam(parameters, column.ColumnName, row[column.ColumnName], GetTLDataType(column.GetNETType()));

                // Perform delete
                dblayer.ExecuteDeleteLinkSP(SessionInfo.SessionID, TableName, parameters.ToString(), false);
            }
        }

        /// <summary>
        /// Deletes a specified row directly from the database.
        /// There is not need to load in the row to use this method to delete it
        /// If the row being delete is alread loaded then it will be invalid, and any save operation will fail.
        /// </summary>
        /// <param name="pk">PK of row to delete</param>
        /// <param name="logicalDelete">If to perform a logical delete</param>
        public virtual void DirectDelete(int pk, bool logicalDelete)
        {
            dblayer.ExecuteDeleteSP(SessionInfo.SessionID, TableName, pk, logicalDelete);
        }

        /// <summary>
        /// Adds a input parameter to the string list.
        /// Parameters are added as xml nodes see ICW TRNRTL10.Transport.CreateInputParameterXML for more details
        /// </summary>
        /// <param name="parameters">List of parameters the new item will be added to</param>
        /// <param name="name">parameter name</param>
        /// <param name="value">parameter value</param>
        /// <param name="type">ICW type</param>
        protected internal void AddInputParam(StringBuilder parameters, string name, object value, Transport.trnDataTypeEnum type)
        {
            int length = BaseTable<T, C>.GetTLDataTypeSize(value, type); // Gets parameter length (depends on type)
            string strvalue;

            if (value == DBNull.Value)
                strvalue = null;                                            // If parameter is dataset null then set null
            else if (value.GetType().Name == "DateTime")
                strvalue = ((DateTime)value).ToString("yyyy-MM-ddTHH:mm:ss.fff");  // If parameter is datetime then format correctly
            else
                strvalue = value.ToString();                                // Convert all other parameters straight to string.

            // Add the parameter to list
            parameters.Append(dblayer.CreateInputParameterXML(name, type, length, strvalue));
        }
        protected internal void AddInputParam<A>(StringBuilder parameters, string name, A value)
        {
            Transport.trnDataTypeEnum type = BaseTable<T, C>.GetTLDataType(typeof(A));
            AddInputParam(parameters, name, value, type);
        }

        /// <summary>
        /// Adds a input parameter to the string list.
        /// Parameters are added as xml nodes see ICW TRNRTL10.Transport.CreateInputParameterXML for more details
        /// </summary>
        /// <param name="parameters">List of parameters the new item will be added to</param>
        /// <param name="spname">parameter name in the stored procedure being called</param>
        /// <param name="row">DataRow that contain the parameter</param>
        /// <param name="colname">column name in row of the data</param>
        protected internal void AddInputParam(StringBuilder parameters, string spname, DataRow row, string colname)
        {
            AddInputParam(parameters, spname, row[colname], GetTLDataType(row.Table.Columns[colname].DataType));
        }

        /// <summary>
        /// Adds a output parameter to the string list.
        /// Parameters are added as xml nodes see ICW TRNRTL10.Transport.CreateOutputParameterXML for more details
        /// </summary>
        /// <param name="parameters">List of parameters the new item will be added to</param>
        /// <param name="name">parameter name</param>
        protected void AddOutputParam(StringBuilder parameters, string name)
        {
            parameters.Append(dblayer.CreateOutputParameterXML(name, Transport.trnDataTypeEnum.trnDataTypeInt, 4));
        }

        /// <summary>
        /// Returns the ICW data type, from the .NET data type
        /// e.g. if type=Int32  returns tlDataTypeEnum.tlInt
        ///      if type=String returns tlDataTypeEnum.tlVarchar
        /// </summary>
        /// <param name="type">.NET type</param>
        /// <returns>ICW type</returns>
        protected static Transport.trnDataTypeEnum GetTLDataType(Type type)
        {
            switch (type.Name)
            {
                case "Byte":
                case "Int16":
                case "Int32": return Transport.trnDataTypeEnum.trnDataTypeInt;
                case "Decimal" : // ICW does not currently support decimal so use float for time being!
                case "Double": return Transport.trnDataTypeEnum.trnDataTypeFloat;
                case "Boolean": return Transport.trnDataTypeEnum.trnDataTypeBit;
                case "Char": return Transport.trnDataTypeEnum.trnDataTypeChar;
                case "DateTime": return Transport.trnDataTypeEnum.trnDataTypeDateTime;
                case "Guid": return Transport.trnDataTypeEnum.trnDataTypeUniqueIdentifier;
                case "StringBuilder":
                case "String": return Transport.trnDataTypeEnum.trnDataTypeVarChar;
                case "Object": return Transport.trnDataTypeEnum.trnDataTypeVarChar;
                case "Nullable`1": return GetTLDataType(Nullable.GetUnderlyingType(type));
            }

            throw new ApplicationException(string.Format("Unsupported type for BaseTable.GetTLDataType (type name {0}).", type.Name));
        }

        /// <summary>
        /// Returns the length of the the data type
        /// e.g. if type = tlDataTypeEnum.tlInt     returns 4
        ///      if type = tlDataTypeEnum.tlVarchar returns string length of value
        /// </summary>
        /// <typeparam name="A">value type</typeparam>
        /// <param name="value">Value (import if data type is a string)</param>
        /// <param name="type">ICW data type</param>
        /// <returns>length of the data type</returns>
        protected static int GetTLDataTypeSize<A>(A value, Transport.trnDataTypeEnum type)
        {
            switch (type)
            {
                case Transport.trnDataTypeEnum.trnDataTypeVarChar: return value.ToString().Length;
                case Transport.trnDataTypeEnum.trnDataTypeChar: return value.ToString().Length;
                case Transport.trnDataTypeEnum.trnDataTypeInt: return 4;
                case Transport.trnDataTypeEnum.trnDataTypeText: return value.ToString().Length;
                case Transport.trnDataTypeEnum.trnDataTypeFloat: return 8;
                case Transport.trnDataTypeEnum.trnDataTypeBit: return 1;
                case Transport.trnDataTypeEnum.trnDataTypeDateTime: return 8;
                case Transport.trnDataTypeEnum.trnDataTypeUniqueIdentifier: return 8;
            }

            throw new ApplicationException("Unsupported type for BaseTable.GetTLDataTypeSize.");
        }
        
        /// <summary>Instance verions of GetColumnInfo (used by Generic Table) 26Jul13 24653</summary>
        protected virtual C GetColumnInfo_InstanceVersion()
        {
            return GetColumnInfo();
        }
        #endregion

        #region IDisposable Members
        protected virtual void Dispose(bool disposing)
        {
            // If disposing rather than terminating then fress locks
            if (disposing)
                this.UnlockRows();
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
        #endregion

        #region IEnumerable<T> Members
        public IEnumerator<T> GetEnumerator()
        {
            return new BaseTableEnumerator<T, C>(this);
        }
        #endregion

        #region IEnumerable Members
        IEnumerator IEnumerable.GetEnumerator()
        {
            return new BaseTableEnumerator<T, C>(this);
        }
        #endregion
    }
}
