//===========================================================================
//
//							BaseColumnInfo.cs
//
//	Base class to hold info about the columns in a table. The table 
//  information is read directly from the database table itself, rather than 
//  via any ICW meta data.
//
//  The class should be inherited from rather than being used directly, with 
//  the derived class returning column information via a property.
//
//  Usage:
//
//  public class WBatchStockLevelColumnInfo : BaseColumnInfo
//  {
//      public WBatchStockLevelColumnInfo() : base("WBatchStockLevel") { }
//
//      public int DescriptionLength { get { return tableInfo.GetFieldLength("Description"); } }
//      public int BatchNumberLength { get { return tableInfo.GetFieldLength("Batchnumber"); } }
//  }
//      
//	Modification History:
//	30Mar09 XN  Written
//  21Jul09 XN  Changed tableInfo from member variable to public property so 
//                      it can be used by BaeTable
//  03Sep10 XN  Made LoadColumnInfo, so NoteColumnInfo can extended, though 
//              eventually it will replace it. (F0082255)
//  21Jan13 XN  Made tableInfo public (did not change case as effected too many files) 53875
//===========================================================================
using System;

namespace ascribe.pharmacy.basedatalayer
{
    public class BaseColumnInfo
    {
        protected string tableName = string.Empty;       // DB table name 

        /// <summary>
        /// Constructor should be overridden in derived class to set tableName
        /// </summary>
        public BaseColumnInfo()
        {
            this.tableInfo = new TableInfo();
        }

        /// <summary>
        /// Constructor should be call from derived class to set tableName
        /// </summary>
        /// <param name="tableName">db talbe name</param>
        public BaseColumnInfo(string tableName)
        {
            this.tableName = tableName;
            this.tableInfo = new TableInfo();
        }

        /// <summary>Overrides base class method so can get complete note hierarchy.</summary>
        internal void LoadColumnInfo()
        {
            // If no table name then error
            if (string.IsNullOrEmpty(tableName))
                throw new ApplicationException(string.Format("Need to add a constructor passing table name to BaseColumnInfo for class {0}", this.GetType().Name));

            // loads in table info, and info for all child tables
            tableInfo.LoadByTableNameAndHierarchy(tableName);
        }

        /// <summary>
        /// Returns the column info (else null).
        /// </summary>
        /// <param name="columnName">Name of the column</param>
        /// <returns>TableInfoRow that contains the column info</returns>
        public TableInfoRow FindColumnByName(string columnName)
        {
            return tableInfo.FindByName(columnName);
        }

        /// <summary>If table has been loaded</summary>
        internal bool IsLoaded { get { return (tableInfo.Table != null); } }

        /// <summary>Get accces to the table info</summary>
        public TableInfo tableInfo { get; protected set; }
    }
}
