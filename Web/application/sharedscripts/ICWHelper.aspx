<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import namespace="Ascribe.Common.WebVersion" %>
<%@ Import Namespace="GENRTL10" %>
<%
    Dim Mode As String = String.Empty
    Dim SessionID As Integer = 0
    
    Mode = CStrX(Request.QueryString("Mode"))
    SessionID = CIntX(Request.Form("sessionID"))
    
    Select Case Mode
        Case "ICWGetSetting"
            If CStrX(Request.Form("role")) = String.Empty Then
                Response.Write(New SettingRead().GetValue(SessionID, CStrX(Request.Form("system")), CStrX(Request.Form("section")), CStrX(Request.Form("key")), CStrX(Request.Form("defaultvalue"))))
            Else
                Response.Write(New SettingRead().GetValueForRole(SessionID, CStrX(Request.Form("system")), CStrX(Request.Form("section")), CStrX(Request.Form("key")), CStrX(Request.Form("defaultvalue")), CIntX(Request.Form("role"))))
            End If
        Case "WebVersion"
            Response.Write(Build())
    End Select
%>
