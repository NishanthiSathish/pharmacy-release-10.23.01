<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<!--#include file="../../application/SharedScripts/ASPHeader.aspx"-->

<%
    Dim objSetting As Object 
    Dim objStateRead As Object ' GENRTL10.StateRead
    Dim lngSessionID As Long 
    Dim lngEpisodeID As Long 
    Dim strSelectEpisode As Object 
    Dim strFieldStyle As String 
    Dim m_intPatientFieldCount As Integer 
    Dim objRoutineRead As Object ' ICWRTL10.RoutineRead
    Dim xmlEpisode As Object 
    Dim xmlDoc As XmlDocument
    Dim xmlNodeList As XmlNodeList
    Dim xmlElement As XmlElement
    Dim xmlAttrib As XmlAttribute
    Dim strParams_XML As Object 
%>
<%
    '---------------------------------------------------------------------------------------------
    '
    'ICW_PBSEntityPanel.aspx
    '
    'Displays PBSPatient information . The entity to be
    'displayed is determined by querying the State table to get an EpisodeID. The
    'EpisodeID is then passed into the "Entity Panel" Routine that fire a user-
    'defined query, which returns the column names and values to be displayed.
    'The column names are used as "caption titles" for the column values.
    '
    'QueryString Parameters
    'SessionID				- SessionID
    '
    '
    'Modification History:
    '24Apr07 TH Written from Entity/Episode panel
    '10May07 ST Added Fast Repeat Number handling
%>

<%
    'Dim blnAllowEpisodeSelection
    'dim strEpisodeTitle
    'Dim m_intEpisodeFieldCount
    'strSelectEpisode = ICWParameter("SelectEpisode", "Set to True to use this application as the means of episode selection; Passive to display the entity/episode selected by another application. ", "True,False")
    'If strSelectEpisode = "" Then strSelectEpisode = "True"
    'blnAllowEpisodeSelection = (Lcase(strSelectEpisode) = "true")
    'strEpisodeTitle = Trim(ICWParameter("EpisodeTitle", "Title that will be shown in the Episode portion of the Entity Panel. Leave blank to display 'Episode of Care'", ""))
    'if strEpisodeTitle="" then
    'strEpisodeTitle = "Episode of Care"
    'end if
    strFieldStyle = UCase(Trim(ICW.ICWParameter("FieldStyle", "Fields are drawin in either columns across the screen or rows down the screen", "Columns,Rows")))
    lngSessionID = Generic.CLngX(Request.QueryString("SessionID"))
    'ValidatePolicy lngSessionID, "Entity Panel View"
    'Read the current entity id from the user's session state
    '-1 is returned if no user is set in session state
    objStateRead = new GENRTL10.StateRead()
    lngEpisodeID = CLng(objStateRead.GetKey(CInt(lngSessionID), "Episode"))
    objStateRead = Nothing
%>


<html>
<head>
<title>PBS Patient Details</title>
<link rel="stylesheet" type="text/css" href="../../style/application.css">
<link rel="stylesheet" type="text/css" href="../../style/EntityPanel.css">

<script src="../sharedscripts/icw.js"></script>
<script type="text/javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>
<script src="../SharedScripts/Menu.js"></script>
<script src="script/PBSEntityPanel.js"></script>

<script >
<!--

//===============================================================================
//									ICW ToolMenus
//===============================================================================



function EVENT_PBSPatient_Edit()
{
// <ToolMenu PictureName="edit.gif" Caption="Edit" ToolTip="Edit" ShortCut="E" HotKey="" />

	LaunchEditPBSPatient(<%= lngEpisodeID %>);

    // 21Feb11 PH Take ICW Episode integer, convert to entity & episode versioned identifiers, and raise the ICW Episode Selected Event
    // Create JSON episode event data
    var jsonEntityEpisodeVid = ICW.clinical.episode.eventSelectedRaised(lngEpisodeID, 0, document.all("bdy").getAttribute("SessionID"));
    // Raise episode event via ICW framework, using entity & episode versioned identifier
    EVENT_EpisodeSelected(jsonEntityEpisodeVid); // Call refresh internally aswell.
//	EVENT_EpisodeSelected();
}

function EVENT_PBSFastRepeatSearch()
{
//  <ToolMenu PictureName="search.gif" Caption="PBS Fast Search" ToolTip="Search" ShortCut="S" HotKey="" />
	
	LaunchPBSFastRepeatSearch(<%= lngSessionID %>);
}



//===============================================================================
//									ICW EventListeners
//===============================================================================
function EVENT_EpisodeSelected(vid)
{
	// Check episode and entity rows exist in the DB with the expected versions as specified in the vid parameter
	ICW.clinical.episode.episodeSelected.init(<%= CInt(Request.QueryString("SessionID")) %>, vid, EntityEpiodeSyncSuccess);

    // Called if/when Entity & Episode exist in the DB at the correct versions
    function EntityEpiodeSyncSuccess(vid)
    {
	    var strURL = '../PBSEntityPanel/ICW_PBSEntityPanel.aspx'
				      + '?SessionID=<%=lngSessionID%>'
				      + '&FieldStyle=<%=strFieldStyle %>';
    				  
    	
	    window.navigate(ICWURL(strURL));
    }
}

//DJH - TFS Bug 12880 - Add new Episode Cleared event.
function EVENT_EpisodeCleared() {
    var strURL = '../PBSEntityPanel/ICW_PBSEntityPanel.aspx'
		          + '?SessionID=<%=lngSessionID%>'
		          + '&FieldStyle=<%=strFieldStyle %>';
    			  

    window.navigate(ICWURL(strURL));
}

function EVENT_Dispensing_RefreshView(RequestID_Prescription, RequestID_Dispensing)
{
// Causes this list to be refreshed from the DB
	var strURL = '../PBSEntityPanel/ICW_PBSEntityPanel.aspx'
				  + '?SessionID=<%=lngSessionID%>'
				  + '&FieldStyle=<%=strFieldStyle %>';
				  
	
	window.navigate(ICWURL(strURL));
}

//-->
</script>

<script>
<!--

//===============================================================================
//									ICW Events
//===============================================================================

function RAISE_EpisodeSelected(jsonEntityEpisodeVid)
{
	// Raised to refresh itself
	ICWEventRaise();
}

function RAISE_Dispensing_RefreshView()
{
	ICWEventRaise();
}

//-->
</script>


</head>

<body id=bdy 
		SessionID="<%= lngSessionID %>" 
		EpisodeID="<%= lngEpisodeID %>" 
		FieldStyle="<%= strFieldStyle %>"
		scroll="no" 
		onload="return window_onload()"
>

<%
    If lngEpisodeID > 0 Then 
%>


	<table width="100%" height=100% cellpadding="0" cellspacing="0">
		<tr valign=top>
			<td width=100%>
				<!-- Patient Detail Area -->
				<table width="100%" height="100%">	
					<tr height="1%">
						<td>
<%
    'ICW.ICWHeader()
%>

						</td>
					</tr>
					<tr>
						<td id="tdPBSPatientPanel" class="PanelBackground">
							<div style="overflow-y:auto;width:100%;height:100%">
<%
        'Read the entitys details
        dim xmlret as object '16-Jan-2008 JA Error code 162
        xmlDoc = new XmlDocument()
        objRoutineRead = new ICWRTL10.RoutineRead()
        strParams_XML = objRoutineRead.CreateParameter("EpisodeID", 2, 4, lngEpisodeID)
        '16-Jan-2008 JA Error code 162
        'xmlDoc.loadXML(CStr(objRoutineRead.ExecuteByDescription(lngSessionID, "PBS Patient Panel", strParams_XML)))
		xmlret = cstr(objRoutineRead.ExecuteByDescription(lngSessionID, "PBS Patient Panel", strParams_XML))
		xmlDoc.loadXML(xmlret)

        objRoutineRead = Nothing
        xmlNodeList = xmlDoc.selectNodes("//*")
        m_intPatientFieldCount = 0
        For Each xmlElement In xmlNodeList
            For Each xmlAttrib In xmlElement.attributes									
				%>
				<span id="divPBSPatient<%=m_intPatientFieldCount%>" style="visibility: hidden" nowrap>
				    <span id="spnPBSPatientCaption<%=m_intPatientFieldCount%>" class="caption">&nbsp;<%=replace(Trim(xmlAttrib.Name), " ", "&nbsp;") %>:&nbsp;</span>
				    <span id="spnPBSPatientText<%=m_intPatientFieldCount%>" class="text">&nbsp;<%=replace(Trim(xmlAttrib.Value), " ", "&nbsp;") %>&nbsp;</span>
				</span>
				<br id="br<%=m_intPatientFieldCount%>">
				<%
                m_intPatientFieldCount = m_intPatientFieldCount + 1
            Next
        Next
        xmlElement = Nothing
        xmlNodeList = Nothing
        xmlDoc = Nothing
%>

							</div>
						</td>
					</tr>

				</table>
			</td>
			
		</tr>
	</table>

	<input type="hidden" id=txtPBSPatientFieldCount value="<%= m_intPatientFieldCount %>">

<%
    Else
%>

	<table width="100%" height="100%">
		<tr height="1%">
			<td>
<%
    'ICW.ICWHeader()
%>

			</td>
		</tr>
		<tr valign=center>
			<td align=center>
				No Patient is currently selected
			</td>
		<tr>
	</table>
<%
    End IF
%>


</body>
</html>
