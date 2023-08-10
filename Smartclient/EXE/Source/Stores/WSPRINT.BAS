Attribute VB_Name = "WSPrint"
'DOStoWIN V1.0 (c) ASCribe 1996
'----------------------------------------------------------------------------
'                                  PRILIST
'                           Print ward stocklist
'
'     converted to qb4 from \STOCKL\PRILIST1.BAS 9990  5-02-88 12:39pm
'-----------------------------------------------------------------------------
' Modification history
'----------------------
' 7Apr89 CKJ Conversion to QB4 started
'21Apr89 CKJ Missing catno ==> print now stays in line
'12May89 ASC No of line feeds if no barcode number now decreased by one
'            to make space used by no barcode sime to barcode
'16May89 ASC Lines per page decreased to 24
'24MAY89 ASC If printer error after intialisation then assumed as timeout
'            and resumed.
' 5Jul89 CKJ Printing remains a problem; a fast computer, slow printer &
'            short timeout in the OS causes the device unavailable error
'            during normal use of the program (esp with barcodes). RESUME
'            is of no use since some, part or all of the PRINT may have got
'            through to the printer & there is no way to tell how much has.
'            Therefore, bring on the print spooler ...
' 6Jul89 CKJ Spooler now starts new file for each page
'18Aug89 CKJ endnwwloop now goes to wayout
'11Sep89 CKJ barcodes OK for EAN, now for HORIS ...
'20Sep89 CKJ  - HORIS codes done. Released as                           V4.1
'30Sep89 CKJ antihack added, printcentred, cls on wayout                V4.1
'22Jan90 CKJ new libraries, popup help & so on                          V4.2
'27Jan90 CKJ version box                                                V4.2
'16Mar90 CKJ clear buffer before handling ESC, help page nos changed    V4.2
'22May90 CKJ 50 char titles, page length reduced slightly               V4.21
'            Inputcharcr now used
'19Nov90 ASC Checking on number of chars in code removed to allow       V5.0
'            compatibility with all sites
'13Apr91 CKJ/ASC reduced No. of lines per page for Burnley
'22Jul91 ASC reference to ward removed in some places as not always used
'            for ward stock lists and to tidy screen now 5.1 (pds 7.1)
'            also sites now dimmed using \library\dimname.inc
'11Aug91 CKJ Dimname.BAS changed to Dimname.INC
'15Dec91 CKJ Stockl.inc added
'            Spacing altered to allow for widened fields
'            Barcode now taken from main drug file, when found          V5.3
' 7Feb92 CKJ Renumbered help, altered escape message
'19Aug93 ASC dp now changed to dpp due to reuse by dp!
' 7Mar94 ASC Stockpath removed from share
'20Mar95 CKJ added progsdrv
'24Mar95 CKJ Moved Close
' 5Jun95 CKJ Uses MultiList
'21Jun95 CKJ Added editform
'05Feb96 EAC Add page numbering.
'19Mar96 EAC Make page length a INI file setting
'29Oct97 EAC DisplayStatus: Stop out of memory error by limiting amount of text displayed in LstBox
'26Jan98 EAC PrilistTop: Use ParseDataItems to pickup expansions from RTF file
'05Mar98 ASC getprintpath: New procedure
'            TidyUpReprints: New procedure. Keeps 10 days of reprints on line and kills off other files
'            WSLParse: Ammended to stop trunction of drug descriptions
'            WSspool: Reprintable%, Global ReprintNo% added to allow order picking ticket and del note
'             reprinting.
'18Mar98 CKJ Tidyupreprints: Found error if date includes am/pm -> Type mismatch in datediff
'            Avoid this by keeping the date as a variant type 7, and not casting to string.
'26Mar98 CFY Tidyupreprints: Added error handling to trap potential problems using the Dir$ and FileDateTime functions
'26Mar98 EAC Sarall:
'             - Allow topup value to be changed
'             - Correct update of prepack
'07Apr98 CFY Tidyupreprints: Added extra error trap around the second dir$
'17Apr98 CFY Tidyupreprints:LineNumbers and stonger error trapping added. Now can optionally log all events that
'            that occur within this procedure by setting a command line switch 'logindebug'
'20Apr98 CFY alpha: Stopped drug description from being truncated on report.
'21APr98 CFY stockloc: Increased 'maxnamelen' constant from 30 to 65 to stop truncation
'03May98 CKJ Y2K. Multiple mods, all with this date/id/Y2k
'07May98 EAC StockLoc: Simplify and speed up printing of location of stock on wards
'                      Removed old dos code that was commented out
'12Jun98 CKJ Sarall: On changing NSVcode make minimum other changes to the entry
'24Jun98 CFY/EAC Sarall: Now handles change of NSVCode correctly.
'30Sep98 TH  WSSpool: Replaced pointer reading with picking ticket no for delivery notes
'02Dec98 TH  WSSpool: Read delnote pointer file for delivery note reprint no
'11Jan99 TH  Alpha: Exposed wardexp for rtf printing
'11Jan99 TH  Prilist: Changed from rtf printing to using crystal report
'19Jan99 TH  Prilist: Now uses crystal control from StockTake to rationalise use of rpt controls
'21Jan99 TH  Prilist: Added DCT code for crystal printing
'02Feb99 SF/CFY WsSpool: attempted to solve the printing of picking tickets to the wrong printer problem by use of context
'24Feb99 TH  Sarall: Put ucase$ on nsvcode match and saving to mdb
'06Apr99 TH  Prilist: Header file now indexed on code and not wardcode as wardcode not necessarily unique and possibly blank
'07Apr99 TH  Prilist: Proper closure on db object
'08Apr99 TH  Prilist: Removed use of header table - Info now exposed using formulas
'14Apr99 TH  Prilist: Added ini call for report preview window
'11Nov99 TH  Prilist: parse out 's from ward/hospital names to stop crystal error
'05Jun00 AJK Sarall : ensured d.localcode is populated
'09Jun00 MMA stockloc: Changed to increase the number of stocks that can be shown (Event no. 42729)
'22Nov00 EAC/CY GetPrintPath: Handle in-dispute items and allow reprints of dispute note
'24sep01 CKJ PrinterParse: Added call to ParseItems which allows use of all standard heap data  (#55080)
'24sep01 CKJ Merged:
'01Sep01 TH  StockLoc: Moved the point at which the stockline is sent to the print file to ensure the last drug is included (#51088)
'09Oct01 TH/CKJ StockLoc: Modified writing of print file to ensure writing of last line and avoid duplicate entries
'11Jan02 TH  Sarall: Added parameter for barcode (#52902)
'15Feb02 TH  WSSpool: Pass in reprintnumber if EDIOrder, use context as flag (#50749)
'16Apr02 TH  Sarall: Addition of new mode 3 to allow for search and delete across wards (enh1477)
'25Apr02 TH  Sarall: Replaced Askwin caption to make caption context specific
'18Jun02 TH  Sarall: Mod to retain space between NSVCode and barcode (#60994)
'06Aug02 TH  Sarall: Mod to retain space from first line as above. (#60788)
'31Mar04 CKJ {SP1}
'            Removed support for non-EAN barcodes
'            Choosewards: Moved proc from StorUtil.bas
'19Apr04 TH  WSSpool: Add suppliercode to the reprintnumber in the reprint file name (enh1574)
'22Jul09 TH  SarallSQL: Show correct amendment to NSVCode(F0052571)
'19Mar10 CKJ Sarallsql: allow NewTopupLevel and NewPackSize to be set to ""
'            If either contains Nul then they have not been set and should be ignored
'            Do not proceed if NSVcode to be written is invalid (either left unchanged or new code)
'            Blank all issue fields when NSV changes, but no others without asking
'            Printed report does not truncate description         (RCN P0007 F0052571)
'01Jun11 CKJ Changed DefInt to DefBool & added 'as integer' to choosewards params


' Mods needed
'-------------
'new input routines should be used                                - done
'top of 2nd page is not aligned                                   - done
'If EAN is selected, but no catno exists then pad o/p with spaces - done
'ditto if no Barcode is selected; just print spaces               - done
'what are SP$ & SQ$? They are always ="P" !!                      - deleted
'HORIS print routine needs multiple pass if ribbon is worn        - done
'anti-tamper s/w needed                                           - done
'file locking on loaded wards needs adding
'should get barcode drom drug file


'-----------------------------------------------------------------------------
'DOStoWIN V1.0 (c) ASCribe 1996
'----------------------------------------------------------------------------
'                                  PRILIST
'                           Print ward stocklist
'
'     converted to qb4 from \STOCKL\PRILIST1.BAS 9990  5-02-88 12:39pm
'-----------------------------------------------------------------------------
' Modification history
'----------------------
' 7Apr89 CKJ Conversion to QB4 started
'21Apr89 CKJ Missing catno ==> print now stays in line
'12May89 ASC No of line feeds if no barcode number now decreased by one
'            to make space used by no barcode sime to barcode
'16May89 ASC Lines per page decreased to 24
'24MAY89 ASC If printer error after intialisation then assumed as timeout
'            and resumed.
' 5Jul89 CKJ Printing remains a problem; a fast computer, slow printer &
'            short timeout in the OS causes the device unavailable error
'            during normal use of the program (esp with barcodes). RESUME
'            is of no use since some, part or all of the PRINT may have got
'            through to the printer & there is no way to tell how much has.
'            Therefore, bring on the print spooler ...
' 6Jul89 CKJ Spooler now starts new file for each page
'18Aug89 CKJ endnwwloop now goes to wayout
'11Sep89 CKJ barcodes OK for EAN, now for HORIS ...
'20Sep89 CKJ  - HORIS codes done. Released as                           V4.1
'30Sep89 CKJ antihack added, printcentred, cls on wayout                V4.1
'22Jan90 CKJ new libraries, popup help & so on                          V4.2
'27Jan90 CKJ version box                                                V4.2
'16Mar90 CKJ clear buffer before handling ESC, help page nos changed    V4.2
'22May90 CKJ 50 char titles, page length reduced slightly               V4.21
'            Inputcharcr now used
'19Nov90 ASC Checking on number of chars in code removed to allow       V5.0
'            compatibility with all sites
'13Apr91 CKJ/ASC reduced No. of lines per page for Burnley
'22Jul91 ASC reference to ward removed in some places as not always used
'            for ward stock lists and to tidy screen now 5.1 (pds 7.1)
'            also sites now dimmed using \library\dimname.inc
'11Aug91 CKJ Dimname.BAS changed to Dimname.INC
'15Dec91 CKJ Stockl.inc added
'            Spacing altered to allow for widened fields
'            Barcode now taken from main drug file, when found          V5.3
' 7Feb92 CKJ Renumbered help, altered escape message
'19Aug93 ASC dp now changed to dpp due to reuse by dp!
' 7Mar94 ASC Stockpath removed from share
'20Mar95 CKJ added progsdrv
'24Mar95 CKJ Moved Close
' 5Jun95 CKJ Uses MultiList
'21Jun95 CKJ Added editform
'05Feb96 EAC Add page numbering.
'27Mar96 CKJ Print definition now from STOCKL.INI
'19Mar96 CKJ Above mod now works per page - reduces memory overheads
'23Dec97 EAC SARALL: turn off hourglass when leaving
'            SARALL: ensure list box is displayed to user
'08Dec97 EAC don't explicity dimension WDNames array - set in ReadFileNames
'29Jul98 TH  Alpha: Added Drugsprinted flag to stop the last drug being reprinted
'19Apr04 TH  WSspool: Add suppliercode to the reprintnumber in the reprint file name (enh1574)
'24May04 TH  sarall: Added getfield wrapper to any reads from the database to stop invalid use of null errors (#65828)
'26Jun13 TH  WSspool: Added mechanism to store reprints in database (TFS 64513)
'06Dec16 TH  DCTPrintExceptions: Replaced RTF Handling (TFS 157969)
'06Dec16 TH  prilistSQL: Replaced RTF Handling (TFS 157969)
'06Dec16 TH  PrilistBottom: Replaced RTF Handling (TFS 157969)
'06Dec16 TH  PrilistTop: Replaced RTF Handling (TFS 157969)
'06Dec16 TH  PrintMarkedText: Replaced RTF Handling (TFS 157969)
'06Dec16 TH  sarallSQL: Replaced RTF Handling (TFS 157969)
'06Dec16 TH  stocklocSQL: Replaced RTF Handling (TFS 157969)
'06Dec16 TH  prilistSQLOLD: Replaced RTF Handling (TFS 157969)
'18Jan21 NS MM-4017-SW - Tx Text control EDI order not printing content of order
'29Jan21 NS MM-4639 SW - Purchase Order missing data and removing MM-4017 changes

' Mods needed
'-------------
'new input routines should be used                                - done
'top of 2nd page is not aligned                                   - done
'If EAN is selected, but no catno exists then pad o/p with spaces - done
'ditto if no Barcode is selected; just print spaces               - done
'what are SP$ & SQ$? They are always ="P" !!                      - deleted
'HORIS print routine needs multiple pass if ribbon is worn        - done
'anti-tamper s/w needed                                           - done
'file locking on loaded wards needs adding
'should get barcode drom drug file                                - done


'-----------------------------------------------------------------------------
DefBool A-Z
Option Explicit

Global lngReprintno As Long       'SQL was reprintno%
Global picknumber%      '30Sep98 TH
Global PrintToScreen$   'allows printing to be sent to highedit preview
                        'useful for testing changes to layouts - set in Set Working Defaults

Const modulename$ = "WSPRINT.BAS"

Dim lastlin%
Dim WDname$()               '08Dec97 EAC don't explicity dimension WDNames array - set in ReadFileNames
Dim dpp As DrugParameters
Dim wardname$, pagenum%, linenum%
Dim PageLen%, HdrALen%, HdrBLen%, DrugLen%, SectLen%, FootLen%, SignLen%, lin%, BCodeLen%
Dim stocklini$
Dim devno%

Function bcode$(NSVCode As String)

Dim barcode As String * 15

    dpp.SisCode = Trim$(UCase$(NSVCode$))
    getdrug dpp, 0, 0, False ' found, False  '01Jun02 ALL/ATW
    barcode$ = "*" & Trim$(dpp.barcode) & "*"
    bcode$ = barcode$

End Function

Function catnovalid(cat$, printwarning)
'-----------------------------------------------------------------------------
'         Returns true/false depending on whether the catno is allowable
'{SP2} use patternmatch
'-----------------------------------------------------------------------------

Dim valid%, char%

   valid = True

   cat$ = UCase$(cat$)
         
   If Len(RTrim$(cat$)) <> 7 Then valid = False
   For char = 1 To 3
      If InStr("ABCDEFGHIJKLMNOPQRSTUVWXYZ", Mid$(cat$, char, 1)) = 0 Then valid = False
   Next char
   For char = 4 To 6
      If InStr("0123456789", Mid$(cat$, char, 1)) = 0 Then valid = False
   Next char
   If InStr("ABCDEFGHIJKLMNOPQRSTUVWXYZ", Mid$(cat$, 7, 1)) = 0 Then valid = False
   If Not valid And printwarning Then
         popmessagecr "!n!iWarning", "Invalid catalogue number; format required is AAA111A"
      End If
      
   catnovalid = valid

End Function

Sub choosewards(WDname$(), nw As Integer, maxnw As Integer)
'-----------------------------------------------------------------------------
'         Display all wards found in keyfile, & select No. required
' NB maxnw = -1 all wards are found & returned, no choice offered
'    maxnw =  0 all wards are offered for user selection
'    maxnw >  0 up to maxnw wards may be selected, & a warning is displayed
'
'Display has 8 wards per line, a line for infobar, 2 for instructions and
' 2 for the box top & bottom, ie a max of 20 lines for the wards.
' It can therefore display up to 160 wards.
'30Jan90 CKJ Blank line at top of display if there is room
'            Only display the max no of wards if that many are found.
' 5Jun95 CKJ Uses MultiList
'29Oct97 EAC Return only the text to the left of the Tab character in WDName$()
'05Mar98 CFY Added new parameter to shellsort.
'31Mar04 CKJ Moved proc from StorUtil.bas
'            Removed unused param StockPath$
'01Jun11 CKJ Added as integer to params
'----------------------------------------------------------------------------
Dim totnw%, count%
Dim title$, msg$, maxW$

   nw = 0
   readfilenames WDname$(), totnw, 0

   If totnw = 0 Then
         title$ = "Load Error"
         msg$ = "   No wards found!"
         popmessagecr title$, msg$
      Else
         If maxnw = -1 Then      'all wards are found & returned, no choice offered
               'shellsort WDname$(), totnw, 1      '05Mar98 CFY Replaced with line below
               shellsort WDname$(), totnw, 1, ""   '
               nw = totnw
            Else
               Load MultiList
               For count = 1 To totnw
                  MultiList.LstUnselected.AddItem WDname$(count)
               Next

               maxW$ = ""
               If maxnw > 0 Then maxW$ = " (up to" + Str$(maxnw) + " maximum)"
               MultiList.Caption = "Select departments or wards" + maxW$
               MultiList.lblLine(1).Caption = "Press A-Z or CURSOR KEYS to move, then SPACE to select, RETURN when finished"
               MultiList.Tag = Str$(maxnw)               'max allowed

               'screen.controlpanel(7) = 0
               MultiList.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form

               If Val(MultiList.Tag) = True Then  'valid
                     nw = MultiList.LstSelected.ListCount
                     For count = 1 To nw
                        WDname$(count) = Trim$(Mid$(MultiList.LstSelected.List(count - 1), 1, InStr(MultiList.LstSelected.List(count - 1), Chr$(9)) - 1)) '29Oct97 EAC only select text left of TAB character
                     Next
                  Else
                     nw = 0
                  End If

               Unload MultiList
            End If
      End If

End Sub

Sub ClearStatusDisplay()

Dim loopvar%

    If MainScreen.LstDisplay.ListCount = 0 Then Exit Sub
    For loopvar = MainScreen.LstDisplay.ListCount To 1 Step -1
            MainScreen.LstDisplay.RemoveItem (loopvar - 1)
        Next
    
    MainScreen.LstDisplay.Visible = True

End Sub

Sub DCTPrintExceptions()
'12Apr00 CFY Parameter added to wsspool call
'06Dec16 TH  Replaced RTF Handling (TFS 157969)


Static X%, Y%, chan%, filename$, linedesc$                 '{SP2} static not needed?

Dim pageno%, plingpos%, success%, Changed%
Dim openbracepos&, closebracepos&, startpos&, endpos&
Dim RTFTxt$, temp$, crlf$

   'DctFrm.LstDCTimport.visible = false
   'DctFrm.Lblmsg.caption = "Spooling..."
   'DctFrm.FrmImport.visible = true
   
   ReadWSLDefaults

   pageno = 1                                            '12Apr95 CKJ
   'Dctfrm.Hide
   chan = FreeFile
   MakeLocalFile filename$
   Open filename$ For Output As chan
   
   'GetTextFile dispdata$ & "\WSdct.rtf", RTFTxt$, success
   GetRTFTextFromDB dispdata$ & "\WSdct.rtf", RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

   If Not success Then
         popmessagecr "Error", "There was a problem reading the RTF layout file - WSDct.rtf"
         Exit Sub
      End If

   crlf$ = "[cr]"
   ParseCtrlChars dispdata$ & "\printer.ini", "RTF", crlf$, Changed

   startpos& = 1
   endpos& = Len(RTFTxt$)

   Do
      openbracepos& = InStr(startpos&, RTFTxt$, "[")
      If openbracepos& > 0 Then
               temp$ = Mid$(RTFTxt$, startpos&, (openbracepos& - startpos&))
         Else
               temp$ = Mid$(RTFTxt$, startpos&)
         End If
      'ok = HEPasteRTF(highedit.HE.hWnd, temp$)
      Print #chan, temp$
      
      If openbracepos& > 0 Then
               startpos& = openbracepos&
               closebracepos& = InStr(openbracepos&, RTFTxt$, "]")
               temp$ = Mid$(RTFTxt$, startpos&, closebracepos& - openbracepos& + 1)
               Do
                  ParseCtrlChars stocklini$, "", temp$, Changed
                  ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, Changed
                  Changed = False
                  If temp$ = "[info]" Then
                           GoSub PrintExceptions
                           temp$ = ""
                           Changed = False
                     Else
                           ParseDataItems temp$, False, Changed
                     End If
               Loop While Changed
               'ok = HEPasteRTF(highedit.HE.hWnd, temp$)
               Print #chan, temp$
         End If
      
      startpos& = closebracepos& + 1

   Loop While (openbracepos& > 0)

   Close #chan

   WSspool filename$, "Stock List", 1, True, False, ""

Exit Sub

PrintExceptions:
   'Print #chan, "Page"; pageno; Space$(20); "DCT exception report"; Space$(22); Mid$(Date$, 4, 3) + Left$(Date$, 3) + Right$(Date$, 2)
   Print #chan,
   Print #chan, Right$(Dctfrm.LblHeader.Caption, 78) & crlf$
   Print #chan, String$(79, "-") & crlf$
   For X = 0 To Dctfrm.LstDCTimport.ListCount - 1
      Y% = Y% + 1
      linedesc$ = Dctfrm.LstDCTimport.List(X)
      Do
         plingpos = InStr(linedesc$, "|")
         If plingpos > 0 Then Mid$(linedesc$, plingpos, 1) = ":"
      Loop Until plingpos = 0
      Print #chan, " "; linedesc$ & crlf$
      If Y% = 56 Then
            pageno = pageno + 1                     '12Apr95 CKJ
            Print #chan, Chr$(12): Y = 0
            Print #chan, "Page"; pageno; Space$(20); "DCT exception report"; Space$(20); Mid$(date$, 4, 3) + Left$(date$, 3) + Right$(date$, 4) & crlf$ '03May98 CKJ Y2K room for yyyy
            Print #chan, Right$(Dctfrm.LblHeader.Caption, 78) & crlf$
            Print #chan, String$(79, "-") & crlf$
         End If
   Next
   'PRINT #chan,                                    '12Apr95 CKJ
   Print #chan, String$(79, "-") & crlf$
   'PRINT #chan, CHR$(12)                           '12Apr95 CKJ
   'Close #chan
   'spool Filename$
   'Dctfrm.Show 0
   'DctFrm.LstDCTimport.visible = true
   ' DctFrm.FrmImport.visible = false
Return

End Sub

Sub DisplayStatus(msg As String)

'29Oct97 EAC Stop out of memory error by limiting amount of text displayed in LstBox

'29Oct97 EAC
Dim loopvar%

    If MainScreen.LstDisplay.ListCount > 100 Then
            For loopvar = 100 To 90
                MainScreen.LstDisplay.RemoveItem loopvar
            Next
        End If
'---

    MainScreen.LstDisplay.AddItem msg$
    MainScreen.LstDisplay.ListIndex = MainScreen.LstDisplay.ListCount - 1
    
    DoEvents

End Sub

Function GenerateSLData$(GenerateBarcodes As Integer)

Dim NewPg%, LPP%, Changed%
Dim temp$, char$

    NewPg = False
    LPP = PageLen - HdrALen
    
    If GenerateBarcodes Then
        temp$ = "[BCHeaderA]"
    Else
        temp$ = "[HeaderA]"
    End If
    
    For linenum = 1 To lastlin
        'If RTrim$(drugs(lin).stklevl) = "&" Then
        If Trim$(drugs(linenum).catno) = "&" Then
                If LPP < SectLen + DrugLen Then NewPg = True
            Else
                If LPP < DrugLen Then NewPg = True
            End If
    
        If NewPg Then
                'setprn devno, "[Footer][FF][~P+][HeaderB]"
                'setprn devno, "[Footer]"
                temp$ = temp$ + "[Footer]"
                'FormFeed outputfile$, devno
                temp$ = temp$ + "[FF]"
                'setprn devno, "[~P+][HeaderB]"
                temp$ = temp$ + "[~P+][HeaderB]"
                NewPg = False
                LPP = PageLen - HdrBLen
            End If
    
        DisplayStatus "Processing line " & Str$(linenum) & Space$(7) & drugs(linenum).drugttl
    
        'If RTrim$(drugs(lin).stklevl) = "&" Then
        If Trim$(drugs(linenum).catno) = "&" Then
                'setprn devno, "[~L+][SectLine]"
                char$ = "[SectLine]"
                Do
                    Changed = False
                    ParseCtrlChars stocklini$, "", char$, Changed
                    ParseDataItems char$, GenerateBarcodes, Changed
                Loop While Changed
                temp$ = temp$ & char$
                LPP = LPP - SectLen
            Else
                'setprn devno, "[~L+][DrugLine]"
                If GenerateBarcodes Then
                        'char$ = "[BCDrugLine]"
                        char$ = bcode$(drugs(linenum).catno)
                    Else
                        char$ = "[DrugLine]"
                    End If
                Do
                    Changed = False
                    ParseCtrlChars stocklini$, "", char$, Changed
                    ParseDataItems char$, GenerateBarcodes, Changed
                Loop While Changed
                'ParseCtrlChars stocklini$, "", char$, changed
                temp$ = temp$ & char$
                If GenerateBarcodes Then
                        LPP = LPP - BCodeLen
                    Else
                        LPP = LPP - DrugLen
                    End If
            End If
    Next
    
    GenerateSLData$ = temp$

End Function

Sub getprintpath(printpath$, X%)
'05Mar98 ASC/EAC
'22Nov00 EAC/CY Handle in-dispute items and allow reprints of dispute note
   
   If X > 0 Then
         Select Case X
            Case 1
               printpath$ = "\ORDERS"                                                  '       "
            Case 2
               printpath$ = "\RETURNS"                                                    '       "
            Case 3
               printpath$ = "\REQUIS"                                                    '       "
            Case 4
               printpath$ = "\DELNOTES"
            Case 5
               printpath$ = "\DISPNOTE"
         End Select
      Else
         Select Case Edittype                                                             '       "
            Case 1, 2, 3                                                               '       "
               printpath$ = "\ORDERS"                                                     '       "
            Case 5, 6                                                                     '       "
               printpath$ = "\REQUIS"                                                     '       "
            Case 7, 8                                                                     '       "
               printpath$ = "\DELNOTES"                                                   '       "
            Case 9                                                                        '       "
               printpath$ = "\RETURNS"                                                    '       "
            Case 4
               printpath$ = "\DISPNOTE"
         End Select                                                                       '       "

      End If

End Sub

Sub ParseDataItems(Item$, DoBarcodes%, Changed%)
'17Jan95 CKJ Copied from ParseCtrlChars, but uses local data items

Dim length%, posn%, openbrace%, closebrace%, foundPtr As Long  '01Jun02 ALL/ATW
Dim char$, middle$, consexp$


   length = Len(Item$)
   If length Then
         posn = 1 'was 0
         Do
            openbrace = InStr(posn, Item$, "[")    'was + 1
            closebrace = 0
            If openbrace Then closebrace = InStr(openbrace + 1, Item$, "]")
            If closebrace > openbrace And openbrace > 0 Then
                  char$ = ""
                  middle$ = Mid$(Item$, openbrace + 1, closebrace - openbrace - 1)
                  Select Case LCase$(middle$)
                     Case ""            'no action
                     Case "~p1"
                        pagenum = 1
                     Case "~l0"
                        linenum = 0
                        ''cleardrug dpp
                        BlankWProduct dpp
                     Case "~p+"
                        pagenum = pagenum + 1
                     Case "~l+"
                        linenum = linenum + 1
                        ''cleardrug dpp
                        BlankWProduct dpp
                        dpp.SisCode = RTrim$(UCase$(drugs(linenum).catno))
                        getdrug dpp, 0, foundPtr&, False    '01Jun02 ALL/ATW
                        If foundPtr& = 0 Then BlankWProduct dpp '01Jun02 ALL/ATW
                        
                     Case "hospname1":
                        char$ = pad$(hospname1$, 40)
                     Case "hospname2":  char$ = pad$(hospname2$, 25)
                     Case "hospabbr":   char$ = hospabbr$
                     Case "today":      char$ = Mid$(date$, 4, 3) + Left$(date$, 3) + Right$(date$, 4) '03May98 CKJ Y2K room for yyyy
                     Case "wardexp":    char$ = wardexp$
                     Case "wardexp20":  char$ = pad$(wardexp$, 20)
                     Case "consexp":    char$ = pad$(consexp$, 30)
                     Case "consexp15":  char$ = pad$(consexp$, 15)
                     Case "wardname":   char$ = pad$(wardname$, 8) 'name on disk
                     Case "wardcode":
                     If Right$(wardcode$, 5) <> "00000" Then char$ = pad$(Right$(wardcode$, 5), 5) '5 char link code
                     Case "dctcode":    If Len(wardcode$) > 5 Then char$ = Left$(wardcode$, 2)
                     Case "pagenum":    char$ = pad$(LTrim$(Str$(pagenum)), 4)
                     Case "linenum":    char$ = pad$(LTrim$(Str$(linenum)), 4)
                     Case "section":    char$ = drugs(linenum).drugttl            '50 chars
                     Case "descrip":    char$ = Left$(drugs(linenum).drugttl, 35) '35 chars
                     Case "barcode":    char$ = bcode$(drugs(linenum).catno)
                     Case "prepack":    char$ = "[prepk-" + Trim$(UCase$(drugs(linenum).prepack)) + "]"
                     Case "stklevl":    char$ = Mid$(drugs(linenum).stklevl, 1, 5)
                     Case "paksize":    char$ = Mid$(drugs(linenum).paksize, 1, 4)
                     Case "catnum":     char$ = UCase$(drugs(linenum).catno)
                     Case "druglist":   char$ = GenerateSLData$(DoBarcodes)
                     Case Else
                        char$ = "[" + middle$ + "]"   'print as found
                     End Select

                  If char$ = "[" + middle$ + "]" Then
                        posn = openbrace + 1 ' was just before LOOP ...
                     Else
                        Changed = True
                     End If
                  Item$ = Left$(Item$, openbrace - 1) + char$ + Mid$(Item$, closebrace + 1)
               End If
         Loop While openbrace
      End If

End Sub


Sub prilistSQL(printbarcodes As Integer)
'29Nov05 TH Changes
'12JUn06 TH Revamp to use new viewer to allow none specific reports
'06Dec16 TH Replaced RTF Handling (TFS 157969)
                          
                          
                          
Dim maxnum%, nw%, nww%, success%, escd%, devno%, loopvar% 'found%,
Dim ans$, temp$, temprtf$, secttxt$, drugtxt$, hdrtxt$, FILE$
Dim tempcode$   '06Apr99 TH
Dim temp1$, temp2$, temp3$  '11Nov99 TH
Dim strParams As String
Dim rsWardStock As ADODB.Recordset
Dim intStart As String
Dim intEnd As String
Dim intOK As Integer
Dim rs As ADODB.Recordset
Dim crxApp As CRAXDDRT.Application
Dim crxRpt As CRAXDDRT.Report
Dim crxTables As CRAXDDRT.DatabaseTables
Dim crxTable As CRAXDDRT.DatabaseTable
Dim crxSubreportObject As CRAXDDRT.SubreportObject
Dim crxSubReport As CRAXDDRT.Report
Dim crxSections As CRAXDDRT.Sections
Dim crxSection As CRAXDDRT.Section
Dim paramField As New Parameter
Dim intIndex As Integer
Dim strReportName As String
Dim blnAlpha As Boolean
Dim strPRN As String
Dim strLines() As String

   If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "WardStock", "N", "UseOLDCrystal", 0)) Then
      If Len(Trim$(g_adoConnectionString)) Then    '15Aug12 CKJ Added check - not compatible with Web Transport Layer
         prilistSQLOLD printbarcodes
         Exit Sub
      Else
         popmessagecr ".", "Cannot use Crystal for printing over Web connection." & crlf & "Reverting to standard printing"
      End If
   End If

   setinput 0, k
   k.HelpFile = "wslist.hlp"
   
   ReadWSLDefaults

   ans$ = "n"
   maxnum = 50
   If ans$ = "Y" Then maxnum = -1                               ' all of them
   
   choosewards WDname$(), nw, maxnum
   
   If nw = 0 Then
         popmsg "Select Wards", "No wards selected.", 64, ans$, escd%
         ChangeTable "Blank", False '14Aug12 TH Added Param
         Exit Sub
      End If
   
   If nw > 50 Then
         popmessagecr "!", "Too many wards selected, first 50 will be printed."
         nw = 50
      End If
  'If Not InStr(UCase$(Command$), "WSLISTRTF") > 0 Then                   '12Jan99 TH
  If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "WardStock", "Y", "UseCrystal", 0)) Then
      'Screen.MousePointer = HOURGLASS '02Aug06 TH Moved below.
      Select Case printbarcodes
         Case 1 'Without barcodes
            strReportName = "\WSLIST.RPT"
         Case 2 'With barcodes
            strReportName = "\WSLISTB.RPT"
         Case 3 'Alphabetical
            strReportName = "\WSLISTA.RPT"
      End Select
      If Not fileexists(dispdata$ & strReportName) Then          '12Jan99 TH
         popmessagecr "Error", "Crystal report file " & strReportName & " missing from directory " & dispdata$ & "." & Chr$(13) & Chr$(13) & "Cannot Print Ward Stock Lists."   '12Jan99 TH
         Exit Sub                                             '    "
      End If
      Screen.MousePointer = HOURGLASS
      For nww = 1 To nw
         getsupplier WDname$(nww), 0, 0, sup  '08Apr99 TH Prepare header information
         wardcode$ = Trim$(sup.wardcode)                 '   "
         wardexp$ = Trim$(sup.fullname)                  '   "
         wardname$ = wardexp$                            '   "
         tempcode$ = Trim$(sup.Code)
         If Len(tempcode$) > 5 Then                      '   "
            tempcode$ = Left$(tempcode$, 2)           '   "
         End If
         temp1$ = hospabbr$              '11Nov99 TH parse out ' to stop crystal error
         temp2$ = wardcode$              '   "
         temp3$ = wardexp$               '   "
         replace temp1$, "'", "", 0      '   "
         replace temp2$, "'", "", 0      '   "
         replace temp3$, "'", "", 0      '   "
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                     gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(WDname(nww)))
         Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListBySiteName", strParams)
         Set crxApp = New CRAXDDRT.Application
         Set crxRpt = crxApp.OpenReport(dispdata$ & strReportName)
          
         rs.Sort = "ScreenPosn"
         crxRpt.Database.SetDataSource rs

         For intIndex = 1 To crxRpt.FormulaFields.count
           If LCase(crxRpt.FormulaFields.Item(intIndex).name) = "{@hospital}" Then
             crxRpt.FormulaFields.Item(intIndex).text = Chr(34) & temp1$ & Chr(34)
           End If
           If LCase(crxRpt.FormulaFields.Item(intIndex).name) = "{@warcode}" Then
             crxRpt.FormulaFields.Item(intIndex).text = Chr(34) & temp2$ & Chr(34)
           End If
           If LCase(crxRpt.FormulaFields.Item(intIndex).name) = "{@wardname}" Then
             crxRpt.FormulaFields.Item(intIndex).text = Chr(34) & temp3$ & Chr(34)
           End If
         Next
         If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "WardStock", "N", "PreviewReports", 0)) Then
            Dim FormReport As New FrmReport
            FormReport.CRViewer.ReportSource = crxRpt
            FormReport.CRViewer.ViewReport
            'FormReport.CRViewer.PrintReport
            Screen.MousePointer = STDCURSOR
            FormReport.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
            Unload FormReport
            Set FormReport = Nothing
         Else
            If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "WardStock", "Y", "CrystalPrintContext", 0)) Then
               SelectPrinterFromContext "WSpool", strPRN
               'MsgBox strPRN
               If strPRN <> "" Then
                  ReDim strLines(3)
                  deflines strPRN, strLines(), ",", 0, 3
                  crxRpt.SelectPrinter strLines(1), strLines(0), strLines(2)
               End If
            End If
            crxRpt.PrintOut
            'crxRpt.SelectPrinter
            Screen.MousePointer = STDCURSOR
         End If
         Set crxRpt = Nothing
         Set crxApp = Nothing
         rs.Close          '20Nov06 TH Close Objects properly
         Set rs = Nothing  '   "
         
      Next
   Else
      MainScreen.LstDisplay.Clear
      ChangeTable "WSPrinting", False '14Aug12 TH Added Param

      
      For nww = 1 To nw
         k.escd = False
         If printbarcodes = 3 Then blnAlpha = True
         readward WDname$(nww), lastlin, success, blnAlpha   '  and re-fill it
         If lastlin > 0 Then
            MakeLocalFile temprtf$
            devno = FreeFile
            Open temprtf$ For Binary Access Write Lock Read Write As devno
            If success = False Then
               DisplayStatus "Ward " & wardname$ & " Not Processed"
            Else
               DisplayStatus Trim$(Str$(lastlin)) & " lines to be printed"
                        
               temp$ = "{"
               Put #devno, , temp$
   
               PrilistTop devno

               'GetTextFile dispdata$ & "\WSLSect.rtf", secttxt$, success
               GetRTFTextFromDB dispdata$ & "\WSLSect.rtf", secttxt$, success  '06Dec16 TH Replaced (TFS 157969)

               If Not success Then
                  popmessagecr "Error", "There was a problem reading the RTF layout file - WSLSect.rtf"
                  Exit Sub
               End If
               striprtf secttxt$
               
               If printbarcodes = 2 Then  '22Apr05 TH Damn thing was loaded in v8.1
                  FILE$ = "\WSLBCode.rtf"
               Else
                  FILE$ = "\WSLDrug.rtf"
               End If
               
               'GetTextFile dispdata$ & FILE$, drugtxt$, success
               GetRTFTextFromDB dispdata$ & FILE$, drugtxt$, success  '06Dec16 TH Replaced (TFS 157969)

               If Not success Then
                  popmessagecr "Error", "There was a problem reading the RTF layout file - " & FILE$
                  Exit Sub
               End If
         
               striprtf drugtxt$

               If printbarcodes = 2 Then '22Apr05 TH Damn thing was loaded in v8.1
                  FILE$ = "\BCodehdr.rtf"
               Else
                  FILE$ = "\Drughdr.rtf"
               End If
               
               'GetTextFile dispdata$ & FILE$, hdrtxt$, success
               GetRTFTextFromDB dispdata$ & FILE$, hdrtxt$, success  '06Dec16 TH Replaced (TFS 157969)

               If Not success Then
                  popmessagecr "Error", "There was a problem reading the RTF layout file - " & FILE$
                  Exit Sub
               End If
               striprtf hdrtxt$
               Put #devno, , hdrtxt$
               
                        
               For loopvar = 1 To UBound(drugs)
                  If Trim$(drugs(loopvar).catno) = "&" Then
                     'title line
                     If Not blnAlpha Then WSLParse devno, secttxt$, loopvar 'TH No title lines for Alphabetical lists
                  Else
                     'drug line
                     WSLParse devno, drugtxt$, loopvar
                  End If
               Next
         
               PrilistBottom devno
               temp$ = "}"
               Put #devno, , temp$
               Close #devno
               WSspool temprtf$, "Stock List", 1, True, False, ""

            End If
            'Print
         Else
            MainScreen.LstDisplay.AddItem "Ward: " & wardname$ & " - No items to print for this ward."
         End If
      Next
   End If

Exit Sub


PrintErr:                                '12Jan99 TH
    popmessagecr "Print Error", Error$   '    "
    Screen.MousePointer = STDCURSOR
    Resume Next                          '    "
   

End Sub

Sub PrilistBottom(devno As Integer)
'06Dec16 TH Replaced RTF Handling (TFS 157969)


Dim RTFTxt$, temp$
Dim success%, Changed%
Dim openbracepos&, closebracepos&, startpos&, endpos&
      
      
      'GetTextFile dispdata$ & "\WSLBttm.rtf", RTFTxt$, success
      GetRTFTextFromDB dispdata$ & "\WSLBttm.rtf", RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

      striprtf RTFTxt$

      startpos& = 1
      endpos& = Len(RTFTxt$)

      Do
         openbracepos& = InStr(startpos&, RTFTxt$, "[")
         If openbracepos& > 0 Then
                  temp$ = Mid$(RTFTxt$, startpos&, (openbracepos& - startpos&))
            Else
                  temp$ = Mid$(RTFTxt$, startpos&)
            End If
         Put #devno, , temp$
         

         If openbracepos& > 0 Then
                  startpos& = openbracepos&
                  closebracepos& = InStr(openbracepos&, RTFTxt$, "]")
                  temp$ = Mid$(RTFTxt$, startpos&, closebracepos& - openbracepos& + 1)
                  
                  '26Jan98 EAC
                  ParseDataItems temp$, False, Changed%
                  'Select Case LCase$(temp$)
                  '   Case "[wardname]"
                  '      temp$ = pad$(wardname$, 8) 'name on disk
                  '   Case "[hospname]"
                  '      temp$ = pad$(hospname1$, 40)
                  '   Case "[today]"
                  '      temp$ = Mid$(Date$, 4, 3) + Left$(Date$, 3) + Right$(Date$, 2)
                  '   Case "[wardcode]"
                  '      temp$ = pad$(Right$(wardcode$, 4), 4) '4 char link code
                  '   Case "[dctcode]"
                  '      temp$ = ""
                  '      If Len(wardcode$) > 4 Then temp$ = Left$(wardcode$, 2)
                  '   Case Else
                  '      ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, changed
                  'End Select
                  Put #devno, , temp$
            End If
         
         startpos& = closebracepos& + 1

      Loop While (openbracepos& > 0)

End Sub

Sub PrilistTop(devno As Integer)

'26Jan98 EAC PrilistTop: Use ParseDataItems to pickup expansions from RTF file
'06Dec16 TH Replaced RTF Handling (TFS 157969)


Dim RTFTxt$, temp$
Dim success%, Changed%
Dim openbracepos&, closebracepos&, startpos&, endpos&
      
      
      'GetTextFile dispdata$ & "\WSLTop.rtf", RTFTxt$, success
      GetRTFTextFromDB dispdata$ & "\WSLTop.rtf", RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

      If Not success Then
            popmessagecr "Error", "There was a problem reading the RTF layout file - WSLTop.rtf"
            Exit Sub
         End If
      striprtf RTFTxt$

      startpos& = 1
      endpos& = Len(RTFTxt$)

      Do
         openbracepos& = InStr(startpos&, RTFTxt$, "[")
         If openbracepos& > 0 Then
                  temp$ = Mid$(RTFTxt$, startpos&, (openbracepos& - startpos&))
            Else
                  temp$ = Mid$(RTFTxt$, startpos&)
            End If
         Put #devno, , temp$
         

         If openbracepos& > 0 Then
                  startpos& = openbracepos&
                  closebracepos& = InStr(openbracepos&, RTFTxt$, "]")
                  temp$ = Mid$(RTFTxt$, startpos&, closebracepos& - openbracepos& + 1)
                  
                  '26Jan98 EAC
                  ParseDataItems temp$, False, Changed%
                  'Select Case LCase$(temp$)
                  '   Case "[wardname]"
                  '      temp$ = pad$(wardname$, 8) 'name on disk
                  '   Case "[hospname]"
                  '      temp$ = pad$(hospname1$, 40)
                  '   Case "[today]"
                  '      temp$ = Mid$(Date$, 4, 3) + Left$(Date$, 3) + Right$(Date$, 2)
                  '   Case "[wardcode]"
                  '      temp$ = pad$(Right$(wardcode$, 4), 4) '4 char link code
                  '   Case "[dctcode]"
                  '      temp$ = ""
                  '      If Len(wardcode$) > 4 Then temp$ = Left$(wardcode$, 2)
                  '   Case Else
                  '      ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, changed
                  'End Select
                  '---
                  Put #devno, , temp$
            End If
         
         startpos& = closebracepos& + 1

      Loop While (openbracepos& > 0)


End Sub

Sub PrinterParse(txt$)
'24sep01 CKJ Added call to ParseItems which allows use of all standard heap data

Dim Changed%

    ParseItems gPRNheapID, txt$, Changed
    Do
        Changed = False
        ParseCtrlChars dispdata$ & "\printer.ini", "RTF", txt$, Changed
    Loop While Changed


End Sub

Sub PrintMarkedText()
'12Apr00 CFY Parameter added to wsspool call
'06Dec16 TH Replaced RTF Handling (TFS 157969)

Dim FILE$, RTFTxt$, temp$, drug$
Dim filno%, success%, loopvar As Long, linesprinted%  '27Jun11 CKJ loopvar was integer
Dim startpos&, openbracepos&, closebracepos&


   Screen.MousePointer = HOURGLASS
    
   'get RTF layout
   MakeLocalFile FILE$
   filno = FreeFile
   Open FILE$ For Binary Access Write Lock Read Write As filno          ' for spooling ...
   
   'GetTextFile dispdata$ + "\utilreps.rtf", RTFTxt$, success
   GetRTFTextFromDB dispdata$ + "\utilreps.rtf", RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

   If Not success Then
         popmessagecr "Error", "Could not open the layout file UTILREPS.RTF"
         Exit Sub
      End If

   'find marked lines and print them
   startpos& = 1
   
   Do
      openbracepos& = InStr(startpos&, RTFTxt$, "[")
      If openbracepos& > 0 Then
               temp$ = Mid$(RTFTxt$, startpos&, (openbracepos& - startpos&))
         Else
               temp$ = Mid$(RTFTxt$, startpos&)
         End If
      Put #filno, , temp$
      

      If openbracepos& > 0 Then
               startpos& = openbracepos&
               closebracepos& = InStr(openbracepos&, RTFTxt$, "]")
               temp$ = Mid$(RTFTxt$, startpos&, closebracepos& - openbracepos& + 1)
               Select Case LCase$(temp$)
                  Case "[header]"
                     temp$ = "Ward Stock List[cr]Print Marked Text"
                     PrinterParse temp$
                     Put #filno, , temp$
                  Case "[data]"
                     'For loopvar = 1 To UBound(OMarked)                               '02Jun11 CKJ Replaced order marked array with direct access to the highlighted listview lines
                     '   If OMarked(loopvar) Then                                      '   "
                     For loopvar = 1 To MainScreen.lvwMainScreen.ListItems.count       '   "
                        If MainLVWIsItemSelected(loopvar) Then              '   "        //// check that this matches one to one in drugs()
                           linesprinted = linesprinted + 1
                           drug$ = drugs(loopvar).catno
                           If Trim$(drug$) = "&" Then drug$ = Space$(Len(drugs(loopvar).catno))
                           temp$ = drugs(loopvar).drugttl & " " & drugs(loopvar).stklevl & " " & drugs(loopvar).paksize & " " & drugs(loopvar).prepack & " " & drug$ & " " & drugs(loopvar).lastissue & "[cr]"
                           PrinterParse temp$
                           Put #filno, , temp$
                        End If
                     Next
               End Select

         End If
      
      startpos& = closebracepos& + 1

      Loop While (openbracepos& > 0)

   Close #filno
   Screen.MousePointer = STDCURSOR
   
   If linesprinted = 0 Then
         If Not k.escd Then popmessagecr "Utility Reports", "No lines to be printed"
         Kill FILE$
      Else
         'Print file
         WSspool FILE$, "Stock Control", 1, True, False, ""
      End If

End Sub

Sub processcolour(txt$)

Dim Colour%
Dim temp$

   If Mid$(txt$, 2, 1) = "!" Then
         Colour = Val(Left$(txt$, 1))
         Select Case Colour
            Case 1:    temp$ = "[red]"
            Case 2:    temp$ = "[blue]"
            Case 3:    temp$ = "[magenta]"
            Case 4:    temp$ = "[yellow]"
            Case 5:    temp$ = "[pink]"
            Case Else: temp$ = "[black]"
            End Select
         txt$ = temp$ & Mid$(txt$, 3) & "[black]"
      End If

End Sub



Sub ReadWSLDefaults()

Dim found%

   stocklini$ = dispdata$ + "\stockl.ini"
   'usable lines per page excluding the footer (if used)
   PageLen = Val(TxtD$(stocklini$, "", "60", "PageLen", found))
   'lines used in 1st page header
   HdrALen = Val(TxtD$(stocklini$, "", "10", "HdrALen", found))
   'lines used in subsequent page headers
   HdrBLen = Val(TxtD$(stocklini$, "", "5", "HdrBLen", found))
   'lines used per drug
   DrugLen = Val(TxtD$(stocklini$, "", "2", "DrugLen", found))
   'lines used per drug
   BCodeLen = Val(TxtD$(stocklini$, "", "3", "BCodeLen", found))
   'lines used per section name
   SectLen = Val(TxtD$(stocklini$, "", "3", "SectLen", found))
   'lines used in footer
   FootLen = Val(TxtD$(stocklini$, "", "3", "FootLen", found))
   'lines used in signature block
   SignLen = Val(TxtD$(stocklini$, "", "15", "SignLen", found))

End Sub


Sub sarallSQL(Mode%, SearchTxt$, NewDesc$, NewPackSize$, NewTopupLvl$, NewCatno$, NewPrepack$, NewBarcode As String)
'22Jul09 TH  Show correct amendment to NSVCode(F0052571)
'19Mar10 CKJ allow NewTopupLevel and NewPackSize to be set to ""
'            If either contains Nul then they have not been set and should be ignored
'            Do not proceed if NSVcode to be written is invalid (either left unchanged or new code)
'            Blank all issue fields when NSV changes, but no others without asking        (RCN P0007 F0052571)
'06Dec16 TH  Replaced RTF Handling (TFS 157969)

Const procname$ = "SARAll"

Dim nw%, X%, devno%, maxnum%, Changed%
Dim duff%, dummy%, success% ', newfnd&
Dim ans$, outputfile$, match$, linepos$, SQL$, temp$, RTFTxt$, rtfCR As String
Dim found&, startpos&, endpos&, openbracepos&, closebracepos&
Dim resumeval%, retries%
Dim tempward$, desc$
Dim posn%
Dim strTmpBcode As String
Dim blnDelete As Integer, strRTF As String, blnOnWard As Integer, strName As String '16Apr02 TH Added (enh1477)
Dim lngSitenumberStore As Long
Dim foundPtr As Long
Dim rsWardlist As ADODB.Recordset
Dim strParams As String
Dim lngOK As Long

Dim strDesc As String
Dim intPackSize As Integer
Dim intTopupLvl As Integer
Dim strPrepack As String
Dim strCatno As String
Dim strBarcode As String
Dim intLastIssue As Integer
Dim lastissuedate As String
Dim intDailyIssue As Integer
Dim strLocal As String '17Aug06 TH Added

Dim dtemp As DrugParameters
Dim strCaption As String
Dim valid As Boolean

   If Mode% = 3 Then blnDelete = True Else blnDelete = False

   ChangeTable "Blank", False '14Aug12 TH Added Param

   setinput 0, k
   k.HelpFile = "wslist.hlp"
   
   Select Case Mode
      Case 1: strCaption = "Replace"
      Case 2: strCaption = "Search"
      Case 3: strCaption = "Delete"
      End Select

   ChangeTable "WSPrinting", False '14Aug12 TH Added Param

   setinput 0, k
   k.helpnum = 1310
   k.validchars = "YN*" & nulls
   ans$ = ""
   '''askwin Iff(blnDelete, "Delete", "Replace"), "Do you want to search all wards?   (Y/N)", ans$, k     '    "
   askwin "?" & strCaption, crlf & crlf & "  Do you want to search all wards?" & crlf, ans$, k
   If Not k.escd Then
      maxnum = 0                                          ' offer all
      If ans$ = "Y" Then maxnum = -1                      ' select all
      choosewards WDname$(), nw, maxnum                   ' offer choice
      If nw = 0 Then Exit Sub                             ' <== Way out
   Else                                                    ' escaped
      Exit Sub                                            ' <== Way out
   End If

   Select Case Mode%
      Case 1, 2, 3              '16Apr02 TH Added 3 (enh1477)
      Case Else
         popmessagecr "Error", "Mode" & Str$(Mode%) & " has not been implemented yet."
         Exit Sub
      End Select

   Screen.MousePointer = HOURGLASS

   ReadWSLDefaults

   rtfCR = "[cr]"
   ParseCtrlChars dispdata$ & "\printer.ini", "RTF", rtfCR, Changed

   MakeLocalFile outputfile$             ' Set up for SPOOL output
   devno = FreeFile                      ' create & open a disk file
   Open outputfile$ For Binary Access Write Lock Read Write As #devno


   If blnDelete Then strRTF = "\WSDel.rtf" Else strRTF = "\WSsandr.rtf"

   'GetTextFile dispdata$ & strRTF, RTFTxt$, success
   GetRTFTextFromDB dispdata$ & strRTF, RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

   If Not success Then
      popmessagecr "Error", "There was a problem reading the RTF layout file - " & Mid$(strRTF, 2)
      Exit Sub
   End If

   startpos& = 1
   endpos& = Len(RTFTxt$)

   Do
      openbracepos& = InStr(startpos&, RTFTxt$, "[")
      If openbracepos& > 0 Then
         temp$ = Mid$(RTFTxt$, startpos&, (openbracepos& - startpos&))
      Else
         temp$ = Mid$(RTFTxt$, startpos&)
      End If
      Put #devno, , temp$
      If openbracepos& > 0 Then
         startpos& = openbracepos&
         closebracepos& = InStr(openbracepos&, RTFTxt$, "]")
         temp$ = Mid$(RTFTxt$, startpos&, closebracepos& - openbracepos& + 1)
         Do
            Changed = False
            Select Case LCase$(temp$)
               Case "[sartitle]"
                  GoSub ProcessTitle
                  temp$ = ""
                  Changed = False
               Case "[info]"
                  SearchTxt = UCase$(Trim$(SearchTxt))
                  '19Mar10 CKJ check drug code before starting
                  valid = True
                  If Mode = 1 Then                             'search & replace mode
                     If Trim$(NewCatno$) = "" Then             'keep same NSVcode, so make sure it is valid
                        d.SisCode = SearchTxt
                        getdrug d, 0, foundPtr&, False
                        If foundPtr& <= 0 Then        'don't proceed with scan
                           temp$ = "NSV Code '" & Trim$(NewCatno$) & "' not found in product database"
                           valid = False
                        End If
                     Else                                      'replace with new NSVcode, so make sure it is valid
                        d.SisCode = NewCatno$                  '(old NSVcode doesn't matter as we're replacing it)
                        getdrug d, 0, foundPtr&, False
                        If foundPtr& <= 0 Then        'don't proceed with scan
                           temp$ = "New NSV Code '" & Trim$(NewCatno$) & "' not found in product database"
                           valid = False
                        End If
                     End If
                  End If
                  
                  If valid Then
                     GoSub ProcessLine
                  Else
                     DisplayStatus temp$
                     Put #devno, , rtfCR & temp$ & rtfCR
                  End If

                  temp$ = ""
                  Changed = False
               Case Else
                  ParseCtrlChars stocklini$, "", temp$, Changed
                  ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, Changed
                  ParseDataItems temp$, False, Changed
            End Select
         Loop While Changed
         Put #devno, , temp$
      End If
      startpos& = closebracepos& + 1
   Loop While (openbracepos& > 0)

   Close #devno

   If blnDelete Or Mode% = 1 Then                                                                                                        '16Apr02 TH Added for new delete option,
      Screen.MousePointer = STDCURSOR
      'Give option to print report or not                                                                                             '    "      but also now for replace (enh1477)
      ans$ = "Y"                                                                                                                      '    "
      '''askwin Iff(blnDelete, "Delete", "Replace"), "Do you want to print a report of " & Iff(blnDelete, "deleted", "replaced") & " lines ?   (Y/N)", ans$, k  '           caption context specific
      askwin "?" & strCaption, crlf & crlf & "Do you want to print a report of " & Iff(blnDelete, "deleted", "replaced") & " lines ?" & crlf, ans$, k '           caption context specific
      
      If ans$ = "Y" And Not k.escd Then                                                                                               '    "
         WSspool outputfile$, "Stock Location", 1, True, False, ""                                                                    '    "
      Else                                                                                                                            '    "
         On Error Resume Next                                                                                                         '    "
         Kill outputfile$                                                                                                             '    "
         On Error GoTo 0                                                                                                              '    "
      End If                                                                                                                          '    "
   Else                                                                                                                               '    "
      WSspool outputfile$, "Stock Location", 1, True, False, ""
   End If                                                                                                                             '    "

   Screen.MousePointer = STDCURSOR
   MainScreen.LstDisplay.Visible = False     '22Mar10 CKJ clear the list box on the MDI parent

Exit Sub

'/-------------------------------------------------------------------------------------------

ProcessTitle:

   If Mode% = 2 Then                                          ' V4.21
      temp$ = "Missing Catalogue Number Search"
      X = 0
   ElseIf Mode% = 3 Then
      strName = d.DrugDescription
      plingparse strName, "!"
      temp$ = d.SisCode & " " & strName
   Else
      temp$ = "Search & Replace"
   End If

   Put #devno, , temp$

Return

'/-------------------------------------------------------------------------------------------

ProcessLine:

   Put #devno, , rtfCR

   For X = 1 To nw    ' loop for each ward
      tempward$ = WDname$(X)
      blnOnWard = False
      If Not blnDelete Then
         DisplayStatus "Searching " & tempward$
         temp$ = Space$(10) & "{[b]Ward  " & tempward$ & "}" & rtfCR
         ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, Changed
         Put #devno, , temp$
      End If

      posn = InStr(tempward$, TB$)
      If posn > 1 Then
         tempward$ = Trim$(Mid$(tempward$, 1, posn - 1))
      End If
     
      lin = 0

      getsupplier tempward$, 0, (dummy), sup
      dispdatastore$ = dispdata$
      lngSitenumberStore = SiteNumber
      
      If trimz$(sup.icode$) <> "" Then dispdata$ = "\dispdata." & Right$("000" & Trim$(sup.icode), 3)
      'SQL ATTENTION CORRECT ID NEEDS RETURNING HERE
      If trimz$(sup.icode$) <> "" Then SiteNumber = Val(sup.icode)
         
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, tempward$)
      
      Set rsWardlist = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListbySiteName", strParams)
      
      Do While Not rsWardlist.EOF
         lin = lin + 1
         linepos$ = Right$(Space$(4) & Str$(lin), 4)
         
         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         If Mode% = 1 Then    'REPLACE'
            If UCase$(GetField(rsWardlist!NSVCode)) = SearchTxt Then
'               d.SisCode = GetField(rsWardlist!NSVCode)       '22Mar10 CKJ already checked for validity before calling
'               getdrug d, 0, foundPtr&, False
'               If foundPtr& > 0 Then

               'Preset Existing values       '22Mar10 CKJ Moved from below & now uses getfield
               strDesc = Trim$(GetField(rsWardlist!titletext))
               intPackSize = GetField(rsWardlist!PackSize)
               intTopupLvl = GetField(rsWardlist!topuplvl)
               strPrepack = Trim$(GetField(rsWardlist!PrintLabel))
               strBarcode = GetField(rsWardlist!barcode)
               strCatno = GetField(rsWardlist!NSVCode)
               intLastIssue = GetField(rsWardlist!lastissue)
               strLocal = GetField(rsWardlist!localcode)   '17Aug06 TH Added '09Sep06 TH was local not localcode !!
               lastissuedate = GetField(rsWardlist!lastissuedate)     '19Mar10 CKJ
               intDailyIssue = GetField(rsWardlist!dailyissue)        '   "
               
               'temp$ = Left$(strDesc & Space$(35), 35) & "  "                  '22Mar10 CKJ changed
               temp$ = "{[condon]" & Left$(strDesc & Space$(56), 56) & "}  "    '            changed from 35 to full 56 chars
               'temp$ = temp$ & Format$(intTopupLvl) & "  "
               temp$ = temp$ & LeftPad(intTopupLvl, 6) & "  "                   '   "
               'temp$ = temp$ & Format$(intPackSize) & "  "
               temp$ = temp$ & LeftPad$(intPackSize, 6) & "  "                  '   "
               If strPrepack = "~" Then
                  temp$ = temp$ & " "
               Else
                  temp$ = temp$ & strPrepack
               End If
               temp$ = temp$ & "  " & strCatno
               If Not IsNull(rsWardlist("barcode")) Then
                  strTmpBcode = strBarcode
                  replace strTmpBcode, "*", "", 0
                  temp$ = temp$ & "  " & strTmpBcode
               End If

               temp$ = linepos$ & ": " & temp$      '22Mar10 CKJ changed from " did read  : " to gain room for description
               DisplayStatus "Line " & temp$
               ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, Changed
               Put #devno, , temp$ & rtfCR
               
               If Trim$(NewCatno$) <> "" And UCase$(RTrim$(strCatno)) <> UCase$(Trim$(NewCatno$)) Then  '24May04 TH
                  'rsWardlist("NSVCode") = UCase$(Trim$(NewCatno$)) '17aug06 TH Do not use rs to cast into, use new variable
                  'd.SisCode = strCatno 'GetField(rsWardlist!NSVCode) '17Aug06 TH Use new variable
'22Mar10 CKJ wrong place to look up. gets same drug every time, and if not found replaces existing line with 'not found...' in each ward list
'                  d.SisCode = NewCatno$ '09Sep06 TH Added - we look up the new item you dolt !!
'                  getdrug d, 0, foundPtr&, False
'                  If foundPtr& > 0 Then
                  
                  'desc$ = d.Description              '19Mar10 CKJ do not change here
                  'plingparse desc$, "!"
                  'strDesc = Trim$(desc$)
                  'intPackSize = Val(d.convfact)
                  intLastIssue = 0
                  intDailyIssue = 0                   '19Mar10 CKJ added
                  lastissuedate = ""                  '   "

                  'wrong to set d.local, even if it is not being saved
                  'If TrueFalse(TxtD$(dispdata$ & "\StkMaint.ini", "Data", "T", "LocalCodeUnique", 0)) = False Or Trim$(d.local) = "" Then
                  '   d.local = d.SisCode
                  'End If

                  strLocal = Trim$(d.local)  '24Jun98 CFY/EAC Added  '17Aug06 TH Replaced
                  If TrueFalse(TxtD$(dispdata$ & "\StkMaint.ini", "Data", "T", "LocalCodeUnique", 0)) = False Or Trim$(d.local) = "" Then
                     strLocal = d.SisCode
                  End If

                  strCatno = NewCatno$ '09Sep06 TH added
                  'If Trim$(d.barcode) <> "" Then strBarcode = "*" & Trim$(d.barcode) & "*"  '17Aug06 TH   '19Mar10 CKJ do not change here

'22Mar10 CKJ already checked, and would be written to DB against the otherwise unchanged entry
'                  Else
'                     strDesc = "Not found in drug file."                '17Aug06 TH Replaced above
'                  End If

               End If

               If Trim$(NewDesc$) <> "" And RTrim$(strDesc) <> Trim$(NewDesc$) Then '24May04 TH
                  strDesc = Trim$(NewDesc$)
               End If

               'If Trim$(NewPack$) <> "" And GetField(rsWardlist!PackSize) <> Val(NewPack$) Then  '24May04 TH
               If Trim$(NewPackSize) <> Nul Then                                                      '19Mar10 CKJ changed to allow =""
                  If GetField(rsWardlist!PackSize) <> Val(NewPackSize) Then   '24May04 TH
                     intPackSize = Val(NewPackSize)
                  End If
               End If
               
               'If Trim$(NewPack$) <> "" And GetField(rsWardlist!PackSize) <> Val(NewPack$) Then   '22Mar10 CKJ changed to barcode
               If Trim$(NewBarcode) <> "" And Trim$(strBarcode) <> Trim$(NewBarcode) Then          '   "
                  strTmpBcode = Trim$(NewBarcode)
                  replace strTmpBcode, "*", "", 0
                  If strTmpBcode <> "" Then
                     strBarcode = "*" & strTmpBcode & "*"
                  End If
               End If
               
               If Trim$(NewPrepack) <> "" And Trim$(strPrepack) <> Trim$(NewPrepack) Then  '24May04 TH
                  strPrepack = Trim$(NewPrepack)
               End If
               
               'If Trim$(NewLvl$) <> "" And GetField(rsWardlist!topuplvl) <> Val(NewLvl$) Then '24May04 TH
               If NewTopupLvl <> Nul Then                                                           '19Mar10 CKJ changed to allow =""
                  If GetField(rsWardlist!topuplvl) <> Val(NewTopupLvl) Then '24May04 TH
                     intTopupLvl = Val(NewTopupLvl)
                  End If
               End If
               
               On Error GoTo SRUpdateTableErr
               '17Aug06 TH use new strLocal rather than rs field as previous below
               strParams = gTransport.CreateInputParameterXML("WWardStockListID", trnDataTypeint, 4, rsWardlist!WWardStockListID) & _
                           gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                           gTransport.CreateInputParameterXML("ScreenPosn", trnDataTypeint, 4, rsWardlist!ScreenPosn) & _
                           gTransport.CreateInputParameterXML("NSVcode", trnDataTypeVarChar, 7, strCatno) & _
                           gTransport.CreateInputParameterXML("TitleText", trnDataTypeVarChar, 56, strDesc) & _
                           gTransport.CreateInputParameterXML("PrintLabel", trnDataTypeVarChar, 1, strPrepack) & _
                           gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, rsWardlist!sitename) & _
                           gTransport.CreateInputParameterXML("TopupLvl", trnDataTypeint, 4, intTopupLvl) & _
                           gTransport.CreateInputParameterXML("LastIssue", trnDataTypeint, 4, intLastIssue) & _
                           gTransport.CreateInputParameterXML("PackSize", trnDataTypeint, 4, intPackSize) & _
                           gTransport.CreateInputParameterXML("LastIssueDate", trnDataTypeVarChar, 10, lastissuedate) & _
                           gTransport.CreateInputParameterXML("LocalCode", trnDataTypeVarChar, 7, strLocal) & _
                           gTransport.CreateInputParameterXML("BarCode", trnDataTypeVarChar, 15, strBarcode) & _
                           gTransport.CreateInputParameterXML("DailyIssue", trnDataTypeint, 4, intDailyIssue)        '19 Mar10 CKJ was rsWardlist!lastissuedate & rsWardlist!dailyissue
               lngOK = gTransport.ExecuteUpdateSP(g_SessionID, "WWardStockList", strParams)
               On Error GoTo 0

               'temp$ = Left$(strDesc & Space$(35), 35) & "  "  ' drug name  V4.21       '22Mar10 CKJ changed
               temp$ = "{[condon]" & Left$(strDesc & Space$(56), 56) & "}  "             '            changed from 35 to full 56 chars
               'temp$ = temp$ & Format$(intTopupLvl) & "  "     ' quantity
               temp$ = temp$ & LeftPad(intTopupLvl, 6) & "  "                            '   "
               'temp$ = temp$ & Format$(intPackSize) & "  "     ' pack size
               temp$ = temp$ & LeftPad$(intPackSize, 6) & "  "                           '   "
               If strPrepack = "~" Then
                  temp$ = temp$ & " "                          ' pre-pack
               Else
                  temp$ = temp$ & strPrepack                   ' pre-pack
               End If
               'temp$ = temp$ + GetField(rsWardlist!NSVCode)    ' cat no
               temp$ = temp$ & "  " & strCatno  '22Jul09 TH Show correct amendment to NSVCode(F0052571)

               strTmpBcode = strBarcode
               replace strTmpBcode, "*", "", 0
               temp$ = temp$ & "  " & strTmpBcode
               DisplayStatus "now reads   " & temp$
               temp$ = " Now: " & temp$ & rtfCR        '22Mar10 CKJ changed from "now reads : " to gain room for description
               ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, Changed
               Put #devno, , temp$
            Else
'               DisplayStatus "NSV Code not found in ward drug file"
'               temp$ = "NSV Code not found in ward drug file" & rtfCR
'               Put #devno, , temp$
            End If
            'Put #devno, , rtfCR
         End If
         'End If

         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         If Mode% = 2 Then                                    ' V4.21
            If RTrim$(GetField(rsWardlist!NSVCode)) <> "&" Then
               duff = 0
               temp$ = UCase$(GetField(rsWardlist!NSVCode))    '24feb99 TH
               If catnovalid(temp$, False) Then
                  BlankWProduct dtemp
                  dtemp.SisCode = temp$
                  found& = 0
                  getdrug dtemp, 0, found&, False
                  If found& = 0 Then duff = 1
               Else
                  duff = 2 ' not of form AAA111A
               End If

               If duff <> 0 Then
                  temp$ = Left$(GetField(rsWardlist!titletext), 35) + "  " ' drug name   V4.21
                  If GetField(rsWardlist!PrintLabel) = "~" Then
                      temp$ = temp$ + " " + "  "     ' pre-pack
                  Else
                      temp$ = temp$ + GetField(rsWardlist!PrintLabel) + "  "     ' pre-pack
                  End If
                  temp$ = temp$ + GetField(rsWardlist!NSVCode)              ' cat no
                  temp$ = "Line " & linepos$ & " : " & temp$
                  If duff = 1 Then
                      temp$ = temp$ & "- NSV code not defined in main index"
                  Else
                      'If ASCribe Then temp$ = temp$ & "- Not a valid NSV code"     '22Mar10 CKJ corrected
                      temp$ = temp$ & "- Not a valid NSV code"
                  End If
                  DisplayStatus temp$
                  Put #devno, , temp$ & rtfCR
               End If
            End If
         End If
         
         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         If Mode% = 3 Then       'DELETE'
            If UCase$(GetField(rsWardlist!NSVCode)) = SearchTxt Then
               d.SisCode = GetField(rsWardlist!NSVCode)
               getdrug d, 0, foundPtr&, False
               If foundPtr& > 0 Then
                  temp$ = Left$(tempward$ & Space$(8), 8) + "  "
                  temp$ = temp$ & Left$(GetField(rsWardlist!titletext) & Space$(35), 35) + "  " '
                  temp$ = temp$ & Format$(GetField(rsWardlist!topuplvl)) + "  "
                  DisplayStatus "Deleted line " & linepos$ & " : " & temp$ & rtfCR
                  temp$ = "Deleted line " & linepos$ & " : " & temp$ & rtfCR
                  If Not blnOnWard Then temp$ = "Ward  " & tempward$ & rtfCR & temp$: blnOnWard = True
                  Put #devno, , temp$

                  On Error GoTo SRUpdateTableErr
                  lngOK = gTransport.ExecuteDeleteSP(g_SessionID, "WWardStockList", GetField(rsWardlist!WWardStockListID))
                  On Error GoTo 0
               Else
                  temp$ = "NSV Code not found in ward drug file"
                  DisplayStatus temp$
                  Put #devno, , temp$ & rtfCR
               End If
               Put #devno, , rtfCR
            End If
         End If
         rsWardlist.MoveNext
      Loop
      
      rsWardlist.Close                 '19Mar10 CKJ moved inside Next, to match creation
      Set rsWardlist = Nothing
      
      dispdata$ = dispdatastore$
      SiteNumber = lngSitenumberStore
   Next       ' end of main loop

'   rsWardlist.Close                   '19Mar10 CKJ moved above
'   Set rsWardlist = Nothing

Return

'/-------------------------------------------------------------------------------------------

SRUpdateTableErr:

   resumeval = ProcessUpdateErr(Err, modulename$, procname$, 0, retries)

   Select Case resumeval
      Case -1
         Resume
      Case 0
         Resume Next
      Case 1
         TerminateApp
   End Select

End Sub

Sub SetPrinterOptions()
'////
Dim errored

   errored = False
   On Error GoTo SPOErr
   Dctfrm.Tag = &H40   'Printer Setup dialog only
   
   'Dctfrm.DirList.  Action = 5
   On Error GoTo SPOErr
   
   If errored Then
         popmessagecr "Error", "There is a problem with the way your printer is configured for Windows." & cr$ & "Please check the settings and try again."
      Else
         'HEWinIniChange HighEdit.HE.hWnd, "Windows"
         'HERedraw HighEdit.HE.hWnd, True
      End If

Exit Sub

SPOErr:

   errored = True
   Resume Next

End Sub

Sub stocklocSQL()
'06Dec16 TH Replaced RTF Handling (TFS 157969)


Dim viewdebug%, nw%, loopvar%, maxnum%, success%, Changed%, escd%
Dim title$, msg$, ans$, SQL$, sitesql$, tmp$, temprtf$, RTFTxt$, temp$, onward$, alphaline$, crlf$
Dim startpos&, endpos&, openbracepos&, closebracepos&
Dim NsvStore$, TitleStore$                        '07May98 EAC Added
Dim strCurrentDesc As String                      '09Oct01 TH/CKJ Added
Dim strCurrentWard As String                      '   "
Dim strCurrentNSVcode As String                   '   "
''Dim objdata As clsDataAccess
Dim rsStockloc As ADODB.Recordset
''Dim blnOK As Boolean
Dim strParams As String

    setinput 0, k
    k.HelpFile = "wslist.hlp"

    viewdebug = False           '!! Set to true if required for testing
    
    ChangeTable "WSPrinting", False '14Aug12 TH Added Param

    MainScreen.LstDisplay.Clear

    DisplayStatus "This program will search through the wards on disc and "
    DisplayStatus "produce a list of all items stocked and their location."
    'If num < 2000 Then popmessagecr "!n!iWARNING: Max number of drugs is" + Str$(num), "This limit applies to this PC - other machines may have more free memory"
    
    setinput 0, k
    k.helpnum = 1500
    k.validchars = "YND*"
    ans$ = ""
    askwin "Location of Stock on Wards", "Do you want to search all wards?    ", ans$, k
    If k.escd Then
         ChangeTable "Blank", False '14Aug12 TH Added Param
         Exit Sub                                   ' <== way out
      End If
    If ans$ = "D" Then viewdebug = True
    If ans$ = "*" Then
            title$ = "!n!bVersion"
            msg$ = "  Ward Stocklist STOCKLOC" & Chr$(13)
            msg$ = msg$ & "  Version 6.2" & Chr$(13)
            msg$ = msg$ & "  Modstate : 11 Oct 96" & Chr$(13)
            popmessagecr title$, msg$
        End If

    'maxnum = 150                  '09Jun00 MMA removed to increase the ceiling (Event no. 42729)
     maxnum = 500                  '09Jun00 MMA added to increase the ceiling (Event no. 42729)
    If ans$ = "Y" Then
            maxnum = -1                               ' all of them
            sitesql$ = ""
        End If
    
    choosewards WDname$(), nw, maxnum

    If nw = 0 Then
         popmsg "Select Wards", "No wards selected.", 64, ans$, escd%
         ChangeTable "Blank", False '14Aug12 TH Added Param
         Exit Sub                                   ' <== way out
      End If
    
    If nw > 0 Then
         tmp$ = Str$(nw) & "ward"
         If nw <> 1 Then tmp$ = tmp$ & "s"
         tmp$ = tmp$ & " to be searched."
         DisplayStatus tmp$
      End If

    If nw > 500 Then                                                                                           '09Jun00 MMA added to increase the ceiling (Event no. 42729)
         popmessagecr "!", "Maximum permitted number of wards is 500, extra wards will not be searched."    '           ''
         nw = 500                                                                                           '           ''
      End If

    DisplayStatus "Building index ..."
    
    ReadWSLDefaults
    MakeLocalFile temprtf$
    devno = FreeFile
    Open temprtf$ For Binary Access Write Lock Read Write As devno

    'GetTextFile dispdata$ & "\WSstock.rtf", RTFTxt$, success
    GetRTFTextFromDB dispdata$ & "\WSstock.rtf", RTFTxt$, success  '06Dec16 TH Replaced (TFS 157969)

   If Not success Then
         popmessagecr "Error", "There was a problem reading the RTF layout file - WSstock.rtf"
         Exit Sub
      End If

    startpos& = 1
    endpos& = Len(RTFTxt$)

    Do
        openbracepos& = InStr(startpos&, RTFTxt$, "[")
        If openbracepos& > 0 Then
                temp$ = Mid$(RTFTxt$, startpos&, (openbracepos& - startpos&))
            Else
                temp$ = Mid$(RTFTxt$, startpos&)
            End If
        Put #devno, , temp$
        

        If openbracepos& > 0 Then
                startpos& = openbracepos&
                closebracepos& = InStr(openbracepos&, RTFTxt$, "]")
                temp$ = Mid$(RTFTxt$, startpos&, closebracepos& - openbracepos& + 1)
                Do
                    Changed = False
                    If LCase$(temp$) = "[stockline]" Then
                            GoSub ProcessStockLine
                            temp$ = ""
                            Changed = False
                        Else
                            ParseCtrlChars stocklini$, "", temp$, Changed
                            ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, Changed
                            ParseDataItems temp$, False, Changed
                        End If
                Loop While Changed
                Put #devno, , temp$
            End If
        
        startpos& = closebracepos& + 1

    Loop While (openbracepos& > 0)

    Close #devno

    WSspool temprtf$, "Stock Location", 1, True, False, ""
    
Exit Sub

ProcessStockLine:

    crlf$ = "[cr]"
    ParseCtrlChars dispdata$ & "\printer.ini", "RTF", crlf$, Changed

''    If nw > 0 And maxnum <> -1 Then
''            For loopvar = 1 To nw
''                    If loopvar = 1 Then
''                            'sitesql$ = " WHERE (SiteName = '" & Trim$(WDName$(loopvar)) & "'"
''                            sitesql$ = " AND (SiteName = '" & Trim$(WDname$(loopvar)) & "'"
''                        Else
''                            sitesql$ = sitesql$ & " OR SiteName = '" & WDname$(loopvar) & "'"
''                        End If
''                Next
''            ''sitesql$ = sitesql$ & ")"
''            sitesql$ = sitesql$ & " AND siteID = " & Format$(sitenumber) & " )"
''        End If

    'Create SnapShot of all drugs in the database, sort by description
    'SQL should be : "SELECT * FROM Layout WHERE (NSVCode <> '&') AND (SiteName = ...) ORDER BY Description)

    '07May98 EAC Simplify and speed up printing of location of stock on wards
    '            commented out below and rewrote
    'sql$ = "SELECT NSVCode,TitleText FROM Layout " & sitesql$ & " GROUP BY NSVCode, TitleText HAVING (NSVCode <> '&') ORDER BY TitleText"
    'Set SLSnapShot = WSDB.CreateSnapshot(sql$)
    '
    '
    'Do While Not SLSnapShot.EOF
    '        DisplayStatus "Primary - " & SLSnapShot("TitleText") & " " & SLSnapShot("NSVCode")
    '        'sql$ = "SELECT * FROM Layout WHERE (NSVCode = '" & SLSnapShot("NSVCode") & "')" & sitesql$ & " ORDER BY SiteName"
    '        sql$ = "SELECT NSVCode,TitleText,SiteName FROM Layout " & sitesql$ & " GROUP BY NSVCode,TitleText,SiteName HAVING (NSVCode = '" & SLSnapShot("NSVCode") & "') ORDER BY SiteName"
    '        Set WardSS = WSDB.CreateSnapshot(sql$)
    '        Do While Not WardSS.EOF
    '                DisplayStatus WardSS("TitleText") & " " & WardSS("NSVCode") & " " & WardSS("SiteName")
    '                wardname$ = WardSS("SiteName")
    '                getsupplier wardname$, 0, found, False, sup
    '                If found > 0 Then onward$ = onward$ & trimz$(sup.code) & ","
    '                WardSS.MoveNext
    '            Loop
    '        desc$ = ""
    '        desc$ = Mid$(GetField(SLSnapShot!TitleText), 1, maxnamelen)
    '        alphaline$ = desc$ & " " & SLSnapShot("NSVCode") & " " & onward$ & crlf$
    '        Put #devno, , alphaline$
    '        onward$ = ""
    '        SLSnapShot.MoveNext
    '    Loop
    
   '09Oct01 TH/CKJ Block removed - logic stramlined, see below
   'sql$ = "SELECT NSVCode,TitleText,SiteName FROM Layout WHERE NSVCode <> '&' " & sitesql$ & " ORDER BY TitleText"
   'Set SLSnapShot = WSDB.CreateSnapshot(sql$)
   '
   'TitleStore$ = ""
   'WardStore$ = ""
   'Do While Not SLSnapShot.EOF
   '   If Trim$(GetField(SLSnapShot!TitleText)) <> TitleStore$ Then
   '         'If Trim$(TitleStore$) <> "" Then                                   '01Sep01 TH Moved below to ensure last drug
   '         '      alphaline$ = desc$ & " " & NsvStore$ & " " & onward$ & crlf$ '   "       is not omitted from the print (#51088)
   '         '      Put #devno, , alphaline$                                     '   "
   '         '   End If                                                          '   "
   '
   '         DisplayStatus "Adding - " & Trim$(GetField(SLSnapShot!TitleText)) & " " & GetField(SLSnapShot!NSVCode)
   '         desc$ = Mid$(GetField(SLSnapShot!TitleText), 1, maxnamelen)
   '         TitleStore$ = Trim$(GetField(SLSnapShot!TitleText))
   '         NsvStore$ = Trim$(GetField(SLSnapShot!NSVCode))
   '         onward$ = ""
   '         WardStore$ = ""
   '         If Trim$(TitleStore$) <> "" Then                                     '01Sep01 TH Moved from above
   '               alphaline$ = desc$ & " " & NsvStore$ & " " & onward$ & crlf$   '   "
   '               Put #devno, , alphaline$                                       '   "
   '            End If                                                            '   "
   '      End If
   '
   '   If Trim$(GetField(SLSnapShot!SiteName)) <> WardStore$ Then
   '         onward$ = onward$ & Trim$(GetField(SLSnapShot!SiteName)) & ","
   '         WardStore$ = Trim$(GetField(SLSnapShot!SiteName))
   '      End If
   '
   '   SLSnapShot.MoveNext
   'Loop
    
   '09Oct01 TH/CKJ Block written - ensures writing of last line, and avoids duplicate entries
   '        Added DISTINCT and also SiteName to Orderby
   '''SQL$ = "SELECT DISTINCT NSVCode,TitleText,SiteName FROM Layout WHERE NSVCode <> '&' " & sitesql$ & " ORDER BY TitleText, SiteName"
   ''Set SLSnapShot = WSDB.CreateSnapshot(SQL$)
   ''Set objdata = New clsDataAccess
   '''blnOK = objdata.GetRecordset(SQL$, rsStockloc, LT_BatchOptimistic)
   
   If nw > 0 Then 'And maxnum <> -1 Then
      If maxnum = -1 Then nw = 1
      For loopvar = 1 To nw
         If maxnum = -1 Then
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
            Set rsStockloc = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListForStockLoc", strParams)
         Else
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(WDname$(loopvar)))
            Set rsStockloc = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListForStockLocbySiteName", strParams)
         End If
   

         TitleStore$ = ""
         onward$ = ""
         NsvStore$ = ""
         If rsStockloc.RecordCount > 0 Then
            Do While Not rsStockloc.EOF Or onward$ <> ""                            'loop while still reading or while line to write
               If rsStockloc.EOF Then                                               'end of snapshot, but may have a line to write
                  strCurrentDesc = ""
                  strCurrentWard = ""
                  strCurrentNSVcode = ""
               Else
                  strCurrentDesc = Trim$(GetField(rsStockloc!titletext))
                  If strCurrentDesc = "" Then strCurrentDesc = "<No description entered>"    'ensure that something is printable
                  strCurrentWard = Trim$(GetField(rsStockloc!sitename))          'will not be blank in a working mdb
                  If strCurrentWard = "" Then strCurrentWard = "---"             'should not be blank, but just in case
                  strCurrentNSVcode = Trim$(GetField(rsStockloc!NSVCode))        'could be blank - will still work
                  rsStockloc.MoveNext
               End If
         
               If strCurrentDesc <> TitleStore$ Then                                'description has changed
                  If TitleStore$ <> "" Then                                      'something to store from previous pass
                     alphaline$ = TitleStore$ & " (" & NsvStore$ & ") [TAB]" & onward$ & "[CR]"
                     ParseCtrlChars dispdata$ & "\printer.ini", "RTF", alphaline$, 0
                     Put #devno, , alphaline$
                     TitleStore$ = ""
                     onward$ = ""                                             'reinitialise on committing of each line
                     NsvStore$ = ""
                  End If
                  If strCurrentDesc <> "" Then                                   'new line needs remembering
                     TitleStore$ = strCurrentDesc
                     onward$ = strCurrentWard
                     NsvStore$ = strCurrentNSVcode
                     DisplayStatus "Adding - " & strCurrentDesc & " " & strCurrentNSVcode
                  End If
               ElseIf strCurrentDesc <> "" Then                                   'no change in description, so change in ward needs adding
                  onward$ = onward$ & "," & strCurrentWard
               End If
            Loop
         End If
   
         rsStockloc.Close
         Set rsStockloc = Nothing
      '---
      Next
   End If

Return


End Sub

Sub striprtf(txt$)

   If Len(txt$) = 0 Then Exit Sub

'   Do
'      txt$ = Left$(txt$, Len(txt$) - 1)
'   Loop Until Asc(Right$(txt$, 1)) = 125
   
  If Right$(txt$, 2) = Chr$(125) & Chr$(125) Then
        txt$ = Left$(txt$, Len(txt$) - 1)
    End If
      
   If Asc(txt$) = 123 Then txt$ = Right$(txt$, Len(txt$) - 1)

End Sub

Sub WSLParse(devno%, RTFTxt$, loopvar%)
'05Mar98 Amended to stop trunction of drug descriptions

Dim startpos&, endpos&, openbracepos&, closebracepos&
Dim temp$
Dim Changed%
     
      startpos& = 1
      endpos& = Len(RTFTxt$)

      Do
         openbracepos& = InStr(startpos&, RTFTxt$, "[")
         If openbracepos& > 0 Then
            temp$ = Mid$(RTFTxt$, startpos&, (openbracepos& - startpos&))
         Else
            temp$ = Mid$(RTFTxt$, startpos&)
         End If
         Put #devno, , temp$
         
         If openbracepos& > 0 Then
               startpos& = openbracepos&
               closebracepos& = InStr(openbracepos&, RTFTxt$, "]")
               temp$ = Mid$(RTFTxt$, startpos&, closebracepos& - openbracepos& + 1)
               
               Select Case LCase$(temp$)
                  Case "[section]"
                     temp$ = drugs(loopvar).drugttl
                  Case "[descrip]"
                     Select Case loopvar
                        Case -2, -1: temp$ = ""
                        Case Else:   temp$ = drugs(loopvar).drugttl
                     End Select
                  Case "[bc]"
                     Select Case loopvar
                        Case -2, -1: temp$ = ""
                        Case Else:   temp$ = bcode$(drugs(loopvar).catno)
                        End Select
                  Case "[prepack]"
                     Select Case loopvar
                        Case -2:   temp$ = "pre- "
                        Case -1:   temp$ = "pack "
                        Case Else
                           temp$ = "[prepk-" + Trim$(UCase$(drugs(loopvar).prepack)) + "]"
                           ParseCtrlChars stocklini$, "", temp$, Changed
                        End Select
                  Case "[stklevl]"
                     Select Case loopvar
                        Case -2:   temp$ = "stock"
                        Case -1:   temp$ = "level"
                        Case Else: temp$ = Mid$(drugs(loopvar).stklevl, 1, 5)
                        End Select
                  Case "[paksize]"
                     Select Case loopvar
                        Case -2:   temp$ = "pack"
                        Case -1:   temp$ = "size"
                        Case Else: temp$ = Mid$(drugs(loopvar).paksize, 1, 4)
                        End Select
                  Case "[catnum]"
                     Select Case loopvar
                        Case -2:   temp$ = "  cat  "
                        Case -1:   temp$ = "  no.  "
                        Case Else: temp$ = UCase$(drugs(loopvar).catno)
                        End Select
                  Case Else
                     ParseCtrlChars dispdata$ & "\printer.ini", "RTF", temp$, Changed
                  End Select
               Put #devno, , temp$
            End If
         
         startpos& = closebracepos& + 1

      Loop While (openbracepos& > 0)

End Sub

Sub WSspool(filename As String, title As String, pgoffset As Integer, KillFile%, Reprintable As Long, Context$)
'05Mar 98 ASC/EAC Reprintable%, Global ReprintNo% added to allow order picking ticket and del note
'                 reprinting
'26Mar98 EAC added hourglasses
'30Sep98 TH Replaced pointer reading with picking ticket no for delivery notes
'02Dec98 TH  Read delnote pointer file for delivery note reprint no
'02Feb99 SF/CFY attempted to solve the printing of picking tickets to the wrong printer problem by use of context
'12Apr00 CFY Added Context Parameter too allow output to different printers within the stores module. If no context is
'            passed in the default context will be WsSpool as per original functionality.
'15Feb02 TH  Pass in reprintnumber if EDIOrder, use context as flag (#50749)
'19Apr04 TH  Add suppliercode to the reprintnumber in the reprint file name (enh1574)
'19Jan07 TH  Set Reprintable as long because this can contain the order number (for EDI) which can now be very long indeed !
'26Jun13 TH  Added mechanism to store reprints in database (TFS 64513)


Dim printpath$ '05Mar98 ASC/EAC

Dim strReprint As String  '13Apr04 TH (enh1574)
Dim strSupplierCode As String
Dim intloop As Integer
Dim strSupplierCodeOut As String
Dim strParams As String    '26Jun13 TH Added (TFS 64513)
Dim lngOK As Long          '    "
Dim strText As String      '    "
Dim intSuccess As Integer  '    "

   Screen.MousePointer = HOURGLASS        '26Mar98 EAC added
   If Trim$(PrintToScreen$) = "" Then ReadOrdData

   If UCase$(Context$) = "EDIORDER" Then        '15Feb02 TH Added (#50749)
         lngReprintno = Reprintable               '    "
         Reprintable = True                     '    "
      End If                                    '    "


   ' 02Feb99 SF/CFY replaced the following block
   'HEInitNewDoc HighEdit.HE.hWnd
   'ok = HELoadDoc(HighEdit.HE.hWnd, Filename$, FILEFORMAT_RTF)
   '
   'Screen.MousePointer = STDCursor        '26Mar98 EAC added
   '
   'If Trim$(PrintToScreen$) = "Y" Then
   '      If InStr(Command$, "preview") Then  '05Mar98 ASC
   '            HEdit 0, ""                  '     "
   '         Else                            '     "
   '            HEdit 2, ""                  '     "
   '         End If                          '     "
   '   Else
   '      ok = HEPrintDocParamHwndAbortDlg(HighEdit.HE.hWnd, 0, 0, 0, 0, title$, pgoffset)
   '   End If

   ' 02Feb99 SF/CFY replaced above block with the following to try and solve the printing to incorrect printer problem
   Screen.MousePointer = STDCURSOR
   If Trim$(PrintToScreen$) = "Y" Then
         If InStr(Command$, "preview") Then
               Hedit 10, filename$
            Else
               Hedit 12, filename$
            End If
      Else
         If Trim$(Context$) = "" Then                                               '10Apr00 CFY Now uses context parameter
               Context$ = "WsSpool"                                                 '            rather than hardcoded to
            End If                                                                  '            wsSpool.
         Hedit 14, Trim$(Context$) & Chr$(0) & filename$
      End If
         
   Screen.MousePointer = HOURGLASS        '26Mar98 EAC added

   'Unload HighEdit     '02Feb99 SF/CFY removed

   '05Mar98 ASC Used to take a copy for reprinting and delete to keep only last 10 days ordno'a on line
   If Reprintable Then                                                                    '05Mar98 ASC/EAC
         getprintpath printpath$, 0
         'Copy file into sub directory of dispdata
         If UCase$(Context$) <> "EDIORDER" Then       '15Feb02 TH Added (#50749)
               If picknumber% > 0 Then                   '30Sep98 TH Replaced pointer with picking ticket no for delivery notes
                     lngReprintno = picknumber%            '      "
                     picknumber% = 0                     '      "
                  Else                                   '      "
                     getorderno Edittype, lngReprintno, 0
                  End If                                 '      "
               '       "
               'getorderno edittype, ReprintNo%, 0
               If Edittype = 7 Then                        '02Dec98 TH
                     getorderno 25, lngReprintno, 0          '02Dec98 TH
                  Else                                     '02Dec98 TH
                     getorderno Edittype, lngReprintno, 0    '09Dec98 TH
                  End If                                   '02Dec98 TH
            End If
         'FileCopy FileName$, dispdata$ & printpath$ & "\" & Format$(reprintno%) & ".rtf"     '190Apr04 TH Replaced below (enh1574)
         strSupplierCode = Left$(Trim$(sup.Code) & Space$(4), 4)
         For intloop = 1 To 4
            If (Asc(Mid$(strSupplierCode, intloop, 1)) > 64 And Asc(Mid$(strSupplierCode, intloop, 1)) < 91) Or (Asc(Mid$(strSupplierCode, intloop, 1)) > 96 And Asc(Mid$(strSupplierCode, intloop, 1)) < 123) Then
               strSupplierCodeOut = strSupplierCodeOut & Mid$(strSupplierCode, intloop, 1)
            ElseIf IsDigits(Mid$(strSupplierCode, intloop, 1)) Then
               strSupplierCodeOut = strSupplierCodeOut & Mid$(strSupplierCode, intloop, 1)
            End If
         Next
         'strReprint = Right$("0000000000" & Format$(lngReprintno), 10) & Left$(Trim$(sup.code), 4)     '   "
         If TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "PadReprintNumber", 0)) Then
            strReprint = Right$("0000000000" & Format$(lngReprintno), 10) & Trim$(strSupplierCodeOut)
         Else
            strReprint = Format$(lngReprintno) & "   " & Trim$(strSupplierCodeOut)
         End If
         
         '26Jun13 TH (TFS) Now store in the DB (TFS 64513)
         If Not TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "StoreReprintFiles", 0)) Then
            'Here we make up the required output to the DB
            GetTextFile filename$, strText, intSuccess
            If intSuccess = 0 Then
               popmessagecr "", "Failure Reading File for reprint. Reprint will now be stored to file"
               FileCopy filename$, dispdata$ & printpath$ & "\" & strReprint & ".rtf"
            Else
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, Format$(gDispSite)) & _
                  gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 10, Mid$(printpath$, 2)) & _
                  gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 15, strReprint) & _
                  gTransport.CreateInputParameterXML("Document", trnDataTypeVarChar, Len(strText), strText)
      
               lngOK = gTransport.ExecuteInsertSP(g_SessionID, "PharmacyStoresReprint", strParams)
            End If
         Else
            FileCopy filename$, dispdata$ & printpath$ & "\" & strReprint & ".rtf"               '   "
         End If
        
      End If                                                                              '       "
                                                                                          '       "
   'Remove original file for spooling from spool queue                                    '       "
   On Error Resume Next                                                                   '       "
   If KillFile Then Kill filename$                                                        '       "
   On Error GoTo 0                                                                        '       "

   Screen.MousePointer = STDCURSOR        '26Mar98 EAC added

End Sub



Sub prilistSQLOLD(printbarcodes As Integer)
'29Nov05 TH Changes
'06Dec16 TH Replaced RTF Handling (TFS 157969)


Dim maxnum%, nw%, nww%, success%, escd%, devno%, loopvar% 'found%,
Dim ans$, temp$, temprtf$, secttxt$, drugtxt$, hdrtxt$, FILE$
Dim tempcode$   '06Apr99 TH
Dim temp1$, temp2$, temp3$  '11Nov99 TH
Dim strConnect As String
Dim strParams As String
Dim rsWardStock As ADODB.Recordset
Dim strTempConnect As String
Dim intStart As String
Dim intEnd As String
Dim strServer As String
Dim strPassword As String
Dim strUID As String
Dim strDB As String
Dim strPRN As String
Dim strLines() As String

   setinput 0, k
   k.HelpFile = "wslist.hlp"
   
   'SQL ForgetPrinterList

   ReadWSLDefaults

   ans$ = "n"
   maxnum = 50
   If ans$ = "Y" Then maxnum = -1                               ' all of them
   
   choosewards WDname$(), nw, maxnum
   
   If nw = 0 Then
         popmsg "Select Wards", "No wards selected.", 64, ans$, escd%
         ChangeTable "Blank", False '14Aug12 TH Added Param
         Exit Sub
      End If
   
   If nw > 50 Then
         popmessagecr "!", "Too many wards selected, first 50 will be printed."
         nw = 50
      End If
   
   'strTempConnect = Trim$(LCase$(g_adoCn.ConnectionString))      '12Aug08 CKJ pragmatic alternative  ** for review by TH  '15Aug12 CKJ removed
   strTempConnect = Trim$(LCase$(g_adoConnectionString))          '15Aug12 CKJ replacement
   
   If Right$(strTempConnect, 1) <> ";" Then strTempConnect = strTempConnect & ";"
   replace strTempConnect, "pwd=", "password=", 0
   intStart = InStr(1, strTempConnect, "server=") + 7
   intEnd = InStr(intStart, strTempConnect, ";")
   strServer = Mid$(strTempConnect, intStart, intEnd - intStart)
   intStart = InStr(1, strTempConnect, "database=") + 9
   intEnd = InStr(intStart, strTempConnect, ";")
   strDB = Mid$(strTempConnect, intStart, intEnd - intStart)
   intStart = InStr(1, strTempConnect, "uid=") + 4
   intEnd = InStr(intStart, strTempConnect, ";")
   strUID = Mid$(strTempConnect, intStart, intEnd - intStart)
   intStart = InStr(1, strTempConnect, "password=") + 9
   intEnd = InStr(intStart, strTempConnect, ";")
   strPassword = Mid$(strTempConnect, intStart, intEnd - intStart)
   
   strConnect = "ODBC: Provider=SQLOLEDB.1;DRIVER=SQL Server;Initial Catalog=" & strDB & ";DATABASE=" & strDB & ";Data Source=" & strServer & ";SERVER=" & strServer & ";Use Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;Workstation ID=XXX;Use Encryption for Data=False;Tag with column collation when possible=False;UID=" & strUID & ";PWD=" & strPassword & ";"
   
   If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "WardStock", "Y", "CrystalPrintContext", 0)) Then
               SelectPrinterFromContext "WSpool", strPRN
               'MsgBox strPRN
               If strPRN <> "" Then
                  ReDim strLines(3)
                  deflines strPRN, strLines(), ",", 0, 3
                  MainScreen.RptStockTake.PrinterDriver = strLines(2)
                  MainScreen.RptStockTake.PrinterName = strLines(0)
                  MainScreen.RptStockTake.PrinterPort = strLines(0)
                  'MainScreen.RptStockTake.SelectPrinter strLines(1), strLines(0), strLines(2)
               End If
            End If
   MainScreen.RptStockTake.Connect = strConnect 'Phartl.GetConnectionString(g_SessionID)

   If Not InStr(UCase$(Command$), "WSLISTRTF") > 0 Then                   '12Jan99 TH
         If printbarcodes = 3 Then                                  '14Jan99 TH
               If Not fileexists(dispdata$ & "\WSLISTA.RPT") Then         '    "
                     popmessagecr "Error", "Crystal report file WSLISTA.RPT missing from directory " & dispdata$ & "." & Chr$(13) & Chr$(13) & "Cannot Print Ward Stock Lists."   '12Jan99 TH
                     Exit Sub                                             '    "
                  End If                                                  '    "
               'mainscreen.Report1.ReportFileName = dispdata$ & "\wslista.rpt"         '19Jan99 TH Replaced to rationalise use of rpt control
               MainScreen.RptStockTake.ReportFileName = dispdata$ & "\wslista.rpt"      '   "
            Else
               If printbarcodes = 2 Then                                            '12Jan99 TH
                     If Not fileexists(dispdata$ & "\WSLISTB.RPT") Then         '    "
                           popmessagecr "Error", "Crystal report file WSLISTB.RPT missing from directory " & dispdata$ & "." & Chr$(13) & Chr$(13) & "Cannot Print Ward Stock Lists."  '12Jan99 TH
                           Exit Sub                                             '    "
                        End If                                                  '    "
                     'mainscreen.Report1.ReportFileName = dispdata$ & "\wslistb.rpt"     '19Jan99 TH Replaced
                     MainScreen.RptStockTake.ReportFileName = dispdata$ & "\wslistb.rpt"  '   "
                  Else                                                          '    "
                     If Not fileexists(dispdata$ & "\WSLIST.RPT") Then          '12Jan99 TH
                           popmessagecr "Error", "Crystal report file WSLIST.RPT missing from directory " & dispdata$ & "." & Chr$(13) & Chr$(13) & "Cannot Print Ward Stock Lists."   '12Jan99 TH
                           Exit Sub                                             '    "
                        End If                                                  '    "
                     'mainscreen.Report1.ReportFileName = dispdata$ & "\wslist.rpt"      '19Jan99 TH Replaced
                     MainScreen.RptStockTake.ReportFileName = dispdata$ & "\wslist.rpt"   '   "
                     'Set crRep = New CrystalReport
                     
                  End If
            End If                                                        '    "

         ''Set db = OpenDatabase(dispdata$ & "\wslist.mdb")     '11Jan99 TH Added
                                                                                                    
         For nww = 1 To nw
               getsupplier WDname$(nww), 0, 0, sup  '08Apr99 TH Prepare header information
               wardcode$ = Trim$(sup.wardcode)                 '   "
               wardexp$ = Trim$(sup.fullname)                  '   "
               wardname$ = wardexp$                            '   "
               tempcode$ = Trim$(sup.Code)
               If Len(tempcode$) > 5 Then                      '   "
                     tempcode$ = Left$(tempcode$, 2)           '   "
                  End If
                  '   "
               temp1$ = hospabbr$              '11Nov99 TH parse out ' to stop crystal error
               temp2$ = wardcode$              '   "
               temp3$ = wardexp$               '   "
               replace temp1$, "'", "", 0      '   "
               replace temp2$, "'", "", 0      '   "
               replace temp3$, "'", "", 0      '   "

               MainScreen.RptStockTake.Formulas(0) = "Hospital='" & temp1$ & "'"                 '11Nov99 TH Replaced above to use parsed names
               MainScreen.RptStockTake.Formulas(1) = "Wardcode=UpperCase('" & temp2$ & "')"      '   "
               MainScreen.RptStockTake.Formulas(2) = "Wardname='" & temp3$ & "'"
               ''MainScreen.RptStockTake.Formulas(3) = "Site=" & Format$(gWardStockSite)
                              'strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
               '            gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(WDname(nww)))
               'Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListBySiteName", strParams)
         
               MainScreen.RptStockTake.SelectionFormula = "{WWardStockList.SiteName} = '" & temp2$ & "' and {WWardStockList.SiteID} = " & Format$(gWardStockSite)
               '"{WWardStockList.SiteID} =2" ' {WWardStockList.Sitename} = 'A&E'" '" & Trim$(WDname(nww)) & "' and {WWardStockList.SiteID} = " & Format$(gWardStockSite)
               'MainScreen.RptStockTake.s = rsWardStock
               ''MainScreen.RptStockTake.
               ''If printbarcodes = 3 Then StockTake.RptStockTake.SelectionFormula = "{WWardStockList.Sitename}='" & WDname(nww) & "' and trimleft({WWardStockList.NSVCode}) <> '&' "        '     "
               On Error GoTo PrintErr
               'MainScreen.RptStockTake.PrinterName
               '      "
               If InStr(UCase$(Command$), "PREVIEW") > 0 Or TxtD(dispdata$ & "\winord.ini", "Defaults", "", "multiwsl", 0) = "Y" Then    '14Apr99 TH Added ini call
                  MainScreen.RptStockTake.Destination = 0 '   "
               Else
                  MainScreen.RptStockTake.Destination = 1
               End If                                                                            '      "
               MainScreen.RptStockTake.Action = 5 '    "
               On Error GoTo 0                                                                      '      "
         Next                                                                                       '      "
         
         ''db.Close               '07Apr99 TH Proper closure
         ''Set db = Nothing       '    "

      Else
         MainScreen.LstDisplay.Clear
         ChangeTable "WSPrinting", False '14Aug12 TH Added Param

         
         For nww = 1 To nw
            k.escd = False
            
            readward WDname$(nww), lastlin, success, 0   '  and re-fill it
      
            If lastlin > 0 Then
            
                  MakeLocalFile temprtf$
                  devno = FreeFile
                  Open temprtf$ For Binary Access Write Lock Read Write As devno
            
                  If success = False Then
                           DisplayStatus "Ward " & wardname$ & " Not Processed"
                     Else
                           DisplayStatus Trim$(Str$(lastlin)) & " lines to be printed"
                           
                           temp$ = "{"
                           Put #devno, , temp$
               
                           PrilistTop devno
            
                           'HEdit 3, rtftxt$
                           '    Else
                           '        popmessagecr "!Error", "Could not read layout file. No list will be printed."
                           '    End If
            
                           'GetTextFile dispdata$ & "\WSLSect.rtf", secttxt$, success
                           GetRTFTextFromDB dispdata$ & "\WSLSect.rtf", secttxt$, success  '06Dec16 TH Replaced (TFS 157969)

                           If Not success Then
                                 popmessagecr "Error", "There was a problem reading the RTF layout file - WSLSect.rtf"
                                 Exit Sub
                              End If
                           striprtf secttxt$
                           
                           If printbarcodes Then
                                 FILE$ = "\WSLBCode.rtf"
                              Else
                                 FILE$ = "\WSLDrug.rtf"
                              End If
                           
                           'GetTextFile dispdata$ & FILE$, drugtxt$, success
                           GetRTFTextFromDB dispdata$ & FILE$, drugtxt$, success  '06Dec16 TH Replaced (TFS 157969)

                           If Not success Then
                                 popmessagecr "Error", "There was a problem reading the RTF layout file - " & FILE$
                                 Exit Sub
                              End If
            
                           striprtf drugtxt$
            
                           If printbarcodes Then
                                 FILE$ = "\BCodehdr.rtf"
                              Else
                                 FILE$ = "\Drughdr.rtf"
                              End If
                           
                           'GetTextFile dispdata$ & FILE$, hdrtxt$, success
                           GetRTFTextFromDB dispdata$ & FILE$, hdrtxt$, success  '06Dec16 TH Replaced (TFS 157969)

                           If Not success Then
                                 popmessagecr "Error", "There was a problem reading the RTF layout file - " & FILE$
                                 Exit Sub
                              End If
                           striprtf hdrtxt$
                           Put #devno, , hdrtxt$
                           
                           For loopvar = 1 To UBound(drugs)
                              If Trim$(drugs(loopvar).catno) = "&" Then
                                    'title line
                                    WSLParse devno, secttxt$, loopvar
                                 Else
                                    'drug line
                                    WSLParse devno, drugtxt$, loopvar
                                 End If
                           Next
            
                           PrilistBottom devno
                           
                           temp$ = "}"
                           Put #devno, , temp$
            
                           Close #devno
            
                           WSspool temprtf$, "Stock List", 1, True, False, ""
            
                     End If
                    'Print
               Else
                  MainScreen.LstDisplay.AddItem "Ward: " & wardname$ & " - No items to print for this ward."
               End If
         Next
      End If

Exit Sub


PrintErr:                                '12Jan99 TH
    popmessagecr "Print Error", Error$   '    "
    Resume Next                          '    "
   

End Sub

Function LeftPad(ByVal sText As String, ByVal iLength As Integer) As String
'22Mar10 CKJ Pad with spaces to left, but do not truncate if longer than iLength

Dim iNewLength As Integer

   iNewLength = Iff(Len(sText) > iLength, Len(sText), iLength)
   
   LeftPad = Right$(Space$(iNewLength) & sText, iNewLength)

End Function
