VERSION 5.00
Begin VB.UserControl StoresOCX 
   ClientHeight    =   3600
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   4800
   ScaleHeight     =   3600
   ScaleWidth      =   4800
End
Attribute VB_Name = "StoresOCX"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Dim m_ASCribePath As String * 255
Dim m_ASCribeSiteNumber As String * 3
Dim m_ASCribeCommand As String * 255
Dim m_ASCribeExe As String
Dim m_LoadModule As Integer
Dim m_StoresPass As String
Dim m_WardPass As String
Dim m_SessionID As String
Const SW_SHOWMAXIMIZED = 3


'Called Module Windows Handles
Dim m_ASCHndl As Long


Private Const MODULE = "Stores_OCX."
Public Property Get ASCribePath() As String
   ASCribePath = m_ASCribePath
End Property

Public Property Let ASCribePath(ByVal New_ASCribePath As String)
   m_ASCribePath = New_ASCribePath
   ''PropertyChanged "ASCribePath"
End Property
Public Property Get SessionID() As String
   SessionID = m_SessionID
End Property
Public Property Get ASCribeExe() As String
   ASCribeExe = m_ASCribeExe
End Property

Public Property Let ASCribeExe(ByVal New_ASCribeExe As String)
   m_ASCribeExe = New_ASCribeExe
   ''PropertyChanged "ASCribePath"
End Property

Public Property Let SessionID(ByVal New_SessionID As String)
   m_SessionID = New_SessionID
   ''PropertyChanged "ASCribePath"
End Property

Public Property Get ASCribeSiteNumber() As String
   ASCribeSiteNumber = m_ASCribeSiteNumber
End Property

Public Property Let ASCribeSiteNumber(ByVal New_ASCribeSiteNumber As String)
   m_ASCribeSiteNumber = New_ASCribeSiteNumber
   ''PropertyChanged "ASCribeSiteNumber"
End Property
Public Property Get ASCribeCommand() As String
   ASCribeCommand = m_ASCribeCommand
End Property

Public Property Let ASCribeCommand(ByVal New_ASCribeCommand As String)
   m_ASCribeCommand = New_ASCribeCommand
   ''PropertyChanged "ASCribeCommand"
End Property
Public Property Get StoresPass() As String
   StoresPass = m_StoresPass
End Property

Public Property Let StoresPass(ByVal New_StoresPass As String)
   m_StoresPass = New_StoresPass
   ''PropertyChanged "ASCribeCommand"
End Property
Public Property Get WardPass() As String
   StoresPass = m_WardPass
End Property

Public Property Let WardPass(ByVal New_WardPass As String)
   m_WardPass = New_WardPass
   ''PropertyChanged "ASCribeCommand"
End Property
Private Sub UserControl_InitProperties()
   m_LoadModule = 0
   m_ASCribePath = ""
   m_ASCribeSiteNumber = ""
   m_ASCribeCommand = ""
   
    
End Sub
Private Function StartASCModule() As Long
'24Feb03 CKJ Added switch for different executables

Const ROUTINE = "StartASCModule"
Dim uErr As tErrorState
On Error GoTo ErrorHandler:
'__________________________

Dim LoadModule As Integer
Dim Locked As Integer
Dim TaskId As Double
Dim GMFN_len As Long
Dim dummy As Long
Dim strExecutable As String



   If Trim$(m_ASCribePath$) = "" Then m_ASCribePath$ = "C:\Ascribe"
  
   strExecutable = Trim$(m_ASCribePath$) & "\" & m_ASCribeExe
      
   LoadModule = False
  
   m_ASCHndl = 0 'CheckModuleIsRunning&() '22Sep05 TH Removed for now
   If m_ASCHndl = 0 Then LoadModule% = True
   
   If LoadModule Then
      'Start executable
      'TaskId = Shell(strExecutable & " " & Format$(Val(m_ASCribeSiteNumber$)) & " /STRPASS" & Format$(Val(m_StoresPass)) & " /WRDPASS" & Format$(Val(m_WardPass)) & " /SID" & Format$(Val(m_SessionID)))                          '   "
      TaskId = Shell(strExecutable & " " & Format$(Val(m_ASCribeSiteNumber$)) & " /STRPASS" & Format$(Val(m_StoresPass)) & " /WRDPASS" & Format$(Val(m_WardPass)) & " /SID" & Format$(Val(m_SessionID)) & " " & m_ASCribeCommand)                          '   "
      
      If Err.Number = 0 Then
''         Do While Not FileExists("C:\", "ASCOCX", 0)
''            DoEvents
''            Sleep 500
''         Loop
         m_ASCHndl = CheckModuleIsRunning()
      End If
   End If
      
   If m_ASCHndl <> 0 Then
         
         'WriteIntermediateFile
         ''AcquireLock mc_Lock_File_Name$, 0, 0         'unlock
         
         'Activate Executable
         'ShowWindow m_ASCHndl, SW_RESTORE
         ''''ShowWindow m_ASCHndl, SW_SHOWMAXIMIZED
         
''         Do While FileExists("C:\", "PMSASC.DAT", 0) And FileExists("C:\", "ASCOCX", 0)
''            Sleep 500 'wait for 0.5 seconds
''            DoEvents
''         Loop
         
         'relock file
''         AcquireLock mc_Lock_File_Name$, -2, Locked%  'exclusive lock, retry
''
''         ReadIntermediateFile
      Else
         StartASCModule = 0 ''mc_Failed_To_Load_ASCribe
      End If
'__________________________
Cleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
Exit Function
'__________________________ EXIT

'__________________________ Error handling

ErrorHandler:
   CaptureErrorState uErr
Resume Cleanup:
'__________________________ End of Error Handling
   
End Function
Private Function CheckModuleIsRunning() As Long

Dim hndl As Long
Dim namesize As Long
Dim Buffer As String * 1024
Dim modulename As String
Dim Application_Title As String

   hndl& = 0
   Select Case LCase$(m_ASCribeExe)  '21Jul05 TH lcased this
      Case "stores.exe":
         If m_ASCribeCommand = "/lv0" Then
            Application_Title$ = "User Log Viewer"
         Else
            Application_Title$ = "Stock Control"
         End If
      Case "manufact.exe": Application_Title$ = "Manufacturing"
      Case "stocktake.exe": Application_Title$ = "Stock Take"
      Case Else
   End Select
   ''Application_Title$ = "iStores"
   hndl& = FindWindow(vbNullString, vbNullString & Application_Title$ & vbNullString)
   ''If hndl& = 0 Then hndl& = FindWindow(vbNullString, Application_Title$ & " - [Prescription Entry]" & vbNullString)
   CheckModuleIsRunning = hndl&

End Function
Public Property Let LoadModule(ByVal New_LoadModule As Integer)

Const ROUTINE = "LoadModule"
Dim uErr As tErrorState
On Error GoTo ErrorHandler:
'__________________________

   
   
   
   m_LoadModule = StartASCModule()
     
   ''RaiseEvent Completed
   
'__________________________
Cleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Property
'__________________________ EXIT

'__________________________ Error handling

ErrorHandler:
   CaptureErrorState uErr
   Resume Cleanup:
'__________________________ End of Error Handling
End Property
