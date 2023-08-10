function window_onload()
{
	var lngSessionID = document.body.getAttribute("SessionID");
	var strOCXURL = document.body.getAttribute("OCXURL");
	var lngEpisodeID = document.body.getAttribute("EpisodeID");
	var strAscribeSiteNumber = document.body.getAttribute("AscribeSiteNumber");
	var strLabelTypesPreventEdit = document.body.getAttribute("LabelTypesPreventEdit");
    var strAllowReDispensing = document.body.getAttribute("AllowReDispensing");
	
	if ( lngEpisodeID>0 )
	{
		objDispense.RefreshState(lngSessionID, strAscribeSiteNumber, 0, 0 ,strOCXURL,strLabelTypesPreventEdit, strAllowReDispensing, 0);
	}
}

function RefreshState(RequestID_Prescription, RequestID_Dispensing)
{
	var lngSessionID = document.body.getAttribute("SessionID");
	var strOCXURL = document.body.getAttribute("OCXURL");
    var strAscribeSiteNumber = document.body.getAttribute("AscribeSiteNumber");
	var strLabelTypesPreventEdit = document.body.getAttribute("LabelTypesPreventEdit");
    var strAllowReDispensing = document.body.getAttribute("AllowReDispensing");

	objDispense.RefreshState( lngSessionID, strAscribeSiteNumber, RequestID_Prescription, RequestID_Dispensing, strOCXURL,strLabelTypesPreventEdit, strAllowReDispensing, 0);
}

function RefreshStateForAmm(RequestID_Prescription, RequestID_AmmSupplyRequestID, RequestID_Dispensing) 
{
    var lngSessionID = document.body.getAttribute("SessionID");
    var strOCXURL = document.body.getAttribute("OCXURL");
    var strAscribeSiteNumber = document.body.getAttribute("AscribeSiteNumber");
    var strLabelTypesPreventEdit = document.body.getAttribute("LabelTypesPreventEdit");
    var strAllowReDispensing = document.body.getAttribute("AllowReDispensing");

    objDispense.RefreshState(lngSessionID, strAscribeSiteNumber, RequestID_Prescription, RequestID_Dispensing, strOCXURL, strLabelTypesPreventEdit, strAllowReDispensing, RequestID_AmmSupplyRequestID);
}

function PrintLabel(RequestID_AmmSupplyRequestID, numberOfLabels, printLabel, saveLabel) 
{
    var lngSessionID = document.body.getAttribute("SessionID");
    var strAscribeSiteNumber = document.body.getAttribute("AscribeSiteNumber");

    return objDispense.PrintLabel(lngSessionID, strAscribeSiteNumber, RequestID_AmmSupplyRequestID, numberOfLabels, printLabel, saveLabel);
}

function GetLabelText(RequestID_AmmSupplyRequestID)
{
    var lngSessionID = document.body.getAttribute("SessionID");
    var strAscribeSiteNumber = document.body.getAttribute("AscribeSiteNumber");

    return objDispense.GetLabelText(lngSessionID, strAscribeSiteNumber, RequestID_AmmSupplyRequestID);
}

function ReprintLabel(RequestID_AmmSupplyRequestID, RequestID_Dispensing)
{
    var lngSessionID = document.body.getAttribute("SessionID");
    var strAscribeSiteNumber = document.body.getAttribute("AscribeSiteNumber");
    var strOCXURL = document.body.getAttribute("OCXURL");
    objDispense.ReprintLabel(lngSessionID, strAscribeSiteNumber, RequestID_AmmSupplyRequestID, RequestID_Dispensing, strOCXURL);
}
