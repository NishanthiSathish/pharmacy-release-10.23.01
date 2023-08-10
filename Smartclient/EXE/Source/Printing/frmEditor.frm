VERSION 5.00
Begin VB.Form frmEditor 
   Caption         =   "Editor"
   ClientHeight    =   8010
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   17115
   LinkTopic       =   "Form1"
   ScaleHeight     =   8010
   ScaleWidth      =   17115
   StartUpPosition =   3  'Windows Default
End
Attribute VB_Name = "frmEditor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
On Error GoTo ErrHandler:
1:  Dim HighEdit As New TxControlEditor.TxWrapper
2:  Dim HE As New TxControlEditor.HeEmulator
3:    HighEdit.Shows (1)
Exit Sub
ErrHandler:
    MsgBox Err.Number & ":" & Err.Description & " on line " & Erl
End Sub
