//===========================================================================
//
//							        Database.cs
//
//  Provides function that can be run against the database directly (rather
//  than going through BaseTable, or BaseTable2.
//
//  Usage:
//  Database.ExecuteSPNonQuery("INSERT INTO PNProduct ([InUse], [LocationID_Site], [ForAdult], [ForPead], [PNCode], [Description], [SortIndex], [AqueousOrLipid]) VALUES (0, 24, 1, 1, 'GHER234', 'Product A', 1, 'L')");//
//  Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM PNProduct");
//
//	Modification History:
//	20Oct11 XN  Written
//  06Mar13 XN  58209 Add pharmacy version (if pharamcy exists)
//  19Mar13 XM  78339 Added ExecuteSPReturnValue
//  19Jan14 XN  108617 Added CheckSPExist 
//  25Sep15 XN  Added IfTableExists 77780
//===========================================================================
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Configuration;
using ascribe.pharmacy.shared;
using System.Text;
using System.Xml;

namespace ascribe.pharmacy.basedatalayer
{
    public class Database
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

        /// <summary>For running stored procedures that return result with single value (e.g. select @result)</summary>
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

        /// <summary>For running stored procedures that return a scalar result (e.g. return @result)</summary>
        /// <param name="sp">sp name</param>
        /// <param name="parameters">SQL string formating parameters</param>
        /// <returns>Scalar results, or default(T) if return value is null</returns>
        public static T ExecuteSPReturnValue<T>(string sp, IEnumerable<SqlParameter> parameters)
        {            
            var parameterList = new List<SqlParameter>(parameters);
            
            SqlParameter returnParam = new SqlParameter("returnVal", SqlDbType.Variant);
            returnParam.Direction = ParameterDirection.ReturnValue;
            parameterList.Add(returnParam);

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlCommand sqlCommand = new SqlCommand(sp, connection);
                sqlCommand.CommandType = CommandType.StoredProcedure;
                sqlCommand.Parameters.AddRange(parameterList.ToArray());

                sqlCommand.ExecuteNonQuery();
                connection.Close();
            }

            object scalar = parameterList.Last().Value;
            return (scalar == DBNull.Value) ? default(T) : ConvertExtensions.ChangeType<T>(scalar);
        }

        /// <summary>Used to run an sql comamnd on the database that will return a table with a single field</summary>
        /// <typeparam name="T">Data type of the field</typeparam>
        /// <param name="sql">SQL command to run</param>
        /// <param name="parameters">SQL string formating parameters</param>
        /// <returns>List of item from the table</returns>
        public static IEnumerable<T> ExecuteSQLSingleField<T>(string sql, params object[] parameters)
        {
            string formattedSQL = string.Format(sql, parameters);
            DataSet data = new DataSet();

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                SqlDataAdapter adapter = new SqlDataAdapter();
                adapter.SelectCommand = new SqlCommand(formattedSQL, connection);
                adapter.SelectCommand.CommandType = CommandType.Text;
                adapter.Fill(data);
                connection.Close();
            }

            return data.Tables[0].Rows.Cast<DataRow>().Select(r => ConvertExtensions.ChangeType<T>(r[0]));
        }

        /// <summary>Inserts a link between to tables into a link table (will also write to the audit ICW log)</summary>
        /// <param name="linkTable">Link table the record is to be added to</param>
        /// <param name="field1"></param>
        /// <param name="pk1"></param>
        /// <param name="field2"></param>
        /// <param name="pk2"></param>
        public static void InsertLink(string linkTable, string field1, int pk1, string field2, int pk2)
        {
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                string sql = string.Format("INSERT INTO [{0}] ([{1}], [{2}]) VALUES ({3}, {4})", linkTable, field1, field2, pk1, pk2);
                SqlCommand sqlCommand = new SqlCommand(sql, connection);
                sqlCommand.ExecuteNonQuery();
                connection.Close();
            }

            // Create xml string to write to audit log
            StringBuilder xml = new StringBuilder();
            XmlWriterSettings settings = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            using (XmlWriter writer = XmlWriter.Create(xml, settings))
            {
                writer.WriteStartElement(linkTable);
                writer.WriteAttributeString(field1, pk1.ToString());
                writer.WriteAttributeString(field2, pk2.ToString());
                writer.WriteEndElement();
                writer.Flush();
                writer.Close();
            }
            AuditLog.Write(linkTable, pk1, pk2, AuditLogType.Insert, xml.ToString());
        }

        /// <summary>
        /// 06Mar13 XN 58209
        /// Return the Pharamcy DB version number 
        /// from setting table Pharmacy.Version then Major, Minor, Revision, Patch
        /// </summary>
        public static string GetPharamcyDBVersionNumber()
        {
            return Database.ExecuteScalar<string>("pPharamcyVersion", new List<SqlParameter>());
        }

        /// <summary>
        /// Returns if the SP exists in the DB
        /// XN 19Jan14 108617
        /// </summary>
        /// <param name="sp">SP Name</param>
        /// <returns>If exists</returns>
        public static bool CheckSPExist(string sp)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@SP", sp);
            return Database.ExecuteSQLScalar<int?>("SELECT TOP 1 1 FROM sys.objects WHERE type='P' AND name = @SP", parameters).HasValue;
        }

        /// <summary>Returns true if the table exists 25Sep15 XN 77780</summary>
        /// <param name="tableName">Name of table to check</param>
        /// <returns>If table exists</returns>
        public static bool IfTableExists(string tableName)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@TableName", tableName);
            return Database.ExecuteSQLScalar<ulong?>("SELECT OBJECT_ID(@TableName, 'U')", parameters).HasValue;
        }
        #endregion
    }
}
