//===========================================================================
//
//							IQSDisplayAccessorExtensions.cs
//
//	IQSDisplayAccessor extension methods
//  
//	Modification History:
//  08Sep14 XN  Written 98658
//  03Jul15 XN  Allowed FindFirstCompatibleRow to handle null BaseRow elements 39882
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.quesscrllayer
{
    /// <summary>Provides helper methods for the IQSDisplayAccessor interface</summary>
    public static class IQSDisplayAccessorExtensions
    {
        /// <summary>Returns the assessor with the specified tag name (else null)</summary>
        public static IQSDisplayAccessor FindByTag(this IEnumerable<IQSDisplayAccessor> accessors, string accessorTag)
        {
            return accessors.FirstOrDefault(a => a.AccessorTag.EqualsNoCase(accessorTag) );
        }

        /// <summary>
        /// Returns first row that is compatible with accessor
        ///     row type == IQSDisplayAccessor.SupportedType
        /// </summary>
        public static BaseRow FindFirstCompatibleRow(this IQSDisplayAccessor accessor, IEnumerable<BaseRow> rows)
        {
            string supportedTypeName = accessor.SupportedType.FullName;
            //return rows.FirstOrDefault(r => supportedTypeName == r.GetType().FullName); 
            return rows.FirstOrDefault(r => r != null && supportedTypeName == r.GetType().FullName);
        }
    }
}
