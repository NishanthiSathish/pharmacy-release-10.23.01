<%@ Page language="vb" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Xml" %>
<html>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationYes.aspx
    '
    'Touchscreen Admin screen.  Confirmation screen for administered doses, where the
    'summary of the administered dose is shown before saving.  The user can go
    'from this screen back to any step to modify anything if required.
    '
    '
    'Modification History:
    '02Jun05 AE  Written
    '20Mar07 AE  Various improvements for SC-07-0219; hide dose recording in continuous infusion mode,
    'corrected text in date box.
    '11May11 Rams F0117196 - error in immediate admin
    '19Jan12 Rams 23388 - Meds override time needs to allow earlier than due time
    '----------------------------------------------------------------------------------------------------------------
    Dim sessionId As Integer
    Dim episodeId As Integer
    Dim entityId As Integer
    Dim adminDateTime As String
    Dim dtAdminDate As Date
    Dim dtStopDate As Date
    Dim strAdminDate As String = ""
	Dim strDoseRecording As String
    Dim blnFlowRateRecording As Boolean
    Dim blnContinuous As Boolean
    Dim strDateTitle As String = ""
    Dim blnShowBatchNumbers As Boolean
    Dim strPrompt As String = String.Empty
    Dim strTimeEditFunction As String = ""
    Dim requestId As Integer
    Dim sOriginUrl As String
    Dim sNextUrl As String
    Dim nodeLockDetails As XmlNode = Nothing
    Dim bLockFailed As Boolean = False
    Dim bLongDurationBased As Boolean
    Dim strMinRate As String
    Dim strMaxRate As String
    Dim prescriptionRequestId As Integer
    
    blnShowBatchNumbers = True
    
    'Read our various variables from state.
    sessionId = CIntX(Request.QueryString("SessionID"))
    
    ' Make sure episode id is selected
    episodeId = CIntX(StateGet(sessionId, "Episode"))
    If episodeId = 0 Then
        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If
    
    'We may have to store the Admin Date if we've come from the date picker
    If Request.QueryString(DA_ADMINDATE) <> "" Then
        Generic.SessionAttributeSet(sessionId, DA_ADMINDATE, Request.QueryString(DA_ADMINDATE).ToString)
    End If
     
    
    entityId = CIntX(StateGet(sessionId, "Entity"))
    requestId = CIntX(SessionAttribute(sessionId, DA_REQUESTID))
    sOriginUrl = SessionAttribute(sessionId, "OriginURL")
    prescriptionRequestId = CIntX(SessionAttribute(sessionId, CStr(DA_PRESCRIPTIONID)))

    ' Prevent self-referall from here
    If (sOriginUrl = "AdministrationYes.aspx") Then
        sNextUrl = SessionAttribute(sessionId, "PreviousOriginURL")
        If (sNextUrl <> "") Then
            sOriginUrl = sNextUrl
            SessionAttributeSet(sessionId, "OriginURL", sNextUrl)
        End If
    End If

	strDoseRecording = SessionAttribute(sessionId, "DoseRecording")
    blnContinuous = (SessionAttribute(sessionId, "Continuous") = "1")
    bLongDurationBased = (SessionAttribute(sessionId, "LongDurationBased") = "1")

    strMinRate = SessionAttribute(sessionId, DA_RATE_MIN)
    strMaxRate = SessionAttribute(sessionId, DA_RATE_MAX)
    '
    If blnContinuous And Not String.IsNullOrEmpty(strMinRate) And Not String.IsNullOrEmpty(strMaxRate) Then
        blnFlowRateRecording = True
    End If
    
    ' Check that the lock is still in place (by attempting to get a lock again)
    Dim objRequestLock As OCSRTL10.RequestLock = New OCSRTL10.RequestLock()
    ' Task 32282 - LockRequest will throw an error is request does not exist. COuld happen when prescription is changed
    Dim sLockDetails As String
    Try
        sLockDetails = objRequestLock.LockRequest(sessionId, requestId, False)
    Catch ex As Exception
        sLockDetails = ex.Message
    End Try

    ' Task 32282 - Attempt to lock on prescription also
    Dim sPrescriptionLockDetails As String
    Try
        sPrescriptionLockDetails = objRequestLock.LockRequest(sessionId, prescriptionRequestId, False)
    Catch ex As Exception
        sPrescriptionLockDetails = ex.Message
    End Try
    
    If (sLockDetails <> "" Or sPrescriptionLockDetails <> "") Then
        ' Lock failed
        bLockFailed = True

        ' Get info on person who as locked the data
        Dim domLockDetails As XmlDocument = New XmlDocument()
        domLockDetails.TryLoadXml(sLockDetails)
        nodeLockDetails = domLockDetails.SelectSingleNode("*")
    ElseIf Not blnContinuous And Not bLongDurationBased Then
        'Build the Administration Date summary text
        
        adminDateTime = SessionAttribute(sessionId, CStr(DA_ADMINDATE))
        dtAdminDate = TDate2DateTime(adminDateTime)
        strAdminDate = DateToFriendlyText(dtAdminDate).ToString() & " at " & Date2HHmm(dtAdminDate)
        strDateTitle = "Time of administration (press to change)"
        If SessionAttribute(sessionId, "SupervisedAdmin") = "1" Then
            strPrompt = "This dose will be recorded as having been SELF-ADMINISTERED under supervision"
        Else
            strPrompt = "This dose will be recorded as having been ADMINISTERED"
        End If
        strTimeEditFunction = "EditTime()"
    Else
        'Continuous infusions; date may indicate various things depending on which mode we're in
        Select Case LCase(SessionAttribute(sessionId, "InfusionAction"))
            Case "fluidchange"
                dtAdminDate = TDate2DateTime(SessionAttribute(sessionId, "FCStartDate"))
                dtStopDate = TDate2DateTime(SessionAttribute(sessionId, "FCEndDate"))
                strAdminDate = "Stopped at " & Date2HHmm(dtStopDate) & "<br />" & "Re-started at " & Date2HHmm(dtAdminDate)
                strDateTitle = "Fluid Change Times (press to change)"
                strPrompt = "This will be recorded as a FLUID CHANGE as shown below:"
                strTimeEditFunction = "EditTime_FluidChange()"
            Case "ended"
                blnShowBatchNumbers = False
                strDateTitle = "Infusion END time (press to change)"
                strTimeEditFunction = "EditTime_InfusionEnd()"
            
                If SessionAttribute(sessionId, CStr(DA_ADMINDATE)).ToLower() = "null" Then
                    strAdminDate = "Not Specified"
                    strPrompt = "The Infusion will be recorded as having ENDED"
                Else
                    dtAdminDate = TDate2DateTime(SessionAttribute(sessionId, CStr(DA_ADMINDATE)))
                    strAdminDate = DateToFriendlyText(dtAdminDate).ToString() & " at " & Date2HHmm(dtAdminDate)
                    strPrompt = "The Infusion END TIME will be recorded as follows:"
                End If
            Case "started"
                dtAdminDate = TDate2DateTime(SessionAttribute(sessionId, CStr(DA_ADMINDATE)))
                strAdminDate = DateToFriendlyText(dtAdminDate).ToString() & " at " & Date2HHmm(dtAdminDate)
                strDateTitle = "Infusion START time (press to change)"
                strPrompt = "The Infusion START TIME will be recorded as follows:"
                strTimeEditFunction = "EditTime_InfusionStart()"
            Case "flowratechange"
                dtAdminDate = TDate2DateTime(SessionAttribute(sessionId, CStr(DA_ADMINDATE)))
                strAdminDate = "Flow Rate changed at " & Date2HHmm(dtAdminDate)
                strDateTitle = "Flow Rate Change Times (press to change)"
                strPrompt = "This will be recorded as a FLOW RATE CHANGE as shown below:"
                strTimeEditFunction = "EditTime_FlowRateChange()"
        End Select
    End If
	'Sort out our available height
%>


<script type="text/javascript" language="javascript" src='../sharedscripts/Touchscreen/Touchscreenshared.js'></script>
<script type="text/javascript" language="javascript" src='scripts/DrugAdministrationConstants.js'></script>
<script type="text/javascript" language="javascript" src='../sharedscripts/icw.js'></script>
<script type="text/javascript" language="javascript">
//----------------------------------------------------------------------------------------------
function Cancel()
{
	//Fires when the "cancel" button is pressed
	var strUrl = 'AdministrationPrescriptionDetail.aspx'
		+ '?SessionID=<%= sessionId %>'
		+ '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
		+ '&OverrideAdmin=<%=IIf(String.Compare(SessionAttribute(sessionId, "OverrideAdmin"), "True", True) = 0, "1", "0")%>';
	void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function Save(){
//Fires when the "save" button is pressed
	var strUrl = 'AdministrationSave.aspx'
    	+ '?SessionID=<%= sessionId %>' 
        	+ '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';

	if (QueryString(DA_ADMINISTERED) != '')
	    strUrl += '&' + DA_ADMINISTERED + '=' + QueryString(DA_ADMINISTERED);
	else
	    strUrl += '&' + DA_ADMINISTERED + '=1';
	if (QueryString(DA_PARTIAL) != '')
	    strUrl += '&' + DA_PARTIAL + '=' + QueryString(DA_PARTIAL);
	else
	    strUrl += '&' + DA_PARTIAL + '=0';
        
	void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function Back() {
//Fires when the "back" button is pressed
    var strUrl = '<%= sOriginUrl %>'
        + '?SessionID=<%= sessionId %>' 
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';
    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function EditNote() {
//Fires when the Note button is pressed.
    var strUrl = 'AdministrationNote.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&' + DA_DESTINATION_URL + '=AdministrationYes.aspx'
                    + '&' + DA_REFERING_URL + '=AdministrationYes.aspx';

    if (QueryString(DA_ADMINISTERED) != '')
    	strUrl += '&' + DA_ADMINISTERED + '=' + QueryString(DA_ADMINISTERED);
    if (QueryString(DA_PARTIAL) != '')
    	strUrl += '&' + DA_PARTIAL + '=' + QueryString(DA_PARTIAL);

    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function EditBatchnumbers() {
//Fires when the Time button is pressed.
    var strUrl = 'AdministrationBatchNumbers.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&' + DA_DESTINATION_URL + '=AdministrationYes.aspx'
                    + '&' + DA_REFERING_URL + '=AdministrationYes.aspx';
    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------

function EditDose() {
//Fires when the Dose button is pressed
    var strUrl = 'AdministrationDrugEntry.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';
    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------

function EditFlowRate() {
    //Fires when the Dose button is pressed
    var strUrl = 'AdministrationFlowRateEntry.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                    + '&' + DA_REFERING_URL + '=AdministrationYes.aspx';
    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function EditTime() {
//Fires when the Time button is pressed.
    var strUrl = 'AdministrationDateEntry.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';
    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function EditTime_InfusionStart() {
    var strUrl = "AdministrationDateEntry.aspx"
        + "?SessionID=<%= sessionId %>"
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&DateEntryPrompt=Please indicate the time at which the infusion was STARTED. (Press to change)';
    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function EditTime_InfusionEnd()
{
    var strUrl = 'AdministrationDateEntry.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&DateEntryPrompt=When was the Infusion ended? (Press to Change)';
    
    // copy ADMINISTERED and PARTIAL states (for partial infusions)
    if (QueryString(DA_ADMINISTERED) != '')
        strUrl += '&' + DA_ADMINISTERED + '=' + QueryString(DA_ADMINISTERED);
    if (QueryString(DA_PARTIAL) != '')
        strUrl += '&' + DA_PARTIAL + '=' + QueryString(DA_PARTIAL);
		  
	void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function EditTime_FluidChange() {
    var strUrl = 'AdministrationFluidChange.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';
    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function EditTime_FlowRateChange() {
    var strUrl = 'AdministrationFlowRateChange.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';
    void TouchNavigate(strUrl);
}

window.onload = function () { document.body.style.cursor = 'default'; }
</script>

<head>
<title>Drug Administration</title>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
</head>
<body class="Touchscreen AdminDetails">
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
</table>

<% If Not(bLockFailed) Then %>
    <table cellpadding="0" cellspacing="<%= BUTTON_SPACING %>" align='center' style='width:<%= 2 * CIntX((BANNER_WIDTH_ADMINREQUEST)) %>px' >	
        <%
            ScriptBanner_BrokenDoseRules(sessionId, True)
        %>
        <tr>
    	    <td colspan="2" class="Prompt" align="center"><%= strPrompt %></td>
        </tr>
	    <tr>
		    <td align='center'>
    <%
        ScriptButton_Picker(strDateTitle, DIR_GENERIC_IMAGES & "Tick.gif", strAdminDate, "Happy", strTimeEditFunction)
    %>
		    </td>
		        <td align="center">
		    <%
		    ScriptBanner_Note(sessionId, "EditNote()",requestId)
		    %>
		    </td>
	    </tr>
    <%
        If blnShowBatchNumbers Then 
    %>

		    <tr>
			    <td align='center'>
    <%
            ScriptBanner_BatchNumbers(sessionId, "EditBatchnumbers()")
    %>

			    </td>
			        <%
		'If blnDoseRecording Then
		If strDoseRecording = "1" Then
    %>
     
			    <td>
    <%
            ScriptBanner_DoseGiven(sessionId)
    %>

			    </td>
    <% 
        Else If blnFlowRateRecording Then
    %>
                <td>
    <%
            ScriptBanner_FlowRate(sessionId)
    %>
                </td>
    <%        
        End IF
    %>

		    </tr>

            <tr>
                <td colspan="2" class="Prompt" align="center">Click [Save] to record this information, or [Cancel] if you need to change anything</td>
            </tr>
  
<%
    End IF
%>
	    <tr>
		    <td align="left">
    <%
        TouchscreenShared.NavButton("../../images/touchscreen/Cross.gif", "Cancel", "Cancel()", true)
    %>
    		
		    </td>
		    <td align="right">
    <%
        TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "Save", "Save()", true)
    %>

		    </td>
	    </tr>
    </table>
    
<% Else 
    ' Failed to get lock on dose
    If nodeLockDetails IsNot Nothing
    ' Failed to get lock on dose because its already locked by another user 
%> 

    <table cellpadding="0" cellspacing="<%= BUTTON_SPACING %>" align='center' style='width:100%'>	
        <tr><td class="Prompt" align="center" style="padding-top: 20px">
            <img src='../../images/User/lock closed.gif' alt="Lock Failed" />
            This Dose is currently Locked by another User!
        </td></tr>    
        <tr><td class='PromptSmallText' style="padding-top: 5px">
            <div>Locked By: <%=If(nodeLockDetails Is Nothing, "Unknown", nodeLockDetails.Attributes("UserFullName").Value)%></div>
            <div>On Terminal: <%=If(nodeLockDetails Is Nothing, "Unknown", nodeLockDetails.Attributes("TerminalName").Value)%></div>
            <div>At <%=If(nodeLockDetails Is Nothing, "Unknown", nodeLockDetails.Attributes("CreationDate").Value)%></div>
        </td></tr>
        <tr><td class="BackButtonText" align="center" style="padding-top: 20px">
<%          TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/DrugChart.gif", "Go Back", "Back()", true)  %>
        </td></tr>
    </table>
    
<% 
    Else
    ' Failed to get lock on dose. Probably because the dose has been changed 
    %>   
    <table cellpadding="0" cellspacing="<%= BUTTON_SPACING %>" align='center' style='width:100%'>	
        <tr>
            <td class="Prompt" align="center" style="padding-top: 20px">
                <img src='../../images/User/lock closed.gif' alt="Lock Failed" />
                Failed to get lock for the selected dose. <br /> The prescription has most likely been changed by another user.
            </td>
        </tr>    
        <tr>
            <td class="BackButtonText" align="center" style="padding-top: 20px">
            <% TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/DrugChart.gif", "Go Back", "Back()", true)  %>
            </td>
        </tr>
    </table>
    
    <%
    End If
End If %>

</body>
</html>
