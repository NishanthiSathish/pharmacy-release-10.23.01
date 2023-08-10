//===========================================================================
//
//							     LockResults.cs
//
//	Class used to lock database rows.
//
//  This is a pharmacy lock, were the table will have a SessionLock field, which
//  is set to the session ID of the user who requests the lock.
//
//  The LockResults class will also keep track of the rows it has locked, so they can
//  be easily unlocked.
//  
//  If locking fails the lock will be retried a number of times (see settings below), 
//  and if it still fails a LockException will be thrown
//
//  Locking depends on 2 settings from the ICW settings table
//      System      Section  Key                        
//      Pharmacy    Locking  LockResultsRetries         - Number of times to retry failed 
//                                                        locks before erroring (default 5)
//      Pharmacy    Locking  LockResultsRetryInterval   - interval between lock retries in ms
//                                                        (default 500ms)     
//
//  The file also contains two internal classes
//      LockResultsRow      - reads results returned from the pPharmacyRowLock sp
//      LockResultsSettings - reads lock settings from ICW settings table    
//  And the LockException exception     
//
//  Usage:
//  To lock row in the WOrder table
//      LockResults locker = new LockResults("WOrder");
//      locker.LockRows(order.Table);
//
//  To unlock rows in the WOrder table
//      locker.UnlockRows();
//      
//	Modification History:
//	15Apr09 AK  Written
//  27Apr09 XN  Removed all static variables by making them local, or storing
//              them in the pharmacy cache. To allow use as web app.
//  24Nov13 XN  Removed need for PK column name in constructor (for BaseTable2) 78339
//  10Feb14 XN  Added WriteXml and ReadXml 56701
//  07Mar14 XN  Update LockRows, UnlockRow
//              Added methods IsLocked, GetPKColumnName
//              And moved LockException to this file
//              For SoftLockResults 56701
//  05Jun14 XN  Moved UnlockRows to new Database functions 43318
//  24Jun14 XN  Improved WriteXml, and ReadXml, and added a Create method
//              that will create a lock object of the correct type from the XML 43318 
//  14Oct14 XN  Dervied HardLockException from LockException, and used this from LockRows  43318
//  18Nov14 XN  Added method GetLockerName, and GetTerminal 104458
//  17Dec15 XN  Added IsLockedByOtherUser 38034
//  17Feb15 XN  Added storing of PK field in LockException 111404 
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Xml;
using ascribe.pharmacy.shared;
using TRNRTL10;

namespace ascribe.pharmacy.basedatalayer
{
    public class LockResults 
    {
        #region Member variables
        protected List<int> lockedRowPKs = new List<int>();  // List of locked rows        

        /// <summary>Cahced name of PK 24Nov13 XN 78339 (don't call directly instead use GetPKColumnName</summary>
        private string pkColumnName = string.Empty;
        #endregion

        #region Public properties
        /// <summary>DB table name</summary>
        public string TableName { get; private set; }
        #endregion        

        #region Constructors
        /// <summary>Constructor</summary>
        /// <param name="tableName">DB table name that support pharmacy row locking</param>
        /// <param name="pkName">DB PK column name for the table</param>
        public LockResults(string tableName, string pkName)
        {
            TableName    = tableName;
            pkColumnName = pkName;
        }        

        /// <summary>Constructor 18Dec13 XN 78339</summary>
        /// <param name="tableName">DB table name that support pharmacy row locking</param>
        public LockResults(string tableName)
        {
            TableName = tableName;
        }     
        #endregion

        #region Public Methods
        /// <summary>Add row to list of locked rows (does not do any actual really locking) 03Dec14</summary>
        internal void AddLockedRowPK(int pk)
        {
            lockedRowPKs.Add(pk);
        }

        /// <summary>
        /// Locks all the rows in the datatable
        /// </summary>
        /// <param name="table">Table containing rows to be locked</param>
        public virtual void LockRows(DataTable table)
        {
            // Get PK 7Mar14 XN 56701
            string pkColumnName = GetPKColumnName();
            //if (string.IsNullOrEmpty(pkColumnName))
            //{
            //    TableInfo tableInfo = new TableInfo();
            //    tableInfo.LoadByTableName(this.TableName);
            //    IEnumerable<TableInfoRow> pks = tableInfo.Where(r => r.IsPK);
            //    this.pkColumnName = (pks.Count() != 1) ? string.Empty : pks.First().ColumnName;
            //}

            // Doesn’t derive from BaseTable as could get recursive includes between BaseTable and this class
            Transport dblayer = new Transport();
            int sessionID = -1;

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
                int pk = Convert.ToInt32(row[pkColumnName]);    // row PK

                int retries = 0;        // Number of retries
                bool success = false;   // If locked row

                // Build parameters for pPharmacyRowLock
                StringBuilder parameters = new StringBuilder();
                parameters.Append(dblayer.CreateInputParameterXML("TableName", Transport.trnDataTypeEnum.trnDataTypeVarChar, TableName.Length,    TableName   ));
                parameters.Append(dblayer.CreateInputParameterXML("PKColumn",  Transport.trnDataTypeEnum.trnDataTypeVarChar, pkColumnName.Length, pkColumnName));
                parameters.Append(dblayer.CreateInputParameterXML("PKValue",   Transport.trnDataTypeEnum.trnDataTypeInt,     4,                   pk          ));

                // Repeatedly retry locking (till max retries exceeded)
                while (retries < LockResultsSettings.Instance.LockResultsRetries && success == false)
                {
                    // Try lock
                    DataSet pharmacyRowLockResults = dblayer.ExecuteSelectSP(SessionInfo.SessionID, "pPharmacyRowLock", parameters.ToString());
                    DataRowCollection pharmacyRowLock = pharmacyRowLockResults.Tables[0].Rows;

                    if (pharmacyRowLock.Count != 1)
                    {
                        // Failed.
                        string error = string.Format("Could not lock {0} Record Number {1}\nReason Unknown", TableName, pk);
                        throw new ApplicationException(error);
                    }
                    else if (((int)pharmacyRowLock[0]["SessionID"]) != SessionInfo.SessionID)
                    {
                        // Already lock so retry.
                        sessionID = (int)pharmacyRowLock[0]["SessionID"];
                        System.Threading.Thread.Sleep(LockResultsSettings.Instance.LockResultsRetryInterval);
                        retries++;
                    }
                    else
                    {
                        // Managed to get lock
                        success = true;
                    }
                }

                // If lock failed throw lock exception
                if (!success)
                    throw new HardLockException(TableName, pkColumnName, pk, sessionID);

                // Update SessionLock field on local data if needed
                if (table.Columns.Contains("SessionLock"))
                    row["SessionLock"] = SessionInfo.SessionID;

                // Add pk to list of locked rows
                lockedRowPKs.Add(pk);
            }
        }

        /// <summary>Unlock a single row (does not have to be locked by this instance</summary>
        public virtual void UnlockRow(int ID)
        {
            // Doesn’t derive from BaseTable as could get recursive includes between BaseTable and this class
            Transport dblayer = new Transport();

            // unlock row
            StringBuilder parameters = new StringBuilder();
            parameters.Append(dblayer.CreateInputParameterXML("TableName", Transport.trnDataTypeEnum.trnDataTypeVarChar, TableName.Length,    TableName));
            parameters.Append(dblayer.CreateInputParameterXML("PKColumn",  Transport.trnDataTypeEnum.trnDataTypeVarChar, pkColumnName.Length, pkColumnName));
            parameters.Append(dblayer.CreateInputParameterXML("PKValue",   Transport.trnDataTypeEnum.trnDataTypeInt,     4,                   ID));
            dblayer.ExecuteSelectSP(SessionInfo.SessionID, "pPharmacyRowUnLock", parameters.ToString());

            // remove from lock list
            if (lockedRowPKs.Contains(ID))
                lockedRowPKs.Remove(ID);
                //lockedRowPKs.RemoveAt(0); Removed as not correct 7Mar14 XN 56701
        }

        /// <summary>Unlock all rows that have been locked with method LockRows</summary>
        public virtual void UnlockRows()
        {
            // Doesn’t derive from BaseTable as could get recursive includes between BaseTable and this class
            Transport dblayer = new Transport();

            // unlock all rows
            while (lockedRowPKs.Count > 0)
            {
                // Build parameters for pPharmacyRowUnLock
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add("CurrentSessionID", SessionInfo.SessionID);
                parameters.Add("TableName",        TableName            );
                parameters.Add("PKColumn",         GetPKColumnName()    );
                parameters.Add("PKValue",          lockedRowPKs[0]      );
                Database.ExecuteSPNonQuery("pPharmacyRowUnLock", parameters);   // Moved from old transport layer to new version 05Jun14 XN

                // remove from lock list
                lockedRowPKs.RemoveAt(0);
            }
        } 

        /// <summary>Returns if all items in table are currently locked by this object 7Mar14 XN 56701</summary>
        public virtual bool IsLocked(DataTable table)
        {
            if (lockedRowPKs.Count != table.Rows.Count)
                return false;
        
            string pkColumnName = GetPKColumnName();
            foreach (DataRow row in table.Rows)
            {
                int pk = Convert.ToInt32(row[pkColumnName]);
                if (!lockedRowPKs.Contains(pk))
                    return false;
            }

            return true;
        }
        
        /// <summary>Write class data to XmlWriter</summary>
        public void WriteXml(XmlWriter writer)
        {
            //writer.WriteElementString("LockResults", this.lockedRowPKs.ToCSVString(",")); 24Jun14 XN 43318 Improved the WriteXml, and ReadXMl methods
            writer.WriteStartElement("LockResults");                            
            writer.WriteAttributeString("Type",         this.GetType().Name);
            writer.WriteAttributeString("TableName",    this.TableName     );
            writer.WriteAttributeString("PKColumnName", this.pkColumnName  );
            writer.WriteValue(this.lockedRowPKs.ToCSVString(","));
            writer.WriteEndElement();
        }
        
        /// <summary>Read class data to XmlReader 24Jun14 XN 43318 Improved the WriteXml, and ReadXMl methods</summary>
        public void ReadXml(XmlReader reader)
        {
            if (reader.Name != "LockResults")
                reader.Read();
            if (this.GetType().Name != reader.GetAttribute("Type"))
            {
                string error = string.Format("LockResuls was saved to xml as type {0} by read as type {1}", reader.GetAttribute("Type"), this.GetType().Name);
                throw new ApplicationException(error);
            }
            this.TableName    = reader.GetAttribute("TableName",    this.TableName   );
            this.pkColumnName = reader.GetAttribute("PKColumnName", this.pkColumnName);
            this.lockedRowPKs = reader.ReadElementString("LockResults").ParseCSV<int>(",", false).ToList();
        }

        /// <summary>Create lock results (or SoftlockResults from xml) 24Jun14 XN 43318 added</summary>
        public static LockResults Create(XmlReader reader)
        {
            LockResults lockResults = null;

            // Read xml string
            string type = reader.GetAttribute("Type");
            switch (type)
            {
            case "LockResults"    : lockResults = new LockResults    (string.Empty); break;
            case "SoftLockResults": lockResults = new SoftLockResults(string.Empty); break;
            }

            lockResults.ReadXml(reader);
            
            return lockResults;
        }
        
        /// <summary>Returns a HardLockException for each rows already locked another user (does not perform any actual locking)  17Dec15 XN 38034</summary>
        public virtual IDictionary<int,LockException> IsLockedByOtherUser(IEnumerable<int> IDs)
        {
            HashSet<int> IDSet            = new HashSet<int>(IDs);
            int currentSessionID = SessionInfo.SessionID;

            // Get all locked rows for the table
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add( "TableName", this.TableName         );
            parameters.Add( "PKColumn",  this.GetPKColumnName() );

            GenericTable2 lockedRows = new GenericTable2();
            lockedRows.LoadBySP("pPharmacyAllHardLockedRowIDs", parameters);

            // Filter to just rows for specified IDs that are not for the current session
            return (from r in lockedRows
                    let sessionID = (int)r.RawRow["SessionID"]
                    let pkValue   = (int)r.RawRow["PKValue"]
                    where IDs.Contains(pkValue) && sessionID != currentSessionID
                    select new { sessionID, pkValue }).ToDictionary(r => r.pkValue, 
                                                                    r => (LockException)new HardLockException(TableName, string.Empty, r.pkValue, r.sessionID));
        }
        #endregion

        #region Private Methods
        /// <summary>Get the PK column name (either uses this.pkColumnName else loads from DB 56701 7Mar14 XN</summary>
        protected string GetPKColumnName()
        {
            if (string.IsNullOrEmpty(pkColumnName))
            {
                TableInfo tableInfo = new TableInfo();
                tableInfo.LoadByTableName(this.TableName);
                IEnumerable<TableInfoRow> pks = tableInfo.Where(r => r.IsPK);
                this.pkColumnName = (pks.Count() != 1) ? string.Empty : pks.First().ColumnName;
            }

            return pkColumnName;
        }
        #endregion
    }

    /// <summary>Defines a specific non-fatal exception for the occasion where a record has already been locked by another user</summary>    
    public class HardLockException : LockException
    {
        /// <summary>Initialises a new instance of the HardLockException class.</summary>
        /// <param name="tableName">The table where the failed lock attempt has taken place.</param>
        /// <param name="pkName">The primary key for the table.</param>
        /// <param name="pk">The value of the primary key for the record that failed to lock.</param>
        /// <param name="sessionID_Locker">Session ID of the person who has the lock</param>
        public HardLockException(string tableName, string pkName, int pk, int sessionID_Locker) 
            : base("Unable to lock table " + tableName + " where " + pkName + " = '" + pk.ToString() + "'.", sessionID_Locker, pk)
        {}
    }

    /// <summary>Defines a specific non-fatal exception for the occasion where a record cannot be locked</summary>    
    public class LockException : ApplicationException
    {
        /// <summary>Generic table created from sp pUserXML that provides info of person who has a lock on the record.</summary>
        private GenericTable user_Locker;

        /// <summary>Session that has the current lock  on the table</summary>
        public int SessionID_Locker { get; private set; }

        /// <summary>PK that caused the exception 111404 17Feb15 XN</summary>
        public int PK { get; private set; }

        /// <summary>Used by SoftlockException</summary>
        /// <param name="message">Exception mesage</param>
        /// <param name="sessionID_Locker">SessionID</param>
        public LockException(string message, int sessionID_Locker, int PK) : base (message)
        {
            this.SessionID_Locker = sessionID_Locker;
            this.PK = PK;
        }


        /// <summary>
        /// Gets the entity of the user that currently has the lock on the record
        /// (can be null if user logs out between when exception raised and method is called)
        /// </summary>
        public int? GetLockerEntityID()
        {
            LoadLocker();
            //return user_Locker.Any() ? (int)user_Locker[0].RawRow["EntityID"] : (int?)null; 10Feb14 XN 56701
            return user_Locker.Any() ? int.Parse(user_Locker[0].RawRow["EntityID"].ToString()) : (int?)null;
        }

        /// <summary>
        /// Gets the username of the user that currently has the lock on the record
        /// (can be "" if user logs out between when exception raised and method is called)
        /// </summary>
        [Obsolete("User GetLockerName instead as more descriptive than username")]
        public string GetLockerUsername()
        {
            LoadLocker();
            return user_Locker.Any() ? (string)user_Locker[0].RawRow["Username"] : string.Empty;
        }

        /// <summary>
        /// Gets the Descritpion of the user that currently has the lock on the record
        /// (can be "" if user logs out between when exception raised and method is called)
        /// 18Nov14 XN 104458
        /// </summary>
        public string GetLockerName()
        {
            LoadLocker();
            return user_Locker.Any() ? (string)user_Locker[0].RawRow["Description"] : string.Empty;
        }

        /// <summary>
        /// Gets the terminal of the user that currently has the lock on the record
        /// (can be "" if user logs out between when exception raised and method is called)
        /// 18Nov14 XN 104458
        /// </summary>
        public string GetTerminal()
        {
            return Database.ExecuteSQLSingleField<string>("Exec pTerminalIdentifyForPharmacy {0}", this.SessionID_Locker).FirstOrDefault() ?? string.Empty; 
        }

        /// <summary>Method that loads info on user that currently has lock on the record (calls pUserXML)</summary>
        private void LoadLocker()
        {
            if (user_Locker == null)
            {
                user_Locker = new GenericTable(string.Empty, string.Empty);

                int? entityID = Database.ExecuteSQLScalar<int?>("SELECT EntityID FROM Session WHERE SessionID={0}", SessionID_Locker);
                if (entityID.HasValue)
                    user_Locker.LoadByXMLSP("pUserXML", "EntityID", entityID.Value);
            }
        }
    }

    /// <summary>
    /// Reads results returned from the pPharmacyRowLock sp
    /// Should have a LockResults table class this will produce recursive includes between
    /// BaseTable and LockResults, so has not been implemented
    /// </summary>
    internal class LockResultsRow : BaseRow
    {
        public int    SessionID     { get { return FieldToInt(RawRow["sessionID"]).Value; } }
        public string TerminalName  { get { return FieldToStr(RawRow["Terminal"]);        } }
        public string UserName      { get { return FieldToStr(RawRow["user"]);            } }
    }

    /// <summary>
    /// holds settings for pharmacy locking loaded from ICW settings table
    /// Should only be reference a singleton LockResultsSettings.Instance
    /// </summary>
    internal class LockResultsSettings
    {
        /// <summary>Force singleton use</summary>
        private LockResultsSettings() {}

        [SettingInfo(System = "Pharmacy", Section = "Locking", Key = "LockResultsRetries", Default = "5")]
        public int LockResultsRetries { get; set; }

        [SettingInfo(System = "Pharmacy", Section = "Locking", Key = "LockResultsRetryInterval", Default = "500")]
        public int LockResultsRetryInterval { get; set; }

        /// <summary>
        /// Provides a singleton instance of this method
        /// The singleton is stored in the pharmacy data cache.
        /// </summary>
        public static LockResultsSettings Instance
        {
            get
            {
                string cachedName = typeof(LockResultsSettings).FullName;

                LockResultsSettings instance = PharmacyDataCache.GetFromCache(cachedName) as LockResultsSettings;
                if (instance == null)
                {
                    instance = new LockResultsSettings();
                    SettingsController.Load<LockResultsSettings>(instance);
                    PharmacyDataCache.SaveToCache(cachedName, instance);
                }

                return instance;
            }
        }
    }
}
