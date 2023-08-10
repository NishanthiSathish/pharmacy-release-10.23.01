<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.ICWCookie" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%
    Dim lngSessionID As Long 
    Dim lngEpisodeID As Long 
    Dim strOCXURL As String
	Dim objStateRead As GENRTL10.StateRead
	Dim objState As GENRTL10.State
    Dim objSettingRead As GENRTL10.SettingRead
    Dim lngCookieID As Double 
    Dim strAscribeSiteNumber As String 
    Dim strLabelTypesPreventEdit As String
    Dim strAllowReDispensing As String
    DIM strURLScheme As String 
	Dim showHeader As Boolean
    Dim enableOnLoad As Boolean
    Dim intPortNumber As Integer
    
%>
<%
    '---------------------------------------------------------------------------------------------
    '
    'ICW_Dispensing.aspx
    '
    'ICW web application wrapper for the "web-based" Dispense control.
    '
    'ICW Parameters: AscribeSiteNumber
    '
    'Modification History:
    '21Oct04 PH Created
    '27Jun12 AJK 36930 Changed page name from GetConnectionString to GetEncryptedString for the OCX URL   
    '13May15 XN  Added AllowReDispensing option 26726
    '04May16 XN  123082 Updates for amm dispensing
    '23May16 XN  153668 Added enableOnLoad ulr parameter
%>

<%
    lngSessionID = Generic.CLngX(Request.QueryString("SessionID"))
    strAscribeSiteNumber = Trim(ICW.ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", ""))
    strLabelTypesPreventEdit = Trim(ICW.ICWParameter("LabelTypesPreventEdit", "Which Label types are locked for editing e.g IOD", ""))
    strAllowReDispensing = Trim(ICW.ICWParameter("AllowReDispensing", "If user is allowed to reuse a dispensing record mainly switched off for EMM", "Enabled,DisabledIfEmmWard,Disabled"))
    If Generic.CLngX(strAscribeSiteNumber) <= 0 Then 
        Response.Write("<html><body>Must specify a 3-digit site number during desktop configuration.</body></html>")
        Response.End()
    End IF
    objStateRead = new GENRTL10.StateRead()
    lngEpisodeID = CLng(objStateRead.GetKey(CInt(lngSessionID), "Episode"))
    objStateRead = Nothing
	'26-10-2007 JA/LM/AI Error code 2
	
	lngCookieID = GetCookieID(lngSessionID)
	If lngCookieID = -1 Then
		'Create cookie because it doesnt exist
		lngCookieID = CreateCookie(lngSessionID)
	End If
	
    objState = new GENRTL10.State()
    objState.SetKey(CInt(lngSessionID), "Cookie", CInt(lngCookieID))
    objState = Nothing

    
    '29Sep15 TH Added Overlay for URL scheme for call back (TFS 130427)
    '8May20 AS Added port number for web transport layer
    objSettingRead = New GENRTL10.SettingRead()
    strURLScheme = objSettingRead.GetValue(CInt(lngSessionID), "Pharmacy", "WebConnection", "URLscheme", Request.Url.Scheme)
    intPortNumber = objSettingRead.GetPortNumber(CInt(lngSessionID), "Pharmacy", "Database", "PortNoWebTransport")
    objSettingRead = Nothing

    '12Jan08 XN F0042881 now send in the http:// as maybe using https
    '    strOCXURL = Request.Url.Host & Request.ApplicationPath & "/integration/Pharmacy/GetEncryptedString.aspx" & "?token=" & secrtl_c.TokenGenerator.GenerateToken(lngSessionID) & "&SessionId=" & lngSessionID
    '27Jun12 AJK 36930 Changed page name
    'strOCXURL = Request.Url.Scheme & Request.Url.SchemeDelimiter & Request.Url.Host & Request.ApplicationPath & "/integration/Pharmacy/GetEncryptedString.aspx" & "?token=" & secrtl_c.TokenGenerator.GenerateToken(lngSessionID) & "&SessionId=" & lngSessionID
    If (intPortNumber = 0 Or intPortNumber = 80 Or intPortNumber = 443) Then
        strOCXURL = strURLScheme & Request.Url.SchemeDelimiter & Request.Url.Host & Request.ApplicationPath & "/integration/Pharmacy/GetEncryptedString.aspx" & "?token=" & secrtl_c.TokenGenerator.GenerateToken(lngSessionID) & "&SessionId=" & lngSessionID
    Else
        strOCXURL = strURLScheme & Request.Url.SchemeDelimiter & Request.Url.Host & ":" & intPortNumber & Request.ApplicationPath & "/integration/Pharmacy/GetEncryptedString.aspx" & "?token=" & secrtl_c.TokenGenerator.GenerateToken(lngSessionID) & "&SessionId=" & lngSessionID
    End If
    
	showHeader   = If(BoolExtensions.PharmacyParseOrNull(Request.QueryString("ShowHeader")), true)
    enableOnLoad = If(BoolExtensions.PharmacyParseOrNull(Request.QueryString("EnableOnLoad")), true)
%>

<html>
<head>
<title>Dispensing</title>

<script src="../sharedscripts/icw.js"></script>
<script type="text/javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>
<script src="script/Dispensing.js"></script>

<script >
<!--

//===============================================================================
//									ICW EventListeners
//===============================================================================

function EVENT_EpisodeSelected(vid)
{
    RefreshState(0, 0);
    
    // Check episode and entity rows exist in the DB with the expected versions as specified in the vid parameter
    //ICW.clinical.episode.episodeSelected.init(<%= CInt(Request.QueryString("SessionID")) %>, vid, EntityEpisodeSyncSuccess);

    // Called if/when Entity & Episode exist in the DB at the correct versions
    //function EntityEpisodeSyncSuccess(vid){}
    
    
 }

 //DJH - TFS Bug 12880 - Add new Episode Cleared event.
 function EVENT_EpisodeCleared() {
     RefreshState(0, 0);
 }

function EVENT_Dispensing_RefreshState(RequestID_Prescription, RequestID_Dispensing)
{
// Listens for "Dispensing_RefreshState" events, and will call RefreshState on the objDispense object
// 05May04 PH Created
	RefreshState(RequestID_Prescription, RequestID_Dispensing);
}
//-->
</script>

<SCRIPT ID=clientEventHandlersJS LANGUAGE=javascript>
<!--
function objDispense_RefreshView(RequestID_Prescription, RequestID_Dispensing) 
{
	RAISE_Dispensing_RefreshView(RequestID_Prescription, RequestID_Dispensing);
}

//===============================================================================
//									ICW Raised Events
//===============================================================================

function RAISE_Dispensing_RefreshView(RequestID_Prescription, RequestID_Dispensing)
{
// This event is listened to by the DispensingPMR page that hosts the PMR grid, 
// This event is raised when an item has been created or edited by the ObjDispensing UserControl. 
// A RequestID of 0 means "create", a positive RequestID means edit the item with that RequestID
    if (typeof window.parent.RAISE_Dispensing_RefreshView === 'function')
        window.parent.RAISE_Dispensing_RefreshView(RequestID_Prescription, RequestID_Dispensing);
}


//-->
</SCRIPT>


<SCRIPT LANGUAGE=vbscript>
<!--
function objDispense_RefreshView(RequestID_Prescription, RequestID_Dispensing)
	
	RAISE_Dispensing_RefreshView RequestID_Prescription, RequestID_Dispensing
	
end function

//-->
</SCRIPT>

<link rel="stylesheet" type="text/css" href="../../style/application.css"/>

</head>

<body id="bdy" 
	SessionID="<%= lngSessionID %>" 
	EpisodeID="<%= lngEpisodeID %>"
	OCXURL=<%= strOCXURL %>
	CookieID="<%= lngCookieID %>"
	AscribeSiteNumber="<%= strAscribeSiteNumber %>"
        LabelTypesPreventEdit = "<%= strLabelTypesPreventEdit %>"
    AllowReDispensing = "<%= strAllowReDispensing %>"
<% If enableOnLoad Then %>
     onload="return window_onload()"
<% End If %>
>

	<table width="100%" height="100%" cellpadding=0 cellspacing=0>	
		<tr height="1%">
			<td>
<%
If showHeader Then    
    ICW.ICWHeader(lngSessionID)
End If        
%>

			</td>
		</tr>
		<tr>
			<td>
			
<OBJECT 
					id=objDispense 
					style="left:0px;top:0px;width:100%;height:100%"
					codebase="../../../ascicw/cab/HEdit.cab" 
					component="dispensingctl.ocx"
					classid=CLSID:BBA260B2-D82D-49AE-BCEA-A69333237A8B VIEWASTEXT>
					<PARAM NAME="_ExtentX" VALUE="16113">
					<PARAM NAME="_ExtentY" VALUE="11139">					
					<SPAN STYLE="color:red">ActiveX control failed to load! -- Please check browser security settings.</SPAN>
				</OBJECT>

			</td>
		</tr>
	</table>

</body>
</html>
