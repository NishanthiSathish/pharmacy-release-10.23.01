Attribute VB_Name = "HSSLPTR"
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
'??????? ??? Cut down & renamed HSSLPTR
'13Nov08 CKJ Ported from V9.8 to V10.0
'            Removed unused procedures
'              SetPrinterOptions
'              ReadWSLDefaults (note duplicated in HSSL.bas)
'              catnovalid
'              FormFeed
'              SetPRN
'              ShortenDrugDesc
'            Removed Type Barcode, Const maxlin & numerous module level vars
'            Set DefBool


'-----------------------------------------------------------------------------
DefBool A-Z
Option Explicit

''Type barcode
''   bcode As String * 13
''End Type

'Declarations
'    Const maxlin = 1000

Const modulename$ = "WSPRINT.BAS"

Global PrintToScreen$   'allows printing to be sent to highedit preview
                        'useful for testing changes to layouts - set in Set Working Defaults

''   Dim VTpos%, lastlin%
''   Dim WdName$(300)
''   Dim T(10), thoris$(10)             ' used in building HORIS barcodes
''   Dim tt$(10)      ' used in building HORIS barcodes
''   Dim esc$
   'Dim Shared d(maxlin + 1) As drugdetails
''   Dim dpp As DrugParameters
   'Dim Shared wardname$, wardcode$, pagenum%, linenum%
''   Dim wardname$, pagenum%, linenum%
''   Dim PageLen%, HdrALen%, HdrBLen%, DrugLen%, SectLen%, FootLen%, SignLen%, lin%, BCodeLen%
''   Dim stocklini$
''   Dim density%, devno%
   
   Dim picknumber% '17Sep07 TH


''Sub FormFeed(outfile$, devno)
'''Do a form feed
''
''      'DisplayStatus "Spooling ... "
''      Close #devno
''      ParseAndSpool outfile$
''      MakeLocalFile outfile$
''      devno = FreeFile
''      Open outfile$ For Output As #devno
''End Sub

Sub PrinterParse(txt$)

Dim Changed%

    Do
        Changed = False
        ParseCtrlChars dispdata$ & "\printer.ini", "RTF", txt$, Changed
    Loop While Changed


End Sub

''Sub ReadWSLDefaults()
''
''Dim found%
''
''   stocklini$ = dispdata$ + "\stockl.ini"
''   'usable lines per page excluding the footer (if used)
''   PageLen = Val(TxtD$(stocklini$, "", "60", "PageLen", found))
''   'lines used in 1st page header
''   HdrALen = Val(TxtD$(stocklini$, "", "10", "HdrALen", found))
''   'lines used in subsequent page headers
''   HdrBLen = Val(TxtD$(stocklini$, "", "5", "HdrBLen", found))
''   'lines used per drug
''   DrugLen = Val(TxtD$(stocklini$, "", "2", "DrugLen", found))
''   'lines used per drug
''   BCodeLen = Val(TxtD$(stocklini$, "", "3", "BCodeLen", found))
''   'lines used per section name
''   SectLen = Val(TxtD$(stocklini$, "", "3", "SectLen", found))
''   'lines used in footer
''   FootLen = Val(TxtD$(stocklini$, "", "3", "FootLen", found))
''   'lines used in signature block
''   SignLen = Val(TxtD$(stocklini$, "", "15", "SignLen", found))
''
''End Sub

''Sub SetPrinterOptions()
''
''Dim errored
''
''   errored = False
''   On Error GoTo SPOErr
''   Dctfrm.Tag = &H40   'Printer Setup dialog only
''
''   'Dctfrm.DirList.  Action = 5
''   On Error GoTo SPOErr
''
''   If errored Then
''         popmessagecr "Error", "There is a problem with the way your printer is configured for Windows." & cr$ & "Please check the settings and try again."
''      Else
''         'HEWinIniChange HighEdit.HE.hWnd, "Windows"
''         'HERedraw HighEdit.HE.hWnd, True
''      End If
''
''Exit Sub
''
''SPOErr:
''
''   errored = True
''   Resume Next
''
''End Sub

''Sub setprn(chan As Integer, chars As String)
'''10Aug95 CKJ Resolve printer references here if not spooling
'''09Oct96 EAC Change to HighEdit printing
''
''Dim Changed%
''
''
''   'IF lpt1 <> "" THEN MyPrinter$ = terminal$("SpoolLPTtype", "EpsonFX80")
''
''   Do
''      Changed = False
''      ParseCtrlChars stocklini$, "", chars$, Changed
''      ParseCtrlChars dispdata$ & "\printer.ini", "RTF", chars$, Changed '09Oct96 EAC
''      'ParseDataItems chars$, changed
''   '   IF lpt1 <> "" THEN               'printing direct to port
''   '         ParseCtrlChars dispdata$ + "\printer.ini", MyPrinter$, chars$, changed
''   '      END IF
''   Loop While Changed
''
''   Print #chan, chars$;
''
''End Sub

''Function ShortenDrugDesc%(descr$)
''
''Dim drug As String
''Dim rep$
''Dim lrep%
''
''
''    drug$ = descr$
''
''        If InStr(drug$, "EYE OINTMENT") Then: rep$ = "OC":
''        If InStr(drug$, "EYE DROPS") Then lrep = 9:       rep$ = "GU":        GoSub shorten
''        If InStr(drug$, "OINTMENT") Then lrep = 8:        rep$ = "Oint":      GoSub shorten
''        If InStr(drug$, "CREAM") Then lrep = 5:           rep$ = "Cr":        GoSub shorten
''        If InStr(drug$, "TABLETS") Then lrep = 7:         rep$ = "Tabs":      GoSub shorten
''        If InStr(drug$, "MG IN 5") Then lrep = 7:         rep$ = "mg/5":      GoSub shorten
''        If InStr(drug$, "CAPSULES") Then lrep = 8:        rep$ = "Caps":      GoSub shorten
''        If InStr(drug$, "SUPPOSITORIES") Then lrep = 13: rep$ = "Sup":        GoSub shorten
''        If InStr(drug$, "SUSPENSION") Then lrep = 10: rep$ = "Susp":          GoSub shorten
''        If InStr(drug$, "SUPPOS") Then lrep = 6:          rep$ = "Sup":       GoSub shorten
''        If InStr(drug$, "DROPS") Then lrep = 5:           rep$ = "Drp":       GoSub shorten
''        If InStr(drug$, "UNITS") Then lrep = 5:           rep$ = "U":         GoSub shorten
''        If InStr(drug$, "MIXTURE") Then lrep = 7:         rep$ = "Mist":      GoSub shorten
''        If InStr(drug$, "ELIXIR") Then lrep = 6:          rep$ = "Elx":       GoSub shorten
''        If InStr(drug$, "LOTION") Then lrep = 6:          rep$ = "Lot":       GoSub shorten
''        If InStr(drug$, "PATCHES") Then lrep = 7:         rep$ = "Patch":     GoSub shorten
''        If InStr(drug$, "SACHETS") Then lrep = 7:         rep$ = "Sac":       GoSub shorten
''        If InStr(drug$, "PESSARIES") Then lrep = 9:       rep$ = "Pes":       GoSub shorten
''        If InStr(drug$, " AND") Then lrep = 4:            rep$ = " &":        GoSub shorten
''        If InStr(drug$, "SYRINGE") Then lrep = 7:         rep$ = "Syg":       GoSub shorten
''        If InStr(drug$, "SPRAY") Then lrep = 5:           rep$ = "Spr":       GoSub shorten
''        If InStr(drug$, "PASTE") Then lrep = 5:           rep$ = "Pst":       GoSub shorten
''        If InStr(drug$, "S.R.") Then lrep = 4:            rep$ = "SR":        GoSub shorten
''        If InStr(drug$, "S/R") Then lrep = 3:             rep$ = "SR":        GoSub shorten
''        If InStr(drug$, "MICROGRAMS") Then lrep = 10: rep$ = "mcg":           GoSub shorten
''        If InStr(drug$, "MICROGRAM") Then lrep = 9:       rep$ = "mcg":       GoSub shorten
''        If InStr(drug$, "LINCTUS") Then lrep = 7:         rep$ = "Linct":     GoSub shorten
''        If InStr(drug$, "LIQUID") Then lrep = 6:          rep$ = "Liq":       GoSub shorten
''        If InStr(drug$, "INJECTION") Then lrep = 9:       rep$ = "Inj":       GoSub shorten
''        If InStr(drug$, "TINCTURE") Then lrep = 8:        rep$ = "Tinct":     GoSub shorten
''        If InStr(drug$, "POWDER") Then lrep = 6:          rep$ = "Pdr":       GoSub shorten
''        If InStr(drug$, "SOLUTION") Then lrep = 7:        rep$ = "Sol":       GoSub shorten
''        If InStr(drug$, "MINIJETS") Then lrep = 8:        rep$ = "mjet":      GoSub shorten
''        If InStr(drug$, "IRRIGATION") Then lrep = 10: rep$ = "Irr":           GoSub shorten
''        If InStr(drug$, "SYRUP") Then lrep = 5:           rep$ = "syr":       GoSub shorten
''        If InStr(drug$, "TRINITRATE") Then lrep = 10: rep$ = "Trinit.":       GoSub shorten
''        If InStr(drug$, "CHLORIDE") Then lrep = 8:        rep$ = "Cl":        GoSub shorten
''        If InStr(drug$, "CITRATE") Then lrep = 7:         rep$ = "Cit":       GoSub shorten
''        If InStr(drug$, "SULPHATE") Then lrep = 8:        rep$ = "Sulph":     GoSub shorten
''        If InStr(drug$, "DECANOATE") Then lrep = 9:       rep$ = "Dec.":      GoSub shorten
''        If InStr(drug$, "CROMOGLYCATE") Then lrep = 12: rep$ = "Cromogly.": GoSub shorten
''        If InStr(drug$, "BROMIDE") Then lrep = 7:         rep$ = "Br":        GoSub shorten
''        If InStr(drug$, "SODIUM") Then lrep = 6:          rep$ = "Na":        GoSub shorten
''        If InStr(drug$, "SOD.") Then lrep = 4:            rep$ = "Na":        GoSub shorten
''        If InStr(drug$, "IRON") Then lrep = 4:            rep$ = "Fe":        GoSub shorten
''        If InStr(drug$, "LITHIUM") Then lrep = 7:         rep$ = "Li":        GoSub shorten
''        If InStr(drug$, " AMPS.") Then lrep = 6:          rep$ = "":          GoSub shorten
''        If InStr(drug$, " AMPS") Then lrep = 5:           rep$ = "":          GoSub shorten
''        If InStr(drug$, "INJ") Then lrep = 3:             rep$ = "Ij":        GoSub shorten
''        If InStr(drug$, "CAPS") Then lrep = 4:            rep$ = "C":         GoSub shorten
''        If InStr(drug$, "TABS") Then lrep = 4:            rep$ = "T":         GoSub shorten
''        If InStr(drug$, "MG") Then lrep = 2:              rep$ = "":          GoSub shorten
''
''
''
''Exit Function
''
''shorten:
''
''Return
''
''End Function

Sub striprtf(txt$)

    Do
        txt$ = Left$(txt$, Len(txt$) - 1)
    Loop Until Asc(Right$(txt$, 1)) = 125
    
    If Right$(txt$, 2) = Chr$(125) & Chr$(125) Then txt$ = Left$(txt$, Len(txt$) - 1)
    If Asc(txt$) = 123 Then txt$ = Right$(txt$, Len(txt$) - 1)

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



Dim printpath$ '05Mar98 ASC/EAC

Dim strReprint As String  '13Apr04 TH (enh1574)
Dim strSupplierCode As String
Dim intloop As Integer
Dim strSupplierCodeOut As String

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
                     getorderno edittype, lngReprintno, 0
                  End If                                 '      "
               '       "
               'getorderno edittype, ReprintNo%, 0
               If edittype = 7 Then                        '02Dec98 TH
                     getorderno 25, lngReprintno, 0          '02Dec98 TH
                  Else                                     '02Dec98 TH
                     getorderno edittype, lngReprintno, 0    '09Dec98 TH
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
         FileCopy filename$, dispdata$ & printpath$ & "\" & strReprint & ".rtf"               '   "
        
      End If                                                                              '       "
                                                                                          '       "
   'Remove original file for spooling from spool queue                                    '       "
   On Error Resume Next                                                                   '       "
   If KillFile Then Kill filename$                                                        '       "
   On Error GoTo 0                                                                        '       "

   Screen.MousePointer = STDCURSOR        '26Mar98 EAC added

End Sub
