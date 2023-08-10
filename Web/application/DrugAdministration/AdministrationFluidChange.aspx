<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationFluidChange.aspx
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
    Dim maxInfusionChangeTimeMinutes As Integer 
    Dim strEndDate As String 
    Dim strStartDate As String 
    Dim strArbTextId As String = String.Empty
    Dim diff As Integer 
    Dim strDate As String 
    Dim strTime As String 
    Dim strCompDateEnd As Object 
    Dim strCompDateStart As Object 
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
        strMode = "GetEndDate"
    End IF
    strTheDate = Request.QueryString("TheDate")
    strInfusionAction = Request.QueryString("InfusionAction")
    If strInfusionAction <> "" Then
        SessionAttributeSet(sessionId, "InfusionAction", strInfusionAction)
    End IF
    entityId = StateGet(sessionId, "Entity")
    adminDateTime = strTheDate
    If adminDateTime = "" Then 
        'Default to now
        dtAdminDate = Now()
    Else
        dtAdminDate = TDate2DateTime(adminDateTime)
    End IF
    Select Case strMode
        Case "SaveEndDate"
            SessionAttributeSet(sessionId, "FCEndDate", strTheDate)
            Response.Redirect("administrationfluidchange.aspx?SessionID=" & sessionId & "&Mode=GetStartDate" & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate"))
        Case "SaveStartDate"
            SessionAttributeSet(sessionId, "FCStartDate", strTheDate)
            Response.Redirect("administrationfluidchange.aspx?SessionID=" & sessionId & "&Mode=TimeDifference" & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate"))
        Case "GetEndDate"
            dateLastAdmin = SessionAttribute(sessionId, "DateLastAdmin")
            strUserPrompt = "Please indicate the time at which the last fluid supply RAN OUT."
            strConfirmMethod = "GotEndDate()"
        Case "GetStartDate"
            dateLastAdmin = SessionAttribute(sessionId, "FCEndDate")
            strUserPrompt = "Please indicate the time at which the new infusion was STARTED."
            strConfirmMethod = "GotStartDate()"
        Case "TimeDifference"
            'go reason picker or confirmation page
            strEndDate = SessionAttribute(sessionId, "FCEndDate")
            strStartDate = SessionAttribute(sessionId, "FCStartDate")
            'compare date/times, remove T
            strDate = Mid(strEndDate, 1, InStr(strEndDate, "T") - 1)
            strTime = Mid(strEndDate, InStr(strEndDate, "T") + 1) & ":00"
            strCompDateEnd = strDate & " " & strTime
            strDate = Mid(strStartDate, 1, InStr(strStartDate, "T") - 1)
            strTime = Mid(strStartDate, InStr(strStartDate, "T") + 1) & ":00"
            strCompDateStart = strDate & " " & strTime
            diff = DateDiff("n", Convert.ToDateTime(strCompDateEnd), Convert.ToDateTime(strCompDateStart))
            maxInfusionChangeTimeMinutes = CInt(SettingGet(sessionId, "OCS", "DrugAdministration", "MaxInfusionChangeTimeMinutes", "60"))
            '20Feb07 AE  Use new shared procedure to read setting
            If diff > maxInfusionChangeTimeMinutes Then
                'reason picker
                Response.Redirect("ArbTextPicker.aspx?" & "SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate") & "&" & DA_DESTINATION_URL & "=administrationfluidchange.aspx" & "&" & DA_REFERING_URL & "=administrationfluidchange.aspx" & "&" & DA_ARBTEXTTYPE & "=" & ARBTEXTTYPE_FLUID_CHANGE_ADMIN_REASON & "&" & DA_PROMPT & "=" & TXT_ENTER_INFUSIONDATEDISCREPENCY)
            Else
                Response.Redirect("administrationyes.aspx?SessionID=" & sessionId & "&Date=" & strStartDate & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate"))
            End If
        Case "ReasonPicked"
            'come back from reason picker, off to administrationyes
            strStartDate = SessionAttribute(sessionId, "FCStartDate")
            Response.Redirect("administrationyes.aspx?SessionID=" & sessionId & "&Date=" & strStartDate & "&" & DA_ARBTEXTID & "=" & strArbTextId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate"))
    End Select
%>

<html>
<head>
<title>Enter Administration Time</title>
<script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/Datelibs.js"></script>
<script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>
<script type="text/javascript" language="javascript">
    var m_objTD; 								//Used to persist a TD object reference whilst the keyboard is shown

    //----------------------------------------------------------------------------------------------
    function Navigate(strPage) {
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
    //display the reason picker
    function ShowReasonPicker(strStartDate) {
        var strArgs = "?SessionID=<%= sessionId %>";
        var strReturn = window.showModalDialog('AdministrationReasonPicker.aspx' + strArgs, '', 'help:off ; status:off ; scroll:off; dialogheight=200px; dialogwidth=600px;');
        if (strReturn == 'logoutFromActivityTimeout') {
            strReturn = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }

        //Build the URL and go there!
        var strUrl = 'AdministrationYes.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&' + DA_ADMINDATE + '=' + strStartDate;
        void TouchNavigate(strUrl);
    }
    //----------------------------------------------------------------------------------------------
    //post end date back with SaveEndDate mode
    function GotEndDate() {
        //Build the Tdate string from our date and time buttons.
        var strDate = btnDate.getAttribute('date') + 'T' + btnTime.getAttribute('time');

        //Build the URL and go there!
        var strUrl = 'AdministrationFluidChange.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&Mode=SaveEndDate'
                + '&TheDate=' + strDate
                    + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';
        void TouchNavigate(strUrl);
    }
    //----------------------------------------------------------------------------------------------
    //
    function GotStartDate() {
        //Build the Tdate string from our date and time buttons.
        var strDate = btnDate.getAttribute('date') + 'T' + btnTime.getAttribute('time');

        //Build the URL and go there!
        var strUrl = 'AdministrationFluidChange.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&Mode=SaveStartDate'
                + '&TheDate=' + strDate
                    + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';
        void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    function Confirm() {
        //Fires when the confirm button is pressed

        //Build the Tdate string from our date and time buttons.
        var strDate = btnDate.getAttribute('date') + 'T' + btnTime.getAttribute('time');

        //Build the URL and go there!
        var strUrl = 'AdministrationYes.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&' + DA_ADMINDATE + '=' + strDate
                + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';
        void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    function SetTime(objSrc) {

        //Fires when the user presses the time.  Allow them to enter a new time.

        m_objTD = objSrc;
        document.frames['fraKeyboard'].NoDecimalPoint(true);
        document.frames['fraKeyboard'].ShowNumpad('Enter the time in 24-hour clock format.<br />  For example, enter "1030" for ten-thirty am.', 4, false);
    }

    //----------------------------------------------------------------------------------------------
    function SetDate(objSrc) {

        //Fires when the user presses the date.  Allow them to enter a new date.
        m_objTD = objSrc;
        void document.frames['fraDatePicker'].Show('Enter the Day on which the dose was administered');
    }

    //----------------------------------------------------------------------------------------------
    function ScreenKeyboard_EnterText(strText) {

        //Fires when a time has been entered
        var blnValid = true;
        var dtNow = new Date();
        var dtEntered;
        var strPromptHtml = '';
        var strDay = '';

        if (strText != '') {
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

            if (blnValid) {
                //Check that the time is not in the future
                if (btnDate.getAttribute('disableprompt') == 'false' && FutureTime(btnDate.getAttribute('date'), HH + ':' + MM)) {
                    //Date is more than 5 minutes in the future
                    strPromptHtml = '<h1>Invalid Time!</h1><p>Administration Time cannot be recorded in the future!</p>';
                    blnValid = false;
                }
                if (blnValid && btnDate.getAttribute('disableprompt') == 'false' && BeforeLastAdmin(btnDate.getAttribute('date'), HH + ':' + MM)) {
                    var strLastAdmin = new String(DateLastAdmin.value);
                    var dtLastAdmin = new Date(strLastAdmin.substr(0, 4), Number(strLastAdmin.substr(5, 2)) - 1, strLastAdmin.substr(8, 2), strLastAdmin.substr(11, 2), strLastAdmin.substr(14, 2), strLastAdmin.substr(17, 2));
                    strPromptHtml = '<h1>Invalid Time!</h1><p>Last recorded administration was ' + dtLastAdmin.toLocaleString() + '. The administration time cannot be prior to this!</p>';
                    blnValid = false;
                }
                if (blnValid) {
                    var strTime = HH.toString() + ':' + MM.toString();
                    m_objTD.innerText = strTime;
                    m_objTD.setAttribute('time', strTime);
                }
            }
            else {
                //Syntactically or numerically invalid time
                strPromptHtml = '<h1>Invalid Time!</h1><p>Times must be entered in 24-hour format, including zeros where necessary.</p>'
    		    + '<p>For example, for nine-thirty am, enter 0930.  For two minutes past four pm, enter 1602.</p>';
            }

            if (!blnValid) {
                void document.frames['fraConfirm'].Show(strPromptHtml, 'cancel');
            }
        }
    }

    //----------------------------------------------------------------------------------------------
    function DatePicker_DateChosen(strCCYYDDMM, strDescription) {

        //A new date has been selected.

        if (btnDate.getAttribute('disableprompt') == 'false' && FutureTime(strCCYYDDMM, btnTime.getAttribute('time'))) {
            //Date is more than 5 minutes in the future
            var strPromptHtml = '<h1>Invalid Time!</h1><p>Administration Time cannot be recorded in the future!</p>';
            void document.frames['fraConfirm'].Show(strPromptHtml, 'cancel');
        }
        else if (btnDate.getAttribute('disableprompt') == 'false' && BeforeLastAdmin(strCCYYDDMM, btnTime.getAttribute('time'))) {
            var strLastAdmin = new String(DateLastAdmin.value);
            var dtLastAdmin = new Date(strLastAdmin.substr(0, 4), Number(strLastAdmin.substr(5, 2)) - 1, strLastAdmin.substr(8, 2), strLastAdmin.substr(11, 2), strLastAdmin.substr(14, 2), strLastAdmin.substr(17, 2));
            strPromptHtml = '<h1>Invalid Time!</h1><p>Last recorded administration was ' + dtLastAdmin.toLocaleString() + '. The administration time cannot be prior to this!</p>';
            void document.frames['fraConfirm'].Show(strPromptHtml, 'cancel');
        }
        else {
            //Date is ok, store it it
            m_objTD.setAttribute('date', strCCYYDDMM);
            m_objTD.innerText = strDescription;
        }
    }

    //----------------------------------------------------------------------------------------------
    function Confirmed(strChosen) {
        //Fires when the confirm dialog has been shown
        //Not currently used.
    }

    //----------------------------------------------------------------------------------------------
    function FutureTime(strDay, strTime) {
        //Returns true if the time specified is more than 5 minutes in the future.

        //strDay: Date in 'yyyy-mm-dd' format	
        //strTime: Time in 'hh:mm' format
        var checkUrl = './AdministrationCheckTime.aspx?date=' + strDay + '&time=' + strTime;
        var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
        objHTTPRequest.open("GET", checkUrl, false);
        objHTTPRequest.send();

        var response = objHTTPRequest.responseText;
        if (response == "future" || response != (strDay + strTime)) {
            return true;
        }

        return false;
    }

    function BeforeLastAdmin(strDay, strTime) {
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

<table style="width:100%;" cellpadding="0" cellspacing="0">	
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
		<td colspan="2" class="Prompt"><%= strUserPrompt %></td>
	</tr>
	
	<tr>
		<td colspan="2" align='center'>
<%
    ScriptButton_Date(sessionId,dtAdminDate, true)
%>

		</td>
	</tr>

	<tr>
		<td colspan="2" class="Prompt">Click [Confirm] to confirm this time, or [Cancel] to return to the previous page</td>
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
