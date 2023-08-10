VERSION 5.00
Begin VB.UserControl RepeatDispense 
   Appearance      =   0  'Flat
   BackColor       =   &H80000005&
   BackStyle       =   0  'Transparent
   ClientHeight    =   8370
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   14700
   DrawStyle       =   5  'Transparent
   Enabled         =   0   'False
   FillColor       =   &H80000005&
   ForeColor       =   &H80000005&
   InvisibleAtRuntime=   -1  'True
   KeyPreview      =   -1  'True
   ScaleHeight     =   8370
   ScaleWidth      =   14700
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
      TabIndex        =   41
      Top             =   1320
      Visible         =   0   'False
      Width           =   9600
      Begin VB.TextBox TxtNumOfLabels 
         Appearance      =   0  'Flat
         Height          =   285
         Left            =   2340
         TabIndex        =   95
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
         TabIndex        =   94
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
         TabIndex        =   93
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
         TabIndex        =   92
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
         TabIndex        =   91
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
         ScaleHeight     =   315
         ScaleWidth      =   9525
         TabIndex        =   88
         Top             =   3870
         Width           =   9555
      End
      Begin VB.Frame fraLineColour 
         BorderStyle     =   0  'None
         Height          =   3345
         Left            =   0
         TabIndex        =   76
         Top             =   480
         Width           =   2430
         Begin VB.TextBox TxtDircode 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   300
            Left            =   630
            TabIndex        =   7
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
            TabIndex        =   4
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
            TabIndex        =   8
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
            TabIndex        =   5
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
            TabIndex        =   2
            Top             =   576
            Width           =   1745
         End
         Begin VB.TextBox TxtQtyPrinted 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            ForeColor       =   &H00000000&
            Height          =   285
            Left            =   1155
            TabIndex        =   11
            Top             =   1560
            Width           =   725
         End
         Begin VB.CheckBox chkPIL 
            Alignment       =   1  'Right Justify
            Caption         =   "Print Leaflet"
            Enabled         =   0   'False
            Height          =   190
            Left            =   45
            TabIndex        =   18
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
            TabIndex        =   19
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
            TabIndex        =   13
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
            TabIndex        =   0
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
            TabIndex        =   20
            Top             =   3060
            Visible         =   0   'False
            Width           =   2295
         End
         Begin VB.TextBox TextBlister 
            Appearance      =   0  'Flat
            Height          =   285
            Left            =   2025
            TabIndex        =   17
            Top             =   2295
            Visible         =   0   'False
            Width           =   345
         End
         Begin VB.Label LblCode 
            Appearance      =   0  'Flat
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
            Caption         =   "Item"
            ForeColor       =   &H00000000&
            Height          =   240
            Left            =   90
            TabIndex        =   3
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
            TabIndex        =   1
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
            TabIndex        =   10
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
            TabIndex        =   6
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
            TabIndex        =   9
            Top             =   1560
            Width           =   1065
         End
         Begin VB.Label LblUntil 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "until"
            ForeColor       =   &H80000008&
            Height          =   255
            Left            =   90
            TabIndex        =   12
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
            TabIndex        =   14
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
            TabIndex        =   15
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
            TabIndex        =   16
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
         TabIndex        =   42
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
            TabIndex        =   40
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
            TabIndex        =   33
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
            TabIndex        =   22
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
            TabIndex        =   26
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
            TabIndex        =   23
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
            TabIndex        =   21
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
            TabIndex        =   27
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
            TabIndex        =   29
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
            TabIndex        =   31
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
            TabIndex        =   35
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
            TabIndex        =   37
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
            TabIndex        =   44
            Top             =   2250
            Visible         =   0   'False
            Width           =   4425
            Begin VB.TextBox TxtInfusionTime 
               Appearance      =   0  'Flat
               BackColor       =   &H00FFFFFF&
               ForeColor       =   &H00000000&
               Height          =   285
               Left            =   1530
               TabIndex        =   47
               Top             =   0
               Width           =   555
            End
            Begin VB.TextBox TxtFinalVol 
               Appearance      =   0  'Flat
               BackColor       =   &H00FFFFFF&
               ForeColor       =   &H00000000&
               Height          =   285
               Left            =   0
               TabIndex        =   45
               Top             =   0
               Width           =   765
            End
            Begin VB.Label LblInfusionRate 
               Appearance      =   0  'Flat
               BackColor       =   &H00FFFFFF&
               ForeColor       =   &H00800000&
               Height          =   240
               Left            =   3120
               TabIndex        =   50
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
               TabIndex        =   49
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
               TabIndex        =   48
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
               TabIndex        =   46
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
            TabIndex        =   28
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
            TabIndex        =   30
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
            TabIndex        =   32
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
            TabIndex        =   39
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
            TabIndex        =   43
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
            TabIndex        =   34
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
            TabIndex        =   36
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
            TabIndex        =   24
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
            TabIndex        =   53
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
            TabIndex        =   25
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
            TabIndex        =   52
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
            TabIndex        =   51
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
            TabIndex        =   38
            Top             =   1950
            Width           =   1065
         End
      End
      Begin VB.Frame fraLabel 
         Height          =   2835
         Left            =   2520
         TabIndex        =   77
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
            TabIndex        =   87
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
            TabIndex        =   82
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
            TabIndex        =   83
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
            TabIndex        =   84
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
            TabIndex        =   80
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
            TabIndex        =   81
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
            TabIndex        =   86
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
            TabIndex        =   85
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
            TabIndex        =   79
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
            TabIndex        =   78
            Top             =   125
            Width           =   4380
         End
      End
      Begin VB.Frame fraPrepared 
         BorderStyle     =   0  'None
         Height          =   3345
         Left            =   7110
         TabIndex        =   54
         Top             =   420
         Width           =   2435
         Begin VB.TextBox txtPrepDate 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            Enabled         =   0   'False
            ForeColor       =   &H00000000&
            Height          =   285
            Left            =   725
            TabIndex        =   72
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
            TabIndex        =   70
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
            TabIndex        =   69
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
            TabIndex        =   66
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
            TabIndex        =   73
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
            TabIndex        =   55
            Top             =   1800
            Visible         =   0   'False
            Width           =   650
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   7
               Left            =   45
               TabIndex        =   63
               Top             =   1275
               Width           =   240
            End
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   6
               Left            =   45
               TabIndex        =   62
               Top             =   1085
               Width           =   225
            End
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   5
               Left            =   45
               TabIndex        =   61
               Top             =   895
               Width           =   225
            End
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   4
               Left            =   45
               TabIndex        =   60
               Top             =   705
               Width           =   240
            End
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   3
               Left            =   45
               TabIndex        =   59
               Top             =   515
               Width           =   240
            End
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   2
               Left            =   45
               TabIndex        =   58
               Top             =   325
               Width           =   240
            End
            Begin VB.CheckBox ChkDay 
               Height          =   240
               Index           =   1
               Left            =   45
               TabIndex        =   57
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
               TabIndex        =   56
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
            TabIndex        =   67
            Top             =   585
            Visible         =   0   'False
            Width           =   615
         End
         Begin VB.Label lblInfo 
            AutoSize        =   -1  'True
            BackStyle       =   0  'Transparent
            Height          =   195
            Left            =   0
            TabIndex        =   98
            Top             =   360
            UseMnemonic     =   0   'False
            Width           =   165
         End
         Begin VB.Image imgScript 
            Height          =   225
            Left            =   0
            Picture         =   "ucRepeatDispens.ctx":0000
            Top             =   45
            Width           =   240
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
            TabIndex        =   68
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
            TabIndex        =   65
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
            TabIndex        =   64
            Top             =   330
            Visible         =   0   'False
            Width           =   2010
         End
         Begin VB.Line Line1 
            BorderColor     =   &H00FFFFFF&
            X1              =   0
            X2              =   2370
            Y1              =   1725
            Y2              =   1725
         End
         Begin VB.Label lblDSSWarning 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
            ForeColor       =   &H80000008&
            Height          =   495
            Left            =   840
            TabIndex        =   75
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
            TabIndex        =   74
            Top             =   2040
            Width           =   1515
         End
         Begin VB.Label lblPrepared 
            BackStyle       =   0  'Transparent
            Caption         =   "Prepared"
            Height          =   255
            Left            =   0
            TabIndex        =   71
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
         TabIndex        =   97
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
         TabIndex        =   90
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
         TabIndex        =   89
         Top             =   5670
         Visible         =   0   'False
         Width           =   1275
      End
   End
   Begin VB.Label lblStatus 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Enabled         =   0   'False
      ForeColor       =   &H00808080&
      Height          =   195
      Index           =   0
      Left            =   30
      TabIndex        =   96
      Top             =   45
      Width           =   45
   End
End
Attribute VB_Name = "RepeatDispense"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' RepeatDispense UserControl
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
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'21Nov08 CKJ Repeat Dispensing control derived from Dispensing Control
'11Aug10 CKJ Added IPLinkShutDown to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)

'28Apr11 CKJ Removed large amounts of already commented-out code from previous conversion
'            MnuDispensary_click: Removed as not called but forces references to unwanted code
'24May11 CKJ Removed IPDlistMain.bas from project.
'              After commenting out sections it became clear that nothing in it is called from this OCX.
'19Jul10 XN  RefreshState: F0123343 added siteID to pEpisodeSelect
'24Apr13 XN  OpenDBConnection: Changed seed to work on any PC (60910)
'            RefreshState: Changed seed to work on any PC (60910)
'06Nov14 XN  RefreshState: Added setting BSA (83897)

Option Explicit
DefBool A-Z

Dim lastvol As String

Private Const OBJNAME As String = PROJECT & "RepeatDispense."

Public Event RefreshView()    '19Jun09 CKJ No params needed
'

Private Sub fraLineColour_MouseMove(button As Integer, Shift As Integer, X As Single, Y As Single)

'   RemoveHyperlinkStyle
   
End Sub

Private Sub fraPrepared_MouseMove(button As Integer, Shift As Integer, X As Single, Y As Single)

'   RemoveHyperlinkStyle
   
End Sub

Private Sub imgScript_Click()

   ToggleRxLabel (fraRx.Visible)
   SetFocusTo TxtPrompt
   
End Sub


'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
'                    UserControl Inherent Events
'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Private Sub UserControl_AccessKeyPress(KeyAscii As Integer)
'

   Select Case KeyAscii
'@@'      Case Asc("O"), Asc("o"): PopupFunctionMenu False  'Options
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

   Select Case Shift
      Case NO_MASK
         Select Case KeyCode
            Case KEY_F2
               KeyCode = 0
               ToggleRxLabel (fraRx.Visible)
                        
            Case KEY_F6
               KeyCode = 0
               SelectAndPrintFFlabels
               
            Case KEY_F7
               KeyCode = 0
               PrintBagLabel
               
    
            End Select
      
      Case SHIFT_MASK
         Select Case KeyCode
            Case KEY_F12                         'show heap
               KeyCode = 0
               Heap 100, g_OCXheapID, "", "", 0
            End Select
               
      Case CTRL_MASK
            
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
'
End Sub

Private Sub UserControl_KeyUp(KeyCode As Integer, Shift As Integer)
'
End Sub

Private Sub UserControl_MouseMove(button As Integer, Shift As Integer, X As Single, Y As Single)

'   RemoveHyperlinkStyle
   
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
      SetupRepeatDispensForm
   End If
   
End Sub

Private Sub UserControl_Show()
'Fires in design mode and at run time
   
   StoreUCHwnd UserControl.Hwnd     '10Feb07 CKJ
   
End Sub

Private Sub UserControl_Terminate()
'Fires in design mode and at run time
'tidy up & go home
   
   On Error Resume Next
      
   IPLinkShutdown                       '11Aug10 CKJ Added to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)

   If Not gTransport Is Nothing Then
      If gTransportConnectionState() = adStateOpen Then      '15Aug12 CKJ
         gTransportConnectionClose      '15Aug12 CKJ
      End If

      If Not gTransportConnectionIsNothing() Then      '15Aug12 CKJ
         SetgTransportConnectionToNothing      '15Aug12 CKJ
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

Public Function ProcessBatch(ByVal sessionID As Long, _
                           ByVal AscribeSiteNumber As Long, _
                           ByVal RepeatDispensingAction As String, _
                           ByVal RepeatDispensingBatchXML As String, _
                           ByVal URLToken As String _
                          ) As Boolean
                            
'19Jun09 CKJ written, derived from RefreshState()

Dim success As Boolean
Dim RepeatDispensingBatchID As Long
Dim RepeatDispensingXML As String
Dim strXML As String
Dim strBatchNotes As String

    Dim xmldoc As MSXML2.DOMDocument
    Dim XMLelement As MSXML2.IXMLDOMElement
Dim xmlnode As MSXML2.IXMLDOMElement
Dim PackerSection As String
Dim MachineName As String
Dim DisplayName As String
Dim strText As String
'Dim lngMTSNo As Long
'Dim blnMTSNoSuccess As Boolean
Dim strFile As String
Dim strOutfile As String
Dim strFileinfo As String
Dim strPrintReport As String
Dim intReportChan As Integer
Dim strPrevFile As String
Dim intMultiplier As Integer
Dim RptDisp As frmRptDisp


   'Set Parent for Modal form - for resolve modal from issue in MS Edge
   SetOwnerForm Me          'AS : MS_Edge_Fix for modal windows without an owner form

   'DebugMsgBox RepeatDispensingBatchXML
   If Not CancelIsRequested() And Not OCXisBusy() Then
      SetOCXBusy True
      '** may need preparatory checks here
      
      If OpenDBConnection(sessionID, AscribeSiteNumber, URLToken) Then
         'After OpenDBConnection, g_SessionID & SiteNumber are global
         
         On Error GoTo ProcessBatchError
         
         success = SetRepeatDispensingMode(RepeatDispensingAction)
         
         If success Then
            
            SetRepeatDispensingBatchXML RepeatDispensingBatchXML
            setRepeatDispensingAction RepeatDispensingAction
            Set RptDisp = New frmRptDisp
            
            Load RptDisp
            
            RptDisp.Show 1, Me                  'AS : MS_Edge_Fix for modal windows without an owner form
         
            Unload RptDisp
            Set RptDisp = Nothing
         End If
      End If
      
      SetOCXBusy False
      SetCancelRequested False               'exiting now, so reset cancellation flag
      ProcessBatch = success
      
   ElseIf CancelIsRequested() Then
      '** handle cancellation while in progress
      'probably nothing to do here, just exit without starting recursive code. Wait for flag to be handled lower down & bubble up.
      
   Else
      ProcessBatch = False
      
   End If
   
   'Reset Parent form
   ResetOwnerForm   'AS : MS_Edge_Fix for modal windows without an owner form

ProcessBatchExit:
   On Error Resume Next
   Set xmlnode = Nothing
   Set XMLelement = Nothing
   Set xmldoc = Nothing
   On Error GoTo 0

Exit Function

ProcessBatchError:
   success = False
   strBatchNotes = strBatchNotes & ">>>>> Error: " & Err.Number & " " & "Source: " & "ProcessBatch " & Err.Description
Resume ProcessBatchExit

RptErrExit:

Resume ProcessBatchExit
   
End Function

Public Sub Cancel()

'25Nov08 CKJ written.
'            During a batch process of labelling or issuing, the hosting web page may wish to cancel the process
'            Calling this function sets a flag which is checked at strategic points and the remainder of the batch
'            is abandoned. Note that there may be a delay before exiting, and that the state of the batch is
'            indeterminate. A cancelled call to .ProcessBatch() returns success=False if cancelled.

   If OCXisBusy() Then
      SetCancelRequested True
   End If

End Sub

'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
'                    Private Procedures Called from Public Method
'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Private Function RefreshState(ByVal sessionID As Long, _
                             ByVal AscribeSiteNumber As Long, _
                             ByVal RequestID_Prescription As Long, _
                             ByVal RequestID_Dispensing As Long, _
                             ByVal URLToken As String _
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

'26nov08 PRIVATE - prior to removal
'19Jul10 XN  F0123343 added siteID to pEpisodeSelect
'24Apr13 XN  Changed seed to work on any PC (60910)
'06Nov14 XN  Added setting BSA (83897)

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

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "RefreshState"
   
   '23Nov05 CKJ Is the user control fully awake & connected? If not then release completely
   On Error Resume Next
   If gTransport Is Nothing Then                                     'transport object doesn't exist
      'no action                                                     ' we'll create it in the next block below
   Else                                                              'transport object is alive
      If gTransportConnectionIsNothing() Then                        'but not connected      '16Aug12 CKJ
         Set gTransport = Nothing                                    ' terminate the transport object ready for a clean creation below
      Else                                                           'it is connected
         If gTransportConnectionState() = adStateOpen Then           'open & ready for use      '16Aug12 CKJ
            'no action                                               ' no further action, just use it
         Else                                                        'but not properly open
            gTransportConnectionClose                                ' attempt to close (may be connecting, handling an error etc)      '16Aug12 CKJ
            SetgTransportConnectionToNothing                         ' disconnect      '16Aug12 CKJ
            Set gTransport = Nothing                                 ' terminate the transport object ready for a clean creation below
         End If
      End If
        
      '**!!** consider ClosePatsubs etc to reset globals
   End If
   On Error GoTo ErrHandler
   
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

   If success Then
      If Not gTransport Is Nothing Then
         If Not gTransportConnectionIsNothing() Then      '16Aug12 CKJ
            If gTransportConnectionState() = adStateOpen Then      '16Aug12 CKJ
            
               gEntityID_User = gTransport.ExecuteSelectReturnSP(g_SessionID, "pEntityIDFromSessionID", "")
               strParam = gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
               Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPersonSelect", strParam)
               If Not rs Is Nothing Then
                  If rs.State = adStateOpen Then
                     If rs.RecordCount <> 0 Then
                        UserID = RtrimGetField(rs!initials)
                        UserFullName = Trim$(RtrimGetField(rs!title) & " " & RtrimGetField(rs!forename) & " " & RtrimGetField(rs!surname))
                        acclevels$ = "1000000000" 'default access, because we couldn't be here unless the user has role "Pharmacy"
                        '**!!** escalate access if extra policies set up - eg use a custom policy
                     End If
                     rs.Close
                  End If
                  Set rs = Nothing
               End If
          
'@@'
''               If UnsavedChanges Then
''                  popmessagecr "?", "Save Changes?"    '**!!**
''                  '
''               End If
   
               gRequestID_Prescription = RequestID_Prescription         'master copies for reference throughout the program
               gRequestID_Dispensing = RequestID_Dispensing             'not changed except by a call to this proc
               
               FillHeapDrugInfo -gPRNheapID, d, 0                       'clear drug from print heap
               FillHeapLabelInfo -gPRNheapID, L, 0
               FillHeapStandardInfo gPRNheapID
               
               DestroyOCXheap
               success = ParseKeyValuePairsToHeap("Version=V93", "|", "=", g_OCXheapID)   'create heap with single entry
   
               If success Then
                  EpisodeID = GetState(g_SessionID, StateType.Episode)
                  gTlogEpisode = EpisodeID                              'JP 15.04.2008 Needed for translog
                  GetEpisodeToOCXHeap EpisodeID, gDispSite                              '19Jul10 XN  F0123343 added siteID to pEpisodeSelect             '26Sep05 CKJ Moved logic from above
                  WPatientID = CLng(OCXheap("EntityID", "0"))
                  If WPatientID <> 0 Then
                     success = GetPatientByPK(WPatientID, WPat)
                  Else
                     success = False
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
                  pid.forename = WPat.forename
                  pid.surname = WPat.surname
                                 
                  'pid.ward = UCase$(OCXheap("WardCode", "NONE"))          'GetEpisodeDataItem(EpisodeID, "WardCode"))    'WPat.ward                  '25Sep08 CKJ removed defaults
                  'pid.cons = UCase$(OCXheap("ConsultantCode", "NONE"))    'UCase$(GetEpisodeDataItem(EpisodeID, "ConsultantCode"))      'WPat.cons       "
                  pid.ward = UCase$(OCXheap("WardCode", ""))               'GetEpisodeDataItem(EpisodeID, "WardCode"))    'WPat.ward                      "
                  pid.cons = UCase$(OCXheap("ConsultantCode", ""))         'UCase$(GetEpisodeDataItem(EpisodeID, "ConsultantCode"))      'WPat.cons       "
                  
   ''               pid.GP = UCase$(OCXheap("GPCode", "NONE"))             'WPat.GP
                  
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
                  
                  Else
                     pid.Height = OCXheap("HeightM", "")      'WPat.height
                     pid.weight = OCXheap("WeightKg", "")     'WPat.weight
                     pid.SurfaceAreaInM2 = OCXheap("BSA", "") 'WPat.BSA  83897 XN 6Nov14
                                    
                     RequestID_PrescriptionValid = False                               '03Mar06 CKJ/TH Block added
                     If RequestID_Prescription Then
                        If IsRequestCancelled(RequestID_Prescription) Then
                           popmessagecr "!", "Prescription has already been cancelled"
                        Else
                           RequestID_PrescriptionValid = True
                        End If
                     Else   '21Oct08 TH Added
                        'Could be new functionality from
                        Select Case gRequestID_Dispensing
                           Case -1
                              FrmPatPrint.Show 1, Me            'AS : MS_Edge_Fix for modal windows without an owner form
                              '20Nov07 TH Added to clear state
                              'UserControlEnable False
                              'DoAction.Caption = "RefreshView-Inactive"
                              RequestID_PrescriptionValid = False
                              
                           Case -3           'Print bag label - Middlemore (F000)
                              patlabel k, pid, True, Val(TxtD(dispdata$ & "\patmed.ini", "", "0", "BagLabelDoAll", 0))
                              RequestID_PrescriptionValid = False
                           End Select
                     End If
                        
                     If RequestID_PrescriptionValid Then
                        'pid.Status = WPat.Status
                        'GetEpisodeDataItem(EpisodeID, "EpisodeTypeDescription"))
                        '01dec05 CKJ Amended status handling to be a two stage process
                        pid.status = UCase$(OCXheap("EpisodeTypeDescription", "A"))    'Use status from patient editor
                        Select Case pid.status
                           Case "I", "O", "D", "L" 'No action required
                              'OK
                           Case Else
                              pid.status = UCase$(OCXheap("EpisodeTypeCode", "A"))     'Use status of episode itself
                           End Select
                        
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
                     
                        FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0
                        success = PrescriptionToOCXHeap(RequestID_Prescription)         'fill OCX heap
                        
                        If success Then
                           UserControlEnable True
                           SetOCXDetailsSize
                           SetupRepeatDispensForm    'ensure OCX data is visible
                           SetOCXdetails       'display data
                           
                           '07Nov07 TH PCT Workaround
                           If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "PharmacWorkaround", 0)) Then
                              SetUpPCTWorkaround RequestID_Prescription  'TH PCT Workaround entry point
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
                              Else
                                 DisplaytheLabAndForm 1, 0, 0, "", 0
                              End If
                           Else                                                  'load prescription, blank label
                              BlankWLabel L
                              Blanklabel
                              'success = GetProductNLbyProductID(OCXheap("ProductID", "0"), d)
                              Select Case OCXheap("prescriptiontypedescription", "")
                                 Case "Infusion"
                                    findrdrug "¦" & OCXheap("ProductID_Ingredient", "0"), False, d, 0, intSuccess, False, False, False
                                 Case Else
                                    findrdrug "¦" & OCXheap("ProductID", "0"), False, d, 0, intSuccess, False, False, False
                                 End Select
                              success = (intSuccess <> 0)
                              
                              If success Then
                                 L.SisCode = d.SisCode
                                 
                                 'Product code
                                 TxtDrugCode.text = L.SisCode
                                                                  
                                                                 
            ''                     TxtDrugCode_KeyDown 13, 0
                                 EnterDrug False
            ''                     fraLineColour.Refresh
                                 blnSuppDirCodeUsed = False
                                 FillHeapDrugInfo gPRNheapID, d, 0
                                 
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
      
                                       If ScalePrescribedUnits(d, PrescribedUnits, NumericDose, NumericDoseLow, 0, Scaling) Then
                                          If NumericDose Then
                                             If NumericDoseLow > 0 Then
                                                TxtDircode = Format$(NumericDoseLow) & "-" & Format$(NumericDose)
                                             Else
                                                TxtDircode = Format$(NumericDose)
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
                                                                        
                                    Case "Doseless" '------------------------------------------------ 'Doseless prescription
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
                                          popmessagecr ".WARNING", "Incomplete doseless prescription - please check alias configuration." & cr & "Frequency: '" & tmpDirCode & "'    Direction: '" & OCXheap("DirCode", "") & "'"
                                          success = False
                                          lblStatus(0).Caption = " Doseless prescription - Incomplete"
                                       End If


                                    Case "Infusion" '------------------------------------------------ 'Infusion or injection prescription
                                       DoAction.Caption = "DELETEDIR"
                                       If OCXheap("InfusionContinuous", "") = "True" Then
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
                                                
                                          If ScalePrescribedUnits(d, PrescribedUnits, NumericDose, NumericDoseLow, NumericDoseHigh, Scaling) Then
                                             If NumericDose Then                                         'units determined by d.LabelInIssueUnits
                                                Heap 10, g_OCXheapID, "Quantity_Ingredient_Scaled", Format$(NumericDose), 0
                                                Heap 10, g_OCXheapID, "QuantityMin_Ingredient_Scaled", Format$(NumericDoseLow), 0
                                                Heap 10, g_OCXheapID, "QuantityMax_Ingredient_Scaled", Format$(NumericDoseHigh), 0
                                                TxtDircode = Format$(NumericDose)
                                                TxtDircode = TxtDircode & "/"
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
                                                Select Case OCXheap("UnitAbbreviation_InfusionDuration", "")
                                                   Case "Sec": TimeUnit = "S"
                                                   Case "Min": TimeUnit = "M"
                                                   Case "Hrs": TimeUnit = "H"
                                                   Case "Day": TimeUnit = "D"
                                                   Case "Wk":  TimeUnit = "W"
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
                                    If Len(tmpDirCode) Then
                                       TxtDircode = TxtDircode & tmpDirCode
                                       TxtDircode = TxtDircode & "/"
                                    End If
         
                                    'PRN flag
                                    If OCXheap("PRN", "") = "True" Then
                                       TxtDircode = TxtDircode & "PRN"
                                       TxtDircode = TxtDircode & "/"
                                    ElseIf OCXheap("ScheduleID_Administration", "") = "0" And OCXheap("NoDoseInfo", "") <> "True" Then      'STAT dose     '02Nov06 AE  Added check for NoDoseInfo flag; (for "as directed" doses).  Don't add STAT direction for these. #SC-06-0928
                                       TxtDircode = TxtDircode & "STAT"
                                       TxtDircode = TxtDircode & "/"
                                    End If
                                    
                                    'Duration
                                    Select Case OCXheap("UnitDescriptionDuration", "")
                                       Case "Day"
                                          TxtDircode = TxtDircode & OCXheap("Duration", "") & "D"
                                          TxtDircode = TxtDircode & "/"
                                       Case "Week"
                                          TxtDircode = TxtDircode & OCXheap("Duration", "") & "W"
                                          TxtDircode = TxtDircode & "/"
                                       End Select
                                    
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
                                                
   '               'Stop date
   ''               strStopDate = Trim$(OCXheap("StopDate", ""))           '' or 'dd/mm/ccyy' or 'dd/mm/ccyy hh:nn'
   ''               If Len(strStopDate) Then
   ''                  strStopTime = Mid$(strStopDate, 12, 5)              '' or 'hh:nn'
   ''                  If Len(strStopTime) = 0 Then strStopTime = "00:00"
   ''                  strStopDate = Left$(OCXheap("StopDate", ""), 10)    'dd/mm/ccyy'
   ''
   ''                  TxtStopDate.Text = strStopDate
   ''                  TxtStopTime.Text = strStopTime
   '
   '               Else
   '                  strStopDate = ""                    'date now as 'dd/mm/ccyy'
   '                  strStopTime = ""            'corresponding time as hh:mm
   ''               End If
                                                                                                  
                                                                                                  
                    '               If TxtDircode.Text <> "" And passlvl <> 3 Then                               'non-prescribers only
                    '                  createlabel 1
                    '                  memorytolabel
                                    If Left$(CmbIssueType.List(CmbIssueType.ListIndex), 1) = "C" Then formtolabel 0  '10Jun05 TH Added  **!!**
                                    
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
                                             askwin "?PCT", TxtD(dispdata$ & "\patmed.ini", "", strDefaultPCTQuestion, "PCTWorkAroundQuestion", 0), strAns, k
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
                        Else
                           lblStatus(0).Caption = " Prescription not found "
                           popmessagecr "#", "Prescription not found" & crlf & crlf & "(Prescription ID = " & Format$(RequestID_Prescription) & ")"
                        End If
                     Else                                                  'no requestid_prescription supplied so shut down interface
                        success = False
                        lblStatus(0).Caption = ""                          'no prescription or dispensing specified - not an error
                        'note dispensing without prescription is an error, but not worth a message as it is disabled anyway
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
   
Cleanup:
   
   If Not success Then
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

'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
'                    Events Raised By Embedded Controls
'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Private Sub lblStatus_MouseUp(Index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)
      
End Sub

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

Private Sub CmbIssueType_Click()
'03Apr KR/EAC Removed - removed bug when selecting items in list
'07Jul97 KR Change issue type description when changing issue type.
'08Jul97 KR/CKJ check if previouse type was civas
'05Feb99 SF now only calls createlabel: if label has not been reused

   If L.IssType <> Left$(CmbIssueType.List(CmbIssueType.ListIndex), 1) And passlvl <> 3 Then '5Jul97 ASC
         '!!** wascivas% = (l.isstype = "C")
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
         RaiseEvent RefreshView

      Case "RefreshView-Save"
''         RaiseEvent RefreshView(gRequestID_Prescription, L.RequestID)
         'No action needed on saving label during repeat dispensing.

      Case "RefreshState-ForceInactive"
         On Error Resume Next
         IPLinkShutdown                       '11Aug10 CKJ Added to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)
         gTransportConnectionClose      '16Aug12 CKJ
         On Error GoTo 0
         dummy = RefreshState(g_SessionID, gDispSite, 0, 0, "")

      'Case
      '
      'more...
      '
      End Select
         
   DoAction.Caption = ""

End Sub


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

   SetFocusTo TxtPrompt

End Sub

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
                                       popmessagecr "!", "Insufficient room on label"
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

   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                               '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then    '         "
         Exit Sub                                                                         '         "
      End If                                                                              '         "
   End If
   '27May08 TH -----------

End Sub

Private Sub TxtLabel_GotFocus(Index As Integer)
'08Apr97 KR added dispens Setfocus to recapture input focus
'08May97 KR changed.  Check form  handle before call setfocus event to prevent
'illegal function call if a modal form showing on top of dispens frm e.g. a message box
'08Apr99 TH  Moved Wardchange call to click event to prevent multiple firing

''Dim activecolour As Long
Dim dd$

   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                               '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then    '        "
            Exit Sub                                                                      '        "
         End If                                                                           '        "
   End If                                                                                 '        "
   '27May08 TH ----------
   
''   currentline = index
   If Index = 9 Then
         SetFocusTo TxtPrompt
         Exit Sub
      End If
      
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

Dim found&, startpos%, ans$, carry$, linx%, done%, X%, splitpoint%

   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                               '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then    '        "
         KeyCode = 0                                                                      '        "
         Exit Sub                                                                         '        "
      End If                                                                              '        "
   End If                                                                                 '        "
   '27May08 TH --------
   
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
   
   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                               '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then    '           "
         KeyAscii = 0                                                                     '           "
         Exit Sub                                                                         '           "
      End If                                                                              '           "
   End If                                                                                 '           "
   '27May08 TH ------------
   
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

   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                                  '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then       '       "
         KeyCode = 0                                                                         '       "
         Exit Sub                                                                            '       "
      End If                                                                                 '       "
   End If                                                                                    '       "
   '27May08 TH --------------

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
   labelline$(Index) = temp$ & RTrim$(ans$)     '20 Jan95 CKJ

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

Dim iBut As Integer

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

Dim rsFormula As ADODB.Recordset
Static blnNonCIVASIssue As Boolean '30May08 TH Added
   
''   labftemp& = Labf&
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
               
               Case 119          'F8 Issue
                  If RTrim$(L.SisCode) <> "" And passlvl <> 3 Then
                        Choice$ = "I"
                        returned = False
                        Action% = 1           '24Mar97 KR added
                     End If

               Case 120          'F9 Return
                  If RTrim$(L.SisCode) <> "" And passlvl <> 3 Then
                        Choice$ = "I"
                        returned = True
                        Action% = 1           '24Mar97 KR added
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

            Heap 10, gPRNheapID%, "lPatientCost", "", 0        '30Sep02 ATW BMI Billing; Blank cost to patient to prevent it spilling onto other labels.
            
            If isPBS() Then
               If (Not PrivateBilling()) Then
                  blnPBSPassed = True
                  PBSPreIssueChecks blnPBSPassed
                  If Not blnPBSPassed Then Exit Sub
               End If                                                                                                           '    "
            End If
            
            If Labf& = 0 Then
               SaveLabel complete       '16Nov98 added complete
               If Labf& = 0 Then Exit Sub  '01Sep01 TH If 0 then hasnt created new label (>50 meds) so dont continue (#54440)
''               labftemp& = Labf&
            Else
               CheckRxComplete complete
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
                     If DailyDoses! = 0 And L.dose(1) = 0 And (InStr(LCase(TxtDircode.text), "stat") > 0) Then
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
   
                     If Not k.escd Or (PBSDrugToDispens()) Then
                        Qty! = Val(TxtQtyPrinted.text)
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
                              GetCostCentre (pid.ward), costcentre$     '15Mar99 SF added
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
                                                   
                              If Issued Then                '15Dec98 SF added
                                 GlobalManufBatchNum$ = batchnumber$  '13Feb02 TH Added (#47263)
                                 '20Nov00 SF/CFY only increment batch number if not been done by patient billing
                                 If Not TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "BillPatient", 0)) Then
                                    L.batchnumber = L.batchnumber + 1
                                 Else                                                                                            '19Mar03 TH (PBSv4) Added  to allow
                                    If PBSSwitchedOff() Then L.batchnumber = L.batchnumber + 1                                   '    "      PBS to be set up but switched off
                                 End If                                                                                          '    "
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
                                          DisplaytheLabel NumofLabels + ExtraLabels, 3, k, expiry$, 0, False '07Jan13 TH Added Param   'Dont use wrapper here
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
                                    If Not Issued Then
                                          popmessagecr "#EMIS Health", "Labels will be printed only.  No items will be issued."  '04June97
                                          PatBillStub = billpatient(17, "")  '02Dec99 SF added to clear PBS items on a label re-print
                                       End If
                                    'If TrueFalse(TxtH$(dispdata$ & "\patmed.ini", "patient billing", "N", "BillPatient", 0)) Then   '24Aug00 JN Added check to only increment if Pharmacc is turned off '18Oct00 JN Changed to line below
                                    '20Nov00 SF/CFY moved logic to a different part of the procedure
                                    'If TxtH$(dispdata$ & "\patmed.ini", "patient billing", "", "BillPatient", 0) <> "N" And Issued Then         '18Oct00 JN Changed line above as was not being picked up properly
                                    '      l.batchnumber = l.batchnumber + 1  '23Jun00 JN ##~HERE~###
                                    '   End If
                                    '20Nov00 SF/CFY -----
''                                                                  TGLabelList.Refresh      '07oct03 CKJ
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
                                 End If
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
                                             
                        If Issued Then
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
         
'~~~~~~~~~~~~~~>
         Case "R"
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
                  
               If Not k.escd Then
                  ReprintFile Val(result$), 2, Labf&, 0 '07Jan13 TH Added Param  '04Mar02 TH Added Parameter (#MOJ#)
               End If
            End If

'~~~~~~~~~~~~~~>
         Case "A", "AN"                   ' amend the memory image                             '29May01 TH Added second clause
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
            If isPBS() Then                            '31Jan03 TH (PBSv4) Added
               If Not (TrueFalse(TxtD(dispdata & "\" & "patmed.ini", "PatientBilling", "N", "PBSLaunchIssueScreen", 0))) Then   '20Jun03 TH Suppress checks now if box will pop automatically later on
                  blnPBSPassed = True
                  If returned Then blnPBSPassed = 3    '07Apr03 TH (PBSv4) Added
                  PBSPreIssueChecks blnPBSPassed
                  If Not blnPBSPassed Then Exit Sub    '!!**
               End If                                                                                                          '20Jun03 TH
            End If
            getformula formulafound%, rsFormula                 '06Sep98 ASC now only shows message if the item has a formula
            If formulafound Then                                                          '02Aug99 AE
               If GetField(rsFormula!DosingUnits) = False Then BatchProduct = True
            End If

            If formulafound And L.IssType = "C" And Not returned Then                        '03Aug99 AE added formula found
               popmessagecr "!", "CIVAS items must be issued with a label and work sheet"
            ElseIf formulafound And Not BatchProduct And Not returned Then                '03Aug99 AE added formula found                                                '02Aug99 AE
               popmessagecr "Manufacturing", "Non-Batch manufactured items must be issued with a label and work sheet."
            Else                                                                         '     "
               dircode$ = Trim$(L.dircode)
               Qty! = dp!(Val(TxtQtyPrinted.text))
               
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
                        returned = False
                        Qty! = dp!(Qty! * -1) '25Aug93 added dp! ASC
                     End If
                     
                     BlankWProduct d
                     d.SisCode = L.SisCode
   
                     If (Qty! < 0) And (TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "", "N", "ReturnsLogging", 0))) = True Then       '03Mar00 TH Added logging code to try and trap mismatched returns
                        LSet Rtemp = L
                        'Rowinedit = TGLabelList.RowIndex
   ''                     PMRItem$ = LstRX$(TGLabelList.RowIndex)                                                          '   "      '07oct03 CKJ
                        'logtext = " Current label = " & Rtemp.record & crlf & " Current Drug = " & d.SisCode & " description : " & d.Description & crlf & crlf & " Current pmr details = " & PMRItem$   XN 4Jun15 98073 New local stores description
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
                        Issue k, Qty!, 0, d, UserID$, (pid.recno), dircode$, Issued, (pid.status), (costcentre$), (pid.cons), SiteNumber, L.IssType, UnitCost$, batchnumber$, expiry$, 0, 0, Action   '15Mar99 SF
                        k.escd = False '27Mar95 ASC added as belt and braces
                        If Issued Then
                           '20Nov00 SF/CFY only increment batch number if not been done by patient billing
                           If Not TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "BillPatient", 0)) Then L.batchnumber = L.batchnumber + 1
                           
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
            If isPBS() Then                                  '09Mar03 TH (PBSv4) Added
               If (Not PrivateBilling()) Then
                  blnPBSPassed = True
                  PBSPreIssueChecks blnPBSPassed
                  If Not blnPBSPassed Then Exit Sub
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

Private Sub TxtQtyPrinted_Change()
'06Jun97 KR Added.
   
'   If Val(TxtQtyPrinted.Text) = 0 Then Stop
   TxtQtyPrinted.Tag = "Edit"
   
End Sub

Private Sub TxtQtyPrinted_GotFocus()

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


Private Sub TxtStartDate_Change()
   
   If Not StopEvents Then LabelAmended = True

End Sub


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

'Dim objPhaRTL As PHARTL10.Security
'Dim ConnectionString As String     '15Aug12 CKJ
Dim valid As Boolean
Dim phase As Single
Dim strDetail As String
Dim ErrNumber As Long, ErrDescription As String
Dim UnencryptedData As String '28Jun12 AJK 36929 Replacement for ConnectionString
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
         If Not gTransportConnectionIsNothing() Then    '16Aug12 CKJ
            If gTransportConnectionState() = adStateOpen Then    '16Aug12 CKJ
               'gTransport.ADOSetConnectionTimeOut 5    '16Aug12 CKJ not appropriate
               valid = True
            End If
         End If
      End If
       
      If Not valid Then
         'ConnectionString = ParseURLToken(sessionID, URLToken, phase, strDetail)
         UnencryptedData = ParseURLToken(sessionID, URLToken, phase, strDetail, blnUseWebConn, strWebDataProxyURL, strUnencryptedToken)
         
         If blnUseWebConn Then
            Set gTransport = New PharmacyWebData.Transport
            gTransport.UnencryptedKey = UnencryptedData
            gTransport.URLToken = strUnencryptedToken
            gTransport.ProxyURL = strWebDataProxyURL
            valid = True
         Else
            '~~~~~~~~~~~~~~~DEBUG ONLY~~~~~~~~~~~~~~
            'ConnectionString = "provider=sqloledb;server=***;database=***;uid=***;password=***;"
            'ConnectionString = "provider=sqloledb;server=server\instance;database=dbname;uid=icwsys;password=whatever;"
            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            If UnencryptedData <> "" Then
               phase = 4
               Set gTransport = New PharmacyData.Transport
               phase = 5
               Set gTransport.Connection = New ADODB.Connection
               phase = 6
               gTransport.Connection.open UnencryptedData
               valid = True
            End If
         End If
         
         If valid Then
            phase = 7
            gDispSite = GetLocationID_Site(SiteNumber)
            
            phase = 8
            ReadSiteInfo
             
            App.HelpFile = AppPathNoSlash() & "\ASCSHELL.HLP"
   
            fraIVdetails.BackColor = White '19May08 TH Added
         End If
      End If
   End If
   
Cleanup:
   If ErrNumber Then
      On Error Resume Next
      gTransportConnectionClose    '16Aug12 CKJ
      SetgTransportConnectionToNothing    '16Aug12 CKJ
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
      MsgBox " Unable to connect " & strDetail & " (Phase=" & Format$(phase, "0.#") & ")"   '17Aug12 CKJ added  "0.#"
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
   
'deleted
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

Dim result%, manpn%, found%, abort$
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

   onloadingdispens
   If StopEvents Then           '18Feb98 CKJ failed to load patient records eg locked
''      patno& = 0              '08Nov05 CKJ
      r.record = ""
      LSet pid = r      '**!!** needs thought
      Exit Sub               '18Feb98 CKJ Added              <=== WAY OUT
                         
   Else
      MnuDisplay_Click 4    '09May05 should not do this here    ' View All '
   End If
   
      
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
         SetupRepeatDispensForm
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

Sub PrintBagLabel()

   patlabel k, pid, True, 1
   
End Sub


Private Sub mnuOptionsHdg_Click()

End Sub

Private Sub MnuOriginalDate_Click()
'31Jan03 TH (PBSv4) Added proc
Dim X%
 
   X = billpatient(11, "")

End Sub


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


Private Sub printOCXdetails(ByVal strText As String, ByVal blnItalic As Integer)
'14Feb03 CKJ written
'01Aug05 CKJ Changed from plain/bold to italic/plain
   
   picOCXdetails.FontBold = False         ' (blnBold <> 0)
   picOCXdetails.FontItalic = (blnItalic <> 0)
   picOCXdetails.Print strText;

End Sub



Private Sub SetupRepeatDispensForm()
'14Feb03 CKJ Moved all the resize code to the resize event

Dim intPanelTop As Integer
Dim intpicOCXlines As Integer
   
   On Error GoTo SetupRepeatDispensFormErr
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

SetupRepeatDispensFormExit:
   UserControl.Refresh
Exit Sub

SetupRepeatDispensFormErr:
   On Error GoTo 0
Resume SetupRepeatDispensFormExit

End Sub


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


Private Sub TxtInfusionTime_LostFocus()

  'IF FrmIV.visible THEN CalcIV 1, false
  'If fraIV.Visible Then CalcIV 1, True      '25Jan95 CKJ
  CalcIV 1, True      '25Jan95 CKJ

End Sub


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

Dim multiplier!
Dim OkToAdd As Integer, X As Integer, ans$, direct$, Numoflines As Integer, druglines As Integer, ReadPtr As Integer, asciiday As Integer, vis As Integer, mins&
Dim FrmTimeOnly As Boolean, FrmDoseOnly As Boolean, DirTimeOnly As Boolean, DirDoseOnly As Boolean, DirBothTimeAndDose As Boolean, TxtDirCodePar$


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
      End If

      'Calculate stop date and enter onto form
      If mins& > 0 Then FindStopDate mins&

      'Handle PRN and Manual Qty check boxes.
      'ChkPRN.Value = Val(wdir.prn) 'ASC 01May95
      If WDir.Prn Then ChkPRN.Value = 1                 '10Nov98 TH Added to retain prn on multiple directions
      If WDir.manualQtyEntry Then ChkManual.Value = 1   '09Aug99 SF added to auto set manual qty entry check box
   Else
      TxtDirCodePar$ = TxtDircode.text
      RemoveUncommitedDirCode TxtDirCodePar$, False
   End If

End Sub

Private Sub EnableTxtDrugAndDirCode(ByVal Enable As Boolean)
'28Jul97 CKJ Added. Enables & disables the two text boxes for txtDrugCode and txtDirCode
'            plus the associated buttons.
'

   On Error Resume Next  ' if not loaded etc
   LblCode.Enabled = Enable
   lblDirCode.Enabled = Enable
   TxtDrugCode.Visible = Enable
   TxtDircode.Visible = Enable
   LblCode.Visible = Enable
   lblDirCode.Visible = Enable
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


'~~~~~~~~~~~~~~~~~~~~~~~
'24May11 CKJ removed as not called but forces references to unwanted code
'Sub MnuDispensary_click(index As Integer)
'
'Dim validpass As Integer
'Dim fullname$, Accesslvl As String
'Dim modulename$
'Dim frmFormula As Form  '25Sep02 TH Added (#62898)
'
'   validpass = True
'
'   Select Case index
'      Case 2
'         modulename = "Prescription Management"
'      End Select
'
'''   If PatientSequenceState() < 2 Or ModuleName = "" Then    '23Jun06 CKJ Added for when in patient sequence   '$$ <1 or <2 ??
'''      askpassword validpass, fullname$, ModuleName
'''      glastid$ = UserID$
'''      glastaccesslevel$ = acclevels$
'''      glastuserfullname$ = UserFullName$
'''   Else
'''      UserID$ = glastid$
'''      acclevels$ = glastaccesslevel$
'''      UserFullName$ = glastuserfullname$
'''   End If
'
'   If validpass Then
'      Select Case index
'         Case 2      'prescription management
'            Accesslvl = Mid$(acclevels$, 1, 1)
'            If Accesslvl > "0" Then
'                  '@@'Ipdlist.Show 1
'                  Set frmFormula = New Formula  /
'                  CallIPDlist frmFormula     /
'                  Set frmFormula = Nothing   /
'                  SetupRptDispensFrm
'                  CallRptDispens       /
'            End If
'
'         End Select
'   End If
'
'End Sub


Private Function OpenDBConnection(ByVal sessionID As Long, _
                          ByVal AscribeSiteNumber As Long, _
                          ByVal URLToken As String _
                         ) As Boolean
'25Nov08 CKJ
'24Apr13 XN  Changed seed to work on any PC (60910)

Dim success As Boolean
Dim strParam As String

Dim rs As ADODB.Recordset

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "OpenDBConnection"
   
   OpenDBConnection = False
   
   'Is the user control fully awake & connected? If not then release completely
   On Error Resume Next
   If gTransport Is Nothing Then                                     'transport object doesn't exist
      'no action                                                     ' we'll create it in the next block below
   Else                                                              'transport object is alive
      If gTransportConnectionIsNothing() Then                        'but not connected    '16Aug12 CKJ
         Set gTransport = Nothing                                    ' terminate the transport object ready for a clean creation below
      Else                                                           'it is connected
         If gTransportConnectionState() = adStateOpen Then           'open & ready for use    '16Aug12 CKJ
            'no action                                               ' no further action, just use it
         Else                                                        'but not properly open
            gTransportConnectionClose                                ' attempt to close (may be connecting, handling an error etc)    '16Aug12 CKJ
            SetgTransportConnectionToNothing                         ' disconnect    '16Aug12 CKJ
            Set gTransport = Nothing                                 ' terminate the transport object ready for a clean creation below
         End If
      End If
   End If
   On Error GoTo ErrHandler
   
   success = True
   If (gTransport Is Nothing) Or sessionID <> g_SessionID Then    'session is never zero, so this fires once at startup and again if session ever changes  '23Nov05 CKJ added gTransport
      If UnsavedChanges Then
         popmessagecr "!Please Note:", "Changes from previous session have been discarded"
      End If
      UserControlEnable False  '@@'??
      If sessionID <> 0 And g_SessionID = 0 Then
         lblStatus(0).Caption = " Connecting ... "
      ElseIf sessionID <> g_SessionID Then
         lblStatus(0).Caption = " SessionID changed ... "
      Else
         lblStatus(0).Caption = " Reconnecting ... "
      End If
      
'      frmBlank.Tag = Format$(((1# * frmBlank.Top * frmBlank.Left) / frmBlank.Width) * frmBlank.Height)
      frmBlank.Tag = Format$(((1# * frmBlank.DefaultTop * frmBlank.DefaultLeft) / frmBlank.DefaultWidth) * frmBlank.DefaultHeight)  '24Apr13 XN 60910 Changed connection string encryption seed to work on any PC

      success = SetConnection(sessionID, AscribeSiteNumber, URLToken)
   End If

   If success Then
      If Not gTransport Is Nothing Then
         If Not gTransportConnectionIsNothing Then    '16Aug12 CKJ
            If gTransportConnectionState() = adStateOpen Then    '16Aug12 CKJ
               gEntityID_User = gTransport.ExecuteSelectReturnSP(g_SessionID, "pEntityIDFromSessionID", "")
               strParam = gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
               Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPersonSelect", strParam)
               If Not rs Is Nothing Then
                  If rs.State = adStateOpen Then
                     If rs.RecordCount <> 0 Then
                        UserID = RtrimGetField(rs!initials)
                        UserFullName = Trim$(RtrimGetField(rs!title) & " " & RtrimGetField(rs!forename) & " " & RtrimGetField(rs!surname))
                        acclevels$ = "1000000000" 'default access, because we couldn't be here unless the user has role "Pharmacy"
                        '**!!** escalate access if extra policies set up - eg use a custom policy
                     End If
                     rs.Close
                  End If
                  Set rs = Nothing
               End If
                            
               OpenDBConnection = True
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
   
Cleanup:
   
   If Not success Then
      gRequestID_Prescription = 0
      gRequestID_Dispensing = 0
      Labf& = 0
      gTlogCaseno$ = ""
      DestroyOCXheap
      UserControlEnable False
      DoAction.Caption = "RefreshView-Inactive"
   End If
   
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   
   If ErrNumber Then
      MessageBox ErrDescription, vbCritical + vbOKOnly, Format$(ErrNumber) & " " & ErrSource
      OpenDBConnection = False
   End If
   
Exit Function

ErrHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
   
End Function



