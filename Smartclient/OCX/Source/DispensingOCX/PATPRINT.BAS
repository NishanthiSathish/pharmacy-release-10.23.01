Attribute VB_Name = "PatPrint"
'30Jun99 CFY Written
'Patient Printing Module

'11Oct99 CFY CreateTimeRanges: Moved from blister.bas to here as is now also used for PIL printing.
'            Removed call to GetTimes so that routine can be used generically. Range$() must now be passed in.
'            PILPrinting: Rewritten so that any number of drugs can be printed on the same PIL.
'             Now also contains dosing information.
'19Oct99 CFY DoDischarge: Code added to add an extra discharge event with a pre-specified discharge letter attached.
'20Oct99 CFY Ability to print discharge letters from the patient printing form added
'27Oct99 CFY PatientPrinting: OnlyIssues flag now picked up from form and not hardcoded.
'            PatientPrintFormInit: Code added to handle OnlyIssues checkbox
'            Config811: Added progress bar when converting PIL's to RTF
'28Oct99 CFY DoDischarge: Added code to initialise teamwork just in case.
'16Nov99 CFY WriteRecords: Fix so that date ranges are converted to the correct format and compared correctly
'17Nov99 CFY medicard: Implemented Preview function
'            pilprinting: Implemented Preview function
'07Dec99 AW PatientPrintingSave: Created To allow default values for PatientPrinting screen to be saved
'            PatientPrintingFormInit: Changed to allow default values to be read from ini file
'13Dec99 SF  medicard: merged TH's mods: 27Oct99, 03Nov99, 17Nov99
'13Dec99 SF  medicard: fix to stop incorrect dose being put into the instruction box if over four time slots setup in the direction
'20Dec99 CFY PILPrinting: Improved descriptions which are built up to provide dosing information. Also corrected logic which decides
'            if a dose is given at breakfast, lunch, teatime etc...
'19Jan00 AE  DoDischarge:  Merged code from backup which had got lost in the original merge
'28Apr00 ATW PatientPrinting: evt 23951; Short loop truncates list of Medication types for printing on medication card - removed spurious -1
'14Jun00 AE  DoDischarge:Added Parameters to calls to Selector
'14Dec00 CKJ DoDischarge: 'Discharger' section moved from ParseRx where it created multiple events for each item
'            Copy taken of labf, FindFile and the l structure & restored afterwards.
'17Jan01 CKJ DischargePrint, DoDischarge: Removed parsing of pid.recno into filename - it has to be kept intact as the extension gets replaced
'            DischargePrint: Corrected wildcard lookup of patient files                                       (#49977)
'13Aug01 SF  added for CMI enhancement
'            PatientPrinting: calls CMIPrinting if chosen
'            added CMIPrinting: to deal with CMI ehancement
'22Oct01 SF  CMIPrinting: ensures the CMI field isn't blank otherwise don't write to the file
'        SF  CMIPrinting: now includes the case number in the output
'30Oct01 CKJ DoDischarge: Added option to allow message to be rewritten
'             Added option to allow radio button selection with site defined text
'10Nov01 CKJ medicard: Added > 0 to "syrup" comparison
'================ V8.5 ==================
'11Jan02 CKJ medicard: print one copy only using each context
'13May02 CKJ DoDischarge: Now defaults to first InUse summary, not where ID=1 as that may not be in use
'07Jun02 CKJ DoDischarge: One level of indirection was missing, picking wrong summary when default not used
'            Now finds the number of matches, not just the first one, then shows list to the user
'            Selected one has name added to the displayed caption
'            No longer defaults to first inuse summary when no match is found - warns user instead.
'17Jul02 TH  WriteRecords: Mod to allow UMMC to print history items on PMC (#61986)
'12Sep02 ATW Added Invoice printing for flexible billing
'30Sep02 TH/ATW PatientPrinting: Now uses localfile to build prints from instead of hardcoded constant (#63694)
'10Feb03 TH  Fixed Merge Error between 8.4UMMC and 8.5r2
'27Jul04 TH  Various mods for Wigan Discharge Interface
'18Aug04 TH  Medicard: Removed line - Merge Error
'18Oct04 TH  medicard: Use Filecopy not Name for output to allow for different drives to be specified
'16Aug05 CKJ/TH DoDischarge: Added FillHeapLabelInfo
'20Sep05 CKJ/PJC DoDischarge: Added FillHeapDrugInfo
'30Mar06 CKJ CMIprinting: use LocalRootPath
'20Nov06 PJC DoDischarge: ParseRX now called with an array holding the local file names/paths used for the dischage letter. (#78186)
'12Jan07 PJC PILPrinting: Added RxDescriptionRaw for each label to the print heap.(SC-06-0474 #84583)
'12Jan07 PJC medicard: Added the patmed setting (PrintformV + DPSForm + issueunitonpmc="Y) to force the non-division by dosesperissueunit on the medication record card. i.e. 0.2 nebule to be used in the nebuliser (#64962/69322/47878)
'15Jan07 PJC WriteRecords: PIL printing excludes drugs without PIL information if configured. Passing in the document type. Test for the document type and the presence of a PIL number if configured.
'            PatientPrinting: Calls to WriteRecords now pass in the document type.
'18Jan07 TH  medicard: Borders enhancement (DR-06-0235)
'08Mar07 PJC medicard: Because the label written to the temp file now contains the Directions marker, the l.text itself needs to be parsed before putting it on the print heap. (SC-06-0474 #84583)
'            WriteRecords: GetLabel now called with flag that preserves the Directions Marker in l.text, allowing RxDescriptionRaw and RxDirectionsRaw to be determined for PIL printing. (SC-06-0474 #84583)
'13Mar07 TH  medicard: Added Additional checks on blnPRNPrint to ensure previous functionality retained.
'07Apr10 AJK HILaunchLeaflet Ported from v8 and tweaked (F0072542)
'14Jan13 TH  PILPrinting: Reinstated as port for version 10 (TFS 46360,51368)
'17Jan13 TH  PILPrinting: fix l.dose fencepost bug (TFS 53471)
'15Feb13 XN  WriteRecords: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'29Dec14 XN  medicard: If doseless then should not print out the dose value on PMC 89292
'06Dec16 TH  medicard: Replaced RTF Handling (TFS 157969)
'07Dec16 TH  DischargePrint: Removed as never called - simplify rtf printing changes
'04Jan17 TH  medicard: Changes to use layout from DB (Hosted) (TFS 157969)
'04Jan17 TH  PILPrinting: Changes to RTF Handling (TFS 157969)
'12Jan17 TH  WriteRecords: Refactored to use DB rtf handling (Hosted)
'12Jan17 TH  PILPrinting: refactored using new sub to use DB rtf handling (Hosted)
'25Jan17 TH  PILPrinting: Replaced parsertf to use new DB rtf sub (Hosted) (TFS 174610)
'03Feb17 TH  PILPrinting: Use new marker for local file inclusion (TFS 174610)
'03Feb17 TH  medicard: DB RTF Handling now also allows local file include on #includx (TFS 174610)
'14Mar17 TH  PILPrinting: Added check for pil.rtf - long standing fault led to proble when file is used below but isnt available (TFS 179340)


DefInt A-Z
Option Explicit

'Const cTmpFile = "c:\rx.tmp"                 'Temp file used to store which Rx's to print
Dim cTmpFile As String                       '25Sep02 TH/ATW Replaced above     '10Feb03 TH Added (Merge Error between 8.4UMMC and 8.5r2)
Const cCMIFile = "\CMIPRINT.ASC"             '13Aug01 SF added for CMI enhancement
Const cPIL = "1"                             'Document Types
Const cPMC = "2"                             '      "
Const cDischargeLtr = "3"                    '      "
Const cCMI = "4"                             '13Aug01 SF added for CMI enhancement
Const cInvoice = "5"                         '12Sep02 ATW added for billing invoice print
Const cPMCInterface = "6"                    '27Jul04 TH Added
Const cPILContext = "PIL"                    'Generic Contexts
Const cPMCContext = "PMC"                    '      "
Const cDischargeLtrContext = "DisLtr"        '      "
Const cMaxLayouts = 10

Type TDocsInfo
   DocType As String * 1
   RTFLayout(cMaxLayouts) As String * 12
End Type

Type TTimeRange                                 'Holds time ranges      '11Oct99 CFY Moved from blister.bas
   Hrs As Integer
   min As Integer
End Type

Type TPILDoseInfo
   StartTime As TTimeRange
   StopTime As TTimeRange
   desc As String * 20
End Type

Dim DocsInfo() As TDocsInfo              'Holds information for each configured document type
Dim lines(25) As String
Dim NumDocs%
Dim PatientTypes$


Sub ArchiveDischargeLtr(recno$, success%)
'

Dim filename$, found$, ext%
   
   success = True
   Screen.MousePointer = HOURGLASS
   ext = 999
   filename$ = Hex(Val(Right$(recno$, 8)))
   
   'Find the latest discharge letter for this patient.
   Do
      found$ = Dir$(patdatapath$ & "\dischrg\archive\" & filename$ & "*." & Format$(ext%, "000"))
      ext = ext - 1
   Loop Until found$ <> "" Or ext = 0
   ext = ext + 1

   'Make copy to archive folder
   On Error GoTo ArchiveDischargeLtr_Err
   FileCopy patdatapath$ & "\dischrg\" & filename$ & ".000", patdatapath$ & "\dischrg\archive\" & filename$ & Format$(ext, "000")

ArchiveDischargeLtr_Exit:
   Screen.MousePointer = STDCURSOR
   On Error GoTo 0
   Exit Sub

ArchiveDischargeLtr_Err:
   success = False
   Resume ArchiveDischargeLtr_Exit

End Sub

Sub CallPatientPrinting()

   FrmPatPrint.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form

End Sub

Sub CMIPrinting(ByVal i_intCopies As Integer, ByVal i_intPreview As Integer)
'''************************************************************************************************************
'''* Description:     Creates a file that can be picked up and processed by the CMI Printing program.
'''*                  This may reside on the client machine or server depening on each terminal's setup.
'''*
'''* Inputs:          i_intCopies     - Number of copies of the CMI leaflet to be printed
'''*                  i_intPreview    - Send directly to printer or preview on the screen
'''
'''Modification History:
'''13Aug01 SF  written
'''22Oct01 SF  ensures the CMI field isn't blank otherwise don't write to the file
'''        SF  now includes the case number in the output
'''30Mar06 CKJ use LocalRootPath
'''************************************************************************************************************
''
''Dim udtL As WLabel
''Dim udtD As DrugParameters
''
''Dim intInputFileChan As Integer
''Dim intOutputFileChan As Integer
''Dim intReturnValue As Integer    '01Jun02 All/CKJ was used for getdrug & shell, now for shell only
''Dim strOutput As String
''Dim strClientPrint As String
''Dim strPath As String
''Dim lngDrugFound As Long         '01Jun02 All/CKJ
''
''   On Error GoTo ErrorHandler
''
''   ' ensure there's an input file to process
''   If fileexists(cTmpFile$) Then
''
''         ' check where CMI printing to be done and point to the appropriate location
''         strClientPrint = Trim$(TxtD(dispdata$ & "\TERMINAL.INI", TerminalName$, "", "CMIPrintProgram", 0))
''         If Len(strClientPrint) > 0 Then                    ' printing to be done on the client
''               'strPath = "C:"                              '30Mar06 CKJ use LocalRootPath
''               strPath = LocalRootPath()                    '   "
''               strPath = Left$(strPath, Len(strPath) - 1)   '   "        remove trailing \
''            Else                                            ' printing to be done on the server
''               strPath = dispdata$
''            End If
''
''         ' open input and and read the PID header
''         intInputFileChan = FreeFile
''         Open cTmpFile$ For Binary As intInputFileChan
''         Get #intInputFileChan, , pid
''         'skip over the extra two chars
''         strOutput = Space$(2)
''         Get #intInputFileChan, , strOutput
''
''         ' open output file
''         intOutputFileChan = FreeFile
''         Open strPath & cCMIFile For Append As intOutputFileChan
''
''         ' process the file of labels
''         Do While Not EOF(intInputFileChan)
''         ' get a label record
''         Get #intInputFileChan, , udtL
''         'skip over the extra two chars
''         strOutput = Space$(2)
''         Get #intInputFileChan, , strOutput
''
''         ' ensure it has a valid product code
''         If PatternMatch(udtL.SisCode, "AAA999A") Then
''
''               ' get product so CMI code can be used
''               cleardrug udtD
''               udtD.SisCode = udtL.SisCode
''               getdrug udtD, 0, lngDrugFound, False      '01Jun02 All/CKJ
''
''               ' check if product found
''               If lngDrugFound > 0 Then                  '01Jun02 All/CKJ
''
''                     ' ensure this product has a CMI code
''                     'If Len(udtD.PIL2) > 0 Then      '22Oct01 SF replaced
''                     If Trim$(udtD.PIL2) <> "" Then   '22Oct01 SF ensures isn't blank
''
''                           ' build line for output: CMI Code, Preview?, Number of copies, Patient Name, Address1, Address2
''                           strOutput = Trim$(udtD.PIL2) & ","
''                           strOutput = strOutput & Format$(i_intPreview) & ","
''                           strOutput = strOutput & Format$(i_intCopies) & ","
''                           '22Oct01 SF now includes the case number
''                           'strOutput = strOutput & Trim$(pid.forename) & " " & Trim$(pid.surname) & ","
''                           strOutput = strOutput & Trim$(pid.forename) & " " & Trim$(pid.surname) & " (" & Trim$(pid.caseno) & "),"
''                           '22Oct01 SF -----
''                           strOutput = strOutput & Trim$(pidExtra.Address1) & ","
''                           strOutput = strOutput & Trim$(pidExtra.Address2)
''
''                           ' write line to output file
''                           Print #intOutputFileChan, strOutput
''                        End If
''                  End If
''            End If
''         Loop
''
''         ' close file channels
''         Close intInputFileChan
''         Close intOutputFileChan
''
''         ' print on client by shelling to the print program
''         If Len(strClientPrint) > 0 Then
''               intReturnValue = Shell(strClientPrint, 6)
''            End If
''
''      End If
''
''
''' ----------------------------- error handling and exit
''Cleanup:
''   On Error GoTo 0
''Exit Sub
''
''ErrorHandler:
''   strOutput = "Error in PATPRINT.BAS: CMIPrinting" & cr$ & cr$
''   strOutput = strOutput & "Error: " & Error$ & cr$
''   strOutput = strOutput & "Err:   " & Err & cr$
''   popmessagecr ".ASCribe", strOutput
''Resume Cleanup

End Sub



Sub CreateTimeRanges(FromRange() As TTimeRange, ToRange() As TTimeRange, range() As String, NumRanges%)
'14Jan97 CFY Created
'DESCRIPTION
' Creates a set of from and to ranges based on the times allocated for each blister column
' in patmed.ini.
'
' eg. The following times in patmed.ini: 0815, 1300, 1800, 2100 will produce the following:
'
'     FromRange      ToRange
'     Hrs Mins       Hrs Mins
'     08  15         12  59
'     13  00         17  59
'     18  00         20  59
'     21  00         08  14
'
'11Oct99 CFY Moved from blister.bas to here as is now also used for PIL printing.
'            Removed call to GetTimes so that routine can be used generically. Range$() must now be passed in.



'Dim Range$()
Dim MTimes$, TempTime$, TempHrs%, TempMin%
Dim Numoflines%, X%

   ReDim FromRange(NumRanges)
   ReDim ToRange(NumRanges)
   
   'GetTimes range$(), NumRanges         '11Oct99 CFY Removed

   For X = 1 To NumRanges
      FromRange(X).Hrs = Val(Left$(range(X), 2))
      FromRange(X).min = Val(Right$(range(X), 2))
   
      If X < NumRanges Then
            TempTime = Format$(Val(range(X + 1)) - 1, "0000")
         Else
            TempTime = Format$(Val(range(1)) - 1, "0000")
         End If
      
      TempHrs = Val(Left$(TempTime, 2))
      TempMin = Val(Right$(TempTime, 2))
      If TempHrs < 0 Then TempHrs = 23
      If TempMin < 0 Or TempMin > 59 Then TempMin = 59

      ToRange(X).Hrs = TempHrs
      ToRange(X).min = TempMin
   Next

End Sub
'07Dec16 TH Removed as never called - simplify rtf printing changes
'Sub DischargePrint(caseno As String, copies%, preview, ErrMsg$)
''20Oct99 CFY Added
''17Jan01 CKJ Removed parsing of pid.recno into filename - it has to be kept intact as the extension gets replaced
''            Corrected wildcard lookup of patient files
'
'Dim OK%, Numoflines%, NumofCopies%, i%, j%, success%
'Dim patfile$, temp$, result$
'
'   ReDim FileInfo$(10)
'
'   'See if a discharge letter exists
'   'If Len(trimz$(PID.recno)) > 8 Then                                                      '17Jan01 CKJ Removed
'   '      patfile$ = Left$(trimz$(PID.recno), 8) & "." & Mid$(trimz$(PID.recno), 9) & "_"   '   "
'   '   Else                                                                                 '   "
'   '      patfile$ = trimz$(PID.recno)                                                      '   "
'   '   End If                                                                               '   "
'   'patfile$ = patdatapath$ & "\" & patfile$                                                '   "
'   patfile$ = patdatapath$ & "\" & trimz$(pid.recno)                                        '   "    Keep pid.recno intact
'
'   'If FileExists(patfile$ & "*.*") Then                                                    '17Jan01 CKJ Removed
'   If fileexists(patfile$ & ".*") Then                                                      '   "        Only add extension
'         OK = True
'      Else
'         OK = False
'         ErrMsg$ = "Discharge letter(s) cannot be located for this patient"
'      End If
'
'   If OK Then
'         'Display list of available letters to print
'         NumofCopies = Val(TxtD(dispdata$ & "\patmed.ini", "Discharge", "", "MaxCopyNum", 0))
'         frmoptionset 0, "Choose Copies"
'         For i = 1 To NumofCopies
'            temp$ = TxtD(dispdata$ & "\patmed.ini", "Discharge", "", Format$(i), 0)
'            deflines temp$, lines$(), "|", 1, Numoflines
'            FileInfo$(i) = lines$(1)
'            frmoptionset 1, FileInfo$(i)
'         Next
'
'         frmoptionshow "00", result$
'
'         'Print selected copies
'         For i = 1 To NumofCopies
'            If Mid$(result$, i, 1) = "1" Then
'                  temp$ = ""
'                  For j = 1 To copies
'                     success = False
'                     If fileexists(patfile$ & "." & Format$(i, "000")) Then
'                           success = True
'                           If preview Then
'                                 Hedit 11, patfile$ & "." & Format$(i, "000")
'                              End If
'                           Hedit 14, cDischargeLtrContext & Chr$(0) & patfile$ & "." & Format$(i, "000")
'                        End If
'                  Next
'
'                  If Not success Then
'                        ErrMsg$ = crlf & ErrMsg$ & "Could not find or print " & FileInfo$(i) & " copy"
'                     End If
'
'               End If
'         Next
'      End If
'
'
'End Sub

Sub HILaunchLeaflet()
'07Apr10 AJK Ported from v8 (F0072542)
Dim strHIMsg As String
Dim strHIAns As String
Dim strHIURL As String
Dim strHIPharmcode As String
Dim objHIL As New frmHIL
Dim strIndication As String
Dim strCaption As String


strHIMsg = "Do you wish to print a Health Informatics leaflet for this medicine and patient?"
strHIMsg = TxtD(dispdata$ & "\PATMED.INI", "HIURL", strHIMsg, "HIMsg", 0)
strHIAns = TxtD(dispdata$ & "\PATMED.INI", "HIURL", "N", "HIDefault", 0)
strHIURL = TxtD(dispdata$ & "\PATMED.INI", "HIURL", "", "RootURL", 0)
strHIURL = TxtD(dispdata$ & "\PATMED.INI", "HIURL", strHIURL, "RootURL" & d.HIProduct, 0)
strHIPharmcode = TxtD(dispdata$ & "\PATMED.INI", "HIURL", "", "HIPharmcode", 0)
strCaption = TxtD(dispdata$ & "\PATMED.INI", "HIURL", "", "FormCaption", 0)


   'Debug strHIURL = "http://www.leaflets.healthinformation.nhs.uk/pm/age=[page]&indication=[iIndication]"  '!!DEMO
   'askwin "?ASCribe", strHIMsg, strHIAns, k
   Set objHIL = New frmHIL
   Load objHIL
   If UCase(strHIAns) = "Y" Then
         objHIL.Tag = "Y"
      Else
         objHIL.Tag = "N"
      End If
   objHIL.Label2.Caption = strHIMsg
   If Val(d.HIProduct) = 2 Then
         objHIL.fraIndication.Enabled = True
         objHIL.txtIndication.Enabled = True
         objHIL.Label1.Enabled = True
      Else
         objHIL.fraIndication.Enabled = False
         objHIL.txtIndication.Enabled = False
         objHIL.Label1.Enabled = False
      End If

   objHIL.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form

   If objHIL.Tag = "Launch" Then
         strIndication = objHIL.txtIndication.text
      
         strIndication = URLEscape(strIndication)
         'Now this must go onto the heap
      
         Heap 10, gPRNheapID, "iIndication", strIndication, 0
         Heap 10, gPRNheapID, "HIPharmcode", strHIPharmcode, 0
      
         ParseItems gPRNheapID, strHIURL, 0
      
               
      
         If Not k.escd Then
               'Launch !!!
               'launchfile strHIURL, "", 0
'            Dim webForm As New frmWebClient
'            webForm.Caption = strCaption
'            webForm.Navigate strHIURL
'            Load webForm
'            webForm.Show 0
            'Unload webForm
            ShellExecute 0, "open", strHIURL, vbNullString, vbNullString, 1&

            End If
      End If
   Unload objHIL



End Sub


Sub medicard(Layout$, copies%, preview%, ErrMsg$, blnInterface As Integer)
'09Aug99 SF 8.11 medication card. 8.066 medication card renamed to Medicard8066: as all the changes made would
'           have made it very messy.  Fixes/enhancments include:

'               deletes all local files used to create the card
'               puts the correct dose in the appropraite box if different doses specified in the directions
'               ini file option to add additional CRs to each printed line which allows each row to be more clearly separated
'               prints free text labels in either the medication or instructions box
'               only prints the drug instructions and warnings if setup to do so in the ini file
'               has ini file option to print numeric dose.  Eg. print "1" instead of "Take ONE table"
'               allow sorting in either ascending or descending order if setup to do so in the ini file
'               parses each of the rows written with the heap drug and label info
'21Oct99 TH  Code to deal with syrups/suspensions etc as correct dose for given time
'27Oct99 TH  Use temp2$ on all checks in above mod
'03Nov99 TH  Set realdose to single to deal with fractional amounts
'17Nov99 CFY Implemented Preview function
'13Dec99 SF  merged TH's mods: 27Oct99, 03Nov99, 17Nov99
'13Dec99 SF  fix to stop incorrect dose being put into the instruction box if over four time slots setup in the direction
'10Nov01 CKJ Added > 0 to "syrup" comparison
'11Jan02 CKJ print one copy only using each context
'16Jul04 TH  Added new param to drive this procedure for interface export
'18Aug04 TH  Removed line - Merge Error
'18Oct04 TH  Use Filecopy not Name for output to allow for different drives to be specified
'12Jan07 PJC Added the patmed setting (PrintformV + DPSForm + issueunitonpmc="Y) to force the non-division by dosesperissueunit on the medication record card. i.e. 0.2 nebule to be used in the nebuliser   (#64962/69322/47878)
'18Jan07 TH Borders enhancement (DR-06-0235)
'08Mar07 PJC Because the label written to the temp file now contains the Directions marker, the l.text itself needs to be parsed before putting it on the print heap. (SC-06-0474 #84583)
'13Mar07 TH Added Additional checks on blnPRNPrint to ensure previous functionality retained.
'25Aug11 TH Added Printable elements for prescription reasons and patient readable prescription reasons. (TFS12153)
'28Sep11 TH Quick fix for NTHS. Replace hardcoded parsing string with setting. This way you can remove the first \par and stop the additional line on the grid. (TFS15773)
'29Dec14 XN If doseless then should not print out the dose value 89292
'06Dec16 TH Replaced RTF Handling (TFS 157969)
'04Jan17 TH Changes to use layout from DB (Hosted) (TFS 157969)
'03Feb17 TH DB RTF Handling now also allows local file include on #includx (TFS 174610)

Dim txt$, table$, tempTable$, fchan%, X%, pos%, Numoflines%
Dim breakfast$, lunch$, dinner$, night$, instructions$, MTimes$, temp$
Dim lines$()
Dim serveTimes$(), dummy$, Tmpfile$, Context$
Dim FILE$, FileNo%, Value%, pmcloop%, success%
Dim StartTable%, EndTable%, i%, SomethingToPrint%, Y%, manualQtyEntry%
Dim pmc$(), NumItems%, instructionsPos%, recno&, found&
Dim printDrugInstructions%, printDrugWarnings%, printFreeText%, printNumericDose%, additionalCRs$, sortOrder$, instructionsSep$
Dim realdose!, temp2$     '21Oct99 TH  '03Nov99 TH Changed realdose to single data type
Dim strFilename As String, lngPointer As Long, strFilePrefix As String, strPointerFilename As String '16Jul04 TH Added
Dim OutFile$ '16Jul04 TH Added
Dim strRTFFile As String
Dim strPRNTable As String                       '18Jan07 TH Added for Borders (DR-06-0235)
Dim blnPRNPrint As Integer                      '        "
Dim strFilePRN As String                        '        "
Dim PRNFileNo   As Integer                      '        "
Dim PRNrecno&                                   '        "
Dim blnPRN As Integer                           '        "
'Dim strText As String       '08Mar07 PJC Removed (SC-06-0474 #84583)                   '        "
Dim iSplitLine As Integer                       '        "
Dim intCount As Integer                         '        "
Dim trimmed As Integer                          '        "
Dim SomethingToPrintPRN As Integer              '        "
Dim strFileheader As String                     '        "
Dim strFileheaderPRN As String                  '        "
Dim strLine As String
Dim lngRequestID As Long
Dim strRxReason As String    '25Aug11 TH Added(TFS12153)
Dim strRXReasonPatient As String    '25Aug11 TH Added (TFS12153)
Dim strTblEndMarker As String      '28Sep11 TH Quick fix for NTHS (TFS15773)
Dim doselessDirection As WDirection '7Jan14 XN
Dim intSuccess As Integer

   'Initialise
   ReDim lines$(20)
   ReDim serveTimes$(4)
   SomethingToPrint = False
   recno& = 1

   strTblEndMarker = TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "\par}\pard\ql", "TblEndMarker", 0) '28Sep11 TH Quick fix for NTHS (TFS15773)
   
   'Check whether transfer file is present
   'If Not fileexists(driveAndPath$ & "\PMC.ASC") Then                                                                                 'xxAug99 CFY Removed as not needed
   '      popmessagecr "Error printing medication card", "Cannot load: " & driveAndPath$ & "\PMC.ASC" & cr & cr & "Exiting ....."      '                     "
   '      Exit Sub    ' <--- WAY OUT                                                                                                   '                     "
   '   End If                                                                                                                          '                     "
   'Read medication card rtf file (main body)
   'If Not fileexists(dispdata$ & "\PMC.RTF") Then                                                                                     'xxAug99 CFY Removed as not needed
   '      popmessagecr "Error printing medication card", "Cannot load: " & dispdata$ & "\PMC.RTF" & cr & cr & "Exiting ....."          '                     "
   '      Exit Sub    ' <--- WAY OUT                                                                                                   '                     "
   '   End If                                                                                                                          '                     "

   printFreeText = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "N", "PrintFreeTextLabels", 0))
   printNumericDose = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "N", "PrintAsNumericDose", 0))
   printDrugInstructions = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "N", "PrintDrugInstructions", 0))
   printDrugWarnings = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "N", "PrintDrugWarnings", 0))
   sortOrder$ = Trim$(UCase$(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "", "SortOrder", 0)))
   
   blnPRNPrint = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "N", "PRNPrint", 0))                            '18Jan07 TH Added for Borders (DR-06-0235)
   strFilePRN = Trim$(UCase$(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "PMCPRN.RTF", "FilePRN", 0)))                 '      "
   strFileheader = Trim$(UCase$(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "PMChd.RTF", "FileHeader", 0)))            '      "
   strFileheaderPRN = Trim$(UCase$(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "PMCPRNhd.RTF", "FilePRNHeader", 0)))   '      "
   If blnPRNPrint Then PRNrecno& = 1                                                                                         '      "
   If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "Y", "CRsAfterEachInstruction", 0)) Then
         instructionsSep$ = " \par "
      Else
         instructionsSep$ = " "
      End If

   ' additional CR's to add to each row
   additionalCRs$ = ""
   Y = Val(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "0", "AdditionalCRs", 0))
   For i = 1 To Y
      additionalCRs$ = additionalCRs$ & "\par "
   Next
   If additionalCRs$ <> "" Then additionalCRs$ = " " & additionalCRs$
   
   If blnInterface Then
      strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "MedicationCard", "PMCTBL.RTF", "RTFDetailFileName", 0)
   Else
      strRTFFile = "PMCTBL.RTF"
   End If
   

   'Read a blank 1x6 table, to use when printing dispensing medication
   GetRTFTextFromDB dispdata$ & "\" & strRTFFile, table$, intSuccess '04Jan17 TH Moved from below
   
   If Not intSuccess Then
         'popmessagecr "Error printing medication card", "Cannot load: " & dispdata$ & "\PMCTBL.RTF" & cr & cr & "Exiting ....."       'xxAug99 CFY Replaced
         'ErrMsg$ = "Cannot load : " & dispdata$ & "\" & strRTFFile 'PMCTBL.RTF"                                    '
         ErrMsg$ = "Cannot load rtf from Database : " & strRTFFile  'PMCTBL.RTF"                                    '
         Exit Sub    ' <--- WAY OUT
      Else
         'GetTextFile dispdata$ & "\" & strRTFFile, table$, 0
         'GetRTFTextFromDB dispdata$ & "\" & strRTFFile, table$, 0 '06Dec16 TH Replaced (TFS 157969)

          If (InStr(table$, "txVer")) Then
            strTblEndMarker = TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "\row\pard", "TblEndMarker", 0)
          End If
   
         If Not blnInterface Then  '16Jul04 TH Added
               'Pull out the rtf section which describes the table and its contents as that is all we need
               StartTable = InStr(table$, "\trowd\")
               'StartTable = InStr(table$, "\par}\pard\ql")  '18Aug04 Removed line - Merge Error
               'EndTable = InStr(table$, "\par}\pard\ql")
               EndTable = InStr(table$, strTblEndMarker) + Len(strTblEndMarker)
               If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "N", "RemovePMCTablePard", 0)) Then EndTable = InStr(table$, strTblEndMarker) '+ Len("\par}\pard\ql")
               If StartTable > 0 And EndTable > 0 Then
                     table$ = Mid$(table$, StartTable, EndTable - StartTable)
                  Else
                      'popmessagecr "Error printing medication card", "Problem with PMCTBL.RTF" & cr & "Cannot find the start and end positions" & cr & cr & "Exiting ....."  'xxAug99 CFY Replaced
                      ErrMsg$ = "Problem with " & strRTFFile & cr & "Cannot find the start and end positions"                                                                    '         "
                      Exit Sub
                  End If
               '18Jan07 TH Added block below for Borders (DR-06-0235)  -------------------------------------------------------------------------------------
                'New PRN Section if required
               If blnPRNPrint Then
                     GetRTFTextFromDB dispdata$ & "\" & strFilePRN, strPRNTable, intSuccess '04Jan17 TH Moved above for check
                     'If Not fileexists(dispdata$ & "\" & strFilePRN) Then
                     If Not intSuccess Then
                           'ErrMsg$ = "Cannot load: " & dispdata$ & "\" & strFilePRN 'PMCTBL.RTF"                                    '
                           ErrMsg$ = "Cannot load RTF : " & strFilePRN 'PMCTBL.RTF"                                    '
                           Exit Sub    ' <--- WAY OUT
                        Else
                   
                           'GetTextFile dispdata$ & "\" & strFilePRN, strPRNTable, 0
                           'GetRTFTextFromDB dispdata$ & "\" & strFilePRN, strPRNTable, 0 '06Dec16 TH Replaced (TFS 157969)

                           'Pull out the rtf section which describes the table and its contents as that is all we need
                           StartTable = InStr(strPRNTable, "\trowd\")
                           EndTable = InStr(strPRNTable, strTblEndMarker) + Len(strTblEndMarker)
                           If StartTable > 0 And EndTable > 0 Then
                                 strPRNTable = Mid$(strPRNTable, StartTable, EndTable - StartTable)
                              Else
                                  ErrMsg$ = "Problem with " & strRTFFile & cr & "Cannot find the start and end positions"                                                                    '         "
                                  Exit Sub
                              End If
                        End If
      
                     'Now we need to get the header files
                     GetRTFTextFromDB dispdata$ & "\" & strFileheader, strFileheader, intSuccess '04Jan17 TH Moved from below
                     
                     'If Not fileexists(dispdata$ & "\" & strFileheader) Then
                     If Not intSuccess Then
                           'ErrMsg$ = "Cannot load: " & dispdata$ & "\" & strFileheader 'PMCPRNHD.RTF"                                    '
                           ErrMsg$ = "Cannot load rtf from DB : " & strFileheader  'PMCPRNHD.RTF"                                    '
                           Exit Sub    ' <--- WAY OUT
                        Else
                        
                           'GetTextFile dispdata$ & "\" & strFileheader, strFileheader, 0
                           'GetRTFTextFromDB dispdata$ & "\" & strFileheader, strFileheader, 0 '06Dec16 TH Replaced (TFS 157969)

                           'Pull out the rtf section which describes the table and its contents as that is all we need
                           StartTable = InStr(strFileheader, "\trowd\")
                           EndTable = InStr(strFileheader, strTblEndMarker) '+ Len("\par}\pard\ql")
                           If StartTable > 0 And EndTable > 0 Then
                                 strFileheader = Mid$(strFileheader, StartTable, EndTable - StartTable) & "}"
                              Else
                                 ErrMsg$ = "Problem with " & strFileheader & cr & "Cannot find the start and end positions"                                                                    '         "
                                 Exit Sub
                              End If
                        End If
                     
                     GetRTFTextFromDB dispdata$ & "\" & strFileheaderPRN, strFileheaderPRN, intSuccess '04Jan17 TH Moved from below
                     'If Not fileexists(dispdata$ & "\" & strFileheaderPRN) Then
                     If Not intSuccess Then
                           'ErrMsg$ = "Cannot load: " & dispdata$ & "\" & strFileheaderPRN 'PMCHD.RTF"                                    '
                           ErrMsg$ = "Cannot load rtf from DB : " & strFileheaderPRN  'PMCHD.RTF"                                    '
                           Exit Sub    ' <--- WAY OUT
                        Else
                      
                           'GetTextFile dispdata$ & "\" & strFileheaderPRN, strFileheaderPRN, 0
                           'GetRTFTextFromDB dispdata$ & "\" & strFileheaderPRN, strFileheaderPRN, 0 '06Dec16 TH Replaced (TFS 157969)

                           'Pull out the rtf section which describes the table and its contents as that is all we need
                           StartTable = InStr(strFileheaderPRN, "\trowd\")
                           EndTable = InStr(strFileheaderPRN, strTblEndMarker) '+ Len(strTblEndMarker)
                           If StartTable > 0 And EndTable > 0 Then
                                 strFileheaderPRN = Mid$(strFileheaderPRN, StartTable, EndTable - StartTable) & "}"
                              Else
                                  ErrMsg$ = "Problem with " & strFileheaderPRN & cr & "Cannot find the start and end positions"                                                                    '         "
                                  Exit Sub
                              End If
                        End If
         
                  End If
         
            '18Jan07 TH End of block above for Borders (DR-06-0235)  -------------------------------------------------------------------------------------
            End If
      End If                 '16Jul04 TH Added

   ' get times for breakfast, lunch, dinner, night
   MTimes$ = ReadPrivateIniFile(dispdata$ & "\PATMED.INI", "MedicationCard", "Times")

   deflines MTimes$, serveTimes$(), ",", 1, Numoflines
   If Numoflines < 4 Then
         'if less than four times specified in the ini exit, if more just use the first four
         'popmessagecr "Medication Card Error", "Incorrect number for Times= setting in" & cr & "Patmed.ini, should be FOUR. Exiting ....."     'xxAug99 CFY Replaced
         ErrMsg$ = "Incorrect number for Times= setting in" & cr & "Patmed.ini, should be FOUR."                                                '         "
         Exit Sub    ' <--- WAY OUT
      End If

   'Open temporary file for building the PMC rtf up on disk
   MakeLocalFile FILE$
   MakeLocalFile strFilePRN                '18Jan07 TH Added for Borders (DR-06-0235)

   'setup serving times
   For X = 1 To 4
      Select Case Val(Trim$(serveTimes(X)))
         Case 0 To 23      ' assume hour
            serveTimes$(X) = Format$(serveTimes(X), "00") & "00"
         Case 24 To 59     ' assume minutes
            serveTimes$(X) = "00" & Format$(serveTimes(X), "00")
         Case Else
            serveTimes$(X) = Format$(serveTimes(X), "0000")
      End Select
   Next

   'Set up serveTimes$() with start/stop times for breakfast, lunch, dinner, eg:
   '08001159  12001759  16002359  0000
   For X = 1 To 3
      If Mid$(serveTimes$(X + 1), 3, 2) = "00" Then   ' mins 00 to 59
            serveTimes$(X) = serveTimes$(X) & Format$(Val(Left$(serveTimes$(X + 1), 2)) - 1, "00") & "59"
         Else
            serveTimes$(X) = serveTimes$(X) & Left$(serveTimes$(X + 1), 2) & Format$(Val(Mid$(serveTimes$(X + 1), 3, 2)) - 1, "00")
         End If
      If Mid$(serveTimes$(X), 5, 3) = "-01" Then      ' hour 00 to 23
            serveTimes$(X) = Left$(serveTimes$(X), 4) & "23" & Mid$(serveTimes$(X), 8, 2)
         End If
   Next

   'Open the Spool file on disk which contains the patients which need PMC printing
   'AcquireLock driveAndPath$ & "\PMC.LCK", -1, done        'xxAug99 CFY Removed as not needed
   fchan = FreeFile
   'Open driveAndPath$ & "\PMC.ASC" For Binary As fchan     'xxAug99 CFY Replaced
   Open cTmpFile$ For Binary As fchan                       '         "
   Get #fchan, , pid
   dummy$ = Space$(2)      'skip over the extra two chars
   Get #fchan, , dummy$
   
   'Insert patient name and date card issued (into the header of PMC.RTF)
   Heap 10, gPRNheapID, "patientname", Trim$(pid.forename) & " " & Trim$(pid.surname), 0
   Heap 10, gPRNheapID, "issuedate", Format(date, "dd mmmm yyyy"), 0
   
   'Find point in the PMC header rtf at which the table entries will be inserted
   'and write up to that point into the temporary file
   ''StartTable = InStr(txt$, "[DispensedMedication]")           '18Jan07 TH Removed for Borders (DR-06-0235)
   ''If StartTable <> 0 Then                                     '      "
   ''      Temp$ = Left$(txt$, StartTable - 1)                   '      "
   ''      Put #FileNo, , Temp$                                  '      "
   ''   End If                                                   '      "

   ' put the contents of the medication card data into an array in case it needs sorting
   NumItems = 0
   ReDim pmc$(50)
   Do While Not EOF(fchan)
      'Get #fchan, , strLine
      'dummy$ = Space$(2)
      dummy$ = Space$(10)
      Get #fchan, , dummy$
      lngRequestID = Val(dummy$)
      dummy$ = Space$(2)
      Get #fchan, , dummy$    ' skip over the extra two chars

      'Get #fchan, , strLine    ' skip over the extra two chars
      'v9 Use dummy to get the label
      If lngRequestID > 0 Then
      GetLabelNL lngRequestID, L
      If Trim$(L.SisCode) = "" And Trim$(L.text) = "" Then Exit Do
      LSet r = L
      Value = 0
      For i = 1 To 6
         ' create a value to sort on depending on the number of time slots that have doses in
         If sortOrder$ = "D" Or sortOrder$ = "-" Then
               ' add to array to sort in descending order
               If L.dose(i) = 0 Then Value = Value + (i ^ 2)
            Else
               ' add to array to sort in ascending order
               If L.dose(i) > 0 Then Value = Value + (i ^ 2)
            End If
      Next
      NumItems = NumItems + 1
      If NumItems > 50 Then ReDim Preserve pmc$(NumItems)
      pmc$(NumItems) = Chr$(Value) & Chr$(160) & r.record
      End If
   Loop
   Close fchan

   ' check whether the program needs to sort the array
   If NumItems > 1 And (sortOrder$ = "A" Or sortOrder$ = "+" Or sortOrder$ = "D" Or sortOrder$ = "-") Then
         shellsort pmc$(), NumItems, 1, Chr$(160)
      End If
   
   'Go through each drug (wlabel) putting information in right places
   For pmcloop = 1 To NumItems
      r.record = Right$(pmc$(pmcloop), Len(pmc$(pmcloop)) - 2)
      LSet L = r
      If PatternMatch(L.SisCode, "AAA999A") Or (printFreeText = True And Trim$(L.SisCode) = "") Then
            
            'If Val(l.prn) Then                                                                                   '18Jan07 TH Added for Borders (DR-06-0235)
            'If Asc(l.flags) And &H2 Then                                                                         '13Mar07 TH replaced by below
            'If (Asc(L.Flags) And &H2) And blnPRNPrint Then                                                        '13Mar07 TH Added check on blnPRNPrint to ensure previous functionality retained      "
            'If (Asc(L.Prn) And &H2) And blnPRNPrint Then                                                        '13Mar07 TH Added check on blnPRNPrint to ensure previous functionality retained      "
            If L.Prn And blnPRNPrint Then          '10Jul11 TH Added (F0122324) Now this is bit flag - we dont need the byte dissembled !
                  blnPRN = True '18Jun06 TH Added                                                                 '        "
                  PRNFileNo = FreeFile                                                                            '        "
                  Open strFilePRN For Binary Access Write Lock Read Write As #PRNFileNo         ' for spooling ...'        "
               Else                                                                                               '        "
                  FileNo = FreeFile
                  Open FILE$ For Binary Access Write Lock Read Write As #FileNo         ' for spooling ...
                  blnPRN = False '18Jun06 TH Added                                                                '18Jan07 TH Added for Borders (DR-06-0235)
               End If                                                                                             '        "
            
            'Blank out previous record's information
            'cleardrug d
            BlankWProduct d
            breakfast$ = ""
            lunch$ = ""
            dinner$ = ""
            night$ = ""
            instructions$ = ""
            instructionsPos = 0
            '25Aug11 TH Added (TFS12153)
            Heap 10, gPRNheapID, "RxReason", "", 0
            Heap 10, gPRNheapID, "RXReasonPatient", "", 0
            strRxReason = ""
            strRXReasonPatient = ""
            '-----
            
            If Trim$(L.SisCode) = "" Then
                  ' free text in either the description or the instructions field
                  temp$ = L.text
                  deflines temp$, lines$(), Chr$(30), 1, Numoflines%
                  temp$ = ""
                  For X% = 1 To Numoflines%
                     If Trim$(lines$(X%)) <> "" Then
                           If X > 1 And X < Numoflines% Then temp$ = temp$ & instructionsSep$
                           temp$ = temp$ & Trim$(lines$(X%))
                        End If
                  Next

                  If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "Y", "FreeTextInInstructions", 0)) Then
                        instructions$ = temp$
                        temp$ = ""
                     End If
               Else
                  d.SisCode = L.SisCode
                  getdrug d, 0, 0, False

                  ' create an array of the entered directions
                  temp$ = L.drdirection
                  ReDim lines$(20)
                  replace temp$, crlf, ",", 0
                  replace temp$, Chr$(30), ",", 0
                  deflines temp$, lines$(), ",", 1, Numoflines
                  
                  
                  ' check if enter manual qty set
                  'If Asc(L.Flags) And &H1 Then
                  If L.ManualQuantity Then
                     manualQtyEntry = True
                  Else
                     manualQtyEntry = False
                  End If
                  
                  ' If doseless then should not print out the dose value, but instead print out the start of the direction text
                  ' 29Dec14 XN 89292
                  Dim bDoeslessPrescription As Boolean
                  bDoeslessPrescription = (UCase(GetRequestTypeByChildRequestID(L.RequestID)) = UCase("Doseless Prescription"))
                  
                  If bDoeslessPrescription Then
                    Dim firstDirEndPos As Integer
                    firstDirEndPos = InStr(L.dircode, "/")
                    If firstDirEndPos = -1 Then
                        getdir L.dircode, "", found&, doselessDirection
                    Else
                        getdir Left$(L.dircode, firstDirEndPos - 1), "", found&, doselessDirection
                    End If
                  End If
                  
                  'Put the directions in the times variables, any extra put in instructions$
                  For X = 1 To 6
                     If Trim$(L.Times(X)) = "" Then Exit For
                        ' get direction for current dose
                        'wdir.code = Format$(l.dose(x))
                        temp2$ = Trim$(UCase$(d.LabelDescription))                 '21Oct99 TH Gives better reflection of actual dose for label
                        'If InStr(temp2$, "SUSPENSION") > 0 Or InStr(temp$, "LIQUID") > 0 Or InStr(temp$, "SOLUTION") > 0 Or InStr(temp$, "MIXTURE") > 0 Or InStr(temp$, "LINCTUS") > 0 Or InStr(temp$, "SYRUP") Or InStr(temp$, "ELIXIR") > 0 Then       '21Oct99 TH
                        'If InStr(temp2$, "SUSPENSION") > 0 Or InStr(temp2$, "LIQUID") > 0 Or InStr(temp2$, "SOLUTION") > 0 Or InStr(temp2$, "MIXTURE") > 0 Or InStr(temp2$, "LINCTUS") > 0 Or InStr(temp2$, "SYRUP") Or InStr(temp2$, "ELIXIR") > 0 Then  '27Oct99 TH Use temp2$ on all checks (oops)
                        'If InStr(temp2$, "SUSPENSION") > 0 Or InStr(temp2$, "LIQUID") > 0 Or InStr(temp2$, "SOLUTION") > 0 Or InStr(temp2$, "MIXTURE") > 0 Or InStr(temp2$, "LINCTUS") > 0 Or InStr(temp2$, "SYRUP") > 0 Or InStr(temp2$, "ELIXIR") > 0 Then '27Oct99 TH Use temp2$ on all checks (oops) '10Nov01 CKJ Added > 0 to "syrup"             '12Jan07 PJC replaced by below (#'23Nov06 PJC replaced by below (#64962/69322/47878))
                        If (InStr(temp2$, "SUSPENSION") > 0 Or InStr(temp2$, "LIQUID") > 0 Or InStr(temp2$, "SOLUTION") > 0 Or InStr(temp2$, "MIXTURE") > 0 Or InStr(temp2$, "LINCTUS") > 0 Or InStr(temp2$, "SYRUP") > 0 Or InStr(temp2$, "ELIXIR") > 0) And (TrueFalse(TxtD$(dispdata$ + "\PATMED.INI", "", "N", UCase$(Trim$(d.PrintformV)) & Trim$(d.DPSform) & "issueunitonpmc", 0)) = False) Then  '12Jan07 PJC Added the patmed setting to force the non-division by dosesperissueunit.   (#64962/69322/47878) '27Oct99 TH Use temp2$ on all checks (oops) '10Nov01 CKJ Added > 0 to "syrup"
                              realdose = L.dose(X) / d.dosesperissueunit    '   "
                              WDir.Code = Format$(realdose)                 '   "
                           Else                                              '   "
                              WDir.Code = Format$(L.dose(X))
                              realdose = L.dose(X)                          '   "
                           End If                                            '   "
                        getdir (WDir.Code), "", found&, WDir
                        
                        ' put in the correct position on the medication card
                        Select Case Val(L.Times(X))
                           Case Val(Left$(serveTimes$(1), 4)) To Val(Mid$(serveTimes$(1), 5, 4))  ' breakfast times
                              If Trim$(breakfast$) <> "" Then
                                    '13Dec99 SF moved into IF statement
                                    instructions$ = instructions$ & "Also " & Trim$(WDir.directs) & " at " & Left(L.Times(X), 2) & ":" & Mid$(L.Times(X), 3, 2) & "." & instructionsSep$
                                 Else     '13Dec99 SF added
                                    If manualQtyEntry Then
                                          breakfast$ = "As directed "
                                       ElseIf bDoeslessPrescription Then
                                         breakfast$ = Trim$(doselessDirection.directs)   ' 29Dec14 XN 89292 Doesless so print start of direction text
                                       ElseIf printNumericDose Then
                                          'breakfast$ = Format$(l.dose(x))   '21Oct99 TH  Replaced
                                          breakfast$ = Format$(realdose)   '   "
                                       Else
                                          breakfast$ = Trim$(WDir.directs)
                                          End If
                                 End If   '13Dec99 SF added
                           Case Val(Left$(serveTimes$(2), 4)) To Val(Mid$(serveTimes$(2), 5, 4))  ' lunch times
                              If Trim$(lunch$) <> "" Then
                                    '13Dec99 SF moved into IF statement
                                    instructions$ = instructions$ & "Also " & Trim$(WDir.directs) & " at " & Left(L.Times(X), 2) & ":" & Mid$(L.Times(X), 3, 2) & "." & instructionsSep$
                                 Else     '13Dec99 SF added
                                    If manualQtyEntry Then
                                          lunch$ = "As directed "
                                       ElseIf bDoeslessPrescription Then
                                          lunch$ = Trim$(doselessDirection.directs)  ' 29Dec14 XN 89292 Doesless so print start of direction text
                                       ElseIf printNumericDose Then
                                          'lunch$ = Format$(l.dose(x))      '21Oct99 TH  Replaced
                                          lunch$ = Format$(realdose)       '   "
                                       Else
                                          lunch$ = Trim$(WDir.directs)
                                       End If
                                 End If   '13Dec99 SF added
                           Case Val(Left$(serveTimes$(3), 4)) To Val(Mid$(serveTimes$(3), 5, 4))   ' dinner times
                              If Trim$(dinner$) <> "" Then
                                    '13Dec99 SF moved into IF statement
                                    instructions$ = instructions$ & "Also " & Trim$(WDir.directs) & " at " & Left(L.Times(X), 2) & ":" & Mid$(L.Times(X), 3, 2) & "." & instructionsSep$
                                 Else     '13Dec99 SF added
                                    If manualQtyEntry Then
                                          dinner$ = "As directed "
                                       ElseIf bDoeslessPrescription Then
                                          dinner$ = Trim$(doselessDirection.directs) ' 29Dec14 XN 89292 Doesless so print start of direction text
                                       ElseIf printNumericDose Then
                                          'dinner$ = Format$(l.dose(x))     '21Oct99 TH  Replaced
                                          dinner$ = Format$(realdose)      '   "
                                       Else
                                          dinner$ = Trim$(WDir.directs)
                                       End If
                                 End If      '13Dec99 SF added
                           Case Else                                                               ' night times
                              If Trim$(night$) <> "" Then
                                    '13Dec99 SF moved into IF statement
                                    instructions$ = instructions$ & "Also " & Trim$(WDir.directs) & " at " & Left(L.Times(X), 2) & ":" & Mid$(L.Times(X), 3, 2) & "." & instructionsSep$
                                 Else     '13Dec99 SF added
                                    If manualQtyEntry Then
                                          night$ = "As directed "
                                       ElseIf bDoeslessPrescription Then
                                          night$ = Trim$(doselessDirection.directs)  ' 29Dec14 XN 89292 Doesless so print start of direction text
                                       ElseIf printNumericDose Then
                                          'night$ = Format$(l.dose(x))     '21Oct99 TH  Replaced
                                          night$ = Format$(realdose)      '   "
                                       Else
                                          night$ = Trim$(WDir.directs)
                                       End If
                                 End If      '13Dec99 SF added
                        End Select

                     'v9 We no longer have a repeat interval, so we will need to work out what we do here !!!
                     ' if repeat interval not every day then put the direction in the instructions box
'''                     If L.RepeatInterval > 1 Or (L.RepeatInterval = 1 And Trim$(LCase$(L.RepeatUnits)) = "wk") Then
'''                           If (X + 1) <= Numoflines Then instructions$ = instructions$ & lines$(X + 1) & instructionsSep$
'''                        End If

                     ' skip the directions already put on the medication card above so no duplication
                     For Y = 1 To Numoflines
                         If InStr(UCase$(Trim$(lines(Y))), UCase$(Trim$(WDir.directs))) > 0 Then
                                 If Y > instructionsPos Then instructionsPos = Y + 1
                             End If
                     Next
                  Next
            

                  ' add additional instructions
                  If instructionsPos > 0 Then instructionsPos = instructionsPos + 1
                  If instructionsPos <= Numoflines Then
                          For X = instructionsPos To Numoflines
                             If manualQtyEntry Then
                                   If InStr(LCase(lines(X)), "as directed") = 0 Then
                                         If Trim$(lines(X)) <> "" Then instructions$ = instructions$ & lines(X) & instructionsSep$
                                      End If
                                 Else
                                    If Trim$(lines(X)) <> "" Then instructions$ = instructions$ & lines(X) & instructionsSep$
                                 End If
                          Next
                    End If

                  ' prints the drug warnings if setup to do so in the ini file
                  If printDrugWarnings Then
                        temp$ = ""
                        GetWarCode Trim$(d.warcode), temp$
                        If temp$ <> "" Then
                              deflines temp$, lines$(), Chr$(30), 1, Numoflines%
                              temp$ = ""
                              For X% = 1 To Numoflines%
                                 Y% = InStr(lines(X%), "!")
                                 If Y% > 0 Then lines$(X%) = Mid$(lines$(X%), (Y% + 1), Len(lines$(X%)))
                                 temp$ = temp$ & lines$(X%)
                                 If X < Numoflines% Then temp$ = temp$ & instructionsSep$
                              Next
                              If Numoflines% > 0 Then instructions$ = instructions$ & temp$ & instructionsSep$
                        End If
                     End If
                  
                  ' prints the drug instructions if setup to do so in the ini file
                  If printDrugInstructions Then
                        temp$ = ""
                        GetInsCode Trim$(d.inscode), temp$
                        If temp$ <> "" Then
                              deflines temp$, lines$(), Chr$(30), 1, Numoflines%
                              temp$ = ""
                              For X% = 1 To Numoflines%
                                 Y% = InStr(lines(X%), "!")
                                 If Y% > 0 Then lines$(X%) = Mid$(lines$(X%), (Y% + 1), Len(lines$(X%)))
                                 temp$ = temp$ & lines$(X%)
                                 If X < Numoflines% Then temp$ = temp$ & instructionsSep$
                              Next
                              If Numoflines% > 0 Then instructions$ = instructions$ & temp$ & instructionsSep$
                           End If
                     End If
                  
                  'Remove last blank line if there is one
                  instructions$ = Trim$(instructions$)
                  breakfast$ = Trim$(breakfast$)
                  lunch$ = Trim$(lunch$)
                  dinner$ = Trim$(dinner$)
                  night$ = Trim$(night$)
                  If Right$(instructions$, 5) = " \par" Then instructions$ = Left$(instructions$, Len(instructions$) - 5)
                  If Right$(breakfast$, 5) = " \par" Then breakfast$ = Left$(breakfast$, Len(breakfast$) - 5)
                  If Right$(lunch$, 5) = " \par" Then lunch$ = Left$(lunch$, Len(lunch$) - 5)
                  If Right$(dinner$, 5) = " \par" Then dinner$ = Left$(dinner$, Len(dinner$) - 5)
                  If Right$(night$, 5) = " \par" Then night$ = Left$(night$, Len(night$) - 5)

                  ' used to put into the [medication] element
                  temp$ = Trim$(d.LabelDescription)
                  plingparse temp$, "!"
               End If
                  
             'If blnPRN Then                       '13Mar07 replaced by below '18Jan07 TH Added for Borders (DR-06-0235)
             If blnPRN And blnPRNPrint Then        '13Mar07 TH Added check on blnPRNPrint to ensure previous functionality retained.
                  tempTable$ = strPRNTable         '        "
               Else                                '        "
                  tempTable$ = table$        ' work on a copy
               End If                              '18Jan07 TH Added for Borders (DR-06-0235)
      
            'Insert data into table and add it to the main text body
            replace tempTable$, "[medication]", temp$ & additionalCRs$, 0
            replace tempTable$, "[breakfast]", breakfast$ & additionalCRs$, 0
            replace tempTable$, "[lunch]", lunch$ & additionalCRs$, 0
            replace tempTable$, "[dinner]", dinner$ & additionalCRs$, 0
            replace tempTable$, "[night]", night$ & additionalCRs$, 0
            replace tempTable$, "[instructions]", instructions$ & additionalCRs$, 0
            
            FillHeapDrugInfo gPRNheapID, d, 0

            Erase labelline$                                                                                         '18Jan07 TH Added for Borders (DR-06-0235)
            'strText = l.Text                                              '08Mar07 PJC Removed (SC-06-0474 #84583)  '            "
            'ParseEndDirMarker strText, Chr$(&H1F), Chr$(30), iSplitLine   '08Mar07 PJC Replaced by line below (SC-06-0474 #84583)     '            "
            ParseEndDirMarker L.text, Chr$(&H1F), Chr$(30), iSplitLine     '08Mar07 PJC Now passes in the text on the label (SC-06-0474 #84583)
            SetDescriptionSplitLine iSplitLine                                                                       '            "
                                                                                                                     '            "
            'deflines strText, labelline$(), Chr$(30), 1, numoflines   '08Mar07 PJC Replaced by below.  (SC-06-0474 #84583)             '            "
            deflines L.text, labelline$(), Chr$(30), 1, Numoflines     '08Mar07 PJC Now uses the l.Text      (SC-06-0474 #84583)             '            "
            
            For intCount = 1 To Numoflines ' + 1                                                                     '            "
               Do                                                                                                    '            "
                  trimmed = False                                                                                    '            "
                  If Len(labelline$(intCount)) >= 2 Then   'ASC 26Sep93                                              '            "
                        If Left$(labelline$(intCount), 2) = "^^" Then                                                '            "
                              labelline$(intCount) = Right$(labelline$(intCount), Len(labelline$(intCount)) - 1)     '            "
                              trimmed = True                                                                         '            "
                           End If                                                                                    '            "
                     End If                                                                                          '            "
               Loop Until Not trimmed                                                                                '            "
            Next                                                                                                     '            "
            iSplitLine = DescriptionSplitLine()                                                                      '            "
            FillHeapLabelText gPRNheapID, labelline$(), iSplitLine, 5                                                '            "
            FillHeapLabelInfo gPRNheapID, L, 0
            '25Aug11 TH
            GetPrescriptionReasons L.RequestID, strRxReason, strRXReasonPatient
            Heap 10, gPRNheapID, "RxReason", Trim$(strRxReason), 0
            Heap 10, gPRNheapID, "RXReasonPatient", Trim$(strRXReasonPatient), 0
            
            ParseItems gPRNheapID, tempTable$, 0   '16Jul04 TH Added
            If blnPRNPrint And blnPRN Then                                                                            '18Jan07 TH Added for Borders (DR-06-0235)
                  'Write table entry to temp file                                                                     '            "
                  Put PRNFileNo, PRNrecno&, tempTable$                  ' write current row to the file to be printed '            "
                  PRNrecno& = PRNrecno& + Len(tempTable$)               ' next position to write in the file          '            "
                  Close #PRNFileNo                                                                                    '            "
                  Tmpfile$ = strFilePRN                                                                               '            "
                  parseRTF Tmpfile$, strFilePRN                        ' parse working chunk with heap data           '            "
                  If fileexists(Tmpfile$) Then Kill Tmpfile$      ' delete local file                                 '            "
                  SomethingToPrintPRN = True                                                                          '            "
               Else                                                                                                   '            "

                  'Write table entry to temp file
                  Put FileNo, recno&, tempTable$                  ' write current row to the file to be printed
                  recno& = recno& + Len(tempTable$)               ' next position to write in the file
                  Close #FileNo
                  Tmpfile$ = FILE$
                  parseRTF Tmpfile$, FILE$                        ' parse working chunk with heap data '04Jan17 TH THis should stilluse local file
                  If fileexists(Tmpfile$) Then Kill Tmpfile$      ' delete local file
                  SomethingToPrint = True
               End If                                                                                                 '18Jan07 TH Added for Borders (DR-06-0235)
         End If
   Next
   
   'If fileexists(driveAndPath$ & "\PMC.ASC") Then Kill driveAndPath$ & "\PMC.ASC"     'xxAug99 CFY Removed
   'AcquireLock driveAndPath$ & "\PMC.LCK", 0, done          ' release lock on file    '         "
   
   Tmpfile$ = FILE$
   'If SomethingToPrint Then                                   '18Jan07 TH removed for Borders (DR-06-0235)
   If SomethingToPrint Or SomethingToPrintPRN Then             '18Jan07 TH Added for Borders (DR-06-0235)

         'Heap 10, gPRNheapID, "DispensedMedication", "[#include" & TB & FILE$ & "]", 0
         Heap 10, gPRNheapID, "DispensedMedication", "[#includx" & TB & FILE$ & "]", 0  '03Feb17 TH DB RTF Handling now also allows local file include (TFS 174610)
         
                                                                                                                '18Jan07 TH Added for Borders (DR-06-0235)
         If blnPRNPrint Then                                                                                    '          "
               Heap 10, gPRNheapID, "DispensedMedicationPRN", "[#include" & TB & strFilePRN & "]", 0            '          "
            End If                                                                                              '          "
         If blnPRNPrint Then                                                                                    '          "
               If SomethingToPrint Then                                                                         '          "
                     Heap 10, gPRNheapID, "DispensedMedicationHeader", strFileheader, 0                         '          "
                  Else                                                                                          '          "
                     Heap 10, gPRNheapID, "DispensedMedicationHeader", "", 0                                    '          "
                  End If                                                                                        '          "
               If SomethingToPrintPRN Then                                                                      '          "
                     Heap 10, gPRNheapID, "DispensedMedicationHeaderPRN", strFileheaderPRN, 0                   '          "
                  Else                                                                                          '          "
                     Heap 10, gPRNheapID, "DispensedMedicationHeaderPRN", "", 0                                 '          "
                  End If                                                                                        '          "
            End If                                                                                              '          "
         If InStr(UCase$(Command$), "/HEAPDEBUG") Then Heap 100, gPRNheapID, "", "", 0
         'ParseRTF dispdata$ & "\PMC.RTF", File$                     'xxAug99 CFY Replaced with
         'Hedit 11, File$                                            '            parsethenprint
         '16Jul04 TH If we are using the interface then lets silently put out the file
         If blnInterface Then       '16Jul04 TH If we are using the interface then lets silently put out the file
            'The interface requires the file to be sent to configured location
            'First create a file name
            strFilename = TxtD(dispdata$ & "\GenInt.INI", "MedicationCard", "", "ExportFilePath", 0)
            If strFilename <> "" Then
               If DirExists(strFilename) Then
                  'Now get a pointer to ensure unique file
                  strPointerFilename = TxtD(dispdata$ & "\GenInt.INI", "MedicationCard", dispdata$ & "\PMCInt.dat", "InterfacePointerFile", 0)
                  GetPointerSQL strPointerFilename, lngPointer, True
                  strFilePrefix = Trim$(Left$(TxtD(dispdata$ & "\GenInt.INI", "MedicationCard", "D", "FilePrefix", 0) & Space$(3), 3))
                  strFilename = strFilename & "\" & strFilePrefix & Left$("00000000", 8 - (Len(strFilePrefix) + Len(Format$(lngPointer)))) & Format$(lngPointer)
                  'Parse the file
                  'parseRTF Layout$, FILE$
                  parseRTFfromDB Layout$, FILE$ '04Jan17 TH Added to use layout from DB (Hosted)
                  'EscapeRTF file$, OutFile$
                  'Put the file to the output location
                  'Name File$ As strFilename & ".xml"      '18Oct04 TH Replaced with below to allow for different drives to be specified
                  FileCopy FILE$, strFilename & ".xml"     '    "
                  If fileexists(FILE$) Then Kill FILE$
                  
               Else
                  popmessagecr "", "Generic Interface Incorrectly configured - Export File Path Not Found"
               End If
            Else
               popmessagecr "", "Generic Interface Incorrectly configured - Export File Path required"
            End If
         Else
         '16Jul04 TH ------------------
         If preview Then                                             '17Nov99 CFY Added
               'parseRTF Layout$, FILE$                               '17Nov99 CFY Added
               parseRTFfromDB Layout$, FILE$  '04Jan17 TH Added to use layout from DB (Hosted)
               Hedit 11, FILE$                                       '17Nov99 CFY Added
            End If                                                   '17Nov99 CFY Added
         
         For i = 1 To copies                                         '          "
            Context$ = cPMCContext                                   '          "
            If copies > 1 Then Context$ = Context$ & Format$(i)      '          "
            If preview Then                                          '17Nov99 CFY Added
                  'ParseThenPrint context$, File$, copies%, success% '          "        11Jan02 CKJ print one copy only using this context
                  'ParseThenPrint Context$, FILE$, 1, success%        '          "           "
                  'ParseThenPrint Context$, FILE$, 1, success%, False  '27May11 TH Added param (F0088129)
                  ParseThenPrint Context$, FILE$, 1, success%, False, True '04Jan17 TH Added to use local files (Hosted)
               Else                                                  '          "
                  'ParseThenPrint context$, layout$, copies%, success%'         "           "
                  'ParseThenPrint Context$, Layout$, 1, success%      '          "           "
                  'ParseThenPrint Context$, Layout$, 1, success%, False        '27May11 TH Added param (F0088129)
                  ParseThenPrint Context$, Layout$, 1, success%, False, False       '04Jan17 TH Added to use DB Parsing (Hosted)
               End If                                                '          "
         Next
         End If   '16Jul04 TH
      End If
   
   If fileexists(Tmpfile$) Then Kill Tmpfile$
   If fileexists(FILE$) Then Kill FILE$

   If blnPRNPrint Then                                         '18Jan07 TH Added for Borders (DR-06-0235)
         If fileexists(strFilePRN) Then Kill strFilePRN        '        "
      End If                                                   '        "
End Sub

Sub PatientPrintFormInit()
'xxAug99 CFY Written
'27Oct99 CFY Code added to handle OnlyIssues checkbox
'07Dec99 AW Code added to allow default values to be read from ini file
'
Dim txt$
Dim ErrorFlag%, i%, j%, Numoflines%, Present%

   'Check Patient Printing has been setup 8.11 style....
   NumDocs = Val(TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "", "NumDocs", Present))
''   If Not Present Then
''         popmessagecr "#", "An upgrade has been detected and your system" & crlf & "will be configured for Patient Printing." & crlf & crlf & "This may take a few minutes."
''         Config811
''      End If
   
   PatientTypes$ = TxtD(dispdata$ & "\patmed.ini", "", "", "PossiblePatientTypes", 0)
   ReDim DocsInfo(NumDocs)

   If Trim$(PatientTypes$) = "" Then
         popmessagecr "", "No patient types have been defined in PATMED.INI" & cr & "See your system manager for help."
         ErrorFlag = True
      End If

   'Setup Form for display....
   
   'Read and store document info from .ini file
   If Not ErrorFlag Then
         For i = 1 To NumDocs
            
            '27Jul04 TH Moved control loading to below to allow for suppression of some ctrls with interface option
            'If i > 1 Then
            '      Load FrmPatPrint.ChkDoc(i)
            '      Load FrmPatPrint.TxtCopies(i)
            '      Load FrmPatPrint.ChkIssuesOnly(i)                                                '27Oct99 CFY Added
            '      FrmPatPrint.ChkDoc(i).Top = FrmPatPrint.ChkDoc(i - 1).Top + 300
            '      FrmPatPrint.ChkDoc(i).Left = FrmPatPrint.ChkDoc(i - 1).Left
            '      FrmPatPrint.TxtCopies(i).Top = FrmPatPrint.TxtCopies(i - 1).Top + 300
            '      FrmPatPrint.TxtCopies(i).Left = FrmPatPrint.TxtCopies(i - 1).Left
            '      FrmPatPrint.ChkIssuesOnly(i).Top = FrmPatPrint.ChkIssuesOnly(i - 1).Top + 300    '27Oct99 CFY Added
            '      FrmPatPrint.ChkIssuesOnly(i).Left = FrmPatPrint.ChkIssuesOnly(i - 1).Left        '         "
            '   End If
            
            'Set up captions, defaults etc..
            txt$ = TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "", "Doc" & Format$(i), 0)
            deflines txt$, lines$(), "|", 1, Numoflines
            DocsInfo(i).DocType = lines$(1)

            'Load additional checkboxes and text boxes as needed
            If i > 1 Then
                  Load FrmPatPrint.ChkDoc(i)
                  FrmPatPrint.ChkDoc(i).Top = FrmPatPrint.ChkDoc(i - 1).Top + 300
                  FrmPatPrint.ChkDoc(i).Left = FrmPatPrint.ChkDoc(i - 1).Left
                  If Val(DocsInfo(i).DocType) <> 6 Then         '27Jul04 TH Interface type does not require these ctrls
                     Load FrmPatPrint.TxtCopies(i)
                     Load FrmPatPrint.ChkIssuesOnly(i)                                                '27Oct99 CFY Added
                     FrmPatPrint.TxtCopies(i).Top = FrmPatPrint.TxtCopies(i - 1).Top + 300
                     FrmPatPrint.TxtCopies(i).Left = FrmPatPrint.TxtCopies(i - 1).Left
                     FrmPatPrint.ChkIssuesOnly(i).Top = FrmPatPrint.ChkIssuesOnly(i - 1).Top + 300    '27Oct99 CFY Added
                     FrmPatPrint.ChkIssuesOnly(i).Left = FrmPatPrint.ChkIssuesOnly(i - 1).Left        '         "
                  End If                                        '27Jul04 TH
               End If

            FrmPatPrint.ChkDoc(i).Caption = lines$(2)
            FrmPatPrint.ChkDoc(i).Value = Abs(TrueFalse(lines$(3)))
            FrmPatPrint.ChkDoc(i).Visible = True
            If Val(DocsInfo(i).DocType) <> 6 Then        '27Jul04 TH Interface type does not require these ctrls
                  FrmPatPrint.TxtCopies(i) = lines$(4)
                  FrmPatPrint.TxtCopies(i).Visible = True
                  FrmPatPrint.ChkIssuesOnly(i).Visible = (lines$(5) <> "NA")                             '27Oct99 CFY Added
                  'FrmPatPrint.ChkIssuesOnly(i).Value = Abs(Lines$(5) = "Y")                             '         "
                  FrmPatPrint.ChkIssuesOnly(i).Value = Abs(TrueFalse(lines$(5)))                         '06Dec99 AW Added
                  If FrmPatPrint.ChkDoc(i).Value = 1 Then                                                '         "
                        FrmPatPrint.ChkIssuesOnly(i).Enabled = True                                      '         "
                     Else                                                                                '         "
                        FrmPatPrint.ChkIssuesOnly(i).Enabled = False                                     '         "
                     End If
               End If                                   '27Jul04 TH
         Next
      
         'Reposition and resize other controls to accommodate
         If NumDocs > 1 Then
               FrmPatPrint.FraDocuments.Height = FrmPatPrint.FraDocuments.Height + (200 * NumDocs)
               FrmPatPrint.FraDateRange.Top = FrmPatPrint.FraDateRange.Top + (200 * NumDocs)
               FrmPatPrint.FraRxTypes.Top = FrmPatPrint.FraRxTypes.Top + (200 * NumDocs)
               FrmPatPrint.ChkPreview.Top = FrmPatPrint.ChkPreview.Top + (200 * NumDocs)
               FrmPatPrint.Height = FrmPatPrint.Height + (200 * NumDocs)
               FrmPatPrint.cmdCancel.Top = FrmPatPrint.cmdCancel.Top + (200 * NumDocs)
               FrmPatPrint.CmdPrint.Top = FrmPatPrint.CmdPrint.Top + (200 * NumDocs)
               FrmPatPrint.CmdSave.Top = FrmPatPrint.CmdSave.Top + (200 * NumDocs)                 '06Dec99 AW Added
            End If
      
      End If

   'Setup the prescription type checkboxes
   If Not ErrorFlag Then
         For i = 1 To (Len(PatientTypes$))
            txt$ = TxtD(dispdata$ & "\patmed.ini", "", "", "PatientTypeTxt" & Format$(i - 1), 0)
            If Trim$(txt$) = "" Then
                  popmessagecr "", "No text is defined for this patient type in PATMED.INI" & cr & "See your system manager for help."
                  ErrorFlag = True
                  Exit For
               End If
            FrmPatPrint.ChkRxType(i).Visible = True
            FrmPatPrint.ChkRxType(i).Caption = txt$


            txt$ = TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "", "Type" & Format$(i), 0)        '06Dec99 AW Added
            deflines txt$, lines$(), "|", 1, Numoflines                                                  '         "
            FrmPatPrint.ChkRxType(i).Value = Abs(TrueFalse(lines$(3)))                                   '         "
            Next
      End If
  
   'Setup Date ranges
   FrmPatPrint.TxtDtFrom.text = Format$(Now, "dd/mm/yyyy")
   FrmPatPrint.TxtDtTo.text = Format$(Now, "dd/mm/yyyy")
   FrmPatPrint.ChkUseDate.Value = Abs(TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "", "UseDate", 0)))
   If FrmPatPrint.ChkUseDate.Value = 1 Then                                                        '07Dec99 AW Added
         FrmPatPrint.TxtDtFrom.Enabled = True                                                      '         "
         FrmPatPrint.TxtDtTo.Enabled = True                                                        '         "
      Else                                                                                         '         "
         FrmPatPrint.TxtDtFrom.Enabled = False                                                     '         "
         FrmPatPrint.TxtDtTo.Enabled = False                                                       '         "
      End If                                                                                       '         "
   FrmPatPrint.ChkPreview.Value = Abs(TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "", "Preview", 0)))
   
End Sub

Sub PatientPrinting()
'20Oct99 CFY Ability to print discharge letters added
'27Oct99 CFY OnlyIssues flag now picked up from form and not hardcoded.
'28Apr00 ATW EVt 23951 Short loop to read PatientType$ fixed - no longer trucates last item from INI
'30Sep02 TH/ATW Now uses localfile to build prints from instead of hardcoded constant (#63694)
'15Jan07 PJC Calls to WriteRecords now pass in the document type. (#XXXXX)
'14Jan13 TH reinstated PIL Printing (TFS 46360)

Dim i%, j%, preview%, copies%, freetext%, Matches%, OnlyIssues%
Dim FromDate$, ToDate$, ErrMsg$, PrintTypes$
Dim strFile As String

   'Initialise ....
   FromDate$ = ""
   ToDate$ = ""
   preview = (FrmPatPrint.ChkPreview = 1)
   If FrmPatPrint.ChkUseDate = 1 Then
         FromDate$ = FrmPatPrint.TxtDtFrom.text
         ToDate$ = FrmPatPrint.TxtDtTo.text
      End If

   FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0
    
   'Determine which Rx's types have been selected
   For i = 1 To Len(PatientTypes$) '- 1 28Apr00 ATW - evt 23951 loop was short, missing of that last setting, causing selfmeds to be omitted (selfmeds always at end?)
      If FrmPatPrint.ChkRxType(i).Value = 1 Then
            PrintTypes$ = PrintTypes$ & Mid$(PatientTypes$, i, 1)
         End If
   Next
   
   'Loop through each possible document and print if required
   For i = 1 To NumDocs
      If FrmPatPrint.ChkDoc(i) = 1 Then
            If DocsInfo(i).DocType <> "6" Then  '16Jul04 TH
               copies = Val(FrmPatPrint.TxtCopies(i).text)
               OnlyIssues = Val(FrmPatPrint.ChkIssuesOnly(i).Value) = 1                  '27Oct99 CFY Added
            End If                            '16Jul04 TH
            ErrMsg$ = ""
            
            MakeLocalFile cTmpFile$    '30Sep02 TH/ATW Added
            
            Select Case DocsInfo(i).DocType
               'Patient Information Leaflet
               Case cPIL
                  WriteRecords OnlyIssues, True, False, FromDate$, ToDate$, PrintTypes$, Matches%, cPIL          '15Jan07 PJC Pass in the document type.
                  'WriteRecords OnlyIssues, True, False, FromDate$, ToDate$, PrintTypes$, Matches%               '         "
                  If Matches > 0 Then
                     PILPrinting dispdata$ & "\pil.rtf", copies, preview, ErrMsg$
                  End If
               
               'Patient Medication Card
               Case cPMC
                  freetext = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicationCard", "N", "PrintFreeTextLabels", 0))  '09Aug99 SF added
                  WriteRecords OnlyIssues, freetext, False, FromDate$, ToDate$, PrintTypes$, Matches%, cPMC      '15Jan07 PJC Pass in the document type.
                  'WriteRecords OnlyIssues, Freetext, False, FromDate$, ToDate$, PrintTypes$, Matches%           '         "
                  If Matches > 0 Then
                     medicard dispdata$ & "\pmc.rtf", copies, preview, ErrMsg$, 0 '16Jul04 TH Added param
                  End If
            
               'Discharge Letter
               Case cDischargeLtr                                       '20Oct99 CFY Added
''                  DischargePrint pid.recno, copies, preview, ErrMsg$    '         "
''                  Matches = 1                                           '         "

               '13Aug01 SF added for CMI enhancement
               Case cCMI
''                  WriteRecords OnlyIssues, True, False, FromDate$, ToDate$, PrintTypes$, Matches%, cCMI          '15Jan07 PJC Pass in the document type.
''                  'WriteRecords OnlyIssues, True, False, FromDate$, ToDate$, PrintTypes$, Matches%               '         "
''                  If Matches > 0 Then
''                        CMIPrinting copies, preview
''                     End If
               '13Aug01 SF -----

               Case cInvoice    '12Sep02 ATW ; Billing invoices
                    Matches = billpatient(26, "") ' 19Sep02 ATW 25 changed to 26 as constant overlapped

               Case cPMCInterface
''                  'Freetext = truefalse(txtd(dispdata$ & "\PATMED.INI", "MedicationCard", "N", "PrintFreeTextLabels", 0))  '09Aug99 SF added
''                  WriteRecords OnlyIssues, Freetext, False, FromDate$, ToDate$, PrintTypes$, Matches%, cPMCInterface          '15Jan07 PJC Pass in the document type.
''                  'WriteRecords OnlyIssues, Freetext, False, FromDate$, ToDate$, PrintTypes$, Matches%                        '         "
''                  If Matches > 0 Then
''                        strFile = TxtD(dispdata$ & "\GenInt.INI", "MedicationCard", "PMC.RTF", "RTFFileName", 0)
''                        medicard dispdata$ & "\" & strFile, copies, preview, ErrMsg$, True '16Jul04 TH Added interface parameter
''                     End If

            End Select
         
            On Error Resume Next
            Kill cTmpFile$
            If Err Then    '30Sep02 TH/ATW Added to log failures
               'logit
               WriteLog patdatapath$ & "\PatPrint.log", SiteNumber, UserID$, " Terminal = " & ASCTerminalName$() & " Error: Failed to kill patprint local file"
               Err = 0
            End If
            On Error GoTo 0
         
            'If Nothing to print then notify the user
            'If Matches = 0 Then
            If Matches = 0 And Not k.escd Then
                  popmessagecr "#", "No medications to print for " & FrmPatPrint.ChkDoc(i).Caption & crlf & "using this selection criteria"
               End If
            
            'If there were problems then notify the user
            If Len(ErrMsg$) Then
                  ErrMsg$ = "The following problems occured whilst printing " & FrmPatPrint.ChkDoc(i).Caption & ":" & crlf & ErrMsg$
                  popmessagecr "!", ErrMsg$
               End If
         End If
   Next

   Unload FrmPatPrint

End Sub

Sub PatientPrintingSave()
'06Dec99 AW Created To allow default values for PatientPrinting screen to be saved

Dim initext$, text$, Value$, PreviewValue$, NoofCopies$, IssueValues$, UseDate$
Dim DocNo%, success%, NoofTypes%, i%, NoofDocs%, ret%
   
   ret% = MessageBox("Do you wish to save changes? ", MB_YESNO, "Save")
   If ret% = IDYES Then
         If Not k.escd Then
               NoofDocs% = Val(TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "", "NumDocs", 0))
               For i = 1 To NoofDocs%
                     text$ = FrmPatPrint.ChkDoc(i).Caption
                     If FrmPatPrint.ChkDoc(i).Value = 1 Then
                           Value$ = "Y"
                        Else
                           Value$ = "N"
                        End If
                     NoofCopies$ = FrmPatPrint.TxtCopies(i).text
                     If FrmPatPrint.ChkIssuesOnly(i).Value = 1 Then
                           IssueValues$ = "Y"
                        Else
                           IssueValues$ = "N"
                        End If
                     initext$ = i% & "|" & text$ & "|" & Value$ & "|" & NoofCopies$ & "|" & IssueValues$
                     WritePrivateIniFile "PatientPrinting", "Doc" & Format(i%), Format(initext$), dispdata$ & "\patmed.ini", success%
                     FlushIniCache
                     If Not success% Then
                           popmessagecr "!", "A problem arose saving the new settings." & crlf & "Changes may be lost."
                        End If
                     
               Next
               NoofTypes% = Len(TxtD(dispdata$ & "\patmed.ini", "", "", "PossiblePatientTypes", 0))
               For i = 1 To NoofTypes%
                     text$ = FrmPatPrint.ChkRxType(i).Caption
                     text$ = Mid$(text$, 2, Len(text$) - 1)
                     If FrmPatPrint.ChkRxType(i).Value = 1 Then
                           Value$ = "Y"
                        Else
                           Value$ = "N"
                        End If

                     initext$ = i% & "|" & text$ & "|" & Value$
                     WritePrivateIniFile "PatientPrinting", "Type" & Format(i%), Format(initext$), dispdata$ & "\patmed.ini", success%
               Next
               If FrmPatPrint.ChkPreview.Value = 1 Then
                     PreviewValue$ = "Y"
                  Else
                     PreviewValue$ = "N"
                  End If
               WritePrivateIniFile "PatientPrinting", "Preview", Format(PreviewValue$), dispdata$ & "\patmed.ini", success%
               FlushIniCache
               If Not success% Then
                     popmessagecr "!", "A problem arose saving the new settings." & crlf & "Changes may be lost."
                  End If

               If FrmPatPrint.ChkUseDate.Value = 1 Then
                     UseDate$ = "Y"
                  Else
                     UseDate$ = "N"
                  End If
               WritePrivateIniFile "PatientPrinting", "UseDate", Format(UseDate$), dispdata$ & "\patmed.ini", success%
               FlushIniCache
               If Not success% Then
                     popmessagecr "!", "A problem arose saving the new settings." & crlf & "Changes may be lost."
                  End If

            End If
      End If
      Unload FrmPatPrint
End Sub

Sub PILPrinting(Layout$, copies%, preview%, ErrMsg$)
'''30Jun99 CFY written
'''11Oct99 CFY Rewritten so that any number of drugs can be printed on the same PIL.
'''            Now also contains dosing information.
'''17Nov99 CFY Implemented Preview function
'''20Dec99 CFY Improved descriptions which are built up to provide dosing information. Also corrected logic which decides
'''            if a dose is given at breakfast, lunch, teatime etc...
'''12Jan07 PJC Added RxDescriptionRaw for each label to the print heap. (SC-06-0474 #84583)
''
'14Jan13 TH Reinstated as port for version 10 (TFS 46360,51368)
'17Jan13 TH fix l.dose fencepost bug (TFS 53471)
'04Jan17 TH Changes to RTF Handling (TFS 157969)
'12Jan17 TH refactored using new sub to use DB rtf handling (Hosted)
'25Jan17 TH Replaced parsertf to use new DB rtf sub (Hosted) (TFS 174610)
'03Feb17 TH Use new marker for local file inclusion (TFS 174610)
'14Mar17 TH Added check for pil.rtf - long standing fault led to proble when file is used below but isnt available (TFS 179340)

Dim fchan%, done%, lngDrugFound As Long, NumOfTimes%, i%, j%, StartTime%, StopTime%, FoundTime%, DoseTime%, NumLocalFiles% '01Jun02 All/CKJ was found%
Dim dummy$, msg$, tmp$, DosingInfo$, Context$, FILE$, directions$
Dim fnd&, Numoflines%
Dim range$(), LocalFile$()
Dim PilDoseInfo() As TPILDoseInfo
Dim FromRange() As TTimeRange, ToRange() As TTimeRange
Dim iSplitLine As Integer                '12Jan07 PJC Added (#84583)
Dim intCount   As Integer                '         "
Dim trimmed    As Integer                '         "
Dim strText    As String                 '         "
Dim lngRequestID As Long  '14Jan13 TH Added
'Dim intSuccess As Integer '04Jan17 TH added

   'GetRTFTextFromDB dispdata$ & "\pildets.rtf", strText, intSuccess '04Jan17 TH Moved above for check
   
   'If Not fileexists(dispdata$ & "\pildets.rtf") Then
   'If Not intSuccess Then
   If Not RTFExistsInDatabase(dispdata$ & "\pildets.rtf") Then '12Jan17 TH refctored using new sub.
      'ErrMsg$ = dispdata$ & "\pildets.rtf cannot be found. Unable to print PIL"
      ErrMsg$ = "pildets.rtf cannot be found in database. Unable to print PIL"
      Exit Sub       '<=== WAY OUT!!
   'Else
   '   strText = ""
   End If
   
   '14Mar17 TH Added this block check for pil - long standing fault led to proble when file is used below but isnt available (TFS 179340)
   If Not RTFExistsInDatabase(dispdata$ & "\pil.rtf") Then '12Jan17 TH refctored using new sub.
      ErrMsg$ = "pil.rtf cannot be found in database. Unable to print PIL"
      Exit Sub       '<=== WAY OUT!!
   End If

   ReDim range$(10)

   'Determine dosing time ranges
   tmp$ = TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "0800,1200,1600,2100", "PILTimes", 0)
   deflines tmp$, range$(), ",", 1, NumOfTimes
   CreateTimeRanges FromRange(), ToRange(), range$(), NumOfTimes
   ReDim PilDoseInfo(NumOfTimes)
   For i = 1 To NumOfTimes
      PilDoseInfo(i).StartTime = FromRange(i)
      PilDoseInfo(i).StopTime = ToRange(i)
      PilDoseInfo(i).desc = TxtD$(dispdata$ & "\patmed.ini", "PatientPrinting", "<Not Defined>", "PilTimeDesc" & Format$(i), 0)
   Next

   fchan = FreeFile
   Open cTmpFile$ For Binary As fchan
   Get #fchan, , pid
   dummy$ = Space$(2)                              'skip over the extra two chars
   Get #fchan, , dummy$

   'Loop through each prescription creating PIL sections and storing in localfiles
   NumLocalFiles = 0
   Do While Not EOF(fchan)
   
      dummy$ = Space$(10)
      Get #fchan, , dummy$
      lngRequestID = Val(dummy$)
      dummy$ = Space$(2)
      Get #fchan, , dummy$    ' skip over the extra two chars

      'Get #fchan, , strLine    ' skip over the extra two chars
      'v9 Use dummy to get the label
      If lngRequestID > 0 Then
         GetLabelNL lngRequestID, L
         
         
         'Get #fchan, , L
         'dummy$ = Space$(2)
         'Get #fchan, , dummy$                         'skip over the extra two chars
   
         Erase labelline$                                                                                      '12Jan07 PJC Added RxDescriptionRaw for each label to the print heap.(#84583)
         strText = L.text                                                                                      '            "
         ParseEndDirMarker strText, Chr$(&H1F), Chr$(30), iSplitLine                                           '            "
         SetDescriptionSplitLine iSplitLine                                                                    '            "
                                                                                                               '            "
         deflines strText, labelline$(), Chr$(30), 1, Numoflines                                               '            "
         For intCount = 1 To Numoflines ' + 1                                                                  '            "
            Do                                                                                                 '            "
               trimmed = False                                                                                 '            "
               If Len(labelline$(intCount)) >= 2 Then   'ASC 26Sep93                                           '            "
                  If Left$(labelline$(intCount), 2) = "^^" Then                                             '            "
                     labelline$(intCount) = Right$(labelline$(intCount), Len(labelline$(intCount)) - 1)  '            "
                     trimmed = True                                                                      '            "
                  End If                                                                                 '            "
               End If                                                                                       '            "
            Loop Until Not trimmed                                                                             '            "
         Next                                                                                                  '            "
         FillHeapLabelText gPRNheapID, labelline$(), iSplitLine, 5                                             '            "
   
         If PatternMatch(L.SisCode, "AAA999A") Then
            msg$ = ""
            d.SisCode = L.SisCode
            getdrug d, 0, lngDrugFound, False                '01Jun02 All/CKJ

            directions$ = Trim$(L.drdirection)                                   '20Dec99 CFY Added
            deflines directions$, lines$(), crlf, 1, Numoflines                  '        "

            If lngDrugFound > 0 Then                        '01Jun02 All/CKJ
               'Add relevent information onto heap....
               FillHeapDrugInfo gPRNheapID, d, 0
               If d.PILnumber <> 0 Then
                  Heap 10, gPRNheapID, "PILInfo", "[#include" & TB & dispdata$ & "\PIL\" & Format$(d.PILnumber) & ".pil" & "]", 0   'PIL text
               Else
                  Heap 10, gPRNheapID, "PILInfo", "", 0
               End If

               DosingInfo$ = ""
               i = 1
               Do While (i <= 6) 'And (Trim$(L.Times(i)) <> "")                        'Cycle through each dose
                  If (Trim$(L.Times(i)) = "") Then Exit Do '17Jan13 TH Removed from main loop criteria as caused subscript out o range error when hit 7 (TFS 53471)
                  'WDir.Code = Format$(L.dose(i))
                  'getdir 0, "", fnd&                                                   'Get the directions

                  j = 1                                                               'Work out which time zone the dose takes
                  FoundTime = False                                                   'place in. eg. breakfast, lunchtime etc..
                  Do While (j <= NumOfTimes) And (Not FoundTime)
                     StartTime = Val(Format(PilDoseInfo(j).StartTime.Hrs, "00") & Format(PilDoseInfo(j).StartTime.min, "00"))
                     StopTime = Val(Format(PilDoseInfo(j).StopTime.Hrs, "00") & Format(PilDoseInfo(j).StopTime.min, "00"))
                     If StopTime < StartTime Then StopTime = StopTime + 2400           '20Dec99 CFY Added
                     DoseTime = Val(Format(L.Times(i)))
                     FoundTime = (DoseTime >= StartTime) And (DoseTime <= StopTime)
                     j = j + 1
                  Loop

                  j = j - 1

                  If FoundTime Then                                                    'Build up the text eg. Take 2 tablets at breakfast
                     'DosingInfo$ = DosingInfo$ & trimz(wdir.directs) & " at " & PilDoseInfo(j).Desc & " \par "      '20Dec99 CFY Replaced
                     DosingInfo$ = DosingInfo$ & lines$(1) & " at " & PilDoseInfo(j).desc & " \par "                 '         "
                  End If

                  i = i + 1
               Loop

               Heap 10, gPRNheapID, "dosinginfo", DosingInfo$, 0

               'Parse information and store name of local file
               NumLocalFiles = NumLocalFiles + 1
               ReDim Preserve LocalFile$(NumLocalFiles)
               'parseRTF dispdata$ & "\pildets.rtf", LocalFile$(NumLocalFiles)
               parseRTFfromDB dispdata$ & "\pildets.rtf", LocalFile$(NumLocalFiles) '25Jan17 TH Replaced to use DB rtf (Hosted) (TFS 174610)
            Else
               ErrMsg$ = ErrMsg$ & "NSVCode '" & trimz(L.SisCode) & "' not found in drug file" & crlf
            End If

         End If
      End If
   Loop
   

   'Create heap entry which will have the include to all the local files
   tmp$ = ""
   For i = 1 To NumLocalFiles
      'tmp$ = tmp$ & "[#include" & TB & LocalFile$(i) & "] \par"
      tmp$ = tmp$ & "[#includx" & TB & LocalFile$(i) & "] \par"  '03Feb17 TH Use marker for local file inclusion (TFS 174610)
   Next
   Heap 10, gPRNheapID, "medicines", tmp$, 0

   If preview Then                                             '17Nov99 CFY Added
      'parseRTF Layout$, FILE$                               '17Nov99 CFY Added
      parseRTFfromDB Layout$, FILE$           '04Jan17 TH Now do the parsing from the DB template data (Hosted)
      Hedit 11, FILE$                                       '17Nov99 CFY Added
   End If                                                   '17Nov99 CFY Added

   'Print the leaflet
   For i = 1 To copies
      Context$ = cPILContext
      If copies > 1 Then Context$ = Context$ & Format$(i)
      If preview Then
         'ParseThenPrint Context$, FILE$, 1, 0, 0
         ParseThenPrint Context$, FILE$, 1, 0, 0, True '04Jan17 TH Parse the local file (again?) (Hosted)
      Else
         'ParseThenPrint Context$, Layout$, 1, 0, 0
         ParseThenPrint Context$, Layout$, 1, 0, 0, False '04Jan17 TH Now do the parsing from the DB template data (Hosted)
         
      End If
   Next

   'Remove the local files
   For i = 1 To NumLocalFiles
      On Error Resume Next
      Kill LocalFile$(i)
      On Error GoTo 0
   Next

   Close fchan

End Sub

Sub WriteRecords(OnlyIssues%, freetext%, Blister%, FromDate$, ToDate$, PrintTypes$, matchesfound%, strDocType As String)
'16Nov99 CFY Fix so that date ranges are converted to the correct format and compared correctly
'17Jul02 TH  Mod to allow UMMC to print history items on PMC (#61986)
'15Jan07 PJC Passing in the document type. Test for the document type and the presence of a PIL number if configured. (#XXXXX)
'08Mar07 PJC GetLabel now called with flag that preserves the Directions Marker in l.text, allowing RxDescriptionRaw and RxDirectionsRaw to be determined for PIL printing. (SC-06-0474 #84583)
'15Feb13 XN  Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'12Jan17 TH  Refctored to use DB rtf handling (Hosted)
Dim outchan%, X%, docheck%, valid%
Dim FromDt&, ToDt&, RxDate&
Dim temp$
Dim blnExcludePIL     '15Jan07 PJC Added
Dim rsLabels As ADODB.Recordset
Dim strParams As String
Dim intSuccess As Integer '12Jan17 TH Added (Hosted)

   'Convert dates to required format for comparison
   If Trim$(FromDate$) <> "" Then
         parsedate (FromDate$), temp$, "YYYYMMDD", valid
         'If valid Then FromDt = Val(FromDate$)                   '16Nov99 CFY Replaced
         If valid Then FromDt = Val(temp$)                        '         "
      End If
   If Trim$(ToDate$) <> "" Then
         parsedate (ToDate$), temp$, "YYYYMMDD", valid
         'If valid Then ToDt = Val(ToDate$)                       '16Nov99 CFY Replaced
         If valid Then ToDt = Val(temp$)                          '         "
      End If

   'Open Temp File
   outchan = FreeFile
   Open cTmpFile$ For Append As outchan
   r.record = ""
   LSet r = pid
   Print #outchan, Left$(r.record, Len(pid))
   
   matchesfound = 0
   blnExcludePIL = TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "N", "ExcludePILIfNoPILNumber", 0))      '15Jan07 PJC Exclude drugs that don't have a PILNumber.
   
   'v9 OK Here we will bring back all Labels where nodissued > 0 siscode not blank
   ' We will still do the date check and issue type check here for now
   strParams = gTransport.CreateInputParameterXML("PatientID", trnDataTypeint, 4, pid.recno)
   
   Set rsLabels = gTransport.ExecuteSelectSP(g_SessionID, "pWLabelsbyPatientIDForPharmacyPrinting", strParams)
   
   'Read through each label...
''   For X = 1 To 50
   Do While Not rsLabels.EOF
      'If labrf&(x) > 1 Then                                                                                                                  '17Jul02 TH Added to allow UMMC to print history items on PMC
''      If (labrf&(X)) > 1 Or (TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "N", "AllowHistory", 0)) And (labrf&(X) < 0)) Then   '    "
            'labf& = labrf&(x)        '17Jul02 TH Added
''            Labf& = Abs(labrf&(X))    '   "
            'getlabel False   '08Mar07 PJC Replaced by below (SC-06-0474 #84583)
''            getlabel 4        '08Mar07 PJC now called with flag that preserves the Directions Marker in l.text, allowing RxDescriptionRaw and RxDirectionsRaw to be determined for PIL printing. (SC-06-0474 #84583)
            'just read the necessary from the recordset
            'Work out if we want this label or not...
''            findfile$ = ""
            docheck = True
''            If OnlyIssues And docheck Then
''                  If L.Nodissued = 0 Then docheck = False
''               End If
            If OnlyIssues And docheck Then
               If Val(RtrimGetField(rsLabels!Nodissued)) = 0 Then docheck = False
            End If
            If freetext And docheck Then
''                  If Trim$(L.SisCode) = "" Then docheck = False
               If Trim$(RtrimGetField(rsLabels!SisCode)) = "" Then docheck = False
            End If
               
''            If InStr(PrintTypes$, L.IssType) = 0 Then docheck = False
            If InStr(PrintTypes$, RtrimGetField(rsLabels!IssType)) = 0 Then docheck = False
            
            'Check label falls between valid date ranges
            'parsedate (l.lastdate), Temp$, "3", valid
''            parsedate (L.lastdate), temp$, "YYYYMMDD", valid
'           If Trim$((RtrimGetField(rsLabels!lastdate))) = "" Then      40210 XN 15Feb13 use proper date\time for WLabel
            Dim lastdate As String
            lastdate$ = Trim$(LastSavedDateTimeToLastDate(rsLabels!lastSavedDateTime))
            If lastdate$ = "" Then
               docheck = False
            Else
               parsedate lastdate$, temp$, "YYYYMMDD", valid
               If valid Then
                  RxDate = Val(temp$)
                  If FromDt <> 0 Then
                     If RxDate < FromDt Then docheck = False
                  End If
                  If ToDt <> 0 Then
                     If RxDate > ToDt Then docheck = False
                  End If
               End If
            End If
            'Special Check for Blister Packs
            'v9 DOnt need this for NT
''            If Blister Then
''                  If (Asc(L.Flags) And &H38) = 0 Then
''                        docheck = False
''                     Else
''                        docheck = True
''                     End If
''                  End If
            
            'v9 DOnt need this for NT
            '14Jan13 TH Now reinstated (TFS 46360)
            If strDocType = cPIL And blnExcludePIL And docheck Then                                      '15Jan07 PJC Check for the PILNumber if required.
               d.SisCode = L.SisCode                                                                  '          "
               getdrug d, 0, 0, False                                                                 '          "
               If d.PILnumber = 0 Then                                                                '          "
                  docheck = False                                                                  '          "
               Else                                                                                '          "
                  'If fileexists(dispdata$ & "\PIL\" & Format$(d.PILnumber) & ".pil") = False Then  '
                  '08Jan17 TH Replaced above to move to DB based rtf (TFS 157969)
                  'GetRTFTextFromDB dispdata$ & "\PIL\" & Format$(d.PILnumber) & ".pil", "", intSuccess
                  'If Not intSuccess Then
                  If Not RTFExistsInDatabase(dispdata$ & "\PIL\" & Format$(d.PILnumber) & ".pil") Then '12Jan17 TH refctored using new sub.
                     docheck = False
                  End If
                  'End If                                                                        '          "
               End If                                                                              '          "
            End If                                                                                    '          "

            'If we still want it then write the record
            If docheck Then
                  matchesfound = matchesfound + 1
                  r.record = ""
                  'CastRecordsetToLabel rsLabels, L
                  'LSet r = L
''                  Print #outchan, Left$(r.record, Len(L))
                  Print #outchan, Left$(CStr(RtrimGetField(rsLabels!RequestID)) & Space$(10), 10)
               End If
''         End If
''   Next
      rsLabels.MoveNext
   Loop
   
   rsLabels.Close
   Set rsLabels = Nothing
   
''   Print #outchan, Space$(Len(L))
   Print #outchan, Space$(10)
   Close outchan
   
End Sub

Sub DoDischarge()
'''19Oct99 CFY Code added to add an extra discharge event with a pre-specified discharge letter attached.
'''28Oct99 CFY Added code to initialise teamwork just in case.
'''19Jan99 AE  Merged code which was lost in the original merge.
'''14Jun00 AE  Added Parameters to calls to Selector
'''14Dec00 CKJ 'Discharger' section moved from ParseRx where it created multiple events for each item
'''            Copy taken of labf, FindFile and the l structure & restored afterwards.
'''15dec00 CKJ/EAC revised above mod
'''17Jan01 CKJ Removed parsing of pid.recno into filename - it has to be kept intact as the extension gets replaced
'''30Oct01 CKJ Added option to allow message to be rewritten
'''            Added option to allow radio button selection with site defined text
'''13May02 CKJ Now defaults to first InUse summary, not where ID=1 as that may not be in use
'''07Jun02 CKJ One level of indirection was missing, picking wrong summary when default not used
'''            Now finds the number of matches, not just the first one, then shows list to the user
'''            Selected one has name added to the displayed caption
'''            No longer defaults to first inuse summary when no match is found - warns user instead.
'''16Aug05 CKJ/TH Added FillHeapLabelInfo
'''20Sep05 CKJ/PJC Added FillHeapDrugInfo
'''20Nov06 PJC ParseRX now called with an array holding the local file names/paths used for the dischage letter. (#78186)
''
''Dim ans$, Changed%, success%, mode%, n%, preview%, InProgress%, patfile$
''Dim i As Integer
''Dim opt As String
''Dim Method As String
''Dim MnuString As String
''Dim copies%, Files$(), lines$(), desc$, File$  '02Sep99 AE Added
''Dim DischargeForm%, msg$, action%, Numoflines%
''Dim db As Database, sn As Snapshot
''Dim RTFline$, temp$, PrintFile$, TmpString$
''Dim Query$(), Recd&(), Matches%()            '19jan00 AE Added
''Dim Qcnt%, iSelHnd As Integer                '14Jun00 AE Added iSelHnd
''Dim intPWvalid As Integer                    '14dec00 CKJ Added
''Dim iLoop As Integer                         '   "
''Dim udtLabel As WLabel                       '   "
''Dim lngLabelPtr As Long                      '   "
''Dim strFindFileCopy As String                '   "
''Dim strSummaryNames() As String              '07Jun02 CKJ
''Dim strSummaryName As String                 '
''Dim intMatches As Integer                    '   "
''Dim intloop As Integer                       '   "
''Dim dcopy As DrugParameters                  '20Sep05 CKJ/PJC
''Dim strTmpFile As String                     '20Nov06 PJC Added   (#78186)
''Dim strTempFiles() As String                 '        "
''Dim intCount As Integer                      '        "
''
''   ReDim FileInfo$(10)
''
''   'If Len(trimz$(PID.recno)) > 8 Then                                                     '17Jan01 CKJ Removed
''   '      patfile$ = Left$(trimz$(PID.recno), 8) & "." & Mid$(trimz$(PID.recno), 9) & "_"  '   "
''   '   Else                                                                                '   "
''   '      patfile$ = trimz$(PID.recno) & ".rtf"                                            '   "
''   '   End If                                                                              '   "
''   'patfile$ = patdatapath$ & "\" & patfile$                                               '   "
''   patfile$ = patdatapath$ & "\" & trimz$(pid.recno) & ".rtf"                              '   "        Keep pid.recno intact
''
''   If InStr(Command$, "preview") Then                                           'If demo mode, show list box
''         LstBoxFrm.Caption = "Prepare Discharge Letter (Demo mode)"
''         LstBoxFrm.LstBox.AddItem "Print Discharge Letter (Pharmacist)"         'choice = 2
''         LstBoxFrm.LstBox.AddItem "Enter Clinical Summary (Doctor)"             'choice = 3
''         LstBoxShow
''         mode = LstBoxFrm.LstBox.ListIndex + 2
''         Unload LstBoxFrm
''      Else
''         mode = passlvl
''      End If
''
''   Select Case mode
''      Case 3   'Doctor
''         k.escd = False                                                                '07Jun02 CKJ added
''         If fileexists(patfile$) Then
''               msg$ = "Discharge already completed! " & crlf
''               msg$ = msg$ & "Do you wish to edit the clinical summary? (choose 'Yes')" & crlf
''               msg$ = msg$ & "or cancel the discharge and re-do? (choose 'No')" & crlf
''
''               msg$ = TxtD(dispdata$ & "\patmed.ini", "Messages", msg$, "MsgEditClinicalSummary", 0)  '30Oct01 CKJ Added to allow message to be rewritten
''               ParseCtrlChars dispdata$ & "\printer.ini", "Screen", msg$, 0                           '   "
''
''               askwin "?ASCribe", msg$, ans$, k
''               Select Case ans$
''                  Case "Y": action = IDYES
''                  Case "N": action = IDNO
''               End Select
''               If k.escd Then action = IDCANCEL
''            Else
''               action = IDNO              '<-- Default is to start from scratch
''            End If
''
''         If Not fileexists(dispdata$ & "\RXline.rtf") Then
''               ans$ = "Cannot find the PMR line layout file " & cr$
''               ans$ = ans$ & dispdata$ & "\RXline.rtf" & ".  Please contact your system administrator"
''               popmessagecr "Discharge", ans$
''               action = IDCANCEL       '<---  Force exit
''            End If
''
''         If action = IDCANCEL Then k.escd = True
''
'''         If InStr(Command$, "preview") Then                                            'Demo mode for testing
'''               LstBoxFrm.LstBox.Clear                                                  '           "
'''               LstBoxFrm.Caption = "Demo Mode"                                         '           "
'''               LstBoxFrm.LblTitle = "Select Clinical summary layout"                   '           "
'''               Set db = OpenDatabase(dispdata$ & "\ClinSum.mdb")                       '           "
'''               ans$ = "SELECT ID,SummaryName FROM Summarys WHERE InUse = True"         '           "
'''               Set sn = db.CreateSnapshot(ans$)                                        '           "
'''               Do                                                                      '           "
'''                  If Not sn.EOF Then                                                   '           "
'''                        LstBoxFrm.LstBox.AddItem sn!SummaryName                        '           "
'''                        LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = sn!id   '           "
'''                        sn.MoveNext                                                    '           "
'''                     End If                                                            '           "
'''               Loop Until sn.EOF                                                       '           "
'''               LstBoxShow                                                              '           "
'''               If LstBoxFrm.Tag = "" Then Exit Sub                                     '           "
'''               i = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)               '           "
'''               Unload LstBoxFrm                                                        '           "
'''               sn.Close                                                                '           "
'''               Set sn = Nothing                                                        '           "
'''               db.Close                                                                '           "
'''               Set db = Nothing                                                        '           "
'''            Else
'''               i = 1
'''            End If
''
''         'Set up the clinical summary form                                                      '19jan00 AE Merged; replaces above
''         Set db = OpenDatabase(dispdata$ & "\ClinSum.mdb")                                      '     "
''         ans$ = "SELECT ID,SummaryName,SelectionParameters FROM Summarys WHERE InUse = True"    '     "
''         Set sn = db.CreateSnapshot(ans$)                                                       '     "
''                                                                                                '     "
''         'Demo mode, user can choose summary                                                    '     "
''         If InStr(Command$, "preview") Then                                                     '     "
''               LstBoxFrm.LstBox.Clear                                                           '     "
''               LstBoxFrm.Caption = "Demo Mode"                                                  '     "
''               LstBoxFrm.lblTitle = "Select Clinical summary layout"                            '     "
''               Do                                                                               '     "
''                  If Not sn.EOF Then                                                            '     "
''                        LstBoxFrm.LstBox.AddItem sn!SummaryName                                 '     "
''                        LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = sn!id            '     "
''                        sn.MoveNext                                                             '     "
''                     End If                                                                     '     "
''               Loop Until sn.EOF                                                                '     "
''               LstBoxShow                                                                       '     "
''               If LstBoxFrm.Tag = "" Then Exit Sub                                              '     "
''               i = LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)                        '     "
''               Unload LstBoxFrm                                                                 '     "
''               sn.Close                                                                         '     "
''               Set sn = Nothing                                                                 '     "
''               db.Close                                                                         '     "
''               Set db = Nothing                                                                 '     "
''            Else                                                                                '     "
''               'Normal mode, Select which summary to use based on the selction parameters       '     "
''               Do                                                                               '     "
''                  If Not sn.EOF Then                                                            '     "
''                        Qcnt = Qcnt + 1                                                         '     "
''                        ReDim Preserve Query$(1 To Qcnt)                                        '     "
''                        ReDim Preserve Recd&(1 To Qcnt)                                         '07Jun02 CKJ Added
''                        ReDim Preserve strSummaryNames(1 To Qcnt) As String
''                        Query$(Qcnt) = GetField(sn!SelectionParameters)
''                        If Trim$(Query$(Qcnt)) = "" Then Query$(Qcnt) = "SELECT * FROM [TABLE]" 'auto select if field is empty
''                        Recd(Qcnt) = sn!id
''                        strSummaryNames(Qcnt) = GetField(sn!SummaryName)                        '07Jun02 CKJ Added
''                        sn.MoveNext
''                     End If
''               Loop Until sn.EOF
''
''               'Check which queries match current parameters
''               SelectorInitialise iSelHnd, "0", ""                         '14Jun00 AE  Added parameters
''               RecordsMatchingCriteria iSelHnd, Query$(), Matches()        '     "
''               SelectorFinished iSelHnd, ""                                '     "
''               i = -1
''               intMatches = 0                                                                   '07Jun02 CKJ Added
''               On Error Resume Next
''               'i = Matches(1)                       'Choose first match                        '07Jun02 CKJ One level of indirection was missing - see below
''               intMatches = UBound(Matches)                                                     '            now return number of matches, not the first one
''               On Error GoTo 0
''
''               Select Case intMatches                                                           '07Jun02 CKJ Added block to present list to the user
''                  Case 0
''                     popmessagecr ".", "No clinical summary available - please inform System Manager"
''                     k.escd = True                                                              'don't proceed
''                  Case 1
''                     i = Recd&(Matches(1))                                                      'Only one match, use array of ID numbers
''                     strSummaryName = strSummaryNames(Matches(1))
''                  Case Else                                                                     'Allow choice of layouts
''                     Unload LstBoxFrm
''                     LstBoxFrm.Caption = "Clinical Summary"
''                     LstBoxFrm.lblTitle = cr & "More than one clinical summary layout is available" & cr & "Please select the one to be used" & cr
''                     For intloop = 1 To intMatches
''                        LstBoxFrm.LstBox.AddItem " " & strSummaryNames(Matches(intloop))
''                     Next
''                     LstBoxShow
''                     If LstBoxFrm.Tag = "" Then
''                           k.escd = True
''                        Else
''                           i = Recd&(Matches(LstBoxFrm.LstBox.ListIndex + 1))
''                           strSummaryName = strSummaryNames(Matches(LstBoxFrm.LstBox.ListIndex + 1))
''                        End If
''                     Unload LstBoxFrm
''                  End Select                                                                    '07Jun02 CKJ end of block
''
''                '07Jun02 CKJ Removed section as it is handled above now
''     '          'If i = -1 Then i = 1           'if none match, default to the first one         '     "     '13May02 CKJ Should be first InUse one, not ID=1
''     '          If i = -1 And Qcnt > 0 Then i = Recd(1)                                                      '   "        if none match, default to the first one in use
''     '          If i = -1 Then                                                                               '   "        may be none in use
''     '                popmessagecr ".", "No clinical summary available - please inform System Manager"       '   "
''     '                k.escd = True                                                                          '   "        don't proceed
''     '             End If                                                                                    '   "
''            End If
''
''         If Not k.escd Then
''               ClinSum.lblDesc(0).Caption = "Patient: "
''               ClinSum.LblDetails(0).Caption = SelectorPatient("pForename_pSurname")
''               ClinSum.lblDesc(1).Caption = "Consultant: "
''               ClinSum.LblDetails(1).Caption = SelectorPatient("pConsExp")
''               ClinSum.lblDesc(2).Caption = "Ward: "
''               ClinSum.LblDetails(2).Caption = SelectorPatient("pWardExp")
''               ClinSum.lblDesc(3).Caption = "Case No: "
''               ClinSum.LblDetails(3).Caption = SelectorPatient("pCaseNo")
''               ClinSum.Caption = "Clinical Summary " & strSummaryName                           '07Jun02 CKJ added name
''               ClinSum.lblTitle.Caption = "Clinical Summary"
''               BuildClinSum i
''               If action = IDYES Then
''                     GetClinSumText patfile$                                 'recover text to edit
''                  End If
''               ShowClinSum i, patfile$, Files$()                               'Get the users input and store it in patfile 19jan99 AE Added i parameter
''            End If
''
''         'Add id of discharger to clinical summary if confirmed completed
''         If Not k.escd Then
''               GetTextFile patfile$, temp$, success%
''
''               If success Then                                            '15dec00 CKJ/EAC only continue is success=T
''                     '30Oct01 CKJ Added block to allow radio button selection with site defined text
''                     MnuString = TxtD(dispdata$ & "\patmed.ini", "Messages", "", "MsgCheckDischargePrompt", 0)              '30Oct01 CKJ
''                     If MnuString <> "" Then                                                                                '   "
''                           ParseCtrlChars dispdata$ & "\printer.ini", "Screen", MnuString, False                            '   "
''                           frmoptionset -1, TxtD(dispdata$ & "\patmed.ini", "Messages", "", "MsgCheckDischargeTitle", 0)    '   "
''                           frmoptionset -2, MnuString                                                                       '   "
''                           frmoptionset 1, TxtD(dispdata$ & "\patmed.ini", "Messages", "", "MsgCheckDischargeTextYes", 0)   '   "
''                           frmoptionset 1, TxtD(dispdata$ & "\patmed.ini", "Messages", "", "MsgCheckDischargeTextNo", 0)    '   "
''                           frmoptionshow "1", ans$                                                                          '   "
''                           frmoptionset 0, ""                                                                               '   "
''                           If ans$ = "1" Then ans$ = "Y" Else ans$ = "N"                                                    '   "
''                        Else                                                                                                '   "
''                           msg$ = "Order Discharge prescription and confirm Clinical Details:" & crlf & crlf
''                           msg$ = msg$ & "Those marked with D on the left will be dispensed." & crlf
''                           msg$ = msg$ & "Please check discharge items are selected before proceeding." & crlf & crlf
''                           msg$ = msg$ & "OK to proceed?"
''                           askwin "?ASCribe: Discharge Prescription", msg$, ans$, k
''                        End If                                                                                              '   "
''                  Else                                                    '15dec00 CKJ/EAC added
''                     popmessagecr "!", "Please create the Clinical Summary before proceeding"
''                     k.escd = True
''                  End If
''
''               If Not k.escd And ans$ = "Y" Then
''                     '14dec00 CKJ Allow escape out of password entry
''                     askpassword intPWvalid, UserFullName$, "Add signature"
''
''                     If intPWvalid Then                                   '14dec00 CKJ Only execute if valid pw entered
''                           FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0
''                           FillHeapStandardInfo gPRNheapID
''                           ParseRx temp$, strTempFiles()                  '20Nov06 PJC Array now passed in to hold localFile information. (#78186)
''                           'ParseRx Temp$                                 '            Replaced by above.
''                           PutTextFile patfile$, temp$, success%
''
''                           patfile$ = Mid$(patfile$, 1, Len(patfile$) - 3)  '15dec00 CKJ/EAC REVIEW: up to 100 patients may share same prefix '17Jan00 CKJ Not now. See edit above
''                           On Error Resume Next
''                           copies = UBound(Files$)
''                           On Error GoTo 0
''
''                           '14dec00 CKJ modified, see above
''                           ''Add the signature to the heap so that they don't have to manually enter it for each copy
''                           'Do
''                           '   askpassword OK, userfullname$, "Add signature"
''                           '   Temp$ = "Approved by : " & userfullname$
''                           'Loop Until OK
''                           'Heap 10, gprnHeapID, "discharger", Temp$, 0
''
''                           temp$ = "Approved by : " & UserFullName$
''                           Heap 10, gPRNheapID, "discharger", temp$, 0
''
''                           '14Dec00 CKJ Section moved from ParseRx where it created multiple events for each item
''                           If automation$ <> "" Then  'Send discharge prescrption to Teamwork Queue
''                                 '07Mar97 KR Added
''                                 eventinifile = dispdata$ & "\" & automation$
''                                 buttondef
''                                 LSet udtLabel = L                                    '14dec00 CKJ take copy before use
''                                 lngLabelPtr = Labf&                                  '   "
''                                 strFindFileCopy = findfile$                          '   "
''                                 LSet dcopy = d                                       '20Sep05 CKJ/PJC
''
''                                 For iLoop = 1 To 50
''                                    If labrf&(iLoop) > 0 Then
''                                          Labf& = labrf&(iLoop)                       '14dec00 CKJ unhappy with altering
''                                          findfile$ = ""                              '            globals, so copy first
''                                          getlabel False
''                                          If InStr("D", L.IssType) Then
''                                                '07Mar97 KR Added
''                                                If L.needednexttime <> "A" Then
''                                                      L.needednexttime = "A"
''                                                      Putlabel
''                                                   End If
''                                                FillHeapLabelInfo gPRNheapID, L, 0     '16Aug05 CKJ/TH Added
''                                                cleardrug d                            '20Sep05 CKJ/PJC Added
''                                                d.SisCode = L.SisCode                  '   "
''                                                getdrug d, 0, 0, False                 '   "
''                                                FillHeapDrugInfo gPRNheapID, d, 0      '   "
''                                                makeevent Labf&, findfile$, pid, d, k, "P", L.IssType
''                                             End If
''                                       End If       ' in range 1 to 50, or 0 if invalid
''                                 Next
''
''                                 LSet L = udtLabel                                    '14dec00 CKJ restore again
''                                 Labf& = lngLabelPtr                                  '   "
''                                 findfile$ = strFindFileCopy                          '   "
''                                 FillHeapLabelInfo gPRNheapID, L, 0                   '16Aug05 CKJ/TH Added
''                                 LSet d = dcopy                                       '20Sep05 CKJ/PJC
''                                 FillHeapDrugInfo gPRNheapID, d, 0                    '   "
''                              End If
''                           '-----
''
''                           For n = 1 To copies
''                              GetTextFile dispdata$ & "\" & Files$(n), temp$, success%
''
''                              TmpString$ = TxtD(dispdata$ & "\patmed.ini", "Discharge", "", Format$(n), 0)     '19Oct99 CFY
''                              deflines TmpString$, FileInfo$(), "|", 1, Numoflines                                  '     "
''                              If Trim$(FileInfo$(3)) = "TW" Then PrintFile$ = patfile$ & Format$(n, "000")     '     "
''
''                              'Insert the item [discharger] into the RTF
''                              AppendToRTF temp$, "", 10
''                              AppendToRTF temp$, "", 10
''                              AppendToRTF temp$, "", 10
''                              AppendToRTF temp$, "[Discharger]", 10
''                              AppendToRTF temp$, "", 10
''
''                              ParseRx temp$, strTempFiles()                                              '20Nov06 PJC  Pass in the array to ParseRx (#78186)
''                              'ParseRx Temp$                                                             '             Replaced by above
''
''                              PutTextFile patfile$ & Format$(n, "000"), temp$, success%
''
''                              parseRTF patfile$ & Format$(n, "000"), strTmpFile                          '20Nov06 PJC  Parse the file and remove any local files created in the ParseRx. (#78186)
''                              copy strTmpFile, patfile$ & Format$(n, "000")                              '              "
''                              For intCount = 1 To UBound(strTempFiles)                                   '              "
''                                 If fileexists(strTempFiles(intCount)) Then                              '              "
''                                       On Error Resume Next                                              '              "
''                                       Kill strTempFiles(intCount)                                       '              "
''                                       On Error GoTo 0                                                   '              "
''                                    End If                                                               '              "
''                              Next                                                                       '              "
''                                                                                                         '              "
''                           Next
''
''                           If automation$ <> "" Then                                                                             '28Oct99 CFY Added
''                                 eventinifile = dispdata$ & "\" & automation$                                                    '             "
''                                 buttondef                                                                                       '             "
''                                 MakeDischargeEvent pid, PrintFile$
''                              End If
''                        End If
''
''                     'essential to remove the item [discharger] when finished with
''                     Heap 12, gPRNheapID, "discharger", "", 0
''                  End If
''            End If
''
''      Case 2   'Pharmacist/check 07Mar97 ASC/KR
''
''         copies = 0                                                     '02Sep99 AE Added loop and section for new discharge form
''         Do                                                             '     "
''            If DischargeForm Then                                       '     "
''                  copies = copies + 1                                   '     "
''                  patfile$ = Mid$(patfile$, 1, Len(patfile$) - 3)       '     "
''                  patfile$ = patfile$ & Format$(copies, "000")          '     "
''               End If                                                   '     "
''
''            Screen.MousePointer = HOURGLASS
''            GetTextFile patfile$, temp$, success%
''            If temp$ = "" Then success = False
''            Screen.MousePointer = STDCURSOR
''
''            If success Then                                             '02Sep99 AE Added IF
''                  If InStr(Command$, "preview") Then
''                        'print preview
''                        Hedit 1, temp$
''                        success = False                                  '20Oct99 CFY Added
''                     Else
''                        'edit then print
''                        Hedit 1, temp$
''                        Hedit 3, temp$
''                        PutTextFile patfile$, temp$, success%
''                     End If
''               End If                                                   '02Sep99 AE Added
''         Loop Until Not success                                            '    "
''
''      Case Else
''         popmessagecr "No Access", "Password Access level does not allow work on discharge letter"
''      End Select
''
''   If preview Then Unload LstBoxFrm
''   k.escd = False

End Sub

