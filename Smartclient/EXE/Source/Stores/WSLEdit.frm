VERSION 5.00
Begin VB.Form FrmWardStockEdit 
   Appearance      =   0  'Flat
   BackColor       =   &H80000004&
   Caption         =   "Form1"
   ClientHeight    =   4080
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   9945
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4080
   ScaleWidth      =   9945
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox txtPrintLabel 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   1680
      TabIndex        =   10
      Text            =   "Text1"
      Top             =   2760
      Width           =   615
   End
   Begin VB.TextBox txtQuantity 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   1680
      TabIndex        =   8
      Text            =   "Text1"
      Top             =   2160
      Width           =   1095
   End
   Begin VB.TextBox txtPackSize 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   1680
      TabIndex        =   6
      Text            =   "Text1"
      Top             =   1560
      Width           =   1095
   End
   Begin VB.TextBox txtDescription 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   1680
      TabIndex        =   4
      Text            =   "Text1"
      Top             =   960
      Width           =   7815
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   495
      Left            =   8160
      TabIndex        =   1
      Top             =   3480
      Width           =   1335
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   495
      Left            =   6480
      TabIndex        =   0
      Top             =   3480
      Width           =   1455
   End
   Begin VB.Label lblUnits 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   3000
      TabIndex        =   11
      Top             =   1680
      Width           =   1575
   End
   Begin VB.Label lblLabel 
      Caption         =   "&Label / DLO"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   240
      TabIndex        =   9
      Top             =   2880
      Width           =   2175
   End
   Begin VB.Label Label4 
      Caption         =   "&Quantity"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   240
      TabIndex        =   7
      Top             =   2280
      Width           =   2175
   End
   Begin VB.Label Label3 
      Caption         =   "&Pack Size"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   240
      TabIndex        =   5
      Top             =   1680
      Width           =   1455
   End
   Begin VB.Label Label2 
      Caption         =   "&Description"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   240
      TabIndex        =   3
      Top             =   1080
      Width           =   1815
   End
   Begin VB.Label Label1 
      Caption         =   "Edit Ward Stock List Line Details"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   240
      TabIndex        =   2
      Top             =   240
      Width           =   5655
   End
End
Attribute VB_Name = "FrmWardStockEdit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit


Private Sub cmdCancel_Click()
   Me.Hide
End Sub

Private Sub cmdOK_Click()
   Me.Tag = "SAVE"
   Me.Hide
End Sub

Private Sub Form_Load()
   SetChrome Me
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
'MsgBox "W"
End Sub

Private Sub txtDescription_KeyPress(KeyAscii As Integer)
   If (Len(txtDescription.Text) > 55 And KeyAscii <> 8) Then KeyAscii = 0
End Sub

Private Sub txtPackSize_KeyPress(KeyAscii As Integer)
'Primitive masking added
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
   If (Len(txtPackSize.Text) > 4 And KeyAscii <> 8) Then KeyAscii = 0
End Sub

Private Sub txtPrintLabel_KeyPress(KeyAscii As Integer)
'Primitive masking added
   If Not (KeyAscii = 32 Or KeyAscii = 8 Or KeyAscii = 80 Or KeyAscii = 112 Or KeyAscii = 68 Or KeyAscii = 100 Or KeyAscii = 27) Then KeyAscii = 0
   
   '22Jun12 TH DLO Added
   If ((Not (TrueFalse(TxtD(dispdata$ & "\winord.ini", "DLO", "N", "AllowDLO", 0)))) Or (sup.PrintPickTicket <> "Y")) And (KeyAscii = 100 Or KeyAscii = 68) Then '22Nov12 TH TFS 49691 Ensure default is off
      KeyAscii = 0
   End If
   
   If KeyAscii = 112 Then KeyAscii = 80
   If KeyAscii = 100 Then KeyAscii = 68
   
   If (Len(txtPrintLabel.Text) > 0 And KeyAscii <> 8) Then KeyAscii = 0
End Sub

Private Sub txtQuantity_KeyPress(KeyAscii As Integer)
'Primitive masking added
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
   If (Len(txtQuantity.Text) > 8 And KeyAscii <> 8) Then KeyAscii = 0
End Sub
