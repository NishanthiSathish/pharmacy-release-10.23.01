//===========================================================================
//
//					       StringBuilderExtensions.cs
//
//  Provides helpful extension methods for StringBuilder.
//
//	Modification History:
//	06Jul11 XN  Created
//  15Aug16 XN  Added ReplaceNoCase 108889
//===========================================================================
using System.Text;

namespace ascribe.pharmacy.shared
{
    /// <summary>Extension methods for the string class</summary>
    static public class StringBuilderExtensions
    {
        //
        // Summary:
        //     Replaces all occurrences of a specified character in this instance with another
        //     specified character.
        //
        // Parameters:
        //   oldChar:
        //     The character to replace.
        //
        //   newChar:
        //     The character that replaces oldChar.
        //
        // Returns:
        //     A reference to this instance with oldChar replaced by newChar.


        /// <summary>Replaces fixed number of occurrences of a specified string in this instance with another specified string.</summary>
        /// <param name="str">this instane</param>
        /// <param name="oldValue">string to replace</param>
        /// <param name="newValue">string to replace oldValue</param>
        /// <param name="count">Number of times to replace</param>
        /// <returns>A reference to this instance with oldChar replaced by newChar.</returns>
        static public StringBuilder Replace(this StringBuilder str, string oldValue, string newValue, int count)
        {
            int index = 0;

            for (; count > 0; count--, index += newValue.Length)
            {
                // Check have not reached end of string
                if (index >= str.Length)
                    return str;

                // Search for next value to replace (end if not present)
                index = str.ToString().IndexOf(oldValue, index);
                if (index < 0)
                    return str;

                // Replace 
                str = str.Remove(index, oldValue.Length).Insert(index, newValue);
            }

            return str;
        }

        /// <summary>Replaces a specified string in this instance with another specified string (case insensitive) 15Aug16 XN 108889</summary>
        /// <param name="str">this instance</param>
        /// <param name="oldValue">string to replace</param>
        /// <param name="newValue">string to replace oldValue</param>
        /// <returns>A reference to this instance with oldChar replaced by newChar.</returns>
        static public StringBuilder ReplaceNoCase(this StringBuilder str, string oldValue, string newValue)
        {
            if (str == null || str.Length == 0 || oldValue.Length == 0)
                return str;

            string temp = str.ToString();
            int sizeDiff = newValue.Length - oldValue.Length;
            int replaceCount = 0;

            int index = temp.IndexOf(oldValue, 0, System.StringComparison.InvariantCultureIgnoreCase);
            while (index != -1 && index < str.Length)
            {
                // Replace 
                int offsetIndex = index + (replaceCount * sizeDiff);
                str = str.Remove(offsetIndex, oldValue.Length).Insert(offsetIndex, newValue);
                replaceCount++;

                // Search for next value to replace
                index = temp.IndexOf(oldValue, index + oldValue.Length, System.StringComparison.InvariantCultureIgnoreCase);
            } 

            return str;
        }

        /// <summary>
        /// Replaces fixed number of occurrences of a specified string in this instance with another specified string.
        /// Starting at end of the string.
        /// </summary>
        /// <param name="str">this instane</param>
        /// <param name="oldValue">string to replace</param>
        /// <param name="newValue">string to replace oldValue</param>
        /// <param name="count">Number of times to replace</param>
        /// <returns>A reference to this instance with oldChar replaced by newChar.</returns>
        static public StringBuilder ReplaceLast(this StringBuilder str, string oldValue, string newValue, int count)
        {
            int index = str.Length;

            for (; count > 0; count--)
            {
                // Check have not reached end of string
                if (index <= 0)
                    return str;

                // Find next last index
                index = str.ToString().LastIndexOf(oldValue, index);
                if (index < 0)
                    return str;

                // Replace
                str = str.Remove(index, oldValue.Length).Insert(index, newValue);
            }

            return str;
        }
    }
}
