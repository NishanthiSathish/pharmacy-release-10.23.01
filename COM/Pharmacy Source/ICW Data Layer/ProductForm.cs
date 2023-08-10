//===========================================================================
//
//							    ProductForm.cs
//
//  Provides access to Product Form table.
//
//  Class should use BaseTable2 but currently just has one function
//
//  Only supports reading (via helper function).
//
//	Modification History:
//	11Sep15 TH Written (TFS) 
//
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Access to the ProductForm table</summary>
    public class ProductForm
    {
        /// <summary>Returns the product Form description</summary>
        public static string GetDescriptionByProductFormID(int productformID)
        {
            return Database.ExecuteSQLScalar<string>("SELECT Description FROM ProductForm WHERE ProductFormID={0}", productformID);
        }

        /// <summary>Returns the product Form description for an associated prescription</summary>
        public static string GetDescriptionByRequestID(int RequestID)
        {
            return Database.ExecuteSQLScalar<string>("SELECT isnull(Description,'') FROM Ingredient left join ProductForm on ProductForm.ProductFormID = Ingredient.ProductFormID WHERE Ingredient.RequestID={0}", RequestID);
        }

    }
}