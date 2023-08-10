function window_onload()
{
	var lngSessionID = document.body.getAttribute("SessionID");
	var strApplicationPath= document.body.getAttribute("ApplicationPath");
	var strAscribeSiteNumber = document.body.getAttribute("AscribeSiteNumber");
	var strStoresPass = document.body.getAttribute("StoresPass");
	var strWardPass = document.body.getAttribute("WardPass");
	var strCommand = document.body.getAttribute("CommandLine");
	var strURLtoken = document.body.getAttribute("URLtoken");
	var blnLocked = document.body.getAttribute("Locked");

	if (strCommand == 'D') {strCommand ='///de0';}
	if (strCommand == 'L') {strCommand ='///lv0';}
	if (strCommand == 'P') {strCommand ='///labeleditors';}
	if (strCommand == 'E') {strCommand ='///editors';}
	if (strCommand == 'C') {strCommand ='///printereditors';}
	if (strCommand == 'Y') {strCommand ='///fffull';}
	if (strCommand == 'Z') {strCommand ='///ffreadonly';}
	if (strCommand == 'B') {strCommand ='///batchmanagement';}
	if (strCommand == 'V') {strCommand ='///logview';}
	if (blnLocked == "True") {strCommand =strCommand + ' ///lk';}
	
//	objStores.SetConnection(lngSessionID, strAscribeSiteNumber);
	objStores.ASCribePath =strApplicationPath;
	objStores.SessionID = lngSessionID; 
	objStores.AscribeDrive = "";
	objStores.ASCribeSiteNumber = strAscribeSiteNumber;
	objStores.StoresPass = strStoresPass ;
	objStores.WardPass = strWardPass ;
//	objStores.ASCribeCommand = strCommand ;
	objStores.ASCribeCommand = strCommand + ' /urltoken=' + strURLtoken;
	objStores.ASCribeExe ="HSSL.exe";
	objStores.LoadModule= 0;
}

