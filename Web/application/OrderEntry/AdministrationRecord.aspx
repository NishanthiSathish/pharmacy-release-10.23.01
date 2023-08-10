<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common.ICW" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="System.Xml"  %>
<%@ Import Namespace="Ascribe.Xml" %>
<%
    Dim lngSessionID As Integer
    Dim lngRequestID As Integer 
    Dim lngEntityID As Integer 
    Dim strPatientName As String 
    Dim strPatientDOB As Object 
    Dim strPrescription As String 
    Dim strAdministrationDate As String 
    Dim strAdministrationTime As String 
    Dim strAdministrationDescription As String 
    Dim xmlDoc As XmlDocument
    Dim xmlNodeList As XmlNodeList
    Dim xmlNode As XmlNode
    Dim objPrescriptionRead As OCSRTL10.PrescriptionRead
    Dim objOrderCommsItemRead As OCSRTL10.OrderCommsItemRead
    Dim objEntityRead As ENTRTL10.EntityRead
    Dim strReturn_XML As String 
%>
<%
    '
    'AdministrationRecord.aspx
    '
    'Displays details of administration date, time and details for a given requestid
    '
    'Input:	SessionID
    'RequestID
    '
    '26Sep07 ST	Written
%>



<html>
<head>

<title>Administration Record</title>
<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<base target="_self">
</head>

<%
    'Query string vars
    'Page vars
    strPatientName = ""
    strPatientDOB = ""
    strPrescription = ""
    strAdministrationDate = ""
    strAdministrationTime = ""
    strAdministrationDescription = ""
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
    xmlDoc = New XmlDocument
    
    xmlDoc.TryLoadXml(strReturn_XML)
    xmlNode = xmlDoc.SelectSingleNode("//Patient")
    If Not (xmlNode) Is Nothing Then
        If Not (xmlNode.Attributes("Title")) Is Nothing Then
            strPatientName = xmlNode.Attributes("Title").Value + " "
        End If
        
        If Not (xmlNode.Attributes("Title")) Is Nothing Then
            strPatientName += xmlNode.Attributes("Forename").Value + " "
        End If
        
        strPatientName += xmlNode.Attributes("Surname").Value
        
        If (xmlNode.Attributes("DOB")) Is Nothing Then
            strPatientDOB = "Not given"
        Else
			strPatientDOB = Date2ddmmccyy(TDate2Date(CStr(xmlNode.Attributes("DOB").Value)))														'20May08 AE  Format to ddmmccyy for #F0022737
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
    xmlNode = xmlDoc.SelectSingleNode("//Request")
    If Not (xmlNode) Is Nothing Then 
        strPrescription = CStr(xmlNode.Attributes("Description").Value)
    End If
    xmlNode = Nothing
    xmlDoc = Nothing
    'Query server for our data
    '<d AdministeredDate="2007-03-12T00:00:00" AdministeredTime="2001-01-01T15:50:00" Description="Administered"/>
    objPrescriptionRead = new OCSRTL10.PrescriptionRead()
    strReturn_XML = CStr(objPrescriptionRead.AdministrationByRequestIDXML(lngSessionID, lngRequestID))
    objPrescriptionRead = Nothing
%>
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=lngSessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "AdministrationRecord.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>


<body id="bdy" sid="<%= lngSessionID %>">
<br>
<table width="100%" cellpadding="5" cellspacing="5" border="0" style="font-family:Arial;font-size:16px;color:#000000;">
	<tr>
		<td colspan="2" align="left" style="font-weight:Bold;font-size:28px;">Administration Record</td>
	</tr>
	<tr>
		<td colspan="2"><p>&nbsp;</p></td>
	</tr>
	<tr>
		<td width="20%">Patient :</td>
		<td align="left" width="80%"><%= strPatientName %></td>
	</tr>
	<tr>
		<td width="20%">Date of Birth :</td>
		<td align="left" width="80%"><%= strPatientDOB %></td>
	</tr>
	<tr>
		<td width="20%">Prescription :</td>
		<td align="left" width="80%"><%= strPrescription %></td>
	</tr>
<%
    'Load our returned data into the dom and display on the page
    xmlDoc = New XmlDocument
    xmlDoc.TryLoadXml(strReturn_XML)
    xmlNodeList = xmlDoc.SelectNodes("//response")
    If Not (xmlNodeList) Is Nothing And CInt(xmlNodeList.Count) > 0 Then
%>

	<tr>
		<td colspan="2">
			<table cellpadding="2" cellspacing="2" border="1" bgcolor="#FFFFFF" style="font-family:Arial;font-size:14px;color:#000000;">
				<tr bgcolor="#EEEEEE">
					<td width="100">Date</td>
					<td width="100">Time</td>
					<td width="550">Details</td>
				</tr>
<%
        'Loop through the data and put a row in for each one found
    For Each xml_node As XmlNode In xmlNodeList
        strAdministrationDate = CStr(xml_node.Attributes("AdministeredDate").Value)
        strAdministrationTime = CStr(xml_node.Attributes("AdministeredTime").Value)
        strAdministrationDescription = CStr(xml_node.Attributes("Description").Value)

        Response.Write("<tr>")
        Response.Write("<td>" + strAdministrationDate + "</td>")
        Response.Write("<td>" + strAdministrationTime + "</td>")
        Response.Write("<td>" + strAdministrationDescription + "</td>")
        Response.Write("</tr>")
    Next
%>
			</table>
		</td>
	</tr>
<%
    Else
%>

	<tr>
		<td colspan="2" style="font-weight:Bold;font-size:18px;" align="center">No Administrations Recorded</td>
	</tr>
<%
    End IF
    xmlNodeList = Nothing
    xmlDoc = Nothing
%>

</table>
<br><br>
<div align="center" style="font-family:Arial;font-size:14px;color:#000000;"><a href="javascript:window.close();">Click here to close this window</a></div>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
