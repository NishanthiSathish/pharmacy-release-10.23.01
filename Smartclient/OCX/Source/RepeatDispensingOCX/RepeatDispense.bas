Attribute VB_Name = "RepeatDispenseMain"
'--------------------------------------------------------------------
'                     RepeatDispense.bas
'                     ------------------
'04jun04 CKJ written
'            Handler module for the dispensing process
'            Replaces ASCshell.frm and Ident.frm
'27sep05 CKJ moved OCXHeap code from OCX.bas prior to its excision
'17May06 CKJ PutRecordFailure: changed action
'10Feb07 CKJ GetNewParentHWnd added
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'21Nov08 CKJ Ported to V10.0 from V8.8 from Dispense.bas
'--------------------------------------------------------------------


Option Explicit
DefInt A-Z

Global Const PROJECT As String = "RepeatDispensingCtl."

'15Aug12 CKJ
'Global gTransport As PharmacyData.Transport
Global gTransport As Object

Global UserControlIsAlive As Integer

Global g_SessionID As Long
Global gEntityID_User As Long    'Currently logged in user

Global g_OCXheapID As Integer

Global UnsavedChanges As Boolean

Global StopEvents As Boolean

''Dim frmConfig As WConfigEdit

Global escaped As Integer  '@@'was in patsubs 8.8, moved here for temp use

Private Const OBJNAME As String = PROJECT & "RepeatDispenseMain."

Dim m_boolQuesCallbackBusy As Integer
Dim m_UCHWnd As Long

Dim m_OCXBusy As Boolean
Dim m_CancelRequested As Boolean

Dim m_RepeatDispensingMode As String

Dim m_lngMTSNo As Long

Dim m_strRepeatDispensingBatchXML As String

'

Private Sub MDIForm_LoadX()

'Obsolete procedure - remains only for salvage of useful parts

Dim X As Long, tmp$, SaveTitle$
Dim sShortDate$, sLongDate$, sMsg$                                      '24Jan00 CKJ Added
    
''   currentdir$ = CurDir$                           '14dec00 CKJ Added. Essential to satisfy GetSections in frmRunReport load event
''   If SingleUserMode() Then HandleSingleUser       '19Jan99 CFY Added
   
''   LX MnuDispensary(0), "", 2, 0     ' prescription entry
''   LX MnuDispensary(2), "", 2, 0     ' prescription management
''   LX MnuTpnprogs, "", 2, 0          'TPN
''   LX MnuTPN(0), "", 2, 0            ' patient
''   LX MnuTPN(1), "", 2, 0            ' batch
''   LX MnuTPN(2), "", 2, 0            ' Baxa
''   LX MnuFinance, "", 2, 0           'stock
''   LX MnuStockCtrl(0), "", 2, 0      ' purchase order
''   LX MnuManufacturing, "", 2, 0     ' manufacturing
''   LX MnuTitleTDM, "", 2, 0          'TDM
''   LX MnuTitleFormulary, "", 2, 0    'Formulary

   tmp$ = terminal$("NumLock", "")                              '7Jan97 CKJ/MD Added
   If tmp$ <> "" Then SetKeyLock VK_NUMLOCK, (Val(tmp$) <> 0)
   tmp$ = terminal$("CapsLock", "")
   If tmp$ <> "" Then SetKeyLock VK_CAPITAL, (Val(tmp$) <> 0)
   
''   buttoninifile$ = dispdata$ & "\" & terminal("identbut", "identbut.ini")          '31Jul98 EAC move from below
      
''   If Not OCXlaunch() Then                                                          '08Jul98 CFY
'>>         MakeToolBar "S"  '17Feb97 KR  '14Nov00 CKJ Moved from below
''         LX frmMsgWin.lblbox, "tpO", 32, 0  '17Aug98 CKJ Block moved from above
''               FormAbout.Show                                  '14Nov00 CKJ moved from below
''               If SingleUserMode() Then                        '19Jan99 CFY Added
''                     FormAbout.LblSingleUser.Visible = True    '        "
''                     FormAbout.Panel3D1.BackColor = &HC0E0FF   '        "
''                     FormAbout.Picture1.BackColor = FormAbout.Panel3D1.BackColor
''                  End If                                       '        "
''               FormAbout.Refresh                               '14Nov00 CKJ added
''         Unload frmMsgWin
''
''      Else
''         If fileexists("C:\ocxstart") Then
''               OCXStarted = True
''               LaunchfromOCX Me  '14Jul00 JN amended to refer to form
''            Else
''               Close
''               End!
''            End If
''      End If

''   PASmode$ = Trim$(txtd$(dispdata$ & "\PATMED.INI", "PAS", "", "PASconnection", 0))
''   PASmode$ = Trim$(Str(TrueFalse(PASmode$)))
''   If Val(PASmode$) Then
''         If Not fileexists(dispdata$ & pasinifile$) Then
''               popmessagecr ".ASCribe PAS connection", "File: " & dispdata$ & pasinifile$ & " not found" & cr & "Will not be able to access the PAS system"
''               PASmode$ = ""
''            Else
''               PASmode$ = Trim$(txtd$(dispdata$ & pasinifile$, "PAS", "", "Mode", 0))
''               If InStr("U", UCase$(PASmode$)) > 0 Or InStr("E", UCase$(PASmode$)) > 0 Then readSQLspecialChars
''            End If
''      End If

''   Dummy$ = txtd(dispdata$ + "\patmed.ini", "", "0", "SpareCIVASlabelsBatch", EntryFound)
''   If Not EntryFound Then
''         Dummy$ = txtd(dispdata$ + "\patmed.ini", "", "0", "NumOfSpareCIVASLabels", EntryFound)
''         WritePrivateIniFile "", "SpareCIVASlabelsBatch", Dummy$, dispdata$ + "\patmed.ini", 0
''         FlushIniCache
''      End If

   '24Jan00 CKJ Added block
   sShortDate = Format$(36000, "Short Date")  '24/07/1998 or 07/24/1998 (or .../98)
   sLongDate = Format$(36000, "Long Date")    '24 July 1998  (or .../98)
   sMsg = ""
   If Left$(sShortDate, 2) <> "24" Then
         sMsg = sMsg & "The Short Date format is currently set to month/day/year" & cr
         sMsg = sMsg & "and MUST be changed to day/month/year format 'dd/mm/yyyy'" & cr
      End If
   If Right$(sShortDate, 4) <> "1998" Then
         sMsg = sMsg & "The Short Date format is currently set to two digit years" & cr
         sMsg = sMsg & "and MUST be changed to four digit year format 'dd/mm/yyyy'" & cr
      End If
   If Right$(sLongDate, 4) <> "1998" Then
         sMsg = sMsg & "The Long Date format is currently set to two digit years" & cr
         sMsg = sMsg & "and MUST be changed to four digit year format 'dd mmmm yyyy'" & cr
      End If
   If Len(sMsg) Then
         sMsg = "The Regional Settings are incorrect on this Terminal" & cr & cr & sMsg & cr & "Please correct this before using the program"
         sMsg = sMsg & cr & cr & "Do you want to correct this now?" & cr
         sMsg = sMsg & "Select [Cancel] to quit now, or" & cr & "Select [OK] to carry on at your own risk."
         If MessageBox(sMsg, MB_OKCANCEL + MB_ICONSTOP + MB_DEFBUTTON2, "EMIS Health") = IDOK Then      'OK chosen
               WriteLog dispdata$ & "\Regional.log", 0, "", "Terminal:  " & ASCTerminalName() & "  Settings:  " & sShortDate & "  " & sLongDate
               popmessagecr ".", "You have chosen to carry on" & cr & "even though the Regional Settings" & cr & "on this terminal are incorrect." & cr & cr & "Your action has been logged."
            Else                                                                                    'Cancel chosen
''               Stop
''               Close
''               End!
            End If
      End If

End Sub


Sub Ques_Callback(Index)
'23Nov00 CKJ Prevented re-entrant calls through this procedure
'            - thought to be responsible for GPF in PN Clinical details quescrol on pressing
'              Shift-F1 to display the consultant list
'            - noted that call stack occasionally showed one callback in progress from the shift-F1
'              and a second happened just as the list box form is displayed, caused by textq_lostfocus

popmessagecr ".", "Ques_Callback is not supported"
Exit Sub '**!!**


End Sub


''Sub ConfigEdit()
''
''   Set frmConfig = New WConfigEdit
''   Load frmConfig
''
''   With frmConfig
''      .lblTitle(0) = "SiteID"
''      .lblTitle(0) = "Category"
''      .lblTitle(0) = "Section"
''      .lblTitle(0) = "Item"
''      .lblTitle(0) = "Value"
''   End With
''
''   frmConfig.Show vbModal
''
''   Unload frmConfig
''   Set frmConfig = Nothing
''
''End Sub


Function ParseKeyValuePairsToHeap(ByVal i_strtoparse As String, ByVal i_strLineSeparator As String, ByVal i_strKeySeparator As String, o_intHeapID) As Integer
'09Aug02 CKJ Given a string of type "key1=value1|key2=value2|key3=value3" parse into a new Heap
'            The separators can be any single character. In the example above
'            they are i_strLineSeparator = "|" and i_strKeySeparator = "="
'            If CR is used as the line separator then this would resemble a config file.
'            A new heap is initialised here and the handle returned.
'            Function returns success T/F, where false means no heap was allocated
'            or a key or value contained an illegal character for use on a heap.
'            An entry of type "key1|key2=xxx" will ignore key1 and process key2 only.
'            A blank entry must still include the = separator or its equivalent.

Dim blnSuccess As Integer
Dim intKeyPos As Integer
Dim strKeyValue As String
Dim strToParse As String
Dim strKey As String

   o_intHeapID = 0
   Heap 1, o_intHeapID, "ParseKeyValuePairsToHeap", "", blnSuccess
   strToParse = i_strtoparse
   
   Do While blnSuccess And Len(strToParse) > 0
      intKeyPos = InStr(strToParse, i_strLineSeparator)           'key1=value1|key2...'  find '|'
      If intKeyPos Then
            strKeyValue = Left$(strToParse, intKeyPos - 1)        'key1=value1'
            strToParse = Mid$(strToParse, intKeyPos + 1)          'key2...'
         Else
            strKeyValue = strToParse                              'last item, no trailing separator
            strToParse = ""
         End If

      If Len(strKeyValue) Then
            intKeyPos = InStr(strKeyValue, i_strKeySeparator)     'key1=value1'  find '='
            If intKeyPos Then
                  strKey = Left$(strKeyValue, intKeyPos - 1)      'key1'
                  If Len(strKey) Then
                        Heap 10, o_intHeapID, strKey, Mid$(strKeyValue, intKeyPos + 1), blnSuccess
                     End If
               End If
         End If
   Loop

   If Not blnSuccess And o_intHeapID > 0 Then
         Heap 2, o_intHeapID, "", "", 0
         o_intHeapID = 0
      End If

   ParseKeyValuePairsToHeap = blnSuccess

End Function


Function OCXheap(ByVal i_strEntry As String, ByVal i_strDefault As String) As String
'14Feb03 CKJ Read parsed data on the OCX heap. Return default if not found or not set up

Dim strBuffer As String
Dim intSuccess As Integer

   strBuffer = i_strDefault
   If g_OCXheapID Then
         Heap 11, g_OCXheapID, i_strEntry, strBuffer, intSuccess
      End If

   OCXheap = strBuffer

End Function


Sub DestroyOCXheap()
'14Feb03 CKJ

   If g_OCXheapID Then
         Heap 2, g_OCXheapID, "", "", 0
      End If

End Sub


Sub SetFocusTo(ctrl As Control)
   
   On Error Resume Next
   If ctrl.Visible Then
      ctrl.SetFocus
   End If
   On Error GoTo 0

End Sub


Public Sub PutRecordFailure(ByVal ErrNo As Integer, ByVal ErrDescription As String)
'17May06 CKJ Changed Err.raise because this does not stop the UserControl, and
'            remaining database updates still get written. Instead, half-close
'            the database connection and call RefreshState recursively to shut
'            the UserControl down.

Dim msg As String

   msg = "Unable to write to database while in a transaction"
   popmessagecr "** Program halted **", msg
   
   'Err.Raise 32767, OBJNAME, "Module Halted: " & cr & cr & msg
   lblUC("DoAction").Caption = "RefreshState-ForceInactive"
   
End Sub

Sub StoreUCHwnd(ByVal Hwnd As Long)
   
   m_UCHWnd = Hwnd

End Sub

Function GetNewParentHWnd() As Long
'10Feb07 CKJ added

   GetNewParentHWnd = m_UCHWnd

End Function

'@@' Copied from V8.8 corelib
Function FilenameParse(ByVal strFilename As String) As String
'05Sep05 TH/PJC Parse the invalid characters in a filename - conforming to Windows, returing the parsed Filename (#77496).
'05Oct05 CKJ/TH Added the extra chars which we have been using elsewhere, and changed it to remove chars not replace with spaces
   
   replace strFilename, " ", "", 0                    'remove ' \/:*?"<>|¦.'
   replace strFilename, "\", "", 0
   replace strFilename, "/", "", 0
   replace strFilename, ":", "", 0
   replace strFilename, "*", "", 0
   replace strFilename, "?", "", 0
   replace strFilename, Chr$(34), "", 0               'quotes "
   replace strFilename, "<", "", 0
   replace strFilename, ">", "", 0
   replace strFilename, "|", "", 0
   replace strFilename, "¦", "", 0
   replace strFilename, ".", "", 0
   
   FilenameParse = strFilename

End Function


'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NEW FOR REPEAT DISPENSING ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sub SetOCXBusy(ByVal IsBusy As Boolean)
'25Nov08 CKJ

   m_OCXBusy = IsBusy
   
End Sub

Function OCXisBusy() As Boolean
'25Nov08 CKJ

   OCXisBusy = m_OCXBusy

End Function

Sub SetCancelRequested(IsRequested)
'25Nov08 CKJ

   m_CancelRequested = IsRequested
   
End Sub

Function CancelIsRequested() As Boolean
'25Nov08 CKJ

   CancelIsRequested = m_CancelRequested
   
End Function

Function SetRepeatDispensingMode(ByVal RepeatDispensingAction As String) As Boolean
'15Mar11 TH Added Medicine schedule

Dim success As Boolean

   success = True
   Select Case UCase(RepeatDispensingAction)
      Case "L"          'labelling
         m_RepeatDispensingMode = "L"
      Case "I"          'Issuing
         m_RepeatDispensingMode = "I"
      Case "S"          'Medicine Schedule
         m_RepeatDispensingMode = "S"
      Case "R"          'Outstanding Report
         m_RepeatDispensingMode = "R"
      Case "C"          'Combined Label/Issue
         m_RepeatDispensingMode = "C"
      Case Else
         m_RepeatDispensingMode = ""
         success = False
      End Select
   SetRepeatDispensingMode = success
      
End Function

Function RepeatDispensingMode() As String

   RepeatDispensingMode = m_RepeatDispensingMode
   
End Function

Sub SetMTSNo(ByVal lngMTSNo As Long)
'06Jul09 TH
   m_lngMTSNo = lngMTSNo
      
End Sub
Function MTSNo() As String
'06Jul09 TH
   MTSNo = m_lngMTSNo
   
End Function
Sub SetRepeatDispensingBatchXML(ByVal strRepeatDispensingBatchXML As String)
   m_strRepeatDispensingBatchXML = strRepeatDispensingBatchXML

End Sub
Function RepeatDispensingBatchXML() As String

RepeatDispensingBatchXML = m_strRepeatDispensingBatchXML
End Function
Public Sub AddToBondStore(a1$, b2$, c3$, a4!, d5$, b6!, c7!, e As Integer)
'01Jul13 TH Stubbage
End Sub

Public Sub DeleteFromBondStore(a1$, b2$)
'27Aug13 TH Stubbage
End Sub
