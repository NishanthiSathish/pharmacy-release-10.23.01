// -----------------------------------------------------------------------
// <copyright file="HelperWebService.cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Web service that provides set of general purpose helper methods
//  IsCurrentUser           - pass in user name and returns if this is the current user for the session
//  GetLocalTempFilename    - creates the name of a temp local file replaces vb6 codelib.bas MakeLocalFile method
//
// You can access the web method via HelperWebService.js javascript file
//
// Modification History:
// 24May16 XN  Created
// 02Aug16 XN  159413 Added GetNextCountStr so  vb6 manuf, and amm can have same counter
// 08Aug16 XN  159843 Replaced IsCurrentUser with GetEntityId
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Web.Services;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

/// <summary>Web service that provides set of general purpose helper methods</summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[System.Web.Script.Services.ScriptService]
public class HelperWebService : System.Web.Services.WebService 
{
    /// <summary>Returns entity id of current user for the session</summary>
    /// <param name="sessionId">Session Id</param>
    /// <param name="username">user name to test</param>
    /// <returns>True if current user</returns>
    [WebMethod]
    public int? GetEntityId(int sessionId, string username)
    //public bool IsCurrentUser(int sessionId, string username)  08Aug16 XN  159843  Replaced IsCurrentUser with GetEntityId
    {
        SessionInfo.InitialiseSession(sessionId);

        var parameters = new List<SqlParameter>();
        parameters.Add("username", username);
        return Database.ExecuteSQLScalar<int?>("SELECT TOP 1 EntityID FROM [user] WHERE username=@username", parameters);
    }
    
    /// <summary>
    /// Creates a local temp filename for printing
    /// Replace vb6 method MakeLocalFile from codelib.bas
    /// You can call this method using GetLocalTempFilename in the HelpWebService.js
    /// (you will also need to include references pharmacyscript.js and FileHandling.js)
    /// </summary>
    /// <param name="sessionId">Session id</param>
    /// <param name="siteId">Site id</param>
    /// <returns>filename</returns>
    [WebMethod]
    public string GetLocalTempFilename(int sessionId, int siteId)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionId, siteId);

        // Get directory
        string dir = Terminal.LocalFilePath();
        if (string.IsNullOrWhiteSpace(dir))
            dir = "c:";

        // Get terminal name and make it suitable for filename
        string terminalName = SessionInfo.Terminal.FilenameStringEscape();
        if (string.IsNullOrWhiteSpace(terminalName))
            terminalName = "DEFAULT";

        // Update terminal name
        dir = dir.Replace("%TERMINAL%", terminalName);

        // Build file name
        string filename = string.Format("#LocalF#{0:yyyyMMddHHmmssfff}{1}{2:000}.rtf", DateTime.Now, terminalName, WFilePointer.Increment(siteId, "D|LocalFileID") % 1000);

        // Return the path
        return Path.Combine(dir, filename);
    }

    /// <summary>Gets the next counter number in the sequence</summary>
    /// <param name="sessionID">Session Id</param>
    /// <param name="siteID">Site ID</param>
    /// <param name="system">System in counter number table</param>
    /// <param name="section">Section in counter number table</param>
    /// <param name="key">Key in counter number table</param>
    /// <returns>Next counter number</returns>
    [WebMethod]
    public string GetNextCountStr(int sessionID, int siteID, string system, string section, string key)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);
        return PharmacyCounter.GetNextCountStr(siteID, system, section, key);
    }
}
