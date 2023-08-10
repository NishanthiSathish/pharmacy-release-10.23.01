Attribute VB_Name = "modMLLP"
Option Explicit
DefInt A-Z

Private Const CLASS_NAME = "modMLLP"

Private Const mclStartOfMessageChrCode = &HB
Private Const mclEndofMessageChrCode = &H1C


Public Function AddMLLPControlCharacters(sMsg As String) As String

Const SUB_NAME = "AddMLLPControlCharacters"

Dim uError As udtErrorState

   On Error GoTo ErrorHandler
   
   AddMLLPControlCharacters = Chr(mclStartOfMessageChrCode) & sMsg & Chr(mclEndofMessageChrCode) & vbCr
      
CleanUp:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume CleanUp
   
End Function

Public Function RemoveMLLPControlCharacters(ByVal sMsg As String) As String

Const SUB_NAME = "RemoveMLLPControlCharacters"

Dim uError As udtErrorState

Dim lngStartOfMsgCharPosn As Long


   On Error GoTo ErrorHandler

   lngStartOfMsgCharPosn = InStr(1, sMsg, Chr(mclStartOfMessageChrCode))
   If lngStartOfMsgCharPosn > 0 Then sMsg = Mid$(sMsg, lngStartOfMsgCharPosn + 1)
      
   If Right(sMsg, 1) = vbCr Then sMsg = Left(sMsg, (Len(sMsg) - 1))
   sMsg = Replace(sMsg, Chr(mclEndofMessageChrCode), vbNullString, 1, , vbTextCompare)
   
   RemoveMLLPControlCharacters = sMsg
   
CleanUp:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   RemoveMLLPControlCharacters = vbNullString
   Resume CleanUp
   
End Function

