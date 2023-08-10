Attribute VB_Name = "WLabelIO"
' WLABEL
'
'V93 Module created to bring together all code which moves patient labels to SQL
'
'29Aug10 TH LastDispenseDateCheck: Ensure prompt is retained correctly after msg displayed (F0095199)
'15Feb13 XN WLabel: Replaced WLabel.LastDate with WLabel.lastSavedDateTime (40210)
'           Putlabel: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'           PutLabelNL: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'           CastRecordsetToLabel: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'           BlankWLabel: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'           LastSavedDateTimeToLastDate: Added method to convert new WLabel.lastSavedDateTime to old WLabel.LastDate string (40210)


Option Explicit
DefInt A-Z

Public Type WLabel
   RequestID As Long        '23aug04 CKJ Added the identity column
   SiteID As Long          '            and site FK
   IsHistory As Boolean    '            and history flag
   
   dircode As String * 255 'top half same as label file    09May05 was * 12
   route As String * 4
''   EqualInterval As Single
''   TimeUnits As String * 3
''   RepeatInterval As Integer
   RepeatUnits As String * 3
''   Abstime As String * 1 'no longer used
''   days As String * 1
   BasePrescriptionID As Long    ' 05Mar02 ATW Populated on new prescriptions and maintained throughout all
                                 '              amendments of that 'scrip - allowing easier tracing of history and easier interfaces
   dose(1 To 6) As Single
   Times(1 To 6) As String * 4
''   flags As String * 1  '23Nov94 ASC Added for manual flag
   '     flags:   Bit  Value  Usage
   '               7    128   Rx Notes          '11Jun99 CFY Added
   '               6     64   Change of Warnings/directions on label
   '               5     32   Blister bit 3     '20Jan98 CFY
   '               4     16   Blister bit 2     '   "
   '               3      8   Blister bit 1     '   "
   '               2      4   PatOwn            '12Nov97 CFY
   '               1      2   PRN
   '               0      1   Manual
   PrescriptionID As Long ' ASC/CKJ 30sep96 added for internal prescription number
   
   ReconVol As Single        '<-----CIVAS
   Container As String * 1
   ReconAbbr As String * 3
   DiluentAbbr As String * 3
   finalvolume As Single
   
   drdirection As String * 255          '09May05 was  105
   containersize As Integer
   InfusionTime As Integer   '<-----TO HERE   ASC 03Sep94
                             
   patid As String * 10
   SisCode As String * 7
   'text As String * 255         '09May05 was 180
   text As String * 550   '13May14 TH Extended for extra label ()
   startdate As Long
   StopDate As Long
   IssType As String * 1
   lastqty As Single

   lastSavedDateTime As Date ' lastdate As String * 8  40210 XN 15Feb13 use proper date\time for WLabel       lastdate As String * 8        '09May05 ddmmccyy ONLY
   topupqty As Single

   dispid As String * 3
   PrescriberID As String * 3 '15Nov95 now used
   PharmacistID As String * 3 '26Nov95 now used
   StoppedBy As String * 3    '26Nov95 now used

   needednexttime As String * 1    '<--NOT used yet for use with PRN flag
   RxStartDate As Long '06Mar93 ASC
   Nodissued As Single
   batchnumber As Integer        '26Nov95 ASC
''   extraFlags As String * 1      '17Jan00 SF added
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
   RxNodIssued As Single  '06Mar93 ASC
      
   days(1 To 7) As Boolean       '09May05 Block added  1Mon,2Tue,3Wed,4Thu,5Fri,6Sat,7Sun
   HasRxNotes As Boolean
   PatientsOwn As Boolean
   Prn As Boolean
   ManualQuantity As Boolean
   rINNflag As Boolean
   PyxisItem As Boolean
   Blister As Integer
   RevisedInstruction As String * 12
   RevisedWarning As String * 12
   wardcode As String * 5           '27Oct05 CKJ added
   ConsCode As String * 4           '   "
   SplitDose As Boolean    '03Aug2011 TH (asymetric dosing)
   PSO As Boolean    '06Aug2011 TH (Patient Specific Ordering)
   ExtraLabel As Boolean
End Type

Private Const OBJNAME As String = PROJECT & "WLabelIO."


Function GetLabelRSbyID(ByVal RequestID As Long) As ADODB.Recordset
'09May05 Just a plain read with no UI or business logic, returning an ADODB RS

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler

   strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gPatientSite) & _
                  gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID)
   Set GetLabelRSbyID = gTransport.ExecuteSelectSP(g_SessionID, "pWlabelSelect", strParameters)
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "GetLabelRSbyID", sErrDesc
End Function

Function GetLabelRSbyPatient(ByVal PatRecNo As String) As ADODB.Recordset
'09May05 Read labels for a patient, returning an ADODB RS

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler
   
   strParameters = gTransport.CreateInputParameterXML("PatRecno", trnDataTypeVarChar, 10, PatRecNo)
   Set GetLabelRSbyPatient = gTransport.ExecuteSelectSP(g_SessionID, "pWlabelSelectByPatRecno", strParameters)
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "GetLabelRSbyPatient", sErrDesc
End Function

Function GetLabelNL(ByVal LabelID As Long, ByRef L As WLabel) As Boolean
'**93** Given the PK, fetch a label and fill the L structure
'       If the label is absent then return success = false
'       If the DB is unreachable then raise an error

Dim success As Boolean
Dim rs As ADODB.Recordset
Dim iLoop As Integer

Dim ErrNumber As Long
Dim ErrDescription As String
Const ErrSource As String = "GetLabelNL"

   On Error GoTo ErrorHandler
   clearlabel L
   Set rs = GetLabelRSbyID(LabelID)

   If Not rs Is Nothing Then     'use returned recordset
      If rs.State = adStateOpen Then
         If rs.RecordCount <> 0 Then
            CastRecordsetToLabel rs, L
         End If
      End If
   End If
   
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function

Sub Putlabel(ByRef L As WLabel)
'!!** would like to store expiry as long integer in the future
'03Mar03 TH  Added check for PBS - dont always record the lastissued date at this point for a PBS Billing item.
'15Feb13 XN  Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)

Dim dummy As Long

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler

''   If LabelForArchive& > 0 Then
''      archivelabel LabelForArchive&
''      LabelForArchive& = 0
''   End If

''   If deletetohistory And L.StopDate = 0 Then
''      GetToday L.StopDate
''   End If

   If Trim$(L.patid) = "" Then L.patid = pid.recno
   'MSGBOX "PUT l.patid=" + l.patid + "  pid.recno =" + pid.recno
   
   If L.patid <> pid.recno Then
      MsgBox "PUTlabel l.patid=" + L.patid + "  pid.recno =" + pid.recno
      WriteLog patdatapath$ & "\lblpidno.log", 0, UserID$, "PUTlabel l.patid=" & L.patid & "  pid.recno =" & pid.recno '19Dec96 EAC ascrootpath$ changed to patdatapath$
   End If
   
''   If Not deletetohistory Then  'ASC 23Jan93
   If Not PBSKeepDate() Then            '03Mar03 TH (PBSv4) added         '!!** Not ideal here - this assumes a particular way of working
      L.lastSavedDateTime = Now         '40210 XN 15Feb13 use proper date\time for WLabel                 L.lastdate = thedate(False, True) '09May05 ddmmyyyy
   End If                               '03Mar03 TH (PBSv4) added
''   End If

   L.SplitDose = g_blnSplitDose  '03Aug11 TH Added for asymmetric dosing
   
   L.PSO = g_blnPSO  '07Aug12 TH Added for Patient Specific Ordering
   
   dummy = PutLabelNL(L)

Cleanup:

Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   popmessagecr "." & OBJNAME & "PutLabel", "Error " & lErrNo & cr & sErrDesc
   
   'Error -2147217871
   'timeout expired
End Sub

Function PutLabelNL(ByRef L As WLabel) As Boolean
'**93** Given a filled WLabel structure write to the DB
'       If RequestID is > 0 then write to that PK else add a new label
'15Feb13 XN  Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)

Dim success As Boolean

Dim strParam As String
Dim RequestID As Long
Dim dummy As Long
Dim iLoop As Integer
Dim strText As String
Dim intResult As Integer
   
Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "PutLabelNL"

   On Error GoTo ErrorHandler
      
   strText = RTrim$(L.text)
''Debug.Print InStr(strText, Chr$(10))
''Debug.Print InStr(strText, Chr$(13))
   
   replace strText, Chr$(LBL_END_LINE), crlf, 0
   replace strText, Chr$(LBL_END_DESC), "<->", 0     '  <>  <->  <_>   <+>   <=>   <~>  <:>  <'>  <|>  <¦>  <*>  <!>  <^>  </>
   '09Mar07 TH Replaced this line for SiteID/gDispSite
   'gTransport.CreateInputParameterXML("SiteIDpatient", trnDataTypeint, 1, gPatientSite)
   strParam = _
      gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 1, gDispSite) & _
      gTransport.CreateInputParameterXML("dircode", trnDataTypeVarChar, Len(L.dircode), Trim$(L.dircode)) & _
      gTransport.CreateInputParameterXML("route", trnDataTypeVarChar, Len(L.route), L.route)
''      gTransport.CreateInputParameterXML("RepeatInterval", trnDataTypeint, 4, L.RepeatInterval) &
   strParam = strParam & _
      gTransport.CreateInputParameterXML("RepeatUnits", trnDataTypeVarChar, Len(L.RepeatUnits), L.RepeatUnits) & _
      gTransport.CreateInputParameterXML("BasePrescriptionID", trnDataTypeint, 4, L.BasePrescriptionID) & _
      gTransport.CreateInputParameterXML("dose1", trnDataTypeFloat, 8, L.dose(1)) & _
      gTransport.CreateInputParameterXML("dose2", trnDataTypeFloat, 8, L.dose(2)) & _
      gTransport.CreateInputParameterXML("dose3", trnDataTypeFloat, 8, L.dose(3)) & _
      gTransport.CreateInputParameterXML("dose4", trnDataTypeFloat, 8, L.dose(4)) & _
      gTransport.CreateInputParameterXML("dose5", trnDataTypeFloat, 8, L.dose(5)) & _
      gTransport.CreateInputParameterXML("dose6", trnDataTypeFloat, 8, L.dose(6)) & _
      gTransport.CreateInputParameterXML("Times1", trnDataTypeVarChar, Len(L.Times(1)), L.Times(1)) & _
      gTransport.CreateInputParameterXML("Times2", trnDataTypeVarChar, Len(L.Times(2)), L.Times(2)) & _
      gTransport.CreateInputParameterXML("Times3", trnDataTypeVarChar, Len(L.Times(3)), L.Times(3)) & _
      gTransport.CreateInputParameterXML("Times4", trnDataTypeVarChar, Len(L.Times(4)), L.Times(4)) & _
      gTransport.CreateInputParameterXML("Times5", trnDataTypeVarChar, Len(L.Times(5)), L.Times(5)) & _
      gTransport.CreateInputParameterXML("Times6", trnDataTypeVarChar, Len(L.Times(6)), L.Times(6)) & _
      gTransport.CreateInputParameterXML("prescriptionid", trnDataTypeint, 4, L.PrescriptionID)
   strParam = strParam & _
      gTransport.CreateInputParameterXML("ReconVol", trnDataTypeFloat, 8, L.ReconVol) & _
      gTransport.CreateInputParameterXML("Container", trnDataTypeChar, 1, L.Container) & _
      gTransport.CreateInputParameterXML("ReconAbbr", trnDataTypeVarChar, Len(L.ReconAbbr), L.ReconAbbr) & _
      gTransport.CreateInputParameterXML("DiluentAbbr", trnDataTypeVarChar, Len(L.DiluentAbbr), L.DiluentAbbr) & _
      gTransport.CreateInputParameterXML("finalvolume", trnDataTypeFloat, 8, L.finalvolume) & _
      gTransport.CreateInputParameterXML("drdirection", trnDataTypeVarChar, Len(L.drdirection), RTrim$(L.drdirection)) & _
      gTransport.CreateInputParameterXML("containersize", trnDataTypeint, 4, L.containersize) & _
      gTransport.CreateInputParameterXML("InfusionTime", trnDataTypeint, 4, L.InfusionTime) & _
      gTransport.CreateInputParameterXML("patid", trnDataTypeVarChar, Len(L.patid), L.patid) & _
      gTransport.CreateInputParameterXML("SisCode", trnDataTypeVarChar, Len(L.SisCode), L.SisCode) & _
      gTransport.CreateInputParameterXML("Text", trnDataTypeVarChar, Len(L.text), strText) & _
      gTransport.CreateInputParameterXML("startdate", trnDataTypeint, 4, L.startdate) & _
      gTransport.CreateInputParameterXML("StopDate", trnDataTypeint, 4, L.StopDate) & _
      gTransport.CreateInputParameterXML("IssType", trnDataTypeChar, 1, L.IssType) & _
      gTransport.CreateInputParameterXML("lastqty", trnDataTypeFloat, 8, L.lastqty) & _
      gTransport.CreateInputParameterXML("lastdate", trnDataTypeVarChar, 8, LastSavedDateTimeToLastDate(L.lastSavedDateTime)) & _
      gTransport.CreateInputParameterXML("LastSavedDateTime", trnDataTypeDateTime, 8, L.lastSavedDateTime) & _
      gTransport.CreateInputParameterXML("topupqty", trnDataTypeFloat, 8, L.topupqty)
   strParam = strParam & _
      gTransport.CreateInputParameterXML("dispid", trnDataTypeVarChar, Len(L.dispid), L.dispid) & _
      gTransport.CreateInputParameterXML("prescriberid", trnDataTypeVarChar, Len(L.PrescriberID), L.PrescriberID) & _
      gTransport.CreateInputParameterXML("PharmacistID", trnDataTypeVarChar, Len(L.PharmacistID), L.PharmacistID) & _
      gTransport.CreateInputParameterXML("StoppedBy", trnDataTypeVarChar, Len(L.StoppedBy), L.StoppedBy) & _
      gTransport.CreateInputParameterXML("needednexttime", trnDataTypeChar, 1, L.needednexttime) & _
      gTransport.CreateInputParameterXML("RxStartDate", trnDataTypeint, 4, L.RxStartDate) & _
      gTransport.CreateInputParameterXML("Nodissued", trnDataTypeFloat, 8, L.Nodissued) & _
      gTransport.CreateInputParameterXML("batchnumber", trnDataTypeint, 4, L.batchnumber) & _
      gTransport.CreateInputParameterXML("deletedate", trnDataTypeint, 4, L.deletedate) & _
      gTransport.CreateInputParameterXML("RxNodIssued", trnDataTypeFloat, 8, L.RxNodIssued) & _
      gTransport.CreateInputParameterXML("IsHistory", trnDataTypeBit, 1, L.IsHistory)

   For iLoop = 1 To 7      '1Mon,2Tue,3Wed,4Thu,5Fri,6Sat,7Sun
      strParam = strParam & gTransport.CreateInputParameterXML("Day" & Format$(iLoop), trnDataTypeBit, 1, L.days(iLoop))
   Next
   
   '06Aug12 TH Added PSO
   strParam = strParam & gTransport.CreateInputParameterXML("HasRxNotes", trnDataTypeBit, 1, L.HasRxNotes) & _
      gTransport.CreateInputParameterXML("PatientsOwn", trnDataTypeBit, 1, L.PatientsOwn) & _
      gTransport.CreateInputParameterXML("PRN", trnDataTypeBit, 1, L.Prn) & _
      gTransport.CreateInputParameterXML("ManualQuantity", trnDataTypeBit, 1, L.ManualQuantity) & _
      gTransport.CreateInputParameterXML("rINNflag", trnDataTypeBit, 1, L.rINNflag) & _
      gTransport.CreateInputParameterXML("PyxisItem", trnDataTypeBit, 1, L.PyxisItem) & _
      gTransport.CreateInputParameterXML("Blister", trnDataTypeint, 4, L.Blister) & _
      gTransport.CreateInputParameterXML("RevisedInstruction", trnDataTypeVarChar, Len(L.RevisedInstruction), L.RevisedInstruction) & _
      gTransport.CreateInputParameterXML("RevisedWarning", trnDataTypeVarChar, Len(L.RevisedWarning), L.RevisedWarning) & _
      gTransport.CreateInputParameterXML("WardCode", trnDataTypeChar, Len(L.wardcode), L.wardcode) & _
      gTransport.CreateInputParameterXML("ConsCode", trnDataTypeChar, Len(L.ConsCode), L.ConsCode) & _
      gTransport.CreateInputParameterXML("SplitDose", trnDataTypeBit, 1, L.SplitDose) & _
      gTransport.CreateInputParameterXML("PSO", trnDataTypeBit, 1, L.PSO) & _
      gTransport.CreateInputParameterXML("ExtraLabel", trnDataTypeBit, 1, L.ExtraLabel)


   ''      L.EqualInterval = GetField(rs!EqualInterval)    ' As Single
   ''      L.TimeUnits = RtrimGetField(rs!TimeUnits) 'As String * 3
   ''      L.Abstime As String * 1 'no longer used
   ''      L.prn = RtrimGetField(rs!prn)    'As String * 1         '<-----NOT USED
   ''      L.rxstatus = RtrimGetField(rs!rxstatus)    'As String * 1    'could be used with above
   ''      L.padding2 As String * 1        '17Jan00 SF
'debug.print instr(strparam,chr$(30))
   
'Debug.Print InStr(strParam, Chr$(10))
'Debug.Print InStr(strParam, Chr$(13))
'Debug.Print InStr(strParam, Chr$(30))
'   replace strParam, Chr$(30), vbCr, 0
'   replace strParam, Chr$(31), vbCr, 0

   If L.RequestID Then
      strParam = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, L.RequestID) & strParam
      dummy = gTransport.ExecuteUpdateSP(g_SessionID, "Wlabel", strParam)
      success = True    'if no error
   Else
      strParam = strParam & gTransport.CreateInputParameterXML("RequestID_Prescription", trnDataTypeint, 4, gRequestID_Prescription)
      RequestID = gTransport.ExecuteInsertSP(g_SessionID, "Wlabel", strParam)
      success = (RequestID <> 0)
      L.RequestID = RequestID
   End If
   
   PutLabelNL = success

Exit Function

ErrorHandler:
'   Debug.Print Err.Number, Err.Description
'   popmessagecr ".", "Can not write to database due to error " & Format$(Err.Number) & cr & Err.Description
      
   If Err.Number = -2147217871 Then    'timeout expired
      If MessageBox(cr & "Timed out - OK to retry?" & cr, MB_OKCANCEL + MB_DEFBUTTON1 + MB_ICONEXCLAMATION, OBJNAME & ErrSource) = MB_OK Then
         Resume
      End If
   End If
   
   lErrNo = Err.Number
   sErrDesc = Err.Description
   On Error Resume Next
   PutLabelNL = False
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
End Function

Function DeleteLabel(ByVal RequestID As Long) As Integer
'09May05

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler
   DeleteLabel = gTransport.ExecuteDeleteSP(g_SessionID, "Wlabel", RequestID)
      
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "DeleteLabel", sErrDesc
End Function

Sub CastRecordsetToLabel(ByRef rs As ADODB.Recordset, ByRef L As WLabel)
'09May05 Cast record to label struct
'15Feb13 XN  Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)

Const DayAbbrev = "1Mon,2Tue,3Wed,4Thu,5Fri,6Sat,7Sun"

Dim iLoop As Integer
Dim daynames() As String
Dim strText As String
Dim blnOneOrMoreDaysSet As Boolean

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "CastRecordsetToLabel"

   On Error GoTo ErrorHandler

   L.RequestID = rs!RequestID    'PK
   L.IsHistory = rs!IsHistory    'also not null
   
   L.dircode = RtrimGetField(rs!dircode)  'As String * 12 'top half same as label file
   L.route = RtrimGetField(rs!route)  'As String * 4
''      L.EqualInterval = GetField(rs!EqualInterval)    ' As Single
''      L.TimeUnits = RtrimGetField(rs!TimeUnits) 'As String * 3
''   L.RepeatInterval = GetField(rs!RepeatInterval)   ' As Integer
   L.RepeatUnits = RtrimGetField(rs!RepeatUnits) 'As String * 3
''      L.Abstime As String * 1 'no longer used
''   L.Days = RtrimGetField(rs!Days) ' As String * 1
   L.BasePrescriptionID = GetField(rs!BasePrescriptionID)   ' As Long    ' 05Mar02 ATW Trimmed off useless Dose(0) array element to make room for this.
                                 '              Populated on new prescriptions and maintained throughout all
                                 '              amendments of that 'scrip - allowing easier tracing of history and easier interfaces
   For iLoop = 1 To 6
      L.dose(iLoop) = GetField(rs.Fields("dose" & Format$(iLoop))) ' As Single
      L.Times(iLoop) = RtrimGetField(rs.Fields("Times" & Format$(iLoop))) ' As String * 4
   Next
''   L.flags = GetField(rs!flags)  ' As String * 1  '23Nov94 ASC Added for manual flag
''   '     flags:   Bit  Value  Usage
''   '               7    128   Rx Notes          '11Jun99 CFY Added
''   '               6     64   Change of Warnings/directions on label
''   '               5     32   Blister bit 3     '20Jan98 CFY
''   '               4     16   Blister bit 2     '   "
''   '               3      8   Blister bit 1     '   "
''   '               2      4   PatOwn            '12Nov97 CFY
''   '               1      2   PRN
''   '               0      1   Manual
   L.PrescriptionID = GetField(rs!PrescriptionID)   ' As Long ' ASC/CKJ 30sep96 added for internal prescription number
   L.ReconVol = GetField(rs!ReconVol)   ' As Single        '<-----CIVAS

   L.Container = RtrimGetField(rs!Container) 'As String * 1
   L.ReconAbbr = RtrimGetField(rs!ReconAbbr) 'As String * 3
   L.DiluentAbbr = RtrimGetField(rs!DiluentAbbr)   ' As String * 3
   L.finalvolume = RtrimGetField(rs!finalvolume)   ' As Single
   L.drdirection = RtrimGetField(rs!drdirection)    'As String * 105
   L.containersize = GetField(rs!containersize)   ' As Integer
   L.InfusionTime = GetField(rs!InfusionTime)   ' As Integer   '<-----TO HERE   ASC 03Sep94

''      L.prn = RtrimGetField(rs!prn)    'As String * 1         '<-----NOT USED
   L.patid = RtrimGetField(rs!patid)    'As String * 10
   L.SisCode = RtrimGetField(rs!SisCode)    'As String * 7
   strText = RtrimGetField(rs!text)    'As String * 180
   replace strText, crlf, Chr$(LBL_END_LINE), 0
   replace strText, "<->", Chr$(LBL_END_DESC), 0     '  <>  <->  <_>   <+>   <=>   <~>  <:>  <'>  <|>  <¦>  <*>  <!>  <^>  </>
   L.text = strText
   
   L.startdate = GetField(rs!startdate)   ' As Long
   L.StopDate = GetField(rs!StopDate)   ' As Long
   L.IssType = RtrimGetField(rs!IssType)    'As String * 1
   L.lastqty = GetField(rs!lastqty)   ' As Single

   L.lastSavedDateTime = GetField(rs!lastSavedDateTime)  ' 40210 XN 15Feb13 use proper date\time for WLabel     L.lastdate = GetField(rs!lastdate)   ' As String * 8
   L.topupqty = GetField(rs!topupqty)   ' As Single

   L.dispid = RtrimGetField(rs!dispid)   ' As String * 3
   L.PrescriberID = RtrimGetField(rs!PrescriberID)    'As String * 3 '15Nov95 now used
   L.PharmacistID = RtrimGetField(rs!PharmacistID)    'As String * 3 '26Nov95 now used
   L.StoppedBy = RtrimGetField(rs!StoppedBy)    'As String * 3    '26Nov95 now used

''      L.rxstatus = RtrimGetField(rs!rxstatus)    'As String * 1    'could be used with above
   L.needednexttime = RtrimGetField(rs!needednexttime)   'As String * 1    '<--NOT used yet for use with PRN flag
   L.RxStartDate = GetField(rs!RxStartDate)   ' As Long '06Mar93 ASC
   L.Nodissued = GetField(rs!Nodissued)   ' As Single
   L.batchnumber = GetField(rs!batchnumber)   ' As Integer        '26Nov95 ASC
''      L.padding2 As String * 1        '17Jan00 SF
''   L.extraFlags = GetField(rs!extraFlags)  ' As String * 1      '17Jan00 SF added
''   '              Bit  Value  Usage
''   '               7    128   unused
''   '               6     64     "
''   '               5     32     "
''   '               4     16     "
''   '               3      8     "
''   '               2      4     "
''   '               1      2   06Mar00 SF specifies whether a Pyxis supplied item
''   '               0      1   flag to specify if warning should be given as label should change to new INN description

   L.deletedate = GetField(rs!deletedate)   ' As Long
   L.RxNodIssued = GetField(rs!RxNodIssued)   ' As Single  '06Mar93 ASC

   daynames = Split(DayAbbrev, ",")
   blnOneOrMoreDaysSet = False
   For iLoop = 1 To 7
      L.days(iLoop) = GetField(rs.Fields("Day" & daynames(iLoop - 1)))
      If L.days(iLoop) Then blnOneOrMoreDaysSet = True                     '28Oct05 CKJ set to True
   Next
   If Not blnOneOrMoreDaysSet Then                                         'all set as false, which still means 'every day'
      For iLoop = 1 To 7
         L.days(iLoop) = True                                              'so set all days active
      Next
   End If
   
   L.HasRxNotes = GetField(rs!HasRxNotes)
   L.PatientsOwn = GetField(rs!PatientsOwn)
   L.Prn = GetField(rs!Prn)
   L.ManualQuantity = GetField(rs!ManualQuantity)
   L.rINNflag = GetField(rs!rINNflag)
   L.PyxisItem = GetField(rs!PyxisItem)
   L.Blister = GetField(rs!Blister)
   
   L.RevisedInstruction = RtrimGetField(rs!RevisedInstruction)
   L.RevisedWarning = RtrimGetField(rs!RevisedWarning)
   L.wardcode = RtrimGetField(rs!wardcode)
   L.ConsCode = RtrimGetField(rs!ConsCode)
   L.SiteID = GetField(rs!SiteID) '17Mar07 TH Added for reDispensing check (SC-07-0197)
   L.SplitDose = GetField(rs!SplitDose) '03Aug11 TH Added
   L.PSO = GetField(rs!PSO) '06Aug12 TH Added
   L.ExtraLabel = GetField(rs!ExtraLabel) '06Aug12 TH Added
   g_blnSplitDose = L.SplitDose '03Aug11 TH Added
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
End Sub

Sub BlankWLabel(L As WLabel)
'15Feb13 XN  Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)

Dim iLoop As Integer
Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "BlankWLabel"

   On Error GoTo ErrorHandler
   
   L.RequestID = 0
   L.SiteID = 0
   L.IsHistory = False
   
   L.dircode = ""
   L.route = ""
''   L.RepeatInterval = 0
   L.RepeatUnits = ""
   L.BasePrescriptionID = 0
   For iLoop = 1 To 6
      L.dose(iLoop) = 0
      L.Times(iLoop) = ""
   Next
   L.PrescriptionID = 0
   L.ReconVol = 0
   
   L.Container = ""
   L.ReconAbbr = ""
   L.DiluentAbbr = ""
   L.finalvolume = 0
   L.drdirection = ""
   L.containersize = 0
   L.InfusionTime = 0
   L.patid = ""
   L.SisCode = ""
   L.text = ""
   L.startdate = 0
   L.StopDate = 0
   L.IssType = ""
   L.lastqty = 0

   L.lastSavedDateTime = Empty    ' 40210 XN 15Feb13 use proper date\time for WLabel       L.lastdate =""
   L.topupqty = 0

   L.dispid = ""
   L.PrescriberID = ""
   L.PharmacistID = ""
   L.StoppedBy = ""
   L.needednexttime = ""
   L.RxStartDate = 0
   L.Nodissued = 0
   L.batchnumber = 0
   L.deletedate = 0
   L.RxNodIssued = 0
      
   For iLoop = 1 To 7
      L.days(iLoop) = True          '28Oct05 CKJ was False, which still meant 'every day'
   Next

   L.HasRxNotes = False
   L.PatientsOwn = False
   L.Prn = False
   L.ManualQuantity = False
   L.rINNflag = False
   L.PyxisItem = False
   L.Blister = 0
   
   L.RevisedInstruction = ""
   L.RevisedWarning = ""
   L.wardcode = ""
   L.ConsCode = ""
   L.SplitDose = 0
   L.ExtraLabel = 0
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
End Sub
Sub LastDispenseDateCheck(ByVal RequestID_Prescription As Long)
'26May09 TH Written (F0041486)
'Here we will check to see if we have a previous label and if so when it was dispensed
'07Mar10 TH Changed logic to properly fit the spec.
'29Aug10 TH Ensure prompt is retained correctly after msg displayed (F0095199)

Dim strParam As String
Dim intCount As Integer
Dim strMessage As String

   'If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "Y", "DisableDispensedTodayMessage", 0)) Then
   If Not TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "DisableDispensedTodayMessage", 0)) Then '07Mar10 TH Changed logic to properly fit the spec
      'run the check
      strParam = gTransport.CreateInputParameterXML("PrescriptionID", trnDataTypeint, 4, RequestID_Prescription) & _
                 gTransport.CreateInputParameterXML("Today", trnDataTypeVarChar, 8, Format$(Now, "ddmmyyyy"))
      intCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWLabelCountbyLastDateandPrescriptionID", strParam)
      If intCount > 0 Then
         'We have some that have been dispensed today
         strMessage = "Please note that this prescription may already have been dispensed today"
         strMessage = TxtD(dispdata$ & "\patmed.ini", "", strMessage, "DispensedTodayMessage", 0)
         popmessagecr "", strMessage
         SetFocusTo txtUC("TxtPrompt")  '29Aug10 TH Ensure prompt is retained correctly after msg displayed (F0095199)
      End If

   End If


End Sub

Sub GetPrescriptionReasons(ByVal RequestID_Label As Long, ByRef strRxReason As String, ByRef strRXReasonPatient As String)
'25Aug11 TH Written (TFS12153)
'Read any associated Prescription reasons and linked patient readable form

'26Sep11 TH TFS15620 - remove unecessary date param
'28Sep11 TH changed variable names as this uses Label requestID not the rx request ID directly. Also changed the sp name to reflect this.


Dim strParam As String
Dim rsReasons As ADODB.Recordset

      'set default
      strRxReason = ""
      strRXReasonPatient = ""
      
      strParam = gTransport.CreateInputParameterXML("LabelID", trnDataTypeint, 4, RequestID_Label)
      '& _
      '           gTransport.CreateInputParameterXML("Today", trnDataTypeVarChar, 8, Format$(Now, "ddmmyyyy"))
      Set rsReasons = gTransport.ExecuteSelectSP(g_SessionID, "pRxReasonandRxReasonPatientbyLabelID", strParam)
      If Not rsReasons Is Nothing Then     'use returned recordset
         If rsReasons.State = adStateOpen Then
            If rsReasons.RecordCount <> 0 Then
               strRxReason = RtrimGetField(rsReasons!rxReason)
               strRXReasonPatient = RtrimGetField(rsReasons!rxReasonPatient)
            End If
         End If
      End If
      rsReasons.Close
      Set rsReasons = Nothing


End Sub
Sub clearlabel(ByRef L As WLabel)
'09May05 Now just clears the label and nothing else.  !!** except RxOffset&
'        Uses L as a param, not the global structure
   
   RxOffset& = 0         '19Jan01 CKJ Added
   'expiry$ = ""          '25Jan95 CKJ Added  '**!!** was declared locally so would not be the right one
   
   BlankWLabel L
         
   L.dispid = "***"     '**???**

End Sub

' 15Feb13 XN  Added to provide a standard conversion from WLabel.LastSavedDateTime, to old WLavel.LastData value
' the new LastSavedDateTime is a datetime, and the old version is a string (ddmmyyyy format)
' Return "" if LastSavedDateTime is empty (40210)
Function LastSavedDateTimeToLastDate(ByVal lastSavedDateTime As Date) As String
   If lastSavedDateTime = Empty Then
      LastSavedDateTimeToLastDate = ""
   Else
      LastSavedDateTimeToLastDate = Format$(lastSavedDateTime, "ddmmyyyy")
   End If
End Function

Function SetNewFastRepeat(strFastRepeat As String) As String
'10Jun07 TH Written
'22Oct07 TH Altered to use new DB objects
'16Aug13 TH (TFS 70134) Ported from 9.9 and altered to allow number to be passed in rather than set here if required

Dim lngFastRepeat As Long
Dim strParams As String
Dim strRepeat As String
Dim lngOK As Long


'First Read the pointer

'GetPointerSQL patdatapath$ & "\FastRepeat", lngFastRepeat, True
If Trim$(strFastRepeat) = "" Then
   GetPointerSQL patdatapath$ & "\EpisodeOrderLookup", lngFastRepeat, True '22Oct07 TH
   strFastRepeat = Format$(lngFastRepeat)
End If
                  
'Then add the prefix if necessary

'strRepeat = TxtD(dispdata$ & "\patmed.ini", "FastRepeat", "", "FastRepeatPrefix", 0)
strRepeat = TxtD(dispdata$ & "\patmed.ini", "EpisodeOrderLookup", "", "EpisodeOrderLookupPrefix", 0)

'strRepeat = strRepeat & Format$(lngFastRepeat)
strRepeat = strRepeat & strFastRepeat

'Now save the record to the DB

 'strParams = gTransport.CreateInputParameterXML("PrescriptionID", trnDataTypeint, 4, gRequestID_Prescription) & _
 'gTransport.CreateInputParameterXML("FastRepeatNumber", trnDataTypeVarChar, 20, strRepeat)
 
 strParams = gTransport.CreateInputParameterXML("EpisodeOrderID", trnDataTypeint, 4, gRequestID_Prescription) & _
 gTransport.CreateInputParameterXML("EpisodeOrderLookup", trnDataTypeVarChar, 20, strRepeat)
            

'lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pFastRepeatNumberInsert", strParams)
lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pEpisodeOrderLookupInsert", strParams)

SetNewFastRepeat = strRepeat

End Function
