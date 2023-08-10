Attribute VB_Name = "WGeneralIO"
'05Nov04 CKJ Written
'09Feb05 CKJ Removed Location & User from Enum as these are not stored in the state table
'03Mar06 CKJ/TH IsRequestCancelled written
'22oct08 AK  Added SettingValueGet: Return the value for the requested Key in the Setting table (F0018781)
'13May12 TH  GetNHSNumberDisplayName: Moved here from WIDENTSB to allow use in log viewer
'13May12 TH  GetNHSNumberDisplayNameFormat: Written to allow correct formating of Pat number
'22May12 TH  GetNHSNumberDisplayName: Use the description of identifier from main setting (TFS34615)
'22May12 TH  GetNHSNumberDisplayNameFormat: Use the description of identifier from main setting (TFS34615)
'24Mar13 TH  IsParentPrescriptionCancelled: Written TFS (59469,59468)

Option Explicit
DefInt A-Z

Public Enum StateType
'   location
'   User
   Episode
   Entity
   Cookie
End Enum

Private Const OBJNAME As String = PROJECT & "WGeneralIO."

Function GetState(ByVal sessionID As Long, ByVal StateCode As StateType) As Long
'09May05 CKJ Read the State table and return the ID corresponding to the named state code
'            Permitted codes are defined in the StateType enum.
'            If no row exists for that state type then -1 is returned

Dim tablename As String
Dim primarykey As Long
Dim str_XML As String
Dim xmldoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMElement
Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "GetState"

   On Error GoTo ErrorHandler
      
   Select Case StateCode
'      Case StateType.location: TableName = ""
'      Case StateType.User:     TableName = ""
      Case StateType.Episode:  tablename = "Episode"
      Case StateType.Entity:   tablename = "Entity"
      Case StateType.Entity:   tablename = "Cookie"
      End Select
   
   strParameters = gTransport.CreateInputParameterXML("TableName", trnDataTypeVarChar, 50, tablename) & _
      gTransport.CreateOutputParameterXML("PrimaryKey", trnDataTypeint, 4)
   str_XML = gTransport.ExecuteSelectOutputSP(g_SessionID, "pStateGet", strParameters)
   Set xmldoc = New MSXML2.DOMDocument
   xmldoc.loadXML str_XML
   Set xmlnode = xmldoc.selectSingleNode("//Parameters")
   GetState = xmlnode.getAttribute("PrimaryKey")
   
Cleanup:
   On Error Resume Next
   Set xmlnode = Nothing
   Set xmldoc = Nothing
   On Error GoTo 0
   If lErrNo Then
      GetState = -1
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If
      
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   Resume Cleanup
End Function

Function GetLocationID_Site(ByVal AscribeSiteNumber As Integer) As Long
'09May05 CKJ

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "GetLocationID_Site"

   On Error GoTo ErrorHandler
      
   strParameters = gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeint, 4, AscribeSiteNumber)
   GetLocationID_Site = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParameters)
   
Cleanup:
   'On Error Resume Next
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

Function SettingValueGet(ByVal vstrSystem As String, _
                         ByVal vstrSection As String, _
                         ByVal vstrKey As String _
                         ) As String
'22oct08 AK  Return the value for the requested Key in the Setting table (F0018781)

Dim strParameters As String
Dim lngErrNoc As Long
Dim strErrDesc As String
Dim rs As ADODB.Recordset
Dim strXML As String
Dim xmldoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMElement
Const ErrSource As String = "SettingValueGet"

   On Error GoTo ErrorHandler
      
   strParameters = gTransport.CreateInputParameterXML("System", trnDataTypeVarChar, 50, vstrSystem) _
                 & gTransport.CreateInputParameterXML("Section", trnDataTypeVarChar, 50, vstrSection) _
                 & gTransport.CreateInputParameterXML("Key", trnDataTypeVarChar, 50, vstrKey)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pSetting", strParameters)
   If rs.EOF = False Then SettingValueGet = GetField(rs!Value)

Cleanup:
    On Error GoTo 0
    If Not rs Is Nothing Then
        If rs.State = adStateOpen Then rs.Close
        Set rs = Nothing
    End If
    If lngErrNoc Then
        Err.Raise lngErrNoc, OBJNAME & ErrSource, strErrDesc
    End If
Exit Function

ErrorHandler:
    lngErrNoc = Err.Number
    strErrDesc = Err.Description
Resume Cleanup

End Function


Sub CastRecordsetToHeap(ByRef rs As ADODB.Recordset, ByVal HeapID As Integer, ByVal blnXML As Boolean)
'09May05 Cast record to OCX heap

Dim strItem As String
Dim strText As String
Dim field As ADODB.field

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource   As String = "CastRecordsetToHeap"

   On Error GoTo ErrorHandler
   
   For Each field In rs.Fields
      strItem = field.name
      strText = RtrimGetField(field)
      Heap 10, HeapID, strItem, strText, 0
      If blnXML Then
         EscapeXML strText
         Heap 10, HeapID, Trim$(strItem) & "XML", strText, 0
      End If
   Next
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
End Sub

Function UnitConversion(ByVal SourceUnit As String, _
                        ByVal SourceValue As Single, _
                        ByVal DestinationUnit As String _
                       ) As Variant
'08Apr05 CKJ Calculate the ratio between two comparable units from the same family
'             UnitConversion("mg", 750, "g")  means convert 750mg to grams and returns 0.75
'            Returns NULL if a ratio cannot be determined eg UnitConversion("kg", 1, "cm")
  
Dim strParameters As String
Dim rs As ADODB.Recordset

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource   As String = "UnitConversion"

   On Error GoTo ErrorHandler
   UnitConversion = Null
   
   strParameters = gTransport.CreateInputParameterXML("SourceUnit", trnDataTypeChar, 50, SourceUnit) _
                 & gTransport.CreateInputParameterXML("SourceValue", trnDataTypeFloat, 4, SourceValue) _
                 & gTransport.CreateInputParameterXML("DestinationUnit", trnDataTypeChar, 50, DestinationUnit)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pUnitConversion", strParameters)
   UnitConversion = rs.Fields("DestinationValue")
  
Cleanup:
   On Error Resume Next
   Set rs = Nothing
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
Public Sub UnlockDatabase(sessionID As Long)
'12Dec05 TH Written.
'This is intended as a general wrapper for the main locking routines. It is designed
'to cope with all possible locks in the system as the application gracefully (or oteherwise)
'retires from the field.
'This will need expanding as locking is expended (notably for batch locking)
Dim dummy As Long

   dummy = UnlockDatabaseTable("WOrder", sessionID)
   dummy = UnlockDatabaseTable("WRequis", sessionID)
   dummy = UnlockDatabaseTable("WReconcil", sessionID)
   dummy = UnlockDatabaseTable("ProductStock", sessionID)

End Sub
Public Function UnlockDatabaseTable(strTable As String, sessionID As Long) As Long
'12Dec05 TH Written.
'This should remove the SessionID from the locking column on the specified table
Dim lngOK As Long

   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "p" & strTable & "SessionUnlock", "")
   
   UnlockDatabaseTable = lngOK

End Function
Public Function TableRowLock(strTable As String, RowID As Long, sessionID As Long) As ADODB.Recordset
'12Dec05 TH Written.
'This should add the SessionID from the locking column on the specified table
'If there is already a Valid SessionID then this should be returned
'18May06 TH added retry functionality - tried to make it as configurable as possible, mostly
'        so that it can be turned off if testing is problematic

Dim strParameters As String
Dim lngOK As Long
Dim intTrys As Integer
Dim blnComplete As Boolean

   
   intTrys = 0
   Do While Not blnComplete
      strParameters = gTransport.CreateInputParameterXML("RowID", trnDataTypeint, 4, RowID)
      Set TableRowLock = gTransport.ExecuteSelectSP(g_SessionID, "p" & strTable & "Rowlock", strParameters)
      If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "AllowLockingRetry", 0)) Then
         If TableRowLock.EOF Or TableRowLock.RecordCount > 1 Or (GetField(TableRowLock!sessionID) <> g_SessionID) Then
            'Lock has not been granted. Here we should wait and retry a while
            waitforticks CInt(TxtD(dispdata$ & "\ascribe.ini", "", "10", "LockingRetryWait", 0))
            intTrys = intTrys + 1
            If intTrys = CInt(TxtD(dispdata$ & "\ascribe.ini", "", "5", "LockingRetrys", 0)) Then blnComplete = True
         Else
            blnComplete = True
         End If
      Else
         blnComplete = True
      End If
      If Not blnComplete Then
         'As we are looping it seems good to destroy the db object to ensure
         'a fresh instantiation
         On Error Resume Next
         TableRowLock.Close
         Set TableRowLock = Nothing
         On Error GoTo 0
      End If
   Loop
   
End Function

Public Function TableRowUnLock(strTable As String, RowID As Long, sessionID As Long) As Long
'12Dec05 TH Written.
'This should remove the SessionID from the locking column on the specified table
Dim strParameters As String
Dim lngOK As Long
   strParameters = gTransport.CreateInputParameterXML("RowID", trnDataTypeint, 4, RowID)
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "p" & strTable & "RowUnlock", strParameters)
   
   TableRowUnLock = lngOK

End Function

Function IsRequestCancelled(ByVal RequestID As Long) As Boolean
'03Mar06 CKJ/TH written
'               given a RequestID, returns request is cancelled True/False or raises error if unable to check

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler
   strParameters = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID)
   IsRequestCancelled = gTransport.ExecuteSelectReturnSP(g_SessionID, "pRequestGetCancelledStatus", strParameters)
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "IsRequestCancelled ", sErrDesc
End Function

 
Function IsPrescriptionLinked(ByVal RequestID As Long) As Boolean
'12Jul11 TH written
'           given a RequestID, returns whether request is comple(linked) rx True/False or raises error if unable to check

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler
   strParameters = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID)
   IsPrescriptionLinked = gTransport.ExecuteSelectReturnSP(g_SessionID, "pIsPrescriptionLinked", strParameters)
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "IsPrescriptionLinked ", sErrDesc
End Function


Public Sub CreateAttachNoteLinkedtoRequest(ByVal strNoteTypeDescription As String, _
                                           ByVal EntityID As Long, _
                                           ByVal strDescription As String, _
                                           ByVal Enabled As Boolean, _
                                           ByVal RequestID As Long)
'08Mar12 TH Written.
'This is intended as a general wrapper for inserting linked attahc notes
'So that client side software can participate in various order comms roles

Dim strParams As String
Dim lngOK As Long

   strParams = gTransport.CreateInputParameterXML("NoteTypeDescription", trnDataTypeVarChar, 50, strNoteTypeDescription) & _
               gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, EntityID) & _
               gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 120, strDescription) & _
               gTransport.CreateInputParameterXML("CreatedDate", trnDataTypeDateTime, 4, Null) & _
               gTransport.CreateInputParameterXML("LocationID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Enabled", trnDataTypeBit, 1, Enabled) & _
               gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID)
               
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pAttachedNoteInsertandLinkRequest", strParams)
   

End Sub


Public Sub DisableAttachNoteLinkedtoRequest(ByVal strNoteTypeDescription As String, _
                                           ByVal RequestID As Long)
'08Mar12 TH Written.
'This is intended as a general wrapper for disabling linked attach notes
'So that client side software can participate in various order comms roles

Dim strParams As String
Dim lngOK As Long

   strParams = gTransport.CreateInputParameterXML("NoteTypeDescription", trnDataTypeVarChar, 50, strNoteTypeDescription) & _
               gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID)
               
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pAttachedNoteDisable_Request", strParams)
   

End Sub

Function GetNHSNumberDisplayName() As String
'13May12 TH Moved here from WIDENTSB to allow use in log viewer
'22May12 TH Use the description of identifier from main setting (TFS34615)


Dim strParams As String
Dim rs As ADODB.Recordset
Dim strAns As String
Dim strIdentifier As String '22May12 TH Added


   strIdentifier = SettingValueGet("General", "PatientEditor", "PrimaryPatientIdentifier") '22May12 TH Added
   
   

   'strParams = gTransport.CreateInputParameterXML("NHSNumber", trnDataTypeVarChar, 50, "NHSNumber") '22May12 TH Replaced with below
   strParams = gTransport.CreateInputParameterXML("NHSNumber", trnDataTypeVarChar, 50, strIdentifier) & _
      gTransport.CreateOutputParameterXML("PrimaryKey", trnDataTypeVarChar, 50)
   'strParams = strParams & gTransport.CreateInputParameterXML("Dummy", trnDataTypeVarChar, 50, "")
   
   strAns = gTransport.ExecuteSelectOutputSP(g_SessionID, "pAliasGroupDisplayNameByDescription", strParams)
   
   If IsNull(strAns) Then
      strAns = ""
   Else
      'Parse out the result
      strAns = Right$(strAns, Len(strAns$) - (InStr(1, strAns, "=", vbTextCompare) + 1))
      strAns = Left$(strAns, Len(strAns$) - 5)
   End If
   
   GetNHSNumberDisplayName = strAns


End Function

Function GetNHSNumberDisplayNameFormat() As String
'13May12 TH Written for use in log viewer
'22May12 TH Use the description of identifier from main setting (TFS34615)

Dim strParams As String
Dim rs As ADODB.Recordset
Dim strAns As String
Dim strIdentifier As String '22May12 TH Added


   strIdentifier = SettingValueGet("General", "PatientEditor", "PrimaryPatientIdentifier") '22May12 TH Added

   'strParams = gTransport.CreateInputParameterXML("NHSNumber", trnDataTypeVarChar, 50, "NHSNumber") '22May12 TH Replaced with below
   strParams = gTransport.CreateInputParameterXML("NHSNumber", trnDataTypeVarChar, 50, strIdentifier) & _
      gTransport.CreateOutputParameterXML("PrimaryKey", trnDataTypeVarChar, 50)
   'strParams = strParams & gTransport.CreateInputParameterXML("Dummy", trnDataTypeVarChar, 50, "")
   
   strAns = gTransport.ExecuteSelectOutputSP(g_SessionID, "pAliasFormatByDescription", strParams)
   
   If IsNull(strAns) Then
      strAns = ""
   Else
      'Parse out the result
      strAns = Right$(strAns, Len(strAns$) - (InStr(1, strAns, "=", vbTextCompare) + 1))
      strAns = Left$(strAns, Len(strAns$) - 5)
   End If
   
   GetNHSNumberDisplayNameFormat = strAns


End Function

Function IsParentPrescriptionCancelled(ByVal WLabelID As Long) As Boolean
'24Mar13  TH written
'         given a WlabeID, returns whether the parent prescription is cancelled
'         TFS (59469,59468)

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler
   strParameters = gTransport.CreateInputParameterXML("WLabelID", trnDataTypeint, 4, WLabelID)
   IsParentPrescriptionCancelled = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWLabelIsParentPrescriptionCancelled", strParameters)
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "IsParentPrescriptionCancelled ", sErrDesc
End Function
Function CheckRptDispLinking(ByVal lngRequestID_Prescription As Long, ByVal lngRequestID_Dispensing As Long) As Boolean
'20Aug13  TH written
'         returns whether this isnt rpt disp linked, and other dispensings under this rx are
'         TFS (70134)

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler
   strParameters = gTransport.CreateInputParameterXML("RequestID_Prescription", trnDataTypeint, 4, lngRequestID_Prescription) & _
                   gTransport.CreateInputParameterXML("RequestID_Dispensing", trnDataTypeint, 4, lngRequestID_Dispensing)
   CheckRptDispLinking = gTransport.ExecuteSelectReturnSP(g_SessionID, "pRepeatDispensingPrescriptionLinkDispensingForDispenseCheck", strParameters)
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "CheckRptDispLinking ", sErrDesc
End Function
Function IsDispensingRptDispLinked(ByVal lngRequestID_Dispensing As Long) As Boolean
'20Aug13  TH written
'         returns whether this is rpt disp linked
'         TFS (70134)

Dim strParameters As String

Dim lngErrNo As Long
Dim strErrDesc As String
Dim rs As ADODB.Recordset
Dim blnReturn As Boolean
Const ErrSource   As String = "IsDispensingRptDispLinked"

   blnReturn = False
   On Error GoTo ErrorHandler
   strParameters = gTransport.CreateInputParameterXML("RequestID_Dispensing", trnDataTypeint, 4, lngRequestID_Dispensing)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pRepeatDispensingPrescriptionLinkDispensingbyDispensingIDINUSE", strParameters)
   If rs.EOF = False Then blnReturn = True
   
   
   IsDispensingRptDispLinked = blnReturn
   
Cleanup:
    On Error GoTo 0
    If Not rs Is Nothing Then
        If rs.State = adStateOpen Then rs.Close
        Set rs = Nothing
    End If
    If lngErrNo Then
        Err.Raise lngErrNo, OBJNAME & ErrSource, strErrDesc
    End If
Exit Function

ErrorHandler:
    lngErrNo = Err.Number
    strErrDesc = Err.Description
Resume Cleanup
End Function


