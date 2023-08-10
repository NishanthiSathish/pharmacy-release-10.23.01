<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationPatientList.aspx
    '
    'Touchscreen patient list application.
    '
    '
    'Results are paged onto the screen; if there are too many to fit on the screen, back and next buttons
    'allow the user to page through the results.  This paging is done in this (the asp) tier, so returning
    'many many pages of results is A Bad Thing.  Shouldn't be an issue in normal use.
    '
    'Modification History:
    '24May05 AE  Written
    '
    '----------------------------------------------------------------------------------------------------------------
    Dim sessionId As Integer
    Dim routineName As String
    Dim searchString As String = String.Empty
    Dim windowHeight As Integer
    Dim windowWidth As Integer
    Dim routineRead As ICWRTL10.RoutineRead
    Dim intHeight As Integer
    Dim strPatientXml As String = String.Empty
    Dim strSearch As String
    Dim blnSearchDone As Boolean
    Dim strOnLoad As String = String.Empty
    Dim strRecordDoses As String = "None"
    
    blnSearchDone = False
    
    'Querystring variables
    sessionId = CIntX(Request.QueryString("SessionID"))
    
    'Store / retrieve our height/width.  This will be passed on the querystring
    'initially, and read from state thereafter
    windowHeight = CIntX(RetrieveAndStore(sessionId, CStr(DA_HEIGHT)))
    windowWidth = CIntX(RetrieveAndStore(sessionId, CStr(DA_WIDTH)))
    
    'If a search string is specified, store it in our state table
    If Request.QueryString("CancelSearch") <> "1" Then
        searchString = RetrieveAndStore(sessionId, CStr(DA_PATIENT_SEARCH))
    Else
        'Clear the previous search
        SessionAttributeSet(sessionId, CStr(DA_PATIENT_SEARCH), "")
    End If
    
    'look for a routine
    routineName = SessionAttribute(sessionId, CStr(DA_ROUTINENAME_PATIENT))
    
    'We're at the list o' patients, so clear the currently selected patient from session state
    StateSet(sessionId, "Entity", -1)
    StateSet(sessionId, "Episode", -1)
    
    'We might have a search to run:
    If searchString <> String.Empty Then
        
        '26Mar2013  Rams    59274 - error searching for a patient with ' in there name, in admin
        searchString = searchString.Replace("'", "''")
        
        'Parse the search string:
        'Searching quick and easy at present, it may well need upgrading in future
        strSearch = Replace(searchString, "%", "")
        
        'Prevent users entering wildcards
        'First look for "My% Search% String%":
        'eg:
        'user enters "A B Test"	to find "Andreaus Bacchus Tester"
        strSearch = Replace(searchString, " ", "% ")
        strSearch = strSearch & "%"
        strPatientXml = CStr(PatientSearch(sessionId, strSearch))
        
        'If we didn't get anything, try "% My% Search% String%"
        'eg:
        'user enters "A B Test" to find "Mr. Andreaus Bacchus Tester"
        If strPatientXml = "" Then
            strSearch = "% " & strSearch
            strPatientXml = CStr(PatientSearch(sessionId, strSearch))
        End If
        
        If strPatientXml = "<root></root>" Then
            strPatientXml = ""
        End If
        blnSearchDone = True
    End If
    
    'If a routine has been specified, run that and return the list o' patients.
    If (strPatientXml = "") And (routineName <> "") And Not blnSearchDone Then
        'Read the routine
        routineRead = New ICWRTL10.RoutineRead()
        strPatientXml = CStr(routineRead.ExecuteByDescription(sessionId, CStr(routineName), ""))
        routineRead = Nothing
        If strPatientXml <> "" Then
            ValidateRoutine_Patient(routineName, strPatientXml)
        End If
        
        ' F0063047 ST 030210 Changed to a string as setting is now not a true/false
        strRecordDoses = SettingGet(sessionId, "OCS", "DrugAdministration", "RecordDoses", "None")
        'blnRecordDoses = SettingGet(SessionID, "OCS", "DrugAdministration", "RecordDoses", "0") '20May08 AE  Check the Record Doses setting and only show the pick list button if it is set to 1
    End If
    
    If strPatientXml = "" Then
        strOnLoad = "PatientSearch()"
    End If

    'Determine the amount of screen we have to play with; this is the whole area,
    'minus a strip at the bottom for the back button...if there is one
    intHeight = windowHeight - (2 * CIntX(TouchscreenShared.BUTTON_STANDARD_HEIGHT)) - (3 * CIntX(BUTTON_SPACING))
%>

<html>
<head>
<title>Drug Administration</title>
<script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
<script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>
<script type="text/javascript" language="javascript">
//--------------------------------------------------------------------------------------------------------------
function PatientSearch(){

//Show the onscreen keyboard
    document.frames['fraKeyboard'].ShowKeyboard('Patient Search:  Enter a name or patient identifier');
}

//--------------------------------------------------------------------------------------------------------------
function ScreenKeyboard_EnterText(strText){
//Fires when the user has entered something using the onscreen keyboard.
	if (strText != ''){

		var strUrl = document.URL;
		strUrl = strUrl.substring(0, strUrl.indexOf('?'));
		strUrl +='?SessionID=<%= sessionId %>'
				  + '&' + DA_PATIENT_SEARCH + '=' + strText;
	    void TouchNavigate(strUrl);
	}
}

//--------------------------------------------------------------------------------------------------------------
function ShowList(){

//Fires when the "back to list" button is clicked; Cancels the 
//search, and shows the original list.

	var strUrl = document.URL;
	strUrl = strUrl.substring(0, strUrl.indexOf('?'));
	strUrl +='?SessionID=<%= sessionId %>'
			 + '&CancelSearch=1';

    void TouchNavigate(strUrl);
}

//--------------------------------------------------------------------------------------------------------------
function PatientSelect(objSelected) {

//Fires when a patient button is clicked.
    var strUrl = 'AdministrationEpisodeList.aspx'
        +'?SessionID=<%= sessionId %>'
            + '&' + DA_ENTITYID + '=' + objSelected.getAttribute('entityid');
    void TouchNavigate(strUrl);
}

//--------------------------------------------------------------------------------------------------------------
function PickList() {
//Fires when the "Drug Pick List" button is clicked.
    var strUrl = 'AdministrationDrugPickList.aspx'
        +'?SessionID=<%= sessionId %>';
    void TouchNavigate(strUrl);
}
//--------------------------------------------------------------------------------------------------------------
</script>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
</head>
<body class="Touchscreen PatientList" onload="document.body.style.cursor = 'default';<%= strOnLoad %>">
	
<table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
	<tr>
		<td class="Toolbar">	
			<table cellpadding="0" cellspacing="0">
				<tr>
<%
    If routineName <> "" Then 
%>

						<td style="padding-left:<%= BUTTON_SPACING %>">					
<%
        TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/List.gif", "Clear Search (Back To List)", "ShowList()", (searchString <> ""))
        Response.Write("</td>" & vbCr)
%>

						</td>
<%
    End IF
%>
					<td style="padding-left:<%= BUTTON_SPACING %>">
<%
    'Script the search button
    TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/ButtonSearch.gif", "Search for a patient", "PatientSearch()", true)
%>

					</td>
					
<%
    'Show the Pick List button if we're running with a patient list and record doses is turned on
    ' F0063047 ST updated to use new setting
    ' 19960 ST 04Jan12 Commented out as functionality has been removed elsewhere so not needed here.
    'If (RoutineName <> "") And Not blnSearchDone And strRecordDoses.ToLower() <> "none" Then                                                        '20May08 AE  Check the Record Doses setting and only show the pick list button if it is set to 1
%>

<!--					<td style="padding-left:<%= BUTTON_SPACING %>">-->
<%
    'TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/Picklist.gif", "Drug Pick List", "PickList()", True)
%>

<!--					</td>-->
<%
    'End IF
%>

				</tr>
			</table>
		</td>
	</tr>

<%
    'Script the list O' patients, if there is one.
    If strPatientXml <> "" Then 
%>
			<tr>
				<td class="Prompt">Select a PATIENT by pressing the screen.</td>
			</tr>
			<tr>			
				<td style="vertical-align: top;">
				<%
				    ScriptButtonPage(sessionId, TYPE_PATIENT, strPatientXml, intHeight, windowWidth)
                %>
                </td>
			</tr>
<%
    Else
%>
			<tr>
				<td align="center" class="Prompt" style="height:100%">
<%
        If Not blnSearchDone Then 
            Response.Write("Select a patient to begin")
        Else
            Response.Write("No Patients found matching """ & searchString & """ ")
        End IF
%>
				</td>
			</tr>
<%
    End IF
%>
</table>
<iframe id="fraKeyboard" frameborder="1" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/keyboard.htm"></iframe>
</body>
</html>
