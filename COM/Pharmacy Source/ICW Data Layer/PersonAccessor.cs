// -----------------------------------------------------------------------
// <copyright file="PersonAccessor.cs" company="Emis Health">
//      Copyright Emis Health.
// </copyright>
// <summary>
// Accessor class for WWardProductListLineRow
//
// Supports interface IQSDisplayAccessor, and the QSBaseProcessor
//  
// Modification History:
// 01Jul15 XN  Created 39882
// </summary>
// -----------------------------------------------------------------------

namespace ascribe.pharmacy.icwdatalayer
{
    using System;
    using ascribe.pharmacy.quesscrllayer;

    /// <summary>Accessor class for PersonRow</summary>
    public class PersonAccessor : IQSDisplayAccessor
    {
        #region IQSDisplayAccessor Members
        /// <summary>the main supported BaseRow type for the accessor (will be PersonRow)</summary>
        public Type SupportedType { get { return typeof(PersonRow); } }

        /// <summary>Tag name for the accessor (links to name in the DB)</summary>
        public string AccessorTag { get { return "Person"; } }

        /// <summary>Returns string suitable for display (on panels and grids) for selected value (propertyName)</summary>
        /// <param name="r">Base row should be of type (PersonRow)</param>
        /// <param name="dataType">Column QS data type</param>
        /// <param name="propertyName">Name of property to return the value for (or special tag name e.g. {description})</param>
        /// <param name="formatOption">Format option for the value</param>
        public string GetValueForDisplay(basedatalayer.BaseRow r, int dataIndex, QSDataType dataType, string propertyName, string formatOption)
        {
            var row = (r as PersonRow);
            switch (propertyName.ToLower())
            {
            case "{fullname}": 
                formatOption = formatOption.ToLower();
                return string.IsNullOrEmpty(formatOption) ? row.ToString() : formatOption.Replace("title", row.Title).Replace("forname", row.Forename).Replace("surname", row.Surname);
            }

            return QSHelper.PharmacyPropertyReader(row, dataType, propertyName, formatOption);
        }
        #endregion
    }
}
