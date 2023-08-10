//===========================================================================
//
//							   EnumViaDBLookupAttribute.cs
//
//	Provides an attribute to allow enumerated types to be linked to a db 
//  lookup table's ids.
//
//  This is useful when converting a db field that represents a link to a 
//  lookup table, into a program friendly enumerated type.
//
//  The attribute defines the look table, it's pk, and description columns.
//
//  If the enumerated value text matches the db rows description the link between
//  the two is easy. However where the db description is different, the EnumDBDescription
//  should be used to link the two (see Usage below)
//
//  Usage
//  For db table called Status that contains
//                              StatusID    Description
//                              --------    -----------
//                              1           No Status
//                              2           Ready for processing
//                              3           Processed
//
//  and enumerated type Status
//      [EnumViaDBLookup(TableName="Status", PKColumn="StatusID", DescriptionColumn="Description")]
//      enum Status
//      {
//          [EnumDBDescription("No Status")]            
//          None,       <- Status text does not match db description so use EnumDBDescription
//
//          [EnumDBDescription("Ready for processing")] 
//          Ready,      <- Status text does not match db description so use EnumDBDescription
//
//          Processed   <- Status text does match db description so no real need for EnumDBDescription
//      }
//
//
//  when converting the db lookup field ID use
//      EnumViaDBLookupAttribute.ToEnum<Status>(2);  
//  or    
//      BaseRow.FieldToEnumViaDBLookup<Status>(2);           
//  will return Status.Ready
//
//  
//  when converting the enum to an Id use
//      EnumViaDBLookupAttribute.ToLookupID(Status.Ready)
//  or
//      BaseRow.EnumToFieldViaDBLookup(Status.Ready) 
//  will return 2
//
//
//  there are also function for converting the lookup description to an enum
//      EnumViaDBLookupAttribute.ToLookupDescription(Status.Ready)
//  will return 'Ready for processing'. 
//  This is done via the encoded value not and is not read from the db.
//
//  and to convert the description to an enumb
//      EnumViaDBLookupAttribute.ToEnum("Ready for processing")
//  will return Status.Ready
//  This is done via the encoded value not and is not read from the db.
//
//	Modification History:
//	28Apr09 XN  Written
//  03Jun09 XN  Added methods ToLookupDescription, and ToEnum.
//  20Jan15 XN  Update ToLookupID to allow option to insert new lookup in DB table 26734
//  23Feb15 XN  ToLookupID fix to use description column rather than ID
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Data;
using TRNRTL10;

namespace ascribe.pharmacy.shared
{
    public class EnumViaDBLookupAttribute : Attribute
    {
        #region Properties
        /// <summary>DB table that holds the lookup information</summary>
        public string TableName { get; set; }

        /// <summary>Name of pk column in the lookup table</summary>
        public string PKColumn { get; set; }        

        /// <summary>Name of description column in lookup table</summary>
        public string DescriptionColumn  { get; set; }        
        #endregion

        #region Public Methods
        /// <summary>
        /// Returns the enumerated value's DB ID.
        /// The enumerated type must support EnumViaDBLookupAttribute.
        /// </summary>
        /// <typeparam name="T">Enumerated type to convert</typeparam>
        /// <param name="enumValue">Value to convert</param>
        /// <param name="addIfNotExists">Add the enum description table if it does not exists already exist 20Jan15 XN 26734</param>
        /// <returns>id value in the lookup table</returns>
        public static int ToLookupID<T>(T enumValue, bool addIfNotExists = false)
        {
            // Get the mapping of DB ID to enum (from cache or loaded from db)
            Dictionary<int, T> pkToEnumMapping = GetPKToEnumMapping<T>();

            // Check that the enum is contained in the list.
            // Will be missing if it was not matched to a db row.
            if (!pkToEnumMapping.ContainsValue(enumValue))
            {
                if (addIfNotExists)
                {
                    // If can add value to table then call insert clear the cache, and reload 20Jan15 XN 26734
                    Database.ExecuteSQLNonQuery(
                                                "INSERT INTO [{0}] ([{1}]) VALUES ('{2}')", 
                                                EnumViaDBLookupAttribute.GetTableName<T>(), 
                                                EnumViaDBLookupAttribute.GetDescriptionColumn<T>(), 
                                                EnumViaDBLookupAttribute.ToLookupDescription<T>(enumValue));
                    EnumViaDBLookupAttribute.ClearCachedData<T>();
                    return EnumViaDBLookupAttribute.ToLookupID<T>(enumValue, false);
                }
                else
                {
                    throw new ApplicationException(
                        string.Format(
                            "Enumerated value {0}.{1} does not have a matching lookup in table {2}.",
                            typeof(T).Name,
                            enumValue.ToString(),
                            GetTableName<T>()));
                }
            }

            // Return the db id
            return pkToEnumMapping.First(i => i.Value.Equals(enumValue)).Key;
        }

        /// <summary>
        /// Returns the enumerated value's lookup description.
        /// This is either value set by EnumDBDescription for the 
        /// enumerated type or it's name.
        /// The enumerated type must support EnumViaDBLookupAttribute.
        /// </summary>
        /// <typeparam name="T">Enumerated type to convert</typeparam>
        /// <param name="enumValue">Value to convert</param>
        /// <returns>Lookup description set of the value</returns>
        public static string ToLookupDescription<T>(T enumValue)
        {
            // Get the mapping of DB description to enum (from cache or generated)
            Dictionary<string, T> descriptionToEnumMapping = GetDescriptionToEnumMapping<T>();

            // As all enums have a description of some sort, don't need to check it exsits
            return descriptionToEnumMapping.First( i => i.Value.Equals(enumValue)).Key;
        }

        /// <summary>
        /// Returns the enumerated value, for the DB ID
        /// The enumerated type must support EnumViaDBLookupAttribute.
        /// </summary>
        /// <typeparam name="T">Enumerated type to convert</typeparam>
        /// <param name="id">id value in the lookup table</param>
        /// <returns>enumerated value</returns>
        public static T ToEnum<T>(int id)
        {
            // Get the mapping of DB ID to enum (from cache or loaded from db)
            Dictionary<int, T> pkToEnumMapping = GetPKToEnumMapping<T>();

            // Get enumerated value from the list
            // Will be missing if it was not matched to a db row.
            T enumValue;
            if (!pkToEnumMapping.TryGetValue(id, out enumValue))
                throw new ApplicationException(string.Format("Lookup ID {0} for enumerated type {1}, has no macthc in table {2}.", id, typeof(T).Name, GetTableName<T>()));

            // Returns the enum
            return enumValue;
        } 

        /// <summary>
        /// Returns the enumerated value, for the lookup description
        /// This is either value set by EnumDBDescription for the 
        /// enumerated type or it's name.
        /// The enumerated type must support EnumViaDBLookupAttribute.
        /// </summary>
        /// <typeparam name="T">Enumerated type to convert</typeparam>
        /// <param name="description">description value in the lookup table</param>
        /// <returns>enumerated value</returns>
        public static T ToEnum<T>(string description)
        {
            // Get the mapping of DB descripton to enum (from cache or loaded from db)
            Dictionary<string, T> descriptionToEnumMapping = GetDescriptionToEnumMapping<T>();

            // See if lookup description is in the list
            KeyValuePair<string, T> pair;
            try
            {
                pair = descriptionToEnumMapping.First( i => i.Key.ToLower() == description.ToLower());
            }
            catch (InvalidOperationException)
            {
                // Gets here is there is no matching description so create nicer error.
                throw new ApplicationException(string.Format("Lookup description {0} for enumerated type {1}, has no mactch.", description, typeof(T).Name));
            }

            // Returns the enum
            return pair.Value;
        }
        #endregion

        #region Private Methods
        /// <summary>
        /// Either gets the pk to enum map from the cache,
        /// else creates the map from the db.
        /// The enumerated type must support EnumViaDBLookupAttribute.
        /// </summary>
        /// <typeparam name="T">Enumerated type the map is for</typeparam>
        /// <returns>pk to enum map</returns>
        private static Dictionary<int, T> GetPKToEnumMapping<T>()
        {
            //string cacheName = string.Format("{0}.GetPKToEnumMapping[{1}]", typeof(EnumViaDBLookupAttribute).FullName, typeof(T).FullName); 20Jan15 XN 26734
            string cacheName = GetPKToEnumMappingCacheName<T>();

            // Try to load the map from the cache
            Dictionary<int, T> pkToEnumMapping = (Dictionary<int, T>)PharmacyDataCache.GetFromCache(cacheName);
            if (pkToEnumMapping != null)
                return pkToEnumMapping;

            // map does not exist so load
            pkToEnumMapping = new Dictionary<int, T>();

            // Load all the data from the lookup table, into a sorted map of Description to ID.
            SortedDictionary<string,int> dblookups = GetLookupTable(GetTableName<T>(), GetPKColumn<T>(), GetDescriptionColumn<T>()); 

            // Get all the enumerated type descriptions
            Dictionary<string, T> decriptionToEnumMapping = GetDescriptionToEnumMapping<T>();

            // Match each enumerated description to a description from the database.
            foreach (string description in decriptionToEnumMapping.Keys)
            {
                // Locate the matching db row, based on description.
                // If there is a match add the db row ID, and enum field to the map.
                int ID;
                if (dblookups.TryGetValue(description.ToLower(), out ID))
                    pkToEnumMapping.Add(ID, decriptionToEnumMapping[description]);
            }

            // Save the map to the cache.
            PharmacyDataCache.SaveToCache(cacheName, pkToEnumMapping);

            return pkToEnumMapping;
        }

        /// <summary>Returns the name used to cache PKToEnumMapping for the type 20Jan15 XN 26734</summary>
        /// <typeparam name="T">type of mapping data cached</typeparam>
        /// <returns>name used to cache PKToEnumMapping</returns>
        private static string GetPKToEnumMappingCacheName<T>()
        {
            return string.Format("{0}.GetPKToEnumMapping[{1}]", typeof(EnumViaDBLookupAttribute).FullName, typeof(T).FullName);
        }  

        /// <summary>
        /// Either gets the lookup description to enum map from the cache, else creates the map from the enum.
        /// The enumerated type must support EnumViaDBLookupAttribute.
        /// </summary>
        /// <typeparam name="T">Enumerated type the map is for</typeparam>
        /// <returns>description to enum map</returns>
        private static Dictionary<string, T> GetDescriptionToEnumMapping<T>()
        {
            //string cacheName = string.Format("{0}.GetDescriptionToEnumMapping[{1}]", typeof(EnumViaDBLookupAttribute).FullName, typeof(T).FullName);  20Jan15 XN 26734
            string cacheName = GetDescriptionToEnumMappingCacheName<T>();

            // Try to load the map from the cache
            Dictionary<string, T> descriptionToEnumMapping = (Dictionary<string, T>)PharmacyDataCache.GetFromCache(cacheName);
            if (descriptionToEnumMapping != null)
                return descriptionToEnumMapping;

            // Test it supports EnumViaDBLookupAttribute
            EnumViaDBLookupAttribute attribute = typeof(T).GetCustomAttributes(true).OfType<EnumViaDBLookupAttribute>().FirstOrDefault();
            if (attribute == null)
            {
                string msg = string.Format("Enumerated type {0} requires a {1} attribute.", typeof(T).Name, typeof(EnumViaDBLookupAttribute).Name);
                throw new ApplicationException(msg);
            }

            // map does not exist so load
            descriptionToEnumMapping = new Dictionary<string, T>();

            // Get each enumerated rows description.
            foreach (FieldInfo enumValue in typeof(T).GetFields())
            {
                // GetField returns other information rather than just enums
                // so filter out as enums are literals
                if (enumValue.IsLiteral)
                {
                    // Get the custom description for the enum value
                    EnumDBDescriptionAttribute descriptionAttribute = enumValue.GetCustomAttributes(true).OfType<EnumDBDescriptionAttribute>().FirstOrDefault();

                    // If there is a custom description use this, else use the enum value text
                    string desceiption = (descriptionAttribute == null) ? enumValue.Name : descriptionAttribute.DBDescription;

                    descriptionToEnumMapping.Add(desceiption, (T)Enum.Parse(typeof(T), enumValue.Name));
                }
            }

            // Save the map to the cache.
            PharmacyDataCache.SaveToCache(cacheName, descriptionToEnumMapping);

            return descriptionToEnumMapping;
        }

        /// <summary>Returns the name used to cache DescriptionToEnumMapping for the type 20Jan15 XN 26734</summary>
        /// <typeparam name="T">type of mapping data cached</typeparam>
        /// <returns>name used to cache DescriptionToEnumMapping</returns>
        private static string GetDescriptionToEnumMappingCacheName<T>()
        {
            return string.Format("{0}.GetDescriptionToEnumMapping[{1}]", typeof(EnumViaDBLookupAttribute).FullName, typeof(T).FullName);
        }  

        /// <summary>
        /// Gets table name for the enumerated type.
        /// The enumerated type must support EnumViaDBLookupAttribute.
        /// </summary>
        /// <typeparam name="T">Enumerated type</typeparam>
        /// <returns>Table the enumerated type is linked to</returns>
        private static string GetTableName<T>()
        {
            Type enumType = typeof(T);

            // Test it supports EnumViaDBLookupAttribute, and the table name has been set
            EnumViaDBLookupAttribute attribute = enumType.GetCustomAttributes(true).OfType<EnumViaDBLookupAttribute>().FirstOrDefault();
            if (attribute == null)
            {
                string msg = string.Format("Enumerated type {0} requires a {1} attribute.", enumType.Name, typeof(EnumViaDBLookupAttribute).Name);
                throw new ApplicationException(msg);
            }
            if (string.IsNullOrEmpty(attribute.TableName))
            {
                string msg = string.Format("Need to set {0}.TableName value for enumerated type {1}.", typeof(EnumViaDBLookupAttribute).Name, enumType.Name);
                throw new ApplicationException(msg);
            }

            return attribute.TableName;
        }

        /// <summary>
        /// Gets pk column name for the enumerated type.
        /// The enumerated type must support EnumViaDBLookupAttribute.
        /// </summary>
        /// <typeparam name="T">Enumerated type</typeparam>
        /// <returns>pk column name</returns>
        private static string GetPKColumn<T>()
        {
            Type enumType = typeof(T);

            // Test it supports EnumViaDBLookupAttribute, and the PKColumn has been set
            EnumViaDBLookupAttribute attribute = enumType.GetCustomAttributes(true).OfType<EnumViaDBLookupAttribute>().FirstOrDefault();
            if (attribute == null)
            {
                string msg = string.Format("Enumerated type {0} requires a {1} attribute.", enumType.Name, typeof(EnumViaDBLookupAttribute).Name);
                throw new ApplicationException(msg);
            }
            if (string.IsNullOrEmpty(attribute.PKColumn))
            {
                string msg = string.Format("Need to set {0}.PKColumn value for enumerated type {1}.", typeof(EnumViaDBLookupAttribute).Name, enumType.Name);
                throw new ApplicationException(msg);
            }

            return attribute.PKColumn;
        }

        /// <summary>
        /// Gets description column name for the enumerated type.
        /// The enumerated type must support EnumViaDBLookupAttribute.
        /// </summary>
        /// <typeparam name="T">Enumerated type</typeparam>
        /// <returns>description column name</returns>
        private static string GetDescriptionColumn<T>()
        {
            Type enumType = typeof(T);

            // Test it supports EnumViaDBLookupAttribute, and the DescriptionColumn has been set
            EnumViaDBLookupAttribute attribute = enumType.GetCustomAttributes(true).OfType<EnumViaDBLookupAttribute>().FirstOrDefault();
            if (attribute == null)
            {
                string msg = string.Format("Enumerated type {0} requires a {1} attribute.", enumType.Name, typeof(EnumViaDBLookupAttribute).Name);
                throw new ApplicationException(msg);
            }
            if (string.IsNullOrEmpty(attribute.DescriptionColumn))
            {
                string msg = string.Format("Need to set {0}.DescriptionColumn value for enumerated type {1}.", typeof(EnumViaDBLookupAttribute).Name, enumType.Name);
                throw new ApplicationException(msg);
            }

            return attribute.DescriptionColumn;
        } 

        /// <summary>
        /// read in the data from a db lookup table using sp pPharmacyLookupTable.
        /// Returns a map of description (lower case), to pk value.
        /// </summary>
        /// <param name="tableName">>Name of table to load</param>
        /// <param name="pkcolumnName">pk column of the table</param>
        /// <param name="descriptionColumn">Description or text column to load from the database.</param>
        /// <returns>map of db tables description (lower case), to pk value</returns>
        private static SortedDictionary<string, int> GetLookupTable(string tableName, string pkcolumnName, string descriptionColumn)
        {
            Transport dblayer = new Transport();

            // Read the information from the databse.
            // Done directly against the Transport layer as this is in the shared modules and so can't access BaseTable directly.
            // The sp pPharmacyLookupTable return dataset of table "ID", and "Description" fields
            string parameters = string.Empty;
            parameters += dblayer.CreateInputParameterXML("TableName",            Transport.trnDataTypeEnum.trnDataTypeVarChar, tableName.Length,         tableName);       
            parameters += dblayer.CreateInputParameterXML("PKColumn",             Transport.trnDataTypeEnum.trnDataTypeVarChar, pkcolumnName.Length,      pkcolumnName);
            parameters += dblayer.CreateInputParameterXML("DescriptionColumn",    Transport.trnDataTypeEnum.trnDataTypeVarChar, descriptionColumn.Length, descriptionColumn);

            DataSet ds = dblayer.ExecuteSelectSP(SessionInfo.SessionID, "pPharmacyLookupTable", parameters);

            // Move the data to a sorted list (description is set to lower case).
            SortedDictionary<string, int> lookup = new SortedDictionary<string,int>();
            foreach(DataRow row in ds.Tables[0].Rows)
            {
                object ID           = row["ID"];
                object description  = row["Description"];

                if ((ID != DBNull.Value) && (description != DBNull.Value))
                    lookup.Add(description.ToString().ToLower(), Convert.ToInt32(ID));
            }

            return lookup;
        }

        /// <summary>Clears all cached data used by this class for data type T  20Jan15 XN 26734</summary>
        /// <typeparam name="T">Enum data type</typeparam>
        private static void ClearCachedData<T>()
        {
            PharmacyDataCache.RemoveFromCache(EnumViaDBLookupAttribute.GetPKToEnumMappingCacheName<T>());
            PharmacyDataCache.RemoveFromCache(EnumViaDBLookupAttribute.GetDescriptionToEnumMappingCacheName<T>());
        }
        #endregion
    }
}
