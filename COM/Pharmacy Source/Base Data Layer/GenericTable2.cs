//===========================================================================
//
//							       GenericTable2.cs
//
//  This is a dirty little class that allows custom sp's to be run within pharmacy
//  without the need to create a completely new set of classes.
//  Should be used sparingly.
//
//  Generally the class will only be used for reading custom sp from the db,
//  though there is no reason why it can’t update, insert or delete data.
//
//  GenericTable2 is a replacement to GenericTable and is derived from BaseTable2
//  so does not go through the ICW transport layer.
//
//  Usage:
//
//  List<SqlParameter> parameters = new List<SqlParameter>();
//  parameters.Add(new SqlParameter("@CurrentSessionID", 1924 ));
//  parameters.Add(new SqlParameter("@SiteID",           15   ));
//  GenericTable2 productInfo  = new GenericTable2();
//  productInfo.LoadBySP("pWProductWithStock", parameters);
//  
//  string  NSVCode  = productInfo[0].RawRow["siscode"];
//  decimal stocklvl = decimal.Parse(productInfo[0].RawRow["stocklvl"]);
//
//	Modification History:
//  05Jul13 XN  Written (27252)
//  18Feb14 XN  Added LoadBySQLFromXML
//  22Aug14 XN  Made LoadFromXMLString Obsolete as XML comes back different on some live servers
//  15Oct15 XN  Added constructor with inherited tables 77977
//===========================================================================
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System;

namespace ascribe.pharmacy.basedatalayer
{
    /// <summary>Allows quick way to run custom sps without need for creating a classes</summary>
    public class GenericTable2 : BaseTable2<BaseRow, BaseColumnInfo> 
    {
        /// <summary>Constructor</summary>
        public GenericTable2() : base() { }

        public GenericTable2(string tableName) : base(tableName) { }

        /// <summary>Constructor 15Oct15 XN 77977</summary>
        /// <param name="tableName">Name of db table class is associated with</param>
        /// <param name="inheritedTableNames">List of inherited tables names the base table should be last in list (e.g. "EpisodeOrder", "Request")</param>
        public GenericTable2(string tableName, params string[] inheritedTableNames) : base(tableName, inheritedTableNames) { }

        /// <summary>Exposes the base class method 24653 26Jul13 XN</summary>
        public new void CreateEmpty()
        {
            base.CreateEmpty();
        }

        /// <summary>
        /// Loads in data from a SQL string that returns datasets.
        /// The SQL string should return a singe table dataset
        /// </summary>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL Parameters for the SQL command</param>
        public void LoadBySQL(string sql, IEnumerable<SqlParameter> parameters)
        {
            base.LoadFromDataSet(false, sql, parameters, CommandType.Text);
        }

        /// <summary>
        /// Loads in data from a sp that returns datasets.
        /// The sp should return a singe table dataset
        /// </summary>
        /// <param name="sp">sp Name</param>
        /// <param name="parameters">SQL Parameters for the SQL command</param>
        public void LoadBySP(string sp, IEnumerable<SqlParameter> parameters)
        {
            base.LoadFromDataSet(false, sp, parameters, CommandType.StoredProcedure);
        }

        /// <summary>
        /// Loads in data from a sql that returns XML.
        /// The sp should return a singe table dataset
        /// 18Feb14 XN 
        /// </summary>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL Parameters for the SQL command</param>
        [Obsolete]
        public void LoadBySQLFromXML(string sql, params object[] parameters)
        {
            base.LoadFromXMLString(sql, parameters);
        }
        
        /// <summary>Instance verions of GetColumnInfo (used by Generic Table) 26Jul13 24653</summary>
        protected override BaseColumnInfo GetColumnInfo_InstanceVersion()
        {
            BaseColumnInfo columnInfo = new BaseColumnInfo(this.TableName);
            columnInfo.LoadColumnInfo();
            if (columnInfo.tableInfo.Count == 0)
                throw new ApplicationException("Invalid table name '" + this.TableName + "'");
            return columnInfo;
        }
    }
}
