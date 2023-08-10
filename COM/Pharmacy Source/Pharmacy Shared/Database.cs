//===========================================================================
//
//							        Database.cs
//
//  Provides function that can be run against the database directly.
//
//  Basicaly just for use by Pharmacy Shared module as not allowed to use
//  the one provided by Base Data Layer
//
//  Usage:
//  Database.ExecuteSPNonQuery("INSERT INTO PNProduct ([InUse], [LocationID_Site], [ForAdult], [ForPead], [PNCode], [Description], [SortIndex], [AqueousOrLipid]) VALUES (0, 24, 1, 1, 'GHER234', 'Product A', 1, 'L')");//
//  Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM PNProduct");
//
//	Modification History:
//	29May13 XN  Written
//  15Jul15 XN  39882 Added method GetWConfigurationValue
//===========================================================================
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Configuration;

namespace ascribe.pharmacy.shared
{
    internal class Database
    {
        #region Member variables
        /// <summary>Cached connection string (don't use this directly call this.ConnectionString)</summary>
        private static string connectionString = null;
        #endregion

        #region Properties
        /// <summary>Get the connection string</summary>
        public static string ConnectionString
        {
            get
            {
                if (connectionString == null)
                {
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
                }

                return connectionString;
            }
        }
        #endregion

        #region Public Methods
        /// <summary>For running SP that returns nothing</summary>
        /// <param name="sp">sp name</param>
        /// <param name="parameters">SQL string formating parameters</param>
        public static void ExecuteSPNonQuery(string sp, params object[] parameters)
        {
            string formattedSQL = string.Format(sp, parameters);

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlCommand sqlCommand = new SqlCommand(formattedSQL, connection);
                sqlCommand.CommandType = CommandType.StoredProcedure;
                sqlCommand.ExecuteNonQuery();
                connection.Close();
            }
        }

        /// <summary>For running SP that returns nothing</summary>
        /// <param name="sp">sp name</param>
        /// <param name="parameters">SQL parameters</param>
        public static void ExecuteSPNonQuery(string sp, IEnumerable<SqlParameter> parameters)
        {
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlCommand sqlCommand = new SqlCommand(sp, connection);
                sqlCommand.CommandType = CommandType.StoredProcedure;
                sqlCommand.Parameters.AddRange(parameters.ToArray());
                sqlCommand.ExecuteNonQuery();
                connection.Close();
            }
        }

        /// <summary>For running SQL that returns nothing</summary>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL string formating parameters</param>
        public static void ExecuteSQLNonQuery(string sql, params object[] parameters)
        {
            string formattedSQL = string.Format(sql, parameters);

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlCommand sqlCommand = new SqlCommand(formattedSQL, connection);
                sqlCommand.CommandType = CommandType.Text;
                sqlCommand.ExecuteNonQuery();
                connection.Close();
            }
        }

        /// <summary>For running SQL that returns nothing</summary>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL parameters</param>
        public static void ExecuteSQLNonQuery(string sql, IEnumerable<SqlParameter> parameters)
        {
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlCommand sqlCommand = new SqlCommand(sql, connection);
                sqlCommand.CommandType = CommandType.Text;
                sqlCommand.Parameters.AddRange(parameters.ToArray());
                sqlCommand.ExecuteNonQuery();
                connection.Close();
            }
        }

        /// <summary>For running stored procedures that return a scalar result</summary>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL string formating parameters</param>
        /// <returns>Scalar results</returns>
        public static T ExecuteSQLScalar<T>(string sql, params object[] parameters)
        {
            string formattedSQL = string.Format(sql, parameters);
            object scalar;

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlCommand sqlCommand = new SqlCommand(formattedSQL, connection);
                sqlCommand.CommandType = CommandType.Text;

                scalar = sqlCommand.ExecuteScalar();
                connection.Close();
            }

            return (scalar == DBNull.Value) ? default(T) : ConvertExtensions.ChangeType<T>(scalar);
        }

        /// <summary>For running stored procedures that return a scalar result</summary>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL string formating parameters</param>
        /// <returns>Scalar results</returns>
        public static T ExecuteSQLScalar<T>(string sql, IEnumerable<SqlParameter> parameters)
        {
            object scalar;

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlCommand sqlCommand = new SqlCommand(sql, connection);
                sqlCommand.CommandType = CommandType.Text;
                sqlCommand.Parameters.AddRange(parameters.ToArray());

                scalar = sqlCommand.ExecuteScalar();
                connection.Close();
            }

            return (scalar == DBNull.Value) ? default(T) : ConvertExtensions.ChangeType<T>(scalar);
        }

        /// <summary>For running stored procedures that return a scalar result</summary>
        /// <param name="sp">sp name</param>
        /// <param name="parameters">SQL string formating parameters</param>
        /// <returns>Scalar results, or default(T) if return value is null</returns>
        public static T ExecuteScalar<T>(string sp, IEnumerable<SqlParameter> parameters)
        {
            object scalar;

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlCommand sqlCommand = new SqlCommand(sp, connection);
                sqlCommand.CommandType = CommandType.StoredProcedure;
                sqlCommand.Parameters.AddRange(parameters.ToArray());

                scalar = sqlCommand.ExecuteScalar();
                connection.Close();
            }

            return (scalar == DBNull.Value) ? default(T) : ConvertExtensions.ChangeType<T>(scalar);
        }
        
        /// <summary>Runs SQL on db and returns DataTable of results</summary>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL string formating parameters</param>
        /// <returns>Data table of results</returns>
        public static DataTable ExecuteSQLDataTable(string sql, params object[] parameters)
        {
            string formattedSQL = string.Format(sql, parameters);
            DataSet data = new DataSet();

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlDataAdapter adapter            = new SqlDataAdapter();
                adapter.SelectCommand             = new SqlCommand(formattedSQL, connection);
                adapter.SelectCommand.CommandType = CommandType.Text;
                adapter.Fill(data);
                connection.Close();
            }

            return data.Tables[0];
        }
        
        /// <summary>Runs SQL on db and returns DataTable of results</summary>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL parameters</param>
        /// <returns>Data table of results</returns>
        public static DataTable ExecuteSQLDataTable(string sql, IEnumerable<SqlParameter> parameters)
        {
            DataSet data = new DataSet();

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlDataAdapter adapter            = new SqlDataAdapter();
                adapter.SelectCommand             = new SqlCommand(sql, connection);
                adapter.SelectCommand.CommandType = CommandType.Text;
                adapter.SelectCommand.Parameters.AddRange(parameters.ToArray());
                adapter.Fill(data);
                connection.Close();
            }

            return data.Tables[0];
        }
        
        /// <summary>Runs SP on db and returns DataTable of results</summary>
        /// <param name="sql">SQL</param>
        /// <param name="parameters">SQL parameters</param>
        /// <returns>Data table of results</returns>
        public static DataTable ExecuteSPDataTable(string sp, IEnumerable<SqlParameter> parameters)
        {
            DataSet data = new DataSet();

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlDataAdapter adapter            = new SqlDataAdapter();
                adapter.SelectCommand             = new SqlCommand(sp, connection);
                adapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                adapter.SelectCommand.Parameters.AddRange(parameters.ToArray());
                adapter.Fill(data);
                connection.Close();
            }

            return data.Tables[0];
        }

        /// <summary>
        /// Gets value from WConfiguration
        /// If no site id is specified then setting from any site is returned
        /// 15Jul15 XN 39882
        /// </summary>
        /// <typeparam name="T">Type to convert to</typeparam>
        /// <param name="siteId">Site Id</param>
        /// <param name="category">config category</param>
        /// <param name="section">config section</param>
        /// <param name="key">config key</param>
        /// <param name="defaultVal">default value to return if setting does not exist</param>
        /// <returns>Setting value</returns>
        public static T GetWConfigurationValue<T>(int? siteId, string category, string section, string key, T defaultVal)
        {
            string siteCondition = (siteId == null || !SessionInfo.HasSite) ? string.Empty : string.Format(" AND SiteID={0}", siteId);
            string value = Database.ExecuteSQLScalar<string>("SELECT TOP 1 [Value] FROM WConfiguration WHERE [Key]='{0}' {1} AND [Section]='{2}' AND [Category]='{3}' ORDER BY SiteID", key, siteCondition, section, category);
            
            // Strip off opening and closing votes
            if (value.StartsWith("\""))
            {
                value = value.SafeSubstring(1);
            }
            
            if (value.EndsWith("\""))
            {
                value = value.SafeSubstring(0, value.Length - 1);
            }
            
            // Convert
            return ConvertExtensions.ChangeType<T>(value, defaultVal);
        }
        #endregion
    }
}
