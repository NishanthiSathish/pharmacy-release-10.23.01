using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;

namespace ascribe.pharmacy.data.wcfclient
{
    public interface IClient
    {
        void Initialise(string address, string token);
        
        ADODB.Recordset ExecuteSelectSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName);

        string ExecuteSelectOutputSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName);

        int ExecuteSelectReturnSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName);

        int ExecuteUpdateCustomSP(int SessionID, string Procedure, string ParametersXML, bool FullSessionIDName);

        int ExecuteInsertSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName);

        int ExecuteUpdateSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName);

        int ExecuteDeleteSP(int SessionID, string TableName, int PrimaryKey, bool FullSessionIDName);

        int ExecuteInsertLinkSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName);

        int ExecuteDeleteLinkSP(int SessionID, string TableName, string ParametersXML, bool FullSessionIDName);
    }


}
