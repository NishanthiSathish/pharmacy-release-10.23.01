Attribute VB_Name = "TPNW"
'17Jan12 TH Ported from v8
'
'mods wanted:
'------------
'/allow water as universal diluent, as well as glucose
'X  this also still has to be product 6
'/prod 21 still has to be pot phos
'/add trap for cals/vol when no igs
'  "   "   lipid only
' max dose only operates when choosing std paed reg
'/ should check everywhere? Also need ml/kg and total ml
'/optional offset product 0 displayed/entered as product 1
'/(G)rams/kg v grams/(K)g
'/spgravcalc - remove overage for adults (- overage now zero and non editable)
'/prescribe for adults as total, not just /kg
'/remove/change Fe warning in adults. (- removed second warning)
' 03sep99 Add acquirelock round calls involving BlackBoard table
'
' Security clearance
'   prescribe, transcribe prescription, /authorise, /view & print only
'/Na back to previous
'/Rules at saving script
' Issue/Return
'/Fonts & layout
'/Save/Read
'/Offer save on exit
'/Printing
'/remove adjcontrol
'/allow return to start editing
'/add electrolytes
' add invoice
'/check batch; weight = 0
' check paeds
'/check adjust K
' IEEE v MBF including the 'Original' proc
'/add info to bottom of VA screen - C/P, sep amino/lipid, Adult!
'Xmain menu blank if nulls in string
'/Replace product
'/Add sort of utils to main menu - allow print products, rules, std regs etc
'/define products by ASC code not prod num now
' handle missing products - one which has been turned off since saving last
'/remove offset & all internal product numbers from display
' volume/cals back to previous
' enter prescription as total for adult & batch
' alternative RTF for batch invoices?
' volumecheck & warningsvdu - check usage (if any)
' 'save as' option allowing new regimen based on existing one.
' return regimen based on transactions, including items issued to waste
'
'LICENCE FILE
'------------
'  Tpn         T/F
'     Paed     T/F
'     Adult    T/F
'     Batch    T/F
'     Issue    T/F
'     Baxa     T/F
'     Vacumat  T/F
'     EditPrd  T/F
'     EditReg  T/F
'     EditRule T/F
'
'
'product file layout:
'Editor                                           PRD$  PROD!  tot!
'    (total volume)                                             0
' 1) Product description    Vamin 9 glucose       (0)    --
' 2) Volume of container    1000 ml               (12)   0
' 3) Non-protein energy     400  kcal             (1)    1      1
' 4) Nitrogen               9.4  g                (2)    2      2
' 5) Glucose                100  g                (3)    3      3
' 6) Fat                    0    g                (4)    4      4
' 7) Sodium                 50   mmol             (5)    5      5
' 8) Potassium              20   mmol             (6)    6      6
' 9) Calcium                2.5  mmol             (7)    7      7
'10) Magnesium              1.5  mmol             (8)    8      8
'11) Zinc                   0    umol             (9)    9      9
'12) Phosphate              0    mmol             (10)   10     10
'13) Chloride               55   mmol             (11)   11     11
'14) Acetate                     mmol              --    12     12
'15) Selenium                    umol              --    13     13
'16) Specific gravity       1.06   g/ml            13    --
'17) Solution (A/B)paed use A                      14    --
'18) Approximate cost     £ 6.93                   15    --
'19) Initial mixing    0-9  1                      16    --
'20) Maximum dose           0    ml                17    --
'21) ASC code for product   VAMI9                  18    --
'22) Viscosity              0.9342                 --    --
'23) Baxa spike             V                      --    --
'    (All baxa info)                               20    --
'   Baxa.Acetate AS STRING * 4
'   Baxa.Selenium AS STRING * 4
'
'
'PrdType 1 PN product
'        2 Other infusion
'        4 Enteral Feed
'          These can be added e.g. 7 = usable as PN, enteral and general infusion
'
' these are organised in the prod() and prd() arrays as follows
'            enteral    -NPi  infusions   -1      PN products
'                        |                 |
'        eeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiiiippppppppppppppppppppppppp
'        |              |                   |                       |
'       -NPe-NPi       -NPi-1               0                       NP-1
'
'Note that a product of type 3 will appear in the list TWICE, once in the infusions section
'  and once in the PN products section. Type 7 products appear once in all three sections.
'
'11Sep14 XN 88799 Added printing of prescription from regimen
'                 PNLoadRegimen - Got it to print prescription directly if no supply request ID
'                 PNLoadProducts- got to use new regimen request ID
'12May15 XN FillPrintHeapPN: Ensured there is a leading 0 on dosingweight < 1Kg 118106
'02Jun15 XN FillPrintHeapPN: Added missing print elements 120001 kcalpergN, modtextshort, regimen30, regimennomodtext, regimennomodtext30, pharmacytext, reqdoc
'24Sep15 XN FillPrintHeapPN: Add all the aliases to the heap 77778
'29Oct15 XN FillPrintHeapPN: Use the case number from the xml by default 133714
'04Nov15 TH PNLoadRegimen: Load the PNPrescriptionID and Supply request into the globals here so we can use this in any transaction logs (TFS 133853)
'16Feb16 XN PNLoadRegimen: Fixed issue with PN supply request not populating Wtranlog.RequestID_Dispensing 145448
'30Mar15 XN PrintTPNlabel: Added PN Paed Label type 102357
'           PNLayoutEditor: Added pn paed labels 102357
'                       HasLayout: added function 102357
'02Jun16 XN FillPrintHeapPN: 154627 added infrateb_full
'06Dec16 TH PNLayoutEditor: First pass rtf file replacement (TFS 157969)
'06Dec16 TH mixtestformat: Replaced RTF Handling (TFS 157969)
'04Jan17 TH PrintTPNLabel: Use the rtf templates from the DB (Hosted)
'04Jan17 TH PrintListBoxContents: Use rtf Templates from DB (Hosted)
'04Jan17 TH LipidSyringes: Changes to RTF Handling for Hosted (TFS 157969)
'04Jan17 TH ParseandPrint: Use rtf templates from DB (Hosted)
'30Jan17 TH PNLayoutEditor: Ensure any mods are saved to the DB (TFS 174973)

Option Explicit
DefInt A-Z

Type ProductDetails
   id           As Integer     'PrdID
   SpGrav       As Single      'Prd(x, 13) = prdss!SpGrav
   SolnAB       As String * 1  'Prd(x, 14) = prdss!SolnAB       '
   cost         As String      'Prd(x, 15) = prdss!Cost         ' £cost
   PreMix       As Integer     'Prd(x, 16) = prdss!PreMix       ' Mix0-9
   maxmltotal   As Single      'Prd(x, 17) = prdss!MaxmlTotal   ' Maxdose
   linkcode     As String * 7  'Prd(x, 18) = prdss!LinkCode     ' NSVlink
   'Viscosity                  'PRD(x, 19) = prdss!Viscosity
   maxmlperkg   As Single
   SharePacks   As Integer     ' 0 or -1
   'spike
   'BaxaMMig     As Integer    '26Nov96 CKJ Added  05Jun00 CKJ
   BaxaMMig     As String * 13 '26Nov96 CKJ Added  05Jun00 CKJ changed from integer to 13 char string
   VacumatIg    As Integer     '26Nov96 CKJ Added
   mOsmperml    As Single
   gH2Operml    As Single
   'Protein
   PO4organic   As Integer     ' 21Oct96 CKJ field added T/F
   name         As String      '7Apr98 CKJ added here to replace the prdname$() array
   ForPaed      As Integer     '04Jun98 CKJ
   ForAdult     As Integer     '04Jun98 CKJ
   Info         As String * 255 '05Jun00 CKJ Added
End Type

''Type ClinicalDetails
''   'CN$
''   'DR$
''   'df$
''   'CP$
''   'rd$
''   'feedlength$
''   'REA$
''   'BodyTemp$
''   'AF$
''   'ifact$
''
''   CardiacFailure         As Integer   '0/-1
''   RenalFailure           As Integer   '0/-1
''   Haemodialysis          As Integer   '0/-1
''   PeritonealDialysis     As Integer   '0/-1
''   Haemofiltration        As Integer   '0/-1
''   Septicaemia            As Integer   '0/-1
''   FulmHepaticFailure     As Integer   '0/-1
''   BiliOver100unconj      As Integer   '0/-1
''   BiliOver170unconj      As Integer   '0/-1
''   Phototherapy           As Integer   '0/-1
''   RadiantHeat            As Integer   '0/-1
''   Diuretics              As Integer   '0/-1
''   SerumSodiumCategory    As Integer   '0 to 5
''   SerumPotassiumCategory As Integer   '0 to 5
''End Type

'General control variables
Const tpndefaultfile = "\TPNDEFLT.V5"

Global VAxy() As String                'view & adjust
Global SCxy() As String                'prescription
Global RowsUsed As Integer             'view & adjust
Global EnteralRow As Integer           '25Mar98 CKJ
Global InfusionRow As Integer          '   "
Global GrandTotRow As Integer          '   "
Global ScriptRow As Integer            '   "
Global RowsUsedSC As Integer           'prescription
Global UExy(1 To 12, 1 To 10) As String
Global TpnVO As Integer                'View Only flag
Global ElectAltered As Integer         '01Jun02 All/CKJ added as integer
Global displaysize%                    '0=WinCE 1=640x480 2=800x600 3=larger (only 1 & 2 used now)

Dim DT1 As DateAndTime
Dim DT2 As DateAndTime
Dim securityaccess As Integer          ' CKJ          '01Jun02 All/CKJ added as integer
Dim tpndef As tpndefaults              ' 1Nov91 CKJ
Dim tpninifile$

Dim SDilGlconc As Single               '27Dec95 CKJ Added
Dim TPNchanged As Integer              '   "          '01Jun02 All/CKJ added as integer
Dim adjKpaed%, adjKadult%              '   "
Dim adjNaPaed%, adjNaAdult%
Dim PaedKClKPO4split%
Dim SQLdbg As Integer
Dim MasterDebug As Integer
Dim RTFinternalTransfer$
Dim OEMver%
Dim ExitAfterPrinting%                 '13Nov98 CKJ added

''Dim patdb As Database, patds As Dynaset, patdbopen As Integer
''Dim regdb As Database, regss As snapshot, regdbopen As Integer
''Dim prddb As Database, prdss As snapshot, prddbopen As Integer

'Product & regimen data
Global IgMax As Integer                'used in ViewAdj form too
Dim IgMaxIncNonDisp As Integer         '27Aug98 CKJ Includes non-displayed igs, up to Vitamin K

Dim NP As Integer                      'number of products available for use
''Dim NPe As Integer, NPi As Integer     'number of enteral and general infusion products
Dim prod() As Single                   'all products vol, mg etc
'Dim prdname() As String               'all product names    8Apr98 CKJ removed; now in PRD().name
Dim Prd() As ProductDetails            'part product info
Dim IgVol%, igCals%, igN%, igGl%, igFat%, IgNa%, igK%, IgCa%, IgMg%, IgZn%, IgPO4%, IgCl%, IgAcet%, IgSe%, IgCu%, IgFe% 'now 0 to 15, was 0 to 14 before Fe
Dim IgVitE%                            '16Feb00 CKJ added
Dim IgVitK%                            '27Aug98 CKJ added
Dim IgMn%                              ' 1Sep98 CKJ added
Dim PrdN%, PrdGl%, PrdFat%, PrdNa%, PrdK%, PrdCa%, PrdMg%, PrdCu%, PrdZn%, PrdSe%, PrdPO4%, PrdVaqu%, PrdVlip%, PrdFe%
Dim PrdNaCl%, PrdKCl%, PrdKPO4%, PrdDil%
Dim sup As supplierstruct
''Dim ManualIE() As Single               '2D array to hold manually entered infusions & enteral feeds

'Patient data, PID, regimen, prescription etc
Dim tot() As Single                    '@@
Dim overage(1 To 3) As Single
Dim PrescriptionID&                    '30sep96 CKJ/ASC Added
Dim inf As Single
Dim heightcms As Single
Dim CN$, DR$, df$, CP$, rd$, feedlength$, REA$, BodyTemp$, AF$, ifact$
Dim weight As Single
Dim dob As String
Dim AgeInDays As Long                  '30Sep96 CKJ Long Integer
Dim AgeInYears As Single               '   "        Decimal places for part year
Dim PatientName As String              '   "
Dim regname As String                  '   "
Dim batchnumber As String              '   "
Dim origdate As String
Dim infratefat%
Dim infrateamino%
Dim expiryB$
Dim expiryA$
Dim ncwa%
Dim ncwf%
Dim wardexp$, consexp$
Dim TotAmino As Single                 '21Jul95 CKJ added
Dim TotLipid As Single                 '31Jul95 CKJ added
Dim TotGlucA As Single                 '31Jul95 CKJ added
Dim TotInPO4 As Single                 '21Oct96 CKJ added
Dim TotAminoOv As Single               '25Oct95 CKJ added Tot vol inc overage of combined/aqueous
Dim TotLipidOv As Single               '25Oct95 CKJ added Tot vol inc overage of lipid only
Dim OtherFluids As Single              '25Jul95 CKJ added
Dim dayofwk$, lblscombined%
Dim totK!, totNa!
Dim NaCategory%, KCategory%            'used for command buttons in Clinical Details page
Dim igover!()
Dim ig() As Single                     'igs for this patient now
Dim ModIg(0 To 3) As Integer           '0 current prod, 1 diluent, 2 K, 3 Na    '01Jun02 All/CKJ added as integer
''Dim Clin As ClinicalDetails
Dim InvoiceTo$, invoicenum$, InvoiceTable$
Dim numofbags%
Dim nsvcodes() As String               '17Aug98 CKJ now dynamic, was nsvcodes(80)
Dim CostPerBag$                        '1Jul97 CKJ
Dim bagLoop As Integer
Dim kcalPerGramFat!                    '05Jun00 CKJ added
Dim kcalPerGramGlucose!                '   "
Dim iBatchMode As Integer              '18Jul00 CKJ boolean set in TPNmain

Dim mTPNreadonly As Integer            '02Jul08 CKJ Enforce readonly when set
Dim m_blnAdult As Boolean
Dim m_intNumberofbags As Integer
Dim m_SupplyRequestAdminStartDate As Date
Dim strRegimenDescription As String '29Feb12 TH Added
Dim m_blnLabels As Boolean  '02Mar12 TH Added
Dim m_intDaysPerBag As Integer            '19Apr12 TH Added
Global g_blnPNStatusIssued As Boolean     '07Mar12 TH Added
Global g_blnPNStatusPrinted As Boolean    '07Mar12 TH Added
Global g_blnPNStatusComplete As Boolean   '07Mar12 TH Added
Global g_blnPNStatusBeingMade As Boolean  '07Mar12 TH Added
      

'Global proddim%
'Dim ElectRecno As Long                'not used !!**
'Dim F(17) As Long                     'still needed by Main/TPNElect - now local array
'Dim t As Single
'Dim BNT As Integer                    '   "
'Dim sex As String                     '14Oct96 CKJ removed
'Dim baxa      As baxa1
'Dim baxaload  As baxatx
'Dim Prd() As String                   'part product info
'Dim reg() As String                   'regimen summary info
'Dim nr As Integer                     'number of regimens loaded
'Dim nor As Integer  'Regimen number    !!**


'03Sep99 CKJ Obsolete code commented out
'Sub prnlbl (chars$, Escaped)
'10Aug95 CKJ Written. Parse ctrls & data then resolve printer references
'            Uses PRN to execute printing. Returns escaped=True if failed
'
'Dim filename$, section$, MyPrinter$, Changed%, lblprnst$
'
'   filename$ = dispdata$ + tpninifile$
'   section$ = ""
'   MyPrinter$ = Terminal$("TPNLPTtype", "EpsonFX80")
'
'   Do
'      Changed = False
'      ParseCtrlChars filename$, section$, chars$, Changed
'      ParseTPNDataItems chars$, Changed
'      ParseCtrlChars dispdata$ + "\printer.ini", MyPrinter$, chars$, Changed
'   Loop While Changed
'
'   'label printer defaults to TPNdef value but can be overridden by terminal.ini
'   lblprnst$ = Terminal$("TPNlblLPT", LTrim$(Str$(tpndef.labelprinter)))
'
'   'PRN Val(lblprn$), chars$, False, Escaped
'   FastPrint Val(lblprnst$), chars$, "TPNlblLPTtype", False, Escaped
'End Sub


'Sub ParseTPNDataItems (item$, Changed)
'17Jan95 CKJ Copied from ParseCtrlChars, but uses local data items
'03Sep99 CKJ Obsolete code commented out
'Static freetxt$
'Dim length%, posn%, openbrace%, closebrace%, char$, middle$, noi%, x%
'Dim leftprint%, Tvols$, Tvolv!, afm%, drpspermin%, ans$
'
'   popmessagecr ".", "Procedure ParseTPNDataItems called - this is now obsolete"
'
'Exit Sub
'
'   length = Len(item$)
'   If length Then
'         posn = 1 'was 0
'         Do
'            openbrace = InStr(posn, item$, "[")    'was + 1
'            closebrace = 0
'            If openbrace Then closebrace = InStr(openbrace + 1, item$, "]")
'            If closebrace > openbrace And openbrace > 0 Then
'                  char$ = ""
'                  middle$ = Mid$(item$, openbrace + 1, closebrace - openbrace - 1)
'                  Select Case LCase$(middle$)
'                     Case ""            'no action
'                     Case "hospname1":  char$ = pad$(hospname1$, 40)
'                     Case "hospname2":  char$ = pad$(hospname2$, 25)
'                     Case "hospabbr":   char$ = hospabbr$
'                     Case "userid":     char$ = userid$             '24Oct96 CKJ new
'                     Case "username":   char$ = UserFullName$       '   "
'                     Case "today":      char$ = td$
'                     Case "timenow":    char$ = Format$(Now, "hh:mm am/pm")
'                     Case "patname":    char$ = pad$(patientname$, 36)
'                     Case "patname21":  char$ = pad$(patientname$, 21)
'                     Case "dob":        char$ = pad$(dob$, 15)
'                     Case "reqdoc":     char$ = rd$
'                     Case "caseno":     char$ = pid.caseno
'                     Case "weight":     char$ = pad$(LTrim$(Str$(weight!)) & "kg", 15)
'                     Case "batchno"
'                        If Len(Trim$(BatchNumber$)) Then
'                              'char$ = Trim$(Batchnumber$) + RIGHT$("000" + LTRIM$(STR$(BNT)), 3)
'                              char$ = pad$(BatchNumber$, 9)   '18Aug95 CKJ as in PrintLabel
'                           Else
'                              char$ = "[EmptyBatch]"
'                           End If
'                     Case "wardexp":    char$ = wardexp$
'                     Case "wardexp20":  char$ = pad$(wardexp$, 20)
'                     Case "consexp":    char$ = pad$(consexp$, 30)
'                     Case "consexp15":  char$ = pad$(consexp$, 15)
'                     Case "regimen":    defregstring regname$, origdate$, char$
'                     Case "regname":    char$ = pad$(regname$, 30)  '5Oct96 CKJ was 20
'                     Case "comment":    If Len(Trim$(REA$)) Then char$ = "[commentlin]" Else char$ = ""
'                     Case "commenttxt": char$ = REA$
'                     Case "wsmixigs":   mixtestformat char$, False
'                     Case "wsmix/kg":   mixtestformat char$, True
'                     '                  for reference; text$, tot!(), combined, perkilo, weight!
'                    'CASE "constits":   constitsformat char$, tot!(), false, false, weight!
'                     Case "constits":   constitsformat char$, tot!(), True, False, weight!   '8Jan96 CKJ inhibit 'fat in part B'
'                     Case "constitsa"   'use only on labels!
'                        If Not lblscombined Then calctotals "A"
'                        constitsformat char$, tot!(), lblscombined, False, weight!
'                        calctotals ""
'                     Case "constitsb"   'use only on labels!
'                        calctotals "B"
'                        constitsformat char$, tot!(), True, False, weight!
'                        calctotals ""
'                     Case "constitskg": constitsformat char$, tot!(), lblscombined, True, weight! '!!** Unused
'                     Case "constkgtot": constitsformat char$, tot!(), True, True, weight!
'                     Case "warnings":   wsheetwarningsformat TotAmino, TotGlucA, tot!(), char$ '!!**
'                     Case "totvol":     char$ = Format$(tot!(0), "0.#")              'was str$()
'                     Case "kconc":      char$ = tsf$(tot!(igK) / (TotAmino / 1000))  'was 6
'                     Case "naconc":     char$ = tsf$(tot!(IgNa) / (TotAmino / 1000)) 'was 5
'                     Case "otherfluids": char$ = Trim$(Str$(OtherFluids))
'                     Case "totml3sf":   char$ = tsf$(tot!(0))
'                     Case "totml/kg":   char$ = tsf$((tot!(0) / weight!)) 'NB not for Batch use
'                     Case "totmla3sf":  char$ = tsf$(TotAmino)
'                     Case "totmlb3sf":  char$ = tsf$(TotLipid)
'                     Case "totmlovg":   char$ = tsf$(TotLipidOv + TotAminoOv) '25Oct96 CKJ
'                     Case "printigs":   char$ = PrintIg("")
'                     Case "printiga":   char$ = PrintIg("A")
'                     Case "printigb":   char$ = PrintIg("B")
'                     Case "glucaconc":  char$ = tsf$(TotGlucA! / TotAmino! * 100)
'                     Case "reverselbl": If tpndef.printreversefeed Then char$ = "[reversefeed]"
'                     Case "forwardlbl": If tpndef.printreversefeed Then char$ = "[forwardfeed]"
'                     Case "lblsetlen":  If tpndef.labels4inches Then char$ = "[4inchFF]" Else char$ = "[5.5inchFF]"
'                     Case "day":        If Len(dayofwk$) Then char$ = "[l.for]" & dayofwk$
'                     Case "ivtype"
'                        Select Case CP$
'                           Case "P":  char$ = "[IVperi]"
'                           Case "C":  char$ = "[IVcent]"
'                           Case "E":  char$ = "[IVCorP]"
'                           Case Else: char$ = "[IVunkn]"           'unspecified
'                           End Select
'
'                     Case "lbligsa"
'                        noi = 0
'                        For x = 0 To NP - 1
'                           If ig(x) <> 0 Then
'                                 If lblscombined Or RTrim$(prd(x).SolnAB) = "A" Then 'was14
'                                       noi = noi + 1
'                                    End If
'                              End If
'                        Next
'                        If noi < 20 Then char$ = "[cr]"
'                        If noi > 22 Then char$ = char$ & "[8lpi]"
'
'                        leftprint = False
'                        For x = 0 To NP - 1
'                           If ig(x) <> 0 Then
'                                 If lblscombined Or RTrim$(prd(x).SolnAB) = "A" Then  'was14
'                                       char$ = char$ & pad$(prd(x).name, 30)
'                                       char$ = char$ & tsf$(ig(x)) & "[ml]"
'                                       leftprint = Not leftprint
'                                       If leftprint Then
'                                             char$ = char$ & "     "
'                                          Else
'                                             char$ = char$ & "[cr]"
'                                          End If
'                                    End If
'                              End If
'                        Next
'                        If leftprint Then char$ = char$ & "[cr]"
'                        If noi > 22 Then popmessagecr tp("WARNING"), tp("Extendlab")
'                        If noi < 20 Then
'                              For x = Int(noi / 2) To 8
'                                 char$ = char$ & "[cr]"
'                              Next
'                           End If
'
'                     Case "lbligsb"
'                        noi = 0
'                        For x = 0 To NP - 1
'                           If ig(x) <> 0 And RTrim$(prd(x).SolnAB) = "B" Then  'was14
'                                 noi = noi + 1
'                                 char$ = char$ & "[PrintIg1]" & pad$(prd(x).name, 30) & " " & tsf$(ig(x)) & "[PrintIg2]"
'                              End If
'                        Next
'                        If noi > 4 Then popmessagecr tp("WARNING"), tp("Extendlab")
'                        If noi < 4 Then
'                              For x = noi To 4
'                                 char$ = char$ & "[cr]"
'                              Next
'                           End If
'
'                     Case "infratea"
'                        If lblscombined Then
'                              Tvols$ = "[totml3sf]"
'                              Tvolv! = tot!(0)
'                              afm = 3
'                           Else
'                              Tvols$ = "[totmlA3sf]"
'                              Tvolv! = TotAmino
'                              afm = 1
'                           End If
'
'                        If infrateamino > 0 And UCase$(pid.sex) <> "B" Then
'                             'char$ = "[l.Infuse]" + Tvols$ + " [ml][l.over]" + STR$(infrateamino) + "[l.at]" + tsf$(totAmino / infrateamino) + "[l.mlperhr]"
'                              char$ = "[l.Infuse]" & Tvols$ & " [ml][l.over]" & Str$(infrateamino) & "[l.at]" & tsf$(Tvolv! / infrateamino) & "[l.mlperhr]"    '8Jan96 CKJ Corrected
'                              If tpndef.dropspermin Then
'                                    drpspermin% = Int((((Tvolv! / infrateamino) + .5) / 60) * tpndef.dropsperml(afm))
'                                    If drpspermin% > 4 Then
'                                          char$ = char$ & "[l.or]" & Str$(drpspermin%) & "[l.drp/min]"
'                                       End If
'                                 End If
'                           Else
'                              char$ = char$ & " [l.volume] " & Tvols$ & "[ml] "
'                           End If
'                        char$ = char$ & "[cr]"
'
'                     Case "infrateb"
'                        If infratefat > 0 And UCase$(pid.sex) <> "B" Then
'                              char$ = "[l.Infuse][totmlB3sf] [ml][l.over]" & Str$(infratefat) & "[l.at]" & tsf$((TotLipid / infratefat)) & "[l.mlperhr]"
'                              If tpndef.dropspermin Then
'                                    drpspermin% = Int((((TotLipid / infratefat) + .5) / 60) * tpndef.dropsperml(2))
'                                    If drpspermin% > 4 Then
'                                          char$ = char$ & "[l.or]" & Str$(drpspermin%) & "[l.drp/min]"
'                                       End If
'                                 End If
'                           Else
'                              char$ = " [l.volume] [totmlB3sf] [ml]"
'                           End If
'                        char$ = char$ & "[cr]"
'
'                     Case "parta":   If Not lblscombined Then char$ = "[l.parta]" '!!use on labels only
'                     Case "expirya": char$ = expiryA$
'                     Case "expiryb": char$ = expiryB$
'
'                     Case "i/olblhdr"                     ' in/out patient headers
'                        If UCase$(pid.status) = "O" Then  'ASC 8Oct93 Added for Hope
'                              char$ = "[opLblHdr]"
'                           Else
'                              char$ = "[ipLblHdr]"
'                           End If
'                     Case "freetext"
'                        char$ = ""
'                        'k.helpnum = 920
'                        k.min = 0
'                        k.max = 76
'                        ans$ = freetxt$
'                        inputwin "Enter free text, if required", "", ans$, k
'                        If Not k.escd Then char$ = ans$: freetxt$ = ans$
'                     Case "internal":     char$ = RTFinternalTransfer$
'                     Case "invoiceto":    char$ = InvoiceTo$                '!!** not in help yet
'                     Case "invoicenum":   char$ = invoicenum$               '!!**
'                     Case "invoicetable": char$ = InvoiceTable$             '!!**
'                     Case "numofbags":    char$ = Format$(numofbags)        '!!**
'                     Case "costperbag":   char$ = CostPerBag$               '1Jul97 CKJ moved from DOS
'
'                     Case Else
'                        char$ = "[" & middle$ & "]"   'print as found
'                     End Select
'
'                  If char$ = "[" & middle$ & "]" Then
'                        posn = openbrace + 1 ' was just before LOOP ...
'                     Else
'                        Changed = True
'                     End If
'                  item$ = Left$(item$, openbrace - 1) & char$ & Mid$(item$, closebrace + 1)
'               End If
'         Loop While openbrace > 0 And closebrace > 0
'      End If
'End Sub

'Function IronTotalX () As Single
''05Jun98 CKJ Function now obsolete as done in SQL
'
'Dim x%, SQLq$, amount!
'
'   amount! = 0
'   For x = 0 To NP - 1
'      If ig(x) > 0 Then     'some of this product present
'            SQLq = "SELECT Iron_micromol FROM prddat WHERE LinkCode='" & Prd(x).linkcode & "';"
'            If SQLdbg Then popmessagecr "SQL", SQLq
'            Set prdss = prddb.CreateSnapshot(SQLq)
'            prddbopen = 2
'
'            If Not prdss.EOF Then
'                  amount! = amount! + ig(x) * Getfield(prdss!Iron_micromol) / prod!(x, IgVol)
'               End If
'         End If
'   Next
'   IronTotalX = amount!
'
'End Function


'Sub TgSetCurCellColor (Ctl As TrueGrid, fg As Long, bg As Long)
'' ==========================================================
'' Sub: TgSetCurCellColor
''
'' This routine sets the color of the current cell.  If you
'' want the entire highlighted row marquee to be a different
'' color, then execute TgSetMarqueeColor FIRST.
'' ==========================================================
'
'   Ctl.ParamForeColor = fg
'   Ctl.ParamBackColor = bg
'
'   ' Set the color for all possible current cell combinations,
'   ' but not for other cells in the highlighted row
'
'   Ctl.SetStatusAttr = GFS_CURCELL
'   Ctl.SetStatusAttr = GFS_CURCELL + GFS_SELECTED
'   Ctl.SetStatusAttr = GFS_CURCELL + GFS_CHANGED
'   Ctl.SetStatusAttr = GFS_CURCELL + GFS_CHANGED + GFS_SELECTED
'   Ctl.SetStatusAttr = GFS_HIGHROW + GFS_CURCELL
'   Ctl.SetStatusAttr = GFS_HIGHROW + GFS_CURCELL + GFS_SELECTED
'   Ctl.SetStatusAttr = GFS_HIGHROW + GFS_CURCELL + GFS_CHANGED
'   Ctl.SetStatusAttr = GFS_HIGHROW + GFS_CURCELL + GFS_CHANGED + GFS_SELECTED
'
'End Sub

Sub EnforceTPNreadonly()
'02Jul08 CKJ Set a module level flag so that next call to TPNmain will be read only
           
   mTPNreadonly = True

End Sub

Function findKPO4()
'27Dec95 CKJ Find Potassium Phosphate ingredient - Product 21
'            Normally Pot Acid Phos or Addiphos
'            Halt if not suitable.
'10Oct96 CKJ Restriction of product 21 now lifted

   If prod!(PrdKPO4, IgPO4) <= 0 Or prod!(PrdKPO4, igK) <= 0 Then
         popmessagecr "Program will now end", "Potassium phosphate has not been configured correctly" & cr & "Press RETURN to exit ... "
         findKPO4 = False
      Else
         findKPO4 = True
      End If

End Function

Function findpotchlor()
'-------------Finds which product is potassium chloride-----------------------
'15Nov99 CKJ replaced IgMax with IgMaxIncNonDisp

Dim X%, totl%

   'For x = 1 To IgMax           '15Nov99 CKJ removed
   For X = 1 To IgMaxIncNonDisp  '15Nov99 CKJ was IgMax
      If prod!(PrdKCl, X) Then totl = totl + 1   'count the number of measurable ingredients
   Next
   If prod!(PrdKCl, igK) <= 0 Or prod!(PrdKCl, IgCl) <= 0 Or totl <> 2 Then
         popmessagecr "Program will now end", "Potassium Chloride has not been configured correctly" & cr & "Press RETURN to exit ... "
         findpotchlor = False
      Else
         findpotchlor = True
      End If
   
'Dim x%, y%, others!
'
'   x = 0
'   Do
'      others! = 0
'      If prod!(x, IgCl) > 0 And prod!(x, IgK) > 0 Then        '@
'               For y = 1 To IgMax   '@@  13       'OK, was 10
'                  Select Case y
'                     Case IgK, IgCl       '6, 11
'                     Case Else: others! = others! + prod!(x, y)'@
'                     End Select
'               Next
'               If others! <= 0 Then
'                     PrdKCl = x
'                     Exit Do
'                  End If
'            End If
'      x = x + 1
'   Loop Until x = NP
'
'   If x = NP Then
'         '"ABORTING", "Check potassium chloride is present in your database"
'         popmessagecr "!n!b" + tp("Error"), tp("CheckKCl")
         
End Function

Function findSDil()
'27Dec95 CKJ Examine standard diluent - product 6
'            Normally 5% Gl, but may be WFI or other glucose concentration.
'            Halt if not suitable.
'12Apr96 CKJ PrdDil now read in from .ini file
'10Oct96 CKJ Product can be in any position in database - given by PrdDil
'15Nov99 CKJ replaced IgMax with IgMaxIncNonDisp

Dim valid%, Y%

   valid = True
   'For Y = 2 To IgMax            '@@  13  'scan each ig (except calories)  '15Nov99 CKJ removed
   For Y = 2 To IgMaxIncNonDisp   '@@  13  'scan each ig (except calories)  '15Nov99 CKJ was IgMax
      If Y <> igGl And prod!(PrdDil, Y) <> 0 Then     'ig(3) is glucose
            valid = False
            Exit For
         End If
   Next

   If Not valid Then
         popmessagecr "!n!b" + tp("Error"), "Check that Glucose or WFI have been specified as diluent"
         findSDil = False
      Else
         SDilGlconc = prod!(PrdDil, igGl) / prod!(PrdDil, 0)     '[gl] = gluc(g) / container(ml)
         findSDil = True
      End If

End Function

Function findsodchlor() As Integer
'15Nov99 CKJ replaced IgMax with IgMaxIncNonDisp

Dim X%, totl%

   'For x = 1 To IgMax           '15Nov99 CKJ removed
   For X = 1 To IgMaxIncNonDisp  '15Nov99 CKJ was IgMax
      If prod!(PrdNaCl, X) Then totl = totl + 1   'count the number of measurable ingredients
   Next
   If prod!(PrdNaCl, IgNa) <= 0 Or prod!(PrdNaCl, IgCl) <= 0 Or totl <> 2 Then
         popmessagecr "Program will now end", "Sodium Chloride has not been configured correctly" & cr & "Press RETURN to exit ... "
         findsodchlor = False
      Else
         findsodchlor = True
      End If
   

End Function

Function findVLip() As Integer
'18Jul00 CKJ Written
'            Check that the product nominated as the lipid soluble vitamin solution does contain Vitamin E
'            as this is used as a proxy during calculations.

   If prod!(PrdVlip, IgVitE) > 0 Then
         findVLip = True
      Else
         findVLip = False
         popmessagecr ".", "The lipid soluble vitamin product chosen does not contain vitamin E" & cr & "This prevents calculations involving this product and PN cannot continue" & cr & "Press RETURN to exit ... "
      End If

End Function

Function FirstPrd(PIE%) As Integer
'Given PEI as follows
' 1 Parenteral
' 2 Concurrent Infusion
' 3 Enteral
'Returns the first entry in ig() and PRD() for that product type

   Select Case PIE
      Case 1: FirstPrd = 0
''      Case 2: FirstPrd = -NPi
''      Case 3: FirstPrd = -NPe - NPi
      End Select

End Function

Function ForAPuse(PrdNumber As Integer) As Integer
'24Sep98 CKJ Written.
'            Given the product number and using the global pid.sex returns whether product is
'            allowed for paediatric/adult usage

   If adult(pid.sex) Then
         ForAPuse = Prd(PrdNumber).ForAdult
      Else
         ForAPuse = Prd(PrdNumber).ForPaed
      End If

End Function

Function GetPrdNum(linkcode$) As Integer

Dim result%, X%
   
   'If Adult(pid.sex) Then Prefix$ = "a" Else Prefix$ = "p"
   'LinkCode$ = tpnini$(Prefix$ & PrdAbbrev$, "")
   If linkcode$ = "" Then
         result = -1                  'not found
      Else                            'scan for code
         For X = 0 To NP - 1
            If linkcode$ = Prd(X).linkcode Then
                  result = X          'found it
                  Exit For
               End If
         Next
         If X = NP Then result = -1   'not found
      End If
   If result = -1 Then
         popmessagecr "WARNING", "Product not found for code '" & linkcode$ & "'"
         k.escd = True
      End If
   GetPrdNum = result

End Function

''Sub GetStdRegimen(RegNum%)
'''Retrieve standard regimen from database.
''' RegNum% is the StdRegID
'''24Sep98 CKJ Added check for adult/paed usage
''
''Dim SQLq As String, x%, Y%, Product$, wrn$
''
''   k.escd = False
''
''   SQLq = "SELECT * FROM StdReg WHERE StdRegID=" & Format$(RegNum) & ";"
''   If SQLdbg Then
''         popmessagecr "SQL", SQLq
''      End If
''   Set regss = regdb.CreateSnapshot(SQLq) ' should be one matching record only
''   regdbopen = 2
''
''   If Not regss.EOF Then
''         For x = 0 To NP - 1 'clear all items
''            ig!(x) = 0
''         Next
''
''         For x = 1 To 25                                  'up to 25 products in 1 regimen
''            Product$ = GetField(regss("Lnk" & Format$(x)))
''            If Product$ <> "" Then                        'product present
''                  For Y = 0 To NP - 1                     'look at each product in turn
''                     If Prd(Y).linkcode = UCase$(Product$) Then   'found it
''                           ig(Y) = GetField(regss("Prd" & Format$(x)))
''
''                           '24Sep98 CKJ Added block to check if product can be used in adult/paed
''                           If Not ForAPuse(Y) Then
''                                 wrn$ = wrn$ & Prd(Y).name & " is not for " & Iff(adult(pid.sex), "adult", "paediatric") & " use" & cr
''                              End If
''                           Exit For
''                        End If
''                  Next
''                  '24Sep98 CKJ Warn if existing product no longer set as inuse
''                  If Y > NP - 1 Then
''                        wrn$ = wrn$ & "Product code " & Product$ & " not found and will not be shown in the regimen" & cr
''                     End If
''               End If
''         Next
''         If Len(wrn$) Then                                                    '24Sep98 CKJ added
''               popmessagecr ".", "Check and amend this regimen:" & cr & cr & wrn$
''            End If
''
''         regname$ = GetField(regss("RegName"))
''      Else
''         popmessagecr "!Warning", "This standard regimen has not been found"
''         k.escd = True
''      End If
''
''End Sub

''Sub gettpn()
'''03Apr96 CKJ Gettpn and Gettpn1 now combined
'''30Sep96 CKJ/ASC Added PrescriptionID for calling from PMR in Patmed
'''11Apr98 CKJ Added suffix handling
'''24Sep98 CKJ Added warning message on loading adult only products in paed regimen & vice versa
'''            Message also includes any invalid codes or not in use products
'''05Jun00 CKJ Preset defaults for infusion rates (#44434)
''
''Dim SQLq As String, x%, Y%, ptr&, Product$, PrdType%, tmpI$, tmpE$
''Dim wrn$, Qty!                                                                 '24Sep98 CKJ Added

''   SQLq = ""
''   prescriptionID& = 0
''   If identtype$ = "1" Then 'called from Patmed
''         prescriptionID& = PresentPrescriptionID() 'long Int
''         If prescriptionID& <> 0 Then          'Given Prescription number, find the one TPN record
''               SQLq = "SELECT * FROM PatRegDat WHERE PrescriptionID=" & Format$(prescriptionID&) & ";"
''            End If
''      End If
''
''   If identtype$ <> "1" Or SQLq = "" Then   'Given Caseno (or no RxID), find TPN record(s)
''         'Find all for this patient, most recent first
''         SQLq = "SELECT * FROM PatRegDat WHERE PatRecNo='" & Trim$(pid.recno) & "' ORDER BY PatRegID Desc;"
''      End If
      
   'Need Equivalent of above to get the Data required.

''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set patds = patdb.CreateDynaset(SQLq)
''   patdbopen = 2
 
''  If Not patds.EOF Then
''         'count number of records found & offer list box if >1     !!** list box preferred
''         patds.MoveLast
''         patds.MoveFirst
''         x = patds.RecordCount
''         If x > 1 Then
''               Screen.MousePointer = STDCURSOR            '14Nov97 CKJ Added
''               popmessagecr "!Please Note", Format$(x) & " records have been found for this patient;" & cr & "the most recent record will be shown." & cr & cr & "Select using the PMR to see current and historical PN."
''            End If
''         For x = 1 To 25                                  'up to 25 products in 1 regimen
''            Product$ = GetField(patds.Fields("Lnk" & Format$(x)))
''            Qty! = GetField(patds.Fields("Prd" & Format$(x)))                  '24Sep98 CKJ Added
''            'If product$ <> "" Then                       'product present     '   "    replaced
''            If Product$ <> "" And Qty! <> 0 Then          'product present     '   "    added qty
''                  Select Case Right$(Product$, 1)
''                     Case "_":  PrdType = 3               'enteral
''                     Case "-":  PrdType = 2               'other infusion
''                     Case Else: PrdType = 1               'normal PN item
''                     End Select
''                  replace Product$, "-", "", 0
''                  replace Product$, "_", "", 0
''                  Product$ = RTrim$(Product$)
''                  For Y = FirstPrd(PrdType) To LastPrd(PrdType)  '0 To NP - 1  'look at each product in turn
''                     If Prd(Y).linkcode = Product$ Then                        'found it
''                           'ig(y) = Getfield(patds.Fields("Prd" & Format$(x))) '24Sep98 CKJ
''                           ig(Y) = Qty!                                        '24Sep98 CKJ Added
''                           '24Sep98 CKJ Added block to check if product can be used in adult/paed
''                           If Not ForAPuse(Y) Then
''                                 wrn$ = wrn$ & Prd(Y).name & " is not for " & Iff(adult(pid.sex), "adult", "paediatric") & " use" & cr
''                              End If
''                           Exit For
''                        End If
''                  Next
''                  '24Sep98 CKJ Warn if existing product no longer set as inuse
''                  If Y > LastPrd(PrdType) Then
''                        wrn$ = wrn$ & "Product code " & Product$ & " not found and will not be shown in the regimen" & cr
''                     End If
''               End If
''         Next
''
''         tmpI$ = GetField(patds!Infusion)   'infusions
''         ReDim lines$(0 To IgMax)
''         deflines tmpI$, lines$(), "|(*)", 0, 0
''         For x = 0 To IgMax
''             ManualIE(2, x) = Val(lines$(x))
''         Next
''         tmpE$ = GetField(patds!Enteral)    'enteral
''         ReDim lines$(0 To IgMax)
''         deflines tmpE$, lines$(), "|(*)", 0, 0
''         For x = 0 To IgMax
''             ManualIE(3, x) = Val(lines$(x))
''         Next
''
''         If GetField(patds!AuthModDate) > 0 Then
''               origdate$ = Format$(patds!AuthModDate, "ddmmyyyy")   '13Aug98 CKJ was ddmmyy
''            End If
''
''         If prescriptionID& = 0 Then 'may have been 0 when first saved, now passed from Patmed
''               prescriptionID& = GetField(patds!prescriptionID)
''            End If
''         CN$ = GetField(patds!ConsName)
''         DR$ = GetField(patds!TPNreqDate)
''         df$ = GetField(patds!TPNbegDate)
''         CP$ = GetField(patds!infuseCPE)
''         rd$ = GetField(patds!ReqDoctor)
''         feedlength$ = GetField(patds!TPNtotdays)
''         REA$ = GetField(patds!ReasonText)
''         AF$ = GetField(patds!ActiveFact)
''         ifact$ = GetField(patds!InjuryFact)
''         't = z.F10            'CVS(F$(10))        '!!**
''         'nor = Getfield(patds!RegNum)              '!!**
''         'BNT = z.F12          'CVS(F$(12))
''         BatchNumber$ = GetField(patds!BatchNo)
''         OtherFluids = GetField(patds!OtherFluids)
''         regname$ = GetField(patds!ModRegName)
''         lblscombined = GetField(patds!combined)
''         'seplbls$ = IIf(lblscombined, "Y", "N")                          '##
''         BodyTemp$ = Format$(GetField(patds!BodyTemp))
''         infrateamino = GetField(patds!HrsAminoInf)
''         infratefat = GetField(patds!HrsLipidInf)
''         If lblscombined Then
''               overage(1) = tpndef.overagevol(1)
''               overage(2) = tpndef.overagevol(2)
''               overage(3) = GetField(patds!OverageA)
''            Else
''               overage(1) = GetField(patds!OverageA)
''               overage(2) = GetField(patds!OverageF)
''               overage(3) = tpndef.overagevol(3)
''            End If
''
''         If adult(pid.sex) Then                                            '1Sep98 CKJ Added
''               overage(1) = 0                                              '  "
''               overage(2) = 0                                              '  "
''               overage(3) = 0                                              '  "
''            End If                                                         '  "
''
''       '  If nor > 0 Then                                                  '!!**
''       '        If LTrim$(Regname$) = "" Then Regname$ = reg$(nor, 0)      '!!**
''       '     End If                                                        '!!**
''       '  If Asc(ifact$) < 48 Then ifact$ = Str$(Asc(ifact$))              '!!**
''       '  inf = Val(ifact$)                '??                             '!!**
''
'''''         Clin.CardiacFailure = GetField(patds!CardiacFailure)                 '0/-1
'''''         Clin.RenalFailure = GetField(patds!RenalFailure)                     '0/-1
'''''         Clin.Haemodialysis = GetField(patds!Haemodialysis)                   '0/-1
'''''         Clin.PeritonealDialysis = GetField(patds!PeritonealDialysis)         '0/-1
'''''         Clin.Haemofiltration = GetField(patds!Haemofiltration)               '0/-1
'''''         Clin.Septicaemia = GetField(patds!Septicaemia)                       '0/-1
'''''         Clin.FulmHepaticFailure = GetField(patds!FulmHepaticFailure)         '0/-1
'''''         Clin.BiliOver100unconj = GetField(patds!BiliOver100unconj)           '0/-1
'''''         Clin.BiliOver170unconj = GetField(patds!BiliOver170unconj)           '0/-1
'''''         Clin.Phototherapy = GetField(patds!Phototherapy)                     '0/-1
'''''         Clin.RadiantHeat = GetField(patds!RadiantHeat)                       '0/-1
'''''         Clin.Diuretics = GetField(patds!Diuretics)                           '0/-1
'''''         Clin.SerumSodiumCategory = GetField(patds!SerumSodiumCategory)       '0 to 5
'''''         Clin.SerumPotassiumCategory = GetField(patds!SerumPotassiumCategory) '0 to 5
''
''         'Prescription info to be read directly from the dynaset as needed
''
''         If Len(wrn$) Then                                                    '24Sep98 CKJ added
''               popmessagecr ".", "Check and amend this regimen:" & cr & cr & wrn$
''            End If
''
''      Else
'''''         patds.AddNew
'''''         GetPointer patdatapath$ & "\pattpn.dat", ptr&, True
'''''         patds!PatRegID = ptr&
'''''         'For x = 1 To 100                           '14Apr98 CKJ replaced with block below
'''''         '   patds.Fields(x) = 0
'''''         'Next
'''''         For x = 1 To 25                             '14Apr98 CKJ needed because ScriptFe is
'''''            patds.Fields("Prd" & Format$(x)) = 0     'added to the start of the list by the
'''''            patds.Fields("Lnk" & Format$(x)) = ""    'update query
'''''         Next
'''''         patds!PatRecNo = Trim$(pid.recno)           'internal pid.recno
'''''         patds!prescriptionID = prescriptionID&      '03Oct96 CKJ/KR
'''''         patds!isadult = adult(pid.sex)
'''''         patds!LastModDate = Now
'''''         patds!LastModUser = UserID$
'''''         patds!LastModTerm = ASCTerminalName$()                          '13Aug98 CKJ was "Unknown"
'''''         patds!inuse = True
'''''         patds!Authorised = False
'''''         patds!AuthModDate = ""
'''''         patds!AuthModUser = ""
'''''         patds!AuthModTerm = ""
'''''         patds!BatchNo = ""
'''''         patds!PrnWS = False
'''''         patds!PrnRx = False
'''''         patds!PrnIFN = False
'''''         patds!prnlbl = False
'''''         patds!infuseCPE = ""
'''''         patds!combined = lblscombined
'''''         'patds!OverageA = 0                                             '13Aug98 CKJ removed
'''''         'patds!OverageF = 0                                             '   "           "
'''''         patds!OverageA = Iff(lblscombined, overage!(3), overage!(1))    '   "        default
'''''         patds!OverageF = overage!(2)                                    '   "           "
'''''
'''''         '05Jun00 CKJ Block added: preset defaults for infusion rates
'''''         infrateamino = tpndef.infusehrs(Iff(lblscombined, 3, 1))
'''''         infratefat = tpndef.infusehrs(2)
'''''         patds!HrsAminoInf = infrateamino
'''''         patds!HrsLipidInf = infratefat
'''''
'''''         patds!EffWeight = 0
'''''         patds!ConsName = ""
'''''         patds!ReqDoctor = ""
'''''         patds!TPNreqDate = ""
'''''         patds!TPNbegDate = ""
'''''         patds!TPNendDate = ""
'''''         patds!TPNtotdays = ""
'''''         patds!ReasonText = ""
'''''         patds!Notes = ""
'''''         patds!RegNum = 0
'''''         patds!OtherFluids = 0
'''''         patds!OtherLosses = 0
'''''         patds!multiplier = 0
'''''         patds!ActiveFact = 0
'''''         patds!InjuryFact = 0
'''''         patds!ModRegName = ""
'''''         patds!ModNum = 0
'''''
'''''         patds!prescribed = False
'''''         patds!PrescModDate = ""
'''''         patds!PrescModUser = ""
'''''         patds!PrescModTerm = ""
'''''         patds!ScriptVol = "0"
'''''         patds!ScriptN = "0"
'''''         patds!ScriptGlu = "0"
'''''         patds!ScriptFat = "0"
'''''         patds!ScriptNa = "0"
'''''         patds!ScriptK = "0"
'''''         patds!ScriptCa = "0"
'''''         patds!ScriptMg = "0"
'''''         patds!ScriptZn = "0"
'''''         patds!ScriptPO4 = "0"
'''''         patds!ScriptSe = "0"
'''''         patds!ScriptCu = "0"
'''''         patds!ScriptFe = "0"                        '14Apr98 CKJ added
'''''         patds!ScriptAVit = "0"
'''''         patds!ScriptLVit = "0"
'''''
'''''         patds!CardiacFailure = 0
'''''         patds!RenalFailure = 0
'''''         patds!Haemodialysis = 0
'''''         patds!PeritonealDialysis = 0
'''''         patds!Haemofiltration = 0
'''''         patds!Septicaemia = 0
'''''         patds!FulmHepaticFailure = 0
'''''         patds!BiliOver100unconj = 0
'''''         patds!BiliOver170unconj = 0
'''''         patds!Phototherapy = 0
'''''         patds!RadiantHeat = 0
'''''         patds!Diuretics = 0
'''''         patds!SerumSodiumCategory = 0
'''''         patds!SerumPotassiumCategory = 0
'''''
'''''         patds.Update
'''''         patds.MoveLast    'or use patds.Bookmark = patds.LastModified    !!**
''      End If
''
''End Sub

Sub GlucosePercent()
'mixed or separate
'find volume
'ask percent required
'convert to g glucose
'call standard mix routine
'
'05Jun00 CKJ Use defined kcalPerGramGlucose
'25Jul00 CKJ added cautionary phrase when used with combined regimens

'@~@~

Dim s$, ConcOld!, ConcNew!, gGluc!, Vol!, ans$


   s$ = "Glucose concentration of finished " & Iff(lblscombined, "", "aqueous ") & "infusion is "
   calctotals ""
   If lblscombined Then        'combined regimen
         Vol! = tot!(0)        'total volume
         gGluc! = tot!(igGl)   'total g Glucose
      Else                     'separate bags
         Vol! = TotAmino       'aqueous volume
         gGluc! = TotGlucA     'aqueous g Glucose
      End If
   If Vol! > 0 Then
         ConcOld! = gGluc! * 100 / Vol!
         s$ = s$ & Trim$(tsfvdu(ConcOld!)) & "%" & cr
         If lblscombined Then                                                                            '25Jul00 CKJ added
               s$ = s$ & "or higher depending upon the degree of dilution by lipid emulsion." & cr & cr  '   "
            End If                                                                                       '   "
         s$ = s$ & "Enter concentration of glucose required as a percentage (w/v)"
         k.min = 1
         k.Max = 4
         k.decimals = True
         ans$ = Trim$(tsfvdu(ConcOld!))
         InputWin "Percentage of Glucose", s$, ans$, k
         ConcNew! = Val(ans$)
         If ConcNew! > 0 And Abs(ConcNew! - ConcOld!) > 0.001 And Not k.escd Then
               gGluc! = Vol! * (ConcNew! - ConcOld!) / 100       'change in glucose (in grams)
               'mixglucose tot!(0), tot!(igCals) + gGluc! * 4    'pass revised calories   '05Jun00 ckj removed
               mixglucose tot!(0), tot!(igCals) + gGluc! * kcalPerGramGlucose!            '05Jun00 CKJ pass revised calories
            End If
      Else
         s$ = s$ & "unknown" & cr & "Regimen has not been defined"
         popmessagecr "!", s$
      End If
   
End Sub

Function IngredientTotal(Ingredient%) As Single
'01Sep98 CKJ Function added. Allows calculation of a specific ingredient, by passing the
'            ingredient number (1 to 33)

Dim X%, amount!

   amount! = 0
   For X = 0 To NP - 1
      If ig(X) > 0 Then                        'some of this product present
            amount! = amount! + ig(X) * prod(X, Ingredient) / prod(X, IgVol)
         End If
   Next
   IngredientTotal = amount!

End Function

Sub issueregimen(ByVal blnIssue As Boolean, ByRef strOutputMessage As String, ByVal lngSupplyRequestID As Long)
'-----------------------------
' issrtn% = T issue, F return
'18Jan92 CKJ Added mlsperpack array to correct issue qty
' 7Dec92 ASC Added "T" label type to transaction
'14Jul94 CKJ Swapped if statements when returning regimen
' 8Feb95 CKJ Added V6.3 mod of 21Nov94 - spelling of issuing
' 2Aug95 CKJ Combined mods from TPNLABEL:
'            23Aug93 ASC increase dims to 80 for siscodes and mlsperpack
'            22May95 CKJ changed "regimen " to "regimen"
' 1Jul97 CKJ Ported latest DOS version, including;
'            Amended for multiple bags
'            Booking out waste replaces ward with WasteCode
'            Improved checking of illegal states for issuing
'17Aug98 CKJ Dynamically resize mlsperpack() and nsvcodes() as needed
'28Aug98 CKJ Replaced AskWin with MessageBox, with tabbed columns
'            Tidied wording to match
'03Mar99 EAC Hong Kong E7 mods - need to be able to determine when the regimen has been issued
'29Sep99 CFY If in OCX mode, now sets recovery time just before issue.
'05Jun00 CKJ Added NoNegIssues check (#42031)
'            Ask for waste cost centre if TPN.INI WasteCode="?" (Enh1046)
'29Mar12 TH  (TFS 30740) show item as red if un issueable
'08Oct13 TH  Allow stores only issue (TFS 75413)
'
'
'-----------------------------

'12Feb96 CKJ moved nsvcodes() to module level
Dim s$, issret$, issreting$, issgn As Integer, ans$, isserr%, X%, found%, issqty!, dircode$, UnitCost$      '01Jun02 All/CKJ added as integer to issgn
Dim IssueToWaste%, pname$, numused!, waste!, WasteCode$, wholepacks%, qtydesc$, msg$
Dim buttons%
Dim CannotIssue As Integer                                  '05Jun00 CKJ Added
Dim suptemp As supplierstruct                               '   "
'ReDim mlsperpack(80) As Single                             '17Aug98 CKJ removed
ReDim mlsperpack(0 To NP - 1) As Single                     '            dynamically resize
Dim strIssueDesc As String
Dim strIssueQty As String
Dim strIssueUnit As String
Dim intFirstEmpty As Integer
Dim intloop As Integer
Dim strInfo As String
Dim strSummary As String
Dim strWasteQty As String
Dim strStock As String
Dim blnAllowIssueEdit
Dim lngFound As Long
Dim strDesc As String
Dim StrOverage As String
Dim strBatch As String
Dim strPatname As String
Dim dat$
Dim strAge As String
Dim valid As Integer
Dim blnAllow As Boolean
Dim strAns As String
Dim strIssueWarnings As String
Dim blnDrugAddedtoWarnings As Boolean
Dim strDrugDesc As String
Dim blnCannotIssueProduct As Boolean '29Mar12 TH  (TFS 30740)


   'New Checks from settings TFS 28622
   CannotIssue = False
   strIssueWarnings = ""
   blnAllow = TrueFalse(TxtD$(dispdata$ & "\PN.INI", Iff(adult(""), "AdultDefault", "PaedDefault"), "Y", Iff(blnIssue, "Issue", "Return") & "Enabled", 0))
   
   If Not blnAllow Then
      'popmessagecr "", "System is not set up to allow " & Iff(adult(), "Adult", "Paedeatric") & " PN " & Iff(blnIssue, "Issuing", "Returning")
      strOutputMessage = "System is not set up to allow " & Iff(adult(""), "Adult", "Paediatric") & " PN " & Iff(blnIssue, "Issuing", "Returning")
      CannotIssue = True
   End If
   
   'Now we will do the status checks
''   If g_blnPNStatusComplete Then 'Supply request completed
''      strOutputMessage = "System is not set up to allow " & Iff(adult(""), "Adult", "Paediatric") & " PN " & Iff(blnIssue, "Issuing", "Returning")
''      CannotIssue = True
''   ElseIf g_blnPNStatusIssued Then
''      'ASk if the wish to Issue Again
''   End If
   If g_blnPNStatusIssued And blnIssue Then
       strAns = "N"
      strDesc = "This supply request has been previously issued. Are you sure you wish to issue again ? "
      strDesc = TxtD$(dispdata$ & "\PN.INI", "", strDesc, "IssueAgainQuestion", 0)
      'askwin "CIVAS Product", strDesc, strAns, k
      askwin "Parenteral Nutrition", strDesc, strAns, k  '05Mar12 TH Changed title
      If k.escd Or strAns = "N" Then
         CannotIssue = True
         strOutputMessage = "PN batch : " & Trim$(batchnumber$) & Iff(blnIssue, " issue", " return") & " aborted."
      End If
   ElseIf (Not g_blnPNStatusIssued) And (Not blnIssue) Then
      'Return but no issue
      strAns = "N"
      If TrueFalse(TxtD$(dispdata$ & "\PN.INI", "", strDesc, "AskIssueWithoutReturnQuestion", 0)) Then
         strDesc = "This supply request has not been previously issued. Are you sure you wish to return  ? "
         strDesc = TxtD$(dispdata$ & "\PN.INI", "", strDesc, "IssueWithoutReturnQuestion", 0)
         askwin "Parenteral Nutrition", strDesc, strAns, k  '05Mar12 TH Changed title
      Else
         strDesc = "This supply request has not been previously issued. You cannot return this batch. "
         strDesc = TxtD$(dispdata$ & "\PN.INI", "", strDesc, "IssueWithoutReturnMsg", 0)
         popmessagecr "Parenteral Nutrition", strDesc
      End If
      If k.escd Or strAns = "N" Then
         CannotIssue = True
         strOutputMessage = "PN batch : " & Trim$(batchnumber$) & Iff(blnIssue, " issue", " return") & " aborted."
      End If
   End If
   
   If Not CannotIssue Then
      k.escd = False
      ReDim nsvcodes(0 To NP - 1) As String                    '            dynamically resize
      
      '''CalcOverage
      IssueToWaste = TrueFalse((tpnini$("IssueToWaste", "0")))     'T/F
      WasteCode$ = tpnini$("WasteCode", "----")
      
      'blnAllowIssueEdit = TrueFalse((tpnini$("EditIssue", "0") <> "0"))
      blnAllowIssueEdit = TrueFalse(TxtD$(dispdata$ & "\PN.INI", "", "Y", "EditIssue", 0))
      
      If IssueToWaste And WasteCode$ = "?" Then                '05Jun00 CKJ Added block
         asksupplier WasteCode$, 0, "SW", "Select cost centre for issuing to waste", False, suptemp, False '15Nov12 TH Added PSO param
         If WasteCode$ = "" Then msg$ = "No cost centre selected for issuing of waste products"
      End If
   
      'issrtn = (issrtn <> False)   ' reduce to boolean
      If blnIssue Then
         issret$ = "Issue"
         issreting$ = "Issuing"              '8Feb95 CKJ
         issgn = 1
      Else
         issret$ = "Return"
         issreting$ = "Returning"            '8Feb95 CKJ
         issgn = -1
      End If
   
      ''If Not fileexists(dispdata$ & "\prodinfo.v8") Then msg$ = "Departmental Stock File does not exist" '16Jul97 made v8
      'TO DO ? If blnIssue = True And Not tpndef.issueenabled Then msg$ = issret$ & " is not enabled in PN Configuration"
      'TO DO ? If blnIssue = False And Not tpndef.returnenabled Then msg$ = issret$ & " is not enabled in PN Configuration"
      
      If msg$ <> "" Then
         popmessagecr "." & issret$ & " Regimen", "Cannot " & issret$ & " regimen:" & cr & cr & msg$  '16Feb98 CKJ Added Stop icon
         k.escd = True
         Exit Sub
      End If
   
   ''   If blnIssue = False Then                    'return
   ''      ans$ = Trim$(batchnumber$)     '18Aug95 CKJ removed + RIGHT$("000" + LTRIM$(STR$(BNT)), 3)
   ''      s$ = tp("Batchret") & Space$(25) & "T" & ans$  '"   Which Batch number is to be returned?"
   ''      k.Max = 8 'ASC 22Aug93 was 4
   ''      k.min = 1
   ''      k.nums = True
   ''      'k.helpnum = 380
   ''      inputwin issret$, s$, ans$, k
   ''      If Not k.escd And Len(RTrim$(ans$)) = 0 Then
   ''         popmessagecr "", tp("Batchrec") & cr    '"   Batch number will not be recorded"
   ''      Else
   ''         batchnumber$ = UCase$(ans$)   '18Aug95 CKJ added
   ''      End If
   ''   End If
   
      isserr = False
      s$ = issret$ & " PN Regimen:" & Space$(12) & TB & " Quantity   " & TB & "Information" & Space$(50) & cr & cr
      
      For X = 0 To NP - 1      ' scan products
         blnDrugAddedtoWarnings = False
         blnCannotIssueProduct = False '29Mar12 TH  (TFS 30740)
         strIssueUnit = ""
         strIssueQty = ""
         strInfo = ""
         strWasteQty = ""
         strStock = ""
         strDrugDesc = ""
         wholepacks = False
         If Prd(X).SharePacks = 0 Then 'don't share containers, use whole ones
            wholepacks = True
         End If
   
         mlsperpack(X) = 0
         '' All used If ig(X) > 0 Then     ' used
               pname$ = " " & pad(Prd(X).name, 30)
         If Len(RTrim$(Prd(X).linkcode)) < 4 Then  'was18
            's$ = s$ & pname$ & "  - Cannot " & issret$ & " - there is no ASC code or NSV code." & cr
            s$ = s$ & pname$ & TB & "- Cannot " & issret$ & " - there is no ASC code or NSV code." & cr
            strIssueWarnings = strIssueWarnings & pname$ & TB & "- Cannot " & issret$ & " - there is no ASC code or NSV code."
            blnDrugAddedtoWarnings = True
            strIssueDesc = pname$ & TB & "- Cannot " & issret$ & " - there is no ASC code or NSV code."
            strInfo = "- Cannot " & issret$ & " - there is no ASC code or NSV code."
            isserr = True
         Else
            If wholepacks Then  '1Jul97 CKJ Block added
               'qtydesc$ = Str$(Numberofbags) & " x" & Str$(igover!(x)) '3 x 400ml
               'qtydesc$ = Str$(m_intNumberofbags) & " x " & tsf$(igover!(X)) '3 x 400ml  28Aug98 CKJ
               qtydesc$ = Str$(m_intNumberofbags) & " x " & igover!(X) '18Mar12 TH Removed tsf
            Else
               'qtydesc$ = Str$(Numberofbags * igover!(x))              '1200ml
               qtydesc$ = tsf$(m_intNumberofbags * igover!(X))               '1200ml     28Aug98 CKJ
            End If
            'findrdrug Trim$(Prd(X).linkcode) & Chr$(127) & Prd(X).name & "   " & qtydesc$ & " ml", False, d, 0, found, 2, 0, True '17Jan12 TH Added param '22Mar12 th Added gap (TFS 29815)
            findrdrug Trim$(Prd(X).linkcode) & Chr$(127) & Prd(X).name & "   " & qtydesc$ & " ml", True, d, 0, found, 2, 0, True '08Oct13 TH Allow stores only issue (TFS 75413)
            If k.escd Then Exit For                                        '28Aug98 CKJ Added
   
            If found Then
               If Left$(d.LabelDescription, 3) <> "***" Then      'If Left$(d.Description, 3) <> "***" Then  XN 4Jun15 98073 New local stores description
                  If d.mlsperpack > 0 Then                           '25Sep98 CKJ Added check
                     issqty! = igover(X)                          '1Jul97 CKJ was ig()
                     mlsperpack(X) = d.mlsperpack
                     If d.mlsperpack > 0 Then issqty! = issqty! / d.mlsperpack
   
                     issqty! = issqty! * m_intNumberofbags             '1Jul97 CKJ Added
                     
                     'Get the wastage qty now for the form
                     'If IssueToWaste And blnIssue Then       'issue only, not returns
                     If IssueToWaste Then       '27Nov12 TH Now allow the return of waste back to the waste cost centre (TFS 50021)
                        numused! = igover!(X)     'mls including overage
                        If mlsperpack(X) > 0 Then numused! = numused! / mlsperpack(X)  ' ml used / ml per issue unit
                        
                        If Not wholepacks Then numused! = numused! * m_intNumberofbags
                        If numused! > Int(numused!) Then
                           numused! = Int(numused!) + 1   'round up to next whole pack
                        End If
                        If wholepacks Then numused! = numused! * m_intNumberofbags
                              
                        waste! = numused! - issqty!
                        If waste! > 0.001 Then
                           If waste! = Int(waste!) Then
                              strWasteQty = Format$(waste!, "#,##0    ")
                           Else
                              strWasteQty = Format$(waste!, "#,##0.0##")
                           End If
                        Else
                           strWasteQty = "0"
                        End If
                     Else
                        '28Nov12 TH Enhancement for issue in whole packs (TFS 29023)
                        If (UCase$(d.issueWholePack) = "Y") Then
                           If issqty! > 0.000001 Then
                              issqty! = Fix(issqty!) + 1
                           Else
                              issqty! = CInt(issqty!)
                           End If
                        End If
                        '28Nov12 TH End -----
                     End If
                     
                     
                     s$ = s$ & pname$ & TB
                     strIssueDesc = pname$
                     'If Trim$(d.storesdescription) <> "" Then
                        'strInfo = d.storesdescription
                     'Else
                        'strInfo = d.Description
                     'End If XN 4Jun15 98073 New local stores description
                                         strInfo = d.DrugDescription
                     strStock = d.stocklvl
                     plingparse strInfo, "!"
                     strInfo = Trim$(strInfo) & " "
                     
                     strDrugDesc = strInfo
                     
                     If issqty! = Int(issqty!) Then
                        s$ = s$ & Format$(issqty!, "#,##0    ")
                        strIssueQty = Format$(issqty!, "#,##0    ")
                     Else
                        s$ = s$ & Format$(issqty!, "#,##0.0##")
                        strIssueQty = Format$(issqty!, "#,##0.0##")
                     End If
                     s$ = s$ & " " & LCase$(d.PrintformV) & TB
                     strIssueUnit = LCase$(d.PrintformV)
                     nsvcodes(X) = d.SisCode
                     If issqty! > Val(d.maxissue) Then
                        s$ = s$ & tp("Qtymax")
                        strInfo = strInfo & tp("Qtymax")
                        If blnDrugAddedtoWarnings Then
                           strIssueWarnings = strIssueWarnings & " " & tp("Qtymax")
                        Else
                           blnDrugAddedtoWarnings = True
                           strIssueWarnings = strIssueWarnings & strDrugDesc & " " & tp("Qtymax")
                        End If
                     End If
                     If issqty! < Val(d.minissue) Then
                        s$ = s$ & tp("Qtymin")
                        strInfo = strInfo & tp("Qtymin")
                        If blnDrugAddedtoWarnings Then
                           strIssueWarnings = strIssueWarnings & " " & tp("Qtymin")
                        Else
                           blnDrugAddedtoWarnings = True
                           strIssueWarnings = strIssueWarnings & pname$ & " - " & strDrugDesc & " " & tp("Qtymin")
                        End If
                     End If
                     If d.livestockctrl = "Y" Then
                        s$ = s$ & tp("live")
                        strInfo = strInfo & tp("live")
                        If Val(d.stocklvl) - issqty! < 0 And blnIssue Then
                           If TrueFalse(TxtD$(dispdata$ & "\PATMED.INI", "", "N", "NoNegIssues", 0)) Then  '05Jun00 CKJ Added check
                              s$ = s$ & cr & "     Issue not allowed: stock level would be below zero"  '   "
                              strInfo = strInfo & " Issue not allowed: stock level would be below zero"
                              If blnDrugAddedtoWarnings Then
                                 strIssueWarnings = strIssueWarnings & " Issue not allowed: stock level would be below zero"
                              Else
                                 strIssueWarnings = strIssueWarnings & pname$ & " - " & strDrugDesc & " Issue not allowed: stock level would be below zero"
                              End If
                              CannotIssue = True                                                        '   "
                              blnCannotIssueProduct = True '29Mar12 TH  (TFS 30740)
                           Else
                              s$ = s$ & cr & "     " & tp("insulst") '"  - DO NOT ISSUE before finding stock! (Insufficient stock for LIVE item)"
                              strInfo = strInfo & " " & tp("insulst")
                              strIssueWarnings = strIssueWarnings & strInfo
                              If blnDrugAddedtoWarnings Then
                                 strIssueWarnings = strIssueWarnings & " " & tp("insulst")
                              Else
                                 strIssueWarnings = strIssueWarnings & pname$ & " - " & strDrugDesc & " " & tp("insulst")
                              End If
                           End If
                           blnDrugAddedtoWarnings = True
                        End If
                     End If
                     s$ = s$ & cr
                     If d.mlsperpack <= 0 Then
                        s$ = s$ & tp("Nosml") & cr '" - Number of ml per pack not defined; assumed issue unit is 1 ml."
                        strInfo = strInfo & " " & tp("Nosml")
                        If blnDrugAddedtoWarnings Then
                           strIssueWarnings = strIssueWarnings & " " & tp("Nosml")
                        Else
                           blnDrugAddedtoWarnings = True
                           strIssueWarnings = strIssueWarnings & strDrugDesc & " " & tp("Nosml")
                        End If
                     End If
                     
                  Else                                            '25Sep98 CKJ Added check
                     s$ = s$ & pname$ & d.SisCode & " - Number of ml per pack not defined (Dispensing pack size)" & cr
                     isserr = True                                '05Jun00 CKJ added
                     strInfo = d.SisCode & " - Number of ml per pack not defined (Dispensing pack size)"
                     If blnDrugAddedtoWarnings Then
                        strIssueWarnings = strIssueWarnings & " - " & d.SisCode & " - Number of ml per pack not defined (Dispensing pack size)"
                     Else
                        blnDrugAddedtoWarnings = True
                        strIssueWarnings = strIssueWarnings & pname$ & " " & strDrugDesc & " - " & d.SisCode & " - Number of ml per pack not defined (Dispensing pack size)"
                     End If
                     
                  End If
               Else
                  s$ = s$ & pname$ & d.SisCode & tp("Curruse") & cr '" is not for current usage"
                  strInfo = d.SisCode & tp("Curruse")
                  isserr = True
                  If blnDrugAddedtoWarnings Then
                     strIssueWarnings = strIssueWarnings & " - " & d.SisCode & tp("Curruse")
                  Else
                     blnDrugAddedtoWarnings = True
                     strIssueWarnings = strIssueWarnings & strDrugDesc & "- " & d.SisCode & tp("Curruse")
                  End If
               End If
            Else
               's$ = s$ & pname$ & tp("Notfound") & cr       '" Not found"
               s$ = s$ & pname$ & TB & tp("Notfound") & cr   '" Not found"
               strInfo = tp("Notfound")
               isserr = True
               If blnDrugAddedtoWarnings Then
                  strIssueWarnings = strIssueWarnings & TB & tp("Notfound")
               Else
                  blnDrugAddedtoWarnings = True
                  strIssueWarnings = strIssueWarnings & pname$ & TB & tp("Notfound")
               End If
            End If
         End If
         If blnDrugAddedtoWarnings Then strIssueWarnings = strIssueWarnings & cr
         '' All used    End If
         If blnAllowIssueEdit Then
            frmPNIssue.lblDescription(X).Caption = pname$
            frmPNIssue.lblUnits(X).Caption = strIssueUnit
            frmPNIssue.txtQty(X).text = strIssueQty
            If Len(strInfo) > Val(TxtD$(dispdata$ & "\PN.INI", "", "100", "PNIssueScreenMaxinfoLengthinChars", 0)) Then
               frmPNIssue.lblInfo(X).Caption = Trim$(strDrugDesc) & " - " & TxtD$(dispdata$ & "\PN.INI", "", "Warnings ! Use view button to see full warnings", "PNIssueScreenLargeWarningText", 0)
            Else
               frmPNIssue.lblInfo(X).Caption = strInfo
            End If
            frmPNIssue.txtWaste(X).text = strWasteQty
            frmPNIssue.lblStock(X).Caption = strStock
            If Trim$(strIssueUnit) = "" Then '01Mar12 TH Use this as a marker for no match - here we are not issuing /returning so lets hide the boxes
               frmPNIssue.txtQty(X).Visible = False
               frmPNIssue.txtWaste(X).Visible = False
            End If
            If Not blnIssue Then
               frmPNIssue.lblDescription(X).ForeColor = Red
            Else
               frmPNIssue.lblDescription(X).ForeColor = Black
            End If
            If blnIssue And blnCannotIssueProduct Then  '29Mar12 TH (TFS 30740)
               frmPNIssue.lblInfo(X).ForeColor = Red
            Else
               frmPNIssue.lblInfo(X).ForeColor = Black
            End If
            If IssueToWaste And blnIssue Then
            
            End If
            If Trim$(strIssueWarnings) <> "" Then
               frmPNIssue.lblAllWarnings.Caption = strIssueWarnings
               frmPNIssue.cmdWarnings.Enabled = True
            Else
               frmPNIssue.cmdWarnings.Enabled = False
            End If
         End If
      Next
      
      If blnAllowIssueEdit Then
         'New labels 05Mar12 TH
         buildname pid, 0, strPatname
         frmPNIssue.lblPatientName.Caption = strPatname
         
         parsedate pid.dob, dat$, "1", valid                        '     "
         If valid Then
            datetodays dat$, "", 0, 0, strAge, 0
            frmPNIssue.lblAge.Caption = strAge
            frmPNIssue.lblDOB.Caption = dat$
         Else
            frmPNIssue.lblAge.Caption = "UNKNOWN"
            frmPNIssue.lblDOB.Caption = "UNKNOWN"
         End If
         If Val(pid.weight) = 0 Then
            frmPNIssue.lblWeight.Caption = TxtD(dispdata$ & "\pn.ini", "", "unknown", "UnknownWeight", 0)
         Else
            frmPNIssue.lblWeight.Caption = Trim$(Format$(pid.weight)) & " kg"
         End If
         frmPNIssue.lblCaseno.Caption = pid.caseno
         frmPNIssue.lblNHS.Caption = (OCXheap("HealthCareNumber", "")) 'pidExtra.NHnumber
         frmPNIssue.lblNHSdesc.Caption = GetNHSNumberDisplayName()
      End If
      
      'If Not adult(pid.sex) Then  '26Mar12 TH  Removed - Overage now shown on any regimen (TFS)
         '25Sep98 CKJ replaced text with fixed version which matches on-screen summary
         's$ = s$ & cr & tp("Overage")
         'If lblscombined Then
         '      s$ = s$ & " " & overage(3) & " " & tp("ml.") & cr
         '   Else
         '      s$ = s$ & " " & overage(1) & " " & tp("mlamino") & " " & overage(2) & " " & tp("mlfat") & cr
         '   End If
         's$ = s$ & "Overage: "
         s$ = s$ & crlf & "Overage: "
         'strSummary = "Overage: "
         'StrOverage = "Overage: "
         If lblscombined Then
            s$ = s$ & Format$(overage(3)) & " ml (Combined)"
            'strSummary = strSummary & Format$(overage(3)) & " ml (Combined)"
            'StrOverage = strSummary & Format$(overage(3)) & " ml (Combined)"
            StrOverage = Format$(overage(3)) & " ml (Combined)"
         Else
            s$ = s$ & "aqueous " & Format$(overage(1)) & " ml, lipid " & Format$(overage(2)) & " ml"
            'strSummary = strSummary & "aqueous " & Format$(overage(1)) & " ml, lipid " & Format$(overage(2)) & " ml"
            'StrOverage = strSummary & "aqueous " & Format$(overage(1)) & " ml, lipid " & Format$(overage(2)) & " ml"
            StrOverage = "aqueous " & Format$(overage(1)) & " ml, lipid " & Format$(overage(2)) & " ml"
         End If
      'End If
      If blnAllowIssueEdit Then
         'New labels 05Mar12 TH
         frmPNIssue.lblOverage.Caption = StrOverage
      End If
      ''Batch = BNT     <TPNLABEL>
      ''IF LEN(Trim$(Batchnuber$)) > 0 THEN
      ''      printwcr tp("Nobatch")
      ''      isserr = true
      ''   ELSE
      ''      printw tp("Currbat") + BatchNumber$    '!'
      ''      'PRINT trim$(STR$(bnt))
      ''   END IF
   
      If Len(Trim$(batchnumber$)) Then  '14Jul94 CKJ Swapped if statements
         s$ = s$ & tp("Currbat") & Trim$(batchnumber$)    '" Current Batch number is T"  18Aug95 CKJ removed + RIGHT$("000" + LTRIM$(STR$(BNT)), 3)
         'strSummary = strSummary & tp("Currbat") & Trim$(batchnumber$)
         strBatch = Trim$(batchnumber$)
     Else
         s$ = s$ & tp("Nobatch")                          '" No batch number has been allocated (worksheet not printed)"
         'strSummary = strSummary & tp("Nobatch")
         'strBatch = strSummary & tp("Nobatch")
         strBatch = tp("Nobatch")
         isserr = True
      End If
      If blnAllowIssueEdit Then
         'New labels 05Mar12 TH
         frmPNIssue.lblBatch.Caption = strBatch
         frmPNIssue.lblBags.Caption = Format$(m_intNumberofbags)
         CannotIssue = False 'Allow edit here and we can catch later if required.
      End If
      '05Mar12 TH Add the bags here !!!!
      
   
      'which batch no to return Q moved above
   
      If Not k.escd Then
         s$ = s$ & cr & cr
         'strSummary = strSummary & cr & cr
         
         
         If Trim$(strSummary) <> "" Then strSummary = strSummary & cr
         If CannotIssue Then                                                            '05Jun00 CKJ Added
            s$ = s$ & "Cannot issue because stock level would become negative." & cr '   "
            strSummary = strSummary & "Cannot issue because stock level would become negative."
            If Not blnAllowIssueEdit Then buttons = MB_OK + MB_ICONSTOP                                            '   "
         ElseIf isserr Then
            s$ = s$ & tp("Wish") & LCase$(issret$) & tp("Inspite") & "?" & cr   'printw "   Do you wish to " + LCASE$(issret$) + " the regimen, in spite of the errors ?   "
            strSummary = strSummary & tp("Wish") & LCase$(issret$) & tp("Inspite") & "?"
            If Not blnAllowIssueEdit Then buttons = MB_YESNO + MB_ICONEXCLAMATION + MB_DEFBUTTON2
         Else
            s$ = s$ & tp("OKto") & " " & LCase$(issret$) & tp("regimen") & cr   '22May95 CKJ removed space  'printw "   OK to " + LCASE$(issret$) + " the regimen   "
            strSummary = strSummary & tp("OKto") & " " & LCase$(issret$) & tp("regimen") & cr
            If Not blnAllowIssueEdit Then buttons = MB_YESNO + MB_ICONQUESTION
         End If
         ans$ = ""
         'k.helpnum = 385
         
         'askwin issret$, s$, ans$, k                                              '29Aug98 CKJ replaced ...
         'If messagebox(s$, buttons, "ASCribe") = IDYES Then                       '29Aug98 CKJ .. with this
         If blnAllowIssueEdit Then
            'Set up form
            'Pick up first empty element
            For intloop = 0 To 19
               If Trim$(frmPNIssue.lblDescription.Item(intloop).Caption) = "" Then
                  intFirstEmpty = intloop
                  Exit For
               End If
            Next
            
            'If IssueToWaste And blnIssue Then frmPNIssue.Tag = "WASTE"
            If IssueToWaste Then frmPNIssue.Tag = "WASTE" '27Nov12 TH Now allow the return of waste back to the waste cost centre (TFS 50021)
            
            For intloop = intFirstEmpty To 19
               frmPNIssue.lblDescription.Item(intloop).Visible = False
               frmPNIssue.lblUnits.Item(intloop).Visible = False
               frmPNIssue.txtQty.Item(intloop).Visible = False
               frmPNIssue.lblInfo.Item(intloop).Visible = False
               frmPNIssue.txtWaste.Item(intloop).Visible = False
               frmPNIssue.lblStock.Item(intloop).Visible = False
            Next
            'Size
         ''   frmPNIssue.cmdOK.Top = 10600 - ((20 - (intFirstEmpty + 1)) * 400)
         ''   frmPNIssue.cmdCancel.Top = 10600 - ((20 - (intFirstEmpty + 1)) * 400)
         ''   frmPNIssue.Height = 12000 - ((20 - (intFirstEmpty + 1)) * 400)
         ''   frmPNIssue.lblSummary.Top = 9400 - ((20 - (intFirstEmpty + 1)) * 400)
            'frmPNIssue.cmdOK.Top = 11600 - ((20 - (intFirstEmpty + 1)) * 400)
            'frmPNIssue.cmdCancel.Top = 11600 - ((20 - (intFirstEmpty + 1)) * 400)
            'frmPNIssue.cmdLog.Top = 11600 - ((20 - (intFirstEmpty + 1)) * 400)   '18Mar12 TH Added (TFS28928)
            'frmPNIssue.cmdWarnings.Top = 11600 - ((20 - (intFirstEmpty + 1)) * 400)   '18Mar12 TH Added (TFS28928)
            frmPNIssue.cmdOK.Top = 10600 - ((20 - (intFirstEmpty + 1)) * 400)
            frmPNIssue.cmdCancel.Top = 10600 - ((20 - (intFirstEmpty + 1)) * 400)
            frmPNIssue.cmdLog.Top = 10600 - ((20 - (intFirstEmpty + 1)) * 400)   '18Mar12 TH Added (TFS28928)
            frmPNIssue.cmdWarnings.Top = 10600 - ((20 - (intFirstEmpty + 1)) * 400)
            'frmPNIssue.Height = 12000 - ((20 - (intFirstEmpty + 1)) * 400)
            frmPNIssue.Height = 11700 - ((20 - (intFirstEmpty + 1)) * 400)
            'frmPNIssue.lblSummary.Top = 10400 - ((20 - (intFirstEmpty + 1)) * 400)
            'frmPNIssue.lblSummary.Top = 11600 - ((20 - (intFirstEmpty + 1)) * 400)
            frmPNIssue.lblSummary.Top = 10600 - ((20 - (intFirstEmpty + 1)) * 400)
            'final bits
            If blnIssue Then
               frmPNIssue.LBLQty.Caption = "Issue Qty"
            Else
               frmPNIssue.LBLQty.Caption = "Return Qty"
            End If
            frmPNIssue.lblSummary.Caption = strSummary
            frmPNIssue.lblRegimen = strRegimenDescription
            frmPNIssue.Caption = "Parenteral Nutrition " & issret$
            frmPNIssue.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
            'Are we going ahead ?
            ans$ = "Y" 'Debug
            ans$ = frmPNIssue.Tag
         Else
            If MessageBox(s$, buttons, "EMIS Health") = IDYES Then                        '29Aug98 CKJ .. with this
               ans$ = "Y"
               k.escd = False
            Else
               ans$ = "N"
               k.escd = True
            End If
         End If
      End If
      
      
   
      'If lblscombined Then
      '      calcoverage (Overage(3)), 3
      '   Else
      '      calcoverage (Overage(1)), 1
      '      If Not k.escd Then calcoverage (Overage(2)), 2
      '   End If
      
      
      strInfo = ""
      If ans$ = "Y" And Not k.escd Then
         'OK if we are entering issue values then we need to double check on neg stock !
         strInfo = ""
         If blnAllowIssueEdit And blnIssue Then
            For X = 0 To NP - 1      ' scan products
               If nsvcodes(X) <> "" Then
                  d.SisCode = nsvcodes(X)
                  getdrug d, 0, lngFound, False
                  If lngFound > 0 Then
                     If d.livestockctrl = "Y" Then
                        If Val(d.stocklvl) - Val(frmPNIssue.txtQty(X).text) < 0 Then
                           If TrueFalse(TxtD$(dispdata$ & "\PATMED.INI", "", "N", "NoNegIssues", 0)) Then  '05Jun00 CKJ Added check
                              'strDesc = d.storesdescription
                              'If Trim$(strDesc) = "" Then strDesc = d.Description XN 4Jun15 98073 New local stores description
                                                          strDesc = d.DrugDescription
                              plingparse strDesc, "!"
                              strInfo = strInfo & Trim$(strDesc) & "(" & d.SisCode & "): Issue not allowed: stock level would be below zero" & crlf
                              CannotIssue = True                                                        '   "
                           End If
                        End If
                     End If
                  End If
               
               End If
            Next
         End If
      End If
      
      If strInfo <> "" Then popmessagecr "!Issue not allowed", strInfo
   
      If ans$ = "Y" And Not k.escd And Not CannotIssue Then
         Screen.MousePointer = HOURGLASS
         dircode$ = ""
         If Len(Trim$(batchnumber$)) Then dircode$ = ":T" & Trim$(batchnumber$) '18Aug95 CKJ removed + RIGHT$("000" + LTRIM$(STR$(BNT)), 3) 'ASC 22Aug93 was BNT
         gCIVASdos$ = Format$(m_intNumberofbags) '14Mar12 TH TFS 29155
         For X = 0 To NP - 1      ' scan products
            If nsvcodes(X) <> "" Then
               wholepacks = False
               If Prd(X).SharePacks = 0 Then 'don't share containers, use whole ones
                  wholepacks = True
               End If
               setbatchnum Trim$(batchnumber$)  '21Feb12 TH seeing as we have a batchnumber in the log why dont we store the batchnumber there ????
               d.SisCode = nsvcodes(X)
               issqty! = igover!(X) * issgn * m_intNumberofbags  '1Jul97 CKJ Added Numberofbags
               If mlsperpack(X) > 0 Then issqty! = issqty! / mlsperpack(X)
               
               'OK overwrite here the issue qty if we are using the new screen
               If blnAllowIssueEdit Then
                  issqty! = Val(frmPNIssue.txtQty(X).text) * issgn
               End If
               
               If issqty! <> 0 Then
                  Translog d, 0, UserID$, pid.recno, issqty!, dircode$, pid.ward, pid.cons, pid.status, SiteNumber, "T", UnitCost$  'ASC 7Dec92 "T" label type added  ASC 26May93 Unitcost added '21Mar94 CKJ pid.caseno=>pid.RecNo
               End If
               'If IssueToWaste And blnIssue Then       'issue only, not returns
               If IssueToWaste Then       'issue only, not returns
                  numused! = igover!(X)     'mls including overage
                  If mlsperpack(X) > 0 Then numused! = numused! / mlsperpack(X)  ' ml used / ml per issue unit
                  
                  If Not wholepacks Then numused! = numused! * m_intNumberofbags
                  If numused! > Int(numused!) Then
                     numused! = Int(numused!) + 1   'round up to next whole pack
                  End If
                  If wholepacks Then numused! = numused! * m_intNumberofbags
                        
                  waste! = numused! - issqty!
                  If blnAllowIssueEdit Then
                     waste! = Val(frmPNIssue.txtWaste(X).text)
                  End If
                  If waste! > 0.001 Then       'at least 1/1000 of a pack so issue it
                     If Not blnIssue Then waste! = waste! * -1  '27Nov12 TH Now allow the return of waste back to the waste cost centre (TFS 50021)
                     Translog d, 0, UserID$, pid.recno, waste!, dircode$, WasteCode$, pid.cons, pid.status, SiteNumber, "T", UnitCost$  'ASC 7Dec92 "T" label type added  ASC 26May93 Unitcost added
                  End If
                  'If PRD(x).SharePacks = 0 Then   'don't share containers, use whole ones
                  '      d.siscode = nsvcodes(x)
                  '      getdrug d, 0, found, False
                  '
                  '      If d.mlsperpack > 0 Then mlppk! = d.mlsperpack Else mlppk! = 1
                  '      numused! = igover!(x) / mlppk!       ' ml used / ml per issue unit
                  '      If numused! > Int(numused!) Then
                  '            waste! = Int(numused!) + 1 - numused!
                  '
                  '            Translog d, 0, userid$, pid.recno, waste!, dircode$, pid.ward, pid.cons, pid.Status, sitenumber, "T", unitcost$  'ASC 7Dec92 "T" label type added  ASC 26May93 Unitcost added
                  '         End If
                  '   End If
               End If
               setbatchnum "" '21Feb12 TH clear
             End If
         Next
         gCIVASdos$ = ""  '14Mar12 TH
         Screen.MousePointer = STDCURSOR
         ''If OCXLaunch() Then SetOCXStatus STATUS_ISSUE         '03Mar99 EAC Added
         strOutputMessage = "PN batch : " & Trim$(batchnumber$) & Iff(blnIssue, " issued.", " returned.")
         If Not blnIssue Then
            'OK now we ask if th user wishes to reset the status to allow issuing as if for the first time.
            'No Just Do it
            DisableAttachNoteLinkedtoRequest "PNIssued", lngSupplyRequestID
         Else
            If Not g_blnPNStatusIssued Then
               'OK Now lets write the attached note/status change
               PNAttachnote "PNIssued", lngSupplyRequestID, "PN Issued"
            
            End If
            
         End If
         
      Else
         strOutputMessage = "PN batch : " & Trim$(batchnumber$) & Iff(blnIssue, " issue", " return") & " aborted."
         
      End If
      If blnAllowIssueEdit Then Unload frmPNIssue
   End If
   strPNOutputMessage = strOutputMessage
   k.escd = False
   
   

End Sub

Function LastPrd(PIE%) As Integer
'Given PEI as follows
' 1 Parenteral
' 2 Concurrent Infusion
' 3 Enteral
'Returns the last entry in ig() and PRD() for that product type

   Select Case PIE
      Case 1: LastPrd = NP - 1
''      Case 2: LastPrd = -1
''      Case 3: LastPrd = -NPi - 1
      End Select

End Function

Sub LimitToMaxDose(X%, warning$)
'27Aug98 CKJ Moved from in-line code in MenuPrescription
'            x is the product number in range 0 to NP-1
'            warning is a string for display, with cr terminated lines
'            If the dose of ig(x) exceeds either maxmltotal or maxmlperkg then the product is
'            reduced to that maximum.
'            Uses shared vars NP (number of products) and weight! which can be zero
'
Dim MaxDose!

   Select Case X
      Case 0 To NP - 1
         MaxDose! = Prd(X).maxmltotal
         If MaxDose! > 0 And ig(X) > MaxDose! Then
               warning$ = warning$ & Prd(X).name & ": dose reduced from " & Format$(ig(X)) & " ml to maximum of " & Format$(MaxDose!) & " ml" & cr
               ig(X) = MaxDose!
            End If
      
         MaxDose! = Prd(X).maxmlperkg
         If MaxDose! > 0 And weight! > 0 Then
               If ig(X) / weight! > MaxDose! Then
                     warning$ = warning$ & Prd(X).name & ": dose reduced from " & Format$(ig(X) / weight!) & " ml per kg to maximum of " & Format$(MaxDose!) & " ml per kg" & cr
                     ig(X) = MaxDose! * weight!
                  End If
            End If
      Case Else
         warning$ = warning$ & "Program Error: LimitToMaxDose called with invalid product number:" & Str$(X) & cr
      End Select

End Sub

Sub LipidSyringes(LipidVolume As Single, LipidOverage As Single, iNumberOfSyringes As Integer, msg As String, sSyringeDescription As String, sRTFforSyringe As String)
'17Jun99 CKJ
'  This procedure looks at the lipid portion of the regimen and works out how to fit it into syringes.
'  It takes the lipid volume and existing lipid overage volume
'  It returns the revised LipidOverage volume, the number of syringes required and a message string.
'  If iNumberOfSyringes>0 then it also sets the rtf file name (including 'x:\dispdata.xxx\')
'  If syringes are not appropriate or are not possible then it sets iNumberOfSyringes=0
'    and may return an explanatory message if this was due to a configuration error.
'  Note that no account is taken of mixed or aqueous only regimens; it is the responsibility of
'  the calling routine to decide when to call the LipidSyringes procedure.
' 3Sep99 CKJ released for alpha test
'  30Mar12 TH Removed most of this as now this is derived from the print xml
'04Jan17 TH Changes to RTF Handling for Hosted (TFS 157969)
'
'TPN.INI
'[LipidSyringes]
'SyringeDescription="60ml syringe"   name of syringe
'MaximumVolumePerSyringe=50          mls max allowable in one syringe
'MinimumVolumePerSyringe=20          >= OveragePerSyringe and <= MaximumVolumePerSyringe
'OveragePerSyringe=12                can be zero
'OveragePerRegimen=0                 this is in addition to OveragePerSyringe and can be zero
'MaximumNumberOfSyringes=3           revert to bags after this number. To never use syringes set = 0
'FillEqually=Y                       Y to fill equally, N for only last syringe to be part filled
'RTFforSyringe=TPN-LBLS.rtf          label layout definition (no path, no slash, uses dispdata)
    
Dim iMaximumNumberOfSyringes%        '3 x 60ml syringes
Dim MaximumVolumePerSyringe!         '50 ml
Dim MinimumVolumePerSyringe!         '20 ml
Dim OveragePerSyringe!               ' 6 ml
Dim OveragePerRegimen!               ' 6 ml  i.e. 6ml per syringe plus a further 6ml
Dim iFillEqually As Integer          'N
Dim UsableSyringeVolume!             'calculated: max fill less overage per syringe
Dim LipidVolWithBasicOverage!        'calculated: total lipid volume plus overage per regimen
Dim PartSyringe!                     'calculated: volume in last syringe of sequence
Dim filename$                        'TPN.INI file
Dim Section$                         'section in ini file
Dim iFound%                          'item found
Dim xmldoc As MSXML2.DOMDocument
Dim xmlElement As MSXML2.IXMLDOMElement
Dim xmlnode As MSXML2.IXMLDOMElement
Dim intSuccess As Integer '04Jan17 TH Added

   iNumberOfSyringes = 0
   msg$ = ""
   sSyringeDescription = ""
   'filename$ = dispdata$ & "\PN.INI"
   
   Set xmldoc = New MSXML2.DOMDocument
   If Not xmldoc.loadXML(GetPNPrintXML()) Then
      popmessagecr "", "Could not load PN Printing Information"
   Else
      Set xmlElement = xmldoc.selectSingleNode("//PNPrintData")
      If InStr(xmlElement.xml, "NumberOfSyringes") Then iNumberOfSyringes = Val(xmlElement.selectSingleNode("NumberOfSyringes").text)
      If InStr(xmlElement.xml, "SyringeDescription") Then sSyringeDescription = xmlElement.selectSingleNode("SyringeDescription").text
      If InStr(xmlElement.xml, "RTFForSyringe") Then sRTFforSyringe = xmlElement.selectSingleNode("RTFForSyringe").text
   
   End If
   'Section$ = "LipidSyringes"

   'iMaximumNumberOfSyringes = Val(TxtD$(filename$, Section$, "0", "MaximumNumberOfSyringes", 0))

   'If LipidVolume! <= 0 Then iMaximumNumberOfSyringes = 0                  'no lipid to apportion
         
   'Select Case iMaximumNumberOfSyringes
   '   Case Is < 0
   '      msg$ = msg$ & "MaximumNumberOfSyringes in PN.INI cannot be negative" & crlf
   '   Case 0
   '      'no further action
   '   Case Is > 0
         '-- Reality Checks --
         'All TPN.INI [LipidSyringes] items are mandatory if MaximumNumberOfSyringes>0

         'sSyringeDescription = TxtD$(filename$, Section$, "", "SyringeDescription", iFound)
         If Trim$(sSyringeDescription) <> "" Then
            If Len(sSyringeDescription) > 30 Then
               'msg$ = msg$ & "Syringe description in PN.INI is too long (max 30 characters)" & crlf
               msg$ = msg$ & "Syringe description is too long (max 30 characters)" & crlf
               iFound = False
            End If
         Else
            msg$ = msg$ & "Syringe description is missing" & crlf
         End If

    '     MaximumVolumePerSyringe! = Val(TxtD$(filename$, Section$, "", "MaximumVolumePerSyringe", iFound))
    '     If iFound Then
    '           Select Case MaximumVolumePerSyringe
    '              Case Is < 1, Is > 100:
    '                 msg$ = msg$ & "MaximumVolumePerSyringe in PN.INI must be between 1ml and 100ml" & crlf
    '                 iFound = False
    '              End Select
    '        Else
    '           msg$ = msg$ & "MaximumVolumePerSyringe missing from PN.INI" & crlf
    '        End If
    
    '     MinimumVolumePerSyringe! = Val(TxtD$(filename$, Section$, "", "MinimumVolumePerSyringe", iFound))
    '     If iFound Then
    '           Select Case MinimumVolumePerSyringe
    '              Case Is < OveragePerSyringe, Is > MaximumVolumePerSyringe
    '                 msg$ = msg$ & "MinimumVolumePerSyringe must be between OveragePerSyringe and MaximumVolumePerSyringe" & crlf
    '                 iFound = False
    '              End Select
    '        Else
    '           msg$ = msg$ & "MinimumVolumePerSyringe missing from PN.INI" & crlf
    '        End If
          
    '     OveragePerSyringe! = Val(TxtD$(filename$, Section$, "", "OveragePerSyringe", iFound))
    '     If iFound Then
    '           Select Case OveragePerSyringe
    '              Case Is < 0, Is > MaximumVolumePerSyringe
    '                 msg$ = msg$ & "OveragePerSyringe must be between 0 and MaximumVolumePerSyringe" & crlf
    '                 iFound = False
    '              End Select
    '        Else
    '           msg$ = msg$ & "OveragePerSyringe missing from PN.INI" & crlf
    '        End If
      
    '     OveragePerRegimen! = Val(TxtD$(filename$, Section$, "", "OveragePerRegimen", iFound))
    '     If iFound Then
    '           If OveragePerRegimen < 0 Then
    '                 msg$ = msg$ & "OveragePerRegimen in PN.INI cannot be less than zero" & crlf
    '                 iFound = False
    '              End If
    '        Else
    '           msg$ = msg$ & "OveragePerRegimen missing from PN.INI" & crlf
    '        End If
    
    '     iFillEqually = TrueFalse(TxtD$(filename$, Section$, "", "FillEqually", iFound))
    '     If Not iFound Then
    '           msg$ = msg$ & "FillEqually missing from PN.INI" & crlf
    '        End If
          
         sRTFforSyringe = dispdata$ & "\" & sRTFforSyringe  'normally TPN-LBLS
         '04Jan17 TH Need to check in the DB for this (Hosted)
         
         If Trim$(sRTFforSyringe) <> "" Then
            GetRTFTextFromDB sRTFforSyringe, "", intSuccess '04Jan17 TH Moved above for check
            'If Not fileexists(sRTFforSyringe) Then
            If Not intSuccess Then
               'msg$ = msg$ & "(PN.INI) File RTFforSyringe cannot be found; '" & sRTFforSyringe & "'" & crlf
               msg$ = msg$ & "RTF for Syringe cannot be found in database ; '" & sRTFforSyringe & "'" & crlf
               iFound = False
            End If
         Else
            msg$ = msg$ & "RTF for Syringe missing" & crlf
         End If
    
       '  If iFound Then
       '        If iFillEqually = False And MinimumVolumePerSyringe = 0 Then 'since the last syringe in the sequence could have a very tiny quantity to be filled. Advise setting a minimum volume per syringe, or fill all equally.
       '              msg$ = msg$ & "MinimumVolumePerSyringe=0 and FillEqually=No in PN.INI:" & crlf
       '              msg$ = msg$ & "  Please set 'MinimumVolumePerSyringe' so as to avoid a tiny volume in the last syringe." & crlf
       '              iFound = False
       '           End If
       '     End If
         '-- end of reality checks --

       '  If iFound Then
       '        'The overage and total volume are calculated as follows;
       '        UsableSyringeVolume = MaximumVolumePerSyringe - OveragePerSyringe                'usable mls
       '        LipidVolWithBasicOverage = LipidVolume + OveragePerRegimen                       'lipid vol + fixed overage
       '        iNumberOfSyringes = Int(LipidVolWithBasicOverage / UsableSyringeVolume)          'integer
       '        PartSyringe = LipidVolWithBasicOverage - iNumberOfSyringes * UsableSyringeVolume 'any left over?
       '        If PartSyringe > 0 Then iNumberOfSyringes = iNumberOfSyringes + 1                'last one is part filled
       '
       '        If iNumberOfSyringes > iMaximumNumberOfSyringes Then                             'too many syringes?
       '              iNumberOfSyringes = 0                                                      'revert to bags
       '              sRTFforSyringe = ""                                                        'no file name needed
       '           Else
       '              'We now know we can fit the required amount into NumberOfSyringes
       '              'Now check if this needs increasing to fill the last syringe
       '              LipidOverage = OveragePerRegimen                                           'start with fixed overage
       '              LipidOverage = LipidOverage + iNumberOfSyringes * OveragePerSyringe        'add the overage per syringe
       '              If PartSyringe + OveragePerSyringe < MinimumVolumePerSyringe Then          'round up last one if necessary
       '                    LipidOverage = LipidOverage + MinimumVolumePerSyringe - PartSyringe - OveragePerSyringe
       '                 End If
       '           End If
       '     End If
      'End Select

End Sub

Function LockBlackboard(iAction As Integer) As Integer
'03Sep99 CKJ Written
'            Action = True  acquires an exclusive lock
'            Action = False releases it

Dim iSuccess As Integer

   AcquireLock patdatapath$ & "\PNruleng.lck", Iff(iAction, 2, 0), iSuccess
   LockBlackboard = iSuccess

End Function

Sub menuElect()
''Dim passchan%, PASS$, x%, electfil%
''
''   ReDim F(17) As Long
''
''   If UCase$(pid.sex) = "B" Then
''         NotInBatch
''      Else
''         If Val(pid.ptr(7)) < 1 Then
''               getpatidL patno&, pid          ' <== LOCK 10Aug91 CKJ
''
''               passchan = FreeFile
''               Open patdatapath$ + "\PASS" For Input As #passchan
''               Input #passchan, PASS$
''               For x = 0 To 9
''                  Input #passchan, F(x)
''               Next
''
''               pid.ptr(7) = LTrim$(Str$(F(6)))
''               F(6) = F(6) + 1
''
''               Close passchan  'being this close to open should make pass file safe
''               Open patdatapath$ + "\PASS" For Output As #passchan
''               Write #passchan, PASS$
''               For x = 0 To 9
''                  Write #passchan, F(x)
''               Next
''               Close #passchan
''
''               putpatidL patno&, pid          ' <== UNLOCK 10Aug91 CKJ
''
''               r.record = ""
''               openrandomfile patdatapath$ + "\ELECT", 760, electfil
''               PutRecordNL r, Val(pid.ptr(7)), electfil, 760
''               Close electfil
''
''            End If
''            TPNelect
''      End If

End Sub

Sub menuEnterDetails()
   
   If UCase$(pid.sex) = "B" Then
         NotInBatch
      Else
         EnterDetails            '27Dec95 CKJ Now a proc
         k.escd = False
      End If

End Sub

Sub menuPrescription()
''' 3Jan97 CKJ Added /24hrs to heading
'''13Mar98 CKJ Enabled Iron column
'''27Aug98 CKJ Checks max dose after every new calculation
'''            Lipid soluble vitamins now calculated based on Vitamin K content
'''28Sep98 CKJ Widen columns if 800x600 or better
'''            Add leading zeros to prescription if these is enough room
'''19Oct98 CKJ Amended to use 4SF precision in total and /kg calculation
'''16Feb00 CKJ Lipid soluble vitamins now use Vitamin E instead of Vitamin K as surrogate ingredient
'''            Glucose & Diluent calculation modified to use similar maths to MixGlucose routine
'''18Jul00 CKJ Added check for batch mode
'''25Jul00 CKJ Added check for view only mode
'''
'''The following code has been extracted from the code below for checking
'''         ingredient SCxy(x,) tp("PRD...")          prod!( ,x)
''         'Nitrogen         3  N                         2
''         'Vitamins aqueous 14 Vaqu                      -
''         'Vitamins lipid   15 Vlip                      -
''         'Fat              5  Fat                       4
''         'Calcium          8  ca                        7
''         'Magnesium        9  Mg                        8
''         'Zinc             10 Zn                        9
''         'Selenium         12 Se                        13
''         'Copper           13 Cu                        14
''         'Glucose          4  Gl                        3
''         'Sodium           6  Na                        5
''         'Potassium        7  K                         6
''         'Phosphate        11 PO4                       10
''         'Diluent          2  Dil                       ??
''         'Iron             .. Fe                        ..
''
''Dim x%, i%, j%, tmp$, SQLq$, tmp1$, result%, PerKg$, value!, SCtxt$, lin%, modifier!, warning$
''Dim totVitE!                                                   '16Feb00 CKJ Use VitE instead of VitK
''Dim TotgGlToAdd!, TotmlVolToAdd!, PrdGlConcGl!, PrdDilConcGl!  '16Feb00 CKJ For simultaneous equations
''
''   'If TPNVO Then Exit Sub                                                                    '25Jul00 CKJ Added message
''   If TpnVO Then                                                                              '   "
''         popmessagecr tp("sec0t"), tp("sec1d")   '"!n!iSecurity Clearance", "Insufficient privilege to use this option"
''         Exit Sub                                                                             '   "
''      End If                                                                                  '   "
''
''   If iBatchMode Then                                                                         '18Jul00 CKJ Added
''         NotInBatch                                                                           '   "
''         Exit Sub                                                                             '   "
''      End If                                                                                  '   "
''
''   'Ques.Controls(i).HelpContextID
''
''   ReDim SCxy(16, 50) As String       '!!** FIXED NUMBER    13Mar98 CKJ was 15,25
''
''   frmSC.tgdSC.Rows = 1
''   frmSC.tgdSC.ColumnSize(1) = 50
''   'frmSC.tgdSC.ColumnWidth(1) = 29    '!!** OK?                    '28Sep98 CKJ
''   frmSC.tgdSC.ColumnWidth(1) = Iff(displaysize < 2, 29, 38)        '28Sep98 CKJ widen column
''   'frmSC.tgdSC.ColumnName(1) = "      All per Kg body weight"
''   'frmSC.tgdSC.ColumnName(1) = "  All values per Kg body" & cr & "    weight per 24 hours"  '3Jan97 CKJ Added /24hrs
''   frmSC.tgdSC.ColumnName(1) = "  All values are /kg /24 hours" & cr & "  except final row Total /24hr"     '27Aug98 CKJ reworded
''   RowsUsedSC = 0
''   frmSC.tgdSC.ColumnWordWrap(1) = False
''
''   For i = 2 To 16                          '!!** FIXED NUMBER   13Mar98 CKJ was 15
''      frmSC.tgdSC.ColumnSize(i) = 5
''      'frmSC.tgdSC.ColumnWidth(i) = 6                               '28Sep98 CKJ
''      frmSC.tgdSC.ColumnWidth(i) = Iff(displaysize < 2, 6, 7)       '   "        extra column
''      frmSC.tgdSC.ColumnStyle(i) = &H23    'heading CJ, text RJ
''      tmp$ = Format$(i - 1)
''      tmp1$ = tp("SCd" & tmp$)
''      replace tmp1$, "_", cr, 0
''      frmSC.tgdSC.ColumnName(i) = tmp1$
''   Next
''
''   frmSC.tgdSC.ColumnIndex = 1
''   frmSC.tgdSC.MarqueeStyle = 2
''
''   frmSC.tgdSC.HeadingHeight = 2
''   frmSC.tgdSC.HeadFontStyle = 1   'not bold
''
''   frmSC.cmdBtns(0).Caption = "&Save && Exit"
''   frmSC.cmdBtns(1).Caption = "&Cancel"
''   frmSC.cmdBtns(2).Caption = "&Multiply"
''   frmSC.cmdBtns(3).Caption = "&Info"
''   frmSC.cmdBtns(4).Caption = "&Products"
''   frmSC.cmdBtns(5).Caption = "Help"
''
''   CheckRulesStdProForma result        'choose a standard prescription proforma
''
''   If Not k.escd Then
''         RowsUsedSC = 1
''         If result = -1 Then   'use last stored prescription
''               SCxy(0, 1) = "No Rules are shown when 'Previous Prescription' is used.[cr]This is to prevent the same changes being applied again.[cr]To see which rules would apply, escape from here and[cr]re-select a standard prescription proforma."
''               SCxy(1, 1) = GetField(patds!PrescModDate)
''               SCxy(2, 1) = GetField(patds!ScriptVol)
''               SCxy(3, 1) = GetField(patds!ScriptN)
''               SCxy(4, 1) = GetField(patds!ScriptGlu)
''               SCxy(5, 1) = GetField(patds!ScriptFat)
''               SCxy(6, 1) = GetField(patds!ScriptNa)
''               SCxy(7, 1) = GetField(patds!ScriptK)
''               SCxy(8, 1) = GetField(patds!ScriptCa)
''               SCxy(9, 1) = GetField(patds!ScriptMg)
''               SCxy(10, 1) = GetField(patds!ScriptZn)
''               SCxy(11, 1) = GetField(patds!ScriptPO4)
''               SCxy(12, 1) = GetField(patds!ScriptSe)
''               SCxy(13, 1) = GetField(patds!ScriptCu)
''               SCxy(14, 1) = GetField(patds!ScriptFe)         '13Mar98 CKJ inserted Iron
''               'SCxy(14, 1) = Getfield(patds!ScriptAVit)
''               'SCxy(15, 1) = Getfield(patds!ScriptLVit)
''               SCxy(15, 1) = GetField(patds!ScriptAVit)
''               SCxy(16, 1) = GetField(patds!ScriptLVit)
''
''         ElseIf result = -2 Then   'enter a new prescription
''               SCxy(0, 1) = "No Rules are shown when 'New Prescription' is used." ' !!** Should we?  [cr]This is to prevent the same changes being applied again.[cr]To see which rules would apply, escape from here and[cr]re-select a standard prescription proforma."
''               For i = 1 To 16                        '13Mar98 CKJ was 15
''                  SCxy(i, 1) = ""
''               Next
''
''            Else               'Use new prescription proforma
''
''               If adult(pid.sex) Then PerKg$ = "0" Else PerKg$ = "-1" 'v-- Rule Type 1
''               SQLq = "SELECT DISTINCTROW * FROM Rules WHERE RuleType=1 AND InUse=-1 AND PerKilo=" & PerKg$ & " AND RuleID=" & Str$(result) & ";"
''               If SQLdbg Then popmessagecr "SQL", SQLq
''               Set regss = regdb.CreateSnapshot(SQLq) 'only one matching row
''               SCxy(0, 1) = GetField(regss!Explanation)
''               SCxy(1, 1) = GetField(regss!Description)
''               SCxy(2, 1) = GetField(regss!volume)
''               SCxy(3, 1) = GetField(regss!Nitrogen)
''               SCxy(4, 1) = GetField(regss!Glucose)
''               SCxy(5, 1) = GetField(regss!Fat)
''               SCxy(6, 1) = GetField(regss!Sodium)
''               SCxy(7, 1) = GetField(regss!Potassium)
''               SCxy(8, 1) = GetField(regss!Calcium)
''               SCxy(9, 1) = GetField(regss!Magnesium)
''               SCxy(10, 1) = GetField(regss!Zinc)
''               SCxy(11, 1) = GetField(regss!Phosphate)
''               SCxy(12, 1) = GetField(regss!Selenium)
''               SCxy(13, 1) = GetField(regss!Copper)
''               SCxy(14, 1) = GetField(regss!Iron)            '13Mar98 CKJ Inserted Iron
''               SCxy(15, 1) = GetField(regss!AquVitamins)     '13Mar98 CKJ was 14
''               SCxy(16, 1) = GetField(regss!FatVitamins)     '13Mar98 CKJ was 15
''               'SCxy(3, 1) = GetField(regss!Calories)
''               'SCxy(13, 1) = GetField(regss!Chloride)
''               'SCxy(14, 1) = GetField(regss!Acetate)
''
''               'If LockBlackboard(True) Then                  '03sep99 Added acquirelock
''                     CheckRulesModifiers                     'check for limits or problems, add to table
''               '      LockBlackboard (False)
''               '   End If
''            End If
''
''         For i = 0 To 16                                     '28Sep98 CKJ Add leading zero if .xx
''            If Left$(SCxy(i, 1), 1) = "." Then                      'is leading zero missing?
''                  If Len(SCxy(i, 1)) <= 4 Or displaysize >= 2 Then  'is there room to add one?
''                        SCxy(i, 1) = "0" & SCxy(i, 1)
''                     End If
''               End If
''         Next
''
''         'calculate the resulting qtys and fill in the total row
''         If RowsUsedSC > 1 Then
''               RowsUsedSC = RowsUsedSC + 1
''               SCxy(0, RowsUsedSC) = "The calculation is based on the prescription proforma." & cr & "Additions and subtractions are performed next" & cr & "followed by multiplication factors." & cr & "Next, upper and lower limits are applied," & cr & "but if automated calculation is not possible" & cr & "the user is prompted to enter the required values."
''               'SCxy(1, RowsUsedSC) = "Calculated Total"
''               SCxy(1, RowsUsedSC) = "Calculated Total /kg /24hr"    '27Aug98 CKJ added /kg /24hr
''               For i = 2 To 16   'scan each ig individually   '!!** FIXED NUMBER '14Aug98 CKJ was 15
''                  value! = Val(SCxy(i, 1))
''                  SCtxt$ = "0"                                '14Aug98 CKJ was ""
''                  For j = 1 To 5        'scan once for each level of action
''                     For lin = 2 To RowsUsedSC - 1  'scan each rule
''                        'posn = InStr(SCxy(i, lin), " ")
''                        If SCxy(i, lin) <> "" Then            'rule found
''                              tmp$ = Mid$(SCxy(i, lin), 2)    'extract digits only
''                              Do While tmp$ <> "" And InStr("0123456789.", Left$(tmp$, 1)) = 0
''                                 tmp$ = Mid$(tmp$, 2)
''                              Loop
''                              modifier! = Val(tmp$)
''
''                              Select Case j         'check phase
''                                 Case 1             ' +  -
''                                    Select Case Left$(SCxy(i, lin), 1)
''                                       Case "+": value! = value! + modifier!
''                                       Case "-": value! = value! - modifier!
''                                       End Select
''                                 Case 2             ' *  x
''                                    Select Case Left$(SCxy(i, lin), 1)
''                                       Case "*", "x": value! = value! * modifier!
''                                       End Select
''                                 Case 3             ' =
''                                    Select Case Left$(SCxy(i, lin), 1)
''                                       Case "=": value! = modifier!
''                                       End Select
''                                 Case 4             ' >  >=  <  <=
''                                    Select Case Left$(SCxy(i, lin), 1)
''                                       Case ">": If value! < modifier! Then value! = modifier!
''                                       Case "<": If value! > modifier! Then value! = modifier!
''                                       End Select
''                                 Case 5             ' ?
''                                    Select Case Left$(SCxy(i, lin), 1)
''                                       Case "?"
''                                          value! = 0
''                                          SCtxt$ = "-----"
''                                       End Select
''                                 End Select
''                           End If
''                     Next
''                  Next
''
''                  If value! <> 0 Then
''                        'SCxy(i, RowsUsedSC) = Format$(tsf$(value!))  '19Oct98 CKJ removed
''                        SCxy(i, RowsUsedSC) = Trim$(FourSF$(value!))  '19Oct98 CKJ now 4SF
''                     Else
''                        SCxy(i, RowsUsedSC) = SCtxt$
''                     End If
''               Next
''            End If
''
''         RowsUsedSC = RowsUsedSC + 1
''         For i = 2 To 16     '!!** FIXED NUMBER               '13Mar98 CKJ was 15
''            SCxy(i, RowsUsedSC) = SCxy(i, RowsUsedSC - 1)
''         Next
''         SCxy(0, RowsUsedSC) = "Information and explanation may be available for each line in this table.[cr]To display these notes, move the cursor to the line of interest and press[cr]the [Return] key or click the Info button.[cr][cr]To see which products will be used to provide the ingredients requested,[cr]click the Products button." '14jun98 CKJ added [cr]
''         SCxy(1, RowsUsedSC) = "Confirmed Prescription"
''         SCxy(1, RowsUsedSC) = "Confirmed Total /kg /24hr"
''
''         '27Aug98 CKJ Block added to show total (not per kg)
''         For i = 2 To 16     '!!** FIXED NUMBER
''            If SCxy(i, RowsUsedSC) = "-----" Then
''                  SCxy(i, RowsUsedSC + 1) = "-----"
''               Else
''                  'SCxy(i, RowsUsedSC + 1) = tsfvdu$(Val(SCxy(i, RowsUsedSC)) * weight!) '19Oct98 CKJ removed
''                  SCxy(i, RowsUsedSC + 1) = FourSF$(Val(SCxy(i, RowsUsedSC)) * weight!)  '19Oct98 CKJ now 4SF
''               End If
''         Next
''         SCxy(0, RowsUsedSC + 1) = "Information and explanation may be available for each line in this table.[cr]To display these notes, move the cursor to the line of interest and press[cr]the [Return] key or click the Info button.[cr][cr]To see which products will be used to provide the ingredients requested,[cr]click the Products button."
''         SCxy(1, RowsUsedSC + 1) = "Confirmed Total /24hr"
''
''         For i = 0 To 3
''            frmSC.Label1(i) = ""
''         Next
''         For i = 1 To 8                                                '27Aug98 CKJ was 1 to 7
''            frmSC.Label1(0) = frmSC.Label1(0) & tp("SC" & Format$(i)) & cr
''         Next
''         For i = 9 To 15                                               '27Aug98 CKJ was 8 to 15
''            frmSC.Label1(2) = frmSC.Label1(2) & tp("SC" & Format$(i)) & cr
''         Next
''
''         frmSC.Label1(1) = frmSC.Label1(1) & Prd(PrdDil).name & cr
''         frmSC.Label1(1) = frmSC.Label1(1) & Prd(PrdN).name & cr
''         frmSC.Label1(1) = frmSC.Label1(1) & Prd(PrdGl).name & cr
''         frmSC.Label1(1) = frmSC.Label1(1) & Prd(PrdFat).name & cr
''         frmSC.Label1(1) = frmSC.Label1(1) & Prd(PrdNa).name & cr
''         frmSC.Label1(1) = frmSC.Label1(1) & Prd(PrdK).name & cr
''         frmSC.Label1(1) = frmSC.Label1(1) & Prd(PrdCa).name & cr
''         frmSC.Label1(1) = frmSC.Label1(1) & Prd(PrdMg).name & cr      '27Aug98 CKJ was label1(1)
''         frmSC.Label1(3) = frmSC.Label1(3) & Prd(PrdZn).name & cr
''         frmSC.Label1(3) = frmSC.Label1(3) & Prd(PrdPO4).name & cr
''         frmSC.Label1(3) = frmSC.Label1(3) & Prd(PrdSe).name & cr
''         frmSC.Label1(3) = frmSC.Label1(3) & Prd(PrdCu).name & cr
''         frmSC.Label1(3) = frmSC.Label1(3) & Prd(PrdFe).name & cr      '11Apr98 CKJ added
''         frmSC.Label1(3) = frmSC.Label1(3) & Prd(PrdVaqu).name & cr
''         frmSC.Label1(3) = frmSC.Label1(3) & Prd(PrdVlip).name & cr
''
''         k.escd = False
''
''         frmSC.tgdSC.SelectMode = 1 ' maybe 0 is OK
''         frmSC.tgdSC.SelectedBackColor = QBColor(7)
''         frmSC.tgdSC.SelectedForeColor = QBColor(0)
''         'frmSC.tgdSC.Rows = RowsUsedSC                                '27Aug98 CKJ removed
''         frmSC.tgdSC.Rows = RowsUsedSC + 1                             '27Aug98 CKJ added totals
''         frmSC.tgdSC.RowIndex = RowsUsedSC
''         frmSC.tgdSC.Refresh
''         SetTgdSCcolours frmSC.tgdSC
''         frmSC.Tag = ""
''         If displaysize >= 2 Then                                      '28Sep98 CKJ set full width
''               frmSC.Width = Screen.TwipsPerPixelX * 800               '   "        on 800 x 600
''            End If
''         HorizCentreForm frmSC
''
''         frmSC.HelpContextID = 5020
''
''         frmSC.Show 1                         '<=== Show Prescription
''
''         If frmSC.Tag <> "" Then
''               TPNchanged = True
''
''               patds.Edit
''               patds!prescribed = True
''               patds!PrescModDate = Now
''               patds!PrescModUser = UserID$
''               patds!PrescModTerm = ASCTerminalName$()             '13Aug98 CKJ was "Unknown"
''               patds!LastModDate = Now
''               patds!LastModUser = UserID$
''               patds!LastModTerm = ASCTerminalName$()              '13Aug98 CKJ was "Unknown"
''               patds!ScriptVol = Val(SCxy(2, RowsUsedSC))
''               patds!ScriptN = Val(SCxy(3, RowsUsedSC))
''               patds!ScriptGlu = Val(SCxy(4, RowsUsedSC))
''               patds!ScriptFat = Val(SCxy(5, RowsUsedSC))
''               patds!ScriptNa = Val(SCxy(6, RowsUsedSC))
''               patds!ScriptK = Val(SCxy(7, RowsUsedSC))
''               patds!ScriptCa = Val(SCxy(8, RowsUsedSC))
''               patds!ScriptMg = Val(SCxy(9, RowsUsedSC))
''               patds!ScriptZn = Val(SCxy(10, RowsUsedSC))
''               patds!ScriptPO4 = Val(SCxy(11, RowsUsedSC))
''               patds!ScriptSe = Val(SCxy(12, RowsUsedSC))
''               patds!ScriptCu = Val(SCxy(13, RowsUsedSC))
''               patds!ScriptFe = Val(SCxy(14, RowsUsedSC))          '13Mar98 CKJ Inserted Iron
''               patds!ScriptAVit = Val(SCxy(15, RowsUsedSC))        '13Mar98 CKJ was 14
''               patds!ScriptLVit = Val(SCxy(16, RowsUsedSC))        '13Mar98 CKJ was 15
''               patds!ModRegName = Left$(SCxy(1, 1), 30)            '5Oct96 CKJ was 22
''               patds!ModNum = 0
''               patds.Update
''               regname$ = SCxy(1, 1)
''
''               For x = 0 To NP - 1
''                  ig(x) = 0           'set all volumes to zero
''               Next
''
''               'NOTE: The order of checking is critical & may have to be amended
''               ' if other products are specified.
''
''               warning$ = ""                                      '27Aug98 CKJ moved from below
''
''               'Nitrogen    N    3                                 2
''               value! = Val(SCxy(3, RowsUsedSC)) * weight!
''               If value! Then
''                     x = PrdN
''                     ig!(x) = value! * prod!(x, IgVol) / prod!(x, igN)                    ' g * ml per pack / g per pack
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''                  End If
''
''               'Vitamins aqueous 15  Vaqu                         '11Apr98 CKJ was 14 until Fe added
''               value! = Val(SCxy(15, RowsUsedSC)) * weight!
''               If value! Then
''                     x = PrdVaqu
''                     ig!(x) = value!                              ' ml required
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''                     'Note that if Solivito in Vitlipid is used then this has knock-on effects
''                     'for the next block...
''                  End If
''
''               'Vitamins lipid   16  Vlip                         '11Apr98 CKJ was 15 until Fe added
''               value! = Val(SCxy(16, RowsUsedSC)) * weight!
''               If value! Then
''                     'If 'Solivito in Vitlipid' is used for the aqueous vitamins then check
''                     'if less Vitlipid is needed here, using Vitamin K as marker for product;
''                     x = PrdVlip
''                     'As it is already in mls, limit max dose
''                     ig!(x) = value!                              'temporarily set ig(x)
''                     LimitToMaxDose x%, warning$                  'find the limit
''                     value! = ig!(x)                              'retrieve this value
''                     ig!(x) = 0                                   'and zero ig(x) before totalling
''
''                     '16Feb00 CKJ Use Vitamin E instead of Vitamin K
''                     ' 'Then convert value to equivalent quantity of vitamin K
''                     ' value! = value! * prod(x, IgVitK) / prod(x, IgVol)
''                     '
''                     ' totVitK! = 0                                 'total the VitK already there
''                     ' For j = 0 To NP - 1
''                     '    totVitK! = totVitK! + ig(j) * prod(j, IgVitK) / prod(j, IgVol)
''                     ' Next
''                     '
''                     ' 'now convert back from VitK to equivalent mls of PrdVlip
''                     ' 'ig!(x) = value!                             'ml required 27Aug98 CKJ replaced
''                     ' ig!(x) = (value! - totVitK!) * prod!(x, IgVol) / prod!(x, IgVitK)     '  "
''
''                     'Then convert value to equivalent quantity of vitamin E       16Feb00 CKJ Block now uses Vitamin E
''                     value! = value! * prod(x, IgVitE) / prod(x, IgVol)
''
''                     totVitE! = 0                                 'total the VitE already there
''                     For j = 0 To NP - 1
''                        totVitE! = totVitE! + ig(j) * prod(j, IgVitE) / prod(j, IgVol)
''                     Next
''
''                     'now convert back from VitE to equivalent mls of PrdVlip
''                     ig!(x) = (value! - totVitE!) * prod!(x, IgVol) / prod!(x, IgVitE)
''
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added (should not be needed unless totVitE<0)
''                  End If
''
''               'Fat         Fat  5           4                                    4
''               value! = Val(SCxy(5, RowsUsedSC)) * weight!
''               If value! Then
''                     calctotals ""
''                     x = PrdFat
''                     ig!(x) = (value! - tot!(igFat)) * prod!(x, IgVol) / prod!(x, igFat)  ' g * ml per pack / g per pack - g already
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''                  End If
''
''               'If Zinc is provided by Peditrace then it will also provide Cu and Se
''               'Zinc        Zn   10          9                                   9
''               value! = Val(SCxy(10, RowsUsedSC)) * weight!
''               If value! Then
''                     calctotals ""
''                     x = PrdZn
''                     ig!(x) = (value! - tot!(IgZn)) * prod!(x, IgVol) / prod!(x, IgZn)    ' qty * ml per pack / qty per pack - qty already
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''                  End If
''
''               'Calcium     Ca   8           7                                   7
''               value! = Val(SCxy(8, RowsUsedSC)) * weight!
''               If value! Then
''                     calctotals ""
''                     x = PrdCa
''                     ig!(x) = (value! - tot!(IgCa)) * prod!(x, IgVol) / prod!(x, IgCa)    ' qty * ml per pack / qty per pack - qty already
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''                  End If
''
''               'Magnesium   Mg   9           8                                   8
''               value! = Val(SCxy(9, RowsUsedSC)) * weight!
''               If value! Then
''                     calctotals ""
''                     x = PrdMg
''                     ig!(x) = (value! - tot!(IgMg)) * prod!(x, IgVol) / prod!(x, IgMg)    ' qty * ml per pack / qty per pack - qty already
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''                  End If
''
''               'Selenium         12     Se   13                                  13
''               value! = Val(SCxy(12, RowsUsedSC)) * weight!
''               If value! Then
''                     calctotals ""
''                     x = PrdSe
''                     ig!(x) = (value! - tot!(IgSe)) * prod!(x, IgVol) / prod!(x, IgSe)    ' qty * ml per pack / qty per pack - qty already
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''                  End If
''
''               'Copper           13     Cu   14                                  14
''               value! = Val(SCxy(13, RowsUsedSC)) * weight!
''               If value! Then
''                     calctotals ""
''                     x = PrdCu
''                     ig!(x) = (value! - tot!(IgCu)) * prod!(x, IgVol) / prod!(x, IgCu)    ' qty * ml per pack / qty per pack - qty already
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''                  End If
''
''               '11Apr98 CKJ Added Iron here
''               'Iron             14     Fe   15                                  15
''               value! = Val(SCxy(14, RowsUsedSC)) * weight!
''               If value! Then
''                     calctotals ""
''                     x = PrdFe
''                     ig!(x) = (value! - tot!(IgFe)) * prod!(x, IgVol) / prod!(x, IgFe)    ' qty * ml per pack / qty per pack - qty already
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''                  End If
''
''               '16Feb00 CKJ Removed, see below
''               ' 'Glucose          4      Gl   3                                   3
''               ' value! = Val(SCxy(4, RowsUsedSC)) * weight!
''               ' If value! Then
''               '       calctotals ""
''               '       x = PrdGl
''               '       ig!(x) = (value! - tot!(igGl)) * prod!(x, IgVol) / prod!(x, igGl)    ' g * ml per pack / g per pack - g already
''               '       LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''               '    End If
''
''               'Phosphate        11     PO4  10                                   10
''               value! = Val(SCxy(11, RowsUsedSC)) * weight!
''               If value! Then
''                     calctotals ""
''                     x = PrdPO4
''                     ig!(x) = (value! - tot!(IgPO4)) * prod!(x, IgVol) / prod!(x, IgPO4)  ' qty * ml per pack / g per pack - qty already
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''                  End If
''
''               'Sodium           6      Na   5                                   5
''               value! = Val(SCxy(6, RowsUsedSC)) * weight!
''               If value! Then
''                     calctotals ""
''                     x = PrdNa
''                     ig!(x) = (value! - tot!(IgNa)) * prod!(x, IgVol) / prod!(x, IgNa)    ' qty * ml per pack / g per pack - qty already
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''                  End If
''
''               'Potassium        7      K    6                                  6
''               value! = Val(SCxy(7, RowsUsedSC)) * weight!
''               If value! Then
''                     calctotals ""
''                     x = PrdK
''                     ig!(x) = (value! - tot!(igK)) * prod!(x, IgVol) / prod!(x, igK)      ' qty * ml per pack / g per pack - qty already
''                     LimitToMaxDose x%, warning$                  '27Aug98 CKJ Added
''                  End If
''
''               'Check for max dose & reduce accordingly prior to topping up with water
''               'warning$ = ""                                     '27Aug98 CKJ Moved above
''
''               'For x = 0 To NP - 1                               '27Aug98 CKJ check performed at each stage now
''               '   MaxDose! = prd(x).maxmltotal
''               '   If MaxDose! > 0 And ig(x) > MaxDose! Then
''               '         warning$ = warning$ & prd(x).name & ": dose reduced to maximum of " & Format$(MaxDose!) & " ml" & cr
''               '         ig(x) = MaxDose!
''               '      End If
''               '
''               '   MaxDose! = prd(x).maxmlperkg
''               '   If MaxDose! > 0 And weight! > 0 Then
''               '         If ig(x) / weight! > MaxDose! Then
''               '               warning$ = warning$ & prd(x).name & ": dose reduced to maximum of " & Format$(MaxDose!) & " ml per kg" & cr
''               '               ig(x) = MaxDose! * weight!
''               '            End If
''               '      End If
''               'Next
''
''
''               '16Feb00 CKJ Removed block, see below
''               'If Len(warning$) Then popmessagecr "Please Note", warning$
''
''               ''!!** ASSUME WATER FOR NOW **
''               ''Diluent     Dil  2          0
''               'value! = Val(SCxy(2, RowsUsedSC)) * weight!
''               'If value! Then
''               '      calctotals ""
''               '      x = PrdDil
''               '      ig!(x) = value! - tot!(IgVol)             ' ml wanted - ml already
''               '   End If
''
''               '16Feb00 CKJ Block below allows universal diluent to be WFI or any glucose concentration
''   ' ___________________________________________________________________
''   '| All the other products | Main Glucose Product | Universal Diluent |
''   '|________________________|______________________|___________________|
''   '                              PrdGl                  PrdDil
''   '
''   '<------------------------------------------------------------------->  Total regimen volume
''   '                         <------------------------------------------>  TotmlVolToAdd (Volume of glucose products)
''   '                         <------------------------------------------>  TotgGlToAdd (g Glucose)
''
''               calctotals ""                                'fill tot!() for the next two sections
''
''               'Glucose          4      Gl   3
''               value! = Val(SCxy(4, RowsUsedSC)) * weight!  'Total grams of glucose wanted in regimen
''               TotgGlToAdd = value! - tot!(igGl)            'Total grams of glucose beyond that which is already there (NB: CAN BE NEGATIVE)
''
''               'Diluent     Dil  2          0
''               value! = Val(SCxy(2, RowsUsedSC)) * weight!  'Total volume of regimen
''               TotmlVolToAdd = value! - tot!(IgVol)         'ml wanted - ml already present  (NB: CAN BE NEGATIVE)
''
''               PrdGlConcGl = prod!(PrdGl, igGl) / prod!(PrdGl, IgVol)      'Concentration of glucose in main glucose product
''               PrdDilConcGl = prod!(PrdDil, igGl) / prod!(PrdDil, IgVol)   'Concentration of glucose in universal diluent
''
''               'Set volume required of main glucose product
''               'Formula derived from the following:
''               ' Totml    = mlA + mlB
''               ' TotGgluc = mlA x Aconc + mlB x Bconc
''               '  =>  mlA = (Bconc x Totml - TotGgluc) / (Bconc - Aconc)
''               ig(PrdGl) = (PrdDilConcGl * TotmlVolToAdd - TotgGlToAdd) / (PrdDilConcGl - PrdGlConcGl)
''               LimitToMaxDose PrdGl, warning$
''
''               'Set volume of universal diluent
''               ig(PrdDil) = TotmlVolToAdd - ig(PrdGl)
''               LimitToMaxDose PrdDil, warning$
''
''               If Len(warning$) Then popmessagecr "#Please Note", warning$
''               '--- end 16Feb00 mod
''
''               'scan all volumes & remove tiny ones, display warning if any remain negative
''               warning$ = ""
''               For x = 0 To NP - 1
''                  If ig(x) > 0 And ig(x) < 0.01 Then ig(x) = 0 '10Aug98 CKJ remove miniscule vols
''                  If ig(x) < 0 And ig(x) > -0.01 Then ig(x) = 0 '10Aug98 CKJ remove miniscule vols
''                  'If ig(x) < 0 Then
''                        'Stop   'debug breakpoint here
''                  '   End If
''                  threesigfigs ig(x)
''                  If ig(x) < 0 Then
''                        warning$ = warning$ & TB & Format$(ig(x)) & "ml" & TB & Prd(x).name & cr
''                     End If
''               Next
''               If Len(warning$) Then
''                     'popmessagecr "CAUTION", "The following product(s) cannot be used in the regimen as it is currently defined" & cr & cr & Warning$ & cr & "Please manually remove the item(s) and replace with" & cr & "alternative products where necessary"
''                     'popmessagecr "CAUTION - Regimen cannot be created", "It is not possible to create the regimen as defined. The following product(s) would require a negative volume, since other ingredients alone provide more constituents than the regimen requires." & cr & cr & warning$ & cr & "Please manually remove the item(s) and replace with alternative products where necessary.  Use of more concentrated preparations may be needed."
''                     'popmessagecr "!CAUTION - Regimen cannot be created", "It is not possible to create the regimen as defined." & cr & cr & "The following product(s) would require a negative volume, since" & cr & "other ingredients alone provide more constituents than the regimen requires." & cr & cr & warning$ & cr & "Please manually remove the item(s) and replace with alternative products if necessary." & cr & "Use of more concentrated preparations may be needed."
''                     '10Aug98 CKJ/NAH amended wording and made this a yes/no type box
''                     tmp$ = "It is not possible to create the regimen exactly as defined." & cr & cr
''                     tmp$ = tmp$ & "The following would require a negative volume, since other" & cr
''                     tmp$ = tmp$ & "ingredients alone provide more constituents than the regimen requires." & cr & cr
''                     tmp$ = tmp$ & warning$ & cr
''                     tmp$ = tmp$ & "You may leave these in the regimen and manually amend or replace with" & cr
''                     tmp$ = tmp$ & "alternatives, or you may remove these products from the regimen now." & cr & cr
''                     tmp$ = tmp$ & "Do you wish to remove the product(s) listed above from the regimen now?"
''                     If MessageBox(tmp$, MB_YESNO + MB_DEFBUTTON2 + MB_ICONEXCLAMATION, "CAUTION - Regimen cannot be created") = IDYES Then
''                           For x = 0 To NP - 1
''                              If ig(x) < 0 Then ig(x) = 0
''                           Next
''                        End If
''                  End If
''            End If
''
''         AdjPrint   'display the newly generated regimen, warts & all,
''                    'or redisplay the unchanged regimen if escaped
''      End If
''
''   Unload frmSC                                                        '28Sep98 CKJ added

End Sub

Sub menuPrint()
'''12Nov98 CKJ Allow exit if all requested printing is complete
'''18Jul00 CKJ Added Baxa File option, hidden unless interface is enabled. This is the sixth option
'''            Moved 'exit after printing' to seventh option - will need PrintOptions in TPN.INI editing
'''            Added hot keys to each line
''
''Dim i As Integer, result$
''
''   frmoptionset 0, "Print Options"
''   frmoptionset 1, "&Worksheet"
''   'frmoptionset 1, "Prescription"                                                      '18Jul00 CKJ disable in batch mode
''   frmoptionset 1, "&Prescription" & Iff(iBatchMode, Nul, "")                           '   "
''   'frmoptionset 1, "Insert for Notes"                                                  '   "
''   frmoptionset 1, "Insert for &Notes" & Iff(iBatchMode, Nul, "")                       '   "
''   frmoptionset 1, "&Labels"
''   frmoptionset 1, "&Invoice"
''   frmoptionset 1, Iff(frmVA.mnuBaxa.Enabled = True, "&Authorise Baxa File", Nul)       '18Jul00 CKJ
''   If TrueFalse(TxtD$(dispdata$ & "\tpn.ini", "", "", "AskExitAfterPrinting", 0)) Then  '12Nov98 CKJ added
''         frmoptionset 1, "&Exit after printing"                                         '   "
''      End If                                                                            '   "
''
''   frmoptionshow tpnini$("PrintOptions", "1001000"), result$  '12Nov98 CKJ was "1  1 "  '18Jul00 CKJ was "100100"
''
''   k.escd = False
''   'For i = 1 To 5                                            '12Nov98 CKJ removed
''   For i = 1 To Len(result$)                                  '12Nov98 CKJ use actual length
''      If Mid$(result$, i, 1) = "1" Then
''            Select Case i
''               Case 1: menuWSheet
''               Case 2: menuPrintScriptNotes True
''               Case 3: menuPrintScriptNotes False
''               Case 4: PrintTPNlabel
''               Case 5: PrintInvoice
''               Case 6: BaxaFile                                '18Jul00 CKJ added
''               Case 7                                          '   "        was Case 6
''                  Unload frmVA                                 '12Nov98 CKJ added
''                  ExitAfterPrinting = Not k.escd               '   "        do exit if user has not escaped from printing
''               End Select
''         End If
''      If k.escd Then Exit For
''   Next
''
''   frmoptionset 0, ""      'unload

End Sub

Sub menuPrintScriptNotes(Script As Integer)

   If UCase$(pid.sex) = "B" Then
         NotInBatch
      Else
         If Script Then
               printnotes tp("pres1"), "Script"    '"prescription"
            Else
               printnotes tp("note1"), "Notes"     '"insert for notes"
            End If
      End If

End Sub

Sub menuRegimenDetails()
'05Jun00 CKJ Added call to AdjPrint on completion
'24Nov00 CKJ avoid 'invalid use of nul' as listindex can be 0 or -1 with an empty combo box, particularly if delete key used

''Dim i As Integer, eno$, enohf$, afm As Integer    '01Jun02 All/CKJ added as integer to afm
''Dim s3$
''
''   Ques.Caption = "Regimen Details"
''
''   eno$ = tp("Enterno")
''   enohf$ = eno$ + tp("hoursfor")
''   afm = 3                   ' amino/fat/mixed   ' default for batch & adult
''   If UCase$(pid.sex) <> "B" Then
''         If Not lblscombined Then
''               afm = 1
''               's1$ = tp("Separate")
''            Else
''               's1$ = tp("Combined")
''            End If
''         's1$ = s1$ & tp("Fatamino")
''      End If
''
''   i = 1
''   'k.helpnum = 350
''   QuesMakeCtrl i, 1
''   Ques.lblDesc(i) = "Enter or amend regimen name"
''   QuesSetCtrl Ques.txtQ(i), 0, 30, RTrim$(regname$)   '5Oct96 CKJ was 20
''
''   i = 3
''   QuesMakeCtrl i, 3
''   Ques.lblDesc(i) = Trim$(tp("dtw" & Trim$(Str$(13))))
''   Ques.cmbQ(i).AddItem ""
''   Ques.cmbQ(i).AddItem "Central"
''   Ques.cmbQ(i).AddItem "Peripheral"
''   Ques.cmbQ(i).AddItem "Either Central/Peripheral"
''   Ques.cmbQ(i).ListIndex = InStr(" CPE", CP$) - 1
''
''   i = 5
''   QuesMakeCtrl i, 1
''   Ques.lblDesc(i) = Trim$(tp("dtw" & Trim$(Str$(15))))
''   QuesSetCtrl Ques.txtQ(i), 2, 0, Str$(Not lblscombined)
''
''   If tpndef.infusionrate Then
''         i = 6
''         QuesMakeCtrl i, 1
''         If lblscombined Then
''               s3$ = tp("infusion")
''            Else
''               s3$ = tp("amininf")
''            End If
''         If lblscombined Then afm = 3 Else afm = 1
''         Ques.lblDesc(i) = enohf$ + s3$
''         Ques.lblInfo(i) = "hours"
''         'QuesSetCtrl Ques.txtQ(i), 1, 2, LTrim$(Str$(tpndef.infusehrs(afm)))
''         QuesSetCtrl Ques.txtQ(i), 1, 2, Format$(infrateamino)
''         'k.helpnum = 440
''      End If
''
''   If tpndef.infusionrate Then
''         i = 7
''         QuesMakeCtrl i, 1
''         Ques.lblDesc(i) = enohf$ & tp("fatinf")
''         Ques.lblInfo(i) = "hours"
''         'QuesSetCtrl Ques.txtQ(i), 1, 2, LTrim$(Str$(tpndef.infusehrs(2)))
''         QuesSetCtrl Ques.txtQ(i), 1, 2, Format$(infratefat)
''         'k.helpnum = 450
''      End If
''
''   If Not adult(pid.sex) Then
''         'afm = 1 (Aminoacid)
''         'afm = 2 (Fat)
''         'afm = 3 (Mixed)
''         If lblscombined Then afm = 3 Else afm = 1
''
''         i = 9
''         QuesMakeCtrl i, 1
''         Ques.lblDesc(i) = "Enter overage for aqueous infusion" '##
''         Ques.lblInfo(i) = "ml"
''         QuesSetCtrl Ques.txtQ(i), 1, 4, LTrim$(Str$(overage(afm))) '1/3 amino/mixed
''         'k.helpnum = 370
''
''         i = 10
''         QuesMakeCtrl i, 1
''         Ques.lblDesc(i) = "Enter overage for lipid infusion"
''         Ques.lblInfo(i) = "ml"
''         QuesSetCtrl Ques.txtQ(i), 1, 4, LTrim$(Str$(overage(2)))  '2 fat
''         'k.helpnum = 370
''      End If
''
''   QuesCallbackMode = 2
''   Ques_Callback 5         'enable/disable fat entry as required
''
''   If TpnVO Then
''         Ques.cmdOK.Visible = False
''         Ques.cmdOK.Enabled = False
''      End If
''
''   Ques.HelpContextID = 5040
''
''   QuesShow i
''   QuesCallbackMode = 0
''
''   If Ques.Tag = "-1" Then
''         TPNchanged = True
''         regname$ = Ques.txtQ(1).Text
''         'CP$ = Choose(Ques.cmbQ(3).ListIndex + 1, "", "C", "P", "E")     '24Nov00 CKJ avoid 'invalid use of nul'
''         CP$ = Choose(Ques.cmbQ(3).ListIndex + 2, "", "", "C", "P", "E")  '   "        -1 (null) & 0 (empty combo box) => ""
''         lblscombined = (Ques.txtQ(5).Text <> "Y")      '##
''         On Error Resume Next
''         infrateamino = Val(Ques.txtQ(6).Text)
''         infratefat = Val(Ques.txtQ(7).Text)
''         If Not adult(pid.sex) Then                                       '1Sep98 CKJ added
''               If lblscombined Then
''                     overage(3) = Val(Ques.txtQ(9).Text)
''                  Else
''                     overage(1) = Val(Ques.txtQ(9).Text)
''                     overage(2) = Val(Ques.txtQ(10).Text)
''                  End If
''            End If
''         On Error GoTo 0
''         RegStatus
''         AdjPrint                                                         '05Jun00 CKJ Added
''      End If
''
''   Unload Ques

End Sub

Sub menuReplace()
'''Replace one product with another
'''12Nov96 CKJ Implemented
'''24Sep98 CKJ Added check for adult/paed use
''
''Dim Y%, ans$, Utyp$, ignum%, igname$, igunit$, s$, s1$, s2$, LN1%, LN2%, mls1!, mls2!, mmol1!, mmol2!
''
''   k.escd = False
''   Select Case frmVA.tgdVA.RowIndex
''      Case Is < 1, Is > RowsUsed
''         popmessagecr "Replace Product", "Place cursor on line to be replaced and" & cr & "on column of ingredient to be preserved"
''         k.escd = True
''      Case Else
''         LN1 = Val(VAxy(0, frmVA.tgdVA.RowIndex))
''      End Select
''
''   If Not k.escd Then
''         ignum = frmVA.tgdVA.ColumnIndex - 2
''         If ignum < 0 Or ignum > IgMax Then ignum = 0
''
''         LstBoxFrm.Caption = "Replace " & Prd(LN1).name
''         LstBoxFrm.lblTitle = cr & "Replace " & Prd(LN1).name & " while preserving which ingredient?" & cr
''         LstBoxFrm.lblHead = "  Ingredient" & Space$(10) & TB & "Quantity" & TB
''
''         Utyp$ = tp("igU0")
''         '               ig0  => volume                                       Udes0 => mls
''         s$ = "  " & tp("ig0") & TB & VAxy(2, frmVA.tgdVA.RowIndex) & TB & tp("Udes" + Utyp$)
''         LstBoxFrm.LstBox.AddItem s$
''         LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 0
''
''         For Y = 1 To IgMax
''            If prod!(LN1, Y) > 0 Then
''                  Utyp$ = tp("igU" + Format$(Y))   ' igU5 => 3
''                  '               ig5  => sodium                                                        Uabr3 => mmol
''                  s$ = "  " & tp("ig" & Format$(Y)) & TB & VAxy(Y + 2, frmVA.tgdVA.RowIndex) & TB & tp("Udes" + Utyp$)
''                  LstBoxFrm.LstBox.AddItem s$
''                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = Y
''                  If Y = ignum Then LstBoxFrm.LstBox.ListIndex = LstBoxFrm.LstBox.NewIndex
''               End If
''         Next
''         LstBoxShow
''         If LstBoxFrm.LstBox.ListIndex > -1 Then
''               ignum = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
''               igname$ = tp("Ig" + Format$(ignum))
''               igunit$ = " " & tp("Udes" + tp("igU" + Format$(ignum))) & " "
''            Else
''               k.escd = True
''            End If
''         Unload LstBoxFrm
''      End If
''
''   If Not k.escd Then
''         Screen.MousePointer = HOURGLASS
''         LstBoxFrm.lblTitle = cr & "Select product to replace " & Prd(LN1).name & cr
''         If ignum = 0 Then                   'volume only
''               For Y = 0 To NP - 1
''                  'If ig(y) = 0 Then                                           '24Sep98 CKJ
''                  If ig(Y) = 0 And ForAPuse(Y) Then                            '24Sep98 CKJ Added
''                        LstBoxFrm.LstBox.AddItem "  " & Prd(Y).name
''                        LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = Y
''                     End If
''               Next
''               LstBoxFrm.Caption = "Products not already in the regimen"
''            Else                             'mmol of ingredient
''               For Y = 0 To NP - 1
''                  'If ig(y) = 0 And prod!(y, ignum) > 0 Then                   '24Sep98 CKJ
''                  If ig(Y) = 0 And prod!(Y, ignum) > 0 And ForAPuse(Y) Then    '24Sep98 CKJ Added
''                        LstBoxFrm.LstBox.AddItem "  " & Prd(Y).name
''                        LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = Y
''                     End If
''               Next
''               LstBoxFrm.Caption = "Products containing " & igname$
''            End If
''         Screen.MousePointer = STDCURSOR
''
''         If LstBoxFrm.LstBox.ListCount = 0 Then
''               popmessagecr "Cannot Replace" & Prd(LN1).name, "No alternative products were found"
''               k.escd = True
''            End If
''
''         Do While Not k.escd
''            LstBoxShow
''            If LstBoxFrm.LstBox.ListIndex = -1 Then k.escd = True
''            If Not k.escd Then
''                  LN2 = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)    'product chosen
''                  mls1! = ig(LN1)                                                'mls original
''                  mmol1! = mls1! * prod!(LN1, ignum) / prod!(LN1, 0)             'mmol original
''                  mls2! = mmol1! * prod!(LN2, 0) / prod!(LN2, ignum)             'mls new
''                  mmol2! = Val(tsf$(mls2!)) * prod!(LN2, ignum) / prod!(LN2, 0)  'mmol new after rounding
''                  s1$ = " (" & Trim$(tsf$(mmol1!)) & igunit$ & igname$ & ")"     'x.xx mmol ingredient
''                  s2$ = " (" & Trim$(tsf$(mmol2!)) & igunit$ & igname$ & ")"     'x.xx mmol ingredient
''                  If ignum = 0 Then s1$ = "": s2$ = ""                           'only if not volume
''                  ans$ = "Y"
''                  s$ = "Do you wish to replace" & cr & cr
''                  s$ = s$ & tsf$(mls1!) & " ml " & Prd(LN1).name & s1$ & " with" & cr
''                  s$ = s$ & tsf$(mls2!) & " ml " & Prd(LN2).name & s2$ & " ?"
''                  askwin "Replace" & Prd(LN1).name, s$, ans$, k
''                  If ans$ = "Y" And Not k.escd Then Exit Do                      'accept offered item
''               End If
''         Loop
''         Unload LstBoxFrm
''      End If
''
''   If Not k.escd Then    ' now have LN1, LN2 and ignum
''         ClearBlobs          '21Sep98 CKJ Added
''         RememberK
''         RememberNa
''         ig(LN1) = 0
''         ig(LN2) = mls2!
''         ModIg(0) = LN2
''         AskAdjustNa LN2
''         AskAdjustK LN2
''         TPNchanged = True   '15Jan97 CKJ Added
''         AdjPrint
''      End If

End Sub

Sub menuStdReg()
'''22Oct97 CKJ Changed IIF to Iff
'''15Nov99 CKJ replaced IgMax with IgMaxIncNonDisp
'''05Jun00 CKJ List of std regs now shown in same order as ViewDB
''
''Dim SQLq As String, tmp$, mlsperkg!, volof!, volinmlsperkg!, nor%
''Dim ttl$, s$, s1$, s2$, s3$, s4$, s5$, s6$, ans$, Txt$, x%, Y%
''Dim mmolKperml21!, mmolPO4perml21!, mmolKpermlKCl!, maxPO4dose21!, mmolKinKCl!, maxmsg$
''Dim mlscont20!, mmolsofKin20!, MaxDose!
''Dim totap!, totg!, totmlg!, numip%, totginall!, newcals!
''
'''Dim height!, years$, ye!, bmr!, proteinfactor!, te!, tf!, activityfactor!, injf!
'''NB 'inf' not in scope !!**
''
''   If TpnVO Then
''         popmessagecr tp("sec0t"), tp("sec1d")   '"!n!iSecurity Clearance", "Insufficient privilege to use this option"
''      Else
''         k.escd = False
''         If adult(pid.sex) Then
''               GoSub chooseadultreg
''            Else
''               GoSub choosepaedreg
''            End If
''         AdjPrint
''      End If
''
''Exit Sub
''
''chooseadultreg:
''   s$ = ""
''
'' 'Code removed for the time being
'' '  te! = Val(BodyTemp$)
'' '  If te! >= 35 And Val(ifact$) > 0 And Val(ifact$) < 11 And Val(AF$) > 0 And Val(AF$) < 4 And (pid.sex = "M" Or pid.sex = "F") Then  '17Aug95 CKJ added sex
'' '        'Height = ((Val(Left$(PID.Height, 1)) * 12) + Val(Right$(PID.Height, 2))) * 2.54
'' '        If heightcms < 1 Then
'' '              popmessagecr "WARNING", "Calculation based on patient being 1.6m tall since height not entered"
'' '              Height = 160
'' '           Else
'' '              Height = heightcms
'' '           End If
'' '
'' '        today dt1
'' '        stringtodate dob$, dt2
'' '        agecalc dt1, dt2, ye!, years$
'' '
'' '        'Cannot get here if sex is Unknown, blank or lower case
'' '        If pid.sex = "M" Then
'' '              bmr! = 66.5 + (13.8 * weight!) + (5 * Height) - (6.8 * ye!)
'' '           Else
'' '              bmr! = 655 + (9.5 * weight!) + (1.8 * Height) - (4.7 * ye!)
'' '           End If
'' '        injf! = Int(10 * ((inf * .1) + .9)) / 10          '!!**
'' '        proteinfactor! = .15
'' '        If injf! > 1.3 Then proteinfactor! = .24
'' '        If injf! > 1.8 Then proteinfactor! = .32
'' '        tf! = 1
'' '        If te! > 37.5 Then tf! = 1.1
'' '        If te! > 38.5 Then tf! = 1.2
'' '        If te! > 39.5 Then tf! = 1.3
'' '        If te! > 40.5 Then tf! = 1.4
'' '        activityfactor! = Int(100 * ((Val(AF$) * .05) + 1.16)) / 100
'' '        If ye! < 16 Then
'' '              popmessagecr "Caution", "Prediction may not be accurate - Age too low to predict requirements"
'' '           End If
'' '
'' '        s$ = cr$ & "  Predicted requirements are  "
'' '        s$ = s$ & Str$((Int(proteinfactor! * weight! * 10)) / 10) & " gN, "
'' '        s$ = s$ & Str$(Int(bmr! * tf! * activityfactor! * injf!)) & " kcal, "
'' '        s$ = s$ & Str$(1.5 + (Int((20 * weight!) / 100)) / 10) & " litres" & cr$
'' '     Else
'' '        If UCase$(pid.sex) <> "B" Then
'' '              s$ = " Insufficient details entered for calculation of requirements" & cr$
'' '           End If
'' '     End If
''
''   Screen.MousePointer = HOURGLASS
''
''   LstBoxFrm.Caption = "Select Adult Regimen"
''   LstBoxFrm.lblTitle = s$
''   LstBoxFrm.lblHead = " Regimen                " & TB & "gN      " & TB & "kcal    " & TB & "Vol"
''
''   'SQLq = "SELECT DISTINCTROW StdRegID, RegName, TotgN, TotCal, TotVol FROM StdReg WHERE InUse=-1 AND PerKilo=0;"                    '05Jun00 CKJ
''   SQLq = "SELECT DISTINCTROW StdRegID, RegName, TotgN, TotCal, TotVol FROM StdReg WHERE InUse=-1 AND PerKilo=0 ORDER BY StdRegID;"   '   "        Same order as viewdb now
''
''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set regss = regdb.CreateSnapshot(SQLq)
''   regdbopen = 2
''
''   If Not regss.EOF Then
''         Do While Not regss.EOF
''            tmp$ = " " & GetField(regss!regname) & TB
''            tmp$ = tmp$ & GetField(regss!TotgN) & TB
''            tmp$ = tmp$ & GetField(regss!TotCal) & TB
''            tmp$ = tmp$ & GetField(regss!totvol)
''            LstBoxFrm.LstBox.AddItem tmp$
''            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(regss!StdRegID)
''            regss.MoveNext
''         Loop
''      Else
''         Screen.MousePointer = STDCURSOR
''         popmessagecr "Please Note", "No standard regimens have been found"
''         Exit Sub
''      End If
''
''   Screen.MousePointer = STDCURSOR
''   'k.helpnum = 105
''
''   LstBoxShow
''
''   nor = -1
''   If LstBoxFrm.LstBox.ListIndex > -1 Then
''         nor = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
''      End If
''   If nor < 0 Then k.escd = True
''   Unload LstBoxFrm
''
''   If Not k.escd Then
''         GetStdRegimen nor
''         If Not k.escd Then TPNchanged = True
''      End If
''
''Return
''
'''------CHOOSE PAEDIATRIC REGIMEN------
''choosepaedreg:
''
''   Screen.MousePointer = HOURGLASS
''
''   LstBoxFrm.Caption = "Select Paediatric Regimen"
''
''   'SQLq = "SELECT RegName,StdRegID FROM StdReg WHERE InUse=-1 AND PerKilo=-1;"                    '05Jun00 CKJ
''   SQLq = "SELECT RegName,StdRegID FROM StdReg WHERE InUse=-1 AND PerKilo=-1 ORDER BY StdRegID;"   '   "        Same order as viewdb now
''
''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set regss = regdb.CreateSnapshot(SQLq)
''   regdbopen = 2
''
''   If Not regss.EOF Then
''         Do While Not regss.EOF
''            LstBoxFrm.LstBox.AddItem " " & GetField(regss!regname)
''            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(regss!StdRegID)
''            regss.MoveNext
''         Loop
''      Else
''         Screen.MousePointer = STDCURSOR
''         popmessagecr "Please Note", "No standard regimens have been found"
''         Exit Sub
''      End If
''
''   Screen.MousePointer = STDCURSOR
''   'k.helpnum = 105
''   k.norefresh = True
''
''   LstBoxShow
''
''   nor = -1
''   If LstBoxFrm.LstBox.ListIndex > -1 Then
''         nor = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
''      End If
''   Unload LstBoxFrm
''   If nor < 0 Then k.escd = True
''
''   If Not k.escd Then GetStdRegimen nor
''
''   If Not k.escd Then
''         TPNchanged = True
''
''         ttl$ = "Paediatric Regimen"
''         s1$ = "Regimen: " & regname$ & cr$
''         s2$ = ""
''         s3$ = ""
''         s4$ = ""
''         s5$ = ""
''         s6$ = ""
''         mlsperkg = 60                       ' If weight! >= 30  '!!** extend
''         If weight! < 30 Then mlsperkg = 80
''         If weight! < 20 Then mlsperkg = 100
''
''         k.Max = 4
''         k.min = 1
''         ans$ = LTrim$(Str$(mlsperkg))
''         'k.helpnum = 200
''         k.norefresh = True
''         inputwin ttl$, "Enter total volume of fluid in ml per kg of body weight", ans$, k
''         If Not k.escd Then
''               mlsperkg = Val(ans$)           ' added CKJ 30Sep91
''               volof! = weight! * mlsperkg
''
''               k.nums = True
''               k.Max = 3
''               ans$ = "0"
''               'k.helpnum = 210
''               inputwin ttl$, "Enter volume of other fluids to be given over 24hr feeding period (ml)", ans$, k
''               OtherFluids = Val(ans$)
''               s3$ = "Volume of other fluids in 24 hours =" & Str$(OtherFluids) & " ml" & cr
''               If Not k.escd Then
''                     volof! = volof! - OtherFluids
''                     volinmlsperkg = (volof!) / weight!
''
''                     '------ ENTRY OF NEW VOLUME OF FEED ------
''                     Do
''                        ans$ = "N"
''                        'k.helpnum = 520
''                        Txt$ = "Volume of feed based on" & Str$(mlsperkg) & "ml per kg (minus" & Str$(OtherFluids) & "ml other fluids) = " & tsfvdu(volof!) & "ml or " & Format$(volinmlsperkg, "###.#") & "ml/kg" & cr$ & cr$
''                        k.norefresh = True
''                        askwin ttl$, Txt$ & "Would you like to enter a different volume?", ans$, k
''                        If k.escd Or ans$ = "N" Then Exit Do
''
''                        'k.helpnum = 600
''                        k.norefresh = True
''                        LstBoxFrm.Caption = ttl$
''                        LstBoxFrm.lblTitle = cr$ & "Enter as total volume or as ml per kg" & cr$
''                        LstBoxFrm.LstBox.AddItem " Enter as total volume"
''                        LstBoxFrm.LstBox.AddItem " Enter as mls/kg"
''                        LstBoxFrm.LstBox.ListIndex = Iff(adult(pid.sex), 0, 1)  '22Oct97 CKJ Changed IIF to Iff
''                        LstBoxShow
''                        Select Case LstBoxFrm.LstBox.ListIndex
''                           Case -1: k.escd = True
''                           Case 0:  ans$ = "T"
''                           Case 1:  ans$ = "M"
''                           End Select
''                        Unload LstBoxFrm
''                        If k.escd Then Exit Do
''
''                        If ans$ = "M" Then
''                              ans$ = ""
''                              k.Max = 3
''                              k.nums = True
''                              'k.helpnum = 220
''                              k.norefresh = True
''                              inputwin ttl$, "Enter volume in ml/kg", ans$, k
''                              If k.escd Then Exit Do
''                              mlsperkg = Val(ans$)
''                              volof! = mlsperkg * weight!
''                           End If
''
''                        If ans$ = "T" Then
''                              ans$ = ""
''                              k.nums = True
''                              k.Max = 4
''                              k.min = 1
''                              'k.helpnum = 230
''                              k.norefresh = True
''                              inputwin ttl$, "Enter total volume of feed (mls)", ans$, k
''                              If k.escd Then Exit Do
''                              volof! = Val(ans$)
''                           End If
''
''                        If OtherFluids > 0 Then
''                              ans$ = "Y"
''                              'k.helpnum = 530
''                              k.norefresh = True
''                              askwin ttl$, "Would you like to subtract the volume of other fluids from this?", ans$, k
''                              If ans$ = "Y" Then volof! = volof! - OtherFluids
''                           End If
''
''                        'k.helpnum = 610
''                        s5$ = "Volume of feed based on" & Str$(mlsperkg) & "ml per kg = " & Str$(volof!) & "ml" & cr$
''                        s6$ = cr$ & "OK to proceed with this regimen?"
''                        ans$ = "Y"
''                        k.norefresh = True
''                        askwin ttl$, s1$ & s2$ & s3$ & s4$ & s5$ & s6$, ans$, k
''                     Loop Until k.escd Or ans$ = "Y"
''
''                     If Not k.escd Then
''                           '-- SET QUANTITIES FOR CHOSEN REGIMEN --
''                           For x = 0 To NP - 1
''                              ig(x) = ig(x) * weight!
''                           Next
''
''                           'mmolKperml21!  = mmol of K+ in prod 21, the KPO4 product
''
''                           '** N.B.no longer forced to be prod 15
''                           'mmolKpermlKCl!  = mmol of K+ in prod 15
''                           'mmolKinKCl!     = mmols of KCL supplied by product 15
''
''                           'mlscont20!     = NUMBER OF ML OF PRODUCT 21 TO CONTAIN 20MMOLS PHOSPHATE
''                           'mmolsofKin20!  = mmols of potassium in prod 21 with every 20mmols of PO4
''
''                           '!!** Needs review & checking
''                           'IF tp("PaedKClKPO4split") <> "0" THEN  ' move to an ini from tpn.044
''
''                           If 0 = 1 And PaedKClKPO4split Then '!!** REMOVED FROM V7.5
''                                 mmolKperml21! = prod!(PrdKPO4, 6) / prod!(PrdKPO4, 0)      ' = K mmol / vol container  as KPO4
''                                 mmolPO4perml21! = prod!(PrdKPO4, 10) / prod!(PrdKPO4, 0)   ' = PO4 mmol / vol container  as KPO4
''                                 mmolKpermlKCl! = prod!(PrdKCl, 6) / prod!(PrdKCl, 0) ' = mmol K / vol  as KCl'@
''
''                                'If Val(Prd(PrdKPO4, 17)) Then
''                                 If Prd(PrdKPO4).maxmltotal Then      'was17
''                                       'maxdose is mls max * [PO4]
''                                       maxPO4dose21! = Prd(PrdKPO4).maxmltotal * mmolPO4perml21!   'was17
''                                       maxmsg$ = "Maximum of" + Str$(maxPO4dose21!)
''                                    Else
''                                       maxPO4dose21! = 20  'mmol max from the KPO4 product
''                                       maxmsg$ = "Default max of 20"
''                                    End If
''                                 maxmsg$ = maxmsg$ + "mmol Phosphate from Potassium Phosphate product exceeded"
''
''                                 mmolKinKCl! = ig(PrdKCl) * mmolKpermlKCl!   ' tot mmol K in volume of regimen as KCl '<-- CORRECTED 14Aug92 CKJ
''                                'mlscont20! = 20! * prod!(PrdKPO4, 0) / prod!(PrdKPO4, 10)  ' = 20 * vol container / mmol PO4 as KPO4 '@
''                                 mlscont20! = maxPO4dose21! / mmolPO4perml21! ' = max dose * vol container / mmol PO4 as KPO4
''                                 mmolsofKin20! = mmolKperml21! * mlscont20!       ' =
''
''                                 If mmolKinKCl! <= mmolsofKin20! Then        '<-- CORRECTED 14Aug92 CKJ
''                                       ig(PrdKPO4) = mmolKinKCl! / mmolKperml21!  '<-- CORRECTED 14Aug92 CKJ
''                                       ig(PrdKCl) = 0
''                                    Else
''                                       ig(PrdKPO4) = mlscont20!
''                                       ig(PrdKCl) = ig(PrdKCl) - (mmolsofKin20! / mmolKpermlKCl!)
''                                    End If
''                              End If
''
''                           For x = 0 To NP - 1              'Set maximum dose
''                              MaxDose! = Prd(x).maxmltotal  'was Val(Prd(x, 17))
''                              If MaxDose! > 0 And ig(x) > MaxDose! Then
''                                    popmessagecr "!n!bMaximum dose exceeded for " & Prd(x).name, "Dose reduced from" & Str$(ig(x)) & "ml to" & Str$(MaxDose!) & "ml"
''                                    ig(x) = MaxDose!
''                                 End If
''
''                              MaxDose! = Prd(x).maxmlperkg
''                              If MaxDose! > 0 And weight! > 0 Then
''                                    If ig(x) / weight! > MaxDose! Then
''                                          popmessagecr "!n!bMaximum dose per kg exceeded for " & Prd(x).name, "Dose reduced from" & Str$(ig(x)) & "ml to" & Str$(MaxDose! * weight!) & "ml"
''                                          ig(x) = MaxDose! * weight!
''                                       End If
''                                 End If
''                           Next
''
''                           '-------PRINT TOTALS AT BOTTOM OF SCREEN------
''                           '!!** NOTE, the one thing this proc does NOT do is print any totals!
''                           'only used by choose Paed regimen
''                           ' needs double checking
''
''                           calctotals ""   '!!** is this ok here?
''
''                           'calsincfat = tot!(1)  'not used
''
''                           'Calculate volume of glucose
''                           totap! = 0               '!!** should be totap!   ?
''                           totg! = 0                '       "
''                           totmlg! = 0              '       "
''
''                           For x = 0 To NP - 1
''                              totap! = totap! + ig(x)
''                              numip = 0
''
''                              'For Y = 2 To IgMax            '@@  13   'OK; was 2 TO 11  '15Nov99 CKJ removed
''                              For Y = 2 To IgMaxIncNonDisp   '@@  13   'OK; was 2 TO 11  '15Nov99 CKJ was IgMax
''                                 If prod!(x, Y) > 0 Then numip = numip + 1
''                              Next
''
''                              If prod!(x, 3) > 0 And numip = 1 Then       'find all glucose only prods
''                                    totg! = totg! + (prod!(x, 3) * ig(x)) / prod!(x, 0)
''                                    totmlg! = totmlg! + ig(x)
''                                 End If
''
''                              If prod!(x, 0) > 0 Then
''                                    totginall! = totginall! + ((prod!(x, 3) * ig(x)) / prod!(x, 0))
''                                 End If
''                           Next
''
''                           'diffing = totginall - totg     '!!** not used
''
''                           If totap! - totmlg! > volof! Then
''                                 Do
''                                    s$ = " Volume of ingredients is " & tsfvdu(totap! - totmlg!) & " ml" & cr
''                                    s$ = s$ & "and is greater than the final volume requested." & cr & cr
''                                    s$ = s$ & " Enter total volume of feed" & cr$
''                                    ans$ = ""
''                                    k.nums = True
''                                    k.Max = 4
''                                    k.min = 1
''                                    'k.helpnum = 240
''                                    inputwin "", s$, ans$, k
''                                    If k.escd Then Exit Do
''                                    volof! = Val(ans$)
''                                 Loop Until totap! - totmlg! <= volof!
''                              End If
''
''                           If Not k.escd Then mixglucose volof!, newcals!        '!!** newcals! is set where?
''                                                                                 'defaults to zero
''
''                           'mmolsofKCLin15!= Number of mmols of KCl supplied in product 15
''                           'mmolsofKCLin15! = ig(PrdKCl) * prod!(PrdKCl, 6) / prod!(PrdKCl, 0) '@
''                        End If
''                  End If
''            End If
''      End If
''Return

End Sub

Sub menuWSheet(ByVal lngSupplyRequestID As Long)
'05Jun00 CKJ Modified batch number to use A-Z as year 2001-2026, A-L as month and 2 or 3 digit sequence number
'18Jul00 CKJ Added icon to batch number window
   
Dim ttl$, s1$, ans$, newnum%, datechan%, BNTptr&, BNT%, numberofsheets%, WStype$
Dim writedate As String * 10
Dim sYearFormat As String
Dim sMonthFormat As String
Dim sSeqFormat As String
Dim strDesc As String
Dim strAns As String
Dim CannotPrint As Boolean

   CannotPrint = False
   
   If g_blnPNStatusPrinted Then
       strAns = "N"
      strDesc = "This supply request has previously had a worksheet printed. Are you sure you wish to print again ? "
      strDesc = TxtD$(dispdata$ & "\PN.INI", "", strDesc, "PrintAgainQuestion", 0)
      'askwin "CIVAS Product", strDesc, strAns, k
      askwin "Parenteral Nutrition", strDesc, strAns, k  '05Mar12 TH Changed title
      If k.escd Or strAns = "N" Then
         CannotPrint = True
         'strOutputMessage = "PN batch : " & Trim$(batchnumber$) & Iff(blnIssue, " issue", " return") & " aborted."
      End If
   End If
   
   If Not CannotPrint Then
      ttl$ = "Print Paediatric Worksheet"
      If adult(pid.sex) Then ttl$ = "Print Adult Worksheet"
      
      If Len(Trim$(batchnumber$)) = 0 Then
         's1$ = "No Batch number has been allocated for this patient."
         s1$ = "No Batch number has been allocated for this supply."
         '02Feb12 TH Needs adding in supply request
         popmessagecr "EMIS Health", s1$
         k.escd = True
         'Assign main outputmsg ???
''      Else
''         s1$ = "Last Batch number for this patient was T" & Trim$(BatchNumber$)
      End If
         
         
   ''   s1$ = s1$ & cr$ & cr$ & "Allocate new Batch number?"
   ''   ans$ = ""
   ''   'k.helpnum = 260
   ''   'askwin ttl$, s1$, ans$, k                     '18Jul00 CKJ added icon
   ''   askwin "?" & ttl$, s1$, ans$, k                '   "
   ''   newnum = False
   ''
   ''   If ans$ = "Y" Then
   ''         datechan = FreeFile
   ''         '!!** need err70msg
   ''         Open dispdata$ & "\readdate.dat" For Random As datechan Len = 10
   ''         Get datechan, 1, writedate$
   ''         If date$ <> writedate$ Then
   ''               BNTptr& = 0
   ''               GetPointerSQL dispdata$ & "\BNT.V5", BNTptr&, 2
   ''            End If
   ''         writedate$ = date$           'mm-dd-ccyy'
   ''         Put datechan, 1, writedate$
   ''         Close datechan
   ''         GetPointerSQL dispdata$ & "\BNT.V5", BNTptr&, True ' read, add 1, write, return value
   ''         BNT = BNTptr& Mod 1000
   ''
   ''         'BatchNumber$ = Mid$(Date$, 10, 1) + Left$(Date$, 2) + Mid$(Date$, 4, 2) + Right$("000" + LTrim$(Str$(BNT)), 3)  '18Aug95 CKJ added BNT '05Jun00 CKJ removed see below
   ''         '05Jun00 CKJ Modified batch number to use A-Z as year 2001-2026
   ''         ' Ymmddxxx or yyMddxxx where Y=A-Z or M=A-L
   ''         ' allow two or three seqence digits at end
   ''
   ''         sYearFormat = UCase$(TxtD(dispdata$ & "\TPN.INI", "", "YY", "BatchNumberYearFormat", 0))    'A, Y or YY
   ''         sMonthFormat = UCase$(TxtD(dispdata$ & "\TPN.INI", "", "A", "BatchNumberMonthFormat", 0))   'A or MM
   ''     '   sDayFormat = UCase$(txtd(dispdata$ & "\TPN.INI", "", "DD", "BatchNumberDayFormat", 0))      'DD         no options
   ''         sSeqFormat = TxtD(dispdata$ & "\TPN.INI", "", "000", "BatchNumberSequenceFormat", 0)        '00 or 000
   ''
   ''         Select Case sYearFormat
   ''            Case "A"
   ''               Select Case Val(Mid$(date$, 7, 4))                                       'ccyy'
   ''                  Case 2001 To 2026
   ''                     BatchNumber$ = Chr$(64 + Val(Mid$(date$, 9, 2)))                   'ccyy => 2001=A to 2026=Z
   ''                  Case Else
   ''                     BatchNumber$ = Mid$(date$, 10, 1)                                  'ccyy => y   0 to 9
   ''                  End Select
   ''            Case "Y"
   ''               BatchNumber$ = Mid$(date$, 10, 1)                                        'ccyy => y   0 to 9
   ''            Case "YY"
   ''               BatchNumber$ = Mid$(date$, 9, 2)                                         'ccyy => yy 00 to 99
   ''            Case Else
   ''               popmessagecr ".", "Incorrect setting for BatchNumberYearFormat in TPN.INI, please amend"
   ''               BatchNumber$ = "Y"
   ''            End Select
   ''
   ''         Select Case sMonthFormat
   ''            Case "A"
   ''               BatchNumber$ = BatchNumber$ & Chr$(64 + Val(Left$(date$, 2)))            'Jan-Dec: 01=A, 12=L
   ''            Case "MM"
   ''               BatchNumber$ = BatchNumber$ & Left$(date$, 2)                            '00 to 12
   ''            Case Else
   ''               popmessagecr ".", "Incorrect setting for BatchNumberMonthFormat in TPN.INI, please amend"
   ''               BatchNumber$ = BatchNumber$ & "M"
   ''            End Select
   ''
   ''         BatchNumber$ = BatchNumber$ & Mid$(date$, 4, 2)                                'add 'dd'
   ''
   ''         Select Case sSeqFormat
   ''            Case "00", "000"
   ''               BatchNumber$ = BatchNumber$ & Right$("000" & LTrim$(Str$(BNT)), Len(sSeqFormat)) 'add 'xx' or 'xxx'
   ''            Case Else
   ''               popmessagecr ".", "Incorrect setting for BatchNumberSequenceFormat in TPN.INI, please amend"
   ''               BatchNumber$ = BatchNumber$ & "XXX"
   ''            End Select
   ''
   ''         newnum = True
   ''      End If
   
   ''   ans$ = Trim$(BatchNumber$)   '18Aug95 CKJ removed + RIGHT$("000" + LTRIM$(STR$(BNT)), 3)
   ''   k.Max = 8                    'ASC 07Sep93 editing of batch number allowed
   ''   k.min = 1
   ''   inputwin ttl$, "Check Batch Number", ans$, k
   ''   If Not k.escd Then
   ''         BatchNumber$ = UCase$(ans$)        '18Aug95 CKJ added
   ''         '!!**GoSub SAVETPN
   ''         patds.Edit
   ''         'patds!LastModDate = Now
   ''         'patds!LastModUser = UserID$
   ''         'patds!LastModTerm = "Unknown"
   ''         patds!BatchNo = BatchNumber$
   ''         patds.Update
   ''      End If
   
      If Not k.escd And Len(Trim$(batchnumber$)) > 0 Then
         ans$ = "1"
         k.nums = True
         k.Max = 2
         k.min = 1
         'k.helpnum = 270
         InputWin ttl$, "Enter number of worksheets required", ans$, k
         numberofsheets = Val(ans$)
   
         If Not k.escd And numberofsheets > 0 Then
            '''''calctotals ""
            'If Not adult(pid.sex) Then
               '>>> check for overage not entered else         '!!**
               ''''''CalcOverage
               'If Not lblscombined Then
               '       calcoverage Overage(1), 1
               '       If Not k.escd Then calcoverage Overage(2), 2
               '   Else
               '       calcoverage Overage(3), 3
               '   End If
            'End If

            If Not k.escd Then
               'k.helpnum = 900
               ans$ = "Y"
               'confirm "!n!bPN Worksheet", "print Worksheet", ans$, k
               If ans$ = "Y" And Not k.escd Then
                  '10Aug95 CKJ Replaced with .INI file version
   ''                           Select Case pid.sex  '02Feb12 TH Need equivalents of what these actually mean
   ''
   ''                              Case "b", "B":      WStype$ = "BWS"
   ''                              Case "m", "f", "u": WStype$ = "PWS"
   ''                              Case Else:          WStype$ = "AWS"
   ''                              End Select
                  '23Feb12 TH Now replaced - batch no longer supported.
                  If adult("") Then     '16Mar12 TH Slow down and do this right - in mitigation I was ill when I did this mod, now removed the not from the condition.
                     'WStype$ = "PWS"
                     WStype$ = "AWS"   '13Mar12 TH Altered (TFS 29051)
                  Else
                     WStype$ = "PWS"
                  End If
                  Parseandprint dispdata$ & "\tpn-" & WStype$ & ".rtf", numberofsheets
                  If Not g_blnPNStatusPrinted Then
                     'OK Now lets write the attached note/status change
                     PNAttachnote "PNPrinted", lngSupplyRequestID, "PN Printed"
                  
                  End If
               End If
            End If
         End If
         If k.escd And newnum Then
            popmessagecr "!n!iEscape selected", "Please note that the assigned Batch Number T" + Trim$(batchnumber$) + " has been saved."
         End If
      End If
   End If
         
End Sub

Sub mixglucose(volof!, newcals!)
' 2Jan96 CKJ Modified to cope with WFI as diluent
'26Aug98 CKJ diluent name specified in the 'OK to mix...?' dialogue
'24Sep98 CKJ Added paed/adult check
'15Nov99 CKJ Changed IgMax to IgMaxIncNonDisp to prevent removal of Solivito in Glucose
'05Jun00 CKJ Use defined calorific value for Glucose

'/ EXIT IF NO GLUCOSE HERE YET
'  Can give 'no glucose' warning if there is glucose, but WFI is negative

Dim mixfinished%, totap!, totg!, totmlg!, concog!, totginall!, volog!
Dim X%, Y%, numip%, CalsOtherThanG!, diffing!, glucnumber%, validglucs$
Dim s$, s1$, s2a$, s2b$, s3$, mixing%, ans$, valid%
Dim gramsofglucperml!, gsup!, gwanted!, percdiff!, hilo$

   'Product PrdDil is 5% glucose, WFI or similar and ig(PrdDil) is the volume
   'prod!(x, 0) =  volume of container

   mixfinished = False
   totap! = 0     'total volume of products other than glucose
   totg! = 0      'total number of grams of glucose in glucose prods
   totmlg! = 0    'total mls of glucose of any strength
   concog! = 0    'average concentration of glucose products
   totginall! = 0 'total glucose in all prods in grams
   'diffing!      = grams of glucose in products other than pure glucose
   volog! = 0     'volume allowed for adding glucose after other products
   'volof!        = total fluid volume required
   'numip         = number of constituents in product
   'SDilGlconc    = gluc concentration in standard diluent (shared var)
    
   For X = 0 To NP - 1
      numip = 0
      'For Y = 2 To IgMax           '@@  13      'OK: was 10   '15Nov99 CKJ Removed
      For Y = 2 To IgMaxIncNonDisp  '@@  13      'OK: was 10   '15Nov99 CKJ was IgMax
         If prod!(X, Y) > 0 Then numip = numip + 1
      Next
      'IF prod!(x, 3) > 0 AND numip = 1 THEN   '28Dec95 CKJ
      If (prod!(X, 3) > 0 And numip = 1) Or X = PrdDil Then        'use SDil anyway
            totg! = totg! + (prod!(X, 3) * ig(X)) / prod!(X, 0)
            totmlg! = totmlg! + ig(X)
         End If
      If prod!(X, 0) > 0 Then
            totginall! = totginall! + prod!(X, 3) * ig(X) / prod!(X, 0)
         End If
   Next

   totap! = tot!(0) - totmlg!
   totmlg! = totmlg! - (tot!(0) - volof!)
   'CalsOtherThanG! = tot!(1) - (totginall! * 4)                          '05Jun00 CKJ
   CalsOtherThanG! = tot!(1) - (totginall! * kcalPerGramGlucose!)         '   "
   diffing! = totginall! - totg!

   If newcals! > 0 Then
         'totginall! = (newcals! - CalsOtherThanG!) / 4                   '05Jun00 CKJ
         totginall! = (newcals! - CalsOtherThanG!) / kcalPerGramGlucose!  '   "
         totg! = totginall! - diffing!     '!!** provides no extra info?
      End If

   If totmlg! > 0 Then
         concog! = totg! / totmlg! * 100      '!!** is this OK?
      End If

   glucnumber = 0
   validglucs$ = "*"                                           ' CKJ 7Oct91
 
   If concog! > 100 Then
         popmessagecr "!CHECK ALL DATA ENTERED", "Impossible to give glucose requirements; over 100% would be required"
         Exit Sub
      End If
   If concog! < 0 Then
         popmessagecr "!CHECK ALL DATA ENTERED", "Impossible reduce glucose content below zero"
         Exit Sub
      End If
   If concog! = 0 Then
         popmessagecr "!PLEASE NOTE", "No glucose is present in the regimen" & cr & "Cannot adjust volume and calorie content"
         Exit Sub
      End If

   Screen.MousePointer = HOURGLASS
   s1$ = cr & "Concentration of glucose required to make to final volume = " & tsfvdu(concog!) & "%" & cr & "Choose product "
   s1$ = cr & "To give final volume required the concentration of glucose solution to be added is " & tsfvdu(concog!) & "%" & cr & "Choose one product "
     'To give final volume required the concentration of glucose solution to be added is x%
     'Choose one glucose solution or mix one with 5% glucose'?
   s2a$ = "or"
   s2b$ = "to"
   s3$ = " mix with " & Prd(PrdDil).name & cr$
   LstBoxFrm.lblHead = "  Products available          " & TB & "Cost      " & TB & "Pack size"
   
   For X = 0 To NP - 1
      numip = 0
      'For Y = 2 To IgMax            '15Nov99 CKJ Removed
      For Y = 2 To IgMaxIncNonDisp   '15Nov99 CKJ was IgMax
         If prod!(X, Y) > 0 Then numip = numip + 1
      Next
      'If prod!(x, 3) > 0 And numip = 1 Then                                   '24Sep98 CKJ
      If prod!(X, 3) > 0 And numip = 1 And ForAPuse(X) Then                    '24Sep98 CKJ Added ForAPuse
           'LstBoxFrm.LstBox.AddItem Fmt$(x + ofs, "###") & TB & pad$(PrdName(x), 24) & TB & pad$(Prd(x).cost, 9) & TB & Str$(prod!(x, 0)) 'was15
           'LstBoxFrm.LstBox.AddItem Fmt$(x + ofs, "###  ") & prdname(x) & TB & pad(prd(x).cost, 9) & TB & Str$(prod!(x, 0))
            LstBoxFrm.LstBox.AddItem "  " & Prd(X).name & TB & pad(Prd(X).cost, 9) & TB & Str$(prod!(X, 0))
            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = X
            'validglucs$ = validglucs$ + LTrim$(Str$(x + ofs)) + "*"
            validglucs$ = validglucs$ + Format$(X) + "*"
         End If
   Next
   mixing = False
   LstBoxFrm.Caption = "Glucose calculation"
   Screen.MousePointer = STDCURSOR

   Do
      k.escd = False
      If mixing Then
            ans$ = "M"
         Else
            LstBoxFrm.lblTitle = s1$ & s2a$ & s3$
            LstBoxFrm.LstBox.AddItem "  M   Mix with " & Prd(PrdDil).name
            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -1
            LstBoxShow
            Select Case LstBoxFrm.LstBox.ListIndex
               Case -1
                  k.escd = True
               Case LstBoxFrm.LstBox.ListCount - 1
                  ans$ = "M"
               Case Else
                 'ans$ = Trim$(Str$(Val(LstBoxFrm.Tag)))
                  ans$ = Format$(LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex))
               End Select
            LstBoxFrm.LstBox.RemoveItem LstBoxFrm.LstBox.ListCount - 1
            If k.escd Then Exit Do
         End If

      If ans$ <> "M" Then
           'If Val(ans$) - ofs > NP Then 'ASC 21Mar94
            If Val(ans$) > NP Then
                  popmessagecr "!No Products >" + Str$(NP), "not valid" 'ASC 21Mar94
                  valid = False
               End If
         Else
            mixing = True
            'Exit Do        '11Mar96 CKJ removed !!** may need more thought
         End If

      If k.escd Then Exit Do
     'glucnumber = Val(ans$) - ofs
      glucnumber = Val(ans$)

      If mixing And concog! >= SDilGlconc Then   '28Dec95 CKJ was >=5
            Do
               valid = True
               'k.helpnum = 400
               LstBoxFrm.lblTitle = s1$ & s2b$ & s3$
               LstBoxShow                        '"Choose product to mix with "; prdname(PrdDil)
               Select Case LstBoxFrm.LstBox.ListIndex
                  Case -1:   k.escd = True
                 'Case Else: ans$ = Trim$(Str$(Val(LstBoxFrm.Tag)))
                  Case Else: ans$ = Format$(LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex))
                  End Select
               glucnumber = Val(ans$)
               
               If k.escd Then
                     'EXIT DO              '2Jan96 CKJ exit on escape now
                     mixing = False
                  Else
                     If prod!(glucnumber, 3) / prod!(glucnumber, 0) < concog! / 100 Then
                           popmessagecr "!N!BInvalid option", "Concentration too low"
                           valid = False
                        End If
                  End If
            Loop Until valid Or k.escd
         Else
            If mixing And concog! < SDilGlconc Then   '28Dec95 CKJ was <5
                  popmessagecr "WARNING", "Mixing less than" + Str$(SDilGlconc) + "% is not possible"
                  k.escd = True
                  mixing = False
               End If
         End If
         
      If Not k.escd Then
            TPNchanged = True
            mixfinished = True
            volog! = volof! - totap!
            gramsofglucperml! = prod!(glucnumber, 3) / prod!(glucnumber, 0)
            
            If Not mixing Then
                  gsup! = (volof! - totap!) * gramsofglucperml!
                  gwanted! = totginall!
                  percdiff! = (((gsup! + diffing!) / gwanted!) * 100) - 100
                  
                  If percdiff! > 2 Or percdiff! < -2 Then
                        If percdiff! > 0 Then
                              hilo$ = "higher"
                           Else
                              percdiff! = -1 * percdiff!
                              hilo$ = "lower"
                           End If
                        
                        's$ = "  If " & PrdName(glucnumber) & " is used alone then the calories" & CR$
                        's$ = s$ & "  supplied by will be" & Str$(Int(percdiff! + .5)) & "% " & hilo$ & " than present" & CR$
                        's$ = s$ & "  requirements. Would you like to mix two" & CR$
                        's$ = s$ & "  strengths for the exact concentration?"
                        
                        s$ = "If " & Prd(glucnumber).name & " is used alone then " & tsf$(gsup! + diffing!) & "g of" & cr$
                        s$ = s$ & "glucose will be supplied instead of " & Trim$(tsf$(gwanted!)) & "g." & cr
                        s$ = s$ & "This is " & Str$(Int(percdiff! + 0.5)) & "% " & hilo$ & " than requested." & cr$
                        's$ = s$ & cr & "Would you like to mix two strengths" & cr$                 '26Aug98 CKJ removed
                        s$ = s$ & cr & "Would you like to mix with " & Prd(PrdDil).name & cr$       '   "        diluent name specified
                        s$ = s$ & "for the exact concentration?"                                    '   "

                        If percdiff! > 10 Then ans$ = "Y" Else ans$ = "N"
                        'k.helpnum = 580
                        askwin "Glucose Concentration", s$, ans$, k
                        If ans$ = "Y" Then
                              mixing = True
                              mixfinished = False
                           Else
                              mixing = False
                              mixfinished = True
                           End If
                     Else
                        ans$ = "N"
                        mixfinished = True
                     End If
               End If
         End If
      'k.escd = False
   Loop Until mixfinished

   Unload LstBoxFrm

   If Not k.escd Then
         '--Remove all products which only contain glucose--
         For X = 0 To NP - 1
            numip = 0
            'For Y = 2 To IgMax           '@@  13   'OK: was 11   '15Nov99 CKJ removed
            For Y = 2 To IgMaxIncNonDisp  '@@  13   'OK: was 11   '15Nov99 CKJ was IgMax
               If prod!(X, Y) > 0 Then numip = numip + 1
            Next
            If prod!(X, 3) > 0 And numip = 1 Then ig(X) = 0
         Next

         ClearBlobs          '21Sep98 CKJ Added
         If mixing Then
               'Set vol of standard diluent required
               'Formula derived from the following:
               ' Totml    = mlA + mlB
               ' TotGgluc = mlA x Aconc + mlB x Bconc
               ' =>   mlA = (Bconc x Totml - TotGgluc) / (Bconc - Aconc)
               ig(PrdDil) = (gramsofglucperml! * volog! - totg!) / (gramsofglucperml! - SDilGlconc)

               'Set vol of chosen glucose product
               ig(glucnumber) = volog! - ig(PrdDil)
               ModIg(0) = glucnumber
               ModIg(1) = PrdDil

               If ig(PrdDil) < 1 Then  'is this always right? - Yes, usual minimum is 25ml
                     'Just to stop silly numbers with very
                     'small amounts of extra glucose
                     ig(glucnumber) = ig(glucnumber) + ig(PrdDil)
                     ig(PrdDil) = 0
                     ModIg(1) = -1
                  End If
            Else
               ig(PrdDil) = 0                         'Universal diluent
               ig(glucnumber) = volof! - totap!
               ModIg(0) = glucnumber
               ModIg(1) = PrdDil
            End If
      
         AdjPrint
      End If

End Sub

Sub mixtestformat(text$, perkilo%)
'!!** Standardise this? - remove odd way that one lot is sorted & other isn't
'!!** cope with solivito in one or other bag
'!!** check lipid weights - not printed?
'!!** allow user formatting/font/point size?
'!!** sort by sort order/baxa or vacumat first/premix order?
'!!** if weight printed don't print volume?
'!!** if weight not printed, choice of sort orders?

'08Feb12 TH Should now be deprecated as elements supported by this are now sent from the server side components
'22Mar12 TH Further changes to use aqueuos/lipid Specifi Gravity nodes from the incoming (precalculated) XML
'23Mar12 TH REmoved premix stuff - no longer supported - was breaking the order of stuff going on the worksheet (based on xml)
'11Feb13 XN Fixed issue with missing SpGrv causing subscript out of range error to vb6 code
'06Dec16 TH Replaced RTF Handling (TFS 157969)


Dim i%, X%, mix%, foundmix%, mixnumber%, DoIt%
Dim alltables$, tabletxt$, success%, noi%, keyID$, nopremix%
ReDim tbls$(1 To 4) '1 Aqu/mixed with SG  2 Aqu/mixed without SG
                    '3 Lipid with SG      4 Lipids without SG
'   GoTo StdWS
Dim xmldoc As MSXML2.DOMDocument
Dim xmlProducts As MSXML2.IXMLDOMNodeList
Dim xmlProduct As MSXML2.IXMLDOMElement

   text$ = ""
   'GetTextFile dispdata$ & "\tpn-wstb.rtf", alltables$, success '31Jul98 CKJ corrected path
   GetRTFTextFromDB dispdata$ & "\tpn-wstb.rtf", alltables$, success  '06Dec16 TH Replaced (TFS 157969)

   If success Then
         success = 0
         For i = 1 To 4           'Paed Adult               1,2=Aqu 3,4=Lip         1,3="SG>"  2,4=">"
            keyID$ = Iff(perkilo, "<P", "<A") & "WS-" & Iff(i < 3, "A", "L") & Iff(i Mod 2, "SG>", ">")
            X = InStr(1, alltables$, keyID$, 1)                 'find keyID
            If X Then X = InStr(X, alltables$, "\trowd", 1)     'find first table after keyID
            If X Then                                           '           v---------------
                  tabletxt$ = Mid$(alltables$, X)               '...\pard\ql\trowd\trgaph...
                  X = InStr(1, tabletxt$, "\row", 1)            '------------v
                  If X Then                                     '...\intbl\row\pard...
                        tbls$(i) = "[WStblPrefix]" & Left$(tabletxt$, X + 3) & "[WStblSuffix]"
                        success = success + 1
                     End If
               End If
         Next
         success = (success = 4)
      End If

   If Not success Then
         popmessagecr ".", "ERROR" & cr & "Cannot print worksheet: cannot find file ... or it does not contain all the Worksheet tables"
      Else
         text$ = Iff(lblscombined, "[WScombined]", "[WSaqueous]") 'combined or amino only
         noi = 0

         Set xmldoc = New MSXML2.DOMDocument
         If Not xmldoc.loadXML(GetPNPrintXML()) Then
            popmessagecr "", "Could not load PN Printing Information"
         Else
            mixnumber = -1                                'set to 11 to prevent printing
            
            ' Get Products (depends on if child or adult)
            If adult("") Then
               Set xmlProducts = xmldoc.selectSingleNode("//PNPrintData/wsmixigs").childNodes
            Else
               Set xmlProducts = xmldoc.selectSingleNode("//PNPrintData/wsmix_kg").childNodes
            End If
            
            ' Print Aqueous nodes
            For Each xmlProduct In xmlProducts
                If UCase(Mid(xmlProduct.nodeName, 5, 1)) = "A" Then  ' Only interested in PWS-ASG, PWS-A, AWS-ASG, or AWS-A
                     noi = noi + 1
                     text$ = text$ & "[PNWS" & Format$(noi) & "]"
                                      
                     If Len(xmlProduct.nodeName) = 7 Then   ' Either PWS-ASG, PWS-A, AWS-ASG, AWS-A
                        tabletxt$ = tbls$(1) ' SP grv table (PWS-ASG, AWS-ASG)
                     Else
                        tabletxt$ = tbls$(2) ' Non sp grv table (PWS-A, AWS-A)
                     End If
                     
                     If tabletxt$ <> "" Then
                       replace tabletxt$, "[Description]", xmlProduct.selectSingleNode("Description").text, True
                       replace tabletxt$, "[mls]", xmlProduct.selectSingleNode("mls").text, True
                       
                       If Not (xmlProduct.selectSingleNode("grams") Is Nothing) Then
                         replace tabletxt$, "[grams]", xmlProduct.selectSingleNode("grams").text, True
                       End If
                     
                       Heap 10, gPRNheapID, "PNWS" & Format$(noi), tabletxt$, 0
                     End If
                 End If
            Next xmlProduct
            
            ' Print Lipid nodes
            If Not (lblscombined) Then
               text$ = text$ & "[WSlipids]"
            End If
            
            For Each xmlProduct In xmlProducts
                If UCase(Mid(xmlProduct.nodeName, 5, 1)) = "L" Then  ' Only interested in PWS-LSG, PWS-L, AWS-LSG, or AWS-L
                     noi = noi + 1
                     text$ = text$ & "[PNWS" & Format$(noi) & "]"
                                      
                     If Len(xmlProduct.nodeName) = 7 Then   ' Either PWS-LSG, PWS-L, AWS-LSG, o AWS-L
                        tabletxt$ = tbls$(3) ' SP grv table (PWS-LSG, AWS-LSG)
                     Else
                        tabletxt$ = tbls$(4) ' Non sp grv table (PWS-L, AWS-L)
                     End If
                     
                     If tabletxt$ <> "" Then
                       replace tabletxt$, "[Description]", xmlProduct.selectSingleNode("Description").text, True
                       replace tabletxt$, "[mls]", xmlProduct.selectSingleNode("mls").text, True
                       
                       If Not (xmlProduct.selectSingleNode("grams") Is Nothing) Then
                         replace tabletxt$, "[grams]", xmlProduct.selectSingleNode("grams").text, True
                       End If
                                              
                       Heap 10, gPRNheapID, "PNWS" & Format$(noi), tabletxt$, 0
                     End If
                 End If
            Next xmlProduct
         End If
         Set xmldoc = Nothing
      End If
Exit Sub

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

StdWS:

   If perkilo Then
         text$ = "[Mix/kgHdr1]"
         For X = 0 To NP - 1
            If igover!(X) > 0 And RTrim$(Prd(X).SolnAB) <> "B" And Prd(X).SpGrav > 0 Then  'was14,13
                  text$ = text$ + "[Mix/kgLin1]" + pad$(Prd(X).name, 30) & "[Mix/kgLin1a]"
                  text$ = text$ + tsf$(igover!(X)) + "[Mix/kgLin2]"
                  text$ = text$ + tsf$(igover!(X) * Prd(X).SpGrav) + "[Mix/kgLin3]"  'was13
               End If
         Next

         For X = 0 To NP - 1
            If igover!(X) > 0 And RTrim$(Prd(X).SolnAB) <> "B" And Prd(X).SpGrav = 0 Then  'was14,13
                  text$ = text$ + "[Mix/kgLin1]" + pad$(Prd(X).name, 30) & "[Mix/kgLin1a]"
                  text$ = text$ + tsf$(igover!(X)) + "[Mix/kgLin4]"
               End If
         Next

         text$ = text$ + "[Mix/kgHdr2]"

         For X = 0 To NP - 1
            If RTrim$(Prd(X).SolnAB) = "B" Then  'was14
                  If igover!(X) > 0 Then
                        text$ = text$ & "[Mix/kgLin1]" & pad$(Prd(X).name, 30) & "[Mix/kgLin1a]"
                        text$ = text$ & tsf$(igover!(X)) & "[Mix/kgLin5]"
                       'If igover!(x) <= 20 And prd(x).SpGrav > 0 Then  'was13   '!!** why <=20???
                        If Prd(X).SpGrav > 0 Then  'was13
                              text$ = text$ & "[Mix/kgLin6]" & tsf$(igover!(X) * Prd(X).SpGrav) + "[Mix/kgLin7]"    'was13
                           Else
                              text$ = text$ & "[Mix/kgLin8]"
                           End If
                        text$ = text$ & "[Mix/kgLin9]"
                     End If
               End If
         Next

      Else       'not per kilo

         text$ = ""
         For mix = 0 To 9     '30Jul95 CKJ/ASC
            '--test for an ingredient in mix--
            foundmix = False
            For X = 0 To NP - 1
               If ig(X) > 0 And Prd(X).PreMix = mix Then  'was16
                     mixnumber = mix
                     foundmix = True
                  End If
            Next

            '--print premix heading--
            If foundmix Then
                  If mixnumber = 0 Then
                        text$ = text$ & "[PreMixNotDef]"
                     Else
                        text$ = text$ & "[PreMixNumber]" & Str$(mixnumber) & "[PreMixNumCR]"
                     End If
                  mixnumber = 0
                  For X = 0 To NP - 1
                     If ig(X) > 0 And Prd(X).PreMix = mix Then   'was16
                           text$ = text$ & "[PreMixLin1]" & pad$(Prd(X).name, 30) & "[PreMixLin1a]" & tsf$(ig!(X)) + "[PreMixLine]"
                        End If
                  Next
               End If
         Next
      End If

End Sub

Sub mmolentry(LN, elecnum, stage)
'''26May92 CKJ Mod to correct when err msg displays
'''11Aug95 CKJ mmolentry1/2 incorporated & .ini file used
'''08Dec98 CKJ Amended; correct figure should be existing qty /weight , not answer / weight
'''24Nov00 CKJ Corrected mod of 08Dec98 to prevent division by zero in batch mode
''
''Dim igname$, u$, totalelec!, totalelecinall!, x%, mmolperml!, diffelec!, s$, answer!, ans$, temp!
''Dim anstemp!, tempkg!
''
''   k.escd = False
''   igname$ = tp("ig" + Format$(elecnum))
''   'pickwindow 4, cols, tp("Enter") + igname$, 4     '"!n!bEnter "
''
''   u$ = tp("IgU" + Format$(elecnum)) 'Ingredient unit type, 3 mmol or 4 umol
''
''   totalelec! = 0
''   totalelecinall! = 0
''
''   For x = 0 To NP - 1
''      If prod!(x, 0) > 0 Then
''            totalelecinall! = totalelecinall! + (prod!(x, elecnum) * (ig(x) / prod!(x, 0)))
''         End If
''   Next
''
''   If ig(LN) > 0 Then
''         totalelec! = prod!(LN, elecnum) * (ig(LN) / prod!(LN, 0))
''      End If
''   mmolperml! = prod!(LN, elecnum) / prod!(LN, 0)
''
''   diffelec! = totalelecinall! - totalelec!
''
''   'keys$ = tp("Ukey" + u$)   ' TM TG etc
''   'keyT$ = Left$(keys$, 1)   ' total
''   'keyM$ = Right$(keys$, 1)  ' mmol
''
''   If weight! = 0 Then stage = 1
''
''   If stage = 0 Then         ' ask total or per kilo
''         'k.helpnum = 640
''         'printw tp("Entot") + tp("Uinp" + u$) + tp("kgof") + igname$ + " ?  " + keyT$ + "/" + keyM$
''         LstBoxFrm.Caption = tp("Enter") & igname$
''         LstBoxFrm.lblTitle = cr$ & "Select entry by Total or per Kg using " & Prd(LN).name & cr$
''         LstBoxFrm.LstBox.AddItem "  Enter " & igname$ & " as total " & tp("Udes" + u$)
''         LstBoxFrm.LstBox.AddItem "  Enter " & igname$ & " as " & tp("Udes" + u$) & "/kg"
''         LstBoxFrm.LstBox.ListIndex = Iff(adult(pid.sex), 0, 1)          '21Sep98 CKJ Added
''         LstBoxShow
''         stage = LstBoxFrm.LstBox.ListIndex + 1
''         Unload LstBoxFrm
''      End If
''
''   If stage > 0 Then
''         Do
''            Select Case stage
''               Case 1
''                  s$ = "Enter total " & tp("Udes" & u$) & tp("of") & igname$ & tp("reqd")
''                  answer! = totalelecinall!
''                  'k.helpnum = 410
''               Case 2
''                  s$ = tp("Enter") & tp("Udes" & u$) & tp("kgof") & igname$ & tp("reqd")
''                  answer! = totalelecinall! / weight!
''                  'k.helpnum = 420
''               End Select
''            threesigfigs answer!
''            ans$ = Trim$(tsf$(answer!))
''            If ans$ = "0" Then ans$ = ""
''            k.Max = 4
''            k.min = 1
''            k.decimals = True
''            inputwin tp("Enter") & igname$, s$ & cr$ & "    (by amending " & Prd(LN).name & ")", ans$, k
''            If k.escd Then Exit Do
''
''            If stage = 2 Then
''                  ans$ = LTrim$(Str$(Val(ans$) * weight!))
''                  If ans$ = "0" Then ans$ = ""
''               End If
''
''            If Val(ans$) < diffelec! Then
''                  temp! = diffelec!
''                  threesigfigs temp!
''                  anstemp! = Val(ans$)      ' 26May92 CKJ if ans$ is same as
''                  threesigfigs anstemp!     ' diffelec as displayed then assume
''                  If anstemp! < temp! Then  ' ans = diffelec with extra decimals
''                        '24Nov00 CKJ replaced with block below
''                        ' 'anstemp1! = anstemp! / weight!                                  '08Dec98 CKJ correct figure should be existing qty /weight , not answer / weight
''                        ' tempkg! = temp! / weight!                                        '   "
''                        ' threesigfigs tempkg!                                             '   "
''                        ' 'popmessagecr "Cannot alter " & igname$, tp("mmad1") + Str$(temp!) & tp("Uabr" + u$) & cr$ & tp("mmad2") & Str$(anstemp1!) & tp("Uabr" + u$) & "/kg"            '08Dec98 CKJ corrected
''                        ' 'popmessagecr "!", "Cannot reduce " & igname$ & " to " & tsf$(anstemp!) & " " & tp("Uabr" & u$) & cr & "by amending " & prd(LN).name & cr & cr & tp("mmad1") & " " & tsf$(temp!) & " " & tp("Uabr" & u$) & cr$ & tp("mmad2") & tsf$(tempkg!) & " " & tp("Uabr" + u$) & "/kg"               '08Dec98 CKJ amended wording to avoid per kg twice in one line
''                        ' popmessagecr "!", "Cannot reduce " & igname$ & " to " & tsf$(anstemp!) & " " & tp("Uabr" & u$) & cr & "by amending " & Prd(LN).name & cr & cr & tp("mmad1") & " " & tsf$(temp!) & " " & tp("Uabr" & u$) & cr$ & "which is equivalent to " & tsf$(tempkg!) & " " & tp("Uabr" & u$) & "/kg"  '   "
''
''                        '24Nov00 CKJ Block rewritten to prevent div by zero in batch mode
''                        s$ = "Cannot reduce " & igname$ & " to " & tsf$(anstemp!) & " " & tp("Uabr" & u$) & cr & "by amending " & Prd(LN).name & cr & cr & tp("mmad1") & " " & tsf$(temp!) & " " & tp("Uabr" & u$)
''                        If weight! > 0 Then
''                              tempkg! = temp! / weight!
''                              threesigfigs tempkg!
''                              s$ = s$ & cr$ & "which is equivalent to " & tsf$(tempkg!) & " " & tp("Uabr" & u$) & "/kg"
''                           End If
''                        popmessagecr "!", s$
''                     Else
''                        popmessagecr tp("remPt"), tp("remPd")   '"!n!bProduct will be removed", "Quantity required is provided by other ingredients"
''                        ans$ = LTrim$(Str$(diffelec!)) ' assume exact difference
''                        Exit Do
''                     End If
''               End If
''         Loop Until Val(ans$) >= diffelec!
''
''         If Not k.escd Then
''               ClearBlobs          '21Sep98 CKJ Added
''               RememberK
''               RememberNa
''               ig(LN) = (Val(ans$) - diffelec!) / mmolperml!
''               threesigfigs ig(LN)
''               ModIg(0) = LN
''               AskAdjustNa LN
''               AskAdjustK LN
''               TPNchanged = True   '15Jan97 CKJ Added
''               AdjPrint
''            End If
''      End If

End Sub

Sub NewRegimen(Action As Integer)
'''12Jun98 CKJ Extended to remove enteral/other
''' 5Aug98 CKJ Added Action parameter
'''            Action 1  New regimen, optionally blanking enteral & other
'''                   2  Blank Enteral Products
'''                   3  Blank Other Infusions
''
''Dim ans$, i%, totl!
''
''   Select Case action
''      Case 1
''         ans$ = "N"
''         askwin "!New Regimen", "OK to remove current regimen?", ans$, k
''         If ans$ = "Y" Then
''               For i = 0 To NP - 1
''                  ig(i) = 0
''               Next
''               regname$ = "Un-named"
''
''               TPNchanged = True
''               AdjPrint
''
''               totl! = 0
''               For i = -NPe - NPi To -1
''                  totl! = totl! + ig(i)
''               Next
''               For i = 0 To IgMax
''                  totl! = totl! + ManualIE(2, i)
''                  totl! = totl! + ManualIE(3, i)
''               Next
''
''               If totl! Then
''                     ans$ = "N"
''                     askwin "!New Regimen", "Regimen Deleted" & cr & cr & "Do you wish to remove enteral feeds/other infusions as well?", ans$, k
''                     If ans$ = "Y" Then
''                           For i = -NPe - NPi To -1
''                              ig(i) = 0
''                           Next
''                           For i = 0 To IgMax
''                              ManualIE(2, i) = 0
''                              ManualIE(3, i) = 0
''                           Next
''                           AdjPrint
''                        End If
''                  End If
''            End If
''
''      Case 2
''         ans$ = "N"
''         askwin "!Blank Enteral Products", "Do you wish to remove all Enteral products?", ans$, k
''         If ans$ = "Y" Then
''               For i = -NPe - NPi To -NPi - 1
''                  ig(i) = 0
''               Next
''               For i = 0 To IgMax
''                  ManualIE(3, i) = 0
''               Next
''               AdjPrint
''            End If
''
''      Case 3
''         ans$ = "N"
''         askwin "!Blank Other Infusions", "Do you wish to remove all Other Infusions?", ans$, k
''         If ans$ = "Y" Then
''               For i = -NPi To -1
''                  ig(i) = 0
''               Next
''               For i = 0 To IgMax
''                  ManualIE(2, i) = 0
''               Next
''               AdjPrint
''            End If
''      End Select
''
''   k.escd = False

End Sub

Sub CheckRulesModifiers()
'''RuleTypes = 1 Standard Prescription Proforma
'''            2 Prescription modifiers                       <== This Procedure
'''            3 Prescription Stability/Dosage Check
'''            4 Regimen Stability/Dosage Check
''
''Dim SQLq As String, PerKg$, BBds As Dynaset
''Dim result%, igname$, IgAction$, IgValue!, i%, rule$
''
''   k.escd = False
''   result = 0
''   Screen.MousePointer = HOURGLASS
''
''   'Find the Blackboard record - use as sandpit for rule testing
''   SQLq = "SELECT DISTINCTROW * FROM Blackboard WHERE ID=1;"
''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set BBds = patdb.CreateDynaset(SQLq) ' only one matching row
''
''   FillBlackboardPIDClinical PerKg$, BBds        'Clear BB, fill with PID & Clinical info
''   FillBlackboardPrescription 1, BBds            'add standard proforma to Prescription*
''   'BBds.Fields("Regimen-----") =                'No Regimen at this time
''
''   BBds.Update                                   'Edit started in FillBlackboardPIDClinical
''
''   'Find all rules which might apply to this situation    v-- Rule Type 2
''   SQLq = "SELECT DISTINCTROW * FROM Rules WHERE RuleType=2 AND InUse=-1 AND PerKilo=" & PerKg$ & ";"
''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set regss = regdb.CreateSnapshot(SQLq) ' could be many matching rows
''   regdbopen = 2
''
''   Do While Not regss.EOF    'for each rule found, test it
''      rule$ = GetField(regss!RuleSQL)
''      If rule$ = "" Then
''            popmessagecr "WARNING", "Blank rule found - not valid"
''         Else
''            SQLq = "SELECT DISTINCTROW * FROM Blackboard WHERE ID=1 AND (" & rule$ & ");"
''            If SQLdbg Then
''                  popmessagecr "SQL", SQLq
''               End If
''            Set BBds = patdb.CreateDynaset(SQLq) ' only one matching row
''            If Not BBds.EOF Then  'rule fired - it was true
''                  'Now act on the instructions
''                  RowsUsedSC = RowsUsedSC + 1
''                  SCxy(1, RowsUsedSC) = GetField(regss!Description)
''                  igname$ = GetField(regss!IngredientName)
''                  IgAction$ = GetField(regss!IngredientAction)
''                  IgValue! = GetField(regss!IngredientValue)
''                  SCxy(0, RowsUsedSC) = GetField(regss!Explanation)
''                  For i = 1 To 15  '!!** Fixed Number      11Apr98 CKJ was 14
''                     If UCase$(tp("SC" & Format$(i))) = UCase$(igname$) Then 'found right ingredient
''                           If IgAction$ = "?" Then
''                                 SCxy(i + 1, RowsUsedSC) = "?Ask"
''                              Else
''                                 SCxy(i + 1, RowsUsedSC) = IgAction$ & Format$(IgValue!)
''                              End If
''                           Exit For
''                        End If
''                  Next
''               End If
''         End If
''      regss.MoveNext
''   Loop
''
''   BBds.Close
''   Screen.MousePointer = STDCURSOR

End Sub

Sub CheckRulesPrescription(txt$, Critical%)
'''RuleTypes = 1 Standard Prescription Proforma
'''            2 Prescription modifier
'''            3 Prescription Stability/Dosage Check          <== This Procedure
'''            4 Regimen Stability/Dosage Check
'''
'''21Sep98 CKJ Added asterisk to highlight critical rules
''
''Dim SQLq As String, PerKg$, BBds As Dynaset, rule$
''
''   k.escd = False
''   Txt$ = ""
''   Critical = False
''   Screen.MousePointer = HOURGLASS
''
''   'Find the Blackboard record - use as sandpit for rule testing
''   SQLq = "SELECT DISTINCTROW * FROM Blackboard WHERE ID=1;"
''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set BBds = patdb.CreateDynaset(SQLq) ' only one matching row
''
''   FillBlackboardPIDClinical PerKg$, BBds        'Clear BB, fill with PID & Clinical info
''   FillBlackboardPrescription RowsUsedSC, BBds   'add amended figures to Prescription*
''
''   BBds.Update                                   'Edit started in FillBlackboardPIDClinical
''
''   'Find all rules which might apply to this situation    v-- Rule Type 3
''   SQLq = "SELECT DISTINCTROW * FROM Rules WHERE RuleType=3 AND InUse=-1 AND PerKilo=" & PerKg$ & ";"
''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set regss = regdb.CreateSnapshot(SQLq) ' could be many matching rows
''   regdbopen = 2
''
''   Do While Not regss.EOF    'for each rule found, test it
''      rule$ = GetField(regss!RuleSQL)
''      If rule$ = "" Then
''            popmessagecr "WARNING", "Blank rule found - not valid"
''         Else
''            SQLq = "SELECT DISTINCTROW * FROM Blackboard WHERE ID=1 AND (" & rule$ & ");"
''            If SQLdbg Then
''                  popmessagecr "SQL", SQLq
''               End If
''            Set BBds = patdb.CreateDynaset(SQLq) ' only one matching row
''            If Not BBds.EOF Then  'rule fired - it was true
''                  'Now act on the instructions
''                  If GetField(regss!Critical) Then                        '21Sep98 CKJ Moved
''                        Txt$ = Txt$ & "* "                                '            added
''                        Critical = True                                   '            moved
''                     End If
''                  Txt$ = Txt$ & GetField(regss!Description) & ":[cr]"
''                  Txt$ = Txt$ & GetField(regss!Explanation) & "[cr][cr]"
''                  'If Getfield(regss!Critical) Then Critical = True       '21Sep98 CKJ Moved
''               End If
''         End If
''      regss.MoveNext
''   Loop
''
''   BBds.Close
''   Screen.MousePointer = STDCURSOR

End Sub

Sub CheckRulesRegimen(txt$, Critical%)
'''RuleTypes = 1 Standard Prescription Proforma
'''            2 Prescription modifier
'''            3 Prescription Stability/Dosage Check
'''            4 Regimen Stability/Dosage Check               <== This Procedure
'''
'''5Jun98 CKJ removed hard-coded Iron calculation and rules - now in SQL
'''02Sep98 CKJ Added Err 11 (Divide by zero) to the error handler
'''21Sep98 CKJ Added asterisk to highlight critical rules
''' 3Sep99 CKJ routine now adds to txt$ instead of replacing existing text
''
''Dim SQLq As String, PerKg$, BBds As Dynaset
''Dim lin%, rule$, tmp$, x%                                  ', IronTot!
''
''   k.escd = False
''   'txt$ = ""                                 '3Sep99 CKJ now cleared before this routine
''   Critical = False
''   Screen.MousePointer = HOURGLASS
''
''   'popmessagecr "Iron", Str$(IronTotal())    '3Jan96 CKJ Temp for warning msg '5Jun98 CKJ removed
''   'IronTot! = IronTotal()                    '3Jan96 CKJ Temp for warning msg '5Jun98 CKJ removed
''
''   'Find the Blackboard record - use as sandpit for rule testing
''   SQLq = "SELECT DISTINCTROW * FROM Blackboard WHERE ID=1;"
''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set BBds = patdb.CreateDynaset(SQLq) ' only one matching row
''
''   FillBlackboardPIDClinical PerKg$, BBds        'Clear BB, fill with PID & Clinical info
''   FillBlackboardPrescription 0, BBds            'add confirmed figures to Prescription*
''
''   lin = RowsUsed + 1                            'mmol etc total amounts (NOT per kilo)
''   BBds!RegimenVolume = VAxy(2, lin)
''   BBds!RegimenCalories = VAxy(3, lin)
''   BBds!RegimenNitrogen = VAxy(4, lin)
''   BBds!RegimenGlucose = VAxy(5, lin)
''   BBds!RegimenFat = VAxy(6, lin)
''   BBds!RegimenSodium = VAxy(7, lin)
''   BBds!RegimenPotassium = VAxy(8, lin)
''   BBds!RegimenCalcium = VAxy(9, lin)
''   BBds!RegimenMagnesium = VAxy(10, lin)
''   BBds!RegimenZinc = VAxy(11, lin)
''   BBds!RegimenPhosphate = VAxy(12, lin)
''   BBds!RegimenChloride = VAxy(13, lin)
''   BBds!RegimenAcetate = VAxy(14, lin)
''   BBds!RegimenSelenium = VAxy(15, lin)
''   BBds!RegimenCopper = VAxy(16, lin)
''   BBds!RegimenIron = VAxy(17, lin)              '05Jun98 CKJ added iron
''   BBds!RegimenAqueousVolume = TotAmino
''   BBds!RegimenLipidVolume = TotLipid
''   BBds!RegimenInorganicPhosphate = TotInPO4     '21Oct96 CKJ added
''   BBds!RegimenManganese = IngredientTotal(IgMn) ' 1Sep98 CKJ added
''
''   tmp$ = ","                                    '05Jun98 CKJ make list of ",prdcode,prdcode,prdcode,"
''   For x = 0 To NP - 1
''      If ig(x) > 0 Then tmp$ = tmp$ & Prd(x).linkcode & ","
''   Next
''   BBds!LinkCodes = tmp$
''
''   BBds.Update                                   'Edit started in FillBlackboardPIDClinical
''
''   'Find all rules which might apply to this situation    v-- Rule Type 4
''   SQLq = "SELECT DISTINCTROW * FROM Rules WHERE RuleType=4 AND InUse=-1 AND PerKilo=" & PerKg$ & ";"
''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set regss = regdb.CreateSnapshot(SQLq) ' could be many matching rows
''   regdbopen = 2
''
''   Do While Not regss.EOF    'for each rule found, test it
''      rule$ = GetField(regss!RuleSQL)
''      If rule$ = "" Then
''            popmessagecr "WARNING", "Blank rule found - not valid"
''         Else
''            SQLq = "SELECT DISTINCTROW * FROM Blackboard WHERE ID=1 AND (" & rule$ & ");"
''            If SQLdbg Then popmessagecr "SQL", SQLq
''
''            On Error GoTo CheckRulesRegimen_Err
''            Set BBds = patdb.CreateDynaset(SQLq) ' only one matching row
''            On Error GoTo 0
''            If Not BBds.EOF Then  'rule fired - it was true
''                  'Now act on the instructions
''                  If GetField(regss!Critical) Then                        '21Sep98 CKJ Moved
''                        Txt$ = Txt$ & "* "                                '            added
''                        Critical = True                                   '            moved
''                     End If
''                  Txt$ = Txt$ & GetField(regss!Description) & ":[cr]"
''                  Txt$ = Txt$ & GetField(regss!Explanation) & "[cr][cr]"
''                  'If Getfield(regss!Critical) Then Critical = True       '21Sep98 CKJ Moved
''               End If
''nextrule:
''            On Error GoTo 0
''         End If
''      regss.MoveNext
''   Loop
''
''   BBds.Close
''   Screen.MousePointer = STDCURSOR
''
'' '05Jun98 CKJ Removed - now in SQL
'' '  '3Jan96 CKJ Temp for warning msg  !!**
'' '  If TotAmino > 0 Then
'' '        If IronTot! / TotAmino > .0179 Then   '17.9umol per l
'' '              txt$ = txt$ & "Iron High:[cr]"
'' '              txt$ = txt$ & "Iron exceeds 17.9 umol/l, equivalent to more than[cr]100ug Iron per 100ml aqueous solution.[cr]Please seek advice about stability[cr][cr]"
'' '           End If
'' '     End If
'' '
'' '  '15Jan96 CKJ Temp for warning msg  !!**
'' '  '30Jun97 CKJ Inhibit for adult usage
'' '  If IronTot! > 0 And Not adult(pid.sex) Then    'Iron present in the regimen
'' '        txt$ = txt$ & "Iron III Chloride:[cr]"
'' '        txt$ = txt$ & "Please note that the volume of Iron III Chloride added[cr]must be less than or equal to the volume of of Peditrace added[cr]This for stability reasons.[cr][cr]"
'' '     End If
''
''Exit Sub
''
''CheckRulesRegimen_Err:
''   'If Err = 6 Then Resume nextrule     'Overflow, eg divide by total vol = 0
''   Select Case Err                      '02Sep98 CKJ Added Err 11
''      Case 6, 11: Resume nextrule       'Overflow, Divide by zero eg divide by total vol = 0
''      End Select
''   Error Err
''   'Resume Next
''   Close  '!!** Crude
''End

End Sub

Sub CheckRulesStdProForma(result%)
'''RuleTypes = 1 Standard Prescription Proforma              <== This Procedure
'''            2 Regimen modifier
'''            3 Prescription Stability/Dosage Check
'''            4 Regimen Stability/Dosage Check
'''05Nov96 CKJ Added rules to narrow down the search
'''31Mar97 CKJ Allow New Prescription every time, regardless of previous entries
''
''Dim SQLq As String, PerKg$, Txt$, BBds As Dynaset, keep%, rule$
''
''   k.escd = False
''   result = 0
''   If adult(pid.sex) Then PerKg$ = "0" Else PerKg$ = "-1"
''   Screen.MousePointer = HOURGLASS
''
''   'Find the Blackboard record - use as sandpit for rule testing
''   SQLq = "SELECT DISTINCTROW * FROM Blackboard WHERE ID=1;"
''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set BBds = patdb.CreateDynaset(SQLq) ' only one matching row
''   FillBlackboardPIDClinical PerKg$, BBds
''   BBds.Update                                   'Edit started in FillBlackboardPIDClinical
''
''   '                                          v-- Rule Type 1
''   SQLq = "SELECT * FROM Rules WHERE RuleType=1 AND InUse=-1 AND PerKilo=" & PerKg$ & " ORDER BY RuleNumber;"
''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set regss = regdb.CreateSnapshot(SQLq)     ' could be many matching rows
''   regdbopen = 2
''   Screen.MousePointer = STDCURSOR
''
''   'If Not regss.EOF Then
''         Screen.MousePointer = HOURGLASS
''         LstBoxFrm.Caption = "Select Prescription Proforma"
''
''         If GetField(patds!PrescModDate) > 0 Then                    'There is a script stored
''               LstBoxFrm.LstBox.AddItem " Previous Prescription:  " & GetField(patds!ModRegName) & ", " & GetField(patds!PrescModDate) & ", " & GetField(patds!PrescModUser)
''               LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -1
''            End If
''
''         '31Mar97 CKJ Added new prescription
''         LstBoxFrm.LstBox.AddItem " Enter New Prescription"
''         LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -2
''
''         Do While Not regss.EOF
''            keep = True
''            rule$ = GetField(regss!RuleSQL)
''            If rule$ <> "" Then
''                  SQLq = "SELECT * FROM Blackboard WHERE ID=1 AND (" & rule$ & ");"
''                  If SQLdbg Then popmessagecr "SQL", SQLq
''
''                  keep = True
''                  On Error GoTo CheckRulesStdProForma_Err
''                  Set BBds = patdb.CreateDynaset(SQLq)    'only one matching row
''                  If BBds.EOF Then keep = False           'rule did not fire - it was false
''NextRule1:
''                  On Error GoTo 0
''               End If
''
''            If keep Then
''                  Txt$ = " " & GetField(regss("Description"))
''                  replace Txt$, ":", TB, 0
''                  LstBoxFrm.LstBox.AddItem Txt$
''                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(regss("RuleID"))
''               End If
''            regss.MoveNext
''         Loop
''
''         If AgeInYears! > 1 Then
''               Txt$ = "Age: " & Format$(AgeInYears!, "0.#") & " years" & cr
''            ElseIf AgeInDays& > 0 Then
''               Txt$ = "Age: " & Format$(AgeInDays&, "0.#") & " days" & cr
''            End If
''         If heightcms! Then Txt$ = Txt$ & "Height: " & Format$(heightcms!) & " cm" & cr
''         If weight! Then Txt$ = Txt$ & "Weight: " & Format$(weight!) & " kg" & cr
''         LstBoxFrm.lblTitle = cr & Txt$
''
''         Screen.MousePointer = STDCURSOR
''         'k.helpnum = 105
''         LstBoxShow
''         If LstBoxFrm.LstBox.ListIndex <> -1 Then
''               result = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
''            Else
''               k.escd = True
''            End If
''         Unload LstBoxFrm
''      'Else                                       '31Mar97 CKJ Always offer New Prescription
''      '   k.escd = True
''      '   screen.MousePointer = stdcursor
''      '   popmessagecr "Warning", "No standard prescription proformas have been found"
''      'End If
''Exit Sub
''
''CheckRulesStdProForma_Err:
''Resume NextRule1

End Sub

Sub ClearBlobs()
'''21Sep98 CKJ written
'''            This procedure clears the array whih holds the last amended lines
'''            NB no visible effect until AdjPrint is next called
'''            Originally -1 was used as the unused indicator but this is mow in the range for
'''            other infusions. Therefore changed to 32767
'''
'''
''Dim item%
''
''   For item = 0 To 3
''      ModIg(item) = 32767
''   Next

End Sub

Sub ClearPatientDetails()
'Blank all patient details - PID, clinical, regimen, prescription
'Call once main arrays have been zeroed - esp ig()
'22Oct97 CKJ Changed IIF to Iff

Dim afm%

   calctotals ""                         'reset tot!, TotAmino, TotLipid, TotGlucA

   PrescriptionID& = 0
   
   AgeInDays& = 0
   AgeInYears! = 0
                             
''   Clin.CardiacFailure = 0               'Clinical details page
''   Clin.RenalFailure = 0
''   Clin.Haemodialysis = 0
''   Clin.PeritonealDialysis = 0
''   Clin.Haemofiltration = 0
''   Clin.Septicaemia = 0
''   Clin.FulmHepaticFailure = 0
''   Clin.BiliOver100unconj = 0
''   Clin.BiliOver170unconj = 0
''   Clin.Phototherapy = 0
''   Clin.RadiantHeat = 0
''   Clin.Diuretics = 0
''   Clin.SerumSodiumCategory = 0
''   Clin.SerumPotassiumCategory = 0
                             
   weight = 0
   dob = ""
   AgeInDays = 0
   AgeInYears = 0
   PatientName = ""
   origdate = ""

   inf = 0
   heightcms = 0

   CN$ = ""
   DR$ = ""
   df$ = ""
   CP$ = ""
   rd$ = ""
   feedlength$ = ""
   REA$ = ""
   BodyTemp$ = ""
   AF$ = ""
   ifact$ = ""
   OtherFluids = 0
   regname$ = ""
   batchnumber$ = ""
              
   lblscombined = Not tpndef.seplabels
   afm = Iff(lblscombined, 3, 1)          '22Oct97 CKJ Changed IIF to Iff
   infratefat% = tpndef.infusehrs(2)
   infrateamino% = tpndef.infusehrs(afm)
   expiryB$ = tpndef.expiry(2)
   expiryA$ = tpndef.expiry(afm)
   ncwa% = 0
   ncwf% = 0
   wardexp$ = ""
   consexp$ = ""
   
   dayofwk$ = ""
   totK! = 0
   totNa! = 0
   NaCategory% = 0
   KCategory% = 0

End Sub

Sub defregstring(regname$, origdate$, regstring$)
'13Aug98 CKJ Improved display of dates using PNdate$
'            Removed regname and origdate param as already in scope

'17Jan12 TH PORT - Not sure what this does

popmessagecr "", "defregstring"

''Dim ModNum%, PNdate$
''
''   If Len(RTrim$(regname$)) Then
''         regstring$ = Trim$(regname$)
''      Else
''         regstring$ = "Un-named"
''      End If
''
''   PNdate$ = Trim$(origdate$)                                         '13Aug98 CKJ block added
''   If TPNchanged Then PNdate$ = ""
''   If Len(PNdate$) Then
''         PNdate$ = Left$(PNdate$, 2) & "/" & Mid$(PNdate$, 3, 2) & "/" & Mid$(PNdate$, 5)
''      End If
''
''   If GetField(patds!ModNum) = 0 Then
''         'regstring$ = regstring$ + " started on " + Left$(origdate$, 2) + "/" + Mid$(origdate$, 3, 2) + "/" + Mid$(origdate$, 5, 2) + " (no mods.)"
''         If Len(PNdate$) Then regstring$ = regstring$ & " started on " & PNdate$  '13Aug98 CKJ
''         regstring$ = regstring$ & Iff(TPNchanged, " (mod 1)", " (no mods.)")
''      Else
''         'regstring$ = regstring$ + " Authorised on " + Left$(origdate$, 2) + "/" + Mid$(origdate$, 3, 2) + "/" + Mid$(origdate$, 5, 2)
''         If Not TPNchanged Then regstring$ = regstring$ & " Authorised"           '13Aug98 CKJ
''         If Len(PNdate$) Then regstring$ = regstring$ & " " & PNdate$
''
''         'modnum = CVI(Mid$(origdate$, 7, 2))
''         ' fiddle for old patients before facility
''         ' surely this needs changing? CKJ 12Oct91
''         ' CKJ 20Oct91 changed from >100 to >=100
''         '8Jan96 CKJ Discussed; retain this functionality, ie max 99
''         ModNum = GetField(patds!ModNum) - (TPNchanged = True)           '13Aug98 Add 1 if edited
''         'If modnum >= 100 Then modnum = 0
''         regstring$ = regstring$ & " (mod " & Format$(ModNum) & ")"
''      End If

End Sub

Sub DeleteItem()
'12Jun98 CKJ Extended functionality to handle fixed rows and to prompt PN/enteral/infusion
   
''Dim LN%, ans$, Row As Integer, desc$      '01Jun02 All/CKJ added as integer to Row
''
''   If Not TpnVO Then
''         desc$ = ""
''         Row = frmVA.tgdVA.RowIndex
''         Select Case Row
''            Case Is <= RowsUsed
''               desc$ = "PN"
''            Case RowsUsed + 1, RowsUsed + 2, EnteralRow, InfusionRow
''            Case Is < InfusionRow 'ie is between enteral & infusion rows
''               desc$ = "Enteral"
''            Case Is < GrandTotRow 'ie is between infusion row and grand total
''               desc$ = "other Infusion"
''            Case ScriptRow
''            Case Else
''            End Select
''         If Len(desc$) Then
''               LN = Val(VAxy(0, frmVA.tgdVA.RowIndex))
''               ans$ = "Y"
''               Confirm "Delete line", "remove " & desc$ & " product " & Prd(LN).name & " from regimen", ans$, k
''               If ans$ = "Y" And Not k.escd Then
''                     ans$ = ""
''                     RememberK
''                     RememberNa
''                     ig(LN) = 0
''                     AskAdjustNa LN
''                     AskAdjustK LN
''                     TPNchanged = True
''                     AdjPrint
''                  End If
''            Else
''               popmessagecr "", "Highlight the line required before deleting a product"
''            End If
''      End If

End Sub

Sub editdefaults(recno%, df As tpndefaults, Changed)
''' 3Jul97 CKJ Adult overage=0, non-editable
'''16Sep98 CKJ Added Val() to the numeric fields - needed for VBtools6
'''17Sep98 CKJ Reversefeed not used anymore
'''30Mar99 CKJ Copied 8.07 mod:
'''            22Feb99 CKJ Changed Str$() to Format$() as leading space caused truncation
''
'''10 lines; 7xTF 2x1,2,3 1xTF
'''gap
''' 5 lines for amino; nn nn n nn nn
'''gap
''' 5 lines for fat
'''gap
''' 5 lines for mixed
''
''Dim maxlines%, i%, afm%
''
''
''   If recno = 1 Then Ques.Caption = tp("DefPaed") Else Ques.Caption = tp("DefAdult")
''   QuesCallbackMode = 3
''   maxlines = 28
''
''   For i = 1 To maxlines
''      Select Case i                            'create controls
''         Case 4:          QuesMakeCtrl i, 0    '17Sep98 CKJ Reversefeed not used anymore
''         Case 8, 9, 10:   QuesMakeCtrl i, 0    '11Jul98 CKJ Printers not set here now
''         Case 11, 17, 23: QuesMakeCtrl i, 0    'labels only
''         Case Else:       QuesMakeCtrl i, 1    'txt box
''         End Select
''
''      Select Case i                            'set labels
''         Case 4                                '17Sep98 CKJ Reversefeed not used anymore
''         Case 8, 9, 10                         '11Jul98 CKJ Printers not set here now
''         Case 1 To 17, 23
''            Ques.lblDesc(i) = tp("defL" & Format$(i))
''            Ques.lblInfo(i) = tp("defR" & Format$(i))
''         Case 18 To 22
''            Ques.lblDesc(i) = tp("defL" & Format$(i - 6))
''            Ques.lblInfo(i) = tp("defR" & Format$(i - 6))
''         Case 24 To 28
''            Ques.lblDesc(i) = tp("defL" & Format$(i - 12))
''            Ques.lblInfo(i) = tp("defR" & Format$(i - 12))
''         End Select
''   Next
''                        '1-10
''   QuesSetCtrl Ques.txtQ(1), 2, 0, Str$(df.seplabels)
''   QuesSetCtrl Ques.txtQ(2), 2, 0, Str$(df.infusionrate)
''   QuesSetCtrl Ques.txtQ(3), 2, 0, Str$(df.dropspermin)
''   'QuesSetCtrl Ques.txtQ(4), 2, 0, Str$(df.printreversefeed)  '17Sep98 CKJ Not used anymore
''   QuesSetCtrl Ques.txtQ(5), 2, 0, Str$(df.issueenabled)
''   QuesSetCtrl Ques.txtQ(6), 2, 0, Str$(df.returnenabled)
''   QuesSetCtrl Ques.txtQ(7), 2, 0, Str$(df.baxapump)
''   'QuesSetCtrl Ques.txtQ(8), 1, 1, Str$(df.plainprinter)  '11Jul98 CKJ Printers not set here now
''   'QuesSetCtrl Ques.txtQ(9), 1, 1, Str$(df.labelprinter)      "
''   'QuesSetCtrl Ques.txtQ(10), 2, 0, Str$(df.labels4inches)    "
''
''   For afm = 1 To 3        '12-16 18-22 24-28
''      If recno = 2 Then                       '3Jul97 CKJ Adult overage=0, non-editable
''            df.overagevol(afm) = 0
''            Ques.txtQ(6 + afm * 6).Enabled = False
''         End If
''      QuesSetCtrl Ques.txtQ(6 + afm * 6), 1, 3, Format$(df.overagevol(afm))   '3   '22Feb99 CKJ Was Str$(), but leading space caused truncation
''      QuesSetCtrl Ques.txtQ(7 + afm * 6), 1, 2, Format$(Val(df.Expiry(afm)))  '2   '   "
''      QuesSetCtrl Ques.txtQ(8 + afm * 6), 1, 1, Format$(df.numlabels(afm))    '1   '   "
''      QuesSetCtrl Ques.txtQ(9 + afm * 6), 1, 2, Format$(df.infusehrs(afm))    '2   '   "
''      QuesSetCtrl Ques.txtQ(10 + afm * 6), 1, 2, Format$(df.dropsperml(afm))  '2   '   "
''   Next
''
''   If TpnVO Then
''         Ques.cmdOK.Visible = False
''         Ques.cmdOK.Enabled = False
''      End If
''
''   Ques.HelpContextID = 5130
''
''   QuesCallbackMode = 3
''   QuesShow maxlines
''   QuesCallbackMode = 0
''
''   If Ques.Tag = "-1" Then
''         df.seplabels = TrueFalse((Ques.txtQ(1)))
''         df.infusionrate = TrueFalse((Ques.txtQ(2)))
''         df.dropspermin = TrueFalse((Ques.txtQ(3)))
''         'df.printreversefeed = TrueFalse((Ques.txtQ(4))) '17Sep98 CKJ Not used anymore
''         df.issueenabled = TrueFalse((Ques.txtQ(5)))
''         df.returnenabled = TrueFalse((Ques.txtQ(6)))
''         df.baxapump = TrueFalse((Ques.txtQ(7)))
''         'df.plainprinter = Ques.txtQ(8)                  '11Jul98 CKJ Printers not set here now
''         'df.labelprinter = Ques.txtQ(9)                      "
''         'df.labels4inches = TrueFalse((Ques.txtQ(10)))       "
''
''         For afm = 1 To 3                  '12-16 18-22 24-28
''            df.overagevol(afm) = Val(Ques.txtQ(6 + afm * 6))                   '16Sep98 CKJ Val()
''            Mid$(df.Expiry(afm), 1, 2) = Format$(Ques.txtQ(7 + afm * 6), "00")
''            df.numlabels(afm) = Val(Ques.txtQ(8 + afm * 6))                    '   "
''            df.infusehrs(afm) = Val(Ques.txtQ(9 + afm * 6))                    '   "
''            df.dropsperml(afm) = Val(Ques.txtQ(10 + afm * 6))                  '   "
''         Next
''         Changed = True
''      End If
''
''   Unload Ques
''
''   '  Select Case num
''   '     Case 0
''   '        If k.escd And changed Then
''   '              k.helpnum = 110
''   '              confirm "!n!b" + tp("DefMod"), tp("ExitNo"), ans$, k
''   '              If ans$ = getYN(1) Then
''   '                    changed = False
''   '                    done = True
''   '                 End If
''   '           ElseIf k.escd Or k.exitval = 13 Then
''   '              done = True
''   '           End If

End Sub

Sub EnterDetails()
'''29Sep91 CKJ This section heavily modified, Adult & Paed merged to one routine
'''27Dec95 CKJ Moved to proc from module level code
'''26Oct98 CKJ Altered capitalisation of clinical data captions
''
''Dim i As Integer, maxlines%
''
'''1¦dtw1 ="Consultant name"
'''2¦dtw6 ="Name of requesting doctor"
'''3¦dtw2 ="Date of request for feeding   (T=today)"
'''4¦dtw3 ="Date feeding commenced        (T=today)"
'''5¦dtw5 ="Expected duration of feeding in days"
'''6¦dtw8 ="Body temperature  (deg Centigrade)"
'''7¦dtw9 ="Activity factor"
'''8¦dtw10="Injury factor"
'''9¦dtw11="Comment"
''
''   Ques.Caption = "Clinical Details"
''
''   If adult(pid.sex) Then
''         maxlines = 11
''      Else
''         maxlines = 28
''      End If
''
''   NaCategory = Clin.SerumSodiumCategory
''   KCategory = Clin.SerumPotassiumCategory
''
''   For i = 1 To maxlines
''      Select Case i
''         Case 3, 7, 9, 11:     '                     'none
''         Case 18, 23, 24: QuesMakeCtrl i, 0     'label only
''         Case 14, 15:     QuesMakeCtrl i, 2     'cmd button
''         'Case 38, 39:    QuesMakeCtrl i, 3     'list box
''         Case Else:       QuesMakeCtrl i, 1     'txt box
''         End Select
''
''      Select Case i
''         Case 3, 7, 9, 11
''         Case 1 To 11: Ques.lblDesc(i) = Trim$(tp("dtw" & Trim$(Str$(i))))
''         Case 12:      Ques.lblDesc(i) = "Radiant Heat"                     '26Oct98 CKJ Altered capitalisation of these items
''         Case 13:      Ques.lblDesc(i) = "Phototherapy"
''         Case 14:      Ques.lblDesc(i) = "Serum Sodium"
''         Case 15:      Ques.lblDesc(i) = "Serum Potassium"
''         Case 16:      Ques.lblDesc(i) = "Cardiac Failure"
''         Case 17:      Ques.lblDesc(i) = "Diuretic Therapy"
''         Case 18:      Ques.lblDesc(i) = "Renal Function:"
''         Case 19:      Ques.lblDesc(i) = "    Haemodialysis"
''         Case 20:      Ques.lblDesc(i) = "    Peritoneal Dialysis"
''         Case 21:      Ques.lblDesc(i) = "    Haemofiltration"
''         Case 22:      Ques.lblDesc(i) = "    Renal Failure"
''         Case 23:      Ques.lblDesc(i) = "Hepatic Function:"
''         Case 24:      Ques.lblDesc(i) = "    Unconjugated Serum Bilirubin"
''         Case 25:      Ques.lblDesc(i) = "        100 to 170 micromol/l"
''         Case 26:      Ques.lblDesc(i) = "        over 170 micromol/l"
''         Case 27:      Ques.lblDesc(i) = "    Fulminant Hepatic Failure"
''         Case 28:      Ques.lblDesc(i) = "Septicaemia"
''         'Case 17:      Ques.lblDesc(i) = "Ventilation"
''         'BiliOver100unconj As Integer   '0/-1
''         'BiliOver170unconj As Integer   '0/-1
''         End Select
''
''      'k.helpnum = 10
''      Select Case i
''         Case 1:  QuesSetCtrl Ques.txtQ(i), 0, 15, RTrim$(CN$)
''         Case 2:  QuesSetCtrl Ques.txtQ(i), 0, 15, rd$
''         Case 3:
''         'Case 4:  QuesSetCtrl Ques.txtQ(i), 0, 8, RTrim$(DR$)          '22Sep98 CKJ widened
''         Case 4:  QuesSetCtrl Ques.txtQ(i), 0, 10, RTrim$(DR$)          '   "          "
''         'Case 5:  QuesSetCtrl Ques.txtQ(i), 0, 8, df$                  '   "          "
''         Case 5:  QuesSetCtrl Ques.txtQ(i), 0, 10, df$                  '   "          "
''         Case 6:  QuesSetCtrl Ques.txtQ(i), 1, 3, Trim$(feedlength$)
''         Case 7:
''         Case 8:  QuesSetCtrl Ques.txtQ(i), 10, -1, Trim$(BodyTemp$)
''         Case 10: QuesSetCtrl Ques.txtQ(i), 0, 50, Trim$(REA$)
''         Case 18, 23, 24 'nothing
''
''         'Case 9:  QuesSetCtrl Ques.cmdQ(i), 0, 0, tp("af" & Format$(Val(AF$)))
''         'Case 10: QuesSetCtrl Ques.cmdQ(i), 0, 0, tp("if" & Format$(Val(ifact$)))
''         'Case 38
''         '   Ques.cmbQ(i).AddItem ""
''         '   Ques.cmbQ(i).AddItem "Below 100 micromols per litre"
''         '   Ques.cmbQ(i).AddItem "100 to 170 micromols per litre"
''         '   Ques.cmbQ(i).AddItem "Above 170 micromols per litre"
''         'Case 39
''         '   Ques.cmbQ(i).AddItem ""
''         '   Ques.cmbQ(i).AddItem "Conjugated"
''         '   Ques.cmbQ(i).AddItem "Unconjugated"
''         'Case 12 To 40   'yes/no box
''           'QuesSetCtrl Ques.txtQ(i), 2, -1, ""
''         Case 12: QuesSetCtrl Ques.txtQ(i), 2, -1, Str$(Clin.RadiantHeat)
''         Case 13: QuesSetCtrl Ques.txtQ(i), 2, -1, Str$(Clin.Phototherapy)
''         Case 14: QuesSetCtrl Ques.cmdQ(i), 0, 0, tp("NaQ" & Format$(NaCategory))
''         Case 15: QuesSetCtrl Ques.cmdQ(i), 0, 0, tp("KQ" & Format$(KCategory))
''         Case 16: QuesSetCtrl Ques.txtQ(i), 2, -1, Str$(Clin.CardiacFailure)
''         Case 17: QuesSetCtrl Ques.txtQ(i), 2, -1, Str$(Clin.Diuretics)
''
''         Case 19: QuesSetCtrl Ques.txtQ(i), 2, -1, Str$(Clin.Haemodialysis)
''         Case 20: QuesSetCtrl Ques.txtQ(i), 2, -1, Str$(Clin.PeritonealDialysis)
''         Case 21: QuesSetCtrl Ques.txtQ(i), 2, -1, Str$(Clin.Haemofiltration)
''         Case 22: QuesSetCtrl Ques.txtQ(i), 2, -1, Str$(Clin.RenalFailure)
''
''         Case 25: QuesSetCtrl Ques.txtQ(i), 2, -1, Str$(Clin.BiliOver100unconj)
''         Case 26: QuesSetCtrl Ques.txtQ(i), 2, -1, Str$(Clin.BiliOver170unconj)
''         Case 27: QuesSetCtrl Ques.txtQ(i), 2, -1, Str$(Clin.FulmHepaticFailure)
''         Case 28: QuesSetCtrl Ques.txtQ(i), 2, -1, Str$(Clin.Septicaemia)
''
''         End Select
''   Next
''
''   If Not SlavemodeEnabled() Then                        '10nov03 ckj
''         Ques.lblInfo(1) = "Press [Shift][F1] for list"
''      End If
''
''   Ques.lblInfo(4) = "Enter date, T=today, Y=yesterday"   '12Aug98 CKJ Added
''   Ques.lblInfo(5) = Ques.lblInfo(4)                      '   "
''
''   If TpnVO Then
''         Ques.cmdOK.Visible = False
''         Ques.cmdOK.Enabled = False
''      End If
''
''   On Error Resume Next
''   For i = 0 To Ques.Controls.Count - 1
''      Ques.Controls(i).HelpContextID = 5010
''   Next
''   On Error GoTo 0
''
''   QuesCallbackMode = 1
''   QuesShow maxlines
''   QuesCallbackMode = 0
''
''   If Ques.Tag = "-1" Then
''         CN$ = Ques.txtQ(1).Text
''         rd$ = Ques.txtQ(2).Text
''         DR$ = Ques.txtQ(4).Text
''         df$ = Ques.txtQ(5).Text
''         feedlength$ = Ques.txtQ(6).Text
''         BodyTemp$ = Ques.txtQ(8).Text
''         REA$ = Ques.txtQ(10).Text
''
''         If Not adult(pid.sex) Then
''               Clin.SerumSodiumCategory = NaCategory
''               Clin.SerumPotassiumCategory = KCategory
''               Clin.RadiantHeat = TrueFalse((Ques.txtQ(12).Text))
''               Clin.Phototherapy = TrueFalse((Ques.txtQ(13).Text))
''               Clin.CardiacFailure = TrueFalse((Ques.txtQ(16).Text))
''               Clin.Diuretics = TrueFalse((Ques.txtQ(17).Text))
''               Clin.Haemodialysis = TrueFalse((Ques.txtQ(19).Text))
''               Clin.PeritonealDialysis = TrueFalse((Ques.txtQ(20).Text))
''               Clin.Haemofiltration = TrueFalse((Ques.txtQ(21).Text))
''               Clin.RenalFailure = TrueFalse((Ques.txtQ(22).Text))
''               Clin.BiliOver100unconj = TrueFalse((Ques.txtQ(25).Text))
''               Clin.BiliOver170unconj = TrueFalse((Ques.txtQ(26).Text))
''               Clin.FulmHepaticFailure = TrueFalse((Ques.txtQ(27).Text))
''               Clin.Septicaemia = TrueFalse((Ques.txtQ(28).Text))
''            End If
''         TPNchanged = True
''         RegStatus
''      End If
''
''   Unload Ques

End Sub

Sub EnterGlucoseByRate()
'18Jul00 CKJ Code moved from mnuGlucose_Click to allow use of kcalPerGramGlucose

''Dim totGlperkg$
''Dim volof!
''
''   totGlperkg$ = VAxy(5, RowsUsed + 2)
''   EnterGlucoseRate totGlperkg$
''   If totGlperkg$ <> VAxy(5, RowsUsed + 2) Then
''         volof! = Val(VAxy(2, RowsUsed + 1))
''         'mixglucose volof!, Val(totGlperkg$) * Val(pid.weight) * 4 'grams Gl per kg per 24 hrs  *  weight in kg  *  calories per gram Gl
''         mixglucose volof!, Val(totGlperkg$) * Val(pid.weight) * kcalPerGramGlucose! 'grams Gl per kg per 24 hrs  *  weight in kg  *  calories per gram Gl
''      End If

End Sub

Sub EnterGlucoseRate(totGlperkg$)
'20Mar98 CKJ Added

''Dim ans$, ttl$, Txt$, Glrate!
''
''   ans$ = Trim$(tsf$(Val(totGlperkg$) * 1000 / 1440))
''   ttl$ = "Amend Glucose"
''   Txt$ = Txt$ & "The patient's weight is recorded as " & Trim$(pid.weight) & " kg" & cr
''   If Val(ans$) Then
''         Txt$ = Txt$ & totGlperkg$ & "g glucose in 24 hrs would be " & ans$ & " mg/kg/min" & cr
''     End If
''   Txt$ = Txt$ & cr & "Enter Glucose as rate per minute  (mg/kg/min)"
''   k.nums = True
''   k.decimals = True
''   k.min = 1
''   k.Max = 4
''   inputwin ttl$, Txt$, ans$, k
''   If Not k.escd Then
''         If Val(ans$) Then
''               Glrate! = Val(ans) * 1440 / 1000                'mg/kg/min * 1440 /1000
''               totGlperkg$ = tsf$(Glrate!)
''            End If
''      End If
    
End Sub

Sub EnterNitrogenasAA(totNitrogenperkg$)
'31Aug98 CKJ Added
'            Enter Nitrogen as grams Amino Acid, using assumed conversion of 6.25gAA==1gN

''Dim ans$, ttl$, Txt$, gNgAA$
''
''   gNgAA$ = "6.25"                                           'This could be user configurable
''
''   ans$ = Trim$(tsf$(Val(totNitrogenperkg$) * Val(gNgAA$)))
''   ttl$ = "Amend Nitrogen"
''   Txt$ = "Amend Nitrogen as grams Amino Acid (using ratio of 1g N = " & gNgAA$ & "g AA)" & cr
''   If Val(ans$) Then
''         Txt$ = Txt$ & totNitrogenperkg$ & "g Nitrogen in 24 hrs would be " & ans$ & " g Amino Acid" & cr
''     End If
''   Txt$ = Txt$ & cr & "Enter grams of Amino Acid per kg per 24 hrs"
''   k.nums = True
''   k.decimals = True
''   k.min = 1
''   k.Max = 4
''   inputwin ttl$, Txt$, ans$, k
''   If Not k.escd Then
''         If Val(ans$) Then totNitrogenperkg$ = tsf$(Val(ans) / Val(gNgAA$))
''      End If
    
End Sub

''Sub FillBlackboardPIDClinical(PerKg$, BBds As Dynaset)
'''05Jun00 CKJ Added extra fields from PID; ward, cons, status. No error here if absent, but will error if SQL is executed.
''
''Dim i%
''
''   If Adult(pid.sex) Then PerKg$ = "0" Else PerKg$ = "-1"
''
''   'Now fill the Blackboard with current data
''   BBds.Edit
''   For i = 0 To BBds.Fields.Count - 1  'clear all fields
''      On Error Resume Next
''      BBds.Fields(i) = ""
''      On Error GoTo 0
''   Next
''
''   BBds!infuseCPE = Left$(CP$ + " ", 1)
''   BBds!TPNtotdays = Val(feedlength$)
''   BBds!BodyTemp = Val(BodyTemp$)
''   'patds!ActiveFact = AF$                                    'not for paeds
''   'patds!InjuryFact = ifact$                                 'not for paeds
''   BBds!OtherFluids = OtherFluids
''   BBds!combined = lblscombined
''   BBds!HrsAminoInf = infrateamino
''   BBds!HrsLipidInf = infratefat
''
''   BBds!CardiacFailure = Clin.CardiacFailure                  '0/-1
''   BBds!RenalFailure = Clin.RenalFailure                      '0/-1
''   BBds!Haemodialysis = Clin.Haemodialysis                    '0/-1
''   BBds!PeritonealDialysis = Clin.PeritonealDialysis          '0/-1
''   BBds!Haemofiltration = Clin.Haemofiltration                '0/-1
''   BBds!Septicaemia = Clin.Septicaemia                        '0/-1
''   BBds!FulmHepaticFailure = Clin.FulmHepaticFailure          '0/-1
''   BBds!BiliOver100unconj = Clin.BiliOver100unconj            '0/-1
''   BBds!BiliOver170unconj = Clin.BiliOver170unconj            '0/-1
''   BBds!Phototherapy = Clin.Phototherapy                      '0/-1
''   BBds!RadiantHeat = Clin.RadiantHeat                        '0/-1
''   BBds!Diuretics = Clin.Diuretics                            '0/-1
''   BBds!SerumSodiumCategory = Clin.SerumSodiumCategory        '0 to 5
''   BBds!SerumPotassiumCategory = Clin.SerumPotassiumCategory  '0 to 5
''
''   BBds!AgeInDays = AgeInDays&       'age
''   BBds!AgeInYears = AgeInYears!     'age as years to several dp
''   BBds!Heightcm = heightcms!        'height in cms
''   BBds!Weightkg = weight!           'weight in kg
''   BBds!sex = UCase$(pid.sex)        'sex
''
''   On Error Resume Next                                       '05Jun00 CKJ Added extra fields. No error here if absent,
''   BBds!wardcode = Trim$(pid.ward)                            '   "        but will error if SQL is executed
''   BBds!ConsCode = Trim$(pid.cons)                            '   "
''   BBds!PIDstatus = UCase$(pid.status)                        '   "
''   On Error GoTo 0                                            '   "
''
''
''End Sub

''Sub FillBlackboardPrescription(SCxyRow%, BBds As Dynaset)
'''Set SCxyRow to  1          for the first row, ie standard proforma
'''                RowsUsedSC for the last  row, ie amended prescription, total volumes
'''                0          for the stored, confirmed prescription
''Dim mOsmperL!, missing%, SolIdx!
''
''   If SCxyRow >= 1 Then
''         BBds!PrescriptionVolume = Val(SCxy(2, SCxyRow))
''         BBds!PrescriptionNitrogen = Val(SCxy(3, SCxyRow))
''         BBds!PrescriptionGlucose = Val(SCxy(4, SCxyRow))
''         BBds!PrescriptionFat = Val(SCxy(5, SCxyRow))
''         BBds!PrescriptionSodium = Val(SCxy(6, SCxyRow))
''         BBds!PrescriptionPotassium = Val(SCxy(7, SCxyRow))
''         BBds!PrescriptionCalcium = Val(SCxy(8, SCxyRow))
''         BBds!PrescriptionMagnesium = Val(SCxy(9, SCxyRow))
''         BBds!PrescriptionZinc = Val(SCxy(10, SCxyRow))
''         BBds!PrescriptionPhosphate = Val(SCxy(11, SCxyRow))
''         BBds!PrescriptionSelenium = Val(SCxy(12, SCxyRow))
''         BBds!PrescriptionCopper = Val(SCxy(13, SCxyRow))
''         BBds!PrescriptionIron = Val(SCxy(14, SCxyRow))                   '11Apr98 CKJ added
''         'BBds!PrescriptionAquVitamins = Val(SCxy(14, SCxyRow))           '   "
''         'BBds!PrescriptionFatVitamins = Val(SCxy(15, SCxyRow))           '   "
''         BBds!PrescriptionAquVitamins = Val(SCxy(15, SCxyRow))
''         BBds!PrescriptionFatVitamins = Val(SCxy(16, SCxyRow))
''
''      ElseIf GetField(patds!prescribed) Then
''         BBds!PrescriptionVolume = tsf$(GetField(patds!ScriptVol))
''         BBds!PrescriptionNitrogen = tsf$(GetField(patds!ScriptN))
''         BBds!PrescriptionGlucose = tsf$(GetField(patds!ScriptGlu))
''         BBds!PrescriptionFat = tsf$(GetField(patds!ScriptFat))
''         BBds!PrescriptionSodium = tsf$(GetField(patds!ScriptNa))
''         BBds!PrescriptionPotassium = tsf$(GetField(patds!ScriptK))
''         BBds!PrescriptionCalcium = tsf$(GetField(patds!ScriptCa))
''         BBds!PrescriptionMagnesium = tsf$(GetField(patds!ScriptMg))
''         BBds!PrescriptionZinc = tsf$(GetField(patds!ScriptZn))
''         BBds!PrescriptionPhosphate = tsf$(GetField(patds!ScriptPO4))
''         BBds!PrescriptionSelenium = tsf$(GetField(patds!ScriptSe))
''         BBds!PrescriptionCopper = tsf$(GetField(patds!ScriptCu))
''         BBds!PrescriptionIron = tsf$(GetField(patds!ScriptFe))           '11Apr98 CKJ added
''         BBds!PrescriptionAquVitamins = tsf$(GetField(patds!ScriptAVit))
''         BBds!PrescriptionFatVitamins = tsf$(GetField(patds!ScriptLVit))
''         CheckCaPO4Solubility SolIdx!
''         BBds!CalciumPhosphateSolubility = SolIdx!
''         Osmolality mOsmperL!, missing, ""                                '11Aug98 CKJ added param
''         BBds!Osmolality = mOsmperL!
''
''      End If
''
''End Sub

Sub FillPrintHeapPN()
'17Jan95 CKJ Copied from ParseCtrlChars, but uses local data items
'16Apr98 CKJ Copied from ParseTPNdataItems, but now fills global printing heap
'            Call this once before printing PN stuff to ensure data is refreshed
'06Aug98 CKJ corrected "totmla3sf" and "totmlb3sf" which were always set as if separate A/B
'            bags were being made. Now set to total and 0 respectively for combined regimen
'            Also added "overagea" and "overageb"
'26Aug98 CKJ Added [Osmolality] -> xyz mOsmol per kg water (Caution: Data not known for 3 products)
'            Added [Gluc:mg/kg/min] -> xyz  or  ----  if any data is absent
'20Oct98 CKJ Added 'not applicable' to [infrateA] and [infrateB] if volume is zero. This is for
'            use on script/insert for notes. Removed the [cr] at the end of this line, as this
'            should be in the layout file.
'19Nov98 CKJ Osmolality limited to 3sf
'20Nov98 CKJ/CFY patname/patname21 now aware of ascribe.ini [PID] surnameforename setting
'09Apr99 CKJ WSmixigs & WSmix/kg both fill worksheet lines PNWS1, PNWS2 etc, so must be called
'            just once otherwise second call overwrites results of the first. Incorrect usage
'            of keyword now prints an error message on the worksheet.
'02Jun99 CKJ Avoid Div by 0 calculating Na, K and Gluc conc in aqueous portion
'16Feb00 CKJ Item "weight" changed from eg ".8kg           " to "0.8kg"
'05Jun00 CKJ Added weight of bags
'18Jul00 CKJ Batch mode mods. Data items which cannot be used in batch mode show as 'N/A' or 'Not available'
'14Feb02 ATW ENHDB 1511 ; Changed to return 1DP only on TPN infusion rates.
'30Mar04 CKJ {SP1} Removed superluous param success%
'12May15 XN Ensured there is a leading 0 on dosingweight < 1Kg 118106
'02Jun15 XN Added missing print elements 120001 kcalpergN, modtextshort, regimen30, regimennomodtext, regimennomodtext30, pharmacytext, reqdoc
'24Sep15 XN  77778 Add all the aliases to the heap
'29Oct15 XN 133714 Use the case number from the xml by default
'02Jun16 XN 154627 added infrateb_full
'29Nov17 KR 199184 fixed doseweight printing format when a whole number
'Static freetxt$
Dim char$, noi%, X%, tmp$, w!, kg$, baxapath$, batchNoA$, batchNoLip$, batchNoMixed$
Dim Tvols$, Tvolv!, afm%, drpspermin%, ans$
Dim gGluc!, mOsmperkgH2O!, missing%, SolIdx!
Dim kcalFat!, kcalCHO!, FatCHOratio$
Dim TotWtOvgA$, TotWtOvgB$                                        '05Jun00 CKJ Added
Dim strOneSigInfusion As String
Dim strThreeSigInfusion As String
Dim xmldoc As MSXML2.DOMDocument
Dim xmlElement As MSXML2.IXMLDOMElement
Dim xmlnode As MSXML2.IXMLDOMElement
Dim strAdminDate As String
Dim iBaxaInterfaceType As Integer
Dim fileType As String

   Screen.MousePointer = HOURGLASS
   ''CalcOverage
   
   '07Feb12 TH Load the xml Here and push to heap
   Set xmldoc = New MSXML2.DOMDocument
   If Not xmldoc.loadXML(GetPNPrintXML()) Then
      popmessagecr "", "Could not load PN Printing Information"
   Else
   Set xmlElement = xmldoc.selectSingleNode("//PNPrintData")
      'Set xmlnode = XMLelement.selectSingleNode("patname")
    '  MsgBox xmlElement.selectSingleNode("patname").Text
         
 '  Next
   
   
   Heap 23, gPRNheapID, "", "", 0                                 '15Sep98 CKJ Set Redraw off

   'Heap 10, gPRNheapID,  "hospname1":  char$ = pad$(hospname1$, 40)
   'Heap 10, gPRNheapID,  "hospname2":  char$ = pad$(hospname2$, 25)
   'Heap 10, gPRNheapID,  "hospabbr":    char$ = hospabbr$
   'Heap 10, gPRNheapID,  "userid":     char$ = userid$             '24Oct96 CKJ new
   'Heap 10, gPRNheapID,  "username":   char$ = UserFullName$       '   "
   'Heap 10, gPRNheapID,  "today":      char$ = td$
   'Heap 10, gPRNheapID,  "timenow":    char$ = Format$(Now, "hh:mm am/pm")
   Heap 10, gPRNheapID, "patname", pad$(PatientName$, 36), 0
   'Heap 10, gPRNheapID, "patname21", pad$(patientname$, 21), 0     '20Nov98 CKJ/CFY removed
   buildname pid, False, tmp$                                       '   "            allows 'sn, fn' style but
   Heap 10, gPRNheapID, "patname21", tmp$, 0                        '   "            currently limits to 25 chars max
   'Heap 10, gPRNheapID, "dob", pad$(dob$, 15), 0
   If InStr(xmlElement.xml, "dob") Then Heap 10, gPRNheapID, "dob", xmlElement.selectSingleNode("dob").text, 0
   'Heap 10, gPRNheapID, "caseno", pid.caseno, 0  29Oct15 XN 133714 Use the case number from the xml by default
   If InStr(xmlElement.xml, "caseno") Then
          Heap 10, gPRNheapID, "caseno", xmlElement.selectSingleNode("caseno").text, 0
   Else
          Heap 10, gPRNheapID, "caseno", pid.caseno, 0
   End If
   
   'Determine whether dosing weight is a whole number. Unfortunately
   'modulus operator (Mod) does not work in VB with floating point numbers.  a - (b * (a\b)) is an equivalent.
   If (weight! - (1 * (weight! \ 1))) = 0 Then
    Heap 10, gPRNheapID, "doseweight", pad$(LTrim$(Str$(weight!)) & "kg", 15), 0
   Else
    Heap 10, gPRNheapID, "doseweight", pad$(Format$(weight!, "0.0#") & "kg", 15), 0
   End If
   
   If Val(pid.weight) = 0 Then
      Heap 10, gPRNheapID, "weight", pad$(TxtD(dispdata$ & "\pn.ini", "", "unknown", "UnknownWeight", 0), 15), 0
   Else
      Heap 10, gPRNheapID, "weight", pad$(Trim$(pid.weight) & "kg", 15), 0                       '   "
   End If
   'Heap 10, gPRNheapID, "reqdoc", rd$, 0       02Jun15 XN Added missing print elements 11956
   If InStr(xmlElement.xml, "reqdoc") Then Heap 10, gPRNheapID, "reqdoc", xmlElement.selectSingleNode("reqdoc").text, 0
   'Heap 10, gPRNheapID, "PNcons", CN$, 0                            '24Jul98 CKJ added
   If InStr(xmlElement.xml, "PNcons") Then Heap 10, gPRNheapID, "PNcons", xmlElement.selectSingleNode("PNcons").text, 0                           '24Jul98 CKJ added
   'Heap 10, gPRNheapID, "PNreqdate", DR$, 0                         '   "
   If InStr(xmlElement.xml, "PNreqdate") Then Heap 10, gPRNheapID, "PNreqdate", xmlElement.selectSingleNode("PNreqdate").text, 0                         '   "
   'Heap 10, gPRNheapID, "PNbegdate", df$, 0                         '   "
   If InStr(xmlElement.xml, "PNbegdate") Then Heap 10, gPRNheapID, "PNbegdate", xmlElement.selectSingleNode("PNbegdate").text, 0                        '   "
   'Heap 10, gPRNheapID, "PNduration", feedlength$, 0                '   "
   If InStr(xmlElement.xml, "PNduration") Then Heap 10, gPRNheapID, "PNduration", xmlElement.selectSingleNode("PNduration").text, 0               '   "
   'AF$ = Getfield(patds!ActiveFact)
   'ifact$ = Getfield(patds!InjuryFact)
   
   '10Feb12 TH Added new elements
   
   If InStr(xmlElement.xml, "supply") Then Heap 10, gPRNheapID, "supply", xmlElement.selectSingleNode("supply").text, 0
   If InStr(xmlElement.xml, "pharmacytext") Then Heap 10, gPRNheapID, "pharmacytext", xmlElement.selectSingleNode("pharmacytext").text, 0       ' 02Jun15 XN Added missing print elements 11956
   '------------

   
   
''   Heap 10, gPRNheapID, "PNcardiacFail", YesNo$(Clin.CardiacFailure), 0                '24Jul98 CKJ block added ...
''   Heap 10, gPRNheapID, "PNrenalFail", YesNo$(Clin.RenalFailure), 0
''   Heap 10, gPRNheapID, "PNH-Dialysis", YesNo$(Clin.Haemodialysis), 0
''   Heap 10, gPRNheapID, "PNP-Dialysis", YesNo$(Clin.PeritonealDialysis), 0
''   Heap 10, gPRNheapID, "PNHaemofiltr", YesNo$(Clin.Haemofiltration), 0
''   Heap 10, gPRNheapID, "PNSepticaemia", YesNo$(Clin.Septicaemia), 0
''   Heap 10, gPRNheapID, "PNFulmHepFail", YesNo$(Clin.FulmHepaticFailure), 0
''   Heap 10, gPRNheapID, "PNbili>100un", YesNo$(Clin.BiliOver100unconj), 0
''   Heap 10, gPRNheapID, "PNbili>170un", YesNo$(Clin.BiliOver170unconj), 0
''   Heap 10, gPRNheapID, "PNphotoRx", YesNo$(Clin.Phototherapy), 0
''   Heap 10, gPRNheapID, "PNradiantHeat", YesNo$(Clin.RadiantHeat), 0
''   Heap 10, gPRNheapID, "PNdiuretics", YesNo$(Clin.Diuretics), 0
''   Heap 10, gPRNheapID, "PNserumNa", tp("NaQ" & Format$(Clin.SerumSodiumCategory)), 0
''   Heap 10, gPRNheapID, "PNserumK", tp("KQ" & Format$(Clin.SerumPotassiumCategory)), 0 '... to here

   If Len(Trim$(batchnumber$)) Then
         'char$ = Trim$(Batchnumber$) + RIGHT$("000" + LTRIM$(STR$(BNT)), 3)
         char$ = pad$(batchnumber$, 9)   '18Aug95 CKJ as in PrintLabel
      Else
         char$ = "[EmptyBatch]"
      End If
   Heap 10, gPRNheapID, "batchno", char$, 0

   'MM-24 SP added old format and new format barcode switch
   iBaxaInterfaceType = Val(TxtD(dispdata$ & "\pn.ini", "Baxa", "2", "BaxaInterfaceType", 0))
   Select Case iBaxaInterfaceType
   Case 2
        '29Jul13 TH Put BAxa Barcode on heap here (TFS)
        'Send in each number to function
        Heap 10, gPRNheapID, "BAXAbarcode", GetBAXABarcode(batchnumber$), 0
        Heap 10, gPRNheapID, "BAXAbarcodeA", GetBAXABarcode(batchnumber$ & "A"), 0
        Heap 10, gPRNheapID, "BAXAbarcodeL", GetBAXABarcode(batchnumber$ & "L"), 0
        Heap 10, gPRNheapID, "BAXAbarcodeM", GetBAXABarcode(batchnumber$ & "M"), 0
        Heap 10, gPRNheapID, "BAXAbarcodepad", GetBAXABarcode(pad$(batchnumber$, 9)), 0
   Case 3
        baxapath$ = siteinfo$("BaxaDRV", "") & "\BAXA\"
        batchNoA$ = GetBaxaBarcodeFileNames(baxapath$, m_intNumberofbags, bagLoop, "A")
        Heap 10, gPRNheapID, "BAXAbarcodeA", GetBAXABarcode(batchNoA$), 0
        batchNoLip$ = GetBaxaBarcodeFileNames(baxapath$, m_intNumberofbags, bagLoop, "L")
        Heap 10, gPRNheapID, "BAXAbarcodeL", GetBAXABarcode(batchNoLip$), 0
        batchNoMixed$ = GetBaxaBarcodeFileNames(baxapath$, m_intNumberofbags, bagLoop, "M")
        Heap 10, gPRNheapID, "BAXAbarcodeM", GetBAXABarcode(batchNoMixed$), 0
      
    End Select
   
   
   'Heap 10, gPRNheapID, "wardexp", wardexp$, 0
   If InStr(xmlElement.xml, "wardexp") Then Heap 10, gPRNheapID, "wardexp", xmlElement.selectSingleNode("wardexp").text, 0
   'Heap 10, gPRNheapID, "wardexp20", pad$(wardexp$, 20), 0
   If InStr(xmlElement.xml, "wardexp20") Then Heap 10, gPRNheapID, "wardexp20", xmlElement.selectSingleNode("wardexp20").text, 0
   'Heap 10, gPRNheapID, "consexp", pad$(consexp$, 30), 0
   If InStr(xmlElement.xml, "consexp") Then Heap 10, gPRNheapID, "consexp", xmlElement.selectSingleNode("consexp").text, 0
   'Heap 10, gPRNheapID, "consexp15", pad$(consexp$, 15), 0
   If InStr(xmlElement.xml, "consexp15") Then Heap 10, gPRNheapID, "consexp15", xmlElement.selectSingleNode("consexp15").text, 0
   ''defregstring regname$, origdate$, char$
   'Heap 10, gPRNheapID, "regimen", char$, 0
   If InStr(xmlElement.xml, "regimen") Then Heap 10, gPRNheapID, "regimen", xmlElement.selectSingleNode("regimen").text, 0
   If InStr(xmlElement.xml, "regimen30") Then Heap 10, gPRNheapID, "regimen30", xmlElement.selectSingleNode("regimen30").text, 0                                                                ' 02Jun15 XN Added missing print elements 11956
   If InStr(xmlElement.xml, "regimennomodtext") Then Heap 10, gPRNheapID, "regimennomodtext", xmlElement.selectSingleNode("regimennomodtext").text, 0                   ' 02Jun15 XN Added missing print elements 11956
   If InStr(xmlElement.xml, "regimennomodtext30") Then Heap 10, gPRNheapID, "regimennomodtext30", xmlElement.selectSingleNode("regimennomodtext30").text, 0             ' 02Jun15 XN Added missing print elements 11956
   'Heap 10, gPRNheapID, "regname", pad$(regname$, 30), 0      '5Oct96 CKJ was 20
   If InStr(xmlElement.xml, "regname") Then Heap 10, gPRNheapID, "regname", xmlElement.selectSingleNode("regname").text, 0      '5Oct96 CKJ was 20
   If InStr(xmlElement.xml, "modtextshort") Then Heap 10, gPRNheapID, "modtextshort", xmlElement.selectSingleNode("modtextshort").text, 0      ' 02Jun15 XN Added missing print elements 11956
   'Heap 10, gPRNheapID, "comment", Iff(Len(Trim$(REA$)), "[commentlin]", ""), 0
   If InStr(xmlElement.xml, "comment") Then Heap 10, gPRNheapID, "comment", xmlElement.selectSingleNode("comment").text, 0
   'Heap 10, gPRNheapID, "commenttxt", REA$, 0
   If InStr(xmlElement.xml, "commenttxt") Then Heap 10, gPRNheapID, "commenttxt", xmlElement.selectSingleNode("commenttxt").text, 0
   
   'mixtestformat char$, False                      '09Apr99 CKJ removed, replaced with code below
   'Heap 10, gPRNheapID, "wsmixigs", char$, 0       '
   'mixtestformat char$, True                       '
   'Heap 10, gPRNheapID, "wsmix/kg", char$, 0       '
   ans$ = "** INCORRECT USE OF WORKSHEET KEYWORD: "
   If TrueFalse(TxtD$(dispdata$ & "\pn.ini", "", "N", "UseXMLwsmix", 0)) Then
      If InStr(xmlElement.xml, "wsmixigs") Then Heap 10, gPRNheapID, "wsmixigs", xmlElement.selectSingleNode("wsmixigs").text, 0    'adult
      If InStr(xmlElement.xml, "wsmix_kg") Then Heap 10, gPRNheapID, "wsmix/kg", xmlElement.selectSingleNode("wsmix_kg").text, 0    'paed
   Else
      mixtestformat char$, (Not adult(pid.sex))        '09Apr99 CKJ Calculate correctly just once '23Feb12 TH reinstated for test
      Heap 10, gPRNheapID, "wsmixigs", Iff(adult(pid.sex), char$, ans$ & "wsmixigs"), 0    'adult
      Heap 10, gPRNheapID, "wsmix/kg", Iff(adult(pid.sex), ans$ & "wsmix/kg", char$), 0    'paed
   End If
   '                  for reference; text$, tot!(), combined, perkilo, weight!
   'CASE "constits":   constitsformat char$, tot!(), false, false, weight!
   '2012 TH Not needed ? constitsformat char$, tot!(), True, False, weight!   '8Jan96 CKJ inhibit 'fat in part B'
   'Heap 10, gPRNheapID, "constits", char$, 0
   If InStr(xmlElement.xml, "constits") Then Heap 10, gPRNheapID, "constits", xmlElement.selectSingleNode("constits").text, 0

   '2012 TH Not needed ? If Not lblscombined Then calctotals "A"
   '2012 TH Not needed ? constitsformat char$, tot!(), lblscombined, False, weight!
   '2012 TH Not needed ? calctotals ""
   'Heap 10, gPRNheapID, "constitsa", char$, 0  'use only on labels!
   If InStr(xmlElement.xml, "constitsa") Then Heap 10, gPRNheapID, "constitsa", xmlElement.selectSingleNode("constitsa").text, 0  'use only on labels!
   '2012 TH Not needed ? calctotals "B"
   '2012 TH Not needed ? constitsformat char$, tot!(), True, False, weight!
   '2012 TH Not needed ? calctotals ""
   'Heap 10, gPRNheapID, "constitsb", char$, 0  'use only on labels!
   If InStr(xmlElement.xml, "constitsb") Then Heap 10, gPRNheapID, "constitsb", xmlElement.selectSingleNode("constitsb").text, 0  'use only on labels!
   
   '2012 TH Not needed ? If iBatchMode Then                                                                     '18Jul00 CKJ Added for batch
   '2012 TH Not needed ?       char$ = "Not available"                                                          '   "
   '2012 TH Not needed ?    Else                                                                                '   "
   '2012 TH Not needed ?       constitsformat char$, tot!(), lblscombined, True, weight! '!!** Unused
   '2012 TH Not needed ?    End If                                                                              '   "
   'Heap 10, gPRNheapID, "constitskg", char$, 0
   If InStr(xmlElement.xml, "constitskg") Then Heap 10, gPRNheapID, "constitskg", xmlElement.selectSingleNode("constitskg").text, 0
   
   '2012 TH Not needed ? If iBatchMode Then                                                                     '18Jul00 CKJ Added for batch
   '2012 TH Not needed ?       char$ = "Not available"                                                          '   "
   '2012 TH Not needed ?    Else                                                                                '   "
   '2012 TH Not needed ?       constitsformat char$, tot!(), True, True, weight!
   '2012 TH Not needed ?   End If                                                                              '   "
   'Heap 10, gPRNheapID, "constkgtot", char$, 0
   If InStr(xmlElement.xml, "constkgtot") Then Heap 10, gPRNheapID, "constkgtot", xmlElement.selectSingleNode("constkgtot").text, 0

   'Vol, Cal, N, Glu, Fat, Na, K, Ca, Mg, Zn, PO4, Cl, Act, Se, Cu, Fe, (CgN)
   'for each ig 0 to 15
   '
   'quantity      Total PerKg Auto
   '-----------------------------------------------------
   'Total         i15qt  i15qtk i15qt*
   'Aqu or mixed  i15qa  i15qak i15qa*
   'Lipid         i15qb  i15qbk i15qb*
   'Grand Total   i15qg  i15qgk
   '
   'Description   i15d
   'Units         i15u   i15uk  i15u*
   
   If adult(pid.sex) Then             'adult
         w! = 1!
         kg$ = ""
      Else                            'paed
         w! = weight!
         kg$ = "k"
      End If

   calctotals ""
   
   '========================= Ingredients ====================
   
''   For X = 0 To IgMax
''      tmp$ = "i" & Format$(X) & "qt"
''      Heap 10, gPRNheapID, tmp$, tsf$(tot!(X)), 0
''      'Heap 10, gPRNheapID, tmp$ & "k", tsf$(tot!(x) / weight!), 0                 '18Jul00 CKJ changed for batch mode
''      If iBatchMode Then                                                           '   "
''            Heap 10, gPRNheapID, tmp$ & "k", "N/A", 0                              '   "
''         Else                                                                      '   "
''            Heap 10, gPRNheapID, tmp$ & "k", tsf$(tot!(X) / weight!), 0            '   "
''         End If                                                                    '   "
''      Heap 10, gPRNheapID, tmp$ & "*", tsf$(tot!(X) / w!), 0
''
''      tmp$ = "i" & Format$(X) & "qg"                              '14Aug98 CKJ Added grand totals
''      '2012 TODO Heap 10, gPRNheapID, tmp$, VAxy(X + 2, GrandTotRow), 0             'i15qg   grand total
''      '2012 TODO Heap 10, gPRNheapID, tmp$ & "k", VAxy(X + 2, GrandTotRow + 1), 0   'i15qgk  grand total/kg
''
''      tmp$ = Format$(X)
''      Heap 10, gPRNheapID, "i" & tmp$ & "d", txt(dispdata$ & tpninifile$, "", "d" & tmp$), 0
''      tmp$ = "u" & tp("igU" & Format$(X))      ' 15 => igU5 => u3 or u3kg
''      Heap 10, gPRNheapID, "i" & Format$(X) & "u", txt(dispdata$ & tpninifile$, "", tmp$), 0
''      Heap 10, gPRNheapID, "i" & Format$(X) & "uk", txt(dispdata$ & tpninifile$, "", tmp$ & "k"), 0
''      Heap 10, gPRNheapID, "i" & Format$(X) & "u*", txt(dispdata$ & tpninifile$, "", tmp$ & kg$), 0
''   Next
''
   For X = 0 To IgMax
      tmp$ = "i" & Format$(X) & "qt"
      If InStr(xmlElement.xml, tmp$) Then Heap 10, gPRNheapID, tmp$, xmlElement.selectSingleNode(tmp$).text, 0
      'Heap 10, gPRNheapID, tmp$ & "k", tsf$(tot!(x) / weight!), 0                 '18Jul00 CKJ changed for batch mode
      If iBatchMode Then                                                           '   "
            'Heap 10, gPRNheapID, tmp$ & "k", "N/A", 0                              '   "
            Heap 10, gPRNheapID, tmp$, "N/A", 0                              '   "
         Else                                                                      '   "
            Heap 10, gPRNheapID, tmp$ & "k", tsf$(tot!(X) / weight!), 0            '   "
            If InStr(xmlElement.xml, tmp$ & "k") Then Heap 10, gPRNheapID, tmp$ & "k", xmlElement.selectSingleNode(tmp$ & "k").text, 0           '   "
         End If                                                                    '   "
      'Heap 10, gPRNheapID, tmp$ & "*", tsf$(tot!(X) / w!), 0
      ''''Need escaped equivalent Heap 10, gPRNheapID, tmp$ & "*", XMLelement.selectSingleNode(tmp$ & "*").Text, 0
      'CHeck with NAH, but isnt this just the equivalent ???
      If InStr(xmlElement.xml, tmp$ & "_") Then Heap 10, gPRNheapID, tmp$ & "*", xmlElement.selectSingleNode(tmp$ & "_").text, 0
      
      tmp$ = "i" & Format$(X) & "qg"                              '14Aug98 CKJ Added grand totals
      '2012 TODO (Done below) Heap 10, gPRNheapID, tmp$, VAxy(X + 2, GrandTotRow), 0             'i15qg   grand total
      '2012 TODO (Done below) Heap 10, gPRNheapID, tmp$ & "k", VAxy(X + 2, GrandTotRow + 1), 0   'i15qgk  grand total/kg
      If InStr(xmlElement.xml, tmp$) Then Heap 10, gPRNheapID, tmp$, xmlElement.selectSingleNode(tmp$).text, 0
      If InStr(xmlElement.xml, tmp$ & "k") Then Heap 10, gPRNheapID, tmp$ & "k", xmlElement.selectSingleNode(tmp$ & "k").text, 0
      
      tmp$ = Format$(X)
      Heap 10, gPRNheapID, "i" & tmp$ & "d", txt(dispdata$ & tpninifile$, "", "d" & tmp$), 0
      tmp$ = "u" & tp("igU" & Format$(X))      ' 15 => igU5 => u3 or u3kg
      Heap 10, gPRNheapID, "i" & Format$(X) & "u", txt(dispdata$ & tpninifile$, "", tmp$), 0
      Heap 10, gPRNheapID, "i" & Format$(X) & "uk", txt(dispdata$ & tpninifile$, "", tmp$ & "k"), 0
      Heap 10, gPRNheapID, "i" & Format$(X) & "u*", txt(dispdata$ & tpninifile$, "", tmp$ & kg$), 0
   Next
   
   'If tot!(2) > 0 Then a15$ = "[kcalpergN]" & tsf$(Int(tot!(1) / (tot!(2) * w!))) & CalN$
   char$ = ""                                                               '24Jul98 CKJ
   'If tot!(2) > 0 Then char$ = tsf$(Int(tot!(1) / (tot!(2) * w!)))         '   "
   '2012 TODO If tot!(2) > 0.01 Then char$ = tsf$(Int(tot!(1) / tot!(2)))              '25Sep98 CKJ now matches screen display
   '2012 TODO Heap 10, gPRNheapID, "kcalpergN", char$, 0
                                  
   'If tot!(igFat) = 0 And tot!(igGl) = 0 Then                              '24Jul98 CKJ block added 27Oct98 CKJ moved to own procedure
   '      char$ = "0:0"
   '   ElseIf tot!(igFat) = 0 Then
   '      char$ = "100:0"
   '   ElseIf tot!(igGl) = 0 Then
   '      char$ = "0:100"
   '   Else
   '      var1! = tot!(igFat) * 10                                          'kcal from fat
   '      var2! = tot!(igGl) * 4                                            'kcal from glucose
   '      var3! = Int(var2! * 100 / (var1! + var2!))                        'glucose as % of total
   '      char$ = Format$(100 - var3!) & ":" & Format$(var3!)               '(100-CHO):(CHO)
   '   End If
   'Heap 10, gPRNheapID, "kcal%Fat:CHO", char$, 0
   'Heap 10, gPRNheapID, "TotkcalFat", tsf$(var1!), 0
   'Heap 10, gPRNheapID, "TotkcalCHO", tsf$(var2!), 0
   
   '2012 TODO CalcFatCHOratio kcalFat!, kcalCHO!, FatCHOratio$                         '27Oct98 CKJ written
   If InStr(xmlElement.xml, "kcalpergN") Then Heap 10, gPRNheapID, "kcalpergN", xmlElement.selectSingleNode("kcalpergN").text, 0        ' 02Jun15 XN  Added missing print elements 11956
   'Heap 10, gPRNheapID, "kcal%Fat:CHO", FatCHOratio$, 0
   If InStr(xmlElement.xml, "kcal_Fat_CHO") Then Heap 10, gPRNheapID, "kcal%Fat:CHO", xmlElement.selectSingleNode("kcal_Fat_CHO").text, 0
   'Heap 10, gPRNheapID, "TotkcalFat", tsf$(kcalFat!), 0
   If InStr(xmlElement.xml, "TotkcalFat") Then Heap 10, gPRNheapID, "TotkcalFat", xmlElement.selectSingleNode("TotkcalFat").text, 0
   'Heap 10, gPRNheapID, "TotkcalCHO", tsf$(kcalCHO!), 0
   If InStr(xmlElement.xml, "TotkcalCHO") Then Heap 10, gPRNheapID, "TotkcalCHO", xmlElement.selectSingleNode("TotkcalCHO").text, 0
                                
   'calctotals "A"                                                          '28Aug98 CKJ removed
''   If Not lblscombined Then calctotals "A"                                  '   "    corrected
   For X = 0 To IgMax
      tmp$ = "i" & Format$(X) & "qa"
      'Heap 10, gPRNheapID, tmp$, tsf$(tot!(X)), 0
      If InStr(xmlElement.xml, tmp$) Then Heap 10, gPRNheapID, tmp$, xmlElement.selectSingleNode(tmp$).text, 0  '16Mar12 TH Missed - ing totals for aqueous lbls missing ! (TFS 29381)
      'Heap 10, gPRNheapID, tmp$ & "k", tsf$(tot!(x) / weight!), 0                 '18Jul00 CKJ changed for batch mode
      If iBatchMode Then                                                           '   "
            Heap 10, gPRNheapID, tmp$ & "k", "N/A", 0                              '   "
         Else                                                                      '   "
            'Heap 10, gPRNheapID, tmp$ & "k", tsf$(tot!(X) / weight!), 0            '   "
            If InStr(xmlElement.xml, tmp$ & "k") Then Heap 10, gPRNheapID, tmp$ & "k", xmlElement.selectSingleNode(tmp$ & "k").text, 0            '   "
         End If                                                                    '   "
      'Heap 10, gPRNheapID, tmp$ & "*", tsf$(tot!(X) / w!), 0
      If InStr(xmlElement.xml, tmp$ & "_") Then Heap 10, gPRNheapID, tmp$ & "*", xmlElement.selectSingleNode(tmp$ & "_").text, 0
   Next
   
   'calctotals "B"
   'FEB12 TH NOT IN XML YET
'   GoTo skip
   'These may not be in the document, so do a text search first
   If InStr(xmlElement.xml, "i0qb") Then
      For X = 0 To IgMax
         tmp$ = "i" & Format$(X) & "qb"
         'Heap 10, gPRNheapID, tmp$, tsf$(tot!(X)), 0
         If InStr(xmlElement.xml, tmp$) Then Heap 10, gPRNheapID, tmp$, xmlElement.selectSingleNode(tmp$).text, 0
         'Heap 10, gPRNheapID, tmp$ & "k", tsf$(tot!(x) / weight!), 0                 '18Jul00 CKJ changed for batch mode
         If iBatchMode Then                                                           '   "
               Heap 10, gPRNheapID, tmp$ & "k", "N/A", 0                              '   "
            Else                                                                      '   "
               'Heap 10, gPRNheapID, tmp$ & "k", tsf$(tot!(X) / weight!), 0            '   "
               If InStr(xmlElement.xml, tmp$ & "k") Then Heap 10, gPRNheapID, tmp$ & "k", xmlElement.selectSingleNode(tmp$ & "k").text, 0            '   "
            End If                                                                    '   "
         'Heap 10, gPRNheapID, tmp$ & "*", tsf$(tot!(X) / w!), 0
         If InStr(xmlElement.xml, tmp$ & "_") Then Heap 10, gPRNheapID, tmp$ & "*", xmlElement.selectSingleNode(tmp$ & "_").text, 0
      Next
''      calctotals ""
   End If
'skip:


   '2012 TODO wsheetwarningsformat TotAmino, TotGlucA, tot!(), char$ '!!**
   'Heap 10, gPRNheapID, "warnings", char$, 0
   If InStr(xmlElement.xml, "warnings") Then Heap 10, gPRNheapID, "warnings", xmlElement.selectSingleNode("warnings").text, 0

   'Heap 10, gPRNheapID, "totvol", Format$(tot!(0), "0.#"), 0                  'was str$()
   If InStr(xmlElement.xml, "totvol") Then Heap 10, gPRNheapID, "totvol", xmlElement.selectSingleNode("totvol").text, 0                  'was str$()

   'Heap 10, gPRNheapID, "kconc", tsf$(tot!(igK) / (TotAmino / 1000)), 0       'was 6       '02Jun99 CKJ Avoid Div by 0
   'Heap 10, gPRNheapID, "naconc", tsf$(tot!(IgNa) / (TotAmino / 1000)), 0     'was 5       '   "
''   If TotAmino > 0 Then                                                                     '   "
''         'Heap 10, gPRNheapID, "kconc", tsf$(tot!(igK) / (TotAmino / 1000)), 0       'was 6  '   "
''         Heap 10, gPRNheapID, "kconc", xmlElement.selectSingleNode("kconc").Text, 0       'was 6  '   "
''         'Heap 10, gPRNheapID, "naconc", tsf$(tot!(IgNa) / (TotAmino / 1000)), 0     'was 5  '   "
''         'MISSING FEB12 TH Heap 10, gPRNheapID, "naconc", xmlElement.selectSingleNode("naconc").Text, 0     'was 5  '   "
''      Else                                                                                  '   "
''         Heap 10, gPRNheapID, "kconc", "N/A", 0                                             '   "
''         Heap 10, gPRNheapID, "naconc", "N/A", 0                                            '   "
''      End If                                                                                '   "
   If InStr(xmlElement.xml, "kconc") Then Heap 10, gPRNheapID, "kconc", xmlElement.selectSingleNode("kconc").text, 0                                             '   "
   If InStr(xmlElement.xml, "naconc") Then Heap 10, gPRNheapID, "naconc", xmlElement.selectSingleNode("naconc").text, 0
   
   'Heap 10, gPRNheapID, "otherfluids", Trim$(Str$(OtherFluids)), 0
   'MISSING FEB12 TH Heap 10, gPRNheapID, "otherfluids", xmlElement.selectSingleNode("otherfluids").Text, 0 '10Feb12 Confirmed deprecated
   'Heap 10, gPRNheapID, "totml3sf", tsf$(tot!(0)), 0
   If InStr(xmlElement.xml, "totml3sf") Then Heap 10, gPRNheapID, "totml3sf", xmlElement.selectSingleNode("totml3sf").text, 0
   'Heap 10, gPRNheapID, "totml/kg", tsf$((tot!(0) / weight!)), 0 'NB not for Batch'18Jul00 CKJ changed for batch mode
   If iBatchMode Then                                                              '   "
         Heap 10, gPRNheapID, "totml/kg", "N/A", 0                                 '   "
      Else                                                                         '   "
         'Heap 10, gPRNheapID, "totml/kg", tsf$((tot!(0) / weight!)), 0             '   "
         If InStr(xmlElement.xml, "totml_kg") Then Heap 10, gPRNheapID, "totml/kg", xmlElement.selectSingleNode("totml_kg").text, 0             '   "
      End If                                                                       '   "
   'Heap 10, gPRNheapID, "totmla3sf", tsf$(TotAmino), 0                            '06Aug98 CKJ amended
   'Heap 10, gPRNheapID, "totmlb3sf", tsf$(TotLipid), 0                            '   "
   'Heap 10, gPRNheapID, "totmla3sf", tsf$(Iff(lblscombined, tot!(0), TotAmino)), 0 '   "
   If InStr(xmlElement.xml, "totmla3sf") Then Heap 10, gPRNheapID, "totmla3sf", xmlElement.selectSingleNode("totmla3sf").text, 0 '   "
   'Heap 10, gPRNheapID, "totmlb3sf", tsf$(Iff(lblscombined, 0, TotLipid)), 0       '   "
   If InStr(xmlElement.xml, "totmlb3sf") Then Heap 10, gPRNheapID, "totmlb3sf", xmlElement.selectSingleNode("totmlb3sf").text, 0       '   "

   'Heap 10, gPRNheapID, "totmlovg", tsf$(TotLipidOv + TotAminoOv), 0   '25Oct96 CKJ
   If InStr(xmlElement.xml, "totmlovg") Then Heap 10, gPRNheapID, "totmlovg", xmlElement.selectSingleNode("totmlovg").text, 0   '25Oct96 CKJ
   'Heap 10, gPRNheapID, "totmlovga", tsf$(TotAminoOv), 0               '24Jul98 CKJ Added
   If InStr(xmlElement.xml, "totmlovga") Then Heap 10, gPRNheapID, "totmlovga", xmlElement.selectSingleNode("totmlovga").text, 0               '24Jul98 CKJ Added
   'Heap 10, gPRNheapID, "totmlovgb", tsf$(TotLipidOv), 0               '   "
   If InStr(xmlElement.xml, "totmlovgb") Then Heap 10, gPRNheapID, "totmlovgb", xmlElement.selectSingleNode("totmlovgb").text, 0               '   "

   'SpGravCalc False, 0, TotWtOvgA$, 0, TotWtOvgB$                             '05Jun00 CKJ Added
   'Heap 10, gPRNheapID, "totwtovga", TotWtOvgA$, 0                            '   "
   If InStr(xmlElement.xml, "totwtovga") Then Heap 10, gPRNheapID, "totwtovga", xmlElement.selectSingleNode("totwtovga").text, 0                            '   "
   'Heap 10, gPRNheapID, "totwtovgb", TotWtOvgB$, 0                            '   "
   If InStr(xmlElement.xml, "totwtovgb") Then Heap 10, gPRNheapID, "totwtovgb", xmlElement.selectSingleNode("totwtovgb").text, 0                            '   "

   'Heap 10, gPRNheapID, "overagea", tsf$(overage(Iff(lblscombined, 3, 1))), 0 '06Aug98 CKJ added mixed/aqueous overage
   If InStr(xmlElement.xml, "overagea") Then Heap 10, gPRNheapID, "overagea", xmlElement.selectSingleNode("overagea").text, 0 '06Aug98 CKJ added mixed/aqueous overage
   'Heap 10, gPRNheapID, "overageb", tsf$(overage(2)), 0                       '06Aug98 CKJ added lipid overage
   If InStr(xmlElement.xml, "overageb") Then Heap 10, gPRNheapID, "overageb", xmlElement.selectSingleNode("overageb").text, 0                       '06Aug98 CKJ added lipid overage

   'Heap 10, gPRNheapID, "printigs", PrintIg(""), 0
   If InStr(xmlElement.xml, "printigs") Then Heap 10, gPRNheapID, "printigs", xmlElement.selectSingleNode("printigs").text, 0
   'Heap 10, gPRNheapID, "printiga", PrintIg("A"), 0
   If InStr(xmlElement.xml, "printiga") Then Heap 10, gPRNheapID, "printiga", xmlElement.selectSingleNode("printiga").text, 0
   'Heap 10, gPRNheapID, "printigb", PrintIg("B"), 0
   If InStr(xmlElement.xml, "printigb") Then Heap 10, gPRNheapID, "printigb", xmlElement.selectSingleNode("printigb").text, 0

   'Heap 10, gPRNheapID, "glucaconc", tsf$(TotGlucA! / TotAmino! * 100), 0                  '02Jun99 CKJ Avoid Div by 0
''   If TotAmino > 0 Then                                                                     '   "
''         'Heap 10, gPRNheapID, "glucaconc", tsf$(TotGlucA! / TotAmino! * 100), 0             '   "
''         Heap 10, gPRNheapID, "glucaconc", xmlElement.selectSingleNode("glucaconc").Text, 0             '   "
''      Else                                                                                  '   "
''         Heap 10, gPRNheapID, "glucaconc", "N/A", 0                                         '   "
''      End If                                                                                '   "
   If InStr(xmlElement.xml, "glucaconc") Then Heap 10, gPRNheapID, "glucaconc", xmlElement.selectSingleNode("glucaconc").text, 0
   
   'Heap 10, gPRNheapID,  "reverselbl",If tpndef.printreversefeed Then char$ = "[reversefeed]"
   'Heap 10, gPRNheapID,  "forwardlbl",If tpndef.printreversefeed Then char$ = "[forwardfeed]"
   'Heap 10, gPRNheapID,  "lblsetlen", If tpndef.labels4inches Then char$ = "[4inchFF]" Else char$ = "[5.5inchFF]"
   
   Heap 10, gPRNheapID, "day", Iff(Len(dayofwk$), "[l.for]" & dayofwk$, ""), 0
 ''''Needs thought - if we are getting this downstairs then w dont need from upstairs   Heap 10, gPRNheapID, "day", xmlElement.selectSingleNode("day").Text, 0
''   Select Case CP$
''      Case "P":  char$ = "[IVperi]"           'P
''      Case "C":  char$ = "[IVcent]"           'C
''      Case "E":  char$ = "[IVCorP]"           'C or P
''      Case Else: char$ = "[IVunkn]"           'unspecified
''   End Select
   'Heap 10, gPRNheapID, "ivtype", char$, 0
   If InStr(xmlElement.xml, "ivtype") Then Heap 10, gPRNheapID, "ivtype", xmlElement.selectSingleNode("ivtype").text, 0
   
   'noi = 0
   'For x = 0 To NP - 1
   '   If ig(x) <> 0 Then
   '         If lblscombined Or RTrim$(prd(x).SolnAB) = "A" Then 'was14
   '               noi = noi + 1
   '            End If
   '      End If
   'Next
   'If noi < 20 Then char$ = "[cr]"
   'If noi > 22 Then char$ = char$ & "[8lpi]"
   '
   'leftprint = False
   'For x = 0 To NP - 1
   '   If ig(x) <> 0 Then
   '         If lblscombined Or RTrim$(prd(x).SolnAB) = "A" Then  'was14
   '               char$ = char$ & prd(x).name & TB 'pad$(PRD(x).name, 30)
   '               char$ = char$ & tsf$(ig(x)) & "[ml]"
   '               leftprint = Not leftprint
   '               If leftprint Then
   '                     char$ = char$ & TB '"     "
   '                  Else
   '                     char$ = char$ & "[cr]"
   '                  End If
   '            End If
   '      End If
   'Next
   'If leftprint Then char$ = char$ & "[cr]"
   'If noi > 22 Then popmessagecr tp("WARNING"), tp("Extendlab")
   'If noi < 20 Then
   '      For x = Int(noi / 2) To 8
   '         char$ = char$ & "[cr]"
   '      Next
   '   End If
   'Heap 10, gPRNheapID, "lbligsa", char$, 0
   

   'noi = 0
   'For x = 0 To NP - 1
   '   If ig(x) <> 0 And RTrim$(prd(x).SolnAB) = "B" Then  'was14
   '         noi = noi + 1
   '         char$ = char$ & "[PrintIg1]" & pad$(prd(x).name, 30) & " " & tsf$(ig(x)) & "[PrintIg2]"
   '      End If
   'Next
   'If noi > 4 Then popmessagecr tp("WARNING"), tp("Extendlab")
   'If noi < 4 Then
   '      For x = noi To 4
   '         char$ = char$ & "[cr]"
   '      Next
   '   End If
   'Heap 10, gPRNheapID, "lbligsb", char$, 0
   


   'for each product 0 to NP-1 ================== PRODUCTS ====================
   '
   'quantity      Total mls
   '----------------------
   'Aqu or mixed  p15qa
   'Aqu or mixed  p15qao with overage
   'Lipid         p15qb
   'Lipid         p15qbo with overage
   '{Total        p15qt} not yet
   '
   'Description
   'Aqu or mixed  p15da
   'Lipid         p15db
   '{Total        p15dt} not yet
   '
   'Units
   'Aqu or mixed  p15ua
   'Lipid         p15ub
   '{Total        p15ut} not yet

   noi = 0                  'aqueous or mixed
   For X = 0 To NP - 1
      'If ig(X) <> 0 Then                                         '18Mar12 TH Removed ocnditions as factores upstairs (TFS29334)
         'If lblscombined Or RTrim$(Prd(X).SolnAB) = "A" Then     '  "
            noi = noi + 1
            'Heap 10, gPRNheapID, "p" & Format$(noi) & "qa", tsf$(ig(X)), 0
            If InStr(xmlElement.xml, "p" & Format$(noi) & "qa") Then Heap 10, gPRNheapID, "p" & Format$(noi) & "qa", xmlElement.selectSingleNode("p" & Format$(noi) & "qa").text, 0
            'Heap 10, gPRNheapID, "p" & Format$(noi) & "qao", tsf$(igover(X)), 0
            If InStr(xmlElement.xml, "p" & Format$(noi) & "qao") Then Heap 10, gPRNheapID, "p" & Format$(noi) & "qao", xmlElement.selectSingleNode("p" & Format$(noi) & "qao").text, 0
            'Heap 10, gPRNheapID, "p" & Format$(noi) & "da", Trim$(Prd(X).name), 0
            If InStr(xmlElement.xml, "p" & Format$(noi) & "da") Then Heap 10, gPRNheapID, "p" & Format$(noi) & "da", xmlElement.selectSingleNode("p" & Format$(noi) & "da").text, 0
            'Heap 10, gPRNheapID, "p" & Format$(noi) & "ua", "[ml]", 0
            If InStr(xmlElement.xml, "p" & Format$(noi) & "ua") Then Heap 10, gPRNheapID, "p" & Format$(noi) & "ua", xmlElement.selectSingleNode("p" & Format$(noi) & "ua").text, 0
         'End If
      'End If
   Next
   For X = noi + 1 To 20    'set any left from last time to blank
      Heap 10, gPRNheapID, "p" & Format$(X) & "qa", "", 0
      Heap 10, gPRNheapID, "p" & Format$(X) & "qao", "", 0
      Heap 10, gPRNheapID, "p" & Format$(X) & "da", "", 0
      Heap 10, gPRNheapID, "p" & Format$(X) & "ua", "", 0
   Next

   noi = 0                  'lipid only
   If Not lblscombined Then          '14Aug98 CKJ Added so as to blank all lipid items in a combined regimen
      For X = 0 To NP - 1
         'If ig(X) <> 0 And RTrim$(Prd(X).SolnAB) = "B" Then  '18Mar12 TH Removed ocnditions as factores upstairs (TFS29334)
            noi = noi + 1
            'Heap 10, gPRNheapID, "p" & Format$(noi) & "qb", tsf$(ig(X)), 0
            If InStr(xmlElement.xml, "p" & Format$(noi) & "qb") Then Heap 10, gPRNheapID, "p" & Format$(noi) & "qb", xmlElement.selectSingleNode("p" & Format$(noi) & "qb").text, 0
            'Heap 10, gPRNheapID, "p" & Format$(noi) & "qbo", tsf$(igover(X)), 0
            If InStr(xmlElement.xml, "p" & Format$(noi) & "qbo") Then Heap 10, gPRNheapID, "p" & Format$(noi) & "qbo", xmlElement.selectSingleNode("p" & Format$(noi) & "qbo").text, 0
            'Heap 10, gPRNheapID, "p" & Format$(noi) & "db", Trim$(Prd(X).name), 0
            If InStr(xmlElement.xml, "p" & Format$(noi) & "db") Then Heap 10, gPRNheapID, "p" & Format$(noi) & "db", xmlElement.selectSingleNode("p" & Format$(noi) & "db").text, 0
            'Heap 10, gPRNheapID, "p" & Format$(noi) & "ub", "[ml]", 0
            If InStr(xmlElement.xml, "p" & Format$(noi) & "ub") Then Heap 10, gPRNheapID, "p" & Format$(noi) & "ub", xmlElement.selectSingleNode("p" & Format$(noi) & "ub").text, 0
         'End If
      Next
   End If
      
   For X = noi + 1 To 20    'set any left from last time to blank
      Heap 10, gPRNheapID, "p" & Format$(X) & "qb", "", 0
      Heap 10, gPRNheapID, "p" & Format$(X) & "qbo", "", 0
      Heap 10, gPRNheapID, "p" & Format$(X) & "db", "", 0
      Heap 10, gPRNheapID, "p" & Format$(X) & "ub", "", 0
   Next

   If lblscombined Then
      Tvols$ = "[totml3sf]"
      Tvolv! = tot!(0)
      afm = 3
   Else
      Tvols$ = "[totmlA3sf]"
      Tvolv! = TotAmino
      afm = 1
   End If
   
   char$ = ""

''   If infrateamino > 0 And UCase$(pid.sex) <> "B" Then
''         'char$ = "[l.Infuse]" + Tvols$ + " [ml][l.over]" + STR$(infrateamino) + "[l.at]" + tsf$(totAmino / infrateamino) + "[l.mlperhr]"
''         'char$ = "[l.Infuse]" & Tvols$ & " [ml][l.over]" & Str$(infrateamino) & "[l.at]" & tsf$(Tvolv! / infrateamino) & "[l.mlperhr]"    '8Jan96 CKJ Corrected
''         '14Feb02 ATW ; added for ENHDB 1511 ; reduce precision of printed infusion rates on TPN to 1DP
''         strOneSigInfusion = "[l.Infuse]" & Tvols$ & " [ml][l.over]" & Str$(infrateamino) & "[l.at]" & odf$(Tvolv! / infrateamino) & "[l.mlperhr]"    '8Jan96 CKJ Corrected
''         strThreeSigInfusion = "[l.Infuse]" & Tvols$ & " [ml][l.over]" & Str$(infrateamino) & "[l.at]" & tsf$(Tvolv! / infrateamino) & "[l.mlperhr]"   '14Feb02 ATW Added alternate precision
''
''         If tpndef.dropspermin Then
''               drpspermin% = Int((((Tvolv! / infrateamino) + 0.5) / 60) * tpndef.dropsperml(afm))
''               If drpspermin% > 4 Then
''                     char$ = "[l.or]" & Str$(drpspermin%) & "[l.drp/min]"
''                  Else
''                     char$ = ""
''                  End If
''            End If
''      ElseIf Tvolv! > 0 Then                                                  '20Oct98 CKJ Added
''         'char$ = char$ & " [l.volume] " & Tvols$ & "[ml] "
''         char$ = " [l.volume] " & Tvols$ & "[ml] "            '6Jul98 CKJ corrected
''      Else
''         char$ = "Not applicable"                                             '20Oct98 CKJ Added
''      End If
''   'char$ = char$ & "[cr]"'20Oct98 CKJ Removed
''   strOneSigInfusion = strOneSigInfusion & char    '14Feb02 ATW ; added for ENHDB 1511 ; reduce precision of printed infusion rates on TPN to 1DP
''   strThreeSigInfusion = strThreeSigInfusion & char
   'Heap 10, gPRNheapID, "infratea", char$, 0    ' 14Feb02 ATW both potential formats now added to heap
   'Heap 10, gPRNheapID, "infratea", strOneSigInfusion, 0
   If InStr(xmlElement.xml, "infratea") Then Heap 10, gPRNheapID, "infratea", xmlElement.selectSingleNode("infratea").text, 0
   'Heap 10, gPRNheapID, "infratea_full", strThreeSigInfusion, 0
   '08FEB12 TH Not yet in XML Heap 10, gPRNheapID, "infratea_full", xmlElement.selectSingleNode("infratea_full").Text, 0
   '23Feb12 TH Reinstated but fenceposted
   If InStr(xmlElement.xml, "infratea_full") Then Heap 10, gPRNheapID, "infratea_full", xmlElement.selectSingleNode("infratea_full").text, 0

   strOneSigInfusion = ""
   strThreeSigInfusion = ""
   char$ = ""

''   If infratefat > 0 And UCase$(pid.sex) <> "B" Then
''         'char$ = "[l.Infuse][totmlB3sf] [ml][l.over]" & Str$(infratefat) & "[l.at]" & tsf$((TotLipid / infratefat)) & "[l.mlperhr]" '14Feb02 ATW; changed for lines beneath
''         strOneSigInfusion = "[l.Infuse][totmlB3sf] [ml][l.over]" & Str$(infratefat) & "[l.at]" & odf$((TotLipid / infratefat)) & "[l.mlperhr]"
''         strThreeSigInfusion = "[l.Infuse][totmlB3sf] [ml][l.over]" & Str$(infratefat) & "[l.at]" & tsf$((TotLipid / infratefat)) & "[l.mlperhr]"
''         If tpndef.dropspermin Then
''               drpspermin% = Int((((TotLipid / infratefat) + 0.5) / 60) * tpndef.dropsperml(2))
''               If drpspermin% > 4 Then
''                     char$ = "[l.or]" & Str$(drpspermin%) & "[l.drp/min]"
''                  Else
''                     char$ = ""
''                  End If
''            End If
''      ElseIf TotLipid > 0 Then                                                '20Oct98 CKJ Added
''         char$ = " [l.volume] [totmlB3sf] [ml]"
''      Else
''         char$ = "Not applicable"                                             '20Oct98 CKJ Added
''      End If
''   'char$ = char$ & "[cr]"                                                    '20Oct98 CKJ Removed
''   strOneSigInfusion = strOneSigInfusion & char
''   strThreeSigInfusion = strThreeSigInfusion & char
   'Heap 10, gPRNheapID, "infrateb", char$, 0 ' 14Feb02 ATW both potential formats now added to heap
   'Heap 10, gPRNheapID, "infrateb", strOneSigInfusion, 0
   If InStr(xmlElement.xml, "infrateb") Then Heap 10, gPRNheapID, "infrateb", xmlElement.selectSingleNode("infrateb").text, 0
   'Heap 10, gPRNheapID, "infrateb_full", strThreeSigInfusion, 0
   '08FEB12 TH Not yet in XML Heap 10, gPRNheapID, "infrateb_full", xmlElement.selectSingleNode("infrateb_full").Text, 0
   If InStr(xmlElement.xml, "infrateb_full") Then Heap 10, gPRNheapID, "infrateb_full", xmlElement.selectSingleNode("infrateb_full").text, 0    ' 2Jun16 XN 154627 added infrateb_full
   
   'Heap 10, gPRNheapID, "parta", Iff(lblscombined, "", "[l.parta]"), 0  '!!use on labels only
   If InStr(xmlElement.xml, "parta") Then Heap 10, gPRNheapID, "parta", xmlElement.selectSingleNode("parta").text, 0  '!!use on labels only
   'Heap 10, gPRNheapID, "expirya", expiryA$, 0
   If InStr(xmlElement.xml, "expirya") Then Heap 10, gPRNheapID, "expirya", xmlElement.selectSingleNode("expirya").text, 0
   'Heap 10, gPRNheapID, "expiryb", expiryB$, 0
   If InStr(xmlElement.xml, "expiryb") Then Heap 10, gPRNheapID, "expiryb", xmlElement.selectSingleNode("expiryb").text, 0
   
   'Heap 10, gPRNheapID, "i/olblhdr", Iff(UCase$(pid.status) = "O", "[opLblHdr]", "[ipLblHdr]"), 0   'ASC 8Oct93 Added for Hope, in/out patient headers
   If InStr(xmlElement.xml, "i_olblhdr") Then Heap 10, gPRNheapID, "i/olblhdr", xmlElement.selectSingleNode("i_olblhdr").text, 0   'ASC 8Oct93 Added for Hope, in/out patient headers
   
   'char$ = ""
   'k.helpnum = 920
   'k.min = 0
   'k.max = 76
   'ans$ = freetxt$
   'Inputwin "Enter free text, if required", "", ans$, k
   'If Not k.escd Then char$ = ans$: freetxt$ = ans$
   'Heap 10, gPRNheapID, "freetext", char$, 0
   
   Heap 10, gPRNheapID, "internal", RTFinternalTransfer$, 0
   Heap 10, gPRNheapID, "invoiceto", InvoiceTo$, 0                   '!!** not in help yet
   Heap 10, gPRNheapID, "invoicenum", invoicenum$, 0                 '!!**
   Heap 10, gPRNheapID, "invoicetable", InvoiceTable$, 0             '!!**
   'Heap 10, gPRNheapID, "numofbags", Format$(numofbags), 0           '!!**
   Heap 10, gPRNheapID, "numofbags", Format$(m_intNumberofbags), 0   '03Apr12 TH(TFS 31128)
   Heap 10, gPRNheapID, "costperbag", CostPerBag$, 0                 '1Jul97 CKJ moved from DOS
   
   'fill 'fixed text' from tpnsetup.ini
   tmp$ = dispdata$ & tpninifile$
   Heap 10, gPRNheapID, "ml", txt(tmp$, "", "ml"), 0
   Heap 10, gPRNheapID, "IVcent", txt(tmp$, "", "IVcent"), 0         'For Central Intravenous use only
   Heap 10, gPRNheapID, "IVperi", txt(tmp$, "", "IVperi"), 0         'For Peripheral Intravenous use
   Heap 10, gPRNheapID, "IVCorP", txt(tmp$, "", "IVCorP"), 0         'For either Central or Peripheral Intravenous use
   Heap 10, gPRNheapID, "IVunkn", txt(tmp$, "", "IVunkn"), 0         'Not specified for Central or Peripheral use
   Heap 10, gPRNheapID, "l.parta", txt(tmp$, "", "l.parta"), 0       '(PART A) '
   Heap 10, gPRNheapID, "l.partb", txt(tmp$, "", "l.partb"), 0       '(PART B) '
   Heap 10, gPRNheapID, "l.Volume", txt(tmp$, "", "l.Volume"), 0     'Volume ='
   Heap 10, gPRNheapID, "l.Infuse", txt(tmp$, "", "l.Infuse"), 0     ' Infuse '
   Heap 10, gPRNheapID, "l.over", txt(tmp$, "", "l.over"), 0         ' over'
   Heap 10, gPRNheapID, "l.at", txt(tmp$, "", "l.at"), 0             ' hrs at '
   Heap 10, gPRNheapID, "l.for", txt(tmp$, "", "l.for"), 0           'for '
   Heap 10, gPRNheapID, "l.mlperhr", txt(tmp$, "", "l.mlperhr"), 0   ' ml/hr'
   Heap 10, gPRNheapID, "l.drp/min", txt(tmp$, "", "l.drp/min"), 0   'drops/min'
   Heap 10, gPRNheapID, "l.or", txt(tmp$, "", "l.or"), 0             ' or'
   Heap 10, gPRNheapID, "emptybatch", txt(tmp$, "", "emptybatch"), 0 '_________'
   Heap 10, gPRNheapID, "ipLblHdr", txt(tmp$, "", "ipLblHdr"), 0     'Name: [patname21]  Ward: [wardexp20][cr][ulineon][l.UnitNo][caseno][11x ][l.cons][consexp15] [l.checked]    [ulineoff][cr]
   Heap 10, gPRNheapID, "opLblHdr", txt(tmp$, "", "opLblHdr"), 0     'Name: [patname21][cr][ulineon][50x ][l.checked][ulineoff][cr]
   
   Heap 10, gPRNheapID, "WScombined", txt(tmp$, "", "WScombined"), 0
   Heap 10, gPRNheapID, "WSaqueous", txt(tmp$, "", "WSaqueous"), 0
   Heap 10, gPRNheapID, "WSlipids", txt(tmp$, "", "WSlipids"), 0
   Heap 10, gPRNheapID, "WSpremix0", txt(tmp$, "", "WSpremix0"), 0
   Heap 10, gPRNheapID, "WSpremix1", txt(tmp$, "", "WSpremix1"), 0
   Heap 10, gPRNheapID, "WSpremix2", txt(tmp$, "", "WSpremix2"), 0
   Heap 10, gPRNheapID, "WSpremix3", txt(tmp$, "", "WSpremix3"), 0
   Heap 10, gPRNheapID, "WSpremix4", txt(tmp$, "", "WSpremix4"), 0
   Heap 10, gPRNheapID, "WSpremix5", txt(tmp$, "", "WSpremix5"), 0
   Heap 10, gPRNheapID, "WSpremix6", txt(tmp$, "", "WSpremix6"), 0
   Heap 10, gPRNheapID, "WSpremix7", txt(tmp$, "", "WSpremix7"), 0
   Heap 10, gPRNheapID, "WSpremix8", txt(tmp$, "", "WSpremix8"), 0
   Heap 10, gPRNheapID, "WSpremix9", txt(tmp$, "", "WSpremix9"), 0
   Heap 10, gPRNheapID, "WStblPrefix", txt(tmp$, "", "WStblPrefix"), 0
   Heap 10, gPRNheapID, "WStblSuffix", txt(tmp$, "", "WStblSuffix"), 0
   Heap 10, gPRNheapID, "CommentLin", txt(tmp$, "", "CommentLin"), 0    '14Aug98 CKJ Added
                                                              
   Heap 10, gPRNheapID, "Hdr0", txt(tmp$, "", "Hdr0"), 0                '14Aug98 CKJ Added block
   Heap 10, gPRNheapID, "Hdr1", txt(tmp$, "", "Hdr1"), 0
   Heap 10, gPRNheapID, "Hdr2", txt(tmp$, "", "Hdr2"), 0
   Heap 10, gPRNheapID, "Hdr3", txt(tmp$, "", "Hdr3"), 0
   'Heap 10, gPRNheapID, "AqueousHeader", Iff(lblscombined, "[Hdr3]", "[Hdr1]"), 0
   If InStr(xmlElement.xml, "AqueousHeader") Then Heap 10, gPRNheapID, "AqueousHeader", xmlElement.selectSingleNode("AqueousHeader").text, 0
   'Heap 10, gPRNheapID, "LipidHeader", Iff(lblscombined, "[Hdr0]", "[Hdr2]"), 0
   If InStr(xmlElement.xml, "LipidHeader") Then Heap 10, gPRNheapID, "LipidHeader", xmlElement.selectSingleNode("LipidHeader").text, 0
   
''   If lblscombined Then        'combined regimen          26Aug98 CKJ block written
''         gGluc! = tot!(igGl)   'total g Glucose
''      Else                     'separate bags
''         gGluc! = TotGlucA     'aqueous g Glucose
''      End If
''
''   If infrateamino > 0 And UCase$(pid.sex) <> "B" And weight! > 0 And gGluc! > 0 Then
''         char$ = tsf$(((gGluc! * 1000) / weight!) / (infrateamino * 60)) 'glucose mg/kg/min
''      Else
''         char$ = "----"
''      End If
   'Heap 10, gPRNheapID, "Gluc:mg/kg/min", char$, 0
   If InStr(xmlElement.xml, "Gluc_mg_kg_min") Then Heap 10, gPRNheapID, "Gluc:mg/kg/min", xmlElement.selectSingleNode("Gluc_mg_kg_min").text, 0

   ''''Osmolality mOsmperkgH2O!, missing, ""                 '26Aug98 CKJ block written
   'Heap 10, gPRNheapID, "Osmolality", Format$(mOsmperkgH2O!) & " mOsmol per kg water" & Iff(missing, " (Caution: Data not known for " & Format$(missing) & " products)", ""), 0      '19Nov98 CKJ use tsf()
   'Heap 10, gPRNheapID, "Osmolality", Trim$(tsf$(mOsmperkgH2O!)) & " mOsmol per kg water" & Iff(missing, " (Caution: Data not known for " & Format$(missing) & " products)", ""), 0   '   "
   If InStr(xmlElement.xml, "Osmolality") Then Heap 10, gPRNheapID, "Osmolality", xmlElement.selectSingleNode("Osmolality").text, 0   '   "

   ''''CheckCaPO4Solubility SolIdx!
   'Heap 10, gPRNheapID, "CaPO4SolIndex", Format$(SolIdx!, "0.00"), 0        '14Sep98 CKJ
   If InStr(xmlElement.xml, "CaPO4SolIndex") Then Heap 10, gPRNheapID, "CaPO4SolIndex", xmlElement.selectSingleNode("CaPO4SolIndex").text, 0        '14Sep98 CKJ
   'Heap 10, gPRNheapID, "CaPO4SolIndex%", Format$(SolIdx! * 100, "#"), 0    '   "
   If InStr(xmlElement.xml, "CaPO4SolIndex_") Then Heap 10, gPRNheapID, "CaPO4SolIndex%", xmlElement.selectSingleNode("CaPO4SolIndex_").text, 0    '   "
                                                                            '   "
   'Heap 10, gPRNheapID, "*", txt(tmp$, "", "*"), 0
   
   '23Mar12 TH '27Mar12 TH Moved into if block
   If InStr(xmlElement.xml, "pnhnumber") Then Heap 10, gPRNheapID, "pnhnumber", xmlElement.selectSingleNode("pnhnumber").text, 0
   End If
   
   '19Mar12 TH Add the admin date to the heap
   '27Mar12 TH Altered to stop 1899 (null from db) dates appearing
   strAdminDate = Format(m_SupplyRequestAdminStartDate, "DD/MMM/YYYY")
   If Right(strAdminDate, 4) = "1899" Then strAdminDate = ""
   'Heap 10, gPRNheapID, "PNAdminDate", Format(m_SupplyRequestAdminStartDate, "DD/MMM/YYYY"), 0
   Heap 10, gPRNheapID, "PNAdminDate", strAdminDate, 0
   
   ' Add all the aliases to the heap 24Sep15 77778 XN
   Dim aliasXml As MSXML2.IXMLDOMNode
   For Each aliasXml In xmlElement.selectNodes("//.[@alias]")
     Heap 10, gPRNheapID, aliasXml.nodeName, aliasXml.text, 0
   Next aliasXml
   
   Heap 24, gPRNheapID, "", "", 0                                 '15Sep98 CKJ Set Redraw on
   
   
   Screen.MousePointer = STDCURSOR
   'Heap 100, gPRNheapID, "", "", 0 '!!** for debug only

End Sub

Sub Osmolality(mOsmperkgH2O!, missing%, msg$)
'Ola Rodell (Pharmacia Sweden);
' Use water content            g H2O/ml
' and osmolarity               mosm/ml
' Sum volume of all products   ml
' Sum osmolarity "    "        mosm/ml * ml
' Sum water content " "        g H2O/ml * ml
'Osmolarity is equal to
'    Sum(mosm/ml * ml) / Sum(ml)
'Osmolality is equal to
'    Sum(mosm/ml * ml) / Sum(ml)
'   ----------------------------
'   Sum(g H2O/ml * ml) / Sum(ml)
'
'This algebraically equal to
'    Sum(mosm/ml * ml)
'   ------------------
'   Sum(g H2O/ml * ml)
'and is measured in units of mOsmol per gram of water, mOsm/gH2O
'This procedure reports in units of mOsmol per kg of water, mOsm/kgH2O
'
'11Aug98 CKJ Show Osmolality result even if incomplete; return missing items in msg$

Dim SumOsmolarity!, SumWaterContent!, i%

   SumOsmolarity! = 0
   SumWaterContent! = 0
   missing = 0
   msg$ = ""
   
   For i = 0 To NP - 1
      Select Case ig(i)
         Case Is > 0
            'If prd(i).mOsmperml > 0 And prd(i).gH2Operml > 0 Then   '11Aug98 CKJ Allow water through even though mOsm=0
            If (Prd(i).mOsmperml > 0 Or (Prd(i).mOsmperml = 0 And Prd(i).linkcode = "WATI000")) And Prd(i).gH2Operml > 0 Then
                  SumOsmolarity! = SumOsmolarity! + Prd(i).mOsmperml * ig(i)
                  SumWaterContent! = SumWaterContent! + Prd(i).gH2Operml * ig(i)
               Else
                  missing = missing + 1
                  msg$ = msg$ & cr & Prd(i).name & TB & tsf(ig(i)) & " ml"
               End If
         Case Is < 0          'negative volumes count as unusable
            missing = missing + 1
            msg$ = msg$ & cr & Prd(i).name & "  (Volume is not valid)"
         End Select
   Next

   'If missing Then
   '      mOsmperkgH2O! = 0
   '   Else
         If SumWaterContent! > 0 Then   '03Oct96 CKJ Trap empty regimen
               mOsmperkgH2O! = 1000! * SumOsmolarity! / SumWaterContent!
            Else
               mOsmperkgH2O! = 0
            End If
   '   End If

End Sub

Sub Parseandprint(FILE$, copies%)
'03Sep99 CKJ Obsolete code commented out
'04Jan17 TH Use rtf templates from DB (Hosted)
Dim success%
   
   FillPrintHeapPN
   'ParseThenPrint "PNsheet", FILE$, copies, success, False
   ParseThenPrint "PNsheet", FILE$, copies, success, False, False '04Jan17 TH Ue rtf templates from DB (Hosted)

End Sub

Sub PatientInfo()
'''--Print patient info in a window--
'''24Nov91 CKJ Show full product description too
'''16Feb98 CKJ Aligned tabs correctly
'''11Aug98 CKJ Show Osmolality result even if incomplete
'''14Oct98 CKJ Uses country.044 for squared symbol
'''15Oct98 CKJ Use OCXhospnum if available
'''27Oct98 CKJ Added fat:CHO ratio and removed record number
'''04Feb98 CFY Changed wording of Surface Area to Dosing S.A and added Calculated S.A
'''18Jul00 CKJ Tidied batch info. Patient info functionally unchanged. Added 'i' icon
''
''Dim mOsmperkgH2O!, missing%, ttl$, s$, SolIdx!, msg$, OCXhospnum$, FatCHOratio$
''
''   'If pid.sex = "B" Then                                                               '18Jul00 CKJ Amended
''   If iBatchMode Then                                                                   '   "
''         ttl$ = "#Batch Information"
''         s$ = "Hospital Name             " & TB & pad$(patientname$, 90) & cr           '18Jul00 CKJ Added
''         s$ = s$ & "Record number" & TB & pid.caseno & cr & cr                          '   "
''
''      Else
''         ttl$ = "#Clinical Details"
''         's$ = "Patient Name          " & TB & pad$(patientname$, 90) & cr              '14Apr98 CKJ was 40, extended for ward/cons expansions
''         s$ = "Patient Name              " & TB & pad$(patientname$, 90) & cr           '27Oct98 CKJ widened first section
''         s$ = s$ & "Date of birth" & TB & dob$ & cr
''
''         Heap 11, gPRNheapID, "OCXhospnum", OCXhospnum$, 0                              '15Oct98 CKJ
''         OCXhospnum$ = Trim$(asciiz$(OCXhospnum$))                                      '   "
''         If OCXhospnum$ = "" Then OCXhospnum$ = pid.caseno                              '   "
''         's$ = s$ & "Case Note number" & TB & pid.caseno & cr                           '   "
''         s$ = s$ & "Case Note number" & TB & OCXhospnum$ & cr                           '   "
''         's$ = s$ & "Record number" & TB & pid.recno & cr                               '27Oct98 CKJ Removed
''         s$ = s$ & "Ward code" & TB & pid.ward & Space$(6) & wardexp$ & cr              '14Apr98 CKJ added expansion
''         s$ = s$ & "Consultant code" & TB & pid.cons & Space$(6) & consexp$ & cr        '   "
''         s$ = s$ & "Height" & TB & pid.Height & cr
''         s$ = s$ & "Dosing Weight" & TB & Trim$(tsf(weight!)) & " kg" & cr
''         's$ = s$ & "Surface area" & TB & SurfaceArea(pid.height, pid.weight) & " m²" & cr
''         's$ = s$ & "Surface area" & TB & SurfaceArea(pid.Height, pid.weight) & " m" & TxtD$("country", "", "²", "Squared", 0) & cr  '14Oct98 CKJ     '04Feb99 CFY Replaced
''         s$ = s$ & "Dosing S.A " & TB & Format$(pidExtra.SurfaceArea, "0.00;-0.00;0") & " m" & TxtD$("country", "", "²", "Squared", 0) & cr           '     "
''         s$ = s$ & "Calculated S.A" & TB & SurfaceArea(pid.Height, pid.weight) & " m" & TxtD$("country", "", "²", "Squared", 0) & cr                  '     "
''         s$ = s$ & "Requesting Doctor" & TB & rd$ & cr & cr
''
''         If GetField(patds!prescriptionID) > 0 Then
''               s$ = s$ & "Prescription ID" & TB & GetField(patds!prescriptionID) & cr
''            End If
''      End If                                                                            '18Jul00 CKJ moved from below
''
''   If tot!(2) >= 0.01 Then
''         '25Sep98 CKJ now matches printed layout
''         's$ = s$ & "Calories/gram nitrogen" & TB & Trim$(tsf(tot!(1) / tot!(2))) & "  non-protein Cals/g N" & cr
''         s$ = s$ & "Calories/gram nitrogen" & TB & Trim$(tsf$(Int(tot!(1) / tot!(2)))) & "  non-protein Cals/g N" & cr
''      End If
''
''   s$ = s$ & "Glucose concentration" & TB
''   calctotals ""    '!!** replaced calcn
''   If TotAmino > 0 Then
''         s$ = s$ & Trim$(tsfvdu(TotGlucA * 100 / TotAmino)) & "%    aqueous part only"
''         If lblscombined Then                                                           '14Apr98 CKJ Added
''               s$ = s$ & cr & TB & Trim$(tsfvdu(tot!(igGl) * 100 / tot!(0))) & "%    or more when combined" '05Jun00 CKJ added 'or more'
''            End If
''      End If
''   s$ = s$ & cr
''
''   CalcFatCHOratio 0, 0, FatCHOratio$                                                   '27Oct98 CKJ added
''   s$ = s$ & "Calorie ratio" & TB & FatCHOratio$ & " percent kcals fat:glucose" & cr
''      'End If                                                                           '18Jul00 CKJ moved above
''   s$ = s$ & cr
''
''   CheckCaPO4Solubility SolIdx!
''   s$ = s$ & "Ca PO4 solubility curve" & TB
''   Select Case SolIdx!
''      Case 0:      s$ = s$ & "not applicable" & cr
''      'Case Is > 1: s$ = s$ & "ABOVE critical value, Index = " & Format$(SolIdx! / .023, "#") & "%" & cr '12Aug98 CKJ Added figure scaled to 100 = borderline
''      'Case Is < 1: s$ = s$ & "below critical value, Index = " & Format$(SolIdx! / .023, "#") & "%" & cr '   "
''      Case Is > 1: s$ = s$ & "ABOVE critical value, Index = " & Format$(SolIdx! * 100, "#") & "%" & cr '12Aug98 CKJ Added figure scaled to 100 = borderline '27Aug98 CKJ Corrected
''      Case Is < 1: s$ = s$ & "below critical value, Index = " & Format$(SolIdx! * 100, "#") & "%" & cr '   "                                                '   "            "
''      End Select
''
''   s$ = s$ & cr & "Estimated Osmolality" & TB
''   Osmolality mOsmperkgH2O!, missing, msg$                                              '11Aug98 CKJ added msg
''   'If mOsmperkgH2O! Then                                                               '11Aug98 CKJ replaced
''   '      s$ = s$ & Trim$(tsf$(mOsmperkgH2O!)) & " mOsmol/kg water (approx)"
''   '   Else
''   '      s$ = s$ & "Not available, data incomplete for" & Str$(missing) & " products"
''   '   End If
''   If mOsmperkgH2O! Then                                                          '11Aug98 CKJ Show result even if incomplete
''         s$ = s$ & Trim$(tsf$(mOsmperkgH2O!)) & " mOsmol/kg water (approx)"
''         If missing Then
''               s$ = s$ & cr & TB & "Data incomplete for the following" & Str$(missing) & " products"
''               replace msg$, cr, lf, 0
''               replace msg$, lf, cr & TB & "    ", 0
''               s$ = s$ & msg$
''            End If
''      Else
''         s$ = s$ & "Not available"
''      End If
''   s$ = s$ & cr & cr
''
''   'defregstring regname$, origdate$, regstring$
''   's$ = s$ & regstring$ & cr
''
''   popmessagecr ttl$, s$

End Sub

Function PNlabelscombined() As Integer

   PNlabelscombined = lblscombined

End Function

Sub AskAdjustK(ProdNum)
''Dim newtotK!, numprods%, x%, deltaK!, Utyp$, ans$, tmp!
''
''   If adult(pid.sex) Then
''         If adjKadult = 0 Then Exit Sub
''      Else
''         If adjKpaed = 0 Then Exit Sub
''      End If
''
''   newtotK! = 0
''   numprods = 0           '8Apr96 CKJ don't ask when only 1 product present
''   For x = 0 To NP - 1
''      If ig(x) > 0 Then   '        mmol K per ml/ container volume
''            newtotK! = newtotK! + ig(x) * prod!(x, igK) / prod!(x, 0)
''            numprods = numprods + 1
''         End If
''   Next
''
''   deltaK! = newtotK! - totK!
''   'popmessagecr "Delta", STR$(deltaK!)
''   If deltaK! <> 0 And ProdNum <> PrdKCl And numprods > 1 And totK! > 0 Then '8Apr96 CKJ
''         AdjPrint
''         Utyp$ = tp("igU6")   ' igU5 => 3
''         If ig(PrdKCl) * prod!(PrdKCl, igK) / prod!(PrdKCl, 0) - deltaK! >= 0 Then
''               ans$ = "Y"                   '6Jan97 CKJ changed from ""
''               'k.helpnum = 910
''               tmp! = totK!
''               threesigfigs tmp!
''               Confirm "!n!bPotassium has been adjusted from" + Str$(tmp!) + " " + tp("Uabr" + Utyp$), "return Potassium to previous level by amending KCl", ans$, k
''               If ans$ = "Y" And Not k.escd Then
''                     ig(PrdKCl) = ig(PrdKCl) - deltaK! * prod!(PrdKCl, 0) / prod!(PrdKCl, igK)
''                     ModIg(2) = PrdKCl
''                  End If
''               k.escd = False
''            Else
''               popmessagecr "!n!bPotassium has been adjusted from" + Str$(totK!) + " " + tp("Uabr" + Utyp$), "Not enough KCl present to compensate for this increase in Potassium"
''            End If
''      End If

End Sub

Sub AskAdjustNa(ProdNum)
''Dim newtotNa!, numprods%, x%, deltaNa!, Utyp$, ans$, tmp!
''
''   If adult(pid.sex) Then
''         If adjNaAdult = 0 Then Exit Sub
''      Else
''         If adjNaPaed = 0 Then Exit Sub
''      End If
''
''   newtotNa! = 0
''   numprods = 0           '8Apr96 CKJ don't ask when only 1 product present
''   For x = 0 To NP - 1
''      If ig(x) > 0 Then   '        mmol Na per ml/ container volume
''            newtotNa! = newtotNa! + ig(x) * prod!(x, IgNa) / prod!(x, 0)
''            numprods = numprods + 1
''         End If
''   Next
''
''   deltaNa! = newtotNa! - totNa!
''   'popmessagecr "Delta", STR$(deltaNa!)
''   If deltaNa! <> 0 And ProdNum <> PrdNaCl And numprods > 1 And totNa! > 0 Then '8Apr96 CKJ
''         AdjPrint
''         Utyp$ = tp("igU5")   ' igU5 => 3
''         If ig(PrdNaCl) * prod!(PrdNaCl, IgNa) / prod!(PrdNaCl, 0) - deltaNa! >= 0 Then
''               ans$ = "Y"                '6Jan97 CKJ changed from ""
''               'k.helpnum = 910
''               tmp! = totNa!
''               threesigfigs tmp!
''               Confirm "!n!bSodium has been adjusted from" + Str$(tmp!) + " " + tp("Uabr" + Utyp$), "return Sodium to previous level by amending NaCl", ans$, k
''               If ans$ = "Y" And Not k.escd Then
''                     ig(PrdNaCl) = ig(PrdNaCl) - deltaNa! * prod!(PrdNaCl, 0) / prod!(PrdNaCl, IgNa)
''                     ModIg(3) = PrdNaCl
''                  End If
''               k.escd = False
''            Else
''               popmessagecr "!n!bSodium has been adjusted from" + Str$(totNa!) + " " + tp("Uabr" + Utyp$), "Not enough NaCl present to compensate for this increase in Sodium"
''            End If
''      End If

End Sub

Sub AskScaleFactor(MulFactor!, DivFactor!)
'''Scale all products by a factor
'''Returns MulFactor!=0 if no change is applicable
''
''Dim ans$, factor!
''
''   frmoptionset -1, "Scale all Ingredients by factor"
''   frmoptionset 1, "Other    Please specify"
''   frmoptionset 1, "  25%"
''   frmoptionset 1, "  33%"
''   frmoptionset 1, "  50%    Halve all ingredients"
''   frmoptionset 1, "  66%"
''   frmoptionset 1, "  75%"
''   frmoptionset 1, "100%    No change"
''   frmoptionset 1, "125%"
''   frmoptionset 1, "133%"
''   frmoptionset 1, "150%"
''   frmoptionset 1, "175%"
''   frmoptionset 1, "200%    Double all ingredients"
''   frmoptionshow "7", ans$
''   frmoptionset 0, ""
''   MulFactor! = 0
''   DivFactor! = 1
''   Select Case ans$
''      Case "1"
''         ans$ = "100"
''         k.nums = True
''         k.decimals = True
''         k.Max = 6
''         inputwin "Apply Scale Factor to all Ingredients", "Enter Percentage of current regimen required", ans$, k
''         If Not k.escd And ans$ <> "100" Then
''               MulFactor! = Val(ans$) / 100
''            End If
''      Case "2":  MulFactor! = 1: DivFactor! = 4
''      Case "3":  MulFactor! = 1: DivFactor! = 3
''      Case "4":  MulFactor! = 1: DivFactor! = 2
''      Case "5":  MulFactor! = 2: DivFactor! = 3
''      Case "6":  MulFactor! = 3: DivFactor! = 4
''      Case "7":  'no action
''      Case "8":  MulFactor! = 5: DivFactor! = 4
''      Case "9":  MulFactor! = 4: DivFactor! = 3
''      Case "10": MulFactor! = 3: DivFactor! = 2
''      Case "11": MulFactor! = 7: DivFactor! = 4
''      Case "12": MulFactor! = 2: DivFactor! = 1
''      End Select
''
''   If MulFactor! > 0 Then
''         ans$ = ""
''         factor! = Int(100! * MulFactor! / DivFactor!) / 100!
''         Confirm "?Apply Scale Factor to all Ingredients", "multiply all ingredients by  " & Format$(factor!, "0.0#  "), ans$, k
''         If ans$ = "N" Or k.escd Then
''               MulFactor! = 0
''            End If
''      End If

End Sub

' Number of seconds since start or year, hex format, padded to 7 characters with "0"
Function GetHexNumberOfSecondsSinceYearStart() As String
    Dim yearStart As Date: yearStart = DateSerial(Year(date), 1, 1)
    Dim dateDiff As Double: dateDiff = Now() - yearStart
    ' use Right(...) to pad to 7 chars
    GetHexNumberOfSecondsSinceYearStart = Right(String(7, "0") & Hex(dateDiff * 24 * 60 * 60), 7)
End Function

' baxa file names for multiple bags = "A...", "B..." etc
Function GetBaxaFileNames(numofbags As Integer, baxapath As String, baxaBaseFileName As String) As String()
    Dim bagChar As String: bagChar = "A"
    Dim fileNameSuffix As String: fileNameSuffix = Mid(baxaBaseFileName, 2)
    
    Dim fileNames() As String
    
    ReDim fileNames(m_intNumberofbags - 1)
                
    Dim X As Integer
    For X = 0 To m_intNumberofbags - 1
        fileNames(X) = baxapath & bagChar & fileNameSuffix
        bagChar = Chr(Asc(bagChar) + 1)
    Next X
    
    GetBaxaFileNames = fileNames
End Function

Function GetBaxaBarcodeFileNames(baxapath As String, numofbags As Integer, currentBag As Integer, fileType As String) As String

'---------------------------------------------------------------------------------------------------------------------
' Find Baxafile name based on the bag and its type eg : Aqueous ,lipid, mixed
'---------------------------------------------------------------------------------------------------------------------
    Dim bagChar As String: bagChar = "A"
    Dim filename As String
    Dim hexDeciName As String
    Dim Numfiles As Integer
    Dim Lastfil As String
    If fileType = "L" Then
    hexDeciName = FindHexNameBaxaFiles(baxapath & bagChar & "+A???????-" & batchnumber$ & ".PAT", Lastfil, Numfiles)
    Else
    hexDeciName = FindHexNameBaxaFiles(baxapath & bagChar & "+" & fileType & "???????-" & batchnumber$ & ".PAT", Lastfil, Numfiles)
    End If
    bagChar = Chr(Asc(bagChar) + (currentBag - 1))
    If fileexists(baxapath & bagChar & "+" & fileType & hexDeciName & "-" & batchnumber$ & ".PAT") Then
        filename = Dir$(LTrim$(baxapath & bagChar & "+" & fileType & hexDeciName & "-" & batchnumber$ & ".PAT"))
        GetBaxaBarcodeFileNames = Left$(filename, Len(filename) - 4)
    Else
        GetBaxaBarcodeFileNames = ""
    End If

End Function
Function FindHexNameBaxaFiles(pathfile$, Lastfil$, Numfiles%) As String
'---------------------------------------------------------------------------------------------------------------------
' Find LAST file which matches Batch number, format \BAXA\A+A0DAA3B2-20F12BB.PAT'and it <Seconds> hexdeciname
'---------------------------------------------------------------------------------------------------------------------
Dim filespec$, Fileis$

   Lastfil$ = ""
   Numfiles = 0
   If pathfile$ <> "" Then
         filespec$ = pathfile$
         Do
            On Local Error GoTo baxaerrhandler
            If filespec$ <> "" Then
                  Fileis$ = Dir$(filespec$)
                  filespec$ = ""
               Else
                  Fileis$ = Dir$
               End If
            On Local Error GoTo 0
            If Fileis$ <> "" Then
                  Numfiles = Numfiles + 1
                  If Fileis$ > Lastfil$ Then Lastfil$ = Fileis$
               End If
         Loop While Fileis$ <> ""
      End If
FindHexNameBaxaFiles = Mid(Lastfil$, 4, 7)
Exit Function

baxaerrhandler:
' error 57 device I/O error
' error 68 device unavailable
' error 71 disk not ready
   Select Case Err
      Case 57, 68, 71
         Fileis$ = ""
      Case Else
         Error Err
      End Select
Resume Next

End Function
Function GetFirstFileThatExists(fileNames() As String) As String
    Dim filename As Variant
    GetFirstFileThatExists = ""
    For Each filename In fileNames
        If fileexists(CStr(filename)) Then
            GetFirstFileThatExists = filename
            Exit For
        End If
    Next
End Function

Sub BaxaFile()
'--write file to \baxa with extension *.dat--
'28Jan92 CKJ Modified to correct 'empty bag', Esc, file naming & help numbers.
'23May96 CKJ Added () for plural$
'20Apr99 CKJ Tidied the questions - formatting was from DOS version
'            Added optional line for siteinfo.ini: BaxaDRV="Z:", default is own drive.
'05Jun00 CKJ Added option for output of file to Baxa's own interface program
'            TPN.INI
'            [Baxa]
'            ;  For interface software written by ASCribe set to 1
'            ;  For interface software written by BAXA set to 2 (spec: LIBR-0025 Rev A 01/13/99)
'            BaxaInterfaceType = 1                 '1 or 2, default is 1
'            ;All options below apply to BaxaInterfaceType 2 only, and are ignored if BaxaInterfaceType 1 is used.
'            BaxaPathName = "\BAXA\"               'optional. If present must have \<path>\ or just \
'            IncludeUndefinedItems = "Y"           'Y/N/T/F/0/1/-1 default is Y
'            DummyProductCode = "0000-0000-00"     'Default is "UndefinedCode" 0<=Length<=13 chars
'            ;Include lipids: Y=include lipids in file, N=do not include lipids, ?=ask every time, default is cancel
'            ;If ? is used then either Y or N can be added to set the default, using any of ?Y, Y?, ?N, N?
'            PaedCombined = "N"                    'N=manual lipid fill
'            PaedSeparate = "Y?"                   '?=ask every time, default is 'Yes'
'            AdultCombined = "Y"                   'Y=always include lipid
'            AdultSeparate = "?N"                  '?=ask every time, default is 'No'
'
'            If a Baxa interface file of a given name already exists it will NOT be overwritten. The file must be
'            removed via the Baxa software, to prevent errors where the Baxa software has already read the file.
'18Jul00 CKJ replaced AskWin with popmsg
'14Aug00 CKJ Added a line to stop lipids appearing in the aqueous part.
'            Corrected display of filenames when writing has been completed.
'
'/needs modifying to write absolute product numbers, not LinkCodes - done
'!!** Needs overage handling changing:- actually may be correct to offer chance to amend.

Dim baxapath$, ans$, nofat As Integer, afm%, fil$, Lastfil$, Numfiles%, overag$, FILE$, emptybag%     '01Jun02 All/CKJ added as integer to nofat
Dim iBaxaInterfaceType As Integer
Dim sRegimenType As String
Dim sLipidFill As String
Dim sPrompt As String
Dim sTitle As String
Dim sBaxaFile1 As String
Dim sBaxaFile2 As String
Dim sHexNumOfSec As String
Dim sMsg As String
Dim baxaFileNames() As String
Dim preExistingBaxaFile As String
Dim strAns As String

   If Len(Trim$(batchnumber)) = 0 Then
         'popmessagecr tp("bat0t"), tp("bat0d") '"Batch number not yet defined (worksheet not yet printed)"
         strPNOutputMessage = strPNOutputMessage & crlf & crlf & tp("bat0d")
      Else
         ''''To Do If tpndef.baxapump Then  '!!** And licenced
''               If Not frmVA.mnuBaxa.Enabled Then  'PORTED
''                     popmessagecr "Please Note", "Baxa Micro/Macro Compounder interface not installed"
''                  Else
                     '05Jun00 CKJ Added select case, and wrote Case 2
                     iBaxaInterfaceType = Val(TxtD(dispdata$ & "\pn.ini", "Baxa", "2", "BaxaInterfaceType", 0))
                     k.escd = False
                     Select Case iBaxaInterfaceType
                        Case 1
                        
                        
                           popmessagecr "", "This interface format is no longer supported."
                           
'21Feb12 TH Removed section as only BAXA format supported now.

''                        'Traditional ASC interface program
''                           'baxapath$ = "\BAXA\"                                   '20Apr99 CKJ Added Drive option
''                           baxapath$ = siteinfo$("BaxaDRV", "") & "\BAXA\"         '   "
''
''                           'infobar hospabbr$, "Writing BAXA micro/macro file", "5.0"
''                           If Not adult(pid.sex) Then
''                              ans$ = "Y"
''                              'k.helpnum = 325
''                              'Confirm "!n!b", "leave FAT out of the pumped regimen", ans$, k                       '20Apr99 CKJ amended
''                              askwin "?Baxa Compounder", "OK to leave FAT out of the pumped regimen?", ans$, k      '   "
''                              If ans$ = "Y" Then
''                                 nofat = True
''                                 afm = 1
''                              Else
''                                 nofat = False
''                                 afm = 3
''                              End If
''                           Else
''                              nofat = False
''                              afm = 3
''                           End If
''
''                           If Not k.escd Then
''                              ans$ = "Y"
''                              'k.helpnum = 320
''                              'Confirm "!n!bBaxa Pump", "write file" + Str$(patno&) + " to disk for the Baxa pump", ans$, k   '20Apr99 CKJ amended
''                              askwin "?Baxa Compounder", "OK to write file to disk for the Baxa Compounder?", ans$, k         '   "
''                              If ans$ = "N" Then k.escd = True
''                           End If
''
''                           If Not k.escd Then
''                              'fil$ = LTrim$(Str$(patno&))
''                              fil$ = LTrim$(Str$(pid.RecNo)) '17Jan12 TH Replaced above
''                              FindBaxaFiles baxapath$ + fil$ + "?.DAT", Lastfil$, Numfiles
''
''                              If Numfiles Then
''                                 ans$ = "Y"
''                                 'k.helpnum = 326
''                                 'Confirm "!n!bWARNING: " & Str$(Numfiles) & " file" & plural$((Numfiles)) & " already exist" & plural$(-(Numfiles = 1)), "make another file for the same patient", ans$, k    '20Apr99 CKJ amended
''                                 fil$ = fil$ & Chr$(Asc(Mid$(Lastfil$, Len(Lastfil$) - 4, 1)) + 1)                                                                                                             '   "
''                                 askwin "!Note: Baxa Compounder Queue", Format$(Numfiles) & " file" & plural$((Numfiles)) & " already present for this patient," & cr & "next available file would be " & fil$ & cr & cr & "OK to make another file for the same patient?", ans$, k    '20Apr99 CKJ amended
''                                 If ans$ = "N" Or k.escd Then
''                                    k.escd = True
''                                 'ElseIf ans$ = "Y" Then                 ' \BAXA\1234C.DAT      ==> D      '20Apr99 CKJ moved above
''                                 '   fil$ = fil$ + Chr$(Asc(Mid$(Lastfil$, Len(Lastfil$) - 4, 1)) + 1)     '   "
''                                 '   popmessagecr "", "Next available file is " + fil$                     '   "
''                                 End If
''                              Else
''                                 fil$ = fil$ + "A"
''                              End If
''                           End If
''
''                           If Not k.escd Then
''                              ans$ = Format$(overage(afm))
''                              k.nums = True
''                              k.Max = 4
''                              'k.helpnum = 327
''                              'inputwin "Enter Overage", "Enter overage required", ans$, k                 '20Apr99 CKJ amended
''                              ''inputwin "Enter Overage", "Enter overage required (ml)", ans$, k             '   "
''                              '26Jan11 TH After disucssion with Nick we will just ask for confirmation of existingOverage. The user can then bak out at this stage and change the regimen/re-authorise/order if required.
''                              askwin "!Baxa Compounder", "Overage required " & ans$ & " ml" & cr & cr & "OK to continue ?", ans$, k  '20Apr99 CKJ amended
''                              If Not k.escd And ans$ <> "N" Then
''                                 overag$ = ans$
''                                 FILE$ = baxapath$ + fil$ + ".DAT"
''                                 SaveBaxaRegimen FILE$, nofat, overag$, emptybag, 1
''                                 If emptybag Then
''                                    'popmessagecr "EMPTY BAG", "Regimen not saved"                   '20Apr99 CKJ amended
''                                    popmessagecr "!Baxa Compounder", "EMPTY BAG: Regimen not saved"  '   "
''                                    Kill FILE$
''                                 End If
''                                 popmessagecr "#SAVED", "File " & FILE$ & " written"                    '20Apr99 CKJ Added '#'
''                             End If
''                      End If

   '-------------------------------------------------------------------------------------------------------------------------
                        Case 2                                                 '05Jun00 CKJ Added interface to Baxa program
                           'Patient     Regimen Type      Actions            Baxa bag 1                Baxa bag 2        Opt.
                           '----------  ----------------  -----------------  ------------------------  ----------------  ----
                           'Paediatric  combined regimen  manual lipid fill  aqueous + overage
                           '                                                 then manual lipid fill    -                 1
                           '                              pump full regimen  combined overage          -                 2
                           '            separate regimen  manual lipid fill  aqueous + overage manual  lipid fill        1
                           '                              pump full regimen  aqueous + overage         lipid + overage   2(*)
                           '
                           'Adult       combined regimen  manual lipid fill  aqueous
                           ' and                                             then manual lipid fill    -                 1
                           'Batch                         pump full regimen  combined                  -                 2
                           '            separate regimen  manual lipid fill  aqueous                   manual lipid fill 1
                           '                              pump full regimen  aqueous                   lipid             2(*)
                           'Note: lines marked * need two files writing, so base filename must be max 7 chars long
                           
                           k.escd = False
                           baxapath$ = siteinfo$("BaxaDRV", "") & TxtD(dispdata$ & "\PN.INI", "BAXA", "\BAXA\", "BaxaPathName", 0)
                           sTitle = "Baxa Compounder Interface"

                           If Len(Trim$(batchnumber$)) = 0 Then
                                 popmessagecr "!" & sTitle, tp("Nobatch")
                                 k.escd = True
                              End If
                                 
                           sRegimenType = Iff(adult(pid.sex), "Adult", "Paed") & Iff(lblscombined, "Combined", "Separate")
                           'N=manual lipid fill, Y=always pump lipid, ?=ask every time
                           sLipidFill = TxtD(dispdata$ & "\PN.INI", "BAXA", "?", sRegimenType, 0)
                           If InStr(sLipidFill, "?") > 0 And Not k.escd Then               'is a '?' present
                                 replace sLipidFill, "?", "", 0                            'remove the '?'
                                 ans$ = sLipidFill                                         'use remainder as default
                                 sPrompt = cr & "Do you want Lipids to be included in the Baxa file?" & cr
                                 'askwin "?" & sTitle, sPrompt, ans$, k                    '18Jul00 CKJ replaced with popmsg
                                 popmsg sTitle, sPrompt, MB_YESNOCANCEL + MB_ICONQUESTION + MB_DEFBUTTON3, ans$, k.escd
                                 If Not k.escd Then sLipidFill = ans$
                              End If

                           If Not k.escd Then
                                 Select Case Len(Trim$(batchnumber$))                  'check if batch number is short enough
                                    Case Is > 8
                                       sMsg = "Cannot create Baxa interface file: Batch number is too long" & crlf
                                       sMsg = sMsg & "Please change the batch number format to eight characters maximum."
                                       'popmessagecr "." & sTitle, sMsg
                                       k.escd = True
                                    Case 8
                                       If sLipidFill = "Y" And Not lblscombined Then   'and if there are lipids !!**
                                             sMsg = "Cannot prepare Baxa interface files for both aqueous and lipid portions." & crlf
                                             sMsg = sMsg & "Please change the batch number format from eight to seven characters."
                                             'popmessagecr "." & sTitle, sMsg
                                             k.escd = True
                                          End If
                                    End Select
                                    strPNOutputMessage = strPNOutputMessage & crlf & crlf & sMsg
                              End If

                           If Not k.escd Then
                                 sMsg = Iff(adult(pid.sex), "Adult", "Paediatric") & " regimen, "
                                 sMsg = sMsg & Iff(lblscombined, "Combined", "Separate") & " portions" & crlf
                                 sBaxaFile1 = Trim$(batchnumber$)
                                 sBaxaFile2 = ""
                                 If sLipidFill = "Y" And Not lblscombined Then                 'separate regimen, pumped lipid
                                       sBaxaFile1 = sBaxaFile1 & "A.PAT"
                                       sBaxaFile2 = Trim$(batchnumber$) & "L.PAT"
                                       sMsg = sMsg & "Aqueous File:  " & sBaxaFile1 & crlf
                                       sMsg = sMsg & "Lipid File:       " & sBaxaFile2 & crlf

                                       '14Aug00 CKJ Added. This stops lipids appearing in the aqueous part, but does not
                                       'prevent the lipid bag from being done, as this is controlled by sBaxaFile2 <> ""
                                       sLipidFill = "N"
                                    ElseIf sLipidFill = "Y" And lblscombined Then              'combined regimen, pumped lipid
                                       sBaxaFile1 = sBaxaFile1 & Iff(Len(sBaxaFile1) < 8, "M", "") & ".PAT"
                                       sMsg = sMsg & "File:  " & sBaxaFile1 & crlf
                                    Else                                                       'either regimen, manual lipid
                                       sBaxaFile1 = sBaxaFile1 & Iff(Len(sBaxaFile1) < 8, Iff(lblscombined, "M", "A"), "") & ".PAT"
                                       sMsg = sMsg & "File:  " & sBaxaFile1 & crlf
                                       sMsg = sMsg & "with manual Lipid handling" & crlf
                                    End If

                                 sMsg = sMsg & crlf
                                 If Not DirExists(baxapath$) Then                              'is the path accessible?
                                       sMsg = sMsg & "Cannot access interface path:  " & baxapath$
                                       k.escd = True
                                    Else
                                       If fileexists(baxapath$ & sBaxaFile1) Then
                                             sMsg = sMsg & "File " & baxapath$ & sBaxaFile1 & " already exists"
                                             k.escd = True
                                          End If
                                       If Len(sBaxaFile2) Then
                                             If fileexists(baxapath$ & sBaxaFile2) Then
                                                   sMsg = sMsg & "File " & baxapath$ & sBaxaFile2 & " already exists"
                                                   k.escd = True
                                                End If
                                          End If
                                       If k.escd Then sMsg = sMsg & crlf & "Cannot overwrite existing file"
                                    End If
                                 
                                 If k.escd Then
                                       'popmessagecr "." & sTitle, sMsg
                                       strPNOutputMessage = strPNOutputMessage & crlf & crlf & sMsg
                                    Else
                                       sMsg = sMsg & "OK to send regimen to Baxa Compounder interface?"
                                       ans$ = "Y"
                                       askwin "?" & sTitle, sMsg, ans$, k
                                       If ans$ = "N" Then k.escd = True
                                    End If
                              End If
                           
                           If Not k.escd Then
                                 CalcOverage
                                 sMsg = "File: " & baxapath$ & sBaxaFile1
                                 '                                      no fat if sLipidFill = "N"
                                 SaveBaxaRegimen baxapath$ & sBaxaFile1, (sLipidFill = "N"), "", emptybag, 2
                                 If emptybag Then
                                       'Kill FILE$
                                       Kill baxapath$ & sBaxaFile1
                                       sMsg = sMsg & "  EMPTY BAG: No file written"
                                    Else
                                       sMsg = sMsg & " has been written"
                                    End If

                                 If Len(sBaxaFile2) Then
                                       'sMsg = crlf & "File: " & baxapath$ & sBaxaFile2                 '14Aug00 CKJ corrected
                                       sMsg = sMsg & crlf & "File: " & baxapath$ & sBaxaFile2           '   "            "
                                       '                                      fat only
                                       SaveBaxaRegimen baxapath$ & sBaxaFile2, 1, "", emptybag, 2
                                       If emptybag Then
                                             Kill baxapath$ & sBaxaFile2
                                             sMsg = sMsg & "  EMPTY BAG: No file written"
                                          Else
                                             sMsg = sMsg & " has been written"
                                          End If
                                    End If
                                 'popmessagecr "#" & sTitle, sMsg
                                 strPNOutputMessage = strPNOutputMessage & crlf & crlf & sMsg
                              Else
                                 strPNOutputMessage = strPNOutputMessage & crlf & crlf & "Baxa Compounder Interface - output aborted."
                              End If
 '-------------------------------------------------------------------------------------------------------------------------
                        Case 3 ' similar to (copied from...) inteface type 2, except creates multiple files per bag
                           k.escd = False
                           baxapath$ = siteinfo$("BaxaDRV", "") & TxtD(dispdata$ & "\PN.INI", "BAXA", "\BAXA\", "BaxaPathName", 0)
                           sTitle = "Baxa Compounder Interface"

                           If Len(Trim$(batchnumber$)) = 0 Then
                                 popmessagecr "!" & sTitle, tp("Nobatch")
                                 k.escd = True
                              End If
                                 
                           sRegimenType = Iff(adult(pid.sex), "Adult", "Paed") & Iff(lblscombined, "Combined", "Separate")
                           'N=manual lipid fill, Y=always pump lipid, ?=ask every time
                           sLipidFill = TxtD(dispdata$ & "\PN.INI", "BAXA", "?", sRegimenType, 0)
                           If InStr(sLipidFill, "?") > 0 And Not k.escd Then               'is a '?' present
                                 replace sLipidFill, "?", "", 0                            'remove the '?'
                                 ans$ = sLipidFill                                         'use remainder as default
                                 sPrompt = cr & "Do you want Lipids to be included in the Baxa file?" & cr
                                 'askwin "?" & sTitle, sPrompt, ans$, k                    '18Jul00 CKJ replaced with popmsg
                                 popmsg sTitle, sPrompt, MB_YESNOCANCEL + MB_ICONQUESTION + MB_DEFBUTTON3, ans$, k.escd
                                 If Not k.escd Then sLipidFill = ans$
                              End If

                           If Not k.escd Then
                                 Select Case Len(Trim$(batchnumber$))                  'check if batch number is short enough
                                    Case Is > 8
                                       sMsg = "Cannot create Baxa interface file: Batch number is too long" & crlf
                                       sMsg = sMsg & "Please change the batch number format to eight characters maximum."
                                       'popmessagecr "." & sTitle, sMsg
                                       k.escd = True
                                 End Select
                                strPNOutputMessage = strPNOutputMessage & crlf & crlf & sMsg
                              End If

                           If Not k.escd Then
                                 sMsg = Iff(adult(pid.sex), "Adult", "Paediatric") & " regimen, "
                                 sMsg = sMsg & Iff(lblscombined, "Combined", "Separate") & " portions" & crlf
                                 batchnumber$ = Trim(batchnumber$)
                                 sBaxaFile1 = ""
                                 sBaxaFile2 = ""
                                 sHexNumOfSec = GetHexNumberOfSecondsSinceYearStart()
                                 If sLipidFill = "Y" And Not lblscombined Then                 'separate regimen, pumped lipid
                                       sBaxaFile1 = "A+A" & sHexNumOfSec & "-" & batchnumber$ & ".PAT"
                                       sBaxaFile2 = "A+L" & sHexNumOfSec & "-" & batchnumber$ & ".PAT"
                                       sMsg = sMsg & "Aqueous File:  " & sBaxaFile1 & crlf
                                       sMsg = sMsg & "Lipid File:       " & sBaxaFile2 & crlf

                                       '14Aug00 CKJ Added. This stops lipids appearing in the aqueous part, but does not
                                       'prevent the lipid bag from being done, as this is controlled by sBaxaFile2 <> ""
                                       sLipidFill = "N"
                                    ElseIf sLipidFill = "Y" And lblscombined Then              'combined regimen, pumped lipid
                                       sBaxaFile1 = "A+M" & sHexNumOfSec & "-" & batchnumber$ & ".PAT"
                                       sMsg = sMsg & "File:  " & sBaxaFile1 & crlf
                                    Else                                                       'either regimen, manual lipid
                                       sBaxaFile1 = "A+" & Iff(lblscombined, "M", "A") & sHexNumOfSec & "-" & batchnumber$ & ".PAT"
                                       sMsg = sMsg & "File:  " & sBaxaFile1 & crlf
                                       sMsg = sMsg & "with manual Lipid handling" & crlf
                                    End If

                                 sMsg = sMsg & crlf
                                 If Not DirExists(baxapath$) Then                              'is the path accessible?
                                       sMsg = sMsg & "Cannot access interface path:  " & baxapath$
                                       k.escd = True
                                    Else
                                       If fileexists(baxapath$ & "*" & batchnumber$ & ".PAT") Then
                                             strAns = "N"
                                             popmsg sTitle, _
                                                "A file with this batch number already exists." & crlf & _
                                                "Are you sure you wish to generate files again?", _
                                                MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION, strAns, k.escd
                                          End If
                                       If strAns = "N" Then
                                            k.escd = True
                                            sMsg = sMsg & crlf & "File with same batch number (" & batchnumber$ & ") already existed"
                                         End If
                                    End If
                                 
                                 If k.escd Then
                                       'popmessagecr "." & sTitle, sMsg
                                       strPNOutputMessage = strPNOutputMessage & crlf & crlf & sMsg
                                    Else
                                       sMsg = sMsg & "OK to send regimen to Baxa Compounder interface?"
                                       ans$ = "Y"
                                       askwin "?" & sTitle, sMsg, ans$, k
                                       If ans$ = "N" Then k.escd = True
                                    End If
                              End If
                           
                           If Not k.escd Then
                                 CalcOverage
                                 sMsg = ""
                                 baxaFileNames = GetBaxaFileNames(m_intNumberofbags, baxapath, sBaxaFile1)
                                 SaveBaxaRegimenMultiBag baxaFileNames, (sLipidFill = "N"), "", emptybag, 3, sMsg

                                 If Len(sBaxaFile2) Then
                                       baxaFileNames = GetBaxaFileNames(m_intNumberofbags, baxapath, sBaxaFile2)
                                       SaveBaxaRegimenMultiBag baxaFileNames, 1, "", emptybag, 3, sMsg
                                    End If
                                 strPNOutputMessage = strPNOutputMessage & crlf & crlf & sMsg
                              Else
                                 strPNOutputMessage = strPNOutputMessage & crlf & crlf & "Baxa Compounder Interface - output aborted."
                              End If

                        Case Else
                           'popmessagecr ".", "Baxa Compounder Interface called with invalid type code of " & Format$(iBaxaInterfaceType)
                           strPNOutputMessage = strPNOutputMessage & crlf & crlf & "Baxa Compounder Interface called with invalid type code of " & Format$(iBaxaInterfaceType)
                        End Select
                 End If
 ''ToDO''            Else
''              'popmessagecr tp("bax0t"), tp("bax0d")  '"!n!b", "Baxa pump not installed"
''               popmessagecr "!Baxa Compounder", "Baxa interface not installed"                          '20Apr99 CKJ Added '!'
''            End If
      'End If

End Sub

Sub CalcFatCHOratio(kcalFat!, kcalCHO!, FatCHOratio$)
'27Oct98 CKJ Added.
'            Code moved from fillprintheappn, so it can be used elsewhere.
'            kcalPerGramFat is now configurable in TPN.INI
'            NOTE: Requires calctotals "" to have been called before use
'24May99 CKJ Corrected display of Fat:CHO ratio when 100% fat or 100% glucose
'26Oct99 CFY Corrected initialisation of Kcal from both fat and glucose
'05jun00 CKJ kcalPerGramFat & kcalPerGramGlucose read at startup

'Static kcalPerGramFat!          '05jun00 CKJ
Dim CHOpercent!

   'kcalFat! = 0                                                                                         '26Oct99 CFY Removed as superflous
   'kcalCHO! = 0                                                                                         '                "
   
   'If kcalPerGramFat! = 0 Then                                        'default to 10kcal/gram fat       05jun00 removed
   '      kcalPerGramFat! = Val(TxtD$(dispdata$ & "\tpn.ini", "", "10", "kcalPerGramFat", 0))
   '   End If
   
   kcalFat! = tot!(igFat) * kcalPerGramFat!                              'kcal from fat                  '26Oct99 CFY Added here
   'kcalCHO! = tot!(igGl) * 4                                            'kcal from glucose
   kcalCHO! = tot!(igGl) * kcalPerGramGlucose!                           'kcal from glucose   '05jun00 CKJ was hardcoded '* 4'
   
   If tot!(igFat) = 0 And tot!(igGl) = 0 Then                                  '24Jul98 CKJ block added
         FatCHOratio$ = "0:0"
      ElseIf tot!(igFat) = 0 Then
         FatCHOratio$ = "0:100"             '24May99 CKJ Corrected from "100:0"
      ElseIf tot!(igGl) = 0 Then
         FatCHOratio$ = "100:0"             '24May99 CKJ Corrected from "0:100"
      Else
         'kcalFat! = tot!(igFat) * kcalPerGramFat!                              'kcal from fat           '26Oct99 CFY Removed from here to above
         'kcalCHO! = tot!(igGl) * 4                                             'kcal from glucose       '                  "
         CHOpercent! = Int(kcalCHO! * 100 / (kcalFat! + kcalCHO!))             'glucose as % of total
         FatCHOratio$ = Format$(100 - CHOpercent!) & ":" & Format$(CHOpercent!) '(100-CHO):(CHO)
      End If

End Sub

Sub CalcOverage()
'''14Apr98 CKJ Incorporated mods from event 8232 re lipid overage of zero
'''05jun00 CKJ If volume of this portion is 0 then set overage to zero too
'''12Oct00 CKJ Redim the igover() array before calculation. Avoids carryover of lipid products after
'''             editing an authorised regimen. See event 47397
'26Jan12 TH  Reinstated but only for overall overage, the product specific overage is loaded elsewhere


''
''Dim X%, grandtotal!, total!, perover!, mlsover!, afm%
'''ReDim tot(0 To igmax) As Single
''
''   ReDim igover!(-NPe - NPi To NP)                '12Oct00 CKJ volume of igs including overage
''
''   k.escd = False
''   grandtotal! = 0
''   TotAminoOv = 0                                 '20Aug98 CKJ Clear before calculation starts to
''   TotLipidOv = 0                                 '   "        prevent 'carry over' from previous
''
''   For X = 0 To NP - 1
''      'tot!(0) = tot!(0) + ig(x) ' !!needed?
''      grandtotal! = grandtotal! + ig(X)
''   Next
''
''   If Not lblscombined Then
''         afm = 1
''         GoSub Calculateoverage
''         If Not k.escd Then
''               afm = 2
''               GoSub Calculateoverage
''            End If
''      Else
''         afm = 3
''         GoSub Calculateoverage
''      End If
''
''Exit Sub
''
''
''Calculateoverage:
''   mlsover! = overage(afm)
''
''   total! = 0
''   For X = 0 To NP - 1
''      Select Case afm
''         Case 1: If RTrim$(Prd(X).SolnAB) = "A" Then total! = total! + ig(X) 'was14
''         Case 2: If RTrim$(Prd(X).SolnAB) = "B" Then total! = total! + ig(X) 'was14
''         Case 3: total! = total! + ig(X)
''         End Select
''   Next
''
''   If total! = 0 Then mlsover! = 0      '05jun00 CKJ Added: If volume of this portion is 0 then set overage to zero too
''
''   If afm = 2 Then             ' lipid alone
''         TotLipidOv = total! + mlsover!
''      Else                     ' amino or mixed
''         TotAminoOv = total! + mlsover!
''      End If
''
''   If grandtotal! <= 0 Then
''         popmessagecr "!n!i" + tp("Error"), tp("TotVolZero")
''         k.escd = True
''      ElseIf total! > 0 Then ' total! for (say) fat can be 0, but tot!(0) > 0
''         perover! = mlsover! / total!
''         For X = 0 To NP - 1
''            If mlsover! > 0 Then
''                  Select Case afm
''                     Case 1: If RTrim$(Prd(X).SolnAB) = "A" Then igover!(X) = ig(X) * (1 + perover!) 'was14
''                     Case 2: If RTrim$(Prd(X).SolnAB) = "B" Then igover!(X) = ig(X) * (1 + perover!) 'was14
''                     Case 3: igover!(X) = ig(X) * (1 + perover!)
''                     End Select
''               Else
''                  'igover!(x) = ig(x)                    '14Apr98 CKJ replaced with Select Case below
''                  Select Case afm                        ' this allows ovg on lipid but not aqueous & vice versa
''                     Case 1: If RTrim$(Prd(X).SolnAB) = "A" Then igover!(X) = ig(X)
''                     Case 2: If RTrim$(Prd(X).SolnAB) = "B" Then igover!(X) = ig(X)
''                     Case 3: igover!(X) = ig(X)
''                     End Select
''               End If
''         Next
''      End If
''Return

End Sub

Sub calctotals(partAB$)
'partAB$ *must* be 'A' 'B' or '' only, the latter calculates for whole regimen
Dim X%, yy%

   TotAmino = 0  'total volume of the aqueous part only (whether or not combined regimen is used)
   TotLipid = 0  'total volume of the lipid   part only (whether or not combined regimen is used)
   TotGlucA = 0  'total g Glucose in  aqueous part      (whether or not combined regimen is used)
   TotInPO4 = 0  'total inorganic Phosphate in whole regimen

   ReDim tot(0 To IgMax) As Single

   For X = 0 To NP - 1
      If RTrim$(Prd(X).SolnAB) = "B" Then 'was14
            TotLipid = TotLipid + ig!(X)
         Else
            TotAmino = TotAmino + ig!(X)
''''''            TotGlucA = TotGlucA + (prod!(X, igGl) * (ig!(X) / prod!(X, IgVol)))
         End If

      If InStr(UCase$(Prd(X).SolnAB), partAB$) Then  'was14
            tot!(0) = tot!(0) + ig!(X)       ' 0 will be total vol of regimen (A/B/all)

            For yy = 1 To IgMax   '@@  13
'''''''               tot!(yy) = tot!(yy) + prod!(X, yy) * (ig!(X) / prod!(X, IgVol))
            Next
         End If

      If Not Prd(X).PO4organic Then  'total inorganicPO4
''''            TotInPO4 = TotInPO4 + prod!(X, IgPO4) * (ig!(X) / prod!(X, IgVol))
         End If
   Next

End Sub

Sub Calories(stage)
'Recalculate calories;
' Stage 0 - show total & per kilo & ask which to use
' Stage 1 - enter by total cals
' Stage 2 - enter by cals/kg
'15Nov99 CKJ replaced IgMax with IgMaxIncNonDisp

''Dim totap!, totg!, totginall!, totmlg!, numip%, x%, Y%, s$, ans$, ansv!, goodvol%, newcals!, volof!
''
''   totap! = 0
''   totg! = 0
''   totginall! = 0
''   totmlg! = 0
''   'diffing! = 0    ' not used
''   For x = 0 To NP - 1
''      numip = 0
''      'For Y = 2 To IgMax            '@@  13   'OK;  was 10  '15Nov99 CKJ removed
''      For Y = 2 To IgMaxIncNonDisp   '@@  13   'OK;  was 10  '15Nov99 CKJ was IgMax
''         If prod!(x, Y) > 0 Then numip = numip + 1
''      Next
''      If prod!(x, 3) > 0 And numip = 1 Then            '!!** used?
''            totg! = totg! + (prod!(x, 3) * ig(x)) / prod!(x, 0)
''            totmlg! = totmlg! + ig(x)
''         End If
''      If prod!(x, 0) > 0 Then
''            totginall! = totginall! + ((prod!(x, 3) * ig(x)) / prod!(x, 0))
''         End If
''   Next
''
'' '  printw " Total calories in feed = " threesigfigsvdu Tot!(1)
'' '  If weight! > 0 Then printw " Calories per kg        =  threesigfigsvdu Tot!(1) / weight!
''
''   If weight! = 0 Then stage = 1
''
''   If stage = 0 Then
''         LstBoxFrm.Caption = "Adjust Non-Protein Calories"
''         LstBoxFrm.lblTitle = cr & "Enter by total Calories or by Calories/kg" & cr
''         LstBoxFrm.LstBox.AddItem " Total Calories = " & tsfvdu(tot!(1)) & " Cals"
''         LstBoxFrm.LstBox.AddItem " Calories / kg   = " & tsfvdu(tot!(1) / weight!) & " Cals/kg"
''         LstBoxFrm.LstBox.ListIndex = Iff(adult(pid.sex), 0, 1)          '24Sep98 CKJ Added
''         LstBoxShow
''         stage = LstBoxFrm.LstBox.ListIndex + 1
''         Unload LstBoxFrm
''      End If
''
''   If stage > 0 Then
''         s$ = "Total calories in feed  = " & tsfvdu(tot!(1)) & " Cals" & cr
''         If weight! > 0 Then s$ = s$ + " Calories per kg   = " & tsfvdu(tot!(1) / weight!) & " Cals/kg" & cr & cr
''         If stage = 1 Then
''               s$ = s$ + "Enter total Calories required"
''            Else
''               s$ = s$ + "Enter Calories per kg required"
''            End If
''         Do
''            If stage = 1 Then ansv! = tot!(1) Else ansv! = tot!(1) / weight!
''            threesigfigs ansv!
''            ans$ = LTrim$(Str$(ansv!))
''            If ans$ = "0" Then ans$ = ""
''            k.nums = 1
''            k.Max = 4
''            k.min = 1
''            'k.helpnum = 330
''            inputwin "Adjust Calories", s$, ans$, k
''
''            If Not k.escd Then
''                  volumecheck goodvol
''                  If goodvol Then
''                        If stage = 1 Then newcals! = Val(ans$) Else newcals! = Val(ans$) * weight!
''                     End If
''               End If
''         Loop Until goodvol Or k.escd
''         If Not k.escd Then
''               volof! = tot!(0)
''               mixglucose volof!, newcals!
''            End If
''      End If
''
''   k.escd = False

End Sub

Function cash$(dosh!)
'Takes a positive monetary value, rounds it to the nearest 0.05p,
'and returns it as a string only. Original number is unchanged.
'String is RJ left space padded to 7 chars
                                    
Dim tmp$

   tmp$ = Format$(dosh!, "###0.00#")
   If Len(tmp$) < 7 Then tmp$ = Space$(7 - Len(tmp$)) + tmp$
   cash$ = tmp$

End Function

Sub CheckCaPO4Solubility(SolubilityIndex!)
'P Ball specification;   If ...
' Calcium(mmol/kg) + Phosphate (mmol/kg)
' --------------------------------------
'        Volume(ml/kg) / 150
' ... exceeds 2.3 then precipitation is likely
'
'This procedure notes that the weight (kg) cancels &
'plays no part in the overall calculation. The result
'is divided by 2.3 so that if SolubilityIndex!>1 then
'precipitation is likely.
'Note also that a combined regimen is treated as if
'separate aqueous & fat bags are being prepared. This
'is because precipitation can still occur during
'preparation.
'Value returned=0 if volume is zero, or Ca or PO4 are absent
'
'21Oct96 CKJ Corrected maths & now uses TotInPO4 - total inorganic PO4 in whole regimen
'            Confirmed with Charlotte whether to include PO4 in lipid phase esp in Intralipid
'            and whether calc should be (all Ca)+(all PO4) / (aqueous volume)
'            ie assume worst case scenario of lowest vol, highest concentrations, as may
'            occur during mixing
'            -> PO4 in intralipid is organic therefore excluded.
'               Yes, use ALL Ca & ALL inorganic PO4 calculated as if in AQUEOUS vol only.

   calctotals "A"      'assume aqueous phase only
                       
   ' total volume
  'If tot!(IgVol) > 0 And tot!(IgCa) > 0 And tot!(10) > 0 Then
   If tot!(IgVol) > 0 And tot!(IgCa) > 0 And TotInPO4 > 0 Then
                             'Ca                    'PO4                  'Mls
        'SolubilityIndex! = (tot!(IgCa) / Weight! + tot!(10) / Weight!) / ((tot!(0) / Weight!) / 150)
                             'Ca         'inorg PO4         'Mls
         SolubilityIndex! = (tot!(IgCa) + TotInPO4) / (tot!(IgVol) / 150) / 2.3
      Else
         SolubilityIndex! = 0
      End If

   calctotals ""     'back to normal

End Sub

Sub CheckPrescription(OK%, Changed%)
'Handle the '?Ask' entries now
'21Sep98 CKJ changes are shown on tot & /kg lines
'            adult prompts for totals

''Dim i%, tmp$, Txt$, x%, dummy%, ans$, Critical%
''Dim RowToChange%
''
''   OK = True
''   Changed = False
''   For i = 2 To 16     '!!** FIXED NUMBER   11Apr98 CKJ was 15
''      If Left$(SCxy(i, RowsUsedSC), 1) = "-" Then
''            '      tmp$ = Format$(i - 1)
''            '      tmp1$ = tp("SCd" & tmp$)
''            tmp$ = frmSC.tgdSC.ColumnName(i)
''            replace tmp$, cr, " ", 0
''            Txt$ = "The entry for " & tmp$ & " cannot be calculated:" & cr & cr
''            For x = 1 To RowsUsedSC - 1 + (RowsUsedSC > 1) 'exclude the calculated total line
''               If Left$(SCxy(i, x), 1) = "?" Then
''                     If SCxy(0, x) = "" Then
''                           Txt$ = Txt$ & SCxy(1, x) & cr & cr
''                        Else
''                           Txt$ = Txt$ & SCxy(1, x) & ": " & SCxy(0, x) & cr & cr
''                        End If
''                  End If
''            Next
''            ParseCtrlChars dispdata$ & "\printer.ini", "Screen", Txt$, dummy
''            If adult(pid.sex) Then                                             '21Sep98 CKJ Added
''                  Txt$ = Txt$ & "Enter total quantity required for " & tmp$    '   "          "
''               Else
''                  Txt$ = Txt$ & "Enter required quantity for " & tmp$ & " per kg body weight"
''               End If
''            ans$ = ""
''            CentreForm frmTxtWin
''            inputwin "Manual Entry Required", Txt$, ans$, k
''            If k.escd Then
''                  OK = False   'but no message
''                  Exit For
''               ElseIf (Val(ans$) = 0 And Trim$(ans$) = "") Then  'Return pressed
''                  popmessagecr "Note", "Prescription cannot be authorised until it is complete"
''                  OK = False
''                  Exit For
''               Else            'new value entered, so show it
''                  'SCxy(i, RowsUsedSC) = ans$                       '21sep98 CKJ removed
''                  RowToChange = RowsUsedSC - adult(pid.sex)
''                  StoreScriptChange (RowToChange), i, ans$          '   "        sets both lines
''                  Changed = True
''                  frmSC.tgdSC.Refresh
''               End If
''         End If
''   Next
''
''   If OK And Not Changed Then  'check rules which may now apply??
''         'Note the proc either asks for values or checks all for validity, not both
''         Txt$ = ""
''         CheckRulesPrescription Txt$, Critical
''         ParseCtrlChars dispdata$ & "\printer.ini", "Screen", Txt$, dummy
''         If Critical Then
''               Txt$ = Txt$ & "This prescription cannot be authorised"
''               OK = False
''            End If
''         If Len(Txt$) Then popmessagecr "Please Note", Txt$
''      End If

End Sub

Function PrintIg$(SolnAB$)
'Set SolnAB = "" for all, "A" for aqueous, "B" for lipids

Dim chars$, X%

   chars$ = ""
   For X = 0 To NP - 1
      If ig(X) <> 0 Then
            If SolnAB$ = "" Or SolnAB$ = RTrim$(Prd(X).SolnAB) Then 'was14
                  chars$ = chars$ & "[PrintIg1]" & pad$(Prd(X).name, 30) & " " & tsf$(ig(X)) & "[PrintIg2]"
               End If
         End If
   Next
   PrintIg$ = chars$

End Function

Sub PrintInvoice()
'''---------------------------------- TPNINVCE ----------------------------V5.0
'''04Sep88 CKJ V1.0 First version released for testing & trial use.
'''20Sep88 ASC libname added
'''5 Oct88 ASC libtpn added for all files except invdata
'''28Oct88 us  VAT as per requirement for Salford
'''            multiple bags, with separate service & bag costs
'''17Aug89 CKJ change invnum => not saved. needed    invnum$=str$(invnum)
'''20Feb90 ASC converted to qb4.5 q4input added
'''20Apr90 CKJ Conversion continues ...
'''10Aug90 ASC file diverted to word procesor to allow manual adjustment.
'''            Output options now include sending to a pharmacopoeia comaptible
'''               file for manual adjustemnt.
'''20Aug90 CKJ Use of pointer rf(11) is incorrect - should be rf(6)
'''18Sep90 ASC programme now loops until escaped out of
'''04Feb90 ASC now works with v5 data structures etc.
'''10Aug91 CKJ GetPatidNL now used
'''31Aug93 ASC ig! now dimmed to 79
''' 7Dec93 ASC/CKJ PID.recno changed to PID.caseno for printing
'''24Jun94 CKJ Named common /TPN/ was missing - added
'''            VAT changed to tpnVAT
''' 4Jan95 CKJ Added GPexp$
'''23Mar95 CKJ Proddim was not declared properly - was not passed to tpnsubs
'''            Moved Close, extended prod!
'''            Still not happy with prodim% - unnecessary wastage of space.
''' 8Feb96 CKJ Moved Invoicing into TPN from TPNINVCE, extended for Hope Hosp.
'''30Nov96 CKJ HEdit installed
'''(need to indicate which are split & which aren't)
'''Redesign done..
'''product name, Vol per bag, Share Y/N, ml in reg, num bags, ml for pt, ml total
'''info in;
'''  product number, mls inc overage
'''info looked up;
'''  product name, container size, share Y/N
'''  VAT rate, price, price basis(TPN/Drug inc or ex VAT)
'''info derived;
'''  price ex VAT, price inc VAT, num packs, £ ex VAT, £ inc VAT
''' 4Feb97 CKJ Moved text for container & services to TPNSETUP.INI
'''            InvContainer="Ingredient containers and consumables"
'''            InvServices ="Services & Overheads"
''' 1Jul97 CKJ Ported latest DOS version and added
'''            InvSubTotal="[tab]Sub-Total[tab]"
'''            InvTotalDue="[tab]TOTAL DUE[tab]"
'''
''
''Dim invnum&, invnumprefix$, IssueAtInvoice%, BagSrvcVat!, showVAT%, bagcost!, overheads!
''Dim scriptcost!, scriptvat!, x%, wholepacks%, lngfound As Long, des$, mlppk!, numused!    '01Jun02 All/CKJ
''Dim rawigcost!, unitprice!, igvatrate!, igcostxv!, igvat!, igcostiv!, totigcost!, tempvar!
''Dim bagvat!, tmp$, ans$
''Static lastsupplier$
''
''   If Not frmVA.mnuInvoice.Enabled Then Exit Sub
''
''   If Not fileexists(dispdata$ + "\tpninvce.dat") Then
''         GetPointer dispdata$ + "\tpninvce.dat", 1, 1  'set 1st one to 1
''      End If
''
''   GetPointer dispdata$ + "\tpninvce.dat", invnum&, False
''   invnumprefix$ = tpnini$("InvNumPrefix", "")
''   invoicenum$ = invnumprefix$ & Mid$(Str$(invnum&), 2) 'increments after use
''   IssueAtInvoice = (tpnini$("IssueAtInvoice", "0") <> "0") 'T/F
''   BagSrvcVat! = Val(tpnini$("BagServiceVat", "0")) / 100   '=17.5 etc
''   'DefaultVAT! = VAL(tpnini$("DefaultVat", "0")) / 100      '=17.5 etc
''
''   asksupplier InvoiceTo$, 0, "WSE", "Select hospital/department to be invoiced:", False, sup
''   k.escd = False
''
''   'InvoiceTo$ = ""
''   'screen.MousePointer = hourglass
''   'LstBoxFrm.Caption = "Suppliers"
''   'LstBoxFrm.lblTitle = cr & " Select hospital/department to be invoiced:" & cr
''   'LstBoxFrm.lblHead = "Code      " & TB & "Description"
''   'GetPointer dispdata$ & "\supfile.v5", pointer&, False       'read only
''   'LstBoxFrm.LstBox.AddItem TB & "< Enter invoicee and address >"
''   'LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 1
''   'For i = 2 To pointer&
''   '   getsupplier "", i, found, False, sup
''   '   If Len(Trim(sup.code)) > 0 Then
''   '         LstBoxFrm.LstBox.AddItem "  " & sup.code & TB & Left$(joinsup$(sup.supaddress, sup), 50)
''   '         LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = i
''   '      End If
''   'Next
''   'screen.MousePointer = stdcursor
''   '
''   'LstBoxShow
''   '
''   'i = LstBoxFrm.LstBox.ListIndex
''   'If i > -1 Then
''   '      posn = LstBoxFrm.LstBox.ItemData(i)
''   '   End If
''   'Unload LstBoxFrm
''
''   'Select Case posn
''   '   Case 1
''   If InvoiceTo$ = "" Then
''         tmp$ = "Enter name and address for Invoice, separating each line with a comma"
''         ans$ = lastsupplier$
''         Do
''            k.min = 1
''            k.Max = 78
''            inputwin "PN Invoice Name and Address", tmp$, ans$, k
''            InvoiceTo$ = UCase$(ans$)
''         Loop Until k.escd Or InvoiceTo$ <> ""
''      'Case Is > 1
''      Else
''         lastsupplier$ = InvoiceTo$
''         'getsupplier "", posn, found, False, sup
''         InvoiceTo$ = joinsup$(sup.supaddress, sup)
''         replace InvoiceTo$, ",", "[cr]", 0
''      'Case Else
''      '   k.escd = True
''      'End Select
''      End If
''
''   If Not k.escd Then
''         showVAT = False
''         If tpnini("AskInvoiceVAT", "0") <> "0" Then
''               ans$ = tpnini("InvoiceVATdef", "0")
''               'k.helpnum = 1010                VAT
''               askwin "PN Invoice", "Is " & money$(9) & " to be shown on the invoice?", ans$, k
''               If ans$ = "Y" And Not k.escd Then showVAT = True
''            End If
''      End If
''
''   If Not k.escd Then
''         k.min = 0
''         k.Max = 5
''         ans$ = tpnini$("CostOfTPNBag", "")
''         k.decimals = True
''         'k.helpnum = 1020
''         tmp$ = "Enter the cost of the bag (" & money$(7) & ")"            '£.pp
''         If BagSrvcVat! > 0 Then tmp$ = tmp$ & " excluding " & money$(9)   'VAT
''         inputwin "PN Invoice", tmp$, ans$, k
''         If Not k.escd Then
''               bagcost! = Int(Val(ans$) * 100 + 0.5001) / 100
''            End If
''      End If
''
''   If Not k.escd Then
''         k.min = 0
''         k.Max = 5
''         ans$ = tpnini$("CostOfServices", "")
''         k.decimals = True
''         'k.helpnum = 1030
''         tmp$ = "Enter the cost of services & overheads (" & money$(7) & ")" '£.pp
''         If BagSrvcVat! > 0 Then tmp$ = tmp$ & " excluding " & money$(9)     'VAT
''         inputwin "PN Invoice", tmp$, ans$, k
''         If Not k.escd Then
''               overheads! = Int(Val(ans$) * 100 + 0.5001) / 100
''            End If
''      End If
''
''   If Not k.escd Then
''         k.min = 0
''         k.Max = 2
''         ans$ = "1"
''         k.nums = True
''         'k.helpnum = 1040
''         inputwin "PN Invoice", "Enter the number of bags prepared", ans$, k
''         numofbags = Int(Val(ans$) + 0.0001)
''         If numofbags = 0 And Len(ans$) > 0 Then k.escd = True
''         If Not k.escd And Len(ans$) = 0 Then numofbags = 1
''      End If
''
''   If Not k.escd Then
''         CalcOverage
''         'Erase nsvcodes$                                         '17Aug98 CKJ removed
''         ReDim nsvcodes(0 To NP - 1) As String                    '            dynamically resize
''         If IssueAtInvoice Then issueregimen True, numofbags      'sets nsvcodes()
''
''         If Not k.escd Then            '-------- PRINT INVOICE ---------
''               tmp$ = ""
''               scriptcost! = 0
''               scriptvat! = 0
''
''               For x = 0 To NP - 1
''                  If igover!(x) > 0 Then
''                        wholepacks = False
''                        If Prd(x).SharePacks = 0 Then 'don't share containers, use whole ones
''                              wholepacks = True
''                           End If
''
''                        If IssueAtInvoice And nsvcodes$(x) <> "" Then
''                              d.SisCode = nsvcodes$(x)
''                              getdrug d, 0, lngfound, False    '01Jun02 All/CKJ
''                           End If
''
''                        If IssueAtInvoice And nsvcodes$(x) <> "" And lngfound <> 0 Then 'use data from main drug file      '01Jun02 All/CKJ
''                              des$ = d.Description
''                              plingparse des$, "!"
''                              tmp$ = tmp$ & des$ & "[cr]"
''
''                              If d.mlsperpack > 0 Then mlppk! = d.mlsperpack Else mlppk! = 1
''                              numused! = igover!(x) / mlppk!       ' ml used / ml per issue unit
''
''                              'If wholepacks And numused! > Int(numused!) Then
''                              '      numused! = Int(numused!) + 1   'round up to next whole pack
''                              '   End If
''                              '18Jan97 CKJ Multiply first if sharing, afterwards if not...
''                              If Not wholepacks Then numused! = numused! * numofbags
''                              If numused! > Int(numused!) Then
''                                    numused! = Int(numused!) + 1   'round up to next whole pack
''                                 End If
''                              If wholepacks Then numused! = numused! * numofbags
''
''                              rawigcost! = Val(d.cost) / Val(d.convfact)   'pence per issue unit NB may be inc vat or exc vat, also fractional
''                              unitprice! = Int(rawigcost! + 0.5001)        'whole pence total inc or ex vat
''                              rawigcost! = rawigcost! * numused!           'pence total inc or ex vat, with fractions of a penny
''                              rawigcost! = Int(rawigcost! + 0.5001)        'whole pence total inc or ex vat
''                              igvatrate! = VAT(Val(d.vatrate))             '1.175
''                              If TransLogVAT Then                          'Price is ex VAT so add VAT now
''                                    igcostxv! = rawigcost!                 'whole pence
''                                    igvat! = igcostxv! * (igvatrate! - 1!) 'VAT, fractional pence
''                                    igvat! = Int(igvat! + 0.5001)          'in whole pence
''                                    igcostiv! = igcostxv! + igvat!         'in whole pence
''                                 Else                                      'Price already includes VAT
''                                    igcostiv! = rawigcost!                 'whole pence
''                                    igvat! = igcostiv! * (igvatrate! - 1!) / igvatrate! 'calculate VAT content, fractional pence
''                                    igvat! = Int(igvat! + 0.5001)          'in whole pence
''                                    igcostxv! = igcostiv! - igvat!         'in whole pence
''                                 End If
''                           Else                  'use data from TPN product file alone
''                              tmp$ = tmp$ & pad$(Prd(x).name, 30)          'len = 29
''                              numused! = igover!(x) / prod!(x, 0)          'ml used / ml per container
''
''                              'If wholepacks And numused! > Int(numused!) Then
''                              '      numused! = Int(numused!) + 1
''                              '   End If
''                              '18Jan97 CKJ Multiply first if sharing, afterwards if not...
''                              If Not wholepacks Then numused! = numused! * numofbags
''                              If numused! > Int(numused!) Then
''                                    numused! = Int(numused!) + 1
''                                 End If
''                              If wholepacks Then numused! = numused! * numofbags
''
''                              rawigcost! = Val(Prd(x).cost) * 100          'pence per container inc VAT
''                              unitprice! = Int(rawigcost! + 0.5001)        'whole pence total inc or ex vat
''                              rawigcost! = rawigcost! * numused!           'pence total inc vat, with fractions of a penny
''                              rawigcost! = Int(rawigcost! + 0.5001)        'whole pence total inc vat
''
''                              igvat! = 0                                   'VAT not visible
''                              igcostiv! = rawigcost!                       'whole pence
''                              igcostxv! = rawigcost!                       'whole pence
''                           End If
''
''                        unitprice! = unitprice! / 100                      '£pp inc or ex vat
''                        igcostxv! = igcostxv! / 100                        '£pp
''                        igcostiv! = igcostiv! / 100                        '£pp
''                        igvat! = igvat! / 100                              '£pp
''
''                        If showVAT Then
''                              totigcost! = igcostxv!                       '£pp ex-VAT figure
''                              scriptvat! = scriptvat! + igvat!             '£pp VAT
''                           Else
''                              totigcost! = igcostiv!                       '£pp total figure
''                           End If
''                        scriptcost! = scriptcost! + totigcost!
''
''                        'tmp$ = tmp$ & "[tab]" & Format$(igover!(x), "####.# ml")
''                        'tmp$ = tmp$ & "[Tab]" & cash(unitprice!) & "[Tab]" & cash(totigcost!)
''
''                        tmp$ = tmp$ & "[Tab]" & cash(unitprice!)
''                        tmp$ = tmp$ & "[Tab]" & Format$(numused!)
''                        tmp$ = tmp$ & "[Tab]" & cash(totigcost!)
''                        If showVAT Then tmp$ = tmp$ & "[Tab]" & cash(igvat!)
''                        tmp$ = tmp$ & "[cr]"
''                     End If
''               Next
''
''               'tempvar! = INT(100 * bagcost! / (1 + BagSrvcVat!) + .5001) / 100
''               bagvat! = bagcost! * BagSrvcVat! * numofbags
''               bagcost! = bagcost! * numofbags
''               '4Feb97 CKJ Moved text into .INI
''               'PRINT #filno, "Ingredient containers and consumables"; TAB(54); money(bagcost!);
''               tmp$ = tmp$ & Txt(dispdata$ & tpninifile$, "", "InvContainer")
''               tmp$ = tmp$ & "[tab][tab][tab]" & moneyV(bagcost!)
''               scriptcost! = scriptcost! + bagcost!
''               If showVAT Then
''                     tmp$ = tmp$ & "[tab]" & moneyV(bagvat!)
''                     scriptvat! = scriptvat! + bagvat!
''                  End If
''               tmp$ = tmp$ & "[cr]"
''
''               tmp$ = tmp$ & "[Tab][Tab][Tab][10x-]"
''               If showVAT Then tmp$ = tmp$ & "[Tab][10x-]"
''               tmp$ = tmp$ & "[cr]"
''
''               tmp$ = tmp$ & "[Tab][Tab][Tab]" & moneyV(scriptcost!)
''               If showVAT Then tmp$ = tmp$ & "[Tab]" & moneyV(scriptvat!)
''               tmp$ = tmp$ & "[cr]"
''
''               'tempvar! = Int(100 * bagcost! / (1 + BagSrvcVat!) + .5001) / 100
''               'bagvat! = bagcost! - tempvar!
''               'bagcost! = tempvar!
''               'tmp$ = tmp$ & "Ingredient Container[Tab][Tab][tab]" & moneyV(bagcost!)
''               'scriptcost! = scriptcost! + bagcost!
''               'If showVAT Then
''               '      tmp$ = tmp$ & "[Tab]" & moneyV(bagvat!) & "[cr]"
''               '      scriptvat! = scriptvat! + bagvat!
''               '   End If
''
''               '4Feb97 CKJ Moved text into .INI
''               'tmp$ = tmp$ & "Services & Overheads[Tab][Tab][Tab]" & moneyV(overheads!)
''               tmp$ = tmp$ & Txt(dispdata$ & tpninifile$, "", "InvServices")
''               tmp$ = tmp$ & "[Tab][tab][tab]" & moneyV(overheads!)
''               scriptcost! = scriptcost! + overheads!
''               If showVAT Then
''                     tempvar! = overheads! * BagSrvcVat!
''                     tmp$ = tmp$ & "[Tab]" & moneyV(tempvar!) & "[cr]"
''                     scriptvat! = scriptvat! + tempvar!
''                     tmp$ = tmp$ & "[Tab][Tab][Tab][10x-][Tab][10x-][cr]"
''                  End If
''
''               'If numofbags > 1 Then
''               '      If Not showVAT Then tmp$ = tmp$ & "[Tab][10x-][cr]"
''               '
''               '      tmp$ = tmp$ & "[Tab]Cost per bag[Tab]" & moneyV(scriptcost!)
''               '      If showVAT Then
''               '            tmp$ = tmp$ & "[Tab]" & moneyV(scriptvat!)
''               '         End If
''               '      tmp$ = tmp$ & "[cr][cr][Tab]Sub total for " & numofbags & " bags[tab]"
''               '   Else
''               '      If showVAT Then tmp$ = tmp$ & "[Tab]Sub-total[Tab][Tab]"
''               '   End If
''
''               If showVAT Then
''                     'scriptcost! = scriptcost! * numofbags
''                     'tmp$ = tmp$ & moneyV(scriptcost!)
''
''                     tmp$ = tmp$ & Txt(dispdata$ & tpninifile$, "", "InvSubTotal")    'includes two tabs
''                     tmp$ = tmp$ & "[Tab]" & moneyV(scriptcost!)
''                     tmp$ = tmp$ & "[Tab]" & moneyV(scriptvat!) & "[cr]"           'CR here
''                                           ' VAT
''                     tmp$ = tmp$ & "[Tab]" & money$(9) & "[Tab][Tab]" & moneyV(scriptvat!) & "[cr]" 'CR here
''                  End If
''
''               'If showVAT Then
''               '      scriptvat! = scriptvat! * numofbags
''               '      tmp$ = tmp$ & "[Tab]" & moneyV(scriptvat!) & "[cr]"
''               '
''               '      tmp$ = tmp$ & "[Tab]VAT[Tab][Tab]" & moneyV(scriptvat!) & "[cr]"
''               '   End If
''
''               tmp$ = tmp$ & "[Tab][Tab][Tab][10x-][cr]"
''               tmp$ = tmp$ & Txt(dispdata$ & tpninifile$, "", "Invtotaldue") & moneyV(scriptcost! + scriptvat!) 'includes two tabs
''               InvoiceTable$ = tmp$
''
''               CostPerBag$ = moneyV((scriptcost! + scriptvat!) / numofbags)  '2Feb97 CKJ Added
''
''               '25Sep98 CKJ Replaced this block with context enabled version
''               'If UCase$(pid.sex) = "B" Then                                 'Batch production
''               '      GetTextFile dispdata$ & "\TPN-INVB.RTF", tmp$, 0        '2Jul97 CKJ Added
''               '   Else
''               '      GetTextFile dispdata$ & "\TPN-INV.RTF", tmp$, 0
''               '   End If
''               '
''               'Do
''               '   changed = False
''               '   ParseCtrlChars dispdata$ + tpninifile$, "", tmp$, changed
''               '   ParseCtrlChars dispdata$ + "\printer.ini", "RTF", tmp$, changed
''               '   ParseTPNDataItems tmp$, changed
''               'Loop While changed
''               '
''               'If tpnini$("EditInvoice", "0") = "0" Then
''               '      HEdit 0, tmp$
''               '   Else
''               '      HEdit 1, tmp$
''               '   End IF
''
''               '25Sep98 CKJ Replaced above block with context enabled version
''               FillPrintHeapPN
''               parseRTF (dispdata$ & Iff(UCase$(pid.sex) = "B", "\TPN-INVB.RTF", "\TPN-INV.RTF")), tmp$
''               Hedit Iff(tpnini$("EditInvoice", "0") = "0", 10, 11), tmp$    '10 view 11 edit file
''
''               ans$ = "Y"
''               'k.helpnum = 145
''               Confirm "?Invoice", "print invoice", ans$, k
''
''               If ans$ = "Y" And Not k.escd Then
''                     'HEdit 3, tmp$                                          '25Sep98 CKJ removed
''                     Parseandprint tmp$, 1                                   'context is PNsheet
''                     'could do with check on printing before incrementing !!**
''                     GetPointer dispdata$ & "\tpninvce.dat", invnum&, True
''                  End If
''
''               If tpnini("DeliveryNote", "0") <> "0" Then
''                     ans$ = "Y"
''                     'k.helpnum = 145
''                     Confirm "?Delivery Note", "print delivery note", ans$, k
''
''                     If ans$ = "Y" And Not k.escd Then
''                           Parseandprint dispdata$ & "\tpn-DEL.RTF", 1       'context is PNsheet
''                        End If
''                  End If
''            End If
''      End If
''
''   k.escd = False

End Sub

Sub PrintlistBoxContents()
'18Jul00 CKJ block moved from inline in ViewDB to its own procedure
'06Apr01 CKJ Corrected fault where first line is not printed.  (#51290)
'04Jan17 TH Use rtf Templates from DB (Hosted)

Dim i As Integer

   RTFinternalTransfer$ = LstBoxFrm.lblTitle & "[cr][ulineon][boldon]" & LstBoxFrm.lblHead & "[boldoff][ulineoff][cr][cr]"
   'For i = 1 To LstBoxFrm.LstBox.ListCount - 1                                             06Apr01 CKJ First line is line 0
   For i = 0 To LstBoxFrm.LstBox.ListCount - 1                                             '   "
      RTFinternalTransfer$ = RTFinternalTransfer$ & LstBoxFrm.LstBox.List(i) & "[cr]"
   Next
   replace RTFinternalTransfer$, cr, "[cr]", 0
   replace RTFinternalTransfer$, TB, "[Tab]", 0
   ParseCtrlChars dispdata$ & "\printer.ini", "RTF", RTFinternalTransfer$, 0
   Heap 10, gPRNheapID, "internal", RTFinternalTransfer$, 0
   'ParseThenPrint "PNsheet", dispdata$ & "\tpn-DBP.rtf", 1, 0, False
   ParseThenPrint "PNsheet", dispdata$ & "\tpn-DBP.rtf", 1, 0, False, False '04Jan17 TH Use rtf Templates from DB (Hosted)

End Sub

Sub printnotes(title$, Item$)
'                    Prescription printing programme
'Escape sorted
'modifications
' 8Oct88 ASC All file handling now from library
'23Oct88 ASC Electrolytes printed as mmols
' 1Nov88 ASC Name of regimen and date changed added
' 2Nov88 ASC Prints constituents /kg if Child
'18Jan90 ASC Converted to q45
'25Feb90 ASC contits and constitsperkg print the contituents at the bottom
'            from sub programme in tpnsubs to three sig figures.
' 1Aug95 CKJ invokes INI file
'--PRINT INSERT FOR NOTES----
'29Apr92 CKJ Added 0.0001 to weight calculation
' 1Aug95 CKJ invokes INI file
'----------------------------
' 7Aug95 CKJ Combines notes & script into one routine
' 1Oct96 CKJ Now uses four rtf files:
'            TPN-xyy.RTF     where x is A/P and yy is SC/NO for script/notes
'05Jun00 CKJ Number of copies can be preset in TPN.INI [], defaults are 1 copy (Enh 556 & 625)
'             NotesAcopies  = "2"    'adult notes
'             NotesPcopies  = "2"    'paed  notes
'             ScriptAcopies = "2"    'adult prescription
'             ScriptPcopies = "2"    'paed  prescription
'25Jul00 CKJ Corrected error by moving 'copies' line


'!!** otherfluids would never work - not in scope
'!!** indeterminate as to how combined/separate adult/paed should be handled
                               
Dim RTFtype$, ans$
Dim copies As Integer                            '05Jun00 CKJ
   
   'k.helpnum = 930
   ans$ = "Y"
   Confirm "!n!bPN Prescription", "print " & title$, ans$, k
   
   If ans$ = "Y" And Not k.escd Then
         ''calctotals ""
''         Select Case pid.sex
''            Case "m", "f", "u": RTFtype$ = "P"
''            Case Else:          RTFtype$ = "A"
''            End Select
            
         If adult("") Then
            RTFtype$ = "A"
         Else
            RTFtype$ = "P"
         End If
         copies = Val(TxtD$(dispdata$ & "\pn.ini", "", "1", Item$ & RTFtype$ & "Copies", 0))   '25Jul00 CKJ Moved from below
         If Item$ = "Notes" Then
               RTFtype$ = RTFtype$ & "NO"     'notes
            Else
               RTFtype$ = RTFtype$ & "SC"     'script
            End If
         
         'Parseandprint dispdata$ & "\tpn-" & RTFtype$ & ".rtf", 1                              '05Jun00 CKJ
         'copies = Val(txtd$(dispdata$ & "\tpn.ini", "", "1", item$ & RTFtype$ & "Copies", 0))  '   "         25Jul00 removed
         Parseandprint dispdata$ & "\tpn-" & RTFtype$ & ".rtf", copies                          '   "
         
         'GetTextfile dispdata$ & "\tpn-" & RTFtype$ & ".rtf", txt$, dummy%
         '
         'Do
         '   changed = False
         '   ParseTPNDataItems txt$, changed
         '   ParseCtrlChars dispdata$ + tpninifile$, "", txt$, changed
         '   ParseCtrlChars dispdata$ + "\printer.ini", "RTF", txt$, changed
         'Loop While changed
         '
         'HEdit 3, txt$       'print it
      End If
   k.escd = False

End Sub

Sub PrintTPNlabel()
'-----------------------------------------------------------------------------
'23Nov91 CKJ Changed Onlyone% to Combined since Onlyone had several meanings.
'            Combined = true   all ingredients in one combined bag
'            Combined = false  separate amino & fat bags
'12Nov92 CKJ Added printer check at start, but not on each line yet.
'12Aug94 CKJ/NAH Mod to Consultant search - mid$ not right$
'            Now OK if wardcode.dat & conscode.dat missing - prints just code
'15Jan95 ASC Day Abbreviations now in .044
'23Jan95 CKJ Day name taken from file, not from DateTime library
'22May95 CKJ Changed "days]" to "days"
'08Dec98 CKJ Only call Issueegimen if set in the defaults (avoids a popmsg later)
' 3Sep99 CKJ Merged changes for lipid syringes
'28Jul00 CKJ Now Issuing uses the number of bags specified
'30Mar15 XN  Added PN Paed Label type 102357
'04Jan17 TH  Use the rtf templates from the DB (Hosted)
'05Jan17 TH  Use the rtf templates from the DB (Hosted)
'-----------------------------------------------------------------------------
Dim eno$, entexp$, ltbp$, Info$, ttl$, afm%, s1$, count%, c$, s2$, s5$, ans$, s6$, s7$, s8$, s9$, baxapath$
Dim numbags%, numlbls$, lblnos%, success%
Dim iNumberOfSyringes As Integer       '01Jul99 CKJ
Dim sMsg As String                     '   "
Dim sRTFforSyringe As String           '   "
Dim sSyringeDescription As String      '   "
Dim strAdminDate As String      '27Mar12 TH Added
Dim intBagLoop As Integer           '19Apr12 TH Added
Dim Bagdate As Date                 '19Apr12 TH Added
Dim strDateFormat As String         '19Apr12 TH Added
Dim LBtype$                                                     '30Mar15 XN Added 102357
Dim iBaxaInterfaceType As Integer
Dim strAns As String
Dim sTitle As String: sTitle = "Baxa Compounder Interface"

'Check for interface type 3 is enable and check baxa files are generated for lables
iBaxaInterfaceType = Val(TxtD(dispdata$ & "\pn.ini", "Baxa", "2", "BaxaInterfaceType", 0))
Select Case iBaxaInterfaceType
Case 3
    baxapath$ = siteinfo$("BaxaDRV", "") & "\BAXA\"
    If Not lblscombined Then
      If Not fileexists(baxapath$ & "?+A???????-" & batchnumber$ & ".PAT") Then
      strAns = "N"
        popmsg sTitle, _
        "Barcodes for Baxa files cannot be printed on labels if the Baxa interface files " & crlf & _
        "have not been generated first.Are you sure you wish to generate Label Print?", _
         MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION, strAns, k.escd
       End If
       If strAns = "N" Then
        k.escd = True
        strPNOutputMessage = strPNOutputMessage & crlf & ""
       End If
    Else
      If Not fileexists(baxapath$ & "?+M???????-" & batchnumber$ & ".PAT") Then
        strAns = "N"
        popmsg sTitle, _
        "Barcodes for Baxa files cannot be printed on labels if the Baxa interface files " & crlf & _
        "have not been generated first.Are you sure you wish to generate Label Print?", _
         MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION, strAns, k.escd
       End If
       If strAns = "N" Then
        k.escd = True
        strPNOutputMessage = strPNOutputMessage & crlf & ""
       End If
      End If
End Select

   eno$ = tp("Enterno")
   'enohf$ = eno$ + tp("hoursfor")
   entexp$ = tp("Enterex")
   ltbp$ = tp("labelpt")

   If pid.sex = " " Then
         Info$ = ""           'ASC 26Sep93
      ElseIf UCase$(pid.sex) = "B" Then
         Info$ = tp("Batch")  'Batch production'
      ElseIf adult(pid.sex) Then
         Info$ = tp("infoA")  'Adult TPN'
      Else
         Info$ = tp("infoP")  'Paediatric TPN'
      End If
   'infobar hospabbr$, Info$ + tp("Labels"), "5.0"
   ttl$ = Info$ + tp("Labels")

   If Len(Trim$(batchnumber$)) = 0 Then popmessagecr ttl$, tp("Nobatch")

   afm = 3                    ' amino/fat/mixed
   'If UCase$(pid.sex) <> "B" Then
   If Not lblscombined Then                '##
      afm = 1
      s1$ = tp("Separate")
   Else
      s1$ = tp("Combined")
   End If
    s1$ = s1$ & tp("Fatamino")
   'End If

   '--NUMBER OF LABELS INPUT--
   'If UCase$(pid.sex) <> "B" Then
   'Feb12 TH After Speaking with nick -
   strAdminDate = Format(m_SupplyRequestAdminStartDate, "DD/MMM/YYYY")
   
   k.Max = 9
   If Right(strAdminDate, 4) = "1899" Then
      strDateFormat = TxtD(dispdata & "\PN.ini", "", "dddd dd/mmm/yyyy", "LblNoAdminDateDateFormat", 0)
      'today DT1
      strAdminDate = ""
      Bagdate = Now
   Else
      'StringToDate Format(m_SupplyRequestAdminStartDate, "DD/MM/YYYY"), DT1
      strDateFormat = TxtD(dispdata & "\PN.ini", "", "dddd dd/mmm/yyyy", "LblAdminDateDateFormat", 0)
      Bagdate = m_SupplyRequestAdminStartDate
   End If
   
   For intBagLoop = 1 To m_intNumberofbags '18Apr12 TH Added
   
      If Trim$(strDateFormat) = "" Then
         dayofwk$ = ""
      Else
         'dayofwk$ = tp("Day" & Format$(DayOfWeek(DT1)))   '23Jan95 CKJ
         'DateToString DT1, strAdminDate
         dayofwk$ = Format$(Bagdate, strDateFormat)
         
         'k.helpnum = 430
         '''inputwin ttl$, tp("Enterday"), dayofwk$, k
         '''If k.escd Then Exit Sub
         'strAdminDate =format$(strAdminDate
         'For count = 1 To 7         '1=Monday ... 7=Sunday
         '   c$ = Trim$(Str$(count))
         '   If UCase$(dayofwk$) = tp("DayAb" + c$) Then
         '      dayofwk$ = tp("Day" + c$)
         '      Exit For
         '   End If
         'Next
         ''s2$ = dayofwk$ & cr$
         'DT2.day = m_intDaysPerBag
         'DT1 = DT1 + 1 * 24
         'AddExpiry DT1, DT2
         Bagdate = DateAdd("d", m_intDaysPerBag, Bagdate)
      End If
         'infrateamino = Val(ans$)   'now done in QuesScrl
         'infratefat = Val(ans$)
      'End If

'13Mar12 TH Removed after speaking with NAH
''   s5$ = "PN for " & s2 & cr & entexp$
''   If Not lblscombined Then s5$ = s5$ & tp("foramino")
''   s5$ = s5$ & "[" & Format$(Val(tpndef.expiry(afm))) & tp("days") & " from today]"   '22May95 CKJ
''   today DT1
''   StringToDate tpndef.expiry(afm), DT2
''   DT2.mint = 0
''   AddExpiry DT1, DT2
''   DateToString DT1, ans$
''   k.Max = 10
''   ''k.begline = True
''   ''k.overwrite = True
''   'k.helpnum = 460
''   inputwin ttl$, s5$, ans$, k
''   If k.escd Then Exit Sub
''   expiryA$ = ans$

'19Mar12 TH Remove lipid part too !
''   If Not lblscombined Then                   '4Jan96 Changed fat to lipid
''      s6$ = "PN for " & s2 & cr & entexp$ & "for lipid part  [" & Format$(Val(tpndef.expiry(2))) & tp("days") & " from today]"  '22May95 CKJ
''      k.Max = 10
''      today DT1
''      StringToDate tpndef.expiry(2), DT2
''      DT2.mint = 0
''      AddExpiry DT1, DT2
''      DateToString DT1, ans$
''      ''k.begline = True
''      ''k.overwrite = True
''      'k.helpnum = 470
''      inputwin ttl$, s6$, ans$, k
''      If k.escd Then Exit Sub
''      expiryB$ = ans$
''   End If
                
   ''   If tpnini$("bagnoQ", "0") = "1" And UCase$(pid.sex) = "B" Then
   ''         s7$ = eno$ & tp("numbags")
   ''         'k.helpnum = 940
   ''         k.nums = True
   ''         k.Max = 2
   ''         k.min = 1
   ''         ans$ = "1"
   ''         inputwin ttl$, s7$, ans$, k
   ''         If k.escd Then Exit Sub
   ''         numbags = Val(ans$)
   ''      Else
            numbags = 1
   ''      End If
   
''      numlbls$ = ""
''      If tpnini$("calclbls", "0") = "1" Then
''            If pid.status = "O" Then
''                  lblnos = numbags * Val(tpnini$("oplbls", "1")) + Val(tpnini$("opextra", "0")) '= N x 1 + 2
''               Else
''                  lblnos = numbags * Val(tpnini$("iplbls", "1")) + Val(tpnini$("ipextra", "0")) '= N x 3 + 0
''               End If
''            numlbls$ = Trim$(Str$(lblnos))
''         End If
   
      s8$ = eno$
      If lblscombined Then
''            s8$ = s8$ & ltbp$ & "               "
            'k.helpnum = 490
            ncwf = 0
''         Else
''            s8$ = s8$ & tp("AMINO") & ltbp$ & "     "
''            'k.helpnum = 650
         End If
      ncwa = tpndef.NumLabels(afm)
''      k.nums = True
''      k.Max = 2
''      k.min = 1
''      ans$ = LTrim$(Str$(tpndef.NumLabels(afm)))
''      If ans$ = "0" Then ans$ = ""
''      If numlbls$ <> "" Then ans$ = numlbls$
''      inputwin ttl$, s8$, ans$, k
''      If k.escd Then Exit Sub
''      ncwa = Val(ans$)
   
      If Not lblscombined Then
         ncwf = tpndef.NumLabels(2)
''         s9$ = eno$ & tp("FAT") & ltbp$ & "           "
''         ans$ = LTrim$(Str$(tpndef.NumLabels(2)))
''         If ans$ = "0" Then ans$ = ""
''         If numlbls$ <> "" Then ans$ = numlbls$
''         k.nums = True
''         k.Max = 2
''         k.min = 1
''         'k.helpnum = 660
''         inputwin ttl$, s9$, ans$, k
''         If k.escd Then Exit Sub
''         ncwf = Val(ans$)
      End If
   
      If Not k.escd And (ncwa > 0 Or ncwf > 0) Then
            ans$ = "Y"
            'k.helpnum = 670
            'confirm "Label Printing", "print labels", ans$, k
            If Not k.escd Then
                  Screen.MousePointer = HOURGLASS
                  bagLoop = intBagLoop
                  FillPrintHeapPN
                  If ncwa Then                                 'AMINO/COMBINED & BATCH
                     'If UCase$(pid.sex) = "B" Then   '02Mar12 TH Removed batch
                     '   ParseThenPrint "PNlabel", dispdata$ & "\TPN-LBLB.rtf", ncwa, success, False
                     'Else
                     
                                         ' Select if using Paed or adult/normal label 102357 30Mar16 XN
                                         If Not adult("") And HasLayout("505") Then
                        LBtype$ = "LBLPA"
                     Else
                        LBtype$ = "LBLA"
                     End If
                     
                     'ParseThenPrint "PNlabel", dispdata$ & "\TPN-LBLA.rtf", ncwa, success, False  102357 30Mar16 XN
                     'ParseThenPrint "PNlabel", dispdata$ & "\TPN-" & LBtype$ & ".rtf", ncwa, success, False
                     ParseThenPrint "PNlabel", dispdata$ & "\TPN-" & LBtype$ & ".rtf", ncwa, success, False, False '04Jan17 TH Use the rtf templates from the DB (Hosted)
                     m_blnLabels = True '02Mar12 TH Added
                     'End If
                  End If
   
                  'If ncwf Then ParseThenPrint "PNlabel", dispdata$ & "\TPN-LBLL.rtf", ncwf, success      '03Sep99 CKJ Removed & replaced with block below
                  If ncwf Then
                     LipidSyringes TotLipid!, overage(2), iNumberOfSyringes, sMsg, sSyringeDescription, sRTFforSyringe
                     If Len(sMsg) Then
                        iNumberOfSyringes = 0
                        popmessagecr ".Configuration Error", "Please check and correct the following:" & cr & cr & sMsg
                     End If
                     If iNumberOfSyringes Then
                        Heap 10, gPRNheapID, "NumberOfSyringes", Format$(iNumberOfSyringes), 0
                        Heap 10, gPRNheapID, "SyringeDescription", sSyringeDescription, 0
                        For count = 1 To iNumberOfSyringes
                           Heap 10, gPRNheapID, "SyringeNumber", Format$(count), 0
                           'ParseThenPrint "PNlabel", sRTFforSyringe, ncwf, success, False
                           ParseThenPrint "PNlabel", sRTFforSyringe, ncwf, success, False, False '04Jan17 TH Use the rtf templates from the DB (Hosted)
                        Next
                        Heap 12, gPRNheapID, "NumberOfSyringes", "", 0
                        Heap 12, gPRNheapID, "SyringeNumber", "", 0
                        Heap 12, gPRNheapID, "SyringeDescription", "", 0
                     Else
                        ' Select if using Paed or adult/normal label 102357 30Mar16 XN
                                                If Not adult("") And HasLayout("506") Then
                            LBtype$ = "LBLPL"
                        Else
                            LBtype$ = "LBLL"
                        End If
                        
                        'ParseThenPrint "PNlabel", dispdata$ & "\TPN-LBLL.rtf", ncwf, success, False 102357 30Mar16 XN
                        'ParseThenPrint "PNlabel", dispdata$ & "\TPN-" & LBtype$ & ".rtf", ncwf, success, False
                        ParseThenPrint "PNlabel", dispdata$ & "\TPN-" & LBtype$ & ".rtf", ncwf, success, False, False  '05Jan17 TH Use the rtf templates from the DB (Hosted)
                     End If
                     m_blnLabels = True  '02Mar12 TH Added
                  End If
                  
                  'Screen.MousePointer = STDCURSOR
               End If
   
           
         End If
      
      If Not k.escd And frmVA.mnuIssue.Enabled And tpndef.issueenabled Then   '   "    only call if set in the defaults (avoids a popmsg later)
         'issueregimen True, 1       ' 1Jul97 CKJ Added NumOfBags
         ''issueregimen True, numbags  ' 1Jul97 CKJ Added NumOfBags '28Jul00 CKJ Now actually uses the number specified
      End If
   
   Next
   
Screen.MousePointer = STDCURSOR

End Sub

Sub RegimenInfo()
'''24Oct96 CKJ Added
''' AllPrds (0-33,  ...      ingredients: volume = 0 to Vitamin K = 33
'''    "      ...   0-20)    0 is total, 1-20 is the qty given by each product in regimen
'''03Jan97 CKJ Extended wording of detail box
'''14jun98 CKJ Added per litre aq/lip                                  !!** Needs more
'''02Jun99 CKJ Avoid Div by 0 if no aqueous or no lipid portion
'''05Jun00 CKJ Corrected display of aqueous/lipid columns
'''28Jul00 CKJ Added tsf() to totals
''
''ReDim allprds(33, 20) As Single, prodnames$(20), lines$(5)
''Dim X%, Y%, i%, tmp$, SQLq$, prodsfound%, amount!, item%, numlines%
''ReDim AqIgs(0 To 33) As Single, LipIgs(0 To 33) As Single              '05Jun00 CKJ Added
''
''   If tot!(IgVol) > 0 Then
''         Screen.MousePointer = HOURGLASS
''         calctotals ""                                                 '05Jun00 CKJ added as belt & braces
''         prodsfound = 0
''         For X = 0 To NP - 1
''            If ig(X) > 0 Then     'some of this product present
''                  SQLq = "SELECT * FROM prddat WHERE LinkCode='" & Prd(X).linkcode & "';"
''                  If SQLdbg Then popmessagecr "SQL", SQLq
''                  Set prdss = prddb.CreateSnapshot(SQLq)
''                  prddbopen = 2
''
''                  If Not prdss.EOF Then
''                        prodsfound = prodsfound + 1
''                        prodnames$(prodsfound) = Prd(X).name
''                        allprds(0, 0) = allprds(0, 0) + ig(X)          'volume
''                        allprds(0, prodsfound) = ig(X)                 'volume
''
''                        If Prd(X).SolnAB = "B" Then                    '05Jun00 CKJ Added block for Volume
''                              LipIgs(0) = LipIgs(0) + ig(X)
''                           Else
''                              AqIgs(0) = AqIgs(0) + ig(X)
''                           End If
''
''                        For Y = 1 To 33     'FIXED VALUE
''                           'amount! = ig(x) * Getfield(prdss.Fields(y)) / prod!(x, IgVol)
''                           amount! = ig(X) * GetField(prdss.Fields(tp("PrdDat" & Format(Y)))) / prod!(X, IgVol)    '11Jul98 CKJ Look field name up before use
''                           allprds(Y, prodsfound) = amount!
''                           allprds(Y, 0) = allprds(Y, 0) + amount!
''
''                           If Prd(X).SolnAB = "B" Then                 '05Jun00 CKJ Added block for Ingredient
''                                 LipIgs(Y) = LipIgs(Y) + amount!
''                              Else
''                                 AqIgs(Y) = AqIgs(Y) + amount!
''                              End If
''                        Next
''                     End If
''               End If
''         Next
''
''         'k.helpnum = 0
''         LstBoxFrm.Caption = "PN Regimen"
''         'LstBoxFrm.lblTitle = cr & "Total of all ingredients in current regimen" & cr                        '05Jun00 CKJ
''         tmp$ = cr & "Total of all ingredients in current regimen" & cr                                       '   "
''         If Not lblscombined Then                                                                             '   "
''               'tmp$ = tmp$ & "Aqueous volume " & AqIgs(0) & " ml,   Lipid volume " & LipIgs(0) & " ml" & cr  '   "
''               tmp$ = tmp$ & "Aqueous volume " & tsf$(AqIgs(0)) & " ml,   Lipid volume " & tsf$(LipIgs(0)) & " ml" & cr   '28Jul00 CKJ added tsf()
''            End If                                                                                            '   "
''         LstBoxFrm.lblTitle = tmp$
''
''         tmp$ = pad("  Name", 20) & TB & "Units      " & TB & "Total      " & TB       '14Jun98 CKJ amended
''         If lblscombined Then
''               tmp$ = tmp$ & "/litre     "
''            Else
''               tmp$ = tmp$ & "/litre (aq)" & TB & "/litre (lip)"
''            End If
''         LstBoxFrm.lblHead = tmp$ & TB & "/Kilo"                                       '05Jun00 was Per Kilo, changed for consistency
''         tmp$ = "  Volume" & TB & "ml" & TB & Trim$(tsfvdu$(allprds(0, 0))) & TB       '14Jun98 CKJ added TB
''         If Not lblscombined Then tmp$ = tmp$ & "-----" & TB                           '   "          "       05Jun00 CKJ Added dashes
''         tmp$ = tmp$ & "-----"                                                         '05Jun00 CKJ Added dashes
''         If weight! > 0 Then tmp$ = tmp$ & TB & Trim$(tsfvdu$(allprds(0, 0) / weight!))
''         LstBoxFrm.LstBox.AddItem tmp$
''         For X = 1 To 33  'for each attribute of the regimen
''            'deflines (prdss.Fields(x).Name), lines$(), "_", 1, numlines   '12Jul98 CKJ
''            deflines tp("PrdDat" & Format(X)), lines$(), "_", 1, numlines  '   "
''            tmp$ = "  "
''            For i = 1 To numlines - 1
''               tmp$ = tmp$ & lines$(i) & " "
''            Next
''            tmp$ = tmp$ & TB & lines$(numlines) & TB & Trim$(tsfvdu$(allprds(X, 0))) & TB
''
''            'tmp$ = tmp$  & Trim$(tsfvdu$(1000 * allprds(x, 0) / TotAmino))  08Jun98 CKJ !!** for discussion
''
''            '05Jun00 CKJ Removed block, replaced with IF block below
''            ''AquTxt$ = Iff(TotAmino, Trim$(tsfvdu$(1000 * allprds(x, 0) / TotAmino)), "---")   '12Jul98 CKJ
''            'AquTxt$ = "---"                                                                    '02Jun99 CKJ Avoid Div by 0
''            'If TotAmino > 0 Then AquTxt$ = Trim$(tsfvdu$(1000 * allprds(x, 0) / TotAmino))     '   "
''            ''LipTxt$ = Iff(TotLipid, Trim$(tsfvdu$(1000 * allprds(x, 0) / TotLipid)), "---")   '12Jul98 CKJ
''            'LipTxt$ = "---"                                                                    '02Jun99 CKJ Avoid Div by 0
''            'If TotLipid > 0 Then LipTxt$ = Trim$(tsfvdu$(1000 * allprds(x, 0) / TotLipid))     '   "
''            '
''            'If lblscombined Then
''            '      tmp$ = tmp$ & AquTxt$
''            '   Else
''            '      If Prd(x).SolnAB = "B" Then
''            '            tmp$ = tmp$ & TB & LipTxt$
''            '         Else
''            '            tmp$ = tmp$ & AquTxt$ & TB
''            '         End If
''            '   End If
''
''            If lblscombined Then                                                                  '05Jun00 CKJ block written
''                  If allprds(0, 0) > 0 Then                                                       '   "
''                        tmp$ = tmp$ & Trim$(tsfvdu$(1000! * allprds(X, 0) / allprds(0, 0)))       '   "
''                     End If                                                                       '   "
''               Else                                                                               '   "
''                  If TotAmino > 0 Then tmp$ = tmp$ & Trim$(tsfvdu$(1000! * AqIgs(X) / TotAmino))  '   "
''                  tmp$ = tmp$ & TB                                                                '   "
''                  If TotLipid > 0 Then tmp$ = tmp$ & Trim$(tsfvdu$(1000! * LipIgs(X) / TotLipid)) '   "
''               End If
''
''            If weight! > 0 Then
''                  tmp$ = tmp$ & TB & Trim$(tsfvdu$(allprds(X, 0) / weight!))
''               End If
''            LstBoxFrm.LstBox.AddItem tmp$
''         Next
''
''         Screen.MousePointer = STDCURSOR
''
''         Do
''            LstBoxShow
''            item = LstBoxFrm.LstBox.ListIndex
''            If item > -1 Then
''                  deflines (LstBoxFrm.LstBox.List(item)), lines$(), TB, 1, numlines
''                  tmp$ = Format$(Val(lines$(3))) & " " & lines$(2) & " " & Trim$(lines$(1)) & " total:" & cr
''                  For X = 1 To prodsfound
''                     If allprds(item, X) > 0 Then
''                           'tmp$ = tmp$ & cr & Trim$(tsf$(allprds(item, x))) & TB & prodnames$(x)      3Jan97 CKJ Extended wording
''                           tmp$ = tmp$ & cr & Trim$(tsf$(allprds(item, X))) & " " & lines$(2) & " " & Trim$(lines$(1)) & " from " & prodnames$(X)
''                        End If
''                  Next
''                  popmessagecr "List of products by ingredient", tmp$
''               End If
''         Loop Until item = -1
''
''         Unload LstBoxFrm
''         If prddbopen = 2 Then prdss.Close: prddbopen = 1
''      Else
''         popmessagecr "PN Regimen", "Volume of regimen is zero"
''      End If
   
End Sub

Sub RegStatus()
'''14Apr98 CKJ Added overages for paed bags
'''14Oct98 CKJ Uses picture box instead of frame/label - allows font & bold changes
'''15Oct98 CKJ Use OCXhospnum if available
'''05Jun00 CKJ Added block to show glucose concentration & glucose:lipid ratio
'''18Jul00 CKJ Allowed the glucose conc & gluc:lipid ratio to be shown in batch mode
'''            Removed ward, cons, status and weight from batch mode
'''            Disable several menu options & buttons for batch mode
'''25Jul00 CKJ Added view only checks
''
''Dim authstatus%, temp$, fBold%, fSize%, fName$, OCXhospnum$
''Dim FatCHOratio$                                                '05Jun00 CKJ Added
''
''   defregstring regname$, origdate$, temp$
''
''   frmVA.F3D2.tabstop = False
''   frmVA.F3D2.AutoRedraw = True
''   frmVA.F3D2.Cls
''
''   frmVA.F3D2.FontBold = True
''   frmVA.F3D2.Print " Regimen: ";
''   frmVA.F3D2.FontBold = False
''   frmVA.F3D2.Print temp$ & "   ";
''
''   If adult(pid.sex) Then
''         If lblscombined Then
''               frmVA.F3D2.Print "Combined regimen in single bag"
''            Else
''               frmVA.F3D2.Print "Separate aqueous and lipid bags"
''            End If
''      Else
''         frmVA.F3D2.FontBold = True
''         frmVA.F3D2.Print "Overage: ";
''         frmVA.F3D2.FontBold = False
''         If lblscombined Then
''               frmVA.F3D2.Print Format$(overage(3)) & " ml (Combined)"
''            Else
''               frmVA.F3D2.Print "aqueous " & Format$(overage(1)) & " ml, ";
''               frmVA.F3D2.Print "lipid " & Format$(overage(2)) & " ml"
''            End If
''      End If
''
''   frmVA.F3D2.FontBold = True
''   frmVA.F3D2.Print " Route: ";
''   frmVA.F3D2.FontBold = False
''   Select Case CP$
''      Case "C":  frmVA.F3D2.Print tp("IVcent");
''      Case "P":  frmVA.F3D2.Print tp("IVperi");
''      Case "E":  frmVA.F3D2.Print tp("IVcorp");
''      Case Else: frmVA.F3D2.Print tp("IVunkn");
''      End Select
''
''   frmVA.F3D2.FontBold = True
''   frmVA.F3D2.Print "    Type: ";
''   frmVA.F3D2.FontBold = False
''   If iBatchMode Then                                                       '18Jul00 CKJ added
''         frmVA.F3D2.Print "Batch (Adult)";                                   '   "
''      ElseIf adult(pid.sex) Then
''         frmVA.F3D2.Print "Adult";
''      Else
''         frmVA.F3D2.Print "Paediatric";
''      End If
''   'If UCase$(pid.sex) = "B" Then                                           '18Jul00 CKJ removed
''   '      frmVA.F3D2.Print "/Batch";                                        '   "
''   '   End If                                                               '   "
''
''   frmVA.F3D2.FontBold = True
''   frmVA.F3D2.Print "    Status: ";
''   frmVA.F3D2.FontBold = False
''   authstatus = False
''   If TPNchanged Then
''         frmVA.F3D2.Print "Edited";
''      ElseIf GetField(patds!AuthModUser) <> "" Then
''         frmVA.F3D2.Print "Authorised";
''         authstatus = True
''      Else
''         frmVA.F3D2.Print "Saved";
''      End If
''
''   frmVA.F3D1.AutoRedraw = True
''   frmVA.F3D1.tabstop = False
''   frmVA.F3D1.Cls
''
''   '05Jun00 CKJ Added block
''   'If pid.sex <> "B" Then                                                  '18Jul00 CKJ removed so it displays in batch
''   calctotals ""
''   frmVA.F3D1.FontBold = True
''   frmVA.F3D1.Print " Glucose concentration: ";
''   frmVA.F3D1.FontBold = False
''   If TotAmino > 0 Then
''         frmVA.F3D1.Print Trim$(tsfvdu(TotGlucA * 100 / TotAmino)); "% aqueous part only";
''         If lblscombined Then
''               frmVA.F3D1.Print ",  "; Trim$(tsfvdu(tot!(igGl) * 100 / tot!(0))); "% or more combined";
''            End If
''      Else
''         frmVA.F3D1.Print "N/A";
''      End If
''
''   CalcFatCHOratio 0, 0, FatCHOratio$
''   frmVA.F3D1.FontBold = True
''   frmVA.F3D1.Print "  Calorie ratio: ";
''   frmVA.F3D1.FontBold = False
''   frmVA.F3D1.Print FatCHOratio$; " percent kcals fat:glucose";
''   '   End If                                                               '18Jul00 CKJ removed
''   frmVA.F3D1.Print
''
''   frmVA.F3D1.FontBold = True
''   frmVA.F3D1.Print " Name: ";
''   frmVA.F3D1.FontBold = False
''   fName$ = frmVA.F3D1.FontName
''   fBold% = frmVA.F3D1.FontBold
''   fSize% = frmVA.F3D1.FontSize
''   On Error Resume Next
''   frmVA.F3D1.FontName = terminal$("MsgBoxFontName", "")
''   frmVA.F3D1.FontBold = False
''   frmVA.F3D1.FontSize = Val(terminal$("MsgBoxFontSize", ""))
''   On Error GoTo 0
''   frmVA.F3D1.Print patientname$;
''   frmVA.F3D1.FontName = fName$
''   frmVA.F3D1.FontBold = fBold
''   frmVA.F3D1.FontSize = fSize
''
''   If Not iBatchMode Then                                                   '18Jul00 CKJ added to prevent display in batch
''         frmVA.F3D1.FontBold = True
''         frmVA.F3D1.Print "   Status: ";
''         frmVA.F3D1.FontBold = False
''         frmVA.F3D1.Print pid.status;
''
''         frmVA.F3D1.FontBold = True
''         frmVA.F3D1.Print "   Ward: ";
''         frmVA.F3D1.FontBold = False
''         frmVA.F3D1.Print Trim$(pid.ward);
''
''         frmVA.F3D1.FontBold = True
''         frmVA.F3D1.Print "   Cons: ";
''         frmVA.F3D1.FontBold = False
''         frmVA.F3D1.Print Trim$(pid.cons);
''
''         frmVA.F3D1.FontBold = True
''         frmVA.F3D1.Print "   Case No: ";
''      Else                                                                  '18Jul00 CKJ added
''         frmVA.F3D1.FontBold = True                                         '   "
''         frmVA.F3D1.Print "   Record No: ";                                 '   "
''      End If                                                                '   "
''
''   frmVA.F3D1.FontBold = False
''   Heap 11, gPRNheapID, "OCXhospnum", OCXhospnum$, 0                        '15Oct98 CKJ
''   OCXhospnum$ = Trim$(asciiz$(OCXhospnum$))                                '   "
''   If OCXhospnum$ = "" Then OCXhospnum$ = Trim$(pid.caseno)                 '   "
''   'frmVA.F3D1.Print Trim$(pid.caseno);                                     '   "
''   frmVA.F3D1.Print OCXhospnum$;                                            '   "
''
''   If Not iBatchMode Then                                                   '18Jul00 CKJ added to prevent display in batch
''         frmVA.F3D1.FontBold = True
''         frmVA.F3D1.Print "   Weight: ";
''         frmVA.F3D1.FontBold = False
''         frmVA.F3D1.Print Format$(weight) & "kg"
''      End If                                                                '18Jul00 CKJ added
''
''   frmVA.cmdVA(0).Enabled = Not iBatchMode                                  '18Jul00 CKJ Prevent Prescription use in batch
''   frmVA.cmdVA(1).Enabled = Not iBatchMode And Not TpnVO                    '   "        Clinical details  '25Jul00 CKJ Added view only check
''   frmVA.menuPrescription.Enabled = Not iBatchMode                          '   "        Prescription
''   frmVA.mnuClinDet.Enabled = Not iBatchMode                                '   "        Clinical details
''   frmVA.mnuGlucose(1).Enabled = Not iBatchMode                             '   "        Glucose by mg/kg/24hrs
''   frmVA.mnuAddEnteral.Enabled = Not iBatchMode                             '   "        Enter enteral product
''   frmVA.mnuAddEnteral.Visible = Not iBatchMode                             '   "          "
''   frmVA.mnuInfusion.Enabled = Not iBatchMode                               '   "        Enter infusion product
''   frmVA.mnuInfusion.Visible = Not iBatchMode                               '   "          "
''   frmVA.mnuSep3.Visible = Not iBatchMode                                   '   "        Hide extra separator
''   frmVA.mnuNew(2).Enabled = Not iBatchMode                                 '   "        Remove enteral products
''   frmVA.mnuNew(2).Visible = Not iBatchMode                                 '   "          "
''   frmVA.mnuNew(3).Enabled = Not iBatchMode                                 '   "        Remove other infusions
''   frmVA.mnuNew(3).Visible = Not iBatchMode                                 '   "          "
''   frmVA.mnuSep6.Visible = Not iBatchMode                                   '   "        Hide extra separator
''   frmVA.mnuElec.Enabled = Not iBatchMode                                   '   "        Electrolyte results
''   frmVA.mnuElec.Visible = Not iBatchMode                                   '   "          "
''   frmVA.mnuSpecial.Enabled = Not TpnVO                                     '25Jul00 CKJ Added view only check
''
''   frmVA.cmdVA(4).Enabled = Not authstatus And Not TpnVO                    '25Jul00 CKJ Added view only check
''   frmVA.mnuSave.Enabled = Not authstatus And Not TpnVO                     '   "
''   frmVA.mnuAuth.Enabled = Not authstatus And Not TpnVO                     '   "
''   frmVA.mnuPrint.Enabled = authstatus
''   frmVA.mnuPrnOpts.Enabled = authstatus
''   frmVA.cmdVA(5).Enabled = authstatus

End Sub

Sub RememberK()
''Dim X%
''
''   totK! = 0
''   For X = 0 To NP - 1
''      If ig(X) > 0 Then   '        mmol K per ml/ container volume
''            totK! = totK! + ig(X) * prod!(X, igK) / prod!(X, 0)
''         End If
''   Next

End Sub

Sub RememberNa()
''Dim X%
''
''   totNa! = 0
''   For X = 0 To NP - 1
''      If ig(X) > 0 Then   '        mmol Na per ml/ container volume
''            totNa! = totNa! + ig(X) * prod!(X, IgNa) / prod!(X, 0)
''         End If
''   Next

End Sub

Sub AdjustOverage(Index As Integer)
'''14Apr98 CKJ Allow a single product to determine the overage
'''            eg a Kabimix bag with a couple of additives
'''            - the whole bag will be sent out but only part infused.
'''            NB Cannot get Index = 2 unless separate labels specified
'''24Sep98 CKJ Added adult/paed usage check
''
''Dim afm%, X%, keep%, conts!, valid%, tmp$, ans$, total!, ovg!, volX!
''
''   afm = Index                                             'amino/fat/mixed
''   If afm = 1 And lblscombined Then afm = 3
''
''   calctotals Choose(afm, "A", "B", "")
''   total! = tot!(0)                                        'we'll need this later
''   calctotals ""                                           'put this back as it was
''   If total! = 0 Then
''         popmessagecr "", "Cannot adjust overage until regimen defined"
''         Exit Sub
''      End If
''
''   Screen.MousePointer = HOURGLASS
''   LstBoxFrm.Caption = "Select Product"
''   LstBoxFrm.lblTitle = cr & "Overage will be adjusted so that whole containers of one product can be used." & cr & "Select the product which is to be used in full" & cr
''   LstBoxFrm.lblHead = "  Product" & Space$(23) & TB & " Volume"
''   For X = 0 To NP - 1
''      keep = True
''      If afm = 1 And RTrim$(Prd(X).SolnAB) = "B" Then keep = False
''      If afm = 2 And RTrim$(Prd(X).SolnAB) = "A" Then keep = False
''      'If ig(x) > 0 And keep Then                                              '24Sep98 CKJ
''      If ig(X) > 0 And keep And ForAPuse(X) Then                               '24Sep98 CKJ Added
''            LstBoxFrm.LstBox.AddItem "  " & Prd(X).name & TB & tsf(ig(X)) & " " & tp("ml")
''            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = X
''         End If
''   Next
''
''   Screen.MousePointer = STDCURSOR
''   LstBoxShow
''   If Len(LstBoxFrm.Tag) Then
''         X = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
''         valid = True
''      End If
''   Unload LstBoxFrm
''
''   If valid Then
''         k.escd = False
''         k.min = Len(Format$(Int(ig(X))))   'ensure at least as many digits
''         k.Max = 4
''         k.nums = True
''         conts! = ig(X) / prod!(X, 0)
''         If conts! > Int(conts!) Then conts! = conts! + 1
''         ans$ = Format$(Int(conts!) * prod!(X, 0))
''         tmp$ = "Prduct: " & RTrim$(Prd(X).name) & Format$(prod!(X, 0), " (#### ml)") & cr & cr
''         tmp$ = tmp$ & "Enter the total volume of this product which is to be used in the final regimen." & cr
''         tmp$ = tmp$ & "This should be one or more whole containers and must be at least " & Format$(ig(X)) & " ml" & cr
''         inputwin "Enter total volume of product", tmp$, ans$, k
''         If Not k.escd Then
''               If Val(ans$) < ig(X) Then
''                     popmessagecr "#", "Volume plus overage must be at least as great as the volume to be infused"
''                  Else
''                     'Now calculate the overage required to use exactly this much of the chosen product
''                     '     ig(x)    other igs    overage
''                     '  x---------x------------x---------x
''                     '  |<       total!       >|    ??
''                     '
''                     ' suppose volX = ig(x) + overage of x   ie the value just typed above
''                     '
''                     '           unused x    +    other igs    / fraction used  -   other igs
''                     'overage = volX - ig(x) + ((total!-ig(x)) * volX / ig(x) ) - (total!-ig(x))
''                     'simplifies to
''                     'overage = volX         + ((total!-ig(x)) * volX / ig(x) ) - total!
''
''                     volX! = Val(ans$)
''                     ovg! = volX! + ((total! - ig(X)) * volX / ig(X)) - total!
''                     ovg! = Val(tsf(ovg!))
''                     popmessagecr "#", "The " & Choose(afm, "aqueous ", "lipid ", "") & "overage required would be " & Format$(ovg!) & " ml"
''                     overage(afm) = ovg!
''                     TPNchanged = True
''                     menuRegimenDetails           'Show standard screen for confirmation
''                  End If
''            End If
''      End If

End Sub

Sub ReturnPNRegimen(PatRecNo$, PrescriptionID&, RecoveryTime$)
'01Oct98 CKJ Written
'            Given Patient recno, prescriptionID (must not be zero)
'            scan translog for today and return all labeltype 'T' issues which match criteria
'            and are for this site. Note that stock returns are ignored.
'            NB items are returned at current cost, not at original price
'19Nov98 CKJ Rewritten, as some sites want the original transaction cancelled instead.
'            Would like INI file option to choose between the methods.
'01Feb99 EAC Added recoverytime
'01Mar99 EAC Corrected passing of Recovery time to ScanLogFile

Dim tofind$, filename$, errcode%, msg$, fil%, pointer&, length%, recno&, issueunitcost$
Dim Increment&, tmp$, logfile$, logfil%, lngDrugRecno As Long, Qty!, CancelLog%, cost!, adjust!      '01Jun02 All/CKJ
Dim t As transaction, dlocal As DrugParameters
         
   CancelLog = True  'needs ini file setting to choose...

   tofind$ = "LBLtype=T,PATRECNO=" & PatRecNo$ & ",PRESCID=" & Format$(PrescriptionID&)
   
   If Trim$(RecoveryTime$) <> "" Then tofind$ = tofind$ & "," & RecoveryTime$ '01Feb99 EAC Added RecoveryTime
   '17Jan12 TH DO We still need this ?
   popmessagecr "", "Return Regimen"
   
                           'daymth       site OPformat
   'errcode = ScanLogFile("T", "", tofind$, "", 1, filename$)
   '''errcode = ScanLogFile("T", "", tofind$, "", Iff(CancelLog, 2, 1), filename$)
''   Select Case errcode
''      Case 1: msg$ = "Type of log file not specified or not supported"
''      Case 2: msg$ = "Date given is not valid"
''      Case 3: msg$ = "Output format requested is not valid"
''      Case 4: msg$ = "Log file specified was not found"
''      Case 0
''         If fileexists(filename$) Then
''               Screen.MousePointer = HOURGLASS
''               If CancelLog Then
''                     fil = FreeFile
''                     Open filename$ For Input As #fil                                 'input channel
''                     Line Input #fil, logfile$                                        'read log file name
''                     length = Len(T)
''                     logfil = FreeFile
''                     openrandomfile logfile$, length, logfil                          'logfile channel
''
''                     Do While Not EOF(fil)
''                        Line Input #fil, tmp$
''                        recno& = Val(tmp$)                                            'record number to amend
''                        If recno& > 1 Then
''                              GetRecordL r, recno&, logfil, length
''                              LSet T = r
''                              tmp$ = T.kind
''                              T.kind = "0"                                            'mark record as cancelled
''                              LSet r = T
''                              PutRecordL r, recno&, logfil, length
''
''                              If Val(T.Qty) <> 0 And tmp$ <> "0" Then                 'Qty present, and not already cancelled
''                                    dlocal.SisCode = T.SisCode
''                                    getdrug dlocal, 0, lngDrugRecno, True             'lock the drug     '01Jun02 All/CKJ
''                                    If lngDrugRecno Then                              '01Jun02 All/CKJ
''                                          Qty! = Val(T.Qty)                           'in issue units
''                                          cost! = Val(T.CostExVAT)                    'total pence for the transaction
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
''                                                popmessagecr "WARNING", "Stores pack size not entered for product '" & T.SisCode & "'"
''                                             End If
''
''                                          dlocal.stocklvl = LTrim$(Str$(dp!(1! * Val(dlocal.stocklvl) + Qty!)))
''                                          dlocal.usethisperiod = dlocal.usethisperiod - Qty!
''                                          putdrug dlocal, lngDrugRecno                 '01Jun02 All/CKJ
''
''                                          If Qty! < 0 And Val(dlocal.stocklvl) < 0 And dlocal.livestockctrl = "Y" Then   'it's been issued into negative
''                                                Screen.MousePointer = STDCURSOR
''                                                popmessagecr "!WARNING", "Product " & T.SisCode & "  " & Trim$(dlocal.Description) & cr & "is now at a negative stock level." & cr & "This must be corrected manually."
''                                             End If
''                                       Else
''                                          Screen.MousePointer = STDCURSOR
''                                          popmessagecr "!", "Product code '" & T.SisCode & "' not found"
''                                       End If
''                                 End If
''                           End If
''                     Loop
''
''                     Close fil
''                     Close logfil
''                     Kill filename$
''
''                  Else
''                     length = Len(T)
''                     GetPointer filename$, pointer&, False
''                     fil = FreeFile
''                     openrandomfile filename$, length, fil                            'input channel
''
''                     Progress.lblInfo = "Returning regimen"
''                     Progress.Show 0
''                     increment& = pointer& \ 100
''                     If increment& < 1 Then increment& = 1
''
''                     For recno& = 2& To pointer&
''                        If (recno& Mod increment&) = 0 Then Progress.Percent = 100 * (pointer& - recno&) \ pointer&
''                        GetRecordNL r, recno&, fil, length
''                        LSet T = r
''
''                        If Val(T.Qty) > 0 Then                                        '!!** NB Only handles Issued regimens
''                              dlocal.SisCode = T.SisCode
''                              getdrug dlocal, 0, 0, 0
''                              Translog dlocal, 0, UserID$, T.patid, "-" & Trim$(T.Qty), T.dircode, T.ward, T.consultant, T.kind, Val(T.site), T.labeltype, issueunitcost$
''                           End If
''
''                        If EOF(fil) Then Exit For                                     '<== Exit
''                     Next
''                     Unload Progress
''
''                     Close fil
''                     Kill filename$
''                  End If
''
''               Screen.MousePointer = STDCURSOR
''            Else
''               msg$ = "Unable to open temporary file " & filename$
''            End If
''      End Select
''
''   If Len(msg$) Then popmessagecr "!", msg$

End Sub

Sub SaveBaxaRegimenMultiBag(fileNames() As String, nofat%, overag$, emptybag%, BaxaInterfaceType%, sMsg$)
    If sMsg <> "" Then sMsg = sMsg & crlf
    
    Dim filename As Variant
    For Each filename In fileNames
        sMsg = sMsg & "File: " & filename
        SaveBaxaRegimen CStr(filename), nofat%, overag$, emptybag%, BaxaInterfaceType%
        If emptybag Then
              Kill CStr(filename)
              sMsg = sMsg & "  EMPTY BAG: No file written" & crlf
              Exit For
           Else
              sMsg = sMsg & " has been written" & crlf
           End If
    Next
End Sub

Sub SaveBaxaRegimen(FILE$, nofat%, overag$, emptybag%, BaxaInterfaceType%)
' 8Feb95 CKJ Added V6.3 mod - Recno added
'18Aug95 CKJ removed BNT since BatchNumber holds full info
'26Nov96 CKJ Now writes Baxa number read from db. NB this can be zero.
'05Jun00 CKJ Modified to support Baxa Interface Specification "LIBR-0025 Revision A 01/13/99"
'             In one call to this routine write a single file containing
'               Both aqueous & lipid with or without items which do not have a BAXA product number
'               Aqueous part only    with or without aqueous items which do not have a BAXA product number
'               Lipid part only      with or without lipid items which do not have a BAXA product number
'             All the above volumes are to be with or without overage for paediatric regimens
'            Where items are to be included even if they do not have a BAXA product number, then a dummy code is used for
'             all such items. This is defined in TPN.INI
'
'            Note that for a mixed regimen it may be usual to leave lipids and all Part B items out of the Baxa file.
'            For separate amino/lipid regimens it may be usual to only include Part A items, and not address lipids at all.
'             Therefore, options include
'              nofat = -1      include aqueous items only, exclude lipid items
'              nofat =  0      include all items, both aqueous & lipid
'              nofat =  1      include lipid items only, exclude aqueous items
'14Aug00 CKJ added trim() round printing of casenumber
'            format of volumes is leading zero & two dp
'
'mods needed:
'comma is not safe, but is used by Braun
'/needs modifying to write absolute product numbers, not LinkCodes

Dim chan%, X%, des$, productnumber$, answer!, volumeofproduct$
Dim q As String
Dim OCXhospnum As String
Dim iDoItem As Integer
Dim sDummyProductCode As String
Dim iIncludeUndefinedItems As Integer

   Select Case BaxaInterfaceType
      Case 1                                      'ASCribe BAXA interface program
         chan = FreeFile
         Open FILE$ For Output As #chan
         Print #chan, 'bag.BagNo
         Print #chan, regname$ 'bag.RegCode
         'PRINT #Chan, LTRIM$(STR$(BNT))
         Print #chan, Trim$(batchnumber$)  '18Aug95 CKJ removed + RIGHT$("000" + LTRIM$(STR$(BNT)), 3)
         Print #chan, hospname1$ + "," + hospname2$
         Print #chan, pid.ward + " " + pid.cons 'Ward and Cons
         Print #chan, PatientName$ 'bag.PatName
         Print #chan, Mid$(date$, 4, 2) + "/" + Left$(date$, 2) + "/" + Right$(date$, 4)
         Print #chan, "TPN" 'Not sure whether this will work ! ASC
         Print #chan, pid.caseno; ","; pid.status; ","; pid.sex; ","; pid.recno  'ASC 26Sep sex added '8Feb95 CKJ Added recno
         Print #chan, overag$
         
         emptybag = True
         For X = 0 To NP - 1 'was to NP
            If ig!(X) <> 0 Then 'ASC 11Jul93
                  des$ = Prd(X).name
                  plingparse des$, ","     '15Aug95 CKJ
                  If Trim$(Prd(X).SolnAB) <> "B" Or nofat = False Then 'was14
                        emptybag = False
                     Else
                        des$ = "~" + des$
                     End If
                  'productnumber$ = LTrim$(Str$(x))
                  'productnumber$ = Format$(Prd(x).BaxaMMig)   '26Nov96 CKJ Changed from (now) variable numbers '05Jun00 CKJ removed
                  productnumber$ = Trim$(Prd(X).BaxaMMig)      '05Jun00 CKJ Changed from integer
                  answer! = ig!(X)
                  threesigfigs answer!
                  volumeofproduct$ = LTrim$(Str$(answer!))
                  Print #chan, productnumber$ + "," + des$ + "," + volumeofproduct$
               End If
         Next
         Close chan
      
      Case 2:                                   'BAXA's own interface program to specififcation LIBR-0025 Revision A 01/13/99
         q$ = Chr(34)                           'double quote
         sDummyProductCode = TxtD(dispdata$ & "\PN.INI", "BAXA", "UndefinedCode", "DummyProductCode", 0)
         iIncludeUndefinedItems = TrueFalse(TxtD(dispdata$ & "\PN.INI", "BAXA", "Y", "IncludeUndefinedItems", 0))
         Heap 11, gPRNheapID, "OCXhospnum", OCXhospnum$, 0
         OCXhospnum$ = Trim$(asciiz$(OCXhospnum$))
         If OCXhospnum$ = "" Then OCXhospnum$ = pid.caseno
         
         chan = FreeFile
         Open FILE$ For Output As #chan
         'Print #chan, q$; "*"; patientname$; " ("; OCXhospnum$; ")"; q$           ' "*name (number)" 14Aug00 CKJ amended
         Print #chan, q$; "*"; PatientName$; " ("; Trim$(OCXhospnum$); ")"; q$     ' "*name (number)"    "        added trim
         
         emptybag = True
         For X = 0 To NP - 1                                                      'all PN products...
            If igover!(X) > 0 Then                                                '...which have a volume
                  iDoItem = True                                                  'assume we'll do all of them
                  Select Case nofat
                     Case -1                                                      'exclude all lipid items
                        If Trim$(Prd(X).SolnAB) = "B" Then iDoItem = False
                     Case 0                                                       'include everything
                        'no action needed
                     Case 1                                                       'exclude all aqueous items
                        If Trim$(Prd(X).SolnAB) <> "B" Then iDoItem = False
                     End Select

                  productnumber$ = Trim$(Prd(X).BaxaMMig)                         '05Jun00 CKJ changed from integer
                  If Len(productnumber$) = 0 Then                                 'no code defined for this product
                        If iIncludeUndefinedItems Then                            'do we still include this in the file?
                              productnumber$ = sDummyProductCode                  'yes, use dummy code
                           Else
                              iDoItem = False                                     'no
                           End If
                     End If

                  If iDoItem Then                                                 'proceed with this item
                        des$ = Prd(X).name
                        plingparse des$, q$                                       'quote delimited so remove any quotes
                        emptybag = False                                          'at least one item has been included
                        answer! = igover!(X)
                        'threesigfigs answer!                                     'commented as it fails to met the AC MM-205 - baxa volume rounding issue
                        'volumeofproduct$ = LTrim$(Str$(answer!))                 '14Aug00 CKJ
                        volumeofproduct$ = Format$(answer!, "#0.00")              '            leading zero & two dp
                        Print #chan, q$; productnumber$; q$; ","; q$; des$; q$; ","; volumeofproduct$
                     End If
               End If
         Next
         Close chan
         
        Case 3:                                   'New format switch
         q$ = Chr(34)                           'double quote
         sDummyProductCode = TxtD(dispdata$ & "\PN.INI", "BAXA", "UndefinedCode", "DummyProductCode", 0)
         iIncludeUndefinedItems = TrueFalse(TxtD(dispdata$ & "\PN.INI", "BAXA", "Y", "IncludeUndefinedItems", 0))
         Heap 11, gPRNheapID, "OCXhospnum", OCXhospnum$, 0
         OCXhospnum$ = Trim$(asciiz$(OCXhospnum$))
         If OCXhospnum$ = "" Then OCXhospnum$ = pid.caseno
         
         chan = FreeFile
         Open FILE$ For Output As #chan
         Print #chan, q$; "*"; PatientName$; " ("; Trim$(OCXhospnum$); ")"; q$     ' "*name (number)"    "        added trim
         
         emptybag = True
         For X = 0 To NP - 1                                                      'all PN products...
            If igover!(X) > 0 Then                                                '...which have a volume
                  iDoItem = True                                                  'assume we'll do all of them
                  Select Case nofat
                     Case -1                                                      'exclude all lipid items
                        If Trim$(Prd(X).SolnAB) = "B" Then iDoItem = False
                     Case 0                                                       'include everything
                        'no action needed
                     Case 1                                                       'exclude all aqueous items
                        If Trim$(Prd(X).SolnAB) <> "B" Then iDoItem = False
                     End Select

                  productnumber$ = Trim$(Prd(X).BaxaMMig)                         'changed from integer
                  If Len(productnumber$) = 0 Then                                 'no code defined for this product
                        If iIncludeUndefinedItems Then                            'do we still include this in the file?
                              productnumber$ = sDummyProductCode                  'yes, use dummy code
                           Else
                              iDoItem = False                                     'no
                           End If
                     End If

                  If iDoItem Then                                                 'proceed with this item
                        des$ = Prd(X).name
                        plingparse des$, q$                                       'quote delimited so remove any quotes
                        emptybag = False                                          'at least one item has been included
                       
                        volumeofproduct$ = Format$(igover!(X), "#0.00")              '            leading zero & two dp
                        Print #chan, q$; productnumber$; q$; ","; q$; des$; q$; ","; volumeofproduct$
                     End If
               End If
         Next
         Close chan
      Case Else
         popmessagecr ".", "Baxa Compounder Interface called with invalid type code of " & Format$(BaxaInterfaceType)
      End Select
   
End Sub

Sub SaveRegimen(Auth As Integer)
' SaveRegimen -1      to ask before authorising
' SaveRegimen  0      to ask before saving. No action unless regimen has been modified
' SaveRegimen  1      to simply save the regimen without question (other than checking warnings)
'
'    If user escapes then k.escd = true & no save or recall takes place
'    Otherwise save has been done OR user has confirmed regimen is not to be saved
'      - the latter is shown by TPNchanged = true if unsaved
'04Nov98 CKJ replaced Askwin with PopMsg as this supports scroll bars
'03Sep99 CKJ Lipid syringe code merged
'01Oct99 CFY Now sets OCX status directly rather than trying to set outside after TPN has finished.
'25Jul00 CKJ Corrected overage with lipid syringes

''Dim DoIt As Integer, flg%, ans$, warnings$, txt$, dummy%, Critical%
''Dim iNumberOfSyringes As Integer
''Dim sLipidOverageMsg As String
''Dim sSyringeDescription As String
''Dim sRTFforSyringe As String
''Dim fTmpLipidOverage As Single
''
''   DoIt = True
''   k.escd = False
''   txt$ = ""                                         '03Sep99 CKJ added
''
''   warningsvdu warnings$, Critical
''
''   '11Jul99 CKJ Calculate number of syringes to be used  '03Sep99 CKJ mods merged
''   If Not lblscombined Then
''         fTmpLipidOverage = overage(2)
''         LipidSyringes TotLipid!, fTmpLipidOverage, iNumberOfSyringes, sLipidOverageMsg, sSyringeDescription, sRTFforSyringe
''         If Len(sLipidOverageMsg) Then
''               iNumberOfSyringes = 0
''               popmessagecr ".Configuration Error", "Please check and correct the following:" & cr & cr & sLipidOverageMsg
''               Critical = True
''            End If
''         If iNumberOfSyringes Then
''               If fTmpLipidOverage <> overage(2) Then
''                     txt$ = txt$ & "Lipid overage has been changed from " & Format$(overage(2))
''                     txt$ = txt$ & " ml to " & Format$(fTmpLipidOverage) & " ml" & cr
''                     overage(2) = fTmpLipidOverage                                                   '25Jul00 CKJ Added line
''                  End If
''               txt$ = txt$ & "Lipid portion of " & tsf$(TotLipid!) & " ml will be in "
''               txt$ = txt$ & Format$(iNumberOfSyringes) & " x " & sSyringeDescription & cr & cr
''            End If
''      End If
''
''   If Not Critical Then
''         CheckRulesRegimen txt$, Critical            'critical' now implemented
''      End If
''
''   warnings$ = warnings$ & txt$
''   ParseCtrlChars dispdata$ & "\printer.ini", "Screen", warnings$, dummy
''   If InStr(warnings$, "[") Then                     '14Sep98 CKJ Added to parse [info] in text
''         FillPrintHeapPN                             '   "
''         ParseItems gPRNheapID, warnings$, 0         '   "
''      End If                                         '   "
''
''   If Critical And Auth = -1 Then Auth = 0           'Turn Authorise into Save
''
''   If Auth = -1 Then                                 'authorise
''         ans$ = "Y"
''         'flg$ = "?"                                 '04Nov98 CKJ replaced
''         flg = MB_ICONQUESTION                       '   "
''         If Len(warnings$) Then
''               ans$ = "N"
''               'flg$ = "!"                           '04Nov98 CKJ replaced
''               flg = MB_ICONEXCLAMATION              '   "
''            End If
''         'k.helpnum = 550
''         'askwin flg$ & "Authorise", warnings$ & "OK to authorise this regimen?", ans$, k                     '04Nov98 CKJ replaced
''         popmsg "Authorise", warnings$ & "OK to authorise this regimen?", flg + MB_YESNOCANCEL, ans$, k.escd  '   "
''         If ans$ <> "Y" Then DoIt = False
''      ElseIf Auth = 0 And Not TPNchanged And warnings$ <> "" Then 'not modified, but has warnings
''         popmessagecr "#Please Note", warnings$      '21Sep98 CKJ added icon
''         DoIt = False
''      ElseIf (Auth = 0 And TPNchanged) Or warnings$ <> "" Then 'ask before saving, or warnings
''         ans$ = "Y"
''         'k.helpnum = 550
''         'askwin "!Exit", warnings$ & "OK to save this regimen?", ans$, k                                                 '04Nov98 CKJ replaced
''         popmsg "Save Regimen", warnings$ & "OK to save this regimen?", MB_ICONEXCLAMATION + MB_YESNOCANCEL, ans$, k.escd '   "
''         If ans$ <> "Y" Then DoIt = False
''      Else
''         DoIt = False
''      End If
''
''   If DoIt Then
''         'message "", "Saving"                        '05Apr04 CKJ {SP1} proc does nothing
''         savetpn Auth
''         TPNchanged = False
''         k.escd = False
''         'message "", ""                              '   "
''         RegStatus
''         If OCXLaunch() Then                          '01Oct99 CFY Added
''               If Auth Then                           '         "
''                     SetOCXStatus STATUS_AUTH         '         "
''                  Else                                '         "
''                     SetOCXStatus STATUS_SAVE         '         "
''                  End If                              '         "
''            End If                                    '         "
''      End If

End Sub

Sub savetpn(Auth As Integer)
'''Auth =-1   Authorise, set the last authorised fields
'''     = 0   Do not authorise, clear the last authorised fields
'''     = 1   Do not authorise, do not clear the last authorised fields, just save
'''11Apr98 CKJ Added suffix for enteral & infusions
''
'''Dim z As tpnstruct, RecNo As Long
''Dim X%, Y%, suffix$, tmpI$, tmpE$
''
''   patds.Edit
''   For X = 1 To 25
''      patds.Fields("Lnk" & Format$(X)) = ""    'blank last regimen
''      patds.Fields("Prd" & Format$(X)) = 0
''   Next
''   Y = 0
''   For X = FirstPrd(3) To LastPrd(1)   '0 To NP - 1
''      Select Case X
''         Case FirstPrd(1) To LastPrd(1): suffix$ = ""      'normal PN item
''         Case FirstPrd(2) To LastPrd(2): suffix$ = "-"     'other infusion
''         Case FirstPrd(3) To LastPrd(3): suffix$ = "_"     'enteral
''         End Select
''      If ig(X) > 0 Then
''            If Y = 25 Then 'stored last product
''                  popmessagecr "!Warning", "Cannot save whole regimen as it contains over 25 products"
''                  Exit For
''               Else
''                  Y = Y + 1
''                  patds.Fields("Lnk" & Format$(Y)) = Prd(X).linkcode & suffix$  'store link code
''                  patds.Fields("Prd" & Format$(Y)) = ig(X)                      'and volume
''               End If
''         End If
''   Next
''
''   tmpI$ = Format$(ManualIE(2, 0))   'infusions
''   tmpE$ = Format$(ManualIE(3, 0))   'enteral
''   For X = 1 To IgMax
''      tmpI$ = tmpI$ & "|" & Format$(ManualIE(2, X))
''      tmpE$ = tmpE$ & "|" & Format$(ManualIE(3, X))
''   Next
''   patds!Infusion = tmpI$
''   patds!Enteral = tmpE$
''
''   Select Case Auth
''      Case -1         'Authorise
''         patds!AuthModDate = Now     ' was origdate$
''         patds!AuthModUser = UserID$
''         patds!AuthModTerm = ASCTerminalName$()               '13Aug98 CKJ was "Unknown"
''         patds!ModNum = GetField(patds!ModNum) + 1
''         origdate$ = Format$(patds!AuthModDate, "ddmmyyyy")   '13Aug98 CKJ Added
''      Case 0          'Clear fields
''         patds!AuthModDate = ""
''         patds!AuthModUser = ""
''         patds!AuthModTerm = ""
''      End Select
''
''   patds!LastModDate = Now
''   patds!LastModUser = UserID$
''   patds!LastModTerm = ASCTerminalName$()                     '13Aug98 CKJ was "Unknown"
''   patds!ConsName = CN$
''   patds!TPNreqDate = DR$
''   patds!TPNbegDate = df$
''   patds!infuseCPE = CP$
''   patds!ReqDoctor = rd$
''   patds!TPNtotdays = feedlength$
''   patds!ReasonText = Left$(REA$, patds!ReasonText.Size)  '20Nov96 CKJ/PS Paste in txtbox allows > maxlen
''   patds!BodyTemp = Val(BodyTemp$)
''   patds!ActiveFact = AF$
''   patds!InjuryFact = ifact$
''   't = z.F10            'CVS(F$(10))        '!!**
''   'patds!RegNum = nor  '!!**
''   'BNT = z.F12          'CVS(F$(12))
''   patds!BatchNo = BatchNumber$
''   patds!OtherFluids = OtherFluids
''   patds!ModRegName = Left$(regname$, 30)    '5Oct96 CKJ was 22, now 30
''   patds!combined = lblscombined
''   ' = Iff(seplbls$ = "Y", True, False)           '##
''   patds!HrsAminoInf = infrateamino
''   patds!HrsLipidInf = infratefat
''   If lblscombined Then
''         patds!OverageA = overage!(3)
''      Else
''         patds!OverageA = overage!(1)
''         patds!OverageF = overage!(2)
''      End If
''   'inf   ?? !!**
''
''   patds!CardiacFailure = Clin.CardiacFailure                  '0/-1
''   patds!RenalFailure = Clin.RenalFailure                      '0/-1
''   patds!Haemodialysis = Clin.Haemodialysis                    '0/-1
''   patds!PeritonealDialysis = Clin.PeritonealDialysis          '0/-1
''   patds!Haemofiltration = Clin.Haemofiltration                '0/-1
''   patds!Septicaemia = Clin.Septicaemia                        '0/-1
''   patds!FulmHepaticFailure = Clin.FulmHepaticFailure          '0/-1
''   patds!BiliOver100unconj = Clin.BiliOver100unconj            '0/-1
''   patds!BiliOver170unconj = Clin.BiliOver170unconj            '0/-1
''   patds!Phototherapy = Clin.Phototherapy                      '0/-1
''   patds!RadiantHeat = Clin.RadiantHeat                        '0/-1
''   patds!Diuretics = Clin.Diuretics                            '0/-1
''   patds!SerumSodiumCategory = Clin.SerumSodiumCategory        '0 to 5
''   patds!SerumPotassiumCategory = Clin.SerumPotassiumCategory  '0 to 5
''
''   patds.Update
''
'''Exit Sub
''
''   'recno& = Val(PID.ptr(6))
''
'''   z.F0 = CN$                 'Consultant
'''   z.F1 = DR$                 'Date of req. for feeding
'''   z.F2 = DF$
'''   z.F3 = CP$                 'Central or peripheral catheter
'''   z.F4 = rd$
'''   z.F5 = feedlength$
'''   z.F6 = REA$                'Reason for feeding
'''   z.F7 = bodytemp$           'Body temperature
'''   z.F8 = AF$                 'Activity Factor
'''   z.F9 = Chr$(Val(ifact$))   'Injury Factor
'''   z.F10 = t                  'MKS$(t)
'''   z.F11 = nor                'MKS$(nor)  'Regimen number
'''   'z.F12 = BNT                'MKS$(BNT)  'Batch number
'''   z.F13 = OtherFluids        'MKS$(OTHERFLUIDS)  'Volume of other fluids
'''   z.F14 = regname$
'''   z.F15 = seplbls$           'YN
'''   z.F16 = Mid$(regname$, 16) 'chars 16 to 20
'''   z.F17 = Batchnumber$
''
'''   LSet R = z
''   'OpenRandomFile patdatapath$ + "\tpn", 150, tpnchan
''   'PutRecordNL R, recno&, tpnchan, Len(z)
''   'Close #tpnchan
''   'TPNchanged = False

End Sub

Sub ScalePrescription()
'27Aug98 CKJ Added total line
'19Oct98 CKJ Amended to use 4SF precision in total and /kg calculation

''Dim MulFactor!, DivFactor!, Count%
''
''   AskScaleFactor MulFactor!, DivFactor!
''   If MulFactor! Then
''         For Count = 2 To 16     '!!** FIXED NUMBER '14Aug98 CKJ was 15
''            'SCxy(Count, RowsUsedSC) = tsf$(MulFactor! * Val(SCxy(Count, RowsUsedSC)) / DivFactor!)           '19Oct98 CKJ removed
''            'SCxy(Count, RowsUsedSC + 1) = tsf$(Val(SCxy(Count, RowsUsedSC)) * weight!)  '27Aug98 CKJ Added   '   "
''            SCxy(Count, RowsUsedSC) = FourSF$(MulFactor! * Val(SCxy(Count, RowsUsedSC)) / DivFactor!)         '   "        now 4SF
''            SCxy(Count, RowsUsedSC + 1) = FourSF$(Val(SCxy(Count, RowsUsedSC)) * weight!)  '27Aug98 CKJ Added '   "
''         Next
''         TPNchanged = True
''         frmSC.tgdSC.Refresh
''      End If

End Sub

Sub ScaleRegimen()
'''
'''16Feb00 CKJ Ensure that re-authorisation is needed after a change
''
''Dim MulFactor!, DivFactor!, Count%
''
''   AskScaleFactor MulFactor!, DivFactor!
''   If MulFactor! Then
''         For Count = 0 To NP - 1
''            ig(Count) = ig(Count) * MulFactor! / DivFactor!
''         Next
''         TPNchanged = True                                       '16Feb00 CKJ Added
''         AdjPrint
''      End If

End Sub

Sub SelectFromAllIgs()
'Show list of all ingredients & allow choice of any
'11Mar96 CKJ Added call to SelectProd

''Dim xx%, X$, Utyp$, ignum%
''
''   If TableFull() Then Exit Sub
''
''   k.escd = False
''   Screen.MousePointer = HOURGLASS
''   LstBoxFrm.Caption = tp("Enter") + LTrim$(tp("by..."))     '"!n!iEnter "" by ..."
''   LstBoxFrm.lblTitle = cr$ & "Select ingredient to adjust" & cr$
''   For xx = 1 To IgMax   '@@  13
''      X$ = Trim$(Str$(xx))
''      Utyp$ = tp("igU" + X$)   ' igU5 => 3
''      '                                                 Uabr3 => mmol              ig5  => sodium
''      'LstBoxFrm.LstBox.AddItem Fmt$((xx), "###") & TB & tp("Udes" + Utyp$) & " " & tp("ig" + x$)
''      '                               Uabr3 => mmol              ig5  => sodium
''      LstBoxFrm.LstBox.AddItem "  " & tp("Udes" + Utyp$) & " " & tp("ig" + X$)
''   Next
''
''   Screen.MousePointer = STDCURSOR
''   'k.helpnum = 950
''   LstBoxShow
''   ignum = LstBoxFrm.LstBox.ListIndex + 1
''   Unload LstBoxFrm
''
''   If ignum Then SelectProd ignum, 0

End Sub

Sub SelectIg(LN)
'Given product ln=0 to NP-1
'returns elecnum=1 to 13 or vol=true or both=0 if escaped or invalid choice

''ReDim igx(1 To IgMax)
''Dim numip%, Vol%, elecnum%, Y%, xx%, X$, Utyp$, s$, ansx%
''
''   numip = 0
''   Vol = False
''   elecnum = 0
''   k.escd = False
''
''   For Y = 1 To IgMax   '@@  13
''      If prod!(LN, Y) > 0 Then
''            numip = numip + 1
''            igx(numip) = Y
''         End If
''   Next
''
''   If numip Then
''         LstBoxFrm.Caption = "Select Ingredient"
''         LstBoxFrm.lblTitle = cr$ & tp("Enter") & Prd(LN).name & tp("by...") & cr$ '!n!iEnter xxx by ...
''         LstBoxFrm.LstBox.AddItem "  ml volume"
''         For xx = 1 To numip
''            X$ = Trim$(Str$(igx(xx)))
''            Utyp$ = tp("igU" + X$)   ' igU5 => 3
''            '                                           Uabr3 => mmol             ig5  => sodium
''           's$ = Fmt$(xx + 1, "###") & TB & tp("Udes" + Utyp$) & " " & tp("ig" & x$)
''            '                       Uabr3 => mmol      ig5  => sodium
''            s$ = "  " & tp("Udes" + Utyp$) & " " & tp("ig" & X$)
''            LstBoxFrm.LstBox.AddItem s$
''         Next
''
''         'k.helpnum = 960
''         LstBoxShow
''         ansx = LstBoxFrm.LstBox.ListIndex + 1
''         Unload LstBoxFrm
''
''         If Not k.escd Then
''               Select Case ansx
''                  Case 0:              k.escd = True
''                  Case 1:              Vol = True
''                  Case 2 To numip + 1: elecnum = igx(ansx - 1)   'igx(1)=first ig
''                  Case Else:           popmessagecr "!n!b", "Invalid choice"
''                  End Select
''            End If
''      Else
''         Vol = True ' no measurable igs, just volume eg solivito
''      End If
''
''   If elecnum Then
''         mmolentry LN, elecnum, 0
''      ElseIf Vol Then
''         volentry LN, 0
''      End If

End Sub

Sub SelectProd(ignum, stage)
'''Given ingredient ignum=1 to IgMax
'''Shows all products containing that Ig, then allows mmol entry for chosen product
'''24Sep98 CKJ Added check for paed/adult use
''
''Dim X%, mls$, LN%
''
''   If ignum Then
''         Screen.MousePointer = HOURGLASS
''         For X = 0 To NP - 1
''            If prod!(X, ignum) > 0 Then
''                  mls$ = ""
''                  If ig(X) > 0 Then mls$ = tsf(ig(X)) + " " + tp("ml")
''                  If ig(X) > 0 Or ForAPuse(X) Then                             '24Sep98 CKJ Added
''                        LstBoxFrm.LstBox.AddItem "  " & Prd(X).name & TB & mls$
''                        LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = X
''                     End If
''               End If
''         Next
''
''         Screen.MousePointer = STDCURSOR
''         If LstBoxFrm.LstBox.ListCount Then
''               LstBoxFrm.Caption = "Products containing " + tp("Ig" + Trim$(Str$(ignum)))
''               LstBoxFrm.lblTitle = cr$ & "Select product to add or amend" & cr$
''               LstBoxFrm.lblHead = "  Product" & Space$(23) & TB & " Volume"
''               LstBoxShow
''               If Len(LstBoxFrm.Tag) Then
''                    'LN = Val(LstBoxFrm.Tag) - ofs
''                     LN = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
''                     Unload LstBoxFrm
''                     mmolentry LN, ignum, stage
''                  Else
''                     Unload LstBoxFrm
''                  End If
''            End If
''      End If
      
End Sub

Sub SetDebug(DebugType%)
'DebugType = 0   SQLdbg
'            1   MasterDebug

   Select Case DebugType
      Case 0: SQLdbg = Not SQLdbg
      'Case 1: If userid$ = "ASC" Then MasterDebug = Not MasterDebug '25Jul00 CKJ Removed developer option
      End Select

End Sub

Sub SetPrdForIg()
'Set the preferred product ID for each ig
'Takes into account patient age and weight, adult/paed
'MUST find just one product to supply each ingredient, otherwise sets k.escd & displays message.

'   PrdN = GetPrdNum("PrdN")              'when adding nitrogen, use this product
'   PrdGl = GetPrdNum("PrdGl")            'when adding glucose, use this product
'   PrdFat = GetPrdNum("PrdFat")          'when adding fat, use this product
'   PrdNa = GetPrdNum("PrdNa")            'when adding Na, use this product
'   PrdK = GetPrdNum("PrdK")              'when adding K, use this product
'   PrdCa = GetPrdNum("PrdCa")            'when adding Ca, use this product
'   PrdMg = GetPrdNum("PrdMg")            'when adding Mg, use this product
'   PrdCu = GetPrdNum("PrdCu")            'when adding Cu, use this product
'   PrdZn = GetPrdNum("PrdZn")            'when adding Zn, use this product
'   PrdSe = GetPrdNum("PrdSe")            'when adding Se, use this product
'   PrdPO4 = GetPrdNum("PrdPO4")          'when adding PO4, use this product
'   PrdVaqu = GetPrdNum("PrdVaqu")        'when adding aqu Vitamins, use this product
'   PrdVlip = GetPrdNum("PrdVlip")        'when adding lip Vitamins, use this product
'
'   If Not Adult(pid.sex) Then
'         'If AgeInYears! > 11 Then      'vitlipid N infant -> vitlipid N adult (or at 30kg)
'         'If weight! > 10 Then          'vaminolact -> Vamin 9 glucose
'         'If weight! > 15 Then          'peditrace 1ml/kg -> peditrace 15ml
'         'If weight! > 40 Then          'peditrace 1ml/kg -> additrace 0.1ml/kg
'      End If

''Dim SQLq As String, PerKg$, BBds As Dynaset, keep%, rule$, Product%, chk$, itemname$, i%, sum&
''
''   k.escd = False
''   If adult(pid.sex) Then PerKg$ = "0" Else PerKg$ = "-1"
''   Screen.MousePointer = HOURGLASS
''
''   'Find the Blackboard record - use as sandpit for rule testing
''   SQLq = "SELECT DISTINCTROW * FROM Blackboard WHERE ID=1;"
''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set BBds = patdb.CreateDynaset(SQLq)    'only one matching row
''   FillBlackboardPIDClinical PerKg$, BBds
''   BBds.Update                             'Edit started in FillBlackboardPIDClinical
''
''   '                                                                                  v-- Rule Type 0
''   SQLq = "SELECT RuleSQL, IngredientName, IngredientAction FROM Rules WHERE RuleType=0 AND InUse=-1 AND PerKilo=" & PerKg$ & " ORDER BY RuleNumber;"
''   If SQLdbg Then popmessagecr "SQL", SQLq
''   Set regss = regdb.CreateSnapshot(SQLq)  'should be many matching rows
''   regdbopen = 2
''
''   If Not regss.EOF Then
''         chk$ = ""                         'used for checking each item is found once only
''         k.escd = False
''         Do While Not regss.EOF And Not k.escd
''            keep = True
''            rule$ = GetField(regss!RuleSQL)
''            If rule$ <> "" Then
''                  SQLq = "SELECT * FROM Blackboard WHERE ID=1 AND (" & rule$ & ");"
''                  If SQLdbg Then popmessagecr "SQL", SQLq
''                  Set BBds = patdb.CreateDynaset(SQLq)    'only one matching row
''                  If BBds.EOF Then keep = False           'rule did not fire - it was false
''               End If
''
''            If keep Then
''                  itemname$ = GetField(regss!IngredientAction)
''                  Product = GetPrdNum(GetField(regss!IngredientName))
''                  If Product = -1 Then
''                        'k.escd already set
''                        popmessagecr ".", "No product defined for ingredient " & itemname$
''                     Else
''                        chk$ = chk$ & itemname$ & " "
''                        Select Case UCase$(itemname$)      'each line must fire once only
''                           Case "DIL":  PrdDil = Product   'diluent' ie Gl 5% or WFI
''                           Case "NACL": PrdNaCl = Product
''                           Case "KCL":  PrdKCl = Product
''                           Case "KPO4": PrdKPO4 = Product
''                          'Case "VOL":  PrdVol = product   'volume not configurable here
''                           Case "N":    PrdN = Product
''                           Case "GLUC": PrdGl = Product
''                           Case "FAT":  PrdFat = Product
''                           Case "NA":   PrdNa = Product
''                           Case "K":    PrdK = Product
''                           Case "CA":   PrdCa = Product
''                           Case "MG":   PrdMg = Product
''                           Case "ZN":   PrdZn = Product
''                           Case "PO4":  PrdPO4 = Product
''                           Case "SE":   PrdSe = Product
''                           Case "CU":   PrdCu = Product
''                           Case "VAQU": PrdVaqu = Product
''                           Case "VLIP": PrdVlip = Product
''                           Case "FE":   PrdFe = Product    '!!** ready for use
''                           Case Else:   k.escd = True
''                           End Select
''                     End If
''               End If
''            regss.MoveNext
''         Loop
''         sum& = 0
''         For i = 1 To Len(chk$)
''            sum& = sum& + Asc(Mid$(chk$, i, 1))
''         Next
''         If k.escd Or sum& <> 4867 Then         '11Apr98 CKJ Checksum before Iron was 4664
''               Screen.MousePointer = STDCURSOR
''               'popmessagecr "PN Program Cannot Continue - Important Data Not Found", "Each ingredient in a prescription is supplied by one product. Either too few products have been found, or there are multiple products for one ingredient.  Please check the database under rule type zero.  The items found are;" & cr & chk$ & cr & "Checksum is" & Str$(sum&)
''               popmessagecr ".PN Program Cannot Continue - Important Data Not Found", "Each ingredient in a prescription has to be supplied by just one product." & cr & "Either too few products have been found, or there are multiple products for one ingredient." & cr & "Please check the database under rule type zero." & cr & cr & "The items found are;" & cr & chk$ & cr & "Checksum is" & Str$(sum&)
''               k.escd = True
''            End If
''
''      End If
''   Screen.MousePointer = STDCURSOR
      
End Sub

''Sub SetTgdSCcolours(Ctl As TrueGrid)
'''==========================================================
''' Set colours for the Prescription Truegrid
'''==========================================================
''Dim fg As Long, bg As Long
''
''   'clear existing rules
''   Ctl.HasRegexAttr = False
''
''   'set negative cells
''   fg = QBColor(15) 'bright white
''   bg = QBColor(4)  'red
''
''   Ctl.ParamForeColor = fg
''   Ctl.ParamBackColor = bg
''   Ctl.ParamFontStyle = -1
''
''  ' ctl.ParamStatus = 0        'not marked, not updated, not marquee row, not current
''  ' ctl.AddRegexAttr = "^ *-"
''
''   Ctl.ParamStatus = 8        'is  marked, not updated, not marquee row, not current
''   Ctl.AddRegexAttr = "^ *-"
''
''  ' ctl.ParamForeColor = bg
''  ' ctl.ParamBackColor = QBColor(14) 'yellow
''  '
''  ' ctl.ParamStatus = 1        'not marked, not updated, not marquee row, is  current
''  ' ctl.AddRegexAttr = "^ *-"
''  '
''  ' ctl.ParamStatus = 9        'is  marked, not updated, not marquee row, is  current
''  ' ctl.AddRegexAttr = "^ *-"
''
''   'set the '?Ask' cells
''   Ctl.ParamForeColor = fg
''   Ctl.ParamBackColor = bg
''   Ctl.ParamFontStyle = -1
''
''   Ctl.ParamStatus = 0        'not marked, not updated, not marquee row, not current
''   Ctl.AddRegexAttr = "^ *?"
''
''End Sub

Sub SetTPNDefaults(PaedorAdult%)
'DOStoWIN V1.0 (c) ASCribe 1996
'------------- TPNDEF  V5.3 --------------------------------------------------
'31Oct91 CKJ Program written
' 2Nov91 CKJ Moved driprate & dropspermin from Libname, added baxapump
' 9Nov91 CKJ Removed overage as %
'24Nov91 CKJ printreversefeed added
'15Dec91 CKJ Added printer numbers for plain & label stock
'18Jan92 CKJ Added IssRetEnabled
'26Jan92 CKJ Added label length, enable issue & return now separate.
'30Jan92 CKJ Released as V5.3
'13Jul93 ASC Now chains back to it after use to allow use with Baxa direct entry
'08Jun94 ASC Internationalised and TPNdefault comes from pddata$ if set in libname
' 2Aug94 CKJ identtype$ was both common & shared - latter removed
'            Esc from detail entry ends program if under Direct Entry,
'            but returns to 'select Paed/Adult' otherwise
'10Aug94 CKJ EditYesNO had YN hard coded
' 9Feb96 CKJ (Un)LockRecord - len() added
'------------
'19Oct96 CKJ Converted to windows.
'            Removed support for identtype 4DE  - direct entry defaults.
'            This will either be done by DOS prog as before, or called explicity.
'            When calling set PaedorAdult%=0 for paed, 1 for adult
'05Jun00 CKJ Added logging as hex dump of the UDT. Not easily readable though.

'identtype:
' 4 = TPN patient
' 5 = TPN batch
' 4DE = Direct entry software   '19Jul94  '20Oct96 NOT IMPLEMENTED IN WINDOWS
'-----------------------------------------------------------------------------
'TPNDEF.BAS converted to windows
'Set Adults% = T for adult/batch
'              F for paeds

'''Dim paed&, Adlt&, Count%, defdirect$, exists%, chan%, recno%, Changed%
'''Dim default As tpndefaults
'''Dim sLogText As String, bte As Integer                                                             '05Jun00 CKJ added
'''
'''   ReDim tpndefs(1 To 2) As tpndefaults
'''
'''   paed = 1
'''   Adlt = 2
'''   If PaedorAdult% = 0 Then recno = paed Else recno = Adlt
'''
'''   ' set up hard coded defaults, to offer new user
'''   ' same defaults are written for adult & paed
'''   default.seplabels = True
'''   default.infusionrate = True     ' infusion rate is printed as mls per hour
'''   default.dropspermin = False
'''   default.baxapump = False
'''   default.printreversefeed = True
'''   default.plainprinter = 1
'''   'default.labelprinter = Val(Mid$(lpt2$, 4, 1))   ' from libname"lpt2"
'''   default.labelprinter = Val(Mid$("lpt2", 4, 1))   ' from libname
'''   default.issueenabled = False
'''   default.returnenabled = False
'''   default.labels4inches = False
'''   For Count = 1 To 3
'''      default.overagevol(Count) = 25
'''      default.Expiry(Count) = "04/00/0000"
'''      default.numlabels(Count) = 2
'''      default.infusehrs(Count) = 24
'''      default.dropsperml(Count) = 24
'''   Next
'''
'''   If pddata$ <> "" Then defdirect$ = pddata$ Else defdirect$ = dispdata$
'''   exists = fileexists(defdirect$ & tpndefaultfile)
'''   openrandomfile defdirect$ & tpndefaultfile, Len(default), chan
'''   If Not exists Then
'''         tpndefs(paed) = default
'''         tpndefs(Adlt) = default
'''         LSet r = default
'''         LockRecord chan, paed, Len(default)     '9Feb96 CKJ Added len()
'''         LockRecord chan, Adlt, Len(default)     '9Feb96 CKJ Added len()
'''         PutRecordNL r, paed, chan, Len(default)
'''         PutRecordNL r, Adlt, chan, Len(default)
'''      Else
'''         GetRecordL r, paed, chan, Len(default)
'''         LSet tpndefs(paed) = r
'''         GetRecordL r, Adlt, chan, Len(default)
'''         LSet tpndefs(Adlt) = r
'''      End If
'''
'''''   sLogText = "Edited " & Iff(PaedorAdult = 0, "Paediatric", "Adult") & " Defaults: "               '05Jun00 CKJ added
'''''   For byte = 1 To Len(default)                                                                     '   "
'''''      sLogText = sLogText & Right$("0" & Hex$(Asc(Mid$(R.record, byte))), 2)                        '   "
'''''   Next                                                                                             '   "
'''
'''   editdefaults recno, tpndefs(recno), Changed
'''
'''   If Changed Then
'''         LSet r = tpndefs(recno)
'''         sLogText = sLogText & " => "                                                               '05Jun00 CKJ added
'''''         For byte = 1 To Len(default)                                                               '   "
'''''            sLogText = sLogText & Right$("0" & Hex$(Asc(Mid$(R.record, byte))), 2)                  '   "
'''''         Next                                                                                       '   "
'''         PutRecordNL r, (recno), chan, Len(default)
'''         WriteLog dispdata$ & "\PNedit.log", 0, UserID$, sLogText                                   '05Jun00 CKJ added
'''      End If
'''
'''   UnlockRecord chan, paed, Len(default)     '9Feb96 CKJ Added len()
'''   UnlockRecord chan, Adlt, Len(default)     '9Feb96 CKJ Added len()
'''   Close chan

End Sub

Sub ShowPrescriptionInfo()
'Click on Prescription line in main screen

''Dim Txt$
''
''   Txt$ = "Prescription:" & cr
''   Txt$ = Txt$ & "    Prescribed:" & TB & YesNo$(GetField(patds!prescribed)) & cr
''   If GetField(patds!prescribed) = True Then
''         Txt$ = Txt$ & "    Name:" & TB & TB & GetField(patds!ModRegName) & cr
''         Txt$ = Txt$ & "    Date:" & TB & TB & Format$(GetField(patds!PrescModDate), "dd mmmm yyyy  h:nn am/pm") & cr
''         Txt$ = Txt$ & "    User:" & TB & TB & GetField(patds!PrescModUser) & cr
''         Txt$ = Txt$ & "    Terminal:" & TB & GetField(patds!PrescModTerm) & cr
''      End If
''
''   Txt$ = Txt$ & cr & "Regimen:" & cr
''   Txt$ = Txt$ & "    Authorised:" & TB & YesNo$(Not IsNull(patds!AuthModDate)) & cr
''   If Not IsNull(patds!AuthModDate) Then
''         Txt$ = Txt$ & "    Name:" & TB & TB & GetField(patds!ModRegName) & cr
''         Txt$ = Txt$ & "    Date:" & TB & TB & Format$(GetField(patds!AuthModDate), "dd mmmm yyyy  h:nn am/pm") & cr
''         Txt$ = Txt$ & "    User:" & TB & TB & GetField(patds!AuthModUser) & cr
''         Txt$ = Txt$ & "    Terminal:" & TB & GetField(patds!AuthModTerm) & cr
''      End If
''
''   popmessagecr "Prescription Details", Txt$
''
End Sub

Sub SpGravCalc(Display%, TotWtAqu!, TotWtAquDesc$, TotWtLip!, TotWtLipDesc$)
'''27Sep96 CKJ Written
'''30Jun97 CKJ Simplified for adult use
'''16Feb98 CKJ Tabstops now lined up
'''            Added total vol & weight for adult
'''05jun00 CKJ Consideration given to extracting data for printing, and for showing aqueous/lipid parts separately
'''            TotWt! parameter replaced with four:
'''            TotWtAqu!      Total weight (inc overage if applicable) of aqueous or mixed bag, based on available SG figures
'''            TotWtAquDesc$  As above plus "g" if all SGs are available, otherwise contains "Incomplete"
'''            TotWtLip!      Total weight (inc overage if applicable) of lipid portion, based on available SG figures
'''            TotWtLipDesc$  As above plus "g" if all SGs are available and it is a separate aqueous/lipid regimen,
'''                            otherwise contains "N/A" for a mixed bag or "Incomplete" if some SGs are absent
'''
'''            Columns moved so that product name is first;
''' Product    regimen        inc overage
'''            Vol weight     Vol weight
''' <name>     ---  ---       ---  ---
''' Tot vol aq                ---
''' Tot wt aq                      ---
'''
''' <name>     ---  ---       ---  ---
''' Tot vol lip               ---
''' Tot wt lip                     ---
'''
''' Tot vol                   ---
''' Tot wt                         ---
''
''Dim txt$, ttl!, Wt!, dummy%, missing%, X%, Vol!
''Dim iPass As Integer
''Dim iDoIt As Integer
''Dim desc As String
''Dim iPasses As Integer
''Dim VolPass1 As Single
''Dim iAnyMissing As Single
''
''   txt$ = "[35x_][tab][9x_][tab][10x_]"                                             'define column widths
''   If Not adult(pid.sex) Then txt$ = txt$ & "[tab][9x_][tab][10x_][0]"              'define column widths for overage
''   txt$ = txt$ & "[0]"                                                              '(nul char at end)
''   txt$ = txt$ & "Product[Tab]Regimen"                                              'define heading
''   If Not adult(pid.sex) Then txt$ = txt$ & "[Tab][Tab]Including Overage"           '16Feb98 CKJ modified
''
''   CalcOverage
''
''   TotWtAqu! = 0
''   TotWtAquDesc$ = "N/A"
''   TotWtLip! = 0
''   TotWtLipDesc$ = "N/A"
''   iAnyMissing = False
''
''   'Pass 1 is the aqueous part of separate bags, or the whole of a combined bag
''   'Pass 2 is the lipid part of separate bags
''   iPasses = Iff(lblscombined, 1, 2)             'one pass for combined, two for separate bags
''   For iPass = 1 To iPasses
''      missing = 0
''      Vol! = 0
''      ttl! = 0
''      txt$ = txt$ & "[cr][cr]"
''      For X = 0 To NP - 1
''         iDoIt = (ig!(X) > 0)   'if ingredient has a volume then assume we'll count it
''
''         'Separate bags, but it is pass 1 and we're not looking at an aqueous item
''         If lblscombined = False And iPass = 1 And UCase$(Prd(X).SolnAB) = "B" Then iDoIt = False
''
''         'Separate bags, but it is pass 2 and we're not looking at a lipid item
''         If lblscombined = False And iPass = 2 And UCase$(Prd(X).SolnAB) <> "B" Then iDoIt = False
''
''         If iDoIt Then
''               txt$ = txt$ & Prd(X).name & "[tab]" & Trim$(tsf$(ig!(X))) & " ml [tab]"
''               If Prd(X).SpGrav > 0 Then
''                     txt$ = txt$ & Trim$(tsf$(ig!(X) * Prd(X).SpGrav)) & " g"
''                  Else
''                     txt$ = txt$ & "------"
''                     missing = missing + 1
''                  End If
''
''               If adult(pid.sex) Then
''                     Vol! = Vol! + ig!(X)                   '16Feb98 CKJ Added total for adult
''                     If Prd(X).SpGrav > 0 Then              '   "
''                           Wt! = ig!(X) * Prd(X).SpGrav     '   "
''                           ttl! = ttl! + Val(tsf$(Wt!))     '   "
''                        End If
''                  Else
''                     Vol! = Vol! + igover!(X)
''                     txt$ = txt$ & "[tab]" & Trim$(tsf$(igover!(X))) & " ml [tab]"
''                     If Prd(X).SpGrav > 0 Then
''                           Wt! = igover!(X) * Prd(X).SpGrav
''                           ttl! = ttl! + Val(tsf$(Wt!))
''                           txt$ = txt$ & Trim$(tsf$(Wt!)) & " g"
''                        Else
''                           txt$ = txt$ & "------"
''                        End If
''                  End If
''               txt$ = txt$ & "[cr]"
''            End If
''      Next
''
''      If display Then                                       'prepare totals or subtotals for display
''            desc$ = ""                                      'combined bag, no description
''            If iPass = 2 Then
''                  desc$ = " Lipid"                          'lipid portion
''               ElseIf Not lblscombined Then
''                  desc$ = " Aqueous"                        'aqueous portion
''               End If
''
''            txt$ = txt$ & "[cr][5x ]Total" & desc$ & " Volume[tab]"
''            txt$ = txt$ & Iff(adult(pid.sex), "", "[tab][tab]") & FourSF$(Vol!) & " ml[cr]"
''
''            txt$ = txt$ & "[5x ]" & Iff(missing, "Approximate", "Total") & desc$ & " Weight[tab][tab]"
''            txt$ = txt$ & Iff(adult(pid.sex), "", "[tab][tab]") & FourSF$(ttl!) & " g"
''            If missing Then txt$ = txt$ & "[cr][tab]NOTE  " & Format$(missing) & " missing specific gravity"
''            txt$ = txt$ & "[cr]"
''         End If
''
''      If missing Then
''            iAnyMissing = True
''            desc$ = "Incomplete"                            'Volume > 0, but some items missing
''         ElseIf ttl! > 0 Then
''            desc$ = FourSF$(ttl!) & " g"                    'Volume > 0 and all items have an S.G.
''         Else
''            desc$ = "N/A"                                   'if total volume is zero
''         End If
''
''      If iPass = 1 Then                                     'aqueous or mixed total
''            TotWtAqu! = ttl!
''            TotWtAquDesc$ = desc$
''            VolPass1 = Vol!
''         Else                                               'lipid total
''            TotWtLip! = ttl!
''            TotWtLipDesc$ = desc$
''         End If
''   Next
''
''   If display Then
''         If iPasses = 2 Then                                'prepare Grand Totals
''               txt$ = txt$ & "[cr][5x ]Regimen Total Volume[tab]"
''               If Not adult(pid.sex) Then txt$ = txt$ & "[tab][tab]"
''               txt$ = txt$ & FourSF$(VolPass1! + Vol!) & " ml[cr]"
''
''               txt$ = txt$ & "[5x ]" & Iff(iAnyMissing, "Approximate", "Regimen") & " Total Weight[tab][tab]"
''               txt$ = txt$ & Iff(adult(pid.sex), "", "[tab][tab]") & FourSF$(TotWtAqu! + TotWtLip!) & " g"
''            End If
''
''         ParseCtrlChars dispdata$ & "\printer.ini", "Screen", txt$, dummy
''         popmessagecr Iff(iAnyMissing, "!", "#") & "Volume and Weight of Products", txt$
''     End If
''
''
'''05Jun00 CKJ Original code before modification
''
'''Dim txt$, ttl!, Wt!, dummy%, missing%, x%, Vol!
'''
'''   If Adult(pid.sex) Then                                                   '16Feb98 CKJ modified
'''         txt$ = "[9x_][tab][10x_][tab][30x_][0]"
'''         txt$ = txt$ & "Regimen[Tab][Tab]Product[cr][cr]"
'''      Else
'''         txt$ = "[9x_][tab][10x_][tab][9x_][tab][10x_][tab][30x_][0]"
'''         txt$ = txt$ & "Regimen[Tab][Tab]Incl. Overage[tab]Product[cr][cr]"
'''      End If
'''
'''   CalcOverage
'''   'If lblscombined Then
'''   '      calcoverage Overage(3), 3
'''   '   Else
'''   '      calcoverage Overage(1), 1
'''   '      If Not k.escd Then calcoverage Overage(2), 2
'''   '   End If
'''
'''   missing = 0
'''   For x = 0 To NP - 1
'''      If ig!(x) > 0 Then
'''            txt$ = txt$ & Trim$(tsf$(ig!(x))) & " ml [tab]"
'''            If Prd(x).SpGrav > 0 Then
'''                  txt$ = txt$ & Trim$(tsf$(ig!(x) * Prd(x).SpGrav)) & " g"
'''               Else
'''                  txt$ = txt$ & "------"
'''                  missing = missing + 1
'''               End If
'''
'''            If Adult(pid.sex) Then
'''                  Vol! = Vol! + ig!(x)                 '16Feb98 CKJ Added total for adult
'''                  If Prd(x).SpGrav > 0 Then            '   "
'''                        Wt! = ig!(x) * Prd(x).SpGrav   '   "
'''                        ttl! = ttl! + Val(tsf$(Wt!))   '   "
'''                     End If
'''               Else
'''                  Vol! = Vol! + igover!(x)
'''                  txt$ = txt$ & "[tab]" & Trim$(tsf$(igover!(x))) & " ml [tab]"
'''                  If Prd(x).SpGrav > 0 Then
'''                        Wt! = igover!(x) * Prd(x).SpGrav
'''                        txt$ = txt$ & Trim$(tsf$(Wt!)) & " g"
'''                        ttl! = ttl! + Val(tsf$(Wt!))
'''                     Else
'''                        txt$ = txt$ & "------"
'''                     End If
'''               End If
'''            txt$ = txt$ & "[tab]" & Prd(x).name & "[cr]"
'''         End If
'''   Next
'''
'''   If display Then
'''         'If Not adult(pid.sex) Then txt$ = txt$ & "[tab][tab][26x-]"
'''         txt$ = txt$ & "[cr]Total volume[tab]" & tsf$(Vol!) & " ml[cr]"
'''         If missing = 0 Then
'''               txt$ = txt$ & "Total weight[tab]"
'''            Else
'''               txt$ = txt$ & "Approx. weight[tab]"
'''            End If
'''         If Not Adult(pid.sex) Then
'''               txt$ = txt$ & "[tab]"
'''               txt$ = txt$ & Trim$(tsf$(ttl!)) & " g"
'''            Else
'''               txt$ = txt$ & tsf$(ttl!) & " g"
'''            End If
'''         If missing Then txt$ = txt$ & "[tab](" & Format$(missing) & " missing specific gravity)"
'''         txt$ = txt$ & "[cr]"
'''         ParseCtrlChars dispdata$ & "\printer.ini", "Screen", txt$, dummy
'''         popmessagecr "Weight of Products", txt$
'''      End If
'''   TotWt! = ttl!
'''
'''   AdjPrint

End Sub

Sub StoreChange(Row As Long, Col As Integer, Value As String)
'15May97 CKJ added StopEvents

''Dim LN%
''
''   If TpnVO Then
''         popmessagecr "Not Stored", "Cannot save changes on view only password"
''      Else
''         StopEvents = True
''         Select Case Row
''            Case Is <= RowsUsed
''               ClearBlobs          '21Sep98 CKJ Added
''               LN = Val(VAxy(0, Row))
''               RememberK
''               RememberNa
''               If Col = IgMax + 3 Then   ' ml/kg column
''                     ig(LN) = Val(Value) * weight!
''                  Else      ' val typed    container vol  mmol of ig in cont
''                     ig(LN) = Val(Value) * prod!(LN, 0) / prod!(LN, Col - 2)
''                  End If
''               ModIg(0) = LN
''               AskAdjustNa LN
''               AskAdjustK LN
''
''            Case EnteralRow       'Manually entered Enteral figures
''               If Col = IgMax + 3 Then   ' ml/kg column
''                     ManualIE(3, 0) = Val(Value) * weight!
''                  Else
''                     ManualIE(3, Col - 2) = Val(Value)
''                  End If
''
''            Case InfusionRow      'Manually entered Infusion figures
''               If Col = IgMax + 3 Then   ' ml/kg column
''                     ManualIE(2, 0) = Val(Value) * weight!
''                  Else
''                     ManualIE(2, Col - 2) = Val(Value)
''                  End If
''
''            Case Is < InfusionRow 'Pre-selected Enteral solution
''               LN = Val(VAxy(0, Row))
''               If Col = IgMax + 3 Then   ' ml/kg column
''                     ig(LN) = Val(Value) * weight!
''                  Else      ' val typed    container vol  mmol of ig in cont
''                     ig(LN) = Val(Value) * prod!(LN, 0) / prod!(LN, Col - 2)
''                  End If
''               ClearBlobs          '21Sep98 CKJ Added
''               ModIg(0) = LN
''
''            Case Is < GrandTotRow 'Pre-selected other Infusion
''               LN = Val(VAxy(0, Row))
''               If Col = IgMax + 3 Then   ' ml/kg column
''                     ig(LN) = Val(Value) * weight!
''                  Else      ' val typed    container vol  mmol of ig in cont
''                     ig(LN) = Val(Value) * prod!(LN, 0) / prod!(LN, Col - 2)
''                  End If
''               ClearBlobs          '21Sep98 CKJ Added
''               ModIg(0) = LN
''
''            End Select
''         TPNchanged = True
''         AdjPrint
''         StopEvents = False
''      End If

End Sub

Sub StoreScriptChange(Row As Long, Col As Integer, Value As String)
'19Oct98 CKJ Amended to use 4SF precision in total and /kg calculation

   If TpnVO Then Exit Sub                                    '27Aug98 CKJ was 'Stop'

   'If Row <= RowsUsedSC Then                                '27Aug98 CKJ allow edit of total row
   Select Case Row
      Case RowsUsedSC
         SCxy(Col, Row) = Value
         'SCxy(col, Row + 1) = tsf$(Val(value) * weight!)    '27Aug98 CKJ added 19Oct98 CKJ removed
         SCxy(Col, Row + 1) = FourSF$(Val(Value) * weight!)  '27Aug98 CKJ added    "        now 4SF
         TPNchanged = True
      Case RowsUsedSC + 1                                    '   "
         SCxy(Col, Row) = Value                              '   "
         'SCxy(col, Row - 1) = tsf$(Val(value) / weight!)    '   "              19Oct98 CKJ removed
         SCxy(Col, Row - 1) = FourSF$(Val(Value) / weight!)  '   "                 "        now 4SF
         TPNchanged = True                                   '   "
      End Select

End Sub

Function TableFull() As Integer

Dim scrlin%, lop%
   
   scrlin = 0                                  '!!** tidy
   For lop = 0 To NP - 1
      If ig(lop) <> 0 Then scrlin = scrlin + 1
   Next
   If scrlin >= 18 Then  'test for screen full added 8Oct91 CKJ '11Jul98 CKJ was 17 max
         popmessagecr "!n!bTable full", "No more room available"
         TableFull = True
      Else
         TableFull = False
      End If

End Function

''Sub TgSetNegativeColColor(Ctl As TrueGrid, col As Integer, fg As Long, bg As Long)
''' ==========================================================
''' Sub: SetNegativeColColor
'''
''' For a given column, sets the colors to be used for cells
''' which have a leading minus sign.
''' ==========================================================
''
''   Ctl.ParamForeColor = fg
''   Ctl.ParamBackColor = bg
''   Ctl.ParamFontStyle = -1
''
''   Ctl.ParamStatus = 0        'not marked, not updated, not marquee row, not current
''   Ctl.ColumnAddRegexAttr(col) = "^ *-"
''
''   Ctl.ParamStatus = 8        'is  marked, not updated, not marquee row, not current
''   Ctl.ColumnAddRegexAttr(col) = "^ *-"
''
''   Ctl.ParamForeColor = bg
''   Ctl.ParamBackColor = QBColor(14) 'yellow
''
''   Ctl.ParamStatus = 1        'not marked, not updated, not marquee row, is  current
''   Ctl.ColumnAddRegexAttr(col) = "^ *-"
''
''   Ctl.ParamStatus = 9        'is  marked, not updated, not marquee row, is  current
''   Ctl.ColumnAddRegexAttr(col) = "^ *-"
''
''End Sub

Sub TPN_Callback(Index)
'20Oct96 CKJ Added MultiBoxID=3
'21Nov96 CKJ Added params to displaymacrofile
' 6Jan97 CKJ added Trim(left( to consultant
'30May97 CKJ Replaced MultiBoxID with QuesCallbackMode
'16May04 TH  Use new enhanced consultant lookup (enh654)

''Dim ScriptValid%, code$, desc$, temp$
''
''   Select Case QuesCallbackMode  '1,2,3 valid
''      Case 1                     'clinical details
''         Select Case Index
''            Case 1, 2
''               Parsename 4, (Ques.txtQ(Index)), temp
''               Ques.txtQ(Index) = temp
''            Case -1       'consultant field shift-f1
''               If SlavemodeEnabled() Then                 '10nov03 ckj
''                     desc$ = ""                           '   "
''                  Else                                    '   "
''                     If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "OldConsultantForm", 0)) Then                 '16May04 TH Added (enh654)
''                           displaymacrofile dispdata$ + "\conscode.dat", "Consultant Codes", code$, desc$  '22Nov96 EAC
''                        Else                                                                                             '   "
''                           EnhDisplayMacrofile dispdata$ + "\conscode.dat", "Consultant Codes", code$, desc$             '   "
''                        End If                                                                                           '   "
''                     If desc$ <> "" Then Ques.txtQ(-Index) = Trim$(Left$(desc$, 20))  '6Jan97 CKJ added Trim(left(
''                  End If
''
''               'If FrmList.LstPatients.ListIndex <> -1 Then
''               '      Ques.txtQ(-index) = Trim$(Mid$(FrmList.LstPatients.List(FrmList.LstPatients.ListIndex), 5))
''               '   End If
''               'Unload FrmList
''
''               'If Trim$(LstBoxFrm.Tag) <> "" Then
''               '      Ques.txtQ(-index) = Trim$(Mid$(LstBoxFrm.Tag, InStr(LstBoxFrm.Tag, TB) + 1))
''               '   End If
''               'Unload LstBoxFrm
''
''            Case 4, 5
''               If UCase$(Ques.txtQ(Index)) = "T" Then Ques.txtQ(Index) = Mid$(date$, 4, 3) & Left$(date$, 3) & Right$(date$, 4) '18Jul00 CKJ was = td$
''               If UCase$(Ques.txtQ(Index)) = "Y" Then Ques.txtQ(Index) = Format$(Now - 1, "dd-mm-yyyy")
''            Case 8
''               Select Case Val(Ques.txtQ(Index))
''                  Case 0: 'no action
''                  Case Is < 35
''                     popmessagecr "Temperature", "Hypothermic - please re-enter"
''                     ScriptValid = False
''                  Case Is > 45
''                     popmessagecr "Temperature", "Too high - please re-enter"
''                     ScriptValid = False
''                  End Select
''            Case 14
''               enterSerumSodium NaCategory
''               QuesSetCtrl Ques.cmdQ(Index), 0, 0, tp("NaQ" & Format$(NaCategory))
''            Case 15
''               EnterSerumPotassium KCategory
''               QuesSetCtrl Ques.cmdQ(Index), 0, 0, tp("KQ" & Format$(KCategory))
''            'Case 9   adult only
''            '   enteractfact AF$, k
''            '   QuesSetCtrl Ques.cmdQ(Index), 0, 0, tp("af" & Format$(Val(AF$)))
''            'Case 10  adult only
''            '   enterinjfact ifact$, k
''            '   QuesSetCtrl Ques.cmdQ(Index), 0, 0, tp("if" & Format$(Val(ifact$)))
''            End Select
''
''      Case 2                     'regimen details
''         Select Case Index
''            Case 5     'Separate/combined
''               On Error Resume Next
''               If Ques.txtQ(Index) = "Y" Then    'separate
''                     Ques.txtQ(7).Visible = True
''                     Ques.txtQ(10).Visible = True
''                  Else
''                     Ques.txtQ(7).Visible = False
''                     Ques.txtQ(10).Visible = False
''                  End If
''               On Error GoTo 0
''            End Select
''
''      Case 3                     'Defaults for Paed/Adult
''         Select Case Index
''            Case 8, 9
''               If Val(Ques.txtQ(Index)) = 0 Then Ques.txtQ(Index) = "1"
''               If Val(Ques.txtQ(Index)) > 3 Then
''                     popmessagecr "PN Defaults", "Printer number must be 1, 2 or 3" & cr & "It has been reset to 1"
''                     Ques.txtQ(Index) = "1"
''                  End If
''            End Select
''      End Select

End Sub

Sub TPNelect()
'-----------------------------------tpnelect------------------------------5.0
'          Storage and retrieval of TPN electrolyte results
'
'-----------------------------------------------------------------------------
'modifications
'27-2-90 ASC Converted to Q4.5
'17Apr90 CKJ Conversion & bug hunting continued ... V4.2
'12Jun90 CKJ Ltrim & rtrim added round data fields
'11Dec90 ASC converted to get and put patid from gettemp with 173 bytes
'17Feb91 ASC Does not need MBF
'10Aug91 CKJ Locking of PatID improved
'            Now does not save after confirming Esc without save
'26Oct92 ASC wipedef and begline added to inputs
' 4Jan95 CKJ Added GPexp$
'24Mar95 CKJ Close modified
'20Feb96 CKJ TPNELECT program moved to this one SUB in TPNsubs
'            Modified to use file handling library for \Elect
'-----------------------------------------------------------------------------
'item       len
'0    date   8
'1    K      4
'2    NA     4
'3    CA     4
'4    MG     4
'5    ZN     4
'6    AL     4
'7    CR     4
'8    UR     4
'9    GL     4
'10   COM   20
'11   LABNO 12   NB Not 10 as shown in original code
'     Total 76

''Dim ans$, electfil%, lin%, tmp$, X%
''
''   k.escd = False
''  'ReDim result$(10)       'item$(0 To 11)
''   GoSub GetElect          'read existing entry
''
''   ElectAltered = False
''   frmElect.Show 1
''
''   If ElectAltered Then
''         If frmElect.Tag = "-1" Then       'save it
''               GoSub SaveElect
''            Else                           'ask save?
''               'k.helpnum = 2010
''               ans$ = "Y"
''               Confirm tp("ElecExT"), tp("ElecExD"), ans$, k   '"!n!iEscape pressed", "to save changes "
''               If Not k.escd And ans$ = "Y" Then GoSub SaveElect
''            End If
''      End If
''
''   Unload frmElect
''   k.escd = False
''Exit Sub
''
''GetElect:
''   openrandomfile patdatapath$ + "\ELECT", 760, electfil
''   GetRecordNL r, Val(pid.ptr(7)), electfil, 760
''   Close electfil
''   For lin = 0 To 9
''      tmp$ = Mid$(r.record, 76 * lin + 1, 76)
''      UExy$(1, lin + 1) = Trim$(Left$(tmp$, 8))
''      For X = 0 To 8
''         UExy$(X + 2, lin + 1) = Trim$(Mid$(tmp$, 9 + 4 * X, 4)) ' 9-12 to 41-44
''      Next
''      UExy$(11, lin + 1) = Trim$(Mid$(tmp$, 45, 20))
''      UExy$(12, lin + 1) = Trim$(Right$(tmp$, 12))
''   Next
''Return
''
''SaveElect:
''   r.record = ""
''   For lin = 0 To 9
''      tmp$ = pad$(UExy$(1, lin + 1), 8)
''      For X = 0 To 8
''         tmp$ = tmp$ & pad$(UExy$(X + 2, lin + 1), 4)
''      Next
''      tmp$ = tmp$ & pad$(UExy$(11, lin + 1), 20)
''      tmp$ = tmp$ & pad$(UExy$(12, lin + 1), 12)
''      Mid$(r.record, 76 * lin + 1, 76) = tmp$
''   Next
''   openrandomfile patdatapath$ + "\ELECT", 760, electfil
''   PutRecordNL r, Val(pid.ptr(7)), electfil, 760
''   Close electfil
''Return

End Sub

Sub TpnMain(Summary$)
'12Jun97 CKJ Added Summary$ as parameter
'14Nov97 CKJ Added option to allow non OEM accept screen - screen shown but no P&U logo
'13Nov98 CKJ Exitafterprinting enabled
'20Nov98 CKJ/CFY Patientname$ now uses 'sn, fn' when required
'24May99 CKJ Replaced App.Path with AppPathNoSlash
'            Removed call to makecommand Pump.exe
'01Oct99 CFY Sets OCXstatus to ABORT by default. Any other actions that take place during the session
'            will overwrite this.
'05jun00 CKJ Info, kcalPerGramFat & kcalPerGramGlucose read at startup
'18Jul00 CKJ Added module-level batch mode flag. Added check findVLip()
'28jul00 CKJ reset view only status for high level password
'12Jan02 CKJ Accept form configurable. Moved text from the form load event.
'24May02 CKJ Added optional extra message to the accept form; Message2="..."
'            Moved Attr="..." from [Validation] section to [Accept]
'            Changed label to textbox in order to show over 1k of text
'12Jun02 CKJ Accept form default wording uses crlf instead of cr alone
'10may04 ckj removed SetHelp
'02Jul08 CKJ Added option to enforce readonly, for viewing PN in PMR history  (F0018870)

Dim SQLq As String, msg$, txt$, AcceptNeeded, X%, Y%, z%
Dim age$, ageval!, GPexp$, surname$, forename$, status$, ndbd&, lye!, ye$, valid%
Dim defchan%, Info$, count, helpfilecopy$
Dim first%, last%
Dim intChecksum As Integer                                           '12Jan02 CKJ

'Licence file
' MDIEvents.mnuTPN.0    Patient TPN (A/P)
' MDIEvents.mnuTPN.1    Batch
' MDIEvents.mnuTPN.2    Baxa
' frmVA.mnuFile.P       Paed
' frmVA.mnuFile.A       Adult
' frmVA.mnuFile.X       accept screen yes/no
' frmVA.mnuFile.O       OEM version - Pharmacia & Upjohn
' frmVA.mnuIssue        Issue
'     Vacumat
'     EditPrd
'     EditReg
'     EditRule
              
''   If OCXLaunch() Then                       '01Oct99 CFY Added
''         SetOCXStatus STATUS_ABORT           '         "
''      End If                                 '         "
   
   k.escd = False
   helpfilecopy$ = App.HelpFile
   App.HelpFile = AppPathNoSlash() & "\tpnshell.hlp"                '24May99 CKJ replaces app.Path
   
   Screen.MousePointer = HOURGLASS
   Select Case Screen.Width / Screen.TwipsPerPixelX                 '28sep98 CKJ added 0 & 3
      Case Is < 640:  displaysize = 0                               'CE machine
      Case Is < 800:  displaysize = 1                               '640x480
      Case Is < 1024: displaysize = 2                               '800x600
      Case Else:      displaysize = 3                               '1024x768 or better
      End Select

   'td$ = Mid$(Date$, 4, 3) + Left$(Date$, 3) + Right$(Date$, 4)    '15Apr98 CKJ was 'YY'   '18Jul00 CKJ obsolete
   setinput 0, k
   k.HelpFile = "tpn.hlp"
   'sethelp      10may04 ckj removed as it duplicated setinput, then set help to a non-existent file

   'tpninifile$ = "\TPNSETUP.INI"
   tpninifile$ = "\PNSETUP.INI"  '28Mar12 TH Altered
   Summary$ = "PN"                        '12Jun97 CKJ Added

   'acclevels$ char 4 = individual TPN, char 5 = batch tpn
   iBatchMode = (UCase$(pid.sex) = "B")                             '18Jul00 CKJ
   'If UCase$(pid.sex) = "B" Then ' batch production                '   "
   If iBatchMode Then             ' batch production                '   "
         securityaccess = Val(Mid$(acclevels$, 5, 1))
      Else
         securityaccess = Val(Mid$(acclevels$, 4, 1))
      End If

   TpnVO = True
   Select Case securityaccess
      Case Is <= 0
         Screen.MousePointer = STDCURSOR
         popmessagecr tp("sec0t"), tp("sec0d")  ' "!n!iSecurity Clearance", "Insufficient privilege to use this program"
         GoTo wayout
      Case 2
         If Not mTPNreadonly Then                                    '02Jul08 CKJ added
            TpnVO = False
         End If                                                      '   "
         
      Case 9
         Screen.MousePointer = STDCURSOR
         App.HelpFile = AppPathNoSlash() & "\tpnsuper.hlp"           '24May99 CKJ replaces app.Path
         If Not mTPNreadonly Then                                    '02Jul08 CKJ added
            TpnVO = False                                            '28jul00 CKJ added
         End If
         ViewDB
         App.HelpFile = AppPathNoSlash() & "\tpnshell.hlp"          '24May99 CKJ replaces app.Path
         GoTo wayout
      Case Else
         'TpnVO = True
      End Select
   
   ''If adult(pid.sex) Then
      LX frmMsgWin.lblbox, "tpA", 32, 0
      If Val(frmMsgWin.lblbox.Tag) = 0 Then
         LX frmMsgWin.lblbox, "tpP", 32, 0
         If Val(frmMsgWin.lblbox.Tag) = 0 Then
               popmessagecr "PN Module", "Software Licence does not include Paediatric PN"
               Screen.MousePointer = STDCURSOR
               GoTo wayout
         End If
         
      End If
   
   LX frmMsgWin.lblbox, "tpX", 32, 0
   AcceptNeeded = (Val(frmMsgWin.lblbox.Tag) <> 0)   'Val(tp("AcceptScrn"))

   LX frmMsgWin.lblbox, "tpO", 32, 0
   OEMver = (Val(frmMsgWin.lblbox.Tag) <> 0)         'set P&U version
   Unload frmMsgWin
                           
   'If identtype = "1" Then AcceptNeeded = False

''   If AcceptNeeded Then
''         Screen.MousePointer = STDCURSOR
''         Load accept                                       '11Jul99 CKJ   03Sep99 CKJ merged
''         SetTextBoxReadOnly accept.txtMessage, True                                           '24May02 CKJ
''
''         '12Jan02 CKJ Added block. Moved from the form load event of the accept form
''         txt$ = "WARNING" & crlf$ & crlf$ & "This program must only be used by suitably qualified personnel." & crlf$ & crlf$
''         txt$ = txt$ & "The user must fully understand the use of this program before clinical usage,"
''         txt$ = txt$ & " and must carefully review the package insert of all pharmaceutical products"
''         txt$ = txt$ & " to assess their suitability for each patient." & crlf$ & crlf$
''         txt$ = txt$ & "The decision regarding which products to prescribe and in what quantity rests solely with the treating physician." & crlf$ & crlf$
''         txt$ = txt$ & "The user accepts that no information from this program can be interpreted as a prescription or recommendation to prescribe."
''         accept.txtMessage.Text = txt$
''         accept.lblPrompt.Caption = "Confirm acceptance of the conditions of use by pressing the [Accept] button, otherwise press the [Cancel] button."
''
''         msg$ = TxtD(dispdata$ & "\PNaccept.ini", "Accept", "", "Attr", 0)                    '24May02 CKJ moved from [Validation] section
''         If Len(msg$) Then
''               decodehex msg$
''               intChecksum = Val(msg$)
''
''               msg$ = TxtD(dispdata$ & "\PNaccept.ini", "Accept", "", "Message", 0)
''               antihack msg$, intChecksum
''               ParseCtrlChars dispdata$ & "\printer.ini", "Screen", msg$, 0
''               replace msg$, lf, Chr$(1), 0                                                   '24May02 CKJ
''               replace msg$, cr, Chr$(1), 0                                                   '   "
''               replace msg$, Chr$(1), crlf, 0                                                 '   "
''               If Len(msg$) Then accept.txtMessage.Text = msg$
''
''               msg$ = TxtD(dispdata$ & "\PNaccept.ini", "Accept", "", "Message2", 0)          '24May02 CKJ Added block
''               antihack msg$, intChecksum                                                     '   "
''               ParseCtrlChars dispdata$ & "\printer.ini", "Screen", msg$, 0                   '   "
''               replace msg$, lf, Chr$(1), 0                                                   '   "
''               replace msg$, cr, Chr$(1), 0                                                   '   "
''               replace msg$, Chr$(1), crlf, 0                                                 '   "
''               If Len(msg$) Then accept.txtMessage.Text = accept.txtMessage.Text & msg$
''
''               msg$ = TxtD(dispdata$ & "\PNaccept.ini", "Accept", "", "Prompt", 0)
''               antihack msg$, intChecksum
''               ParseCtrlChars dispdata$ & "\printer.ini", "Screen", msg$, 0
''               If Len(msg$) Then accept.lblPrompt.Caption = msg$
''
''               If intChecksum <> 0 Then
''                     accept.txtMessage.Text = "The Parenteral Nutrition module is not available." & crlf & crlf & "The Terms Of Use document has been tampered with," & crlf & "please contact your Supervisor and the ASC Support Desk." & crlf & crlf & "Press the [Cancel] button to exit"
''                     accept.lblPrompt = ""
''                  End If
''            End If
''         '12Jan02 CKJ End block.
''
''         CentreForm accept
''         accept.cmd(0).Visible = False
''         accept.cmd(1).Visible = False
''         If Not OEMver Then accept.Image1.Visible = False  '14Nov97 CKJ Added to allow non OEM accept screen
''         accept.Show
''         accept.Refresh
''      End If
''
''   txt$ = tp("RevNo")                         '14Apr98 CKJ Added for 8.1
''   If txt$ <> "8.1" Then
''         Screen.MousePointer = STDCURSOR
''         popmessagecr ".Warning - Incorrect PN configuration", "PN program cannot run without the correct tpnw.044 file" & cr & "Requires revision 8.1, found " & txt$
''         GoTo wayout
''      End If

''   IgMax = Val(tp("IgMax"))   '@@
''   If IgMax <> 15 Then
''         Screen.MousePointer = STDCURSOR
''         popmessagecr ".Warning - Incorrect PN configuration", "PN program cannot run without the correct tpnw.044 file" & cr & "Requires 15 ingredients, found " & Format$(IgMax)
''         GoTo wayout
''      End If
''   IgMaxIncNonDisp = 33                       '27Aug98 CKJ FIXED VALUE of total num of ingredients
''
''   '03Sep99 CKJ Pumplabel is obsolete
''   Select Case identtype$
''      Case ""
''         GoTo wayout             'not called correctly
''      Case "1", "4", "5"         'full TPN program      30Sep96 CKJ "1" added
''         'PumpLabel = False      '03Sep99 CKJ no action needed
''      Case Else                  'labelling only, called from Pump                   '03Sep99 CKJ
''         'PumpLabel = True                                                           '   "
''         popmessagecr ".", "Printing of labels from Pump.exe is no longer supported" '   "
''         GoTo wayout
''      End Select
''
''   '!!** add err handlers here         -8194 Locked by another user?
''   Set prddb = OpenDatabase(dispdata$ & "\tpnprds.mdb", False, True)
''   prddbopen = 1
''
''   Set regdb = OpenDatabase(dispdata$ & "\stdregs.mdb", False, True)
''   regdbopen = 1
''
''   Set patdb = OpenDatabase(patdatapath$ & "\pattpn.mdb")
''   patdbopen = 1
''
''   'SQLq = "SELECT COUNT (*) FROM prddat WHERE InUse=-1;"              25Mar98 CKJ
''   SQLq = "SELECT COUNT (*) FROM prddat WHERE InUse=-1 AND PrdType IN('1','3','5','7');"  'PN products
''   Set prdss = prddb.CreateSnapshot(SQLq)
''   NP = prdss.Fields(0)
''
''   SQLq = "SELECT COUNT (*) FROM prddat WHERE InUse=-1 AND PrdType IN('2','3','6','7');"  'infusions
''   Set prdss = prddb.CreateSnapshot(SQLq)
''   NPi = prdss.Fields(0)
''
''   SQLq = "SELECT COUNT (*) FROM prddat WHERE InUse=-1 AND PrdType IN('4','5','6','7');"  'enteral
''   Set prdss = prddb.CreateSnapshot(SQLq)
''   NPe = prdss.Fields(0)
''
''   If NP = 0 Then
''         Screen.MousePointer = STDCURSOR
''         popmessagecr "Warning", "No products have been found"
''         GoTo wayout
''      End If

   'ReDim prod(-NPe - NPi To NP, 0 To IgMax) As Single       'all products vol, mg etc
''   ReDim prod(-NPe - NPi To NP, 0 To IgMaxIncNonDisp) As Single '27Aug98 CKJ all products and all ingredients even non displayed ones
''   ReDim Prd(-NPe - NPi To NP) As ProductDetails            'replaces Prd
''   ReDim ig(-NPe - NPi To NP) As Single                     'igs for this patient now
''   ReDim igover!(-NPe - NPi To NP)                          'volume of igs including overage
''   ReDim tot(0 To IgMax) As Single                          'calculated totals of each Ig
''   ReDim ManualIE(2 To 3, 0 To IgMax) As Single             '2D array to hold manually entered infusions & enteral feeds
  
  'ReDim prdname(-NPe - NPi To NP) As String                'all product names 8Apr98 CKJ replaced by PRD().name
  'ReDim Prd(NP, 13 To 20) As String                        'part product info
  'ReDim reg(NP, 3) As String                               'regimen summary info
                                                   
   'SQLq = "SELECT DISTINCTROW * FROM prddat WHERE InUse=-1 ORDER BY PrdID;"    '!!** sort by PrdID
   'SQLq = "SELECT DISTINCTROW * FROM prddat WHERE InUse=-1 ORDER BY SortCode;"    '!!** sort by PrdID
   
''   For Z = 1 To 3
''      Select Case Z
''         Case 1: SQLq = "('1','3','5','7')"                 'PN
''         Case 2: SQLq = "('2','3','6','7')"                 'Infusions
''         Case 3: SQLq = "('4','5','6','7')"                 'Enteral
''         End Select
''
''      SQLq = "SELECT * FROM prddat WHERE InUse=-1 AND PrdType IN" & SQLq & " ORDER BY SortCode;"
''      first = FirstPrd(Z)
''      last = LastPrd(Z)
''
''      If SQLdbg Then popmessagecr "SQL", SQLq
''      Set prdss = prddb.CreateSnapshot(SQLq)
''      prddbopen = 2
''
''      If Not prdss.EOF Then
''            For X = first To last
''               'For y = 1 To IgMax
''               For Y = 1 To IgMaxIncNonDisp                      '27Aug98 CKJ now includes igs up to VitK
''                  'prod!(x, y) = Getfield(prdss.Fields(y))       'Igs 1 to 15
''                  prod!(X, Y) = GetField(prdss.Fields(tp("PrdDat" & Format(Y)))) 'Igs 1 to 15 '11Jul98 CKJ Look name up before use
''               Next
''               prod!(X, 0) = GetField(prdss!ContainerVol)
''               Prd(X).name = GetField(prdss!PrdName)             'name
''               Prd(X).id = GetField(prdss!PrdID)                 'PrdID
''               Prd(X).SpGrav = GetField(prdss!SpGrav)            '13
''               Prd(X).SolnAB = Trim$(GetField(prdss!SolnAB))     '14
''               Prd(X).cost = Trim$(GetField(prdss!cost))         '15 £cost
''               Prd(X).PreMix = GetField(prdss!PreMix)            '16 Mix0-9
''               Prd(X).maxmltotal = GetField(prdss!maxmltotal)    '17 Maxdose
''               Prd(X).linkcode = Trim$(GetField(prdss!linkcode)) '18 NSV or ASCcode link
''               'PRD(x, 19) = Trim$(GetField(prdss!Viscosity))    '19 viscosity
''               Prd(X).maxmlperkg = GetField(prdss!maxmlperkg)
''               Prd(X).SharePacks = GetField(prdss!SharePacks)    ' 0 or -1
''               'spike
''               Prd(X).BaxaMMig = GetField(prdss!BaxaMMig)        'ID Number   '05Jun00 CKJ was integer now string. No change needed here
''               Prd(X).VacumatIg = GetField(prdss!VacumatIg)      'ID Number
''               Prd(X).mOsmperml = GetField(prdss!mOsmperml)
''               Prd(X).gH2Operml = GetField(prdss!gH2Operml)
''               'Protein
''               Prd(X).PO4organic = GetField(prdss!PhosphateIsOrganic)  ' 0 or -1
''               Prd(X).ForPaed = GetField(prdss!ForPaed)          '04Jun98 CKJ Added
''               Prd(X).ForAdult = GetField(prdss!ForAdult)        '   "
''               Prd(X).Info = GetField(prdss!Info)                '05Jun00 CKJ Added
''
''               If prod!(X, 0) < 0.01 Then   'Container vol=0 for product No x
''                     Screen.MousePointer = STDCURSOR
''                     popmessagecr tp("vol0t"), tp("vol0d") + Str$(X)
''                     GoTo wayout                                          '<== WAY OUT
''                  End If
''               prdss.MoveNext
''               If prdss.EOF And X < last Then
''                     popmessagecr ".", "Unable to load all PN products" & cr & "Please report these codes:" & Str$(X) & Str$(first) & Str$(last)
''                     GoTo wayout
''                  End If
''            Next
''         End If
''      Next
''
''   If prddbopen = 2 Then prdss.Close: prddbopen = 1

   'ofs = Val(tpnini$("offset", "0"))           '2Jan96 CKJ  24Oct96 CKJ Removed
   adjKpaed = Val(tpnini$("adjKpaed", "1"))
   adjKadult = Val(tpnini$("adjKadult", "0"))
   PaedKClKPO4split = Val(tpnini$("PaedKClKPO4split", "1"))
   adjNaPaed = Val(tpnini$("adjNaPaed", "1"))
   adjNaAdult = Val(tpnini$("adjNaAdult", "0"))

   IgVol = 0    'tp("IgVol")              'the ingredient number (PrdID) for each ig
   igCals = 1   'tp("IgCals")             'now hard coded; too dangerous to keep outside.
   igN = 2      'tp("IgN"))
   igGl = 3     'tp("IgGl")
   igFat = 4    'tp("IgFat")
   IgNa = 5     'tp("IgNa")
   igK = 6      'tp("IgK")
   IgCa = 7     'tp("IgCa")
   IgMg = 8     'tp("IgMg")
   IgZn = 9     'tp("IgZn")
   IgPO4 = 10   'tp("IgPO4")
   IgCl = 11    'tp("IgCl")
   IgAcet = 12  'tp("IgAcet")
   IgSe = 13    'tp("IgSe")
   IgCu = 14    'tp("IgCu")
   IgFe = 15                              '8Apr98 CKJ

   IgMn = 17                              ' 1Sep98 CKJ
   IgVitE = 31                            '16Feb00 CKJ
   IgVitK = 33                            '27Aug98 CKJ

   'PrdDil = GetPrdNum("PrdDil")          'diluent' ie Gl 5% or WFI
   'PrdNaCl = GetPrdNum("PrdNaCl")        'NaCl
   'PrdKCl = GetPrdNum("PrdKCl")          'KCl
   'PrdKPO4 = GetPrdNum("PrdKPO4")        'KPO4
   'If k.escd Then GoTo wayout

''   SetPrdForIg
''   If k.escd Then GoTo wayout
''
''   Screen.MousePointer = STDCURSOR
''   If Not findpotchlor() Then GoTo wayout                  'halts if not suitable
''   If Not findsodchlor() Then GoTo wayout                  'halts if not suitable
''   If Not findSDil() Then GoTo wayout                      '  "
''   If Not findKPO4() Then GoTo wayout                      '  "
''   If Not findVLip() Then GoTo wayout                      '18Jul00 CKJ Added check for lipid soluble vitamin product
''
''   '05Jun00 CKJ Added block
''   kcalPerGramFat! = Val(TxtD$(dispdata$ & "\tpn.ini", "", "10", "kcalPerGramFat", 0))          'default to 10kcal/gram fat         '//
''   Select Case kcalPerGramFat!
''      Case Is < 8, Is > 10
''         popmessagecr ".", "WARNING: Invalid TPN.INI setting found, kcalPerGramFat =" & Str$(kcalPerGramFat!)
''         GoTo wayout
''      End Select
''
''   '05Jun00 CKJ Added block
''   kcalPerGramGlucose! = Val(TxtD$(dispdata$ & "\tpn.ini", "", "4", "kcalPerGramGlucose", 0))   'default to  4kcal/gram glucose     '//
''   Select Case kcalPerGramGlucose!
''      Case Is < 3.4, Is > 4
''         popmessagecr ".", "WARNING: Invalid TPN.INI setting found, kcalPerGramGlucose =" & Str$(kcalPerGramGlucose!)
''         GoTo wayout
''      End Select
''
''   If AcceptNeeded Then
''         'accept.cmd(0).Visible = True                               '12Jan02 CKJ removed
''         If intChecksum = 0 Then accept.cmd(0).Visible = True        '   "        added
''         accept.cmd(1).Visible = True
''         Do While accept.Visible
''            DoEvents
''         Loop
''         If accept.Tag <> "-1" Then GoTo wayout
''         Screen.MousePointer = HOURGLASS
''         Unload accept
''      End If
''
''   If fileexists(dispdata$ + "\tpndeflt.v5") Then                   '14Nov96 CKJ Moved to here
''         openrandomfile dispdata$ & "\tpndeflt.v5", Len(tpndef), defchan
''         If adult(pid.sex) Then
''               If UCase$(pid.sex) = "B" Then Info$ = tp("infoB")    '"Batch production "
''               Info$ = Info$ + tp("infoA")                          '"Adult TPN"
''               GetRecordNL r, 2, defchan, Len(tpndef)
''            Else
''               Info$ = tp("infoP")                                  '"Paediatric TPN"
''               GetRecordNL r, 1, defchan, Len(tpndef)
''            End If
''         LSet tpndef = r
''         Close defchan
''         For Count = 1 To 3         ' preset overages
''            'overage(Count) = tpndef.overagevol(Count)                        '1Sep98 CKJ
''            overage(Count) = Iff(adult(pid.sex), 0, tpndef.overagevol(Count)) '1Sep98 CKJ 0 if adult
''         Next
''
''         'lpt1 = ""                                                                  '18Jul00 CKJ obsolete
''         'If tpndef.plainprinter = 2 Then lpt1 = "LPT2:"   ' default is to spool     '18Jul00 CKJ obsolete
''
''      Else
''         popmessagecr tp("def0t"), tp("def0d")   '"!n!bTPN defaults", "Default settings must be entered from the TPN utility menu"
''         GoTo wayout
''      End If
''
''   ClearPatientDetails                         '!!** new
''
''   '03Sep99 CKJ Pumplabel is obsolete, block removed
''   'If PumpLabel Then
''   '      PumpRegFile$ = identtype$             'filename of regimen eg DE456.ASC
''   '      If fileexists(PumpRegFile$) Then
''   '            fromfile = True
''   '            regchan = FreeFile
''   '            Open PumpRegFile$ For Input As regchan
''   '            x = 0
''   '            totalvolume! = 0
''   '            Line Input #regchan, BagNo$
''   '            Line Input #regchan, regname$
''   '            Line Input #regchan, BatchNumber$ '22Aug93
''   '            Line Input #regchan, braunhospname$
''   '            Line Input #regchan, txt$         'WARD_CONS'
''   '            pid.ward = Left$(txt$, 4)         'was 5
''   '            pid.cons = Mid$(txt$, 6, 4)       'was 5
''   '            Line Input #regchan, patientname$
''   '            Line Input #regchan, orddate$
''   '            Line Input #regchan, Setup$
''   '            Line Input #regchan, temp$
''   '            ReDim lines$(30)
''   '            deflines temp$, lines$(), ",", 1, numoflines
''   '            pid.caseno = lines$(1)
''   '            pid.status = lines$(2)
''   '            pid.sex = lines$(3)
''   '            pid.recno = lines$(4)    '8Jan95 CKJ Copied edit from V6.3 3Nov94
''   '            Line Input #regchan, temp$
''   '
''   '            'seplbls$ = "N"      '## original line
''   '            lblscombined = True  '## added
''   '            Do While Not EOF(regchan)
''   '               Line Input #regchan, temp$
''   '               deflines temp$, lines$(), ",", 1, numoflines
''   '               x = x + 1
''   '               ig!(Val(lines$(1))) = Val(lines$(numoflines)) '8Nov93 CKJ was (3)
''   '               If Left$(lines$(2), 1) = "~" Then
''   '                     'seplbls$ = "Y"         '## original
''   '                     lblscombined = False    '## added
''   '                  End If
''   '            Loop
''   '
''   '            If x > 24 Then   '!!**
''   '                  popmessagecr tp("ABORTING"), tp("TooLarge")
''   '                  x = 0
''   '               End If
''   '            Close #regchan
''   '         Else
''   '            popmessagecr "!n!b" + tp("ERROR"), tp("NoFile")
''   '            GoTo wayout
''   '         End If
''   '   Else                        'read patient or hospital if batch
''
''   getpatidL patno&, pid                                 '<== LOCK 10Aug91 CKJ
''   Expandpid pid, dob$, age$, ageval!, wardexp$, consexp$, GPexp$
''   surname$ = Trim$(pid.surname)
''   forename$ = Trim$(pid.forename)
''   weight! = Val(pid.weight)
''   Select Case Val(pid.Height)
''      Case Is >= 10     'cms           (10 or above)
''         heightcms = Val(pid.Height)
''      Case Is > 0       'feet & inches (below 10)
''         heightcms = ((Val(Left$(pid.Height, 1)) * 12) + Val(Right$(pid.Height, 2))) * 2.54
''      Case Else         '              (missing)
''         heightcms = 0
''      End Select
''   status$ = pid.status
''   'patientname$ = forename$ + " " + surname$          '20Nov98 CKJ/CFY removed
''   buildname pid, False, patientname$                  '   "            allows 'sn, fn'
''   AgeInDays& = 0
''   AgeInYears! = 0
''   If ageval! Then  'dob is valid
''         datetodays dob$, "", ndbd&, lye!, ye$, valid%
''         If valid% Then
''               AgeInDays& = ndbd&
''               AgeInYears! = ageval!
''            End If
''      End If
''
''   gettpn
''   If Val(pid.ptr(6)) = 0 Then
''         pid.ptr(6) = "-1"
''         PutPatidNL patno&, pid                       '<== No locking 10Aug91 CKJ
''      End If
''   TPNchanged = False
''   UnlockPatid patno&, Len(pid)                       '<== UNLOCK 10Aug91 CKJ
''
''   '   End If      '03Sep99 CKJ Pumplabel is obsolete
''
''   If InStr(wardexp$, "Invalid") > 0 Or wardexp$ = " " Then wardexp$ = pid.ward  '12Aug94 CKJ/NAH added OR exp$=" "
''   If InStr(consexp$, "Invalid") > 0 Or consexp$ = " " Then consexp$ = pid.cons  '12Aug94 CKJ/NAH added OR exp$=" "
''
''   Screen.MousePointer = STDCURSOR
''
''   'For z = 0 To 3                                                               '21Sep98 CKJ
''   '   ModIg(z) = -1                                                             '   "
''   'Next                                                                         '   "
''   ClearBlobs                                                                    '   "
''
''   'If fileexists(dispdata$ + "\tpndeflt.v5") Then
''         'OpenRandomFile dispdata$ + "\tpndeflt.v5", Len(tpndef), defchan
''         'If Adult(pid.sex) Then
''         '      If UCase$(pid.sex) = "B" Then info$ = tp("infoB")    '"Batch production "
''         '      info$ = info$ + tp("infoA")  '"Adult TPN"
''         '      GetRecordNL R, 2, defchan, Len(tpndef)
''         '   Else
''         '      info$ = tp("infoP")  '"Paediatric TPN"
''         '      GetRecordNL R, 1, defchan, Len(tpndef)
''         '   End If
''         'LSet tpndef = R
''         'Close defchan
''         'For Count = 1 To 3         ' preset overages
''         '   overage(Count) = tpndef.overagevol(Count)
''         'Next
''
''         'Select Case seplbls$      '##
''         '   Case "Y", "N": 'OK
''         '   Case Else: seplbls$ = Mid$("NY", 1 - tpndef.seplabels, 1) 'default
''         '   End Select
''         'lblscombined = Not tpndef.seplabels <stored in pt data now
''
''         'lpt1 = ""
''         'If tpndef.plainprinter = 2 Then lpt1 = "LPT2:"   ' default is to spool
''
''   '03Sep99 CKJ Pumplabel is obsolete, block removed
''   'If PumpLabel Then
''   '      PrintTPNlabel           ' label only
''   '   Else
''
''   SetPrdForIg             ' reset prds for igs based on actual patient loaded
''   If Not k.escd Then
''         If Not OEMver Then
''               frmVA.Image1(1) = frmVA.Image1(0)
''               frmVA.Picture1.Picture = frmVA.Image1(0)
''            End If
''         'frmVA.mnuTips.Enabled = False '3Jan97 CKJ Removed for V7.50  1Jul97 CKJ Renabled
''         CentreForm frmVA
         LX frmVA.mnuIssue, "", 2, 0                                  'enable issue
''         ExitAfterPrinting = False                                    '13Nov98 CKJ added
''
''         frmVA.Show 1                                                 '<== ALL TPN CODE
''
''         Summary$ = "PN: " & GetField(patds!ModRegName) & Chr$(30)    '12Jun97 CKJ Added
''         If ExitAfterPrinting Then Summary$ = Nul & Summary$          '13Nov98 CKJ added
''         If IsNull(patds!AuthModDate) Then
''               Summary$ = Summary$ & "(Not Authorised)"
''            Else
''               Summary$ = Summary$ & "(" & Format$(GetField(patds!AuthModDate), "dd mmm yyyy hh:nn")
''               Summary$ = Summary$ & ", " & GetField(patds!AuthModUser) & ")"
''            End If
''      End If
''
''   '   End If   '03Sep99 CKJ Pumplabel is obsolete
''
''   '   Else
''   '      popmessagecr tp("def0t"), tp("def0d")   '"!n!bTPN defaults", "Default settings must be entered from the TPN utility menu"
''   '   End If

wayout:
   On Error Resume Next
''   If patdbopen = 2 Then patds.Close: patdbopen = 1       ' shut down databases
''   If patdbopen = 1 Then patdb.Close: patdbopen = 0
''   If regdbopen = 2 Then regss.Close: regdbopen = 1
''   If regdbopen = 1 Then regdb.Close: regdbopen = 0
''   If prddbopen = 2 Then prdss.Close: prddbopen = 1
''   If prddbopen = 1 Then prddb.Close: prddbopen = 0
''   On Error GoTo 0
   
  '24May99 CKJ Removed block - has not been used & won't be
  ' If PumpLabel Then
  '       ChDir progsdrv$ + "\baxa"   '20Mar95 CKJ added progsdrv
  '       identtype$ = ""
  '       makecommand "pump"          '!!** needs thought
  '    End If

''   App.HelpFile = helpfilecopy$
''
''   mTPNreadonly = False                '02Jul08 CKJ added

End Sub

Sub ViewDB()
'''User may come here for viewing or editing - depending on password  [**!! not enabled yet]
'''22Dec96 CKJ Moved editable DB fields to licence file
'''28Jan98 CKJ
'''03Sep99 CKJ Merged lipid syringle label layout
'''05Jun00 CKJ Added error handling round dynaset update & set k.max for each data type.
'''            Added logging of each change to dispdata.xxx/pnedit.log
'''            Note that pn defaults are encoded in hex - no easy way to dismember these and
'''            that rtf changes are not shown as differences, just a record of UserID & date
'''18Jul00 CKJ Widened columns which were too narrow
'''            Added view only option, where password is 1-8 inclusive.
'''            Added print list option for the databases
''
''Dim msg$, ans1$, ans2$, ans3$, rule$, SQLq$, i%, tmp$, dat$, numoflines%, flag%, Value$
''Dim key1&, key2&, idx1%, ans0%, numoptions%, X%
''Dim Title$, edflag$, Changed%, itemname$, TopField$, tmp1$
''Dim db As Database, ds As Dynaset
''Dim db1 As Database, ds1 As Dynaset
''Dim filename$, txt$, txtwas$, dummy%, change%, fullpage%, special%, units$
''Dim sErr$, iErr%                                                                       '05Jun00 CKJ
''Dim sLogText As String                                                                 '         "
''Dim ViewOnly As Integer
''
''ReDim lines$(100)
''
''   numoptions = Val(tp("DBtot"))
''   If numoptions = 0 Then
''         popmessagecr "ASCribe", "Cannot display the list of editable tables" & cr & "File \ascroot\tpnw.044 is missing or out of date."
''         Exit Sub
''      End If
''
''   Select Case securityaccess                                                          '18Jul00 CKJ added view only options
''      Case Is <= 0
''         popmessagecr tp("sec0t"), tp("sec0d")  ' "!n!iSecurity Clearance", "Insufficient privilege to use this program"
''         Exit Sub
''      Case 9
''         sLogText = "PN Supervisor Editor"
''         ViewOnly = False
''      Case Else
''         sLogText = "PN Configuration Viewer"
''         ViewOnly = True
''      End Select
''
''   'sLogText = "PN Supervisor Editor - Started on terminal " & ASCTerminalName$()      '05Jun00 CKJ added
''   sLogText = sLogText & " - Started on terminal " & ASCTerminalName$()                '18Jul00 CKJ modified
''   WriteLog dispdata$ & "\PNedit.log", 0, UserID$, sLogText                            '   "
''
''   Do
''      'k.helpnum = 0
''      LstBoxFrm.Caption = "Database & layout viewer"
''      LstBoxFrm.lblTitle = cr & "Select database or layout to examine" & cr
''      LstBoxFrm.lblHead = ""
''
''      For i = 1 To numoptions
''         tmp$ = tp("DB" & Format$(i))
''         deflines tmp$, lines$(), "!", 1, numoflines
''         If numoflines = 2 Then
''               LstBoxFrm.LstBox.AddItem lines$(2)
''               LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = Val(lines$(1))
''            End If
''      Next
''
''      If MasterDebug Then
''            LstBoxFrm.LstBox.AddItem "ASCribe Utilities"
''            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 0
''            LstBoxFrm.LstBox.AddItem "   Products Database"
''            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 701
''            LstBoxFrm.LstBox.AddItem "   Standard Regimens Database"
''            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 702
''            LstBoxFrm.LstBox.AddItem "   Patient Regimens Database"
''            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 703
''            LstBoxFrm.LstBox.AddItem "   Rules and Prescription Proforma Database"
''            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 704
''            LstBoxFrm.LstBox.AddItem "   Edit \ASCROOT\TPNW.044 file"
''            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 601
''            LstBoxFrm.LstBox.AddItem "   Edit \DISPDATA.xxx" & tpninifile$ & " file"
''            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 602
''            LstBoxFrm.LstBox.AddItem "   Edit \DISPDATA.xxx\TPN.INI file"
''            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 603
''         End If
''
''      LstBoxFrm.LstBox.ListIndex = ans0
''
''      LstBoxShow
''
''      ans1$ = ""
''      ans0 = LstBoxFrm.LstBox.ListIndex
''      If ans0 > -1 Then
''            ans1$ = Format$(LstBoxFrm.LstBox.ItemData(ans0))
''         End If
''      Unload LstBoxFrm
''
''      Select Case ans1$
''         Case "301", "302", "401", "402", "403", "601", "602", "603", "701", "702", "703", "704"
''            If ViewOnly Then
''                  ans1$ = "0"
''                  popmessagecr "!", cr & "This option cannot be viewed using a low level password" & cr
''               End If
''         End Select
''
''      Select Case ans1$
''         Case "101", "111"                          'Products Database
''            Title$ = "PN Products Database"
''            Set db = OpenDatabase(dispdata$ & "\tpnprds.mdb", False, False)
''
''            Do
''               'SQLq = "SELECT * FROM prddat WHERE PrdType='1' ORDER BY SortCode;"
''               'SQLq = "SELECT * FROM prddat WHERE PrdType IN('1','3','5','7') ORDER BY SortCode;"     '12Jul98 CKJ removed
''               'SQLq = "SELECT * FROM prddat WHERE PrdType >='1' AND PrdType <='7' ORDER BY SortCode;"  '   "        show all products, not just PN
''               If ans1$ = "101" Then           'All products
''                     SQLq = "SELECT * FROM prddat WHERE PrdType >='0' AND PrdType <='7' ORDER BY SortCode;"  '   "        show all products, not just PN
''                  Else                         'Non-PN products only
''                     SQLq = "SELECT * FROM prddat WHERE PrdType IN('0','2','4','6') ORDER BY SortCode;"  '   "        show all products, not just PN
''                  End If
''               If SQLdbg Then popmessagecr "SQL", SQLq
''               Set ds = db.CreateDynaset(SQLq)
''
''               k.helpnum = 5100
''               LstBoxFrm.Caption = Title$
''               'LstBoxFrm.lblTitle = cr & "All products  " & cr                                      '18Jul00 CKJ Added print
''               LstBoxFrm.lblTitle = cr & "All products" & cr & "Press Shift-F1 or click right mouse button for menu" & cr
''               'LstBoxFrm.lblHead = "  Name" & Space$(28) & TB & "In Use" & TB & "Part" & TB & "Adult" & TB & "Paediatric" & TB & "PN   " & TB & "Infusion" & TB & "Enteral       "
''               LstBoxFrm.lblHead = "  Name" & Space$(28) & TB & "In Use" & TB & "Part" & TB & "Adult" & TB & "Paed." & TB & "PN   " & TB & "Infusion" & TB & "Enteral       "
''            '   LstBoxFrm.LstBox.AddItem "  < Print all products >"
''            '   LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -2
''               popmenu 0, "", 0, 0                                                                   '18Jul00 CKJ Added
''               popmenu 2, "&View or Edit Item[cr]&Print list", 0, 0                                  '   "
''
''               Do While Not ds.EOF
''                  tmp$ = "  " & GetField(ds!PrdName) & TB
''                  tmp$ = tmp$ & YesNo(GetField(ds!inuse)) & TB
''                  tmp$ = tmp$ & GetField(ds!SolnAB) & TB                '12Jul98 CKJ added
''                  tmp$ = tmp$ & YesNo(GetField(ds!ForAdult)) & TB
''                  tmp$ = tmp$ & YesNo(GetField(ds!ForPaed)) & TB
''                  tmp$ = tmp$ & YesNo(GetField(ds!PrdType) And 1) & TB  '12Jul98 CKJ added
''                  tmp$ = tmp$ & YesNo(GetField(ds!PrdType) And 2) & TB  '   "
''                  tmp$ = tmp$ & YesNo(GetField(ds!PrdType) And 4)       '   "
''                  replace tmp$, "_", "  ", 0
''                  LstBoxFrm.LstBox.AddItem tmp$
''                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(ds!PrdID)
''                  ds.MoveNext
''               Loop
''               'LstBoxFrm.LstBox.ListIndex = idx1
''
''               LstBoxShow
''
''               key1& = -1
''               idx1 = LstBoxFrm.LstBox.ListIndex
''               If idx1 > -1 Then key1& = LstBoxFrm.LstBox.ItemData(idx1)
''               If LstBoxFrm.LstBox.Tag = "2" Then key1& = -2                                 '18Jul00 CKJ Print requested
''
''               Select Case key1&
''                  Case -1
''                     k.escd = True
''                  Case -2
''                     PrintlistBoxContents                                                    '18Jul00 CKJ Added print option
''                  Case Is >= 0                  'List of fields in this product
''                     SQLq = "SELECT * FROM prddat where PrdID=" & Str$(key1&) & ";"
''                     itemname$ = "Product"
''                     'dat$ = "PrdID,PrdName,!InUse,!ForPaed,!ForAdult,!Cost,!BaxaMMIg,!VacumatIg,!SharePacks,LastModDate,LastModUser,LastModTerm,LinkCode,SolnAB,PreMix,MaxmlTotal,Maxmlperkg,SpGrav,Viscosity,mOsmperml,gH2Operml,PhosphateIsOrganic,SortCode,ContainerVol,1#,2#,3#,4#,5#,6#,7#,8#,9#,10#,11#,12#,13#,14#,15#,16#,17#,18#,19#,20#,21#,22#,23#,24#,25#,26#,27#,28#,29#,30#,31#,32#,33#"
''                     'LX LstBoxFrm.LstBox, "TPDB101", 32, 0
''                     LX LstBoxFrm.LstBox, "TPDB" & ans1$, 32, 0
''                     dat$ = LstBoxFrm.LstBox.Tag
''                     LstBoxFrm.LstBox.Tag = ""
''                     TopField$ = "prdname"
''                     If SQLdbg Then popmessagecr "SQL", SQLq
''
''                     GoSub ProcessList
''                     k.escd = False
''                  End Select
''               Unload LstBoxFrm
''            Loop Until k.escd
''            popmenu 0, "", 0, 0                                                              '18Jul00 CKJ Added
''            ds.Close
''            Set ds = Nothing
''            db.Close
''            Set db = Nothing
''
''         Case "102"
''            Title$ = "PN Ingredient Supplied by Product Database"
''            'dat$ = "RuleNumber,!Description,!RuleSQL,!Explanation,!IngredientName,!IngredientAction,!InUse,!PerKilo,Locked,LastModDate,LastModUser,LastModTerm"
''            LX LstBoxFrm.LstBox, "TPDB102", 32, 0
''            dat$ = LstBoxFrm.LstBox.Tag
''            LstBoxFrm.LstBox.Tag = ""
''            Set db = OpenDatabase(dispdata$ & "\stdregs.mdb", False, False)
''
''            Do
''               SQLq = "SELECT * FROM rules WHERE RuleType=0 ORDER BY RuleNumber;"
''               If SQLdbg Then popmessagecr "SQL", SQLq
''               Set ds = db.CreateDynaset(SQLq)
''
''               k.helpnum = 5100
''               LstBoxFrm.Caption = "PN Rules Database"
''               'LstBoxFrm.lblTitle = cr & "Rule type 0" & cr                                         '18Jul00 CKJ
''               LstBoxFrm.lblTitle = cr & "Rule type 0" & cr & "Press Shift-F1 or click right mouse button for menu" & cr
''               'LstBoxFrm.lblHead = "  Name" & Space$(28) & TB & "In Use" & TB & "Per kg"            '18Jul00 CKJ
''               LstBoxFrm.lblHead = "  Name" & Space$(35) & TB & "In Use" & TB & "Per kg"             '   "
''              ' LstBoxFrm.LstBox.AddItem "  < Print all rules >"
''              ' LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -2
''               popmenu 0, "", 0, 0                                                                   '18Jul00 CKJ Added
''               popmenu 2, "&View or Edit Item[cr]&Print list", 0, 0                                  '   "
''
''               Do While Not ds.EOF
''                  tmp$ = "  " & GetField(ds!Description) & TB
''                  tmp$ = tmp$ & YesNo(GetField(ds!inuse)) & TB
''                  tmp$ = tmp$ & YesNo(GetField(ds!perkilo)) & TB
''                  replace tmp$, "_", "  ", 0
''                  LstBoxFrm.LstBox.AddItem tmp$
''                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(ds!RuleID)
''                  ds.MoveNext
''               Loop
''               'LstBoxFrm.LstBox.ListIndex = key1&
''
''               LstBoxShow
''
''               key1& = -1
''               If LstBoxFrm.LstBox.ListIndex > -1 Then
''                     key1& = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
''                  End If
''               If LstBoxFrm.LstBox.Tag = "2" Then key1& = -2                                 '18Jul00 CKJ Print requested
''
''               Select Case key1&
''                  Case -1
''                     k.escd = True
''                  Case -2
''                     PrintlistBoxContents                                                    '18Jul00 CKJ Added print option
''                  Case Is >= 0
''                     SQLq = "SELECT * FROM rules WHERE RuleID=" & Str$(key1&) & ";"
''                     Title$ = "PN Rules Database"
''                     itemname$ = "Rule"
''                     TopField$ = "Description"
''                     If SQLdbg Then popmessagecr "SQL", SQLq
''
''                     GoSub ProcessList
''                     k.escd = False
''                  End Select
''               Unload LstBoxFrm
''            Loop Until k.escd
''            popmenu 0, "", 0, 0                                                              '18Jul00 CKJ Added
''            ds.Close
''            Set ds = Nothing
''            db.Close
''            Set db = Nothing
''
''         Case "103", "104"
''            Title$ = "PN Standard Regimen Database - "
''            If ans1$ = "103" Then
''                  rule$ = "-1"
''                  Title$ = Title$ & "Paediatric"
''                  'dat$ = "!RegName,!InUse,!PerKilo,Locked,LastModDate,LastModUser,LastModTerm,!1#,!2#,!3#,!4#,!5#,!6#,!7#,!8#,!9#,!10#,!11#,!12#,!13#,!14#,!15#,!16#,!17#,!18#,!19#,!20#,!21#,!22#,!23#,!24#,!25#,!26#,!27#,!28#,!29#,!30#,!31#,!32#,!33#,!34#,!35#,!36#,!37#,!38#,!39#,!40#,!41#,!42#,!43#,!44#,!45#,!46#,!47#,!48#,!49#,!50#"
''                  LX LstBoxFrm.LstBox, "TPDB103", 32, 0
''                  units$ = " ml/kg"
''               Else
''                  rule$ = "0"
''                  Title$ = Title$ & "Adult and Batch"
''                  'dat$ = "!RegName,!InUse,!PerKilo,!TotgN,!TotCal,!TotVol,Locked,LastModDate,LastModUser,LastModTerm,!1#,!2#,!3#,!4#,!5#,!6#,!7#,!8#,!9#,!10#,!11#,!12#,!13#,!14#,!15#,!16#,!17#,!18#,!19#,!20#,!21#,!22#,!23#,!24#,!25#,!26#,!27#,!28#,!29#,!30#,!31#,!32#,!33#,!34#,!35#,!36#,!37#,!38#,!39#,!40#,!41#,!42#,!43#,!44#,!45#,!46#,!47#,!48#,!49#,!50#"
''                  LX LstBoxFrm.LstBox, "TPDB104", 32, 0
''                  units$ = " ml"
''               End If
''            dat$ = LstBoxFrm.LstBox.Tag
''            LstBoxFrm.LstBox.Tag = ""
''            Set db = OpenDatabase(dispdata$ & "\stdregs.mdb", False, False)
''            'make a ds with all PN products for use later
''            Set db1 = OpenDatabase(dispdata$ & "\tpnprds.mdb", False, False)
''            SQLq = "SELECT * FROM prddat WHERE PrdType IN('1','3','5','7') ORDER BY SortCode;"
''            If SQLdbg Then popmessagecr "SQL", SQLq
''            Set ds1 = db1.CreateDynaset(SQLq)
''
''            Do
''               SQLq = "SELECT * FROM stdreg WHERE PerKilo=" & rule$ & " ORDER BY StdRegID;"
''               If SQLdbg Then popmessagecr "SQL", SQLq
''               Set ds = db.CreateDynaset(SQLq)
''
''               k.helpnum = 5100
''               LstBoxFrm.Caption = Title$
''               'LstBoxFrm.lblTitle = cr & "Standard regimens" & cr                                                               '18Jul00 CKJ
''               LstBoxFrm.lblTitle = cr & "Standard regimens" & cr & "Press Shift-F1 or click right mouse button for menu" & cr   '18Jul00 CKJ Added
''               LstBoxFrm.lblHead = "  Name" & Space$(28) & TB & "In Use" & TB & "Per Kilo"
''            '  LstBoxFrm.LstBox.AddItem "  < Print all products >"
''            '  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -2
''               popmenu 0, "", 0, 0                                                           '18Jul00 CKJ Added
''               popmenu 2, "&View or Edit Item[cr]&Print list", 0, 0                          '   "
''
''               Do While Not ds.EOF
''                  tmp$ = "  " & GetField(ds!regname) & TB
''                  tmp$ = tmp$ & YesNo(GetField(ds!inuse)) & TB
''                  tmp$ = tmp$ & YesNo(GetField(ds!perkilo)) & TB
''                  replace tmp$, "_", "  ", 0
''                  LstBoxFrm.LstBox.AddItem tmp$
''                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(ds!StdRegID)
''                  ds.MoveNext
''               Loop
''               'LstBoxFrm.LstBox.ListIndex = key1&
''
''               LstBoxShow
''
''               key1& = -1
''               If LstBoxFrm.LstBox.ListIndex > -1 Then
''                     key1& = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
''                  End If
''               If LstBoxFrm.LstBox.Tag = "2" Then key1& = -2                                 '18Jul00 CKJ Print requested
''
''               Select Case key1&
''                  Case -1
''                     k.escd = True
''                  Case -2
''                     PrintlistBoxContents                                                    '18Jul00 CKJ Added print option
''                  Case Is >= 0                  'List of fields in this product
''                     SQLq = "SELECT * FROM stdreg WHERE StdRegID=" & Str$(key1&) & ";"
''                     itemname$ = "Regimen"
''                     TopField$ = "regname"
''                     If SQLdbg Then popmessagecr "SQL", SQLq
''
''                     GoSub ProcessList
''                     k.escd = False
''                  End Select
''               Unload LstBoxFrm
''            Loop Until k.escd
''            popmenu 0, "", 0, 0                                                              '18Jul00 CKJ Added
''            ds1.Close
''            Set ds1 = Nothing
''            db1.Close
''            Set db1 = Nothing
''            ds.Close
''            Set ds = Nothing
''            db.Close
''            Set db = Nothing
''
''         Case "105", "106", "107", "108"
''            Set db = OpenDatabase(dispdata$ & "\stdregs.mdb", False, False)
''            rule$ = Format$(Val(ans1$) - 104)
''            If ans1$ = "105" Then  'list items in order required, editing allowed if prefixed with '!'
''                  '22Dec96 CKJ Added RuleSQL to list
''                  'dat$ = "!InUse,PerKilo,LastModDate,LastModUser,LastModTerm,RuleSQL,Explanation,Volume,Calories,Nitrogen,Glucose,Fat,Sodium,Potassium,Calcium,Magnesium,Zinc,Phosphate,Chloride,Acetate,Selenium,Copper,AquVitamins,FatVitamins"
''                  LX LstBoxFrm.LstBox, "TPDB105", 32, 0
''               Else
''                  'dat$ = "!InUse,PerKilo,LastModDate,LastModUser,LastModTerm,Critical,RuleSQL,IngredientName,IngredientAction,IngredientValue,Explanation"
''                  LX LstBoxFrm.LstBox, "TPDB106", 32, 0
''               End If
''            dat$ = LstBoxFrm.LstBox.Tag
''            LstBoxFrm.LstBox.Tag = ""
''
''            Do
''               SQLq = "SELECT * FROM rules WHERE RuleType=" & rule$ & " ORDER BY RuleNumber;"
''               If SQLdbg Then popmessagecr "SQL", SQLq
''               Set ds = db.CreateDynaset(SQLq)
''
''               k.helpnum = 5100
''               LstBoxFrm.Caption = "PN Rules Database"
''               'LstBoxFrm.lblTitle = cr & "Rule type " & rule$ & cr                          '18Jul00 CKJ
''               LstBoxFrm.lblTitle = cr & "Rule type " & rule$ & cr & "Press Shift-F1 or click right mouse button for menu" & cr
''               'LstBoxFrm.lblHead = "  Name" & Space$(28) & TB & "In Use" & TB & "Per kg"    '18Jul00 CKJ
''               LstBoxFrm.lblHead = "  Name" & Space$(35) & TB & "In Use" & TB & "Per kg"     '   "
''              ' LstBoxFrm.LstBox.AddItem "  < Print all rules >"
''              ' LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -2
''               popmenu 0, "", 0, 0                                                           '18Jul00 CKJ Added
''               popmenu 2, "&View or Edit Item[cr]&Print list", 0, 0                          '   "
''
''               Do While Not ds.EOF
''                  tmp$ = "  " & GetField(ds!Description) & TB
''                  tmp$ = tmp$ & YesNo(GetField(ds!inuse)) & TB
''                  tmp$ = tmp$ & YesNo(GetField(ds!perkilo)) & TB
''                  replace tmp$, "_", "  ", 0
''                  LstBoxFrm.LstBox.AddItem tmp$
''                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(ds!RuleID)
''                  ds.MoveNext
''               Loop
''               'LstBoxFrm.LstBox.ListIndex = key1&
''
''               LstBoxShow
''
''               key1& = -1
''               If LstBoxFrm.LstBox.ListIndex > -1 Then
''                     key1& = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
''                  End If
''               If LstBoxFrm.LstBox.Tag = "2" Then key1& = -2                                 '18Jul00 CKJ Print requested
''
''               Select Case key1&
''                  Case -1
''                     k.escd = True
''                  Case -2
''                     PrintlistBoxContents                                                    '18Jul00 CKJ Added print option
''                  Case Is >= 0
''                     SQLq = "SELECT * FROM rules WHERE RuleID=" & Str$(key1&) & ";"
''                     Title$ = "PN Rules Database"
''                     itemname$ = "Rule"
''                     TopField$ = "Description"
''                     If SQLdbg Then popmessagecr "SQL", SQLq
''
''                     GoSub ProcessList
''                     k.escd = False
''                  End Select
''               Unload LstBoxFrm
''            Loop Until k.escd
''            popmenu 0, "", 0, 0                                                              '18Jul00 CKJ Added
''            ds.Close
''            Set ds = Nothing
''            db.Close
''            Set db = Nothing
''
''         Case "201", "202", "203", "204", "205", "206", "207", "208", "209", "210", "211", "212"
''            Select Case Val(ans1$) - 200
''               Case 1:  filename$ = "TPN-PWS"
''               Case 2:  filename$ = "TPN-AWS"
''               Case 3:  filename$ = "TPN-BWS"
''               Case 4:  filename$ = "TPN-PSC"
''               Case 5:  filename$ = "TPN-ASC"
''               Case 6:  filename$ = "TPN-PNO"
''               Case 7:  filename$ = "TPN-ANO"
''               Case 8:  filename$ = "TPN-INV"
''               Case 9:  filename$ = "TPN-DEL"
''               Case 10: filename$ = "TPN-DBP"
''               Case 11: filename$ = "TPN-INVB"      ' 2Jul97 CKJ Added
''               Case 12: filename$ = "TPN-WSTB"      '12Jul98 CKJ Added
''               End Select
''            GetTextFile dispdata$ & "\" & filename$ & ".rtf", txt$, dummy%
''            txtwas$ = txt$
''            HighEdit.HelpContextID = 5120
''            'Hedit 1, txt$                          'view and edit it
''            Hedit Iff(ViewOnly, 0, 1), txt$         'view and edit it '18Jul00 CKJ Added view only option
''
''            If txt$ <> txtwas$ Then
''                  PutTextFile dispdata$ & "\" & filename$ & ".rtf", txt$, dummy%
''                  sLogText = "Edited layout file " & filename$                       '05Jun00 CKJ added !!** keep copy?
''                  WriteLog dispdata$ & "\PNedit.log", 0, UserID$, sLogText           '   "
''               End If
''
''         Case "501", "502", "503", "504"                '11Jul98 CKJ replaced .dat with .rtf
''            Select Case ans1$
''               Case "501": filename$ = "TPN-LBLA"
''               Case "502": filename$ = "TPN-LBLL"
''               Case "503": filename$ = "TPN-LBLB"
''               Case "504": filename$ = "TPN-LBLS"       '11Jul99 CKJ Added Syringe layout for labels
''               End Select
''            'GetTextFile dispdata$ & "\" & filename$ & ".dat", txt$, dummy%
''            'change = True
''            'TextEdit "PN Label Editor", txt$, "", change, True
''            'If change Then
''            '      PutTextFile dispdata$ & "\" & filename$ & ".dat", txt$, dummy%
''            '   End If
''            GetTextFile dispdata$ & "\" & filename$ & ".rtf", txt$, dummy%
''            txtwas$ = txt$
''            HighEdit.HelpContextID = 5120
''            'Hedit 1, txt$                          'view and edit it
''            Hedit Iff(ViewOnly, 0, 1), txt$         'view and edit it '18Jul00 CKJ Added view only option
''
''            If txt$ <> txtwas$ Then
''                  PutTextFile dispdata$ & "\" & filename$ & ".rtf", txt$, dummy%
''                  sLogText = "Edited layout file " & filename$                       '05Jun00 CKJ added !!** keep copy?
''                  WriteLog dispdata$ & "\PNedit.log", 0, UserID$, sLogText           '   "
''               End If
''
''         Case "301": SetTPNDefaults 0               'paed defaults
''         Case "302": SetTPNDefaults 1               'adult defaults
''         Case "401": Editors 6                      '16Jan97 CKJ/EAC added one to each option
''         Case "402": Editors 5
''         Case "403": Editors 7
''
''         Case "601", "602", "603"
''            Select Case ans1$
''               Case "601": filename$ = rootpath & "\TPNW.044"
''               Case "602": filename$ = dispdata$ & tpninifile$
''               Case "603": filename$ = dispdata$ & "\TPN.INI"
''               End Select
''            On Error Resume Next                   'need to set focus etc
''            dummy = Shell("notepad " & filename$, 3)
''            Screen.ActiveForm.Enabled = False
''            Do While GetModuleUsage(dummy) > 0
''               DoEvents
''            Loop
''            Screen.ActiveForm.Enabled = True
''            Screen.ActiveForm.SetFocus
''            On Error GoTo 0
''
''         Case "701", "702", "703", "704"
''            Select Case ans1$
''               Case "701"
''                  dbEd.Data1.DatabaseName = dispdata$ & "\tpnprds.mdb"
''                  dbEd.Data1.RecordSource = "PrdDat"
''               Case "702"
''                  dbEd.Data1.DatabaseName = dispdata$ & "\stdregs.mdb"
''                  dbEd.Data1.RecordSource = "StdReg"
''               Case "703"
''                  dbEd.Data1.DatabaseName = patdatapath$ & "\pattpn.mdb"
''                  dbEd.Data1.RecordSource = "PatRegDat"
''               Case "704"
''                  dbEd.Data1.DatabaseName = dispdata$ & "\stdregs.mdb"
''                  dbEd.Data1.RecordSource = "Rules"
''               End Select
''            dbEd.Data1.Refresh
''            dbEd.Table1.Tag = dbEd.Data1.DatabaseName
''            DoEvents
''            dbEd.Show 1
''            dbEd.Table1.Layout = ""
''            Unload dbEd
''            DoEvents
''            FreeLocks
''
''         End Select
''   Loop While ans1$ <> ""
''
''   'sLogText = "PN Supervisor Editor - Stopped on terminal " & ASCTerminalName$()         '05Jun00 CKJ added
''   sLogText = Iff(ViewOnly, "PN Configuration Viewer", "PN Supervisor Editor")            '18Jul00 CKJ modified
''   sLogText = sLogText & " - Stopped on terminal " & ASCTerminalName$()                   '   "
''
''   WriteLog dispdata$ & "\PNedit.log", 0, UserID$, sLogText                               '05Jun00 CKJ added
''
''Exit Sub
''
'''-----------------------------------------------------------------------------------------------
''ProcessList:
''   popmenu 0, "", 0, 0
''   popmenu 2, "&View or Edit Item[cr]&Print list", 0, 0
''   Do
''      Set ds = db.CreateDynaset(SQLq)
''      Unload LstBoxFrm
''
''      'k.helpnum = 0
''      LstBoxFrm.Caption = Title$
''      LstBoxFrm.lblTitle = cr & "  " & itemname$ & " '" & GetField(ds.Fields(TopField$)) & "'" & cr & "  Press Shift-F1 or click right mouse button for menu" & cr
''      LstBoxFrm.lblHead = "  Item" & Space$(15) & TB & " " & TB & "Value"
''
''      deflines dat$, lines$(), ",", 1, numoflines       'dat$ = "!editable,4#,5#,6#,!7#,noteditable"
''      For i = 1 To numoflines
''         tmp$ = lines$(i)
''         flag = False
''         If Left$(lines$(i), 1) = "!" Then
''               tmp$ = Mid$(tmp$, 2)
''               flag = True
''            End If
''         If MasterDebug Then flag = True                '11Jul98 CKJ WARNING: Now ONLY used for PrdDat
''         If Right$(lines$(i), 1) = "#" Then
''               'tmp$ = ds.Fields(Val(tmp$)).Name        '   "
''               tmp$ = tp("PrdDat" & Format(Val(tmp$)))  '   "
''            End If
''
''         If ViewOnly Then flag = False                  '18Jul00 CKJ Added view only option
''
''         If flag Then edflag$ = ">" Else edflag$ = ""
''         If InStr(1, tmp$, "PrdType", 1) = 1 Then
''               Select Case Right$(tmp$, 1)
''                  Case "1"
''                     LstBoxFrm.LstBox.AddItem "  PN product" & TB & edflag$ & TB & YesNo(GetField(ds!PrdType) And 1)
''                     LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = Iff(flag, 32761, -3)
''                  Case "2"
''                     LstBoxFrm.LstBox.AddItem "  Other Infusion product" & TB & edflag$ & TB & YesNo(GetField(ds!PrdType) And 2)
''                     LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = Iff(flag, 32762, -3)
''                  Case "4"
''                     LstBoxFrm.LstBox.AddItem "  Enteral product" & TB & edflag$ & TB & YesNo(GetField(ds!PrdType) And 4)
''                     LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = Iff(flag, 32764, -3)
''                  End Select
''            Else
''               If ds.Fields(tmp$).Type = 1 Then   'boolean
''                     If GetField(ds.Fields(tmp$)) Then Value$ = getYN(3) Else Value$ = getYN(4)
''                  Else
''                     Value$ = GetField(ds.Fields(tmp$))
''                  End If
''
''               tmp1$ = "  " & ds.Fields(tmp$).name            'Intentionally self-referential to read cAsE from the DB
''               plingparse tmp1$, "_"
''               LstBoxFrm.LstBox.AddItem tmp1$ & TB & edflag$ & TB & Value$
''               If flag Then
''                     LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = ds.Fields(tmp$).OrdinalPosition
''                  Else
''                     LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -3
''                  End If
''            End If
''      Next
''      If ans1$ = "103" Or ans1$ = "104" Then       'standard regimens      '04Jun98 CKJ Enhanced
''            Screen.MousePointer = HOURGLASS
''            ds1.MoveFirst
''            Do While Not ds1.EOF
''               tmp1$ = GetField(ds1!linkcode)      'scan each product in turn
''               tmp$ = "-"                          'assume volume is zero
''               If Trim$(tmp1$) <> "" Then
''                     For X = 1 To 25               'is it in the regimen already?
''                        If GetField(ds.Fields("LNK" & Format$(X))) = tmp1$ Then
''                              tmp$ = GetField(ds.Fields("PRD" & Format$(X))) & units$
''                              Exit For
''                           End If
''                     Next
''                  End If
''               tmp$ = "  " & tmp$ & TB & ">" & TB & tmp1$ & TB & GetField(ds1!PrdName)
''               LstBoxFrm.LstBox.AddItem tmp$
''               LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 32767
''               ds1.MoveNext
''            Loop
''            Screen.MousePointer = STDCURSOR
''         End If
''
''      Do
''         LstBoxShow
''         On Error Resume Next                          '18Jul00 CKJ needed to avoid 'cannot display non modal form' error
''         LstBoxFrm.Show 0
''         On Error GoTo 0                               '18Jul00 CKJ
''         LstBoxFrm.Enabled = False
''
''         key2& = -1
''         If LstBoxFrm.LstBox.ListIndex > -1 Then
''               key2& = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
''            End If
''         If LstBoxFrm.LstBox.Tag = "2" Then key2& = -2    'Print requested
''         Select Case key2&
''            Case -3       'non editable item chosen
''               msg$ = LstBoxFrm.LstBox.List(LstBoxFrm.LstBox.ListIndex)
''               replace msg$, TB, cr, 0
''               ParseCtrlChars dispdata$ & "\printer.ini", "Screen", msg$, Changed
''
''               popmessagecr itemname$ & ":  " & GetField(ds.Fields(TopField$)), msg$
''
''            Case -2       'print     '04Jun98 CKJ Replaced with new version using context
''               PrintlistBoxContents                                                       '18Jul00 CKJ moved to new proc
''
''               'RTFinternalTransfer$ = LstBoxFrm.lblTitle & "[cr][ulineon][boldon]" & LstBoxFrm.lblHead & "[boldoff][ulineoff][cr][cr]"
''               'For i = 1 To LstBoxFrm.LstBox.ListCount - 1
''               '   RTFinternalTransfer$ = RTFinternalTransfer$ & LstBoxFrm.LstBox.List(i) & "[cr]"
''               'Next
''               'replace RTFinternalTransfer$, cr, "[cr]", 0
''               'replace RTFinternalTransfer$, TB, "[Tab]", 0
''               'ParseCtrlChars dispdata$ & "\printer.ini", "RTF", RTFinternalTransfer$, Changed
''               'Heap 10, gPRNheapID, "internal", RTFinternalTransfer$, 0
''               ''Heap 100, gPRNheapID, "", "", 0
''               'ParseThenPrint "PNsheet", dispdata$ & "\tpn-DBP.rtf", 1, 0
''
''               'GetTextFile dispdata$ & "\tpn-DBP.rtf", txt$, dummy%
''               'Do
''               '   changed = False
''               '   ParseTPNDataItems txt$, changed
''               '   ParseCtrlChars dispdata$ + tpninifile$, "", txt$, changed
''               '   ParseCtrlChars dispdata$ & "\printer.ini", "RTF", txt$, changed
''               'Loop While changed
''               'HEdit 3, txt$       'print it
''               'ParseandPrint dispdata$ & "\tpn-DBP.rtf", 1
''
''            Case Is >= 0  'edit item
''               msg$ = itemname$ & ":  " & GetField(ds.Fields(TopField$))
''               sLogText = msg$ & ", "                                                                  '05Jun00 CKJ
''               If key2& = 32767 Then               '04Jun98 CKJ special - edit standard regimen
''                     change = False
''                     k.nums = True
''                     k.decimals = True
''                     k.Max = 5
''                     ans2$ = Format$(Val(LstBoxFrm.LstBox.List(LstBoxFrm.LstBox.ListIndex)))
''
''                     '05Jun00 CKJ Replaced block with lines below
''                     'msg$ = msg$ & cr & LstBoxFrm.LstBox.List(LstBoxFrm.LstBox.ListIndex) & cr & cr & "Enter volume required in" & units$
''                     'replace msg$, TB, "  ", 0
''                     'replace msg$, ">", "", 0
''                     tmp$ = LstBoxFrm.LstBox.List(LstBoxFrm.LstBox.ListIndex)       '  10ml tab > tab DESI000 Description'
''                     replace tmp$, TB, "  ", 0                                      '  10ml  >  DESI000 Description'
''                     replace tmp$, ">", "", 0                                       '  10ml     DESI000 Description'
''                     sLogText = sLogText & Trim$(tmp$)                              '10ml     DESI000 Description'
''                     msg$ = msg$ & cr & tmp$ & cr & cr & "Enter volume required in" & units$      '05Jun00 CKJ end of block
''
''                     ans3$ = ans2$
''                     inputwin Title$, msg$, ans2$, k
''                     If Not k.escd And ans2$ <> ans3$ Then
''                           tmp$ = LstBoxFrm.LstBox.List(LstBoxFrm.LstBox.ListIndex)
''                           tmp$ = ans2$ & Mid$(tmp$, InStr(tmp$, TB))   'replace new volume
''                           LstBoxFrm.LstBox.List(LstBoxFrm.LstBox.ListIndex) = tmp$
''
''                           BeginTrans
''                           ds.Edit
''                           For X = 1 To 25                      'blank all entries
''                              ds.Fields("LNK" & Format$(X)) = ""
''                              ds.Fields("PRD" & Format$(X)) = 0
''                           Next
''                           numoflines = 0
''                           For X = 0 To LstBoxFrm.LstBox.ListCount - 1
''                              If LstBoxFrm.LstBox.ItemData(X) = 32767 Then
''                                    deflines (LstBoxFrm.LstBox.List(X)), lines$(), TB, 1, 0
''                                    If Val(lines$(1)) Then        'volume is not zero
''                                          numoflines = numoflines + 1
''                                          If numoflines > 25 Then Exit For       '<== QUIT
''                                          ds.Fields("LNK" & Format$(numoflines)) = lines$(3)
''                                          ds.Fields("PRD" & Format$(numoflines)) = Format$(Val(lines$(1)))
''                                       End If
''                                 End If
''                           Next
''                           If numoflines > 25 Then
''                                 Rollback
''                                 popmessagecr "!", "Maximum of 25 products allowed in a standard regimen" & cr & "Change requested has not been performed."
''                              Else
''                                 ds!LastModDate = Now
''                                 ds!LastModUser = UserID$
''                                 ds!LastModTerm = ASCTerminalName$()             '13Aug98 CKJ was "Unknown"
''                                 ds.Update
''                                 CommitTrans
''                                 sLogText = sLogText & ": " & ans3$ & " => " & ans2$                        '05Jun00 CKJ
''                                 WriteLog dispdata$ & "\PNedit.log", 0, UserID$, sLogText                   '   "
''                              End If
''                        End If
''
''                  ElseIf key2& >= 32761 And key2& <= 32764 Then     'special handler for PrdType#
''                     '05Jun00 CKJ replaced block with lines below, to extract description from listbox line
''                     'msg$ = msg$ & cr & "Select whether item is of type:" & LstBoxFrm.LstBox.List(LstBoxFrm.LstBox.ListIndex)
''                     'replace msg$, TB, nul, 0         'make first Tab an ascii zero
''                     'msg$ = asciiz(msg$)              'and trim beyond the null char
''                     tmp$ = LstBoxFrm.LstBox.List(LstBoxFrm.LstBox.ListIndex)             '   description tab > tab Yes  '
''                     replace tmp$, TB, Nul, 0         'make first Tab an ascii zero       '   description#>#Yes  '
''                     tmp$ = asciiz(tmp$)              'and trim beyond the null char      '   description'
''                     msg$ = msg$ & cr & "Select whether item is of type:" & tmp$
''                     sLogText = sLogText & Trim$(tmp$)                                    '05Jun00 end of edited block
''
''                     ans2$ = getYN(Iff(GetField(ds.Fields("PrdType")) And (key2& Mod 10), 1, 2))   'yes/no
''                     ans3$ = ans2$
''                     change = False
''                     askwin Title$, msg$, ans2$, k
''                     If Not k.escd And ans3$ <> ans2$ Then
''                           ds.Edit
''                           ds.Fields("PrdType") = GetField(ds.Fields("PrdType")) Xor (key2& Mod 10)   'flip appropriate bit
''                           ds!LastModDate = Now
''                           ds!LastModUser = UserID$
''                           ds!LastModTerm = ASCTerminalName$()                   '13Aug98 CKJ was "Unknown"
''                           ds.Update
''                           sLogText = sLogText & ": " & ans3$ & " => " & ans2$                       '05Jun00 CKJ
''                           WriteLog dispdata$ & "\PNedit.log", 0, UserID$, sLogText                  '   "
''                        End If
''
''                  ElseIf ds.Fields(key2&).Type = 1 Then   'boolean
''                     msg$ = msg$ & cr & "Select whether item is " & (ds.Fields(key2&).name)
''                     If GetField(ds.Fields(key2&)) Then ans2$ = getYN(1) Else ans2$ = getYN(2)
''                     ans3$ = ans2$
''                     change = False
''                     askwin Title$, msg$, ans2$, k
''                     sLogText = sLogText & (ds.Fields(key2&).name) & ": " & ans3$ & " => " & ans2$   '05Jun00 CKJ
''                     If Not k.escd Then
''                           ans2$ = Format$(ans2$ = "Y")
''                           change = True
''                        End If
''                  Else
''                     fullpage = False
''
''                     'Select Case ds.Fields(key2&).Type              '05Jun00 CKJ removed block, see below
''                     '   Case 2 To 4   'byte integer long
''                     '      k.nums = True
''                     '   Case 5 To 7   'currency single double
''                     '      k.nums = True
''                     '      k.decimals = True
''                     '   Case 8        'date
''                     '   Case 10       'text
''                     '      k.max = ds.Fields(key2&).Size
''                     '      If k.max > 78 Then fullpage = True
''                     '      special = 0
''                     '   Case 11, 12   'longbinary memo
''                     '      fullpage = True
''                     '   End Select
''
''                     '----------
''                     k.Max = 0                                       '05Jun00 CKJ Added specific sizes for each field
''                     Select Case ds.Fields(key2&).Type
''                        Case 2        'byte
''                           k.nums = True
''                           k.Max = 3
''                        Case 3        'integer
''                           k.nums = True
''                           k.Max = 6
''                        Case 4        'long
''                           k.nums = True
''                           k.Max = 11
''                        Case 5        'currency
''                           k.nums = True
''                           k.decimals = True
''                           k.Max = 21
''                        Case 6        'single
''                           k.nums = True
''                           k.decimals = True
''                           k.Max = 13
''                        Case 7        'double
''                           k.nums = True
''                           k.decimals = True
''                           k.Max = 22
''                        Case 8        'date
''                           k.Max = 10
''                        Case 10       'text
''                           k.Max = ds.Fields(key2&).Size
''                           If k.Max > 78 Then
''                                 fullpage = True
''                                 k.Max = 0
''                              End If
''                           special = 0
''                        Case 11, 12   'longbinary memo
''                           fullpage = True
''                        End Select
''                     '----------
''
''                     ans2$ = GetField(ds.Fields(key2&))
''                     If fullpage Then
''                           change = True
''                           k.escd = False
''                           ans3$ = ans2$                                                                   '05Jun00 CKJ
''                           ParseCtrlChars dispdata$ & "\printer.ini", "Screen", ans2$, Changed   '[CR][Cr][cr] etc to ASCII 13
''                           replace ans2$, cr, "[cr]", 0                                          'ASCII 13 to only lower case [cr]
''                           replace ans2$, "[cr]", crlf, 0                                        '[cr] to ASCII 13, 10
''                           TextEdit Title$, ans2$, msg$, change, True
''                           replace ans2$, crlf, "[cr]", 0                                        'ASCII 13, 10 to [cr]
''                           sLogText = sLogText & (ds.Fields(key2&).name) & ": " & ans3$ & " => " & ans2$   '05Jun00 CKJ
''                        Else
''                           Select Case special
''                              Case 0
''                                 change = False
''                                 msg$ = msg$ & cr & "Change setting for " & (ds.Fields(key2&).name)
''                                 ans3$ = ans2$
''                                 inputwin Title$, msg$, ans2$, k
''                                 If ans2$ <> ans3$ Then change = True
''                                 sLogText = sLogText & (ds.Fields(key2&).name) & ": " & ans3$ & " => " & ans2$   '05Jun00 CKJ
''                              Case 1
''                                 'none yet
''                              End Select
''                        End If
''                  End If
''               If Not k.escd And change Then               'save change
''                     iErr = 0                                                    '05Jun00 CKJ Added
''                     ds.Edit
''                     On Error GoTo ViewDB_Err                                    '05Jun00 CKJ Added
''                     ds.Fields(key2&) = ans2$
''                     ds!LastModDate = Now
''                     ds!LastModUser = UserID$
''                     ds!LastModTerm = ASCTerminalName$()                         '13Aug98 CKJ was "Unknown"
''ViewDB_Resume:                                                                                             '05Jun00 CKJ Added
''                     ds.Update
''                     On Error GoTo 0                                                                       '05Jun00 CKJ Added
''                     If iErr Then                                                                          '   "
''                           popmessagecr ".", "Not updated: " & crlf & sErr & " (Error" & Str$(iErr) & ")"  '   "
''                           iErr = 0                                                                        '   "
''                           sLogText = sLogText & "Not updated: " & sErr & " (Error" & Str$(iErr) & ")"     '   "
''                        End If                                                                             '   "
''                     WriteLog dispdata$ & "\PNedit.log", 0, UserID$, sLogText                              '   "
''                  End If
''            End Select
''         LstBoxFrm.Enabled = True
''         LstBoxFrm.Hide
''      Loop While key2& = -3
''   Loop While LstBoxFrm.LstBox.ListIndex <> -1
''   popmenu 0, "", 0, 0
''
''Return
''
''ViewDB_Err:                                                                      '05Jun00 CKJ Added block
''   sErr = Error$
''   iErr = Err
''Resume ViewDB_Resume

End Sub

Sub volentry(LN, stage)
''Dim u$, v$, answer!, s$, ans$
''
''   v$ = tp("ig" & Format$(IgVol))              'volume
''   u$ = tp("Udes" & tp("IgU" & Format$(IgVol))) 'units description
''
''   If weight! = 0 Then stage = 1
''
''   If stage = 0 Then         ' ask total or per kilo
''         'k.helpnum = 0
''         LstBoxFrm.Caption = tp("Enter") & v$ & " of " & Prd(LN).name
''         LstBoxFrm.lblTitle = cr & "Select entry of " & Prd(LN).name & " by ml or by ml per Kg" & cr
''         LstBoxFrm.LstBox.AddItem " Enter as total " & u$
''         LstBoxFrm.LstBox.AddItem " Enter as " & u$ & "/kg"
''         LstBoxFrm.LstBox.ListIndex = Iff(adult(pid.sex), 0, 1)          '24Sep98 CKJ Added
''         LstBoxShow
''         stage = LstBoxFrm.LstBox.ListIndex + 1
''         Unload LstBoxFrm
''      End If
''
''   If stage > 0 Then
''         If stage = 1 Then
''               answer! = ig(LN)
''               s$ = "Enter volume required of " & Prd(LN).name & " in mls"
''            Else
''               answer! = ig(LN) / weight!
''               s$ = "Enter volume required of " & Prd(LN).name & " as mls/Kg"
''            End If
''
''         threesigfigs answer!
''         ans$ = Trim$(tsf$(answer!))
''         k.Max = 4
''         k.min = 1
''         k.nums = True
''         k.decimals = True
''         'k.helpnum = 290
''         inputwin Prd(LN).name, s$, ans$, k
''         If Not k.escd Then
''               RememberK
''               RememberNa
''               ig(LN) = Val(ans$)
''               If stage = 2 Then
''                     ig(LN) = ig(LN) * weight!
''                  End If
''               ModIg(0) = LN
''               AskAdjustNa LN
''               AskAdjustK LN
''               TPNchanged = True
''               AdjPrint
''            End If
''      End If

End Sub

Sub volume(stage%)
'''Recalculate volume;
''' Stage 0 - show total & per kilo & ask which to use
''' Stage 1 - enter by total vol
''' Stage 2 - enter by ml/kg
'''15Nov99 CKJ replaced IgMax with IgMaxIncNonDisp
''
''Dim totap!, totg!, totginall!, totmlg!, X%, Y%, numip%, s$, ansv!, ans$, goodvol%, volof!, newcals!
''
''   '--Calculate volume of glucose---
''   totap! = 0
''   totg! = 0
''   totginall! = 0
''   totmlg! = 0
''   For X = 0 To NP - 1
''      numip = 0
''      'For Y = 2 To IgMax            '@@  13   'OK; was 10  '15Nov99 CKJ removed
''      For Y = 2 To IgMaxIncNonDisp   '@@  13   'OK; was 10  '15Nov99 CKJ was IgMax
''         If prod!(X, Y) > 0 Then numip = numip + 1
''      Next
''      If prod!(X, 3) > 0 And numip = 1 Then
''            totg! = totg! + (prod!(X, 3) * ig(X)) / prod!(X, 0)
''            totmlg! = totmlg! + ig(X)
''         End If
''      If prod!(X, 0) > 0 Then
''            totginall! = totginall! + ((prod!(X, 3) * ig(X)) / prod!(X, 0))
''         End If
''   Next
''
''   If weight! = 0 Then stage = 1
''
''   If stage = 0 Then
''         LstBoxFrm.Caption = "Adjust Volume"
''         LstBoxFrm.lblTitle = cr & "Enter volume as total ml or as ml per kg" & cr
''         LstBoxFrm.LstBox.AddItem " Total volume of feed  = " & tsfvdu(tot!(0)) & " ml"
''         LstBoxFrm.LstBox.AddItem " Volume in ml per kg   = " & tsfvdu(tot!(0) / weight!) & " ml/kg"
''         LstBoxFrm.LstBox.ListIndex = Iff(adult(pid.sex), 0, 1)          '24Sep98 CKJ Added
''         LstBoxShow
''         stage = LstBoxFrm.LstBox.ListIndex + 1
''         Unload LstBoxFrm
''      End If
''
''   If stage > 0 Then
''         s$ = "Total volume of feed  = " & tsfvdu(tot!(0)) & " ml" & cr
''         If weight! > 0 Then s$ = s$ + " Volume in ml per kg   = " & tsfvdu(tot!(0) / weight!) & " ml/kg" & cr & cr
''         If stage = 1 Then
''               s$ = s$ + "Enter total volume required"
''            Else
''               s$ = s$ + "Enter volume per kg required"
''            End If
''         Do
''            If stage = 1 Then ansv! = tot!(0) Else ansv! = tot!(0) / weight!
''            threesigfigs ansv!
''            ans$ = LTrim$(Str$(ansv!))
''            If ans$ = "0" Then ans$ = ""
''            k.decimals = 1
''            k.Max = 4
''            k.min = 1
''            'k.helpnum = 500
''            inputwin "Adjust Volume", s$, ans$, k
''
''            If Not k.escd Then
''                  volumecheck goodvol
''                  If goodvol Then
''                        If stage = 1 Then volof! = Val(ans$) Else volof! = Val(ans$) * weight!
''                     End If
''               End If
''         Loop Until goodvol Or k.escd
''         If Not k.escd Then
''               mixglucose volof!, newcals!      '!!** newcals is always 0 here
''            End If
''      End If
''
''   k.escd = False

End Sub

Sub volumecheck(goodvol)
'''--checks requested volume--
'''15Nov99 CKJ replaced IgMax with IgMaxIncNonDisp
''
'''!!** what does this do and when would it fire?
''
''Dim totap!, totg!, totginall!, totmlg!, X%, Y%, numip%, s$
''
''   goodvol = True
''
''   totap! = 0
''   totg! = 0
''   totginall! = 0
''   totmlg! = 0
''   'diffing! = 0   not used
''   For X = 0 To NP - 1
''      'totap! = totap! + ig(x) same as tot!(0) I think ??!!ASC       !!**
''      numip = 0
''      'For Y = 2 To IgMax            '@@  10   '!!** 10?  '15Nov99 CKJ removed
''      For Y = 2 To IgMaxIncNonDisp   '@@  10   '!!** 10?  '15Nov99 CKJ was IgMax
''         If prod!(X, Y) > 0 Then numip = numip + 1
''      Next
''      If prod!(X, 3) > 0 And numip = 1 Then
''            totg! = totg! + (prod!(X, 3) * ig(X)) / prod!(X, 0)
''            totmlg! = totmlg! + ig(X)
''         End If
''      If prod!(X, 0) > 0 Then
''            totginall! = totginall! + ((prod!(X, 3) * ig(X)) / prod!(X, 0))
''         End If
''   Next
''
''   'diffing! = totginall! - totg!   not used
''   If totap! - totmlg! > tot!(0) Then
''         s$ = "Volume of ingredients is " & Format$((totap! - totmlg!), "####.#") & cr
''         s$ = s$ & "mls and is greater than the final volume requested."
''         popmessagecr "Warning", s$
''         goodvol = False
''      End If

End Sub

Sub warningsvdu(Warnings$, Critical%)
'''-----------------------------------------------------------------------------
'''            Prints warnings about electrolyte concentrations to screen
''' 6Oct91 CKJ all warnings in one box
'''  Aug96 CKJ Old style warnings now in SQL database
'''            Now proc only contains maxdose calcs
'''24Sep98 CKJ Added block to check if product can be used in adult/paed
''
''Dim negvols%, X%, MaxDose!
''
''   For X = 0 To NP - 1
''      If ig(X) < 0 Then
''            negvols = True
''            warnings$ = warnings$ & "Volume of " & Prd(X).name & " is negative" & cr
''         End If
''
''      If ig(X) > 0 And Not ForAPuse(X) Then                              '24Sep98 CKJ Added block
''            warnings$ = warnings$ & Prd(X).name & " is not for " & Iff(adult(pid.sex), "adult", "paediatric") & " use" & cr
''            Critical = True
''         End If
''
''      MaxDose! = Prd(X).maxmltotal
''      If MaxDose! > 0 And ig(X) > MaxDose! Then
''            warnings$ = warnings$ & Prd(X).name & ": max dose of " & Format$(MaxDose!) & " ml exceeded" & cr
''         End If
''
''      MaxDose! = Prd(X).maxmlperkg
''      If MaxDose! > 0 And weight! > 0 Then
''            If ig(X) / weight! > MaxDose! Then
''                  warnings$ = warnings$ & Prd(X).name & ": max dose of " & Format$(MaxDose!) & " ml per kg exceeded" & cr
''               End If
''         End If
''   Next
''
''   If negvols Then
''         warnings$ = warnings$ & cr & "Cannot Authorise while negative volumes are present" & cr & cr
''         Critical% = True
''      End If
''   If Len(warnings$) Then warnings$ = warnings$ & cr

End Sub

Sub AddAProduct(stage%, PIE%)
'''24Oct96 CKJ Added Stage - allows selection of product then straight to
'''            mls (Stage=1) or ml/kg (Stage=2) of product
'''            Stage=0 asks all questions in normal way
''' 8Apr98 CKJ Added PIE; 1 PN 2 Inf 3 Enteral
'''            Only offers entry by volume for types 2 & 3
'''24Sep98 CKJ Added check for paed/adult use
''
''Dim X%, mls$, LN%, valid%
''
''   If TableFull() Then Exit Sub
''
''   If PIE < 1 Or PIE > 3 Then Exit Sub
''
''   Screen.MousePointer = HOURGLASS
''   LstBoxFrm.Caption = "All " & Choose(PIE, "PN", "other Infusion", "Enteral") & " Products"
''   LstBoxFrm.lblTitle = cr & "Select product to add or amend" & cr
''   LstBoxFrm.lblHead = "  Product" & Space$(23) & TB & " Volume      " '@~@~ & Iff(PIE = 1, TB & "Part", "")
''   'For x = 0 To NP - 1
''   For X = FirstPrd(PIE) To LastPrd(PIE)
''      mls$ = ""
''      If ig(X) > 0 Then mls$ = tsf(ig(X)) + " " + tp("ml")
''      If ig(X) > 0 Or ForAPuse(X) Then                                         '24Sep98 CKJ Added
''            LstBoxFrm.LstBox.AddItem "  " & Prd(X).name & TB & mls$ '@~@~ & Iff(PIE = 1, TB & prd(x).solnAB, "")
''            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = X
''         End If
''   Next
''   Screen.MousePointer = STDCURSOR
''   LstBoxShow
''   'LN = LstBoxFrm.LstBox.listindex
''   valid = False
''   If LstBoxFrm.LstBox.ListIndex > -1 Then
''         LN = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
''         valid = True
''      End If
''   Unload LstBoxFrm
''
''   'If LN >= 0 Then
''   If valid Then
''         If stage = 0 And PIE = 1 Then   'entry method not specified and PN product
''               SelectIg LN
''            Else
''               volentry LN, stage
''            End If
''      End If

End Sub

Sub AdjPrint()
'''--show screen display--
'''05Jun00 CKJ Indicate lipid items on screen if separate bags are used & screen is greater than 640x480
'''            Default is [description] for lipid items, but changeable usinh TPN.INI LipidPrefix and
'''            LipidSuffix where value is the ASCII character number.
'''
'''18Jul00 CKJ Added batch mode changes. Screen now has two modes...
'''             Screen layout:                 Patient                                             Batch
'''
'''             Row 1                         Title line                                         Title line
'''             Row 2                        first product                                      first product
'''             Row 3                        second product                                     second product
'''             Row 4       RowsUsed         third product                     RowsUsed         third product
'''             Row 5       RowsUsed+1          total                          RowsUsed+1          total
'''             Row 6       RowsUsed+2          total/kg
'''             Row 7       EnteralRow       custom enterals
'''             Row 8       EnteralRow+1     first std enteral
'''             Row 9       InfusionRow      custom infusions
'''             Row 10      InfusionRow+1    first std infusion
'''             Row 11      GrandTotrow         grand total
'''             Row 12      GrandTotrow+1       grand total/kg
'''             Row 13      ScriptRow        Prescription/kg
''
''
''Dim tmp$, Row%, X%, Y%, Z%, ModChar$, item!, stage%
''Dim sLipidPrefix As String, sLipidSuffix As String                                             '05Jun00 CKJ added
''
''   ReDim VAxy(IgMax + 3, 100) As String   '28Mar98 CKJ was 25 lines max
''
''   sLipidPrefix = Chr$(Val(TxtD(dispdata$ & "\TPN.INI", "", "91", "LipidPrefix", 0)) Mod 256)  '05Jun00 CKJ '['
''   sLipidSuffix = Chr$(Val(TxtD(dispdata$ & "\TPN.INI", "", "93", "LipidSuffix", 0)) Mod 256)  '   "        ']'
''
''   'frmVA.mnuIssue.Enabled = False        'allow only if full system  - see LX
''
''   frmVA.cmdVA(0).Caption = "&Clinical Details"
''   frmVA.cmdVA(1).Caption = "&Prescription"
''   frmVA.cmdVA(2).Caption = "&Standard Regimen"
''   frmVA.cmdVA(3).Caption = "&Regimen Details"
''   frmVA.cmdVA(4).Caption = "&Authorise"
''   frmVA.cmdVA(5).Caption = "&Print"
''   frmVA.cmdVA(6).Caption = "E&xit"           '05Jun00 CKJ
''
''   'clear existing rules
''   frmVA.tgdVA.HasRegexAttr = False
''
'''  TgSetCurCellColor frmVA.tgdVA, QBColor(1), QBColor(15)
''   TgSetNegativeColColor frmVA.tgdVA, 2, QBColor(15), QBColor(4)
''
''   Row = 0
''   stage = 1
''   GoSub DoRows
''
''   RowsUsed = Row
''   frmVA.tgdVA.SelectMode = 1        'maybe 0 is OK
''   frmVA.tgdVA.SelectZoneWidth = 0   'default is 6
''   frmVA.tgdVA.SelectedBackColor = QBColor(7)
''   frmVA.tgdVA.SelectedForeColor = QBColor(0)
''
''   calctotals ""
''   Row = Row + 1
''   VAxy(1, Row) = Space$(20) & "PN Total"
''   For X = 0 To IgMax
''      VAxy(X + 2, Row) = tsf(tot!(X))
''   Next
''
''   If weight! > 0 Then
''         Row = Row + 1
''         VAxy(1, Row) = Space$(20) & "PN Total/kg"
''         For X = 0 To IgMax
''            VAxy(X + 2, Row) = tsf(tot!(X) / weight!)
''         Next
''         VAxy(IgMax + 3, Row - 1) = tsf(tot!(0) / weight!)
''         VAxy(IgMax + 3, Row) = tsf(tot!(0) / weight!)
''      End If
''
''   If iBatchMode Then                                                               '18Jul00 CKJ Batch mode
''         EnteralRow = RowsUsed + 1                                                  '   "        dummy value
''         InfusionRow = RowsUsed + 1                                                 '   "          "     "
''         GrandTotRow = RowsUsed + 2                                                 '   "          "     "
''         ScriptRow = 0                                                              '   "        no script
''      Else                                                                          '   "
''         '25Mar98 CKJ added enteral and concurrent products here
''         Row = RowsUsed + 3        'leaves a blank row if no weight - is this OK?
''         EnteralRow = Row
''         VAxy(1, Row) = Space$(20) & "Enteral Feeds"
''         For X = 0 To IgMax
''            VAxy(X + 2, Row) = tsf(ManualIE(3, X))
''         Next
''         If weight! > 0 Then VAxy(IgMax + 3, Row) = tsf(ManualIE(3, 0) / weight!)
''         stage = 3
''         GoSub DoRows
''
''         Row = Row + 1
''         InfusionRow = Row
''         VAxy(1, Row) = Space$(20) & "Other Infusions"
''         For X = 0 To IgMax
''            VAxy(X + 2, Row) = tsf(ManualIE(2, X))
''         Next
''         If weight! > 0 Then VAxy(IgMax + 3, Row) = tsf(ManualIE(2, 0) / weight!)
''         stage = 2
''         GoSub DoRows
''
''         Row = Row + 1
''         GrandTotRow = Row
''         VAxy(1, Row) = Space$(20) & "Grand Total"
''         For X = 0 To IgMax
''             item! = tot!(X)
''             For Y = FirstPrd(3) To LastPrd(2)
''                item! = item! + prod!(Y, X) * (ig!(Y) / prod!(Y, IgVol))
''             Next
''             VAxy(X + 2, Row) = tsf(item! + ManualIE(2, X) + ManualIE(3, X))       'add enteral & infusions here
''          Next
''
''         If weight! > 0 Then
''               Row = Row + 1
''               VAxy(1, Row) = Space$(20) & "Grand Total/kg"
''               For X = 0 To IgMax
''                  VAxy(X + 2, Row) = tsf(Val(VAxy(X + 2, Row - 1)) / weight!)
''               Next
''               VAxy(IgMax + 3, Row - 1) = VAxy(2, Row)     'ml/kg on line above
''               VAxy(IgMax + 3, Row) = VAxy(2, Row)         'ml/kg on this line
''            End If
''
''         'RowsUsed = Row    ' needs setting to last line used
''         '----
''
''         ScriptRow = 0
''         If GetField(patds!prescribed) Then
''               Row = Row + 1
''               ScriptRow = Row
''               For X = 0 To IgMax + 2
''                  VAxy(X, ScriptRow) = ""
''               Next
''               VAxy(1, ScriptRow) = " Prescription /kg " & GetField(patds!PrescModDate) '!!** Need total for adult?
''               VAxy(2, ScriptRow) = tsf$(GetField(patds!ScriptVol))
''               VAxy(3, ScriptRow) = "-----"
''               VAxy(4, ScriptRow) = tsf$(GetField(patds!ScriptN))
''               VAxy(5, ScriptRow) = tsf$(GetField(patds!ScriptGlu))
''               VAxy(6, ScriptRow) = tsf$(GetField(patds!ScriptFat))
''               VAxy(7, ScriptRow) = tsf$(GetField(patds!ScriptNa))
''               VAxy(8, ScriptRow) = tsf$(GetField(patds!ScriptK))
''               VAxy(9, ScriptRow) = tsf$(GetField(patds!ScriptCa))
''               VAxy(10, ScriptRow) = tsf$(GetField(patds!ScriptMg))
''               VAxy(11, ScriptRow) = tsf$(GetField(patds!ScriptZn))
''               VAxy(12, ScriptRow) = tsf$(GetField(patds!ScriptPO4))
''               VAxy(13, ScriptRow) = "-----"
''               VAxy(14, ScriptRow) = "-----"
''               VAxy(15, ScriptRow) = tsf$(GetField(patds!ScriptSe))
''               VAxy(16, ScriptRow) = tsf$(GetField(patds!ScriptCu))
''               VAxy(17, ScriptRow) = tsf$(GetField(patds!ScriptFe))    '26Mar98 CKJ
''               'VAxy(17, ScriptRow) = "-----"                          '   "
''               VAxy(18, ScriptRow) = "-----"                           '12Mar98 CKJ Added
''               'VAxy(17, ScriptRow) = GetField(patds!ScriptAVit)        can't show
''               'VAxy(18, ScriptRow) = GetField(patds!ScriptLVit)         "
''               'VAxy(3, ScriptRow) = GetField(patds!ScriptCalories)     not on script
''               'VAxy(13, ScriptRow) = GetField(patds!ScriptChloride)     "
''               'VAxy(14, ScriptRow) = GetField(patds!ScriptAcetate)      "
''            End If
''      End If
''
''   RegStatus
''
''   k.escd = False
''
''   frmVA.tgdVA.Rows = Row
''   frmVA.tgdVA.Refresh
''
''Exit Sub
''
''DoRows:
''   For Y = FirstPrd(stage) To LastPrd(stage)  'originally 0 To NP - 1
''      If ig(Y) Then
''            Row = Row + 1
''            ModChar$ = " "
''            For Z = 0 To 3
''               'If y = ModIg(z) Then ModChar$ = Chr$(149)   '14Aug98 CKJ Configurable 'blob' mark
''               If Y = ModIg(Z) Then ModChar$ = Chr$(Val(TxtD(dispdata$ & "\TPN.INI", "", "149", "ModifiedIndicator", 0)) Mod 256)
''            Next
''            VAxy(0, Row) = Str$(Y)
''
''            'tmp$ = RTrim$(ModChar$ & Prd(Y).name)                                        '05Jun00 CKJ amended
''            tmp$ = RTrim$(Prd(Y).name)                                                    '   "
''            If displaysize >= 2 Then                                                      '   "        Indicate lipid items
''                  If Prd(Y).SolnAB = "B" And Not lblscombined Then                        '   "        if screen >= 600x800
''                        tmp$ = sLipidPrefix & tmp$ & sLipidSuffix                         '   "        as [description]
''                     End If                                                               '   "
''               End If                                                                     '   "
''            tmp$ = RTrim$(ModChar$ & tmp$)                                                '   "
''
''            If displaysize < 2 Then replace tmp$, " ", "", 29
''
''            VAxy(1, Row) = tmp$
''            VAxy(2, Row) = tsfvdu(ig!(Y))
''            For X = 1 To IgMax
''               VAxy(X + 2, Row) = tsfvdu(prod!(Y, X) * (ig!(Y) / prod!(Y, IgVol)))
''            Next
''            If weight! Then VAxy(IgMax + 3, Row) = tsfvdu(ig!(Y) / weight!)
''         End If
''   Next
''Return

End Sub


Function txt(pathfile$, Section$, Entry$) As String
'19Dec94 CKJ Main code moved to TxtD. Proc functionally unchanged.
'19Jan95 CKJ file$ -> pathfile$ in default string
'17Jan12 TH Moved from old v8 corelib PORT
Dim found%

   txt$ = TxtD$(pathfile$, Section$, "TEXT " & Section$ & " " & Entry$ & " MISSING FROM " & pathfile$, Entry$, found)

End Function

Function adult%(sex$)
'-----------------------------------------------------------------------------
'            ADULT = TRUE IF sex$ IN UPPERCASE OR FALSE IN LOWERCASE
'
'11Nov91 CKJ Added U for unknown
'17Jan12 TH PORTED more as a stub than anything
'-----------------------------------------------------------------------------

''popmessagecr "", "Adult check being called - need new equivalent"
''   Select Case sex$
''      Case "m", "f", "b", "u"
''         adult% = False
''      Case Else
''         adult% = True
''      End Select
      
     adult% = m_blnAdult

End Function
Public Sub PNLoadProducts(ByVal lngRegimenRequestID As Long)
'Public Sub PNLoadProducts(ByVal lngSupplyRequestID As Long)
'20Jan12 TH This routine loads regime data into the various old arrays and types
'11Sep14 XN 88799 Added printing of prescription from regimen

Dim strParams As String
Dim rsPNProds As ADODB.Recordset

   'strParams = gTransport.CreateInputParameterXML("PNSupplyRequestID", trnDataTypeint, 4, lngSupplyRequestID)   11Sep14 XN 88799 Added printing of prescription from regimen
   'Set rsPNProds = gTransport.ExecuteSelectSP(g_SessionID, "pRegimenProductVolumeforPharmacybyPNSupplyRequestID", strParams)

   strParams = gTransport.CreateInputParameterXML("PNRegimenRequestID", trnDataTypeint, 4, lngRegimenRequestID)
   Set rsPNProds = gTransport.ExecuteSelectSP(g_SessionID, "pRegimenProductVolumeforPharmacybyPNRegimenRequestID", strParams)
   
   NP = 0
   ReDim Prd(NP)
   ReDim ig(NP)
   ReDim igover(NP)
      
      
   If Not rsPNProds.EOF Then
      rsPNProds.MoveFirst
      'Loop through and build our array
      Do While Not rsPNProds.EOF
      
      'OK here we basically need to fill out all our standard PN variables for Issuing/Printing
      ReDim Preserve Prd(NP)
      ReDim Preserve ig(NP)
      ReDim Preserve igover(NP)
      'No load the stuff
      Prd(NP).BaxaMMig = RtrimGetField(rsPNProds!BaxaMMig)
      Prd(NP).cost = 0 'deprecated ?
      Prd(NP).ForAdult = RtrimGetField(rsPNProds!ForAdult)
      Prd(NP).ForPaed = RtrimGetField(rsPNProds!ForPaed)
      Prd(NP).gH2Operml = RtrimGetField(rsPNProds!ForPaed)
      Prd(NP).id = RtrimGetField(rsPNProds!SortIndex) '????
      Prd(NP).Info = RtrimGetField(rsPNProds!Description)
      'Prd(NP).linkcode = RtrimGetField(rsPNProds!PNcode)
      Prd(NP).linkcode = RtrimGetField(rsPNProds!StockLookUp)
      Prd(NP).maxmlperkg = RtrimGetField(rsPNProds!maxmlperkg)
      Prd(NP).maxmltotal = RtrimGetField(rsPNProds!maxmltotal)
      Prd(NP).mOsmperml = RtrimGetField(rsPNProds!mOsmperml)
      Prd(NP).name = RtrimGetField(rsPNProds!Description)
      Prd(NP).PO4organic = RtrimGetField(rsPNProds!Phosphate_mmol) - RtrimGetField(rsPNProds!PhosphateInorganic_mmol) 'RtrimGetField(rsPNProds!PO4organic)
      Prd(NP).PreMix = RtrimGetField(rsPNProds!PreMix)
      Prd(NP).SharePacks = RtrimGetField(rsPNProds!SharePacks)
      Prd(NP).SolnAB = RtrimGetField(rsPNProds!AqueousorLipid)
      If UCase$(Prd(NP).SolnAB) = "L" Then Prd(NP).SolnAB = "B"   '19Mar12 TH TFS
      Prd(NP).SpGrav = RtrimGetField(rsPNProds!SpGrav)
      'Prd(NP).VacumatIg = RtrimGetField(rsPNProds!VacumatIg)
      ig(NP) = RtrimGetField(rsPNProds!Volume_ml)
      igover(NP) = RtrimGetField(rsPNProds!TotalVolumeIncOverage)
      If igover(NP) = 0 Then igover(NP) = ig(NP)  '21Feb12 TH If volume including overage is null then this is because there is no overage so use the straight value.
      NP = NP + 1
      
      rsPNProds.MoveNext
      Loop
      
      
   
   End If

End Sub

Public Sub PNLoadRegimen(ByVal lngRegimenRequestID As Long, ByVal lngSupplyRequestID As Long)
'Public Sub PNLoadRegimen(ByVal lngSupplyRequestID As Long)
'20Jan12 TH This routine loads regime data into the various old arrays and types
'11Sep14 XN 88799 Added printing of prescription from regimen
'04Nov15 TH Load the PNPrescriptionID and Supply request into the globals here so we can use this in any transaction logs (TFS 133853)
'16Feb16 XN Fixed issue with PN supply request not populating Wtranlog.RequestID_Dispensing 145448

Dim strParams As String
Dim rsRegimen As ADODB.Recordset

   '04Nov15 TH Clean these prior to loading the regimen (TFS 133853)
   gRequestID_Prescription = 0
   gRequestID_Dispensing = 0
   L.RequestID = 0      '16Feb16 XN 145448 Fixed issue with PN supply request not populating Wtranlog.RequestID_Dispensing
      
   buildname pid, False, PatientName$
   IgMax = Val(tp("IgMax"))
   'tpninifile$ = "\TPNSETUP.INI"
   tpninifile$ = "\PNSETUP.INI"  '28Mar12 TH Added

   'strParams = gTransport.CreateInputParameterXML("PNSupplyRequestID", trnDataTypeint, 4, lngSupplyRequestID)    11Sep14 XN 88799 Added printing of prescription from regimen
   'Set rsRegimen = gTransport.ExecuteSelectSP(g_SessionID, "pRegimenforPharmacybyPNSupplyRequestID", strParams)

   strParams = gTransport.CreateInputParameterXML("PNRegimenRequestID", trnDataTypeint, 4, lngRegimenRequestID)
   strParams = strParams + gTransport.CreateInputParameterXML("PNSupplyRequestID", trnDataTypeint, 4, lngSupplyRequestID)
   Set rsRegimen = gTransport.ExecuteSelectSP(g_SessionID, "pRegimenforPharmacybyRegimenAndSupplyRequest", strParams)
   
   If Not rsRegimen.EOF Then
      rsRegimen.MoveFirst 'Should be superfluos as there should only be one row. Howver we arent going to explicitly test for this.
      
      '04Nov15 TH Load the PNPrescriptionID and Supply request into the globals here so we can use this in any transaction logs (TFS 133853)
      gRequestID_Prescription = RtrimGetField(rsRegimen!PNPrescription_RequestID)
      gRequestID_Dispensing = lngSupplyRequestID
      L.RequestID = lngSupplyRequestID      '16Feb16 XN 145448 Fixed issue with PN supply request not populating Wtranlog.RequestID_Dispensing
      'OK here we basically need to fill out all our standard PN variables for Issuing/Printing
      batchnumber$ = RtrimGetField(rsRegimen!batchnumber)
      If RtrimGetField(rsRegimen!perkilorules) Then
         m_blnAdult = False ' True    '09Mar12 TH Wrong way around - oops (TFS 28622)
      Else
         m_blnAdult = True 'False
      End If
      m_intNumberofbags = RtrimGetField(rsRegimen!numofbags)
      lblscombined = RtrimGetField(rsRegimen!IsCombined)
      
      'overage(1) = RtrimGetField(rsRegimen!Overagelipid)
      'overage(2) = RtrimGetField(rsRegimen!OverageAqueousOrCombined)
      overage(1) = RtrimGetField(rsRegimen!OverageAqueousOrCombined)    '21Mar12 TH Swapped over as going into the wrong part of the array (TFS 29652)
      overage(2) = RtrimGetField(rsRegimen!Overagelipid)                '    "
      overage(3) = RtrimGetField(rsRegimen!OverageAqueousOrCombined)
      
      weight! = RtrimGetField(rsRegimen!DosingWeight_KG)
      
      tpndef.NumLabels(1) = RtrimGetField(rsRegimen!NumberofLabelsAminoCombined)
      tpndef.NumLabels(2) = RtrimGetField(rsRegimen!NumberofLabelsLipid)
      tpndef.NumLabels(3) = RtrimGetField(rsRegimen!NumberofLabelsAminoCombined)
      
      m_SupplyRequestAdminStartDate = RtrimGetField(rsRegimen!AdminStartDate)
      
      tpndef.expiry(1) = RtrimGetField(rsRegimen!ExpiryAminoCombined)
      tpndef.expiry(2) = RtrimGetField(rsRegimen!ExpiryLipid)
      tpndef.expiry(3) = RtrimGetField(rsRegimen!ExpiryAminoCombined)
      strRegimenDescription = RtrimGetField(rsRegimen!RegimenDescription)
      m_intDaysPerBag = IIf(RtrimGetField(rsRegimen!Supply48Hours), 2, 1) '19Apr12 TH Added
      g_blnPNStatusIssued = False
      g_blnPNStatusPrinted = False
      g_blnPNStatusComplete = False
      g_blnPNStatusBeingMade = False
      On Error Resume Next
      g_blnPNStatusIssued = RtrimGetField(rsRegimen!PNIssued)
      g_blnPNStatusPrinted = RtrimGetField(rsRegimen!PNPrinted)
      On Error GoTo 0
   End If


End Sub

Public Sub PrintPN(ByVal lngSupplyRequestID As Long)
'02Feb12 TH New entry point for PN Printing
'11Sep14 XN 88799 Added printing of prescription from regimen
Dim strResult As String
Dim intloop As Integer

' If no supply reques then just print prescription directly 11Sep14 XN 88799
If lngSupplyRequestID > 0 Then
frmoptionset 0, "PN Print Options"
   frmoptionset 1, "&Worksheet"
   frmoptionset 1, "Prescription"                                                      '18Jul00 CKJ disable in batch mode
''   frmoptionset 1, "&Prescription" & Iff(iBatchMode, Nul, "")                           '   "
   frmoptionset 1, "Insert for Notes"                                                  '   "
''   frmoptionset 1, "Insert for &Notes" & Iff(iBatchMode, Nul, "")                       '   "
   frmoptionset 1, "&Authorise Baxa File"                    'MM-24 SP added
   frmoptionset 1, "&Labels"
''   frmoptionset 1, "&Invoice"
'   frmoptionset 1, Iff(frmVA.mnuBaxa.Enabled = True, "&Authorise Baxa File", Nul)       '18Jul00 CKJ

''   If TrueFalse(TxtD$(dispdata$ & "\tpn.ini", "", "", "AskExitAfterPrinting", 0)) Then  '12Nov98 CKJ added
''         frmoptionset 1, "&Exit after printing"                                         '   "
''      End If                                                                            '   "
''
   'frmoptionshow tpnini$("PrintOptions", "1001000"), strResult  '12Nov98 CKJ was "1  1 "  '18Jul00 CKJ was "100100"
   frmoptionshow tpnini$("PrintOptions", "10010"), strResult
Else
    strResult = "01000" ' select prescription be default
End If

   k.escd = False
   'For i = 1 To 5                                            '12Nov98 CKJ removed
   For intloop = 1 To Len(strResult)                                  '12Nov98 CKJ use actual length
      If Mid$(strResult, intloop, 1) = "1" Then
            Select Case intloop
               Case 1: menuWSheet lngSupplyRequestID
               Case 2: menuPrintScriptNotes True
               Case 3: menuPrintScriptNotes False
               Case 4: BaxaFile
               'Case 5: PrintInvoice
               Case 5: PrintTPNlabel                              'MM-24 SP added  '18Jul00 CKJ added
''               Case 7                                          '   "        was Case 6
''                  Unload frmVA                                 '12Nov98 CKJ added
''                  ExitAfterPrinting = Not k.escd               '   "        do exit if user has not escaped from printing
               End Select
         End If
      If k.escd Then Exit For
   Next

   frmoptionset 0, ""      'unload
   
   strPNOutputMessage = "Printing " & Iff((k.escd Or (Trim$(strResult) = "")), "aborted", "complete") & strPNOutputMessage '26Mar12 TH Added cancel handling
End Sub
Sub PNLoadPrinting()
'17Feb12 TH Anything we may need to get from the print XML we will get from here

Dim xmldoc As MSXML2.DOMDocument
Dim xmlElement As MSXML2.IXMLDOMElement

Set xmldoc = New MSXML2.DOMDocument
   If Not xmldoc.loadXML(GetPNPrintXML()) Then
      popmessagecr "", "Could not load PN Printing Information"
   Else
   Set xmlElement = xmldoc.selectSingleNode("//PNPrintData")
   
   
   End If
End Sub
Function GetPNBatchnumber() As String
   GetPNBatchnumber = batchnumber$
End Function
Sub PNLayoutEditor(ByVal viewonly As Boolean)
'30Mar16 XN 102357 Added pn paed labels
'06Dec16 TH First pass rtf file replacement (TFS 157969)
'30Jan17 TH Ensure any mods are saved to the DB (TFS 174973)

Dim msg$, ans1$, ans2$, ans3$, rule$, SQLq$, i%, tmp$, dat$, Numoflines%, flag%, Value$
Dim key1&, key2&, idx1%, ans0%, numoptions%, X%
Dim title$, edflag$, Changed%, itemname$, TopField$, tmp1$
Dim filename$, txt$, txtwas$, dummy%, change%, fullpage%, special%, units$
Dim sErr$, iErr%                                                                       '05Jun00 CKJ
Dim sLogText As String                                                                 '         "

ReDim lines$(100)

   numoptions = Val(tp("DBtot"))
   'ViewOnly = False

   Do
      'k.helpnum = 0
      'LstBoxFrm.Caption = "Database & layout viewer"
      'LstBoxFrm.LblTitle = cr & "Select database or layout to examine" & cr
      LstBoxFrm.Caption = "Layout viewer"
      LstBoxFrm.lblTitle = cr & "Select layout to examine" & cr
      LstBoxFrm.lblHead = ""

      For i = 1 To numoptions
         tmp$ = tp("DB" & Format$(i))
         deflines tmp$, lines$(), "!", 1, Numoflines
         If Numoflines = 2 Then
            If InStr(LCase$(lines$(2)), "layout") Then
               LstBoxFrm.LstBox.AddItem lines$(2)
               LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = Val(lines$(1))
            End If
         End If
      Next

      
      LstBoxFrm.LstBox.ListIndex = ans0

      LstBoxShow

      ans1$ = ""
      ans0 = LstBoxFrm.LstBox.ListIndex
      If ans0 > -1 Then
         ans1$ = Format$(LstBoxFrm.LstBox.ItemData(ans0))
      End If
      Unload LstBoxFrm

      Select Case ans1$
         Case "201", "202", "203", "204", "205", "206", "207", "208", "209", "210", "211", "212"
            Select Case Val(ans1$) - 200
               Case 1:  filename$ = "TPN-PWS"
               Case 2:  filename$ = "TPN-AWS"
               Case 3:  filename$ = "TPN-BWS"
               Case 4:  filename$ = "TPN-PSC"
               Case 5:  filename$ = "TPN-ASC"
               Case 6:  filename$ = "TPN-PNO"
               Case 7:  filename$ = "TPN-ANO"
               Case 8:  filename$ = "TPN-INV"
               Case 9:  filename$ = "TPN-DEL"
               Case 10: MsgBox "Use the ICW Report Editor to edit this report." + vbNewLine + "In the report editor select Report Types->Stand-alone->Pharmacy General Report" ' XN 19Feb13 report for the TPN-DBP is not in the db so use the standard ICW editor for it
                        filename$ = ""
               Case 11: filename$ = "TPN-INVB"      ' 2Jul97 CKJ Added
               Case 12: filename$ = "TPN-WSTB"      '12Jul98 CKJ Added
            End Select
            
            If filename$ <> "" Then         ' XN 19Feb13 report for the TPN-DBD is not in the db so use the standard ICW editor for it
                'GetTextFile dispdata$ & "\" & filename$ & ".rtf", txt$, dummy%
                
                '30Jan17 TH replaced section below
                'GetRTFTextFromDB dispdata$ & "\" & filename$ & ".rtf", txt$, dummy%  '06Dec16 TH Replaced (TFS 157969)

                'txtwas$ = txt$
                'HighEdit.HelpContextID = 5120
                'Hedit Iff(viewonly, 0, 1), txt$         'view and edit it '18Jul00 CKJ Added view only option
    
                'If txt$ <> txtwas$ Then
                '   PutTextFile dispdata$ & "\" & filename$ & ".rtf", txt$, dummy%
                '   sLogText = "Edited layout file " & filename$                       '05Jun00 CKJ added !!** keep copy?
                '   WriteLog dispdata$ & "\PNedit.log", 0, UserID$, sLogText           '   "
                'End If
                If viewonly Then   '30Jan17 TH replaced above (TFS 174973)
                   GetRTFTextFromDB dispdata$ & "\" & filename$ & ".rtf", txt$, dummy%
                   Hedit 0, txt$
                Else
                   EditRTFFromDB dispdata$ & "\" & filename$ & ".rtf", dispdata$ & "PNedit.log"
                End If
            End If

         'Case "501", "502", "503", "504"                '11Jul98 CKJ replaced .dat with .rtf
                 Case "501", "502", "503", "504", "505", "506"   '30Mar16 XN 102357 Added pn paed labels
            Select Case ans1$
               Case "501": filename$ = "TPN-LBLA"
               Case "502": filename$ = "TPN-LBLL"
               Case "503": filename$ = "TPN-LBLB"
               Case "504": filename$ = "TPN-LBLS"       '11Jul99 CKJ Added Syringe layout for labels
               Case "505": filename$ = "TPN-LBLPA"              '30Mar16 XN 102357 Added
               Case "506": filename$ = "TPN-LBLPL"              '30Mar16 XN 102357 Added
            End Select
            'GetTextFile dispdata$ & "\" & filename$ & ".rtf", txt$, dummy%
            '30Jan17 TH replaced section below
            'GetRTFTextFromDB dispdata$ & "\" & filename$ & ".rtf", txt$, dummy%  '06Dec16 TH Replaced (TFS 157969)

            'txtwas$ = txt$
            'HighEdit.HelpContextID = 5120
            'Hedit Iff(viewonly, 0, 1), txt$         'view and edit it '18Jul00 CKJ Added view only option

            'If txt$ <> txtwas$ Then
            '   PutTextFile dispdata$ & "\" & filename$ & ".rtf", txt$, dummy%
            '   sLogText = "Edited layout file " & filename$                       '05Jun00 CKJ added !!** keep copy?
            '   WriteLog dispdata$ & "\PNedit.log", 0, UserID$, sLogText           '   "
            'End If
            
            If viewonly Then   '30Jan17 TH replaced above (TFS 174973)
               GetRTFTextFromDB dispdata$ & "\" & filename$ & ".rtf", txt$, dummy%
               Hedit 0, txt$
            Else
               EditRTFFromDB dispdata$ & "\" & filename$ & ".rtf", dispdata$ & "PNedit.log"
            End If
            
      End Select
            
   Loop While ans1$ <> ""

   sLogText = Iff(viewonly, "PN Configuration Viewer", "PN Supervisor Editor")            '18Jul00 CKJ modified
   sLogText = sLogText & " - Stopped on terminal " & ASCTerminalName$()                   '   "

   WriteLog dispdata$ & "\PNedit.log", 0, UserID$, sLogText
End Sub
Function GetLabelsPrinted() As Boolean
   GetLabelsPrinted = m_blnLabels
End Function

Sub SetLabelsPrinted(ByVal blnLabelsPrinted)
   m_blnLabels = blnLabelsPrinted
End Sub
Sub PNAttachnote(ByVal strNoteTypeDescription As String, ByVal lngSupplyRequestID As Long, ByVal strDescription As String)


   CreateAttachNoteLinkedtoRequest strNoteTypeDescription, gEntityID_User, strDescription, True, lngSupplyRequestID
End Sub

Function GetBAXABarcode(ByVal strBarcode As String) As String
'29Jul13 TH Written to generate BAXA Barcode (TFS)
'           This should take an existing output filename and turn into something recognisable
'           For the compounder when barcoded

Dim intChecksum As Integer
Dim intCount As Integer


   'strBarcode = Trim$(strBarcode)
   intChecksum = 0
   If Len(strBarcode) > 0 Then
      For intCount = 1 To Len(strBarcode)
         Select Case Asc(Mid$(strBarcode, intCount, 1))
            Case 65 To 90: intChecksum = intChecksum + (Asc(Mid$(strBarcode, intCount, 1)) - 55)
            Case 45:  intChecksum = intChecksum + 36 '"-"
            Case 46:  intChecksum = intChecksum + 37 '"."
            Case 32:  intChecksum = intChecksum + 38 '" "
            Case 36:  intChecksum = intChecksum + 39 '"$"
            Case 47:  intChecksum = intChecksum + 40 '"/"
            Case 43:  intChecksum = intChecksum + 41 '"+"
            Case 37:  intChecksum = intChecksum + 42 '"%"
            Case 48:  intChecksum = intChecksum + 43 '"0"
            Case Else: intChecksum = intChecksum + Val(Mid$(strBarcode, intCount, 1))
         End Select
      Next
      
      'We should now have our checkdigit - set to correct character and send up
      Select Case intChecksum Mod 43
         Case 1 To 9: strBarcode = strBarcode & Format$(intChecksum Mod 43)
         Case 10 To 35: strBarcode = strBarcode & Chr$((intChecksum Mod 43) + 55)
         Case 36: strBarcode = strBarcode & "-"
         Case 37: strBarcode = strBarcode & "."
         Case 38: strBarcode = strBarcode & " "
         Case 39: strBarcode = strBarcode & "$"
         Case 40: strBarcode = strBarcode & "/"
         Case 41: strBarcode = strBarcode & "+"
         Case 42: strBarcode = strBarcode & "%"
         Case 43: strBarcode = strBarcode & "0"
      End Select
      
   End If
   
   
   
   GetBAXABarcode = strBarcode








End Function

Function HasLayout(ByVal intLayoutNumber As Integer) As Boolean
' Returns if the layout number is available under WConfiguration
' Category: A|PNW.044
' Section:
' Key:          DBxx
' Value:        contains intLayoutNumber before a !
' 30Mar16 102357
    Dim lines$(1 To 50)
    Dim tmp$
    Dim numoptions%, Numoflines%, i%

    HasLayout = False
    numoptions = Val(tp("DBtot"))

    For i = 1 To numoptions
        tmp$ = tp("DB" & Format$(i))
        deflines tmp$, lines$(), "!", 1, Numoflines
        If Numoflines = 2 Then
            If InStr(LCase$(lines$(2)), "layout") And (Val(lines$(1)) = intLayoutNumber) Then
                HasLayout = True
            End If
        End If
    Next
End Function
