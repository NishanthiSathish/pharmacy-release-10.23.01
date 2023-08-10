Attribute VB_Name = "StoresNew"
'Storesnew.bas Modification history
'
'14Oct05 TH  Storesparsedate: A stores version of parsedate that will not allow zero days or months
'14Oct05 TH  StoresDateValid: As normal DateValid, but zero days or months are NOT permitted
'14Jan13 TH  EditFiles: Ported - convert PILdesc.ini (TFS 51363)
'21Jan13 TH  EditFiles: Trim leading zero's from PIL filename and check with user (TFS 53690)
'08Mar13 TH  EditFiles: Added to reset msg when looping due to change in pad (TFS 58122)


Sub Storesparsedate(ByVal TextIn$, Out$, dformat$, valid%)
'14Oct05 TH A stores version of parsedate that will not allow zero days or months
'unlike the original, as these are NOT permitted here and can damage financial interfaces and reporting !

'------------------------------------------------------------------------------------------------
'Accepts dates in following formats:
'
'  dd_mm_yy     dd_mm_yyyy   - variable length, dd = 4 or 04
'                              and _ is any non numeric character
'                            - If year is absent then current year is assumed
'  ddmmyy       ddmmyyyy     - fixed length, leading zeros needed:  dd = 04
'  US<date>                  - precede any of the above with US to
'                              accept month, day, year
'  dd Monthname yy           - all the above accept Jan, January, etc as month
'  +nnD -nnD +nnW -nnW       - nn days or weeks in the future or past
'                              nn is from 1 to 9999 days or weeks
'  +nnM -nnM +nnY -nnY       - nn months or years in the future or past
'                              max 100 years either way
'  ccyy-mm-dd                - must be zero prefixed, dash separated, ten chars only
'  ccyy-mm-ddT00:00:00.000   - as above but with canonical time of midnight
'
'  T today
'  Y yesterday
'  M tomorrow
'
'Returns date in one of the formats
' dformat$ = "1"  DD/MM/CCYY
'            "1-" DD-MM-CCYY    * Note 2
'            "2"  DD/MM/YY
'            "2-" DD-MM-YY      * Note 2
'            "3"  DDMMCCYY
'            "4"  DDMMYY
'            "5"  MMDDYY        American for ATC
'            "6"  DDMmmCCYY     Month as Jan Feb etc
'            "7"  DD Mmmm CCYY  Month as January February etc
'            "8"  DD/MM/CCYY    Identical to Format 1, but two digit years span 1980-2079
'            "9"  DD/MM/CCYY    Identical to Format 1, but two digit years span (now-99) to (now)
'  "dd-mmm-ccyy"  User defined allows any of DD DDD DDDD MM MMM MMMM CC YY YYYY and punctuation
'
'Note 1:
' If dformat$ = "" then format "1" is used

'Note 2:
' Formats 1 & 2 only can have a second, optional, character which specifies
' the separator to be used instead of '/'. This can be any printable character
' including space eg if dformat$ = "1 " then 'dd mm yyyy' is returned.
'
'Note 3:
' User defined formats allow any combination of the following (in upper/lower case)
'  DD   day with leading zero
'  DDD  day name, first 3 chars, 1st char upper case
'  DDDD day name in full, 1st char upper case
'  MM   month number with leading zero
'  MMM  month name, first 3 chars, 1st char upper case ('---' if zero)
'  MMMM month name in full, 1st char upper case ('---' if zero)
'  CC   century, 00 to 40
'  YY   year as two digits, leading zero or '00' as appropriate
'  YYYY year as combination of CCYY
'       plus any other printable characters may be added as required
'
' e.g. 'DD-MM-YY (DD MMMM CCYY)' -> '04-01-98 (04 January 1998)'
'
'Note 4:
' Returns dformat$ = "0" if any of dd, mm or yyyy are zero, otherwise
' dformat$ is unchanged.
'
'Note 5:
' In$ is unchanged on exit
'
'Note 6:
' A Millenium window operates on all two digit years (where year is 1-99, '0' or '00')
' but not if the year is 3 or 4 digits or blank.
' A sliding window is calculated based on the current year. For example with a cutoff
' of +10 years, in 1998 two digit years are interpreted in the range 1909-2008,
' but by 2000 the range becomes 1911 to 2010, and in 2007 it becomes 1918-2017.
' The cutoff can be set in ASCRIBE.INI:[Dates]TwoDigitYearCutoff=xx if 10 is not suitable.
' A similar mechanism operates for dates of birth but the offset is zero, ie the date
' is interpreted as current year back to 99 years ago. This is specified by format "9"
'
'Modifications
'20Feb94 ASC added format 5
'14Mar94 CKJ Corrected the above mod
'15Jan95 KR  Changed first parameter to byval so that it can accept input from text boxes
'11Sep96 CKJ Added +/-Months and +/-Years
'            Month names, eg 1 Jan   04March96   5Jul
'            Note that with month names, only spaces can be used to separate
'            parts of the date. 3/4/5 letter abbrevs are all accepted, as are
'            full names in upper/lower/mixed case
'            User defined format added, plus formats 6 & 7
'            Note that for formats 1 & 2, the separator char must now follow the digit
'07May97 CKJ Added ddd and dddd formats to the user defined type
'23Jun97 CKJ Format 8 added: Millenium switch at 'xx80'
'03May98 CKJ Y2K now uses sliding window for all 2 digit years.
'            This window default is (now-89) to (now+10) years, except for
'            dates of birth (new format "9") for which the window is (now-99) to (now)
'            Format "8" no longer has any special meaning. It is equivalent to format "1"
'            as all formats now use the sliding window. See Note 6 (above) for more detail
'26Nov98 CKJ Corrected format 9 when full 'ccyy' is provided
'14Feb03 CKJ Added canonical date format 'ccyy-mm-dd'  These must be ten characters, dash
'            separated, zero padded dates in this format and is mainly for XML based transfer
'            Added canonical date and time 'ccyy-mm-ddT00:00:00.000' where the time portion
'            has to be midnight otherwise the entry is rejected.
'------------------------------------------------------------------------------------------------

Dim dt As DateAndTime
Dim temp As Integer              '14Dec95 KR used for swap
Dim lastsep$, incopy$, formatcopy$, swapdaymth As Integer, Offset$, days#, x As Integer, char$
Dim sep$, numoflines%, count As Integer
Dim dd$, ddd$, dddd$, mm$, mmm$, mmmm$, cc$, yy$, mult%, dat$, fmt$
Dim Limit%, Cutoff%, Century%
Dim strTemp As String
Dim YYcutoff$

Static aline$(10)                '14Dec95 KR Use static for fixed bound arrays within proc
   
   ReDim mths$(0 To 12)

   valid = True
   lastsep$ = ""
   incopy$ = TextIn$
   TextIn$ = UCase$(TextIn$)
   formatcopy$ = dformat$

   swapdaymth = False
   If Left$(TextIn$, 2) = "US" Then
         swapdaymth = True
         TextIn$ = Mid$(TextIn$, 3)
      End If

   '14feb03 CKJ Added canonical format filter 'ccyy-mm-dd' and 'ccyy-mm-ddT00:00:00.000'
   If Len(TextIn$) = 23 Then                                       'full canonical length
         If Right$(TextIn$, 13) = "T00:00:00.000" Then             'with midnight specified
               TextIn$ = Left$(TextIn$, 10)                            'keep just the date portion
            End If
      ElseIf Len(TextIn$) = 19 Then                                'shortened canonical length
         If Right$(TextIn$, 9) = "T00:00:00" Then                  'with midnight specified
               TextIn$ = Left$(TextIn$, 10)                            'keep just the date portion
            End If
      End If
   If Len(TextIn$) = 10 Then                                       'length is right
         If Mid$(TextIn$, 5, 1) = "-" Then                         'and dashes are in
               If Mid$(TextIn$, 8, 1) = "-" Then                   'specific locations
                     strTemp = TextIn$
                     replace strTemp, "-", "", 0               'remainder are all digits?
                     If IsDigits(strTemp) Then                 'swap to standard format
                           TextIn$ = Right$(TextIn$, 2) & Mid$(TextIn$, 5, 4) & Left$(TextIn$, 4)   'dd -mm- yyyy
                         End If
                  End If
            End If
      End If

   Select Case TextIn$
      Case "T", "Y", "M"
         today dt
         If TextIn$ = "Y" Then dt.mint = dt.mint - mind
         If TextIn$ = "M" Then dt.mint = dt.mint + mind
         minstodate dt
         DateToString dt, TextIn$
      End Select

   Select Case Left$(TextIn$, 1)
      Case "+", "-"
         today dt
         Offset$ = Left$(TextIn$, Len(TextIn$) - 1)   ' remove the letter eg +9999W
         days = 0
         On Error Resume Next
         days = Val(Left$(Offset$, 5))        ' max is +9999
         On Error GoTo 0
         Select Case Right$(TextIn$, 1)
            Case "D": mult = 1                ' +3d -21d days
            Case "W": mult = 7                ' +3w -5w weeks
            Case "M": mult = 28               ' +3m -6m 'months' at 4 weeks per month
            Case "Y": mult = 365              ' +1y -2y years at 365 days per year
            Case Else: TextIn$ = ""               ' not valid
            End Select

         If 1# * mult * days > 70000# Then
               TextIn$ = ""                       ' not valid
            End If

         If Len(TextIn$) Then                     ' still valid
               dt.mint = dt.mint + mind * days * mult
               minstodate dt
               DateToString dt, TextIn$
            End If
      End Select
                   
   count = 0                                  '06May98 CKJ Improve performance;
   For x = 1 To Len(TextIn$)                      '            Look for an alpha char
      Select Case Mid$(TextIn$, x, 1)             '
         Case "a" To "z", "A" To "Z"          '            Only do Month name replaces
            count = count + 1                 '            if at least three letters found
         End Select                           '
   Next                                       '
   If count > 2 Then                          '            Proceed to scan month names
         deflines UCase$(monthname$), mths$(), "¦", 0, numoflines%
         For x = 1 To 12
            replace TextIn$, mths$(x), Format$(x, " 00 "), 6            'min length 1August
            replace TextIn$, Left$(mths$(x), 5), Format$(x, " 00 "), 5  'min length 1April
            replace TextIn$, Left$(mths$(x), 4), Format$(x, " 00 "), 4  'min length 1June
            replace TextIn$, Left$(mths$(x), 3), Format$(x, " 00 "), 3  'min length 1May
         Next
      End If
   replace TextIn$, "  ", " ", 4
   TextIn$ = RTrim$(TextIn$)

   For x = 1 To Len(TextIn$)
      char$ = Mid$(TextIn$, x, 1)
      If InStr("0123456789", Mid$(TextIn$, x, 1)) = 0 Then
            If sep$ = lastsep$ Or lastsep$ = "" Then
                  sep$ = char$
                  lastsep$ = sep$
               Else
                  valid = False
               End If
         End If
   Next

   If valid Then
         'If sep$ = "" And Len(in$) > 5 Then     'ddmmyy ddmmyyyy   '!!** add more here?
         'If IsDigits(in$) And (Len(in$) = 6 Or Len(in$) = 8) Then  'ddmmyy ddmmyyyy
         If (Len(TextIn$) = 6 Or Len(TextIn$) = 8) Then  'ddmmyy ddmmyyyy
               If IsDigits(TextIn$) Then             '06May98 CKJ Performance: split the line
                     TextIn$ = Left$(TextIn$, 2) & "/" & Mid$(TextIn$, 3, 2) & "/" & Mid$(TextIn$, 5)
                     sep$ = "/"
                  End If
            End If
         deflines TextIn$, aline$(), sep$ + "(*)", 1, numoflines%
         If numoflines% = 2 Then
               aline$(3) = Right$(date$, 4)
               numoflines% = 3
            End If
         If numoflines% = 3 Then
               dt.day = 0
               dt.mth = 0
               dt.Yrs = 0
               On Error Resume Next
               dt.day = Val(aline$(1))
               dt.mth = Val(aline$(2))
               dt.Yrs = Val(aline$(3))
               On Error GoTo 0
               If swapdaymth Then 'SWAP dt.day, dt.mth    '14Dec95 KR
                     temp = dt.mth
                     dt.mth = dt.day
                     dt.day = temp
                  End If

               'Adds 1800, 1900 or 2000 if year is '0' '00' or 1-99 but not if it is blank
               If (dt.Yrs > 0 And dt.Yrs < 100) Or aline$(3) = "0" Or aline$(3) = "00" Then
                     '03May98 CKJ Y2K now uses Millenium sliding window for all 2 digit years
                     If YYcutoff$ = "" Then                               'undefined first time
                           YYcutoff$ = "10"                               'use default or ini file
                           YYcutoff$ = TxtD(dispdata$ & "\ascribe.ini", "Dates", (YYcutoff$), "TwoDigitYearCutoff", 0)
                           Select Case Val(YYcutoff$)                     'is it within range?
                              Case Is < 0, Is > 99: YYcutoff$ = "10"      'No: revert to default
                              End Select
                        End If
                     Limit = Val(YYcutoff$)                               'sets the upper limit
                     If Left$(dformat$, 1) = "9" Then Limit = 0           'date of birth entry
                     Cutoff = (Val(Right$(date$, 2)) + Limit) Mod 100     'eg 10 to (1)09
                     If dt.Yrs <= Cutoff Then                             'use higher century
                           Century = Val(Right$(date$, 4)) + Limit        ' eg 18xx or 19xx
                        Else                                              'use lower century
                           Century = Val(Right$(date$, 4)) - (99 - Limit) ' eg 19xx or 20xx
                        End If                                            '
                     dt.Yrs = dt.Yrs + Century - (Century Mod 100)        'so add 1800/1900/2000
                     
                     '03May98 CKJ Y2K Superceded. Format "8" now same as "1"
                     'If Left$(dformat$, 1) = "8" Then     'Millenium switch at 'xx80' 23Jun97 CKJ
                     '      If dt.yrs < 80 Then            'ddmm00 -> ddmm2000
                     '            dt.yrs = dt.yrs + 2000   'ddmm79 -> ddmm2079
                     '         Else                        'ddmm80 -> ddmm1980
                     '            dt.yrs = dt.yrs + 1900   'ddmm99 -> ddmm1999
                     '         End If
                     '   Else
                     '      dt.yrs = dt.yrs + Val(Mid$(Date$, 7, 2)) * 100 'Add current century
                     '   End If
                  End If
               If dt.day = 0 Or dt.mth = 0 Or dt.Yrs = 0 Then formatcopy$ = "0"
               StoresDateValid dt, valid
            Else
               valid = False
            End If
      End If
   
   If valid Then
         deflines monthname$, mths$(), "¦", 0, numoflines%
         DateToString dt, Out$                       'dd/mm/ccyy
         dd$ = Left$(Out$, 2)                        '04
         dddd$ = dayname$(DayOfWeek(dt))             'Wednesday
         ddd$ = Left$(dayname$(DayOfWeek(dt)), 3)    'Wed
         mm$ = Mid$(Out$, 4, 2)                      '02
         mmmm$ = mths$(Val(mm$))                     'February or ---
         mmm$ = Left$(mmmm$, 3)                      'Feb      or ---
         cc$ = Mid$(Out$, 7, 2)                      '19
         yy$ = Right$(Out$, 2)                       '96
         sep$ = Mid$(dformat$, 2, 1)
         If sep$ = "" Then sep$ = "/"
         Select Case Left$(dformat$, 1)
            Case "1", "8", "9": fmt$ = "dd" & sep$ & "mm" & sep$ & "ccyy"  '23Jun97 CKJ Added "8" '26Nov98 CKJ added "9"
            Case "2":           fmt$ = "dd" & sep$ & "mm" & sep$ & "yy"
            Case "3":           fmt$ = "ddmmccyy"
            Case "4":           fmt$ = "ddmmyy"
            Case "5":           fmt$ = "mmddyy"
            Case "6":           fmt$ = "ddMmmyy"
            Case "7":           fmt$ = "dd Mmmm yy"
            Case Else:          fmt$ = dformat$
            End Select
         Out$ = fmt$
         replace Out$, "dd", "DD", 0          'dd->DD ddd->DDd and dddd->DDDD
         replace Out$, "DDDD", "¦2", 0
         replace Out$, "DDd", "¦1", 0         'DDd->Tue
         replace Out$, "DDD", "¦1", 0         'DDD->Tue
         replace Out$, "DD", dd$, 0

         replace Out$, "mm", "MM", 0          'mm->MM mmm->MMm and mmmm->MMMM
         replace Out$, "MMMM", "¦4", 0
         replace Out$, "MMm", "¦3", 0         'MMm->Jan
         replace Out$, "MMM", "¦3", 0         'MMM->Jan
         replace Out$, "MM", mm$, 0

         replace Out$, "yy", "YY", 0          'yy->YY and yyyy->YYYY
         replace Out$, "YYYY", cc$ & yy$, 0
         replace Out$, "cc", cc$, 0
         replace Out$, "CC", cc$, 0
         replace Out$, "YY", yy$, 0

         replace Out$, "¦1", ddd$, 0          'DDD->Tue
         replace Out$, "¦2", dddd$, 0         'DDDD->Tuesday
         replace Out$, "¦3", mmm$, 0          'MMM->Jan
         replace Out$, "¦4", mmmm$, 0         'MMMM->January
      Else
         Out$ = incopy$
      End If
   TextIn$ = incopy$
   dformat$ = formatcopy$ '14Mar94 CKJ set to '0' if dd=0 or mm=0 or yy=0 '!!** remove yy?

End Sub
Sub StoresDateValid(dt As DateAndTime, valid)
'14Oct05 TH As normal DateValid, but zero days or months are NOT permitted
'-----------------------------------------------------------------------------
'                Takes a date & time structure & returns T/F
'-----------------------------------------------------------------------------
Dim dm As Integer

   valid = True     ' assume innocent until proven ...
   If Abs(dt.Yrs) > 4000 Then valid = False
   If dt.mth < 0 Or dt.mth > 12 Then
         valid = False
      Else                            'else added ASC 22-01-91
         dm = daysinmonth(dt.mth)
         If dt.mth = 2 Then If isleapyear(dt.Yrs) Then dm = 29 '17Feb91 CKJ extra IF to speed it up
         If dt.day < 1 Or dt.day > dm Then valid = False '13Oct05 TH Change to 1
         If dt.Hrs < 0 Or dt.Hrs > 23 Then valid = False
         If dt.min < 0 Or dt.min > 59 Then valid = False
      End If

End Sub
Sub EditFiles(Filepath$, fileext$, Caption$, Mode%, SelectedFile$)
'23Sep99 CFY Written
'05Jan00 AW Changed to check for "<New>" rather than "New".
'12Jan00 SF added call to FlushIniCache: so descriptions held in ini files can be changed and displayed
'           without having to exit the program

'Will create a ini file to store a human readable description of each file
'This is then presented as a list to the user in order to select the file to edit.
'
' Given :   Filepath$:     a file path in which rtf files are located
'           FileExt$:      a common file extension
'           Caption$:      Caption on title bar
'           Mode:          1 = Edit, 2 = View, 3 = Select
'Pass Back: SelectedFile$: Filename selected
'
'26Nov99 AW  added extra menu item to allow new files to be created
'12Jun02 CKJ Corrected faults in the 'New' routine. Overhauled & tidied
'14Jan13 TH Ported - convert PILdesc.ini (TFS 51363)
'21Jan13 TH Trim leading zero's from PIL filename and check with user (TFS 53690)
'08Mar13 TH Added to reset msg when looping due to change in pad (TFS 58122)

Dim NumEntries%, i%, numoflines%, Choice%, Selected%
Dim iniFile$, FILE$, FileFound$, text$, ans$, msg$
Dim blnValid As Integer          '12Jun02 CKJ
Dim strExtn As String            '   "
Dim intSuccess As Integer        '09Jan17 TH Added
Dim strRTFTextCopy As String     '   "
Dim strRTFText As String         '   "
Dim lngOK As Long                '   "


   FlushIniCache     '12Jan00 SF added to refresh any descriptions changed ini files without having to exit the program
   ReDim lines$(5)
   ReDim Action%(4)
   strExtn = UCase$(Trim$(fileext$))                                                      '12Jun02 CKJ
   iniFile$ = Filepath$ & "\" & strExtn & "desc.ini"                                      'eg. dispdata.002\pil\pildesc.ini
   FILE$ = Filepath$ & "\*." & strExtn                                                    'eg. dispdata.002\pil\*.pil

   '14Jan13 TH Now read totals and use this as a marker on whether to "reget" the files (TFS 51363)
   NumEntries = Val(TxtD(iniFile$, "", "0", "NumEntries", 0))
   
   'Check description file exists, If not then create it.
   'If Not fileexists(inifile$) Then
   If NumEntries < 1 Then  '14Jan13 TH Replaced above (TFS 51363)
      FileFound$ = Dir$(FILE$)
      Do While FileFound$ <> ""
         NumEntries = NumEntries + 1
         text$ = FileFound$ & "|" & "<No Description>"
         WritePrivateIniFile "", Format$(NumEntries), text$, iniFile$, 0               'Write entry to ini file
         FileFound$ = Dir$
      Loop
      WritePrivateIniFile "", "NumEntries", Format$(NumEntries), iniFile$, 0           'Write total to ini file
   End If

   'Display list of available files to user for editing..
   NumEntries = Val(TxtD(iniFile$, "", "0", "NumEntries", 0))
   ReDim FileLookup$(NumEntries)
   ReDim DescLookup$(NumEntries)

   LstBoxFrm.Caption = Caption$
   LstBoxFrm.lblTitle = crlf & "Select file" & crlf & "Press Shift-F1 or Right Click for menu" & crlf
   LstBoxFrm.lblHead = "     File      " & TB & " Description"

   For i = 1 To NumEntries
      text$ = TxtD(iniFile$, "", "", Format$(i), 0)
      deflines text$, lines$(), "|", 1, numoflines
      FileLookup$(i) = lines$(1)                                               'Store filename
      DescLookup$(i) = lines$(2)
      LstBoxFrm.LstBox.AddItem pad$(lines$(1), 15) & TB & lines$(2)            'Add to menu
   Next
   
   Do
      'Create appropriate popmenu dependant on mode
      popmenu 0, "", False, False
      Select Case Mode
         Case 1   'Full access for editing files
            'popmenu 2, "Edit" & cr & "Edit Description", False, False
            'popmenu 2, "Edit" & cr & "Edit Description" & cr & "New", False, False     '26Nov99 AW added extra menu item  '05Jan00 AW changed
            popmenu 2, "Edit" & cr & "Edit Description" & cr & "<New>", False, False                                       '         "
            Action(1) = 1    'Edit File
            Action(2) = 2    'Edit Description
            Action(3) = 5    'New File                                                 ' New File menu item
         Case 2   'View-only access
            popmenu 2, "View", False, False
            Action(1) = 3    'View
         Case 3   'View-only with ability to select a file and pass back to calling routine
            popmenu 2, "Select" & cr & "View", False, False
            Action(1) = 4    'Select
            Action(2) = 3    'View
         End Select
      
      LstBoxShow
      Selected = LstBoxFrm.LstBox.ListIndex + 1
      Choice = Val(PopMnu.Tag)

      If Selected <> 0 Then
            If Choice = 0 Then Choice = 1
            Select Case Action(Choice)
               Case 1      'Edit File
                  'Hedit 11, Filepath$ & "\" & FileLookup$(Selected)
                  strRTFText = getPharmacyRTFfromSQL(Filepath$ & "\", FileLookup$(Selected))
                  strRTFTextCopy = strRTFText
                  Hedit 1, strRTFText
                  If strRTFTextCopy <> strRTFText Then
                     'Now save to DB
                     lngOK = WritePharmacyRTFToSQL(Filepath$ & "\", filename$, strRTFText)
                  End If

               Case 2      'Edit Description
                  ans$ = DescLookup$(Selected)
                  k.Max = 50
                  inputwin Caption$, crlf & "Enter new description for " & FileLookup$(Selected) & crlf, ans$, k
                  If Not k.escd Then
                        DescLookup$(Selected) = Trim$(ans$)
                        LstBoxFrm.LstBox.RemoveItem Selected - 1
                        LstBoxFrm.LstBox.AddItem FileLookup$(Selected) & TB & DescLookup$(Selected), Selected - 1
                        WritePrivateIniFile "", Format$(Selected), FileLookup$(Selected) & "|" & DescLookup$(Selected), iniFile$, 0
                     End If

               Case 3      'View File
                  'Hedit 10, Filepath$ & "\" & FileLookup$(Selected)
                  strRTFText = getPharmacyRTFfromSQL(Filepath$ & "\", FileLookup$(Selected)) '09Jan17 TH Replaced above
                  Hedit 0, strRTFText

               Case 4      'Select File
                  SelectedFile$ = FileLookup$(Selected)
                  Selected = 0

               Case 5      'New File                                                   '26Nov99 AW added
                  
                  ans$ = ""
                  msg$ = ""
                  blnValid = False
                  Do
                     k.min = 1
                     k.Max = 5
                     k.nums = True
                     k.decimals = False
                     
                     inputwin Caption$, crlf & "Please enter name of the new file as 1 to 5 digits" & crlf & msg$, ans$, k
                     If Not k.escd Then
                           If Val(ans$) > 32767 Then
                                 msg$ = "Note: This must be 32767 or less"
                              Else
                                 'If fileexists(Filepath & "\" & ans$ & "." & strExtn) Then
                                 '09Jan17 TH CHeck from DB
                                 'GetRTFTextFromDB Filepath & "\" & ans$ & "." & strExtn, "", intSuccess   '04Jan17 TH Now read from DB (Hosted)
                                 'If fileexists(dispdata$ & "\" & fields(1) & ".rtf") Then    'rtf is present
                                 If RTFExistsInDatabase(dispdata$ & "\" & ans$ & "." & strExtn) Then    '12Jan17 TH Refactored
                                 'If intSuccess Then
                                    msg$ = "Note: File " & ans$ & " already exists"
                                 Else
                                    If Trim$(Str$(Val(ans$))) <> Trim$(ans$) Then '21Jan13 TH Trim leaing zero's and check with user
                                       ans$ = Trim$(Str$(Val(ans$)))
                                       msg$ = "" '08Mar13 TH Added to reset msg (TFS 58122)
                                    Else
                                       blnValid = True
                                    End If
                                 End If
                              End If
                        End If
                  Loop While Not blnValid And Not k.escd

                  If Not k.escd Then
                        NumEntries = NumEntries + 1
                        ReDim Preserve FileLookup$(NumEntries)
                        ReDim Preserve DescLookup$(NumEntries)
                        Selected = NumEntries
                        FileLookup$(Selected) = ans$ & "." & strExtn
                        
                        'enter optional description
                        DescLookup$(Selected) = "<No Description>"
                        ans$ = ""
                        k.Max = 50
                        inputwin Caption$, crlf & "Enter description for " & FileLookup$(Selected) & crlf, ans$, k
                        If Not k.escd Then DescLookup$(Selected) = Trim$(ans$)
                        
                        text$ = FileLookup$(Selected) & "|" & DescLookup$(Selected)
                        WritePrivateIniFile "", "NumEntries", Format$(NumEntries), iniFile$, 0
                        WritePrivateIniFile "", Format$(NumEntries), text$, iniFile$, 0
                        
                        'copy dispdata$ & "\Blank.rtf", Filepath$ & "\Blank.rtf"
                        'Name Filepath$ & "\Blank.rtf" As Filepath$ & "\" & FileLookup$(Selected)
                        'Hedit 11, Filepath$ & "\" & FileLookup$(Selected)
                        '09Jan17 TH Replaced above (Hosted)
                        strRTFText = getPharmacyRTFfromSQL(Filepath$ & "\", "Blank.rtf")
                        Hedit 1, strRTFText
                        lngOK = WritePharmacyRTFToSQL(Filepath$ & "\", FileLookup$(Selected), strRTFText)
                        '09Jan17 TH End
                        LstBoxFrm.LstBox.AddItem FileLookup$(Selected) & TB & DescLookup$(Selected)
                        LstBoxFrm.LstBox.Refresh
                     End If
               End Select
         End If

   Loop Until Selected = 0

   Unload LstBoxFrm
   popmenu 0, "", False, False

End Sub




