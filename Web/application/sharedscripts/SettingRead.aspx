<%@ Page language="vb" ValidateRequest="false"%>

<%
    Dim lngSessionID As Integer
    Dim strSystem As String
    Dim strSection As String
    Dim strKey As String
    Dim strReturn As String
    Dim objSettingRead As GENRTL10.SettingRead = New GENRTL10.SettingRead
    
    strReturn = ""
    
    lngSessionID = CInt(Request.QueryString("SessionID"))
    strSystem = CStr(Request.QueryString("System"))
    strSection = CStr(Request.QueryString("Section"))
    strKey = CStr(Request.QueryString("Key"))
    
    strReturn = objSettingRead.GetValue(lngSessionID, strSystem, strSection, strKey, "0")
    Response.Write(strReturn)
%>

