VERSION 5.00
Begin VB.UserControl Dispense 
   Appearance      =   0  'Flat
   AutoRedraw      =   -1  'True
   BackColor       =   &H80000005&
   ClientHeight    =   4530
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   9600
   KeyPreview      =   -1  'True
   Picture         =   "ucDispens.ctx":0000
   ScaleHeight     =   4530
   ScaleWidth      =   9600
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H8000000A&
      BorderStyle     =   0  'None
      Enabled         =   0   'False
      ForeColor       =   &H80000008&
      Height          =   4290
      Left            =   0
      ScaleHeight     =   4290
      ScaleWidth      =   9600
      TabIndex        =   46
      Top             =   240
      Visible         =   0   'False
      Width           =   9600
      Begin VB.PictureBox Picture2 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
         BorderStyle     =   0  'None
         Enabled         =   0   'False
         ForeColor       =   &H80000008&
         Height          =   345
         Left            =   0
         ScaleHeight     =   345
         ScaleWidth      =   15555
         TabIndex        =   101
         TabStop         =   0   'False
         Top             =   5040
         Visible         =   0   'False
         Width           =   15555
         Begin VB.CommandButton CmdPrompt 
            Appearance      =   0  'Flat
            Caption         =   "Function"
            Enabled         =   0   'False
            Height          =   315
            Index           =   5
            Left            =   840
            Style           =   1  'Graphical
            TabIndex        =   123
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   750
         End
         Begin VB.PictureBox PctCmd 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
            BorderStyle     =   0  'None
            FillColor       =   &H00C0C0C0&
            FillStyle       =   0  'Solid
            ForeColor       =   &H00C0C0C0&
            Height          =   160
            Index           =   3
            Left            =   11160
            Picture         =   "ucDispens.ctx":16096
            ScaleHeight     =   165
            ScaleWidth      =   45
            TabIndex        =   120
            Top             =   60
            Visible         =   0   'False
            Width           =   45
         End
         Begin VB.PictureBox PctCmd 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
            BorderStyle     =   0  'None
            FillColor       =   &H00C0C0C0&
            FillStyle       =   0  'Solid
            ForeColor       =   &H00C0C0C0&
            Height          =   160
            Index           =   2
            Left            =   10260
            Picture         =   "ucDispens.ctx":16144
            ScaleHeight     =   165
            ScaleWidth      =   45
            TabIndex        =   119
            TabStop         =   0   'False
            Top             =   60
            Visible         =   0   'False
            Width           =   45
         End
         Begin VB.PictureBox PctCmd 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
            BorderStyle     =   0  'None
            Enabled         =   0   'False
            FillColor       =   &H00C0C0C0&
            FillStyle       =   0  'Solid
            ForeColor       =   &H00C0C0C0&
            Height          =   160
            Index           =   0
            Left            =   13065
            Picture         =   "ucDispens.ctx":161F2
            ScaleHeight     =   165
            ScaleWidth      =   45
            TabIndex        =   118
            Top             =   55
            Visible         =   0   'False
            Width           =   45
         End
         Begin VB.PictureBox PctCmd 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
            BorderStyle     =   0  'None
            Enabled         =   0   'False
            FillColor       =   &H00C0C0C0&
            FillStyle       =   0  'Solid
            ForeColor       =   &H00C0C0C0&
            Height          =   160
            Index           =   1
            Left            =   12300
            Picture         =   "ucDispens.ctx":162A0
            ScaleHeight     =   165
            ScaleWidth      =   45
            TabIndex        =   117
            Top             =   60
            Visible         =   0   'False
            Width           =   45
         End
         Begin VB.CommandButton CmdPrompt 
            Appearance      =   0  'Flat
            Caption         =   "Exit"
            Height          =   315
            Index           =   11
            Left            =   9760
            Style           =   1  'Graphical
            TabIndex        =   116
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   435
         End
         Begin VB.CommandButton CmdPrompt 
            Appearance      =   0  'Flat
            Caption         =   "BNF"
            Enabled         =   0   'False
            Height          =   315
            Index           =   10
            Left            =   8800
            Style           =   1  'Graphical
            TabIndex        =   115
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   750
         End
         Begin VB.CommandButton CmdPrompt 
            Appearance      =   0  'Flat
            Caption         =   "Script"
            Enabled         =   0   'False
            Height          =   315
            Index           =   9
            Left            =   15
            Style           =   1  'Graphical
            TabIndex        =   114
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   750
         End
         Begin VB.CommandButton CmdPrompt 
            Appearance      =   0  'Flat
            Caption         =   "Formula"
            Enabled         =   0   'False
            Height          =   315
            Index           =   8
            Left            =   14985
            Style           =   1  'Graphical
            TabIndex        =   113
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   750
         End
         Begin VB.CommandButton CmdPrompt 
            Appearance      =   0  'Flat
            Caption         =   "Discharge"
            Enabled         =   0   'False
            Height          =   315
            Index           =   7
            Left            =   13980
            Style           =   1  'Graphical
            TabIndex        =   112
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   1000
         End
         Begin VB.CommandButton CmdPrompt 
            Appearance      =   0  'Flat
            Caption         =   "Print"
            Enabled         =   0   'False
            Height          =   315
            Index           =   4
            Left            =   3750
            Style           =   1  'Graphical
            TabIndex        =   111
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   750
         End
         Begin VB.CommandButton CmdPrompt 
            Appearance      =   0  'Flat
            Caption         =   "Discontinue"
            Enabled         =   0   'False
            Height          =   315
            Index           =   2
            Left            =   4560
            Style           =   1  'Graphical
            TabIndex        =   110
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   1095
         End
         Begin VB.CommandButton CmdPrompt 
            Appearance      =   0  'Flat
            Caption         =   "Clear"
            Enabled         =   0   'False
            Height          =   315
            Index           =   6
            Left            =   13530
            Style           =   1  'Graphical
            TabIndex        =   109
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   750
         End
         Begin VB.CommandButton CmdPrompt 
            Appearance      =   0  'Flat
            Caption         =   "Amend"
            Enabled         =   0   'False
            Height          =   315
            Index           =   1
            Left            =   6420
            Style           =   1  'Graphical
            TabIndex        =   108
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   750
         End
         Begin VB.CommandButton CmdPrompt 
            Appearance      =   0  'Flat
            Caption         =   "Save"
            Enabled         =   0   'False
            Height          =   315
            Index           =   3
            Left            =   2910
            Style           =   1  'Graphical
            TabIndex        =   107
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   750
         End
         Begin VB.CommandButton CmdPrompt 
            Caption         =   "New"
            Enabled         =   0   'False
            Height          =   315
            Index           =   0
            Left            =   5685
            Style           =   1  'Graphical
            TabIndex        =   106
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   705
         End
         Begin VB.CommandButton cmdEdit 
            Appearance      =   0  'Flat
            Caption         =   "Diagn&osis"
            Height          =   315
            Index           =   3
            Left            =   11160
            Style           =   1  'Graphical
            TabIndex        =   105
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   1095
         End
         Begin VB.CommandButton CmdInteractions 
            Appearance      =   0  'Flat
            Caption         =   "  Inte&ractions"
            Enabled         =   0   'False
            Height          =   315
            Left            =   12990
            Style           =   1  'Graphical
            TabIndex        =   104
            Top             =   0
            Visible         =   0   'False
            Width           =   1100
         End
         Begin VB.CommandButton cmdEdit 
            Appearance      =   0  'Flat
            Caption         =   "   A&llergies"
            Height          =   315
            Index           =   2
            Left            =   10230
            Style           =   1  'Graphical
            TabIndex        =   103
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   885
         End
         Begin VB.CommandButton cmdEdit 
            Appearance      =   0  'Flat
            Caption         =   " &Notes"
            Enabled         =   0   'False
            Height          =   315
            Index           =   1
            Left            =   12240
            Style           =   1  'Graphical
            TabIndex        =   102
            Top             =   0
            Visible         =   0   'False
            Width           =   750
         End
      End
      Begin VB.TextBox TxtNumOfLabels 
         Appearance      =   0  'Flat
         Height          =   285
         Left            =   2340
         TabIndex        =   100
         Text            =   "TxtNumOfLabels"
         Top             =   5625
         Visible         =   0   'False
         Width           =   1275
      End
      Begin VB.TextBox TxtTopUpQty 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         ForeColor       =   &H00000000&
         Height          =   285
         Left            =   135
         TabIndex        =   99
         TabStop         =   0   'False
         Text            =   "TxtTopUpQty"
         Top             =   5640
         Visible         =   0   'False
         Width           =   1095
      End
      Begin VB.TextBox TxtSupplied 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         ForeColor       =   &H00000000&
         Height          =   285
         Left            =   1275
         TabIndex        =   98
         TabStop         =   0   'False
         Text            =   "TxtSupplied"
         Top             =   5640
         Visible         =   0   'False
         Width           =   975
      End
      Begin VB.PictureBox F3D2 
         Appearance      =   0  'Flat
         BackColor       =   &H0080FFFF&
         ForeColor       =   &H80000008&
         Height          =   230
         Left            =   0
         ScaleHeight     =   195
         ScaleWidth      =   9585
         TabIndex        =   97
         Top             =   4320
         Visible         =   0   'False
         Width           =   9615
      End
      Begin VB.PictureBox F3D1 
         Appearance      =   0  'Flat
         BackColor       =   &H00FF8080&
         ForeColor       =   &H80000008&
         Height          =   230
         Left            =   0
         ScaleHeight     =   195
         ScaleWidth      =   9585
         TabIndex        =   96
         Top             =   4680
         Visible         =   0   'False
         Width           =   9615
      End
      Begin VB.PictureBox picOCXdetails 
         Appearance      =   0  'Flat
         AutoRedraw      =   -1  'True
         BackColor       =   &H8000000A&
         ForeColor       =   &H80000008&
         Height          =   345
         Left            =   30
         MouseIcon       =   "ucDispens.ctx":1634E
         MousePointer    =   99  'Custom
         ScaleHeight     =   315
         ScaleWidth      =   9525
         TabIndex        =   93
         Top             =   3870
         Width           =   9555
      End
      Begin VB.Frame fraLineColour 
         BorderStyle     =   0  'None
         Height          =   3345
         Left            =   0
         TabIndex        =   81
         Top             =   480
         Width           =   2430
         Begin VB.TextBox TxtDircode 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   300
            Left            =   630
            TabIndex        =   12
            Top             =   1125
            Width           =   1710
         End
         Begin VB.TextBox TxtDrugCode 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   300
            Left            =   630
            TabIndex        =   9
            Top             =   870
            Width           =   1710
         End
         Begin VB.ComboBox CmbDropDrugCode 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            ForeColor       =   &H00000000&
            Height          =   315
            Index           =   1
            Left            =   1980
            TabIndex        =   13
            Text            =   "CmdDropDrugCode"
            Top             =   1125
            Width           =   390
         End
         Begin VB.ComboBox CmbDropDrugCode 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            ForeColor       =   &H00000000&
            Height          =   315
            Index           =   0
            Left            =   2040
            Style           =   2  'Dropdown List
            TabIndex        =   10
            TabStop         =   0   'False
            Top             =   855
            Width           =   330
         End
         Begin VB.ComboBox CmbIssueType 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            ForeColor       =   &H00000000&
            Height          =   315
            Left            =   624
            Style           =   2  'Dropdown List
            TabIndex        =   7
            Top             =   576
            Width           =   1745
         End
         Begin VB.TextBox TxtQtyPrinted 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            ForeColor       =   &H00000000&
            Height          =   285
            Left            =   1155
            TabIndex        =   16
            Top             =   1560
            Width           =   725
         End
         Begin VB.CheckBox chkPIL 
            Alignment       =   1  'Right Justify
            Caption         =   "Print Leaflet"
            Enabled         =   0   'False
            Height          =   190
            Left            =   45
            TabIndex        =   23
            Top             =   2670
            Visible         =   0   'False
            Width           =   2290
         End
         Begin VB.CheckBox ChkManual 
            Alignment       =   1  'Right Justify
            Caption         =   "Manual Quantity Entry"
            Enabled         =   0   'False
            Height          =   190
            Left            =   45
            TabIndex        =   24
            Top             =   2870
            Visible         =   0   'False
            Width           =   2290
         End
         Begin VB.TextBox TxtDescDate 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
            BorderStyle     =   0  'None
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   195
            Left            =   540
            TabIndex        =   18
            Top             =   1860
            Visible         =   0   'False
            Width           =   1095
         End
         Begin VB.TextBox TxtPrompt 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            ForeColor       =   &H00000000&
            Height          =   285
            Left            =   2040
            TabIndex        =   5
            ToolTipText     =   "(S)ave (P)rint (R)eprint (?) help"
            Top             =   45
            Width           =   300
         End
         Begin VB.CheckBox ChkPatOwn 
            Alignment       =   1  'Right Justify
            Caption         =   "Patients Own Medication"
            Enabled         =   0   'False
            Height          =   190
            Left            =   45
            TabIndex        =   25
            Top             =   3060
            Visible         =   0   'False
            Width           =   2295
         End
         Begin VB.TextBox TextBlister 
            Appearance      =   0  'Flat
            Height          =   285
            Left            =   2025
            TabIndex        =   22
            Top             =   2295
            Visible         =   0   'False
            Width           =   345
         End
         Begin VB.Image ImgWarning 
            Height          =   240
            Left            =   60
            Picture         =   "ucDispens.ctx":16658
            Top             =   120
            Visible         =   0   'False
            Width           =   240
         End
         Begin VB.Label lblPrompt 
            AutoSize        =   -1  'True
            BackStyle       =   0  'Transparent
            Caption         =   "Reprint"
            ForeColor       =   &H00C00000&
            Height          =   195
            Index           =   3
            Left            =   1395
            MouseIcon       =   "ucDispens.ctx":169DC
            MousePointer    =   99  'Custom
            TabIndex        =   4
            Top             =   120
            Width           =   510
         End
         Begin VB.Label lblPrompt 
            Appearance      =   0  'Flat
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
            ForeColor       =   &H00C00000&
            Height          =   195
            Index           =   2
            Left            =   120
            MouseIcon       =   "ucDispens.ctx":16CE6
            MousePointer    =   99  'Custom
            TabIndex        =   3
            Top             =   120
            Width           =   210
         End
         Begin VB.Label lblPrompt 
            Appearance      =   0  'Flat
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
            Caption         =   "Print"
            ForeColor       =   &H00C00000&
            Height          =   195
            Index           =   1
            Left            =   915
            MouseIcon       =   "ucDispens.ctx":16FF0
            MousePointer    =   99  'Custom
            TabIndex        =   2
            Top             =   120
            Width           =   405
         End
         Begin VB.Label LblCode 
            Appearance      =   0  'Flat
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
            Caption         =   "Item"
            ForeColor       =   &H00000000&
            Height          =   240
            Left            =   90
            TabIndex        =   8
            Top             =   900
            Width           =   480
         End
         Begin VB.Label LblIssueType 
            Appearance      =   0  'Flat
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
            Caption         =   "Type"
            ForeColor       =   &H00000000&
            Height          =   255
            Left            =   90
            TabIndex        =   6
            Top             =   585
            Width           =   480
         End
         Begin VB.Label LblPrintForm 
            Appearance      =   0  'Flat
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
            ForeColor       =   &H00000000&
            Height          =   240
            Left            =   1950
            TabIndex        =   15
            Top             =   1560
            Width           =   405
         End
         Begin VB.Line Line2 
            BorderColor     =   &H00FFFFFF&
            X1              =   60
            X2              =   2340
            Y1              =   1485
            Y2              =   1485
         End
         Begin VB.Label lblDirCode 
            Appearance      =   0  'Flat
            AutoSize        =   -1  'True
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
            Caption         =   "Dir."
            ForeColor       =   &H80000008&
            Height          =   195
            Left            =   90
            TabIndex        =   11
            Top             =   1170
            Width           =   240
         End
         Begin VB.Label LblQtyDesc 
            Appearance      =   0  'Flat
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
            Caption         =   "Qty:"
            ForeColor       =   &H00000000&
            Height          =   240
            Left            =   90
            TabIndex        =   14
            Top             =   1560
            Width           =   1065
         End
         Begin VB.Label lblPrompt 
            Appearance      =   0  'Flat
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
            Caption         =   "Save"
            ForeColor       =   &H00C00000&
            Height          =   195
            Index           =   0
            Left            =   360
            MouseIcon       =   "ucDispens.ctx":172FA
            MousePointer    =   99  'Custom
            TabIndex        =   1
            Top             =   120
            Width           =   465
         End
         Begin VB.Label LblUntil 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "until"
            ForeColor       =   &H80000008&
            Height          =   255
            Left            =   90
            TabIndex        =   17
            Top             =   1890
            Visible         =   0   'False
            Width           =   465
         End
         Begin VB.Label Lblreason 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            ForeColor       =   &H80000008&
            Height          =   240
            Left            =   1620
            TabIndex        =   19
            Top             =   1860
            Visible         =   0   'False
            Width           =   735
         End
         Begin VB.Label LblSupply 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            ForeColor       =   &H80000008&
            Height          =   255
            Left            =   90
            TabIndex        =   20
            Top             =   2070
            Visible         =   0   'False
            Width           =   2265
         End
         Begin VB.Label LabelBlister 
            Appearance      =   0  'Flat
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
            Caption         =   "Blister Pack number"
            ForeColor       =   &H80000008&
            Height          =   195
            Left            =   90
            TabIndex        =   21
            Top             =   2340
            Visible         =   0   'False
            Width           =   1755
         End
      End
      Begin VB.Frame fraRx 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         ForeColor       =   &H00FFFFFF&
         Height          =   3210
         Left            =   12520
         TabIndex        =   47
         Top             =   510
         Visible         =   0   'False
         Width           =   4560
         Begin VB.ComboBox CmbRepeatUnits 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   315
            Left            =   3810
            Style           =   2  'Dropdown List
            TabIndex        =   45
            Top             =   1896
            Width           =   720
         End
         Begin VB.TextBox TxtTime 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   4
            Left            =   4005
            TabIndex        =   38
            Top             =   1090
            Width           =   540
         End
         Begin VB.ComboBox CmbRoute 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   315
            Left            =   0
            Style           =   2  'Dropdown List
            TabIndex        =   27
            Top             =   1890
            Width           =   1095
         End
         Begin VB.TextBox TxtDose 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   1
            Left            =   3285
            TabIndex        =   31
            Top             =   270
            Width           =   735
         End
         Begin VB.CheckBox ChkPRN 
            Alignment       =   1  'Right Justify
            BackColor       =   &H00FFFFFF&
            Caption         =   "PRN"
            Enabled         =   0   'False
            Height          =   245
            Left            =   1500
            TabIndex        =   28
            Top             =   1940
            Width           =   675
         End
         Begin VB.TextBox TxtDirections 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   1905
            Left            =   15
            MultiLine       =   -1  'True
            TabIndex        =   26
            Top             =   0
            Width           =   3280
         End
         Begin VB.TextBox TxtTime 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   1
            Left            =   4005
            TabIndex        =   32
            Top             =   270
            Width           =   540
         End
         Begin VB.TextBox TxtTime 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   300
            Index           =   2
            Left            =   4005
            TabIndex        =   34
            Top             =   540
            Width           =   540
         End
         Begin VB.TextBox TxtTime 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   320
            Index           =   3
            Left            =   4005
            TabIndex        =   36
            Top             =   830
            Width           =   540
         End
         Begin VB.TextBox TxtTime 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   5
            Left            =   4005
            TabIndex        =   40
            Top             =   1360
            Width           =   540
         End
         Begin VB.TextBox TxtTime 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   6
            Left            =   4005
            TabIndex        =   42
            Top             =   1630
            Width           =   540
         End
         Begin VB.Frame fraIVdetails 
            Appearance      =   0  'Flat
            BackColor       =   &H00E0E0E0&
            BorderStyle     =   0  'None
            ForeColor       =   &H00FFFFFF&
            Height          =   300
            Left            =   90
            TabIndex        =   49
            Top             =   2250
            Visible         =   0   'False
            Width           =   4425
            Begin VB.TextBox TxtInfusionTime 
               Appearance      =   0  'Flat
               BackColor       =   &H00FFFFFF&
               ForeColor       =   &H00000000&
               Height          =   285
               Left            =   1530
               TabIndex        =   52
               Top             =   0
               Width           =   555
            End
            Begin VB.TextBox TxtFinalVol 
               Appearance      =   0  'Flat
               BackColor       =   &H00FFFFFF&
               ForeColor       =   &H00000000&
               Height          =   285
               Left            =   0
               TabIndex        =   50
               Top             =   0
               Width           =   765
            End
            Begin VB.Label LblInfusionRate 
               Appearance      =   0  'Flat
               BackColor       =   &H00FFFFFF&
               ForeColor       =   &H00800000&
               Height          =   240
               Left            =   3120
               TabIndex        =   55
               Top             =   45
               Width           =   600
            End
            Begin VB.Label Label15 
               Appearance      =   0  'Flat
               BackColor       =   &H00FFFFFF&
               Caption         =   " mL/hr"
               DragMode        =   1  'Automatic
               ForeColor       =   &H00800000&
               Height          =   330
               Left            =   3720
               TabIndex        =   54
               Top             =   45
               Width           =   720
            End
            Begin VB.Label Label11 
               Appearance      =   0  'Flat
               BackColor       =   &H00FFFFFF&
               Caption         =   "minutes at"
               ForeColor       =   &H00800000&
               Height          =   240
               Left            =   2160
               TabIndex        =   53
               Top             =   45
               Width           =   855
            End
            Begin VB.Label Label7 
               Appearance      =   0  'Flat
               BackColor       =   &H00FFFFFF&
               Caption         =   "mL over"
               ForeColor       =   &H00800000&
               Height          =   240
               Left            =   840
               TabIndex        =   51
               Top             =   45
               Width           =   630
            End
         End
         Begin VB.TextBox TxtDose 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   300
            Index           =   2
            Left            =   3285
            TabIndex        =   33
            Top             =   540
            Width           =   735
         End
         Begin VB.TextBox TxtDose 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   3
            Left            =   3285
            TabIndex        =   35
            Top             =   830
            Width           =   735
         End
         Begin VB.TextBox TxtDose 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   4
            Left            =   3285
            TabIndex        =   37
            Top             =   1090
            Width           =   735
         End
         Begin VB.TextBox xTxtRepeatInterval 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   315
            Left            =   2295
            TabIndex        =   44
            Text            =   "1"
            Top             =   1890
            Visible         =   0   'False
            Width           =   285
         End
         Begin VB.TextBox TxtNodPrescribed 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   0  'None
            Enabled         =   0   'False
            ForeColor       =   &H00800000&
            Height          =   195
            Left            =   1170
            TabIndex        =   48
            Top             =   2970
            Width           =   780
         End
         Begin VB.TextBox TxtDose 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   5
            Left            =   3285
            TabIndex        =   39
            Top             =   1360
            Width           =   735
         End
         Begin VB.TextBox TxtDose 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   6
            Left            =   3285
            TabIndex        =   41
            Top             =   1630
            Width           =   735
         End
         Begin VB.Line Line12 
            X1              =   0
            X2              =   2250
            Y1              =   1890
            Y2              =   1890
         End
         Begin VB.Label RxUnits 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   1  'Fixed Single
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   1
            Left            =   3285
            TabIndex        =   29
            Top             =   0
            Width           =   735
         End
         Begin VB.Label Label2 
            Appearance      =   0  'Flat
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
            Caption         =   "Qty Prescribed"
            ForeColor       =   &H00800000&
            Height          =   195
            Index           =   1
            Left            =   45
            TabIndex        =   58
            Top             =   2970
            Width           =   1095
         End
         Begin VB.Label Label9 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BorderStyle     =   1  'Fixed Single
            Caption         =   "  time"
            ForeColor       =   &H80000008&
            Height          =   285
            Left            =   4005
            TabIndex        =   30
            Top             =   0
            Width           =   540
         End
         Begin VB.Line Line3 
            BorderColor     =   &H00E0E0E0&
            X1              =   0
            X2              =   4905
            Y1              =   3180
            Y2              =   3180
         End
         Begin VB.Line Line5 
            X1              =   0
            X2              =   0
            Y1              =   2205
            Y2              =   3300
         End
         Begin VB.Label LblName 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            ForeColor       =   &H80000008&
            Height          =   315
            Left            =   45
            TabIndex        =   57
            Top             =   2580
            Width           =   4455
         End
         Begin VB.Line Line4 
            BorderColor     =   &H00FFFFFF&
            X1              =   4875
            X2              =   4875
            Y1              =   1890
            Y2              =   3285
         End
         Begin VB.Line Line7 
            X1              =   4525
            X2              =   4525
            Y1              =   1900
            Y2              =   3280
         End
         Begin VB.Line Line6 
            BorderColor     =   &H00000000&
            X1              =   0
            X2              =   4525
            Y1              =   3200
            Y2              =   3200
         End
         Begin VB.Line Line11 
            X1              =   3840
            X2              =   0
            Y1              =   2190
            Y2              =   2190
         End
         Begin VB.Label RxUnits 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            ForeColor       =   &H00000000&
            Height          =   195
            Index           =   0
            Left            =   1935
            TabIndex        =   56
            Top             =   2970
            Width           =   600
         End
         Begin VB.Label Label12 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            Caption         =   "  Repeat each"
            ForeColor       =   &H00800000&
            Height          =   255
            Left            =   2730
            TabIndex        =   43
            Top             =   1950
            Width           =   1065
         End
      End
      Begin VB.Frame fraLabel 
         Height          =   2835
         Left            =   2520
         TabIndex        =   82
         Top             =   415
         Width           =   4515
         Begin VB.TextBox TxtLabel 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   0  'None
            BeginProperty Font 
               Name            =   "Courier New"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   9
            Left            =   60
            TabIndex        =   92
            Top             =   2520
            Width           =   4380
         End
         Begin VB.TextBox TxtLabel 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   0  'None
            BeginProperty Font 
               Name            =   "Courier New"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   4
            Left            =   60
            TabIndex        =   87
            Top             =   1190
            Width           =   4380
         End
         Begin VB.TextBox TxtLabel 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   0  'None
            BeginProperty Font 
               Name            =   "Courier New"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   5
            Left            =   60
            TabIndex        =   88
            Top             =   1460
            Width           =   4380
         End
         Begin VB.TextBox TxtLabel 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   0  'None
            BeginProperty Font 
               Name            =   "Courier New"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   6
            Left            =   60
            TabIndex        =   89
            Top             =   1730
            Width           =   4380
         End
         Begin VB.TextBox TxtLabel 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   0  'None
            BeginProperty Font 
               Name            =   "Courier New"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   2
            Left            =   60
            TabIndex        =   85
            Top             =   650
            Width           =   4380
         End
         Begin VB.TextBox TxtLabel 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   0  'None
            BeginProperty Font 
               Name            =   "Courier New"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   3
            Left            =   60
            TabIndex        =   86
            Top             =   920
            Width           =   4380
         End
         Begin VB.TextBox TxtLabel 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   0  'None
            BeginProperty Font 
               Name            =   "Courier New"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   8
            Left            =   60
            TabIndex        =   91
            Top             =   2270
            Width           =   4380
         End
         Begin VB.TextBox TxtLabel 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   0  'None
            BeginProperty Font 
               Name            =   "Courier New"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   7
            Left            =   60
            TabIndex        =   90
            Top             =   2000
            Width           =   4380
         End
         Begin VB.TextBox TxtLabel 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   0  'None
            BeginProperty Font 
               Name            =   "Courier New"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   1
            Left            =   60
            TabIndex        =   84
            Top             =   380
            Width           =   4380
         End
         Begin VB.TextBox TxtLabel 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   0  'None
            BeginProperty Font 
               Name            =   "Courier New"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00000000&
            Height          =   285
            Index           =   0
            Left            =   60
            TabIndex        =   83
            Top             =   125
            Width           =   4380
         End
      End
      Begin VB.Frame fraPrepared 
         BorderStyle     =   0  'None
         Height          =   3345
         Left            =   7110
         TabIndex        =   59
         Top             =   420
         Width           =   2435
         Begin VB.TextBox txtPrepDate 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Left            =   725
            TabIndex        =   77
            TabStop         =   0   'False
            Text            =   " "
            Top             =   1305
            Visible         =   0   'False
            Width           =   1050
         End
         Begin VB.TextBox TxtStopTime 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Left            =   1750
            TabIndex        =   75
            Top             =   855
            Visible         =   0   'False
            Width           =   615
         End
         Begin VB.TextBox TxtStopDate 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Left            =   725
            TabIndex        =   74
            Top             =   855
            Visible         =   0   'False
            Width           =   1050
         End
         Begin VB.TextBox TxtStartDate 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Left            =   725
            TabIndex        =   71
            Top             =   585
            Visible         =   0   'False
            Width           =   1050
         End
         Begin VB.TextBox txtPrepTime 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Left            =   1750
            TabIndex        =   78
            TabStop         =   0   'False
            Text            =   " "
            Top             =   1305
            Visible         =   0   'False
            Width           =   615
         End
         Begin VB.Frame fraDays 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
            BorderStyle     =   0  'None
            ForeColor       =   &H00000000&
            Height          =   1555
            Left            =   0
            TabIndex        =   60
            Top             =   1800
            Visible         =   0   'False
            Width           =   650
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   7
               Left            =   45
               TabIndex        =   68
               Top             =   1275
               Width           =   240
            End
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   6
               Left            =   45
               TabIndex        =   67
               Top             =   1085
               Width           =   225
            End
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   5
               Left            =   45
               TabIndex        =   66
               Top             =   895
               Width           =   225
            End
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   4
               Left            =   45
               TabIndex        =   65
               Top             =   705
               Width           =   240
            End
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   3
               Left            =   45
               TabIndex        =   64
               Top             =   515
               Width           =   240
            End
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   2
               Left            =   45
               TabIndex        =   63
               Top             =   325
               Width           =   240
            End
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   1
               Left            =   45
               TabIndex        =   62
               Top             =   135
               Width           =   240
            End
            Begin VB.Label Lbldays 
               Appearance      =   0  'Flat
               BackColor       =   &H8000000A&
               Caption         =   "Mon Tue Wed Thu  Fri  Sat  Sun"
               ForeColor       =   &H00000000&
               Height          =   1400
               Left            =   270
               TabIndex        =   61
               Top             =   135
               Width           =   340
            End
         End
         Begin VB.TextBox TxtStartTime 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Left            =   1750
            TabIndex        =   72
            Top             =   585
            Visible         =   0   'False
            Width           =   615
         End
         Begin VB.Label lblPatprint 
            BackColor       =   &H00800000&
            Caption         =   " PAT PRINT"
            ForeColor       =   &H00FFFFFF&
            Height          =   230
            Left            =   960
            MouseIcon       =   "ucDispens.ctx":17604
            MousePointer    =   99  'Custom
            TabIndex        =   127
            Top             =   75
            Visible         =   0   'False
            Width           =   900
         End
         Begin VB.Label lblModState 
            BackStyle       =   0  'Transparent
            BeginProperty Font 
               Name            =   "Wingdings"
               Size            =   8.25
               Charset         =   2
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   255
            Left            =   1440
            TabIndex        =   126
            Top             =   60
            Width           =   255
         End
         Begin VB.Label lblInfo 
            AutoSize        =   -1  'True
            BackStyle       =   0  'Transparent
            Height          =   195
            Left            =   0
            TabIndex        =   125
            Top             =   360
            UseMnemonic     =   0   'False
            Width           =   165
         End
         Begin VB.Label lblPrompt 
            AutoSize        =   -1  'True
            BackStyle       =   0  'Transparent
            Caption         =   "Options"
            ForeColor       =   &H00C00000&
            Height          =   195
            Index           =   4
            Left            =   360
            MouseIcon       =   "ucDispens.ctx":1790E
            MousePointer    =   99  'Custom
            TabIndex        =   0
            Top             =   45
            Width           =   540
         End
         Begin VB.Image imgScript 
            Height          =   240
            Left            =   0
            Picture         =   "ucDispens.ctx":17C18
            Top             =   45
            Width           =   240
         End
         Begin VB.Label lblBNF 
            BackColor       =   &H00800000&
            Caption         =   " BNF "
            ForeColor       =   &H00FFFFFF&
            Height          =   230
            Left            =   1920
            MouseIcon       =   "ucDispens.ctx":17F7F
            MousePointer    =   99  'Custom
            TabIndex        =   124
            Top             =   75
            Width           =   405
         End
         Begin VB.Label Label5 
            Alignment       =   1  'Right Justify
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
            BackStyle       =   0  'Transparent
            Caption         =   "Stop"
            ForeColor       =   &H80000008&
            Height          =   270
            Left            =   0
            TabIndex        =   73
            Top             =   885
            Visible         =   0   'False
            Width           =   615
         End
         Begin VB.Label Label6 
            Alignment       =   1  'Right Justify
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
            BackStyle       =   0  'Transparent
            Caption         =   "Start"
            ForeColor       =   &H80000008&
            Height          =   285
            Left            =   0
            TabIndex        =   70
            Top             =   615
            Visible         =   0   'False
            Width           =   615
         End
         Begin VB.Label Label3 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "          Date               Time"
            ForeColor       =   &H80000008&
            Height          =   255
            Left            =   285
            TabIndex        =   69
            Top             =   330
            Visible         =   0   'False
            Width           =   2010
         End
         Begin VB.Line SiteLine1 
            BorderColor     =   &H00FFFFFF&
            X1              =   0
            X2              =   2435
            Y1              =   1725
            Y2              =   1725
         End
         Begin VB.Label lblDSSWarning 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
            ForeColor       =   &H80000008&
            Height          =   495
            Left            =   840
            TabIndex        =   80
            Top             =   2760
            Width           =   1515
         End
         Begin VB.Label lblLocation 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            ForeColor       =   &H80000008&
            Height          =   720
            Left            =   840
            TabIndex        =   79
            Top             =   2040
            Width           =   1515
         End
         Begin VB.Label lblPrepared 
            BackStyle       =   0  'Transparent
            Caption         =   "Prepared"
            Height          =   255
            Left            =   0
            TabIndex        =   76
            Top             =   1335
            Visible         =   0   'False
            Width           =   735
         End
      End
      Begin VB.Label LblWarning 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         ForeColor       =   &H000000FF&
         Height          =   240
         Left            =   5000
         TabIndex        =   122
         Top             =   3285
         Width           =   1950
      End
      Begin VB.Label lblExpiry 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         ForeColor       =   &H00000000&
         Height          =   240
         Left            =   2610
         TabIndex        =   95
         Top             =   3525
         Width           =   4350
      End
      Begin VB.Label DoAction 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         Caption         =   "DoAction"
         ForeColor       =   &H80000008&
         Height          =   285
         Left            =   3690
         TabIndex        =   94
         Top             =   5670
         Visible         =   0   'False
         Width           =   1275
      End
   End
   Begin VB.Line SiteLine0 
      BorderColor     =   &H00FFFFFF&
      Visible         =   0   'False
      X1              =   7125
      X2              =   9525
      Y1              =   1680
      Y2              =   1680
   End
   Begin VB.Label lblStatus 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "status"
      Enabled         =   0   'False
      ForeColor       =   &H00808080&
      Height          =   225
      Index           =   0
      Left            =   25
      TabIndex        =   121
      Top             =   50
      Width           =   420
   End
End
Attribute VB_Name = "Dispense"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' Dispense UserControl
'==========================
'08Sep04 CKJ Derived from V8.6 Dispens.frm

'Form settings for reference:
'usercontrol
'  height   4530
'  width    9630
'picture1
'  height   4290
'  width    9585


'25Jul05 CKJ Removed Alt keys from form - not reliable in web page
'            Removed TxtPrepDate/Time and hidden all date/time
'            Removed Discontinue label and popup
'            Replaced backing image with one which matches slimmer control
'03Mar06 CKJ/TH Added check for cancelled prescription
'17May06 CKJ DoAction_Change: Added "RefreshState-ForceInactive" to half-close the database connection and
'            call RefreshState recursively to shut the UserControl down.
'10Feb07 CKJ Mechdisp handling added
'20May08 CKJ TxtPrompt_KeyUp: Robot printing; clear messageid & section, add () to preserve NumOfLabels
'17Jul08 CKJ Replaced PhaRTL with V10 .NET calls
'25sep08 CKJ TxtPrompt_Keyup: Moved SetFocus call below deferred printing (F0028203)
'            Refreshstate: Added default to override pid.status "A"   (F0020276)
'30sep08 CKJ removed call to SetSpecialty: superfluous as var is global already (F0019922)
'             Specialty to upper case
'             Optional setting Ascribe, PID, SpecialtyMandatory="Y"
'             Ward & Consultant; removed default of "NONE" if no element in XML
'17oct08 CKJ MnuStockLevel_Click: Replaced shell with internal stock enquiry  (F0036013)
'20oct08 CKJ TxtPrompt_Keyup: extra call to DeferredPrinting added, so that setfocus can be done inside IFs (F0036227)
'            various: commented out unused code to save space
'27oct08 CKJ added SetFocusTo TxtPrompt, as focus appears to vary depending on preceding popups (F0036227)
'23Jun08 XN  F0033906 Added g_URLToken to cache the URL for frmWebClient.
'03Sep09 PJC RefreshState: Populate PatientPaymentCategory in the pid structure from the OCX heap. (F0054530)
'21Sep09 PJC OCXHeapPatientElementToPrintHeap: Created (F0054530)
'21Sep09 PJC RefreshState: Added call to OCXHeapPatientElementToPrintHeap (F0054530)
'05Oct09 PJC OCXHeapPatientElementToPrintHeap: Added Primary Patient Identifier Display to print heap (F0064619)
'05Oct09 PJC RefreshState: Populated pidExtra with the PatientIdentifier/Valid for the patient print heap. (F0064619)
'07Apr10 AJK Added HILaunchLeaflet call to TxtPrompt_KeyUp (F0072542) Ported from v8
'15Apr10 XN  Prevent dispensing to \'Out of Use\' consultants
'16Apr10 TH/AJK F0072542 Ensured pidExtra.Specialty is updated to allow speciality expansion to be added to print heap (HIL requirement)
'06May10 AJK RefreshState: F0073627 Wipe off route flag
'11Aug10 CKJ Added IPLinkShutDown to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)

'05Aug10 TH  RefreshState: Added call to initialise print element for output interface (UHB)(F0077942)
'28Feb11 AJK RefreshState: F0067942 Added SupplementaryText Append to textbox directly as it's not derived from a code
'11Feb11 TH  printOCXdetailsWrap: Written for Chemocare (F0036868)
'15Feb11 TH  picOCXdetails_Click: Rewritten for Chemocare (F0036868)
'22Mar11 CKJ RefreshState: F0067942 Amended to only append SupplementaryText (not insert in middle of text),
'            and separated with crlf   (F0111869)
'25Mar11 CKJ RefreshState: F0067942 Removed sporadic extra crlf  (F0111869)
'27Jun11 XN  RefreshState: F0089668 Added test for out of use wards
'19Jul10 XN  RefreshState: F0123343 added siteID to pEpisodeSelect
'06Sep11 TH  RefreshState: Mods to improve Asymetric dosing (include duration and add extra link support (as default)) (TFS13203)
'16Sep11 CKJ RefreshState: Episode type handling simplified with addition of alias table   (TFS14479)
'28Jun12 AJK 36929 SetConnection: Changed ConnectionString to UnencryptedData
'                                 Get unencrpyted data generically and then decide if to create a web or direct data connection
'02Jul12 CKJ SetSiteLineColour: written to mirror StoresMenuBarColour
'            Alternative label layouts added
'            Site colour bar added
'20Jul12 TH  Added input param for TFS 26712
'10Oct12 TH  suppress already dispensed today check if PSO (TFS 41435)
'21Sep12 AJK RefreshState: 44489 Added check to ensure we're not loading all of this info when no Rx is in scope
'04Oct12 CKJ use transport layer wrapper for setsiteline & force-inactive (TFS44503)
'11Oct12 TH  RefreshState: Fixed above mod to allow patient printing routines (which are not based on rx ID)(TFS 46459)
'29Jan13 TH  RefreshState: Drop and recreate the print heap to stop persistence on re-entry TFS 54634
'29Jan13 TH  RefreshState: Cross check on Episode for state and Rx Added TFS 54633
'30Jan13 TH  RefreshState: Altered msgs and added logging TFS 54633
'16Jan13 XN  RefreshState: Optimise loading user information (48747)
'22Jan13 XN  RefreshState: If session changes then clear user details (53975)
'30Jan13 XN  RefreshState: Set the patient address and post code on pidExtra, so goes on print heap (41410)
'24Apr13 XN  RefreshState: Changed seed to work on any PC (60910)
'13Jun13 TH  RefreshState: Replaced reading of hour for infusion duraion abbr as abbrev had been changed (TFS 66438)
'13Jun13 TH  RefreshState: Reinstated Firstload flag to handle prepdate for STDLBL4B Added (TFS 66470)

'01Jul13 TH  RefreshState: Stop designation of a continuous infusion as a stat dose. (TFS 56672)
'08Jan14 TH  TxtPrompt_KeyUp: Added call to savelabel on "I" from prompt because if this is not present then we may not get label ID in the translog or Billing transaction (TFS 81381)
'17Oct14 XN  RefreshState: 88560 Prevented user from searching for drug via BNF (findrdrug)
'05Nov14 XN  UserControl_KeyDown: 44134 Allowing focus to go back to control when dialog is closed
'06Nov14 XN  RefreshState: Added setting BSA (83897)
'08Apr15 TH  RefreshState: Added override settings for dose rounding on label (TFS 82713)
'13May15 XN  RefreshState: Added AllowReDispensingStr parameter to prevent reuse of dispensing records (mainly disabled for emm sites) 26726
'            Added AllowReDispensingType Enum 26726
'12Jun15 TH  TxtPrompt_KeyUp: Ensure pid.ward is update by user selecting correct cost centre (TFS 58926)
'27Jul15 TH  RefreshState: Added to reset the terminal name (in case switched mid session (TFS 60163)
'28Jul15 TH  TxtPrompt_KeyUp: Ensure WYSWYG is updated if ward is swapped (TFS 123260)
'21Jul15 TH  RefreshState: First pass on custom frequency prescription handling (TFS 123221)
'05Aug15 TH  RefreshState: Second pass on Custom frequencies, especially around handling of doseless Rxs (TFS 125159)
'13Aug15 TH  Now mechanically still derive the duration (course length) from custom frequency labels  (TFS 126257)
'17Aug15 TH  TxtPrompt_KeyUp: Added ucase and trim (TFS 123260)
'10Sep15 TH  RefreshState: Add in route if  eyelabel style (TFS 128201)
'10Sep15 TH  RefreshState: Added support for custom frequency with complex (linked) prescriptions (TFS 128203)
'15Sep15 TH  TxtPrompt_KeyUp: Mod to scrape dose for custom frequency (as it does for Stat) when CIVAS (TFS 129498)
'16Sep15 TH  RefreshState: Remove point correctly to pick up checkstandard (spoon) settings on dose (TFS 129773)
'18Sep15 TH  AppendChildPrescriptionforLinkedRx: Written in attempt to simplify and refactor a little refreshstate (TFS 129844)
'18Sep15 TH  RefreshState: Extended and shifted handling of complex children to own sub for refactoring purposes (TFS 129844)
'18Sep15 TH  AppendChildPrescriptionforLinkedRx: Extended Prescription Infusion complex linking to allow for custom frequency(TFS 129929)
'28Sep15 TH  ProcessLabelDuration: Written to refactor (a bit) refreshstate. This just process the durational aspect of the direction codes incomming (TFS 130610)
'28Sep15 TH  RefreshState: Extended and shifted handling of  durational aspect of the direction codes to own sub for refactoring purposes  (TFS 130610)
'03Nov15 TH  RefreshState: Added Trim on description to ensure correct check for selecting drug name on split dose prompt (TFS 132827)
'12Nov15 TH  RefreshState: Check on trimmed description (TFS 134982)
'15Oct15 TH  AppendChildPrescriptionforLinkedRx: PRNs may not have direction - these and stat are now handled correctly (though should never be stat as secondary rx) (TFS 137379)
'20Oct15 TH  AppendChildPrescriptionforLinkedRx: Overhauled to use correct joining word on label (TFS 137379)
'06Jan16 TH  TxtPrompt_KeyUp: Mod to installment disp so decrement/decrement is by label NOT rx to allow split dose installment dispensing (TFS 138797)
'18Jan16 TH  AppendChildPrescriptionforLinkedRx: Added DurationLastCOde as input param so it can be cached externally and resent (TFS 141453)
'                                                Added PRN specific joining settings and made the setting used after a stat more explicit (TFS 141453)
'29Sep15 XN  RefreshState: Added site specific Rx print elements to heap (TFS 77778)
'06Oct15 XN  RefreshState: Added support for converting chinese name to RTF so can print out 77780
'09Nov15 XN  RefreshState: Added siteID to HongKong/HelperMethod.asmx to get chinese name 133949
'26Apr16 TH  RefreshState: Mod to ensure dose qty box is shown on each pass for pat specific CIVAS issue (TFS 152118)

'01Mar16 XN  PopupFunctionMenu, UserControl_KeyDown: Removed F6 short cut, as does not work with web 104303
'26Apr16 TH  RefreshState: Mod to ensure dose qty box is shown on each pass for pat specific CIVAS issue (TFS 151553)

'04May16 XN  RefreshState: Updated for amm 123082
'                        PrintLabel: Added for amm 123082
'                        DispensLoad: Updated for amm 123082
'                        PopupFunctionMenu: Updated for amm 123082
'18May16 XN  ReprintLabel: Added for amm 153668
'                        PrintLabel: allowed it to do save Reprints 153668
'21Jun16 XN  PrintLabel: Fixed syringe volume 154896
'02Aug16 XN  GetLabelText: Added to allow getting label text without printing, or saving 159413
'02Aug16 XN  PrintLabel: 158642 Fix moving to next stage from AMM labeling stage
'08Aug16 XN  PrintLabel: 159843 Now reads expiry from DB
'24Aug16 XN  PrintLabel: 160920 Fixed expiry
'26Aug16 XN  PopupFunctionMenu: Added filtering of Return Stock for amm 161138
'06Mar18 DR  Bug 198948 - Pharmacy dispensing control in HTAless environment - tab key does not work
'09Mar18 DR  Bug 198948 - Blister pack number field missed
'                       - Pings with each tab
'                       - Random delays
'14Mar18 DR  Bug 198948 - Blister Pack Number field tabs out to first field rather than the label

'start & stop times on F3
'========================
'   parsedate (txtUC("TxtStartDate").Text), pdate$, "1", valid1
'   parsedate (txtUC("TxtStopDate").Text), pdate$, "1", valid2
'   parsetime (txtUC("TxtStartTime").Text), pdate$, "1", valid3
'   parsetime (txtUC("TxtStopTime").Text), pdate$, "1", valid4
'   If valid1 And valid2 And valid3 And valid4 Then
'      StringToDate (txtUC("TxtStopDate").Text), dt
'      StringToTime (txtUC("TxtStopTime").Text), dt
'      datetomins dt
'      today td
'      If L.IsHistory Then
'         WarningCaption "Item from PMR History"
'         ShowWarning% = True
'      ElseIf dt.mint <= td.mint Then
'         WarningCaption "Prescription Expired"
'         ShowWarning% = True
'      Else
'         StringToDate (txtUC("TxtStartDate").Text), td
'         StringToTime (txtUC("TxtStartTime").Text), td
'         datetomins td

'DirectV6toSQL       'in conversion.bas
'WarningV4toSQL
'InstructV4toSQL


Option Explicit
DefInt A-Z

' Used to determine if re-dispensing is allowed (mainly disabled for emm sites)
' XN 12May15 26726
Public Enum AllowReDispensingType
   Enabled
   DisabledIfEmmWard
   Disabled
End Enum

''Dim tFirstLoaded%       'Used to fix problem with Preparation Dialog appearing
'Dim dfirstloaded%       'Set when time & date first loaded. '13Jun13 TH REinstated (TFS 66470)'29Aug13 TH Removed
Dim datechanged As Boolean

''Dim historylab&         '20Jul00 MMA
Dim lastvol As String
Dim allowReDispensing As AllowReDispensingType  ' XN 12May15 26726


Private Const OBJNAME As String = PROJECT & "Dispense."

'06Oct05 CKJ added prescriptionID
Public Event RefreshView(ByVal PrescriptionID As Long, ByVal RequestID As Long)
'
Private Type TabControlsStruct
   name As String
   ControlArrayIndex As Integer
End Type

Dim TabControlsArray(16) As TabControlsStruct
Dim CurrentPositionInTabArray As Integer


Private Sub CmbIssueType_GotFocus()

CurrentPositionInTabArray = 1

End Sub

Private Sub fraLineColour_MouseMove(button As Integer, Shift As Integer, X As Single, Y As Single)

   RemoveHyperlinkStyle
   
End Sub

Private Sub fraPrepared_MouseMove(button As Integer, Shift As Integer, X As Single, Y As Single)

   RemoveHyperlinkStyle
   
End Sub

Private Sub imgScript_Click()

   ToggleRxLabel (fraRx.Visible)
   SetFocusTo TxtPrompt
   
End Sub

Private Sub lblBNF_Click()
      
   LoadBNF
   
End Sub


Private Sub lblInfo_Click()

   ShowUserMessage d.UserMsg
   
End Sub


Private Sub lblPatprint_Click()
FrmPatPrint.Show 1, Me			'AS : MS_Edge_Fix for modal windows without an owner form
'20Nov07 TH Added to clear state
UserControlEnable False
DoAction.Caption = "RefreshView-Inactive"       'clunky but works
'-----
End Sub
Private Sub LblPrompt_Click(Index As Integer)

Dim strPrompt As String

   strPrompt = ""
   Select Case Index
      Case 0: strPrompt = "S"    'Save
      Case 1: strPrompt = "P"    'Print
      Case 2: strPrompt = "D"    'Discontinue
      Case 3: strPrompt = "R"    'Reprint
      Case 4: PopupFunctionMenu True  'Options
      End Select
      
   If Len(strPrompt) Then
      nextchoice = strPrompt
      TxtPrompt_KeyUp 0, 0
   End If
      
End Sub

Private Sub lblPrompt_MouseMove(Index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)

   If lblPrompt(Index).FontUnderline = False Then
      lblPrompt(Index).FontUnderline = True
      lblPrompt(Index).Refresh
   End If
   
End Sub

Private Sub picOCXdetails_Click()
'15Feb11 TH Rewritten for Chemocare (F0036868)


Dim strOCXtext As String

   'ShowDebugScreen '15Feb11 TH replaced with below
   
   Heap 11, gPRNheapID, "rxOCXText", strOCXtext, 0
   printOCXdetailsWrap strOCXtext, False, True
   If GetReviewInterfaceText() Then
      picOCXdetails.Cls
      SetReviewInterfaceText False
      printOCXdetailsWrap strOCXtext, False, False
      SetReviewInterfaceText False
   End If
End Sub

Private Sub TextBlister_GotFocus()

CurrentPositionInTabArray = 3

End Sub

Private Sub TxtLabel_Click(Index As Integer)
Dim intloop As Integer
Dim strLine As String

   If L.extralabel And Index > 0 And Index < 6 Then
      'Show form
      'For intloop = 0 To 19
      'For intloop = 0 To 17  'Reserve 2 lines
      For intloop = 0 To 15  '05Aug14 TH
         setforecolour intloop, True, True
         'Remove the prefixes
         strLine = RTrim$(labelline$(intloop))
         If Mid$(strLine, 2, 1) = "!" Then strLine = Right$(strLine, Len(strLine) - 2)
         'txtUC("TxtLabel", 9).text = LTrim$(txtUC("TxtLabel", 9).text & " " & ans$) '   "
            
         frmExtraLabel.TxtLabel(intloop).text = strLine
      Next
      frmExtraLabel.Show 1, Me			'AS : MS_Edge_Fix for modal windows without an owner form                                                                   '        "
      Exit Sub                                                                         '        "
   End If
   
   If L.IssType = "C" And passlvl <> 8 Then                                               '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then    '         "
         Exit Sub                                                                         '         "
      End If                                                                              '         "
   ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
      Exit Sub
   End If
   If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
      Exit Sub
   End If
   
End Sub

Private Sub TxtLabel_MouseMove(Index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)
Dim iLoop As Integer

   Select Case Index
      Case 1 To 5
         If L.extralabel Then
            For iLoop = 1 To 5
               If Not TxtLabel(iLoop).FontUnderline Then
                  TxtLabel(iLoop).FontUnderline = True
                  TxtLabel(iLoop).Refresh
               End If
            Next
         End If
      Case Else
         For iLoop = 1 To 5
            If TxtLabel(iLoop).FontUnderline Then
               TxtLabel(iLoop).FontUnderline = False
               TxtLabel(iLoop).Refresh
            End If
         Next
   End Select
End Sub
''Private Sub txtPrepDate_DblClick()      '25Jul05 CKJ removed
''
''Dim DateStr$
''
''   enterdate DateStr$
''   If DateStr$ <> "" Then
''         txtPrepDate = DateStr$
''      End If
''
''End Sub

''Private Sub picOCXdetails_dblClick()
'TESTBED CODE ONLY HERE

'   RaiseEvent RefreshView(99)
'   ChooseDevice "", "", True
  
'Dim ptr As Long
'   ptr = GetState(g_SessionID, StateType.Episode)
  
'Dim found As Integer
'  onwsl "ABCDE", "ABC123D", found
'  onwsl "OPD", "WAT200A", found
  
'WarningV4toSQL

''End Sub


'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
'                    UserControl Inherent Events
'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Private Sub UserControl_AccessKeyPress(KeyAscii As Integer)
'

   Select Case KeyAscii
      Case Asc("O"), Asc("o"): PopupFunctionMenu False  'Options
      End Select
      
End Sub

Private Sub UserControl_AmbientChanged(PropertyName As String)
'

'testbed only
''   Debug.Print PropertyName
''   Select Case PropertyName
''      Case "BackColor"
''         Debug.Print Hex$(Ambient.BackColor)
''      End Select
   
End Sub

Private Sub UserControl_AsyncReadComplete(AsyncProp As AsyncProperty)
'

End Sub

Private Sub UserControl_AsyncReadProgress(AsyncProp As AsyncProperty)
'
End Sub

Private Sub UserControl_EnterFocus()
'
End Sub

Private Sub UserControl_ExitFocus()
'
End Sub

Private Sub UserControl_GetDataMember(DataMember As String, Data As Object)
'
End Sub

Private Sub UserControl_GotFocus()
'
End Sub

Private Sub UserControl_Hide()
'Fires in design mode and at run time
End Sub

Private Sub UserControl_HitTest(X As Single, Y As Single, HitResult As Integer)
'
End Sub

Private Sub UserControl_Initialize()
'Fires in design mode and at run time
   
''   If Ambient.UserMode = True Then
      'Make a reference to our control list available
      Set colControls = UserControl.Controls
''   End If
   
   lblStatus(0) = " Initialised "
   UserControlIsAlive = 1
   
''   App.HelpFile = "e:\ascribe\ascshell.hlp"

TabControlsArray(0) = NewTabControlsStruct("TxtPrompt", -1)
TabControlsArray(1) = NewTabControlsStruct("CmbIssueType", -1)
TabControlsArray(2) = NewTabControlsStruct("TxtQtyPrinted", -1)
TabControlsArray(3) = NewTabControlsStruct("TextBlister", -1)
TabControlsArray(4) = NewTabControlsStruct("TxtLabel", 0)
TabControlsArray(5) = NewTabControlsStruct("TxtLabel", 1)
TabControlsArray(6) = NewTabControlsStruct("TxtLabel", 2)
TabControlsArray(7) = NewTabControlsStruct("TxtLabel", 3)
TabControlsArray(8) = NewTabControlsStruct("TxtLabel", 4)
TabControlsArray(9) = NewTabControlsStruct("TxtLabel", 5)
TabControlsArray(10) = NewTabControlsStruct("TxtLabel", 6)
TabControlsArray(11) = NewTabControlsStruct("TxtLabel", 7)
TabControlsArray(12) = NewTabControlsStruct("TxtLabel", 8)
TabControlsArray(13) = NewTabControlsStruct("TxtLabel", 9)
TabControlsArray(14) = NewTabControlsStruct("TxtFinalVol", -1)
TabControlsArray(15) = NewTabControlsStruct("TxtInfusionTime", -1)

CurrentPositionInTabArray = 0
   
End Sub

Private Sub UserControl_InitProperties()
'Fires in design mode and at run time

''   If Ambient.UserMode = True Then
''      'Make a reference to our control list available
''      Set colControls = UserControl.Controls
''   End If

End Sub

Private Sub UserControl_KeyDown(KeyCode As Integer, Shift As Integer)
'Form KeyPreview comes here first
'16Aug12 TH Changed msg on prevention of label edit (TFS 40666)
'05Nov14 XN 44134 Allowing focus to go back to control when dialog is closed
'01Mar16 XN 104303 Removed F6 short cut key as does not work in web

   Select Case Shift
      Case NO_MASK
         Select Case KeyCode
            Case 9
               UserControlTab (Shift)
               
            Case KEY_F2
               KeyCode = 0
                           CalcIV 1, True
               ToggleRxLabel (fraRx.Visible)
            
            Case KEY_F3
               KeyCode = 0
               furtherinfo
               
               If Not (ActiveControl Is Nothing) Then ActiveControl.SetFocus     ' XN 5Nov14 44134 Allowing focus to go back to control when dialog is closed
            Case KEY_F4
               If passlvl <> 3 Then
                  KeyCode = 0
                  MnuStockLevel_Click

                  If Not (ActiveControl Is Nothing) Then ActiveControl.SetFocus     ' XN 5Nov14 44134 Allowing focus to go back to control when dialog is closed
               End If
               
            'Cannot use F5
            
            'Case KEY_F6        ' 01Mar16 XN 104303 Removed F6 short cut key as does not work in web
               'KeyCode = 0
               'SelectAndPrintFFlabels
               
               'If Not (ActiveControl Is Nothing) Then ActiveControl.SetFocus     ' XN 5Nov14 44134 Allowing focus to go back to control when dialog is closed
               
            Case KEY_F7
               KeyCode = 0
               PrintBagLabel
               
               If Not (ActiveControl Is Nothing) Then ActiveControl.SetFocus     ' XN 5Nov14 44134 Allowing focus to go back to control when dialog is closed
               
            'Cannot use F10
            
            Case KEY_F11

            Case KEY_F12
    
            End Select
      
      Case SHIFT_MASK
         Select Case KeyCode
            Case 9
               UserControlTab (Shift)
            Case KEY_F12                         'show heap
               KeyCode = 0
               Heap 100, g_OCXheapID, "", "", 0
            End Select
               
      Case CTRL_MASK
         Select Case KeyCode
            Case vbKeyW         '87, Ctrl-W
               KeyCode = 0
               '22Jul12 TH Added Various suppressions .Label Auditing enhancement (TFS 39622)
               If L.IssType = "C" And passlvl <> 8 And TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then '08Oct09 TH (F0062358)
                  popmessagecr "!", TxtD(dispdata$ & "\patmed.ini", "", "You are not allowed to change this dispensing label", "StopCivasEditsMsg", 0)
               ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
                  popmessagecr "!", TxtD(dispdata$ & "\patmed.ini", "", "You are not allowed to change this dispensing label", "StopIssTypeEditsMsg", 0)
               ElseIf passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then '20Jul12 TH Added (TFS 26712)
                  popmessagecr "!", TxtD(dispdata$ & "\patmed.ini", "", "You are not allowed to change this dispensing label", "StopIssTypeEditsMsg", 0)
               Else
                  ChooseWarningCode
               End If
                           
               If Not (ActiveControl Is Nothing) Then ActiveControl.SetFocus     ' XN 5Nov14 44134 Allowing focus to go back to control when dialog is closed
            Case vbKeyI         '73, Ctrl-I
               KeyCode = 0
               '22Jul12 TH Added Various suppressions.Label Auditing enhancement (TFS 39622)
               If L.IssType = "C" And passlvl <> 8 And TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then '08Oct09 TH (F0062358)
                  popmessagecr "!", TxtD(dispdata$ & "\patmed.ini", "", "You are not allowed to change this dispensing label", "StopCivasEditsMsg", 0)
               ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
                  popmessagecr "!", TxtD(dispdata$ & "\patmed.ini", "", "You are not allowed to change this dispensing label", "StopIssTypeEditsMsg", 0)
               ElseIf passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then '20Jul12 TH Added (TFS 26712)
                  popmessagecr "!", TxtD(dispdata$ & "\patmed.ini", "", "You are not allowed to change this dispensing label", "StopIssTypeEditsMsg", 0)
               Else
                  ChooseInstructionCode
               End If
                           
               If Not (ActiveControl Is Nothing) Then ActiveControl.SetFocus     ' XN 5Nov14 44134 Allowing focus to go back to control when dialog is closed
            End Select
            
      Case ALT_MASK
         Select Case KeyCode
            Case KEY_F12                         'flush heap
               KeyCode = 0
               FlushIniCache
               popmessagecr "#", "Heap flushed"
            End Select
      
      End Select
      
End Sub

Private Sub UserControl_KeyPress(KeyAscii As Integer)

If KeyAscii = 9 Then
    KeyAscii = 0
End If

End Sub

Private Sub UserControl_KeyUp(KeyCode As Integer, Shift As Integer)
'
End Sub

Private Sub UserControl_MouseMove(button As Integer, Shift As Integer, X As Single, Y As Single)

   RemoveHyperlinkStyle
   
End Sub

Private Sub UserControl_Paint()
'Fires in design mode and at run time

End Sub

Private Sub UserControl_ReadProperties(PropBag As PropertyBag)
'Fires in design mode and at run time

End Sub

Private Sub UserControl_Resize()
'Fires in design mode and at run time

   If Ambient.UserMode Then
      SetupDispensForm
   End If
   
End Sub

Private Sub UserControl_Show()
'Fires in design mode and at run time

   'Picture1.Visible = False
   'Picture1.Enabled = False
   'MsgBox "show"
   
   StoreUCHwnd UserControl.Hwnd     '10Feb07 CKJ
   
End Sub

Private Sub UserControl_Terminate()
'Fires in design mode and at run time
'tidy up & go home
   
   IPLinkShutdown                       '11Aug10 CKJ Added to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)

'   On Error Resume Next
'   If Not gTransport Is Nothing Then
'      If gTransport.Connection.state = adStateOpen Then
'         gTransport.Connection.Close
'      End If
'
'      If Not gTransport.Connection Is Nothing Then
'         Set gTransport.Connection = Nothing
'      End If
'
'      Set gTransport = Nothing
'   End If

   On Error Resume Next
   If Not gTransport Is Nothing Then
      If gTransportConnectionState() = adStateOpen Then
         gTransportConnectionClose
      End If

      If Not gTransportConnectionIsNothing() Then
         SetgTransportConnectionToNothing
      End If

      Set gTransport = Nothing
   End If

   UserControlIsAlive = 2
   
End Sub

Private Sub UserControl_WriteProperties(PropBag As PropertyBag)
'
End Sub

'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
'                    UserControl Public Methods & Events
'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Public Function RefreshState(ByVal sessionID As Long, _
                             ByVal AscribeSiteNumber As Long, _
                             ByVal RequestID_Prescription As Long, _
                             ByVal RequestID_Dispensing As Long, _
                             ByVal URLToken As String, _
                             ByVal LabelTypesPreventEdit As String, _
                             ByVal AllowReDispensingStr As String, _
                             ByVal RequestID_AmmSupplyRequest As Long _
                             ) As Boolean
'21Nov05 CKJ Changed to now be the only entry to the usercontrol.
'            SetConnection is called from here, and the AscribeSiteNumber param has been added
'18Jul08 CKJ Added param URLtoken for setconnection
'25sep08 CKJ Added default to override pid.status "A"   (F0020276)
'
'
'21Oct08 TH  Added New functionality to allow for print of pmc's and patient bag labels from icw buttons
'21Oct08 TH  Set PCT Question to default to previous answer when asked again
'27oct08 CKJ added SetFocusTo TxtPrompt, as focus appears to vary depending on preceding popups (F0036227)
'03Sep09 PJC Populate PatientPaymentCategory in the pid structure from the OCX heap. (F0054530)
'21Sep09 PJC Added call to OCXHeapPatientElementToPrintHeapprint for additional elements (F0054530)
'05Oct09 PJC Populated pidExtra with the PatientIdentifier/Valid for the patient print heap. (F0064619)
'16Apr10 TH/AJK F0072542 Ensured pidExtra.Specialty is updated to allow speciality expansion to be added to print heap (HIL requirement)
'06May10 AJK F0073627 Wipe off route flag
'05Aug10 TH  Added call to initialise print element for output interface (UHB)(F0077942)
'28Feb11 AJK F0067942 Added SupplementaryText Append to textbox directly as it's not derived from a code
'11Feb11 TH  Chemocare - OCX mods (F0036868)
'15Feb11 TH  Further Chemocare mods (F0036868)
'25Mar11 CKJ Amended Supplementary Text handling  (F0111869)
'27Jun11 XN  RefreshState: F0089668 Added test for out of use wards
'19Jul10 XN  F0123343 added siteID to pEpisodeSelect
'05Aug11 TH  Added (TFS 10726) Ensure ocxpanel is blnaked on entry.
'06Sep11 TH  Mods to improve Asymetric dosing (include duration and add extra link support (as default)) (TFS13203)
'08Sep11 TH  Added the following check on product inuse for re-dispensing (TFS13555)
'16Sep11 CKJ Episode type handling simplified with addition of alias table   (TFS14479)
'09Nov11 TH  Further mods to handle split dosing of complex types (TFS18827)
'20Jul12 TH  Added input param for TFS 26712
'06Aug12 TH  Added check on trying to redispense a PSO (TFS 40715)
'07Aug12 TH  New PSO button (TFS 40531)
'09Aug12 TH (TFS 40682) Ensure issue type combo restricted correctly (cling film lbl mod) when redispensing.
'21Sep12 AJK 44489 Added check to ensure we're not loading all of this info when no Rx is in scope
'11Oct12 TH  Fixed above mod to allow patient printing routines (which are not based on rx ID)(TFS 46459)
'10Oct12 TH  suppress already dispensed today check if PSO (TFS 41435)
'22Nov12 TH  Allow PSO Split dose from PMR button (TFS 40895)
'29Jan13 TH  Drop and recreate the print heap to stop persistence on re-entry TFS 54634
'29Jan13 TH  Cross check on Episode for state and Rx Added TFS 54633
'30Jan13 TH  Altered msgs and added logging
'16Jan13 XN  48747 Optimise loading user information
'22Jan13 XN  53975 If session changes then clear user details
'30Jan13 XN  41410 Set the patient address and post code on pidExtra, so goes on print heap
'07Mar13 TH  Clear Label status on new dispensing request. (TFS 58265)
'04Jul13 TH  Initialise new concentration (extemp fields) (TFS 39202)
'06Aug13 TH  Added call to CalcIV on CIVAS redispense to ensure actual concentration elements are filled (TFS 70867)
'24Apr13 XN  Changed seed to work on any PC (60910)
'13Jun13 TH  Replaced reading of hour for infusion duraion abbr as abbrev had been changed (TFS 66438)
'13Jun13 TH  Reinstated Firstload flag to handle prepdate for STDLBL4B Added (TFS 66470)
'01Jul13 TH  Stop designation of a continuous infusion as a stat dose. (TFS 56672)
'19Sep13 TH  Made ocx time units (Durations) case insensitive - these had been changed in the DB (TFS 73783)
'03Oct13 TH  Ensure DoC repeat variables are reset (TFS 74486)
'15Oct13 TH  Now allow split dose of Infusion Prescriptions in some circumstances (TFS 75250)
'25Nov13 TH  Added reset of rpt Qty -was being cached and "polluting" none rpt issues (TFS 78979)
'17Oct14 XN  88560 Prevented user from searching for drug via BNF (findrdrug)
'06Nov14 XN  Added setting BSA (83897)
'08Apr15 TH  Added override settings for dose rounding on label (TFS 82713)
'14Apr15 TH  Moved SetLabelTypesPreventEdit below readsiteinfo as now may need loaded data for user interaction (TFS 110013)
'13May15 XN Added AllowReDispensingStr parameter to prevent reuse of dispensing records (mainly disabled for emm sites) 26726
'27Jul15 TH  Added to reset the terminal name (in case switched mid session (TFS 60163)
'21Jul15 TH  First pass on custom frequency prescription handling (TFS 123221)
'05Aug15 TH  Second pass on Custom frequencies, especially around handling of doseless Rxs (TFS 125159)
'09Aug15 TH  Removed course length from custom frequency labels (TFS 125872)
'13Aug15 TH  Now mechanically still derive the duration (course length) from custom frequency labels  (TFS 126257)
'10Sep15 TH  Add in route if  eyelabel style (TFS 128201)
'10Sep15 TH  Added support for custom frequency with complex (linked) prescriptions (TFS 128203)
'16Sep15 TH  Remove point correctly to pick up checkstandard (spoon) settings on dose (TFS 129773)
'18Sep15 TH  Extended and shifted handling of complex children to own sub for refactoring purposes (TFS 129844)
'28Sep15 TH  Extended and shifted handling of  durational aspect of the direction codes to own sub for refactoring purposes  (TFS 130610)
'03Nov15 TH  Added Trim on description to ensure correct check for selecting drug name on split dose prompt (TFS 132827)
'12Nov15 TH  Check on trimmed description (TFS 134982)
'29Sep15 XN  Added site specific Rx print elements to heap (TFS 77778)
'06Oct15 XN Added support for converting chinese name to RTF so can print out 77780
'26Apr16 TH  Mod to ensure dose qty box is shown on each pass for pat specific CIVAS issue (TFS 152118)
'04May16 XN  Updated for amm 123082

'Injection/Infusion prescription
'-------------------------------
'prescriptiontypedescription=Infusion
'
'PrescriptionInfusion table
'  (RequestID)
'  UnitID_InfusionDuration
'  UnitID_RateMass
'  UnitID_RateTime
'  Continuous
'  InfusionDuration
'  InfusionDurationLow
'  Rate
'  RateMin
'  RateMax
'
'
'
'
'Ingredient table
'  (IngredientID)
'  (RequestID)
'  ProductID
'  Quantity
'  QuantityMin
'  QuantityMax
'  UnitID
'  UnitID_Time
'
'
'WLabel structure
'  L.reconvol
'  L.finalvolume
'  L.InfusionTime

' Bolus 1g qds
'  Continuous  InfusionDuration to InfusionDurationLow  UnitID_InfusionDuration  Rate  RateMin  RateMax  UnitID_RateMass  UnitID_RateTime
'   no               0                  0                      0                  0       0       0         0                0
'  Quantity_Ingredient UnitID_Ingredient of ProductID_Ingredient  UnitID_Time_Ingredient
'    1                    8 (g)                12345 (stuff)             0

'Give / dose / by bolus IV injection / frequency / prescriptionduration / modifiers

' Intermittent Infusion   750mg qds over 60 mins                                 Infusion
'  Continuous  InfusionDuration to InfusionDurationLow  UnitID_InfusionDuration  Rate  RateMin  RateMax  UnitID_RateMass  UnitID_RateTime
'   no               60                 0                      2 (min)             0       0       0         0                0
'  Quantity_Ingredient UnitID_Ingredient of ProductID_Ingredient  UnitID_Time_Ingredient
'    750                    9 (mg)               12345 (stuff)             0
'Give 750mg over 60mins qds for 2 days

' Intermittent Infusion   500mL evry six hours over 4 to 5 hours                 Infusion
'  Continuous  InfusionDuration to InfusionDurationLow  UnitID_InfusionDuration  Rate  RateMin  RateMax  UnitID_RateMass  UnitID_RateTime
'   no               5                  4                       3 (???)             0       0       0         0                0
'  Quantity_Ingredient UnitID_Ingredient of ProductID_Ingredient  UnitID_Time_Ingredient
'    500                    12 (??)               12345 (stuff)             0
'Give /500/mL/ over 4 to 5 hours/ every 6 hours

'Give / dose / over duration minutes / frequency / prescriptionduration / modifiers
'                L.InfusionTime


' Continuous infusion 3 microgram / minute for 1 day
'  Continuous  InfusionDuration to InfusionDurationLow  UnitID_InfusionDuration  Rate  RateMin  RateMax  UnitID_RateMass  UnitID_RateTime
'   yes               0                  0                      0                  3       1       5        10 (mcg)        2 (minute)
'  Quantity_Ingredient UnitID_Ingredient of ProductID_Ingredient  UnitID_Time_Ingredient
'    0                    9 (mg)              12345 (stuff)             0


Dim WPat As WPatient
Dim WPatientID As Long
Dim success As Boolean
Dim EpisodeID As Long
Dim ProductID As Long
Dim intSuccess As Integer
Dim lngSuccess As Long
Dim NumericDose As Single
Dim NumericDoseLow As Single
Dim NumericDoseHigh As Single
Dim rs As ADODB.Recordset
Dim strParam As String
Dim strStartDate As String
Dim strStartTime As String
Dim strStopDate As String
Dim strStopTime As String
Dim PrescribedUnits As String
Dim Scaling As String
Dim blnSuppDirCodeUsed As Boolean
Dim tmpDirCode As String
Dim InfusionDuration As Single
Dim InfusionDurationLow As Single
Dim TimeUnit As String
Dim strText As String
Dim msg As String
Dim sep As String
Dim RequestID_PrescriptionValid As Boolean
Dim intDose As Integer     '03Sep08 TH
Dim strAbort As String     '   "
Dim intCount As Integer    '   "
Dim strAns As String       '   "
Dim strDefaultPCTQuestion As String  '11Oct08 TH Added
Dim strOCXtext As String   '10Feb11 TH Added (F0036868)
Dim intloop As Integer  '12Jul11 TH Added
'Dim blnSplitDose As Boolean  '13Jul11 TH Added
Dim blnDone As Boolean
Dim strDirectionLinkCode As String '19Jul11 TH Added
Dim strSplitMsg As String  '21Jul11 TH
Dim strDesc As String      '21Jul11 TH
Dim strInitials As String  '24Jul11 TH Added (F0110136)
Dim intPosn As Integer      '   "
Dim strMsg As String
Dim blnDurationLastCode As Boolean   '06Sep11 TH Added
Dim blnComplexDoseSplitOK As Boolean   '09Nov11 TH Added
Dim blnPCTEsc As Boolean   '10Jan12 TH Added
Dim StrMaxDoseWarning As String  '15Mar12 TH Added
Dim intHealthCareNumberValid As Integer '13May12 TH Added
Dim lngBilling As Long  '29Nov13 TH Billing
Dim strFrequency As String, strDirections As String, strCourse As String '21Jul15 TH
Dim routeword$ '10Sep15 TH Added (TFS 128201)
Dim rsAMMSupplyRequest As ADODB.Recordset
Dim strNSVCode As String
Dim strParams As String

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "RefreshState"

   g_blnSplitDose = False '03Aug11 TH
   g_TotalComplexChildren = 0  '08Nov11 TH Added
   setPCTPRNflag False '05Jan12 TH Added
   setPCTNoCourseLengthFlag False '05Jan12 TH Added
   setPCTStatflag False '05Jan12 TH Added
   blnPCTEsc = False    '10Jan12 TH Added
   setPCTCourseLength 0 '12Jan12 TH Added
   g_blnPSO = False     '02Aug12 TH PSO
   
   'dfirstloaded = True  '13Jun13 TH Added (TFS 66470)'29Aug13 TH Removed
   
   setNHNumberData "", 0 '13May12 TH
   
   SetAttemptedlabelEdit False  '24Jul12 TH Added. Label Auditing enhancement (TFS 39622)
   
   'm_LabelTypesPreventEdit = LabelTypesPreventEdit  '20Jul12 TH Added (TFS 26712)
   'SetLabelTypesPreventEdit LabelTypesPreventEdit '27Jul12 TH Label Auditing enhancement (TFS 39622) '14Apr15 TH Moved below as now may need loaded data for user interaction (TFS 110013)
   
   setTotalRepeats 0 '03Oct13 TH Ensure these are reset (TFS 74486)
   setRepeatNumber 0 '    "
   setRptQuantity 0  '25Nov13 TH Added -was being cached and "polluting" none rpt issues (TFS 78979)
   
   gRequestID_AmmSupplyRequest = RequestID_AmmSupplyRequest
   
   ' Convert the allow redispensing str to enum XN 13May15 26726
   Select Case LCase$(AllowReDispensingStr)
   Case "disabledifemmward"
        allowReDispensing = DisabledIfEmmWard
   Case "disabled"
        allowReDispensing = Disabled
   Case Else
        allowReDispensing = Enabled
   End Select
   'picOCXdetails.Visible = False    '05Aug11 TH Added (TFS 10726)
   'picOCXdetails.Cls                '
   'ImgWarning.Visible = False       '
   
   TxtQtyPrinted.text = ""        '26Apr16 TH Added to ensure dose qty box is shown on each pass (TFS 152118)
   TxtQtyPrinted.Tag = ""         '  "
   
   'Set Parent for Modal form - to resolve modal from issue in MS Edge
   SetOwnerForm Me          'AS : MS_Edge_Fix for modal windows without an owner form
   
   '23Nov05 CKJ Is the user control fully awake & connected? If not then release completely
   On Error Resume Next
   If gTransport Is Nothing Then                                     'transport object doesn't exist
      'no action                                                     ' we'll create it in the next block below
   Else                                                              'transport object is alive
      'If gTransport.Connection Is Nothing Then                      'but not connected
      If gTransportConnectionIsNothing() Then                        'but not connected                  '08Aug12 CKJ
         Set gTransport = Nothing                                    ' terminate the transport object ready for a clean creation below
      Else                                                           'it is connected
         'If gTransport.Connection.state = adStateOpen Then          'open & ready for use
         If gTransportConnectionState() = adStateOpen Then           'open & ready for use               '08Aug12 CKJ
            'no action                                               ' no further action, just use it
         Else                                                        'but not properly open
            'gTransport.Connection.Close                             ' attempt to close (may be connecting, handling an error etc)
            'Set gTransport.Connection = Nothing                     ' disconnect
            gTransportConnectionClose                                ' attempt to close (may be connecting, handling an error etc) '08Aug12 CKJ
            SetgTransportConnectionToNothing                         ' disconnect                                                  '08Aug12 CKJ
            Set gTransport = Nothing                                 ' terminate the transport object ready for a clean creation below
         End If
      End If

      '**!!** consider ClosePatsubs etc to reset globals
   End If
   
   
   On Error GoTo ErrHandler
   
   ' 22Jan13 XN 53975 If session changes then clear user details
   If (g_SessionID <> sessionID) Then
      gEntityID_User = 0
      UserID = ""
      UserFullName = ""
   End If

   g_URLToken = URLToken  ' added cached URL so frmWebClient has a web server name (F0033906)
   success = True
   If (gTransport Is Nothing) Or sessionID <> g_SessionID Then    'session is never zero, so this fires once at startup and again if session ever changes  '23Nov05 CKJ added gTransport
      If UnsavedChanges Then
         popmessagecr "!Please Note:", "Changes from previous session have been discarded"
      End If
      UserControlEnable False
      If sessionID <> 0 And g_SessionID = 0 Then
         lblStatus(0).Caption = " Connecting ... "
      ElseIf sessionID <> g_SessionID Then
         lblStatus(0).Caption = " SessionID changed ... "
      Else
         lblStatus(0).Caption = " Reconnecting ... "
      End If
      
'      frmBlank.Tag = Format$(((1# * frmBlank.Top * frmBlank.Left) / frmBlank.Width) * frmBlank.Height)
      frmBlank.Tag = Format$(((1# * frmBlank.DefaultTop * frmBlank.DefaultLeft) / frmBlank.DefaultWidth) * frmBlank.DefaultHeight)  '24Apr13 XN 60910 Changed connection string encryption seed to work on any PC
      
      'success = SetConnection(SessionID, SiteNumber)
      success = SetConnection(sessionID, AscribeSiteNumber, URLToken)         '18Jul08 CKJ added param URLtoken
   End If
   SetupPRNHeap True, 0 '29Jan13 TH Added this should reset the printheap. Needs to be here so it has initialised variables from readsitinfo TFS 54634
   SetSiteLineColour    '02Jul12 CKJ Added
   
   

   If (RequestID_Prescription = 0 And RequestID_Dispensing = 0) Then success = False '11Oct12 TH fixed mod below to allow patient printing routines (which are not based on rx ID)(TFS 46459)
   
   'If success And RequestID_Prescription > 0 Then '21Sep12 AJK 44489 Added check to ensure we're not loading all of this info when no Rx is in scope
   If success Then '12Oct12 TH Reverted (TFS 46459)
      If Not gTransport Is Nothing Then
'         If Not gTransport.Connection Is Nothing Then
'            If gTransport.Connection.state = adStateOpen Then
         If Not gTransportConnectionIsNothing() Then                 '08Aug12 CKJ
            If gTransportConnectionState() = adStateOpen Then        '   "
                
                ASCTerminalName$ True  '27Jul15 TH Added to reset the terminal name (in case switched mid session (TFS 60163)
   
                If (gEntityID_User <= 0) Or (Len(UserFullName) = 0) Then    ' 22Jan13 XN 53975 Check values have been sent
                ' 16Jan13 XN 48747 Optimise loading user information
'               gEntityID_User = gTransport.ExecuteSelectReturnSP(g_SessionID, "pEntityIDFromSessionID", "")
'               strParam = gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
'               Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPersonSelect", strParam)
                    Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPersonFromSessionID", strParam)
                    
                    If Not rs Is Nothing Then
                       If rs.State = adStateOpen Then
                          If rs.RecordCount <> 0 Then
                             gEntityID_User = RtrimGetField(rs!EntityID)
                             UserID = RtrimGetField(rs!initials)
                             UserFullName = Trim$(RtrimGetField(rs!title) & " " & RtrimGetField(rs!forename) & " " & RtrimGetField(rs!surname))
                             acclevels$ = "1000000000" 'default access, because we couldn't be here unless the user has role "Pharmacy"
                             '**!!** escalate access if extra policies set up - eg use a custom policy
                          End If
                          rs.Close
                       End If
                       Set rs = Nothing
                    End If
                End If
          
               If UnsavedChanges Then
                  popmessagecr "?", "Save Changes?"    '**!!**
                  '
                  '
                  '
                  '
               End If
   
               gRequestID_Prescription = RequestID_Prescription         'master copies for reference throughout the program
               gRequestID_Dispensing = RequestID_Dispensing             'not changed except by a call to this proc
               
               FillHeapDrugInfo -gPRNheapID, d, 0                       'clear drug from print heap
               FillHeapLabelInfo -gPRNheapID, L, 0
               FillHeapStandardInfo gPRNheapID
               
               '04Jul13 TH Initialise new concentration (extemp fields) (TFS 39202)
               Heap 10, gPRNheapID, "ActualDose", "", 0
               Heap 10, gPRNheapID, "ActualVolume", "", 0
               Heap 10, gPRNheapID, "ActualConcLong", "", 0
               Heap 10, gPRNheapID, "ActualConcmgml", "", 0
               Heap 10, gPRNheapID, "ActualConc", "", 0
               Heap 10, gPRNheapID, "ActualDose", "", 0
               '------
               
               Heap 10, gPRNheapID, "InternalOrderNumber", "", 0  '05Aug10 TH Added to initialise element (UHB)(F0077942)
               
               picOCXdetails.Visible = False    '09Aug11 TH Added (TFS 10726) Moved till after DB connected.
               picOCXdetails.Cls                '
               ImgWarning.Visible = False       '
               SetReviewInterfaceText False     '22Jan12 TH Added
               
               SetLabelTypesPreventEdit LabelTypesPreventEdit '14Apr15 TH Moved here as now may need loaded data for user interaction (TFS 110013)
               
               DestroyOCXheap
               Heap 10, gPRNheapID, "sOffRouteProductSelected", "N", 0 '06May10 AJK F0073627 Wipe off route flag
               
               success = ParseKeyValuePairsToHeap("Version=V93", "|", "=", g_OCXheapID)   'create heap with single entry
                  
               If success Then
                  EpisodeID = GetState(g_SessionID, StateType.Episode)
                  gTlogEpisode = EpisodeID                              'JP 15.04.2008 Needed for translog
                  GetEpisodeToOCXHeap EpisodeID, gDispSite              '19Jul10 XN F0123343 added siteID to pEpisodeSelect              26Sep05 CKJ Moved logic from above
                  WPatientID = CLng(OCXheap("EntityID", "0"))
                  If WPatientID <> 0 Then
                     success = GetPatientByPK(WPatientID, WPat)
                  Else
                     success = False
                  End If
               End If
                  
               If success And RequestID_AmmSupplyRequest <> 0 Then
                  success = False
                  '20Jul15 TH Here we will read in what we are going to use from the AMMSupply request
                  'Essentially a site, prescriptonID, Lable (if there is one and drug)
                  strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID_AmmSupplyRequest)
                  Set rsAMMSupplyRequest = gTransport.ExecuteSelectSP(g_SessionID, "pAMMSupplyRequestforOCX", strParams)
                  If Not rsAMMSupplyRequest Is Nothing Then     'use returned recordset
                     If rsAMMSupplyRequest.State = adStateOpen Then
                        If rsAMMSupplyRequest.RecordCount <> 0 Then
                           If EpisodeID = RtrimGetField(rsAMMSupplyRequest!EpisodeID) Then
                              gRequestID_Prescription = RtrimGetField(rsAMMSupplyRequest!PrescriptionID)
                                                          gRequestID_Dispensing = RtrimGetField(rsAMMSupplyRequest!RequestID_Dispensing)
                              strNSVCode = RtrimGetField(rsAMMSupplyRequest!NSVCode)
                              
                              Heap 10, g_OCXheapID, "EpisodeTypeCode", RtrimGetField(rsAMMSupplyRequest!EpisodeTypeCode), 0
                              Heap 10, gPRNheapID, "EpisodeTypeCode", RtrimGetField(rsAMMSupplyRequest!EpisodeTypeCode), 0
                              success = True
                           End If
                        End If
                     End If
                  End If
                  
                  If Not success Then
                    lblStatus(0).Caption = " Can't find supply request... "
                    Error 0
                  End If
               End If
               
               If success Then
   ''               patno& = WPat.EntityID             'WPatientID                  '08Nov05 CKJ same as wpat.recno and wpat.entityid
                  pid.recno = WPat.recno             'Format$(WPatientID)
                  pid.caseno = OCXheap("CaseNo", "") ' GetEpisodeDataItem(EpisodeID, "CaseNo")                 'WPat.caseno
                  gTlogCaseno$ = pid.caseno
                                    
                  gTlogSpecialty$ = UCase(OCXheap("Specialty", ""))         '31Jan06 TH Added      '25Sep08 CKJ added ucase()
                  
                  'If gTlogSpecialty$ = "0" Then gTlogSpecialty$ = "" ' There was nothing there    '03Mar06 CKJ/TH removed as zero doesn't mean blank
                  'setSpecialty gTlogSpecialty$ '07Feb06 TH Added            '30sep08 CKJ removed: superfluous as var is global already
                  
                  pid.sex = WPat.sex
                  pid.dob = WPat.dob
                  '24JulTH F0110136
                  If Len(Trim$(WPat.forename)) > 15 Then
                     'Bigger than the pharmacy forename - initialise
                     pid.forename = WPat.forename
                     strInitials = Left$(WPat.forename, 1)                               'take first initial (may be zero length)
                     intPosn = InStr(WPat.forename, " ")                               'two first names?
                     If intPosn Then                                            '... yes
                        'Can we get the first name and second intitial in ?
                        If Len(Trim$(Left$(WPat.forename, intPosn)) & Mid$(WPat.forename, intPosn, 2)) < 16 Then
                           strInitials = Trim$(Left$(WPat.forename, intPosn)) & Mid$(WPat.forename, intPosn, 2)
                        Else
                           strInitials = strInitials & Mid$(WPat.forename, intPosn, 2)           '03Dec99 TH Retain first initial
                        End If
                     End If
                     pid.forename = strInitials
                  Else
                     pid.forename = WPat.forename
                  End If
                  
                  If Len(Trim$(WPat.surname)) > 20 Then
                     'Bigger than the pharmacy surname - truncate and warn
                     strMsg = Trim$(WPat.surname) & " is too long for The dispensing label." & crlf
                     strMsg = strMsg & "It is recommended that you edit the patient surname to a maximum of 20 characters" & crlf
                     strMsg = strMsg & "If you continue then the patient surname used for any dispensing will be truncated to "
                     strMsg = strMsg & Left$(WPat.surname, 20)
                     strMsg = TxtD(dispdata$ & "\patmed.ini", "", strMsg, "SurnameTruncationMessage", 0)
                     popmessagecr "!", strMsg
                     pid.surname = Left$(WPat.surname, 20)
                  Else
                     pid.surname = WPat.surname
                  End If
                                 
                  'pid.ward = UCase$(OCXheap("WardCode", "NONE"))          'GetEpisodeDataItem(EpisodeID, "WardCode"))    'WPat.ward                  '25Sep08 CKJ removed defaults
                  'pid.cons = UCase$(OCXheap("ConsultantCode", "NONE"))    'UCase$(GetEpisodeDataItem(EpisodeID, "ConsultantCode"))      'WPat.cons       "
                  pid.ward = UCase$(OCXheap("WardCode", ""))               'GetEpisodeDataItem(EpisodeID, "WardCode"))    'WPat.ward                      "
                  pid.cons = UCase$(OCXheap("ConsultantCode", ""))         'UCase$(GetEpisodeDataItem(EpisodeID, "ConsultantCode"))      'WPat.cons       "
                  
                  pid.PatientPaymentCategory = TxtD(dispdata$ & "\Genint.ini", "TranslogInterface", "UNKNOWN", "PatientPaymentDefault", 0) '03Sep09 PJC Populate PatientPaymentCategory in the pid structure from the OCX heap. (F0054530)
                  pid.PatientPaymentCategory = OCXheap("PatientPaymentCategory", "")                                                       '       "
                 
   ''               pid.GP = UCase$(OCXheap("GPCode", "NONE"))             'WPat.GP
                  'pidExtra.NHNumber = OCXheap("HealthCareNumber", "")             '05Oct09 PJC Populated pidExtra with the PatientIdentifier/Valid for the patient print heap. (F0064619)
                  pidExtra.NHNumber = OCXheap("HealthCareNumberUnformatted", "")  '13May12 TH Replaced as HealthCareNumber now pre-formated. Shouldnt be an issue, but needed for compatibility (formatting here done differently)
                  pidExtra.NHnumValid = OCXheap("HealthCareNumberValid", "")      '              "
                  
                  ' 20Jan13 XN 41410 Set the patient address and post code on pidExtra, so goes on print heap
                  pidExtra.Address1 = OCXheap("Address1", "")
                  pidExtra.Address2 = OCXheap("Address2", "")
                  pidExtra.Address3 = OCXheap("Address3", "")
                  pidExtra.Address4 = OCXheap("Address4", "")
                  pidExtra.postCode = OCXheap("PostCode", "")
                                    
                  If LCase(OCXheap("HealthCareNumberValid", "")) = "false" Then
                     intHealthCareNumberValid = 2
                  ElseIf LCase(OCXheap("HealthCareNumberValid", "")) = "true" Then
                     intHealthCareNumberValid = 1
                  Else
                     intHealthCareNumberValid = 0
                  End If
                  
                  setNHNumberData OCXheap("HealthCareNumberUnformatted", ""), intHealthCareNumberValid '13May12 TH added to capture data for the Wtranslog record
                  
                  pidExtra.Speciality = gTlogSpecialty$  '16Apr10 TH/AJK
                
                  msg = ""
                  If Len(trimz(pid.caseno)) = 0 Then msg = msg & TB & "Patient Case Number" & cr
                  If Len(trimz(pid.surname)) = 0 Then msg = msg & TB & "Patient Surname" & cr
                  If Len(trimz(pid.ward)) = 0 Then msg = msg & TB & "Ward Code" & cr
                  If Len(trimz(pid.cons)) = 0 Then msg = msg & TB & "Consultant Code" & cr
                  If TrueFalse(TxtD(dispdata & "\ascribe.ini", "PID", "N", "SpecialtyMandatory", 0)) Then   '25Sep08 CKJ added block
                     If Len(trimz(gTlogSpecialty)) = 0 Then msg = msg & TB & "Specialty Code" & cr
                  End If
                  
                  If Len(msg) Then
                     success = False
                     msg = "The following information has not been entered:" & cr & cr & msg & cr & "Please enter the details before dispensing can begin"
                     popmessagecr ".Insufficient Information For Dispensing", msg
                  ElseIf TrueFalse(OCXheap("ConsultantOutOfUse", "")) And Not TrueFalse(TxtD(dispdata & "\patmed.ini", "", "0", "AllowDispensingToOutOfUseConsultant", 0)) Then
                    success = False     ' XN 15Apr10 section of if added to prevent dispensing to \'Out of Use\' consultants
                    msg = "Consultant for this patient has been marked as out of use." & cr & "Please assign a valid consultant before dispensing can begin."
                    popmessagecr "Invalid Consultant", msg
                    lblStatus(0).Caption = "Consultant marked as out of use."
                  ElseIf TrueFalse(OCXheap("WardOutOfUse", "")) And Not TrueFalse(TxtD(dispdata & "\patmed.ini", "", "0", "AllowDispensingToOutOfUseWard", 0)) Then
                    success = False     ' XN 21Apr10 F0089668 section of if added to prevent dispensing to \'Out of Use\' Wards
                    msg = "Ward for this patient has been marked as out of use." & cr & "Please assign a valid Ward before dispensing can begin."
                    popmessagecr "Invalid Ward", msg
                    lblStatus(0).Caption = "Ward marked as out of use."
                  Else
                     pid.Height = OCXheap("HeightM", "")      'WPat.height
                     pid.weight = OCXheap("WeightKg", "")     'WPat.weight
                     pid.SurfaceAreaInM2 = OCXheap("BSA", "") 'WPat.BSA  83897 XN 6Nov14
                                    
                     RequestID_PrescriptionValid = False                               '03Mar06 CKJ/TH Block added
                     'setDispensingReturn False
                     setHistoryPrescription False  '14Jan10 TH Renamed this to make the logic more readable (F)
                     If RequestID_Prescription Then
                        '12Jual11 TH Now we check to see if this is a complex (linked) rx. If so we set the flag
                        g_blnLinkedPrescription = IsPrescriptionLinked(RequestID_Prescription)
                        
                        If IsRequestCancelled(RequestID_Prescription) Then
                           'F0040489 If we are dispensing then we need to allow for possible return. Set a flag and allow through
                           If gRequestID_Dispensing > 0 Then      '22May09 TH F0040489
                              RequestID_PrescriptionValid = True  '  "
                              'setDispensingReturn True            '  "
                              setHistoryPrescription True  '14Jan10 TH Renamed this to make the logic more readable - basically if this is set (History) only a return should be allowed
                           Else                                   '  "
                              popmessagecr "!", "Prescription has already been cancelled"
                           End If                                 '  "
                        Else
                           RequestID_PrescriptionValid = True
                        End If
                        
                        If RequestID_PrescriptionValid = True Then
                           If gRequestID_Dispensing = -4 Then
                              'If g_blnLinkedPrescription Then   '08Nov11 TH Removed bar on split dose for complex rx. (TFS18827)
                              '   popmessagecr "!", "Complex prescriptions cannot be issued with altered dose"
                              '   RequestID_PrescriptionValid = True
                              'Else
                                 g_blnSplitDose = True
                              'End If
                              RequestID_Dispensing = 0
                              gRequestID_Dispensing = 0
                           ElseIf gRequestID_Dispensing = -5 Then '07Aug12 TH New PSO button (TFS 40531)
                              'popmessagecr "!", "Patient Specific Order"
                              g_blnPSO = True
                              RequestID_Dispensing = 0
                              gRequestID_Dispensing = 0
                              If Not TrueFalse(TxtD(dispdata$ & "\PSO.ini", "PSO", "N", "AllowPSO", 0)) Then '14Nov12 TH PSO Big Switch (TFS 38070)
                                 RequestID_PrescriptionValid = False
                              End If
                           ElseIf gRequestID_Dispensing = -6 Then '22Nov12 TH Allow PSO Split dose from PMR button (TFS 40895)
                              'Split Dose PSO Order
                              g_blnSplitDose = True
                              g_blnPSO = True
                              RequestID_Dispensing = 0
                              gRequestID_Dispensing = 0
                           End If
                           
                        End If
                        
                     Else   '21Oct08 TH Added
                        'Could be new functionality from
                        Select Case gRequestID_Dispensing
                           Case -1
                              FrmPatPrint.Show 1, Me			'AS : MS_Edge_Fix for modal windows without an owner form
                              '20Nov07 TH Added to clear state
                              'UserControlEnable False
                              'DoAction.Caption = "RefreshView-Inactive"
                              RequestID_PrescriptionValid = False
                              
                           'To be merged at a later date
                           'Case -2           'PBS defer Issue -something not stocked in pharmacy
                           '   PBSDeferedIssue
                           '   RequestID_PrescriptionValid = False
                           
                           Case -3           'Print bag label - Middlemore (F000)
                              pid.status = UCase$(OCXheap("EpisodeTypeCode", "A")) '30Jul12 TH Added to allow status driven bag labels (TFS ?????)
                              patlabel k, pid, True, Val(TxtD(dispdata$ & "\patmed.ini", "", "0", "BagLabelDoAll", 0))
                              RequestID_PrescriptionValid = False
                              
                           Case -7     'Print Invoices - Generic Billing
                              lngBilling = billpatient(26, "")
                        End Select
                     End If
                     
                     '26Aug09 TH Added (F0054335)
                     setSecondAuthorisation (TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "CIVAS2ndAuth", 0)))
                        
                     If RequestID_PrescriptionValid Then
                        '29Jan13 TH Here we need to check that the episode we have loaded comes from the same lifetime episode for the rx
                        'If PrescriptionCrossCheckEpisode(RequestID_Prescription, EpisodeID) Then '29Jan13 TH TFS 54633 '13Feb13 TH Moved below
                        'pid.Status = WPat.Status
                        'GetEpisodeDataItem(EpisodeID, "EpisodeTypeDescription"))
                        '01dec05 CKJ Amended status handling to be a two stage process

'16Sep11 CKJ Description is now unusable, as ePEX Spell has been added, and more may be added later
'            Now just calls fEpisodeType() inside pEpisodeSelect, and sets the status there
'            This uses an Alias which has to be kept up to date as new types are added          (TFS14479)
'                        pid.status = UCase$(OCXheap("EpisodeTypeDescription", "A"))    'Use status from patient editor
'                        Select Case pid.status
'                           Case "I", "O", "D", "L" 'No action required
'                              'OK
'                           Case Else
'                              pid.status = UCase$(OCXheap("EpisodeTypeCode", "A"))     'Use status of episode itself
'                           End Select
                        pid.status = UCase$(OCXheap("EpisodeTypeCode", "A"))     'Use status of episode itself
                        
                        Select Case pid.status
                           Case "I", "O", "D", "L" 'No action required
                              'OK
                           Case Else                'Select IODL because an invalid code or the lifetime episode was given - 'A'll
                              If pid.status = "A" Then
                                 msg = "Currently using the Lifetime Episode"
                              Else
                                 msg = "Invalid episode type: " & pid.status
                              End If
                              LstBoxFrm.Caption = "Patient Status"
                              LstBoxFrm.lblTitle = cr & msg & cr & "Please select the episode type for this dispensing" & cr
                              'LstBoxFrm.lblHead = "Optional secondary heading, for column names above the list box"
                              LstBoxFrm.LstBox.AddItem "  In-patient"
                              LstBoxFrm.LstBox.AddItem "  Out-patient"
                              LstBoxFrm.LstBox.AddItem "  Discharge"
                              LstBoxFrm.LstBox.AddItem "  Leave"
                              LstBoxShow
                              If LstBoxFrm.LstBox.ListIndex = -1 Then
                                 popmessagecr "#", "No episode type chosen" & cr & "Discharge status will be used"
                                 pid.status = "D"        '25sep08 CKJ Added default to override "A"
                              Else
                                 pid.status = LTrim$(LstBoxFrm.LstBox.text)
                              End If
                              Unload LstBoxFrm
                        End Select
                     
                        setDispWardSupplier (pid.ward)
                        FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0, True
                        
                        OCXHeapPatientElementToPrintHeap gPRNheapID, pid                '21Sep09 PJC Added call for additional print elements (F0054530)
                        success = PrescriptionToOCXHeap(RequestID_Prescription)         'fill OCX heap
                        SiteSpecificRxInfoToPrintHeap (RequestID_Prescription)                  '29Sep15 XN Added site specific Rx print elements to heap
                                                
                        ' XN 06Oct15 77780 Added support for chinese name as can't handle unicode call web service to get the RTF version and add to print heap
                        Dim chineseName As String
                        Dim chineseNamePresent%
                        Heap 11, gPRNheapID, "ChineseName", chineseName, chineseNamePresent%
                        If chineseNamePresent% Then
                          chineseName = CallWebMethod("application/HongKong/HelperMethod.asmx", "GetChineseNameForRTF", "<sessionId>" + Format(g_SessionID) + "</sessionId><siteId>" + Format(gDispSite) + "</siteId><entityId>" + Format(WPat.EntityID) + "</entityId>")
                          Heap 10, gPRNheapID, "ChineseName", chineseName, 0
                        End If
                                                     
                        '20Aug13 TH Added (TFS 70134)
                        If success And TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "Y", "EnableDispensingDoseRangeChecking", 0)) Then
                           If CheckRptDispLinking(RequestID_Prescription, RequestID_Dispensing) Then
                              'ask the question
                              strAns = "N"
                              'Produce a suitable msg
                              msg = "The dispensing row linked to this prescription should be used." & crlf & crlf & "Do you wish to continue and dispense outside of the linked process"
                              msg = TxtD(dispdata$ & "\rptdisp.ini", "RepeatCycles", msg, "DispenseRptCheckMsg", 0)
                              askwin "?Repeat Dispensing", msg, strAns, k
                              If strAns = "N" Or k.escd Then
                                 msg = "Repeat Cycle - aborted"
                                 lblStatus(0).Caption = msg
                                 success = False
                              End If
                           End If
                        End If
                        '20Aug13 TH -----
                        
                        If success Then
                           If PrescriptionCrossCheckEpisode(RequestID_Prescription, EpisodeID) Then '29Jan13 TH TFS 54633 '13Feb13 TH Moved from above (TFS 56386)
                           '13Feb13 TH Now try to lock the prescription (TFS)
                           If PharmacyPrescriptionLock(RequestID_Prescription) Then
                           
                              '29Nov13 TH Pat Billing - do we need to clean up before checking ?
                              'Clear Billing here if necessary
                              
                              '29Nov13 TH StV Patient Billing - Is the patient set to Bill ? This is done in onlaodingdispens from UserControlEnable
                              lngBilling = billpatient(27, "")
                              
                              UserControlEnable True
                           
                              '10Feb11 TH Chemocare set up form -  Now always check after discussion with AS 11Feb11 (F0036868)
                              'If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "Interface", "Y", "UsePrescriptionOCXTextDisplay", 0)) Then
                              'Now we need to get any potential text from the DB. Only if there is text do we go into "full display mode"
                              strOCXtext = PrescriptionOCXtext(RequestID_Prescription)
                              
                              'Put on heap
                              Heap 10, gPRNheapID, "rxOCXText", strOCXtext, 0
                              If Trim$(strOCXtext) <> "" Then
                                 picOCXdetails.Visible = True
                                 If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "N", "FontBold", 0)) Then picOCXdetails.FontBold = True
                                 picOCXdetails.BackColor = TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "&H80FFFF", "PrescriptionOCXTextBackColor", 0)
                                 picOCXdetails.ForeColor = TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "&H80000008", "PrescriptionOCXTextForeColor", 0)
                                 picOCXdetails.Tag = "1"
                                 picOCXdetails.Cls
                                 printOCXdetailsWrap strOCXtext, True, False
                                 ImgWarning.Visible = True
                                 'For intloop = 0 To 3  'Mr Simmons idea, but wasnt much cop so removed
                                 '   lblPrompt(intloop).ForeColor = TxtD(dispdata$ & "\patmed.ini", "Interface", "&H000080FF", "PrescriptionOCXTWarnForeColor", 0)
                                 'Next
                              
                              End If
                              'End If
                              
                              If picOCXdetails.Visible = False Then  '15Feb11 TH Retain old way of working if not Chemocare (F0036868)
                                 SetOCXDetailsSize
                                 SetupDispensForm    'ensure OCX data is visible
                                 SetOCXdetails       'display data
                              End If
                              
                              
                              '20Nov11 TH If the real thing is running then dont use the workaround
                              If Not InitialisePCTBilling() Then
                                 '07Nov07 TH PCT Workaround
                                 If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "PharmacWorkaround", 0)) Then
                                    SetUpPCTWorkaround RequestID_Prescription  'TH PCT Workaround entry point
                                 End If
                              Else
                                 'OK we are PCT
                                 If PCTCheckForRepeat() Then
                                    'tell the user, offer to back out,switch PCT off
                                    strAns = "Y"
                                    msg = "This prescription already has an associated PCT Claim record. If you continue no PCT Claim will be generated and this will be treated as a normal issue" & crlf & _
                                    "Do you wish to continue?"
                                    askwin "?EMIS Health", TxtD(dispdata$ & "\patmed.ini", "PCT", msg, "PCTRepeatMsg", 0), strAns, k
                                    If strAns = "N" Or k.escd Then
                                       blnPCTEsc = True
                                    End If
                                    SetPCTDispensing False 'Off regardless
                                 End If
                              End If
                           
                              If blnPCTEsc Then
                                 lblStatus(0).Caption = " PCT Dispensing Aborted "
                                 success = False
                                 'popmessagecr "#", "Prescription not found" & crlf & crlf & "(Prescription ID = " & Format$(RequestID_Prescription) & ")"
                              Else
                              
                                 '15Mar12 TH
                                 If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "Y", "PRNMaximumDoseWarningCheck", 0)) Then
                                    If Val(OCXheap("MaximumDoseOverTimeDose", "")) > 0 Then
                                       StrMaxDoseWarning = "This PRN prescription has a maximum dose specified over time - please ensure the label is correct in terms of any instructions/warnings"
                                       StrMaxDoseWarning = TxtD(dispdata$ & "\patmed.ini", "", StrMaxDoseWarning, "PRNMaximumDoseWarningMsg", 0)
                                       popmessagecr "!", StrMaxDoseWarning
                                    End If
                                 End If
                                 Labf& = RequestID_Dispensing                          'requestid for dispensing which is currently in use
                                 If Labf& Then                                         'load label
                                    getlabel Labf&, L, False
                                    '18Mar07 TH New check on site here (SC-07-0197)
                                    If L.SiteID <> gDispSite Then
                                       success = False
                                       'Produce a suitable msg
                                       msg = "This item was previously dispensed from " & GetSiteDescription(L.SiteID) & crlf & crlf & _
                                       "Cannot redispense this item from current site"
                                       popmessagecr "!", msg
                                       msg = "Previously dispensed from " & GetSiteDescription(L.SiteID) & ". Cannot redispense from current site"
                                       lblStatus(0).Caption = msg
                                    ElseIf L.PSO Then '06Aug12 TH Added check on trying to redispense a PSO (TFS 40715)
                                       success = False
                                       'Produce a suitable msg
                                       msg = "This is a patient specific order line and cannot be dispensed from here"
                                       popmessagecr "!", msg
                                       msg = "Patient specific order. Cannot dispense row"
                                       lblStatus(0).Caption = msg
                                    Else
                                       '09Aug122 TH (TFS 40682)
                                       cmbUC("CmbIssueType").Clear
                                       SetDispenseForm
                                          
                                       '08Sep11 TH Added the following check on inuse for re-dispensing (TFS13555)
                                       d.SisCode = L.SisCode
                                       getdrug d, 0, 0, False
                                       If d.inuse = "N" Then
                                          strAns = "N"
                                          'Produce a suitable msg
                                          'msg = d.SisCode & " - " & Trim$(d.storesdescription) & crlf & crlf & "This item has been set to out of use" & crlf & crlf & _ XN 9Jun15 98073 New local stores description
                                          'msg = d.SisCode & " - " & Trim$(Iff(d.LocalDescription = "", d.storesdescription, d.LocalDescription)) & crlf & crlf & "This item has been set to out of use" & crlf & crlf & _ 12Nov15 TH Added trim to check (TFS 134982)
                                          msg = d.SisCode & " - " & Trim$(Iff(Trim$(d.LocalDescription) = "", d.storesdescription, d.LocalDescription)) & crlf & crlf & "This item has been set to out of use" & crlf & crlf & _
                                          "Do you wish to continue?"
                                          askwin "?EMIS Health", TxtD(dispdata$ & "\patmed.ini", "", msg, "OutofUseDispensingQuestion", 0), strAns, k
                                          If strAns = "N" Or k.escd Then
                                             msg = "Item out of use"
                                             lblStatus(0).Caption = msg
                                             success = False
                                          End If
                                       End If
                                       If success Then
                                       
                                          '30Aug13 TH DoC Consultant Override (TFS 72225)
                                          If TrueFalse(TxtD(dispdata$ & "\RptDisp.ini", "RepeatDispensing", "N", "ConsultantOverride", 0)) Then
                                             If Trim(L.ConsCode) <> "" Then
                                                If IsDispensingRptDispLinked(RequestID_Dispensing) Then
                                                   pid.cons = UCase$(L.ConsCode)
                                                End If
                                             End If
                                          End If
                                          
                                          'If PCT Enabled load any linked item
                                          If IsPCTDispensing() Then LoadPCTPrimaryIngredient d.productstockID '29Nov11 TH Added
                                          
                                          LastDispenseDateCheck RequestID_Prescription '26May09 TH
                                          DisplaytheLabAndForm 1, 0, 0, "", 0
                                          
                                          '06Aug13 TH Added (TFS 70867)
                                          If Left$(CmbIssueType.List(CmbIssueType.ListIndex), 1) = "C" Then
                                             'formtolabel 0  '10Jun05 TH Added  **!!**
                                             CalcIV 1, True '26Aug09 TH Added (F0062137)
                                          End If
                                       End If
                                    End If
                                 Else                                                  'load prescription, blank label
                                    'LastDispenseDateCheck RequestID_Prescription '26May09 TH
                                    If Not (g_blnPSO) Then LastDispenseDateCheck RequestID_Prescription '10Oct12 TH suppress check if PSO (TFS 41435)
                                    BlankWLabel L
                                    Blanklabel
                                    'success = GetProductNLbyProductID(OCXheap("ProductID", "0"), d)
                                    
                                    '07Mar13 TH (TFS 58265)
                                    cmbUC("CmbIssueType").Clear
                                    SetDispenseForm
                                       
                                    If strNSVCode = "" Then
                                        Select Case OCXheap("prescriptiontypedescription", "")
                                           Case "Infusion"
                                              'findrdrug "¦" & OCXheap("ProductID_Ingredient", "0"), False, d, 0, intSuccess, False, False, False            17Oct14 XN  88560 Prevented user from searching for drug via BNF (findrdrug)
                                              findrdrug "¦" & OCXheap("ProductID_Ingredient", "0"), False, d, 0, intSuccess, False, False, False, False
                                           Case Else
                                              'findrdrug "¦" & OCXheap("ProductID", "0"), False, d, 0, intSuccess, False, False, False                       17Oct14 XN  88560 Prevented user from searching for drug via BNF (findrdrug)
                                              findrdrug "¦" & OCXheap("ProductID", "0"), False, d, 0, intSuccess, False, False, False, False
                                        End Select
                                        success = (intSuccess <> 0)
                                    Else
                                        d.SisCode = strNSVCode
                                        getdrug d, 0, lngSuccess, False
                                        success = (lngSuccess <> 0)
                                    End If
                                    
                                    'PSO Supplier checks here !!! 06Aug12 TH
                                    strMsg = " No matching products found "
                                    If success Then
                                       'strMsg = " No patient specific ordering supplier available "
                                       If g_blnPSO Then
                                          'We now need to check other pending orders/receipts to warn the user, they may wish to back out
                                          strMsg = " Cancelled patient specific ordering "
                                          success = CheckPendingPSOOrders(d.SisCode, pid.recno)
                                          If success Then
                                             'They want to continue so offer the suppliers
                                             strMsg = " No patient specific ordering supplier available "
                                             success = SelectPSOSupProfile()
                                          End If
                                       End If
                                    End If
                                          
                                    If success Then
                                       L.SisCode = d.SisCode
                                       
                                       'Product code
                                       TxtDrugCode.text = L.SisCode
                                                                  
                                                                 
                  ''                     TxtDrugCode_KeyDown 13, 0
                                       EnterDrug False
                  ''                     fraLineColour.Refresh
                                       blnSuppDirCodeUsed = False
                                       FillHeapDrugInfo gPRNheapID, d, 0
                                       
                                       'If PCT Enabled load any linked item !!!PCT
                                       If IsPCTDispensing() Then LoadPCTPrimaryIngredient d.productstockID
                                       
                                       '27Oct06 TH Temporary addition for prototyping
                                       L.ReconAbbr = d.ReconAbbr
                                       L.ReconVol = d.ReconVol
                                       L.DiluentAbbr = d.Diluent1Abbr
                                       L.Container = d.IVcontainer
                                       L.finalvolume = d.MaxInfusionRate
                                       '------------------------
                                    
                                 
                                       'Direction code for the dose
                                       Select Case OCXheap("prescriptiontypedescription", "")
                                          Case "Standard" '------------------------------------------------ 'Standard Prescription
                                             DoAction.Caption = "DELETEDIR"
                                             
                                             NumericDose = CSng(OCXheap("Dose", ""))
                                             NumericDoseLow = CSng(OCXheap("DoseLow", ""))
                                             PrescribedUnits = Trim$(OCXheap("UnitAbbreviationDose", ""))
                                             If LCase$(PrescribedUnits) = "qty" Then
                                                PrescribedUnits = Trim$(OCXheap("productformdescription", ""))
                                             End If
                                             
                                             If g_blnSplitDose And (NumericDoseLow = 0) Then
                                                'Here we present the dose to the user and allow them to alter it to a lower figure
                                                g_blnSplitDose = False
                                                If g_blnLinkedPrescription Then blnComplexDoseSplitOK = False  '09Nov11 TH Further mods to handle split dosing of complex types (TFS18827)
                                                For intloop = 0 To g_TotalComplexChildren                      '     "
                                                   blnDone = False
                                                   
                                                   Do
                                                      If intloop > 0 Then
                                                         strAns = Format$(OCXheap("Dose" & intloop, ""))
                                                      Else
                                                         strAns = Format$(NumericDose)
                                                      End If
                                                      '21Jul11 TH Enhance the message
                                                      strSplitMsg = ""
                                                      If g_blnLinkedPrescription Then '09Nov11 TH (TFS18827)
                                                         strSplitMsg = "Prescription : " & crlf & crlf & Space$(5) & Trim$(OCXheap("MergedDescription", "")) & crlf & crlf
                                                      End If
                                                      strSplitMsg = strSplitMsg & Iff(g_blnLinkedPrescription, TxtD(dispdata$ & "\patmed.ini", "SplitDosing", "Dose Slot", "DoseSlotCaption", 0) & " : ", "Prescription : ") & crlf & crlf & Space$(5) & Trim$(OCXheap("Description" & IIf(intloop > 0, Format$(intloop), ""), "")) '09Nov11 TH Enhanced (TFS18827)
                                                      'strDesc = Iff(d.LocalDescription = "", d.storesdescription, d.LocalDescription) ' d.storesdescription XN 9Jun15 98073 New local stores description
                                                      strDesc = Iff(Trim$(d.LocalDescription) = "", d.storesdescription, d.LocalDescription) '03Nov15 TH Added Trim to ensure correct check (TFS 132827)
                                                      plingparse strDesc, "!"
                                                      strSplitMsg = strSplitMsg & crlf & crlf & "To be dispensed using : " & crlf & crlf & Space$(5) & strDesc & crlf & crlf '09Nov11 TH Enhanced (TFS18827)
                                                      strSplitMsg = strSplitMsg & crlf & crlf & "Enter new dose in " & PrescribedUnits & " to dispense" & crlf
                                                      k.nums = True
                                                      k.decimals = True
                                                      InputWin "Enter " & Iff(g_blnLinkedPrescription, TxtD(dispdata$ & "\patmed.ini", "SplitDosing", "Dose Slot", "DoseSlotCaption", 0) & " " & Format(intloop + 1) & " of " & Format$(g_TotalComplexChildren + 1), "Dose"), strSplitMsg, strAns, k '09Nov11 TH Enhanced (TFS18827)
                                                      k.nums = False
                                                      k.decimals = False
                                                      If k.escd Then Exit Do
                                                      If Trim$(strAns) = "" Then
                                                         popmessagecr "", "Please enter a valid dose to dispense"
                                                      ElseIf Val(strAns) < 0 Then
                                                         popmessagecr "", strAns & " is not a valid dose. Please enter a valid dose to dispense"
                                                      ElseIf Val(strAns) = 0 And g_TotalComplexChildren = 0 Then '09Nov11 TH Enhanced (TFS18827) zero is allowed as some dosing slots may not be used when split dosing a complex type
                                                         popmessagecr "", strAns & " is not a valid dose. Please enter a valid dose to dispense"
                                                      ElseIf Val(strAns) > (Iff(intloop > 0, Val(OCXheap("Dose" & intloop, "")), NumericDose)) Then
                                                         'popmessagecr "", "Dose dispensed cannot be greateer than that prescribed"
                                                         popmessagecr "", "Dose dispensed cannot be greater than that prescribed" '07Sep11 TH Ooops (TFS13338)
                                                      Else
                                                         If intloop > 0 Then
                                                            If (Val(OCXheap("Dose" & intloop, "")) <> Val(strAns)) Then g_blnSplitDose = True '03Aug11 TH If the dose is lowered then class as split dose
                                                            Heap 10, g_OCXheapID, "dose" & Format$(intloop), strAns, 0
                                                         Else
                                                            If (NumericDose <> Val(strAns)) Then g_blnSplitDose = True '03Aug11 TH If the dose is lowered then class as split dose
                                                            NumericDose = Val(strAns)
                                                         End If
                                                         If Val(strAns) > 0 Then blnComplexDoseSplitOK = True '09Nov11 TH Enhanced (TFS18827) Flag to stop all slots set to zero for complex type
                                                         blnDone = True
                                                      End If
                                                   Loop Until blnDone Or k.escd
                                                   If k.escd Then Exit For
                                                Next
                                                If k.escd Then
                                                   success = False
                                                   lblStatus(0).Caption = " No Suitable dose selected "
                                                End If
                                                
                                                If g_blnLinkedPrescription And Not blnComplexDoseSplitOK Then  '09Nov11 TH (TFS18827) Stop all slots set to zero for complex type
                                                   success = False                                             '     "
                                                   lblStatus(0).Caption = " No Suitable dose selected "        '     "
                                                End If                                                         '     "
                                          
                                             Else
                                                g_blnSplitDose = False
                                             End If
                                                   
                                             If NumericDose > 0 Then  '08Nov11 TH Added
                                                If ScalePrescribedUnits(d, PrescribedUnits, NumericDose, NumericDoseLow, 0, Scaling) Then
                                                   If NumericDose Then
                                                      If NumericDoseLow > 0 Then
                                                         TxtDircode = Format$(NumericDoseLow) & "-" & Format$(NumericDose)
                                                      Else
                                                         '01Jun09 TH Added Clause to round dose on label (F0021850)
                                                         If Trim$(UCase$(OCXheap("ProductRouteDescription", ""))) = "ORAL" And (Trim$(UCase$(d.PrintformV)) = "ML" Or (Trim$(UCase$(d.PrintformV)) = "BTL" And Trim$(UCase$(d.DosingUnits)) = "MG" Or Trim$(UCase$(d.DosingUnits)) = "ML")) And TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "Y", "LabelTextDoseRounding", 0)) Then
                                                            If NumericDose >= 1 Then
                                                               'TxtDircode = Format$(NumericDose, "0.#")
                                                               'TxtDircode = Format$(NumericDose, TxtD(dispdata$ & "\PATMED.INI", "", "0.#", "LabelTextDoseRoundingFormatAboveOne", 0)) '08Apr15 TH Replaced Above (TFS 82713)
                                                               TxtDircode = Format$(NumericDose, TxtD(dispdata$ & "\PATMED.INI", "", "0.##", "LabelTextDoseRoundingFormatAboveOne", 0)) '13Apr15 TH Changed default as per Andrews Instructions (TFS 82713)
                                                            Else
                                                               'TxtDircode = Format$(NumericDose, "0.##")
                                                               TxtDircode = Format$(NumericDose, TxtD(dispdata$ & "\PATMED.INI", "", "0.##", "LabelTextDoseRoundingFormatBelowOne", 0)) '08Apr15 TH Replaced Above (TFS 82713)
                                                            End If
                                                            If Right$(TxtDircode, 1) = "." Then TxtDircode = Left$(TxtDircode, Len(TxtDircode) - 1)
                                                         Else
                                                            TxtDircode = Format$(NumericDose)
                                                         End If
                                                      End If
                     
                                                      TxtDircode = TxtDircode & "/"
                                                   End If
                                                Else
                                                   popmessagecr ".Caution", "Standard Prescription:" & crlf & _
                                                      Scaling & crlf & crlf & _
                                                      "Prescribed units: " & PrescribedUnits & crlf & crlf & _
                                                      "Product Issue units: " & Trim$(d.PrintformV) & crlf & _
                                                      "Product Dosing units: " & Trim$(d.DosingUnits) & crlf & crlf & _
                                                      "Amend the prescription or product before dispensing."
                                                      '**!!** ADD enough info to know which product is in use - ID, description, convfact & dosesperissueunit
                                                   success = False
                                                   lblStatus(0).Caption = " Suitable product not selected "
                                                End If
                                             End If
                                          Case "Doseless" '------------------------------------------------ 'Doseless prescription
                                             g_blnSplitDose = False '11Nov11 TH (now need to turn this off so that we dont lose the freq code on doseless if the user tries to split dose this.
                                                'prescriptiontypedescription='Doseless'
                                                'productroutedescription='Top.'
                                                'supplementarytext='Apply'
                                                'Dose=0
                                                
         ''13Jan06 CKJ replaced with block below
         ''                                       If OCXheap("productroutedescription", "") = "Top." Then        'Topical doseless
         ''                                          DoAction.Caption = "DELETEDIR"
         ''
         ''                                          tmpDirCode = OCXheap("SupplementaryDirection", "")
         ''                                          If Len(tmpDirCode) Then
         ''                                             blnSuppDirCodeUsed = True
         ''                                          Else
         ''                                             tmpDirCode = "AP"                                        '**!!** TEMPORARY !!
         ''                                          End If
         ''
         ''                                          TxtDircode = TxtDircode & tmpDirCode
         ''                                          TxtDircode = TxtDircode & "/"
         ''                                       Else
         ''                                          popmessagecr ".WARNING", "Unknown type of doseless prescription. Route is " & OCXheap("productroutedescription", "")       '**!!**
         ''                                          success = False
         ''                                          lblStatus(0).Caption = " Doseless prescription with unknown route "
         ''                                       End If
                                                
                                             '13Jan06 CKJ removed hard coded "AP" - apply, now uses both directions, regardless of route
                                             tmpDirCode = Trim$(OCXheap("SupplementaryDirection", ""))
                                             'If Len(tmpDirCode) > 0 And Len(Trim$(OCXheap("DirCode", ""))) > 0 Then
                                             'If Len(tmpDirCode) > 0 And (Len(Trim$(OCXheap("DirCode", ""))) > 0 Or UCase$(Trim$(OCXheap("PRN", ""))) = "TRUE")  Then '24Jan06 Allow PRN through too
                                             If Len(tmpDirCode) > 0 And (Len(Trim$(OCXheap("DirCode", ""))) > 0 Or UCase$(Trim$(OCXheap("PRN", ""))) = "TRUE" Or ((UCase$(Trim$(OCXheap("PRN", ""))) = "FALSE") And Val(OCXheap("SCHEDULEID_ADMINISTRATION", "0")) = 0)) Then '24Jul06 TH Allow STAT through too
                                                DoAction.Caption = "DELETEDIR"
                                                blnSuppDirCodeUsed = True
                                                
                                                TxtDircode = TxtDircode & tmpDirCode
                                                TxtDircode = TxtDircode & "/"
                                             Else
                                                '05Aug15 TH Custom frequencies are allowed through (TFS 125159)
                                                If (Len(Trim$(OCXheap("DirCode", ""))) > 0) And (Val(OCXheap("SCHEDULEID_ADMINISTRATION", "0"))) = 0 Then
                                                   popmessagecr ".WARNING", "Incomplete doseless prescription - please check alias configuration." & cr & "Frequency: '" & tmpDirCode & "'    Direction: '" & OCXheap("DirCode", "") & "'"
                                                   success = False
                                                   lblStatus(0).Caption = " Doseless prescription - Incomplete"
                                                End If
                                             End If
      
      
                                          Case "Infusion" '------------------------------------------------ 'Infusion or injection prescription
                                             'g_blnSplitDose = False '11Nov11 TH
                                             DoAction.Caption = "DELETEDIR"
                                             If OCXheap("InfusionContinuous", "") = "True" Then
                                                g_blnSplitDose = False '11Nov11 TH
                                                'popmessagecr ".", "Prescription type not yet supported: Continuous infusion"
                                                'success = false
                                                NumericDose = CSng(OCXheap("InfusionRate", ""))
                                                NumericDoseLow = CSng(OCXheap("InfusionRateMin", ""))
                                                NumericDoseHigh = CSng(OCXheap("InfusionRateMax", ""))
                                                PrescribedUnits = Trim$(OCXheap("UnitAbbreviation_InfusionContinuousRateMass", ""))    'UNITID_RATEMASS
                                                TimeUnit = Trim$(OCXheap("UnitAbbreviation_InfusionContinuousRateTime", ""))           'UNITID_RATETIME
                                                strText = Format$(NumericDose) & " " & PrescribedUnits & "/" & TimeUnit
                                                If NumericDoseLow > 0 And NumericDoseHigh > 0 Then
                                                   strText = "Start at " & strText & " (range " & Format$(NumericDoseLow) & " to " & Format$(NumericDoseHigh)
                                                   strText = strText & " " & PrescribedUnits & "/" & TimeUnit & ")"
                                                Else
                                                   strText = "Infuse at " & strText
                                                End If
                                                TxtDircode = "TEXT:" & DirectionTextEscape(strText)
                                                TxtDircode = TxtDircode & "/"
                                             
                                             Else                                                           'Intermittent Infusion / bolus injection
                                                NumericDose = CSng(OCXheap("Quantity_Ingredient", ""))
                                                NumericDoseLow = CSng(OCXheap("QuantityMin_Ingredient", ""))
                                                NumericDoseHigh = CSng(OCXheap("QuantityMax_Ingredient", ""))
                                                PrescribedUnits = Trim$(OCXheap("UnitAbbreviationDose_Ingredient", ""))
                                                      
                                                '04Aug14 TH (TFS 96938)
                                                'If we are using a dose range then we need to use the high point as the "dose" we will
                                                'use to dispense from
                                                If NumericDose = 0 And NumericDoseHigh > 0 Then
                                                   NumericDose = NumericDoseHigh
                                                End If
                                                      
                                                '15Oct13 TH further split dose checks (TFS 75250)
                                                If g_blnSplitDose Then
                                                   If NumericDoseLow <> 0 Then g_blnSplitDose = False
                                                   If NumericDoseHigh <> 0 Then g_blnSplitDose = False
                                                   If g_blnSplitDose Then
                                                      'If InStr("," & Trim$(UCase$(OCXheap("ProductRouteDescription", ""))) & ",", UCase$(TxtD(dispdata$ & "\patmed.ini", "", ",IV,", "AllowedRoutesForSplitDoseInfusion", 0))) = 0 Then
                                                      If InStr(UCase$(TxtD(dispdata$ & "\patmed.ini", "", ",IV,INF.,", "AllowedRoutesForSplitDoseInfusion", 0)), "," & Trim$(UCase$(OCXheap("ProductRouteDescription", ""))) & ",") = 0 Then '07Jan14 TH Wrong order ! (TFS 75250) '10Jan14 TH Added INF.
                                                         g_blnSplitDose = False
                                                      End If
                                                   
                                                   End If
                                                End If
                                                
                                                '15Oct13 TH Now allow split dose in some circumstances (TFS 75250)
                                                If g_blnSplitDose Then
                                                   'Here we present the dose to the user and allow them to alter it to a lower figure
                                                   g_blnSplitDose = False
                                                   If g_blnLinkedPrescription Then blnComplexDoseSplitOK = False  '09Nov11 TH Further mods to handle split dosing of complex types (TFS18827)
                                                   For intloop = 0 To g_TotalComplexChildren                      '     "
                                                      blnDone = False
                                                      
                                                      Do
                                                         If intloop > 0 Then
                                                            strAns = Format$(OCXheap("Dose" & intloop, ""))
                                                         Else
                                                            strAns = Format$(NumericDose)
                                                         End If
                                                         '21Jul11 TH Enhance the message
                                                         strSplitMsg = ""
                                                         If g_blnLinkedPrescription Then '09Nov11 TH (TFS18827)
                                                            strSplitMsg = "Prescription : " & crlf & crlf & Space$(5) & Trim$(OCXheap("MergedDescription", "")) & crlf & crlf
                                                         End If
                                                         strSplitMsg = strSplitMsg & Iff(g_blnLinkedPrescription, TxtD(dispdata$ & "\patmed.ini", "SplitDosing", "Dose Slot", "DoseSlotCaption", 0) & " : ", "Prescription : ") & crlf & crlf & Space$(5) & Trim$(OCXheap("Description" & IIf(intloop > 0, Format$(intloop), ""), "")) '09Nov11 TH Enhanced (TFS18827)
                                                         'strDesc = Iff(d.LocalDescription = "", d.storesdescription, d.LocalDescription) ' d.storesdescription XN 9Jun15 98073 New local stores description
                                                         strDesc = Iff(Trim$(d.LocalDescription) = "", d.storesdescription, d.LocalDescription)   '12Nov15 TH Check on trimmed description (TFS 134982)
                                                         plingparse strDesc, "!"
                                                         strSplitMsg = strSplitMsg & crlf & crlf & "To be dispensed using : " & crlf & crlf & Space$(5) & strDesc & crlf & crlf '09Nov11 TH Enhanced (TFS18827)
                                                         strSplitMsg = strSplitMsg & crlf & crlf & "Enter new dose in " & PrescribedUnits & " to dispense" & crlf
                                                         k.nums = True
                                                         k.decimals = True
                                                         InputWin "Enter " & Iff(g_blnLinkedPrescription, TxtD(dispdata$ & "\patmed.ini", "SplitDosing", "Dose Slot", "DoseSlotCaption", 0) & " " & Format(intloop + 1) & " of " & Format$(g_TotalComplexChildren + 1), "Dose"), strSplitMsg, strAns, k '09Nov11 TH Enhanced (TFS18827)
                                                         k.nums = False
                                                         k.decimals = False
                                                         If k.escd Then Exit Do
                                                         If Trim$(strAns) = "" Then
                                                            popmessagecr "", "Please enter a valid dose to dispense"
                                                         ElseIf Val(strAns) < 0 Then
                                                            popmessagecr "", strAns & " is not a valid dose. Please enter a valid dose to dispense"
                                                         ElseIf Val(strAns) = 0 And g_TotalComplexChildren = 0 Then '09Nov11 TH Enhanced (TFS18827) zero is allowed as some dosing slots may not be used when split dosing a complex type
                                                            popmessagecr "", strAns & " is not a valid dose. Please enter a valid dose to dispense"
                                                         ElseIf Val(strAns) > (Iff(intloop > 0, Val(OCXheap("Dose" & intloop, "")), NumericDose)) Then
                                                            'popmessagecr "", "Dose dispensed cannot be greateer than that prescribed"
                                                            popmessagecr "", "Dose dispensed cannot be greater than that prescribed" '07Sep11 TH Ooops (TFS13338)
                                                         Else
                                                            If intloop > 0 Then
                                                               If (Val(OCXheap("Dose" & intloop, "")) <> Val(strAns)) Then g_blnSplitDose = True '03Aug11 TH If the dose is lowered then class as split dose
                                                               Heap 10, g_OCXheapID, "dose" & Format$(intloop), strAns, 0
                                                            Else
                                                               If (NumericDose <> Val(strAns)) Then g_blnSplitDose = True '03Aug11 TH If the dose is lowered then class as split dose
                                                               NumericDose = Val(strAns)
                                                            End If
                                                            If Val(strAns) > 0 Then blnComplexDoseSplitOK = True '09Nov11 TH Enhanced (TFS18827) Flag to stop all slots set to zero for complex type
                                                            blnDone = True
                                                         End If
                                                      Loop Until blnDone Or k.escd
                                                      If k.escd Then Exit For
                                                   Next
                                                   If k.escd Then
                                                      success = False
                                                      lblStatus(0).Caption = " No Suitable dose selected "
                                                   End If
                                                   
                                                   If g_blnLinkedPrescription And Not blnComplexDoseSplitOK Then  '09Nov11 TH (TFS18827) Stop all slots set to zero for complex type
                                                      success = False                                             '     "
                                                      lblStatus(0).Caption = " No Suitable dose selected "        '     "
                                                   End If                                                         '
                                                End If
                                                
                                                If ScalePrescribedUnits(d, PrescribedUnits, NumericDose, NumericDoseLow, NumericDoseHigh, Scaling) Then
                                                   If NumericDose Then                                         'units determined by d.LabelInIssueUnits
                                                      Heap 10, g_OCXheapID, "Quantity_Ingredient_Scaled", Format$(NumericDose), 0
                                                      Heap 10, g_OCXheapID, "QuantityMin_Ingredient_Scaled", Format$(NumericDoseLow), 0
                                                      Heap 10, g_OCXheapID, "QuantityMax_Ingredient_Scaled", Format$(NumericDoseHigh), 0
                                                      If NumericDoseLow > 0 And NumericDoseHigh > 0 Then '07Aug14 TH Added section to handle dose range (TFS 96938)
                                                         TxtDircode = Format$(NumericDoseLow) & "-" & Format$(NumericDoseHigh)
                                                         TxtDircode = TxtDircode & "/"
                                                      Else
                                                         TxtDircode = Format$(NumericDose)
                                                         TxtDircode = TxtDircode & "/"
                                                      End If
                                                   End If
                                                   
                                                   'Infusion duration and infusion duration range. ... over 12 hours ... over 4 to 6 hours ... etc
                                                   'Stored in dircode as /Over[<n>-]<n><S|M|H|D|W|?>/
                                                   'where ? implies an unknown or invalid time unit
                                                   InfusionDuration = CSng(OCXheap("InfusionDuration", ""))
                                                   InfusionDurationLow = CSng(OCXheap("InfusionDurationLow", ""))
                                                   If InfusionDuration Then
                                                      tmpDirCode = Format$(InfusionDuration)
                                                      If InfusionDurationLow Then
                                                         tmpDirCode = Format$(InfusionDurationLow) & "-" & tmpDirCode
                                                      End If
                                                      '19Sep13 TH Made case insensitive (TFS 73783)
                                                      Select Case LCase$(OCXheap("UnitAbbreviation_InfusionDuration", ""))
                                                         Case "sec": TimeUnit = "S"
                                                         Case "min": TimeUnit = "M"
                                                         'Case "Hrs": TimeUnit = "H"   '13Jun13 TH Replaced with below as abbrev had been changed (TFS 66438)
                                                         Case "hrs", "hour", "hours": TimeUnit = "H"
                                                         Case "day": TimeUnit = "D"
                                                         Case "wk", "week", "weeks": TimeUnit = "W"
                                                         Case Else:  TimeUnit = "?"
                                                      End Select
                                                      TxtDircode = TxtDircode & "Over" & tmpDirCode & TimeUnit
                                                      TxtDircode = TxtDircode & "/"
                                                   End If
                                                Else
                                                   popmessagecr ".Caution", "Infusion/Injection Prescribed:" & crlf & _
                                                   Scaling & crlf & _
                                                   "Prescribed units: " & PrescribedUnits & crlf & _
                                                   "Product Issue units: " & Trim$(d.PrintformV) & crlf & _
                                                   "Product Dosing units: " & Trim$(d.DosingUnits) & crlf & crlf & _
                                                   "Amend the prescription or product before dispensing."
                                                   success = False
                                                   lblStatus(0).Caption = " Suitable product not selected "
                                                End If
                                             End If
                                         
                                          Case "NonMedicinal"
                                             g_blnSplitDose = False '11Nov11 TH
                                             DoAction.Caption = "DELETEDIR"
                                             
                                             NumericDose = CSng(OCXheap("Quantity", ""))
                                             NumericDoseLow = 0
                                             PrescribedUnits = d.PrintformV    ' Trim$(OCXheap("UnitAbbreviationDose", ""))
                                             NumericDose = NumericDose * Val(d.convfact)       'n x items per pack
         
                                             TxtDircode = Format$(NumericDose)
                                             TxtDircode = TxtDircode & "/"
                                             
                                             tmpDirCode = OCXheap("PrintableDirection", "")  'Sentence suitable for printing on label
                                             If Len(tmpDirCode) Then                         'replace 'mdu' with this
                                                TxtDircode = "NoQty"                         'like 'mdu' but without the words - sets PRN & ManualQty
                                                TxtDircode = TxtDircode & "/"
                                                Heap 10, g_OCXheapID, "DirCode", DirectionTextEscape("TEXT:" & tmpDirCode), 0    'add free text wording
                                             End If
                                                                                    
                                          Case Else
                                             g_blnSplitDose = False '11Nov11 TH
                                             popmessagecr ".", "Prescription type not supported: " & OCXheap("prescriptiontypedescription", "")
                                             success = False
                                             lblStatus(0).Caption = " Prescription type invalid"
                                                
                                       End Select
                                       
                                       'Purely debug information...
                                       sep = cr & TB & TB
                                       Scaling = Scaling & sep & _
                                       "Prescribed units: " & PrescribedUnits & sep & _
                                       "Product Issue units: " & LCase$(Trim$(d.PrintformV)) & sep & _
                                       "Product Dosing units: " & LCase$(Trim$(d.DosingUnits)) & cr & sep & _
                                       "DoseLow: " & OCXheap("DoseLow", "") & sep & _
                                       "Dose: " & OCXheap("Dose", "") & sep & _
                                       "DosesPerIssueUnit: " & Format$(d.dosesperissueunit) & sep & _
                                       "txtDirCode: " & TxtDircode.text & sep & _
                                       "LabelInIssueUnits: " & YesNo(d.LabelInIssueUnits) & sep & _
                                       "CanUseSpoon: " & YesNo(d.CanUseSpoon)
                                       Heap 10, g_OCXheapID, "Scale_Debug", Scaling, 0
                                             
                                       If success Then
                                             
                                          '20Nov11 TH Hook the dose into PCT for use in PCT calculations for claim
                                          setPCTDose NumericDose, 1, False
                                             
                                       
                                          'Start date - 01Feb06 TH Added block as it is needed in calculating course length to get proper qty required
                                          strStartDate = Trim$(OCXheap("StartDate", ""))           '' or 'dd/mm/ccyy' or 'dd/mm/ccyy hh:nn'
                                          If Len(strStartDate) Then
                                             strStartTime = Mid$(strStartDate, 12, 5)              '' or 'hh:nn'
                                             If Len(strStartTime) = 0 Then strStartTime = "00:00"
                                             strStartDate = Left$(OCXheap("StartDate", ""), 10)    'dd/mm/ccyy'
                                          Else
                                             strStartDate = thedate(True, True)                    'date now as 'dd/mm/ccyy'
                                             strStartTime = Left$(thedate(True, -2), 5)            'corresponding time as hh:mm
                                          End If
                                          TxtStartDate.text = strStartDate
                                          TxtStartTime.text = strStartTime
                                          '----------------------------
                                    
                                          'Frequency code
                                          tmpDirCode = OCXheap("DirCode", "")
                                          If Not (NumericDose = 0 And g_blnSplitDose) Then
                                             If Len(tmpDirCode) Then
                                                TxtDircode = TxtDircode & tmpDirCode
                                                TxtDircode = TxtDircode & "/"
                                             End If
                                                
                                             '06Sep11 TH Moved below to accomodate the duration code as part of assymetric (TFS 13203)
                                             '12Jul11 TH Here we need to add the extra stuff for complex types
                                             'If g_blnLinkedPrescription Then
                                             '
                                             '   For intloop = 1 To g_TotalComplexChildren
                                             '      strDirectionLinkCode = TxtD(dispdata$ & "\patmed.ini", "", "", "DirectionLinkCode", 0)
                                             '      If Trim$(strDirectionLinkCode) <> "" Then
                                             '         tmpDirCode = "TEXT:" & strDirectionLinkCode
                                             '         TxtDircode = TxtDircode & tmpDirCode
                                             '         TxtDircode = TxtDircode & "/"
                                             '      End If
                                             '      'tmpDirCode = OCXheap("dose" & intloop, "")
                                             '      'TxtDircode = TxtDircode & tmpDirCode
                                             '      'TxtDircode = TxtDircode & "/"
                                             '      NumericDose = CSng(OCXheap("Dose" & intloop, ""))
                                             '      NumericDoseLow = CSng(OCXheap("DoseLow" & intloop, ""))
                                             '      PrescribedUnits = Trim$(OCXheap("UnitAbbreviationDose" & intloop, ""))
                                             '      If LCase$(PrescribedUnits) = "qty" Then
                                             '         PrescribedUnits = Trim$(OCXheap("productformdescription" & intloop, ""))
                                             '      End If
               
                                             '      If ScalePrescribedUnits(d, PrescribedUnits, NumericDose, NumericDoseLow, 0, Scaling) Then
                                             '         If NumericDose Then
                                             '            If NumericDoseLow > 0 Then
                                             '               tmpDirCode = Format$(NumericDoseLow) & "-" & Format$(NumericDose)
                                             '            Else
                                             '               '01Jun09 TH Added Clause to round dose on label (F0021850)
                                             '               If Trim$(UCase$(OCXheap("ProductRouteDescription", ""))) = "ORAL" And (Trim$(UCase$(d.PrintformV)) = "ML" Or (Trim$(UCase$(d.PrintformV)) = "BTL" And Trim$(UCase$(d.DosingUnits)) = "MG" Or Trim$(UCase$(d.DosingUnits)) = "ML")) And TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "Y", "LabelTextDoseRounding", 0)) Then
                                             '                  If NumericDose >= 1 Then
                                             '                     tmpDirCode = Format$(NumericDose, "0.#")
                                             '                  Else
                                             '                     tmpDirCode = Format$(NumericDose, "0.##")
                                             '                  End If
                                             '                  If Right$(TxtDircode, 1) = "." Then tmpDirCode = Left$(TxtDircode, Len(TxtDircode) - 1)
                                             '               Else
                                             '                  tmpDirCode = Format$(NumericDose)
                                             '               End If
                                             '            End If
                        
                                             '            TxtDircode = TxtDircode & tmpDirCode
                                             '            TxtDircode = TxtDircode & "/"
                                             '         End If
                                             '      Else
                                             '      'Error Handling
                                             '      End If
                                             '
                                             '      tmpDirCode = OCXheap("DirCode" & intloop, "")
                                             '      TxtDircode = TxtDircode & tmpDirCode
                                             '      TxtDircode = TxtDircode & "/"
                                             '   Next
                                             'End If
                                              
                                             '------
                        
                                             'PRN flag
                                             If OCXheap("PRN", "") = "True" Then
                                                TxtDircode = TxtDircode & "PRN"
                                                TxtDircode = TxtDircode & "/"
                                                If PCTDrugToDispens() Then setPCTPRNflag True '05Jan12 TH Added
                                             'ElseIf OCXheap("ScheduleID_Administration", "") = "0" And OCXheap("NoDoseInfo", "") <> "True" Then      'STAT dose     '02Nov06 AE  Added check for NoDoseInfo flag; (for "as directed" doses).  Don't add STAT direction for these. #SC-06-0928
                                             ElseIf OCXheap("ScheduleID_Administration", "") = "0" And OCXheap("NoDoseInfo", "") <> "True" And OCXheap("InfusionContinuous", "") <> "True" Then    '01Jul13 TH Stop designation a continuous infusion as a stat dose. (TFS 56672)
                                                TxtDircode = TxtDircode & "STAT"
                                                TxtDircode = TxtDircode & "/"
                                                If PCTDrugToDispens() Then setPCTStatflag True '05Jan12 TH Added
                                             End If
                                                   
                                             'Duration
                                             '05Aug15 TH Custom frequencies are dealt with via text from upstairs only (TFS 125159)
                                             If Not ((Len(Trim$(OCXheap("DirCode", ""))) = 0) And (Val(OCXheap("SCHEDULEID_ADMINISTRATION", "0"))) > 0) Then
                                                '28Sep15 TH Refactor call here
                                                ProcessLabelDuration blnDurationLastCode

                                             ElseIf g_blnLinkedPrescription Then
                                                '10Sep15 TH Somewhat absurdly we have to do custom ones quite differently n terms of timing (TFS 128203)
                                                '21Jul15 TH Here we identify if we have a custom frequency prescription
                                                If (Len(OCXheap("Dircode", "")) = 0) And (Val(OCXheap("ScheduleID_Administration", "0")) > 0) Then
                                                   strFrequency = Trim$(OCXheap("Description_Frequency", ""))
                                                   If Len(strDirections) > 1 Then
                                                      strFrequency = LCase$(Left$(strFrequency, 1)) & Right$(strFrequency, Len(strFrequency) - 1)
                                                   ElseIf Len(strFrequency) = 1 Then
                                                      strFrequency = LCase$(Left$(strFrequency, 1))
                                                   End If
                                                   '05Aug15 TH Skip if doseless for doseless rxs the direction is sent via supplemental text (TFS 125159)
                                                   If OCXheap("prescriptiontypedescription", "") <> "Doseless" Then
                                                      strDirections = Trim$(OCXheap("Description_Direction", ""))
                                                      If Len(strDirections) > 1 Then
                                                         strDirections = LCase$(Left$(strDirections, 1)) & Right$(strDirections, Len(strDirections) - 1)
                                                      ElseIf Len(strDirections) = 1 Then
                                                         strDirections = LCase$(Left$(strDirections, 1))
                                                      End If
                                                   End If
                                                   
                                                   '10Sep15 TH Add in route if  eyelabel style (TFS 128201)
                                                   If d.EyeLabel Then  'Further trapping may be required here
                                                      GetRouteExpansion Iff((Trim$(CmbRoute.text) = ""), OCXheap("ProductRouteDescription", ""), CmbRoute.text), "", routeword$
                                                      If Trim$(TxtDirections.text) <> "" Then
                                                         If InStr(TxtDirections.text, routeword$) = 0 Then 'For PRN or multi direction we could call re-entrantly  TFS 55794,56067
                                                            TxtDirections.text = TxtDirections.text & routeword$ & crlf
                                                         End If
                                                      End If
                                                   End If
                                                   
                                                   TxtDirections.text = TxtDirections.text & strFrequency & " " & strDirections
                                             
                                                   '28Sep15 TH Refactor call here
                                                   ProcessLabelDuration blnDurationLastCode

                                                End If
                                             End If
                                                
                                          End If
                                          '06Sep11 TH Moved from above to accomodate multiple durations
                                          If g_blnLinkedPrescription Then
                                          
                                             For intloop = 1 To g_TotalComplexChildren
                                                '18Sep15 TH Extended and shifted to own sub for refactoring purposes
                                                'AppendChildPrescriptionforLinkedRx intloop, success
                                                AppendChildPrescriptionforLinkedRx intloop, success, blnDurationLastCode '18Jan16 TH Replaced above
                                             Next
                                          End If
                                          
                                          '------
                                          
                                          'Route
                                          On Error Resume Next
                                          CmbRoute.text = OCXheap("ProductRouteDescription", "")
                                          WDir.route = CmbRoute.text
                                          L.route = CmbRoute.text
                                                   
                                          msg = ""
                                          If Err.Number = 383 Then      'route text not recognised
                                             msg = "Please enter the route" & cr & "Code not found for: " & OCXheap("ProductRouteDescription", "<blank>")
                                          End If
                                          On Error GoTo 0
                                          If Len(msg) Then popmessagecr "!", msg
                                          
                                          'Supplementary direction code
                                          If Not blnSuppDirCodeUsed And Len(OCXheap("SupplementaryDirection", "")) > 0 Then
                                             TxtDircode = TxtDircode & OCXheap("SupplementaryDirection", "")
                                             TxtDircode = TxtDircode & "/"
                                          End If
                                                
                                          '21Jul15 TH Here we identify if we have a custom frequency prescription
                                          'If (Len(OCXheap("Dircode", "")) = 0) And (Val(OCXheap("ScheduleID_Administration", "0")) > 0) Then
                                          If (Len(OCXheap("Dircode", "")) = 0) And (Val(OCXheap("ScheduleID_Administration", "0")) > 0) And Not (g_blnLinkedPrescription) Then '10Sep15 TH Now exclude Complex too (TFS 128203)
                                             strFrequency = Trim$(OCXheap("Description_Frequency", ""))
                                             If Len(strDirections) > 1 Then
                                                strFrequency = LCase$(Left$(strFrequency, 1)) & Right$(strFrequency, Len(strFrequency) - 1)
                                             ElseIf Len(strFrequency) = 1 Then
                                                strFrequency = LCase$(Left$(strFrequency, 1))
                                             End If
                                             '05Aug15 TH Skip if doseless for doseless rxs the direction is sent via supplemental text (TFS 125159)
                                             If OCXheap("prescriptiontypedescription", "") <> "Doseless" Then
                                                strDirections = Trim$(OCXheap("Description_Direction", ""))
                                                If Len(strDirections) > 1 Then
                                                   strDirections = LCase$(Left$(strDirections, 1)) & Right$(strDirections, Len(strDirections) - 1)
                                                ElseIf Len(strDirections) = 1 Then
                                                   strDirections = LCase$(Left$(strDirections, 1))
                                                End If
                                             End If
                                             'strCourse = Trim$(OCXheap("Description_Direction", ""))
                                             '09Aug15 TH Removed course length
                                             'strCourse = Trim$(OCXheap("Description_Duration", ""))  '05Aug15 TH replaced (TFS )
                                             'If Len(strCourse) > 1 Then
                                             '   strCourse = LCase$(Left$(strCourse, 1)) & Right$(strCourse, Len(strCourse) - 1)
                                             'ElseIf Len(strCourse) = 1 Then
                                             '   strCourse = LCase$(Left$(strCourse, 1))
                                             'End If
                                             'If (Right$(strCourse, 1) = ",") Then strCourse = Left$(strCourse, Len(strCourse) - 1)
                                             'TxtDirections.text = TxtDirections.text & strFrequency & " " & strDirections & " " & strCourse
                                             
                                             '10Sep15 TH Add in route if  eyelabel style (TFS 128201)
                                             If d.EyeLabel Then  'Further trapping may be required here
                                                GetRouteExpansion Iff((Trim$(CmbRoute.text) = ""), OCXheap("ProductRouteDescription", ""), CmbRoute.text), "", routeword$    '26Jan98 ASC
                                                If Trim$(TxtDirections.text) <> "" Then
                                                   If InStr(TxtDirections.text, routeword$) = 0 Then 'For PRN or multi direction we could call re-entrantly  TFS 55794,56067
                                                      TxtDirections.text = TxtDirections.text & routeword$ & crlf
                                                   End If
                                                End If
                                             End If
                                             TxtDirections.text = TxtDirections.text & strFrequency & " " & strDirections
                                             
                                             '28Sep15 TH Refactor call here
                                             ProcessLabelDuration blnDurationLastCode

                                          End If

                                          '28Feb11 AJK F0067942 START
                                          '22Mar11 CKJ simplified as it is only handled here (not Case Doseless as well) & added CRLF (F0111869)
                                          If Len(OCXheap("SupplementaryText", "")) Then
                                             If Len(TxtDirections.text) > 2 Then  '25Mar11 CKJ Prevent sporadic extra crlf  (F0111869)
                                                If Right$(TxtDirections.text, 2) <> crlf Then TxtDirections.text = TxtDirections.text & crlf
                                             End If
                                             TxtDirections.text = TxtDirections.text & Trim$(OCXheap("SupplementaryText", ""))
                                          End If
                                          '28Feb11 AJK F0067942 END
            
                                          'Start date
                                          strStartDate = Trim$(OCXheap("StartDate", ""))           '' or 'dd/mm/ccyy' or 'dd/mm/ccyy hh:nn'
                                          If Len(strStartDate) Then
                                             strStartTime = Mid$(strStartDate, 12, 5)              '' or 'hh:nn'
                                             If Len(strStartTime) = 0 Then strStartTime = "00:00"
                                             strStartDate = Left$(OCXheap("StartDate", ""), 10)    'dd/mm/ccyy'
                                          Else
                                             strStartDate = thedate(True, True)                    'date now as 'dd/mm/ccyy'
                                             strStartTime = Left$(thedate(True, -2), 5)            'corresponding time as hh:mm
                                          End If
                                          TxtStartDate.text = strStartDate
                                          TxtStartTime.text = strStartTime
                                                      
               
                                          If Left$(CmbIssueType.List(CmbIssueType.ListIndex), 1) = "C" Then
                                             formtolabel 0  '10Jun05 TH Added  **!!**
                                             CalcIV 1, True '26Aug09 TH Added (F0062137)
                                          End If
                                          
                                          ToggleRxLabel True
                                                
                                          '03Sep08 TH Here we will now do some dose range checking, but only if we feel like it (F0027850)
                                          If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "EnableDispensingDoseRangeChecking", 0)) Then
                                             If Val(TxtDose(1).text) <> 0 Then                '24Dec98 SF replaced above IF
                                                ReDim doses!(6)
                                                For intDose = 1 To 6
                                                   doses!(intDose) = Val(TxtDose(intDose).text)
                                                Next
                                                CheckDose doses!(), strAbort '26Jun98 ASC moved to make BNF work
                                                If strAbort = "Y" Then    '26Jun98 ASC
                                                   success = False
                                                   lblStatus(0).Caption = " Aborted after dose range checking "
                                                End If
                                             End If
                                          End If
                                          '---------------------
                                          
                                          '03Sep08 TH Here we can ask if the item is PCT or not (F0030915)
                                          If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "PCTWorkAround", 0)) Then
                                             If d.cyto = "Y" Then
                                                'See if we already have a PCTRepeat record for this Rx
                                                strParam = gTransport.CreateInputParameterXML("PrescriptionID", trnDataTypeint, 4, RequestID_Prescription)
                                                intCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "pPCTRepeatbyRequestIDforWorkaround", strParam)
                                                'No, so we ask the question
                                                If (intCount < 1) Or TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "PCTWorkAroundQuestionOverride", 0)) Then '11Oct08 TH Added Over ride to always pop the question
                                                   strAns = TxtD(dispdata$ & "\patmed.ini", "", "Y", "PCTWorkAroundQuestionDefault", 0)
                                                   If intCount = 1 Then strAns = "N"   '21Oct08 TH Added
                                                   strDefaultPCTQuestion = "Is this medication for the treatment of Cancer, therefore needed to be claimed under Pharmaceutical Cancer Treatment (PCT)" '11Oct08 TH Added new default question (as per site feedback)
                                                   askwin "?EMIS Health PCT", TxtD(dispdata$ & "\patmed.ini", "", strDefaultPCTQuestion, "PCTWorkAroundQuestion", 0), strAns, k
                                                   If strAns = "Y" Or strAns = "N" Then
                                                      strParam = strParam & gTransport.CreateInputParameterXML("PCTFlag", trnDataTypeBit, 1, TrueFalse(strAns))
                                                      intCount = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPCTRepeatWorkAroundWrite", strParam)
                                                   End If
                                                End If
                                             End If
                                          End If
                                          '----------------------
                                          
                                          SetFocusTo TxtPrompt       '27oct08 CKJ added as focus appears to vary depending on preceding popups (F0036227)
                                       End If
                                    Else
                                       lblStatus(0).Caption = " No matching products found "
                                    End If
                                 End If
                              End If
                           Else
                              success = False 'set inactive
                              lblStatus(0).Caption = "Prescription Locked" '30Jan13 TH Changed message
                           End If
                        
                        Else '29Jan13 TH Prescription Episode Crosscheck has failed TFS 54633 '13Feb13 TH Moved inside main rx check (TFS)
                           success = False 'set inactive
                           lblStatus(0).Caption = "Patient Mismatch" '30Jan13 TH Changed message
                           WriteLogSQL "The input Rx RequestID " & CStr(RequestID_Prescription) & " does not match to a patient via the current Episode in state " & CStr(EpisodeID), "EpisodeRxMismatch", 0, 0 '30Jan13 TH
                           popmessagecr "!Patient Mismatch", "Please reselect this patient as the system cannot validate that all information has been loaded correctly." & crlf & crlf & "Please contact EMIS Health support if this message persists."
                           '30Jan13 TH Replaced above message, was "Episode/Prescription Mismatch" & crlf & crlf & "The Current selected Patient does not match the Patient this prescription is for"
                        End If
                     Else
                        If Trim$(lblStatus(0).Caption) <> "Repeat Cycle - aborted" Then '20Aug13 TH Added (TFS 70134)
                           lblStatus(0).Caption = " Prescription not found "
                           popmessagecr "#", "Prescription not found" & crlf & crlf & "(Prescription ID = " & Format$(RequestID_Prescription) & ")"
                        End If
                     End If
                     '13Feb13 TH Moved Above
                     'Else '29Jan13 TH Prescription Episode Crosscheck has failed TFS 54633
                     '   success = False 'set inactive
                     '   lblStatus(0).Caption = "Patient Mismatch" '30Jan13 TH Changed message
                     '   WriteLogSQL "The input Rx RequestID " & CStr(RequestID_Prescription) & " does not match to a patient via the current Episode in state " & CStr(EpisodeID), "EpisodeRxMismatch", 0, 0 '30Jan13 TH
                     '   popmessagecr "!Patient Mismatch", "Please reselect this patient as the system cannot validate that all information has been loaded correctly." & crlf & crlf & "Please contact ascribe support if this message persists."
                     '   '30Jan13 TH Replaced above message, was "Episode/Prescription Mismatch" & crlf & crlf & "The Current selected Patient does not match the Patient this prescription is for"
                     'End If
                  Else                                                  'no requestid_prescription supplied so shut down interface
                     If g_blnPSO Then                                                                          '14Nov12 TH PSO Big Switch (TFS 38070)
                        lblStatus(0).Caption = " Patient Specific Ordering is not enabled for this site "      '     "
                        popmessagecr "#", "Patient Specific Ordering is not enabled for this site"             '     "
                     Else
                        'no requestid_prescription supplied so shut down interface
                        success = False
                        lblStatus(0).Caption = ""                          'no prescription or dispensing specified - not an error
                        'note dispensing without prescription is an error, but not worth a message as it is disabled anyway
                     End If                                                                                    '     "
                  End If
               End If
            Else
              lblStatus(0).Caption = " Patient not found... "
            End If
         Else
            lblStatus(0).Caption = " Database connection not open "
         End If
      Else
         lblStatus(0).Caption = " Database connection not ready "
      End If
   Else
      lblStatus(0).Caption = " Transport layer not ready "
   End If
Else
'SetConnection failed, message already handled
End If
  
'Reset Parent form
ResetOwnerForm   'AS : MS_Edge_Fix for modal windows without an owner form

Cleanup:
   SetModState 2
   SetInfoLabel success
   
   'If Not success Or Not RequestID_Prescription > 0 Then '21Sep12 AJK 44489 Reset control if no Rx in scope
   If Not success Then '12Oct12 TH Reverted (TFS 46459)
      gRequestID_Prescription = 0
      gRequestID_Dispensing = 0
      Labf& = 0
      gTlogCaseno$ = ""
      DestroyOCXheap
      'clear PID?
      'clear L?
      UserControlEnable False
      DoAction.Caption = "RefreshView-Inactive"       '06oct05 CKJ added
   End If
   
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   
   If ErrNumber Then
      MessageBox ErrDescription, vbCritical + vbOKOnly, Format$(ErrNumber) & " " & ErrSource
      RefreshState = False
   Else
      RefreshState = True
   End If
   'DoAction.Caption = "RefreshView-Inactive"       'clunky but works    '06oct05 CKJ removed as not required with new PMR grid
   
Exit Function

ErrHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
   
End Function

' Print a label used for amm
' Has options to print the label, or save and print the label
' 04May16 XN  added for amm 123082
' 21Jun16 XN  Fixed syringe volume 154896
' 02Aug16 XN  158642 Fix moving to next stage from AMM labeling stage
' 08Aug16 XN  159843 Now reads expiry from DB
' 24Aug16 XN  160920 Fixed expiry
Public Function PrintLabel(ByVal sessionID As Long, _
                       ByVal AscribeSiteNumber As Long, _
                       ByVal RequestID_AmmSupplyRequest As Long, _
                       ByVal numberOfLabels As Integer, _
                       ByVal bPrintLabel As Boolean, _
                       ByVal bSaveLabel As Boolean) As Long
    Dim strParams As String
    Dim rsAMMSupplyRequest As ADODB.Recordset
    Dim success As Boolean
    Dim labelCount As Integer
    Dim lngSuccess As Long
    Dim xp As DateAndTime
    Dim ExpiryDate As DateAndTime
    Dim batchexpiry$, batchtimeexpiry$
    Dim strDate As String, strTime As String, strExpiry As String
    Dim strTmp As String
    Dim batchnumber$
    Dim found As Integer
    Dim syringeCount As Integer
    Dim syringeVol As Double
    Dim syringeFinalVol As Double
    Dim syringeDose As Double
    Dim syringeFinalDose As Double
    Dim strSyrcnt As String, strCIVAScnt As String
    Dim intsyringeloop As Integer, X As Integer, intCIVASlblNum As Integer
    
    success = True
    
    'Set Parent for Modal form - to resolve modal from issue in MS Edge
    SetOwnerForm Me          'AS : MS_Edge_Fix for modal windows without an owner form
   
    If sessionID = 0 Then
        MsgBox "Invalid Session ID"
        success = False
    ElseIf gTransport Is Nothing Then
        MsgBox "No database connection"
        success = False
    ElseIf g_SessionID <> sessionID Or SiteNumber <> AscribeSiteNumber Or gRequestID_AmmSupplyRequest <> RequestID_AmmSupplyRequest Then
        MsgBox "Invalid control state"
        success = False
    End If
    
    If success Then
        strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID_AmmSupplyRequest)
        Set rsAMMSupplyRequest = gTransport.ExecuteSelectSP(g_SessionID, "pAMMSupplyRequestforOCX", strParams)
        If Not (rsAMMSupplyRequest Is Nothing) Then
           If rsAMMSupplyRequest.State = adStateOpen Then
              If rsAMMSupplyRequest.RecordCount <> 0 Then
                 gRequestID_Prescription = RtrimGetField(rsAMMSupplyRequest!PrescriptionID)
                 gRequestID_Dispensing = RtrimGetField(rsAMMSupplyRequest!RequestID_Dispensing)
                 d.SisCode = rsAMMSupplyRequest!NSVCode
                 getdrug d, 0, lngSuccess, False
                 success = (lngSuccess <> 0)

                 Qty! = rsAMMSupplyRequest!QuantityRequested
                                 setm_sgnCivasDose (Qty!)
                                 
                 batchnumber$ = Trim$(rsAMMSupplyRequest!batchnumber)
                 Heap 10, gPRNheapID, "batchnumber", Trim$(rsAMMSupplyRequest!batchnumber), 0
                 
                 syringeCount = RtrimGetField(rsAMMSupplyRequest!NumberOfSyringes)
                 syringeVol = RtrimGetField(rsAMMSupplyRequest!SyringeVolume_mL)
                 syringeFinalVol = RtrimGetField(rsAMMSupplyRequest!SyringeDose_mg)
                 syringeDose = RtrimGetField(rsAMMSupplyRequest!SyringeFinalVolume_mL)
                 syringeFinalDose = RtrimGetField(rsAMMSupplyRequest!SyringeFinalDose_mg)
                 If syringeCount <= 0 Then
                    syringeCount = 1
                 End If
                                 
                 ' Calulcate the expiry XN 8Aug16 159843 got it to read from DB now
                 If Not IsNull(rsAMMSupplyRequest!ExpiryDate) Then
                    batchexpiry$ = Format$(RtrimGetField(rsAMMSupplyRequest!ExpiryDate), "DD/MM/YYYY")
                    batchtimeexpiry$ = Format$(RtrimGetField(rsAMMSupplyRequest!ExpiryDate), "HH:MM")
                 End If
                 
                 ' Calulcate the expiry 24Aug16 XN Fixed expiry
                 Heap 10, gPRNheapID, "expirydateonly", batchexpiry$, 0
                 Heap 10, gPRNheapID, "expirytimeonly", batchtimeexpiry$, 0
                 If batchexpiry$ <> "" Then
                    batchexpiry$ = batchexpiry$ & " " & Left$(batchtimeexpiry$, 2) & ":" & Right$(batchtimeexpiry$, 2)
                 End If
                 Heap 10, gPRNheapID, "rxExpiry", batchexpiry$, 0
                 
                 ' StdLbl10A frig
                 Dim strStdLbl10AFrig As String
                 strStdLbl10AFrig = ""
                 If Len(batchexpiry$) > 0 Then
                     strStdLbl10AFrig = plvl$("DoNotUseAfter") & batchexpiry$
                 End If
                 If batchnumber$ <> "" Then
                     strStdLbl10AFrig = strStdLbl10AFrig & " " & Trim$(TxtD(dispdata$ & "\PATMED.INI", "", "", "BNOnLabel", found))
                     strStdLbl10AFrig = strStdLbl10AFrig & batchnumber$ '22May08 TH Added trim (F0019305)
                 End If
                gStdLbl10PreDone = True
                Heap 10, gPRNheapID, "stdlbl10AFrigFrig", Trim$(strStdLbl10AFrig), 0
              Else
                success = False
              End If
           Else
             success = False
           End If
        Else
          success = False
        End If
    End If
    
    If success Then
                ' 02Aug16 XN 158642 Fix moving to next stage from AMM labeling stage
        If bSaveLabel Then
            LblPrompt_Click 0
        End If
                
                labelCount = numberOfLabels / syringeCount
                intCIVASlblNum = 1
                
                setSyringestolabel (syringeCount)
                resizeSyringeLabel (syringeCount)
                
                For intsyringeloop = 1 To syringeCount
                        If intsyringeloop = syringeCount Then
                           setSyrineLabelDose intsyringeloop, rsAMMSupplyRequest!SyringeFinalDose_mg
                           setSyrineLabelVolume intsyringeloop, rsAMMSupplyRequest!SyringeFinalVolume_mL
                        Else
                           setSyrineLabelDose intsyringeloop, rsAMMSupplyRequest!SyringeDose_mg
                           setSyrineLabelVolume intsyringeloop, rsAMMSupplyRequest!SyringeVolume_mL
                        End If
                        
                        createlabel 1, intsyringeloop
                        
                        strSyrcnt = Trim$(Str$(intsyringeloop)) & TxtD(dispdata$ & "\PATMED.INI", "", " of ", "SyringeCountSeparator", 0) & Trim$(Str$(Syringestolabel())) & TxtD(dispdata$ & "\PATMED.INI", "", " syringes", "SyringeCountSuffix", 0)
                        strSyrcnt = TxtD(dispdata$ & "\PATMED.INI", "", "", "SyringeCountPrefix", 0) & strSyrcnt     '05Jun02 TH Added possible prefix
                        Heap 10, gPRNheapID, "SyrCnt", strSyrcnt, 0
                        
                        For X = 1 To labelCount
                                strCIVAScnt = Trim$(Str$(intCIVASlblNum)) & TxtD(dispdata$ & "\PATMED.INI", "", " of ", "CIVASlblCountSeparator", 0) & Trim$(Str$(numberOfLabels)) & TxtD(dispdata$ & "\PATMED.INI", "", "", "CIVASlblCountSuffix", 0) '14Jan13 TH Altered after testing as two figures were wrong way round
                                strCIVAScnt = TxtD(dispdata$ & "\PATMED.INI", "", "", "CIVASlblCountPrefix", 0) & strCIVAScnt     '09Jan13 TH Added possible prefix
                                Heap 10, gPRNheapID, "CCnt", strCIVAScnt, 0
                
                                'DisplaytheLabel labelCount, 3, k, "", 0, False  ' Use print output 2 to save reprint and 3 to print without reprint
                                
                                DisplaytheLabel 1, 3, k, "", intsyringeloop, 0, Iff(bPrintLabel, 1, 0) '06Jan13 TH Added Param
                                If Not (k.escd) And bSaveLabel Then ReprintFile 5, 1, 0, intCIVASlblNum
                                
                                intCIVASlblNum = intCIVASlblNum + 1
                        Next
                Next
    End If
    
    PrintLabel = L.RequestID
    
    'Reset Parent form
    ResetOwnerForm   'AS : MS_Edge_Fix for modal windows without an owner form

End Function

' 02Aug16 XN 159413 Added to allow getting label text without printing, or saving
Public Function GetLabelText(ByVal sessionID As Long, _
                         ByVal AscribeSiteNumber As Long, _
                         ByVal RequestID_AmmSupplyRequest As Long) As String
                           
    Dim strParams As String
    Dim rsAMMSupplyRequest As ADODB.Recordset
    Dim success As Boolean
    Dim syringeCount As Long
    Dim strText As String, stdlbl As String
    Dim i As Long
    
    'Set Parent for Modal form - to resolve modal from issue in MS Edge
    SetOwnerForm Me          'AS : MS_Edge_Fix for modal windows without an owner form
   
    'Clear label
    For i = 1 To 11
        Heap 10, gPRNheapID, "StdLbl" + CStr(i) + "a", "", 0
    Next
    
    strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID_AmmSupplyRequest)
    Set rsAMMSupplyRequest = gTransport.ExecuteSelectSP(g_SessionID, "pAMMSupplyRequestforOCX", strParams)
    If Not (rsAMMSupplyRequest Is Nothing) Then
        If rsAMMSupplyRequest.State = adStateOpen Then
            If rsAMMSupplyRequest.RecordCount <> 0 Then
                syringeCount = RtrimGetField(rsAMMSupplyRequest!NumberOfSyringes)
                If syringeCount <= 0 Then
                    syringeCount = 1
                End If
            End If
        End If
    End If
    
    PrintLabel sessionID, AscribeSiteNumber, RequestID_AmmSupplyRequest, syringeCount, False, False
    
    strText = ""
    For i = 1 To 11
        Heap 11, gPRNheapID, "StdLbl" + CStr(i) + "a", stdlbl, 0
        strText = strText & stdlbl + vbNewLine
    Next
    
    GetLabelText = strText
    'Reset Parent form
    ResetOwnerForm   'AS : MS_Edge_Fix for modal windows without an owner form
End Function

' Reprints label for RequestID_Dispensing for AMM
' 18May16 XN  added for amm 153668
Public Function ReprintLabel(ByVal sessionID As Long, _
                       ByVal AscribeSiteNumber As Long, _
                       ByVal RequestID_AmmSupplyRequest As Long, _
                       ByVal RequestID_Dispensing As Long, _
                                           ByVal URLToken As String) As Long
    Dim success As Boolean
    success = True
   
   'Set Parent for Modal form - to resolve modal from issue in MS Edge
   SetOwnerForm Me          'AS : MS_Edge_Fix for modal windows without an owner form
   
   '23Nov05 CKJ Is the user control fully awake & connected? If not then release completely
   On Error Resume Next
   Set gTransport = Nothing

   ' 22Jan13 XN 53975 If session changes then clear user details
   If (g_SessionID <> sessionID) Or (SiteNumber <> AscribeSiteNumber) Then
      gEntityID_User = 0
      UserID = ""
      UserFullName = ""
   End If

   g_URLToken = URLToken  ' added cached URL so frmWebClient has a web server name (F0033906)
   success = True
   If (gTransport Is Nothing) Or sessionID <> g_SessionID Or (SiteNumber <> AscribeSiteNumber) Then    'session is never zero, so this fires once at startup and again if session ever changes  '23Nov05 CKJ added gTransport
      frmBlank.Tag = Format$(((1# * frmBlank.DefaultTop * frmBlank.DefaultLeft) / frmBlank.DefaultWidth) * frmBlank.DefaultHeight)  '24Apr13 XN 60910 Changed connection string encryption seed to work on any PC
      success = SetConnection(sessionID, AscribeSiteNumber, URLToken)         '18Jul08 CKJ added param URLtoken
   End If
    
   If success Then
      Labf& = RequestID_Dispensing
          ReprintFile 1, 2, RequestID_Dispensing, 0
   End If
   
   'Reset Parent form
    ResetOwnerForm   'AS : MS_Edge_Fix for modal windows without an owner form

End Function

'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
'                    Events Raised By Embedded Controls
'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Private Sub lblStatus_MouseUp(Index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)

''Dim ans As String
''Dim xpos As Long
''Dim ypos As Long
''Dim MousePosition As POINTAPI
''
''   If button = vbLeftButton And Shift = 0 Then
''      ans = ""
''      popmenu 0, "", 0, 0
''
''      GetCursorPos MousePosition                                  'Get pointer position
''      xpos = MousePosition.X * Screen.TwipsPerPixelX
''      ypos = MousePosition.Y * Screen.TwipsPerPixelY
''      xpos = xpos - X - 90                                        'less allowance for border
''      ypos = ypos - Y + lblStatus(index).Height - 600             'less allowance for border
''
''      Select Case index
''         Case 0   'status
''            'not visible now
         
''         Case 1   'prescription
''            popmenu 2, "New[tab]Ctrl+N[cr]Amend[tab]Ctrl+M[cr]Discontinue[tab]Ctrl+T[cr]Save[tab]Ctrl+S[cr]Print[tab]Ctrl+P", 0, 0
''            PopMenuShow ans, xpos, ypos
''            Select Case Val(ans)            'mnuScript_Click
''               Case 1: DispMnuButHandler 1  'new label
''               Case 2: DispMnuButHandler 2  'amend label
''               Case 3: DispMnuButHandler 3  'discontinue label
''               Case 4: DispMnuButHandler 4  'save label
''               Case 5: DispMnuButHandler 5  'print label
''              'Case 6: separator
''              'Case 7: DispMnuButHandler 0  'Exit Dispensary
''               End Select
''
''         Case 2   'edit
''            popmenu 2, "Undo[tab]Ctrl+Z[cr]Cut[tab]Ctrl+X[cr]Copy[tab]Ctrl+C[cr]Paste[tab]Ctrl+V", 0, 0
''            PopMenuShow ans, xpos, ypos
''            Select Case Val(ans)             'mnuEdit_Click
''               Case Is > 0: UndoCutCopyPasteDel Val(ans)
''               End Select
''
''         Case 3   'view
''            popmenu 2, "Inpatient[tab]Ctrl+I[cr]Outpatient[tab]Ctrl+O[cr]Discharge[tab]Ctrl+D[cr]All[tab]Ctrl+A[cr]History[tab]Ctrl+H", 0, 0
''            PopMenuShow ans, xpos, ypos
''            Select Case Val(ans)             'mnuDisplay_Click(1-4) mnuHistory_Click
''               Case Is > 0: popmessagecr ".", "Web function"
''               End Select
         
''         Case 4   'functions
''            'popmenu 2, "Change Ward[cr]Further Information[tab]F3[cr]Stock Level Information[tab]F4[cr]View Prescription[tab]F5[cr]Change Consultant[tab]F6[cr]Print Bag Label[tab]F7[cr]Issue Stock[tab]F8[cr]Return Stock[tab]F9[cr]Change Top-up Date[tab]F11", 0, 0
''            'popmenu 2, "Further Information[tab]F3[cr]Stock Level Information[tab]F4[cr]View Prescription[tab][cr]Print Bag Label[tab]F7[cr]Issue Stock[tab]F8[cr]Return Stock[tab]F9[cr]Change Top-up Date[tab]F11[cr]Print Free Format Label", 0, 0
''            popmenu 2, "Further Information[tab]F3[cr]Stock Level Information[tab]F4[cr]Print Bag Label[tab]F7[cr]Issue Stock[tab]F8[cr]Return Stock[tab]F9[cr]Change Top-up Date[tab]F11[cr]Print Free Format Label", 0, 0
''            PopMenuShow ans, xpos, ypos
''            Select Case Val(ans)
''               'Case 1: popmessagecr ".", "Web function"  'mnuWard_Click
''               Case 1: mnuInfo_Click
''               Case 2: MnuStockLevel_Click
''               'Case 3: MnuPrescription_Click
''               'Case 5: popmessagecr ".", "Web function"  'mnuchangeconsultant_click
''               Case 3: MnuLabel_Click
''               Case 4: MnuIssue_Click
''               Case 5: MnuReturn_Click
''               Case 6: ChangeTopupDate
''               'Case 7: mnuPrescriber_Click
''               Case 7: SelectAndPrintFFlabels         'DispMnuButHandler 13   'Print FFlabel
''               End Select
         
''         Case 5   'tools
''            popmenu 2, "Colour[tab]Ctrl+L[cr]Discharge[tab]Ctrl+G[cr]Protocols[tab]Ctrl+R[cr]Formula/PN[tab]Ctrl+F[cr]--[cr]Edit Free Format Label[cr]Print Free Format Label[cr]Options...", 0, 0
''            PopMenuShow ans, xpos, ypos
''            Select Case Val(ans)
''               Case 1 To 7: MnuTools_Click (Val(ans) - 1)
''               Case 8:      popmessagecr ".", "Not available"     'mnuOptionsHdg_Click
''               End Select
         
''         Case 6   'Information
''            'popmenu 2, "BNF[tab]Ctrl+B[cr]--[cr]Last Issues to patient[cr]Last Issues of Product[cr]Last Issues by User[cr]Last Issues to Department[cr]Log Viewer[cr]Show Prescriber[tab]Shift+F11[cr]Stock in machine[tab]Shift+F4", 0, 0
''            popmenu 2, "BNF[tab]Ctrl+B[cr]Show Prescriber[tab]Shift+F11[cr]Stock in machine[tab]Shift+F4", 0, 0
''            PopMenuShow ans, xpos, ypos
''            Select Case Val(ans)
''               Case 1: LoadBNF                                     'mnuinfotools_click(0)
''               'Case 2 To 7: popmessagecr ".", "Web function"      'mnuinfotools_click (Val(ans) - 1)
''               Case 2: MnuShowPrescriber_Click
''               Case 3: mnuMechDispEnquiry_Click
''               End Select
         
''         Case 7   'Help
''            popmenu 2, "Contents[tab]F1[cr]Search for help on...[cr]How to use help[cr]About...", 0, 0
''            PopMenuShow ans, xpos, ypos
''            Select Case Val(ans)
''               Case 1: Help UserControl.hWnd, 0                         'mnuHelp_Click(0)
''               Case 2: HelpSearch UserControl.hWnd                      'mnuHelp_Click(1)
''               Case 3: HelpGet UserControl.hWnd, HELP_HELPONHELP, 0     'mnuHelp_Click(2)
''               Case 4: ShowAboutBox "ASCribe Dispensing Module"  'mnuAbout_Click
''               End Select
''
''         End Select
''      popmenu 0, "", 0, 0
''   End If
      
End Sub

'Private Sub TxtPrepTime_Change()
''09May05 split from the rest of the time(x) array
'
'   If Not StopEvents Then
'         If TxtTime(1).Visible = True Then Calcqtys
'
'         If Not tFirstLoaded Then
'            tFirstLoaded = True
'            datechanged = False
'         Else
'            datechanged = True
'         End If
'
'         LabelAmended = True
'       End If
'
'End Sub
'
'Private Sub txtPrepTime_DblClick()
''09May05 split from the rest of the time(x) array
''But not convinced this is needed for the prep time
'
'Dim Timestr$
'
'''   If Trim$(txtPrepTime.Text) <> "" Then
'         EnterTime Timestr$
'         If Timestr$ <> "" Then
'               txtPrepTime.Text = Timestr$
'            End If
'''      Else                                    why would double click here on an empty box prompt for dose & directions?
'''         TxtDirCode_keyDown 8, 0
'''         enterdose
'''         ChooseDirectionCode WDir.Code
'''         expanddir WDir.Code
'''      End If
'
'End Sub
'
'Private Sub TxtPrepTime_GotFocus()
''09May05 split from the rest of the time(x) array
'
'   txtPrepTime.Text = RTrim$(txtPrepTime.Text)
'   'txtPrepTime.SelStart = 0
'   'txtPrepTime.SelLength = Len(txtPrepTime.Text)
'
'End Sub
'
'Private Sub TxtPrepTime_KeyDown(KeyCode As Integer, Shift As Integer)
''09May05 split from the rest of the time(x) array
'
'   Select Case KeyCode
'      Case 27, 13    'Return/Escape
'         TxtPromptSetFocus
'      Case 38        'Keyup
'         txtPrepDate.SetFocus
'      End Select
'
'End Sub
'
'Private Sub TxtPrepTime_KeyPress(KeyAscii As Integer)
''09May05 split from the rest of the time(x) array
'
'   Select Case KeyAscii
'      Case 13, 27: KeyAscii = 0
'      End Select
'
'End Sub

Private Sub ChkDay_Click(Index As Integer)

   Calcqtys
   If Not StopEvents Then LabelAmended = True

End Sub

Private Sub ChkDay_MouseUp(Index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)

   SetFocusTo TxtPrompt

End Sub

Private Sub ChkManual_Click()

   If Not StopEvents Then LabelAmended = True

End Sub

''Private Sub ChkManual_KeyDown(KeyCode As Integer, Shift As Integer)
''
''   SetFocusTo TxtPrompt
''
''End Sub

Private Sub ChkPatOwn_Click()
'13Nov97 CFY Patients Own Medication

   If Not StopEvents Then LabelAmended = True
   SetFocusTo TxtPrompt

End Sub

Private Sub ChkPatOwn_KeyDown(KeyCode As Integer, Shift As Integer)

   SetFocusTo TxtPrompt

End Sub

Private Sub chkPIL_KeyDown(KeyCode As Integer, Shift As Integer)

   Select Case KeyCode
      Case 40, 27  'Down arrow,Escape
         SetFocusTo TxtPrompt
      Case 13
         If chkPIL.Value < 2 Then chkPIL.Value = 1 - chkPIL.Value
         SetFocusTo TxtPrompt
      End Select

End Sub

Private Sub ChkPRN_click()
'29May98 CFY Changed condition which determines if the prn flag has been set or not
'26Jun98 CFY PRN text no longer hard coded but picked up from patmed.ini
'22Jul98 EAC make PRN text language aware
'11Dec13 TH  If we dont have any PRN text then we wont try and replace it with any extended PRN text. (TFS 81485)
'03Apr14 TH  Added following space to default PRNIf setting (TFS 87938)
'**!!**V93 needs revising

Dim temp%
Dim PRNText$
Dim strUpto As String
Dim strPRNIF As String
   
   PRNText$ = TxtD(ASCFileName("patmed.ini", False, ""), "", "when required", "PRNDesc", 0)
   temp = InStr(TxtDirections, PRNText$)
   
   If Not StopEvents Then LabelAmended = True

   If temp > 0 And ChkPRN.Value = 0 Then
         TxtDirections = Left$(TxtDirections, temp - 1) & Right$(TxtDirections, Len(Trim$(TxtDirections)) - temp + 1 - Len(Trim$(PRNText$)))    '26Jun98 CFY
      End If
   If temp = 0 And ChkPRN.Value <> 0 Then
         TxtDirections = RTrim$(TxtDirections)
         If Right$(TxtDirections, 2) = crlf Then
               TxtDirections = RTrim$(Left$(TxtDirections, Len(TxtDirections) - 2))
            End If
         TxtDirections = TxtDirections & crlf & PRNText$
         temp = 1 '12Apr14 TH Set as flag so we can test for minimum dose functionality below (TFS 84804)
      End If
   
   'If temp > 0 And ChkPRN.Value <> 0 Then
   If temp > 0 And ChkPRN.Value <> 0 And PRNText$ <> "" Then '11Dec13 TH If we dont have any PRN text then we wont try and replace it. (TFS 81485)
      'Here we may need to insert the new stuff
      If Val(OCXheap("MinimumDoseInterval", "")) > 0 Then
         strPRNIF = TxtD(ASCFileName("patmed.ini", False, ""), "", "if required ", "PRNExtDesc", 0)  '03Apr14 TH Added following space to default (TFS 87938)
         strUpto = TxtD(ASCFileName("patmed.ini", False, ""), "", "up to every ", "PRNMinDoseDesc", 0)
         'If Trim$(strPRNIF) = "" Then strPRNIF = Right$(TxtDirections, Len(Trim$(TxtDirections)) - temp + 1)  '22Mar12 TH Removed after testing to make more flexible (TFS 29787)
         TxtDirections = Left$(TxtDirections, temp - 1) & strUpto & Trim$(OCXheap("MinimumDoseInterval", "")) & " " & Trim$(OCXheap("UnitDescriptionMinimumDoseInterval", "")) & plural$(Val(OCXheap("MinimumDoseInterval", ""))) & " " & strPRNIF    '26Jun98 CFY
      End If
   End If

End Sub

''Private Sub CmbContainer_Change()
''
''   If Not StopEvents Then LabelAmended = True
''
''End Sub
''
''Private Sub CmbContainer_KeyDown(KeyCode As Integer, Shift As Integer)
''
''   Select Case KeyCode
''      Case 27 'Escape
''         TxtPromptSetFocus                                                      '17May99 AE
''   End Select
''
''End Sub
''
''Private Sub CmbContainer_KeyPress(Keyascii As Integer)
''
''   CmbContainer.Text = ""                         '24Jan95 CKJ
''   Keyascii = Asc(UCase$(Chr$(Keyascii)))
''
''End Sub

''Private Sub CmbDiluentAbbr_Change()
''
''   If Not StopEvents Then LabelAmended = True
''
''End Sub
''
''Private Sub CmbDiluentAbbr_KeyDown(KeyCode As Integer, Shift As Integer)
''
''   Select Case KeyCode
''      Case 27 'Escape
''         TxtPromptSetFocus                                                      '17May99 AE
''   End Select
''
''End Sub

Private Sub CmbIssueType_Click()
'03Apr KR/EAC Removed - removed bug when selecting items in list
'07Jul97 KR Change issue type description when changing issue type.
'08Jul97 KR/CKJ check if previouse type was civas
'05Feb99 SF now only calls createlabel: if label has not been reused

 Dim intCount As Integer
 Dim strTmpIssuetype As String

   strTmpIssuetype = L.IssType
   
   If L.IssType <> Left$(CmbIssueType.List(CmbIssueType.ListIndex), 1) And passlvl <> 3 Then '5Jul97 ASC
         '!!** wascivas% = (l.isstype = "C")
         
         '26Jul12 TH Added block (prevent label edits)  (TFS 39622)
         If (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Or (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then ' in prohibited list then
            popmessagecr "EMIS Health", "You are not allowed to change this type of label"
            L.IssType = strTmpIssuetype
            For intCount = 0 To cmbUC("CmbIssueType").ListCount - 1
               If L.IssType = Left$(cmbUC("CmbIssueType").List(intCount), 1) Then
                  cmbUC("CmbIssueType").ListIndex = intCount
                  Exit For
               End If
            Next
            SetFocusTo TxtPrompt
            Exit Sub
         End If
         '---------
         SetAttemptedlabelEdit True
         
         If Left$(CmbIssueType.List(CmbIssueType.ListIndex), 1) = "C" Then formtolabel 0 'Calcqtys
         L.IssType = Left$(CmbIssueType.List(CmbIssueType.ListIndex), 1)
         WDir.directs = TxtDirections.text
         If Not reusedLabel% Then createlabel 1, 0
         memorytolabel
         Calcqtys
         '!!**If wascivas% Then TxtQtyPrinted = "0"
         
         SetLblQtyDescCaption L.IssType
      End If

   EnableTxtDrugAndDirCode (L.IssType <> "P")    '28Jul97 CKJ disable for PN only
   '16Jun05 TH Added Block
   If UCase$(Left$(CmbIssueType.text, 1)) = "C" Then
      TxtQtyPrinted.Visible = False
      LblQtyDesc.Visible = False
   Else
      TxtQtyPrinted.Visible = True
      LblQtyDesc.Visible = True
   End If
   '--------------
End Sub

Private Sub CmbIssueType_KeyDown(KeyCode As Integer, Shift As Integer)

    Select Case KeyCode
      Case 27 'Escape
         SetFocusTo TxtPrompt

      Case 13 'Return
         KeyCode = 0
         If L.IssType <> "P" Then              '11Nov97 CKJ can't setfocus with PN - not on view
            SetFocusTo TxtLabel(1)
         End If
      End Select

End Sub

Private Sub CmbIssueType_KeyPress(KeyAscii As Integer)

   Select Case KeyAscii
      Case 27  'Escape
         KeyAscii = 0
         
      Case 13  'Return
         KeyAscii = 0
         If L.IssType = "P" Then
            doFormulaAndPN
''               '20Jul98 EAC
''               If OCXlaunch() And GetTpnExit() Then
''                     GetOCXStatus OCXStatus$                    '01Oct99 CFY Added
''                     SignalASCDone OCXStatus$, Labf&, True      '20Jul98 EAC
''                  End If
''               '---
         End If
      End Select

End Sub

Private Sub CmbIssueType_LostFocus()
'05Jun97 KR Removed CheckIsstype as not necessary
'28Nov96 ASC Now use click event as this does fire
'22Feb96 EAC - needs to be in here as no CHANGE events are generated for
'              drop down list boxes
'12Jun97 KR  Start TPN if issuetype = "T"
      
   If L.IssType <> Left$(CmbIssueType.List(CmbIssueType.ListIndex), 1) And trimz(L.IssType) <> "" Then
         LabelAmended = True
         L.IssType = Left$(CmbIssueType.List(CmbIssueType.ListIndex), 1)
     End If
   
End Sub

Private Sub CmbRepeatUnits_Click()

   fraDays.Visible = (Trim$(LCase$(CmbRepeatUnits.text)) = "wk")
   If Not StopEvents Then LabelAmended = True

End Sub

Private Sub CmbRoute_Change()
   
   If Not StopEvents Then LabelAmended = True

End Sub


''Private Sub CmbRoute_KeyDown(KeyCode As Integer, Shift As Integer)
'''07Jun97 KR Move the cursor back to prompt (if visible) after editing route.
''
''   If KeyCode = 40 Then CmbRoute_DropDown
''   If KeyCode = 13 Then SetFocusTo TxtPrompt
''
''End Sub

''Private Sub CmbRoute_LostFocus()
''
''   WDir.route = CmbRoute.Text

''   If Left(CmbRoute.Text, 2) = "IV" Then
''          fraIVdetails.Visible = True
''          TxtDirections.Height = 800
''      Else
''          fraIVdetails.Visible = False
''          TxtDirections.Height = 1095
''      End If
''
''End Sub

''Private Sub CmbDropDrugCode_Click(index As Integer)
''
''   TxtDircode.SetFocus
''
''End Sub

''Private Sub CmbDropDrugCode_DropDown(index As Integer)
'''26Feb99 TH  Stop dose calculator for creams in prescribing
'''12May99 CFY Trap to prevent any actions occuring if system is running in OCX mode and OCX action is modify.
'''09Apr01 CKJ Do not allow TxtDrugCode_KeyDown to be called whilst switched to the alternate dispdata, instead
'''            encapsulate the functionality at a lower level inside EnterDrug and Findrdrug.
'''01May01 AW Added code to allow new bnf to work
''
''   If (Not OCXlaunch()) Or (GetOCXAction() <> "M") Then
''      Select Case index
''         Case 0
''            escaped = False
''            TxtDrugCode.Text = "BNF"
''            TxtDrugCode_KeyDown 13, 0
''
''         Case 1
''            If passlvl = 3 Then
''               If Not UCase$(Trim$(d.DosingUnits)) = "APP" Then     '26Feb99 TH    Stop dose for creams in prescribing
''                  enterdose
''               End If
''            End If
''            ChooseDirectionCode WDir.Code
''            expanddir WDir.Code
''            checkroute
''         End Select
''   End If
''
''   TxtDircode.SetFocus
''
''End Sub


''Private Sub CmdInteractions_Click()
'''16May97 ASC
'''12sep01 CKJ added protocol parameter
''
''Dim severity%, abort$
''
''   checkPMRinteractions False, "", "", False, severity%, abort$, False
''   TGLabelList.Refresh
''
''End Sub

''Private Sub CmdInteractions_KeyDown(KeyCode As Integer, Shift As Integer)
''
''   If KeyCode = 27 Then
''         TxtPrompt_KeyDown 27, 0
''      End If
''
''End Sub

'   Private Sub CmdPrompt_Click(index As Integer)
'   '25Sep96 Reinstated nextchoice A - since F5 does not keep changes to the prescription, it is
'   '        inappropriate to call F5 from the Amend button.  Why was this done in the first place?
'   '09May97 KR Changed the way buttons are handled.
'   '11Aug98 EAC Added command to return qty for OCX mods
'
'      Select Case index
'   ''      Case 0:  DispMnuButHandler 1        'New prescription
'   ''      Case 1:  DispMnuButHandler 2        'Amend prescription
'         Case 2:  DispMnuButHandler 3        'Discontinue prescription
'         Case 3:  DispMnuButHandler 4        'Save Prescription
'         Case 4:  DispMnuButHandler 5        'Print Prescription
'         Case 5:  PopupFunctionMenu
'         'Case 5:  DispMnuButHandler 6        'Show colour palette 09Jan98 now called from icon
'   ''      Case 6:  DispMnuButHandler 11       'Clear instructions
'   ''      Case 7:  DispMnuButHandler 7        'discharge Letter
'   ''      Case 8:  DispMnuButHandler 10       'Formula/PN
'   ''               If OCXlaunch() And GetTpnExit() Then
'   ''                     GetOCXStatus OCXStatus$                    '01OCt99 CFY Added
'   ''                     SignalASCDone OCXStatus$, Labf&, True      '20Jul98 EAC
'   ''                  End If
'   '      Case 9:  DispMnuButHandler 8        'Protocols
'         Case 9:  ToggleRxLabel (fraRx.Visible) 'was FlipFlopRxView
'         Case 10: LoadBNF                      'DispMnuButHandler 9        'Load BNF
'   ''      Case 11: DispMnuButHandler 0        'Exit Dispensary
'         End Select
'
'   End Sub

'   Private Sub CmdPrompt_KeyDown(index As Integer, KeyCode As Integer, Shift As Integer)
'   '05Jul96 KR  Added start of exit sequence if user presses escape.
'
'      Select Case KeyCode
'         Case 27 'Escape
'            TxtPromptSetFocus
'         End Select
'
'   End Sub

'   Private Sub CmdPrompt_MouseUp(index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)
'   '26Dec98 ASC
'
'      Select Case index
'         Case 3, 6, 2, 4, 7, 8, 9, 10
'            TxtPromptSetFocus
'         End Select
'
'   End Sub


Private Sub DoAction_Change()
'14Jun00 AE  Written
'            Flag to allow actions to be done on dispens frm, eg saving of a prescription from code,
'            in procedures outside dispens frm.
'            Setting it performs an action, depending on it's current value. Setting it to "0"
'            returns it to the default, waiting state.
'06Oct05 CKJ added prescriptionID to RefreshView
'17May06 CKJ Added "RefreshState-ForceInactive" to half-close the database connection and
'            call RefreshState recursively to shut the UserControl down.

'--------------------------------------------------------------
Dim dummy As Boolean

   Select Case DoAction
      Case ""     'no action needed
      
      Case "SAVE"
      'Save the current prescription by manipulating controls from code.
''            CmdPrompt(3).SetFocus
''            DoSaferEvents 2
''            CmdPrompt_Click 3
''            DoSaferEvents 1
         DispMnuButHandler 4        'Save Prescription

      Case "DELETEDIR"
         'Remove the entries in the directions box by simulating a backspace keypress
         TxtDirCode_keyDown 8, 0
         
      Case "RefreshView-Inactive"
         RaiseEvent RefreshView(0, 0)

      Case "RefreshView-Save"
         RaiseEvent RefreshView(gRequestID_Prescription, L.RequestID)

      Case "RefreshState-ForceInactive"
         On Error Resume Next
         IPLinkShutdown                      '11Aug10 CKJ Added to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)

         'gTransport.Connection.Close
         gTransportConnectionClose           '04Oct12 CKJ use wrapper TFS44503
         On Error GoTo 0
         'dummy = RefreshState(g_SessionID, gDispSite, 0, 0, "", "")
         dummy = RefreshState(g_SessionID, SiteNumber, 0, 0, "", "", "Enabled", 0)  '04Jul14 TH Replaced to use proper param - from unit test of Second label

      Case "RefreshState-Inactive-Connected"                          '31Jul14 TH Added for extended label close down (retain connection)
         dummy = RefreshState(g_SessionID, SiteNumber, 0, 0, "", "", "Enabled", 0)

      'Case
      '
      'more...
      '
      End Select
         
   DoAction.Caption = ""

End Sub

Private Sub F3D1_Click()
'31Jan03 TH (PBSv4) Written

   DoPatientBilling 120, 2
   F3D1.Height = 230
   PBSRefreshPatDetails F3D1
   setQuesdefaults 3    '  "        Not sure why this is needed at all but dont want to tempt fate too much

End Sub

Private Sub F3D2_Click()
'31Jan03 TH (PBSv4) Written
Dim intOK As Integer

   If Trim$(d.SisCode) <> "" And (d.SisCode = Trim$(TxtDrugCode.text)) Then
      If Not PBSGetFoundDrugItem() Then
         If L.batchnumber = 0 Then               '16Mar03 TH (PBSv4) Added to allow saved but not issued lines
            intOK = billpatient(33, "")          '    "      to be checked (they may be PBS issuable, not automatically
            If intOK Then                        '    "      private)
               intOK = billpatient(19, "")
            Else
               intOK = billpatient(32, "")
            End If
            setPBSblnKeepBillitems True
            Unload Ques
         Else
            intOK = billpatient(32, "")   '*** was 27 now 32
            setPBSblnKeepBillitems True 'Use this as flag to ensure defaults arent reloaded until required
            Unload Ques
         End If
      Else
         intOK = billpatient(19, "")
         setPBSblnKeepBillitems True 'Use this as flag to ensure defaults arent reloaded until required
         Unload Ques
      End If
   Else
      popmessagecr "!", "Please Specify Item before editing PBS details"
   End If
   
   SetFocusTo TxtPrompt
      
End Sub

Private Sub F3D2_Resize()
'31Jan03 TH (PBSv4) Written

   F3D1.Top = picOCXdetails.Top + 450 + 50 + F3D2.Height  '20Oct03 TH Changed resizing

End Sub

''Private Sub Label5_Click()
'''Stop date label
''
''   TxtStopDate_DblClick
''
''End Sub

''Private Sub Label6_Click()
'''Start date label
''
''   TxtStartDate_DblClick
''
''End Sub

''Private Sub LblDrug_Click()
''
''   escaped = False
''   TxtDrugCode.Text = "BNF"
''   TxtDrugCode_KeyDown 13, 0
''
''End Sub

Private Sub RxUnits_Change(Index As Integer)

   'RxUnits(0) = RxUnits(1)
   RxUnits(0) = ""            '12Dec97 CKJ Temporary removal for safety
                              '            this does not necessarily reflect the units used

End Sub

Private Sub TextBlister_Change()
'25Jan98 CKJ/ASC Limit to 3 blisters max at this time
'                Note that up to 7 could be supported
'15Apr02 TH Extended Entry Value to 4 (#53284)

   If Val(TextBlister) > 4 Then TextBlister = "0"    '15Apr02 TH Extended to 4 (#53284)

End Sub

Private Sub TextBlister_KeyDown(KeyCode As Integer, Shift As Integer)
   
   If Not KeyCode = 9 Then
      SetFocusTo TxtPrompt
   End If

End Sub

'Private Sub txtPrepDate_Change()
''29Mar96 KR Prevents date changed dialog appearing even though actual date not changed
''23Jul96 KR Fixed error with changed dialog.
''26Jul96 KR Added extra prepdate$ line so prepdate always set, but reset if changed.
'
'   prepdate$ = txtPrepDate.text
'   If Not dfirstloaded Then
'      dfirstloaded = True
'      datechanged = False
'   Else
'      datechanged = True
'      prepdate$ = txtPrepDate.text
'   End If
'
'End Sub
'
'Private Sub txtPrepDate_GotFocus()
'
'   txtPrepDate.Text = RTrim$(txtPrepDate.Text)
'   ''txtPrepDate.SelStart = 0
'   ''txtPrepDate.SelLength = Len(txtPrepDate.Text)
'
'End Sub
'
'Private Sub txtPrepDate_KeyDown(KeyCode As Integer, Shift As Integer)
'
'   Select Case KeyCode
'      Case 27     'Escape
'         TxtPromptSetFocus
'      Case 40, 13 'KeyDown/Return
'         txtPrepTime.SetFocus
'      End Select
'
'End Sub
'
'Private Sub txtPrepDate_KeyPress(KeyAscii As Integer)
'
'   Select Case KeyAscii
'      Case 13, 27: KeyAscii = 0
'      End Select
'
'End Sub
'
'Private Sub txtPrepDate_LostFocus()
'
'Dim sDate$, pdate$, valid%
'
'   sDate$ = txtPrepDate.Text
'   If sDate$ <> "" Then
'         parsedate sDate$, pdate$, "1", valid
'         If Not valid Then
'               popmessagecr "Date not valid", "Please re-enter " + sDate$
'               txtPrepDate.SetFocus
'            Else
'               txtPrepDate.Text = pdate$
'            End If
'      End If
'
'End Sub

Private Sub TxtDircode_Change()
'22Sep00 JN added a check for re-entered directions after a lo/hi dosage warning via buttons on dispens frm
'   "    "  if a dosage has been cancelled, the TxtDirCode.Tag will be "C", so change to "c" (routine will fire when box is cleared).
'   "    "  When "c", set to "" (gone through twice - cleared and re-entered dose).
'   "    "  These Tags are picked up in CheckRxComplete, which will return False if the Tag is set.

Dim TxtDirCodePar$, highlight%, PutDirToForm%

   If Not StopEvents Then
         TxtDirCodePar$ = TxtDircode.text
         TxtDircodeChange TxtDirCodePar$, highlight%, PutDirToForm%
         TxtDircode.text = TxtDirCodePar$
         TxtDircode.SelStart = Len(TxtDircode.text)
         If PutDirToForm% Then DirToForm True
         LabelAmended = True
         Select Case TxtDircode.Tag
            Case "C"
               TxtDircode.Tag = "c"
            Case "c"
               TxtDircode.Tag = ""
            End Select
      End If
   
End Sub

''Private Sub TxtDircode_DblClick()
''
''   ChooseDirectionCode WDir.Code
''   expanddir WDir.Code
''
''End Sub

Private Sub TxtDircode_GotFocus()
'25Jun97 KR  Replaced TextBoxHilight with TxtDirCode.Selstart so that
'            the caret always appears at the end of the line.  When the the text was highlighted
'            and overwrittein, the directions on the 'prescribing' label were not being cleared.
'            Now if they want to clear the directions, they can press backspace as per normal.
'22Jan98 ASC moved the whole of route handling here from patsubs CheckStandard
'22Jan98 CKJ Route now defaults to oral if using traditional method (ie not DPS) where patmed.ini
'            assumes the default of oral.
'02Mar99 CFY Toggles label to prescription on got focus just in-case this isn't already the case

   TxtDircode.SelStart = Len(TxtDircode.text)

   TxtDircode.Refresh
   MakeDoseUnitsLbl
   If RTrim$(TxtDircode.text) = "" Then
         StopEvents = True
         BlankWDirection WDir
         DirToForm False
         StopEvents = False
      End If

   If passlvl <> 3 Then ToggleRxLabel False     '!!** 02Mar99 CFY
   
End Sub

Private Sub TxtDirCode_keyDown(KeyCode As Integer, Shift As Integer)
'06Jun97 KR  Reistated CheckIssuetype in TxtDirCode_KeyDown
'07Jun97 KR  check the state of chkd after authorise - if no route
'            entered, allows the user to change this.
'27Jan98 ASC Toggle label if escape from directions.
'05Feb98 SF  Stop help screen loading after presing F1 in directions box
'17Dec98 TH  No Dose Checking if MDU or PRN in directions
'24Dec98 SF  Modified above mod
'05Feb99 SF  now only calls createlabel: if label has not been reused
'04Mar99 CFY Now if a key is pressed whilst the text in the directions box is
'            highlighted, the prescription is cleared.
'19Apr99 EAC Correct setting bits in l.flags now that bit 7 is used instead of bit6 for modified warnings
'13Sep00 JN  Added code to clear directions box and admin times on re-enter dose (event 46799)
'21Sep00 JN  moved directions clearing code to separate subroutine - ClearDirections (event 46799)
'13Feb02 TH  Reset Additional direction code here for next add of directions (#56294)
'11Mar02 TH  Added to clean out prn if Directions are blanked (#59130)
'11Mar02 TH  Use shift =2 input param as a flag to denote that dose range checking has already been done
'    "       i.e the script is being authorised by a prescriber (#49034)
'15Jun11 TH added switch to stop label editing (F0109779)

Dim slashpos As Integer, lastslashpos As Integer, currentdir As String
Dim TxtDirCodePar$, X%, abort$, chkd%
Dim intClearAdmin As Integer
Dim intflags As Integer                   '11Mar02 TH (#59130)
Dim blnDoseAlreadyChecked As Integer      '11Mar02 TH (#49034)

   blnDoseAlreadyChecked = False          '11Mar02 TH (#49034)
   If Shift = -2 Then                     '11Apr02 TH Replaced after discussion with CKJ
         blnDoseAlreadyChecked = True     '     "
         Shift = 0                        '     "
      End If
   
   If Len(TxtDircode.SelText) = Len(TxtDircode.text) Then
         TxtQtyPrinted = 0
         NewRx L, False, True
      End If
   
   Select Case KeyCode
      Case 27
         If passlvl <> 3 Then     '27Jan98 ASC
            ToggleRxLabel True
         End If
         SetFocusTo TxtPrompt
      
      Case 112    'Shift F1
         If Shift = 1 Then
            ChooseDirectionCode WDir.Code
            expanddir WDir.Code
            KeyCode = 0
         End If

      Case 40
         ChooseDirectionCode WDir.Code
         expanddir WDir.Code
         
      Case 8, 127
          If Len(TxtDircode.text) > 0 Then
                If Right$(TxtDircode.text, 1) <> "/" And InStr(TxtDircode.text, "/") Then
                       TxtDirCodePar$ = TxtDircode.text
                       RemoveUncommitedDirCode TxtDirCodePar$, True
                       TxtDircode.text = TxtDirCodePar$
                       TxtDircode.SelStart = Len(TxtDircode.text)
                    Else
                       TxtQtyPrinted = 0
                       NewRx L, False, True
                       '13Feb02 TH Reset Additional direction code here for next add of directions (#56294)
                       If RTrim$(d.dircode) <> "" And Left$(d.dircode, 1) = ">" Then
                             storeddirect$ = RTrim$(Right$(d.dircode, Len(d.dircode) - 1))
                          End If
                       
                       ChkPRN.Value = 0                 '11Mar02 TH Added to clean out prn (#59130)
                       L.Prn = False
                    End If
              End If
              
      Case 37
         TxtDircode.SelStart = Len(TxtDircode.text)
         
      Case 13
         If Right$(TxtDircode, 1) = "/" Then
               If Trim$(CmbRoute.text) = "" Then checkroute    '     "      '07oct03 CKJ
               ReDim doses!(6)
               For X = 1 To 6
                  doses!(X) = Val(TxtDose(X).text)
               Next
               
               Authorise chkd
               
               If passlvl <> 3 Then                                   '28May99 AE Added to prevent label showing when prescriber
                     If chkd Then            '07Jun97 KR  added check
                           WDir.directs = TxtDirections.text  'needed for createlabel      '07oct03 CKJ
                           If Not reusedLabel% Then createlabel 1, 0
                           memorytolabel
                           ToggleRxLabel True
                           'If TxtLabel(5).Visible Then SetFocusTo TxtLabel(5)  '26Jun98 ASC corrected was being moved up again later but this is quicker  '10Jun08 CKJ Removed as superceded by lines below
                           '27May08 TH Ported from v8 (F001810)
                           If L.IssType = "C" And passlvl <> 8 And TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then   '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
                              'TxtPrompt.SetFocus
                              SetFocusTo TxtPrompt       '10Jun08 CKJ changed to use safer version
                           ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
                              SetFocusTo TxtPrompt
                           ElseIf passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then '20Jul12 TH added (TFS 26712)
                              SetFocusTo TxtPrompt
                           Else
                              'TxtLabel(5).SetFocus
                              SetFocusTo TxtLabel(5)     '10Jun08 CKJ changed to use safer version
                           End If
                           '27May08 TH ------------
                           
                        End If
                  End If                                             '28May99 AE
               abort$ = ""
               CheckRxComplete chkd '16Nov98 ASC
               
               If chkd And Not blnDoseAlreadyChecked Then   '    "
                     'If ChkPRN.Value <> 1 Then    '17Dec98 TH Dont check dose for PRN
                     If L.dose(1) <> 0 Then                '24Dec98 SF replaced above IF
                           CheckDose doses!(), abort$ '26Jun98 ASC moved to make BNF work
                           If abort$ = "Y" Then    '26Jun98 ASC
                                 ClearDirections            '21Sep00 JN moved directions clearing code to new subroutine
                              End If               '    "
                           If Val(abort$) <> 3 And abort$ <> "" Then
''                              TxtDircode.SetFocus
                           End If
                        End If
                  Else
''                     TxtDircode.SetFocus
                  End If
            Else
               TxtDircode.text = TxtDircode.text & "/"
            End If
            
         End Select
   If fraLineColour.Visible Then fraLineColour.Refresh ' refresh frame !!**

End Sub

''Private Sub TxtDircode_KeyPress(KeyAscii As Integer)
'''7jul97 added to stop pings on pressing return
'''30Apr99 CFY/SF re-sets reusedlabel flag to force createlabel to fire if the directions change
''
''   Select Case KeyAscii
''      Case 13, 27: KeyAscii = 0
''      Case Else
''         reusedLabel% = False
''      End Select
''
''End Sub

''Private Sub TxtDircode_LostFocus()
'''27Feb97 KR Added !!**
'''04Apr97 KR Added check for empty directioncode text.
''
''   If Right$(TxtDircode.Text, 1) <> "/" And TxtDircode.Text <> "" Then
''         TxtDirCode_keyDown 13, 1
''      End If
''
''End Sub

Private Sub TxtDirections_Change()
   
   If Not StopEvents Then LabelAmended = True

End Sub

Private Sub TxtDose_Change(Index As Integer)

   If Not StopEvents Then
      If Not StopEvents And L.IssType = "C" Then CalcIV Index, False  '11Dec07 TH reinstated.
      If Val(TxtDose(Index).text) > 999999# Then       '20Jan95 CKJ was 9999
         popmessagecr ".", "Dose entered too Large ( >999,999 )"
         TxtDose(Index).text = ""
      End If
      MakeDoseUnitsLbl
      Calcqtys
      LabelAmended = True
   End If

End Sub

Private Sub TxtDose_DblClick(Index As Integer)
'09May96 KR Changed CmdDelete_Click to TxtDirCode
'15Oct98 TH Added code to clear unwanted default directions in prescribing
'15Oct98 TH Added code to stop dose and period boxes for creams in prescribing
   
''Dose is sent from prescription now
   
''   If Trim(TxtDose(index).Text) <> "" Then
''         TxtDirCode_keyDown 8, 0 '09May96 KR Added
''      End If
''
''   If index = 1 And passlvl = 3 Then
''      Blanklabel
''      BlankWDirection WDir
''      BlnkPrescribFrm True  '15Oct98 TH Added to clear unwanted default directions
''   End If
''   If Not UCase$(Trim$(d.DosingUnits)) = "APP" Or passlvl <> 3 Then             '15Oct98 TH STop dose for creams in prescribing
''         enterdose
''      End If                                                                     '    "
''   ChooseDirectionCode WDir.Code
''   expanddir WDir.Code
   
End Sub

Private Sub TxtDose_GotFocus(Index As Integer)

''   If fraIV.Visible And index > 1 Then
''         TxtDose(index).Enabled = False
''         popmessagecr "", "Only one dose per prescription is allowed for IV drugs"
''         TxtDose(1).SetFocus
''      Else
         TxtDose(Index).Enabled = True
         TxtDose(Index).SelStart = 0
         TxtDose(Index).SelLength = Len(TxtDose(Index).text)
''      End If

End Sub

Private Sub TxtDose_KeyPress(Index As Integer, KeyAscii As Integer)
'21Dec96 ASC
   
''   If Trim(TxtDose(index).Text) <> "" Then
''         TxtDirCode_keyDown 8, 0
''         TxtDose(1).SetFocus
''         KeyPad.LCD.Text = Chr$(KeyAscii)
''         KeyPad.LCD.SelStart = 1
''         enterdose
''         ChooseDirectionCode WDir.Code
''         expanddir WDir.Code
''      End If
   KeyAscii = 0

End Sub

''Private Sub TxtDrugCode_DblClick()
''
''   CmbDropDrugCode_Click (0)
''
''End Sub

''Private Sub TxtDrugCode_GotFocus()
'''12May99 CFY Trap to prevent any actions occuring if system is running in OCX mode and OCX action is modify.
''
''   If OCXlaunch() And GetOCXAction() = "M" Then TxtDircode.SetFocus
''
''   TxtDrugCode.Text = RTrim$(TxtDrugCode.Text)
''   TxtDrugCode.SelStart = 0
''   TxtDrugCode.SelLength = Len(TxtDrugCode.Text)
''   newstart = True
''   escaped = False
''
''End Sub

''Private Sub TxtDrugCode_KeyDown(KeyCode As Integer, Shift As Integer)
'''26Jan95 CKJ Removed use of variable 'alreadytheir' (sic)
'''01Sep95 ASC text blanked before auto adding
'''09Sep95 ASC/CKJ made = "" rtrim instead and only add d.dircode if first pass
'''16Feb96 EAC when reusing a previous prescription update the start and stop date
'''26Jul96 Kr  Correct invalid use of instr.
'''21Mar97 KR Added extra parameter to displaylabelandform
'''08May97 ASC Added protocol prescribing
'''26Aug97 CKJ Protocol: Added check if escd from listbox & closed objects after use.
'''            NB I recommend for testing only; limited error trapping & use of doevents
'''27Aug97 CKJ Protocols disabled temporarily for 8.0 (NZ)
'''10Oct97 ASC Added error checking on protocols
'''22Oct97 CKJ used to read 'OK to to add authorise...'
'''            Corrected some error handling round protocol.mdb
'''            Changed DoEvents to DoSaferEvents
'''            Opens protocol.mdb for read only
'''            NB Corrections incomplete - Protocols are NOT for release
'''30Oct97 CKJ Protocol handling improved but not yet completed
'''31Oct97 EAC Finish off improving Protocols section.
'''11Nov97 CKJ Amended unloading of list box
'''18Feb98 CFY Added block to handle display of blister box where appropriate
'''27Apr98 CFY Removed block of code which sets rx stop date to 6months from startdate regardless.
'''27Apr98 ASC/CFY Now doesn't check interactions when escaping from adding a new drug.
'''03Nov98 CFY Fix to stop the label re-loading after we have made a copy from history and initialised
'''            the relevent fields. This relies on setting the flag - FirstLoaded to False which will stop the truegrid
'''            change event from re-loading the label.
'''25Nov98 CFY/SF Added line to initialise l.lastqty when re-using items from history.
'''09Jan99 ASC removed declarations below since code moved to EnterDrug
'''Dim reuse%, msg$, ans$, Count%
'''Dim complete%, passcop%, Y%, i%      '22Oct97 CKJ
'''Dim drug$, keepisstype$, newRxallowed%, f%, found%, newdrug%, severity%, abort$, item$
'''Dim numoflabels%, expiry$, drugescaped%, startdt&, stopdt&, x%, done%
'''Dim desc$, dcop As drugparameters '26Jun98 ASC
''
''Dim dummy As Boolean
''
''   Select Case KeyCode
''      Case 13 'Return
''         EnterDrug False
''         KeyCode = 0
''         fraLineColour.Refresh
''         TxtDrugCode.Refresh
''
''      'Case 40 'KeyDown
''      '   CmbIssueType.SetFocus
''
''      Case 27 'Escape
''         TxtPromptSetFocus
''         KeyCode = 0
''
''      End Select
''
''End Sub

''Private Sub TxtDrugCode_KeyPress(KeyAscii As Integer)
''
''   Select Case KeyAscii
''      Case 13, 27: KeyAscii = 0
''      End Select
''
''End Sub

Private Sub TxtFinalVol_Change()
'10Oct96 ASC added stop events and format$
'28Aug98 TH  Changed format to stop stray decimal point

   If Not StopEvents Then
         If d.MaxInfusionRate > 0 Then  '17Dec96 ASC
               TxtFinalVol.text = Format$(d.MaxInfusionRate)      '07oct03 CKJ
            Else
               If Left$(TxtFinalVol.text, 1) = "." Then
                     TxtFinalVol.text = Format$(TxtFinalVol.text, "###0.##")   '24Sep98 TH Reinstated
                     TxtFinalVol.text = Format$(TxtFinalVol.text) '28Aug98 TH
''                     TxtFinalVol.SelStart = Len(TxtFinalVol.Text)
                  End If
            End If
         LabelAmended = True
      End If

End Sub

Private Sub TxtFinalVol_Gotfocus()

   CurrentPositionInTabArray = 14
   
   TxtFinalVol.SelStart = 0
   TxtFinalVol.SelLength = Len(TxtFinalVol.text)

End Sub

Private Sub TxtFinalVol_LostFocus()

''Static lastvol$            '!!** INADVISABLE! stops form unloading

   If Val(TxtFinalVol.text) > 9999 Then
         popmessagecr "!", "Volume too large; no change made"
         TxtFinalVol.text = lastvol$
         
      Else
         'If fraIV.Visible Then CalcIV 1, True
         CalcIV 1, True
         'formtolabel 0 '19May08 TH Added to reformat the label when vool has changed
      End If
   formtolabel 0 '19May08 TH Added to reformat the label when vool has changed
   lastvol$ = TxtFinalVol.text

End Sub

Private Sub TxtInfusionTime_Change()

   If Not StopEvents Then LabelAmended = True

End Sub

Private Sub TxtInfusionTime_GotFocus()

   CurrentPositionInTabArray = 15
   
   TxtInfusionTime.SelStart = 0
   TxtInfusionTime.SelLength = Len(TxtInfusionTime.text)

End Sub

Private Sub TxtLabel_Change(Index As Integer)
'03Jul97 ASC   - Wordwrapping now works correctly
'13Jun98 ASC copes with word wrapping when no spaces on line
'17Mar99 TH  Use second drug description if blank and move directions up
'18Mar99 TH  Retain word on next line if moving directions up
'18Mar99 TH  Fill Third line on label if blank with long directions

Dim temp%, numofspaces%, strlen%, X%, ans$, tabpos%
Dim tmp$, pos%, pos2%  '18Mar99 TH
Dim intloop As Integer '13May14 TH Added
Dim strAns As String, strMsg As String   '24Jun14 TH Added

   TxtLabelChanged = True

   'will always change for a new label as it is loaded!!!
   If Not StopEvents Then      ' 1Nov96 ASC stops recursion
         StopEvents = True     '28Jul97 CKJ moved from below
         If Index < 9 Then
               strlen = Len(TxtLabel(Index).text)
               tmp$ = TxtLabel(Index).text        '18Mar99 TH
               If strlen > 35 Then     'find the first space available back from end of line
                     If InStr(TxtLabel(Index).text, " ") Then  '13Jun98 ASC copes when no spaces on line
                           For X = strlen To 0 Step -1
                              If Mid$(TxtLabel(Index).text, X, 1) = " " Then Exit For
                           Next
                           If X <= 0 Then X = 34
                           ans$ = TxtLabel(Index).text
                           temp% = TxtLabel(Index).SelStart  'store position of curser (caret)
                           TxtLabel(Index).text = Left$(ans$, X - 1)
                           numofspaces% = 0
                           If Index < 5 Then
                                 'wrap text if necessary
                                 numofspaces% = -1 * ((Len(TxtLabel(Index + 1).text) > 1) And Len(LTrim$(Right$(ans$, strlen - X))) > 0)
                                 TxtLabel(Index + 1).text = LTrim$(Right$(ans$, strlen - X) & Space$(numofspaces%) & TxtLabel(Index + 1).text)
                                 TxtLabel(Index).SelStart = temp%
                               Else
                                 If TxtLabel(2).text = "" Or TxtLabel(3).text = "" Then   '18Mar99 TH Also Check third line
                                       If TxtLabel(2).text = "" Then
                                             For X = 3 To 5
                                                TxtLabel(X - 1).text = TxtLabel(X).text '  "
                                             Next
                                          Else
                                             For X = 4 To 5
                                                TxtLabel(X - 1).text = TxtLabel(X).text
                                             Next
                                          End If
                                       TxtLabel(5).text = ""
                                       pos2 = 35                             '18Mar99 TH Retain word on next line
                                       pos = 0
                                       Do
                                          If pos > 1 Then pos2 = pos
                                          pos = InStr(pos + 1, tmp$, " ")
                                       Loop While pos > 0
                                       tmp$ = Mid$(tmp$, pos2 + 1)
                                       TxtLabel(5).text = tmp$
                                       TxtLabel(5).SelStart = Len(tmp$)
                                       Index = 4
                                    Else
                                       '13May14 TH WE need to trap here and present the new screen
                                       
                                       'popmessagecr "!", "Insufficient room on label"
                                       If TrueFalse(TxtD(dispdata$ & "\Patmed.ini", "", "Y", "DefaultSecondLabelOption", 0)) Then
                                          strAns = "Y"
                                       Else
                                          strAns = "N"
                                       End If
                                       'Produce a suitable msg
                                       strMsg = "Insufficient room on label" & crlf & crlf & "Do you wish to print over two labels"
                                       'msg = TxtD(dispdata$ & "\rptdisp.ini", "RepeatCycles", msg, "DispenseRptCheckMsg", 0)
                                       askwin "?NO ROOM", strMsg, strAns, k
                                       If strAns = "Y" Then
                                          'clean the form
                                          'For intloop = 0 To 19
                                          'For intloop = 0 To 17 'Reserve 2 lines
                                          For intloop = 0 To 15 '05Aug14 TH
                                             frmExtraLabel.TxtLabel(intloop).text = ""
                                          Next
                                          'set the form
                                          For intloop = 0 To 5
                                             frmExtraLabel.TxtLabel(intloop).text = TxtLabel(intloop).text
                                          Next
                                          
                                          For intloop = 6 To 9
                                             'frmExtraLabel.TxtLabel(intloop + 10).text = TxtLabel(intloop).text
                                             'frmExtraLabel.TxtLabel(intloop + 10).ForeColor = TxtLabel(intloop).ForeColor
                                             'frmExtraLabel.TxtLabel(intloop + 8).text = TxtLabel(intloop).text            'Reserve 2 lines
                                             'frmExtraLabel.TxtLabel(intloop + 8).ForeColor = TxtLabel(intloop).ForeColor
                                             frmExtraLabel.TxtLabel(intloop + 6).text = TxtLabel(intloop).text            'Reserve 2 lines
                                             frmExtraLabel.TxtLabel(intloop + 6).ForeColor = TxtLabel(intloop).ForeColor
                                          Next
                                          StopEvents = False
                                          frmExtraLabel.Show 1, Me			'AS : MS_Edge_Fix for modal windows without an owner form
                                          'Keep form open and set the label extra flag
                                          'Set the lbl as extended
                                          If L.extralabel Then
''                                             For X = 0 To 9                                                  '08oct98 CKJ Added
''                                                TxtLabel(X).text = ""
''                                             Next
''                                             'setforecolour 0, True
''                                             'ans$ = RTrim$(labelline$(0))
''                                             'If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
''                                             'txtUC("TxtLabel", 0).text = LTrim$(txtUC("TxtLabel", 0).text & " " & ans$) '   "
''                                             'txtUC("TxtLabel", 0).Refresh
''
''                                             TxtLabel(2).text = "This is an Extended Label"
''                                             TxtLabel(2).Refresh
''
''                                             TxtLabel(3).text = "Click here to view Label"
''                                             TxtLabel(3).Refresh
''
''                                             'For X = 6 To 9
''                                             '   setforecolour (X), True
''                                             '   ans$ = RTrim$(labelline$((X + 10)))
''                                             '   If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
''                                             '   txtUC("TxtLabel", (X)).text = LTrim$(txtUC("TxtLabel", (X)).text & " " & ans$)  '   "
''                                             '   txtUC("TxtLabel", (X)).Refresh
''                                             'Next
''                                             setforecolour 9, True, False
''                                             'ans$ = RTrim$(labelline$(19))
''                                             ans$ = RTrim$(labelline$(17)) 'Reserve 2 lines
''                                             If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
''                                             TxtLabel(9).text = LTrim$(TxtLabel(9).text & " " & ans$) '   "
''                                             TxtLabel(9).Refresh
                                             setExtendedLabelWYSWY
                                          End If
                                       End If
                                    End If
                               End If
                         End If
                     'move cursor to the next line and to the end of he wrapped text
                     If TxtLabel(Index).SelStart = Len(TxtLabel(Index).text) And TxtLabel(Index + 1).Visible Then
                           SetFocusTo TxtLabel(Index + 1)
                           tabpos = temp% - Len(TxtLabel(Index).text) - 1 '7Jul97 ASC stops negative positions for cursor
                           If tabpos < 0 Then tabpos = 0
                           TxtLabel(Index + 1).SelStart = tabpos
                        End If
                  End If
            End If
         
         StopEvents = False
      End If
         
   TxtLabel(Index).FontBold = False
   If Len(Trim$(TxtLabel(Index).text)) < 23 And Index > 0 And Index < 7 Then
         TxtLabel(Index).FontSize = 12
      Else
         TxtLabel(Index).FontSize = 10
      End If
   
End Sub

Private Sub TxtLabel_DblClick(Index As Integer)
'15Jun11 TH added switch to stop label editing (F0109779)
Dim intloop As Integer
Dim ans$

''   If L.extralabel And Index > 0 And Index < 6 Then
''      'Show form
''      'For intloop = 0 To 19
''      For intloop = 0 To 17  'Reserve 2 lines
''         setforecolour intloop, True, True
''         'Remove the prefixes
''         ans$ = RTrim$(labelline$(intloop))
''         If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
''         'txtUC("TxtLabel", 9).text = LTrim$(txtUC("TxtLabel", 9).text & " " & ans$) '   "
''
''         frmExtraLabel.TxtLabel(intloop).text = ans$
''      Next
''      frmExtraLabel.Show 1                                                                   '        "
''      Exit Sub                                                                         '        "
''   End If
   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                               '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then    '         "
         Exit Sub                                                                         '         "
      End If                                                                              '         "
   ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
      Exit Sub
   End If
   '27May08 TH -----------
   
   '20Jul12 TH Added (TFS 26712)
   If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
      Exit Sub
   End If
   '20Jul12 TH --------
   If Not L.extralabel Then '01Jul14 TH Added
      Select Case Index
         Case 0
            ChooseInstructionCode
         Case 6 To 8
            ChooseWarningCode
      End Select
   End If
End Sub

Private Sub TxtLabel_GotFocus(Index As Integer)
'08Apr97 KR added dispens Setfocus to recapture input focus
'08May97 KR changed.  Check form  handle before call setfocus event to prevent
'illegal function call if a modal form showing on top of dispens frm e.g. a message box
'08Apr99 TH  Moved Wardchange call to click event to prevent multiple firing
'15Jun11 TH added switch to stop label editing (F0109779)

''Dim activecolour As Long

CurrentPositionInTabArray = Index + 4

Dim dd$

   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                               '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then    '        "
            Exit Sub                                                                      '        "
         End If                                                                           '        "
   ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
      Exit Sub
   End If                                                                                 '        "
   '27May08 TH ----------
   
   '20Jul12 TH Added (TFS 26712)
   If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
      Exit Sub
   End If
   '20Jul12 TH --------
   
   
''   currentline = index
   If Index = 9 Then
         SetFocusTo TxtPrompt
         Exit Sub
      End If
      
    SetAttemptedlabelEdit True '23Jul12 TH Added
    
''   If Screen.ActiveForm.hWnd = TxtLabel(1).hWnd Then !!**
''         If index < 1 Then TxtLabel(1).SetFocus
''         If index > 5 Then TxtLabel(5).SetFocus
''      End If
   
''   infobarstatus 4
   dd$ = TxtLabel(Index).text
   TxtLabel(Index).text = RTrim$(dd$)
   
''   activecolour = TxtLabel(Index).ForeColor
''
''   '5Oct96 ASC colour choicmoved to separate form
''   Select Case activecolour
''      Case Black:  FrmColour.OptColour(0).Value = True
''      Case Red:  FrmColour.OptColour(1).Value = True
''      Case Blue:  FrmColour.OptColour(2).Value = True
''      Case Magenta:  FrmColour.OptColour(3).Value = True
''      Case Yellow: FrmColour.OptColour(4).Value = True
''      Case Green:  FrmColour.OptColour(5).Value = True
''      End Select
   
   '08Apr97 KR added setfocus because the setting the options on the colour
   'form initiate a click event, resulting in the dispensing form losing the focus.
   'Dispens SetFocus
   '08May97 KR changed.  Check form  handle before call setfocus event to prevent
   'illegal function call if a modal form showing on top of dispens frm e.g. a message box
   '
''   'If Screen.ActiveForm.hWnd = dispens hWnd Then dispens SetFocus
''   On Error Resume Next     '26Jun98 ASC
''   If Screen.ActiveForm.hWnd = FrmColour.hWnd Then Me.SetFocus     '16May97 KR Changed.
''   On Error GoTo 0

   TxtLabelChanged = False
      
End Sub

Private Sub TxtLabel_KeyDown(Index As Integer, KeyCode As Integer, Shift As Integer)
'28Jul97 CKJ Moved Case 38 & 40 from the KeyUp event, and added KeyCode=0
'            This prevents the cursor wandering sideways during vertical movement.
'16Feb00 AE  Code to show pop-up menu if using highlightdescriptionlines mod.
'15Jun11 TH added switch to stop label editing (F0109779)

Dim found&, startpos%, ans$, carry$, linx%, done%, X%, splitpoint%

   If L.extralabel And Index > 0 And Index < 6 Then
      KeyCode = 0                                                                      '        "
      Exit Sub                                                                         '        "
   End If
   
   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                               '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then    '        "
         KeyCode = 0                                                                      '        "
         Exit Sub                                                                         '        "
      End If                                                                              '        "
   ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
      KeyCode = 0
      Exit Sub
   End If                                                                                 '        "
   '27May08 TH --------
   
   '20Jul12 TH Added (TFS 26712)
   If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
      KeyCode = 0
      Exit Sub
   End If
   '20Jul12 TH --------
   
   Select Case KeyCode
      Case 38     'Key_up
         If Index > 1 Then
               KeyCode = 0    '28Jul97 CKJ Added
               SetFocusTo TxtLabel(Index - 1)
            End If
            
      Case 40     'Key_Down
         KeyCode = 0          '28Jul97 CKJ Added
         If Index < 5 Then
               SetFocusTo TxtLabel(Index + 1)
            Else
               SetFocusTo TxtPrompt
            End If
            
      Case 13 'Return
         found& = 0
''         AddDirCodeToLabel index, found&            '09May05 Removed ability to add direction codes here (requested by AS)
         If found& = 0 Then
               If Index = 5 Then
                     SetFocusTo TxtPrompt
                  End If
               startpos = TxtLabel(Index).SelStart
               ans$ = TxtLabel(Index).text
               ans$ = RTrim$(ans$)
               If Len(ans$) - startpos > 0 And Index < 5 Then
                     carry$ = Right$(ans$, Len(ans$) - startpos)
                     ans$ = Left$(ans$, startpos)
                     rightuprite ans$
                     TxtLabel(Index).text = ans$
                     linx = 0
                     done = True
                     Do
                        If Len(carry$) And Index + linx < 5 Then
                              done = False
                              linx = linx + 1
                              ans$ = RTrim$(TxtLabel(Index + linx).text)
                              'plingparse ans$, "°"
                              ans$ = RTrim$(ans$)
                              ans$ = carry$ + " " + ans$
                              If Len(RTrim$(ans$)) > 35 Then
                                    X = 0
                                    Do
                                       splitpoint = X
                                       X = InStr(splitpoint + 1, ans$, " ")
                                    Loop Until X > 35 Or X = 0
                                  Else
                                    If Len(ans$) < 23 Then rightuprite ans$
                                    done = True
                                    TxtLabel(Index + linx).text = LTrim$(ans$)
                                    Exit Do
                                 End If
                              carry$ = Right$(ans$, Len(ans$) - splitpoint)
                              TxtLabel(Index + linx).text = RTrim$(LTrim$(Left$(ans$, splitpoint)))
                              If Len(RTrim$(TxtLabel(Index + linx).text)) < 23 Then
                                    ans$ = RTrim$(TxtLabel(Index + linx).text)
                                    rightuprite ans$
                                    TxtLabel(Index + linx).text = LTrim$(ans$)
                                 End If
                           End If
                     Loop Until Index + linx > 4 Or done
         
                     If Not done Then popmessagecr "WARNING", "No room for " & carry$
                  End If
            End If

      Case 27 'Escape
         SetFocusTo TxtPrompt

      Case KEY_F2   'Shift + F2
         If Shift = 1 And Index > 0 Then
            ShowColourAndDescriptionSplitMenu Index, False
         End If

      End Select

End Sub

Private Sub TxtLabel_KeyPress(Index As Integer, KeyAscii As Integer)
'15Jun11 TH added switch to stop label editing (F0109779)
   
   If L.extralabel And Index > 0 And Index < 6 Then
      KeyAscii = 0                                                                      '        "
      Exit Sub                                                                         '        "
   End If
   
   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                               '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then    '           "
         KeyAscii = 0                                                                     '           "
         Exit Sub                                                                         '           "
      End If                                                                              '           "
   ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
      KeyAscii = 0
      Exit Sub
   End If                                                                                 '           "
   '27May08 TH ------------
   
   '20Jul12 TH Added (TFS 26712)
   If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
      KeyAscii = 0
      Exit Sub
   End If
   '20Jul12 TH --------
   
   Select Case KeyAscii
      Case 13, 27: KeyAscii = 0
      End Select

End Sub

Private Sub TxtLabel_KeyUp(Index As Integer, KeyCode As Integer, Shift As Integer)
'22Jun96 ASC Took procedure from DOS release and made delete work by adding keycode 46 to word wrap case statemeent
'28Jul97 CKJ Moved Case 38 & 40 to the KeyDown event
'8Aug97 CKJ/KR Added check to prevent 1st line of warnings moving upwards
'15Jan99 EAC Enhancement 603

''Static tempforundel$                        '!!** NOT ADVISABLE! stops the form unloading
Dim ans$, GlueText%, X%, splitpoint%

   If L.extralabel And Index > 0 And Index < 6 Then
      KeyCode = 0                                                                      '        "
      Exit Sub                                                                         '        "
   End If
   
   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                                  '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then       '       "
         KeyCode = 0                                                                         '       "
         Exit Sub                                                                            '       "
      End If                                                                                 '       "
   ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
      KeyCode = 0
      Exit Sub
   End If                                                                                    '       "
   '27May08 TH --------------
   
   '20Jul12 TH Added (TFS 26712)
   If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
      KeyCode = 0
      Exit Sub
   End If
   '20Jul12 TH --------

   If KeyCode = 127 And TxtLabel(Index).SelStart = Len(TxtLabel(Index).text) Then
         TxtLabelChanged = False
      End If

   If Not TxtLabelChanged Then
         Select Case KeyCode
''            Case 117    ' F6 delete
''               tempforundel$ = TxtLabel(index).Text
''               TxtLabel(index).Text = ""
''               ans$ = TxtLabel(index).Text
''               rightuprite ans$
''               TxtLabel(index).Text = ans$
''               LabelAmended = True
''
''            Case 118    ' F7 Un-delete
''               TxtLabel(index).Text = tempforundel$
               
''09May05 Removed ability to add direction codes here (requested by AS)
''            Case 112    ' ^F1
''               SelectDirs index     '2Feb95 CKJ added index
            
            'Case 38     'Key_up
            '   If Index > 1 Then TxtLabel(Index - 1).SetFocus
            
            'Case 40     'Key_Down
            '   If Index < 5 Then
            '         TxtLabel(Index + 1).SetFocus
            '      Else
            '         If passlvl = 3 Then TGLabelList.SetFocus  Else TxtPromptSetFocus
            '      End If
            
            Case 8, 127, 46  'Back space/Delete  N.B. delete=46 in VBwin
               If Index < 5 Then
                  If TxtLabel(Index).SelStart = Len(TxtLabel(Index).text) And Index > 0 Then
                        Index = Index + 1
                        GlueText = True
                     End If
   
                  If TxtLabel(Index).SelStart = 0 And Index > 1 Then
                        GlueText = True
                     End If
      
                  If GlueText Then
                     ans$ = TxtLabel(Index - 1).text
                     'plingparse ans$, "°"
                     ans$ = RTrim$(ans$)
                     If Len(ans$) Then ans$ = ans$ + " "
                     ans$ = RTrim$(ans$ & TxtLabel(Index).text)
                     If Len(ans$) > 35 Then
                        X = 0
                        Do
                           splitpoint = X
                           X = InStr(splitpoint + 1, ans$, " ")
                        Loop Until X > 36 Or X = 0                                        '12Oct05 CKJ was 35
'                        TxtLabel(index).Text = Right$(ans$, Len(ans$) - splitpoint)
'                        TxtLabel(index - 1).Text = Left$(ans$, splitpoint)
                        TxtLabel(Index).text = Mid$(ans$, splitpoint + 1)                 '   "        functionally unchanged
                        TxtLabel(Index - 1).text = Left$(ans$, splitpoint - 1)            '   "        don't include the space
                     Else
                        KeyCode = 0    '28Jul97 CKJ Added
                        TxtLabel(Index).text = ""
                        TxtLabel(Index - 1).text = ans$
                        SetFocusTo TxtLabel(Index - 1)
                     End If
                  End If
               End If

            Case Else 'ASC 03Nov95
               LabelAmended = True
               
            End Select
      End If
   TxtLabelChanged = False
   
End Sub

Private Sub TxtLabel_LostFocus(Index As Integer)
'04Jun97 KR Added call to inforbarstatus so that correct bar gets displayed.
'19Jan99 EAC ensure colour information is saved to labelline as well
Dim ctrlhwnd As Integer, ans$
Dim temp$, tempval&                             '19Jan99 EAC added
   
   ans$ = TxtLabel(Index).text
   rightuprite ans$
   TxtLabel(Index).text = ans$
   
   '19Jan99 EAC Enhancement 603
   temp$ = ""
   tempval = StoredColour((TxtLabel(Index).ForeColor))
   If tempval > 0 Then
      temp$ = Trim$(Format$(tempval)) & "!"
   End If
   If Not L.extralabel Then labelline$(Index) = temp$ & RTrim$(ans$)     '20 Jan95 CKJ '17Jun14 TH Added fencepost

End Sub

Private Sub TxtLabel_MouseDown(Index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)
'16Feb00 AE  Written
'Show pop-up menu on mouse right click on highlighted direction text.
'This will only be active if the ini setting HighlightPMRDescriptionLines=Y
'is present in patmed.ini. If not, DescriptionSplitLine will return 0,
'hence the criteria for showing the menu will never be fulfilled.
'Notice the slight fiddle required to avoid the inbuilt context menu
'appearing first.
'-------------------------------------------------------------------------
'19Jul11 TH Disable this if required (F0123219)

Dim iBut As Integer

   '19Jul11 TH Disable this if required (F0123219)
   If L.IssType = "C" And passlvl <> 8 Then                                                  '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then       '       "
         If button = 2 Then
            LockWindowUpdate TxtLabel(Index).Hwnd
            TxtLabel(Index).Enabled = False
            popmessagecr "", "This action has been disabled"
            TxtLabel(Index).Enabled = True
            LockWindowUpdate 0
         End If
         button = 0
         Exit Sub                                                                            '       "
      End If                                                                                 '       "
   ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
      If button = 2 Then
         LockWindowUpdate TxtLabel(Index).Hwnd
         TxtLabel(Index).Enabled = False
         popmessagecr "", "This action has been disabled"
         TxtLabel(Index).Enabled = True
         LockWindowUpdate 0
      End If
      button = 0
      Exit Sub
   End If
   '19Jul11 TH End
   
   '20Jul12 TH Added (TFS 26712)
   If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
      If button = 2 Then
         LockWindowUpdate TxtLabel(Index).Hwnd
         TxtLabel(Index).Enabled = False
         popmessagecr "", "This action has been disabled"
         TxtLabel(Index).Enabled = True
         LockWindowUpdate 0
      End If
      button = 0
      Exit Sub
   End If
   '20Jul12 TH --------
   
   If Index > 0 Then      'Set button to 0 and disable text box to prevent the inbuilt context menu from firing.
         iBut = button
         button = 0
         If iBut And RIGHT_BUTTON Then
''            TxtLabel(index).Enabled = False         '!!** actually needed!
            TxtLabel(Index).Enabled = True
            ShowColourAndDescriptionSplitMenu Index, False
         End If
      End If

End Sub

''Private Sub TxtNodPrescribed_GotFocus()
''
''   UCTextBoxHiLight
''
''End Sub

Private Sub TxtPrompt_Change()

   labpromptchanged = True
   
   'Store the action type e.g. P,N,S ect. to use with automation.
''   If (Len(Trim$(TxtPrompt.Text))) = 1 Then patmedaction = TxtPrompt.Text Else patmedaction = ""

End Sub

Private Sub TxtPrompt_GotFocus()
'20Dec95 CKJ Use ASCver from version.inc unless over-ridden
'08May97 KR Added check for active form to prevent illegal function call if modal form loaded.
'10May97 KR removed infobarstatus 3.  Now being set in onloadingdispens
'26Jan97 ASC must be a cascading event causing reseting of infobarstatus (needs looking at further but fixed for now)

''Dim expiry$

CurrentPositionInTabArray = 0

'>>   If TGLabelList.Rows > 0 And Firstdisplay Then      '07oct03 CKJ
'>>         TGLabelList.RowIndex = 1      '07oct03 CKJ
''         DisplaytheLabAndForm 1, 0, k.escd, expiry$, 0
''         LabelAmended = False        '2Feb95 CKJ added
'>>      End If
''   Firstdisplay = False
   setP
'>>   infobarstatus 3 '26Jan97 ASC
   If pid.recno > 0 Then               '08Nov05 CKJ Was patno&
'**!!**   needs implementing
'>>         If Not newstart And TGLabelList.Rows = 0 And MnuHistory.Checked = 0 Then '21May95 ASC Labf&<>0 added
''               L.IssType = pid.Status
''               CheckIssType 2
''               If Screen.ActiveForm.hWnd = UserControl.hWnd Then CmbIssueType.SetFocus '08May97 KR Added
''               newstart = True
'>>            End If
      End If

End Sub

Private Sub TxtPrompt_KeyDown(KeyCode As Integer, Shift As Integer)
'07Jun97 KR Changed the way escape handled - prevents user having to press escape twice to exit the program
'09Jul98 CFY Corrected problem which could potentially occur when exiting when the label has not
'            been saved.
'02Oct98 CFY Code added to trap keyup and keydown actions from happening when in OCX mode.
'02Feb99 EAC Stop movement of cursor when OCX action = M
'22Sep99 CFY Removed lines which hide the picture frames when unloading dispens form.
'25Aug99 CFY Now prevents OCXStatus being overwritten if already set.
'29Sep00 CFY Re-instated original teamwork code so that closeing of pigeon holes will now fire
'08May01 CKJ Add record to pigeon.mdb at same time as pigeon.asc file
'29Jun01 CKJ Added message if ticket number has not been successfully allocated
'15Oct01 TH/EAC  Ensure OCX status is set OK on Discontinue to allow correct closure of form later (#54921)

Dim ward$, itemstodo%, itemsdone%, itemstofollow%, patnum&
Dim msg$, ans$
''Dim labftemp&
Dim intCloseHole As Integer
Dim intTicketNum As Integer
Dim PatientName As String

''   labftemp& = Labf&
   
   Select Case KeyCode
      Case 13 'Return
         nextchoice$ = TxtPrompt.text
      
      Case 27 'Escape
         QuerySave ans$
         'If ans$ = "Y" Then  'anything needed?
         '   End If
         'OnClosingDispens True 'maybe wanted?
         UserControlEnable False
         DoAction.Caption = "RefreshView-Inactive"       'clunky but works

      End Select

End Sub


Private Sub TxtPrompt_KeyPress(KeyAscii As Integer)

   Select Case KeyAscii
      Case 13, 27:    KeyAscii = 0
      Case 97 To 122: KeyAscii = KeyAscii - 32
      Case 18
      End Select

End Sub

Private Sub TxtPrompt_KeyUp(KeyCode As Integer, Shift As Integer)
' Print Amend New Delete Copy Save Esc
'9Feb95 CKJ Mod calling Patlabel
'10Jan96 EAC Correct index so that when a patient with no PMR is displayed
'            the program does not crash
'16Jan96 EAC Deleteflag renamed to Deletetohistory which is a new common variable
'27Jun96 ASC Stopped anything bad if patient not loaded
'31Oct96 KR  added check for valid ward & consultant with new patient
'15Jan97 EAC moved ForwardLabel and ReverseLabel to only occur if CIVASDryLabel
'18Feb97 KR  Removedqty! = dp!(Numoflabels * qty!) as now use showlabelscalulator
'21Mar97 KR  Added duplicates to DisplaytheLabelAndForm
'            Moved printing after issue
'08Apr97 KR  Prevent user issueing and printing if no drug selected.
'06May97 KR  Add CRLF to expiry message in confirm to make message neater.
'04May97 KR  Ensured that CIVAS display issue quatity & actual issue qty the same.
'04Jun97 KR  Moved setting of l.dispid from after to issueing to savelabel - never set if just save label.
'            Sorts out the problem with kings and teamwork print 2 initials on label.
'04jun97 KR  Added resetting of quantity labels in dispensing form when option = "N"
'06Jun97 KR  added Forwardlabel and reverselabel with CIVAS printing
'12Jun97 CKJ/KR removed call to sendtopump
'20JUn97 KR  Added setting of prescription id just prior to issuing and printing
'            so that for CIVAS labels, the uniqueId can be printed on the label.
'04Jul97 KR  Fixed bug that made 2 labels disappear from the truegrid if one was deleted.
'11Jul97 KR  Now Calls DisplaytheLabandForm because of the new ability to change label types on the fly.  With out them, the following sequence of events
'            would save the label but not the drug description: if enter new rx, then enter N instead of saving it
'            (s) or  printiing it (p), no description saved in pmr line.
'29Aug97 EAC Added ini file setting to allow printing of patient labels for  manufactured items
' 4Sep97 CKJ Expanded above fix for batch formulae
'18Nov97 CFY Prompt added before adding patients own medication
'22Jan98 CKJ Added PMR debug on shift F3
'23Jan98 CKJ Added option ? to NADSP; a small popup help box
'            corrected ToggleRxLabel; previously F5 was needed twice on occasions
'05Feb98 CFY Extra condition to stop CheckRxComplete firing when printing ad-hoc free format labels
'16Feb98 CFY Now blanks label after abandoning saving of a record.
'27Aug98 TH  Added Reprint facility for labels and manuf worksheets if CIVAS
'17Sep98 CFY Now saves the label before printing. This creates a rx number that is used
'            for generating reprint filenames.
'24Sep98 TH  Changed formats
'02Oct98 CFY Code added to trap Pageup and Pagedown actions from happening when the application has
'            been launched from the OCX
'14Oct98 TH  In prescribing now skips dose entry screen if creams.
'15Oct98 TH  Skip period entry screen in prescribing if creams
'19Nov98 CFY Changed order in which labels are printed. See comment in formula.bas for explaination.
'15Dec98 SF  added calls to patient billing
'18Jan99 EAC Enhancement 603
'11Nov98 CFY Removed variable declaration 'deletetohistory%' as this needs to be global in order
'            for putlabel in patmed.bas to work!!
'05Feb99 SF  now only calls createlabel: if label has not been reused
'24Feb99 SF  updated paraemeter calls to PrintWorkLabel: and PromptForWrkSht: subs
'15Mar99 SF  if issuing to  ward L type then ensure a wardcode is setup
'15Mar99 SF  if in repeat dispensing mode then when saving a label the allows user to change number of labels to print for that issue
'31Mar99 SF  now only calls SetNumberOfRptLabels: if repeat dispensing and nothing has been issued
'06Apr99 TH  Added code to handle bag labels
'24May99 CFY Mods to allow return of CIVAS items
'04Jun99 SF  added patient billing mods
'08Jun99 TH  Reset storeddirect$ to ensure extra directions are prompted (merge from 8066 12feb99)
'25Jun99 CFY Detects if reprint function is on or off and responds to the 'R' command accordingly
'28Jul99 AE  Mod to allow batch manufactured products to be issued as for a normal drug.
'02Aug99 AE  Fix to Issue / Return manufactured items
'03Aug99 AE  Corrected above mod
'06Sep99 CFY Change to fucntionality fucntionality of Extra CIVAS labels. Can now have extra labels
'             either per batch or per dose.
'02Dec99 SF added to clear PBS items on a label re-print
'17Jan00 SF now warns if label rINN flag set on an amend and print, then clears when the label has been saved
'16Feb00 AE  Replaced a section of code with a procedure call for neatness.
'03Mar00 TH Added logging code to try and trap mismatched returns
'20Mar00 CFY Line added to stop issue occuring if user has escpaed from the CIVAS issue screen.
'20mar00 ATW Added two "reuselabel%=false" to prevent labels that have been called from history being incorrect when cons/ward is changed mid 'scrip
'30Mar00 AE  Added workingdate$/time$ as parameters to GetLabelExpiry as are needed elsewhere
'19May00 AE/MMA Prevent blank lines in PMR
'02Aug00 MMA Added: Global update for Teamwork
'24Aug00 JN  Checks Pharmacc is turned off before incrementing l.batchnumber
'02Feb99 EAC Added CancelTransactions for OCX issueing
'            Prevent cursor movement in PMR for OCX Action = "M" (Amend Mode)
'            Prevent use of certain functions when OCX Action = "E" (Enquiry mode)
'01Mar99 EAC Hong Kong E7 mods
'14Sep00 JN  F5 pressed: existing routine replaced by FlipFlopRxView, now powered by F5 press on Menu Bar
'18Oct00 JN  Now only increments l.batchnumber when an actual issue takes place (Issued = TRUE)
'16Nov00 SF  allows reprint of repeat authorisation form for PBS
'20Nov00 SF/CFY mods to only increment batch number if not been done by patient billing
'29May01 TH  Prevent amendment if Label not yet saved (#52393) - could lead to translog entry but no PMR record (label)
'19Jun01 TH  Added call to CanTheLabelBeSaved to check the label shouldnt "bounce" and not be saved PRIOR to the actual issue (#52393)
'16Jul01 TH  Added call to present label to set labf to ensure Amend is allowed
'             for existing item when first loading Dispens (#54003)
'18sep01 ckj Only call CanTheLabelBeSaved if there is a drug code, ie not a free format label
'            Similarly, only ask batchno & expiry if there is a drug code, ie not a free format label   (#55128)
'24sep01 CKJ The entire prescribing Wizard block had been commented out, no date/initials/reason
'            - reinstated for testing
'01Sep01 TH  If new label cannot be created (>50 meds) dont continue with a new issue (#54440)
'08oct01 CKJ Removed prescribing wizard block. Not used since Jan99 and now not compatible with main code.
'27Nov01 CKJ Set to use deferred printing to keep disk files in sync even if printing causes a GPF
'13Feb02 TH Try to prevent the possibility of previous directions persisting on Label when amending item using the mouse to
'           avoid the normal direction validation before saving - RAH Strategy (#58291)
'13Feb02 TH Added extra handling of the GlobalManufBatchNum variable which can get onto labels if user has previously been making items (#47263)
'13Feb02 TH moved back despite above (no relevant comments found in formula.bas) - print labels before wrksheet (#50210)
'13Feb02 TH Added suppression of "cant amend unsaved label" msg on ini (#55838)
'15Feb02 TH  Removed dim of deletetohistory variable as this should be global. Making this local meant the values
'            were not correctly sent to putlabel. Rem above states this was removed 11Nov98 but it was still active (#54264)
'27Feb02 TH Moved hot key for Instructions to Ctrl-U (#56150)
'04Mar02 TH Added New section for calling POF reprints for MOJ (type 3) (#MOJ#)
'19Jul02 SF/TH changed parameter to 3 on CheckIssueType to ensure labelamended flag not set
'30Sep02 ATW Case "P" added clear of lPatientCost element to prevent cost spilling onto multiple labels
'01Oct02 TH  Number of mods to handle CIVAS/Manufacturing issues;
'            Allow for cancel at worksheet/batchno prompts.
'            Process only those things required (wrksheet/labels/issue or combination thereof)
'            Reset txtqtyprinted to force prompt of dose entry box on subsequent issue of line
'            Get new stored expiry of expiry is blank (needed for non-issue prints)
'            Use the number of labels + extralabels from formula.mdb if no dose is explicitly entered
'            Use the qty from the issue calculator/box if no dose explicitly entered for calculating wrksheets
'07Oct02 TH  If the expiry date is entered directly by the user then user this on the wrksheet and labels rather than system calcualted expirys
'            Then ensure this heap entry is blanked for the next pass
'21Oct02 TH  Added Parameter to PromptBatchNumber call
'13Nov02 CKJ Added dummy param to PrintWorkLabel
'06Jun03 TH  Added mod to use label values from formula mdb (if set) to calc labels for printing on CIVAS issue. (#68679)
'31Jan03 TH (PBSv4) MERGED
'31Jan03 TH New PBS pre issue checks added
'           Various PBS variables reset for issue
'           Allow TxtQtyPrinted to be ignored for PBS (as Qtys come from Schedule, not entered by user)
'           Added update of PBS issue panel after issue\new\save etc.
'16May04 TH Added terminal based setting to enable rxing check : this will force the user back into the rxing
'           process with a warning rather than just state the prescription has not been saved - for UMMC, classic rxing (#65365)
'16May04 TH Mod to retain modified warning/instr codes (inc blanks) during the ammendment of a label (#67284)
'17May04 TH Added mod to check if there is sufficient pmr space for a new label as the user begins the process Enh1532
'20May08 CKJ Robot printing; clear messageid & section, add () to preserve NumOfLabels
'25sep08 CKJ Moved SetFocus call below deferred printing (F0028203)
'07Apr10 AJK Added HILaunchLeaflet call (F0072542) Ported from v8
'15Feb11 TH  Call to display interface prescription notes if too big for display - Chemocare (F0036868)
'08Jan14 TH  Added call to savelabel on "I" from prompt because if this is not present then we may not get label ID in the translog or Billing transaction (TFS 81381)
'12Jun15 TH  Ensure pid.ward is update by user selecting correct cost centre (TFS 58926)
'28Jul15 TH  Ensure WYSWYG is updated if ward is swapped (TFS 123260)
'17Aug15 TH  Added ucase and trim (TFS 123260)
'15Sep15 TH  Mod to scrape dose for custom frequency (as it does for Stat) when CIVAS (TFS 129498)
'06Jan16 TH  Mod to installment disp so decrement/decrement is by label NOT rx to allow split dose installment dispensing (TFS 138797)
                                 
Dim Action%, toissue%, done%, Choice$, returned%, complete%, chkd%, DailyDoses!, mancost!
Dim NumofLabels%, whole$, ans$, WorkingDate$, WorkingTime$
Dim expiry$, dircode$, formulafound%, Issued%, UnitCost$, batchnumber$, duplicates%
Dim lcount%, dat$, highlight%, X%
Dim msg$
''Dim labftemp&
Dim result$
Dim inttmpNumofLabels As Integer

Dim PatsPerSheet%, Layout$
Dim OK As Integer
Dim costcentre$
Dim bagLabel%, i%
Dim success%
Dim PatBillStub%
Dim BatchProduct As Boolean
Dim ExtraLabels%, ExtraLabelsBatch%, ExtraLabelsDose%
Dim logtext$, PMRItem$, Rtemp As filerecord
Dim intLabelok As Integer
Dim strTmpExpiry As String
Dim intFormulaNumofLabels As Integer
Dim intFormulaExtraLabels As Integer
Dim blnPBSPassed As Integer
Dim dummy As Integer
Dim strMsg As String '17May04 TH Added
Dim robotlabelID As Long         '12oct06 CKJ
Dim AltLabelContext As String    '28Jun12 CKJ

Dim rsFormula As ADODB.Recordset
Static blnNonCIVASIssue As Boolean '30May08 TH Added
Dim blnAllowSaveforHistory As Boolean '15Jan10 TH Added (F0072599)
Dim strCaption As String '16Feb11 TH Added (Chemocare)

Dim strParams As String             '15Aug13 TH Doc (TFS 70134)
Dim rsRptDisp As ADODB.Recordset    '  "
Dim strPrescriptionExpiry As String
Dim intTotalRepeats As Integer
Dim intRepeatsRemaining As Integer
Dim intRepeats As Integer
Dim ndbd&
Dim strAns As String
Dim lngOK As Long
Dim sglRepeatQuantity As Single
Dim lngFoundSup As Long             '30Jun17 TH Added
Dim lclsupWard As supplierstruct    '   "

   
''   labftemp& = Labf&
   blnAllowSaveforHistory = False '15Jan10 TH Added (F0072599)
   SetFromTxtPromptKeyUp   '17Nov05 TH Added '22May08 TH Ported from v8

   Do
      If pid.recno > 0 And Len(nextchoice$) = 0 And Not labpromptchanged Then            '08Nov05 CKJ Was patno&
            done = True
            Select Case KeyCode
''               Case 33  'Page-Up
''               Case 34  'Page-Down
               
               Case 112 'F1 help   16Feb95 CKJ
                  Select Case Shift
                     Case ALT_MASK
''                        popmessagecr "#", PatientDebug()                '06sep99 CKJ added
                     End Select
               
''               Case 113 'F2 Change Ward
''               Case 114 'F3 further information
               'Case 115 'F4 ChangeTopupDate
''               Case 116 'F5   FlipFlopRxView
''               Case 118       'F7 Label for bag or charts -65
               
               Case 119          'F8 Issue
                  If RTrim$(L.SisCode) <> "" And passlvl <> 3 Then
                        Choice$ = "I"
                        returned = False
                        'Action% = 1           '24Mar97 KR added     '28Jun12 CKJ Moved inside Case "I" to standardise action
                     End If

               Case 120          'F9 Return
                  If RTrim$(L.SisCode) <> "" And passlvl <> 3 Then
                        Choice$ = "I"
                        returned = True
                        'Action% = 1           '24Mar97 KR added     '28Jun12 CKJ Moved inside Case "I" to standardise action
                     End If
               
''               Case 121         'F10 Debug    '06Sep99 CKJ Removed, as popfreemem is obsolete
''               Case 87        'Ctrl-W      '18Jan99 EAC enhancement 603
               'Case 73        'Ctrl-I                                  '27Feb02 TH moved to Ctrl-U (#56150)
''               Case 85

               Case 67
                  If Shift = 2 Then
                     If isPBS() Then
                        F3D1_Click
                     End If
                  End If
                  
               Case 90
                  If Shift = 2 Then
                     If isPBS() Then
                        F3D2_Click
                     End If
                  End If
                  
               Case Else
                  done = False
               End Select
            KeyCode = 0
         Else
            Choice$ = nextchoice$
            nextchoice$ = ""
         End If
      
      If pid.recno = 0 Then            '08Nov05 CKJ Was patno&
         Select Case Choice$
            Case "P", "S", "A", "I", "D", "N", "R": Choice$ = ""
            End Select
      End If

      Select Case Choice$
'~~~~~~~~~~~~~~>
         Case "F"  '07Jun05 TH Added new extemp formula issue  option '24May06 TH Added setting
            If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "N", "AllowFormulafromDispensing", 0)) Then doFormulaAndPN
            
'~~~~~~~~~~~~~~>
         Case "P"                    ' print label
            '22May09 TH Added
            
            'If getDispensingReturn() And Not (returned) Then
            If getHistoryPrescription() And Not (returned) Then '14Jan10 TH Replaced to make more logical sense
               popmessagecr "", "This functionality is only available against a current prescription"
               Exit Sub  '22May09 TH
            End If

            Heap 10, gPRNheapID%, "lPatientCost", "", 0        '30Sep02 ATW BMI Billing; Blank cost to patient to prevent it spilling onto other labels.
            
            If isPBS() Then
               If (Not PrivateBilling()) Then
                  blnPBSPassed = True
                  PBSPreIssueChecks blnPBSPassed
                  If Not blnPBSPassed Then Exit Sub
               End If                                                                                                           '    "
            End If
            
            '15Feb11 TH  Chemocare (F0036868) If we have truncated notes shown then here we pop them to force the user to view them before we continue
            'Otherwise continuing would be a clinical risk
            If GetReviewInterfaceText() Then
               If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "Y", "ForceReview", 0)) Then
                  strMsg = TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "You must Review and verify the full details of this prescription before proceeding. [cr][cr]Click the Chemocare panel to view prescription details", "ForceReviewMessage", 0)
                  strCaption = TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "!Imported Chemocare prescription", "ForceReviewCaption", 0)
                  ParseCtrlChars dispdata$ & "\printer.ini", "Screen", strMsg, 0
                  popmessagecr strCaption, strMsg
                  Exit Sub
               Else
                  picOCXdetails_Click
               End If
            End If
            
            If Labf& = 0 Then
               SaveLabel complete       '16Nov98 added complete
               If Labf& = 0 Then Exit Sub  '01Sep01 TH If 0 then hasnt created new label (>50 meds) so dont continue (#54440)
''               labftemp& = Labf&
            Else
               CheckRxComplete complete
            End If
            
            If g_blnPSO Then  '08Aug12 TH Added PSO chunk
               If CheckPSOOrder(L.RequestID) Then
                  popmessagecr "", "This order has already been created"
                  Exit Sub
               End If
            End If
            
            '15Aug13 TH DoC stuff (TFS 70134)
            If TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "UseRptCyclesDisp", 0)) Or TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "RepeatsRemainingDispCheck", 0)) Or TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "PrescriptionExpiryDispCheck", 0)) Then
               'Load up a recordset
               strParams = gTransport.CreateInputParameterXML("DispensingID", trnDataTypeint, 4, gRequestID_Dispensing)
               Set rsRptDisp = gTransport.ExecuteSelectSP(g_SessionID, "pRepeatDispensingPrescriptionLinkDispensingByDispensingIDINUSE", strParams)
            
               If Not rsRptDisp Is Nothing Then     'use returned recordset
                  If rsRptDisp.State = adStateOpen Then
                     If rsRptDisp.RecordCount <> 0 Then
                        strPrescriptionExpiry = RtrimGetField(rsRptDisp!PrescriptionExpiry)
                        intTotalRepeats = RtrimGetField(rsRptDisp!RepeatTotal)
                        intRepeatsRemaining = RtrimGetField(rsRptDisp!RepeatRemaining)
                        intRepeats = intTotalRepeats - intRepeatsRemaining
                        sglRepeatQuantity = RtrimGetField(rsRptDisp!quantity)
                        If intTotalRepeats > 0 Then
                           setRepeatNumber intRepeats + 1
                           setTotalRepeats intTotalRepeats
                        End If
                        setRptPrescriptionExpiry strPrescriptionExpiry
                        setRptQuantity sglRepeatQuantity '19Aug13 TH Extend to possibly use the rpt qty as override on issue
                     End If
                  End If
               End If
               rsRptDisp.Close
               Set rsRptDisp = Nothing
            End If
            If TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "RepeatsRemainingDispCheck", 0)) Then
               'Check here to see if we have a linked repeat
               'If TrueFalse(TxtD(dispdata$ & "D|Patbill.ini", "PatientBilling", "N", "UseBatchnumberforRepeats", 0)) Then
               If TrueFalse(TxtD(dispdata$ & "\Patbill.ini", "PatientBilling", "N", "UseBatchnumberforRepeats", 0)) Then '23Sep13 TH (TFS 73946)
                  intRepeatsRemaining = intTotalRepeats - L.batchnumber
               End If
               If intTotalRepeats > 0 And intRepeatsRemaining < 1 Then
                  If TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "RepeatsRemainingDispCheckWarn", 0)) Then
                     strMsg = TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "There are no more repeats allowed for this item." & crlf & crlf & "Are you sure you wish to continue", "RepeatsRemainingDispCheckWarnMsg", 0)
                     strAns = "N"
                     askwin "?Repeat Dispensing", strMsg, strAns, k
                     If strAns = "N" Or k.escd Then
                        Exit Sub
                     End If
                  Else
                     strMsg = TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "There are no more repeats allowed for this item.", "RepeatsRemainingDispCheckStopMsg", 0)
                     popmessagecr "!Repeat Dispensing", strMsg
                     Exit Sub
                  End If
               End If
            End If
            
            If TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "PrescriptionExpiryDispCheck", 0)) Then
               If Trim$(strPrescriptionExpiry) <> "" Then
                  datetodays Format$(Now, "dd/mm/yyyy"), strPrescriptionExpiry, ndbd&, 0, "", 0
                  If ndbd& < 0 Then
                     If TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "PrescriptionExpiryDispCheckWarn", 0)) Then
                        strMsg = TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "This prescription has expired." & crlf & crlf & "Are you sure you wish to continue", "PrescriptionExpiryDispCheckWarnMsg", 0)
                        strAns = "N"
                        askwin "?Repeat Dispensing", strMsg, strAns, k
                        If strAns = "N" Or k.escd Then
                           Exit Sub
                        End If
                     Else
                        strMsg = TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "This prescription has expired.", "PrescriptionExpiryDispCheckStopMsg", 0)
                        popmessagecr "!Repeat Dispensing", strMsg
                        Exit Sub
                     End If
                  End If
               End If
            End If
            
''            rINNcheck      '17Jan00 SF to check if rINN change warning bit set
            inttmpNumofLabels = 0 '01Oct02 TH initialise
               
            If Not LabelAmended Then
               labeltoform
            End If
               
            If Trim$(d.SisCode) <> "" Then    '     " 16Nov98 why is this section needed
               'CheckRxComplete complete '22Nov96 ASC          '16Nov98 ASC removed now asked in savelabel
            Else
               complete = True
            End If

            If Not L.IsHistory And complete Then
               DeferredPrinting 1, "", ""                                        '27Nov01 CKJ Added. Set deferred printing on
               If passlvl = 3 Then
                  Authorise chkd '04Dec96 ASC
                  
                  If chkd Then
                     PrintRx
                     k.escd = False

''                     patmedaction = "S"
                     SaveLabel 0
''                     labftemp& = Labf&
                     '22Mar02 ATW Added to support external Rx interface
''                   If LabelNotification() Then
''                      WriteLabelNotification L, UserID$, deletetohistory
''                   End If
                  End If
               Else
                  If L.IssType = "C" And TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "Y", "CIVASIssueBatchCheck", 0)) Then
                     blnNonCIVASIssue = CIVASCheck(False)   '29May08 TH Added
                  End If
                  If Not k.escd Then                        '   "
                     If LabelAmended Then                  '13Feb02 TH (#58291)
                        Authorise 0
                        ToggleRxLabel True
                        formtolabel 0
                     End If
   ''                UserControl.Refresh                                             '19May00 AE/MMA Prevent blank lines in PMR
                     k.escd = False
                     'CheckRxComplete complete                                   '05Feb98 CFY
                     'If Trim$(d.SisCode) <> "" Then CheckRxComplete complete     '     "       '16Feb98 ASC
                     DosesForDays -1, DailyDoses!    ' Use -1 to inhibit message
                     '17Jun08 TH Added block - black hat kludge to derive a dose on a stat item. (F0025724)
                     'If DailyDoses! = 0 And L.dose(1) = 0 And (InStr(LCase(TxtDircode.text), "stat") > 0) Then
                     If DailyDoses! = 0 And L.dose(1) = 0 And ((InStr(LCase(TxtDircode.text), "stat") > 0) Or isCustomFrequency()) Then '15Sep15 TH Added to scrape dose for custom frequency (TFS 129498)
                        DailyDoses! = (CIVASDoseIncStat(0))
                     End If
                     '------------------------
                     If DailyDoses! > 0 Then '21Jan95 ASC Added for when prescribing is NOT used
                        CalcDefaultDoses k.escd  'ASC 01Nov94   '20 Jan95 CKJ
                     End If
                     '26Jan95 CKJ added
                     'Input manually  ????
                     If Not k.escd And Val(TxtQtyPrinted.text) = 0 And RTrim$(TxtDrugCode.text) <> "" Then      '07oct03 CKJ
                        If Not PBSDrugToDispens() Then        '31Jan03 TH (PBSv4) Added
                           k.escd = True
                           SetFocusTo TxtQtyPrinted
                        End If
                     End If
                  End If                                    '29May08 TH Added
                  If (Not k.escd) Or (PBSDrugToDispens()) Then
                     NumofLabels = Val(TxtNumOfLabels.text)
''21oct05 CKJ REMOVED DRY VIALS AND CIVASDRYPOWDERLABEL
''                     whole$ = "N"
                                 
                     If L.IssType = "C" Then
''                        If UCase$(plvl$("AskDryVials")) <> "N" Then
''                           whole$ = "Y"
''                           'confirm "Dispensary Issue", "confirm CIVAS label and print label for whole packs", whole$, k  '!!** Wording too obscure
''                           Confirm "Stock Issue", "print label for whole packs now (storing CIVAS label for later use)", whole$, k
''                           If whole$ = "Y" And Not k.escd Then
''                              Qty! = 0
''                              SaveLabel CIVASDryPowderLabel, 0
''                              labftemp& = Labf&
''                              L.IssType = "I"
''                              If Not reusedLabel% Then createlabel 1
''                              L.IssType = "C"
''                              CIVASDryPowderLabel = True
''                           End If
''                        End If
                           
''                        If whole$ = "N" And Not k.escd Then
                           If d.dosesperissueunit > 0 Then
                              TxtQtyPrinted.text = LTrim$(Str$((L.dose(1) / d.dosesperissueunit) * NumofLabels))
                              TxtQtyPrinted.text = Format$(TxtQtyPrinted.text)
                           Else
                              popmessagecr "!Warning", "Doses per issue unit needs setting in utilities"
                           End If
''                        End If
                     End If
                     '10Jun05 TH Moved block from below
                     If blnNonCIVASIssue And Not k.escd Then '30May08 TH added
                        toissue = True
                     Else
                        If Not k.escd Then
                           d.SisCode = L.SisCode
                           getformula formulafound, rsFormula     '26Jun97 KR Needed for manufacturing
                           If formulafound Then       '4Sep97 Expanded for batch formulae
                              If RtrimGetField(rsFormula!DosingUnits) Then 'true = patient not batch
                                 toissue = False    'issue as extemp, issuing ingredients later and not issuing this product code
                                 inttmpNumofLabels = RtrimGetField(rsFormula!NumofLabels) + RtrimGetField(rsFormula!ExtraLabels) '01Oct02 TH Added to give default lbl number when no dose is explicitly entered
                                 intFormulaNumofLabels = RtrimGetField(rsFormula!NumofLabels)   '06Jun03 TH Added
                                 intFormulaExtraLabels = RtrimGetField(rsFormula!ExtraLabels)
                                 '12Jan12 TH This is where our PCT message should go
                                 If IsPCTDispensing() Then
                                    'Turn off PCT for CIVAS and warn the user
                                    popmessagecr "", "There is PCT information for this prescription and this item." & crlf & _
                                    "However PCT Dispensing is not allowed for patient specific CIVAS dispensing " & crlf & "and therefore no PCT claim will be made for this issue."
                                    SetPCTDispensing False
                                 End If
                              Else
                                 toissue = True     'batch manuafacture, already on shelf, issue finished product
                              End If
                           Else
                              toissue = True           'no formula - normal issue
                           End If
                        End If
                     End If
                     '--------
                     ''If d.expiryminutes > 0 And whole$ <> "Y" And Not k.escd Then
''                     If d.expiryminutes > 0 And whole$ <> "Y" And Not k.escd And toissue Then '10Jun05 TH Added toissue
                     If d.expiryminutes > 0 And Not k.escd And toissue Then                     '10Jun05 TH Added toissue
                        ans$ = "Y"
                        k.helpnum = 210
                        expiry$ = ""
                        GetLabelExpiry expiry$, WorkingDate$, WorkingTime$, k.escd
                        Heap 10, gPRNheapID, "rxExpiry", expiry$, 0
                        lblExpiry.Caption = expiry$
                     End If
   
                     ' XN 26726 13May15
                     If Not k.escd Then
                        Qty! = Val(TxtQtyPrinted.text)

                        ' If item is an issue (-ve return or +issue) for a disepensing record check if redispensing is enabled XN 26726 13May15
                        If ((returned And Qty! < 0) Or (Not returned And Qty! > 0)) And gRequestID_Dispensing > 0 And _
                            (allowReDispensing = Disabled Or (allowReDispensing = DisabledIfEmmWard And IsEpisodeOnEMMWard(gTlogEpisode))) Then
                            popmessagecr "Dispensing", "Current settings prevent re-dispensing"
                            k.escd = True
                        End If
                     End If
                     
                     If Not k.escd Or (PBSDrugToDispens()) Then
                        'Qty! = Val(TxtQtyPrinted.text) Moved above  XN 26726 13May15
''                      If d.ATC = "B" Then SendToBaker
            
                        '18sep01 ckj Only call this if there is a drug code, ie not a free format label
                        BatchNo$ = ""                                               '18sep01 ckj added
                        Exdate$ = ""
                        ''If Trim$(d.SisCode) <> "" Then
                        If Trim$(d.SisCode) <> "" And toissue Then '10Jun05 TH Added
                           If BatchLabel$ = "Y" Then
                              k.min = 0
                              k.Max = 15
                              k.nums = False
                              k.decimals = False
                              k.escd = False
                              InputWin "Batch No.", "Please enter the batch number of this drug.", BatchNo$, k
                              If Not k.escd Then
                                 k.Max = 12
                                 InputWin "Batch" & BatchNo$, "Please enter the expiry date for this batch.", Exdate$, k
                              End If
                           End If                                             '18sep01 ckj
                        End If
                                       
                        k.escd = False    '20Jan95 CKJ offer to print label anyway
''                        If whole$ = "Y" And L.IssType = "C" Then getlabel Labf&, L, False

                        If Not k.escd Then
                           If L.PrescriptionID = 0 Then GetPointerSQL patdatapath$ & "\RxID.dat", L.PrescriptionID, True  'Set prescription id here.  20Jun97 KR.
                           dircode$ = Trim$(L.dircode)
                           'If l.IssType = "C" And (l.dose(1) = 0) Then
                           '   '19Jun08 TH Added kludge
                           '   If (InStr(LCase(txtUC("TxtDircode").text), "stat") = 0) Then popmessagecr "!", "Dose not entered for this patient"
                           'End If
                           '19jun08 TH Replaced above
                           If L.IssType = "C" And (CIVASDoseIncStat(L.dose(1)) = 0) Then popmessagecr "!", "Dose not entered for this patient"
                           ''d.SisCode = L.SisCode
                           ''getformula formulafound, rsFormula     '26Jun97 KR Needed for manufacturing
                           ''If formulafound Then       '4Sep97 Expanded for batch formulae
                           ''   If RtrimGetField(rsFormula!DosingUnits) Then 'true = patient not batch
                           ''      toissue = False    'issue as extemp, issuing ingredients later and not issuing this product code
                           ''      inttmpNumofLabels = RtrimGetField(rsFormula!NumofLabels) + RtrimGetField(rsFormula!ExtraLabels) '01Oct02 TH Added to give default lbl number when no dose is explicitly entered
                           ''      intFormulaNumofLabels = RtrimGetField(rsFormula!NumofLabels)   '06Jun03 TH Added
                           ''      intFormulaExtraLabels = RtrimGetField(rsFormula!ExtraLabels)
                           ''   Else
                           ''      toissue = True     'batch manuafacture, already on shelf, issue finished product
                           ''   End If
                           ''Else
                           ''   toissue = True           'no formula - normal issue
                           ''End If
                           
                           If toissue Then
                              'issue k, qty!, 0, d, userid$, (pid.recno), dircode$, issued, (pid.Status), (pid.ward), (pid.cons), SiteNumber, l.isstype, unitcost$, batchnumber$, expiry$
                              'Action = 2 'show issue and label portion of form
                              'If l.IssType <> "C" Then Action = 2 Else Action = 1
                              If L.IssType <> "C" Then Action = -2 Else Action = -1   '06Apr99 TH
                              
                              GetDispWardSupplier (pid.ward), lngFoundSup, lclsupWard
                              If lngFoundSup > 0 Then
                                If lclsupWard.suppliertype = "W" Then costcentre$ = lclsupWard.wardcode
                              End If
                                
                              If Trim$(costcentre$) = "" Then GetCostCentre (pid.ward), costcentre$     '15Mar99 SF added
                              
                              
                              '12Jun15 TH If we swap wards (because existing doesnt exist) then change pid - this is effectively session based,
                              '           we dont save so it is inappropriate to use the old incorrect ward on prints when the selected ward is logged
                              '           The ward selected here should now be used consistently in preference (TFS 58926)
                              'pid.ward = costcentre$
                              '28Jul15 TH Replaced above to ensure WYSWYG is updated (TFS 123260)
                              'If pid.ward <> costcentre$ Then
                              If UCase$(Trim$(pid.ward)) <> UCase$(Trim$(costcentre$)) Then  '17Aug15 TH Added ucase and trim (TFS 123260)
                                 pid.ward = costcentre$
                                 'Now we need to refresh the label
                                 If Not L.extralabel Then createlabel 1, 0
                                 memorytolabel
                              End If
                              
''                              SetOCXRecoveryTime Format$(Now, "HHMMSS")

                              '13Jun01 TH Added - if label incomplete then warn before issue not after once log is written and label therefore not saved
                              '18sep01 ckj Only call this if there is a drug code, ie not a free format label
                              If Trim$(d.SisCode) <> "" Then                             '18sep01 ckj
                                 CanTheLabelBeSaved intLabelok
                                 If Not intLabelok Then
                                    popmessagecr "!EMIS Health", "The label is not complete and CANNOT be saved in its present form"
                                    Qty! = 0    'Reset qty incase user amends and reissues on same effective pass
                                    DeferredPrinting 4, "", ""                     '27Nov01 CKJ delete queue
                                    Exit Sub    '<------------------ WAY OUT
                                 End If
                              End If                                                  '18sep01 ckj

                              SetIssueConfig 1                            '14apr04 CKJ baglabels supported, deferred printing
                              'issue k, Qty!, 0, d, UserID$, (pid.recno), dircode$, Issued, (pid.status), (pid.ward), (pid.cons), SiteNumber, l.IssType, unitcost$, batchnumber$, expiry$, duplicates%, numoflabels%, Action     '15Mar99 SF replaced
                              GlobalManufBatchNum$ = ""  '13Feb02 TH Added (#47263)
                              Issue k, Qty!, 0, d, UserID$, (pid.recno), dircode$, Issued, (pid.status), (costcentre$), (pid.cons), SiteNumber, L.IssType, UnitCost$, batchnumber$, expiry$, duplicates%, NumofLabels%, Action   '15Mar99 SF
                                 '20May08 CKJ ported from V8.8
                                                   '12oct06 CKJ read robot labelID and clear it to prevent patient labels etc being sent to robot
                                                   robotlabelID = GetRobotPrintLabelMessageID()
                                                   SetRobotPrintLabelMessageID 0
                                
                              AltLabelContext = GetAltLabelContext()   '28Jun12 CKJ read and clear to prevent patient labels being affected
                              SetAltLabelContext ""
                                                   
                              If Issued Then                '15Dec98 SF added
                                 GlobalManufBatchNum$ = batchnumber$  '13Feb02 TH Added (#47263)
                                 '20Nov00 SF/CFY only increment batch number if not been done by patient billing
                                 '15Aug13 TH Doc Do we need to utilise the batchnumber field here with the repeat number ????? TFS 70134
                                 If Not TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "BillPatient", 0)) Then
                                    L.batchnumber = L.batchnumber + 1
                                 Else                                                                                            '19Mar03 TH (PBSv4) Added  to allow
                                    If PBSSwitchedOff() Then L.batchnumber = L.batchnumber + 1                                   '    "      PBS to be set up but switched off
                                 End If                                                                                          '    "
                              End If
                              
                              '14Aug13 TH If in DoC Mode then we must increment the repeat number here for this RepeatDispensingPrescriptionLinkDispensing record (TFS 70134)
                              If (intRepeatsRemaining > 0) And Issued And TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "AutoDecrementFromDisp", 0)) Then
                                 'strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Prescription)
                                 'lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pRepeatDispensingPrescriptionLinkDispensingDecrementRepeat", strParams)
                                 '06Jan16 TH Replaced above to decrement by label to allow split dose installment dispensing (TFS 138797)
                                 strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Dispensing)
                                 lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pRepeatDispensingPrescriptionLinkDispensingDecrementRepeatbyLabel", strParams)
                              End If
                                 
                              If Issued Or Action = 3 Then                               '13May04 CKJ Baglabels moved outside the If Issued clause
                                 For i = 1 To Val(FrmIssue.TxtBagLabels.text)
                                    If costcentre$ <> "" Then
                                       patlabel k, pid, True, 2
                                    Else
                                       patlabel k, pid, True, 1
                                    End If
                                 Next
                                 Unload FrmIssue
                              End If                                                  '13May04 CKJ ---

                           Else
                              Issued = True
                           End If
                        
                           '!!** 21Mar97 KR Cludge Deluxe!!!!
                           If Action = 3 Then k.escd = False        'if selected print only no issue
                           If Not k.escd Then      '20 Jan95 CKJ
''                              If CIVASDryPowderLabel Then
''                                 'from memory
''                                 DisplaytheLabel NumofLabels, 3, k, expiry$     ' Print it ...
''
''                              Else
                                 If L.IssType = "C" Or Not toissue Then
                                    GlobalManufBatchNum$ = ""  '23Sep96 CKJ Cludge!!**
                                    
                                    PromptBatchNumber False  '21Oct02 TH Added Parameter
                                    Heap 11, gPRNheapID, "rxExpiry", strTmpExpiry, 0    '07Oct02 TH
                                    If strTmpExpiry <> "" Then expiry$ = strTmpExpiry   '  "
                                    If Not k.escd Then '01Oct02 TH Allow for escape (#)
                                       If intFormulaExtraLabels > 0 Then                                                               '06Jun03 TH Added (#68679)
                                          ExtraLabelsBatch = intFormulaExtraLabels
                                       Else
                                          ExtraLabelsBatch = Val(TxtD(dispdata$ + "\patmed.ini", "", "0", "SpareCIVASlabelsBatch", 0))
                                       End If
                                          
                                       If intFormulaNumofLabels > 0 Then
                                          ExtraLabelsDose = intFormulaNumofLabels - 1
                                       Else
                                          ExtraLabelsDose = Val(TxtD(dispdata$ + "\patmed.ini", "", "B", "SpareCIVASlabelsDose", 0))
                                       End If
                                       ExtraLabels = (NumofLabels * ExtraLabelsDose) + ExtraLabelsBatch

                                       PromptForWrkSht Layout$, PatsPerSheet%, 0
                                       If L.IssType <> "C" And NumofLabels = 0 Then                                                                '01Oct02 TH Added to allow qty issued to be used when no dose was been entered explicitly
                                          PrintWorkLabel Formula, Int(Qty!), WorkingDate$, WorkingTime$, expiry$, formulafound, 1, Layout$, 0, 0, blnNonCIVASIssue
                                       Else
                                          PrintWorkLabel Formula, NumofLabels, WorkingDate$, WorkingTime$, expiry$, formulafound, 1, Layout$, 0, 0, False
                                       End If
                                    End If
                                       
                                    If k.escd Then Issued = False                                   '20Mar00 CFY Added
                                    '01Oct02 TH make checks on formula vars and do only what is required (#)
                                    If NumofLabels = 0 Then            '01Oct02 TH Added to override if no doses explicitly entered
                                       NumofLabels = inttmpNumofLabels '     "
                                    End If                             '     "

                                    If GetNoLabelRequired() Then
                                          SetNoLabelRequired False
                                          NumofLabels = 0
                                          ExtraLabels = 0
                                       End If
                                    If GetNoIssueRequired() Then
                                          Issued = False
                                       End If

                                    'If Not k.escd Then DisplaytheLabAndForm numoflabels + ExtraLabels, 3, k, expiry$, 0    '13Feb02 TH moved back despite above (no relevant comments found in formula.bas) (#50210)
                                    '01Oct02 TH Added to replace above
                                    If Not k.escd Then
                                       Heap 11, gPRNheapID, "rxExpiry", strTmpExpiry, 0    '07Oct02 TH
                                       If strTmpExpiry <> "" Then expiry$ = strTmpExpiry   '  "
                                       If expiry$ = "" Then
                                          getexpirydate expiry$     'Essentially a frig to get any entered expiry if no issue actually taking place
                                          If expiry$ = "" Then expiry$ = "00/00/00 00:00"    'Needed as wrksheets used to format this ,but htis could now have been bypassed
                                       End If
                                       If L.IssType <> "C" And Not toissue Then
                                          DisplaytheLabel NumofLabels + ExtraLabels, 3, k, expiry$, 0, False  'Dont use wrapper here
                                       Else
                                          DisplaytheLabAndForm NumofLabels + ExtraLabels, 3, k.escd, expiry$, 0
                                       End If
                                       setexpirydate ""      'Added to reset
                                    End If
                                    SetNoIssueRequired False
                                    '-----------
                                    'DisplaytheLabAndForm numoflabels + Val(TxTd(dispdata$ + "\patmed.ini", "", "0", "NumofSpareCIVASlabels", 0)), 3, k, expiry$, 0  '19Nov98 CFY
''                                                                  forwardlabel k.escd        '06Jun97 KR added
                                    GlobalManufBatchNum$ = ""  '23Sep96 CKJ Cludge!!**
''                                    If OCXlaunch() And formulafound Then
''                                          GetManufactureInfo Qty!, mancost!
''                                          UnitCost$ = Format$(mancost!, "0.00")
''                                       End If
                                    
                                 Else
                                    'If Not Issued Then
                                    If (Not Issued) And (Not g_blnPSO) Then  '07Aug12 TH Added PSO check
                                          popmessagecr "#EMIS Health", "Labels will be printed only.  No items will be issued."  '04June97
                                          PatBillStub = billpatient(17, "")  '02Dec99 SF added to clear PBS items on a label re-print
                                       End If
                                    '07Apr10 AJK Added for HIL (F0072542) Ported from v8
                                    'If Qty! > 0 And Not k.escd Then
                                    If Qty! > 0 And Not k.escd And (Not g_blnPSO) Then  '08Aug12 TH HIL Leaflets not supported for PSO
                                        If TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "HIURL", "N", "HealthInformation", 0)) Then
                                            If Val(d.HIProduct) > 0 Then
                                                HILaunchLeaflet
                                            End If
                                        End If
                                    End If
                                    If (Not g_blnPSO) Or (g_blnPSO And (d.PSOLabel)) Then  '07Aug12 TH PSO
                                       'If TrueFalse(TxtH$(dispdata$ & "\patmed.ini", "patient billing", "N", "BillPatient", 0)) Then   '24Aug00 JN Added check to only increment if Pharmacc is turned off '18Oct00 JN Changed to line below
                                       '20Nov00 SF/CFY moved logic to a different part of the procedure
                                       'If TxtH$(dispdata$ & "\patmed.ini", "patient billing", "", "BillPatient", 0) <> "N" And Issued Then         '18Oct00 JN Changed line above as was not being picked up properly
                                       '      l.batchnumber = l.batchnumber + 1  '23Jun00 JN ##~HERE~###
                                       '   End If
                                       '20Nov00 SF/CFY -----
   ''                                                                  TGLabelList.Refresh      '07oct03 CKJ
   
                                       SetAltLabelContext AltLabelContext     '28Jun12 CKJ restore alternative label context, if set
   
                                       '20May08 CKJ ported from V8.8
                                       '12oct06 CKJ RobotLabel print happens here, restore robotlabelID & decrement duplicates
                                       'DisplaytheLabAndForm NumofLabels, 3, k, expiry$, duplicates%       ' Print it ...
                                       SetRobotPrintLabelMessageID robotlabelID
                                       If robotlabelID Then
                                          DisplaytheLabAndForm (NumofLabels), 3, k.escd, expiry$, 1             ' Send label to robot ...     20May08 CKJ add () to preserve NumOfLabels
                                          duplicates = duplicates - 1
                                       End If
                                       If duplicates > 0 Then
                                          DisplaytheLabAndForm NumofLabels, 3, k.escd, expiry$, duplicates%    ' Print it ...
                                       End If
                                       
                                       SetAltLabelContext ""                  '28Jun12 CKJ clear alternative label context
                                       
                                    End If
                                 End If         '07Aug12 TH PSO
                                 'from the form
''                              End If
                           
                           If Qty! > 0 Then PatBillStub% = billpatient(6, "")      '04Jun99 SF added to discontinue the item if all repeats issued
                           
''                           If OCXlaunch() And Issued Then
''                                                            '02Feb99 EAC Added for E7 mod
''                                                            Select Case GetOCXAction()
''                                                               Case "N", "M"
''                                                                  If GetOCXModuleType() = "C" Then
''                                                                        CancelTransactions pid.recno, L.prescriptionid, "TIME<=" & GetOCXRecoveryTime$()
''                                                                     Else
''                                                                        ReturnPNRegimen pid.recno, L.prescriptionid, "TIME<=" & GetOCXRecoveryTime$()
''                                                                     End If
''                                                               Case Else
''                                                            End Select
''
''                              OCXStatus = STATUS_ISSUE
''                              SetOCXIssueParameters Qty!, UnitCost$
''                              SetOCXLabelParameters L.SisCode, L.IssType, L.dircode$, (TxtDose(1).Text), (RxUnits(1).Caption), L.startdate, L.StopDate
''                           End If
                        End If
                        k.escd = False    '20Jan95 CKJ offer to print label anyway
                                             
                        'If Issued Then
                        If Issued Or g_blnPSO Then
                           SaveLabel 0
                           '05Mar02 ATW Added to support external Rx interface
''                            If LabelNotification() Then
''                               WriteLabelNotification L, UserID$, deletetohistory
''                            End If
''                            labftemp& = Labf&
                           Else
                              Qty! = 0  'ASC 10.02.92
                              If L.IssType = "C" Then TxtQtyPrinted.Tag = ""  '01Oct02 TH Added to prompt dose box next time over (#63313)      '07oct03 CKJ
                           End If
                                             MechDispClearLabelData            '20May08 CKJ now clears messageid & section
                        Else
                           Qty! = 0
                        End If
                     End If
                     BatchNo$ = ""
                     Exdate$ = ""
                     DeferredPrinting 3, "", ""               '20oct08 CKJ extra call added, so that setfocus can be done inside IFs (F0036227)
                     SetFocusTo TxtPrompt       '21oct05 CKJ  '25sep08 CKJ Moved below (F0028203) '20oct08 CKJ reinstated
                  End If
                  k.escd = False
               End If
               DeferredPrinting 3, "", ""                      'now only used as back-stop if no printing has been done
                     
            Else
               If L.IsHistory Then popmessagecr "!", "View and issue only for history"
            End If
            GlobalManufBatchNum$ = ""  '13Feb02 TH (#47263)
            Heap 10, gPRNheapID, "rxExpiry", "", 0   '07Oct02 TH Added

            '30Sep02 ATW BMI Billing; Blank cost to patient to prevent it spilling onto other labels.
            Heap 10, gPRNheapID%, "lPatientCost", "", 0
            If isPBS() Then               '31Jan03 TH (PBSv4) Added
               PBSUpdateIssuePanel
            End If
            '03Dec12 TH Switch off residual syringelabel handling
            setSyringestolabel 0
         
'~~~~~~~~~~~~~~>
         Case "R"
            '15Jan10 TH Added block after testing (F0074324)
            If getHistoryPrescription() And Not (returned) Then '14Jan10 TH Replaced to make more logical sense
               popmessagecr "", "This functionality is only available against a current prescription"
               Exit Sub
            End If
            
            If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "EnableReprints", 0)) = True Then    '25Jun99 CFY Added
               result$ = "1"                                           '
               If UCase(Trim$(L.IssType)) = "C" Then                   '
                  frmoptionset -1, "Reprint"                        '
                  frmoptionset 1, "Label"                           '
                  frmoptionset 1, "Manufacturing Worksheet"         '
                  If billpatient(13, "") Then frmoptionset 1, "Repeat Authorisation Form"    '16Nov00 SF added for PBS repeat auth form reprint
                  frmoptionshow "1", result$                        '
                  frmoptionset 0, ""                                '
               Else                                                     '16Nov00 SF added for PBS repeat auth form reprint
                  If billpatient(13, "") Then
                     frmoptionset -1, "Reprint"
                     frmoptionset 1, "Label"
                     frmoptionset 1, "Repeat Authorisation Form"
                     frmoptionshow "1", result$
                     frmoptionset 0, ""
                     If result$ = "2" Then result$ = "3"
                  ElseIf billpatient(25, "") Then                    '04Mar02 TH Added elseif for MOJ (type 3) (#MOJ#)
                     frmoptionset -1, "Reprint"
                     frmoptionset 1, "Label"
                     frmoptionset 1, "Prescription Owing Form"
                     frmoptionshow "1", result$
                     frmoptionset 0, ""
                     If result$ = "2" Then result$ = "4"
                  End If
               End If
               
               k.escd = Iff(result$ = "", True, False)
                  
               If Not k.escd Then
                  ReprintFile Val(result$), 2, Labf&, 0  '04Mar02 TH Added Parameter (#MOJ#)
               End If
            End If

'~~~~~~~~~~~~~~>
         Case "A", "AN"                   ' amend the memory image                             '29May01 TH Added second clause
            'If getDispensingReturn() And Not (returned) Then
            If getHistoryPrescription() And Not (returned) Then '14Jan10 TH Replaced to make more logical sense
               popmessagecr "", "This functionality is only available against a current prescription"
               Exit Sub  '22May09 TH
            End If
            'Labf& = PresentLabel&()      '16Jul01 TH Added to ensure Amend is allowed for existing item when first loading Dispens (#54003)
            Labf& = L.RequestID           '13Oct05 CKJ
            
            If Labf& = 0 And Choice$ = "A" Then                                                '29May01 TH Prevent amendment if Label not yet saved (#52393)
               If Not TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "SuppressAmendMsg", 0)) Then popmessagecr "!", "Amend is only available against a previously saved record"   '13Feb02 TH Added suppressionof msg on ini (#55838)
               SetFocusTo CmbIssueType
            Else
               If Not L.IsHistory Then
                  If RTrim$(d.dircode) <> "" And Left$(d.dircode, 1) = ">" Then       '08Jun99 TH Reset storeddirect$ to ensure extra directions are prompted (merge from 8066 12feb99)
                     storeddirect$ = RTrim$(Right$(d.dircode, Len(d.dircode) - 1))
                  End If
                  WDir.directs = ""
               
                  SetFocusTo CmbIssueType
               Else
                  popmessagecr "!", "View only for history"
               End If
                     
''               rINNcheck      '17Jan00 SF added to check if rINN change warning bit set
            End If                                                                          '29May01 TH
         
'~~~~~~~~~~~~~~>
         Case "N"                    ' new label
            'If getDispensingReturn() And Not (returned) Then
            If getHistoryPrescription() And Not (returned) Then '14Jan10 TH Replaced to make more logical sense
               popmessagecr "", "This functionality is only available against a current prescription"
               Exit Sub  '22May09 TH
            End If
            Blanklabel
            setPBSblnKeepBillitems False '31Jan03 TH (PBSv4) Added
            
            If Not L.IsHistory Then
               If LabelAmended Then
                  DisplaytheLabAndForm 0, -1, k.escd, expiry$, 0
                  QuerySave ans$
               End If
                     
               If Not LabelAmended Then
                  StopEvents = True
                  Blanklabel
                  clearlabel L
                  Erase labelline$
                  If isPBS() Then                         '31Jan03 TH (PBSv4) Added
                     blnPBSPassed = billpatient(29, "")   '   " '***** was 24
                  End If
                  
                  'Clear the form and the label
                  labeltoform
                  TxtDrugCode = ""
                  BlankWDirection WDir
                  BlnkPrescribFrm True
                  BlankWProduct d
                  
                  clearlabel L
                  Erase labelline$
                  LabelAmended = False
                  Qty! = 0
      
                  L.IssType = pid.status
   
                  CheckIssType 3    '19Jul02 SF/TH was 2 to ensure labelamended flag not set
      
                  TxtQtyPrinted.text = "0"
                  LblUntil.Visible = False
                  TxtDescDate.Visible = False
                  TxtDescDate.text = ""
                  LblSupply.Visible = False
                  LblSupply.Caption = ""
                  Lblreason.Visible = False
               
                  nextchoice$ = "AN"  '29May01 TH Added to get around new check on pre-exisitng labels (#52393)
                  StopEvents = False
               End If
            Else
              popmessagecr "!", "View and issue only for history"
            End If

            If isPBS() Then               '31Jan03 TH (PBSv4) Added
               PBSSetNewLabel
               PBSUpdateIssuePanel
            End If
            
            HideAllIPlinkForms            '09Mar04 CKJ Added


'~~~~~~~~~~~~~~>
         Case "I"                    ' issue stock
         
            If g_blnPSO Then
               If CheckPSOOrder(L.RequestID) Then
                  popmessagecr "", "This order has already been created"
                  Exit Sub  '22May09 TH
               End If
            End If
            
            'If getDispensingReturn() And Not (returned) Then
            If getHistoryPrescription() And Not (returned) Then '14Jan10 TH Replaced to make more logical sense
               popmessagecr "", "This functionality is only available against a current prescription"
               Exit Sub  '22May09 TH
            End If
            If isPBS() Then                            '31Jan03 TH (PBSv4) Added
               If Not (TrueFalse(TxtD(dispdata & "\" & "patmed.ini", "PatientBilling", "N", "PBSLaunchIssueScreen", 0))) Then   '20Jun03 TH Suppress checks now if box will pop automatically later on
                  blnPBSPassed = True
                  If returned Then blnPBSPassed = 3    '07Apr03 TH (PBSv4) Added
                  PBSPreIssueChecks blnPBSPassed
                  If Not blnPBSPassed Then Exit Sub    '!!**
               End If                                                                                                          '20Jun03 TH
            End If
            
            '15Feb11 TH  Chemocare (F0036868) If we have truncated notes shown then here we pop them to force the user to view them before we continue
            'Otherwise continuing would be a clinical risk
            If GetReviewInterfaceText() Then
               If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "Y", "ForceReview", 0)) Then
                  strMsg = TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "You must Review and verify the full details of this prescription before proceeding. [cr][cr]Click the Chemocare panel to view prescription details", "ForceReviewMessage", 0)
                  strCaption = TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "imported Chemocare prescription", "ForceReviewCaption", 0)
                  ParseCtrlChars dispdata$ & "\printer.ini", "Screen", strMsg, 0
                  popmessagecr "!" & strCaption, strMsg
                  Exit Sub
               Else
                  picOCXdetails_Click
               End If
            End If
            
            '15Aug13 TH DoC stuff (TFS 70134)
            If TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "UseRptCyclesDisp", 0)) Or TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "RepeatsRemainingDispCheck", 0)) Or TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "PrescriptionExpiryDispCheck", 0)) Then
               'Load up a recordset
               strParams = gTransport.CreateInputParameterXML("DispensingID", trnDataTypeint, 4, gRequestID_Dispensing)
               Set rsRptDisp = gTransport.ExecuteSelectSP(g_SessionID, "pRepeatDispensingPrescriptionLinkDispensingByDispensingIDINUSE", strParams)
            
               If Not rsRptDisp Is Nothing Then     'use returned recordset
                  If rsRptDisp.State = adStateOpen Then
                     If rsRptDisp.RecordCount <> 0 Then
                        strPrescriptionExpiry = RtrimGetField(rsRptDisp!PrescriptionExpiry)
                        intTotalRepeats = RtrimGetField(rsRptDisp!RepeatTotal)
                        intRepeatsRemaining = RtrimGetField(rsRptDisp!RepeatRemaining)
                        intRepeats = intTotalRepeats - intRepeatsRemaining
                        sglRepeatQuantity = RtrimGetField(rsRptDisp!quantity)
                        If intTotalRepeats > 0 Then
                           setRepeatNumber intRepeats + 1
                           setTotalRepeats intTotalRepeats
                        End If
                        setRptPrescriptionExpiry strPrescriptionExpiry
                        setRptQuantity sglRepeatQuantity '19Aug13 TH Extend to possibly use the rpt qty as override on issue
                     End If
                  End If
               End If
               rsRptDisp.Close
               Set rsRptDisp = Nothing
            End If
            
            If Not returned Then '29Aug13 TH These checks not required for returns (TFS 72187)
               If TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "RepeatsRemainingDispCheck", 0)) Then
                  'Check here to see if we have a linked repeat
               'If TrueFalse(TxtD(dispdata$ & "D|Patbill.ini", "PatientBilling", "N", "UseBatchnumberforRepeats", 0)) Then
               If TrueFalse(TxtD(dispdata$ & "\Patbill.ini", "PatientBilling", "N", "UseBatchnumberforRepeats", 0)) Then '23Sep13 TH (TFS 73946)
                     intRepeatsRemaining = intTotalRepeats - L.batchnumber
                  End If
                  
                  If intTotalRepeats > 0 And intRepeatsRemaining < 1 Then
                     If TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "RepeatsRemainingDispCheckWarn", 0)) Then
                        strMsg = TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "There are no more repeats allowed for this item." & crlf & crlf & "Are you sure you wish to continue", "RepeatsRemainingDispCheckWarnMsg", 0)
                        strAns = "N"
                        askwin "?Repeat Dispensing", strMsg, strAns, k
                        If strAns = "N" Or k.escd Then
                           Exit Sub
                        End If
                     Else
                        strMsg = TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "There are no more repeats allowed for this item.", "RepeatsRemainingDispCheckStopMsg", 0)
                        popmessagecr "!Repeat Dispensing", strMsg
                        Exit Sub
                     End If
                  End If
                  
               End If
               
               If TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "PrescriptionExpiryDispCheck", 0)) Then
                  If Trim$(strPrescriptionExpiry) <> "" Then
                     datetodays Format$(Now, "dd/mm/yyyy"), strPrescriptionExpiry, ndbd&, 0, "", 0
                     If ndbd& < 0 Then
                        If TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "PrescriptionExpiryDispCheckWarn", 0)) Then
                           strMsg = TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "This prescription has expired." & crlf & crlf & "Are you sure you wish to continue", "PrescriptionExpiryDispCheckWarnMsg", 0)
                           strAns = "N"
                           askwin "?Repeat Dispensing", strMsg, strAns, k
                           If strAns = "N" Or k.escd Then
                              Exit Sub
                           End If
                        Else
                           strMsg = TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "This prescription has expired.", "PrescriptionExpiryDispCheckStopMsg", 0)
                           popmessagecr "!Repeat Dispensing", strMsg
                           Exit Sub
                        End If
                     End If
                  End If
               End If
            End If  '29Aug13 TH
            
            '08Jan14 TH Added because if this is not present then we will not get label ID in the translog or Billing transaction (TFS 81381)
            If Labf& = 0 Then
               SaveLabel complete
               If Labf& = 0 Then Exit Sub
            End If
                        
            Action% = 1           '28Jun12 CKJ Moved inside Case "I" to standardise action
            
            getformula formulafound%, rsFormula                 '06Sep98 ASC now only shows message if the item has a formula
            If formulafound Then                                                          '02Aug99 AE
               If GetField(rsFormula!DosingUnits) = False Then BatchProduct = True
            End If

            ' Moved here so can use in checks XN 26726 13May15
            Qty! = dp!(Val(TxtQtyPrinted.text))
            
            If formulafound And L.IssType = "C" And Not returned Then                        '03Aug99 AE added formula found
               popmessagecr "!", "CIVAS items must be issued with a label and work sheet"
            ElseIf formulafound And Not BatchProduct And Not returned Then                '03Aug99 AE added formula found                                                '02Aug99 AE
               popmessagecr "Manufacturing", "Non-Batch manufactured items must be issued with a label and work sheet."
            ElseIf ((returned And Qty! < 0) Or (Not returned And Qty! > 0)) And gRequestID_Dispensing > 0 And _
                   (allowReDispensing = Disabled Or (allowReDispensing = DisabledIfEmmWard And IsEpisodeOnEMMWard(gTlogEpisode))) Then
                ' If item is an issue (-ve return or +issue) for a disepensing record check if redispensing is enabled XN 26726 13May15
               popmessagecr "Dispensing", "Current settings prevent re-dispensing"
            Else                                                                         '     "
               dircode$ = Trim$(L.dircode)
               'Qty! = dp!(Val(TxtQtyPrinted.text)) XN 26726 13May15 Moved above
               
               If Not k.escd Then
                  If L.IssType = "C" And formulafound% And returned Then
                     ReturnCivasItem success%    '22May08 TH Reinstated
                     If success% Then            '  "
   ''                     If Not True Then  'Needs setting here !!!
   ''                     Qty! = -L.lastqty        '  "
   ''                     setm_sgnCivasDose Qty!   '  "
   ''                     else
                           Qty! = getm_sgnCivasDose()
   ''                         Qty! = Qty! * -1
   ''                     End If
                        nextchoice$ = "S"        '  "
                        
                     Else                        '  "
                     Qty! = 0
                     End If                      '  "

                  Else
                     If returned Then
                        If Qty! = 0 Then Qty! = 1 '29May95 ASC
                        If getHistoryPrescription() Then blnAllowSaveforHistory = True '15Jan10 TH Added (F0072599)
                        returned = False
                        Qty! = dp!(Qty! * -1) '25Aug93 added dp! ASC
                     End If
                     
                     BlankWProduct d
                     d.SisCode = L.SisCode
   
                     If (Qty! < 0) And (TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "ReturnsLogging", 0))) = True Then       '03Mar00 TH Added logging code to try and trap mismatched returns
                        LSet Rtemp = L
                        'Rowinedit = TGLabelList.RowIndex
   ''                     PMRItem$ = LstRX$(TGLabelList.RowIndex)                                                          '   "      '07oct03 CKJ
                        logtext = " Current label = " & Rtemp.record & crlf & " Current Drug = " & d.SisCode & " description : " & d.LabelDescription & crlf & crlf & " Current pmr details = " & PMRItem$
                        WriteLog dispdata$ & "\retlog.txt", SiteNumber, UserID$, logtext$
                     End If
   
   ''                If d.ATC = "B" Then
   ''                   SendToBaker
   ''                End If
                        
                     whole$ = "Y"
                     k.escd = False
                     If L.PatientsOwn Then Confirm "Patients Own Medication", "Proceed with issue of patients own medication", whole$, k
                     
                     If whole$ = "Y" And Not k.escd Then
                        GetCostCentre (pid.ward), costcentre$
                        
                        '12Jun15 TH If we swap wards (because existing doesnt exist) then change pid - this is effectively session based,
                        '           we dont save so it is inappropriate to use the old incorrect ward on prints when the selected ward is logged
                        '           The ward selected here should now be used consistently in preference (TFS 58926)
                        pid.ward = costcentre$
                              
                        Issue k, Qty!, 0, d, UserID$, (pid.recno), dircode$, Issued, (pid.status), (costcentre$), (pid.cons), SiteNumber, L.IssType, UnitCost$, batchnumber$, expiry$, 0, 0, Action   '15Mar99 SF
                        k.escd = False '27Mar95 ASC added as belt and braces
                        If Issued Then
                           '20Nov00 SF/CFY only increment batch number if not been done by patient billing
                           '15Aug13 TH Doc (TFS 70134)
                           If Not TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "BillPatient", 0)) Then L.batchnumber = L.batchnumber + 1
                           
                           'decrement/increment repeats
                           If Qty! > 0 Then
                              '14Aug13 TH If in DoC Mode then we must increment the repeat number here for this RepeatDispensingPrescriptionLinkDispensing record
                              If (intRepeatsRemaining > 0) And Issued And TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "AutoDecrementFromDisp", 0)) Then
                                 'strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Prescription)
                                 'lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pRepeatDispensingPrescriptionLinkDispensingDecrementRepeat", strParams)
                                 '06Jan16 TH Replaced above to decrement by label to allow split dose installment dispensing (TFS 138797)
                                 strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Dispensing)
                                 lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pRepeatDispensingPrescriptionLinkDispensingDecrementRepeatbyLabel", strParams)
                              End If
                           Else
                              'Increment repeats ?
                              'If (intRepeatsRemaining > 0) And Issued And TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "IncrementFromDisp", 0)) Then
                              If (intRepeatsRemaining < intTotalRepeats) And Issued And TrueFalse(TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "N", "IncrementFromDisp", 0)) Then '29Aug13 TH Replaced logic (TFS 72186)
                                 'Here we ask the user the question, but only if there is any "leeway"
                                 If intRepeats > 0 Then
                                    strMsg = TxtD(dispdata$ & "\RptDisp.INI", "RepeatCycles", "This prescription has a number of repeats" & crlf & crlf & "Do you wish to return one of the repeats", "RepeatReturnMsg", 0)
                                    strAns = "N"
                                    askwin "?Repeat Dispensing", strMsg, strAns, k
                                    If strAns = "Y" Then
                                       'strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Prescription)
                                       'lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pRepeatDispensingPrescriptionLinkDispensingIncrementRepeat", strParams)
                                       '06Jan16 TH Added to allow differentiation for split dose labels (TFS 138797)
                                       strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, gRequestID_Dispensing)
                                       lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pRepeatDispensingPrescriptionLinkDispensingIncrementRepeatbyLabel", strParams)
                                    End If
                                 End If
                              End If
                           End If
                           
                           nextchoice$ = "S"   'save label
   ''                        If OCXlaunch() And Issued Then
   ''                           OCXStatus = STATUS_ISSUE      '08Jul98
   ''                           SetOCXIssueParameters Qty!, UnitCost$
   ''                           SetOCXLabelParameters L.SisCode, L.IssType, L.dircode, (TxtDose(1).Text), (RxUnits(1).Caption), L.startdate, L.StopDate
   ''                        End If
                        Else
                           Qty! = 0
                        End If
                     End If
                     SetFocusTo TxtPrompt
                  End If
               End If
            End If

            If isPBS() Then               '31Jan03 TH (PBSv4) Added
               PBSUpdateIssuePanel
            End If


'~~~~~~~~~~~~~~>
         Case "D"                    ' delete label
GoTo EndOfDeleteLabel

''popmessagecr ".", "Label delete/discontinue not currently supported" & crlf & "Please discontinue the Prescription above"

            If Not L.IsHistory And (passlvl = 3 Or Len(RTrim$(L.PrescriberID)) = 0) Then
''                  Labf& = PresentLabel&()        ie L.RequestID
                  If Labf& > 1 Then
                        querydelete dat$
                        If dat$ <> "" Then              ' valid, not escaped
''                              highlight = TGLabelList.RowIndex      '07oct03 CKJ
                              'If highlight = TGLabelList.Rows Then X = highlight - 1 Else X = highlight
                              '5oct96
''                              RemoveTGrow highlight
                              'TGLabellist.RemoveItem (X)
''                              For X = 1 To 50
''                                 If labrf&(X) = Labf& Then
''                                       labrf&(X) = labrf&(X) * -1  'This line causes Labf& to go -ve !
''                                       'Labf& = Labf& * -1          '??** This should not be needed but is !
''                                       Exit For
''                                    End If
''                              Next
''                              deletetohistory = True 'ASC 23Jan93
                              '------ASC 26Nov95
                              L.StoppedBy = UserID$
                              L.IsHistory = True
                              GetToday L.deletedate
   
                              If L.StopDate = 0 Then
                                 GetToday L.StopDate
                              End If

''                              Putlabel L
                              '05Mar02 ATW Added to support external Rx interface
''                              If LabelNotification() Then
''                                    WriteLabelNotification L, UserID$, deletetohistory
''                                 End If
''                              deletetohistory = False 'ASC 23Jan93
''                              putpmr pmrptr&, (pid.recno)
''                              If UBound(LstRX$) >= 1 Then   '04Jul97 KR
''                                    If highlight > TGLabelList.Rows Then      '07oct03 CKJ
''                                          TGLabelList.RowIndex = highlight - 1      '07oct03 CKJ
''                                       Else
''                                          TGLabelList.RowIndex = highlight      '07oct03 CKJ
''                                       End If
''                                    Labf& = PresentLabel&()
''                                    If Labf& > 0 Then
''                                          getlabel Labf, L, False
''                                          DisplaytheLabAndForm 1, 0, k.escd, expiry$, 0
''                                       End If
''                                 Else
''                                    ReDim LstRX$(0)
                                    BlankWDirection WDir
                                    BlnkPrescribFrm True
                                    BlankWProduct d
                                    
                                    clearlabel L
                                    Erase labelline$
                        ''          If Choice$ <> "A" Then TGLabelList.MarqueeStyle = 5
                                    LabelAmended = False
                                    Qty! = 0
 
                                    L.IssType = ""
                                    DisplaytheLabAndForm 1, 0, k.escd, expiry$, 0 '21Mar97 KR Added
''                                 End If
                              LabelAmended = False
''                              If OCXlaunch() Then
''                                    GetOCXStatus OCXStatus$          '01Oct99 CFY Added
''                                    If GetOCXAction() = "R" Then
''                                          OCXStatus$ = STATUS_RECOVER
''                                       Else
''                                          OCXStatus$ = STATUS_DISCONTINUE
''                                          SetOCXIssueParameters 0, "0"
''                                          SetOCXLabelParameters L.SisCode, L.IssType, L.dircode$, (TxtDose(1).Text), (RxUnits(1).Caption), L.startdate, L.StopDate
''                                       End If
''                                    SetOCXStatus OCXStatus$          '01Oct99 CFY Added
''                                 End If
                           End If
                        Else
                           If Labf& = 0 Then
                                 popmessagecr ".Invalid", "Can not delete a label that has not been saved"
                              Else
                                 popmessagecr ".Invalid", "Can not delete history"
                              End If
                        End If
                        setP
                        SetFocusTo TxtPrompt
            Else
               If Len(RTrim$(L.PrescriberID)) = 0 Then
                  popmessagecr "!", "View and issue only for history"
               Else
                  popmessagecr "!", "If prescribed only a prescriber can delete"
               End If
            End If
EndOfDeleteLabel:


'~~~~~~~~~~~~~~>
         Case "S"  ' save label to disk
         
            'If getDispensingReturn() And Not (returned) Then
            'If getHistoryPrescription() And Not (returned) Then '14Jan10 TH Replaced to make more logical sense
            If getHistoryPrescription() And (Not (returned) And Not blnAllowSaveforHistory) Then '15Jan10 TH Added check as returned is unset in Issue (F0072599)
               popmessagecr "", "This functionality is only available against a current prescription"
               blnAllowSaveforHistory = False '15Jan10 TH Added (F0072599)
               Exit Sub  '22May09 TH
            End If
            If isPBS() Then                                  '09Mar03 TH (PBSv4) Added
               If (Not PrivateBilling()) Then
                  blnPBSPassed = True
                  PBSPreIssueChecks blnPBSPassed
                  If Not blnPBSPassed Then Exit Sub
               End If
            End If
            
            '15Feb11 TH  Chemocare (F0036868) If we have truncated notes shown then here we pop them to force the user to view them before we continue
            'Otherwise continuing would be a clinical risk
            If GetReviewInterfaceText() Then
               If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "Y", "ForceReview", 0)) Then
                  strMsg = TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "You must Review and verify the full details of this prescription before proceeding. [cr][cr]Click the Chemocare panel to view prescription details", "ForceReviewMessage", 0)
                  strCaption = TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "imported Chemocare prescription", "ForceReviewCaption", 0)
                  ParseCtrlChars dispdata$ & "\printer.ini", "Screen", strMsg, 0
                  popmessagecr "!" & strCaption, strMsg
                  Exit Sub
               Else
                  picOCXdetails_Click
               End If
            End If
            
            If Not TrueFalse(terminal$("RxDirectionFocus", "0")) And passlvl = 3 Then  '16May04 TH Added as rxing check (#65365)
               CanTheLabelBeSaved intLabelok
            Else
               intLabelok = True
            End If
            
            If intLabelok Then
               If Qty! = 0 And TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "RepeatDispensing", "N", "RepeatDispensing", 0)) Then
''                  SetNumberOfRptLabels
               End If
               
''               L.extraFlags = Chr$(Asc(L.extraFlags) And &HFE)   '17Jan00 SF added to clear bit 0 for rINN label change
               L.rINNflag = False
               
               SetRxNodIssued
               SaveLabel 0
               '05Mar02 ATW Added to support external Rx interface
''               If LabelNotification() Then
''                     WriteLabelNotification L, UserID$, deletetohistory
''                  End If
''               labftemp& = Labf&
               '09Mar03 TH (PBSv4) Added to provide repeat record
               'If ispbs() Then
               '    PBSSetRepeatRecord
               'End If

               If nextchoice$ = "S" Then nextchoice$ = ""
               setP
               If isPBS() Then                      '09Mar03 TH (PBSv4) Added  '17Mar03 TH Reinstated
                  PBSSetPBSItemStatus
                  ItemTypeStatus 3, "", "", ""                            'Changed param to 3 to do insert not update - needed so there is a record of
               End If                                                     'of PBS details when they actually decide to issue the bugger!
''               If OCXlaunch() And OCXStatus = "" Then       '08Jul98 CFY
''                     OCXStatus = STATUS_AUTH
''                     SetOCXIssueParameters 0, "0"
''                     SetOCXLabelParameters L.SisCode, L.IssType, L.dircode$, (TxtDose(1).Text), (RxUnits(1).Caption), L.startdate, L.StopDate
''                  End If
            End If                                                                     '16May04 TH

         
'~~~~~~~~~~~~~~>
         Case "?"                                   '23Jan98 CKJ
            'msg$ = "Press  N  for a new item" & cr
            'msg$ = msg$ & "Press    D    to discontinue this item" & cr
            msg$ = msg$ & "Press    S    to save this item" & cr
            msg$ = msg$ & "Press    P    to print and issue this item" & cr
            msg$ = msg$ & "Press    R    to reprint the last item" & cr
            msg$ = msg$ & "Press    A    to amend current item" & cr
            msg$ = msg$ & "Press    ?    for this help screen" & cr
            msg$ = msg$ & "Press  Esc  to Exit" & cr
            popmessagecr "#", msg$
         
         End Select
      Choice$ = ""
   Loop Until nextchoice$ = ""

   setm_sgnCivasDose 0 '22May08 TH Ported
   labpromptchanged = False
   TxtPrompt.text = UCase$(TxtPrompt.text) 'just to keep cursor to left !
   
   TxtPrompt.SelStart = 0
   TxtPrompt.SelLength = 1
   ClearFromTxtPromptKeyUp  '17Nov05 TH Added '22May08 TH Ported from v8
   
End Sub

Private Sub TxtPrompt_LostFocus()
'Added if user enters N and clicks on type or drug code
   
''Dim DoIt As Boolean
''
''   'If patmedaction = "N" And (UserControl.ActiveControl Is CmbDropDrugCode Or UserControl.ActiveControl Is TxtDrugCode Or UserControl.ActiveControl Is CmbIssueType) Then
''
''   DoIt = False
''''   If UserControl.ActiveControl Is CmbDropDrugCode Then DoIt = True
''''   If UserControl.ActiveControl Is TxtDrugCode Then DoIt = True
''   If UserControl.ActiveControl Is CmbIssueType Then DoIt = True
''
''''   If DoIt And patmedaction = "N" Then
''   If DoIt Then
''      TxtPrompt_KeyDown 13, 0
''      TxtPrompt_KeyUp 13, 0
''   End If

End Sub

Private Sub TxtQtyPrinted_Change()
'06Jun97 KR Added.
   
'   If Val(TxtQtyPrinted.Text) = 0 Then Stop
   TxtQtyPrinted.Tag = "Edit"
   
End Sub

Private Sub TxtQtyPrinted_GotFocus()

   CurrentPositionInTabArray = 2
   UCTextBoxHiLight

End Sub

Private Sub TxtQtyPrinted_KeyDown(KeyCode As Integer, Shift As Integer)

   Select Case KeyCode
      Case 13, 27 'Return  Escape
         SetFocusTo TxtPrompt
         KeyCode = 0
      End Select
      
End Sub

Private Sub TxtQtyPrinted_KeyPress(KeyAscii As Integer)

   Select Case KeyAscii
      Case 13, 27: KeyAscii = 0
      End Select

End Sub

Private Sub TxtQtyPrinted_LostFocus()
 
   TxtQtyPrinted.text = Format$(TxtQtyPrinted.text)

End Sub

''Private Sub TxtRepeatInterval_Change()
'''16Nov96 ASC
'''09May05 a hang over from equalinterval dosing, where only 1st dose and no times are entered
''
''Dim X%
''
''   If Not StopEvents Then LabelAmended = True
''   If Val(TxtRepeatInterval.Text) > 1 And CmbRepeatUnits.Text = "day" Then
''         TxtTime(1) = ""
''         For X = 2 To 6
''            TxtTime(X) = ""
''            TxtDose(X) = ""
''         Next
''      End If
''
''End Sub
''
''Private Sub TxtRepeatInterval_GotFocus()
''
''   TxtRepeatInterval.SelStart = 0
''   TxtRepeatInterval.SelLength = Len(TxtRepeatInterval.Text)
''
''End Sub

Private Sub TxtStartDate_Change()
   
   If Not StopEvents Then LabelAmended = True

End Sub

''Private Sub TxtStartDate_DblClick()
''
''Dim DateStr$
''
''   enterdate DateStr$
''   If DateStr$ <> "" Then
''         TxtStartDate = DateStr$
''      End If
''
''End Sub

''Private Sub TxtStartDate_GotFocus()
''
''   UCTextBoxHiLight
''
''End Sub

Private Sub TxtStartDate_LostFocus()

Dim sDate$, pdate$, valid%, rightorder%

   sDate$ = TxtStartDate.text
   parsedate sDate$, pdate$, "1", valid
   If valid Then
         checkdateorder pdate$, "", "", "", rightorder
         If Not rightorder Then
               Beep
            End If
      End If

   If Not valid Then
         Beep
      Else
         TxtStartDate.text = pdate$
         Calcqtys                              '!!** should this be inhibited if rightorder=false
      End If

End Sub

Private Sub TxtStartTime_Change()
   
   If Not StopEvents Then LabelAmended = True

End Sub

''Private Sub TxtStartTime_DblClick()
''
''Dim Timestr$
''
''   If Trim$(TxtStartTime) <> "" Then
''         EnterTime Timestr$
''         If Timestr$ <> "" Then
''               TxtStartTime = Timestr$
''            End If
''      End If
''
''End Sub

''Private Sub TxtStartTime_GotFocus()
''
''   UCTextBoxHiLight
''
''End Sub

Private Sub TxtStartTime_LostFocus()

Dim stime$, ptime$, valid%, rightorder%

   stime$ = TxtStartTime.text
   parsetime stime$, ptime$, "1", valid
   If valid Then
         checkdateorder "", ptime$, "", "", rightorder
         If Not rightorder Then
               Beep
            End If
      End If

   If Not valid Then
         Beep
      Else
         TxtStartTime.text = ptime$
         Calcqtys
      End If

End Sub

Private Sub TxtStopDate_Change()

   If Not StopEvents Then LabelAmended = True

End Sub

''Private Sub TxtStopDate_DblClick()
'''23Oct98 TH Added flag to try to retain Prn when adding period
''
''Dim flag%
''
''   If ChkPRN.Value Then flag = True
''   Enterlength
''   If flag Then
''      ChkPRN.Value = 1
''      ChkPRN_click
''   End If
''
''End Sub

''Private Sub TxtStopDate_GotFocus()
''
''   UCTextBoxHiLight
''
''End Sub

Private Sub TxtStopDate_LostFocus()
'10Oct96 ASC moved to proc in patmed.bas

Dim sdat$, valid%
   
   sdat$ = TxtStopDate.text
   StopDateLostFocus sdat$, valid
   If valid Then
         TxtStopDate.text = sdat$
         Calcqtys
      End If

End Sub

Private Sub TxtStopTime_Change()
   
   If Not StopEvents Then LabelAmended = True

End Sub

''Private Sub TxtStopTime_DblClick()
''
''Dim Timestr$
''
''   If Trim$(TxtStopTime) <> "" Then
''         EnterTime Timestr$
''         If Timestr$ <> "" Then
''               TxtStopTime = Timestr$
''            End If
''      End If
''
''End Sub

''Private Sub TxtStopTime_GotFocus()
''
''   UCTextBoxHiLight
''
''End Sub

Private Sub TxtStopTime_LostFocus()

Dim stime$, ptime$, valid%, rightorder%

   stime$ = TxtStopTime.text
   parsetime stime$, ptime$, "1", valid
   If valid Then
          checkdateorder "", "", "", ptime$, rightorder
          If Not rightorder Then
               Beep
            End If
      End If
                                                                   
   If Not valid Then
         Beep
      Else
         TxtStopTime.text = ptime$
         Calcqtys
      End If

End Sub

Private Sub TxtSupplied_GotFocus()

   TxtSupplied.SelStart = 0
   TxtSupplied.SelLength = Len(TxtSupplied.text)

End Sub

Private Sub TxtTime_Change(Index As Integer)

   If Not StopEvents Then
         If TxtTime(1).Visible = True Then Calcqtys
         LabelAmended = True
       End If

End Sub

Private Sub TxtTime_DblClick(Index As Integer)

''Dim Timestr$
''
''   If Trim$(TxtTime(index)) <> "" Then
''         EnterTime Timestr$
''         If Timestr$ <> "" Then
''               TxtTime(index) = Timestr$
''            End If
''      Else
''         TxtDirCode_keyDown 8, 0
''         enterdose
''         ChooseDirectionCode WDir.Code
''         expanddir WDir.Code
''      End If

End Sub

Private Sub TxtTime_GotFocus(Index As Integer)

   TxtTime(Index).SelStart = 0
   TxtTime(Index).SelLength = Len(TxtTime(Index).text)
   
End Sub

Private Sub TxtTopUpQty_Change()
'ASC 31Mar95 was lost focus

   If DosesToTopUP! > 0 And Left$(L.IssType, 1) <> "C" Then
         TxtSupplied.text = LTrim$(Str$(DosesToTopUP! - Val(TxtTopUpQty.text)))      '07oct03 CKJ
      End If

   If Not StopEvents Then LabelAmended = True
   
   'IF VAL(TxtTopUpQty.text) = 0 THEN l.topupqty = 0 'this stops deliberately entered
   '                                                 'top up qtys from being over written by automatic calc

End Sub

Private Sub TxtTopUpQty_GotFocus()

   TxtTopUpQty.SelStart = 0
   TxtTopUpQty.SelLength = Len(TxtTopUpQty.text)

End Sub

Private Sub TxtTopUpQty_LostFocus()

   UserTopUpQty% = True

End Sub

'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
'                    Private Procedures
'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Private Function SetConnection(ByVal sessionID As Long, ByVal AscribeSiteNumber As Long, ByVal URLToken As String) As Boolean
 '09May05 CKJ Main procedure to initialise the database connection
'21Nov05 CKJ Changed from Public to Private. Only one interface is now required.
'18Jul08 CKJ Replaced V9 Phartl with V10 .NET crypto
'28Jun12 AJK 36929 Changed ConnectionString to UnencryptedData
'                  Get unencrpyted data generically and then decide if to create a web or direct data connection


'Dim objPhaRTL As PHARTL10.Security
'Dim ConnectionString As String '28Jun12 AJK 36929 Replaced with UnencrpytedData
Dim UnencryptedData As String '28Jun12 AJK 36929 Replacement for ConnectionString
Dim valid As Boolean
Dim phase As Single
Dim strDetail As String
'Dim strURL As String
'Dim strToken As String
Dim ErrNumber As Long, ErrDescription As String
'Dim HttpRequest As WinHttpRequest
'Dim posn As Integer
'Dim success As Boolean
'Dim strSeed As String
'Dim strCypher As String
'Dim strCypherHex As String
Dim blnUseWebConn As Boolean '28Jun12 AJK 36929 Added to identify if the data layer should be web proxy component
Dim strWebDataProxyURL As String '28Jun12 AJK 36929 Added to identify the URL of the web data proxy page
Dim strUnencryptedToken As String '28Jun12 AJK 36929 Added to store the unencrypted token

Const ErrSource As String = "SetConnection"

   On Error GoTo ErrorHandler

   phase = 1
   If sessionID = 0 Then Err.Raise 32767, ErrSource, "Invalid SessionID (Zero)"
''   If AscribeSiteNumber = 0 Then Err.Raise 32767, ErrSource, "Invalid AscribeSiteNumber (Zero)"
   
   If AscribeSiteNumber = 0 Then
      strDetail = "- Invalid SiteNumber (Zero)"
   Else
      g_SessionID = sessionID
      SiteNumber = AscribeSiteNumber
           
      If Val(Right$(date$, 4)) < Val(CopyrightYear) Then
         Err.Raise 32767, ErrSource, "The clock in this computer has been set to " & date$ & cr & "Please correct the date on this computer"
      End If
           
      valid = False
      If Not gTransport Is Nothing Then
         'If Not gTransport.Connection Is Nothing Then
         '   If gTransport.Connection.state = adStateOpen Then
         If Not gTransportConnectionIsNothing() Then
            If gTransportConnectionState() = adStateOpen Then
               'gTransport.ADOSetConnectionTimeOut 5               '10aug12 CKJ not right in old world, definitely not right in web
               valid = True
            End If
         End If
      End If
       
      If Not valid Then
         '28Jun12 AJK 36929 Get unencrpyted data generically and then decide if to create a web or direct data connection
         UnencryptedData = ParseURLToken(sessionID, URLToken, phase, strDetail, blnUseWebConn, strWebDataProxyURL, strUnencryptedToken)
         
         If blnUseWebConn Then
            Set gTransport = New PharmacyWebData.Transport
            gTransport.UnencryptedKey = UnencryptedData
            gTransport.URLToken = strUnencryptedToken
            gTransport.ProxyURL = strWebDataProxyURL
            'frmBlank.Tag = Format$(((1# * frmBlank.Top * frmBlank.Left) / frmBlank.Width) * frmBlank.Height)
            'gTransport.BlankTag = frmBlank.Tag
            'AJK TODO
         Else
            'ConnectionString = ParseURLToken(sessionID, URLToken, phase, strDetail)
            '~~~~~~~~~~~~~~~DEBUG ONLY~~~~~~~~~~~~~~
            'ConnectionString = "provider=sqloledb;server=servername\instance;database=DBName;uid=user;password=pwd;"
            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
            If UnencryptedData <> "" Then
               phase = 4
               Set gTransport = New PharmacyData.Transport
               phase = 5
               Set gTransport.Connection = New ADODB.Connection
               phase = 6
               gTransport.Connection.open UnencryptedData
            End If
         End If
         '28Jun12 AJK 36929 END
         
         If (UnencryptedData <> "") Then
            phase = 7
            gDispSite = GetLocationID_Site(SiteNumber)
            
            phase = 8
            ReadSiteInfo
                          
            App.HelpFile = AppPathNoSlash() & "\ASCSHELL.HLP"
   
            '19Nov07 TH Added
            If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "N", "AllowPatientPrinting", 0)) Then
               lblPatprint.Visible = True
            End If
            fraIVdetails.BackColor = White '19May08 TH Added
            valid = True
         End If
      End If
   End If
   
Cleanup:
   If ErrNumber Then
      On Error Resume Next
      'gTransport.Connection.Close
      gTransportConnectionClose              '08Aug12 CKJ
      'Set gTransport.Connection = Nothing
      SetgTransportConnectionToNothing       '08Aug12 CKJ
      Set gTransport = Nothing
      On Error GoTo 0
      'Err.Raise ErrNumber, ErrSource, ErrDescription
      MsgBox ErrDescription, vbCritical + vbOKOnly, Format$(ErrNumber) & " " & ErrSource & " (Phase=" & Format$(phase, "0.#") & ")"   '17Aug12 CKJ added  "0.#"
   End If
   
   If valid Then
      lblStatus(0).Caption = " Connected "
   Else
      UserControlEnable False
      lblStatus(0).Caption = " Unable to connect " & strDetail & " (Phase=" & Format$(phase, "0.#") & ")"   '17Aug12 CKJ added  "0.#"
      DoAction.Caption = "RefreshView-Inactive"       '06oct05 CKJ added
   End If
                  
   UnsavedChanges = False
   SetConnection = valid
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
'   ErrSource = Err.Source
   ErrDescription = Err.Description
Resume Cleanup

End Function


Private Sub doFormulaAndPN()
'27Jun96 CKJ Added
'12Jun97 KR  Added parsing of summary info for label and T to P  for (t)pn.
'12Jun97 CKJ/KR Added Check for installed modules.
'        CKJ/KR Check and set prescription id before calling tpn
'01Jul97 KR  Only call TxtPrompt setfocus if TxtPrompt visible (which it may not be in prescribing mode).
'11Nov97 CKJ Added labelamended=true when sumary text changes
'20Jul98 EAC Trap return from TPN for OCX mode
'13Aug98 EAC HK merges
'18Aug98 EAC Fixes for HK
'17Sep98 EAC Fixes for HK
'21Oct98 CKJ/CFY Preserve d through TPNmain, and fill labeline() with text returned.
'13Nov98 CKJ Added optional immediate exit from TPN
'26Dec98 ASC Added facility for patient specific formula
'01Feb99 TH  Save case changes to PID.sex before launching TPN
'03Mar99 EAC Prevent ExitNow being called in OCX mode
'            Add new Returns status of Saved for TPN items not authorised or issued
'28Jul99 AE  Mods for Formula. Now sets l.prescription ID before callmanufacturing, so that
'            a patient specific formula may be defined before the prescription is saved. In the
'            worst case, this could leave an orphaned record in Formula.mdb, but this was felt to
'            be acceptable.
'            Also added code to set the view mode of formula, depending on whether any drugs had
'            been issued on that prescription.  If so, the formula can no longer be changed.
'13Jun00 TH/AW CmdTPN_Click: Added checks against AskAPBand in ini file for consistency across application (event no. 42926)[dated 02Jun00 TH]
'25Aug99 CFY Now exist automatically from TPN when in OCX mode, but does not overide the set status.
'01Oct99 CFY Removed code which sets ocxstatus as this is now done from within TPN itself
'15Nov99 CFY Changed condition on which ReturnPNRegimen fires. Now only fires on modify action.
'14Sep00 JN  Added reference to instance of Formula.frm
'17Jul01 CKJ Removed Callmanufacturing form reference - now declared inside procedure
'01Oct02 TH  Number of mods to handle manufacturing from front screen. These interact fully with the label to try
'    "       and ensure that any issues to patient from here are logged and recorded properly on the PMR (#)

Dim NumericalAge!, dat$, valid%
Dim Summary$, Numoflines%, i%
Dim dcopy As DrugParameters, ExitNow%
Dim sex$    '03Feb99 TH
ReDim lines$(4)
Dim FormulaMode%                                                     '28Jul99 AE Added
Dim tmp$, age1!, age2!, wt1!, wt2!     '02Jun00 TH  Added
'Dim frmFormula As Formula                 '14Sep00 JN Added         '17Jul01 CKJ Removed
Dim intLabelok As Integer   '01Oct02 TH Added

   ExitNow = False                                                   '13Nov98 CKJ
   
   If L.IssType = "P" Then
   
GoTo SKIP_PN
   
''         If MDIEvents.MnuTpnprogs.Enabled = True Then '12June97 CKJ/KR Added
               '20Jul98 EAC save any height,wieght,surface area changes before loading TPN
''               CheckForPIDChanges (patno&)
               
''               If OCXlaunch() Then
''                     SetTPNExit True            '20Jul98 EAC Added
''                     SetOCXStatus ""            '03Mar99 EAC Added
''                  End If

               parsedate pid.dob, dat$, "1", valid
               If Val(pid.weight) = 0 Or RTrim$(pid.dob) = "" Or Not valid Then
                     popmessagecr "!", "Must enter details of weight and date of birth for TPN"
''                     If OCXlaunch() Then SetTPNExit False    '20Jul98 EAC Added
                  Else
                     datetodays dat$, "", 0, NumericalAge!, "", 0

                     tmp$ = TxtD(dispdata$ & "\ASCribe.ini", "PID", "12,18,0,40", "AskAPband", 0)                    '02Jun00 TH Added for consistency :
                     deflines tmp$, lines$(), ",", 1, 0                                                              '   "       Defaults can be set in ini file
                     age1! = Val(lines$(1))    'The lowest age to treat as adult;     below this is always paed
                     age2! = Val(lines$(2))    'The highest age to treat as paed;     above this is always adult
                     wt1! = Val(lines$(3))     'The lowest weight to ask paed/adult;  boundary between paed & ask
                     wt2! = Val(lines$(4))     'The highest weight to ask paed/adult; boundary between ask & adult
                     ReDim lines$(4)                                                                                 '   " Clear Array

                     If NumericalAge! > age2! Or (NumericalAge! >= age1! And Val(pid.weight) > wt2!) Then
                           pid.sex = UCase$(pid.sex)
                        Else
''                           If Val(pid.weight) < wt2! And NumericalAge! >= age1! And NumericalAge! < age2! Then
''                                 sex$ = pid.sex                                    '  "     Save any case change
''                                 chooseadult (pid.dob), (pid.weight), sex$         '  "     in sex$ back to correct
''                                 getpatidL patno&, pid                             '  "     PID record
''                                 pid.sex = Trim$(sex$)                             '  "
''                                 putpatidL patno&, pid                             '  "
''                              Else
''                                 getpatidL patno&, pid
''                                 pid.sex = LCase$(pid.sex)
''                                 putpatidL patno&, pid
''                              End If
                        End If
                     
                     If L.PrescriptionID = 0 Then GetPointerSQL patdatapath$ & "\RxID.dat", L.PrescriptionID, True
                     
                     FormDates                      '25Jan98 CKJ Added
                     L.RxStartDate = L.startdate
                     LSet dcopy = d                 '21Oct98 CKJ/CFY Added to preserve d after PN issue
                     
''                     TpnMain Summary$

                     ExitNow = (Left$(Summary$, 1) = Nul)             '13Nov98 CKJ
                     If ExitNow Then Summary$ = Mid$(Summary$, 2)
                     
                     LSet d = dcopy                 '21Oct98 CKJ/CFY Added

                     deflines Summary$, lines$(), Chr$(LBL_END_LINE), 1, Numoflines
                     For i = 1 To Numoflines          '11Nov97 CKJ Added loop and labelamended
                        If Trim$(TxtLabel(i).text) <> Trim$(lines$(i)) Then LabelAmended = True
                        TxtLabel(i).text = lines$(i)
                        labelline$(i) = lines$(i)   '21Oct98 CKJ/CFY Added to ensure text displays
                     Next
                     
                     SaveLabel 0
                     
''                     If OCXlaunch() Then                              '20Jul98 EAC Added
''                           'ExitNow = False                              '03Mar99 EAC prevent escape happening in OCX mode as it overwrites the status.  '25Aug99 CFY Replaced
''                           ExitNow = True                                '                                                                               '      "
''                           'GetOCXStatus OCXStatus$                                                                                                                              '01Oct99 CFY Removed
''                           'If Trim$(OCXStatus$) = "" Then                                                                                                                       '       "
''                           ''---                                                                                                                                                 '       "
''                           '      If InStr(Summary$, "(Not Authorised)") Then                                                                                                    '       "
''                           '            OCXStatus$ = STATUS_SAVE               '  "    '03Mar99 EAC changed status returned to Saved                                             '       "
''                           '         Else                                                                                                                                        '       "
''                           '            OCXStatus$ = STATUS_AUTH               '  "                                                                                              '       "
''                           '         End If                                                                                                                                      '       "
''                           '   End If                                                                                                                                            '       "
''
''                           Select Case GetOCXAction()
''                              'Case "N", "M"
''                              Case "M"
''                                 GetOCXStatus OCXStatus$
''                                 If OCXStatus$ = STATUS_ISSUE Then
''                                       ReturnPNRegimen pid.recno, L.prescriptionid, "TIME<=" & GetOCXRecoveryTime$()
''                                    End If
''                              End Select
''
''                           LabelAmended = False                        '17Sep98 EAC/CFY Added to prevent QuerySave when exiting TPN
''                           SetOCXLabelParameters L.SisCode, L.IssType, "", "", "", 0, 0
''                        End If

                  End If
''            Else
''                  popmessagecr "ASCribe", "Parenteral Nutrition Module not installed."
''               End If

SKIP_PN:

      Else
''         If MDIEvents.MnuManufacturing.Enabled = True Then '12June97 CKJ/KR Added
               MousePointer = HOURGLASS
               '28Jul99 AE Added to allow saving of patient-specific formula before the prescription is saved
               If L.PrescriptionID = 0 Then GetPointerSQL patdatapath$ & "\RxID.dat", L.PrescriptionID, True
               
               If L.Nodissued = 0 Then         '28Jul99 AE Added to set view mode of formula
                     FormulaMode = 2           'according to drugs issued / not issued
                  Else                         'Prevents changing formula once issued
                     FormulaMode = 0
                  End If
               '01Oct02 TH make check on l here to ensure label saved OK
               CanTheLabelBeSaved intLabelok
               If Not intLabelok Then
                     popmessagecr "!EMIS Health", "The label is not complete and CANNOT be saved in its present form"
                     MousePointer = STDCURSOR
                     Qty! = 0    'Reset qty incase user amends and reissues on same effective pass
                     Exit Sub    '<------------------ WAY OUT
                  End If

               setFromDispens True                 '01Oct02 TH
               setManufactureInfo 0, 0             '    "
               'Set frmFormula = New Formula                                                   '17Jul01 CKJ removed
               'callmanufacturing frmFormula, d, FormulaMode     '28Jul99 AE added parameter   '17Jul01 CKJ removed
               callmanufacturing d, FormulaMode, True                                               '17Jul01 CKJ removed parameter
               If Not k.escd Then UpdateDispensLabel           '07Jun05 TH Added escd flag
               setFromDispens False                '    "

               MousePointer = STDCURSOR
''            Else
''               popmessagecr "ASCribe", "Manufacturing Module not installed."
''            End If
      End If
   
   SetFocusTo TxtPrompt

   If ExitNow Then TxtPrompt_KeyDown 27, 0

End Sub

Private Sub displayOCXdetails(ByVal strAttribute As String, ByVal strValue As String, ByVal strSuffix As String)
'14Feb03 CKJ written
'            "  Surname: ", "Bloggs", ""  print Surname: non-bold and Bloggs in bold
'            "  Surname: ", "", ""        print nothing
'            "", "XYZ", ""                print XYZ in bold
'            "", crlf, ""                 start new line
'09May05 CKJ Changed from plain/bold to italic/plain

   If Len(strValue) Then                            'Item present
         printOCXdetails strAttribute, True  'False
         printOCXdetails strValue, False     'True
         printOCXdetails strSuffix, True     'False
      End If

End Sub

Private Sub DispMnuButHandler(functionCode As Integer)
'08May97 KR Written
'18Nov97 SF allows user to print a medication card on discharge (case 7)
'11May98 CFY Force dose range checking an interactions checking to fire when the authorise button
'            is pressed.
'11Aug98 EAC Added command to return qty for OCX mods
'13Aug98 EAC set protocol Surface area flag
'16Dec98 TH  Write relevant ID's to the label for checking purposes
'17Dec98 TH  Added putlabel to properly save the above
'28Sep99 CFY Now calls DoDischarge in patprint.bas rather than discharge in patmed.bas
'01Jun00 CFY/MMA now does not allow saving an incomplete pmr (event no. 44104)
'03Aug00 CFY Now resets issue type after doing a CIVAS prescription in prescriber mode
'            Moved above mod to correct place in code and also moved a TxtPrompt_KeyUp 0, 0 call so that it fires at what I
'            think is the right place ?!!!
'04Aug00 CFY Another mod to the above to also deal with wardstock issues.
'21Sep00 JN  Added dosage check to allow user to re-enter low/high dosages
'22Sep00 JN  Added 'C' tag to TxtDirCode if a user wants to re-enter a dose. This prevents the Rx being saved first
'29Mar01 CKJ/ASC Added code to forcibly de-select the current PMR line when entering a new line (event 51305)
'03Apr01 CKJ/ASC Added line to force clearing of form and memory structures when using the [New] button.
'                Prevents carry-over of information from previous script e.g. route
'27Jun01 CKJ Added option to inhibit the 'Awaiting Pharmacist' message
'30Oct01 CKJ Call PrescribingWizard from [New] if prescriber & on UserPreferences
'07Nov01 CKJ If Wizard is off then use old style data entry
'15Feb02 TH  Change passlvl requirement for pharmacist check to 4 (#52340)
'11Mar02 TH  Use shift param as a flag to denote the dose is already checked (#49034)
'11Apr02 TH  Changed above mod after discussion with CKJ (this is far safer)
'16May04 TH  Added terminal based switch to force another refresh to fill the route out (#67596)

'Obsolete, removed from 9.3
''   Case 0: TxtPrompt_KeyDown 27, 0     'Exit Dispensary
''   Case 1                              'New prescription
''   Case 2                              'Amend prescription
''   Case 3                              'Discontinue Prescription
''   Case 6: FrmColour.Show              'Display Colour palette
''   Case 7                              'Discharge Letter
''   Case 8                              'Protocol Prescribing
''   Case 9:  LoadBNF                    'Load BNF
''   Case 10: doFormulaAndPN             'Formula/TPN
''   Case 11: TxtDirCode_keyDown 8, 0    'ClearRx
''   Case 12: Editors 10                 'Edit free format labels
''   Case 13: SelectAndPrintFFlabels     'Print free format labels


Dim complete%, ans$
Dim keepmessage%
Dim X As Integer
Dim strReEnterDose$, sngDoses!(), intGetDose%      '21Sep00 JN added to store validity of dosage
ReDim sngDoses(6)                                  '21Sep00 JN redim array

   Select Case functionCode
      Case 4, 5
         '21Sep00 check dose before checking Rx is complete and prevent save if not OK
         For intGetDose = 1 To 6
            sngDoses(intGetDose) = Val(TxtDose(intGetDose).text)
         Next
         CheckDose sngDoses(), strReEnterDose
         If UCase$(strReEnterDose) = "Y" Then      '21Sep00 JN dosage must be re-entered
            ClearDirections                     '21Sep00 JN clear directions here so Rx is not complete
            TxtDircode.Tag = "C"                '22Sep00 JN added 'tag' to directions code to denote cancelled from here
         End If
         
         Select Case functionCode
            Case 4                        'Save Prescription
               If UCase$(strReEnterDose) <> "Y" Then      '21Sep00 JN dosage must be re-entered
                     CheckRxComplete complete            '21Sep00 JN dosage OK so check rx complete
                     If complete Then
                           TxtDirCode_keyDown 13, -2     '11Apr02 TH Changed after discussion with CKJ
                           keepmessage = True            '15Dec98 TH
                           nextchoice$ = "S"
                        End If
                  End If
            
            Case 5                        'Print prescription
               If UCase$(strReEnterDose) = "Y" Then   '21Sep00 JN dosage must be re-entered
                  ClearDirections                  '21Sep00 JN clear directions here so Rx is not complete
                  TxtDircode.Tag = "C"             '22Sep00 JN added 'tag' to directions code to denote cancelled from here
                  Exit Sub                         '21Sep00 JN get out of the routine altogether
               End If
               If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "RxFillRouteOnPrint", 0)) Then TxtDirCode_keyDown 13, -2  '16May04 TH Added (#67596)
               Authorise complete
               If complete Then
                     CheckRxComplete complete
                     If complete Then
                           nextchoice$ = "P"
                           If passlvl = 3 Then Screen.MousePointer = HOURGLASS
                        End If
                  End If
            End Select
   
         TxtPrompt.text = nextchoice$
   
         If (keepmessage) And (Not k.escd) And (passlvl = 4) And (Trim$(L.PharmacistID) = "") Then L.PharmacistID = UserID$    '15Feb02 TH Change passlvl requirement to 4 (#52340)
         TxtPrompt_KeyUp 0, 0
         
         If keepmessage And Not k.escd Then
            If passlvl = 3 Then
               If Trim$(L.PrescriberID) = "" Then
                  L.PrescriberID = UserID$
                  SaveLabel 0               '01Jun00 CFY/MMA added   (event no. 44104)
               End If
            End If
            If LblWarning.Caption = "" Then
               If Trim$(L.PrescriberID) <> "" And Trim$(L.PharmacistID) = "" Then
                  If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "InhibitMessageAwaitingPharmacist", 0)) = False Then '27Jun01 CKJ Added
                     WarningCaption "Awaiting Pharmacist"
                  End If
               End If
               If Trim$(L.PrescriberID) = "" And Trim$(L.PharmacistID) <> "" Then
                  WarningCaption "Awaiting Prescriber"
               End If
            End If
         End If

   End Select

End Sub


Private Sub DispensLoad()
'19Jan00 CKJ Prevent editing within the height/weight/SA text boxes. Not ideal but safe.
'20Oct03 TH  Now resize the form and if necessary the PBS panels. Only put to visible after positioning to prevent flicker
'04May16 XN  Updated for amm 123082

Dim result%, manpn%, found%, severity%, abort$
Dim Value$, success%, TmpDate$, squared$                '25Sep98 CFY Added
Dim PatientName$, SnameFirst%                           '20Nov98 CKJ/CFY
Dim filename$                                           '25May99 CKJ Added

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "DispensLoad"

   On Error GoTo ErrorHandler
   FirstLoaded = False          '18Jun97 KR
   pmc = False                  '18Nov97 SF
  
''   LblPIDInfo(0).Caption = Trim$(pid.caseno)
''   buildname pid, False, PatientName$                                        '   "            Use INI file settings
''   SnameFirst = (InStr(PatientName$, Trim$(pid.surname) & ",") = 1)          '   "            Is the surname first?
''   LblPIDInfo(1).Caption = Trim$(Iff(SnameFirst, pid.surname, pid.forename)) '   "            Select Sn Fn or Fn Sn
''   LblPIDInfo(2).Caption = Trim$(Iff(SnameFirst, pid.forename, pid.surname)) '   "
''   parsedate pid.dob, TmpDate$, "dd/mm/yyyy", 0    '     "
''   LblPIDInfo(3).Caption = TmpDate$                '     "
''   LblPIDInfo(4).Caption = Trim$(pid.ward)
''   LblPIDInfo(5).Caption = Trim$(pid.cons)
''   LblPIDInfo(6).Caption = Trim$(pid.Status)    '20Jul98 ASC
''   SetEpisodicButton CmdEpisodes, (pid.recno)                        '21May99 EAC updated call to SetEpisodicButton
''   If Trim$(pidExtra.EpisodeNum) <> "" Then                             '21May99 EAC Added
''         LblEpisode.Visible = True                              '   "
''         LblEpisodeNo.Caption = pidExtra.EpisodeNum             '   "
''      End If                                                            '   "
''
''   TxtPatDet(0).Text = Trim$(pid.Height)                                    '    "
''   Select Case Val(TxtPatDet(0).Text)                                       '    "
''      Case 0:        LblPatHeight = "Height"                                '    "
''      Case Is <= 10: LblPatHeight = "Height (ft.in)"                        '    "
''      Case Else:     LblPatHeight = "Height (cms)"                          '    "
''   End Select                                                               '    "
''   TxtPatDet(1).Text = Trim$(pid.weight)                                    '    "
''   LblCalcSA = SurfaceArea((TxtPatDet(0).Text), (TxtPatDet(1).Text))        '    "
''   PatSurfaceArea! = pidExtra.SurfaceArea                                   '    "
''   If PatSurfaceArea! = 0 Then PatSurfaceArea! = Val(LblCalcSA)             '    "
''   TxtPatDet(2).Text = Format$(PatSurfaceArea!, "0.00;-0.00;0")             '    "
''   Load FrmColour               '30Jun98 CFY/CKJ Added

   Picture1.Visible = False
'>>   automation$ = txtd$(dispdata & "\patmed.ini", "", "", "Automationdb", found)
'>>   UsePigeon$ = txtd$(dispdata & "\patmed.ini", "", "", "UsePigeon", found)
   
   'Check if printing batch numbers on label
   BatchLabel$ = TxtD(dispdata & "\patmed.ini", "", "", "LabelBatchNo", found)
   
'>>   Show

   '12Jun97 KR Check whether using TPN & Manufacturing
   manpn = 0
   If gRequestID_AmmSupplyRequest <> 0 Then manpn = 4
'>>   If MDIEvents.MnuTpnprogs.Enabled = True Then manpn = 1
'>>   If MDIEvents.MnuManufacturing.Enabled = True Then manpn = manpn + 2

   Select Case manpn
      Case 0
         CmdPrompt(8).Enabled = False
      Case 1
         CmdPrompt(8).Caption = "PN"
         CmdPrompt(8).Enabled = True
      Case 2
         CmdPrompt(8).Caption = "Formula"
         CmdPrompt(8).Enabled = True
      Case 3
         CmdPrompt(8).Caption = "Formula"          '   "
         CmdPrompt(8).Enabled = True
      Case 4
         CmdPrompt(8).Enabled = False
         TxtPrompt.Visible = False
         lblPrompt(0).Visible = False
         lblPrompt(1).Visible = False
         lblPrompt(2).Visible = False
         lblPrompt(3).Visible = False
         TxtQtyPrinted.Enabled = False
                 CmbIssueType.Enabled = False
      End Select

   onloadingdispens
   If StopEvents Then           '18Feb98 CKJ failed to load patient records eg locked
''      patno& = 0              '08Nov05 CKJ
      r.record = ""
      LSet pid = r      '**!!** needs thought
      Exit Sub               '18Feb98 CKJ Added              <=== WAY OUT
                         
   Else
      MnuDisplay_Click 4    '09May05 should not do this here    ' View All '
   End If
   
''   checkPMRinteractions False, "", d.Description, True, severity%, abort$, False
   Select Case severity                                                                    '26Dec98 ASC
      Case 0: filename$ = ""
      Case 1: filename$ = AppPathNoSlash() & "\warn.bmp"
      Case 2: filename$ = AppPathNoSlash() & "\action.bmp"
      End Select                                                                           '26Dec98 ASC
   On Error Resume Next                                                                    '25May99 CKJ Added error handling

   PctCmd(0).Picture = LoadPicture(filename$)
   If Err Then popmessagecr ".WARNING", "Unable to load " & filename$ & crlf & crlf & "Interaction button can not display icon for severity."
   On Error GoTo 0
      
''   SetLastUpdateLbl 2                     '20Jul98 ASC

   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "EnableReprints", 0)) = True Then
         ''LblPrompt = "N/A/D/S/P/R/?"
      End If

''   SetTextBoxReadOnly TxtPatDet(0), True   '19Jan00 CKJ Prevent editing within the text boxes
''   SetTextBoxReadOnly TxtPatDet(1), True   '   "
''   SetTextBoxReadOnly TxtPatDet(2), True   '   "
''   TxtPatDet(0).Enabled = False            '   "
''   TxtPatDet(1).Enabled = False            '   "
''   TxtPatDet(2).Enabled = False            '   "

   If isPBS() Then
         PBSPatientLoad
         '20Oct03 TH Now resize the form and if necessary the PBS panels. Only put to visible after positioning to prevent flicker
         SetupDispensForm
         If PBSIsScreenBigEnough() Then
            F3D2.Top = picOCXdetails.Top + 450
            F3D1.Top = picOCXdetails.Top + 700
            F3D1.Width = picOCXdetails.Width - 100
            F3D2.Width = picOCXdetails.Width - 100
            F3D1.Left = picOCXdetails.Left + 50
            F3D2.Left = picOCXdetails.Left + 50
            F3D1.Visible = True
            F3D2.Visible = True
         End If
      End If

''   mnuMechDispEnquiry.Visible = (txtd(dispdata$ & "\mechdisp.ini", "", "0", "total", 0) <> "")      '24Feb04 CKJ added

Cleanup:
'   On Error Resume Next
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Sub

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Sub

''Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
'''03Oct96 KR added On error
'''17Feb98 CKJ As forms get used for other purposes this becomes inappropriate
'''            Ideally, only specific forms should be unloaded here, but until
'''            then add a list of forms to NOT unload, e.g. frmHeap
'''            - as per Ident.frm Queryunload
''
'''**!!** not fired under UserControl
''
''Dim i As Integer, hWndHeap%
''
''   'Unload all loaded forms (both visible and invisible)
''   Heap 21, hWndHeap, "", "", 0                                               '17Feb98 CKJ
''   On Error Resume Next
''   For i = (Forms.count - 1) To 0 Step -1 '0 To forms.Count - 1
''      If Forms(i).hWnd <> MDIEvents.hWnd And Forms(i).hWnd <> hWndHeap Then
''      If Forms(i).hWnd <> hWndHeap Then
''            Unload Forms(i)
''         End If
''   Next
''   On Error GoTo 0
''
''End Sub

''Private Sub Form_Resize()
''
''   SetupDispensForm
''
''End Sub

''Private Sub Form_Unload(Cancel As Integer)
''
''**!!** not fired under UserControl
''
''   'Reset form level variables.
''   dfirstloaded = False
''   tFirstLoaded = False
''   FirstLoaded = False
'''*****************************************************
'''  CLEAR BAS module Declares
'''*****************************************************
''   ClosePatsubs
''   ClosePatMed
''   CloseSubPatMed
''
''End Sub

''Private Sub ImgColour_Click()
''
''   DispMnuButHandler 6
''
''End Sub

''Private Sub LblCalcSA_Change()
'''31Jan01 CKJ Added
''
''                        'If      Calculated SA <> Dosing SA        then black else grey
''   LblCalcSA.ForeColor = Iff(LblCalcSA.Caption <> TxtPatDet(2).Text, QBColor(0), QBColor(8))
''
''End Sub

''Private Sub LblCalcSA_DblClick()
''
''Dim ans$
''
''   If Not OCXlaunch() Then     '10nov03 CKJ
''         ans$ = "N"
''         Confirm "Update", "update Dosing Surface Area with Calculated Surface Area", ans$, k
''         If ans$ = "Y" And Not k.escd Then
''               TxtPatDet(2).Text = LblCalcSA.Caption
''            End If
''      End If
''
''End Sub

''Private Sub mnuAbout_Click()
''
''   ShowAboutBox "ASCribe Prescription Module"
''
''End Sub

Private Sub MnuDisplay_Click(Index As Integer)
'22Nov96 made  work and put if labelamemnded in the proc
'21Mar97 KR Added extra parameter to DisplayTheLabelAndForm
'08Apr97 KR Clear directions ect on form from previous view
'13May97 KR Disable/Enabled Prescription menu items depending on whether history checked.
'12Jun97 KR added for "P" for tpn items.
'04Jun97 KR Ensured that when you first go into a new patient in prescriber mode, the l.isstype
'           defaults to the patient status.
'07Apr99 TH disable protocol button if history
'14Mar00 TH Added to show no of items in view
'24May00 AE Moved above function into separate procedure, SetTGCaption, as we need to update
'           the items in view from a number of different places.
'20Jul00 MMA Added to ensure the correct line on the pmr is restored to view when going between history and current views on the pmr.

Dim msg$, Changed%, X%, ans$, setvis%, History%, Display$, expiry$, found%

''   For X = 1 To 4
''      MnuDisplay(X).Checked = (X = index)
''   Next

'**!!**Stop

   '08Apr97 KR Clear bits on form from previous
   StopEvents = True
   TxtDrugCode = ""
   TxtDircode = ""
   StopEvents = False
   
   QuerySave ans$
''   If MnuHistory.Checked Then
''         currentlab& = Labf&           '20jul00 MMA added
''         setvis = False
''         History = True
''      Else
''         historylab& = Labf&            '20jul00 MMA added
         setvis = True
''      End If
   
''   For X = 0 To 4
''      CmdPrompt(X).Enabled = setvis
''      MnuScript(X).Enabled = setvis     '13May97 KR added
''   Next

''   CmdPrompt(2).Enabled = setvis
''   CmdPrompt(3).Enabled = setvis
''   CmdPrompt(4).Enabled = setvis
   
''   CmdPrompt(9).Enabled = setvis '07Apr99 TH disable protocol button if history
   
''   For X = 1 To 4
''      If MnuDisplay(X).Checked Then Display$ = Display$ + MnuDisplay(X).Tag
''   Next

   Display$ = Display$ & "P" '12Jun97 KR added for tpn.
   clearlabel L
   Erase labelline$

   '04Apr97 KR Added if any labels marked to history, pmr updated.
'>>   SelectRx History, Display$ + "CAP", Changed '14Nov94 P added ASC
'>>   If Changed Then putpmr pmrptr&, (pid.recno)
   '16Feb96 EAC - select the first item in the list if present
   '10Oct96 ASC changed for true grid
    
'>>    If TGLabelList.Rows > 0 Then
'>>         TGLabelList.MarqueeStyle = 3
'>>         TGLabelList.RowIndex = 1 'select first item in list
'>>      Else
         'clear label display
'>>         TGLabelList.MarqueeStyle = 5
'>>      End If
   
'   DisplaytheLabAndForm 1, 0, k.escd, expiry$, 0

'>>   SetTGCaption                                                                  '24May00 AE Replaces above
   
   setP

   Picture1.Visible = True 'make the main form visible

   If passlvl = 3 Then
         '04Jun97 KR added.  Ensures that when you first go into a new patient, the l.isstype defaults
         'the patient status.
         If Trim$(L.IssType) = "" Then
               L.IssType = pid.status
               CheckIssType 2
            End If
      End If

''   If MnuHistory.Checked Then                '20jul00 MMA added
''      Labf& = historylab&                    '       ''
''    Else                                     '       ''
''      Labf& = currentlab&                    '       ''
''    End If                                   '       ''
   
''   MoveToRx Labf&, found%, False                   '       ''      **!!**V93 Cannot be right to call this now

   SetFocusTo TxtPrompt

End Sub

'Private Sub mnuEdit_Click(Index As Integer)
'10May97 KR added.
'20oct08 CKJ commented out unused code to save space
'
'   Select Case Index
'      Case 0: UndoCutCopyPasteDel 1
'      Case 1: UndoCutCopyPasteDel 2
'      Case 2: UndoCutCopyPasteDel 3
'      Case 3: UndoCutCopyPasteDel 4
'      End Select
'
'End Sub


'Private Sub MnuInfoTitle_Click()
''24Feb04 CKJ Added
'20oct08 CKJ commented out unused code to save space
'
'Dim MachineType As String
'
'''   mnuMechDispEnquiry.Enabled = LocationForMechDisp(d.loccode, MachineType)
'''   mnuMechDispEnquiry.Caption = "Stock in " & Iff((mnuMechDispEnquiry.Enabled), MachineType, "machine")
'
'End Sub


Private Sub MnuIssue_Click()
'Call TxtPrompt_KeyUP with code 119 to simulate the pressing of the F8 issue key
'02Feb98 CFY Added call to querysave so that label is saved before issue occurs.

Dim ans$
                                                                            
   If passlvl <> 3 Then
         QuerySave ans$
         If ans$ = "Y" And Not LabelAmended Then
               TxtPrompt_KeyUp 119, 0
            Else
               LabelAmended = True
            End If
      End If

End Sub

''Private Sub MnuLabel_Click()
'''18Jan97 KR Added select case
'''24Aug99 SF added code to refresh and stop the bag label info being saved on the pmr label if doing a save straight after printing a bag label
'''21Feb00 SF stop patient name being saved on the label when a save is done straight after an F7 bag label print
''Dim tmpLabelAmended%    '21Feb00 SF added
''
''   Select Case UserControl.ActiveControl.hWnd
''      Case TxtLabel(0).hWnd
''      Case TxtLabel(1).hWnd
''      Case TxtLabel(2).hWnd
''      Case TxtLabel(3).hWnd
''      Case TxtLabel(4).hWnd
''      Case TxtLabel(5).hWnd
''      Case TxtLabel(6).hWnd
''      Case TxtLabel(7).hWnd
''      Case TxtLabel(8).hWnd
''      Case TxtLabel(9).hWnd
''      Case Else
''         If passlvl <> 3 Then
''               lblprn = 1 ' **!!
''               patlabel k, pid, True, 1
''            End If
''      End Select
''
''End Sub

Sub PrintBagLabel()

   patlabel k, pid, True, 1
   
End Sub

'Private Sub mnuMechDispEnquiry_Click()
''16feb04 ckj
''10Feb07 CKJ Added strMessage parameter. No popmessage needed as it is on display already
'20oct08 CKJ commented out unused code to save space
'
'Dim success As Integer
'Dim MachineType As String
'Dim QuantityStocked As String
'Dim strMessage As String
'
'   If MechDispEnquiry(d, MachineType, QuantityStocked, strMessage) Then    '10feb07 CKJ
'         'No message because it worked and is in the floating window
'      Else
'         If MachineType = "<UNKNOWN>" Then
'               popmessagecr "#", "Dispensing machine not specified for this item"
'            Else
'               popmessagecr "#", MachineType & " not available"      'Shows 'Swisslog' if it should have linked but could not
'            End If
'      End If
'
'End Sub

''Private Sub MnuMonitorKinetics_Click()
''19Jul99 AE Added procedure
''
''   MnuMonitorKinetics.Checked = Not (MnuMonitorKinetics.Checked)
''
''End Sub

Private Sub mnuOptionsHdg_Click()
'24sep01 CKJ Added
                   
''   mnuSetWarnings(0).Enabled = TrueFalse(txtd(dispdata$ & "\ASCribe.ini", "PMRinteractions", "N", "AllowProtocolWarningSuppression", False))
''   mnuSetWarnings(1).Enabled = TrueFalse(txtd(dispdata$ & "\ASCribe.ini", "PMRinteractions", "N", "AllowNonProtocolWarningSuppression", False))

End Sub

Private Sub MnuOriginalDate_Click()
'31Jan03 TH (PBSv4) Added proc
Dim X%
 
   X = billpatient(11, "")

End Sub

''** If changing details of the prescriber is wanted in V9 then it should be done in the web, not here
''Private Sub mnuPrescriber_Click()
'''16Nov00 SF added to allow prescriber to be changed
'''           !!** was used previously as PBS re-submit but never used
''
''Dim success%
''Dim PatientName$
''
''   GetPrescriberDetails True, "", success
''   If success Then
''          ' update label with the new prescriber code
''         buildname pid, True, PatientName$
''         TxtLabel(9).Text = Left$((PatientName$ & " (" & Trim(pid.ward) & " " & ReplaceConsWithRxer$() & " " & Trim(pid.caseno) & ")" & Space$(36)), 36)
''         FillHeapPrescriberInfo gPRNheapID, gPrescriberDetails, 0
''      End If
''
''End Sub

''Private Sub MnuPrescription_Click()
'''14Sep00 JN commented out earlier code and replaced by call to new routine
'''   "     " FlipFlopRxView, which is the old TxtPrompt_KeyUp routine for F5 (event 47254)
''
''   FlipFlopRxView
''
''End Sub

Private Sub mnuResubmit_Click()
'16Nov99 SF added for PBS to allow transactions to be re-submitted to HIC

   ReSubmit

End Sub

Private Sub MnuReturn_Click()
'Call TxtPrompt_KeyUP with code 120 to simulate the pressing of the F9 return key
'12Mar98 CFY added call to query save so that label is saved before return occurs.

Dim ans$

   If passlvl <> 3 Then
         QuerySave ans$
         If ans$ = "Y" And Not LabelAmended Then
               TxtPrompt_KeyUp 120, 0
            Else
               LabelAmended = True
            End If
      End If

End Sub

''Private Sub mnuScript_Click(index As Integer)
''
''   Select Case index
''      Case 0: DispMnuButHandler 1  'new label
''      Case 1: DispMnuButHandler 2  'amend label
''      Case 2: DispMnuButHandler 3  'discontinue label
''      Case 3: DispMnuButHandler 4  'save label
''      Case 4: DispMnuButHandler 5  'print label
''      Case 6: DispMnuButHandler 0  'Exit Dispensary
''      End Select
''
''End Sub

Private Sub mnuSetWarnings_Click(Index As Integer)
'24sep01 CKJ written
'            We won't be here unless the option has been enabled in ASCRIBE.INI
'            Index 0 is protocol
'                  1 is non-protocol
Dim intSuccess As Integer
Dim sMsg As String
   
   sMsg = "Could not store User Preference setting" & cr & "Please inform Sytem Manager immediately"
   Select Case Index
      Case 0
         intSuccess = ChangeUserPreference(UserID$, "ShowProtocolWarnings")
         If intSuccess = 0 Then popmessagecr ".", sMsg                           'Success -1, fail 0, escape/timeout 1
      Case 1
         intSuccess = ChangeUserPreference(UserID$, "ShowNonProtocolWarnings")
         If intSuccess = 0 Then popmessagecr ".", sMsg                           'Success -1, fail 0, escape/timeout 1
      End Select

End Sub

'Private Sub MnuShowPrescriber_Click()
'31Jan03 TH (PBSv4) Written (shamelessly robbed from [somewhere])
'31Jan03 TH (PBSv4) MERGED
'20oct08 CKJ commented out unused code to save space
'
'      Dim db As Database
'      Dim snap As Snapshot
'      Dim SQL$, Patdb$
'      Dim numLbls&, found&, foundInRX&
'      Dim rxid$, rxernum$
'      Dim billingtype%
'      Dim rxnum%
'      Dim rxsnap As Snapshot, rxerDB As Database, rxname$
'
'         billingtype = Val(TxtD(dispdata$ & "\PATBILL.INI", "PatientBilling", "", "BillingType", 0))
'         If (TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "PatientBilling", "N", "BillPatient", 0)) And ((billingtype = 1) Or (billingtype = 2) Or (billingtype = 3))) Then   '14Jul00 SF added Repeat Dispensing
'               If Not fileexists(dispdata$ & "\RXER.MDB") Then
'                     popmessagecr "#ASCribe", "The prescriber database does not exist" & cr & "File: " & dispdata$ & "\RXER.MDB not found"
'                     Exit Sub
'                  End If
'
'               On Error GoTo ShowRxerErr
'               Patdb$ = Trim$(TxtD(dispdata$ & "\PATBILL.INI", "PatientBilling", "", "MDBpathName", 0))
'               SQL$ = "SELECT prescriberID, prescribernumber FROM transactions WHERE rxnumber = " & Format$(Abs(Labf&)) & ";"
'               Set db = OpenDatabase(Patdb$)
'               Set snap = db.CreateSnapshot(SQL$)
'               If Not snap.EOF Then
'                     rxid$ = Trim$(GetField(snap!prescriberid))
'                     If Trim$(rxid$) = "" Then rxid$ = "NOT ENTERED"
'                     rxernum$ = Trim$(GetField(snap!prescriberNumber))
'                     If Trim$(rxernum$) = "" Then rxernum$ = "NOT ENTERED"
'                     'Get prescriber name from rxer mdb
'                     On Error GoTo ShowRxnameErr
'                     Set rxerDB = OpenDatabase(dispdata$ & "\RXER.MDB")
'                     Set rxsnap = rxerDB.CreateSnapshot("select name from prescribers where prescribers.code = '" & rxid$ & "'")
'                     If Not rxsnap.EOF Then
'                        rxname$ = Trim$(GetField(rxsnap!name))
'                     Else
'                        rxname$ = "NOT KNOWN"
'                     End If
'                     rxsnap.Close: Set rxsnap = Nothing
'                     rxerDB.Close: Set rxerDB = Nothing
'
'                     On Error GoTo ShowRxerErr
'                     '---------------------------------
'                     popmessagecr "#Ascribe Patient Billing", "Prescriber details for this line ;" & crlf & crlf & "Prescriber Name = " & rxname$ & crlf & crlf & "Prescriber ID = " & rxid$ & crlf & crlf & "Prescriber Number = " & rxernum$
'                  Else
'                     popmessagecr "#Ascribe Patient Billing", "Prescriber details not known for this line "
'                  End If
'               snap.Close: Set snap = Nothing
'               db.Close: Set db = Nothing
'               '
'               On Error GoTo 0
'            Else
'               popmessagecr "#", "PBS module not installed"
'            End If
'
'ShowRxerExit:
'         On Error GoTo 0
'      Exit Sub
'
'ShowRxerErr:
'         On Error Resume Next
'         snap.Close: Set snap = Nothing
'         db.Close: Set db = Nothing
'      Resume ShowRxerExit
'
'ShowRxnameErr:
'         On Error Resume Next
'         rxsnap.Close: Set rxsnap = Nothing
'         rxerDB.Close: Set rxerDB = Nothing
'      Resume ShowRxerExit
'
'End Sub

Private Sub MnuStockLevel_Click()
'26Dec98 ASC Calls the stores program to display the F4 page
'24May99 CKJ Use App.Path instead of progsdrv
'13nov03 CKJ removed /OCX as winord should not try to start in OCX mode
'16May04 TH  Added passlvl for UMMC enhancement (hide price)
'03Jun08 TH  launch new stores !
'30Jun05 CKJ Added to ensure robots are disconnected  '20May08 CKJ ported from V8.8
'17oct08 CKJ Replaced shell with internal stock enquiry

'Dim success%
'Dim strCommand As String
   
   IPLinkShutdown                                                                '30Jun05 CKJ Added to ensure robots are disconnected

'   strCommand = UCase$(Command$)
'   replace strCommand, "/OCX", "", 0
'   replace strCommand, "  ", " ", 0
'   On Error Resume Next
'   strCommand = "  " & SiteNumber & " /SID" & Format$(g_SessionID)
'   'success = Shell(AppPathNoSlash() & "\winord.exe " & strCommand & " /de" & d.SisCode & " /pl" & CStr(passlvl))  '16May04 TH Added passlvl for UMMC enhancement
'   success = Shell(AppPathNoSlash() & "\ICWStores.exe " & strCommand & " /de" & d.SisCode & " /pl" & CStr(passlvl))  '16May04 TH Added passlvl for UMMC enhancement
'   If Err.Number Then
'      On Error GoTo 0
'      popmessagecr "!", "Stock level viewer not configured"
'
'   End If
      
   SiteDrugEnquiryDISP d.SisCode, passlvl

End Sub

''Private Sub MnuTools_Click(index As Integer)
''
''   Select Case index
''      Case 0: DispMnuButHandler 6   'Show Colour palette
''      Case 1: DispMnuButHandler 7   'Discharge Letter
''      Case 2: DispMnuButHandler 8   'Protocol Prescribing
''      Case 3: DispMnuButHandler 10  'Formula/TPN
''              '20Jul98 EAC
''              If OCXlaunch() And GetTpnExit() Then
''                    GetOCXStatus OCXStatus$                    '01Oct99 CFY Added
''                    SignalASCDone OCXStatus$, Labf&, True      '20Jul98 EAC
''                 End If
''              '---
''      Case 4:                       'separator bar
''      Case 5: DispMnuButHandler 12  'Edit FFlabel
''      Case 6: DispMnuButHandler 13  'Print FFlabel
''      End Select
''
''End Sub

''Private Sub MnuTopup_Click()
''
''   If passlvl <> 3 Then ChangeTopupDate
''
''End Sub

'Private Sub mnuUseWizard_Click(Index As Integer)
'30Oct01 CKJ written
'            Index 0 is prescribing wizard from the [New] button
'20oct08 CKJ commented out unused code to save space
'
'      Dim intSuccess As Integer
'      Dim sMsg As String
'
'         sMsg = "Could not store User Preference setting" & cr & "Please inform Sytem Manager immediately"
'         Select Case Index
'            Case 0
'               intSuccess = ChangeUserPreference(UserID$, "UsePrescribingWizard")
'               If intSuccess = 0 Then popmessagecr ".", sMsg                           'Success -1, fail 0, escape/timeout 1
'            End Select
'
'End Sub

''Private Sub MnuViewKinetics_Click()
'19Jul99 AE Added procedure

'Will need paramaterising when Kinetics is compiled as a component.
'Items will have to be passed in, and items such as the recommended dose info
'for RecWriteBack will have to be passed back as a result

''   HandleFrmKinet

   'RecWriteBack (Params Out)

''End Sub

'Private Sub MoveListHighLight(lines)
'Dim ans$, length%, curpos%
'
'   QuerySave ans$
'   If Not LabelAmended Then
''         length = TGLabelList.Rows       ' n
''         curpos = TGLabelList.RowIndex   ' 1 to n
''         If length > 0 Then
''               curpos = curpos + lines
''               If curpos < 1 Then curpos = 1
''               If curpos > length Then curpos = length
''
''               If curpos <> TGLabelList.RowIndex Then
''                     If TGLabelList.MarqueeStyle = 5 Then curpos = 1
''                     TGLabelList.MarqueeStyle = 3
''                     TGLabelList.RowIndex = curpos
''                  End If
''            End If
'      End If
'   setP
'
'End Sub

''Private Sub PctCmd_Click(index As Integer)
'''26Dec98 ASC makes sure the picture on the button still react like rest of button to mouse click
''
''   Select Case index
''      Case 1, 2
''         CmdEdit_Click index
''      Case 3
''         CmdInteractions_Click
''      End Select
''
''End Sub

'Private Sub PrescribingWizard()
'30Oct01 CKJ Written
'            Derived from older prescribing sequence in TxtPrompt_KeyUp
'07Nov01 CKJ Allow duration to be blanked if user selects OK with blank entry & set prompt to 'not specified'
'            Allow dose to be blanked if user selects OK with blank entry & set prompt to 'not specified' with PRN warning
'            Remove [cr] from directions before display
'            Added block to cope with compound direction with dose embedded
'            For dose only show in issue units and dosing units if these are different (dosesperissueunit<>1)
'10Nov01 CKJ Prompt can be set from patmed.ini [Messages] PrescribingWizardPrompt="text over[cr]several lines"
'18Mar02 TH  Added tag to keypad to pick up new validation on dose entry (#59667)
'05Apr02 CKJ Changed tag from "dose" to "1."
'15Apr02 CKJ detects if the drug was accepted during EnterDrug - user may abort entry if an interaction is found
'05Sep02 SF  implemented AllSides for the route selection when necessary (#61906)
'14Feb03 CKJ Can now prefill items from OCXheap
'20Feb04 CKJ Use dose, dosing units and directioncode where available
'20Feb04 CKJ add duration if specified  e.g. lStartDate=2004-02-20T00:00:00  lStopDate=2004-02-21T00:00:00 => /1d
'23feb04 CKJ Added block to extract route from Heap
'24Feb04 CKJ Only show items where present
'20oct08 CKJ commented out unused code to save space
'
'      Dim blnDone As Integer
'      Dim intloop As Integer
'      Dim strDefaults As String
'      Dim strLabelType As String
'      Dim strMainPrompt As String
'      Dim strExtraPrompt As String
'      Dim strLabelDefault As String
'      Dim strDrug As String
'      Dim blnFound As Integer
'      Dim strTemp As String
'      Dim sngKeypadValue As Single
'      Dim intNumRoutes As Integer
'      Dim strExpansion As String
'      Dim intNumDirections As Integer
'      Dim strProduct As String
'      Dim strDirCodes As String
'      Dim strPrompt As String
'      Dim strDose As String
'      Dim FromDate As String
'      Dim ToDate As String
'      Dim lngDuration As Long
'      Dim valid As Integer
'
'         strMainPrompt = "Select the steps required individually or as a group" & Space$(20) & crlf & "Finish becomes available when minimum details have been entered" & crlf
'         strMainPrompt = TxtD(dispdata$ & "\patmed.ini", "Messages", strMainPrompt, "PrescribingWizardPrompt", 0)
'         If Len(OCXheap("UserID", "")) Then           '14feb04 CKJ OCX data has been provided, so add to top label
'            strMainPrompt = strMainPrompt & crlf
'
'            strMainPrompt = strMainPrompt & DetailHandler("Product:  ", OCXheap("iDescription", ""), crlf)
'            strMainPrompt = strMainPrompt & DetailHandler("NSV code:  ", OCXheap("iNSVcode", ""), crlf)
'            strMainPrompt = strMainPrompt & DetailHandler("Local code:  ", OCXheap("iLocalCode", ""), crlf)
'            strMainPrompt = strMainPrompt & DetailHandler("Tradename:  ", OCXheap("iTradename", ""), crlf)
'            strMainPrompt = strMainPrompt & DetailHandler("BNF code:  ", OCXheap("iBNF", ""), crlf)
'            strMainPrompt = strMainPrompt & DetailHandler("Chemical:  ", OCXheap("iChemical", ""), crlf)
'            strMainPrompt = strMainPrompt & DetailHandler("PIP code:  ", OCXheap("iPIPcode", ""), crlf)
'            strMainPrompt = strMainPrompt & DetailHandler("Barcode:  ", OCXheap("iBarcode", ""), crlf)
'            strMainPrompt = strMainPrompt & DetailHandler("Lookup:  ", OCXheap("iCode", ""), crlf)
'
'            strMainPrompt = strMainPrompt & DetailHandler("PrescriptionID:  ", OCXheap("lPrescriptionid", ""), crlf)
'            strMainPrompt = strMainPrompt & "Dose:  " & OCXheap("ldose", "-") & " " & OCXheap("idosingunits", "") & crlf
'            strMainPrompt = strMainPrompt & "Directions:  " & OCXheap("lDirCode", "-") & crlf
'            strMainPrompt = strMainPrompt & "Route:  " & OCXheap("lRoute", "-") & crlf
'            strMainPrompt = strMainPrompt & "Text:  " & OCXheap("lText", "-") & crlf
'            strMainPrompt = strMainPrompt & "Start:  " & OCXheap("parsedStartDate", "-") & crlf
'            strMainPrompt = strMainPrompt & "Stop:  " & OCXheap("parsedStopDate", "-") & crlf
'         End If
'         ParseCtrlChars dispdata$ & "\printer.ini", "Screen", strMainPrompt, 0
'
'         strExtraPrompt = ""
'
'         ReDim strLabelTypes(1 To 8) As String
'         strLabelTypes(1) = "In-patient"
'         strLabelTypes(2) = "Out-Patient"
'         strLabelTypes(3) = "Discharge"
'         strLabelTypes(4) = "Leave"
'         strLabelTypes(5) = "Ward Stock"
'         strLabelTypes(6) = "CIVAS"
'         strLabelTypes(7) = "Self Medication"
'         strLabelTypes(8) = "Parenteral Nutrition"
'
'         ReDim strPrompts(1 To 7, 1 To 3) As String
'         strPrompts(1, 1) = "Prescription &Type:  "          '(x, 1) Display prompt  (x, 2) Code to use  (x, 3) Expansion of code
'         strPrompts(2, 1) = "&Product:  "
'         strPrompts(3, 1) = "&Dose:  "
'         strPrompts(4, 1) = "&Frequency:  "
'         strPrompts(5, 1) = "&Course Duration:  "
'         strPrompts(6, 1) = "&Route:  "
'         strPrompts(7, 1) = "&FINISH"
'
'         strPrompts(1, 2) = Left$(CmbIssueType.text, 1)
'         strPrompts(1, 3) = CmbIssueType.text
'
'         ReDim blnStatus(1 To 7) As Integer
'         blnStatus(1) = True
'         For intloop = 2 To 7
'            blnStatus(intloop) = False
'         Next
'
'         ReDim strDirections(1 To 10) As String
'
'         strDefaults = "0111110"
'         blnDone = False
'
'         Do
'            frmoptionset 0, "Prescribe New Item"                                                        'initialise as checkboxes
'            frmoptionset -2, strMainPrompt & strExtraPrompt                                             'set heading
'            If InStr(strPrompts(6, 2), ",") Then                                                        'route has a comma
'               Mid$(strDefaults, 6, 1) = "1"                                                         'set checkbox
'               blnStatus(6) = False                                                                  'status not completed
'            End If
'
'            blnStatus(7) = True                                                                         'assume finish available
'            For intloop = 1 To 6
'               frmoptionset 1, strPrompts(intloop, 1) & strPrompts(intloop, 3)                          'set first 6 prompts
'               If blnStatus(intloop) = False Then blnStatus(7) = False                                  'and check if completed
'            Next
'
'            If blnStatus(7) Then                                                                        'finish this time
'               frmoptionset 1, strPrompts(7, 1)
'               frmoptionshow "0000001", strDefaults
'            Else                                                                                     'not ready to finish
'               frmoptionset 1, strPrompts(7, 1) & Nul                                                'grey out "FINISH"
'               frmoptionshow (strDefaults), strDefaults
'            End If
'            frmoptionset 0, ""                                                                          'unload
'
'            If strDefaults = "" Then                                                                    'escaped
'               blnDone = True
'            Else
'               k.escd = False
'               If InStr(Left$(strDefaults, 6), "1") Then                                             'one or more changes wanted
'                  Mid$(strDefaults, 7, 1) = "0"                                                   'remove FINISH option
'               End If
'
'               '1 Choose Prescription Type
'               If Mid$(strDefaults, 1, 1) = "1" Then
'                  frmoptionset -1, "Select Prescription Type"
'                  strLabelDefault = ""
'                  For intloop = 1 To 8
'                     frmoptionset 1, "&" & strLabelTypes(intloop)
'                     If strPrompts(1, 2) = Mid$("IODLWCSP", intloop, 1) Then strLabelDefault = Format$(intloop)
'                  Next
'                  frmoptionshow strLabelDefault, strLabelType
'                  frmoptionset 0, ""
'                  If strLabelType <> "" Then
'                     strPrompts(1, 3) = strLabelTypes(Val(strLabelType))
'                     strPrompts(1, 2) = Left$(strPrompts(1, 3), 1)
'                  End If
'                  Mid$(strDefaults, 1, 1) = "0"
'               End If
'
'               '2 Choose Product
'               If Not k.escd And Mid$(strDefaults, 2, 1) = "1" Then                                  'derived from enterdrug
'                  'strDrug = "BNF"                                                                '14Feb03 CKJ removed
'                  strDrug = OCXheap("ProductLookup", "BNF")                                       '   "        added block
'                  strProduct = OCXheap("iChemical", "")
'                  strProduct = OCXheap("iTradename", strProduct)
'                  strProduct = OCXheap("iDescription", strProduct)
'                  If Len(strProduct) Then
'                     strDrug = strDrug & Chr$(127) & strProduct
'                  End If
'
'                  Finddrug.CmdAll.Enabled = (siteinfo$("FormularyEXT", "") <> "")                 '03May01 CKJ swap to use enabled
'                  Finddrug.CmdAll.Visible = Finddrug.CmdAll.Enabled                               '            set visible from this
'
'                  GetSetLocalWardListCode True, pid.ward                                          '09Apr01 CKJ added to set ward code
'                  findrdrug strDrug, False, d, 0, blnFound, 0, False
'                  If Not blnFound Then                                                            '14Feb03 CKJ Added
'                     k.escd = True                                                             '   "
'                     Heap 12, g_OCXheapID, "ProductLookup", "", 0                              '   "    remove from heap, force BNF lookup next time
'                  End If                                                                       '   "
'
'                  If Not k.escd Then
'                     strPrompts(2, 2) = Trim$(d.SisCode)                                       'NSVcode
'                     strPrompts(2, 3) = Trim$(d.Description)                                   'description
'                     plingparse strPrompts(2, 3), "!"
'                     blnStatus(2) = True                                                       'set status to completed
'                     strExtraPrompt = ""                                                       'clear extra direction
'
'                     strDefaults = "0011110"                                                   'reset defaults list
'                     For intloop = 3 To 6                                                      'reset prompts 3 to 6
'                        strPrompts(intloop, 2) = ""
'                        strPrompts(intloop, 3) = ""
'                        blnStatus(intloop) = False
'                     Next
'
'                     '23feb04 CKJ Added block to extract route from Heap
'                     'If Trim$(d.route) <> "" Then                                             'check route(s)
'                     If OCXheap("lroute", "") <> "" Then
'                        strPrompts(6, 2) = UCase$(OCXheap("lroute", ""))
'                        strPrompts(6, 3) = strPrompts(6, 2)
'                        If InStr(strPrompts(6, 2), ",") = 0 Then                            'no comma so just one route
'                           strTemp = TxtD(ASCFileName("Route.ini", True, ""), "AllSides", "", strPrompts(6, 2), blnFound)
'                           If Not blnFound Then
'                              Mid$(strDefaults, 6, 1) = "0"                           'remove from defaults list
'                              blnStatus(6) = True                                     'set status to completed
'                           End If
'                        End If
'                        If UCase$(strPrompts(6, 2)) = "TOP." Then                           'Topical: dose not mandatory
'                           Mid$(strDefaults, 3, 1) = "0"                                 'remove Dose from defaults
'                           blnStatus(3) = True                                           'set status to completed
'                        End If
'
'      '09May05 Always will be blank since this field is no longer read from the DB
'      ''               ElseIf Trim$(d.route) <> "" Then                                       'check route(s)
'      ''                  strPrompts(6, 2) = Trim$(d.route)
'      ''                  strPrompts(6, 3) = strPrompts(6, 2)
'      ''                  If InStr(strPrompts(6, 2), ",") = 0 Then                            'no comma so just one route
'      ''                     '05Sep02 SF now checks for AllSides entry
'      ''                     strTemp = TxtD(ASCFileName("Route.ini", True, ""), "AllSides", "", strPrompts(6, 2), blnFound)
'      ''                     If Not blnFound Then
'      ''                        Mid$(strDefaults, 6, 1) = "0"                           'remove from defaults list
'      ''                        blnStatus(6) = True                                     'set status to completed
'      ''                     End If
'      ''                     '05Sep02 SF -----
'      ''                  End If
'      ''                  If UCase$(strPrompts(6, 2)) = "TOP." Then                           'Topical: dose not mandatory
'      ''                     Mid$(strDefaults, 3, 1) = "0"                                 'remove Dose from defaults
'      ''                     blnStatus(3) = True                                           'set status to completed
'      ''                  End If
'                     End If
'
'                     '20Feb04 CKJ Use dose, dosing units and directioncode where available
'                     'strDirCodes = OCXheap("lDirCode", Trim$(d.dircode))
'                     strDose = OCXheap("ldose", "")
'                     If Val(strDose) Then
'                        Select Case LCase$(OCXheap("idosingunits", ""))
'                           Case ""                                  'blank
'                              'no action
'                           Case Trim$(LCase$(d.PrintformV))                'same as issue units eg tab or btl
'                              strDirCodes = strDose & "/" & OCXheap("lDircode", "")
'                              '!!** May need admin units check here as well
'                           Case Trim$(LCase$(d.DosingUnits))               'same as dosing units eg mg or g
'                              'strDirCodes = Format$(CDbl(strDose) / CDbl(d.convfact)) & "/" & OCXheap("lDircode", "")
'                              'strDirCodes = Format$(CDbl(strDose) / d.dosesperissueunit) & "/" & OCXheap("lDircode", "")
'                              If CanInferAdministrationUnits() And d.dosesperissueunit <> 1 Then            '07Nov01 CKJ added check <>1
'                                 '!!** May need to reduce decimal places
'                                 strDirCodes = Format$(CDbl(strDose) / d.dosesperissueunit) & "/" & OCXheap("lDircode", "")
'                              Else
'                                 strDirCodes = strDose & "/" & OCXheap("lDircode", "")
'                              End If
'                           End Select
'
'                        '20Feb04 CKJ add duration if specified  e.g. lStartDate=2004-02-20T00:00:00  lStopDate=2004-02-21T00:00:00 => /1d
'                        parsedate OCXheap("lStartDate", ""), FromDate, "dd-mmm-yyyy", valid
'                        If valid Then parsedate OCXheap("lStopDate", ""), ToDate, "dd-mmm-yyyy", valid
'                        If valid Then
'                           lngDuration = DateDiff("d", FromDate, ToDate)
'                           Select Case lngDuration
'                              Case 1 To 366                'arbitrary upper limit for sanity
'                                 strDirCodes = strDirCodes & "/" & Format$(lngDuration) & "d"
'                              End Select
'                        End If
'
'                     Else
'                        strDirCodes = OCXheap("lDirCode", Trim$(d.dircode))
'                     End If
'
'                     'can any more be set to completed now?
'
'                     If Trim$(strDirCodes) <> "" Then                                            'check attached direction code
'                        ReDim strDirections(1 To 10) As String
'                        'deflines Trim$(d.dircode), strDirections(), "/", 1, intNumDirections '14Feb03 CKJ use OCX data if present
'                        deflines strDirCodes, strDirections(), "/", 1, intNumDirections
'                        'strDirections(1)      dose
'                        'strDirections(2)      frequency
'                        'strDirections(3)      could be anything, duration, after meals etc
'                        PrescribingWizardParseDirections intNumDirections, strDirections(), strPrompts(), blnStatus(), strDefaults, strExtraPrompt
'                     End If
'                  End If
'               End If
'
'               '3 Choose Dose
'               If Not k.escd And Mid$(strDefaults, 3, 1) = "1" Then
'                  If strPrompts(2, 2) <> "" Then                                                   'based on 'Enterdose'
'                     sngKeypadValue = 0
'                     KeyPad.lblUnits.Caption = LCase$(d.DosingUnits)
'                     strTemp = "  " & Trim$(d.Description)
'                     replace strTemp, "!", crlf & "  ", 0
'                     KeyPad.Picture1.Tag = crlf & strTemp
'                     KeyPad.LCD.Tag = "1."    '18Mar02 TH Added (#59667) '05apr02 CKJ Changed tag from "dose" to "1."
'                     KeyPad.Show 1
'
'                     Select Case KeyPad.Tag
'                        Case ""
'                           k.escd = True
'                        Case "-1"
'                           sngKeypadValue = Val(KeyPad.LCD.text)
'                           If sngKeypadValue > 0 Then
'                              'below is the original from which it was derived
'                              'If UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR" Then
'                              'temp$ = d.description
'                              'If InStr(temp$, "SUSPENSION") > 0 Or InStr(temp$, "LIQUID") > 0 Or (InStr(temp$, "SOLUTION") > 0 And (InStr(UCase$(d.route), "ORAL") > 0 Or InStr(UCase$(d.route), "NG") > 0 Or InStr(UCase$(d.route), "ET") > 0)) Or InStr(temp$, "MIXTURE") > 0 Or InStr(temp$, "LINCTUS") > 0 Or InStr(temp$, "SYRUP") Or InStr(temp$, "ELIXIR") > 0 Then    '10Nov98 TH Deal with non-oral solutions
'
'                              If CanInferAdministrationUnits() And d.dosesperissueunit <> 1 Then            '07Nov01 CKJ added check <>1
'                                 strTemp = Trim$(Str$(dp!(sngKeypadValue / d.dosesperissueunit)))
'                                 strPrompts(3, 2) = Format$(strTemp)
'                                 strPrompts(3, 3) = Format$(strTemp) & " " & d.PrintformV & " (" & Format$(sngKeypadValue) & " " & Trim$(LCase$(d.DosingUnits)) & ")"
'                              Else
'                                 strPrompts(3, 2) = Trim$(KeyPad.LCD.text)
'                                 strPrompts(3, 3) = Trim$(KeyPad.LCD.text) & " " & LCase$(d.DosingUnits)
'                              End If
'                           Else                                                             '07Nov01 CKJ Added block
'                              strPrompts(3, 2) = ""
'                              strPrompts(3, 3) = "Not specified (Note: PRN may need to be selected)"
'                           End If
'                           Mid$(strDefaults, 3, 1) = "0"                                       'remove from defaults list
'                           blnStatus(3) = True                                                 'set status to completed
'                        End Select
'                     Unload KeyPad
'                  End If
'               End If
'
'               '4 Choose Frequency
'               If Not k.escd And Mid$(strDefaults, 4, 1) = "1" Then
'                  strPrompt = ""
'                  If Len(OCXheap("UserID", "")) Then           '14feb04 CKJ OCX data has been provided, so add to top label
'                     strPrompt = "Select one or more directions" & cr
'                     strPrompt = strPrompt & "Product:  " & OCXheap("iDescription", "-") & cr
'                     strPrompt = strPrompt & "Directions:  " & OCXheap("lDirCode", "-") & "      Route:  " & OCXheap("lRoute", "-") & cr
'                     strPrompt = strPrompt & "Text:  " & OCXheap("lText", "-")
'                  End If
'                  ChooseMultipleDirections 4, strPrompt, "1000", intNumDirections, strDirections()
'                  If Not k.escd Then
'                     PrescribingWizardParseDirections intNumDirections, strDirections(), strPrompts(), blnStatus(), strDefaults, strExtraPrompt
'                  End If
'               End If
'
'               '5 Choose Duration
'               If Not k.escd And Mid$(strDefaults, 5, 1) = "1" Then                                  'derived from 'EnterLength'
'                  KeyPad.Caption = "Duration of Prescription"
'                  KeyPad.lblUnits.Caption = ""
'                  KeyPad.cmdBtn(13).Visible = False
'      ''            KeyPad.cmdBtn(19).Visible = False
'      ''            KeyPad.cmdBtn(20).Visible = False
'                  KeyPad.cmdBtn(21).Visible = False
'                  strPrompt = ""
'                  If Len(OCXheap("UserID", "")) Then           '14feb04 CKJ OCX data has been provided
'                     strPrompt = crlf & " From " & OCXheap("parsedStartDate", "-") & " To " & OCXheap("parsedStopDate", "-")
'                  End If
'                  KeyPad.Picture1.Tag = crlf & "  Enter the duration of the course" & crlf & "  in days, or select cancel to exit" & strPrompt
'
'                  KeyPad.lblUnits.Caption = "days"
'
'                  KeyPad.Show 1
'
'                  Select Case KeyPad.Tag                                                          '07Nov01 CKJ
'                     Case ""                                                                      '   "        Cancel selected
'                        k.escd = True
'                     Case "-1"                                                                    '   "        OK selected
'                        If Val(KeyPad.LCD) = 0 Then                                               '   "        but no number entered
'                           strPrompts(5, 2) = ""                                               '   "        blank the code
'                           strPrompts(5, 3) = "Not specified"                                  '   "        show prompt
'                        Else
'                           strPrompts(5, 2) = Trim$(KeyPad.LCD.text) & "d"
'                           strPrompts(5, 3) = Trim$(KeyPad.LCD.text) & " days"
'                        End If
'                     End Select
'                  Unload KeyPad
'
'                  Mid$(strDefaults, 5, 1) = "0"                                                   'remove from defaults list
'                  blnStatus(5) = True                                                             'set status to completed
'               End If
'
'               '6 Choose Route
'               If Not k.escd And Mid$(strDefaults, 6, 1) = "1" Then
'                  '05Sep02 SF AllSides entry associated with the product's route
'                  If InStr(strPrompts(6, 2), ",") = 0 Then
'                     strTemp = TxtD(ASCFileName("Route.ini", True, ""), "AllSides", "", strPrompts(6, 2), blnFound)
'                     If blnFound Then
'                        strPrompts(6, 2) = strTemp
'                     End If
'                  End If
'                  '05Sep02 SF -----
'
'                  ReDim strRoutes(1 To 100) As String
'                  Unload LstBoxFrm
'                  LstBoxFrm.Caption = "Route"
'
'                  strPrompt = ""
'                  If Len(OCXheap("UserID", "")) Then           '14feb04 CKJ OCX data has been provided, so add to top label
'                     strPrompt = crlf & "Product:  " & OCXheap("iDescription", "-") & crlf
'                     strPrompt = strPrompt & "Directions:  " & OCXheap("lDirCode", "-") & "      Route:  " & OCXheap("lRoute", "-") & crlf
'                     strPrompt = strPrompt & "Text:  " & OCXheap("lText", "-") & crlf
'                  End If
'                  LstBoxFrm.lblTitle = crlf & "Select the Route of Administration" & crlf & strPrompt
'
'                  LstBoxFrm.lblHead = "Code      " & TB & "Description"
'                  If InStr(strPrompts(6, 2), ",") Then
'                     deflines strPrompts(6, 2), strRoutes(), ",", 1, intNumRoutes
'                  Else                                                                         'derived from checkroute
'                     intNumRoutes = Val(TxtD(dispdata$ & "\route.ini", "allroutes", "", "Total", True))
'                     For intloop = 1 To intNumRoutes
'                        strRoutes(intloop) = TxtD(dispdata$ & "\route.ini", "allroutes", "", Format$(intloop), True)
'                     Next
'                  End If
'
'                  For intloop = 1 To intNumRoutes
'                     GetRouteExpansion strRoutes(intloop), strExpansion, ""
'                     If strExpansion = "" Then strExpansion = "** Code '" & strRoutes(intloop) & "' not found"
'                     LstBoxFrm.LstBox.AddItem strRoutes(intloop) & TB & strExpansion
'                  Next
'
'                  LstBoxShow
'                  If Trim$(LstBoxFrm.Tag) <> "" Then
'                     strPrompts(6, 2) = strRoutes(LstBoxFrm.LstBox.ListIndex + 1)
'                     GetRouteExpansion strPrompts(6, 2), strPrompts(6, 3), ""
'                     Mid$(strDefaults, 6, 1) = "0"
'                     blnStatus(6) = True                                                       'set status to completed
'                  End If
'
'                  Unload LstBoxFrm
'               End If
'
'               '7 Finish
'               If Not k.escd And Mid$(strDefaults, 7, 1) = "1" Then                                  'post all the bits then exit
'                  If strPrompts(1, 2) <> Left$(CmbIssueType.text, 1) Then
'                     For intloop = 0 To CmbIssueType.ListCount - 1
'                        If Left$(CmbIssueType.List(intloop), 1) = strPrompts(1, 2) Then        '07oct03 CKJ
'                           CmbIssueType.ListIndex = intloop
'                           Exit For
'                        End If
'                     Next
'                  End If
'
'                  If strPrompts(2, 2) <> "" Then
'                     TxtDrugCode.text = strPrompts(2, 2)
'      ''               TxtDrugCode_KeyDown 13, 0
'                     If Trim$(d.SisCode) = "" Then    '15Apr02 CKJ detect if the drug was accepted
'                        TxtDrugCode.text = ""         '   "        user aborted entry so clear drug textbox
'                     Else
'      ''                  CmbDropDrugCode_Click 0
'                        TxtQtyPrinted = 0
'                        NewRx L, False, True
'                        LabelAmended = False
'                     End If
'                  End If
'
'                  If Trim$(d.SisCode) <> "" Then         '15Apr02 CKJ drug entry was not aborted
'                     For intloop = 3 To 5
'                        If strPrompts(intloop, 2) <> "" Then
'                           WDir.Code = strPrompts(intloop, 2)
'                           expanddir WDir.Code
'                        End If
'                     Next
'
'                     If strPrompts(6, 2) <> "" Then
'                        For intloop = 0 To CmbRoute.ListCount - 1
'                           If UCase$(Trim$(CmbRoute.List(intloop))) = UCase$(Trim$(strPrompts(6, 2))) Then
'                              CmbRoute.ListIndex = intloop
'                              Exit For
'                           End If
'                        Next
'                     End If
'
'                     If TxtDircode.text <> "" And passlvl <> 3 Then                               'non-prescribers only
'                        createlabel 1
'                        memorytolabel
'                     End If
'
'                     LabelAmended = True
'                     blnDone = True
'                  End If
'               End If
'
'               k.escd = False
'            End If
'
'         Loop Until blnDone
'
'End Sub

'Private Sub PrescribingWizardParseDirections(intNumDirections As Integer, strDirections() As String, strPrompts() As String, blnStatus() As Integer, strDefaults As String, strExtraPrompt As String)
'10Nov01 CKJ written
'            routine is used more than once so moved to separate location to avoid duplication
'            Assumes use of global PID. Wdir. d. and k.  where d. must be set prior to calling
'            All other variables passed as params
'            For reference, the array elements are as follows
'               blnStatus(1)  strPrompts(1, x)  Prescription Type
'               blnStatus(2)  strPrompts(2, x)  Product
'               blnStatus(3)  strPrompts(3, x)  Dose
'               blnStatus(4)  strPrompts(4, x)  Frequency
'               blnStatus(5)  strPrompts(5, x)  Course Duration
'               blnStatus(6)  strPrompts(6, x)  Route
'               blnStatus(7)  strPrompts(7, x)  Finish
'            where 'x' has the values   1) Display prompt  2) Code to use  3) Expansion of code
'23Feb04 CKJ Removed d.printformv as it may be in dosing units
'            Added check to allow dec pt
'20oct08 CKJ commented out unused code to save space
'
'      Dim strFrequency As String
'      Dim intloop As Integer
'      Dim strTemp As String
'      Dim strNumTest As String
'      Dim intPosn As Integer
'      Dim lngFound As Long
'
'         strFrequency = ""
'         For intloop = 1 To intNumDirections
'            strTemp = Trim$(strDirections(intloop))
'
'            strNumTest = strTemp                                             '23Feb04 CKJ added dec pt check
'            intPosn = InStr(strNumTest, ".")                                 'is there at least one dec pt
'            If intPosn Then Mid$(strNumTest, intPosn, 1) = "0"               'replace first dec pt with a digit
'            'If IsDigits(strTemp) Then                                       'dose
'            If IsDigits(strNumTest) Then                                     'dose      Check that all chars are now digits 0 to 9
'                  strPrompts(3, 2) = strTemp
'                  'always present in drug file as issue units (not dosing units) BUT may be used here as dosing units eg injections by mg not by vial
'                  'strPrompts(3, 3) = strTemp & " " & d.printformv           '23Feb04 CKJ removed units as not always appropriate
'                  If CanInferAdministrationUnits() And d.dosesperissueunit <> 1 Then     'use this instead
'                        strPrompts(3, 3) = strTemp & " " & d.PrintformV                  '      "
'                     Else                                                                '      "
'                        strPrompts(3, 3) = strTemp & " " & d.DosingUnits                 '      "
'                     End If                                                              '      "
'
'                  Mid$(strDefaults, 3, 1) = "0"                              'remove from defaults list
'                  blnStatus(3) = True                                        'set status to completed
'
'               ElseIf IsDigits(Left$(strTemp, Len(strTemp) - 1)) And LCase$(Right$(strTemp, 1)) = "d" And Len(strTemp) > 1 Then 'duration
'                  strPrompts(5, 2) = strTemp                                 '21d'
'                  replace strTemp, "d", " ", 0                               '23feb04 CKJ add space afer digits
'                  strPrompts(5, 3) = strTemp & "days"                        '21 days'
'                  Mid$(strDefaults, 5, 1) = "0"                              'remove from defaults list
'                  blnStatus(5) = True                                        'set status to completed
'
'               ElseIf Left$(strTemp, 1) = ">" Then                           'supplementary direction code (attached to drug)
'                  WDir.Code = Mid$(strTemp, 2)
'                  getdir (WDir.Code), pid.ward, lngFound, WDir
'                  If lngFound Then
'                        strExtraPrompt = Trim$(WDir.directs)
'                     Else
'                        strExtraPrompt = "(description not found)"
'                     End If
'                  strExtraPrompt = crlf & "Supplementary direction code '" & Trim$(WDir.Code) & "' will be added:" & crlf & strExtraPrompt
'
'               Else                                                          'put in 'frequency' slot
'                  WDir.Code = strTemp
'                  getdir (WDir.Code), pid.ward, lngFound, WDir
'                  If lngFound Then                                           'cope with compound direction containing a dose
'                        If WDir.dose(1) > 0 Then
'                              strPrompts(3, 2) = ""
'                              strPrompts(3, 3) = "Set within direction code: " & WDir.Code
'                              Mid$(strDefaults, 3, 1) = "0"                  'remove from defaults list
'                              blnStatus(3) = True                            'set status to completed
'                           End If
'                     End If
'                  strFrequency = strFrequency & "/" & strTemp
'               End If
'            Next
'
'         If Len(strFrequency) Then
'               strPrompts(4, 2) = Mid$(strFrequency, 2)                      'remove leading '/'
'               strPrompts(4, 3) = strPrompts(4, 2)
'               If InStr(strPrompts(4, 2), "/") = 0 Then
'                     WDir.Code = strPrompts(4, 2)
'                     getdir (WDir.Code), pid.ward, lngFound, WDir
'                     If lngFound Then
'                           strPrompts(4, 3) = Trim$(WDir.directs)
'                           replace strPrompts(4, 3), cr, " ", 0
'                        End If
'                  End If
'               Mid$(strDefaults, 4, 1) = "0"
'               blnStatus(4) = True                                           'set status to completed
'            End If
'
'End Sub

Private Sub printOCXdetails(ByVal strText As String, ByVal blnItalic As Integer)
'14Feb03 CKJ written
'01Aug05 CKJ Changed from plain/bold to italic/plain
   
   picOCXdetails.FontBold = False         ' (blnBold <> 0)
   picOCXdetails.FontItalic = (blnItalic <> 0)
   picOCXdetails.Print strText;

End Sub

Private Sub printOCXdetailsWrap(ByVal strText As String, ByVal blnAllowItalics As Boolean, ByVal blnForPopup As Boolean)
'11Feb11 TH Written for Chemocare (F0036868)

Dim intMax As Integer
Dim intloop As Integer
Dim strOutput() As String
Dim intLines As Integer
Dim strMsg As String
Dim strEllipsis As String
Dim strHeader As String
Dim strFooter As String

   
   
   intLines = 0
   intMax = Int(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "200", "MaxCharsperRow", 0))
   strEllipsis = TxtD(dispdata$ & "\patmed.ini", "OCXInterface", " ...", "Ellipsis", 0)
   picOCXdetails.FontItalic = False

   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "Y", "ParseCtrlCharacters", 0)) Then
      plingparse strText, Chr$(30)
      plingparse strText, Chr$(10)
      plingparse strText, Chr$(13)
   End If
   
   strHeader = Trim$(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "This prescription has been imported from Chemocare and must be verified before dispensing - Click to view", "PanelHeaderText", 0))
   If blnForPopup Then strHeader = Trim$(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "This prescription has been imported from Chemocare and must be verified before dispensing[cr][cr] - Chemocare Prescription[cr]", "MsgBoxHeaderText", 0))
   If (strHeader <> "") And ((Int(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "2", "MaxRows", 0)) > 1) Or (blnForPopup)) Then
      ParseCtrlChars dispdata$ & "\printer.ini", "Screen", strHeader, 0
      intLines = 1
      ReDim Preserve strOutput(intLines)
      strOutput(intLines) = strHeader
   End If
   
   Do While Len(strText) > 0
   
      If (picOCXdetails.TextWidth(strText) > picOCXdetails.ScaleWidth) Or (blnForPopup And Len(strText) > intMax) Then
         'seperate into lines as required
         If InStr(1, strText, " ", vbBinaryCompare) > 0 Then
            For intloop = intMax To 1 Step -1
               If InStr(1, Mid$(strText, intloop, 1), " ", vbBinaryCompare) Then
                  'Check it is actually Ok
                  If (picOCXdetails.TextWidth(Left$(strText, intloop) & Iff((intLines + 1) >= (Int(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "2", "MaxRows", 0))), strEllipsis, "")) < picOCXdetails.ScaleWidth) Or blnForPopup Then '15Feb11 TH Extra check
                     intLines = intLines + 1
                     ReDim Preserve strOutput(intLines)
                     strOutput(intLines) = Left$(strText, intloop)
                     strText = Right$(strText, Len(strText) - (intloop))
                     Exit For
                  End If
               End If
            Next
         Else
            'Ok we have no spaces. We will cut at an appropriate place
            If blnForPopup And (Len(strText) <= intMax) Then
               intLines = intLines + 1
               ReDim Preserve strOutput(intLines)
               strOutput(intLines) = strText
               strText = ""
            Else
               For intloop = intMax To 1 Step -1
                  If (picOCXdetails.TextWidth(Left$(strText, intloop) & Iff((intLines + 1) >= (Int(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "2", "MaxRows", 0))), strEllipsis, "")) < picOCXdetails.ScaleWidth) Or blnForPopup Then '16Feb11 include ...
                     intLines = intLines + 1
                     ReDim Preserve strOutput(intLines)
                     strOutput(intLines) = Left$(strText, intloop)
                     strText = Right$(strText, Len(strText) - (intloop))
                     Exit For
                  End If
               Next
            End If
         End If
         'OK do we need to wrap
         If intLines >= Int(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "2", "MaxRows", 0)) And (Not blnForPopup) Then
            strOutput(intLines) = strOutput(intLines) & strEllipsis
            SetReviewInterfaceText True
            strText = "" 'Come out of the loop and leave the remainder - Its too big !!
         End If
      Else
         intLines = intLines + 1
         ReDim Preserve strOutput(intLines)
         strOutput(intLines) = strText
         strText = ""
      End If
   Loop
   
   If blnForPopup Then
      strMsg = ""
      For intloop = 1 To intLines
         strMsg = strMsg & crlf & strOutput(intloop)
      Next
      strFooter = Trim$(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "[cr][cr] - Prescription[cr][cr][Description]", "MsgboxFooterText", 0))
      If Trim$(strFooter) <> "" Then
         ParseCtrlChars dispdata$ & "\printer.ini", "Screen", strFooter, 0
         ParseItems g_OCXheapID, strFooter, 0
         ParseItems gPRNheapID, strFooter, 0
         strMsg = strMsg & strFooter
      End If
      popmessagecr TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "Imported prescription", "PopMessageTitle", 0), strMsg
      SetFocusTo txtUC("TxtPrompt")    '04Sep11 TH (TFS 12258)
   Else
      'Now assign the text
      picOCXdetails.Tag = Format$(intLines)
      SetupDispensForm
      If GetReviewInterfaceText() And blnAllowItalics And TrueFalse(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "Y", "ItalicizeWrap", 0)) Then
         picOCXdetails.FontItalic = True
      Else
         picOCXdetails.FontItalic = False
      End If
      For intloop = 1 To intLines
         If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "Y", "FontBoldHeader", 0)) And intloop = 1 Then picOCXdetails.FontBold = True
         picOCXdetails.Print strOutput(intloop)
         If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "Y", "FontBoldHeader", 0)) And intloop = 1 Then picOCXdetails.FontBold = TrueFalse(TxtD(dispdata$ & "\patmed.ini", "OCXInterface", "N", "FontBold", 0))
      Next
      
   End If
   

End Sub







Private Sub SetupDispensForm()
'14Feb03 CKJ Moved all the resize code to the resize event

Dim intPanelTop As Integer
Dim intpicOCXlines As Integer
   
   On Error GoTo SetupDispensFormErr
   Picture1.Move 0, 0, Screen.Width, UserControl.ScaleHeight   'All main PMR controls live on this one
   
   intpicOCXlines = Val(picOCXdetails.Tag)                                             'how many lines to display?
   picOCXdetails.Visible = (intpicOCXlines > 0)                                        'hide if none
   picOCXdetails.Height = TxtHeight(picOCXdetails) * intpicOCXlines                    'basic height
   If picOCXdetails.Height Then picOCXdetails.Height = picOCXdetails.Height + 50       'with margin if not empty
   picOCXdetails.Top = fraLineColour.Top + fraLineColour.Height                        'place under main controls

   intPanelTop = 0
   fraLineColour.Move 45, intPanelTop - 50
   fraRx.Move 2520, intPanelTop + 70
   fraLabel.Move 2520, intPanelTop
   fraPrepared.Move 7110, intPanelTop - 50
   LblWarning.Top = fraLabel.Top + fraLabel.Height
   lblExpiry.Top = LblWarning.Top + LblWarning.Height
''   Picture2.Width = fraPrepared.Left + fraPrepared.Width + 45                          'holds the button bar

SetupDispensFormExit:
   UserControl.Refresh
Exit Sub

SetupDispensFormErr:
   On Error GoTo 0
Resume SetupDispensFormExit

End Sub

''Private Sub RxProtocol()
'''09Jan99 ASC replaces gosub
'''20Apr01 CKJ Allow printing of protocols at time of entry
'''            Uses Patmed.ini [] PrintProtocolLabels = "Y" T/F/Y/N/0/1/-1
'''24sep01 CKJ Warnings now gathered together at start of protocol, and if OK the chosen drugs are
'''            then used with no further warnings shown.                              (#55041)
'''27Nov01 CKJ Abort Addition message now editable                                    (#57019)
'''            patmed.ini [Messages] MsgAbortAddProtocol="multi-line[cr]prompt"
'''                                  MsgAbortAddProtocolDefault="N"     'optional, default is "Y"
'''27Nov01 TH  Added Protocol logging for Royal London enhancement (#52700)
'''03Dec01 TH  Quick change to a bodge up where I had formated the part nsvcodes incorrectly in the log above
'''11Jan02 CKJ Allow protocols on level 2 password, if configuration permits.
'''            Use entry in siteinfo.ini [] protocolinfo="<hex block>"
'''            where the hex data is generated by encodehex from a string which MUST conform to
'''            the definition      [[nnn-nnn,]...]
'''            ie repeating groups of eight characters where nnn must be digits in range 000 to 999
'''            with dash and comma as shown. An empty string is permitted (but pointless), and a
'''            theoretical maximum of 29 groups can be used. It has been tested with six groups.
'''            Each group is a range of site numbers for which level 2 users will be allowed to
'''            use protocols, and this can be a single site or range of sites. For a single site
'''            specify the same sitenumber in both low and high values.
'''            For 'spare' entries, use 000 as the sitenumber.  For example;
'''            001-001,041-043,400-499,000-000,000-000,000-000,
'''            allows sites 1, 41, 42, 43 and all of the four hundreds to use protocols on level 2
'''            If the string cannot be parsed or has an error then the protocol upgrade is denied.
'''
'''            Tested lines for siteinfo.ini with 400-499 and five spare sections
'''              ;11jan02 CKJ This block affects HK sites only, and therefore can be included safely in any siteinfo file.
'''              ProtocolInfo="B29E9010B2B09605923E1C339E93B4A43A929030BA9216A7B0B09898B892968490B81A10321816279A90B8103A1016A692983218B210148712B0B038B23836843A381AB21A329E0D9A38BABA3AB2968E123ABA1012B29625923010303AB2B6A6"
'''
'''07Oct02 TH  Added refresh of the truegrid line if user aborts (not elegant but should be OK as protocols are tied in to dispens frm)
'''16apr04 ckj Cleared k.escd before dir code handler. k.escd is set true in enterdrug, only for d.dircode where the txt box is empty.
'''            Reason for setting in enterdrug is not explicit, but clearing it here is safe. (#73608)
''
''Dim X%, passcop%, Y%, ans$
''Dim SSProtocols As Snapshot
''Dim intAction As Integer
''Dim intSeverity As Integer
''Dim strWarningMsg As String
''Dim abort$
''Dim intItems As Integer
''Dim PatientName$
''Dim dob$
''Dim intloop As Integer
''Dim strMsg As String
''Dim strProtocolName As String, blnProtocolLog As Integer
''Dim blnPartProtocol As Integer, strPartMsg As String
''Dim blnDoProtocol As Integer
''Dim strPWupgrade As String
''
''   blnProtocolLog = TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "Y", "ProtocolLog", 0))
''   If blnProtocolLog Then WriteLog dispdata$ & "\protocol.log", SiteNumber, UserID$, "Patient Record Number = " & pid.recno & " Patient Caseno : " & Trim$(pid.caseno) & " Protocol Button Pressed"  '27Nov01 TH Added
''   CmbRoute.ListIndex = -1 '29Jun97 ASC
''
''   blnDoProtocol = (passlvl > 2)                            '11Jan02 CKJ added block
''   If passlvl = 2 Then                                      '            allow 'upgrade' of lvl 2
''         strPWupgrade = siteinfo$("ProtocolInfo", "")       '            if site is included here
''         decodehex strPWupgrade                             '400-499,801-801,849-849,000-000,000-000,'
''         On Error GoTo RxProtocol_UpgradeErr                'cope with non-numeric trash etc
''         Do While Len(strPWupgrade) >= 7
''            Select Case Val(Left$(strPWupgrade, 3))         'eg '400'
''               Case 0                                       'ignore entries starting 000-
''                  'no action
''               Case Is <= SiteNumber                        'OK, now check upper bound eg '499'
''                  If SiteNumber <= Val(Mid$(strPWupgrade, 5, 3)) Then
''                        blnDoProtocol = True                'successful
''                        Exit Do                             'exit now
''                     End If
''               End Select
''            strPWupgrade = Mid$(strPWupgrade, 9)            'snip off first 8 chars eg '123-456,'
''         Loop
''
''RxProtocol_Upgrade:
''         On Error GoTo 0
''      End If                                                '11Jan02 CKJ end block
''
''   If blnDoProtocol Then
''         If fileexists(dispdata$ & "\protocol.mdb") Then
''               If Left$(CmbIssueType.List(X), 1) = "P" Then '26Jun98 ASC                        '!!** WRONG
''                     CmbIssueType.List(X) = pid.Status                                          ' ""
''                  End If
''               Dim db As Database
''               Dim TblProtocols As Table
''               Dim TblItems As Table
''               Dim SSItems As Snapshot
''
''               On Error GoTo DbopenProtocolError
''               Set db = OpenDatabase(dispdata$ & "\protocol.mdb", False, True) '22Oct97 CKJ Added read only
''               On Error GoTo 0
''
''               On Error GoTo DbopenTableError
''               Set TblProtocols = db.OpenTable("protocols", 4)  ' 09Jan99 ASC was tbl
''               Set TblItems = db.OpenTable("items", 4)         '    "
''               On Error GoTo 0
''
''               '31Oct97 EAC - check for PrimaryKey Index here to allow easier exit if not present
''               'NB will also help with the MoveFirst below as it establish in which order to read any records
''               On Error GoTo RxProtocol_NoIndex
''               TblProtocols.index = "primarykey"
''               On Error GoTo 0
''
''               LstBoxFrm.Caption = "Products"
''
''               'If C type then set to I type before protocols to inhibit question r.e. change
''               If Left$(CmbIssueType.Text, 1) = "C" Then  '29Jun97 ASC
''                  For X = 0 To CmbIssueType.ListCount - 1
''                        If Left$(CmbIssueType.List(X), 1) = "I" Then
''                              CmbIssueType.ListIndex = X      '07oct03 CKJ
''                           End If
''                     Next
''                  End If
''
''               '31Oct97 EAC - check that there are some records in the Table
''               If TblProtocols.RecordCount = 0 Then
''                     popmessagecr "Protocol Issue", "There are no Protocols defined in the Protocol Database."
''                     GoTo RxProtocol_Return
''                  End If
''
''               Set SSProtocols = db.CreateSnapshot("sortedprotocols")   '09Jan98 ASC
''               SSProtocols.MoveFirst                                    '    "
''
''               Do While Not SSProtocols.EOF    '30Oct97 CKJ Moved from below
''                  LstBoxFrm.LstBox.AddItem "  " & GetField(SSProtocols!name)                       '22Oct97 CKJ was tbl.Fields("name")
''                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(SSProtocols!id)  '22Oct97 CKJ was tbl.Fields("id")
''                  SSProtocols.MoveNext
''               Loop ' Until tbl.EOF     30Oct97 CKJ Moved to the 'Do'
''
''               LstBoxShow
''
''               If Trim$(LstBoxFrm.Tag) <> "" Then     '26Aug97 CKJ Added - checks if escd from listbox
''                     TblProtocols.Seek "=", LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
''
''                     Unload LstBoxFrm
''
''                     If TblProtocols.NoMatch = False Then
''                           intAction = 4                                             '20Apr01 CKJ Added. 4=Save Prescription
''                           If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "PrintProtocolLabels", 0)) Then '20Apr01 CKJ
''                                 ans$ = "Y"
''                                 k.escd = False
''                                 askwin "?Protocol Entry", "OK to print labels during protocol entry?", ans$, k
''                                 If ans$ = "Y" Then intAction = 5                                       '5=Print Prescription
''                                 k.escd = False
''                              End If
''                           strProtocolName = GetField(TblProtocols!name)
''                           If blnProtocolLog Then WriteLog dispdata$ & "\protocol.log", SiteNumber, UserID$, "Patient Record Number = " & pid.recno & "Patient Caseno : " & Trim$(pid.caseno) & " Protocol Selected = " & Trim$(strProtocolName) '27Nov01 TH Added
''                           '09Jan99 ASC Now uses a relational item file to allow limitless prescriptions in a protocol
''                           Set SSItems = db.CreateSnapshot("Select * from items where id = " & GetField(TblProtocols!id) & " order by sortno")
''
''                           '24sep01 CKJ Start of new block
''                           SSItems.MoveFirst
''                           StoreSeverityAndMessage True, 0, ""                                  'empty the stored data
''                           k.escd = False
''                           intItems = 0
''                           ReDim strItems(0 To 2, intItems) As String
''
''                           Do While Not SSItems.EOF
''                              If trimz$(GetField(TblItems!Code)) <> "" Then                     'choose drug
''                                    TxtDrugCode.Text = GetField(SSItems!Code)      '07oct03 CKJ
''
''                                    EnterDrug 1            'Phase 1, choose drugs & collect severity data
''                                    DoEvents
''
''                                    If k.escd Then
''                                          Confirm "?Escape", "abort protocol entry", ans$, k          '15apr04 CKJ removed extra "to"
''                                          If ans$ = "Y" Then
''                                                k.escd = True
''                                                Exit Do
''                                             End If
''                                       End If
''
''                                    If Trim$(d.SisCode) <> "" Then
''                                          intItems = intItems + 1
''                                          ReDim Preserve strItems(0 To 2, intItems) As String
''                                          strItems(0, intItems) = d.SisCode
''                                          strItems(1, intItems) = GetField(SSItems!dose)
''                                          strItems(2, intItems) = UCase$(trimz$(GetField(SSItems!route)))
''                                       End If
''                                 Else
''                                    Exit Do
''                                End If
''                              DoSaferEvents 1              '29Jun97 ASC '22Oct97 CKJ
''                              SSItems.MoveNext
''                           Loop
''
''                           If Not k.escd Then
''                                 StoreSeverityAndMessage False, intSeverity, strWarningMsg              'retrieve message
''                                 If strWarningMsg <> "" Then
''                                       buildname pid, False, PatientName$
''                                       dob$ = pid.dob
''                                       If Trim$(pid.dob) = "" Then dob$ = "Unknown"
''                                       strWarningMsg = "Case Number : " & pid.caseno & crlf & "Name : " & PatientName$ & crlf & "DOB : " & dob$ & crlf & crlf & strWarningMsg
''                                       Editor.Txt1 = strWarningMsg & crlf & crlf & "Click Interaction button to show all interactions"
''                                       Editor.LblCode = ""
''                                       Editor.cmdExit.default = True
''                                       Editor.Tag = ""
''                                       CentreForm Editor
''                                       Editor.Show 1
''                                       Unload Editor
''                                       k.escd = False
''                                    End If
''
''                                 If intSeverity = 2 Then
''                                       'Confirm "Logging your action", "abort addition of Protocol", abort$, k                     '27Nov01 CKJ Message now editable
''                                       strMsg = "OK to abort addition of Protocol?"
''                                       strMsg = TxtD(dispdata$ & "\patmed.ini", "Messages", strMsg, "MsgAbortAddProtocol", 0)
''                                       abort$ = TxtD(dispdata$ & "\patmed.ini", "Messages", "Y", "MsgAbortAddProtocolDefault", 0)
''                                       ParseCtrlChars dispdata$ & "\printer.ini", "Screen", strMsg, 0
''                                       askwin "!Logging your action", strMsg, abort$, k
''
''                                       Select Case abort$
''                                          Case "Y": k.escd = True
''                                          Case "N": WriteLog dispdata$ & "\interact.log", SiteNumber, UserID$, strWarningMsg
''                                          End Select
''                                    End If
''                              End If
''
''                           StoreSeverityAndMessage True, 0, ""                                  'empty the stored data
''
''                           If Not k.escd Then
''                                 '24sep01 CKJ end of new block
''                                 For intloop = 1 To intItems
''                                    'New prescription
''                                    For X = 0 To CmbIssueType.ListCount - 1
''                                       If pid.Status = Left$(CmbIssueType.List(X), 1) Then
''                                             CmbIssueType.ListIndex = X
''                                             Exit For
''                                          End If
''                                    Next
''
''                                    passcop = passlvl
''                                    passlvl = 2
''                                    TxtPrompt.Text = "N"
''                                    TxtPrompt_KeyUp 0, 0
''''                                    TGLabelList.RowIndex = 0
''                                    passlvl = passcop
''                                    DoSaferEvents 1
''''                                    TxtDrugCode.SetFocus
''
''                                    'choose drug
''                                    TxtDrugCode.Text = strItems(0, intloop)
''
''                                    EnterDrug 2                    '12sep01 CKJ Phase 2, add new drugs without messages
''
''                                    '31Oct97 EAC unfortunately this has to be a doevents because of a call to set focus on Dispens frm
''                                    '            in the above code.
''                                    DoEvents
''
''                                    'enter dose
''                                    TxtDirCode_keyDown 8, 0
''                                    k.escd = False                  '16apr04 ckj Added. k.escd is set true in enterdrug, only for d.dircode where the txt box is empty.
''                                                                    '            Reason for setting in enterdrug is not explicit, but clearing it here is safe. (#73608)
''
''                                    For Y = 1 To Len(strItems(1, intloop))
''                                       TxtDircode = TxtDircode & Mid$(strItems(1, intloop), Y, 1)
''                                       DoEvents
''                                       If k.escd Then
''                                             Confirm "?Escape", "abort protocol entry", ans$, k
''                                             If ans$ = "Y" Then k.escd = True: Exit For
''                                          End If
''                                    Next
''
''                                    'authorise and save
''                                    CmbRoute.ListIndex = -1
''                                    For X = 0 To CmbRoute.ListCount - 1
''                                       If strItems(2, intloop) = UCase$(Trim$(CmbRoute.List(X))) Then
''                                             CmbRoute.ListIndex = X
''                                             Exit For
''                                          End If
''                                    Next
''
''                                    If Not k.escd Then
''                                          Confirm "?Protocol Issue", "Authorise this prescription", ans$, k
''                                          If ans$ = "Y" And Not k.escd Then
''''                                                CmdPrompt(3).SetFocus
''                                                DoSaferEvents 1
''                                                DispMnuButHandler intAction
''
''                                                DoSaferEvents 1
''                                             Else
''                                                blnPartProtocol = True
''                                                strItems(0, intloop) = ""   'blank this so it wont be logged later
''                                             End If
''                                       Else
''                                          blnPartProtocol = True
''                                          strItems(0, intloop) = ""  'blank this so that it wont be logged later
''                                          Exit For
''                                       End If
''
''                                    DoSaferEvents 1
''
''                                 Next
''
''                                 If blnPartProtocol And blnProtocolLog Then
''                                       strPartMsg = ""
''                                       For intloop = 1 To intItems
''                                          If Trim$(strItems(0, intloop)) <> "" Then
''                                                strPartMsg = strPartMsg & "," & Trim$(strItems(0, intloop))
''                                             End If
''                                       Next
''                                       If Trim$(strPartMsg) <> "" Then
''                                             strPartMsg = Mid$(strPartMsg, 2)
''                                             WriteLog dispdata$ & "\protocol.log", SiteNumber, UserID$, "Patient Record Number = " & pid.recno & " Patient Caseno : " & Trim$(pid.caseno) & " " & strProtocolName & " Has been part selected with ;" & strPartMsg
''                                          Else
''                                             WriteLog dispdata$ & "\protocol.log", SiteNumber, UserID$, "Patient Record Number = " & pid.recno & " Patient Caseno : " & Trim$(pid.caseno) & " " & strProtocolName & " Protocol Selected but no items authorised"
''                                          End If
''                                    End If
''                              Else
''                                 If blnProtocolLog Then WriteLog dispdata$ & "\protocol.log", SiteNumber, UserID$, "Patient Record Number = " & pid.recno & " Patient Caseno : " & Trim$(pid.caseno) & " " & strProtocolName & " Protocol Aborted : " & strWarningMsg
''
''                                 TGLabelList_rowchange '07Oct02 TH Added as refresh if user aborts
''                              End If
''                           k.escd = False
''                        Else
''                            popmessagecr "Protocol Not Found.", "No data was found in the protocol database for the selected Protocol. Please inform your System Manager."
''                        End If  '{tbl.nomatch}
''                  Else
''                     Unload LstBoxFrm
''                  End If
''
''            Else
''               popmessagecr "", "Protocols not installed" & cr & cr & dispdata$ & "\protocol.mdb" & " not found"
''            End If  '{if fileexists}
''      Else
''         popmessagecr "!", "Insufficient password authority"
''''         TxtDrugCode.SetFocus
''      End If '{PassLvl > 2}
''
''RxProtocol_Return:
''   On Error Resume Next
''   SSItems.Close
''   Set SSItems = Nothing
''   SSProtocols.Close
''   Set SSProtocols = Nothing
''   TblItems.Close
''   Set TblItems = Nothing
''   TblProtocols.Close
''   Set TblProtocols = Nothing
''   db.Close
''   Set db = Nothing
''   On Error GoTo 0
''Exit Sub
''
''DbopenProtocolError:
''   popmessagecr "Protocol Database Error", "Error:" & cr & "Failed to open protocol database: " & dispdata$ & "\protocol.mdb." & cr$ & "Unable to continue with Protocol Issue." & cr$ & "Please inform your System manager."
''Resume RxProtocol_Return
''
''DbopenTableError:
''   popmessagecr "Protocol Database Error", "Error:" & cr & "Failed to open the protocol database." & cr$ & "Unable to continue with Protocol Issue." & cr$ & "Please inform your System manager."
''Resume RxProtocol_Return
''
''RxProtocol_NoIndex:
''    popmessagecr "Protocol Database Error", "The Primary Key index is not defined in the protocol database. Unable to continue with Protocol Issue." & cr$ & "Please inform your System manager."
''Resume RxProtocol_Return
''
''RxProtocol_UpgradeErr:                 '11jan02 CKJ added. Any error and the upgrade is skipped
''Resume RxProtocol_Upgrade
''
''End Sub

''09May05 Removed ability to add direction codes here (requested by AS)
''Private Sub SelectDirs(lin%)
'''2Feb95 CKJ added lin
''
''   ChooseDirectionCode WDir.Code
''
''   If WDir.Code <> "" Then
''         TxtLabel(lin).Text = WDir.Code
''         AddDirCodeToLabel lin, 0
''      End If
''
''End Sub

Private Sub SetOCXDetailsSize()

Dim strInifile As String
Dim strINIsection As String
   
   strInifile = dispdata$ & "\PMRpanel.ini"
   strINIsection = "OCXdetails"
   picOCXdetails.Tag = TxtD(strInifile, strINIsection, "0", "lines", False)
   
End Sub

Private Sub SetOCXdetails()
'14Feb03 CKJ written

Dim strTemp As String
Dim intline As Integer
Dim strInifile As String
Dim strINIsection As String
Dim strItemCopy As String
   
   ReDim strData(1 To 3) As String

   strInifile = dispdata$ & "\PMRpanel.ini"
   strINIsection = "OCXdetails"
''   picOCXdetails.Tag = txtd(strINIfile, strINIsection, "0", "lines", False)
   picOCXdetails.Cls

   For intline = 1 To Val(TxtD(strInifile, strINIsection, "0", "Total", False))
      strTemp = TxtD(strInifile, strINIsection, "", Str$(intline), False) & "||"    '="preamble|item|postamble"  where item is [crlf] or OCXheap(<item>,"")
      replace strTemp, "[crlf]", crlf, True                                         'not case sensitive
      deflines strTemp, strData(), "|(*)", 1, 3                                     'split on |
      strItemCopy = strData(2)
      If strData(2) <> crlf Then strData(2) = OCXheap(strData(2), "¬")              'look up item on OCX heap
      If strData(2) = "¬" Then                                                      'not found
         strData(2) = ""
         Heap 11, gPRNheapID, strItemCopy, strData(2), 0                            'look up item on print heap
      End If
      displayOCXdetails strData(1), strData(2), strData(3)
   Next

End Sub

Private Sub setP()
'4Jun95 ASC
'20Apr96 KR Added checks for Automation
'16May96 KR Added extra check so that if the user wants to use P, it does not automatically change back to S
'22Jun96 now set automation$ in form load
'06Mar97 KR  Also check for passlevel of 3 for ward prescribing
'05Feb99 SF  Prescription action now defaults to "N" if a blank current PMR
'26Feb02 TH  Ensure FirstLoaded is set properly for any patients with nothing on the PMR (#59181)

'>>   If automation$ <> "" And (Mid$(acclevels$, 1, 1) = "8" Or Mid$(acclevels$, 1, 1) = "3") Then '06Mar97 KR
'>>         If TxtPrompt.Text <> "P" Then TxtPrompt.Text = "S"    '16May96 KR added
'>>      Else
         TxtPrompt.text = "P"
'>>      End If
'>>   If TGLabelList.Rows = 0 And Trim$(TxtDrugCode.Text) = "" Then  '05Feb99 SF added      '07oct03 CKJ
'>>         TxtPrompt.Text = "N"                                                     '    "
'>>         FirstLoaded = True    '26Feb02 TH Added as this wont get set properly otherwise for any patients with nothing on the PMR (#59181)
'>>      End If                                                                      '    "
   TxtPrompt.SelStart = 0
   TxtPrompt.SelLength = 1
   labpromptchanged = False

End Sub

'20oct08 CKJ commented out unused code to save space
'      Private Sub TGLabelList_rowchange()
'      '07Mar97 KR  Added check for no rows
'      '21Mar97 KR  Added extra parameter to displaytheLabAndForm
'      '18Jun97 KR  Added checking and setting of FirstLoaded.  Used to stop DisplaytheLabAndForm
'      '            firing twice when dispensing form is first loaded.
'      '20Jan98 CFY Added coded to handle switching on and off of
'      '            blister packing text and box when a tablet/capsule type drug is selected
'      '25Jan98 CKJ Corrected blister check, and added ini file override
'      '27Oct98 ASC/CFY removed check for Labelamended when changing rows to stop old label being preserved after a row change
'      '26Nov99 TH Added getdrug to fully fill drug structure on first load. Previously it contained wrong description
'      '04Sep00 JN  Added check to pick up blank drug descriptions. If blank, label is found by using internal rec. no
'      '   "     "  in order to get NSVcode. Getdrug searches on NSVcode for drug desc. If found, this is swapped for the blank desc on TrueGrid
'      '09Oct00 AW  Added code to show licenced/unlicenced routes
'      '09Nov00 JN/EAC  Added .ini file switch to activate blank drug desc replacement
'      '20Nov00 AW commented out code for licenced/unlicenced route mod
'      '19Dec00 CKJ/JN Block removed. Replaced by code in MakePMRline which checks as the array is being assembled.
'      '31Jan03 TH (PBSv4) MERGED
'      '31Jan03 TH (PBSv4) Added mod check PBS Status of line to explicitly set foundDrugItem to 0
'      '           Added section to update the billing (PBS) Issue panel
'      '09Mar04 CKJ Added hiding of IPlink forms
'      '16May04 TH Pass keep modified direction flag into label routines (#67284)
'
'      Dim expiry$
'      Dim F%, strMsngDrugDesc As String, lngTempLabf As Long      '04Sep00 JN Added
'      Dim intLabelChan As Integer                                 '04Sep00 JN Added
'      Dim udtRec As filerecord, udtLabel As WLabel                '04Sep00 JN Added
'      Dim strFile As String, udtDrug As DrugParameters            '09Nov00 JN Added
'
'
'      '**!!**V93 still need most of this
'
'      ''   If FirstLoaded Or OCXlaunch() Then       '18Jun97 KR added '08Jul98 CFY added "OR OCXLaunch()"
'         If FirstLoaded Then        '18Jun97 KR added '08Jul98 CFY added "OR OCXLaunch()"
'               StopEvents = True
'               If isPBS() Then F% = billpatient(30, "")   '31Jan03 TH (PBSv4) Reinstated but to explicitly set founDrugItem to 0 '***** was 25
'               DisplaytheLabAndForm 1, 0, k.escd, expiry$, 0
'               StopEvents = False
'            Else
'               getdrug d, 0, 0, False  '26Nov99 TH Added getdrug to fully fill drug structure.Previously it contained wrong description
'               If isPBS() Then F% = billpatient(30, "")    '31Jan03 TH (PBSv4) Added for same reason above '***** was 24
'               FirstLoaded = True
'            End If
'
'         Select Case Left$(Trim$(UCase$(d.PrintformV)), 3)
'            Case "TAB", "CAP"
'               LabelBlister.Visible = (TxtD(dispdata$ & "\patmed.ini", "BlisterPacking", "", "Times", 0) <> "")
'            Case Else:
'               LabelBlister.Visible = False
'            End Select
'         TextBlister.Visible = LabelBlister.Visible
'
'         If isPBS() And FirstLoaded Then                         '31Jan03 TH (PBSv4) '09Mar03 Added firstloaded
'               F% = billpatient(29, "Rchange")      '   " Used to set FoundDrugItem '***** was 24
'               F% = 0
'               If L.Nodissued = 0 Then
'                     'Saved or cancelled line - need to set default here if nsvcode is in PBS table then set to P as default in itemstatus
'                     F% = billpatient(33, "")
'                  End If
'               setPBSblnKeepBillitems False
'               setQuesdefaults F%
'               PBSUpdateIssuePanel
'            End If
'
'         HideAllIPlinkForms   '09Mar04 CKJ Added
'
'      End Sub

''Private Sub TxtContainerSize_Change()
''
''   If Not StopEvents Then LabelAmended = True
''
''End Sub
''
''Private Sub TxtContainerSize_GotFocus()
''
''   TxtContainerSize.SelStart = 0
''   TxtContainerSize.SelLength = Len(TxtContainerSize.Text)
''
''End Sub
''
''Private Sub TxtContainerSize_KeyDown(KeyCode As Integer, Shift As Integer)
''
''   Select Case KeyCode
''      Case 27 'Escape
''         TxtPromptSetFocus
''      End Select
''
''End Sub

Private Sub TxtInfusionTime_LostFocus()

  'IF FrmIV.visible THEN CalcIV 1, false
  'If fraIV.Visible Then CalcIV 1, True      '25Jan95 CKJ
  CalcIV 1, True      '25Jan95 CKJ

End Sub

''Private Sub TxtPatDet_Change(index)
'''31Jan01 CKJ Added forecolour handler
'''09Feb01 CKJ Removed first Case block - fully handled in the popup form
'''            Moved setting of height units from TxtPatDet_lostfocus
''
''                        'If      Calculated SA <> Dosing SA       then black else grey
''   LblCalcSA.ForeColor = Iff(LblCalcSA.Caption <> TxtPatDet(2).Text, QBColor(0), QBColor(8))
''
''   Select Case Val(TxtPatDet(0).Text)                       '09Feb01 CKJ Moved from the TxtPatDet_lostfocus event
''      Case 0:        LblPatHeight = "Height"
''      Case Is <= 10: LblPatHeight = "Height (ft.in)"
''      Case Else:     LblPatHeight = "Height (cms)"
''      End Select
''
''End Sub

''Private Sub TxtReconVol_Change()
'''10Oct96 ASC
'''24Sep98 TH Changed format
''
''   If Not StopEvents Then
''         If Left$(TxtReconVol.Text, 1) = "." Then
''                TxtReconVol.Text = Format$(TxtReconVol.Text, "##0.##")  '24Sep98 TH Reinstated
''                TxtReconVol.Text = Format$(TxtReconVol.Text)   '14Sep98 TH Changed
''                TxtReconVol.SelStart = Len(TxtReconVol.Text)
''            End If
''         LabelAmended = True
''      End If
''
''End Sub

''Private Sub TxtReconVol_GotFocus()
''
''   TxtReconVol.SelStart = 0
''   TxtReconVol.SelLength = Len(TxtReconVol.Text)
''
''End Sub

''Private Sub TxtReconVol_KeyDown(KeyCode As Integer, Shift As Integer)
''
''   Select Case KeyCode
''      Case 27 'Escape
''         TxtPromptSetFocus
''      End Select
''
''End Sub

Private Sub DirToForm(ByVal add As Boolean)
'ASC 15Dec93
'Copies Direction structure to all elements of the form
'If add then adds one direction to another else blanks it
'!!** could do with setting PRN here from dir code
'30Jul95 ASC Add can now be 2 for when no line feed is required between direction
'            changed all NOT add to add = 0 and Add to add <> 0 then used add = 2
'21Jun96 KR  added check to make picture visible.
'22Jan98 ASC added ucase & trim round route comparison (CKJ)
'05Feb98 CFY Added code to handle Pessaries, Nebules, Lozenges and Sprays
'27Apr98 ASC/CFY Corrected problem which occurred when setting doses per issue unit to 0
'16Oct98 TH  Added various formats
'10Nov98 TH  Added code to retain prn on multiple directions
'09Aug99 SF  added code to auto set manual qty entry check box
'02May00 EAC moved the declaration of daysdefined to the module level so it is not reset between calls to DirToForm
'            removed OptAbsolute as it is not used.
'15May00 EAC added a call to CalcQtys after the fraDays is shown to force the correct calculation of the default
'            issue quantity
'30Mar01 AE  Added code for Stat dose flag
'09May05 CKJ Moved from Patmed
'28Jan13 TH  Added Eyelable section to position route differently on label (39777,55068)
'07Feb13 TH  Ensure route added only once to directions for "eye-label" flagged items TFS 55794,56067

Dim multiplier!
Dim OkToAdd As Integer, X As Integer, ans$, direct$, Numoflines As Integer, druglines As Integer, ReadPtr As Integer, asciiday As Integer, vis As Integer, mins&
Dim FrmTimeOnly As Boolean, FrmDoseOnly As Boolean, DirTimeOnly As Boolean, DirDoseOnly As Boolean, DirBothTimeAndDose As Boolean, TxtDirCodePar$
Dim routeword$

   ReDim lines$(4)

   OkToAdd = True

   If add = 0 Then
      For X = 1 To 6
         TxtDose(X).text = ""
         TxtTime(X).text = ""
      Next
      daysdefined = 0
   End If

   If Len(RTrim$(CmbRoute.text)) > 0 And Len(RTrim$(WDir.route)) > 0 And (WDir.route <> CmbRoute.text) Then
      ans$ = "N"      '30JAn95 CKJ
      Confirm "Route already defined", "change route from " & CmbRoute.text & " to " & WDir.route, ans$, k
      If ans$ <> "Y" Then OkToAdd = False
      If Picture1.Visible = False Then Picture1.Visible = True
   End If

   FrmTimeOnly = False
   FrmDoseOnly = False
   DirTimeOnly = False
   DirDoseOnly = False
   DirBothTimeAndDose = False
   For X = 1 To 6      'for each of the possible six time/dose slots
      'Look at the dispens form
      If Val(TxtDose(X).text) = 0 And Len(LTrim$(TxtTime(X).text)) > 3 Then FrmTimeOnly = True               'Should not happen
      If Val(TxtDose(X).text) > 0 And Len(LTrim$(TxtTime(X).text)) < 3 Then FrmDoseOnly = True

      'Look at the new direction code
      If WDir.dose(X) = 0 And Len(LTrim$(WDir.Times(X))) > 0 Then DirTimeOnly = True
      If WDir.dose(X) > 0 And Len(LTrim$(WDir.Times(X))) = 0 Then DirDoseOnly = True
      If WDir.dose(X) > 0 And Len(LTrim$(WDir.Times(X))) > 0 Then DirBothTimeAndDose = True

      'exit if all four are blank
      If WDir.dose(X) = 0 And Len(LTrim$(WDir.Times(X))) = 0 And Val(TxtDose(X).text) = 0 And Len(LTrim$(TxtTime(X).text)) < 3 Then Exit For
   Next

   If DirBothTimeAndDose And (FrmDoseOnly Or FrmTimeOnly) Then
      OkToAdd = False
      popmessagecr "!", "Time must follow doses"
   End If

   If DirTimeOnly And Not FrmDoseOnly Then
      OkToAdd = False
      popmessagecr "!", "Dose must be specified before time"
   End If

   If daysdefined Then
      For X = 1 To 7
         If L.days(X) = False Then                                   '28Oct05 CKJ Inverted logic to expect 1111111 rather than 0000000
            OkToAdd = False
            popmessagecr "!", "Week days have already been defined"
            Exit For
         End If
      Next
   End If

   If OkToAdd Then
      If add = 0 Then CmbRoute.ListIndex = -1
      If LTrim$(WDir.route) <> "" Then
         For X = 0 To CmbRoute.ListCount - 1
            If UCase$(Trim$(WDir.route)) = UCase$(Trim$(CmbRoute.List(X))) Then
               CmbRoute.ListIndex = X
               Exit For
            End If
         Next
         If X = CmbRoute.ListCount Then popmessagecr "Note", "Route '" & WDir.route & "' is not valid"
      End If

      'Add Direction Text   !!** This section needs a revamp! 19mar96 KR
      '------------------
      If add <> 0 Then
         direct$ = WDir.directs
         druglines = Numoflines
         plingparse direct$, Chr$(30)
         plingparse direct$, Chr$(10)
         If Right$(direct$, 1) = Chr$(10) Then direct$ = Left$(direct$, Len(direct$) - 1)
         deflines direct$, lines$(), Chr$(13), 0, Numoflines

         For X = 0 To Numoflines - 1
            If add = 2 And X = 0 Then 'ASC takes off CR for directions separated by commas
               TxtDirections.text = RTrim$(TxtDirections.text) + LTrim$(RTrim$(lines$(X))) + " "
            Else
               '09May05 NEEDS REVIEW - MAY NOT BE CORRECT TO USE CR & LF LIKE THIS
               
               '28Jan13 TH Added section (39777,55068)
               'If the item is set to routefirst and we are doing outpatient then add route betwee dose and direction
               If d.EyeLabel Then  'Further trapping may be required here
                  GetRouteExpansion Iff((Trim$(CmbRoute.text) = ""), OCXheap("ProductRouteDescription", ""), CmbRoute.text), "", routeword$    '26Jan98 ASC
                  If Trim$(TxtDirections.text) <> "" Then
                     If InStr(TxtDirections.text, routeword$) = 0 Then 'For PRN or multi direction we could call re-entrantly  TFS 55794,56067
                        TxtDirections.text = TxtDirections.text & routeword$ & crlf
                     End If
                  End If
               End If
               '---
               
               TxtDirections.text = TxtDirections.text & LTrim$(RTrim$(lines$(X))) & String$(((Len(RTrim$(lines$(X))) > 0) * -1), Chr$(13)) + String$(((Len(RTrim$(lines$(X))) > 0) * -1), Chr$(10))
               If ReadLanguage(10, 0) = 852 Then
                  If Trim$(ChineseAppend$) <> "" Then
                     If ChineseDirCount >= 1 Then
                        TxtDirections.text = Mid$(TxtDirections.text, 1, Len(TxtDirections.text) - 2) & " " & ChineseAppend$ & crlf$
                        ChineseAppend$ = ""
                        ChineseDirCount = 0
                     Else
                        ChineseDirCount = ChineseDirCount + 1
                     End If
                  End If
               End If
            End If
         Next
      Else
         TxtDirections.text = ""
      End If

      SetRepeatCombo WDir.RepeatUnits
''         If WDir.RepeatInterval > 0 Then TxtRepeatInterval.Text = LTrim$(Str$(WDir.RepeatInterval))
      ReadPtr = 0
      'If d.dosesperissueunit > 0 And (UCase$(Left$(d.PrintformV, 3)) = "TAB" Or UCase$(Left$(d.PrintformV, 3)) = "CAP" Or UCase$(Left$(d.PrintformV, 3)) = "SUP" Or UCase$(Left$(d.PrintformV, 3)) = "MLO" Or UCase$(Left$(d.PrintformV, 3)) = "MGO" Or UCase$(Left$(d.PrintformV, 3)) = "PES" Or UCase$(Left$(d.PrintformV, 3)) = "NEB" Or UCase$(Left$(d.PrintformV, 3)) = "LOZ" Or UCase$(Left$(d.PrintformV, 3)) = "SPR") Then '     "
      If d.dosesperissueunit > 0 And d.LabelInIssueUnits Then
         multiplier! = d.dosesperissueunit
      Else
         multiplier! = 1
      End If

      'Enter doses and times into the boxes.
      If WDir.StatDoseFlag Then
         'Stat dose, enter a single time as NOW and the dose.
         'This is entered into the structure so that the standard
         'routines to enter the times and doses (below) can be used.
         WDir.Times(1) = Format$(Now, "HHMM")
         DirTimeOnly = True
      End If

      'Enter doses and times 1-6 into the boxes from the direction structure.
      '09May05 CKJ amended logic to avoid referencing WDir.dose(0)
      For X = 1 To 6
         If Len(LTrim$(TxtTime(X).text)) < 1 Or Len(LTrim$(TxtDose(X).text)) = 0 Then
            ReadPtr = ReadPtr + 1

            If DirBothTimeAndDose And WDir.dose(ReadPtr) > 0 Then
               TxtTime(X).text = Left$(WDir.Times(ReadPtr), 2) & ":" & Right$(WDir.Times(ReadPtr), 2)  '1030' => '10:30'
               TxtDose(X).text = Format$(LTrim$(Str$(dp!(WDir.dose(ReadPtr) * multiplier!))))

            ElseIf DirTimeOnly And Len(LTrim$(WDir.Times(ReadPtr))) > 1 Then
               If Len(LTrim$(WDir.Times(ReadPtr))) <= 1 Then Exit For
               TxtTime(X).text = Left$(WDir.Times(ReadPtr), 2) & ":" & Right$(WDir.Times(ReadPtr), 2)
               If Val(TxtDose(X).text) = 0 And X > 1 Then
                  TxtDose(X).text = TxtDose(X - 1).text
               End If

            ElseIf DirDoseOnly Then
               If WDir.dose(ReadPtr) = 0 Then Exit For
               TxtDose(X).text = LTrim$(Str$(dp!(WDir.dose(ReadPtr) * multiplier!)))
               TxtDose(X).text = Format$(TxtDose(X).text)
            End If
         End If
      Next

      If Not daysdefined Then
         vis = False
''            asciiday = Asc(WDir.days)
''            For X = 7 To 1 Step -1
''               If asciiday - (2 ^ X) >= 0 Then
''                  asciiday = asciiday - 2 ^ X
''                  ChkDay(X).Value = 1
''                  vis = True
''                  daysdefined = True
''               Else
''                  ChkDay(X).Value = 0
''               End If
''            Next
         For X = 1 To 7
            ChkDay(X).Value = Iff(L.days(X), 1, 0)
            If L.days(X) = False Then                 '01nov05 ckj inverted logic - expects all true so false means an omitted day
               vis = True
               daysdefined = True
            End If
         Next

         fraDays.Visible = vis
         Calcqtys
      End If

      'Sort out course length and stop date etc
      If Not WDir.StatDoseFlag Then
         'Normal doses, calculate stop date based on
         'the course length
         mins& = WDir.CourseLength
         Select Case Trim$(LCase$(WDir.CourseUnits))
            Case "day": mins& = mins& * 1440
            Case "wk":  mins& = mins& * 10080
            Case "hr":  mins& = mins& * 60         '!!** hou hrs
            End Select
      Else
         'STAT dose, stop date is 1 minute from now.
         mins& = 1
         mins& = 1440  '10Jan12 This is the essential component. This allows the dose to be properly calculated. Needs gaurding for complex rxs
         If PCTDrugToDispens() Then setPCTStatflag True '05Jan12 TH Added
      End If

      'Calculate stop date and enter onto form
      If mins& > 0 Then FindStopDate mins&

      'Handle PRN and Manual Qty check boxes.
      'ChkPRN.Value = Val(wdir.prn) 'ASC 01May95
      If WDir.Prn Then
         ChkPRN.Value = 1                 '10Nov98 TH Added to retain prn on multiple directions
         If PCTDrugToDispens() Then setPCTPRNflag True '05Jan12 TH Added
      End If
      If WDir.manualQtyEntry Then ChkManual.Value = 1   '09Aug99 SF added to auto set manual qty entry check box
   Else
      TxtDirCodePar$ = TxtDircode.text
      RemoveUncommitedDirCode TxtDirCodePar$, False
   End If

End Sub

Private Sub EnableTxtDrugAndDirCode(ByVal enable As Boolean)
'28Jul97 CKJ Added. Enables & disables the two text boxes for txtDrugCode and txtDirCode
'            plus the associated buttons.
'

   On Error Resume Next  ' if not loaded etc
   LblCode.Enabled = enable
   lblDirCode.Enabled = enable
   TxtDrugCode.Visible = enable
   TxtDircode.Visible = enable
   LblCode.Visible = enable
   lblDirCode.Visible = enable
   On Error GoTo 0

End Sub

Sub FindStopDate(mins&)
'09May05 moved from patmed

Dim dat$, tim$, valid As Integer
Dim dt As DateAndTime
Dim xp As DateAndTime
   
   If mins& > 0 Then
      xp.mint = mins&
      StringToDate (TxtStartDate.text), dt
      StringToTime (TxtStartTime.text), dt
      datetomins dt
      AddExpiry dt, xp
      DateToString dt, dat$
      TxtStopDate.text = dat$
      TimeToString dt, tim$
      parsetime (tim$), tim$, "1", valid
      TxtStopTime.text = tim$
      Calcqtys
   End If

End Sub

Sub UCsetcolours()

Dim ctrl As Control

   For Each ctrl In Controls
'      Select Case ctrl.ForeColor
'         Case &H80000008
'         Case &H8000000A
'         Case &H80000005
'         End Select
      
'      ctrl.BackColor = &HFFE3D6     'main background
'      ctrl.BackColor = &HC0C0C0     'silver
'      ctrl.BackColor = &HB48246     'bit darker blue
'      ctrl.BackColor = &HA97868     'another blue
'      ctrl.BackColor = &HF0D3C6     'and another
'      ctrl.BackColor = &HE6E0B0     'Paler blue
      
      On Error GoTo ErrorHandler
      Select Case ctrl.BackColor
         Case &H80000008
''            Stop
         Case &H8000000A, &HC0C0C0
            ctrl.BackColor = &HFFE3D6
         Case &H8000000F
            ctrl.BackColor = &HFFE3D6
         Case &H80000005, &HFFFFFF
            'white is fine for text boxes
         Case Else
''            Debug.Print Hex(ctrl.BackColor), ctrl.name
''            Stop
         End Select
            
      Select Case ctrl.name
         Case "Lbldays", "TxtLabel", "Label2", "Label4"
            'no change
         Case Else
            ctrl.FontName = "Arial"
         End Select
         
Continue:
   Next
Exit Sub

ErrorHandler:
Resume Continue

End Sub


Private Sub UserControlEnable(ByVal Active As Boolean)
   
Dim iLoop As Integer

Dim ErrNumber As Long, ErrDescription As String
Dim lngOK As Long
Const ErrSource As String = "UserControlEnable"

Const transparent = 0, opaque = 1

   On Error GoTo ErrorHandler
   BackStyle = Iff(Active, transparent, opaque)
   Picture1.Visible = Active
   Picture1.Enabled = Active

   lblStatus(0).Visible = Not Active
   lblStatus(0).Enabled = Not Active
   If Len(lblStatus(0).Caption) Then Debug.Print lblStatus(0).Caption
      
   If Active Then
      DispensLoad
            
      lblStatus(0) = ""
      
      UCsetcolours
      UserControl.AccessKeys = "O"
   Else
''      OnClosingDispens
      IPLinkShutdown                       '11Aug10 CKJ Added to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)
      lngOK = PharmacyPrescriptionUnLock()
      'More needed? !!**
   End If
   
   SetTextBoxReadOnly TxtStartDate, True
   SetTextBoxReadOnly TxtStartTime, True
   SetTextBoxReadOnly TxtStopDate, True
   SetTextBoxReadOnly TxtStopTime, True
   SetTextBoxReadOnly TxtDircode, True
   SetTextBoxReadOnly TxtDrugCode, True
   SetTextBoxReadOnly TxtDirections, True
   For iLoop = 1 To 6
      SetTextBoxReadOnly TxtDose(iLoop), True
      SetTextBoxReadOnly TxtTime(iLoop), True
   Next
''   SetTextBoxReadOnly TxtRepeatInterval, True
   'SetTextBoxReadOnly TxtFinalVol, True
   SetTextBoxReadOnly TxtFinalVol, False  '19May08 TH Reinstated
   'SetTextBoxReadOnly TxtInfusionTime, True
   SetTextBoxReadOnly TxtInfusionTime, False '19May08 TH Reinstated
   
   CmbDropDrugCode(0).Visible = False
   CmbDropDrugCode(0).Enabled = False
   CmbDropDrugCode(1).Visible = False
   CmbDropDrugCode(1).Enabled = False
   
Cleanup:
'   On Error Resume Next
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Sub

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
   
End Sub

Private Sub UserControlTab(ByVal Shift As Integer)

Dim Index As Integer
Dim TabIndexStart As Long
Dim TabIndexEnd As Long
Dim Increment As Integer
Dim ObjControl As Object

If Shift = 1 Then
    TabIndexStart = CurrentPositionInTabArray - 1
    TabIndexEnd = 0
    Increment = -1
ElseIf Shift = 0 Then
    TabIndexStart = CurrentPositionInTabArray + 1
    TabIndexEnd = 15
    Increment = 1
End If

For Index = TabIndexStart To TabIndexEnd Step Increment
    If TabControlsArray(Index).ControlArrayIndex > -1 Then
       Set ObjControl = colControls(TabControlsArray(Index).name)(TabControlsArray(Index).ControlArrayIndex)
    Else
       Set ObjControl = colControls(TabControlsArray(Index).name)
    End If
    If Not ObjControl Is Nothing And ObjControl.Enabled And ObjControl.Visible Then
        ObjControl.SetFocus
        Exit Sub
    End If
Next Index

SetFocusTo TxtPrompt

End Sub

Sub UCTextBoxHiLight()
'Highlights existing text in a text box. Use in text box's GotFocus event

Dim txtBox As Control

   On Error Resume Next
   Set txtBox = UserControl.ActiveControl
   txtBox.SelStart = 0
   txtBox.SelLength = Len(txtBox.text)
   Set txtBox = Nothing
   On Error GoTo 0

End Sub


Sub PopupFunctionMenu(ByVal blnUseMousePosition As Boolean)
'15Jun11 TH added switch to stop label editing (F0109779)
'01Mar16 XN Removed F6 screen 104303
'26Aug16 XN Added filtering of Return Stock for amm 161138

Dim ans As String
Dim Xpos As Long
Dim Ypos As Long
Dim MousePosition As POINTAPI

   bolFirstPrintCompleted = False   'SP - MM-10661 10.23 Print FF Labels modal dialog issue resolve
   ans = ""
   popmenu 0, "", 0, 0
   
   If blnUseMousePosition Then
      GetCursorPos MousePosition                                  'Get pointer position
      Xpos = MousePosition.X * Screen.TwipsPerPixelX
      Ypos = MousePosition.Y * Screen.TwipsPerPixelY
      Xpos = Xpos - 90                                            'less allowance for border
      Ypos = Ypos - 600                                           'less allowance for border
   Else
      Xpos = lblPrompt(4).Left * Screen.TwipsPerPixelX
      Ypos = lblPrompt(4).Top * Screen.TwipsPerPixelY
   End If
   
   'popmenu 2, "View Label[tab]F2[cr]Further Information[tab]F3[cr]Stock Level Information[tab]F4[cr]Print Free Format Label[tab]F6[cr]Print Bag Label[tab]F7[cr]Issue Stock[tab]F8[cr]Return Stock[tab]F9[cr]Change Instruction[tab]Ctrl-I[cr]Change Warning[tab]Ctrl-W[cr]About...", 0, 0
   'popmenu 2, "View Label[tab]F2[cr]Further Information[tab]F3[cr]Stock Level Information[tab]F4[cr]Print Free Format Label[tab]F6[cr]Print Bag Label[tab]F7[cr]Issue Stock[tab]F8[cr]Return Stock[tab]F9[cr]Change Instruction[tab]Ctrl-I[cr]Change Warning[tab]Ctrl-W[cr]View Robot Messages[tab][cr]About...", 0, 0 XN 1Mar16 Removed F6 short cut 104303
   popmenu 2, "View Label[tab]F2[cr]Further Information[tab]F3[cr]Stock Level Information[tab]F4[cr]Print Free Format Label[cr]Print Bag Label[tab]F7[cr]Issue Stock[tab]F8[cr]Return Stock[tab]F9[cr]Change Instruction[tab]Ctrl-I[cr]Change Warning[tab]Ctrl-W[cr]View Robot Messages[tab][cr]About...", 0, 0
   If gRequestID_AmmSupplyRequest <> 0 Then
      PopMnu.mnuItem(5).Enabled = False
      PopMnu.mnuItem(6).Enabled = False
      PopMnu.mnuItem(7).Enabled = False         '26Aug16 XN Added filtering of Return Stock 161138
   End If
   
   PopMenuShow ans, Xpos, Ypos
   Select Case Val(ans)
      Case 1:  ToggleRxLabel (fraRx.Visible)             'F2
      Case 2:  furtherinfo                               'F3
      Case 3:  MnuStockLevel_Click                       'F4
      '-----                                             'F5
      Case 4:  SelectAndPrintFFlabels                    'F6
      Case 5:  PrintBagLabel                             'F7
      Case 6:  MnuIssue_Click                            'F8
      Case 7:  MnuReturn_Click                           'F9
      '-----                                             'F10
      Case 8:
               If L.IssType = "C" And passlvl <> 8 And TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then '08Oct09 TH (F0062358)
                  popmessagecr "!", TxtD(dispdata$ & "\patmed.ini", "", "This functionality is not currently allowed", "StopCivasEditsMsg", 0)
               ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
                  popmessagecr "!", TxtD(dispdata$ & "\patmed.ini", "", "This functionality is not currently allowed", "StopIssTypeEditsMsg", 0)
               ElseIf passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then '20Jul12 TH Added (TFS 26712)
                  popmessagecr "!", TxtD(dispdata$ & "\patmed.ini", "", "This functionality is not currently allowed", "StopIssTypeEditsMsg", 0)
               Else
                  ChooseInstructionCode                     'Ctrl-I
               End If
               
      Case 9:
               If L.IssType = "C" And passlvl <> 8 And TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then '08Oct09 TH (F0062358)
                  popmessagecr "!", TxtD(dispdata$ & "\patmed.ini", "", "This functionality is not currently allowed", "StopCivasEditsMsg", 0)
               ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
                  popmessagecr "!", TxtD(dispdata$ & "\patmed.ini", "", "This functionality is not currently allowed", "StopIssTypeEditsMsg", 0)
               ElseIf passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then '20Jul12 TH Added (TFS 26712)
                  popmessagecr "!", TxtD(dispdata$ & "\patmed.ini", "", "This functionality is not currently allowed", "StopIssTypeEditsMsg", 0)
               Else
                  ChooseWarningCode                         'Ctrl-W
               End If
      Case 10: ShowAllRobotMessageWindows                '13Mar07 CKJ Added (SC-07-0157)
      Case 11: ShowAboutBox "Dispensing Module"  'mnuAbout_Click
      End Select

   popmenu 0, "", 0, 0

End Sub

Sub RemoveHyperlinkStyle()

Dim iLoop As Integer

   For iLoop = 0 To 4
      If lblPrompt(iLoop).FontUnderline Then
         lblPrompt(iLoop).FontUnderline = False
         lblPrompt(iLoop).Refresh
      End If
   Next
   If L.extralabel Then
      For iLoop = 0 To 9
         If TxtLabel(iLoop).FontUnderline Then
            TxtLabel(iLoop).FontUnderline = False
            TxtLabel(iLoop).Refresh
         End If
      Next
   End If
   
End Sub

Sub ShowDebugScreen()

Dim m As String
Dim s As String
Dim iLoop As Integer

   m = Space$(15) & TB & cr
   m = m & "DEBUG INFORMATION" & cr

   m = m & cr & "Start Date:" & TB & TxtStartDate.text & " " & TxtStartTime.text
   m = m & cr & "Stop Date:" & TB & TxtStopDate.text & " " & TxtStopTime.text
   m = m & cr & "Prep Date:" & TB & txtPrepDate.text & " " & txtPrepTime.text
   s = ""
   For iLoop = 1 To 7
      s = s & Iff(ChkDay(iLoop).Value, Mid$("MTWTFSS", iLoop, 1), "-")
   Next
   m = m & cr & "Days:" & TB & s
'   m = m & cr & ""

   popmessagecr "#", m
   
End Sub
'21Sep09 PJC Created: additional episode elements added to the print heap for output F0054530
'05Oct09 PJC Added Primary Patient Identifier Display to print heap (F0064619)
Private Sub OCXHeapPatientElementToPrintHeap(ByVal HeapID As Integer, pid As patidtype)
   Dim strTmp As String
   Dim strTmpTime As String
   Dim strTmpFormatted As String
   Dim strTmpTimeFormatted As String
   Dim strDateFormat As String
   Dim strTimeFormat As String
   Dim lErrNo        As Long
   Dim sErrDesc      As String

   On Error GoTo ErrHandler
   
   Heap 10, HeapID, "pEpisodeDescription", OCXheap("EpisodeDescription", ""), 0
  
   strDateFormat = TxtD(dispdata$ & "\patmed.ini", "", "yyyymmdd", "PatientPrintHeapEpisodeDateFormat", 0)
   strTimeFormat = TxtD(dispdata$ & "\patmed.ini", "", "hhmmss", "PatientPrintHeapEpisodeTimeFormat", 0)
   
   'process the startdate
   strTmp = OCXheap("EpisodeStartDateFormatted", "")
   If InStr(strTmp, " ") > 0 Then
      strTmpTime = Mid(strTmp, InStr(strTmp, " ") + 1)
      strTmp = Left(strTmp, InStr(strTmp, " ") - 1)
      parsedate strTmp, strTmpFormatted, strDateFormat, 0
      strTmpTimeFormatted = Format(strTmpTime, strTimeFormat)
   End If
   
   Heap 10, HeapID, "pEpisodeStartDateFormatted", strTmpFormatted, 0
   Heap 10, HeapID, "pEpisodeStartTimeFormatted", strTmpTimeFormatted, 0

   'process the enddate
   strTmpFormatted = ""
   strTmpTimeFormatted = ""
   strTmp = OCXheap("EpisodeEndDateFormatted", "")
   If InStr(strTmp, " ") > 0 Then
      strTmpTime = Mid(strTmp, InStr(strTmp, " ") + 1)
      strTmp = Left(strTmp, InStr(strTmp, " ") - 1)
      parsedate strTmp, strTmpFormatted, strDateFormat, 0
      strTmpTimeFormatted = Format(strTmpTime, strTimeFormat)
   End If

   Heap 10, HeapID, "pEpisodeEndDateFormatted", strTmpFormatted, 0
   Heap 10, HeapID, "pEpisodeEndTimeFormatted", strTmpTimeFormatted, 0
   
   Heap 10, HeapID, "pPatientStatusMapped", TxtD(dispdata$ & "\patmed.ini", "", pid.status, "PatientPrintHeapPatientStatus" & pid.status, 0), 0
   
   Heap 10, HeapID, "pPrimaryPatientIdentifierDisplay", OCXheap("PrimaryPatientIdentifierDisplay", ""), 0      '05Oct09 PJC Added Primary Patient Identifier Display to print heap (F0064619)
Cleanup:
   On Error Resume Next
   On Error GoTo 0
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & "OCXHeapPatientElementToPrintHeap", sErrDesc
   End If
      
Exit Sub

ErrHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   Resume Cleanup
End Sub

Sub SetSiteLineColour()
'02Jul12 CKJ written to mirror StoresMenuBarColour

   SetSiteLine SiteLine0, False
   SetSiteLine SiteLine1, True
   
End Sub

Sub SetSiteLine(ctl As Object, ByVal InactiveVisible As Boolean)
'02Jul12 CKJ written to mirror (and use) StoresMenuBarColour
   
Dim enable As Boolean
Dim strColour As String
Dim Colour As Long
   
   On Error GoTo SetSiteLine_Error
   
   enable = False                                                    'assume no connection
   If Not gTransport Is Nothing Then                                 'transport object exists
      'If Not gTransport.Connection Is Nothing Then                  'and is connected
      If Not gTransportConnectionIsNothing() Then                    'and is connected    '04Oct12 CKJ use wrapper TFS44503
         'If gTransport.Connection.State = adStateOpen Then          'and ready for use
         If gTransportConnectionState() = adStateOpen Then           'and ready for use   '04Oct12 CKJ use wrapper TFS44503
            enable = True                                            'proceed
         End If
      End If
   End If
      
   If enable Then
      strColour = TxtD(dispdata$ & "\siteinfo.ini", "", "", "DispensingSiteColour", 0)     'override if desired ("" to no show)
      If Len(strColour) = 0 Then
         strColour = TxtD(dispdata$ & "\siteinfo.ini", "", "", "StoresMenuBarColour", 0)   'default uses Stores setting
      End If
      
      If Len(strColour) Then
         Select Case LCase$(strColour)
            Case "black":   Colour = ColorConstants.vbBlack
            Case "blue":    Colour = ColorConstants.vbBlue
            Case "cyan":    Colour = ColorConstants.vbCyan
            Case "green":   Colour = ColorConstants.vbGreen
            Case "magenta": Colour = ColorConstants.vbMagenta
            Case "red":     Colour = ColorConstants.vbRed
            Case "white":   Colour = ColorConstants.vbWhite
            Case "yellow":  Colour = ColorConstants.vbYellow
            Case Else
               If IsNumeric(strColour) Then
                  Colour = CLng(strColour)
               Else
                  enable = False
               End If
            End Select
      Else
         enable = False
      End If
   End If
    
SetSiteLine_WayOut:
   On Error Resume Next
   If enable Then
      ctl.BorderColor = Colour
      ctl.BorderWidth = Val(TxtD(dispdata$ & "\siteinfo.ini", "", "3", "DispensingSiteColourWidth", 0))
      ctl.Visible = True
   Else
      ctl.Visible = InactiveVisible
      ctl.BorderWidth = 1
      ctl.BorderColor = ColorConstants.vbWhite
   End If
   On Error GoTo 0
   
Exit Sub

SetSiteLine_Error:
   enable = False
Resume SetSiteLine_WayOut

End Sub
Private Sub AppendChildPrescriptionforLinkedRx(ByVal intloop As Integer, ByRef success As Boolean, ByVal blnDurationLastCode As Boolean)
'18Sep15 TH Written in attempt to simplify and refactor a little refreshstate
'18Sep15 TH Extended Prescription Infusion complex linking to allow for custom frequency(TFS 129929)
'15Oct15 TH PRNs may not have direction - these and stat are now handled correctly (though should never be stat as secondary rx) (TFS 137379)
'20Oct15 TH Overhauled to use correct joining word on label (TFS 137379)
'18Jan16 TH Added DurationLastCOde as input param so it can be cached externally and resent (TFS 141453)
'           Added PRN specific joining settings and made the setting used after a stat more explicit (TFS 141453)

Dim strDirectionLinkCode As String
Dim tmpDirCode As String
'Dim blnDurationLastCode As Boolean  '18Jan16 TH Paramaterised this so that it can be stored and fed back in. (TFS 141453)
Dim NumericDose As Single
Dim NumericDoseLow As Single
Dim NumericDoseHigh As Single
Dim PrescribedUnits As String
Dim Scaling As String
Dim strFrequency As String, strDirections As String, strCourse As String
Dim routeword$
Dim InfusionDuration As Single
Dim InfusionDurationLow As Single
Dim TimeUnit As String
Dim strText As String

   Select Case OCXheap("prescriptiontypedescription", "")
      Case "Standard"
         If Val(OCXheap("Dose" & intloop, "")) > 0 Then '08Nov11 TH Added - now complex types can be split some slots may be zero dosed - these should be ignored.
            If Len(Trim(TxtDircode)) > 0 Then  '08Nov11 TH Added - needed because the first codes may now not be present as expected (split dose, complex type)
               If blnDurationLastCode Then '06Sep11 TH Added to allow different link text after a duration goeson the label
                  If (OCXheap("PRN" & intloop, "") = "True") Then
                     strDirectionLinkCode = TxtD(dispdata$ & "\patmed.ini", "", "then ", "DirectionLinkCodeDurationPRN", 0)  '18Sep16 TH Added default setting for PRN (TFS 141453)
                  Else
                     strDirectionLinkCode = TxtD(dispdata$ & "\patmed.ini", "", "then ", "DirectionLinkCodeDuration", 0)  '06Sep11 TH Added default
                  End If
               Else
                  '20Oct15 TH Overhauled to use correct joining word on label (TFS)
                  If intloop = 1 And (OCXheap("ScheduleID_Administration", "") = "0" And OCXheap("NoDoseInfo", "") <> "True" And OCXheap("InfusionContinuous", "") <> "True") And Not (OCXheap("PRN" & intloop, "") = "True") Then
                     'here we have a direction following a STAT that is not PRN - use then
                     'strDirectionLinkCode = TxtD(dispdata$ & "\patmed.ini", "", "then ", "DirectionLinkCodeThen", 0)
                     strDirectionLinkCode = TxtD(dispdata$ & "\patmed.ini", "", "then ", "DirectionLinkCodeAfterSTAT", 0) '18Jan16 TH Made Setting more explicit (TFS 141453)
                  ElseIf (OCXheap("PRN" & intloop, "") = "True") Then
                     'here we have a PRN - these come after normal directions and are preceeded by then
                     '18Jan If we have not had a duration then this must be AND
                     'strDirectionLinkCode = TxtD(dispdata$ & "\patmed.ini", "", "then ", "DirectionLinkCodeThen", 0)
                     strDirectionLinkCode = TxtD(dispdata$ & "\patmed.ini", "", "and ", "DirectionLinkCodePRN", 0) '18Jan16 TH Made Setting more explicit ((TFS 141453)
                  Else
                     'Here we have a standard link - use and
                     strDirectionLinkCode = TxtD(dispdata$ & "\patmed.ini", "", "and ", "DirectionLinkCode", 0)  '06Sep11 TH Added default
                  End If
               End If
               blnDurationLastCode = False
            End If
   
            If Trim$(strDirectionLinkCode) <> "" Then
               tmpDirCode = "TEXT:" & strDirectionLinkCode
               TxtDircode = TxtDircode & tmpDirCode
               TxtDircode = TxtDircode & "/"
            End If
            NumericDose = CSng(OCXheap("Dose" & intloop, ""))
            NumericDoseLow = CSng(OCXheap("DoseLow" & intloop, ""))
            PrescribedUnits = Trim$(OCXheap("UnitAbbreviationDose" & intloop, ""))
            If LCase$(PrescribedUnits) = "qty" Then
               PrescribedUnits = Trim$(OCXheap("productformdescription" & intloop, ""))
            End If

            If ScalePrescribedUnits(d, PrescribedUnits, NumericDose, NumericDoseLow, 0, Scaling) Then
               If NumericDose Then
                  If NumericDoseLow > 0 Then
                     tmpDirCode = Format$(NumericDoseLow) & "-" & Format$(NumericDose)
                  Else
                     '01Jun09 TH Added Clause to round dose on label (F0021850)
                     If Trim$(UCase$(OCXheap("ProductRouteDescription", ""))) = "ORAL" And (Trim$(UCase$(d.PrintformV)) = "ML" Or (Trim$(UCase$(d.PrintformV)) = "BTL" And Trim$(UCase$(d.DosingUnits)) = "MG" Or Trim$(UCase$(d.DosingUnits)) = "ML")) And TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "Y", "LabelTextDoseRounding", 0)) Then
                        If NumericDose >= 1 Then
                           tmpDirCode = Format$(NumericDose, "0.#")
                        Else
                           tmpDirCode = Format$(NumericDose, "0.##")
                        End If
                        'If Right$(TxtDircode, 1) = "." Then tmpDirCode = Left$(TxtDircode, Len(TxtDircode) - 1)
                        If Right$(tmpDirCode, 1) = "." Then tmpDirCode = Left$(tmpDirCode, Len(tmpDirCode) - 1) '16Sep15 TH Remove point correctly to pick up checkstandard (spoon) settings on dose (TFS 129773)
                     Else
                        tmpDirCode = Format$(NumericDose)
                     End If
                  End If

                  TxtDircode = TxtDircode & tmpDirCode
                  TxtDircode = TxtDircode & "/"
               End If
            Else
            'Error Handling
            End If
            '10Sep15 TH if complex type then swap out direction here (TFS 128203) Added section for custom frequency
            If (Len(OCXheap("Dircode" & intloop, "")) = 0) And (Val(OCXheap("ScheduleID_Administration" & intloop, "0")) > 0) Then
               strFrequency = Trim$(OCXheap("Description_Frequency" & intloop, ""))
               If Len(strDirections) > 1 Then
                  strFrequency = LCase$(Left$(strFrequency, 1)) & Right$(strFrequency, Len(strFrequency) - 1)
               ElseIf Len(strFrequency) = 1 Then
                  strFrequency = LCase$(Left$(strFrequency, 1))
               End If
               '05Aug15 TH Skip if doseless for doseless rxs the direction is sent via supplemental text (TFS 125159)
               If OCXheap("prescriptiontypedescription" & intloop, "") <> "Doseless" Then
                  strDirections = Trim$(OCXheap("Description_Direction" & intloop, ""))
                  If Len(strDirections) > 1 Then
                     strDirections = LCase$(Left$(strDirections, 1)) & Right$(strDirections, Len(strDirections) - 1)
                  ElseIf Len(strDirections) = 1 Then
                     strDirections = LCase$(Left$(strDirections, 1))
                  End If
               End If
               
               '10Sep15 TH Add in route if  eyelabel style (TFS 128201)
               If d.EyeLabel Then  'Further trapping may be required here
                  GetRouteExpansion Iff((Trim$(CmbRoute.text) = ""), OCXheap("ProductRouteDescription", ""), CmbRoute.text), "", routeword$    '26Jan98 ASC
                  If Trim$(TxtDirections.text) <> "" Then
                     'If InStr(TxtDirections.text, routeword$) = 0 Then 'For PRN or multi direction we could call re-entrantly  TFS 55794,56067 'I think for complex scripts this is right. Confirmed with AS
                        TxtDirections.text = TxtDirections.text & routeword$ & crlf
                     'End If
                  End If
               End If
            
               TxtDirections.text = TxtDirections.text & strFrequency & " " & strDirections
            Else
               tmpDirCode = OCXheap("DirCode" & intloop, "")
               If Len(tmpDirCode) Then  '15Oct15 TH PRNs may not have direction - these and stat are handled below (though should never be stat as secondary rx) (TFS)
                  TxtDircode = TxtDircode & tmpDirCode
                  TxtDircode = TxtDircode & "/"
               End If
               If OCXheap("PRN" & intloop, "") = "True" Then
                  TxtDircode = TxtDircode & "PRN"
                  TxtDircode = TxtDircode & "/"
                  If PCTDrugToDispens() Then setPCTPRNflag True '05Jan12 TH Added
               'ElseIf OCXheap("ScheduleID_Administration", "") = "0" And OCXheap("NoDoseInfo", "") <> "True" Then      'STAT dose     '02Nov06 AE  Added check for NoDoseInfo flag; (for "as directed" doses).  Don't add STAT direction for these. #SC-06-0928
               ElseIf OCXheap("ScheduleID_Administration" & intloop, "") = "0" And OCXheap("NoDoseInfo" & intloop, "") <> "True" And OCXheap("InfusionContinuous" & intloop, "") <> "True" Then '01Jul13 TH Stop designation a continuous infusion as a stat dose. (TFS 56672)
                  TxtDircode = TxtDircode & "STAT"
                  TxtDircode = TxtDircode & "/"
                  If PCTDrugToDispens() Then setPCTStatflag True '05Jan12 TH Added
               End If
               
            End If
                  
            '19Sep13 TH Made case insensitive (TFS 73783)
            Select Case LCase$(OCXheap("UnitDescriptionDuration" & intloop, ""))
               Case "day", "days"
                  TxtDircode = TxtDircode & OCXheap("Duration" & intloop, "") & "D"
                  TxtDircode = TxtDircode & "/"
                  blnDurationLastCode = True '06Sep11 TH Added
               Case "week", "wk", "weeks"
                  TxtDircode = TxtDircode & OCXheap("Duration" & intloop, "") & "W"
                  TxtDircode = TxtDircode & "/"
                  blnDurationLastCode = True '06Sep11 TH Added
            End Select
         End If
      Case "Infusion"
           If Len(Trim(TxtDircode)) > 0 Then  '08Nov11 TH Added - needed because the first codes may now not be present as expected (split dose, complex type)
               If blnDurationLastCode Then '06Sep11 TH Added to allow different link text after a duration goeson the label
                  strDirectionLinkCode = TxtD(dispdata$ & "\patmed.ini", "", "then ", "DirectionLinkCodeDuration", 0)  '06Sep11 TH Added default
               Else
                  strDirectionLinkCode = TxtD(dispdata$ & "\patmed.ini", "", "and ", "DirectionLinkCode", 0)  '06Sep11 TH Added default
               End If
               blnDurationLastCode = False
            End If
   
            If Trim$(strDirectionLinkCode) <> "" Then
               tmpDirCode = "TEXT:" & strDirectionLinkCode
               TxtDircode = TxtDircode & tmpDirCode
               TxtDircode = TxtDircode & "/"
            End If
            '-----------
         If OCXheap("InfusionContinuous" & intloop, "") = "True" Then
            g_blnSplitDose = False '11Nov11 TH
            'popmessagecr ".", "Prescription type not yet supported: Continuous infusion"
            'success = false
            NumericDose = CSng(OCXheap("InfusionRate" & intloop, ""))
            NumericDoseLow = CSng(OCXheap("InfusionRateMin" & intloop, ""))
            NumericDoseHigh = CSng(OCXheap("InfusionRateMax" & intloop, ""))
            PrescribedUnits = Trim$(OCXheap("UnitAbbreviation_InfusionContinuousRateMass" & intloop, ""))   'UNITID_RATEMASS
            TimeUnit = Trim$(OCXheap("UnitAbbreviation_InfusionContinuousRateTime" & intloop, ""))          'UNITID_RATETIME
            strText = Format$(NumericDose) & " " & PrescribedUnits & "/" & TimeUnit
            If NumericDoseLow > 0 And NumericDoseHigh > 0 Then
               strText = "Start at " & strText & " (range " & Format$(NumericDoseLow) & " to " & Format$(NumericDoseHigh)
               strText = strText & " " & PrescribedUnits & "/" & TimeUnit & ")"
            Else
               strText = "Infuse at " & strText
            End If
            TxtDircode = "TEXT:" & DirectionTextEscape(strText)
            TxtDircode = TxtDircode & "/"
         
         Else                                                           'Intermittent Infusion / bolus injection
            NumericDose = CSng(OCXheap("Quantity_Ingredient" & intloop, ""))
            NumericDoseLow = CSng(OCXheap("QuantityMin_Ingredient" & intloop, ""))
            NumericDoseHigh = CSng(OCXheap("QuantityMax_Ingredient" & intloop, ""))
            PrescribedUnits = Trim$(OCXheap("UnitAbbreviationDose_Ingredient" & intloop, ""))
         
            '04Aug14 TH (TFS 96938)
            'If we are using a dose range then we need to use the high point as the "dose" we will
            'use to dispense from
            If NumericDose = 0 And NumericDoseHigh > 0 Then
               NumericDose = NumericDoseHigh
            End If
         
                                                     '
         End If
   
         If ScalePrescribedUnits(d, PrescribedUnits, NumericDose, NumericDoseLow, NumericDoseHigh, Scaling) Then
            If NumericDose Then                                         'units determined by d.LabelInIssueUnits
               Heap 10, g_OCXheapID, "Quantity_Ingredient_Scaled" & intloop, Format$(NumericDose), 0
               Heap 10, g_OCXheapID, "QuantityMin_Ingredient_Scaled" & intloop, Format$(NumericDoseLow), 0
               Heap 10, g_OCXheapID, "QuantityMax_Ingredient_Scaled" & intloop, Format$(NumericDoseHigh), 0
               If NumericDoseLow > 0 And NumericDoseHigh > 0 Then '07Aug14 TH Added section to handle dose range (TFS 96938)
                  TxtDircode = Format$(NumericDoseLow) & "-" & Format$(NumericDoseHigh)
                  TxtDircode = TxtDircode & "/"
               Else
                  TxtDircode = Format$(NumericDose)
                  TxtDircode = TxtDircode & "/"
               End If
            End If
   
            'Infusion duration and infusion duration range. ... over 12 hours ... over 4 to 6 hours ... etc
            'Stored in dircode as /Over[<n>-]<n><S|M|H|D|W|?>/
            'where ? implies an unknown or invalid time unit
            InfusionDuration = CSng(OCXheap("InfusionDuration" & intloop, ""))
            InfusionDurationLow = CSng(OCXheap("InfusionDurationLow" & intloop, ""))
            If InfusionDuration Then
               tmpDirCode = Format$(InfusionDuration)
               If InfusionDurationLow Then
                  tmpDirCode = Format$(InfusionDurationLow) & "-" & tmpDirCode
               End If
               '19Sep13 TH Made case insensitive (TFS 73783)
               Select Case LCase$(OCXheap("UnitAbbreviation_InfusionDuration" & intloop, ""))
                  Case "sec": TimeUnit = "S"
                  Case "min": TimeUnit = "M"
                  'Case "Hrs": TimeUnit = "H"   '13Jun13 TH Replaced with below as abbrev had been changed (TFS 66438)
                  Case "hrs", "hour", "hours": TimeUnit = "H"
                  Case "day": TimeUnit = "D"
                  Case "wk", "week", "weeks": TimeUnit = "W"
                  Case Else:  TimeUnit = "?"
               End Select
               TxtDircode = TxtDircode & "Over" & tmpDirCode & TimeUnit
               TxtDircode = TxtDircode & "/"
            End If
         Else
            popmessagecr ".Caution", "Infusion/Injection Prescribed:" & crlf & _
            Scaling & crlf & _
            "Prescribed units: " & PrescribedUnits & crlf & _
            "Product Issue units: " & Trim$(d.PrintformV) & crlf & _
            "Product Dosing units: " & Trim$(d.DosingUnits) & crlf & crlf & _
            "Amend the prescription or product before dispensing."
            success = False
            lblStatus(0).Caption = " Suitable product not selected "
         End If
            
         'May need custom frequency handling here ?? '18Sep15 TH Yes , thanks andrew (TFS 129929)
         If (Len(OCXheap("Dircode" & intloop, "")) = 0) And (Val(OCXheap("ScheduleID_Administration" & intloop, "0")) > 0) Then
            strFrequency = Trim$(OCXheap("Description_Frequency" & intloop, ""))
            If Len(strDirections) > 1 Then
               strFrequency = LCase$(Left$(strFrequency, 1)) & Right$(strFrequency, Len(strFrequency) - 1)
            ElseIf Len(strFrequency) = 1 Then
               strFrequency = LCase$(Left$(strFrequency, 1))
            End If
            '05Aug15 TH Skip if doseless for doseless rxs the direction is sent via supplemental text (TFS 125159)
            If OCXheap("prescriptiontypedescription" & intloop, "") <> "Doseless" Then
               strDirections = Trim$(OCXheap("Description_Direction" & intloop, ""))
               If Len(strDirections) > 1 Then
                  strDirections = LCase$(Left$(strDirections, 1)) & Right$(strDirections, Len(strDirections) - 1)
               ElseIf Len(strDirections) = 1 Then
                  strDirections = LCase$(Left$(strDirections, 1))
               End If
            End If
            
            '10Sep15 TH Add in route if  eyelabel style (TFS 128201)
            If d.EyeLabel Then  'Further trapping may be required here
               GetRouteExpansion Iff((Trim$(CmbRoute.text) = ""), OCXheap("ProductRouteDescription", ""), CmbRoute.text), "", routeword$    '26Jan98 ASC
               If Trim$(TxtDirections.text) <> "" Then
                  'If InStr(TxtDirections.text, routeword$) = 0 Then 'For PRN or multi direction we could call re-entrantly  TFS 55794,56067 'I think for complex scripts this is right. Confirmed with AS
                     TxtDirections.text = TxtDirections.text & routeword$ & crlf
                  'End If
               End If
            End If
         
            TxtDirections.text = TxtDirections.text & strFrequency & " " & strDirections
         Else
            tmpDirCode = OCXheap("DirCode" & intloop, "")
            TxtDircode = TxtDircode & tmpDirCode
            TxtDircode = TxtDircode & "/"
            Select Case LCase$(OCXheap("UnitDescriptionDuration" & intloop, ""))
               Case "day", "days"
                  TxtDircode = TxtDircode & OCXheap("Duration" & intloop, "") & "D"
                  TxtDircode = TxtDircode & "/"
                  blnDurationLastCode = True '06Sep11 TH Added
               Case "week", "wk", "weeks"
                  TxtDircode = TxtDircode & OCXheap("Duration" & intloop, "") & "W"
                  TxtDircode = TxtDircode & "/"
                  blnDurationLastCode = True '06Sep11 TH Added
            End Select
         End If
      
   End Select
    
    
End Sub
Private Sub ProcessLabelDuration(ByRef blnDurationLastCode As Boolean)
'28Sep15 TH Written to refactor (a bit) refreshstate. THis just process the durational aspect of the direction codes incomming (TFS 130610)


   '28Sep15 TH Only derive a course length if a valid length is sent. For rxs where duration is templated but then removed we are still getting "0" units through !(TFS 130610)
   If Val(OCXheap("Duration", "0")) > 0 Then
      '19Sep13 TH Made case insensitive (TFS 73783)
      Select Case LCase$(OCXheap("UnitDescriptionDuration", ""))
         Case "day", "days"
            TxtDircode = TxtDircode & OCXheap("Duration", "") & "D"
            TxtDircode = TxtDircode & "/"
            blnDurationLastCode = True '06Sep11 TH Added
            'If PCTDrugToDispens() Then setPCTStatflag True '05Jan12 TH Added
            If PCTDrugToDispens() Then setPCTCourseLength Val(OCXheap("Duration", ""))
         Case "week", "wk", "weeks"
            TxtDircode = TxtDircode & OCXheap("Duration", "") & "W"
            TxtDircode = TxtDircode & "/"
            blnDurationLastCode = True '06Sep11 TH Added
            If PCTDrugToDispens() Then setPCTCourseLength Val(OCXheap("Duration", "")) * 7
         Case Else
            If PCTDrugToDispens() Then setPCTNoCourseLengthFlag True '05Sep12 TH Added
      End Select
   Else
      If PCTDrugToDispens() Then setPCTNoCourseLengthFlag True '28Sep15 TH Retained this
   End If
End Sub

Private Function NewTabControlsStruct(ByVal name As String, _
                           ByVal ControlArrayIndex As Integer) As TabControlsStruct
                           
    Dim t As TabControlsStruct
    t.name = name
    t.ControlArrayIndex = ControlArrayIndex
    NewTabControlsStruct = t
    
End Function
