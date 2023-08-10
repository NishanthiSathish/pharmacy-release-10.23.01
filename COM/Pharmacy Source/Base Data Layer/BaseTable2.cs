//===========================================================================
//
//							        BaseTable2.cs
//
//	Base class for a class that represents a db table. 
//  This replace the BaseTable method, as it by-passes the transport layer.
//
//  Once db rows have been loaded into the class (via LoadBySP, LoadBySQL, 
//  or LoadFromXMLString), it can be used as an enumerable list of BaseRow items.
//
//  The class should be inherited from rather than being used directly.  
//
//  Derived classes will need to 
//      1. Provide LoadBy functions to load db rows, via an sp.
//      2. Define the associated derived BaseRow, and BaseColumnInfo classes to use.
//
//  Locking
//  -------
//  The class can support two forms of pharmacy locking, based on option RowLockingOption (default None)
//  HardLock - This adds the SessionId to the pharmacy SessionLock field on the table,
//             prevents another user from locking (at the same time)
//             If the fields are already lock by another will raise a LockException
//  SoftLock - This adds the rows ID to the SessionAttrbiute table, this allows multiple
//             users to lock the same row at the same time.
//             If a field is already locked by another user it will raise a SoftLockException (but will still lock all rows on the table)
//             (normaly used with ConflictOption = CompareAllSearchableValues see below)
//
//  Locks are only applied to data at the point of loadng, and will be removed when
//  new data is loaded, or Clear method is called, all when dispose is called.
//  If is possible to prevent unlocking of rows during dispose by setting PreventUnlockOnDispose = true (used when table data is cached)
//
//  ConflictOption
//  --------------
//  Normaly set to OverwriteChanges, but can used CompareAllSearchableValues.
//  When set to CompareAllSearchableValues, if another user had changed data since was last loaded, 
//  and the current user alters it a DBConcurrencyException is thrown
//      If local dataset field A is changed and db field B is changed by another user then data is saved without error
//      If local dataset field A is changed and db field A is changed by another user then save gives DBConcurrencyException
//
//  Usage:
//
//  public class WBatchStockLevel : BaseTable2<WBatchStockLevelRow, WBatchStockLevelColumnInfo>
//  {
//      public WBatchStockLevel() : base("WBatchStockLevel") { }
//
//      public void LoadBySiteIDAndNSVCode(int siteID, string NSVCode)
//      {
//          List<SqlParameter> parameters = new List<SqlParameter>();
//          parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID));  
//          parameters.Add(new SqlParameter("@LocationID_Site", siteID));   
//          parameters.Add(new SqlParameter("@NSVCode",NSVCode));
//          LoadBySp( "pWBatchStockLevelbySiteandNSVCode", parameters );
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
//  To declare classes that supports inheritance tables eg Person, Entity
//      public class EntityRow : BaseRow { }
//
//      public class EntityColumnInfo : BaseColumnInfo
//      {
//          public EntityColumnInfo() : base("Entity") { }
//
//          public EntityColumnInfo(string inheritiedTableName) : base(inheritiedTableName) { }
//      }    
//
//      public class Entity : BaseTable2<EntityRow, EntityColumnInfo>
//      {
//          public Entity() : base("Entity") { }
//      }
//
//  
//      public class PersonRow : EntityRow { }
//
//      public class PersonColumnInfo : EntityColumnInfo
//      {
//          public PersonColumnInfo() : base("Person") { }
//      }    
//
//      public class Person : BaseTable2<EntityRow, EntityColumnInfo>
//      {
//          public Entity() : base("Person", "Entity") { }
//      }
//      
//	Modification History:
//	20Oct11 XN  Written
//  15Nov12 XN  TFS47487 If called with default constructor, set a default table name
//  26Nov12 XN  SaveInheritedTables got audit log to save all hierarchy table information
//  03Apr12 XN  Added methods WriteXml, ReadXml
//  19Aug13 XN  Added audit logging to DirectDelete
//  02May13 XN  Added easier to use WriteXml, ReadXml for single tables (27038)
//  23May13 XN  Added extraExcludedColumns member to allow exclusion of extra columns (27038)
//  12Jul13 XN  Added SelectCommandTimeout (27038)
//  26Jul13 XN  Added GetColumnInfo_InstanceVersion and got class to use this method
//              instead of static GetColumnInfo (so Generic table can save) 24653
//  01Aug13 XN  In Save method if no Table object then returns 
//              (as load or createempty not called so no data to save) 24653
//  12Aug13 XN  Added SaveUsingBulkInsert method 24653
//  22Nov13 XN  Added support for pharmacy session locking 78339
//  10Feb14 XN  Update WriteXml, ReadXml to handle all class data
//              Update LoadFromDataSet to allow locking when appending row
//              Update SaveSingleTable and SaveInheritedTables so when doing opermistic locking 
//              (ConflictOption == CompareAllSearchableValues) only check columns that have been altered 56701
//  16Apr14 XN  Updated WriteToLog so replace non printable char 30 with xml escpated char (88858)
//  20Aug14 XN  Allowed connection string to be from different DB (added virtual property ConnectionString)
//  22Aug14 XN  Made LoadFromXMLString Obsolete as XML comes back different on some live servers
//  02Jun14 XN  Added FindByIDs 88935
//  24Jun14 XN  Replaced EnabledRowLocking with RowLockingOption 43318
//              Also added PreventUnlockOnDispose option
//  27Jun14 XN  Maded ExcludedColumns protected (88922)
//  20Nov14 XN  Fixed logical deletes
//  03Dec14 XN  Got CreateEmpty to call LockRows (so creates correct lock object)
//              LoadFromDataSet, LoadFromXMLString always call LockRows
//              SaveSingleTable will ensure new rows are locked when saved.
//  20Feb15 XN  Updated LoadFromDataSet and LoadFromXMLString to prevent double hard locking
//  08May15 XN  Update FindByID, and FindByIDs for changes in BaseRow (change field from static to instance for error handling improvements)
//  24Sep15 XN  Moved alias methods from SiteProductData to BaseTable2 77778
//  15Oct15 XN  Updated alias methods to user the base table name as most aliases are against the base table 77977 
//  18Nov15 XN  Added GetAllAliases and GetPKByAlias 133905
//  04Apr16 XN  fix using the aliasGroupID 149738 
//  08Apr16 XN  150046 Fix for the sort method
//  15Jul16 XN  126634 prevented crash if remove is passed a null
//  28Nov16 XN  147104 Made WriteToAudtiLog, and ExcludedColumns, public properties
//===========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using _Shared;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.basedatalayer
{
    /// <summary>BaseTable2 locking option 24Jun14 XN 43318</summary>
    public enum LockingOption
    {
        /// <summary>No locking</summary>
        None,

        /// <summary>
        /// Uses SessionAttribute table to perfrom lock.
        /// Means you can have multiple locks at the same time.
        /// Normally set ConflictOption = CompareAllSearchableValues
        /// Uses locking object LockResult
        /// </summary>
        SoftLock,

        /// <summary>
        /// Uses Session field on the table to perform the lock.
        /// So can only have one user lock at a time
        /// Uses locking object SoftLockResult
        /// </summary>
        HardLock,
    }

    public class BaseTable2<T,C> : IEnumerable<T>, IDisposable
        where T : BaseRow, new()
        where C : BaseColumnInfo, new()
    {
        #region Constants
        /// <summary>Name given to data set if no table name specified (uses lowercase to prevent mistaking it for Table table)</summary>
        private static readonly string DefaultTableName = "table";

        /// <summary>Suffix append to deleted items data set</summary>
        private static readonly string DeleteDataSetSuffix = "_DeletedItems";

        // protected static readonly string[] ExcludedColumns = new string[]{"_RowVersion",      28Nov16 XN 147104 made public
        /// <summary>Rows excluded from updates or inserts</summary>
        public static readonly string[] ExcludedColumns = new string[]{ "_RowVersion",      
                                                                        "_RowGUID",
                                                                        "_TableVersion",
                                                                        "_QA" };

        /// <summary>Column used for logical deletion (if UseLogicalDelete is true)</summary>
        private static readonly string LogicalDeletedColumn = "_Deleted";
        #endregion

        #region Member variables
        /// <summary>Name fo the delete items table</summary>
        private string deleteItemsTableName;

        /// <summary>PK column name if singe pk column (null if set yet, empty string if combined pk) don't call directly use GetPKColumnName()</summary>
        protected string pkColumnName = null;

        /// <summary>Dataset that contains all the rows (contains 2 table data table and deleted items table)</summary>
        private DataSet dataSet = new DataSet();

        /// <summary>
        /// List of tables the class relates to {normally only 1, but maybe more for inheritied tables} 
        /// Should be in order of base table first in list (eg Request table id first)
        /// </summary>
        private List<string> tableNames = new List<string>();
        
        /// <summary>Class used to handle locking 22Nov13 XN 78339</summary>
        private LockResults lockResults = null;

        /// <summary>
        /// Table sepcific exclude columns beyond the standard ExcludedColumns
        /// Column will still existing in ds just not be inserted or updated
        /// Won't work well with inherited tables, as excludes any column with the name (even from inherited tables)
        /// XN 23May13 (27038)
        /// </summary>
        protected List<string> extraExcludedColumns = new List<string>();

        //protected bool writeToAudtiLog = true;   28Nov16 XN 147104 Made public
        #endregion

        #region Properties
        /// <summary>DB table name (or view) the class relates to</summary>
        public string TableName { get { return tableNames.Last(); } }

        /// <summary>Returns number of rows loaded.</summary>
        public int Count
        {
            get { return (Table != null) ? Table.Rows.Count : 0; }
        }

        /// <summary>Provides access to the under lying dataset table</summary>
        public DataTable Table { get; private set; }

        /// <summary>Provides access to the underlying deleted items dataset table</summary>
        public DataTable DeletedItemsTable { get; private set; }

        /// <summary>Locking method to perform for the table 24Jun14 XN 43318</summary>
        public LockingOption RowLockingOption { get; set; }
        //public bool EnabledRowLocking { get; set; }   24Jun14 XN 43318

        /// <summary>Prevents unlocking of rows when list is disposed (used when data is cached) 24Jun14 XN 43318</summary>
        public bool PreventUnlockOnDispose { get; set; }

        /// <summary>If table uses logical deletes</summary>
        protected bool UseLogicalDelete { get; set; }

        /// <summary>
        /// If save should perform concurrency checks on update or delete (default is off)
        /// This is where the update or delete errors if it tries to save a row that has been modified since last loaded.
        /// </summary>
        public ConflictOption ConflictOption { get; set; }
        //protected ConflictOption ConflictOption { get; set; } 10Feb14 XN 56701

        /// <summary>Set the timeout used by table for all select statments (otherwise uses system default) in seconds</summary>
        protected int? SelectCommandTimeout { get; set; }

        /// <summary>Allows derived classes to provide alternate insert command</summary>
        virtual protected string AlternateInsertCommand { get { return string.Empty; } }

        /// <summary>Allows derived classes to provide alternate update command</summary>
        virtual protected string AlternateUpdateCommand { get { return string.Empty; } }

        /// <summary>Allows derived classes to provide alternate delete command</summary>
        virtual protected string AlternateDeleteCommand { get { return string.Empty; } }
        
        /// <summary>If insert, update, delete operations should be written to the icw AuditLog table 28Nov16 XN 147104 made public</summary>
        public bool WriteToAudtiLog { get; set; }
        #endregion
    
        #region Constructors
        /// <summary>Constructor</summary>
        /// <param name="tableName">Name of db table class is associated with</param>
        /// <param name="inheritiedTableNames">List of inherited tables names the base tabe should be last in list (e.g. "EpisodeOrder", "Request")</param>
        public BaseTable2 (string tableName, params string[] inheritiedTableNames)
	    {
            this.tableNames = new List<string>();
            this.tableNames.AddRange(inheritiedTableNames.Reverse());
            this.tableNames.Add(tableName);

            this.deleteItemsTableName     = this.TableName + DeleteDataSetSuffix;
            this.UseLogicalDelete         = false;
            this.Table                    = null;
            this.DeletedItemsTable        = null;
            this.ConflictOption           = ConflictOption.OverwriteChanges;
            //this.EnabledRowLocking        = false;   24Jun14 XN 43318
            this.RowLockingOption         = LockingOption.None;
            this.PreventUnlockOnDispose   = false;
            this.lockResults              = new LockResults(tableName);
            this.WriteToAudtiLog          = true;
	    }

        /// <summary>Constructor</summary>
        /// <param name="tableName">Name of db table class is associated with</param>
        public BaseTable2 (string tableName)
	    {
            if (string.IsNullOrEmpty(tableName))    // 15Nov12 XN  TFS47487 Set a default table name if none provided
                tableName = "BaseTable2";

            this.tableNames = new List<string>();
            this.tableNames.Add(tableName);

            this.deleteItemsTableName     = this.TableName + DeleteDataSetSuffix;
            this.UseLogicalDelete         = false;
            this.Table                    = null;
            this.DeletedItemsTable        = null;
            this.ConflictOption           = ConflictOption.OverwriteChanges;
            //this.EnabledRowLocking        = false;   24Jun14 XN 43318
            this.RowLockingOption         = LockingOption.None;
            this.PreventUnlockOnDispose   = false;
            this.lockResults              = new LockResults(tableName);
            this.WriteToAudtiLog          = true;
	    }

        public BaseTable2 ()
	    {
            this.tableNames               = new List<string>() { "BaseTable2" };    // 15Nov12 XN  TFS47487 Set a default table name
            this.deleteItemsTableName     = this.TableName + DeleteDataSetSuffix;
            this.UseLogicalDelete         = false;
            this.Table                    = null;
            this.DeletedItemsTable        = null;
            this.ConflictOption           = ConflictOption.OverwriteChanges;
            //this.EnabledRowLocking        = false;   24Jun14 XN 43318
            this.RowLockingOption         = LockingOption.None;
            this.PreventUnlockOnDispose   = false;
            this.lockResults              = new LockResults(string.Empty);
            this.WriteToAudtiLog          = true;
        }
        #endregion

        ~BaseTable2()
        {
            Dispose(false);
        }

        #region Public Methods
        /// <summary>Saves any changes (since last call to LoadBy or Save) to the database.</summary>
        public virtual void Save()
        {
            // Check valid table name has been supplied
            if (this.TableName == DefaultTableName)
                throw new ApplicationException("You have not provided a table name in the BaseTable2 class constructor, so Save method will not work.");

            // If no table then class has not been initalised with a load or create empty so nothing to save 01Aug13 XN 24653
            if (this.Table == null)
                return;

            // Save method depends on if we are saving a single table, or an inherited table
            if (this.tableNames.Count == 1)
                SaveSingleTable();
            else
                SaveInheritedTables();
        }

        /// <summary>
        /// Performs a bulk insert on the table data.
        /// Will NOT write the info to the AuditLog.
        /// Will NOT Update the pk of the inserted rows 
        /// Will NOT perform any delete or update operations on the DB data
        /// </summary>
        public virtual void SaveUsingBulkInsert()
        {
            // Check valid table name has been supplied
            if (this.TableName == DefaultTableName)
                throw new ApplicationException("You have not provided a table name in the BaseTable2 class constructor, so Save method will not work.");

            // If no table then class has not been initalised with a load or create empty so nothing to save 01Aug13 XN 24653
            if (this.Table == null)
                return;

            if (this.tableNames.Count != 1)
                throw new ApplicationException("Currently only support buil insert for single tables.");

            if (this.WriteToAudtiLog)
                throw new ApplicationException("Bulk insert will not write to audit log (in derived class set this.writeToAudtiLog = false).");

            SqlBulkCopy bulkCopy = new SqlBulkCopy(this.ConnectionString);
            bulkCopy.DestinationTableName = this.TableName;
            bulkCopy.WriteToServer(this.Table); // Did to test if the SqlBulkCopy.WriteToServer Accepts the changes in the dataset after the update assuemd it does
        }

        /// <summary>Removes all data from dataset (will not save changes)</summary>
        public void Clear()
        {
            // clear all locks (22Nov13 XN 78339)
            this.UnlockRows();
            
            if (this.DeletedItemsTable != null)
            {
                this.DeletedItemsTable.Clear();
                this.dataSet.Tables.Remove(this.DeletedItemsTable);
            }
            this.DeletedItemsTable = null;

            if (this.Table != null)
            {
                this.Table.Clear();
                this.dataSet.Tables.Remove(this.Table);
            }
            this.Table = null;

            this.dataSet.Clear();
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
            columnInfo = PharmacyDataCache.GetFromContext(cachedName) as C;
            if (columnInfo == null)
            {
                columnInfo = new C();
                PharmacyDataCache.SaveToContext(cachedName, columnInfo);
            }

            // If column info data not loaded then load
            if (!columnInfo.IsLoaded)
                columnInfo.LoadColumnInfo();

            // Return results
            return columnInfo;
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
            if (item == null)   // 15Jul16 XN 126634 Added
                return;         

            DataRowState orignalState = item.RawRow.RowState;

            if (orignalState != DataRowState.Added)
            {
                if (this.UseLogicalDelete)
                    item.RawRow[LogicalDeletedColumn] = true;
                else
                    item.RawRow.Delete();

                DeletedItemsTable.ImportRow(item.RawRow);
            }
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

        /// <summary>Unlocks all the existing rows (22Nov13 XN 78339)</summary>
        public void UnlockRows()
        {
            if (lockResults != null)
                lockResults.UnlockRows();   // Might be null if called from dispaose and PreventUnlockOnDispose=true 24Jun14 XN 43318
        }

        /// <summary>
        /// Sorts the row as specified
        /// This method should only really be used straight after a load.
        /// </summary>
        /// <param name="orderby">string that contains column names and "ASC" or "DESC"</param>
        public void Sort(string orderby)
        {
            // Create a view of a table and sort it
            DataView view = new DataView(this.Table);
            view.Sort = orderby;

            // Remove the old unsorted table from the dataset
            this.dataSet.Tables.Remove(this.Table);

            // Get the sorted table from the view and assign it back to the dataset
            DataTable table = view.ToTable();
            table.TableName = this.TableName;
            this.dataSet.Tables.Add(table);

            // Update table XN 8Apr16 150046 
            this.Table = this.dataSet.Tables[this.TableName];
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
            // Check valid table name has been supplied
            if (this.TableName == DefaultTableName)
                throw new ApplicationException("You have not provided a table name in the BaseTable2 class constructor, so DirectDelete method will not work.");

            // Create the SQL string
            string sql;
            if (logicalDelete)
                sql = string.Format("UPDATE [{0}] SET [{1}]=1 WHERE [{2}]={3}", this.TableName, LogicalDeletedColumn, this.GetPKColumnName(), pk);
            else
                sql = string.Format("DELETE FROM [{0}] WHERE [{1}]={2}", this.TableName, this.GetPKColumnName(), pk);

            // Perform the delete
            using (SqlConnection sqlConnection = new SqlConnection(this.ConnectionString))
            {
                sqlConnection.Open();
                using (SqlCommand sqlCommand = new SqlCommand(sql, sqlConnection))
                    sqlCommand.ExecuteNonQuery();
                sqlConnection.Close();

                // write to log
                try
                {
                    if (logicalDelete)
                        AuditLog.Write(this.TableName, pk, 0, AuditLogType.Update, string.Format("<{0} {1}=\"1\" />", this.TableName, LogicalDeletedColumn));
                    else
                        AuditLog.Write(this.TableName, pk, 0, AuditLogType.Delete, string.Empty);
                }
                catch (Exception ex)
                {
#if DEBUG
                    throw ex;   // Don't want simple thing like locking of audit log table to effect rest of app so ignore error in production
#endif
                }
            }
        }

        /// <summary>Copies the data from rows to this item</summary>
        /// <param name="row">source to copy from</param>
        public void CopyFrom(IEnumerable<T> rows)
        {
            foreach (T row in rows)
                this.Add().CopyFrom(row);
        }

        /// <summary>
        /// Adds a input parameter to the SQLParameter list.
        /// This tries to provide a direct replacement for BaseTable.AddInputParam.
        /// </summary>
        /// <param name="parameters">List of parameters the new item will be added to</param>
        /// <param name="name">parameter name</param>
        /// <param name="value">parameter value</param>
        /// <param name="type">ICW type</param>
        protected internal void AddInputParam<A>(IList<SqlParameter> parameters, string name, A value)
        {
            parameters.Add(new SqlParameter(name, value));
        }
        
        /// <summary>Get the PK column name</summary>
        /// <returns>PK column name</returns>
        public string GetPKColumnName()
        {
            if (this.pkColumnName == null)
            {
                // Check valid table name has been supplied
                if (this.TableName == DefaultTableName)
                    throw new ApplicationException("You have not provided a table name in the BaseTable2 class constructor, so GetPKColumnName method will not work.");

                // Get the table info (read directly from db or web cache)
                TableInfo tableInfo = this.GetColumnInfo_InstanceVersion().tableInfo;
                if (tableInfo.Count == 0)
                    throw new ApplicationException(string.Format("Failed to get table schema for '{0}'", this.TableName));
                
                IEnumerable<TableInfoRow> pks = tableInfo.Where(r => r.IsPK);
                this.pkColumnName = (pks.Count() != 1) ? string.Empty : pks.First().ColumnName;
            }
            
            return this.pkColumnName;
        }
        
        /// <summary>
        /// Read the TableID from the ICW [Table] table.
        /// Once read values are cached.
        /// If this table does not exists in ICW [Table] property will assert.
        /// </summary>
        public int GetTableID()
        {
            string cacheName = string.Format("{0}.TableID['{1}']", this.GetType().FullName, TableName);

            if (this.TableName == DefaultTableName)
                throw new ApplicationException("You have not provided a table name in the BaseTable2 class constructor, so GetTableID method will not work.");

            // Try reading the value from the cache
            int? tableID = (int?)PharmacyDataCache.GetFromCache(cacheName);
            if (!tableID.HasValue)
            {
                // Read the value from the ICW [Table] (asserts if not present
                tableID = TableInfo.GetTableID(TableName);

                // Cache the value for future reference.
                PharmacyDataCache.SaveToCache(cacheName, tableID.Value);
            }

            return tableID.Value;
        }

        /// <summary>Writes the dataset to XML (as a XmlWriteMode.DiffGram) 3Apr13 XN</summary>
        /// <param name="writer">XML writer to use</param>
        public void WriteXml(XmlWriter writer)
        {
            writer.WriteStartElement("BaseTable2"); // 10Feb14 XN 56701 Added
            //writer.WriteAttributeString("EnabledRowLocking", this.EnabledRowLocking.ToOneZeorString()); // 10Feb14 XN 56701 Added
            writer.WriteAttributeString("RowLockingOption",        this.RowLockingOption.ToString()             );  // 19Jun14 XN 43318 Added
            writer.WriteAttributeString("PreventUnlockOnDispose",  this.PreventUnlockOnDispose.ToOneZeorString());  // 24Jun14 XN 43318 Added
            writer.WriteAttributeString("ConflictOption",          this.ConflictOption.ToString()               );  // 10Feb14 XN 56701 Added
            this.dataSet.WriteXmlSchema(writer);
            this.dataSet.WriteXml(writer, XmlWriteMode.DiffGram);
            this.lockResults.WriteXml(writer);  // 10Feb14 XN 56701 Added
            writer.WriteEndElement();
        }
        public string WriteXml()
        {
            // Setup to write xml fragment
            XmlWriterSettings settings = new XmlWriterSettings();
            settings.Indent             = false;
            settings.OmitXmlDeclaration = true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Write xml string
            StringBuilder str = new StringBuilder();
            using(XmlWriter writer = XmlWriter.Create(str, settings))
            {
                WriteXml(writer);
                writer.Flush();
                writer.Close();
            }

            return str.ToString();
        }

        /// <summary>Reads dataset from XML (assumes the data was written using WriteXml) 3Apr13 XN</summary>
        /// <param name="reader">XML reader to use</param>
        public void ReadXml(XmlReader reader)
        {
            this.Clear();
            //this.EnabledRowLocking = BoolExtensions.PharmacyParse(reader.GetAttribute("EnabledRowLocking"));                   // 10Feb14 XN 56701 Added
            this.RowLockingOption       = (LockingOption) Enum.Parse(typeof(LockingOption),  reader.GetAttribute("RowLockingOption")); // 19Jun14 XN 43318 Added
            this.PreventUnlockOnDispose = BoolExtensions.PharmacyParse(reader.GetAttribute("PreventUnlockOnDispose"));                 // 24Jun14 XN 43318 Added
            this.ConflictOption         = (ConflictOption)Enum.Parse(typeof(ConflictOption), reader.GetAttribute("ConflictOption"));   // 10Feb14 XN 56701 Added
            reader.Read();  // Move to first child
            this.dataSet.ReadXmlSchema(reader);
            this.dataSet.ReadXml(reader, XmlReadMode.DiffGram);
            //this.lockResults.ReadXml(reader);   // 10Feb14 XN 56701 Added
            this.lockResults = LockResults.Create(reader);   // 24Jun14 XN 43318 Create locking option of correct type   10Feb14 XN 56701 Added
            this.Table             = this.dataSet.Tables[this.TableName           ];
            this.DeletedItemsTable = this.dataSet.Tables[this.deleteItemsTableName];
            reader.Read();  // Move to next node
        }
        public void ReadXml(string xml)
        {
            if (string.IsNullOrEmpty(xml))
            {
                CreateEmpty();
                return;
            }

            // Setup string as XML fragment
            XmlReaderSettings settings = new XmlReaderSettings();
            settings.ConformanceLevel = ConformanceLevel.Fragment;

            // Read xml string
            using (XmlReader reader = XmlReader.Create(new StringReader(xml), settings))
            {
                reader.Read();  // Read to first node
                ReadXml(reader);
            }
        }
        
        /// <summary>Gets single alias from {TableName}Alias (select Default items first then non-Default) 24Sep15 XN 77778</summary>
        /// <param name="id">Primary key id</param>
        /// <param name="aliasGroup">Alias group</param>
        /// <returns>Returns the alias</returns>
        public R GetAlias<R>(int id, string aliasGroup)
        {
            string baseTableName = this.tableNames.First(); // 15Oct15 XN 77977 Use base table name

            // Get the group Id
            int? aliasGroupId = Database.ExecuteSQLScalar<int?>("SELECT AliasGroupID FROM AliasGroup WHERE Description='{0}'", aliasGroup);
            if (aliasGroupId == null)
            {
                throw new ApplicationException("Invalid alias group '" + aliasGroup + "'");
            }

            // get pk column
            string pkcolumnName = this.GetPKColumnName();
            if (string.IsNullOrEmpty(pkcolumnName))
            {
                throw new ApplicationException("Table " + this.TableName + " does not have a primary key column");
            }

            return Database.ExecuteSQLScalar<R>("SELECT TOP 1 Alias FROM [{0}Alias] WHERE [{1}]={2} AND AliasGroupID={3} ORDER BY [Default] DESC", baseTableName, pkcolumnName, id, aliasGroupId);
        }

        /// <summary>Gets multiple alias from {TableName}Alias (order by Default items first then non-Default) 24Sep15 XN 77778</summary>
        /// <param name="id">Primary key id</param>
        /// <param name="aliasGroup">Alias group</param>
        /// <returns>Returns the aliases</returns>
        public IEnumerable<R> GetAliases<R>(int id, string aliasGroup)
        {
            string baseTableName = this.tableNames.First(); // 15Oct15 XN 77977 Use base table name

            // Get the group Id
            int? aliasGroupId = Database.ExecuteSQLScalar<int?>("SELECT AliasGroupID FROM AliasGroup WHERE Description='{0}'", aliasGroup);
            if (aliasGroupId == null)
            {
                throw new ApplicationException("Invalid alias group '" + aliasGroup + "'");
            }

            // get pk column
            string pkcolumnName = this.GetPKColumnName();
            if (string.IsNullOrEmpty(pkcolumnName))
            {
                throw new ApplicationException("Table " +  this.TableName + " does not have a primary key column");
            }

            //return Database.ExecuteSQLSingleField<R>("SELECT Alias FROM [{0}Alias] WHERE [{1}]={2} AND AliasGroupID={3} ORDER BY [Default] DESC", baseTableName, pkcolumnName, id, aliasGroup); 4Apr16 XN 149738 fix using the aliasGroupID
            return Database.ExecuteSQLSingleField<R>("SELECT Alias FROM [{0}Alias] WHERE [{1}]={2} AND AliasGroupID={3} ORDER BY [Default] DESC", baseTableName, pkcolumnName, id, aliasGroupId);
        }

        /// <summary>Get all aliases for from {TableName}Alias 17Nov15 XN 38321</summary>
        /// <param name="id">Primary key id</param>
        /// <returns>dictionary of alias group to value</returns>
        public IDictionary<string,string> GetAllAliases(int id)
        {
            string baseTableName = this.tableNames.First();

            // get pk column
            string pkcolumnName = this.GetPKColumnName();
            if (string.IsNullOrEmpty(pkcolumnName))
            {
                throw new ApplicationException("Table " +  this.TableName + " does not have a primary key column");
            }

            GenericTable2 alias = new GenericTable2(this.TableName);
            alias.LoadBySQL("SELECT Alias, Value FROM [{0}Alias] WHERE [{1}]={2} AND [Default]=1", baseTableName, pkcolumnName, id);
            return alias.ToDictionary(r => r.RawRow["Alias"].ToString(), r => r.RawRow["Value"].ToString());
        }

        /// <summary>
        /// Return the first PK value that has the alias.
        /// Will only ever return the first item ordered by default desc, then pk desc
        /// 18Nov15 XN 133905
        /// </summary>
        /// <param name="aliasGroup">Alias group</param>
        /// <param name="alias">Alias</param>
        /// <returns>PK or null if not found</returns>
        public int? GetPKByAlias(string aliasGroup, string alias)
        {
            string baseTableName = this.tableNames.First(); // 15Oct15 XN 77977 Use base table name

            // Get the group Id
            int? aliasGroupId = Database.ExecuteSQLScalar<int?>("SELECT AliasGroupID FROM AliasGroup WHERE Description='{0}'", aliasGroup);
            if (aliasGroupId == null)
            {
                throw new ApplicationException("Invalid alias group '" + aliasGroup + "'");
            }

            // get pk column
            string pkcolumnName = this.GetPKColumnName();
            if (string.IsNullOrEmpty(pkcolumnName))
            {
                throw new ApplicationException("Table " +  this.TableName + " does not have a primary key column");
            }

            return Database.ExecuteSQLScalar<int?>("SELECT TOP 1 {0} FROM {1}Alias WHERE Alias='{2}' AND AliasGroupID={3} ORDER BY [Default] desc, {0} Desc", pkcolumnName, baseTableName, alias, aliasGroupId);
        }

        /// <summary>Adds an alias to SiteProductDataAlias (does not check if it already existing) 24Sep15 XN 77778</summary>
        /// <param name="id">Primary key id</param>
        /// <param name="aliasGroup">Alias group name</param>
        /// <param name="alias">Alias to add</param>
        /// <param name="isDefault">If default</param>
        public void AddAlias(int id, string aliasGroup, string alias, bool isDefault)
        {
            this.AddAlias(id, aliasGroup, new [] { alias }, isDefault);
        }

        /// <summary>Adds multiple alias to SiteProductDataAlias (does not check if it already existing) 24Sep15 XN 77778</summary> 
        /// <param name="id">Primary key id</param>
        /// <param name="aliasGroup">Alias group name</param>
        /// <param name="aliases">Add aliases</param>
        /// <param name="isDefault">If default</param>
        public void AddAlias(int id, string aliasGroup, string[] aliases, bool isDefault)
        {
            string baseTableName = this.tableNames.First(); // 15Oct15 XN 77977 Use base table name

            // Get the group Id
            int? aliasGroupId = Database.ExecuteSQLScalar<int?>("SELECT AliasGroupID FROM AliasGroup WHERE Description='{0}'", aliasGroup);
            if (aliasGroupId == null)
            {
                throw new ApplicationException("Invalid alias group '" + aliasGroup + "'");
            }

            // get pk column
            string pkcolumnName = this.GetPKColumnName();
            if (string.IsNullOrEmpty(pkcolumnName))
            {
                throw new ApplicationException("Table " +  this.TableName + " does not have a primary key column");
            }

            // And save
            GenericTable2 siteProductDataAlias = new GenericTable2(baseTableName + "Alias");
            foreach (string a in aliases)
            {
                BaseRow newRow = siteProductDataAlias.Add();
                newRow.RawRow[pkcolumnName  ] = id;
                newRow.RawRow["AliasGroupID"] = aliasGroupId;
                newRow.RawRow["Alias"       ] = a;
                newRow.RawRow["Default"     ] = isDefault;
            }
            siteProductDataAlias.Save();
        }

        /// <summary>Removes all alias by AliasGroup description 24Sep15 XN 77778</summary>
        /// <param name="id">Primary key id</param>
        /// <param name="aliasGroup">alias group</param>
        public void RemoveAllAliasByAliasGroup(int id, string aliasGroup)
        {
            string baseTableName = this.tableNames.First(); // 15Oct15 XN 77977 Use base table name

            // Get alias group ID
            int? aliasGroupId = Database.ExecuteSQLScalar<int?>("SELECT AliasGroupID FROM AliasGroup WHERE Description='{0}'", aliasGroup);
            if (aliasGroupId == null)
            {
                throw new ApplicationException("Invalid alias group '" + aliasGroup + "'");
            }

            // get pk column
            string pkcolumnName = this.GetPKColumnName();
            if (string.IsNullOrEmpty(pkcolumnName))
            {
                throw new ApplicationException("Table " +  this.TableName + " does not have a primary key column");
            }

            // Delete existing items
            GenericTable2 siteProductDataAlias = new GenericTable2(baseTableName + "Alias");
            siteProductDataAlias.LoadBySQL("SELECT * FROM [{0}Alias] WHERE [{1}]={2} AND AliasGroupID={3}", baseTableName, pkColumnName, id, aliasGroupId);
            siteProductDataAlias.RemoveAll();
            siteProductDataAlias.Save();
        }

        /// <summary>Removes by alias group and value 24Sep15 XN 77778</summary>
        /// <param name="aliasGroup">alias group</param>
        /// <param name="alias">alias value</param>
        public void RemoveAlias(string aliasGroup, string alias)
        {
            string baseTableName = this.tableNames.First(); // 15Oct15 XN 77977 Use base table name

            // Get alias group ID
            int? aliasGroupId = Database.ExecuteSQLScalar<int?>("SELECT AliasGroupID FROM AliasGroup WHERE Description='{0}'", aliasGroup);
            if (aliasGroupId == null)
            {
                throw new ApplicationException("Invalid alias group '" + aliasGroup + "'");
            }

            // Delete existing items
            GenericTable2 siteProductDataAlias = new GenericTable2(baseTableName + "Alias");
            siteProductDataAlias.LoadBySQL("SELECT * FROM [{0}Alias] WHERE Alias='{1}' AND AliasGroupID={2}", baseTableName, alias, aliasGroupId);
            siteProductDataAlias.RemoveAll();
            siteProductDataAlias.Save();
        }
        #endregion

        #region Protected Methods
        /// <summary>
        /// Initialises the class for use without the need to call a LoadBy method.
        /// When called will 
        ///     1. Remove all existing data (ignoring any changes).
        ///     2. Reads in table information from database to initialise the dataset
        /// The Add function will calls this when needed.
        /// </summary>
        protected virtual void CreateEmpty()
        {
            // Remove all existing data
            Clear();

            if (this.tableNames.Count == 1)
            {
                // Single table do simple fill schema
                string sql = "SELECT * FROM [" + this.TableName + "]";
                using (SqlDataAdapter dataAdapter = new SqlDataAdapter(sql, this.ConnectionString))
                    dataAdapter.FillSchema(this.dataSet, SchemaType.Source, this.TableName);
                
                Table = this.dataSet.Tables[this.TableName];
            }
            else
            {
                // Inherited table data

                // Gets or creates an active table
                if (Table == null)
                    Table = this.dataSet.Tables.Add(this.TableName);

                string pkName = this.GetPKColumnName();
                if (string.IsNullOrEmpty(pkName))
                    throw new ApplicationException(string.Format("Can't load an inherited DB table if table has multiple PKs (for table '{0}')", this.TableName));

                StringBuilder sql = new StringBuilder();
                sql.AppendFormat("SELECT * FROM [{0}] a", this.tableNames.First());
                foreach(string tableName in this.tableNames.Skip(1))
                    sql.AppendFormat(" JOIN [{0}] ON a.[{1}] = [{0}].[{1}]", tableName, pkName);

                // get data set for each table
                using (SqlDataAdapter dataAdapter = new SqlDataAdapter(sql.ToString(), this.ConnectionString))
                    dataAdapter.FillSchema(this.dataSet, SchemaType.Source, this.TableName);
            
                Table = this.dataSet.Tables[this.TableName];
            }

            // Remove excluded columne from the table
            foreach (string colName in ExcludedColumns)
            {
                if (Table.Columns.Contains(colName))
                    Table.Columns.Remove(colName);
            }

            // Creats an empty delete table if required
            this.DeletedItemsTable           = Table.Clone();
            this.DeletedItemsTable.TableName = this.deleteItemsTableName;
            this.dataSet.Tables.Add(this.DeletedItemsTable);

            // Works better if constraints are not enforced
            this.dataSet.EnforceConstraints = false;

            // Call lock rows, so create correct locking object (as currently nothing to lock!!!)
            this.LockRows(false, Table);
        }

        /// <summary>
        /// Loads in data from a SQL string that returns datasets.
        /// The SQL string should return a singe table dataset
        /// Unless append flag is set, exists records are removed (changes will not be saved)
        /// </summary>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL string formating parameters</param>
        protected void LoadBySQL(string sql, params object[] parameters)
        {
            LoadFromDataSet(false, string.Format(sql, parameters), (IEnumerable<SqlParameter>)null, CommandType.Text);
        }

        /// <summary>
        /// Loads in data from a SQL string that returns datasets.
        /// The SQL string should return a singe table dataset
        /// Unless append flag is set, exists records are removed (changes will not be saved)
        /// </summary>
        /// <param name="append">If data is to be appended</param>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL string formating parameters</param>
        protected void LoadBySQL(bool append, string sql, params object[] parameters)
        {
            LoadFromDataSet(append, string.Format(sql, parameters), (IEnumerable<SqlParameter>)null, CommandType.Text);
        }

        /// <summary>
        /// Loads in data from a SQL string that returns datasets.
        /// The SQL string should return a singe table dataset
        /// Unless append flag is set, exists records are removed (changes will not be saved)
        /// </summary>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL Parameters for the SQL command</param>
        protected void LoadBySQL(string sql, IEnumerable<SqlParameter> parameters)
        {
            LoadFromDataSet(false, sql, parameters, CommandType.Text);
        }

        /// <summary>
        /// Loads in data from a SQL string that returns datasets.
        /// The SQL string should return a singe table dataset
        /// Unless append flag is set, exists records are removed (changes will not be saved)
        /// </summary>
        /// <param name="append">If data is to be appended</param>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL Parameters for the SQL command</param>
        protected void LoadBySQL(bool append, string sql, IEnumerable<SqlParameter> parameters)
        {
            LoadFromDataSet(append, sql, parameters, CommandType.Text);
        }

        /// <summary>
        /// Loads in data from a sp that returns datasets.
        /// The sp should return a singe table dataset
        /// Unless append flag is set, exists records are removed (changes will not be saved)
        /// </summary>
        /// <param name="sp">sp Name</param>
        /// <param name="parameters">SQL Parameters for the SQL command</param>
        protected void LoadBySP(string sp, IEnumerable<SqlParameter> parameters)
        {
            LoadFromDataSet(false, sp, parameters, CommandType.StoredProcedure);
        }

        /// <summary>
        /// Loads in data from a sp that returns datasets.
        /// The sp should return a singe table dataset
        /// Unless append flag is set, exists records are removed (changes will not be saved)
        /// </summary>
        /// <param name="append">If data is to be appended</param>
        /// <param name="sp">sp</param>
        /// <param name="parameters">SQL Parameters for the SQL command</param>
        protected void LoadBySP(bool append, string sp, IEnumerable<SqlParameter> parameters)
        {
            LoadFromDataSet(append, sp, parameters, CommandType.StoredProcedure);
        }

        /// <summary>
        /// Loads in data from a stored procedure, or SQL string, that returns datasets.
        /// The stored procedure, or SQL string, should return a singe table dataset
        /// Unless append flag is set, exists records are removed (changes will not be saved)
        /// </summary>
        /// <param name="append">If data is to be appended</param>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL Parameters for the SQL command</param>
        /// <param name="commandType">Command type the sql string represents</param>
        protected void LoadFromDataSet(bool append, string sql, IEnumerable<SqlParameter> parameters, CommandType commandType)
        {
//            if (append && this.EnabledRowLocking) 10Feb14 XN 56701 Allow locking in append mode
//                throw new ApplicationException("Can't currently append data when using row locking in BaseTable2");

            if (!append)
                Clear();

            using (SqlDataAdapter dataAdapter = new SqlDataAdapter(sql, this.ConnectionString))
            {
                // Works better if constraints are not enforced
                this.dataSet.EnforceConstraints = false;

                dataAdapter.SelectCommand.CommandType = commandType;
                if (this.SelectCommandTimeout != null)
                    dataAdapter.SelectCommand.CommandTimeout = this.SelectCommandTimeout.Value;
                if (parameters != null)
                    dataAdapter.SelectCommand.Parameters.AddRange(parameters.ToArray());

                //dataAdapter.Fill(this.dataSet, this.TableName); 10Feb14 XN 56701 Allow locking in append mode
                DataSet ds = new DataSet(); // Store in temp ds so can have locking of appended data
                dataAdapter.Fill(ds, this.TableName);

                // If locking enabled then lock the rows (22Nov13 XN 78339)
                // if (this.EnabledRowLocking)  19Jun14 XN 43318
                if (this.RowLockingOption == LockingOption.HardLock)
                {
                    using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                    {
                        // lock the rows
                        //this.lockResults.LockRows(this.dataSet.Tables[0]); 10Feb14 XN 56701
                        //this.lockResults.LockRows(ds.Tables[0]); 19Jun14 XN Added soft locking 43318
                        LockRows(append, ds.Tables[0]);

                        // reload the data (incase things have changed since lock)
                        //this.dataSet.Clear(); 10Feb14 XN 56701 Allow locking in append mode
                        //dataAdapter.Fill(this.dataSet, this.TableName);
                        ds.Clear();
                        dataAdapter.Fill(ds, this.TableName);

                        scope.Commit();
                    }
                }

                this.dataSet.Merge(ds.Tables[0]);   // 10Feb14 XN 56701 Allow locking in append mode
                ds.Dispose();

                this.Table = this.dataSet.Tables[this.TableName];

                // Creats an empty delete table if required
                if (this.DeletedItemsTable == null)
                {
                    this.DeletedItemsTable = Table.Clone();
                    this.DeletedItemsTable.TableName = this.deleteItemsTableName;
                    this.dataSet.Tables.Add(this.DeletedItemsTable);
                }

                // if soft locking is enabled implement 19Jun14 XN Added soft locking 43318
                // 20Feb15 XN readded as for hard lock could end up double locking     03Dec14 Locking determine if needs to be called
                if (this.RowLockingOption == LockingOption.SoftLock) 
                {
                    this.LockRows(append, this.Table);
                }
            }
        }

        /// <summary>
        /// Loads in data from a stored procedure that returns XML.
        /// The stored procedure should return a single table XML string (non nested xml).
        /// SQL should be in the form "SELECT * FROM Entity WHERE EntityID={0} FOR XML AUTO"
        /// </summary>
        /// <param name="sp">Stored procedure name</param>
        /// <param name="parameters">Parameters in the stored procedure</param>
        [Obsolete]
        protected void LoadFromXMLString(string sql, params object[] parameters)
        {
            Clear();

            string formattedSQL = string.Format(sql, parameters);

            using (SqlConnection sqlConnection = new SqlConnection(this.ConnectionString))
            {
                // Works better if constraints are not enforced
                this.dataSet.EnforceConstraints = false;

                using (SqlCommand sqlCommand = new SqlCommand(formattedSQL, sqlConnection))
                {
                    if (this.SelectCommandTimeout != null)
                        sqlCommand.CommandTimeout = this.SelectCommandTimeout.Value;
                    sqlConnection.Open();
                    XmlReader xmlReader = sqlCommand.ExecuteXmlReader();
                    this.dataSet.ReadXml(xmlReader, XmlReadMode.Auto);
                    sqlConnection.Close();
                }

                // If no xml returned then create empty table
                if (this.dataSet.Tables.Count == 0)
                    this.dataSet.Tables.Add(this.TableName);
                else
                    this.dataSet.Tables[0].TableName = this.TableName;

                // If locking enabled then lock the rows (22Nov13 XN 78339)
                // if (this.EnabledRowLocking)  19Jun14 XN 43318
                if (this.RowLockingOption == LockingOption.HardLock)
                {
                    using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                    {
                        // lock the rows
                        //this.lockResults.LockRows(this.dataSet.Tables[0]); 19Jun14 XN Added soft locking 43318
                        LockRows(false, this.dataSet.Tables[0]);

                        // reload the data (incase things have changed since lock) into the local dataset 
                        this.dataSet.Clear();
                        using (SqlCommand sqlCommand = new SqlCommand(formattedSQL, sqlConnection))
                        {
                            if (this.SelectCommandTimeout != null)
                                sqlCommand.CommandTimeout = this.SelectCommandTimeout.Value;
                            sqlConnection.Open();
                            XmlReader xmlReader = sqlCommand.ExecuteXmlReader();
                            this.dataSet.ReadXml(xmlReader, XmlReadMode.Auto);
                            sqlConnection.Close();
                        }

                        scope.Commit();
                    }
                }
            }

            this.Table = this.dataSet.Tables[this.TableName];

            // Creats an empty delete table if required
            if (this.DeletedItemsTable == null)
            {
                this.DeletedItemsTable = Table.Clone();
                this.DeletedItemsTable.TableName = this.deleteItemsTableName;
                this.dataSet.Tables.Add(this.DeletedItemsTable);
            }

            // if locking is enabled implement 19Jun14 XN Added soft locking 43318
            // 20Feb15 XN readded as for hard lock could end up double locking     03Dec14 Locking determine if needs to be called
            if (this.RowLockingOption == LockingOption.SoftLock) 
            {
                this.LockRows(false, this.Table);
            }
        }

        /// <summary>
        /// Callued when updating a dataset row to the database
        /// If an insert statment then handles this itself, so can get the id back out
        /// </summary>
        protected virtual void RowUpdating(object sender, SqlRowUpdatingEventArgs e)
        {
            if (e.StatementType == StatementType.Insert)
            {
                // Add getting ID, after insert statment
                string sql = e.Command.CommandText + "; SELECT SCOPE_IDENTITY()";

                // Add all the insert parameters to the command
                List<SqlParameter> parameters = new List<SqlParameter>();
                foreach (SqlParameter param in e.Command.Parameters)
                    parameters.Add(new SqlParameter(param.ParameterName, param.Value));

                // Run command
                object id;
                using (SqlConnection connection = new SqlConnection(this.ConnectionString))
                {
                    connection.Open();
                    SqlCommand sqlCommand = new SqlCommand(sql, connection);
                    sqlCommand.CommandType = CommandType.Text;
                    sqlCommand.Parameters.AddRange(parameters.ToArray());

                    id = sqlCommand.ExecuteScalar();
                    connection.Close();
                }

                // If returns id, and has single PK column then save this to the PK
                if ((id != DBNull.Value) && (id != null) && !string.IsNullOrEmpty(this.GetPKColumnName()))
                {     
                    e.Row.Table.Columns[this.GetPKColumnName()].ReadOnly = false;
                    e.Row[this.GetPKColumnName()] = id;
                    e.Row.Table.Columns[this.GetPKColumnName()].ReadOnly = true;
                }

                // Clear any changes 
                //e.Row.AcceptChanges();    (both save methods now do accept changes manually due to ICW audit log so don't do here)

                // And prevent being insert again, as done above
                e.Status = UpdateStatus.SkipCurrentRow;
            }
        }
        
        /// <summary>Instance verions of GetColumnInfo (used by Generic Table) 26Jul13 24653</summary>
        protected virtual C GetColumnInfo_InstanceVersion()
        {
            return GetColumnInfo();
        }

        /// <summary>Get connection string for Database calls Database.ConnectionString, made virtual so other classes can override it</summary>
        protected virtual string ConnectionString
        {
            get { return Database.ConnectionString; }
        }
        #endregion

        #region Private Methods
        /// <summary>Save data to a single ICW table</summary>
        private void SaveSingleTable()
        {
            // Get the table info (read directly from db or web cache)
            TableInfo tableInfo = GetColumnInfo_InstanceVersion().tableInfo;
            if (tableInfo.Count == 0)
                throw new ApplicationException(string.Format("Failed to get table schema for '{0}'", this.TableName));

            // Build up simple sql select statement for the table
            // This only contains columns that are present in the dataset, and in the database,
            // so command builder won't get confused with complex joins, or trying to save columns that where not loaded.
            //List<string> columns = tableInfo.Select(c => c.ColumnName).Where(c => !ExcludedColumns.Contains(c) && !extraExcludedColumns.Contains(c) && this.Table.Columns.Contains(c)).ToList(); 10Feb14 XN 56701
            IEnumerable<string> columns = GetColumnsForCommandBuilder(tableInfo);
            StringBuilder sqlSelect = new StringBuilder();
            sqlSelect.Append("select [");
            sqlSelect.Append(columns.ToCSVString("],["));
            sqlSelect.AppendFormat("] from [{0}]", this.TableName);

            // If in hard lock mode then set the session lock for the rows that need to be updated 03Dec14 
            List<DataRow> newlyAddedRows = this.Table.Rows.Cast<DataRow>().Where(r => r.RowState == DataRowState.Added).ToList();
            if (this.RowLockingOption == LockingOption.HardLock)
                newlyAddedRows.ForEach(r => r["SessionLock"] = SessionInfo.SessionID);

            // Use the command builder to create the insert, update and delete commands
            using (SqlDataAdapter dataAdapter = new SqlDataAdapter(sqlSelect.ToString(), this.ConnectionString))
            {
                using (SqlCommandBuilder commandBuilder = new SqlCommandBuilder(dataAdapter))
                {
                    commandBuilder.ConflictOption = this.ConflictOption;
                    dataAdapter.InsertCommand = commandBuilder.GetInsertCommand();
                    dataAdapter.UpdateCommand = commandBuilder.GetUpdateCommand();
                    dataAdapter.DeleteCommand = commandBuilder.GetDeleteCommand();

                    dataAdapter.RowUpdating += new SqlRowUpdatingEventHandler(RowUpdating);
                    dataAdapter.AcceptChangesDuringUpdate = false;  // so can save to audit log

                    // save updates
                    dataAdapter.Update(this.DeletedItemsTable);
                    dataAdapter.Update(this.Table);

                    // Write to audit log
                    if (WriteToAudtiLog)
                    {
                        // Get pk info (for log)
                        TableInfoRow pk  = tableInfo.Where(t => t.IsPK && t.Type.EqualsNoCase("int") && columns.Contains(t.ColumnName)).FirstOrDefault();  
                        TableInfoRow pkB = tableInfo.Where(t => t.IsPK && t.Type.EqualsNoCase("int") && columns.Contains(t.ColumnName)).Skip(1).FirstOrDefault();  
                        
                        WriteToLog(columns, (pk == null) ? null : pk.ColumnName, (pkB == null) ? null : pkB.ColumnName, this.DeletedItemsTable);
                        WriteToLog(columns, (pk == null) ? null : pk.ColumnName, (pkB == null) ? null : pkB.ColumnName, this.Table);
                    }

                    // finally accept changes
                    this.DeletedItemsTable.AcceptChanges();
                    this.Table.AcceptChanges();
                }
            }

            // If in hard lock mode then log all the newly added rows with the locker 03Dec14
            if (this.RowLockingOption == LockingOption.HardLock)
            {
                string pkName = this.GetPKColumnName();
                newlyAddedRows.ForEach(r => lockResults.AddLockedRowPK((int)r[pkName]));
            }
        }

        /// <summary>
        /// Save data to a an inhertied ICW table structure
        /// The data in the data set will be saved to all tables in the heirachy.
        /// </summary>
        private void SaveInheritedTables()
        {
            // Can't save if the table has multiple PKs
            string pkColumnName = this.GetPKColumnName();
            if (string.IsNullOrEmpty(pkColumnName))
                throw new ApplicationException(string.Format("Can't save an inherited DB table set if table has multiple PKs (for table '{0}')", this.TableName));

            // Create a single SQL statment to delete a row from each inhertied table starting from the top item in the heirachy e.g. Person.
            // e.g. will create SQL statment to delete from person table as
            //      DELETE FROM [Person] WHERE [EntityID]={0}
            //      DELETE FROM [Entity] WHERE [EntityID]={0}
            StringBuilder sqlDeleteForSingleRow = new StringBuilder();
            foreach (string tableName in tableNames.Reverse<string>())
                sqlDeleteForSingleRow.AppendFormat("DELETE FROM [{0}] WHERE [{1}]={{0}}\n", tableName, pkColumnName);

            // Create select statements for each inhertied table starting at bottom item in heiracy e.g. Entity
            // These statements will be used to create insert, and update, commands using the commmand builder
            List<string> sqlSelects = new List<string>();
            foreach (string tableName in tableNames)
            {
                // Get column info for table
                TableInfo tableInfo = new TableInfo();
                tableInfo.LoadByTableName(tableName);

                if (tableInfo.Count == 0)
                    throw new ApplicationException(string.Format("Failed to get table schema for '{0}' when saving '{1}'", tableName, this.TableName));

                // Create select statment for table 
                StringBuilder sql = new StringBuilder();
                sql.Append("select [");
                //sql.Append(tableInfo.Select(c => c.ColumnName).Where(c => !ExcludedColumns.Contains(c) && !extraExcludedColumns.Contains(c) && this.Table.Columns.Contains(c)).ToCSVString("],[")); 10Feb14 XN 56701
                sql.Append(GetColumnsForCommandBuilder(tableInfo).ToCSVString("],["));
                sql.AppendFormat("] from [{0}]", tableName);

                // Add select statment to list
                sqlSelects.Add(sql.ToString());
            }


            using (ICWTransaction transaction = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {                
                // Do deletes first (as deletes from tables in reverse order EpisodeOrder first, and then Request
                List<DataRow> deletedItems = this.DeletedItemsTable.Rows.Cast<DataRow>().Where(r => r.RowState == DataRowState.Deleted).ToList();
                using (SqlConnection connection = new SqlConnection(ConnectionString))
                {
                    connection.Open();
                    foreach (DataRow row in deletedItems)
                    {
                        string id = row[pkColumnName, DataRowVersion.Original].ToString();
                        SqlCommand sqlCommand = new SqlCommand(string.Format(sqlDeleteForSingleRow.ToString(), id), connection);
                        sqlCommand.CommandType = CommandType.Text;
                        sqlCommand.ExecuteNonQuery();
                    }
                    connection.Close();
                }

                // Now do inserts and updates does it in order Entity, then Person
                foreach (string sql in sqlSelects)
                {
                    using (SqlDataAdapter dataAdapter = new SqlDataAdapter(sql, this.ConnectionString))
                    {
                        using (SqlCommandBuilder commandBuilder = new SqlCommandBuilder(dataAdapter))
                        {
                            // Get insert, and update commands
                            commandBuilder.ConflictOption = this.ConflictOption;
                            dataAdapter.InsertCommand = commandBuilder.GetInsertCommand();
                            dataAdapter.UpdateCommand = commandBuilder.GetUpdateCommand();

                            dataAdapter.RowUpdating += new SqlRowUpdatingEventHandler(RowUpdating);

                            // Can't seem to call update on the DataTable mulitple times, even if you reset rows using SetAdded, and SetModified
                            // So create temp table and update that.
                            // Might of been able to do it if dataAdapter.AcceptChangesDuringUpdate = false

                            DataSet temp = new DataSet();
                            temp.EnforceConstraints = false;
                            temp.Tables.Add(this.Table.Clone());
                            foreach(DataRow row in this.Table.Rows)
                                temp.Tables[0].ImportRow(row);

                            bool anyInserts = temp.Tables[0].Rows.Cast<DataRow>().Any(r => r.RowState == DataRowState.Added);

                            dataAdapter.Update(temp.Tables[0]);

                            if (anyInserts && !string.IsNullOrEmpty(this.GetPKColumnName()))
                            {
                                for (int r = 0; r < this.Table.Rows.Count; r++)
                                {
                                    DataRow originalRow = this.Table.Rows[r];
                                    DataRow tempRow     = temp.Tables[0].Rows[r];

                                    if ((originalRow.RowState == DataRowState.Added) && (originalRow[this.GetPKColumnName()] != tempRow[this.GetPKColumnName()]))
                                    {
                                        this.Table.Columns[this.GetPKColumnName()].ReadOnly = false;
                                        this.Table.Rows[r][this.GetPKColumnName()] = temp.Tables[0].Rows[r][this.GetPKColumnName()];
                                        this.Table.Columns[this.GetPKColumnName()].ReadOnly = temp.Tables[0].Columns[this.GetPKColumnName()].ReadOnly;
                                    }
                                }
                            }
                        }
                    }
                }

                // Write to audit log
                if (WriteToAudtiLog)
                {
                    // Get table info (for log)
                    TableInfo tableInfo = new TableInfo();
                    tableInfo.LoadByTableNameAndHierarchy(this.TableName);
                    //List<string> columns = tableInfo.Select(c => c.ColumnName).Where(c => !ExcludedColumns.Contains(c) && !extraExcludedColumns.Contains(c) && this.Table.Columns.Contains(c)).ToList(); 10Feb14 XN 56701
                    IEnumerable<string> columns = GetColumnsForCommandBuilder(tableInfo);

                    TableInfoRow pk  = tableInfo.Where(t => t.IsPK && t.Type.EqualsNoCase("int") && columns.Contains(t.ColumnName)).FirstOrDefault();  
                    TableInfoRow pkB = tableInfo.Where(t => t.IsPK && t.Type.EqualsNoCase("int") && columns.Contains(t.ColumnName)).Skip(1).FirstOrDefault();  
                    
                    WriteToLog(columns, (pk == null) ? null : pk.ColumnName, (pkB == null) ? null : pkB.ColumnName, this.DeletedItemsTable);
                    WriteToLog(columns, (pk == null) ? null : pk.ColumnName, (pkB == null) ? null : pkB.ColumnName, this.Table);
                }

                // And accept changes
                this.DeletedItemsTable.AcceptChanges();
                this.Table.AcceptChanges();
                transaction.Commit();
            }
        }

        /// <summary>Writes any changed rows to the ICW audi log</summary>
        /// <param name="columns">Columns to wirte</param>
        /// <param name="pkColumnName">PK column name</param>
        /// <param name="pkBColumnName">2nd PK column name</param>
        /// <param name="table">Table data to save</param>
        private void WriteToLog(IEnumerable<string> columns, string pkColumnName, string pkBColumnName, DataTable table)
        {
            try
            {
                foreach (DataRow r in table.Rows)
                {
                    // Get update type
                    AuditLogType logType;
                    DataRowVersion rowVersionToUse; // Can't access deleted row info so need to get original version
                    switch (r.RowState)
                    {
                    case DataRowState.Added:    logType = AuditLogType.Insert; rowVersionToUse = DataRowVersion.Current;  break;
                    case DataRowState.Deleted:  logType = AuditLogType.Delete; rowVersionToUse = DataRowVersion.Original; break;
                    case DataRowState.Modified: logType = AuditLogType.Update; rowVersionToUse = DataRowVersion.Current;  break;
                    default: continue;  // No changes to row so skip
                    }

                    // Get pk value
                    int pk = 0;
                    if (!string.IsNullOrEmpty(pkColumnName))
                        pk = (int)r[pkColumnName, rowVersionToUse];

                    // Get pk b value
                    int pkB = 0;
                    if (!string.IsNullOrEmpty(pkBColumnName))
                        pkB = (int)r[pkBColumnName, rowVersionToUse];

                    // Convert row to xml string
                    StringBuilder dataXML = new StringBuilder();
                    XmlWriterSettings settings = new XmlWriterSettings();
                    settings.OmitXmlDeclaration = true;
                    using (XmlWriter writer = XmlWriter.Create(dataXML, settings))
                    {
                        writer.WriteStartElement(this.TableName);
                        foreach (string c in columns)
                        {
                            if (!r.IsNull(table.Columns[c], rowVersionToUse))
                                writer.WriteAttributeString(c, r[c, rowVersionToUse].ToString().Replace("\x1E", "&#30"));   // Replace is for WLookup items that use unpritable char 30 quite a lot
                                //writer.WriteAttributeString(c, r[c, rowVersionToUse].ToString());   TFS88858
                        }
                        writer.WriteEndElement();
                        writer.Flush();
                        writer.Close();
                    }

                    // And save
                    AuditLog.Write(this.TableName, pk, pkB, logType, dataXML.ToString());
                }
            }
            catch (Exception ex)
            {
#if DEBUG
                throw ex;   // Don't want simple thing like locking of audit log table to effect rest of app so ignore error in production
#endif
            }
        }
        
        /// <summary>
        /// Used by SaveSingleTable and SaveInheritedTables to get list of columns names to be used by the command builder
        /// This will include the name of all columns with altered date (or all columns for a new row)
        /// The PK columns
        /// But will not include items that are in the ExcludedColumns, extraExcludedColumns, or not in the DB table
        /// 10Feb14 XN 56701 Added
        /// </summary>
        /// <param name="tableInfo">Info on table the get the column data for</param>
        private List<string> GetColumnsForCommandBuilder(TableInfo tableInfo)
        {
            // Only get list of columns that have be altered
            // This is useful for ConflictOption == CompareAllSearchableValues as will only throw a concurrance violation if alter a column that has been edit by another user (if differnet column has been altered data is saved okay but only columns edited are updated in db)
            // This does mean that only columns that are edit are updated in the db (which is how DataSet seem to work anyway)
            List<string> columns = new List<string>();
            columns.AddRange( this.SelectMany(r => r.GetChangedColumns().Select(c => c.ColumnName)) );            
            if ( this.UseLogicalDelete )    // 20Nov14 XN  Fixed logical deletes
            {
                var deletedRows = this.DeletedItemsTable.Rows.Cast<DataRow>().Select(r => new T(){ RawRow = r });
                columns.AddRange( deletedRows.SelectMany(r => r.GetChangedColumns().Select(c => c.ColumnName)) );
            }

            // Add pk columns
            if (string.IsNullOrEmpty(this.GetPKColumnName()))
                columns.Add(this.GetPKColumnName());    // try GetPKColumnName for table like WSupplierProfile that do not have a PK in the DB
            else
                columns.AddRange(tableInfo.Where(c => c.IsPK).Select(c => c.ColumnName));

            // Remove duplciates
            columns = columns.Distinct().ToList();

            // remove exluded columns, and one that are not in the table or dataset
            columns.RemoveAll(c => ExcludedColumns.Contains(c) || extraExcludedColumns.Contains(c) || !tableInfo.Any(ti => ti.ColumnName == c));

            return columns;
        }

        /// <summary>
        /// Locks all the rows in dataTable
        /// Will set lockResults to the correct lock class based on option RowLockingOption
        /// 24Jun14 XN 43318
        /// </summary>
        /// <param name="append">If data is being appended</param>
        /// <param name="dataTable">Rows to lock</param>
        private void LockRows(bool append, DataTable dataTable)
        {
            if (this.RowLockingOption == LockingOption.None)
                return;

            // Change the lockResults class if incorrect for locking option
            switch (this.RowLockingOption)
            {
            case LockingOption.SoftLock:
                if ( this.lockResults.GetType().Name != typeof(SoftLockResults).Name )
                {
                    if (append)
                        throw new ApplicationException("Can't change locking mechanisum when appending rows");
                    this.lockResults.UnlockRows();
                    this.lockResults = new SoftLockResults(this.TableName);
                }
                break;
            case LockingOption.HardLock:
                if ( this.lockResults.GetType().Name != typeof(LockResults).Name )
                {
                    if (append)
                        throw new ApplicationException("Can't change locking mechanisum when appending rows");
                    this.lockResults.UnlockRows();
                    this.lockResults = new LockResults(this.TableName);
                }
                break;
            }

            // Lock rows
            this.lockResults.LockRows(dataTable);
        }

        /// <summary>
        /// Returns row with the specified PK ID
        /// </summary>
        /// <param name="id">PK ID</param>
        /// <returns>data row (or null if row does not exist)</returns>
        public T FindByID(int id)
        {
            string pkName = this.GetPKColumnName();

            // If no pk column defined then can't search
            if ((Table != null) && Table.Columns.Contains(pkName))
            {
                foreach (T row in this)
                {
                    if (row.FieldToInt(row.RawRow[pkName]) == id)
                        return row;
                }

            }

            return null;
        }

        /// <summary>Returns all rows with the specified PK ID</summary>
        public IEnumerable<T> FindByIDs(int[] ids)
        {
            string pkName = this.GetPKColumnName();

            // If no pk column defined then can't search
            if ((Table != null) && Table.Columns.Contains(pkName))
            {
                foreach (T row in this)
                {
                    int? pk = row.FieldToInt(row.RawRow[pkName]);
                    if (pk.HasValue && ids.Contains(pk.Value))
                        yield return row;
                }

            }
        }
        #endregion

        #region IDisposable Members
        protected virtual void Dispose(bool disposing)
        {
            // If disposing rather than terminating then free locks 
            if (disposing)
            {
                // If not freeing locks the clear the lock object so does not get unlocked 24Jun14 XN 43318
                if (this.PreventUnlockOnDispose)
                    this.lockResults = null;
                this.Clear();
            }
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
            return new BaseTable2Enumerator<T, C>(this);
        }
        #endregion

        #region IEnumerable Members
        IEnumerator IEnumerable.GetEnumerator()
        {
            return new BaseTable2Enumerator<T, C>(this);
        }
        #endregion
    }
}
