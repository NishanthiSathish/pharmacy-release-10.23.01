function window_onload()
{
	var lngSessionID = document.body.getAttribute("SessionID");
	var lngEpisodeID = document.body.getAttribute("EpisodeID");
	var strAscribeSiteNumber = document.body.getAttribute("AscribeSiteNumber");
	var PrescriptionID = document.body.getAttribute("PrescriptionID");
	var NoteType = document.body.getAttribute("NoteType");
	var UserID = document.body.getAttribute("UserID");
	var FullName = document.body.getAttribute("FullName");
	var AscribeInstance = document.body.getAttribute("AscribeInstance");
	var AscribePassLevel = document.body.getAttribute("AscribePassLevel");
	
}

function RefreshState(RequestID_Prescription, RequestID_Dispensing)
{
	var lngSessionID = document.body.getAttribute("SessionID");
	var AscribeInstance = document.body.getAttribute("AscribeInstance");
	var AscribePassLevel = document.body.getAttribute("AscribePassLevel");
	var NoteType = document.body.getAttribute("NoteType");

	//Here we need to get the patient + prescription XML

	var strURL= "../PharmacyGateway/ICW_PharmacyGateway.aspx?SessionID="+lngSessionID +"&PrescriptionID=" +RequestID_Prescription+"&AscribeInstance=" +AscribeInstance+"&AscribePassLevel=" +AscribePassLevel+"&NoteType=" +NoteType ;
	window.navigate (strURL);	

}
