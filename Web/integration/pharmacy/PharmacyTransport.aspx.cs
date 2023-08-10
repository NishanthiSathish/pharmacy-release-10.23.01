using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using TRNRTL10;
using System.IO;
using _Shared;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using System.Xml;
using _Shared;
using secrtl_c;

//??Jul12 AJK Written
//25Sep12 CKJ Swapped Linq for standard XML, since Linq strips out whitespace (0x09, 0x0A, 0x0D) from inside data strings (TFS44486)
//            LogException now writes to wPharmacyLog
//26Sep12 CKJ GetADORS error now returns message. Improved string handling performance (TFS44486)
//10Apr13 AJK 61073 Renamed
//09Sep14 TH  TFS 95758
//25Aug15 XN  LogException changes in WPharmacyLog require updates to this method
//29Sep15 TH/XN get physical path here to avoid web security issues. We know where the fie is after all (TFS 130430)

public partial class integration_pharmacy_PharmacyTransport : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "text/plain";
        Response.Clear();
        string token = string.Empty;
        string BLOB = string.Empty;
        bool success = false;
        int sessionID = 0;
        string retVal = string.Empty;
        string response = string.Empty;
        bool FullSessionIDName = false;
        string ErrorTag = "PharmacyTransportExceptionRaisedByServer>";

        if (Request["Token"] != null && Request["Token"] != string.Empty)
        {
            token = Request["Token"];
        }
        if (Request["BLOB"] != null && Request["BLOB"] != string.Empty)
        {
            BLOB = Request["BLOB"];
        }
        if (Request["SessionID"] != null && Request["SessionID"] != string.Empty)
        {
            success = int.TryParse(Request["SessionID"], out sessionID);
        }
        if (success && token != string.Empty && BLOB != string.Empty && BLOB.Length > 32 && BLOB.Length % 2 == 0)
        {
            SessionInfo.InitialiseSession(sessionID);
            Cryptography crypto = new Cryptography(token, sessionID);
            try
            {
                string data = crypto.DehexAndDecrypt(BLOB.Substring(32), BLOB.Substring(0, 32));
                Transport trans = new Transport();
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(data);

                string Function = xmlDoc.DocumentElement.Attributes[0].Value;

                string Procedure = string.Empty;
                XmlNodeList xnl = xmlDoc.GetElementsByTagName("Procedure");
                if (xnl.Count > 0)
                {
                    Procedure = xnl.Item(0).InnerText;
                }

                string TableName = string.Empty;
                xnl = xmlDoc.GetElementsByTagName("TableName");
                if (xnl.Count > 0)
                {
                    TableName = xnl.Item(0).InnerText;
                }

                string PrimaryKey = string.Empty;
                xnl = xmlDoc.GetElementsByTagName("PrimaryKey");
                if (xnl.Count > 0)
                {
                    PrimaryKey = xnl.Item(0).InnerText;
                }

                FullSessionIDName = true;                                               //08Aug12 CKJ Added block as testbed //25Sep12 CKJ retained as permanent mod
                if (xmlDoc.GetElementsByTagName("SessionIDName").Count > 0)
                {
                    FullSessionIDName = false;
                }

                string parametersXML = string.Empty;
                XmlNodeList xmlParams = xmlDoc.GetElementsByTagName("Parameter");       // Create a list of nodes where name is Parameter
                if (xmlParams != null)
                {
                    StringBuilder sb = new StringBuilder(2048);                         //25Sep12 CKJ Most param lists will fit in 2KB
                    foreach (XmlNode child in xmlParams)
                    {
                        sb.Append(child.OuterXml.ToString());
                    }
                    parametersXML = sb.ToString();
                }

                using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    switch (Function)
                    {
                        case "ExecuteSelectOutputSP":
                            retVal = trans.ExecuteSelectOutputSP(sessionID, Procedure, parametersXML, FullSessionIDName);
                            break;
                        case "ExecuteSelectReturnSP":
                            retVal = trans.ExecuteSelectReturnSP(sessionID, Procedure, parametersXML, FullSessionIDName).ToString();
                            break;
                        case "ExecuteUpdateCustomSP":
                            retVal = trans.ExecuteUpdateCustomSP(sessionID, Procedure, parametersXML, FullSessionIDName).ToString();
                            break;
                        case "ExecuteInsertSP":
                            retVal = trans.ExecuteInsertSP(sessionID, TableName, parametersXML, FullSessionIDName).ToString();
                            break;
                        case "ExecuteUpdateSP":
                            retVal = trans.ExecuteUpdateSP(sessionID, TableName, parametersXML, FullSessionIDName).ToString();
                            break;
                        case "ExecuteDeleteSP":
                            retVal = trans.ExecuteDeleteSP(sessionID, TableName, int.Parse(PrimaryKey), false, FullSessionIDName).ToString();
                            break;
                        case "ExecuteInsertLinkSP":
                            retVal = trans.ExecuteInsertLinkSP(sessionID, TableName, parametersXML, FullSessionIDName).ToString();
                            break;
                        case "ExecuteDeleteLinkSP":
                            retVal = trans.ExecuteDeleteLinkSP(sessionID, TableName, parametersXML, false, FullSessionIDName).ToString();
                            break;
                        case "ExecuteSelectSP":
                            //08Aug12 CKJ Added FullSessionIDName
                            DataSet ds = trans.ExecuteSelectSP(sessionID, Procedure, parametersXML, FullSessionIDName);
                            Uri url = HttpContext.Current.Request.Url;
                            string port = url.Port != 80 ? (":" + url.Port) : String.Empty;
                            //string xsltURL = string.Format("{0}://{1}{2}/{3}{4}", url.Scheme, url.Host, port,HttpContext.Current.Request.ApplicationPath, "/xml_data/DataSet2Recordset.xslt");
                            //string xsltURL = string.Format("{0}://{1}{2}/{3}{4}", url.Scheme, "localhost", port, HttpContext.Current.Request.ApplicationPath, "/xml_data/DataSet2Recordset.xslt");
                            //29Sep15 TH/XN get physical path here to avoid web security issues. We know where the fie is after all (TFS 130430)
			                string xsltURL =Server.MapPath("../../xml_data/DataSet2Recordset.xslt");
                            long adoSuccess = ascribe.pharmacy.shared.DataSet2Recordset.GetADORS(ds, trans.DatabaseName(), xsltURL, out retVal);
                            if (adoSuccess != 1)
                                throw (new InvalidOperationException(retVal));          //26Sep12 CKJ previously returned string.empty
                            break;
                        //04Sep12 AJK Removed as not supported due to connection pooling
                        //case "GetRowLock":
                        //    retVal = trans.PharmacyGetRowLock(sessionID, xTableName.Value, int.Parse(xPrimaryKey.Value)).ToString();
                        //    break;
                        default:
                            break;
                    }

                    scope.Commit();
                }
            }
            catch (Exception ex)
            {
                retVal = "<" + ErrorTag + ex.Message + "</" + ErrorTag;
                LogException(ex, sessionID);
            }

            if (retVal != string.Empty)
            {
                string salt = string.Empty;
                string encrypted = crypto.EncryptAndHex(retVal, out salt);

                StringBuilder sbResponse = new StringBuilder(salt.Length + encrypted.Length);
                sbResponse.Append(salt);
                sbResponse.Append(encrypted);
                response = sbResponse.ToString();
            }

            Response.Write(response);
        }
    }

    protected void LogException(Exception ex, int sessionID)
    {
        // There have been changes to the structure of the PharmacyLog so have replaced the below 25Aug15 XN
        //Transport trans = new Transport();
        //using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
        //{
        //    StringBuilder sb = new StringBuilder();

        //    //27Sep12 CKJ added block as these can be null
        //    string stacktrace = String.Empty;
        //    if (!String.IsNullOrEmpty(ex.StackTrace.ToString()))
        //    {
        //        stacktrace = ex.StackTrace.Substring(0, Math.Min(ex.StackTrace.Length, 8000));
        //    }
        //    string message = String.Empty;
        //    if (!String.IsNullOrEmpty(ex.Message.ToString()))
        //    {
        //        message = ex.Message.Substring(0, Math.Min(ex.Message.Length, 8000));               
        //    }
            
        ////27Aug14 TH Added NSVCode
        //    sb.Append(trans.CreateInputParameterXML("SiteID", Transport.trnDataTypeEnum.trnDataTypeInt, 4, 0));
        //    sb.Append(trans.CreateInputParameterXML("Terminal", Transport.trnDataTypeEnum.trnDataTypeVarChar, 25, "PharmacyTransport"));
        //    sb.Append(trans.CreateInputParameterXML("EntityID_User", Transport.trnDataTypeEnum.trnDataTypeInt, 4, 0));
        //    sb.Append(trans.CreateInputParameterXML("Detail", Transport.trnDataTypeEnum.trnDataTypeVarChar, 8000, stacktrace));
        //    sb.Append(trans.CreateInputParameterXML("Description", Transport.trnDataTypeEnum.trnDataTypeVarChar, 8000, message));
        //    sb.Append(trans.CreateInputParameterXML("State", Transport.trnDataTypeEnum.trnDataTypeInt, 4, 0));
        //    sb.Append(trans.CreateInputParameterXML("Thread", Transport.trnDataTypeEnum.trnDataTypeInt, 4, 0));
        //    sb.Append(trans.CreateInputParameterXML("NSVCode", Transport.trnDataTypeEnum.trnDataTypeVarChar, 7, ""));
        //    int success = trans.ExecuteInsertSP(sessionID, "wPharmacyLog", sb.ToString());                          //25Sep12 CKJ added
        //    scope.Commit();
        //}
        //if (ex.InnerException != null)
        //{
        //    LogException(ex.InnerException, sessionID);
        //}


        // There have been changes to the structure of the PharmacyLog so have replaced the above with the below 25Aug15 XN
        SessionInfo.InitialiseSession(sessionID);

        // Build up the message
        StringBuilder message = new StringBuilder();
        message.AppendLine(ex.GetAllMessaages().ToCSVString("\n"));
        message.Append(ex.GetAllStackTrace().ToCSVString("\n---------------------\n"));
        message.Length = Math.Min(message.Length, WPharmacyLog.GetColumnInfo().DetailLength);   // Limit to max length of description field

        // Save to log
        WPharmacyLog log = new WPharmacyLog();
        var newRow = log.Add();
        newRow.WPharmacyLogType = WPharmacyLogType.PharmacyTransport;
        newRow.NSVCode          = string.Empty;
        newRow.SiteID           = null;
        newRow.Detail           = message.ToString();
        log.Save();
    }
}
