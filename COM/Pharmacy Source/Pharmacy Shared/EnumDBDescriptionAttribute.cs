//===========================================================================
//
//							   EnumDBDescriptionAttribute.cs
//
//	Provides an attribute to attach DB lookup description strings to enumerated types.
//
//  This attribute is to be used for enumerated types that also support the 
//  EnumViaDBLook attribute. For occurrences where the database description does not 
//  match the enumerated value.
//
//  See EnumViaDBLookupAttribute for more information
//
//  Usage:
//  Declare the enumerated type
//
//      [EnumViaDBLookup(TableName="Status", PKColumn="StatusID", DescriptionColumn="Description")]
//      public enum StatusType
//      {
//          [EnumDBDescription("No Status")]            None,
//          [EnumDBDescription("Ready for processing")] Ready,
//      }
//
//	Modification History:
//	28Apr09 XN  Written
//===========================================================================
using System;

namespace ascribe.pharmacy.shared
{
    public class EnumDBDescriptionAttribute : Attribute
    {
        #region Constructor
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="dbDescription">Description string of the enumerated value in the database</param>
        public EnumDBDescriptionAttribute(string description)
        {
            DBDescription = description;
        }
        #endregion

        #region Properties
        public string DBDescription { get; set; }        
        #endregion
    }
}
