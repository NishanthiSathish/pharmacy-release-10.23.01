using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.Data;
using TRNRTL10;
using _Shared;

namespace ascribe.pharmacy.webtransport
{
    public class WebDataService : IWebDataService
    {
        Transport trans = new Transport();

        public DataSet ExecuteSelectSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName, string x, string y)
        {
            DataSet ret;
            if (Validate(x, y))
            {
                using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    ret = trans.ExecuteSelectSP(SessionID, Procedure, ParametersXML, FullSessionIDName);
                    scope.Commit();
                }
            }
            else
            {
                ret = new DataSet();
            }
            return ret;
        }

        public string ExecuteSelectOutputSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName, string x, string y)
        {
            string ret = string.Empty;
            if (Validate(x, y))
            {
                using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    ret = trans.ExecuteSelectOutputSP(SessionID, Procedure, ParametersXML, FullSessionIDName);
                    scope.Commit();
                }
            }
            return ret;
        }

        public int ExecuteSelectReturnSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName, string x, string y)
        {
            int ret = 0;
            if (Validate(x, y))
            {
                using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    ret = trans.ExecuteSelectReturnSP(SessionID, Procedure, ParametersXML, FullSessionIDName);
                    scope.Commit();
                }
            }
            return ret;
        }

        public int ExecuteUpdateCustomSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName, string x, string y)
        {
            int ret = 0;
            if (Validate(x, y))
            {

                using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    ret = trans.ExecuteUpdateCustomSP(SessionID, Procedure, ParametersXML, FullSessionIDName);
                    scope.Commit();
                }
            }
            return ret;
        }

        public int ExecuteInsertSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName, string x, string y)
        {
            int ret = 0;
            if (Validate(x, y))
            {
                using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    ret = trans.ExecuteInsertSP(SessionID, TableName, ParametersXML, FullSessionIDName);
                    scope.Commit();
                }
            }
            return ret;
        }

        public int ExecuteUpdateSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName, string x, string y)
        {
            int ret = 0;
            if (Validate(x, y))
            {
                using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    ret = trans.ExecuteUpdateSP(SessionID, TableName, ParametersXML, FullSessionIDName);
                    scope.Commit();
                }
            }
            return ret;
        }

        public int ExecuteDeleteSP(int SessionID, string TableName, int PrimaryKey, bool FullSessionIDName, string x, string y)
        {
            int ret = 0;
            if (Validate(x, y))
            {
                using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    string ParametersXML = trans.CreateInputParameterXML(TableName + "ID", Transport.trnDataTypeEnum.trnDataTypeInt, 4, PrimaryKey);
                    ret = trans.ExecuteUpdateCustomSP(SessionID, "p" + TableName + "Delete", ParametersXML);
                    //ret = trans.ExecuteDeleteSP(SessionID, TableName, PrimaryKey, false, FullSessionIDName); 146283 24Feb16 XN Fixed issue where ExecuteDeleteSP calls a lookup sp before calling the delete (different from old transport error), and this causes issues if the lookup sp does not exists
                    scope.Commit();
                }
            }
            return ret;
        }

        public int ExecuteInsertLinkSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName, string x, string y)
        {
            int ret = 0;
            if (Validate(x, y))
            {
                using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    ret = trans.ExecuteInsertLinkSP(SessionID, TableName, ParametersXML, FullSessionIDName);
                    scope.Commit();
                }
            }
            return ret;
        }

        public int ExecuteDeleteLinkSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName, string x, string y)
        {
            int ret = 0;
            if (Validate(x, y))
            {
                using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    ret = trans.ExecuteDeleteLinkSP(SessionID, TableName, ParametersXML, FullSessionIDName);
                    scope.Commit();
                }
            }
            return ret;
        }

        private bool Validate(string username, string password)
        {
            bool ret = false;
            using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                string par = trans.CreateInputParameterXML("SessionID", Transport.trnDataTypeEnum.trnDataTypeInt, 4, username) +
                                trans.CreateInputParameterXML("URLToken", Transport.trnDataTypeEnum.trnDataTypeVarChar, 8000, password);
                DataSet ds = new DataSet();
                ds = trans.ExecuteSelectSP(int.Parse(username), "pPharmacyActiveDataConnectionsBySessionIDAndURLToken", par, true);
                if (ds.Tables[0].Rows.Count > 0)
                {
                    ret = true;
                }
                scope.Commit();
            }
            return ret;
        }


    }
}
