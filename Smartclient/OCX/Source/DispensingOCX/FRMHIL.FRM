VERSION 5.00
Begin VB.Form frmHIL 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   Caption         =   "Health Information Leaflet Printing"
   ClientHeight    =   4050
   ClientLeft      =   8280
   ClientTop       =   8070
   ClientWidth     =   7950
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
   Icon            =   "FRMHIL.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4050
   ScaleWidth      =   7950
   Begin VB.CommandButton cmdNo 
      Appearance      =   0  'Flat
      Caption         =   "&No"
      Height          =   615
      Left            =   5160
      TabIndex        =   4
      Top             =   3120
      Width           =   1935
   End
   Begin VB.CommandButton cmdYes 
      Appearance      =   0  'Flat
      Caption         =   "&Yes"
      Height          =   615
      Left            =   1320
      TabIndex        =   5
      Top             =   3120
      Width           =   1815
   End
   Begin VB.Frame fraIndication 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      ForeColor       =   &H80000008&
      Height          =   1215
      Left            =   120
      TabIndex        =   0
      Top             =   240
      Width           =   7695
      Begin VB.TextBox txtIndication 
         Appearance      =   0  'Flat
         Height          =   285
         Left            =   2160
         MaxLength       =   30
         TabIndex        =   2
         Top             =   480
         Width           =   5175
      End
      Begin VB.Label Label1 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
         Caption         =   "Enter Indication"
         ForeColor       =   &H80000008&
         Height          =   255
         Left            =   360
         TabIndex        =   1
         Top             =   510
         Width           =   2895
      End
   End
   Begin VB.Label Label2 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      Caption         =   "OK to print a Health Informatics leaflet for this medicine and patient ?"
      ForeColor       =   &H80000008&
      Height          =   975
      Left            =   480
      TabIndex        =   3
      Top             =   1920
      Width           =   6735
   End
End
Attribute VB_Name = "frmHIL"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'07Apr10 AJK Ported from v8 for F0072782 & F0072542

Private Sub cmdNo_Click()
   Me.Tag = "N"
   Me.Hide

End Sub

Private Sub cmdYes_Click()
   Me.Tag = "Launch"
   Me.Hide
End Sub

Private Sub Form_Load()
   CentreForm Me
   If Me.Tag = "Y" Then
         cmdYes.SetFocus
      End If
End Sub

