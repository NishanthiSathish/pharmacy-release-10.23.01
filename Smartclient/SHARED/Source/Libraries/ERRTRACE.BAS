Attribute VB_Name = "ERRTRACE"
Option Explicit
DefInt A-Z

Type tErrorState
   Description As String
   HelpContext As String
   HelpFile As String
   Number As Long
   Source As String
End Type


'21Nov05 CKJ From http://www.freevbcode.com/ShowCode.Asp?ID=3490
'Name: John Conwell
'E-mail: jconwell@ costco.com

Public Enum enmLogType
   LogError = 1&
   LogWarning = 2&
   LogInfo = 4&
End Enum

Public Enum enmErrLevel
   lInfo = &H60000000
   lWarning = &HA0000000
   lError = &HE0000000
End Enum

Private Declare Function RegisterEventSource Lib "advapi32" Alias "RegisterEventSourceA" _
   (ByVal lpUNCServerName As String, _
    ByVal lpSourceName As String _
   ) As Long

Private Declare Function DeregisterEventSource Lib "advapi32" (ByVal hEventLog As Long) As Long

Private Declare Function ReportEvent Lib "advapi32" Alias "ReportEventA" _
   (ByVal hEventLog As Long, _
    ByVal wType As Long, _
    ByVal wCategory As Long, _
    ByVal dwEventID As Long, _
    ByVal lpUserSid As Long, _
    ByVal wNumStrings As Long, _
    ByVal dwDataSize As Long, _
          lpStrings As Any, _
          lpRawData As Any _
   ) As Long



Const ERROR_DETAILS_LOST% = 32767

Sub CaptureErrorState(ErrorState As tErrorState)
'*********************************************************************
'* Purpose:     Captures the state of the error object so that the error can be raied later
'*              in time. If the routine has been called and the error number = 0 then it is
'*              assumed that the error state has been lost so the error number will be set to
'*              ERROR_DETAILS_LOST.
'*
'* Inputs    :  ErrorState       - Variable used to hold the state of the error object
'*
'*********************************************************************
   
  
'      ErrorState.Description = Err'.Description
'      ErrorState.HelpContext = Err.HelpContext
'      ErrorState.HelpFile = Err.HelpFile
      
   If Err = 0 Then
      ErrorState.Number = ERROR_DETAILS_LOST
   Else
      ErrorState.Number = Err
   End If
      
      
End Sub

Sub ProcessError(ErrorState As tErrorState, sProcedureName As String)  ', sParameterValues As String, sExtraInfo As String)
'*********************************************************************
'* Purpose:     Restores the error objects state and then passes control to PassErr
'*
'* Inputs    :  ErrorState       - Variable used to hold the state of the error object
'*              sProcedureName   - Source of the error
'*              sParameterValues - Any parameter values that are of interest
'*              sExtraInfo       - Any further information of interest
'*
'*********************************************************************
      
   'Recover the error state
      
   'Exit now if no error has been raised
   If ErrorState.Number = 0 Then
      Exit Sub             '<== WAY OUT!!!!
   End If
      
   'Now Pass the error on
   'PassErr sProcedureName, sParameterValues, sExtraInfo
   Error ErrorState.Number

End Sub


Public Function LogErrorToEventViewer(sErrMsg As String, eEventType As LogEventTypeConstants) As Boolean
                                     
Dim lEventLogHwnd As Long
Dim LogType As enmLogType
Dim lEventID As Long
Dim lCategory As Long
Dim sServerName As String
Dim lRet As Long
   
   LogErrorToEventViewer = True
   Const sSourceName = "UnshippedOrders"
   lCategory = 1
   sServerName = vbNullString
            
   If eEventType = vbLogEventTypeError Then
      LogType = LogError
      lEventID = 3& Or enmErrLevel.lError
   ElseIf eEventType = vbLogEventTypeInformation Then
      LogType = LogInfo
      lEventID = 1& Or enmErrLevel.lInfo
   ElseIf eEventType = vbLogEventTypeWarning Then
      LogType = LogWarning
      lEventID = 2& Or enmErrLevel.lWarning
   End If
    
   lEventLogHwnd = RegisterEventSource(lpUNCServerName:=sServerName, lpSourceName:=sSourceName)
   
   If lEventLogHwnd = 0 Then
      LogErrorToEventViewer = False
   Else
      lRet = ReportEvent(hEventLog:=lEventLogHwnd, _
                        wType:=LogType, _
                        wCategory:=lCategory, _
                        dwEventID:=lEventID, _
                        lpUserSid:=0, _
                        wNumStrings:=1, _
                        dwDataSize:=0, _
                        lpStrings:=sErrMsg, _
                        lpRawData:=0)
                        
      If lRet = False Then
         LogErrorToEventViewer = False
      End If
                        
      DeregisterEventSource lEventLogHwnd
   End If

End Function


