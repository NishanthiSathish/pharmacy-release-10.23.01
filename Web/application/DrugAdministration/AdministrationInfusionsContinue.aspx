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
    'AdministrationInfusionContinue.aspx
    '
    '
    '
    '
    'Modification History:
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
    Dim strReasonCode As String
    Dim strReasonClass As String
    Dim strImage As String
    
    sessionId = CIntX(Request.QueryString("SessionID"))
    
    ' Make sure episode id is selected
    episodeId = CIntX(StateGet(sessionId, "Episode"))
    If episodeId = 0 Then
        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If
    
    'Read variables from our state table
    entityId = StateGet(sessionId, "Entity")
    'If we've come back from the reason code picker, we'll have an ArbTextID
    'passed on the querystring, which we'll now save in state
    arbTextId = RetrieveAndStore(sessionId, CStr(DA_ARBTEXTID))
    If arbTextId <> "" Then 
        arbitraryTextRead = new OCSRTL10.ArbitraryTextRead()
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
    End IF
%>


<html>
<head>
<title>Drug Administration</title>
<script language="javascript" type="text/javascript" src="../sharedscripts/SessionAttribute.js"></script>
<script type="text/javascript" language="javascript" src='../sharedscripts/Touchscreen/Touchscreenshared.js'></script>
<script type="text/javascript" language="javascript" src='scripts/DrugAdministrationConstants.js'></script>
<script type="text/javascript" language="javascript">
//----------------------------------------------------------------------------------------------
function Cancel()
{
	//Fires when the "back" button is pressed
	var strUrl = 'AdministrationPrescriptionDetail.aspx'
		+ '?SessionID=<%= sessionId %>'
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
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&' + DA_ADMINISTERED + '=0'
                    + '&' + DA_PARTIAL + '=1';
    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------

function EnterReason(){
//Fires when the "pick reason" button is pressed
    var strPage = document.URL;
	strPage = strPage.substring(0, strPage.indexOf('?'));
    var strUrl = 'ArbtextPicker.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&' + DA_DESTINATION_URL + '=AdministrationInfusionsContinue.aspx'
                    + '&' + DA_REFERING_URL + '=AdministrationInfusionsContinue.aspx'
                        + '&' + DA_ARBTEXTTYPE + '=' + ARBTEXTTYPE_PARTIAL_ADMIN_REASON
                            + '&' + DA_PROMPT + '=' + TXT_ENTER_PARTIAL_ADMIN_REASON;
	void TouchNavigate(strUrl);
}
//----------------------------------------------------------------------------------------------

function EditBatchnumbers() {
//Fires when the Time button is pressed.
    var strUrl = 'AdministrationBatchNumbers.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&' + DA_DESTINATION_URL + '=AdministrationPartial.aspx'
                    + '&' + DA_REFERING_URL + '=AdministrationPartial.aspx';
    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
//infusion to continue (restarted)
//same route as 'FluidChange' on prescriptiondetails
function Continue() {
    
    SessionAttributeSet(<%=SessionID %>, '<%=CStr(DA_NODOSERULES) %>', '1');

    var strUrl = "AdministrationDateEntry.aspx"
        + "?SessionID=<%= sessionId %>"
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&DateEntryPrompt=Enter the date the infusion was RESTARTED'
                    + "&InfusionAction=Started";
    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
//infusion to be stopped (ended)
//same route as 'stopped' on prescriptiondetails
//datetime picker - confirmation
function Stopped() {
    var strUrl = 'AdministrationDateEntry.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&DateEntryPrompt=Enter the date the infusion was ENDED'
                    + '&InfusionAction=Ended'
                        + '&' + DA_ADMINISTERED + '=0'
                            + '&' + DA_PARTIAL + '=1';
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


<table style="width:100%;" cellpadding="0" cellspacing="0">	
    <tr>
		<td class="Prompt">
		<%
	        DrugAdminEpisodeBannerByID(sessionId, episodeId)
        %>
		</td>
	</tr>
</table>

<table cellpadding="0" cellspacing="<%= BUTTON_SPACING %>" align='center' style='width:<%= (BANNER_WIDTH_ADMINREQUEST) %>px' >	

	<tr>
		<td colspan="2" class="Prompt">
		The following Problem will be recorded.
		</td>
	</tr>
	<tr>
		<td colspan="2" align="center">
<%
    ScriptButton_Picker("Reason why administration was not completed (press to change)", DIR_GENERIC_IMAGES & strImage, strReasonCode, strReasonClass, "EnterReason()")
%>

		</td>
	</tr>
	
	<tr>
		<td colspan="2" class="Prompt">
		Please indicate if the infusion will be CONTINUED or STOPPED because of this problem.
		</td>
	</tr>
	
	<tr>
		<td align="left">
<%
    TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/InfusionStarted.gif", "Continued", "Continue()", true)
%>

		</td>
		<td align="right">
<%
    TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/InfusionEnd.gif", "Stopped", "Stopped()", true)
%>
		</td>
	</tr>
</table>
</body>
</html>
