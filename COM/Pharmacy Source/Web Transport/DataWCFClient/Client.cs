using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.ServiceModel;
using System.Data;

namespace ascribe.pharmacy.data.wcfclient
{
	[Guid("B9D1D840-BA61-4B8A-91BA-31ADFA08D866")]
    [ComDefaultInterface(typeof(IClient))]
    [ClassInterface(ClassInterfaceType.None)]
    public class Client : System.EnterpriseServices.ServicedComponent, IClient
    {
        private WSHttpBinding binding;
        private EndpointAddress endpointAddress;
        private WebDataServiceClient proxyClient;
        private string _token;

        public void Initialise(string address, string token)
        {
            try
            {
                binding = new WSHttpBinding();
                binding.MaxReceivedMessageSize              = Int32.MaxValue;
                binding.MaxBufferPoolSize                   = Int32.MaxValue;
                binding.MaxReceivedMessageSize              = Int32.MaxValue;
                binding.ReaderQuotas.MaxDepth               = Int32.MaxValue;
                binding.ReaderQuotas.MaxStringContentLength = Int32.MaxValue;
                binding.ReaderQuotas.MaxArrayLength         = Int32.MaxValue;
                binding.ReaderQuotas.MaxBytesPerRead        = Int32.MaxValue;
                binding.ReaderQuotas.MaxNameTableCharCount  = Int32.MaxValue;
                binding.Security.Mode                       = address.StartsWith("https") ? SecurityMode.Transport : SecurityMode.Message;
                endpointAddress                             = new EndpointAddress(address);
            }
            catch (Exception ex)
            {
                throw this.GetFullException(ex);
            }
            _token = token;
        }

        public ADODB.Recordset ExecuteSelectSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName)
        {
            try
            {
                this.OpenConnection();
                DataSet ds = proxyClient.ExecuteSelectSP(SessionID, Procedure, ParametersXML, FullSessionIDName, SessionID.ToString(), _token);
                DataTable dt = ds.Tables[0];
                return ConvertToRecordset(dt);
            }
            catch (Exception ex)
            {
                throw this.GetFullException(ex);
            }
            finally
            {
                this.CloseConnection();
            }
        }

        public string ExecuteSelectOutputSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName)
        {
            try
            {
                this.OpenConnection();
                return proxyClient.ExecuteSelectOutputSP(SessionID, Procedure, ParametersXML, FullSessionIDName, SessionID.ToString(), _token);
            }
            catch (Exception ex)
            {
                throw this.GetFullException(ex);
            }
            finally
            {
                this.CloseConnection();
            }
        }

        public int ExecuteSelectReturnSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName)
        {
            try
            {
                this.OpenConnection();
                return proxyClient.ExecuteSelectReturnSP(SessionID, Procedure, ParametersXML, FullSessionIDName, SessionID.ToString(), _token);
            }
            catch (Exception ex)
            {
                throw this.GetFullException(ex);
            }
            finally
            {
                this.CloseConnection();
            }
        }

        public int ExecuteUpdateCustomSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName)
        {
            try
            {
                this.OpenConnection();
                return proxyClient.ExecuteUpdateCustomSP(SessionID, Procedure, ParametersXML, FullSessionIDName, SessionID.ToString(), _token);
            }
            catch (Exception ex)
            {
                throw this.GetFullException(ex);
            }
            finally
            {
                this.CloseConnection();
            }
        }

        public int ExecuteInsertSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName)
        {
            try
            {
                this.OpenConnection();
                return proxyClient.ExecuteInsertSP(SessionID, TableName, ParametersXML, FullSessionIDName, SessionID.ToString(), _token);
            }
            catch (Exception ex)
            {
                throw this.GetFullException(ex);
            }
            finally
            {
                this.CloseConnection();
            }
        }

        public int ExecuteUpdateSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName)
        {
            try
            {
                this.OpenConnection();
                return proxyClient.ExecuteUpdateSP(SessionID, TableName, ParametersXML, FullSessionIDName, SessionID.ToString(), _token);
            }
            catch (Exception ex)
            {
                throw this.GetFullException(ex);
            }
            finally
            {
                this.CloseConnection();
            }
        }

        public int ExecuteDeleteSP(int SessionID, string TableName, int PrimaryKey, bool FullSessionIDName)
        {
            try
            {
                this.OpenConnection();
                return proxyClient.ExecuteDeleteSP(SessionID, TableName, PrimaryKey, FullSessionIDName, SessionID.ToString(), _token);
            }
            catch (Exception ex)
            {
                throw this.GetFullException(ex);
            }
            finally
            {
                this.CloseConnection();
            }
        }

        public int ExecuteInsertLinkSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName)
        {
            try
            {
                this.OpenConnection();
                return proxyClient.ExecuteInsertLinkSP(SessionID, TableName, ParametersXML, FullSessionIDName, SessionID.ToString(), _token);
            }
            catch (Exception ex)
            {
                throw this.GetFullException(ex);
            }
            finally
            {
                this.CloseConnection();
            }
        }

        public int ExecuteDeleteLinkSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName)
        {
            try
            {
                this.OpenConnection();
                return proxyClient.ExecuteDeleteLinkSP(SessionID, TableName, ParametersXML, FullSessionIDName, SessionID.ToString(), _token);
            }
            catch (Exception ex)
            {
                throw this.GetFullException(ex);
            }
            finally
            {
                this.CloseConnection();
            }
        }

        static private ADODB.Recordset ConvertToRecordset(DataTable inTable)
        {
            ADODB.Recordset result = new ADODB.Recordset();
            result.CursorLocation = ADODB.CursorLocationEnum.adUseClient;

            ADODB.Fields resultFields = result.Fields;
            System.Data.DataColumnCollection inColumns = inTable.Columns;

            foreach (DataColumn inColumn in inColumns)
            {
                resultFields.Append(inColumn.ColumnName
                    , TranslateType(inColumn.DataType)
                    , inColumn.MaxLength
                    , inColumn.AllowDBNull ? ADODB.FieldAttributeEnum.adFldIsNullable :
                                             ADODB.FieldAttributeEnum.adFldUnspecified
                    , null);
            }

            result.Open(System.Reflection.Missing.Value
                    , System.Reflection.Missing.Value
                    , ADODB.CursorTypeEnum.adOpenStatic
                    , ADODB.LockTypeEnum.adLockOptimistic, 0);

            foreach (DataRow dr in inTable.Rows)
            {
                result.AddNew(System.Reflection.Missing.Value,
                              System.Reflection.Missing.Value);

                for (int columnIndex = 0; columnIndex < inColumns.Count; columnIndex++)
                {
                    resultFields[columnIndex].Value = dr[columnIndex];
                }
            }

            if (result.EOF == false) result.MoveFirst();

            return result;
        }

       
        static ADODB.DataTypeEnum TranslateType(Type columnType)
        {
            switch (columnType.UnderlyingSystemType.ToString())
            {
                case "System.Boolean":
                    return ADODB.DataTypeEnum.adBoolean;

                case "System.Byte":
                    return ADODB.DataTypeEnum.adUnsignedTinyInt;

                case "System.Char":
                    return ADODB.DataTypeEnum.adChar;

                case "System.DateTime":
                    return ADODB.DataTypeEnum.adDate;

                case "System.Decimal":
                    return ADODB.DataTypeEnum.adCurrency;

                case "System.Double":
                    return ADODB.DataTypeEnum.adDouble;

                case "System.Int16":
                    return ADODB.DataTypeEnum.adSmallInt;

                case "System.Int32":
                    return ADODB.DataTypeEnum.adInteger;

                case "System.Int64":
                    return ADODB.DataTypeEnum.adBigInt;

                case "System.SByte":
                    return ADODB.DataTypeEnum.adTinyInt;

                case "System.Single":
                    return ADODB.DataTypeEnum.adSingle;

                case "System.UInt16":
                    return ADODB.DataTypeEnum.adUnsignedSmallInt;

                case "System.UInt32":
                    return ADODB.DataTypeEnum.adUnsignedInt;

                case "System.UInt64":
                    return ADODB.DataTypeEnum.adUnsignedBigInt;

                case "System.Guid":
                    return ADODB.DataTypeEnum.adVariant;

                case "System.Byte[]":
                    return ADODB.DataTypeEnum.adBinary;

                case "System.String":
                default:
                    return ADODB.DataTypeEnum.adVarChar;
            }
        }

        private void OpenConnection()
        {
            if (this.proxyClient == null)
            {
                this.proxyClient = new WebDataServiceClient(binding, endpointAddress);
            }
        }

        private void CloseConnection()
        {
            try
            {
                this.proxyClient.Close();
            }
            catch (Exception ex)
            {
                this.proxyClient.Abort();
            }

            this.proxyClient.InnerChannel.Dispose();
            this.proxyClient = null;
        }

        private Exception GetFullException(Exception ex)
        {
            if (ex.InnerException == null)
            {
                return ex;
            }
            else
            {
                StringBuilder str = new StringBuilder();
                Exception innerEx = ex;
                while (innerEx != null)
                {
                    str.AppendLine(innerEx.Message);
                    str.AppendLine();
                    innerEx = innerEx.InnerException;
                }

                return new ApplicationException(str.ToString());
            }
        }
     }
}
