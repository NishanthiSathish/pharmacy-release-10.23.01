//===========================================================================
//
//							       GenericTable.cs
//
//  This is a dirty little class that allows custom sp's to be run within pharmacy
//  without the need to create a completely new set of classes.
//  Should be used sparingly.
//
//  Generally the class will only be used for reading custom sp from the db,
//  though there is no reason why it can’t update, insert or delete data.
//
//  OBSOLETE AS REPLACED BY GENERICTABLE2
//
//  Usage:
//
//  GenericTable productInfo  = new GenericTable("", "");
//  productInfo.LoadBySP("pWProductWithStock", "SiteID", 15);
//  
//  string  NSVCode  = productInfo[0].RawRow["siscode"];
//  decimal stocklvl = decimal.Parse(productInfo[0].RawRow["stocklvl"]);
//
//	Modification History:
//	03Sep10 XN  Written (F0082255)
//  05Jul13 XN  Made Obsolete as now replaced by GenericTable2
//  26Jul13 XN  Override GetColumnInfo_InstanceVersion so can do inserts 
//              and updates 24653
//===========================================================================
using System;
using System.Linq;
using System.Text;

namespace ascribe.pharmacy.basedatalayer
{
    /// <summary>
    /// Allows quick way to run custom sps without need for creating a classes
    /// </summary>
    [Obsolete]
    public class GenericTable : BaseTable<BaseRow, BaseColumnInfo> 
    {
        /// <summary>Constructor</summary>
        public GenericTable(string tableName, string pkcolumnName) : base(tableName, pkcolumnName)
        {
        }

        /// <summary>
        /// Calls the sp with the specified arguments.
        /// The sp should return the data as a record set.
        /// The list of args must specify the argument name, and then value
        /// e.g.
        ///        productInfo.LoadBySP("pWProductWithStock", "SiteID", 15); 
        /// </summary>
        /// <param name="sp">Stored procedure name</param>
        /// <param name="args">List of sp arguments, specified as name, followed by value</param>
        public void LoadBySP(string sp, params object[] args)
        {
            // check there is a name and value pairing of args
            if ((args.Length % 2) != 0)
                throw new ApplicationException(string.Format("{0}.LoadBySP expects name, and value, pair of arguments e.g. LoadBySP(\"pWProductWithStock\", \"SiteID\", 15)", this.GetType().FullName));

            // Create the parameter list
            StringBuilder parameters = new StringBuilder();
            for (int c = 0; c < args.Count(); c += 2)
            {
                if (!(args[c] is string))
                    throw new ApplicationException(string.Format("{0}.LoadBySP expects name, and value, pair of arguments e.g. LoadBySP(\"pWProductWithStock\", \"SiteID\", 15)", this.GetType().FullName));

                AddInputParam(parameters, (string)args[c], args[c + 1]);
            }

            // Call the sp
            LoadRecordSetStream(sp, parameters);
        }

        /// <summary>
        /// Calls the sp with the specified arguments.
        /// The sp should return the data as XML.
        /// The list of args must specify the argument name, and then value
        /// e.g.
        ///        productInfo.LoadByXMLSP("pWProductWithStock", "SiteID", 15); 
        /// </summary>
        /// <param name="sp">Stored procedure name</param>
        /// <param name="args">List of sp arguments, specified as name, followed by value</param>
        public void LoadByXMLSP(string procedureName, params object[] args)
        {
            // check there is a name and value pairing of args
            if ((args.Length % 2) != 0)
                throw new ApplicationException(string.Format("{0}.LoadByXMLSP expects name, and value, pair of arguments e.g. LoadByXMLSP(\"pWProductWithStock\", \"SiteID\", 15)", this.GetType().FullName));

            // Create the parameter list
            StringBuilder parameters = new StringBuilder();
            for (int c = 0; c < args.Count(); c += 2)
            {
                if (!(args[c] is string))
                    throw new ApplicationException(string.Format("{0}.LoadByXMLSP expects name, and value, pair of arguments e.g. LoadByXMLSP(\"pWProductWithStock\", \"SiteID\", 15)", this.GetType().FullName));

                AddInputParam(parameters, args[c].ToString(), args[c + 1]);
            }

            // Call the sp
            LoadFromXMLString(procedureName, parameters);
        }

        /// <summary>Overrised base class method to so can pass in table name to BaseColumnInfo</summary>
        protected override BaseColumnInfo GetColumnInfo_InstanceVersion()
        {
            BaseColumnInfo columnInfo = new BaseColumnInfo(this.TableName);
            columnInfo.LoadColumnInfo();
            return columnInfo;
        }
    }
}
