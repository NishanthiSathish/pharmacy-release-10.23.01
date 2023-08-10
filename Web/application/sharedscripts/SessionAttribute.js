/* 
	SeeionAttribute functions for use in ASP pages to store session attributes on the server.
	
	Makes use of the SessionAttribute.aspx page to save and retrieve settings.
	
	Note:  All values stored inside an <Attribute> node as XML
	
	01May07	CJM Written
*/

function SessionAttribute(lngSessionID, strAttribute) {

	//  Get session setting
	
	var strURL = '../sharedscripts/SessionAttribute.aspx'
				  + '?SessionID=' + lngSessionID
				  + '&Mode=get'
				  + '&Attribute=' + strAttribute;

	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");                                      
	objHTTPRequest.open("POST", strURL, false);	//false = syncronous                              
	objHTTPRequest.send('');
	var strValue = objHTTPRequest.responseText;
	//  Remiove <Attribute> wrapper
	return strValue.substr(11, strValue.length - 24);
	
}

function SessionAttributeSet(lngSessionID, strAttribute, strValue) {
	
	//  Save session setting
	
	var strURL = '../sharedscripts/SessionAttribute.aspx'
				  + '?SessionID=' + lngSessionID
				  + '&Mode=set'
				  + '&Attribute=' + strAttribute;

	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");                                      
	objHTTPRequest.open("POST", strURL, false);	//false = syncronous                              
	objHTTPRequest.send("<Attribute>" + strValue + "</Attribute>");
	return objHTTPRequest.responseText;
}

