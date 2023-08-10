<%@ Page Language="VB" AutoEventWireup="false" CodeFile="ICW_PCTPatient.aspx.vb" Inherits="application_PCTPatient_ICW_PCTPatient" %>

<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<!--#include file="../SharedScripts/ASPHeader.aspx"-->

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
    Dim lngEntityID AS Long
%>
<%
    '---------------------------------------------------------------------------------------------
    '
    'ICW_PCTPatient.aspx
    '
    'Displays PCTPatient information . The entity to be
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
    '07Nov11 AJK 16270 Created
%>

<%
    strFieldStyle = UCase(Trim(ICW.ICWParameter("FieldStyle", "Fields are drawin in either columns across the screen or rows down the screen", "Columns,Rows")))
    lngSessionID = Generic.CLngX(Request.QueryString("SessionID"))
    objStateRead = new GENRTL10.StateRead()
    lngEpisodeID = CLng(objStateRead.GetKey(CInt(lngSessionID), "Episode"))
    lngEntityID = - 1
    lngEntityID = CLng(objStateRead.GetKey(CInt(lngSessionID), "Entity"))
    objStateRead = Nothing
%>


<html>
<head>
<title>PCT Patient Details</title>
<link rel="stylesheet" type="text/css" href="../../style/application.css">
<link rel="stylesheet" type="text/css" href="../../style/EntityPanel.css">
<%    'ICW.ICWParameter("SiteNumber", "The Site Number", "");  %>

<script src="../sharedscripts/icw.js"></script>
<script type="text/javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>
<script src="../SharedScripts/Menu.js"></script>
<script src="script/PCTPatientPanel.js"></script>

<script >
<!--

//===============================================================================
//									ICW ToolMenus
//===============================================================================

function EVENT_PCTPatient_Edit()
{
// <ToolMenu PictureName="edit.gif" Caption="Edit" ToolTip="Edit" ShortCut="E" HotKey="" />

	LaunchEditPCTPatient(<%= lngEntityID %>);

	var jsonEntityEpisodeVid = ICW.clinical.episode.eventSelectedRaised(<%= lngEpisodeID %>, 0, document.all("bdy").getAttribute("SessionID"));
    // Raise episode event via ICW framework, using entity & episode versioned identifier
    EVENT_EpisodeSelected(jsonEntityEpisodeVid); // Call refresh internally aswell.
}

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
	var strURL = '../PCTPatient/ICW_PCTPatient.aspx'
				  + '?SessionID=<%=lngSessionID%>'
				  + '&FieldStyle=<%=strFieldStyle %>'
				  + '&SiteNumber=<%=siteNumber %>';
	window.navigate(ICWURL(strURL));
    }
}

function EVENT_EpisodeCleared() {
    var strURL = '../PCTPatient/ICW_PCTPatient.aspx'
				  + '?SessionID=<%=lngSessionID%>'
				  + '&FieldStyle=<%=strFieldStyle %>'
				  + '&SiteNumber=<%=siteNumber %>';
	window.navigate(ICWURL(strURL));
}

function EVENT_Dispensing_RefreshView(RequestID_Prescription, RequestID_Dispensing)
{
	var strURL = '../PCTPatient/ICW_PCTPatient.aspx'
				  + '?SessionID=<%=lngSessionID%>'
				  + '&FieldStyle=<%=strFieldStyle %>'
				  + '&SiteNumber=<%=siteNumber %>';
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
	window.parent.RAISE_EpisodeSelected(jsonEntityEpisodeVid);
}

function RAISE_Dispensing_RefreshView()
{
    window.parent.RAISE_Dispensing_RefreshView();
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
		SiteID="<%= siteID%>"
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
        ICW.ICWHeader(lngSessionID)
%>

						</td>
					</tr>
					<tr>
						<td id="tdPCTPatientPanel" class="PanelBackground">
							<div style="overflow-y:auto;width:100%;height:100%">
<%
        'Read the entitys details
        dim xmlret as object
        xmlDoc = new XmlDocument()
        objRoutineRead = new ICWRTL10.RoutineRead()
        strParams_XML = objRoutineRead.CreateParameter("EpisodeID", 2, 4, lngEpisodeID)
		xmlret = cstr(objRoutineRead.ExecuteByDescription(lngSessionID, "PCT Patient Panel", strParams_XML))
		xmlDoc.loadXML(xmlret)

        objRoutineRead = Nothing
        xmlNodeList = xmlDoc.selectNodes("//*")
        m_intPatientFieldCount = 0
        For Each xmlElement In xmlNodeList
            For Each xmlAttrib In xmlElement.attributes									
				%>
				<span id="divPCTPatient<%=m_intPatientFieldCount%>" style="visibility: hidden" nowrap>
				    <span id="spnPCTPatientCaption<%=m_intPatientFieldCount%>" class="caption">&nbsp;<%=replace(Trim(xmlAttrib.Name), " ", "&nbsp;") %>:&nbsp;</span>
				    <span id="spnPCTPatientText<%=m_intPatientFieldCount%>" class="text">&nbsp;<%=replace(Trim(xmlAttrib.Value), " ", "&nbsp;") %>&nbsp;</span>
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

	<input type="hidden" id=txtPCTPatientFieldCount value="<%= m_intPatientFieldCount %>">

<%
    Else
%>

	<table width="100%" height="100%">
		<tr height="1%">
			<td>
<%
        ICW.ICWHeader(lngSessionID)
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
