//===========================================================================
//
//							        AuditLog.cs
//
//	Provides functions for wiriting to the ICW AuditLog table
//
//  Usage:
//  AuditLog.Write("Request", 167, 0, AuditLogType.Insert, "<Request RequestID="167" ... />");
//      
//	Modification History:
//	05Mar12 XN  Written
//  23Apr13 XN  GetTableID if table not in Table table then set to MinValue 53147
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Transactions;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.basedatalayer
{
    public enum AuditLogType
    {
        [EnumDBCode("I")]
        Insert,

        [EnumDBCode("U")]
        Update,

        [EnumDBCode("D")]
        Delete,
    }

    public class AuditLog
    {
        private struct AuditLogColumnInfo
        {
            public int UserLength;
            public int TerminalLength;
            public int DataXMLLength;
        }

        public static void Write(string table, int pk, int pkB, AuditLogType logType, string xml)
        {
            try
            {
                AuditLogColumnInfo auditLogColumnInfo = GetColumnInfo();
                
                Guid activityID = (Transaction.Current == null) ? Guid.NewGuid() : AuditLog.GetGuidForTransaction(Transaction.Current.TransactionInformation);

                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add(new SqlParameter("@table", table));
                parameters.Add(new SqlParameter("@tableID", AuditLog.GetTableID(table)));
                parameters.Add(new SqlParameter("@primaryKey", pk));
                parameters.Add(new SqlParameter("@user", SessionInfo.Fullname.SafeSubstring(0, auditLogColumnInfo.UserLength)));
                parameters.Add(new SqlParameter("@entityID_User", SessionInfo.EntityID));
                parameters.Add(new SqlParameter("@createdDate", DateTime.Now));
                parameters.Add(new SqlParameter("@terminal", SessionInfo.Terminal.SafeSubstring(0, auditLogColumnInfo.TerminalLength)));
                parameters.Add(new SqlParameter("@locationID", SessionInfo.LocationID));
                parameters.Add(new SqlParameter("@logType", EnumDBCodeAttribute.EnumToDBCode(logType)));
                parameters.Add(new SqlParameter("@dataXML", xml));
                parameters.Add(new SqlParameter("@primaryKeyB", pkB));
                parameters.Add(new SqlParameter("@activityID", activityID));
                Database.ExecuteSQLNonQuery("INSERT INTO AuditLog ([Table], [TableID], [PrimaryKey], [User], EntityID_User, [CreatedDate], [Terminal], [LocationID], [LogType], DataXML, [PrimaryKeyB], [ActivityID]) VALUES (@table, @tableID, @primaryKey, @user, @entityID_User, @createdDate, @terminal, @locationID, @logType, @dataXML, @primaryKeyB, @activityID)", parameters);
            }
            catch (Exception ex)
            {
#if DEBUG
                throw ex;   // Don't want simple thing like locking of audit log table to effect rest of app so ignore error in production
#endif
            }
        }

        private static int GetTableID(string tableName)
        {
            string cachName = typeof(AuditLog).FullName + ".GetTableID";
            Dictionary<string,int> tableNameToIDMap;
            int tableID;

            tableNameToIDMap = (PharmacyDataCache.GetFromCache(cachName) as Dictionary<string,int>);
            if (tableNameToIDMap == null)
                tableNameToIDMap = new Dictionary<string,int>();

            if (!tableNameToIDMap.TryGetValue(tableName, out tableID))
            {
                // Get table ID
                try
                {
                    tableID = TableInfo.GetTableID(tableName);
                }
                catch(Exception)
                {
                    tableID = int.MinValue; // If table not  in Table then just default to min (as overlord does) 53147 XN 23Apr13
                }

                // Create copy to prevent thread issues
                tableNameToIDMap = new Dictionary<string,int>(tableNameToIDMap);

                // Add to cache and save
                tableNameToIDMap.Add(tableName, tableID);
                PharmacyDataCache.RemoveFromCache(cachName);
                PharmacyDataCache.SaveToCache(cachName, tableNameToIDMap);
            }

            return tableID;
        }

        private static AuditLogColumnInfo GetColumnInfo()
        {
            string cacheName = typeof(AuditLog).FullName + ".GetColumnInfo";
            object obj = PharmacyDataCache.GetFromContext(cacheName);
            AuditLogColumnInfo columnInfo;

            if (obj == null)
            {
                TableInfo tableInfo = new TableInfo();
                tableInfo.LoadByTableName("AuditLog");

                columnInfo = new AuditLogColumnInfo();
                columnInfo.UserLength = tableInfo.GetFieldLength("User");
                columnInfo.TerminalLength = tableInfo.GetFieldLength("Terminal");
                columnInfo.DataXMLLength = tableInfo.GetFieldLength("DataXML");

                PharmacyDataCache.SaveToCache(cacheName, columnInfo);
            }
            else
                columnInfo = (AuditLogColumnInfo)obj;

            return columnInfo;
        }

        /// <summary>Derived a guid for a transaction</summary>
        /// <param name="info">Info on the transaction</param>
        /// <returns>Guid base on the identifier</returns>
        private static Guid GetGuidForTransaction(TransactionInformation info)
        {
            byte[] guidBytes = new byte[16];
            byte[] identifierBytes = ASCIIEncoding.ASCII.GetBytes(info.LocalIdentifier.Replace(":", "").Replace("-", "")).Reverse().ToArray();
            byte[] timeBytes       = System.BitConverter.GetBytes(info.CreationTime.Ticks);
            int i = 0;

            for (; i < timeBytes.Length; i++)
                guidBytes[i] = timeBytes[i];
            for (; i < guidBytes.Length; i++)
                guidBytes[i] = identifierBytes[i - timeBytes.Length];

            return new Guid(guidBytes);
        }
    }
}
