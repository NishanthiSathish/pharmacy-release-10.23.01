VERSION 5.00
Begin VB.Form frmPBSdebug 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Validate PBS Details"
   ClientHeight    =   4500
   ClientLeft      =   7410
   ClientTop       =   1410
   ClientWidth     =   4020
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   8.25
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   Icon            =   "PBSdebug.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4500
   ScaleWidth      =   4020
   Begin VB.CommandButton CmdCancel 
      Appearance      =   0  'Flat
      Caption         =   "Cancel"
      Height          =   375
      Left            =   240
      TabIndex        =   13
      Top             =   4080
      Width           =   1095
   End
   Begin VB.CommandButton CmdEdit 
      Appearance      =   0  'Flat
      Caption         =   "&Edit"
      Height          =   285
      Left            =   3480
      TabIndex        =   12
      Top             =   1080
      Width           =   495
   End
   Begin VB.TextBox TxtBrandPremium 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   2250
      TabIndex        =   11
      Top             =   1080
      Width           =   1185
   End
   Begin VB.CommandButton cmdOK 
      Appearance      =   0  'Flat
      Caption         =   "&Accept"
      Default         =   -1  'True
      Height          =   375
      Left            =   2400
      TabIndex        =   8
      Top             =   4080
      Width           =   1095
   End
   Begin VB.TextBox txtAmountToSafetyNet 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   2250
      TabIndex        =   3
      Top             =   2040
      Width           =   1185
   End
   Begin VB.TextBox txtCostToPatient 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   2250
      TabIndex        =   2
      Top             =   1560
      Width           =   1185
   End
   Begin VB.TextBox txtManufacturersCode 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   2250
      TabIndex        =   1
      Top             =   630
      Width           =   1185
   End
   Begin VB.TextBox txtPBScode 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   2250
      TabIndex        =   0
      Top             =   225
      Width           =   1185
   End
   Begin VB.Label LblBrandPremium 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Brand Premium         $"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   315
      TabIndex        =   10
      Top             =   1080
      Width           =   1695
   End
   Begin VB.Label lblWarning 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      BorderStyle     =   1  'Fixed Single
      Caption         =   $"PBSdebug.frx":030A
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   1410
      Left            =   240
      TabIndex        =   9
      Top             =   2520
      Width           =   3255
      WordWrap        =   -1  'True
   End
   Begin VB.Label lblSafetyNetAmount 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      Caption         =   "Amount to safety net $"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   195
      Left            =   315
      TabIndex        =   7
      Top             =   2040
      Width           =   1635
   End
   Begin VB.Label lblCostToPatient 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      Caption         =   "Cost to Patient          $"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   195
      Left            =   315
      TabIndex        =   6
      Top             =   1560
      Width           =   1635
   End
   Begin VB.Label lblManufacturersCode 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      Caption         =   "Manufacturers Code"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   195
      Left            =   315
      TabIndex        =   5
      Top             =   675
      Width           =   1590
   End
   Begin VB.Label lblPBScode 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      Caption         =   "PBS Code"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   195
      Left            =   315
      TabIndex        =   4
      Top             =   270
      Width           =   1590
   End
End
Attribute VB_Name = "frmPBSdebug"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
DefInt A-Z

'\libfiles\pbsdebug.frm
'No supporting BAS file, calls from patbill.bas

'16Nov99 SF added for the PBS billing module
'16Nov00 SF changed button "cmdOK" wording "OK" to "Accept"
'16Nov00 SF Form_QueryUnload: stops user closing form
'31Jan03 TH (PBSv4) MERGED
'31Jan03 TH cmdCancel_Click:,CmdEdit_Click:,TxtBrandPremium_GotFocus:,TxtBrandPremium_KeyUp: Written

Private Sub cmdCancel_Click()
'31Jan03 TH (PBSv4)
   cmdCancel.Tag = "-1"
   Me.Hide
End Sub

Private Sub CmdEdit_Click()
'31Jan03 TH (PBSv4)
    frmPBSdebug.TxtBrandPremium.Tag = Trim$(Format$(Val(txtCostToPatient.Text) - Val(TxtBrandPremium.Text)))
    PBSAlterBrandPremium

End Sub

Private Sub cmdOK_Click()

   Me.Hide
End Sub

Private Sub Form_Load()
   SetChrome Me
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
'16Nov00 SF added

   If UnloadMode <> 1 Then Cancel = True

End Sub

Private Sub txtAmountToSafetyNet_GotFocus()

   txtAmountToSafetyNet.SelLength = Len(txtAmountToSafetyNet.Text)

End Sub

Private Sub TxtBrandPremium_GotFocus()
'31Jan03 TH (PBSv4)
   TxtBrandPremium.SelLength = Len(TxtBrandPremium.Text)
   
End Sub

Private Sub TxtBrandPremium_KeyUp(KeyCode As Integer, Shift As Integer)
'31Jan03 TH (PBSv4)

Dim pat!, cost$

    pat! = frmPBSdebug.TxtBrandPremium.Tag + Val(frmPBSdebug.TxtBrandPremium.Text)
    If pat! >= 0 Then
          cost$ = Format$(pat!)
          poundsandpence cost$, False
          frmPBSdebug.txtCostToPatient.Text = Trim$(cost$)
       End If

End Sub

Private Sub txtCostToPatient_GotFocus()

   txtCostToPatient.SelLength = Len(txtCostToPatient.Text)

End Sub

Private Sub txtManufacturersCode_GotFocus()

   txtManufacturersCode.SelLength = Len(txtManufacturersCode.Text)

End Sub

Private Sub txtPBScode_GotFocus()

   txtPBScode.SelLength = Len(txtPBScode.Text)

End Sub

