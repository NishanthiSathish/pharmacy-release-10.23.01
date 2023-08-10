Attribute VB_Name = "FTP"
Option Explicit
DefInt A-Z


Const Module$ = "FTP.BAS"
Const ErrTitle = "FTP"

Function FTPError$(FTP As Control, ErrNo%)

   Select Case ErrNo%
      Case 20103
         FTPError$ = "The RemoteHost address is invalid (0.0.0.0). "
      Case 20302
         FTPError$ = "Operation interrupted."
      Case 20303
         FTPError$ = "Can't open local file."
      Case 20142
         FTPError$ = "FTP protocol error. The error message contains the server reply. "
      Case 20143
         FTPError$ = FTP.LastReply
      Case 20144
         FTPError$ = "Busy performing current action."
      Case 20145
         FTPError$ = "Local file error. Error description contains detailed information."
      Case 20146
         FTPError$ = "Can't open LocalFile for reading."
      Case 20302
         FTPError$ = "Data interface error. Error description contains detailed information."
      Case 20303
         FTPError$ = "Accept failed for data connection."
      Case Else
         FTPError$ = "Asynchronous select failed for data connection."
   End Select

End Function

Function FTPErrorHandler(FTPCtrl As Control, ErrNo) As String

Dim msg$

   msg$ = ""
   Select Case ErrNo
      Case 20103, 20302, 20303, 20142 To 20146, 20148, 20302 To 20303
         msg$ = msg$ & FTPError$(FTPCtrl, Err)
      Case 25049 To 25072, 25092 To 25094, 26002 To 26005
         msg$ = msg$ & WinsockError$(Err)
      Case Else
         msg$ = msg$ & Error$(Err)
      End Select

   FTPErrorHandler$ = msg$

End Function

Function FTPLogoff(Ctrl As Control, SvrReply$) As Integer

   FTPLogoff = True

   On Error Resume Next
   Ctrl.Action = 3
   On Error GoTo 0
   SvrReply$ = Ctrl.LastReply

   Ctrl.WinsockLoaded = False

End Function

Function FTPLogon(Ctrl As Control, IPAddr$, UsrName$, Passwd$, ServerReply$) As Integer

Const procname$ = "FTPLogon"
Dim ErrMsg$

   Screen.MousePointer = HOURGLASS
   FTPLogon = True
   Ctrl.WinsockLoaded = True
   If Not Ctrl.WinsockLoaded Then
         Screen.MousePointer = STDCURSOR
         ServerReply$ = "Failed to initialise FTP Control - Please reboot this machine."
         FTPLogon = False
         Exit Function
      End If

   Ctrl.RemoteHost = IPAddr$
   
   Ctrl.User = UsrName$
   Ctrl.Password = Passwd$

   On Error GoTo FTPLogon_err
   Ctrl.Action = 2
   On Error GoTo 0
   If Trim$(ServerReply$) = "" Then ServerReply$ = Ctrl.LastReply
   Screen.MousePointer = STDCURSOR

Exit Function

FTPLogon_err:

   ServerReply$ = FTPErrorHandler(Ctrl, Err)
   FTPLogon = False
   Resume Next

End Function

Sub FTPSend(Ctrl As Control, LocalFile$, RemoteFile$, ServerReply$, DeleteLocalFile%)

Dim SentOk%

   SentOk = True
   On Error GoTo FTPSend_Err
   Ctrl.LocalFile = LocalFile$
   Ctrl.RemoteFile = RemoteFile$
   Ctrl.Action = 5                        'Upload
   ServerReply$ = Ctrl.LastReply
   On Error GoTo 0

   If DeleteLocalFile And SentOk Then Kill LocalFile$

Exit Sub

FTPSend_Err:
   SentOk = False
   Resume Next
End Sub

