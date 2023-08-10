Attribute VB_Name = "RptDisp"
'                    RPTDISP.BAS
'                    -----------
'
'15Mar99 SF added for Repeat Dispensing
'31Mar99 SF modifications from testing by JL
'01Apr99 SF modifications from testing by JL
'13Apr99 SF modifications from testing by JL
'26Apr99 SF modifications from testing by JL / Nottingham Health Care
'07Jun99 SF GetRptDays:, PutRptPatient:, UpdateDBrptInfo:, CallRptDispens: now does only one open/close, moved into CallRptDispens:
'07Jun99 SF GetRptDays:, PutRptPatient:, UpdateDBrptInfo:, CallRptDispens: modified error handling
'07Jun99 SF CallRptDispens: added logging to attempt to catch patient and label mismatch
'07Jun99 SF CallRptDispens: changed variable type numDoses% to numDoses! as fraction of units where calculating incorrectly
'07Jun99 SF CallRptDispens: now asks to print a report before starting batch to get round timing out problem also asks to print previous report
'07Jun99 SF CallRptDispens: fix on the condition where l.containersize > qty calculated
'07Jun99 SF CallRptDispens: now deals with items that cannot be found in the drug file
'21Jun99 SF CallRptDispens: now only writes a report if the user as specified to have one produced
'13Aug99 SF CallRptDispens: now only prints a bag label if one or more rx labels printed
'13Aug99 SF CallRptDispens: if no rx labels printed for a patient then their status is set to "N"
'06Apr00 MMA CallRptDispens: retains status allowing stock to be booked out (event no. 42689)
'15Feb01 AW CallRptDispens: Now calls correct patient (#50448)
'04Sep01 JN MedicineSchedule: New routine to scan through repeat dispensing list and generate a medication schedule
'04Sep01 JN BuildMedicineSchedule: Builds an RTF document for page of the medicine schedule using info passed to it from MedicineSchedule
'04Sep01 JN RenumberRowElements: New function used by BuildMedicineSchedule to build up an element-driven table for medicine schedule page
'04Sep01 JN CountRptListStatus: New function to count the number of patients of a given status code on repeat dispensing list
'04Sep01 JN GetRptPatient: Added code to enable the cmdRxPrint button if status is 'D'
'04Sep01 JN RemoveColourInfo: New function to remove colour information from RTF text containing RTF formatting
'26Sep01 JN ScheduleLabelsToHeap: New routine to add RXs from a patient's PMR to the print heap (part of Medicine Schedule)
'26Sep01 JN UpdateDBrptInfo:  Added code to check for presence of records to be updated in Patid.mdb.
'                             If none are found, a single record is created to satisfy the update constraints of the SQL update query
'27Sep01 JN UpdateDBrptInfo:  Further amendment made to routine to check for existence of record to update before SQL update is run
'04Oct01 JN UpdateDBrptInfo:  Added code to routine to close the DB after an update is made, thereby forcing DB to update correctly
'04Oct01 JN MedicineSchedule: Removed NoIssue option
'04Oct01 JN MedicineSchedule: Improved Print Preview routine
'04Oct01 JN ScheduleLabelsToHeap: Removes colour information before checking for verbs in label text
'04Oct01 JN ScheduleLabelsToHeap: If label>255 chars move warnings, instructions and dr directions to 'information' column
'04Oct01 JN ScheduleLabelsToHeap: Removed extra carriage-returns being displayed to reduce size of cells in the table
'25Feb02 TH CallRptDispens:,ScheduleLabelsToHeap: Changed to flag not to reference dispens.frm  (#59050)
'15Apr02 TH ScheduleLabelsToHeap: Changes to get and use the correct instructions and warnings (those actually saved on the label and not those that   (#59508)
'           are default from the item), ensure 3 lines of warnings are available,not 2 and put the correct repeat qty on the printout, not the rxdispensed qty.
'           Also added code to handle inst/warnings that are deliberately blanked on the label when there is a default for the item and added a mod
'           to handle large label element output to overspill into the information element when there is to much in the initial cell (this should
'           parse on the nearest carriage return to the cell limit).
'15Apr02 TH MedicineSchedule: Changed commenced date to reflect week to come, not that just gone. (#59508)
'25Apr02 TH/SF ScheduleLabelsToHeap: Replaced use l.dircode explicitly as gstrModDirCode is not being set here
'                                    Get instructions not warnings when asking for instructions - oops!
'26Sep02 TH ScheduleLabelsToHeap: Altered way labels element is calculated to reflect the repeat qty (#63528)
'20Jan05 TH MedicineSchedule: Added TotalPages printable element (enh76690)
'25Jan08 CKJ Added support for MTS robot
'06Nov14 XN  RptDispGetPatient: Added setting BSA (83897)
'06Jan16 TH  RepeatDispenseItem: Ensure decrement is against label NOT the Rx (TFS 138797)
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'21Nov08 CKJ Ported to V10.0 from V8.8

' Current Repeat Dispensing status codes:
'      N = not marked for repeat dispensing (ignore the patient)
'      D = marked for repeat dispensing ready for labels to be printed
'      I = labels have been printed and ready to issue the stock

'07Mar11 TH RepeatDispenseItem: Replace case statement to remove factoring of dose for items with issue unit mls as this seems superfluous (F00109625)
'07Mar11 TH RepeatDispenseItem: Ensure the MTS batch number is sent through correctly to the output file (F00109180)
'19Jul10 XN RptDispGetPatient: F0123343 added siteID to pEpisodeSelect

'28Apr11 CKJ GetRptPatient deleted - remnant of TrueGrid
'            SetupRptDispensFrm, UpdateDBrptInfo, UpdateRptPatList deleted

'24May11 CKJ/TH CallRptDispens: Deleted. Not used.
'               GetRptDays, PutRptPatient: Deleted. Not used but required DAO2.5
'               Removed DAO 2.5 from project references
'               RptDBsetupOK, MedicineSchedule, SetRptPosition, SetRptStatus: commented out
'22Aug11 TH  RepeatDispenseItem: Update other label fields when issuing (TFS11472)
'30Jan13 XN  RefreshState: Set the patient address and post code on pidExtra, so goes on print heap (41410)
'15Feb13 XN  RepeatDispenseItem: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'02Dec15 TH  RptDispGetPatient: Use unformatted NH Number Ported from dispensing ctrl (TFS 132479)
'01Feb17 TH  ProcessBatchPatient: Fix DB RTF header and footer on requirements report (TFS 173979)
'06Feb17 TH  ProcessRepeatBatch: Number of mods to support Reprinting of main issue report
'                                1=save only data file (not full rtf), 2= use new file include in DB parsing 3=lock file and channel for use lower down(TFS 175260)
'12Apr17 TH  ProcessBatchPatient: Replaced call as medicine schedule rtf is now in the DB (TFS 180854)


Option Explicit
DefBool A-Z

'@@' temp to allow removal of IPDlist form
Global RptDispAction As Integer  '0 Label 1 Issue     replace with data from outside, using public enum

'24May11 CKJ removed
'Type RptDispRec
'   recno As String * 10
'   ward As String * 5
'   caseno As String * 10
'   forename As String * 15
'   surname As String * 20
'   interval As Integer
'   status As String * 1
'   baglabels As Integer
'   ForPacking As String * 1    '25Jan08 CKJ Added. Patient is for MTS robot packing ('R' robot, default 'L' label) Boolean in database
'End Type
''Dim rptPatList() As RptDispRec
'
'Dim m_PatCount As Long

Dim m_inifile As String
Dim RepeatDispensingAction As String
Dim m_PackerSection As String
Dim m_PackerType As String    '28Apr11 CKJ added
Dim m_blnRobotItem As Boolean 'Flag to identify if a robot run is happening
Dim m_strRequiredDate As String

'04May11 TH Added DORIS
Type BatchReportRec
   Description As String * 10
   NSVCode As String * 7
   Qty As String 'Single
End Type

Dim m_BatchReportList() As String 'As BatchReportRec

'New variables for DORIS/JVM
Dim blnJVMBreakfast As Boolean
Dim blnJVMLunch As Boolean
Dim blnJVMTea As Boolean
Dim blnJVMNight As Boolean
Dim intJVMStartSlot As Integer
Dim intJVMTotalSlots As Integer
Dim m_RepeatDispensingBatchDescription As String
Dim m_strJVMStartDate As String

Dim m_intBagLabels As Integer '30May11 TH Added

'10Apr12 TH New switches and storage for meds management integration work.
Dim m_blnMedsManagement As Boolean
'Dim m_ComplianceAidID As Integer
Dim m_str_eMMAdditionalInfo As String
Dim m_bln_eMMCompliance As Boolean
Dim m_bln_eMMPriority As Boolean
Dim m_lng_eMMComplianceTypeID As Long
Dim m_str_eMMComplianceStartDate As String
Dim m_dte_eMMRequiredDate As Date
Dim m_lng_eMMDeliveryTypeID As Long
Dim m_str_eMMBatchDescription As String
Dim m_lng_eMMLocationID As Long
Dim m_lng_eMMNumberofDays As Long

Dim m_blnJVADTPS As Boolean
Dim m_eMMSupplyDescription As String


'

'24May11 CKJ Removed - see TH comments inside from 23Mar11
'Sub MedicineSchedule(ByVal i_strLayout As String, ByVal i_intCopies As Integer, ByVal i_intPreview As Integer, io_strErrMsg As String)
''**********************************************************************************************
''* Purpose: To obtain the data required to print a medicine schedule, create the
''*          schedule by calling BuildMedicineSchedule, populate the resultant layout
''*          with the data obtained and send the output to printer and/or screen.
''*
''* Inputs:  i_strLayout <string>   - name of layout file used as a basis for the printed output
''*          i_intCopies <integer>  - number of copies required
''*          i_intPreview <integer> - allows previews
''*          io_strErrMsg <string>  - allows for passing in/out of Error Messages
''*
''* Outputs: io_strErrMsg     "         "     "     "       "    "    "      "
''**********************************************************************************************
''04Sep01 JN Written
''27Sep01 JN Amended errorhandling
''04Oct01 JN Removed NoIssue option
''04Oct01 JN Improved Print Preview routine
''15Apr02 TH Changed commenced date to reflect week to come, not that just gone.
''20Jan05 TH Added TotalPages printable element (enh76690)
'
''15Mar11 TH Re factored to use in new ocx
''23Mar11 TH This sub now redundant. Basically the medicine schedule is called from RepeatBatch Patient.
''           Anythin9 require from this su can now be found there.
'
''Now we will call this routine recursively for each patient so we wont need to loop
'
'
'
'Dim intInstrs As Integer
'Dim intWarnings As Integer
'Dim intItemsPerPage As Integer
'Dim strOutLayout As String
'Dim lngMaxPMRPtr As Long
'Dim lngMaxLblPtr As Long
'Dim lngPMRPtr As Long
'Dim lngPatRecNo As Long
'Dim lngPatLoop As Long
'Dim intLabelCount As Integer
'Dim lngLabf As Long
'Dim lngFound As Long
'Dim intSuccess As Integer
'Dim intAnyOutput As Integer
'Dim strWkComm As String
'Dim dteWC As DateAndTime
'Dim intLabelsPrinted As Integer
'Dim intFiles As Integer
'Dim intRTF As Integer
'Dim strRTF() As String
'Dim strIssueType As String
'Dim intTypes As Integer
'Dim strParsedFile As String   '04Oct01 JN Added
'
'Dim udtPID As patidtype
'Dim udtSup As supplierstruct
'Dim udtLabel As WLabel
'Dim udtDrug As DrugParameters
'
'Const cstrTypeList = "IODLWC??S??"  '26Sep01 JN Amended
'
'   On Error GoTo ErrorHandler       '26Sep01 JN Added
'
'   'Get .INI file settings
'   intInstrs = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicineSchedule", "N", "Instructions", 0))
'   intWarnings = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicineSchedule", "N", "Warnings", 0))
'   intItemsPerPage = Val(TxtD$(dispdata$ & "\PATMED.INI", "MedicineSchedule", "10", "ItemsPerPage", 0))
'
'
'
'   'get Week Commencing date based on Today's date
'   today dteWC
'   'dteWC.mint = dteWC.mint - ((DayOfWeek(dteWC) - 1) * 1440)   '1140 mins in a day!     '15Apr02 TH Added to ensure correct date
'   dteWC.mint = dteWC.mint - ((DayOfWeek(dteWC) - 1) * 1440) + 10080                     '     "
'   minstodate dteWC
'   DateToString dteWC, strWkComm
'
'   'if the path supplied is relative, add the dispdata path to it
'   If InStr(i_strLayout, ":") = 0 Then
'      If Left$(i_strLayout, 1) <> "\" Then
'         i_strLayout = dispdata$ & "\" & i_strLayout
'      Else
'         i_strLayout = dispdata$ & i_strLayout
'      End If
'   End If
'
'   'ensure that the In-Layout supplied exists      '26Sep01 JN made use of improved error reporting
'   If Not fileexists(i_strLayout) Then
'      io_strErrMsg = io_strErrMsg & crlf & "The RTF layout path supplied '" & i_strLayout & "' doesn't exist." & crlf & "Schedule print failed."
'      GoTo Cleanup
'   End If
'
'   'take a copy of the original label, PID and Labf values before this routine was run
'   udtLabel = L
'   udtPID = pid
'   lngLabf = Labf&
'   '{note: copies here are superfluous since this module exits to the main menu. Copies of findfile, pidextra, pidepisode etc are not necessary}
'
'
'   clearsup udtSup
'   getsupplier pid.ward, 0, lngFound, udtSup
'   FillHeapSupplierInfo gPRNheapID, udtSup, intSuccess                     '27Sep01 JN Used standard heap items instead
'
'   If lngFound > 0 And InStr(strIssueType, pid.status) > 0 And UCase$(rptPatList(lngPatLoop).status) = "D" Then      '21Sep01 JN Changed to check for patient status
'
'
'
'         FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, intSuccess   '27Sep01 JN Used standard heap items
'         Heap 10, gPRNheapID, "wkcommdate", strWkComm, 0
'
'         '26Sep01 JN Moved code originally here to a separate routine for clarity
'         '           ScheduleLabelsToHeap works through a patient's PMR, adding
'         '           RXs to be included on the medicine schedule onto the print heap
'         '''''ScheduleLabelsToHeap lngPMRPtr, lngMaxLblPtr, pid.recno, intInstrs, intWarnings, io_strErrMsg, intLabelCount
'
'         'if any labels matching the required criteria were attained, generate a layout for these
'         If intLabelCount > 0 Then
'               'create an RTF document based on the layout supplied
'               strOutLayout = ""    '20Sep01 JN just for safety - hasn't been used yet
'               BuildMedicineSchedule intLabelCount, intItemsPerPage, i_strLayout, strOutLayout
'
'               'retrieve the files created
'               intFiles = Val(Left$(strOutLayout, InStr(strOutLayout, "|") - 1))
'               ReDim strRTF(1 To intFiles)
'               deflines Mid$(strOutLayout, InStr(strOutLayout, "|") + 1), strRTF(), "|", 1, intFiles
'
'               'print the RTFs
'               For intRTF = 1 To intFiles
'
'                  'add the page number to the heap
'                  Heap 10, gPRNheapID, "page", Format$(intRTF), 0
'                  Heap 10, gPRNheapID, "TotalPages", "Page " & Format$(intRTF) & " of " & Format$(intFiles), 0    '20Jan05 TH Added (enh76690)
'
'                  'parse the document ready for printing
'                  strParsedFile = ""                           '04Oct01 JN Added this section
'                  parseRTF strRTF(intRTF), strParsedFile
'                  If Len(strParsedFile) > 0 Then
'                        Kill strRTF(intRTF)
'                        strRTF(intRTF) = strParsedFile         '04Oct01 JN Replace the original file with the parsed version
'                     End If
'
'                  'if previews have been requested, open HighEdit for editing    '04Oct01 JN Added this section
'                  If i_intPreview Then
'                        Hedit 11, strRTF(intRTF)
'                     End If
'
'                  'parse the document again, just in case parseable amendments have been made in preview mode   '04Oct01 JN Added this section
'                  ParseThenPrint "MEDSCHED", strRTF(intRTF), i_intCopies, intSuccess
'
'                  ''parse the RTF output generated                                           '04Oct01 JN Removed - all dealt with above
'                  'If i_intPreview Then                                                      '   "     "    "    "  "    "     "    "
'                        'ParseThenPrint "SCREEN", strRTF(intRTF), i_intCopies, intSuccess    '   "     "    "    "  "    "     "    "
'                     'Else                                                                   '   "     "    "    "  "    "     "    "
'                        'ParseThenPrint "", strRTF(intRTF), i_intCopies, intSuccess          '   "     "    "    "  "    "     "    "
'                     'End If                                                                 '   "     "    "    "  "    "     "    "
'
'                  'kill the output file
'                  Kill strRTF(intRTF)
'               Next
'
'                                    'erase the RTF Array
'                                    Erase strRTF
'
'                                    'If Not intNoIssue Then                   '04Oct01 JN Removed
'                                          ''change the patient status to 'I'
'                                          'rptPatList(lngPatLoop).status = "I"
'                                       'End If
'
'                                    'destroy and reinitialise the print heap
'                                    'Heap 2, gPRNHeapID, "", "", 0      '20Sep01 JN Replaced in favour of standard procedure below
'                                    'Heap 1, gPRNHeapID, "", "", 0      '   "     "     "     "    "    "     "        "       "
'                                    SetupPRNHeap True, intSuccess
'
'                                    'set intAnyOutput to TRUE since at least one patient's
'                                    'details have been printed...
'                                    intAnyOutput = True
'                                 End If
'                           End If
'
'
'
'
'        ' Next lngPatLoop
'
'   'replace the original settings of label and pid structure
'   Labf& = lngLabf
'   L = udtLabel
'   pid = udtPID
'
'   'if no patient's details were printed, report this to the user.
'   If Not intAnyOutput Then
'         popmessagecr "!", "Nothing to print as a Medicine Schedule."
'      Else
'         popmessagecr "!", "Finished printing Schedule..."
'      End If
'
'Cleanup:
'
'   On Error GoTo 0
'
'   Exit Sub
'
'ErrorHandler:
'
'   io_strErrMsg = io_strErrMsg & Error$(Err)
'
'   'GoTo CleanUp
'   Resume Cleanup    '27Sep01 JN Amended in favour of 'Resume'
'
'End Sub





Function RemoveColourInfo(ByVal i_strString As String, ByVal i_intNumOfLines As Integer) As String
'**************************************************************************************************
'* Purpose: To remove the colour information within a string that contains CHR$(30) and x!
'*          type colour information
'*
'* Inputs:  i_strString     <string>   text to have colour information removed
'*          i_intNumOfLines <integer>  number of lines to parse
'*
'* Outputs: <string> with colour information removed
'**************************************************************************************************
'04Sep01 JN Written

Dim strParseLine() As String
Dim intParse As Integer
Dim strOut As String

   If Len(i_strString) > 0 Then
         ReDim strParseLine(1 To i_intNumOfLines)
      
         'split up the text into separate lines
         deflines i_strString, strParseLine(), Chr$(30), 1, i_intNumOfLines
      
         'remove the colour information
         For intParse = 1 To i_intNumOfLines
            If Mid$(strParseLine(intParse), 2, 1) = "!" Then
                  strParseLine(intParse) = Mid$(strParseLine(intParse), 3)
               End If
         Next
      
         'put the warning back together
         strOut = "" '04Oct01 JN Added
         For intParse = 1 To i_intNumOfLines
            If Len(strParseLine(intParse)) > 0 Then
                  strOut = strOut & strParseLine(intParse) & crlf
               End If
         Next
      
         'destroy the array afterwards
         Erase strParseLine
      
         'pass the result out of the function
         RemoveColourInfo = strOut

      Else
         RemoveColourInfo = ""
      End If

End Function

Private Function RenumberRowElements(ByVal i_strLine As String, ByVal i_intElementNo As Integer) As String
'**************************************************************************************************
'* Purpose: To replace the numbered elements in i_strElementLine with re-numbered elements
'*
'* Inputs:  i_strLine <string> contains text and numbered elements
'*          i_intElementNo <integer> number to replace within element
'*
'* Outputs: <string> containing text and renumbered elements
'**************************************************************************************************
'04Sep01 JN Written
'20Sep01 JN Heavily amended

   'replace all instances of '*]' with '<element number>]'

   replace i_strLine, "*]", Format$(i_intElementNo) & "]", -1  '20Sep01 JN Amended to use a simple replace

   RenumberRowElements = i_strLine

End Function

'24May11 CKJ not used but required DAO 2.5
'Function RptDBsetupOK() As Integer
''07Jun99 SF added to make sure all relevant new fields where added for repeat dispensing
'
'Dim tbl As table
'Dim X%, i%
'
'   On Error GoTo RptSetupOkErr
'
'   RptDBsetupOK = True
'   X% = 0
''@@'
'''   Set tbl = PIDdb.OpenTable("patid")
'''   For i% = 0 To (tbl.Fields.Count - 1)
'''      Select Case Trim$(LCase$(tbl.Fields(i%).name))
'''         Case "repeatinterval", "repeatstatus", "numberofbaglabels", "forpacking"
'''            X% = X% + 1
'''      End Select
'''   Next
'
'   tbl.Close: Set tbl = Nothing
'
'   If X% < 4 Then                        '25Jan08 CKJ was <3
'         RptDBsetupOK = False
'         'popmessagecr ".Repeat Dispensing", "Error, patient database not setup correctly." & cr & "Cannot continue with repeat dispensing."                                                                               '25Jan08 CKJ
'         popmessagecr ".Repeat Dispensing", "Patient database has not been set up correctly" & cr & cr & "Please ensure that the new item 'ForPacking' has been added" & cr & "as type Boolean to table PatID in database PatID" & cr & cr & "Unable to continue with repeat dispensing"      '25Jan08 CKJ
'      End If
'
'RptSetupOkExit:
'   On Error Resume Next
'   Exit Function
'
'RptSetupOkErr:
'   RptDBsetupOK = False
'   popmessagecr ".Repeat Dispensing", "An error has occurred using database PatID: " & cr & cr & Error$ & cr & "Error number: " & Err
'Resume RptSetupOkExit
'
'End Function

Sub ScheduleLabelsToHeap(ByVal PatientXML As MSXML2.IXMLDOMElement, ByVal i_strRecno As String, ByVal i_intInstrs As Integer, ByVal i_intWarnings As Integer, io_strErrMsg As String, o_intLabelCount As Integer, ByVal intSupplyLength As Integer, ByVal intSupplyPatternDays As Integer, ByVal intSupplyPatternSplitDays As Integer)
'26Sep01 JN Moved this code to a separate routine for clarity
'27Sep01 JN Changed errorhandling
'04Oct01 JN Removes colour information before checking for verbs in label text
'04Oct01 JN If label>255 chars move warnings, instructions and dr directions to 'information' column
'04Oct01 JN Removed extra carriage-returns being displayed to reduce size of cells in the table
'25Feb02 TH Changed to flag not to reference dispens.frm (#59050)
'15Apr02 TH Changes to get and use the correct instructions and warnings (those actually saved on the label and not those that are default from   (#59508)
'           the item), ensure 3 lines of warnings are available,not 2 and put the correct repeat qty on the printout, not the rxdispensed qty.
'           Also added code to handle inst/warnings that are deliberately blanked on the label when there is a default for the item and added a mod
'           to handle large label element output to overspill into the information element when there is to much in the initial cell (this should
'           parse on the nearest carriage return to the cell limit).
'25Apr02 TH/SF Replaced use l.dircode explicitly as gstrModDirCode is not being set here
'25Apr02 TH/SF Get instructions not warnings when asking for instructions - oops!
'26Sep02 TH Altered way labels element is calculated to reflect the repeat qty (#63528)

'15Mar11 TH re-Factored to use in v9/10
'07Jun11 TH  Exclude not inuse dispensing lines (F0119656)

Dim udtDrug As DrugParameters

'Dim intDrugNum As Integer              '01Jun02 All/CKJ removed as not used
'Dim intFoundDrug As integer            '01Jun02 All/CKJ removed as not used
Dim intInstruction As Integer
Dim intLabel As Integer
Dim intLabelDirs As Integer
Dim intLabelLine As Integer
Dim intLabelsPrinted As Integer
Dim strInstrs As String
Dim strLabel As String
Dim strLabelText() As String
Dim strWarning As String
Dim strInformation As String           '04Oct01 JN Added
Dim intTrackpos As Integer, intCurpos As Integer '15Apr02 TH Added  (#59508)
Dim RepeatDispensingDispensingID As Long
Dim RepeatDispensingPrescriptionID As Long
Dim sglRepeatDispensingQuantity As Single
Dim XMLelement As MSXML2.IXMLDOMElement
Dim sglDosesperissueunit As Single
Dim sglNumDoses As Single
Dim intloop As Integer
Dim sqlTotQty As Single
Dim UnfactoredTotQty!
Dim intLabels As Integer
Dim sglTotalSupplyQty As Single
Dim sglQtyCache As Single
Dim sglSupplyQty As Single
Dim intSplitCount As Integer
Dim rsRequest As ADODB.Recordset
Dim strParams As String
Dim strPrescriptionInfo As String
Dim strPat As String '23May11 TH Added (F)
Dim strErr As String
Dim ErrNo As Long


On Error GoTo ScheduleErrorHandler

   'reset the label counter
   o_intLabelCount = 0
   
   'go through each label for that patient
   'For intLabel = 1 To 50
   For Each XMLelement In PatientXML.selectNodes("Dispensing")
   
      If LCase(XMLelement.getAttribute("InUse")) = "true" Or XMLelement.getAttribute("InUse") = "1" Then '07Jun11 TH (F0119656)
   
         'get the label
         RepeatDispensingDispensingID = XMLelement.getAttribute("RequestID")
         If RepeatDispensingDispensingID > 0 Then                'potentially valid dispensing
            RepeatDispensingPrescriptionID = XMLelement.getAttribute("PrescriptionID")
            sglRepeatDispensingQuantity = XMLelement.getAttribute("RepeatDispensingQuantity")
            
            'Put Prescription Info on heap
            strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RepeatDispensingPrescriptionID)
            Set rsRequest = gTransport.ExecuteSelectSP(g_SessionID, "pRequestbyRequestID", strParams)
            strPrescriptionInfo = ""
            If Not rsRequest.EOF Then
               rsRequest.MoveFirst
               strPrescriptionInfo = RtrimGetField(rsRequest!Description)
            End If
            rsRequest.Close
            Set rsRequest = Nothing
            
            Labf& = RepeatDispensingDispensingID                         'requestid for dispensing which is currently in use
            getlabel Labf&, L, False
            
            'add this label to the schedule...
            strLabel = Trim$(L.text)
            'if drdirection has been set, check for anything
            'beneath the drug description on the label which
            'would suggest there are directions stored on the label
            'This will only work provided there are automatically-entered directions on the label
            'or for manually entered directions that conform to the recognised standard
            intLabelDirs = False    '04Oct01 JN Moved setting of intLabelDirs out of IF statement below
            If Len(L.drdirection) > 0 Then
               ReDim strLabelText(5)
               deflines L.text, strLabelText(), Chr$(30), 1, 5
               'intLabelDirs = False      '04Oct01 JN Moved setting of intLabelDirs up - now outside IF statement
               ''21Mar11 TH Removed block below. Spec now says get the label, regardless of whether there are directions on it or not.
               ''For intLabelLine = 2 To 5
               ''   If Not intLabelDirs = True Then
               ''      For intInstruction = 1 To 9
               ''         'If InStr(UCase$(strLabelText(intLabelLine)), Choose(intInstruction, "TAKE ", "GIVE ", "INHALE ", "SUCK ", "APPLY ", "INSERT ", "PUT ", "SPRAY ", "IRRIGATE ")) = 1 Then   '04Oct01 JN Commented Out
               ''          If InStr(UCase$(RemoveColourInfo(strLabelText(intLabelLine), 1)), Choose(intInstruction, "TAKE ", "GIVE ", "INHALE ", "SUCK ", "APPLY ", "INSERT ", "PUT ", "SPRAY ", "IRRIGATE ")) = 1 Then  '04Oct01 JN Remove colour info before checking for Verbs
               ''            intLabelDirs = True
               ''            Exit For    '04Oct01 JN Added to speed up routine
               ''         End If
               ''      Next intInstruction
               ''   Else
               ''      Exit For             '04Oct01 JN Added to speed up routine
               ''   End If
               ''Next intLabelLine
         
               'if no directions are held on the label
               'use l.drdirection instead
               '04Oct01 JN Moved an enhanced version of this code further down
               '           to check for label size before adding to the target cell.
               '           HighEdit4 has a maximum of 256 chars allowed in a cell - new routine checks for this.
               'If Not intLabelDirs Then
                     'strLabel = strLabel & CRLF & l.drdirection
                  'Else                                                          '04Oct01 JN Removed
                     'strLabel = strLabel & CRLF & l.Text    '20Sep01 JN Added   '04Oct01 JN Removed
                  'End If
      
               Erase strLabelText
            End If
         
            strLabel = RemoveColourInfo(strLabel, 20)
            plingparse strLabel, "!"
            
            'get the drug details
            udtDrug.SisCode = L.SisCode
            'getdrug udtDrug, intDrugNum, intFoundDrug, 0    '01Jun02 All/CKJ intDrugNum & intFoundDrug not used
            getdrug udtDrug, 0, 0, False                     '01Jun02 All/CKJ therefore removed
         
            'get instructions if required
            '15Apr02 TH Added Block   (#59508)
            If i_intWarnings Then
               'If ((Trim$(Left$(gstrModDirCode, 6)) <> "") Or InStr(Left$(gstrModDirCode, 6), Chr(161)) > 0) Then  '25Apr02 TH/SF Replaced use l.dircode explicitly as
               If ((Trim$(Left$(L.dircode, 6)) <> "") Or InStr(Left$(L.dircode, 6), Chr(161)) > 0) Then             '   "          gstrModDirCode is not being set here
                  GetWarCode Trim$(Left$(L.dircode, 6)), strWarning
                  strWarning = Trim$(RemoveColourInfo(strWarning, 3))
               Else
                  If InStr(plvl$("Warning2"), L.IssType) Then
                        GetWarCode udtDrug.warcode2, strWarning
                     Else
                        GetWarCode udtDrug.warcode, strWarning
                     End If
                  strWarning = Trim$(RemoveColourInfo(strWarning, 3))
               End If
            Else
                strWarning = ""
            End If
            If i_intInstrs Then
               'If ((Trim$(Right$(gstrModDirCode, 6)) <> "") Or InStr(Right$(gstrModDirCode, 6), Chr(161)) > 0) Then   '25Apr02 TH/SF Replaced use l.dircode explicitly as
               If ((Trim$(Right$(L.dircode, 6)) <> "") Or InStr(Right$(L.dircode, 6), Chr(161)) > 0) Then              '   "          gstrModDirCode is not being set here
                  GetInsCode Trim$(Right$(L.dircode, 6)), strInstrs
                  strInstrs = Trim$(RemoveColourInfo(strInstrs, 2))
               Else
                  GetInsCode udtDrug.inscode, strInstrs                  '    "
                  strInstrs = Trim$(RemoveColourInfo(strInstrs, 2))      '    "
               End If
            Else
               strInstrs = ""
            End If
      
            '15Apr02 TH End of Block  (#59508)
            If i_intInstrs Then
               GetInsCode udtDrug.inscode, strInstrs
               strInstrs = Trim$(RemoveColourInfo(strInstrs, 2))
            Else
               strInstrs = ""
            End If
                              
            'get warnings if required
            If i_intWarnings Then
               If InStr(plvl$("Warning2"), L.IssType) Then
                  GetWarCode udtDrug.warcode2, strWarning
               Else
                  GetWarCode udtDrug.warcode, strWarning
               End If
               strWarning = Trim$(RemoveColourInfo(strWarning, 2))
            Else
               strWarning = ""
            End If
         
                              
            'add these to the label if required
            If i_intWarnings And Len(strWarning) > 0 Then
               strLabel = strLabel & crlf & strWarning
            End If
            If i_intInstrs And Len(strInstrs) > 0 Then
               'strLabel = strLabel & CRLF & strInstrs
               strLabel = strInstrs & crlf & strLabel    '04Oct01 JN Amended so instructions appear at top
            End If
         
            'add the Rx ID and batchnumber to the label if required
            If InStr(plvl$("PrintBatchNumber"), L.IssType) Then
               'strLabel = strLabel & " \par Rx ID: " & Format$(l.prescriptionid, "0")    '20Sep01 JN Amended to use [CR] in order to get parsed by ParseCTRLChars
               strLabel = strLabel & "[CR]Rx ID: " & Format$(L.PrescriptionID)
            End If
            If InStr(plvl$("PrintRxNumOnLabel"), L.IssType) And L.batchnumber > 0 Then
               'strLabel = strLabel & " \par Batchnumber: " & Format$(l.batchnumber, "0") '20Sep01 JN Amended to use [CR] in order to get parsed by ParseCTRLChars
               strLabel = strLabel & "[CR]Batchnumber: " & Format$(L.batchnumber)
            End If
      
            'tidy-up the label text
            If Left$(strLabel, 2) = crlf Then
               strLabel = Mid$(strLabel, 3)
            End If
      
            'add drdirections to strLabel if neccessary
            If Not intLabelDirs Then
               '04Oct01 JN Added enhancement to move text to information section when target cell's length exceeds 256 chars
               If Len(strLabel) + Len(Trim$(L.drdirection)) < 256 Then
                  ''strLabel = strLabel & crlf & L.drdirection  '16Mar11 TH Removed
               Else
                  ''strInformation = strInformation & L.drdirection '16Mar11 TH Removed
               End If
            End If
      
            replace strLabel, crlf, "[CR]", True
            replace strLabel, "[CR] ", "[CR]", True
            replace strLabel, "[CR][CR]", "[CR]", True
      
            If Len(strLabel) > 256 Then                                                            '15Apr02 TH Added to allow overspill at convenient juncture  (#59508)
               intTrackpos = 0                                                                  '    "
               intCurpos = 1                                                                    '    "
               Do While intCurpos <> 0 And intCurpos < 256                                      '    "
                  intTrackpos = intCurpos                                                       '    "
                  intCurpos = InStr(intCurpos + 1, strLabel, "[CR]")                            '    "
               Loop                                                                             '    "
               strInformation = Mid$(strLabel, intTrackpos + 4) & "[CR]" & strInformation       '    "
               strLabel = Left(strLabel, intTrackpos - 1)                                       '    "
            End If                                                                              '    "
            
            'add this data to the printheap
            o_intLabelCount = o_intLabelCount + 1
            Heap 10, gPRNheapID, "labeldesc" & Format$(o_intLabelCount), strLabel, 0
            strLabel = L.text
            replace strLabel, Chr(30), " ", True
            Heap 10, gPRNheapID, "DispensingInfo" & Format$(o_intLabelCount), strLabel, 0
            Heap 10, gPRNheapID, "PrescriptionInfo" & Format$(o_intLabelCount), strPrescriptionInfo, 0
            
            Heap 10, gPRNheapID, "infodesc" & Format$(o_intLabelCount), strInformation, 0    '04Oct01 JN Added "overspill" information to print heap
            If Val(XMLelement.getAttribute("RepeatDispensingQuantity")) = 0 Then
               Heap 10, gPRNheapID, "qty" & Format$(o_intLabelCount), "", 0
            Else
               Heap 10, gPRNheapID, "qty" & Format$(o_intLabelCount), XMLelement.getAttribute("RepeatDispensingQuantity") & " " & Trim$(udtDrug.PrintformV), 0     '    "
            End If
            
            strInformation = "" '15Apr02 TH Reset for next pass  (#59508)
      
            'calculate how many labels would need to be printed for this issue  -- THIS NEEDS REWORKING
            'sglDosesperissueunit = d.dosesperissueunit
            sglDosesperissueunit = udtDrug.dosesperissueunit
            If sglDosesperissueunit = 0 Then sglDosesperissueunit = 1
            sglNumDoses = 0
            For intloop = 1 To 6
               If L.dose(intloop) > 0 Then
                  sglNumDoses = sglNumDoses + L.dose(intloop) '07Mar11 TH Replace above case statement (F00109625)
               End If
            Next
            If sglNumDoses = 0 Then sglNumDoses = 1
   
            If sglRepeatDispensingQuantity > 0 Then
               'here the whole qty is on one label
               sqlTotQty = sglRepeatDispensingQuantity
               UnfactoredTotQty! = sglRepeatDispensingQuantity
               intLabels = 1
               Qty! = sqlTotQty
               sglTotalSupplyQty = sqlTotQty
            ElseIf intSupplyLength > 0 Then
               'OK the supply length will now dictate the quantity and number of labels requried
               If intSupplyPatternDays = 0 Then intSupplyPatternDays = intSupplyLength  '30Oct09 TH
               sqlTotQty = sglNumDoses * intSupplyLength
               sglTotalSupplyQty = sglNumDoses * intSupplyLength  '30Oct09 TH Added
               UnfactoredTotQty! = sqlTotQty
               intLabels = (sqlTotQty / (sglNumDoses * intSupplyPatternDays)) 'sglRepeatDispensingQuantity
               If sqlTotQty < sglNumDoses Then   '07Jun99 SF
                  intLabels = 1
                  Qty! = sglRepeatDispensingQuantity
                  sqlTotQty = sglRepeatDispensingQuantity     '07Jun99 SF added
               Else
                  If sqlTotQty Mod (sglNumDoses * intSupplyPatternDays) > 0 Then intLabels = intLabels + 1
                  Qty! = (sglNumDoses * intSupplyPatternDays)
               End If
            End If
            
            sglQtyCache = Qty!
            sglSupplyQty = sglTotalSupplyQty
            Qty! = sglQtyCache
            intSplitCount = 1
            Do While sglSupplyQty > 0
               'Do day split here 'but only if no qty override
               If sglRepeatDispensingQuantity = 0 Then
                  If intSupplyPatternSplitDays > 0 Then
                     If intSplitCount Mod 2 = 1 Then
                        Qty! = sglNumDoses * intSupplyPatternSplitDays
                     Else
                        Qty! = sglNumDoses * (7 - intSupplyPatternSplitDays)
                     End If
                  End If
               End If
               intSplitCount = intSplitCount + 1
               If Qty! > sglSupplyQty Then Qty! = sglSupplyQty '19Jul09 TH moved from above as this needs doing after any split (on second + pass)
               If TrueFalse(TxtD(dispdata$ & "\RptDisp.ini", "", "Y", "RepeatDispensingPackLimitforLabels", 0)) Then
                  If Qty! > udtDrug.convfact Then
                     Qty! = udtDrug.convfact
                     intSplitCount = intSplitCount - 1
                  End If
               End If
               sqlTotQty = sqlTotQty - Qty!
               sglSupplyQty = sglSupplyQty - Qty!
               intLabelsPrinted = intLabelsPrinted + 1
            Loop
                  
            '22Mar11 TH replaced this with block above
            'If Val(udtDrug.convfact) > 0 Then            '20Sep01 JN Amended this to check for convfact=0 first
            '   intLabelsPrinted = Int(sglRepeatDispensingQuantity / Val(udtDrug.convfact))    '     "
            '   If sglRepeatDispensingQuantity Mod Val(udtDrug.convfact) <> 0 Then        '     "
            '      intLabelsPrinted = intLabelsPrinted + 1
            '   End If
            'Else
            '   intLabelsPrinted = 0    '20Sep01 JN Set to labels printed to 0 here, since if convfact is 0 there's nothing to print anyway
            'End If
            
            Heap 10, gPRNheapID, "labels" & Format$(o_intLabelCount), Format$(intLabelsPrinted), 0
            
            '05Sep11 TH Added (TFS 13171)
            If L.SplitDose Then
               Heap 10, gPRNheapID, "DispensedAs" & Format$(o_intLabelCount), TxtD(dispdata$ & "\RptDisp.ini", "MedicineSchedule", "Part Dispensed as :", "PartDispensedAs", 0), 0
            Else
               Heap 10, gPRNheapID, "DispensedAs" & Format$(o_intLabelCount), TxtD(dispdata$ & "\RptDisp.ini", "MedicineSchedule", "Dispensed as :", "DispensedAs", 0), 0
            End If
            
            intLabelsPrinted = 0
         End If
      'else
      'Dispensing is out of use - place any code required here, at present no action, just skip
      End If
   Next

ScheduleCleanUp:

   On Error GoTo 0

   Exit Sub

ScheduleErrorHandler:
   strErr = Err.Description
   ErrNo = Err.Number
   io_strErrMsg = io_strErrMsg & strErr
   Heap 11, gPRNheapID, "pForenameSurname", strPat, 0
   popmessagecr "", "An error has occured whilst collating information for the Medicine Schedule print." & crlf & _
   "This may affect the final print." & crlf & crlf & _
   " Patient : " & strPat & crlf & _
   " Prescription : " & strPrescriptionInfo & crlf & _
   " Error : " & strErr & crlf & _
   " Error Number : " & CStr(strErr)

Resume ScheduleCleanUp     '27Sep01 JN Amended in favour of 'Resume'

End Sub

Sub SetNumberOfRptLabels()
'15Mar99 SF added for repeat dispensing to set the number of labels to be printed for each issue
'31Mar99 SF moved from PATMED.BAS and rewritten

Dim issuePerLabel$

   If L.IssType <> "C" And L.IssType <> "P" And InStr(UCase$(TxtD$(dispdata$ & "\PATMED.INI", "RepeatDispensing", "", "LabelTypes", 0)), L.IssType) > 0 Then
'@@'         issuePerLabel$ = Trim$(Dispens.TxtQtyPrinted.Text)
         k.nums = True
         InputWin "Repeat Dispensing", "Enter the quantity per label", issuePerLabel$, k
         If Not k.escd Then
               L.containersize = Val(issuePerLabel)
'@@'               Dispens.TxtQtyPrinted = L.containersize
            End If
      End If

End Sub

'24May11 CKJ removed
'Function SetRptPosition&(rptPatCount&)
'
'   If rptPatCount& = -1 Then
'         ReDim rptPatList(1000)
'         m_PatCount = 0
'      Else
'         m_PatCount = m_PatCount + 1
'      End If
'   SetRptPosition& = m_PatCount
'
'End Function
'
'Sub SetRptStatus(status$)
'' set all patients repeat status to that in status$ parameter
'
'Dim X&, toggle%
'
'   toggle% = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "RepeatDispensing", "Y", "ToggleStatusI", 0))
'   For X& = 1 To m_PatCount
'      If toggle% Then
'            rptPatList(X&).status = status$
'         ElseIf rptPatList(X&).status <> "I" Then
'            rptPatList(X&).status = status$
'         End If
'   Next
''@@'   frmRptDisp.PatientList.Refresh
'
'End Sub


Sub BuildMedicineSchedule(ByVal i_intPMRItems As Integer, ByVal i_intMaxTableRows As Integer, ByVal i_strLayout As String, o_strNewTemplate As String)
'*******************************************************************************************
'* Purpose: Routine to insert table rows with associated data elements from a basic
'*          .RTF template file containing a simple table comprising of table header and first row.
'*          Sufficient pages are generated to accommodate the dispensing requirement
'*          for the specified number of items. The finished article contains sets of
'*          numbered elements for each row.
'*
'* Inputs:  i_intPMRItems - number of items from PMR to be added to .RTF
'*          i_intMaxTableRows - number of rows allowed in a table - any extra will be on another page
'*          i_strLayout - name of layout file to be used as a template
'*
'* Outputs: o_strNewTemplate - name of templates to be parsed in normal way
'*                             To avoid problems with RTF Parsing, each page generated
'*                             by this routine is in a separate file. The output is encoded as
'*                             number of files|filename1|filename2|filename3, etc
'*******************************************************************************************
'04Sep01 JN Written

Dim intChan As Integer
Dim intPages As Integer
Dim intRemainder As Integer
Dim intPageLoop As Integer
Dim intCompleted As Integer
Dim strRowDef As String
Dim strBody As String
Dim lngPos As Long
Dim lngRowStart As Long
Dim lngRowLength As Long
Dim lngInsertPoint As Long
Dim intInsert As Integer
Dim intInsertLimit As Integer
Dim intFileCount As Integer
Dim strOut As String
Dim intSuccess As Integer

   'calculate how many pages will be needed
   intPages = Int(i_intPMRItems / i_intMaxTableRows)
   intRemainder = i_intPMRItems Mod i_intMaxTableRows
   If intRemainder > 0 Then 'i.e. there is a remainder
         intPages = intPages + 1
      End If

   'load the layout as the body of the document
   'GetTextFile i_strLayout, strBody, intSuccess    '20Sep01 JN Changed in favour of core function
   GetRTFTextFromDB i_strLayout, strBody, intSuccess  '06Dec16 TH Replaced (TFS 157969)
   
   'strBody = GetFileAsString(i_strLayout)         '20Sep01 JN Commented out

   '20Sep01 JN Check for size of file exceeding 32K or other problems occurring during load
   If intSuccess = False Then
      'there has been an error
      popmessagecr "!n!i" & "Error", "Unable to read file '" & i_strLayout & "', cannot proceed further. " & crlf & "Please notify your System Administrator."
      Exit Sub
   End If
   '20Sep01 JN ----------------

   'look for 2nd instance of '\trowd' in body to find 1st data row of table
   intCompleted = 0
   lngPos = 1
   Do Until intCompleted = 2 Or lngPos = 0
      lngPos = InStr(lngPos, strBody, "\trowd")
      If lngPos > 1 Then
         intCompleted = intCompleted + 1
         lngPos = lngPos + 1  'move point just beyond start of '\trowd'
      End If
   Loop

   'if there are two instances of '\trowd', find 1st instance of '\row' after that
   'this will give the data row definition which can be used to add further rows
   If intCompleted = 2 Then
      lngRowStart = lngPos - 1   'store the start of the first row
      lngRowLength = InStr(lngPos, strBody, "\row") - lngRowStart + 4
      strRowDef = Mid$(strBody, lngRowStart, lngRowLength)

      'find the point at the end of the table where you will want to insert new rows
      lngInsertPoint = InStr(lngPos, strBody, "\row\pard")
      If lngInsertPoint > 0 Then lngInsertPoint = lngInsertPoint + 4

      'create pages as neccessary
      For intPageLoop = 1 To intPages

         'create the output file
         MakeLocalFile strOut

         'open a channel to the newly-opened file
         intChan = FreeFile
         Open strOut For Output As #intChan

         'write header to the file
         Print #intChan, Left$(strBody, lngRowStart - 1)    '20Sep01 JN This section added

         'decide on how many rows to add in for this page
         If intPageLoop < intPages Or intRemainder = 0 Then
            intInsertLimit = i_intMaxTableRows
         Else
            intInsertLimit = intRemainder
         End If

         'build up a string containing row definitions, the first of which is renumbered
         'correctly for each page. Any further rows are additions to the table
         For intInsert = 1 To intInsertLimit
            'write the renumbered row elements to the output file
            Print #intChan, RenumberRowElements(strRowDef, (intPageLoop - 1) * i_intMaxTableRows + intInsert)     '20Sep01 JN Amended to avoid extra string manipulation
         Next

         'write the footer to the output file
         Print #intChan, Mid$(strBody, lngRowStart + lngRowLength)      '20Sep01 JN Write footer to file

         'close the output file
         Close intChan

         'add the last filename to the list
         o_strNewTemplate = o_strNewTemplate & (strOut & "|")
      Next

   End If

   'add in the number of pages created to the template details
   o_strNewTemplate = Format$(intPages) & ("|" & o_strNewTemplate)

End Sub

Public Sub ProcessRepeatBatch(ByRef frmRptDisp As Form)

'18May11 TH Added section to read JVM settings
'06Feb17 TH Number of mods to support Reprinting of main issue report
'           1=save only data file (not full rtf), 2= use new file include in DB parsing 3=lock file and channel for use lower down(TFS 175260)

Dim success As Boolean
Dim RepeatDispensingBatchID As Long
Dim RepeatDispensingXML As String
Dim strXML As String
Dim strBatchNotes As String

Dim xmldoc As MSXML2.DOMDocument
Dim XMLelement As MSXML2.IXMLDOMElement
Dim xmlnode As MSXML2.IXMLDOMElement
Dim HasRobot As Boolean
Dim PackerSection As String
Dim MachineName As String
Dim DisplayName As String
Dim strText As String
Dim lngMTSNo As Long
'Dim blnMTSNoSuccess As Boolean
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
Dim blnUpdateBatch As Boolean
Dim strErrMsg As String
Dim filno As Long
Dim strRequiredDate As String
Dim strTemp As String
Dim valid As Integer
Dim blnDone As Boolean
Dim strRequiredDateShuffle As String
Dim JVMsortorder As Integer
Dim strFormat As String '23May11 TH Added (F0118397)
Dim intCombinedLoop As Integer   '04Apr12 TH Added
Dim intCombined As Integer       '   "
Dim blnLabelCancel As Boolean
Dim strStartSlot As String       '10Apr12 TH Added
Dim strEndSlot As String         '    "
Dim strSlots As String           '    "
Dim intJVMEndSlot As Integer
Dim strEndDate As String
Dim intTempSlot As Integer
Dim intTmpslots As Integer
Dim intDay As Integer
Dim DTFirst As DateAndTime
Dim DTSecond As DateAndTime
Dim rsDeliveryMethod As ADODB.Recordset
Dim intSuccess As Integer
Dim strStartDate As String
Dim strDate As String
Dim strLocation As String
Dim blnRobotable As Boolean
Dim strLineBreak As String
Dim strStartSlotDB As String     '26Apr12 TH
Dim strEndSlotDB As String       '26Apr12 TH
Dim strSlotsDB As String       '26Apr12 TH
Dim strRequirementsText As String  '03Feb17 TH Added (TFS 175260)

  ''    On Error GoTo ProcessRepeatBatchError
      
      success = True
      
      m_blnRobotItem = False '19Jul09 TH Added
      blnLabelCancel = False
      m_blnJVADTPS = False
      m_lng_eMMNumberofDays = 0   '26Apr12 TH reset number of days
      
      '28Apr11 CKJ added packertype handling
      m_PackerType = ""
      m_PackerSection = Format$(MechDispPackerSection(MachineName, DisplayName))      '
      HasRobot = Val(m_PackerSection) > 0
      If HasRobot Then
         m_PackerType = UCase(MachineName)
         Select Case m_PackerType
            Case "MTS", "JVADTPS"
               FillDoseSlotArray m_PackerSection
            Case Else
               popmessagecr ".", "Packing robot undefined; '" & m_PackerType & "'"
               HasRobot = False
               m_PackerSection = 0
               m_PackerType = ""
            End Select
      End If
      
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
      
      'OK here we check if we are combined and then loop 2 under the seperate modes
      If RepeatDispensingAction = "C" Then
         intCombined = 2
         RepeatDispensingAction = "L"
         lngOK = SetRepeatDispensingMode(RepeatDispensingAction)
      Else
         intCombined = 1
      End If
      
      For intCombinedLoop = 1 To intCombined
         blnUpdateBatch = False
         If intCombinedLoop = 2 Then
         RepeatDispensingAction = "I"
         lngOK = SetRepeatDispensingMode(RepeatDispensingAction)
         End If
         
         RepeatDispensingBatchID = 0
         Set xmldoc = New MSXML2.DOMDocument
         xmldoc.loadXML strXML
         If intCombinedLoop = 1 Then blnRobotable = Robotable(xmldoc)
         
         For Each XMLelement In xmldoc.selectNodes("//Batch")              'for each batch (only process first, as design is for only one)
            For Each xmlnode In XMLelement.selectNodes("ValidationError")  'handle batch errors here
               strBatchNotes = strBatchNotes & xmlnode.xml & crlf          'should never be batch errors  '** tidy for printing
               'We should only fail now for real errors
               If Val(Iff(IsNull(xmlnode.getAttribute("Exception")), "", xmlnode.getAttribute("Exception"))) = 1 Then success = False   '02Nov09 TH Added
               'success = False
            Next
            
            If success Then
               RepeatDispensingBatchID = XMLelement.getAttribute("BatchID")
               strLocation = XMLelement.getAttribute("LocationDescription")
               m_lng_eMMLocationID = Val(XMLelement.getAttribute("LocationID"))
               If RepeatDispensingBatchID <= 0 Then                'not a valid batch
                  strBatchNotes = strBatchNotes & "Batch ID not supplied" & crlf
                  success = False
               ElseIf HasRobot And UCase(MachineName) = "JVADTPS" Then '18May11 TH Added to read JVM settings
                  'JVM so prefill the batch level pattern
                  blnJVMBreakfast = True
                  blnJVMLunch = True
                  blnJVMTea = True
                  blnJVMNight = True
                  intJVMStartSlot = 1
                  intJVMTotalSlots = 0
                  If XMLelement.getAttribute("Breakfast") = "0" Then blnJVMBreakfast = False
                  If XMLelement.getAttribute("Lunch") = "0" Then blnJVMLunch = False
                  If XMLelement.getAttribute("Tea") = "0" Then blnJVMTea = False
                  If XMLelement.getAttribute("Night") = "0" Then blnJVMNight = False
                  If LCase(XMLelement.getAttribute("Breakfast")) = "false" Then blnJVMBreakfast = False  '07Jun11 TH Added after getting actual XML
                  If LCase(XMLelement.getAttribute("Lunch")) = "false" Then blnJVMLunch = False          '  "
                  If LCase(XMLelement.getAttribute("Tea")) = "false" Then blnJVMTea = False              '  "
                  If LCase(XMLelement.getAttribute("Night")) = "false" Then blnJVMNight = False          '  "
                  intJVMStartSlot = Val(XMLelement.getAttribute("StartSlot"))
                  intJVMTotalSlots = Val(XMLelement.getAttribute("TotalSlots"))
                  strTemp = XMLelement.getAttribute("StartDate")    'date as ccyy-mm-ddT00:00:00 only
                  m_strJVMStartDate = Mid$(strTemp, 9, 2) & Mid$(strTemp, 6, 2) & Left$(strTemp, 4)   'date as ddmmccyy only
                  strStartDate = Mid$(strTemp, 9, 2) & "/" & Mid$(strTemp, 6, 2) & "/" & Left$(strTemp, 4)
                  'strTemp = XMLelement.getAttribute("EndDate")    'date as ccyy-mm-ddT00:00:00 only
                  strEndDate = Mid$(strTemp, 9, 2) & "/" & Mid$(strTemp, 6, 2) & "/" & Left$(strTemp, 4)  'date as ddmmccyy only
                  Select Case intJVMStartSlot
                     Case 1: strStartSlot = "Breakfast": strStartSlotDB = TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "B", "BreakfastForeMM", 0)
                     Case 2: strStartSlot = "Lunch": strStartSlotDB = TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "L", "LunchForeMM", 0)
                     Case 3: strStartSlot = "Tea": strStartSlotDB = TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "T", "TeaForeMM", 0)
                     Case 4: strStartSlot = "Night": strStartSlotDB = TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "N", "NightForeMM", 0)
                  End Select
                  'Now we need to derive the end slot
                  intTempSlot = intJVMStartSlot
                  intTmpslots = 0
                  intDay = 0
                  Do While intTmpslots < intJVMTotalSlots
                     
                     Select Case intTempSlot
                        Case 1: If blnJVMBreakfast Then intTmpslots = intTmpslots + 1
                        Case 2: If blnJVMLunch Then intTmpslots = intTmpslots + 1
                        Case 3: If blnJVMTea Then intTmpslots = intTmpslots + 1
                        Case 4: If blnJVMNight Then intTmpslots = intTmpslots + 1
                     End Select
                     If intTmpslots < intJVMTotalSlots Then
                        intTempSlot = intTempSlot + 1
                        If intTempSlot = 5 Then
                           intTempSlot = 1
                           intDay = intDay + 1
                        End If
                     End If
                  Loop
                  'derive end date
                  If intDay > 0 Then
                     StringToDate strEndDate, DTFirst
                     DTSecond.day = intDay
                     AddExpiry DTFirst, DTSecond
                     DateToString DTFirst, strEndDate
                  End If
                  'm_lng_eMMNumberofDays = (intDay + 1)
                  If intJVMTotalSlots > 0 Then m_lng_eMMNumberofDays = (intDay + 1) '25Apr12 TH Added (TFS32650)
                  Select Case intTempSlot
                     Case 1: strEndSlot = "Breakfast": strEndSlotDB = TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "B", "BreakfastForeMM", 0)
                     Case 2: strEndSlot = "Lunch": strEndSlotDB = TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "L", "LunchForeMM", 0)
                     Case 3: strEndSlot = "Tea": strEndSlotDB = TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "T", "TeaForeMM", 0)
                     Case 4: strEndSlot = "Night": strEndSlotDB = TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "N", "NightForeMM", 0)
                  End Select
                  
                  strSlots = Iff(blnJVMBreakfast, "Breakfast, ", "") & Iff(blnJVMLunch, "Lunch, ", "") & Iff(blnJVMTea, "Tea, ", "") & Iff(blnJVMNight, "Night, ", "")
                  strSlotsDB = Iff(blnJVMBreakfast, TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "B", "BreakfastForeMM", 0) & ", ", "") & Iff(blnJVMLunch, TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "L", "LunchForeMM", 0) & ", ", "") & Iff(blnJVMTea, TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "T", "TeaForeMM", 0) & ", ", "") & Iff(blnJVMNight, TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "N", "NightForeMM", 0) & ", ", "")
                  If Trim$(strSlots) <> "" Then strSlots = Left$(strSlots, Len(strSlots) - 2)
                  
               End If
               m_RepeatDispensingBatchDescription = XMLelement.getAttribute("Description")
               m_intBagLabels = Val(XMLelement.getAttribute("BagLabels")) '30May11 TH Bag labels now batch not patient specific
            End If
            Exit For    'amend here if more than one batch needs to be supported
         Next
         
            
         If success Then   'find and process all patients in batch
            'Read the multiplier and do here - we need to do two reports at present
            intMultiplier = CInt(XMLelement.getAttribute("Factor"))
            k.escd = False '09Nov09 TH
            For intloop = 1 To intMultiplier
               If Not k.escd Then    '09Nov09 TH Added
                  If RepeatDispensingAction = "I" Then
                     frmRptDisp.lblRpt.Caption = "Issuing Stock ..."
                     
                     '12Apr12 TH Moved blck below to handle escape from eMM mods correctly.
                     'strFile = dispdata$ & "\RPTDISP.DAT"
                     'If fileexists(strFile) Then
                     '   strFileinfo = FileDateTime(strFile)
                     '   strPrintReport = "N"
                     '   askwin "?Repeat Dispensing", "Before creating a new report do you want to re-print the " & cr & "previous report that was created on: " & strFileinfo, strPrintReport, k
                     '   If strPrintReport = "Y" Then
                     '      Do
                     '         Heap 10, gPRNheapID, "repeatdispensingdata", "[#include" & TB & strFile & "]", 0
                     '         If InStr(UCase$(Command$), "/HEAPDEBUG") Then Heap 100, gPRNheapID, "", "", 0
                     '         parseRTF dispdata$ & "\RPTDISP.RTF", strOutfile
                     '         Hedit 14, "RptDisp" & Chr$(0) & strOutfile
                     '         askwin "?Repeat Dispensing", "Previous repeat dispensing report printed" & cr & "Did the report print successfully?", strPrintReport, k
                     '         If k.escd Then strPrintReport = "Y"
                     '      Loop Until strPrintReport = "Y"
                     '      If k.escd Then GoTo RptErrExit      '**!! consider cleaner exit
                     '   End If
                     '   Kill dispdata$ & "\RPTDISP.DAT"
                     'End If
                     'strPrintReport = "Y"
                     'askwin "?Repeat Dispensing", "Do you want to print a report of all the" & cr & "items issued at the end of this batch?", strPrintReport, k
                     'If k.escd Then
                     '   popmessagecr "#Repeat Dispensing", "Issuing of stock cancelled"
                     '   GoTo RptErrExit
                     'End If
                     'If strPrintReport = "Y" Then
                     '   strFile = dispdata$ & "\RPTDISP.DAT"
                     '   intReportChan = FreeFile
                     '   Open strFile For Output Lock Read Write As intReportChan
                     'End If
                        
                     'If we are labelling in a combined call then check to see if we are using Meds Management
                     If TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "", "N", "MedicineManagement", 0)) Then
                        'set Meds Management flag - this can then be turned off independently of the switch
                        m_blnMedsManagement = True
                        'Prepare the meds management data capture
                        Set frmSupplyRequestInfo = New frmSupplyRequestInfo
                        frmSupplyRequestInfo.lblDesc = m_RepeatDispensingBatchDescription
                        
                        'get and populate the delivery method combo
                        Set rsDeliveryMethod = gTransport.ExecuteSelectSP(g_SessionID, "pascEMMDeliveryMethodSelectAll", "")
                        If rsDeliveryMethod.RecordCount > 0 Then
                           rsDeliveryMethod.MoveFirst
                           Do While Not rsDeliveryMethod.EOF
                              frmSupplyRequestInfo.cmbDeliveryMethod.AddItem (RtrimGetField(rsDeliveryMethod!Description))
                              frmSupplyRequestInfo.cmbDeliveryMethod.ItemData(frmSupplyRequestInfo.cmbDeliveryMethod.NewIndex) = RtrimGetField(rsDeliveryMethod!ascEMMDeliveryMethodID)
                              rsDeliveryMethod.MoveNext
                           Loop
                        End If
                        rsDeliveryMethod.Close
                        Set rsDeliveryMethod = Nothing
                        
                        m_lng_eMMComplianceTypeID = 0
                        strParams = gTransport.CreateInputParameterXML("Except", trnDataTypeVarChar, 50, TxtD(dispdata$ & "\RptDisp.INI", "", "DORIS", "ComplianceAid", 0))
                        If HasRobot And UCase(MachineName) = "JVADTPS" And blnRobotable And (intJVMTotalSlots > 0) Then
                           m_blnJVADTPS = True
                           Set rsDeliveryMethod = gTransport.ExecuteSelectSP(g_SessionID, "pASCComplianceAidSelectbyDescription", strParams)
                           If rsDeliveryMethod.RecordCount > 0 Then
                              m_lng_eMMComplianceTypeID = RtrimGetField(rsDeliveryMethod!ascComplianceAidID)
                           End If
                        Else
                           Set rsDeliveryMethod = gTransport.ExecuteSelectSP(g_SessionID, "pASCComplianceAidSelectExcept", strParams)
                           If rsDeliveryMethod.RecordCount > 0 Then
                              rsDeliveryMethod.MoveFirst
                              Do While Not rsDeliveryMethod.EOF
                                 frmSupplyRequestInfo.cmbComplianceType.AddItem (RtrimGetField(rsDeliveryMethod!Description))
                                 frmSupplyRequestInfo.cmbComplianceType.ItemData(frmSupplyRequestInfo.cmbComplianceType.NewIndex) = RtrimGetField(rsDeliveryMethod!ascComplianceAidID)
                                 rsDeliveryMethod.MoveNext
                              Loop
                           End If
                        End If
                        rsDeliveryMethod.Close
                        Set rsDeliveryMethod = Nothing
                        
                        frmSupplyRequestInfo.lblPriority.Caption = TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "&Priority", "PriorityCaption", 0)
                        
                        frmSupplyRequestInfo.lblbLocation.Caption = strLocation
                        
                        strLineBreak = TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "<br>", "BatchDescriptionLineBreak", 0)
                           
                        If HasRobot And UCase(MachineName) = "JVADTPS" And blnRobotable And (intJVMTotalSlots > 0) Then
                           frmSupplyRequestInfo.lbldateover.Visible = False
                           frmSupplyRequestInfo.lbltimeover.Visible = False
                           frmSupplyRequestInfo.lblReq.Visible = False
                           frmSupplyRequestInfo.lblEndDate = strEndDate & " " & strEndSlot
                           frmSupplyRequestInfo.lblStartdate = strStartDate & " " & strStartSlot
                           frmSupplyRequestInfo.lblSlots = strSlots
                           frmSupplyRequestInfo.chkCompliance.Visible = False
                           frmSupplyRequestInfo.cmbComplianceType.Visible = False
                           frmSupplyRequestInfo.txtComplianceStartDate.Visible = False
                           'set the date and disable
                           frmSupplyRequestInfo.lblDate.Caption = strStartDate
                           frmSupplyRequestInfo.lblTime.Caption = GetPackerSlot(intJVMStartSlot)
                           'frmSupplyRequestInfo.txtDate.Enabled = False
                           'frmSupplyRequestInfo.TxtTime.Enabled = False
                           'frmSupplyRequestInfo.txtDate.Visible = False
                           'frmSupplyRequestInfo.TxtTime.Visible = False
                           frmSupplyRequestInfo.lblDate.Visible = False
                           frmSupplyRequestInfo.lblTime.Visible = False
                           frmSupplyRequestInfo.Text1.Visible = False  '25Apr12 TH (TFS 32647)
                           frmSupplyRequestInfo.Text2.Visible = False  '25Apr12 TH (TFS 32647)
                           m_str_eMMBatchDescription = "JVM Batch: " & m_RepeatDispensingBatchDescription & Iff(Trim$(strLineBreak) <> "", strLineBreak, Iff(Trim$(strLocation) <> "", " - ", "")) & Iff(Trim$(strLocation) <> "", "Location : " & strLocation, "")
                           'm_str_eMMBatchDescription = m_str_eMMBatchDescription & " - Start : " & strStartDate & " " & strStartSlotDB
                           m_str_eMMBatchDescription = m_str_eMMBatchDescription & "Start: " & strStartDate & " " & strStartSlotDB  '26Apr12 TH Removed hyphen
                           m_str_eMMBatchDescription = m_str_eMMBatchDescription & Iff(Trim$(strLineBreak) <> "", strLineBreak, " - ") & "End: " & strEndDate & " " & strEndSlotDB
                           m_str_eMMBatchDescription = m_str_eMMBatchDescription & Iff(Trim$(strLineBreak) <> "", strLineBreak, " - ") & "Slots: " & strSlotsDB
                        Else
                           frmSupplyRequestInfo.lblComplianceAidType.Visible = True
                           frmSupplyRequestInfo.lblComplianceStartDate.Visible = True
                           'frmSupplyRequestInfo.txtDate.Visible = True
                           'frmSupplyRequestInfo.TxtTime.Visible = True
                           frmSupplyRequestInfo.lblDate.Visible = True
                           frmSupplyRequestInfo.lblTime.Visible = True
                           'frmSupplyRequestInfo.txtDate = Format$(Now, "DD/MM/YYYY")
                           'frmSupplyRequestInfo.TxtTime = Format$(Now, "NN:SS")
                           frmSupplyRequestInfo.lblDate.Caption = Format$(Now, "DD/MM/YYYY")
                           frmSupplyRequestInfo.lblTime.Caption = Format$(Now, "HH:NN")
                           'm_str_eMMBatchDescription = "Batch : " & m_RepeatDispensingBatchDescription & " - Location : " & strLocation
                           'm_str_eMMBatchDescription = "Batch : " & m_RepeatDispensingBatchDescription & Iff(Trim$(strLineBreak) <> "", strLineBreak, Iff(Trim$(strLocation) <> "", " - ", "")) & Iff(Trim$(strLocation) <> "", "Location : " & strLocation, "")
                           m_str_eMMBatchDescription = "Batch : " & m_RepeatDispensingBatchDescription & Iff(Trim$(strLocation) <> "", Iff(Trim$(strLineBreak) <> "", strLineBreak & "Location : " & strLocation, " - Location : " & strLocation), "")
                           frmSupplyRequestInfo.lblenddatedesc.Visible = False
                           frmSupplyRequestInfo.lblstartdatedesc.Visible = False
                           frmSupplyRequestInfo.lblslotsdesc.Visible = False
                           frmSupplyRequestInfo.cmbComplianceType.ListIndex = 0
                           frmSupplyRequestInfo.cmbComplianceType.Visible = True
                           frmSupplyRequestInfo.txtComplianceStartDate.Visible = True
                        End If
                        'these will be different if we are doing a DORIS run
                        
                        
                        'show the form
                        frmSupplyRequestInfo.Show 1, OwnerForm         'NG : MS_Edge_Fix for modal windows without an owner form
                        'If cancel then back out entirely from here
                        'If frmSupplyRequestInfo.Tag = "CANCEL" Then
                        If frmSupplyRequestInfo.Tag <> "OK" Or k.escd Then  '25Apr12 TH Altered as wasnt catching cancel off page
                           'Do we cancel here ?
                           frmRptDisp.lblRpt.Caption = "Supply Request cancelled. No issue will be made"
                           k.escd = True
                           'if so we need a message on screen
                        Else
                           'm_lng_eMMComplianceTypeID = 0
                           'otherwise we keep the form in scope to raise the required changes at point of issue
                           'No I think we can stor in modular variables for later use
                           m_str_eMMAdditionalInfo = frmSupplyRequestInfo.txtAdditionalInfo.text
                           If HasRobot And UCase(MachineName) = "JVADTPS" And blnRobotable And (intJVMTotalSlots > 0) Then
                              m_bln_eMMCompliance = Iff(m_lng_eMMComplianceTypeID > 0, True, False)
                              m_str_eMMComplianceStartDate = ""
                           Else
                              'm_bln_eMMCompliance = frmSupplyRequestInfo.chkCompliance.Value
                              If frmSupplyRequestInfo.cmbComplianceType.ListIndex >= 0 Then
                                 m_lng_eMMComplianceTypeID = frmSupplyRequestInfo.cmbComplianceType.ItemData(frmSupplyRequestInfo.cmbComplianceType.ListIndex)
                              End If
                              m_bln_eMMCompliance = (m_lng_eMMComplianceTypeID > 0)
                              m_str_eMMComplianceStartDate = frmSupplyRequestInfo.txtComplianceStartDate.text
                           End If
                           
                           m_lng_eMMDeliveryTypeID = 0
                           If frmSupplyRequestInfo.cmbDeliveryMethod.ListIndex >= 0 Then
                              m_lng_eMMDeliveryTypeID = frmSupplyRequestInfo.cmbDeliveryMethod.ItemData(frmSupplyRequestInfo.cmbDeliveryMethod.ListIndex)
                           End If
                           
                           strDate = frmSupplyRequestInfo.lblDate.Caption
                           'Do the date shuffle here to put it into ddMMMYYYY format - shields us from poor client formats
                           strDate = Format$(strDate, "DD/MMM/YYYY")
                           'm_dte_eMMRequiredDate = CDate(strDate & " " & frmSupplyRequestInfo.txtTime.text)
                           m_dte_eMMRequiredDate = CDate(strDate & " " & frmSupplyRequestInfo.lblTime.Caption)
                           
                           m_bln_eMMPriority = frmSupplyRequestInfo.chkUrgent.Value
                        End If
                        'Now we have the values we need we can dismiss the form
                        Unload frmSupplyRequestInfo
                        Set frmSupplyRequestInfo = Nothing
                     
                     End If
                     
                     If Not k.escd Then
                        'strFile = dispdata$ & "\RPTDISP.DAT"
                        strFile = dispdata$ & "\RPTDISP_Reprint.rtf" '03Feb17 TH Here we will read a new rtf ext named file (TFS 175260)
                        'If fileexists(strFile) Then
                        'If RTFExistsInDatabase(strFile) Then
                        strFileinfo = GetRTFUpdateDateTime(strFile, True)  '03Feb17 TH replaced above so we can update as blank rather than continually add and delete the record (TFS 175260)
                        If strFileinfo <> "" Then
                           'strFileinfo = FileDateTime(strFile)
                           strPrintReport = "N"
                           askwin "?Repeat Dispensing", "Before creating a new report do you want to re-print the " & cr & "previous report that was created on: " & strFileinfo, strPrintReport, k
                           If strPrintReport = "Y" Then
                              Do
                                 Heap 10, gPRNheapID, "repeatdispensingdata", "[#include" & TB & strFile & "]", 0
                                 If InStr(UCase$(Command$), "/HEAPDEBUG") Then Heap 100, gPRNheapID, "", "", 0
                                 'parseRTF dispdata$ & "\RPTDISP.RTF", strOutfile
                                 parseRTFfromDB dispdata$ & "\RPTDISP.RTF", strOutfile '02Feb17 We will need to load this from DB
                                 
                                 Hedit 14, "RptDisp" & Chr$(0) & strOutfile
                                 askwin "?Repeat Dispensing", "Previous repeat dispensing report printed" & cr & "Did the report print successfully?", strPrintReport, k
                                 If k.escd Then strPrintReport = "Y"
                              Loop Until strPrintReport = "Y"
                              If k.escd Then GoTo RptErrExit      '**!! consider cleaner exit
                           End If
                           '02Feb17 TH Hosted - remove this from the DB
                           'Kill dispdata$ & "\RPTDISP.DAT"
                           lngOK = WritePharmacyRTFToSQL(dispdata$ & "\RPTDISP_Reprint.rtf", "RPTDISP_Reprint.rtf", "")
                        End If
                        strPrintReport = "Y"
                        askwin "?Repeat Dispensing", "Do you want to print a report of all the" & cr & "items issued at the end of this batch?", strPrintReport, k
                        If k.escd Then
                           popmessagecr "#Repeat Dispensing", "Issuing of stock cancelled"
                           GoTo RptErrExit
                        End If
                        If strPrintReport = "Y" Then
                           '02Feb17 TH This will always be a new file by this point. It seems this is stored on share so can be accessed next time (rather than local file only)
                           'What we need to do here is to create a local file and store in the DB after printing (as something unique)
                           'This can then be accessed above and printed before being deleted and inserted/updated below (TFS 175260)
                           'strFile = dispdata$ & "\RPTDISP.DAT"
                           'intReportChan = FreeFile
                           'Open strFile For Output Lock Read Write As intReportChan
                           MakeLocalFile strFile
                           intReportChan = FreeFile                                    '06Feb17 TH Reinstated as chan used to print to lower in the process  (TFS 175260)
                           Open strFile For Output Lock Read Write As intReportChan    '  "
                        End If
                     End If
                        
                  ElseIf RepeatDispensingAction = "L" Then
                     'Here we want to check that the user has set up the environment
                     strMsg = "Please check label printer is on-line and has sufficient label stock available. OK to proceed Y/N"
                     strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingLabelPrinterCheckMsg", 0)
                              
                     askwin "Repeat Dispensing", strMsg, strAns, k
                     If strAns <> "Y" Then k.escd = True
                     If k.escd Then
                        frmRptDisp.lblRpt.Caption = "Batch labelling cancelled. No labels will be printed"
                        blnLabelCancel = True
                     Else
                        frmRptDisp.lblRpt.Caption = "Printing labels ..."
                        If RepeatDispensingAction = "L" And HasRobot Then
                           Select Case MachineName
                              Case "MTS"      ' Only allocate number when potentially outputting to robot, not at issue
                                 GetPointerSQL patdatapath$ & "\MTSRPT.dat", lngMTSNo, True
                                 SetMTSNo lngMTSNo
                              Case "JPADTPS"
                                 '!!** no action yet - may not actually be needed
                              End Select
                        End If
                     End If
                     
                  ElseIf RepeatDispensingAction = "S" Then '22Mar11 TH Added new medicine schedule stuff, Tayside(F0082043)
                     m_strRequiredDate = ""
                     strMsg = "OK to print medicine schedule Yes/No"
                     strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingMedSchedCheckMsg", 0)
                              
                     askwin "Repeat Dispensing", strMsg, strAns, k
                     If strAns <> "Y" Then k.escd = True
                     If k.escd Then
                     'frmRptDisp.lblRpt.Caption = "Medecine Schedule print cancelled."
                     frmRptDisp.lblRpt.Caption = "Medicine Schedule print cancelled." '23May11 TH Spell medicine properly (F0118399)
                     Else
                        'OK Now we need to get the Required Date
                        Do
                           strMsg = "Required date for Medicine Schedule"
                           strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingMedSchedDateMsg", 0)
                           strMsg = "Enter " & strMsg & " dd/mm/yyyy"
                           setinput 0, k
                           k.Max = 10
               
                           parsedate strRequiredDate, strRequiredDateShuffle, "1", valid           'dd/mm/yyyy
                           InputWin "Repeat Dispensing", strMsg, strRequiredDateShuffle, k
                           If Not k.escd Then
                              strFormat = "3"
                           parsedate strRequiredDateShuffle, strTemp, strFormat, valid
                              If strFormat = "0" Then valid = False
                              If valid Then
                                 If strRequiredDate = strTemp Then blnDone = True
                                 strRequiredDate = strTemp
                              Else
                                 BadDate
                              End If
                           End If
                        Loop Until blnDone Or k.escd
                        
                        If Not k.escd Then
                           'Put the date on the heap - No, defer this until later
                           m_strRequiredDate = strRequiredDateShuffle
                           frmRptDisp.lblRpt.Caption = "Printing Medicine Schedule ..." '23May11 TH Spell medicine correctly(F00118398)
                        Else  '23May11 TH Added (F0118403)
                           frmRptDisp.lblRpt.Caption = "Medicine Schedule print cancelled."
                        End If
                        
                     End If
                  
                  ElseIf RepeatDispensingAction = "R" Then '04May11 TH Added new DORIS requirements report, Norfolk(F)
                     strMsg = "OK to print Batch Requirements Report Yes/No"
                     strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingReportCheckMsg", 0)
                              
                     askwin "Repeat Dispensing", strMsg, strAns, k
                     If strAns <> "Y" Then k.escd = True
                     If k.escd Then
                         frmRptDisp.lblRpt.Caption = "Batch Requirements Report print cancelled."
                     Else
                         frmRptDisp.lblRpt.Caption = "Printing Batch Requirements Report ..."
                     End If
                     ReDim m_BatchReportList(0) As String ' BatchReportRec  'reset the batch report array
                  End If
                     
                  If (Not k.escd) And (Not CancelIsRequested()) Then  '14Jul09 TH Added
                     'Debug MsgBox "ProcessRepeatBatch" 'debug TH
                     success = ProcessBatchPatients(RepeatDispensingBatchID, XMLelement, strBatchNotes, HasRobot, intReportChan, TrueFalse(strPrintReport))
                     
                     'Now we do checks/prints based on the mode and update the Batch accordingly.
                     'If HasRobot And m_blnRobotItem Then
                     If HasRobot And m_blnRobotItem And RepeatDispensingAction = "L" Then  '13Jun11 TH Replaced Above (F120187)
                        If m_PackerType = "MTS" Then
                           MTSReleaseFile m_PackerSection '06Jul TH Added HasRobot clause **This should only be done if we have done a robot issue
                        Else
                           JVMsortorder = 1     'sortorder 0 (unsorted) still avaialable for debug but not used in real life
                           If XMLelement.getAttribute("SortByDate") = "1" Then JVMsortorder = 2
                           JVMReleaseFile m_PackerSection, JVMsortorder '24May11 CKJ added
                        End If
                     End If
                     '[]
                     
                     If RepeatDispensingAction = "I" And strPrintReport = "Y" Then Close intReportChan      '21Jun99 SF
                     Screen.MousePointer = STDCURSOR
            
                     ' print report of stock booked out
                     strPrevFile = strFile
                     If RepeatDispensingAction = "I" Then
                        If fileexists(strFile) Then              '06Apr00 MMA added
                           If FileLen(strFile) > 0 Then
                              If strPrintReport = "Y" And Not k.escd Then
                                 'If Not fileexists(dispdata$ & "\RPTDISP.RTF") Then
                                 If Not RTFExistsInDatabase(dispdata$ & "\RPTDISP.RTF") Then '02Feb17 TH Replaced above line (TFS 175260)
                                    popmessagecr "#Repeat Dispensing", "File: " & dispdata$ & "\RPTDISP.RTF not found" & cr & "Cannot run the report"
                                    Kill strPrevFile
                                    '02Feb17 TH we need to remove the dat report here (maybe from DB - HOSTED)
                                    'Exit Sub         '07Jun99 SF replaced
                                    GoTo RptErrExit:  '07Jun99 SF
                                 End If
                              End If
                              'Heap 10, gPRNheapID, "repeatdispensingdata", "[#include" & TB & strFile & "]", 0
                              Heap 10, gPRNheapID, "repeatdispensingdata", "[#includx" & TB & strFile & "]", 0  '06Feb17 TH This is a genuine file so need to use new file include (TFS 175260)
                              GetTextFile strFile, strRequirementsText, intSuccess '06Feb17 TH Moved here to cache data only (TFS 175260)
                              If InStr(UCase$(Command$), "/HEAPDEBUG") Then Heap 100, gPRNheapID, "", "", 0
                              '02Feb17 TH It looks like a file on the fileshare is standing in for a local file and is being reused
                              '           What we need here is to read out of the DB Parse to a local file and restore ? (TFS 175260)
                              'parseRTF dispdata$ & "\RPTDISP.RTF", strFile
                              parseRTFfromDB dispdata$ & "\RPTDISP.RTF", strFile  '02Feb17 TH Replaced above to use DB RTF (HOSTED) (TFS 175260)
                              Hedit 14, "RptDisp" & Chr$(0) & strFile
                              '03Feb17 TH Clear the RTF in DB update the rtf (TFS 175260)
                              'GetTextFile strFile, strRequirementsText, intSuccess '06FEb17 TH THis needs to be read BEFORE the parsing with the main rtf as we cache only data (TFS 175260)
                              If intSuccess Then lngOK = WritePharmacyRTFToSQL(dispdata$ & "\RPTDISP_Reprint.rtf", "RPTDISP_Reprint.rtf", strRequirementsText)
                              popmessagecr "#Repeat Dispensing", "Complete, report printed"
                           Else
                              popmessagecr "#Repeat Dispensing", "Complete, nothing to book out"
                              If fileexists(strPrevFile) Then Kill strPrevFile
                              '03Feb17 TH Clear the RTF in DB (TFS 175260)
                              lngOK = WritePharmacyRTFToSQL(dispdata$ & "\RPTDISP_Reprint.rtf", "RPTDISP_Reprint.rtf", "")
                           End If
                        End If
                        'Are there any exceptions , if so can we update the batch
                        If intloop = intMultiplier Then
                              blnUpdateBatch = True
                              If Trim$(strBatchNotes) <> "" Then
                                 frmRptDisp.lblRpt.Caption = "Batch issuing complete with warnings. Batch status updated."
                                 'frmRptDisp.lblWarnings.Caption = strBatchNotes
                                 frmRptDisp.txtWarnings.text = strBatchNotes
                                 frmRptDisp.fraWarnings.Visible = True
                              Else
                                 frmRptDisp.lblRpt.Caption = "Batch issuing complete. Batch status updated."
                              End If
                           End If
                     
                     '07Jun99 SF added following ELSE block
                     ElseIf RepeatDispensingAction = "L" Then  '15Mar11 TH Added further clause to allow medicine schedule
                        'Check labels are OK
                        If (HasRobot And m_blnRobotItem) Then
                           strMsg = "Labels printed and ADM messages created OK Y/N"
                           strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingLabelsOKMsgADM", 0)
                        Else
                           strMsg = "Labels printed OK Y/N"
                           strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingLabelsOKMsg", 0)
                        End If
                        askwin "Repeat Dispensing", strMsg, strAns, k
                        If strAns <> "Y" Then k.escd = True
                     
                        If k.escd Then
                           If (HasRobot And m_blnRobotItem) Then
                              strMsg = "Batch not updated. Labels and ADM messages not printed or created correctly"
                              strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingLabelsNOTOKMsgADM", 0)
                              'frmRptDisp.lblRpt.Caption = "Batch not updated. Labels and ADM messages not printed or created correctly"
                              frmRptDisp.lblRpt.Caption = strMsg  '15Jun11 TH Replaced above (F0120625)
                           Else
                              strMsg = "Batch not updated. Labels not printed correctly"
                              strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingLabelsNOTOKMsg", 0)
                              'frmRptDisp.lblRpt.Caption = "Batch not updated. Labels not printed correctly"
                              frmRptDisp.lblRpt.Caption = strMsg  '15Jun11 TH Replaced above (F0120625)
                           End If
                           blnLabelCancel = True
                        Else
                           If (HasRobot And m_blnRobotItem) Then
                              strMsg = "Batch Updated. All labels printed and ADM messages created"
                              strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingBatchOKMsgADM", 0)
                              'frmRptDisp.lblRpt.Caption = "Batch Updated. All labels printed and ADM messages created"
                              frmRptDisp.lblRpt.Caption = strMsg  '15Jun11 TH Replaced above (F0120625)
                           Else
                              strMsg = "Batch Updated. All labels printed"
                              strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingBatchOKMsg", 0)
                              'frmRptDisp.lblRpt.Caption = "Batch Updated. All labels printed"
                              frmRptDisp.lblRpt.Caption = strMsg  '15Jun11 TH Replaced above (F0120625)
                           End If
                           'Update the batch HERE
                           '(but only if we have cleared the Factor (dont update twice !)
                           If intloop = intMultiplier Then
                              blnUpdateBatch = True
                           End If
                           
                        End If
                        If Trim$(strBatchNotes) <> "" Then
                           'frmRptDisp.lblWarnings.Caption = strBatchNotes
                           frmRptDisp.txtWarnings.text = strBatchNotes
                           frmRptDisp.fraWarnings.Visible = True
                        End If
                        
                        'popmessagecr "#Repeat Dispensing", "Complete, all labels printed"
                     ElseIf RepeatDispensingAction = "S" Then
                        strMsg = "Medicine Schedule Processed."
                        strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "ScheduleCompleteMsg", 0)
                        frmRptDisp.lblRpt.Caption = "Medicine Schedule Processed."
                     ElseIf RepeatDispensingAction = "R" Then
                        If Not success Then
                           frmRptDisp.lblRpt.Caption = "Repeat batch errors"
                           If Trim$(strBatchNotes) <> "" Then
                              'frmRptDisp.lblWarnings.Caption = strBatchNotes
                              frmRptDisp.txtWarnings.text = strBatchNotes
                              frmRptDisp.fraWarnings.Visible = True
                           End If
                           popmessagecr "Repeat Dispensing", "Failed to update batch status" & crlf & crlf & strBatchNotes
                        Else
                           strMsg = "Batch Requirements Report Processed."
                           strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RequirementsReportCompleteMsg", 0)
                           frmRptDisp.lblRpt.Caption = "Batch Requirements Report Processed."
                        End If
                     End If
                  End If
               End If  '09Nov09 TH Added
            Next
         Else
         
         End If
         If blnUpdateBatch Then
            On Error GoTo RepeatBatchUpdateError
            'We will need the batchID,EntityID (of us), the
            ' RepeatDispensingBatchID,gEntityID_User,RepeatDispensingAction
            strParams = gTransport.CreateInputParameterXML("BatchID", trnDataTypeint, 4, RepeatDispensingBatchID) & _
                        gTransport.CreateInputParameterXML("EntityID_User", trnDataTypeint, 7, gEntityID_User) & _
                        gTransport.CreateInputParameterXML("RepeatDispensingAction", trnDataTypeVarChar, 1, RepeatDispensingAction)
            lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pRepeatDispensingBatchUpdateAction", strParams)
         End If
         If Not success Then
            'popmessagecr "ASCribe Repeat Dispensing", "Batch Failed." & crlf & crlf & strBatchNotes
            strErrMsg = TxtD(dispdata$ & "\RptDisp.ini", "", "Problems with Batch.", "RepeatDispensingBatchFailMsg", 0)
            popmessagecr "Repeat Dispensing", strErrMsg & crlf & crlf & strBatchNotes
            frmRptDisp.lblRpt.Caption = strErrMsg
            If Trim$(strBatchNotes) <> "" Then
               'frmRptDisp.lblWarnings.Caption = strBatchNotes
               frmRptDisp.txtWarnings.text = strBatchNotes
               frmRptDisp.fraWarnings.Visible = True
            End If
            '04Apr12 TH Should we come out at this point ?
            'Yes I think so
            Exit For
         End If
         If blnLabelCancel Then Exit For
      Next
         
      '** return to inactive state, message on screen if needed
      'close db
      
ProcessRepeatBatchExit:
   On Error Resume Next
   Set xmlnode = Nothing
   Set XMLelement = Nothing
   Set xmldoc = Nothing
   On Error GoTo 0

Exit Sub

RepeatBatchUpdateError:
success = False
   strBatchNotes = strBatchNotes & ">>>>> Error: " & Err.Number & " " & "Source: RepeatBatchUpdate " & Err.Description
   frmRptDisp.lblRpt.Caption = "Repeat batch errors"
   If Trim$(strBatchNotes) <> "" Then
      'frmRptDisp.lblWarnings.Caption = strBatchNotes
      frmRptDisp.txtWarnings.text = strBatchNotes
      frmRptDisp.fraWarnings.Visible = True
   End If
   popmessagecr "Repeat Dispensing", "Failed to update batch status" & crlf & crlf & strBatchNotes
Resume ProcessRepeatBatchExit

ProcessRepeatBatchError:
   success = False
   strBatchNotes = strBatchNotes & ">>>>> Error: " & Err.Number & " " & "Source: ProcessRepeatBatch " & Err.Description
   frmRptDisp.lblRpt.Caption = "Repeat batch errors"
   If Trim$(strBatchNotes) <> "" Then
      'frmRptDisp.lblWarnings.Caption = strBatchNotes
      frmRptDisp.txtWarnings.text = strBatchNotes
      frmRptDisp.fraWarnings.Visible = True
   End If
   popmessagecr "Repeat Dispensing", "problem(s) have been encountered with this batch :" & crlf & crlf & strBatchNotes
Resume ProcessRepeatBatchExit

RptErrExit:
frmRptDisp.lblRpt.Caption = "Batch Processed. Error printing batch report"
'Resume ProcessRepeatBatchExit
GoTo ProcessRepeatBatchExit  '10Dec09 TH (F0071709)
End Sub

Sub setRepeatDispensingAction(ByVal strRepeatDispensingAction As String)
   RepeatDispensingAction = strRepeatDispensingAction
End Sub

Private Function ProcessBatchPatients(ByVal RepeatDispensingBatchID As Long, _
                                    ByVal PatientsXML As MSXML2.IXMLDOMElement, _
                                    ByRef strBatchNotes As String, _
                                    ByVal HasRobot As Boolean, _
                                    ByVal intReportChan As Integer, _
                                    ByVal blnprintReport As Boolean) As Boolean
'Process all patients, as defined in PatientsXML
'04May11 TH Added Batch requirements report stuff (DORIS)
'01Feb17 TH Fix DB RTF header and footer on requirements report (TFS 173979)

Dim success As Boolean
Dim XMLelement As MSXML2.IXMLDOMElement
Const Source = "ProcessBatchPatients"
Dim ReportArray() As String
Dim intItemsPerPage As Integer
Dim intTotPages As Integer
Dim strOutfile As String
Dim strRTFFile As String
Dim intItem As Integer
Dim intPage As Integer
Dim intline As Integer
Dim lclDrug As DrugParameters
Dim strRTFData As String
Dim strDataLine As String
Dim sqlQty As Single
Dim strStockMsg As String
Dim strRTFFooter As String
Dim blnOK As Boolean
Dim strDataRTFFile As String
'Dim blnNoHeader As Boolean
'Dim intNoHeader As Integer '05Jan17 TH Changed to allow to be used in new sub
Dim intHeader As Integer '03Feb17 TH Simplify the logic (and fix it) (TFS 173979)
Dim strRTHeaderData As String
Dim strTemp As String
Dim intOK As Integer '05Jan17 TH Added
Dim intFooter As Integer  '05Jan17 TH Added

   'Debug MsgBox PatientsXML.xml 'debug TH
   success = True
   On Error GoTo ProcessBatchPatientsError
   
   Heap 10, gPRNheapID, "RptDispBatchDesc", m_RepeatDispensingBatchDescription, 0
   
   For Each XMLelement In PatientsXML.selectNodes("//Patient")  'for each patient
      success = ProcessBatchPatient(RepeatDispensingBatchID, XMLelement, strBatchNotes, HasRobot, intReportChan, blnprintReport)
      If Not success Then
         '!!** decide if carry on or quit
         If RepeatDispensingAction = "R" Then Exit For '26May11 TH Added
      End If
   Next
   
   '04May11 TH Here we should have an array created of the drugs and quantities required for the
   'batch requirements report. Now we use the array to assemble and print the report.
   If RepeatDispensingAction = "R" Then
      'As this is new I wont use the over complex tayside print as the basis. New rtfs /mechanisms are called for
      'First check we have a data rtf. Headers and footers are optional but we must have one of these
      If UBound(m_BatchReportList()) = 0 Then
         popmessagecr "", "No Dispensings Required - Report will not be produced"
         success = False
      End If
      
      If success Then   '26May11 TH Added
         blnOK = True
         strDataRTFFile = "Rpt_Requirements_Data.rtf"
         strDataRTFFile = TxtD(dispdata$ & "\RptDisp.INI", "RequirementsReport", strDataRTFFile, "DataRTFFile", 0)
         If strDataRTFFile <> "" Then
            strDataRTFFile = dispdata & "\" & strDataRTFFile
            '06Dec16 TH Replaced bloc below(TFS 157969)
            GetRTFTextFromDB strDataRTFFile, strRTFData, intOK '06Dec16 TH Replaced bloc below(TFS 157969)
            If Not intOK Then
               popmessagecr "", "Repeat Dispensing Requirement Report Incorrectly configured - " & strDataRTFFile & " Not Found"
               blnOK = False
            Else
               striprtf strRTFData
            End If
            '06Dec16 TH Replaced bloc below(TFS 157969)
            
            'If fileexists(strDataRTFFile) Then
            '   GetTextFile strDataRTFFile, strRTFData, 0
            '   striprtf strRTFData
            '   'If LCase$(Left$(strDataRTFFile, 5)) = "{\rtf1" Then strDataRTFFile = Mid$(strDataRTFFile, 2)
            'Else
            '   popmessagecr "", "Repeat Dispensing Requirement Report Incorrectly configured - " & strDataRTFFile & " File Not Found"
            '   blnOK = False
            'End If
         Else
            popmessagecr "", "Repeat Dispensing Requirement Report Incorrectly configured - Data RTF File not specified"
            blnOK = False
         End If
         If blnOK Then
            'Sort the array then print
            shellsort m_BatchReportList(), UBound(m_BatchReportList()), 0, 0, 0
            'First lets get a header - put a page element on it and a total (thus page one of xxx
            'get the number of items per page
            intItemsPerPage = TxtD(dispdata$ & "\RptDisp.INI", "RequirementsReport", "20", "LinesperPage", 0) '03Mar09 TH Added
            intTotPages = UBound(m_BatchReportList()) \ intItemsPerPage
            'If UBound(m_BatchReportList()) Mod intItemsPerPage > 1 Then intTotPages = intTotPages + 1
            If UBound(m_BatchReportList()) Mod intItemsPerPage > 0 Then intTotPages = intTotPages + 1  '16Jun11 TH Altered (F0120631)
            'put this on the heap
            Heap 10, gPRNheapID, "TotalPages", Format$(intTotPages), 0
            intItem = 0
            MakeLocalFile strOutfile
            For intPage = 1 To intTotPages
               Heap 10, gPRNheapID, "Page", Format$(intPage), 0
               strRTFFile = "Rpt_Requirements_header.rtf"
                
               strRTFFile = TxtD(dispdata$ & "\RptDisp.INI", "RequirementsReport", strRTFFile, "HeaderRTFFile", 0)
               If strRTFFile <> "" Then
                  strRTFFile = dispdata & "\" & strRTFFile
                  '06Dec16 TH Replaced bloc below(TFS 157969)
                  'GetRTFTextFromDB strDataRTFFile, strRTFData, intNoHeader
                  If RTFExistsInDatabase(strRTFFile) Then                        '01Feb17 TH Replaced above (TFS 173979)
                     'GetRTFTextFromDB strRTFFile, strRTHeaderData, intNoHeader   '  "
                     GetRTFTextFromDB strRTFFile, strRTHeaderData, intHeader   '03Feb17 TH Simplify the logic (and fix it) (TFS 173979)
                     'If Not intNoHeader Then
                     If intHeader Then '03Feb17 TH Simplify the logic (and fix it) (TFS 173979)
                        striprtf strRTHeaderData
                        'MakeLocalFile strOutfile
                        If intPage > 1 Then
                           strTemp = "[FF]"
                           PrinterParse strTemp
                           strRTHeaderData = strTemp & strRTHeaderData
                        Else
                           strRTHeaderData = "{" & strRTHeaderData
                        End If
                        ParseItems gPRNheapID, strRTHeaderData, 0
                        PutTextFileAppend strOutfile, strRTHeaderData, 0
                     End If
                  Else
                     'intNoHeader = True
                     intHeader = False '03Feb17 TH Simplify the logic (and fix it) (TFS 173979)
                  End If
                  '06Dec16 TH Replaced bloc below(TFS 157969)
                  'If fileexists(strRTFFile) Then
                  '   'Need to strip and prepare the rtf
                  '   GetTextFile strRTFFile, strRTHeaderData, 0
                  '   striprtf strRTHeaderData
                  '   'MakeLocalFile strOutfile
                  '   If intPage > 1 Then
                  '      strTemp = "[FF]"
                  '      PrinterParse strTemp
                  '      strRTHeaderData = strTemp & strRTHeaderData
                  '   Else
                  '      strRTHeaderData = "{" & strRTHeaderData
                  '   End If
                  '   ParseItems gPRNheapID, strRTHeaderData, 0
                  '   PutTextFileAppend strOutfile, strRTHeaderData, 0
                  '   'parseRTF strRTFFile, strOutfile
                  'Else
                  '     intNoHeader = True
                  'End If
               Else
                  'intNoHeader = True
                  intHeader = False '03Feb17 TH Simplify the logic (and fix it) (TFS 173979)
               End If
               
               'If intNoHeader Then
               If Not intHeader Then '03Feb17 TH Simplify the logic (and fix it) (TFS 173979)
                  'MakeLocalFile strOutfile
                  
                  ''''PutTextFileAppend strOutfile, "{", 0
                  If intPage > 1 Then
                     strTemp = "[FF]"
                     PrinterParse strTemp
                     PutTextFileAppend strOutfile, strTemp, 0
                  Else
                     PutTextFileAppend strOutfile, "{", 0
                  End If
               End If
               
               'Second data loop through array#
               'intPageItem = 1
               For intline = 1 To intItemsPerPage
                  intItem = intItem + 1
                  If intItem > UBound(m_BatchReportList()) Then Exit For 'End of array
                  'get the item, put it on the heap
                  lclDrug.SisCode = Mid$(m_BatchReportList(intItem), 11, 7)
                  getdrug lclDrug, 0, 0, False
                  FillHeapDrugInfo gPRNheapID, lclDrug, 0
                  'Put qty required on heap and whether enough or not (as per spec)
                  
                  sqlQty = CSng(Right$(m_BatchReportList(intItem), Len(m_BatchReportList(intItem)) - 17))
                  If Val(lclDrug.stocklvl) <= 0 Then
                     strStockMsg = TxtD(dispdata$ & "\RptDisp.INI", "RequirementsReport", "No Stock", "NoStockMsg", 0)
                  ElseIf (Val(lclDrug.stocklvl) - sqlQty) <= 0 Then
                     strStockMsg = TxtD(dispdata$ & "\RptDisp.INI", "RequirementsReport", "Insufficient Stock", "InsufficientStockMsg", 0)
                  Else
                     strStockMsg = TxtD(dispdata$ & "\RptDisp.INI", "RequirementsReport", "", "StockOKMsg", 0)
                  End If
                  Heap 10, gPRNheapID, "StockMsg", strStockMsg, 0
                   
                  Heap 10, gPRNheapID, "StockReq", Right$(m_BatchReportList(intItem), Len(m_BatchReportList(intItem)) - 17), 0
                  sqlQty = CSng(Right$(m_BatchReportList(intItem), Len(m_BatchReportList(intItem)) - 17))
                  'Read the local file.
                  strDataLine = strRTFData
                  ParseItems gPRNheapID, strDataLine, 0
                  PutTextFileAppend strOutfile, strDataLine, 0
               Next
               
               'last a footer
               strRTFFile = "Rpt_Requirements_Footer.rtf"
               strRTFFile = TxtD(dispdata$ & "\RptDisp.INI", "RequirementsReport", strRTFFile, "FooterRTFFile", 0)
               If strRTFFile <> "" Then
                  strRTFFile = dispdata & "\" & strRTFFile
                  '06Dec16 TH Replaced bloc below(TFS 157969)
                  'GetRTFTextFromDB strDataRTFFile, strRTFData, intFooter
                  If RTFExistsInDatabase(strRTFFile) Then                  '01Feb17 TH Replaced above (TFS 173979)
                     GetRTFTextFromDB strRTFFile, strRTFFooter, intFooter  '  "
                     If Not intFooter Then
                        striprtf strRTFFooter
                        ParseItems gPRNheapID, strRTFFooter, 0
                     End If
                  End If
                  'If fileexists(strRTFFile) Then
                  '   GetTextFile strRTFFile, strRTFFooter, 0
                  '   'Read the local file.
                  '   striprtf strRTFFooter
                  '   strRTFFooter = strRTFFooter
                  '   ParseItems gPRNheapID, strRTFFooter, 0
                  'End If
               End If
               'If intline <> intItemsPerPage Then 'we have another page to come
               '   strTemp = "[FF]"
               '   PrinterParse strTemp
               '   strRTFFooter = strRTFFooter & strTemp
               'End If
               PutTextFileAppend strOutfile, strRTFFooter, 0
            Next
            PutTextFileAppend strOutfile, "}", 0
            Hedit 14, "RptDispReqReport" & Nul & strOutfile
            On Error Resume Next
            Kill strOutfile
            On Error GoTo 0
         End If
      End If
   End If
   

ProcessBatchPatientsExit:
   On Error Resume Next
   Set XMLelement = Nothing
   On Error GoTo 0
   ProcessBatchPatients = success
Exit Function

ProcessBatchPatientsError:
   success = False
   strBatchNotes = strBatchNotes & ">>>>> Error: " & Err.Number & " " & "Source: " & Source & " " & Err.Description
Resume ProcessBatchPatientsExit

End Function

Private Function ProcessBatchPatient(RepeatDispensingBatchID As Long, _
                                    ByVal PatientXML As MSXML2.IXMLDOMElement, _
                                    ByRef strBatchNotes As String, _
                                    ByVal HasRobot As Boolean, _
                                    ByVal intReportChan As Integer, _
                                    ByVal blnprintReport As Boolean) As Boolean
'Process a single patient, as defined in PatientXML
'23Mar11 TH Large addition to power Medicine schedule print. If Schedule is required then we loop through
'           each patient node and print schedules for them in turn.
'04May11 TH DORIS Now another seperate section for Batch requirements report
'07Jun11 TH  Exclude not inuse patient lines (F0119656)
'26Sep11 TH  Allow patient with validation errors to be processed. IF we are here then we have passed validation checking to stop the patient (TFS15629)
'12Apr17 TH  Replaced call as medicine schedule rtf is now in the DB (TFS 180854)

Dim success As Boolean
Dim RepeatDispensingPatientID As Long
Dim xmlnode As MSXML2.IXMLDOMElement
Dim XMLelement As MSXML2.IXMLDOMElement
Dim blnLabelsPrinted As Boolean
Dim intSupplyLength As Integer
Dim intloop As Integer
Dim intSupplyPatternDays As Integer
Dim intSupplyPatternSplitDays As Integer

'15Mar11 TH From here
Dim RepeatDispensingDispensingID As Long
Dim RepeatDispensingPrescriptionID As Long
Dim strWkComm As String
Dim intInstrs As Integer
Dim intWarnings As Integer
Dim intItemsPerPage As Integer
Dim WPat As WPatient
Dim dteWC As DateAndTime
Dim strLayout As String
Dim io_strErrMsg As String
Dim udtSup As supplierstruct
Dim intLabelCount As Integer
Dim strOutLayout As String
Dim intFiles As Integer
Dim strRTF() As String
Dim intRTF As Integer
Dim strParsedFile As String
Dim intPreview As Integer
Dim intCopies As Integer
Dim lngEpisodeID As Long
Dim rsSupplyPatterns As ADODB.Recordset
Dim strParams As String
Dim strSupplyDescription As String
Dim rsRptDispPatient As ADODB.Recordset
Dim strAdditionalinformation As String
Dim blnPatientSpecificeMMDays As Boolean '27Apr12 TH Added

Const Source = "ProcessBatchPatient"

   On Error GoTo ProcessBatchPatientError
   success = True
   For Each xmlnode In PatientXML.selectNodes("ValidationError")
      'strBatchNotes = strBatchNotes & crlf & ">>>>> Patient not processed" & crlf
      strBatchNotes = strBatchNotes & crlf & ">>>>> Patient warning" & crlf  '26Sep11 TH Altered message (TFS15629)
      strBatchNotes = strBatchNotes & xmlnode.xml & crlf       '** tidy for printing
      'success = False  '26Sep11 TH If we have got this far these are warnings only - proceed to label or issue ! (TFS15629)
   Next
   
   If success Then
      If LCase(PatientXML.getAttribute("InUse")) = "true" Or PatientXML.getAttribute("InUse") = "1" Then '07Jun11 TH (F0119656)
         RepeatDispensingPatientID = PatientXML.getAttribute("EntityID")
         If RepeatDispensingPatientID > 0 Then                'potentially valid patient
         
            'Do separately here for medicine schedule
            If RepeatDispensingMode() = "S" Then
               'Effectively this used to be from Sub Medicine schedule, but this was such a rewrite
               'that the following is the basis of this with a lot of rework/addition
               RepeatDispensingPatientID = PatientXML.getAttribute("EntityID")
               intSupplyLength = PatientXML.getAttribute("SupplyLength")
               
               If m_lng_eMMNumberofDays = 0 Then
                  m_lng_eMMNumberofDays = intSupplyLength '11Apr12 TH Added
                  blnPatientSpecificeMMDays = True '27Apr12 TH Added
               End If
               
               If Not IsNull(PatientXML.getAttribute("SupplyPatternDays")) Then
               intSupplyPatternDays = PatientXML.getAttribute("SupplyPatternDays")
               'If intSupplyPatternDays = 0 Then intSupplyPatternDays = 7 '31July09 TH Added - default to week ?? '30Oct09 TH REmoved as these should be handled as single shot ??
               End If
               If Not IsNull(PatientXML.getAttribute("SupplyPatternSplitDays")) Then
                  intSupplyPatternSplitDays = PatientXML.getAttribute("SupplyPatternSplitDays")
               End If
               
                'Put supply days, pattern on heap
               'Here we need to get the supplier pattern information
               strParams = gTransport.CreateInputParameterXML("Days", trnDataTypeint, 4, intSupplyPatternDays) & _
                           gTransport.CreateInputParameterXML("SplitDays", trnDataTypeint, 4, intSupplyPatternSplitDays)
               Set rsSupplyPatterns = gTransport.ExecuteSelectSP(g_SessionID, "pRepeatDispensingSupplyPatternsByDaysandSplitDays", strParams)
               strSupplyDescription = "No Description for This Supply Pattern"
               If Not rsSupplyPatterns.EOF Then
                  rsSupplyPatterns.MoveFirst
                  strSupplyDescription = RtrimGetField(rsSupplyPatterns!Description)
               End If
               rsSupplyPatterns.Close
               Set rsSupplyPatterns = Nothing
               Heap 10, gPRNheapID, "SupplyPattern", strSupplyDescription, 0
               Heap 10, gPRNheapID, "SupplyLength", Format$(intSupplyLength), 0
               Heap 10, gPRNheapID, "SupplyLengthDay", Format$(intSupplyLength) & " days", 0
               
               Heap 10, gPRNheapID, "RequiredDate", m_strRequiredDate, 0
               
               intInstrs = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicineSchedule", "N", "Instructions", 0))
               intWarnings = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicineSchedule", "N", "Warnings", 0))
               intItemsPerPage = Val(TxtD$(dispdata$ & "\PATMED.INI", "MedicineSchedule", "5", "ItemsPerPage", 0))
               
               strLayout = TxtD(dispdata$ & "\PATMED.INI", "MedicineSchedule", "\wksheets\dispsch.rtf", "LayoutName", 0)
               intCopies = Val(TxtD(dispdata$ & "\PATMED.INI", "MedicineSchedule", "1", "PrintCopies", 0))
               intPreview = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "MedicineSchedule", "N", "Preview", 0))
               
               'get Week Commencing date based on Today's date '23Mar11 TH Still support this.
               today dteWC
               'dteWC.mint = dteWC.mint - ((DayOfWeek(dteWC) - 1) * 1440)   '1140 mins in a day!     '15Apr02 TH Added to ensure correct date
               dteWC.mint = dteWC.mint - ((DayOfWeek(dteWC) - 1) * 1440) + 10080                     '     "
               minstodate dteWC
               DateToString dteWC, strWkComm
            
               'if the path supplied is relative, add the dispdata path to it
               If InStr(strLayout, ":") = 0 Then
                  If Left$(strLayout, 1) <> "\" Then
                     strLayout = dispdata$ & "\" & strLayout
                  Else
                     strLayout = dispdata$ & strLayout
                  End If
               End If
            
               'ensure that the In-Layout supplied exists      '26Sep01 JN made use of improved error reporting
               'If Not fileexists(strLayout) Then
               If Not RTFExistsInDatabase(strLayout) Then '12Apr17 TH Replaced call as rtf is now in the DB (TFS 180854)
                  io_strErrMsg = io_strErrMsg & crlf & "The RTF layout path supplied '" & strLayout & "' doesn't exist." & crlf & "Schedule print failed."
                  strBatchNotes = strBatchNotes & crlf & ">>>>> Error with Medicine Schedule" & crlf
                  strBatchNotes = strBatchNotes & io_strErrMsg & crlf       '** tidy for printing
                  success = False
                  GoTo ProcessBatchPatientExit
               End If
               
               success = GetPatientByPK(RepeatDispensingPatientID, WPat)
               Set XMLelement = PatientXML.selectSingleNode("Dispensing")
               RepeatDispensingDispensingID = XMLelement.getAttribute("RequestID")
               RepeatDispensingPrescriptionID = XMLelement.getAttribute("PrescriptionID")
               'success = RptDispGetPatient(RepeatDispensingPrescriptionID, RepeatDispensingDispensingID, strBatchNotes, 0) '17Jul12
               lngEpisodeID = Val(PatientXML.getAttribute("EpisodeID")) '18Jul12 TH Added
               success = RptDispGetPatient(RepeatDispensingPrescriptionID, RepeatDispensingDispensingID, strBatchNotes, lngEpisodeID) '17Jul12 TH Added
               
               'OK Now we can get the actual rpt Disp stuff which oddly isnt done above !
               strParams = gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, RepeatDispensingPatientID)
               Set rsRptDispPatient = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyPatientByEntityID", strParams)
               strAdditionalinformation = ""
               If Not rsRptDispPatient.EOF Then
                  rsRptDispPatient.MoveFirst
                  strAdditionalinformation = RtrimGetField(rsRptDispPatient!Additionalinformation)
               End If
               rsRptDispPatient.Close
               Set rsSupplyPatterns = Nothing
               ' Now put on heap
               Heap 10, gPRNheapID, "pAdditionalInfo", strAdditionalinformation, 0
               
               clearsup udtSup
               getsupplier pid.ward, 0, 0, udtSup
               FillHeapSupplierInfo gPRNheapID, udtSup, 0
               
               strWkComm = "We need To get This for the schedule"
               Heap 10, gPRNheapID, "wkcommdate", strWkComm, 0
               
               'This should go through the XML and put all labels there onto the heap (using numeric suffixes).
               ScheduleLabelsToHeap PatientXML, pid.recno, intInstrs, intWarnings, io_strErrMsg, intLabelCount, intSupplyLength, intSupplyPatternDays, intSupplyPatternSplitDays
               
               If intLabelCount > 0 Then
                  'create an RTF document based on the layout supplied
                  strOutLayout = ""    '20Sep01 JN just for safety - hasn't been used yet
                  BuildMedicineSchedule intLabelCount, intItemsPerPage, strLayout, strOutLayout
                                    
                  'retrieve the files created
                  intFiles = Val(Left$(strOutLayout, InStr(strOutLayout, "|") - 1))
                  ReDim strRTF(1 To intFiles)
                  deflines Mid$(strOutLayout, InStr(strOutLayout, "|") + 1), strRTF(), "|", 1, intFiles
   
                  'print the RTFs
                  For intRTF = 1 To intFiles
                     'add the page number to the heap
                     Heap 10, gPRNheapID, "page", Format$(intRTF), 0
                     Heap 10, gPRNheapID, "TotalPages", "Page " & Format$(intRTF) & " of " & Format$(intFiles), 0    '20Jan05 TH Added (enh76690)
                     'parse the document ready for printing
                     strParsedFile = ""                           '04Oct01 JN Added this section
                     parseRTF strRTF(intRTF), strParsedFile
                     If Len(strParsedFile) > 0 Then
                        Kill strRTF(intRTF)
                        strRTF(intRTF) = strParsedFile         '04Oct01 JN Replace the original file with the parsed version
                     End If
                     'if previews have been requested, open HighEdit for editing    '04Oct01 JN Added this section
                     If intPreview Then
                        Hedit 11, strRTF(intRTF)
                     End If
                     'parse the document again, just in case parseable amendments have been made in preview mode   '04Oct01 JN Added this section
                     'ParseThenPrint "MEDSCHED", strRTF(intRTF), intCopies, 0, False '28Jul11 TH Added param
                     ParseThenPrint "MEDSCHED", strRTF(intRTF), intCopies, 0, False, True '05Jan17 TH Here we are using local files
                     Kill strRTF(intRTF)
                  Next
   
                  'erase the RTF Array
                  Erase strRTF
                  SetupPRNHeap True, 0  '
               End If
            
            '04May11 TH DORIS Now another seperate section for Batch requirements report
            ElseIf RepeatDispensingMode() = "R" Then
               intSupplyLength = PatientXML.getAttribute("SupplyLength")
               If Not IsNull(PatientXML.getAttribute("SupplyPatternDays")) Then
                   intSupplyPatternDays = PatientXML.getAttribute("SupplyPatternDays")
                   'If intSupplyPatternDays = 0 Then intSupplyPatternDays = 7 '31July09 TH Added - default to week ?? '30Oct09 TH REmoved as these should be handled as single shot ??
               End If
               If Not IsNull(PatientXML.getAttribute("SupplyPatternSplitDays")) Then
                  intSupplyPatternSplitDays = PatientXML.getAttribute("SupplyPatternSplitDays")
               End If
               io_strErrMsg = ""
               ConstructBatchArray PatientXML, pid.recno, io_strErrMsg, intSupplyLength, intSupplyPatternDays, intSupplyPatternSplitDays
               If Trim$(io_strErrMsg) <> "" Then
                  'OK Here we have failed to process a patient either fully or in part. We need to bubble this and set flags. Back out ??? Yes should be very rare
                  strBatchNotes = strBatchNotes & crlf & ">>>>> Error with Requirements Report" & crlf
                  strBatchNotes = strBatchNotes & io_strErrMsg & crlf       '** tidy for printing
                  success = False
               End If
            Else
               '23Mar11 TH "Normal" Previous way for "I" Issuing and "L" Labelling
               
               lngEpisodeID = Val(PatientXML.getAttribute("EpisodeID")) '26Jul12 TH Moved form below
               
               For Each XMLelement In PatientXML.selectNodes("Dispensing")
                  
                  If LCase(XMLelement.getAttribute("InUse")) = "true" Or XMLelement.getAttribute("InUse") = "1" Then  '07Jun11 TH (F0119656)
                     RepeatDispensingPatientID = PatientXML.getAttribute("EntityID")
                     intSupplyLength = PatientXML.getAttribute("SupplyLength")
                     If Not IsNull(PatientXML.getAttribute("SupplyPatternDays")) Then
                     intSupplyPatternDays = PatientXML.getAttribute("SupplyPatternDays")
                     'If intSupplyPatternDays = 0 Then intSupplyPatternDays = 7 '31July09 TH Added - default to week ?? '30Oct09 TH REmoved as these should be handled as single shot ??
                     End If
                     If Not IsNull(PatientXML.getAttribute("SupplyPatternSplitDays")) Then
                        intSupplyPatternSplitDays = PatientXML.getAttribute("SupplyPatternSplitDays")
                     End If
                     
                     If m_lng_eMMNumberofDays = 0 Then
                        m_lng_eMMNumberofDays = intSupplyLength '18Apr12 TH Added
                        blnPatientSpecificeMMDays = True '27Apr12 TH Added
                     End If
                     
                     strParams = gTransport.CreateInputParameterXML("Days", trnDataTypeint, 4, intSupplyPatternDays) & _
                                 gTransport.CreateInputParameterXML("SplitDays", trnDataTypeint, 4, intSupplyPatternSplitDays)
                     Set rsSupplyPatterns = gTransport.ExecuteSelectSP(g_SessionID, "pRepeatDispensingSupplyPatternsByDaysandSplitDays", strParams)
                     strSupplyDescription = "No Description for This Supply Pattern"
                     If Not rsSupplyPatterns.EOF Then
                        rsSupplyPatterns.MoveFirst
                        strSupplyDescription = RtrimGetField(rsSupplyPatterns!Description)
                     End If
                     rsSupplyPatterns.Close
                     Set rsSupplyPatterns = Nothing
                     m_eMMSupplyDescription = strSupplyDescription
                     
                     success = ProcessBatchDispensing(RepeatDispensingBatchID, RepeatDispensingPatientID, XMLelement, strBatchNotes, intSupplyLength, intSupplyPatternDays, HasRobot, blnLabelsPrinted, intReportChan, blnprintReport, intSupplyPatternSplitDays, lngEpisodeID)
                     If Not success Then
                        '** decide if carry on or quit
                     End If
                     If CancelIsRequested() Then
                        '** quit and bubble up without completion
                     End If
                     If blnPatientSpecificeMMDays Then m_lng_eMMNumberofDays = 0 '27Apr12 TH Added
                  End If
               Next
               
               'TH Bag Labels - if we are here and we have printed labels below then we print a bag label if required. '29Oct09 TH Moved from inside For loop
               'If blnLabelsPrinted And (Val(PatientXML.getAttribute("BagLabels")) > 0) Then
               If blnLabelsPrinted And (m_intBagLabels > 0) Then '30May11 TH Replaced Above
                     'lngEpisodeID = Val(PatientXML.getAttribute("EpisodeID")) '18Jul12 TH Added '26Jul12 TH Moved above
                     success = RptDispGetPatient(0, 0, strBatchNotes, lngEpisodeID) '17Jul12 TH Added

                     'Load the new episode here
                     'For intloop = 1 To Val(PatientXML.getAttribute("BagLabels"))
                     For intloop = 1 To m_intBagLabels  '30May11 TH Replaced Above
                        patlabel k, pid, True, 3      '07Jun99 SF changed last parameter from 1 to 3
                     Next
      
               End If
               
            End If
         Else
            strBatchNotes = strBatchNotes & "Patient ID not supplied" & crlf
            success = False
         End If
      'Else
      'Patient is not in use - any code needed here can be added, at present no action taken, just skip
      End If
   End If

ProcessBatchPatientExit:
   On Error Resume Next
   Set xmlnode = Nothing
   Set XMLelement = Nothing
   On Error GoTo 0
   ProcessBatchPatient = success

Exit Function

ProcessBatchPatientError:
   success = False
   strBatchNotes = strBatchNotes & ">>>>> Error: " & Err.Number & " " & "Source: " & Source & " " & Err.Description
Resume ProcessBatchPatientExit

End Function


Private Function ProcessBatchDispensing(ByVal RepeatDispensingBatchID As Long, _
                                    ByVal RepeatDispensingPatientID As Long, _
                                    ByVal DispensingXML As MSXML2.IXMLDOMElement, _
                                    ByRef strBatchNotes As String, _
                                    ByVal intSupplyLength As Integer, _
                                    ByVal intSupplyPatternDays As Integer, _
                                    ByVal HasRobot As Boolean, _
                                    ByRef blnLabelsPrinted As Boolean, _
                                    ByVal intReportChan As Integer, _
                                    ByVal blnprintReport As Boolean, _
                                    ByVal intSupplyPatternSplitDays As Integer, _
                                    ByVal lngEpisodeID As Long) As Boolean
'Process a single dispensing, as defined in DispensingXML
'26Jul12 TH Added Episode param in order to "overlay" with active episode

Dim success As Boolean
Dim RepeatDispensingPrescriptionID As Long
Dim RepeatDispensingDispensingID As Long
Dim NSVCode As String
Dim xmlnode As MSXML2.IXMLDOMElement
Dim XMLelement As MSXML2.IXMLDOMElement
Dim sglRepeatDispensingQuantity As Single
Dim blnRobotItem As Boolean
Dim strDescription As String
Dim strErrDescription As String
Dim lngPatientEpisodeID As Long  '26Jul12 Th Added to allow either approach
Dim intTotalRepeats As Integer
Dim intRepeatsRemaining As Integer
Dim strPrescriptionExpiry As String

Const Source = "ProcessBatchDispensing"


   On Error GoTo ProcessBatchDispensingError
   DoSaferEvents 1  '14Jul09 TH Added
   success = True
   For Each xmlnode In DispensingXML.selectNodes("ValidationError")
      'Here Again we need to stop only if it is a genuine "stopper" error
      'strException =
      If Val(Iff(IsNull(xmlnode.getAttribute("Exception")), "", xmlnode.getAttribute("Exception"))) = 1 Then
         success = False  '02Nov09 TH Added
         strBatchNotes = strBatchNotes & crlf & ">>>>> Dispensing not processed" & crlf
      Else
         strBatchNotes = strBatchNotes & crlf & ">>>>> Dispensing warning" & crlf
      End If
      strErrDescription = xmlnode.getAttribute("ErrorMessage")
      strDescription = xmlnode.getAttribute("KeyValue")
      'strBatchNotes = strBatchNotes & xmlnode.xml & crlf       '**  tidy for printing
      strBatchNotes = strBatchNotes & strDescription & " : Error = " & strErrDescription & crlf       '** tidy for printing
   Next
   
   If success Then
      RepeatDispensingDispensingID = DispensingXML.getAttribute("RequestID")
      If RepeatDispensingDispensingID > 0 Then                'potentially valid dispensing
         RepeatDispensingPrescriptionID = DispensingXML.getAttribute("PrescriptionID")
         sglRepeatDispensingQuantity = DispensingXML.getAttribute("RepeatDispensingQuantity")
         intTotalRepeats = CInt(DispensingXML.getAttribute("RepeatTotal"))
         intRepeatsRemaining = CInt(DispensingXML.getAttribute("RepeatRemaining"))
         strPrescriptionExpiry = DispensingXML.getAttribute("PrescriptionExpiry")
         Set xmlnode = DispensingXML.selectSingleNode("Drug")
         NSVCode = xmlnode.getAttribute("NSVCode")
         
         '02Nov09 TH Added
         'Set xmlnode = DispensingXML.selectSingleNode("Drug")
         For Each xmlnode In xmlnode.selectNodes("ValidationError")  'handle batch errors here
            'We should only fail now for real errors
            If Val(Iff(IsNull(xmlnode.getAttribute("Exception")), "", xmlnode.getAttribute("Exception"))) = 1 Then
               success = False  '02Nov09 TH Added
               strBatchNotes = strBatchNotes & crlf & ">>>>> Drug not processed" & crlf
            Else
               strBatchNotes = strBatchNotes & crlf & ">>>>> Drug warning" & crlf
            End If
            strErrDescription = xmlnode.getAttribute("ErrorMessage")
            strDescription = xmlnode.getAttribute("KeyValue")
            'strBatchNotes = strBatchNotes & xmlnode.xml & crlf       '**  tidy for printing
            strBatchNotes = strBatchNotes & strDescription & " : Error = " & strErrDescription & crlf       '** tidy for printing
         Next
         '----------------
         
         
         blnRobotItem = False
         On Error Resume Next
         Set xmlnode = DispensingXML.selectSingleNode("RobotItem")
         blnRobotItem = Iff(xmlnode.getAttribute("Value") = "1", True, False)
         HasRobot = blnRobotItem  '19Jul09 TH
         If blnRobotItem Then m_blnRobotItem = True
         On Error GoTo ProcessBatchDispensingError
         'HasRobot = HasRobot & blnRobotItem
         
         
         Dim WPat As WPatient
         success = GetPatientByPK(RepeatDispensingPatientID, WPat)
         If TrueFalse(TxtD(dispdata$ & "\RptDisp.ini", "", "Y", "UseActiveEpisode", 0)) Then
            lngPatientEpisodeID = lngEpisodeID
         Else
            lngPatientEpisodeID = 0
         End If
         
         success = RptDispGetPatient(RepeatDispensingPrescriptionID, RepeatDispensingDispensingID, strBatchNotes, lngPatientEpisodeID) '17Jul12 TH Added '26Jul12 TH send through active episode if so required
         
'++++++++++++++++
         success = RepeatDispenseItem(RepeatDispensingBatchID, strBatchNotes, intSupplyLength, sglRepeatDispensingQuantity, intSupplyPatternDays, HasRobot, blnLabelsPrinted, intReportChan, blnprintReport, intSupplyPatternSplitDays, intTotalRepeats, intRepeatsRemaining, strPrescriptionExpiry)
         
'++++++++++++++++
      Else
         strBatchNotes = strBatchNotes & "Patient ID not supplied" & crlf
         success = False
      End If
   End If

ProcessBatchDispensingExit:
   On Error Resume Next
   Set xmlnode = Nothing
   Set XMLelement = Nothing
   On Error GoTo 0
   ProcessBatchDispensing = success

Exit Function

ProcessBatchDispensingError:
   success = False
   strBatchNotes = strBatchNotes & ">>>>> Error: " & Err.Number & " " & "Source: " & Source & " " & Err.Description
Resume ProcessBatchDispensingExit

End Function

Function RepeatDispenseItem(ByVal RepeatBatchID As Long, _
                            ByRef strBatchNotes As String, _
                            ByVal intSupplyLength As Integer, _
                            ByVal sglRepeatDispensingQuantity As Single, _
                            ByVal intSupplyPatternDays As Integer, _
                            ByVal HasRobot As Boolean, _
                            ByRef blnLabelsPrinted As Boolean, _
                            ByVal intReportChan As Integer, _
                            ByVal blnprintReport As Boolean, _
                            ByVal intSupplyPatternSplitDays As Integer, _
                            ByVal intTotalRepeats As Integer, _
                            ByVal intRepeatsRemaining As Integer, _
                            ByVal strPrescriptionExpiry As String) As Boolean
'24jun09 CKJ Repeat Dispensing main routine. Returns success T/F.
'            Once a patient, episode, prescription and dispensing are in scope,
'            do the labelling (and ADM file) or issue.
'            OCX UI becomes inactive, does the processing and goes inactive on exit
'          NOTES
'            gRequestID_Dispensing must be valid and non zero when calling
'            PCT workaround not supported
'

'TH NOTES
'v8 containersize was qty per issue . Is now RepeatDispensingQuantity from Dispensing node in XML
'v* Interval = SupplyLength ??
'Can only work to patients current ward ???
'05Mar10 TH Send the recno through to translog NOT casenumber ! (F0079598)
'07Mar11 TH Replace case statement to remove factoring of dose for items with issue unit mls as this seems superfluous (F00109625)
'07Mar11 TH Ensure the MTS batch number is sent through correctly to the output file (F00109180)
'13May11 TH Ensure support for lblcnt element (F0116290)
'22Aug11 TH Update other label fields when issuing (TFS11472)
'15Feb13 XN Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'18Aug13 TH Added Extra params and mods to support DoC repeat dispensing (TFS 70134)
'06Jan16 TH Ensure decrement is against label NOT the Rx (TFS 138797)

Dim success As Boolean
Dim msg As String
Dim lngDrugFound As Long
Dim sglDosesperissueunit As Single
Dim sglNumDoses As Single
Dim intloop As Integer
'Dim blnOneOrMoreDaysSet As Boolean
Dim intLabels As Integer
'Dim Qty! As Single
Dim sqlTotQty As Single
Dim blnIssueStock As Boolean
Dim strIssueType As String
Dim strExpiry As String
Dim intValid As Integer
Dim strTemp As String
Dim blnSuccess As Boolean
Dim MTSConfirm As MTSConfirmType
'Dim PackerSection As String
Dim UnfactoredTotQty As Single
'Dim lngMTSNo As Long
Dim strPrintPatient As String
Dim strPrintNoPatient As String
Dim strPrintItem As String
Dim strPrintNoItem As String
Dim strText As String
Dim sglSupplyQty As Single
Dim sglTotalSupplyQty As Single
Dim sglQtyCache As Single
Dim intSplitCount As Integer
Dim intTotalLabels As Integer    '13May11 TH (F0116290)
Dim intLabel As Integer          '  "
Dim strLblcnt As String          '  "
Dim JVMConfirm As JVMConfirmType
Dim blnJVDone As Boolean '13Jun11 TH Added flag
Dim lngOK As Long

Dim strParams As String '11Apr12 TH Added
Dim StrNumofDays As String '18Apr12 TH Added
Dim intRepeats As Integer  '18Aug13 TH Added (TFS 70134)
Dim patBillEscd As Integer

Const Source = "RepeatDispenseItem"

   On Error GoTo RepeatDispenseItemError

    blnJVDone = False '13Jun11 TH Added flag

   DoSaferEvents 1 '14Jul09 TH Added
   'UserControlEnable True
   'SetOCXDetailsSize
   'SetupRepeatDispensForm    'ensure OCX data is visible
   'SetOCXdetails       'display data
   success = True
   Labf& = gRequestID_Dispensing                         'requestid for dispensing which is currently in use
   getlabel Labf&, L, False

   If L.SiteID <> gDispSite Then
      success = False

      msg = "Previously dispensed from " & GetSiteDescription(L.SiteID) & ". Cannot redispense from current site"
      '-----lblStatus(0).Caption = msg
      strBatchNotes = strBatchNotes & cr & msg
   Else
      
      'HERE
      BlankWProduct d
      d.SisCode = L.SisCode
      'getdrug d, 0, lngDrugFound, True   '24May11 CKJ Changed to non-locked
      getdrug d, 0, lngDrugFound, False   '   "
      
      FillHeapLabelInfo gPRNheapID, L, 0
      FillHeapDrugInfo gPRNheapID, d, 0
      
      'set the repeat dispensing stuff for the label here, we also need to increment the batchnumber (as if it has been incremented by issue)
      If intTotalRepeats > 0 Then
         intRepeats = intTotalRepeats - intRepeatsRemaining
         setRepeatNumber intRepeats + 1
         setTotalRepeats intTotalRepeats
      End If
      setRptPrescriptionExpiry strPrescriptionExpiry
      If Not TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "BillPatient", 0)) Then
         L.batchnumber = L.batchnumber + 1
      Else                                                                                            '19Mar03 TH (PBSv4) Added  to allow
         If PBSSwitchedOff() Then L.batchnumber = L.batchnumber + 1                                   '    "      PBS to be set up but switched off
      End If
      patBillEscd = billpatient(1, "")

      'strPrintPatient = TxtD$(dispdata$ & "\PATMED.INI", "RepeatDispensing", "[rptIss]" & Trim$(pid.ward) & " \tab " & Trim$(pid.caseno) & " \tab " & Left$(pid.forename, 1) & " " & Trim$(pid.surname), "PrintPatient", 0)
      strPrintPatient = TxtD$(dispdata$ & "\PATMED.INI", "RepeatDispensing", Trim$(pid.ward) & " \tab " & Trim$(pid.caseno) & " \tab " & Left$(pid.forename, 1) & " " & Trim$(pid.surname), "PrintPatient", 0)
      strPrintNoPatient = TxtD$(dispdata$ & "\PATMED.INI", "RepeatDispensing", " \tab \tab", "PrintNoPatient", 0)
      strPrintItem = TxtD$(dispdata$ & "\PATMED.INI", "RepeatDispensing", "[tab][iNSVCode][tab][iDescription][tab][RptDispQuantity] [iPrintform][tab][RptDispQuantityIssued][cr]", "PrintItem", 0)
      strPrintNoItem = TxtD$(dispdata$ & "\PATMED.INI", "RepeatDispensing", " \tab " & L.SisCode & " \tab *** Cannot find in the drug file *** \par ", "PrintNoItem", 0)
     
      If lngDrugFound = 0 Then
''         If Val(ipdlist.ChkBookout.Value) = 1 Then
         If blnprintReport And (RepeatDispensingMode() = "I") Then
            If Trim$(strText) = "" Then
               strText = strPrintPatient & strPrintNoItem
            Else
               strText = strText & strPrintNoPatient & strPrintNoItem
            End If
         End If
         success = False
         'ADD SOME BATCH NOTES
''         End If
''         If InStr(UCase$(Command$), "/DEBUG") > 0 Then popmessagecr "#Repeat Dispensing", "Cannot find NSV Code: " & L.SisCode
      Else

         If HasRobot And m_PackerType = "JVADTPS" Then      '24May11 CKJ JVM handling us separate from manual & MTS
            'patient, label & drug already loaded
            '!!** check if patient on heap yet
            BlankJVMConfirmType JVMConfirm
            JVMConfirm.startdate = m_strJVMStartDate
            JVMConfirm.StartSlot = intJVMStartSlot
            JVMConfirm.SlotsToRun = intJVMTotalSlots
            JVMConfirm.SlotSelected(1) = blnJVMBreakfast
            JVMConfirm.SlotSelected(2) = blnJVMLunch
            JVMConfirm.SlotSelected(3) = blnJVMTea
            JVMConfirm.SlotSelected(4) = blnJVMNight
            If IsItemForJVMPacker(m_PackerSection, JVMConfirm) Then
               If RepeatDispensingMode() = "L" Then
                  JVMAppendData m_PackerSection, JVMConfirm
                  blnJVDone = True '13Jun11 TH Added flag as we dont need to do anything else now
                  blnLabelsPrinted = True '16Jun11 TH Except flag we might need a bag label (F0120601)
               Else
                  sqlTotQty = JVMCalculateDoses(m_PackerSection, JVMConfirm)
               End If
            End If
            
         Else  ' MTS or manual
   
            sglDosesperissueunit = d.dosesperissueunit
            If sglDosesperissueunit = 0 Then sglDosesperissueunit = 1
            sglNumDoses = 0
            For intloop = 1 To 6
   ''            Ldose!(intLoop) = L.dose(intLoop)
               If L.dose(intloop) > 0 Then
                  'Select Case Trim$(UCase$(d.PrintformV))
                  '   Case "ML": sglNumDoses = sglNumDoses + (L.dose(intloop) / sglDosesperissueunit)
                  '   Case Else: sglNumDoses = sglNumDoses + L.dose(intloop)
                  'End Select
                  sglNumDoses = sglNumDoses + L.dose(intloop) '07Mar11 TH Replace above case statement (F00109625)
               End If
            Next
            
            'If sglNumDoses = 0 Then sglNumDoses = 1      24May11 CKJ removed - if total is zero then no dose should be given
            '!!** set errorcode??
            
   ''         For intloop = 1 To 7
   ''            L.days(iLoop) = GetField(rs.Fields("Day" & daynames(iLoop - 1)))
   ''            If L.days(intloop) Then blnOneOrMoreDaysSet = True                     '28Oct05 CKJ set to True
   ''         Next
   ''         asciiday% = Asc(L.days)
   ''         If d.dosesperissueunit = 0 Then
   ''            Qty! = 1
   ''            intLabels = sglRepeatDispensingQuantity
   ''            sqlTotQty = sglRepeatDispensingQuantity
   ''''         ElseIf asciiday% = 0 Then
   ''         Else
            If sglRepeatDispensingQuantity > 0 Then
            'If sglRepeatDispensingQuantity > 0 Or intSupplyPatternDays = 0 Then '29Oct09 POSS ???
               'here the whole qty is on one label
               sqlTotQty = sglRepeatDispensingQuantity
               UnfactoredTotQty! = sglRepeatDispensingQuantity
               intLabels = 1
               Qty! = sqlTotQty
               sglTotalSupplyQty = sqlTotQty
               '06Jul09 TH Added check to limit label to pack qty.
   ''            If TrueFalse(TxtD(dispdata$ & "\RptDisp.ini", "", "Y", "RepeatDispensingPackLimitforLabels", 0)) Then
   ''               If Qty! > d.convfact Then
   ''                  Qty! = d.convfact
   ''                  intLabels = (sqlTotQty \ (d.convfact))
   ''                  If sqlTotQty Mod (d.convfact) > 0 Then intLabels = intLabels + 1
   ''               End If
   ''            End If
               '----------
            ElseIf intSupplyLength > 0 Then
               'OK the supply length will now dictate the quantity and number of labels requried
               'intSupplyPatternDays
               If intSupplyPatternDays = 0 Then intSupplyPatternDays = intSupplyLength  '30Oct09 TH
               sqlTotQty = sglNumDoses * intSupplyLength
               sglTotalSupplyQty = sglNumDoses * intSupplyLength  '30Oct09 TH Added
               UnfactoredTotQty! = sqlTotQty
               'If intSupplyPatternDays = 0 Then
               '   intLabels = 1
               'Else
                  intLabels = (sqlTotQty / (sglNumDoses * intSupplyPatternDays)) 'sglRepeatDispensingQuantity
               'End If
               If sqlTotQty < sglNumDoses Then   '07Jun99 SF
                  intLabels = 1
                  Qty! = sglRepeatDispensingQuantity
                  sqlTotQty = sglRepeatDispensingQuantity     '07Jun99 SF added
               Else
                  If sqlTotQty Mod (sglNumDoses * intSupplyPatternDays) > 0 Then intLabels = intLabels + 1
                  Qty! = (sglNumDoses * intSupplyPatternDays)
   ''               '06Jul09 TH Added check to limit label to pack qty.
   ''               If TrueFalse(TxtD(dispdata$ & "\RptDisp.ini", "", "N", "RepeatDispensingPackLimitforLabels", 0)) Then
   ''                  If Qty! > d.convfact Then
   ''                     Qty! = d.convfact
   ''                     intLabels = (sqlTotQty \ (d.convfact))
   ''                     If sqlTotQty Mod (d.convfact) > 0 Then intLabels = intLabels + 1
   ''                  End If
   ''               End If
               End If
            End If
            
         End If '13Jun11 TH - JVM back in equation
            
            
            
   ''         ElseIf Not blnOneOrMoreDaysSet Then
   ''            sqlTotQty = sglNumDoses * intSupplyLength
   ''            intLabels = sqlTotQty \ sglRepeatDispensingQuantity
   ''            If sqlTotQty < sglRepeatDispensingQuantity Then   '07Jun99 SF
   ''               intLabels = 1
   ''               Qty! = sglRepeatDispensingQuantity
   ''               sqlTotQty = sglRepeatDispensingQuantity     '07Jun99 SF added
   ''            Else
   ''               If sqlTotQty Mod sglRepeatDispensingQuantity > 0 Then intLabels = intLabels + 1
   ''               Qty! = sglRepeatDispensingQuantity
   ''            End If
   ''         Else
   ''            intLabels = 0
   ''            For intloop = 7 To 1 Step -1
   ''''               If asciiday - (2 ^ i) >= 0 Then
   ''''                     asciiday = asciiday - 2 ^ i
   ''''                     labels% = labels% + 1
   ''''                  End If
   ''               If L.days(intloop) Then intLabels = intLabels + 1
   ''            Next
   ''            If intLabels = 0 Then intLabels = 1
   ''            sqlTotQty = sglNumDoses * ((intSupplyLength / 7) * intLabels)
   ''            intLabels = sqlTotQty \ sglRepeatDispensingQuantity
   ''            If sqlTotQty < sglRepeatDispensingQuantity Then   '07Jun99 SF
   ''               intLabels = 1
   ''               Qty! = sqlTotQty
   ''               sqlTotQty = sglRepeatDispensingQuantity     '07Jun99 SF added
   ''            Else
   ''               If sqlTotQty Mod sglRepeatDispensingQuantity > 0 Then intLabels = intLabels + 1
   ''               Qty! = sglRepeatDispensingQuantity
   ''            End If
   ''         End If
         If Not blnJVDone Then '13Jun11 TH Added
            If TrueFalse(TxtD$(dispdata$ & "\PATMED.INI", "", "N", "NoNegIssues", 0)) Then
               ' check if enough stock to issue
               If lngDrugFound > 0 Then            '01Jun02 All/CKJ was found%
                  If Val(d.stocklvl) - sqlTotQty < 0 Then
                     blnIssueStock = False
                  Else
                     blnIssueStock = True
                  End If
               Else
                  blnIssueStock = False
               End If
            Else
               blnIssueStock = True
            End If
            
            'putdrug d ', -lngDrugFound   '24May11 CKJ removed. should unlock, not write.
                                                            
            'If m_RepeatDispensingMode = "L" And status$ = "D" And blnIssueStock = True Then
            If RepeatDispensingMode() = "L" And blnIssueStock = True Then
               ' print the label(s)
               blnLabelsPrinted = True       ' 13Aug99 SF a label has been printed so a bag label may be printed at the end
                                                                              '25Jan08 CKJ Check if item is for robot or normal labels
               blnSuccess = False
               If HasRobot Then
                  BlankMTSConfirmType MTSConfirm
                  blnSuccess = IsItemForMTSPacker(Val(m_PackerSection), MTSConfirm)
                  '''****If PatientForPacking = "L" Then blnSuccess = False '21Feb08 TH Added
               End If
               If blnSuccess Then                                                      'output data for MTS
                  'MTSAppendData PackerSection, MTSConfirm, interval, sqlTotQty, UnfactoredTotQty!, lngMTSNo  '21Feb08 TH Added new params
                  'MTSAppendData m_PackerSection, MTSConfirm, intSupplyLength, sqlTotQty, UnfactoredTotQty!, lngMTSNo  '21Feb08 TH Added new params
                  MTSAppendData m_PackerSection, MTSConfirm, intSupplyLength, sqlTotQty, UnfactoredTotQty!, MTSNo()  '07Mar11 TH (F00109180)
               Else
                  sglQtyCache = Qty!
                  '''For intloop = 1 To intLabels 'This is now really just the number of supplys required.
                     sglSupplyQty = sglTotalSupplyQty
                     Qty! = sglQtyCache
                     intSplitCount = 1
                     
                     '13May11 TH OK, its not neat, but to support the lblcnt elements we have to predetermine the total num of labels (F0116290)
                     intTotalLabels = 0
                     Do While sglSupplyQty > 0
                        'Do day split here 'but only if no qty override
                        If sglRepeatDispensingQuantity = 0 Then
                           If intSupplyPatternSplitDays > 0 Then
                              If intSplitCount Mod 2 = 1 Then
                                 Qty! = sglNumDoses * intSupplyPatternSplitDays
                              Else
                                 Qty! = sglNumDoses * (7 - intSupplyPatternSplitDays)
                              End If
                           End If
                        End If
                        intSplitCount = intSplitCount + 1
                        If Qty! > sglSupplyQty Then Qty! = sglSupplyQty '19Jul09 TH moved from above as this needs doing after any split (on second + pass)
                        If TrueFalse(TxtD(dispdata$ & "\RptDisp.ini", "", "Y", "RepeatDispensingPackLimitforLabels", 0)) Then
                           If Qty! > d.convfact Then
                              Qty! = d.convfact
                              intSplitCount = intSplitCount - 1
                           End If
                        End If
                        sglSupplyQty = sglSupplyQty - Qty!
                        intTotalLabels = intTotalLabels + 1
                     Loop
                     
                     'Now reset the variables for the actual label run (F0116290)
                     
                     sglSupplyQty = sglTotalSupplyQty
                     Qty! = sglQtyCache
                     intLabel = 1
                     
                     Do While sglSupplyQty > 0
                        'If Qty! > sqlTotQty Then Qty! = sqlTotQty
                        
                        'Do day split here 'but only if no qty override
                        If sglRepeatDispensingQuantity = 0 Then
                           If intSupplyPatternSplitDays > 0 Then
                              If intSplitCount Mod 2 = 1 Then
                                 Qty! = sglNumDoses * intSupplyPatternSplitDays
                              Else
                                 Qty! = sglNumDoses * (7 - intSupplyPatternSplitDays)
                              End If
                           End If
                        End If
                        intSplitCount = intSplitCount + 1
                        If Qty! > sglSupplyQty Then Qty! = sglSupplyQty '19Jul09 TH moved from above as this needs doing after any split (on second + pass)
                        If TrueFalse(TxtD(dispdata$ & "\RptDisp.ini", "", "Y", "RepeatDispensingPackLimitforLabels", 0)) Then
                           If Qty! > d.convfact Then
                              Qty! = d.convfact
                              intSplitCount = intSplitCount - 1
                           End If
                        End If
                        '13May11 TH prepare the lblcnt elements (F0116290)
                        If InStr(TxtD(dispdata$ & "\PATMED.INI", "", "", "LabelCount", 0), L.IssType) > 0 And intTotalLabels > 1 Then
                           strLblcnt = Trim$(Str$(intLabel)) & TxtD(dispdata$ & "\PATMED.INI", "", " of ", "LabelCountSeparator", 0) & Trim$(Str$(intTotalLabels)) & TxtD(dispdata$ & "\PATMED.INI", "", "", "LabelCountSuffix", 0)
                           strLblcnt = TxtD(dispdata$ & "\PATMED.INI", "", "", "LabelCountPrefix", 0) & strLblcnt     '05Jun02 TH Added possible prefix
                           Heap 10, gPRNheapID, "LblCnt", strLblcnt, 0
                        Else
                           Heap 10, gPRNheapID, "LblCnt", "", 0
                        End If
                        
                        DisplaytheLabel 1, 3, k, strExpiry, 0, False '07Jan13 TH Added Param
                        
                        intLabel = intLabel + 1 '13May11 TH (F0116290)
                        
                        sqlTotQty = sqlTotQty - Qty!
                        sglSupplyQty = sglSupplyQty - Qty!
                        
                     Loop
                  '''Next
               End If
                                                                  
            ElseIf RepeatDispensingMode() = "I" Then
               ' issue stock
               Qty! = sqlTotQty
               If blnIssueStock Then
                  strIssueType = L.IssType
                  If strIssueType = "S" Then strIssueType = "M"
                  setRepeatBatchID RepeatBatchID
                  'Translog d, lngDrugFound, UserID$, Trim$(pid.caseno), Qty!, L.dircode, ward$, pid.cons, pid.status, SiteNumber%, strIssueType, d.cost       '07Jun99 SF '01Jun02 All/CKJ was found%
                  'Translog d, lngDrugFound, UserID$, Trim$(pid.caseno), Qty!, L.dircode, pid.ward, pid.cons, pid.status, SiteNumber%, strIssueType, d.cost       '07Jun99 SF '01Jun02 All/CKJ was found%
                  
                  If m_blnMedsManagement Then '19Apr12 TH Moved block from below to ensure supply request predates the log entry (TFS 32294)
                     If m_blnJVADTPS Then
                        StrNumofDays = Format$(m_lng_eMMNumberofDays)
                     Else
                        StrNumofDays = Format$(m_lng_eMMNumberofDays) & " day" & Iff(m_lng_eMMNumberofDays > 1, "s", "") & " (" & m_eMMSupplyDescription & ")"
                     End If
                  
                     '11Apr12 TH Meds Management integration. Here we must add the meds management records
                     
                     strParams = gTransport.CreateInputParameterXML("NoteTypeDescription", trnDataTypeVarChar, 128, TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "EMMSupply", "NoteType", 0))
                     strParams = strParams & gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
                     strParams = strParams & gTransport.CreateInputParameterXML("LocationID", trnDataTypeint, 4, m_lng_eMMLocationID)
                     strParams = strParams & gTransport.CreateInputParameterXML("Comments", trnDataTypeVarChar, 30, m_str_eMMAdditionalInfo)
                     strParams = strParams & gTransport.CreateInputParameterXML("Priority", trnDataTypeBit, 1, m_bln_eMMPriority)
                     strParams = strParams & gTransport.CreateInputParameterXML("ascEMMDeliveryMethodID", trnDataTypeint, 4, m_lng_eMMDeliveryTypeID)
                     strParams = strParams & gTransport.CreateInputParameterXML("RequiredDate", trnDataTypeDateTime, 8, m_dte_eMMRequiredDate)
                     strParams = strParams & gTransport.CreateInputParameterXML("NumberOfDays", trnDataTypeVarChar, 50, StrNumofDays)
                     strParams = strParams & gTransport.CreateInputParameterXML("ComplianceAidRequired", trnDataTypeBit, 1, m_bln_eMMCompliance)
                     strParams = strParams & gTransport.CreateInputParameterXML("ascComplianceAidID", trnDataTypeint, 4, m_lng_eMMComplianceTypeID)
                     strParams = strParams & gTransport.CreateInputParameterXML("ComplianceAidStartDate", trnDataTypeVarChar, 30, m_str_eMMComplianceStartDate)
                     strParams = strParams & gTransport.CreateInputParameterXML("BatchDescription", trnDataTypeVarChar, 256, m_str_eMMBatchDescription)
                     strParams = strParams & gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Prescription)
                     lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "peMMSupplyInsertfromRptDispensing", strParams)
                     
                     If m_blnJVADTPS Then
                        If Trim$(TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "", "JVADTPOptionalsp", 0)) <> "" Then
                           strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Prescription)
                           lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "", "JVADTPOptionalsp", 0), strParams)
                        End If
                     Else
                        If Trim$(TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "", "Optionalsp", 0)) <> "" Then
                           strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Prescription)
                           lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "", "Optionalsp", 0), strParams)
                        End If
                     End If
                  
                  End If
                  
                  Translog d, lngDrugFound, UserID$, Trim$(pid.recno), Qty!, L.dircode, pid.ward, pid.cons, pid.status, SiteNumber%, strIssueType, d.cost  '05Mar10 TH Send the recno through NOT casenumber ! (F0079598)
                  setRepeatBatchID 0
                  L.Nodissued = dp!(L.Nodissued + Qty!)
                  '!!** review if this is appropriate - normally replaced with labelinissueunits
                  If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then
                     L.RxNodIssued = dp!(L.RxNodIssued + (Qty! * d.dosesperissueunit))
                  Else
                     L.RxNodIssued = dp!(L.RxNodIssued + Qty!)
                  End If
                  parsedate LastSavedDateTimeToLastDate(L.lastSavedDateTime), strTemp, "3", intValid '40210 XN 15Feb13 use proper date\time for WLabel      parsedate (L.lastdate), strTemp, "3", intValid
                  If Not intValid Or strTemp <> thedate(False, True) Then
                     L.lastqty = Qty!
                  Else
                     L.lastqty = dp!(L.lastqty + Qty!)
                  End If
                  L.lastSavedDateTime = Now  ' 40210 XN 15Feb13 use proper date\time for WLabel     L.lastdate = thedate(False, False)
                  '22Aug11 TH update other fields (TFS11472)
                  L.dispid = UserID$
                  L.wardcode = pid.ward
                  L.ConsCode = pid.cons
                  '------
                  
                  '18Aug13 TH Moved above as this also needs moving on for the label print for DoC
                  '15Aug13 TH Doc Do we need to utilise the batchnumber field here with the repeat number ?????
                  '16Aug13 This is standard behaviour in dispensing used by DoC that we now need in Rpt disp. (TFS 70134)
                  'If Not TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "BillPatient", 0)) Then
                  '   L.batchnumber = L.batchnumber + 1
                  'Else                                                                                            '19Mar03 TH (PBSv4) Added  to allow
                  '   If PBSSwitchedOff() Then L.batchnumber = L.batchnumber + 1                                   '    "      PBS to be set up but switched off
                  'End If
                  
                  If TrueFalse(TxtD$(dispdata$ & "\PATMED.INI", "RepeatDispensing", "N", "PatientDebug", 0)) Then WriteLog patdatapath$ & "\rptdisp.log", SiteNumber%, UserID$, "Loaded PatID:" & pid.recno & " Patient: " & Trim$(pid.caseno) & " " & Trim$(pid.forename) & " " & Trim$(pid.surname)    '07Jun99 SF added logging
                  Putlabel L
                  
                  
                  '14Aug13 TH If in DoC Mode then we must increment the repeat number here for this RepeatDispensingPrescriptionLinkDispensing record
                  If TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "AutoDecrementFromRptDisp", 0)) Then
                     'strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Prescription)
                     'lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pRepeatDispensingPrescriptionLinkDispensingDecrementRepeat", strParams)
                     '06Jan16 TH Ensure decrement is against lable NOT the Rx (TFS 138797)
                     strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Dispensing)
                     lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pRepeatDispensingPrescriptionLinkDispensingDecrementRepeatbyLabel", strParams)
                  End If
                  
                  '19Apr12 TH Moved above
'                  If m_blnMedsManagement Then
'                     If m_blnJVADTPS Then
'                        StrNumofDays = Format$(m_lng_eMMNumberofDays)
'                     Else
'                        StrNumofDays = Format$(m_lng_eMMNumberofDays) & " day" & Iff(m_lng_eMMNumberofDays > 1, "s", "") & " (" & m_eMMSupplyDescription & ")"
'                     End If
'
'                     '11Apr12 TH Meds Management integration. Here we must add the meds management records
'
'                     strParams = gTransport.CreateInputParameterXML("NoteTypeDescription", trnDataTypeVarChar, 128, TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "EMMSupply", "NoteType", 0))
'                     strParams = strParams & gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
'                     strParams = strParams & gTransport.CreateInputParameterXML("LocationID", trnDataTypeint, 4, m_lng_eMMLocationID)
'                     strParams = strParams & gTransport.CreateInputParameterXML("Comments", trnDataTypeVarChar, 30, m_str_eMMAdditionalInfo)
'                     strParams = strParams & gTransport.CreateInputParameterXML("Priority", trnDataTypeBit, 1, m_bln_eMMPriority)
'                     strParams = strParams & gTransport.CreateInputParameterXML("ascEMMDeliveryMethodID", trnDataTypeint, 4, m_lng_eMMDeliveryTypeID)
'                     strParams = strParams & gTransport.CreateInputParameterXML("RequiredDate", trnDataTypeDateTime, 8, m_dte_eMMRequiredDate)
'                     strParams = strParams & gTransport.CreateInputParameterXML("NumberOfDays", trnDataTypeVarChar, 50, StrNumofDays)
'                     strParams = strParams & gTransport.CreateInputParameterXML("ComplianceAidRequired", trnDataTypeBit, 1, m_bln_eMMCompliance)
'                     strParams = strParams & gTransport.CreateInputParameterXML("ascComplianceAidID", trnDataTypeint, 4, m_lng_eMMComplianceTypeID)
'                     strParams = strParams & gTransport.CreateInputParameterXML("ComplianceAidStartDate", trnDataTypeVarChar, 30, m_str_eMMComplianceStartDate)
'                     strParams = strParams & gTransport.CreateInputParameterXML("BatchDescription", trnDataTypeVarChar, 256, m_str_eMMBatchDescription)
'                     strParams = strParams & gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Prescription)
'                     lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "peMMSupplyInsertfromRptDispensing", strParams)
'
'                     If m_blnJVADTPS Then
'                        If Trim$(TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "", "JVADTPOptionalsp", 0)) <> "" Then
'                           strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Prescription)
'                           lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "", "JVADTPOptionalsp", 0), strParams)
'                        End If
'                     Else
'                        If Trim$(TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "", "Optionalsp", 0)) <> "" Then
'                           strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Prescription)
'                           lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, TxtD(dispdata$ & "\RptDisp.INI", "MedsManagement", "", "Optionalsp", 0), strParams)
'                        End If
'                     End If
'
'                  End If
                  
                  
                  
                  ' reset status flag after issuing
   ''               SQL$ = "UPDATE patid SET patid.repeatstatus = 'N' WHERE patid.patrecno = '" & Trim$(patid$) & "';"
   ''               PIDdb.Execute SQL$: FreeLocks                         '07Jun99 SF
               Else
               'Couldnt issue stock
               success = False
               'ADD SOME BATCH NOTES
               End If
   
               ' create to report line
   ''                                                                          ' create report line             '29Feb08 CKJ now uses heap
               If blnprintReport Then
                  If Trim$(strText) = "" Then
                    strText = strPrintPatient & strPrintItem
                  Else
                     strText = strText & strPrintNoPatient & strPrintItem
                  End If
                  Heap 10, gPRNheapID, "RptDispQuantity", Format$(Qty!), 0
                  'Heap 10, gPRNheapID, "RptIss", " ", 0
                  If blnIssueStock Then
                     Heap 10, gPRNheapID, "RptDispQuantityIssued", Format$(Qty!), 0
                     'If Qty! <> 0 Then Heap 10, gPRNheapID, "RptIss", "*", 0
                  Else
                     Heap 10, gPRNheapID, "RptDispQuantityIssued", "0", 0
                  End If
               End If
   
            End If
         End If   '24May11 CKJ end of MTS/manual handler '13Jun11 TH now this is fenceposted from the new blnJVDone flag '13Jun11 TH Added
      End If
      
      If blnprintReport Then
         ParseCtrlChars dispdata$ & "\printer.ini", "rtf", strText, False    '29Feb08 CKJ added
         ParseItems gPRNheapID, strText, False                                 '   "
         Print #intReportChan, strText
      End If
      '----------------
      'DisplaytheLabAndForm 1, 0, 0, "", 0
   End If
   
RepeatDispenseItemExit:
   On Error Resume Next
   '
   On Error GoTo 0
   
   RepeatDispenseItem = success
   
Exit Function

RepeatDispenseItemError:
success = False
strBatchNotes = strBatchNotes & ">>>>> Error: " & Err.Number & " " & "Source: " & Source & " " & Err.Description
Resume RepeatDispenseItemExit

End Function

Private Function RptDispGetPatient(ByVal RequestID_Prescription As Long, _
                                   ByVal RequestID_Dispensing As Long, _
                                   ByRef strBatchNotes As String, _
                                   ByVal lngEpisodeID As Long _
                                   ) As Boolean
'07Dec08 CKJ Repeat Dispensing support routine. Returns success T/F.
'            Bring patient into scope based on RequestIDs, both of which must be present unlike
'            normal dispensing where the RequestID_Dispensing is optional and denotes a new dispensing
'19Jul10 XN  F0123343 added siteID to pEpisodeSelect
'30Jan13 XN  41410 Set the patient address and post code on pidExtra, so goes on print heap
'06Nov14 XN  Added setting BSA (83897)
'02Dec15 TH  Use unformatted NH Number Ported from dispensing ctrl (TFS 132479)

Dim WPat As WPatient
Dim WPatientID As Long
Dim success As Boolean
Dim EpisodeID As Long
Dim msg As String


Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "RptDispGetPatient"

   success = False
   msg = ""
   
   If (RequestID_Prescription > 0 And RequestID_Dispensing > 0) Or lngEpisodeID > 0 Then '17Jul12 TH Added episode clause
      If IsRequestCancelled(RequestID_Prescription) And lngEpisodeID = 0 Then '17Jul12 TH Added episode clause
         msg = "Prescription has already been cancelled" & cr  '** tidy for output
      Else
         gRequestID_Prescription = RequestID_Prescription         'master copies for reference throughout the program
         gRequestID_Dispensing = RequestID_Dispensing             'not changed except by a call to this proc
      
         FillHeapDrugInfo -gPRNheapID, d, 0                       'clear drug from print heap
         FillHeapLabelInfo -gPRNheapID, L, 0
         FillHeapStandardInfo gPRNheapID
   
         DestroyOCXheap
         success = ParseKeyValuePairsToHeap("Version=V10", "|", "=", g_OCXheapID)   'create heap with single entry
      End If

      If success Then
         'infer episode from RequestID_Dispensing using pEpisodeOrderEpisode (instead of GetState() in normal dispensing)
         If lngEpisodeID > 0 Then       '17Jul12 TH Added
            EpisodeID = lngEpisodeID
         Else
            EpisodeID = GetEpisodeFromRequest(RequestID_Prescription)
         End If
                          
         gTlogEpisode = EpisodeID
         GetEpisodeToOCXHeap EpisodeID, gDispSite       '19Jul10 XN F0123343 added siteID to pEpisodeSelect
         WPatientID = CLng(OCXheap("EntityID", "0"))
         If WPatientID <> 0 Then
            success = GetPatientByPK(WPatientID, WPat)
         Else
            success = False
         End If
      End If

      If success Then
         pid.recno = WPat.recno
         pid.caseno = OCXheap("CaseNo", "") ' GetEpisodeDataItem(EpisodeID, "CaseNo")                 'WPat.caseno
         gTlogCaseno$ = pid.caseno

         gTlogSpecialty$ = UCase(OCXheap("Specialty", ""))

         pid.sex = WPat.sex
         pid.dob = WPat.dob
         pid.forename = WPat.forename
         pid.surname = WPat.surname

         pid.ward = UCase$(OCXheap("WardCode", ""))               'GetEpisodeDataItem(EpisodeID, "WardCode"))    'WPat.ward                      "
         pid.cons = UCase$(OCXheap("ConsultantCode", ""))         'UCase$(GetEpisodeDataItem(EpisodeID, "ConsultantCode"))      'WPat.cons       "

         If Len(trimz(pid.caseno)) = 0 Then msg = msg & TB & "Patient Case Number" & cr
         If Len(trimz(pid.surname)) = 0 Then msg = msg & TB & "Patient Surname" & cr
         If Len(trimz(pid.ward)) = 0 Then msg = msg & TB & "Ward Code" & cr
         If Len(trimz(pid.cons)) = 0 Then msg = msg & TB & "Consultant Code" & cr
         If TrueFalse(TxtD(dispdata & "\ascribe.ini", "PID", "N", "SpecialtyMandatory", 0)) Then
            If Len(trimz(gTlogSpecialty)) = 0 Then msg = msg & TB & "Specialty Code" & cr
         End If
         
         If Len(msg) Then
            success = False
            msg = "The following information is missing:" & cr & msg
         End If

         pid.Height = OCXheap("HeightM", "")      'WPat.height
         pid.weight = OCXheap("WeightKg", "")     'WPat.weight
         pid.SurfaceAreaInM2 = OCXheap("BSA", "") 'WPat.BSA  83897 XN 6Nov14
         
         pid.status = UCase$(OCXheap("EpisodeTypeDescription", "A"))    'Use status from patient editor
         Select Case pid.status
            Case "I", "O", "D", "L" 'No action required
               'OK
            Case Else
               pid.status = UCase$(OCXheap("EpisodeTypeCode", "A"))     'Use status of episode itself
            End Select
      
         Select Case pid.status
            Case "I", "O", "D", "L" 'No action required
               'OK
            Case Else                'Select IODL because an invalid code or the lifetime episode was given - 'A'll
               msg = msg & TB & "Invalid episode type: " & pid.status & cr
               success = False
            End Select

         'pidExtra.NHNumber = OCXheap("HealthCareNumber", "")             '05Oct09 PJC Populated pidExtra with the PatientIdentifier/Valid for the patient print heap. (F0064619)
         pidExtra.NHNumber = OCXheap("HealthCareNumberUnformatted", "")  '02Dec15 TH Ported from dispensing ctrl (TFS 132479) 13May12 TH Replaced as HealthCareNumber now pre-formated. Shouldnt be an issue, but needed for compatibility (formatting here done differently)
         pidExtra.NHnumValid = OCXheap("HealthCareNumberValid", "")      '              "
         
                 
         pidExtra.Speciality = UCase(OCXheap("Specialty", ""))
                  
         ' 30Jan13 XN 41410 Set the patient address and post code, on pidExtra, so goes on print heap!
         pidExtra.Address1 = OCXheap("Address1", "")
         pidExtra.Address2 = OCXheap("Address2", "")
         pidExtra.Address3 = OCXheap("Address3", "")
         pidExtra.Address4 = OCXheap("Address4", "")
         pidExtra.postCode = OCXheap("PostCode", "")
         
         'If success Then '05Feb14 TH Removed fencepost - if pat type is loaded then the heap MUST be over written (TFS 83807)
            FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0
            ''success = PrescriptionToOCXHeap(RequestID_Prescription) '!!! Do we need this ????? THis will be heavy 22Mar11 TH
            ''If Not success Then
            ''   msg = msg & "Unable to fill print heap with Prescription details"
            ''End If
         'End If
         
        
         

      Else
         '-----lblStatus(0).Caption = " Patient not found... "
         msg = msg & "Patient not found"
      End If
   End If

Cleanup:
   'On Error Resume Next
   On Error GoTo 0
   
   If Len(msg) Then
      success = False
      msg = cr & WPat.forename & " " & WPat.surname & "  " & pid.caseno & cr & cr & msg & cr
      strBatchNotes = strBatchNotes & msg          'tidy for output
   End If
   
   If ErrNumber Then
      Err.Raise ErrNumber, ErrSource & ErrSource, ErrDescription
   End If
   
   RptDispGetPatient = success
   
Exit Function

ErrHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function


Sub ConstructBatchArray(ByVal PatientXML As MSXML2.IXMLDOMElement, ByVal i_strRecno As String, io_strErrMsg As String, ByVal intSupplyLength As Integer, ByVal intSupplyPatternDays As Integer, ByVal intSupplyPatternSplitDays As Integer)
'18May11 TH Written for batch requirements report


Const DoseSlotsPerDay = 4

Dim udtDrug As DrugParameters
Dim RepeatDispensingDispensingID As Long
Dim RepeatDispensingPrescriptionID As Long
Dim sglRepeatDispensingQuantity As Single
Dim XMLelement As MSXML2.IXMLDOMElement
Dim sglDosesperissueunit As Single
Dim sglNumDoses As Single
Dim intloop As Integer
Dim sqlTotQty As Single
Dim UnfactoredTotQty!
Dim intLabels As Integer
Dim sglTotalSupplyQty As Single
Dim sglQtyCache As Single
Dim sglSupplyQty As Single
Dim intSplitCount As Integer
Dim rsRequest As ADODB.Recordset
Dim strParams As String
Dim strPrescriptionInfo As String
Dim blnUpdated As Boolean
Dim intArrayTotal As Integer
Dim batchrec As BatchReportRec
Dim strQty As String
Dim blnOK As Boolean
Dim blnBreakfast As Boolean
Dim blnLunch As Boolean
Dim blnTea As Boolean
Dim blnNight As Boolean
Dim intTotalSlots As Integer
Dim intSlot As Integer
Dim intDoseLoop As Integer
Dim MachineName As String
Dim DisplayName As String
Dim intSuccess As Integer
Dim xmlnode As MSXML2.IXMLDOMElement
Dim intCount As Integer
Dim intSlotloop As Integer

On Error GoTo ConstructBatchArrayErrorHandler

   ReDim SlotMap(1 To 6) As Integer

   For Each XMLelement In PatientXML.selectNodes("Dispensing")
      If LCase(XMLelement.getAttribute("InUse")) = "true" Or XMLelement.getAttribute("InUse") = "1" Then  '07Jun11 TH (F0119656)
         'get the label
         RepeatDispensingDispensingID = XMLelement.getAttribute("RequestID")
         If RepeatDispensingDispensingID > 0 Then                'potentially valid dispensing
            RepeatDispensingPrescriptionID = XMLelement.getAttribute("PrescriptionID")
            sglRepeatDispensingQuantity = XMLelement.getAttribute("RepeatDispensingQuantity")
            
            Labf& = RepeatDispensingDispensingID                         'requestid for dispensing which is currently in use
            getlabel Labf&, L, False
            
            
         
           'get the drug details
            udtDrug.SisCode = L.SisCode
            getdrug udtDrug, 0, 0, False
                                                                             '    "
            
           'calculate how many labels would need to be printed for this issue  -- THIS NEEDS REWORKING
            sglDosesperissueunit = d.dosesperissueunit
            If sglDosesperissueunit = 0 Then sglDosesperissueunit = 1
            sglNumDoses = 0
            
            intSuccess = MechDispPackerSection(MachineName, DisplayName)
            Set xmlnode = XMLelement.selectSingleNode("RobotItem")
            If MachineName = "JVADTPS" And (xmlnode.getAttribute("Value") = "1") Then
               'We need to loop through each day
               ReDim SlotTime(1 To DoseSlotsPerDay) As String
               ReDim ScriptTime(1 To 6) As String
               For intloop = 1 To 6
                 ScriptTime(intloop) = Trim$(L.Times(intloop))
               Next
               blnOK = MapTimesToTimeSlots(ScriptTime(), SlotMap(), SlotTime())
               If Not blnOK Then
                  'ErrorCode = 135                  'mapping of times failed
               Else
                  intSlot = intJVMStartSlot
                  sglNumDoses = 0
                  intCount = 0
                  'For intloop = 1 To intJVMTotalSlots
                  Do While intCount <= intJVMTotalSlots
                     If intSlot > 4 Then intSlot = 1
                     'Do we have a dose ? If so we add to total
                     'For intDoseLoop = intSlot To 4
                        intCount = intCount + 1
                        If intCount > intJVMTotalSlots Then Exit Do
                        'If (blnJVMBreakfast And intDoseLoop = 1) Or (blnJVMLunch And intDoseLoop = 2) Or (blnJVMTea And intDoseLoop = 3) Or (blnJVMNight And intDoseLoop = 4) Then
                        If (blnJVMBreakfast And intSlot = 1) Or (blnJVMLunch And intSlot = 2) Or (blnJVMTea And intSlot = 3) Or (blnJVMNight And intSlot = 4) Then
                           For intSlotloop = 1 To 4
                           If SlotMap(intSlotloop) = intSlot Then
                              sglNumDoses = sglNumDoses + L.dose(intSlotloop)
                           End If
                           Next
                        End If
                     'Next
                     'intSlot =
                     'If L.dose(ScriptTime(intSlot)) > 0 Then
                     '   sglNumDoses = sglNumDoses + L.dose(ScriptTime(intSlot))
                     'End If
                     intSlot = intSlot + 1
                  Loop
                  'Next
                  sglTotalSupplyQty = sglNumDoses
                  intCount = intCount + 1
               End If
            Else
            
               For intloop = 1 To 6
                  If L.dose(intloop) > 0 Then
                     sglNumDoses = sglNumDoses + L.dose(intloop) '07Mar11 TH Replace above case statement (F00109625)
                  End If
               Next
               If sglNumDoses = 0 Then sglNumDoses = 1
      
               If sglRepeatDispensingQuantity > 0 Then
                  'here the whole qty is on one label
                  sqlTotQty = sglRepeatDispensingQuantity
                  UnfactoredTotQty! = sglRepeatDispensingQuantity
                  intLabels = 1
                  Qty! = sqlTotQty
                  sglTotalSupplyQty = sqlTotQty
               ElseIf intSupplyLength > 0 Then
                  'OK the supply length will now dictate the quantity and number of labels requried
                  If intSupplyPatternDays = 0 Then intSupplyPatternDays = intSupplyLength  '30Oct09 TH
                  sqlTotQty = sglNumDoses * intSupplyLength
                  sglTotalSupplyQty = sglNumDoses * intSupplyLength  '30Oct09 TH Added
                  UnfactoredTotQty! = sqlTotQty
                  intLabels = (sqlTotQty / (sglNumDoses * intSupplyPatternDays)) 'sglRepeatDispensingQuantity
                  If sqlTotQty < sglNumDoses Then   '07Jun99 SF
                     intLabels = 1
                     Qty! = sglRepeatDispensingQuantity
                     sqlTotQty = sglRepeatDispensingQuantity     '07Jun99 SF added
                  Else
                     If sqlTotQty Mod (sglNumDoses * intSupplyPatternDays) > 0 Then intLabels = intLabels + 1
                     Qty! = (sglNumDoses * intSupplyPatternDays)
                  End If
               End If
            End If
            
            'we want sglTotalSupplyQty as the total quantity required. Here we search the nsvcode and if exist we ADD to the quantity
            'already present.If not in arrary then we add and post the qty.
            
            blnUpdated = False
            For intloop = 0 To UBound(m_BatchReportList())
               'LSet r.record = buffer
               If Trim$(m_BatchReportList(intloop)) <> "" Then
                   'LSet batchrec = m_BatchReportList(intloop)
                   batchrec.NSVCode = Mid$(m_BatchReportList(intloop), 11, 7)
                   batchrec.Description = Left$(m_BatchReportList(intloop), 10)
                   batchrec.Qty = Right$(m_BatchReportList(intloop), Len(m_BatchReportList(intloop)) - 17)
                   
                   If batchrec.NSVCode = udtDrug.SisCode Then
                   'OK its here so we add the qty,set the added flag leave
                       strQty = CSng(batchrec.Qty) + sglTotalSupplyQty
                       m_BatchReportList(intloop) = Left(m_BatchReportList(intloop) & Space$(17), 17) & strQty
                       blnUpdated = True
                       Exit For
                   End If
               End If
            Next
            If blnUpdated = False Then
               'we need to add this to the array.
               intArrayTotal = UBound(m_BatchReportList())
               intArrayTotal = intArrayTotal + 1
               ReDim Preserve m_BatchReportList(intArrayTotal)
               'm_BatchReportList(intArrayTotal) = Left$(udtDrug.Description, 10) & udtDrug.SisCode & sglTotalSupplyQty  XN 4Jun15 98073 New local stores description
               m_BatchReportList(intArrayTotal) = Left$(udtDrug.LabelDescription, 10) & udtDrug.SisCode & sglTotalSupplyQty
               'm_BatchReportList(intArrayTotal).description = Left$(udtDrug.description, 10)
               'm_BatchReportList(intArrayTotal).qty = sglTotalSupplyQty
               
            
            End If
            
         End If
      'else
      'dispensing is out of use. For now we just skip
      End If
   Next

ConstructBatchArrayCleanUp:

   On Error GoTo 0

   Exit Sub

ConstructBatchArrayErrorHandler:
   
   io_strErrMsg = io_strErrMsg & Error$(Err)

Resume ConstructBatchArrayCleanUp

End Sub


Sub striprtf(txt$)

   If Len(txt$) = 0 Then Exit Sub

   Do
      txt$ = Left$(txt$, Len(txt$) - 1)
   Loop Until Asc(Right$(txt$, 1)) = 125
   
   If Right$(txt$, 2) = Chr$(125) & Chr$(125) Then txt$ = Left$(txt$, Len(txt$) - 1)
   If Asc(txt$) = 123 Then txt$ = Right$(txt$, Len(txt$) - 1)

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

Function IsPCTDispensing() As Boolean
'stub
End Function

Function PCTConfirmClaimQty(a!) As Boolean
'stub
End Function
Function PCTDrugToDispens() As Boolean
'stub
End Function

Sub setPCTDose(PCTdoses!, nDays As Integer, a As Boolean)
'stub
End Sub

Sub LogAllPCTDispensings()
'stub
End Sub

Function Robotable(ByVal xmldoc As MSXML2.DOMDocument) As Boolean

Dim blnRobotable As Boolean
Dim PatientsXML As MSXML2.IXMLDOMElement
Dim PatientXML As MSXML2.IXMLDOMElement
Dim XMLelementDispensing As MSXML2.IXMLDOMElement
Dim XMLelementRobotItem As MSXML2.IXMLDOMElement

blnRobotable = False

For Each PatientsXML In xmldoc.selectNodes("//Batch")

   For Each PatientXML In PatientsXML.selectNodes("//Patient")  'for each patient
      For Each XMLelementDispensing In PatientXML.selectNodes("Dispensing")
         For Each XMLelementRobotItem In XMLelementDispensing.selectNodes("RobotItem")
            If XMLelementRobotItem.getAttribute("Value") = "1" Then
               blnRobotable = True
               Exit For
            End If
         Next
         If blnRobotable Then Exit For
      Next
      If blnRobotable Then Exit For
      
   Next
   If blnRobotable Then Exit For
Next

Robotable = blnRobotable


End Function
Public Sub CreatePSOrder(a As Long)
'Stubbage
End Sub
Public Function GetPSOSupplierText() As String
'Stubbage
End Function

