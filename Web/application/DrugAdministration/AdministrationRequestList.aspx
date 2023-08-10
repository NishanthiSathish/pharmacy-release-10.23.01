<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<%@ Import Namespace="Ascribe.Common.OCSStatusMessage" %>
<%@ Import Namespace="ENTRTL10" %>
<%@ Import Namespace="System.Web" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationRequestList.aspx
    '
    'Touchscreen Admin Request list application.
    '
    '
    'Results are paged onto the screen; if there are too many to fit on the screen, back and next buttons
    'allow the user to page through the results.
    '
    'Modification History:
    '24May05 AE  Written
    '18Feb11 Rams F0041360 - Added changes to Generic Templates
    '
    '----------------------------------------------------------------------------------------------------------------
	Dim sessionId As Integer
    Dim windowHeight As Integer 
    Dim windowWidth As Integer 
    Dim entityId As Integer
    Dim episodeId As Integer
	Dim height As Integer
    Dim strRequestXml As String
    Dim episodeRead As ENTRTL10.EpisodeRead
    Dim allergyStatus As Integer
    Dim allergyRead As New OCSRTL10.AllergyRead
    
    'Read querystring.  Note that parameters from previous pages are persisted to support
    'the "back" functionality.  Unfortunately, they can't all be persisted in the state table.
    sessionId = Integer.Parse(Request.QueryString("SessionID"))
    
    ' Clear existing states
    SessionAttributeSet(sessionId, "Action", "")
    SessionAttributeSet(sessionId, "Continuous", "")
	SessionAttributeSet(sessionId, "DateLastAdmin", "")
	SessionAttributeSet(sessionId, "DoseRecording", "")
    SessionAttributeSet(sessionId, "DrugName", "")
    SessionAttributeSet(sessionId, "FCEndDate", "")
    SessionAttributeSet(sessionId, "FCStartDate", "")
    SessionAttributeSet(sessionId, "InfusionAction", "")
    SessionAttributeSet(sessionId, "IsGenericTemplate", "")
    SessionAttributeSet(sessionId, "LongDurationBased", "")
    SessionAttributeSet(sessionId, "OptionSelected", "")
    SessionAttributeSet(sessionId, "OriginURL", "")
    SessionAttributeSet(sessionId, "OverrideAdmin", "")
    SessionAttributeSet(sessionId, "PreviousOriginURL", "")
    SessionAttributeSet(sessionId, "RequestTypeID", "")
    SessionAttributeSet(sessionId, "SupervisedAdmin", "")
    SessionAttributeSet(sessionId, "UsePOM", "")
    SessionAttributeSet(sessionId, DA_ADMINDATE, "")
    SessionAttributeSet(sessionId, DA_ARBTEXTID, "")
	SessionAttributeSet(sessionId, DA_ARBTEXTID_EARLY, "")
	SessionAttributeSet(sessionId, DA_DOSE, "")
	SessionAttributeSet(sessionId, DA_DOSETO, "")
    SessionAttributeSet(sessionId, DA_FLOW_RATE, "")
    SessionAttributeSet(sessionId, DA_FLOW_RATE_UNIT, "")
    SessionAttributeSet(sessionId, DA_FLOW_RATE_UNIT_TIME, "")
    SessionAttributeSet(sessionId, DA_FLOW_RATE_UNITID, "")
    SessionAttributeSet(sessionId, DA_FLOW_RATE_UNITID_TIME, "")
    SessionAttributeSet(sessionId, DA_INFUSIONDURATION_HIGH, "")
    SessionAttributeSet(sessionId, DA_INFUSIONDURATION_LOW, "")
    SessionAttributeSet(sessionId, DA_NOTE, "")
    SessionAttributeSet(sessionId, DA_NOTE_REQUESTID, "")
    SessionAttributeSet(sessionId, DA_PRESCRIPTIONID, "")
    SessionAttributeSet(sessionId, DA_RATE_MAX, "")
    SessionAttributeSet(sessionId, DA_RATE_MIN, "")
    SessionAttributeSet(sessionId, DA_RATE_UNIT_DESCRIPTION, "")
    SessionAttributeSet(sessionId, DA_REQUESTID, "")
    SessionAttributeSet(sessionId, DA_TOTAL_SELECTED, "")
    SessionAttributeSet(sessionId, DA_UNIT_SELECTED, "")
    SessionAttributeSet(sessionId, DA_UNITID, "")
    SessionAttributeSet(sessionId, DA_UNITNAME, "")
    SessionAttributeSet(sessionId, IA_ADMIN, "")
    
    'Store / retrieve our height/width.  This will be passed on the querystring
    'initially, and read from state thereafter
    
    If Not Request.QueryString("ResizeDesktop") Is Nothing Then
        windowHeight = CIntX(Request.QueryString("Height"))
        windowWidth = CIntX(Request.QueryString("Width"))
    Else
        windowHeight = CIntX(RetrieveAndStore(sessionId, CStr(DA_HEIGHT)))
        windowWidth = CIntX(RetrieveAndStore(sessionId, CStr(DA_WIDTH)))
    End If
    

    ' Get the episodeID; this is passed on the querystring initially, and
    ' read from state thereafter.
    ' If no episode id exists then navigate to the AdministrationEpisodeList.aspx page
    episodeId = CIntX(Request.QueryString(DA_EPISODEID))
    If episodeId <> 0 Then
        StateSet(sessionId, "Episode", episodeId)
    Else
        episodeId = StateGet(sessionId, "Episode")
    End If

    If episodeId = 0 Then
        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If

    ' Get the current entity id using the episode id.
    episodeRead = New EpisodeRead()
    entityId = episodeRead.EntityIDFromEpisode(sessionId, episodeId)
    episodeRead = Nothing
    StateSet(sessionId, "Entity", entityId)
    
    ' If we have come back to this page from Prescription Details screen then need to clear any existing locks
    Dim oRequestLock As OCSRTL10.RequestLock = New OCSRTL10.RequestLock
    oRequestLock.UnlockMyRequestLocks(sessionId)
    
    ' TFS 55665 13Feb13 YB - Delete expired admin requests
    DeleteExpiredAdminRequests(sessionId, entityId)
    
    ' Get a list of admin requests for this patient.
    Dim bGroupOrdersets As Boolean = CBool(SettingGet(sessionId, "OCS", "DrugAdministration", "GroupOrderSets", "1"))
    strRequestXml = AdminRequestList(sessionId, entityId, bGroupOrdersets, 0)

    ' Sort out the height we have to fill with buttons
    height = windowHeight - TouchscreenShared.BUTTON_STANDARD_HEIGHT - (2 * BUTTON_SPACING) - 160
    
    If episodeId > 0 Then
        allergyStatus = allergyRead.FetchAllergyStatus(sessionId, episodeId)
    End If
%>

<html>
<head>
    <title>Drug Administration</title>
    <script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/icwFunctions.js"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/ocs/StatusMessage.js"></script>
    <script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>

    <script type="text/javascript" language="javascript">
        var m_resize;
        var m_objSrc;
        //----------------------------------------------------------------------------------------------
        function BackToEpisodeList() {
            //Fires when the "back" button is pressed
            var strUrl = 'AdministrationEpisodeList.aspx' + '?SessionID=<%= sessionId %>';
            void TouchNavigate(strUrl);
        }

        //----------------------------------------------------------------------------------------------
        function Administer(objSrc)
        {
	        var requestType = objSrc.getAttribute('requesttype');
	        if (requestType == REQUESTTYPE_ORDERSET || requestType == REQUESTTYPE_CYCLEDORDERSET || requestType == REQUESTTYPE_ADMINISTRATIONSESSIONORDERSET)
	        {
		        OrderSetNavigate(objSrc); // Item is an order set so show order set contents screen
	        }
	        else if (objSrc.getAttribute('administered') == '1') {
	        	//09Apr2010  Rams    F0078434 - Overriding existing administration records should not create another prompt (Added PRN)
	        	if (objSrc.getAttribute("infusioninprogress") == 1)
	        	{
	        		if (objSrc.getAttribute('isoptionalorderset') == '1')
	        		{
	        			OptionNavigate(objSrc, false); // Item is an options order set so options order set contents screen
	        		}
	        		else
	        		{
	        			AdministerNavigate(objSrc, false); // Just go straight to the admin screen
	        		}

	        		return;
	        	}

		        // Item has already been administered, show a warning first
		        m_objSrc = objSrc;
		        var strPromptHtml;
		        //09Apr2010  Rams    F0078434 - Overriding existing administration records should not create another prompt (Added PRN)
		        if (objSrc.getAttribute("PRN") == 1)
		        {
			        strPromptHtml = '<h1>WARNING!</h1><p>An administration has already been recorded for this dose!</p>'
				        + '<p>Do you wish to override this administration?</p>';
		        }
		        else
		        {
			        strPromptHtml = '<h1>WARNING!</h1><p>An administration has already been recorded for this dose!</p>'
				        + '<p>Do you wish to override this administration and record a new one?</p>';
			       }

		        void document.frames['fraConfirm'].Show(strPromptHtml, 'yesno');
	        }
	        else if (objSrc.getAttribute('isoptionalorderset') == '1')
	        {
		        OptionNavigate(objSrc, false); // Item is an options order set so options order set contents screen
	        }
	        else
	        {
		        AdministerNavigate(objSrc); // Just go straight to the admin screen
	        }
        }

//----------------------------------------------------------------------------------------------

        function Confirmed(strChosen)
        {
	        //User was warned of a re-administration and has selected yes or no.
	        if (strChosen == 'yes')
	        {
		        if (m_objSrc.getAttribute('isoptionalorderset') == '1')
		        {
			        OptionNavigate(m_objSrc, true); // Item is an options order set so options order set contents screen
		        }
		        else
		        {
			        AdministerNavigate(m_objSrc, true); // Just go straight to the admin screen
		        }
	        }
	        else
	        {
		        m_objSrc = null;
	        }
        }

//----------------------------------------------------------------------------------------------

        function AdministerNavigate(objSrc, blnOverrideAdmin)
        {
	        var strURL = '';
	        if (blnOverrideAdmin && objSrc.getAttribute("infusioninprogress") != 1)
	        {
		        strURL = '../../DrugAdministration/';
	        }

	        strURL = strURL + 'AdministrationDSSCheck.aspx?SessionID=<%= SessionID %>'
		        + '&' + DA_REQUESTID + '=' + objSrc.getAttribute('requestid')
		        + '&Continuous=' + objSrc.getAttribute('continuousinfusion')
		        + '&IsGenericTemplate=' + objSrc.getAttribute('isgenerictemplate');

	        if (blnOverrideAdmin)
	        {
		        strURL = strURL + '&OverrideAdmin=1';
	        }

	        strURL = strURL + '&' + DA_MODE + '=select';
	        void TouchNavigate(strURL);
        }

        function OrderSetNavigate(objSrc)
        {
	        var strURL = 'AdministrationOrdersetContentsList.aspx?SessionID=<%= SessionID %>'
		        + '&EntityID=<%= EntityID %>'
		        + '&RequestID=' + objSrc.getAttribute('requestid');

	        void TouchNavigate(strURL);
        }

        function OptionNavigate(objSrc, blnOverrideAdmin)
        {
	        var strURL = '';
	        if (blnOverrideAdmin && objSrc.getAttribute("infusioninprogress") != 1)
	        {
		        strURL = '../../DrugAdministration/';
	        }

	        strURL = strURL + 'AdministrationOptionsSelection.aspx?SessionID=<%= SessionID %>&PrescriptionID=' + objSrc.getAttribute('prescriptionid') + '&AdminRequestID=' + objSrc.getAttribute('requestid');

	        if (blnOverrideAdmin)
	        {
		        strURL = strURL + '&OverrideAdmin=1';
	        }

	        void TouchNavigate(strURL);
        }

        function CloseDialog()
        {
	        var requestsSection = document.getElementById("RequestsSection");
	        var dialogSection = document.getElementById("DialogSection");
	        requestsSection.style.display = "block";
	        dialogSection.style.display = "none";
        }

        function ResizeAdministrationWindow()
        {
			// onresize events can be sent twice by the browser so if this happens then we need to pick up the second occurance.
	        if (m_resize != null)
		        clearTimeout(m_resize);

	        m_resize = setTimeout(function()
	        {
		        ShowStatusMessage("Please Wait...");
		        var url = 'AdministrationRequestList.aspx?SessionID=<%=sessionId %>&EpisodeID=<%=episodeId %>&ResizeDesktop=1&Height=' + document.body.clientHeight + '&Width=' + document.body.clientWidth;
		        TouchNavigate(url);
	        }, 500);
        }

        function ShowStatusMessage(strMsg)
        {
	        //displays a message in the status panel.  Use blank string to hide the message.

	        var intTop = document.body.offsetHeight / 2;
	        if (document.all['statusPanel'] != undefined)
	        {
		        var intLeft = (document.body.offsetWidth - statusPanel.offsetWidth) / 2;
		        void StatusMessage(strMsg, intTop, intLeft);
	        }
        }

        //----------------------------------------------------------------------------------------------
        window.onload = function () { document.body.style.cursor = 'default'; }

        function CloseWindow() {
            var objWin = window.parent;
            objWin.open('', '_self', '');
            objWin.close();
        }
    </script>
    <link rel='stylesheet' type='text/css' href='../../style/application.css' />
    <link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
    <link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
</head>

<body class="Touchscreen RequestList" onresize="ResizeAdministrationWindow();">
    
<table width="100%" cellpadding="0" cellspacing="0">    
<%
	PatientBannerByID(sessionId, entityId, episodeId)
%>
<tr>
    <td colspan="2">
        <table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
	        <tr>
        	    <td class="Toolbar" style="padding-left:<%= BUTTON_SPACING %>px;">
                <%
        	    'Script the "back to list" button.
        	    TouchscreenShared.NavToolBarButton("../../images/touchscreen/DrugAdministration/List.gif", "Back to Episode List", "BackToEpisodeList()", True)
                %>
    		    </td>
                <%
                    If SessionAttribute(sessionId, CStr(DA_MODALMODE)).ToLower() = "true" Then
                    %><td class="Toolbar" align="right" style="padding-right:<%= BUTTON_SPACING %>px;"><%
                    TouchscreenShared.NavToolBarButton("../../images/touchscreen/DrugAdministration/List.gif", "Close", "CloseWindow();", True)
                    %></td><%
                End If
                %>
            </tr>
        </table>
	</td>
</tr>
</table>
<table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
    <tr>
		<td class="Prompt" height="40px;">
		<%
	        DrugAdminEpisodeBannerByID(sessionId, episodeId)
        %>
		</td>
	</tr>
<%
    'Script the list O' admin requests, if there is one.
    If strRequestXml <> "" Then
%>
    <tr>
        <td valign="top">
            <div id="RequestUnlockedSection">
                <table id="RequestsSection" width="100%">
			        <tr>
				        <td class="Prompt">Select the Dose you wish to administer by pressing the screen.</td>
			        </tr>
			        <tr>
				        <td style="vertical-align: top;">
                            <%
                                ScriptButtonPage(sessionId, TYPE_ADMINREQUEST, strRequestXml, height, windowWidth)
                            %>
                        </td>
			        </tr>
			    </table>
			    <div id="DialogSection">
			        <%
			            ScriptEpisodeErrorDialog(sessionId, entityId, height, windowWidth, strRequestXml)
                    %>
			    </div>
			</div>
			<% If Request("LockRequestFailed") <> Nothing OrElse Request("NoAdminRequest") <> Nothing Then%>
			<table cellpadding="0" cellspacing="<%= BUTTON_SPACING %>" align='center' style='width:100%' id="RequestLockedDialogSection">	
                <tr>
                    <% If Request("LockRequestFailed") <> Nothing Then ' Show "LockRequestFailed" warning if "LockRequestFailed" exists in the querystring  %>
                    <td class="Prompt" align="center" style="padding-top: 20px">
                        <img src='../../images/User/lock closed.gif' alt="Lock Failed" />
                        Failed to get lock for the selected dose. <br /> The prescription has most likely been changed by another user.
                    </td>
                    <%ElseIf Request("NoAdminRequest") <> Nothing Then ' Show "NoAdminRequest" warning if "NoAdminRequest" exists in the querystring  %>
                    <td class="Prompt" align="center" style="padding-top: 20px">
                        The Item to Administer does not exists. <br /> The prescription has most likely been changed by another user.
                    </td>
                    <%End If%>
                </tr>    
                <tr>
                    <td class="BackButtonText" align="center" style="padding-top: 20px">
                    <% TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/DrugChart.gif", "Ok", "HideEntityDialog()", true)  %>
                    </td>
                </tr>
            </table>
			<% End If %>
        </td>
    </tr>		
<%
    Else
%>
			<tr>
				<td align="center" colspan='2' class="Prompt" style="height:100%;">Nothing to be administered for this Episode</td>
			</tr>
<%
    End IF
%>

</table>

<%
    '22Feb06 AE  Added BlockSelect parameter			'21Jan06 AE  Added multiselect parameter
    ScriptStatusPanel()
%>


<script type="text/javascript" language="javascript" >
    // Determine whether or not we need to show the "Entity Locked" warning
    // This warning will be shown if "EntityLockedDialogSection" has been rendered.
    // "EntityLockedDialogSection" will not be rendered if "RequestLocked" was not passed to this page in the querystring
    var requestLockedDialogSection = document.getElementById("RequestLockedDialogSection");
    var requestUnlockedSection = document.getElementById("RequestUnlockedSection");
    if (requestLockedDialogSection != null && requestUnlockedSection != null) {
        requestLockedDialogSection.style.display = "block";
        requestUnlockedSection.style.display = "none";
    }
    else {
        var requestsSection = document.getElementById("RequestsSection");
        var dialogSection = document.getElementById("DialogSection");
        if (requestsSection != null && dialogSection != null) {
            if (dialogSection.innerText != "") {
                requestsSection.style.display = "none";
                dialogSection.style.display = "block";
            }
            else {
                requestsSection.style.display = "block";
                dialogSection.style.display = "none";
            }
        }
    }
    

    function HideEntityDialog() {
        var requestLockedDialogSection = document.getElementById("RequestLockedDialogSection");
        var requestUnlockedSection = document.getElementById("RequestUnlockedSection");
        if (requestLockedDialogSection != null && requestUnlockedSection != null) {
            requestLockedDialogSection.style.display = "none";
            requestUnlockedSection.style.display = "block";
        }
    }
</script>
        
<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>
</body>
</html>
