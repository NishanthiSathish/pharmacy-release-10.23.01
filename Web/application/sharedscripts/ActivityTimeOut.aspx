<%@ Page Language="VB" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<!DOCTYPE html>

 <script language="javascript" type="text/javascript">
    
     function showDisplay(v10Location,sessionId, secondTimeOutValueInSeconds) {
         var url = v10Location +"application/ICW/SessionTimeOutModal.aspx?SessionID=" + sessionId + "&secondSessionTimeOut=" + secondTimeOutValueInSeconds;
         var result = window.showModalDialog(url, window.self, "dialogHeight: " + 400 + "px; dialogWidth: " + 600 + "px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: no; status: No; ");
         
         if (result == null || result == 'logoutFromActivityTimeout') {
             //alert('test' + deskTopName);
             inactivityTimeout_exit();
         }
         
     }

     function inactivityTimeout_exit() {
         try {
             sessionStorage.setItem('logoutFromActivityTimeout', 'true');
             window.returnValue = 'logoutFromActivityTimeout';
             window.close();
             window.parent.close();
             // Depending on where you are in the HAP the script may need little hand to help find Exit 
             if (window.parent.ICWWindow() != null)
                 window.parent.ICWWindow().Exit();

         }
         catch (err) {
             var txt = "There was an error on this page.\n\n";
             txt += "Error description: " + err.message + "\n\n";
             txt += "Click OK to continue.\n\n";
             alert(txt);
         }
     }
 </script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
   <%
       Dim sessionId As Integer
       'Dim sessionToken As String
       Dim oTransport As New TRNRTL10.Transport()
       Dim objSettingRead As GENRTL10.SettingRead
       Dim isSessionActive As Boolean
       Dim timeoutDurations As String = String.Empty
       Dim secondTimeOutValue As Integer
       Dim TimeOutValue As Integer
       Dim DiffValue As Integer
       Dim v10Location As String = String.Empty
       Dim deskTopName As String = String.Empty
       Dim closeWindow As String = String.Empty

       sessionId = CInt(Request.QueryString("SessionID"))
       'closeWindow = Request.QueryString("closeWindow")
       'MessageBox.Show(closeWindow)
       ' sessionToken = Request.QueryString("SessionToken")
       'MessageBox.Show("sessionID " + sessionId.ToString())
       'Using Scope As New ICWTransaction(ICWTransactionOptions.ReadCommited)
       If (sessionId > 0) Then
           isSessionActive = oTransport.ValidateSessionActive(sessionId)
           If isSessionActive = False Then
               'MessageBox.Show("output" + output1.ToString())
               'ScriptManager.RegisterStartupScript(Me, Page.GetType, "Script", "showDisplay();", True)
               'deskTopName = Request.QueryString("deskTopName")
               objSettingRead = New GENRTL10.SettingRead()
               timeoutDurations = objSettingRead.GetValue(_Shared.udtConsts.SECURITY_SESSION_ID, "ICW", "InactivityTimeout", "TimeoutDurations", "")
               objSettingRead = Nothing
               If timeoutDurations.Length > 0 Then
                   Dim timeoutDurationLength As Integer = 0
                   Dim CharPosition As Integer = 0
                   timeoutDurationLength = timeoutDurations.Length
                   CharPosition = timeoutDurations.IndexOf(":") + 1
                   TimeOutValue = CInt(Trim(timeoutDurations.Substring(0, CharPosition - 1)))
                   secondTimeOutValue = CInt(Trim(timeoutDurations.Substring(CharPosition, timeoutDurationLength - CharPosition)))
                   DiffValue = (secondTimeOutValue - TimeOutValue) / 1000
                   v10Location = System.Configuration.ConfigurationManager.AppSettings("ICW_Location") + "/"
                   'MessageBox.Show("v10Location" + v10Location.ToString())
               End If
               Response.Write("<script language=javascript>showDisplay('" & v10Location & "'," & sessionId & "," & DiffValue & ");</script>")
               'Else
               '    MessageBox.Show("output1" + output1.ToString())
               '    objSettingRead = New GENRTL10.SettingRead()
               '    timeoutDurations = objSettingRead.GetValue(_Shared.udtConsts.SECURITY_SESSION_ID, "ICW", "InactivityTimeout", "TimeoutDurations", "")
               '    objSettingRead = Nothing
               '    If timeoutDurations.Length > 0 Then
               '        Dim timeoutDurationLength As Integer = 0
               '        Dim CharPosition As Integer = 0
               '        timeoutDurationLength = timeoutDurations.Length
               '        CharPosition = timeoutDurations.IndexOf(":") + 1
               '        TimeOutValue = CInt(Trim(timeoutDurations.Substring(0, CharPosition - 1)))
               '        secondTimeOutValue = CInt(Trim(timeoutDurations.Substring(CharPosition, timeoutDurationLength - CharPosition)))
               '        DiffValue = (secondTimeOutValue - TimeOutValue) / 1000
               '    End If
               '    Response.Write("<script language=javascript>showDisplay(" & sessionId & "," & DiffValue & ");</script>")

           End If
       End If
       'If closeWindow = "1" Then
       '    MessageBox.Show("true1")
       '    Response.Write("<script language=javascript>inactivityTimeout_exit();</script>")
       'End If
%>
</head>    
</html>
