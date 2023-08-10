//===========================================================================
//
//							SettingsController.cs
//
//	Generic class used to read, and save, Settings table values also allows
//  settings to be cached to prevent reloading.
//  Currently the class only loads settings for the 0 role (Everyone).
//
//  Usage:
//  To load a setting direct from database use
//  int interval = SettingsController.Load<int>("Pharmacy", "Locking", "LockResultsRetryInterval", 500);
//
//  For settings that are to loaded multiple times in a single page request
//  int interval = SettingsController.LoadAndCache<int>("Pharmacy", "Locking", "LockResultsRetryInterval", 500);
//      
//	Modification History:
//	19Jan09 XN  Written
//  27Apr09 XN  Removed all static variables by making them local, or storing
//              them in the pharmacy cache. To allow use as web app.
//  29May09 XN  Moved from Base Data Layer to Pharmacy Shared
//  18Jan10 XN  Added more simplified Load, and LoadAndCache methods
//              that should be used from now on (F0042698).
//  14Sep10 XN  F0082255 if Load reads a string from setting database that is 
//              not there, it would return and empty string not the default.
//              So got it to return default value string.
//  01Mar10 XN  Added convert to Guid option in Load method TFS31936
//  29May13 XN  Made methods that use SettingInfoAttribute Obsolete
//              Add Save method, also used method to replace SaveASetting 27038 
//  17Sep13 XN  add convertion of short, and ushort to Load (73326)
//  18Mar15 XN  Method Load added support for nullable types
//  01Oct15 XN  Load added float conversion 130210
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using TRNRTL10;
using System.Data.SqlClient;

namespace ascribe.pharmacy.shared
{
    public static class SettingsController
    {
        #region Private types
        /// <summary>Holds info on properties, and their SettingInfoAttributes</summary>
        private struct SettingClassProperty
        {
            public PropertyInfo property;
            public SettingInfoAttribute settingInfo;
        } 
        #endregion

        #region Public Methods
        /// <summary>
        /// Loads setting values for each property tagged with SettingInfoAttribute.
        /// The method only load settings with role 0 (everyone).
        /// If a setting does not exist in the database the default value will be used.
        /// 
        /// The database values are held as string, so that method will try to convert
        /// them to the property specific type, if this fails the default value will 
        /// be converted instead (and if this fails method will thrown an exception)
        /// </summary>
        /// <typeparam name="T">setting object to update (must have SettingInfo attributes see above)</typeparam>
        /// <param name="System">Setting system (only used if system is not supplier by attribute)</param>
        /// <param name="Section">Setting section (only used if section is not supplier by attribute)</param>
        /// <param name="settingObj">Instance of class that settings are to be loaded to.</param>
        [Obsolete]
        static public void Load<T>(T settingObj)
        {
            // Iterate through each property that has a SettingInfoAttribute,
            // and load the value from that db
            IEnumerable<SettingClassProperty> settingProperties = GetSettingInfoAttributeProperties<T>();
            foreach (SettingClassProperty p in settingProperties)
                LoadASetting(settingObj, p);
        }
        [Obsolete]
        static public void Load<T>(string System, string Section, T settingObj)
        {
            // Iterate through each property that has a SettingInfoAttribute,
            // and load the value from that db
            IEnumerable<SettingClassProperty> settingProperties = GetSettingInfoAttributeProperties<T>();
            foreach (SettingClassProperty p in settingProperties)
            {
                if (string.IsNullOrEmpty(p.settingInfo.System))
                    p.settingInfo.System = System;
                if (string.IsNullOrEmpty(p.settingInfo.Section))
                    p.settingInfo.Section = Section;

                LoadASetting(settingObj, p);
            }
        }

        /// <summary>Loads and converts the setting if it exists (else returns the default value)</summary>
        /// <typeparam name="T">Setting type to convert to</typeparam>
        /// <param name="system">System</param>
        /// <param name="section">Section</param>
        /// <param name="key">Key</param>
        /// <param name="defaultValue">Default value</param>
        /// <returns>Setting value</returns>
        static public T Load<T>(string system, string section, string key, T defaultValue)
        {
            Transport dblayer = new Transport();        
            StringBuilder parameters = new StringBuilder();

            // Read setting from db
            parameters.Append(dblayer.CreateInputParameterXML("System",  Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, system));
            parameters.Append(dblayer.CreateInputParameterXML("Section", Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, section));
            parameters.Append(dblayer.CreateInputParameterXML("Key",     Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, key));

            string strValue = dblayer.ExecuteSelectStreamSP(SessionInfo.SessionID, "pSetting", parameters.ToString());

            // If value is not present the set default
            if (string.IsNullOrEmpty(strValue))
                return defaultValue;

            // Get the data type
            Type type = typeof(T);

            // Convert setting from string value to property type
            T objValue = defaultValue;
            try
            {
                if (type == typeof(string))
                    objValue = (T)Convert.ChangeType(strValue, type);    // string type so no conversion
                else if ((type == typeof(int))     || 
                         (type == typeof(uint))    || 
                         (type == typeof(short))   ||       // 17Sep13 XN 73326
                         (type == typeof(ushort))  ||       // 17Sep13 XN 73326
                         (type == typeof(double))  ||
                         (type == typeof(float))   ||
                         (type == typeof(decimal)))
                {
                    // Try converting from string to numeric. 
                    // If empty string then use default.
                    if (strValue != string.Empty)
                        objValue = (T)Convert.ChangeType(strValue, type);
                }
                else if (type == typeof(bool))
                    objValue = (T)Convert.ChangeType(BoolExtensions.PharmacyParse(strValue), type);
                else if (type == typeof(Guid))
                    objValue = (T)(object)new Guid(strValue);
                else if (Nullable.GetUnderlyingType(type) != null)
                    objValue = ConvertExtensions.ChangeType<T>(strValue);   // 18Mar15 XN Notice did not support nullable types so added
                else
                    throw new ApplicationException("Unspported property type in SettingClassProperty.Load.");
            }
            catch (FormatException )
            {
                // Conversion failed so use default value. 
                objValue = defaultValue;
            }

            return objValue;
        }

        /// <summary>Loads the setting from context cache and if not there loads from db and save it to cache</summary>
        /// <typeparam name="T">setting type</typeparam>
        /// <param name="system">System</param>
        /// <param name="section">Section</param>
        /// <param name="key">Key</param>
        /// <param name="defaultValue">Default value (if not present in database)</param>
        /// <returns>Setting value</returns>
        static public T LoadAndCache<T>(string system, string section, string key, T defaultValue)
        {
            string cacheName =BuildCacheName(system, section, key);

            object obj = PharmacyDataCache.GetFromContext(cacheName);
            if (obj == null)
            {
                obj = Load<T>(system, section, key, defaultValue);
                PharmacyDataCache.SaveToContext(cacheName, obj);
            }

            return (T)obj;
        }

        /// <summary>
        /// Saves setting values for each property tagged with SettingInfoAttribute.
        /// The method will save settings to role 0 (everyone).
        /// If the setting does not already exist in the database then it will be added.
        /// </summary>
        /// <typeparam name="T">setting object to update (must have SettingInfo attributes see above)</typeparam>
        /// <param name="System">Setting system (only used if system is not supplier by attribute)</param>
        /// <param name="Section">Setting section (only used if section is not supplier by attribute)</param>
        /// <param name="settingObj">Instance of class that settings are to be read from.</param>
        [Obsolete]
        static public void Save<T>(T settingObj)
        {
            // Iterate through each property that has a SettingInfoAttribute,
            // and save the value to the db.
            IEnumerable<SettingClassProperty> settingProperties = GetSettingInfoAttributeProperties<T>();
            foreach (SettingClassProperty p in settingProperties)
            {
                //SaveASetting(settingObj, p); 29May13 XN 27038
                string value = p.property.GetValue(settingObj, null).ToString();
                Save(p.settingInfo.System, p.settingInfo.Section, p.settingInfo.Key, value);
            }
        } 
        [Obsolete]
        static public void Save<T>(string System, string Section, T settingObj)
        {
            // Iterate through each property that has a SettingInfoAttribute,
            // and save the value to the db.
            IEnumerable<SettingClassProperty> settingProperties = GetSettingInfoAttributeProperties<T>();
            foreach (SettingClassProperty p in settingProperties)
            {
                if (string.IsNullOrEmpty(p.settingInfo.System))
                    p.settingInfo.System = System;
                if (string.IsNullOrEmpty(p.settingInfo.Section))
                    p.settingInfo.Section = Section;

                //SaveASetting(settingObj, p); 29May13 XN 27038
                string value = p.property.GetValue(settingObj, null).ToString();
                Save(p.settingInfo.System, p.settingInfo.Section, p.settingInfo.Key, value);
            }
        } 

        /// <summary>
        /// Saves setting to db.
        /// Will always save to role 0, and description will be an empty string.
        /// 29May13 XN 27038
        /// </summary>
        static public void Save<T>(string system, string section, string key, T value)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();

            // Check if value exists
            parameters.Add(new SqlParameter("@System",   system     ));
            parameters.Add(new SqlParameter("@Section",  section    ));
            parameters.Add(new SqlParameter("@RoleID",   (object)0  ));
            parameters.Add(new SqlParameter("@Key",      key        ));
            bool exists = Database.ExecuteSQLScalar<int?>("SELECT TOP 1 1 FROM Setting WHERE [System] Like @System AND [Section] Like @Section AND [Key] Like @Key AND RoleID = @RoleID", parameters).HasValue;

            // Can't share parameters between calls to ExecuteSQLScalar
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@System",   system          ));
            parameters.Add(new SqlParameter("@Section",  section         ));
            parameters.Add(new SqlParameter("@RoleID",   (object)0       ));
            parameters.Add(new SqlParameter("@Key",      key             ));
            parameters.Add(new SqlParameter("@Value",    value.ToString()));

            if (exists)
                Database.ExecuteSQLNonQuery("UPDATE Setting SET Value=@Value WHERE [System] Like @System AND [Section] Like @Section AND [Key] Like @Key AND RoleID=@RoleID", parameters);
            else
                Database.ExecuteSQLNonQuery("INSERT INTO Setting ([System], [Section], [Key], Value, Description, RoleID) VALUES (@System, @Section, @Key, @Value, '', @RoleID)", parameters);
        }
        #endregion

        #region Private Methods
        /// <summary>
        /// Returns the names used to store the setting in the pharmacy cache
        /// 29May13 XN 27038
        /// </summary>
        static private string BuildCacheName(string system, string section, string key)
        {
            return string.Format("Pharmacy.Setting[{0}|{1}|{2}]", system, section, key);
        }

        /// <summary>
        /// Gets SettingClassProperty list containing all properties in T that have a SettingInfoAttribute
        /// </summary>
        /// <returns>SettingClassProperty list</returns>
        static private IEnumerable<SettingClassProperty> GetSettingInfoAttributeProperties<T>()
        {
            return from p in typeof(T).GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance)
                   from a in p.GetCustomAttributes(true)
                   where (a is SettingInfoAttribute)
                   select new SettingClassProperty { property = p, settingInfo = (SettingInfoAttribute)a };
        } 

        /// <summary>
        /// Loads the setting from the database.
        /// </summary>
        /// <typeparam name="T">setting object to update (must have SettingInfo attributes see above)</typeparam>
        /// <param name="settingObj">Setting object the value is saved to</param>
        /// <param name="settingProp">Info about the setting</param>
        static private void LoadASetting<T>(T settingObj, SettingClassProperty settingProp)
        {
            Transport dblayer = new Transport();        
            StringBuilder parameters = new StringBuilder();

            // Read setting from db
            parameters.Append(dblayer.CreateInputParameterXML("System",  Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, settingProp.settingInfo.System));
            parameters.Append(dblayer.CreateInputParameterXML("Section", Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, settingProp.settingInfo.Section));
            parameters.Append(dblayer.CreateInputParameterXML("Key",     Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, settingProp.settingInfo.Key));

            string strValue = dblayer.ExecuteSelectStreamSP(SessionInfo.SessionID, "pSetting", parameters.ToString());

            // If value is not present the set default
            if (strValue == null)
                strValue = settingProp.settingInfo.Default;

            // Convert setting from string value to property type
            object objValue;
            try
            {
                if (settingProp.property.PropertyType == typeof(string))
                    objValue = strValue;    // string type so no conversion
                else if ((settingProp.property.PropertyType == typeof(int))     || 
                         (settingProp.property.PropertyType == typeof(uint))    || 
                         (settingProp.property.PropertyType == typeof(double))  ||
                         (settingProp.property.PropertyType == typeof(decimal)))
                {
                    // Try converting from string to numeric. 
                    // If empty string then use default.
                    if (strValue == string.Empty)
                        strValue = settingProp.settingInfo.Default;
                    objValue = Convert.ChangeType(strValue, settingProp.property.PropertyType);
                }
                else if (settingProp.property.PropertyType == typeof(bool))
                    objValue = BoolExtensions.PharmacyParse(strValue);
                else
                    throw new ApplicationException("Unspported property type in SettingClassProperty.Load.");
            }
            catch (FormatException )
            {
                // Conversion failed so try default value. 
                // If that fails it's your own fault for defining incorrect default value.
                objValue = Convert.ChangeType(settingProp.settingInfo.Default, settingProp.property.PropertyType);
            }

            // Set property to converted value
            settingProp.property.SetValue(settingObj, objValue, null);
        }

        // Removed 29Mar13 XN 270378
        ///// <summary>
        ///// Saves a setting to the database
        ///// </summary>
        ///// <typeparam name="T">setting object to update (must have SettingInfo attributes see above)</typeparam>
        ///// <param name="settingObj">Setting object the value is read from</param>
        ///// <param name="settingProp">Info about the setting</param>
        //static private void SaveASetting<T>(T settingObj, SettingClassProperty settingProp)
        //{
        //    Transport dblayer = new Transport();        
        //    StringBuilder parameters = new StringBuilder();

        //    // Try reading setting to determine if it exists
        //    parameters.Append(dblayer.CreateInputParameterXML("System",  Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, settingProp.settingInfo.System));
        //    parameters.Append(dblayer.CreateInputParameterXML("Section", Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, settingProp.settingInfo.Section));
        //    parameters.Append(dblayer.CreateInputParameterXML("Key",     Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, settingProp.settingInfo.Key));

        //    string dbValue = dblayer.ExecuteSelectStreamSP(SessionInfo.SessionID, "pSetting", parameters.ToString());
        //    bool   exists  = (dbValue != null);

        //    // Read the setting from the setting object
        //    dbValue = settingProp.property.GetValue(settingObj, null).ToString();

        //    // Insert of update the setting 
        //    parameters.Append(dblayer.CreateInputParameterXML("Value",       Transport.trnDataTypeEnum.trnDataTypeVarChar,   50, dbValue));
        //    parameters.Append(dblayer.CreateInputParameterXML("RoleID",      Transport.trnDataTypeEnum.trnDataTypeInt,        4, 0));
        //    parameters.Append(dblayer.CreateInputParameterXML("Description", Transport.trnDataTypeEnum.trnDataTypeVarChar, 1024, settingProp.settingInfo.Description));

        //    if (exists)
        //        dblayer.ExecuteUpdateSP(SessionInfo.SessionID, "Setting", parameters.ToString());
        //    else
        //        dblayer.ExecuteInsertSP(SessionInfo.SessionID, "Setting", parameters.ToString());
        //}
        #endregion
    }
}
