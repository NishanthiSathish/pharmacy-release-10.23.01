//===========================================================================
//
//					    PrescriptionStandard.cs
//
//  Provides access to ProductFamily table.
//
//  SP for this object should return all fields from the ProductFamily table, 
//  and a link to the following extra fields
//      Product.ProductTypeID as ProductTypeID_Product
//      Product.ProductTypeID as ProductTypeID_RelatedProduct 
//
//  Only supports reading.
//
//	Modification History:
//	24Jun11 XN  Created
//===========================================================================
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Represents a record in the ProductFamily table</summary>
    public class ProductFamilyRow : BaseRow
    {
        public int ProductID                    { get { return FieldToInt(RawRow["ProductID"]).Value;                   } }
        public int ProductTypeID_Product        { get { return FieldToInt(RawRow["ProductTypeID_Product"]).Value;       } }
        public int RelatedProductID             { get { return FieldToInt(RawRow["RelatedProductID"]).Value;            } }
        public int ProductTypeID_RelatedProduct { get { return FieldToInt(RawRow["ProductTypeID_RelatedProduct"]).Value;} }
    }

    /// <summary>Represent the ProductFamily table</summary>
    public class ProductFamily : BaseTable<ProductFamilyRow, BaseColumnInfo>
    {
        /// <summary>
        /// Gets all products from specified item, up to chemical (note won't return items marked as logical deleted)
        /// e.g. for family true
        ///     Paracetamol                                                             - Chemical
        ///         Paracetamol Tablet                                                  - TM
        ///             Paracetamol 250mg Tablet (Calpol Fast Melts)                    - AMP
        ///                 Paracetamol 250mg Tablets (12 Tablets) (Calpol Fast Melts)  - AMPP
        ///                 Paracetamol 250mg Tablets (24 Tablets) (Calpol Fast Melts)  - AMPP
        ///             Paracetamol 500mg Tablet (Generic Blister)                      - AMP
        ///                 Paracetamol 500mg Tablet (100 Tablets) (Generic Blister)    - AMPP
        ///                 
        /// If pass in product ID for 'Paracetamol 250mg Tablets (12 Tablets) (Calpol Fast Melts)' will return items for
        ///     Paracetamol
        ///     Paracetamol Tablet 
        ///     Paracetamol 250mg Tablet (Calpol Fast Melts)
        ///     Paracetamol 250mg Tablets (12 Tablets) (Calpol Fast Melts)
        ///     
        /// If pass in product ID for 'Paracetamol 500mg Tablet (Generic Blister)' will return items for
        ///     Paracetamol
        ///     Paracetamol Tablet 
        ///     Paracetamol 500mg Tablet (Generic Blister)
        /// </summary>
        /// <param name="relatedProductID">Related product Id</param>
        public void LoadByRelatedProduct(int relatedProductID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "RelatedProductID", relatedProductID);
            AddInputParam(parameters, "IncludeDeleted",   false);
            LoadRecordSetStream("pProductFamilyByRelatedProduct", parameters);
        }

        /// <summary>
        /// Gets all products from specified item, to the AMPP level (note won't return items marked as logical deleted)
        /// e.g. for family true
        ///     Paracetamol                                                             - Chemical
        ///         Paracetamol Tablet                                                  - TM
        ///             Paracetamol 250mg Tablet (Calpol Fast Melts)                    - AMP
        ///                 Paracetamol 250mg Tablets (12 Tablets) (Calpol Fast Melts)  - AMPP
        ///                 Paracetamol 250mg Tablets (24 Tablets) (Calpol Fast Melts)  - AMPP
        ///             Paracetamol 500mg Tablet (Generic Blister)                      - AMP
        ///                 Paracetamol 500mg Tablet (100 Tablets) (Generic Blister)    - AMPP
        ///                 
        /// If pass in product ID for 'Paracetamol 250mg Tablets (12 Tablets) (Calpol Fast Melts)' will return items for
        ///     Paracetamol 250mg Tablets (12 Tablets) (Calpol Fast Melts)
        ///     
        /// If pass in product ID for 'Paracetamol 500mg Tablet (Generic Blister)' will return items for
        ///     Paracetamol 500mg Tablet (Generic Blister)
        ///     Paracetamol 500mg Tablet (100 Tablets) (Generic Blister)
        /// </summary>
        /// <param name="productID"product Id</param>
        public void LoadByProduct(int productID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "ProductID", productID);
            AddInputParam(parameters, "IncludeDeleted",   false);
            LoadRecordSetStream("pProductFamilyByProduct", parameters);
        }
    }
}
