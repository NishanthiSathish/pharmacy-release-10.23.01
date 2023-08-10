VERSION 5.00
Object = "{6B544935-E105-41C4-9512-DEC9C1119735}#1.0#0"; "ProductStockEditor.ocx"
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   12420
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   10605
   LinkTopic       =   "Form1"
   ScaleHeight     =   12420
   ScaleWidth      =   10605
   StartUpPosition =   3  'Windows Default
   Begin ProductStockEditor.ucPSE UcPSEditor 
      Height          =   10335
      Left            =   240
      TabIndex        =   3
      Top             =   840
      Width           =   10095
      _ExtentX        =   17806
      _ExtentY        =   18230
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Command2"
      Height          =   615
      Left            =   5160
      TabIndex        =   1
      Top             =   11400
      Width           =   3855
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   735
      Left            =   480
      TabIndex        =   0
      Top             =   11400
      Width           =   2895
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


Private Sub Command1_Click()
Dim blnOK As Boolean
blnOK = UcPSEditor.SetConnection(lngsess, 503, "")
End Sub

Private Sub Command2_Click()
Dim blnOK As Boolean
blnOK = UcPSEditor.RefreshState(lngsess, lngprod)
'88060

End Sub

