Attribute VB_Name = "WDirectionIO"
'   WDIRECT
'   -------
'
'08Sep04 CKJ Moved direction structure & SQL procs to this module
'            Tidied error handling. Added LocationID_Site
'19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)

Option Explicit
DefInt A-Z

Type WDirection
   WDirectionID As Long
   Code As String * 12 'top half same as label file
   route As String * 4
''   EqualDose As Single
''   EqualInterval As Single
''   TimeUnits As String * 3
''   RepeatInterval As Integer
   RepeatUnits As String * 3
   CourseLength As Integer
   CourseUnits As String * 3
''   Abstime As String * 1
''   days As String * 1          '28Oct05 CKJ
   days(1 To 7) As Boolean       '   "     "  Block added  1Mon,2Tue,3Wed,4Thu,5Fri,6Sat,7Sun

   dose(1 To 6) As Single
   Times(1 To 6) As String * 4

   DeletedBy As String * 5  'bottom half directions only
   ApprovedBy As String * 5
''   RevisionNo As Integer
   deleted As Boolean
   location As String * 5 ' 4 19May10 XN Update to 5 (F0051906)  '20Jun95 CKJ was 5
''   sparebyte As String * 1  '   "        added
   'directs As String * 255
   directs As String * 500  '03Jul14 TH Extended to allow for huge directions now spanning 2 labels
   Prn As Boolean
   SortCode As String * 4
   DSS As Long                     '0=Not DSS, 1=DSS Visible, 2=DSS Invisible
   HidePrescriber As Boolean       'Y/N
   manualQtyEntry As Boolean        '09Aug99 SF added as a way of auto setting the manual qty entry flag
   StatDoseFlag As Boolean
''   padding As String * 41              '04Mar99 CFY Was 49 now 43, 09Aug99 SF was 43 now 42. 30Mar01 AE 42 to 41 and counting...
   SiteID As Long
End Type

Private Const OBJNAME As String = PROJECT & "WDirectionIO."

Sub BlankWDirection(WDir As WDirection)

Dim iLoop As Integer

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "BlankWDirection"

   On Error GoTo ErrorHandler
   With WDir
      .WDirectionID = 0
      .Code = ""
      .route = ""
''    .RepeatInterval = 0
      .RepeatUnits = ""
      .CourseLength = 0
      .CourseUnits = ""
''    .days = Chr$(0)               '28Oct05 CKJ
      For iLoop = 1 To 7            '   "
         .days(iLoop) = True
      Next
   
      For iLoop = 1 To 6
         .dose(iLoop) = 0
         .Times(iLoop) = ""
      Next
      .DeletedBy = ""
      .ApprovedBy = ""
      .deleted = False
      .location = ""
      .directs = ""
      .Prn = False                 '25May95 CKJ copied from DIRECTF ASC 28Apr95
      .SortCode = ""
      .DSS = 0                     '0=Not DSS, 1=DSS Visible, 2=DSS Invisible
      .HidePrescriber = False      'Y/N
      .manualQtyEntry = False      '09Aug99 SF added as a way of auto setting the manual qty entry flag
      .StatDoseFlag = False
      .SiteID = 0
   End With
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
End Sub

Function GetDirectionRSbyID(ByVal WDirectionID As Long) As ADODB.Recordset
'09May05 Just a plain read with no UI or business logic, returning an ADODB RS

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "GetDirectionRSbyID"

   On Error GoTo ErrorHandler
   
   strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("WDirectionID", trnDataTypeint, 4, WDirectionID)
   Set GetDirectionRSbyID = gTransport.ExecuteSelectSP(g_SessionID, "pWDirectionSelect", strParameters)
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
End Function

Function GetDirectionRSbyCriteria( _
                                   ByVal Code As String _
                                 , ByVal wardcode As String _
                                 , ByVal Language As Integer _
                                 , ByVal HidePrescriber As Boolean _
                                 , Optional ByVal HideDeleted As Variant = True _
                                 ) As ADODB.Recordset
'09May05
'INPUT
'  sessionid (implies site)
'  code        blank for all directions
'  wardcode    blank unless ward specific direction are needed
'  language    blank unless foreign language required (**NOT IMPLEMENTED**)
'  hideprescriber True to hide dispensary-only directions, False to see all
'  deleted     True(default) to hide deleted directions, False to see all
'
'OUTPUT ADORS containing any number of rows
'  WDirectionID
'  Code
'  Directs
'  Location

Dim strParameters As String
Dim WDir As WDirection

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "GetDirectionRSbyCriteria"

   On Error GoTo ErrorHandler
   
   'If Language = 0 Then Language = 44    '!!** worth adding?
     
   strParameters = _
      gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
      gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, Len(WDir.Code), Code) & _
      gTransport.CreateInputParameterXML("Location", trnDataTypeVarChar, Len(WDir.location), wardcode) & _
      gTransport.CreateInputParameterXML("Language", trnDataTypeint, 4, Language) & _
      gTransport.CreateInputParameterXML("HidePrescriber", trnDataTypeBit, 1, HidePrescriber) & _
      gTransport.CreateInputParameterXML("HideDeleted", trnDataTypeBit, 1, TrueFalse((HideDeleted)))
   
   Set GetDirectionRSbyCriteria = gTransport.ExecuteSelectSP(g_SessionID, "pWDirectionByCriteria", strParameters)
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
End Function


Function GetDirectionByPK(ByVal WDirectionID As Long, ByRef WDir As WDirection) As Boolean
'**93** Given the PK, fetch a label and fill the L structure
'       If the label is absent then return success = false and blank WDir
'       If the DB is unreachable then raise an error

Dim success As Boolean
Dim rs As ADODB.Recordset
Dim iLoop As Integer

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "GetDirectionByPK"

   On Error GoTo ErrorHandler
   success = False
   BlankWDirection WDir
   
   Set rs = GetDirectionRSbyID(WDirectionID)
   If Not rs Is Nothing Then     'use returned recordset
      If rs.State = adStateOpen Then
         If rs.RecordCount > 0 Then    'use returned recordset
            CastRecordsetToDirection rs, WDir
            success = True
         End If
      End If
   End If
   
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   
   GetDirectionByPK = success

   If lErrNo Then Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   Resume Cleanup
End Function


'Function GetDirectionRSbyWDirCode(ByVal WDirCode As String) As ADODB.Recordset
'09May05 Read directions matching a code, returning an ADODB RS
'
'Dim strParameters As String
'Dim WDir As WDirection
'
'Dim lErrNo        As Long
'Dim sErrDesc      As String
'Const ErrSource As String = "GetDirectionRSbyWDirCode"
'
'   On Error GoTo ErrorHandler
'
'   strParameters = gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, Len(WDir.Code), WDirCode)
'   Set GetDirectionRSbyWDirCode = gTransport.ExecuteSelectSP(g_SessionID, "pWDirectionSelectBy?????", strParameters)
'
'Exit Function
'
'ErrorHandler:
'   lErrNo = Err.Number
'   sErrDesc = Err.Description
'   'On Error Resume Next
'   On Error GoTo 0
'   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
'End Function


Function DeleteDirection(ByVal WDirectionID As Long) As Integer
'09May05

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "DeleteDirection"

   On Error GoTo ErrorHandler
   DeleteDirection = gTransport.ExecuteDeleteSP(g_SessionID, "WDirection", WDirectionID)
      
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
End Function


Sub CastRecordsetToDirection(ByRef rs As ADODB.Recordset, ByRef WDir As WDirection)
'09May05 Cast record to label struct

Dim iLoop As Integer
Dim days As Integer
Dim blnOneOrMoreDaysSet As Boolean
Dim daynames() As String
   
Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "CastRecordsetToDirection"

Const DayAbbrev = "1Mon,2Tue,3Wed,4Thu,5Fri,6Sat,7Sun"
   
   On Error GoTo ErrorHandler
   WDir.WDirectionID = rs!WDirectionID 'As Long PK
   
   WDir.Code = RtrimGetField(rs!Code) 'As String * 12 'top half same as label file
   WDir.route = RtrimGetField(rs!route) 'As String * 4
''   WDir.RepeatInterval = GetField(rs!RepeatInterval) 'As Integer
   WDir.RepeatUnits = RtrimGetField(rs!RepeatUnits) 'As String * 3
   WDir.CourseLength = GetField(rs!CourseLength) 'As Integer
   WDir.CourseUnits = RtrimGetField(rs!CourseUnits) 'As String * 3
   
'  WDir.Days = RtrimGetField(rs!Days) 'As String * 1
''   days = 0
''   If GetField(rs!Day1Mon) Then days = days + 1
''   If GetField(rs!Day2Tue) Then days = days + 2
''   If GetField(rs!Day3Wed) Then days = days + 4
''   If GetField(rs!Day4Thu) Then days = days + 8
''   If GetField(rs!Day5Fri) Then days = days + 16
''   If GetField(rs!Day6Sat) Then days = days + 32
''   If GetField(rs!Day7Sun) Then days = days + 64
''   WDir.days = Chr$(2 * days) 'ShiftL 1 bit
   
   daynames = Split(DayAbbrev, ",")
   blnOneOrMoreDaysSet = False
   For iLoop = 1 To 7
      WDir.days(iLoop) = GetField(rs.Fields("Day" & daynames(iLoop - 1)))
      If WDir.days(iLoop) Then blnOneOrMoreDaysSet = True
   Next
   If Not blnOneOrMoreDaysSet Then                                         'all set as false, which still means 'every day'
      For iLoop = 1 To 7
         WDir.days(iLoop) = True                                           'so set all days active
      Next
   End If

   
   For iLoop = 1 To 6
      WDir.dose(iLoop) = GetField(rs.Fields("dose" & Format$(iLoop))) ' As Single
      WDir.Times(iLoop) = RtrimGetField(rs.Fields("Times" & Format$(iLoop))) ' As String * 4
   Next

   WDir.DeletedBy = RtrimGetField(rs!DeletedBy) 'As String * 5  'bottom half directions only
   WDir.ApprovedBy = RtrimGetField(rs!ApprovedBy) 'As String * 5
   WDir.deleted = GetField(rs!deleted)
   WDir.location = RtrimGetField(rs!location) 'As String * 4   '20Jun95 CKJ was 5
   WDir.directs = RtrimGetField(rs!directs) 'As String * 255
   WDir.Prn = GetField(rs!Prn)
   WDir.SortCode = RtrimGetField(rs!SortCode) 'As String * 4
   WDir.DSS = GetField(rs!DSS)                    '0=Not DSS, 1=DSS Visible, 2=DSS Invisible
   WDir.HidePrescriber = GetField(rs!HidePrescriber)
   WDir.manualQtyEntry = GetField(rs!manualQtyEntry)
   WDir.StatDoseFlag = GetField(rs!StatDoseFlag)
   
   WDir.SiteID = rs!LocationID_Site 'As Long
   
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
End Sub

'Function DeleteStandard(ByVal PKStandardID As Long, ByVal StandardTableName As String) As Boolean
'09May05 Given the PK of a row and the name of its table, invoke p[table]Delete stored procedure
'
'Dim lErrNo        As Long
'Dim sErrDesc      As String
'Const ErrSource As String = "DeleteStandard"
'
'   On Error GoTo ErrorHandler
'   DeleteStandard = gTransport.ExecuteDeleteSP(g_SessionID, StandardTableName, PKStandardID)
'
'Exit Function
'
'ErrorHandler:
'   lErrNo = Err.Number
'   sErrDesc = Err.Description
'   'On Error Resume Next
'   On Error GoTo 0
'   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
'End Function


Function PutDirectionNL(ByRef WDir As WDirection) As Boolean
'**93** Given a filled WDirection structure write to the DB
'       If WDirectionID is > 0 then write to that PK else add a new direction
'
'         @CurrentSessionID int
'--    ,  @WDirectionID int               UPDATE only
'      ,  @LocationID_Site int
'      ,  @Code varchar(12)
'      ,  @Route varchar(4)
'      ,  @RepeatInterval int
'      ,  @RepeatUnits varchar(3)
'      ,  @CourseLength int
'      ,  @CourseUnits varchar(3)
'      ,  @Dose1 float
'      ,  @Dose2 float
'      ,  @Dose3 float
'      ,  @Dose4 float
'      ,  @Dose5 float
'      ,  @Dose6 float
'      ,  @Times1 varchar(4)
'      ,  @Times2 varchar(4)
'      ,  @Times3 varchar(4)
'      ,  @Times4 varchar(4)
'      ,  @Times5 varchar(4)
'      ,  @Times6 varchar(4)
'      ,  @DeletedBy varchar(5)
'      ,  @ApprovedBy varchar(5)
'      ,  @Deleted bit
'      ,  @Location varchar(4)
'      ,  @Directs varchar(255)
'      ,  @Prn bit
'      ,  @SortCode varchar(4)
'      ,  @Dss int
'      ,  @HidePrescriber bit
'      ,  @ManualQtyEntry bit
'      ,  @StatDoseFlag bit
'      ,  @Day1Mon bit
'      ,  @Day2Tue bit
'      ,  @Day3Wed bit
'      ,  @Day4Thu bit
'      ,  @Day5Fri bit
'      ,  @Day6Sat bit
'      ,  @Day7Sun bit
'--    ,  @LocationID_Site int OUTPUT     INSERT only

Dim success As Boolean
Dim strParam As String
Dim strTempParam1 As String
Dim strTempParam2 As String
Dim WDirectionID As Long
Dim dummy As Long
Dim DayFlags As Integer
Dim iLoop As Integer

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "PutDirectionNL"
   
   On Error GoTo ErrorHandler
      
   With WDir
      strParam = _
         gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
         gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, Len(.Code), Trim$(.Code)) & _
         gTransport.CreateInputParameterXML("route", trnDataTypeVarChar, Len(.route), Trim$(.route))
   ''      gTransport.CreateInputParameterXML("RepeatInterval", trnDataTypeint, 4, .RepeatInterval) &
      strParam = strParam & _
         gTransport.CreateInputParameterXML("RepeatUnits", trnDataTypeVarChar, Len(.RepeatUnits), Trim$(.RepeatUnits)) & _
         gTransport.CreateInputParameterXML("CourseLength", trnDataTypeint, 4, .CourseLength) & _
         gTransport.CreateInputParameterXML("CourseUnits", trnDataTypeChar, Len(.CourseUnits), Trim$(.CourseUnits))
            
''      strParam = strParam & _        '28Oct05 CKJ
''         gTransport.CreateInputParameterXML("dose1", trnDataTypeFloat, 8, .dose(1)) & _
''         gTransport.CreateInputParameterXML("dose2", trnDataTypeFloat, 8, .dose(2)) & _
''         gTransport.CreateInputParameterXML("dose3", trnDataTypeFloat, 8, .dose(3)) & _
''         gTransport.CreateInputParameterXML("dose4", trnDataTypeFloat, 8, .dose(4)) & _
''         gTransport.CreateInputParameterXML("dose5", trnDataTypeFloat, 8, .dose(5)) & _
''         gTransport.CreateInputParameterXML("dose6", trnDataTypeFloat, 8, .dose(6)) & _
''         gTransport.CreateInputParameterXML("Times1", trnDataTypeVarChar, Len(.Times(1)), Trim$(.Times(1))) & _
''         gTransport.CreateInputParameterXML("Times2", trnDataTypeVarChar, Len(.Times(2)), Trim$(.Times(2))) & _
''         gTransport.CreateInputParameterXML("Times3", trnDataTypeVarChar, Len(.Times(3)), Trim$(.Times(3))) & _
''         gTransport.CreateInputParameterXML("Times4", trnDataTypeVarChar, Len(.Times(4)), Trim$(.Times(4))) & _
''         gTransport.CreateInputParameterXML("Times5", trnDataTypeVarChar, Len(.Times(5)), Trim$(.Times(5))) & _
''         gTransport.CreateInputParameterXML("Times6", trnDataTypeVarChar, Len(.Times(6)), Trim$(.Times(6)))
   
      strTempParam1 = ""      '28Oct05 CKJ
      strTempParam2 = ""
      For iLoop = 1 To 6
         strTempParam1 = strTempParam1 & gTransport.CreateInputParameterXML("dose" & Format$(iLoop), trnDataTypeFloat, 8, .dose(iLoop))
         strTempParam2 = strTempParam2 & gTransport.CreateInputParameterXML("Times" & Format$(iLoop), trnDataTypeVarChar, Len(.Times(iLoop)), Trim$(.Times(iLoop)))
      Next
      
      strParam = strParam & strTempParam1 & strTempParam2 & _
         gTransport.CreateInputParameterXML("DeletedBy", trnDataTypeVarChar, Len(.DeletedBy), Trim$(.DeletedBy)) & _
         gTransport.CreateInputParameterXML("ApprovedBy", trnDataTypeVarChar, Len(.ApprovedBy), Trim$(.ApprovedBy)) & _
         gTransport.CreateInputParameterXML("Deleted", trnDataTypeBit, 1, .deleted) & _
         gTransport.CreateInputParameterXML("Location", trnDataTypeVarChar, Len(.location), Trim$(.location)) & _
         gTransport.CreateInputParameterXML("Directs", trnDataTypeVarChar, Len(.directs), Trim$(.directs)) & _
         gTransport.CreateInputParameterXML("PRN", trnDataTypeBit, 1, .Prn) & _
         gTransport.CreateInputParameterXML("SortCode", trnDataTypeVarChar, Len(.SortCode), Trim$(.SortCode)) & _
         gTransport.CreateInputParameterXML("DSS", trnDataTypeint, 4, .DSS) & _
         gTransport.CreateInputParameterXML("HidePrescriber", trnDataTypeBit, 1, .HidePrescriber) & _
         gTransport.CreateInputParameterXML("ManualQtyEntry", trnDataTypeBit, 1, .manualQtyEntry) & _
         gTransport.CreateInputParameterXML("StatDoseFlag", trnDataTypeBit, 1, .StatDoseFlag)
   
   ''   '                        SSFTWTM-    '28Oct05 CKJ replaced bit-wise logic
   ''   ' BW  twice a week  18   ...x..x0
   ''   ' MWF Mon Wed Fri   42   ..x.x.x0
   ''   ' OW  Mon            2   ......x0
   ''   DayFlags = Asc(.days) \ 2         'bit shift SSFTWTM- to 0SSFTWTM
   ''
   ''   strParam = strParam & _
   ''      gTransport.CreateInputParameterXML("day1Mon", trnDataTypeBit, 1, DayFlags And 1) & _
   ''      gTransport.CreateInputParameterXML("day2Tue", trnDataTypeBit, 1, DayFlags And 2) & _
   ''      gTransport.CreateInputParameterXML("day3Wed", trnDataTypeBit, 1, DayFlags And 4) & _
   ''      gTransport.CreateInputParameterXML("day4Thu", trnDataTypeBit, 1, DayFlags And 8) & _
   ''      gTransport.CreateInputParameterXML("day5Fri", trnDataTypeBit, 1, DayFlags And 16) & _
   ''      gTransport.CreateInputParameterXML("day6Sat", trnDataTypeBit, 1, DayFlags And 32) & _
   ''      gTransport.CreateInputParameterXML("day7Sun", trnDataTypeBit, 1, DayFlags And 64)
   
      strTempParam1 = ""                     '28Oct05 CKJ replaced bit-wise logic
      For iLoop = 1 To 7
         strTempParam1 = strTempParam1 & gTransport.CreateInputParameterXML("day" & Format$(iLoop), trnDataTypeBit, 1, .days(iLoop))
      Next
      strParam = strParam & strTempParam1
   End With
      
   If WDir.WDirectionID Then
      strParam = strParam & gTransport.CreateInputParameterXML("WDirectionID", trnDataTypeint, 4, WDir.WDirectionID)
      dummy = gTransport.ExecuteUpdateSP(g_SessionID, "WDirection", strParam)
      success = True    'if no error
   Else
      WDirectionID = gTransport.ExecuteInsertSP(g_SessionID, "WDirection", strParam)
      success = (WDirectionID <> 0)
      WDir.WDirectionID = WDirectionID
   End If
   
   PutDirectionNL = success

Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
End Function

