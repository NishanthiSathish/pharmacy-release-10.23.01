Attribute VB_Name = "WPrescriptionIO"
' WPrescription
'
'V93 Module created to bring together all code which reads Prescription Requests from SQL
'
'29Dec14 XN Added GetRequestTypeByChildRequestID: To get the request type from child request ID 89292
'10Sep15 TH  PrescriptionToOCXHeap: Added support for custom frequency with complex (linked) prescriptions (TFS 128203)
'17Sep15 TH  PrescriptionToOCXHeap: ANeed to support infusions in linked Rxs !(TFS 129844)
'04Dec15 TH  PrescriptionToOCXHeap: Ensure PRN is recorded TFS 137379)
'29Sep15 XN  SiteSpecificRxInfoToPrintHeap: Added (TFS 77778)
'12Feb15 XN  SiteSpecificRxInfoToPrintHeap: 145005 Fixed printing of chinese name and language on worksheet
'16Apr18 DR  Bug 209934 - Dispensing control client error in event log missing sp

Option Explicit
DefInt A-Z


Private Const OBJNAME As String = PROJECT & "WPrescriptionIO."

Function PrescriptionToOCXHeap(ByVal RequestID As Long) As Boolean
'09May05 Returns true if prescription found, false if rs is empty
'12Jul11 TH Mods to handkle complex types
'09Nov11 TH Further mods to handle split dosing of complex types (TFS18827)
'10Sep15 TH  Added support for custom frequency with complex (linked) prescriptions (TFS 128203)
'17Sep15 TH Need to support infusions in linked Rxs !(TFS 129844)
'04Dec15 TH Ensure PRN is recorded TFS 137379)

Dim success As Boolean

Dim rs As ADODB.Recordset
Dim rsComplex As ADODB.Recordset
Dim lErrNo        As Long
Dim sErrDesc      As String
Dim strParams     As String
Dim intCount As Integer

   On Error GoTo ErrorHandler

   success = False
   If g_blnLinkedPrescription Then '12Jul11 TH Added to handkle complex types
      'swap the request to the master rx
      RequestID = GetPrescriptionIDbyLinkedPrescriptionID(RequestID)
   End If
   Set rs = GetPrescriptionRSbyID("pPrescriptionSelect", RequestID)        'Try Normal Prescriptions
   If rs.RecordCount = 0 Then                                              'Try Non-medicinal prescription
      Set rs = GetPrescriptionRSbyID("pProductOrderSelect", RequestID)
   End If
   
   If rs.RecordCount > 0 Then
      CastRecordsetToHeap rs, g_OCXheapID, False '03Mar14 TH Added Param
      success = True
   End If
   
   If g_blnLinkedPrescription Then '12Jul11 TH Added to handkle complex types
      'Here we need to get other linked prescriptions (dose and doselow fields) that we need to use to add to the label
      strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Prescription)
      Set rsComplex = gTransport.ExecuteSelectSP(g_SessionID, "pWPrescriptionMergeItembyPrescriptionIDForWlabel", strParams)
      If rsComplex.RecordCount > 0 Then
         rsComplex.MoveFirst
         intCount = 0
         Heap 10, g_OCXheapID, "MergedDescription", RtrimGetField(rsComplex!MergedDescription), 0 '09Nov11 TH  (TFS18827)

         Do While Not rsComplex.EOF
            If GetField(rsComplex!RequestID) <> RequestID Then
               intCount = intCount + 1
               Heap 10, g_OCXheapID, "dose" & Format$(intCount), RtrimGetField(rsComplex!dose), 0
               Heap 10, g_OCXheapID, "doselow" & Format$(intCount), RtrimGetField(rsComplex!doselow), 0
               Heap 10, g_OCXheapID, "dircode" & Format$(intCount), RtrimGetField(rsComplex!dircode), 0
               Heap 10, g_OCXheapID, "UnitAbbreviationDose" & Format$(intCount), RtrimGetField(rsComplex!UnitAbbreviationDose), 0
               Heap 10, g_OCXheapID, "productformdescription" & Format$(intCount), RtrimGetField(rsComplex!productformdescription), 0
               Heap 10, g_OCXheapID, "ProductRouteDescription" & Format$(intCount), RtrimGetField(rsComplex!ProductRouteDescription), 0
               Heap 10, g_OCXheapID, "PRN" & Format$(intCount), RtrimGetField(rsComplex!Prn), 0  '04Dec15 TH (TFS 137379)
               '06Sep11 TH Added new fields to support multiple duration codes
               Heap 10, g_OCXheapID, "UnitDescriptionDuration" & Format$(intCount), RtrimGetField(rsComplex!UnitDescriptionDuration), 0
               Heap 10, g_OCXheapID, "Duration" & Format$(intCount), RtrimGetField(rsComplex!Duration), 0
               Heap 10, g_OCXheapID, "Description" & Format$(intCount), RtrimGetField(rsComplex!Description), 0 '09Nov11 TH  (TFS18827)
               '10Sep15 TH Added new custom frequency stuff (TFS 128203)
               Heap 10, g_OCXheapID, "Description_Frequency" & Format$(intCount), RtrimGetField(rsComplex!Description_Frequency), 0
               Heap 10, g_OCXheapID, "Description_Direction" & Format$(intCount), RtrimGetField(rsComplex!Description_Direction), 0
               Heap 10, g_OCXheapID, "ScheduleID_Administration" & Format$(intCount), RtrimGetField(rsComplex!ScheduleID_Administration), 0
               '17Sep15 TH Andrew has added infusions to linked Rxs !(TFS 129844)
               Heap 10, g_OCXheapID, "UnitAbbreviation_InfusionDuration" & Format$(intCount), RtrimGetField(rsComplex!UnitAbbreviation_InfusionDuration), 0
               Heap 10, g_OCXheapID, "InfusionDurationLow" & Format$(intCount), RtrimGetField(rsComplex!InfusionDurationLow), 0
               Heap 10, g_OCXheapID, "InfusionDuration" & Format$(intCount), RtrimGetField(rsComplex!InfusionDuration), 0
               
               Heap 10, g_OCXheapID, "UnitAbbreviationDose_Ingredient" & Format$(intCount), RtrimGetField(rsComplex!UnitAbbreviationDose_Ingredient), 0
               Heap 10, g_OCXheapID, "QuantityMax_Ingredient" & Format$(intCount), RtrimGetField(rsComplex!QuantityMax_Ingredient), 0
               Heap 10, g_OCXheapID, "QuantityMin_Ingredient" & Format$(intCount), RtrimGetField(rsComplex!QuantityMin_Ingredient), 0
               
               Heap 10, g_OCXheapID, "Quantity_Ingredient" & Format$(intCount), RtrimGetField(rsComplex!Quantity_Ingredient), 0
               Heap 10, g_OCXheapID, "UnitAbbreviation_InfusionContinuousRateTime" & Format$(intCount), RtrimGetField(rsComplex!UnitAbbreviation_InfusionContinuousRateTime), 0
               Heap 10, g_OCXheapID, "UnitAbbreviation_InfusionContinuousRateMass" & Format$(intCount), RtrimGetField(rsComplex!UnitAbbreviation_InfusionContinuousRateMass), 0
               
               Heap 10, g_OCXheapID, "InfusionRateMax" & Format$(intCount), RtrimGetField(rsComplex!InfusionRateMax), 0
               Heap 10, g_OCXheapID, "InfusionRateMin" & Format$(intCount), RtrimGetField(rsComplex!InfusionRateMin), 0
               Heap 10, g_OCXheapID, "InfusionRate" & Format$(intCount), RtrimGetField(rsComplex!InfusionRate), 0
               
               Heap 10, g_OCXheapID, "InfusionContinuous" & Format$(intCount), RtrimGetField(rsComplex!InfusionContinuous), 0
               Heap 10, g_OCXheapID, "InfusionRateMin" & Format$(intCount), RtrimGetField(rsComplex!InfusionRateMin), 0
               Heap 10, g_OCXheapID, "InfusionRate" & Format$(intCount), RtrimGetField(rsComplex!InfusionRate), 0
               
            End If
            rsComplex.MoveNext
            'Store the incout for later use
            g_TotalComplexChildren = intCount
         Loop
      
      End If
   End If
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   PrescriptionToOCXHeap = success
   If lErrNo Then Err.Raise lErrNo, OBJNAME & "PrescriptionToOCXHeap", sErrDesc
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup
End Function

Function GetPrescriptionRSbyID(ByVal strSPname As String, ByVal RequestID As Long) As ADODB.Recordset
'09May05 Just a plain read with no UI or business logic, returning an ADODB RS

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler
   strParameters = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID)
   Set GetPrescriptionRSbyID = gTransport.ExecuteSelectSP(g_SessionID, strSPname, strParameters)
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "GetPrescriptionRSbyID " & strSPname, sErrDesc
End Function


Function GetPrescriptionIDbyLinkedPrescriptionID(ByVal RequestID As Long) As Long
'11Jul11 TH Written return a prescriptionID from a merged line

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler
   strParameters = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID)
   GetPrescriptionIDbyLinkedPrescriptionID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pPrescriptionIDMasterfromPresciptionLinked", strParameters)

Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "GetPrescriptionIDbyWPrescription_MergedID" & sErrDesc
End Function

Function PharmacyPrescriptionLock(ByVal RequestID As Long) As Boolean
'13Feb13 TH Written TFS 51159
'18Feb13 TH Altered to allow continuance and handle complex prescription types
'19Feb13 TH Changed message as per Mr Simmons (TFS 56918)

Dim strParameters As String
Dim rsLock As ADODB.Recordset
Dim lErrNo        As Long
Dim sErrDesc      As String
Dim strMsg As String
Dim blnOK As Boolean
Dim strAns As String
Dim lngComplexRxID As Long
Dim LogMsg As String

   On Error GoTo ErrorHandler
   
   strAns = "N" 'default
   
   'If g_blnLinkedPrescription Then '18Feb13 TH Added to handle complex types
   'swap the request to the master rx - always use the high level ID wherever we are rxing. Lock the whole complex rx
   'lngComplexRxID = GetPrescriptionIDbyLinkedPrescriptionID(RequestID)
   lngComplexRxID = GetMergeIDbyLinkedPrescriptionID(RequestID)  '22Feb13 TH Replaced above TFS 57204
   'End If
   If lngComplexRxID > 0 Then RequestID = lngComplexRxID
   
   strParameters = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID)
   Set rsLock = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyPrescriptionLock", strParameters)
   
   If rsLock.EOF Or rsLock.RecordCount > 1 Then
      strMsg = "Could not lock Prescription Record Number " & CStr(RequestID) & crlf & "Reason Unknown"
      'popmessagecr "ASCribe", strMsg
      LogMsg = strMsg
      strMsg = strMsg & crlf & crlf & "Do you wish to continue?"
      askwin "!EMIS Health", TxtD(dispdata$ & "\patmed.ini", "", strMsg, "RxLockingQuestion", 0), strAns, k
      If strAns = "N" Or k.escd Then
         blnOK = False
      Else
         blnOK = True
         WriteLogSQL LogMsg, "PrescriptionLockOverride", 0, 0
      End If
      
      
   Else
      If GetField(rsLock!sessionID) = g_SessionID Then
         blnOK = True 'There is a lock - it is ours !
      Else
         'Geuine lock from another identifiable source
         'strMsg = "Could not lock Prescription " & crlf &
         'strMsg ="Prescription is currently locked by User " & RtrimGetField(rsLock!User) & " on Terminal " & RtrimGetField(rsLock!terminal)
         'strMsg = "Could not lock Prescription " & crlf &
         strMsg = "Warning - " & RtrimGetField(rsLock!User) & " on Terminal " & RtrimGetField(rsLock!terminal) & " is already dispensing this prescription."
         
         'popmessagecr "ASCribe", strMsg
         LogMsg = strMsg
         strMsg = strMsg & crlf & crlf & "Do you wish to continue?"
         askwin "!EMIS Health", TxtD(dispdata$ & "\patmed.ini", "", strMsg, "RxLockingQuestion", 0), strAns, k
         If strAns = "N" Or k.escd Then
            blnOK = False
         Else
            blnOK = True
            'Now we need to log the fact
            WriteLogSQL LogMsg, "PrescriptionLockOverride", 0, 0
         End If
         
      End If
            
   End If
   
   rsLock.Close
   Set rsLock = Nothing
    
   PharmacyPrescriptionLock = blnOK

Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   On Error Resume Next
   rsLock.Close
   Set rsLock = Nothing
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "GetPrescriptionIDbyWPrescription_MergedID" & sErrDesc
End Function
Function PrescriptionCrossCheckEpisode(ByVal RequestID_Prescription As Long, ByVal EpisodeID As Long) As Boolean
'29Jan13 TH TFS 54633 Small wrapper to cross check that a given rx and episode refer to the same patient (lifetime episode)

Dim strParams As String
'Dim rsOrders As ADODB.Recordset
Dim lErrNo        As Long
Dim sErrDesc      As String
Dim lngResult As Long

   PrescriptionCrossCheckEpisode = False

   strParams = gTransport.CreateInputParameterXML("PrescriptionID", trnDataTypeint, 4, RequestID_Prescription) & _
               gTransport.CreateInputParameterXML("EpisodeID", trnDataTypeint, 4, EpisodeID)
   
   lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWPrescriptionAndEpisodeCrossCheck", strParams)
   PrescriptionCrossCheckEpisode = (lngResult = 1)
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "PrescriptionCrossCheckEpisode" & sErrDesc
End Function
Function PharmacyPrescriptionUnLock() As Long
'14Feb13 TH Written.
'This should remove the SessionID from the locking column on the specified table
Dim strParameters As String
Dim lngOK As Long

   On Error Resume Next 'If we dont unlock its bad but not the end of the world, but if we error here it could be as we
                        'could be called within the bounds of a clean up routine. Lesser of two evils is to fail silently and continue.
   If Not (gTransport Is Nothing) Then
   
      lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPharmacyPrescriptionUnlock", "")
   
   End If
   PharmacyPrescriptionUnLock = lngOK

End Function
Function GetMergeIDbyLinkedPrescriptionID(ByVal RequestID As Long) As Long
'22Feb13 TH Written return a prescriptionID from a merged line (TFS 57204)

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler
   strParameters = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID)
   GetMergeIDbyLinkedPrescriptionID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWPrescriptionMergeIDByPrescriptionID", strParameters)

Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "GetMergeIDbyLinkedPrescriptionID" & sErrDesc
End Function

Function GetRequestTypeByChildRequestID(ByVal RequestID_Child As Long) As String
'11Jul11 TH Written return a prescriptionID from a merged line

Dim strParameters As String
Dim rs            As ADODB.Recordset
Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler
   strParameters = gTransport.CreateInputParameterXML("RequestID_Child", trnDataTypeint, 4, RequestID_Child)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pRequestTypeByChildRequestID", strParameters)
   
   If rs.EOF Then
       GetRequestTypeByChildRequestID = ""
   Else
       GetRequestTypeByChildRequestID = rs!RequestType
   End If
   
   rs.Close
   Set rs = Nothing
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "GetRequestTypeByChildRequestID" & sErrDesc
End Function

Sub SiteSpecificRxInfoToPrintHeap(ByVal RequestID_Prescription As Long)
' Added to do site specific Rx printing to heap 29Sep15 XN TFS 77778
' 145005 Fixed printing of chinese name and language on worksheet XN 12Feb15
' 16Apr18 DR Bug 209934 - Dispensing control client error in event log missing sp

Dim rs As ADODB.Recordset
Dim sErrDesc  As String
Dim strParams As String
Dim strItem   As String
Dim strText   As String
Dim field     As ADODB.field

   On Error GoTo ErrorHandler
   Err.Clear
   
   If gTransport.CheckSPExists("pSiteSpecificRxPrinting") Then

       strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
       strParams = strParams & gTransport.CreateInputParameterXML("RequestID_Prescription", trnDataTypeint, 4, RequestID_Prescription)
       strParams = strParams & gTransport.CreateInputParameterXML("RequestID_Child", trnDataTypeint, 4, Null) ' Nothing) XN 12Feb15 145005
       
       Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pSiteSpecificRxPrinting", strParams)
    
       ' Do this manually as if there is no row need empty string to clear print elements
       For Each field In rs.Fields
          strItem = field.name
          If rs.EOF Then
            strText = ""
          Else
            strText = RtrimGetField(field)
          End If
          Heap 10, gPRNheapID, strItem, strText, 0
       Next
   
       rs.Close
       Set rs = Nothing
    
   End If
   
Exit Sub

ErrorHandler:
   Set rs = Nothing
   On Error GoTo 0
End Sub
