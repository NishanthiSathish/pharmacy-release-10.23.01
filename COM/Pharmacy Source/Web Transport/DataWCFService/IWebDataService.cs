using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.Data;

namespace ascribe.pharmacy.webtransport
{
    [ServiceContract]
    public interface IWebDataService
    {
        [OperationContract]
        DataSet ExecuteSelectSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName, string x, string y);

        [OperationContract]
        string ExecuteSelectOutputSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName, string x, string y);

        [OperationContract]
        int ExecuteSelectReturnSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName, string x, string y);

        [OperationContract]
        int ExecuteUpdateCustomSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName, string x, string y);

        [OperationContract]
        int ExecuteInsertSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName, string x, string y);

        [OperationContract]
        int ExecuteUpdateSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName, string x, string y);

        [OperationContract]
        int ExecuteDeleteSP(int SessionID, string TableName, int PrimaryKey, bool FullSessionIDName, string x, string y);

        [OperationContract]
        int ExecuteInsertLinkSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName, string x, string y);

        [OperationContract]
        int ExecuteDeleteLinkSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName, string x, string y);
    }
}
