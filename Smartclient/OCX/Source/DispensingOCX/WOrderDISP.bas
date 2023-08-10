Attribute VB_Name = "WOrderIO"
'---------------------------------------------------------------
'        wOrderDISP - Order IO layer for Dispensing only
'---------------------------------------------------------------
'17oct08 CKJ Modified wOrderIO for use in the dispensing control
'            End statement cannot be used so raise error instead
'26Jul16 XN  Added EDIProductIdentifier to orderstruct 126634 
'            FillOrdFromRS: read in EDIProductIdentifier for WOrder, and WReconcil 126634
'            PutOrder: Added support for writing EDIProductIdentifier for WOrder, and WReconcil to DB 126634
Option Explicit
DefBool A-Z

'06Aug12 TH replaced from stores (as not kept in sync) - This needs Review as there should be only 1 IO

Type orderstruct
   revisionlevel As String * 2   '03May98 CKJ new version number of the structure
   
   Code As String * 7
   outstanding As String * 13    '03May98 CKJ Y2K was 9
   orddate As String * 8         '03May98 CKJ Y2K ddmmyyyy  was 6
   ordtime As String * 6         '03May98 CKJ Y2K hhmmss    new
   loccode As String * 3
   supcode As String * 5
   status As String * 1
   numprefix As String * 6       '05may98 CKJ added to allow ord.num to be widened
   num As String * 10 '4
   cost As String * 13           '03May98 CKJ Y2K was 6
   pickno As Long
   received As String * 13       '03May98 CKJ Y2K was 6
   recdate As String * 8         '03May98 CKJ Y2K ddmmyyyy  was 6
   rectime As String * 6         '03May98 CKJ Y2K hhmmss    new
   'invnum As String * 12         'also holds retcode for returns
   invnum As String * 20         '01Nov05 TH Extended
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
   pflag As String * 1           '27Jan99 TH price flag for manually entered price
   CreatedUser As String * 3     '01Mar00 TH Added for information
   custordno As String * 12      '18Apr00 CFY Added
   VATAmount As String * 13      '20Oct00 JN Added
   VATRateCode As String * 1     '20Oct00 JN Added
   VATRatePCT As String * 13     '20Oct00 JN Added
   VATInclusive As String * 13   '20Oct00 JN Added
   Indispute As String * 1       '22Nov00 EAC/CY Added
   IndisputeUser As String * 3
   ShelfPrinted As String * 1    '22Apr02 SF added (enh#1555) and decremented pad by 1 (was 758)
   Reconciledate As String * 8     '28Jan04 TH Added for interface requirements (#72647)
   CodingSlipdate As String * 8    '    "
   OrderID As Long
   batchnumber As String * 25    '08Mar07 TH Added
   DeliveryNoteReference As String * 30   '15Aug11 TH Increased again for Notts URS F0084761'19Oct10 XN Increasesed size to 20 (F0098793) (UMMC FINV) '15Oct10 XN reduced to 10 characters to match db (F0098793) (UMMC FINV)  '02Sep10 TH Added for UMMC FINV. This is the docket number from the external receipt docket. (F0054531)
   DLO As Boolean                '29May12 TH Added DLO
   DLOWard As String * 5         '     "
   PSORequestID As Long          '06Aug12 TH Added PSO
   EDIProductIdentifier AS String *15 	'22Jul16 XN Added 126634
End Type                         'total length is now 1024 bytes


Private Const OBJNAME As String = PROJECT & "WOrderIOdisp."


Sub getorder(ByRef ord As orderstruct, ByVal lngOrderID As Long, ByVal intEditType As Integer, ByVal blnLockRecord As Boolean)

'06Aug12 TH replaced from stores (as not kept in sync) - This needs Review as there should be only 1 IO

Dim strMsg As String
Dim strTable As String
Dim rsOrders  As ADODB.Recordset
Dim intLock As Integer
Dim strParams As String
Dim blnOK As Boolean
Dim rsLock As ADODB.Recordset
Dim intCount As Integer
Dim intloop As Integer
Dim strAns As String
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "GetOrder"

   On Error GoTo ErrorHandler
   
   Select Case Abs(intEditType)
      Case 0
         popmessagecr "ERROR", "Edit type not set report to system manager"
      Case 1, 2, 3, 9: strTable = "WOrder"
      Case 4: strTable = "WReconcil"
      Case Else: strTable = "WRequis"
   End Select
   
   
    

   If lngOrderID > 0 Then
      blnOK = True
      If blnOK Then
         'strParams = gTransport.CreateInputParameterXML(strTable & "ID", trnDataTypeint, 4, lngOrderID)
         'Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "p" & strTable, strParams)
         'If Not rsOrders.EOF Then ord = FillOrdFromRS(rsOrders, strTable)
         'Set rsOrders = Nothing
         If blnLockRecord Then 'Stop            '!!** Need locking hint here
            'OPEN TRANSACTION
            If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
               blnOK = False
               If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLockingStandard", 0)) Then
                  gTransportConnectionExecute "Begin Transaction"	'10Aug12 CKJ
               End If
               Do While Not blnOK
                  intCount = 0
                  Set rsLock = TableRowLock(strTable, lngOrderID, g_SessionID)
                  If rsLock.EOF Or rsLock.RecordCount > 1 Then
                     Do While gTransportIsInTransaction(g_SessionID)	'10Aug12 CKJ
                        'Here are going to rollback ay outstanding transactions prior to msg display
                        'We keep a count so we can reinstitute them
                        If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction"	'10Aug12 CKJ
                        intCount = intCount + 1
                     Loop
                     strMsg = "Could not lock " & strTable & " Record Number " & CStr(lngOrderID) & crlf & "Reason Unknown" & _
                              crlf & crlf & "OK to Retry ? (No Will exit Application)"
                     strAns = "Y"
                     popmsg "EMIS Health", strMsg, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, strAns, k.escd
                     If strAns = "N" And Not k.escd Then
                        'Exit App
                        GoTo CloseApplication
                     Else
                        blnOK = False
                     End If
                  Else
                     If GetField(rsLock!sessionID) = g_SessionID Then
                        blnOK = True 'There is a lock - it is ours !
                     Else
                     'Geuine lock from another identifiable source
                        Do While gTransportIsInTransaction(g_SessionID)	'10Aug12 CKJ
                           'Here are going to rollback ay outstanding transactions prior to msg display
                           'We keep a count so we can reinstitute them
                           If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction"	'10Aug12 CKJ
                           intCount = intCount + 1
                        Loop
                        strMsg = "Could not lock " & strTable & " Record Number " & CStr(lngOrderID) & crlf & _
                                 "Record is currently locked by User " & RtrimGetField(rsLock!User) & " on Terminal " & RtrimGetField(rsLock!terminal) & _
                                 crlf & crlf & "OK to Retry ? (No will exit " & App.EXEName & ")"
                        strAns = "Y"
                        popmsg "EMIS Health", strMsg, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, strAns, k.escd
                        If strAns = "N" And Not k.escd Then
                           'Exit App
                           ErrNumber = -8000
                           ErrDescription = "User Requested Close after Locked Record Encountered"
                           GoTo CloseApplication
                        Else
                           blnOK = False
                        End If
                     
                     End If
                  
                  End If
                  
                  If Not blnOK Then
                     'Restore any Transactions from before rollbacks for any modal display
                     For intloop = 1 To intCount
                        gTransportConnectionExecute "Begin Transaction"	'10Aug12 CKJ
                     Next
                     
                  End If
               Loop
            
            Else
            
               blnOK = False
               Do While Not blnOK
                  'blnOK = gTransport.GetRowLock(g_SessionID, strTable, ord.OrderID) '21Oct04 TH Testage
                  gTransportConnectionExecute "Begin Transaction"	'10Aug12 CKJ
                  blnOK = gTransport.GetRowLock(g_SessionID, strTable, lngOrderID) '21Oct04 TH Testage
                  If Not blnOK Then
                     gTransportConnectionExecute "RollBack Transaction"                          '06Jan06 TH Moved from below msgbox call	'10Aug12 CKJ
                     popmessagecr "", "Waiting to lock " & strTable & " record. Press OK to retry" '           Converted from msgbox
                  End If
               Loop
            End If
         End If
         '24Oct05 TH Moved read here INSIDE the lock !!!
         strParams = gTransport.CreateInputParameterXML(strTable & "ID", trnDataTypeint, 4, lngOrderID)
         Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "p" & strTable, strParams)
         If Not rsOrders.EOF Then ord = FillOrdFromRS(rsOrders, strTable)
         Set rsOrders = Nothing
         
         If InStr(UCase$(Command$), "/DEBUG") Then
            strMsg = "ord.code =" & ord.Code & cr
            strMsg = strMsg & "ord.outstanding =" & ord.outstanding & cr
            strMsg = strMsg & "ord.orddate = " & ord.orddate & cr
            strMsg = strMsg & "ord.loccode = " & ord.loccode & cr
            strMsg = strMsg & "ord.supcode = " & ord.supcode & cr
            strMsg = strMsg & "ord.status = " & ord.status & cr
            strMsg = strMsg & "ord.num = " & ord.num & cr
            strMsg = strMsg & "ord.cost = " & ord.cost & cr
            strMsg = strMsg & "ord.pickno = " & Str$(ord.pickno) & cr
            strMsg = strMsg & "ord.received = " & ord.received & cr
            strMsg = strMsg & "ord.recdate = " & ord.recdate & cr
            strMsg = strMsg & "ord.invnum = " & ord.invnum & cr
            strMsg = strMsg & "ord.paydate = " & ord.paydate & cr
            strMsg = strMsg & "ord.qtyordered = " & ord.qtyordered & cr
            strMsg = strMsg & "ord.urgency = " & ord.urgency & cr
            strMsg = strMsg & "ord.tofollow = " & ord.tofollow & cr
            strMsg = strMsg & "ord.internalsiteno = " & ord.internalsiteno & cr
            strMsg = strMsg & "ord.internalmethod = " & ord.internalmethod & cr
            popmessagecr "DEBUG", strMsg
         End If
      End If
   Else
      popmessagecr "ERROR", "Asked for order " + Str$(lngOrderID) + Chr$(13) + "Report to system manager"
      ''End
   End If
   

Cleanup:
   On Error Resume Next
   Set rsOrders = Nothing
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Sub

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

CloseApplication:
On Error Resume Next                  'SQL If there has been an error then we should try and roll back to unlock any record.
   Do While gTransportIsInTransaction(g_SessionID)	'10Aug12 CKJ
      'Here are going to rollback any outstanding transactions prior to unloading completely
      If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction"	'10Aug12 CKJ
   Loop
   If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
      UnlockDatabase g_SessionID
   End If
   'Now we have cleaned up the database we are ready to clean up and close
   'We will call a closedown routine that can be different for each app type using this library
   PutRecordFailure ErrNumber, ErrDescription
   On Error GoTo 0

End Sub
Public Function FillOrdFromRS(ByVal rsOrder As ADODB.Recordset, strTable As String) As orderstruct

'06Aug12 TH replaced from stores (as not kept in sync) - This needs Review as there should be only 1 IO
'26Jul16 XN read in EDIProductIdentifier for WOrder, and WReconcil 126634

Dim ord As orderstruct

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "FillOrdFromRS"


blankorder ord
If Not rsOrder.EOF Then
   On Error Resume Next
   With ord
      .Code = rsOrder.Fields("code")
      .CodingSlipdate = rsOrder.Fields("CodingSlipdate")
      .convfact = rsOrder.Fields("convfact")
      .cost = rsOrder.Fields("cost")
      .CreatedUser = rsOrder.Fields("CreatedUser")
      .custordno = rsOrder.Fields("custordno")
      .Description = rsOrder.Fields("description")
      .Indispute = rsOrder.Fields("Indispute")
      .IndisputeUser = rsOrder.Fields("IndisputeUser")
      .internalmethod = rsOrder.Fields("internalmethod")
      .internalsiteno = rsOrder.Fields("internalsiteno")
      .invnum = rsOrder.Fields("invnum")
      .IssueUnits = rsOrder.Fields("IssueUnits")
      .loccode = rsOrder.Fields("loccode")
      .numprefix = rsOrder.Fields("numprefix")
      .orddate = rsOrder.Fields("orddate")
      .ordtime = rsOrder.Fields("ordtime")
      .outstanding = rsOrder.Fields("outstanding")
      .paydate = rsOrder.Fields("paydate")
      .pflag = rsOrder.Fields("pflag")
      .pickno = rsOrder.Fields("pickno")
      .qtyordered = rsOrder.Fields("qtyordered")
      .recdate = rsOrder.Fields("recdate")
      .received = rsOrder.Fields("received")
      .Reconciledate = rsOrder.Fields("Reconciledate")
      .rectime = rsOrder.Fields("rectime")
      .revisionlevel = rsOrder.Fields("revisionlevel")
      .ShelfPrinted = rsOrder.Fields("ShelfPrinted")
      .status = rsOrder.Fields("Status")
      .Stocked = rsOrder.Fields("Stocked")
      .supcode = rsOrder.Fields("supcode")
      .suppliertype = rsOrder.Fields("suppliertype")
      .tofollow = rsOrder.Fields("tofollow")
      .urgency = rsOrder.Fields("urgency")
      .VATAmount = rsOrder.Fields("VATAmount")
      .VATInclusive = rsOrder.Fields("VATInclusive")
      .VATRateCode = rsOrder.Fields("VATRateCode")
      .VATRatePCT = rsOrder.Fields("VATRatePCT")
      Select Case strTable
         Case "WOrder"
            .OrderID = rsOrder.Fields("WOrderID")
            .num = Format$(rsOrder.Fields("num"))
			.EDIProductIdentifier = GetField(rsOrder.Fields("EDIProductIdentifier"))		' 22Jul16 XN added 126634 	
         Case "WRequis"
            .OrderID = rsOrder.Fields("WRequisID")
            .num = Format$(rsOrder.Fields("RequisitionNum"))
			.EDIProductIdentifier = ""														' 22Jul16 XN added 126634 
         Case "WReconcil"
            .OrderID = rsOrder.Fields("WReconcilID")
            .num = Format$(rsOrder.Fields("num"))
			.EDIProductIdentifier = GetField(rsOrder.Fields("EDIProductIdentifier"))		' 22Jul16 XN added 126634 	
      End Select
      .DeliveryNoteReference = Format$(rsOrder.Fields("DeliveryNoteReference"))  '02Sep10 TH Added for Delivery note capture (UMMC FINV)
      .DLO = rsOrder.Fields("DLO")              '29May12 TH DLO
      .DLOWard = rsOrder.Fields("DLOWard")      '    "
      .PSORequestID = rsOrder.Fields("PSORequestID")  '06Aug12 TH Added
      
      On Error GoTo 0
      End With
End If
FillOrdFromRS = ord

Cleanup:
   'On Error Resume Next
   '
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
End Function
Public Function PutOrder(ord As orderstruct, lngOrderID As Long, strTable As String) As Long

'06Aug12 TH replaced from stores (as not kept in sync) - This needs Review as there should be only 1 IO
'26Jul16 XN Added support for writing EDIProductIdentifier for WOrder, and WReconcil to DB 126634

Dim rsOrder As ADODB.Recordset
'Dim gTransport    As clsDataAccess
Dim strSql As String
Dim lngReturn As Long
Dim ErrNumber As Long, ErrDescription As String
Dim success As Boolean
Dim intloop As Integer
Const ErrSource As String = "PutOrder"

   success = False

   On Error GoTo ErrorHandler
   If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) And lngOrderID > 0 Then '03Jan06 TH Added check on lngOrderID as we wont be in transaction if this is new rec
      If Not TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLockingStandard", 0)) Then gTransportConnectionExecute "begin Transaction"	'10Aug12 CKJ
   End If

   If InStr(UCase$(Command$), "/ORDERDEBUG") Then poporder ord, "To " + dispdata$ + " rec" + Str$(lngOrderID)
   ''Set gTransport New clsDataAccess
         
   With ord
      strSql = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, .Code) & _
               gTransport.CreateInputParameterXML("convfact", trnDataTypeVarChar, 5, .convfact) & _
               gTransport.CreateInputParameterXML("cost", trnDataTypeVarChar, 13, .cost) & _
               gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, .CreatedUser) & _
               gTransport.CreateInputParameterXML("custordno", trnDataTypeVarChar, 12, .custordno) & _
               gTransport.CreateInputParameterXML("description", trnDataTypeVarChar, 56, .Description) & _
               gTransport.CreateInputParameterXML("Indispute", trnDataTypeVarChar, 1, .Indispute) & _
               gTransport.CreateInputParameterXML("IndisputeUser", trnDataTypeVarChar, 3, .IndisputeUser) & _
               gTransport.CreateInputParameterXML("internalmethod", trnDataTypeVarChar, 1, .internalmethod) & _
               gTransport.CreateInputParameterXML("internalsiteno", trnDataTypeVarChar, 3, .internalsiteno) & _
               gTransport.CreateInputParameterXML("invnum", trnDataTypeVarChar, 20, .invnum) & _
               gTransport.CreateInputParameterXML("IssueUnits", trnDataTypeVarChar, 5, .IssueUnits) & _
               gTransport.CreateInputParameterXML("loccode", trnDataTypeVarChar, 3, .loccode)
      If strTable = "WRequis" Then     '24Oct05 TH The damned requistion number aint a number !!!!!
         strSql = strSql & gTransport.CreateInputParameterXML("RequisitionNum", trnDataTypeVarChar, 10, .num)
      Else
         strSql = strSql & gTransport.CreateInputParameterXML("num", trnDataTypeint, 4, Val(.num))
      End If
      strSql = strSql & gTransport.CreateInputParameterXML("numprefix", trnDataTypeVarChar, 6, .numprefix) & _
               gTransport.CreateInputParameterXML("orddate", trnDataTypeVarChar, 8, .orddate) & _
               gTransport.CreateInputParameterXML("ordtime", trnDataTypeVarChar, 6, .ordtime) & _
               gTransport.CreateInputParameterXML("outstanding", trnDataTypeVarChar, 13, .outstanding) & _
               gTransport.CreateInputParameterXML("paydate", trnDataTypeVarChar, 8, .paydate) & _
               gTransport.CreateInputParameterXML("pflag", trnDataTypeVarChar, 1, .pflag) & _
               gTransport.CreateInputParameterXML("pickno", trnDataTypeint, 4, .pickno) & _
               gTransport.CreateInputParameterXML("qtyordered", trnDataTypeVarChar, 13, .qtyordered) & _
               gTransport.CreateInputParameterXML("recdate", trnDataTypeVarChar, 8, .recdate) & _
               gTransport.CreateInputParameterXML("received", trnDataTypeVarChar, 13, .received)

      strSql = strSql & gTransport.CreateInputParameterXML("Reconciledate", trnDataTypeVarChar, 8, .Reconciledate) & _
                        gTransport.CreateInputParameterXML("rectime", trnDataTypeVarChar, 6, .rectime) & _
                        gTransport.CreateInputParameterXML("revisionlevel", trnDataTypeVarChar, 2, .revisionlevel) & _
                        gTransport.CreateInputParameterXML("ShelfPrinted", trnDataTypeVarChar, 1, .ShelfPrinted) & _
                        gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, .status) & _
                        gTransport.CreateInputParameterXML("Stocked", trnDataTypeVarChar, 1, .Stocked) & _
                        gTransport.CreateInputParameterXML("supcode", trnDataTypeVarChar, 5, .supcode) & _
                        gTransport.CreateInputParameterXML("suppliertype", trnDataTypeVarChar, 1, .suppliertype) & _
                        gTransport.CreateInputParameterXML("tofollow", trnDataTypeVarChar, 1, .tofollow) & _
                        gTransport.CreateInputParameterXML("urgency", trnDataTypeVarChar, 1, .urgency) & _
                        gTransport.CreateInputParameterXML("VATAmount", trnDataTypeVarChar, 13, .VATAmount) & _
                        gTransport.CreateInputParameterXML("VATInclusive", trnDataTypeVarChar, 13, .VATInclusive) & _
                        gTransport.CreateInputParameterXML("VATRateCode", trnDataTypeVarChar, 1, .VATRateCode) & _
                        gTransport.CreateInputParameterXML("VATRatePCT", trnDataTypeVarChar, 13, .VATRatePCT) & _
                        gTransport.CreateInputParameterXML("CodingSlipDate", trnDataTypeVarChar, 8, .CodingSlipdate)

      strSql = strSql & gTransport.CreateInputParameterXML("DeliveryNoteReference", trnDataTypeVarChar, 30, .DeliveryNoteReference) '15Aug11 TH Increased again for Notts URS F0084761 '19Oct10 XN Increased size to 20 chars (F0098792) (UMMC FINV) '15Oct10 XN Updated length to 10 to match db (F0098792) (UMMC FINV) '02Sep10 TH Added (UMMC FINV) (F0054531)
      '29May12 TH DLO Added '06Aug12 TH Added PSO
      strSql = strSql & gTransport.CreateInputParameterXML("DLO", trnDataTypeBit, 1, .DLO) & _
                        gTransport.CreateInputParameterXML("DLOWard", trnDataTypeVarChar, 5, .DLOWard) & _
                        gTransport.CreateInputParameterXML("PSORequestID", trnDataTypeint, 4, .PSORequestID) & _
						gTransport.CreateInputParameterXML("EDIProductIdentifier", trnDataTypeVarChar, 15, .EDIProductIdentifier)	' 22Jul16 XN added 126634 
   End With
      
   
   If lngOrderID = 0 Then
      '10Aug12 CKJ gTransport.Connection.Execute "begin Transaction"
      lngReturn = gTransport.ExecuteInsertSP(g_SessionID, strTable, strSql)
      '10Aug12 CKJ gTransport.Connection.Execute "Commit Transaction"
      '''success = True 'No Locking handling on insert !!
   Else
      strSql = gTransport.CreateInputParameterXML("WOrderID", trnDataTypeint, 4, lngOrderID) & strSql
      
      If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
         '10Aug12 CKJ gTransport.Connection.Execute "begin Transaction"
         lngReturn = gTransport.ExecuteUpdateCustomSP(g_SessionID, "p" & strTable & "UpdateUnderLock", strSql)
         '10Aug12 CKJ gTransport.Connection.Execute "Commit Transaction"
         If lngReturn = -1000 Then
         'This is the return flag to indicate that the lock has expired
            Err.Number = -1000
            Err.Description = "Row Lock Failure"
            GoTo ErrorHandler
         End If
      Else
         '10Aug12 CKJ gTransport.Connection.Execute "begin Transaction"
         lngReturn = gTransport.ExecuteUpdateSP(g_SessionID, strTable, strSql)
         '10Aug12 CKJ gTransport.Connection.Execute "Commit Transaction"
      End If
      
      If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then TableRowUnLock strTable, lngOrderID, g_SessionID
      success = True
   End If
            
  
   
Cleanup:
   If success Then
      gTransportConnectionExecute "Commit Transaction"	'10Aug12 CKJ
   Else
      '???/what do we do here ? Hmmm
      If lngOrderID > 0 Then 'We tried an update and failed
      MsgBox "Could not save changes to " & strTable & " Record"
      WriteLog dispdata$ & "\locking.txt", SiteNumber, UserID$, "Could not save changes to product " & d.SisCode
      gTransportConnectionExecute "RollBack Transaction"	'10Aug12 CKJ
      End If
   End If
   On Error Resume Next
   gTransportConnectionExecute "Rollback Transaction"     '10aug12 CKJ was    gTransport.Connection.RollbackTrans
   PutOrder = lngReturn
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   
   ErrNumber = Err.Number
   ErrDescription = Err.Description
   
   On Error Resume Next                  'SQL If there has been an error then we should try and roll back to unlock any record.
   Do While gTransportIsInTransaction(g_SessionID)	'10Aug12 CKJ
   'For intloop = 1 To 5 '08Dec05 TH
      'Here are going to rollback ay outstanding transactions prior to unloading completely
      If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction"	'10Aug12 CKJ
   Loop
   If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
      UnlockDatabase g_SessionID
   End If
   'Next
   'No we have cleaned up the database we are ready to clean up and close
   'We will call a closedown routine that can be different for each app type using this library
   PutRecordFailure ErrNumber, ErrDescription
   On Error GoTo 0
'Resume Cleanup '12Dec05 TH Superfluous now as we are not going anywhere from here

End Function
Public Function CalculateWOrderValue(ByVal strSupplierCode As String) As String
'19May05 TH Written. Used to calculate the total cost of an order for a given supplier
'           (in amend screen only, status 1)

Dim strParams As String
Dim rsOrders As ADODB.Recordset
Dim totalCost As Double
Dim cost As Double
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "CalculateWOrderValue"

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
   gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, strSupplierCode)
   
   Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderValue", strParams)
   
   If Not rsOrders Is Nothing Then     'use returned recordset
      If rsOrders.State = adStateOpen Then
         If rsOrders.RecordCount <> 0 Then
            rsOrders.MoveFirst
            Do While Not rsOrders.EOF
               If Trim$(UCase$(RtrimGetField(rsOrders!pflag))) = "M" Then
                  cost = Val(RtrimGetField(rsOrders!cost))
               Else
                  If Val(RtrimGetField(rsOrders!contprice)) <> 0 Then
                     cost = Val(RtrimGetField(rsOrders!contprice))
                  Else
                     If UCase$(RtrimGetField(rsOrders!sisstock)) = "N" And (Val(RtrimGetField(rsOrders!sislistprice)) > 0) Then
                        cost = Val(RtrimGetField(rsOrders!sislistprice))
                     Else
                        cost = Val(RtrimGetField(rsOrders!IssueCost))
                     End If
                  End If
               End If
               totalCost = totalCost + (cost * Val(RtrimGetField(rsOrders!Qty)))
               rsOrders.MoveNext
            Loop
         End If
      End If
   End If
   CalculateWOrderValue = Format$(totalCost / 100, "0.00")
Cleanup:
   On Error Resume Next
   rsOrders.Close
   Set rsOrders = Nothing
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

CalculateWOrderValueErr:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
End Function
Public Function InvoicableOrder(ByVal lngOrderNum As Long, ByVal blnInvoice As Boolean) As Boolean
'14Nov05 TH Small wrapper to check if a given order line exists
Dim strParams As String
Dim rsOrders As ADODB.Recordset

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "4") & _
               gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
               gTransport.CreateInputParameterXML("num", trnDataTypeint, 4, lngOrderNum) & _
               gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, "") & _
               gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
               gTransport.CreateInputParameterXML("Maxrow", trnDataTypeint, 4, 0)
   If blnInvoice Then
      Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCriteriaINVOICESlimline", strParams)
   Else
      Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCriteriaCREDITSlimline", strParams)
   End If
   
   InvoicableOrder = (rsOrders.RecordCount > 0)
   rsOrders.Close
   Set rsOrders = Nothing

End Function
Public Function CheckBatchReconcilReceipts(ByVal lngOrderNum As Long, ByVal strNSVCode As String, ByVal blnInvoice As Boolean) As Long
'14Nov05 TH Small wrapper to check if a given order line exists
Dim strParams As String
'Dim rsOrders As ADODB.Recordset
Dim lngResult As Long

   CheckBatchReconcilReceipts = 0

   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "4") & _
               gTransport.CreateInputParameterXML("num", trnDataTypeint, 4, lngOrderNum) & _
               gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, strNSVCode)
   'If blnInvoice Then
      lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWReconcilMaxIDbySiteNumandCode", strParams)
   'Else
   '   Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCriteriaCREDITSlimline", strParams)
   'End If
   'If Not rsOrders.EOF Then
      CheckBatchReconcilReceipts = lngResult
   'End If
   'rsOrders.Close
   'Set rsOrders = Nothing
End Function

