// -----------------------------------------------------------------------
// <copyright file="HelperMethod.cs" company="Ascribe">
// Hong Kong helper Web Service methods (called by VB6 client)
//      
//	Modification History:
//	01Oct15 XN  Created 
//  02Nov15 XN  If Chinese name is not present then use English name 133949
// </copyright>
// -----------------------------------------------------------------------
using System.Web.Services;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;

/// <summary>Hong Kong helper Web Service methods (called by VB6 client)</summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class HelperMethod : System.Web.Services.WebService 
{
    /// <summary>Returns the Chinese name for the entity as an RTF image (if Chinese name not present returns English name as plain text)</summary>
    /// <param name="sessionId">Session Id</param>
    /// <param name="siteId">site Id 9Nov15 133949</param>
    /// <param name="entityId">Entity Id</param>
    /// <returns>RTF image string</returns>
    [WebMethod]
    public string GetChineseNameForRTF(int sessionId, int siteId, int entityId) 
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionId, siteId);

        string name = Database.ExecuteSQLScalar<string>("SELECT ChineseName FROM EntityExtraInfo WHERE EntityID={0}", entityId);
        if (string.IsNullOrWhiteSpace(name))
        {
            return PNPrintProcessor.BuildName(Patient.GetByEntityID(entityId));  // If Chinese name not present use English name 03Oct15 XN 133949
        }
        else 
        {
            return RTFUtils.TextToRTFImage(name);
        }
    }
}
