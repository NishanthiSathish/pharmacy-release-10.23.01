Attribute VB_Name = "PRNTCTRL"
'----------------------------------------------------------------------------------
'                                 PRNTCTRL.BAS
'
'27Mar95 ASC Printer Control library allowing use of many printers initially
'            for use with small dispensary labels but could be generic
'            in future
'15Jun95 CKJ ParseCtrlChars relesed. Corrected PrinterCtrl
' 3Nov95 CKJ ParseCtrlChars & terminal$() moved to Q4ansi
'04Sep96 ASC moved printlabels from patsubs.bas
'14Nov96 EAC PrintLabels: replaced InputMsg dialog with our own InputWin
'02Dec96 ASC/CKJ added demo facility
'10Mar97 EAC/CKJ ForwardLabel: Close channel if printing under NT
'22Oct97 CKJ Forward/ReverseLabel: Now uses PatmedLblLPTtype="RTF"
'            If found then it does not forward or reverse the label, just exits.
'            Added Option Explicit
'19Jan98 CKJ RTF support added to PrintExtraLabel
'17Mar98 CKJ Printlabels: Mod to prevent leading spaces on label lines 2 onwards
'            SelectAndPrintFFlabels written - used by Dispens.frm
'24Feb99 SF  printextralabel: now fits expiry/batch# onto the last line if all lines used
'02Sep99 AE  PrintLabels: Additions to allow printing of RTF labels
'02Dec99 TH  printextralabel: Flag for old wardstocklabels
'08Dec99 TH  printextralabel: Get correct setting for nonrtf wslabels
'01Mar00 AE  Printlabels:Changed mod of 02Sep99 to use RTF parsing
'15Oct02 TH  SelectAndPrintFFlabels: Fairly major overhaul to allow for a split of the file when over 150 entries.
'            In this case the user will be asked to choose from either the first 150 entries or the others.
'            This should increase the use of this file until the demise of v8. <150 recs - should function as was
'28May04 CKJ/TH SelectAndPrintFFlabels: Rewrote avoiding use of arrays, as these have caused out of memory errors in the Editor proc.
'04Jun04 CKJ 32bit
'            removed direct printing via interrupt
'14Jul11 TH  PrintLabels: Added section to clean up local files properly (F0123007)
'21Mar13 TH  SelectAndPrintFFlabels: Reset as if the user has no context listbox may have been reset "lower down" (TFS 59398)
'----------------------------------------------------------------------------------
Option Explicit
DefInt A-Z

''Global lblprn%

''Sub FindSmallLabelPrn()
'''27Jul96 also used by ipdlist now name changed from FindPrn
''
''   If lblprn = 0 Then
''         lblprn = Val(terminal$("SmallLabelLPT", "1"))              '2Jun95 CKJ
''      End If
''
''End Sub

Function printerctrl$(cmd$)

Dim found%, Changed%
Dim MyPrinter$

   'find printer type for this terminal
''   MyPrinter$ = terminal$("PatmedLblLPTtype", "EpsonFX80")
   MyPrinter$ = "RTF"      '09May05 CKJ Only RTF is supported
   
   cmd$ = TxtD(dispdata$ & "\PRINTER.INI", MyPrinter$, "", cmd$, found)
   Do                                     '15Jun95 CKJ Added Do/Loop
      Changed = False
      ParseCtrlChars dispdata$ & "\PRINTER.INI", MyPrinter$, cmd$, Changed
   Loop While Changed

   printerctrl$ = cmd$

End Function

Sub printlabels(ByVal body As String, ByVal NumofLabels As Integer)
'ASC 26Mar95
'Prints the additional label
'06Nov96 EAC - don't use global variable as a parameter, use local variable instead
'14Nov96 EAC replace InputMsg dialog with our own InputWin
'02Sep99 AE Additions to allow printing of RTF labels
'01Mar00 AE  Changed above mod to use RTF parsing
'V93 OK
'14Jul11 TH Added section to clean up local files properly (F0123007)
 
Dim sFilename As String, iFil As Integer, Y As Integer, escaped As Integer, ans As String, success As Integer
   
   If NumofLabels < 0 Then NumofLabels = "1"
   k.nums = True
   k.Max = 3
   ans$ = Format$(NumofLabels)
   InputWin "Label printer", "Enter number of labels to print", ans$, k
   NumofLabels = Val(ans$)
   
   If NumofLabels > 0 And Not k.escd Then
      If Left$(body$, 5) = "{\rtf" Then
         MakeLocalFile sFilename
         PutTextFile sFilename, body, success
         If success Then
            'ParseThenPrint "Formula Label", sFilename, NumofLabels, 0
            'ParseThenPrint "FormulaLabel", sFilename, NumofLabels, 0  '10Jan08 TH Changed the context
            'ParseThenPrint "FormulaLabel", sFilename, NumofLabels, 0, False  '27May11 TH Added param (F0088129)
            ParseThenPrint "FormulaLabel", sFilename, NumofLabels, 0, False, True '04Jan17 TH Use Local file to parse
         End If
         
         '14Jul11 TH added section to clean up properly (F0123007)
         On Error Resume Next
         If fileexists(sFilename) Then Kill sFilename
         On Error GoTo 0
         
      Else
         For Y = 1 To NumofLabels
            If Not escaped Then escaped = 2                 'prints raw text when k.escd = 2
            printextralabel body$, escaped
            If escaped Then Exit For
         Next
      End If
   End If

   k.escd = False
   
End Sub

Sub SelectAndPrintFFlabels()
'17Mar98 CKJ Written - used by Dispens.frm, calls PrintLabels
'15Oct02 TH Fairly major overhaul to allow for a split of the file when over 150 entries.
'           In this case the user will be asked to choose from either the first 150 entries or the others.
'           This should increase the use of this file until the demise of v8. <150 recs - should function as was
'28May04 CKJ/TH Rewrote avoiding use of arrays, as these have caused out of memory errors in the Editor proc.
'21Sep05 TH Quick Overhaul to try and use new v9.3 architecture
'21Mar13 TH Reset as if the user has no context listbox may have been reset "lower down" (TFS 59398)

Dim filename$, ErrNum%, fil%, i%, Items As Integer
Dim strCode As String, strValue As String
Dim strParameters As String '21Sep05 TH Added
Dim lngOK As Long           '    "
Dim rsLookups As ADODB.Recordset

   'filename$ = dispdata$ & "\fflabels.dat"
   filename$ = "fflabels"   '21Sep05 TH Replaced to use new Wlookups
   'strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
   '                gTransport.CreateInputParameterXML("FileName", trnDataTypeChar, 255, FileName$)
   'lngOK = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWLookupCountbyContext", strParameters)
   
   strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                   gTransport.CreateInputParameterXML("Context", trnDataTypeChar, 255, filename$) & _
                   gTransport.CreateInputParameterXML("Code", trnDataTypeChar, 10, Null) & _
                   gTransport.CreateInputParameterXML("InUse", trnDataTypeBit, 1, Null)
   Set rsLookups = gTransport.ExecuteSelectSP(g_SessionID, "pWLookupSelectByCriteria", strParameters)
   

   If rsLookups.RecordCount > 0 Then
   'If fileexists(filename$) Then
   ''If lngOK = 0 Then    '21Sep05 TH Replaced Above
         Unload LstBoxFrm
         
         Do
            If LstBoxFrm.LstBox.ListCount = 0 Then
               Screen.MousePointer = HOURGLASS
               LstBoxFrm.Caption = "Print Free Format Labels"
               LstBoxFrm.lblTitle = cr & "Select label to print" & cr
               LstBoxFrm.lblHead = "  Code    " & TB & "Label"
''                  Do
''                     On Error GoTo SelectAndPrintFFlabels_Err
''                     ErrNum = 0
''                     fil = FreeFile
''                     Open FileName$ For Input As #fil
''                     Err70msg ErrNum, "File " & FileName$
''                  Loop While ErrNum
               On Error GoTo SelectAndPrintFFlabels_Err
               rsLookups.MoveFirst '21Mar13 TH Reset as if the user has no context listbox may have been reset "lower down" (TFS 59398)
               Do While Not rsLookups.EOF
                  strValue = RtrimGetField(rsLookups!Value)
                  replace strValue, crlf, " ", 0
                  strCode = RtrimGetField(rsLookups!Code)
                  LstBoxFrm.LstBox.AddItem "  " & UCase$(Trim$(strCode)) & TB & Left$(Trim$(strValue), 80) & "..."
                  rsLookups.MoveNext
               Loop
               On Error GoTo 0
               
''                  Input #fil, Items
''                  For i = 1 To Items
''                     Input #fil, strCode, strValue
''                     replace strValue, crlf, " ", 0
''                     LstBoxFrm.LstBox.AddItem "  " & UCase$(Trim$(strCode)) & TB & Left$(Trim$(strValue), 80) & "..."
''                  Next
''                  Close #fil
               Screen.MousePointer = STDCURSOR
            End If
            
            strCode = ""
            'START : AS - MM-10660 - 10.22 EdgeTesting - Print Free Format Labels modal dialog issue resolve
            If bolFirstPrintCompleted Then
                MsgBox "Print process completed!", vbInformation + vbOKOnly, "Printing status"
            End If
            'END : AS - MM-10660 - 10.22 EdgeTesting - Print Free Format Labels modal dialog issue resolve
            LstBoxShow
            bolFirstPrintCompleted = True      'AS - MM-10660 - 10.22 EdgeTesting - Print Free Format Labels modal dialog issue resolve
            strCode = LTrim$(LstBoxFrm.Tag)
            If Len(strCode) Then
               replace strCode, TB, Nul, 0
               strCode = asciiz$(strCode)
               SeqScan strCode, strValue, filename$
               If strValue = "<Invalid Code>" Then
                  popmessagecr "!", "Free Format label not found"
               Else
                  printlabels strValue, 1
               End If
            End If
         Loop While Len(strCode)
      
         Unload LstBoxFrm
      Else
         popmessagecr "!", "No Free Format labels defined"
      End If
      
      rsLookups.Close
      Set rsLookups = Nothing

SelectAndPrintFFlabels_Exit:
Exit Sub

SelectAndPrintFFlabels_Err:
   Screen.MousePointer = STDCURSOR
   popmessagecr "Procedure halted", " Error " & Format$(Err) & " while reading file " & filename$
Resume SelectAndPrintFFlabels_Exit

End Sub

Sub printextralabel(LabelText$, escd%)
'ASC 26Mar95
'Prints the additional label
'If escd% is sent in as 2 then does not look up labeltext$ just uses it
'16Jan98 CKJ Added RTF support
'17Mar98 CKJ Replaced plingparse with Replace, to prevent leading spaces on lines >=2
'24Feb99 SF  now fits expiry/batch# onto the last line if all lines used
'02Dec99 TH  Flag for old wardstocklabels
'08Dec99 TH  Get correct setting for nonrtf wslabels
'09May05 CKJ oldwardstocklabels and raw printing not supported under V93

Dim expansion As String, Numoflines%, count%, done%, oldwardstocklabels%
   
   ReDim lines$(1 To 10)
   If escd > 50 Then              '02Dec99 TH
      popmessagecr ".PrintExtraLabel", "Option not supported 'oldwardstocklabels'"
''      oldwardstocklabels = True
''      escd = escd - 50
   End If

''   lblprn = 1           '!!**
''   FindSmallLabelPrn
   expansion = ""
   If escd = 2 Then
         expansion = LabelText$
         escd = False
       Else
         'SeqScan LabelText$, expansion, dispdata$ & "\fflabels.dat"
         SeqScan LabelText$, expansion, "fflabels"  '21Sep05 TH Replaced to use new Wlookups
       End If

   If expansion <> "" And Not escd Then
      replace expansion, lf, "", 0                                 'to prevent leading space on each line
      deflines (expansion), lines$(), cr & "(*)", 1, Numoflines
      count% = GetNumEditorLines%()                                     '24Feb99 SF added
      If count% = 9 And Numoflines% = 11 Then lines$(9) = lines$(10)    '24Feb99 SF added
      
'09May05 Only RTF printing is supported
''         If oldwardstocklabels Then                                                 '08Dec99 TH Get correct setting for nonrtf wslabels
''                MyPrinter$ = UCase$(terminal$("WSLblLPTtype", "EpsonFX80"))         '   "
''             Else                                                                   '   "
''         MyPrinter$ = UCase$(terminal$("PatmedLblLPTtype", "EpsonFX80"))     '   "
''             End If                                                                 '   "
''         If MyPrinter$ <> "RTF" Or oldwardstocklabels Then                                    '02Dec99 TH
''               prn lblprn, "", True, escd
''               If Not escd Then prn lblprn, "", True, escd
''               For Count = 1 To 10
''                  ParseCtrlChars dispdata$ + "\PRINTER.INI", MyPrinter$, lines$(Count), done
''                  If Not escd Then prn lblprn, lines$(Count), True, escd
''               Next
''         Else                                                        '16Jan98 CKJ Added Block
            For count = 1 To 10
               Heap 10, gPRNheapID, "StdLbl" & Format$(count) & "A", lines$(count), 0
            Next
            'ParseThenPrint "FFLabel", dispdata$ & "\FFLabel.rtf", 1, 0
            'ParseThenPrint "FFLabel", dispdata$ & "\FFLabel.rtf", 1, 0, False  '27May11 TH Added param (F0088129)
            ParseThenPrint "FFLabel", dispdata$ & "\FFLabel.rtf", 1, 0, False, False '04Jan17 TH Use DB rtf to parse
             
''         End If
   End If

   Erase lines$

End Sub

