<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<html>

<%
    Dim sessionId As Integer
    Dim episodeId As Integer
    Dim entityId As Integer 
    Dim arbTextType As String 
    Dim windowHeight As Integer
    Dim windowWidth As Integer
    Dim destinationUrl As String 
    Dim cancelUrl As String 
    Dim prompt As String 
    Dim arbitraryTextRead As OCSRTL10.ArbitraryTextRead
    Dim intHeight As Integer
    Dim strTextXml As String 
    Dim strInfusionAction As String 
%>
<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AtbTextPicker.aspx
    '
    'Arb Text picker.
    '
    'Useage:
    'Call with the following QS Parameters:
    'TextType:			The description of the Arb Text Type which we wish to list.
    '
    'When the user selects an ArbTextID, the page returns to the page which called it, with the
    'selected ArbTextID on the querystring as ArbTextID
    '
    'Modification History:
    '31May05 AE  Written
    '
    '----------------------------------------------------------------------------------------------------------------
    'URL we go to when they pick an item
    'URL we go to if they cancel
    'Read querystring.  This will specify the ArbTextType we are to show,
    'and the URL we are to return to
    sessionId = CIntX(Request.QueryString("SessionID"))
    
    ' Make sure episode id is selected
    episodeId = CIntX(StateGet(sessionId, "Episode"))
    If episodeId = 0 Then
        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If
    
    arbTextType = RetrieveAndStore(sessionId, CStr(DA_ARBTEXTTYPE))
    destinationUrl = Request.QueryString(DA_DESTINATION_URL)
    cancelUrl = Request.QueryString(DA_REFERING_URL)
    prompt = Request.QueryString(DA_PROMPT)
    'a cludge if we get here for a continuous infusion because we need an 'Action' string in state
    'from AdministrationDateEntry should save state and script callback to PrescriptionDetail to navigate here
    strInfusionAction = Request.QueryString("InfusionAction")
    If strInfusionAction <> "" Then
        SessionAttributeSet(sessionId, "InfusionAction", strInfusionAction)
    End IF
    
    'Read useful variables from state
    windowHeight = CIntX(SessionAttribute(sessionId, CStr(DA_HEIGHT)))
    windowWidth = CIntX(SessionAttribute(sessionId, CStr(DA_WIDTH)))
    entityId = StateGet(sessionId, "Entity")
    
    'Read all of the text strings of the given type
    arbitraryTextRead = new OCSRTL10.ArbitraryTextRead()
    strTextXml = arbitraryTextRead.GetTextByTypeName(sessionId, arbTextType, True)
    arbitraryTextRead = Nothing
    
    'Work out the height we have to play with
    intHeight = windowHeight - TouchscreenShared.BUTTON_STANDARD_HEIGHT - (3 * CIntX(BUTTON_SPACING))
%>


<script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
<script type="text/javascript" language="javascript">
//------------------------------------------------------------------------------------------------------------------
function Navigate(ArbTextID)
{
    var arbTextId;
    if ('<%=Request.QueryString(DA_ARBTEXTRETURNID) %>' != '') {
        arbTextId = '<%=Request.QueryString(DA_ARBTEXTRETURNID) %>';
    }
    else {
        arbTextId = DA_ARBTEXTID;
    }

    var strUrl = '<%= destinationUrl %>'
        + '?SessionID=<%= sessionId %>'
            + '&dssresult=<%= Request.QueryString("dssresult") %>'
                + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                    + '&' + arbTextId + '=' + ArbTextID;
    if("<%= destinationUrl %>" == "administrationfluidchange.aspx")
        strUrl += "&Mode=ReasonPicked"; //going back
	void TouchNavigate(strUrl);
}

//------------------------------------------------------------------------------------------------------------------
function Cancel()
{
	var strUrl = '<%= cancelUrl %>'
		+ '?SessionID=<%= sessionId %>'
		+ '&dssresult=<%= Request.QueryString("dssresult") %>'
		+ '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
		+ '&OverrideAdmin=<%=IIf(String.Compare(SessionAttribute(sessionId, "OverrideAdmin"), "True", True) = 0, "1", "0")%>';
	void TouchNavigate(strUrl);
}

//------------------------------------------------------------------------------------------------------------------
window.onload = function () { document.body.style.cursor = 'default'; }
</script>

<head>
<title>Text Picker</title>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />

</head>
<body class="Touchscreen">
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
    TouchscreenShared.NavButton("../../images/touchscreen/Cross.gif", "Cancel", "Cancel();", true)
%>
		</td>		
		<td class="Toolbar" style="padding-right:<%= BUTTON_SPACING %>" align="center">
<%
    ScriptBanner_AdminRequestCurrent(sessionId, false, entityId)
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

<table>
<%
    If prompt <> "" Then 
%>

		<tr>
			<td class="Prompt"><%= prompt %></td>
		</tr>
<%
    End IF
%>


	<tr>
<%
    'Script the list O' text strings, if there is one.
    If Len(strTextXml) > Len("<root></root>") Then 
%>

				<td valign="top"><%
        ScriptButtonPage(sessionId, TYPE_ARBTEXT, strTextXml, intHeight, windowWidth)
%>
</td>

<%
    Else
%>
				<td align="center" class="Prompt" style="height:100%">No Text of type &quot;<%= arbTextType %>&quot; configured.</td>
<%
    End IF
%>
	</tr>
</table>

</body>
</html>
