<%@ Page language="vb" %>

<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Constants" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationEpisodeList.aspx
    '
    'Touchscreen Episode list application.
    '
    '
    'Results are paged onto the screen; if there are too many to fit on the screen, back and next buttons
    'allow the user to page through the results.
    '
    'Modification History:
    '02Feb12 YB  Written
    '06Oct15 CA  TFS131387 - Updated to that selecting a patient raises the EpisodeSelected event
    '----------------------------------------------------------------------------------------------------------------
	Dim sessionId As Integer
    Dim windowHeight As Integer 
    Dim windowWidth As Integer 
	Dim entityId As Integer
	Dim height As Integer
    Dim strEpisodesXml As String
    Dim episodeRead As ENTRTL10.EpisodeRead = Nothing

    'Read querystring.  Note that parameters from previous pages are persisted to support
    'the "back" functionality.  Unfortunately, they can't all be persisted in the state table.
	sessionId = Integer.Parse(Request.QueryString("SessionID"))
   
    ' Clear existing states
	StateSet(sessionId, "Episode", 0)  
    
    ' Clear current request index
    SessionAttributeSet(sessionId, DA_REQUEST_STARTINDEX, "0")
        
    'Store / retrieve our height/width.  This will be passed on the querystring
    'initially, and read from state thereafter
    windowHeight = CIntX(RetrieveAndStore(sessionId, CStr(DA_HEIGHT)))
    windowWidth = CIntX(RetrieveAndStore(sessionId, CStr(DA_WIDTH)))
    
    'Get the entityID; this is passed on the querystring initially, and
    'read from state thereafter.
    entityId = CIntX(Request.QueryString(DA_ENTITYID))
    If entityId > 0 Then
        StateSet(sessionId, "Entity", entityId)
    Else
        entityId = StateGet(sessionId, "Entity")
    End IF
    
    'Get a list of active episodes for this patient.
    ' Dim bGroupOrdersets As Boolean = CBool(Generic.SettingGet ( SessionID, "OCS", "DrugAdministration", "GroupOrderSets", "1" ))   
    ' strRequest_XML = AdminRequestList(SessionID, EntityID, bGroupOrdersets, 0)
    'Dim strRoutine_XML
    'Dim strURL = "RoutineSearch.aspx" & "?SessionID=" & SessionID & "&RoutineName=Episode Selector"
    'ScriptInputControlsByRoutineDescription(SessionID, "Episode Selector", strURL, strRoutine_XML, "Vertical")
    episodeRead = New ENTRTL10.EpisodeRead()
    strEpisodesXml = episodeRead.EpisodesByEntityForDrugAdmin(sessionId, entityId, True)
    
    ' Clear out "DrugAdminEpisodeWarning" which is a warning that is displayed on episode slection in the request list
    ' "DrugAdminEpisodeWarning" is also cleared in episode selector and should be cleared wherever we select an episode
    SessionAttributeSet(sessionId, DA_EPISODE_WARNING, string.Empty)
    SessionAttributeSet(SessionID, DA_EPISODE_NOWARNING, string.Empty)
  
    'Sort out the height we have to fill with buttons
	height = windowHeight - CIntX(2 * TouchscreenShared.BUTTON_STANDARD_HEIGHT) - (4 * CIntX(BUTTON_SPACING))
%>
<html>
<head>
    <title>Drug Administration</title>
    <script src="../sharedscripts/jquery-1.3.2.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/icw.js"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/ICWFunctions.js"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
    <script type="text/javascript" language="javascript" src="./scripts/DrugAdministrationConstants.js"></script>
    
    <script language="javascript" type="text/javascript">
        var m_objSrc;
        //----------------------------------------------------------------------------------------------
        function BackToPatientList() {
            //Fires when the "back" button is pressed
            var strUrl = 'AdministrationPatientList.aspx' + '?SessionID=<%= sessionId %>';
            void TouchNavigate(strUrl);
        }

        function RAISE_EpisodeSelected(episode) {
                ICWEventRaise();
        }

        function EpisodeSelect(objSelected) {
            void DisableButtons();
            var episodeId = objSelected.getAttribute('episodeid');

            var strUrl = 'EpisodeSelected.aspx'
			      + '?SessionID=<%= sessionId %>'
			      + '&' + DA_EPISODEID + '=' + episodeId;

            document.getElementById("fraSelectEpisode").src = strUrl;

            var jsonEntityEpisodeVid = ICW.clinical.episode.eventSelectedRaised(episodeId, 0, <%= sessionId %>, 'hap');
            RAISE_EpisodeSelected(jsonEntityEpisodeVid);
        }

        //----------------------------------------------------------------------------------------------
        window.onload = function () { document.body.style.cursor = 'default'; }
    </script>

    <link rel='stylesheet' type='text/css' href='../../style/application.css' />
    <link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
    <link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
</head>
<body class="Touchscreen RequestList">
    <iframe style="display: none;" id="fraSelectEpisode"></iframe>

<table width="100%" cellpadding="0" cellspacing="0">
<%
    PatientBannerByID(sessionId, entityId, 0)
%>
<tr>
    <td colspan="2">
        <table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
	        <tr>
		        <td class="Toolbar" style="padding-left:<%= BUTTON_SPACING %>">
                    <%
                    'Script the "back to list" button.
                    TouchscreenShared.NavToolBarButton("../../images/touchscreen/DrugAdministration/List.gif", "Back to Patient List", "BackToPatientList()", True)
                    %>
		        </td>
	        </tr>
        </table>
    </td>
</tr>
</table>
<table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
	<%
        'Script the list O' patients, if there is one.
        If strEpisodesXml <> "" Then 
    %>
	<tr>
		<td class="Prompt">Select an EPISODE by pressing the screen.</td>
	</tr>
	<tr>
	    <td valign="top">
	        <% ScriptButtonPage(sessionId, TYPE_EPISODE, strEpisodesXml, height, windowWidth) %>
	    </td>
	</tr>
	<% 
	    Else
	%>
	    <tr>
		    <td class="Prompt">No Episodes could be found for the current patient.</td>
	    </tr>
	<% 
	    End IF
	%>
</table>
</body>
</html>