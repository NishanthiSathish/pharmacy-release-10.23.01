//===========================================================================
//
//						    WConfigurationController.cs
//
//	This class is obsolete use methods on WConfiguration first.
//      
//	Modification History:
//	03Jun09 XN  Created
//  09Sep10 XN  Added LoadAndCache (F0054531)
//  17May11 XN  Added LoadAndCache method with siteID paremeter
//  20Oct11 XN  Made obsolete
//  08Feb12 XN  Added method LoadByCategoryAndSection
//  29Oct13 XN  Removed unused funcitons for loading data by properties
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using TRNRTL10;
using System.Data;
using System.Reflection;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Configuration;

namespace ascribe.pharmacy.shared
{
    [Obsolete]
    public class WConfigurationController
    {
        #region Public Methods
        /// <summary>
        /// Loads the WConfiguration value from the database.
        /// If the configuration value does not exits in the database, 
        /// or can't be converted to the required type. 
        /// The default value is returned (after being converted to the correct type)
        /// </summary>
        /// <param name="siteID">Id of the site</param>
        /// <param name="category">Configuration category</param>
        /// <param name="section">Configuration section</param>
        /// <param name="key">Configuration key</param>
        /// <param name="defaultValue">default configuration value</param>
        /// <param name="isCountrySpecific">If configuration value is contry specific</param>
        /// <param name="type">Converts the value read from the database to this specific type</param>
        /// <returns>Returns the WConfiguration value or defaultValue if it's not present in the database</returns>
        public static object LoadASetting(int siteID, string category, string section, string key, string defaultValue, bool isCountrySpecific, Type type)
        {
            Transport     dblayer    = new Transport();        
            StringBuilder parameters = new StringBuilder();

            // If property is contry specific then append the country code to the category.
            if (isCountrySpecific)
                category += PharmacyCultureInfo.CountryCode.ToString("000");

            // Read row from db
            parameters.Append(dblayer.CreateInputParameterXML("LocationID_Site",Transport.trnDataTypeEnum.trnDataTypeInt,      4, siteID));
            parameters.Append(dblayer.CreateInputParameterXML("Category",       Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, category));
            parameters.Append(dblayer.CreateInputParameterXML("Section",        Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, section));
            parameters.Append(dblayer.CreateInputParameterXML("Key",            Transport.trnDataTypeEnum.trnDataTypeVarChar, 50, key));

            DataSet ds = dblayer.ExecuteSelectSP(SessionInfo.SessionID, "pWConfigurationSelectValue", parameters.ToString());

            // get the string value (if not present use default)
            string strValue;
            if (ds.Tables[0].Rows.Count > 0)
            {
                strValue = ds.Tables[0].Rows[0]["Value"].ToString();

                // Remove any quote marks form the value
                if (strValue.StartsWith("\"") || strValue.StartsWith("“"))
                    strValue = strValue.Remove(0, 1);
                if (strValue.EndsWith("\"")   || strValue.EndsWith("”"))
                    strValue = strValue.Remove(strValue.Length - 1, 1);
            }
            else
                strValue = defaultValue;

            // Convert from string value to property type
            object objValue;
            try
            {
                if (type == typeof(string))
                    objValue = strValue;    // string type so no conversion
                else if ((type == typeof(int))     || 
                         (type == typeof(uint))    || 
                         (type == typeof(double))  ||
                         (type == typeof(float))   ||
                         (type == typeof(decimal)))
                    objValue = Convert.ChangeType(strValue, type);
                else if (type == typeof(bool))
                    objValue = BoolExtensions.PharmacyParse(strValue);
                else
                    throw new ApplicationException("Unspported property type in WConfigurationController.LoadASetting.");
            }
            catch (FormatException )
            {
                // Conversion failed so try default value. 
                // If that fails it's your own fault for defining incorrect default value.
                objValue = Convert.ChangeType(defaultValue, type);
            }

            return objValue;
        }

        /// <summary>Loads the setting from context cache and if not there loads from db and save it to cache</summary>
        /// <typeparam name="T">setting type</typeparam>
        /// <param name="category">Configuration category</param>
        /// <param name="section">Configuration section</param>
        /// <param name="key">Configuration key</param>
        /// <param name="defaultValue">Default value (if not present in database)</param>
        /// <returns>Setting value</returns>
        static public T LoadAndCache<T>(string category, string section, string key, string defaultValue, bool isCountrySpecific)
        {
            return LoadAndCache<T>(SessionInfo.SiteID, category, section, key, defaultValue, isCountrySpecific);
        }

        /// <summary>Loads the setting from context cache and if not there loads from db and save it to cache</summary>
        /// <typeparam name="T">setting type</typeparam>
        /// <param name="siteID">Site ID</param>
        /// <param name="category">Configuration category</param>
        /// <param name="section">Configuration section</param>
        /// <param name="key">Configuration key</param>
        /// <param name="defaultValue">Default value (if not present in database)</param>
        /// <returns>Setting value</returns>
        static public T LoadAndCache<T>(int siteID, string category, string section, string key, string defaultValue, bool isCountrySpecific)
        {
            string countryCode = string.Empty;
            if (isCountrySpecific)
                countryCode = PharmacyCultureInfo.CountryCode.ToString("000");

            string cacheName = string.Format("Pharmacy.WConfigurationController[{0}|{1}{2}|{3}|{4}]", siteID, category, countryCode, section, key);

            object obj = PharmacyDataCache.GetFromContext(cacheName);
            if (obj == null)
            {
                obj = LoadASetting(siteID,  category, section, key, defaultValue, isCountrySpecific, typeof(T));
                PharmacyDataCache.SaveToContext(cacheName, obj);
            }

            return (T)obj;
        }

        /// <summary>
        /// Loads all configuration options with the specified category, and section.
        /// Returns them as Key (db Key), Value (db Value) pair 
        /// Value will have the " characters removed.
        /// </summary>
        /// <param name="siteID">Pharamcy site</param>
        /// <param name="category">WCOnfiguration category</param>
        /// <param name="section">WCOnfiguration section</param>
        /// <param name="isCountrySpecific">If country specific data</param>
        /// <returns>Returns key and value pairs</returns>
        static public IDictionary<string, string> LoadByCategoryAndSection(int siteID, string category, string section, bool isCountrySpecific)
        {
            Dictionary<string,string> results = new Dictionary<string,string>();

            // If property is contry specific then append the country code to the category.
            if (isCountrySpecific)
                category += PharmacyCultureInfo.CountryCode.ToString("000");

            DataSet data = new DataSet();
            string sql = string.Format("SELECT DISTINCT [Key], [Value] FROM WCONfiguration WHERE SiteID={0} AND Category Like '{1}' AND Section Like '{2}'",  siteID, category, section);
            using (SqlDataAdapter adapter = new SqlDataAdapter(sql, WConfigurationController.ConnectionString))
            {
                adapter.Fill(data);

                foreach (DataRow row in data.Tables[0].Rows)
                {
                    string key   = row["Key"].ToString();
                    string value = row["Value"].ToString();

                    // Remove WConfiguration quotes
                    if (value.StartsWith("\""))
                        value = value.Remove(0, 1);
                    if (value.EndsWith("\""))
                        value = value.Remove(value.Length - 1, 1);

                    // Add
                    results.Add (key, value);
                }
            }            

            return results;
        }
        #endregion

        #region Private Methods
        /// <summary>Get the connection string</summary>
        private static string ConnectionString
        {
            get
            {
                string connectionString;

                string settingName = "TRNRTL10.My.MySettings.ConnectionString"; 

                try
                {
                    // first tey the App.config
                    Configuration conf = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
                    ConnectionStringSettings setting = conf.ConnectionStrings.ConnectionStrings[settingName];
                    connectionString = setting.ConnectionString;
                }
                catch(Exception )
                {
                    //can't read the app.config file so try the web.config file
                    ConnectionStringSettings setting = WebConfigurationManager.ConnectionStrings[settingName];
                    connectionString = setting.ConnectionString;
                }

                if (string.IsNullOrEmpty(connectionString))
                    throw new ApplicationException("Connection string undefiend");

                return connectionString;
            }
        }
        #endregion
    }
}
