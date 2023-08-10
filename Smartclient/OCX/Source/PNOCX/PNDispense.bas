Attribute VB_Name = "PNDispenseMain"
'--------------------------------------------------------------------
'                     PNDispense.bas
'                     ------------------
'04jun04 CKJ written
'            Handler module for the dispensing process
'            Replaces ASCshell.frm and Ident.frm
'27sep05 CKJ moved OCXHeap code from OCX.bas prior to its excision
'17May06 CKJ PutRecordFailure: changed action
'10Feb07 CKJ GetNewParentHWnd added
'11Sep14 XN  88799 Added printing of prescription from regimen
'            Added m_RegimenRequestID, and SetRegimenRequestID
'            Updated ProcessPN to use m_RegimenRequestID
'            Updated GetEpisodefromSupplyRequest
'            Renamed GetEpisodefromSupplyRequest to GetEpisodeFromRequest and got to use RegimenRequestID
'06Nov14 XN  ProcessPN: Added setting BSA (83897)
'14Oct15 TH  ProcessPN: Added section to get patietn status (for kind in any potential translog) (TFS 132485)
'11Jul16 KR  Now check for out-of-use wards and consultants before dispensing (138707)
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'21Nov08 CKJ Ported to V10.0 from V8.8 from Dispense.bas
'--------------------------------------------------------------------


Option Explicit
DefInt A-Z

Global Const PROJECT As String = "PNCtl."

'Global gTransport As PharmacyData.Transport      '15Aug12 CKJ
Global gTransport As Object      '15Aug12 CKJ

Global UserControlIsAlive As Integer

Global g_SessionID As Long
Global gEntityID_User As Long    'Currently logged in user

Global g_OCXheapID As Integer

Global UnsavedChanges As Boolean

Global StopEvents As Boolean

''Dim frmConfig As WConfigEdit

Global escaped As Integer  '@@'was in patsubs 8.8, moved here for temp use

Private Const OBJNAME As String = PROJECT & "PNDispenseMain."

Dim m_boolQuesCallbackBusy As Integer
Dim m_UCHWnd As Long

Dim m_OCXBusy As Boolean
Dim m_CancelRequested As Boolean

Dim m_RepeatDispensingMode As String
Dim m_PNMode As String

Dim m_lngMTSNo As Long

Dim m_strRepeatDispensingBatchXML As String
Dim m_PNPrintXML As String
Dim m_SupplyRequestID As Long
Dim m_RegimenRequestID As Long   '11Sep14 XN 88799 Added printing of prescription from regimen

'20Feb12 TH Added to support logviewer
Global sitenos() As Integer                                      '31Mar04 CKJ added type declaration
Global siteabb$(), sitepth$()
''Global sup As supplierstruct
Global strPNOutputMessage As String

'




Sub Ques_Callback(Index)
'23Nov00 CKJ Prevented re-entrant calls through this procedure
'            - thought to be responsible for GPF in PN Clinical details quescrol on pressing
'              Shift-F1 to display the consultant list
'            - noted that call stack occasionally showed one callback in progress from the shift-F1
'              and a second happened just as the list box form is displayed, caused by textq_lostfocus

popmessagecr ".", "Ques_Callback is not supported"
Exit Sub '**!!**


End Sub




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

Sub LX(mnu As Menu, SuppCode$, Action%, Token&)
'Nov-Dec96 CKJ/EAC Licence interface
'Parameters:
' Ctl is a control which has one or more attributes to be set.
'   examples are mnuItem.enabled, mnuItem.visible, frmForm.tag
'   The name of the control is central to the licence operation
' SuppCode$ may be optional - depends on individual controls.
'   It is used to specify a licence element for generic controls.
' Action is applied to the control
'   0 no  action
'   1 set visible
'   2 set enabled
'   4 set tabstop
'   8 set checked
'  16 set text/caption
'  32 set tag
'  These can be added together, where doing so is sensible,
'   eg   3 sets both visible & enabled to T or F
'       48 sets text and tag of a textbox to same value
' Token - to be decided; probably supplementary security
'    leave at zero for now
'16Dec96 CKJ Ready for testing
               
Dim Value$, LinkID$, i%, Filter%

   On Error Resume Next
   
   'LinkID$ = vbGetCtrlName(Ctl.Parent) & "." & vbGetCtrlName(Ctl.)
   LinkID$ = mnu.Parent.name & "." & mnu.name
''   LinkID$ = LinkID$ & "." & Format$(Ctl.Index) 'resume next if 'object not an array'
   LinkID$ = LinkID$ & "." & Format$(mnu.Index) 'resume next if 'object not an array'
   If SuppCode$ <> "" Then LinkID$ = LinkID$ & "." & SuppCode$

   Value$ = fLX(LinkID$, Token&)

   For i = 0 To 5
      Filter = 2 ^ i                                 ' 1  2  4  8 16 32
      Select Case Action And Filter
    Case 1:  mnu.Visible = (Val(Value$) <> 0)   'reduce to boolean
    Case 2:  mnu.Enabled = (Val(Value$) <> 0)
''    Case 4:  Mnu.tabstop = (Val(value$) <> 0)
    Case 8:  mnu.Checked = (Val(Value$) <> 0)
    Case 16
''       Mnu.Text = value$                        'only one will fire successfully
''       Mnu.Caption = value$
    Case 32: mnu.Tag = Value$
    End Select
   Next
   On Error GoTo 0

End Sub

Private Function fLX(LinkID$, Token&) As String
'Licence control procedure
' All handling of the licence file is done here
' - read once, hold as static data & hand out data on demand
' Call at start of program to fill    Ret$ = Flx("", Token&)
' Ret$ is blank on first call, Token& is not used yet.
' NB if routine fails to read a valid set of data program ends.

'Once read into Txt$, each entry is of the format [10]item=value[13]

Static txt$
Dim pathfileext$, success%, tmp$, ret$, posn%, posn1%
            
   success = False
   ret$ = ""
   If txt$ = "" Then                                           'not already loaded
    pathfileext$ = dispdata$ & "\ascribe.lx"
    If fileexists(pathfileext$) Then                      'file found
          GetTextFile pathfileext$, txt$, success
          If success Then
           decodehex txt$
           txt$ = Chr$(10) & txt$ & cr
           'encodehex Txt$
           'PutTextFile pathfileext$, Txt$, success
        End If
       End If
      Else
    success = True
      End If

   If success And LinkID$ <> "" Then
    tmp$ = Chr$(10) & LinkID$ & "="
    posn = InStr(1, txt$, tmp$, 1)                        'case independent
    If posn Then
          posn1% = InStr(posn + Len(tmp$), txt$, cr)      'look for end of string
          fLX$ = Mid$(txt$, posn + Len(tmp$), posn1 - Len(tmp$) - posn)
       End If
      End If

End Function

Function SetPNMode(ByVal PNAction As String) As Boolean
'15Mar11 TH Added Medicine schedule

Dim success As Boolean

   success = True
   Select Case UCase(PNAction)
      Case "P"          'Printing
         m_PNMode = "P"
      Case "I"          'Issuing
         m_PNMode = "I"
      Case "R"          'Returning
         m_PNMode = "R"
      Case "C"          'Combined (issuing and printing)
         m_PNMode = "C"
      Case "B"
         m_PNMode = "B"  'Baxa Compounder interface
      Case "L"
         m_PNMode = "L"  'Log Viewer
      Case "E"
         m_PNMode = "E"  'Edit Layouts
      Case "V"
         m_PNMode = "V"  'View Layouts
      Case Else
         m_PNMode = ""
         success = False
      End Select
   SetPNMode = success
      
End Function
Public Sub ProcessPN(ByRef frmPNProcess As Form)

'17Jan12 TH Based on ProcessRepeatBatch

'18May11 TH Added section to read JVM settings
'06Nov14 XN Added setting BSA (83897)
'14Oct15 TH Added section to get patietn status (for kind in any potential translog) (TFS 132485)
'11Jul16 KR Now check for out-of-use wards and consultants before dispensing (138707)

Dim success As Boolean

Dim strXML As String


Dim xmldoc As MSXML2.DOMDocument
Dim xmlElement As MSXML2.IXMLDOMElement
Dim xmlnode As MSXML2.IXMLDOMElement
Dim strText As String
Dim strFile As String
Dim strOutfile As String
Dim strFileinfo As String
Dim strPrintReport As String
Dim intReportChan As Integer
Dim strPrevFile As String
Dim intMultiplier As Integer
Dim strMsg As String
Dim strAns As String
Dim intloop As Integer
Dim strParams As String
Dim lngOK As Long
Dim strErrMsg As String
Dim filno As Long
Dim strTemp As String
Dim valid As Integer
Dim blnDone As Boolean
Dim rs As ADODB.Recordset
Dim strFormat As String '23May11 TH Added (F0118397)
  ''    On Error GoTo ProcessRepeatBatchError
Dim EpisodeID As Long
Dim WPatientID As Long
Dim WPat As WPatient
Dim strOutputMessage As String
Dim strDesc As String
Dim msg As String
  
  
      'Do Generic stuff here (readsite info - TH Already done in connection -  , derive episode - patient
      gEntityID_User = gTransport.ExecuteSelectReturnSP(g_SessionID, "pEntityIDFromSessionID", "")
      strParams = gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPersonSelect", strParams)
      If Not rs Is Nothing Then
         If rs.State = adStateOpen Then
            If rs.RecordCount <> 0 Then
               UserID = RtrimGetField(rs!initials)
               UserFullName = Trim$(RtrimGetField(rs!Title) & " " & RtrimGetField(rs!forename) & " " & RtrimGetField(rs!surname))
               acclevels$ = "1000000000" 'default access, because we couldn't be here unless the user has role "Pharmacy"
               '**!!** escalate access if extra policies set up - eg use a custom policy
            End If
            rs.Close
         End If
         Set rs = Nothing
      End If
      
      'Need EpisodeID and then select patienty stuff
      'EpisodeID = GetState(g_SessionID, StateType.Episode)
      'Unroll Episode ID from the Supply request
      DestroyOCXheap
      
      FlushIniCache  '03Apr12 TH Clear cache here
      
      strPNOutputMessage = ""
      SetLabelsPrinted False  '26Mar12 TH Ensure no caching
      'ReadSites '20Mar12 TH Added (TFSLogFix)
      
      success = ParseKeyValuePairsToHeap("Version=V93", "|", "=", g_OCXheapID)   'create heap with single entry
      If success Then
         'EpisodeID = GetEpisodefromSupplyRequest(m_SupplyRequestID)    11Sep14 XN 88799 Added printing of prescription from regimen
         EpisodeID = GetEpisodeFromRequest(m_RegimenRequestID)
         gTlogEpisode = EpisodeID                              'JP 15.04.2008 Needed for translog
         GetEpisodeToOCXHeap EpisodeID, gDispSite                              '19Jul10 XN  F0123343 added siteID to pEpisodeSelect             '26Sep05 CKJ Moved logic from above
         WPatientID = CLng(OCXheap("EntityID", "0"))
         If WPatientID <> 0 Then
            success = GetPatientByPK(WPatientID, WPat)
         Else
            success = False
         End If
         
         If success Then
   ''               patno& = WPat.EntityID             'WPatientID                  '08Nov05 CKJ same as wpat.recno and wpat.entityid
            pid.recno = WPat.recno             'Format$(WPatientID)
            pid.caseno = OCXheap("CaseNo", "") ' GetEpisodeDataItem(EpisodeID, "CaseNo")                 'WPat.caseno
            gTlogCaseno$ = pid.caseno
                              
            gTlogSpecialty$ = UCase(OCXheap("Specialty", ""))         '31Jan06 TH Added      '25Sep08 CKJ added ucase()
            
            'If gTlogSpecialty$ = "0" Then gTlogSpecialty$ = "" ' There was nothing there    '03Mar06 CKJ/TH removed as zero doesn't mean blank
            'setSpecialty gTlogSpecialty$ '07Feb06 TH Added            '30sep08 CKJ removed: superfluous as var is global already
            
            pid.sex = WPat.sex
            pid.dob = WPat.dob
            pid.forename = WPat.forename
            pid.surname = WPat.surname
                           
            'pid.ward = UCase$(OCXheap("WardCode", "NONE"))          'GetEpisodeDataItem(EpisodeID, "WardCode"))    'WPat.ward                  '25Sep08 CKJ removed defaults
            'pid.cons = UCase$(OCXheap("ConsultantCode", "NONE"))    'UCase$(GetEpisodeDataItem(EpisodeID, "ConsultantCode"))      'WPat.cons       "
            pid.ward = UCase$(OCXheap("WardCode", ""))               'GetEpisodeDataItem(EpisodeID, "WardCode"))    'WPat.ward                      "
            pid.cons = UCase$(OCXheap("ConsultantCode", ""))
            
            strMsg = ""
            If Len(trimz(pid.caseno)) = 0 Then strMsg = strMsg & TB & "Patient Case Number" & cr
            If Len(trimz(pid.surname)) = 0 Then strMsg = strMsg & TB & "Patient Surname" & cr
            If Len(trimz(pid.ward)) = 0 Then strMsg = strMsg & TB & "Ward Code" & cr
            If Len(trimz(pid.cons)) = 0 Then strMsg = strMsg & TB & "Consultant Code" & cr
            If TrueFalse(TxtD(dispdata & "\ascribe.ini", "PID", "N", "SpecialtyMandatory", 0)) Then   '25Sep08 CKJ added block
               If Len(trimz(gTlogSpecialty)) = 0 Then strMsg = strMsg & TB & "Specialty Code" & cr
            End If
            
            If Len(strMsg) Then
               success = False
               strMsg = "The following information has not been entered:" & cr & cr & strMsg & cr & "Please enter the details before dispensing can begin"
               'popmessagecr ".Insufficient Information For Dispensing", strMsg
               strPNOutputMessage = "Insufficient Information For Dispensing." & crlf & crlf & strMsg
               
            'KR 11Jul2016 Prevent issuing Out of Use Consultants and Wards (138707)
            ElseIf TrueFalse(OCXheap("ConsultantOutOfUse", "")) And Not TrueFalse(TxtD(dispdata & "\patmed.ini", "", "0", "AllowDispensingToOutOfUseConsultant", 0)) Then
                success = False
                strMsg = "Consultant for this patient has been marked as out of use." & cr & "Please assign a valid consultant before dispensing can begin."
                strPNOutputMessage = "Invalid Consultant." & crlf & crlf & strMsg
                    
            ElseIf TrueFalse(OCXheap("WardOutOfUse", "")) And Not TrueFalse(TxtD(dispdata & "\patmed.ini", "", "0", "AllowDispensingToOutOfUseWard", 0)) Then
              success = False
              strMsg = "Ward for this patient has been marked as out of use." & cr & "Please assign a valid Ward before dispensing can begin."
              strPNOutputMessage = "Invalid Ward." & crlf & crlf & strMsg
            ' end 138707
            Else
               pid.Height = OCXheap("HeightM", "")      'WPat.height
               pid.weight = OCXheap("WeightKg", "")     'WPat.weight
               pid.SurfaceAreaInM2 = OCXheap("BSA", "") 'WPat.BSA  83897 XN 6Nov14
               
               '14Oct15 TH Added section to get patient status (for kind in any potential translog) (TFS 132485)
               pid.status = UCase$(OCXheap("EpisodeTypeCode", "A"))     'Use status of episode itself
               Select Case pid.status
                  Case "I", "O", "D", "L" 'No action required
                     'OK
                  Case Else                'Select IODL because an invalid code or the lifetime episode was given - 'A'll
                     If pid.status = "A" Then
                        msg = "Currently using the Lifetime Episode"
                     Else
                        msg = "Invalid episode type: " & pid.status
                     End If
                     LstBoxFrm.Caption = "Patient Status"
                     LstBoxFrm.lblTitle = cr & msg & cr & "Please select the episode type for this dispensing" & cr
                     LstBoxFrm.LstBox.AddItem "  In-patient"
                     LstBoxFrm.LstBox.AddItem "  Out-patient"
                     LstBoxFrm.LstBox.AddItem "  Discharge"
                     LstBoxFrm.LstBox.AddItem "  Leave"
                     LstBoxShow
                     If LstBoxFrm.LstBox.ListIndex = -1 Then
                        'popmessagecr "#", "No episode type chosen" & cr & "Discharge status will be used"
                        popmessagecr "#", "No episode type chosen" & cr & "Inpatient status will be used"
                        pid.status = "I"        '25sep08 CKJ Added default to override "A" '14Oct15 TH Inpatient seems more appropriate for PN
                     Else
                        pid.status = LTrim$(LstBoxFrm.LstBox.Text)
                     End If
                     Unload LstBoxFrm
               End Select
               
               FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0
               'PNLoadRegimen m_SupplyRequestID 11Sep14 XN 88799 Added printing of prescription from regimen
               'PNLoadProducts m_SupplyRequestID
               PNLoadRegimen m_RegimenRequestID, m_SupplyRequestID
               PNLoadProducts m_RegimenRequestID
               'Work out the mode and switch it here
               Select Case m_PNMode
                  Case "I"
                        'issuing - Load in the regimen and supply request/Load in the productbvols into arrays
                        
                        issueregimen True, strOutputMessage, m_SupplyRequestID
                  Case "P"
                        PrintPN m_SupplyRequestID
                  
                  Case "C"
                        PrintPN m_SupplyRequestID
                        'Now we need to check if any labels have been printed before issuing
                        If GetLabelsPrinted() Then
                           issueregimen True, strOutputMessage, m_SupplyRequestID
                        Else
                           'We dont think labels are printed so we should ask if they wis to continue
                           strAns = "N"
                           strDesc = "Labels have not been printed. Do you still wish to issue this regimen ? "
                           'askwin "CIVAS Product", strDesc, strAns, k
                           askwin "Parenteral Nutrition", strDesc, strAns, k  '05Mar12 TH Changed title
                           If Not k.escd And strAns = "Y" Then
                              issueregimen True, strOutputMessage, m_SupplyRequestID
                           Else
                              strPNOutputMessage = strPNOutputMessage & crlf & crlf & "Issuing Aborted. No Labels have been printed."
                           End If
                        End If
                        
                  Case "R"
                        issueregimen False, strOutputMessage, m_SupplyRequestID
                  Case "B"  'BAXA Compunder
                        BaxaFile
               
               End Select
            End If
         Else
            strPNOutputMessage = "Failed to load patient record"
         End If
      End If
      
      
Exit Sub


      success = True
      
      
      strXML = RepeatDispensingBatchXML
      'Debug MsgBox RepeatDispensingBatchXML
      replace strXML, "<xmlData>", "<xml>", 0
      replace strXML, "</xmlData>", "</xml>", 0
      If LCase(Left(strXML, 5)) <> "<xml>" Then             'encase raw XML in suitable tags
         strXML = "<xml>" & strXML & "</xml>"
      End If
      
      'DEBUG
      'filno = FreeFile                        'create file of 0 bytes on disk
      'Open "C:\rptdisp.txt" For Output As filno
      'Print #filno, strXML
      'Close filno
      
''      RepeatDispensingBatchID = 0
      Set xmldoc = New MSXML2.DOMDocument
      xmldoc.loadXML strXML
      
      For Each xmlElement In xmldoc.selectNodes("//Batch")              'for each batch (only process first, as design is for only one)
''         For Each xmlnode In XMLelement.selectNodes("ValidationError")  'handle batch errors here
''            strBatchNotes = strBatchNotes & xmlnode.xml & crlf          'should never be batch errors  '** tidy for printing
''            'We should only fail now for real errors
''            If Val(Iff(IsNull(xmlnode.getAttribute("Exception")), "", xmlnode.getAttribute("Exception"))) = 1 Then success = False   '02Nov09 TH Added
''            'success = False
''         Next
         
''         If success Then
''            RepeatDispensingBatchID = XMLelement.getAttribute("BatchID")
''            If RepeatDispensingBatchID <= 0 Then                'not a valid batch
''               strBatchNotes = strBatchNotes & "Batch ID not supplied" & crlf
''               success = False
''            ElseIf HasRobot And UCase(MachineName) = "JVADTPS" Then '18May11 TH Added to read JVM settings
''               'JVM so prefill the batch level pattern
''               blnJVMBreakfast = True
''               blnJVMLunch = True
''               blnJVMTea = True
''               blnJVMNight = True
''               intJVMStartSlot = 1
''               intJVMTotalSlots = 0
''               If XMLelement.getAttribute("Breakfast") = "0" Then blnJVMBreakfast = False
''               If XMLelement.getAttribute("Lunch") = "0" Then blnJVMLunch = False
''               If XMLelement.getAttribute("Tea") = "0" Then blnJVMTea = False
''               If XMLelement.getAttribute("Night") = "0" Then blnJVMNight = False
''               If LCase(XMLelement.getAttribute("Breakfast")) = "false" Then blnJVMBreakfast = False  '07Jun11 TH Added after getting actual XML
''               If LCase(XMLelement.getAttribute("Lunch")) = "false" Then blnJVMLunch = False          '  "
''               If LCase(XMLelement.getAttribute("Tea")) = "false" Then blnJVMTea = False              '  "
''               If LCase(XMLelement.getAttribute("Night")) = "false" Then blnJVMNight = False          '  "
''               intJVMStartSlot = Val(XMLelement.getAttribute("StartSlot"))
''               intJVMTotalSlots = Val(XMLelement.getAttribute("TotalSlots"))
''               strTemp = XMLelement.getAttribute("StartDate")    'date as ccyy-mm-ddT00:00:00 only
''               m_strJVMStartDate = Mid$(strTemp, 9, 2) & Mid$(strTemp, 6, 2) & Left$(strTemp, 4)   'date as ddmmccyy only
''            End If
''            m_RepeatDispensingBatchDescription = XMLelement.getAttribute("Description")
''            m_intBagLabels = Val(XMLelement.getAttribute("BagLabels")) '30May11 TH Bag labels now batch not patient specific
''         End If
''         Exit For    'amend here if more than one batch needs to be supported
      Next
      
         
''      If success Then   'find and process all patients in batch
''         'Read the multiplier and do here - we need to do two reports at present
''         intMultiplier = CInt(XMLelement.getAttribute("Factor"))
''         k.escd = False '09Nov09 TH
''         For intloop = 1 To intMultiplier
''            If Not k.escd Then    '09Nov09 TH Added
''               If RepeatDispensingAction = "I" Then
''                  frmPNProcess.lblRpt.Caption = "Issuing Stock ..."
''                  strFile = dispdata$ & "\RPTDISP.DAT"
''                  If fileexists(strFile) Then
''                     strFileinfo = FileDateTime(strFile)
''                     strPrintReport = "N"
''                     askwin "?Repeat Dispensing", "Before creating a new report do you want to re-print the " & cr & "previous report that was created on: " & strFileinfo, strPrintReport, k
''                     If strPrintReport = "Y" Then
''                        Do
''                           Heap 10, gPRNheapID, "repeatdispensingdata", "[#include" & TB & strFile & "]", 0
''                           If InStr(UCase$(Command$), "/HEAPDEBUG") Then Heap 100, gPRNheapID, "", "", 0
''                           parseRTF dispdata$ & "\RPTDISP.RTF", strOutfile
''                           Hedit 14, "RptDisp" & Chr$(0) & strOutfile
''                           askwin "?Repeat Dispensing", "Previous repeat dispensing report printed" & cr & "Did the report print successfully?", strPrintReport, k
''                           If k.escd Then strPrintReport = "Y"
''                        Loop Until strPrintReport = "Y"
''                        If k.escd Then GoTo RptErrExit      '**!! consider cleaner exit
''                     End If
''                     Kill dispdata$ & "\RPTDISP.DAT"
''                     End If
''                     strPrintReport = "Y"
''                     askwin "?Repeat Dispensing", "Do you want to print a report of all the" & cr & "items issued at the end of this batch?", strPrintReport, k
''                     If k.escd Then
''                        popmessagecr "#Repeat Dispensing", "Issuing of stock cancelled"
''                        GoTo RptErrExit
''                     End If
''                     If strPrintReport = "Y" Then
''                        strFile = dispdata$ & "\RPTDISP.DAT"
''                        intReportChan = FreeFile
''                        Open strFile For Output Lock Read Write As intReportChan
''                     End If
''
''               ElseIf RepeatDispensingAction = "L" Then
''                  'Here we want to check that the user has set up the environment
''                  strMsg = "Please check label printer is on-line and has sufficient label stock available. OK to proceed Y/N"
''                  strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingLabelPrinterCheckMsg", 0)
''
''                  askwin "ASCribe Repeat Dispensing", strMsg, strAns, k
''                  If strAns <> "Y" Then k.escd = True
''                  If k.escd Then
''                     frmPNProcess.lblRpt.Caption = "Batch labelling cancelled. No labels will be printed"
''                  Else
''                     frmPNProcess.lblRpt.Caption = "Printing labels ..."
''                     If RepeatDispensingAction = "L" And HasRobot Then
''                        Select Case MachineName
''                           Case "MTS"      ' Only allocate number when potentially outputting to robot, not at issue
''                              GetPointerSQL patdatapath$ & "\MTSRPT.dat", lngMTSNo, True
''                              SetMTSNo lngMTSNo
''                           Case "JPADTPS"
''                              '!!** no action yet - may not actually be needed
''                           End Select
''                     End If
''                  End If
''
''               ElseIf RepeatDispensingAction = "S" Then '22Mar11 TH Added new medicine schedule stuff, Tayside(F0082043)
''                  m_strRequiredDate = ""
''                  strMsg = "OK to print medicine schedule Yes/No"
''                  strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingMedSchedCheckMsg", 0)
''
''                  askwin "ASCribe Repeat Dispensing", strMsg, strAns, k
''                  If strAns <> "Y" Then k.escd = True
''                  If k.escd Then
''                  'frmPNProcess.lblRpt.Caption = "Medecine Schedule print cancelled."
''                  frmPNProcess.lblRpt.Caption = "Medicine Schedule print cancelled." '23May11 TH Spell medicine properly (F0118399)
''                  Else
''                     'OK Now we need to get the Required Date
''                     Do
''                        strMsg = "Required date for Medicine Schedule"
''                        strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingMedSchedDateMsg", 0)
''                        strMsg = "Enter " & strMsg & " dd/mm/yyyy"
''                        setinput 0, k
''                        k.Max = 10
''
''                        parsedate strRequiredDate, strRequiredDateShuffle, "1", valid           'dd/mm/yyyy
''                        inputwin "Repeat Dispensing", strMsg, strRequiredDateShuffle, k
''                        If Not k.escd Then
''                           strFormat = "3"
''                        parsedate strRequiredDateShuffle, strTemp, strFormat, valid
''                           If strFormat = "0" Then valid = False
''                           If valid Then
''                              If strRequiredDate = strTemp Then blnDone = True
''                              strRequiredDate = strTemp
''                           Else
''                              BadDate
''                           End If
''                        End If
''                     Loop Until blnDone Or k.escd
''
''                     If Not k.escd Then
''                        'Put the date on the heap - No, defer this until later
''                        m_strRequiredDate = strRequiredDateShuffle
''                        frmPNProcess.lblRpt.Caption = "Printing Medicine Schedule ..." '23May11 TH Spell medicine correctly(F00118398)
''                     Else  '23May11 TH Added (F0118403)
''                        frmPNProcess.lblRpt.Caption = "Medicine Schedule print cancelled."
''                     End If
''
''                  End If
''
''               ElseIf RepeatDispensingAction = "R" Then '04May11 TH Added new DORIS requirements report, Norfolk(F)
''                  strMsg = "OK to print Batch Requirements Report Yes/No"
''                  strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingReportCheckMsg", 0)
''
''                  askwin "ASCribe Repeat Dispensing", strMsg, strAns, k
''                  If strAns <> "Y" Then k.escd = True
''                  If k.escd Then
''                      frmPNProcess.lblRpt.Caption = "Batch Requirements Report print cancelled."
''                  Else
''                      frmPNProcess.lblRpt.Caption = "Printing Batch Requirements Report ..."
''                  End If
''                  ReDim m_BatchReportList(0) As String ' BatchReportRec  'reset the batch report array
''               End If
''
''               Screen.MousePointer = STDCURSOR
''
''
''               End If
''              '09Nov09 TH Added
''         Next
''      Else
''
''      End If
''      If blnUpdateBatch Then
''         On Error GoTo RepeatBatchUpdateError
''         'We will need the batchID,EntityID (of us), the
''         ' RepeatDispensingBatchID,gEntityID_User,RepeatDispensingAction
''         strParams = gTransport.CreateInputParameterXML("BatchID", trnDataTypeint, 4, RepeatDispensingBatchID) & _
''                     gTransport.CreateInputParameterXML("EntityID_User", trnDataTypeint, 7, gEntityID_User) & _
''                     gTransport.CreateInputParameterXML("RepeatDispensingAction", trnDataTypeVarChar, 1, RepeatDispensingAction)
''         lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pRepeatDispensingBatchUpdateAction", strParams)
''      End If
''      If Not success Then
''         'popmessagecr "ASCribe Repeat Dispensing", "Batch Failed." & crlf & crlf & strBatchNotes
''         strErrMsg = TxtD(dispdata$ & "\RptDisp.ini", "", "Problems with Batch.", "RepeatDispensingBatchFailMsg", 0)
''         popmessagecr "ASCribe Repeat Dispensing", strErrMsg & crlf & crlf & strBatchNotes
''         frmPNProcess.lblRpt.Caption = strErrMsg
''         If Trim$(strBatchNotes) <> "" Then
''            'frmPNProcess.lblWarnings.Caption = strBatchNotes
''            frmPNProcess.txtWarnings.Text = strBatchNotes
''            frmPNProcess.fraWarnings.Visible = True
''         End If
''      End If
         
      '** return to inactive state, message on screen if needed
      'close db
      
ProcessRepeatBatchExit:
   On Error Resume Next
   Set xmlnode = Nothing
   Set xmlElement = Nothing
   Set xmldoc = Nothing
   On Error GoTo 0

Exit Sub

''RepeatBatchUpdateError:
''success = False
''   strBatchNotes = strBatchNotes & ">>>>> Error: " & Err.Number & " " & "Source: RepeatBatchUpdate " & Err.Description
''   frmPNProcess.lblRpt.Caption = "Repeat batch errors"
''   If Trim$(strBatchNotes) <> "" Then
''      'frmPNProcess.lblWarnings.Caption = strBatchNotes
''      frmPNProcess.txtWarnings.Text = strBatchNotes
''      frmPNProcess.fraWarnings.Visible = True
''   End If
''   popmessagecr "ASCribe Repeat Dispensing", "Failed to update batch status" & crlf & crlf & strBatchNotes
''Resume ProcessRepeatBatchExit
''
''ProcessRepeatBatchError:
''   success = False
''   strBatchNotes = strBatchNotes & ">>>>> Error: " & Err.Number & " " & "Source: ProcessRepeatBatch " & Err.Description
''   frmPNProcess.lblRpt.Caption = "Repeat batch errors"
''   If Trim$(strBatchNotes) <> "" Then
''      'frmPNProcess.lblWarnings.Caption = strBatchNotes
''      frmPNProcess.txtWarnings.Text = strBatchNotes
''      frmPNProcess.fraWarnings.Visible = True
''   End If
''   popmessagecr "ASCribe Repeat Dispensing", "problem(s) have been encountered with this batch :" & crlf & crlf & strBatchNotes
''Resume ProcessRepeatBatchExit

RptErrExit:
frmPNProcess.lblRpt.Caption = "Batch Processed. Error printing batch report"
'Resume ProcessRepeatBatchExit
GoTo ProcessRepeatBatchExit  '10Dec09 TH (F0071709)
End Sub

Sub SetPNPRintXML(ByVal PNPRrintXML As String)

   m_PNPrintXML = PNPRrintXML

End Sub
Sub SetSupplyRequestID(ByVal SupplyRequestID As Long)

   m_SupplyRequestID = SupplyRequestID

End Sub
Sub SetRegimenRequestID(ByVal RegimenRequestID As Long)
'11Sep14 XN 88799 Added printing of prescription from regimen

    m_RegimenRequestID = RegimenRequestID

End Sub
Function GetEpisodeFromRequest(ByVal RequestID As Long) As Long
'Function GetEpisodefromSupplyRequest(ByVal SupplyRequestID As Long) As Long
'23Jan12 TH Written
'11Feb13 TH Function not typed (oops) so defaulted to integer. Now set as long (TFS 56237)
'11Sep14 XN 88799 Added printing of prescription from regimen
Dim strParams As String
'Dim rs As ADODB.Recordset
Dim lngResult As Long

   lngResult = 0
   'strParams = gTransport.CreateInputParameterXML("SupplyRequestID", trnDataTypeint, 4, SupplyRequestID)
   'lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pEpisodeIDbySupplyRequestID", strParams)     11Sep14 XN 88799 Added printing of prescription from regimen
   strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID)
   lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pEpisodeIDbyRequestID", strParams)
   GetEpisodeFromRequest = lngResult
   
   
End Function

Function GetPNPrintXML() As String
'07Feb12 TH

   GetPNPrintXML = m_PNPrintXML


End Function

Sub SetDispdata(site%)
' 6Jan95 CKJ Written. If site is in SITEINFO.INI then add drive letter
'            else assume same server
'            Site = 0  set dispdata to own sitenumber
'            Site = -1 returns number of sites (0-n)
'            Site > 0  set dispdata to specified site
'sitenos() sitepth() and dispdata$ are Named Common Shared
'19Mar09 TH  Added sitenumber to heap for UHB Interfacing (F0032689)

Dim count%
Dim strParams As String

   ReadSites
   Select Case site
      Case -1     ' how many sites?
         site = UBound(sitenos)
      Case 0      ' set to own site
         dispdata$ = sitepth$(0)
         'reset gDispSite
         strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, SiteNumber)
         gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
         Heap 10, gPRNheapID, "SiteNumber", Format$(SiteNumber), 0  '19Mar09 TH Added For UHB Interfacing
      Case Else   ' set to specified site
         For count = 0 To UBound(sitenos)
            If sitenos%(count) = site% Then
                  dispdata$ = sitepth$(count)
                  strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, site%)
                  gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
                  Heap 10, gPRNheapID, "SiteNumber", Format$(site%), 0 '19Mar09 TH Added For UHB Interfacing
                  Exit For
               End If
         Next
         If count > UBound(sitenos) Then
            popmessagecr "WARNING", "Site " + Str$(site) + " missing from SITEINFO.INI"
            Close
            '''End
         End If
   End Select

End Sub

Sub ReadSites()
Static doneonce
Dim sites$
Dim comma%, NumItems%, count%

   If doneonce = False Then
      doneonce = True
      sites$ = siteinfo$("SiteNumbers", "")
      If sites$ <> "" Then
         comma = InStr(sites$, ",")
         NumItems = 1                                'at least one other site
         Do While comma
            NumItems = NumItems + 1
            comma = InStr(comma + 1, sites$, ",")
         Loop
   
         ReDim sitenos%(NumItems), siteabb$(NumItems), sitepth$(NumItems)
        
         deflines sites$, sitepth$(), ",(*)", 1, NumItems
         
         For count = 1 To NumItems
            sitenos%(count) = Val(sitepth$(count))
         Next
         sites$ = siteinfo$("dispdataDRVs", "")
         deflines sites$, sitepth$(), ",(*)", 1, NumItems
         sites$ = siteinfo$("hospabs", "")
         deflines sites$, siteabb$(), ",(*)", 1, NumItems
         For count = 1 To NumItems  ' example  G:\DISPDATA.003
             sitepth$(count) = sitepth$(count) + "\dispdata." + Right$("000" + Trim$(Str$(sitenos%(count))), 3)
         Next
      Else
          ReDim sitenos%(0), siteabb$(0), sitepth$(0)
      End If
      
      sitenos%(0) = SiteNumber
      siteabb$(0) = hospabbr$
      sitepth$(0) = dispdata$
   End If

End Sub
Sub AskReasonCode(Text$, reason$)
' 7Jul94 CKJ Written. Takes text$ = "extra order" etc
'            Returns reason$ or k.escd (shared)
'            Uses dispdata$, reasonfile$, k
'            Max length for text$ is 16 chars
'            Place cusor before calling, ensure screen/window is > 38 wide
Dim Description$

   displaymacrofile "Reason", "Enter reason code for " + Text$, reason$, Description$, True
   k.escd = False
   If Trim$(reason$) = "" Then
      k.escd = True
      popmessagecr "!", "No Reason Code selected - exiting."
   End If

End Sub
Function IsPCTDispensing() As Boolean
'stubbage
IsPCTDispensing = False
End Function
Function PCTConfirmClaimQty(ByVal X As Single) As Boolean
'stubbage
PCTConfirmClaimQty = False
End Function
Sub LogAllPCTDispensings()
'stubbage
End Sub
Function PCTDrugToDispens() As Boolean
'Stubbage
End Function

Sub setPCTDose(ByVal PCTdose As Single, ByVal nDays As Integer, ByVal blnX As Boolean)
'stubbage
End Sub
Public Sub CreatePSOrder(a As Long)
'Stubbage
End Sub

Public Function GetPSOSupplierText() As String
'stubbage
End Function
Public Sub AddToBondStore(a1$, b2$, c3$, a4!, d5$, b6!, c7!, e As Integer)
'01Jul13 TH Stubbage
End Sub
Public Sub DeleteFromBondStore(a1$, b2$)
'27Aug13 TH Stubbage
End Sub
