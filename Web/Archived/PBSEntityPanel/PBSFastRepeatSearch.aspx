<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>

<%
    Dim objSetting As Object 
    Dim objStateRead As Object 
    Dim objState As Object ' GENRTL10.State
    Dim objOCSRTL As Object ' OCSRTL10.PrescriptionRead
    Dim xmlDoc As XmlDocument
    Dim xmlNode As XmlElement
    Dim lngSessionID As Long 
    Dim lngEpisodeID As Long 
    Dim lngRequestID As Long 
    Dim strReturn_XML As String 
    Dim strFastRepeat As String 
%>
<%
    '---------------------------------------------------------------------------------------------
    '
    'PBSFastRepeatSearch.aspx
    '
    'QueryString Parameters
    'SessionID				- SessionID
    '
    '
    'Modification History:
    '10May07 ST Written
%>

<%
    'Get our sessionid from the querystring
    lngSessionID = Generic.CLngX(Request.QueryString("SessionID"))
    'Have we got a number to search on?
    'If Request.Form.GetValues("txtFastRepeatNumber").Length > 0 Then
    '19-11-2007 JA Error code 85 -replace with Is Nothing check 
    If Not Request.Form.GetValues("txtFastRepeatNumber") Is Nothing Then
        strFastRepeat = Request.Form("txtFastRepeatNumber")
        'try to find the record in the db
        objOCSRTL = new OCSRTL10.PrescriptionRead()
        strReturn_XML = objOCSRTL.GetEpisodeOrderIDByEpisodeOrderAliasXML(lngSessionID, strFastRepeat, "EpisodeOrderLookup")
        '19Jun08 ST Commented out as per 9.13 merges
        'strReturn_XML = objOCSRTL.GetEpisodeOrderIDByEpisodeOrderAliasXML(CInt(lngSessionID), strFastRepeat, "PBSFastRepeat")
        objOCSRTL = Nothing
        'we should get something back like this
        '<root><EpisodeOrder RequestID="26" EpisodeID="6"/></root>
        If strReturn_XML <> "<root></root>" Then 
            'we have some details so grab the values
            xmlDoc = new XmlDocument()
            xmlDoc.loadXML(strReturn_XML)
            xmlNode = xmlDoc.selectSingleNode("//EpisodeOrder")
            If Not (xmlNode Is Nothing) Then 
                lngRequestID = Generic.CLngX(xmlNode.getAttribute("RequestID"))
                lngEpisodeID = Generic.CLngX(xmlNode.getAttribute("EpisodeID"))
            End IF
            xmlNode = Nothing
            xmlDoc = Nothing
            objState = new GENRTL10.State()
            objState.SetKey(CInt(lngSessionID), "Prescription", CInt(lngRequestID))
            objState.SetKey(CInt(lngSessionID), "Episode", CInt(lngEpisodeID))
            objState = Nothing
            'set our return value and close the window
            Response.Write("<script language=javascript>")
            Response.Write("window.returnValue=" & lngEpisodeID & ";")
            Response.Write("window.close();")
            Response.Write("</script>")
        End IF
    End IF
%>


<html>
<head>
<title>PBS Fast Repeat Number Search</title>
<link rel="stylesheet" type="text/css" href="../../style/application.css">
<script src="script/PBSFastSearch.js"></script>
</head>

<body id=bdy SessionID="<%= lngSessionID %>" scroll="no" onload="return window_onload()">

<form id="frmSave" name="frmSave" action="<%= ICW.ICWURL("../PBSEntityPanel/PBSFastRepeatSearch.aspx?SessionID=" & lngSessionID) %>" method="POST">
<table cellpadding="2" cellspacing="2" border="1" width="100%">
	<tr>
		<td>
			<table cellpadding="2" cellspacing="2" border="0" width="100%">
				<tr>
					<td style="font-family:trebuchet ms, arial, helvetica; font-size:14px;">Enter the prescription fast repeat number in the box below.</td>
				</tr>
				<tr>
					<td><p>&nbsp;</p></td>
				</tr>
				<tr>
					<td style="font-family:trebuchet ms, arial, helvetica; font-size:14px;">Fast Repeat Number:&nbsp;&nbsp;&nbsp;
					<input type="text" id="txtFastRepeatNumber" name="txtFastRepeatNumber" size="20" maxlength="15">&nbsp;&nbsp;&nbsp;
					<button type="button" id="btnSearch" LANGUAGE="javascript" onclick="frmSave.submit();" ACCESSKEY=""S""><u>S</u>earch</button>
					</td>
				</tr>
				<tr>
					<td><p>&nbsp;</p></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br><br>
<div align="right">
	<button type="button" id="btnCancel" LANGUAGE="javascript" onclick="return window.close();" ACCESSKEY=""C""><u>C</u>ancel</button>&nbsp;&nbsp;&nbsp;&nbsp;
</div>
</form>
</body>
</html>
