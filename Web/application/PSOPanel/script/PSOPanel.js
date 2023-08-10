//22Nov12 TH Written from Entity/Episode panel js for PSO Dispensing details Panel (TFs 40930)

function window_onload()
{
	//Select an episode if we are in Active mode
	//var blnSelectEpisode = (document.body.getAttribute('allowepisodeselection') == 'true');
	var DispensingID = document.body.getAttribute("lngDispensingID");
	
	if ( DispensingID >0)
	{
		LayoutPanel("PSO");
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
