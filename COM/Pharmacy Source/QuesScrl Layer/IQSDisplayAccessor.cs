//===========================================================================
//
//							     IQSDisplayAccessor.cs
//
//	QuesScrol display accessor.
//  
//  Use by accessor classes that supports being able to return data purley 
//  for display purposes in grid, and panels.
//
//  Normaly there will be related rows in the QSDisplayItem, and QSField tables,
//  that determine how the value will be displayed.
//
//	Modification History:
//  08Sep14 XN  Written 98658
//===========================================================================
using System;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.quesscrllayer
{
    /// <summary>Accessor class can return data purley for display purposes</summary>
    public interface IQSDisplayAccessor
    {
        /// <summary>the main supported BaseRow type for the accessor</summary>
        Type SupportedType { get; }

        /// <summary>Tag name for the accessor (links to name in the DB)</summary>
        string AccessorTag { get; }

        /// <summary>Returns string suitable for display (on panels and grids) for selected value (propertyName)</summary>
        /// <param name="r">Base row should be of accessor class</param>
        /// <param name="dataType">Column QS data type</param>
        /// <param name="propertyName">Name of property to return the value for (or special tag name e.g. {description})</param>
        /// <param name="formatOption">Format option for the value</param>
        string GetValueForDisplay(BaseRow row, int dataIndex, QSDataType dataType, string propertyName, string formatOption);
    }
}
