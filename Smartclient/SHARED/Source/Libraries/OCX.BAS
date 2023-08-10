Attribute VB_Name = "OCX"
'------------------------------------------------------------------------------------------------
'                                  OCX
'                                 -----
'
'22Jun98 ASC Used to pick up the data from the OCX wrapper programme and then pass control
'            to the appropriate module.
'07Sep98 CFY UpdateDetailsFromOCX: Now takes the ward code passed from the OCX and creates a ward record in the supplier
'            file.
'15Oct98 CFY LaunchFromOCX: Added extra code to handle recovery of TPN prescriptions
'19Nov98 CKJ LaunchfromOCX: ReturnPNregimen parameter corrected
'23Nov98 CKJ LaunchfromOCX: Mark transactions as cancelled
'            CancelTransactions: written
'21Dec98 CFY updatedetailsfromOCX: Added gTlogPPFlag$
'22FEb99 EAC Corrections for E7 Mods
'03Mar99 EAC Corrections for E7 Mods
'            Added additional return status of "S" for Save for TPN items not authorised or issued
'27Apr99 CFY LaunchFromOCX: Additional code added in an attempt to trap for instances were dispens.frm does not
'            load ie. when the PMR is locked.
'19Jul99 CFY updatedetailsfromOCX: Now assigns a default GP code to the patient if it is not present. This is to create an
'             entry in the patient-GP index.
'            LaunchFromOCX: Set focus to dispens.TxtDrugCode regardless (with on error resume next!!). This is to try
'             and stop intances were sometimes the focus was not set after launching from the OCX.
'            UpdateDetailsFromOCX: Now assigns a default GP code to the patient if it is not present. This is to create an
'             entry in the patient-GP index.
'26Jul99 CFY Multiple Mods: Now uses long integer to hold the PMRitem number rather than an encoded 4 byte string. This is to overcome problems
'            with Unicode on NT systems.
'19May99 EAC Updated for use with Generic PAS Interface
'08Jun99 EAC Further updates for use with Generic PAS Interface
'09Jun99 EAC LaunchASCPrograms: set global translog variables
'21Jul99 SF  LaunchFromOCX: added extra parameter to MoveToRx: calls
'21Jul99 SF  MoveToRx: added searchHistory% parameter
'21Jul99 SF  MoveToRx: searches history for the rx number to lookup
'28Jul99 AE  LaunchASCPrograms:added view parameter to call to callmanufacturing
'06Sep99 EAC SignalDone: Added line to ensure that we kill ASCShell if not in Hong Kong mode
'30Sep99 EAC LaunchASCPrograms: Allow 5 char codes to be passed as Prescriber id for Oz
'08Oct99 EAC LaunchASCPrograms: Exit from OCX properly is an error occurs loading the PMR
'16Nov99 SF  MoveToRx: if PBS patient billing then lookup on l.prescriptionid
'16Nov99 SF  MoveToRx: now sets labf& so F3 information can be looked up straight away
'19Nov99 SF/CKJ MoveToRx: added to allow the refresh the pmr correctly when moving to an rx#
'28Jan00 EAC LaunchASCPrograms: Patients notes now being read
'14Jul00 JN  LaunchASCPrograms: Added reference to form
'14Jul00 JN  LaunchfromOCX: Added reference to form
'29Sep99 CFY GetOCXRecoveryTime: Added trimz
'29Sep99 CFY GetOCXStstus: Added Trimz
'01Dec99 CFY updatedetailsfromOCX: Now splits patient name if to fit into the fields. Eg. if forename is sent and its too long, now
'            adds the as much as possible to the end of the surname.
'10Jan00 CFY LaunchFromOCX: Now initialises all structures each time the procedure is called. This should ensure new patients
'            are added to the indexes successfully.
'01Feb00 CFY Added new function OCXRunning so that we can test if the OCX is actually running. This is used to prevent, the OCX
'             from relaunching during the MDIform re-size event.
'            LaunchFromOCX: Added Dosafer events and set focus to maintain focus on the dispens forms directions
'             box when calling ASCribe with the modify action.
'02May00 CFY LaunchFromOCX: Error trap added to stop setfocus command setting focus on a control that may not be active.
'            UpdateDetailsFromOCX: Hospital number now stored in address line 1 so that it can be displayed later on the label from prescription
'              manager. Temporary solution. Will need revisiting.
'05May00 CFY updatedetailsfromOCX: Removed all processing carried out on patient name as was far to complex and still did not function as intended.
'              Name is now simple written to the 35 bytes that make up the surname and forename.
'19Mar01 SF  MoveToRx: now looks up patient billing settings from the dispdata rather than the patdata
'17Jul01 CKJ LaunchASCPrograms: Removed Callmanufacturing form reference (wrong form was being passed through)
'================ V8.5 ==================
'11Jan02 CKJ LaunchASCPrograms: Ask prescriber id if not provided via OCX and if set in patmed.ini
'11Apr02 CKJ EnableDispens, DisableDispens: Button 5 used to bring up the palette but was removed in Jan98 (#60240)
'12Jul02 CKJ Allow external system to add and update patients for "TP" and "PE" modes, if set using
'            ascribe.ini
'            [PID]
'            OCXcreatePID="PE,TP"      'options are "", "PE", "TP", "PE,TP", "TP,PE"
'08Aug02 CKJ Corrected logic of update option
'09Aug02 CKJ Function ParseKeyValuePairsToHeap written and used in AddOrUpdatePatientFromOCX to extract
'            height & weight from overloaded data element OCXIn.MOName
'16jun03 CKJ use tradename search only if entry present
'22Sep03 CKJ Added slave mode, pAllergy, pDiagnosis and pNotes to mode 4 operation
'13nov03 CKJ LaunchFromSessionExtension: added Load FrmOwner for RxNotes to work
'02Apr04 CKJ {SP1}
'            Removed procs stringtolong, longtostring
'27May04 CKJ OCXAcquireLock: Added TrackOpenedFiles
'19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
'6Nov14  XN  AddOrUpdatePatientFromSessionExtension: Added BSA (83897)

'Published routines:
'LaunchFromOCX       - Launches the system in OCX mode
'OCXAcquireLock      - Locks/Unlocks the file which is used to determine if PMS or ASCribe
'                      is the active application.
'OCXLaunch()         - Checks to see if the system was launched on OCX mode
'RefreshOCXHeap      - Refreshes the Print heap with data in the OCXIn structure
'SignalASCDone       - Signals to the OCX that ASCribe has finished and puts ASCribe to sleep
'
'
'mods needed
'-----------
'/ Check use of "c:\ASCOCX.LCK" and "c:\OCXASC.LCK" - which is it? => "c:\OCXASC.LCK"
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
'Const Click_TPN = 8
Const Click_Amend = 1
Const Click_Exit = 11
Const RecoveryFile$ = "C:\ASCRIBE\RECOVER.ASC"


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
   wardcode As String * 5 '4              'pid.Wardcode		19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
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
   Identtype As String * 1
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
   prescriptionid As Long
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
Dim iOCXRunning As Integer

Global g_OCXheapID As Integer
'

Private Function AddOrUpdatePatientFromSessionExtension(i_strOCXcaseno As String) As Long
'12Jul02 CKJ Written
'            Takes a caseno which may be new, exisiting or invalid
'            If invalid then it returns 0 & no globals are changed, otherwise
'            it adds patient or updates existing patient using OCX data
'            and returns pointer into patid.v5 for that patient.
'            Globals PID and PIDextra are populated on return.
'14Feb03 CKJ Derived from AddOrUpdatePatientFromOCX, but uses heap based data transfer instead
'            This removed the need for name parsing routines and overloaded data structures
'6Nov14  XN  Added BSA (83897)

Dim blnSuccess As Integer
'Dim lngPIDptr As Long
Dim lngPIDptrsearch1 As Long
Dim lngPIDptrsearch2 As Long
Dim msg As String, contnum&
Dim blnDateValid As Integer
Dim strDate As String

Stop '!!**
   blnSuccess = True
''   CleanTheSlate                                         'initialise PID, PIDextra, PIDnotes, PIDepisode, PIDwas, Sch, patient globals

   blnSuccess = CheckCasenoStructure(i_strOCXcaseno)     'is caseno usable?
   If blnSuccess Then                                    'is it new/unique/duplicated?
         'derived from scanfordupcaseno but without loading Ident.frm
         contnum& = 0
         lngPIDptrsearch1 = 0
         lngPIDptrsearch2 = 0
         If lngPIDptrsearch2 > 0 Then                                      'found another with same caseno (NB could be BatchPN)
               msg = "WARNING - Two or more patients with same Case Number already registered:" & cr & cr
               msg = msg & "Please resolve this ambiguity using the Pharmacy tools" & cr
               msg = msg & "then repeat the request from the external system." & cr & cr
               msg = msg & "Duplicated Case Number is " & i_strOCXcaseno
               popmessagecr "Duplicate Case Number", msg
               blnSuccess = False
      
            ElseIf lngPIDptrsearch1 > 0 Then                               'one matching patient
               patno& = lngPIDptrsearch1                                   'load patient specified
               GetPatIDNL patno&, pid
''               GetPIDExtra PID.recno, pidExtra
''               GetPIDNotes PID.recno, pidNotes
''               pidwas = pid

            Else                                                           'must be a new patient
               pid.caseno = i_strOCXcaseno
               patno& = 0
               '!!** internal record number
            End If
      End If

   If blnSuccess Then                                    'set all appropriate fields from OCXheap, over blank PID or existing PID
         'On Error GoTo OCX_UpdateDetailsFromOCX_Err
         pid.surname = OCXheap("pSurname", pid.surname)
         pid.forename = OCXheap("pForename", pid.forename)
         parsedate OCXheap("DateOfBirth", pid.dob), pid.dob, "3", 0        'convert canonical to DDMMCCYY
         parsedate pid.dob, strDate, "1", blnDateValid                     'convert DDMMCCYY to DD/MM/CCYY
         If Not blnDateValid Then strDate = ""
         Heap 10, g_OCXheapID, "parsedDateOfBirth", strDate, 0
         
         pid.sex = OCXheap("pSex", pid.sex)
         If Trim$(pid.sex) = "" Then pid.sex = "U"
         pidExtra.NHnumber = OCXheap("pNHnumber", pidExtra.NHnumber)
         pidExtra.NHnumValid = OCXheap("pNHnumValid", pidExtra.NHnumber)
         
         pid.ward = OCXheap("pWard", pid.ward)
         pid.cons = OCXheap("pCons", pid.cons)
''         pid.GP = OCXheap("pGP", pid.GP)
         pid.weight = OCXheap("pWeightkg", pid.weight)
         pid.Height = OCXheap("pHeightcm", pid.Height)
         pid.SurfaceAreaInM2 = OCXheap("BSA", pid.SurfaceAreaInM2)      ' XN 6Nov14 Added BSA (83897)
         pid.Status = OCXheap("pStatus", pid.Status)
         pidExtra.Speciality = OCXheap("pSpeciality", pidExtra.Speciality)
         pid.HouseNumber = OCXheap("pHouseNo", pid.HouseNumber)
         pidExtra.Address1 = OCXheap("pAddress1", pidExtra.Address1)
         pidExtra.Address2 = OCXheap("pAddress2", pidExtra.Address2)
         pidExtra.Address3 = OCXheap("pAddress3", pidExtra.Address3)
         pidExtra.Address4 = OCXheap("pAddress4", pidExtra.Address4)
         pid.postCode = OCXheap("pPostCode", pid.postCode)
         
         gTlogCaseno$ = pid.caseno
         gTlogSpecialty$ = pidExtra.Speciality
         gTlogEpisode$ = i_strOCXcaseno
         gTlogEventNumber$ = ""                          'HK use only
         gTlogPPFlag$ = pidExtra.PPflag                  '21Dec98 CFY Added
      
         'not supported except in HK mode
         'If Not ReadLanguage(22, OCXIn.LanguageFlag) Then      'language could not be set - stay with default
         '      'no action needed
         '   End If
      
         ' "pTitle", pidExtra.Title                             'not supported in this version
         ' "pAliasSurname", pidExtra.AliasSurname
         ' "pAliasForename", pidExtra.AliasForename
         pidExtra.allergy = OCXheap("pAllergy", pidExtra.allergy)    '22Sep03 CKJ
         '  PIDextra.EthnicOrigin
         '  PIDextra.PPflag
         pidExtra.diagnosis = OCXheap("pDiagnosis", pidExtra.diagnosis) '22Sep03 CKJ
         '  pEpisodeNum
''         pidNotes.notes = OCXheap("pNotes", pidNotes.notes)          '22Sep03 CKJ
''         replace pidNotes.notes, "[cr]", crlf, 0
''         replace pidNotes.notes, "[160]", Chr$(160), 0
''         Heap 10, g_OCXheapID, "pNotes", pidNotes.notes, 0
         '!!**92
      End If
         
   If blnSuccess Then
         blnSuccess = CheckPatientData()                             'is record fit for saving?
         If blnSuccess Then
''               SavePatient PID, patno&, pidwas, blnSuccess           'save details
               If blnSuccess Then
''                     PutPIDExtra PID.recno, pidExtra
                     FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0
                  End If
            End If
      End If

   If Not blnSuccess Then patno& = 0
   AddOrUpdatePatientFromSessionExtension = patno&

End Function

''Sub CancelTransactions(PatRecNo$, prescriptionid&, RecoveryTime$)
'''23Nov98 CKJ Written based on ReturnPNregimen
'''            Given Patient recno and prescriptionID (must not be zero)
'''            scan translog for today and cancel all issues/returns which
'''            match criteria and are for this site. The T.kind is set to '0'
'''            NB items are returned at current cost, not at original price
'''01Feb99 EAC Only Cancel transactions after a certain time
''
''Dim tofind$, FileName$, errcode%, msg$, fil%, length%, recno&
''Dim tmp$, logfile$, logfil%, lngDrugRecno As Long, Qty!, CancelLog%, cost!, adjust!
''Dim t As transaction, dlocal As DrugParameters
''
''   CancelLog = True  'needs ini file setting to choose...
''
''   tofind$ = "PATRECNO=" & PatRecNo$ & ",PRESCID=" & Format$(prescriptionid&)
''
''   If Trim$(RecoveryTime$) <> "" Then tofind$ = tofind$ & "," & RecoveryTime$
''
''                            'daymth       site OPformat
''''   errcode = ScanLogFile("T", "", tofind$, "", Iff(CancelLog, 2, 1), FileName$)
''   Select Case errcode
''      Case 1: msg$ = "Type of log file not specified or not supported"
''      Case 2: msg$ = "Date given is not valid"
''      Case 3: msg$ = "Output format requested is not valid"
''      Case 4: msg$ = "Log file specified was not found"
''      Case 0
''         If fileexists(FileName$) Then
''               Screen.MousePointer = HOURGLASS
''               If CancelLog Then
''                     fil = FreeFile
''                     Open FileName$ For Input As #fil                                 'input channel
''                     Line Input #fil, logfile$                                        'read log file name
''                     length = Len(t)
''                     logfil = FreeFile
''                     openrandomfile logfile$, length, logfil                          'logfile channel
''
''                     Do While Not EOF(fil)
''                        Line Input #fil, tmp$
''                        recno& = Val(tmp$)                                            'record number to amend
''                        If recno& > 1 Then
''                              GetRecordL r, recno&, logfil, length
''                              LSet t = r
''                              tmp$ = t.kind
''                              t.kind = "0"                                            'mark record as cancelled
''                              LSet r = t
''                              PutRecordL r, recno&, logfil, length
''
''                              If Val(t.Qty) <> 0 And tmp$ <> "0" Then                 'Qty present, and not already cancelled
''                                    dlocal.SisCode = t.SisCode
''                                    getdrug dlocal, 0, lngDrugRecno, True             'lock the drug
''                                    If lngDrugRecno Then
''                                          Qty! = Val(t.Qty)                           'in issue units
''                                          cost! = Val(t.CostExVAT)                    'total pence for the transaction
''
''                                          'stock level = stock level + qty
''                                          'usethisperiod = usethisperiod - qty
''                                          'issue price is unchanged
''                                          'gains losses will absorb original value - current value of the items
''                                          'gains losses = gains losses + T.CostExVAT - issue price now * qty/packsize
''                                          'if issue price has not changed, and no gains/losses were apportioned originally
''                                          ' then gains losses will not be altered now.
''                                          'Returning' stock now is no problem as stock level is increasing.
''                                          'Issuing' stock now may take stock level below zero.
''                                          ' This will happen and the user will be notified.
''
''                                          If Val(dlocal.convfact) > 0 Then
''                                                adjust! = cost! - Val(dlocal.cost) * Qty! / Val(dlocal.convfact)
''                                                dlocal.lossesgains = dlocal.lossesgains + adjust!
''                                             Else
''                                                Screen.MousePointer = STDCURSOR
''                                                popmessagecr "WARNING", "Stores pack size not entered for product '" & t.SisCode & "'"
''                                             End If
''
''                                          dlocal.stocklvl = LTrim$(Str$(dp!(1! * Val(dlocal.stocklvl) + Qty!)))
''                                          dlocal.usethisperiod = dlocal.usethisperiod - Qty!
''                                          putdrug dlocal
''
''                                          If Qty! < 0 And Val(dlocal.stocklvl) < 0 And dlocal.livestockctrl = "Y" Then   'it's been issued into negative
''                                                Screen.MousePointer = STDCURSOR
''                                                popmessagecr "!WARNING", "Product " & t.SisCode & "  " & Trim$(dlocal.Description) & cr & "is now at a negative stock level." & cr & "This must be corrected manually."
''                                             End If
''                                       Else
''                                          Screen.MousePointer = STDCURSOR
''                                          popmessagecr "!", "Product code '" & t.SisCode & "' not found"
''                                       End If
'''                                      End If
''                                 End If
''                           End If
''                     Loop
''
''                     Close fil
''                     Close logfil
''                     Kill FileName$
''
''                  Else
''                     'Could do a balancing transaction here instead - See ReturnPNregimen if interested
''                  End If
''
''               Screen.MousePointer = STDCURSOR
''            Else
''               msg$ = "Unable to open temporary file " & FileName$
''            End If
''      End Select
''
''   If Len(msg$) Then popmessagecr "!", msg$
''
''End Sub

Function CheckCasenoStructure(ByVal strCaseNo As String) As Integer
'12Jul02 CKJ Check that there is a caseno which conforms to the standards required
'            Returns success = T/F


Dim msg$, counter%, onechar$, IsNumber%, caseno$

   msg$ = ""
   caseno$ = UCase$(Trim$(strCaseNo))

   Select Case Len(caseno$)
      Case 0
         msg$ = "Case Number is blank." & cr
      
      Case Is > 10
         msg$ = "Invalid Case Number more than ten characters long: " & caseno$ & cr
      
      Case Else
         If caseno$ = "?" Then
               msg$ = "A temporary Case Number cannot be assigned automatically." & cr
            Else
               IsNumber = 0
               For counter = 1 To Len(caseno$)
                  onechar$ = Mid$(caseno$, counter, 1)
                  IsNumber = (InStr("0123456789", onechar$) > 0)
                  If IsNumber Then Exit For
               Next
      
               If Not IsNumber Then
                     msg$ = "The Case Number must contain at least one digit: " & caseno$ & cr
                  Else
                     '25Aug99 CKJ Check number algorithm added
                     Select Case UCase$(TxtD(dispdata$ & "\ascribe.ini", "PID", "", "CaseNoCheckCharacter", 0))
                        Case ""   'No action required
                        Case "UMRN"                                                 'Australian Universal Medical Record Number
                           If Len(caseno$) = 10 And Left$(caseno$, 1) = "@" Then    'is this a temporary caseno?
                                 'temporary caseno - no action needed
                              Else                                                  'if not, does it match the UMRN strucure
                                 If PatternMatch(caseno$, "A9999999") Then
                                       If Left$(caseno$, 1) <> CheckCharacter(Mid$(caseno$, 2), "UMRN") Then
                                             msg$ = msg$ & "Case Number check character is incorrect: " & caseno$ & cr
                                          End If
                                    Else
                                       msg$ = msg$ & "Case Number does not match UMRN pattern of 'A1234567': " & caseno$ & cr
                                    End If
                              End If
                        'Case "????"  Add more algorithms here
                        Case Else
                           msg$ = msg$ & "Unknown Case Number check method specified in ASCRIBE.INI" & cr
                        End Select
                  End If
            End If
      End Select

   If Len(msg$) Then
         popmessagecr "!", msg$
         CheckCasenoStructure = False
      Else
         CheckCasenoStructure = True
      End If

End Function

Private Function CheckPatientData() As Integer
'12Jul02 CKJ Derived from ValidateDetails in Ident.frm, but uses the structures not the text boxes
'        Temporary caseno is not permitted. Batch mode not supported
'        Displays messagebox if any fields fail checking
'        Returns success T/F
'08Aug02 CKJ Corrected logic

Dim age$, NumericalAge!, tempdate$, msg$
Dim dob$, ret$
Dim heightcms!, HtHiLow%, WtHiLow%, ans$
Dim inuse%, FoundWard%                                  '11Oct99 CKJ added
Dim specprompt%  '17Jan01 TH
Dim success As Integer

   success = True
   msg$ = ""

   '!!** internal record number too?
   'Caseno has its own check procedure

   If Trim$(pid.surname) = "" Then                     'surname present
         msg$ = msg$ & "Patient surname is missing." & cr
      End If

   If pid.dob <> "" Then
         dob$ = pid.dob
''         verifydob dob$, age$, NumericalAge!
         If dob$ = "" Then                        'not valid
               msg$ = msg$ & " "                  'to force success=false
            End If
      End If

   ipEthnicOrg (pidExtra.EthnicOrigin), ret$, False
   If (Trim$(pidExtra.EthnicOrigin) <> "" And ret$ = "<Invalid Code>") Or InStr(ret$, "#") > 0 Then   'valid code not present
         msg$ = msg$ & EthnicOrgCaption() & " code is invalid: " & pidExtra.EthnicOrigin & cr
      End If
   
   ipspecialty (pidExtra.Speciality), ret$, False
   specprompt = TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "SpecialtyPrompt", 0))
   If ((Trim$(pidExtra.Speciality) <> "" Or specprompt) And ret$ = "<Invalid Code>") Or InStr(ret$, "#") > 0 Then
         msg$ = msg$ & "Specialty code is invalid: " & pidExtra.Speciality & cr
      End If

   GetWardDescription (pid.ward), ret$, inuse, FoundWard       'now detects not-in-use wards
   If Trim$(pid.ward) = "" Or Not inuse Or Not FoundWard Then
         msg$ = msg$ & "Ward code is not " & Iff(inuse, "valid: ", "in use: ") & pid.ward & cr
      End If
   
''   ipcons (pid.cons), ret$, False
   If Trim$(pid.cons) = "" Or ret$ = "<Invalid Code>" Or InStr(ret$, "#") > 0 Then   'valid cons code not present
         msg$ = msg$ & "Consultant code is not valid: " & pid.cons & cr
      End If

   If Val(pid.weight) = 0 And Identtype$ = "4" Then
         msg$ = msg$ & "Weight must be entered for Parenteral Nutrition." & cr
      End If
      
   If InStr(1, "IODLXZH", pid.Status, 1) = 0 Then                                'status present   '08Aug02 CKJ Corrected logic
         msg$ = msg$ & "Patient status code is not valid: " & pid.Status & cr
      End If
   
   tempdate$ = TxtD(dispdata$ & "\ascribe.ini", "PID", "", "PPFlagValidChars", 0)
   If tempdate$ <> "" Then
         If InStr(1, tempdate, pidExtra.PPflag) = 0 Then
               msg$ = msg$ & "Invalid patient flag: " & pidExtra.PPflag & cr
            End If
      End If
   
   If Len(msg$) Then                     'data missing
         'If Len(Trim$(msg$)) Then MsgBox msg$, 48, "ASCribe"
         'If Len(Trim$(msg$)) Then dummy = MessageBox(msg$, 48, "ASCribe")             '14Feb03 CKJ Replaced with standard box
         replace msg$, Nul, " ", 0                                                     '   "        Null chars in text don't work
         If Len(Trim$(msg$)) Then popmessagecr "!", msg$                               '   "        Handles cr properly
         success = False

      Else                               'no data missing, but is it all valid
         'validate weight.               ' 2Jul98 CKJ
         If Val(pid.weight) > 320 Then
               popmessagecr "Incorrect entry", "Invalid weight entered: maximum of 320 kg (50 Stone)"
               success = False
            End If

         'validate height.
         If pid.Height <> "" Then
               If Mid$(pid.Height, 2, 1) = "." And Mid$(pid.Height, 3, 1) = " " Then Mid$(pid.Height, 3, 1) = "0"    '5. 7' -> '5.07'
               
               Select Case Val(pid.Height)
                  Case 0            'no action
                  Case Is < 10      'Feet & Inches
                     If Int(Val(pid.Height)) > 7 Or Int(Val(Mid$(pid.Height, 3))) >= 12 Then
                           popmessagecr "EMIS Health", "Invalid height entered - use feet & inches as [f.in]   e.g. [5.07]"
                           success = False
                        End If
                  Case Is > 225
                     popmessagecr "EMIS Health", "Invalid height entered: over 225cm"
                     success = False
                  Case Else          'no action (10<=cms<=225)
                  End Select
            End If

         'check for high/low weight and height
         If success Then
               Select Case Val(pid.Height)
                  Case Is >= 10     'cms           (10 or above)
                     heightcms = Val(pid.Height)
                  Case Is > 0       'feet & inches (below 10)
                     heightcms = ((Val(Left$(pid.Height, 1)) * 12) + Val(Right$(pid.Height, 2))) * 2.54
                  Case Else         '              (missing)
                     heightcms = 0
                  End Select
               tempdate = pid.dob
''               verifydob tempdate, age$, NumericalAge!
               If age$ <> "" Then
                     msg$ = ""
''                     HtWtHiLo NumericalAge!, heightcms, Val(pid.weight), pid.sex, HtHiLow, WtHiLow, msg$
                     If HtHiLow <> 0 Or WtHiLow <> 0 Then
                           ans$ = "N"
                           askwin "!EMIS Health", msg$ & cr & "OK to continue?", ans$, k
                           If ans$ = "N" Or k.escd Then
                                 success = False
                              End If
                        End If
                  End If
            End If
      End If
                                      
   'Duplicate Caseno check must be carried out in calling procedure

   CheckPatientData = success

End Function

''Private Sub DeleteRecoveryFile()
'''01Feb99 EAC written for E7 mods
''
''   On Error GoTo DRF_Delete_Err
''   Kill RecoveryFile$
''   On Error GoTo 0
''
''Exit Sub
''
''DRF_Delete_Err:
''
''   If Err <> 53 Then popmessagecr "Failed to delete the Recovery File", "Error Number : " & Format$(Err) & cr$ & "Error Msg: " & Error$(Err)
''   Resume Next
''
''End Sub

Sub DestroyOCXheap()
'14Feb03 CKJ

   If g_OCXheapID Then
         Heap 2, g_OCXheapID, "", "", 0
      End If

End Sub


''Private Sub DisableDispens()
'''11Apr02 CKJ Button 5 used to bring up the palette but was removed in Jan98
''
''Dim loopvar%
''
''   Dispens.fraIV.Enabled = False
''   'Dispens.fraLineColour.Enabled = False
''   Dispens.fraPrepared.Enabled = False
''   Dispens.fraRx.Enabled = False
''
''   cmbUC("CmbIssueType").Enabled = False
''   txtUC("txtDrugCode").Enabled = False
''   txtUC("TxtDircode").Enabled = False
''   Dispens.CmbDropDrugCode(0).Enabled = False
''   Dispens.CmbDropDrugCode(1).Enabled = False
''   txtUC("txtQtyPrinted").Enabled = False
''   Dispens.TextBlister.Enabled = False
''   Dispens.chkPIL.Enabled = False
''   Dispens.ChkManual.Enabled = False
''   Dispens.ChkPatOwn.Enabled = False
''   Dispens.txtPrepDate.Enabled = False
''   Dispens.txtPrepTime.Enabled = False
''
''   Dispens.MnuFunctions.Enabled = False
''   Dispens.MnuToolsTitle.Enabled = False
''
''   For loopvar = 0 To 4       'Leave Exit menu enabled
''      Dispens.MnuScript(loopvar).Enabled = False
''   Next
''
''   For loopvar = 0 To 10      'Leave Exit button enabled
''      If loopvar <> 5 Then    '11Apr02 CKJ Button 5 used to bring up the palette but was removed
''            Dispens.CmdPrompt(loopvar).Enabled = False
''         End If               '11Apr02 CKJ
''   Next
''
''   For loopvar = 0 To 9
''      txtUC("txtLabel", loopvar).Enabled = False
''   Next
''
''End Sub

Private Sub DispButtonClick(ButtonNo%)
'Reproduces a click on a dispensary form button
'14feb03 CKJ Button 11 was removed from dispens.frm many versions ago
'            Reinstated this button on dispens.frm as a hidden control

''   On Error GoTo OCX_DispButtonClick_Err
''   Dispens.CmdPrompt(ButtonNo).Value = True
''
''OCX_DispButtonClick_Exit:
''   On Error GoTo 0
''Exit Sub
''
''OCX_DispButtonClick_Err:
''   ErrorObj.Proc = "DispButtonClick"
''   ErrorObj.msg = "ButtonNo% = " & Format$(ButtonNo%)
''   OCXErrorHandler
''Resume OCX_DispButtonClick_Exit

End Sub

''Private Sub EnableDispens()
'''11Apr02 CKJ Button 5 used to bring up the palette but was removed in Jan98
''
''Dim loopvar%
''
''   Dispens.fraIV.Enabled = True
''   Dispens.fraLineColour.Enabled = True
''   Dispens.fraPrepared.Enabled = True
''   Dispens.fraRx.Enabled = True
''
''   cmbUC("CmbIssueType").Enabled = True
''   txtUC("txtDrugCode").Enabled = True
''   txtUC("TxtDircode").Enabled = True
''   Dispens.CmbDropDrugCode(0).Enabled = True
''   Dispens.CmbDropDrugCode(1).Enabled = True
''   txtUC("txtQtyPrinted").Enabled = True
''   Dispens.TextBlister.Enabled = True
''   Dispens.chkPIL.Enabled = True
''   Dispens.ChkManual.Enabled = True
''   Dispens.ChkPatOwn.Enabled = True
''   Dispens.txtPrepDate.Enabled = True
''   Dispens.txtPrepTime.Enabled = True
''
''   Dispens.MnuFunctions.Enabled = True
''   Dispens.MnuToolsTitle.Enabled = True
''
''   For loopvar = 0 To 4       'Leave Exit menu
''      Dispens.MnuScript(loopvar).Enabled = True
''   Next
''
''   For loopvar = 0 To 10      'Leave Exit button
''      If loopvar <> 5 Then    '11Apr02 CKJ Button 5 used to bring up the palette but was removed
''            Dispens.CmdPrompt(loopvar).Enabled = True
''         End If               '11Apr02 CKJ
''   Next
''
''   For loopvar = 0 To 9
''      txtUC("txtLabel", loopvar).Enabled = True
''   Next
''
''End Sub

''Private Sub FillOCXOut(Status$, PMRItem&)
'''Fills the OCX output structure Structure
'''26Jul99 CFY Now uses long integer to hold the PMRitem number rather than an encoded 4 byte string. This is to overcome problems
'''            with Unicode on NT systems.
''
''Dim filno%, Numoflines%
''Dim DrugDesc$, dircode$
''ReDim temp$(10)
''
''   On Error GoTo OCX_FillOCXOut_Err
''
''   r.record = ""
''   LSet OCXOut = r
''
''   OCXOut.OrderID = OCXIn.OrderID
''   'OCXOut.ItemNo = LongToString(PMRItem&)         '26Jul99 CFY Replaced
''   OCXOut.ItemNo = PMRItem&                        '         "
''   OCXOut.PatientID = OCXIn.PatientID
''   OCXOut.UnitCost = 0
''
''   If Status <> "X" And OCXLabelType$ <> "P" Then
''
''         If Trim$(OCXNsvcode$) <> "" Then
''               d.SisCode = OCXNsvcode$
''               getdrug d, 0, 0, False
''            End If
''
''         OCXOut.DrugCode = Left(d.local, 6)
''
''         DrugDesc$ = d.Description
''         plingparse DrugDesc$, "!"
''         OCXOut.DrugDesc = DrugDesc$
''         OCXOut.DrugStrength = d.StrengthDesc
''
''         OCXOut.FormDesc = d.PrintformV
''         OCXOut.tradename = d.tradename
''         OCXOut.DosageValue = OCXDose$                      '!!** Unknown
''         OCXOut.DosageUnit = OCXDosingUnit$                  'PHS dosing unit code
''
''         deflines OCXDirCode$, temp$(), "/(*)", 0, Numoflines
''         If Numoflines >= 2 Then
''               dircode$ = temp$(1)
''            Else
''               dircode$ = ""
''            End If
''
''         OCXOut.FrequencyCode = dircode$
''
''         OCXOut.DurationDays = Format$(OCXDuration%)
''
''         OCXOut.IssueQty = Str$(OCXQty!)
''
''         '27Jul98 EAC
''         'If (UCase$(Left$(d.printformV, 2)) = "ML" And Left$(UCase$(Trim$(d.DosingUnits)), 2) <> "DR") Or UCase$(Left$(d.printformV, 3)) = "TAB" Or UCase$(Left$(d.printformV, 3)) = "CAP" Or UCase$(Left$(d.printformV, 3)) = "SUP" Or UCase$(Left$(d.printformV, 3)) = "MLO" Or UCase$(Left$(d.printformV, 3)) = "MGO" Or UCase$(Left$(d.printformV, 3)) = "PES" Or UCase$(Left$(d.printformV, 3)) = "NEB" Or UCase$(Left$(d.printformV, 3)) = "LOZ" Or UCase$(Left$(d.printformV, 3)) = "SPR" Then    '
''         '      OCXOut.BaseUnit = UCase$(Trim$(d.printformV))
''         '      If UCase$(Trim$(d.DosingUnits)) = "MLO" Then OCXOut.BaseUnit = "mlo"
''         '   Else
''         '      OCXOut.BaseUnit = UCase$(Trim$(d.DosingUnits))
''         '   End If
''         OCXOut.BaseUnit = Trim$(d.PrintformV)
''
''         OCXOut.UnitCost = Val(OCXCost$)
''      End If
''
''   OCXOut.TransactionStatus = Status$
''
''   filno = FreeFile
''   If fileexists("c:\ASCPMS.DAT") Then Kill "c:\ASCPMS.DAT"
''   Open "c:\ASCPMS.DAT" For Binary Access Write Lock Read Write As filno
''   Put #filno%, , OCXOut
''   Close #filno%
''
''''   If InStr(UCase$(Command$), "/OCXDEBUG") Then OCXOutDebug
''
''OCX_FillOCXOut_Exit:
''   On Error GoTo 0
''Exit Sub
''
''OCX_FillOCXOut_Err:
''   ErrorObj.Proc = "FillOCXOut"
''   OCXErrorHandler
''GoTo OCX_FillOCXOut_Exit
''
''End Sub

Function GetOCXAction() As String

   GetOCXAction$ = OCXIn.Action

End Function

Function GetOCXModuleType() As String
'26Aug99 CFY Added trim$
   
   GetOCXModuleType = Trim$(OCXIn.moduletype)

End Function

Function GetOCXPrescriptionID&()

   'GetOCXPrescriptionID = StringToLong(OCXIn.ItemNo)             '26Jul99 CFY Replaced
   GetOCXPrescriptionID = OCXIn.ItemNo                            '         "

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

Function GetTpnExit()
'11Jun99 EAC Prevent exit from dispens.frm after TPN when not HongKong OCX modes

   If Len(OCXIn.moduletype) > 1 Then OCXTpnExit = False     '11Jun99 EAC Added
   GetTpnExit = OCXTpnExit

End Function

Private Sub LaunchASCPrograms(frmLaunchForm As Form, OCXIn As PMStoASCStruct)
'19May99 EAC written for Generic PAS Interface mods
'09Jun99 EAC set global translog variables
'28Jul99 AE added view parameter to call to callmanufacturing
'30Sep99 EAC Allow 5 char codes to be passed as Prescriber id for Oz
'08Oct99 EAC Exit from OCX properly is an error occurs loading the PMR
'28Jan00 EAC Patients notes now being read
'14Jul00 JN  Added reference to form
'17Jul01 CKJ Removed Callmanufacturing form reference (wrong form was being passed through)
'11Jan02 CKJ Ask prescriber id if not provided via OCX and if set in patmed.ini
'12Jul02 CKJ Added OCXcreatePID option
'08Aug02 CKJ Modified message handling

Dim found As Long
Dim Accesslvl As Integer
Dim blnSuccess As Integer                                   '11Jan02 CKJ
Dim strMsg As String                                        '08Aug02 CKJ

   On Error GoTo LASCPErr

   UserID$ = Left$(Trim$(OCXIn.UserID), 3)
   acclevels$ = OCXIn.Accesslvl
   Identtype$ = OCXIn.Identtype
   strMsg = ""

   Select Case OCXIn.moduletype
      Case "PE", "TP"
         'PID.caseno = OCXIn.HospNum               26Jun02 CKJ moved into block below
         'ScanIndexes 2, PID.caseno, 0, found&
         
         '26Jun02 CKJ Added block. Allows use of OCX where patient does not already exist in the V8 files
         If InStr(1, "," & TxtD(dispdata$ & "\ascribe.ini", "PID", "", "OCXcreatePID", False) & ",", "," & OCXIn.moduletype & ",", 1) Then
               found& = AddOrUpdatePatientFromOCX(OCXIn.HospNum)
            Else                                      'Traditional lookup of existing patient only
               strMsg = "Patient was not found"       '08Aug02 CKJ default message in case found&=0
               pid.caseno = OCXIn.HospNum
''               ScanIndexes 2, PID.caseno, 0, found&
            End If
         '26Jun02 ---

         If found& > 0 Then
               'Read the existing patient
               patno& = found&
               GetPatIDNL patno&, pid
''               LSet pidwas = pid
''               GetPIDExtra PID.recno, pidExtra
''               GetPIDNotes PID.recno, pidNotes        '28Jan00 EAC Added

               '09June99 EAC added
               gTlogPPFlag$ = pidExtra.PPflag
               gTlogSpecialty$ = pidExtra.Speciality
               gTlogEpisode$ = pidExtra.EpisodeNum
               gPrescriberID$ = Trim$(OCXIn.MOCode) '30Sep99 EAC allow 5 char codes for Oz - code was Left$(OCXIn.MoCode, 3)
               gTlogCaseno$ = pid.caseno
               '---
               
               '11Jan02 CKJ Added block
               blnSuccess = True
               If gPrescriberID$ = "" Then                  'prescriber id not provided by OCX
                     If Mid$(acclevels$, 1, 1) = "3" And UserID$ <> "" Then    'prescriber level
                           gPrescriberID$ = UserID$
                        Else                                                   'not a prescriber
                           If TrueFalse(TxtD(dispdata & "\" & "patmed.ini", "", "", "AskPrescriberID", 0)) Then
''                                 GetPrescriberDetails False, "", blnSuccess
                                 If blnSuccess Then
''                                       FillHeapPrescriberInfo gPRNheapID, gPrescriberDetails, 0
                                    Else
''                                       SignalASCDone "X", 0, True
                                    End If
                              End If
                        End If
                  End If
               '11Jan02 CKJ end block

               If blnSuccess Then                                          '11Jan02 CKJ added
                     Select Case OCXIn.moduletype
                        Case "PE"
''                           Load Dispens
                           '08Oct99 EAC Added next chunck of code to exit properly if patient's PMR is locked
                           If StopEvents Then                'failed to load eg patient not found
''                                 Unload Dispens
''                                 SignalASCDone "X", 0, True
                                 StopEvents = False
                              End If
                           '---
                        
                        Case "TP"
''                           TpnMain ""                                      '!!** NEEDS WEIGHT
''                           SignalASCDone "X", 0, True
                        End Select
                  End If                                                   '11Jan02 CKJ added
            Else
               'popmessagecr "OCX Mode", "Could not launch dispensary functions as patient was not found."     '08Aug02 CKJ
               popmessagecr "OCX Mode", "Could not launch dispensary functions" & cr & strMsg
''               SignalASCDone "X", 0, True
            End If

      Case "PM"
Stop '**!!**
''         Accesslvl = Val(Mid$(acclevels$, 1, 1))  '03Jul97 KR added
''         If Accesslvl > 0 Then
''               Unload FormAbout '02Oct96 KR Added
''
''               ipdlist.Show 1                            '12Sep98 CFY Added
''               If Not ipdlist.CmdCancel.Cancel Then      '        "
''                     If ipdlist.ChkOutput(12) Then               '        "
''                           CallPickList                  '        "
''                        Else                             '        "
''                           CallIPDlist frmLaunchForm                   '18Jul96 ASC       '14Jul00 JN
''                           15Mar99 SF added
''                           If ipdlist.ChkOutput(13) Then
''                                 SetupRptDispensFrm
''                                 CallRptDispens
''                              End If
''                        End If                           '12Sep98 CFY Added
''                  End If                                 '        "
''               Unload ipdlist                            '        "
''               gRedo = False
''
''            Else
''               popmessagecr "ASCribe", "Password does not have sufficient privilege for access."
''            End If
''         SignalASCDone "X", 0, True

      Case "TB"
         pid.sex = "B"
''         TpnMain ""

      Case "TC"

      Case "MA"
         d.SisCode = ""
         'callmanufacturing frmLaunchForm, d, 9          '28Jul99 AE  added manufacturing view. '9' - Full access to formula '14Jul00 JN amended to refer to form instance
         callmanufacturing d, 9, False                         '17Jul01 CKJ removed form reference
''         SignalASCDone "X", 0, True
      End Select

LASCPExit:

Exit Sub

LASCPErr:

Const ErrTitle$ = "OCX: LaunchASCPrograms"
Dim msg As String

   msg$ = "An error occurred trying to launch the "
   Select Case OCXIn.moduletype
      Case "PE": msg$ = msg$ & "Prescription Entry"
      Case "PM": msg$ = msg$ & "Prescription Management"
      Case "TP": msg$ = msg$ & "Parental Nutrition"
      Case "TB": msg$ = msg$ & "Parental Nutrition Batch"
      Case "MA": msg$ = msg$ & "Manufacturing"
      End Select
   msg$ = msg$ & " module." & cr$ & cr$
   msg$ = msg$ & "Error No: " & Err & cr$
   msg$ = msg$ & "Error Msg: " & Error$(Err) & cr$
   popmessagecr ErrTitle$, msg$
''   SignalASCDone "X", 0, True
Resume LASCPExit

End Sub

Sub LaunchfromOCX(frmName As Form)
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
Dim strBuffer As String
Dim lngBufferLen As Long

   OCXHndl = FreeFile
   Open "C:\ASCOCX" For Binary Access Read Write Lock Read Write As OCXHndl

   On Error GoTo OCX_LaunchFromOCX_Err
   filno = FreeFile
   'Open "c:\PMSASC.DAT" For Binary Access Read Write Lock Read Write As filno     '14feb03 CKJ only read it here
   Open "c:\PMSASC.DAT" For Binary Access Read Lock Read Write As filno
   Get #filno, , OCXIn                                                              '!!** INCOMPATIBLE WITH EXISTING HK OCX!
                                                                  
   strBuffer = ""                                                 '14Feb03 CKJ
   lngBufferLen = LOF(filno) - Len(OCXIn)
   If lngBufferLen > 0 Then
         strBuffer = String$(lngBufferLen, 0)
         Get #filno, , strBuffer
      End If
   Close #filno

''   If InStr(UCase$(Command$), "/OCXDEBUG") Then OCXInDebug
   
   '19May99 EAC Generic PAS Interface mods
   Select Case OCXIn.moduletype
      Case Nul & Nul, "  "                                        '14Feb03 CKJ added double space
         'Error - no moduletype specified  !!** anything needed?

      Case "PE", "PM", "TP", "TB", "TC", "MA"
         LaunchASCPrograms frmName, OCXIn

      'Case Else                                                  'HONG KONG mode only. Multiple checks made in the OCX to ensure data is correct
      Case "P ", "C "                                             '14Feb03 CKJ Case Else now fires new routine below
''         LaunchInPMSmode                                          '   "     "  Moved original Hong Kong code to separate procedure
         
      Case "XS"                                                   '14Feb03 CKJ Added block
''         LaunchFromSessionExtension strBuffer
                                                         
      Case Else
         'No action, don't launch

      End Select
   
OCX_LaunchFromOCX_Exit:
   On Error GoTo 0
Exit Sub

OCX_LaunchFromOCX_Err:
   ErrorObj.Proc = "LaunchFromOCX"
   OCXErrorHandler
''   SignalASCDone STATUS_ABORT, OCXIn.ItemNo, False
Resume OCX_LaunchFromOCX_Exit

End Sub

''Private Sub LaunchFromSessionExtension(SessionExtension As String)
'''14Feb03 CKJ Written. Handles OCXIn.moduletype="XS" for the 'Shell' functions
'''16jun03 CKJ use tradename search only if entry present
'''13nov03 CKJ added Load FrmOwner for RxNotes to work
''
''Const ErrTitle$ = "OCX: LaunchFromSessionExtension"
''
''Dim blnSuccess As Integer
''Dim strMsg As String
''Dim lngFound As Long
''Dim frmFormula As Form
''Dim strProduct As String
''Dim blnFound As Integer
''Dim strDate As String
''Dim blnDateValid As Integer
''
''   On Error GoTo LaunchFromSessionExtensionErr
''   strMsg = ""
''   blnSuccess = ParseKeyValuePairsToHeap(SessionExtension, cr, "=", g_OCXheapID)
''
''   If blnSuccess Then
''         UserID$ = Trim$(UCase$(OCXheap("UserID", "")))
''         Select Case Len(UserID$)
''            Case 1 To 3
''               '**!! Match against security module
''               'AccessLevelMask = OCXheap("AccessLevel","")
''               'set user full name & access levels here
''
''               'temp for testing only ...
''               acclevels$ = OCXheap("AccessLevel", "")
''               replace acclevels$, "*", "0", 0
''               replace acclevels$, ">", "1", 0
''               UserFullName$ = ""
''
''            Case Else
''               strMsg = "UserID is of incorrect format: '" & UserID$ & "'"
''               blnSuccess = False
''            End Select
''      Else
''         strMsg = "Session Extension data is not valid"
''      End If
''
''   If blnSuccess Then
''         Select Case UCase$(OCXheap("Module", ""))
''            Case "PMR", "PN"
''               Load FrmOwner                                               '13nov03 CKJ added
''               If InStr(1, "," & txtd(dispdata$ & "\ascribe.ini", "PID", "", "OCXcreatePID", False) & ",", "," & OCXheap("Module", "") & ",", 1) Then
''                     lngFound = AddOrUpdatePatientFromSessionExtension(OCXheap("pCaseno", ""))
''                  Else                                      'Traditional lookup of existing patient only
''                     strMsg = "Patient was not found"       'default message in case found&=0
''                     pid.caseno = OCXheap("pCaseno", "")
''                     ScanIndexes 2, pid.caseno, 0, lngFound&
''                  End If
''
''               If lngFound& > 0 Then
''                     'Read the existing patient
''                     patno& = lngFound&
''                     GetPatIDNL patno&, pid
''                     LSet pidwas = pid
''                     If SlaveModeEnabled() Then                             '22sep03 CKJ
''                           'no action as already set
''                           'RetrievePIDextraPIDnotes pidExtra, pidNotes
''                        Else
''                           GetPIDExtra pid.recno, pidExtra
''                           GetPIDNotes pid.recno, pidNotes        '28Jan00 EAC Added
''                        End If
''
''                     gTlogPPFlag$ = pidExtra.PPflag
''                     gTlogSpecialty$ = pidExtra.Speciality
''                     gTlogEpisode$ = pidExtra.EpisodeNum
''                     gTlogCaseno$ = pid.caseno
''                     gPrescriberID$ = OCXheap("PrescriberID", "") 'default needed perhaps? See old routine
''    'xxxxxxxxxxxxx
''                     If gPrescriberID$ = "" Then                  'prescriber id not provided by OCX
''                           If Mid$(acclevels$, 1, 1) = "3" And UserID$ <> "" Then    'prescriber level
''                                 gPrescriberID$ = UserID$
''                              Else                                                   'not a prescriber
''                                 If TrueFalse(txtd(dispdata & "\" & "patmed.ini", "", "", "AskPrescriberID", 0)) Then
''                                       GetPrescriberDetails False, "", blnSuccess
''                                       If blnSuccess Then
''                                             FillHeapPrescriberInfo gPRNheapID, gPrescriberDetails, 0
''                                          Else
''                                             SignalASCDone "X", 0, True
''                                          End If
''                                    End If
''                              End If
''                        End If
''
''                     'If PN is permitted but PMR isn't then grant level 1 for PMR usage here
''                     If Val(Left$(acclevels$, 1)) = 0 And Val(Mid$(acclevels$, 4, 1)) > 0 Then Mid$(acclevels$, 1, 1) = "1"
''
''                     'If PMR access is still denied then warn & flag for exit
''                     If Val(Left$(acclevels$, 1)) = 0 Then
''                           strMsg$ = "Password does not have sufficient privilege for access"
''                           blnSuccess = False
''                        End If
''                  Else
''                     blnSuccess = False
''                  End If
''            End Select
''      End If
''
''   If blnSuccess Then
''         Select Case UCase$(OCXheap("Module", ""))
''            Case "PMR"
''               Identtype$ = "1"
''               Load Dispens
''
''               'Added to exit properly if patient's PMR is locked
''               If StopEvents Then                'failed to load eg patient not found
''                     Unload Dispens
''                     SignalASCDone "X", 0, True
''                     StopEvents = False
''                  Else
''                     blnFound = False
''                     If Val(OCXheap("lPrescriptionid", "0")) > 0 Then       'prescriptionID specified so use it
''                           MoveToRx Val(OCXheap("lPrescriptionid", "0")), blnFound, False 'don't search history
''                        End If
''
''                     If Not blnFound Then
''                           parsedate OCXheap("lStartDate", ""), strDate, "1", blnDateValid   'convert date from canonical form
''                           If Not blnDateValid Then strDate = ""
''                           Heap 10, g_OCXheapID, "parsedStartDate", strDate, 0
''                           parsedate OCXheap("lStopDate", ""), strDate, "1", blnDateValid
''                           If Not blnDateValid Then strDate = ""
''                           Heap 10, g_OCXheapID, "parsedStopDate", strDate, 0
''
''                           'escalating sequence of checks
''                           strProduct = OCXheap("iBNF", "")                               'find if BNF is specified
''                           If Len(strProduct) Then strProduct = "BNF" & strProduct        'if so add BNF to code ** NB section search not implemented ** (See SelectBNFSection)
''                           strProduct = OCXheap("iChemical", strProduct)
''                           strProduct = OCXheap("iDescription", strProduct)               '** May wish to truncate at first word boundary **
''                           If Len(OCXheap("iTradename", "")) Then
''                                 strProduct = "?" & OCXheap("iTradename", "")             '16jun03 CKJ use tradename search only if entry present
''                              End If
''                           If Len(OCXheap("iLocalCode", "")) Then
''                                 strProduct = txtd(dispdata$ & "\StkMaint.ini", "Data", "=", "LocalCodePrefix", 0) & OCXheap("iLocalCode", strProduct)
''                              End If
''                           strProduct = OCXheap("iCode", strProduct)
''                           strProduct = OCXheap("iBarcode", strProduct)
''                           strProduct = OCXheap("iNSVcode", strProduct)     'Use NSVcode if present
''                           replace strProduct, " ", Nul, 0
''                           strProduct = trimz(strProduct)
''                           If Len(strProduct) Then
''                                 Heap 10, g_OCXheapID, "ProductLookup", strProduct, 0
''                                 DispButtonClick 0                          'invoke (N)ew script via PrescribingWizard
''                              Else
''                                 'Allow normal use without wizard
''                              End If
''
''                        End If
''                  End If
''
''            Case "PN"
''               Identtype$ = "4"
''               TpnMain ""                                      '!!** NEEDS WEIGHT
''               SignalASCDone "X", 0, True
''
''            Case "PNBATCH"             '{Reserved} DO NOT USE
''               Identtype$ = "5"
''               pid.sex = "B"
''               TpnMain ""
''               SignalASCDone "X", 0, True
''
''            Case "PM"
''               If Val(Mid$(acclevels$, 1, 1)) > 0 Then
''                     Unload FormAbout '02Oct96 KR Added
''
''                     ipdlist.Show 1                            '12Sep98 CFY Added
''                     If Not ipdlist.CmdCancel.Cancel Then      '        "
''                           If ipdlist.ChkOutput(12) Then       '        "
''                                 CallPickList                  '        "
''                              Else                             '        "
''                                 Set frmFormula = New Formula
''                                 CallIPDlist frmFormula
''                                 Set frmFormula = Nothing
''                                 If ipdlist.ChkOutput(13) Then '15Mar99 SF added
''                                       SetupRptDispensFrm
''                                       CallRptDispens
''                                    End If
''                              End If                           '12Sep98 CFY Added
''                        End If                                 '        "
''                     Unload ipdlist                            '        "
''                     gRedo = False
''
''                  Else
''                     strMsg$ = "Password does not have sufficient privilege for access"
''                  End If
''               'SignalASCDone "X", 0, True
''
''            Case "MANUFACTURING"       '{Reserved} DO NOT USE
''               d.SisCode = ""
''               callmanufacturing d, 9
''               'SignalASCDone "X", 0, True
''
''            Case Else                  'Exit without action
''               strMsg$ = "Module requested is not recognised: " & OCXheap("Module", "")
''
''            End Select
''      End If
''
''LaunchFromSessionExtensionExit:
''   If Len(strMsg$) > 0 Or blnSuccess = False Then
''         popmessagecr "!" & ErrTitle$, "Could not launch dispensary function" & cr & strMsg
''         SignalASCDone "X", 0, True
''      End If
''Exit Sub
''
''LaunchFromSessionExtensionErr:
''   strMsg = "An error occurred trying to launch ASCshell" & cr$ & cr$
''   strMsg = strMsg & "Error No: " & Err & cr$
''   strMsg = strMsg & "Error Msg: " & Error$(Err) & cr$
''Resume LaunchFromSessionExtensionExit
''
''End Sub

''Private Sub LaunchInPMSmode()
'''14Feb03 CKJ Moved code from LaunchfromOCX
'''            This procedure now handles Hong Kong PMS mode only
''
''Dim found&, success%
''Dim foundit%, loopvar%, tmpptr&
''Dim UnitCost$, caseno$, RecoveryTime$
''Dim PresID&
''
''   SetTPNExit False
''
''   patno& = 0                                   '10Jan99 CFY Added
''   r.record = ""                                '         "
''   LSet pidwas = r                              '         "
''   LSet pid = r                                 '         "
''   LSet pidExtra = r                            '         "
''   tempOCXStatus = ""                           '23May00 CFY Added
''
''   'Search for requested patient
''   pid.caseno = Mid$(OCXIn.HospNum, 3)          'EAC HK HospNum is 12 char, take last 10
''   ScanIndexes 2, pid.caseno, 0, found&
''   If found& > 0 Then
''         'Update the existing patient
''         patno& = found&
''         GetPatIDNL patno&, pid
''         LSet pidwas = pid
''         GetPIDExtra pid.recno, pidExtra
''         updatedetailsfromOCX
''         SavePatient pid, patno&, pidwas, success
''      Else
''         'Create the new patient
''         patno& = 0
''         r.record = ""
''         LSet pid = r
''         LSet pidExtra = r
''         pidExtra.IDnum = 0
''         pidExtra.SurfaceArea = 0
''         updatedetailsfromOCX
''         SavePatient pid, patno&, pidwas, success
''      End If
''
''   iOCXRunning = True                                                                              '01Feb99 CFY Added
''
''   PutPIDExtra pid.recno, pidExtra
''   Load Dispens
''   DoEvents: DoEvents: DoEvents
''   If k.escd Then                                                                            '27Apr99 CFY Added
''         ErrorObj.msg = "A problem has occured whilst trying to load the Patient Medication" '         "
''         ErrorObj.msg = ErrorObj.msg & "screen. The system is therefore unable to continue." '         "
''         GoTo LaunchInPMSmode_Err       '<=== WAY OUT                                        '         "
''      End If                                                                                 '         "
''
''   acclevels$ = "0002000000"
''   Identtype$ = "1"                       '02Mar99 EAC was 4
''   UserID$ = Left$(Trim$(OCXIn.UserID), 3)
''
''   Select Case OCXIn.Action
''      Case "N", "M", "D"
''         'WriteRecoveryFile 0, StringToLong(OCXIn.ItemNo), pid.recno, Format$(Now, "HHMMSS")    '26Jul99 CFY Replaced
''         WriteRecoveryFile 0, OCXIn.ItemNo, pid.recno, Format$(Now, "HHMMSS")                   '         "
''      Case "R"
''         'Do nothing as it is handled below
''      Case Else
''         DeleteRecoveryFile
''      End Select
''
''   If OCXIn.Action <> "E" Then EnableDispens
''
''   Select Case OCXIn.Action
''      Case "M"
''         'Modify - loading of known previous medication
''         'MoveToRx StringToLong(OCXIn.ItemNo), foundit%              '21Jul99 SF replaced
''         MoveToRx OCXIn.ItemNo, foundit%, False        '21Jul99 SF
''         '?? What do we do if the rx couldn't be found.
''         DoEvents
''         If foundit Then
''               DispButtonClick Click_Amend
''               DoSaferEvents 1                                    '01Feb00 CFY Added
''               On Error Resume Next                               '02Mar00 CFY Added
''               txtUC("TxtDircode").SetFocus                        '         "
''               On Error GoTo LaunchInPMSmode_Err                  '02Mar00 CFY Added
''            Else
''               popmessagecr "OCX Interface", "The specified prescription Id was not found."
''               DispButtonClick Click_Exit
''            End If
''
''      Case "N"
''         'New - loading of a known patient and creation of a prescripion record from the
''         '      details of the drug supplied
''         DispButtonClick Click_New
''         DoEvents
''         SetRxType
''         DoEvents
''
''         On Error Resume Next
''         DoSaferEvents 1
''         txtUC("txtDrugCode").SetFocus
''         On Error GoTo 0
''         DoEvents
''
''      Case "D"
''         'Delete - Discontinue the prescripion putting in todays stop and and sending to history
''         tmpptr& = OCXIn.ItemNo
''         MoveToRx tmpptr&, foundit%            '21Jul99 SF replaced
''         MoveToRx OCXIn.ItemNo, foundit%, False      '21Jul99 SF
''         DoSaferEvents 1: FreeLocks
''         DoEvents
''         If foundit Then
''               Labf& = OCXIn.ItemNo
''               getlabel Labf, L, False
''               PresID& = L.prescriptionid
''               L.lastqty = 0
''               Putlabel L
''               DispButtonClick Click_Discontinue
''               '01Feb99 EAC added for E7 mod
''               If OCXIn.moduletype = "C" Then           '01Sep99 CFY Replaced
''               If Trim$(OCXIn.moduletype) = "C" Then     '         "
''                     CancelTransactions pid.recno, PresID&, ""
''                  Else
''                     ReturnPNRegimen pid.recno, PresID&, ""
''                  End If
''               ---
''            End If
''
''      Case "R"
''         'Recovery - Check to see if patient and prescription is already there and if not create them
''         For loopvar = 1 To 2
''            Select Case loopvar
''               Case 1
''                  ReadRecoveryFile PresID&, tmpptr&, caseno$, RecoveryTime$
''                  DeleteRecoveryFile
''               Case 2
''                  'tmpptr& = StringToLong(OCXIn.ItemNo)     '26Jul99 CFY Replaced
''                  tmpptr& = OCXIn.ItemNo                    '         "
''                  PresID& = 0
''                  caseno$ = pid.recno
''                  RecoveryTime$ = OCXIn.RecoveryTime
''               End Select
''
''            If PresID& = 0 Then
''                  Labf& = tmpptr&
''                  If Labf& > 0 Then
''                        getlabel Labf, L, False
''                        PresID& = L.prescriptionid
''                     End If
''               End If
''
''            If PresID& > 0 And Trim$(RecoveryTime$) <> "" And Len(RecoveryTime$) = 6 Then
''                  'MoveToRx tmpptr&, foundit%
''                  'DoSaferEvents 1: FreeLocks
''                  'If foundit Then DispButtonClick Click_Discontinue
''
''                  If Trim$(caseno$) = "" Then caseno$ = pid.recno
''
''                  'If OCXIn.ModuleType = "P" Then                                      '15Oct98 CFY Added         '01Sep99 CFY Replaced
''                  If Trim$(OCXIn.moduletype) = "P" Then                                                           '         "
''                        ReturnPNRegimen caseno$, PresID&, "TIME>=" & OCXIn.RecoveryTime            '        "         19Nov98 CKJ was pid.caseno '01Feb99 EAC Added RecoveryTime
''                     Else                                                           '                    '        "
''                        CancelTransactions caseno$, PresID&, "TIME>=" & OCXIn.RecoveryTime                '23Nov98 CKJ Replaced Translog below '01Feb99 EAC Added RecoveryTime
''                        If foundit Then
''                              'return item quantity
''                              'd.SisCode = l.SisCode
''                              'getdrug d, 0, fnd, False
''                              'If l.lastqty <> 0 Then                         '23Nov98 CKJ Use CancelTransactions instead
''                              '      Translog d, 0, userid$, pid.recno, -1! * (l.lastqty), (l.dircode), (pid.ward), (pid.cons), (pid.status), sitenumber%, (l.IssType), UnitCost$
''                              '   End If
''                              'discontinue item
''                              SetOCXIssueParameters -1! * (L.lastqty), UnitCost$
''                              SetOCXLabelParameters L.SisCode, L.IssType, L.dircode$, (txtUC("txtDose", 1).Text), (lblUC("RxUnits", 1).Caption), L.startdate, L.StopDate
''                              L.lastqty = 0
''                              Putlabel L
''                           End If
''                     End If
''                  'MoveToRx tmpptr&, foundit%               '21Jul99 SF replaced
''                  MoveToRx tmpptr&, foundit%, False         '21Jul99 SF
''                  DoSaferEvents 1: FreeLocks
''                  If foundit Then DispButtonClick Click_Discontinue
''               End If
''         Next
''
''         'send back an abort
''         Unload Dispens
''
''         'SignalASCDone "R", StringToLong(OCXIn.ItemNo), False          '26Jul99 CFY Replaced
''         SignalASCDone "R", OCXIn.ItemNo, False                         '         "
''
''      Case "E"
''         'Enquiry - Show a read only view of prescription
''         DisableDispens
''
''      End Select
''
''      '3/ Creation of a patient record based on the details supplied and creation of a prescripion record from the details of the drug supplied
''
''
''LaunchInPMSmode_Exit:
''   On Error GoTo 0
''Exit Sub
''
''LaunchInPMSmode_Err:
''   ErrorObj.Proc = "LaunchFromOCX"
''   OCXErrorHandler
''   SignalASCDone STATUS_ABORT, OCXIn.ItemNo, False
''Resume LaunchInPMSmode_Exit
''
''End Sub

''Sub MoveToRx(rxnum As Long, found%, searchHistory%)
'''Description : Highlights the requested prescription on the dispensary form grid
'''              and loads the related label.
'''Parameters
'''Input   RXNum : Prescription to be displayed
'''Output  Found : True if rx is found otherwise false
''
'''21Jul99 SF added searchHistory% parameter
'''21Jul99 SF searches history for the rx number to lookup
'''16Nov99 SF if PBS patient billing then lookup on l.prescriptionid
'''16Nov99 SF now sets labf& so F3 information can be looked up straight away
'''19Nov99 SF/CKJ added to allow the refresh the pmr correctly when moving to an rx#
'''19Mar01 SF now looks up patient billing settings from the dispdata rather than the patdata
''
''Dim i%, Value&
''
''   On Error GoTo OCX_MovetoRx_Err
''   found = False
''
''   For i = 1 To UBound(LstRX$)
''      If TrueFalse(txtd(dispdata$ & "\PATBILL.INI", "PatientBilling", "N", "LookupOnPrescriptionID", 0)) Then
''            Value& = Val(Mid$(LstRX$(i), 133, 9))
''         Else
''            Value& = Val(Right$(LstRX$(i), 9))     '16Nov99 SF moved into the ELSE statement
''         End If
''
''      If Value& = rxnum& Then
''            found = True
''            '16Nov99 SF sets labf& so can use F3 information as soon as we have moved to it
''            If TrueFalse(txtd(dispdata$ & "\PATBILL.INI", "PatientBilling", "N", "LookupOnPrescriptionID", 0)) Then
''                  Labf& = Val(Right$(LstRX$(i), 9))
''               Else
''                  Labf& = Value&
''               End If
''
''            Exit For
''         End If
''   Next
''
''   If found Then
''         FirstLoaded = True      '19Nov99 SF/CKJ added to allow the refresh the pmr correctly when moving to an rx#
'''>>         Dispens.TGLabelList.RowIndex = i
''      End If
''
''   '21Jul99 SF added to search for rx in history
''   If searchHistory And (Not found) Then
''         For i = 1 To UBound(labrf&)
''            If labrf&(i) = rxnum& * -1 Then
''                  found = True
''                  Exit For
''               End If
''         Next
''
''         If found Then
''               SendKeys "%VH", True       ' show history view
''               MoveToRx rxnum&, 0, False
''            End If
''      End If
''
''OCX_MoveToRx_Exit:
''   On Error GoTo 0
''Exit Sub
''
''OCX_MovetoRx_Err:
''   ErrorObj.Proc = "MoveToRx"
''   OCXErrorHandler
''   'GoTo OCX_MoveToRx_Exit        '14feb03 CKJ
''Resume OCX_MoveToRx_Exit          '   "        corrected
''
''End Sub

Sub OCXAcquireLock(pathfile$, LockType, done)
' PathFile: Full pathname of file to lock, filename also used as message.
' Locktype: 0 Release, 1 Acquire shared, 2 Acquire exclusive lock
'                     -1  " keep trying,-2  " keep trying every 5 seconds.
' Returns:  Done T/F where False is because the user escaped
'
'27May04 CKJ Added TrackOpenedFiles

Dim k1 As kbdcontrol
Dim msg$, Msg2$, KeepTrying%, count%, LockChan%, ans$
Static NumLocks%, Locks$(), Lockdata%()

   If done = 1 Then done = True: Exit Sub
   done = True
   msg$ = pathfile$
   Msg2$ = T1("IsLckd", " is locked by another user")
   pathfile$ = UCase$(pathfile$)
   KeepTrying = (LockType < 0)
   LockType = Abs(LockType)
   For count = 1 To NumLocks
      If Locks$(count) = pathfile$ Then
            If Lockdata(1, count) = LockType Then Exit Sub
            If Lockdata(1, count) <> 0 Then  '10Apr95 CKJ Added
                  Close Lockdata(2, count)
                  TrackOpenedFiles Lockdata(2, count), "", ""          '27May04 CKJ
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
            TrackOpenedFiles LockChan, pathfile$, "AcquireLock " & Iff(LockType = 1, "Shared", "Exclusive")          '27May04 CKJ
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
                  Confirm msg$ & Msg2$, T1("RetryLckd", "try again"), ans$, k1
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
'14Feb03 CKJ Read parsed data on the OCX heap. Return default if not found or not set up

Dim strBuffer As String
Dim intsuccess As Integer

   strBuffer = i_strDefault
   If g_OCXheapID Then
         Heap 11, g_OCXheapID, i_strEntry, strBuffer, intsuccess
      End If

   OCXheap = strBuffer

End Function

''Function OCXheapID() As Integer
'''14Feb03 CKJ
''
''   OCXheapID = m_OCXheapID
''
''End Function

''Private Sub OCXInDebug()
''
''Dim msg$
''
''   msg$ = "ModuleType : " & OCXIn.moduletype & cr
''   msg$ = msg$ & "OrderID : " & OCXIn.OrderID & cr
''   'msg$ = msg$ & "ItemNo : " & StringToLong(OCXIn.ItemNo) & cr      '26Jul99 CFY Replaced
''   msg$ = msg$ & "ItemNo : " & OCXIn.ItemNo & cr                     '         "
''   msg$ = msg$ & "PatientID : " & OCXIn.PatientID & cr
''   msg$ = msg$ & "HKPatientID : " & OCXIn.HKPatientID & cr
''   msg$ = msg$ & "PatientName : " & OCXIn.PatientName & cr
''   msg$ = msg$ & "sex : " & OCXIn.sex & cr
''   msg$ = msg$ & "dob : " & OCXIn.dob & cr
''   msg$ = msg$ & "HospNum : " & OCXIn.HospNum & cr
''   msg$ = msg$ & "Speciality : " & OCXIn.Speciality & cr
''   msg$ = msg$ & "WardCode : " & OCXIn.wardcode & cr
''   msg$ = msg$ & "BedNo : " & OCXIn.BedNo & cr
''   msg$ = msg$ & "MOCode : " & OCXIn.MOCode & cr
''   msg$ = msg$ & "MOName : " & OCXIn.MOName & cr
''   msg$ = msg$ & "PatientCat : " & OCXIn.PatientCat & cr
''   msg$ = msg$ & "PatientStatus : " & OCXIn.PatientStatus & cr
''   msg$ = msg$ & "LanguageFlag : " & OCXIn.LanguageFlag & cr
''   msg$ = msg$ & "Action : " & OCXIn.Action & cr
''   msg$ = msg$ & "UserID : " & OCXIn.UserID & cr
''
''   popmessagecr "OCXIn Structure", msg$
''
''End Sub

Function OCXlaunch() As Integer
'Description : Returns true if the system was launched from the OCX
'              otherwise returns false.

   If InStr(UCase$(Command$), "/OCX") Then
         OCXlaunch = True
      Else
         OCXlaunch = False
      End If

End Function

''Private Sub OCXOutDebug()
''
''Dim msg$
''
''   msg$ = "OrderID : " & OCXOut.OrderID & cr
''   'msg$ = msg$ & "ItemNo : " & StringToLong(OCXOut.ItemNo) & cr     '26Jul99 CFY Replaced
''   msg$ = msg$ & "ItemNo : " & OCXOut.ItemNo & cr                    '         "
''   msg$ = msg$ & "PatientID : " & OCXOut.PatientID & cr
''   msg$ = msg$ & "DrugDesc : " & OCXOut.DrugDesc & cr
''   msg$ = msg$ & "DrugCode : " & OCXOut.DrugCode & cr
''   msg$ = msg$ & "DrugStrength : " & OCXOut.DrugStrength & cr
''   msg$ = msg$ & "FormDesc : " & OCXOut.FormDesc & cr
''   msg$ = msg$ & "tradename : " & OCXOut.tradename & cr
''   msg$ = msg$ & "DosageValue : " & OCXOut.DosageValue & cr
''   msg$ = msg$ & "DosageUnit : " & OCXOut.DosageUnit & cr
''   msg$ = msg$ & "FrequencyCode : " & OCXOut.FrequencyCode & cr
''   msg$ = msg$ & "DurationDays : " & OCXOut.DurationDays & cr
''   msg$ = msg$ & "IssueQty : " & OCXOut.IssueQty & cr
''   msg$ = msg$ & "BaseUnit : " & OCXOut.BaseUnit & cr
''   msg$ = msg$ & "UnitCost : " & OCXOut.UnitCost & cr
''   msg$ = msg$ & "TransactionStatus : " & OCXOut.TransactionStatus & cr
''
''   popmessagecr "OCXOut Structure", msg$
''
''End Sub

Function OCXRunning() As Integer
'01Feb99 CFY Written

   OCXRunning = iOCXRunning

End Function

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
   
'popmessagecr Format$(Len(i_strtoparse)), i_strtoparse
'Dim s As String
'Dim i As Integer
'For i = 1 To Len(i_strtoparse)
'   s = s & Str(Asc(Mid$(i_strtoparse, i, 1)))
'Next
'popmessagecr Str(Asc(i_strLineSeparator)) & Str(Asc(i_strKeySeparator)), s

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

Sub ReadRecoveryFile(LabelID&, PresID&, caseno$, RecoverTime$)

Dim rec As RecoveryStruct
Dim fil%

   'Initialise the record
   r.record = ""
   LSet rec = r
   rec.LabelPtr = 0
   rec.prescriptionid = 0

   'Read from file
   On Error Resume Next
   fil = FreeFile
   Open RecoveryFile For Binary Access Read Lock Read Write As fil
   Get #fil, , rec
   Close #fil
   On Error GoTo 0
   
   'return results to user
   LabelID& = rec.LabelPtr
   PresID& = rec.prescriptionid
   caseno$ = Trim$(rec.caseno)
   RecoverTime$ = Trim$(rec.recoveraftertime)

End Sub

Sub RefreshOCXHeapData()
'Description : Adds patient information that is passed in from the OCX but not stored
'              by ASC to the print heap.

Dim success%

   Heap 10, gPRNheapID, "OCXOrdID", OCXIn.OrderID, success
   Heap 10, gPRNheapID, "OCXPatID", OCXIn.PatientID, success
   Heap 10, gPRNheapID, "OCXHKPatID", OCXIn.HKPatientID, success
   Heap 10, gPRNheapID, "OCXHospNum", OCXIn.HospNum, success
   Heap 10, gPRNheapID, "OCXBedNo", OCXIn.BedNo, success
   Heap 10, gPRNheapID, "OCXMOCode", OCXIn.MOCode, success
   Heap 10, gPRNheapID, "OCXMOName", OCXIn.MOName, success
   Heap 10, gPRNheapID, "OCXPatCat", OCXIn.PatientCat, success
   Heap 10, gPRNheapID, "OCXUserID", OCXIn.UserID, success                 'EAC Added
   Heap 10, gPRNheapID, "OCXPatName", OCXIn.PatientName, success           'EAC Added

End Sub

''Sub RetrievePIDextraPIDnotes(localpidExtra As PatIDTypeExtra, localpidNotes As PatidtypeNotes)
'''22sep03 CKJ
''
''Dim strTmp As String
''
''   'Type PatIDTypeExtra
''   localpidExtra.IDnum = 0                           'As Long
''   localpidExtra.PatRecNo = ""                       'As String * 10
''   localpidExtra.createddate = Now
''   localpidExtra.CreatedUserID = ""
''   localpidExtra.createdterminal = ""
''   localpidExtra.UpdatedDate = Now
''   localpidExtra.UpdatedUserID = ""
''   localpidExtra.UpdatedTerminal = ""
''   '----------------------------
''   localpidExtra.NHnumber = ""                       'As String * 10
''   localpidExtra.NHnumValid = ""                     'As String * 4
''   localpidExtra.title = ""                          'As String * 5
''   localpidExtra.Address1 = ""                       'As String * 35
''   localpidExtra.Address2 = ""                       'As String * 35
''   localpidExtra.Address3 = ""                       'As String * 35
''   localpidExtra.Address4 = ""                       'As String * 35
''   localpidExtra.EthnicOrigin = ""                   'As String * 4
''   localpidExtra.AliasSurname = ""                   'As String * 20
''   localpidExtra.AliasForename = ""                  'As String * 15
''   localpidExtra.PPflag = ""                         'As String * 1
''   localpidExtra.EpisodeNum = ""                     'As String * 12
''   localpidExtra.Speciality = ""                     'As String * 4
''   localpidExtra.allergy = OCXheap("pAllergy", "")     'As String * 255
''   localpidExtra.diagnosis = OCXheap("pDiagnosis", "") 'As String * 255
''   localpidExtra.SurfaceArea = 0                     'As Double
''
''   'Type PatidtypeNotes
''   localpidExtra.IDnum = 0                           'As Long
''   localpidExtra.PatRecNo = ""                       'As String * 10
''   localpidExtra.createddate = Now
''   localpidExtra.CreatedUserID = ""
''   localpidExtra.createdterminal = ""
''   localpidExtra.UpdatedDate = Now
''   localpidExtra.UpdatedUserID = ""
''   localpidExtra.UpdatedTerminal = ""
''   '----------------------------
''   strTmp = OCXheap("pNotes", "")
''   replace strTmp, "[cr]", crlf, 0
''   replace strTmp, "[160]", Chr$(160), 0
''   localpidNotes.notes = OCXheap("pNotes", "")       'As String
''
''End Sub

Sub SetOCXIssueParameters(IssuedQty!, IssueCost$)

   OCXQty! = IssuedQty!
   OCXCost$ = IssueCost$

End Sub

Sub SetOCXLabelParameters(SisCode$, labeltype$, dircode$, dose$, doseunit$, StartTime&, StopTime&)

   OCXNsvcode$ = SisCode$
   OCXLabelType$ = labeltype$
   OCXDirCode$ = dircode$
   OCXDose$ = dose$
   OCXDosingUnit$ = doseunit$
   OCXDuration% = (StopTime& - StartTime&) \ (60 * 24) 'Duration in days

End Sub

Sub SetOCXRecoveryTime(hhmmss$)

   OCXRecoveryTime$ = hhmmss$

End Sub

Sub SetOCXStatus(OCXStatus As String)
'03Mar99 EAC Written

   tempOCXStatus = OCXStatus

End Sub

Private Sub SetRxType()
'Description: Sets the Rx type combo box on the dispensing form to the required type

   On Error GoTo OCX_SetRxType_Err
   Select Case Trim$(UCase(OCXIn.moduletype))
      Case "P"
         cmbUC("CmbIssueType").ListIndex = 7  'PN
      Case "C"
         cmbUC("CmbIssueType").ListIndex = 5  'Civas/Cytotoxic
      Case Else
         '!!** Error requested Rx type is not valid
      End Select

OCX_SetRXType_Exit:
   On Error GoTo 0
   Exit Sub

OCX_SetRxType_Err:
   ErrorObj.Proc = "SetRxType"
   OCXErrorHandler
   GoTo OCX_SetRXType_Exit

End Sub

Sub SetTPNExit(OkToExit%)

   OCXTpnExit = OkToExit

End Sub

''Sub SignalASCDone(Status$, pmrptr As Long, ExitOCX)
'''Description : Fills the OCX output structure, closes down the dispensary screen and signals
'''              that ASCribe has finished for this session.
'''Parameters:
'''Input   Status      Status to record what happened in the dispensing screen ie. Issue, abort etc.
'''Input   PMRItem     The Itemnumber of the prescription being dealt with in this session
'''Input   UnitCosts   The cost of the prescription
''Static SignalASCDoneAlready
''
''   If Not SignalASCDoneAlready Then                                        'Prevent Re-entry through DispButtonClick_Exit
''         SignalASCDoneAlready = True
''         FillOCXOut Status$, pmrptr&                                       'Fill the OCX output structure
''         If Status$ <> "X" And ExitOCX Then DispButtonClick Click_Exit     'Reproduce a click event on the exit button
''         Select Case OCXIn.Action
''            Case "N", "M", "D"
''               WriteRecoveryFile L.prescriptionid, pmrptr&, pid.recno, GetOCXRecoveryTime$()
''            End Select
''         SignalASCDoneAlready = False
''         SignalDone                                                        'Signal the OCX that we have finished
''      End If
''
''End Sub

''Private Sub SignalDone()
'''06Sep99 EAC Added line to ensure that we kill ASCShell if not in Hong Kong mode
'''
'''Description: Signals to the OCX that ASCribe has completed and is going to sleep
''
''   On Error Resume Next                         'Kill the intermediate file
''   Kill "c:\PMSASC.DAT"
''   On Error GoTo 0
''
''   On Error GoTo OCX_SignalDone_Err
''   OCXAcquireLock "C:\OCXASC.LCK", 0, 0         'Unlock the OCX lock file and
''''   MDIEvents.Enabled = False                    'disable and minimise the window
''''   MDIEvents.WindowState = 1
''   DestroyOCXheap                               '14feb04 ckj added
''   On Error Resume Next
''   Close OCXHndl
''   Kill "C:\ASCOCX"
''
''''   If Len(OCXIn.moduletype) > 1 Then Unload MDIEvents       '06Sep99 EAC Added to ensure ASCSHELL exits
''
''OCX_SignalDone_Exit:
''   On Error GoTo 0
''Exit Sub
''
''OCX_SignalDone_Err:
''   ErrorObj.Proc = "SignalDone"
''   OCXErrorHandler
''   'GoTo OCX_SignalDone_Exit
''Resume OCX_SignalDone_Exit
''
''End Sub

Function SlaveModeEnabled() As Integer
'22sep03 CKJ Returns boolean, whether slave mode is set for this site
'            True   slave mode set,     normal dispensing
'            False  slave mode not set, under control of OCX

   SlaveModeEnabled = (Val(TxtD(dispdata$ & "\ascribe.ini", "PID", "0", "SlaveMode", 0)) <> 0)

End Function

Function SlaveModeType() As Integer
'22sep03 CKJ Returns slave mode currently in use
'            0      slave mode not set (default)
'            1      slave mode set to one shot, ie enter from OCX, dispense one item and exit
'            2      slave mode set to multiple, ie enter from OCX, stay as long as needed, exit on user command

   SlaveModeType = Val(TxtD(dispdata$ & "\ascribe.ini", "PID", "0", "SlaveMode", 0))

End Function

Private Sub updatedetailsfromOCX()
'20Jun98 ASC Take the HK structure and update the pid structure for either a new patient or to update a current patient.
'07Sep98 CFY Now takes the ward code passed from the OCX and creates a ward record in the supplier
'            file.
'21Dec98 CFY Added gTlogPPFlag$
'19Jul99 CFY Now assigns a default GP code to the patient if it is not present. This is to create an
'            entry in the patient-GP index.
'01Dec99 CFY Now splits patient name if to fit into the fields. Eg. if forename is sent and its too long, now
'            adds the as much as possible to the end of the surname.
'02May00 CFY Hospital number now stored in address line 1 so that it can be displayed later on the label from prescription
'            manager. Temporary solution. Will need revisiting.
'05May00 CFY Removed all processing carried out on patient name as was far to complex and still did not function as intended.
'            Name is now simple written to the 35 bytes that make up the surname and forename.

'Presumptions :
'The name is passed in with format of - surname, forenames

Dim success%

   ReDim patname$(5)

   On Error GoTo OCX_UpdateDetailsFromOCX_Err
   If trimz(pid.caseno) <> "" And trimz(pid.caseno) <> Mid$(OCXIn.HospNum, 3) Then
         pid.oldcaseno = pid.caseno
      End If

   pid.caseno = Mid$(OCXIn.HospNum, 3)          'EAC missout 1st two chars
   gTlogCaseno$ = pid.caseno
   
   'Names:
   ' English - Surname, ForeName     - 35bytes total
   ' Chinese - all as one            - 10bytes total

   If InStr(OCXIn.PatientName, ",") Then
         
         LSet r = pid                                                                                          '05May00 CFY added
         Mid$(r.record, 51) = Left$(OCXIn.PatientName, 15)  'Write to pid.forename                             '         "
         Mid$(r.record, 31) = Mid$(OCXIn.PatientName, 16)   'write to pid.surname                              '         "
         LSet pid = r                                                                                          '         "
         
         '05May00 CFY Removed whole block
         'deflines OCXIn.PatientName, patname$(), ",", 1, numoflines
         'If (Len(patname$(1)) <= 20) And (Len(patname$(2)) <= 15) Then    'Both will fit                       '01Dec99 CFY Added
         '      Pid.surname = patname$(1)
         '      Pid.forename = patname$(2)
         '   End If
         '
         ''Surname is too long.....                                                                             '01Dec99 CFY Added
         'If Len(patname$(1)) > 20 Then                                                                         '         "
         '     If TrueFalse(TxTd$(dispdata$ & "\ascribe.ini", "PID", "N", "SurnameForename", 0)) Then           '         "
         '            Pid.forename = Mid$(patname$(1), 21) & " " & patname$(2)                                  '         "
         '         Else                                                                                         '         "
         '            Pid.forename = patname$(2) & " " & Mid$(patname$(1), 21)                                  '         "
         '         End If                                                                                       '         "
         '      Pid.surname = Left$(patname$(1), 20)                                                            '         "
         '   End If                                                                                             '         "
         ''Forename is too long......                                                                           '         "
         ''(should be mutually exclusive to above condition as it should be impossible for both to be too long) '         "
         'If (Len(patname$(2)) > 15) Then                                                                       '         "
         '      SpaceLeft = 20 - Len(patname$(1))                                                               '         "
         '      If TrueFalse(TxTd$(dispdata$ & "\ascribe.ini", "PID", "N", "SurnameForename", 0)) Then          '         "
         '            Pid.surname = patname$(1) & " " & Left$(patname$(2), SpaceLeft)                           '         "
         '         Else                                                                                         '         "
         '            Pid.surname = Left$(patname$(2), SpaceLeft) & " " & patname$(1)                           '         "
         '         End If                                                                                       '         "
         '      Pid.forename = Mid$(patname$(2), SpaceLeft)                                                     '         "
         '   End If                                                                                             '         "
      Else
         pid.surname = OCXIn.PatientName
         pid.forename = " "
      End If
   
   'Pid.postCode = ""
   'Pid.HouseNumber = ""
   parsedate OCXIn.dob, pid.dob, "3", success
   pid.sex = OCXIn.sex
   If Trim$(pid.sex) = "" Then pid.sex = "U"
   
   pid.ward = OCXIn.wardcode
   If trimz(OCXIn.MOCode) <> "" Then                                                      '19Jul99 CFY Added
         pid.cons = OCXIn.MOCode
      Else                                                                                '19Jul99 CFY Added
         pid.cons = TxtD(dispdata$ & "\siteinfo.ini", "OCX", "NS", "DefaultConsCode", 0)  '         "
      End If                                                                              '         "
   'Pid.GP = ""
   'Pid.weight = ""
   'Pid.height = ""
   pid.Status = OCXIn.PatientStatus

   pidExtra.NHnumber = Left(OCXIn.HKPatientID, Len(pidExtra.NHnumber))
   pidExtra.NHnumValid = Mid$(OCXIn.HKPatientID, Len(pidExtra.NHnumber) + 1)
   'PIDextra.title = ""
   pidExtra.Address1 = OCXIn.HospNum                                                      '02May00 CFY Added
   'PIDextra.Address2 = ""
   'PIDextra.Address3 = ""
   'PIDextra.Address4 = ""
   'PIDextra.EthnicOrigin = ""
   'PIDextra.PPflag = ""
   'EpisodeNum As String * 12
   pidExtra.Speciality = OCXIn.Speciality
   'Allergy As String * 255
   'Notes As String

   gTlogSpecialty$ = pidExtra.Speciality
   gTlogEpisode$ = OCXIn.HospNum
   gTlogEventNumber$ = Mid$(OCXIn.OrderID, 9, 6)
   gTlogPPFlag$ = pidExtra.PPflag                  '21Dec98 CFY Added

   UpdateWardInfo                                  '07Sep98 CFY Added
   
   'Throw all relevent information onto the heap to make it available for printing
   'and set relevent language
   RefreshOCXHeapData
   If Not ReadLanguage(22, OCXIn.LanguageFlag) Then
         '!!** Error language could not be set
      End If
OCX_UpdateDetailsFromOCX_Exit:
   On Error GoTo 0
   Exit Sub

OCX_UpdateDetailsFromOCX_Err:
   ErrorObj.Proc = "UpdateDetailsFromOCX"
   OCXErrorHandler
   GoTo OCX_UpdateDetailsFromOCX_Exit

End Sub

Sub UpdateWardInfo()
'07Sep98 CFY Added

Dim FoundSup As Long, failed%, pointer&
Dim sup As supplierstruct

   getsupplier OCXIn.wardcode, 0, FoundSup, sup
   If FoundSup = 0 Then
         GetPointer dispdata$ & "\supfile.v5", pointer&, -1 ' increment
         If pointer& <= 1 Then
               GetPointer dispdata$ & "\supfile.v5", 2, 2
               pointer& = 2
            End If
         FoundSup = pointer&
         getsupplier OCXIn.wardcode, FoundSup, 0, sup
         clearsup sup

         'Add Ward to index
         Do
''            Updateindex "", OCXIn.wardcode, (foundsup), dispdata$ & "\supfile.idx", failed%
            If failed = -1 Then popmessagecr "Supplier Index Update Failed", "Supplier index may no longer be accurate - please reindex now."
         Loop While failed = 1

         sup.Code = OCXIn.wardcode
         sup.name = OCXIn.wardcode
         sup.fullname = OCXIn.wardcode
         sup.wardcode = OCXIn.wardcode
         sup.suppliertype = "W"
         sup.inuse = "Y"
         
         'Unlock and write the record
         'putsupplier FoundSup, False, sup
         putsupplier FoundSup, sup '23Jun05 TH Removed parameter
      End If
   
End Sub

Sub WriteRecoveryFile(LabelID&, PresID&, caseno$, RecoverTime$)

Dim rec As RecoveryStruct
Dim fil%

   rec.LabelPtr = LabelID&
   rec.prescriptionid = PresID&
   rec.caseno = caseno$
   rec.recoveraftertime = RecoverTime$

   On Error Resume Next
   fil = FreeFile
   Open RecoveryFile For Binary Access Write Lock Read Write As fil
   Put #fil, , rec
   Close #fil
   On Error GoTo 0

End Sub

Private Function AddOrUpdatePatientFromOCX(i_strOCXcaseno As String) As Long
'12Jul02 CKJ Written
'            Takes a caseno which may be new, exisiting or invalid
'            If invalid then it returns 0 & no globals are changed, otherwise
'            it adds patient or updates existing patient using OCX data
'            and returns pointer into patid.v5 for that patient.
'            Globals PID and PIDextra are populated on return.
'09Aug02 CKJ Added handling for overloaded OCXIn.MOName
'            This is a 48 char string which is not actively used for anything.
'            In HK it is added to the heap but otherwise not stored or processed
'            By treating it as a set of key/value pairs it can pass extra data
'            such as weight & height etc.
'            At present the format of this is "kg=xxxxxx" and "cm=xxxxxx", either
'            individually or together when they must be separated by a single CR
'14Feb02 CKJ Corrected to use i_strOCXcaseno instead of OCXIn.HospNum

Dim blnSuccess As Integer
'Dim lngPIDptr As Long
Dim lngPIDptrsearch1 As Long
Dim lngPIDptrsearch2 As Long
Dim msg As String, contnum&
Dim Numoflines%, SpaceLeft%, strTemp As String
Dim intHeapID As Integer                                 '09Aug02 CKJ Added

Stop '!!**
   ReDim patname$(10)
   
   blnSuccess = True
''   CleanTheSlate                                         'initialise PID, PIDextra, PIDnotes, PIDepisode, PIDwas, Sch, patient globals

   blnSuccess = CheckCasenoStructure(i_strOCXcaseno)     'is caseno usable?
   If blnSuccess Then                                    'is it new/unique/duplicated?
         'derived from scanfordupcaseno but without loading Ident.frm
         contnum& = 0
         lngPIDptrsearch1 = 0
         lngPIDptrsearch2 = 0
''         ScanIndexes 2, i_strOCXcaseno, contnum&, lngPIDptrsearch1         'look for caseno on disk
         If lngPIDptrsearch1 > 0 Then                                      'found one patient              (NB could be BatchPN)
''               ScanIndexes 2, i_strOCXcaseno, contnum&, lngPIDptrsearch2   'look again
            End If
''         ScanIndexes 0, "", 0, 0                                           'close index, if still open
         If lngPIDptrsearch2 > 0 Then                                      'found another with same caseno (NB could be BatchPN)
               msg = "WARNING - Two or more patients with same Case Number already registered:" & cr & cr
               msg = msg & "Please resolve this ambiguity using the Pharmacy tools" & cr
               msg = msg & "then repeat the request from the external system." & cr & cr
               msg = msg & "Duplicated Case Number is " & i_strOCXcaseno
               popmessagecr "Duplicate Case Number", msg
               blnSuccess = False
      
            ElseIf lngPIDptrsearch1 > 0 Then                               'one matching patient
               patno& = lngPIDptrsearch1                                   'load patient specified
               GetPatIDNL patno&, pid
''               GetPIDExtra PID.recno, pidExtra
''               GetPIDNotes PID.recno, pidNotes
''               pidwas = pid

            Else                                                           'must be a new patient
               pid.caseno = i_strOCXcaseno
               patno& = 0
               '!!** internal record number
            End If
      End If

   If blnSuccess Then                                    'set all appropriate fields from the OCXIn, over blank PID or existing PID
         'derived from UpdateDetailsFromOCX but without the HK specific settings
          ' 'ModuleType As String * 2               'P=PN, C=CIVAS/Cytotoxic   '19May99 EAC was string * 1
         '   OrderID As String * 14                 '
         '   ItemNo As Long                         '         "
         '   PatientID As String * 8                '
         '   HKPatientID As String * 12             '
         '   PatientName As String * 35             'pid.forename & pid.surname
         '   sex As String * 1                      'pid.sex
         '   dob As String * 8                      'pid.dob
         '   HospNum As String * 12                 'pid.caseno
         '   Speciality As String * 4               'pid.Speciality
         '   wardcode As String * 4                 'pid.Wardcode
          ' 'BedNo As String * 5                    '** Not stored
         '   MOCode As String * 6                   'pid.cons
          ' 'MOName As String * 48                  '** Not stored
         '   PatientCat As String * 2               '** Not stored
         '   PatientStatus As String * 1            'Pid.Status
         '   LanguageFlag As String * 1             'C=Chinese, E=English
         '   action As String * 1                   'N=New, M=Modify, D=Delete, R=Recovery, E=Enquiry
          ' 'UserID As String * 4                   'Printed on label and recorded in transactions
          ' 'RecoveryTime As String * 6             '19May99 EAC Added, format HHMMSS seems to have been missed in the merge
          ' 'Accesslvl As String * 10               '19May99 EAC Added for Generic PAS Enquiry
          ' 'Identtype As String * 1                '   "     "
      
         'On Error GoTo OCX_UpdateDetailsFromOCX_Err
         gTlogCaseno$ = pid.caseno
         
         'Names:
         ' English - Surname,ForeName      - 35bytes total
         ' Chinese - all as one            - 10bytes total
         If InStr(OCXIn.PatientName, ",") Then
               deflines OCXIn.PatientName, patname$(), ",", 1, Numoflines
               If (Len(patname$(1)) <= 20) And (Len(patname$(2)) <= 15) Then    'Both will fit
                     pid.surname = patname$(1)
                     pid.forename = patname$(2)
                  End If
               
               'Surname is too long.....
               If Len(patname$(1)) > 20 Then
                    If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "PID", "N", "SurnameForename", 0)) Then
                           pid.forename = Mid$(patname$(1), 21) & " " & patname$(2)
                        Else
                           pid.forename = patname$(2) & " " & Mid$(patname$(1), 21)
                        End If
                     pid.surname = Left$(patname$(1), 20)
                  End If
               'Forename is too long......
               '(should be mutually exclusive to above condition as it should be impossible for both to be too long)
               If (Len(patname$(2)) > 15) Then
                     SpaceLeft = 20 - Len(patname$(1))
                     If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "PID", "N", "SurnameForename", 0)) Then
                           pid.surname = patname$(1) & " " & Left$(patname$(2), SpaceLeft)
                        Else
                           pid.surname = Left$(patname$(2), SpaceLeft) & " " & patname$(1)
                        End If
                     pid.forename = Mid$(patname$(2), SpaceLeft)
                  End If
            ElseIf Len(Trim$(OCXIn.PatientName)) Then
               pid.surname = OCXIn.PatientName
               pid.forename = ""
            End If
         
         blnSuccess = ParseKeyValuePairsToHeap(OCXIn.MOName, cr, "=", intHeapID)                '09Aug02 CKJ Added to parse MOName
      End If

   If blnSuccess Then
         'Pid.postCode = ""
         'Pid.HouseNumber = ""
         parsedate OCXIn.dob, pid.dob, "3", False
         If Len(Trim$(OCXIn.sex)) Then pid.sex = OCXIn.sex
         If Trim$(pid.sex) = "" Then pid.sex = "U"
         
         If Len(Trim$(OCXIn.wardcode)) Then pid.ward = OCXIn.wardcode
         If trimz(OCXIn.MOCode) <> "" Then                                                      '19Jul99 CFY Added
               pid.cons = OCXIn.MOCode
            Else                                                                                '19Jul99 CFY Added
               strTemp = TxtD(dispdata$ & "\siteinfo.ini", "OCX", "NS", "DefaultConsCode", 0)
               If Len(Trim$(strTemp)) Then pid.cons = strTemp                                   '         "
            End If                                                                              '         "
         'Pid.GP = ""
         
         Heap 11, intHeapID, "kg", pid.weight, False                                            '09Aug02 CKJ Added
         Heap 11, intHeapID, "cm", pid.Height, False
         
         If Len(Trim$(OCXIn.PatientStatus)) Then pid.Status = OCXIn.PatientStatus
      
         If Len(Trim$(OCXIn.HKPatientID)) Then
               pidExtra.NHnumber = Left(OCXIn.HKPatientID, Len(pidExtra.NHnumber))
               pidExtra.NHnumValid = Mid$(OCXIn.HKPatientID, Len(pidExtra.NHnumber) + 1)
            End If
         'PIDextra.title = ""
         'pidExtra.Address1 = ""                                                                   'HK version puts OCXIn.HospNum here
         'PIDextra.Address2 = ""
         'PIDextra.Address3 = ""
         'PIDextra.Address4 = ""
         'PIDextra.EthnicOrigin = ""
         'PIDextra.PPflag = ""
         'EpisodeNum As String * 12
         If Len(Trim$(OCXIn.Speciality)) Then pidExtra.Speciality = OCXIn.Speciality
         'Allergy As String * 255
         'Notes As String
      
         gTlogSpecialty$ = pidExtra.Speciality
         gTlogEpisode$ = i_strOCXcaseno
         gTlogEventNumber$ = Mid$(OCXIn.OrderID, 9, 6)   '!!** HK special?? Should this be outside HK code?
         gTlogPPFlag$ = pidExtra.PPflag                  '21Dec98 CFY Added
      
         'UpdateWardInfo          - not appropriate here: this would automatically add a new ward code but without
         
         If Not ReadLanguage(22, OCXIn.LanguageFlag) Then      'language could not be set - stay with default
               'no action needed
            End If
      
         Heap 2, intHeapID, "", "", False                            '09Aug02 CKJ Added
      End If
         
   If blnSuccess Then
         If CheckPatientData() Then                                  'is record fit for saving?
''               SavePatient PID, patno&, pidwas, blnSuccess            'save details
               If blnSuccess Then
''                     PutPIDExtra PID.recno, pidExtra
                     FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0
                     RefreshOCXHeapData
                  End If
            End If
      End If

   If Not blnSuccess Then patno& = 0
   AddOrUpdatePatientFromOCX = patno&

End Function

