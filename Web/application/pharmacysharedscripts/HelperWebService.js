/*

HwlperWebService.js

Specific script for the HwlperWebService.asmx methods.
*/

// Returns the entity id of the user
// function isCurrentUser(sessionId, username) 08Aug16 159843 replaced isCurrentUser with getEntityId
function getEntityId(sessionId, username)
{
    var parameters =
        {
            sessionId: sessionId,
            username: username
        };
    return PostServerMessage("../pharmacysharedscripts/HelperWebService.asmx/GetEntityId", JSON.stringify(parameters)).d;
}

// Gets a local (or sometimes network) temp filename
// Replace vb6 method MakeLocalFile from codelib.bas
// (you will also need to include references pharmacyscript.js,  FileHandling.js)
function GetLocalTempFilename(sessionId, siteId)
{
    var filename;
    do
    {
        var parameters =
                {
                    sessionId: sessionId,
                    siteId:    siteId
                };
        filename = PostServerMessage('../pharmacysharedscripts/HelperWebService.asmx/GetLocalTempFilename', JSON.stringify(parameters)).d;
    } while (ifFileExists(filename));

    return filename;
}