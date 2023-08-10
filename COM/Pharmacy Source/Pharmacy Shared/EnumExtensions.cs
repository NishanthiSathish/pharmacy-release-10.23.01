//===========================================================================
//
//							   EnumExtensions.cs
//
//  Provides helpful extension methods for Enum class.
//
//	Modification History:
//	25Oct11 XN  Written 
//  23Apr13 XN  Prevent ListItemValueToEnum crashing if value not supported 53147
//  07May13 XN  Added more generic EnumIndexInListView so can work with icw 
//              controls 53147
//  15Jul16 XN  126634 Added ForEach at long last!!!
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;

namespace ascribe.pharmacy.shared
{
    public static class EnumExtensions
    {
        /// <summary>
        /// Converts all items in an emumerated type to a ListItem array.
        /// The text part will be the enum item name with '_' replaced by ' '.
        /// The value part will be the enum item as a string.
        /// </summary>
        /// <param name="enumType">An enumerated type</param>
        /// <returns>Enumerated types as ListItem array</returns>
        public static ListItem[] EnumToListItems(Type enumType)
        {
            string[] names = Enum.GetNames(enumType);

            List<ListItem> listItems = new List<ListItem>();
            for(int c = 0; c < names.Length; c++)
                listItems.Add(new ListItem(names[c].Replace('_', ' '), names[c]));

            return listItems.ToArray();
        }

        /// <summary>Takes a list item created with EnumToListItems, and converts it to the enumerated value</summary>
        /// <typeparam name="T">Enumerated type</typeparam>
        /// <param name="itemValue">List item value to EnumToListItems</param>
        /// <returns>The enumeated value (or enum default if value not present)</returns>
        public static T ListItemValueToEnum<T>(string itemValue)
        {
            string value = itemValue.Replace(' ', '_');
            try
            {
                return (T)Enum.Parse(typeof(T), value);
            }
            catch(Exception)
            {
                return default(T);  // added 53147 XN 23Apr13
            }
        }

        /// <summary>
        /// Gets the index of an enummerated value in a drop down list that was populated with EnumToListItems
        /// </summary>
        /// <typeparam name="T">Enumerated type</typeparam>
        /// <param name="dropDownList">Drop down list populated by EnumToListItems</param>
        /// <param name="enumValue">Enum value to find</param>
        /// <returns>Index of enumValue, or -1</returns>
        [Obsolete("Use EnumIndexInListView<T>(ListItemCollection listItems, T enumValue) instead")]
        public static int EnumIndexInListView<T>(DropDownList dropDownList, T enumValue)
        {
            ListItem item = dropDownList.Items.FindByValue(enumValue.ToString());
            return dropDownList.Items.IndexOf(item);
        }

        /// <summary>
        /// Gets the index of an enummerated value in a list that was populated with EnumToListItems
        /// 07May13 XN 53147
        /// </summary>
        /// <typeparam name="T">Enumerated type</typeparam>
        /// <param name="listItems">list items from list populated by EnumToListItems</param>
        /// <param name="enumValue">Enum value to find</param>
        /// <returns>Index of enumValue, or -1</returns>
        public static int EnumIndexInListView<T>(ListItemCollection listItems, T enumValue)
        {
            ListItem item = listItems.FindByValue(enumValue.ToString());
            return listItems.IndexOf(item);
        }

        /// <summary>Performs the specified action on each element of the IEnumerable{T} 15Jul16 XN 126634</summary>
        /// <param name="listItems">list to perform the action on</param>
        /// <param name="action">delegate to perform on each element</param>
        public static void ForEach<T>(this IEnumerable<T> listItems, Action<T> action)
        {
            foreach (T l in listItems)
                action(l);
        }
    }
}
