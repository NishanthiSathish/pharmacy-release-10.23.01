//===========================================================================
//
//							TableInfo.cs
//
//	Gets information about a table's columns, this includes
//      Column name
//      column data type (SQL type and conversion to .NET type)
//      field length (normally only useful for strings)
//      If pk column
//
//  All the information is read directly from the database table rather than 
//  from any meta data table.
//
//  Usage:
//  First load in the information about the table
//      TableInfo tableInfo = new TableInfo();
//      tableInfo.LoadByTableName("WOrder");
//
//  To get the field length of the description column
//      tableInfo.GetFieldLength("Description");         
//   
//  To get the .NET type of the description column
//      tableInfo.FindByName("Description").GetNETType();
//      
//	Modification History:
//	19Jan09 XN  Written
//  21Jul09 XN  Add if field is a pk.
//  21Dec09 XN  Got GetNETType to support smallint
//  03Sep10 XN  (F0082255) Added methods LoadByTableNameAndHierarchy, and GetTableID.
//  07Jul11 XN  Got GetTableID to assert if table not found
//  21Jan13 XN  Add if column is nullable (53875)
//  28Nov16 XN  Changed to BaseTable2, and moved GetNETType to ConvertExtensions.SqlToNETType 147104
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.basedatalayer
{
    public class TableInfoRow : BaseRow
    {
        /// <summary>column nanme</summary>
        public string ColumnName { get { return FieldToStr(RawRow["name"]);          } }

        /// <summary>SQL field type</summary>
        public string Type { get { return FieldToStr(RawRow["type"]);          } }

        /// <summary>DB field size</summary>
        public int Length { get { return FieldToInt(RawRow["length"]).Value;  } }

        /// <summary>If column is a primary key</summary>
        public bool IsPK { get { return FieldToBoolean(RawRow["pk"]).Value; } }

        /// <summary>Returns if the column is nullable 53875 XN 21Jan13 Add if column is nullable</summary>
        public bool IsNullable { get { return FieldToBoolean(RawRow["isnullable"]).Value; } }

        /// <summary>Converts the sql type to a .NET type</summary>
        /// <returns>.NET type</returns>
        public Type GetNETType()
        {
            //switch(Type.ToLower())    28Nov16 XN 147104 moved to ConvertExtensions.SqlToNETType
            //{
            //    case "text": 
            //    case "ntext":
            //    case "varchar":
            //    case "nchar":
            //    case "char":            
            //    case "nvarchar":        return typeof(string);
            //    case "uniqueidentifier":return typeof(Guid);
            //    case "smallint":        return typeof(short);
            //    case "int":             return typeof(int);
            //    case "float":           return typeof(double);
            //    case "datetime":        return typeof(DateTime);
            //    case "decimal":         return typeof(decimal);
            //    case "bit":             return typeof(bool);
            //    case "tinyint":         return typeof(byte);
            //}

            //throw new ApplicationException("Unsupported SQL type " + Type.ToLower());

            return ConvertExtensions.SqlToNETType(this.Type);
        }
    }

    //public class TableInfo : BaseTable<TableInfoRow, BaseColumnInfo>  28Nov16 XN 147104
    public class TableInfo : BaseTable2<TableInfoRow, BaseColumnInfo>
    {
        public TableInfo() : base() { }

        /// <summary>
        /// Loads column information for the table
        /// </summary>
        /// <param name="tableName">DB table name</param>
        public void LoadByTableName(string tableName)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("TableName",        tableName);
            this.LoadBySP("pTrueTableInfo", parameters);
        }

        /// <summary>
        /// Loads column information for the table, and all parent tables in the hierarchy
        /// The list of columns will only contain one pk column (for tableName), and won't
        /// contain the PK's of parent tables (which normally have the same name).
        /// The table hierarchy information is read from the ICW metadata.
        /// </summary>
        /// <param name="tableName">DB table name</param>
        public void LoadByTableNameAndHierarchy(string tableName)
        {
            // Get the parent tables (including itself).
            GenericTable tableHierarchy = new GenericTable(string.Empty, string.Empty);
            tableHierarchy.LoadByXMLSP("pTableByChildTableXML", "tableName", tableName);

            // If tableHierarchy is empty maybe because not registered in [Table]
            // So add to list so can still get table info
            // Other possibility is that the name is wrong
            IEnumerable<string> allTables = tableHierarchy.Select(t => (string)t.RawRow["Description"]);
            if (!allTables.Any())
            {
                allTables = new List<string>();
                ((List<string>)allTables).Add(tableName);
            }

            // Get all columns for this table, and the parent tables
            List<SqlParameter> parameters = new List<SqlParameter>();
            foreach (string name in allTables)
            {
                parameters.Clear();
                parameters.Add("CurrentSessionID",    SessionInfo.SessionID);
                parameters.Add("TableName",           name);
                this.LoadBySP(true, "pTrueTableInfo", parameters);
            }

            // Remove the duplicate PKs.
            List<TableInfoRow> duplicatePKRows = this.Where(r => r.IsPK).ToList();
            this.RemoveAll(duplicatePKRows.Skip(1));
        }

        /// <summary>
        /// Return information about a column.
        /// Must call LoadByTableName first.
        /// </summary>
        /// <param name="name">Column name.</param>
        /// <returns>Column info (or null if column does not exist)</returns>
        public TableInfoRow FindByName(string name)
        {
            foreach(TableInfoRow row in this)
            {
                if (row.ColumnName.Equals(name, StringComparison.InvariantCultureIgnoreCase))
                    return row;
            }

            return null;
        }

        /// <summary>
        /// Returns field size for a column.
        /// Must call LoadByTableName first.
        /// </summary>
        /// <param name="name">Column name.</param>
        /// <returns>field size</returns>
        public int GetFieldLength(string name)
        {
            TableInfoRow info = FindByName(name);
            if (info == null)
                throw new ApplicationException(string.Format("Invalid column name {0}", name));
            return info.Length;
        }

        /// <summary>
        /// Returns table ID (read from ICW [Table] table)
        /// In future maybe better to cache table names and IDs (read using pPharmacyLookupTable function)
        /// Asserts if table not found
        /// </summary>
        /// <param name="name">Table name</param>
        /// <returns>table id</returns>
        public static int GetTableID(string name)
        {
            int tableID = Database.ExecuteSQLScalar<int>("SELECT TableID FROM [Table] WHERE Description = '{0}'", name);
            if ((tableID < 0) || (tableID == 0 && !name.EqualsNoCaseTrimEnd("Table")))
                throw new ApplicationException(string.Format("Table [{0}] has not been registered in the ICW [Table] table.", name));    
            return tableID;
        }

        /// <summary>
        /// Retursn the table name (read from ICW [Table] table)
        /// In future maybe better to cache table names and IDs 
        /// Asserts if table not found
        /// </summary>
        /// <param name="tableID">Table ID</param>
        /// <returns>Table name</returns>
        public static string GetTableName(int tableID)
        {
            string tableName = Database.ExecuteSQLScalar<string>("SELECT Description FROM [Table] WHERE TableID = {0}", tableID);
            if (string.IsNullOrEmpty(tableName))
                throw new ApplicationException(string.Format("TableID {0} does not exist in the ICW [Table] table.", tableID));    
            return tableName;
        }
    }
}
