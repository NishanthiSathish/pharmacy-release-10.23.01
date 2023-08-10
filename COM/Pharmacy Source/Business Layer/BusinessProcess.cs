//===========================================================================
//
//							BusinessProcess.cs
//
//	Base class for a class that contain business processes.
//
//  The class should be inherited from rather than being used directly.  
//
//  The base class also provides functions for batch locking of pharmacy tables.
//
//  Usage:
//      
//	Modification History:
//	19Jan09 XN  Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.businesslayer
{
    public class BusinessProcess : IDisposable
    {
        #region Member variables
        protected Dictionary<string, LockResults> lockedRows = new Dictionary<string, LockResults>();   // Dictionary of tables and locked rows        
        #endregion

        ~BusinessProcess()
        {
            Dispose(false);
        }

        public BusinessProcess()
        {
            ValidationErrors = new ValidationErrorList();
        }

        #region Properties
        /// <summary>
        /// List of validation error objects
        /// </summary>
        public ValidationErrorList ValidationErrors { get; set; }
        #endregion

        #region Protected method
        /// <summary>
        /// Locks all the rows in the datatable
        /// Should only be used for pharmacy tables, that contain a SessionLock field.
        /// </summary>
        /// <param name="table">Table containing rows to be locked</param>
        /// <param name="tableName">DB table name that support pharmacy row locking</param>
        /// <param name="pkName">DB PK column name for the table</param>
        protected void LockRows(DataTable table, string tableName, string pkName)
        {
            LockResults info;   // List of locked rows

            // Try to get the table locking object (from dictionary).
            if (!lockedRows.TryGetValue(tableName, out info))
            {
                // locking object for table does not exist so create one.
                info = new LockResults(tableName, pkName);
                lockedRows.Add(tableName, info);
            }

            // Lock all rows in the table
            if (table != null)
                info.LockRows(table);
        }

        /// <summary>
        /// Unlock all row locked with method LockRows
        /// </summary>
        protected void UnlockRows()
        {
            foreach (LockResults info in lockedRows.Values)
                info.UnlockRows();
        } 
        #endregion

        #region IDisposable Members
        protected virtual void Dispose(bool disposing)
        {
            if (disposing) 
                UnlockRows();
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);            
        }
        #endregion
    }
}
