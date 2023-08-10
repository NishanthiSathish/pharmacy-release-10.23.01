//===========================================================================
//
//							    Product.cs
//
//  Provides access to Product table.
//
//  Class should use BaseTable2 but currently just has a couple of helper functions
//
//  Only supports reading (via helper functions).
//
//	Modification History:
//	18Dec13 XN  Written 78339
//  28Feb14 XN  Updated HasTemplate
//  31Mar14 XN  Added product type option to GetProductIDByDescritpion
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Access to the Product table</summary>
    public class Product
    {
        /// <summary>Returns the product description</summary>
        public static string GetDescriptionByProductID(int productID)
        {
            return Database.ExecuteSQLScalar<string>("SELECT Description FROM Product WHERE ProductID={0}", productID);
        }

        /// <summary>Returns the product id for exact descrtipion match</summary>
        /// <param name="description">Product description to search for</param>
        /// <param name="productType">Product type name (or null for all) e.g. Checmical</param>
        public static int? GetProductIDByDescritpion(string description, string productType = null)
        //public static int? GetProductIDByDescritpion(string description) 31Mar14 XN 
        {
            string sql = string.Format("SELECT p.ProductID FROM Product p " +
                                            "JOIN ProductType pt ON p.ProductTypeID = pt.ProductTypeID " +
                                            "WHERE p.Description='{0}'", description.Replace("'", "''"));
            if (!string.IsNullOrEmpty(productType))
                sql += " AND pt.Description='" + productType.Replace("'", "''") + "'";
            return Database.ExecuteSQLScalar<int?>(sql);
        }

        /// <summary>If the product has any templates assigned to it (or product higher up heiarchy has template)</summary>
        public static bool HasTemplate(int productID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("@ProductID",        productID            );
            return Database.ExecuteScalar<int?>("pOrderTemplateExistByParentProductFamilyForPharm", parameters).HasValue;
        }
    }
}
