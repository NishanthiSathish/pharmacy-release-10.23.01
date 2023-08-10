<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="OCSRTL10" %>
<%
    Dim SessionID As Integer
    Dim GUID As String
    Dim DataDoc As New XmlDocument()
    Dim Result As String = "0"

    SessionID = Integer.Parse(Request.QueryString("SessionID"))
    GUID = Request.QueryString("GUID")
    
    If Not String.IsNullOrEmpty(GUID) Then
        Dim mhaForm As MHAForm = New MHAForm()
        Result = mhaForm.AddOrderEntryAttributeForVID(SessionID, GUID)
    End If
    
    Response.Write(Result)
%>
