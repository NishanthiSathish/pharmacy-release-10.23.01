VERSION 5.00
Begin VB.Form frmLog 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "TCPIP Comms Client Log"
   ClientHeight    =   7800
   ClientLeft      =   2760
   ClientTop       =   4050
   ClientWidth     =   10395
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7800
   ScaleWidth      =   10395
   ShowInTaskbar   =   0   'False
   Begin VB.TextBox txtLog 
      Height          =   7575
      Left            =   90
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Top             =   120
      Width           =   10215
   End
   Begin VB.Menu mnuLogTop 
      Caption         =   "Log To &File"
      Index           =   0
      Begin VB.Menu mnuLogging 
         Caption         =   "&Enabled"
         Index           =   0
      End
   End
End
Attribute VB_Name = "frmLog"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
DefInt A-Z
'----------------------------------------------------------------------------------
'
' Purpose: Displays debugging messages on a form to establish what steps the Comms
'          client has been asked to do and to display any errors
'
'
' Modification History:
'  09Jan07 EAC  Written
'
'----------------------------------------------------------------------------------
Const CLASS_NAME = "frmLog"


Public Sub AddEntry(ByVal Msg As String)
'----------------------------------------------------------------------------------
'
' Purpose: Adds the message text to the log text box
'
' Inputs:
'     Msg      :  The log entry to be displayed
'
' Outputs:
'
' Modification History:
'  09Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "AddEntry"

Dim udtError As udtErrorState

Dim boolFileOpen As Boolean
Dim intHdl As Integer
Dim strLogEntry As String

   On Error GoTo ErrorHandler

   boolFileOpen = False
   
   strLogEntry = Format$(Now, "dd-mmm-yy HH:MM:SS") & " - " & Msg & vbCrLf
   
   txtLog.Text = txtLog.Text + strLogEntry

   If mnuLogging(0).Checked Then
      'Log it to file as well
      intHdl = FreeFile()
      Open App.Path & "\comms.log" For Append Lock Read Write As intHdl
      boolFileOpen = True
      Write #intHdl, strLogEntry
      
   End If
   
Cleanup:
   
   On Error Resume Next
   If boolFileOpen Then
      Close #intHdl
   End If
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If (UnloadMode = vbFormControlMenu) Then
      Cancel = True
      Me.Hide
   End If
   
End Sub

Private Sub mnuLog_Click(Index As Integer)

End Sub


Private Sub mnuLogging_Click(Index As Integer)

   If (Index = 0) Then
      mnuLogging(0).Checked = Not mnuLogging(0).Checked
   End If
   
End Sub


