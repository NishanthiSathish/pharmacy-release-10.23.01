VERSION 5.00
Begin VB.Form Formula 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "f"
   ClientHeight    =   8415
   ClientLeft      =   2130
   ClientTop       =   705
   ClientWidth     =   10095
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
   Icon            =   "FORMULA.frx":0000
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   8415
   ScaleWidth      =   10095
   Begin VB.Frame Frame4 
      BackColor       =   &H8000000A&
      Height          =   7575
      Left            =   120
      TabIndex        =   7
      Top             =   720
      Width           =   9855
      Begin VB.Frame FraQA 
         Appearance      =   0  'Flat
         BackColor       =   &H80000000&
         Caption         =   "Quality Assurance Qty"
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
         Height          =   975
         Left            =   7380
         TabIndex        =   114
         Top             =   6360
         Width           =   1935
         Begin VB.CheckBox chkBond 
            Caption         =   "Issue via Bond Store"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   195
            Left            =   100
            TabIndex        =   117
            Top             =   680
            Width           =   240
         End
         Begin VB.TextBox txtQAQty 
            Appearance      =   0  'Flat
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
            Left            =   1350
            TabIndex        =   115
            Top             =   280
            Width           =   495
         End
         Begin VB.Label lblBond 
            Caption         =   "Issue via Bond Store"
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
            Left            =   360
            TabIndex        =   118
            Top             =   660
            Width           =   1500
         End
         Begin VB.Label Label1 
            Caption         =   "Units per Batch"
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
            Left            =   100
            TabIndex        =   116
            Top             =   340
            Width           =   1120
         End
      End
      Begin VB.CheckBox ChkDosingUNits 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
         Caption         =   "Dosing Units"
         DataField       =   "DosingUNits"
         DataSource      =   "FormulaData"
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
         Left            =   7965
         TabIndex        =   93
         Top             =   1200
         Width           =   1365
      End
      Begin VB.TextBox TxtQty 
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
         Height          =   285
         Index           =   0
         Left            =   6495
         TabIndex        =   92
         Top             =   1470
         Width           =   1320
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   295
         Index           =   14
         Left            =   1320
         TabIndex        =   91
         Top             =   5250
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Left            =   1320
         TabIndex        =   90
         Top             =   4980
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Left            =   1320
         TabIndex        =   89
         Top             =   4710
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Left            =   1320
         TabIndex        =   88
         Top             =   4440
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Left            =   1320
         TabIndex        =   87
         Top             =   4170
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Left            =   1320
         TabIndex        =   86
         Top             =   3900
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Left            =   1320
         TabIndex        =   85
         Top             =   3630
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Left            =   1320
         TabIndex        =   84
         Top             =   3360
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Left            =   1320
         TabIndex        =   83
         Top             =   3090
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Left            =   1320
         TabIndex        =   82
         Top             =   2820
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Left            =   1320
         TabIndex        =   81
         Top             =   2550
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Left            =   1320
         TabIndex        =   80
         Top             =   2280
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Left            =   1320
         TabIndex        =   79
         Top             =   2010
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
         DataSource      =   "FormulaData"
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
         Index           =   1
         Left            =   1320
         TabIndex        =   78
         Top             =   1740
         Width           =   5190
      End
      Begin VB.TextBox TxtDescription 
         Appearance      =   0  'Flat
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
         Index           =   0
         Left            =   1320
         TabIndex        =   77
         Top             =   1470
         Width           =   5190
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   295
         Index           =   14
         Left            =   6495
         TabIndex        =   76
         Top             =   5250
         Width           =   1320
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   13
         Left            =   6495
         TabIndex        =   75
         Top             =   4980
         Width           =   1320
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   12
         Left            =   6495
         TabIndex        =   74
         Top             =   4710
         Width           =   1320
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   11
         Left            =   6495
         TabIndex        =   73
         Top             =   4440
         Width           =   1320
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   10
         Left            =   6495
         TabIndex        =   72
         Top             =   4170
         Width           =   1320
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   9
         Left            =   6495
         TabIndex        =   71
         Top             =   3900
         Width           =   1320
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   8
         Left            =   6495
         TabIndex        =   70
         Top             =   3630
         Width           =   1320
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   7
         Left            =   6495
         TabIndex        =   69
         Top             =   3360
         Width           =   1320
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   6
         Left            =   6495
         TabIndex        =   68
         Top             =   3090
         Width           =   1320
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   5
         Left            =   6495
         TabIndex        =   67
         Top             =   2820
         Width           =   1320
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   4
         Left            =   6495
         TabIndex        =   66
         Top             =   2550
         Width           =   1320
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   295
         Index           =   14
         Left            =   360
         TabIndex        =   65
         Top             =   5250
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Left            =   360
         TabIndex        =   64
         Top             =   4980
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Left            =   360
         TabIndex        =   63
         Top             =   4710
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Left            =   360
         TabIndex        =   62
         Top             =   4440
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Left            =   360
         TabIndex        =   61
         Top             =   4170
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Left            =   360
         TabIndex        =   60
         Top             =   3900
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Left            =   360
         TabIndex        =   59
         Top             =   3630
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Left            =   360
         TabIndex        =   58
         Top             =   3360
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Left            =   360
         TabIndex        =   57
         Top             =   3090
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Left            =   360
         TabIndex        =   56
         Top             =   2820
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Left            =   360
         TabIndex        =   55
         Top             =   2550
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Left            =   360
         TabIndex        =   54
         Top             =   2280
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Left            =   360
         TabIndex        =   53
         Top             =   2015
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Index           =   1
         Left            =   360
         TabIndex        =   52
         Top             =   1740
         Width           =   975
      End
      Begin VB.TextBox TxtCode 
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
         Height          =   285
         Index           =   0
         Left            =   360
         TabIndex        =   51
         Top             =   1470
         Width           =   975
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   2
         Left            =   6495
         TabIndex        =   50
         Top             =   2010
         Width           =   1320
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   3
         Left            =   6495
         TabIndex        =   49
         Top             =   2280
         Width           =   1320
      End
      Begin VB.TextBox TxtQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         DataSource      =   "FormulaData"
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
         Height          =   285
         Index           =   1
         Left            =   6495
         TabIndex        =   48
         Top             =   1740
         Width           =   1320
      End
      Begin VB.CheckBox ChkBlisterPack 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
         Caption         =   "Blister Pack"
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
         Left            =   6525
         TabIndex        =   47
         Top             =   1200
         Width           =   1365
      End
      Begin VB.Frame Frame1 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
         Caption         =   "&Layouts"
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
         Height          =   1680
         Left            =   3870
         TabIndex        =   36
         Top             =   5655
         Width           =   3480
         Begin VB.ComboBox CmbLayout 
            Appearance      =   0  'Flat
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   315
            Index           =   0
            Left            =   360
            TabIndex        =   42
            Top             =   600
            Width           =   1455
         End
         Begin VB.TextBox TxtPatsPerSheet 
            Appearance      =   0  'Flat
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   330
            Index           =   0
            Left            =   1890
            TabIndex        =   41
            Top             =   585
            Width           =   465
         End
         Begin VB.CommandButton CmdEdit 
            Appearance      =   0  'Flat
            Caption         =   "Edit ..."
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   330
            Index           =   0
            Left            =   2520
            TabIndex        =   40
            Top             =   585
            Width           =   825
         End
         Begin VB.ComboBox CmbLayout 
            Appearance      =   0  'Flat
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   315
            Index           =   1
            Left            =   360
            TabIndex        =   39
            Top             =   990
            Width           =   1455
         End
         Begin VB.TextBox TxtPatsPerSheet 
            Appearance      =   0  'Flat
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   330
            Index           =   1
            Left            =   1890
            TabIndex        =   38
            Top             =   990
            Width           =   465
         End
         Begin VB.CommandButton CmdEdit 
            Appearance      =   0  'Flat
            Caption         =   "Edit ..."
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   330
            Index           =   1
            Left            =   2520
            TabIndex        =   37
            Top             =   990
            Width           =   825
         End
         Begin VB.Label Label4 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "1"
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
            Height          =   285
            Index           =   3
            Left            =   135
            TabIndex        =   46
            Top             =   630
            Width           =   240
         End
         Begin VB.Label Label20 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "Name"
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
            Left            =   360
            TabIndex        =   45
            Top             =   315
            Width           =   1230
         End
         Begin VB.Label Label19 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "Patients per Sheet"
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
            Height          =   420
            Left            =   1890
            TabIndex        =   44
            Top             =   135
            Width           =   915
         End
         Begin VB.Label Label4 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "2"
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
            Height          =   285
            Index           =   2
            Left            =   135
            TabIndex        =   43
            Top             =   1035
            Width           =   240
         End
      End
      Begin VB.Frame Frame2 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
         Caption         =   "La&bels"
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
         Height          =   610
         Left            =   7380
         TabIndex        =   32
         Top             =   5655
         Width           =   1950
         Begin VB.TextBox Text3 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            DataField       =   "ExtraLabels"
            DataSource      =   "FormulaData"
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
            Left            =   1350
            TabIndex        =   34
            Top             =   240
            Width           =   495
         End
         Begin VB.TextBox Text2 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            DataField       =   "NumofLabels"
            DataSource      =   "FormulaData"
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
            Left            =   135
            TabIndex        =   33
            Top             =   240
            Width           =   495
         End
         Begin VB.Label Label18 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BackStyle       =   0  'Transparent
            Caption         =   "Labels +"
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
            Left            =   675
            TabIndex        =   35
            Top             =   270
            Width           =   690
         End
      End
      Begin VB.Frame Frame3 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
         Caption         =   "Information"
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
         Height          =   1680
         Left            =   360
         TabIndex        =   23
         Top             =   5655
         Width           =   3480
         Begin VB.Label LblStatusTag 
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
            Left            =   90
            TabIndex        =   113
            Top             =   1350
            Width           =   3255
         End
         Begin VB.Label LblStatus 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "LblStatus"
            DataField       =   "Authorised_Date"
            DataSource      =   "FormulaData"
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
            Left            =   1710
            TabIndex        =   31
            Top             =   1080
            Width           =   1680
         End
         Begin VB.Label LblAuthorised 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "LblAuthorised"
            DataField       =   "Authorised"
            DataSource      =   "FormulaData"
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
            Left            =   1710
            TabIndex        =   30
            Top             =   540
            Width           =   1635
         End
         Begin VB.Label LblTotQty 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BackStyle       =   0  'Transparent
            Caption         =   "LblTotQty"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   -1  'True
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H80000008&
            Height          =   255
            Left            =   945
            TabIndex        =   29
            Top             =   270
            Width           =   1290
         End
         Begin VB.Label Label14 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BackStyle       =   0  'Transparent
            Caption         =   "Saved by"
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
            Left            =   90
            TabIndex        =   28
            Top             =   540
            Width           =   1590
         End
         Begin VB.Label Label13 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BackStyle       =   0  'Transparent
            Caption         =   "Batch total"
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
            Left            =   90
            TabIndex        =   27
            Top             =   270
            Width           =   840
         End
         Begin VB.Label Label12 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "Approved by"
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
            Left            =   90
            TabIndex        =   26
            Top             =   810
            Width           =   1590
         End
         Begin VB.Label Label11 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "Status"
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
            Left            =   90
            TabIndex        =   25
            Top             =   1080
            Width           =   1545
         End
         Begin VB.Label Lbl2ndAuth 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "Lbl2ndAuth"
            DataField       =   "Authorised2"
            DataSource      =   "FormulaData"
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
            Left            =   1710
            TabIndex        =   24
            Top             =   810
            Width           =   1635
         End
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   0
         ItemData        =   "FORMULA.frx":030A
         Left            =   8235
         List            =   "FORMULA.frx":0323
         TabIndex        =   22
         Top             =   1455
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   1
         ItemData        =   "FORMULA.frx":035D
         Left            =   8235
         List            =   "FORMULA.frx":0376
         TabIndex        =   21
         Top             =   1725
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   2
         ItemData        =   "FORMULA.frx":03B0
         Left            =   8235
         List            =   "FORMULA.frx":03C9
         TabIndex        =   20
         Top             =   2010
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   3
         ItemData        =   "FORMULA.frx":0403
         Left            =   8235
         List            =   "FORMULA.frx":041C
         TabIndex        =   19
         Top             =   2280
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   4
         ItemData        =   "FORMULA.frx":0456
         Left            =   8235
         List            =   "FORMULA.frx":046F
         TabIndex        =   18
         Top             =   2550
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   5
         ItemData        =   "FORMULA.frx":04A9
         Left            =   8235
         List            =   "FORMULA.frx":04C2
         TabIndex        =   17
         Top             =   2820
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   6
         ItemData        =   "FORMULA.frx":04FC
         Left            =   8235
         List            =   "FORMULA.frx":0515
         TabIndex        =   16
         Top             =   3090
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   7
         ItemData        =   "FORMULA.frx":054F
         Left            =   8235
         List            =   "FORMULA.frx":0568
         TabIndex        =   15
         Top             =   3360
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   8
         ItemData        =   "FORMULA.frx":05A2
         Left            =   8235
         List            =   "FORMULA.frx":05BB
         TabIndex        =   14
         Top             =   3630
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   9
         ItemData        =   "FORMULA.frx":05F5
         Left            =   8235
         List            =   "FORMULA.frx":060E
         TabIndex        =   13
         Top             =   3900
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   10
         ItemData        =   "FORMULA.frx":0648
         Left            =   8235
         List            =   "FORMULA.frx":0661
         TabIndex        =   12
         Top             =   4170
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   11
         ItemData        =   "FORMULA.frx":069B
         Left            =   8235
         List            =   "FORMULA.frx":06B4
         TabIndex        =   11
         Top             =   4440
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   12
         ItemData        =   "FORMULA.frx":06EE
         Left            =   8235
         List            =   "FORMULA.frx":0707
         TabIndex        =   10
         Top             =   4695
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   13
         ItemData        =   "FORMULA.frx":0741
         Left            =   8235
         List            =   "FORMULA.frx":075A
         TabIndex        =   9
         Top             =   4980
         Width           =   1215
      End
      Begin VB.ComboBox CSCmbType 
         Height          =   315
         Index           =   14
         ItemData        =   "FORMULA.frx":0794
         Left            =   8235
         List            =   "FORMULA.frx":07AD
         TabIndex        =   8
         Top             =   5250
         Width           =   1215
      End
      Begin VB.Label lblVersion 
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   18
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   8400
         TabIndex        =   112
         Top             =   360
         Width           =   1215
      End
      Begin VB.Label LblFormulaStatus 
         Alignment       =   2  'Center
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   18
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Left            =   120
         TabIndex        =   111
         Top             =   480
         Width           =   9615
      End
      Begin VB.Label LblDescription 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BackStyle       =   0  'Transparent
         ForeColor       =   &H80000008&
         Height          =   210
         Left            =   1440
         TabIndex        =   110
         Top             =   1245
         Width           =   4935
      End
      Begin VB.Label LblNSVcode 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BackStyle       =   0  'Transparent
         Caption         =   "Look Up Code"
         DataField       =   "NSVcode"
         DataSource      =   "FormulaData"
         ForeColor       =   &H80000008&
         Height          =   210
         Left            =   360
         TabIndex        =   109
         Top             =   1245
         Width           =   960
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   300
         Index           =   14
         Left            =   7800
         TabIndex        =   108
         Top             =   5250
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   13
         Left            =   7800
         TabIndex        =   107
         Top             =   4980
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   12
         Left            =   7800
         TabIndex        =   106
         Top             =   4710
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   11
         Left            =   7800
         TabIndex        =   105
         Top             =   4440
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   10
         Left            =   7800
         TabIndex        =   104
         Top             =   4170
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   9
         Left            =   7800
         TabIndex        =   103
         Top             =   3900
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   8
         Left            =   7800
         TabIndex        =   102
         Top             =   3630
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   7
         Left            =   7800
         TabIndex        =   101
         Top             =   3360
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   6
         Left            =   7800
         TabIndex        =   100
         Top             =   3090
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   5
         Left            =   7800
         TabIndex        =   99
         Top             =   2820
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   4
         Left            =   7800
         TabIndex        =   98
         Top             =   2550
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   3
         Left            =   7800
         TabIndex        =   97
         Top             =   2280
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   2
         Left            =   7800
         TabIndex        =   96
         Top             =   2010
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   1
         Left            =   7800
         TabIndex        =   95
         Top             =   1740
         Width           =   480
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   285
         Index           =   0
         Left            =   7800
         TabIndex        =   94
         Top             =   1470
         Width           =   480
      End
   End
   Begin VB.CommandButton cmdReturn 
      Caption         =   "&Return"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   8000
      TabIndex        =   6
      Top             =   0
      Width           =   2000
   End
   Begin VB.CommandButton CmdAuthorise 
      Appearance      =   0  'Flat
      Caption         =   "&Authorise"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   2000
   End
   Begin VB.CommandButton CmdCancel 
      Appearance      =   0  'Flat
      Cancel          =   -1  'True
      Caption         =   "&Exit"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   6000
      TabIndex        =   3
      Top             =   0
      Width           =   2000
   End
   Begin VB.CommandButton CmdNew 
      Appearance      =   0  'Flat
      Caption         =   "&New Formula"
      Height          =   375
      Left            =   7110
      TabIndex        =   4
      Top             =   6120
      Visible         =   0   'False
      Width           =   2175
   End
   Begin VB.CommandButton CmdDelete 
      Appearance      =   0  'Flat
      Caption         =   "&Delete Formula"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   4000
      TabIndex        =   2
      Top             =   0
      Width           =   2000
   End
   Begin VB.CommandButton CmdCompound 
      Appearance      =   0  'Flat
      Caption         =   "&Print and Issue"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   2000
      TabIndex        =   1
      Top             =   0
      Width           =   2000
   End
   Begin VB.Data FormulaData 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Connect         =   "Access 2000;"
      DatabaseName    =   ""
      DefaultCursorType=   0  'DefaultCursor
      DefaultType     =   2  'UseODBC
      Exclusive       =   0   'False
      Height          =   315
      Left            =   7380
      Options         =   0
      ReadOnly        =   0   'False
      RecordsetType   =   1  'Dynaset
      RecordSource    =   ""
      Top             =   5760
      Visible         =   0   'False
      Width           =   1140
   End
   Begin VB.Label Label2 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   -1  'True
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   345
      Left            =   8640
      TabIndex        =   5
      Top             =   15
      Width           =   840
   End
   Begin VB.Line Line1 
      X1              =   9660
      X2              =   0
      Y1              =   360
      Y2              =   360
   End
   Begin VB.Line Line2 
      X1              =   9660
      X2              =   0
      Y1              =   0
      Y2              =   0
   End
   Begin VB.Menu MnuFormula 
      Caption         =   "&Formula"
      Begin VB.Menu MnuNew 
         Caption         =   "&New Formula"
      End
      Begin VB.Menu MnuDelete 
         Caption         =   "&Delete Formula"
      End
      Begin VB.Menu mnuline1 
         Caption         =   "-"
      End
      Begin VB.Menu MnuPrint 
         Caption         =   "&Print worksheet"
         Index           =   0
      End
      Begin VB.Menu MnuPrint 
         Caption         =   "Print Worksheet Pre&view"
         Index           =   1
      End
      Begin VB.Menu MnuLine2 
         Caption         =   "-"
      End
      Begin VB.Menu MnuExit 
         Caption         =   "E&xit"
      End
   End
   Begin VB.Menu MnuFormat 
      Caption         =   "F&ormat"
      Begin VB.Menu MnuHeaderfooter 
         Caption         =   "La&bel"
         Index           =   4
      End
      Begin VB.Menu MnuHeaderfooter 
         Caption         =   "&Method"
         Index           =   5
      End
   End
   Begin VB.Menu MnuOptS 
      Caption         =   "Op&tions"
      Begin VB.Menu MnuOpt1 
         Caption         =   "Extra &Labels (Patient Issues)"
         Begin VB.Menu MnuOptSpareLbl 
            Caption         =   "Spare Labels Per Issue"
            Index           =   1
         End
         Begin VB.Menu MnuOptSpareLbl 
            Caption         =   "Spare Labels Per Dose"
            Index           =   2
         End
      End
   End
   Begin VB.Menu MnuHelp 
      Caption         =   "&Help"
      Begin VB.Menu MnuAbout 
         Caption         =   "&About..."
      End
   End
End
Attribute VB_Name = "Formula"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'--------------------------------------------------------------------------------------------------------
'                                  Formula.frm
'                                 -------------
'
'15Dec96 section moved here from Issueandprint to allow work sheet details to be passed to full worksheet
'17Feb98 CFY Added Blister Pack check box
'19Nov98 CFY Modified layout of form. Added ability to have two worksheets
'            associated with a CIVAS item.
'19Nov98 CFY Form_Load: Added call to fill the Layout combo boxes
'19Nov98 CFY ForumlaData_Validate: Code added to handling saving of layout and patients per layout back
'            to the database as these are not handled using data-aware controls.
'19Nov98 CFY mnuPrint_Click: Extra parameters added to call to PrintManworksheet. Now also calls PromptForWrkSheets
'            to determine which layout to use.
'19Nov98 CFY CmdCompund_Click: Extra parameters added to call to IssueAndPrintFormula. Now also calls PromptForWrkSheet to
'            determine which layout to use.
'30Nov98 CFY CmdAuthorise_Click: Added ability to second authorise a formula. Second authorisor must have sufficient
'            password level and be a different user.
'24Feb99 SF  CmdCompound_Click: updated paraemeter calls to PromptForWrkSht: and IssueAndPrintFormula: subs
'24Feb99 SF  mnuPrint_Click: updated paraemeter calls to PromptForWrkSht: and PrintManWorksheet: subs
'28Jul99 AE  CmbLayout_Change: Layouts are now saved in SaveFormula
'            CmdAuthorise_Click:Replaced Updates with calls to SaveFormula
'            CmdCompound_Click:Replaced Update. Added call to promptbatchnumber
'            CmdDelete_Click: Replaced code with call to DeleteFormula
'            CmdEdit_Click: Replaced UpdateFlag with the Tag property
'            MnuExit_Click: replaced update.
'            TxtCode_KeyPress: mods to disallow editing in some view modes
'            TxtQty_KeyPress:          "     "
'            TxtDescription_Keypress:  "     "
'27Sep99 CFY Various mods to allow normal dispenser to change patient specific formula
'04May00 JP  CmdCancel_Click: added 2nd authorisation check if formula has been changed
'14Sep00 JN  Form_Load: Changed reference to formula form to 'Me'
'19Nov01 CKJ MnuFormula_Click: Added to only allow deletion if password high enough             (#47301)
'21Oct02 TH  CmdCompound_Click: Added parameter to promptbatchnumber call

'--------------------------------------------------------------------------------------------------------
'26Aug09 TH Ported from v8
'12Jan07 PJC mnuPrint_Click: Added empty arguments to the call to PrintManWorksheet for workingdate and workingTime (enh77351).
'07Oct13 TH  TxtCode_KeyDown: Allow stores only ingredients (TFS 75305)
'--------
                                    
DefInt A-Z
Option Explicit

Dim UpdateFlag%
Dim SecondAuthID$

Private Sub Check2_Click()

End Sub

Private Sub ChkBlisterPack_Click()

    CmdCancel.Tag = "C"

End Sub

Private Sub ChkDosingUNits_Click()

    CmdCancel.Tag = "C"

End Sub

Private Sub ChkDosingUnits_GotFocus()
   
   '28sep96 ASC
   If Not CmdDelete.Visible Then    '14Jul00 JN removed reference to form
         On Error Resume Next '09Jan99 ASC
         CmdCompound.SetFocus
         On Error GoTo 0
      End If
End Sub

Private Sub CmbLayout_Change(Index As Integer)

'28Jul99 AE  This was not firing as it seems to have been intended, unless the user
'           actually types the layout in. It doesn't fire if you choose a new layout
'           using the drop down list.


   CmdCancel.Tag = "C"          '28Jul99 AE Added


'Dim db As database
'Dim Layout As Table

'   On Error GoTo CmbLayout_Change_Err
'   Set db = OpenDatabase(dispdata$ & "\formula.mdb")
'   Set Layout = db.OpenTable("layout")
'   Layout.Index = "Name"
'   Layout.Seek "=", CmbLayout(Index).Text
'   If Not Layout.NoMatch Then
'         TxtPatsPerSheet(Index) = getfield(Layout!PatientsPerSheet)
'      End If
'   CmdCancel.Tag = "C"
'CmbLayout_Change_Exit:
'   On Error Resume Next
'   Layout.Close
'   Set Layout = Nothing
'   db.Close
'   Set db = Nothing
'   Exit Sub
'
'CmbLayout_Change_Err:
'   popmessagecr "", "Error could not onpen formula database"
'   GoTo CmbLayout_Change_Exit
End Sub

Private Sub CmbLayout_Click(Index As Integer)

    CmdCancel.Tag = "C"

End Sub

Private Sub CmbLayout_KeyDown(Index As Integer, KeyCode As Integer, Shift As Integer)

    CmdCancel.Tag = "C"

End Sub

Private Sub CmdAuthorise_Click()
'30Nov98 CFY Added ability to second authorise a formula. Second authorisor must have sufficient
'            password level and be a different user.
'28Jul99 AE  Replaced Updates with calls to SaveFormula

Dim validpass%, CIVAS2ndAuth%, OKToAuthorise%
Dim TmpID$, TmpAccLevel$, TmpFullName$
Dim ans$                                        '?????99 AE Added

''26Aug09 Th Removed 2nd auth (didnt work anyway) (F0054335)
''   OKToAuthorise% = True
''   CIVAS2ndAuth% = TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "CIVAS2ndAuth", 0))
''
''   If CIVAS2ndAuth% Then
''         TmpID$ = UserID$
''         TmpFullName$ = UserFullName$
''         TmpAccLevel$ = acclevels$
''''         askpassword validpass%, "", "Second Authorisor"
''         If validpass% Then
''               'Check password level is sufficient
''               If Mid$(acclevels$, 1, 1) <> "9" Then
''                     popmessagecr "", "Insufficient password level"
''                     OKToAuthorise% = False
''                  End If
''               'Check if this is another user doing the authorisation
''               If OKToAuthorise And (TmpID$ = UserID$) Then
''                     popmessagecr "", "Second authorisation must be carried out by another user"
''                     OKToAuthorise% = False
''                  End If
''               'Everything OK so authorise
''               If OKToAuthorise% Then
''                '     SecondAuthID$ = UserID$          '28Jul99 AE should be safe, since this is immediately
''                     Lbl2ndAuth.Caption = UserID$      'copied to lbl2ndauth in formuladata_validate
''
''                     UserID$ = TmpID$
''                     UserFullName$ = TmpFullName$
''                     acclevels$ = TmpAccLevel$
''                      CmdCancel.Tag = "C"
'''                     FormulaData.Recordset.Update
''                     SaveFormula Me '14Jul00 JN updated reference to formula.frm
''                  End If
''            End If
''         UserID$ = TmpID$
''         UserFullName$ = TmpFullName$
''         acclevels$ = TmpAccLevel$
''      Else
'         FormulaData.Recordset.Update
         If getFormulaFromDispense() Then   '17Jun05 TH Added to suppress prompt if from Dispensing
            ans$ = "Y"
         Else
            If GetSecondAuthorisation() Then
               Select Case getaccesslevel()
                  Case 9: Confirm "Saving", "approve this draft formula", ans$, k
                  Case 8: Confirm "Saving", "save changes to draft formula", ans$, k
                  Case Else: popmessagecr "Manufacturing", "Security level insufficient to allow save of formula"
               End Select
            Else
               Confirm "Saving", "authorise changes to formula", ans$, k
            End If
         End If
         If ans$ = "Y" And Not k.escd Then                             '      "
            SaveFormula Me    '14Jul00 JN updated reference to formula.frm
            CmdCancel.Tag = ""                                         'Reset "changed" flag
         End If                                                        '      "
''      End If
   'cmdCancel_Click  '09Jan99 ASC
   'If Not k.escd Then formula.Hide           '?????99 AE Removed.  Don't hide form until exit is clicked
   k.escd = False
   

End Sub

Private Sub CmdCancel_Click()
   CancelFormula Me
End Sub

Private Sub CmdCompound_Click()
'19Nov98 CFY Extra parameters added to call to IssueAndPrintFormula. Now also calls PromptForWrkSheet to
'            determine which layout to use.
'24Feb99 SF  updated parameter calls to PromptForWrkSht: and IssueAndPrintFormula: subs
'28Jul99 AE  Replaced Update. Added call to promptbatchnumber
'21Oct02 TH  Added parameter to promptbatchnumber call

Dim formulafound%
Dim Layout$, PatsPerSheet%              '19Nov98 CFY
Dim escd%                              '24Feb99 SF added
Dim rsFormula As ADODB.Recordset
   
 '  formula.FormulaData.Recordset.Update '28sep96 ASC
   
   If CmdCancel.Tag = "C" Then CmdAuthorise_Click                    '28Jul99 AE replaces above
    CmdCancel.Tag = ""                                       '28Jul99 AE
   Set rsFormula = New ADODB.Recordset
   getformula formulafound, rsFormula             '15Dec96 section moved here from Issue and print to allow work sheet details to be passed to issue and print
   If Not formulafound Or getFormulaFromDispense() Then
   'We are using a formula from dispensing so this needs saving as pat specific
      SaveFormula Me
      getformula formulafound, rsFormula
   End If
   If formulafound Then
         'PromptForWrkSht Layout$, PatsPerSheet%         '24Feb99 SF replaced
         PromptForWrkSht Layout$, PatsPerSheet%, escd%   '24Feb99 SF
         'If Not k.escd Then     '24Feb99 SF replaced
         If Not escd% Then       '24Feb99 SF
               'IssueAndPrintFormula d, False, 0, 0, "", "", "", "", "", 1, Layout$        '19Nov98 CFY Added extra paramaters  '24Feb99 SF replaced
               k.escd = False
               PromptBatchNumber 0               '28Jul99 AE Added to set batch number   '21Oct02 TH Added parameter
               IssueAndPrintFormula Me, d, False, 0, 0, "", "", "", "", "", 1, Layout$, 0, rsFormula      '24Feb99 SF     '14Jul00 JN
               If getFormulaFromDispense() Then Unload Me
            End If
      Else
         'popmessagecr "", "Full worksheet and formula for " & Trim$(d.Description) & " not found"  XN 4Jun15 98073 New local stores description
		 popmessagecr "", "Full worksheet and formula for " & Trim$(d.LabelDescription) & " not found"
      End If

End Sub

Private Sub CmdDelete_Click()

'28Jul99 AE moved delete formula to formula.bas

Dim ans$
k.escd = False
   If GetSecondAuthorisation() Then  '24Feb09 TH (F78585)
   
      If getaccesslevel() = 8 Then
         Confirm "?Manufacturing", "delete draft formula", ans$, k
      ElseIf getaccesslevel() = 7 Then
         Confirm "?Manufacturing", "delete approved formula", ans$, k
      Else
         popmessagecr "Manufacturing", "Insufficient secrity level to delete formula"
      End If
   Else                                                                 '24Feb09 TH (F78585)
      Confirm "?Manufacturing", "delete the current formula", ans$, k   '    "
   End If                                                               '    "
   
   'Confirm "?Manufacturing", "delete the current formula", ans$, k
   If ans$ = "Y" And Not k.escd Then DeleteFormula Me    '14Jul00 JN
      
   Me.Hide  '14Jul00 JN changed from formula.hide to me.hide
End Sub

Private Sub CmdEdit_Click(Index As Integer)
   
Dim result$

   k.escd = False '09Oct09 TH Reset
   
   '26Aug09 TH added (F0054335)
   If GetSecondAuthorisation() And getaccesslevel() = 8 Then
      'OK - we need to warn the user about this
      DraftWlayoutWarning Trim$(Me.CmbLayout(Index).text), k, 0
   End If
   '-------
   
   If Not k.escd Then  '26Aug09 TH added (F0054335)
      frmoptionset -1, "Item to Edit"
      frmoptionset 1, "Layout"
      frmoptionset 1, "Item Line Text"
      frmoptionset 1, "Consumable Line Text"
      frmoptionshow "1", result$
      frmoptionset 0, ""
   End If
   If Not k.escd Then
         Select Case Val(result$)
            Case 1: AmendLayout Me, Index + 6
            Case 2: AmendLayout Me, Index
            Case 3: AmendLayout Me, Index + 2
         End Select
         'UpdateFlag = True      '28Jul99 AE replaced
          CmdCancel.Tag = "C"
      End If
End Sub

Private Sub CmdNew_Click()
   NewFormula Me
End Sub

Private Sub cmdReturn_Click()
 CIVASTransactionRollBack False, True
End Sub
Private Sub CSCmbType_Change(Index As Integer)

    CmdCancel.Tag = "C"

End Sub

Private Sub CSCmbType_GotFocus(Index As Integer)
   
   '28sep96 ASC
   If Not CmdDelete.Visible Then    '14Jul00 JN removed reference to form
         On Error Resume Next '09Jan99 ASC
         CmdCompound.SetFocus
         On Error GoTo 0      '  "
      End If

End Sub

Private Sub Form_Load()
'19Nov98 CFY Added call to fill the Layout combo boxes
'14Sep00 JN  Changed reference to formula form to 'Me'

Dim ExtraLabels$

   'Centreform formula     '14Sep00 JN replaced with line below
   CentreForm Me
   SetChrome Me
   
'   FormulaData.DatabaseName = dispdata + "\formula.mdb"
'   FormulaData.RecordSource = "formula"
'   FormulaData.Refresh
'   For X = 0 To 14                                           '????? AE  Temporarily removed
'      TxtCode(X).DataField = "code" & LTrim$(Str$(X + 1))
'      TxtQty(X).DataField = "qty" & LTrim$(Str$(X + 1))
'      CSCmbType(X).DataField = "type" & LTrim$(Str$(X + 1))
'      TxtDescription(X).DataField = "d" & LTrim$(Str$(X + 1))
'   Next

   FillLayoutCombos Me         '19Nov98 CFY Added  '13Sep00JN Added form instance

   'Read option settings from ini file
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
   If UnloadMode <> 1 Then       '20Jan99 CFY Added
         Me.Hide            '        "
         CancelFormula Me        '13Jul00 JN  Added '14Jul00 JN moved event-code to module
      End If                     '        "
End Sub

Private Sub FormulaData_Validate(Action As Integer, Save As Integer)
'19Nov98 CFY Code added to handling saving of layout and patients per layout back to the database,
'            as these are not handled using data-aware controls.
'SQL TODO
''Dim ans$, i%
''Dim db As Database
''Dim TblLayout As table
''
''
''   If UpdateFlag Then Save = True                                                      '19Nov98 CFY Added
''   If Save And LblTotQty.Caption <> "" Then
''
''         If Action <> 5 And Action <> 9 Then ' Addnew or bookmark set
''               ans$ = "Y"
''
''               Confirm "Saving", "authorise changes to formula", ans$, k
''               If ans$ = "Y" Then
''                     On Error GoTo LayoutUpdate_Err
''                     Set db = OpenDatabase(dispdata$ & "\formula.mdb")
''                     Set TblLayout = db.OpenTable("Layout")
''                     TblLayout.Index = "Name"                                          '19Nov98 CFY Added
''                     For i = 0 To 1                                                    '      "
''                        TblLayout.Seek "=", CmbLayout(i).text                          '      "
''                        If Not TblLayout.NoMatch Then                                  '      "
''                              TblLayout.Edit                                           '      "
''                              TblLayout!PatientsPerSheet = TxtPatsPerSheet(i).text     '      "
''                              TblLayout.Update                                         '      "
''                           End If                                                      '      "
''                     Next                                                              '      "
''                     On Error GoTo 0                                                   '      "
''                     If UpdateFlag Then                                                '      "
''                           FormulaData.Recordset.Edit                                  '      "
''                           FormulaData.Recordset!Layout = CmbLayout(0).text            '      "
''                           FormulaData.Recordset!Layout2 = CmbLayout(1).text           '      "
''                        End If                                                         '      "
''                     Lbl2ndAuth = SecondAuthID$                                        '      "
''                     LblAuthorised = UserID$
''                     'LblAuthorisedDate = Now                                          '04Jun99 CFY replaced
''                     LblAuthorisedDate = Format(Now, "dd/mm/yyyy")                     '         "
''                  End If
''
''
''               If ans$ <> "Y" Then Save = 0
''               UpdateFlag = False
''            End If
''      End If
''
''
''FormulaUpdate_Validate_Exit:
''   On Error Resume Next
''   TblLayout.Close
''   Set TblLayout = Nothing
''   db.Close
''   Set db = Nothing
''   Exit Sub
''
''LayoutUpdate_Err:
''   popmessagecr "", "Error. Could not update Layout table. Your changes may be lost."
''   GoTo FormulaUpdate_Validate_Exit

End Sub

Private Sub mnuAbout_Click()

      ShowAboutBox "Manufacturing"
   
End Sub

Private Sub MnuDelete_Click()

'28Jul99 AE moved delete formula to formula.bas
'14Jul00 JN took code from CmdDelete_Click to replace original code in order to avoid calling CmdDelete_Click from here

Dim ans$
k.escd = False

   'Confirm "Manufacturing", "delete the current formula", ans$, k
   askwin "#Manufacturing", "delete the current formula", ans$, k  '21Aug06 TH Added info icon (DR-06-0470)
   If ans$ = "Y" And Not k.escd Then DeleteFormula Me    '14Jul00 JN
      
   Me.Hide  '14Jul00 JN changed from formula.hide to me.hide
End Sub

Private Sub mnuExit_Click()
   CancelFormula Me         '28Jul99 AE replaced above   '14Jul00 JN now refers to module-based code
End Sub

Private Sub MnuFormula_Click()
'19Nov01 CKJ Added to only allow deletion if password high enough

   MnuDelete.Enabled = CmdDelete.Visible

End Sub

Private Sub MnuHeaderFooter_Click(Index As Integer)
   
   If cmdDelete.Visible Then  'High level password '14Jul00 JN removed reference to form
         If GetSecondAuthorisation() And getaccesslevel() = 9 Then
            popmessagecr "#", "Insufficent Password Privilege - you can approve draft changes but not make changes"
         Else
            AmendLayout Me, Index
         End If
      Else
         If getaccesslevel() = 9 Then  '10Aug14 TH Allow view on level 9 (TFS 86640)
            AmendLayout Me, Index
         Else
            popmessagecr "#", "Insufficent Password Privilege"  '21Aug06 TH added info icon (DR-06-0470)
         End If
      End If

End Sub

Private Sub MnuNew_Click()

   NewFormula Me  '14Jul00 JN changed to module-based code

End Sub

Private Sub MnuOptSpareLbl_Click(Index As Integer)
'06Sep99 CFY Written

Dim SpareLabels$, msg$, Entry$
Dim valid%, success%

   Select Case Index
      Case 1:     'Per Batch
         Entry$ = "SpareCIVASLabelsBatch"
         msg$ = "per batch"
      Case 2:     'Per Dose
         Entry$ = "SpareCIVASLabelsDose"
         msg$ = "per dose"
   End Select

   SpareLabels$ = TxtD(dispdata$ & "\patmed.ini", "", "1", Entry$, 0)
   Do
      inputwin "EMIS Health", "Enter number of spare CIVAS labels " & msg$, SpareLabels$, k
      valid = (Val(SpareLabels$) >= 0 And Val(SpareLabels$) <= 99) Or (k.escd)
      If Not valid Then
            popmessagecr "!", "Value must be between 0 and 99. Please re-enter"
         End If
   Loop While Not valid

   If Not k.escd Then
         WritePrivateIniFile "", Entry$, SpareLabels$, dispdata$ & "\patmed.ini", success%
         FlushIniCache
         If Not success% Then
               popmessagecr "!", "A problem arose saving the new settings to disk." & crlf & "Changes may be lost."
            End If
      End If
         
End Sub

Private Sub mnuPrint_Click(Index As Integer)
'18Jun98 CFY Now passes a ¬ char to indicate that we simply want to produce a worksheet without
'            issuing stock.
'19Nov98 CFY Extra parameters added to call to PrintManworksheet. Now also calls PromptForWrkSheets
'            to determine whcih layout to use.
''24Feb99 SF  updated paraemeter calls to PromptForWrkSht: and PrintManWorksheet: subs
'12Jan07 PJC Added empty arguments to the call to PrintManWorksheet for workingdate and workingTime (enh77351).

Dim Layout$    '19Nov98 CFY Added
Dim rsFormula As ADODB.Recordset
Dim intFound As Integer

   PromptForWrkSht Layout$, 0, 0    '24Feb99 SF
   'PrintManWorksheet (Index = 1), Val(d.convfact), 1, 0, "¬", 0, 0, "Patient details go here including Unit No.", "", "Worksheet wordinf depending on formula", 1, Layout$   '19Nov98 CFY   '24Feb99 SF  replaced
   Set rsFormula = New ADODB.Recordset
   getformula intFound, rsFormula
   If intFound Then
      'PrintManWorksheet Me, (index = 1), Val(d.convfact), 1, 0, "¬", 0, 0, "Patient details go here including Unit No.", "", "Worksheet wordinf depending on formula", 1, Layout$, 0, rsFormula '24Feb99 SF
      PrintManWorksheet Me, (Index = 1), Val(d.convfact), 1, 0, "¬", 0, 0, "Patient details go here including Unit No.", "", "Worksheet wordinf depending on formula", 1, Layout$, "", "", 0, rsFormula               '12Jan07 PJC Added  (enh77351).
   Else
      popmessagecr "", "Formula cannot be found" 'Should never fire !!
   End If
   
Cleanup:
   On Error Resume Next
   rsFormula.Close
   Set rsFormula = Nothing
   On Error GoTo 0
End Sub

Private Sub Text2_Change()

    CmdCancel.Tag = "C"

End Sub

Private Sub Text2_KeyPress(KeyAscii As Integer)
'Primitive masking added
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
   If (Len(Text2.text) > 4 And KeyAscii <> 8) Then KeyAscii = 0

End Sub

Private Sub Text1_Change()
   CmdCancel.Tag = "C"
End Sub

Private Sub Text3_Change()
   
    CmdCancel.Tag = "C"
   
End Sub

Private Sub Text3_KeyPress(KeyAscii As Integer)
'Primitive masking added
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
   If (Len(Text3.text) > 4 And KeyAscii <> 8) Then KeyAscii = 0

End Sub

Private Sub TxtCode_Change(Index As Integer)

    CmdCancel.Tag = "C"

End Sub

Private Sub TxtCode_GotFocus(Index As Integer)
   
'28Jul99 AE removed. Functionality replaced by view modes
   '28sep96 ASC
'   If Not Formula.CmdDelete.Visible Then
'         On Error Resume Next    '09Jan99 ASC
'         CmdCompound.SetFocus
'         On Error GoTo 0         '   "
'      End If

End Sub

Private Sub TxtCode_KeyDown(Index As Integer, KeyCode As Integer, Shift As Integer)
'07Oct13 TH allow stores only ingredients (TFS 75305)

Dim drug$, lngfoundptr As Long, dcop As DrugParameters  '21Dec96 ASC local copy of d


   LSet dcop = d
   
   If KeyCode = 13 Then
         'findrdrug (TxtCode(index).text), False, d, lngfoundptr, 0, False, False, False
         findrdrug (TxtCode(Index).text), True, d, lngfoundptr, 0, False, False, False '07Oct13 TH allow stores only ingredients (TFS 75305)
         If lngfoundptr > 0 Then
               If LblNSVcode.Caption <> d.SisCode Then
                     TxtCode(Index).text = d.SisCode
                     'drug$ = d.Description   XN 4Jun15 98073 New local stores description
					 drug$ = d.LabelDescription
                     plingparse drug$, "!"
                     TxtDescription(Index).text = drug$
                     If ChkDosingUNits.Value Then
                           lblUnits(Index).Caption = LCase$(d.DosingUnits)
                        Else
                           lblUnits(Index).Caption = LCase$(d.PrintformV)
                        End If
                     CSCmbType(Index).ListIndex = 1
                     txtQty(Index).SetFocus
                  Else
                     TxtCode(Index).text = ""
                     popmessagecr "Entry Error", "Cannot have manufactured item as an ingredient"
                  End If
            End If
         If TxtCode(Index).text = "" Then
               blankformulaline Me, Index
            End If
      End If

   LSet d = dcop


End Sub

Private Sub TxtCode_KeyPress(Index As Integer, KeyAscii As Integer)
   
   '28Jul99 AE Added block to disallow editing in some view modes / password levels
   Select Case getviewmode()
      Case 0
         KeyAscii = 0
      Case 1 - 9
      End Select

   Select Case Mid$(acclevels$, 1, 1)
      Case "1", "2", "3", "4", "5", "6", "7"
         'KeyAscii = 0                                                     '27Sep99 CFY Added
         If getviewmode() < 2 Or getviewmode() > 7 Then KeyAscii = 0       '         "
      Case "8", "9"
      End Select
   '-------

End Sub

Private Sub TxtCode_LostFocus(Index As Integer)

   If TxtCode(Index).text = "" Then blankformulaline Me, Index

End Sub

Private Sub TxtDescription_Change(Index As Integer)

    CmdCancel.Tag = "C"

End Sub

Private Sub txtDescription_KeyPress(Index As Integer, KeyAscii As Integer)
   
   '28Jul99 AE Added block to disallow editing in some view modes
   Select Case getviewmode()
      Case 0
         KeyAscii = 0
      Case 1 - 9
      End Select
   
   Select Case Mid$(acclevels$, 1, 1)
      Case "1", "2", "3", "4", "5", "6", "7"
         'KeyAscii = 0                                                     '27Sep99 CFY Added
         If getviewmode() < 2 Or getviewmode() > 7 Then KeyAscii = 0       '         "
      Case "8", "9"
      End Select

   '-------

End Sub

Private Sub TxtPatsPerSheet_Click(Index As Integer)

    CmdCancel.Tag = "C"

End Sub

Private Sub TxtPatsPerSheet_KeyPress(Index As Integer, KeyAscii As Integer)
'Primitive masking added
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
   If (Len(TxtPatsPerSheet(Index).text) > 4 And KeyAscii <> 8) Then KeyAscii = 0

End Sub

Private Sub TxtQty_Change(Index As Integer)

Dim Changed%  '28sep96 ASC

   CmdCancel.Tag = "C"

   If Left$(txtQty(Index).text, 1) = "." Then
         Changed = txtQty(Index).DataChanged   '28sep96 ASC
         txtQty(Index).text = "0" & txtQty(Index).text
         txtQty(Index).SelStart = Len(txtQty(Index).text)
         txtQty(Index).DataChanged = Changed   '28sep96 ASC
      End If

End Sub

Private Sub TxtQty_KeyDown(Index As Integer, KeyCode As Integer, Shift As Integer)


   If KeyCode = 13 And Index < 14 Then TxtCode(Index + 1).SetFocus

End Sub

Private Sub TxtQty_KeyPress(Index As Integer, KeyAscii As Integer)
   
   '28Jul99 AE Added block to disallow editing in some view modes
   Select Case getviewmode()
      Case 0
         KeyAscii = 0
      Case 1 - 9
      End Select
   
   Select Case Mid$(acclevels$, 1, 1)
      Case "1", "2", "3", "4", "5", "6", "7"
         'KeyAscii = 0                                                     '27Sep99 CFY Added
         If getviewmode() < 2 Or getviewmode() > 7 Then KeyAscii = 0       '         "
      Case "8", "9"
      End Select

   '-------


End Sub

Private Sub xCSCmbType_Click(Index As Integer)

End Sub
