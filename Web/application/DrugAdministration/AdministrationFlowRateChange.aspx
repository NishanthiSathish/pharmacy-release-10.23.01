<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<html>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationFlowRateChange.aspx
    '
    'strMode:
    'GetEndDate (of previous infusion)
    'SaveEndDate
    'GetStartDate (of new infusion)
    'SaveStartDate
    'TimeDifference
    'Modification History:
    '20Mar07 AE  Corrected text as per spec
    '----------------------------------------------------------------------------------------------------------------
    Dim sessionId As Integer
    Dim entityId As Integer
    Dim episodeId As Integer
    Dim adminDateTime As String 
    Dim dtAdminDate As Date 
    Dim strInfusionAction As String 
    Dim strMode As String 
    Dim strTheDate As String 
    Dim strUserPrompt As String = String.Empty
    Dim strConfirmMethod As String = String.Empty
    Dim dateLastAdmin As String = String.Empty

    'Read the appropriate state variables
    sessionId = CIntX(Request.QueryString("SessionID"))
    
    ' Make sure episode id is selected
    episodeId = CIntX(StateGet(sessionId, "Episode"))
    If episodeId = 0 Then
        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If
    
    strMode = Request.QueryString("Mode")
    If strMode = "" Then 
        strMode = "GetChangeDate"
    End If
    
    strTheDate = Request.QueryString("TheDate")
    strInfusionAction = Request.QueryString("InfusionAction")
    If strInfusionAction <> "" Then
        SessionAttributeSet(sessionId, "InfusionAction", strInfusionAction)
    End If
    
    entityId = CIntX(StateGet(sessionId, "Entity"))
    
    adminDateTime = strTheDate
    If adminDateTime = "" Then 
        'Default to now
        dtAdminDate = Now()
    Else
        dtAdminDate = TDate2DateTime(adminDateTime)
    End If
    
    Select Case strMode
        Case "SaveChangeDate"
            SessionAttributeSet(sessionId, CStr(DA_ADMINDATE), strTheDate)
            Response.Redirect("administrationflowrateentry.aspx?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate"))
        Case "GetChangeDate"
            dateLastAdmin = SessionAttribute(sessionId, "FCEndDate")
            strUserPrompt = "Please indicate the time at which the new rate was STARTED."
            strConfirmMethod = "GotChangeDate()"
    End Select
%>

<head>
<title>Enter Flow Rate Change</title>
<script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/Datelibs.js"></script>
<script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>
<script type="text/javascript" language="javascript">
    var m_objTD; 								//Used to persist a TD object reference whilst the keyboard is shown

    //----------------------------------------------------------------------------------------------
    function Navigate(strPage)
    {
    }

    //----------------------------------------------------------------------------------------------
    function Cancel()
    {
    	//Fires when the cancel button is pressed
    	var strUrl = 'AdministrationPrescriptionDetail.aspx'
            + '?SessionID=<%= sessionId %>'
			+ '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			+ '&OverrideAdmin=<%=IIf(String.Compare(SessionAttribute(sessionId, "OverrideAdmin"), "True", True) = 0, "1", "0")%>';
    	void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    //post end date back with SaveEndDate mode
    function GotChangeDate()
    {
    	//Build the Tdate string from our date and time buttons.
    	var strDate = btnDate.getAttribute('date') + 'T' + btnTime.getAttribute('time');

    	//Build the URL and go there!
    	var strUrl = 'AdministrationFlowRateChange.aspx'
    		+ '?SessionID=<%= sessionId %>'
        	+ '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
            + '&Mode=SaveChangeDate'
            + '&TheDate=' + strDate;
    	void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------

    function Confirm()
    {
    	//Fires when the confirm button is pressed

    	//Build the Tdate string from our date and time buttons.
    	var strDate = btnDate.getAttribute('date') + 'T' + btnTime.getAttribute('time');

    	//Build the URL and go there!
    	var strUrl = 'AdministrationYes.aspx'
    		+ '?SessionID=<%= sessionId %>'
        	+ '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
            + '&' + DA_ADMINDATE + '=' + strDate;
    	void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    function SetTime(objSrc)
    {
    	//Fires when the user presses the time.  Allow them to enter a new time.

    	m_objTD = objSrc;
    	document.frames['fraKeyboard'].NoDecimalPoint(true);
    	document.frames['fraKeyboard'].ShowNumpad('Enter the time in 24-hour clock format.<br />  For example, enter "1030" for ten-thirty am.', 4, false);
    }

    //----------------------------------------------------------------------------------------------
    function SetDate(objSrc)
    {
    	//Fires when the user presses the date.  Allow them to enter a new date.
    	m_objTD = objSrc;
    	void document.frames['fraDatePicker'].Show('Enter the Day on which the rate was changed');
    }

    //----------------------------------------------------------------------------------------------
    function ScreenKeyboard_EnterText(strText)
    {
    	//Fires when a time has been entered
    	var blnValid = true;
    	var dtNow = new Date();
    	var dtEntered;
    	var strPromptHtml = '';
    	var strDay = '';

    	if (strText != '')
    	{
    		//Check that the time is valid
    		if (strText.length == 4)
    		{
    			var HH = strText.substring(0, 2);
    			var MM = strText.substring(2, 4);

    			if (Number(HH) > 23 || Number(HH) < 0) blnValid = false;
    			if (Number(MM) > 59 || Number(MM) < 0) blnValid = false;
    		}
    		else
    		{
    			blnValid = false;
    		}

    		if (blnValid)
    		{
    			//Check that the time is not in the future
    		    if (btnDate.getAttribute('disableprompt') == 'false' && FutureTime(btnDate.getAttribute('date'), HH + ':' + MM))
    			{
    				//Date is more than 5 minutes in the future
    				strPromptHtml = '<h1>Invalid Time!</h1><p>Flow Rate Change Time cannot be recorded in the future!</p>';
    				blnValid = false;
    			}
                if (blnValid && btnDate.getAttribute('disableprompt') == 'false' && BeforeLastAdmin(btnDate.getAttribute('date'), HH + ':' + MM))
    			{
    				var strLastAdmin = new String(DateLastAdmin.value);
    				var dtLastAdmin = new Date(strLastAdmin.substr(0, 4), Number(strLastAdmin.substr(5, 2)) - 1, strLastAdmin.substr(8, 2), strLastAdmin.substr(11, 2), strLastAdmin.substr(14, 2), strLastAdmin.substr(17, 2));
    				strPromptHtml = '<h1>Invalid Time!</h1><p>Last recorded administration was ' + dtLastAdmin.toLocaleString() + '. The Flow Rate Change Time cannot be prior to this!</p>';
    				blnValid = false;
    			}
    			if (blnValid)
    			{
    				var strTime = HH.toString() + ':' + MM.toString();
    				m_objTD.innerText = strTime;
    				m_objTD.setAttribute('time', strTime);
    			}
    		}
    		else
    		{
    			//Syntactically or numerically invalid time
    			strPromptHtml = '<h1>Invalid Time!</h1><p>Times must be entered in 24-hour format, including zeros where necessary.</p>'
    		    + '<p>For example, for nine-thirty am, enter 0930.  For two minutes past four pm, enter 1602.</p>';
    		}

    		if (!blnValid)
    		{
    			void document.frames['fraConfirm'].Show(strPromptHtml, 'cancel');
    		}
    	}
    }

    //----------------------------------------------------------------------------------------------
    function DatePicker_DateChosen(strCCYYDDMM, strDescription)
    {
    	//A new date has been selected.
    	var strPromptHtml;
    	if (btnTime.getAttribute('disableprompt') == 'false' && FutureTime(strCCYYDDMM, btnTime.getAttribute('time')))
    	{
    		//Date is more than 5 minutes in the future
    		strPromptHtml = '<h1>Invalid Time!</h1><p>Administration Time cannot be recorded in the future!</p>';
    		void document.frames['fraConfirm'].Show(strPromptHtml, 'cancel');
    	}
        else if (btnTime.getAttribute('disableprompt') == 'false' && BeforeLastAdmin(strCCYYDDMM, btnTime.getAttribute('time')))
    	{
    		var strLastAdmin = new String(DateLastAdmin.value);
    		var dtLastAdmin = new Date(strLastAdmin.substr(0, 4), Number(strLastAdmin.substr(5, 2)) - 1, strLastAdmin.substr(8, 2), strLastAdmin.substr(11, 2), strLastAdmin.substr(14, 2), strLastAdmin.substr(17, 2));
    		strPromptHtml = '<h1>Invalid Time!</h1><p>Last recorded administration was ' + dtLastAdmin.toLocaleString() + '. The administration time cannot be prior to this!</p>';
    		void document.frames['fraConfirm'].Show(strPromptHtml, 'cancel');
    	}
    	else
    	{
    		//Date is ok, store it it
    		m_objTD.setAttribute('date', strCCYYDDMM);
    		m_objTD.innerText = strDescription;
    	}
    }

    //----------------------------------------------------------------------------------------------
    function Confirmed(strChosen)
    {
    	//Fires when the confirm dialog has been shown
    	//Not currently used.
    }

    //----------------------------------------------------------------------------------------------
    function FutureTime(strDay, strTime)
    {
    	//Returns true if the time specified is more than 5 minutes in the future.

    	//strDay: Date in 'yyyy-mm-dd' format	
    	//strTime: Time in 'hh:mm' format
    	var checkUrl = './AdministrationCheckTime.aspx?date=' + strDay + '&time=' + strTime;
    	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    	objHTTPRequest.open("GET", checkUrl, false);
    	objHTTPRequest.send();

    	var response = objHTTPRequest.responseText;
    	if (response == "future" || response != (strDay + strTime))
    	{
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

    	return ((dtThisAdmin.getTime() - dtLastAdmin.getTime()) < 0);
    }

    window.onload = function () { document.body.style.cursor = 'default'; }
</script>

<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
</head>
<body class="Touchscreen Callendar">
    <input type="hidden" id="DateLastAdmin" name="DateLastAdmin" value="<%= dateLastAdmin %>" />
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

<table cellpadding="0" cellspacing="0" style="width:100%" align="center">	
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
		<td colspan="2" class="Prompt">
<%= strUserPrompt %>
		</td>
	</tr>
	
	<tr>
		<td colspan="2" align='center'>
<%
    ScriptButton_Date(sessionId,dtAdminDate, true)
%>

		</td>
	</tr>

	<tr>
		<td colspan="2" class="Prompt">
		Click [Confirm] to confirm this time, or [Cancel] to return to the previous page
		</td>
	</tr>
	
	<tr>
		<td align="left">
<%
    TouchscreenShared.NavButton("../../images/touchscreen/Cross.gif", "Cancel", "Cancel()", true)
%>
		
		</td>
		<td align="right">
<%
    TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "Confirm", strConfirmMethod, true)
%>

		</td>
	</tr>


</table>

<iframe id="fraKeyboard" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/keyboard.htm"></iframe>
<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>
<iframe id="fraDatePicker" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="AdministrationDatePicker.aspx?SessionID=<%=sessionID %>"></iframe>

</body>
</html>
