Attribute VB_Name = "modEventNotifierV1"
Option Explicit
DefInt A-Z

Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Public gboolProcessingMessages As Boolean
Public gboolShutdown As Boolean

Public Sub Main()

Dim objConfig As EventNotifierV1.Config
Dim frmMain As EventNotifierV1.frmEventNotifierV1

Dim boolLocked As Boolean

Dim iPosn As Integer
Dim iStartPosn As Integer

Dim sInstanceName As String
Dim sMsg As String


   gboolShutdown = False
   
   App.StartLogging "", vbLogToNT
   App.LogEvent "ICW Event Notifier Initializing...", vbLogEventTypeInformation
   
   iPosn = InStr(1, UCase(Command$), "/INSTANCENAME=", vbBinaryCompare)
   If iPosn = 0 Then
         sMsg = "The instance name has not been passed to the application." & vbCrLf & vbCrLf
         sMsg = sMsg & "Please launch the application using the following syntax:-" & vbCrLf & vbCrLf
         sMsg = sMsg & "<path>\EVENTNOTIFIERV1.EXE /INSTANCENAME=<xxxxx>"
         MsgBox sMsg, vbCritical, App.Comments
         Exit Sub
      Else
         iStartPosn = iPosn + 14
         iPosn = InStr(iStartPosn, UCase$(Command$), Chr$(32), vbTextCompare)
         If iPosn = 0 Then iPosn = Len(Command$)
         sInstanceName = Trim(UCase(Mid(Command$, iStartPosn, iPosn - iStartPosn + 1)))
      End If
   
   App.LogEvent "ICW Event Notifier Started - Instance name = " & sInstanceName, vbLogEventTypeInformation
   Set objConfig = New EventNotifierV1.Config
   
   With objConfig
      .LoadConfig sInstanceName
   
      On Error GoTo ErrorHandler
   
      boolLocked = LockInstanceNameFile(.InstanceName)
      
      If boolLocked Then
      
            Set frmMain = New EventNotifierV1.frmEventNotifierV1
            frmMain.Caption = .SystemTrayToolTipText
            ShowIconInSysTray frmMain, .SystemTrayToolTipText
            
            frmMain.Startup objConfig
         Else
            MsgBox "The ascribe ICW Event Notifier V1 is already running with instance name of '" & .InstanceName & "'" & vbCrLf & vbCrLf & "Cannot run multiple instances - exiting.", vbCritical + vbOKOnly, App.Title
         End If
      
   End With
      
   Do While (Not gboolShutdown) Or gboolProcessingMessages
      Sleep 50
      DoEvents
   Loop
   
Cleanup:

   On Error Resume Next
   
   If Not objConfig Is Nothing Then
      App.LogEvent "ICW Event Notifier Instance " & sInstanceName & " - Logging out", vbLogEventTypeInformation
      objConfig.Logout
      Set objConfig = Nothing
   End If
   
   If Not frmMain Is Nothing Then
      Unload frmMain
      Set frmMain = Nothing
   End If
   
   RemoveIconFromSysTray
   
   App.LogEvent "ICW Event Notifier Instance " & sInstanceName & "  - Exiting", vbLogEventTypeInformation
      
   On Error GoTo 0
   
Exit Sub

ErrorHandler:
   
Dim sErr As String

   sErr = "An error occurred starting the ICWEventNotifierV1 application." & vbCrLf & vbCrLf
   sErr = sErr & "Error Number: " & Format(Err.Number) & vbCrLf
   sErr = sErr & "Error Source: " & Err.Source & vbCrLf
   sErr = sErr & "Error Description: " & Err.Description & vbCrLf
   MsgBox sErr, vbCritical + vbOKOnly, App.Title
   gboolShutdown = True
   Resume Cleanup
   
End Sub

