<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.ICWCookie" %>

<%
    Dim lngSessionID As Long 
    Dim lngEpisodeID As Long 
	Dim objStateRead As GENRTL10.StateRead
	Dim objState As GENRTL10.State
    Dim lngCookieID As Double 
    Dim strAscribeSiteNumber As String 
    'Dim strApplicationPath As String 
    'Dim strStoresPass As String 
    'Dim strWardPass As String 
    Dim strCommand As String 
    Dim strURLtoken As String
    Dim strMode as String
    Dim strLock as String
    Dim objSettingRead As GENRTL10.SettingRead
    Dim strURLScheme As String
    Dim intPOrtNumber As Integer
%>
<%
    '---------------------------------------------------------------------------------------------
    '
    'ICW_IDispensing.aspx
    '
    'ICW web application wrapper for the "web-based" Dispense control.
    '
    'ICW Parameters: AscribeSiteNumber
    '
    '14May12 TH Added Log Locking (TFS 27611)
%>

<%
    lngSessionID = Generic.CLngX(Request.QueryString("SessionID"))
    strAscribeSiteNumber = Trim(ICW.ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", ""))
    strCommand = Trim(ICW.ICWParameter("Mode", "Launch Mode", ""))
    strMode = Trim(ICW.ICWParameter("Mode", "V = View, E = Edit", "E"))
    strLock = LCase(Trim(ICW.ICWParameter("Lock_To_Site", "Lock To Site Number", "No,Yes")))
    If Generic.CLngX(strAscribeSiteNumber) <= 0 Then 
        Response.Write("<html><body>Must specify a 3-digit site number during desktop configuration.</body></html>")
        Response.End()
    End IF
    objStateRead = new GENRTL10.StateRead()
    lngEpisodeID = CLng(objStateRead.GetKey(CInt(lngSessionID), "Episode"))
	objStateRead = Nothing

	lngCookieID = GetCookieID(lngSessionID)
	If lngCookieID = -1 Then
		'Create cookie because it doesnt exist
		lngCookieID = CreateCookie(lngSessionID)
	End If

    objState = new GENRTL10.State()
    objState.SetKey(CInt(lngSessionID), "Cookie", CInt(lngCookieID))
    objState = Nothing
    
    '29Sep15 TH Added Overlay for URL scheme for call back (TFS 130427)
    '8June20 AS Added port number for web transport layer
    objSettingRead = New GENRTL10.SettingRead()
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
<title>Stores</title>
<script src="../sharedscripts/icw.js"></script>
<script src="script/PNPrintEditor.js"></script>

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
	CookieID="<%= lngCookieID %>"
	AscribeSiteNumber="<%= strAscribeSiteNumber %>"
	Mode="<%= strMode %>"
	Locked="<%= strLock %>"
	URLtoken="<%= strURLtoken %>"
	onload="return window_onload()"
	style="BACKGROUND-COLOR:white"
>

	<table width="100%" height="100%" cellpadding=0 cellspacing=0 style="BACKGROUND-COLOR:white">	
		<tr height="1%">
			<td>
<%
    ICW.ICWHeader(lngSessionID)
%>

			</td>
		</tr>
		<tr  width="100%" height="94%" style=" BACKGROUND-COLOR:white">
			<td style=" BACKGROUND-COLOR:white">
				<img style="position: absolute; z-index: 0; top:0;right:0" galleryimg="no" align="right" src="../../images/splash.gif" height="100%">
				<!--<img id="image1" galleryimg="no" align="right" src="../../../ascicw/images/splash.gif">
				<img id="image2" galleryimg="no" style="position: absolute; display: none; visibility: hidden;" src="../../../ascicw/application/default/images/ascribe.jpg" WIDTH="510" HEIGHT="229">-->


			</td>
		</tr>
		<tr height="5%" style="BACKGROUND-COLOR:white">
			
			
			<td style=" BACKGROUND-COLOR:white">
				
			
                <OBJECT 
					id=objPN 
					style="left:0px;top:0px;width:0px;height:0px"
					codebase="../../../ascicw/cab/HEdit.cab" 
					component="PNCtl.ocx"
					classid=CLSID:0BDAD488-98F3-45D4-A424-ADBDFBF12E18 VIEWASTEXT>
					<PARAM NAME="_ExtentX" VALUE="16113">
					<PARAM NAME="_ExtentY" VALUE="11139">
					<SPAN STYLE="color:red">ActiveX control failed to load! -- Please check browser security settings.</SPAN>
				</OBJECT>
				
			</td>
		</tr>
	</table>
</body>
</html>
