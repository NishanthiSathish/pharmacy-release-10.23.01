<%@ Page language="vb" %>
<%@ Import namespace="System.IO" %>
<%@ Import namespace="System.Xml" %>
<%@ Import namespace="System.Xml.Xsl" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.ICWCookie" %>

<%
    Dim lngSessionID As Long 
    Dim lngEpisodeID As Long 
	Dim objStateRead As GENRTL10.StateRead
    Dim objPrescription As Object 
	Dim objState As GENRTL10.State
    Dim lngCookieID As Double 
	Dim xmldoc As XmlDocument
    Dim lngPrescriptionID As Long 
    Dim strXML As String 
    Dim strParameterXML As String 
	Dim objEpisodeRead As INTRTL10.IENRTL10.EpisodeRead
    Dim strReturn As String 
	Dim objXML As XmlDocument
	Dim objXSL As XslCompiledTransform
    Dim strScheduleTemplateID As String 
    Dim TableID As Object 
	Dim objDOM As XmlDocument
	Dim objAttribute As XmlElement
	Dim objTable As ICWRTL10.TableRead
	Dim objAlias As ICWRTL10.AliasRead
    Dim strAliasXML As Object 
    Dim strValue As String 
    Dim UnitID As String 
    Dim UnitXML As String 
	Dim objUnit As DSSRTL20.UnitsRead
	Dim objNewEpisodeNode As XmlElement
	Dim objOldEpisodeNode As XmlElement
	Dim objEpisodeDOM As XmlDocument
	Dim objUnitDOM As XmlDocument
    Dim objPatientTypeAttribute As XmlElement
	Dim objEntity As Object
    Dim lngEntityID As Integer 
    Dim objScheduleTemplateID As XmlNode
    Dim strPersonXML As Object 
    Dim strAscribeInstance As String 
    Dim strUserID As String 
    Dim strFullName As String 
    Dim strAscribePassLevel As String 
    Dim strNoteType As String
    Dim temp As XmlElement
%>
<%
    '---------------------------------------------------------------------------------------------
    '
    'ICW_Dispensing.aspx
    '
    'ICW web application wrapper for the "web-based" Dispense control.
    '
    'ICW Parameters: AscribeSiteNumber
    '
    'Modification History:
    '21Oct04 PH Created
    '26Mar08 EAC PRN prescriptions do not have a ScheduleTemplateID node in the XML. Correct the handling of PRN prescriptions.
    
%>

<%
    lngSessionID = Generic.CLngX(Request.QueryString("SessionID"))
    lngPrescriptionID = 0
    lngPrescriptionID = Generic.CLngX(Request.QueryString("PrescriptionID"))
    'Get The User EntityID form the sessionID
    objEntity = new ENTRTL10.EntityRead()
    lngEntityID = CInt(objEntity.EntityIDFromSession(lngSessionID))
    objEntity = Nothing
    If lngEntityID > 0 Then 
        'Get the Person details from the EntityID
        objEntity = new ENTDTL10.EntityRead()
        strPersonXML = objEntity.Item(lngSessionID, lngEntityID, "Person")
        objEntity = Nothing
        objXML = new XmlDocument()
        Dim xmlLoaded As Boolean = False

        Try
            objXML.loadXML(strPersonXML)
            xmlLoaded = True
        Catch ex As Exception
        End Try

        If xmlLoaded Then 
            strUserID = objXML.documentElement.Attributes.GetNamedItem("Initials").InnerText
            strFullName = Trim(objXML.documentElement.Attributes.GetNamedItem("Forename").InnerText) & " " & Trim(objXML.documentElement.Attributes.GetNamedItem("Surname").InnerText)
        End IF
        objXML = Nothing
    End IF
    strAscribeInstance = Trim(ICW.ICWParameter("AscribeInstance", "Name of Instance of Pharmacy Gateway settings", ""))
    If strAscribeInstance = "" Then 
        strAscribeInstance = Request.QueryString("AscribeInstance")
    End IF
    strAscribePassLevel = Trim(ICW.ICWParameter("AscribePassLevel", "Version 8 Access Level 0 to 9", ""))
    If strAscribePassLevel = "" Then 
        strAscribePassLevel = Request.QueryString("AscribePassLevel")
    End IF
    strNoteType = Trim(ICW.ICWParameter("NoteType", "NoteType Used to attach to dispensed request", ""))
    If strNoteType = "" Then 
        strNoteType = Request.QueryString("NoteType")
    End IF
    objStateRead = new GENRTL10.StateRead()
    lngEpisodeID = CLng(objStateRead.GetKey(CInt(lngSessionID), "Episode"))
	objStateRead = Nothing
	
	lngCookieID = GetCookieID(lngSessionID)
	If lngCookieID = -1 Then
		'Create cookie because it doesnt exist
		lngCookieID = CreateCookie(lngSessionID)
	End If
	
    objState = new GENRTL10.State()
    objState.SetKey(CInt(lngSessionID), "Cookie", CInt(lngCookieID))
    objState = Nothing
    If lngPrescriptionID > 0 Then 
        objPrescription = new OCSRTL10.RequestTypeRead()
        strXML = CStr(objPrescription.GetRequestTypeByRequestXML(lngSessionID, lngPrescriptionID))
        objPrescription = Nothing
        objXML = new XmlDocument()
        objXML.loadXML(strXML)
        strValue = objXML.documentElement.Attributes.GetNamedItem("TableID").InnerText
        objPrescription = new OCSRTL10.OrderCommsItemRead()
        strXML = CStr(objPrescription.GetXML(lngSessionID, CLng(strValue), lngPrescriptionID))
        objPrescription = Nothing
        objXSL = new XslCompiledTransform()     
        objXSL.Load(Server.MapPath("../../App_Data/NorthPennineDischargeRxTransform.xslt"))
        objXML = new XmlDocument()
        objXML.loadXML(strXML)
        Dim settings as XmlWriterSettings = new XmlWriterSettings()
        settings.OmitXmlDeclaration = True
        Dim tempString As New StringBuilder()
        Dim tempWriter As XmlWriter = XmlWriter.Create(tempString, settings)
        objXSL.Transform(objXML, Nothing, tempWriter)
        tempWriter.Close()
        xmldoc = new XmlDocument()
        xmldoc.LoadXml(tempString.ToString())
        'objXML.transformNodeToObject(objXSL, xmldoc)
        'xmldoc = objXML.transformNode(objXSL)
        strXML = xmldoc.InnerXml
        'Set xmlnode = xmldoc.selectSingleNode("xmldata/Requests/Request/RequestData") 'RELOAD THE NODE!
        'Set xmlnode = xmldoc.selectSingleNode("Requests/Request/RequestData")
        strScheduleTemplateID = "0"
        objScheduleTemplateID = xmldoc.documentElement.selectSingleNode("Request/RequestData/attribute[@name='ScheduleTemplateID']/@value")
    
        If Not objScheduleTemplateID Is Nothing Then
            strScheduleTemplateID = objScheduleTemplateID.InnerText
        End If
        '19Jun08 ST Commented out as per 9.13 merges
        'strScheduleTemplateID = xmldoc.documentElement.selectSingleNode("Request/RequestData/attribute[@name='ScheduleTemplateID']/@value").text
        If CLng(strScheduleTemplateID) > 0 Then 
            'OK Now we need to look up the tableID of the scheduletemplatealias table
            objTable = new ICWRTL10.TableRead()
            TableID = objTable.GetIDFromDescription(lngSessionID, "ScheduleTemplate")
            objTable = Nothing
            'Now we have the ID we need to look up the alias for the dir code
            objAlias = new ICWRTL10.AliasRead()
            strAliasXML = objAlias.GetAlias(lngSessionID, "V8 compatibility layer", TableID, strScheduleTemplateID)
            objAlias = Nothing
            objDOM = new XmlDocument()
            'Not needed cos cant get Alias row, just the Alias
            'If objDOM.loadXML(strAliasXML) Then
            'strValue = objDOM.documentElement.Attributes.getNamedItem("Alias").Text
            ''strText = objDOM.documentElement.Attributes.getNamedItem("Description").Text
            'End If
            objAttribute = xmldoc.createElement("attribute")
            objAttribute.setAttribute("name", "Dircode")
            objAttribute.setAttribute("value", strAliasXML)
            objAttribute.setAttribute("text", "")
            If Not objAttribute Is Nothing Then 
                xmldoc.documentElement.SelectSingleNode("Request/RequestData").appendChild(objAttribute)
            End IF
        End IF
        If Not xmldoc.documentElement.selectSingleNode("Request/RequestData/attribute[@name='UnitID_Dose']") Is Nothing Then 
            UnitID = xmldoc.documentElement.SelectSingleNode("Request/RequestData/attribute[@name='UnitID_Dose']").Attributes.GetNamedItem("value").InnerText
            objUnit = new DSSRTL20.UnitsRead()
            UnitXML = objUnit.GetUnitByID(CInt(lngSessionID), CInt(UnitID))
            objUnit = Nothing
            objUnitDOM = new XmlDocument()
            Dim xmlLoaded As Boolean = False

            Try
                objUnitDOM.LoadXml(UnitXML)
                xmlLoaded = True
            Catch ex As Exception
            End Try

            If xmlLoaded Then 
                xmldoc.documentElement.SelectSingleNode("Request/RequestData/attribute[@name='UnitID_Dose']").Attributes.GetNamedItem("text").InnerText = objUnitDOM.documentElement.SelectSingleNode("Unit").Attributes.GetNamedItem("Abbreviation").InnerText
            End IF
            objUnitDOM = Nothing
        End IF
        strXML = xmldoc.InnerXml
        objXML = Nothing
        objXSL = Nothing
        '----------------------------------------------------------------
        strParameterXML = "<Parameters><Parameter name=""episodeXml"">&lt;Episodes&gt;&lt;Episode Type=&quot;Episode&quot; EpisodeType=&quot;Clinical&quot; EpisodeId=&quot;" + CStr(lngEpisodeID) + "&quot;/&gt;&lt;/Episodes&gt;</Parameter></Parameters>"
        objEpisodeRead = New INTRTL10.IENRTL10.EpisodeRead()
        strReturn = Generic.XMLReturn(objEpisodeRead.EpisodeXML(CInt(lngSessionID), strParameterXML))
        objEpisodeRead = Nothing
        objEpisodeDOM = new XmlDocument()
        objEpisodeDOM.loadXML(strReturn)
        'Add in new patient Type
        objPatientTypeAttribute = objEpisodeDOM.createElement("attribute")
        objPatientTypeAttribute.setAttribute("name", "PatientType")
        objPatientTypeAttribute.setAttribute("value", "D")
        objEpisodeDOM.documentElement.selectSingleNode("Success/Episodes/Episode/Entity/EntityData").appendChild(objPatientTypeAttribute)
        objPatientTypeAttribute = Nothing
        If Not objEpisodeDOM.documentElement.selectSingleNode("Success/Episodes/Episode/EpisodeData/attribute[@name='EpisodeTypeID']") Is Nothing Then 
            temp = objEpisodeDOM.documentElement.selectSingleNode("Success/Episodes/Episode/EpisodeData/attribute[@name='EpisodeTypeID']")
            temp.setAttribute("text", "D")
        End If
        '----------------------------------------------------------------
        'Patch the two together
        'Set objNewEpisodeNode = objEpisodeDOM.documentElement.selectSingleNode("Episodes/Episode").cloneNode(True)
        objNewEpisodeNode = objEpisodeDOM.documentElement.selectSingleNode("Success/Episodes/Episode").cloneNode(true)        
        objOldEpisodeNode = xmldoc.documentElement.selectSingleNode("Request")
        objOldEpisodeNode.replaceChild(xmldoc.ImportNode(objNewEpisodeNode, true), xmldoc.documentElement.selectSingleNode("Request/Episode"))
        strXML = xmldoc.InnerXml
        xmldoc = Nothing
    End IF
%>


<html>
<head>
<title>Pharmacy Gateway</title>
<link rel="stylesheet" type="text/css" href="../../style/application.css">

<script src="../sharedscripts/icw.js"></script>
<script type="text/javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>
<script src="script/PharmacyGateway.js"></script>

<script >
<!--

//===============================================================================
//									ICW EventListeners
//===============================================================================

function EVENT_EpisodeSelected(vid)
{
    // Check episode and entity rows exist in the DB with the expected versions as specified in the vid parameter
    ICW.clinical.episode.episodeSelected.init(<%= CInt(Request.QueryString("SessionID")) %>, vid, EntityEpisodeSyncSuccess);

    // Called if/when Entity & Episode exist in the DB at the correct versions
    function EntityEpisodeSyncSuccess(vid)
    {
        // Occurs when episode is changed. Causes this list to be refreshed.
	        RefreshState(0, 0);
    }
}

//DJH - TFS Bug 12880 - Add new Episode Cleared event.
function EVENT_EpisodeCleared() {
    RefreshState(0, 0);
}

function EVENT_Dispensing_RefreshState(RequestID_Prescription, RequestID_Dispensing)
{
// Listens for "Dispensing_RefreshState" events, and will cqall RefreshState on the objDispense object
// 05May04 PH Created
	RefreshState(RequestID_Prescription, RequestID_Dispensing);
}

//-->
</script>

<SCRIPT ID=clientEventHandlersJS LANGUAGE=javascript>
<!--
//function objDispense_RefreshView(RequestID_Prescription, RequestID_Dispensing) 
//{
//	RAISE_Dispensing_RefreshView(RequestID_Prescription, RequestID_Dispensing);
//}

//===============================================================================
//									ICW Raised Events
//===============================================================================

function RAISE_Dispensing_RefreshView(RequestID_Prescription, RequestID_Dispensing)
{
// This event is listened to by the DispensingPMR page that hosts the PMR grid, 
// This event is raised when an item has been created or edited by the ObjDispensing UserControl. 
// A RequestID of 0 means "create", a positive RequestID means edit the item with that RequestID
	window.parent.RAISE_Dispensing_RefreshView(RequestID_Prescription, RequestID_Dispensing);
}

function RAISE_NoteChanged()
{
    window.parent.RAISE_NoteChanged();
}


//-->
</SCRIPT>


<SCRIPT LANGUAGE=vbscript>
<!--
//function objDispense_RefreshView(RequestID_Prescription, RequestID_Dispensing)
//	
//	RAISE_Dispensing_RefreshView RequestID_Prescription, RequestID_Dispensing
	
//end function

//-->
</SCRIPT>

</head>

<body id="bdy" 
	SessionID="<%= lngSessionID %>" 
	EpisodeID="<%= lngEpisodeID %>"
	CookieID="<%= lngCookieID %>"
	PrescriptionID="<%= lngPrescriptionID %>"
	NoteType="<%= strNoteType %>"
	UserID="<%= strUserID %>"
	FullName="<%= strFullName %>"
	AscribeInstance="<%= strAscribeInstance %>"
	AscribePassLevel="<%= strAscribePassLevel %>"
	onload="return window_onload()"
>
<table width="100%" height="100%" cellpadding=0 cellspacing=0>	
		<tr height="1%">
			<td>
<%
    ICW.ICWHeader(lngSessionID)
%>

			</td>
		</tr>
		<tr>
			<td>
			
<OBJECT 
					id=objDispense 
					style="left:0px;top:0px;width:100%;height:100%"
					codebase="../../../ascicw/cab/HEdit.cab" 
					component="PharmGateCtl.ocx"
					classid=CLSID:7FF75E1E-DD03-4313-826F-2399FEC7E0C7 VIEWASTEXT>
					<PARAM NAME="_ExtentX" VALUE="16113">
					<PARAM NAME="_ExtentY" VALUE="11139">
					<SPAN STYLE="color:red">ActiveX control failed to load! -- Please check browser security settings.</SPAN>
				</OBJECT>

			</td>
		</tr>
	</table>	

<iframe application=yes 
		  style='display:none;' 
		  id='fraSave'     
		  src="../OrderEntry/OrderEntrySaver.aspx" 
		  >
</iframe>

<%
    'Response.write "<XML ID=myxml><xmldata>" & strXML & "</xmldata></xml>"
    Response.Write("<XML ID=myxml>" & strXML & "</xml>")
    'Response.write "<XML ID=Episodexml><xmldata>" & strAscribeInstance & "</xmldata></xml>"
%>
	
</body>

<%
    If lngPrescriptionID > 0 Then 
%>

<script LANGUAGE=javascript defer>

var blnSuccess;
var UserID = document.body.getAttribute("UserID");
var AscribePassLevel = document.body.getAttribute("AscribePassLevel");
var FullName = document.body.getAttribute("FullName");
var AscribeInstance = document.body.getAttribute("AscribeInstance");
var NoteType = document.body.getAttribute("NoteType");
blnSuccess = objDispense.RefreshState(<%= lngSessionID %>,<%= lngPrescriptionID %>,0,myxml.xml,UserID,AscribePassLevel,FullName,AscribeInstance);
if(blnSuccess == true)
{
fraSave.AttachSystemNote(document.body.getAttribute('SessionID'), 'Request', document.body.getAttribute('PrescriptionID'), NoteType, '');

}


function SaveComplete(blnSuccess) {
	
//Fires when the save page has finished saving.  It contains
//an XML Island which holds the details of the success / failiure
//of each item in the 

	if (blnSuccess) {
		RAISE_NoteChanged();				
					
	}
	else {
		//Something failed; ALWAYS show the error report
		void ShowSaveResults();
	}
}

function ShowSaveResults() {

var intCount = new Number();
var objRule = new Object();

	var DOM = document.frames['fraSave'].document.all['saveResultsXML'].XMLDocument;

	var strMsg = 'WARNING!  Save Failed!\n\n';
	var colErrors = DOM.selectNodes('//BrokenRules');
	if (colErrors.length > 0) {
		for (intCount=0; intCount < colErrors.length; intCount++) {
			objRule = colErrors[intCount].selectSingleNode('Rule');
			strMsg += objRule.getAttribute('Text') + '\n\n';
		}
		Popmessage(strMsg);		
	}

}
</script>
<%
    End IF
%>

<!--</body>-->
</html>
