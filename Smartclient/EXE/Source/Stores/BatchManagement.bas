Attribute VB_Name = "BatchManagement"
'30Oct06 TH  Written.
'10Nov16 TH  ReportExpiredBatches: Mods to use local file for crystal exported from DB NOT file share version (Hosted) TFS 157972
'14Nov16 TH  ReportExpiredBatches: Added new section to get reports from the DB (TFS 157972)
'06Dec16 TH  ReportExpiredBatches: Make sure we are going to load the report successfully (TFS 170866)
'06Jan17 TH  ReportExpiredBatches: Conversion of RTF to DB (Hosted)
'19Jan17 TH  ReportExpiredBatches: Better msg for missing report - was refering to ward lists ?(TFS 173912)

Option Explicit
DefInt A-Z

Const modulename$ = "BatchManagement.BAS"

Sub BatchManagementMain()
'30Oct06 TH Written. This is the main gateway to batch management processes
'It is for limited functionality (v8 port) in 9.8 - will be expanded/rewritten
'in due course

'Here we present a simple option box for the user to select the batch option

Dim strAns As String

frmoptionset -1, "Batch Management Utilities" '10Aug05 TH (#81783)
         frmoptionset 1, "Remove Zero Qty Batches"
         frmoptionset 1, "Report Expired Batches"
         frmoptionset 1, "Book Out Expired Batches"
         frmoptionshow "1", strAns
         frmoptionset 0, ""

         If Trim$(strAns) <> "" Then
            Select Case Val(strAns)
               Case 1: DeleteZeroStockBatches
               Case 2: ReportExpiredBatches
               Case 3: BookOutExpiredBatches
            End Select
         End If
      
        
End Sub

Sub DeleteZeroStockBatches()
'30Dec98 CFY Written
'            Removes records from the BatchStockLevel table in formula.mdb that have a qty value
'            of < 0.0000001. The table is locked with 'Deny Write' during the process.


Dim lngBatches As Long
Dim RecordsDeleted%
'Dim sql$, msg$, ans$
Dim strMsg As String
Dim strAns As String
Dim strParams As String
Dim lngResult As Long


   askwin "?EMIS Health", "Are you sure you wish to remove batches with zero stock levels ?", strAns, k
   If strAns = "Y" Then
      On Error GoTo RemoveZeroStock_Err
      
      
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
      
      lngBatches = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWBatchStockLevelforZeroQty", strParams)
     
      If lngBatches > 0 Then
         Screen.MousePointer = HOURGLASS
         lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWBatchStockLevelDeleteforZeroQty", strParams)
         Screen.MousePointer = STDCURSOR
         popmessagecr "", Format$(lngResult) & " record(s) deleted from the database"
         
      Else
         Screen.MousePointer = STDCURSOR
         popmessagecr "", "No records to delete"
      End If
   End If

RemoveZeroStock_Exit:
   Screen.MousePointer = STDCURSOR
   
Exit Sub

RemoveZeroStock_Err:
   strMsg = "Operation unsuccesful. The following error has occured:" & crlf
   strMsg = strMsg & "Error No. : " & Format$(Err) & crlf
   strMsg = strMsg & Error$
   popmessagecr ".EMIS Health", strMsg
GoTo RemoveZeroStock_Exit           '!!**

End Sub
Sub ReportExpiredBatches()
'20Jan99 CFY Written
'30Oct00 AW  changed wording passed to inputwin
'21Nov05 PJC Explicitly open and close the database around the report to
'            remove "database engine has already been initialized" error in BookOutExpiredBatches. (#87021)
'10Nov16 TH  Mods to use local file for crystal exported from DB NOT file share version (Hosted) TFS 157972
'06Jan17 TH  Conversion of RTF to DB (Hosted)
'19Jan17 TH  Better msg for missing report - was refering to ward lists ?(TFS 173912)
'
'Prompts user for a date and launches a crystal report details all batch items
'that will/have expired upto that date.

Dim msg$, parseddate$, ExpiryDate$, valid%
Dim strExpiryDate As String
Dim expdate As DateAndTime
Dim TmpDate#
Dim TmpVar As Variant
Dim DB As Database      '21Nov05 PJC Added (#87021)
Dim strAns As String
Dim strParams As String
Dim dteExpiryDate As Date
Dim rs As ADODB.Recordset
Dim crxApp As CRAXDDRT.Application
Dim crxRpt As CRAXDDRT.Report
Dim strReportName As String
Dim strRTFLayout As String
Dim strContext As String
Dim strRTFTxt As String
Dim strPgHdr As String
Dim strPgItem As String
Dim strPgEnd As String
Dim strTmpFile As String
Dim intTmpFileNo As Integer
Dim strDetailLine As String
Dim dlocal As DrugParameters
Dim intSuccess As Integer '06Jan17 TH Added (Hosted)


   
   valid% = False
   
   today expdate
   DateToString expdate, strExpiryDate
   valid% = False
   Do
      InputWin "Batch Management", "Enter date to report expired batches to", strExpiryDate, k
      Storesparsedate strExpiryDate, parseddate$, "yyyy, mm, dd", valid%
      If Not valid% Then BadDate
   Loop Until valid% Or k.escd
   
   If Not k.escd Then
      On Error GoTo ReportExpiredBatches_Err
      dteExpiryDate = CDate(strExpiryDate)
      TmpDate# = TmpVar
      
      'If TrueFalse(TxtD(dispdata$ & "\winord.ini", "Mediate", "Y", "UseCrystal", 0)) Then         '26Mar10 TH Altered to use correct setting (F0078637)
      If TrueFalse(TxtD(dispdata$ & "\Patmed.ini", "BatchTracking", "Y", "UseCrystal", 0)) Then    '     "
         strReportName = "\expbatch.rpt"
         If TrueFalse(TxtD(dispdata$ & "\winord.ini", "CrystalReports", "Y", "CrystalDBReports", 0)) Then  '14Nov16 TH Added new section to get reports from the DB (TFS 157972)
            strReportName = getCrystalFilefromSQL(strReportName)
            If strReportName = "" Then
               popmessagecr "Error", "Crystal report file " & strReportName & " missing from Database." & Chr$(13) & Chr$(13) & "Cannot Print Expired Batches Report."   '12Jan99 TH
               Exit Sub
            End If
         Else
            If Not fileexists(dispdata$ & strReportName) Then
               'popmessagecr "Error", "Crystal report file " & strReportName & " missing from directory " & dispdata$ & "." & Chr$(13) & Chr$(13) & "Cannot Print Ward Stock Lists."   '12Jan99 TH
               popmessagecr "Error", "Crystal report file " & strReportName & " missing from directory " & dispdata$ & "." & Chr$(13) & Chr$(13) & "Cannot Print Expired Batches Report."   '19Jan17 TH Better msg (TFS 173912)
               Exit Sub
            End If
            strReportName = dispdata$ & strReportName '06Dec16 TH Make sure we are going to load the report successfully (TFS 170866)
         End If
      Else
         strReportName = "\expbatch.rtf"
         GetRTFTextFromDB dispdata$ & strReportName, strRTFTxt, intSuccess '06Jan17 TH Moved here for check
         'If Not fileexists(dispdata$ & strReportName) Then
         If Not intSuccess Then
            'popmessagecr "Error", "rtf report file " & strReportName & " missing from directory " & dispdata$ & "." & Chr$(13) & Chr$(13) & "Cannot Print Ward Stock Lists."   '12Jan99 TH
            'popmessagecr "Error", "rtf report " & strReportName & " missing from database." & Chr$(13) & Chr$(13) & "Cannot Print Ward Stock Lists."   '12Jan99 TH
            popmessagecr "Error", "rtf report " & strReportName & " missing from database." & Chr$(13) & Chr$(13) & "Cannot Print Expired Batches Report."   '19Jan17 TH Better msg (TFS 173912)
            Exit Sub
         End If
      End If
      
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Date", trnDataTypeDateTime, 8, dteExpiryDate)
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWBatchStockLeveltoReportExpiredBatches", strParams)
      rs.Sort = "Expiry" 'Use config setting ?
      
      If TrueFalse(TxtD(dispdata$ & "\Patmed.ini", "BatchTracking", "Y", "UseCrystal", 0)) Then
         Set crxApp = New CRAXDDRT.Application
         'Set crxRpt = crxApp.OpenReport(dispdata$ & strReportName) '10Nov16 TH Replaced with below to use local file (Hosted) TFS 157972
         Set crxRpt = crxApp.OpenReport(strReportName)
         crxRpt.Database.SetDataSource rs
         If TrueFalse(TxtD$(dispdata$ & "\patmed.ini", "BatchTracking", "N", "PreviewReports", 0)) Then
            Dim FormReport As New FrmReport
            FormReport.CRViewer.ReportSource = crxRpt
            FormReport.CRViewer.ViewReport
            'FormReport.CRViewer.PrintReport
            Screen.MousePointer = STDCURSOR
            FormReport.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
            Unload FormReport
            Set FormReport = Nothing
         Else
            crxRpt.PrintOut
            Screen.MousePointer = STDCURSOR
         End If
         Set crxRpt = Nothing
         Set crxApp = Nothing
      Else
         strRTFLayout = strReportName
         strContext = "ExpiredBatches"
         'If fileexists(dispdata$ & "\" & strRTFLayout) Then '06Jan17 TH REmoved - check already done
            'GetTextFile dispdata$ & "\" & strRTFLayout, strRTFTxt, 0
            'GetRTFTextFromDB dispdata$ & "\" & strRTFLayout, strRTFTxt, 0 '06Dec16 TH Replaced (TFS 157969)

            SplitFile strRTFTxt, strPgHdr, strPgItem, strPgEnd
            MakeLocalFile strTmpFile                                                  'Tmp file used to
            intTmpFileNo = FreeFile                                                   'build report
            Open strTmpFile For Binary Access Write Lock Read Write As intTmpFileNo
            
            'Header Info
            'FillHeapSupplierInfo gPRNheapID, sup, success
            'Heap 10, gPRNheapID, "SiteNumber", Trim$(GetField(rs!SiteNumber)), 0
            'Heap 10, gPRNheapID, "StockTakeName", Trim$(GetField(rs!StockTakeName)), 0
               
            ParseItems gPRNheapID, strPgHdr, 0
            Put intTmpFileNo, , strPgHdr
            Do While Not rs.EOF
               'Put relevant info on the heap
               'Heap 10, gPRNheapID, "iDescription", Trim$(temp$), 0
               Heap 10, gPRNheapID, "NSVCode", Trim$(GetField(rs!NSVCode)), 0
               Heap 10, gPRNheapID, "Description", Trim$(GetField(rs!Description)), 0
               Heap 10, gPRNheapID, "BatchNumber", Trim$(GetField(rs!batchnumber)), 0
               Heap 10, gPRNheapID, "Expiry", Trim$(GetField(rs!expiry)), 0
               Heap 10, gPRNheapID, "Qty", Trim$(GetField(rs!Qty)), 0
               BlankWProduct dlocal
               dlocal.SisCode = Trim$(GetField(rs!NSVCode))
               getdrug dlocal, 0, 0, False
               FillHeapDrugInfo gPRNheapID, dlocal, 0
               strDetailLine = strPgItem
               ParseItems gPRNheapID, strDetailLine, 0
               Put intTmpFileNo, , strDetailLine

            
               rs.MoveNext
            Loop
            'If we need a footer put parsable elements here
            ParseItems gPRNheapID, strPgEnd, 0
         
            Put intTmpFileNo, , strPgEnd
            
            'Print and cleanup
            Close intTmpFileNo
            'ParseThenPrint strContext, strTmpFile, 1, 0, False '15Jun11 TH Added parameter (F0088129)
            ParseThenPrint strContext, strTmpFile, 1, 0, False, True '04Jan17 TH Use Local File Parsing (Hosted)
            On Error Resume Next
            Kill strTmpFile
         'End If    '06Jan17 TH Removed
      End If
      On Error GoTo 0
   End If
   
ReportExpiredBatches_Exit:

Exit Sub

ReportExpiredBatches_Err:
   msg$ = "There was a problem running your report." & crlf
   msg$ = msg$ & "Error No. : " & Format$(Err) & crlf
   msg$ = msg$ & Error$
   popmessagecr "!EMIS Health", msg$
GoTo ReportExpiredBatches_Exit            '!!**
   
End Sub

Sub BookOutExpiredBatches()
'20Jan99 CFY Written

'Prompts user for a date and cost centre and books out all batches that have/will
'expire upto that date to the cost centre.
'27Jun00 MMA text in messagebox changed and better error handling (event no 44774)
'17Nov05 PJC Reset the pointer. Translog called with correct drug. (#87021)

Dim valid%, ValidCostCentre%, F&    ' 01Jun02 ALL/ATW
Dim expdate As DateAndTime
Dim sup As supplierstruct
Dim TmpDate#
Dim TmpVar As Variant
Dim snapshotopen%                     '27Jun00 MMA added (event no 44774)
Dim strExpiryDate As String
Dim lngOK As Long
Dim rs As ADODB.Recordset
Dim strMsg As String
Dim strCode As String
Dim dteExpiryDate As Date
Dim strParams As String
Dim foundPtr As Long
Dim lngFound As Long
                  
   today expdate
   DateToString expdate, strExpiryDate
   valid% = False
   
   'Get expiry date from user
   Do
      InputWin "EMIS Health", "Enter date up to which batches will be deleted", strExpiryDate, k
      parsedate strExpiryDate, strExpiryDate, "dd-mmm-yyyy", valid%
      If Not valid% Then BadDate
   Loop Until valid% Or k.escd
             
   If Not k.escd Then
      'Get cost centre from user
      Do
         WardInputWin "EMIS Health", "Enter Cost centre - Shift-F1 for a list of codes.", strCode, k, "1"
         If Not k.escd Then
            getsupplier strCode, 0, lngFound, sup
            If lngFound > 0 Then
               If Not (sup.suppliertype = "W" Or sup.suppliertype = "L") Then
                  popmessagecr "", "Not a valid cost centre"
                  ValidCostCentre% = False
               Else
                  ValidCostCentre% = True
               End If
            Else
               popmessagecr "", "Invalid code"
               ValidCostCentre% = False
               k.escd = True
            End If
         End If
      Loop Until k.escd Or ValidCostCentre%

   'Book out stock to cost centre
   On Error GoTo DeleteExpiredBatches_Err
   If Not k.escd Then
      Screen.MousePointer = HOURGLASS
      dteExpiryDate = CDate(strExpiryDate)
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Date", trnDataTypeDateTime, 8, dteExpiryDate)
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWBatchStockLeveltoReportExpiredBatches", strParams)
      If Not rs.EOF Then rs.MoveFirst
         Do While Not rs.EOF
            F& = 0
            foundPtr& = 0
            BlankWProduct d
            d.SisCode = GetField(rs!NSVCode)
            getdrug d, F&, foundPtr&, False
            If foundPtr& Then
             '!!Need to check what should be written to the translog
               Translog d, F&, UserID$, "", GetField(rs!Qty), "", strCode, "", "X", SiteNumber%, "Y", ""
            End If
            'Delete the record - do this one by one so as to avoid possible failure where many logs are written without any deletion of recs
            lngOK = gTransport.ExecuteDeleteSP(g_SessionID, "WBatchStockLevel", GetField(rs!WBatchStockLevelID))
            rs.MoveNext
         Loop
      End If
      On Error GoTo 0
   End If
       
  
DeleteExpiredBatches_Exit:
   Screen.MousePointer = STDCURSOR
Exit Sub

DeleteExpiredBatches_Err:
   strMsg = "Operation unsuccesful. The following error has occured:" & crlf
   strMsg = strMsg & "Error No. : " & Format$(Err) & crlf
   strMsg = strMsg & Error$
   popmessagecr ".EMIS Health", strMsg
Resume DeleteExpiredBatches_Exit

End Sub
