Attribute VB_Name = "modFileHandling"
Option Explicit
DefInt A-Z

Private Const CLASS_NAME = "modFileHandling"

Private mintLockHdl As Integer
Public Sub SaveMessageToFile(ByVal sInstanceName As String, _
                             ByVal sDirectory As String, _
                             ByVal sFileNameExtn As String, _
                             ByVal sMessage As String, _
                             ByRef sFileName As String)
                             
Const SUB_NAME = "SaveMessageToFile"
                             
Const csBackslash = "\"
Const clNoFreeFileNames = 1000
Const csNoFreeFileNames = "Cannot allocate a file name to save the received message. Check that the PASIMPORT32 application is processing the XML files."

Dim uError As udtErrorState

Dim bValidFileName As Boolean
Dim lFileNumber As Long
Dim lInitialFileNumber As Long

Dim sXmlFileName As String

   On Error GoTo ErrorHandler
   
   bValidFileName = True
   
   If Right(sDirectory, 1) <> csBackslash Then sDirectory = sDirectory & csBackslash
   
   lFileNumber = GetNextFileNumber(sInstanceName)
   lInitialFileNumber = lFileNumber
   
   sFileName = Format(lFileNumber, "000000") & sFileNameExtn
   
   sXmlFileName = sDirectory & sFileName
   
   Do While FileExists(sXmlFileName)
      lFileNumber = GetNextFileNumber(sInstanceName)
      sXmlFileName = sDirectory & Format(lFileNumber, "000000") & sFileNameExtn
      
      If lFileNumber = lInitialFileNumber Then
            'only go round the loop once looking for a free file name to use
            bValidFileName = False
            Exit Do
         End If
   Loop
   
   If bValidFileName Then
         WriteMessageToFile sXmlFileName, sMessage
      Else
         Err.Raise vbObjectError + clNoFreeFileNames, SUB_NAME, csNoFreeFileNames
      End If
      
Cleanup:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Public Function GenerateArchiveFileName(ByVal i_sOrigFileName As String, _
                                        ByVal i_sArchiveCriteria As String) As String

Const SUB_NAME = "GenerateArchiveFileName"

Dim uError As udtErrorState

Dim bTwoParts As Boolean
Dim bTwoArchiveParts As Boolean
Dim iPosn As Integer
Dim sFirstBit As String
Dim sSecondBit As String
Dim sFirstArchiveBit As String
Dim sSecondArchiveBit As String
Dim sReplaceChar As String
Dim sToFindChar As String
Dim sPad As String
Dim sTemp As String

   On Error GoTo ErrorHandler
   iPosn = InStr(1, i_sOrigFileName, ".")
   bTwoParts = (iPosn > 0)

   sFirstBit = i_sOrigFileName
   If bTwoParts Then
         sFirstBit = Left(i_sOrigFileName, iPosn - 1)
         sSecondBit = Mid(i_sOrigFileName, iPosn + 1)
      End If

   sFirstArchiveBit = i_sArchiveCriteria
   iPosn = InStr(1, i_sArchiveCriteria, ".")
   bTwoArchiveParts = (iPosn > 0)
   If bTwoArchiveParts Then
         sFirstArchiveBit = Left(i_sArchiveCriteria, iPosn - 1)
         sSecondArchiveBit = Mid(i_sArchiveCriteria, iPosn + 1)
      End If


   If Len(sFirstBit) > Len(sFirstArchiveBit) Then
         sPad = String(Len(sFirstBit) - Len(sFirstArchiveBit), "*")
         sFirstArchiveBit = Replace(sFirstArchiveBit, "*", "*" & sPad, 1, 1)
      End If

   If InStr(1, sFirstArchiveBit, "*") > 0 Then
         For iPosn = 1 To Len(sFirstArchiveBit)
            sReplaceChar = Mid(sFirstArchiveBit, iPosn, 1)
            If Not ((sReplaceChar = "*") Or (sReplaceChar = "?")) Then
                  sToFindChar = Mid(sFirstBit, iPosn, 1)
                  sTemp = Mid(sFirstBit, 1, (iPosn - 1))
                  sFirstBit = sTemp & Replace(sFirstBit, sToFindChar, sReplaceChar, iPosn, 1)
               End If
         Next
      Else
         sFirstBit = sFirstArchiveBit
      End If

   If bTwoParts Then
         If bTwoArchiveParts Then
               sPad = String(Len(sSecondBit) - Len(sSecondArchiveBit), "*")
               sSecondArchiveBit = Replace(sSecondArchiveBit, "*", sPad, 1, 1)
            Else
               sSecondArchiveBit = String(Len(sSecondBit), "*")
            End If

         If (InStr(1, sSecondArchiveBit, "*") > 0) Or (InStr(1, sSecondArchiveBit, "?") > 0) Then
               For iPosn = 1 To Len(sSecondArchiveBit)
                  sReplaceChar = Mid(sSecondArchiveBit, iPosn, 1)
                  If Not ((sReplaceChar = "*") Or (sReplaceChar = "?")) Then
                        sToFindChar = Mid(sSecondBit, iPosn, 1)
                        sTemp = Mid(sSecondBit, 1, (iPosn - 1))
                        sSecondBit = sTemp & Replace(sSecondBit, sToFindChar, sReplaceChar, iPosn, 1)
                     End If
               Next
            Else
               sSecondBit = sSecondArchiveBit
            End If
      End If

   GenerateArchiveFileName = sFirstBit
   If Trim(sSecondBit) <> "" Then
         GenerateArchiveFileName = GenerateArchiveFileName & "." & sSecondBit
      End If

   On Error GoTo 0

Exit Function

ErrorHandler:
   
   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Exit Function

End Function




Public Function LockInstanceNameFile(ByVal strInstanceName As String) As Boolean

Dim strInstanceNameFile As String

   On Error Resume Next
   
   strInstanceNameFile = App.Path & "\" & strInstanceName & ".lck"
   
   mintLockHdl = FreeFile()
   Open strInstanceNameFile For Binary Access Read Write Lock Read Write As #mintLockHdl Len = (1)
   
   LockInstanceNameFile = (Err.Number = 0)
   
   On Error GoTo 0

End Function


Public Sub UnlockInstanceNameFile()

   On Error Resume Next
   
   Close #mintLockHdl
   
   On Error GoTo 0
   
End Sub

Private Sub WriteMessageToFile(ByVal sFileName As String, _
                               ByVal sMessage As String, _
                               Optional ByVal bAppendToFile As Boolean = False, _
                               Optional ByVal bCreateNewFile As Boolean = True)
                               
Const SUB_NAME = "WriteMessageToFile"

Dim uError As udtErrorState

Dim intHandle As Integer
Dim sExtraInfo As String

   On Error GoTo ErrorHandler
   
   intHandle = FreeFile()
   
   sExtraInfo = "Opening file '" & sFileName & "'"
   Open sFileName For Output Access Write Lock Read Write As FreeFile
   
   sExtraInfo = "Writing to file '" & sFileName & "'"
   Print #intHandle, sMessage
   
Cleanup:

   On Error Resume Next
   
   Close #intHandle
         
   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME, , sExtraInfo
   Resume Cleanup
   
End Sub
Private Function FileExists(ByVal sFileName As String) As Boolean

Const SUB_NAME = "FileExists"

Dim uError As udtErrorState

Dim sExtraInfo As String


   On Error GoTo ErrorHandler
      
   FileExists = (Dir(sFileName) <> "")
   
Cleanup:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME, , sExtraInfo
   Resume Cleanup

End Function
Public Function GetNextFileNumber(sInstanceName As String) As Long

Const SUB_NAME = "GetNextFileNumber()"

Const clBottomLimit = 0
Const clTopLimit = 1000000

Dim uError As udtErrorState

Dim bOk As Boolean

Dim iHdl As Integer
Dim lValue As Long

Dim sExtraInfo As String
Dim sFileName As String


   On Error GoTo ErrorHandler
   
   sFileName = App.Path & "\" & sInstanceName & ".dat"
   
   If Dir$(sFileName) = "" Then
         lValue = clBottomLimit
         iHdl = FreeFile()
         Open sFileName For Binary Access Read Write Lock Read Write As iHdl
         Put #iHdl, 1, lValue
         Close #iHdl
      End If
      
   iHdl = FreeFile
   Open sFileName For Binary Access Read Write Lock Read Write As iHdl
   Get #iHdl, 1, lValue
   
   GetNextFileNumber = lValue

   lValue = lValue + 1
   If lValue = clTopLimit Then lValue = clBottomLimit
   
   Put #iHdl, 1, lValue
   
Cleanup:

   On Error Resume Next
   Close #iHdl
   
   On Error GoTo 0
   BubbleOnError uError
   
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME, , sExtraInfo
   Resume Cleanup

End Function


