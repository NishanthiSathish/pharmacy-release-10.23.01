VERSION 5.00
Begin VB.Form FrmPCTQTY 
   Caption         =   "PCT Claim Quantity"
   ClientHeight    =   9345
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   12765
   Icon            =   "frmPCTQTY.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   9345
   ScaleWidth      =   12765
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame fraPCTrxDetails 
      Caption         =   "PCT Prescription Details"
      Height          =   1695
      Left            =   360
      TabIndex        =   39
      Top             =   1800
      Width           =   12015
      Begin VB.Label lblEndorsementDate 
         Height          =   255
         Left            =   8880
         TabIndex        =   51
         Top             =   1080
         Width           =   2775
      End
      Begin VB.Label lblSpecialistEndorser 
         Height          =   255
         Left            =   8880
         TabIndex        =   50
         Top             =   720
         Width           =   2895
      End
      Begin VB.Label lblSpecialAuthorityNumber 
         Height          =   255
         Left            =   8880
         TabIndex        =   49
         Top             =   360
         Width           =   2655
      End
      Begin VB.Label lblPrescriptionFormNumber 
         Height          =   375
         Left            =   2760
         TabIndex        =   48
         Top             =   1080
         Width           =   3615
      End
      Begin VB.Label lblOncologyGroup 
         Height          =   255
         Left            =   2760
         TabIndex        =   47
         Top             =   720
         Width           =   3735
      End
      Begin VB.Label lblPrescriber 
         Height          =   255
         Left            =   2760
         TabIndex        =   46
         Top             =   360
         Width           =   3495
      End
      Begin VB.Label Label13 
         Caption         =   "Endorsement Date"
         Height          =   255
         Left            =   6720
         TabIndex        =   45
         Top             =   1080
         Width           =   1935
      End
      Begin VB.Label Label12 
         Caption         =   "Specialist Endorser"
         Height          =   255
         Left            =   6720
         TabIndex        =   44
         Top             =   720
         Width           =   2295
      End
      Begin VB.Label Label11 
         Caption         =   "Special Authority Number"
         Height          =   255
         Left            =   6720
         TabIndex        =   43
         Top             =   360
         Width           =   2055
      End
      Begin VB.Label Label10 
         Caption         =   "Prescription Form Number"
         Height          =   255
         Left            =   360
         TabIndex        =   42
         Top             =   1080
         Width           =   1935
      End
      Begin VB.Label Label7 
         Caption         =   "Oncology Patient Group"
         Height          =   255
         Left            =   360
         TabIndex        =   41
         Top             =   720
         Width           =   1935
      End
      Begin VB.Label lbl1 
         Caption         =   "Prescriber"
         Height          =   375
         Left            =   360
         TabIndex        =   40
         Top             =   360
         Width           =   1335
      End
   End
   Begin VB.TextBox txtSecondaryDailyDose 
      Height          =   345
      Index           =   2
      Left            =   8640
      MaxLength       =   8
      TabIndex        =   15
      Top             =   7080
      Visible         =   0   'False
      Width           =   855
   End
   Begin VB.TextBox txtSecondaryDailyDose 
      Height          =   345
      Index           =   1
      Left            =   8640
      MaxLength       =   8
      TabIndex        =   11
      Top             =   6480
      Visible         =   0   'False
      Width           =   855
   End
   Begin VB.TextBox txtSecondaryDailyDose 
      Height          =   345
      Index           =   0
      Left            =   8640
      MaxLength       =   8
      TabIndex        =   7
      Top             =   5880
      Visible         =   0   'False
      Width           =   855
   End
   Begin VB.TextBox txtSecondaryDose 
      Height          =   345
      Index           =   2
      Left            =   7440
      MaxLength       =   8
      TabIndex        =   14
      Top             =   7080
      Visible         =   0   'False
      Width           =   975
   End
   Begin VB.TextBox txtSecondaryDose 
      Height          =   345
      Index           =   1
      Left            =   7440
      MaxLength       =   8
      TabIndex        =   10
      Top             =   6480
      Visible         =   0   'False
      Width           =   975
   End
   Begin VB.TextBox txtSecondaryDose 
      Height          =   345
      Index           =   0
      Left            =   7440
      MaxLength       =   8
      TabIndex        =   6
      Top             =   5880
      Visible         =   0   'False
      Width           =   975
   End
   Begin VB.TextBox txtDailyDose 
      Height          =   405
      Left            =   8640
      TabIndex        =   3
      Top             =   4200
      Width           =   855
   End
   Begin VB.TextBox txtDose 
      Height          =   405
      Left            =   7440
      TabIndex        =   2
      Top             =   4200
      Width           =   975
   End
   Begin VB.TextBox txtWastegeQtySecondary 
      Height          =   345
      Index           =   2
      Left            =   11040
      MaxLength       =   8
      TabIndex        =   16
      Top             =   7080
      Visible         =   0   'False
      Width           =   975
   End
   Begin VB.TextBox txtWastegeQtySecondary 
      Height          =   345
      Index           =   1
      Left            =   11040
      MaxLength       =   8
      TabIndex        =   12
      Top             =   6480
      Visible         =   0   'False
      Width           =   975
   End
   Begin VB.TextBox txtWastegeQtySecondary 
      Height          =   345
      Index           =   0
      Left            =   11040
      MaxLength       =   8
      TabIndex        =   8
      Top             =   5880
      Visible         =   0   'False
      Width           =   975
   End
   Begin VB.TextBox txtWastageQty 
      Height          =   435
      Left            =   11040
      TabIndex        =   4
      Top             =   4200
      Width           =   975
   End
   Begin VB.TextBox txtSecondaryQty 
      Height          =   345
      Index           =   2
      Left            =   9720
      MaxLength       =   8
      TabIndex        =   13
      Top             =   7080
      Visible         =   0   'False
      Width           =   1095
   End
   Begin VB.TextBox txtSecondaryQty 
      Height          =   345
      Index           =   1
      Left            =   9720
      MaxLength       =   8
      TabIndex        =   9
      Top             =   6480
      Visible         =   0   'False
      Width           =   1095
   End
   Begin VB.TextBox txtSecondaryQty 
      Height          =   345
      Index           =   0
      Left            =   9720
      MaxLength       =   8
      TabIndex        =   5
      Top             =   5880
      Visible         =   0   'False
      Width           =   1095
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   495
      Left            =   6600
      TabIndex        =   18
      Top             =   8280
      Width           =   1695
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   495
      Left            =   3960
      TabIndex        =   17
      Top             =   8280
      Width           =   1695
   End
   Begin VB.TextBox txtQtyToClaim 
      Height          =   405
      Left            =   9720
      TabIndex        =   1
      Top             =   4200
      Width           =   1095
   End
   Begin VB.Line Line1 
      X1              =   120
      X2              =   12600
      Y1              =   4920
      Y2              =   4920
   End
   Begin VB.Label lblInfo 
      Height          =   735
      Left            =   1800
      TabIndex        =   38
      Top             =   960
      Width           =   9255
   End
   Begin VB.Label Label9 
      Caption         =   "Daily Dose"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   8640
      TabIndex        =   33
      Top             =   3720
      Width           =   975
   End
   Begin VB.Label Label8 
      Caption         =   "Dose"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   7680
      TabIndex        =   34
      Top             =   3720
      Width           =   615
   End
   Begin VB.Label Label4 
      Alignment       =   2  'Center
      Caption         =   "Wastage Qty"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   11160
      TabIndex        =   31
      Top             =   3720
      Width           =   735
   End
   Begin VB.Label lblUnitsSecondary 
      Height          =   255
      Index           =   2
      Left            =   12120
      TabIndex        =   27
      Top             =   7200
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.Label lblUnitsSecondary 
      Height          =   255
      Index           =   1
      Left            =   12120
      TabIndex        =   28
      Top             =   6600
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.Label lblPharmacode 
      Height          =   255
      Left            =   6240
      TabIndex        =   37
      Top             =   4320
      Width           =   1095
   End
   Begin VB.Label lblSecondaryPharmacode 
      Height          =   255
      Index           =   2
      Left            =   6240
      TabIndex        =   21
      Top             =   7200
      Visible         =   0   'False
      Width           =   1095
   End
   Begin VB.Label lblSecondaryPharmacode 
      Height          =   255
      Index           =   1
      Left            =   6240
      TabIndex        =   24
      Top             =   6600
      Visible         =   0   'False
      Width           =   1095
   End
   Begin VB.Label lblUnitsSecondary 
      Height          =   375
      Index           =   0
      Left            =   12120
      TabIndex        =   29
      Top             =   6000
      Visible         =   0   'False
      Width           =   495
   End
   Begin VB.Label lblSecondaryPharmacode 
      Height          =   255
      Index           =   0
      Left            =   6240
      TabIndex        =   25
      Top             =   6000
      Visible         =   0   'False
      Width           =   1095
   End
   Begin VB.Label LabelDescSecondary 
      Height          =   255
      Index           =   2
      Left            =   720
      TabIndex        =   22
      Top             =   7200
      Visible         =   0   'False
      Width           =   5295
   End
   Begin VB.Label LabelDescSecondary 
      Height          =   255
      Index           =   1
      Left            =   720
      TabIndex        =   23
      Top             =   6600
      Visible         =   0   'False
      Width           =   5295
   End
   Begin VB.Label LabelDescSecondary 
      Height          =   255
      Index           =   0
      Left            =   720
      TabIndex        =   26
      Top             =   6000
      Visible         =   0   'False
      Width           =   5295
   End
   Begin VB.Label LblSecondaryIngredients 
      Caption         =   "Secondary Ingredients"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   600
      TabIndex        =   20
      Top             =   5400
      Visible         =   0   'False
      Width           =   3735
   End
   Begin VB.Label lblUnits 
      Height          =   375
      Left            =   12120
      TabIndex        =   52
      Top             =   4320
      Width           =   615
   End
   Begin VB.Label Label6 
      Caption         =   "Pharmacode"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   6120
      TabIndex        =   35
      Top             =   3720
      Width           =   1095
   End
   Begin VB.Label Label5 
      Caption         =   "Units"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   12120
      TabIndex        =   30
      Top             =   3720
      Width           =   735
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Center
      Caption         =   "Active Qty To Claim"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   9720
      TabIndex        =   32
      Top             =   3720
      Width           =   1215
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Left            =   720
      TabIndex        =   19
      Top             =   4320
      Width           =   5295
   End
   Begin VB.Label Label2 
      Caption         =   "Primary Ingredient"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   600
      TabIndex        =   0
      Top             =   3720
      Width           =   3735
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      Caption         =   "Please confirm the quantity of active ingredients you wish to claim for"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   1200
      TabIndex        =   36
      Top             =   240
      Width           =   10335
   End
End
Attribute VB_Name = "FrmPCTQTY"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub CmdCancel_Click()
   Me.Hide
End Sub

Private Sub cmdOK_Click()
'05Jan12 TH Added check

Dim blnCheck As Boolean
Dim intloop As Integer
Dim strAns As String

   'Run through a check of claim quantities if there are some missing warn and check. If user opts out do not unload the page
   blnCheck = False
   'If Val(txtQtyToClaim.text) < 1 And txtQtyToClaim.Visible Then blnCheck = True   '16Jan12 TH Added visibility check as this then stops check on Full wastage
   If Val(txtQtyToClaim.text) <= 0 And txtQtyToClaim.Visible Then blnCheck = True   '14Feb12 TH TFS26928 '11Apr12 TH Altered to include = 0
   For intloop = 0 To 2
      'If Val(txtSecondaryQty(intloop).text) <1 And txtSecondaryQty(intloop).Visible Then blnCheck = True
      If Val(txtSecondaryQty(intloop).text) <= 0 And txtSecondaryQty(intloop).Visible Then blnCheck = True '11Apr12 TH Replaced (TFS31755)
   Next
   If blnCheck Then
      askwin "EMIS Health", "Not all ingredients have claim quantities. This will result in some ingredients not being claimed for PCT. Are you sure you wish to continue ", strAns, k
      If strAns = "Y" Then
         Me.Tag = "OK"
         Me.Hide
      End If
   Else
      Me.Tag = "OK"
      Me.Hide
   End If
End Sub

Private Sub Form_Activate()
   On Error Resume Next
   cmdCancel.SetFocus
   On Error GoTo 0
End Sub

Private Sub Form_Load()

   SetChrome Me
   CentreForm Me
   Me.Tag = ""
End Sub

Private Sub txtDailyDose_KeyPress(KeyAscii As Integer)
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
End Sub

Private Sub TxtDose_KeyPress(KeyAscii As Integer)

   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
   
End Sub

Private Sub txtQtyToClaim_KeyPress(KeyAscii As Integer)
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
End Sub

Private Sub txtSecondaryDailyDose_KeyPress(Index As Integer, KeyAscii As Integer)
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
End Sub

Private Sub txtSecondaryDose_KeyPress(Index As Integer, KeyAscii As Integer)
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
End Sub

Private Sub txtSecondaryQty_KeyPress(Index As Integer, KeyAscii As Integer)
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
End Sub

Private Sub txtWastageQty_KeyPress(KeyAscii As Integer)
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
End Sub

Private Sub txtWastegeQtySecondary_KeyPress(Index As Integer, KeyAscii As Integer)
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
End Sub
