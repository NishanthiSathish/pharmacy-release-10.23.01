<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<html>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    '
    '
    'Second Check Entry page.
    '
    'Useage:
    'Call with the following QS Parameters:
    'Referer:			Page which called this one
    'Dest:				Page which we will navigate to when the OK button is pressed
    '
    'Modification History:
    '23Jan07    ST      Written
    '19May2010  Rams    F0078434 - Do not Create AdminRequest for PRN's when Override Administration
    '
    '----------------------------------------------------------------------------------------------------------------
    
    Dim sessionId As Integer = Integer.Parse(Request.QueryString("SessionID"))
    Dim episodeId As Integer = StateGet(sessionId, "Episode")

    If episodeId = 0 Then


        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If

    Dim entityId As Integer = StateGet(sessionId, "Entity")
    Dim sMode As String = Request.QueryString(DA_MODE)
    Dim windowHeight As String = SessionAttribute(sessionId, DA_HEIGHT)
    Dim windowWidth As String = SessionAttribute(sessionId, DA_WIDTH)
    Dim destinationUrl As String = Request.QueryString(DA_DESTINATION_URL)
    Dim CancelURL As String = Request.QueryString(DA_REFERING_URL)
    Dim requestId As Integer = Integer.Parse(SessionAttribute(sessionId, DA_REQUESTID))
    Dim optionSelected As String = SessionAttribute(sessionId, "OptionSelected")
    Dim prescriptionId As Integer = IIf(optionSelected = "1", Integer.Parse(Generic.SessionAttribute(sessionId, DA_PRESCRIPTIONID)), 0)
    Dim sUsername As String = String.Empty
    Dim sPassword As String = String.Empty
    Dim strOnLoad As String = String.Empty
    Dim intHeight As String = (windowHeight - (3 * (TouchscreenShared.BUTTON_STANDARD_HEIGHT + BUTTON_SPACING))).ToString()
    Dim overrideAdmin As Byte = IIf(Generic.SessionAttribute(sessionId, "OverrideAdmin") = True, 1, 0)
    Dim secondCheckerName As String = GetLastSecondChecker(sessionId)

    If sMode = "" Then
        sMode = "init"
    End If

    If Request.Form.GetValues("txtUserName") IsNot Nothing Then
        sUsername = Request.Form("txtUserName")
    End If

    If Request.Form.GetValues("txtPassword") IsNot Nothing Then
        sPassword = Request.Form("txtPassword")
    End If

    ' Iterate through each mode
    Select Case sMode
        Case "init"
            strOnLoad = "ShowKeyboard ( false, 'Enter Username', '" & secondCheckerName & "' )"
            sMode = "enterusername"

        Case "enterusername"
            strOnLoad = "ShowKeyboard ( true, 'Enter password for  " & sUsername & "' )"
            sMode = "enterpassword"

        Case "enterpassword"
            Select Case ValidateAndStoreSecondCheck(sessionId, requestId, prescriptionId, sUsername, sPassword)
                Case "ok"
                    strOnLoad = "Confirm()"
                    sMode = "end"
                Case "invaliduser"
                    strOnLoad = "Error ( 'Invalid username or password entered' )"
                    sMode = "init"
                Case "secondcheckself"
                    strOnLoad = "Error ( 'You cannot act as a second check for yourself!' )"
                    sMode = "init"
                Case "secondchecknotallowed"
                    strOnLoad = "Error ( 'You are not allowed to second check this user' )"
                    sMode = "init"
            End Select
    End Select

%>

<script type="text/javascript" language="javascript" src='scripts/DrugAdministrationConstants.js'></script>
<script type="text/javascript" language="javascript" src='../sharedscripts/Touchscreen/Touchscreenshared.js'></script>
<script type="text/javascript" language="javascript" src='../sharedscripts/icwfunctions.js'></script>

<script language="javascript">
    //------------------------------------------------------------------------------------------------------------------
    function ShowKeyboard(bShowPassword, sMsg, sUserName) {
        void document.frames['fraKeyboard'].PasswordMode(bShowPassword);
        void document.frames['fraKeyboard'].ShowFull(sMsg);

        //F0075735 07Jun10 ST Check for a saved second checker name and pass through to keyboard if it exists
        if (sUserName != undefined && sUserName != "") {
            void document.frames['fraKeyboard'].SetDisplay(sUserName);
        }
    }

    //------------------------------------------------------------------------------------------------------------------
    function ScreenKeyboard_EnterText(strText) {
        // called when username or password is entered 

        // if the cancel is pressed then cancel second check 
        if (strText == '') {
            Cancel();
            return;
        }

        // store the username, or password, in the form
        switch (document.body.getAttribute(DA_MODE)) {
            case 'enterusername':
                document.all['txtUserName'].value = strText;
                break;

            case 'enterpassword':
                document.all['txtPassword'].value = strText;
                break;
        }

        // post back username and password
        frmSecondCheck.submit();
    }

    //------------------------------------------------------------------------------------------------------------------
    function Confirm() {
        // Username and password has been entered correctly

        var strURL = '<%= destinationUrl %>'
			    + '?SessionID=<%= sessionId %>'
    			+ '&dssresult=<%= Request.QueryString("dssresult") %>'
                + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
        	    + '&OverrideAdmin=<%=overrideAdmin%>';
        void TouchNavigate(strURL);
    }

    //------------------------------------------------------------------------------------------------------------------
    function Cancel() {
        // User has opted to cancel so return to previoud screen    

        //    var strURL = document.URL
        //    
        //    // does not seem to have the correct default folder, so create full url
        //    strURL = strURL.split('AdministrationSecondCheck.aspx')[ 0 ] + '<%= CancelURL %>' + '?SessionID=<%= sessionId %>';
        //F0068155 JMei 16Nov2009 when iis set to “use uri” instead of “use cookie”, don't navigate to a whole URL, remove path.
        var strURL = '../../DrugAdministration/<%= CancelURL %>'
                + '?SessionID=<%= sessionId %>'
                + '&dssresult=<%= Request.QueryString("dssresult") %>'
                + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&OverrideAdmin=<%=overrideAdmin%>';
        void TouchNavigate(strURL);
    }

    //------------------------------------------------------------------------------------------------------------------
    function Error(sMsg) {
        // invalid username\password so display error
        document.frames['fraConfirm'].Show(sMsg, "ok");
    }

    //------------------------------------------------------------------------------------------------------------------
    function Confirmed(strReturn) {
        // called when user oks the error message (so redisplay this form with latest mode)

        var sURL = QuerystringReplace(document.URL, "Mode", "<%= sMode %>");
        void TouchNavigate(sURL + '&OverrideAdmin=<%=overrideAdmin%>');
    }
</script>

<head>
<title>Second Check</title>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />

</head>
<body id="body" class="Touchscreen" SessionID="<%= sessionId %>" DestinationURL="<%= destinationUrl %>" CancelURL="<%= CancelURL %>" Mode="<%= sMode %>" onload="document.body.style.cursor = 'default';<%= strOnLoad %>">
    
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

<table style="width:100%">
    <tr>
		<td class="Prompt">
		<%
	        DrugAdminEpisodeBannerByID(sessionId, episodeId)
        %>
		</td>
	</tr>
	<tr>
		<td class="Prompt">Enter your username and password.</td>
	</tr>
</table>


<div style="display:none;">
	<form action="<%= ICW.ICWURL("AdministrationSecondCheck.aspx?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate") & "&dssresult=" & Request.QueryString("dssresult") & "&" & DA_DESTINATION_URL & "=" & destinationUrl & "&" & DA_REFERING_URL + "=" & CancelURL & "&" & DA_MODE + "=" & sMode) %>" method="POST" id="frmSecondCheck" name="frmSecondCheck">
		<input type="text" id="txtUserName" name="txtUserName" value="<%= sUsername %>" onselectstart="event.returnValue=true;event.cancelBubble=true;">
		<input type="password" id="txtPassword" name="txtPassword" value="" onselectstart="event.returnValue=true;event.cancelBubble=true;">
	</form>
</div>

<iframe id="fraKeyboard" frameborder="1" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/keyboard.htm"></iframe>
<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>
<!--<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:600px;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>-->
</body>
</html>

