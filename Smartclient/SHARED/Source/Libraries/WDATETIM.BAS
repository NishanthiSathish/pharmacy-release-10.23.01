Attribute VB_Name = "WDATETIM"
'-----------------------------------------------------------------------------
'            A collection of routines to manipulate dates & times
'           ------------------------------------------------------
'
'SUB parsedate (in$, out$, dformat$, valid%)
'  Enter a date in almost any format, parse & return as out$. Accepts ddmmyy
'  ddmmyyyy, d(d)_m(m)_y(yyy), T, Y, M, +n(nnn)D, -n(nnn)D, USmm/dd/yy(yy)
'  where _ is any non numeric character, T is today, Y yesterday, M toMorrow
'  Output formats:  1 = DD/MM/YYYY  2 = DD/MM/YY  3 = DDMMYYYY  4 = DDMMYY
'  To replace / as the separator, add the required character to dformat$.
'  Valid dates include 00/mm/yyyy 00/00/yyyy and 00/00/0000 but if any is
'  zero then dformat$ is returned as "0"

'SUB ParseTime (in$, out$, tformat$, valid%)
'  Enter a time in almost any format, parse & return in out$.
'  Accepts h, hh, hh m, hhmm, hh_mm, hhpm, hh pm, hh mm pm, hh mmpm, T
'  where _ is any non numeric character, T is the time now
'  Output formats:  1 = HH:MM  2 = HHMM  3 = HH:MM am  4 = HHMMam

'SUB datetodays (dat$, tday$, ndbd&, ye!, ye$, valid%)
'  Emulates the old include file; takes two dates as strings & returns the
'  difference between them as days, years (inc fraction) and a 20 char string.

'SUB stringtodate (dat$, dt AS dateandtime)
'  Convert a date in string format to the dateandtime structure. Also returns
'  the total minutes since 1st Jan 1AD 00:00 (the fundamental epoch)
'  and the number of the day in the year is returned in .yday (0 to 365)
'  Caution. If this routine is used in expiry calculations, then the year
'  MUST be given as four digits even if it is zero. This is to prevent the
'  year being normalised to 18xx or 19xx which would INVALIDATE the expiry.

'SUB datetostring (dt AS dateandtime, dat$)
'  Given .yrs .mth .day returns 10 char string "dd/mm/yyyy"

'SUB agecalc (dt AS dateandtime, td AS dateandtime, years!, ye$)
'  Given two structured dates, returns 'age' as fractional years & string

'SUB addexpiry (dt1 AS dateandtime, dt2 AS dateandtime)
'  Given one structured date (dt1), adds days+hours+mins OR .mint if .mint<>0
'  Returns the answer in dt1

'SUB today (td AS dateandtime)
'  Sets structured date to today & now: .yrs .mth .day .hrs .min .yday .mint

'SUB datetomins (dt AS dateandtime)
'  Take structured date & calculate .yday and .mint
'  WARNING See comments at start of routine regarding Gregorian v Julian
'  Calendars, these routines must not be used for dates before 14 Oct 1582 !!

'SUB minstodate (dt AS dateandtime)
'  Take .mint and calculate .yrs .mth .day .hrs .min and .yday

'SUB datevalid (dt AS dateandtime, valid%)
'  Returns true%/false% in valid%. Allows years in range -4000 to +4000
'  Checks for month, day (leapyears calculated), hour, min in range.
'  Note that any or all can be zero - this is permitted.

'SUB baddate ()
'  Pop a window, print helpful message, wait for keypress, pop down

'FUNCTION isleapyear% (year AS INTEGER)
'  Returns true% for any leap year in range 1 to 4000 but false% for year=0

'FUNCTION daysinmonth% (mth%)
'  Simply reads an array. No account taken of leap years!

'FUNCTION yearday% (dt AS dateandtime)
'  Given .yrs .mth .day returns the year-day; 1 Jan = 0, 31 Dec = 364 or 365

'FUNCTION dayofweek% (dt AS dateandtime)
'  Given structured date returns day of week Mon = 1, Sun = 7
'  Note that .mint is used if <>0 otherwise calculates .mint from the date

'FUNCTION dayname$ (daynumber%)
'  Returns day as a string given day number from Dayofweek%() above

'FUNCTION plural$ (fig AS INTEGER)
'  Returns "s" if fig<>1, otherwise returns ""

'WARNING - checking for invalid dates MUST be done by the calling program
' before use of these routines - they assume valid dates have been set.
' The only routines which can be used without prior checking are Datetodays
' and Datevalid.
'
'NOTE - Most routines use .mint in calculations if .mint is non zero.
' Always ensure that .mint corresponds to the date held in the structure
' If in doubt then call datetomins to be quite certain, or set .mint = 0
'
'-----------------------------------------------------------------------------
'WARNING! the behaviour of division & assignment to an integer is as follows
'
'   print 99 / 100  ==> .99               ordinary division
'   a% =  99 / 100 : print a%  ==>  1     i.e  rounded up
'   a% = -99 / 100 : print a%  ==> -1     i.e  rounded 'up'  (more negative)
'
'   print 99 \ 100  ==>   0               integer  division
'   a% =  99 \ 100 : print a%  ==>  0     i.e  rounded down
'   a% = -99 \ 100 : print a%  ==>  0     i.e  rounded down
'
'   Note that integer division '\' rounds both sides before calculation:
'    0.5 is rounded DOWN!!   0.500001 is rounded UP    !!UNEXPECTED!!
'   -0.5 ==> 0              -0.500001 ==> -1           !!UNEXPECTED!!
'    e.g   2.5 \ .99       equivalent to  2 \ 1 =  2
'    e.g   2.500001 \ .99  equivalent to  3 \ 1 =  3
'    e.g   2.5 \ .5        equivalent to  2 \ 0 = division by zero!
'    e.g  -2.5 \ .99       equivalent to -2 \ 1 = -2
'    e.g  -2.500001 \ .99  equivalent to -3 \ 1 = -3
'    e.g  -2.5 \ .5        equivalent to -2 \ 0 = division by zero!
'
'-----------------------------------------------------------------------------
'mod history
'-----------
'20Feb90 CKJ Started writing the library, developed from
'            \LIBRARY\LIBDATE.BAS  5847  02-04-89 8:52pm
' 3Mar90 CKJ Released for á-test                                         V4.0
' 9Apr90 CKJ Datetodays - added valid%
'            Datevalid written
'10Jun90 CKJ Popdate written (for debugging)
'            Stringtodate modified to allow yyyy through untouched.
'  V4.1      Datetime.inc now incorporates the declares. It MUST be placed
'            immediately after the last DECLARE in the main program. This
'            is because the file has TYPE, DECLARE, DIM and executable code
'            in the same file. It is acceptable only so long as no other
'            include uses the same method, if this happens it will be split
'            into two include files.
'            Plural$ written, used to tidy ye$ in agecalc
'02Oct93 ASC approx now prints months as well as years
'30Oct93 CKJ VB: year=>yearV month=>monthV
' 9Feb94 ASC/CKJ Added ParseDate & ParseTime, removed PopDate, used FORMAT$()
'13Feb94 ASC Added TimeToString and StringToTime
'14Feb94 ASC Added DosesBetweenDates
'20Feb94 ASC Added American format to parsedate
'05Mar94 ASC Added quicker way for counting doses alone
'12Apr94 ASC Dosesbetween times fixed for equal doses
' 9Jun94 CKJ Plural$() only when UK system
'            Added word 'month(s)' to approx age in AgeCalc
'24Mar95 CKJ AddExpiry;  Changed to avoid overflow with 30 day expiry
'30Nov95 ASC plural now is not unless
'25Jan96 KR/CKJ Added option explicit
'05Jul96 KR  Moved Plural$ from corelib.bas
'11Sep96 CKJ Parsedate: Added +/-Months and +/-Years
'            Month names, eg 1 Jan   04March96   5Jul
'            User defined format added, plus formats 6 & 7
'23Mar97 CKJ BadDate: Better explanation added
' 1Apr97 CKJ Added xxD to the BadDate help box
'07Apr97 CKJ Fixed fault with appending AM/PM to time in Parsetime.
'07May97 CKJ Parsedate: Added ddd and dddd formats to the user defined type
'            Millenium testing: confirmed that 1Jan2000 works and that
'            29Feb2000 is Tues and 01Mar2000 is Wed
'08May97 CKJ Moved DosesBetweenTimesY to WdateTim.REM - proc has not been in use
'            for some time.
'23Jun97 CKJ Parsedate: Format 8 added: Millenium switch at 'xx80'
'03May98 CKJ Y2K ParseDate: Implemented sliding window for two digit dates
'06Aug98 CKJ AgeCalc: Corrected actmths where dates are within the same month
'26Nov98 CKJ ParseDate: Corrected format 9 when full 'ccyy' is provided
'10Jan00 AE  IncDate: Written
'10Jan00 AE  DecDate: Written
'14Feb03 CKJ Parsedate: Added canonical date format 'ccyy-mm-dd'
'             and 'ccyy-mm-ddT00:00:00.000'
'30Mar04 CKJ {SP1}
'04jun04 CKJ 32bit
'15Sep11 CKJ DateAndTimeToMillisecond: Corrected handling of boundary condition  (TFS14212)
'16Apr18 VR Bug 209204: Pharmacy manufacturing - Invalid dates allowed in Manufacturing issue screen-Manufacturing
'25Apr18 VR Bug 209204 and Bug 210999: Unable to dispense

'mods needed
'-----------
'/year 1AD ==> 0 mins    but   0 mins ==> 0AD   - done
'/monthnames not used: need dt ==> "Wednesday 31st January 1990 11:45am"
' Millenium checking: ensure that 19xx is not hard coded
'-----------------------------------------------------------------------------
Option Explicit
DefInt A-Z

Type DateAndTime
   Yrs  As Integer   ' 1 to 4000     year from 1 AD to 4000 AD
   mth  As Integer   ' 1 to 12       NB if = 0 then assume 1   ie 0,0 = 1 Jan
   day  As Integer   ' 1 to 31       NB if = 0 then assume 1
   Hrs  As Integer   ' 0 to 23       24 hour clock
   min  As Integer   ' 0 to 59
   yday As Integer   ' 0 to 365 year-day, ie the day number of current year
   mint As Long      ' 0 to 2,103,796,800  (~4000 years) mins in total since 1 AD
End Type

Global Const mind& = 1440&    ' minutes-in-day as long integer
Global Const monthname$ = "---¦January¦February¦March¦April¦May¦June¦July¦August¦September¦October¦November¦December" '14DEC95 KR
Global Const daynames$ = "---¦Monday¦Tuesday¦Wednesday¦Thursday¦Friday¦Saturday¦Sunday"
Global zeroAD As DateAndTime

Dim YYcutoff$                 '03May98 CKJ Y2K Used to interpret two digit years in a date

Private Type SYSTEMTIME
   wYear As Integer
   wMonth As Integer
   wDayOfWeek As Integer
   wDay As Integer
   wHour As Integer
   wMinute As Integer
   wSecond As Integer
   wMilliseconds As Integer
End Type

Private Declare Sub GetSystemTime Lib "kernel32" (lpSystemTime As SYSTEMTIME)
'


Function DayOfWeek(dt As DateAndTime) As Integer
'-----------------------------------------------------------------------------
'         Returns day of week as an integer in range 1 (Mon) to 7 (Sun)
'NB: return code is meaningless unless a valid date is present as ddmmyy or mint
'-----------------------------------------------------------------------------

   If dt.mint = 0 Then datetomins dt
   DayOfWeek = (dt.mint \ mind) Mod 7 + 1

End Function

Function daysinmonth(ByVal mth As Integer) As Integer
'-----------------------------------------------------------------------------
' Takes an integer in range 1 to 12 returns the number of days in that month
' Note: February always returns an answer of 28 days
'-----------------------------------------------------------------------------
Static alines(12) As String
Dim linesreturned As Integer
Dim monthlength As String

   If mth > 0 And mth < 13 Then
         monthlength = "31¦28¦31¦30¦31¦30¦31¦31¦30¦31¦30¦31" '08Dec95 KR use a string list
         deflines monthlength, alines(), "¦", 1, linesreturned
         
         daysinmonth = Val(alines(mth))
      Else
         daysinmonth = 0
      End If

End Function

Sub DecDate(sDateIn As String, sDateOut As String)

'Routine to Decrement the give date (DateIN) by 1 day
'And return in DateOut
'Note does not check for validity
'----------------------------------------------------------
'10Jan00 AE  Written

Dim dt As DateAndTime, dtAdd As DateAndTime

   StringToDate sDateIn, dt
   dtAdd.day = -1
   AddExpiry dt, dtAdd
   DateToString dt, sDateOut

End Sub

Sub IncDate(sDateIn As String, sDateOut As String)

'Routine to Increment the give date (DateIN) by 1 day
'And return in DateOut
'Note does not check for validity
'----------------------------------------------------------
'10Jan00 AE  Written

Dim dt As DateAndTime, dtAdd As DateAndTime

   StringToDate sDateIn, dt
   dtAdd.day = 1
   AddExpiry dt, dtAdd
   DateToString dt, sDateOut


End Sub

Function isleapyear(yearV As Integer) As Boolean
'-----------------------------------------------------------------------------
'                           returns true% or false%
' Validated by printing to screen & checking manually
' Note that 0 AD does not exist, but the routine returns false% for year = 0
'-----------------------------------------------------------------------------

   isleapyear = ((yearV Mod 4 = 0 And yearV Mod 100 <> 0) Or (yearV Mod 400 = 0) And yearV <> 0)
 
End Function

Sub minstodate(dt As DateAndTime)
'-----------------------------------------------------------------------------
'    Takes the immense number of minutes since 1 AD (in .mint)
'    & returns year, month, day and year-day, hrs & min
'    Fundamental epoch is 1st Jan 1AD 00:00, matching datetomins()
'
'Validated using;
'   FOR years = 1 TO 4000
'      dt.yrs = years
'      datetomins dt
'      minstodate dt
'      IF years <> dt.yrs THEN STOP
'   NEXT
'-----------------------------------------------------------------------------
Const yearlength = 365.2425
Dim dtemp As DateAndTime, days&, daysinyear As Integer, daysinmonthx, minsinday&

   days& = dt.mint \ mind
   dtemp = zeroAD
   dtemp.Yrs = days& / yearlength                 ' may be correct or 1 to 2 years out
   Do                                             ' calculate correct year from days
      datetomins dtemp                            ' take estimate & find .mint
      Select Case days& - dtemp.mint \ mind       ' actual tot days - estimated tot days
        Case 0 To 364 - isleapyear(dtemp.Yrs)     ' adds one for a leap year
           dt.Yrs = dtemp.Yrs                     ' correct answer found
           If dt.Yrs = 0 Then dt.Yrs = 1          ' 0 AD does not 'exist'
           Exit Do                                ' quit the loop
        Case Is < 0
           dtemp.Yrs = dtemp.Yrs - 1
        Case Else                      ' NB automatically excludes first 365 or 366 days
           dtemp.Yrs = dtemp.Yrs + 1
        End Select
   Loop
  
   dt.yday = days& - dtemp.mint \ mind
   daysinyear = dt.yday + 1                      ' .dayt is up to yesterday so add 1

   dt.mth = 0
   Do
      dt.mth = dt.mth + 1                        ' was set to 0 above, so inc
      daysinmonthx = daysinmonth(dt.mth)         ' how many days in this month?
      If daysinmonthx = 28 Then If isleapyear(dtemp.Yrs) Then daysinmonthx = 29
      If daysinyear <= daysinmonthx Then Exit Do ' remainder is in this month
      daysinyear = daysinyear - daysinmonthx     ' decrement remainder
   Loop
   dt.day = daysinyear                           ' the remainder
 
   minsinday& = dt.mint Mod mind                 ' mins in current day
   dt.Hrs = minsinday& \ 60                      ' whole hours
   dt.min = minsinday& Mod 60                    ' remaining mins

End Sub

Sub parsedate(ByVal TextIn$, Out$, dformat$, valid%)
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
Dim lastsep$, incopy$, formatcopy$, swapdaymth As Integer, Offset$, days#, X As Integer, char$
Dim sep$, Numoflines%, count As Integer
Dim dd$, ddd$, dddd$, mm$, mmm$, mmmm$, cc$, yy$, mult%, dat$, fmt$
Dim Limit%, Cutoff%, Century%
Dim strTemp As String

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
   For X = 1 To Len(TextIn$)                      '            Look for an alpha char
      Select Case Mid$(TextIn$, X, 1)             '
         Case "a" To "z", "A" To "Z"          '            Only do Month name replaces
            count = count + 1                 '            if at least three letters found
         End Select                           '
   Next                                       '
   If count > 2 Then                          '            Proceed to scan month names
         deflines UCase$(monthname$), mths$(), "¦", 0, Numoflines%
         For X = 1 To 12
            replace TextIn$, mths$(X), Format$(X, " 00 "), 6            'min length 1August
            replace TextIn$, Left$(mths$(X), 5), Format$(X, " 00 "), 5  'min length 1April
            replace TextIn$, Left$(mths$(X), 4), Format$(X, " 00 "), 4  'min length 1June
            replace TextIn$, Left$(mths$(X), 3), Format$(X, " 00 "), 3  'min length 1May
         Next
      End If
   replace TextIn$, "  ", " ", 4
   TextIn$ = RTrim$(TextIn$)

   For X = 1 To Len(TextIn$)
      char$ = Mid$(TextIn$, X, 1)
      If InStr("0123456789", Mid$(TextIn$, X, 1)) = 0 Then
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
         deflines TextIn$, aline$(), sep$ + "(*)", 1, Numoflines%
         If Numoflines% = 2 Then
               aline$(3) = Right$(date$, 4)
               Numoflines% = 3
            End If
         If Numoflines% = 3 Then
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
               DateValid dt, valid
            Else
               valid = False
            End If
      End If
   
   If valid Then
         deflines monthname$, mths$(), "¦", 0, Numoflines%
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

Sub parsetime(TextIn$, Out$, tformat$, valid%)
'format 1 = HH:MM                00:00 to 23:59
'format 2 = HHMM                  "
'format 3 = HH:MM am HH:MM pm    12:00 am to 11:59 pm
'format 4 = HHMMam HHMMpm         "
'all with leading zeros
'07Apr97 CKJ   Fixed fault with appending AM/PM to time.

Static aline$(10)                '14Dec95 KR Use static for fixed bound arrays
Dim dt As DateAndTime
Dim Numoflines As Integer
Dim incopy$, sep$, add12, X As Integer, char$, hr24$, hr12$, Hrs, mins$, ampm$

   valid = True
   incopy$ = TextIn$
   TextIn$ = UCase$(TextIn$)
   sep$ = ""

   If TextIn$ = "T" Then TextIn$ = Left$(Time$, 5)   ' T current time
   If LTrim$(TextIn$) = "" Then TextIn$ = "XX"       ' blank line not valid

   Select Case Left$(TextIn$, 1)
      Case "+", "-": TextIn$ = "XX"              ' +nn -nn not implemented
      End Select

   add12 = 0
   If Right$(TextIn$, 1) = "A" Then TextIn$ = Left$(TextIn$, Len(TextIn$) - 1)
   If Right$(TextIn$, 2) = "AM" Then TextIn$ = Left$(TextIn$, Len(TextIn$) - 2)
   If Right$(TextIn$, 1) = "P" Then TextIn$ = Left$(TextIn$, Len(TextIn$) - 1): add12 = 12
   If Right$(TextIn$, 2) = "PM" Then TextIn$ = Left$(TextIn$, Len(TextIn$) - 2): add12 = 12
   TextIn$ = RTrim$(TextIn$)

   For X = 1 To Len(TextIn$)
      char$ = Mid$(TextIn$, X, 1)
      If InStr("0123456789", Mid$(TextIn$, X, 1)) = 0 Then
            If sep$ = "" Then
                  sep$ = char$
               Else
                  valid = False
               End If
         End If
   Next

   If valid Then
         If sep$ = "" And Len(TextIn$) = 4 Then   ' hhmm
               TextIn$ = Left$(TextIn$, 2) + ":" + Mid$(TextIn$, 3)
               sep$ = ":"
            End If
         deflines TextIn$, aline$(), sep$ & "(*)", 1, Numoflines
         If Numoflines = 1 Then
               aline$(2) = "0"
               Numoflines = 2
            End If
         If Numoflines = 2 Then
               dt.Hrs = Val(aline$(1)) + add12
               dt.min = Val(aline$(2))
            DateValidForTime dt, valid
            Else
               valid = False
            End If
      End If

   If valid Then
         hr24$ = Format$(dt.Hrs, "00")
         Hrs = ((dt.Hrs + 11) Mod 12) + 1
         hr12$ = Format$(Hrs, "00")
         mins$ = Format$(dt.min, "00")
         'If dt.hrs < 12 Then mins$ = "am" Else ampm$ = "pm"      '07Apr97 CKJ
         If dt.Hrs < 12 Then ampm$ = "am" Else ampm$ = "pm"
         If InStr(tformat$, "1") Then Out$ = hr24$ & ":" & mins$
         If InStr(tformat$, "2") Then Out$ = hr24$ & mins$
         If InStr(tformat$, "3") Then Out$ = hr12$ & ":" & mins$ & " " & ampm$
         If InStr(tformat$, "4") Then Out$ = hr12$ & mins$ & ampm$
      Else
         Out$ = incopy$
      End If
   TextIn$ = incopy$


End Sub

Sub datetodays(dat$, tday$, ndbd&, ye!, wye$, valid%)
'-----------------------------------------------------------------------------
'             This routine replaces the existing include file
' It takes a two dates in string format, & returns the difference between them
' If either string is null then it defaults to today
'-----------------------------------------------------------------------------
' vars in -
'    dat$ "ddxmmxyy" "ddxmmxyyyy" "00x00xyy" "ddxmmyyy"
'    td$  date for comparison, same format
'    if either is null then it defaults to today's date
'
' vars out -
'   ndbd& = no of days between dates
'     ye! = years between dates, including fraction of year
'     wye$ = years between dates as a formatted string (20 characters long)
'
'assume any year beyond current year is 18xx (ie if dat$ is after tday$)
'   - return dat$ as "dd/mm/18yy" or "dd/mm/19yy"
'-----------------------------------------------------------------------------
Dim dt As DateAndTime, td As DateAndTime

   If Len(dat$) Then StringToDate dat$, dt Else today dt   ' map to structure
   If Len(tday$) Then StringToDate tday$, td Else today td
  
   DateValid dt, valid
   If valid Then DateValid td, valid
   If valid Then
         ndbd& = td.mint \ mind - dt.mint \ mind   ' No of days between dates
         agecalc dt, td, ye!, wye$
      End If

End Sub

Sub datetomins(dt As DateAndTime)
'-----------------------------------------------------------------------------
'     Takes year, month, day, hours and mins
'     Returns total completed minutes since 1 AD.
'        0 mins = 1st Jan 1AD 00:00
'     Also returns the year-day ie Jan 1 = 0 Jan 2 = 1 etc in .yday
'
'Assumption: this algorithm assumes that the Gregorian calendar has been in
'  use since 1 AD, but since it is only to be used as an offset to a date
'  which is 1800+ then this is of no consequence. Do not use the routine for
'  dates which are from the Julian calendar, ie before 14 Oct 1582 !
'  Furthermore, by convention 0AD does not exist; sequence is -2 -1  1  2  AD
'  This routine uses 1st Jan 1AD 00:00 as the fundamental epoch.
'
'1Mar90 CKJ Validated using following code (differing only in detail);
'   DIM ml(12)
'   RESTORE monthlength
'   FOR i = 1 TO 12: READ ml(i): NEXT
'   dlast& = -1
'   FOR y = 1 TO 4000
'      dt.yrs = y
'      FOR m = 1 TO 12
'         dt.mth = m
'         daysinmonthx = ml(dt.mth)
'         IF dt.mth = 2 THEN IF isleapyear(y) THEN daysinmonthx = 29
'         FOR d = 1 TO daysinmonthx
'            dt.day = d
'            datetomins dt
'            daytotl& = dt.mint \ 1440
'            IF daytotl& <> dlast& + 1 THEN PRINT "Error": END
'            dlast& = daytotl&
'   NEXT d, m, y
'-----------------------------------------------------------------------------
Dim lastyr As Integer, days&

   lastyr = dt.Yrs - Sgn(dt.Yrs)      ' 2 => 1     1, 0, -1 => 0     -2 => -1
   days& = lastyr * 365& + lastyr \ 4 - lastyr \ 100 + lastyr \ 400
   days& = days& + yearday(dt)
   dt.mint = (days& * 24 + dt.Hrs) * 60 + dt.min   ' calculate minute total
                                             
End Sub

Sub DateToString(dt As DateAndTime, dat$)
'-----------------------------------------------------------------------------
'        Given .yrs .mth .day returns 10 char string "dd/mm/yyyy"
'-----------------------------------------------------------------------------

   dat$ = Format$(dt.day, "00\/") & Format$(dt.mth, "00\/") & Format$(dt.Yrs, "0000")

End Sub

'25Apr18 VR Changes to make dates like '00/mm/yyyy', 'dd/00/yyyy', 'dd/mm/0000' and '00/00/0000'
Sub DateValid(dt As DateAndTime, valid)
    '-----------------------------------------------------------------------------
    '                Takes a date & time structure & returns T/F
    '-----------------------------------------------------------------------------
    Dim dm As Integer

    valid = True     ' assume innocent until proven ...
    If Abs(dt.Yrs) < 1 Or Abs(dt.Yrs) > 4000 Then valid = False
    If dt.mth < 1 Or dt.mth > 12 Then
        valid = False
    Else                            'else added ASC 22-01-91
        dm = daysinmonth(dt.mth)
        If dt.mth = 2 Then If isleapyear(dt.Yrs) Then dm = 29 '17Feb91 CKJ extra IF to speed it up
        If dt.day < 1 Or dt.day > dm Then valid = False
        If dt.Hrs < 0 Or dt.Hrs > 23 Then valid = False
        If dt.min < 0 Or dt.min > 59 Then valid = False
    End If

End Sub

'25Apr18 VR Retaining the original logic for validating date from ValidTime function, as when entering time 
'date, day and year will be zero. In that case date should not be made invalid
Sub DateValidForTime(dt As DateAndTime, valid)
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
        If dt.day < 0 Or dt.day > dm Then valid = False
        If dt.Hrs < 0 Or dt.Hrs > 23 Then valid = False
        If dt.min < 0 Or dt.min > 59 Then valid = False
    End If

End Sub

Function dayname$(daynumber)
'-----------------------------------------------------------------------------
'       Returns a string containing the name of the day, Mon=1 Sun=7
' The name is not abbreviated, contains no spaces, and has an initial capital
'-----------------------------------------------------------------------------_
Static alines(0 To 7) As String
Dim returnedlines As Integer

   If daynumber > 0 And daynumber < 8 Then
         deflines daynames$, alines(), "¦", 0, returnedlines
         dayname$ = alines(daynumber)
      Else
         dayname$ = ""
      End If
   
End Function

Sub StringToDate(dat$, dt As DateAndTime)
'-----------------------------------------------------------------------------
'       Take a string & return the date as a structure
' var in : dat$ as "ddxmmxyy" "ddxmmyyy" "ddxmmxyyyy"
' var out: dt with .yrs .mth .day .hrs .min .yday & .mint filled
'          or all values=0 if string length is invalid
'          dat$ "dd/mm/yyyy" or unchanged if string length is invalid
' If year is given as "xx" or "xxx" then it is normalised to 18xx, 19xx etc.
' The "xx" form should only be used for dates of birth, since it switches
' between 18xx & 19xx on the value of todays date.
' NB Validity checking does NOT include days in month or months in year etc,
'  it only checks that the length of the string is 8 or 10 chars.
'
'03May98 CKJ Y2K The three digit year format is OK to 2099, but should be phased out anyway.
'            The two digit form now uses current century and switches to previous century
'            if the resulting day/month/year would be in the future. Similar to the sliding
'            window of parsedate, where the offset is zero AND the day and month are considered.
'            It is strongly recommended to call parsedate first to check validity and reformat
'            to the standard ddmmyyyy or dd/mm/yyyy, then call stringtodate to fill dt.
'
'
'mods needed -
'/format "ddxmmxyy" will not work beyond year 2000 without mods    - done
'-----------------------------------------------------------------------------
Dim td As DateAndTime

   dt = zeroAD
   If Len(dat$) <> 8 And Len(dat$) <> 10 Then Exit Sub          ' <== Way Out
  
   dt.day = Val(Left$(dat$, 2))                                 ' DDxmm.yy..
   dt.mth = Val(Mid$(dat$, 4, 2))                               ' ddxMM.yy..
   If Len(dat$) = 8 And InStr("0123456789", Mid$(dat$, 6, 1)) > 0 Then
         dt.Yrs = Val(Mid$(dat$, 6))                            ' ddxmmYYY
         If dt.Yrs < 100 Then dt.Yrs = dt.Yrs + 1000            ' ddxmm0yy
         dt.Yrs = dt.Yrs + 1000                                 ' 18 19 20xx  - Y2K compliant
      Else
         dt.Yrs = Val(Mid$(dat$, 7))                            ' ddxmmxYY(YY)
         If dt.Yrs < 100 And Len(dat$) = 8 Then                 ' ddxmmxYY
               'dt.yrs = dt.yrs + 1900                          ' 19yy '03May98 CKJ Y2K replaced
               dt.Yrs = dt.Yrs + 100 * Val(Mid$(date$, 7, 2))   '03May98 CKJ Y2K 19yy 20yy etc
               today td                                         ' set today
               If dt.Yrs * 10000& + dt.mth * 100& + dt.day > td.Yrs * 10000& + td.mth * 100& + td.day Then
                     dt.Yrs = dt.Yrs - 100                      ' 18yy 19yy etc
                  End If
            End If
      End If
   datetomins dt                                                ' set .mint
   DateToString dt, dat$                                        ' new format dd/mm/yyyy

End Sub

Sub StringToTime(tim$, dt As DateAndTime)
'Tim$ must be of format "h:mm" "hh:mm" or "hhmm"
'No other formats are handled
'No assumptions are made about 12/24 hour clock

   dt.min = Val(Right$(tim$, 2))
   dt.Hrs = Val(Left$(tim$, 2))

End Sub

Sub TimeToString(dt As DateAndTime, tim$)
'13Feb94 ASC
'Given dt.hrs and dt.min return tim$ as "hhmm" in range 0000 (midnight) to 2359
   
   tim$ = Right$("00" & LTrim$(Str$(dt.Hrs)), 2) & Right$("00" & LTrim$(Str$(dt.min)), 2)

End Sub

Sub today(td As DateAndTime)
'-----------------------------------------------------------------------------
'              Fills a time structure with todays date & time
'-----------------------------------------------------------------------------
Dim d$, t$

   Do                               '03May98 CKJ Avoid midnight errors
      d$ = date$                    ' mm-dd-yyyy
      t$ = Time$                    ' hh:mm:ss
   Loop Until d$ = date$            '03May98 CKJ
   td.Yrs = Val(Right$(d$, 4))
   td.mth = Val(d$)
   td.day = Val(Mid$(d$, 4, 2))
   td.Hrs = Val(t$)
   td.min = Val(Mid$(t$, 4, 2))
   datetomins td                    ' finds .mint & .yday

End Sub

Sub AddExpiry(DT1 As DateAndTime, DT2 As DateAndTime)
'-----------------------------------------------------------------------------
' Take one date (dt1) and add any number of days, hours & mins to it (dt2)
' Note that the following applies to the expiry (dt2):
'   (1)  if .mint is not zero then this is used
'   (2)  if .mint is zero then .day .hrs .min are used
'   (3)  .yrs and .mth are NOT used in calculating the expiry
' Note: All values should be positive: negative values have not been tested.
' Answer is returned in dt1
'
'24Mar95 CKJ Changed 60 to 60&, avoids overflow with 30 day expiry
'-----------------------------------------------------------------------------

   datetomins DT1                             ' convert to minutes
   If DT2.mint = 0 Then             ' no total mins set, use day hrs min only
         DT2.mint = (DT2.day * 24 + DT2.Hrs) * 60& + DT2.min  '24Mar95 CKJ Added &
      End If
   DT1.mint = DT1.mint + DT2.mint             ' find total minutes
   minstodate DT1                             ' convert back again

End Sub

Sub agecalc(dt As DateAndTime, td As DateAndTime, Years!, ye$)
'-----------------------------------------------------------------------------
'  Given two dates, calculate the difference between them and return
'  this as years (including fraction) and as a string (length 20 chars)
'
' Starting from .day .mth .yrs for dt and td  (these being the date in
' question and, usually but not necessarily, today) then find the number of
' spare days. This is the number of days to the end of the month (inc first
' day) plus number in last month (excluding last day). If total exceeds number
' of days in first month then decrement accordingly & inc month total.
' The process continues for the months & years.
'
' Note, if day or month is zero then 1 is assumed & ye$ is returned with the
' word 'approx'
'10Jun90 CKJ Plural$ used to tidy ye$
' 9Jun94 CKJ Added word 'month(s)' to approx age & age is now up to 21 chars
'05Jul96 KR  Forced pass by value in plural$ as plural$ now takes single not int
'06Aug98 CKJ Corrected actmths where dates are within the same month
'-----------------------------------------------------------------------------
Dim d1 As DateAndTime, d2 As DateAndTime, temp As DateAndTime
Dim actyrs As Integer, actmths As Integer, actdays As Integer
Dim partial As Integer, daysinmth As Integer

   d1 = dt                                         ' earlier of the two dates
   d2 = td                                         ' later date, usually today
   partial = False                                 ' zero in any day or mont
   If d1.day = 0 Then d1.day = 1: partial = True
   If d2.day = 0 Then d2.day = 1: partial = True   ' fundamental epoch is
   If d1.mth = 0 Then d1.mth = 1: partial = True   ' 01-01-0001 and zero for
   If d2.mth = 0 Then d2.mth = 1: partial = True   ' any is invalid.
   If d1.Yrs = 0 Then d1.Yrs = 1
   If d2.Yrs = 0 Then d2.Yrs = 1
   If d1.mint = 0 Then datetomins d1
   If d2.mint = 0 Then datetomins d2
   If d1.mint > d2.mint Then 'SWAP d1, d2           ' future date given
         temp = d1                                  ' 07DEC95 KR
         d1 = d2
         d2 = temp
      End If
   actmths = 0                                     ' set to zero before use

   If d1.mth <> d2.mth Or d1.Yrs <> d2.Yrs Then    ' different months
         daysinmth = daysinmonth(d1.mth)
         If d1.mth = 2 Then If isleapyear(d1.Yrs) Then daysinmth = 29
         actdays = daysinmth - d1.day + d2.day
         If actdays >= daysinmth Then
               actdays = actdays - daysinmth
               actmths = 1
            End If
      Else
         actdays = d2.day - d1.day                 ' within same month
      End If

   If d1.Yrs <> d2.Yrs Then                        ' different years
         actmths = actmths + 11 - d1.mth + d2.mth  ' end of one year + start of the next
      'Else                                        ' 07Aug98 CKJ replaced by line below
      ElseIf d2.mth <> d1.mth Then                 ' 07Aug98 CKJ Only do this if months differ
         actmths = actmths + d2.mth - d1.mth - 1   ' within same year but different months
      End If

   If d1.Yrs + 1 < d2.Yrs Then                     ' more than a year apart
         actmths = actmths + 12 * (d2.Yrs - d1.Yrs - 1)
      End If

   actyrs = actmths \ 12                           ' whole years
   actmths = actmths Mod 12                        ' remaining months
   Years! = actyrs + (actmths / 12) + (actdays / 365.2425)

   If partial Then   '23 yrs 10 mths approx'
         ye$ = LTrim$(Str$(actyrs)) + " yr" + plural$((actyrs)) + Str$(actmths) + " mth" + plural$((actmths)) + " approx"  'added months ASC 2Oct93 '9Jun94 CKJ Added word 'month(s)' & Ltrim
      Else
         If actyrs >= 1 Then
               ye$ = Str$(actyrs) + " year" + plural$((actyrs)) + Str$(actmths) + " month" + plural$((actmths))
            Else
               If Val(ye$) < 1 And actmths > 2 Then    '07DEC KR val ye$ vs. vbdos ye
                     ye$ = Str$(actmths) + " month" + plural$((actmths)) + Str$(actdays) + " day" + plural$((actdays))
                  Else
                     ye$ = Str$(d2.mint \ mind - d1.mint \ mind) + " day" + plural$((actdays))
                  End If
            End If
      End If
   ye$ = Left$(ye$ + Space$(15), 21)  '9Jun94 CKJ Expanded 20 to 21 chars

End Sub

Sub BadDate()
'-----------------------------------------------------------------------------
'                          Pop a suitable message
'
'23Mar97 CKJ Better explanation added
'-----------------------------------------------------------------------------
Dim s$

   s$ = "Enter date in any of the following ways" & cr & cr
   s$ = s$ & "DD MM" & TB & TB & "eg 21 1  for 21st Jan of the current year" & cr
   s$ = s$ & "DDMMYY " & TB & "eg 14 7 03 for 14th July 1903 or 2003" & cr
   s$ = s$ & "DD MM YY " & TB & "These three examples use the current century" & cr
   s$ = s$ & "DD MM YYYY " & TB & "Full date eg 1 8 1997, 01 08 1997" & cr
   s$ = s$ & "DD-MM-YYYY " & TB & "Use any punctuation between digits eg 4/2/1997" & cr
   s$ = s$ & "DD mth YYYY " & TB & "Use three letters of month eg Feb, Dec" & cr
   s$ = s$ & "DD month YYYY " & TB & "Use full name of month eg April, July" & cr
   s$ = s$ & "T" & TB & TB & "Today" & cr
   s$ = s$ & "Y" & TB & TB & "Yesterday" & cr
   s$ = s$ & "M" & TB & TB & "Tomorrow (not for date of birth)" & cr
   s$ = s$ & "+xxD" & TB & "-xxD" & TB & "Add or subtract xx days from today, eg +90d" & cr
   s$ = s$ & "+xxW" & TB & "-xxW" & TB & "Add or subtract xx weeks from today, eg +26w" & cr
   s$ = s$ & "+xxM" & TB & "-xxM" & TB & "Add or subtract xx months from today, eg -9m" & cr
   s$ = s$ & "+xxY" & TB & "-xxY" & TB & "Add or subtract xx years from today, eg +5y" & cr
   s$ = s$ & "xxD" & TB & TB & "xx days old (date of birth entry only)" & cr
   s$ = s$ & "xxM" & TB & TB & "xx months old, up to 36 max (date of birth entry only)" & cr
   popmessagecr "WARNING: Invalid date", s$

End Sub

Function yearday(dt As DateAndTime) As Integer
'-----------------------------------------------------------------------------
'    Takes year, month & day in month
'    Returns year-day in dt.yday and as an integer
'
' NOTE: this returns the number of whole days from midnight of the new year
' up to midnight of the start of the Current Day. For example:
' Jan  1 00:00 =  0      this is the new year
' Jan  1 14:26 =  0      not a whole day yet
' Feb  1 00:00 = 31      one whole month
' Feb  1 21:46 = 31      still only 31 whole days
' Dec 31 xx:xx = 364     not a leap year
' Dec 31 xx:xx = 365     leap year
'-----------------------------------------------------------------------------
Dim monthV As Integer

   dt.yday = 0
  
   For monthV = 1 To dt.mth - 1          ' if month = 0 or 1 then return zero
      If monthV > 12 Then Beep: Exit For        ' 17Feb91 CKJ check added
      dt.yday = dt.yday + daysinmonth(monthV)
   Next         '14Feb95 CKJ removed monthV

   If isleapyear(dt.Yrs) And dt.mth > 2 Then dt.yday = dt.yday + 1

   '**** WARNING Current day is NOT counted ****
   If dt.day Then dt.yday = dt.yday + dt.day - 1
   yearday = dt.yday

End Function
Function StringDateToDate(ByVal strDate As String) As Date

'02Mar05 TH Written
'Used to coerce a textual date (10 or 8 char format) into a reliable date to be sent
'to the database that will be independent of the local machine date formatting

'-----------------------------------------------------------------------------
Dim lclDate As Date
Dim strDay As String
Dim strMonth As String
Dim strYear As String


   lclDate = 0
   If Len(strDate) <> 8 And Len(strDate) <> 10 Then Exit Function     ' <== Way Out
   
   strDay = Left(strDate, 2)
   strYear = Right(strDate, 4)
   If Len(strDate) = 8 Then
      strMonth = Mid$(strDate, 3, 2)
   Else
      strMonth = Mid$(strDate, 4, 2)
   End If
   
   Select Case Val(strMonth)
      Case 1: strMonth = "JAN"
      Case 2: strMonth = "FEB"
      Case 3: strMonth = "MAR"
      Case 4: strMonth = "APR"
      Case 5: strMonth = "MAY"
      Case 6: strMonth = "JUN"
      Case 7: strMonth = "JUL"
      Case 8: strMonth = "AUG"
      Case 9: strMonth = "SEP"
      Case 10: strMonth = "OCT"
      Case 11: strMonth = "NOV"
      Case 12: strMonth = "DEC"
   End Select
  
   lclDate = strDay & "/" & strMonth & "/" & strYear
   StringDateToDate = lclDate

End Function

Public Function DateAndTimeToMillisecond() As String
'10Jul11 TH  Written. THis proc is designed to return a string originally for
'            Local file handling. IT DOES NOT GIVE A TRUE FIGURE, BUT GIVES THE
'            TIME TO MILLISECONDS OF THE LATEST CLOCKTICK, so do not rely on this
'            in this respect (ie you can get the same result in a tight loop).
'15Sep11 CKJ Code review: fails to check that the millisecs 'belong' to same second
'            Added loop to handle this.                              (TFS14212)

Dim sAns As String
Dim typTime As SYSTEMTIME
Dim vbNow As Variant
Dim MilliSec As Integer

   On Error GoTo DateAndTimeToMillisecond_Error
   
'   GetSystemTime typTime
'   sAns = Format(Now, "YYYYMMDDHHNNSS") & Right("000" & typTime.wMilliseconds, 3)
'   DateAndTimeToMillisecond = sAns
   
   Do
      GetSystemTime typTime
      MilliSec = typTime.wMilliseconds             '64 ticks per second on most systems, 15.625 millisec per tick
      vbNow = Now
      GetSystemTime typTime
   Loop While MilliSec <> typTime.wMilliseconds    'ensure that the timer has not ticked to the next 1/64th of a second
      
   sAns = Format(vbNow, "YYYYMMDDHHNNSS") & Right("000" & Format$(typTime.wMilliseconds), 3) '15Sep11 CKJ added format$() to remove leading space
   DateAndTimeToMillisecond = sAns
   
DateAndTimeToMillisecond_Error:
'Error handling here, but leave the function empty for now, dont want to resume in such a low level library.

End Function

