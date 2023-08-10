VERSION 5.00
Object = "*\A..\RepeatDispensingCtl.vbp"
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   12420
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   17145
   LinkTopic       =   "Form1"
   ScaleHeight     =   12420
   ScaleWidth      =   17145
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command3 
      Caption         =   "Cancel"
      Height          =   495
      Left            =   5400
      TabIndex        =   4
      Top             =   960
      Width           =   1935
   End
   Begin RepeatDispensingCtl.RepeatDispense RepeatDispense1 
      Height          =   7695
      Left            =   720
      TabIndex        =   3
      Top             =   1920
      Width           =   15855
      _ExtentX        =   27966
      _ExtentY        =   13573
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Issue Batch"
      Height          =   495
      Left            =   3120
      TabIndex        =   1
      Top             =   960
      Width           =   1935
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Label Batch"
      Height          =   495
      Left            =   840
      TabIndex        =   0
      Top             =   960
      Width           =   1935
   End
   Begin VB.Label lblStatus 
      Caption         =   "Label1"
      Height          =   375
      Left            =   1800
      TabIndex        =   2
      Top             =   360
      Width           =   4695
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'me
'Const lngSession = 974
'Const lngSiteID = 503
'Const strFile = "F:\Errors edited.xml"

'aidan
Const lngSession = 320
Const lngSiteID = 272
'Const strFile = "F:\RptDisp.xml"
Const strFile = "F:\2ndUsable.xml"

Dim rpt As RepeatDispense

Private Sub Command1_Click()
Dim blnOK As Boolean
   
'Stop

Dim XML As String
Dim chan As Integer
   
   chan = FreeFile
   Open strFile For Binary As #chan
   XML = Space$(LOF(chan))
   Get #chan, , XML
   Close chan
   
'   blnOK = RepeatDispense1.LabelBatch(lngSession, lngSiteID, 0, "")
   blnOK = RepeatDispense1.ProcessBatch(lngSession, lngSiteID, "L", XML, "")
   lblStatus.Caption = Format$(blnOK)
   
End Sub

Private Sub Command2_Click()
Dim blnOK As Boolean

Stop
'   blnOK = RepeatDispense1.IssueBatch(lngSession, lngSiteID, 0, "")
   lblStatus.Caption = Format$(blnOK)
   
End Sub

Private Sub Command3_Click()

Stop
   RepeatDispense1.Cancel

End Sub
