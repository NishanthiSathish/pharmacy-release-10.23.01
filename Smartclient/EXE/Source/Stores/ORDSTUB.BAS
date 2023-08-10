Attribute VB_Name = "OrdStub"
' Module: \winord\ordstub.bas
'04Jun99 SF added to hold stub procedures for patient billing
'06Mar00 SF added PyxisFlag: stub
'20Nov00 SF RxEditor: stub
'05Sep02 SF added stubs for S8 enhancement (enh#1274)
' 1oct03 CKJ Added SlaveModeEnabled()
' 1oct03 CKJ Removed SlaveModeEnabled() - now uses OCXlight
'17May04 CKJ Issue_Callback: Added

Option Explicit
DefInt A-Z

Dim m_LabelRequestID As Long '03Sep12 TH PSO

Sub AddNewRxerOnTheFly()
'13Jul03 TH Stubbage
End Sub

Function BillPatDispensQty%(stocklvl!, d!, negorpos%, patBillEscd%)
' stub for patient billing
End Function

Function BillPatient(Action%, txt$)
' stub for patient billing
End Function

Sub GetLabelDetails(a$, b%, c&)
'05Sep02 SF stub
End Sub

Function isPBS()
'stubbage
End Function

Sub Issue_Callback()
'17May04 CKJ Added
'            Repace with proper code if F7 Bag Label printing is desired from within the Issue screen
            
End Sub

Sub ItemTypeStatus(a%, b$, c$, d$)
'stubbage
End Sub

Function PBSDrugToDispens()
'stubbage
End Function

Function PBSGetBillitem(i%) As String
'stubbage
End Function

Function PBSGetExceptionalQty()
'stubbage
End Function

Sub PharmacistEditor(a%)
'05Sep02 SF stub
End Sub

Sub PharmacistInCharge(a%)
'05Sep02 SF stub
End Sub

Function PyxisFlag(a%)
'06Mar00 SF added stub
End Function

Sub RxEditor(a%, b%)
'20Nov00 SF added prescriber editor stub
End Sub

Sub SetKeepPBSDefaults(i%)
'stubbage
End Sub
Function getPrescriberID()
'04Nov07 TH Added
   getPrescriberID = 0
End Function
Function GetLabelRequestID() As Long
'06Jun08 TH Stubbage
GetLabelRequestID = m_LabelRequestID

End Function
Function IsPCTDispensing() As Boolean

End Function

Function PCTConfirmClaimQty(a!) As Boolean

End Function

Sub LogAllPCTDispensings()
'stub
End Sub

Sub setLabelRequestID(ByVal LabelRequestID As Long)
'03Sep12 TH PSO
m_LabelRequestID = LabelRequestID
End Sub
