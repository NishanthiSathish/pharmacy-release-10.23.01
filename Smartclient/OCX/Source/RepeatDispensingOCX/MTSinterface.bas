Attribute VB_Name = "MTSinterface"


Const DoseSlotsPerDay = 4                 'Caution: would require significant editing before this could be changed


'25Jan08 CKJ added to support MTS
Type MTSConfirmType
   ReasonNotForRobot As Integer           'Error code > 0
   '------------------------------
   SlotTime(1 To 4) As String * 4         '0800' '    ' '1800' '2200'
   SlotQuantity(1 To 4) As Integer        'Num of SlotFractions to dispense, eg 2/1 5/2 3/4
   SlotFraction(1 To 4) As Integer        '0 no dose  1 whole  2 half  (3 third <reserved>)  4 quarter
End Type

Dim mDoseSlot(1 To DoseSlotsPerDay, 1 To 6) As String



Function IsItemForMTSPacker(ByVal PackerSection As Integer, MTSConfirm As MTSConfirmType) As Integer
'Takes global l
'Takes global d
'Returns T/F if item could be for robot packer
'ErrorCode is 0 if successful, else a code which is defined in mechdisp.ini
' selected errors are warnings only and still return success
' only first error encountered is returned
'MTSConfirm has SlotTime() SLotQuantity() and SlotFraction() filled on exit, where appropriate
'
'Criteria are as follows   Success   ErrorCode     Description
'   l.siscode blank           N        100         Free format label
'   wrong issue type          X        101         l.isstype not in selected list
'   drug not found            X        102         l.siscode present but drug not found
'   not a robot item          N        110         primary stock location is not robot
'   drug out of use           N      111,112       product has InUse = No (111) or Stores only (112)
'   no stock                  N      113,114       stock level is zero (113) or negative (114)            (note 2)
'   low stock                 Y        115         stock level is positive but below reorder level
'   Manual issue qty          N        120         Manual issue flag is set
'   PRN set                   N        121         PRN flag is set
'   Patient own               N        122         Patient own stock is set
'   non-daily dose            N      130,131       interval not 'day' (130), days of week not 1234567 (131) (note 1)
'   dose is zero              N        132         l.dose(1) is zero or negative
'   unequal dosing            Y        133         two or more dosing times, dose not identical each time
'   too many doses            N        134         more than four doses per day
'   two doses per slot        N        135         two or more dosing times would be served by one time slot
'   fractional dose           N        140         dose is not whole, half or quarter of an issue unit
'   quarter dose              Y        141         quarter of an issue unit
'   half dose                 Y        142         half an issue unit
'   three quarters dose       Y        143         three quarters of an issue unit
'
'   Code X is not tested here and is included purely for reference

'Notes:
'1) excluded even if only one dose prescribed, or only one dose left in the sequence
'2) may allow this as a warning when not on live stock control or when issue into negative is permitted
'
' 02Aug10 XN Stores only products identified now by d.ProductID being 0 F0088717

Dim ErrorCode As Integer
Dim success As Integer
Dim Section As String
Dim foundPtr As Long
Dim asciiday As Integer
Dim iLoop As Integer
Dim fraction As Single
Dim iCount As Integer
Dim iDenominator As Integer

   ReDim SlotMap(1 To 6) As Integer

   ErrorCode = 0
   success = True

   If Len(Trim$(L.SisCode)) = 0 Then
      success = False
      ErrorCode = 100                                 'free format label
   End If

'Several checks are tested in CallRptDispens prior to this function, hence omitted

'   If success Then
'      If InStr(1, PackerGridData(0).DispensingTypes, UCase$(l.IssType), 1) = 0 Then
'         ErrorCode = 101
'         success = False
'      End If
'   End If

'   If success Then
'      d.SisCode = l.SisCode
'      getdrug d, 0, foundptr, False                   'read drug file
'
'      If foundptr = 0 Then
'         success = False
'         ErrorCode = 102                              'drug not found
'      End If
'   End If

   If success Then
      Section = SectionIDForMechDisp(d.loccode)

      If Val(Section) <> PackerSection Then
         success = False
         ErrorCode = 110                              'primary stock location not robot
      End If
   End If

   If success Then
          ' 02Aug10 XN Stores only products identified now by d.ProductID being 0 F0088717
      If d.inuse = "N" Then                           'not in use
        success = False
        ErrorCode = 111
      ElseIf d.ProductID = 0 Then                   'Stores only
        success = False
        ErrorCode = 112
      End If
      
'      Select Case d.inuse
'         Case "N"                                     'not in use
'            success = False
'            ErrorCode = 111
'         Case "S"                                     'Stores only
'            success = False
'            ErrorCode = 112
'         End Select
          ' end of F0088717
   End If

   If success Then
      Select Case Val(d.stocklvl)
         Case 0
            success = False
            ErrorCode = 113
         Case Is < 0
            success = False
            ErrorCode = 114
         Case Is < Val(d.reorderlvl)
            ErrorCode = 115
         End Select
   End If

'@@'
''   If success Then
''      If Asc(L.Flags) And &H1 Then                    'Manual flag 0000 0001
''         success = False
''         ErrorCode = 120
''      End If
''   End If
''
''   If success Then
''      If Asc(L.Flags) And &H2 Then                    'PRN flag    0000 0010
''         success = False
''         ErrorCode = 121
''      End If
''   End If
''
''   If success Then
''      If Asc(L.Flags) And &H4 Then                    'Patient own 0000 0100
''         success = False
''         ErrorCode = 122
''      End If
''   End If
''
''   If success Then
''      If Trim$(LCase$(L.RepeatUnits)) <> "day" Then
''         success = False
''         ErrorCode = 130
''      End If
''   End If
''
''   If success Then
''      asciiday = Asc(L.days)
''      If asciiday > 0 Then
''         If (asciiday And &HFE) <> &HFE Then           '1111 1110'
''            success = False
''            ErrorCode = 131
''         End If
''      End If
''   End If

   If success Then
      If L.dose(1) <= 0 Then
         success = False
         ErrorCode = 132
      End If
   End If

   If success Then
      iCount = 1                          'first dose already checked above
      For iLoop = 2 To 6
         If L.dose(iLoop) > 0 Then iCount = iCount + 1
         Select Case L.dose(iLoop)
            Case 0                        'zero is ok
            Case Is <> L.dose(1)          'different from first dose
               ErrorCode = 133            'warning only
               Exit For
            End Select
      Next
      If iCount > 4 Then                  'more than four doses per day
         ErrorCode = 134
         success = False
      End If
   End If

   If success Then                        'no more than four doses per day, do they fit the time slots?
      ReDim SlotTime(1 To DoseSlotsPerDay) As String
      ReDim ScriptTime(1 To 6) As String
      For iLoop = 1 To 6
        ScriptTime(iLoop) = Trim$(L.Times(iLoop))
      Next
      success = MapTimesToTimeSlots(ScriptTime(), SlotMap(), SlotTime())
      If Not success Then
         ErrorCode = 135                  'mapping of times failed
      Else
         For iLoop = 1 To DoseSlotsPerDay
            MTSConfirm.SlotTime(iLoop) = SlotTime(iLoop)
         Next
      End If
   End If

   If success Then
      For iLoop = 6 To 1 Step -1                              'reverse loop so that minor error appears as the first one
         iDenominator = 0
         fraction = L.dose(iLoop) - Int(L.dose(iLoop))        'each dose                      '$$ scale dose to tablets from mg
         Select Case fraction                                 '0 to 0.9999999
            Case 0 To 0.0000003                               'whole
               iDenominator = 1
            Case 0.2499997 To 0.2500003                       'quarter
               iDenominator = 4
               ErrorCode = 141
            Case 0.4999997 To 0.5000003                       'half
               iDenominator = 2
               ErrorCode = 142
            Case 0.7499997 To 0.7500003                       'three quarters
               iDenominator = 4
               ErrorCode = 143
            Case 0.9999997 To 1                               'whole
               iDenominator = 1
            Case Else                                         'not packable
               success = False
               ErrorCode = 140
               Exit For                                       'stop on unpackable fraction
            End Select
         If success And SlotMap(iLoop) > 0 Then
            MTSConfirm.SlotFraction(SlotMap(iLoop)) = iDenominator
            MTSConfirm.SlotQuantity(SlotMap(iLoop)) = Int(L.dose(iLoop) * iDenominator + 0.0000003)
         End If
      Next

      If success And L.dose(1) > 1 Then
         Select Case ErrorCode
            Case 141 To 143                                   'combination of whole and parts of tablets
               ErrorCode = 144
            End Select
      End If
   End If

   'dosing units v issue units   '$$ review data

   MTSConfirm.ReasonNotForRobot = ErrorCode
   IsItemForMTSPacker = success

End Function


Sub MTSAppendData(ByVal iniSection As String, MTSConfirm As MTSConfirmType, DaysForSupply As Integer, TotalIssueQuantity As Single, TotalUnfactoredIssueQuantity As Single, MTSRepeatNumber As Long)
'25Jan08 CKJ
'Take PMR data in MTSConfirm()
'Use Heap and MechDisp.ini to populate the output file

Dim MTSchan As Integer
Dim prnchan As Integer
Dim strOut As String
Dim MTSheapID As Integer
Dim success As Integer
Dim valid As Integer
Dim iniFile As String
Dim strVal As String
'Dim PackerConfirmID As Integer
'Dim PackerGridDataID As Integer
'Dim iLoopDose As Integer
'Dim StartingSlot As Integer
'Dim SlotsToRun As Integer
Dim DaySlot As Integer
Dim dose As Integer
'Dim theDay As Variant
'Dim CellID As Integer
Dim TotalDoses As Single
Dim DoseQuantity As Single
Dim QtyDone As Single
Dim WorkingPathFile As String
Dim ServerPath As String
Dim donePatlabel As Integer
Dim PatientPrinted As Integer  'printed header for patient details
Dim SummaryPrinted As Integer  'printed header for prescription/drug details
Dim ExceptionCode As Integer
Dim temp As String
Dim dblDate As Double
Dim MTSAdminTimes As String
Dim MTSAdminDoses As String

   Screen.MousePointer = HOURGLASS
   
   Heap 1, MTSheapID, "MTS output data", "", success    'create heap
   If Not success Then
      popmessagecr ".", "Halted: Unable to create MTS heap in MTSAppendData"
'@@'      Close
'@@'      End    '$$ would prefer soft exit
   End If

   PatientPrinted = False                                '///
   donePatlabel = False                                  '///
   iniFile = dispdata$ & "\MechDisp.Ini"

   'MessageOut = "[MessageOutPatient][MessageOutProduct][MessageOutPrescription]"
   'MessageOutPatient = "[pForename]|[pSurname]|[MTSDOB]|[pCaseno]|"
   'MessageOutProduct = "[iNSVcode]|[iDescriptionInferred]|[iPhysicalDescription]|[iDirectionsInferred]|[MTSwarning]|[MTSinstruction]|[MTSAdminTimes]|[MTSAdminDoses]|[MTSDaysSupply]|NHC|[Facility]|"
   'Facility = "Notthingham Health Care tel. 0123 123456"
   'MessageOutPrescription "lRxNum|MTSStartDate|Everyday|MTStotalquantity|[crlf]"

   Heap 10, MTSheapID, "MTStotalquantity", Format$(TotalIssueQuantity), 0
                                     
   Heap 10, MTSheapID, "MTStotalunfactoredquantity", Format$(TotalUnfactoredIssueQuantity), 0

   Heap 10, MTSheapID, "MTSDaysSupply", Format$(DaysForSupply), 0
                                     
   'MTSStartDate = next sunday
   'Select Case CLng(Now) Mod 7                       '03Mar08 CKJ see below
   Select Case Int(Now) Mod 7                         '   "
      Case 0     'saturday
         dblDate = Now + 1
      Case 1     'sunday
         dblDate = Now
      Case Else  'mon-fri
         'dblDate = Now + (8 - (CLng(Now) Mod 7))     '29Feb08 CKJ changed to Int() to avoid rounding, added optional offset
         dblDate = Now + (8 - (Int(Now) Mod 7)) + Val(TxtD(iniFile, Format$(iniSection), "0", "PackingDateOffset", 0))
      End Select
   'strVal = Format$(dblDate, "ddmmyyyy")            '29Feb08 CKJ made format configurable
   strVal = Format$(dblDate, TxtD(iniFile, Format$(iniSection), "ddmmyyyy", "PackingDateFormat", 0))
   Heap 10, MTSheapID, "MTSstartdate", strVal, 0

   parsedate pid.dob, strVal, "ddmmccyy", valid
   If Not valid Then strVal = ""
   Heap 10, MTSheapID, "MTSDOB", strVal, 0

   GetInsCode (d.inscode), temp
   '/// consider gintModified
   replace temp, Chr$(30), " ", 0
   replace temp, "|", " ", 0
   replace temp, "  ", " ", 0
   temp = StripColourInfo$(temp)

   Heap 10, MTSheapID, "MTSinstruction", temp, 0

   GetWarCode d.warcode, temp      ' o/p      '///consider gintModified, and i/p v o/p settings
   replace temp, Chr$(30), " ", 0
   replace temp, "|", " ", 0
   replace temp, "  ", " ", 0
   temp = StripColourInfo$(temp)
   Heap 10, MTSheapID, "MTSwarning", temp, 0
   
   ServerPath = TxtD(iniFile, Format$(iniSection), "", "ServerPath", 0)                            '$$ make a function call
   replace ServerPath, "[DISPDATA]", dispdata$, True                                               'case insensitive replace
   If Right$(ServerPath, 1) <> "\" Then ServerPath = ServerPath & "\"                              'L:\somewhere\'   'L:\dispdata.123\MTS\'
   WorkingPathFile = ServerPath & Left$(FilenameParse(ASCTerminalName()), 8)                       'L:\somewhere\TERM14'

   MTSchan = FreeFile
   Open WorkingPathFile & ".wrk" For Append As #MTSchan
   prnchan = FreeFile
'///   Open WorkingPathFile & ".inc" For Append As #prnchan
             
   ExceptionCode = 0                                                    'indicates the need to print an item which was excluded from the run
             
   TotalDoses = 0

   SummaryPrinted = False
   
   MTSAdminTimes = ""
   MTSAdminDoses = ""

   For DaySlot = 1 To 4                                           'for each dose to do
'               DayNumber = (iLoopDose - 1) \ DoseSlotsPerDay               '0 for first column of doses

      'MessageOut="[MTSpatientname][MTSlocation][pCaseno]  [iNSVcode][MTSfractioncode]   [MTSscript][MTSDoseDate][MTSDoseTime]  [MTSqty][MTSDay][cr][lf]"
         
      'If Len(MTSAdminDoses) Then
      '   MTSAdminTimes = MTSAdminTimes & ","
      '   MTSAdminDoses = MTSAdminDoses & ","
      'End If

      DoseQuantity = MTSConfirm.SlotQuantity(DaySlot)           'cast int to single

      If DoseQuantity > 0 Then
         If Len(MTSAdminDoses) Then
            MTSAdminTimes = MTSAdminTimes & ","
            MTSAdminDoses = MTSAdminDoses & ","
         End If

         MTSAdminTimes = MTSAdminTimes & MTSConfirm.SlotTime(DaySlot)

'/// spec does not permit fractions of tablets
         strVal = Mid$("*XY*Z", MTSConfirm.SlotFraction(DaySlot) + 1, 1)        '*' is there as a trap for invalid entries - error if used
'                  Heap 10, MTSheapID, "MTSfractioncode", strVal, 0
         Select Case strVal
            Case "Y": DoseQuantity = DoseQuantity / 2
            Case "Z": DoseQuantity = DoseQuantity / 4
            End Select
'                 TotalDoses = TotalDoses + DoseQuantity
         MTSAdminDoses = MTSAdminDoses & Format$(DoseQuantity)        'cast single to string for output
      End If
   Next
               
   Heap 10, MTSheapID, "MTSAdminTimes", MTSAdminTimes, 0
   Heap 10, MTSheapID, "MTSAdminDoses", MTSAdminDoses, 0
   Heap 10, MTSheapID, "MTSRepeatNumber", Format$(MTSRepeatNumber), 0
   

         
'                        strOut = ""
   
'                        theDay = CVDate(PackerGridData(PackerGridDataID).BaseDateTimeDbl)  'start at base day
'                        theDay = DateAdd("d", DayNumber, theDay)                    'increment to correct day
                  
'                        strVal = Format$(dose)
'                        Heap 10, MTSheapID, "MTSqty", strVal, 0

                  
'                        strVal = Mid$("*XY*Z", PackerConfirm(PackerConfirmID).SlotFraction(DaySlot) + 1, 1)        '*' is there as a trap for invalid entries - error if used
'                        Heap 10, MTSheapID, "MTSfractioncode", strVal, 0
'                        Select Case strVal
'                           Case "Y": DoseQuantity = DoseQuantity / 2
'                           Case "Z": DoseQuantity = DoseQuantity / 4
'                           End Select
'                        TotalDoses = TotalDoses + DoseQuantity
                  
'                        strVal = Format$(theDay, "ddmmyy")
'                        Heap 10, MTSheapID, "MTSDoseDate", strVal, 0
                  
'                        strVal = PackerConfirm(PackerConfirmID).SlotTime(DaySlot)
'                        Heap 10, MTSheapID, "MTSDoseTime", strVal, 0
                  
'                        strVal = Format$(theDay, "ddd")
'                        Heap 10, MTSheapID, "MTSDay", strVal, 0
                  
'                        PadHeapField MTSheapID, inifile, iniSection, "MTSfractioncode"
'                        PadHeapField MTSheapID, inifile, iniSection, "MTSscript"
'                        PadHeapField MTSheapID, inifile, iniSection, "MTSDoseDate"
'                        PadHeapField MTSheapID, inifile, iniSection, "MTSDoseTime"
'                        PadHeapField MTSheapID, inifile, iniSection, "MTSqty"
'                        PadHeapField MTSheapID, inifile, iniSection, "MTSDay"
                        
   'Heap 100, MTSheapID, "", "", 0          'enable for testing only   '18Feb08 TH Removed

   strOut = "[MessageOut]"
   strVal = ""
   Do While strVal <> strOut
      strVal = strOut
      ParseCtrlChars iniFile, iniSection, strOut, False
      ParseCtrlChars dispdata & "\printer.ini", "screen", strOut, False
      ParseItems MTSheapID, strOut, False
      ParseItems gPRNheapID, strOut, False     '11Jul06 CKJ added to catch iNSVcode
   Loop
                        
   Print #MTSchan, strOut;                  'output file for interface

   '   RTFinternalTransfer$ = RTFinternalTransfer$ & ques.lblDesc(i) & "[tab]...[BoldOn]   " & QuesGetText(i) & "[BoldOff][tab][tab]" & ques.lblInfo(i) & "[cr]"
   strOut = ""
'                        If Not PatientPrinted Then
'                           strOut = strOut & "[IncludePatient]"
'                           PatientPrinted = True
'                        End If
   If Not SummaryPrinted Then
      strOut = strOut & "[IncludeScript]"
      SummaryPrinted = True
   End If
   strOut = strOut & "[IncludeLine]"

   ParseCtrlChars iniFile, iniSection, strOut, False
   ParseCtrlChars dispdata & "\printer.ini", "rtf", strOut, False
   ParseItems MTSheapID, strOut, False
   ParseItems gPRNheapID, strOut, False
   ParseCtrlChars iniFile, iniSection, strOut, False
                        
'///                        Print #prnchan, strOut;                  'output file for included items report
   
                        '$$
                        'internal log
'                     Else
                        'within robot dates, but outside prescription dates
'                     End If
            
'            Next 'dose within current grid
   
            'cut-down version of issue
'///            success = PackerIssue(TotalDoses, QtyDone)   'may issue none, some or all of the amount requested    Also updates labeltxt.v6
   
   If SummaryPrinted Then
      strOut = "[IncludeSummary]"               'summary may be used if details lines are not needed
      Heap 10, MTSheapID, "MTSTotalDoses", Format$(TotalDoses), 0
      Heap 10, MTSheapID, "MTSIssuedDoses", Format$(QtyDone), 0
      ParseCtrlChars iniFile, iniSection, strOut, False
      ParseCtrlChars dispdata & "\printer.ini", "rtf", strOut, False
      ParseItems MTSheapID, strOut, False
      ParseItems gPRNheapID, strOut, False
      ParseCtrlChars iniFile, iniSection, strOut, False
            
'///               Print #prnchan, strOut;                   'output file for included items report
   Else
      '... nothing printed from this grid. No doses match dates/times for picking
      ExceptionCode = 201
   End If
   
            If QtyDone Then                              'update label with QtyDone
'               'did some of it
'               If Not donePatlabel Then
'                  donePatlabel = True
'                  If InStr(PackerGridData(0).PrintOptions, "3") Then    'patlabel wanted
'                     patlabel k, pid, 1, -1, 1
'                  End If
'               End If
            End If
            If TotalDoses > QtyDone Then                 'print amount to do manually later
'               'didn't do all of it
'               popmessagecr "!", "Insufficient stock to complete this item" & cr & cr & "Please review and manually issue remainder" & cr & "when stock becomes available" & cr & cr & Trim$(d.description)
            End If
            
'         Else                                            'drug has no grid, or has been greyed out by user
'            If PackerGridData(PackerGridDataID).StartingSlot = 0 Then
'               ExceptionCode = 200       'was greyed out by user
'            Else
'               ExceptionCode = 202       'config not done correctly
'            End If
'         End If
'      Else                                               'no grid present
'         ExceptionCode = PackerConfirm(PackerConfirmID).ReasonNotForRobot
'      End If

   If ExceptionCode Then
'         If InStr(PackerGridData(PackerGridDataID).PrintOptions, "2") Then    'print exceptions selected
      If InStr(TxtD(iniFile, iniSection, "", "ReasonCodesNotToPrint", 0), "," & Format$(ExceptionCode) & ",") = 0 Then
         strOut = ""
         If Not PatientPrinted Then
            strOut = strOut & "[IncludePatient]"
            PatientPrinted = True
         End If
         strOut = strOut & "[ExcludeScript]"
         Heap 10, MTSheapID, "MTSReasonCode", Format$(ExceptionCode), 0

         ParseCtrlChars iniFile, iniSection, strOut, False
         ParseCtrlChars dispdata & "\printer.ini", "rtf", strOut, False
         ParseItems MTSheapID, strOut, False
         ParseItems gPRNheapID, strOut, False
         ParseCtrlChars iniFile, iniSection, strOut, False
         
'///               Print #prnchan, strOut;                  'output file for included items report
      End If
'         End If
   End If

'   Next 'drug within current patient

   Close #MTSchan
'///   Close #prnchan

   Heap 2, MTSheapID, "", "", success                 'destroy heap
   Screen.MousePointer = STDCURSOR

End Sub

Sub MTSReleaseFile(ByVal iniSection As String)
'25Jan08 CKJ MTS output, borrowed from JVM as template
'$$ do we ask if they want to close the file now? NO - just do it
'$$ do we ask if they want to discard the file?   NO - don't pack if it's not wanted

'Place output file on server
'Print output (reserved)

' rename Term.wrk => 2ABC--15.dat
' copy   2ABC--15.dat \archive
' print  Term.pr1
' move   Term.pr1 => \archive
' print  Term.pr2
' move   Term.pr2 => \archive

Dim WorkingFile As String
Dim WorkingPathFile As String
Dim ServerPathFile As String
Dim ServerPath As String
Dim ArchivePath As String
Dim SharedPath As String
Dim filename As String
Dim iniFile As String
Dim TempFileName As String

   iniFile = dispdata & "\mechdisp.ini"
   
   ServerPath = TxtD(iniFile, iniSection, "", "ServerPath", 0)
   replace ServerPath, "[DISPDATA]", dispdata$, True                                               'case insensitive replace
   If Right$(ServerPath, 1) <> "\" Then ServerPath = ServerPath & "\"                              'L:\somewhere\'   'L:\dispdata.123\MTS\'

   SharedPath = TxtD(iniFile, iniSection, "", "SharedPath", 0)
   replace SharedPath, "[DISPDATA]", dispdata$, True
   If Right$(SharedPath, 1) <> "\" Then SharedPath = SharedPath & "\"                              'L:\dispdata.123\MTS\Interface\'

   ArchivePath = TxtD(iniFile, iniSection, "", "ArchivePath", 0)
   replace ArchivePath, "[DISPDATA]", dispdata$, True
   If Right$(ArchivePath, 1) <> "\" Then ArchivePath = ArchivePath & "\"                           'L:\dispdata.123\MTS\archive\'

   WorkingFile = Left$(FilenameParse(ASCTerminalName()), 8)                                        'TERM14'
   WorkingPathFile = ServerPath & WorkingFile                                                      'L:\somewhere\TERM14'

   filename = CreatePackerFileName()                                                               '3-AB-123'
   ServerPathFile = ServerPath & filename                                                          'L:\somewhere\3-AB-123'

   'rename output & print files
      
   If fileexists(WorkingPathFile & ".wrk") Then
      Name WorkingPathFile & ".wrk" As ServerPathFile & ".dat"                                         'no sorting
   
      'do printing
      TempFileName = ServerPath & WorkingFile & ".inc"                                                 'Print list of included items
      If fileexists(TempFileName) Then
         '"e:\dispdata.002\MTS\s100.inc"
         PackerPrintDoc filename, "Items Requested For Packing: [cr]", TempFileName
         Name TempFileName As ArchivePath & filename & ".inc"                                          'move and rename in one go
      End If
   
      copy ServerPathFile & ".dat", ArchivePath & filename & ".dat"                                    'overwrite old archive files if they're still there
      copy ServerPathFile & ".dat", SharedPath & filename & ".dat"                                     'copy to output directory
      Kill ServerPathFile & ".dat"
      
      '$$ logging - may not be needed as files are kept anyway
      
      popmessagecr "#", cr & Space$(8) & filename & cr & cr & "Released for packing"
   End If

End Sub

Function CreatePackerFileName() As String
'Uses current date, UserID and Packer.dat to generate next file in sequence
'$$ need to check files don't already exist from last time round the 0000-9999 sequence

Dim intVal As Integer
Dim lngVal As Long
   
   intVal = Format(Now, "w") - 1      '1sun,2mon,...,7sat => 0sun,1mon,...,6sat
   If intVal = 0 Then intVal = 7      '=> 7sun,1mon,...,6sat
   GetPointerSQL dispdata$ & "\Packer.dat", lngVal, True                      'only get number once lock is granted
   Select Case lngVal
      Case Is < 1, Is > 9999                                               'NB 4 digits only
         GetPointerSQL dispdata$ & "\Packer.dat", 1, 2
         lngVal = 1
      End Select
   CreatePackerFileName = Format(intVal) & Right$("---" & Trim$(UserID), 3) & Right$("----" & Format$(lngVal), 4)    '1ABC--41' '3-DE-165'

End Function

Sub FillDoseSlotArray(Section As String)
   
Dim loop1 As Integer
Dim loop2 As Integer
Dim count As Integer
Dim sLine As String

   '         =start,stop,nominal,letter,abbrev,description  (times are 0000 to 2359)
   'DoseSlot1="0000,0929,0800,B,B'fast  ,Breakfast"       before 9
   'DoseSlot2="0930,1429,1200,L,Lunch   ,Lunch"          10 till 2
   'DoseSlot3="1430,1929,1800,D,Dinner   ,Dinner"         3 till 7
   'DoseSlot4="1930,2359,2200,N,Night  ,Night"            8 and after
   
   ReDim lines(0 To 10) As String
   
   For loop1 = 1 To DoseSlotsPerDay
      sLine = TxtD(dispdata & "\MechDisp.ini", Section, ",,,,,", "DoseSlot" & Format$(loop1), 0)
      deflines sLine, lines(), ",(*)", 1, count
      For loop2 = 1 To 6
         mDoseSlot(loop1, loop2) = lines(loop2)
      Next
   Next

End Sub

Function MapTimesToTimeSlots(strScriptTimes() As String, SlotMap() As Integer, SlotTime() As String) As Integer
'09Jun06 CKJ Written, based on MapTimesToTimeBands
'            This procedure takes the l.times() array and selects which of four time slots will be populated
'            Before calling, ensure that there are no more than four doses
'            Consider doses at 10am and 2pm. These may end up in the same time slot
'             --------------------
'             B'fast |   06:00   |
'                    |-----------|
'             Lunch  |10:00 14:00|
'                    |-----------|
'             Dinner |           |
'                    |-----------|
'             Night  |   22:00   |
'             --------------------
'
'            For each dose to map, returns dose slot to use in array SlotMap()
'            eg strScriptTimes(1)=0600   SlotMap(1)=1  breakfast
'               strScriptTimes(2)=1400   SlotMap(2)=2  lunch
'               strScriptTimes(3)=2200   SlotMap(3)=4  night
'               strScriptTimes(4)=       SlotMap(4)=0  no dose
'
'            TimeBands come from mDoseSlot(1 To 4, 1)
'               Start1=00:00           <== Always 00:00
'               Start2=09:30
'               Start3=15:30
'               Start4=19:30
'
'$$ add separate error number for each failure mode

Dim intTimesUsed As Integer            'total number of entries to parse, from 0 to 6
Dim intloop As Integer
Dim strTemp As String
Dim intSuccess As Integer
Dim intBand As Integer
Dim strBands As String                 'four character string holding number of items in each time band e.g. "1011" = B'fast,Dinner,Night

   ReDim strTimes(1 To 6) As String    'l.times() cleaned up and formatted as HHNN
   ReDim intBandStart(1 To 4)          'time of start of each band as integer in range 0 to 2359

   intSuccess = True
   intTimesUsed = 0
   For intloop = 1 To 4
      SlotTime(intloop) = ""
   Next
   
   For intloop = 1 To 6                                                    'Check each entry in turn
      SlotMap(intloop) = 0                                                 'default - no slots to use
      strTemp = Trim$(strScriptTimes(intloop))                             'accepts HHNN or HH:NN
      If strTemp <> "" Then                                                'has a time in it
         intTimesUsed = intTimesUsed + 1
         parsetime strTemp, strTimes(intTimesUsed), "2", intSuccess        'format to just HHNN
         If Not intSuccess Then
            intTimesUsed = 0                                               'not parseable
            Exit For
         End If
      End If
   Next
   
   Select Case intTimesUsed
      Case 0                                                               'no times, nothing to do
         intSuccess = False

      Case 1 To 4
         For intBand = 1 To 4
            intBandStart(intBand) = Val(mDoseSlot(intBand, 1))                   'store for band checking
            If intBand > 1 Then                                                  'times must increase in order
               If intBandStart(intBand) <= intBandStart(intBand - 1) Then
                  intSuccess = False
                  Exit For
               End If
            End If
         Next

         If Not intSuccess Then
            popmessagecr ".", "Contact Supervisor: Invalid time band entry in MechDisp.ini"
         Else

            strBands = "0000"                                           'number of items in each band
            For intloop = 1 To intTimesUsed                             '1 to 1, up to 1 to 4
               If intloop > 1 Then                                      'dosing times must increase in order
                  If Val(strTimes(intloop)) <= Val(strTimes(intloop - 1)) Then
                     intSuccess = False
                     Exit For
                  End If
               End If
               
               Select Case Val(strTimes(intloop))                       'HHNN as an integer
                  Case Is >= intBandStart(4): intBand = 4
                  Case Is >= intBandStart(3): intBand = 3
                  Case Is >= intBandStart(2): intBand = 2
                  Case Else:                  intBand = 1
                  End Select
               Mid$(strBands, intBand, 1) = Format$(Val(Mid$(strBands, intBand, 1)) + 1)              'increment appropriate digit
               SlotMap(intloop) = intBand                                                             'store result
               SlotTime(intBand) = strTimes(intloop)                                                  'band1-4 with time '0000'-'2359' or '    '
            Next
            Heap 10, gPRNheapID, "Debug:Packer strBands", strBands, 0                                 'to aid debugging

            If InStr(strBands, "2") > 0 Or InStr(strBands, "3") > 0 Or InStr(strBands, "4") > 0 Then  'conflict found
               intSuccess = False
            End If
         End If
      
      Case Else            '5 or 6 doses
         intSuccess = False
      End Select

   MapTimesToTimeSlots = intSuccess

End Function

Sub PackerPrintDoc(ByVal title As String, ByVal heading As String, ByVal includefile As String)
'based on QuesPrintView

Dim txt$, Changed%, dummy%
Dim filename As String
Dim filename1 As String
Dim filename2 As String
                                             '"e:\dispdata.002\jvm\s100.inc"
   RTFinternalTransfer$ = "[#include" & TB & includefile & "]"            ' LstBoxFrm.lblTitle & "[cr][ulineon][boldon]" & LstBoxFrm.lblHead & "[boldoff][ulineoff][cr][cr]"
   RTFinternalTitle$ = Iff(Len(title$), title$, "ASCribe")
   RTFinternalHeading$ = ""
   If Len(heading$) Then RTFinternalHeading$ = heading$
   RTFinternalHeader$ = ""
   RTFinternalFooter$ = ""
   
   GetTextFile dispdata$ & "\StdPrint.rtf", txt$, dummy%
   Do
      Changed = False
      ParseStdDataItems txt$, Changed
      ParseCtrlChars dispdata$ & "\printer.ini", "RTF", txt$, Changed
   Loop While Changed
   MakeLocalFile filename
   PutTextFile filename, txt$, 0

   ParseThenPrint "SysMaint", filename, 1, 0, False '04Jul11 TH Added param
   Kill filename

End Sub


