<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<html>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationDateEntry.aspx
    '
    'Touchscreen Date Entry for Administration.  This is shown after the user has told is that they've
    'administered a dose, and allows them to enter the date and time at which it was done.
    '
    '
    'Modification History:
    '09Jun05 AE  Written
    '19Jan12 Rams 23388 - Meds override time needs to allow earlier than due time
    '
    '----------------------------------------------------------------------------------------------------------------
    Dim sessionId As Integer
    Dim entityId As Integer
    Dim episodeId As Integer
    Dim adminDateTime As String
    Dim dtAdminDate As Date
    Dim strInfusionAction As String
    Dim strPrompt As String
    Dim bInfusionEndTimeOptional As Boolean
    Dim bSupervisedAdmin As Boolean
    Dim bAllowSkipTimeEntry As Boolean
    Dim bSupervisedDatePicker As Boolean = False
    Dim dateLastAdmin As String
    Dim datePrescriptionStart As String
    Dim EditMode As Boolean = False

    'Read the appropriate state variables
    sessionId = CIntX(Request.QueryString("SessionID"))
    
    ' Make sure episode id is selected
    episodeId = CIntX(StateGet(sessionId, "Episode"))
    If episodeId = 0 Then
        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If

    bSupervisedAdmin = CBoolX(SessionAttribute(sessionId, "SupervisedAdmin"))
    dateLastAdmin = SessionAttribute(sessionId, "DateLastAdmin")
    datePrescriptionStart = SessionAttribute(sessionId, DA_PRESCRIPTION_START_DATE)

    ' Get info
    bInfusionEndTimeOptional = CBool(SettingGet(sessionId, "OCS", "DrugAdministration", "InfusionEndTimeOptional", "0"))
    strInfusionAction = RetrieveAndStore(sessionId, "InfusionAction")
    entityId = StateGet(sessionId, "Entity")
    
    ' Determine if skip button is presnet
    bAllowSkipTimeEntry = bInfusionEndTimeOptional And (strInfusionAction.ToLower() = "ended") And Not (bSupervisedAdmin)
    
    ' Configure prompt!!!!
    strPrompt = Request.QueryString("DateEntryPrompt")
    If strPrompt = "" Then
        If bSupervisedAdmin Then
            strPrompt = "When was this dose supervised?  (Press to change)"
            bSupervisedDatePicker = True
        Else
            strPrompt = "When was this dose administered?  (Press to change)"
        End If
        ' 20May08 CD - Moved inside the condition to avoid adding the skip message again
        If bAllowSkipTimeEntry Then strPrompt += " You may skip this step."
    End If
    
    'Check if we already have an admin date (will be the case if we are returning here
    'from the confirmation screen)
    adminDateTime = SessionAttribute(sessionId, CStr(DA_ADMINDATE))
    If adminDateTime = "" Or adminDateTime.ToLower() = "null" Then
        'Default to now
        dtAdminDate = Now()
    Else
        EditMode = True
        dtAdminDate = TDate2DateTime(adminDateTime)
    End If

    RetrieveAndStore(sessionId, CStr(DA_ARBTEXTID_EARLY))
%>

<script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/Datelibs.js"></script>
<script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/icw.js"></script>

<script type="text/javascript" language="javascript">
var m_objTD;									//Used to persist a TD object reference whilst the keyboard is shown
var recordAdminForced = false;
var strURL;
var isOverride = '<%=IIf(String.Compare(SessionAttribute(sessionId, "OverrideAdmin"), "True", True) = 0, 1, 0)%>';
var editMode = <%=EditMode.ToString().ToLowerInvariant()%>;

//----------------------------------------------------------------------------------------------
function Navigate(strPage){
}

//----------------------------------------------------------------------------------------------
function Cancel()
{
	//Fires when the cancel button is pressed
	if (editMode)
	{
		strURL = 'AdministrationYes.aspx'
			+ '?SessionID=<%= sessionId %>'
			+ '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'

		if (QueryString(DA_ADMINISTERED) != '')
		{
			strURL += '&' + DA_ADMINISTERED + '=' + QueryString(DA_ADMINISTERED);
		}

		if (QueryString(DA_PARTIAL) != '')
		{
			strURL += '&' + DA_PARTIAL + '=' + QueryString(DA_PARTIAL);
		}
	}
	else
	{
		strURL = 'AdministrationPrescriptionDetail.aspx'
			+ '?SessionID=<%= sessionId %>'
			+ '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			+ '&OverrideAdmin=<%=IIf(String.Compare(SessionAttribute(sessionId, "OverrideAdmin"), "True", True) = 0, "1", "0")%>';
	}

	void TouchNavigate(strURL);
}

//----------------------------------------------------------------------------------------------
function Confirm(){
    //Fires when the confirm button is pressed
    /*
    02Feb2010 CD F0075144 Now checks validity of the date and time that has been entered rather
    than checking when they are entered
    */
    
    //Build the Tdate string from our date and time buttons.
    var strDate = btnDate.getAttribute('date') + 'T' + btnTime.getAttribute('time');
    var strURL;

    if (editMode)
    {
        strURL = 'AdministrationYes.aspx';
    }
    else
    {
        strURL = 'AdministrationDrugEntry.aspx';
    }

    strURL = strURL
			  + '?SessionID=<%= SessionID %>'
              + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			  + '&' + DA_ADMINDATE + '=' + strDate;

    if (QueryString(DA_ADMINISTERED) != '')
    {
        strURL += '&' + DA_ADMINISTERED + '=' + QueryString(DA_ADMINISTERED);
    }

    if (QueryString(DA_PARTIAL) != '')
    {
        strURL += '&' + DA_PARTIAL + '=' + QueryString(DA_PARTIAL);
    }

    if (recordAdminForced )
    {
        //Build the URL and go there!
        strURL = '../../DrugAdministration/' + strURL
    }
    else if (!IsChosenDateTimeValid())
    {
        strURL = '';
    }

    if (strURL != '')
    {
        void TouchNavigate(strURL);
    }
}

//----------------------------------------------------------------------------------------------
function SkipTimeEntry(){
//Fires when the skip time entry button is pressed

	//Build the URL and go there!
	strURL  = 'AdministrationDrugEntry.aspx'
			  + '?SessionID=<%= sessionId %>'
              + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			  + '&' + DA_ADMINDATE + '=null';
			  
    // copy ADMINISTERED and PARTIAL states (for partial infusions)
	if (QueryString(DA_ADMINISTERED) != '')
	    strURL += '&' + DA_ADMINISTERED + '=' + QueryString(DA_ADMINISTERED);
	if (QueryString(DA_PARTIAL) != '')
	    strURL += '&' + DA_PARTIAL + '=' + QueryString(DA_PARTIAL);
            			  
	void TouchNavigate(strURL);
}

//----------------------------------------------------------------------------------------------
function SetTime(objSrc){

//Fires when the user presses the time.  Allow them to enter a new time.

	m_objTD = objSrc;
	document.frames['fraKeyboard'].NoDecimalPoint(true);
	document.frames['fraKeyboard'].ShowNumpad('Enter the time in 24-hour clock format.<br />  For example, enter "1030" for ten-thirty am.', 4, false);
}

//----------------------------------------------------------------------------------------------
function SetDate(objSrc){

//Fires when the user presses the date.  Allow them to enter a new date.
	m_objTD = objSrc;
	void document.frames['fraDatePicker'].Show('Enter the Day on which the dose was <%If bSupervisedDatePicker Then Response.Write("supervised") Else Response.Write("administered") %>');
}

//----------------------------------------------------------------------------------------------
function ScreenKeyboard_EnterText(strText){

//Fires when a time has been entered
var blnValid = true;
var dtNow = new Date();
var dtEntered;
var strPromptHtml = '';
var strDay = '';

	if (strText != ''){
		//Check that the time is valid
		if (strText.length == 4) {
			var HH = strText.substring(0, 2);
			var MM = strText.substring(2, 4);
		
			if (Number(HH) > 23 || Number(HH) < 0) blnValid = false;
			if (Number(MM) > 59 || Number(MM) < 0) blnValid = false;
		}
		else {
			blnValid = false;
		}

		/*
	        02Feb2010 CD F0075144 Removed check from the time entry handler as causes problems when backdating administrations
	        Checking of date/time is now done in the confirm button click handler
		*/
		if (blnValid){
/*		//Check that the time is not in the future
			if (FutureTime(btnDate.getAttribute('date'), HH + ':' + MM)){
			//Date is more than 5 minutes in the future
				strPromptHTML = '<h1>Invalid Time!</h1><p>Administration time cannot be recorded in the future!</p>'
				blnValid = false;
			}
			if (blnValid && BeforeLastAdmin(btnDate.getAttribute('date'), HH + ':' + MM))
			{
				var strLastAdmin = new String(DateLastAdmin.value);
				var dtLastAdmin = new Date(strLastAdmin.substr(0, 4), Number(strLastAdmin.substr(5, 2)) - 1, strLastAdmin.substr(8, 2), strLastAdmin.substr(11, 2), strLastAdmin.substr(14, 2), strLastAdmin.substr(17, 2));
				strPromptHTML = '<h1>Invalid Time!</h1><p>Last recorded administration was ' + dtLastAdmin.toLocaleString() + '. The administration time cannot be prior to this!</p>'
				blnValid = false;
			}
			if (blnValid){*/
			var strTime = HH.toString() + ':' + MM.toString();
		    m_objTD.innerText = strTime;
			m_objTD.setAttribute('time', strTime);
//			}
		}
		else{
		//Syntactically or numerically invalid time
		    strPromptHtml = '<h1>Invalid Time!</h1><p>Times must be entered in 24-hour format, including zeros where necessary.</p>'
    		    + '<p>For example, for nine-thirty am, enter 0930.  For two minutes past four pm, enter 1602.</p>';		
		}
			
		if (!blnValid){
			void document.frames['fraConfirm'].Show(strPromptHtml, 'cancel');		
		}
	}
}

function IsChosenDateTimeValid() {
    var blnReturn = false;

    var strCCYYDDMM = btnDate.getAttribute('date');
    var strPromptHtml;
    if (btnTime.getAttribute('disableprompt') == 'false' && FutureTime(strCCYYDDMM, btnTime.getAttribute('time'))) {
        //Date is more than 5 minutes in the future
        strPromptHtml = '<h1>Invalid Time!</h1><p>Administration time cannot be recorded in the future!</p>';
        void document.frames['fraConfirm'].Show(strPromptHtml, 'cancel');
    }
    else if(btnTime.getAttribute('disableprompt') == 'false' && BeforeStartDate(strCCYYDDMM, btnTime.getAttribute('time'))) {
    	var strPrescriptionStart = new String(DatePrescriptionStart.value);
	    var dtPrescriptionStart = new Date(strPrescriptionStart.substr(0, 4), Number(strPrescriptionStart.substr(5, 2)) - 1, strPrescriptionStart.substr(8, 2), strPrescriptionStart.substr(11, 2), strPrescriptionStart.substr(14, 2), strPrescriptionStart.substr(17, 2));
        var dtThisAdmin = new Date(strCCYYDDMM.substr(0, 4), Number(strCCYYDDMM.substr(5, 2)) - 1, strCCYYDDMM.substr(8, 2), btnTime.getAttribute('time').substr(0, 2), btnTime.getAttribute('time').substr(3, 2));
        strPromptHtml = '<h1>Warning!</h1><p>The entered administration time, ' + dtThisAdmin.toLocaleString() + ', is prior to </p>' +
                                             '<p>the start date of the prescription which is ' + dtPrescriptionStart.toLocaleString() + '.</p>' +
                                             '<p>Do you wish to continue?</p>';
            void document.frames['fraConfirm'].Show(strPromptHtml, 'yesno');
    } else if (btnTime.getAttribute('disableprompt') == 'false' && BeforeLastAdmin(strCCYYDDMM, btnTime.getAttribute('time'))) {
        var strLastAdmin = new String(DateLastAdmin.value);
        var dtLastAdmin = new Date(strLastAdmin.substr(0, 4), Number(strLastAdmin.substr(5, 2)) - 1, strLastAdmin.substr(8, 2), strLastAdmin.substr(11, 2), strLastAdmin.substr(14, 2), strLastAdmin.substr(17, 2));
        var dtThisAdmin = new Date(strCCYYDDMM.substr(0, 4), Number(strCCYYDDMM.substr(5, 2)) - 1, strCCYYDDMM.substr(8, 2), btnTime.getAttribute('time').substr(0, 2), btnTime.getAttribute('time').substr(3, 2));
        
        if(isOverride != '1') {
            strPromptHtml = '<h1>Invalid Time!</h1><p>Last recorded administration was ' + dtLastAdmin.toLocaleString() + '. The administration time cannot be prior to this!</p>';
            void document.frames['fraConfirm'].Show(strPromptHtml, 'cancel');
        } else {
            strPromptHtml = '<h1>Warning!</h1><p>The entered administration time, ' + dtThisAdmin.toLocaleString() + ', is prior to </p>' +
                                             '<p>the last recorded administration which was ' + dtLastAdmin.toLocaleString() + '.</p>' +
                                             '<p>Do you wish to continue?</p>';
            void document.frames['fraConfirm'].Show(strPromptHtml, 'yesno');
        }
    }
    else {
        //Date is ok, store it it
        blnReturn = true;
    }    

    return blnReturn;
}

//----------------------------------------------------------------------------------------------
function DatePicker_DateChosen(strCCYYDDMM, strDescription){

    /*
    02Feb2010 CD F0075144 Removed check from the date entry handler as causes problems when backdating administrations
    Checking of date/time is now done in the confirm button click handler
    */

    //A new date has been selected.
/*	if (FutureTime(strCCYYDDMM, btnTime.getAttribute('time'))){
	//Date is more than 5 minutes in the future
		strPromptHTML = '<h1>Invalid Time!</h1><p>Administration time cannot be recorded in the future!</p>'
		void document.frames['fraConfirm'].Show(strPromptHTML, 'cancel');		
	}
	else if (BeforeLastAdmin(strCCYYDDMM, btnTime.getAttribute('time'))) {
		var strLastAdmin = new String(DateLastAdmin.value);
		var dtLastAdmin = new Date(strLastAdmin.substr(0, 4), Number(strLastAdmin.substr(5, 2)) - 1, strLastAdmin.substr(8, 2), strLastAdmin.substr(11, 2), strLastAdmin.substr(14, 2), strLastAdmin.substr(17, 2));
		strPromptHTML = '<h1>Invalid Time!</h1><p>Last recorded administration was ' + dtLastAdmin.toLocaleString() + '. The administration time cannot be prior to this!</p>'
		void document.frames['fraConfirm'].Show(strPromptHTML, 'cancel');
	}
	else {*/
	//Date is ok, store it it
		m_objTD.setAttribute('date', strCCYYDDMM);
		m_objTD.innerText = strDescription;
//	}
}

//----------------------------------------------------------------------------------------------
function Confirmed(strChosen){
//Fires when the confirm dialog has been shown
    if (strChosen == 'yes') {
        recordAdminForced = true;
        Confirm();
    }
}

//----------------------------------------------------------------------------------------------
function FutureTime(strDay, strTime){
//Returns true if the time specified is more than 5 minutes in the future.
	
//strDay: Date in 'yyyy-mm-dd' format	
//strTime: Time in 'hh:mm' format
    var checkUrl = './AdministrationCheckTime.aspx?date=' + strDay + '&time=' + strTime;
   	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
	objHTTPRequest.open("GET", checkUrl, false);
	objHTTPRequest.send();

    var response = objHTTPRequest.responseText;
    if(response == "future" || response != (strDay + strTime)) {
        return true;
    }

    return false;
}

function BeforeLastAdmin(strDay, strTime)
{
//Returns true if the time specified is prior to the last recorded admin response.
	
//strDay: Date in 'yyyy-mm-dd' format	
//strTime: Time in 'hh:mm' format

	var strLastAdmin = new String(DateLastAdmin.value);
	var dtLastAdmin = new Date(strLastAdmin.substr(0, 4), Number(strLastAdmin.substr(5, 2)) - 1, strLastAdmin.substr(8, 2), strLastAdmin.substr(11, 2), strLastAdmin.substr(14, 2), strLastAdmin.substr(17, 2));
	var dtThisAdmin = new Date(strDay.substr(0, 4), Number(strDay.substr(5, 2)) - 1, strDay.substr(8, 2), strTime.substr(0, 2), strTime.substr(3, 2));
    return ((dtThisAdmin.getTime() - dtLastAdmin.getTime() )  < 0 );
}

function BeforeStartDate(strDay, strTime) {
	var strPrescriptionStart = new String(DatePrescriptionStart.value);
	var dtPrescriptionStart = new Date(strPrescriptionStart.substr(0, 4), Number(strPrescriptionStart.substr(5, 2)) - 1, strPrescriptionStart.substr(8, 2), strPrescriptionStart.substr(11, 2), strPrescriptionStart.substr(14, 2), strPrescriptionStart.substr(17, 2));
	var dtThisAdmin = new Date(strDay.substr(0, 4), Number(strDay.substr(5, 2)) - 1, strDay.substr(8, 2), strTime.substr(0, 2), strTime.substr(3, 2));
    return ((dtThisAdmin.getTime() - dtPrescriptionStart.getTime() )  < 0 );    
}

window.onload = function () { document.body.style.cursor = 'default'; }

</script>

<head>
<title>Enter Administration Time</title>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />

</head>
<body class="Touchscreen Callendar">
    <input type="hidden" id="DateLastAdmin" name="DateLastAdmin" value="<%= dateLastAdmin %>" />
    <input type="hidden" id="DatePrescriptionStart" name="DatePrescriptionStart" value="<%= datePrescriptionStart %>" />

<table width="100%" cellpadding="0" cellspacing="0">        
<%
    'Selected Patient details
    PatientBannerByID(sessionId, entityId, episodeId)
%>
<tr>
    <td colspan="2">
        <table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
	        <tr>
		        <td class="Toolbar" style="padding-right:<%= BUTTON_SPACING %>" align="center">
        <%
		        ScriptBanner_AdminRequestCurrent(sessionId, False, entityId)
        %>
		        </td>
            </tr>
        </table>
	</td>
</tr>
</table>

<table cellpadding="0" cellspacing="0" style="width:100%">	
	<tr>
		<td class="Prompt">
		<%
	        DrugAdminEpisodeBannerByID(sessionId, episodeId)
        %>
		</td>
	</tr>
</table>

<table cellpadding="0" cellspacing="<%= BUTTON_SPACING %>" style="width:<%= BANNER_WIDTH_DATE %>" align='center'>	
	<tr>
		<td colspan="3" class="Prompt">
<%= strPrompt %>
		</td>
	</tr>
	
	<tr>
		<td colspan="3" align='center'>
<% ScriptButton_Date(sessionId,dtAdminDate, true) %>

		</td>
	</tr>

	<tr>
		<td colspan="3" class="Prompt">
		Click [Confirm] to confirm this time, or [Cancel] to return to the previous page		
		<%If bAllowSkipTimeEntry Then %>
		    , or [Skip] to record that the infusion has ended without specifying a time.
		 <% End If %>
		
		</td>
	</tr>
	
	<tr>
		<td>
<%  TouchscreenShared.NavButton("../../images/touchscreen/Cross.gif", "Cancel", "Cancel()", true) %>		
		</td>
		
		<td>
<%  TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "Confirm", "Confirm()", true) %>
		</td>
		
<%	If bAllowSkipTimeEntry Then %>
		<td>
<%  TouchscreenShared.NavButton("../../images/touchscreen/ButtonNext.gif", "Skip Time<br>Entry", "SkipTimeEntry()", true) %>
		</td>
<% End If %>	
	
	</tr>


</table>

<iframe id="fraKeyboard" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/keyboard.htm"></iframe>
<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>
<iframe id="fraDatePicker" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="AdministrationDatePicker.aspx?SessionID=<%=sessionID %>"></iframe>
</body>
</html>
