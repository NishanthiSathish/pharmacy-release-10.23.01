function window_onload()
{
	var lngSessionID = document.body.getAttribute("SessionID");
	var strApplicationPath= document.body.getAttribute("ApplicationPath");
	var strAscribeSiteNumber = document.body.getAttribute("AscribeSiteNumber");
	var strManuPass = document.body.getAttribute("ManuPass");
	var strCommand = document.body.getAttribute("CommandLine");
	var strURLtoken = document.body.getAttribute("URLtoken");

	if (strCommand == 'B') {strCommand ='///bondstore';}

// 27oct08 CKJ renamed objLauncher to objStores to prevent Builder changing the name (F0036599)	
//	objStores.SetConnection(lngSessionID, strAscribeSiteNumber);
	objStores.ASCribePath =strApplicationPath;
	objStores.SessionID = lngSessionID ;
	objStores.AscribeDrive = "";
	objStores.ASCribeSiteNumber = strAscribeSiteNumber;
	objStores.StoresPass = strManuPass ;
	objStores.WardPass = "0";
	objStores.ASCribeCommand = strCommand + ' /urltoken=' + strURLtoken;
	objStores.ASCribeExe ="ICWManufact.exe";
	objStores.LoadModule= 0;
	

	
//	if ( lngEpisodeID>0 )
//	{
//		objDispense.RefreshState(lngSessionID, 0, 0);
//		objStores.RefreshState(lngSessionID, 0, 0);
//		alert('launch stores');
//	}
}

//function RefreshState(RequestID_Prescription, RequestID_Dispensing)
//{
//	var lngSessionID = document.body.getAttribute("SessionID");
//	objDispense.RefreshState( lngSessionID, RequestID_Prescription, RequestID_Dispensing );
//}
