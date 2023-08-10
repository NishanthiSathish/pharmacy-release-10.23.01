Attribute VB_Name = "WPatientIO"
'07Oct04 CKJ Patient access module
'            Note: update/delete not supported
'09Feb05 CKJ Added .title

Option Explicit
DefInt A-Z

'pPatientSelect
'-----------
'[Patient].EntityID
' [Entity].EntityTypeID
' [Entity].TableID
' [Entity].Description
' [Entity].Telephone
' [Entity].Fax
' [Entity].Email
' [Entity].Website
' [Person].Title
' [Person].Initials
' [Person].Forename
' [Person].Surname
' [Person].Mobile
' [Person].Pager
'[Patient].GenderID
' [Gender].[Description] "GenderDescription"
'[Patient].EntityID_NextOfKin
'[Patient].DOB
'[Patient].DOBEstYear
'[Patient].DOBEstMonth
'[Patient].DOBEstDay
'[Patient].NHSNumber
'[Patient].NHSNumberValid

Type WPatient
   EntityID As Long
   recno As String         '* 10    ' internal lookup code - used for Xref in Tpn etc: Now is PK as a string
   title As String         '* 5     ' *10 in SQL
   surname As String       '* 20    ' trimmed & left justified
   forename As String      '* 15    ' trimmed & left justified
   dob As String           '* 8     ' as  ddmmyyyy  only
   sex As String           '* 1     ' M F or space
End Type
''   caseno As String        '* 10    ' Current caseno
''   oldcaseno As String     '* 10    ' Previous caseno, after a merge     18oct05 CKJ removed
'   ward As String          '* 4     ' UCase only                             'Episodic - removed
'   cons As String          '* 4     ' UCase only                             '   "
'   weight As String        '* 6     ' kkk.gg                                 '   "
'   Height As String        '* 6     ' ff.ii                                  '   "
'   Status As String        '* 1     ' I/O/D/L                                '   "
''   postCode As String      '* 8     ' added for coventry etc. ASC 06Sep93   '   "
'   GP As String            '* 4     ' UCase only                             '   "
''   HouseNumber As String   '* 6     ' 28Mar97                               '   "

Private Const OBJNAME As String = PROJECT & "WPatientIO."
'

Function GetPatientByPK(ByVal WPatientID As Long, ByRef WPat As WPatient) As Boolean
'09May05 Given the PK, fetch a label and fill the L structure
'        If the patient is absent then return success = false and blank WPat
'        If the DB is unreachable then raise an error

Dim success As Boolean
Dim rs As ADODB.Recordset
Dim iLoop As Integer

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "GetPatientByPK"

   On Error GoTo ErrorHandler
   success = False
   BlankWPatient WPat
   
   Set rs = GetPatientRSbyID(WPatientID)
   If Not rs Is Nothing Then                 'use returned recordset
      If rs.State = adStateOpen Then
         If rs.RecordCount > 0 Then
            CastRecordsetToPatient rs, WPat
            success = True
         End If
      End If
   End If
   
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   GetPatientByPK = success
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If

Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup

End Function


Private Sub BlankWPatient(WPat As WPatient)

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "BlankWPatient"

   On Error GoTo ErrorHandler

   WPat.EntityID = 0
   WPat.recno = ""
   WPat.title = ""
   WPat.surname = ""
   WPat.forename = ""
   WPat.dob = ""
   WPat.sex = ""

''   WPat.caseno = ""
''   WPat.oldcaseno = ""         18oct05 CKJ removed
''   WPat.postCode = ""
''   WPat.HouseNumber = ""
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
End Sub

Private Function GetPatientRSbyID(ByVal WPatientID As Long) As ADODB.Recordset
'09May05 Just a plain read with no UI or business logic, returning an ADODB RS

Dim lErrNo        As Long
Dim sErrDesc      As String
Dim strParameters As String

   On Error GoTo ErrHandler
      
   strParameters = gTransport.CreateInputParameterXML("WPatientID", trnDataTypeint, 4, WPatientID)
   Set GetPatientRSbyID = gTransport.ExecuteSelectSP(g_SessionID, "pPatientSelect", strParameters)
   
Exit Function

ErrHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error resume next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "GetPatientRSbyID", sErrDesc
End Function


Private Sub CastRecordsetToPatient(ByRef rs As ADODB.Recordset, ByRef WPat As WPatient)
'09May05 Cast record to label struct

Dim sDOB       As String
Dim valid      As Integer
Dim strSex     As String
Dim lErrNo     As Long
Dim sErrDesc   As String
Const ErrSource As String = "CastRecordsetToPatient"

   On Error GoTo ErrorHandler
      
   WPat.EntityID = GetField(rs!EntityID)
   WPat.recno = Format$(WPat.EntityID)
   WPat.title = RtrimGetField(rs!title)
   WPat.surname = RtrimGetField(rs!surname)
   WPat.forename = RtrimGetField(rs!forename)
   
   WPat.dob = ""
   parsedate RtrimGetField(rs!dob), sDOB, "3", valid
   If valid Then WPat.dob = sDOB
   
   strSex = UCase$(Left$(RtrimGetField(rs!GenderDescription), 1))
   Select Case strSex
      Case "U", "M", "F"         'no action
      Case Else: strSex = "U"
      End Select
   WPat.sex = strSex

''   WPat.caseno = ""                              11Nov05 CKJ no caseno at this level
''   WPat.oldcaseno = ""                           18oct05 CKJ removed
''   WPat.Status = RtrimGetField(rs!PatientStatusID)         '**!!** fixed at 'O' in the SP

   ' [Entity].Description
   ' [Person].Initials
   ' [Person].Mobile
   ' [Person].Pager
   '[Patient].EntityID_NextOfKin
   '[Patient].DOBEstYear
   '[Patient].DOBEstMonth
   '[Patient].DOBEstDay
   '[Patient].NHSNumber
   '[Patient].NHSNumberValid
   
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
End Sub

''Sub GetPatIDNL(ByVal WPatientID As Long, ByRef pid As patidtype)
'''mirrors the original V8 procedure
''
''Dim success As Boolean
''Dim WPat As WPatient
''''Dim iLoop As Integer
''Dim lErrNo        As Long
''Dim sErrDesc      As String
''Const ErrSource As String = "GetPatIDNL"
''
''   On Error GoTo ErrorHandler
''
''   success = GetPatientByPK(WPatientID, WPat)
''   If Not success Then
''      popmessagecr ".", "Unable to retrieve patient data (GetPatIDNL called GetPatientByPK)"
''      Error 32767
''   Else
''      With pid
''         .recno = WPat.recno
''         .caseno = ""                           '11Nov05 CKJ There is no Caseno at this level WPat.caseno
''''         .oldcaseno = WPat.oldcaseno          18oct05 CKJ removed
''''         .title = WPat.title
''         .surname = WPat.surname
''         .forename = WPat.forename
''         .dob = WPat.dob
''         .sex = WPat.sex
''         .ward = ""       ' WPat.ward
''         .cons = ""       ' WPat.cons
''         .weight = ""     ' WPat.weight
''         .Height = ""     ' WPat.Height
''         .status = ""     ' WPat.Status
''''         For iLoop = 1 To 10
''''            .ptr(iLoop) = ""
''''         Next
''''         .postCode = WPat.postCode
''''         .GP = ""         ' WPat.GP
''''         .HouseNumber = WPat.HouseNumber
''      End With
''   End If
''Exit Sub
''
''ErrorHandler:
''   lErrNo = Err.Number
''   sErrDesc = Err.Description
''   'On Error Resume Next
''   On Error GoTo 0
''   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
''End Sub
