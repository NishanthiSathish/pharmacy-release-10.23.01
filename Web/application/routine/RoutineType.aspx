<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import namespace="Ascribe.Xml" %>
<% 
 Response.Buffer = true 
 Response.Expires = -1 
 Response.CacheControl = "No-cache" 
 %>


<%
    Dim strRoutineTypes_XML As String  
    Dim xmlDoc As XmlDocument
    Dim xmlNodeList As XmlNodeList
    Dim xmlNode As XmlElement
%>
<%
    Dim lngSessionID As Integer
    Dim lngRoutineTypeID As Integer 
    Dim objMetaDataRead As ICWDTL10.MetaDataRead
    Dim lngIndex As Integer
%>
<%
    lngSessionID = CInt(Request.QueryString("SessionID"))
    Ascribe.Common.Security.ValidatePolicy(lngSessionID, "Routine Administration")
%>


<html>
<head>
<title>Routines</title>


<SCRIPT ID=clientEventHandlersJS LANGUAGE=javascript>
<!--

function window_onload()
{
	fraMain.navigate("RoutineList.aspx?SessionID=" + txtSessionID.value + "&RoutineTypeID=" + cboRoutineType.children(cboRoutineType.selectedIndex).attributes("id") );
}

function cboRoutineType_onchange()
{
	fraMain.navigate("RoutineList.aspx?SessionID=" + txtSessionID.value + "&RoutineTypeID=" + cboRoutineType.children(cboRoutineType.selectedIndex).attributes("id") );
}

//-->
</SCRIPT>
<link rel="stylesheet" type="text/css" href="../../style/application.css" />
</head>

<body onselectstart="event.returnValue=false" oncontextmenu="return false" id="body" onload="return window_onload()"  oncontextmenu="return false">

<table width=100% height=100%>
<tr height=50>
<td>

<input type="hidden" id=txtSessionID name=txtSessionID value="<%
    Response.Write(lngSessionID)
%>
">

List Routines of type:&nbsp;<select id=cboRoutineType name=cboRoutineType LANGUAGE=javascript onchange="return cboRoutineType_onchange()">
<%
    lngRoutineTypeID = CInt(Request.QueryString("RoutineTypeID"))
    objMetaDataRead = new ICWDTL10.MetaDataRead()
    strRoutineTypes_XML = "<DATA>" & objMetaDataRead.RoutineTypeListXML(lngSessionID) & "</DATA>"
    '<RoutineType RoutineTypeID="1" Description="Function"/><RoutineType RoutineTypeID="2" Description="Stored procedure"/>
    objMetaDataRead = Nothing
    xmlDoc = new XmlDocument()
    xmlDoc.TryLoadXml(strRoutineTypes_XML)
    xmlNodeList = xmlDoc.SelectNodes("//RoutineType")
    For lngIndex = 0 To xmlNodeList.Count() - 1
        xmlNode = xmlNodeList(lngIndex)
        If lngRoutineTypeID = 0 Then 
            lngRoutineTypeID = CInt(xmlNode.Attributes.GetNamedItem("RoutineTypeID").InnerXml)
        End IF
        If xmlNode.Attributes.GetNamedItem("Description").InnerXml = Request.Form("cboRoutineType") Then 
            lngRoutineTypeID = CInt(xmlNode.Attributes.GetNamedItem("RoutineTypeID").InnerXml)
        End IF
%>


<option ID='<%
        Response.Write(xmlNode.Attributes.GetNamedItem("RoutineTypeID").InnerXml)
%>
' ><%
        Response.Write(xmlNode.Attributes.GetNamedItem("Description").InnerXml)
%>
</option>
<%
    Next
%>

</select>

</td>
</tr>

<tr>
<td>
<iframe application=yes id='fraMain' width=100% height=100% >
</iframe>
</td>
</tr>
</table>

</body>
</html>
