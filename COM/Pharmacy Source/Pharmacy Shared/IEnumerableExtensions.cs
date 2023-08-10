//===========================================================================
//
//							    IEnumerableExtensions.cs
//
//  Provides helpful extension methods for IEnumerable.
//
//	Modification History:
//	03Jan03 XN  Written (F0082255)
//  18Jul13 XN  Added ContainsNoCase 24653
//  11Jun14 XN  Got ToCSVString to use Append rather than AppendFormat (43318)

//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ascribe.pharmacy.shared
{
    /// <summary>Extension methods for the IEnumerable class</summary>
    public static class IEnumerableExtensions
    {
        /// <summary>
        /// Converts the elements to a CSV list.
        /// Calls ToString to convert each item to a string
        /// </summary>	
        /// <typeparam name="T">Type of items in list</typeparam>
        /// <param name="items">List to convert to CSV string</param>
        /// <param name="separator">Item separator</param>
        /// <returns>CSV list of items</returns>
        public static string ToCSVString<T>(this IEnumerable<T> items, string separator)
        {
            StringBuilder str = new StringBuilder();
            foreach (T item in items)
            {
                //str.AppendFormat(item.ToString()); 11Jun14 XN 43318
                //str.AppendFormat(separator);
                str.Append(item.ToString());
                str.Append(separator);
            }

            // Remove last comma
            if (str.Length > 0)
                str.Remove(str.Length - separator.Length, separator.Length);

            return str.ToString();
        }

        /// <summary>Recursivly gets all child elements, and their children</summary>
        /// <typeparam name="T">Type of items in list</typeparam>
        /// <param name="items">List to use</param>
        /// <param name="funcGetParent">Function to return child elements, returns null when no more children</param>
        /// <returns>All children and their children</returns>
        public static IEnumerable<T> Desendants<T>(this IEnumerable<T> items, Func<T, IEnumerable<T>> funcGetChildren)
        {
            List<T> children = new List<T>();

            foreach (T i in items)
            {
                children.Add(i);
                children.AddRange(funcGetChildren(i).Desendants(funcGetChildren));
            }

            return children;
        }

        /// <summary>Returns if value is in the list (ignores case CurrentCultureIgnoreCase)</summary>
        /// <param name="items">List to compare with</param>
        /// <param name="value">String to compare with</param>
        /// <returns>If list contains value (ignores case)</returns>
        public static bool ContainsNoCase(this IEnumerable<string> items, string value)
        {
            return items.Contains(value, StringComparer.CurrentCultureIgnoreCase);
        }
    }
}

