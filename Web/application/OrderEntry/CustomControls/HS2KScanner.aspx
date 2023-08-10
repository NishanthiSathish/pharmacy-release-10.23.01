<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>
<html>
<head>

<%
    Dim blnReadOnly As String  
%>
<%
    Dim SessionID As Integer
    Dim objEnt As ENTRTL10.EntityRead
    Dim objTrn As TRNRTL10.Transport
    Dim strXML As String
    Dim lngEpisodeID As Integer 
    Dim lngEntityID As String
    Dim dom As XmlDocument
    Dim objSetting As GENRTL10.SettingRead
%>
<%
    'Validate the session
    'Obtain the session ID from the querystring
    SessionID = CInt(Request.QueryString("SessionID"))
    'ValidateSession(SessionID)
    'Check if we are in read-only mode
    blnReadOnly = Request.QueryString("Display")
    If blnReadOnly = CStr(true) Then 
        'render an image view, not a image capture
        Response.Write("<script language=javascript defer>void SetReadOnly();</script>")
    End IF
    'fetch the current patient and episode information for the control
    objEnt = new ENTRTL10.EntityRead()
    lngEpisodeID = objEnt.CurrentEpisodeID(SessionID)
    objEnt = Nothing
%>
<DIV id=xmldata><XML id='patientData'><ROOT><%
    'Episode data
    objTrn = new TRNRTL10.Transport()
    strXML = objTrn.ExecuteSelectRowSP(SessionID, "Episode", lngEpisodeID)
    objTrn = Nothing
    Response.Write(strXML)
    'Squeeze out the patient PK
    dom = new XmlDocument()
    dom.TryLoadXml(CStr(strXML))
    lngEntityID = dom.DocumentElement.GetAttribute("EntityID")
    dom = Nothing
    'Patient data
    objTrn = new TRNRTL10.Transport()
    strXML = objTrn.ExecuteSelectRowSP(SessionID, "Patient", lngEntityID)
    objTrn = Nothing
    Response.Write(strXML)
%>
</ROOT></XML></DIV><%
    'Configuration Information
%>
<DIV id=xmldata><XML id='configData'><ROOT><%
    objSetting = new GENRTL10.SettingRead()
    'strXML = objSetting.GetValue(sessionID, "HS2000", "General", "Configuration", "<Configuration port='1' baudrate='115200' singleimageonly='true' />")
    objSetting = Nothing
    Response.Write(strXML)
%>
</ROOT></XML></DIV>
<script language="javascript" src="scripts/OrderFormResizing.js" ></script>
<script language="javascript" src="HS2KScanner.js" ></script>
<script language="javascript" src="../sharedscripts/Controls.js" ></script>
<script language="javascript" src="../sharedscripts/icwFunctions.js" ></script>

<script language="javascript">

//===========================================================================
//							Public Methods
//===========================================================================

function Resize() {

//Standard resize event
//This is fired from the hosting page when a resize event
//occurrs.
//This function is OPTIONAL

}

//===========================================================================

function Populate(strData_XML) {

    instanceData.loadXML(strData_XML);
	
	var imageID = instanceData.selectSingleNode("//attribute[@name='Scan']/@value").value;
	
	image1.src = "../../ImageServer/ICW_Image.aspx?SessionID=<%= SessionID %>&TableName=NonXrayRadiologyResponse&FieldName=Scan&ImageID=" + imageID;
	
}

//===========================================================================

function GetData() {

//Standard method to read data from this control.
//Called from the hosting form to retrieve data
//This function is MANDATORY

//MUST Return data in the following format:
//
//	"sToken=<sValue>"
//
//	sToken:  	String reserved word; one of {value|xml}
//	<sValue>:	String specifying the data.  

	return "xml=" + uploadControl.GetImages();

}


//===========================================================================

function FilledIn() {

//Return true if all of the mandatory fields on this 
//page are filled in.
//This function is MANDATORY

	return true;

}

//============================================================================
</script>


<SCRIPT ID=clientEventHandlersJS LANGUAGE=javascript>
<!--

function uploadControl_Ready() {

	

}

//-->
</SCRIPT>
<SCRIPT LANGUAGE=javascript FOR=uploadControl EVENT=Ready>
<!--
 uploadControl_Ready()
//-->
</SCRIPT>

<link rel="stylesheet" type="text/css" href=   "../../../Style/application.css" />

</head>

<body id="formBody">

<%
    If Not CDbl(blnReadOnly) Then 
%>

<OBJECT onreadystatechange="Initialise()" id=uploadControl style="LEFT: 0px; TOP: 0px" 
	classid="clsid:A14DE16F-6D25-4DCF-9E2B-6F7179C966CE" 
	CODEBASE="HS2kUpload.CAB#version=1,0,0,0"
	VIEWASTEXT>
	<PARAM NAME="_ExtentX" VALUE="18098">
	<PARAM NAME="_ExtentY" VALUE="9499"></OBJECT>
<%
    Else
%>

	<img id="image1"></img>
<%
    End IF
%>


<xml id="instanceData"></xml>

</body>
</html>
