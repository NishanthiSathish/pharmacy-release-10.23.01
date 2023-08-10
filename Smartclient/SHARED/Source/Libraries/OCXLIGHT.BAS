Attribute VB_Name = "Module27"
'------------------------------------------------------------------------------------------------
'                                  OCXlight
'                                 ----------
'
'================ V8.6 ==================
'29Oct03 CKJ Written
'            Derived from OCX.bas but wih all patient and prescription related info removed.
'            Supports transfer of UserID, access levels etc from the OCX for stores/stkmaint etc.
'19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
'
'
'
'Published routines:
'LaunchFromOCX       - Launches the system in OCX mode
'OCXAquireLock       - Locks/Unlocks the file which is used to determine if PMS or ASCribe
'                      is the active application.
'OCXLaunch()         - Checks to see if the system was launched on OCX mode
'RefreshOCXHeap      - Refreshes the Print heap with data in the OCXIn structure
'SignalASCDone       - Signals to the OCX that ASCribe has finished and puts ASCribe to sleep
'
'
'mods needed
'-----------
' Check use of "c:\ASCOCX.LCK" and "c:\OCXASC.LCK" - which is it?
'--------------------------------------------------------------------------------------------

Option Explicit
DefInt A-Z

Global Const STATUS_ISSUE = "I"
Global Const STATUS_AUTH = "A"
Global Const STATUS_ABORT = "X"
Global Const STATUS_DISCONTINUE = "D"
Global Const STATUS_RECOVER = "R"
Global Const STATUS_SAVE = "S"               '03Mar99 EAC Added

Const Click_Discontinue = 2
Const Click_New = 0
Const Click_TPN = 8
Const Click_Amend = 1
Const Click_Exit = 11


'Intermediate File record type declaration
Type PMStoASCStruct
   moduletype As String * 2               'P=PN, C=CIVAS/Cytotoxic   '19May99 EAC was string * 1
   OrderID As String * 14                 '
   'ItemNo As String * 4                  '26Jul99 CFY Replaced
   ItemNo As Long                         '         "
   PatientID As String * 8                '
   HKPatientID As String * 12             '
   PatientName As String * 35             'pid.forename & pid.surname
   sex As String * 1                      'pid.six
   dob As String * 8                      'pid.dob
   HospNum As String * 12                 'pid.caseno
   Speciality As String * 4               'pid.Speciality
   wardcode As String * 5 '4              'pid.Wardcode         19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
   BedNo As String * 5                    '** Not stored
   MOCode As String * 6                   '
   MOName As String * 48                  '** Not stored
   PatientCat As String * 2               '
   PatientStatus As String * 1            'Pid.Status
   LanguageFlag As String * 1             'C=Chinese, E=English
   Action As String * 1                   'N=New, M=Modify, D=Delete, R=Recovery, E=Enquiry
   UserID As String * 4                   'Printed on label and recorded in transactions
   RecoveryTime As String * 6             '19May99 EAC Added, format HHMMSS seems to have been missed in the merge
   Accesslvl As String * 10               '19May99 EAC Added for Generic PAS Enquiry
   Identtype As String * 1                '   "     "
   '!!** consider adding height & weight for PN
End Type

Type ASCtoPMSStruct
   OrderID As String * 14
   'ItemNo As String * 4                  '26Jul99 CFY Replaced
   ItemNo As Long                         '         "
   PatientID As String * 8
   DrugDesc As String * 35
   DrugCode As String * 6
   DrugStrength As String * 12
   FormDesc As String * 10
   tradename As String * 20
   DosageValue As String * 4
   DosageUnit As String * 15
   FrequencyCode As String * 7
   DurationDays As String * 3
   IssueQty As String * 4
   BaseUnit As String * 4
   UnitCost As Double
   TransactionStatus As String * 1
End Type

Type TErrorObject                'Used to hold error information
   Proc As String * 35           'Procedure/function
   msg As String                 'Specific message
End Type

Type RecoveryStruct
   LabelPtr As Long
   PrescriptionID As Long
   caseno As String * 10
   recoveraftertime As String * 6
End Type

'Type TOCXSignal
'   Status As String * 1
'   PMRItem As Long
'   Cost As Long
'   Qty
'End Type

Dim OCXHndl As Integer

Dim OCXIn As PMStoASCStruct
Dim OCXOut As ASCtoPMSStruct
Dim ErrorObj As TErrorObject
Dim OCXQty As Single
Dim OCXCost As String
Dim OCXNsvcode As String
Dim OCXDirCode As String
Dim OCXDose As String
Dim OCXDuration As Integer
Dim OCXDosingUnit As String
Dim OCXLabelType As String
Dim OCXTpnExit As Integer
Dim OCXRecoveryTime As String * 6         '01Feb99 EAC added for HK E7 mods, format "HHMMSS"
Dim tempOCXStatus As String * 1           '03Mar99 EAC Frig for TPN stati

Dim m_OCXheapID As Integer                '14Feb03 CKJ

Sub DestroyOCXheap()
'14Feb03 CKJ

   If m_OCXheapID Then
         Heap 2, m_OCXheapID, "", "", 0
      End If

End Sub

Private Sub FillOCXOut(status$, PMRItem&)
'Fills the OCX output structure Structure
'26Jul99 CFY Now uses long integer to hold the PMRitem number rather than an encoded 4 byte string. This is to overcome problems
'            with Unicode on NT systems.

Dim filno%, numoflines%        ' , found% '01Jun02 All/CKJ found% not used
Dim DrugDesc$, dircode$

   ReDim strTemp(10) As String                     '11Nov03 CKJ renamed from temp$() due to 'duplicate definition' bug

   On Error GoTo OCX_FillOCXOut_Err
   
   r.record = ""
   LSet OCXOut = r

   OCXOut.OrderID = OCXIn.OrderID
   'OCXOut.ItemNo = LongToString(PMRItem&)         '26Jul99 CFY Replaced
   OCXOut.ItemNo = PMRItem&                        '         "
   OCXOut.PatientID = OCXIn.PatientID
   OCXOut.UnitCost = 0

   If status <> "X" And OCXLabelType$ <> "P" Then
         
         If Trim$(OCXNsvcode$) <> "" Then
               d.SisCode = OCXNsvcode$
               'getdrug d, 0, found, False      '01Jun02 All/CKJ found is returned but never used
               getdrug d, 0, 0, False           '01Jun02 All/CKJ therefore removed it
            End If

         OCXOut.DrugCode = Left(d.local, 6)
         
         DrugDesc$ = d.LabelDescription   ' DrugDesc$ = d.Description XN 4Jun15 98073 New local stores description
         plingparse DrugDesc$, "!"
         OCXOut.DrugDesc = DrugDesc$
         OCXOut.DrugStrength = d.StrengthDesc
         
         OCXOut.FormDesc = d.PrintformV
         OCXOut.tradename = d.tradename
         OCXOut.DosageValue = OCXDose$                      '!!** Unknown
         OCXOut.DosageUnit = OCXDosingUnit$                  'PHS dosing unit code
         
         deflines OCXDirCode$, strTemp(), "/(*)", 0, numoflines    '11Nov03 CKJ renamed from temp$() due to 'duplicate definition' bug
         If numoflines >= 2 Then
               dircode$ = strTemp(1)                               '   "
            Else
               dircode$ = ""
            End If

         OCXOut.FrequencyCode = dircode$
         
         OCXOut.DurationDays = Format$(OCXDuration%)
         
         OCXOut.IssueQty = Str$(OCXQty!)
         
         '27Jul98 EAC
         'If (UCase$(Left$(d.printformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.printformV, 3)) = "TAB" Or UCase$(Left$(d.printformV, 3)) = "CAP" Or UCase$(Left$(d.printformV, 3)) = "SUP" Or UCase$(Left$(d.printformV, 3)) = "MLO" Or UCase$(Left$(d.printformV, 3)) = "MGO" Or UCase$(Left$(d.printformV, 3)) = "PES" Or UCase$(Left$(d.printformV, 3)) = "NEB" Or UCase$(Left$(d.printformV, 3)) = "LOZ" Or UCase$(Left$(d.printformV, 3)) = "SPR" Then    '
         '      OCXOut.BaseUnit = UCase$(Trim$(d.printformV))
         '      If UCase$(Trim$(d.DosingUnits)) = "MLO" Then OCXOut.BaseUnit = "mlo"
         '   Else
         '      OCXOut.BaseUnit = UCase$(Trim$(d.DosingUnits))
         '   End If
         OCXOut.BaseUnit = Trim$(d.PrintformV)
         
         OCXOut.UnitCost = Val(OCXCost$)
      End If
   
   OCXOut.TransactionStatus = status$
   
   filno = FreeFile
   If fileexists("c:\ASCPMS.DAT") Then Kill "c:\ASCPMS.DAT"
   Open "c:\ASCPMS.DAT" For Binary Access Write Lock Read Write As filno
   Put #filno%, , OCXOut
   Close #filno%

   If InStr(UCase$(Command$), "/OCXDEBUG") Then OCXOutDebug

OCX_FillOCXOut_Exit:
   On Error GoTo 0
Exit Sub

OCX_FillOCXOut_Err:
   ErrorObj.Proc = "FillOCXOut"
   OCXErrorHandler
GoTo OCX_FillOCXOut_Exit

End Sub

Function GetOCXAction() As String

   GetOCXAction$ = OCXIn.Action

End Function

Function GetOCXModuleType() As String
'26Aug99 CFY Added trim$
   
   GetOCXModuleType = Trim$(OCXIn.moduletype)

End Function

Function GetOCXRecoveryTime() As String
'29Sep99 CFY Added trimz

   GetOCXRecoveryTime$ = trimz(OCXRecoveryTime$)

End Function

Sub GetOCXStatus(OCXStatus As String)
'03Mar99 EAC Written
'29Sep99 CFY Added Trimz

   OCXStatus = trimz(tempOCXStatus)

End Sub

Sub LaunchfromOCX(strModuleCode As String)
'22Jun98 ASC Loads file left by OCX and loads the appropriate patient and takes the appropriate module in
'            the correct place e.g. in PR screen at prescription number asked for.
'11Aug98 EAC added recovery option
'15Oct98 CFY Added extra code to handle recovery of TPN prescriptions
'19Nov98 CKJ ReturnPNregimen parameter corrected
'23Nov98 CKJ Mark transactions as cancelled
'01Mar99 EAC Hong Kong E7 Mods
'27Apr99 CFY Additional code added in an attempt to trap for instances were dispens.frm does not
'            load ie. when the PMR is locked.
'19May99 EAC Generic PAS Interface mods
'21Jul99 SF  added extra parameter to MoveToRx: calls
'14Jul00 JN  added new form parameter frmName
'19Jul99 CFY Set focus to dispens.TxtDrugCode regardless (with on error resume next!!). This is to try
'            and stop intances were sometimes the focus was not set after launching from the OCX.
'10Jan00 CFY Now initialises all structures each time the procedure is called. This should ensure new patients
'            are added to the indexes successfully.
'01Feb00 CFY Added Dosafer events and set focus to maintain focus on the dispens forms directions
'            box when calling ASCribe with the modify action.
'02May00 CFY Error trap added to stop setfocus command setting focus on a control that may not be active.
'23May00 CFY Initialises status each time the program is launched by the OCX. Was previously
'14Feb03 CKJ Moved HK PMS specific code to own procedure. Added new launch options

Dim filno%
'Dim ok As Integer                                                '01Mar99 EAC Added for HK E7 Mods
Dim strBuffer As String                                           '14Feb03 CKJ
Dim lngBufferLen As Long                                          '   "
Dim strMsg As String

   OCXHndl = FreeFile
   Open "C:\ASCOCX" For Binary Access Read Write Lock Read Write As OCXHndl

   On Error GoTo OCX_LaunchFromOCX_Err
   filno = FreeFile
   Open "c:\PMSASC.DAT" For Binary Access Read Lock Read Write As filno
   Get #filno, , OCXIn                                            '!!** INCOMPATIBLE WITH EXISTING HK OCX!
                                                                  
   strBuffer = ""                                                 '14Feb03 CKJ
   lngBufferLen = LOF(filno) - Len(OCXIn)                         '   "
   If lngBufferLen > 0 Then                                       '   "
         strBuffer = String$(lngBufferLen, 0)                     '   "
         Get #filno, , strBuffer                                  '   "
      End If                                                      '   "
   Close #filno

   If InStr(UCase$(Command$), "/OCXDEBUG") Then OCXInDebug
   
   Select Case OCXIn.moduletype
      Case Nul & Nul, "  "                                        '14Feb03 CKJ added double space
         strMsg = "Moduletype not specified"

      Case "X" & strModuleCode                                    'eXtension
         LaunchFromSessionExtension strBuffer

      Case Else                                                   'No action, don't launch
         strMsg = "Moduletype " & OCXIn.moduletype & " is not valid for this program"

      End Select
      '----
   
OCX_LaunchFromOCX_Exit:
   On Error GoTo 0
   
   If Len(strMsg$) > 0 Then
         popmessagecr "!OCX: LaunchFromOCX", "Could not launch requested function" & cr & strMsg
         SignalASCDone "X", 0, True
         Close
         storesEnd
      End If

Exit Sub

OCX_LaunchFromOCX_Err:
   ErrorObj.Proc = "LaunchFromOCX"
   OCXErrorHandler
   SignalASCDone STATUS_ABORT, OCXIn.ItemNo, False
   Close
   storesEnd

Resume OCX_LaunchFromOCX_Exit

End Sub

Private Sub LaunchFromSessionExtension(SessionExtension As String)
'14Feb03 CKJ Written. Handles OCXIn.moduletype="XS" for the 'Shell' functions
'16jun03 CKJ use tradename search only if entry present

Const ErrTitle$ = "OCX: LaunchFromSessionExtension"

Dim blnSuccess As Integer
Dim strMsg As String
Dim blnFound As Integer
        
   On Error GoTo LaunchFromSessionExtensionErr
   strMsg = ""
   blnSuccess = ParseKeyValuePairsToHeap(SessionExtension, cr, "=", m_OCXheapID)

   If blnSuccess Then
         UserID$ = Trim$(UCase$(OCXheap("UserID", "")))
         Select Case Len(UserID$)
            Case 1 To 3
               '**OCX Match against security module
               'AccessLevelMask = OCXheap("AccessLevel","")
               'set user full name & access levels here

               'was originally for testing, but now accepts data direct from V9.2
               acclevels$ = OCXheap("AccessLevel", "")
               replace acclevels$, "*", "0", 0
               replace acclevels$, ">", "1", 0
               UserFullName$ = Trim$(OCXheap("UserName", UserID$))
               
            Case Else
               strMsg = "UserID is of incorrect format: '" & UserID$ & "'"
               blnSuccess = False
            End Select
      Else
         strMsg = "Session Extension data is not valid"
      End If

LaunchFromSessionExtensionExit:
   If Len(strMsg$) > 0 Or blnSuccess = False Then
         popmessagecr "!" & ErrTitle$, "Could not launch requested function" & cr & strMsg
         SignalASCDone "X", 0, True
         Close
         storesEnd
      End If
Exit Sub

LaunchFromSessionExtensionErr:
   strMsg = "An error occurred trying to launch program" & cr$ & cr$
   strMsg = strMsg & "Error No: " & Err & cr$
   strMsg = strMsg & "Error Msg: " & Error$(Err) & cr$
Resume LaunchFromSessionExtensionExit

End Sub

Sub OCXAcquireLock(pathfile$, LockType, done)
' PathFile: Full pathname of file to lock, filename also used as message.
' Locktype: 0 Release, 1 Acquire shared, 2 Acquire exclusive lock
'                     -1  " keep trying,-2  " keep trying every 5 seconds.
' Returns:  Done T/F where False is because the user escaped

Dim k1 As kbdcontrol
Dim msg$, Msg2$, KeepTrying%, count%, LockChan%, ans$
Static NumLocks%, Locks$(), Lockdata%()

   If done = 1 Then
         done = True
         Exit Sub
      End If

   done = True
   msg$ = pathfile$
   Msg2$ = T1("IsLckd", "")     '!" is locked by another user"
   pathfile$ = UCase$(pathfile$)
   KeepTrying = (LockType < 0)
   LockType = Abs(LockType)
   For count = 1 To NumLocks
      If Locks$(count) = pathfile$ Then
            If Lockdata(1, count) = LockType Then Exit Sub
            If Lockdata(1, count) <> 0 Then  '10Apr95 CKJ Added
                  Close Lockdata(2, count)
                  Lockdata(1, count) = 0   ' released
                  Lockdata(2, count) = 0   ' chan = 0 " "
               End If
            Exit For
         End If
   Next
   If NumLocks < count Then
         NumLocks = count            ' same No as before or NumLocks + 1
         ReDim Preserve Locks$(NumLocks)
         ReDim Preserve Lockdata(1 To 2, NumLocks)
      End If
   Locks$(count) = pathfile$
   Lockdata(1, count) = LockType
   If LockType = 0 Then Exit Sub                                        'no further action on releasing a lock
   
   On Error GoTo AcquireLock_Err
   Do
      done = True
      LockChan = FreeFile
      If LockType = 1 Then                                              ' shared lock
            Open pathfile$ For Binary Access Read Lock Write As #LockChan Len = (1)
         Else                                                           ' exclusive lock
            Open pathfile$ For Binary Access Read Write Lock Read Write As #LockChan Len = (1)
         End If

      If done Then
            Lockdata(2, count) = LockChan
         Else
            setinput 0, k1
            ans$ = "Y"
            Do While InStr(msg$, "\")
               msg$ = Mid$(msg$, InStr(msg$, "\") + 1)
            Loop
            If KeepTrying Then
                  waitforticks 4                                        'roughly 0.25 second
                  DoEvents
                  ans$ = "Y"
               Else
                  Confirm msg$ & Msg2$, T1("RetryLckd", ""), ans$, k1       '!"try again"
               End If
            If ans$ = "N" Or k1.escd Then
                  Lockdata(1, count) = 0
                  Exit Do
               End If
         End If
   Loop Until done
   On Error GoTo 0
Exit Sub

AcquireLock_Err:
   done = False
   Resume Next

End Sub

Private Sub OCXErrorHandler()
'Description: Handles the display of all errors raised within the OCX module using
'             the Error structure.

Dim msg$

   msg$ = "An error has occured in module OCX" & cr
   msg$ = msg$ & cr
   msg$ = msg$ & "Procedure  : " & Trim$(ErrorObj.Proc) & cr
   msg$ = msg$ & "Error code : " & Format$(Err) & cr
   msg$ = msg$ & "Message    : " & Format$(Error$) & cr
   msg$ = msg$ & cr
   msg$ = msg$ & Trim$(ErrorObj.msg)

   popmessagecr ".EMIS Health", msg$
   
End Sub

Function OCXheap(ByVal i_strEntry As String, ByVal i_strDefault As String) As String
'14Feb03 CKJ Read to parsed data on the OCX heap. Return default if not found.

Dim strBuffer As String
Dim intSuccess As Integer

   strBuffer = i_strDefault
   If m_OCXheapID Then
         Heap 11, m_OCXheapID, i_strEntry, strBuffer, intSuccess
      End If

   OCXheap = strBuffer

End Function

Function OCXheapID() As Integer
'14Feb03 CKJ

   OCXheapID = m_OCXheapID

End Function

Private Sub OCXInDebug()
   
Dim msg$

   msg$ = "ModuleType : " & OCXIn.moduletype & cr
   msg$ = msg$ & "OrderID : " & OCXIn.OrderID & cr
   'msg$ = msg$ & "ItemNo : " & StringToLong(OCXIn.ItemNo) & cr      '26Jul99 CFY Replaced
   msg$ = msg$ & "ItemNo : " & OCXIn.ItemNo & cr                     '         "
   msg$ = msg$ & "PatientID : " & OCXIn.PatientID & cr
   msg$ = msg$ & "HKPatientID : " & OCXIn.HKPatientID & cr
   msg$ = msg$ & "PatientName : " & OCXIn.PatientName & cr
   msg$ = msg$ & "sex : " & OCXIn.sex & cr
   msg$ = msg$ & "dob : " & OCXIn.dob & cr
   msg$ = msg$ & "HospNum : " & OCXIn.HospNum & cr
   msg$ = msg$ & "Speciality : " & OCXIn.Speciality & cr
   msg$ = msg$ & "WardCode : " & OCXIn.wardcode & cr
   msg$ = msg$ & "BedNo : " & OCXIn.BedNo & cr
   msg$ = msg$ & "MOCode : " & OCXIn.MOCode & cr
   msg$ = msg$ & "MOName : " & OCXIn.MOName & cr
   msg$ = msg$ & "PatientCat : " & OCXIn.PatientCat & cr
   msg$ = msg$ & "PatientStatus : " & OCXIn.PatientStatus & cr
   msg$ = msg$ & "LanguageFlag : " & OCXIn.LanguageFlag & cr
   msg$ = msg$ & "Action : " & OCXIn.Action & cr
   msg$ = msg$ & "UserID : " & OCXIn.UserID & cr

   popmessagecr "OCXIn Structure", msg$

End Sub

Function OCXlaunch() As Integer
'Description : Returns true if the system was launched from the OCX
'              otherwise returns false.

   If InStr(UCase$(Command$), "/OCX") Then
         OCXlaunch = True
      Else
         OCXlaunch = False
      End If

End Function

Private Sub OCXOutDebug()

Dim msg$
   
   msg$ = "OrderID : " & OCXOut.OrderID & cr
   'msg$ = msg$ & "ItemNo : " & StringToLong(OCXOut.ItemNo) & cr     '26Jul99 CFY Replaced
   msg$ = msg$ & "ItemNo : " & OCXOut.ItemNo & cr                    '         "
   msg$ = msg$ & "PatientID : " & OCXOut.PatientID & cr
   msg$ = msg$ & "DrugDesc : " & OCXOut.DrugDesc & cr
   msg$ = msg$ & "DrugCode : " & OCXOut.DrugCode & cr
   msg$ = msg$ & "DrugStrength : " & OCXOut.DrugStrength & cr
   msg$ = msg$ & "FormDesc : " & OCXOut.FormDesc & cr
   msg$ = msg$ & "tradename : " & OCXOut.tradename & cr
   msg$ = msg$ & "DosageValue : " & OCXOut.DosageValue & cr
   msg$ = msg$ & "DosageUnit : " & OCXOut.DosageUnit & cr
   msg$ = msg$ & "FrequencyCode : " & OCXOut.FrequencyCode & cr
   msg$ = msg$ & "DurationDays : " & OCXOut.DurationDays & cr
   msg$ = msg$ & "IssueQty : " & OCXOut.IssueQty & cr
   msg$ = msg$ & "BaseUnit : " & OCXOut.BaseUnit & cr
   msg$ = msg$ & "UnitCost : " & OCXOut.UnitCost & cr
   msg$ = msg$ & "TransactionStatus : " & OCXOut.TransactionStatus & cr

   popmessagecr "OCXOut Structure", msg$

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
Dim intValuePos As Integer
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

Sub SetOCXRecoveryTime(hhmmss$)

   OCXRecoveryTime$ = hhmmss$

End Sub

Sub SetOCXStatus(OCXStatus As String)
'03Mar99 EAC Written

   tempOCXStatus = OCXStatus

End Sub

Sub SignalASCDone(status$, pmrptr As Long, ExitOCX)
'Description : Fills the OCX output structure, closes down the dispensary screen and signals
'              that ASCribe has finished for this session.
'Parameters:
'Input   Status      Status to record what happened in the dispensing screen ie. Issue, abort etc.
'Input   PMRItem     The Itemnumber of the prescription being dealt with in this session
'Input   UnitCosts   The cost of the prescription
Static SignalASCDoneAlready

   If Not SignalASCDoneAlready Then                                        'Prevent Re-entry through DispButtonClick_Exit
         SignalASCDoneAlready = True
         FillOCXOut status$, 0                                             'Fill the OCX output structure
         SignalDone                                                        'Signal the OCX that we have finished
      End If

End Sub

Private Sub SignalDone()
'06Sep99 EAC Added line to ensure that we kill ASCShell if not in Hong Kong mode
'Description: Signals to the OCX that ASCribe has completed and is going to sleep

   On Error Resume Next                         'Kill the intermediate file
   Kill "c:\PMSASC.DAT"
   On Error GoTo 0

   On Error GoTo OCX_SignalDone_Err
   OCXAcquireLock "C:\OCXASC.LCK", 0, 0         'Unlock the OCX lock file and
'!!OCX   MDIEvents.Enabled = False                    'disable and minimise the window
'!!OCX   MDIEvents.WindowState = 1
   DestroyOCXheap                               '14feb04 ckj added
   On Error Resume Next
   Close OCXHndl
   Kill "C:\ASCOCX"

   If Len(OCXIn.moduletype) > 1 Then            '!!OCX needs alternative form names here  XS  XO  XM  XR  XN  XE
         Select Case OCXIn.moduletype
            Case "XM"                           'Maint
'!!OCX         Unload MDIEvents       '06Sep99 EAC Added to ensure ASCSHELL exits
               'exit ack to calling routine where Unload/close/exit are needed
            Case "XO", "XE", "XR", "XN"   'Orders,Enquiry=MainScreen / Report=Reporter / Night=frmONJsplash
'!!OCX
            Case Else                           'XS' Shell - does not use OCXlight
               
            End Select
      End If

OCX_SignalDone_Exit:
   On Error GoTo 0
Exit Sub

OCX_SignalDone_Err:
   ErrorObj.Proc = "SignalDone"
   OCXErrorHandler
Resume OCX_SignalDone_Exit

End Sub

Function SlaveModeEnabled() As Integer
'22sep03 CKJ Returns boolean, whether slave mode is set for this site
'            True   slave mode set,     normal dispensing
'            False  slave mode not set, under control of OCX

   SlaveModeEnabled = (Val(TxtD(dispdata$ & "\ascribe.ini", "PID", "0", "SlaveMode", 0)) <> 0)

End Function

