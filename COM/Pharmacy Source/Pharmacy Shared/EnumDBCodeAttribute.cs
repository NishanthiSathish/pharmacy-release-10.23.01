//===========================================================================
//
//							     EnumDBCodeAttribute.cs
//
//	Provides an attribute to attach DB string codes to enumerated types.
//
//  Some pharamcy database fields are single character string codes, this class
//  enables these values to be easily converted to enumerated types using the 
//  FieldToEnumByDBCode and EnumToFieldByDBCode BaseRow functions
//
//  Usage:
//  Declare the enumerated type
//      public enum WOrderLogType
//      {
//          [EnumDBCode("R")]  Receipt,
//          [EnumDBCode("A")]  CostChange,
//          [EnumDBCode("Q")]  BatchUpdate,
//      }
//
//
//  when converting the db field from a string use
//      EnumDBCodeAttribute.DBCodeToEnum<WOrderLogType>("A")
//  or    
//      BaseRow.FieldToEnumByDBCode<WOrderLogType>("A") 
//  will return WOrderLogType.CostChange
//
//  
//  when converting the db field to a string use
//      EnumDBCodeAttribute.EnumToDBCode(WOrderLogType.CostChange)
//  or
//      BaseRow.EnumToFieldByDBCode(WOrderLogType.CostChange) 
//  will return "A"
//
//  It is possible to have multiple db codes for a type (so can handle legacy codes)
//      public enum CIVASIngrdientType
//      {
//          [EnumDBCode("F", "X")] Fixed,
//      :
//  In this case "F" is the main db code returned by EnumDBCodeAttribute.EnumToDBCode(CIVASIngrdientType.Fixed)
//
//	Modification History:
//	15Apr09 XN  Written
//  08Sep14 XN  Added new EnumToDBCode (that has Type passed in) 98658
//  08Jul15 XN  Allows for handling multiple db codes for an enum value 39882
//===========================================================================
namespace ascribe.pharmacy.shared
{
using System;
using System.Linq;
using System.Reflection;

    public class EnumDBCodeAttribute : Attribute
    {
        #region Constructor
        /// <summary>Initializes a new instance of the <see cref="EnumDBCodeAttribute"/> class.</summary>
        /// <param name="dbcode">The db code.</param>
        public EnumDBCodeAttribute(string dbcode)
        {
            this.DBCodes = new[] { dbcode };
        }

        /// <summary>Initializes a new instance of the <see cref="EnumDBCodeAttribute"/> class.</summary>
        /// <param name="dbcode">Main db code.</param>
        /// <param name="args">Old\\alternative db codes</param>
        public EnumDBCodeAttribute(string dbcode, params string[] args)
        {
            this.DBCodes = new string[args.Length + 1];
            this.DBCodes[0] = dbcode;
            for (int i = 0; i < args.Length; i++)
            {
                this.DBCodes[1] = args[0];
            }
        }
        #endregion

        #region Properties
        /// <summary>Db codes supported the default is normally just 1 code</summary>
        private string[] DBCodes { get; set; }        
        #endregion

        #region Public Methods
        /// <summary>
        /// Returns the enumerated values database code.
        /// The enumerated type must have EnumDBCode attributes for each of it members.
        /// </summary>
        /// <typeparam name="T">Enumerated type to convert</typeparam>
        /// <param name="enumValue">Value to convert</param>
        /// <returns>string DB code (or empty string)</returns>
        public static string EnumToDBCode<T>(T enumValue)
        {
            return (from p in typeof(T).GetFields()
                    from a in p.GetCustomAttributes(true)
                    where (a is EnumDBCodeAttribute) && p.GetValue(enumValue).Equals(enumValue)
                    select ((EnumDBCodeAttribute)a).DBCodes[0]).FirstOrDefault();
        }
        public static string EnumToDBCode(Type type, object enumValue)  // 08Sep14 XN  98658
        {
            return (from p in type.GetFields()
                    from a in p.GetCustomAttributes(true)
                    where (a is EnumDBCodeAttribute) && p.GetValue(enumValue).Equals(enumValue)
                    select ((EnumDBCodeAttribute)a).DBCodes[0]).FirstOrDefault();
        }

        /// <summary>
        /// Returns the enumerated value for a database code
        /// The enumerated type must have EnumDBCode attributes for each of it members.
        /// </summary>
        /// <typeparam name="T">Enumerated type to convert</typeparam>
        /// <param name="dbcode">DB code</param>
        /// <returns>enumerated value (returns first enumerated value if no match found)</returns>
        public static T DBCodeToEnum<T>(string dbcode)
        {
            FieldInfo field = (from p in typeof(T).GetFields()
                               from a in p.GetCustomAttributes(true)
                               where (a is EnumDBCodeAttribute) && (((EnumDBCodeAttribute)a).DBCodes.Contains(dbcode))
                               select p).FirstOrDefault();
            if (field == null)
                return default(T);
            else
                return (T)Enum.Parse(typeof(T), field.Name);
        } 
        #endregion
    }
}
