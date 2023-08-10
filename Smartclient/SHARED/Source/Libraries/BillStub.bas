Attribute VB_Name = "BillStub"
Option Explicit

Public Function BillPatient(intStub As Integer, strStub As String) As Integer
'SQL STUB
End Function
Public Function PBSKeepDate() As Boolean
'SQL STUB
End Function
Public Function PBSDrugToDispens() As Boolean
'SQL STUB
End Function

Public Function isPBS() As Boolean
'SQL STUB
End Function
Public Function PBSGetBillitem(intStub As Integer) As String
'SQL STUB
End Function

Public Function PBSGetExceptionalQty() As Integer
'SQL STUB
End Function
Public Sub ItemTypeStatus(intA As Integer, str1 As String, str2 As String, str3 As String)
'SQL STUB
End Sub
Public Sub SetKeepPBSDefaults(int1 As Integer)
'SQL STUB
End Sub
Public Function BillPatDispensQty(int1 As Integer, int2 As Integer, int3 As Integer, int4 As Integer) As Boolean
'SQL STUB
End Function

Public Function PBSGetFoundDrugItem() As Boolean
'SQL STUB
End Function

Public Sub SetPBSNewScript(int1 As Integer)
'SQL STUB
End Sub
Public Sub PBSSetNewLabel()
'SQL STUB
End Sub
Public Sub PBSSetbillitems(int1 As Integer, str1 As String)
'SQL STUB
End Sub

Public Sub PBSUpdateIssuePanel()
'SQL STUB
End Sub
Public Function PBSReadBillitem(int1 As Integer) As String
'stub
End Function

Function getPrescriberID() As Long
'07Nov07 TH Added
getPrescriberID = 0
End Function
Function IsPCTDispensing() As Boolean
'stub
End Function

Function PCTConfirmClaimQty(a!) As Boolean
'stub
End Function

Function PCTDrugToDispens() As Boolean
'stub
End Function

Sub setPCTDose(PCTdoses!, nDays As Integer, a As Boolean)
'stub
End Sub

Sub LogAllPCTDispensings()
'stub
End Sub
