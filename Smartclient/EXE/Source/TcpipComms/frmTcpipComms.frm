VERSION 5.00
Begin VB.Form frmTcpipComms 
   Caption         =   "TCPIP Comms Client"
   ClientHeight    =   1155
   ClientLeft      =   165
   ClientTop       =   855
   ClientWidth     =   3855
   Icon            =   "frmTcpipComms.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1155
   ScaleWidth      =   3855
   StartUpPosition =   3  'Windows Default
   Visible         =   0   'False
   WindowState     =   1  'Minimized
   Begin VB.Menu mnuPopupTop 
      Caption         =   ""
      Begin VB.Menu mnuPopup 
         Caption         =   "&Show Log"
         Index           =   0
      End
      Begin VB.Menu mnuPopup 
         Caption         =   "-"
         Index           =   1
         Visible         =   0   'False
      End
      Begin VB.Menu mnuPopup 
         Caption         =   "&Disconnect"
         Index           =   2
         Visible         =   0   'False
      End
   End
End
Attribute VB_Name = "frmTcpipComms"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
DefInt A-Z
'----------------------------------------------------------------------------------
'
' Purpose: This form provides the main execution loop of the app. It is used to drive
'          the icon and menu in the notification area.
'
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------
Const CLASS_NAME = "frmTcpipComms"

Public mfrmLog As frmLog
Public WithEvents mfrmClient As frmClient
Attribute mfrmClient.VB_VarHelpID = -1

'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent Connected[(arg1, arg2, ... , argn)]
Public Event Connected(ByVal Status As Integer, ByVal Description As String)
'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent DataIn[(arg1, arg2, ... , argn)]
Public Event DataIn(ByVal Data As String, ByVal EOL As Boolean)
'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent Disconnected[(arg1, arg2, ... , argn)]
Public Event Disconnected(ByVal Status As Integer, ByVal Description As String)
'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent Error[(arg1, arg2, ... , argn)]
Public Event Error(ByVal ErrorCode As Integer, ByVal Description As String)
'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent ReadyToSend[(arg1, arg2, ... , argn)]
Public Event ReadyToSend()
Private Sub Form_Load()

   Set mfrmLog = New frmLog
   
   Set mfrmClient = New frmClient
   
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)

Dim lResult As Long
Dim lMsg As Long

   If Me.ScaleMode = vbPixels Then
         lMsg = X
      Else
         lMsg = X / Screen.TwipsPerPixelX
      End If

   Select Case lMsg
      Case WM_RBUTTONUP
           'popup a menu
            mnuPopup(1).Visible = False
            mnuPopup(2).Visible = False
            
            If (Not (mfrmClient Is Nothing)) Then
               If mfrmClient.IPPort.Connected Then
                  mnuPopup(1).Visible = True
                  mnuPopup(2).Visible = True
               End If
            End If
           PopupMenu mnuPopupTop
      Case Else
         If mfrmLog.Visible Then
            mnuPopup(0).Caption = "&Hide Log"
         Else
            mnuPopup(0).Caption = "&Show Log"
         End If
         
   End Select

End Sub




Private Sub Form_Unload(Cancel As Integer)

   On Error Resume Next
   
   Unload mfrmClient
   
   Unload mfrmLog
   
   Set mfrmClient = Nothing
   
   Set mfrmLog = Nothing
   
   On Error GoTo 0
   
End Sub

Private Sub mfrmClient_Connected(ByVal Status As Integer, ByVal Description As String)
'----------------------------------------------------------------------------------
'
' Purpose: Raises a socket connected event to the class. The event occurs
'          on success or failure of a connection attempt to a remote host.
'
' Inputs:
'     Status      :  Zero if successfully connected, a non-zero number indicating the
'                    error number if the connection failed.
'     Description :  Blank if successfully connected, otherwise the error description.
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "mfrmClient_Connected"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler

   With mfrmClient.IPPort
      If (Status = 0) Then
         mfrmLog.AddEntry "Connection establised to host " & .RemoteHost & " port " & Format$(.RemotePort)
      Else
         mfrmLog.AddEntry "Connection to host " & .RemoteHost & " port " & Format$(.RemotePort) & " failed." & vbCrLf & _
                         "Status: " & Format$(Status) & vbCrLf & _
                         "Description: " & Description & vbCrLf
      End If
   End With
   
   RaiseEvent Connected(Status, Description)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub
Private Sub mfrmClient_DataIn(ByVal Text As String, ByVal EOL As Boolean)
'----------------------------------------------------------------------------------
'
' Purpose: Alerts the class when we have received data from the remote host.
'
' Inputs:
'     Text     :  The data received from the remote host
'     EOL      :  A boolean indicating if the EOL sequence was received with data.
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "mfrmClient_DataIn"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler

   mfrmLog.AddEntry "Received message:" & vbCrLf & Text & vbCrLf & "EOL = " & IIf(EOL, "True", "False") & vbCrLf
   
   RaiseEvent DataIn(Text, EOL)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub
Private Sub mfrmClient_Disconnected(ByVal Status As Integer, ByVal Description As String)
'----------------------------------------------------------------------------------
'
' Purpose: Raises a socket disconnected event to the class. The event occurs on
'          success or failure of a disconnection attempt or when the remote host drops
'          the connection independantly of the client.
'
' Inputs:
'     Status      :  Zero if successfully connected, a non-zero number indicating the
'                    error number if the connection failed.
'     Description :  Blank if successfully connected, otherwise the error description.
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "mfrmClient_Disconnected"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler

   With mfrmClient.IPPort
      mfrmLog.AddEntry "Disconnected from host " & .RemoteHost & " port " & Format$(.RemotePort)
   End With
   
   RaiseEvent Disconnected(Status, Description)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub
Private Sub mfrmClient_Error(ByVal ErrorCode As Integer, ByVal Description As String)
'----------------------------------------------------------------------------------
'
' Purpose: Notifies the class when an error has occurred when using the
'          IP Port control to manage the TCPIP communications.
'
' Inputs:
'     ErrorCode      :  The error number as an integer
'     Description    :  The error description as a text string
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "mfrmClient_Error"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler
   
   mfrmLog.AddEntry "Error:" & vbCrLf & " Number = " & Format$(ErrorCode) & vbCrLf & Description
   
   RaiseEvent Error(ErrorCode, Description)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
Private Sub mfrmClient_ReadyToSend()
'----------------------------------------------------------------------------------
'
' Purpose: Notifies the class that the IP Port is ready to resume
'          transmitting data to the remote host.
'
' Inputs:
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "mfrmClient_ReadyToSend"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler

   mfrmLog.AddEntry "ReadyToSend event fired."
   
   RaiseEvent ReadyToSend

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub

Private Sub mnuPopup_Click(Index As Integer)

   Select Case Index
      Case 0
         If mnuPopup(Index).Caption = "&Show Log" Then
            mnuPopup(Index).Caption = "&Hide Log"
            mfrmLog.Show vbModeless
         Else
            mnuPopup(Index).Caption = "&Show Log"
            mfrmLog.Hide
         End If
      Case 2
         If (Not mfrmClient Is Nothing) Then
            If mfrmClient.IPPort.Connected Then
               mfrmClient.IPPort.Connected = False
            End If
         End If
   End Select
   
End Sub


