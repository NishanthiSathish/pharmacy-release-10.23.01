function window_onload()
{
	//Select an episode if we are in Active mode
	//var blnSelectEpisode = (document.body.getAttribute('allowepisodeselection') == 'true');
	var lngEpisodeID = document.body.getAttribute("EpisodeID");
	var blnEpisodeIsSelected = ( (Number(lngEpisodeID) > 0) );

	ICWToolMenuEnable("RptDispPatient_Edit", blnEpisodeIsSelected);
	ICWToolMenuEnable("PBSFastRepeatSearch", true);



	//ICWToolMenuEnable("Entity_FurtherDetail", blnEpisodeIsSelected);
	//ICWToolMenuEnable("NBEntity_New", blnSelectEpisode);
	//ICWToolMenuEnable("NBEntity_Edit", blnEpisodeIsSelected);

	if ( blnEpisodeIsSelected )
	{
		LayoutPanel("PBSPatient");
//		LayoutPanel("Episode");
	}
//	else
//	{
//		if (blnSelectEpisode) {LaunchEpisodeSelector()};					//24Jan04 AE  Added Active/Passive mode
//	}
}

//function LaunchEpisodeSelector()
//{
//	var lngHeight = window.screen.availHeight-100;
//	var lngWidth  = window.screen.availWidth-100;
//	
//	if (lngWidth > 1100) {lngWidth = 1100;}																											//23Sep03 AE  Prevent huge widths on dual screens
//	
//	var lngEpisodeID = -1;
//	
//	lngEpisodeID = window.showModalDialog("../EpisodeSelector/EpisodeSelectorModal.aspx?SessionID=" + document.all("bdy").getAttribute("SessionID"),"","dialogHeight: " + lngHeight + "px; dialogWidth: " + lngWidth + "px;" + "dialogTop:50px edge: Raised; center: Yes; Scroll: No; help: No; resizable: yes; status: No;");   //09May05 AE  Prevent form disapearing off the top of the screen
//	if (lngEpisodeID!==undefined)
//	{
//		RAISE_EpisodeSelected();
//		EVENT_EpisodeSelected(); // Call refresh internally aswell.
//	}
//}

//function LaunchFurtherDetail()
//{
// 24Apr03 DB Launches the further detail entity panel in a modal window.
//	void window.showModalDialog("../PatientEpisodeEditor/patientfurtherdetail.aspx?SessionID=" + document.all("bdy").getAttribute("SessionID") + "&Mode=view","","dialogHeight: 600px; dialogWidth: 600px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: No; status: No;");
//	void window.showModalDialog("../EntityPanelFurtherDetail/EntityPanelFurtherDetail.aspx?SessionID=" + document.all("bdy").getAttribute("SessionID"),"","dialogHeight: 270px; dialogWidth: 400px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: No; status: No;");
//}

//function LaunchNewPatient()
//{
//	var lngEpisodeID = -1;
//	//lngEpisodeID = window.showModalDialog("../PatientEditor/PatientEditModal.aspx?SessionID=" + document.all("bdy").getAttribute("SessionID") +"&EpisodeID=-1" ,"","dialogHeight: 610px; dialogWidth: 420px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: No; status: No;");
//	lngEpisodeID = window.showModalDialog("../PatientEpisodeEditor/PatientEpisodeEditorModal.aspx?SessionID=" + document.all("bdy").getAttribute("SessionID") +"&EpisodeID=-1&Mode=newpatient&WindowStyle=Modal","","dialogHeight: 600px; dialogWidth: 800px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: No; status: No;");
//	if (lngEpisodeID>-1)
//	{
//		RAISE_EpisodeSelected();
//		EVENT_EpisodeSelected(); // Call refresh internally aswell.
//	}
//}

function LaunchEditRptDispPatient(lngEntityID)
{
	if ( lngEntityID== undefined ) lngEntityID= -1;
	//lngEpisodeID = window.showModalDialog("../PatientEditor/PatientEditModal.aspx?SessionID=" + document.all("bdy").getAttribute("SessionID") + "&EntityID=" + lngEntityID,"","dialogHeight: 610px; dialogWidth: 420px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: No; status: No;");
//TH THIS SHOULD BE USED AS IS I THINK	
	lngEntityID = window.showModalDialog("../RepeatDispensing/RepeatDispensingModal.aspx?SessionID=" + document.all("bdy").getAttribute("SessionID") +"&EntityID=" + lngEntityID + "&SiteID=" + document.all("bdy").getAttribute("SiteID"),"","edge: Raised; center: Yes; Scroll: No; help: No; resizable: No; status: No;");
	if (lngEntityID == 'logoutFromActivityTimeout') {
		lngEntityID = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}
	//if (lngEpisodeID>-1)
	//{
	//	RAISE_EpisodeSelected(lngEpisodeID);
	//	EVENT_EpisodeSelected(); // Call refresh internally aswell.
	//}
}


function LaunchPBSFastRepeatSearch(lngSessionID)
{
	lngEpisodeID = window.showModalDialog("../PBSEntityPanel/PBSFastRepeatSearchModal.aspx?SessionID=" + document.all("bdy").getAttribute("SessionID"), "","dialogHeight: 214px; dialogWidth: 600px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: No; status: No;");
	if (lngEntityID == 'logoutFromActivityTimeout') {
		lngEntityID = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}
	if (lngEntityID!=null && lngEpisodeID > -1)
	{
	    // 21Feb11 PH Take ICW Episode integer, convert to entity & episode versioned identifiers, and raise the ICW Episode Selected Event
	    // Create JSON episode event data
	    var jsonEntityEpisodeVid = ICW.clinical.episode.eventSelectedRaised(lngSlaveEpisodeID, 0, document.body.getAttribute("SessionID"));
	    // Raise episode event via ICW framework, using entity & episode versioned identifier
	    RAISE_EpisodeSelected(jsonEntityEpisodeVid);
	    EVENT_EpisodeSelected(jsonEntityEpisodeVid);

//		RAISE_EpisodeSelected(lngEpisodeID);
//		EVENT_EpisodeSelected();

		RAISE_Dispensing_RefreshView(0, 0);
	}
}



//function NBLaunchNewPatient()
//{
//	var lngEpisodeID = -1;
//	lngEpisodeID = window.showModalDialog("../NBPatientEditor/NBPatientEditModal.aspx?SessionID=" + document.all("bdy").getAttribute("SessionID") +"&EpisodeID=-1" ,"","dialogHeight: 610px; dialogWidth: 620px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: No; status: No;");
//	if (lngEpisodeID>-1)
//	{
//		RAISE_EpisodeSelected();
//		EVENT_EpisodeSelected(); // Call refresh internally aswell.
//	}
//}

//function NBLaunchEditPatient(lngEpisodeID)
//{
//	if ( lngEpisodeID == undefined ) lngEpisodeID = -1;
//	lngEpisodeID = window.showModalDialog("../NBPatientEditor/NBPatientEditModal.aspx?SessionID=" + document.all("bdy").getAttribute("SessionID") + "&EpisodeID=" + lngEpisodeID ,"","dialogHeight: 610px; dialogWidth: 620px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: No; status: No;");
//	if (lngEpisodeID>-1)
//	{
//		RAISE_EpisodeSelected(lngEpisodeID);
//		EVENT_EpisodeSelected(); // Call refresh internally aswell.
//	}
//}

function LayoutPanel(strPanelName)
{
	var intMaxCaptionWidth = 0;
	var intMaxWidth;
	var intIndex;
	var intFieldCount = Number(document.all("txt" + strPanelName + "FieldCount").value);
	var spnElement;

	// Captions
	
	intMaxWidth = 0

	for (intIndex=0; intIndex<intFieldCount; intIndex++)
	{
		spnElement = document.getElementById("spn" + strPanelName + "Caption" + intIndex);
		if (spnElement.offsetWidth > intMaxWidth) 
		{
			intMaxWidth = spnElement.offsetWidth;
		}
	}

	for (intIndex=0; intIndex<intFieldCount; intIndex++)
	{
		spnElement = document.getElementById("spn" + strPanelName + "Caption" + intIndex);
		spnElement.style.pixelWidth = intMaxWidth;
	}

	// Text

	intMaxWidth = 0

	for (intIndex=0; intIndex<intFieldCount; intIndex++)
	{
		spnElement = document.getElementById("spn" + strPanelName + "Text" + intIndex);
		if (spnElement.offsetWidth > intMaxWidth) 
		{
			intMaxWidth = spnElement.offsetWidth;
		}
	}

	for (intIndex=0; intIndex<intFieldCount; intIndex++)
	{
		spnElement = document.getElementById("spn" + strPanelName + "Text" + intIndex);
		spnElement.style.pixelWidth = intMaxWidth;
	}

	// Whole divs
	for (intIndex=0; intIndex<intFieldCount; intIndex++)
	{
		spnElement = document.getElementById("div" + strPanelName + intIndex);
		spnElement.outerHTML = "<button tabindex='-1' class='FieldSurround' style='width:" + spnElement.offsetWidth + "'><div align=left>" + spnElement.innerHTML + "</div></button> "
	}


	if (document.body.getAttribute("FieldStyle")!="ROWS")
	{
		// Remove <BR>s
		for (intIndex=0; intIndex<intFieldCount; intIndex++)
		{
			spnElement = document.getElementById("br" + intIndex);
			spnElement.parentElement.removeChild(spnElement);
		}
	}
}
