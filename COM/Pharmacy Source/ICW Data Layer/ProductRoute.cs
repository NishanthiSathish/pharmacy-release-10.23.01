// -----------------------------------------------------------------------
// <copyright file="ProductRoute.cs" company="Emis Health">
//      Copyright Emis Health Plc
// </copyright>
// <summary>
// Provides access to Product Route table.
//
// Only supports reading.
//
// Modification History:
// 16Sep15 XN   Added 129200 
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.icwdatalayer
{
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

    /// <summary>Row in the ProductRoute table</summary>
    public class ProductRouteRow : BaseRow
    {
        /// <summary>Gets product route id</summary>
        public int ProductRouteID { get { return this.FieldToInt(this.RawRow["ProductRouteID"]).Value; } }

        /// <summary>Gets the product route description</summary>
        public string Description { get { return this.FieldToStr(this.RawRow["Description"], trimString: true, nullVal: string.Empty); } }
    }

    /// <summary>Column info for the ProductRoute table</summary>
    public class ProductRouteColumnInfo : BaseColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="ProductRouteColumnInfo"/> class.</summary>
        public ProductRouteColumnInfo() : base("ProductRoute") { }

        /// <summary>Gets the length of the product description field</summary>
        public int DescriptionLength { get { return this.FindColumnByName("Description").Length; } }        
    }

    /// <summary>Access to the ProductRoute table</summary>
    public class ProductRoute : BaseTable2<ProductRouteRow,ProductRouteColumnInfo>
    {
        /// <summary>Initializes a new instance of the <see cref="ProductRoute"/> class.</summary>
        public ProductRoute() : base("ProductRoute") { }

        /// <summary>Loads all the product routes</summary>
        public void LoadAll()
        {
            this.LoadBySP("pProductRouteAll", new SqlParameter[0]);            
        }

        /// <summary>Returns the first product route by description</summary>
        /// <param name="description">Product route description</param>
        /// <returns>Returns first product route</returns>
        public ProductRouteRow FindByDescription(string description)
        {
            return this.FirstOrDefault(r => description.EqualsNoCaseTrimEnd(r.Description));
        }
    }
}