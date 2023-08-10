VERSION 5.00
Object = "{1DA97B0A-8ADD-457B-A1BB-C7A6F9DA6190}#1.0#0"; "PNCtl.ocx"
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
   Begin PNCtl.PN PN1 
      Left            =   960
      Top             =   2400
      _extentx        =   25426
      _extenty        =   10821
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Cancel"
      Height          =   495
      Left            =   5400
      TabIndex        =   3
      Top             =   960
      Width           =   1935
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

'Dim rpt As RepeatDispense

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
   
'   blnOK = PN1.LabelBatch(lngSession, lngSiteID, 0, "")
   ''blnOK = PN1.ProcessPN(lngSession, lngSiteID, "L", XML, "")
   'blnOK = PN1.ProcessPN(lngSession, lngSiteID, "L", 3, 4)
   blnOK = PN1.ProcessPN(lngSession, lngSiteID, "P", 109686, XML, "", "")
   lblStatus.Caption = Format$(blnOK)
   
End Sub

Private Sub Command2_Click()
Dim blnOK As Boolean

Stop
'   blnOK = PN1.IssueBatch(lngSession, lngSiteID, 0, "")
   lblStatus.Caption = Format$(blnOK)
   
End Sub

Private Sub Command3_Click()

Stop
   PN1.Cancel

End Sub
