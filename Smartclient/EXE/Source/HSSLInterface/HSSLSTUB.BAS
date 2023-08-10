Attribute VB_Name = "HSSLStub"
'----------------------------------------------------------------------------------------
'                                  HSSL Interface Stubs
'----------------------------------------------------------------------------------------
'14Nov08 CKJ Added DefBool & option explicit
'            Removed procedures, all of which were duplicated
'              OCXLaunch
'              RestrictedView
'              RxEditor
'----------------------------------------------------------------------------------------
Option Explicit
DefBool A-Z

Global freeflag As Integer 'stubbage

Sub askward(a$, OSite$, escd%)
      '14Dec01 TH Stubbage
End Sub

Function DblRound(TargetNum As Variant, DecPlaces%, AlwaysDown%) As Double
'14Nov08 Minimalist version created
   DblRound = CDbl(TargetNum)
End Function

Sub Issue_Callback()

End Sub

Sub GetLabelDetails(o_strLabelText As String, o_intBatchNumber As Integer, o_lngStartDate As Long)

   
End Sub

Function SpecificStockLabelLayout(a$, b$, c$) As Integer
'13Nov08 CKJ stub
End Function

Function GetLabelRequestID() As Long
'13Nov08 CKJ stub
   GetLabelRequestID = 0
End Function

Sub PrintStockLabels(IssueQty!, NSVCode$, WardCd$, NumofLabels%, NumOfDupes%)
'13Nov08 CKJ stub
End Sub

