VERSION 5.00
Begin VB.Form FrmManuSyringes 
   Caption         =   "Syringe Label Manager"
   ClientHeight    =   7125
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4785
   LinkTopic       =   "Form1"
   ScaleHeight     =   7125
   ScaleWidth      =   4785
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame Frame1 
      Height          =   1455
      Left            =   240
      TabIndex        =   28
      Top             =   120
      Width           =   4215
      Begin VB.Label lblNHNumber 
         Height          =   255
         Left            =   1440
         TabIndex        =   34
         Top             =   960
         Width           =   2415
      End
      Begin VB.Label lblCaseno 
         Height          =   255
         Left            =   1440
         TabIndex        =   33
         Top             =   600
         Width           =   2415
      End
      Begin VB.Label lblNHNumberDesc 
         Height          =   255
         Left            =   120
         TabIndex        =   32
         Top             =   960
         Width           =   1215
      End
      Begin VB.Label Label5 
         Caption         =   "Case Number  :"
         Height          =   255
         Left            =   120
         TabIndex        =   31
         Top             =   600
         Width           =   1215
      End
      Begin VB.Label lblPatientName 
         Height          =   255
         Left            =   1440
         TabIndex        =   30
         Top             =   240
         Width           =   2655
      End
      Begin VB.Label Label4 
         Caption         =   "Patient Name  : "
         Height          =   255
         Left            =   120
         TabIndex        =   29
         Top             =   240
         Width           =   1095
      End
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   375
      Left            =   3480
      TabIndex        =   5
      Top             =   6480
      Width           =   1095
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   375
      Left            =   2160
      TabIndex        =   4
      Top             =   6480
      Width           =   1215
   End
   Begin VB.OptionButton optLabels 
      Caption         =   "Full And Part Split"
      Height          =   375
      Index           =   1
      Left            =   1320
      TabIndex        =   1
      Top             =   3840
      Width           =   1695
   End
   Begin VB.OptionButton optLabels 
      Caption         =   "Split Volume Equally"
      Height          =   375
      Index           =   0
      Left            =   1320
      TabIndex        =   0
      Top             =   3480
      Width           =   2655
   End
   Begin VB.Label lblProduct 
      Height          =   375
      Left            =   360
      TabIndex        =   27
      Top             =   1680
      Width           =   4215
   End
   Begin VB.Label NumofSyringes 
      Height          =   375
      Left            =   2400
      TabIndex        =   26
      Top             =   6600
      Visible         =   0   'False
      Width           =   1095
   End
   Begin VB.Label TotalVolume 
      Height          =   495
      Left            =   240
      TabIndex        =   25
      Top             =   7080
      Visible         =   0   'False
      Width           =   1455
   End
   Begin VB.Label TotalDose 
      Height          =   375
      Left            =   360
      TabIndex        =   24
      Top             =   6600
      Visible         =   0   'False
      Width           =   1335
   End
   Begin VB.Label lblVol 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Index           =   4
      Left            =   2760
      TabIndex        =   23
      Top             =   5760
      Width           =   1575
   End
   Begin VB.Label lblVol 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Index           =   3
      Left            =   2760
      TabIndex        =   22
      Top             =   5520
      Width           =   1575
   End
   Begin VB.Label lblVol 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Index           =   2
      Left            =   2760
      TabIndex        =   21
      Top             =   5280
      Width           =   1575
   End
   Begin VB.Label lblVol 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Index           =   1
      Left            =   2760
      TabIndex        =   20
      Top             =   5040
      Width           =   1575
   End
   Begin VB.Label lblVol 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Index           =   0
      Left            =   2760
      TabIndex        =   19
      Top             =   4800
      Width           =   1575
   End
   Begin VB.Label lblDose 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Index           =   4
      Left            =   1320
      TabIndex        =   18
      Top             =   5760
      Width           =   1455
   End
   Begin VB.Label lblDose 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Index           =   3
      Left            =   1320
      TabIndex        =   17
      Top             =   5520
      Width           =   1455
   End
   Begin VB.Label lblDose 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Index           =   2
      Left            =   1320
      TabIndex        =   16
      Top             =   5280
      Width           =   1455
   End
   Begin VB.Label lblDose 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Index           =   1
      Left            =   1320
      TabIndex        =   15
      Top             =   5040
      Width           =   1455
   End
   Begin VB.Label lblDose 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Height          =   255
      Index           =   0
      Left            =   1320
      TabIndex        =   14
      Top             =   4800
      Width           =   1455
   End
   Begin VB.Label lblNum 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "5"
      Height          =   255
      Index           =   4
      Left            =   480
      TabIndex        =   13
      Top             =   5760
      Width           =   855
   End
   Begin VB.Label lblNum 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "4"
      Height          =   255
      Index           =   3
      Left            =   480
      TabIndex        =   12
      Top             =   5520
      Width           =   855
   End
   Begin VB.Label lblNum 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "3"
      Height          =   255
      Index           =   2
      Left            =   480
      TabIndex        =   11
      Top             =   5280
      Width           =   855
   End
   Begin VB.Label lblNum 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "2"
      Height          =   255
      Index           =   1
      Left            =   480
      TabIndex        =   10
      Top             =   5040
      Width           =   855
   End
   Begin VB.Label lblNum 
      BackColor       =   &H8000000E&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "1"
      Height          =   255
      Index           =   0
      Left            =   480
      TabIndex        =   9
      Top             =   4800
      Width           =   855
   End
   Begin VB.Label Label3 
      BackColor       =   &H8000000D&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Volume on Label"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   2760
      TabIndex        =   8
      Top             =   4560
      Width           =   1575
   End
   Begin VB.Label Label2 
      BackColor       =   &H8000000D&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Dose On Label"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   1320
      TabIndex        =   7
      Top             =   4560
      Width           =   1455
   End
   Begin VB.Label Label1 
      BackColor       =   &H8000000D&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label"
      ForeColor       =   &H8000000E&
      Height          =   255
      Left            =   480
      TabIndex        =   6
      Top             =   4560
      Width           =   855
   End
   Begin VB.Label lblTotal 
      Height          =   255
      Left            =   360
      TabIndex        =   3
      Top             =   2160
      Width           =   4095
   End
   Begin VB.Label lblDesc 
      Caption         =   $"FrmManuSyringes.frx":0000
      Height          =   855
      Left            =   360
      TabIndex        =   2
      Top             =   2640
      Width           =   4095
   End
End
Attribute VB_Name = "FrmManuSyringes"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub CmdCancel_Click()
   k.escd = True
   Unload Me
End Sub

Private Sub cmdOK_Click()
   Me.Hide
   Me.Tag = "OK" '20Jun13 TH (TFS 66809) Added to help trap vaious ways of escaping form
End Sub

Private Sub Form_Load()

   SetChrome Me
   CentreForm Me
   
   'SyringeContainers True
   
End Sub

Private Sub optLabels_Click(Index As Integer)
  SyringeContainers IIf(Index = 0, True, False), CSng(Me.TotalDose.Caption), CSng(Me.TotalVolume.Caption), Me
End Sub
