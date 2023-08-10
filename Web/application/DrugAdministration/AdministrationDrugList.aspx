<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationDrugList.aspx
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
    Dim searchString As String
    Dim windowHeight As Integer
    Dim windowWidth As Integer
    Dim routineRead As ICWRTL10.RoutineRead
    Dim intHeight As Integer
    Dim strPatientXml As String = String.Empty
    Dim strSearch As String
    
    'Read querystring
    sessionId = CIntX(Request.QueryString("SessionID"))
    routineName = Request.QueryString("RoutineName")
    searchString = Request.QueryString("Search")
    windowHeight = CIntX(Request.QueryString("Height"))
    windowWidth = CIntX(Request.QueryString("Width"))
    
    'Or we might have a search to run:
    If searchString <> "" Then 
        'Parse the search string:
        'Searching quick and easy at present, it may well need upgrading in future
        strSearch = Replace(searchString, "%", "")
        'Prevent users entering wildcards
        'First look for "My% Search% String%":
        'eg:
        'user enters "A B Test"	to find "Andreaus Bacchus Tester"
        strSearch = Replace(searchString, " ", "% ")
        strSearch = strSearch & "%"
        strPatientXml = PatientSearch(sessionId, strSearch)
        'If we didn't get anything, try "% My% Search% String%"
        'eg:
        'user enters "A B Test" to find "Mr. Andreaus Bacchus Tester"
        If strPatientXml = "" Then
            strSearch = "% " & strSearch
            strPatientXml = PatientSearch(sessionId, strSearch)
        End If
    End If
    
    'If a routine has been specified, run that and return the list o' patients.
    If strPatientXml = "" And routineName <> "" Then
        'Read the routine
        routineRead = New ICWRTL10.RoutineRead()
        strPatientXml = routineRead.ExecuteByDescription(sessionId, CStr(routineName), "")
        routineRead = Nothing
        If CStr(strPatientXml) <> "" Then
            ValidateRoutine_Patient(routineName, strPatientXml)
        End If
    End If
    'Determine the amount of screen we have to play with; this is the whole area,
    'minus a strip at the bottom for the back button...if there is one
    intHeight = windowHeight - TouchscreenShared.BUTTON_STANDARD_HEIGHT - (3 * CIntX(BUTTON_SPACING))
%>


<html>
<head>
<title>Drug Administration</title>
<script type="text/javascript" language="javascript">
//--------------------------------------------------------------------------------------------------------------
function PatientSearch(){

//Show the onscreen keyboard
	document.frames['fraKeyboard'].Show('Patient Search:  Enter a name or patient identifier');
}

//--------------------------------------------------------------------------------------------------------------
function ScreenKeyboard_EnterText(strText){

//Fires when the user has entered something using the onscreen keyboard.
	if (strText != ''){
		var strUrl = document.URL;
		strUrl = strUrl.substring(0, strUrl.indexOf('?'));
		strUrl +='?SessionID=<%= sessionId %>'
				  + '&RoutineName=<%= routineName %>'
				  + '&Search=' + strText
				  + '&Height=<%= windowHeight %>'
				  + '&Width=<%= windowWidth %>';
	    void TouchNavigate(strUrl);
	}
}

//--------------------------------------------------------------------------------------------------------------
window.onload = function () { document.body.style.cursor = 'default'; }
</script>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
</head>

<body class="Touchscreen PatientList">
<table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
	<tr>
		<td class="Toolbar" style="padding-left:<%= BUTTON_SPACING %>">
<%
    'Script the search button, (and "back to list" button if required).
    'This may be made "turn off and on-able"
    TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/ButtonSearch.gif", "Search for a patient", "PatientSearch()", true)
%>
		</td>
	</tr>
	<tr>
<%
    'Script the list O' patients, if there is one.
    If CStr(strPatientXml) <> "" Then 
%>
				<td valign="top"><%ScriptButtonPage(sessionId, TYPE_PATIENT, strPatientXml, intHeight, windowWidth)%></td>
<%
    Else
%>
				<td align="center" class="Prompt" style="height:100%">Select a patient to begin</td>
<%
    End IF
%>
	</tr>
</table>
<iframe id="fraKeyboard" frameborder="1" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/keyboard.htm"></iframe>
</body>
</html>
