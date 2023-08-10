// -----------------------------------------------------------------------
// <copyright file="WExtraDrugDetailAccessor.cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Maps the fields in WExtraDrugDetail to QuesScrl data indexes stores in WConfiguration
//
// Modification History:
// 15Jul16 XN  Created 126634
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.pharmacydatalayer
{
    using System;
    using ascribe.pharmacy.quesscrllayer;
    using ascribe.pharmacy.shared;

    /// <summary>Accessor class for WExtraDrugDetailRow</summary>
    public class WExtraDrugDetailAccessor : IQSDisplayAccessor
    {
        MoneyDisplayType moneyDisplayType;

        public WExtraDrugDetailAccessor(MoneyDisplayType moneyDisplayType)
        {
            this.moneyDisplayType = moneyDisplayType;
        }

        #region IQSDisplayAccessor Members
        /// <summary>the main supported BaseRow type for the accessor (will be WExtraDrugDetailRow)</summary>
        public Type SupportedType { get { return typeof(WExtraDrugDetailRow); } }

        /// <summary>Tag name for the accessor (links to name in the DB)</summary>
        public string AccessorTag { get { return "Contracts"; } }

        /// <summary>Returns string suitable for display (on panels and grids) for selected value (propertyName)</summary>
        /// <param name="r">Base row should be of type (PersonRow)</param>
        /// <param name="dataType">Column QS data type</param>
        /// <param name="propertyName">Name of property to return the value for (or special tag name e.g. {description})</param>
        /// <param name="formatOption">Format option for the value</param>
        public string GetValueForDisplay(basedatalayer.BaseRow r, int dataIndex, QSDataType dataType, string propertyName, string formatOption)
        {
            var row = (r as WExtraDrugDetailRow);

            switch (propertyName.ToLower())
            {
            case "{startandenddate}": 
                {
                string str = row.DateOfChange.ToPharmacyDateString();
                if (row.StopDate != null)
                    str += " - " + row.StopDate.ToPharmacyDateString();
                return str;
                }
            case "{supcode+setasdefaultsupplier}":
                {
                string str = row.SupCode;
                if (row.SetAsDefaultSupplier)
                    str += " - Set as default";
                return str;
                }
            case "newcontractprice":
                return row.NewContractPrice.ToMoneyString(this.moneyDisplayType);

            case "sitenumber":
                return Site2.GetSiteIDByNumber(row.LocationID_Site).ToString("000");
            }

            return QSHelper.PharmacyPropertyReader(row, dataType, propertyName, formatOption);
        }
        #endregion
    }
}
