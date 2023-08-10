<%@ Page Language="vb" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<%@ Import Namespace="Ascribe.Xml" %>

<% 
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationOrdersetContentsList.aspx
    '
    'Touchscreen Admin application.
    '
    'Will display all the items in an orderset same manner as AdministrationRequestList.aspx.
    '
    'Results are listed down the screen, on alternativly coloured rows, with line numbers. 
    '
    '----------------------------------------------------------------------------------------------------------------
    Dim dom As XmlDocument = New XmlDocument()

    ' Get query info, saved from the previous pages.    
    Dim sessionId As Integer = CIntX(Request.QueryString("SessionID"))
    Dim entityId As Integer = CIntX(RetrieveAndStore(sessionId, "EntityID"))
    Dim requestId As Integer = CIntX(RetrieveAndStore(sessionId, "RequestID"))
    Dim episodeId As Integer
    Dim bGroupOrdersets As Boolean = CBool(SettingGet(sessionId, "OCS", "DrugAdministration", "GroupOrderSets", "1"))
    
    ' Bug 122642 When trying to administer prescriptions of an orderset gets the error
    Dim strStillRequiredText As String = SettingGet(sessionId, "OCS", "Prescribing", "StillRequiredAdminText", "Still Required")
    Dim strNoLongerRequiredText As String = SettingGet(sessionId, "OCS", "Prescribing", "NoLongerRequiredAdminText", "No Longer Required")
    Dim blnShowRequiredMessage As Boolean = (SettingGet(sessionId, "OCS", "Prescribing", "DiscontinueDecisionOnOutstandingRequests", "false").ToLower() = "true")
    
    ' If we have come back to this page from Prescription Details screen then need to clear any existing locks
    Dim oRequestLock As OCSRTL10.RequestLock = New OCSRTL10.RequestLock
    oRequestLock.UnlockMyRequestLocks(sessionId)
    
    ' Clear existing states
    SessionAttributeSet(sessionId, "OriginURL", "")
    SessionAttributeSet(sessionId, DA_REQUESTID, "")
    
    ' Get height/width.  This will be passed on the querystring initially, and read from state thereafter    
    Dim iWindowHeight As Integer = CIntX(RetrieveAndStore(sessionId, CStr(DA_HEIGHT)))
    Dim iWindowWidth As Integer = CIntX(RetrieveAndStore(sessionId, CStr(DA_WIDTH)))
    
    ' Now calc button height
    Dim iHeight As Integer = iWindowHeight - TouchscreenShared.BUTTON_STANDARD_HEIGHT - (2 * BUTTON_SPACING) - 200
    
    ' Get order set details
    Dim sOrderSetDesc As String = ""
    Dim sOrderSetXml As String = AdminRequestOrderSetByID(sessionId, requestId)
    Try
        dom.LoadXml(sOrderSetXml)
        Dim xmlItems As XmlNodeList = dom.SelectNodes("//" & NodeNameByType(TYPE_ADMINREQUEST).ToString())
        If (xmlItems IsNot Nothing) And (xmlItems.Count > 0) Then
            '17Nov08 ST F0038496
            sOrderSetDesc = XMLReturn(xmlItems(0).Attributes("Description").Value)
        End If
    Catch ex As XmlException
    End Try
    
    ' Get a list of admin requests for this patient.
    Dim sRequestXml As String = AdminRequestList(sessionId, entityId, bGroupOrdersets, requestId)
    
    ' get count of number of admin requests items in the list
    Dim iAdminRequestCount As Integer = 0
    Try
        dom.LoadXml(sRequestXml)
        iAdminRequestCount = dom.SelectNodes("//" & NodeNameByType(TYPE_ADMINREQUEST).ToString()).Count
    Catch ex As XmlException
    End Try
    
    episodeId = CIntX(StateGet(sessionId, "Episode"))
%>

<html>
<head>
    <title>Drug Administration<</title>
    <script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/icwFunctions.js"></script>
    <script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>
    <script type="text/javascript" language="javascript">
        var m_objSrc;

        function Back() {
            //Fires when the "back" button is pressed
            var strUrl = 'AdministrationRequestList.aspx' + '?SessionID=<%= sessionId %>' + '&EntityID=<%= entityId %>';
            void TouchNavigate(strUrl);
        }

        function Administer(objSrc) {
            // Move onto the administration screen
            var requestType = objSrc.getAttribute('requesttype');
            if (requestType == REQUESTTYPE_ORDERSET || requestType == REQUESTTYPE_CYCLEDORDERSET || requestType == REQUESTTYPE_ADMINISTRATIONSESSIONORDERSET) {
                OrderSetNavigate(objSrc);    // Item is an order set so show order set contents screen
            }
            else if (objSrc.getAttribute('administered') == '1') {
                m_objSrc = objSrc;
                //05aug2010  JMei    F0092386 - Overriding existing administration records should not create another prompt (Added PRN)				
                var strPromptHtml;
                if (objSrc.getAttribute("PRN") == 1) {
                    strPromptHtml = '<h1>WARNING!</h1><p>An administration has already been recorded for this dose!</p>'
							    + '<p>Do you wish to override this administration?</p>';
                }
                else {
                    strPromptHtml = '<h1>WARNING!</h1><p>An administration has already been recorded for this dose!</p>'
							    + '<p>Do you wish to override this administration and record a new one?</p>';
                }


                void document.frames['fraConfirm'].Show(strPromptHtml, 'yesno');
            }
            else if (objSrc.getAttribute('isoptionalorderset') == '1') {
                OptionNavigate(objSrc, false);    // Item is an options order set so options order set contents screen
            }
            else
                AdministerNavigate(objSrc);  //Just go straight to the admin screen
        }

        function Confirmed(strChosen) {
            // User was warned of a re-administration and has selected yes or no.
            if (strChosen == 'yes') 
            {
                var strUrl = '../../DrugAdministration/AdministrationDSSCheck.aspx?SessionID=<%= sessionId %>'
                + '&' + DA_REQUESTID + '=' + m_objSrc.getAttribute('requestid')
                    + '&Continuous=' + m_objSrc.getAttribute('continuousinfusion')
                        + '&' + DA_MODE + '=select'
                            + '&OverrideAdmin=1'
                                + '&' + DA_REFERING_URL + '=administrationordersetcontentslist.aspx';
                TouchNavigate(strUrl);

                //AdministerNavigate(m_objSrc);
            }
            else 
            {
                m_objSrc = null;
            }
        }

        function AdministerNavigate(objSrc) {
            //Navigate to the admin screen.
            //Need to get the absolute URL as callbacks from the confirm dialog make IIS think that we're
            //comming from there, rather than here.
            //strURL = document.URL.toLowerCase();
            //strURL = strURL.substring(0, strURL.indexOf('?'));
            //strURL = strURL.split('administrationordersetcontentslist.aspx').join('AdministrationDSSCheck.aspx');

            //Now build the querystring
            //F0068155 JMei 16Nov2009 when iis set to “use uri” instead of “use cookie”, don't navigate to a whole URL, remove path.
            //F0078176 ST   19Feb10 Previous fix didn't fix the problem if navigating from a confirm window
            var strUrl = 'AdministrationDSSCheck.aspx?SessionID=<%= sessionId %>' + '&' + DA_REQUESTID + '=' + objSrc.getAttribute('requestid')
                + '&Continuous=' + objSrc.getAttribute('continuousinfusion')
                    + '&' + DA_MODE + '=select'
                        + '&' + DA_REFERING_URL + '=administrationordersetcontentslist.aspx';
            TouchNavigate(strUrl);
        }

        function OrderSetNavigate(objSrc) {
            //Navigate to the order set navigate screen.

            //Need to get the absolute URL as callbacks from the confirm dialog make IIS think that we're
            //comming from there, rather than here.
            var strUrl = document.URL.toLowerCase();
            strUrl = strUrl.substring(0, strUrl.indexOf('?'));

            //Now build the querystring
            strUrl += '?SessionID=<%= sessionId %>'
			      + '&EntityID=<%= entityId %>'
			      + '&RequestID=' + objSrc.getAttribute('requestid');

            void TouchNavigate(strUrl);
        }

        function OptionNavigate(objSrc, blnOverrideAdmin) {
            var strURL = '';
            if (blnOverrideAdmin) {
                strURL = '../../DrugAdministration/';
            }

            strURL = strURL + 'AdministrationOptionsSelection.aspx?SessionID=<%= sessionId %>&PrescriptionID=' + objSrc.getAttribute('prescriptionid') + '&AdminRequestID=' + objSrc.getAttribute('requestid');

            if (blnOverrideAdmin) {
                strURL = strURL + '&OverrideAdmin=1';
            }

            void TouchNavigate(strURL);
        }

        function Navigate(strPage) {
            //Fires when a button is pressed
            var strURL = strPage;
            if (strURL.toLowerCase().indexOf('?sessionid') < 0) {
                strURL += '?SessionID=<%= SessionID %>';
            }

            void TouchNavigate(strURL);
        }        

        //----------------------------------------------------------------------------------------------
        window.onload = function () { document.body.style.cursor = 'default'; }
    </script>
        
    <link rel='stylesheet' type='text/css' href='../../style/application.css' />
    <link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
    <link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />    
</head>
<body class="Touchscreen RequestList">
<table width="100%" cellpadding="0" cellspacing="0">        
<%
    'Selected Patient details
    PatientBannerByID(sessionId, entityId, episodeId)
%>
<tr>
    <td colspan="2">
        <table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
        	<tr>
		        <td class="Toolbar" style="padding-left:<%= BUTTON_SPACING %>">					
                    <%
                    'Script the "back to list" button.
                    TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/DrugChart.gif", "Back to Drug List", "Navigate('AdministrationRequestList.aspx')", True)
                    %>
        		</td>		
	        </tr>
        </table>
	</td>
</tr>
</table>    
<table width="100%" cellpadding="0" cellspacing="0">        
<%
    'Script the list O' admin requests, if there is one.
    If CStr(sRequestXml) <> "" Then 
%>

			<tr>
			    <td class="Prompt" colspan='2' style="border-bottom-style: solid; border-bottom-width: 4px; border-bottom-color: #c0c0c0;">
			        <div style="font-weight: bold; font-size: 16pt; padding-bottom: 10px;"><%=sOrderSetDesc%></div>
			        <div>Select the Dose you wish to administer by pressing the screen.</div>
			        <div style="padding-bottom: 10px;">There are <%= iAdminRequestCount %> Doses in total</div>
				</td>
			</tr>
			<tr>
				<td valign="top" colspan='2'>
				    <table >
<% 'Bug 122642 When trying to administer prescriptions of an orderset gets the error 
ScriptButtonVerticalPage(sessionId, TYPE_ADMINREQUEST, sRequestXml, iHeight, iWindowWidth, blnShowRequiredMessage, strStillRequiredText, strNoLongerRequiredText) %>
                    </table>
                </td>
			</tr>
			
<%
    Else
%>
			<tr>
				<td align="center" colspan='2' class="Prompt" style="height:100%;">Empty order set</td>
			</tr>
<%
    End IF
%>
</table>

<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>
</body>
</html>
