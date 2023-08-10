//===========================================================================
//
//							       FMDatabase.cs
//
//  The WFMDailyStockLevel and WFMLogCache tables might be in a form of 
//  reporting db rather than the main ICW db, so the FMDatabase class provides 
//  access to the FM database (or if not in-use defaults to the normal ICW DB)
//
//	Modification History:
//	20Aug14 XN  Written
//===========================================================================
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.financemanagerlayer
{
    public class FMDatabase
    {
        #region Member variables
        /// <summary>Cached connection string (don't use this directly call this.FMConnectionString)</summary>
        private static string fmConnectionString = null;
        #endregion

        #region Properties
        /// <summary>Get the connection string for finance manager DB (might not be in same db as ICW)</summary>
        public static string ConnectionString
        {
            get
            {
                if (FMDatabase.fmConnectionString == null)
                {
                    string settingName = "FMConnectionString"; 

                    try
                    {
                        // first tey the App.config
                        Configuration conf = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
                        ConnectionStringSettings setting = conf.ConnectionStrings.ConnectionStrings[settingName];
                        fmConnectionString = setting.ConnectionString;
                    }
                    catch(Exception )
                    {
                        //can't read the app.config file so try the web.config file
                        ConnectionStringSettings setting = WebConfigurationManager.ConnectionStrings[settingName];
                        if (setting != null)
                            fmConnectionString = setting.ConnectionString;
                    }

                    if (string.IsNullOrEmpty(fmConnectionString))
                        fmConnectionString = Database.ConnectionString;
                }

                return fmConnectionString;
            }
        }
        #endregion

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
    }
}
