<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<html>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationNote.aspx
    '
    'Note Entry page.
    '
    'Useage:
    'Call with the following QS Parameters:
    'Referer:			Page which called this one
    'Dest:				Page which we will navigate to when the OK button is pressed
    '
    'Modification History:
    '31Jul05    AE      Written
    '19May2010  Rams    F0078434 - Do not Create AdminRequest for PRN's when Override Administration
    '
    '----------------------------------------------------------------------------------------------------------------
    'URL we go to when they pick an item
    'URL we go to if they cancel

    Dim sessionId As Integer
    Dim entityId As Integer
    Dim episodeId As Integer
    Dim destinationUrl As String
    Dim requestId As Integer
    Dim strOnLoad As String
    Dim strNote As String = ""
    strNote = Request.QueryString(DA_NOTE)
    'Read querystring.  This will specify the ArbTextType we are to show,
    'and the URL we are to return to
    sessionId = CIntX(Request.QueryString("SessionID"))
    
    ' Make sure episode id is selected
    episodeId = CIntX(StateGet(sessionId, "Episode"))
    If episodeId = 0 Then
        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If
    
    destinationUrl = Request.QueryString(DA_DESTINATION_URL)
    'Read useful variables from state
    requestId = CIntX(SessionAttribute(sessionId, CStr(DA_REQUESTID)))
    entityId = CIntX(StateGet(sessionId, "Entity"))
    strOnLoad = "DisplayNoteKeypad('add')"	    	    
    Dim strRedirect as String
	strRedirect = destinationUrl & "?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate") & "&dssresult=" & Request.QueryString("dssresult") & "&OverrideAdmin=" & IIf(Generic.SessionAttribute(sessionId, "OverrideAdmin") = True, "1", "0")
	
	If Not String.IsNullOrEmpty(Request.QueryString(DA_ADMINISTERED)) Then
		strRedirect &= "&" & DA_ADMINISTERED & "=" & Request.QueryString(DA_ADMINISTERED)
	End If
	
	If Not String.IsNullOrEmpty(Request.QueryString(DA_PARTIAL)) Then
		strRedirect &= "&" & DA_PARTIAL & "=" & Request.QueryString(DA_PARTIAL)
	End If

	If LCase(Request.QueryString("Mode")) = "cancel" Then
		Response.Redirect(strRedirect)
	End If

	If (Not strNote Is Nothing) Then		' we are posting the result to be stored in the db session
		SessionAttributeSet(sessionId, CStr(DA_NOTE), strNote)
		SessionAttributeSet(sessionId, CStr(DA_NOTE_REQUESTID), requestId.ToString())
		strRedirect &= "&" & DA_NOTE & "=" & strNote.Replace(vbCr, "&lt;br/&gt;")
		Response.Redirect(strRedirect)
	End If
%>


<script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
<script type="text/javascript" language="javascript" src='../sharedscripts/icw.js'></script>
<script type="text/javascript" language="javascript">

var m_strCurrentMode;
 
//------------------------------------------------------------------------------------------------------------------
function Confirm(){
	var strUrl  = '<%= destinationUrl %>' 
    	+ '?SessionID=<%= sessionId %>' 
        	+ '&dssresult=<%= Request.QueryString("dssresult") %>' 
            	+ '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';

    if (QueryString(DA_ADMINISTERED) != '')
    	strUrl += '&' + DA_ADMINISTERED + '=' + QueryString(DA_ADMINISTERED);
    if (QueryString(DA_PARTIAL) != '')
    	strUrl += '&' + DA_PARTIAL + '=' + QueryString(DA_PARTIAL);

	void TouchNavigate(strUrl);
}

//------------------------------------------------------------------------------------------------------------------
function Cancel () {
    var strUrl = document.URL;
    strUrl = strUrl.substring(0, strUrl.indexOf('?'));
    strUrl += '?SessionID=<%= sessionId %>'
        + '&' + DA_DESTINATION_URL + '=<%= destinationUrl %>'
                + '&dssresult=<%= Request.QueryString("dssresult") %>'
                    + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                        + '&Mode=cancel';

    if (QueryString(DA_ADMINISTERED) != '')
    	strUrl += '&' + DA_ADMINISTERED + '=' + QueryString(DA_ADMINISTERED);
    if (QueryString(DA_PARTIAL) != '')
    	strUrl += '&' + DA_PARTIAL + '=' + QueryString(DA_PARTIAL);

    void TouchNavigate(strUrl);	
}

//------------------------------------------------------------------------------------------------------------------
function ScreenKeyboard_EnterText(strText)
{
    // remove the blank spaces at the end and the begining of the string e.g. Trim it
    var s = new String(strText);
    var trimmed = s.replace(/^\s+|\s+$/g, '');
    
    // Check is the trimmed string is empty or not
    if(trimAll(trimmed) != '')
    {
        // string contains some text therefore we can edit or add a note
        if(m_strCurrentMode=="edit")
        {
            EditNote(strText);
        }
        else
        {
            AddNote(strText);
        }
    }
    else
    {
        // string didn't contain any text. Therefore cancel the key board
        Cancel();
    }
}

//----------------------------------------------------------------------------------
function trimAll(sString) 
{
    while (sString.substring(0,1) == ' ') 
    { 
        sString = sString.substring(1, sString.length); 
    }
     
    while (sString.substring(sString.length-1, sString.length) == ' ') 
    { 
        sString = sString.substring(0,sString.length-1); 
    }
     
    return sString; 
}

//------------------------------------------------------------------------------------------------------------------
function DisplayNoteKeypad ( sAddEditMode )
{    
  	m_strCurrentMode     = sAddEditMode;
	document.frames['fraKeyboard'].ShowKeyboard ( 'Enter a Note' );
	document.frames['fraKeyboard'].SetDisplay ( '<%
	
	Dim s as String = Ascribe.Common.Generic.SessionAttribute(sessionId, DA_NOTE)
	Dim r as Integer  = CIntX(Ascribe.Common.Generic.SessionAttribute(sessionId, DA_NOTE_REQUESTID))
	If r = requestId Then
	    response.write(s.Replace(vbCr,"&lt;br/&gt;").Replace("<","&lt;").Replace(">","&gt;").Replace("'","\'"))
	End If
	%>' );
}

//------------------------------------------------------------------------------------------------------------------
function AddNote (strNote) {
    var strUrl = document.URL;
    strUrl = strUrl.substring(0, strUrl.indexOf('?'));
    strUrl += '?SessionID=<%= sessionId %>'
        + '&' + DA_DESTINATION_URL + '=<%= destinationUrl %>'
                + '&' + DA_NOTE + '=' + strNote
                    + '&dssresult=<%= Request.QueryString("dssresult") %>'
                        + '&Mode=add'
                            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';

    if (QueryString(DA_ADMINISTERED) != '')
    	strUrl += '&' + DA_ADMINISTERED + '=' + QueryString(DA_ADMINISTERED);
    if (QueryString(DA_PARTIAL) != '')
    	strUrl += '&' + DA_PARTIAL + '=' + QueryString(DA_PARTIAL);

    void TouchNavigate(strUrl);	
}

//------------------------------------------------------------------------------------------------------------------
function EditNote (strNote) {
    var strUrl = document.URL;
    strUrl = strUrl.substring(0, strUrl.indexOf('?'));
    strUrl += '?SessionID=<%= sessionId %>'
        + '&' + DA_DESTINATION_URL + '=<%= destinationUrl %>'
                + '&' + DA_NOTE + '=' + strNote
                    + '&dssresult=<%= Request.QueryString("dssresult") %>'
                        + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                            + '&Mode=edit';

    if (QueryString(DA_ADMINISTERED) != '')
    	strUrl += '&' + DA_ADMINISTERED + '=' + QueryString(DA_ADMINISTERED);
    if (QueryString(DA_PARTIAL) != '')
    	strUrl += '&' + DA_PARTIAL + '=' + QueryString(DA_PARTIAL);
			 
    void TouchNavigate(strUrl);	
}

</script>

<head>
<title>Batch Number Entry</title>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />

</head>

<body class="Touchscreen" onload="document.body.style.cursor = 'default';<%= strOnLoad %>" >
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
	<tr>
	    <td class="Prompt">Enter a Note1</td>
	</tr>
</table>

<iframe id="fraKeyboard" frameborder="1" style="display:none;background-color:transparent;position:absolute;top:50px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/MultilineKeyboard.aspx"></iframe>
<iframe id="fraSelectAction" frameborder="1" style="display:none;background-color:transparent;position:absolute;top:50px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="AdministrationSelectAction.aspx"></iframe>
<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>

</body>
</html>
