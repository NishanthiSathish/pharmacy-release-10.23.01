<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.ICWCookie" %>

<%
	Dim lngSessionID As Long
	Dim lngEpisodeID As Object
	Dim objState As GENRTL10.State
    Dim objSettingRead As GENRTL10.SettingRead
	Dim lngCookieID As Double
	Dim strAscribeSiteNumber As String
	Dim strApplicationPath As String
	Dim strManuPass As String
	Dim strCommand As String
    Dim strURLtoken As String
    Dim strURLScheme As String
    Dim intPOrtNumber As Integer
%>
<%
    '---------------------------------------------------------------------------------------------
    '
    'ICW_Manufacturing.aspx
    '
    'ICW web application wrapper for StockTake.exe
    '
    'ICW Parameters: AscribeSiteNumber
    '
    'Modification History:
    '21Oct04 PH Created
    '
    '27oct08 CKJ renamed objLauncher to objStores to prevent Builder changing the name (F0036599)
    '16Jul13 TH  addad launch mode to allow for new bondstore
    '29Sep15 TH Added Overlay for URL scheme for call back (TFS 130427)	
%>

<%
	lngSessionID = Generic.CLngX(Request.QueryString("SessionID"))
    strAscribeSiteNumber = Trim(ICW.ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", ""))
    strApplicationPath = Trim(ICW.ICWParameter("ApplicationPath", "Path for Clien iStores.exe e.g. C:\Ascribe", ""))
	strManuPass = Trim(ICW.ICWParameter("ManuPass", "Single Digit Number for Manufacturing Level Access e.g. 4", ""))
	strCommand = Trim(ICW.ICWParameter("Mode", "Launch Mode", ""))
	If Generic.CLngX(strAscribeSiteNumber) <= 0 Then
		Response.Write("<html><body>Must specify a 3-digit site number during desktop configuration.</body></html>")
		Response.End()
	End If
    'Set objStateRead = server.CreateObject("GENRTL10.StateRead")
    'lngEpisodeID = Clng(objStateRead.GetKey(lngSessionID, "Episode"))
	'Set objStateRead = nothing
    
	lngCookieID = GetCookieID(lngSessionID)
	If lngCookieID = -1 Then
		'Create cookie because it doesnt exist
		lngCookieID = CreateCookie(lngSessionID)
	End If
	objState = New GENRTL10.State()
	objState.SetKey(CInt(lngSessionID), "Cookie", CInt(lngCookieID))
	objState = Nothing

    '29Sep15 TH Added Overlay for URL scheme for call back (TFS 130427)
    '8June20 AS Added port number for web transport layer
    objSettingRead = new GENRTL10.SettingRead()
    strURLScheme = objSettingRead.GetValue(CInt(lngSessionID), "Pharmacy", "WebConnection", "URLscheme", Request.Url.Scheme)
    intPOrtNumber = objSettingRead.GetPortNumber(CInt(lngSessionID), "Pharmacy", "Database", "PortNoWebTransport")
    objSettingRead = Nothing

	'12Jan08 XN F0042881 now send in the http:// as maybe using https
    'strURLtoken = Request.Url.Host & Request.ApplicationPath & "/integration/Pharmacy/GetEncryptedString.aspx" & "?token=" & secrtl_c.TokenGenerator.GenerateToken(lngSessionID) & "&SessionId=" & lngSessionID
    'strURLtoken = Request.Url.Scheme & Request.Url.SchemeDelimiter & Request.Url.Host & Request.ApplicationPath & "/integration/Pharmacy/GetEncryptedString.aspx" & "?token=" & secrtl_c.TokenGenerator.GenerateToken(lngSessionID) & "&SessionId=" & lngSessionID
    If (intPOrtNumber = 0 Or intPOrtNumber = 80 Or intPOrtNumber = 443) Then
        strURLtoken = strURLScheme & Request.Url.SchemeDelimiter & Request.Url.Host & Request.ApplicationPath & "/integration/Pharmacy/GetEncryptedString.aspx" & "?token=" & secrtl_c.TokenGenerator.GenerateToken(lngSessionID) & "&SessionId=" & lngSessionID
    Else
        strURLtoken = strURLScheme & Request.Url.SchemeDelimiter & Request.Url.Host & ":" & intPOrtNumber & Request.ApplicationPath & "/integration/Pharmacy/GetEncryptedString.aspx" & "?token=" & secrtl_c.TokenGenerator.GenerateToken(lngSessionID) & "&SessionId=" & lngSessionID
    End If
    
%>


<html>
<head>
<title>Manufacturing</title>

<script src="../sharedscripts/icw.js"></script>
<script src="script/Manufacturing.js"></script>

<script >
<!--

//===============================================================================
//									ICW EventListeners
//===============================================================================

//function EVENT_EpisodeSelected()
//{
// Occurs when episode is changed. Causes this list to be refreshed.
//	RefreshState(0, 0);
//}

//function EVENT_iDispensing_RefreshState(RequestID_Prescription, RequestID_Dispensing)
//{
// Listens for "iDispensing_RefreshState" events, and will cqall RefreshState on the objDispense object
// 05May04 PH Created
//	RefreshState(RequestID_Prescription, RequestID_Dispensing);
//}

//-->

// 54169 Disable activity monitor for items like stores, as popup not handled by monitor
function EVENT_InitialiseCompleted() 
{
    ICWWindow().SuspendTimeout();
}
</script>

<SCRIPT ID=clientEventHandlersJS LANGUAGE=javascript>
<!--
//function objDispense_RefreshView(RequestID) 
//{
//	RAISE_iDispensing_RefreshView(RequestID);
//}

//===============================================================================
//									ICW Raised Events
//===============================================================================

//function RAISE_iDispensing_RefreshView(RequestID)
//{
// This event is listened to by the IDispensingList page that hosts the PMR grid, 
// This event is raised when an item has been created or edited by the ObjDispensing UserControl. 
// A RequestID of 0 means "create", a positive RequestID means edit the item with that RequestID
//	ICWEventRaise();
//}


//-->
</SCRIPT>


<SCRIPT LANGUAGE=vbscript>
<!--
function objDispense_RefreshView(RequestID)
	
	RAISE_iDispensing_RefreshView RequestID
	
end function

//-->
</SCRIPT>

<link rel="stylesheet" type="text/css" href="../../style/application.css" />

</head>

<body id="bdy" 
	SessionID="<%= lngSessionID %>" 
	EpisodeID="<%= lngEpisodeID %>"
	CookieID="<%= lngCookieID %>"
	AscribeSiteNumber="<%= strAscribeSiteNumber %>"
	ApplicationPath="<%= strApplicationPath %>"
	ManuPass="<%= strManuPass %>"
	CommandLine="<%= strCommand %>"
    	URLtoken="<%= strURLtoken %>"
	onload="return window_onload()"
>

	<table width="100%" height="100%" cellpadding=0 cellspacing=0>	
		<tr height="1%">
			<td>
<%
    ICW.ICWHeader(lngSessionID)
%>

			</td>
		</tr>
		<tr>
			<td>
			
<OBJECT 
					id=objStores 
					style="left:0px;top:0px;width:100%;height:100%"
					codebase="../../../ascicw/cab/HEdit.cab" 
					component="launcher.ocx"
					classid=CLSID:E3487242-8DFE-4108-AE95-FB49894A97F5 VIEWASTEXT>
					<PARAM NAME="_ExtentX" VALUE="16113">
					<PARAM NAME="_ExtentY" VALUE="11139">
					<SPAN STYLE="color:red">ActiveX control failed to load! -- Please check browser security settings.</SPAN>
				</OBJECT>

			</td>
		</tr>
	</table>

</body>
</html>
