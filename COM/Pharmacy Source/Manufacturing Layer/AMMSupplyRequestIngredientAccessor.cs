// -----------------------------------------------------------------------
// <copyright file="AMMSupplyRequestIngredientAccessor.cs" company="Emis Health">
//      Copyright Emis Health.
// </copyright>
// <summary>
// Accessor class for AMMSupplyRequestIngredientRow
//
// Supports interface IQSDisplayAccessor
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.manufacturinglayer
{
    using System;

    using ascribe.pharmacy.pharmacydatalayer;
    using ascribe.pharmacy.quesscrllayer;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;
    using System.Text;

    /// <summary>AMMSupplyRequestIngredientRow accessor</summary>
    public class aMMSupplyRequestIngredientAccessor : IQSDisplayAccessor
    {
        public WProductRow Product { get; set; }

        public BaseRow PersonChecked   { get; set; }
        public BaseRow PersonAssembled { get; set; }

        #region IQSDisplayAccessor Members
        /// <summary>the main supported BaseRow type for the accessor (will be aMMSupplyRequestIngredientRow)</summary>
        public Type SupportedType { get { return typeof(aMMSupplyRequestIngredientRow); } }

        /// <summary>Tag name for the accessor (links to name in the DB)</summary>
        public string AccessorTag { get { return "aMM Supply Request Ingredient"; } }

        /// <summary>Returns string suitable for display (on panels and grids) for selected value (propertyName)</summary>
        /// <param name="r">Base row should be of type (aMMSupplyRequestIngredientRow)</param>
        /// <param name="dataType">Column QS data type</param>
        /// <param name="propertyName">Name of property to return the value for (or special tag name e.g. {description})</param>
        /// <param name="formatOption">Format option for the value</param>
        public string GetValueForDisplay(basedatalayer.BaseRow row, int dataIndex, QSDataType dataType, string propertyName, string formatOption)
        {
            var ingredient = row as aMMSupplyRequestIngredientRow;
            StringBuilder text = new StringBuilder();
            
            switch (propertyName.ToLower())
            {
            case "{qty}"        : return this.Product == null ? string.Empty : string.Format("{0} {1}", ingredient.QtyInIssueUnits.ToString("0.####"), this.Product.PrintformV);
            case "{checkedby}"  : return PersonChecked.ToString() + (string.IsNullOrEmpty(ingredient.SelfCheckReason) ? string.Empty : "<br />Self check:" + ingredient.SelfCheckReason);
            case "{checkedbyon}": 
                if (ingredient.CheckedByDate != null)
                {
                    text.Append(PersonChecked);
                    text.Append(" on ");
                    text.Append(ingredient.CheckedByDate.ToPharmacyDateTimeString());
                    if (!string.IsNullOrEmpty(ingredient.SelfCheckReason))
                        text.Append("<br />Self check:" + ingredient.SelfCheckReason);
                }
                return text.ToString();
            case "{assembledby}": return (ingredient.AssembledByDate == null) ? string.Empty : PersonAssembled.ToString();
            case "{assembledbyon}": 
                if (ingredient.AssembledByDate != null)
                {
                    text.Append(PersonAssembled);
                    text.Append(" on ");
                    text.Append(ingredient.AssembledByDate.ToPharmacyDateTimeString());
                }
                return text.ToString();
            }

            return QSHelper.PharmacyPropertyReader(row, dataType, propertyName, formatOption);
        }
        #endregion
    }
}
