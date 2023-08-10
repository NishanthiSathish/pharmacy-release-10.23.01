<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Xml" %>
<%
    Dim strReturn As String  
%>
<%
    Dim objRequestTypeRead As OCSRTL10.RequestTypeRead
    Dim xmlDOM As XmlDocument
    Dim xmlElement As XmlElement
    Dim strReturn_XML As String
    Dim lngSessionID As Integer
    Dim lngRequestTypeID As String 
%>
<%
    '
    '22Aug07 ST				RequestTypeOrderFrequency.aspx
    '
    'Called from TaskPicker2.js to retrieve the orderingfrequency value
    'for the given requesttypeid
    strReturn_XML = ""
    lngSessionID = CInt(Request.QueryString("SessionID"))
    lngRequestTypeID = Request.QueryString("RequestTypeID")
    objRequestTypeRead = new OCSRTL10.RequestTypeRead()
    strReturn_XML = objRequestTypeRead.GetByID(lngSessionID, CInt(lngRequestTypeID))
    objRequestTypeRead = Nothing
    If CStr(strReturn_XML) <> "" Then 
        xmlDOM = New XmlDocument()
        Dim xmlLoaded As Boolean
        
        Try
            xmlDOM.LoadXml(CStr(strReturn_XML))
            xmlLoaded = True
        Catch ex As Exception
        End Try
        
        If xmlLoaded Then
            xmlElement = xmlDOM.SelectSingleNode("*")
            strReturn_XML = xmlElement.GetAttribute("OrderingFrequency")
            xmlDOM = Nothing
        Else
            strReturn = ""
        End If
    End IF
    Response.Write(strReturn_XML)
%>

