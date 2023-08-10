VERSION 5.00
Object = "{33337113-F789-11CE-86F8-0020AFD8C6DB}#1.0#0"; "ipport40.ocx"
Begin VB.Form frmClient 
   BorderStyle     =   3  'Fixed Dialog
   ClientHeight    =   780
   ClientLeft      =   2760
   ClientTop       =   3360
   ClientWidth     =   630
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   780
   ScaleWidth      =   630
   ShowInTaskbar   =   0   'False
   Visible         =   0   'False
   Begin IPPORTLibCtl.IPPort IPPort 
      Left            =   120
      Top             =   180
      EOL             =   ""
      InBufferSize    =   2048
      KeepAlive       =   0   'False
      Linger          =   -1  'True
      LocalPort       =   0
      MaxLineLength   =   2048
      OutBufferSize   =   2048
      RemoteHost      =   ""
      RemotePort      =   0
      WinsockLoaded   =   -1  'True
   End
End
Attribute VB_Name = "frmClient"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
DefInt A-Z
'----------------------------------------------------------------------------------
'
' Purpose:
'
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------
Private Const CLASS_NAME = "frmClient"

Public Event Connected(ByVal Status As Integer, ByVal Description As String)
Public Event DataIn(ByVal Text As String, ByVal EOL As Boolean)
Public Event Disconnected(ByVal Status As Integer, ByVal Description As String)
Public Event Error(ByVal ErrorCode As Integer, ByVal Description As String)
Public Event ReadyToSend()

Private Sub IPPort_Connected(StatusCode As Integer, Description As String)
'----------------------------------------------------------------------------------
'
' Purpose: Raises a Connected Event from the IP Port control to the IpClient Class
'
' Inputs:
'     StatusCode     :  A value of zero if no error, otherwise the error number
'     Description    :  Blank if no error, otherwise the error description
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "IPPort_Connected"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   RaiseEvent Connected(StatusCode, Description)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub


Private Sub IPPort_DataIn(Text As String, EOL As Boolean)
'----------------------------------------------------------------------------------
'
' Purpose: Raises a DataIn event from the IP Port to the IpClient class.
'
' Inputs:
'     Text     :  The data received from the remote host by the IP Port control.
'     EOL      :  A boolean value indicating if an End Of Line sequence was received
'                 with the data from the remote host.
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "IPPort_DataIn"

Dim udtError As udtErrorState



   On Error GoTo ErrorHandler

   RaiseEvent DataIn(Text, EOL)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub

Private Sub IPPort_Disconnected(StatusCode As Integer, Description As String)
'----------------------------------------------------------------------------------
'
' Purpose: Raises a Disconnected Event from the IP Port control to the IpClient Class
'
' Inputs:
'     StatusCode     :  A value of zero if no error, otherwise the error number
'     Description    :  Blank if no error, otherwise the error description
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "IPPort_Disconnected"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   RaiseEvent Disconnected(StatusCode, Description)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub


Private Sub IPPort_Error(ErrorCode As Integer, Description As String)
'----------------------------------------------------------------------------------
'
' Purpose: Raises an Error Event from the IP Port control to the IpClient Class
'
' Inputs:
'     ErrorCode      :  A value of zero if no error, otherwise the error number
'     Description    :  Blank if no error, otherwise the error description
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "IPPort_Error"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   RaiseEvent Error(ErrorCode, Description)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub


Private Sub IPPort_ReadyToSend()
'----------------------------------------------------------------------------------
'
' Purpose: Raises a ReadyToSend event from the IP Port control to the IpClient class.
'          The ReadyToSend event signals that the output buffer now has enough space
'          for more data to be added for transmission.
'
' Inputs:
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "IPPort_ReadyToSend"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   RaiseEvent ReadyToSend

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub


