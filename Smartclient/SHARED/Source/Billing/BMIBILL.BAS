Attribute VB_Name = "BMIBill"
Option Explicit
DefInt A-Z
'10Apr02 ATW
'  Module implementing required functions for BMI billing
'
'  Achieves flexibility by having the bulk of the application logic implemented in SQL code
'  in the 'Pricing' database. You must define a mimimum subset of queries to support billing.
'     Currently the only REQUIRED queries are PackCost and LineCost, but this provides very limited
'     functionality.
'
'  Will also function with a SQL DB connected through a shell MDB. The 'Settings' table MUST remain in the
'     Access Db (not as a link), as issues with MEMO fields seem to prevent strings > 255 chars crossing the
'     SQL link. This also conveniently allows sites to ship their 'billing db' for functional amendment
'     without shipping their whole transaction store.
'

'12Jun02 ATW  BmiBill.bas  : Multiple bugfixes to resolve issues on developmental testing - saving same data multiple times, and 'Returns' not behaving correctly.
'09Aug02 ATW Fixed truncation of fractions in dispfee fields by changing to single

'19Aug02 ATW Commenced invoice printing routines
'              Uses SplitFiles (from ToFollow report et al)
'                 Detail line denoted by [DetailStart] and [DetailEnd] tags.
'20Aug02 ATW Refined display code to fit more lines on screen - adjustment fields (and certain others) can display companion data (their unadjusted values) in the info text, allowing you to remove a line
'29Sep02 ATW Must set Packs Issued field to read only on views - tabbing off it causes rounding inaccuracies. Hard to fix in code.
'07Oct02 ATW i) Added several patient identifiers to Transaction type/table. ii) Changed colour of issue qty to RED on returns.
'07Oct02 ATW Consider this build (V85 b010) to be first functional/release build of this module
'10Oct02 ATW Added dt + product description to transaction lines
'25Nov02 ATW SaveTransaction : fixed "type mismatch" for patients with invalid or absent DOB
'03Jul06 PJC PrintInvoice: Added Printer Context for BMI Patient billing. (#91676)
'18Jan07 PJC PrintInvoice: Removes the local file if it exists (#88777,#49479)
'15Jun09 PJC DoReturn,PrintInvoice: Changed the datatype to Long to handle the return value. RFC F0051718.

'-----------

'10Jan14 TH Ported For new V10 GENERIC BILLING (TFS 77893)
'           Trgetted for release to St Vincents
'           The main changes are that instead of named queries in an accompanying mdb, the system uses a set of
'           none site specific sps (site specific rules can be conditionally written into these sps
'           Previosuly the results of these configurable queries from access would be stored on the heap where they could then be accessed to build up
'           sql that would then be executed directly on the client.
'           This cannot be done in version 10, so the sps can return values into a billing state table which can then be accessed by later sps (in the same logical cascade
'           as supported from the opriginal v8 code. THe original paradigm is not completely generic as implied but is built aound
'           a number of specific billing concepts (BaseCost, LineCost etc.). Indeed some of the Tax values were not properly supported in version 8.
'           With this in mind, if new conceptual billing elements would be required, these would have to be added in code, they are not fully extensible in
'           that regard. Having used the original st Vincents configuration as the main model when porting this functionality
'           some of these draw backs have become apparent. However, the requirements did not allow for a complete rewrite at his
'           stage.
'           Other main differences include handling of invoices (these cannot now be printed automatically) and an "invoice session" per patient (and now site)
'           remains open from appending until such time as the user closes by printing.
'           Whether a patient is billable is more configurable now, but should be largely controlled via the payment flags on the episode.

'08Jan14 TH BmiBillPatient: Added to stop return on rx line - this code is still in but a parallel fix around users using f9/f8 and "I"
'           at the label prompt from an attempt to dispense directly from an rx, means now that the label should be save here
'           so this code should never fire.
'06Jan14 TH CalculateLine: Added new TaxRate read
'08Dec13 TH CheckPatientGetsBilled: Added call to clear Billing State values
'10Dec13 TH CheckPatientGetsBilled:Functionality added to reload the TransactionID for this patient on this session not printed. This
'           "batches" billing transaction lines together onto a single invoice.
'06Dec13 TH ClearBillingState: Written. Clear state in DB associated with generic billing
'10Jan14 TH GetNamedQueryValue: Rewritten to use specific sps ( that should be configured for specific billing requirements). Instead of using the heap
'           to build sql statements for execution, values can be access directly in the sps via the billing state table.
'06Dec13 TH Issue: Push stuff into state here - this is the initial upload. Other things are written directly (and read) from the billing procs. The
'           logical flow is as per version 8.
'02Dec13 TH LineSetUp: Use RequestID_Dispensing
'10Jan14 TH LoadLine: Rewritten to use new v10 transport mechanisms
'10Jan14 TH LoadTransation: Rewritten to use new v10 transport mechanisms
'10Jan10 TH PrintInvoice: Major overhaul for version 10
'02Dec13 TH PrintInvoice: Need to add a picker now as this will only be called via patient printing in v10
'           We will offer the last 10 transactions for printing, so this can in effect be used
'           for limited reprint functionality.
'05Jan14 TH PrintInvoice: Ensure lst box is refreshed properly elsewhere - no over hang (TFS 80849)
'10Dec13 TH PrintInvoiceLine: Removed calculateLine call -this as its already calculated from the DB !!!Otherwise I would just end up having to throw everything up into state
'05Jan14 TH QuesLineGetState: Added Tax Rate and Tax Amount (TFS 81010)
'05Jan14 TH QuesLineSetState: Added Tax Rate and Tax Amount (TFS 81010)
'10Jan14 TH SaveLine: Rewritten to use v10 tranport mechanisms
'10Jan14 TH SaveTransaction: Rewritten to use v10 tranport mechanisms
'02Dec13 TH SaveTransaction: Added further fencepost
'22May14 XN PrintInvoice: Should now just come from DB 88863

'-----------

Const MODULE = "BMIBILL."

Const CANCELLED = True

'''Const DB_OPEN = True
'''Const DB_CLOSE = False

'Transaction heap items '19Aug02 ATW
'''21Nov13 TH These need pusing into state in the DB under session
Const HEAP_TRANCHARGE = "TranCharge"
Const HEAP_TAXTOTAL = "TaxTotal"
Const HEAP_SUBTOTAL = "SubTotal"
Const HEAP_GRANDTOTAL = "GrandTotal"
Const HEAP_ITEMCOUNT = "ItemCount"
Const HEAP_DISCOUNT = "Discount"
Const HEAP_TOTALADJUST = "TotalAdjust"
Const HEAP_LINECOUNT = "LineCount"

'Transaction Line heap Items
'''21Nov13 TH These need pusing into state in the DB under session
Const HEAP_NSVCODE = "NSVCode"
Const HEAP_QTY = "PacksIssued"
Const HEAP_BASECOST = "BaseCost"
Const HEAP_MARKUP = "Markup"
Const HEAP_DISPFEE = "DispFee"
Const HEAP_PACKCOST = "PackCost"
Const HEAP_LINECOST = "LineCost"
Const HEAP_PXID = "PrescriptionID"
Const HEAP_PXBASEID = "BasePrescriptionID"
Const HEAP_PATRECNO = "PatRecNo"
Const HEAP_MINPRICE = "MinPrice"
Const HEAP_PREVLINE = "PrevLine"
Const HEAP_BILLPATIENT = "BillPatient"
Const HEAP_BILLITEM = "BillItem"
Const HEAP_ISSUEQTY = "IssueQty"
Const HEAP_TAXRATE = "TaxRate"
Const HEAP_TAXAMOUNT = "TaxAmount"
Const HEAP_OPENTRANSACTION = "OpenTransaction"
Const HEAP_LABELCOST = "lPatientCost"

Const TWODP = "0.00"

Const NO_QUERY = 2100000000

Const TRANBILL = "TranBill"
Const PATIENTBILLING = "PatientBilling"
Const iniFile = "\PATBILL.INI"

Type BmiTransactionLine
   id As Long           ' Primary key
   TransactionID As Long         ' Foreign key to Transaction
   LabelID As Long
   PrescriptionID As Long        ' "Foreign Key" to prescription
   BasePrescriptionID As Long    '
   NSVCode As String * 7         '
   CreatedInits As String * 3     '12Sep02 ATW moved here from Transaction
   LineCost As Single           ' line cost in £.p
   LineAdjust As Single
   CostAdjust As Single
   PacksIssued As Single        '
   BaseCost As Single           '
   markup As Single             '
   MarkupAdjust As Single       '
   DispFee As Single 'integer            '09Aug02 ATW Fixed truncation of fractions
   DispAdjust As Single 'Integer         '
   TaxRate As Single                    '20Aug02 ATW
   TaxAdjust As Single                     '20Aug02 ATW
   ProductDesc As String * 56             '10Oct02 ATW
   '---------------------------------------
   PackCost As Single         '10Dec13 TH Now needed to persist for invoicing  '  NOT persisted, just used as calcspace
   IssueQty As Single
   PackSize As Integer
   TaxAmount As Single        '10Dec13 TH Now needed to persist for invoicing
End Type

Type BmiTransaction
   id As Long
   PatRecNo As String * 10
   '07Oct02 ATW ________
   caseno As String * 10
   surname As String * 20
   forename As String * 15
   dob As String * 8
   '____________________
   Printed As Boolean
   PrintedDT As Date
   PrintedInits As String * 3
   TransactionCharge As Single
   LineCount As Integer
   TranLine(0 To 50) As BmiTransactionLine
   TotalAdjust As Single
   '______________________________________ Calculation space below
   LineTotal As Single
   TaxTotal As Single
   CreatedDT As Date
End Type
   
Dim m_jdbBilling As Database
Dim m_jdbPricing As Database

Dim m_CurrentTransaction As BmiTransaction
Dim m_intCurrentLine As Integer

Dim m_blnPrevLine As Integer
Dim m_PrevLine As BmiTransactionLine
                                    
Dim m_intControlCount As Integer

Dim m_sngIssueQty As Single
Dim m_blnReturn As Integer

Dim m_strIssueUnit As String

Dim m_blnBillPatient As Integer

' Data items in PATBILL.INI

Const QUES_BASE = 24
Const QUES_BASE_ADJ = 25
Const QUES_MARKUP = 15
Const QUES_MARKUP_ADJ = 26
Const QUES_DISPFEE = 14
Const QUES_DISPFEE_ADJ = 23
Const QUES_PACKSISSUED = 27
Const QUES_PACKCOST = 28
Const QUES_TOTAL = 29
Const QUES_ISSUEQTY = 30
Const QUES_PACKSIZE = 31
Const QUES_PREV_BASE = 32
Const QUES_PREV_MARKUP = 33
Const QUES_PREV_DISPFEE = 34
'19AUg02 ATW
Const QUES_LINETOTAL_ADJUST = 37
Const QUES_TAXRATE = 38
Const QUES_TAXRATE_ADJUST = 39
Const QUES_TAXAMOUNT = 40
                                                                                    


' Views defined in PATBILL.INI
Const VIEW_NOPREVLINE = 4
Const VIEW_PREVLINE = 5

Dim m_intHeap As Integer

'''Private Sub BillingDB(ByVal OpenClose As Integer)
''''  Description :  Provides a reference-counted means of opening/closing the 'billing' db.
''''
''''  Input       :  OpenClose      ;  Boolean integer. DB_OPEN opens, DB_CLOSE closes.
''''
'''Const ROUTINE = "BillingDB"
'''Dim uErr As tErrorState
'''On Error GoTo OpenBillingDB_ErrorHandler:
''''__________________________
'''
'''Static intRefCount As Integer
'''Dim strPath As String
'''
'''   Select Case OpenClose
'''      Case DB_OPEN
'''         If m_jdbBilling Is Nothing Then
'''
'''               strPath = PathParse(GetSetting(PATIENTBILLING, "MDBPathName"))
'''
'''               Set m_jdbBilling = OpenDatabase(strPath)
'''            End If
'''         intRefCount = intRefCount + 1
'''
'''      Case DB_CLOSE
'''         intRefCount = intRefCount - 1
'''         If intRefCount = 0 Then
'''               m_jdbBilling.Close
'''               Set m_jdbBilling = Nothing
'''            End If
'''   End Select
''''__________________________
'''OpenBillingDB_Cleanup:
'''   On Error Resume Next
'''      ' Clean up any object references here
'''   On Error GoTo 0
'''      ProcessError uErr, PROJECT & MODULE & ROUTINE
'''   Exit Sub
''''__________________________ EXIT
'''
''''__________________________ Error handling
'''
'''OpenBillingDB_ErrorHandler:
'''   CaptureErrorState uErr
'''   Resume OpenBillingDB_Cleanup:
''''__________________________ End of Error Handling
'''End Sub

Private Sub FillHeapTransaction(uTran As BmiTransaction)
'  Description :  Fill the pricing heap with the transaction
'
Const ROUTINE = "FillHeapTranasaction"
Dim uErr As tErrorState
On Error GoTo FillHeapTranasactionErrorHandler:
'__________________________

Dim intHeap As Integer

   intHeap = PricingHeap()

   Heap 10, intHeap, HEAP_PATRECNO, Trim$(uTran.PatRecNo), 0
   Heap 10, intHeap, HEAP_TRANCHARGE, Format$(uTran.TransactionCharge, TWODP), 0
   Heap 10, intHeap, HEAP_SUBTOTAL, Format$(uTran.LineTotal, TWODP), 0
   Heap 10, intHeap, HEAP_TAXTOTAL, Format$(uTran.TaxTotal, TWODP), 0
   Heap 10, intHeap, HEAP_GRANDTOTAL, Format$((uTran.LineTotal + uTran.TotalAdjust), TWODP), 0
   Heap 10, intHeap, HEAP_LINECOUNT, CStr(uTran.LineCount), 0
   
   '28Nov13 TH Push to state ?
   

'__________________________
FillHeapTranasactionCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

FillHeapTranasactionErrorHandler:
   CaptureErrorState uErr
   Resume FillHeapTranasactionCleanup:
'__________________________ End of Error Handling

End Sub

Private Function GetNamedQueryValue(ByVal QueryName As String) As Variant
'  Description :  The core routine of this billing module. This allows flexible return of values based on
'                    SQL queries stored in the Settings table. The rule is that the query should return at
'                    least one field of the same name as itself. This will be used as the return value.
'
'                 Settings are fetched on name alone by default, but adding a GetSetting query to the table
'                    (along with other fields to allow differentiation) allows you to cultivate whole sets of logic
'                    for different conditions. Any variable pushed on the heap is available to you and will be parsed
'                    into the SQL executed by this routine.
'
'  Input       :  QueryName      ;  The name of the query to execute
'
'  Output      :  Return         ;  Returns the value of the [QueryName] field in the top row of the returning
'                                      recordset. Queries should be designed to return one row only where possible
'                                   NO_QUERY is returned in the event that QueryName is not defined.
'10Jan14 TH Rewritten to use specific sps ( that should be configured for specific billing requirements). Instead of using the heap
'           to build sql statements for execution, values can be access directly in the sps via the billing state table.


Const ROUTINE = "GetNamedQueryValue"
Dim uErr As tErrorState
On Error GoTo GetNamedQueryValue_ErrorHandler:
'__________________________

Dim strSql As String
'''Dim snpValue As Snapshot
Dim found As Integer
Dim intHeap As Integer
Dim strSPname As String
Dim strResult As String
Dim strParameters As String
Dim xmldoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMElement

''Const SETTING = "<S>"
''Const GET_SETTING = "SELECT [Value] FROM Settings WHERE SettingName ='<S>'"
''Const METASETTING = "GetSetting"

   '''PricingDB DB_OPEN
   
''   intHeap = PricingHeap()
''
''   '''strSql = GET_SETTING
''   strSql = "SELECT [Value] FROM Settings WHERE SettingName ='<S>'"
''   '''replace strSql, SETTING, METASETTING, 0
''   replace strSql, "<S>", "GetSetting", 0
   

   ' Get the query that governs fetching queries  '21Nov - does this ever change ???? - If so why cant we just have a config setting to read an sp name ?
   
   'so we use settings to derive spnames via wconfig, if no wconfig setting then just use original key as sp name (think we should prefix all these defaults
   'SO, Instead of settings table in billing mdb we use sp names in wconfig. Nested sps will need to be enclosed in the sp, not unrolled with individual sql strings
   'I dont believe this would lose any functionality.
   
   

''   Set snpValue = m_jdbPricing.CreateSnapshot(strSql)
''
''   If snpValue.EOF Then
''         strSql = GET_SETTING
''         replace strSql, SETTING, QueryName, 0
''      Else
''         strSql = snpValue!Value
''      End If
''
''   Heap 10, intHeap, SETTING, QueryName, 0
''   ParseItems intHeap, strSql, 0
''
''   ' Get the actual query
''
''   Set snpValue = m_jdbPricing.CreateSnapshot(strSql)
''
''   If snpValue.EOF Then
''         GetNamedQueryValue = NO_QUERY
''         GoTo GetNamedQueryValue_Cleanup
''      End If
''
''   strSql = snpValue!Value
''
''   ParseItems intHeap, strSql, 0

   ' Find the value
   
   '''CALL our SP using sessionID the return
   
   
   strSPname = TxtD(dispdata$ & iniFile, "GenericBillingQueryName", "pPharmacy_GenericBilling_" & QueryName, QueryName, found)
   strSPname = strSPname & TxtD(dispdata$ & iniFile, "GenericBilling", "", "GenericBillingSPSuffix", found) '02Dec13 TH Added configurable suffix on sps
   'Set snpValue = m_jdbPricing.CreateSnapshot(strSql)
   strParameters = gTransport.CreateOutputParameterXML(QueryName, trnDataTypeVarChar, 20)

   strResult = gTransport.ExecuteSelectOutputSP(g_SessionID, strSPname, strParameters)
   
   'str_XML = gTransport.ExecuteSelectOutputSP(g_SessionID, "pStateGet", strParameters)
   Set xmldoc = New MSXML2.DOMDocument
   xmldoc.loadXML strResult
   Set xmlnode = xmldoc.selectSingleNode("//Parameters")
   GetNamedQueryValue = xmlnode.getAttribute(QueryName)
   
   'GetNamedQueryValue = strResult
''   If Not snpValue.EOF Then
''         GetNamedQueryValue = GetField(snpValue.Fields(QueryName))
''      End If

'__________________________
GetNamedQueryValue_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
''      snpValue.Close
''      Set snpValue = Nothing
      '''PricingDB DB_CLOSE
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

GetNamedQueryValue_ErrorHandler:
   CaptureErrorState uErr
   Resume GetNamedQueryValue_Cleanup:
'__________________________ End of Error Handling

End Function

Private Function GetSetting(ByVal Section As String, ByVal i_strSetting As String) As Variant
'  Description :  Encapsulation of TxTD$ for routines in this module using the patbill ini file
'
'  Input       :  Section     ;  The section to poll
'                 Setting     ;  The setting to fetch
'
Const ROUTINE = "GetSetting"
Dim uErr As tErrorState
On Error GoTo GetSettingErrorHandler:
'__________________________

Dim found As Integer

   GetSetting = TxtD(dispdata$ & iniFile, Section, "", i_strSetting, found)

'__________________________
GetSettingCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

GetSettingErrorHandler:
   CaptureErrorState uErr
   Resume GetSettingCleanup:
'__________________________ End of Error Handling

End Function

Private Function Initialize(Patient As patidtype, PatientExtra As PatIDTypeExtra, PatientEpisode As PatIdTypeEpisode) As Variant
'  Description :  Initialises the billing module on beginning billing for a new patient.
'
'  Input       :  Patient        ;  The patient
'                 PatientExtra   ;  The extra struct for this patient
'                 PatientEpisode ;  The episode struct for this patient
'
'  Output      :  Return         ;  Boolean true if succeeds
'
'12Sep02 ATW Moved much of the code off into CheckPatientGetsBilled()

Dim varOpenTransaction As Variant
Dim success As Integer

   If Not m_blnBillPatient Then Exit Function

   'If CheckPatientGetsBilled(Patient, PatientExtra, PatientEpisode) = 0 Then
   '   m_blnBillPatient = False
   '   Exit Function
   'Else
   '   m_blnBillPatient = True
   'End If

   ' Check to see if the patient has a previously open transaction not printed
   varOpenTransaction = GetNamedQueryValue(HEAP_OPENTRANSACTION)

   If Not (varOpenTransaction = NO_QUERY) Then
         If varOpenTransaction <> 0 Then
               ' check with user to soo if we want this old transaction (or just prompt them that it's loaded)
               
               m_CurrentTransaction.id = varOpenTransaction
               success = LoadTransaction(m_CurrentTransaction.id, m_CurrentTransaction)
               popmessagecr "!Flexible Billing Module", "Loaded " & m_CurrentTransaction.LineCount & " uninvoiced issues from previous session."
            End If
      End If

   Initialize = True

End Function

Private Function Issue(i_Drug As DrugParameters, i_Label As WLabel, i_IssueQty As Single) As Variant
'  Description :  Perform the task of determining the pricing for a single issue.
'
'  Input       :  i_Drug         ;  The drug we are issuing
'                 i_Label        ;  The label we are issuing from
'                 i_IssueQty     ;  The quantity to start with
'
'  Output      :  Return         ;  Variant Empty should no mishaps occur, CANCELLED if a UI cancel is used.

'06Dec13 TH Push stuff into state here - this is the initial upload. Other things are written directly (and read) from the billing procs. The
'           logical flow is as per version 8.

Const ROUTINE = "Issue"
Dim uErr As tErrorState
On Error GoTo IssueErrorHandler:
'__________________________

Dim success As Integer
Dim varBillItem As Variant
Dim blnBillItem As Integer
Dim lngTranID As Long

Const SHOWUI = "ShowUI"
Dim blnShowUI As Integer
Dim varShowUI As Variant

Dim intHeap As Integer
Dim lngOK As Long
Dim strParams As String
Dim sglPacksIssued As Single


   intHeap = PricingHeap()

   ' Check for billing for this patient

   If Not m_blnBillPatient Then GoTo IssueCleanup
   
   sglPacksIssued = i_IssueQty / CSng(Val(i_Drug.convfact))
   '06Dec13 Th Push stuff into state here
   strParams = gTransport.CreateInputParameterXML("EntityID_Patient", trnDataTypeint, 4, pid.recno) & _
               gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, i_Drug.SisCode) & _
               gTransport.CreateInputParameterXML("RequestID_Dispensing", trnDataTypeint, 15, i_Label.RequestID) & _
               gTransport.CreateInputParameterXML("PacksIssued", trnDataTypeFloat, 8, sglPacksIssued)
   
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPharmacyGenericBillingStateWriteFromIssue", strParams)
   
   

   ' Check for billing on this item
   
   FillHeapDrugInfo intHeap, i_Drug, 0
   
   varBillItem = GetNamedQueryValue(HEAP_BILLITEM)

   If varBillItem = NO_QUERY Then
         blnBillItem = True
      Else
         blnBillItem = (varBillItem <> 0)
      End If

   If Not blnBillItem Then GoTo IssueCleanup

   FillHeapLabelInfo intHeap, i_Label, success

   m_strIssueUnit = trimz$(i_Drug.PrintformV)

   m_intCurrentLine = NewLine(m_CurrentTransaction)

   LineSetup m_CurrentTransaction.TranLine(m_intCurrentLine), i_Drug, i_Label, i_IssueQty
   
   blnShowUI = TrueFalse(GetSetting(TRANBILL, "ShowUI"))

   varShowUI = GetNamedQueryValue("ShowUI")
   If varShowUI <> NO_QUERY Then
         blnShowUI = (varShowUI <> 0)
      End If

   If blnShowUI Then
         ConstructView dispdata$ & "\Patbill.ini", "Views", "Data", Iff(m_blnPrevLine, VIEW_PREVLINE, VIEW_NOPREVLINE), "", 0, "Costing", m_intControlCount
         
         success = CalculateLine(m_CurrentTransaction.TranLine(m_intCurrentLine))
         
         ' Place the state of the structure into the view
         
         QuesLineSetState m_CurrentTransaction.TranLine(m_intCurrentLine)
      
         QuesCallbackMode = 12
      
         QuesShow m_intControlCount
      
         'Check for cancel
         If Ques.Tag <> "-1" Then
               m_CurrentTransaction.LineCount = m_CurrentTransaction.LineCount - 1
               Issue = CANCELLED
               m_sngIssueQty = 0
               GoTo IssueCleanup
            End If
         
         ' Read the state out
         QuesLineGetState m_CurrentTransaction.TranLine(m_intCurrentLine)
      End If

   success = CalculateLine(m_CurrentTransaction.TranLine(m_intCurrentLine))

   If m_blnReturn Then    '12Jun02 ATW m_blnReturn to save negative qtys
         success = CalculateLine(m_CurrentTransaction.TranLine(m_intCurrentLine))
         NegativizeLine m_CurrentTransaction.TranLine(m_intCurrentLine)
      End If

   ' Stick the cost to the patient
   Heap 10, gPRNheapID%, HEAP_LABELCOST, CStr((m_CurrentTransaction.TranLine(m_intCurrentLine).LineCost) + (m_CurrentTransaction.TranLine(m_intCurrentLine).LineAdjust)), 0

   lngTranID = SaveTransaction(m_CurrentTransaction)

'__________________________
IssueCleanup:
   On Error Resume Next
      ' Clean up any object references here
      Unload Ques
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

IssueErrorHandler:
   CaptureErrorState uErr
   Resume IssueCleanup:
'__________________________ End of Error Handling

End Function

Private Sub LineSetup(uLine As BmiTransactionLine, i_Drug As DrugParameters, i_Label As WLabel, ByVal i_sngIssueQty As Single)
'  Descripion  :  Sets up a new transaction line
'
'  Input       :  i_Drug         ;  The Drug to set up with
'                 i_Label        ;  The label to use
'                 i_sngIssueQty  ;  The issue quantity to use
'
'  Output      :  uLine          ;  Passed line structure is populated
'
'02Dec13 TH Use RequestID_Dispensing

Const ROUTINE = "LineSetup"
Dim uErr As tErrorState
On Error GoTo LineSetupErrorHandler:
'__________________________

Dim success As Integer
Dim uExtra As DrugExtra

Dim varMinPrice As Variant
Dim varPrevLine As Variant

   ''success = GetDrugExtra(i_Drug, uExtra)

   FillHeapDrugExtra PricingHeap(), uExtra
   
   'uLine.LabelID = i_Label
   uLine.LabelID = i_Label.RequestID '02Dec13 TH Added
   uLine.PrescriptionID = i_Label.PrescriptionID
   uLine.BasePrescriptionID = i_Label.BasePrescriptionID
   uLine.CreatedInits = UserID$
   uLine.NSVCode = i_Drug.SisCode
   uLine.LineCost = 0
   uLine.PacksIssued = i_sngIssueQty / CSng(Val(i_Drug.convfact))

   varMinPrice = GetNamedQueryValue(HEAP_BASECOST)
   If varMinPrice <> NO_QUERY Then
         uLine.BaseCost = varMinPrice
      Else
         uLine.BaseCost = (uExtra.RefPrice + uExtra.PriceAdjust)
      End If

   uLine.markup = FetchMarkup(uLine)
   uLine.CostAdjust = 0
   uLine.MarkupAdjust = 0
   uLine.DispFee = FetchDispFee(uLine)
   uLine.DispAdjust = 0

   '10Oct02 ATW added description
   'uLine.ProductDesc = Iff((trimz$(i_Drug.storesdescription) = ""), i_Drug.Description, i_Drug.storesdescription) XN 4Jun15 98073 New local stores description
   uLine.ProductDesc = i_Drug.DrugDescription

   If Val(i_Drug.convfact) <= 0 Then
         popmessagecr ".Transactional Billing", "Pack size MUST be set up and greater than zero on product " & i_Drug.SisCode & cr & "to use it in this context."
         Error 10001
      End If

   uLine.PackSize = CSng(Val(i_Drug.convfact))
   
   uLine.IssueQty = i_sngIssueQty

   ' Check for minimum pricing
   FillHeapTranLine uLine
   
   varMinPrice = GetNamedQueryValue(HEAP_MINPRICE)
   If varMinPrice <> NO_QUERY Then
         uLine.BaseCost = varMinPrice
      End If

   success = False
   varPrevLine = GetNamedQueryValue(HEAP_PREVLINE)
   If varPrevLine <> NO_QUERY Then
         If CLng(varPrevLine) <> 0 Then
               success = LoadLine(CLng(varPrevLine), m_PrevLine)
            End If
      End If
   m_blnPrevLine = success

'__________________________
LineSetupCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

LineSetupErrorHandler:
   CaptureErrorState uErr
   Resume LineSetupCleanup:
'__________________________ End of Error Handling
                       
End Sub

Private Function LoadLine(ByVal id As Long, uLine As BmiTransactionLine) As Integer
'  Description :  Loads a previously stored line from the DB, given its primary key
'
'  Input       :  ID       ;  The primary key
'
'  Output      :  uLine ;  Passed structure is populated
'                 Return   ;  Boolean true if successful, false if not
'
'10Jan14 TH Rewritten to use new v10 transport mechanisms

Const ROUTINE = "LoadLine"
Dim uErr As tErrorState
On Error GoTo LoadLine_ErrorHandler:
'__________________________

Dim strSql As String
Dim snpLine As Snapshot
Dim rsLine As ADODB.Recordset
Dim strParams As String

   
   ''strSql = "SELECT * FROM TransactionLine WHERE ID = " & CStr(id)

   '''BillingDB DB_OPEN
   
   ''Set snpLine = m_jdbBilling.CreateSnapshot(strSql)
   
   strParams = gTransport.CreateInputParameterXML("PharmacyGenericBilling_TransactionLineID", trnDataTypeint, 4, id)
   
   Set rsLine = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyGenericBilling_TransactionLinebyID", strParams)
   
''   If snpLine.EOF Then
''         LoadLine = False
''         GoTo LoadLine_Cleanup
''      End If
      
   If rsLine.EOF Then
      LoadLine = False
      GoTo LoadLine_Cleanup
   Else
   
''   uLine.id = snpLine!id
''   uLine.TransactionID = snpLine!TransactionID
''   uLine.PrescriptionID = snpLine!PrescriptionID
''   uLine.BasePrescriptionID = snpLine!BasePrescriptionID
''   uLine.NSVCode = snpLine!NSVCode
''   uLine.LineCost = snpLine!LineCost
''   uLine.PacksIssued = snpLine!PacksIssued
''   uLine.BaseCost = snpLine!BaseCost
''   uLine.markup = snpLine!markup
''   uLine.CostAdjust = GetField(snpLine!CostAdjust)
''   uLine.MarkupAdjust = GetField(snpLine!MarkupAdjust)
''   uLine.DispFee = snpLine!DispFee
''   uLine.DispAdjust = GetField(snpLine!DispAdjust)
''   uLine.TaxRate = snpLine!TaxRate
''   uLine.TaxAdjust = GetField(snpLine!TaxAdjust)
''   uLine.LineAdjust = GetField(snpLine!LineAdjust)
   
   uLine.id = RtrimGetField(rsLine!PharmacyGenericBilling_TransactionLineID)
   uLine.TransactionID = RtrimGetField(rsLine!PharmacyGenericBilling_TransactionID)
   uLine.PrescriptionID = RtrimGetField(rsLine!PrescriptionID)
   uLine.BasePrescriptionID = RtrimGetField(rsLine!BasePrescriptionID)
   uLine.NSVCode = RtrimGetField(rsLine!NSVCode)
   uLine.LineCost = RtrimGetField(rsLine!LineCost)
   uLine.PacksIssued = RtrimGetField(rsLine!PacksIssued)
   uLine.BaseCost = RtrimGetField(rsLine!BaseCost)
   uLine.markup = RtrimGetField(rsLine!markup)
   uLine.CostAdjust = RtrimGetField(rsLine!CostAdjust)
   uLine.MarkupAdjust = RtrimGetField(rsLine!MarkupAdjust)
   uLine.DispFee = RtrimGetField(rsLine!DispFee)
   uLine.DispAdjust = RtrimGetField(rsLine!DispAdjust)
   uLine.TaxRate = RtrimGetField(rsLine!TaxRate)
   uLine.TaxAdjust = RtrimGetField(rsLine!TaxAdjust)
   uLine.LineAdjust = RtrimGetField(rsLine!LineAdjust)
   '10Dec13 TH Added
   uLine.PackCost = RtrimGetField(rsLine!PackCost)
   uLine.TaxAmount = RtrimGetField(rsLine!TaxAmount)

   LoadLine = True
   End If
'__________________________
LoadLine_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
      snpLine.Close
      Set snpLine = Nothing
      '''BillingDB DB_CLOSE
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

LoadLine_ErrorHandler:
   CaptureErrorState uErr
   Resume LoadLine_Cleanup:
'__________________________ End of Error Handling

End Function

Private Function LoadTransaction(ByVal id As Long, uTran As BmiTransaction) As Integer
'  Description :  Loads a previously stored line from the DB, given its primary key
'
'  Input       :  ID       ;  The primary key
'
'  Output      :  uTran    ;  Passed structure is populated
'                 Return   ;  Boolean true if successful, false if not
'
'10Jan14 TH Rewritten to use new v10 transport mechanisms

Const ROUTINE = "LoadTransaction"
Dim uErr As tErrorState
On Error GoTo LoadTransaction_ErrorHandler:
'__________________________

Dim strSql As String
Dim snpTran As Snapshot
Dim snpLines As Snapshot
Dim success As Integer
Dim intLineCount As Integer
Dim strParams As String
Dim rsTran As ADODB.Recordset
Dim rsTranline As ADODB.Recordset



   'strSql = "SELECT * FROM Transaction WHERE ID = " & CStr(id)

   '''BillingDB DB_OPEN
   
   
''   Set snpTran = m_jdbBilling.CreateSnapshot(strSql)
''
''   If snpTran.EOF Then
''         LoadTransaction = False
''         GoTo LoadTransaction_Cleanup
''      End If

   strParams = gTransport.CreateInputParameterXML("PharmacyGenericBilling_TransactionID", trnDataTypeint, 4, id)
   
   Set rsTran = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyGenericBilling_TransactionbyID", strParams)
   
   If rsTran.EOF Then
      LoadTransaction = False
      GoTo LoadTransaction_Cleanup
   End If
   
   ' Set up the transaction stuff
   ''uTran.id = snpTran!id
   uTran.id = RtrimGetField(rsTran!PharmacyGenericBilling_TransactionID)
   

   ' load the individual lines

   'strSql = "SELECT ID FROM TransactionLine WHERE TransactionID = " & CStr(id)
   
   'Set snpLines = m_jdbBilling.CreateSnapshot(strSql)
   
   Set rsTranline = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyGenericBilling_TransactionLineIDsbyTransactionID", strParams)
   
   If Not rsTranline.EOF Then
      rsTranline.MoveFirst
   ''   Do Until snpLines.EOF
   ''      success = LoadLine(snpLines!id, uTran.TranLine(intLineCount))
   ''      intLineCount = intLineCount + 1
   ''      snpLines.MoveNext
   ''   Loop
      Do Until rsTranline.EOF
         success = LoadLine(RtrimGetField(rsTranline!PharmacyGenericBilling_TransactionLineID), uTran.TranLine(intLineCount))
         intLineCount = intLineCount + 1
         rsTranline.MoveNext
      Loop
   End If
   
   uTran.Printed = RtrimGetField(rsTran!Printed)
   
   uTran.PrintedDT = RtrimGetField(rsTran!PrintedDT)
   uTran.PrintedInits = RtrimGetField(rsTran!PrintedInits)
   uTran.TransactionCharge = RtrimGetField(rsTran!TransactionCharge)

   uTran.CreatedDT = RtrimGetField(rsTran!CreatedDT)
   
   uTran.LineCount = intLineCount

   LoadTransaction = True

'__________________________
LoadTransaction_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
''      snpTran.Close
''      snpLines.Close
''      Set snpTran = Nothing
''      Set snpLines = Nothing
      '''BillingDB DB_CLOSE
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

LoadTransaction_ErrorHandler:
   CaptureErrorState uErr
   Resume LoadTransaction_Cleanup:
'__________________________ End of Error Handling
End Function

Private Sub NegativizeLine(uLine As BmiTransactionLine)
'  Description :  When doing a return, negative values should be assigned for the
'                 releveant quantities.

   uLine.IssueQty = -uLine.IssueQty
   uLine.PacksIssued = -uLine.PacksIssued
   uLine.LineCost = -uLine.LineCost
   uLine.LineAdjust = -uLine.LineAdjust
   uLine.DispFee = -uLine.DispFee
   uLine.DispAdjust = -uLine.DispAdjust

End Sub

Private Function NewLine(Tran As BmiTransaction) As Integer
'  Description :  Creates a new transaction line in the memory space of the passed transaction
'
'  Input       :  Tran        ;  The transaction to expand.
'
'  Output      :  Return      ;  The position of the new line in the transaction
'
Const ROUTINE = "NewLine"
Dim uErr As tErrorState
On Error GoTo NewLine_ErrorHandler:
'__________________________

   Tran.LineCount = Tran.LineCount + 1
   NewLine = Tran.LineCount - 1
   
'__________________________
NewLine_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

NewLine_ErrorHandler:
   CaptureErrorState uErr
   Resume NewLine_Cleanup:
'__________________________ End of Error Handling

End Function

Private Function CalculateLine(uLine As BmiTransactionLine) As Integer
'  Description :  Calculates the transaction line using the SQL stored in the DB.
'
'  Input       :  uLine    ;  udt containing the information from the transactionline
'
'  Output      :  uLine    ;  the line returns amended
'                 Return   ;  returns boolean true if successful.
'
'06Jan14 TH Added new Tax rate read

Const ROUTINE = "CalculateLine"
Dim uErr As tErrorState
On Error GoTo CalculateLine_ErrorHandler:
'__________________________

   uLine.PackCost = FetchPackCost(uLine)
   
   uLine.TaxRate = FetchTaxRate(uLine)  '05Jan14 TH Added

   uLine.TaxAmount = FetchTaxAmount(uLine)

   uLine.LineCost = FetchLineCost(uLine)

   m_sngIssueQty = uLine.IssueQty

   CalculateLine = True
   
'__________________________
CalculateLine_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

CalculateLine_ErrorHandler:
   CaptureErrorState uErr
   Resume CalculateLine_Cleanup:
'__________________________ End of Error Handling
End Function

Private Function CheckPatientGetsBilled(Patient As patidtype, PatientExtra As PatIDTypeExtra, PatientEpisode As PatIdTypeEpisode) As Integer
' Description : Returns boolean true if the patient gets billed. Otherwise, false.
'01Oct02 ATW ; Revised - returns FALSE to carry on, TRUE to back out to ident. Billing switched on-off by YN dialogue, cancel returns to ident
'08Dec13 TH Added call to clear Billing State values
'10Dec13 TH Functionality added to reload the TransactionID for this patient on this session not printed. This
'           "batches" billing transaction lines together onto a single invoice.

Dim intLineCounter As Integer

Dim r As filerecord
Dim varBillPatient As Variant
Dim strReturn As String
Dim strTitle As String

Dim strParams As String
Dim lngReturn As Long

Dim varTransactionCharge As Variant

   r.record = String$(Len(r), Chr(0))

   For intLineCounter = 0 To UBound(m_CurrentTransaction.TranLine)
      LSet m_CurrentTransaction.TranLine(intLineCounter) = r
   Next intLineCounter

   m_CurrentTransaction.id = 0    '12Jun02 ATW clear ID to prevent whole client session using same transaction
   m_CurrentTransaction.PatRecNo = Patient.recno
   m_CurrentTransaction.caseno = Patient.caseno
   m_CurrentTransaction.surname = Patient.surname
   m_CurrentTransaction.forename = Patient.forename
   m_CurrentTransaction.dob = Patient.dob

   varTransactionCharge = GetNamedQueryValue(HEAP_TRANCHARGE)

   If varTransactionCharge <> NO_QUERY Then
         m_CurrentTransaction.TransactionCharge = varTransactionCharge
      End If

   m_CurrentTransaction.LineCount = 0
   m_CurrentTransaction.TotalAdjust = 0
   m_CurrentTransaction.LineTotal = 0
   m_CurrentTransaction.TaxTotal = 0
   m_CurrentTransaction.PrintedInits = "   "

   FillHeapPatientInfo PricingHeap(), Patient, PatientExtra, PatientEpisode, 0
   FillHeapTransaction m_CurrentTransaction
   
   varBillPatient = GetNamedQueryValue(HEAP_BILLPATIENT)

   If Val(varBillPatient) = NO_QUERY Then
         varBillPatient = 1
         m_blnBillPatient = True
         CheckPatientGetsBilled = False
         

      ElseIf varBillPatient = "0" Then
         ' Do nothing
         m_blnBillPatient = False
         CheckPatientGetsBilled = False

      ElseIf Val(varBillPatient) <> 1 Then ' No quibbling
         ' Allow user to define graphical feedback in warning
         If InStr(1, "@?!#", Left$(varBillPatient, 1)) > 0 Then
               strTitle = Left$(varBillPatient, 1)
               varBillPatient = Mid$(varBillPatient, 2)
            End If
         
         strTitle = strTitle & "Billing Module"
         askwin strTitle, CStr(varBillPatient), strReturn, k
         varBillPatient = Iff(TrueFalse(strReturn), 1, 0)
         m_blnBillPatient = (strReturn = "Y")
         CheckPatientGetsBilled = (strReturn = "")
         ClearBillingState
      ElseIf Val(varBillPatient) = 1 Then
         m_blnBillPatient = True
         CheckPatientGetsBilled = False
      End If
      
      If m_blnBillPatient Then
         ClearBillingState '08Dec13 TH
      
      '10Dec13 TH Here reload the TransactionID for this patient on this session not printed
         'We could put a time limit here ???
         strParams = gTransport.CreateInputParameterXML("EntityID_Patient", trnDataTypeint, 4, pid.recno) & _
                     gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
         lngReturn = gTransport.ExecuteSelectReturnSP(g_SessionID, "pPharmacyGenericBillingTransactionOpen", strParams)
         m_CurrentTransaction.id = lngReturn
         '05Jan14 TH Load the transaction here if we have one (TFS )
         lngReturn = LoadTransaction(m_CurrentTransaction.id, m_CurrentTransaction)
         'Not sure we need the msg now.      popmessagecr "!Flexible Billing Module", "Loaded " & m_CurrentTransaction.LineCount & " uninvoiced issues from previous session."
           
      End If
      

End Function

Private Function DoReturn(i_Drug As DrugParameters, i_Label As WLabel, i_ReturnQty As Single) As Variant
'  Description :  Performs a return. Not strictly necessary at present, but useful for amendments in future.
'
'  Input       :  i_Drug      ;  The drug being issued
'                 i_Label     ;  The label being issued frmo
'
'  Output         i_ReturnQty ;  The amount to return

'15Jun09 PJC Changed the datatype to Long to handle the return value. RFC F0051718.

Const ROUTINE = "DoReturn"
Dim uErr As tErrorState
On Error GoTo DoReturnErrorHandler:
'__________________________

'Dim success As Integer     '15Jun09 PJC Changed the datatype to Long to handle the return value. RFC F0051718.
Dim success As Long         '    "

   ' we might want to return something we just put in
   success = SaveTransaction(m_CurrentTransaction)

   '12Jun02 ATW Added m_blnReturn to allow negative qty saving in transactions

   m_blnReturn = True
   DoReturn = Issue(i_Drug, i_Label, i_ReturnQty)
   m_blnReturn = False
'__________________________
DoReturnCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

DoReturnErrorHandler:
   CaptureErrorState uErr
   Resume DoReturnCleanup:
'__________________________ End of Error Handling

End Function

Private Function FetchDispFee(uTranLine As BmiTransactionLine) As Single
'  Description :  Fetch the dispensing fee based on the content of the line
'
'  Input       :  uTranLine      ;  The transaction line
'
'  Output      :  Return         ;  The dispensing fee
'
Const ROUTINE = "FetchDispFee"
Dim uErr As tErrorState
On Error GoTo FetchDispFee_ErrorHandler:
'__________________________

Dim varTemp As Variant

   FillHeapTranLine uTranLine
   
   varTemp = GetNamedQueryValue(HEAP_DISPFEE)

   If varTemp <> NO_QUERY Then
         FetchDispFee = CSng(varTemp)
      End If

'__________________________
FetchDispFee_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

FetchDispFee_ErrorHandler:
   CaptureErrorState uErr
   Resume FetchDispFee_Cleanup:
'__________________________ End of Error Handling

End Function

Private Function FetchLineCost(uTranLine As BmiTransactionLine) As Single
'  Description :  Return the cost of this line in toto
'
'  Input :     uTranLine      ;  The transaction line
'
'  Output:     Return         ;  The cost of this line
'
Const ROUTINE = "FetchLineCost"
Dim uErr As tErrorState
On Error GoTo FetchLineCost_ErrorHandler:
'__________________________

   FillHeapTranLine uTranLine

   FetchLineCost = CSng(GetNamedQueryValue(HEAP_LINECOST))

'__________________________
FetchLineCost_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
      'PricingDB DB_CLOSE
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

FetchLineCost_ErrorHandler:
   CaptureErrorState uErr
   Resume FetchLineCost_Cleanup:
'__________________________ End of Error Handling

End Function

Private Function FetchMarkup(uTranLine As BmiTransactionLine) As Single
'  Description :  Return the markup based on the transaction line
'
Const ROUTINE = "FetchMarkup"
Dim uErr As tErrorState
On Error GoTo FetchMarkup_ErrorHandler:
'__________________________

Dim varTemp As Variant

   FillHeapTranLine uTranLine

   varTemp = GetNamedQueryValue(HEAP_MARKUP)

   If varTemp <> NO_QUERY Then FetchMarkup = CSng(varTemp)

'__________________________
FetchMarkup_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

FetchMarkup_ErrorHandler:
   CaptureErrorState uErr
   Resume FetchMarkup_Cleanup:
'__________________________ End of Error Handling
End Function

Private Function FetchPackCost(uTranLine As BmiTransactionLine) As Single
'  Description :  Return the cost per pack based on the transaction line
'
Const ROUTINE = "FetchPackCost"
Dim uErr As tErrorState
On Error GoTo FetchPackCost_ErrorHandler:
'__________________________

   FillHeapTranLine uTranLine

   FetchPackCost = CSng(GetNamedQueryValue(HEAP_PACKCOST))

'__________________________
FetchPackCost_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

FetchPackCost_ErrorHandler:
   CaptureErrorState uErr
   Resume FetchPackCost_Cleanup:
'__________________________ End of Error Handling
End Function

Private Function FetchTaxAmount(uTranLine As BmiTransactionLine) As Single
'
'  Input       :  uTranLine      ;  The transaction line
'
'  Output      :  Return         ;  The dispensing fee
'
Const ROUTINE = "FetchTaxAmount"
Dim uErr As tErrorState
On Error GoTo FetchTaxAmount_ErrorHandler:
'__________________________

Dim varTemp As Variant

   If uTranLine.TaxRate = 0 Then Exit Function

   FillHeapTranLine uTranLine
   
   
   
   varTemp = GetNamedQueryValue(HEAP_TAXAMOUNT)

   If varTemp <> NO_QUERY Then
         FetchTaxAmount = CSng(varTemp)
      End If

'__________________________
FetchTaxAmount_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

FetchTaxAmount_ErrorHandler:
   CaptureErrorState uErr
   Resume FetchTaxAmount_Cleanup:
'__________________________ End of Error Handling

End Function
Private Function FetchTaxRate(uTranLine As BmiTransactionLine) As Single
'
'  Input       :  uTranLine      ;  The transaction line
'
'  Output      :  Return         ;  The tax rate (%)
'
'06Jan14 T Written in line with other data capture routines (TFS 81010)

Const ROUTINE = "FetchTaxRate"
Dim uErr As tErrorState
On Error GoTo FetchTaxRate_ErrorHandler:
'__________________________

Dim varTemp As Variant

   'If uTranLine.TaxRate = 0 Then Exit Function

   FillHeapTranLine uTranLine
   
   
   
   varTemp = GetNamedQueryValue(HEAP_TAXRATE)

   If varTemp <> NO_QUERY Then
         FetchTaxRate = CSng(varTemp)
      End If

'__________________________
FetchTaxRate_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

FetchTaxRate_ErrorHandler:
   CaptureErrorState uErr
   Resume FetchTaxRate_Cleanup:
'__________________________ End of Error Handling

End Function

Private Sub FillHeapTranLine(uLine As BmiTransactionLine)
'  Description :  Fill the pricing heap with the transaction line
'
Const ROUTINE = "FillHeapTranLine"
Dim uErr As tErrorState
On Error GoTo FillHeapTranLineErrorHandler:
'__________________________

Dim intHeap As Integer
   
   intHeap = PricingHeap()

   Heap 10, intHeap, HEAP_NSVCODE, uLine.NSVCode, 0
   Heap 10, intHeap, HEAP_BASECOST, Format(CStr((uLine.BaseCost + uLine.CostAdjust)), TWODP), 0
   Heap 10, intHeap, HEAP_MARKUP, CStr((uLine.markup + uLine.MarkupAdjust)), 0
   Heap 10, intHeap, HEAP_DISPFEE, Format(CStr(uLine.DispFee + uLine.DispAdjust), TWODP), 0
   Heap 10, intHeap, HEAP_QTY, CStr(uLine.PacksIssued), 0
   Heap 10, intHeap, HEAP_PACKCOST, Format(CStr(uLine.PackCost), TWODP), 0
   Heap 10, intHeap, HEAP_PXID, CStr(uLine.PrescriptionID), 0
   Heap 10, intHeap, HEAP_PXBASEID, CStr(uLine.BasePrescriptionID), 0
   Heap 10, intHeap, HEAP_ISSUEQTY, CStr(uLine.IssueQty), 0
   Heap 10, intHeap, HEAP_TAXRATE, CStr((uLine.TaxRate + uLine.TaxAdjust)), 0
   Heap 10, intHeap, HEAP_TAXAMOUNT, Format(CStr(uLine.TaxAmount), TWODP), 0
   Heap 10, intHeap, HEAP_LINECOST, Format(CStr((uLine.LineCost + uLine.LineAdjust)), TWODP), 0

'__________________________
FillHeapTranLineCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

FillHeapTranLineErrorHandler:
   CaptureErrorState uErr
   Resume FillHeapTranLineCleanup:
'__________________________ End of Error Handling

End Sub

Private Sub PricingDB(ByVal OpenClose As Integer)
''''  Description :  Provides a reference-counted means of opening/closing the 'pricing' db.
''''
''''  Input       :  OpenClose      ;  Boolean integer. DB_OPEN opens, DB_CLOSE closes.
''''
'''Const ROUTINE = "PricingDB"
'''Dim uErr As tErrorState
'''On Error GoTo OpenPricingDB_ErrorHandler:
''''__________________________
'''
'''Static intRefCount As Integer
'''
'''   Select Case OpenClose
'''      Case DB_OPEN
'''         If m_jdbPricing Is Nothing Then
'''               Set m_jdbPricing = OpenDatabase(PathParse(GetSetting(TRANBILL, "PriceCalcDB")), False, True) ' non-exclusive, read-only access
'''            End If
'''         intRefCount = intRefCount + 1
'''
'''      Case DB_CLOSE
'''         intRefCount = intRefCount - 1
'''         If intRefCount = 0 Then
'''               m_jdbPricing.Close
'''               Set m_jdbPricing = Nothing
'''            End If
'''   End Select
''''__________________________
'''OpenPricingDB_Cleanup:
'''   On Error Resume Next
'''      ' Clean up any object references here
'''   On Error GoTo 0
'''      ProcessError uErr, PROJECT & MODULE & ROUTINE
'''   Exit Sub
''''__________________________ EXIT
'''
''''__________________________ Error handling
'''
'''OpenPricingDB_ErrorHandler:
'''   CaptureErrorState uErr
'''   Resume OpenPricingDB_Cleanup:
''''__________________________ End of Error Handling
End Sub

Private Function PricingHeap() As Integer
'  Description :  Determine a heap ID to use and return it
'
'  Output      :  Returns a heap ID
'
Const ROUTINE = "PricingHeap"
Dim uErr As tErrorState
On Error GoTo PricingHeapErrorHandler:
'__________________________

   If m_intHeap = 0 Then
         Heap 1, m_intHeap, "PRICING_HEAP", "", 0
      End If

   PricingHeap = m_intHeap
                        
'__________________________
PricingHeapCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

PricingHeapErrorHandler:
   CaptureErrorState uErr
   Resume PricingHeapCleanup:
'__________________________ End of Error Handling

End Function

Private Sub PrintInvoice(Tran As BmiTransaction)
'03Jul06 PJC Added Printer Context for BMI Patient billing. (#91676)
'18Jan07 PJC Removes the local file if it exists (#88777,#49479)
'15Jun09 PJC Changed the datatype to Long to handle the return value. RFC F0051718.
'10Jan10 TH  Major overhaul for version 10
'02Dec13 TH  Need to add a picker now as this will only be called via patient printing in v10
'            We will offer the last 10 transactions for printing, so this can in effect be used
'            for limited reprint functionality.
'05Jan14 TH  Ensure lst box is refreshed properly elsewhere - no over hang (TFS 80849)
'22May14 XN  Should now just come from DB 88863

Const ROUTINE = "PrintInvoice"
Dim uErr As tErrorState
On Error GoTo PrintInvoiceErrorHandler:
'__________________________

Dim strHeader As String
Dim strDetailTemplate As String
Dim strFooter As String

Dim intline As Integer

Dim strTemplatePath As String
Dim strTemplate As String

Dim strInvoicePath As String

Dim h As Integer
Dim intHeap As Integer

'Dim success As Integer      '15Jun09 PJC Changed the datatype to Long to handle the return value. RFC F0051718.
Dim success As Long
Dim strParams As String
Dim rsTran As ADODB.Recordset
Dim strPatName As String
Dim strTemp As String
Dim strTemp2 As String
Dim strTemp3 As String


   'Construct a list of invoices (transactions) for the current patient and ask the user to choose
   
   'escaped = False
   'Code$ = ""
   'expn$ = ""
   Unload LstBoxFrm
   
   Heap 11, gPRNheapID, "pForenameSurname", strPatName, 0
   LstBoxFrm.Caption = "Select Invoice Batch for " & strPatName
   'LstBoxFrm.LstBox.AddItem Space$(6) & TB$ & "<No Instruction>"
   LstBoxFrm.lblHead.Caption = "Issued On" & TB & "At      " & TB & "Printed On   " & TB & "By   "
   
      
   strParams = gTransport.CreateInputParameterXML("EntityID_Patient", trnDataTypeint, 4, pid.recno) & _
               gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
   Set rsTran = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyGenericBilling_TransactionbyEntityID_PatientforInvoicing", strParams)
   If Not rsTran Is Nothing Then
      If rsTran.State = adStateOpen Then
         If rsTran.RecordCount <> 0 Then
            Do While Not rsTran.EOF
               'temp$ = RtrimGetField(rs!Value)
               strTemp = Format$(RtrimGetField(rsTran!PrintedDT), "DD/MM/YYYY")
               strTemp2 = Format$(RtrimGetField(rsTran!CreatedDT), "DD/MM/YYYY")
               strTemp3 = Format$(RtrimGetField(rsTran!CreatedDT), "HH:MM")
               If Right$(strTemp, 4) = "1899" Then strTemp = ""
               'If temp$ <> "" Then
                  LstBoxFrm.LstBox.AddItem strTemp2 & TB$ & strTemp3 & TB$ & strTemp & TB$ & RtrimGetField(rsTran!PrintedInits)
                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(rsTran!PharmacyGenericBilling_TransactionID)
               'End If
               rsTran.MoveNext
            Loop
         End If
      End If
   End If
   
   
   LstBoxShow
   
''   Select Case LstBoxFrm.LstBox.ListIndex
''      Case -1
''         'escaped = True
''      Case 0
''         'do nothing as code$ ="" & expn$ = "" from above
''         'Code$ = Chr$(161) '21Jan02 TH Use as marker for no inst
''      Case Else
''         'temp$ = LstBoxFrm.Tag
''         'replace temp$, TB, Nul, 0
''         'Code$ = asciiz(temp$)
''         'GetInsCode Code$, expn$
''      End Select


   '--------------
   
   If LstBoxFrm.LstBox.ListIndex > -1 Then
      LoadTransaction LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex), Tran
   
   Else
      k.escd = True
      Unload LstBoxFrm
      Exit Sub
   End If
   
   '05Jan14 TH (TFS 80849)
   Unload LstBoxFrm 'Ensure lst box is refreshed properly elsewhere - no over hang
   
   ' Don't bother printing empty invoices!
   
   If Tran.LineCount = 0 Then Exit Sub

   '22Oct02 ATW ; Fixes total carrying over to next invoice print for same patient/session
   Tran.LineTotal = 0
   Tran.TaxTotal = 0
   
   intHeap = PricingHeap()

   ' Load the report template (should now just come from DB 88863) XN 22May14
   'If TrueFalse(TxtD(dispdata$ & iniFile, TRANBILL, "N", "UseOldPatientInvoice", 0)) Then
   If Not TrueFalse(TxtD(dispdata$ & iniFile, TRANBILL, "N", "UseOldPatientInvoice", 0)) Then  '20Aug14 TH Switch logic (TFS 98308)
      strTemplate = GetRichTextDocument("Pharmacy Patient Invoice " + CStr(SiteNumber))
   Else
      'strTemplatePath = PathParse(TxtD(dispdata$ & iniFile, TRANBILL, "Invoice.rtf", "Invoice", 0))
      strTemplatePath = PathParse(TxtD(dispdata$ & iniFile, TRANBILL, "[DISPDATA]\Invoice.rtf", "Invoice", 0))   '20Aug14 TH Replaced above as default would never load (TFS 98308)
      
      'GetTextFile strTemplatePath, strTemplate, 0
      GetRTFTextFromDB strTemplatePath, strTemplate, 0 '06Dec16 TH Replaced (TFS 157969)

   
   End If
   
   SplitFile strTemplate, strHeader, strDetailTemplate, strFooter
                                                                 
   ' Open a report file

   MakeLocalFile strInvoicePath
   
   h = FreeFile

   Open strInvoicePath For Binary Access Write Lock Read Write As h
   
   ' Header

   ' Push header info onto stack
   FillHeapPatientInfo intHeap, pid, pidExtra, pidEpisode, 0
   ' Parse header
   ParseItems intHeap, strHeader, 0
   'write header to file
   Put h, , strHeader

   'Detail header
   strHeader = HeaderFromLayout(strDetailTemplate, TRANBILL)
   
   Put h, , strHeader

   ' Detail lines
   For intline = 0 To Tran.LineCount - 1
      PrintInvoiceLine Tran, Tran.TranLine(intline), h, (strDetailTemplate)
   Next intline

   ' Footer
   
   ' Push footer info onto stack
   FillHeapTransaction Tran
   ' Parse footer
   ParseItems intHeap, strFooter, 0
   ' write footer to file
   Put h, , strFooter

   Close h

   'ParseThenPrint "", strInvoicePath, 1, 0                       '03Jul06 PJC Added Printer Context for BMI Patient billing. (#91676)
   'ParseThenPrint "PatBillInvoice", strInvoicePath, 1, 0, 0       '21Nov13 TH Added param (DO WE WANT REPRINTS HERE ??)
   ParseThenPrint "PatBillInvoice", strInvoicePath, 1, 0, 0, True '04Jan17 TH Use local file parsing (Hosted)

   Tran.PrintedInits = UserID$
   
   success = SaveTransaction(Tran)

   ' Remove the temp file                                                   '18Jan07 PJC Removes the local file if it exists (#88777,#49479)
   If InStr(strInvoicePath, "#LOCALF#.") > 0 Then                           '          "
         If fileexists(strInvoicePath) Then Kill strInvoicePath             '          "
      End If                                                                '          "


'__________________________
PrintInvoiceCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

PrintInvoiceErrorHandler:
   CaptureErrorState uErr
   Resume PrintInvoiceCleanup:
'__________________________ End of Error Handling

End Sub

Private Sub PrintInvoiceLine(uTran As BmiTransaction, uLine As BmiTransactionLine, ByVal h As Integer, ByVal strDetail As String)
'  Description :  Print a single line on the invoice, and update the main transaction to
'                    reflect running totals
'
'  Input       :  uTran          ;  The transaction
'                 uLine          ;  The line we are dealing with
'                 h              ;  The file handle we are using
'                 strDetail      ;  The detail template
'10Dec13 TH Removed calculateLine call -this as its already calculated from the DB !!!Otherwise I would just end up having to throw everything up into state

Const ROUTINE = "PrintInvoiceLine"
Dim uErr As tErrorState
On Error GoTo PrintInvoiceLineErrorHandler:
'__________________________

Dim drug As DrugParameters
Dim intHeap As Integer
Dim success As Integer

   intHeap = PricingHeap()

' Push detail info onto stack
   FillHeapTranLine uLine
   
   drug.SisCode = uLine.NSVCode
   getdrug drug, 0, 0, 0
   FillHeapDrugInfo intHeap, drug, 0

   '10Dec13 TH Removed this as its already calculated from the DB !!!Otherwise I would just end up having to throw everything up into state
   ''success = CalculateLine(uLine)
   
   
' parse detail line
   ParseItems intHeap, strDetail, 0
' write line to file

   Put h, , strDetail

   ' totalise

   uTran.LineTotal = uTran.LineTotal + (uLine.LineCost + uLine.LineAdjust) ' + uLine.DispFee + uLine.DispAdjust)
   uTran.TaxTotal = uTran.TaxTotal + (uLine.TaxAmount + uLine.TaxAdjust)

'__________________________
PrintInvoiceLineCleanup:
   On Error Resume Next
      ' Clean up any object references here
      Unload Ques
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

PrintInvoiceLineErrorHandler:
   CaptureErrorState uErr
   Resume PrintInvoiceLineCleanup:
'__________________________ End of Error Handling
End Sub

Private Sub QuesLineGetState(uLine As BmiTransactionLine)
'  Description :  Reads the state of a transaction line out of the Ques form
'
'  Output      :  The passed line is modified
'
'05Jan14 TH  Added Tax Rate and Tax Amount (TFS 81010)

Const ROUTINE = "QuesLineGetState"
Dim uErr As tErrorState
On Error GoTo QuesLineGetStateErrorHandler:
'__________________________

Dim intCounter As Integer
Dim strValue As String

   For intCounter = 1 To m_intControlCount
      strValue = ""
      strValue = QuesGetText(intCounter)
      
      ' Trim out double decimal dots
      replace strValue, "..", ".", 0
      
      ' Val naturally excludes numeric value after second decimal (e.g. Val("2.345.68") = 2.345)

      Select Case Ques.lblDesc(intCounter).Tag
         Case QUES_BASE_ADJ
            uLine.CostAdjust = CSng(Val(strValue)) - uLine.BaseCost
         Case QUES_MARKUP_ADJ
            uLine.MarkupAdjust = CSng(Val(strValue)) - uLine.markup
         Case QUES_DISPFEE_ADJ
            uLine.DispAdjust = CSng(Val(strValue)) - uLine.DispFee
         Case QUES_ISSUEQTY
            uLine.IssueQty = CSng(Val(strValue))
         Case QUES_PACKSISSUED
            uLine.PacksIssued = CSng(Val(strValue))
         Case QUES_TAXRATE_ADJUST
            uLine.TaxAdjust = CSng(Val(strValue)) - uLine.TaxRate
         Case QUES_LINETOTAL_ADJUST
            uLine.LineAdjust = CSng(Val(strValue)) - uLine.LineCost
         '05Jan14 TH Added (TFS 81010)
         Case QUES_TAXRATE
            uLine.TaxRate = CSng(Val(strValue))
         Case QUES_TAXAMOUNT
            uLine.TaxAmount = CSng(Val(strValue))
      End Select
   Next intCounter
                  
'__________________________
QuesLineGetStateCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

QuesLineGetStateErrorHandler:
   CaptureErrorState uErr
   Resume QuesLineGetStateCleanup:
'__________________________ End of Error Handling
End Sub

Private Sub QuesLineSetState(uLine As BmiTransactionLine)
'  Description :  Reads the state out of a transaction line into the Ques form
'
'  Input :     uLine ;  The transaction line
'
'05Jan14 TH  Added Tax Rate and Tax Amount (TFS 81010)

Const ROUTINE = "QuesLineSetState"
Dim uErr As tErrorState
On Error GoTo QuesLineSetStateErrorHandler:
'__________________________

Dim strTag As String
Dim intCounter As Integer
Dim strValue As String
Dim strInfo As String
Dim strInsert As String
Dim blnFound As Integer
Dim intDataField As Integer

   For intCounter = 1 To m_intControlCount
      strValue = ""
      
      '20Aug02 ATW Added feature to allow more compact forms - where an asterisk appears in the info
      '              field, the companion info replaces it in the label (e.g. - the adjusted fields
      '              replace the asterisk with the original value - £*  /

      intDataField = Ques.lblDesc(intCounter).Tag
      
      strTag = "INFOTAG_" & intDataField

      Heap 11, PricingHeap(), strTag, strInfo, blnFound
      strInsert = ""

      If Not blnFound Then
            strInfo = Ques.lblInfo(intCounter).Caption
            Heap 10, PricingHeap(), strTag, strInfo, 0
         End If

      Select Case intDataField
         Case QUES_BASE
            strValue = CStr(uLine.BaseCost)
         Case QUES_BASE_ADJ
            strValue = CStr(uLine.BaseCost + uLine.CostAdjust)
            strInsert = Format$(CStr(uLine.BaseCost), TWODP) ' shows the default base cost to the right    '20Aug02 ATW
         Case QUES_MARKUP
            strValue = CStr(uLine.markup)
         Case QUES_MARKUP_ADJ
            strValue = CStr(uLine.markup + uLine.MarkupAdjust)
            strInsert = Format$(CStr(uLine.markup), TWODP)   ' shows the default markup to the right      '20Aug02 ATW
         Case QUES_DISPFEE
            strValue = CStr(uLine.DispFee)
         Case QUES_DISPFEE_ADJ
            strValue = CStr(uLine.DispFee + uLine.DispAdjust)
            strInsert = Format$(CStr(uLine.DispFee), TWODP)  ' shows the default fee to the right        '20Aug02 ATW
         Case QUES_PACKSISSUED
            strValue = CStr(uLine.PacksIssued)

         Case QUES_PACKCOST
            strValue = CStr(uLine.PackCost)
         Case QUES_TOTAL
            strValue = CStr(uLine.LineCost)
         Case QUES_ISSUEQTY
            strValue = CStr(uLine.IssueQty)
            If m_strIssueUnit <> "" Then Ques.lblInfo(intCounter).Caption = m_strIssueUnit
            '07Oct02 ATW Show the IssueQty in RED if it's a return
            If m_blnReturn Then
                  'Ques.txtQ(intCounter).TextColor = Red
                  Ques.txtQ(intCounter).ForeColor = Red
               Else
                  'Ques.txtQ(intCounter).TextColor = Black
                  Ques.txtQ(intCounter).ForeColor = Black
               End If
            

         Case QUES_PACKSIZE
            strValue = CStr(uLine.PackSize)
            If m_strIssueUnit <> "" Then Ques.lblInfo(intCounter).Caption = m_strIssueUnit
         Case QUES_PREV_BASE
            strValue = CStr(m_PrevLine.BaseCost + m_PrevLine.CostAdjust)
         Case QUES_PREV_MARKUP
            strValue = CStr(m_PrevLine.markup + m_PrevLine.MarkupAdjust)
         Case QUES_PREV_DISPFEE
            strValue = CStr(m_PrevLine.DispFee + m_PrevLine.DispAdjust)
         '20Aug02 ATW Begin
         Case QUES_LINETOTAL_ADJUST
            strValue = CStr(uLine.LineCost + uLine.LineAdjust)
            strInsert = Format$(CStr(uLine.LineCost), TWODP)     ' shows the calculated cost on the right
            
         '05Jan14 TH Added (TFS 81010)
         Case QUES_TAXRATE
            strValue = CStr(uLine.TaxRate)
            
         Case QUES_TAXAMOUNT
            strValue = CStr(uLine.TaxAmount)
      End Select
      
      strValue = Format$(strValue, TWODP)
      
      If strValue <> "" Then
            QuesSetText intCounter, strValue
         End If

      If strInsert <> "" Then
            replace strInfo, "*", strInsert, 0
            Ques.lblInfo(intCounter).Caption = strInfo
         End If

   Next intCounter

'__________________________
QuesLineSetStateCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

QuesLineSetStateErrorHandler:
   CaptureErrorState uErr
   Resume QuesLineSetStateCleanup:
'__________________________ End of Error Handling

End Sub

Private Function SaveLine(Tran As BmiTransaction, uLine As BmiTransactionLine) As Long
'  Description :  Saves an individual transaction line
'
'  Input       :  Tran        ;  The transaction context of the line
'                 LineIndex   ;  The index of the transaction to save
'
'  Output      :  Return      ;  Primary key of the saved line
'

'12Jun02 ATW Replaced LineIndex parameter with Byref pass of type
'10Jan14 TH Rewritten to use v10 tranport mechanisms

Const ROUTINE = "SaveLine"
Dim uErr As tErrorState
On Error GoTo SaveLine_ErrorHandler:
'__________________________

Dim dynLine As Dynaset
Dim strSql As String
Dim lngLineID As Long
Dim strParams As String
Dim lngResult As Long


   '''BillingDB DB_OPEN

   'uLine = Tran.TranLine(LineIndex)  '12Jun02 ATW This line was copying, not referencing - ID number was not persisting, causing multiple saves

''   strSql = "SELECT * FROM TransactionLine WHERE ID = " & CStr(uLine.id)
''   Set dynLine = m_jdbBilling.CreateDynaset(strSql)

''   If dynLine.RecordCount = 0 Then
''         dynLine.AddNew
''         ' use a file-counter if the DB is not using a counter field
''         If IsNull(dynLine!id) Then
''               GetPointerSQL patdatapath$ & "\TranLine.dat", lngLineID, True
''               dynLine!id = lngLineID
''            End If
''
''         dynLine!TransactionID = Tran.id
''      Else
''         dynLine.Edit
''      End If

''   dynLine!PrescriptionID = uLine.PrescriptionID
''   dynLine!BasePrescriptionID = uLine.BasePrescriptionID
''   dynLine!NSVCode = uLine.NSVCode
''   dynLine!LineCost = uLine.LineCost
''   dynLine!PacksIssued = uLine.PacksIssued
''   dynLine!IssueQty = uLine.IssueQty
''   dynLine!BaseCost = uLine.BaseCost
''   dynLine!markup = uLine.markup
''   dynLine!CreateInits = uLine.CreatedInits
''
''   '10Oct02 ATW Added DT and descriptive text
''   dynLine!CreateDT = Now
''   dynLine!ProductDesc = uLine.ProductDesc
''
''   If uLine.CostAdjust <> 0 Or Not IsNull(dynLine!CostAdjust) Then
''         dynLine!CostAdjust = uLine.CostAdjust
''      End If
''
''   If uLine.MarkupAdjust <> 0 Or Not IsNull(dynLine!MarkupAdjust) Then
''         dynLine!MarkupAdjust = uLine.MarkupAdjust
''      End If
''
''   dynLine!DispFee = uLine.DispFee
''
''   If uLine.DispAdjust <> 0 Or Not IsNull(dynLine!DispAdjust) Then
''         dynLine!DispAdjust = uLine.DispAdjust
''      End If
''
''   dynLine!TaxRate = uLine.TaxRate
''
''   If uLine.TaxAdjust <> 0 Or Not IsNull(dynLine!TaxAdjust) Then
''         dynLine!TaxAdjust = uLine.TaxAdjust
''      End If
''
''   If uLine.LineAdjust <> 0 Or Not IsNull(dynLine!LineAdjust) Then
''         dynLine!LineAdjust = uLine.LineAdjust
''      End If
''
''   SaveLine = dynLine!id
''   uLine.id = dynLine!id
''
''   dynLine.Update
   
    strParams = gTransport.CreateInputParameterXML("PharmacyGenericBilling_TransactionID", trnDataTypeint, 4, Tran.id) & _
               gTransport.CreateInputParameterXML("RequestID_DispensingID", trnDataTypeint, 10, uLine.LabelID) & _
               gTransport.CreateInputParameterXML("PrescriptionID", trnDataTypeint, 4, uLine.PrescriptionID) & _
               gTransport.CreateInputParameterXML("BasePrescriptionID", trnDataTypeint, 4, uLine.BasePrescriptionID) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, uLine.NSVCode) & _
               gTransport.CreateInputParameterXML("LineCost", trnDataTypeFloat, 8, uLine.LineCost) & _
               gTransport.CreateInputParameterXML("PacksIssued", trnDataTypeFloat, 8, uLine.PacksIssued) & _
               gTransport.CreateInputParameterXML("IssueQty", trnDataTypeFloat, 8, uLine.IssueQty) & _
               gTransport.CreateInputParameterXML("BaseCost", trnDataTypeFloat, 8, uLine.BaseCost) & _
               gTransport.CreateInputParameterXML("markup", trnDataTypeFloat, 8, uLine.markup) & _
               gTransport.CreateInputParameterXML("CreatedInits", trnDataTypeVarChar, 3, uLine.CreatedInits) & _
               gTransport.CreateInputParameterXML("CreateDT", trnDataTypeDateTime, 8, Now) & _
               gTransport.CreateInputParameterXML("ProductDesc", trnDataTypeVarChar, 56, uLine.ProductDesc) & _
               gTransport.CreateInputParameterXML("CostAdjust", trnDataTypeFloat, 8, uLine.CostAdjust) & _
               gTransport.CreateInputParameterXML("MarkupAdjust", trnDataTypeFloat, 8, uLine.MarkupAdjust) & _
               gTransport.CreateInputParameterXML("DispFee", trnDataTypeFloat, 8, uLine.DispFee) & _
               gTransport.CreateInputParameterXML("DispAdjust", trnDataTypeFloat, 8, uLine.DispAdjust) & _
               gTransport.CreateInputParameterXML("TaxRate", trnDataTypeFloat, 8, uLine.TaxRate) & _
               gTransport.CreateInputParameterXML("TaxAdjust", trnDataTypeFloat, 8, uLine.TaxAdjust) & _
               gTransport.CreateInputParameterXML("LineAdjust", trnDataTypeFloat, 8, uLine.LineAdjust) & _
               gTransport.CreateInputParameterXML("PackCost", trnDataTypeFloat, 8, uLine.PackCost) & _
               gTransport.CreateInputParameterXML("TaxAmount", trnDataTypeFloat, 8, uLine.TaxAmount) & _
               gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
   
   If uLine.id > 0 Then 'update
      strParams = gTransport.CreateInputParameterXML("PharmacyGenericBilling_TransactionLineID", trnDataTypeint, 4, uLine.id) & strParams
      lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "PharmacyGenericBilling_TransactionLine", strParams)
   Else
      lngResult = gTransport.ExecuteInsertSP(g_SessionID, "PharmacyGenericBilling_TransactionLine", strParams)
      If lngResult > 0 Then uLine.id = lngResult
   End If
   
   SaveLine = lngResult
   
'__________________________
SaveLine_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
      dynLine.Close
      Set dynLine = Nothing
      '''BillingDB DB_CLOSE
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

SaveLine_ErrorHandler:
   CaptureErrorState uErr
   Resume SaveLine_Cleanup:
'__________________________ End of Error Handling

End Function

Private Function SaveTransaction(Tran As BmiTransaction) As Long
'  Description :  Saves a transaction
'
'  Input :  Tran     ;  The transaction to save
'
'  Output:  Return   ;  The primary key of the saved transaction
'
'10Jan14 TH Rewritten to use v10 tranport mechanisms
'02Dec13 TH Added further fencepost

Const ROUTINE = "SaveTransaction"
Dim uErr As tErrorState
On Error GoTo SaveTransaction_ErrorHandler:
'__________________________

''Dim dynTransaction As Dynaset

Dim strSql As String
Dim intLineCounter As Integer
Dim lngTranID As Long
Dim lngLineID As Long
Dim dob As String
Dim valid As Integer
Dim strParams As String
Dim lngResult As Long

   If Tran.LineCount = 0 Then
         SaveTransaction = 0
         Exit Function
      End If

   '''BillingDB DB_OPEN

''   strSql = "SELECT * FROM Transaction WHERE ID = " & CStr(Tran.id)
''
''   Set dynTransaction = m_jdbBilling.CreateDynaset(strSql)

''   If dynTransaction.RecordCount = 0 Then
''         dynTransaction.AddNew
''
''         If IsNull(dynTransaction!id) Then ' this occurs with SQL DBs and non-counter fields
''               GetPointerSQL patdatapath$ & "\Tran.dat", lngTranID, True
''               dynTransaction!id = lngTranID
''            End If
''
''         Tran.id = dynTransaction!id
''      Else
''         dynTransaction.Edit
''      End If

   
   strParams = gTransport.CreateInputParameterXML("EntityID_Patient", trnDataTypeint, 4, pid.recno) & _
               gTransport.CreateInputParameterXML("Caseno", trnDataTypeVarChar, 10, Tran.caseno) & _
               gTransport.CreateInputParameterXML("surname", trnDataTypeVarChar, 20, Tran.surname) & _
               gTransport.CreateInputParameterXML("forename", trnDataTypeVarChar, 15, Tran.forename) & _
               gTransport.CreateInputParameterXML("DOB", trnDataTypeVarChar, 8, Tran.dob)
   If Trim$(Tran.PrintedInits) <> "" Then
      ''dynTransaction!PrintedInits = Tran.PrintedInits
      strParams = strParams & gTransport.CreateInputParameterXML("PrintedInits", trnDataTypeVarChar, 3, Tran.PrintedInits)
      ''If dynTransaction!Printed = 0 Then
      If Tran.Printed = 0 Then
''            dynTransaction!Printed = 1
''            dynTransaction!PrintedDT = Now
         strParams = strParams & gTransport.CreateInputParameterXML("Printed", trnDataTypeBit, 1, 1) & _
                                 gTransport.CreateInputParameterXML("PrintedDT", trnDataTypeDateTime, 8, Now)
      Else
         strParams = strParams & gTransport.CreateInputParameterXML("Printed", trnDataTypeBit, 8, Tran.Printed) & _
                                 gTransport.CreateInputParameterXML("PrintedDT", trnDataTypeDateTime, 8, Tran.PrintedDT)
      End If
   Else
      strParams = strParams & gTransport.CreateInputParameterXML("PrintedInits", trnDataTypeVarChar, 8, Null) & _
                              gTransport.CreateInputParameterXML("Printed", trnDataTypeBit, 8, 0) & _
                              gTransport.CreateInputParameterXML("PrintedDT", trnDataTypeDateTime, 8, Null)
   End If
              
   strParams = strParams & gTransport.CreateInputParameterXML("TransactionCharge", trnDataTypeFloat, 8, Tran.TransactionCharge)
   
   If Tran.id > 0 Then 'update
      strParams = strParams & gTransport.CreateInputParameterXML("CreatedDT", trnDataTypeDateTime, 8, Tran.CreatedDT) & _
               gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
   
      strParams = gTransport.CreateInputParameterXML("PharmacyGenericBilling_TransactionID", trnDataTypeint, 4, Tran.id) & strParams
      lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "PharmacyGenericBilling_Transaction", strParams)
   Else
      strParams = strParams & gTransport.CreateInputParameterXML("CreatedDT", trnDataTypeDateTime, 8, Now) & _
               gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
   
   
      lngResult = gTransport.ExecuteInsertSP(g_SessionID, "PharmacyGenericBilling_Transaction", strParams)
      If lngResult > 0 Then Tran.id = lngResult
   End If
   
''   dynTransaction!PatRecNo = Tran.PatRecNo
''   '07Oct02 ATW______________
''   dynTransaction!caseno = Tran.caseno
''   dynTransaction!surname = Tran.surname
''   dynTransaction!forename = Tran.forename
''
''   '25Nov02 ATW Changed this area to prevent patients with no/invalid dob from causing "type mismatch"
''   '              nulls will be recorded instead
''   parsedate Tran.dob, dob, "1", valid
''
''   If valid Then
''      dynTransaction!dob = "#" & dob & "#"
''   End If
''   '25Nov02 ATW
   
   '07Oct02 ATW______________

''   If Trim$(Tran.PrintedInits) <> "" Then
''         dynTransaction!PrintedInits = Tran.PrintedInits
''         If dynTransaction!Printed = 0 Then
''               dynTransaction!Printed = 1
''               dynTransaction!PrintedDT = Now
''            End If
''      End If
''
''   dynTransaction!TransactionCharge = Tran.TransactionCharge
''
''   dynTransaction.Update
   If Tran.id > 0 Then '02Dec13 TH Added further fencepost
      For intLineCounter = 0 To Tran.LineCount - 1
         If Tran.TranLine(intLineCounter).id = 0 Then
               lngLineID = SaveLine(Tran, Tran.TranLine(intLineCounter))   '12Jun02 ATW Pass Tranline by reference instead of index
            End If
      Next intLineCounter
   End If
   
   SaveTransaction = Tran.id

'__________________________
SaveTransaction_Cleanup:
   On Error Resume Next
      ' Clean up any object references here
      '''BillingDB DB_CLOSE
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

SaveTransaction_ErrorHandler:
   CaptureErrorState uErr
   Resume SaveTransaction_Cleanup:
'__________________________ End of Error Handling

End Function

Private Sub SetPacksFromQty(uLine As BmiTransactionLine)
'  Descriptiom :  Set the number of packs in this line from the quantity
'
'  In/Out      :  The line is modified
'
Const ROUTINE = "SetPacksFromQty"
Dim uErr As tErrorState
On Error GoTo SetPacksFromQtyErrorHandler:
'__________________________

   If uLine.PackSize <> 0 Then
         uLine.PacksIssued = uLine.IssueQty / CSng(uLine.PackSize)
      End If
'__________________________
SetPacksFromQtyCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

SetPacksFromQtyErrorHandler:
   CaptureErrorState uErr
   Resume SetPacksFromQtyCleanup:
'__________________________ End of Error Handling

End Sub

Private Sub SetQtyFromPacks(uLine As BmiTransactionLine)
'  Description :  Set the issue quantity of this line from the number of packs issued
'
'  In/Out      :  the line is modified.
'
Const ROUTINE = "SetQtyFromPacks"
Dim uErr As tErrorState
On Error GoTo SetQtyFromPacksErrorHandler:
'__________________________

   If uLine.PackSize <> 0 Then
         uLine.IssueQty = uLine.PackSize * uLine.PacksIssued
      End If
'__________________________
SetQtyFromPacksCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

SetQtyFromPacksErrorHandler:
   CaptureErrorState uErr
   Resume SetQtyFromPacksCleanup:
'__________________________ End of Error Handling

End Sub

Private Function Terminate() As Variant
'  Description :  Tidies up the transaction stuff when leaving the PMR.
'
Const ROUTINE = "Terminate"
Dim uErr As tErrorState
On Error GoTo Terminate_ErrorHandler:
'__________________________

Dim lngTranID As Long

   lngTranID = SaveTransaction(m_CurrentTransaction)
   
   If TrueFalse(TxtD$(dispdata$ & iniFile, TRANBILL, "N", "ForceInvoice", 0)) Then
         PrintInvoice m_CurrentTransaction
      End If

'__________________________
Terminate_Cleanup:
   On Error Resume Next
      ' clean up
      Heap 2, PricingHeap(), "", "", 0
      m_intHeap = 0
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

Terminate_ErrorHandler:
   CaptureErrorState uErr
   Resume Terminate_Cleanup:
'__________________________ End of Error Handling

End Function

Sub BmiBilling_Callback(Index As Integer)
'  Description :  Provides the callback routine to handle UI events
'                 In this case, the entire line is recalculated and the state re-inserted into
'                 Ques.
'
'  Input       :  Index    ;  Index of which control on Ques just lost focus.

Const ROUTINE = "BmiBilling_Callback"
Dim uErr As tErrorState
On Error GoTo BmiBilling_CallbackErrorHandler:
'__________________________

Dim success As Integer
Dim sngQtyCache As Single

Const OK = 0

   
   QuesLineGetState m_CurrentTransaction.TranLine(m_intCurrentLine)
   'sngQtyCache = m_CurrentTransaction.TranLine(m_intCurrentLine).PacksIssued      ' 29Oct02 ATW Fixed "Not updating packs issued" ; this var never used

   If Index <> OK Then
         Select Case Ques.lblDesc(Index).Tag
            Case QUES_ISSUEQTY
               SetPacksFromQty m_CurrentTransaction.TranLine(m_intCurrentLine)
            Case QUES_PACKSISSUED
               '25Sep02 ATW Removed faulty rounding-error inhibitor, because it didn't work anyway.
               '              Just disable the Packs Issued field in the view to prevent iterative rounding errors.
               SetQtyFromPacks m_CurrentTransaction.TranLine(m_intCurrentLine)
            End Select
      End If
             

   'QuesLineGetState m_CurrentTransaction.TranLine(m_intCurrentLine)               ' 29Oct02 ATW Fixed "Not updating packs issued" ; this line overwrites change made by SetPacksFromQty
   success = CalculateLine(m_CurrentTransaction.TranLine(m_intCurrentLine))

   QuesLineSetState m_CurrentTransaction.TranLine(m_intCurrentLine)
  
'__________________________
BmiBilling_CallbackCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

BmiBilling_CallbackErrorHandler:
   CaptureErrorState uErr
   Resume BmiBilling_CallbackCleanup:
'__________________________ End of Error Handling

End Sub

Public Function BmiBillPatient(Action As Integer, strReturn As String) As Variant
'  Description :  The root of the billing call. Routes the thread to the correct subroutine.
'
'  Input       :  Action      ;  Magic number denoting action desired. Consts have been used here.
'                 strReturn   :  strReturn is used by this module to receive the return QTY when returning
'
'  Output      :  strReturn   :  strReturn is used to return stuff. e.g. the return qty allowing it to be edited.
'                 Return      :  Returns a variant that contains various stuff the calling routine expects depending
'                                on other stuff in a non-deterministic fashion. Blurrgh.
'
'08Jan14 TH Added to stop return on rx line (TFS ) - this code is still in but a parallel fix around users using f9/f8 and "I"
'           at the label prompt from an attempt to dispense directly from an rx, means now that the label should be save here
'           so this code should never fire.


Const ROUTINE = "BmiBillPatient"
Dim uErr As tErrorState
On Error GoTo BmiBillPatientErrorHandler:
'__________________________

Const ACTION_INIT% = 0
Const ACTION_ISSUE% = 1
Const ACTION_TERMINATE% = 2
Const ACTION_SETQTYFROMBILLINGQTY% = 4

Const ACTION_RETURN% = 14
Const ACTION_PRINT% = 26    '12Sep02 ATW '19Sep02 ATW changed constant 'cause it overlapped.
Const ACTION_QUERYBACKOUT = 27 ' 19Sep02 ATW Back out if you don't like the fact that the patient will get billed.

Dim strDescription As String
Dim strAns As String
Dim msg As String '08Jan14 TH Added to stop return on rx line (TFS )

   strDescription = Trim$(d.DrugDescription)  ' strDescription = Trim$(d.Description)  XN 4Jun15 98073 New local stores description
   plingparse strDescription, "!"

   Select Case Action
      Case ACTION_INIT
         BmiBillPatient = Initialize(pid, pidExtra, pidEpisode)
      Case ACTION_TERMINATE
         BmiBillPatient = Terminate()
      Case ACTION_ISSUE
         Ques.Caption = "Issuing " & strDescription
         BmiBillPatient = Issue(d, L, m_sngIssueQty)
      Case ACTION_SETQTYFROMBILLINGQTY
         If m_sngIssueQty > 0 Then Qty! = m_sngIssueQty
      Case ACTION_RETURN
         If L.RequestID = 0 And TrueFalse(TxtD(dispdata$ & "\Patbill.ini", "PatientBilling", "Y", "StopReturnOnRx", 0)) Then '08Jan14 TH This is an attempt to return against an rx, NOT a label. THis is not allowed for generic billing (TFS )
            'As this is not allowed - inform the user , ask if they want to continue the return (though no patient billing can occur)
            strAns = "N"
            'Produce a suitable msg
            msg = "This return is not against a previous dispensing record" & crlf & crlf & "Do you wish to continue and return outside of patient billing process"
            msg = TxtD(dispdata$ & "\Patbill.ini", "PatientBilling", msg, "NoReturnOnRxMsg", 0)
            askwin "?Patient Billing", msg, strAns, k
            If strAns = "N" Or k.escd Then
               strReturn = "0"
            End If
         Else
            m_sngIssueQty = CSng(Val(strReturn))
            Ques.Caption = "Returning " & strDescription
            BmiBillPatient = DoReturn(d, L, m_sngIssueQty)
            strReturn = CStr(Abs(m_sngIssueQty))    '12Jun02 ATW Abs() added to prevent validation on issue re-showing returns box on negative values
         End If
      
      '12sep02 ATW
      Case ACTION_PRINT
         ' Print an invoice
         PrintInvoice m_CurrentTransaction
         BmiBillPatient = m_CurrentTransaction.LineCount
      Case ACTION_QUERYBACKOUT
         BmiBillPatient = CheckPatientGetsBilled(pid, pidExtra, pidEpisode)
   End Select
'__________________________
BmiBillPatientCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

BmiBillPatientErrorHandler:
   CaptureErrorState uErr
   Resume BmiBillPatientCleanup:
'__________________________ End of Error Handling
End Function

Function Bmi_BillPatDispensQty(stockLevel!, DispensQty!, negorpos%, escd%) As Integer
'  Description :  Provides the 'encapsulated' means of setting the default billing issue quantity from outside
'
'  Input       :  stockLevel     ;  the stock level
'                 DispensQty     ;  the quantity entered into DISPENS
'                 negorpos       ;  integer vector of signedness
'                 escd           ;  boolean cancel integer
'
Const ROUTINE = "Bmi_BillPatDispensQty"
Dim uErr As tErrorState
On Error GoTo Bmi_BillPatDispensQtyErrorHandler:
'__________________________

   m_sngIssueQty = DispensQty!

'__________________________
Bmi_BillPatDispensQtyCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Function
'__________________________ EXIT

'__________________________ Error handling

Bmi_BillPatDispensQtyErrorHandler:
   CaptureErrorState uErr
   Resume Bmi_BillPatDispensQtyCleanup:
'__________________________ End of Error Handling

End Function

Sub ClearBillingState()
'06Dec13 TH Written.
'Clear state in DB associated with generic billing

Dim strParameters As String
Dim lngOK As Long

   On Error Resume Next
                        
   If Not (gTransport Is Nothing) Then
   
      lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPharmacyGenericBillingState_ClearState", "")
   
   End If
   

End Sub

