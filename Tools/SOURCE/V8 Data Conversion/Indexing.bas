Attribute VB_Name = "Indexing"
Option Explicit
DefInt A-Z
'------------------------------------------------------------------------------
'
'                   Routines to create & maintain indexes
'
' This file provides the minimum of index handling routines for normal use.
'
' 5Dec90 CKJ Library created. Still needs work, so is released with no support
'            for altering or deleting index items.
'
' Index file structure:
'-----------------------
' Each line is of the following structure
'
'   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
'   |S M I T H _ _ _ 0 0 0 7 5 6 #|
'   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
'
' Where _ represents a space character and # is <CR> or <LF> (see below)
' The No. of characters in the variable section is determined for a given
' index and is held in the first bytes of the file, and copied to IdxStrLen.
' The length of the line excluding the indexed characters = IdxMinLen which
' is a constant declared below.
'
'   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
'   |8 _ _ _ _ _ _ _ 0 0 3 9 4 8 #|  line 1  8 byte string, 3948 entries total
'   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
'   |_ _ _ _ _ _ _ _ 0 0 3 3 1 4 #|  line 2  3314 entries already indexed
'   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
'   |A A R D V A R K 0 0 0 9 0 2 #|  line 3  AARDVARK points to record 902
'   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+            in parent file
'   |             etc             |
'
' The total No. of entries in the index is held in the numeric part of line 1
' and is copied to TotLines. Line 2 holds the size of the indexed portion of
' the file, copied to IdxedLines. Line 3 holds the first true index entry.
' NB Total No. of records in file = TotLines + 2 since lines 1 & 2 are not
' indexed entries. Similarly, last indexed entry is in record IdxedLines + 2.
'
' Each entry to be indexed must be left trimmed, left justified, right space
' padded, and must be in upper case.
'
' Note that in a fully indexed file, TotLines& = IdxedLines&
'
' The last character on each line, shown as #, is <CR> for all lines except
' where the entry is marked for deletion, in which case <LF> is used instead.
' Such a deleted entry may result from the parent record to which the index
' points being deleted. Alternatively, any amendment to the indexed field
' requires that the old index entry be 'deleted' and a new one written at the
' end of the file. These marked records are left untouched until the file is
' re-indexed, when they are genuinely deleted. Note that they should not be
' used in any search, other than to allow binary search to pass across safely.
'
'18Feb91 CKJ more error handling added
'24Feb91 CKJ á-release of full index routines including update, supports V5.0
'30Mar91 CKJ Getidxline - Trim$ changed to Rtrim$; leading spaces preserved.
' 5Apr91 CKJ cosmetic changes only
'15Dec91 CKJ Updateindex - both entrywas & newentry = null not considered to
'            be an error condition.
' 3Apr92 CKJ Cont& changed to use absolute value (first line is now 3 not 1)
'11Jan94 CKJ Added Exact = 1 to BinarySearchidx
' 3Feb96 CKJ Windows version: Tidied & removed debug code
'18Feb96 CKJ Binarysearchidx: Replaced original binary search with simpler
'            version with constant search depth irrespective of index state.
'05Oct99 EAC Moved to 32bit and modified for use as an MTS object
'27Mar03 EAC Removed MTS references to enable for non-NT clients
'            Tidied up error handling to ensure open files are closed before
'            exiting after an error
'24Aug12 TH  Culled for the ASC Indexing v1 component Indexing Class
'            to allow internal use of procs and reduce external dependencies.

'------------------------------------------------------------------------------

' binarysearchidx (tofind$, idxpathfile$, exact%, cont&, found&)
' updateindex (entrywas$, newentry$, vector&, idxpathfile$, failed%)
' getidxline (idxchan%, lineno&, linelen%, idxentry$, idxvector&, Del%)
' putidxline (idxchan%, lineno&, linelen%, idxentry$, idxvector&, Del%)

Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
              
Private Const mcintIdxMinLen = 7                           ' 6 chars for the record pointer, plus <CR> or <LF>
Private Const mcstrClassName = "ASCIndexing.Indexing"

Private Const mcintIndexLocked = 513
Private Const mcstrIndexLockedMsg = "Indexed locked by another user : "

Private Const miNumOfRetries = 50
Private Const mlRetryPeriod = 100

Private boolDontClose As Boolean
Private mintIdx As Integer
Private mstrLastIdxPathFile As String

Sub binarysearchidx(strToFind As String, ByVal strIdxPathFile As String, ByVal intExact As Integer, lngCont As Long, lngFound As Long, Optional ByVal bLeaveHandleOpen As Boolean = False)
'-----------------------------------------------------------------------------
'             General purpose routine to scan a disk based index
'
' The index must be of the form   ABCDEF000164<CR> or <LF>
' idxstrlen = len("ABCDEF")  i.e. 6 in the example.
' All such strings must be left justified, right space padded to the length
' The line number must be 6 digits, left 0 padded if required.
' There must be no extra spaces or characters on the line.
'
' found&= 0 if no match found, or = line number of tofind$
'
'03 Nov  ASC Taken from subpatme
'14Nov90 CKJ Foundpos% changed to found&
'            why are lines ** commented out ??
'16Nov90 CKJ Exact% =-1   must be exact match, except for trailing spaces
'                   = 0   matches partial entry, starting at left of string
'                          eg  cjones : cjones   0 yes   1 yes
'                              cjon   : cjones   0 no    1 yes
'                   = 1   partial match, returning full match in tofind$
'            Cont&  = 0   new search, normal usage
'                   <>0   special case - continues from where it left off
'                         (Set to 1 or 2 to start from beginning of index,
'                          since first line in index is line 3)
'
'            All parameters including Cont& must be kept UNCHANGED between
'             calls if the calling routine wants to do a continuation search!
'            NB Do NOT call the routine for a continuation unless Found&
'             was true last time.
'
' 5Dec90 CKJ Released for beta test
' 6Feb91 CKJ Modified to handle deleted lines & unsorted section in the file
'            Uses LONG INTEGERS in all places now.
'            *** NOTE *** The code is now partially re-entrant i.e. you can
'                         look in the patient index, then use the routine for
'                         checking the Consultant file, then continue looking
'                         for the next matching patient. The penalty is speed
'                         since this involves closing & re-opening the first
'                         file, & re-reading the file header.
'            ** DANGER ** When used in this way there is a danger of another
'                         user modifying the index while the index is closed.
'
'14Feb91 CKJ To force closure of the last index, call with idxpathfile$ = ""
' 3Apr92 CKJ Cont& changed to use absolute value (ie 1st line is 3 not 1 now)
'11Jan94 CKJ Added Exact = 1 to return matching entry in ToFind$
'18Feb96 CKJ Replaced Phase 1 with much simpler binary search!
'            Every search of a fully sorted index now takes log2(n) to
'            log2(n)+1 reads, whereas the old version could take 1 to n,
'            with a median of log2(n)-1 if the index had no duplicate entries.
'            Duplicates however severely degraded the sort; they now have no
'            undue effect.  22Feb96 CKJ Ported from V7.4beta

'mods needed
' auto retry on Err70 in all places
'-----------------------------------------------------------------------------

Const cstrProcName = ".BinarySearchIdx"

Dim uError As udtErrorState

Dim boolReturnMatch As Boolean

Dim intDel As Integer
Dim intLineLen As Integer

Dim lngBot As Long
Dim lngError As Long
Dim lngIdxVector As Long
Dim lngIndexedLines As Long
Dim lngMatched As Long
Dim lngPtr As Long
Dim lngTop As Long
Dim lngTotalLines As Long
Dim intRetries As Integer

Dim strMatch As String
Dim strIdxEntry As String


   If Len(strIdxPathFile) = 0 Then GoTo Cleanup     '<== WAY OUT
         
   lngFound = False
   strMatch = UCase$(RTrim$(strToFind))
         
   If (mstrLastIdxPathFile <> strIdxPathFile) And (mintIdx > 0) Then
         Close #mintIdx
         mintIdx = 0
      End If
      
   If mintIdx = 0 Then
         On Error GoTo OpenIndexFileErr
         mintIdx = FreeFile
         Do
            lngError = 0
            Open strIdxPathFile For Binary Access Read Lock Write As #mintIdx
         Loop While (lngError <> 0)
      End If
      
   On Error GoTo binarysearchidxErr
   getidxline 1, mcintIdxMinLen + 2, strIdxEntry, lngIdxVector, intDel, strIdxPathFile
   intLineLen = Val(strIdxEntry) + mcintIdxMinLen
   getidxline 1, intLineLen, strIdxEntry, lngTotalLines, intDel, strIdxPathFile
   getidxline 2, intLineLen, strIdxEntry, lngIndexedLines, intDel, strIdxPathFile

   If lngTotalLines <= 0 Then GoTo Cleanup
      
   boolReturnMatch = False
   If intExact = 1 Then                         ' 11Jan94 CKJ Added
         boolReturnMatch = True
         intExact = 0
      End If
   intExact = (intExact <> 0)                      ' reduce to Boolean

  '' Original Phase 1 - find first matching entry - now superseded
  '' binary search until found (del or not) or pointers crossed => Not found
  '' step back until not found (del or not) or until bof
  '' step forwards while found (del or not) until found (not del) or Not found
  '' if found then return value
  '' jump to 1st non indexed entry
  '' while not eof step forwards until found (not del)
  '' if found then return value else return 0
    
   ' New Phase 1 - find first matching entry
   ' binary search until pointers equal, whether found or not
   ' (re)read record at pointer and test if found
   ' if found and not del then return value
   ' step forwards while found (del or not) until found (not del) or Not found
   ' if found then return value
   ' jump to 1st non indexed entry
   ' while not eof step forwards until found (not del)
   ' if found then return value else return 0
   
   ' Phase 2 assumes found in phase 1 - find next matching entry
   ' if pointer is <= indexed entries then
   '  step forwards while found (del or not) until found (not del) or eos or Not found
   '  if found then return value
   ' set pointer to 1st non indexed entry
   ' step forwards until found (not del) or eof
   ' if found then return value else return 0

   If lngCont = 1 Then lngCont = 2                   ' step past pointers
   lngPtr = lngCont - 2                              ' 3Apr92 CKJ Cont& now absolute
   If lngCont = 0 Then                             '     -- Phase 1 --
         lngMatched = False
         lngTop = lngIndexedLines                      ' 17Mar91 CKJ error corrected
         lngBot = 1
         lngPtr = (lngTop + lngBot) \ 2
         Do While lngTop > lngBot                    '  -- Binary Search --
            getidxline lngPtr + 2, intLineLen, strIdxEntry, lngIdxVector, intDel, strIdxPathFile

            If strIdxEntry < strMatch Then  'less than required item
                  lngBot = lngPtr + 1       'set bottom above this line
               Else                     'greater than or equal to item
                  lngTop = lngPtr           'keep found line as new top
               End If
            lngPtr = (lngTop + lngBot) \ 2
         Loop
         GoSub getidxandcheckmatch
      End If

   If lngFound = 0 Then    ' -- Phase 1 / 2 step forwards within sorted --
         If lngPtr < lngIndexedLines Then
               lngMatched = True                   '  -- Step forwards --
               Do While lngPtr < lngIndexedLines And lngMatched <> 0 And lngFound = 0
                  lngPtr = lngPtr + 1
                  GoSub getidxandcheckmatch
               Loop
            End If
      End If

   If lngFound = 0 Then    ' -- Phase 1 / 2 scan unsorted --
         If lngPtr < lngIndexedLines Then lngPtr = lngIndexedLines
         If lngTotalLines > lngIndexedLines Then         '  -- Step forwards --
               Do While lngPtr < lngTotalLines And lngFound = 0
                  lngPtr = lngPtr + 1
                  GoSub getidxandcheckmatch
               Loop
            End If
      End If

   If lngFound Then
         lngCont = lngPtr + 2   ' Return current index pointer (as absolute value)
      Else
         lngCont = 0          ' Return zero
      End If

Cleanup:

   On Error Resume Next
   
If Not bLeaveHandleOpen Then
         Close #mintIdx
         mintIdx = 0
      End If
   
   On Error GoTo 0
   'ProcessError uError, cstrProcName
   BubbleOnError uError
   
Exit Sub
     
getidxandcheckmatch:
   ' matched set if strings match, irrespective of deleted status
   ' found is set if matched and not deleted
   getidxline lngPtr + 2, intLineLen, strIdxEntry, lngIdxVector, intDel, strIdxPathFile
   lngMatched = False
   If intExact Then
         If strIdxEntry = strMatch Then lngMatched = lngIdxVector
      ElseIf InStr(strIdxEntry, strMatch) = 1 Then
         lngMatched = lngIdxVector        ' near match found
         If boolReturnMatch Then strToFind = strIdxEntry  '11Jan94 CKJ Added
      End If
   If lngMatched > 0 And Not intDel Then lngFound = lngMatched
Return

binarysearchidxErr:
   
   CaptureErrorState uError, mcstrClassName, cstrProcName
   GoTo Cleanup

OpenIndexFileErr:

   lngError = Err.Number
   Select Case lngError
      Case 70, 63
         intRetries = intRetries + 1
         Sleep mlRetryPeriod
         If intRetries = miNumOfRetries Then
               CaptureErrorState uError, mcstrClassName, cstrProcName
               LogMessage mcstrClassName, "Error no: " & uError.Number & "; Err Desc: " & uError.Description & " trying to open : " & strIdxPathFile
               Resume Cleanup
            Else
               Resume Next
            End If
      Case Else
         CaptureErrorState uError, mcstrClassName, cstrProcName
         GoTo Cleanup
   End Select
   
End Sub

Public Sub CloseIndex()


   On Error Resume Next
   
   Close #mintIdx
   mintIdx = 0

   On Error GoTo 0
   
End Sub

Public Sub getidxline(lngLineNo As Long, intLineLen As Integer, strIdxEntry As String, lngIdxVector As Long, intDel As Integer, strIdxPathName As String)
'-----------------------------------------------------------------------------
' Read line from a pre-opened index. Supply channel No., total linelength
' and line No. required. Note that this is the actual line number in the
' file, i.e. add two to skip the length & length indexed markers.
' Del% =false unless eol marker is <LF>
'-----------------------------------------------------------------------------

Const cstrProcName = ".getidxline"

Dim uError As udtErrorState
Dim strIdxLine As String
Dim intRetries As Long
Dim lngError As Long

   On Error GoTo getidxlineErr
   
   strIdxLine = Space$(intLineLen)
   
   Do
      lngError = 0
      Get #mintIdx, (lngLineNo - 1) * intLineLen + 1, strIdxLine
   Loop While lngError <> 0
   On Error GoTo 0

   strIdxEntry = RTrim$(Left$(strIdxLine, intLineLen - mcintIdxMinLen))  ' 30Mar91 CKJ was Trim$ - ie removed leading spaces
   lngIdxVector = Val(Mid$(strIdxLine, intLineLen - mcintIdxMinLen + 1))
   intDel = False
   If Right$(strIdxLine, 1) = Chr$(10) Then intDel = True
   
Cleanup:

   On Error GoTo 0
   'ProcessError uError, cstrProcName
   BubbleOnError uError
   
Exit Sub

getidxlineErr:
   
   lngError = Err.Number
   Select Case lngError
      Case 70, 63
         intRetries = intRetries + 1
         Sleep mlRetryPeriod
         If intRetries = miNumOfRetries Then
               CaptureErrorState uError, mcstrClassName, cstrProcName
               LogMessage mcstrClassName, "Error no: " & uError.Number & "; Err Desc: " & uError.Description & " trying to read : " & strIdxPathName
               Resume Cleanup
            Else
               Resume Next
            End If
      Case Else
         CaptureErrorState uError, mcstrClassName, cstrProcName
         Resume Cleanup
   End Select

End Sub
Public Function OpenIndex(ByVal strIdxPathFile As String) As Boolean

Const SUB_NAME = "OpenIndex"

Dim udtError As udtErrorState

Dim intFailed As Integer
Dim intRetries As Integer

Dim lngError As Long


   On Error GoTo ErrorHandler
   
   OpenIndex = False
   
   mintIdx = FreeFile()
   Do
      lngError = 0
      Open strIdxPathFile For Binary Access Read Write Lock Read Write As #mintIdx
   Loop Until lngError = 0
   
   mstrLastIdxPathFile = strIdxPathFile
   
   OpenIndex = True

Cleanup:

   On Error GoTo 0
   'ProcessError udtError, SUB_NAME
   BubbleOnError udtError
   
Exit Function

ErrorHandler:

   lngError = Err.Number
   Select Case lngError
      Case 70, 63
         intRetries = intRetries + 1
         Sleep mlRetryPeriod
         If intRetries = miNumOfRetries Then
               CaptureErrorState udtError, mcstrClassName, SUB_NAME
               LogMessage mcstrClassName, "Error no: " & udtError.Number & "; Err Desc: " & udtError.Description & " trying to open : " & strIdxPathFile
               intFailed = -1      ' had five goes & still locked, so return to calling
               Resume Cleanup
            Else
               Resume Next
            End If
      Case Else
         CaptureErrorState udtError, mcstrClassName, SUB_NAME
         Resume Cleanup
   End Select


End Function


Public Sub putidxline(ByVal intIdxChan As Integer, ByVal lngLineNo As Long, ByVal intLineLen As Integer, strIdxEntry As String, lngIdxVector As Long, intDel As Long, ByVal strIdxPathName As String)
'-----------------------------------------------------------------------------
' Write line to a pre-opened index. Supply channel No., total linelength
' and line No. required. Note that this is the actual line number in the
' file, i.e. add two to skip the length & length indexed markers.
' intDel = false unless line is to be marked for deletion
'-----------------------------------------------------------------------------

Const cstrProcName = ".putidxline"

Dim uError As udtErrorState
Dim strIdxLine As String
Dim strVect As String
Dim intRetries As Integer
Dim lngError As Long

   On Error GoTo putidxlineErr:
   
   strIdxLine = Space$(intLineLen - mcintIdxMinLen)
   
   LSet strIdxLine = UCase$(strIdxEntry)
   
   strVect = Right$(String$(mcintIdxMinLen, "0") + LTrim$(Str$(lngIdxVector)), mcintIdxMinLen - 1)
   
   strIdxLine = strIdxLine + strVect + Chr$(13 + 3 * (intDel = True)) ' Del=>10 else 13
                                                             
   Do
      lngError = 0
      Put #intIdxChan, (lngLineNo - 1) * intLineLen + 1, strIdxLine
   Loop While lngError <> 0
   
Cleanup:

   On Error GoTo 0
   'ProcessError uError, cstrProcName
   BubbleOnError uError
   
Exit Sub

putidxlineErr:
   
   lngError = Err.Number
   Select Case lngError
      Case 70, 63
         intRetries = intRetries + 1
         Sleep mlRetryPeriod
         If intRetries = miNumOfRetries Then
               CaptureErrorState uError, mcstrClassName, cstrProcName
               LogMessage mcstrClassName, "Error no: " & Err.Number & "; Err Desc: " & Err.Description & " trying to write to : " & strIdxPathName
               Resume Cleanup
            Else
               Resume Next
            End If
      Case Else
         CaptureErrorState uError, mcstrClassName, cstrProcName
         Resume Cleanup
   End Select

End Sub

Sub updateindex(ByVal strEntryWas As String, ByVal strNewEntry As String, ByVal lngVector As Long, strIdxPathFile As String, intFailed As Integer)
'-----------------------------------------------------------------------------
'24Feb91 CKJ procedure written
'
' 1) Close idx, if open
' 2) Open file for update as idx
' 3) Do exact match on old string, until vector& is equal, or not found
' 4)  If found then overwrite with new if beyond idxed, or rewrite as Deleted
' 5) Extend index size, if not done in (4)
' 6) Write new record           "
' 7) Close file
'
' Note - if entrywas$=""    then it is a new entry
'        if newentry$=""    then an entry is being deleted & not replaced
'        if vector& <= 0    then the index cannot be changed               *
'        if idxpathfile$="" or is not found then nothing is written        *
'
' Note: both entrywas$ and newentry$ should be trimmed before passing here.
'                                   -------------------
' Failed = 0  all OK
'        =-1  unrecoverable error (see * above)
'        = 1  index locked after five tries, come back later!
'
'15Dec91 CKJ If entrywas and newentry are both null then return failed = false
'            without looking at the index. Previously, it returned
'            unrecoverable error if both were null.
'
'mods needed
'-----------
' could decide whether to overwrite the existing entry, if this is beyond the
'  indexed length - saves extending the file.         - done, see (4a) & (4b)
'-----------------------------------------------------------------------------

Const cstrProcName = ".UpdateIdx"

Dim uError As udtErrorState

Dim boolAlreadyDone As Boolean

Dim intDel As Integer
Dim intLineLen As Integer
Dim intRetries As Integer

Dim lngError As Long
Dim lngCont As Long
Dim lngFound As Long
Dim lngIdxVector As Long
Dim lngIndexedLines As Long
Dim lngTotLines As Long

Dim strIdxChars As String
Dim strIdxEntry As String

   On Error GoTo UpdateindexErr

   boolAlreadyDone = False
   intFailed = False
   
   If Trim$(strEntryWas) = "" And Trim$(strNewEntry) = "" Then
         LogMessage mcstrClassName, "Exiting UpdateIndex as both entries are empty strings."
         GoTo Cleanup   '<== WAY OUT
      End If

   intFailed = True                ' (2) Open index file
   If strIdxPathFile = "" Or lngVector <= 0 Then
         LogMessage mcstrClassName, "UpdateIndex called with IdxPath = '" & strIdxPathFile & "'; Vector = " & Format$(lngVector)
         GoTo Cleanup   '<== WAY OUT
      End If
      
      
   If (mstrLastIdxPathFile <> strIdxPathFile) And (mintIdx > 0) Then
         CloseIndex
      End If
   
   If mintIdx = 0 Then
         OpenIndex strIdxPathFile
      End If
      
   intFailed = False
   getidxline 1, mcintIdxMinLen + 2, strIdxEntry, lngIdxVector, intDel, strIdxPathFile
   intLineLen = Val(strIdxEntry) + mcintIdxMinLen
   getidxline 1, intLineLen, strIdxChars, lngTotLines, intDel, strIdxPathFile
   getidxline 2, intLineLen, strIdxEntry, lngIndexedLines, intDel, strIdxPathFile

   If Trim$(strEntryWas) <> "" Then            ' (3) do exact match on previous entry
         boolDontClose = True
         lngCont = 0
         binarysearchidx strEntryWas, strIdxPathFile, True, lngCont, lngFound, True

         Do While lngFound
            If lngFound = lngVector Then  ' (4a) found it, overwrite the old line

                  If lngCont - 2 > lngIndexedLines And strNewEntry <> "" Then ' 3Apr92 CKJ Cont& now absolute
                        ' safe to rewrite new entry over the old
                        putidxline mintIdx, lngCont, intLineLen, strNewEntry, lngVector, False, strIdxPathFile
                        boolAlreadyDone = True ' prevent writing lower down

                     Else             ' (4b) found it, rewrite the line as Del
                        putidxline mintIdx, lngCont, intLineLen, strEntryWas, lngVector, True, strIdxPathFile
                     End If

                  Exit Do
               Else
                  boolDontClose = True
                  binarysearchidx strEntryWas, strIdxPathFile, True, lngCont, lngFound, True
               End If
         Loop
      End If

                                      ' (5) extend index size
   If strNewEntry <> "" And Not boolAlreadyDone Then
         lngTotLines = lngTotLines + 1
         putidxline mintIdx, 1, intLineLen, strIdxChars, lngTotLines, False, strIdxPathFile

                                      ' (6) write new record
         putidxline mintIdx, lngTotLines + 2, intLineLen, strNewEntry, lngVector, False, strIdxPathFile
      End If

Cleanup:
            
   On Error Resume Next
   Close #mintIdx                          ' (7) Close current index
   mintIdx = 0
   
   On Error GoTo 0
   
   'ProcessError uError, cstrProcName, "IdxPathName = '" & strIdxPathFile & "'"
   BubbleOnError uError
   
Exit Sub

UpdateindexErr:
         
   lngError = Err.Number
   Select Case lngError
      Case 70, 63
         intRetries = intRetries + 1
         Sleep mlRetryPeriod
         If intRetries = miNumOfRetries Then
               CaptureErrorState uError, mcstrClassName, cstrProcName
               LogMessage mcstrClassName, "Error no: " & uError.Number & "; Err Desc: " & uError.Description & " trying to open : " & strIdxPathFile
               intFailed = -1      ' had five goes & still locked, so return to calling
               Resume Cleanup
            Else
               Resume Next
            End If
      Case Else
         CaptureErrorState uError, mcstrClassName, cstrProcName
         Resume Cleanup
   End Select

End Sub




