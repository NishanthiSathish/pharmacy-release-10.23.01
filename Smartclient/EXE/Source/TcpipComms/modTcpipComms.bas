Attribute VB_Name = "modTcpipComms"
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
Const CLASS_NAME = "modTcpipComms"

Dim mfrmMain As frmTcpipComms
Sub Main()
'----------------------------------------------------------------------------------
'
' Purpose: The subroutine called when the application is started.
'
' Inputs:
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "Main"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   
   If mfrmMain Is Nothing Then
      Set mfrmMain = New frmTcpipComms
            
      ShowIconInSysTray frmTcpipComms, "ascribe TCPIP Communication Client"
      
      
      DoEvents
   End If
   
Cleanup:

   On Error GoTo 0

   
Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   MsgBox ConvertErrorToBrokenRulesXML(udtError), vbCritical
   Resume Cleanup
   
End Sub


