Attribute VB_Name = "BLISTER"
'------------------------------------------------------------------------------------------------
'                            BLISTER.BAS
'
'20Jan98 CFY Written
'            Support routines for blister packing
'
'
'
'------------------------------------------------------------------------------------------------

'MODIFICATION HISTORY
'
'29Jan98 CFY Added code to issue drugs that have been blister packed.
'17Feb98 CFY Added new structure ManBlister for manufactured blisters.
'            New routines to handle printing of blister worksheets.
'            BlisterPackDrug: Now issues drugs that have been packed.
'02Mar98 CFY PrintPatPacks: Added now reads command line for preview mode and prints to
'                           screen if set.
'16Mar98 CFY PrintPatPack: Added PreviewEdit parameter so that an editable preview of the blister
'                          foil can be shown to screen before printing.
'            SinglePrint: Now reads ini file setting in patmed.ini to determine whether or not an editable
'                         preview of the blister pack should be shown.
'17Mar98 CFY BlisterPackDrug: Added Issue parameter.
'                             Issue = TRUE  then prints and issues.
'                             Issue = FALSE then just prints.
'            SinglePrint: Added issue parameter which is passed onto the BlisterPackDrug routine.
'02Sep98 TH  Singleprint: Previewedit parameter now taken from checkbox
'            PrintPatPacks: Added Print on exit for previewedit to allow for Quick print
'14Sep98 CFY PrintPatPacks: Corrected above mod
'25Jan99 CFY InitBlisters: Now reads MaxDescLength from patmed.ini to set the point at which descriptions on
'            the blisters are truncated.
'25Jan99 CFY AddToBlister: Stoped trunctation of dose to allow for decimal points that may be present.
'            Also uses the variable 'MaxDescLen' to determine description truncation length
'            as apposed to being hardcoded.
'24Feb99 CFY ParsePatFront: Can now print wardcode and wardname
'24Feb99 CFY ParsePatBack: Can now print nhi number
'12Apr99 CFY Extended length of string in TDruglist Type so that directions don't get truncated
'11Oct99 CFY CreateTimeRanges: Moved from blister.bas to patprint.bas as is now also used for PIL printing.
'             Removed call to GetTimes so that routine can be used generically. Range$() must now be passed in.
'23Mar01 CFY BlisterPackDrug: Added dp! to issue calculations
'            AddToBlister: added dp! to issue calculation to avoid rounding errors
'15Feb13 XN  IssueDrug: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)

DefInt A-Z
Option Explicit

Const MAX_DRUGS_PER_PACK = 7
Const MAX_DRUGS_PER_BLISTER = 7                 'Max drugs per blister
Const MAX_PACKS = 3                             '04Feb98 CFY Added

Type TDrugList
   SisCode As String * 7
   'drug As String * 40                         '12Apr99 CFY Replaced
   drug As String * 50                          '     "
   Warnings As String * 30                       '** For future use **
End Type

Type TPatBlister                                 'Holds contents of each patient blister
   NumDrugs As Integer
   'drug(MAX_DRUGS_PER_BLISTER) As String * 18  '25Jan99 CFY
   drug(MAX_DRUGS_PER_BLISTER) As String * 20   '    "
End Type

Type TManBlister                                '17Feb98 CFY Added
   drug As String * 18                          'Holds contents of a manufactured blister
   Strength As String * 10                      '
   Batch As String * 15                         '
   expiry As String * 10                        '
End Type

Type TTimeNode                                  'Holds start and end time of each blister
   StartTime As DateAndTime
   EndTime As DateAndTime
End Type

Type TTimeRange                                 'Holds time ranges     '11Oct99 CFY Moved to patprint.bas
   Hrs As Integer
   min As Integer
End Type

Dim WkSheetList() As String * 56                'Holds list of drugs for worksheet
Dim DrugList() As TDrugList
'Dim SummaryArray() As Integer                  '25Jan99 CFY
Dim SummaryArray() As Single                    '    "
Dim TimeMap() As TTimeNode
Dim Blister() As TPatBlister
Dim Across%, down%                              'Number of blisters across and down on this pack
Dim DrugCount%                                  '04Feb98 CFY Added
Dim MaxDescLen%                                 '25Jan99 CFY Added

Function OpenRTF(txt$, filename$) As Integer
'04Jan17 TH Converted to use DB rtf not template files (Hosted)
Dim intSuccess As Integer

   GetRTFTextFromDB dispdata$ & filename$, txt$, intSuccess

   'If Not fileexists(dispdata$ & filename$) Then
   If Not intSuccess Then
         popmessagecr "EMIS Health", "Cannot find file: " & dispdata$ & filename$
         OpenRTF = False
      Else
         'GetTextFile dispdata$ & filename$, txt$, 0
         'GetRTFTextFromDB dispdata$ & filename$, txt$, 0  '06Dec16 TH Replaced (TFS 157969)
         OpenRTF = True
      End If

End Function

Sub ParseBlisters(PackNo, txt$)
'DESCRIPTION
' Runs through the blister array and parses the drug information
' onto the blister rtf

Dim X%, Y%, z%
Dim ParseText$

   'Parse Drugs onto pack
   For Y = 1 To down
      For X = 1 To Across
         For z = 1 To MAX_DRUGS_PER_BLISTER
            ParseText = "[drug" & Trim$(Str$(X)) & Trim$(Str$(Y)) & Trim$(Str$(z)) & "]"
            If z <= Blister(X, Y, PackNo).NumDrugs Then
               replace txt$, ParseText, Blister(X, Y, PackNo).drug(z), 0
            Else
               replace txt$, ParseText, " ", 0
            End If
         Next
      Next
   Next

End Sub

Sub ParseExtraDrugs(txt$)
'At present Removes entries in rtf for extra drugs.
'This is until we decide what to do with PRN's
Dim i%
Dim ParseText$

   For i% = 1 To MAX_DRUGS_PER_PACK
      ParseText$ = "[edrug" & Trim$(Str$(i)) & "]"
      replace txt$, ParseText, " ", 0
   Next

End Sub

Sub ParseHeader(txt$, StartTime As DateAndTime)
'DESCRIPTION
' Parses all header information onto the blister RTF
'24Feb99 CFY Can now print nhi number

Dim X%, found, inuse%
Dim ParseText$, desc$, strDate$
Dim MTime$()

   'Print column times
   GetTimes MTime$(), Across
   For X = 1 To Across
      ParseText$ = "[time" & Trim$(Str$(X)) & "]"
      replace txt$, ParseText, MTime$(X), 0
   Next

   'Print Patient Info
   replace txt$, "[name]", Trim$(pid.forename$) & " " & Trim$(pid.surname), 0
   replace txt$, "[doctor]", Trim$(pid.cons), 0
   DateToString StartTime, strDate$
   replace txt$, "[date]", strDate$, 0
   replace txt$, "[nhi]", pid.caseno, 0
   
   getsupplierward pid.ward, desc$, found%, inuse%
   replace txt$, "[ward]", desc$, 0
   replace txt$, "[hospital]", hospname1$, 0
End Sub

Private Sub ParsePatBack(Pack%, txt$, StartTime As DateAndTime)
'DESCRIPTION
' Parses information for the back sheet of the patient blister pack

   ParseHeader txt$, StartTime
   ParseSummary Pack, txt$
   ParseBlisters Pack, txt$
   
   ParseExtraDrugs txt$

End Sub

Sub ParsePatFront(PackNo%, txt$)
'DESCRIPTION
' Parses patient information onto the front label of the patient blister pack
'
'24Feb99 CFY Can now print wardcode and wardname


Dim X%, found%
Dim ParseText$, wardname$
Dim MTime$()

   'Print column times
   GetTimes MTime$(), Across
   For X = 1 To Across
      ParseText$ = "[time" & Trim$(Str$(X)) & "]"
      replace txt$, ParseText, MTime$(X), 0
   Next

   'Print Patient Info
   replace txt$, "[name]", Trim$(pid.forename$) & " " & Trim$(pid.surname), 0
   replace txt$, "[nhi]", Trim$(pid.caseno), 0
   replace txt$, "[date]", Format$(date, "dd mmmm yyyy"), 0
   replace txt$, "[hospital]", hospname1$, 0
   replace txt$, "[wardcode]", pid.ward, 0
   getsupplierward pid.ward, wardname$, found%, False
   replace txt$, "[wardname]", wardname$, 0

End Sub

Sub ParseSummary(PackNo, txt$)
'DESCRIPTION
' Parses the drug summary onto the blister RTF

Dim X%, Y%, Numoflines%
Dim ParseText$
Dim desc$

   For Y = 1 To MAX_DRUGS_PER_PACK
      
      'Parse drug list
      If Left$(DrugList(Y, PackNo).drug, 1) <> Chr$(0) Then
            desc$ = DrugList(Y, PackNo).drug
         Else
            desc$ = ""
         End If
      ParseText$ = "[drug desc" & Trim$(Str$(Y)) & "]"
      replace txt$, ParseText, desc$, 0
   
      'Parse dosing summary table
      For X = 1 To Across
         ParseText$ = "[d" & Trim$(Str$(X)) & Trim$(Str$(Y)) & "]"
         If SummaryArray(X, Y, PackNo) <> 0 Then
               desc$ = Str$(SummaryArray(X, Y, PackNo))
            Else
               desc$ = " "
            End If
         replace txt$, ParseText, desc$, 0
      Next
   
   Next

End Sub

Sub ParseWkSheetHdr(txt$, StartTime As DateAndTime)

Dim desc$, found%, inuse%, strDate$

   replace txt$, "[name]", Trim$(pid.forename) & " " & Trim$(pid.surname), 0
   replace txt$, "[doctor]", Trim$(pid.cons), 0
   DateToString StartTime, strDate$
   replace txt$, "[date]", strDate$, 0
   replace txt$, "[nhi]", Trim$(pid.caseno), 0

   getsupplierward pid.ward, desc$, found%, inuse%
   replace txt$, "[ward]", desc$, 0
   replace txt$, "[hospital]", hospname1$, 0

End Sub

Sub ParseWkSheetTbl(tbl$)
'17Feb98 CFY Added
'DESCRIPTION
' Parses drug information into the worksheet table
'
Dim i%
Dim TempRow$, TempTbl$

   TempTbl$ = ""
   
   For i = 1 To DrugCount
      TempRow$ = tbl$
      replace TempRow$, "[drug]", WkSheetList(i), 0
      TempTbl$ = TempTbl$ & TempRow$
   Next
   
   tbl$ = TempTbl$

End Sub

Sub PrintPatPacks(StartTime As DateAndTime, PreviewEdit%)
'DESCRIPTION
' Prints the current patient blister pack
'
'17Feb98 CFY Added section to print worksheets
'02Mar98 CFY Added now reads command line for preview mode and prints to
'            screen if set.
'16Mar98 CFY Added PreviewEdit parameter so that an editable preview of the blister
'            foil can be shown to screen before printing.
'02Sep98 TH  Added Print on exit for previewedit to allow for Quick print
'14Sep98 CFY Corrected above mod

Dim Pack%
Dim txt$, tbl$, bfile$, bchan%
   
   For Pack = 1 To UBound(DrugList, 2)
      
      'Print back of pack
      If OpenRTF(txt$, "\BPACK.RTF") Then
            ParsePatBack Pack, txt$, StartTime
            If InStr(Command$, "preview") Then           '02Mar98 CFY Added
                  Hedit 2, txt$                          '       "
               Else                                      '       "
                  If PreviewEdit Then                    '16Mar98 CFY Added
                        MakeLocalFile bfile$                   '02Sep98 TH Added to allow for Quick print
                        bchan = FreeFile                       '     "
                        Open bfile$ For Output As #bchan       '     "
                        Print #bchan, txt$                     '     "
                        'HEdit 1, txt$                    '      "
                        Hedit 11, bfile$                       '     "
                        Hedit 14, "PatFoil" & Nul & bfile$     '     "
                        Close #bchan                           '     "
                        Kill bfile$                            '     "

                     Else                                '      "
                        Hedit 4, "PatFoil" & Nul & txt$
                     End If
               End If
         End If
      
      'Print front of pack
      txt$ = ""
      If OpenRTF(txt$, "\BLSHDR.RTF") Then
            ParsePatFront Pack, txt$
            If InStr(Command$, "preview") Then           '02Mar98 CFY Added
                  Hedit 2, txt$                          '       "
               Else                                      '       "
                  If PreviewEdit Then                    '16Mat98 CFY Added
                        MakeLocalFile bfile$                      '02Sep98 TH Added to allow for Quick print
                        bchan = FreeFile                          '      "
                        'Open bfile$ For Output As FreeFile       '      "
                        Open bfile$ For Output As #bchan          '      "
                        Print #bchan, txt$                        '      "
                        'HEdit 1, txt                             '      "
                        Hedit 11, bfile$
                        'HEdit 14, "PatFoil" & nul & bfile$        '      "      '14Sep98 CFY Corrected
                        Hedit 14, "BlistHdr" & Nul & bfile$        '      "      '           "
                        Close #bchan                              '      "
                        Kill bfile$                               '      "

                     Else                                '       "
                        Hedit 4, "BlistHdr" & Nul & txt$
                     End If
               End If
         End If
    Next

   '04Feb98 CFY Added -----
   'Print patient worksheet
   txt$ = ""
   If OpenRTF(txt$, "\BLWKPHDR.RTF") Then
         ParseWkSheetHdr txt$, StartTime
         tbl$ = ""
         If OpenRTF(tbl$, "\BLWKTBL.RTF") Then
               ParseWkSheetTbl tbl$
               rtfinsert tbl$
               replace txt$, "[drugtable]", Trim$(tbl$), 0
               If InStr(Command$, "preview") Then           '02Mar98 CFY Added
                     Hedit 2, txt$                          '       "
                  Else                                      '       "
                     Hedit 4, "BlistWkSh" & Nul & txt$
                  End If
            End If
      End If
   '-----

End Sub

Sub SetBlisterRange(StartDateTime As DateAndTime, StopDateTime As DateAndTime)
'17Feb98 CFY Added

Dim valid, parseddate$, ParsedTime$, temp$
   
   'Parse and validate startdate
   Do
      temp$ = FrmBlisterPack.TxtBlistStartDt.text
      parsedate temp$, parseddate$, "1", valid
      If Not valid And FrmBlisterPack.TxtBlistStartDt.text <> "" Then
            MsgBox "Please re-enter date"
            FrmBlisterPack.TxtBlistStartDt.SetFocus
         End If
   Loop Until valid And FrmBlisterPack.TxtBlistStartDt.text <> ""
   FrmBlisterPack.TxtBlistStartDt.text = parseddate$
   
   'Parse and validate starttime
   Do
      temp$ = FrmBlisterPack.TxtBlistStartTm.text
      parsetime temp$, ParsedTime$, "1", valid
      If Not valid And FrmBlisterPack.TxtBlistStartTm.text <> "" Then MsgBox "Please re-enter date"
   Loop Until valid And FrmBlisterPack.TxtBlistStartTm.text <> ""
   FrmBlisterPack.TxtBlistStartTm.text = ParsedTime$
   
   StringToDate (FrmBlisterPack.TxtBlistStartDt.text), StartDateTime
   StringToTime (FrmBlisterPack.TxtBlistStartTm.text), StartDateTime
   datetomins StartDateTime
   
   If FrmBlisterPack.TxtBlistStopDt.text <> "" And FrmBlisterPack.TxtBlistStopTm.text <> "" Then
         'Parse and validate stopdate
         Do
            temp$ = FrmBlisterPack.TxtBlistStopDt.text
            parsedate temp$, parseddate$, "1", valid
            If Not valid And FrmBlisterPack.TxtBlistStopDt.text <> "" Then MsgBox "Please re-enter date"
         Loop Until valid Or FrmBlisterPack.TxtBlistStopDt.text <> ""
         FrmBlisterPack.TxtBlistStopDt.text = parseddate$
   
         'Parse and validate starttime
         Do
            temp$ = FrmBlisterPack.TxtBlistStopTm.text
            parsetime temp$, ParsedTime$, "1", valid
            If Not valid And FrmBlisterPack.TxtBlistStopTm.text <> "" Then MsgBox "Please re-enter date"
         Loop Until valid Or FrmBlisterPack.TxtBlistStopTm.text <> ""
         FrmBlisterPack.TxtBlistStopTm.text = ParsedTime$
      
         StringToDate (FrmBlisterPack.TxtBlistStopDt.text), StopDateTime
         StringToTime (FrmBlisterPack.TxtBlistStopTm.text), StopDateTime
         datetomins StopDateTime
      Else
         StopDateTime.mint = 0
      End If

End Sub

Sub SinglePrint(StartTime As DateAndTime, StopTime As DateAndTime, Issue%, PrintPreview%)
'DESCRIPTION
' Prints an adhoc blister pack
'
'16Mar98 CFY Now reads ini file setting in patmed.ini to determine whether or not an editable
'            preview of the blister pack should be shown.
'17Mar98 CFY Added issue parameter which is passed onto the BlisterPackDrug routine.
'02Sep98 TH  Previewedit parameter now taken from checkbox

Dim CreateErr%, BlisterError%, PackToPrint%
Dim Pack%, label%, PreviewEdit%

   InitPatBlisters StartTime, StopTime, BlisterError
   
   If Not BlisterError Then
         'go through each drug (wlabel) and store information in relevent
         'places on blister pack
         PackToPrint = False
         For label = 1 To 50   '** Loop for each label **
''            If labrf&(label) > 0 Then
''                  Labf& = labrf&(label)
''                  getlabel False
''                  If L.Blister Then
''                        BlisterPackDrug StartTime, StopTime, CreateErr, Issue     'Add to to relevent blisters
''                        PackToPrint = True
''                     End If
''               End If
         Next
         
         If PackToPrint Then
               'PreviewEdit = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "BlisterPacking", "N", "PreviewEdit", 0))     '16Mar98 CFY Added
               'PreviewEdit = selecttp.ChkPrintPreview.Value          '02Sep98 TH Added
               PreviewEdit = FrmBlisterPack.ChkPreview.Value
               PrintPatPacks StartTime, PreviewEdit
               EndBlisterPacking
            End If
   End If

End Sub

Sub BlisterPacking()

Dim StartDateTime As DateAndTime
Dim StopDateTime As DateAndTime
Dim CurrStart As DateAndTime
Dim CurrStop As DateAndTime
Dim SevenDays As DateAndTime
Dim sup As supplierstruct
Dim FoundSup As Long, i%, Issue%, PrintPreview%


   'Set Start and stop time for blister pack
   SetBlisterRange StartDateTime, StopDateTime
   Issue = FrmBlisterPack.ChkBookout.Value                        '17Mar98 CFY Added
   PrintPreview = FrmBlisterPack.ChkPreview.Value                 '02Sep98 TH  Added
         
   If StopDateTime.mint > 0 Then                            'Create blister packs for
            SevenDays.day = 7                               'specified period.
            CurrStart = StartDateTime
            CurrStop = CurrStart
            Do While CurrStop.mint < StopDateTime.mint
               AddExpiry CurrStop, SevenDays
               If CurrStop.mint < StopDateTime.mint Then
                     SinglePrint CurrStart, CurrStop, Issue, PrintPreview       '17Mar98 CFY Added Issue parameter
                  Else
                     SinglePrint CurrStart, StopDateTime, Issue, PrintPreview   '17Mar98 CFY Added Issue parameter
                  End If
               CurrStart = CurrStop
            Loop
         Else
            getsupplier pid.ward, 0, FoundSup, sup       'Create blister pack till
            StringToDate sup.topupdate, StopDateTime           'top-up date.
            If StopDateTime.mint > 0 Then
                  SinglePrint StartDateTime, StopDateTime, Issue, PrintPreview '17Mar98 CFY Added Issue parameter '02Sep98 TH Added Printpreview parameter
               Else
                  popmessagecr "!", "Could not print blister pack. Ward topup date not set."
               End If
         End If

   Unload FrmBlisterPack

End Sub

Sub CallBlisterPacking()

   FrmBlisterPack.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form

End Sub

''Function CheckPackNo() As Integer
'''DESCRIPTION
''' Returns the pack number the drug is to be placed into. If the pack number
''' isn't set then 0 is returned.
'''Note pack numbers 0 to 4 currently supported. >=5 should not be used.
'''
'''     flags:   Bit  Value  Usage
'''               7    128   <reserved>
'''               6     64     "
'''               5     32   Blister bit 3
'''               4     16   Blister bit 2
'''               3      8   Blister bit 1
'''               2      4   PatOwn
'''               1      2   PRN
'''               0      1   Manual
'''
''' Byte:    xx101xxx
''' \8       000xx101  right shift
''' AND &H7  00000101  mask
''
''
''Dim iByte%
''
''   iByte = Asc(L.Flags)
''
''   CheckPackNo = (iByte \ 8) And &H3   ' right shift by 3 bits, and mask the last 2 bits
''
''End Function

Private Function CreateNewPack(PackNo%) As Integer
'DESCRIPTION
' Creates the necessary structures for an extra patient blister pack

   On Error GoTo CreateNewPack_Error
   ReDim Preserve DrugList(MAX_DRUGS_PER_PACK, PackNo)
   ReDim Preserve SummaryArray(Across, MAX_DRUGS_PER_PACK, PackNo)
   ReDim Preserve Blister(Across, down, PackNo)
   On Error GoTo 0
   CreateNewPack = True

CreateNewPack_Exit:
Exit Function

CreateNewPack_Error:
   CreateNewPack = False
Resume CreateNewPack_Exit

End Function

Sub CreateTimeMap(startdate As DateAndTime, StopDate As DateAndTime)
'DESCRIPTION
' Used to initialise the blister packing. When passed a start date the routine calculates
' a map of start and stop time for each blister on the pack. This map can then be used
' later to determine which blister a particular prescribed drug should fill.
   
Dim FromRange() As TTimeRange
Dim ToRange() As TTimeRange
Dim X%, Y%
Dim CurrentBlister As DateAndTime
Dim OneDay As DateAndTime
Dim DayNum%
Dim range$()

popmessagecr ".", "CreateTimeMap called in blister packing - not currently supported"
Stop '**!!**

   OneDay.day = 1
   DayNum = DayOfWeek(startdate)                      '1=Mon 7=Sun

   GetTimes range$(), Across                          '11Oct99 CFY Added
''   CreateTimeRanges FromRange(), ToRange(), range$(), Across

   'Create and populate the Date/Time map
   ReDim DateTimeMap(Across, down)
   CurrentBlister = startdate

   For Y = 1 To 7
      For X = 1 To Across
         CurrentBlister.Hrs = FromRange(X).Hrs
         CurrentBlister.min = FromRange(X).min
         datetomins CurrentBlister
         TimeMap(X, DayNum).StartTime = CurrentBlister
         CurrentBlister.Hrs = ToRange(X).Hrs
         CurrentBlister.min = ToRange(X).min
         If X = Across Then
               AddExpiry CurrentBlister, OneDay    'Get the next date.
            End If
         datetomins CurrentBlister
         TimeMap(X, DayNum).EndTime = CurrentBlister
      Next

      If DayNum < 7 Then
            DayNum = DayNum + 1           'Once we've got DayNum using getday is it
         Else                             'faster to work out the days ourself here
            DayNum = 1                    'rather than keep calling getday?
         End If
   Next

End Sub

Sub EndBlisterPacking()
'DESCRIPTION
' Clears all structures related to the blister packing
'
'17Feb98 CFY Added code to delete WkSheet list array

   Erase WkSheetList       '04Feb98 CFY Added
   Erase DrugList
   Erase SummaryArray
   Erase Blister
   Erase TimeMap

End Sub

''Private Sub GetDoseInterval(mins&)
'''DESCRIPTION
''' Gets Dose interval
''
''   mins& = L.EqualInterval
''   Select Case L.TimeUnits
''      Case "day": mins& = mins& * 1440
''      Case " wk": mins& = mins& * 10080
''      Case " hr": mins& = mins& * 60
''   End Select
''
''End Sub

Function GetIssueDays(DosingDays() As Boolean) As String
'DESCRIPTION
' Get the days the drug is issued on
'09May05 CKJ Changed Sub into Function and passed array explicitly

Dim X%
Dim dow$

   dow$ = ""
   For X = 1 To 7
      If DosingDays(X) Then dow$ = dow$ & Format$(X)
   Next
   If dow$ = "" Then dow$ = "1234567"
   GetIssueDays = dow$
   
End Function

Sub GetTimes(MTime$(), NumTimes%)
'DESCRIPTION
' Reads time headings for each blister column and returns values in MTime$

Dim Numoflines%
Dim TimesString$

   ReDim MTime$(NumTimes%)
   
   TimesString$ = TxtD(dispdata$ & "\PATMED.INI", "BlisterPacking", "0530,1030,1530,2130", "Times", 0)
   deflines TimesString$, MTime$(), ",", 1, Numoflines

End Sub

Private Sub GetTimesDoses(Ldose!(), LTime$())
'DESCRIPTION
' Get the times & doses for each day

Dim X%
      
   On Error Resume Next                                      'warn user instead of ignoring?
   For X = 1 To UBound(Ldose!, 1)
      If L.dose!(X) = 0 Then Exit For
      Ldose!(X) = L.dose!(X) / d.dosesperissueunit           '!!** May need more checking
      LTime$(X) = L.Times(X)
   Next
   On Error GoTo 0

End Sub

Sub InitPatBlisters(StartTime As DateAndTime, StopTime As DateAndTime, BlisterError%)
'DESCRIPTION
' Initialises structures ready for patient blister packing
'
'04Feb98 CFY Added initialisation of DrugCount
'17Feb98 CFY Added Error handling
'25Jan99 CFY Now reads MaxDescLength from patmed.ini to set the point at which descriptions on
'            the blisters are truncated.

Dim msg$

   BlisterError = False
   If StopTime.mint > StartTime.mint Then
         On Error GoTo InitBlisterError
         Across = Val(TxtD(dispdata$ & "\PATMED.INI", "BlisterPacking", "4", "BlistersAcross", 0))
         down = Val(TxtD(dispdata$ & "\PATMED.INI", "BlisterPacking", "7", "BlistersDown", 0))
         MaxDescLen% = Val(TxtD(dispdata$ & "\PATMED.INI", "BlisterPacking", "15", "MaxDescLength", 0))        '25Jan99 CFY Added
         If MaxDescLen% <= 0 Or MaxDescLen% >= 20 Then
               msg$ = "Warning! MaxDescLength in patmed.ini has been set at " & Format$(MaxDescLen%) & "." & crlf
               msg$ = msg$ & "Valid range is 0 to 20." & crlf
               msg$ = msg$ & "MaxDescLength has been set to 15"
               popmessagecr "!", msg$
               MaxDescLen% = 15
            End If

         ReDim WkSheetList(MAX_DRUGS_PER_PACK * MAX_PACKS)
         ReDim DrugList(MAX_DRUGS_PER_PACK, 1)
         ReDim SummaryArray(Across, MAX_DRUGS_PER_PACK, 1)
         ReDim Blister(Across, down, 1)
         ReDim TimeMap(Across, down)
         
         CreateTimeMap StartTime, StopTime
      
         DrugCount = 0    '04Feb98 CFY Added
      Else
         popmessagecr "!", "Stop time must be later than than the Start time."
         BlisterError = True
      End If
      On Error GoTo 0

InitBlister_Exit:
Exit Sub

InitBlisterError:
   popmessagecr "!", "Procedure: Initblisters: Error Creating blister structures."
   BlisterError = True
   Resume Next

End Sub

Sub IssueDrug(DosesForIssue!, Qty!, lngIPDfound As Long)
'17Feb98 CFY Added
'DESCRIPTION
' Issues drugs that have been added to the blister packs
'01Jun02 All/CKJ definition was Sub IssueDrug (DosesForIssue!, QTY!, ipdfound), ie implicit type for ipdfound.
'                Changed to Long
'15Feb13 XN  Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)

Dim issuetype$
Dim IssueCost$ '!!** what is this?

   If DosesForIssue! > 0 And Not L.ManualQuantity Then
         issuetype$ = L.IssType
         
         If issuetype$ = "S" Then issuetype$ = "M"
         
         Translog d, (lngIPDfound), UserID$, pid.recno, Qty!, L.dircode, pid.ward, pid.cons, pid.status, SiteNumber, issuetype$, IssueCost$
         
         L.RxNodIssued = dp!(L.RxNodIssued + DosesForIssue!)
         L.Nodissued = dp!(L.Nodissued + Qty!)
         
         'If L.lastdate <> thedate(False, True) Then  40210 XN 15Feb13 use proper date\time for WLabel
         If LastSavedDateTimeToLastDate(L.lastSavedDateTime) <> LastSavedDateTimeToLastDate(Now) Then
               L.lastqty = Qty!
            Else
               L.lastqty = dp!(L.lastqty + Qty!)
            End If
         
         L.lastSavedDateTime = Now    '    40210 XN 15Feb13 use proper date\time for WLabel  L.lastdate = thedate(False, True)
         Putlabel L
      End If

End Sub

Sub AddToBlister(PackNo%, DateTime&, thisdose!, found%)
'DESCRIPTION
' Takes a single issue of a drug and determine which blister it should be added to.

'17Feb98 CFY Changed dose calculation from divide to multiply!!!
'25Jan99 CFY Stoped trunctation of dose to allow for decimal points that may be present.
'            Also uses the variable 'MaxDescLen' to determine description truncation length
'            as apposed to being hardcoded.
'23Mar00 CFY added dp! to issue calculation to avoid rounding errors (#50734)

Dim X%, Y%, x1%, y1%
Dim NumDrugs%
Dim StartMins&, EndMins&
Dim Numoflines%
Dim drug$
'Dim dose As String * 2    '25Jan99 CFY
Dim dose As String         '     "

   found = False
   ReDim DescLine$(10)
   
   'Determine which blister to add to
   For Y = 1 To down
      For X = 1 To Across
         StartMins = TimeMap(X, Y).StartTime.mint
         EndMins = TimeMap(X, Y).EndTime.mint
         If DateTime& >= StartMins And DateTime <= EndMins Then
               found = True
               Exit For
            End If
      Next
      If found = True Then Exit For
   Next

   'Add the drug to the blister if it will fit
   If found Then
         NumDrugs = Blister(X, Y, PackNo).NumDrugs
         If NumDrugs < MAX_DRUGS_PER_BLISTER Then
               '!!** Need to also check a drug has already been added to this blister
               '     and decide what to do!
               NumDrugs = NumDrugs + 1
               Blister(X, Y, PackNo).NumDrugs = NumDrugs
               'deflines d.Description, DescLine$(), "!", 1, Numoflines
               deflines d.LabelDescription, DescLine$(), "!", 1, Numoflines
               'drug$ = Left$(DescLine$(1), 15)           '25Jan99 CFY
               'drug$ = pad$(drug$, 15)                   '    "
               drug$ = Left$(DescLine$(1), MaxDescLen)    '    "
               drug$ = pad$(drug$, MaxDescLen)            '    "
               
               'thisdose! = thisdose! * d.dosesperissueunit  '17Feb98 CFY Changed from divide to multiply!!!   '23Mar00 CFY added dp!
               thisdose! = dp!(thisdose! * d.dosesperissueunit)                                                '         "
               
               dose$ = Format$(thisdose!)
               Blister(X, Y, PackNo).drug(NumDrugs) = drug$ & "x" & dose$
               AddToSummary PackNo, X, dose$
            Else
               '!!** Give some error!
            End If
      End If

End Sub

Sub AddToDrugList(PackNo%)
'DESCRIPTION
' Adds drug information to the list of drugs which is printed at the top of
' the blister pack

Dim Numoflines%, i&
Dim DescValue As String * 25
   
   ReDim DescLine$(5)

   'deflines d.Description, DescLine$(), "!", 1, Numoflines
   deflines d.LabelDescription, DescLine$(), "!", 1, Numoflines
   DescValue = DescLine$(1)
   
   For i = 1 To MAX_DRUGS_PER_PACK
      If Left$(DrugList(i, PackNo).SisCode, 1) = Chr$(0) Then
            DrugList(i, PackNo).SisCode = d.SisCode
            DrugList(i, PackNo).drug = DescValue$ & pad$(Str$(d.dosesperissueunit) & d.DosingUnits, 10) & L.dircode
            Exit For
         End If
   Next

End Sub

Private Sub AddToSummary(PackNo%, X%, dose$)
'DESCRIPTION
' Adds information to the dosing summary table

Dim i%

   For i = 1 To MAX_DRUGS_PER_PACK
      If DrugList(i, PackNo).SisCode = d.SisCode Then
            SummaryArray(X, i, PackNo) = Val(dose$)
            Exit For
         End If
   Next
       
End Sub

Sub AddToWkSheet()
'04Feb98 CFY Added
'DESCRIPTION
' Stores drug information ready to to be parsed onto the worksheet.

Dim desc$
   
   DrugCount = DrugCount + 1
   If DrugCount <= UBound(WkSheetList, 1) Then
         desc$ = d.LabelDescription
         plingparse desc$, "!"
         WkSheetList(DrugCount) = desc$
      Else
         '!!** Error
      End If

End Sub

Sub BlisterFormInit()

Dim startdt$, StopDt$, StartTm$, StopTm$
Dim StartDateT As DateAndTime
Dim StopDateT As DateAndTime
Dim SevenDays As DateAndTime

   today StartDateT
   SevenDays.day = 7
   StopDateT = StartDateT
   AddExpiry StopDateT, SevenDays
   DateToString StartDateT, startdt$
   TimeToString StartDateT, StartTm$
   DateToString StopDateT, StopDt$
   TimeToString StopDateT, StopTm$
   FrmBlisterPack.TxtBlistStartDt.text = startdt$
   FrmBlisterPack.TxtBlistStartTm.text = Format$(StartTm$, "00:00")
   FrmBlisterPack.TxtBlistStopDt.text = StopDt$
   FrmBlisterPack.TxtBlistStopTm.text = Format$(StopTm$, "00:00")

End Sub

Sub BlisterPackDrug(StartTime As DateAndTime, StopTime As DateAndTime, Create%, Issue%)
'DESCRIPTION
' Adds a drug to the blister pack.
' This routine assumes that a patient and a medication is currently loaded.
'
'17Feb98 CFY Added call to new procedure 'AddToWkSheet'
'            Extra code to handle issuing of packed items.
'17Mar98 CFY Added Issue parameter.
'            Issue = TRUE  then prints and issues.
'            Issue = FALSE then just prints.
'23Mar01 CFY Added dp! to issue calculations (#50734)

Dim doses!, cont&, thisdose!, DosesForIssue!, Qty!       'mins&,
Dim dos As DateAndTime
Dim X%
Dim Added%
Dim PackNo%

Dim lngIPDfound As Long
Dim issuetype$

   ReDim Ldose!(6)
   ReDim LTime$(6)
   
   'Find out which pack this drug is to be placed into. If structures
   'for the pack don't yet exist then create them.
   Create = True
   PackNo% = L.Blister
   If PackNo% > UBound(DrugList, 2) Then
         Create = CreateNewPack(PackNo)
      End If

   If Create Then
         BlankWProduct d
         d.SisCode = L.SisCode
        
         If d.SisCode <> "" Then
               getdrug d, False, lngIPDfound, False
            Else
               lngIPDfound = 0
            End If
         
         If lngIPDfound Then
               AddToWkSheet                       'Add drug to the work sheet (04Feb98 CFY Added)
               AddToDrugList PackNo               'Add drug to summary table
               
               GetTimesDoses Ldose!(), LTime$()   'Get the times & doses for each day
''               GetDoseInterval mins&              'Get Dose interval
''               GetIssueDays dow$                  'Get the days the drug is issued on
               
               cont& = 0
               DosesForIssue! = 0
               Do
''                  DosesBetweenTimes False, Ldose!(), LTime$(), (mins&), L.days(), StartTime, StopTime, doses!, cont&, thisdose!
                  DosesBetweenTimes False, Ldose!(), LTime$(), L.days(), StartTime, StopTime, doses!, cont&, thisdose!
                  If cont& <> 0 And Not L.ManualQuantity Then
                        AddToBlister PackNo, cont&, thisdose!, Added
                        If Added Then
                              DosesForIssue! = DosesForIssue! + dp!(thisdose!)      '         "
                           End If
                     End If
               
               Loop While cont& <> 0
               
               If Issue Then                                   '17Mar98 CFY Added
                     Qty! = dp!(DosesForIssue!)
                     IssueDrug DosesForIssue!, Qty!, lngIPDfound
                  End If

            Else
               '!!** failed to create another pack ... msg to user?
            End If
      
      End If
End Sub

