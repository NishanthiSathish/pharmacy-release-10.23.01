<%@ Page language="vb" %>

<%@ Import Namespace="Ascribe.Common.ICW" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>
<%
    Dim objEntityRead As ENTRTL10.EntityRead
%>
<%
    Dim lngSessionID As Integer
    Dim lngRequestID As Integer 
    Dim lngEntityID As Integer 
    Dim strPatientName As String 
    Dim strPatientDOB As String
    Dim strPrescription As String 
    Dim strDispensingDate As String 
    Dim strDispensingTime As String
    Dim strDispensingDescription As String 
    Dim lngDispensingQty As Integer 
    Dim xmlDoc As XmlDocument 
    Dim xmlElement As XmlElement
    Dim xmlNodeList As XmlNodeList
    Dim xmlNode As XmlNode
    Dim objDispensingRead As LEGRTL10.DispensingRead
    Dim objOrderCommsItemRead As OCSRTL10.OrderCommsItemRead
    Dim strReturn_XML As String 
%>
<%
    '
    'DispensingRecord.aspx
    '
    'Displays details of dispensing date, time, details and quantity for a given requestid
    '
    'Input:	SessionID
    'RequestID
    '
    '26Sep07 ST	    Written
    '23Sep09 Rams   Fixed F0064199 and Implemented System.XML as well.
%>



<html>
<head>
<title>Dispensing Record</title>
<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<base target="_self">
</head>

<%
    'Query string vars
    'Page vars
    
    strPatientName = ""
    strPatientDOB = ""
    strPrescription = ""
    strDispensingDate = ""
    strDispensingTime = ""
    strDispensingDescription = ""
    lngDispensingQty = 0
    'General vars
    strReturn_XML = ""
    lngSessionID = CInt(Request.QueryString("SessionID"))
    lngRequestID = CInt(Request.QueryString("RequestID"))
    'Get the current patient EntityID from state
    objEntityRead = new ENTRTL10.EntityRead()
    lngEntityID = objEntityRead.GetSelectedEntity(lngSessionID)
    'Then read the patient information
    strReturn_XML = CStr(objEntityRead.PatientDetailByEntityIDXML(lngSessionID, lngEntityID))
    objEntityRead = Nothing
    xmlDoc = New XmlDocument()
    xmlDoc.TryLoadXml(strReturn_XML)
    xmlNode = xmlDoc.selectSingleNode("//Patient")
    If Not (xmlNode) Is Nothing Then 
        If Not xmlNode.Attributes("Title").Equals(DBNull.Value) AndAlso xmlNode.Attributes("Title").Value.ToString() <> "" Then
            strPatientName = xmlNode.Attributes("Title").Value & " "
        End If
        strPatientName = strPatientName & xmlNode.Attributes("Forename").Value & " " & xmlNode.Attributes("Surname").Value
        '23Sep09    Rams    F0064199 - Dispensing Record Daob is not displaying on DOB and displays with the Patient Name
        '13Jan10    JMei    F0074344 - check if "DOB" Exist first
        If xmlNode.Attributes("DOB") isNot Nothing then
            If Not xmlNode.Attributes("DOB").Equals(DBNull.Value) AndAlso xmlNode.Attributes("DOB").Value.ToString() <> "" Then
                'strPatientDOB = TDate2Date(CStr(xmlNode.getAttribute("DOB")))
                strPatientDOB = Date.Parse(xmlNode.Attributes("DOB").Value).ToString("dd/MM/yyyy")
            End If
        End If

    End If
    xmlNode = Nothing
    xmlDoc = Nothing
    'Get our prescription data
    objOrderCommsItemRead = new OCSRTL10.OrderCommsItemRead()
    strReturn_XML = objOrderCommsItemRead.GetRequestCore_XML(lngSessionID, CInt(lngRequestID))
    objOrderCommsItemRead = Nothing
    xmlDoc = New XmlDocument
    xmlDoc.TryLoadXml(strReturn_XML)
    xmlNode = xmlDoc.selectSingleNode("//Request")
    If Not (xmlNode) Is Nothing Then strPrescription = xmlNode.Attributes("Description").Value.ToString()
    '
    xmlNode = Nothing
    xmlDoc = Nothing
    'Query server for our data
    objDispensingRead = new LEGRTL10.DispensingRead()
    strReturn_XML = objDispensingRead.DispensingListByPrescription(lngSessionID, CInt(lngRequestID))
    objDispensingRead = Nothing
%>
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=lngSessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "DispensingRecord.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>


<body id="bdy" sid="<%= lngSessionID %>">
<br>
<table width="100%" cellpadding="5" cellspacing="5" border="0" style="font-family:Arial;font-size:16px;color:#000000;">
	<tr valign="top">
		<td align="left" colspan="2" style="font-weight:Bold;font-size:24px;">Dispensing Record</td>
	</tr>
	<tr valign="top">
		<td colspan="2"><p>&nbsp;</p></td>
	</tr>
	<tr valign="top">
		<td style="font-weight:Bold;" width="20%">Patient :</td>
		<td align="left" width="80%"><%= strPatientName %></td>
	</tr>
	<tr valign="top">
		<td style="font-weight:Bold;" width="20%">Date of Birth :</td>
		<td align="left" width="80%"><%= strPatientDOB %></td>
	</tr>

	<tr valign="top">
		<td style="font-weight:Bold;">Prescription :</td>
		<td><%= strPrescription %></td>
	</tr>
	<tr style="width:100%">
		<td colspan="2">
			<table width="100%" cellpadding="1" cellspacing="1" border="1" bgcolor="#FFFFFF" style="font-family:Arial;font-size:14px;color:#000000;">
<%
    'Load our returned data into the dom and display on the page
    xmlDoc = New XmlDocument()
    xmlDoc.TryLoadXml(strReturn_XML)
    xmlNodeList = xmlDoc.selectNodes("//D")
    If Not (xmlNodeList) Is Nothing Then 
%>

					<tr style="font-weight:bold">
						<td width="20%" style="text-align:center">Date</td>
						<td width="60%" style="text-align:center">Details</td>
						<td width="20%" style="text-align:center">Qty</td>
					</tr>
<%
        'Loop through the data and put a row in for each one found
        For Each xmlElement In xmlNodeList
        '23Sep09    Rams    F0064199 - Commented below and now the StrDispensingDate is the onlyfield that carries the data
        'strDispensingDate = TDate2Date(CStr(xmlElement.getAttribute("LastDate")))
        'strDispensingTime = TDate2Time(xmlElement.getAttribute("LastDate"))
        '
        '23Sep09    Rams   Lastdate is of length 8 in the db and this cannot hold the time.. 
        strDispensingDate = Date.Parse(xmlElement.GetAttribute("LastDate")).ToString("dd/MM/yyyy")
        'strDispensingTime = DateTime.Parse(xmlElement.GetAttribute("LastDate")).ToString("HH:mm:ss")
        strDispensingDescription = xmlElement.GetAttribute("Text").ToString()
        'lngDispensingQty  = CInt(xmlElement.getAttribute("DispensedQty"))
        lngDispensingQty = CInt(xmlElement.GetAttribute("LastQty"))
%>
				<tr>
						<%--<td><%= strDispensingDate %>&nbsp;<%= strDispensingTime %></td>--%>
						<td><%=strDispensingDate%></td>
						<td><%=strDispensingDescription%></td>
						<td style="text-align:right"><%=lngDispensingQty%></td>
				</tr>

<%
        Next
%>
			</table>
		</td>
	</tr>
<%
    Else
%>

	<tr>
		<td colspan="2" style="font-weight:Bold;font-size:18px;" align="center">No Dispensings Recorded</td>
	</tr>
<%
    End IF
    xmlNodeList = Nothing
    xmlDoc = Nothing
    xmlElement = Nothing
%>

</table>
<br><br>
<div align="center" style="font-family:Arial;font-size:14px;color:#000000;"><a href="javascript:window.close();">Click here to close this window</a></div>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
