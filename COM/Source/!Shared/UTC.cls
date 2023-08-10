VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "UTC"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'  Description :  Module for UTC (Coordinated Universal Time and similar stuff)
'                 This format is the standard for civilian time and
'                 has been adopted by W3C as the standard Date type for XML

'  Viable formats for UTC are the following

'   Year:
'      YYYY (eg 1997)
'   Year and month:
'      YYYY-MM (eg 1997-07)
'   Complete Date:
'      YYYY-MM-DD (eg 1997-07-16)
'   Complete date plus hours and minutes:
'      YYYY-MM-DDThh:mmTZD (eg 1997-07-16T19:20+01:00)
'   Complete date plus hours, minutes and seconds:
'      YYYY-MM-DDThh:mm:ssTZD (eg 1997-07-16T19:20:30+01:00)
'   Complete date plus hours, minutes, seconds and a decimal fraction of a second
'      YYYY-MM-DDThh:mm:ss.sTZD (eg 1997-07-16T19:20:30.45+01:00)

'where:
'
'     YYYY = four-digit year
'     MM   = two-digit month (01=January, etc.)
'     DD   = two-digit day of month (01 through 31)
'     hh   = two digits of hour (00 through 23) (am/pm NOT allowed)
'     mm   = two digits of minute (00 through 59)
'     ss   = two digits of second (00 through 59)
'     s    = one or more digits representing a decimal fraction of a second
'     TZD  = time zone designator (Z or +hh:mm or -hh:mm)

Private Enum UTCComponents
   years = 1
   months = 2
   days = 4
   hhmm = 8
   seconds = 16
   fracsec = 32
   timezone = 64
End Enum

Public Enum UTCFormat
   [YYYY] = years
   [YYYY_MM] = [YYYY] Or months
   [YYYY_MM_DD] = [YYYY_MM] Or days
   [YYYY_MM_DDThh_mmTZD] = [YYYY_MM_DD] Or hhmm Or timezone
   [YYYY_MM_DDThh_mm_ssTZD] = [YYYY_MM_DDThh_mmTZD] Or seconds
   [YYYY_MM_DDThh_mm_ss_sTZD] = [YYYY_MM_DDThh_mm_ssTZD] Or fracsec
End Enum

Private m_format As UTCFormat

Private m_offset As Long ' offset in minutes
Public ShowOffset As Boolean

Private m_date As Date  ' This is stored as UTC date, not local date.

Public Property Let Format(rhs As UTCFormat)

   m_format = rhs

End Property

Public Property Get Format() As UTCFormat
   
   Format = m_format

End Property

Public Property Let HoursOffset(rhs As Long)

   If rhs > 23 Or rhs < -23 Then Err.Raise vbObjectError, "UTC", "Offset exceeds 23:59"

   m_offset = rhs * 60

End Property

Public Property Let MinutesOffset(rhs As Long)

   If rhs > ((23 * 60) + 59) Or rhs < ((-23 * 60) - 59) Then Err.Raise vbObjectError, "UTC", "Offset exceeds 23:59"

   m_offset = rhs

End Property

Private Property Get OffsetTime() As String

   OffsetTime = (VBA.Format$(Fix(Abs(m_offset) / 60), "00") & VBA.Format$(Abs(m_offset) Mod 60, ":00"))
   
End Property

Public Property Get localDate() As Date

Dim outdate As Date
Dim dateadjust As Date

   outdate = m_date

   dateadjust = OffsetTime

   If m_offset < 0 Then
      outdate = outdate - dateadjust
   ElseIf m_offset > 0 Then
      outdate = outdate + dateadjust
   End If

   localDate = outdate

End Property
Public Property Let localDate(rhs As Date)
   
Dim outdate As Date
Dim dateadjust As Date
   
   outdate = rhs

   dateadjust = OffsetTime

   If m_offset <> 0 Then
      If m_offset < 0 Then
         outdate = outdate + dateadjust
      Else
         outdate = outdate - dateadjust
      End If
   End If
   
   m_date = outdate
   
End Property

Public Sub fromString(rhs As String)
'  Description :  Convert a UTC string to a VB date
   localDate = Replace(Left$(rhs, 19), "T", " ")

End Sub

Public Function toString() As String
'  Description :  Convert a VB date to UTC in the desired format
Dim aFragment() As String
Dim strFormat As String
Const FRAGMENTS = "YYYY,-MM,-DD,Thh:mm,:ss,.0000,Z"

Dim Count As Long
Dim outdate As Date

Dim dateadjust As String

   aFragment = Split(FRAGMENTS, ",")

   Do
      If m_format And (2 ^ Count) Then
         strFormat = strFormat & aFragment(Count)
      End If
      Count = Count + 1
   Loop Until Count = 7
   
   dateadjust = OffsetTime
   
   If ShowOffset And m_offset <> 0 Then
      
      strFormat = Replace(strFormat, "Z", IIf(m_offset < 0, "-", "+") & dateadjust)
      
      outdate = localDate
   Else
      outdate = m_date
   End If
         
   toString = VBA.Format$(outdate, strFormat)
   
End Function


Private Sub Class_Initialize()

m_format = YYYY_MM_DDThh_mm_ssTZD
ShowOffset = True

' set the offset to (-ve) ActiveTimeBias, which is the locality offset INCLUDING daylight saving time (if enabled)
' this means that by default LOCALTIME gets it right.

m_offset = -GetRegistryValue(HKEY_LOCAL_MACHINE, _
                              "SYSTEM\CurrentControlSet\Control\TimeZoneInformation", _
                              "ActiveTimeBias")

End Sub


Private Function IsLeapYear(intYear As Integer) As Boolean
  ' Comments  : Determines if the specified year is a leap year without
  '             relying on the DateSerial method.
  ' Parameters: intYear - integer year
  '             Note: Always specify the full four digits of the year,
  '             or the code cannot be considered Year 2000 compliant.
  ' Returns   : True - year is a leap year, False otherwise
  '
  On Error GoTo PROC_ERR

  IsLeapYear = False

  If intYear Mod 4 = 0 Then
    If intYear Mod 100 = 0 Then
      If intYear Mod 400 = 0 Then
        IsLeapYear = True
      End If
    Else
      IsLeapYear = True
    End If
  End If

PROC_EXIT:
  Exit Function

PROC_ERR:
  MsgBox "Error: " & Err & ". " & Error$
  Resume PROC_EXIT

End Function

