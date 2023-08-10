//===========================================================================
//
//							    WConfiguration.cs
//
//  Provides access to WConfiguration table.
//
//  WConfiguration table holds pharmacy specific settings, that were originally
//  stored in the WConfiguration file. The settings are site dependant.
//
//  Supports reading, updating and inserting from the table.
//
//  Though the method supports the standard BaseTable functions, generally only use
//  static methods
//      WConfiguration.LoadAndCache
//      WConfiguration.Save
//
//  Usage
//  To get the config setting 
//  Category: D|PN
//  Section: PNProducts
//  Key: Reload
//  Default is false
//  WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|PN", "PNProducts", "Reload", false, false);
//  
//  to save the above setting
//  WConfiguration.Save<bool>(SessionInfo.SiteID, "D|PN", "PNProducts", "Reload", false, false);
// 
//	Modification History:
//	15Apr09 XN  Written
//  27Apr09 XN  Added LoadBySiteCategorySectionAndKey.
//  24Jul09 XN  Added custom update, and insert methods
//  20Oct11 XN  Moved LoadAndCache, and Save from WCOnfigurationController
//  15Aug13 XN  Added LoadBySiteAndCategory 24653
//  01Nov13 XN  56701 Added FindByKey method 
//  19Dec13 XN  78339 Added LoadByCategorySectionAndKey
//  28Aug14 XN  88922 added hanlding of char type to Load method
//      18Jun15 XN  39882 Update Load to convert enum
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
 
namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Represents a record in the  WConfiguration table</summary>
    public class WConfigurationRow : BaseRow
    {
        public int WConfigurationID
        {
            get { return FieldToInt(RawRow["WConfigurationID"]).Value;  }
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]).Value; }
            set { RawRow["SiteID"] = IntToField(value);      }
        }

        public string Category
        {
            get { return FieldToStr(RawRow["Category"]);  }
            set { RawRow["Category"] = StrToField(value); }
        }

        public string Section
        {
            get { return FieldToStr(RawRow["Section"]);  }
            set { RawRow["Section"] = StrToField(value); }
        }

        public string Key
        {
            get { return FieldToStr(RawRow["Key"]);  }
            set { RawRow["Key"] = StrToField(value); }
        }

        /// <summary>
        /// When getting the data removes start\end quotes returned by database
        /// When setting the value will automatically readds the quotes.
        /// </summary>
        public string Value
        {
            get 
            {
                string value = FieldToStr(RawRow["Value"]);

                if ( !string.IsNullOrEmpty(value) && (value.StartsWith("\"") || value.StartsWith("“")) )
                    value = value.Remove(0, 1);
                if ( !string.IsNullOrEmpty(value) && (value.EndsWith("\"")   || value.EndsWith("”")) )
                    value = value.Remove(value.Length - 1, 1);

                return value;  
            }
            set 
            { 
                RawRow["Value"] = "\"" + value + "\""; 
            }
        }
    }

    public class WConfigurationColumnInfo : BaseColumnInfo
    {
        public WConfigurationColumnInfo() : base("WConfiguration") {}

        public int CategoryLength() { return FindColumnByName("Category").Length; }
        public int SectionLength () { return FindColumnByName("Section").Length;  }
        public int KeyLength     () { return FindColumnByName("Key").Length;      }
        public int ValueLength   () { return FindColumnByName("Value").Length;    }
    }

    /// <summary>Represent the WConfiguration table</summary>
    public class WConfiguration : BaseTable<WConfigurationRow, WConfigurationColumnInfo>
    {
        public WConfiguration() : base("WConfiguration", "WConfigurationID")
        {
            UpdateSP = "pWConfigurationUpdate";
        }

        /// <summary>
        /// Loads WConfiguration setting by site, and category
        /// 15Aug13 XN 24653
        /// </summary>
        /// <param name="siteID">setting site</param>
        /// <param name="category">setting category</param>
        public void LoadBySiteAndCategory(int siteID, string category)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "SiteID",     siteID);
            AddInputParam(parameters, "Category",   category);
            LoadRecordSetStream("pWConfigurationBySiteAndCategory", parameters);
        }

        /// <summary>
        /// Loads WConfiguration setting by site, category, and section.
        /// </summary>
        /// <param name="siteID">setting site</param>
        /// <param name="category">setting category</param>
        /// <param name="section">setting section</param>
        public void LoadBySiteCategoryAndSection ( int siteID, string category, string section)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "SiteID",     siteID);
            AddInputParam(parameters, "Category",   category);
            AddInputParam(parameters, "Section",    section);
            LoadRecordSetStream("pWConfigurationSelectSection", parameters);
        }

        /// <summary>
        /// Loads single WConfiguration row by site, category, section, and key
        /// </summary>
        /// <param name="siteID">setting site</param>
        /// <param name="category">setting category</param>
        /// <param name="section">setting section</param>
        /// <param name="key">setting key</param>
        public void LoadBySiteCategorySectionAndKey ( int siteID, string category, string section, string key)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "LocationID_Site",siteID);
            AddInputParam(parameters, "Category",       category);
            AddInputParam(parameters, "Section",        section);
            AddInputParam(parameters, "Key",            key);
            LoadRecordSetStream("pWConfigurationSelectValue", parameters);
        }

        /// <summary>Loads WConfiguration row by category, section, and key (for all sites) 18Dec13 XN 78339</summary>
        /// <param name="category">setting category</param>
        /// <param name="section">setting section</param>
        /// <param name="key">setting key</param>
        public void LoadByCategorySectionAndKey(string category, string section, string key)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "Category",       category);
            AddInputParam(parameters, "Section",        section);
            AddInputParam(parameters, "Key",            key);
            LoadRecordSetStream("pWConfigurationByCategorySectionAndKey", parameters);
        }

        /// <summary>
        /// Returns first item with the specified key (else null)
        /// The comparison is case insensitive.
        /// </summary>
        public WConfigurationRow FindByKey(string key)
        {
            return this.FirstOrDefault(c => c.Key.EqualsNoCase(key));
        }

        /// <summary>
        /// Returns all loaded settings who's key is prefixed with keyPrefix value
        /// The comparison is case sensitive.
        /// </summary>
        /// <param name="keyPrefix">Key prifix</param>
        /// <returns>All settings with the specified key prefix</returns>
        public List<WConfigurationRow> FindByKeyStartingWith(string keyPrefix)
        {
            List<WConfigurationRow> list = new List<WConfigurationRow>();

            foreach(WConfigurationRow row in this)
            {
                if (row.Key.StartsWith(keyPrefix))
                    list.Add(row);
            }

            return list;
        }

        /// <summary>
        /// Adds new WConfiguration row, setting the site, category, section and key
        /// The row will not be saved to the database until save is called.
        /// </summary>
        /// <param name="siteID">Rows site ID</param>
        /// <param name="category">Category</param>
        /// <param name="section">Section</param>
        /// <param name="key">Key</param>
        /// <returns>Newly created row</returns>
        public WConfigurationRow Add(int siteID, string category, string section, string key)
        {
            WConfigurationRow newRow = base.Add();
            newRow.SiteID   = siteID;
            newRow.Category = category;
            newRow.Section  = section;
            newRow.Key      = key;
            return newRow;
        }

        /// <summary>
        /// Need to do insert manually as sp parameter don't match db column names
        /// </summary>
        /// <param name="row">Row to insert</param>
        protected override void InsertRow(DataRow row)
        {
            StringBuilder parameters = new StringBuilder();

            // wrap the DataRow in an object
            WConfigurationRow dbrow = new WConfigurationRow();
            dbrow.RawRow = row;

            // Build up parameter list
            AddInputParam(parameters, "LocationID_Site", dbrow.SiteID);
            AddInputParam(parameters, "Category",        dbrow.Category);
            AddInputParam(parameters, "Section",         dbrow.Section);
            AddInputParam(parameters, "Key",             dbrow.Key);
            AddInputParam(parameters, "Value",           dbrow.Value);

            // Perform the insert
            int pk = dblayer.ExecuteInsertSP(SessionInfo.SessionID, TableName, parameters.ToString());

            // update local dataset pk
            row.Table.Columns[PKColumnName].ReadOnly = false;
            row[PKColumnName] = pk;
            row.Table.Columns[PKColumnName].ReadOnly = true;
        }

        /// <summary>
        /// Need to do update manually as sp parameter don't match db column names
        /// </summary>
        /// <param name="row">Row to insert</param>
        protected override void UpdateRow(DataRow row)
        {
            StringBuilder parameters = new StringBuilder();

            // wrap the DataRow in an object
            WConfigurationRow dbrow = new WConfigurationRow();
            dbrow.RawRow = row;

            // Build up parameter list
            AddInputParam(parameters, "WConfigurationID",dbrow.WConfigurationID);
            AddInputParam(parameters, "LocationID_Site", dbrow.SiteID);
            AddInputParam(parameters, "Category",        dbrow.Category);
            AddInputParam(parameters, "Section",         dbrow.Section);
            AddInputParam(parameters, "Key",             dbrow.Key);
            AddInputParam(parameters, "Value",           dbrow.Value);

            // Perform the Update
            dblayer.ExecuteUpdateSP(SessionInfo.SessionID, TableName, parameters.ToString());
        }

        /// <summary>Returns name used to save the setting to cache</summary>
        private static string CreateCacheName(int siteID, string category, string section, string key, bool isCountrySpecific)
        {
            string countryCode = string.Empty;
            if (isCountrySpecific)
                countryCode = PharmacyCultureInfo.CountryCode.ToString("000");

            return string.Format("Pharmacy.WConfigurationController[{0}|{1}{2}|{3}|{4}]", siteID, category, countryCode, section, key);
        }

        /// <summary>
        /// Loads the WConfiguration value from the database.
        /// If the configuration value does not exits in the database, or can't be converted to the required type,
        /// the default value is returned (after being converted to the correct type)
        /// </summary>
        /// <param name="siteID">Id of the site</param>
        /// <param name="category">Configuration category</param>
        /// <param name="section">Configuration section</param>
        /// <param name="key">Configuration key</param>
        /// <param name="defaultValue">default configuration value</param>
        /// <param name="isCountrySpecific">If configuration value is contry specific</param>
        /// <returns>Returns the WConfiguration value or defaultValue if it's not present in the database</returns>
        public static T Load<T>(int siteID, string category, string section, string key, T defaultValue, bool isCountrySpecific)
        {
            StringBuilder parameters = new StringBuilder();

            // If property is contry specific then append the country code to the category.
            if (isCountrySpecific)
                category += PharmacyCultureInfo.CountryCode.ToString("000");

            // Read row from db
            WConfiguration config = new WConfiguration();
            config.LoadBySiteCategorySectionAndKey(siteID, category, section, key);

            // get the string value (if not present use default)
            string strValue;
            if (config.Count > 0)
                strValue = config[0].Value.ToString();
            else
                return defaultValue;

            // Convert from string value to property type
            object objValue;
            Type type = typeof(T);
            try
            {
                if (type == typeof(string))
                    objValue = strValue;    // string type so no conversion
                else if ((type == typeof(int))     || 
                         (type == typeof(uint))    || 
                         (type == typeof(double))  ||
                         (type == typeof(float))   ||
                         (type == typeof(decimal)) ||
                         (type == typeof(char)) )   // 28Aug14 XN added char type 88922
                    objValue = Convert.ChangeType(strValue, type);
                else if (type == typeof(bool))
                    objValue = BoolExtensions.PharmacyParse(strValue);
                else if (type.IsEnum)
                    objValue = Enum.Parse(type, strValue);  // 18Jun15 XN  39882
                else
                    throw new ApplicationException("Unspported property type in WConfigurationController.LoadASetting.");
            }
            catch (FormatException )
            {
                // Conversion failed so try default value. 
                // If that fails it's your own fault for defining incorrect default value.
                objValue = Convert.ChangeType(defaultValue, type);
            }

            return (T)objValue;
        }

        /// <summary>Loads the setting from context cache and if not there loads from db and save it to cache</summary>
        /// <typeparam name="T">setting type</typeparam>
        /// <param name="siteID">Site ID</param>
        /// <param name="category">Configuration category</param>
        /// <param name="section">Configuration section</param>
        /// <param name="key">Configuration key</param>
        /// <param name="defaultValue">Default value (if not present in database)</param>
        /// <param name="isCountrySpecific">If configuration value is contry specific</param>
        /// <returns>Setting value</returns>
        static public T LoadAndCache<T>(int siteID, string category, string section, string key, T defaultValue, bool isCountrySpecific)
        {
            string cacheName = CreateCacheName(siteID, category, section, key, isCountrySpecific);

            object obj = PharmacyDataCache.GetFromContext(cacheName);
            if (obj == null)
            {
                obj = Load<T>(siteID,  category, section, key, defaultValue, isCountrySpecific);
                PharmacyDataCache.SaveToContext(cacheName, obj);
            }

            return (T)obj;
        }

        /// <summary>Save setting to db, either inserting or updating the setting as needed</summary>
        /// <typeparam name="T">setting type</typeparam>
        /// <param name="siteID">Site ID</param>
        /// <param name="category">Configuration category</param>
        /// <param name="section">Configuration section</param>
        /// <param name="key">Configuration key</param>
        /// <param name="value">Value to save</param>
        /// <param name="isCountrySpecific">If setting is country specific</param>
        public static void Save<T>(int siteID, string category, string section, string key, T value, bool isCountrySpecific)
        {
            string cacheName = CreateCacheName(siteID, category, section, key, isCountrySpecific);

            // If property is contry specific then append the country code to the category.
            if (isCountrySpecific)
                category += PharmacyCultureInfo.CountryCode.ToString("000");

            // Save to db
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@CurrentSessionID",SessionInfo.SessionID));
            parameters.Add(new SqlParameter("@LocationID_Site", siteID      ));
            parameters.Add(new SqlParameter("@Category",        category    ));
            parameters.Add(new SqlParameter("@Section",         section     ));
            parameters.Add(new SqlParameter("@Key",             key         ));
            parameters.Add(new SqlParameter("@Value",           '\"' + value.ToString() + '\"'));
            Database.ExecuteSPNonQuery("pWConfigurationWrite", parameters);

            // Remove from cache
            PharmacyDataCache.SaveToContext(cacheName, null);
        }
    }
}
