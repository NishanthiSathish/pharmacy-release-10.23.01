<%@ Page language="vb" ValidateRequest="false"%>

<%
    Dim setting As String
    Dim strReturn As String
    
    strReturn = ""
    
    setting = CStr(Request.QueryString("Setting"))
    
    If Not String.IsNullOrEmpty(System.Configuration.ConfigurationManager.AppSettings(setting)) Then
        strReturn = System.Configuration.ConfigurationManager.AppSettings(setting)
    End If
    
    Response.Write(strReturn)
%>

