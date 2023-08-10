function window_onload()
{
	//Select an episode if we are in Active mode
	var lngEpisodeID = document.body.getAttribute("EpisodeID");
	var blnEpisodeIsSelected = ( (Number(lngEpisodeID) > 0) );

	ICWToolMenuEnable("PCTPatient_Edit", blnEpisodeIsSelected);

	if ( blnEpisodeIsSelected )
	{
		LayoutPanel("PCTPatient");
	}
}

function LaunchEditPCTPatient(lngEntityID)
{
	if ( lngEntityID== undefined ) lngEntityID= -1;
	lngEntityID = window.showModalDialog("../PCTPatient/PCTPatientEditorModal.aspx?SessionID=" + document.all("bdy").getAttribute("SessionID") +"&EntityID=" + lngEntityID + "&SiteID=" + document.all("bdy").getAttribute("SiteID"),"","edge: Raised; center: Yes; Scroll: No; help: No; resizable: No; status: No;");
	if (lngEntityID == 'logoutFromActivityTimeout') {
		lngEntityID = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

}

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
