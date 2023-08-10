VERSION 5.00
Begin VB.Form FrmPSO 
   Caption         =   "Patient Specific Ordering"
   ClientHeight    =   7620
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7305
   LinkTopic       =   "Form1"
   ScaleHeight     =   7620
   ScaleWidth      =   7305
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command2 
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   375
      Left            =   5760
      TabIndex        =   13
      Top             =   7080
      Width           =   1215
   End
   Begin VB.CommandButton Command1 
      Caption         =   "&OK"
      Height          =   375
      Left            =   4320
      TabIndex        =   12
      Top             =   7080
      Width           =   1215
   End
   Begin VB.Frame Frame4 
      Caption         =   "PSO Order Type"
      Height          =   1575
      Left            =   360
      TabIndex        =   2
      Top             =   1200
      Width           =   2415
      Begin VB.OptionButton OptOrderType 
         Caption         =   "Service"
         Height          =   255
         Index           =   1
         Left            =   360
         TabIndex        =   5
         Top             =   720
         Width           =   1575
      End
      Begin VB.OptionButton OptOrderType 
         Caption         =   "Equipment"
         Height          =   255
         Index           =   2
         Left            =   360
         TabIndex        =   4
         Top             =   1080
         Width           =   1575
      End
      Begin VB.OptionButton OptOrderType 
         Caption         =   "Medicinal"
         Height          =   255
         Index           =   0
         Left            =   360
         TabIndex        =   3
         Top             =   360
         Width           =   1575
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   "PSO Order Information"
      Height          =   1095
      Left            =   360
      TabIndex        =   1
      Top             =   5760
      Width           =   6615
      Begin VB.TextBox txtInstructions 
         Height          =   495
         Left            =   1800
         MaxLength       =   50
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   15
         Top             =   360
         Width           =   4455
      End
      Begin VB.Label Label5 
         Caption         =   "Enter Special Instructions"
         Height          =   495
         Left            =   240
         TabIndex        =   14
         Top             =   360
         Width           =   1215
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "PSO Renewal Information"
      Height          =   2415
      Left            =   360
      TabIndex        =   0
      Top             =   3000
      Width           =   6615
      Begin VB.TextBox txtRenewaleMail 
         Height          =   285
         Left            =   2160
         MaxLength       =   50
         TabIndex        =   11
         Top             =   1800
         Width           =   4095
      End
      Begin VB.TextBox txtRenewalTelephone 
         Height          =   285
         Left            =   2160
         MaxLength       =   35
         TabIndex        =   10
         Top             =   1200
         Width           =   4095
      End
      Begin VB.TextBox txtRenewalContact 
         Height          =   285
         Left            =   2160
         MaxLength       =   50
         TabIndex        =   9
         Top             =   600
         Width           =   4095
      End
      Begin VB.Label Label4 
         Caption         =   "eMail Address"
         Height          =   255
         Left            =   360
         TabIndex        =   8
         Top             =   1800
         Width           =   1575
      End
      Begin VB.Label Label3 
         Caption         =   "Telephone Number"
         Height          =   375
         Left            =   360
         TabIndex        =   7
         Top             =   1200
         Width           =   1695
      End
      Begin VB.Label Label2 
         Caption         =   "Renewal Contact"
         Height          =   375
         Left            =   360
         TabIndex        =   6
         Top             =   600
         Width           =   2175
      End
   End
   Begin VB.Label lblDesc 
      Height          =   855
      Left            =   360
      TabIndex        =   16
      Top             =   240
      Width           =   6615
   End
End
Attribute VB_Name = "FrmPSO"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
   Me.Hide
End Sub

Private Sub Command2_Click()
   k.escd = True
   Me.Hide
End Sub

Private Sub Form_Load()
   SetChrome Me  '08Jun05 TH Added
   CentreForm Me
End Sub

