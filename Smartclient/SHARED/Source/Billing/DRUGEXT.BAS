Attribute VB_Name = "DRUGEXT"
'08Mar07 PJC EditExtraBilling: Added for CAPIO, if the interface is enabled then output the drug to a file.
'10Jan14 TH  Moved into v10 for refs with generic billing - however external drug functionality not yet used.
'06Apr16 XN  QuesSetState: trimed LocalDescription before comparing it to "" 149885

Option Explicit
DefInt A-Z
Const MODULE = "DrugExt."
'10Apr02 ATW
'
'  Drug information extension V1.0    (DIX1)
'
'     Intended to provide external repository of information against ProdInfo.V8
'     originally designed for BMI Billing enhancements to store C&D trade price
'     in a user-adjustible manner. Could be used to store a wider variety of information.
'

Type DrugExtra
   id As Long           ' primary key on table
   NSVCode As String * 7 ' NSV code
   PIP As Long          ' MASTER PIP code (7 digits) (NOT the primary pip, which identifies the product). De-normailsed from ProdInfo.V8 to provide hook for C&D autoupdate.
   RefPrice As Single  ' Price per packsize in £.p - from Chemist & Druggist or other reference source
   PriceAdjust As Single ' Adjustment to this price in £.p
End Type

Dim m_dbDrugExtra As Database

Const INI_FILE = "\STKMAINT.INI"
Const ISECTION_DIX = "DIX"

Const DB_OPEN = True
Const DB_CLOSE = False

Dim m_intControlCount As Integer

Const QUES_STOREDESC = 82
Const QUES_NSVCODE = 9
Const QUES_PIP = 118
Const QUES_EAN = 10
Const QUES_REFPRICE = 1001
Const QUES_ADJPRICE = 1002

Const QUES_VIEW_DIX = 1003

Const HEAP_REFPRICE = "iRefPrice"

Sub ExternalPricing_Callback(Index As Integer)
Const ROUTINE = "ExternalPricing_Callback"
Dim uErr As tErrorState
On Error GoTo ExternalPricing_CallbackErrorHandler:
'__________________________

Const OK = 0

   If Index <> OK Then
      
         Select Case Ques.lblDesc(Abs(Index)).Tag
            Case QUES_REFPRICE, QUES_ADJPRICE
               
               ' do nothing!
      
            Case Else
               
         End Select

      End If
'__________________________
ExternalPricing_CallbackCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

ExternalPricing_CallbackErrorHandler:
   CaptureErrorState uErr
   Resume ExternalPricing_CallbackCleanup:
'__________________________ End of Error Handling

End Sub

Function ExternalPricingActive() As Integer
'
'  Description :  check for INI setting
'

   If TrueFalse(TxtD$(dispdata$ & INI_FILE, ISECTION_DIX, "N", "ExtendDrugFile", 0)) Then
         ExternalPricingActive = True
      Else
         ExternalPricingActive = False
      End If

End Function

Sub FillHeapDrugExtra(ByVal intHeap As Integer, uExtra As DrugExtra)
'  Description :  Push the type onto the heap
'
''   Heap 10, intHeap, HEAP_REFPRICE, CStr(uExtra.RefPrice + uExtra.PriceAdjust), 0

End Sub

Function PutDrugExtra(dex As DrugExtra) As Integer
'  Description :  Store the DrugExtra structure in the database
'
'  Input :     dex      ;  The struct to store
'
''On Error GoTo PutDrugExtra_err:
''
''Dim qry As QueryDef
''Dim rsExtra As Dynaset
''Dim success As Integer
''Dim strSql As String
''
''   DrugExtraDB DB_OPEN
''
''   strSql = "SELECT * FROM DrugExtra WHERE NSVCode = '" & dex.NSVCode & "'"
''
''   Set rsExtra = m_dbDrugExtra.CreateDynaset(strSql)
''
''   If rsExtra.RecordCount = 0 Then
''         rsExtra.AddNew
''         dex.id = GetField(rsExtra!id)
''         rsExtra!NSVCode = dex.NSVCode
''      Else
''         rsExtra.Edit
''      End If
''
''   'If dex.PIP <> 0 Then rsExtra!PIP = dex.PIP
''   '  £.p in DB currency type, single £.p in memory
''   If dex.RefPrice <> 0 Then rsExtra!RefPrice = dex.RefPrice
''
''   rsExtra!PriceAdjust = dex.PriceAdjust
''
''   rsExtra.Update
''
''   PutDrugExtra = True
''
''PutDrugExtra_cleanup:
''   On Error Resume Next
''      rsExtra.Close
''      Set rsExtra = Nothing
''
''      DrugExtraDB DB_CLOSE
''   On Error GoTo 0
''Exit Function
''PutDrugExtra_err:
''   PutDrugExtra = False
''Resume PutDrugExtra_cleanup
End Function

Private Sub QuesGetState(drug As DrugParameters, dex As DrugExtra)
Const ROUTINE = "QuesGetState"
Dim uErr As tErrorState
On Error GoTo QuesGetStateErrorHandler:
'__________________________

Dim intCounter As Integer
Dim strValue As String
   
   For intCounter = 1 To m_intControlCount
      strValue = ""
      strValue = QuesGetText(intCounter)

      Select Case Ques.lblDesc(intCounter).Tag
         Case QUES_ADJPRICE
            replace strValue, "..", ".", 0
            dex.PriceAdjust = CSng(Val(strValue)) - dex.RefPrice
      End Select
   Next intCounter

'__________________________
QuesGetStateCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

QuesGetStateErrorHandler:
   CaptureErrorState uErr
   Resume QuesGetStateCleanup:
'__________________________ End of Error Handling

End Sub

Private Sub QuesSetState(drug As DrugParameters, dex As DrugExtra)
Const ROUTINE = "QuesSetState"
Dim uErr As tErrorState
On Error GoTo QuesSetStateErrorHandler:
'__________________________

Dim intCounter As Integer
Dim strValue As String

   For intCounter = 1 To m_intControlCount
      strValue = ""
      Select Case Ques.lblDesc(intCounter).Tag
         Case QUES_STOREDESC
            strValue = Iff(Trim$(drug.LocalDescription)="",drug.storesdescription,drug.LocalDescription)     ' drug.storesdescription XN 9Jun15 98073 New local stores description ' !!** ATW/TH ? Use DrugDescription
            plingparse strValue, "!"
         Case QUES_NSVCODE
            strValue = drug.SisCode
         Case QUES_PIP
            strValue = Iff(Val(drug.pipcode) <> 0, Val(drug.pipcode), "")
         Case QUES_EAN
            strValue = trimz$(drug.barcode)
         Case QUES_REFPRICE
            If dex.RefPrice <> 0 Then
                  strValue = Format$(dex.RefPrice, "0.00")
               Else
                  strValue = "No Price"
               End If
         Case QUES_ADJPRICE
            strValue = Format$(dex.RefPrice + dex.PriceAdjust, "0.00")
      End Select
      If strValue <> "" Then
            QuesSetText intCounter, strValue
         End If
   Next intCounter

'__________________________
QuesSetStateCleanup:
   On Error Resume Next
      ' Clean up any object references here
   On Error GoTo 0
      ProcessError uErr, PROJECT & MODULE & ROUTINE
   Exit Sub
'__________________________ EXIT

'__________________________ Error handling

QuesSetStateErrorHandler:
   CaptureErrorState uErr
   Resume QuesSetStateCleanup:
'__________________________ End of Error Handling

End Sub

Private Sub DrugExtraDB(ByVal OpenClose As Integer)
'''  Description :  Reference-counted routine for opening/closing druge extention DB.
'''
''Const ROUTINE = "DrugExtraDB"
''Dim uErr As tErrorState
''On Error GoTo DrugExtraDBErrorHandler:
'''__________________________

''Const FILE = "\DrugExt.MDB"
''
''Static intRefCount As Integer
''Dim strPath As String
''
''   Select Case OpenClose
''      Case DB_OPEN
''         strPath = dispdata$ & FILE
''         strPath = PathParse(TxtD$(dispdata$ & INI_FILE, ISECTION_DIX, strPath, "PriceRefDB", 0))
''         Set m_dbDrugExtra = OpenDatabase(strPath)
''
''         intRefCount = intRefCount + 1
''
''      Case DB_CLOSE
''         intRefCount = intRefCount - 1
''         If intRefCount <= 0 Then
''               m_dbDrugExtra.Close
''               Set m_dbDrugExtra = Nothing
''            End If
''
''   End Select
''
'''__________________________
''DrugExtraDBCleanup:
''   On Error Resume Next
''      ' Clean up any object references here
''   On Error GoTo 0
''      ProcessError uErr, PROJECT & MODULE & ROUTINE
''   Exit Sub
'''__________________________ EXIT
''
'''__________________________ Error handling
''
''DrugExtraDBErrorHandler:
''   CaptureErrorState uErr
''   Resume DrugExtraDBCleanup:
'''__________________________ End of Error Handling

End Sub

Sub EditExtraBilling(drug As DrugParameters)
'08Mar07 PJC Added for CAPIO, if the interface is enabled the output the drug to a file.
'  Description :  Used to edit the information
'
'  Input :     drug        ;  The drug struct to edit for
'

''Dim dex As DrugExtra
''
''Dim success As Integer
''
''   ConstructView dispdata$ & "\STKMAINT.INI", "Views", "Data", QUES_VIEW_DIX, "", False, "Reference Price", m_intControlCount
''
''   success = GetDrugExtra(drug, dex)
''
''   If Not success Then dex.NSVCode = drug.SisCode
''
''   QuesSetState drug, dex
''
''   QuesCallbackMode = 18
''   QuesShow m_intControlCount
''
''   If Ques.Tag = "-1" Then
''         QuesGetState drug, dex
''         success = PutDrugExtra(dex)
''
''         If success = True Then               '08Mar07 PJC Added for CAPIO, if the interface is enabled the output the drug to a file.
''               If DrugExportEnabled() Then    '       "
''                     OutputDrug d, False, 0   '       "
''                     ClearDrugExportHeap      '       "
''                  End If                      '       "
''            End If                            '       "
''
''      End If
''
''   Unload Ques
   
End Sub

Function GetDrugExtra(drug As DrugParameters, dex As DrugExtra) As Integer
'  Fetches extra pricing from

'Dim qry As QueryDef
''Dim rsExtra As Snapshot
''Dim success As Integer
''Dim strSql As String
''
''On Error GoTo GetDrugExtra_err
''
''   DrugExtraDB DB_OPEN
''
''   strSql = "SELECT * FROM DrugExtra WHERE NSVCode = '" & drug.SisCode & "'"
''
''   Set rsExtra = m_dbDrugExtra.CreateSnapshot(strSql)
''
''   If rsExtra.RecordCount = 0 Then
''         dex.NSVCode = drug.SisCode
''         dex.PIP = Val(drug.MasterPip)
''         success = PutDrugExtra(dex)
''         Set rsExtra = m_dbDrugExtra.CreateSnapshot(strSql)
''      End If
''
''   dex.id = rsExtra!id
''   dex.NSVCode = rsExtra!NSVCode
''
''   dex.PIP = GetField(rsExtra!PIP)
''   If Trim$(drug.pipcode) <> "" Then
''         If IsNull(rsExtra!PIP.Value) Then ' Populate previously empty pips
''               dex.PIP = CLng(drug.MasterPip)
''               success = PutDrugExtra(dex)
''            Else
''               If dex.PIP <> CLng(drug.MasterPip) Then
''                     ' Should not get mismatched entries here - PIP should not change except in error!
''                     popmessagecr "!Drug Information Extension", "Mismathced PIP code on " & drug.SisCode
''                     Error 100001
''                  End If
''            End If
''      End If
''
''   ' Currency in DB, £.p in Single type
''   dex.RefPrice = GetField(rsExtra!RefPrice)
''   dex.PriceAdjust = GetField(rsExtra!PriceAdjust)
''
''   GetDrugExtra = True
''
''GetDrugExtra_cleanup:
''   On Error Resume Next
''      rsExtra.Close
''      Set rsExtra = Nothing
''      DrugExtraDB DB_CLOSE
''   On Error GoTo 0
''Exit Function
''GetDrugExtra_err:
''   Resume GetDrugExtra_cleanup
End Function

