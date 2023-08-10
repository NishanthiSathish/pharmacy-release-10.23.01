<%@ Page language="vb" ValidateRequest="false"%>

<!--#include file="ASPHeader.aspx"-->
<%
    Dim strMode As String
    Dim strAttribute As String 
    Dim strValue As String 
    Dim lngSessionID As Integer 
    Dim objStream As System.IO.StreamReader
    Dim sessionAttribute As String
%>
<%
    'Supports the javascript SessionAttribute/SessionAttributeSet functions for storing
    'session attributes on the server
    '
    '01May07	CJM	Written
    lngSessionID = CInt(Request.QueryString("SessionID"))
    strMode = Request.QueryString("Mode")
    strAttribute = Request.QueryString("Attribute")
    Select Case LCase(Request.QueryString("Mode"))
    Case "get"
        strValue = Ascribe.Common.Generic.SessionAttribute(lngSessionID, strAttribute)
    Case "set"
        objStream = New System.IO.StreamReader ( Request.InputStream )
        sessionAttribute = objStream.ReadToEnd()
        sessionAttribute = sessionAttribute.Replace("<Attribute>", "")
        sessionAttribute = sessionAttribute.Replace("</Attribute>", "")
        Ascribe.Common.Generic.SessionAttributeSet(lngSessionID, strAttribute, sessionAttribute)
    End Select
    Response.Write(strValue)
%>

