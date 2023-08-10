<%@ Page Language="VB" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Ascribe.Xml" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">   
<%
    'MM-2848 -Inactivity TimeOut
    'CheckSessionExists.aspx to validate the session for pharmacy desktop
    Dim sessionId As Integer
    'Dim sessionToken As String
    Dim oTransport As New TRNRTL10.Transport()
    Dim isSessionActive As Boolean
    Dim timeoutDurations As String = String.Empty
    sessionId = CInt(Request.QueryString("SessionID"))
    'Using Scope As New ICWTransaction(ICWTransactionOptions.ReadCommited)
    If (sessionId > 0) Then
        isSessionActive = oTransport.ValidateSessionID(sessionId)
    End If
%>
</head>    
</html>
