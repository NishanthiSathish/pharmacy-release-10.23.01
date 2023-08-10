using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Text;
using ascribe.pharmacy.basedatalayer;

/// <summary>
/// Summary description for ICWIntegrationService
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class ICWIntegrationService : System.Web.Services.WebService
{
    public ICWIntegrationService() {}

    [WebMethod]
    public string[] VersionNumbers()
    {
        List<string> versionNumbers = new List<string>();

        if (System.IO.File.Exists(System.Web.Hosting.HostingEnvironment.ApplicationPhysicalPath + @"\Build.txt"))
            versionNumbers.Add("Pharmacy Web Version " + System.IO.File.ReadAllText(System.Web.Hosting.HostingEnvironment.ApplicationPhysicalPath + @"\Build.txt"));
        else
            versionNumbers.Add("Pharmacy Web Version [Build Unavailable]");

        string dbVersion = Database.GetPharamcyDBVersionNumber();
        if (!string.IsNullOrEmpty(dbVersion))
            versionNumbers.Add("Pharmacy DB Version " + dbVersion);

        return versionNumbers.ToArray();
    }

}

