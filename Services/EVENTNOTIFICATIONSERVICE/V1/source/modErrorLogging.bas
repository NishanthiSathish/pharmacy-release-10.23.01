Attribute VB_Name = "modErrorLogging"
Option Explicit
DefInt A-Z


Public Function CreateModuleErrorString(ByVal ModuleName As String, _
                                        ByRef Error As udtErrorState) As String
                                        
   CreateModuleErrorString = "An error occurred in module " & ModuleName & vbCrLf & vbCrLf & _
                             "Error Number: " & Format$(Error.Number) & vbCrLf & _
                             "Error Source: " & Error.Source & vbCrLf & _
                             "Error Description : " & Error.Description & vbCrLf
                                        
End Function

Public Sub LogMessage(ByVal sInstance As String, _
                      ByVal sMessage As String)

Dim sText As String

   On Error Resume Next
      
   'moErrorStream.WriteLine Format(Now, "ddmmmyyyy HH:mm:ss") & " - InstanceName=" & sInstance & " : " & sMessage
   sText = Format(Now, "ddmmmyyyy HH:mm:ss") & " - InstanceName=" & sInstance & " : " & sMessage
   
   LogString sText
   
   On Error GoTo 0
   
End Sub

Public Sub LogString(ByVal sString As String)

Dim iHdl As Integer

Dim sFileName As String

   On Error Resume Next
   
   sFileName = "\" & Format$(Now, "YYYYMMMDD") & ".err"
   
   iHdl = FreeFile()
   Open App.Path & sFileName For Append Access Write Lock Read Write As iHdl
   Print #iHdl, sString
   Close #iHdl
   
   On Error GoTo 0
   
End Sub


Public Sub LogDecodeError(ByVal sInstanceName As String, _
                          ByVal sMessage As String, _
                          ByVal sMsgSource As String, _
                          ByVal lErrorNum As Long, _
                          ByVal sErrorSrc As String, _
                          ByVal sErrorDesc As String)
                           
'NOTE: This function is called by the error handlers so if an error occurs we must ignore it otherwise
'      we will endup in a recursive loop.

Dim sText As String

   On Error Resume Next
   
   sText = "<Error InstanceName=" & Chr(34) & sInstanceName & Chr(34) & " Occurred=" & Chr(34) & _
           Format(Now, "YYYY-MM-DDTHH:mm:ss") & Chr(34) & "><MsgSource><![CDATA[" & sMsgSource & _
           "]]></MsgSource><Message><![CDATA[" & sMessage & _
           "]]></Message><ErrMessage ErrNum=" & _
           Chr(34) & Format(lErrorNum) & Chr(34) & "><ErrSource><![CDATA[" & sErrorSrc & "]]></ErrSource>" & _
           "<ErrDescription><![CDATA[" & sErrorDesc & "]]></ErrDescription></ErrMessage></Error>"

   LogString sText
      
   On Error GoTo 0
                           
                           
End Sub


