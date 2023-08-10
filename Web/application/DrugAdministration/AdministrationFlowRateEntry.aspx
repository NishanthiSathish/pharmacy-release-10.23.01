<%@ Page Language="VB" AutoEventWireup="false" CodeFile="AdministrationFlowRateEntry.aspx.vb" Inherits="application_DrugAdministration_AdministrationFlowRateEntry" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationFlowRateEntry.aspx
    '
    '
    '----------------------------------------------------------------------------------------------------------------
    Dim sessionId As Integer
    Dim episodeId As Integer
    Dim entityId As Integer
    Dim prescriptionId As Integer
    Dim flowRate As Double = 0
    Dim minRate As Double
    Dim maxRate As Double
    Dim rateUnitId As Integer
    Dim rateUnitDescription As String = String.Empty
    Dim timeUnitId As Integer
    Dim timeUnitDescription As String = String.Empty

    'Read querystring and State to get out standard variables
    sessionId = CIntX(Request.QueryString("SessionID"))
    
    ' Make sure episode id is selected
    episodeId = CIntX(StateGet(sessionId, "Episode"))
    If episodeId = 0 Then
        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If
    
    entityId = CIntX(StateGet(sessionId, "Entity"))
    
    'We may have to store the Admin Date if we've come from the date picker
    If Request.QueryString(DA_ADMINDATE) <> "" Then
        SessionAttributeSet(sessionId, CStr(DA_ADMINDATE), Request.QueryString(DA_ADMINDATE).ToString)
    End If
    
    prescriptionId = CIntX(SessionAttribute(sessionId, CStr(DA_PRESCRIPTIONID)))
    SetFlowRate(sessionId, prescriptionId, rateUnitId, timeUnitId, rateUnitDescription, timeUnitDescription, flowRate, minRate, maxRate)
                            
    'If we have been sent a dose to store (this will be the case when confirming in numerical entry mode), store it and move
    'on to the next page
    If Request.QueryString("Confirm") = "1" Then
        SessionAttributeSet(sessionId, CStr(DA_FLOW_RATE), Request.QueryString(DA_FLOW_RATE).ToString)
        SessionAttributeSet(sessionId, CStr(DA_FLOW_RATE_UNITID), Request.QueryString(DA_FLOW_RATE_UNITID).ToString)
        SessionAttributeSet(sessionId, CStr(DA_FLOW_RATE_UNIT), Request.QueryString(DA_FLOW_RATE_UNIT).ToString)
        SessionAttributeSet(sessionId, CStr(DA_FLOW_RATE_UNITID_TIME), Request.QueryString(DA_FLOW_RATE_UNITID_TIME).ToString)
        SessionAttributeSet(sessionId, CStr(DA_FLOW_RATE_UNIT_TIME), Request.QueryString(DA_FLOW_RATE_UNIT_TIME).ToString)
        Response.Redirect("AdministrationYes.aspx?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate"))
    End If
    'Otherwise, on we go...
    'Read the Prescription so we can interpret the dose required.
    'We store this in the SessionAttribute table after the first hit, for speed
    prescriptionId = CIntX(SessionAttribute(sessionId, CStr(DA_PRESCRIPTIONID)))
%>


<html>
<head>
<title>Flow Rate</title>
<script type="text/javascript" language="javascript" src='scripts/DrugAdministrationConstants.js'></script>
<script type="text/javascript" language="javascript" src='../sharedscripts/Touchscreen/Touchscreenshared.js'></script>
<script type="text/javascript" language="javascript">

    var m_strPage;

    //----------------------------------------------------------------------------------------------
    function ShowRateWarning(rateUnder, rateOver, strDestinationPage) {

        var strPromptHtml = '<h1>WARNING!</h1><p>This rate is ';
        if (rateOver) strPromptHtml += 'GREATER ';
        if (rateUnder) strPromptHtml += 'LOWER ';
        strPromptHtml += 'than the prescribed rate.  Are you sure that you wish to continue?</p>';
        m_strPage = strDestinationPage;
        void document.frames['fraConfirm'].Show(strPromptHtml, 'yesno');
    }

    function Confirmed(strChosen) {

        //User was warned of an over- or underdose and has selected yes or no.
        if (strChosen == 'yes') {
            NavigateToPage("../../DrugAdministration/" + m_strPage);
        }
        else {
            m_strPage = '';
        }
    }
    //------------------------------------------------------------------------------------------------------------------
    function NavigateToPage(strPage) {
        var strUrl = strPage;
        if (strUrl.toLowerCase().indexOf('?sessionid') < 0) strUrl += '?SessionID=<%= sessionId %>';
        void TouchNavigate(strUrl);
    }

    //------------------------------------------------------------------------------------------------------------------
    function Confirm() {

        //When confirm is pressed
        var flowRate = Number(flowrateselected.value);

        var page = 'AdministrationFlowRateEntry.aspx?SessionID=<%= sessionId %>'
        + '&Confirm=1'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&<%= DA_FLOW_RATE %>=' + flowRate
                    + '&<%= DA_FLOW_RATE_UNITID %>=' + rateunitid.value
                        + '&<%= DA_FLOW_RATE_UNIT %>=' + rateunit.value
                            + '&<%= DA_FLOW_RATE_UNITID_TIME %>=' + timeunitid.value
                                + '&<%= DA_FLOW_RATE_UNIT_TIME %>=' + timeunit.value;

        var minRate = Number(minrate.value);
        var maxRate = Number(maxrate.value);
        var rateUnder = flowRate < minRate;
        var rateOver = flowRate > maxRate;
        if (rateUnder || rateOver) {
            ShowRateWarning(rateUnder, rateOver, page);
        }
        else {
            void TouchNavigate(page);
        }
    }

    //------------------------------------------------------------------------------------------------------------------
    function SetFlowRate() {
        document.frames['fraKeyboard'].ShowNumpad('Enter Flow Rate in <%= rateUnitDescription %>/<%= timeUnitDescription %>', null, 4);
    }
    //------------------------------------------------------------------------------------------------------------------
    function ScreenKeyboard_EnterText(flowRateQuantity) {

        //Fires when the user has entered a quantity on the number pad
        //If they didn't cancel, we need to add this drug to our basket o' drugs.

        if (flowRateQuantity != '') {
            tdFlowRate.innerHTML = flowRateQuantity + ' ' + rateunit.value + '/' + timeunit.value;
            flowrateselected.value = flowRateQuantity;
        }
    }

    //----------------------------------------------------------------------------------------------
    function EnableButtons() {

        if (tblContent.offsetHeight < (divScroller.offsetHeight - 20)) {
            document.all['tblScrollButtons'].style.display = 'none';
        }
        else {

            if (divScroller.scrollTop <= 0) {
                void EnableButton(document.all['ascScrollup'], false);
            }
            else {
                void EnableButton(document.all['ascScrollup'], true);
            }

            if ((divScroller.scrollTop + divScroller.offsetHeight) >= tblContent.offsetHeight) {
                void EnableButton(document.all['ascScrolldown'], false);
            }
            else {
                void EnableButton(document.all['ascScrolldown'], true);
            }
        }
    }

    //----------------------------------------------------------------------------------------------
    function PageUp() {
        //Scroll the content window 1 page upwards
        divScroller.scrollTop = divScroller.scrollTop - divScroller.offsetHeight;
        EnableButtons();
    }
    //----------------------------------------------------------------------------------------------
    function PageDown() {
        //Scroll the content window 1 page downwards
        divScroller.scrollTop = divScroller.scrollTop + divScroller.offsetHeight;
        EnableButtons();
    }

    //----------------------------------------------------------------------------------------------
    window.onload = function () { document.body.style.cursor = 'default'; }
</script>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
</head>
<!-- F0063047 ST 040210 Add new settings to body tag -->
<body class="Touchscreen DrugEntry">
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
<br />
<br />
<table style="width:100%;height:100%" cellpadding="0" cellspacing="0">	
    <tr>
		<td class="Prompt"><%DrugAdminEpisodeBannerByID(sessionId, episodeId)%></td>
	</tr>
    <tr>
	    <td align="center" valign="top" style="height:100%;" >
            <table cellpadding="0"  style="width:<%= BANNER_WIDTH_DOSE %>" align='center' class="NumericEntry">							
			    <tr>
                    <td colspan="2" align='center'>
					    <table border='1' cellpadding='0' cellspacing='0' class='Dose' style="width:100%">
						    <tr>
							    <td class="TouchButton" onclick="SetFlowRate()" id="btnFlowRate" style="height:<%= TouchscreenShared.BUTTON_STANDARD_HEIGHT %>;" <%= TouchscreenShared.EVENTHANDLER_BUTTON %> align="center">
                                    <table cellpadding='1' cellspacing='0'>
									    <tr class='Prompt'>
										    <td>Flow Rate:&nbsp;</td>
											<% 
											If flowRate > 0 Then
    									 	%>
    									 	<td id='tdFlowRate'><%= flowRate %>&nbsp;<%= rateUnitDescription %>/<%=timeUnitDescription%></td>
    									 	<% 
    									 	Else
   									 		%>
											<td id='tdFlowRate'>(Not Recorded)</td>
											<% 
											End If
										 	%>
                                        </tr>
										<tr class='Info'><td>(press to change)</td></tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
				<tr>
				    <td colspan="2" class="Prompt" style="padding:<%= BUTTON_SPACING %>">Click [Confirm] to confirm this Flow Rate, or [Cancel] to return to the previous page</td>
                </tr>
                <tr>
				    <td align="right" style="padding:<%= BUTTON_SPACING %>">
                    <%
                        Dim NavCancelURL As String = IIf(Request.QueryString(DA_REFERING_URL) = "", "AdministrationPrescriptionDetail.aspx", Request.QueryString(DA_REFERING_URL))
                        TouchscreenShared.NavButton("../../images/touchscreen/Cross.gif", "Cancel", "NavigateToPage('" & NavCancelURL & "?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate") & "&OverrideAdmin=" & IIf(String.Compare(SessionAttribute(sessionId, "OverrideAdmin"), "True", True) = 0, "1", "0").ToString() & "');", True)
                    %>
                    </td>
					<td align="left" style="padding:<%= BUTTON_SPACING %>">
                    <%
                        TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "Confirm", "Confirm();", True)
                    %>
                    </td>
                </tr>
            </table>				
        </td>
    </tr>
</table>
<input type="hidden" id="flowrateselected" value='<%= flowRate %>' />
<input type="hidden" id="rateunitid" value='<%= rateUnitId %>' />
<input type="hidden" id="rateunit" value='<%= rateUnitDescription %>' />
<input type="hidden" id="timeunitid" value='<%= timeUnitId %>' />
<input type="hidden" id="timeunit" value='<%= timeUnitDescription %>' />
<input type="hidden" id="minrate" value='<%= minRate %>' />
<input type="hidden" id="maxrate" value='<%= maxRate %>' />

<iframe id="fraKeyboard" frameborder="1" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/keyboard.htm"></iframe>
<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>
</body>
</html>

