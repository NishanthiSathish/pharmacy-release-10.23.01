VERSION 5.00
Begin VB.Form Finddrug 
   Appearance      =   0  'Flat
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Select Item"
   ClientHeight    =   6975
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   9330
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   9.75
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H00000000&
   Icon            =   "FINDDRUG.frx":0000
   KeyPreview      =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6975
   ScaleWidth      =   9330
   Begin VB.CommandButton cmdAllRoutes 
      Appearance      =   0  'Flat
      Caption         =   "All"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   320
      Left            =   7750
      Style           =   1  'Graphical
      TabIndex        =   43
      Top             =   6180
      Visible         =   0   'False
      Width           =   705
   End
   Begin VB.CommandButton CmdOk 
      Appearance      =   0  'Flat
      Caption         =   "&OK"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   320
      Left            =   8520
      Style           =   1  'Graphical
      TabIndex        =   44
      Top             =   6180
      Width           =   705
   End
   Begin VB.ListBox lstBNFchap 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   3150
      IntegralHeight  =   0   'False
      Left            =   0
      TabIndex        =   3
      TabStop         =   0   'False
      Top             =   0
      Visible         =   0   'False
      Width           =   7200
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "Z"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   25
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   38
      TabStop         =   0   'False
      Top             =   6660
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "Y"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   240
      Index           =   24
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   37
      TabStop         =   0   'False
      Top             =   6435
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "X"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   23
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   36
      TabStop         =   0   'False
      Top             =   6165
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "W"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   22
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   35
      TabStop         =   0   'False
      Top             =   5895
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "V"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   21
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   34
      TabStop         =   0   'False
      Top             =   5625
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "U"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   20
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   33
      TabStop         =   0   'False
      Top             =   5355
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "T"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   19
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   32
      TabStop         =   0   'False
      Top             =   5085
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "S"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   18
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   31
      TabStop         =   0   'False
      Top             =   4815
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "R"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   17
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   30
      TabStop         =   0   'False
      Top             =   4545
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "Q"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   16
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   29
      TabStop         =   0   'False
      Top             =   4275
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "P"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   15
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   28
      TabStop         =   0   'False
      Top             =   4005
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "O"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   14
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   27
      TabStop         =   0   'False
      Top             =   3735
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "N"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   13
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   26
      TabStop         =   0   'False
      Top             =   3465
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "M"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   12
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   25
      TabStop         =   0   'False
      Top             =   3195
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "L"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   11
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   24
      TabStop         =   0   'False
      Top             =   2925
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "K"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   10
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   23
      TabStop         =   0   'False
      Top             =   2655
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "J"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   9
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   22
      TabStop         =   0   'False
      Top             =   2385
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "I"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   8
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   21
      TabStop         =   0   'False
      Top             =   2115
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "H"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   7
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   20
      TabStop         =   0   'False
      Top             =   1845
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "G"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   6
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   19
      TabStop         =   0   'False
      Top             =   1575
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "F"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   5
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   18
      TabStop         =   0   'False
      Top             =   1305
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "E"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   4
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   17
      TabStop         =   0   'False
      Top             =   1035
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "D"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   3
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   16
      TabStop         =   0   'False
      Top             =   765
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "C"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   2
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   15
      TabStop         =   0   'False
      Top             =   495
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "B"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   270
      Index           =   1
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   14
      TabStop         =   0   'False
      Top             =   235
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton CmdLetter 
      Appearance      =   0  'Flat
      Caption         =   "A"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   270
      Index           =   0
      Left            =   9330
      Style           =   1  'Graphical
      TabIndex        =   13
      TabStop         =   0   'False
      Top             =   -15
      Visible         =   0   'False
      Width           =   300
   End
   Begin VB.CommandButton cmdExit 
      Appearance      =   0  'Flat
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   320
      Left            =   8520
      Style           =   1  'Graphical
      TabIndex        =   4
      TabStop         =   0   'False
      Top             =   6550
      Width           =   700
   End
   Begin VB.ListBox lstBNFsect 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   3855
      IntegralHeight  =   0   'False
      Left            =   360
      TabIndex        =   5
      TabStop         =   0   'False
      Top             =   3120
      Visible         =   0   'False
      Width           =   8115
   End
   Begin VB.ListBox lstBNFsectMaster 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   810
      Left            =   7440
      TabIndex        =   9
      TabStop         =   0   'False
      Top             =   1320
      Visible         =   0   'False
      Width           =   1665
   End
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   250
      Left            =   8370
      Top             =   315
   End
   Begin VB.ListBox lstDrugs 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   5490
      Left            =   -15
      Sorted          =   -1  'True
      TabIndex        =   0
      Top             =   285
      Width           =   9380
   End
   Begin VB.TextBox txtDrugsHdr 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000F&
      BorderStyle     =   0  'None
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
      Left            =   0
      MousePointer    =   1  'Arrow
      MultiLine       =   -1  'True
      TabIndex        =   6
      TabStop         =   0   'False
      Top             =   0
      Width           =   9285
   End
   Begin VB.TextBox TxtSelect 
      Appearance      =   0  'Flat
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Left            =   0
      TabIndex        =   2
      TabStop         =   0   'False
      Top             =   0
      Visible         =   0   'False
      Width           =   1275
   End
   Begin VB.OptionButton OptTradeOrApproved 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Caption         =   "&Trade"
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
      Height          =   240
      Index           =   1
      Left            =   3240
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   45
      Visible         =   0   'False
      Width           =   810
   End
   Begin VB.OptionButton OptTradeOrApproved 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Caption         =   "&Approved"
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
      Height          =   240
      Index           =   0
      Left            =   2025
      TabIndex        =   40
      TabStop         =   0   'False
      Top             =   45
      Value           =   -1  'True
      Visible         =   0   'False
      Width           =   1200
   End
   Begin VB.OptionButton OptTradeOrApproved 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Caption         =   "&BNF"
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
      Height          =   240
      Index           =   2
      Left            =   4200
      TabIndex        =   41
      TabStop         =   0   'False
      Top             =   45
      Visible         =   0   'False
      Width           =   690
   End
   Begin VB.OptionButton OptTradeOrApproved 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Caption         =   "&Wild card"
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
      Height          =   240
      Index           =   3
      Left            =   5040
      TabIndex        =   42
      TabStop         =   0   'False
      Top             =   45
      Visible         =   0   'False
      Width           =   1050
   End
   Begin VB.CommandButton CmdAll 
      Appearance      =   0  'Flat
      Caption         =   "&View All"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   270
      Left            =   8400
      Style           =   1  'Graphical
      TabIndex        =   8
      TabStop         =   0   'False
      Top             =   0
      Visible         =   0   'False
      Width           =   870
   End
   Begin VB.CommandButton cmdDelete 
      Caption         =   "Del"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   1320
      Style           =   1  'Graphical
      TabIndex        =   39
      TabStop         =   0   'False
      Top             =   30
      Visible         =   0   'False
      Width           =   615
   End
   Begin VB.Line Line1 
      Index           =   2
      X1              =   4230
      X2              =   4230
      Y1              =   6885
      Y2              =   5805
   End
   Begin VB.Line Line1 
      Index           =   1
      X1              =   2970
      X2              =   2970
      Y1              =   6885
      Y2              =   5805
   End
   Begin VB.Line Line1 
      Index           =   0
      X1              =   1710
      X2              =   1710
      Y1              =   6885
      Y2              =   5805
   End
   Begin VB.Label lblDrugInfo 
      Appearance      =   0  'Flat
      BackStyle       =   0  'Transparent
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
      Height          =   735
      Index           =   3
      Left            =   4230
      TabIndex        =   10
      Top             =   6210
      UseMnemonic     =   0   'False
      Width           =   5415
   End
   Begin VB.Label lblDrugInfo 
      Appearance      =   0  'Flat
      BackStyle       =   0  'Transparent
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
      Height          =   735
      Index           =   2
      Left            =   2970
      TabIndex        =   11
      Top             =   6210
      UseMnemonic     =   0   'False
      Width           =   1275
   End
   Begin VB.Label lblDrugInfo 
      Appearance      =   0  'Flat
      BackStyle       =   0  'Transparent
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
      Height          =   735
      Index           =   1
      Left            =   1710
      TabIndex        =   12
      Top             =   6210
      UseMnemonic     =   0   'False
      Width           =   1275
   End
   Begin VB.Label lblDrugInfo 
      Appearance      =   0  'Flat
      BackStyle       =   0  'Transparent
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
      Height          =   735
      Index           =   0
      Left            =   0
      TabIndex        =   7
      Top             =   6210
      UseMnemonic     =   0   'False
      Width           =   1725
   End
End
Attribute VB_Name = "Finddrug"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------------------------------------------------------------
' FindDrug.frm
' ------------
'25Oct94 CKJ Written. Provides form for drug selection including BNF codes.
'27Oct94 CKJ EditDrugMsg added on F2, not ideal as INPUTBOX$ is truly awful.
'20Jan95 CKJ mod to lstDrugs_GotFocus
'13Mar96 CKJ Started windows mods
'18Mar96 KR  Added Status Bar
'        KR  Used itemdata property to store drug id instead of end of list entry
'11Apr96 KR  Fixed F2 bug caused by now using .itemdata property of listbox
'27Sep96 KR  Added Centreform to Form_Load Event.  Also made windowstate = Normal
'26Jun98 CFY Added redraw parameter to 'updateinofline' calls.
'30Sep98 CKJ Modified for other screen resolutions including 1024x768 large fonts
'01Oct98 CKJ Added Bold option in terminal.ini
'28Oct98 CKJ Merged V: 15Oct98 TH  lstDrugs_KeyPress: Added change to tag on drug selection to stop form reloading
'17Nov99 CKJ/SF OptTradeOrApproved_GotFocus: added resume next
'09Apr01 CKJ cmdAll_Click: Now the mere presence of the View All button is enough to invoke the friendly list
'            Clicking the button hides itself, opening up the full list.
'            Form_Keydown: Ensure that EditDrugMsg is not called from a prescribing account
'            Form_Load: Removed bold from the bottom labels as the text did not fit
'            CmdExit_Click: Clear list on escape
'            CmdOK_Click: Clear list rather than use removeitem
'            MoveToSelection: Clear list rather than use removeitem
'03May01 CKJ cmdAll_Click, Form_Load: Set .enabled false as well
'14feb03 CKJ (merged 20Jun03) TxtDrugsHdr_Change written
'            NewSearchMethod: Removed params - pointless as never used
'16Feb04 CKJ Moved letters 60 twips to the right to make roon for mech disp indicator
'20Feb04 CKJ Added Swisslog lookup on F4 and by double clicking the stock level or location labels
'            F2 Notes available on double clicking the notes or prompt labels as well
'            Form_Activate: added resume next on setfocus
'24Feb04 CKJ Removed "FindDrug." from all controls
'            Form_Keydown: Added digits 0-9 to valid chars
'25Jul05 CKJ Hidden controls at top of form and buttons to right
'08oct08 CKJ Altered layout to support multi-level BNF lookup
'06May10 AJK cmdAllRoutes_Click: F0073627 Button and event added to load all off route products
'            AddOffRoute: F0073627 Added to load all of route products
'            Form_Load: F0073627 Check master switch to determine whether to enable all routes button
'16Aug13 CKJ Form_KeyDown: Removed call to NewSearchMethod. Use of Alt-B/T/W/A deprecated (TFS 42770)
'17Oct14 XN  AllowBNF: 88560 Control if allowed to show BNF
'            Form_KeyDown: 88560 Show BNF if user selects Alt+B
'05May15 XN  Form_KeyDown: 40374 If over 1 sec since key pressed then clear down the TxtSelect (used to typing to select the drug)
'			 MoveToSelection: 40374 re-enabled type letter to select a drug	
'-----------------------------------------------------------------------------
Option Explicit
DefInt A-Z

Dim intMouseButton As Integer      '20feb04 ckj
Dim intMouseLine As Integer
Dim bAllowBNF As Boolean      ' 17Oct14 XN  88560 Control if allowed to show BNF
Dim bForceBNF As Boolean      ' 7Nov14 XN  88560 Force to show BNF
Dim dtLastSearchTime As Date  ' 5May15 XN 40374 time that TxtSearch was last updated

Private Sub cmdAll_Click()
'09Apr01 CKJ Modified. Now the mere presence of the visible button is enough to invoke the friendly list
'            Clicking the button hides itself, opening up the full list.
'03May01 CKJ Set .enabled false as well

   'Tag = "Formulary"
   'Hide
   CmdAll.Visible = False
   CmdAll.Enabled = False                '03May01 CKJ Added
   NewSearchMethod "B"
   OptTradeOrApproved(2).Value = True

End Sub

Private Sub cmdAllRoutes_Click()
'06May10 AJK F0073627 Added event to load all off route products

   AddOffRoute
   
End Sub

Public Sub AddOffRoute()
'06May10 AJK F0073627 Added to load all of route products
   
   Select Case OCXheap("prescriptiontypedescription", "")
      Case "Infusion"
         FillDrugList "¦" & OCXheap("ProductID_Ingredient", "0"), "", False, True
      Case Else
         FillDrugList "¦" & OCXheap("ProductID", "0"), "", False, True
   End Select
   
   cmdAllRoutes.Enabled = False

End Sub

Private Sub CmdDelete_Click()
'10Feb99 ASC
   
   TxtSelect.Text = ""
   On Error Resume Next
   TxtSelect.SetFocus
   On Error GoTo 0
    
End Sub

Private Sub cmdExit_Click()
'escape pressed anywhere on the form
'09Apr01 CKJ Clear list on escape
   
   'If lstBNFsect.Visible And Not lstDrugs.Visible Then
   '      LstBNFchap_Gotfocus
   '      lstBNFchap.SetFocus
   '   Else

   lstBNFchap.ListIndex = -1  ' no BNF chapter selected
   lstBNFsect.ListIndex = -1  ' no BNF section selected
   lstDrugs.ListIndex = -1    ' no drug selected
   lstDrugs.Clear             '09Apr01 CKJ Clear list on escape
   Me.Hide                    '24feb04 CKJ removed FindDrug.

   '   End If

End Sub

Private Sub CmdLetter_Click(Index)
'10Feb99 ASC
Dim X%

   TxtSelect.Text = TxtSelect.Text & Chr$(65 + Index)
   MoveToSelection False, "", (TxtSelect.Text), ""

End Sub

Private Sub cmdOK_Click()
'10Feb99 ASC brought filling drug list to within form to avoid hiding form and save speed
'09Apr01 CKJ Clear list rather than use removeitem

Dim Section, drug$, Index$

   If lstDrugs.Visible = True Then
         Me.Hide
      Else
         Section = lstBNFsect.ListIndex
         If Section = -1 Then                  'no section chosen
               If lstBNFchap.ListIndex > -1 Then 'but chapter was chosen
                     drug$ = Left$(lstBNFchap.Text, 2)
                     Index$ = "bnf"
                  Else
                     k.escd = True
                  End If
            Else
               'drug$ = Left$(lstBNFsect.List(Section), 5)  '08oct08 CKJ altered to support multi-level BNF lookup
               drug = lstBNFsect.List(Section)              '   "
               replace drug, TB, Nul, 0                     '   "
               drug = trimz(drug)                           '   "
               Index$ = "bnf"
            End If
         lstDrugs.Clear

         FillDrugList drug$, Index$, Iff(Me.CmdOk.Tag = "MASTER", True, False) '14Feb07 TH Added ref to CmdOK as this was missing
         MoveToSelection False, "", (TxtSelect.Text), "" '14Mar99 ASC
         updateinfoline True
         updateinfoline True
      End If

End Sub

Private Sub F2Notes()
'20Feb04 CKJ Moved from form_keydown

   If lstDrugs.ListIndex >= 0 Then
         If siteinfo$("FormularyEXT", "") = "" Then
               EditDrugMsg (lstDrugs.ItemData(lstDrugs.ListIndex))
            End If
      End If

End Sub

Private Sub Form_Activate()
'30Sep98 CKJ Added txtDrugsHdr, removed DrugInfo (defunct 3D panel)
'            Tidied the procedure using active flag
'20Feb04 CKJ/TH needed for Swisslog etc

Dim i%, Active%

   dtLastSearchTime = Now
   Active = lstDrugs.Visible
   For i = 0 To 3
      lblDrugInfo(i).Visible = Active
   Next
   For i = 0 To 2
      Line1(i).Visible = Active
   Next
   txtDrugsHdr.Visible = Active
   
   If Active Then
         On Error Resume Next       '20Feb04 CKJ/TH needed for Swisslog etc
         lstDrugs.SetFocus
         On Error GoTo 0
      Else
         If lstBNFchap.Visible Then lstBNFchap.SetFocus
      End If

   TxtSelect.Text = ""             '25Apr99 ASC initialises form
   OptTradeOrApproved(0).Value = 1 '  "
   
   If bAllowBNF And bForceBNF Then     '7nov14 XN 88560 Show BNF if requested
         SelectBNFSection
    End If

End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
'11Apr96 KR  Fixed bug caused by conversion i.e. now using .itemdata property
'09Apr01 CKJ Ensure that EditDrugMsg is not called from a prescribing account
'16Feb04 CKJ Added F4 MechDisp Stock Enquiry
'24Feb04 CKJ Added digits 0-9 to valid chars
'17Oct14 XN  88560 Show BNF if user selects Alt+B
'5May15  XN  40374 If over 1 sec since key pressed then clear down the TxtSelect (used to typing to select the drug)

   If Shift = 0 Then
         Select Case KeyCode
            Case 113                                                                             'F2
               F2Notes
            
            '16feb04 CKJ added block
            Case 115                                                                             'F4 MechDisp Stock Enquiry
               MechDispStockEnquiry
                     
            Case 48 To 57, 64 To 91      '10Feb99 ASC                                            '24Feb04 CKJ Added digits 0-9
			   ' If over 1 sec since key pressed then clear down the TxtSelect (used to typing to select the drug) 5May15 XN 40374 
               If DateDiff("s", dtLastSearchTime, Now) > 1 Then TxtSelect.text = ""
               dtLastSearchTime = Now
               
               TxtSelect.Text = TxtSelect.Text & Chr$(KeyCode)
               MoveToSelection False, "", (TxtSelect.Text), ""
            
            Case 8
               If Len(TxtSelect.Text) > 0 Then
                     TxtSelect.Text = Left$(TxtSelect.Text, Len(TxtSelect.Text) - 1) '10Feb99 ASC
                  End If
         End Select
      End If

   'If Shift = 4 Then     '14Mar99 ASC
         'NewSearchMethod UCase$(Chr$(KeyCode))   '16Aug13 CKJ Removed: Use of Alt-B/T/W/A deprecated(TFS 42770)
   '   End If
   If bAllowBNF And Shift = 4 And UCase$(Chr$(KeyCode)) = "B" Then     '17Oct14 XN 88560 Show BNF if user selects Alt+B
         SelectBNFSection
    End If
      
End Sub

Private Sub Form_Load()
'01Oct98 CKJ Added Bold option
'09Apr01 CKJ Removed bold from the bottom labels as the text did not fit
'03May01 CKJ use enabled property of View All button instead of .visible
'06May10 AJK F0073627 Check master switch to determine whether to enable all routes button

Dim i%, isbold%

   SetChrome Me
   CentreForm Me
   If siteinfo$("FormularyEXT", "") = "" Then CmdAll.Enabled = False
   CmdAll.Visible = CmdAll.Enabled

   isbold = TrueFalse(terminal$("FindItemScreenFontBold", "0"))
   txtDrugsHdr.FontBold = isbold
   lstDrugs.FontBold = isbold
   For i = 0 To 3
      lblDrugInfo(i).FontBold = False
   Next
   KeyPreview = True
   '06May10 AJK F0073627 Check master switch to determine whether to enable all routes button
   If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "EnableOffRouteDispensing", 0)) Then
      cmdAllRoutes.Visible = True
   End If

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
'15Jul97 CKJ Added

   If UnloadMode <> 1 Then
         Cancel = True
         cmdExit_Click
      End If

End Sub

Private Sub lblDrugInfo_Click(Index As Integer)
'20Feb04 CKJ Added
'            Ready for right click popup menu

   'Line:   intMouseLine    1/2/3
   'Button: intMouseButton  1/2
   If intMouseButton = 2 Then    'single right click
         Select Case Index
            Case 0         'NSV/ASC/Local code
               '
            Case 1         'Live/Stocked/InUse
               '
            Case 2         'Formulary/Location/message
               '
            Case 3         'Stock/Tradename/Message
               '
            End Select
      End If
        
End Sub

Private Sub lblDrugInfo_DblClick(Index As Integer)
'20Feb04 CKJ Added
'
'Line:   intMouseLine    1/2/3
'Button: intMouseButton  1/2

'MouseLine            Panel 0           1               2              3
'   1                   NSV           Live           Formulary       Stock
'   2                   ASC           Stocked        Location        Tradename
'   3                   Local code    InUse          Notes [F2]      Notes

   If intMouseButton = 1 Then    'double clicked left mouse
         Select Case Index
            Case 0         'NSV/ASC/Local code
               '

            Case 1         'Live/Stocked/InUse
               '

            Case 2         'Formulary/Location/notes
               If intMouseLine = 2 Then MechDispStockEnquiry 'Location
            
            Case 3         'Stock/Tradename/notes
               Select Case intMouseLine
                  Case 1: MechDispStockEnquiry               'Stock
                  Case 3: F2Notes                            'Notes
                  End Select
            End Select
      End If

End Sub

Private Sub lblDrugInfo_MouseDown(Index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)
'20Feb04 CKJ Added

   intMouseButton = button
   intMouseLine = 1 + Y \ 195

End Sub

Private Sub lstBNFchap_Click()

Dim chap%, Item%

   If lstBNFchap.ListIndex = -1 Then
         lstBNFsect.Clear
      Else
         chap = Val(Left$(lstBNFchap.Text, 2))  'first 2 chars
         If lstBNFchap.ListCount Then
               If Val(Left$(lstBNFsect.Text, 2)) <> chap Then lstBNFsect.Clear
            End If
         For Item = 0 To lstBNFsectMaster.ListCount - 1
            If lstBNFsectMaster.ItemData(Item) = chap Then
                  lstBNFsect.AddItem lstBNFsectMaster.List(Item)
               End If
         Next
      End If

End Sub

Private Sub lstBNFchap_DblClick()

   lstBNFchap_KeyPress 13

End Sub

Private Sub LstBNFchap_Gotfocus()
'07Dec96
   
   If lstBNFchap.Visible Then
         If lstBNFchap.ListIndex = -1 Then
               On Error Resume Next
               lstBNFchap.ListIndex = 0
               On Error GoTo 0
            End If
      End If
   lstBNFsect.ListIndex = -1
   
   lstBNFchap.ForeColor = QBColor(0)
   lstBNFsect.ForeColor = QBColor(8)
''   lstBNFchap.FontBold = False
''   lstBNFsect.FontBold = True

End Sub

Private Sub lstBNFchap_KeyDown(KeyCode As Integer, Shift As Integer)
   
   Select Case KeyCode
      Case KEY_LEFT:  KeyCode = 0
      Case KEY_RIGHT: KeyCode = 0: SendKeys "{tab}"
      End Select

End Sub

Private Sub lstBNFchap_KeyPress(KeyAscii As Integer)

   If KeyAscii = KEY_RETURN Then cmdOK_Click

End Sub

Private Sub lstBNFsect_DblClick()

   lstBNFsect_KeyPress 13

End Sub

Private Sub lstBNFsect_GotFocus()
   
   If lstBNFsect.ListCount Then
         If lstBNFsect.ListIndex = -1 Then
            On Error Resume Next
            lstBNFsect.ListIndex = 0
            On Error GoTo 0
         End If
      End If

   lstBNFchap.ForeColor = QBColor(8)
   lstBNFsect.ForeColor = QBColor(0)
''   lstBNFchap.FontBold = True
''   lstBNFsect.FontBold = False

End Sub

Private Sub lstBNFsect_KeyDown(KeyCode As Integer, Shift As Integer)
   
   Select Case KeyCode
      Case KEY_LEFT:  KeyCode = 0: SendKeys "{tab}{tab}"
      Case KEY_RIGHT: KeyCode = 0
      End Select

End Sub

Private Sub lstBNFsect_KeyPress(KeyAscii As Integer)
   
   If KeyAscii = 13 Then cmdOK_Click

End Sub

Private Sub lstDrugs_DblClick()

   lstDrugs_KeyPress 13

End Sub

Private Sub lstDrugs_GotFocus()

   Timer1.Interval = 200 'millisecs
   Timer1.Enabled = True
   updateinfoline True

End Sub

Private Sub lstDrugs_KeyPress(KeyAscii As Integer)

   If KeyAscii = 13 Then    ' return
         If lstDrugs.ListIndex = -1 And lstDrugs.ListCount > 0 Then
               'Dispens.TGLabelList.MarqueeStyle = 3
               On Error Resume Next
               lstDrugs.ListIndex = 0
               On Error GoTo 0
            Else
               cmdOK_Click
            End If
      End If

End Sub

Private Sub lstDrugs_LostFocus()

   Timer1.Enabled = False

End Sub

Private Sub MechDispStockEnquiry()
'20Feb04 CKJ written
'19Dec06 CKJ Mechdisp port 8.6->9.7

Dim dlocal As DrugParameters
Dim foundPtr As Long
Dim strMachine As String
Dim strStock As String
Dim strMsg As String
Dim NumItems As Single
Dim strMessage As String    '19Dec06 CKJ Mechdisp port 8.6->9.7

   If lstDrugs.ListIndex >= 0 Then
      getdrug dlocal, (lstDrugs.ItemData(lstDrugs.ListIndex)), foundPtr, False
      If foundPtr& Then
         If MechDispEnquiry(dlocal, strMachine, strStock, strMessage) Then  '19Dec06 CKJ Mechdisp port 8.6->9.7
            If Len(strMessage) = 0 Then
               strMsg = strMachine & " stock level" & crlf & crlf
               
               If Len(strStock) Then
                  strMsg = strMsg & strStock & " "
                  Select Case Val(dlocal.convfact)
                     Case 1
                        strMsg = strMsg & Trim$(dlocal.PrintformV) & plural$(Val(strStock))
                     
                     Case Is > 1
                        strMsg = strMsg & "pack" & plural$(Val(strStock))
                        NumItems = Val(strStock) * Val(dlocal.convfact)
                        strMsg = strMsg & crlf & Format$(NumItems) & " " & Trim$(dlocal.PrintformV) & plural$(NumItems)
                     
                     Case Else
                        strMsg = strMsg & "pack" & plural$(Val(strStock))
                     
                     End Select
                     strMsg = strMsg & crlf & crlf
                  End If
               End If
            popmessagecr "#", strMsg & crlf
         Else
            If strMachine = "<UNKNOWN>" Then
               popmessagecr "#", "Dispensing machine not specified for this item"
            Else
               popmessagecr "#", strMachine & " not available" & cr & cr & strMessage     'Shows 'Swisslog' or 'Rowa' if it should have linked but could not
            End If
         End If
      End If
   End If

End Sub

Private Sub MoveToSelection(redo%, Index$, search$, Methodchar$)
'10Feb99 ASC
'5May15  XN  40374 re-enabled type letter to select a drug

Dim X%, char$

   Select Case Methodchar$
      Case "A": char$ = ""
      Case "T": char$ = "?"
      Case "W": char$ = "*"
      End Select

   If lstDrugs.Visible And Not redo% Then
          search$ = LTrim$(search$)     ' 5May15 XN 40374  best to remove space in search as well (as remove from drug details below)
      For X = 0 To lstDrugs.ListCount - 1
            'If InStr(lstDrugs.List(X), search$) > 0 And InStr(lstDrugs.List(X), search$) = 1 Then  5May15 XN 40374 re-enabled type letter to select a drug (believe space has been add to start of description that caused issue), also removed need for double InStr search
            If InStr(LTrim$(lstDrugs.List(X)), search$) = 1 Then
               lstDrugs.ListIndex = lstDrugs.ListCount - 1
               lstDrugs.ListIndex = X
               Exit For
            End If
      Next
   Else
      lstDrugs.Clear
      
      If Len(search$) > 0 Then
         FillDrugList char$ & search$, Index$, Iff(CmdOk.Tag = "MASTER", True, False)
      End If
   End If

End Sub

Private Sub NewSearchMethod(Methodchar$)
'10Feb99 ASC
'Remove chars if not what is wanted and add on chars requested. If both asked to be removed then assume no chars wanted i.e. approved name search

Dim findindex$

   If InStr("ATBW", Methodchar$) > 0 Then
         If Methodchar$ = "B" Then
               'TxtSelect = ""
               'SelectBNFSection "BNF", findindex$  '14Feb03 CKJ
               SelectBNFSection                     '   "        Removed params - pointless as never used
            Else
               MoveToSelection True, findindex$, (TxtSelect.Text), Methodchar$
            End If
      End If

   If lstDrugs.Visible = True Then
         lstDrugs.SetFocus
      Else
         If lstBNFchap.Visible = True Then
               lstBNFchap.SetFocus
            End If
      End If

End Sub

Private Sub OptTradeOrApproved_GotFocus(Index As Integer)
'25Apr99 ASC New procedure
'17Nov99 CKJ/SF Added resume next, since a search which returns >700 items
'            shows a modal warning which means that although lstDrugs is
'            visible, it's parent form does not have the focus.

   On Error Resume Next
   If lstDrugs.Visible Then
         lstDrugs.SetFocus
      Else
         lstBNFchap.SetFocus
      End If
   On Error GoTo 0

End Sub

Private Sub OptTradeOrApproved_MouseDown(Index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)
'10Feb99 ASC

   Select Case Index
      Case 0: NewSearchMethod "A"
      Case 1: NewSearchMethod "T"
      Case 2: NewSearchMethod "B"
      Case 3: NewSearchMethod "W"
      End Select
   
   OptTradeOrApproved(Index).Value = True

End Sub

Private Sub Timer1_Timer()

   updateinfoline False    '26Jun98 CFY Added Redraw parameter

End Sub

Private Sub txtDrugsHdr_Change()
'14feb03 CKJ written

   If Len(txtDrugsHdr.Text) Then
         lstDrugs.Top = txtDrugsHdr.Top + txtDrugsHdr.Height
      Else
         lstDrugs.Top = txtDrugsHdr.Top
      End If

   lstDrugs.Height = CmdOk.Top - lstDrugs.Top

End Sub

Private Sub txtDrugsHdr_Click()

   SendKeys "{tab}"

End Sub

Private Sub TxtSelect_KeyPress(KeyAscii As Integer)
'10Feb99 ASC

   KeyAscii = 0

End Sub

Private Sub TxtSelect_KeyUp(KeyCode As Integer, Shift As Integer)
'10Feb99 ASC
   
   MoveToSelection False, "", (TxtSelect.Text), UCase$(Chr$(KeyCode))

End Sub

'17Oct14 XN 88560 Control if allowed to show BNF
Public Property Get AllowBNF() As Boolean

   AllowBNF = bAllowBNF

End Property
   
'17Oct14 XN 88560 Control if allowed to show BNF
Public Property Let AllowBNF(allowBNFSearch As Boolean)

   bAllowBNF = allowBNFSearch

End Property

'7Nov14 XN 88560 Force the control into BNF mode on open
Public Property Get forceBNF() As Boolean

   forceBNF = bForceBNF

End Property
   
'7Nov14 XN 88560 Force the control into BNF mode on open
Public Property Let forceBNF(forceBNF As Boolean)

   bForceBNF = forceBNF

End Property