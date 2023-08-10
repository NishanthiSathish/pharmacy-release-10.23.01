//===========================================================================
//
//							    SqlParameterExtensions.cs
//
//  Provides helpful extension methods for SqlParameter (mainly the list).
//
//	Modification History:
//	03Feb14 XN  Written (82433)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace ascribe.pharmacy.shared
{
    /// <summary>Extension methods for the SqlParameter (list) class</summary>
    public static class SqlParameterExtensions
    {
        /// <summary>Add parameter to the list (if value is null replaces it with DBNull)</summary>
        public static void Add(this IList<SqlParameter> list, string name, object value)
        {
            list.Add(new SqlParameter(name, value == null ? DBNull.Value : value));
        }
    }
}
