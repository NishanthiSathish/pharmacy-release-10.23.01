Attribute VB_Name = "WIDENTSB"
'-------------------------------------------------------------------------------
'          Routines to store & retrieve Patient ID records
'
'24Feb91 CKJ Seqscan moved here from ident
'            Released for beta-test
'24Jul91 CKJ Lock & No-lock versions written of Get/PutPatid plus UnlockPatid
'            WARNING - LockRecord in dfhl uses 8bit integer only.
' 7Aug91 CKJ All patient record pointers are now LONG integer (Recno&)
'30Aug91 CKJ Lockpatid fault fixed - DIM added
'12Dec91 CKJ Seqscan moved to Macros, for use by WSList
'18Apr92 CKJ ParseName written
'19Aug93 ASC Seqscan moved to q4ansi.bas
'18Oct93 ASC F7 label lined up
' 2Nov93 CKJ VBDOS: Printer => PrinterV
'31Oct94 CKJ Parsename type 3 added
' 1Nov94 CKJ ExpandPID: Added GPexp$
'13Dec94 ASC made patlabel 11 lines like DisplayThelabel
'20Mar95 CKJ Enhanced parsename
'FebMar96 KR Converted to Windows
'23Jan96 KR  Combined patid.inc with widentsb.bas
'28Mar96 KR  Added CloseWidentSb to tidyup any module level variables
'02Dec96 CKJ ExpandPID: Corrected handling of height
' 3Dec96 CKJ ParseName: Simplified Type 1 code
'28Mar97 CKJ Added HouseNumber
'28May97 CKJ/KR Changed ward code to use supplier file
'11Jul97 CKJ V8.0 mods released for alpha test
'14Jul97 CKJ PutPIDextra, PutPIDnotes: added conditional write;
'            only write if the data fields have something in them
'            OR if the database entry already exists for this patient.
'10Sep97 CKJ Added Freelocks after putting mdb info
'11Sep97 CKJ Simple error handling added to table updates, and added error code
'            and message if error occurs on database/table open or table update
'22Oct97 CKJ Added more thorough error handling round patient mdbs, incl retries.
'            Added Option Explicit
' 3Nov97 CKJ Added diagnosis to PatidtypeExtra
'18Mar98 CFY Added type 5 & 6
'            type 5 preserves mixed case, otherwise capitalises
'            type 6 preserves mixed case, otherwise make all upper case
'08Jul98 EAC Episodic data mods
'17Jul98 EAC Added surface area for HK mods
'22Jul98 CKJ FillHeapPatientInfo written, to fill heap with patient related data
'            Call this once before printing to ensure data is refreshed
'13Aug98 EAC ipEthnicOrg moved from WIDENT.BAS
'            ipSpecialty moved from WIDENT.BAS
'            ipLookup moved from WIDENT.BAS
'            FillHeapPatientInfo: Added PID, PIDExtra and PIDEpisode as parameters so that this can exist in non patient apps
'            SetEpisodicButton moved to WIDENT.BAS
'29Sep98 CKJ ExpandPID: Trim of ft.in removed entirely
'            FillHeapPatientInfo: Height now uses mid$ not right$
'16Nov98 CKJ Parsename: Added type 2 "S" Soundex matching
'20Nov98 CKJ/CFY FillHeapPatientInfo: Buildname enhanced to allow 'fn sn' or 'sn, fn' type layouts
'19May99 CKJ OpenClosePidDB, OpenCloseEpisodeDB: Inhibit use of databases by INI file option.
'            Use only on slow WAN where speed is an issue.
'            ASCribe.ini [Inhibit] PIDextraDB = Y/1/-1/T to inhibit, ""/N/0/F/absent to enable
'            ASCribe.ini [Inhibit] PIDepisodeDB = Y/1/-1/T to inhibit, ""/N/0/F/absent to enable
'19Jul99 AE  SelectorPatient:Written.
'19Jul99 AE  FillHeapPatientIDNew:Created from FillHeapPatientID, modified to use SelectorPatient()
'            Not in use at present
'17Aug99 SF  FillHeapPatientInfo: added the prescriber ID to the heap
'06Sep99 CKJ CloseWidentSb: Added call to TrackOpenedFiles
'03Dec99 TH  Buildname: Retain first initial for shortname
'16Feb00 AE  FillHeapPatientInfo:Added Ward Short name to heap
'26Jan00 CFY buildname: ini file switch added to disable comma separation of forename from surname.
'05May00 CFY buildname: Condition to stop any processing occuring if the program was launched in OCX mode.
'             All processing of the name is assumed to have occured with the OCX handler.
'13jun01 ckj ipEthnicOrg: Change Ethnic Origin caption for Language use
'17Jul01 CKJ Buildname: Added switch to make raw forename/surname optional under OCXlaunch
'06Mar02 TH  Buildname: Added Casing on output name (South Tees) (#58583)
'24mar04 ckj {SP1}
'20Apr04 TH  ConsSpecLookup: Use new enhanced lookup (enh654)
'03Sep09 PJC FillHeapPatientInfo: Added PatientPaymentCategory to patient heap. (F0054530)
'03Sep09 PJC Declarations: Added PatientPaymentCategory to patidtype type (F0054530)
'07Sep09 PJC FillHeapPatientInfo: Added formatted version of DOB to the heap used for the UMMC billing interface. (F0054530)
'01Oct09 PJC FillHeapPatientInfo, Expandpid: Partially reinstated (following discussion with CKJ) after formatted DOB required on the label by UMMC (F0065077)
'05Oct09 PJC FillHeapPatientInfo: Added Formatted NHS Number to Print Heap (F0064619)
'07Apr10 AJK FillHeapPatientInfo: Added new elements(pAgeInYears and pSpecialityExpHIL) for HIL printing, ported from v8 (F0072542)
'19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
'13May12 TH  Moved GetNHSNumberDisplayName to WGeneralIO from here to allow use in log viewer
'04Feb13 XN  PatIDTypeExtra: added PostCode so goes on print heap  (41410)
'            FillHeapPatientInfo: Placed pPostCode onto print heap (41410)
'11Feb13 TH  Buildname: Added check in EnsureCasedLabelNames as forename could be empty (TFS 43276,56343)
'06Nov14 XN  patidtype: added SurfaceAreaInM2 (83897)
'            FillHeapPatientInfo: Added print heap elements pCalcSurfaceArea and pSurfaceArea (83897)
'16Feb15 TH  Buildname: Reworked Mc Rule - replaced above (TFS 110935)
'06Dec15 TH  Buildname: Ensure Mc Rule can accomodate 20 char surname (TFS 124058)


'
'Mods Needed:
'-----------
'/Auto Retries on non-fatal mdb errors
' ExpandPID needs tidying in light of recent changes
'
'
'-------------------------------------------------------------------------------
DefInt A-Z
Option Explicit

' 7Feb91 CKJ PatIdType moved to this include file
' 6Sep93 ASC Added post code
'30Oct94 CKJ Added GP
'03Sep09 PJC Added PatientPaymentCategory to patidtype type (F0054530)
Type patidtype
   recno As String * 10                      ' internal lookup code - used for Xref in Tpn etc
   caseno As String * 10                     ' Current caseno
''   oldcaseno As String * 10                ' Previous caseno, after a merge     18oct05 CKJ removed
   surname As String * 20                    ' trimmed & left justified
   forename As String * 15                   ' trimmed & left justified
   dob As String * 8                         ' as  ddmmyyyy  only
   sex As String * 1                         ' M F or space
   ward As String * 5 '4                     ' UCase only       19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
   cons As String * 4                        ' UCase only
   weight As String * 6                      ' kkk.gg
   Height As String * 6                      ' ff.ii
   status As String * 1                      ' I/O/D/L
   PatientPaymentCategory As String * 10     ' 03Sep09 PJC Added for Malaysia (F0054530)
   SurfaceAreaInM2 As String * 6             ' Body surface area m2 83897 XN 6Nov14
   
''   ptr(1 To 10) As String * 6 ' equivalent to rf() 'changed from ptr ASC 1Aug93
 ' ptr(1 To 2) As String * 6  ' equivalent to rf() 'changed from ptr ASC 1Aug93
 ' NHSnumber As String * 10   '
 ' NHSnumvalid As String * 1  '
 ' NHSnumsource As String * 4 '
 ' padding As String * 3
 ' ptr(6 To 10) As String * 6 ' equivalent to rf() 'changed from ptr ASC 1Aug93
''   postCode As String * 8     ' added for coventry etc. ASC 06Sep93
''   GP As String * 4           ' UCase only
 ' spareroom As String * 6
''   HouseNumber As String * 6  ' 28Mar97 CKJ Added
   '--------------
   '  LEN = 173
   '--------------
End Type

Type PatIDTypeExtra                    '10Jul97CKJ added, maps to PIDdb.MDB:Patid
   IDnum As Long                       '4 bytes
   PatRecNo As String * 10
   createddate As Double               'from Variant (8 bytes)
   CreatedUserID As String * 3
   createdterminal As String * 8
   UpdatedDate As Double               'from Variant (8 bytes)
   UpdatedUserID As String * 3
   UpdatedTerminal As String * 8       '52 bytes from start of record to end of this field
   '----------------------------
   NHNumber As String * 10
   NHnumValid As String * 4
   title As String * 5
   Address1 As String * 35
   Address2 As String * 35
   Address3 As String * 35
   Address4 As String * 35
   postCode As String * 10             ' 04Feb13 XN 41410 Set the patient address and post code on pidExtra, so goes on print heap (41410)
   EthnicOrigin As String * 4
   AliasSurname As String * 20
   AliasForename As String * 15
   PPflag As String * 1
   EpisodeNum As String * 12
   Speciality As String * 4
   allergy As String * 255
   diagnosis As String * 255           ' 3Nov97 CKJ Added
   SurfaceArea As Double               '17Jul98 EAC Added
End Type

''Type PatidtypeNotes                    '10Jul97CKJ added, maps to PIDdb.MDB:Patnotes
''   IDnum As Long
''   PatRecNo As String * 10
''   createddate As Double               'from Variant
''   CreatedUserID As String * 3
''   createdterminal As String * 8
''   UpdatedDate As Double               'from Variant
''   UpdatedUserID As String * 3
''   UpdatedTerminal As String * 8
''   '----------------------------
''   notes As String                     'memo field
''End Type

Type PatIdTypeEpisode                  '08Jul98 EAC added, maps to PIDEpisd.MDB:PatEpisodes
   IDnum As Long
   PatRecNo As String * 10
   createddate As Double               'from Variant
   CreatedUserID As String * 3
   createdterminal As String * 8
   UpdatedDate As Double               'from Variant
   UpdatedUserID As String * 3
   UpdatedTerminal As String * 8
   '----------------------------
   Class As String * 1
   EpisodeNum As String * 12
   EpisodeActive As String * 1         'N = Episode not active, any other char = Episode active
   facilityID As String * 15           'Hospital name/code
   EpisodeWard As String * 4           'Will override WardCd field in SupInfo block
   EpisodeRoom As String * 12
   Episodebed As String * 8
   attendingDR As String * 15
   AdmitDate As String * 10
   AdmitTime As String * 4
   DischDate As String * 10
   DischTime As String * 4
   EpisodeCons As String * 4
''   EpisodeGP As String * 4
   EpisodeSpeciality As String * 4
   EpisodeHeight As String * 6
   EpisodeWeight As String * 6
   EpisodePPFlag As String * 1
   EpisodeStatus As String * 1
   EpisodeDiagCodes  As String * 255
End Type

'09May05 CKJ Moved from WIdent as that module is not used
Global pid As patidtype
Global pidExtra As PatIDTypeExtra
''Global pidNotes As PatidtypeNotes
Global pidEpisode As PatIdTypeEpisode


Sub Expandpid(pid As patidtype, dob$, age$, lage!, wardexp$, consexp$, GPexp$)
'-----------------------------------------------------------------------------
'15Nov90 CKJ scope of data items extended
' 1Dec90 CKJ status added
'13Dec90 CKJ dob$ fault fixed
'24Feb91 CKJ Massaged weight replaced in pid.weight
'31May91 ASC ft integer conversion corrected (patients were gaining 1 foot
'        between ?.05" and ?.09" due to . 9 = .9 see !!!
'31Oct94 CKJ Added GPexp$
'02Dec96 CKJ Corrected handling of height
'28May97 CKJ/KR Changed ward code to use supplier file
'29Sep98 CKJ Trim of ft.in removed entirely
'01Oct09 PJC Partially reinstated (following discussion with CKJ) after formatted DOB required on the label by UMMC (F0065077)
'12May11 TH  Further reinstated to allow for consultant and ward expansions (F0116299)
'01Jun11 TH  mod to protect cached consultant expansion (F0119288)
'03Jun11 TH  introducted another local static to store the expansion (F0119288 )
'-----------------------------------------------------------------------------
Dim found%, inuse%
Dim db$, ndbd&, lye!, ye$, valid%, byt%, Height$, X%, tempval&
Dim strParams As String
Dim rsConsultant As ADODB.Recordset
Static pconscode As String
Static strConsExp As String

   ' ddmmyyyy  ==>  dd/mm/yyyy ==> nn years & mm months
   dob$ = ""
   db$ = Trim$(pid.dob)
   If Len(db$) Then
         dob$ = Left$(db$, 2) + "/" + Mid$(db$, 3, 2) + "/" + Right$(db$, 4)
         datetodays dob$, "", ndbd&, lye!, ye$, valid%
         If valid% Then
               age$ = ye$
               lage! = lye!        '!!CKJ
            Else
               dob$ = ""
               age$ = ""
               lage! = 0          '!!CKJ
            End If
      End If
''
'11May11 TH Reinstated (F0116299)

   wardexp$ = ""
   If Len(Trim$(pid.ward)) Then
         'seqscan pid.ward, wardexp$, dispdata$ + "\wardcode.dat"
         getsupplierward pid.ward, wardexp$, found, inuse '28May97 CKJ/KR Replaced
      End If
''
   'consexp$ = ""  '01Jun11 TH Removed - This could have blanked an effictively cached expansion
   If Len(Trim$(pid.cons)) Then
      If Trim$(pid.cons) <> pconscode Then
         strConsExp = "" '01Jun11 TH Added
         pconscode = Trim$(pid.cons)
         ''If SlaveModeEnabled() Then                 '10nov03 ckj
         ''      consexp$ = Trim$(pid.cons)           '   "
         ''  Else                                    '   "
         ''      SeqScan pid.cons, consexp$, dispdata$ + "\conscode.dat"
         ''   End If
         '12May11 TH Added (F0116299)
         'Here we need to get the extension associated with the consultant - this will be the description of the Entity record
         strParams = gTransport.CreateInputParameterXML("ConsultantAlias", trnDataTypeVarChar, 6, Trim$(pid.cons))
         Set rsConsultant = gTransport.ExecuteSelectSP(g_SessionID, "pConsultantDescriptionFromWConsulantsCodesAlias", strParams)
         If rsConsultant.RecordCount > 0 Then
            strConsExp = RtrimGetField(rsConsultant!Description)
         End If
         rsConsultant.Close
         Set rsConsultant = Nothing
      End If
   Else
      strConsExp = "" '01Jun11 TH Added
   End If
   consexp$ = strConsExp
''
''''   GPexp$ = ""
''''   If Len(Trim$(pid.GP)) Then SeqScan pid.GP, GPexp$, dispdata$ + "\GPcode.dat"
''
''   ' VAL() fails if any of '%!&#^DE' found in string in the wrong place ...
''   For byt = 1 To 6          ' check each digit for validity
''      If InStr("0123456789. ", Mid$(pid.weight, byt, 1)) = 0 Then Exit For  ' dec pt & the space needed
''   Next
''   pid.weight = Left$(pid.weight, byt - 1)
''
''   For byt = 1 To 6          ' check each digit for validity
''      If InStr("0123456789. ", Mid$(pid.Height, byt, 1)) = 0 Then Exit For
''   Next
''   Height$ = Left$(pid.Height, byt - 1)             ' 5.10  5. 3
''
''   For X = 1 To 10         ' scan record pointers for invalid characters
''      For byt = 1 To 6
''         If InStr("0123456789", Mid$(pid.ptr(X), byt, 1)) = 0 Then Exit For
''      Next
''      tempval& = Val(Left$(pid.ptr(X), byt - 1))
''      pid.ptr(X) = ""
''      If tempval& <= 999999 And tempval& >= 0 Then pid.ptr(X) = LTrim$(Str$(tempval&))
''   Next
''
End Sub

Sub FillHeapPatientInfo(ByVal HeapID%, pid As patidtype, pidExtra As PatIDTypeExtra, pidEpisode As PatIdTypeEpisode, success%, Optional ByVal blnUseCachedWard As Boolean = False)
'22Jul98 CKJ Copied from FillPrintHeapPN, to fill heap with patient related data
'            Call this once before printing to ensure data is refreshed
'            Pass HeapID as a positive value to add the items, negative to remove.
'            Pass HeapID=0 to fill the global printing heap using gPRNheapID
'            All items have prefix 'p' to indicate patient related data
'
'            NOTE: This procedure uses the global structures pid. pidextra. (pidnotes.)
'            but there seems to be no global episode structure declared.
'            Once this has been added to the declarations in Wident.bas remove comment marks.
'13Aug98 EAC Added PID, PIDExtra and PIDEpisode as parameters so that this can exist in non patient apps
'29Sep98 CKJ Height now uses mid$ not right$
'20Nov98 CKJ/CFY Buildname enhanced to allow 'fn sn' or 'sn, fn' type layouts
'17Aug99 SF  added the prescriber ID to the heap
'16Feb00 AE  Added Ward Short name to heap
'03Sep09 PJC Added PatientPaymentCategory to patient heap. (F0054530)
'07Sep09 PJC Added formatted version of DOB to the heap used for the UMMC billing interface. (F0054530)
'01Oct09 PJC Reinstated Call to Expandpid as DOB required formated on the label for UMMC (F0065077)
'05Oct09 PJC Added Formatted NHS Number to Print Heap (F0064619)
'07Apr10 AJK Added new elements(pAgeInYears and pSpecialityExpHIL) for HIL printing, ported from v8 (F0072542)
'06Nov14 XN  Added print heap elements pCalcSurfaceArea and pSurfaceArea (83897)
'
'Fields and structures NOT incorporated:
'   pid.ptr(1 To 10)     - internal use only
'   pidnotes structure   - notes could burst the print heap in one go
'                          If they are to be printed, place them formatted in a local file
'                          and add "#include<tab><path\file.ext>" to the heap, e.g.
'                          Heap action, ID, "pNotes", "#Include" & TB & tempfilename$, 0
'   Created/Updated-Date/UserID/Terminal in Episode not added, ones in pid.extra should do
'
'mods wanted:
'/ expansions of coded fields
'  success to be set False if any problems occur
'/ DOB to be formatted
'/ Height converted to cm
'  Manually entered Surface area to be available

Dim Action%, id%, htcm$, dob$, age$, wardexp$, consexp$, GPexp$, PatientName$, tmp$
Dim lFound As Long, sup As supplierstruct               '16Feb00 AE
Dim strDOBFormat As String                              '07Sep09 PJC Added
Dim strDOBFormatted As String                            '07Sep09 PJC Added

   success = False

   id = HeapID
   If id = 0 Then id = gPRNheapID                                'default id global print heap
   Action = Iff(id > 0, 10, 12)                                  'add or remove from heap
   id = Abs(id)                                                  'ensure ID is positive
   
   If id Then
         Heap Action, id, "pIntRecNo", Trim$(pid.recno), 0
         Heap Action, id, "pCaseNo", Trim$(pid.caseno), 0
''         Heap Action, id, "pOldCaseno", Trim$(pid.oldcaseno), 0       18oct05 CKJ removed
         Heap Action, id, "pSurname", Trim$(pid.surname), 0
         Heap Action, id, "pForename", Trim$(pid.forename), 0
         'Heap action, ID, "pForenameSurname", LTrim$(Trim$(PID.forename) & " " & Trim$(PID.surname)), 0 '20Nov98 CKJ/CFY removed
         buildname pid, False, PatientName$                            '20Nov98 CKJ/CFY Added to allow 'sname fname'
         Heap Action, id, "pForenameSurname", PatientName$, 0          '   "
         buildname pid, True, PatientName$                             '20Nov98 CKJ/CFY Added True to shorten name
         Heap Action, id, "pInitialsSurname", PatientName$, 0          'Abbreviated if >~20 chars  '20Nov98 CKJ/CFY removed trim
      
         Heap Action, id, "pSex", pid.sex, 0
         Heap Action, id, "pStatus", pid.status, 0
         Heap Action, id, "pDOBraw", Trim$(pid.dob), 0                 'ddmmyyyy 00mmyyyy 0000yyyy
         Heap Action, id, "pWard", pid.ward, 0
         Heap Action, id, "pCons", pid.cons, 0
         
         Heap Action, id, "pPatientPaymentCategory", Trim$(pid.PatientPaymentCategory), 0                '03Sep09 PJC Added PatientPaymentCategory to patient heap. (F0054530)

''         Heap Action, id, "pGP", pid.GP, 0
         Expandpid pid, dob$, age$, 0, wardexp$, consexp$, GPexp$     '**!!**  '01Oct09 PJC Reinstated as DOB required formated on the label for UMMC (F0065077)
         
         Heap Action, id, "pDOB", dob$, 0
         Heap Action, id, "pAge", age$, 0
         
         If InStr(age$, "years") > 0 Then                                      '07Apr10 AJK ported from v8
            age$ = Format$(Val(Left$(age$, (InStr(age$, "years") - 1))))       '   "
            Heap Action, id, "pAgeInYears", age$, 0                            '   "
         Else                                                                  '   "
            Heap Action, id, "pAgeInYears", "", 0                              '   "
         End If                                                                '   "
         
         
         Heap Action, id, "pWardExp", wardexp$, 0
         Heap Action, id, "pConsExp", consexp$, 0
         Heap Action, id, "pGPexp", GPexp$, 0
         
         strDOBFormat = TxtD(dispdata$ & "\patmed.ini", "", "ccyymmdd", "PatientPrintHeapDOBFormat", 0)  '07Sep09 PJC Added formatted version of DOB to the heap used for the UMMC billing interface. (F0054530)
         parsedate pid.dob, strDOBFormatted, strDOBFormat, 0                                             '          "
         Heap Action, id, "pDOBformatted", strDOBFormatted, 0                                            '          "

         wardexp$ = ""
         '30Jun17 TH Added new caching to allow bypass of getsupplier (TFS 191443)
         If blnUseCachedWard Then
            GetDispWardSupplier pid.ward, lFound, sup
         End If
         
         If (lFound = 0) Then getsupplier pid.ward, 0, lFound, sup                      '16Feb00 AE  Added (Ward Short name)
         If lFound Then wardexp$ = sup.name
         Heap Action, gPRNheapID, "pShortWard", wardexp$, 0

         Heap Action, id, "pHeight", Trim$(pid.Height), 0
         Select Case Val(pid.Height)
            Case Is >= 10     'cms           (10 or above)
               htcm$ = Trim$(pid.Height)
            Case Is > 0       'feet & inches (below 10)
               'htcm$ = Format$(2.54 * (12 * Val(Left$(PID.Height, 1)) + Val(Right$(PID.Height, 2))))  29Sep98 CKJ
               htcm$ = Format$(2.54 * (12 * Val(Left$(pid.Height, 1)) + Val(Mid$(pid.Height, 3))))    '29Sep98 CKJ
            Case Else         '              (missing)
               htcm$ = ""
            End Select
         Heap Action, id, "pHeightcm", htcm$, 0
         Heap Action, id, "pWeight", Trim$(pid.weight), 0
         
         Heap Action, id, "pCalcSurfaceArea", pid.SurfaceAreaInM2, 0    ' 83897 XN 6nov14 Add surface area to print heap
         Heap Action, id, "pSurfaceArea", pid.SurfaceAreaInM2, 0        ' 83897 XN 6nov14 Add surface area to print heap (repeat of pCalcSurfaceArea for backwards compatibility)
''         Heap Action, id, "pCalcSurfaceArea", SurfaceArea(pid.Height, pid.weight), 0
         'Heap action, ID, "p???SurfaceArea", ???, 0                 manually entered SA

''         Heap Action, id, "pHouseNo", Trim$(pid.HouseNumber), 0
         Heap Action, id, "pAddress1", Trim$(pidExtra.Address1), 0
         Heap Action, id, "pAddress2", Trim$(pidExtra.Address2), 0
         Heap Action, id, "pAddress3", Trim$(pidExtra.Address3), 0
         Heap Action, id, "pAddress4", Trim$(pidExtra.Address4), 0
         Heap Action, id, "pPostcode", Trim$(pidExtra.postCode), 0      ' 04Feb13 XN  41410 added PostCode so goes on print heap
         
         Heap Action, id, "pNHnumber", Trim$(pidExtra.NHNumber), 0
         Heap Action, id, "pNHnumValid", Trim$(pidExtra.NHnumValid), 0
         Heap Action, id, "pNHnumberFormatted", Format$(Trim$(pidExtra.NHNumber), TxtD$(dispdata & "\Patmed.ini", "", "", "DisplayNHSNumberOnPMRFormat", 0)), 0  '05Oct09 PJC Added Formatted NHS Number to Print Heap (F0064619)
         Heap Action, id, "pTitle", Trim$(pidExtra.title), 0
         Heap Action, id, "pEthnicOrigin", Trim$(pidExtra.EthnicOrigin), 0
         ipEthnicOrg pidExtra.EthnicOrigin, tmp$, False
         Heap Action, id, "pEthnicOriginExp", tmp$, 0
         Heap Action, id, "pAliasSurname", Trim$(pidExtra.AliasSurname), 0
         Heap Action, id, "pAliasForename", Trim$(pidExtra.AliasForename), 0
         Heap Action, id, "pFlag", Trim$(pidExtra.PPflag), 0
         Heap Action, id, "pEpisodeNum", Trim$(pidExtra.EpisodeNum), 0
         Heap Action, id, "pCreatedDate", Format$(pidExtra.createddate, "dd-mmm-yyyy hh:nn:ss"), 0
         Heap Action, id, "pCreatedUserID", Trim$(pidExtra.CreatedUserID), 0
         Heap Action, id, "pCreatedTerminal", Trim$(pidExtra.createdterminal), 0
         Heap Action, id, "pUpdatedDate", Format$(pidExtra.UpdatedDate, "dd-mmm-yyyy hh:nn:ss"), 0
         Heap Action, id, "pUpdatedUserID", Trim$(pidExtra.UpdatedUserID), 0
         Heap Action, id, "pUpdatedTerminal", Trim$(pidExtra.UpdatedTerminal), 0
         Heap Action, id, "pAllergy", Trim$(pidExtra.allergy), 0
         Heap Action, id, "pSpeciality", Trim$(pidExtra.Speciality), 0
         Heap Action, id, "pSpecialty", Trim$(pidExtra.Speciality), 0
         ipspecialty pidExtra.Speciality, tmp$, False
         Heap Action, id, "pSpecialityExp", tmp$, 0
         Heap Action, id, "pSpecialtyExp", tmp$, 0
         Heap Action, id, "pSpecialtyExpHIL", URLEscape(tmp$), 0                  '07Apr10 AJK Ported from v8
         Heap Action, id, "pDiagCodes", Trim$(pidExtra.diagnosis), 0
      
         Heap Action, id, "pEpisodeClass", Trim$(pidEpisode.Class), 0
         Heap Action, id, "pEpisodeNum", Trim$(pidEpisode.EpisodeNum), 0
         Heap Action, id, "pEpisodeActive", Trim$(pidEpisode.EpisodeActive), 0
         Heap Action, id, "pFacilityID", Trim$(pidEpisode.facilityID), 0
         Heap Action, id, "pEpisodeWard", Trim$(pidEpisode.EpisodeWard), 0
         Heap Action, id, "pEpisodeRoom", Trim$(pidEpisode.EpisodeRoom), 0
         Heap Action, id, "pEpisodeBed", Trim$(pidEpisode.Episodebed), 0
         Heap Action, id, "pAttendingDr", Trim$(pidEpisode.attendingDR), 0
         Heap Action, id, "pAdmitDate", Trim$(pidEpisode.AdmitDate), 0
         Heap Action, id, "pAdmitTime", Trim$(pidEpisode.AdmitTime), 0
         Heap Action, id, "pDischDate", Trim$(pidEpisode.DischDate), 0
         Heap Action, id, "pDischTime", Trim$(pidEpisode.DischTime), 0
         Heap Action, id, "pEpisodeCons", Trim$(pidEpisode.EpisodeCons), 0
''         Heap Action, id, "pEpisodeGP", Trim$(pidEpisode.EpisodeGP), 0
         Heap Action, id, "pEpisodeSpeciality", Trim$(pidEpisode.EpisodeSpeciality), 0
         Heap Action, id, "pEpisodeSpecialty", Trim$(pidEpisode.EpisodeSpeciality), 0
         Heap Action, id, "pEpisodeHeight", Trim$(pidEpisode.EpisodeHeight), 0
         Heap Action, id, "pEpisodeWeight", Trim$(pidEpisode.EpisodeWeight), 0
         Heap Action, id, "pEpisodePatFlag", Trim$(pidEpisode.EpisodePPFlag), 0
         Heap Action, id, "pEpisodeStatus", Trim$(pidEpisode.EpisodeStatus), 0
         Heap Action, id, "pEpisodeDiagCodes", Trim$(pidEpisode.EpisodeDiagCodes), 0
         Heap Action, id, "pPrescriberId", Trim$(gPrescriberID$), 0                    '17Aug99 SF added
         
         success = True
      End If

End Sub


Sub ipEthnicOrg(Code$, EOexp$, displayMsg As Integer)
'11Jul97 CKJ Added
'13jun01 ckj Change Ethnic Origin caption for Language use

Dim pathfile$, Section$
         
   pathfile$ = dispdata$ & "\ASCribe.ini"
   Section$ = "PID"

   EOexp$ = ""
   If TrueFalse(TxtD(pathfile$, Section$, "0", "EditEthnicOrg", 0)) Then
         'ipLookup Code$, "\ethncode.dat", EOexp$, displayMsg
         ipLookup Code$, "ethncode", EOexp$, displayMsg '21Sep05 TH Replaced
      End If

End Sub

Sub ipLookup(Code$, FILE$, wexp$, displayMsg As Integer)
'26Jul96 KR  added extra parameter, displaymessage, which if false suppresses error message.
' 9Feb95 CKJ Added not-in-use check
'            This proc has outlived its usefulness - needs simplifying
'23Mar97 CKJ Simplified
'29May97 CKJ Not used for wards anymore
'11Jul97 CKJ Now used by many fields - changed name from ipWardCons to ipLookup
            
''   If Val(Identtype$) <> 5 Then                     '08Nov05 CKJ identtype no longer used
   wexp$ = ""
   'SeqScan Code$, wexp$, dispdata$ & FILE$
   SeqScan Code$, wexp$, FILE$  '21Sep05 TH Replaced
   If Len(wexp$) And displayMsg Then
      If InStr(wexp$, "#") Then      '9Feb95 CKJ Added not-in-use check
         popmessagecr "!WARNING", "This code is not in use - please correct"
      End If
   End If
''      End If

End Sub

Sub ipspecialty(Code$, SPexp$, displayMsg As Integer)
'11Jul97 CKJ Added
'21Jan98 CKJ changed dirctrte.dat to speclty.dat
'            This procedure shows all specialties on file, not just the ones for the consultant

Dim pathfile$, Section$
         
   pathfile$ = dispdata$ & "\ASCribe.ini"
   Section$ = "PID"

   SPexp$ = ""
   If TrueFalse(TxtD(pathfile$, Section$, "0", "EditSpecialty", 0)) Then
         'ipLookup Code$, "\speclty.dat", SPexp$, displayMsg   '21Jan98 CKJ was dirctrte
         ipLookup Code$, "speclty", SPexp$, displayMsg   '21Sep05 TH Replaced
      End If
         
End Sub



Sub Parsename(Method%, rawname$, parsedname$)
'-----------------------------------------------------------------------------
'       Convert a name into form used in index
'       Method 1: Upper case & remove punctuation, preserving original length
'
'18Apr92 CKJ Proc written
'31Oct94 CKJ Added type 3 - improved ucase/lcase
'20Mar95 CKJ Added type 4 - ucase/lcase, but only if all lcase or ucase now.
'29Feb96 CKJ Type 4 was written to only work if all lower case - description corrected
' 3Dec96 CKJ Simplified Type 1 code
'18Mar98 CFY Added type 5 & 6
'            type 5 preserves mixed case, otherwise capitalises
'            type 6 preserves mixed case, otherwise make all upper case
'16Nov98 CKJ Added type 2 "S" Soundex matching
'-----------------------------------------------------------------------------
Dim nam$, posn%, posx%, char$

   Select Case Method
      Case 1                         ' Upper case & remove punctuation
         'tempname$ = UCase$(rawname$) + " "
         'towrite = 0
         'parsedname$ = ""            ' O'Malley-Smythe => OMALLEYSMYTHE
         'For parsptr = 1 To Len(tempname$)
         '   Select Case Mid$(tempname$, parsptr, 1)
         '      Case "A" To "Z", "0" To "9"
         '         towrite = towrite + 1 ' one more char to write either at end or at next invalid char
         '      Case Else
         '         parsedname$ = parsedname$ + Mid$(tempname$, parsptr - towrite, towrite)
         '         towrite = 0
         '      End Select
         'Next
         'parsedname$ = parsedname$ + Space$(Len(rawname$) - Len(parsedname$))
         parsedname$ = Space$(Len(rawname$))
         LSet parsedname$ = UCase$(AlphaNum$(rawname$))
         
      Case 2                         ' Soundalike match
         Select Case "S"                                                         'replace with match algorithm
            Case "A"                                                             'Aurex - our own
            Case "S"                                                             'Standard Soundex
               Parsename 1, rawname$, nam$                                       'start by ucase & removing punctuation
               parsedname$ = Left$(nam$, 1)                                      'keep first letter
               nam$ = RTrim$(Mid$(nam$, 2))                                      'discard first letter & trailing spaces
               Do While Len(nam$) > 0 And Len(parsedname$) < 4                   'for each remaining letter
                  Select Case Left$(nam$, 1)                                     'pick next letter
                     Case "B", "P", "F", "V":                     char$ = "1"    'code the letter
                     Case "C", "S", "G", "J", "K", "Q", "X", "Z": char$ = "2"
                     Case "D", "T":                               char$ = "3"
                     Case "L":                                    char$ = "4"
                     Case "M", "N":                               char$ = "5"
                     Case "R":                                    char$ = "6"
                     Case Else:                                   char$ = ""
                     End Select
                  If char$ = Right$(parsedname$, 1) Then char$ = ""              'ignore duplicates
                  parsedname$ = parsedname$ & char$                              'keep coded letter
                  nam$ = Mid$(nam$, 2)                                           'discard first letter
               Loop
            Case "M"                                                             'Metaphone
            End Select

      Case 3                         ' Upper & lower case
         nam$ = Trim$(LCase$(rawname$))
         posn = 0
         Do
            posx = posn
            posn = InStr(posx + 1, nam$, " ")
            If posn = 0 Then posn = InStr(posx + 1, nam$, "-")
            If posn = 0 Then posn = InStr(posx + 1, nam$, "(")
            If posn < Len(nam$) Then
                  Mid$(nam$, posn + 1, 1) = UCase$(Mid$(nam$, posn + 1, 1))
               End If
         Loop While posn
         parsedname$ = nam$

      Case 4                         ' Upper & lower case, only if lower case now
         If rawname$ = LCase$(rawname$) Then
               Parsename 3, rawname$, parsedname$
            Else
               parsedname$ = rawname$
            End If

      Case 5                         'preserve mixed case, otherwise capitalise '16Mar98 CFY Added
         Select Case rawname$
            Case LCase$(rawname$), UCase$(rawname$)
               Parsename 3, rawname$, parsedname$
            Case Else
               parsedname$ = rawname$
            End Select
      
      Case 6                         'preserve mixed case, otherwise make all upper case
         Select Case rawname$
            Case LCase$(rawname$), UCase$(rawname$)
               parsedname$ = UCase$(rawname$)
            Case Else
               parsedname$ = rawname$
            End Select

      Case Else                      ' Upper case only
         parsedname$ = UCase$(rawname$)
      End Select
End Sub


''Sub ConsSpecLookup(ByVal ConsCode$, SpecCode$, SpecDesc$)
'''09Aug99 CFY Written. Taken from code in TxtPatDet_LostFocus in ident.frm.
'''Consultant/Specialty lookup. Suppply a consultant code in 'ConsCode$' and will return
'''a specialty code and description in 'SpecCode$' and 'SpecDesc$'
'''20Apr04 TH  Use new enhanced lookup (enh654)
''
''Dim Code$, temp$, ret$
''Dim total%, chan%, i%
''
''   ReDim lines$(50)
''   SpecCode$ = ""
''   SpecDesc$ = ""
''
''   popmessagecr "Ascribe", "ConsSpecLookup called in v 9.3 Need to resolve multiple Specialties !!!"
''
''   ipLookup (ConsCode$), "\consspec.dat", Code$, 0
''   ipLookup (ConsCode$), "\consspec", Code$, 0
''
''   'Cons code passed... and it is found...    and it is in use...
''   If Code$ <> "" And Left$(Code$, 1) <> "<" And InStr(Code$, "#") = 0 Then
''         deflines Code$, lines$(), ",", 1, total
''         Select Case total
''            Case 1      'only one specialty for this consultant
''               ipspecialty Code$, ret$, 0
''            Case Is > 1 'several specialties for this consultant
''                  '21Sep05 TH May need to handle multiple specialties for Consultant, but not sure
''                  ' if this is required in the pharmacy control so work not done yet !
''
''''               MakeLocalFile temp$
''''               chan = FreeFile
''''               Open temp$ For Output As #chan
''''               Print #chan, total
''''               For i = 1 To total
''''                  ipLookup lines$(i), "\speclty.dat", ret$, 0
''''                  Write #chan, lines$(i), ret$
''''               Next
''''               Close #chan
''               If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "OldSpecialtyForm", 0)) Then                     '20Apr04 TH Added (enh654)
''                     'displaymacrofile dispdata$ + "\speclty.dat", "Specialties for this Consultant", Code$, ret$, False
''                     displaymacrofile "speclty", "Specialties for this Consultant", Code$, ret$, False
''                  Else                                                                                                '   "
''                     'EnhDisplayMacrofile dispdata$ + "\speclty.dat", "Specialties for this Consultant", Code$, ret$, False  '   "
''                     EnhDisplayMacrofile "speclty", "Specialties for this Consultant", Code$, ret$, False  '   "
''                  End If                                                                                              '   "
''               Kill temp$
''            End Select
''      End If
''
''   If Code$ <> "" And Left$(Code$, 1) <> "<" Then
''         SpecCode$ = Code$
''         SpecDesc$ = ret$
''      End If
''
''End Sub


''Function SurfaceArea(ByVal Height$, ByVal weight$) As String
'''03Dec96 CKJ Calc now aware that height$ > 10 is already in cm
'''            cm! was labelled ft! before - changed
'''            String returned is now the bare figure without text around
'''24Jul98 CFY SurfaceArea: Added 'ByVal' to the parameter list. Now also trim$ height$.
'''              Without the trim, the SurfaceArea function would possibly omit the inches from the
'''              height as two extra spaces are present at the end of the field.
'''13Aug98 EAC SurfaceArea function moved from WIDENT.BAS
''
''Dim SWeight!, sa!, cm!
''
''   Height$ = Trim$(Height$)         '24Jul98 CFY Added
''   SWeight! = Val(weight$)
''
''   If SWeight! > 0.1 And Val(Height$) > 0 Then
''         If Val(Height$) >= 10 Then             'cm
''               cm! = Val(Height$)
''            Else                                'ft in
''               cm! = 30.48! * (Val(Left$(Height$, 1)) + (Val(Right$(Height$, 2)) / 12))
''            End If
''         sa! = (SWeight! ^ 0.425) * (cm! ^ 0.725) * 0.007184
''         SurfaceArea = Format$(sa!, "0.00")     'square metres
''      Else
''         SurfaceArea = ""
''      End If
''
''End Function


''Sub BlankPIDnotes(PIDmemo As PatidtypeNotes)
''
''   PIDmemo.IDnum = 0                'Long
''   PIDmemo.PatRecNo = ""            'String * 10
''   PIDmemo.createddate = 0          'Double from Variant
''   PIDmemo.CreatedUserID = ""       'String * 3
''   PIDmemo.createdterminal = ""     'String * 8
''   PIDmemo.UpdatedDate = 0          'Double from Variant
''   PIDmemo.UpdatedUserID = ""       'String * 3
''   PIDmemo.UpdatedTerminal = ""     'String * 8
''   PIDmemo.notes = ""               'String
''
''End Sub

Sub buildname(pid As patidtype, shortname%, PatientName$)
'13Jun98 ASC keeps length of name down to allow use of same line for other info like patient number
'13Aug98 EAC moved here from PATSUBS.BAS
'            Added PID to parameter list
'20Nov98 CKJ/CFY Added parameter ShortName; If True then total length is limited to max of
'            24 chars 'A B SURNAME.............' or 25 chars 'SURNAME............., A B'
'            Uses Ascribe.ini [PID] SurnameForename=T/F/0/1 etc, if true then surname, forename or initials
'03Dec99 TH Retain first initial for shortname
'26Jan00 CFY ini file switch added to disable comma separation of forename from surname.
'05May00 CFY Condition to stop any processing occuring if the program was launched in OCX mode.
'            All processing of the name is assumed to have occured with the OCX handler.
'17Jul01 CKJ Added switch to make raw forename/surname optional under OCXlaunch
'06Mar02 TH  Added Casing on output name (South Tees) (#58583)
'24Jul11 TH  Added new rules (F0110136)
'11Feb13 TH  Added check in EnsureCasedLabelNames as forename could be empty (TFS 43276,56343)
'16Feb15 TH  Reworked Mc Rule - replaced above (TFS 110935)
'06Dec15 TH  Ensure Mc Rule can accomodate 20 char surname (TFS 124058)

Dim inits$, fname$, sName$, posn%
Static SnameFname%, doneonce%, CommaSeparatedName%
Dim intloop As Integer
Dim blnUcase As Boolean

   'If Len(Trim$(PID.forename) & " " & Trim$(PID.surname)) > 20 Then                      20Nov98 CKJ/CFY Block removed
   '      If Len(Trim$(PID.forename)) > 1 Then PatientName$ = Left$(PID.forename, 1)
   '      If InStr(Trim$(PID.forename), " ") > 0 Then PatientName$ = PatientName$ & " " & Mid$(PID.forename, InStr(Trim$(PID.forename), " ") + 1, 1)
   '      PatientName$ = PatientName$ & " " & Trim$(PID.surname)
   '   Else
   '      PatientName$ = Trim$(PID.forename) & " " & Trim$(PID.surname)
   '   End If
   
''   If OCXlaunch() Then                                         '05May00 CFY Added
''         '17Jul01 CKJ Added switch to make raw name optional
''         If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "PID", "N", "OCXUseRawForenameSurname", 0)) Then
''               PatientName$ = pid.forename & pid.surname
''               Exit Sub
''            End If
''      End If
   
   If Not doneonce Then
         SnameFname = TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "PID", "N", "SurnameForename", 0))
         CommaSeparatedName = TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "PID", "Y", "CommaSeparatedName", 0))   '26Jan00 CFY
         doneonce = True
      End If
   
   fname$ = Trim$(pid.forename)                            'remove spaces
   sName$ = Trim$(pid.surname)                             'remove spaces
   inits$ = Left$(fname$, 1)                               'take first initial (may be zero length)
   posn = InStr(fname$, " ")                               'two first names?
   If posn Then                                            '... yes
         'inits$ = Mid$(fname$, posn, 2)                    'take space and next initial (cannot be blank)
         inits$ = inits$ & Mid$(fname$, posn, 2)           '03Dec99 TH Retain first initial
      End If                                               'inits now one of '' 'A' 'A B'
   
   If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "PID", "N", "EnsureCasedLblNames", 0)) Then   '06Mar02 TH Ensure Name is cased OK (#58583)
         inits$ = UCase$(inits$)
         If Len(fname$) > 0 Then fname$ = UCase$(Left$(fname$, 1)) & LCase$(Right$(fname$, Len(fname$) - 1)) '11Feb13 TH Added check as forename could be empty (TFS 43276,56343)
         sName$ = UCase$(Left$(sName$, 1)) & LCase$(Right$(sName$, Len(sName$) - 1))
      End If
      
   '24Jul11 TH F0110136
   'New casing rules - only to be used if EnsureCasedLblNames is not present
   If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "PID", "N", "UpperCaseRule", 0)) Then
      'If ((UCase(WPat.forename) = WPat.forename) Or (LCase(WPat.forename) = WPat.forename)) And ((UCase(WPat.surname) = WPat.surname) Or (LCase(WPat.surname) = WPat.surname)) Then
      'Now we can apply the new rules.
      blnUcase = True
      fname$ = ""
      For intloop = 1 To 15
         If blnUcase Then
            fname$ = fname$ & UCase$(Mid$(pid.forename, intloop, 1))
         Else
            fname$ = fname$ & LCase$(Mid$(pid.forename, intloop, 1))
         End If
         If (Asc(UCase$(Mid$(pid.forename, intloop, 1))) < 65) Or (Asc(UCase$(Mid$(pid.forename, intloop, 1))) > 90) Then
            blnUcase = True
         Else
            blnUcase = False
         End If
      Next
      fname$ = Trim$(fname$)
      blnUcase = True
      sName$ = ""
      For intloop = 1 To 20
         If blnUcase Then
            sName$ = sName$ & UCase$(Mid$(pid.surname, intloop, 1))
         Else
            sName$ = sName$ & LCase$(Mid$(pid.surname, intloop, 1))
         End If
         If (Asc(UCase$(Mid$(pid.surname, intloop, 1))) < 65) Or (Asc(UCase$(Mid$(pid.surname, intloop, 1))) > 90) Then
            blnUcase = True
         Else
            blnUcase = False
         End If
      Next
      sName$ = Trim$(sName$)
      'End If
      'Now the "mc" rule
      'If InStr(LCase(sName$), "mc") > 0 Then
      '   sName$ = Left$(sName$, (InStr(LCase(sName$), "mc") + 1)) & UCase(Mid$(sName$, InStr(LCase(sName$), "mc") + 2, 1)) & Mid$(sName$, InStr(LCase(sName$), "mc") + 3, (Len(sName$)))
      'End If
   End If
   'Now the "mc" rule (only one instance supported)
   If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "PID", "N", "McRule", 0)) Then
      'If InStr(LCase(sName$), "mc") > 0 And InStr(LCase(sName$), "mc") < 19 Then
      '   sName$ = Left$(sName$, (InStr(LCase(sName$), "mc") + 1)) & UCase(Mid$(sName$, InStr(LCase(sName$), "mc") + 2, 1)) & Mid$(sName$, InStr(LCase(sName$), "mc") + 3, (Len(sName$)))
      'End If
      '16Feb15 TH Reworked Mc Rule - replaced above (TFS 110935)
      If Left(LCase(sName$), 2) = "mc" Then
         'sName$ = "Mc" & UCase(Mid$(sName$, 3, 1)) & LCase(Mid$(sName$, 4, 16))
         sName$ = "Mc" & UCase(Mid$(sName$, 3, 1)) & LCase(Mid$(sName$, 4, 17))  '06Dec15 TH Replaced above (TFS 124058)
      End If
      'Now look for one secondary - these will be cased
      If InStr(LCase(sName$), " mc") > 3 And InStr(LCase(sName$), " mc") < 19 Then
         sName$ = Left$(sName$, (InStr(LCase(sName$), " mc")) - 1) & " Mc" & UCase(Mid$(sName$, InStr(LCase(sName$), " mc") + 3, 1)) & Mid$(sName$, InStr(LCase(sName$), " mc") + 4, (Len(sName$)))
      End If
      If InStr(LCase(sName$), "-mc") > 3 And InStr(LCase(sName$), "-mc") < 19 Then
         sName$ = Left$(sName$, (InStr(LCase(sName$), "-mc")) - 1) & "-Mc" & UCase(Mid$(sName$, InStr(LCase(sName$), "-mc") + 3, 1)) & Mid$(sName$, InStr(LCase(sName$), "-mc") + 4, (Len(sName$)))
      End If
   End If
   
   If shortname And Len(LTrim$(fname$ & " ")) + Len(sName$) > 24 Then    'over 24 chars for 'fname sname'
      fname$ = inits$                                   'use just the initials
   End If
   
   '25Jul11 TH Now we apply new casing rules if appropriate (F0109989,F0102479,F0089372,F0109869)
   Select Case LCase(TxtD(dispdata$ & "\ascribe.ini", "PID", "", "LabelNameCasing", 0))
      Case "lcfnamelcsname"
         'This is standard from the settings above.
      Case "lcfnameucsname"
         sName$ = UCase$(sName$)
      Case "ucfnameucsname"
         sName$ = UCase$(sName$)
         fname$ = UCase$(fname$)
      Case "ucfnamelcsname"
         fname$ = UCase$(fname$)
      Case "lcallfnameucsname"
         sName$ = UCase$(sName$)
         fname$ = LCase$(fname$)
      Case "lcallfnamelcsname"
         fname$ = LCase$(fname$)
      Case "lcfnamelcallsname"
         sName$ = LCase$(sName$)
      Case "ucfnamelcallsname"
         fname$ = UCase$(fname$)
         sName$ = LCase$(sName$)
      Case "lcallfnamelcallsname"
         fname$ = LCase$(fname$)
         sName$ = LCase$(sName$)
      Case Else
   
   End Select
   
   If Not SnameFname Then                                  'Traditional layout; forename first
         PatientName$ = fname$ & " " & sName$              'F Bloggs' or 'Fred Bloggs'
      ElseIf Len(fname$) Then
         If CommaSeparatedName Then                                                             '26Jan99 CFY Added
               PatientName$ = sName$ & ", " & fname$       'Bloggs, F' or 'Bloggs, Fred'
            Else
               PatientName$ = sName$ & fname$              'Bloggs F' or 'Bloggs Fred'          '26Jan99 CFY Added
            End If
      Else
         PatientName$ = sName$                             'Bloggs'
      End If
      
   PatientName$ = Trim$(PatientName$)                      'remove leading or trailing space
   
   '25Jul11 TH Put the new names on the print heap
   Heap 10, gPRNheapID, "pName", PatientName$, 0
   Heap 10, gPRNheapID, "psName", sName$, 0
   Heap 10, gPRNheapID, "pfName", fname$, 0
   
End Sub


