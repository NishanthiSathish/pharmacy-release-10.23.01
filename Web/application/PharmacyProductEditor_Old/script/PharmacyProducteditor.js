function window_onload()
{
	var lngSessionID = document.body.getAttribute("SessionID");
	var lngProductID = document.body.getAttribute("ProductID");
	var strAscribeSiteNumber = document.body.getAttribute("AscribeSiteNumber");
	var strURLtoken = document.body.getAttribute("URLtoken");
	//alert(strAscribeSiteNumber);
	//alert(eval(lngSessionID));
	//alert(eval(lngProductID));
	//objPharmacyProductEditor.SetConnection(lngSessionID, strAscribeSiteNumber);  12Aug08 CKJ

	//08oct08 CKJ Check success of setconnection before calling refreshstate (F0035503)	
	if (objPharmacyProductEditor.SetConnection(lngSessionID, strAscribeSiteNumber, strURLtoken))
	{	
		objPharmacyProductEditor.RefreshState(lngSessionID, lngProductID );
	}
}

function RefreshState(lngProductID)
{
	var lngSessionID = document.body.getAttribute("SessionID");
	objPharmacyProductEditor.RefreshState( lngSessionID, lngProductID );
}
