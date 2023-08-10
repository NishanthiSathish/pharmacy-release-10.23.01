<%@ Page language="vb" %>

<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>

<%
    '---------------------------------------------------------------------------------------------------------
    '
    'ICW_DrugAdministration.aspx
    '
    'Touchscreen Drug Admin application.
    '
    '
    'Modification History:
    '26May05 AE  Written
    '18Mar06 AE  Modified; EntityID no longer in state.  Sure I've done this before...
    ' 25/02/2008 PR : F0013629  Add new parameter called DoseListRoutine and rename RoutineName paramter to PatientListRoutine
    '                           If DoseListRoutine populated need to use this to pull back dose list
    '22Sep11 XN     TFS1450 Got the admin request button on the banner to have the same status as the main screen
    '               Done by having extra desktop parameter SingleRequestRoutine on the DrugAdmin desktop
    '
    '06Oct15 CA     TFS131387 Showed loading message when selected an episode so there is no white screen.
    '
    '---------------------------------------------------------------------------------------------------------
    Dim routineName As String
    Dim doseListRoutine As String
    Dim singleRequestRoutine As String
    Dim sessionId As Integer
    Dim episodeRead As ENTRTL10.EpisodeRead
    Dim entityId As Integer 
    Dim episodeId As Integer 
    Dim strUrl As String
    Dim showPatientPhoto As Boolean = False
    Dim showPatientAlerts As Boolean = False
    Dim patientPhoto As String = String.Empty
    Dim patientAlerts As String = String.Empty
    Dim mode As String = String.Empty
    Dim origin As String = String.Empty
    Dim modalMode as Boolean = false

    origin = Request.QueryString("Origin")

    Const URL_START_DEFAULT As String = "../DrugAdministration/AdministrationPatientList.aspx"
    Const URL_START_PATIENT_IN_SCOPE As String = "../DrugAdministration/AdministrationEpisodeList.aspx"
    Const URL_START_EPISODE_IN_SCOPE As String = "../DrugAdministration/AdministrationRequestList.aspx"

    sessionId = CIntX(Request.QueryString("SessionID"))
    doseListRoutine = ICW.ICWParameter("DoseListRoutine", "Optional.  Specify a stored procedure which will return a dose list", "")   ' 25/02/08 PR new dose list routine paramater
    routineName = ICW.ICWParameter("PatientListRoutine", "Optional.  Specify a stored procedure which will return a patient list", "")
    singleRequestRoutine = ICW.ICWParameter("SingleRequestRoutine", "Optional.  Specify a stored procedure which will return a single request button", "")  ' 22Sep11 XN  TFS1450 Gextra desktop parameter SingleRequestRoutine on the DrugAdmin desktop

    patientPhoto = ICW.ICWParameter("ShowPatientPhoto", "Displays the patient photograph if available in the patient banner", "No,Yes") ' 130214 ST 72706 Allow patient photo to be displayed on the patient banner
    patientAlerts = ICW.ICWParameter("ShowPatientAlerts", "Displays the patient alert status in the patient banner", "No,Yes") ' 130214 ST 30958 Allow patient alerts to be displayed on the patient banner
    mode = ICW.ICWParameter("ModalMode", "If true shows a close button to close the modal window", "No,Yes")
    
    If Not patientPhoto Is Nothing AndAlso patientPhoto.ToLower() = "yes" Then
        showPatientPhoto = True
    End If
    If Not patientAlerts Is Nothing AndAlso patientAlerts.ToLower() = "yes" Then
        showPatientAlerts = True
    End If
        If Not mode Is Nothing AndAlso mode.ToLower() = "yes" Then
        modalMode = True
    End If
    
    'Check if an episode has been selected; if so, go straight to their admin screen.
    'Otherwise, we show the patient list first.
    'This is largely to support the ICW being called from a 3rd party app which will deal
    'with patient selection.
    'This application uses and stores EntityID, since we want to consider drugs across all episodes.
    'Order Entry applications use Episode ID however.  So we treat EpisodeID as the master, and if one
    'is stored, use it to obtain the EntityID.  If no EpisodeID is stored, but an EntityID is, we will use that.
    
    episodeId = CIntX(StateGet(sessionId, "Episode"))
    If episodeId > 0 Then
        'An episodeID has been set by another application selecting a patient.
        episodeRead = New ENTRTL10.EpisodeRead()
        '18Mar06 AE
        entityId = episodeRead.EntityIDFromEpisode(sessionId, episodeId)
        episodeRead = Nothing
    Else
        'An entityID might have been stored by this application, and persisted in state across a log-out/login.		'27Apr06 AE
        entityId = CIntX(StateGet(sessionId, "Entity"))
    End If
    
    If episodeId > 0 Then
        strUrl = URL_START_EPISODE_IN_SCOPE
    ElseIf entityId > 0 Then
        strUrl = URL_START_PATIENT_IN_SCOPE
    Else
        strUrl = URL_START_DEFAULT
    End If
    
    'Store our variables in the SessionAttribute store
    SessionAttributeSet(sessionId, CStr(DA_ROUTINENAME_PATIENT), routineName)
    SessionAttributeSet(sessionId, CStr(DA_ROUTINENAME_DOSE), doseListRoutine)   ' 25/02/08 PR new dose list routine paramater
    SessionAttributeSet(sessionId, CStr(DA_ROUTINENAME_SINGLEREQUEST), singleRequestRoutine) ' 22Sep11 XN  TFS1450 Gextra desktop parameter SingleRequestRoutine on the DrugAdmin desktop
    SessionAttributeSet(sessionId, IA_ADMIN, "0")     'Reset ImmediateAdmin
    SessionAttributeSet(sessionId, CStr(DA_SHOW_PATIENT_PHOTO), showPatientPhoto.ToString())
    SessionAttributeSet(sessionId, CStr(DA_SHOW_PATIENT_ALERTS), showPatientAlerts.ToString())
    SessionAttributeSet(sessionId, CStr(DA_REQUEST_STARTINDEX), "0")
    SessionAttributeSet(sessionId, CStr(DA_MODALMODE), modalMode.ToString())
    
    if origin <> String.Empty then
        SessionAttributeSet(sessionId, "origin", origin)
    end if
%>

<html>
<head>
<title>Drug Administration</title>
<script type="text/javascript" language="javascript" src="../sharedscripts/icw.js"></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>
<script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/icwfunctions.js"></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/Locking.js"></script>
<script type="text/javascript" language="javascript" defer="defer">
    ResizeScreen();
</script>

<script type="text/javascript" language="javascript" >
//  06Oct15 CA  TFS131387    
        //  Showed loading message when selected an episode so there is no white screen.
        ICWWindow().ICWMainStatusShow("Loading...");
        window.onload = function() {
            ICWWindow().ICWMainStatusHide();    
        }

//----------------------------------------------------------------------------------------------
function EVENT_Exit() 
{
    UnlockRequests ( <%= sessionId %> );
    
    // Unlock the the currently-locked entity
	if ( <%= entityId %> > 0 )
	{
		UnlockEntity(<%= sessionId %>, <%= entityId %>);
	}

	return true;
}

function EVENT_EpisodeSelected(vid)
{
    // Check episode and entity rows exist in the DB with the expected versions as specified in the vid parameter
    ICW.clinical.episode.episodeSelected.init(<%= CIntX(Request.QueryString("SessionID")) %>, vid, EntityEpisodeSyncSuccess);

    // Called if/when Entity & Episode exist in the DB at the correct versions
    function EntityEpisodeSyncSuccess(vid)
    {
        window.navigate(window.document.location.href);
    }
}

//DJH - TFS Bug 12880 - Add new Episode Cleared event.
function EVENT_EpisodeCleared()
{
    window.navigate(window.document.location.href);
}

//25Sep2009 JMei F0040487 Call printprocessor for printing DSS Warnings
function PrintDSSWarnings()
{
    ICWWindow().document.frames['fraPrintProcessor'].PrintDSSWarnings(document.all.SessionID.value,document.all.EpisodeID.value,document.all.DSSWarningsXML.value);
}

function ResizeScreen()
{
    
    var strPreviousWidth = GetVariable(document.all['fraMain'].src.substring(1).split("&"),DA_WIDTH);
    // only need to trigger this call when previously set height and weight are 0
    if ( strPreviousWidth == "0" || strPreviousWidth == "")
    {
        var vHeight = document.all['fraMain'].offsetHeight;
        var vWidth  = document.all['fraMain'].offsetWidth;
	    var strUrl = '<%= strUrl %>'
				      + '?SessionID=<%= Request.QueryString("SessionID") %>'
				      + '&' + DA_HEIGHT + '=' + vHeight
				      + '&' + DA_WIDTH + '=' + vWidth
				      + '&' + DA_ENTITYID + '=<%= entityId %>'
				      + '&' + DA_EPISODEID + '=<%= episodeId %>';
	    document.all['fraMain'].src = ICWURL(strUrl);
    }
}
</script>
</head>
<!--<frameset>
    <frame id="fraMain"/>
</frameset>-->
<body onunload="EVENT_Exit()" onresize="ResizeScreen();" style="position: fixed; top: 0; left: 0; bottom: 0; right: 0;">
    <iframe id="fraMain" width="100%" height="100%" application="yes"></iframe>

    <%--    29Sep2009 JMei F0040487 because cannot call js function in this page from a navigated window, we call button onclick function instead
            the following 3 elements are for storing the information --%>
    <input id="printer" type="button" value="" onclick="PrintDSSWarnings();" style="display: none"/>
    <input type="hidden" id="DSSWarningsXML" name="DSSWarningsXML" />
    <input type="hidden" id="SessionID" name="SessionID" />
    <input type="hidden" id="EpisodeID" name="EpisodeID"/>
</body>
</html>
