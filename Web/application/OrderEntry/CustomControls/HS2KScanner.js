
function Initialise()
{
	
	uploadControl.letEpisodeData(patientData.xml);
	//uploadControl.Configuration = configData.xml;
	uploadControl.StartPolling();
	
}