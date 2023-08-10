<%@ Page Language="VB" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>

<%--

This page is used to read the web.config values for the client to make any calls to the server location 
say for example, location of V11
--%>
<%
    Dim Find As String = String.Empty
    
    Find = CStrX(Request.QueryString("Find"))
    
    Select Case Find
        Case "V11Location"
            Response.Write(ConfigurationManager.AppSettings("ICW_V11Location"))
    End Select
%>