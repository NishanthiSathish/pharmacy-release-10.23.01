function window_onload()
{
	var lngSessionID = document.body.getAttribute("SessionID");
	var strApplicationPath= document.body.getAttribute("ApplicationPath");
	var strAscribeSiteNumber = document.body.getAttribute("AscribeSiteNumber");
	var strStoresPass = document.body.getAttribute("StoresPass");
	var strWardPass = document.body.getAttribute("WardPass");
	var strURLtoken = document.body.getAttribute("URLtoken");
	
//	objStores.SetConnection(lngSessionID, strAscribeSiteNumber);
	objStores.ASCribePath =strApplicationPath;
	objStores.SessionID = lngSessionID; 
	objStores.AscribeDrive = "";
	objStores.ASCribeSiteNumber = strAscribeSiteNumber;
	objStores.StoresPass = strStoresPass ;
	objStores.WardPass = strWardPass; 
	objStores.ASCribeCommand = ' /urltoken=' + strURLtoken;
	objStores.ASCribeExe ="ICWStockTake.exe";
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
