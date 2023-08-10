//===========================================================================
//
//							     SoftLockResults.cs
//
//	Class used to perform soft lock of database rows.
//
//  This is a pharmacy lock where a row in the table can been lock by multiple users.
//  Just because 1 user has a lock on a row dose not mean that another user can't also
//  lock a row, it is used to just let people known that someone else may update the row.
//
//  This form of locking is often used by editors where where standard Pharmacy Locking
//  would lock the row for two long prevent it being used for say dispensing.
//  Soft locking is normaly used with BaseTable2 opermistic locking (BaseTable2.ConflictOption = CompareAllSearchableValues)
//
//  SoftLockResults inherits LockResults and so will keep track of the rows it has locked, for easy unlocking
//  
//  If another user has already soft locked a row then a SoftLockException will be thrown, however
//  the Lock method will still lock all rows, and will only throw 1 exception independat of number of rows that are locked
//
//  Locked row are tracked on the SessionAttribute tabe where Attribute='<table name> Soft Lock <row pk>'
//
//  Usage:
//  To lock row in the WOrder table
//      SoftLockResults locker = new SoftLockResults("WOrder");
//      locker.LockRows(order.Table);
//
//  To unlock rows in the WOrder table
//      locker.UnlockRows();
//      
//	Modification History:
//	07Mar14 XN  Written
//  05Jun14 XN  Added errorIfLocked flag to LockRows 43318
//  03Dec14 XN  Added IsLockedByOtherUser 43318
//  17Dec15 XN  Added IsLockedByOtherUser 38034
//  17Feb15 XN  Added storing of PK field in LockException 111404 
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.basedatalayer
{
    public class SoftLockResults : LockResults
    {
        #region Constructors
        /// <summary>Constructor</summary>
        /// <param name="tableName">DB table name</param>
        /// <param name="pkName">DB PK column name for the table</param>
        public SoftLockResults(string tableName, string pkName) : base(tableName, pkName) { }

        /// <summary>Constructor</summary>
        /// <param name="tableName">DB table name</param>
        public SoftLockResults(string tableName) : base(tableName) { }
        #endregion

        #region Public Methods
        /// <summary>
        /// Locks all the rows in the data table 
        /// Will always lock all rows, but will throw a single SoftLockException at end if any row are currently locked by another user
        /// </summary>
        /// <param name="table">Table containing rows to be locked</param>
        /// <pparam name="errorIfLocked">If to throw an exception if already locked XN 05Jun14 43318</pparam>
        public override void LockRows(DataTable table)
        {
            this.LockRows(table, true);
        }
        public void LockRows(DataTable table, bool errorIfLocked)
        {
            LockException        lockException = null;
            ApplicationException appException  = null;
            string pkColumnName = GetPKColumnName();

            // Test table info
            if (string.IsNullOrEmpty(TableName))
            {
                string error = string.Format("Can't lock rows as table not defined.");
                throw new ApplicationException(error);
            }
            else if (string.IsNullOrEmpty(pkColumnName))
            {
                string error = string.Format("Can't lock rows as single column PK is not defined.");
                throw new ApplicationException(error);
            }
            else if (!table.Columns.Contains(pkColumnName))
            {
                string error = string.Format("Row lock has been requested for data returned by '{0}' but the data does not contain the pk column '{1}'.", TableName, pkColumnName);
                throw new ApplicationException(error);
            }

            // lock each row in the table
            foreach (DataRow row in table.Rows)
            {
                List<SqlParameter> parameters = new List<SqlParameter>();
                int pk = Convert.ToInt32(row[pkColumnName]);    // row PK                

                parameters.Add("CurrentSessionID", SessionInfo.SessionID);
                parameters.Add("TableName",        this.TableName       );
                parameters.Add("PKValue",          pk                   );

                int? result = Database.ExecuteSPReturnValue<int?>("pPharmacyRowSoftLock", parameters);
                if (result == null)
                    appException = new ApplicationException(string.Format("Could not lock {0} Record Number {1}\nReason Unknown", TableName, pk));  // Failed.
                else if (errorIfLocked && result != SessionInfo.SessionID)
                    lockException = new SoftLockException(TableName, pkColumnName, pk, result.Value); // already locked

                // Add pk to list of locked rows
                lockedRowPKs.Add(pk);
            }

            // Raise any exceptions
            if (appException != null)
                throw appException;
            if (lockException != null)
                throw lockException;
        }

        /// <summary>Unlock a single row (does not have to be locked by this instance</summary>
        public override void UnlockRow(int ID)
        {
            // Build parameters for pPharmacyRowUnLock
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("TableName",        TableName            );
            parameters.Add("PKValue",          ID                   );
            Database.ExecuteSPNonQuery("pPharmacyRowUnSoftLock", parameters);

            // remove from lock list
            lockedRowPKs.Remove(ID);
        }

        /// <summary>Unlock all rows that have been locked with method LockRows</summary>
        public override void UnlockRows()
        {
            List<SqlParameter> parameters = new List<SqlParameter>();

            // unlock all rows
            while (lockedRowPKs.Count > 0)
            {
                parameters.Clear();

                // Build parameters for pPharmacyRowUnLock
                parameters.Add("CurrentSessionID", SessionInfo.SessionID);
                parameters.Add("TableName",        TableName            );
                parameters.Add("PKValue",          lockedRowPKs[0]      );
                Database.ExecuteSPNonQuery("pPharmacyRowUnSoftLock", parameters);

                // remove from lock list
                lockedRowPKs.RemoveAt(0);
            }
        } 

        /// <summary>Returns if all items in table are currently locked by this object 7Mar14 XN 56701</summary>
        public override bool IsLocked(DataTable table)
        {
            throw new NotImplementedException();
        }
        
        /// <summary>Returns a SoftLockException if row is already locked another user (does not perform any actual locking) 03Dec14 43318</summary>
        public SoftLockException IsLockedByOtherUser(int ID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("TableName",        this.TableName       );
            parameters.Add("PKValue",          ID                   );

            int result = Database.ExecuteSPReturnValue<int?>("pPharmacyIsRowSoftLocked", parameters) ?? 0;  // Returns 0 if not set
            return (result == 0) ? null : new SoftLockException(TableName, string.Empty, ID, result);
        }

        /// <summary>Returns a SoftLockException for each rows already locked another user (does not perform any actual locking) 17Dec15 XN 38034</summary>
        public override IDictionary<int,LockException> IsLockedByOtherUser(IEnumerable<int> IDs)
        {
            HashSet<int> IDSet            = new HashSet<int>(IDs);
            int          currentSessionID = SessionInfo.SessionID;

            // Get all locked rows for the table
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("TableName", this.TableName);

            GenericTable2 lockedRows = new GenericTable2();
            lockedRows.LoadBySP("pPharmacyAllSoftLockedRowIDs", parameters);

            // Filter to just rows for specified IDs that are not for the current session
            return (from r in lockedRows
                    let sessionID = (int)r.RawRow["SessionID"]
                    let pkValue   = (int)r.RawRow["PKValue"]
                    where IDs.Contains(pkValue) && sessionID != currentSessionID
                    select new { sessionID, pkValue }).ToDictionary(r => r.pkValue,
                                                                    r => (LockException)new SoftLockException(TableName, string.Empty, r.pkValue, r.sessionID));
        }
        #endregion
    }

    /// <summary>Defines a specific non-fatal exception for the occasion where a record has already been locked by another user</summary>    
    public class SoftLockException : LockException
    {
        /// <summary>Initialises a new instance of the SoftLockException class.</summary>
        /// <param name="tableName">The table where the failed lock attempt has taken place.</param>
        /// <param name="pkName">The primary key for the table.</param>
        /// <param name="pk">The value of the primary key for the record that failed to lock.</param>
        /// <param name="sessionID_Locker">Session ID of the person who has the lock</param>
        public SoftLockException(string tableName, string pkName, int pk, int sessionID_Locker) 
            : base("Item in table " + tableName + " where " + pkName + " = '" + pk.ToString() + "' is also locked by another user.", sessionID_Locker, pk)
        {}
    }
}
