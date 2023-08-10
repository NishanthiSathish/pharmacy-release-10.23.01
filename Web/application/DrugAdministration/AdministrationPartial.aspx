<%@ Page language="vb" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationPartial.aspx
    '
    'Touchscreen Admin screen.  Confirmation screen for recording partial-administration, shown
    'immediately before saving.  The user can go back and modify anything from this screen.
    '
    '
    '
    'Modification History:
    '05Jun05 AE  Written
    '11May11 Rams F0117196 - error in immediate admin
    '
    '----------------------------------------------------------------------------------------------------------------

    Dim sessionId As Integer
    Dim episodeId As Integer
    Dim entityId As Integer 
    Dim arbTextId As String 
    Dim arbitraryTextRead As OCSRTL10.ArbitraryTextRead
    Dim domText As XmlDocument
    Dim xmlText As XmlNode
    Dim strTextXml As String 
    Dim strReasonCode As String = String.Empty
    Dim strReasonClass As String = String.Empty
    Dim strImage As String = String.Empty
    Dim requestId As Integer 
    Dim sOriginUrl as String
    Dim sNextUrl as String
    Dim lockDetails As XmlNode = Nothing
    Dim bLockFailed As Boolean = False
    Dim prescriptionRequestId As Integer
    
    sessionId = CIntX(Request.QueryString("SessionID"))
    
    ' Make sure episode id is selected
    episodeId = CIntX(StateGet(sessionId, "Episode"))
    If episodeId = 0 Then
        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If
    
    'Read variables from our state table
    entityId = CIntX(StateGet(sessionId, "Entity"))
    requestId = CIntX(SessionAttribute(sessionId, DA_REQUESTID))
    sOriginUrl = SessionAttribute(sessionId, "OriginURL")
    prescriptionRequestId = CIntX(SessionAttribute(sessionId, CStr(DA_PRESCRIPTIONID)))

    ' Hack to prevent self-referall from here
    If ( sOriginUrl = "AdministrationPartial.aspx" ) Then
        sNextUrl = SessionAttribute(sessionId, "PreviousOriginURL" )
        if ( sNextUrl <> "" ) Then
            sOriginUrl = sNextUrl
            SessionAttributeSet(sessionId, "OriginURL", sNextUrl)     
        End If
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
    
    ' Task 32282 - Attempt to lock the prescription
    Dim prescriptionLockDetails As String
    Try
        prescriptionLockDetails = objRequestLock.LockRequest(sessionId, prescriptionRequestId, False)
    Catch ex As Exception
        prescriptionLockDetails = ex.Message
    End Try
    
    If (sLockDetails <> "" Or prescriptionLockDetails <> "") Then
        ' Lock failed
        bLockFailed = True

        ' Get info on person who as locked the data
        Dim domLockDetails As XmlDocument = New XmlDocument()
        domLockDetails.TryLoadXml(sLockDetails)
        lockDetails = domLockDetails.SelectSingleNode("*")
    Else
        'If we've come back from the reason code picker, we'll have an ArbTextID
        'passed on the querystring, which we'll now save in state
        arbTextId = RetrieveAndStore(sessionId, CStr(DA_ARBTEXTID))
        If arbTextId <> "" Then
            arbitraryTextRead = New OCSRTL10.ArbitraryTextRead()
            strTextXml = arbitraryTextRead.GetTextByID(sessionId, arbTextId)
            arbitraryTextRead = Nothing
            domText = New XmlDocument()
            domText.TryLoadXml(strTextXml)
            xmlText = domText.SelectSingleNode("ArbText")
            strReasonCode = xmlText.Attributes("Description").Value & " - " & xmlText.Attributes("Detail").Value
            strReasonClass = "Happy"
            strImage = "tick.gif"
        Else
            'No reason selected
            strReasonCode = "(Press Here)"
            strReasonClass = "Sad"
            strImage = "info.gif"
        End If
    End If
%>

<html>
<head>
<title>Drug Administration</title>
<script type="text/javascript" language="javascript" src='../sharedscripts/Touchscreen/Touchscreenshared.js'></script>
<script type="text/javascript" language="javascript" src='scripts/DrugAdministrationConstants.js'></script>
<script type="text/javascript" language="javascript">
    //----------------------------------------------------------------------------------------------
	function Cancel()
	{
		//Fires when the "cancel" button is pressed
		var strUrl = 'AdministrationPrescriptionDetail.aspx'
			+ '?SessionID=<%= sessionId %>'
			+ '&dssresult=<%= Request.QueryString("dssresult") %>'
			+ '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			+ '&OverrideAdmin=<%=IIf(String.Compare(SessionAttribute(sessionId, "OverrideAdmin"), "True", True) = 0, "1", "0")%>'
			+ '&' + DA_MODE + '=select';
		void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    function Save() {
        //Fires when the "save" button is pressed
        var strUrl = 'AdministrationSave.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&dssresult=<%= Request.QueryString("dssresult") %>'
                + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                    + '&' + DA_ADMINISTERED + '=0'
                        + '&' + DA_PARTIAL + '=1';
        void TouchNavigate(strUrl);
    }
    //----------------------------------------------------------------------------------------------

    function Back() {
        //Fires when the "back" button is pressed
        var strUrl = '<%= sOriginUrl %>'
        + '?SessionID=<%= sessionId %>'
            + '&dssresult=<%= Request.QueryString("dssresult") %>'
                + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';
        void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    function EnterReason() {
        //Fires when the "pick reason" button is pressed
        var strPage = document.URL;
        strPage = strPage.substring(0, strPage.indexOf('?'));
        var strUrl = 'ArbtextPicker.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&dssresult=<%= Request.QueryString("dssresult") %>'
                + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                    + '&' + DA_DESTINATION_URL + '=AdministrationNo.aspx'
                        + '&' + DA_REFERING_URL + '=AdministrationNo.aspx'
                            + '&' + DA_ARBTEXTTYPE + '=' + ARBTEXTTYPE_PARTIAL_ADMIN_REASON
                                + '&' + DA_PROMPT + '=' + TXT_ENTER_PARTIAL_ADMIN_REASON;
        void TouchNavigate(strUrl);
    }
    //----------------------------------------------------------------------------------------------
    function EditNote() {
        //Fires when the Note button is pressed.
        var strUrl = 'AdministrationNote.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&dssresult=<%= Request.QueryString("dssresult") %>'
                + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                    + '&' + DA_DESTINATION_URL + '=AdministrationPartial.aspx'
                        + '&' + DA_REFERING_URL + '=AdministrationPartial.aspx';
        void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------

    function EditBatchnumbers() {
        //Fires when the Time button is pressed.
        var strUrl = 'AdministrationBatchNumbers.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&dssresult=<%= Request.QueryString("dssresult") %>'
                + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                    + '&' + DA_DESTINATION_URL + '=AdministrationPartial.aspx'
                        + '&' + DA_REFERING_URL + '=AdministrationPartial.aspx';
        void TouchNavigate(strUrl);
    }
    //----------------------------------------------------------------------------------------------
    window.onload = function () { document.body.style.cursor = 'default'; }
</script>
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


<table style="width:100%;">
    <tr>
		<td class="Prompt">
		<%
	        DrugAdminEpisodeBannerByID(sessionId, episodeId)
        %>
		</td>
	</tr>
</table>

<% If Not(bLockFailed) Then %>
    <table cellpadding="0" cellspacing="<%= BUTTON_SPACING %>" align='center' style='width:<%= (BANNER_WIDTH_ADMINREQUEST) %>px' >	

	    <tr>
		    <td colspan="2" class="Prompt">
		    This dose will be recorded as having been PARTIALLY ADMINISTERED.
		    </td>
	    </tr>
	    <tr>
		    <td align="center">
    <%
        ScriptButton_Picker("Reason why administration was not completed (press to change)", DIR_GENERIC_IMAGES & strImage, strReasonCode, strReasonClass, "EnterReason()")
    %>

		    </td>
		    		        <td align="center">
		    <%
		        ScriptBanner_Note(sessionId, "EditNote()", requestId)
		    %>
		    </td>

	    </tr>
    	
	    <tr>
		    <td align="center">
    <%
        ScriptBanner_BatchNumbers(sessionId, "EditBatchnumbers()")
    %>

		    </td>
		    <td align="center">
    <%
        ScriptBanner_BrokenDoseRules(sessionId, False)
    %>

		    </td>
	    </tr>
    		
	    <tr>
		    <td colspan="2" class="Prompt">
		    Click [Save] to record this information, or [Cancel] to go back without saving
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
        TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "Save", "Save()", true)
    %>

		    </td>
	    </tr>

    </table>
    
<%  Else
        ' Failed to get lock on dose
        If lockDetails IsNot Nothing Then
            ' Failed to get lock on dose because its already locked by another user 
        %> 

    <table cellpadding="0" cellspacing="<%= BUTTON_SPACING %>" align='center' style='width:100%'>	
        <tr><td class="Prompt" align="center" style="padding-top: 20px">
            <img src='../../images/User/lock closed.gif' />
            This Dose is currently Locked by another User!
        </td></tr>    
        <tr><td class='PromptSmallText' style="padding-top: 5px">
            <div>Locked By: <%=lockDetails.Attributes("UserFullName").Value%></div>
            <div>On Terminal: <%=lockDetails.Attributes("TerminalName").Value%></div>
            <div>At <%=lockDetails.Attributes("CreationDate").Value%></div>
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
    
<% End If
End If
%>

</body>
</html>
