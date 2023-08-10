Attribute VB_Name = "Logview"
'------------------------------------------------------------------------------------------------
'               LOGVIEW.BAS
'
' 7Oct97 CKJ UserLogViewer moved from testbed to its own module
'            allowing it to be used in various EXEs
'            See header for usage instructions
'            Requires Subpatme, HighEdit and our replacement message box
'            plus Corelib & GUIbits
'08Oct97 CKJ Released for testing as stand alone app.
'14Oct97 CKJ corrected display of translog
'05Feb98 SF/CFY UserLogViewer: Corrected multiple search in logview
'16Feb98 CKJ Removed above mod as it was correct originally,
'            Extended message to describe use of multiple items
'            To default to own site, pass "0" as site number
'11Jun98 ASC/CKJ Added drug description to each log and added /I to search to find a drug code when not know
'25Aug98 CFY Added 'Terminal' to output.
'14Oct98 CKJ ScanLogFile written
'28Oct98 CKJ/CFY Cosmetic change to translog & orderlog header lines
'03Nov98 TH  UserLogViewer: Changed viewer titles to allow for proper currency description
'20Jan99 CKJ Cannot show progress over modal form, so added resume next
'22Feb99 CFY UserLogView: Added Stock Level to output.
'20May01 TH  UserLogView: Added Search Criteria for logview calls to translog - uses extra parameter (#52397)
'15Jan02 TH  UserLogViewer: Added time of order and receipt in orderlog view, and changer header from terminal
'   "        to description as this is what it actually shows (#53214)
'25Jan02 TH  UserLogViewer: Added Stocklvl to Orderlog display (#53214)
'21Feb02 TH  UserLogViewer: Show CustOrdNo in Translog if set to up use them (enh1435)
'21Feb02 TH  UserLogViewer: Make sure text searches are case insensitive (#59102)
'29Apr02 SF  GroupTextByProduct: added to group the given text by product NSV Code.  (enh#1555)
'            If the transaction log then total on issue and return.
'            If the oder log then total on products receieved
'            SetGroupByProduct: added to switch the log viewer mode to grouping or individual lines
'            UserLogViewer: mods to allow grouping on products (enh#1555)
'10May02 SF  UserLogViewer: when grouping by product, makes the selection of a product mandatory (enh#1555). Not commented as original not released to site.
'13Oct03 TH  UserLogViewer: Mod to remove the new ID field (a long) from record - dont want to search on that
'16May04 TH  UserLogViewer: Added mods for (enh1435) - shows pickingticket number in logviewer where necessary.
'16May04 TH                 Added mods to hide the price on certain passlvls (UMMC Price hide)
'27May04 TH  UserLogViewer: Now uses HidePrice for UMMC mod
'05Aug13 TH  NewUserLogViewer: Removed format of batch number as this was interpretting exponential
'                              and decimal possible numeric stings  (TFS 56051)
'25Mar15 XN  NewUserLogViewer: Removed brackets from around Pack value in trans log viewer 114702

'08Jun15 XN  98073: Replaced Description with ProductDescription
'------------------------------------------------------------------------------------------------
DefInt A-Z
Option Explicit


Dim m_intGroupByProduct As Integer     '29Apr02 SF added (enh#1555)

''Function ScanLogFile(ByVal logtype$, ByVal daymth$, ByVal tofind$, ByVal site$, ByVal OPformat%, filename$) As Integer
'''------------------------------------------------------------------------------------------------
'''01Oct98 CKJ Written, based on UserLogViewer
'''            Given a date plus suitable criteria returns either a list of transaction IDs
'''            which match, or writes a copy of these transactions to a temporary file.
'''            No questions are asked
'''            Given:
'''              logtype = T/O mandatory item; translog/orderlog. NB Only T supported initially.
'''              daymth$ "" or "ddmmyyyy", where "" defaults to today and search is to end of month
'''              tofind$ mandatory search criteria in the format "<item>,<value>|<item>,<value>..."
'''                  valid keywords are any of NSVCODE, PRESCID, PATRECNO, LBLTYPE in any order
'''                  any mix of upper & lower case is acceptable
'''                  e.g. "NSVcode=ABC123D,PrescID=426374,PATRECNO=15242,LBLtype=i"
'''              site$ "", "0", "123" blank for all sites, 0 for own site otherwise specific site
'''              OPformat = 1/2   1 is a complete copy of the transactions (record 1 is a pointer)
'''                               2 is filename followed by a list of record numbers e.g.
'''                                      \translog\TL199812<crlf>
'''                                      4139<crlf>
'''                                      4137<crlf>
'''            Returns:
'''              filename$ is the temporary local file assigned for the output text ("" if error)
'''              Function itself returns errcode as follows
'''               0  no error
'''               1  log file not specified (or O requested and not yet supported)
'''               2  date given is not valid
'''               3  OPformat not valid
'''               4  log file specified not found
'''
'''
'''------------------------------------------------------------------------------------------------
''Dim vchan%, yyyymm$, yyyymmdd1$, yyyymmdd2$
''Dim valid%, DoIt%, numlines%, count%, DateFormat$, Increment&
''Dim length%, FILE$, fil%, pointer&, RecNo&, vfile$, errcode%
''Dim o As orderlogstruct, T As transaction
''
''   ReDim Find$(1 To 10), lines$(1 To 10)
''   errcode = 0
''
''   If site$ = "0" Then site$ = Format$(SiteNumber)
''
''   logtype$ = UCase$(logtype$)
''   Select Case logtype$
''      Case "T"   ' "O"  not orderlog yet
''      Case Else: errcode = 1
''      End Select
''
''   If errcode = 0 Then
''         DateFormat$ = "dd/mm/yyyy"
''         If daymth$ = "" Then daymth$ = Format$(Now, DateFormat$)         'today as default
''         parsedate (daymth$), daymth$, (DateFormat$), valid
''         If Not valid Then errcode = 2
''      End If
''
''   If errcode = 0 Then
''         parsedate daymth$, yyyymm$, "yyyymm", valid
''         parsedate daymth$, yyyymmdd1$, "yyyymmdd", valid
''      End If
''
''   If errcode = 0 Then
''         Select Case OPformat
''            Case 1, 2
''            Case Else: errcode = 3
''            End Select
''      End If
''
''   If errcode = 0 Then
''         For count = 1 To 10
''            Find$(count) = Nul
''         Next
''         deflines UCase$(tofind$), lines$(), ",", 1, numlines
''         For count = 1 To numlines
''            If Left$(lines$(count), 8) = "NSVCODE=" Then Find$(1) = Mid$(lines$(count), 9)
''            If Left$(lines$(count), 8) = "PRESCID=" Then Find$(2) = Mid$(lines$(count), 9)
''            If Left$(lines$(count), 9) = "PATRECNO=" Then Find$(3) = Mid$(lines$(count), 10)
''            If Left$(lines$(count), 8) = "LBLTYPE=" Then Find$(4) = Mid$(lines$(count), 9)
''         Next
''      End If
''
''   If errcode = 0 Then
''         length = 0
''         Select Case logtype$
''            Case "T"
''               FILE$ = transpath$ & "\tl" & yyyymm$
''               length = Len(T)
''            Case "O"
''               FILE$ = orderlogpath$ & "\ol" & yyyymm$
''               length = Len(o)
''            End Select
''
''         If fileexists(FILE$) Then
''               Screen.MousePointer = HOURGLASS
''               MakeLocalFile vfile$
''               vchan = FreeFile
''               Open vfile$ For Output As #vchan                  'output channel for viewing
''               fil = FreeFile
''               openrandomfile FILE$, length, fil                 'input channel
''               GetPointer FILE$, pointer&, False
''
''               Select Case OPformat
''                  Case 1: Print #vchan, Space$(length);          'pointer goes here
''                  Case 2: Print #vchan, FILE$; crlf;             'input file name
''                  End Select
''
''               Progress.lblInfo = "Searching " & logtype$ & "L" & yyyymm$ & " after " & daymth$ & crlf & "For " & Iff(Len(tofind$), "'" & tofind$ & "'", "all entries") & crlf & "Site code: " & Iff(Len(site$), site$, "all sites") & crlf & "Number of entries:" & Str$(pointer& - 1)
''               Progress.Show 0
''               Increment& = pointer& \ 100
''               If Increment& < 1 Then Increment& = 1
''
''               count = 0
''               For RecNo& = pointer& To 2& Step -1               'scan from end backwards
''                  If (RecNo& Mod Increment&) = 0 Then Progress.PerCent = 100 * (pointer& - RecNo&) \ pointer&
''                  GetRecordNL r, RecNo&, fil, length
''                  DoIt = True
''
''                  Select Case logtype$
''                     Case "T"
''                        LSet T = r
''                        parsedate T.date, yyyymmdd2$, "yyyymmdd", valid
''                        If Val(yyyymmdd2$) < Val(yyyymmdd1$) Then
''                              Exit For                                          '<== Exit early
''                           End If
''
''                        If Len(site$) > 0 And Val(T.site) <> Val(site$) Then DoIt = False
''                        If Find$(1) <> Nul And Find$(1) <> Trim$(UCase$(T.SisCode)) Then DoIt = False
''                        If Find$(2) <> Nul And Find$(2) <> Trim$(UCase$(T.PrescriptionNum)) Then DoIt = False
''                        If Find$(3) <> Nul And Find$(3) <> Trim$(UCase$(T.patid)) Then DoIt = False
''                        If Find$(4) <> Nul And Find$(4) <> Trim$(UCase$(T.labeltype)) Then DoIt = False
''
''                     Case "O"
''                        'Not written yet!
''                     End Select
''
''                  If DoIt Then
''                        Select Case OPformat
''                           Case 1: Print #vchan, Left$(r.record, length);       'copy of record
''                           Case 2: Print #vchan, Format$(RecNo&); crlf;         'record number
''                           End Select
''                        count = count + 1
''                     End If
''                  If EOF(fil) Then Exit For                                     '<== Exit
''               Next
''               Unload Progress
''
''               Close fil
''               Close vchan
''               If OPformat = 1 Then GetPointer vfile$, count + 1, 2             'write pointer
''               Screen.MousePointer = STDCURSOR
''
''            Else
''               errcode = 4
''            End If
''      End If
''
''   filename$ = Iff(errcode = 0, vfile$, "")
''   ScanLogFile = errcode
''
''End Function

Sub SetGroupByProduct(ByVal i_intGroupByProduct As Integer)
'29Apr02 SF added to switch the log viewer mode to grouping or individual lines

    m_intGroupByProduct = i_intGroupByProduct

End Sub

Sub UserLogViewer(ByVal askQ$, ByVal LogType$, ByVal strStartDate As String, ByVal tofind$, ByVal site$, iSrch%)
'------------------------------------------------------------------------------------------------
'                       LOGFILE VIEWER & EDITOR V1.0
'                       ----------------------------

'------------------------------------------------------------------------------------------------
Dim Logview As String, vchan%, msg$, yyyymm$, yyyymmdd1$, yyyymmdd2$
Dim valid%, datwas$, DoIt%, numlines%, count%, tmp$, DateFormat$, Increment&
Dim length%, FILE$, fil%, pointer&, recno&, recnum$, temp$, posn%, vfile$
'Dim o As orderlogstruct, T As transaction
Dim dlocal As DrugParameters, desc$, found%, ans$  '11Jun98 ASC
Dim lngLineCount As Long, lngHeaderLength As Long, lngTrailerLength As Long   '29Apr02 SF added (enh#1555)
Dim strMMYYYY As String
Dim strTable As String
Dim strSql As String
'Dim oDataAccess    As clsDataAccess
Dim rsLogs    As ADODB.Recordset
Dim strParams As String
Dim strSiscode As String
Dim strDispID As String
Dim strSite As String
Dim strWard As String
Dim strCaseno As String
Dim lngDayMth As Long
Dim strDate As String
Dim lngSite As Long
Dim lngEndDayMth As Long
Dim strEndDate As String
Dim startyyyymm$
Dim startyyyymmdd$
Dim endyyyymmdd$

Dim endyyyymm$
Dim lngMaxrows
'Dim strStartDate As String

   'Initialise the criteria
   strParams = ""
   strSiscode = ""
   strDispID = ""
   strSite = ""
   strWard = ""
   strCaseno = ""
   lngDayMth = 0
   
   Logview = "Log File Viewer"                                      'caption for forms
   DateFormat$ = "dd mmm yyyy"                                      'for display & data entry
   If LogType$ = "" Then LogType$ = "T"                             'translog by default
   LogType$ = UCase$(LogType$)
   If strStartDate = "" Then strStartDate = Format$(Now, DateFormat$)         'today as default
   If Len(strStartDate) Then parsedate (strStartDate), strStartDate, (DateFormat$), valid
   If site$ = "0" Then site$ = Format$(SiteNumber)                   '16Feb98 CKJ own site
   k.escd = False
   'If logtype$ = "C" Then
   strEndDate = Format$(Now, DateFormat$) '18Oct05 th Now set defualt end date to todays date ???(#79842)
   'Else
   '   strEndDate = strStartDate
   'End If
   Do
      If InStr(askQ$, "L") Then
         msg$ = "Enter Log File to view" & cr & cr
         msg$ = msg$ & "(T)ransaction log - Issues, Returns" & cr
         msg$ = msg$ & "(O)rder log          - Orders, Receipts, Credits, Reconciliation" & cr
         msg$ = msg$ & "(C)ombined stock movements"
         k.validchars = "TOC"
         k.min = 1
         k.Max = 1
         inputwin Logview, msg$, LogType$, k
      End If
         
      If k.escd Then Exit Do                                        '<== Exit here

      If InStr(askQ$, "D") Then
         k.min = 1
         k.Max = 15
         msg$ = "Enter earliest date to be searched" & cr & cr
         msg$ = msg$ & "dd-mm-yyyy  or any standard date formats," & cr
         msg$ = msg$ & "including  T  for today,  Y  for yesterday," & cr
         msg$ = msg$ & "-5D  for last five days, -2W  for last two weeks," & cr
         msg$ = msg$ & "00-mm-yyyy or Jan 98  to search the whole month" & cr & cr
         'msg$ = msg$ & "Search runs from day specified to end of that month"
         msg$ = msg$ & "Search runs from day specified "
         Do
            inputwin Logview, msg$, strStartDate, k
            datwas$ = strStartDate
            If Not k.escd Then
               'parsedate strStartDate, startyyyymm$, "mmyyyy", valid
               Storesparsedate strStartDate, startyyyymm$, "mmyyyy", valid
               If Not valid Then
                  BadDate
                  datwas$ = ""
               Else
                  'parsedate (strStartDate), strStartDate, (DateFormat$), valid
                  Storesparsedate (strStartDate), strStartDate, (DateFormat$), valid
               End If
            End If
         Loop While Not k.escd And strStartDate <> datwas$
         If Not valid Then k.escd = True
            If Not k.escd Then
            msg$ = "Enter latest date to be searched" & cr & cr
            msg$ = msg$ & "dd-mm-yyyy  or any standard date formats," & cr
            msg$ = msg$ & "including  T  for today,  Y  for yesterday," & cr
            msg$ = msg$ & "-5D  for last five days, -2W  for last two weeks," & cr
            msg$ = msg$ & "00-mm-yyyy or Jan 98  to search the whole month" & cr & cr
            'msg$ = msg$ & "Search runs from day specified to end of that month"
            msg$ = msg$ & "Search runs to day specified "
            strEndDate = strStartDate
            Do
               inputwin Logview, msg$, strEndDate, k
               datwas$ = strEndDate
               If Not k.escd Then
                  'parsedate strEndDate, endyyyymm$, "mmyyyy", valid
                  Storesparsedate strEndDate, endyyyymm$, "mmyyyy", valid
                  If Not valid Then
                     BadDate
                     datwas$ = ""
                  Else
                     'parsedate (strEndDate), strEndDate, (DateFormat$), valid
                     Storesparsedate (strEndDate), strEndDate, (DateFormat$), valid
                     If CDate(strEndDate) < CDate(strStartDate) Then
                        popmessagecr "", "The last date must be after the first date specified for a given search"
                        strEndDate = strStartDate
                     End If
                  End If
               End If
            Loop While Not k.escd And strEndDate <> datwas$
            If Not valid Then k.escd = True
         End If
      End If
   
      If Not k.escd Then
         'parsedate strStartDate, strMMYYYY, "mmyyyy", valid
         Storesparsedate strStartDate, strMMYYYY, "mmyyyy", valid
         'parsedate strStartDate, startyyyymmdd$, "yyyymmdd", valid
         Storesparsedate strStartDate, startyyyymmdd$, "yyyymmdd", valid
         If valid Then lngDayMth = CLng(startyyyymmdd$)
         'parsedate strEndDate, strMMYYYY, "mmyyyy", valid
         Storesparsedate strEndDate, strMMYYYY, "mmyyyy", valid
         'parsedate strEndDate, endyyyymmdd$, "yyyymmdd", valid
         Storesparsedate strEndDate, endyyyymmdd$, "yyyymmdd", valid
         If valid Then lngEndDayMth = CLng(endyyyymmdd$)
      End If

      If InStr(askQ$, "F") > 0 And Not k.escd Then
            
         If Not m_intGroupByProduct Then     '29Apr02 SF do as before
            k.min = 0
            k.Max = 20
            msg$ = "Enter text for which to search" & cr & cr                         '11Jun98 ASC/CKJ
            msg$ = msg$ & "Leave blank to search for all entries, or" & cr            '      "
            msg$ = msg$ & "Enter list of items separated by a space or comma" & cr    '      "
            msg$ = msg$ & "e.g. type XYZ123B,56,ABC,MED1" & cr                        '      "
            msg$ = msg$ & "to search for specific item, quantity, user and ward" & cr
            msg$ = msg$ & "/I will look for an item when the code is not known"       '11Jun98 ASC/CKJ
            inputwin Logview, msg$, tofind$, k
         Else
            tofind$ = "/I"
         End If
         If InStr(1, tofind$, "/I", 1) Then
            'inputwin Logview, "Enter item for search ", ans$, k
            'EnterDrug ans$, "Logview" '09Mar07 TH Replaced above and wrappered below to ensure we have something useful. (SC-07-0137)
            If ans$ = "" Then
               setinput 0, k
               k.Max = 14
               k.min = 2
               k.helpnum = 360
               inputwin "Logview", "Enter item code ", ans$, k
            End If
            If Not k.escd Then findrdrug ans$, False, dlocal, 0, found, 0, False, False
            If found Then
               replace tofind$, "/I", "," & dlocal.SisCode, 0
               replace tofind$, "/i", "," & dlocal.SisCode, 0
               If Left$(tofind$, 1) = "," Then tofind$ = Mid$(tofind$, 2)
               strSiscode = tofind$
            Else
               k.escd = True
            End If
         End If
      End If
      tofind$ = UCase$(tofind$)

      
      If InStr(askQ$, "S") > 0 And Not k.escd Then
         k.min = 0
         k.Max = 3
         k.nums = True
         strSite = Format$(SiteNumber)
         inputwin Logview, "Enter site number to search for (1 - 999)" & cr & "Leave blank to search all sites", strSite, k
      End If
      
      If Not k.escd Then
         'length = 0
         Select Case LogType$
            Case "T"
               'FILE$ = transpath$ & "\tl" & yyyymm$
               strTable = "TransLog"
               'length = Len(T)
            Case "O"
               'FILE$ = orderlogpath$ & "\ol" & yyyymm$
               strTable = "OrderLog"
               'length = Len(o)
            Case "C"
               'FILE$ = orderlogpath$ & "\ol" & yyyymm$
               strTable = "CombinedLogs"
            Case Else
               Exit Do                                           '<== Error so exit
         End Select

         
         Screen.MousePointer = HOURGLASS
         MakeLocalFile vfile$
         vchan = FreeFile
         Open vfile$ For Output As #vchan                  'output channel for viewing
         fil = FreeFile
         If Not m_intGroupByProduct Then  '29Apr02 SF do as before
             Select Case LogType$
                Case "T":
                  If UCase$(Trim$(TxtD(dispdata$ & "\winord.ini", "PickingTicket", "N", "TranslogEntry", 0))) = "PICKTICKNO" Then                                                                                                                                                                                               '16May04 TH Added (enh1549)
                     ''Print #vchan, "Trans."; TB; "Case Number"; TB; "NSV code"; TB; "Quantity   "; TB; "Pack  "; TB; "User"; TB; "Date and Time  "; TB; "Cost (" & money(4) & ")"; TB; "Ward    "; TB; "Cons "; TB; "Pat"; TB; "Lbl"; TB; "Site"; TB; "Terminal      "; TB; "Stock Lvl" & TB; "Pick Tic No" & TB & crlf; crlf;        '    "
                     Print #vchan, "Case Number"; TB; "NSV code"; TB; "Quantity   "; TB; "Pack  "; TB; "User"; TB; "Date and Time  "; TB; "Cost (" & money(4) & ")"; TB; "Ward    "; TB; "Cons "; TB; "Pat"; TB; "Lbl"; TB; "Site"; TB; "Terminal      "; TB; "Stock Lvl" & TB; "Pick Tic No" & TB & crlf; crlf;        '    "
                  Else                                                                                                                                                                                                                                                                                                          '    "
                     If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "PromptCustOrdNo", 0)) Then                                                                                                                                                                                                                         '21Feb02 TH Added to show CustOrdNo if set to use
                        'Print #vchan, "Trans."; TB; "Case Number"; TB; "NSV code"; TB; "Quantity   "; TB; "Pack  "; TB; "User"; TB; "Date and Time  "; TB; "Cost (" & money(4) & ")"; TB; "Ward    "; TB; "Cons "; TB; "Pat"; TB; "Lbl"; TB; "Site"; TB; "Terminal      "; TB; "Stock Lvl" & TB; "Cust Ord No " & TB & crlf; crlf;        '    "      this functionality (enh1435)
                        Print #vchan, "Case Number"; TB; "NSV code"; TB; "Quantity   "; TB; "Pack  "; TB; "User"; TB; "Date and Time  "; TB; "Cost (" & money(4) & ")"; TB; "Ward    "; TB; "Cons "; TB; "Pat"; TB; "Lbl"; TB; "Site"; TB; "Terminal      "; TB; "Stock Lvl" & TB; "Cust Ord No " & TB & crlf; crlf;        '    "      this functionality (enh1435)
                     Else                                                                                                                                                                                                                                                                                                           '    "
                        'Print #vchan, "Trans."; TB; "Case Number"; TB; "NSV code"; TB; "Quantity   "; TB; "Pack  "; TB; "User"; TB; "Date and Time  "; TB; "Cost (" & money(4) & ")"; TB; "Ward    "; TB; "Cons "; TB; "Pat"; TB; "Lbl"; TB; "Site"; TB; "Terminal      "; TB; "Stock Lvl" & TB & crlf; crlf;
                        Print #vchan, "Case Number"; TB; "NSV code"; TB; "Quantity   "; TB; "Pack  "; TB; "User"; TB; "Date and Time  "; TB; "Cost (" & money(4) & ")"; TB; "Ward    "; TB; "Cons "; TB; "Pat"; TB; "Lbl"; TB; "Site"; TB; "Terminal      "; TB; "Stock Lvl" & TB & crlf; crlf;
                     End If                                                                                                                                                                                                                                                                                                         '    "
                  End If                                                                                                                                                                                                                                                                                                        '16May04 TH
               'Case "O": Print #vchan, "Trans."; TB; "OrdNum"; TB; "NSV code"; TB; "Date and Time Ord  "; TB; "Quantity Ord"; TB; "Date and Time Rec  "; TB; "Quantity Rec"; TB; "User"; TB; "Cost (" & money(4) & ")"; TB; "Type"; TB; "Supplier"; TB; "Site"; TB; "Other       "; TB; "Stock Lvl"; TB; "Description"; TB; crlf; crlf;   '25Jan02 TH Added Stocklvl to display (#53214)
               Case "O": Print #vchan, "OrdNum    "; TB; "NSV code"; TB; "Date and Time Ord  "; TB; "Quantity Ord"; TB; "Date and Time Rec  "; TB; "Quantity Rec"; TB; "User"; TB; "Cost (" & money(4) & ")"; TB; "Type"; TB; "Supplier"; TB; "Site"; TB; "Other       "; TB; "Stock Lvl"; TB; "Description"; TB; crlf; crlf;   '25Jan02 TH Added Stocklvl to display (#53214)
               'Case "C": Print #vchan, "Trans."; TB; "Log   "; TB; "NSV code"; TB; "Description" & Space$(50); TB; "Date and Time      "; TB; "Quantity "; TB; "User"; TB; "Cost (" & money(4) & ")"; TB; "Type  "; TB; "Site "; TB; ; "Stock Lvl"; TB; "Terminal      "; TB; crlf; crlf;  '25Jan02 TH Added Stocklvl to display (#53214)
               Case "C": Print #vchan, "Log   "; TB; "NSV code"; TB; "Description" & Space$(50); TB; "Date and Time  "; TB; "Quantity     "; TB; "User"; TB; "Cost (" & money(4) & ")"; TB; "Type  "; TB; "Site "; TB; ; "Stock Lvl"; TB; "Terminal      "; TB; crlf; crlf;  '25Jan02 TH Added Stocklvl to display (#53214)
            End Select
         Else
            Select Case LogType$
               Case "T":
                  temp$ = Space$(10) & TB & Space$(15) & TB & Space$(20) & crlf
                  temp$ = temp$ & "ISSUE/RETURN GROUPED BY PRODUCT" & crlf & crlf & crlf
                  temp$ = temp$ & "NSV Code " & TB & "Quantity " & TB & "Product Description " & crlf & crlf
               Case "O"
                  temp$ = Space$(10) & TB & Space$(15) & TB & Space$(20) & crlf
                  temp$ = temp$ & "RECEIVED GROUPED BY PRODUCT" & crlf & crlf & crlf
                  temp$ = temp$ & "NSV Code " & TB & "Quantity " & TB & "Product Description " & crlf & crlf
            End Select
            Print #vchan, temp$;
            lngHeaderLength = Len(temp$)
            lngLineCount = 0
         End If
         ReDim Find$(10)
         replace tofind$, " ", ",", 0
         deflines tofind$, Find$(), ",", 1, numlines
         Select Case iSrch
            Case 1: strWard = Left$(tofind$ & Space$(5), 5)
            Case 2: strDispID = Left$(tofind$ & Space$(3), 3)
            Case 3: strSiscode = Left$(tofind$ & Space$(7), 7)
            Case 4: strCaseno = Left$(tofind$ & Space$(10), 10)
            Case 0:
         End Select
         If Trim$(strSite) <> "" And Val(strSite) > 0 Then
            strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, CLng(strSite))
            lngSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
         Else
            lngSite = 0
         End If
         lngMaxrows = Val(TxtD(dispdata$ & "\siteinfo.ini", "LogViewer", "2000", "Maxrows", 0))
         strParams = gTransport.CreateInputParameterXML("Site", trnDataTypeint, 4, lngSite) & _
                     gTransport.CreateInputParameterXML("StartDate", trnDataTypeint, 4, lngDayMth) & _
                     gTransport.CreateInputParameterXML("EndDate", trnDataTypeint, 4, lngEndDayMth) & _
                     gTransport.CreateInputParameterXML("Caseno", trnDataTypeVarChar, 10, strCaseno) & _
                     gTransport.CreateInputParameterXML("Siscode", trnDataTypeVarChar, 7, strSiscode) & _
                     gTransport.CreateInputParameterXML("DispID", trnDataTypeVarChar, 3, strDispID) & _
                     gTransport.CreateInputParameterXML("Ward", trnDataTypeVarChar, 3, strWard) & _
                     gTransport.CreateInputParameterXML("MaxRows", trnDataTypeint, 4, lngMaxrows)
         
         Set rsLogs = gTransport.ExecuteSelectSP(g_SessionID, "pW" & strTable & "byCriteria", strParams)
         If Not rsLogs.EOF Then
            pointer& = rsLogs.RecordCount
            Screen.MousePointer = STDCURSOR
            If pointer& = lngMaxrows Then popmessagecr "Log Viewer", "Criteria returns " & Format$(lngMaxrows) & " or more records. Only the first " & Format$(lngMaxrows) & " will be used."
            Screen.MousePointer = HOURGLASS
            rsLogs.MoveFirst
            Do While Not rsLogs.EOF
               
               'Progress.lblInfo = "Searching " & logtype$ & "L" & yyyymm$ & " after " & daymth$ & crlf & "For " & Iff(Len(tofind$), "'" & tofind$ & "'", "all entries") & crlf & "Site code: " & Iff(Len(site$), site$, "all sites") & crlf & "Number of entries:" & Str$(pointer&)
               Progress.lblInfo = "Searching Logs from " & startyyyymm$ & " to " & startyyyymm$ & crlf & "For " & Iff(Len(tofind$), "'" & tofind$ & "'", "all entries") & crlf & "Site code: " & Iff(Len(site$), site$, "all sites") & crlf & "Number of entries:" & Str$(pointer&)
               On Error Resume Next
               Progress.Show 0
               On Error GoTo 0
               Increment& = pointer& \ 100
               
               If Increment& < 1 Then Increment& = 1

               
               If (recno& Mod Increment&) = 0 Then Progress.Percent = 100 * (pointer& - recno&) \ pointer&
               recnum$ = Trim(Str$(recno&))
               If numlines > 0 Then
                  DoIt = False
               Else
                  DoIt = True
               End If
               For count = 1 To numlines
                  'Do a check here against the major fields - a bit crummy really - needs improvement
                  DoIt = False
                  Select Case strTable
                     Case "TransLog"
                        'List fields required - siscode,ward,dispid,caseno,terminal,consultant
                        If InStr(1, GetField(rsLogs!SisCode), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        If InStr(1, GetField(rsLogs!ward), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        If InStr(1, GetField(rsLogs!dispid), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        If InStr(1, GetField(rsLogs!caseno), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        If InStr(1, GetField(rsLogs!terminal), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        If InStr(1, GetField(rsLogs!consultant), Find$(count), vbTextCompare) > 0 Then DoIt = True
                     Case "OrderLog"
                        'List fields required - siscode,supcode,dispid,ordernum,terminal,batchnum
                        If InStr(1, GetField(rsLogs!SisCode), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        If InStr(1, GetField(rsLogs!supcode), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        If InStr(1, GetField(rsLogs!dispid), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        If InStr(1, GetField(rsLogs!ordernum), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        If InStr(1, GetField(rsLogs!terminal), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        If InStr(1, GetField(rsLogs!BatchNum), Find$(count), vbTextCompare) > 0 Then DoIt = True
                   Case "CombinedLogs"
                        'List fields required - siscode,supcode,dispid,ordernum,terminal,batchnum
                        If InStr(1, GetField(rsLogs!SisCode), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        ''If InStr(1, GetField(rsLogs!supcode), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        If InStr(1, GetField(rsLogs!dispid), Find$(count), vbTextCompare) > 0 Then DoIt = True
                        If InStr(1, GetField(rsLogs!terminal), Find$(count), vbTextCompare) > 0 Then DoIt = True
                  End Select
                  If DoIt = False Then Exit For
               Next
                      
               If DoIt Then
                  temp$ = ""
                  
                  Select Case LogType$
                     Case "T"
                        'dlocal.SisCode = GetField(rsLogs!SisCode)
                        'getdrug dlocal, 0, 0, 0        '     "
                        If GetField(rsLogs![date]) < Val(startyyyymmdd$) Or GetField(rsLogs![date]) > Val(endyyyymmdd$) Then
                           DoIt = False
                        End If
                        If Not m_intGroupByProduct Then   '29Apr02 SF do as before
                           If Len(Trim$(GetField(rsLogs!caseno))) Then                 '16Feb98 CKJ
                              temp$ = temp$ & GetField(rsLogs!caseno)              'use CaseNo if there
                           ElseIf Len(Trim$(GetField(rsLogs!patid))) Then           'else use [RecNo]
                              temp$ = temp$ & "[" & GetField(rsLogs!patid) & "]"
                           End If
                           temp$ = temp$ & TB & GetField(rsLogs!SisCode) & TB
                           temp$ = temp$ & Trim$(GetField(rsLogs!Qty)) & " " & Trim$(GetField(rsLogs!IssueUnits)) & TB  '14Oct97 CKJ corrected display
                           temp$ = temp$ & "(" & Trim$(GetField(rsLogs!convfact)) & ")" & TB
                           temp$ = temp$ & GetField(rsLogs!dispid) & TB
                           strDate = CStr(GetField(rsLogs![date]))
                           strDate = Mid$(strDate, 7, 2) & Mid$(strDate, 5, 2) & Mid$(strDate, 1, 4)
                           parsedate strDate, tmp$, "ddmmmyyyy", valid
                           temp$ = temp$ & Iff(valid, tmp$, strDate) & " " & Left$(GetField(rsLogs!Time), 2) & ":" & Mid$(GetField(rsLogs!Time), 3, 2) & TB
                           temp$ = temp$ & HidePrice(Trim$(GetField(rsLogs!cost)), False) & TB '27May04 TH Added HidePrice and replace the surrounding code
                           temp$ = temp$ & GetField(rsLogs!ward) & TB
                           temp$ = temp$ & GetField(rsLogs!consultant) & TB
                           temp$ = temp$ & GetField(rsLogs!kind) & TB
                           temp$ = temp$ & GetField(rsLogs!labeltype) & TB
                           temp$ = temp$ & GetField(rsLogs!site) & TB
                           temp$ = temp$ & Left$(Trim$(GetField(rsLogs!terminal)) & Space$(12), 12) & TB  '25Aug98 CFY
                           temp$ = temp$ & Format$(GetField(rsLogs!stocklvl)) & TB  '22Feb99 CFY Added
                           If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "PromptCustOrdNo", 0)) Or (UCase$(Trim$(TxtD(dispdata$ & "\winord.ini", "PickingTicket", "N", "TranslogEntry", 0))) = "PICKTICKNO") Then
                              temp$ = temp$ & Format$(GetField(rsLogs!custordno)) & TB                                            '    "
                           End If                                                                                  '    "
                           'desc$ = dlocal.Description       '11Jun98 ASC/CKJ
                           desc$ = GetField(rsLogs!ProductDescription)  ' GetField(rsLogs!Description)  XN 9Jun15 98073    '11Jun98 ASC/CKJ
                           plingparse desc$, "!"            '    "
                           temp$ = temp$ & desc$            '    "
                        Else
                           'desc$ = dlocal.Description  XN 9Jun15 98073 replaced with ProductDescription
                           'desc$ = GetField(rsLogs!storesdescription)
                           'If Trim$(desc$) = "" Then desc$ = GetField(rsLogs!Description)
                                                   desc$ = GetField(rsLogs!ProductDescription)
                           plingparse desc$, "!"
                           'temp$ = dlocal.SisCode & TB & dlocal.convfact & TB & dlocal.PrintformV & TB & pad(desc$, 56) & TB & Left$(Format$(GetField(rsLogs!Qty)) & Space(13), 13)
                           temp$ = GetField(rsLogs!SisCode) & TB & GetField(rsLogs!convfact) & TB & GetField(rsLogs!IssueUnits) & TB & pad(desc$, 56) & TB & Left$(Format$(GetField(rsLogs!Qty)) & Space(13), 13)
                        End If
                              
                     Case "O"
                        'dlocal.SisCode = GetField(rsLogs!SisCode)            '11Jun98 ASC to print drug description
                        'getdrug dlocal, 0, 0, 0               '     "
                        If GetField(rsLogs![dateord]) < Val(startyyyymmdd$) Or GetField(rsLogs![dateord]) > Val(endyyyymmdd$) Then
                           If GetField(rsLogs![daterec]) < Val(startyyyymmdd$) Or GetField(rsLogs![daterec]) > Val(endyyyymmdd$) Then
                              DoIt = False
                           End If
                        End If
                        If Not m_intGroupByProduct Then   '29Apr02 SF do as before
                           temp$ = temp$ & RtrimGetField(rsLogs!ordernum) & TB
                           temp$ = temp$ & RtrimGetField(rsLogs!SisCode) & TB
                           parsedate RtrimGetField(rsLogs!dateord), tmp$, "ddmmmyyyy", valid
                           strDate = CStr(RtrimGetField(rsLogs![dateord]))
                           strDate = Mid$(strDate, 7, 2) & Mid$(strDate, 5, 2) & Mid$(strDate, 1, 4)
                           parsedate strDate, tmp$, "ddmmmyyyy", valid
                           temp$ = temp$ & Iff(valid, tmp$, strDate)
                           If Trim$(RtrimGetField(rsLogs!Timeord)) <> "" Then                                                                                   '     "
                              temp$ = temp$ & " " & Left$(RtrimGetField(rsLogs!Timeord), 2) & ":" & Mid$(RtrimGetField(rsLogs!Timeord), 3, 2) & TB '     "
                           Else                                                                                                          '     "
                              temp$ = temp$ & "      " & TB                                                '     "
                           End If
                           temp$ = temp$ & Trim$(GetField(rsLogs!qtyord))
                           temp$ = temp$ & TB     ' Temporary
                           strDate = CStr(RtrimGetField(rsLogs![daterec]))
                           strDate = Mid$(strDate, 7, 2) & Mid$(strDate, 5, 2) & Mid$(strDate, 1, 4)
                           parsedate strDate, tmp$, "ddmmmyyyy", valid
                           temp$ = temp$ & Iff(valid, tmp$, strDate)
                           If Trim$(GetField(rsLogs!Timerec)) <> "" Then                                                                                    '     "
                              temp$ = temp$ & " " & Left$(GetField(rsLogs!Timerec), 2) & ":" & Mid$(GetField(rsLogs!Timerec), 3, 2) & TB  '     "
                           Else                                                                                                           '     "
                              temp$ = temp$ & "      " & TB                                                 '     "
                           End If
                           temp$ = temp$ & Trim$(GetField(rsLogs!qtyrec))
                           temp$ = temp$ & TB     ' Temporary
                           temp$ = temp$ & GetField(rsLogs!dispid) & TB
                           temp$ = temp$ & HidePrice(Trim$(GetField(rsLogs!cost)), False) & TB '27May04 TH Added HidePrice and replace the surrounding code
                           temp$ = temp$ & GetField(rsLogs!kind) & TB
                           temp$ = temp$ & GetField(rsLogs!supcode) & TB
                           temp$ = temp$ & GetField(rsLogs!site) & TB
                           temp$ = temp$ & GetField(rsLogs!invnum) & TB
                           'If Val(dlocal.convfact) > 0 Then                                            '25Jan02 TH Added Stocklvl to display (#53214)
                           If Val(GetField(rsLogs!convfact)) > 0 Then                                            '25Jan02 TH Added Stocklvl to display (#53214)
                              'temp$ = temp$ & Format$(dp!(Val(GetField(rsLogs!stocklvl)) / Val(dlocal.convfact))) & TB  '   "
                              temp$ = temp$ & Format$(StrDecPl$(Format$(dp!(Val(GetField(rsLogs!stocklvl)) / Val(GetField(rsLogs!convfact)))), 2)) & TB '24Nov05 TH TOMERGE
                           Else                                                                     '   "
                              temp$ = temp$ & "     " & TB                                          '   "
                           End If
                           'desc$ = dlocal.Description  XN 9Jun15 98073 replaced with ProductDescription
                           'desc$ = GetField(rsLogs!storesdescription)
                           'If Trim$(desc$) = "" Then desc$ = GetField(rsLogs!Description)
                                                   desc$ = GetField(rsLogs!ProductDescription)
                           plingparse desc$, "!"
                           temp$ = temp$ & desc$
                        Else
                           If GetField(rsLogs!kind) = "R" Then
                              'desc$ = dlocal.Description
                              desc$ = GetField(rsLogs!ProductDescription)       ' GetField(rsLogs!Description)  XN 9Jun15 98073
                              plingparse desc$, "!"
                              'temp$ = dlocal.SisCode & TB & dlocal.convfact & TB & dlocal.PrintformV & TB & pad(desc$, 56) & TB & Left$(Format$(GetField(rsLogs!qtyrec)) & Space(13), 13)
                              '15Mar07 TH Used Issueunits instead of printformv
                              temp$ = GetField(rsLogs!SisCode) & TB & GetField(rsLogs!convfact) & TB & GetField(rsLogs!IssueUnits) & TB & pad(desc$, 56) & TB & Left$(Format$(GetField(rsLogs!qtyrec)) & Space(13), 13)
                           Else
                              ' not a receive transaction type so ignore
                              DoIt = False
                           End If
                        End If
                     Case "C"
                        'dlocal.SisCode = GetField(rsLogs!SisCode)
                        'getdrug dlocal, 0, 0, 0        '     "
                        If Left(GetField(rsLogs![DateTime]), 8) < Val(startyyyymmdd$) Or Left(GetField(rsLogs![DateTime]), 8) > Val(endyyyymmdd$) Then
                           DoIt = False
                        End If
                        If Not m_intGroupByProduct Then   '29Apr02 SF do as before
                           temp$ = temp$ & GetField(rsLogs!LogType)              'use CaseNo if there
                           temp$ = temp$ & TB & GetField(rsLogs!SisCode) & TB
                           'If dlocal.storesdescription <> "" Then
                           '   desc$ = dlocal.storesdescription
                           'Else
                           '   desc$ = dlocal.Description
                           'End If
                           'If GetField(rsLogs![storesdescription]) <> "" Then
                              'desc$ = GetField(rsLogs![storesdescription])
                           'Else
                              'desc$ = GetField(rsLogs![Description])
                           'End If      XN 9Jun15 98073 replaced with ProductDescription
                                                   desc$ = GetField(rsLogs![ProductDescription])
                           plingparse desc$, "!"
                           If Len(Trim$(desc$)) < 30 Then desc$ = desc$ & Space$(10)
                           temp$ = temp$ & desc$ & TB
                           '''If GetField(rsLogs![kind]) = "D" Then MsgBox "yar"
                           strDate = Left(GetField(rsLogs![DateTime]), 8)
                           strDate = Mid$(strDate, 7, 2) & Mid$(strDate, 5, 2) & Mid$(strDate, 1, 4)
                           parsedate strDate, tmp$, "ddmmmyyyy", valid
                           temp$ = temp$ & Iff(valid, tmp$, strDate) & " " & Mid$(GetField(rsLogs!DateTime), 9, 2) & ":" & Mid$(GetField(rsLogs!DateTime), 11, 2) & TB
                           If Trim$(LCase(GetField(rsLogs!LogType))) = "trans" Then
                              temp$ = temp$ & Trim$(GetField(rsLogs!Qty)) & " " & Trim$(GetField(rsLogs!IssueUnits)) & TB  '14Oct97 CKJ corrected display
                           Else
                              temp$ = temp$ & Trim$(GetField(rsLogs!Qty)) & " * " & Trim$(GetField(rsLogs!convfact)) & " " & Trim$(GetField(rsLogs!IssueUnits)) & TB '14Oct97 CKJ corrected display
                           End If
                           'temp$ = temp$ & "(" & Trim$(GetField(rsLogs!convfact)) & ")" & TB
                           temp$ = temp$ & GetField(rsLogs!dispid) & TB
                           temp$ = temp$ & HidePrice(Trim$(GetField(rsLogs!cost)), False) & TB '27May04 TH Added HidePrice and replace the surrounding code
                           temp$ = temp$ & GetField(rsLogs!kind) & TB
                           temp$ = temp$ & GetField(rsLogs!site) & TB
                           temp$ = temp$ & Format$(GetField(rsLogs!stocklvl)) & TB
                           temp$ = temp$ & Left$(Trim$(GetField(rsLogs!terminal)) & Space$(12), 12) & TB  '25Aug98 CFY
                           '22Jul05 TH Removed block below as this is not really relevant for Combined orders (#81584)
                           'If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "PromptCustOrdNo", 0)) Or (UCase$(Trim$(TxtD(dispdata$ & "\winord.ini", "PickingTicket", "N", "TranslogEntry", 0))) = "PICKTICKNO") Then
                           '   temp$ = temp$ & Format$(GetField(rsLogs!custordno)) & TB                                            '    "
                           'End If
                           
                        Else
                           'desc$ = dlocal.Description  XN 9Jun15 98073 replaced with ProductDescription
                           'desc$ = GetField(rsLogs![storesdescription])
                           'If Trim$(desc$) = "" Then desc$ = GetField(rsLogs![Description])
                                                   desc$ = GetField(rsLogs![ProductDescription])
                           plingparse desc$, "!"
                           'temp$ = dlocal.SisCode & TB & dlocal.convfact & TB & dlocal.PrintformV & TB & pad(desc$, 56) & TB & Left$(Format$(GetField(rsLogs!Qty)) & Space(13), 13)
                           temp$ = GetField(rsLogs![SisCode]) & TB & GetField(rsLogs![convfact]) & TB & GetField(rsLogs![IssueUnits]) & TB & pad(desc$, 56) & TB & Left$(Format$(GetField(rsLogs!Qty)) & Space(13), 13)
                        End If
                  End Select

                  If DoIt Then
                     If Not m_intGroupByProduct Then
                        'Print #vchan, Format$(RecNo&, "00000"); TB; temp$; crlf;
                        'Print #vchan, temp$; crlf;
                        'Select Case logtype$
                           'Case "T": Print #vchan, Format$(RtrimGetField(rsLogs!WTranslogID), "00000"); TB; temp$; crlf;
                           'Case "O": Print #vchan, Format$(RtrimGetField(rsLogs!WOrderlogID), "00000"); TB; temp$; crlf;
                           'Case "C": Print #vchan, Format$(RtrimGetField(rsLogs!LogID), "00000"); TB; temp$; crlf;
                        'End Select
                        Print #vchan, temp$; crlf;
                     Else
                        lngLineCount = lngLineCount + 1
                        Print #vchan, temp$;
                     End If
                  End If
               End If
               rsLogs.MoveNext
            Loop
      
            Unload Progress
               
         End If
                 

         Print #vchan, crlf;
         Print #vchan, "Log file:   "; TB; strTable; " Log"; yyyymm$; crlf;
         Print #vchan, "From date: "; TB; strStartDate; " To date: "; strEndDate; crlf;
         Print #vchan, "Search for: "; TB; Iff(Len(tofind$), tofind$, "All entries"); crlf;
         Print #vchan, "Site code: "; TB; Iff(Len(site$), site$, "All sites");
         Close fil
         Close vchan
         
         '20Mar07 TH Changed below a bit
         
         If m_intGroupByProduct Then
            lngTrailerLength = Len(crlf & "Log file:   " & TB & strTable & " Log" & yyyymm$ & crlf & "From date: " & TB & strStartDate & " To date: " & TB & strEndDate & crlf)
            lngTrailerLength = lngTrailerLength + Len("Search for: " & TB)
            lngTrailerLength = lngTrailerLength + Len(Iff(Len(tofind$), tofind$, "All entries"))
            lngTrailerLength = lngTrailerLength + Len(crlf & "Site code: " & TB)
            lngTrailerLength = lngTrailerLength + Len(Iff(Len(site$), site$, "All sites"))
         End If
         
         GetTextFile vfile$, temp$, valid
         Screen.MousePointer = STDCURSOR
         If valid Then
            If m_intGroupByProduct Then
               GroupTextByProduct lngLineCount, lngHeaderLength, lngTrailerLength, LogType$, temp$
            End If
            popmessagecr "Log File Viewer", temp$   'small enough for message box  '26Sep05 TH Moved back from below (inadvertently moved somewhere along the line)
         Else
            If Not m_intGroupByProduct Then
               Hedit 111, vfile$                           'edit plain text file
            Else
               popmessagecr "#" & Logview, "Too much data to display. To group and" & cr & "report on large amounts of data use the EIS"
            End If
         End If
         Kill vfile$
      Else
         ''popmessagecr "", "File " & UCase$(FILE$) & " not found"
      End If
      
      
      askQ$ = UCase$(askQ$)
      
   Loop Until askQ$ = "" Or InStr(askQ$, "X") > 0
   
   k.escd = False

Exit Sub

'UserLogViewer_Err:
'   popmessagecr "Log File Viewer", "Cannot open output destination:" & cr & Str$(Err) & ": " & Error$
'Resume Next

End Sub

Sub GroupTextByProduct(ByVal i_lngLineCount As Long, ByVal i_lngHeaderLength As Long, ByVal i_lngTrailerLength As Long, ByVal i_strLogType As String, io_strText As String)
'29Apr02 SF added to group the given text by product NSV Code.  (enh#1555)
'           If the transaction log then total on issue and return.
'           If the oder log then total on products receieved


Const cNSVLength = 7
Const cQtyLength = 13
Const cSortLineLength = 90

Dim strLines() As String, strCurrent() As String
Dim strHeader As String, strTrailer As String, strText As String, strError As String, strLine As String, strQty As String
Dim lngCount As Long, lngCurrentLinePos As Long
Dim intWriteLine As Integer
Dim sngQty  As Single


   
   On Error GoTo SortLogFile_Err

   
   If i_lngLineCount > 0 Then
         
         ' cut out and store the header and trailer text not included in the sort
         strHeader = Left$(io_strText, i_lngHeaderLength)
         strTrailer = Right$(io_strText, i_lngTrailerLength)
         io_strText = Mid$(io_strText, i_lngHeaderLength + 1, Len(io_strText) - (i_lngHeaderLength + i_lngTrailerLength))
      
         
         ' build up an array so the text can be sorted, missing out the header and trailer lines
         lngCurrentLinePos = 1
         ReDim strLines(i_lngLineCount)
         For lngCount = 1 To i_lngLineCount
            strLines(lngCount) = Mid$(io_strText, lngCurrentLinePos, cSortLineLength)
            lngCurrentLinePos = lngCurrentLinePos + cSortLineLength
         Next
      
      
         ' sort the text on the NSV Code of the product
         shellsort strLines(), UBound(strLines), 1, TB
      
         
         ' group the text by NSV Code
         ReDim strCurrent(5)
         strText = ""
         sngQty = 0
         lngCount = 1
         
         Do
            
            ' decide whether the start of a new group
            If lngCount = UBound(strLines) Then                                                 ' no more lines left
                  intWriteLine = True
               ElseIf Left$(strLines(lngCount), 7) <> Left$(strLines(lngCount + 1), 7) Then     ' end of current group
                  intWriteLine = True
               Else
                  intWriteLine = False
               End If
            
            If intWriteLine Then
                  
                  sngQty = sngQty + Val(Right$(strLines(lngCount), cQtyLength))
      
                  ' build up grouped text
                  ' nsv, pack size, issue units, description, qty
                  deflines strLines(lngCount), strCurrent(), TB, 1, 0
      
                  ' format quantity for display
                  Select Case i_strLogType
                     Case "T":
                        If sngQty Mod Val(strCurrent(2)) = 0 Then
                              ' in packs
                              strQty = Format$(sngQty / Val(strCurrent(2))) & " x " & Trim$(strCurrent(2)) & " " & Trim$(strCurrent(3))
                           Else
                              ' in issue units
                              strQty = Format$(sngQty) & " " & Trim$(strCurrent(3))
                           End If
                     
                     Case "O":
                        If sngQty <> Int(sngQty) = 0 Then
                              ' in packs
                              strQty = Format$(sngQty) & " x " & Trim$(strCurrent(2)) & " " & Trim$(strCurrent(3))
                           Else
                              ' in issue units
                              strQty = Format$(CInt(sngQty * Val(strCurrent(2))) & " " & Trim$(strCurrent(3)))
                           End If
                  End Select
      
      
                  ' nsv, qty, description
                  strLine = strCurrent(1) & TB & strQty & TB & strCurrent(4) & crlf
                  strText = strText & strLine
                  
                  ' setup the next group
                  sngQty = 0
               Else
                  ' total on quantity
                  sngQty = sngQty + Val(Right$(strLines(lngCount), cQtyLength))
               End If
            
            lngCount = lngCount + 1
         Loop While lngCount <= UBound(strLines)
      
         ' return the sorted text with the header and trailer appended
         io_strText = strHeader & strText & strTrailer
         
      End If



SortLogFile_CleanUp:
   On Error GoTo 0
   Exit Sub


SortLogFile_Err:
   strError = Error$
   popmessagecr ".SortLogFile", "Error: " & strError
   Resume SortLogFile_CleanUp
End Sub

Sub NewUserLogViewer()
'------------------------------------------------------------------------------------------------
'                       LOGFILE VIEWER & EDITOR V1.0
'                       ----------------------------

'------------------------------------------------------------------------------------------------
'16Aug12 TH Removed second pass functionality and all calls that altered ste lck time out.
'15Sep12 TH  Fixed combined log search via batch number (TFS 43928)
'05Aug13 TH  Removed format of batch number as this was interpretting exponential
'            and decimal possible numeric stings  (TFS 56051)
'16Sep14 TH  Ensure msgbox only used for correct amount of data, broken by changes to underlying GetTextFile sub (TFS 100039)

Dim Logview As String, vchan%, msg$, yyyymm$, yyyymmdd1$, yyyymmdd2$
Dim valid%, datwas$, DoIt%, numlines%, count%, tmp$, DateFormat$, Increment&
Dim length%, FILE$, fil%, pointer&, recno&, recnum$, temp$, posn%, vfile$
'Dim o As orderlogstruct, T As transaction
Dim dlocal As DrugParameters, desc$, found%, ans$  '11Jun98 ASC
Dim lngLineCount As Long, lngHeaderLength As Long, lngTrailerLength As Long   '29Apr02 SF added (enh#1555)
Dim strMMYYYY As String
Dim strTable As String
Dim strSql As String
'Dim oDataAccess    As clsDataAccess
Dim rsLogs    As ADODB.Recordset
Dim strParams As String
Dim strSiscode As String
Dim strUserID As String
Dim strSite As String
Dim strWard As String
Dim strCaseno As String
Dim strKind As String
Dim strLabeltype As String
Dim strBatchNumber As String
Dim strConsultant As String
Dim strTerminal As String
Dim strReason As String
Dim strOrderNum As String
Dim strInvoiceNum As String
Dim strDispID As String
Dim strSpecialty As String
Dim strSupplier As String

Dim lngDayMth As Long
Dim strDate As String
Dim lngSite As Long
Dim lngEndDayMth As Long
Dim strEndDate As String
Dim startyyyymm$
Dim startyyyymmdd$
Dim endyyyymmdd$
Dim tofind$

Dim endyyyymm$
Dim lngMaxrows
Dim LogType$
Dim strStartDate As String
Dim blnGroupByProduct As Boolean
Static secondpass  As Boolean
Dim strCriteriaSuffix As String
Dim strCriteria As String
Dim strDisplayCriteria As String
Dim strNHNumber As String
Dim strPatientIdentifier As String
Dim strPatientIdentifierFormat As String
Dim strInternalOrderNumber As String   '07Mar14 TH Added

secondpass = False
   'Initialise the criteria
   strParams = ""
   strSiscode = ""
   strDispID = ""
   strSite = ""
   strWard = ""
   strCaseno = ""
   lngDayMth = 0
   
   blnGroupByProduct = frmLogView.chkGroupBy.Value
   
   Logview = "Log File Viewer"                                      'caption for forms
   
   strStartDate = frmLogView.txtDateFrom.text
   strEndDate = frmLogView.txtDateTo.text
   
   If Not k.escd Then
      Storesparsedate strStartDate, strMMYYYY, "mmyyyy", valid
      Storesparsedate strStartDate, startyyyymmdd$, "yyyymmdd", valid
      If valid Then lngDayMth = CLng(startyyyymmdd$)
      Storesparsedate strEndDate, strMMYYYY, "mmyyyy", valid
      Storesparsedate strEndDate, endyyyymmdd$, "yyyymmdd", valid
      If valid Then lngEndDayMth = CLng(endyyyymmdd$)
   End If
        
   If frmLogView.optLogType(1).Value = True Then
      LogType$ = "T"
      strPatientIdentifier = GetNHSNumberDisplayName()
      If TrueFalse(TxtD(dispdata$ & "\winord.ini", "LogViewer", "Y", "DisplayNHValid", 0)) Then
         strPatientIdentifier = Trim$(strPatientIdentifier) & TxtD(dispdata$ & "\winord.ini", "LogViewer", " (Valid)", "NHValidHeader", 0)
      End If
      strPatientIdentifier = Left$(strPatientIdentifier & Space$(18), 18)
      strPatientIdentifierFormat = GetNHSNumberDisplayNameFormat()
      
   ElseIf frmLogView.optLogType(2).Value = True Then
      LogType$ = "O"
   Else
      LogType$ = "C"
   End If
         
   If Not k.escd Then
      Select Case LogType$
         Case "T"
            strTable = "TransLog"
         Case "O"
            strTable = "OrderLog"
         Case "C"
            strTable = "CombinedLogs"
         Case Else
            Exit Sub                                          '<== Error so exit
      End Select

      Screen.MousePointer = HOURGLASS
      MakeLocalFile vfile$
      vchan = FreeFile
      Open vfile$ For Output As #vchan                  'output channel for viewing
      fil = FreeFile
      If Not blnGroupByProduct Then  '29Apr02 SF do as before
          Select Case LogType$
             Case "T":
               If UCase$(Trim$(TxtD(dispdata$ & "\winord.ini", "PickingTicket", "N", "TranslogEntry", 0))) = "PICKTICKNO" Then                                                                                                                                                                                               '16May04 TH Added (enh1549)
                  'Print #vchan, "Case Number"; TB; "NSV code"; TB; "Quantity   "; TB; "Pack  "; TB; "User"; TB; "Date and Time  "; TB; "Cost (" & money(4) & ")"; TB; "Ward    "; TB; "Cons "; TB; "Pat"; TB; "Lbl"; TB; "Site"; TB; "Terminal      "; TB; "Stock Lvl" & TB; "Pick Tic No" & TB;
                  'Print #vchan, "Case Number   "; TB; "NSV code"; TB; "Quantity   "; TB; "Pack  "; TB; "User"; TB; "Date and Time  "; TB; "Cost (" & money(4) & ")"; TB; "Ward    "; TB; "Cons    "; TB; "Pat"; TB; "Lbl"; TB; "Site"; TB; "Terminal      "; TB; "Stock Lvl" & TB; "Pick Tic No" & TB; '26Apr12 TH Added extra room for casenumber '10May12 TH addde extra space for cons as is order number for internal PT's (TFS)
                  Print #vchan, "Case Number    "; TB; strPatientIdentifier; TB; "NSV code"; TB; "Quantity   "; TB; "Pack  "; TB; "User"; TB; "Date and Time  "; TB; "Cost (" & money(4) & ")"; TB; "Ward    "; TB; "Cons    "; TB; "Pat"; TB; "Lbl"; TB; "Site"; TB; "Terminal      "; TB; "Stock Lvl" & TB; "Pick Tic No" & TB; '26Apr12 TH Added extra room for casenumber '10May12 TH addde extra space for cons as is order number for internal PT's (TFS)
               Else
                  'Print #vchan, "Case Number"; TB; "NSV code"; TB; "Quantity   "; TB; "Pack  "; TB; "User"; TB; "Date and Time  "; TB; "Cost (" & money(4) & ")"; TB; "Ward    "; TB; "Cons "; TB; "Pat"; TB; "Lbl"; TB; "Site"; TB; "Terminal      "; TB; "Stock Lvl" & TB;
                  'Print #vchan, "Case Number   "; TB; strPatientIdentifier; TB; "NSV code"; TB; "Quantity   "; TB; "Pack  "; TB; "User"; TB; "Date and Time  "; TB; "Cost (" & money(4) & ")"; TB; "Ward    "; TB; "Cons    "; TB; "Pat"; TB; "Lbl"; TB; "Site"; TB; "Terminal      "; TB; "Stock Lvl" & TB; '26Apr12 TH Added extra room for casenumber
                  Print #vchan, "Case Number    "; TB; strPatientIdentifier; TB; "NSV code"; TB; "Quantity   "; TB; "Pack  "; TB; "User"; TB; "Date and Time  "; TB; "Cost (" & money(4) & ")"; TB; "Ward    "; TB; "Cons    "; TB; "Pat"; TB; "Lbl"; TB; "Site"; TB; "Terminal      "; TB; "Stock Lvl" & TB;  '26Apr12 TH Added extra room for casenumber
                  If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "PromptCustOrdNo", 0)) Then                                                                                                                                                                                                                         '21Feb02 TH Added to show CustOrdNo if set to use
                     Print #vchan, "Cust Ord No " & TB;         '    "      this functionality (enh1435)
                  End If
                  
                  
               End If
               If TrueFalse(TxtD(dispdata$ & "\winord.ini", "LogViewer", "Y", "Displaybatchnumber", 0)) Then   '28May08 TH (F0017809)
                  Print #vchan, "Batch Number"; TB;                                            '    "
               End If
               Print #vchan, crlf; crlf;
            Case "O": Print #vchan, "OrdNum    "; TB; "NSV code"; TB; "Date and Time Ord  "; TB; "Quantity Ord"; TB; "Date and Time Rec  "; TB; "Quantity Rec"; TB; "User"; TB; "Cost (" & money(4) & ")"; TB; "Type"; TB; "Supplier"; TB; "Site"; TB; "Other            "; TB; "Stock Lvl"; TB; "Description"; TB; crlf; crlf;   '25Jan02 TH Added Stocklvl to display (#53214) '20Jun12 TH Increased padding round "other" (TFS 36727)
            Case "C": Print #vchan, "Log   "; TB; "NSV code"; TB; "Description" & Space$(50); TB; "Date and Time  "; TB; "Quantity     "; TB; "User"; TB; "Cost (" & money(4) & ")"; TB; "Type  "; TB; "Site "; TB; ; "Stock Lvl"; TB; "Terminal      "; TB; crlf; crlf;  '25Jan02 TH Added Stocklvl to display (#53214)
         End Select
      Else
         Select Case LogType$
            Case "T":
               temp$ = Space$(10) & TB & Space$(15) & TB & Space$(20) & crlf
               temp$ = temp$ & "ISSUE/RETURN GROUPED BY PRODUCT" & crlf & crlf & crlf
               temp$ = temp$ & "NSV Code " & TB & "Quantity " & TB & "Product Description " & crlf & crlf
            Case "O"
               temp$ = Space$(10) & TB & Space$(15) & TB & Space$(20) & crlf
               temp$ = temp$ & "RECEIVED GROUPED BY PRODUCT" & crlf & crlf & crlf
               temp$ = temp$ & "NSV Code " & TB & "Quantity " & TB & "Product Description " & crlf & crlf
         End Select
         Print #vchan, temp$;
         lngHeaderLength = Len(temp$)
         lngLineCount = 0
      End If

      strSiscode = frmLogView.txtDrug.text
      strUserID = frmLogView.txtUser.text
      strTerminal = frmLogView.txtTerminal.text
      strSite = frmLogView.txtSite.text
      
      replace strSiscode, "'", "", 0
      replace strSiscode, ";", "", 0
      replace strUserID, "'", "", 0
      replace strUserID, ";", "", 0
      replace strTerminal, "'", "", 0
      replace strTerminal, ";", "", 0
      replace strSite, "'", "", 0
      replace strSite, ";", "", 0
               
      If Trim$(strSite) <> "" And Val(strSite) > 0 Then
         strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, CLng(strSite))
         lngSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
      Else
         lngSite = 0
      End If
         
      lngMaxrows = Val(TxtD(dispdata$ & "\siteinfo.ini", "LogViewer", "2000", "Maxrows", 0))
      strDisplayCriteria = ""
      
      Select Case LogType$
         Case "T"
            strWard = frmLogView.txtWard.text
            strCaseno = frmLogView.txtCaseNo.text
            strKind = frmLogView.txtTransKind.text
            strLabeltype = frmLogView.txtLabeltype.text
            strSpecialty = frmLogView.txtSpecialty.text
            strBatchNumber = frmLogView.txtTransBatchNumber.text
            strConsultant = frmLogView.txtConsultant.text
            strNHNumber = frmLogView.txtNHNumber.text '10May12 TH
            strInternalOrderNumber = frmLogView.txtInternalOrderNumber.text '07Mar14 TH TFS 81586
            replace strWard, "'", "", 0
            replace strCaseno, "'", "", 0
            replace strKind, "'", "", 0
            replace strLabeltype, "'", "", 0
            replace strBatchNumber, "'", "", 0
            replace strConsultant, "'", "", 0
            replace strNHNumber, "'", "", 0
            replace strWard, ";", "", 0
            replace strCaseno, ";", "", 0
            replace strKind, ";", "", 0
            replace strLabeltype, ";", "", 0
            replace strBatchNumber, ";", "", 0
            replace strConsultant, ";", "", 0
            replace strNHNumber, ";", "", 0
            replace strNHNumber, " ", "", 0 '14May Parse out display spaces
            replace strInternalOrderNumber, ";", "", 0 '07Mar14 TH TFS 81586
            replace strInternalOrderNumber, "'", "", 0 ' "
            '24Apr08 TH Build new search string to use different IO layer if possible
            strCriteria = ""
            If lngSite > 0 Then strCriteria = strCriteria & " and Wtranslog.siteID = " & Format$(lngSite)
            If Trim$(strSiscode) <> "" Then strCriteria = strCriteria & " and Wtranslog.siscode = '" & strSiscode & "'": strDisplayCriteria = strDisplayCriteria & "NSVCode = " & strSiscode & ","
            If Trim$(strCaseno) <> "" Then strCriteria = strCriteria & " and Wtranslog.caseno = '" & strCaseno & "'": strDisplayCriteria = strDisplayCriteria & "Caseno = " & strCaseno & ","
            If Trim$(strUserID) <> "" Then strCriteria = strCriteria & " and Wtranslog.DispID = '" & strUserID & "'": strDisplayCriteria = strDisplayCriteria & "UserID = " & strUserID & ","
            If Trim$(strWard) <> "" Then strCriteria = strCriteria & " and Wtranslog.Ward = '" & strWard & "'": strDisplayCriteria = strDisplayCriteria & "Ward = " & strWard & ","
            If Trim$(strConsultant) <> "" Then strCriteria = strCriteria & " and Wtranslog.Consultant = '" & strConsultant & "'": strDisplayCriteria = strDisplayCriteria & "Consultant = " & strConsultant & ","
            If Trim$(strSpecialty) <> "" Then strCriteria = strCriteria & " and Wtranslog.Specialty = '" & strSpecialty & "'": strDisplayCriteria = strDisplayCriteria & "Specialty = " & strSpecialty & ","
            If Trim$(strBatchNumber) <> "" Then strCriteria = strCriteria & " and Wtranslog.Batchnum = '" & strBatchNumber & "'": strDisplayCriteria = strDisplayCriteria & "BatchNumber = " & strBatchNumber & ","
            If Trim$(strKind) <> "" Then strCriteria = strCriteria & " and Wtranslog.kind = '" & strKind & "'": strDisplayCriteria = strDisplayCriteria & "Kind = " & strKind & ","
            If Trim$(strLabeltype) <> "" Then strCriteria = strCriteria & " and Wtranslog.LabelType = '" & strLabeltype & "'": strDisplayCriteria = strDisplayCriteria & "Labeltype = " & strLabeltype & ","
            If Trim$(strTerminal) <> "" Then strCriteria = strCriteria & " and Wtranslog.Terminal = '" & strTerminal & "'": strDisplayCriteria = strDisplayCriteria & "Terminal = " & strTerminal & ","
            If Trim$(strNHNumber) <> "" Then strCriteria = strCriteria & " and Wtranslog.NHNumber = '" & strNHNumber & "'": strDisplayCriteria = strDisplayCriteria & Trim$(frmLogView.lblNHNumber.Caption) & "  = " & strNHNumber & ","  '10May12 TH Added
            If Trim$(strInternalOrderNumber) <> "" Then strCriteria = strCriteria & " and Wtranslog.InternalOrderNumber = '" & strInternalOrderNumber & "'": strDisplayCriteria = strDisplayCriteria & "Internal Order Number = " & strInternalOrderNumber & ","   '07Mar14 TH Added TFS 81586
            
            If Right$(strDisplayCriteria, 1) = "," Then strDisplayCriteria = Left$(strDisplayCriteria, Len(strDisplayCriteria) - 1)
            
            strParams = gTransport.CreateInputParameterXML("criteria", trnDataTypeVarChar, 1024, "where date >=  " & Format$(lngDayMth) & " and date < = " & Format$(lngEndDayMth) & strCriteria)

         Case "O"
            strBatchNumber = frmLogView.txtBatchNumber.text
            strReason = frmLogView.txtReason.text
            strOrderNum = frmLogView.txtOrderNumber
            strSupplier = frmLogView.txtSupplier.text
            strKind = frmLogView.txtKind.text
            strInvoiceNum = Trim$(frmLogView.txtInvoiceNumber)
            
            replace strBatchNumber, "'", "", 0
            replace strReason, "'", "", 0
            replace strOrderNum, "'", "", 0
            replace strSupplier, "'", "", 0
            replace strKind, "'", "", 0
            replace strInvoiceNum, "'", "", 0
            replace strBatchNumber, ";", "", 0
            replace strReason, ";", "", 0
            replace strOrderNum, ";", "", 0
            replace strSupplier, ";", "", 0
            replace strKind, ";", "", 0
            replace strInvoiceNum, ";", "", 0
            
            strCriteria = ""
            strCriteria = "where (((([DateOrd] >= " & Format$(lngDayMth) & ")and kind <> 'Q')   and (([DateOrd] <= " & Format$(lngEndDayMth) & ")and kind <> 'Q')) or (([DateRec] >= " & Format$(lngDayMth) & ")  and ([DateRec] <= " & Format$(lngEndDayMth) & ")))"
            If lngSite > 0 Then strCriteria = strCriteria & " and WOrderlog.siteID = " & Format$(lngSite)
            If Trim$(strSiscode) <> "" Then strCriteria = strCriteria & " and WOrderlog.siscode = '" & strSiscode & "'": strDisplayCriteria = strDisplayCriteria & "NSVCode = " & strSiscode & ","
            If Trim$(strReason) <> "" Then strCriteria = strCriteria & " and WOrderlog.Reasoncode = '" & strReason & "'": strDisplayCriteria = strDisplayCriteria & "Reason = " & strReason & ","
            If Trim$(strUserID) <> "" Then strCriteria = strCriteria & " and WOrderlog.DispID = '" & strUserID & "'": strDisplayCriteria = strDisplayCriteria & "UserID = " & strUserID & ","
            If Trim$(strSupplier) <> "" Then strCriteria = strCriteria & " and WOrderlog.supcode = '" & strSupplier & "'": strDisplayCriteria = strDisplayCriteria & "Supplier = " & strSupplier & ","
            If Trim$(strInvoiceNum) <> "" Then strCriteria = strCriteria & " and WOrderlog.InvNum = '" & strInvoiceNum & "'": strDisplayCriteria = strDisplayCriteria & "InvoiceNum = " & strInvoiceNum & ","
            If Trim$(strBatchNumber) <> "" Then strCriteria = strCriteria & " and WOrderlog.Batchnum = '" & strBatchNumber & "'": strDisplayCriteria = strDisplayCriteria & "BatchNumber = " & strBatchNumber & ","
            If Trim$(strKind) <> "" Then strCriteria = strCriteria & " and WOrderlog.kind = '" & strKind & "'": strDisplayCriteria = strDisplayCriteria & "Kind = " & strKind & ","
            If Trim$(strOrderNum) <> "" Then strCriteria = strCriteria & " and WOrderlog.OrderNum = '" & strOrderNum & "'": strDisplayCriteria = strDisplayCriteria & "OrderNum = " & strOrderNum & ","
            If Trim$(strTerminal) <> "" Then strCriteria = strCriteria & " and WOrderlog.Terminal = '" & strTerminal & "'": strDisplayCriteria = strDisplayCriteria & "Terminal = " & strTerminal & ","
            
            If Right$(strDisplayCriteria, 1) = "," Then strDisplayCriteria = Left$(strDisplayCriteria, Len(strDisplayCriteria) - 1)

            strParams = gTransport.CreateInputParameterXML("criteria", trnDataTypeVarChar, 1024, strCriteria)
         
         Case "C"
               strBatchNumber = frmLogView.txtCombinedBatchNumber.text
               
               replace strBatchNumber, "'", "", 0
               replace strBatchNumber, ";", "", 0
               
               'Translog criteria first
               strCriteria = ""
               strCriteria = "where date >=  " & Format$(lngDayMth) & " and date < = " & Format$(lngEndDayMth)
               If lngSite > 0 Then strCriteria = strCriteria & " and wtranslog.siteID = " & Format$(lngSite)
               If Trim$(strSiscode) <> "" Then strCriteria = strCriteria & " and wtranslog.siscode = '" & strSiscode & "'": strDisplayCriteria = strDisplayCriteria & "NSVCode = " & strSiscode & ","
               If Trim$(strUserID) <> "" Then strCriteria = strCriteria & " and wtranslog.DispID = '" & strUserID & "'": strDisplayCriteria = strDisplayCriteria & "UserID = " & strUserID & ","
               If Trim$(strBatchNumber) <> "" Then strCriteria = strCriteria & " and wtranslog.Batchnum = '" & strBatchNumber & "'": strDisplayCriteria = strDisplayCriteria & "BatchNumber = " & strBatchNumber & ","
               strParams = gTransport.CreateInputParameterXML("Transcriteria", trnDataTypeVarChar, 1024, strCriteria)
               If Right$(strDisplayCriteria, 1) = "," Then strDisplayCriteria = Left$(strDisplayCriteria, Len(strDisplayCriteria) - 1)
               'Orderlog criteria next
               strCriteria = "where (" '15Sep12 TH Added (TFS 43928)
               'strCriteria = "where (((([DateOrd] >= " & Format$(lngDayMth) & ")and kind <> 'Q')   and (([DateOrd] <= " & Format$(lngEndDayMth) & ")and kind <> 'Q')) or (([DateRec] >= " & Format$(lngDayMth) & ")  and ([DateRec] <= " & Format$(lngEndDayMth) & ")))"
               strCriteria = strCriteria & "(((([DateOrd] >= " & Format$(lngDayMth) & ")and kind <> 'Q')   and (([DateOrd] <= " & Format$(lngEndDayMth) & ")and kind <> 'Q')) or (([DateRec] >= " & Format$(lngDayMth) & ")  and ([DateRec] <= " & Format$(lngEndDayMth) & ")))" '15Sep12 TH Added (TFS 43928)
               If lngSite > 0 Then strCriteria = strCriteria & " and worderlog.siteID = " & Format$(lngSite)
               If Trim$(strSiscode) <> "" Then strCriteria = strCriteria & " and worderlog.siscode = '" & strSiscode & "'"
               If Trim$(strUserID) <> "" Then strCriteria = strCriteria & " and worderlog.DispID = '" & strUserID & "'"
               'If Trim$(strBatchNumber) <> "" Then strCriteria = strCriteria & " and worderlog.[InvNum] = '" & strBatchNumber & "' and Kind ='R')"
               If Trim$(strBatchNumber) <> "" Then strCriteria = strCriteria & " and worderlog.InvNum = '" & strBatchNumber & "' and Kind ='R'"
               strCriteria = strCriteria & ")" '15Sep12 TH Added (TFS 43928)
               strParams = strParams & gTransport.CreateInputParameterXML("Ordcriteria", trnDataTypeVarChar, 1024, strCriteria)              '12Jun08 TH Added - how was this missing !
               If Right$(strDisplayCriteria, 1) = "," Then strDisplayCriteria = Left$(strDisplayCriteria, Len(strDisplayCriteria) - 1)       '  "
               
      End Select
      
      strParams = strParams & gTransport.CreateInputParameterXML("MaxRows", trnDataTypeint, 4, lngMaxrows)
      
      
retry:
      On Error GoTo timeout
      If Not secondpass Then
'16Aug12 CKJ Deprecated         gTransport.ADOSetConnectionTimeOut 5
      Else
'16Aug12 CKJ Deprecated         gTransport.ADOSetConnectionTimeOut (TxtD(dispdata$ & "\siteinfo.ini", "Connection", "30", "ConnectionTimeout", found))

      End If
      'strCriteria
      Set rsLogs = gTransport.ExecuteSelectSP(g_SessionID, "pW" & strTable & "byCriteriaNEW", strParams)
      
      On Error GoTo 0
'16Aug12 CKJ Deprecated      gTransport.ADOSetConnectionTimeOut (TxtD(dispdata$ & "\siteinfo.ini", "Connection", "30", "ConnectionTimeout", found))
      If Not rsLogs.EOF Then
         pointer& = rsLogs.RecordCount
         Screen.MousePointer = STDCURSOR
         If pointer& = lngMaxrows Then popmessagecr "Log Viewer", "Criteria returns " & Format$(lngMaxrows) & " or more records. Only the first " & Format$(lngMaxrows) & " will be used."
         Screen.MousePointer = HOURGLASS
         rsLogs.MoveFirst
         Do While Not rsLogs.EOF
            DoIt = True
            Progress.lblInfo = "Searching Logs from " & startyyyymm$ & " to " & startyyyymm$ & crlf & "For " & Iff(Len(tofind$), "'" & tofind$ & "'", "all entries") & crlf & "Site code: " & Iff(Len(strSite), strSite, "all sites") & crlf & "Number of entries:" & Str$(pointer&)
            Increment& = pointer& \ 100
            
            If Increment& < 1 Then Increment& = 1

            
            If (recno& Mod Increment&) = 0 Then Progress.Percent = 100 * (pointer& - recno&) \ pointer&
            
            recnum$ = Trim(Str$(recno&))
            
            temp$ = ""
               
            Select Case LogType$
               Case "T"
                  If GetField(rsLogs![date]) < Val(startyyyymmdd$) Or GetField(rsLogs![date]) > Val(endyyyymmdd$) Then
                     DoIt = False
                  End If
                  If Not blnGroupByProduct Then   '29Apr02 SF do as before
                     If Len(Trim$(GetField(rsLogs!caseno))) Then                 '16Feb98 CKJ
                        temp$ = temp$ & GetField(rsLogs!caseno)              'use CaseNo if there
                     ElseIf Len(Trim$(GetField(rsLogs!patid))) Then           'else use [RecNo]
                        temp$ = temp$ & "[" & GetField(rsLogs!patid) & "]"
                     End If
                     temp$ = temp$ & TB & Trim$(Format$(GetField(rsLogs!NHNumber), strPatientIdentifierFormat))
                     If TrueFalse(TxtD(dispdata$ & "\winord.ini", "LogViewer", "Y", "DisplayNHValid", 0)) Then
                        If Not IsNull(rsLogs!NHNumberValid) Then
                           If GetField(rsLogs!NHNumberValid) Then
                              temp$ = temp$ & TxtD(dispdata$ & "\winord.ini", "LogViewer", " (Y)", "NHValidLine", 0)
                           Else
                              temp$ = temp$ & TxtD(dispdata$ & "\winord.ini", "LogViewer", " (N)", "NHInValidLine", 0)
                           End If
                        End If
                     End If
                     temp$ = temp$ & TB & GetField(rsLogs!SisCode) & TB
                     temp$ = temp$ & Trim$(GetField(rsLogs!Qty)) & " " & Trim$(GetField(rsLogs!IssueUnits)) & TB  '14Oct97 CKJ corrected display
                     temp$ = temp$ & Trim$(GetField(rsLogs!convfact)) & TB   '25Mar15 XN 114702 Don't need brackets around value (when opened in excel goes -ve) temp$ = temp$ & "(" & Trim$(GetField(rsLogs!convfact)) & ")" & TB
                     temp$ = temp$ & GetField(rsLogs!dispid) & TB
                     strDate = CStr(GetField(rsLogs![date]))
                     strDate = Mid$(strDate, 7, 2) & Mid$(strDate, 5, 2) & Mid$(strDate, 1, 4)
                     parsedate strDate, tmp$, "ddmmmyyyy", valid
                     temp$ = temp$ & Iff(valid, tmp$, strDate) & " " & Left$(GetField(rsLogs!Time), 2) & ":" & Mid$(GetField(rsLogs!Time), 3, 2) & TB
                     temp$ = temp$ & HidePrice(Trim$(GetField(rsLogs!cost)), False) & TB '27May04 TH Added HidePrice and replace the surrounding code
                     temp$ = temp$ & GetField(rsLogs!ward) & TB
                     If Val(GetField(rsLogs!InternalOrderNumber)) > 0 Then                '07Mar14 TH Added (TFS 81586)
                        temp$ = temp$ & GetField(rsLogs!InternalOrderNumber) & TB         '  "
                     Else                                                                 '  "
                        temp$ = temp$ & GetField(rsLogs!consultant) & TB
                     End If                                                               '  "
                     temp$ = temp$ & GetField(rsLogs!kind) & TB
                     temp$ = temp$ & GetField(rsLogs!labeltype) & TB
                     temp$ = temp$ & GetField(rsLogs!site) & TB
                     temp$ = temp$ & Left$(Trim$(GetField(rsLogs!terminal)) & Space$(12), 12) & TB  '25Aug98 CFY
                     temp$ = temp$ & Format$(GetField(rsLogs!stocklvl)) & TB  '22Feb99 CFY Added
                     If TrueFalse(TxtD(dispdata$ & "\winord.ini", "LogViewer", "Y", "Displaybatchnumber", 0)) Then '28May08 TH (F0017809)
                        'temp$ = temp$ & Format$(GetField(rsLogs!BatchNum)) & TB                                            '    "
                        'temp$ = temp$ & Format$(RtrimGetField(rsLogs!BatchNum)) & TB  '10Jun08 TH (F0025759) added trim                                          '    "
                        temp$ = temp$ & RtrimGetField(rsLogs!BatchNum) & TB  '05Aug13 TH  (TFS 56051) Removed format as this was interpretting exponential and decimal possible numeric stings
                     End If
                     If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "PromptCustOrdNo", 0)) Or (UCase$(Trim$(TxtD(dispdata$ & "\winord.ini", "PickingTicket", "N", "TranslogEntry", 0))) = "PICKTICKNO") Then
                        temp$ = temp$ & Format$(GetField(rsLogs!custordno)) & TB                                            '    "
                     End If                                                                                  '    "
                     desc$ = GetField(rsLogs!ProductDescription)   ' GetField(rsLogs!Description)  XN 9Jun15 98073        '11Jun98 ASC/CKJ
                     plingparse desc$, "!"            '    "
                     temp$ = temp$ & desc$            '    "
                  Else
                     'desc$ = GetField(rsLogs!storesdescription)        XN 9Jun15 98073 replaced with ProductDescription
                     'If Trim$(desc$) = "" Then desc$ = GetField(rsLogs!Description)
                                         desc$ = GetField(rsLogs!ProductDescription)
                     plingparse desc$, "!"
                     temp$ = GetField(rsLogs!SisCode) & TB & GetField(rsLogs!convfact) & TB & GetField(rsLogs!IssueUnits) & TB & pad(desc$, 56) & TB & Left$(Format$(GetField(rsLogs!Qty)) & Space(13), 13)
                  End If
                        
               Case "O"
                  If Not blnGroupByProduct Then   '29Apr02 SF do as before
                     temp$ = temp$ & RtrimGetField(rsLogs!ordernum) & TB
                     temp$ = temp$ & RtrimGetField(rsLogs!SisCode) & TB
                     parsedate RtrimGetField(rsLogs!dateord), tmp$, "ddmmmyyyy", valid
                     strDate = CStr(RtrimGetField(rsLogs![dateord]))
                     strDate = Mid$(strDate, 7, 2) & Mid$(strDate, 5, 2) & Mid$(strDate, 1, 4)
                     parsedate strDate, tmp$, "ddmmmyyyy", valid
                     temp$ = temp$ & Iff(valid, tmp$, strDate)
                     If Trim$(RtrimGetField(rsLogs!Timeord)) <> "" Then                                                                                   '     "
                        temp$ = temp$ & " " & Left$(RtrimGetField(rsLogs!Timeord), 2) & ":" & Mid$(RtrimGetField(rsLogs!Timeord), 3, 2) & TB '     "
                     Else                                                                                                          '     "
                        temp$ = temp$ & "      " & TB                                                '     "
                     End If
                     temp$ = temp$ & Trim$(GetField(rsLogs!qtyord))
                     temp$ = temp$ & TB     ' Temporary
                     strDate = CStr(RtrimGetField(rsLogs![daterec]))
                     strDate = Mid$(strDate, 7, 2) & Mid$(strDate, 5, 2) & Mid$(strDate, 1, 4)
                     parsedate strDate, tmp$, "ddmmmyyyy", valid
                     temp$ = temp$ & Iff(valid, tmp$, strDate)
                     If Trim$(GetField(rsLogs!Timerec)) <> "" Then                                                                                    '     "
                        temp$ = temp$ & " " & Left$(GetField(rsLogs!Timerec), 2) & ":" & Mid$(GetField(rsLogs!Timerec), 3, 2) & TB  '     "
                     Else                                                                                                           '     "
                        temp$ = temp$ & "      " & TB                                                 '     "
                     End If
                     temp$ = temp$ & Trim$(GetField(rsLogs!qtyrec))
                     temp$ = temp$ & TB     ' Temporary
                     temp$ = temp$ & GetField(rsLogs!dispid) & TB
                     temp$ = temp$ & HidePrice(Trim$(GetField(rsLogs!cost)), False) & TB '27May04 TH Added HidePrice and replace the surrounding code
                     temp$ = temp$ & GetField(rsLogs!kind) & TB
                     temp$ = temp$ & GetField(rsLogs!supcode) & TB
                     temp$ = temp$ & GetField(rsLogs!site) & TB
                     temp$ = temp$ & GetField(rsLogs!invnum) & TB
                     If Val(GetField(rsLogs!convfact)) > 0 Then                                            '25Jan02 TH Added Stocklvl to display (#53214)
                        temp$ = temp$ & Format$(StrDecPl$(Format$(dp!(Val(GetField(rsLogs!stocklvl)) / Val(GetField(rsLogs!convfact)))), 2)) & TB '24Nov05 TH TOMERGE
                     Else                                                                     '   "
                        temp$ = temp$ & "     " & TB                                          '   "
                     End If
                     'desc$ = GetField(rsLogs!storesdescription)        XN 9Jun15 98073 replaced with ProductDescription
                     'If Trim$(desc$) = "" Then desc$ = GetField(rsLogs!Description)
                                         desc$ = GetField(rsLogs!ProductDescription)
                     plingparse desc$, "!"
                     temp$ = temp$ & desc$
                  Else
                     If GetField(rsLogs!kind) = "R" Then
                        desc$ = GetField(rsLogs!ProductDescription)     ' GetField(rsLogs!Description)  XN 9Jun15 98073
                        plingparse desc$, "!"
                        temp$ = GetField(rsLogs!SisCode) & TB & Left$(GetField(rsLogs!convfact) & Space$(5), 5) & TB & Left$(GetField(rsLogs!IssueUnits) & Space$(5), 5) & TB & pad(desc$, 56) & TB & Left$(Format$(GetField(rsLogs!qtyrec)) & Space(13), 13)
                     Else
                        ' not a receive transaction type so ignore
                        DoIt = False
                     End If
                  End If
               Case "C"
                  If (Left(GetField(rsLogs![DateTime]), 8) < Val(startyyyymmdd$) Or Left(GetField(rsLogs![DateTime]), 8) > Val(endyyyymmdd$)) And (GetField(rsLogs![kind]) <> "Q") Then
                     DoIt = False
                  End If
                  If Not blnGroupByProduct Then   '29Apr02 SF do as before
                     temp$ = temp$ & GetField(rsLogs!LogType)              'use CaseNo if there
                     temp$ = temp$ & TB & GetField(rsLogs!SisCode) & TB
                     'If GetField(rsLogs![storesdescription]) <> "" Then        XN 9Jun15 98073 replaced with ProductDescription
                     'If Trim$(GetField(rsLogs![storesdescription])) <> "" Then '19May08 TH Added trim (F)
                        'desc$ = GetField(rsLogs![storesdescription])
                     'Else
                        desc$ = GetField(rsLogs![ProductDescription])
                     'End If
                     plingparse desc$, "!"
                     If Len(Trim$(desc$)) < 30 Then desc$ = desc$ & Space$(10)
                     temp$ = temp$ & desc$ & TB
                     strDate = Left(GetField(rsLogs![DateTime]), 8)
                     strDate = Mid$(strDate, 7, 2) & Mid$(strDate, 5, 2) & Mid$(strDate, 1, 4)
                     parsedate strDate, tmp$, "ddmmmyyyy", valid
                     temp$ = temp$ & Iff(valid, tmp$, strDate) & " " & Mid$(GetField(rsLogs!DateTime), 9, 2) & ":" & Mid$(GetField(rsLogs!DateTime), 11, 2) & TB
                     If Trim$(LCase(GetField(rsLogs!LogType))) = "trans" Then
                        temp$ = temp$ & Trim$(GetField(rsLogs!Qty)) & " " & Trim$(GetField(rsLogs!IssueUnits)) & TB
                     Else
                        temp$ = temp$ & Trim$(GetField(rsLogs!Qty)) & " * " & Trim$(GetField(rsLogs!convfact)) & " " & Trim$(GetField(rsLogs!IssueUnits)) & TB '14Oct97 CKJ corrected display
                     End If
                     temp$ = temp$ & GetField(rsLogs!dispid) & TB
                     temp$ = temp$ & HidePrice(Trim$(GetField(rsLogs!cost)), False) & TB '27May04 TH Added HidePrice and replace the surrounding code
                     temp$ = temp$ & GetField(rsLogs!kind) & TB
                     temp$ = temp$ & GetField(rsLogs!site) & TB
                     temp$ = temp$ & Format$(GetField(rsLogs!stocklvl)) & TB
                     temp$ = temp$ & Left$(Trim$(GetField(rsLogs!terminal)) & Space$(12), 12) & TB  '25Aug98 CFY
                  Else
                     'desc$ = GetField(rsLogs![storesdescription])      XN 9Jun15 98073 replaced with ProductDescription
                     'If Trim$(desc$) = "" Then desc$ = GetField(rsLogs![Description])
                         desc$ = GetField(rsLogs![ProductDescription])
                     plingparse desc$, "!"
                     temp$ = GetField(rsLogs![SisCode]) & TB & GetField(rsLogs![convfact]) & TB & GetField(rsLogs![IssueUnits]) & TB & pad(desc$, 56) & TB & Left$(Format$(GetField(rsLogs!Qty)) & Space(13), 13)
                  End If
            End Select

            If DoIt Then
               If Not blnGroupByProduct Then
                  Print #vchan, temp$; crlf;
               Else
                  lngLineCount = lngLineCount + 1
                  Print #vchan, temp$;
               End If
            End If
            rsLogs.MoveNext
         Loop
   
            
      End If
      rsLogs.Close
      Set rsLogs = Nothing

      Print #vchan, crlf;
      Print #vchan, "Log file:   "; TB; strTable; " Log"; yyyymm$; crlf;
      Print #vchan, "From date: "; TB; strStartDate; " to date: "; strEndDate; crlf;
      Print #vchan, "Search for: "; TB; Iff(Len(strDisplayCriteria), strDisplayCriteria, "All entries"); crlf;
      Print #vchan, "Site code: "; TB; Iff(Len(strSite), strSite, "All sites");
      Close fil
      Close vchan
            
      '20Mar07 TH Changed below a bit
      
      If blnGroupByProduct Then
         lngTrailerLength = Len(crlf & "Log file:   " & TB & strTable & " Log" & yyyymm$ & crlf & "From date: " & TB & strStartDate & " to date: " & TB & strEndDate & crlf)
         lngTrailerLength = lngTrailerLength + Len("Search for: " & TB)
         lngTrailerLength = lngTrailerLength + Len(Iff(Len(strDisplayCriteria), strDisplayCriteria, "All entries"))
         lngTrailerLength = lngTrailerLength + Len(crlf & "Site code: " & TB)
         lngTrailerLength = lngTrailerLength + Len(Iff(Len(strSite), strSite, "All sites"))
      End If
         
      GetTextFile vfile$, temp$, valid
      Screen.MousePointer = STDCURSOR
      'If valid Then
      If Len(temp$) < 32768 And valid Then    '16Sep14 TH Ensure msgbox only used for correct amount of data (TFS 100039)
         If blnGroupByProduct Then
            GroupTextByProduct lngLineCount, lngHeaderLength, lngTrailerLength, LogType$, temp$
         End If
         popmessagecr "Log File Viewer", temp$   'small enough for message box  '26Sep05 TH Moved back from below (inadvertently moved somewhere along the line)
      Else
         If Not blnGroupByProduct Then
            Hedit 111, vfile$                           'edit plain text file
         Else
            popmessagecr "#" & Logview, "Too much data to display. To group and" & cr & "report on large amounts of data use the EIS"
         End If
      End If
      Kill vfile$
   Else
      ''popmessagecr "", "File " & UCase$(FILE$) & " not found"
   End If
      
      
k.escd = False

Exit Sub

'UserLogViewer_Err:
'   popmessagecr "Log File Viewer", "Cannot open output destination:" & cr & Str$(Err) & ": " & Error$
'Resume Next

timeout:

   On Error Resume Next
   
   rsLogs.Close
   Set rsLogs = Nothing
   
   On Error GoTo 0
   
'If Not secondpass Then
'  secondpass = True
   'On Error GoTo 0
   'Error = 0
   'Err = 0
'   Debug.Print "once round"
'   Resume retry
   
'Else
   Screen.MousePointer = STDCURSOR
   popmessagecr "Log File Viewer", "There is a problem returning all the data requested, try narrowing the criteria used to select data"
'End If
End Sub
