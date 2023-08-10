<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.ICWCookie" %>
<%
    Dim lngSessionID As Long 
    Dim lngProductID As Long 
    'Dim objStateRead As GENRTL10.StateRead
	Dim objState As GENRTL10.State
    Dim lngCookieID As Double 
    Dim strAscribeSiteNumber As String 
    Dim strURLtoken As String
    Dim strURLScheme As String
    Dim objSettingRead As GENRTL10.SettingRead
    Dim intPOrtNumber As Integer
%>
<%
    '---------------------------------------------------------------------------------------------
    '
    'ICW_PharmacyProductEditor.aspx
    '
    'ICW web application wrapper for the PharmacyProductEditor OCX
    '
    'ICW Parameters: AscribeSiteNumber
    '
    'Modification History:
    '04Jul05 TH Created
%>

<%
    lngSessionID = Generic.CLngX(Request.QueryString("SessionID"))
    strAscribeSiteNumber = Request.QueryString("AscribeSiteNumber")
    'Response.Write "<html><body>" + strAscribeSiteNumber + "</body></html>"
    If Generic.CLngX(strAscribeSiteNumber) <= 0 Then 
        strAscribeSiteNumber = Trim(ICW.ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", ""))
    End IF
    'strAscribeSiteNumber = Trim(ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", ""))
    If Generic.CLngX(strAscribeSiteNumber) <= 0 Then 
        Response.Write("<html><body>Must specify a 3-digit site number during desktop configuration.</body></html>")
        Response.End()
    End IF
    lngProductID = Generic.CLngX(Request.QueryString("ProductID"))
    'Set objStateRead = server.CreateObject("GENRTL10.StateRead")
    'lngEpisodeID = Clng(objStateRead.GetKey(lngSessionID, "Episode"))
    'Set objStateRead = nothing
    
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
<title>Pharmacy Product Editor</title>
<link rel="stylesheet" type="text/css" href="../../style/application.css">

<script src="../sharedscripts/icw.js"></script>
<script src="script/PharmacyProductEditor.js"></script>

<!--
//===============================================================================
//									ICW EventListeners
//===============================================================================

-->
<SCRIPT ID=clientEventHandlersJS LANGUAGE=javascript>

function EVENT_ProductSelected(ProductID)
{
	var strURL = '../PharmacyProductEditor_Old/ICW_PharmacyProductEditor_Old.aspx'
				  + '?SessionID=<%= lngSessionID %>'
				  + '&ProductID=' + ProductID
				  + '&AscribeSiteNumber=<%= strAscribeSiteNumber %>'
	
	window.navigate(ICWURL(strURL));
}

// 54169 Disable activity monitor for product ediotr, as popup not handled by monitor
// THIS CAN BE REMOVED IN THE REWRITE
function EVENT_InitialiseCompleted()
{
    ICWWindow().SuspendTimeout(); 
}
</SCRIPT>
<!--
//===============================================================================
//									ICW Raised Events
//===============================================================================


//-->



</head>

<body id="bdy" 
	SessionID="<%= lngSessionID %>" 
	ProductID="<%= lngProductID %>"
	CookieID="<%= lngCookieID %>"
	AscribeSiteNumber="<%= strAscribeSiteNumber %>"
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
					id=objPharmacyProductEditor
					style="left:0px;top:0px;width:100%;height:100%"
					codebase="../../../ascicw/cab/HEdit.cab"
					component="productstockeditor.ocx"
					classid=CLSID:FD2132EB-9138-4F59-A07E-DC7F27222781 VIEWASTEXT>
					<PARAM NAME="_ExtentX" VALUE="16113">
					<PARAM NAME="_ExtentY" VALUE="11139">
					<SPAN STYLE="color:red">ActiveX control failed to load! -- Please check browser security settings.</SPAN>
				</OBJECT>

			</td>
		</tr>
	</table>

</body>
</html>
