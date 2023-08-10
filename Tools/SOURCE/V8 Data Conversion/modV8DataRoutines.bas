Attribute VB_Name = "V8DataRoutines"
Option Explicit
DefInt A-Z

'18Mar09 EAC F0048514: Add option to only convert patient with prescriptions
'30Jan13 XN  54164: CreateCategory: Removed sql script PN_UpdateConfigForTest.sql and hardcoded
'                   conversion of A|TPNW.044 to A|PNW.044 and D|TPNSETUP to D|PNSETUP

Private Declare Function GetPrivateProfileSection Lib "kernel32" Alias "GetPrivateProfileSectionA" (ByVal lpAppName As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long
Private Declare Function GetPrivateProfileSectionNames Lib "kernel32" Alias "GetPrivateProfileSectionNamesA" (ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long

Private Const CLASS_NAME = "modV8DataRoutines"

Public Type FileRecord
   record As String * 1024
End Type

Public Type directstruct                                       '12Apr 97 CKJ copied here
   code As String * 12 'top half same as label file
   route As String * 4
   EqualDose As Single
   EqualInterval As Single
   TimeUnits As String * 3
   repeatinterval As Integer
   repeatunits As String * 3
   CourseLength As Integer
   CourseUnits As String * 3
   Abstime As String * 1
   days As String * 1
   dose(12) As Single
   'Time(12) as string * 4 Time reserved word in VBWIN
   times(12) As String * 4

   DeletedBy As String * 5  'bottom half directions only
   ApprovedBy As String * 5
   RevisionNo As Integer
   deleted As String * 1
   location As String * 4   '20Jun95 CKJ was 5
   sparebyte As String * 1  '   "        added
   directs As String * 140
   PRN As String * 1     '13Nov94 ASC
   SortCode As String * 4              '04Mar99 CFY
   DSS As String * 1                   '     "      (0=Not DSS, 1=DSS Visible, 2=DSS Invisible)
   HidePrescriber As String * 1        '     "      (Y/N)
   ManualQtyEntry As String * 1        '09Aug99 SF added as a way of auto setting the manual qty entry flag
   StatDoseFlag As String * 1
   padding As String * 41              '04Mar99 CFY Was 49 now 43, 09Aug99 SF was 43 now 42. 30Mar01 AE 42 to 41 and counting...
End Type


Const mcintPatientIDMismatch = 513
Const mcstrPatientIDMismatchMsg = "Patient ID mismatch between PMR record and patient's label."

Public Type WLabel
   dircode As String * 12 'top half same as label file
   route As String * 4
   EqualInterval As Single
   TimeUnits As String * 3
   repeatinterval As Integer
   repeatunits As String * 3
   Abstime As String * 1 'no longer used
   days As String * 1
   BasePrescriptionID As Long    ' 05Mar02 ATW Trimmed off useless Dose(0) array element to make room for this.
             '              Populated on new prescriptions and maintained throughout all
             '              amendments of that 'scrip - allowing easier tracing of history and easier interfaces
   dose(1 To 6) As Single
   'Time(6) AS STRING * 4 12MAR96 KR
   times(6) As String * 4
   flags As String * 1  '23Nov94 ASC Added for manual flag
   '     flags:   Bit  Value  Usage
   '               7    128   Rx Notes          '11Jun99 CFY Added
   '               6     64   Change of Warnings/directions on label
   '               5     32   Blister bit 3     '20Jan98 CFY
   '               4     16   Blister bit 2     '   "
   '               3      8   Blister bit 1     '   "
   '               2      4   PatOwn            '12Nov97 CFY
   '               1      2   PRN
   '               0      1   Manual
   'padding As String * 4
   prescriptionid As Long ' ASC/CKJ 30sep96 added for internal prescription number
   ReconVol As Single        '<-----CIVAS
   
   Container As String * 1
   ReconAbbr As String * 3
   DiluentAbbr As String * 3
   finalvolume As Single
   drdirection As String * 105
   containersize As Integer
   InfusionTime As Integer   '<-----TO HERE   ASC 03Sep94
              
   PRN As String * 1         '<-----NOT USED
   patid As String * 10
   SisCode As String * 7
   Text As String * 180
   startdate As Long
   StopDate As Long
   IssType As String * 1
   lastqty As Single

   lastdate As String * 6 'could be converted to long integer saving 2 bytes
   topupqty As Single

   dispid As String * 3
   prescriberid As String * 3 '15Nov95 now used
   PharmacistID As String * 3 '26Nov95 now used
   StoppedBy As String * 3    '26Nov95 now used

   rxstatus As String * 1    'could be used with above
   needednexttime As String * 1    '<--NOT used yet for use with PRN flag
   RxStartDate As Long '06Mar93 ASC
   NodIssued As Single
   batchnumber As Integer        '26Nov95 ASC
   'padding2 As String * 2       '17Jan00 SF decremented to insert extraFlags field
   padding2 As String * 1        '17Jan00 SF
   extraFlags As String * 1      '17Jan00 SF added
   '              Bit  Value  Usage
   '               7    128   unused
   '               6     64     "
   '               5     32     "
   '               4     16     "
   '               3      8     "
   '               2      4     "
   '               1      2   06Mar00 SF specifies whether a Pyxis supplied item
   '               0      1   flag to specify if warning should be given as label should change to new INN description

   deletedate As Long
   'NodAdministered AS SINGLE '<--NOT used yet
   'NodOrdered AS SINGLE      '<--NOT used yet
   RxNodIssued As Single  '06Mar93 ASC
End Type

Type orderstruct
   revisionlevel As String * 2   '03May98 CKJ new version number of the structure
   
   code As String * 7
   outstanding As String * 13    '03May98 CKJ Y2K was 9
   orddate As String * 8         '03May98 CKJ Y2K ddmmyyyy  was 6
   ordtime As String * 6         '03May98 CKJ Y2K hhmmss    new
   loccode As String * 3
   supcode As String * 5
   status As String * 1
   numprefix As String * 6       '05may98 CKJ added to allow ord.num to be widened
   num As String * 4
   cost As String * 13           '03May98 CKJ Y2K was 6
   pickno As Integer
   'ward As String * 4           '05may98 CKJ ward field not required
   received As String * 13       '03May98 CKJ Y2K was 6
   recdate As String * 8         '03May98 CKJ Y2K ddmmyyyy  was 6
   rectime As String * 6         '03May98 CKJ Y2K hhmmss    new
   invnum As String * 12         'also holds retcode for returns
   paydate As String * 8         '03May98 CKJ Y2K ddmmyyyy  was 6
   qtyordered As String * 13     '03May98 CKJ Y2K was 6
   urgency As String * 1         'added 24May93
   tofollow As String * 1        'added 3Jun93
   internalsiteno As String * 3  'added 27Mar93
   internalmethod As String * 1

   suppliertype As String * 1    '05May98 CKJ ward, list, store, external supplier
   convfact As String * 5        '   "        d.convfact
   IssueUnits As String * 5      '   "        d.PrintformV
   Stocked As String * 1         '   "        d.sisstock Y/N
   Description As String * 56    '   "        stores/dispensary description

   'pad As String * 818           '03May98 CKJ length 206+818=1024
   pflag As String * 1           '27Jan99 TH price flag for manually entered price
   CreatedUser As String * 3     '01Mar00 TH Added for information
   'pad As String * 817           '27Jan99 TH length 207+817=1024
   custordno As String * 12      '18Apr00 CFY Added
   VATAmount As String * 13      '20Oct00 JN Added
   VATRateCode As String * 1     '20Oct00 JN Added
   VATRatePCT As String * 13     '20Oct00 JN Added
   VATInclusive As String * 13   '20Oct00 JN Added
   Indispute As String * 1       '22Nov00 EAC/CY Added
   IndisputeUser As String * 3   '   "
   ShelfPrinted As String * 1    '22Apr02 SF added (enh#1555) and decremented pad by 1 (was 758)
   pad As String * 757           '01Mar00 TH    '20Oct00 JN Amended pad size from 802 '22Nov00 762 -4 = 758
   crlf As String * 2            '03May98 CKJ separate this from the padding
End Type                         'total length is now 1024 bytes

Private Type pmrrecord
   patid As String * 10
   ptr(49) As Long
End Type

Private Type DateandTime
   Yrs  As Integer   ' 1 to 4000     year from 1 AD to 4000 AD
   Mth  As Integer   ' 1 to 12       NB if = 0 then assume 1   ie 0,0 = 1 Jan
   Day  As Integer   ' 1 to 31       NB if = 0 then assume 1
   Hrs  As Integer   ' 0 to 23       24 hour clock
   min  As Integer   ' 0 to 59
   yday As Integer   ' 0 to 365 year-day, ie the day number of current year
   mint As Long      ' 0 to 2,103,796,800  (~4000 years) mins in total since 1 AD
End Type

Public Type patidtype
   recno As String * 10       ' internal lookup code - used for Xref in Tpn etc
   caseno As String * 10      ' Current caseno
   oldcaseno As String * 10   ' Previous caseno, after a merge
   surname As String * 20     ' trimmed & left justified
   forename As String * 15    ' trimmed & left justified
   dob As String * 8          ' as  ddmmyyyy  only
   sex As String * 1          ' M F or space
   ward As String * 4         ' UCase only
   cons As String * 4         ' UCase only
   weight As String * 6       ' kkk.gg
   height As String * 6       ' ff.ii
   status As String * 1       ' I/O/D/L
   ptr(1 To 10) As String * 6 ' equivalent to rf() 'changed from ptr ASC 1Aug93
 ' ptr(1 To 2) As String * 6  ' equivalent to rf() 'changed from ptr ASC 1Aug93
 ' NHSnumber As String * 10   '
 ' NHSnumvalid As String * 1  '
 ' NHSnumsource As String * 4 '
 ' padding As String * 3
 ' ptr(6 To 10) As String * 6 ' equivalent to rf() 'changed from ptr ASC 1Aug93
   postCode As String * 8     ' added for coventry etc. ASC 06Sep93
   GP As String * 4           ' UCase only
 ' spareroom As String * 6
   HouseNumber As String * 6  ' 28Mar97 CKJ Added
   '--------------
   '  LEN = 173
   '--------------
End Type

Public Type supplierstruct
   code As String * 5
   contractaddress As String * 100
   supaddress As String * 100
   invaddress As String * 100
   conttelno As String * 14
   suptelno As String * 14
   invtelno As String * 14
   discountdesc As String * 70
   discountval As String * 9
   Method As String * 1
   ordmessage As String * 50
   avleadtime As String * 4
   contfaxno As String * 14
   supfaxno As String * 14
   '24Oct96 EAC - match mod made in DOS 12Mar96 by ASC
   'invfaxno As String * 14
   'icode as string * 2
   invfaxno As String * 13                                   '@~@~!!
   pad1 As String * 3           '10Sep96 EAC was icode       '@~@~!!
   '---
   name As String * 15
   ptn As String * 1
   psis As String * 1
   FullName As String * 35     '21Mar93 CKJ Added
   discountbelow As String * 4 '  "
   discountabove As String * 4 '  "
   '27Aug96 EAC
   'pad As String * 95
   icode As String * 8                 '10Sep96 EAC
   CostCentre As String * 15           'could be subjective and/or objective code for links
   PrintDeliveryNote As String * 1     'Yes or No
   PrintPickTicket As String * 1       'Yes or No
   suppliertype As String * 1          'e.g. ward, store, external supplier
   OrderOutput As String * 1           'e.g. paper,fax,edi,internal, X25, modem
   ReceiveGoods As String * 1          'Yes or No
   '02Oct96 EAC
   TopupInterval As String * 2         'Number in days
   ATCSupplied As String * 1           'Yes or No
   pad2 As String * 4                  'WAS Cost code for ward
   TopUpDate As String * 8
   InUse As String * 1
   wardcode As String * 5              'Cost code for ward      '@~@~!! len 4 in translog
   onCost As String * 3                '19Apr00 JP On Cost as % charged to a ward.
   InPatientDirections As String * 1   '30Mar01 AE  "1" is on, anything else is false.
   'pad As String * 42                  '30Mar01 AE  43 - 1 for inpatient directions flag
   AdHocDelNote As String * 1          '31Oct01 TH Added new field to print delivery note on AdHoc Issue
   leadtime As String * 2              '15Jan07 TH Added  (#DR-06-0234)
   pad As String * 39                  '31Oct01 TH 42 - 1 from above field 15Jan07 TH 41 to 39 (#DR-06-0234)

End Type

Public Type pharmacylogstruct
    SiteNumber As String
    DateTime As DateandTime
    DateTimeSec As Integer
    Initials As String
    Terminal As String
    Detail As String
    NSVCode As String * 8
End Type

Public Enum enumV8FileLocation
   eDispdata = 1
   ePatdata = 2
   eAscroot = 3
End Enum

Private Const mind& = 1440&    ' minutes-in-day as long integer
Private Const monthname$ = "---¦January¦February¦March¦April¦May¦June¦July¦August¦September¦October¦November¦December" '14DEC95 KR
Private Const daynames$ = "---¦Monday¦Tuesday¦Wednesday¦Thursday¦Friday¦Saturday¦Sunday"
Private zeroAD As DateandTime

Private mintPmrChan As Integer
Private mintLabelHdl As Integer

Private mstrLabelPath As String

Private mintPatientHdl As Integer

'18Mar09 EAC F0038514: Added
'''Private mobjRxIndex As ASCIndexingV1.Indexing
Private mstrRxIndexPath As String
'---

Public Sub ClosePatientFile()
'----------------------------------------------------------------------------------
'
' Purpose: Closes the Patient file opened using the OpenPatientFile subroutine.
'
' Inputs:
'
' Outputs:
'
' Modification History:
'  01Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ClosePatientFile"

Dim udtError As udtErrorState



   On Error GoTo ErrorHandler

   Close #mintPatientHdl
   
   mintPatientHdl = 0

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Public Function GetPatientRecord(ByVal lngFilePosn As Long) As patidtype
'----------------------------------------------------------------------------------
'
' Purpose: Reads a patient record from the PATID.V5 file at a given position.
'
' Inputs:
'     lngFilePosn        :  The number of the record in the file to be read
'
' Outputs:
'
'     returns the patient record as a UDT patidtype
'
' Modification History:
'  01Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetPatientRecord"

Dim udtError As udtErrorState
Dim udtPid As patidtype

Dim lngByteNo As Long

Dim strExtraInfo As String

   On Error GoTo ErrorHandler

   lngByteNo = ((lngFilePosn - 1) * Len(udtPid)) + 1
   
   strExtraInfo = "Reading patient data from Patid.v5 using filehandle " & _
                  Format$(mintPatientHdl) & " at byte " & Format$(lngByteNo) & _
                  " (Record# " & Format$(lngFilePosn) & ")"
                  
   Get #mintPatientHdl, lngByteNo, udtPid

   GetPatientRecord = udtPid
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function



Private Sub minstodate(dt As DateandTime)
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
Dim dtemp As DateandTime, days&, daysinyear As Integer, daysinmonthx, minsinday&

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

   dt.Mth = 0
   Do
      dt.Mth = dt.Mth + 1                        ' was set to 0 above, so inc
      daysinmonthx = daysinmonth(dt.Mth)         ' how many days in this month?
      If daysinmonthx = 28 Then If isleapyear(dtemp.Yrs) Then daysinmonthx = 29
      If daysinyear <= daysinmonthx Then Exit Do ' remainder is in this month
      daysinyear = daysinyear - daysinmonthx     ' decrement remainder
   Loop
   dt.Day = daysinyear                           ' the remainder
 
   minsinday& = dt.mint Mod mind                 ' mins in current day
   dt.Hrs = minsinday& \ 60                      ' whole hours
   dt.min = minsinday& Mod 60                    ' remaining mins

End Sub

Private Function daysinmonth(ByVal Mth As Integer) As Integer
'-----------------------------------------------------------------------------
' Takes an integer in range 1 to 12 returns the number of days in that month
' Note: February always returns an answer of 28 days
'-----------------------------------------------------------------------------
Dim alines() As String
Dim linesreturned As Integer
Dim monthlength As String

   If Mth > 0 And Mth < 13 Then
         monthlength = "31¦28¦31¦30¦31¦30¦31¦31¦30¦31¦30¦31" '08Dec95 KR use a string list
         alines = Split(monthlength, "¦")
         daysinmonth = Val(alines(Mth - 1))
      Else
         daysinmonth = 0
      End If

End Function

Private Sub datetomins(dt As DateandTime)
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

Public Function V8minsToSqlDate(ByVal lngMinT As Long) As Variant
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngMinT     :  The total number of minutes since 01/01/1800 00:00
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Jan06 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "V8minsToSqlDate"

Dim udtError As udtErrorState

Dim dt As DateandTime

   On Error GoTo ErrorHandler

   If lngMinT > 0 Then
      dt.mint = lngMinT
      minstodate dt
      
      V8minsToSqlDate = CDate(dt.Yrs & "-" & dt.Mth & "-" & dt.Day & " " & dt.Hrs & ":" & dt.min)
   Else
      V8minsToSqlDate = Null
   End If
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Private Function yearday(dt As DateandTime)
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
  
   For monthV = 1 To dt.Mth - 1          ' if month = 0 or 1 then return zero
      If monthV > 12 Then Beep: Exit For        ' 17Feb91 CKJ check added
      dt.yday = dt.yday + daysinmonth(monthV)
   Next         '14Feb95 CKJ removed monthV

   If isleapyear(dt.Yrs) And dt.Mth > 2 Then dt.yday = dt.yday + 1

   '**** WARNING Current day is NOT counted ****
   If dt.Day Then dt.yday = dt.yday + dt.Day - 1
   yearday = dt.yday

End Function

Private Function isleapyear(yearV As Integer)
'-----------------------------------------------------------------------------
'                           returns true% or false%
' Validated by printing to screen & checking manually
' Note that 0 AD does not exist, but the routine returns false% for year = 0
'-----------------------------------------------------------------------------

   isleapyear = ((yearV Mod 4 = 0 And yearV Mod 100 <> 0) Or (yearV Mod 400 = 0) And yearV <> 0)
 
End Function

Public Sub CloseLabelFile()
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'
' Outputs:
'
'
' Modification History:
'  09Jan06 EAC  Written
'
'----------------------------------------------------------------------------------

   On Error Resume Next
   
   Close #mintLabelHdl
   
   mintPmrChan = 0
   mstrLabelPath = vbNullString

   On Error GoTo 0
   
End Sub
Public Sub ClosePmrFile()
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  20Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

   On Error Resume Next
   
   Close #mintPmrChan
   
   mintPmrChan = 0

   On Error GoTo 0
   
End Sub

Public Function CreateCategory(ByVal eFileLocation As enumV8FileLocation, _
                               ByVal strFileName As String, _
                               Optional ByVal boolRemoveExtn As Boolean = True) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  19Apr05 EAC  Written
'  30Jan13 XN   54164 Removed sql script PN_UpdateConfigForTest.sql and hardcoded
'               conversion of A|TPNW.044 to A|PNW.044 and D|TPNSETUP to D|PNSETUP
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "CreateCategory"

Dim udtError As udtErrorState
                                
Dim strCategory As String

   On Error GoTo ErrorHandler

   Select Case eFileLocation
      Case eAscroot
         strCategory = "A"
      Case eDispdata
         strCategory = "D"
      Case ePatdata
         strCategory = "P"
   End Select
   
   strCategory = strCategory & "|"

   strFileName = UCase$(strFileName)
   
   If boolRemoveExtn Then
      strFileName = Replace(strFileName, ".INI", "")
      strFileName = Replace(strFileName, ".DAT", "")
   End If
   
   strCategory = strCategory & strFileName
   
   ' 30Jan13 XN 54164 Removed sql script PN_UpdateConfigForTest.sql and hard coded the conversion of TPN to PN here
   Select Case UCase$(strCategory)
      Case "A|TPNW.044"
         strCategory = "A|PNW.044"
      Case "D|TPNSETUP"
         strCategory = "D|PNSetup"
   End Select
   
   CreateCategory = strCategory
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Function trimz(chars$) As String
'-----------------------------------------------------------------------------
'  Remove all spaces at left & right, and remove anything beyond a null byte.
'-----------------------------------------------------------------------------

Const SUB_NAME = "Trimz"

Dim uError As udtErrorState

   On Error GoTo ErrorHandler
   
   trimz = Trim$(asciiz$(chars$))

Cleanup:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   trimz = ""
   Resume Cleanup
   
End Function

Function asciiz$(st As String)
'--------------------------------
' given an ASCIIZ string (one terminated by null), returns an ordinary string.
' if passed an ordinary variable length string, returns it unchanged.

Const SUB_NAME = "asciiz"

Dim uError As udtErrorState
Dim ptr%

   On Error GoTo ErrorHandler
   
   ptr = InStr(st, Chr$(0))             '  ""=0   "ABC"=0   "|"=1   "ABC|"=4
   If ptr Then asciiz$ = Left$(st, ptr - 1) Else asciiz$ = st

Cleanup:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   asciiz = ""
   Resume Cleanup
   
End Function

Public Function CreateConfigValue(ByVal strValue As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  24Oct05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "CreateConfigValue"

Dim udtError As udtErrorState

Dim strTemp As String


   On Error GoTo ErrorHandler

   If Left$(strValue, 1) = Chr$(34) Then
      strTemp = strValue
   Else
      strTemp = Chr$(34) & strValue
   End If
   
   If Right$(strTemp, 1) <> Chr$(34) Then
      strTemp = strTemp & Chr$(34)
   End If

   If strTemp = Chr$(34) Then strTemp = Chr$(34) & Chr$(34)
   
   CreateConfigValue = strTemp
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Private Function CreateContext(ByVal strFileName As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  25Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "CreateContext"

Dim udtError As udtErrorState

Dim lngPosn As Long

Dim strExtn As String
Dim strName As String


   On Error GoTo ErrorHandler

   strFileName = LCase$(strFileName)
   
   lngPosn = InStr(1, strFileName, ".")
   
   If lngPosn > 1 Then
      strName = Left$(strFileName, lngPosn - 1)
      strExtn = Mid$(strFileName, lngPosn + 1)
   Else
      strName = strFileName
      strExtn = vbNullString
   End If
   
   Select Case strExtn
      Case "v4"
         If Left$(strName, 3) = "ins" Then
            If strName = "instruct" Then
               CreateContext = "instruction.044"
            Else
               CreateContext = "instruction." & Right$(strName, 3)
            End If
            
         End If
         
         If Left$(strName, 3) = "war" Then
            If strName = "warning" Then
               CreateContext = "warning.044"
            Else
               CreateContext = "warning." & Right$(strName, 3)
            End If
         End If
         
      Case "dat"
         CreateContext = strName
      Case "dss"
         If Left$(strName, 3) = "ins" Then
            If strName = "instruct" Then
               CreateContext = "instruction.044.dss"
            Else
               CreateContext = "instruction." & Right$(strName, 3) & ".dss"
            End If
            
         End If
         
         If Left$(strName, 3) = "war" Then
            If strName = "warning" Then
               CreateContext = "warning.044.dss"
            Else
               CreateContext = "warning." & Right$(strName, 3) & ".dss"
            End If
         End If
         
      Case Else
         CreateContext = "Unknown"
   End Select
   
   

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Public Sub FindConfigFiles(ByVal SessionID As Long, _
                           ByVal DataDrive As String, _
                           ByVal SiteNumber As String, _
                           ByVal DBConn As String, _
                           ByVal FileLocation As enumV8FileLocation, _
                           ByVal SearchCriteria As String, _
                           ByRef Cmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  19Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "FindConfigFiles"

Dim udtError As udtErrorState
                           
Dim strCategory As String
Dim strFile As String
Dim strSearch As String
                           
   On Error GoTo ErrorHandler
   
   strSearch = BuildV8FilePath(DataDrive, _
                               FileLocation, _
                               SiteNumber, _
                               SearchCriteria)
                               
   On Error Resume Next   'ensure that we continue on to the next file if an error occurs
   
   strFile = Dir$(strSearch)
   
   Do While strFile <> vbNullString
   
      strCategory = CreateCategory(FileLocation, _
                                   strFile)
                                   
      strFile = BuildV8FilePath(DataDrive, _
                                FileLocation, _
                                SiteNumber, _
                                strFile)
      
      ProcessConfigurationFile SessionID, _
                               DataDrive, _
                               SiteNumber, _
                               DBConn, _
                               strFile, _
                               strCategory, _
                               Cmd
                               
      strFile = Dir$()
   Loop

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub

Public Sub FindLookupFiles(ByVal SessionID As Long, _
                           ByVal DataDrive As String, _
                           ByVal SiteNumber As String, _
                           ByVal DBConn As String, _
                           ByVal FileLocation As enumV8FileLocation, _
                           ByVal FileName As String, _
                           ByRef LookupCmd As ADODB.Command, _
                           ByRef LookupContextCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  22Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "FindLookupFiles"

Dim udtError As udtErrorState
                           
Dim lngLookupContextID As Long

Dim strFile As String
Dim strSearch As String
                           
   On Error GoTo ErrorHandler
   
   strSearch = BuildV8FilePath(DataDrive, _
                               FileLocation, _
                               SiteNumber, _
                               FileName)
                               
   On Error Resume Next   'ensure that we continue on to the next file if an error occurs
   
   strFile = Dir$(strSearch)
   
   Do While strFile <> vbNullString
   
                                   
      lngLookupContextID = InsertLookupContext(SessionID, _
                                               DataDrive, _
                                               SiteNumber, _
                                               DBConn, _
                                               strFile, _
                                               LookupContextCmd)
                                               
                                               
      If lngLookupContextID > 0 Then
         strFile = BuildV8FilePath(DataDrive, _
                                   FileLocation, _
                                   SiteNumber, _
                                   strFile)
         
         ProcessLookupFile SessionID, _
                           DataDrive, _
                           SiteNumber, _
                           DBConn, _
                           strFile, _
                           lngLookupContextID, _
                           LookupCmd
      End If
      
      strFile = Dir$()
   Loop

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub

Public Function GetField(fld As DAO.Field) As Variant
' 2Apr96 CKJ Written
'            Avoids 'Invalid use of Null' problems by assigning
'            zero, "" or date'0' as appropriate.
'14Oct96 CKJ Null date now returns 0# not 31-12-1899
'
' 1 Boolean
' 2 Byte
' 3 Integer
' 4 Long
' 5 currency
' 6 single
' 7 double
' 8 date
' 9 ?  <not defined>
'10 text
'11 longbinary
'12 memo

   If IsNull(fld) Then
         Select Case fld.Type
            Case 1 To 7:   GetField = 0
            Case 8:        GetField = 0#  'Format$(0, "dd-mm-yyyy")
            Case 10 To 12: GetField = ""
            End Select
      Else
         GetField = fld
      End If

End Function
Public Function GetDiskLabel(ByVal strPath As String, _
                             ByVal lngLabelPtr As Long) As WLabel
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetDiskLabel"

Dim udtError As udtErrorState

Dim lngByteNo As Long

Dim udtLbl As WLabel


   On Error GoTo ErrorHandler

   If (UCase$(strPath) <> UCase$(mstrLabelPath)) Then
      If mintLabelHdl > 0 Then
         On Error Resume Next
         Close #mintLabelHdl
         mintLabelHdl = 0
         On Error GoTo ErrorHandler
      End If
   End If
   
   If mintLabelHdl = 0 Then
      mintLabelHdl = FreeFile
      Open strPath For Binary Access Read Lock Read Write As #mintLabelHdl
      mstrLabelPath = strPath
   End If
   
   lngByteNo = (Abs(lngLabelPtr) - 1) * Len(udtLbl) + 1
   Get #mintLabelHdl, lngByteNo, udtLbl
    
   GetDiskLabel = udtLbl

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function getdir(ByVal strFileName As String, _
                       ByVal lngDirectionPosn As Long, _
                       ByRef lngFound As Long) As directstruct
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  08Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "getdir"

Dim udtError As udtErrorState

Dim udtDirection As directstruct

Dim intDirChan As Integer

Dim lngByteNo As Long


   On Error GoTo ErrorHandler

   lngFound = 0
   
   lngByteNo = (Abs(lngDirectionPosn) - 1) * Len(udtDirection) + 1
   
   intDirChan = FreeFile()
   Open strFileName For Binary Access Read Lock Read Write As intDirChan
   
   Get #intDirChan, lngByteNo, udtDirection
   
   Close #intDirChan
                                
   
   udtDirection.directs = Replace(udtDirection.directs, Chr$(30), vbCr)
   udtDirection.directs = Replace(udtDirection.directs, vbLf, " ")

   lngFound = lngByteNo
   
   getdir = udtDirection
   
Cleanup:

   On Error Resume Next
   Close #intDirChan
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function GetLabUtilsLog(ByVal strFileName As String, _
                               ByVal strSiteNumber As String, _
                                ByRef lngPos As Long, _
                                ByRef lngFound As Long) As pharmacylogstruct
'----------------------------------------------------------------------------------
'
' Purpose:  Converts a pharmacy lab utils log file
'
' Inputs:
'     strFilename   :  File to read
'     strSiteNumber :  Site number
'     lngPos        :  File position
'     lngFound      :  If file found
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  19Feb14 XN  Written 56701
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetLabUtilsLog"

Dim udtError As udtErrorState

Dim udtPharmacyLog As pharmacylogstruct

Dim intDirChan As Integer

Dim lngByteNo As Long

Dim TempStr As String
Dim siteNumberStr As String
Dim dateTimeStr As String

   On Error GoTo ErrorHandler

   lngFound = 0
   
   intDirChan = FreeFile()
   Open strFileName For Input As intDirChan
   
   If lngPos > 0 Then Seek intDirChan, lngPos
   
   On Error GoTo ErrorConvert
   
   While strSiteNumber <> siteNumberStr And Not EOF(intDirChan)
      Line Input #intDirChan, TempStr
      siteNumberStr = Mid$(TempStr, 21, 3)
   Wend
   lngPos = Seek(intDirChan)
    
   If strSiteNumber = siteNumberStr Then
       dateTimeStr = Mid$(TempStr, 1, 20)
    
       udtPharmacyLog.DateTime.Day = CInt(Mid$(TempStr, 1, 2))
       udtPharmacyLog.DateTime.Mth = CInt(Mid$(TempStr, 4, 2))
       udtPharmacyLog.DateTime.Yrs = CInt(Mid$(TempStr, 7, 4))
       udtPharmacyLog.DateTime.Hrs = CInt(Mid$(TempStr, 12, 2))
       udtPharmacyLog.DateTime.min = CInt(Mid$(TempStr, 15, 2))
       udtPharmacyLog.DateTimeSec = CInt(Mid$(TempStr, 18, 2))
    
       siteNumberStr = Mid$(TempStr, 21, 3)
       udtPharmacyLog.SiteNumber = siteNumberStr
       udtPharmacyLog.Initials = Trim(Mid(TempStr, 24, 5))
        udtPharmacyLog.NSVCode = Mid(TempStr, 30, 8)
       udtPharmacyLog.Detail = ""
       
       While (Left$(TempStr, 1) = " " Or (dateTimeStr = Mid$(TempStr, 1, 20) And udtPharmacyLog.SiteNumber = Mid$(TempStr, 21, 3) And _
              udtPharmacyLog.Initials = Trim(Mid(TempStr, 24, 5)) And udtPharmacyLog.NSVCode = Mid(TempStr, 30, 8))) And _
             Not EOF(intDirChan)
          If Left$(TempStr, 1) = " " Then
            udtPharmacyLog.Detail = udtPharmacyLog.Detail + LTrim$(Mid(TempStr, 38, Len(TempStr) - 34)) + vbNewLine
          Else
            udtPharmacyLog.Detail = udtPharmacyLog.Detail + Mid(TempStr, 38, Len(TempStr) - 34) + vbNewLine
          End If
          lngPos = Seek(intDirChan)
          Line Input #intDirChan, TempStr
       Wend
       
       lngFound = 1
   End If
   
   Close #intDirChan
                                
   GetLabUtilsLog = udtPharmacyLog
   
Cleanup:

   On Error Resume Next
   Close #intDirChan
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorConvert:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   lngPos = Seek(intDirChan)
   Resume Cleanup

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function


Public Function GetGainLossLog(ByVal strFileName As String, _
                               ByVal strSiteNumber As String, _
                                ByRef lngPos As Long, _
                                ByRef lngFound As Long) As pharmacylogstruct
'----------------------------------------------------------------------------------
'
' Purpose:  Converts a pharmacy Gain Loss log file
'
' Inputs:
'     strFilename   :  File to read
'     strSiteNumber :  Site number
'     lngPos        :  File position
'     lngFound      :  If file found
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Apr16 XN  Written 123082
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetGainLossLog"

Dim udtError As udtErrorState

Dim udtPharmacyLog As pharmacylogstruct

Dim intDirChan As Integer

Dim lngByteNo As Long

Dim TempStr As String
Dim siteNumberStr As String
Dim dateTimeStr As String
Dim posIndex As Integer

   On Error GoTo ErrorHandler

   lngFound = 0
   
   intDirChan = FreeFile()
   Open strFileName For Input As intDirChan
   
   If lngPos > 0 Then Seek intDirChan, lngPos
   
   On Error GoTo ErrorConvert
   
   While strSiteNumber <> siteNumberStr And Not EOF(intDirChan)
      Line Input #intDirChan, TempStr
      siteNumberStr = Mid$(TempStr, 21, 3)
   Wend
   lngPos = Seek(intDirChan)
    
   If strSiteNumber = siteNumberStr Then
       dateTimeStr = Mid$(TempStr, 1, 20)
    
       udtPharmacyLog.DateTime.Day = CInt(Mid$(TempStr, 1, 2))
       udtPharmacyLog.DateTime.Mth = CInt(Mid$(TempStr, 4, 2))
       udtPharmacyLog.DateTime.Yrs = CInt(Mid$(TempStr, 7, 4))
       udtPharmacyLog.DateTime.Hrs = CInt(Mid$(TempStr, 12, 2))
       udtPharmacyLog.DateTime.min = CInt(Mid$(TempStr, 15, 2))
       udtPharmacyLog.DateTimeSec = CInt(Mid$(TempStr, 18, 2))
    
       siteNumberStr = Mid$(TempStr, 21, 3)
       udtPharmacyLog.SiteNumber = siteNumberStr
       
       posIndex = InStr(TempStr, "Resultant Losses")
       If posIndex <> -1 Then
          udtPharmacyLog.NSVCode = Trim$(Mid$(TempStr, posIndex - 8, 8))
       End If
       
       ' Updateprice-reconciliationStck lvl
       posIndex = InStr(TempStr, "Updateprice-reconciliationStck lvl")
       udtPharmacyLog.Detail = udtPharmacyLog.Detail + Trim$(Mid$(TempStr, posIndex, InStr(posIndex, TempStr, "Pck Sz=") - posIndex)) + vbNewLine
       
       ' Pck Sz
       posIndex = InStr(TempStr, "Pck Sz")
       udtPharmacyLog.Detail = udtPharmacyLog.Detail + Trim$(Mid$(TempStr, posIndex, InStr(posIndex, TempStr, "Issue price") - posIndex)) + vbNewLine
       
       ' Issue price
       posIndex = InStr(TempStr, "Issue price")
       udtPharmacyLog.Detail = udtPharmacyLog.Detail + Trim$(Mid$(TempStr, posIndex, InStr(posIndex, TempStr, "Pharmacy agreed price") - posIndex)) + vbNewLine
       
       ' Pharmacy agreed price
       posIndex = InStr(TempStr, "Pharmacy agreed price")
       udtPharmacyLog.Detail = udtPharmacyLog.Detail + Trim$(Mid$(TempStr, posIndex, InStr(posIndex, TempStr, "Reconciled price") - posIndex)) + vbNewLine
       
       ' Reconciled price
       posIndex = InStr(TempStr, "Reconciled price")
       udtPharmacyLog.Detail = udtPharmacyLog.Detail + Trim$(Mid$(TempStr, posIndex, InStr(posIndex, TempStr, "Qty received/reconciled") - posIndex)) + vbNewLine
       
       ' Qty received/reconciled
       posIndex = InStr(TempStr, "Qty received/reconciled")
       udtPharmacyLog.Detail = udtPharmacyLog.Detail + Trim$(Mid$(TempStr, posIndex, InStr(posIndex, TempStr, "Ann use") - posIndex)) + vbNewLine
       
       ' Ann use
       posIndex = InStr(TempStr, "Ann use")
       udtPharmacyLog.Detail = udtPharmacyLog.Detail + Trim$(Mid$(TempStr, posIndex, InStr(posIndex, TempStr, "Qty issued") - posIndex)) + vbNewLine
       
       ' Qty issued
       posIndex = InStr(TempStr, "Qty issued")
       udtPharmacyLog.Detail = udtPharmacyLog.Detail + Trim$(Mid$(TempStr, posIndex, InStr(posIndex, TempStr, "Resultant Losses/gains") - posIndex - 8)) + vbNewLine
       
       ' Resultant Losses/gains
       posIndex = InStr(TempStr, "Resultant Losses/gains")
       udtPharmacyLog.Detail = udtPharmacyLog.Detail + Trim$(Right$(TempStr, Len(TempStr) - posIndex + 1)) + vbNewLine
       
       lngFound = 1
   End If
   
   Close #intDirChan
                                
   GetGainLossLog = udtPharmacyLog
   
Cleanup:

   On Error Resume Next
   Close #intDirChan
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorConvert:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   lngPos = Seek(intDirChan)
   Resume Cleanup

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Public Function GetNegativeLog(ByVal strFileName As String, _
                               ByVal strSiteNumber As String, _
                               ByRef lngPos As Long, _
                               ByRef lngFound As Long) As pharmacylogstruct
'----------------------------------------------------------------------------------
'
' Purpose:  Converts a pharmacy negative log file
'
' Inputs:
'     strFilename   :  File to read
'     strSiteNumber :  Site number
'     lngPos        :  File position
'     lngFound      :  If file found
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Apr16 XN  Written 123082
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetNegativeLog"

Dim udtError As udtErrorState

Dim udtPharmacyLog As pharmacylogstruct

Dim intDirChan As Integer

Dim lngByteNo As Long

Dim TempStr As String
Dim siteNumberStr As String
Dim dateTimeStr As String
Dim midPointIndex As Integer
Dim priceChangeStr As String

   On Error GoTo ErrorHandler

   lngFound = 0
   
   intDirChan = FreeFile()
   Open strFileName For Input As intDirChan
   
   If lngPos > 0 Then Seek intDirChan, lngPos
   
   On Error GoTo ErrorConvert
   
   While strSiteNumber <> siteNumberStr And Not EOF(intDirChan)
      Line Input #intDirChan, TempStr
      siteNumberStr = Mid$(TempStr, 21, 3)
   Wend
   lngPos = Seek(intDirChan)
    
   If strSiteNumber = siteNumberStr Then
       dateTimeStr = Mid$(TempStr, 1, 20)
    
       udtPharmacyLog.DateTime.Day = CInt(Mid$(TempStr, 1, 2))
       udtPharmacyLog.DateTime.Mth = CInt(Mid$(TempStr, 4, 2))
       udtPharmacyLog.DateTime.Yrs = CInt(Mid$(TempStr, 7, 4))
       udtPharmacyLog.DateTime.Hrs = CInt(Mid$(TempStr, 12, 2))
       udtPharmacyLog.DateTime.min = CInt(Mid$(TempStr, 15, 2))
       udtPharmacyLog.DateTimeSec = CInt(Mid$(TempStr, 18, 2))
    
       siteNumberStr = Mid$(TempStr, 21, 3)
       udtPharmacyLog.SiteNumber = siteNumberStr
       udtPharmacyLog.Initials = Trim(Mid(TempStr, 25, 5))
       udtPharmacyLog.NSVCode = Mid(TempStr, 86, 8)
       
       priceChangeStr = Trim(Mid(TempStr, 93, Len(TempStr) - 1))
       midPointIndex = InStr(priceChangeStr, " ")
       
       udtPharmacyLog.Detail = "Negative Stock Warning\nIssued: " + Trim$(Mid$(priceChangeStr, 1, midPointIndex)) + " Stock Lvl Was:" + Trim$(Mid$(priceChangeStr, midPointIndex, Len(priceChangeStr) - 1)) + vbNewLine
       lngFound = 1
   End If
   
   Close #intDirChan
                                
   GetNegativeLog = udtPharmacyLog
   
Cleanup:

   On Error Resume Next
   Close #intDirChan
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorConvert:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   lngPos = Seek(intDirChan)
   Resume Cleanup

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Public Function GetReport(ByVal strFileName As String, _
                          ByVal strSiteNumber As String, _
                          ByRef lngFound As Long) As String
                              
'----------------------------------------------------------------------------------
'
' Purpose:  Read pharmacy report file
'
' Inputs:
'     strFilename   :  File to read
'     strSiteNumber :  Site number
'     lngFound      :  If file found
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  21May14 XN  Written 88862
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetReport"

Dim udtError As udtErrorState

Dim intDirChan As Integer

Dim TempStr As String

   On Error GoTo ErrorHandler

   lngFound = 0
   
   intDirChan = FreeFile()
   Open strFileName For Input As intDirChan
   
   While Not EOF(intDirChan)
    Line Input #intDirChan, TempStr
    GetReport = GetReport + TempStr + vbNewLine
   Wend
    
   Close #intDirChan
                                
Cleanup:

   On Error Resume Next
   Close #intDirChan
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function


Private Sub BlankDir(dirn As directstruct)

Dim R As FileRecord
Dim x%
   

   R.record = ""
   LSet dirn = R
   For x = 1 To 6
      dirn.dose(x) = 0
   Next
   dirn.EqualDose = 0
   dirn.EqualInterval = 0
   dirn.repeatinterval = 0
   dirn.CourseLength = 0
   dirn.RevisionNo = 0
   dirn.Abstime = "Y"
   dirn.days = Chr$(0)
   dirn.PRN = "0"              'ASC 28Apr95

End Sub
Public Function GetOrder(ByVal Chan As Integer, _
                         ByVal FilePosn As Long) As orderstruct
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  19Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetOrder"

Dim udtError As udtErrorState
                        
Dim udtOrder As orderstruct

Dim lngByteNo As Long


   On Error GoTo ErrorHandler

   lngByteNo = (FilePosn - 1) * 1024 + 1
   Get #Chan, lngByteNo, udtOrder
   
   GetOrder = udtOrder
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                         
End Function

Private Function GetPMR(ByVal lngPmrPtr As Long) As pmrrecord
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  20Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetPMR"

Dim udtError As udtErrorState
Dim udtPmrRecord As pmrrecord

Dim lngByteNo As Long

   On Error GoTo ErrorHandler

   lngByteNo = (lngPmrPtr - 1) * Len(udtPmrRecord) + 1
   
   Get #mintPmrChan, lngByteNo, udtPmrRecord
   
   GetPMR = udtPmrRecord
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Private Function InsertLookupContext(ByVal lngSessionID As Long, _
                                     ByVal strDataDrive As String, _
                                     ByVal strSiteNumber As String, _
                                     ByVal strDbConn As String, _
                                     ByVal strFileName As String, _
                                     ByRef adoCmd As ADODB.Command) As Long
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  22Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "InsertLookupContext"

Dim udtError As udtErrorState
                                     
                                     


   On Error GoTo ErrorHandler

   With adoCmd
      .Parameters("context").value = CreateContext(strFileName)
   
      .Execute , , adExecuteNoRecords
      
Cleanup:

      If IsNull(adoCmd.Parameters("wlookupcontextid").value) Then adoCmd.Parameters("wlookupcontextid").value = -1
      If IsEmpty(adoCmd.Parameters("wlookupcontextid").value) Then adoCmd.Parameters("wlookupcontextid").value = 0
      
      If adoCmd.Parameters("wlookupcontextid").value <= 0 Then
         LogConversionError udtError, _
                            strSiteNumber, _
                            strDbConn, _
                            strFileName, _
                            Null
      Else
         InsertLookupContext = adoCmd.Parameters("wlookupcontextid").value
      End If
      
   End With



   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                                     
End Function

Public Function LabelMismatch(ByVal strSiteNumber As String, _
                              ByVal strDbConn As String, _
                              ByVal strFile As String, _
                              ByVal lngFilePosn As Long, _
                              ByVal strDataDrive As String, _
                              ByVal strPatientID As String, _
                              ByVal lngLabelId As Long) As Boolean
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  20Apr05 EAC  Written
'
'----------------------------------------------------------------------------------
Const RECNO_INDEX_FILE = "PATRECNO.IDX"
Const SUB_NAME = "LabelMismatch"

Dim udtError As udtErrorState
Dim udtPid As patidtype
Dim udtPmr As pmrrecord

'Dim objIndexing As ASCIndexingV1.Indexing

Dim lngLoop As Long
Dim lngRecno As Long
Dim lngPmrPtr As Long

Dim strExtraInfo As String
Dim strIndexPath As String

   On Error GoTo ErrorHandler

   LabelMismatch = True
   
   strIndexPath = BuildV8FilePath(strDataDrive, _
                                  ePatdata, _
                                  strSiteNumber, _
                                  RECNO_INDEX_FILE)
                                  
   strExtraInfo = "Creating the 'ASCIndexingV1.Indexing' object"
   'Set objIndexing = CreateObject("ASCIndexingV1.Indexing")
   
   strExtraInfo = "Finding patient with internal record no '" & strPatientID & "'"
   'objIndexing.binarysearchidx strPatientID, strIndexPath, -1, 0, lngRecno
   binarysearchidx strPatientID, strIndexPath, -1, 0, lngRecno
   
   'Set objIndexing = Nothing
                                          
   If (lngRecno > 0) Then
         strExtraInfo = "Raading the patient with recno = '" + Format$(lngRecno) + "'"
         udtPid = GetPatientRecord(lngRecno)
   
         strExtraInfo = "Reading the PMR ptr from ptr8 in the patient record"
         lngPmrPtr = Val(udtPid.ptr(8))
         
         If lngPmrPtr > 1 Then
            strExtraInfo = "Reading the PMR record at position " & Format(lngPmrPtr)
            udtPmr = GetPMR(lngPmrPtr)
            
            If udtPmr.patid = strPatientID Then
               strExtraInfo = "Looking for labelid " & Format(lngLabelId) & " in the PMR pointers"
               For lngLoop = 49 To 0 Step -1
                  If Abs(udtPmr.ptr(lngLoop)) = lngLabelId Then
                     LabelMismatch = False
                     Exit For
                  End If
               Next
               
               If LabelMismatch Then
                  With udtError
                     .Number = vbObjectError + 12345
                     .Description = "Label Mismatch  - " & strExtraInfo
                     .source = SUB_NAME
                     .HelpFile = ""
                     .HelpContext = 0
                  End With
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
            Else
               With udtError
                  .Number = vbObjectError + 12345
                  .Description = "Label Mismatch - PMR Patid = '" & Trim$(udtPmr.patid) & "' - Patients Patid = '" & Trim$(strPatientID) & "'"
                  .source = SUB_NAME
                  .HelpFile = ""
                  .HelpContext = 0
               End With
               LogConversionError udtError, _
                                  strSiteNumber, _
                                  strDbConn, _
                                  strFile, _
                                  lngFilePosn
               
               End If
         End If
      Else
         With udtError
            .Number = vbObjectError + 12345
            .Description = "Label Mismatch - Patient with Recno = '" & strPatientID & "' not found"
            .source = SUB_NAME
            .HelpFile = ""
            .HelpContext = 0
         End With
         LogConversionError udtError, _
                         strSiteNumber, _
                         strDbConn, _
                         strFile, _
                         lngFilePosn
      End If
   
Cleanup:
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
   
End Function
Public Sub OpenPmrFile(ByVal SiteNumber As String, _
                       ByVal DataDrive As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  20Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "OpenPmrFile"

Dim udtError As udtErrorState
                       
Dim strFile As String

   On Error Resume Next
   If mintPmrChan > 0 Then
      Close #mintPmrChan
      mintPmrChan = 0
   End If

   On Error GoTo ErrorHandler

   strFile = BuildV8FilePath(DataDrive, _
                             ePatdata, _
                             SiteNumber, _
                             "pmr.v5")
                             
   mintPmrChan = FreeFile()

   Open strFile For Binary Access Read Shared As #mintPmrChan
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                       
End Sub


Sub OpenPatientFile(strDataPath As String)
'----------------------------------------------------------------------------------
'
' Purpose: Opens the PATID.V5 file on disk.
'
' Inputs:
'     strDataPath        :  The path of the file to be opened.
'
' Outputs:
'
' Modification History:
'  01Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "OpenPatientFile"

Dim udtError As udtErrorState

Const cstrProcName = ".OpenPatientDiskFile"

Dim uError As udtErrorState
Dim sExtraInfo As String


   On Error GoTo ErrorHandler

   mintPatientHdl = FreeFile
   
   sExtraInfo = "Opening file " & strDataPath
   Open strDataPath For Binary Access Read Write Shared As #mintPatientHdl
         
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , sExtraInfo
   Resume Cleanup
      
End Sub

Private Sub ProcessConfigurationFile(ByVal lngSessionID As Long, _
                                     ByVal strDataDrive As String, _
                                     ByVal strSiteNumber As String, _
                                     ByVal strDbConn As String, _
                                     ByVal strFileName As String, _
                                     ByVal strCategory As String, _
                                     ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  19Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ProcessConfigurationFile"

Dim udtError As udtErrorState

Dim lngComment As Long
Dim lngEqualsPosn As Long
Dim lngLoop As Long
Dim lngLoop2 As Long
Dim lngresult As Long

Dim astrSectionNames() As String
Dim astrLines() As String

Dim strbuffer As String * 32768
Dim strData As String
Dim strLine As String
Dim strKeyName As String
Dim strSection As String
Dim strValue As String


   On Error GoTo ErrorHandler

   lngresult = GetPrivateProfileSectionNames(strbuffer, 32768, strFileName)
   
   strData = Left$(strbuffer, lngresult)
   astrSectionNames = Split(strData, Chr$(0))
   
   frmProgress.ShowProgress strSiteNumber, _
                            "Processing: " & strFileName, _
                            0
   On Error GoTo DataError
   
   For lngLoop = LBound(astrSectionNames) To (UBound(astrSectionNames) - 1)
   
      strSection = Trim$(astrSectionNames(lngLoop))
   
      strbuffer = Space$(Len(strbuffer))
      lngresult = GetPrivateProfileSection(strSection, strbuffer, Len(strbuffer), strFileName)
      strData = Left$(strbuffer, lngresult)
      
      astrLines = Split(strData, Chr(0))
      
      For lngLoop2 = LBound(astrLines) To UBound(astrLines)
      
         strLine = astrLines(lngLoop2)
         
         lngComment = InStr(1, strLine, "'")
         If lngComment > 0 Then strLine = Trim$(Left$(strLine, lngComment - 1))
         
         lngComment = InStr(1, strLine, ";")
         If lngComment > 0 Then strLine = Trim$(Left$(strLine, lngComment - 1))
         
         lngEqualsPosn = InStr(1, strLine, "=")
         
         If lngEqualsPosn > 0 Then
            strKeyName = Left$(strLine, lngEqualsPosn - 1)
            strValue = Mid$(strLine, lngEqualsPosn + 1)
            If Left$(strValue, 1) = Chr$(34) Then
               lngComment = InStr(2, strValue, Chr$(34))
               If lngComment = 0 Then lngComment = Len(strValue)
               If Len(strValue) > 2 Then strValue = Mid$(strValue, 2, lngComment - 2)
            End If
            
            With adoCmd
               .Parameters("category").value = strCategory
               .Parameters("section").value = strSection
               .Parameters("key").value = strKeyName
               .Parameters("value").value = CreateConfigValue(strValue)
               
               .Execute , , adExecuteNoRecords
               
DataResume:
               If IsNull(adoCmd.Parameters("wconfigurationid").value) Then adoCmd.Parameters("wconfigurationid").value = -1
               If IsEmpty(adoCmd.Parameters("wconfigurationid").value) Then adoCmd.Parameters("wconfigurationid").value = 0
               
               If adoCmd.Parameters("wconfigurationid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFileName, _
                                     strKeyName
               End If
               
               DoEvents
               
            End With
         End If
         
      Next
      
   Next
      

Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                                    
End Sub

Private Sub ProcessLookupFile(ByVal lngSessionID As Long, _
                              ByVal strDataDrive As String, _
                              ByVal strSiteNumber As String, _
                              ByVal strDbConn As String, _
                              ByVal strFileName As String, _
                              ByVal lngContextID As Long, _
                              ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  19Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ProcessLookupFile"

Dim udtError As udtErrorState

Dim blnInUSe As Boolean

Dim intHndl As Integer

Dim lngLoop As Long
Dim lngNumOfRecords As Long
Dim lngPosn As Long

Dim strLine As String
Dim strCode As String
Dim strExpn As String

   On Error GoTo ErrorHandler
   
   intHndl = FreeFile()
   
   Open strFileName For Input Lock Write As #intHndl
   
   On Error GoTo DataError
   
   If Not EOF(intHndl) Then
   
      Line Input #intHndl, strLine
      lngNumOfRecords = Val(Trim$(strLine))
         
      frmProgress.ShowProgress strSiteNumber, _
                               "Processing: " + strFileName, _
                               lngNumOfRecords
                               
      frmMain.StartProgressTimer
      
      For lngLoop = 1 To lngNumOfRecords
         If frmMain.UpdateProgress Then
            frmProgress.UpdateProgress lngLoop
            
            frmMain.StartProgressTimer
         End If
         
         If Not EOF(intHndl) Then
            
            Input #intHndl, strCode, strExpn
            
            blnInUSe = True
            If Left$(strExpn, 1) = "#" Then
               blnInUSe = False
               strExpn = Mid$(strExpn, 2)
            End If
            
            With adoCmd
               
               .Parameters("wlookupcontextid").value = lngContextID
               .Parameters("code").value = strCode
               .Parameters("expansion").value = strExpn
               .Parameters("inuse").value = blnInUSe
               
               .Execute , , adExecuteNoRecords
               
DataResume:
         
               If IsNull(adoCmd.Parameters("wlookupid").value) Then adoCmd.Parameters("wlookupid").value = -1
               If IsEmpty(adoCmd.Parameters("wlookupid").value) Then adoCmd.Parameters("wlookupid").value = 0
               
               If adoCmd.Parameters("wlookupid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFileName, _
                                     lngLoop
               End If
               
               DoEvents
               
            End With
         End If 'not objtxt.AtEndOfStream
      Next
   End If 'not eof
   
Cleanup:

   On Error Resume Next
   Close #intHndl
   intHndl = 0
   
   frmProgress.ProgressHide
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                                    
End Sub

Public Function DoesPatientHavePrescriptions(udtPatient As patidtype, strRecno As String) As Boolean
'----------------------------------------------------------------------------------
'
' Purpose: Checks if the patient has current or historical prescriptions
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns true or false
'
' Modification History:
'  18Mar09 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "DoesPatientHavePrescriptions"

Dim udtError As udtErrorState

Dim boolPatientHasPrescriptions As Boolean

   On Error GoTo ErrorHandler
   
   boolPatientHasPrescriptions = False
   
   boolPatientHasPrescriptions = DoesPatientHaveCurrentPmrEntries(udtPatient, strRecno)
   
   If (boolPatientHasPrescriptions = False) Then
      boolPatientHasPrescriptions = DoesPatientHaveHistoricalPrescription(udtPatient, strRecno)
   End If

Cleanup:

   DoesPatientHavePrescriptions = boolPatientHasPrescriptions
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Private Function DoesPatientHaveCurrentPmrEntries(udtPatient As patidtype, strRecno As String) As Boolean
'----------------------------------------------------------------------------------
'
' Purpose: Checks if the patient has current medication in the PMR
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns true if a prescription entry is found in the PMR record for the patient or false otherwise
'
' Modification History:
'  18Mar09 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "DoesPatientHaveCurrentPmrEntries"

Dim udtError As udtErrorState

Dim udtPmr As pmrrecord

Dim boolPrescriptionFound As Boolean

Dim lngLoop As Long
Dim lngPmrPtr As Long

Dim strExtraInfo As String

   On Error GoTo ErrorHandler
   
   boolPrescriptionFound = False
   
   strExtraInfo = "Reading the PMR ptr from ptr8 in the patient record"
   lngPmrPtr = Val(udtPatient.ptr(8))
   
   If lngPmrPtr > 1 Then
      strExtraInfo = "Reading the PMR record at position " & Format(lngPmrPtr)
      udtPmr = GetPMR(lngPmrPtr)
      
      If trimz$(udtPmr.patid) = strRecno Then
         strExtraInfo = "Looking for a valid LabelID in the PMR pointers"
         For lngLoop = 49 To 0 Step -1
            If (udtPmr.ptr(lngLoop) <> 0) Then
               boolPrescriptionFound = True
               Exit For
            End If
            Next
      End If
   End If

Cleanup:

   DoesPatientHaveCurrentPmrEntries = boolPrescriptionFound
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
                       
End Function

Private Function DoesPatientHaveHistoricalPrescription(udtPatient As patidtype, strRecno As String) As Boolean
'----------------------------------------------------------------------------------
'
' Purpose: Checks if the patient has an entry in the RX.IDX file indicating that they have
'          historical prescriptions
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns true if an entry is found in the RX.IDX file or false if no entry found.
'
' Modification History:
'  18Mar09 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "DoesPatientHaveHistoricalPrescription"

Dim udtError As udtErrorState

Dim boolRxPrescriptionFound As Boolean

Dim strExtraInfo As String

Dim lngFound As Long

   On Error GoTo ErrorHandler

   boolRxPrescriptionFound = False
   
   strExtraInfo = "Finding patient with internal record no '" & strRecno & "'"
   'mobjRxIndex.binarysearchidx strRecno, mstrRxIndexPath, -1, 0, lngFound, True
   binarysearchidx strRecno, mstrRxIndexPath, -1, 0, lngFound, True
   
   If (lngFound > 0) Then boolRxPrescriptionFound = True
   
Cleanup:

   DoesPatientHaveHistoricalPrescription = boolRxPrescriptionFound
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
                       
End Function

Public Sub OpenRxIndexFile(ByVal SiteNumber As String, _
                           ByVal DataDrive As String)
'----------------------------------------------------------------------------------
'
' Purpose: Opens the RX.IDX file
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Mar09 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "OpenRxIndexFile"

Dim udtError As udtErrorState
                       
Dim strFile As String

   On Error Resume Next
   
   mstrRxIndexPath = BuildV8FilePath(DataDrive, _
                                     ePatdata, _
                                     SiteNumber, _
                                     "RX.IDX")
                                     
   'Set mobjRxIndex = CreateObject("ASCIndexingV1.Indexing")
      
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                       
End Sub

Public Sub CloseRxIndexFile()
'----------------------------------------------------------------------------------
'
' Purpose: Closes the channel to the RX.IDX file
'
' Inputs:
'
' Outputs:
'
'     None
'
' Modification History:
'  18Mar09 EAC  Written
'
'----------------------------------------------------------------------------------

   On Error Resume Next
   
   'If Not (mobjRxIndex Is Nothing) Then
      
      'mobjRxIndex.binarysearchidx "", "", 0, 0, 0
      binarysearchidx "", "", 0, 0, 0
      
      'Set mobjRxIndex = Nothing
      
      mstrRxIndexPath = ""
   'End If
   
   On Error GoTo 0
   
End Sub
Public Function GetPNEditLog(ByVal strFileName As String, _
                               ByVal strSiteNumber As String, _
                               ByRef lngPos As Long, _
                               ByRef lngFound As Long) As pharmacylogstruct
'----------------------------------------------------------------------------------
'
' Purpose:  Converts a pharmacy PNEdit log file
'
' Inputs:
'     strFilename   :  File to read
'     strSiteNumber :  Site number
'     lngPos        :  File position
'     lngFound      :  If file found
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  03Apr17 TH  Written 175557
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetPNEditLog"

Dim udtError As udtErrorState

Dim udtPharmacyLog As pharmacylogstruct

Dim intDirChan As Integer

Dim lngByteNo As Long

Dim TempStr As String
Dim siteNumberStr As String
Dim dateTimeStr As String
Dim midPointIndex As Integer
Dim DetailStr As String

   On Error GoTo ErrorHandler

   lngFound = 0
   
   intDirChan = FreeFile()
   Open strFileName For Input As intDirChan
   
   If lngPos > 0 Then Seek intDirChan, lngPos
   
   On Error GoTo ErrorConvert
   
   While strSiteNumber <> siteNumberStr And Not EOF(intDirChan)
      Line Input #intDirChan, TempStr
      siteNumberStr = Mid$(TempStr, 21, 3)
   Wend
   lngPos = Seek(intDirChan)
    
   If strSiteNumber = siteNumberStr Then
       dateTimeStr = Mid$(TempStr, 1, 20)
    
       udtPharmacyLog.DateTime.Day = CInt(Mid$(TempStr, 1, 2))
       udtPharmacyLog.DateTime.Mth = CInt(Mid$(TempStr, 4, 2))
       udtPharmacyLog.DateTime.Yrs = CInt(Mid$(TempStr, 7, 4))
       udtPharmacyLog.DateTime.Hrs = CInt(Mid$(TempStr, 12, 2))
       udtPharmacyLog.DateTime.min = CInt(Mid$(TempStr, 15, 2))
       udtPharmacyLog.DateTimeSec = CInt(Mid$(TempStr, 18, 2))
    
       siteNumberStr = Mid$(TempStr, 21, 3)
       udtPharmacyLog.SiteNumber = siteNumberStr
       udtPharmacyLog.Initials = Trim(Mid(TempStr, 25, 5))
       udtPharmacyLog.NSVCode = ""
       
       DetailStr = Trim(Mid(TempStr, 30, Len(TempStr) - 29))
       
       
       udtPharmacyLog.Detail = DetailStr + vbNewLine
       lngFound = 1
   End If
   
   Close #intDirChan
                                
   GetPNEditLog = udtPharmacyLog
   
Cleanup:

   On Error Resume Next
   Close #intDirChan
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorConvert:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   lngPos = Seek(intDirChan)
   Resume Cleanup

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Public Function GetReconcilLog(ByVal strFileName As String, _
                               ByVal strSiteNumber As String, _
                               ByRef lngPos As Long, _
                               ByRef lngFound As Long) As pharmacylogstruct
'----------------------------------------------------------------------------------
'
' Purpose:  Converts a pharmacy PNEdit log file
'
' Inputs:
'     strFilename   :  File to read
'     strSiteNumber :  Site number
'     lngPos        :  File position
'     lngFound      :  If file found
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  03Apr17 TH  Written 175557
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetReconcilLog"

Dim udtError As udtErrorState

Dim udtPharmacyLog As pharmacylogstruct

Dim intDirChan As Integer

Dim lngByteNo As Long

Dim TempStr As String
Dim siteNumberStr As String
Dim dateTimeStr As String
Dim midPointIndex As Integer
Dim DetailStr As String

   On Error GoTo ErrorHandler

   lngFound = 0
   
   intDirChan = FreeFile()
   Open strFileName For Input As intDirChan
   
   If lngPos > 0 Then Seek intDirChan, lngPos
   
   On Error GoTo ErrorConvert
   
   While strSiteNumber <> siteNumberStr And Not EOF(intDirChan)
      Line Input #intDirChan, TempStr
      siteNumberStr = Mid$(TempStr, 21, 3)
   Wend
   lngPos = Seek(intDirChan)
    
   If strSiteNumber = siteNumberStr Then
       dateTimeStr = Mid$(TempStr, 1, 20)
    
       udtPharmacyLog.DateTime.Day = CInt(Mid$(TempStr, 1, 2))
       udtPharmacyLog.DateTime.Mth = CInt(Mid$(TempStr, 4, 2))
       udtPharmacyLog.DateTime.Yrs = CInt(Mid$(TempStr, 7, 4))
       udtPharmacyLog.DateTime.Hrs = CInt(Mid$(TempStr, 12, 2))
       udtPharmacyLog.DateTime.min = CInt(Mid$(TempStr, 15, 2))
       udtPharmacyLog.DateTimeSec = CInt(Mid$(TempStr, 18, 2))
    
       siteNumberStr = Mid$(TempStr, 21, 3)
       udtPharmacyLog.SiteNumber = siteNumberStr
       udtPharmacyLog.Initials = Trim(Mid(TempStr, 25, 5))
       udtPharmacyLog.NSVCode = Trim(Mid(TempStr, 30, 7))
       
       DetailStr = Trim(Mid(TempStr, 37, Len(TempStr) - 36))
       
       
       udtPharmacyLog.Detail = DetailStr + vbNewLine
       lngFound = 1
   End If
   
   Close #intDirChan
                                
   GetReconcilLog = udtPharmacyLog
   
Cleanup:

   On Error Resume Next
   Close #intDirChan
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorConvert:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   lngPos = Seek(intDirChan)
   Resume Cleanup

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function


Public Function GetEditorsLog(ByVal strFileName As String, _
                               ByVal strSiteNumber As String, _
                               ByRef lngPos As Long, _
                               ByRef lngFound As Long) As pharmacylogstruct
'----------------------------------------------------------------------------------
'
' Purpose:  Converts a pharmacy PNEdit log file
'
' Inputs:
'     strFilename   :  File to read
'     strSiteNumber :  Site number
'     lngPos        :  File position
'     lngFound      :  If file found
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  03Apr17 TH  Written 175557 - Not fully tested as realised on reflection this log is obselete to all intents and purpose.
'              DO NOT  USE AS NOT FULLY  TESTED.
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetEditorsLog"

Dim udtError As udtErrorState

Dim udtPharmacyLog As pharmacylogstruct

Dim intDirChan As Integer

Dim lngByteNo As Long

Dim TempStr As String
Dim siteNumberStr As String
Dim dateTimeStr As String
Dim midPointIndex As Integer
Dim DetailStr As String

   On Error GoTo ErrorHandler

   lngFound = 0
   
   intDirChan = FreeFile()
   Open strFileName For Input As intDirChan
   
   If lngPos > 0 Then Seek intDirChan, lngPos
   
   On Error GoTo ErrorConvert
   
   While strSiteNumber <> siteNumberStr And Not EOF(intDirChan)
      Line Input #intDirChan, TempStr
      siteNumberStr = Mid$(TempStr, 21, 3)
   Wend
   lngPos = Seek(intDirChan)
    
   'If strSiteNumber = siteNumberStr Then
   If strSiteNumber = siteNumberStr And (Mid$(TempStr, 3, 1) = "-") And (Mid$(TempStr, 6, 1) = "-") Then '06 Ensure that we have a date at the front so this is a proper logline
       dateTimeStr = Mid$(TempStr, 1, 20)
    
       udtPharmacyLog.DateTime.Day = CInt(Mid$(TempStr, 1, 2))
       udtPharmacyLog.DateTime.Mth = CInt(Mid$(TempStr, 4, 2))
       udtPharmacyLog.DateTime.Yrs = CInt(Mid$(TempStr, 7, 4))
       udtPharmacyLog.DateTime.Hrs = CInt(Mid$(TempStr, 12, 2))
       udtPharmacyLog.DateTime.min = CInt(Mid$(TempStr, 15, 2))
       udtPharmacyLog.DateTimeSec = CInt(Mid$(TempStr, 18, 2))
    
       siteNumberStr = Mid$(TempStr, 21, 3)
       udtPharmacyLog.SiteNumber = siteNumberStr
       udtPharmacyLog.Initials = Trim(Mid(TempStr, 25, 5))
       udtPharmacyLog.NSVCode = ""
       
       DetailStr = Trim(Mid(TempStr, 30, Len(TempStr) - 29))
       
       
       udtPharmacyLog.Detail = DetailStr + vbNewLine
       
       Do While Not EOF(intDirChan)
         Line Input #intDirChan, TempStr
         If Len(TempStr) > 10 Then
            If (Mid$(TempStr, 3, 1) <> "-") And (Mid$(TempStr, 6, 1) <> "-") Then
               udtPharmacyLog.Detail = TempStr + vbNewLine
               lngPos = Seek(intDirChan)
            Else
               Exit Do
            End If
         End If
       Loop
       
       lngFound = 1
   End If
   
   Close #intDirChan
                                
   GetEditorsLog = udtPharmacyLog
   
Cleanup:

   On Error Resume Next
   Close #intDirChan
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorConvert:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   lngPos = Seek(intDirChan)
   Resume Cleanup

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Public Function GetEscIssueLog(ByVal strFileName As String, _
                               ByVal strSiteNumber As String, _
                               ByRef lngPos As Long, _
                               ByRef lngFound As Long) As pharmacylogstruct
'----------------------------------------------------------------------------------
'
' Purpose:  Converts a pharmacy EscIssue log file
'
' Inputs:
'     strFilename   :  File to read
'     strSiteNumber :  Site number
'     lngPos        :  File position
'     lngFound      :  If file found
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  03Apr17 TH  Written 175557
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetEscIssueLog"

Dim udtError As udtErrorState

Dim udtPharmacyLog As pharmacylogstruct

Dim intDirChan As Integer

Dim lngByteNo As Long

Dim TempStr As String
Dim siteNumberStr As String
Dim dateTimeStr As String
Dim midPointIndex As Integer
Dim DetailStr As String

   On Error GoTo ErrorHandler

   lngFound = 0
   
   intDirChan = FreeFile()
   Open strFileName For Input As intDirChan
   
   If lngPos > 0 Then Seek intDirChan, lngPos
   
   On Error GoTo ErrorConvert
   
   While strSiteNumber <> siteNumberStr And Not EOF(intDirChan)
      Line Input #intDirChan, TempStr
      siteNumberStr = Mid$(TempStr, 21, 3)
   Wend
   lngPos = Seek(intDirChan)
    
   If strSiteNumber = siteNumberStr Then
       dateTimeStr = Mid$(TempStr, 1, 20)
    
       udtPharmacyLog.DateTime.Day = CInt(Mid$(TempStr, 1, 2))
       udtPharmacyLog.DateTime.Mth = CInt(Mid$(TempStr, 4, 2))
       udtPharmacyLog.DateTime.Yrs = CInt(Mid$(TempStr, 7, 4))
       udtPharmacyLog.DateTime.Hrs = CInt(Mid$(TempStr, 12, 2))
       udtPharmacyLog.DateTime.min = CInt(Mid$(TempStr, 15, 2))
       udtPharmacyLog.DateTimeSec = CInt(Mid$(TempStr, 18, 2))
    
       siteNumberStr = Mid$(TempStr, 21, 3)
       udtPharmacyLog.SiteNumber = siteNumberStr
       udtPharmacyLog.Initials = Trim(Mid(TempStr, 25, 5))
       udtPharmacyLog.NSVCode = Trim(Mid(TempStr, 86, 7))
       
       DetailStr = Trim(Mid(TempStr, 30, Len(TempStr) - 29))
       
       
       udtPharmacyLog.Detail = DetailStr + vbNewLine
       lngFound = 1
   End If
   
   Close #intDirChan
                                
   GetEscIssueLog = udtPharmacyLog
   
Cleanup:

   On Error Resume Next
   Close #intDirChan
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorConvert:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   lngPos = Seek(intDirChan)
   Resume Cleanup

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

