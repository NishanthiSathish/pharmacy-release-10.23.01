/*
	Used to lock entities and requests
*/

function LockEntity(SessionID, EntityID)
{
    strURL = GetSharedScriptsURL() + "Locking.aspx?SessionID=" + SessionID + "&ID=" + EntityID + "&action=lock&ObjectType=entity";
	
	m_objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");							
	m_objHTTPRequest.open("GET", strURL, false);								
	m_objHTTPRequest.send();
	return m_objHTTPRequest.responseText;
}

function UnlockEntity(SessionID, EntityID)
{
	strURL = GetSharedScriptsURL() + "Locking.aspx?SessionID=" + SessionID + "&ID=" + EntityID + "&action=unlock&ObjectType=entity";

	m_objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");							
	m_objHTTPRequest.open("GET", strURL, false);								
	m_objHTTPRequest.send();										
	return m_objHTTPRequest.responseText;
}

function LockRequests(SessionID, strOrderXML)
{
	strURL = GetSharedScriptsURL() + "Locking.aspx?SessionID=" + SessionID + "&action=lock&ObjectType=request";

	m_objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");							
	m_objHTTPRequest.open("POST", strURL, false);								
	m_objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	m_objHTTPRequest.send( strOrderXML );										
	return m_objHTTPRequest.responseText;
}

function UnlockRequests(SessionID)
{
	strURL = GetSharedScriptsURL() + "Locking.aspx?SessionID=" + SessionID + "&action=unlock&ObjectType=request";

	m_objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");							
	m_objHTTPRequest.open("GET", strURL, false);								
	m_objHTTPRequest.send();										
	return m_objHTTPRequest.responseText;
}
