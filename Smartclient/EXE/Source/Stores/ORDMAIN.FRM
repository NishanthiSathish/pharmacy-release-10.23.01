VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Object = "{00025600-0000-0000-C000-000000000046}#5.2#0"; "crystl32.ocx"
Begin VB.Form MainScreen 
   Appearance      =   0  'Flat
   AutoRedraw      =   -1  'True
   BackColor       =   &H000000C0&
   BorderStyle     =   3  'Fixed Dialog
   ClientHeight    =   6450
   ClientLeft      =   1845
   ClientTop       =   2505
   ClientWidth     =   9495
   FillStyle       =   0  'Solid
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   9.75
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   Icon            =   "ORDMAIN.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6450
   ScaleWidth      =   9495
   WindowState     =   2  'Maximized
   Begin MSComctlLib.StatusBar LblHelpPrompt 
      Align           =   2  'Align Bottom
      Height          =   495
      Left            =   0
      TabIndex        =   11
      Top             =   5955
      Visible         =   0   'False
      Width           =   9495
      _ExtentX        =   16748
      _ExtentY        =   873
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   10
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
         BeginProperty Panel2 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
         BeginProperty Panel3 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
         BeginProperty Panel4 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
         BeginProperty Panel5 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
         BeginProperty Panel6 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
         BeginProperty Panel7 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
         BeginProperty Panel8 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
         BeginProperty Panel9 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
         BeginProperty Panel10 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.ListView lvwMainScreen 
      CausesValidation=   0   'False
      Height          =   4935
      Left            =   240
      TabIndex        =   10
      Top             =   960
      Visible         =   0   'False
      Width           =   3015
      _ExtentX        =   5318
      _ExtentY        =   8705
      LabelEdit       =   1
      MultiSelect     =   -1  'True
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      Checkboxes      =   -1  'True
      FullRowSelect   =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   16777215
      BorderStyle     =   1
      Appearance      =   1
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      NumItems        =   0
   End
   Begin VB.PictureBox picToolBar 
      Align           =   1  'Align Top
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
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
      ForeColor       =   &H80000008&
      Height          =   615
      Left            =   0
      ScaleHeight     =   615
      ScaleWidth      =   9495
      TabIndex        =   7
      TabStop         =   0   'False
      Top             =   0
      Visible         =   0   'False
      Width           =   9495
      Begin VB.CommandButton cmdToolbar 
         Caption         =   "Empty"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Index           =   0
         Left            =   0
         Style           =   1  'Graphical
         TabIndex        =   9
         Top             =   0
         Width           =   1215
      End
      Begin VB.Line lineToolBar 
         Visible         =   0   'False
         X1              =   0
         X2              =   32000
         Y1              =   585
         Y2              =   585
      End
   End
   Begin VB.PictureBox PicLayout 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
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
      ForeColor       =   &H80000008&
      Height          =   5325
      Left            =   0
      ScaleHeight     =   5325
      ScaleWidth      =   9495
      TabIndex        =   2
      TabStop         =   0   'False
      Top             =   600
      Width           =   9495
      Begin MSComDlg.CommonDialog CommonDialog1 
         Left            =   8055
         Top             =   4560
         _ExtentX        =   847
         _ExtentY        =   847
         _Version        =   393216
      End
      Begin VB.Timer DebugInfoTimer 
         Enabled         =   0   'False
         Interval        =   100
         Left            =   8685
         Top             =   4575
      End
      Begin VB.PictureBox PicInfo2 
         BackColor       =   &H00D8FFD8&
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
         Left            =   5760
         ScaleHeight     =   315
         ScaleWidth      =   1275
         TabIndex        =   13
         Top             =   4560
         Visible         =   0   'False
         Width           =   1335
      End
      Begin VB.PictureBox PicInfo1 
         BackColor       =   &H00D8FFFF&
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
         Left            =   4200
         ScaleHeight     =   315
         ScaleWidth      =   1035
         TabIndex        =   12
         Top             =   4560
         Visible         =   0   'False
         Width           =   1095
      End
      Begin VB.TextBox TxtInput 
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
         Left            =   6120
         MaxLength       =   14
         TabIndex        =   5
         Top             =   3840
         Visible         =   0   'False
         Width           =   1875
      End
      Begin VB.Frame FrmGauge 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         Caption         =   "Processing Automatic Orders"
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
         Left            =   4320
         TabIndex        =   4
         Top             =   1800
         Visible         =   0   'False
         Width           =   3360
         Begin VB.CommandButton CmdAutoOrder 
            Appearance      =   0  'Flat
            Cancel          =   -1  'True
            Caption         =   "&Cancel"
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
            Height          =   330
            Left            =   2340
            Style           =   1  'Graphical
            TabIndex        =   6
            Top             =   315
            Width           =   915
         End
         Begin MSComctlLib.ProgressBar Progress 
            Height          =   420
            Left            =   120
            TabIndex        =   8
            Top             =   240
            Width           =   2175
            _ExtentX        =   3836
            _ExtentY        =   741
            _Version        =   393216
            Appearance      =   1
         End
      End
      Begin VB.ListBox LstDisplay 
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
         Height          =   2760
         Left            =   2880
         TabIndex        =   3
         Top             =   960
         Visible         =   0   'False
         Width           =   5595
      End
      Begin Crystal.CrystalReport RptStockTake 
         Left            =   0
         Top             =   0
         _ExtentX        =   741
         _ExtentY        =   741
         _Version        =   348160
         PrintFileLinesPerPage=   60
      End
      Begin VB.Label lblHeading 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         BackColor       =   &H80000003&
         BorderStyle     =   1  'Fixed Single
         Caption         =   "Label1"
         ForeColor       =   &H80000008&
         Height          =   700
         Index           =   0
         Left            =   0
         TabIndex        =   14
         Top             =   0
         Visible         =   0   'False
         Width           =   1935
         WordWrap        =   -1  'True
      End
      Begin VB.Label LblGrid 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   300
         Left            =   0
         TabIndex        =   1
         Top             =   0
         Width           =   750
      End
      Begin VB.Label LblInput 
         Alignment       =   1  'Right Justify
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Enter Code for Amendment"
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
         Height          =   195
         Left            =   3720
         TabIndex        =   0
         Top             =   3840
         Visible         =   0   'False
         Width           =   2280
      End
   End
   Begin VB.Menu MnuPrgm 
      Caption         =   "&Program"
      Begin VB.Menu MnuProgram 
         Caption         =   "&Printer Setup"
         Enabled         =   0   'False
         Index           =   0
         Visible         =   0   'False
      End
      Begin VB.Menu MnuProgram 
         Caption         =   "&Login"
         Enabled         =   0   'False
         Index           =   2
         Visible         =   0   'False
      End
      Begin VB.Menu MnuProgram 
         Caption         =   "E&xit"
         Index           =   4
         Shortcut        =   ^X
      End
   End
   Begin VB.Menu mnuEditTop 
      Caption         =   "&Edit"
      Begin VB.Menu mnuEdit 
         Caption         =   "Undo"
         Index           =   1
      End
      Begin VB.Menu mnuEdit 
         Caption         =   "Cut"
         Index           =   2
      End
      Begin VB.Menu mnuEdit 
         Caption         =   "Copy"
         Index           =   3
      End
      Begin VB.Menu mnuEdit 
         Caption         =   "Paste"
         Index           =   4
      End
      Begin VB.Menu mnuEdit 
         Caption         =   "Delete"
         Index           =   5
      End
   End
   Begin VB.Menu MnuOrders 
      Caption         =   "&Orders"
      Begin VB.Menu MnuOrdersCreate 
         Caption         =   "Automatic Order &Creation"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuOrdersAmend 
         Caption         =   "A&mend Orders"
         Enabled         =   0   'False
      End
      Begin VB.Menu mnuPSOAmend 
         Caption         =   "Amend Patient Specific Orders"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuPreOrderPrint 
         Caption         =   "&Pre-Order Print"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuOrdersAuth 
         Caption         =   "Au&thorise Orders"
         Enabled         =   0   'False
      End
      Begin VB.Menu mnuPSOAuth 
         Caption         =   "Authorise Patient Specific Orders"
         Enabled         =   0   'False
      End
      Begin VB.Menu line26 
         Caption         =   "-"
         Index           =   0
      End
      Begin VB.Menu MnuOrdersSupp 
         Caption         =   "Authorise &Supplementary Orders"
         Enabled         =   0   'False
      End
      Begin VB.Menu Line1 
         Caption         =   "-"
      End
      Begin VB.Menu MnuOrdersReceive 
         Caption         =   "&Receive Goods"
         Enabled         =   0   'False
      End
      Begin VB.Menu mnuPSORec 
         Caption         =   "Receive Patient Specific Goods"
         Enabled         =   0   'False
      End
      Begin VB.Menu mnuPSOHubRec 
         Caption         =   "Receive eHub POD"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuGoodsRcvd 
         Caption         =   "&Goods Received Report"
         Enabled         =   0   'False
      End
      Begin VB.Menu mnuStockList 
         Caption         =   "&Shelf Stocking List"
         Enabled         =   0   'False
      End
      Begin VB.Menu x 
         Caption         =   "-"
      End
      Begin VB.Menu MnuOrdersCredit 
         Caption         =   "Enter/Amend &Credits to Supplier"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuOrdersAuthCred 
         Caption         =   "&Authorise Credit Orders"
         Enabled         =   0   'False
      End
      Begin VB.Menu mnudivide 
         Caption         =   "-"
      End
      Begin VB.Menu MnuRepOrds 
         Caption         =   "Repri&nt"
         Enabled         =   0   'False
         Begin VB.Menu MnuReprint 
            Caption         =   "&Orders"
            Index           =   0
         End
         Begin VB.Menu MnuReprint 
            Caption         =   "&Returns"
            Index           =   1
         End
      End
      Begin VB.Menu mnudivide1 
         Caption         =   "-"
      End
      Begin VB.Menu MnuRobotLoading 
         Caption         =   "Robot &Loading"
         Enabled         =   0   'False
      End
   End
   Begin VB.Menu MnuOrdersModem 
      Caption         =   "E&DI"
      Begin VB.Menu MnuMediate 
         Caption         =   "&Ordering"
         Enabled         =   0   'False
         Index           =   0
      End
      Begin VB.Menu MnuMediate 
         Caption         =   "&Process Reply Price"
         Enabled         =   0   'False
         Index           =   1
      End
      Begin VB.Menu MnuMediate 
         Caption         =   "&Invoicing"
         Enabled         =   0   'False
         Index           =   2
      End
      Begin VB.Menu mnuEdi 
         Caption         =   "&Settings"
         Enabled         =   0   'False
         Index           =   0
      End
   End
   Begin VB.Menu MnuReq 
      Caption         =   "&Requisitions"
      Begin VB.Menu MnuReqEnter 
         Caption         =   "&Enter Requisitions"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuToFollows 
         Caption         =   "&To Follows Report"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuReqPrintPick 
         Caption         =   "Print &Picking Tickets"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuReqIssue 
         Caption         =   "&Issue Picking Tickets"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuReqDelivery 
         Caption         =   "Print &Delivery Notes"
         Enabled         =   0   'False
      End
      Begin VB.Menu Line4 
         Caption         =   "-"
      End
      Begin VB.Menu MnuReqReturn 
         Caption         =   "&Return to Store"
         Enabled         =   0   'False
      End
      Begin VB.Menu NewLine1 
         Caption         =   "-"
      End
      Begin VB.Menu MnuRepReqs 
         Caption         =   "Repri&nt"
         Enabled         =   0   'False
         Begin VB.Menu MnuReprintReq 
            Caption         =   "Pic&king Tickets"
            Index           =   2
         End
         Begin VB.Menu MnuReprintReq 
            Caption         =   "&Delivery Notes"
            Index           =   3
         End
      End
   End
   Begin VB.Menu MnuFin 
      Caption         =   "&Finance"
      Begin VB.Menu MnuFinRecon 
         Caption         =   "Invoice &Reconciliation"
         Enabled         =   0   'False
      End
      Begin VB.Menu mnuPSOInv 
         Caption         =   "Patient Specific &Invoice Reconciliation"
         Enabled         =   0   'False
      End
      Begin VB.Menu mnuPSOHubInv 
         Caption         =   "Patient Specific eHub Invoice Reconcilliation"
      End
      Begin VB.Menu mnuPSOHubInvSettings 
         Caption         =   "Patient Specific eHub Invoice Settings"
      End
      Begin VB.Menu MnuFinConfirm 
         Caption         =   "&Credit Note Confirmation"
         Enabled         =   0   'False
      End
      Begin VB.Menu Line5 
         Caption         =   "-"
      End
      Begin VB.Menu MnuFinAP 
         Caption         =   "Accounts Payable &Interface"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuFinDispNotes 
         Caption         =   "Print Di&spute Notes"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuFinSlips 
         Caption         =   "&Print Coding Slips"
         Enabled         =   0   'False
      End
      Begin VB.Menu line6 
         Caption         =   "-"
      End
      Begin VB.Menu MnuFinMonthEnd 
         Caption         =   "&Month End Discounts/Credits"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuFinAdj 
         Caption         =   "Stock Value &Adjustments"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuFinDirect 
         Caption         =   "&Direct Entry Reconcilation"
         Enabled         =   0   'False
      End
      Begin VB.Menu line7 
         Caption         =   "-"
      End
      Begin VB.Menu MnuFinGL 
         Caption         =   "General Ledger Link"
         Enabled         =   0   'False
      End
      Begin VB.Menu line35 
         Caption         =   "-"
      End
      Begin VB.Menu mnufinreprints 
         Caption         =   "&Reprint"
         Enabled         =   0   'False
         Begin VB.Menu MnuFinReprintDNotes 
            Caption         =   "&Dispute Notes"
         End
      End
   End
   Begin VB.Menu MnuInfoTop 
      Caption         =   "&Information"
      Begin VB.Menu MnuInfo 
         Caption         =   "&Item Enquiry"
         Enabled         =   0   'False
         Index           =   0
         Shortcut        =   +{F4}
      End
      Begin VB.Menu MnuInfo 
         Caption         =   "&Site Enquiry"
         Enabled         =   0   'False
         Index           =   1
      End
      Begin VB.Menu MnuInfo 
         Caption         =   "-"
         Index           =   2
      End
      Begin VB.Menu MnuInfo 
         Caption         =   "&Orders in progress enquiry"
         Enabled         =   0   'False
         Index           =   3
      End
      Begin VB.Menu MnuInfo 
         Caption         =   "&Requisitions in progress enquiry"
         Enabled         =   0   'False
         Index           =   4
      End
      Begin VB.Menu MnuInfo 
         Caption         =   "-"
         Index           =   5
      End
      Begin VB.Menu MnuInfo 
         Caption         =   "&Log Viewer"
         Enabled         =   0   'False
         Index           =   6
      End
      Begin VB.Menu MnuInfo 
         Caption         =   "Log Viewer &Group on Product"
         Index           =   7
      End
      Begin VB.Menu MnuInfo 
         Caption         =   "-"
         Index           =   8
      End
      Begin VB.Menu MnuInfo 
         Caption         =   "View Robot Messages"
         Enabled         =   0   'False
         Index           =   9
      End
   End
   Begin VB.Menu MnuWS 
      Caption         =   "&WardStock"
      Begin VB.Menu MnuWardStock 
         Caption         =   "Ad-hoc &Issue"
         Enabled         =   0   'False
         Index           =   0
      End
      Begin VB.Menu MnuWardStock 
         Caption         =   "Ad-hoc &Return"
         Enabled         =   0   'False
         Index           =   1
      End
      Begin VB.Menu MnuWardStock 
         Caption         =   "-"
         Index           =   2
      End
      Begin VB.Menu MnuWardStock 
         Caption         =   "&Edit,Issue and Return"
         Enabled         =   0   'False
         Index           =   3
      End
      Begin VB.Menu MnuWardStock 
         Caption         =   "-"
         Index           =   4
      End
      Begin VB.Menu MnuWardStock 
         Caption         =   "&Print Stock Lists without Barcodes"
         Enabled         =   0   'False
         Index           =   5
      End
      Begin VB.Menu MnuWardStock 
         Caption         =   "Print Stock Lists with &Barcodes"
         Enabled         =   0   'False
         Index           =   6
      End
      Begin VB.Menu MnuWardStock 
         Caption         =   "Print &Alphabetical Lists"
         Enabled         =   0   'False
         Index           =   7
      End
      Begin VB.Menu MnuWardStock 
         Caption         =   "-"
         Index           =   8
      End
      Begin VB.Menu MnuWardStock 
         Caption         =   "&Location of Stock on Wards"
         Enabled         =   0   'False
         Index           =   9
      End
      Begin VB.Menu MnuWardStock 
         Caption         =   "&Maintenance"
         Enabled         =   0   'False
         Index           =   10
         Begin VB.Menu MnuWSDrugInfo 
            Caption         =   "Search and &Replace across wards"
         End
         Begin VB.Menu MnuWSDelete 
            Caption         =   "Search and &Delete across Wards"
         End
         Begin VB.Menu MnuWSMissing 
            Caption         =   "&Report NSV Codes not in Product File"
         End
      End
      Begin VB.Menu MnuWardStock 
         Caption         =   "&Ward Stock Interface"
         Index           =   12
      End
   End
   Begin VB.Menu MnuUtil 
      Caption         =   "&Utilities"
      Begin VB.Menu MnuUtilLevel 
         Caption         =   "Print Stock &Level for Live Stocked Item"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuUtilDang 
         Caption         =   "List &Overdue items below danger level"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuUtilNeg 
         Caption         =   "List all live items with &negative stock"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuUtilAmend 
         Caption         =   "&Amend Site Details"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuUtilDefs 
         Caption         =   "Set / Report &Working Defaults"
      End
      Begin VB.Menu Line30 
         Caption         =   "-"
      End
      Begin VB.Menu MnuUtilCalcs 
         Caption         =   "&End of Period Calculations"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuUtilTidy 
         Caption         =   "&Tidy and Reindex Orders"
         Enabled         =   0   'False
         Visible         =   0   'False
      End
      Begin VB.Menu MnuUtilOut 
         Caption         =   "Calculate Outstanding &Quantities"
         Enabled         =   0   'False
      End
      Begin VB.Menu line31 
         Caption         =   "-"
      End
      Begin VB.Menu MnuUtilCycle 
         Caption         =   "Set Supplier Order &Cycle Number"
         Enabled         =   0   'False
      End
      Begin VB.Menu MnuUtilContPrice 
         Caption         =   "A&mend Drug Contract Prices"
         Enabled         =   0   'False
      End
      Begin VB.Menu line32 
         Caption         =   "-"
      End
      Begin VB.Menu MnuUtilRestore 
         Caption         =   "&Restore a Modem transmission for amend"
         Enabled         =   0   'False
         Visible         =   0   'False
      End
      Begin VB.Menu MnuEdiHdr 
         Caption         =   "E&DI Settings"
         Enabled         =   0   'False
         Visible         =   0   'False
      End
      Begin VB.Menu MnuUtilStckTake 
         Caption         =   "&Stock Take Utility"
         Enabled         =   0   'False
         Visible         =   0   'False
      End
      Begin VB.Menu MnuWSLayouts 
         Caption         =   "Edit &Printer Layouts"
         Enabled         =   0   'False
         Begin VB.Menu MnuOrdLayoutTop 
            Caption         =   "&Orders"
            Begin VB.Menu MnuOrdLayout 
               Caption         =   "&Top"
               Index           =   0
            End
            Begin VB.Menu MnuOrdLayout 
               Caption         =   "Data &Heading"
               Index           =   1
            End
            Begin VB.Menu MnuOrdLayout 
               Caption         =   "&Data"
               Index           =   2
            End
            Begin VB.Menu MnuOrdLayout 
               Caption         =   "&Extra Information"
               Index           =   3
            End
            Begin VB.Menu MnuOrdLayout 
               Caption         =   "&Total"
               Index           =   4
            End
            Begin VB.Menu MnuOrdLayout 
               Caption         =   "&Bottom"
               Index           =   5
            End
         End
         Begin VB.Menu mnuPSOOrderEditors 
            Caption         =   "PSO Orders"
            Begin VB.Menu MnuPSOOrdLayout 
               Caption         =   "Top"
               Index           =   1
            End
            Begin VB.Menu MnuPSOOrdLayout 
               Caption         =   "Data &Heading"
               Index           =   2
            End
            Begin VB.Menu MnuPSOOrdLayout 
               Caption         =   "&Data"
               Index           =   3
            End
            Begin VB.Menu MnuPSOOrdLayout 
               Caption         =   "&Extra Information"
               Index           =   4
            End
            Begin VB.Menu MnuPSOOrdLayout 
               Caption         =   "&Total"
               Index           =   5
            End
            Begin VB.Menu MnuPSOOrdLayout 
               Caption         =   "&Bottom"
               Index           =   6
            End
         End
         Begin VB.Menu MnuFaxLayoutTop 
            Caption         =   "&Faxed Orders"
            Begin VB.Menu MnuFaxLayout 
               Caption         =   "Top"
               Index           =   0
            End
            Begin VB.Menu MnuFaxLayout 
               Caption         =   "Data &Heading"
               Index           =   1
            End
            Begin VB.Menu MnuFaxLayout 
               Caption         =   "&Data"
               Index           =   2
            End
            Begin VB.Menu MnuFaxLayout 
               Caption         =   "&Extra Information"
               Index           =   3
            End
            Begin VB.Menu MnuFaxLayout 
               Caption         =   "&Total"
               Index           =   4
            End
            Begin VB.Menu MnuFaxLayout 
               Caption         =   "&Bottom"
               Index           =   5
            End
         End
         Begin VB.Menu Line20 
            Caption         =   "-"
         End
         Begin VB.Menu MnuLayoutTop 
            Caption         =   "&Picking Tickets / Delivery Notes"
            Begin VB.Menu MnuLayout 
               Caption         =   "&Top"
               Index           =   0
            End
            Begin VB.Menu MnuLayout 
               Caption         =   "Data &Heading (Picking Tickets)"
               Index           =   1
            End
            Begin VB.Menu MnuLayout 
               Caption         =   "Data &Heading (Delivery Notes)"
               Index           =   2
            End
            Begin VB.Menu MnuLayout 
               Caption         =   "Data &Heading (Credit Notes)"
               Index           =   3
            End
            Begin VB.Menu MnuLayout 
               Caption         =   "&Data (Picking Tickets)"
               Index           =   4
            End
            Begin VB.Menu MnuLayout 
               Caption         =   "&Data (Delivery Notes)"
               Index           =   5
            End
            Begin VB.Menu MnuLayout 
               Caption         =   "&Data (Credit Notes)"
               Index           =   6
            End
            Begin VB.Menu MnuLayout 
               Caption         =   "&Total"
               Index           =   7
            End
            Begin VB.Menu MnuLayout 
               Caption         =   "&Bottom"
               Index           =   8
            End
         End
         Begin VB.Menu MnuDLOReqTop 
            Caption         =   "D&LO Picking Tickets"
            Begin VB.Menu MnuDLOLayout 
               Caption         =   "DLO Picking Ticket &Top"
               Index           =   0
            End
            Begin VB.Menu MnuDLOLayout 
               Caption         =   "DLO Picking Ticket &Bottom"
               Index           =   1
            End
         End
         Begin VB.Menu line21 
            Caption         =   "-"
         End
         Begin VB.Menu MnuCSLayoutTop 
            Caption         =   "Confirmation &Slips"
            Begin VB.Menu MnuCSLayout 
               Caption         =   "&Top"
               Index           =   0
            End
            Begin VB.Menu MnuCSLayout 
               Caption         =   "&Data"
               Index           =   1
            End
         End
         Begin VB.Menu line25 
            Caption         =   "-"
         End
         Begin VB.Menu mnuFinDNoteLayout 
            Caption         =   "&Dispute Notes"
         End
         Begin VB.Menu MnuFinLayoutTop 
            Caption         =   "&Coding Slips"
         End
         Begin VB.Menu MnuLayoutTFRpt 
            Caption         =   "To &Follows Report"
         End
         Begin VB.Menu mnuShelfStockReport 
            Caption         =   "Shelf Stocking Report"
         End
         Begin VB.Menu line22 
            Caption         =   "-"
         End
         Begin VB.Menu MnuUtilLayout 
            Caption         =   "&Utility Reports Layout"
            Index           =   0
         End
         Begin VB.Menu MnuUtilLayout 
            Caption         =   "&GRN Layout"
            Index           =   1
            Visible         =   0   'False
         End
         Begin VB.Menu line29 
            Caption         =   "-"
         End
         Begin VB.Menu MnuWSLayout 
            Caption         =   "S&tock On Wards Layout"
            Index           =   1
            Visible         =   0   'False
         End
         Begin VB.Menu MnuWSLayout 
            Caption         =   "Search and &Replace Layout"
            Index           =   2
            Visible         =   0   'False
         End
         Begin VB.Menu MnuWSLayout 
            Caption         =   "DCT &Exception Layout"
            Index           =   3
         End
         Begin VB.Menu MnuWSLayout 
            Caption         =   "Search and &Delete Layout"
            Index           =   4
            Visible         =   0   'False
         End
         Begin VB.Menu linesep30 
            Caption         =   "-"
         End
         Begin VB.Menu MnuHUBLayout 
            Caption         =   "Pharmacy HUB Exceptions Report"
         End
      End
   End
   Begin VB.Menu MnuHlp 
      Caption         =   "&Help"
      Begin VB.Menu MnuHelp 
         Caption         =   "&Contents                             F1"
         Index           =   0
      End
      Begin VB.Menu MnuHelp 
         Caption         =   "&Search for Help on ..."
         Index           =   1
      End
      Begin VB.Menu MnuHelp 
         Caption         =   "&How to use Help"
         Index           =   2
      End
      Begin VB.Menu MnuHelp 
         Caption         =   "-"
         Index           =   3
      End
      Begin VB.Menu MnuHelp 
         Caption         =   "&About"
         Index           =   4
      End
   End
   Begin VB.Menu mnuWSOptions 
      Caption         =   "Options"
      Enabled         =   0   'False
      Visible         =   0   'False
      Begin VB.Menu MnuWSOHelp 
         Caption         =   "&Help"
      End
      Begin VB.Menu line9 
         Caption         =   "-"
      End
      Begin VB.Menu MnuWSOFind 
         Caption         =   "&Find"
         Shortcut        =   {F3}
      End
      Begin VB.Menu MnuWSONext 
         Caption         =   "Find &Next"
         Shortcut        =   +{F3}
      End
      Begin VB.Menu MnuWSOEnquiry 
         Caption         =   "Drug &Enquiry"
      End
      Begin VB.Menu Line10 
         Caption         =   "-"
      End
      Begin VB.Menu MnuWSOInsert 
         Caption         =   "Insert &Line"
         Shortcut        =   {F5}
      End
      Begin VB.Menu MnuWSODelete 
         Caption         =   "&Delete Line"
         Shortcut        =   {F6}
      End
      Begin VB.Menu line11 
         Caption         =   "-"
      End
      Begin VB.Menu MnuWSOBlockDel 
         Caption         =   "Delete Marked &Block"
         Shortcut        =   +{F6}
      End
      Begin VB.Menu MnuWSOSort 
         Caption         =   "&Sort Marked Block"
         Begin VB.Menu MnuSort 
            Caption         =   "Sort by &Title"
            Index           =   0
         End
         Begin VB.Menu MnuSort 
            Caption         =   "Sort by &Issue Type"
            Enabled         =   0   'False
            Index           =   1
            Visible         =   0   'False
         End
         Begin VB.Menu MnuSort 
            Caption         =   "Sort by &NSVCode"
            Index           =   2
         End
         Begin VB.Menu MnuSort 
            Caption         =   "-"
            Index           =   3
         End
         Begin VB.Menu MnuSort 
            Caption         =   "List &Ascending"
            Checked         =   -1  'True
            Index           =   4
         End
      End
      Begin VB.Menu line27 
         Caption         =   "-"
         Index           =   0
      End
      Begin VB.Menu MnuWSOBIssue 
         Caption         =   "Barcode Issue"
         Shortcut        =   +{F8}
      End
      Begin VB.Menu MnuWSOBReturn 
         Caption         =   "Barcode Return"
         Shortcut        =   +{F9}
      End
      Begin VB.Menu line17 
         Caption         =   "-"
      End
      Begin VB.Menu MnuWSOCopy 
         Caption         =   "Copy to &Clipboard"
      End
      Begin VB.Menu MnuWSOCut 
         Caption         =   "C&ut to Clipboard"
      End
      Begin VB.Menu MnuWSOBlkInsert 
         Caption         =   "&Insert from Clipboard"
      End
      Begin VB.Menu line12 
         Caption         =   "-"
      End
      Begin VB.Menu MnuWSOChange 
         Caption         =   "Change &Ward Code"
      End
      Begin VB.Menu MnuWSOSaveAs 
         Caption         =   "Save as &New Ward"
         Enabled         =   0   'False
      End
      Begin VB.Menu line15 
         Caption         =   "-"
      End
      Begin VB.Menu MnuWSOPrint 
         Caption         =   "&Print Marked Text"
      End
      Begin VB.Menu line13 
         Caption         =   "-"
      End
      Begin VB.Menu MnuWSOInfo 
         Caption         =   "Ward &Information"
      End
      Begin VB.Menu line28 
         Caption         =   "-"
      End
      Begin VB.Menu MnuExportTopup 
         Caption         =   "Export Topup Information"
         Begin VB.Menu MnuWriteTopup 
            Caption         =   "&Psion 3A"
            Index           =   0
         End
         Begin VB.Menu MnuWriteTopup 
            Caption         =   "Windows &CE"
            Index           =   1
         End
      End
      Begin VB.Menu MnuImportTopup 
         Caption         =   "Import Topup Information"
         Begin VB.Menu MnuReadTopup 
            Caption         =   "&Psion 3A"
            Index           =   0
         End
         Begin VB.Menu MnuReadTopup 
            Caption         =   "Windows &CE"
            Index           =   1
         End
      End
   End
End
Attribute VB_Name = "MainScreen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'28Aug97 CKJ     Do not blank the screen if help is requested
'                Replaced the about box with standard call as printscreen is needed
'                Added App.helpfile="stores.hlp"
'17Oct97 EAC     Added Adhoc Issue menu option to Ward Stock menu
'28Oct97 EAC     lvwMainScreen_DblClick: Add code to treat double click same as pressing enter key
'                in Ordering side of software apart from in Reconciliation where
'                double click highlights the lines to be reconciled
'                TxtInput_KeyDown,TxtInput_KeyUp: Eat DELETE, INSERT,HOME and END key presses to
'                override Truegrid handling of them.
'03Dec97 EAC     Added Adhoc return to Ward Stock menu
'                Added Login to Program menu
'                Modified Program menu code to run from index property in the menu
'10Dec97 EAC     Added "Calculate Outstanding Quantities" to utilities menu
'                added call to FindOutstanding from menu
'14Jan98 EAC     use Shift-F4 menu short cut for a general drug enquiry
'14Jan98 EAC     Showing information menus should not affect what is already on screen
'29Jan98 EAC     TxtInput_KeyPress: Having set order number in the program update LastRowIndex& to match
'                item position in new screen
'12Feb98 EAC     TxtInput_KeyPress: Added check to prevent update when item has been added for different supplier and no items on this suppliers screen
'17Feb98 EAC     Form property KeyPreview set to true
'                Form_keyUP: debugging menu added on Alt-F12 keypress
'05Mar98 CFY     lvwMainScreen_MouseUp: Added extra parameter to shell sort.
'26Mar98 CFY/EAC lvwMainScreen_MouseUp: Removed the loop which occurs prior to the shellsort as it sometimes caused an
'                infinite loop to occur. Replaced with code which stops this occuring but now
'                only sorts a screen at a time.
'03May98 CKJ Y2K. Multiple mods, all with this date/id/Y2k
'18May98 EAC     lvwMainScreen_KeyUp: stop Subscript out of bounds Error
'12Jun98 EAC     lvwMainScreen_KeyUp: Barcode issues/returns to be corrected asap, in meantime prevent use
'22Jun98 EAC/CFY MnuWriteTopup_Click: distinguish between Psion and CE when exporting
'27Jul98 TH      MnuWSOMove_Click:Pass rowindex rather than 0 to maintain integrity of indexes
'06Aug98 SF      MnuFinLayoutTop_Click: now has code for editing c/slip rtf.  Replaced MnuFinLayout().
'04Sep98 TH      Form_Query Unload: Added code to save data from truegrid on exit
'30Oct98 EAC     lvwMainScreen_MarkChange: ensure that marque is moved to selected line
'12Nov98 TH      lvwMainScreen_DblClick: Code to select individual items to order direct from amend screen
'12Nov98 TH      TxtInput_KeyUp: F7 on amend screen set to selective ordering
'19Nov98 TH      TxtInput_KeyUp: F8 on amend screen set to display total cost of order
'12Nov98 TH      lvwMainScreen_Markchange in amend screen as in reconciliation
'12Nov98 TH      lvwMainScreen_MouseUp: Right click in Amend screen to order selected items
'12Nov98 TH      lvwMainScreen_QueryMark: Select items in amend orders screen
'04Dec98 TH      TxtInput_KeyUp: prevent OInfoStore array set to 0
'08Dec98 TH      TxtInput_KeyUp: Remove marquee after selective order
'05jan99 CKJ     Added Toolbar support
'                Also set mid grey as the background colour
'                Key for modem orders changed to D from M as this clashed with A&mend
'11Jan99 TH      Added Report control for printing wardstocklists
'21Jan99 TH      TxtInput_KeyUp: F8 on amend screen now includes supplier based discount details
'21Jan99 TH      Removed Report control - WSlists now use control off stockcontrol form
'22Jan99 TH      TxtInput_KeyUp: Corrected Logic on F3 to prevent OInfoStore array set to 0
'28Jan99 TH      TxtInput_KeyUp: code for free receive on F8 in receive screen
'28Jan99 TH      TxtInput_KeyUp: code for manual entry of price on shift& F8 in amend screen
'29Jan99 TH      TxtInput_KeyUp: Account for manual prices in order cost key
'11Feb99 TH      TxtInput_KeyUp: Msgbox reminder that F6 cannot be used in credit confirmation screen
'11Feb99 TH      TxtInput_GotFocus: Added TxtInput update for credit confirmation screen
'19Feb99 TH      TxtInput_KeyUp: Check to stop -ve prices in manual entry
'23Feb99 TH      TxtInput_KeyUp: (F7 - Receive) Do not reinitialise screen if flagged from checkexitval
'23Feb99 TH      TxtInput_KeyUp: Changes to manual price entry to differentiate free items and force size of txtbox
'25Feb99 TH      MnuUtilTidy_Click: Now calls Wdelord to tidy and reorder indexes
'15Apr99 CFY     Form_Unload: Removed End statement as should not be necessary if everything has been
'                 'cleaned up' correctly.
'15Apr99 CFY     Form_QueryUnload: Additional code added to correctly unload loaded forms the clsoe and
'                 release database objects.
'13May99 TH      lvwMainScreen_KeyUp: Now passes correct position to blockmove on F7 in wstock thus should retain correct screenposns
'24May99 TH      MnuUtilTidy_Click: Replaced Drive designation
'25May99 TH      MnuUtilTidy_Click: Moved wdelord path to ascribe folder (AppPath)
'14Jun99 SF      removed edit coding slips layout sub menu as not needed and was causing problems when editing
'26Jul99 TH      TxtInput_KeyUp: Added Regional price unit (pence cents) as info in enter manual price message.
'25Aug99 TH      Form_QueryUnload: Changed index range of forms to be unloaded
'26Aug99 TH      Form_Unload: Reinstated End
'30Sep99 AE      Removed Menu Item MnuSort(1)  (Sort by issue type). The code behind this merely sorted by screen
'                position, ie effectively did nothing.  Issue type is not stored in the wslist.mdb, so it is difficult
'                to see what its purpose was.
'26Oct99 AE      TxtInput_KeyUp:Only allow receive free using F8 if not using entercostonrecipt
'21feb00 TH/MMA/VS Txtinput_keyup: moved from right click to give keyboard option
'30Mar00 CFY MnuPreOrderPrint_Click: Written. Prompts user for a supplier followed by the report sort order.
'30Mar00 CFY MnuGoodsRcd_Click: Written. Prompts user for sort order before calling report.
'18Apr00 CFY MnuGoodsRcd_Click: Now prompts for an order number to allow additional filtering.
'23Jun00 AE  MnuGoodsRcvd_Click: Now uses correct ini file entry (paste error)
'22Nov00 EAC/CY Handle in-dispute items
'06Apr01 CFY MnuToFollowsPrint_Click: Added
'18Apr01 CFY MnuToFollowsPrint_Click: Now only calls ToFollowsPrint once!!!
'        CFY Added MnuLayoutTFRpt_Click: Added
'25Apr01 AW  Corrected spelling of TecSol on EDI and Utilities-EDI menu option
'29May01 TH  lvwMainScreen_KeyUp: Close off F6 option (delete) for wslist lvls < 2 (#52361)
'29May01 TH  MnuInfo_Click: Added parameter search parameter to logview call    (#52397)
'10Jan02 TH  TxtInput_KeyUp: Added to allow tradename toggle for Confirmation notes (#49091)
'11Jan02 TH  MnuWSMissing_Click: Added new parameter to Sarall call (#52902)
'11Jan02 TH  TxtInput_KeyUp: Added ini switch to allow manual entry for Electronic Orders (#54468) - For Fauldings at FMC
'14Jan02 TH  TxtInput_KeyUp: Removed line setting osite$ to sup.code as sup structure might be incorrect at this stage (#58045)
'16Jan02 TH  TxtInput_KeyUp: Added screen refresh to allow for possible change of supplier on line edit (#51913)
'16Jan02 TH  MnuModemTrans_Click: Added time ordered for the orderlog (#53214)
'16Jan02 TH  MnuEDI_Click: Call to new sub for EDI settings (%EDI%)
'16Jan02 TH  MnuEDIInvoicing_Click, MnuEDIOrdering, MnuEDIReply, MnuEDISettings: Added, various changes to menus to reflect new functionality
'16Jan02 TH  MnuMediate_Click: New calls to wrapper subs (to add the supplier code to the old calls)
'23Jan02 TH  lvwMainScreen_KeyUp: Close off F6 option (delete) for wslist lvls 5 (#52055)
'27Feb02 TH  MnuWSOBlockDel_Click:,MnuWSODelete_Click:,lvwMainScreen_KeyUp: Added new parameter to deletelines call (enh1463)
'27Feb02 TH  MnuWSOCut_Click Added (enh1463)
'07Mar02 TH  TxtInput_KeyUp: Added call to getdrugsup in price check to handle profiles (#59320)
'08Mar02 TH  MnuToFollowsPrint_Click: Pick up cancel correctly (#58511)
'08Mar02 TH  TxtInput_KeyUp: Various changes involving using a new wrapper to call frmenhtxtwin when amending price (#56352,54364)
'25Mar02 TH  TxtInput_KeyUp: Change to #59320 after testing as ord.supcode not yet filled, now uses osite$ if appropriate.
'16Apr02 TH  MnuWSDelete_Click: Written to allow new search and delete across wards enhancement (enh1477)
'16Apr02 TH  MnuWSLayout()_Click: Added Edit option for new search and delete rtf (enh1477)
'24Apr02 ATW Added extra To-Follow report option where reports are set up (#55445)
'22Apr02 SF  mnuStockList_Click: added to call the shelf stocking report (enh#1555)
'            TxtInput_KeyUp: amend orders ^F3 Minimum Order Value (enh#1555)
'25Apr02 TH/SF MnuWSDelete_Click: Second get of drug is superfluous
'17May02 SF  added mnuEdit_Click: for clipboard operations
'31May02 TH  MnuWSDelete_Click: Reference nsvcode directly for askwin
'29Jul02 TH  MnuWSDelete_Click: Use NSVcode only (not searchstring) in sarall delete call
'05Sep02 SF  MnuPreOrderPrint_Click: mods to allow cancelling out correctly of pre-order printing (event #61535)
'31Mar04 CKJ {SP1}
'06Apr04 TH  lvwMainScreen_Update: Added mod to allow Printing prepaks from passwrd lvl 5 (#63724)
'02Oct06 TH  lvwMainScreen_dblClick: If blank screen no functionality required regardless of mode (SC-06-0768)
'07Jan10 CKJ corrected use of OTblMaxCols and the associated lines() array
'            MnuInfoTop_Click: Option to show robot messages is greyed unless there's a form to display
'15Jan10 XN  Added menuu item MnuRobotLoading and event handler MnuRobotLoading_Click (F0042698)
'23Jun08 XN  F0033906 Now used the ICW desktop F4 screens.
'11Feb10 TH  TxtInput_KeyUp: (F0077298) Removed F2 set qty functionality from supplementary order screen.
'11Feb10 TH  lvwMainScreen_KeyUp: Disable delete if there are no rows (F0077289)
'08Apr10 XN  F0055221 - proper column sorting in receive good screen
'08Jun10 XN  picToolBar_MouseDown Menu bar colour now set via config setting (so site dependant) (F0085853)
'29Jun10 XN  F0055221 - lblHeading_Click fixed problem getting last column type from database, for clickable list headers
'11Aug10 CKJ Added IPLinkShutdown to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)
'17sep10 TH  TxtInput_KeyPress: Added param to addlinetodisplay and RefreshTblData calls (F0096592)
'17sep10 TH  lvwMainScreen_KeyUp: Added param to addlinetodisplay and RefreshTblData calls (F0096592)
'17sep10 TH  TxtInput_KeyUp: Added param to addlinetodisplay and RefreshTblData calls (F0096592)
'01Jun11 CKJ Noted that Form_Activate does not fire until the form has already been in use for a while (esp in Ward Stock) causing
'              WSlist grid to be displayed too high up the screen (sometimes above it), so moved PicLayout resize to Form_Resize
'            Removed 122 references to MainScreen. as it must not reference it's own design-time object directly
'            Changed 10 references of MainScreen.MousePointer to Screen.MousePointer
'            Changed 3 references to MainScreen to Me
'            Removed existing commented code where this pertained to previous generation compiler.
'            Removed unused Private Type COLORSCHEME
'            Removed unused m_intlvwMainScreenDirection
'            Set DefInt to DefBool which uncovered missing type declarations in mnuHelp_Click, lvwMainScreen_KeyDown (IsMarked)
'            Removed deprecated menu option MnuWSOMove, associated events, lvwMainScreen_Append & BlockMove
'            Removed DispPgNo. See comments in StoreAsc.bas for details
'02Jun11 CKJ Removed all reference to OMarked(), the array which held whether each line should be selected
'            - this was clashing with inherent listview behaviour, and losing. Now uses listview exclusively
'            Removed reference to lvwMainScreen.ListItems().Checked since no check mark is ever shown & propery is never read
'            m_blnlvwMainctrlOn removed. originally handled highlighting with Ctrl-CsrUp/Dn
'            m_intlvwMainScreenShiftBase removed. Shift-highlight works without this
'            Ward Stock popup menu: changed '&Find /top /bottom' to '&Find' as the top & bottom facility went out with DOS
'            lvwMainScreen_Fetch, lvwMainScreen_FetchAttributes, lvwMainScreen_GotFocus, lvwMainScreen_QueryMark lvwMainScreen_Update: deleted. TrueGrid remnants
'            MnuOrdersFreeAmend_Click: deleted. Not attached to a menu & had no active code
'            MnuFinLayout_Click: deleted. Superceded & not callable
'            blnRetainPosition: removed. Although it controls code, it is always False
'            BarEditMode, PreventAppend : Removed. Although it set, they are never used by executable code
'06Jul11 CKJ MnuModemGrn_Click, MnuModemReceive_Click, MnuModemTrans_Click: Obsolete, deleted as mnuFTU already set not visible
'            corresponding menu elements deleted, including mnuFTU
'11Jul11 CKJ lvwMainScreen_MarkChange: deleted - used to be a TrueGrid event but not supported under listview
'22Jul11 XN  lblHeading_Click: Added m_SortOrderAsc to help maintain grid sort order on refresh (F0102524), (F0102526), (F0102527)
'04Jul12 CKJ Added common dialog for colour picker
'26Sep12 TH  ProcessDrugLine: Added fencepost to DLO check to stop when no line selected (i.e. new)(TFS 45129)
'20Aug12 TH  MnuPSOOrdLayout_Click: Written . Added new PSO rtf Editor menus (TFS 40791)
'22Aug12 TH  MnuPSOAuth: Added (TFS 41431)
'03Sep12 TH (TFS 41784)
'10Oct12 TH  lvwMainScreen_KeyUp: Added check to diasble shift-F3 for PSO TFS 41573
'14Nov12 TH  Reconfigured menu options to set PSO as same layer as normal order functions (TFS 48799)
'14Nov13 TH  lvwMainScreen_KeyUp: Moved process drug line to allow auto selection of new line (TFS 78314)
'15Oct14 XN  lblHeading_Click: Allowed column header sorting to be case sensitive (TFS 87588)
'15Sep15 TH  ProcessDrugLine: Ensure PSO partial invoices (per order) are handled correctly (TFS 127187)
'08Feb16 TH  Added MnuHUBLayout for hub exception report editor based on tofollow rtf edit option (TFS 138647)
'06Dec16 TH  Replaced RTF Handling from multiple Editor menus(TFS 157969)
'10Jan16 TH  Refactored RTF Handling from multiple Editor menus(TFS 157969)
'01Feb17 TH  MnuUtilLayout_Click: Corrected odd typo for util report (Hosted) (TFS 175454)
'01Feb17 TH  MnuFaxLayout_Click: Corrected file name (Hosted) (TFS 175454)
'09Feb17 TH  Removed menu options for redundant Search and replace/delete, stock on wards reports. (TFS 176078)
'12Feb17 TH  Removed menu option for redundant GRN report. (TFS 176497)
'09Mar17 TH  MnuHUBLayout_Click: Fixed rtf reference (TFS 179306)

'TO DO
'reviewed  replace rowline$, "||", "| |", 0 - all unnecessary when followed by deflines "|(*)"
'reviewed  deflines OInfoStore(lvwMainScreen.SelectedItem.Index), lines$(), "|(*)", 1, 0      for (*) but not yet for selecteditem.index
'reviewed MainScreen.PicInfo1.Visible - now uses blankorderinfoscreens exclusively
'why     '28Oct97 EAC Added code to eat INSERT,DELETE,HOME and END key presses
'usable? Private Sub lvwMainScreen_ColumnClick - No, removed
'review  ONumToDisplay,  - when set, always correct? - master or slave to display size?
'review  oinfomaxlen
'review  OMarked() - any equivalent procedures needed instead?
'review ClearPrintedOrders - may duplicate code nearby, may be needed in places which reset the order arrays
'review redim OInfoStore and redim preserve OInfoStore
'need to remove swathes of code from keyup/down on textbox & listview
'sup.ptn can be ascii 0 (F9 on AddLineToDisplaySQL in printorder)
'review "ScreenViewHeight"
'grid: money format, right justification, add nsv to receive, column headers
'heading handling is not ideal - offset from grid. Why use label AND listview headings?
'blnWardStock v text box visible
'consider keyboard highlighting shortcuts

DefBool A-Z
Option Explicit

Dim ord As orderstruct
'Dim BarEditMode As Integer                  '02Jun11 CKJ Removed. Although it is set, it's never used by executable code
'Dim PreventAppend As Integer                '02Jun11 CKJ Removed. Although it is set, it's never used by executable code
Dim findstring As String                     'used in "find next"
'Dim m_intlvwMainScreenShiftBase As Integer  'SQL flags to control selection on grid
'Dim m_blnlvwMainctrlOn As Boolean
Dim m_blnTxtInputRetainText As Boolean
'Dim blnRetainPosition As Boolean            '02Jun11 CKJ Removed. Although it controls code, it is always False
Public m_LastColumnSorted As Integer            '27Jun11 CKJ avoids static in form
Public m_SortOrderAsc As Boolean             '21Jul11 XN  Current sort direction (F0102524), (F0102526), (F0102527)
'

Private Sub CmdAutoOrder_Click()
    CmdAutoOrder.Tag = "Cancelled"
End Sub

Private Sub cmdToolbar_Click(Index As Integer)

   DoToolBarButton (cmdToolbar(Index).Tag)  '05jan99 CKJ

End Sub

Private Sub DebugInfoTimer_Timer()
'27Jun11 CKJ Debug option added - just set DebugInfoTimer.Enabled

Dim iLoop As Integer    'don't need very long strings
Dim strMsg As String
Dim iItems As Integer
Dim strSel As String

   On Error GoTo DebugInfoTimer_Err
   With lvwMainScreen
      iItems = .ListItems.count
      If iItems > 256 Then iItems = 256      'max length of caption
      strMsg = Space$(iItems)
      For iLoop = 1 To iItems
         'Mid$(strMsg, iLoop, 1) = Iff(.ListItems.Item(iLoop).Selected, "|", ".")
         Mid$(strMsg, iLoop, 1) = Format$(Abs(.ListItems.Item(iLoop).Selected))
      Next
      strSel = "Null Null"
      If Not (.SelectedItem Is Nothing) Then
         strSel = Format$(.SelectedItem.Index) & " " & Iff(.ListItems(.SelectedItem.Index).Selected, "Y", "N")
      End If
      Me.Caption = Format$(.ListItems.count) & " " & strSel & " " & strMsg
   End With
   On Error GoTo 0
    
DebugInfoTimer_Exit:
Exit Sub

DebugInfoTimer_Err:
Resume DebugInfoTimer_Exit
End Sub

Private Sub Form_Activate()

   Me.WindowState = 2
   
End Sub

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)
'17Feb98 EAC debugging menu added on Alt-F12 keypress
'27Jun11 CKJ Used existing hook for listview selection debug

   Select Case KeyCode
      Case KEY_F12
         If Shift = ALT_MASK Then   'Alt key pressed
            'popmessagecr "", "Debug options not available in this release"
            ''DisplayDebugMenu
            DebugInfoTimer.Enabled = Not DebugInfoTimer.Enabled
            popmessagecr "#", "Debug information turned " & Iff(DebugInfoTimer.Enabled, "ON", "OFF")
         End If
   End Select

End Sub

Private Sub Form_Load()

   SetChrome Me
''''SendMessage Me.LblHelpPrompt.hWnd, SB_SETBKCOLOR, 0, ByVal &HFFE3D6 ''&HFF8080

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   Form_Unload (0)
   
End Sub

Private Sub Form_Resize()

   Me.WindowState = 2
   
   '01Jun11 CKJ Moved block from Form_Activate
   PicLayout.Left = 0   'Me.Left       '01Jun11 CKJ changed to zero (since Left = -45)
   PicLayout.Width = Me.ScaleWidth
   PicLayout.Top = Me.ScaleTop
   PicLayout.Height = Me.ScaleHeight - LblHelpPrompt.Height

End Sub

Private Sub Form_Unload(Cancel As Integer)
'15Apr99 CFY Removed End statement as should not be necessary if everything has been
'            'cleaned up' correctly.
'26Aug99 TH Reinstated End - Some object open somewhere is still causing problems

   IPLinkShutdown                       '11Aug10 CKJ Added to ensure robot link (if any) is cleared down gracefully (P0158 F0088410)

   Me.Hide

   If OCXlaunch() Then                  '02Nov03 CKJ
         SignalASCDone "X", 0, True     '   "
      End If                            '   "
   gTransportConnectionClose            '15Aug12 CKJ
   Set gTransport = Nothing
   Close
   StoresEnd               '26Aug99 TH Reinstated

End Sub

Private Sub lblHeading_Click(Index As Integer)
' XN 08Apr10 F0055221 - proper column sorting in receive good screen
' XN 22Jul11 Added m_SortOrderAsc to help maintain grid sort order on refresh (F0102524), (F0102526), (F0102527)
' XN 15Oct14 87588 Allowed column header sorting to be case sensitive

Dim lastordernum$
Dim lines$()
'Static intLastCol As Integer     '27Jun11 CKJ static in a Form is bad practice. moved to m_LastColumnSorted as integer
Dim OInfoStorecopy$()
Dim intCount As Integer
Dim lngOrderID As Long
Dim ColumnType As String

  If Not WardStockLoaded Then
      Screen.MousePointer = HOURGLASS
      If ONumToDisplay > 0 Then                '            Replaced with this block
         ' XN 08Apr10 F0055221 - proper column sorting in receive goods screen
         ColumnType = "text"
         If Index <= UBound(OColumnType) Then
            ColumnType = OColumnType(Index)
         End If
      
         'shellsort OInfoStore(), (ONumToDisplay), (Index), "|", ColumnType   15Oct14 XN 87588 Allowed column header sorting to be case sensitive
         shellsort OInfoStore(), (ONumToDisplay), (Index), "|", ColumnType, TrueFalse(TxtD(dispdata$ & "\winord.ini", "", "Y", "CaseSensitiveHeaderSort", 0))
         
         ' 22Jul11 XN Added m_SortOrderAsc to help maintain grid sort order on refresh (F0102524), (F0102526), (F0102527)
         If m_LastColumnSorted = Index And m_SortOrderAsc Then
                m_SortOrderAsc = Not m_SortOrderAsc
                           ReverseStringArray OInfoStore
         Else
                m_SortOrderAsc = True
            m_LastColumnSorted = Index
         End If
         ' End of 22Jul11 XN Added m_SortOrderAsc to help maintain grid sort order on refresh (F0102524), (F0102526), (F0102527)
         
         RefreshLVWMainScreen False, False
         MainScreenSetTextAndPanels Edittype
      End If                                                                                                                                     '
      Screen.MousePointer = STDCURSOR
   End If
   
End Sub


'27Jun11 CKJ Procedure removed. Column headers not visible, uses ibiHeading instead
'Private Sub lvwMainScreen_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)
'Dim lastordernum$
'Dim lines$()
'Static intLastCol As Integer
'Dim OInfoStorecopy$()
'Dim intCount As Integer
'Dim lngOrderID As Long
'
'   'If Y < 375 And Not WardStockLoaded Then  '05Mar98 ASC/EAC
'   If Not WardStockLoaded Then
'         Screen.MousePointer = HOURGLASS
'
'         '26Mar98 CFY/EAC Removed following block of code as it sometimes causes an infinite loop
'         '                to occur.
'         'Clearprintedorders                                                                                                                           '26Mar98 CFY Removed block as it
'        'Do                                                                                                                                           '            sometimes caused an
'         '   printorder 0, 0, 0, 0, OASCcode$(), ORecNo&()                                                                                             '            infinite loop to
'         'Loop Until IndexStartPos& = 0                                                                                                                '            occur.
'         'If ONumtoDisplay > 0 Then shellsort OInfoStore(), (ONumtoDisplay), (lvwMainScreen.ColumnIndex) * -1    '05Mar98 CFY Replaced withn line below   '
'
'         '26Mar98 CFY/EAC Replaced above block with block below
'         If ONumToDisplay > 0 Then
'            shellsort OInfoStore(), (ONumToDisplay), (ColumnHeader.Index), "|"
'            If intLastCol = ColumnHeader.Index Then
'               'If InStr(strOrder, "DES") And column = Int(Val(strOrder)) Then
'               ReDim OInfoStorecopy$(UBound(OInfoStore))
'               For intCount = 1 To UBound(OInfoStore)
'                  OInfoStorecopy$(intCount) = OInfoStore(UBound(OInfoStore) - (intCount - 1))
'               Next
'               For intCount = 1 To UBound(OInfoStore)
'               OInfoStore(intCount) = OInfoStorecopy$(intCount)
'               Next
'               intLastCol = 0
'            Else
'               intLastCol = ColumnHeader.Index
'            End If '            of code.
'            RefreshlvwMainScreen False, False
'            'ReDim lines(9)                                 '07Jan10 CKJ corrected
'            ReDim lines(OTblMaxCols + 1) As String          '   "
'            deflines OInfoStore(lvwMainScreen.SelectedItem.Index), lines$(), "|(*)", 1, 0
'            TxtInput.Text = lines$(1)
'            TxtInput.SelStart = 0
'            TxtInput.SelLength = Len(TxtInput.Text)
'            ''deflines OInfoStore(lvwMainScreen.SelectedItem.Index), lines$(), "|(*)", 1, numoflines
'            lngOrderID = Val(lines$(OTblMaxCols + 1))
'            getorder ord, lngOrderID, edittype, 0
'            UpdatePanels ord, Abs(edittype) '02Dec04 TH
'
'         End If                                                                                                                                     '
'
'         Screen.MousePointer = STDCURSOR
'      End If
'
'End Sub

'Private Sub lvwMainScreen_LostFocus()
'   m_intlvwMainScreenShiftBase = 0
'End Sub

Private Sub MnuCSLayout_Click(Index As Integer)
'10Jan17 TH Refactored to use DB rtf (Hosted)

Dim RTFfilename$, Layout$, OldLayout$
Dim OK%

   Select Case Index
      Case 0:    RTFfilename$ = "\CSTop.rtf"
      Case 1:    RTFfilename$ = "\CSData.rtf"
      Case Else: popmessagecr "!Error", "MnuCSLayout_Click called with value" + Str$(Index) & Chr$(13) & "Please report this fault to EMIS Health."
   End Select

   'GetTextFile dispdata$ + RTFfilename$, Layout$, OK
   'GetRTFTextFromDB dispdata$ + RTFfilename$, Layout$, OK  '06Dec16 TH Replaced (TFS 157969)

    
   'If OK Then
   If RTFExistsInDatabase(dispdata$ & RTFfilename$) Then
       'OldLayout$ = Layout$
       'Hedit 1, Layout$
       'If OldLayout$ <> Layout$ Then PutTextFile dispdata$ + RTFfilename$, Layout$, OK
       'If Not OK Then popmessagecr "!Error", "Failed to write new layout to " & dispdata$ & RTFfilename$
       EditRTFFromDB dispdata$ & RTFfilename$  '10Jan17 TH Replaced Above(Hosted)
   Else
       'popmessagecr "!Error", "Failed to read the layout file " & dispdata$ & RTFfilename$
       popmessagecr "!Error", "Failed to read the layout '" & RTFfilename$ & "' from database"
   End If

End Sub

Private Sub MnuDLOLayout_Click(Index As Integer)
'05Jul12 TH Added (TFS 37704)
'10Jan17 TH Refactored to use DB rtf (Hosted)

Dim strRTFfilename As String

   Select Case Index
      Case 0:    strRTFfilename = "\PickTopDLO.rtf"
      Case 1:    strRTFfilename = "\PickBotDLO.rtf"
      Case Else: popmessagecr "Error", "MnuDLOLayout_Click called with value" + Str$(Index) & Chr$(13) & "Please report this fault to EMIS Health."
   End Select
      
   If RTFExistsInDatabase(dispdata$ & strRTFfilename) Then
      'Hedit 11, dispdata$ + strRTFfilename
      EditRTFFromDB dispdata$ & strRTFfilename  '10Jan17 TH Replaced Above(Hosted)
   Else
      popmessagecr "!Error", strRTFfilename & " record not found in database"
   End If
End Sub

Private Sub MnuEdi_Click(Index As Integer)

   EDISetup
   
End Sub

Private Sub MnuEDIInvoicing_Click()
     EDIInvoicing  '16Jan02 TH Added (%EDI%)
End Sub

Private Sub MnuEDIOrdering_Click()
    EDIOrder     '16Jan02 TH Added (%EDI%)
End Sub

Private Sub MnuEDIReply_Click()
   'ReadPWO True     '16Jan02 TH Added  16Jan02 Removed  (%EDI%)
End Sub

Private Sub MnuEDISettings_Click()
'16Jan02 TH Added (%EDI%)
    EDISetup
End Sub

Private Sub mnuEdit_Click(Index As Integer)
'17May02 SF added for clipboard operations

   UndoCutCopyPasteDel Index
   
End Sub

Private Sub MnuFaxLayout_Click(Index As Integer)
'10Jan17 TH Refactored to use DB rtf (Hosted)
'01Feb17 TH Corrected file name (Hosted) (TFS 175454)

Dim RTFfilename$ ', Layout$, OldLayout$
'Dim OK%

   Select Case Index
      Case 0:    RTFfilename$ = "\FaxTop.rtf"
      Case 1:    RTFfilename$ = "\FaxDescr.rtf"
      Case 2:    RTFfilename$ = "\FaxData.rtf"
      Case 3:    RTFfilename$ = "\FaxExtra.rtf"
      Case 4:    RTFfilename$ = "\FaxTotal.rtf"
      Case 5:    RTFfilename$ = "\FaxBot.rtf"
      Case Else: popmessagecr "!Error", "MnuFaxLayout_Click called with value" + Str$(Index) & Chr$(13) & "Please report this fault to EMIS Health."
      End Select

   'GetTextFile dispdata$ + RTFfilename$, Layout$, OK
   'GetRTFTextFromDB dispdata$ + RTFfilename$, Layout$, OK  '06Dec16 TH Replaced (TFS 157969)

    
   'If OK Then
   If RTFExistsInDatabase(dispdata$ & RTFfilename$) Then
      'OldLayout$ = Layout$
      'Hedit 1, Layout$
      'If OldLayout$ <> Layout$ Then PutTextFile dispdata$ + RTFfilename$, Layout$, OK
      'If Not OK Then popmessagecr "!Error", "Failed to write new layout to " & dispdata$ & RTFfilename$
      'EditRTFFromDB dispdata$ & "\dnotetop.rtf"  '10Jan17 TH Replaced Above(Hosted)
      EditRTFFromDB dispdata$ & RTFfilename$ '01Feb17 TH Replaced Above(Hosted) (TFS 175454)
   Else
      'popmessagecr "!Error", "Failed to read the layout file " & dispdata$ & RTFfilename$
      popmessagecr "!Error", "Failed to read the layout rtf '" & RTFfilename$ & "' from database"
   End If

End Sub

Private Sub MnuFin_Click()

   WardStockLoaded = False
   ChangeTable "Blank", False '14Aug12 TH Added Param

End Sub

Private Sub MnuFinAdj_Click()

   FINANASC "5", False

End Sub

Private Sub MnuFinAP_Click()

   'finanasc "2"
   popmessagecr "General Ledger Link", "Not implemented yet."

End Sub

Private Sub MnuFinConfirm_Click()

   FINANASC "3", False
End Sub

Private Sub MnuFinDirect_Click()

   FINANASC "6", False

End Sub

Private Sub MnuFinDispNotes_Click()
'22Nov00 EAC/CY Handle in-dispute items

   PrintDisputeNotes

End Sub

Private Sub mnuFinDNoteLayout_Click()
'22Nov00 EAC/CY Handle in-dispute items
'10Jan17 TH Refactored to use DB rtf (Hosted)


   'If fileexists(dispdata$ & "\dnotetop.rtf") Then
   If RTFExistsInDatabase(dispdata$ & "\csliptop.rtf") Then '10Jan17 TH replaced above (Hosted)
      'Hedit 11, dispdata$ & "\dnotetop.rtf"
      EditRTFFromDB dispdata$ & "\dnotetop.rtf"  '10Jan17 TH Replaced Above(Hosted)
   Else
      'popmessagecr "!Error", "File " & dispdata$ & "\DNOTETOP.RTF not found"
      popmessagecr "!Error", "'DNOTETOP' rtf record not found in database"
   End If

End Sub

Private Sub MnuFinLayoutTop_Click()
'06Aug98 SF replaced MnuFinLayout(), as only one rtf is now used do not need selection
'10Jan17 TH Refactored to use DB rtf (Hosted)

   'If fileexists(dispdata$ & "\csliptop.rtf") Then
   If RTFExistsInDatabase(dispdata$ & "\csliptop.rtf") Then '10Jan17 TH replaced above (Hosted)
      'Hedit 11, dispdata$ & "\csliptop.rtf"
      EditRTFFromDB dispdata$ & "\csliptop.rtf"  '10Jan17 TH Replaced Above(Hosted)
   Else
      'popmessagecr "!Error", "File " & dispdata$ & "\CSLIPTOP.RTF not found"
      popmessagecr "!Error", "'CSLIPTOP' rtf record not found in database"
   End If

End Sub

Private Sub MnuFinMonthEnd_Click()

    FINANASC "4", False

End Sub

Private Sub MnuFinRecon_Click()

    FINANASC "1", False

End Sub

Private Sub MnuFinReprintDNotes_Click()
'22Nov00 EAC/CY Handle in-dispute items

Dim tmpEditType%

   tmpEditType = Edittype
   Edittype = 4
   Reprint 4, "dispute note"
   Edittype = tmpEditType

End Sub

Private Sub MnuFinSlips_Click()

    FINANASC "2", False

End Sub

Private Sub MnuGoodsRcvd_Click()
'30Mar00 CFY Written. Prompts user for sort order before calling report.
'18Apr00 CFY Now prompts for an order number to allow additional filtering.
'23Jun00 AE  Now uses correct ini file entry (paste error)

Dim sDefaultSort As String, sResult As String, sAns As String
Dim iSort As Integer

   'Read default sort selection from ini file
   sDefaultSort = TxtD(dispdata$ & "\winord.ini", "defaults", "1", "GoodsReceived", 0)
   
   'k.Max = 10
   k.Max = 9 '24Nov05 TH Altered
   inputwin "Goods Received Report", "Enter order number (or leave blank for all orders)", sAns, k
   
   If Not k.escd Then         'Ask user to choose sort order
      frmoptionset -1, "Choose Sort Order"
      frmoptionset 1, "Location Code"
      frmoptionset 1, "Order Number"
      frmoptionset 1, "Product Description"
      frmoptionshow sDefaultSort, sResult
      frmoptionset 0, ""
   End If

   If Not k.escd And sResult <> "" Then '01Jun05 TH Added check on sResult (#80451)
      'Save sort order for next time and print
      WritePrivateIniFile "defaults", "GoodsReceived", sResult, dispdata$ & "\winord.ini", 0           '?????00 AE  Corrected paste error
      Select Case Val(sResult)
         Case 1: iSort = 4
         Case 2: iSort = 2
         Case 3: iSort = 3
         End Select
      OrdersPrint Trim$(sAns), sup, 4, iSort, "Goods Received Report"
   End If

End Sub

Private Sub mnuHelp_Click(Index As Integer)
'28Aug97 CKJ Do not blank the screen if help is requested
'            especially as printscreen is on the About box
'03Dec97 EAC Updated Help menu to be same as ASCSHELL
'01Jun11 CKJ added As Integer

   Select Case Index
      Case 0: SendKeys "{F1}"  'Help 0
      Case 1: HelpSearch Me.Hwnd
      Case 2: HelpGet Me.Hwnd, HELP_HELPONHELP, 0
      Case 4: ShowAboutBox "Stock Control"
   End Select

End Sub

Private Sub MnuHUBLayout_Click()
'08Feb16 TH Written based on tofollow rtf edit option (TFS 138647)
'10Jan17 TH Refactored to use DB rtf (Hosted)
'09Mar17 TH Fixed rtf reference (TFS 179306)

'Dim OK%
'Dim Layout$, OldLayout$

   'GetTextFile dispdata$ + "\Hubexcep.rtf", Layout$, OK
   'GetRTFTextFromDB dispdata$ + "\Hubexcep.rtf", Layout$, OK  '06Dec16 TH Replaced (TFS 157969)

   'If Not OK Then
   'If Not RTFExistsInDatabase(dispdata$ & "\ToFollow.rtf") Then '10Jan17 TH replaced above (Hosted)
   If Not RTFExistsInDatabase(dispdata$ & "\Hubexcep.rtf") Then '09Mar17 TH wrong rtf (TFS 179306)
      'popmessagecr "Error", "There was a problem reading the RTF layout file - " & "Hubexcep.rtf"
      popmessagecr "Error", "There was a problem reading the RTF layout 'Hubexcep' from the database"
      Exit Sub
   End If
    
   'If OK Then
   '   OldLayout$ = Layout$
   '   Hedit 1, Layout$
   '   If OldLayout$ <> Layout$ Then PutTextFile dispdata$ + "\Hubexcep.rtf", Layout$, OK
   '   If Not OK Then popmessagecr "!Error", "Failed to write new layout to " & dispdata$ & "\Hubexcep.rtf"
   'Else
   '   popmessagecr "!Error", "Failed to read the layout file " & dispdata$ & "\Hubexcep.rtf"
   'End If
   'EditRTFFromDB dispdata$ & "\ToFollow.rtf"  '10Jan17 TH Replaced Above(Hosted)
   EditRTFFromDB dispdata$ & "\Hubexcep.rtf"  '09Mar17 TH Replaced Above (TFS 179306)
   
End Sub

Private Sub MnuInfo_Click(Index As Integer)
'23Dec97 EAC created menu from several old menus
'            added Logfile viewer
'29May01 TH  Added parameter search parameter to logview call
'29Apr02 SF  call the log viewer to group by products (enh#1555)

Dim num$, msg$
   
   Select Case Index
      Case 0
         DrugEnquiry
          
      Case 1
         ODrugInfo$ = ""   '26Dec98 ASC
         SiteDrugEnquiry
          
      Case 3
         setinput 0, k
         k.escd = False
         k.Max = 9 '24Nov05 TH Altered from 10
         k.min = 0
         num$ = ""
         msg$ = "Enter order number"
         inputwin "Order Enquiry", msg$, num$, k
         
         If Not k.escd Then
            DisplayOrder num$
         End If
         setinput 0, k
          
      Case 4
         RequisitionEnquiry
          
      Case 6  'Log file viewer
         If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "Y", "UseNewLogView", 0)) Then
            If InStr(1, Command$, "///lk", 1) Then frmLogView.txtSite.Enabled = False '25Apr12 TH TFS 26711
            frmLogView.Show 1
         Else
            UserLogViewer "LDFS", "", "", "", "", 0  '29May01 TH Added parameter
         End If
         
      '29Apr02 SF added to call the log viewer to group by products (enh#1555)
      Case 7
         If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "Y", "UseNewLogView", 0)) Then
              frmLogView.chkGroupBy = "1"
              If InStr(1, Command$, "///lk", 1) Then frmLogView.txtSite.Enabled = False '25Apr12 TH TFS 26711
              frmLogView.Show 1
           Else
              SetGroupByProduct True
              UserLogViewer "LDFS", "", "", "", "", 0
              SetGroupByProduct False
           End If
      
      Case 9         '13Mar07 CKJ added (SC-07-0157)
         ShowAllRobotMessageWindows
   
      'Case 2, 5, 8 'Separators
      End Select

End Sub

Private Sub MnuInfoTop_Click()
'07Jan10 CKJ Option to show robot messages is greyed unless there's a form to display
'            and user has rights to see the rest of the info menu options

   mnuInfo(9).Enabled = (mnuInfo(0).Enabled And (CountAllRobotMessageWindows() > 0))

End Sub

Private Sub MnuLayout_Click(Index As Integer)

Dim RTFfilename$, Layout$

   Select Case Index
      Case 0:    RTFfilename$ = "\PickTop.rtf"
      Case 1:    RTFfilename$ = "\PickDesc.rtf"
      Case 2:    RTFfilename$ = "\DelnDesc.rtf"
      Case 3:    RTFfilename$ = "\CredDesc.rtf"
      Case 4:    RTFfilename$ = "\PickData.rtf"
      Case 5:    RTFfilename$ = "\DelnData.rtf"
      Case 6:    RTFfilename$ = "\CredData.rtf"
      Case 7:    RTFfilename$ = "\PickTotl.rtf"
      Case 8:    RTFfilename$ = "\PickBot.rtf"
      Case Else: popmessagecr "Error", "MnuLayout_Click called with value" + Str$(Index) & Chr$(13) & "Please report this fault to EMIS Health."
      End Select

    'Hedit 11, dispdata$ + RTFfilename$
    EditRTFFromDB dispdata$ & RTFfilename$  '10Jan17 TH Replaced Above(Hosted)

End Sub

Private Sub MnuLayoutTFRpt_Click()
'18Apr01 CFY Added
'10Jan17 TH Refactored to use DB rtf (Hosted)

'Dim OK%
'Dim Layout$, OldLayout$

   'GetTextFile dispdata$ + "\ToFollow.rtf", Layout$, OK
   'GetRTFTextFromDB dispdata$ + "\ToFollow.rtf", Layout$, OK '06Dec16 TH Replaced (TFS 157969)

   'If Not OK Then
   If Not RTFExistsInDatabase(dispdata$ & "\ToFollow.rtf") Then '10Jan17 TH replaced above (Hosted)
      popmessagecr "Error", "There was a problem reading the RTF layout 'ToFollow' from the database"
      Exit Sub
   End If
    
   'If OK Then
            'OldLayout$ = Layout$
            'Hedit 1, Layout$
            'If OldLayout$ <> Layout$ Then PutTextFile dispdata$ + "\ToFollow.rtf", Layout$, OK
            'If Not OK Then popmessagecr "!Error", "Failed to write new layout to " & dispdata$ & "\ToFollow.rtf"
   'Else
   '    popmessagecr "!Error", "Failed to read the layout file " & dispdata$ & "\ToFollow.rtf"
   'End If
   EditRTFFromDB dispdata$ & "\ToFollow.rtf"  '10Jan17 TH Replaced Above(Hosted)
   
   
End Sub

Private Sub MnuMediate_Click(Index As Integer)

   Select Case Index
      Case 0: EDIOrder
      Case 1: EDIReadPWO
      Case 2: EDIInvoicing
      End Select

End Sub

Private Sub MnuOrders_Click()

    WardStockLoaded = False
    ChangeTable "Blank", False '14Aug12 TH Added Param

End Sub

Private Sub MnuOrdersAmend_Click()
    
    freestock = False
    MainOptions "2", SiteNumber, False

End Sub

Private Sub MnuOrdersAuth_Click()

    MainOptions "3", SiteNumber, False

End Sub

Private Sub MnuOrdersAuthCred_Click()

    MainOptions "10", SiteNumber, False

End Sub

Private Sub MnuOrdersCreate_Click()

    MainOptions "1", SiteNumber, False

End Sub

Private Sub MnuOrdersCredit_Click()

    MainOptions "9", SiteNumber, False

End Sub


Private Sub MnuOrdersReceive_Click()

    MainOptions "4", SiteNumber, False

End Sub

Private Sub MnuOrdersSupp_Click()

    MainOptions "12", SiteNumber, False

End Sub

Private Sub MnuOrdLayout_Click(Index As Integer)

Dim RTFfilename$

   Select Case Index
      Case 0
         RTFfilename$ = "\OrdTop.rtf"
      Case 1
         RTFfilename$ = "\OrdDescr.rtf"
      Case 2
         RTFfilename$ = "\OrdData.rtf"
      Case 3
         RTFfilename$ = "\OrdExtra.rtf"
      Case 4
         RTFfilename$ = "\OrdTotal.rtf"
      Case 5
         RTFfilename$ = "\OrdBot.rtf"
     Case Else
         popmessagecr "!Error", "MnuOrdLayout_Click called with value" + Str$(Index) & Chr$(13) & "Please report this fault to EMIS Health."
   End Select


   'Hedit 11, dispdata$ & RTFfilename$
   EditRTFFromDB dispdata$ & RTFfilename$  '10Jan17 TH Replaced (Hosted)


End Sub

Private Sub MnuPreOrderPrint_Click()
'30Mar00 CFY Written. Prompts user for a supplier followed by the report sort order.
'05Sep02 SF  mods to allow cancelling out correctly of pre-order printing (event #61535)

Dim sSupCode As String, sDefaultSort As String, sResult As String
Dim iNumofSups As Integer, iSort As Integer '', iFoundSup As Integer
Dim sup As supplierstruct

   'Read default sort selection from ini file
   sDefaultSort = TxtD(dispdata$ & "\winord.ini", "defaults", "1", "PreOrderPrint", 0)
   
   'Ask which supplier user wishes to print report for
   supswithords 99, sSupCode, iNumofSups, "", False '11Jun12 TH Added param (DLO)
   getsupplier sSupCode, 0, 0, sup

   If Trim$(sSupCode) <> "" Then        '05Sep02 SF now traps if cancelled out from choosing a supplier
         'Ask user to choose sort order
         frmoptionset -1, "Choose Sort Order"
         frmoptionset 1, "Location"
         frmoptionset 1, "Product Description"
         frmoptionshow sDefaultSort, sResult
         frmoptionset 0, ""
      
         '05Sep02 SF now ensures user selected a sort order before attempting to print
         If (Not k.escd) And (Trim$(sResult) <> "") Then
               'Save sort order for next time and print
               WritePrivateIniFile "defaults", "PreOrderPrint", sResult, dispdata$ & "\winord.ini", 0
               Select Case Val(sResult)
                  Case 1: iSort = 4
                  Case 2: iSort = 3
               End Select
               OrdersPrint "", sup, 1, iSort, "PreOrder Print" 'SQL added '21Jul05 TH Added caption param
            End If
      End If                            '05Sep02 SF

End Sub

Private Sub MnuProgram_Click(Index As Integer)

Dim valid%
Dim fullname$

    Select Case Index
        Case 1, 3
        Case 0
            SetPrinterOptions
        Case 2
            If Not OCXlaunch() Then          '29Oct03 CKJ
                  ChangeTable "Blank", False '14Aug12 TH Added Param
                  ResetMenuOptions                                                  '23Feb99 JP new function to disable all menu options until login complete
                 '''SQL ??? askpassword valid%, fullname$, "Windows Stock Control"
          
                  Storepasslvl = Val(Mid$(acclevels$, 6, 1))
                  WardStockPasslvl = Val(Mid$(acclevels$, 2, 1))
      
                  If valid Then
                        SetToolBarView Me, "Blank"
                     Else
                        SetToolBarView Me, "NoPass"
                     End If
      
                  SetMenuOptions
               End If
        Case 4
            Unload Me
            StoresEnd   'V93
    End Select

End Sub

Private Sub MnuPSO_Click()
'Select Case Index
'   Case 1
'      freestock = False
'      MainOptions "2", SiteNumber, True
'   Case 2
'      MainOptions "3", SiteNumber, True
'   Case 3
'      MainOptions "4", SiteNumber, True
'   Case 4
'      FINANASC "1", True
'End Select

End Sub

Private Sub mnuPSOAmend_Click()
   freestock = False
   MainOptions "2", SiteNumber, True
End Sub

Private Sub mnuPSOAuth_Click()
'22Aug12 TH Added (TFS 41431)
   MainOptions "3", SiteNumber, True
End Sub

Private Sub mnuPSOHubInv_Click()
   Invoice_EHub
End Sub

Private Sub mnuPSOHubInvSettings_Click()
   HubSupplierSetup
End Sub

Private Sub mnuPSOHubRec_Click()
   Receive_eHUBPOD '20Apr15 TH Missed on initial merge (TFS 116567)
End Sub

Private Sub mnuPSOInv_Click()
'03Sep13 TH Added (TFS 42773)

   FINANASC "1", True
End Sub

Private Sub MnuPSOOrdLayout_Click(Index As Integer)
'20Aug12 TH Written . Added new PSO rtf Editor menus (TFS 40791)
'10Jan17 TH Refactored to use DB (Hosted)

Dim RTFfilename$

   Select Case Index
      Case 1
         RTFfilename$ = "\PSO_OrdTop.rtf"
      Case 2
         RTFfilename$ = "\PSO_OrdDescr.rtf"
      Case 3
         RTFfilename$ = "\PSO_OrdData.rtf"
      Case 4
         RTFfilename$ = "\PSO_OrdExtra.rtf"
      Case 5
         RTFfilename$ = "\PSO_OrdTotal.rtf"
      Case 6
         RTFfilename$ = "\PSO_OrdBot.rtf"
      Case Else
         'popmessagecr "!Error", "MnuOrdLayout_Click called with value" + Str$(Index) & Chr$(13) & "Please report this fault to EMIS Health."
         popmessagecr "!Error", "MnuPSOOrdLayout_Click called with value" + Str$(Index) & Chr$(13) & "Please report this fault to EMIS Health."
   End Select


   'Hedit 11, dispdata$ & RTFfilename$
   EditRTFFromDB dispdata$ & RTFfilename$  '10Jan17 TH Replaced (Hosted)
   
End Sub

Private Sub mnuPSORec_Click()
'03Sep12 TH (TFS 41784)

   MainOptions "4", SiteNumber, True
End Sub

Private Sub MnuReadTopup_Click(Index As Integer)
'07Dec97 Written

    ImportWardData Index

End Sub

Private Sub MnuReprint_Click(Index As Integer)
'05Mar98 ASC/EAC
Dim strContext As String

   Select Case Index
      Case 1: strContext = "return"
      Case Else: strContext = "order"
   End Select
   Reprint Index, strContext
End Sub

Private Sub MnuReprintReq_Click(Index As Integer)
'05Mar98 ASC/EAC
Dim strContext As String

   Select Case Index
      Case 2: strContext = "picking ticket"
      Case Else: strContext = "delivery note"
   End Select
    Reprint Index, strContext

End Sub

Private Sub MnuReq_Click()

    WardStockLoaded = False
    ChangeTable "Blank", False '14Aug12 TH Added Param

End Sub

Private Sub MnuReqDelivery_Click()

    MainOptions "8", SiteNumber, False

End Sub

Private Sub MnuReqEnter_Click()

    MainOptions "5", SiteNumber, False

End Sub

Private Sub MnuReqIssue_Click()

    osite$ = "A"
    MainOptions "7", SiteNumber, False

End Sub

Private Sub MnuReqPrintPick_Click()

    MainOptions "6", SiteNumber, False

End Sub

Private Sub MnuReqReturn_Click()

    MainOptions "11", SiteNumber, False

End Sub

Private Sub MnuRobotLoading_Click()
' Called when the RobotLocainf menu item is clicked
' Displays the robot loding modal form (actualy an ICW web page)
    DisplayRobotLoading SiteNumber, GetRobotLocationCode()
End Sub

Private Sub mnuShelfStockReport_Click()
'26Apr02 SF added (enh#1555)
'10Jan17 TH Refactored to use DB (Hosted)

   'If fileexists(dispdata$ & "\sstklst.rtf") Then
   If RTFExistsInDatabase(dispdata$ & "\sstklst.rtf") Then '10Jan17 TH replaced above (Hosted)
      'Hedit 11, dispdata$ & "\sstklst.rtf"
      EditRTFFromDB dispdata$ & "\sstklst.rtf"  '10Jan17 TH Replaced (Hosted)
   Else
      'popmessagecr "!Error", "File " & dispdata$ & "\SSTKLST.RTF not found"
      popmessagecr "Error", "There was a problem reading the RTF layout 'SSTKLST' from the database"
   End If

End Sub

Private Sub MnuSort_Click(Index As Integer)

    Select Case Index
        Case 0 To 2      ' Sort Options
            SortMarkedBlock Index, (MnuSort(4).Checked = True)
        'Case 3          ' Seperator Line
        Case 4          ' Display Order
            MnuSort(Index).Checked = Not MnuSort(Index).Checked
            PopupMenu mnuWSOptions
        Case Else
            popmessagecr "", "This option is not available yet."
    End Select

End Sub

Private Sub mnuStockList_Click()
'22Apr02 SF added (enh#1555)

    ShelfStockList

End Sub

Private Sub MnuToFollows_Click()
'18Apr01 CFY Now only calls ToFollowsPrint once!!!
'08Mar02 TH Pick up cancel correctly (#58511)

Dim sDefaultSort As String, sResult As String
Dim iSort As Integer

   'Read default sort selection from ini file
   sDefaultSort = TxtD(dispdata$ & "\winord.ini", "defaults", "1", "ToFollowsPrint", 0)

   'Ask user to choose sort order
   frmoptionset -1, "Choose Sort Order"
   frmoptionset 1, "Supplier"
   frmoptionset 1, "Product Description"
   '24Apr02 ATW Added for Hierarchical reports (#55445)
   If HierarchicalReportCount() > 0 Then
         frmoptionset 1, "Hierachical Report"
      End If
   frmoptionshow sDefaultSort, sResult
   frmoptionset 0, ""

   'If Not k.escd Then            '08Mar02 TH Pick up cancel correctly (#58511)
   If Trim$(sResult) <> "" Then   '    "
         'Save sort order for next time and print
         WritePrivateIniFile "defaults", "ToFollowsPrint", sResult, dispdata$ & "\winord.ini", 0
         Select Case Val(sResult)
            Case 1: iSort = 1
            Case 2: iSort = 2
            '24Apr02 ATW        Added for Hierarchical reports (#55445)
            Case 3:
               ToFollowReport2
               Exit Sub
         End Select
         ToFollowsPrint iSort
      End If
   
End Sub

Private Sub MnuUtil_Click()

    WardStockLoaded = False
    ChangeTable "Blank", False '14Aug12 TH Added Param

End Sub

Private Sub MnuUtilAmend_Click()

   OrderingUtils SiteNumber, "4", False

End Sub

Private Sub MnuUtilCalcs_Click()

    OrderingUtils SiteNumber, "6", False

End Sub

Private Sub MnuUtilContPrice_Click()

    DrugContract.Show 1

End Sub

Private Sub MnuUtilCycle_Click()

    OrderingUtils SiteNumber, "9", False

End Sub

Private Sub MnuUtilDang_Click()
    
    OrderingUtils SiteNumber, "2", False

End Sub

Private Sub MnuUtilDefs_Click()

   OrderingUtils SiteNumber, "5", False

End Sub

Private Sub MnuUtilLayout_Click(Index As Integer)
'10Jan17 TH Refactored to use DB (Hosted)
'01Feb17 TH Corrected odd typo for util report (Hosted) (TFS 175454)

Dim RTFfilename$ ', Layout$, OldLayout$
'Dim OK%

   Select Case Index
      Case 0: RTFfilename$ = "\utilreps.rtf"
      'Case 1: RTFfilename$ = "\checkgrn.rtf"         '06Jul11CKJ FTU is obsolete, so removed layout
      End Select

   'GetTextFile dispdata$ + RTFfilename$, Layout$, OK
   'GetRTFTextFromDB dispdata$ + RTFfilename$, Layout$, OK '06Dec16 TH Replaced (TFS 157969)


   'If OK Then
   If RTFExistsInDatabase(dispdata$ & RTFfilename$) Then '10Jan17 TH replaced above (Hosted)
      'OldLayout$ = Layout$
      'Hedit 1, Layout$
      'If OldLayout$ <> Layout$ Then PutTextFile dispdata$ + RTFfilename$, Layout$, OK
      'If Not OK Then popmessagecr "!Error", "Failed to write new layout to " & dispdata$ & RTFfilename$
      'EditRTFFromDB dispdata$ & "RTFfilename$  '10Jan17 TH Replaced (Hosted)"
      EditRTFFromDB dispdata$ & RTFfilename$  '01Feb17 TH Corrected odd typo above (Hosted) (TFS 175454)
   Else
      'popmessagecr "!Error", "Failed to read the layout file " & dispdata$ & RTFfilename$
      popmessagecr "!Error", "Failed to read the layout '" & RTFfilename$ & "' from the database"
   End If

End Sub

Private Sub MnuUtilLevel_Click()
    
    OrderingUtils SiteNumber, "1", False

End Sub

Private Sub MnuUtilNeg_Click()

    OrderingUtils SiteNumber, "3", False

End Sub

Private Sub MnuUtilOut_Click()

    FindOutStanding  '10Dec97 EAC

End Sub

Private Sub MnuUtilRestore_Click()

    OrderingUtils SiteNumber, "8", False

End Sub

Private Sub MnuUtilStckTake_Click()

  ' LoadStockTake '16May05 TH Removed

End Sub

Private Sub MnuUtilTidy_Click()
'25Feb99 TH Now calls Wdelord to tidy and reorder indexes
'24May99 TH Replaced Drive designation
'25May99 TH Moved wdelord path to ascribe folder (AppPath)
'07Oct99 TH Changed message

Dim X%
   popmessagecr "", "Removed for 9.3"
   Exit Sub
   'makecommand orderpath$ & "\delord"   '25Feb99 TH Replaced
   'makecommand orderpath$ & "\Wdelord"
   'x = Shell(orderpath$ & "\wdelord.exe  " & Str$(sitenumber%) & " " & currentDRV$, 1)
   On Error Resume Next
   'x = Shell(orderpath$ & "\wdelord.exe  " & Str$(sitenumber%) & " " & progsDRV$, 1)    '24May99 TH Replaced
   'x = Shell(orderpath$ & "\wdelord.exe  " & Str$(sitenumber%) & " " & Left$(CurDir$, 2), 1)   '
   X = Shell(AppPathNoSlash() & "\wdelord.exe  " & Str$(SiteNumber%) & " " & Left$(CurDir$, 2), 1)   '25May99 TH Move all programs to ascribe folder
   If Err Then
         'popmessagecr "", " Error starting " & orderpath$ & "\wdelord.exe.  Check program exists and try again."      '07Oct99 TH
         popmessagecr "", " Error starting " & AppPathNoSlash() & "\wdelord.exe.  Check program exists and try again." '   "
         Err = 0
      End If

End Sub

Private Sub MnuWardStock_Click(Index As Integer)
'03Dec97 EAC updated for Adhoc Return

    Select Case Index
        'Case 2, 8, 11   'Seperators
        Case 0         'Adhoc
            AdhocIssue True
        Case 1
            AdhocIssue False
        Case 3         'Edit,Issue & Return
            WSLISTSQL
        Case 5         'List without barcodes
            prilistSQL 1
        Case 6         'List with barcodes
            prilistSQL 2
        Case 7         'Alphabetical List
            prilistSQL 3                                    '    "
        Case 9         'Location of Stock on wards
            stocklocSQL
        Case 10        'S&R across wards
            'no action
        Case 12        'Hand-held DCT
            Dctfrm.Show 1   '08Mar10 TH Reinstated after merge error (F0079944)
        End Select

End Sub

Private Sub MnuWriteTopup_Click(Index As Integer)
'22Jun98 EAC/CFY distinguish between Psion and CE when exporting

Dim wardcode$
    
    wardcode$ = ward$
    ExportWardData wardcode$, Index       '22Jun98 EAC/CFY added ,Index

End Sub

Private Sub MnuWS_Click()

    ChangeTable "Blank", False '14Aug12 TH Added Param
    lvwMainScreen.Enabled = True
    WardStockLoaded = True

End Sub

Private Sub MnuWSDelete_Click()
'16Apr02 TH Written to allow new search and delete across wards enhancement (enh1477)
'25Apr02 TH/SF Second get of drug is superfluous
'31May02 TH Reference nsvcode directly
'29Jul02 TH Use NSVcode only (not searchstring) in sarall delete call

Dim strNSVCode As String, strAns As String, intFound As Integer, strName As String

   setinput 0, k
   EnterDrug strNSVCode, "Enter Item"
   If Not k.escd Then
      findrdrug strNSVCode, True, d, False, intFound, False, False, False
      'If intFound <> 0 Then                                   '25Apr02 TH/SF Second get is superfluous
      '      getdrug d, (False), intFound, False    ' No lock  '   "
      '      strNSVcode = d.siscode                            '   "
      '   Else                                                 '   "
      If intFound = 0 Then                                     '   "
            k.escd = True
         End If
   End If

   If Not k.escd Then
      setinput 0, k
      strAns = "N"
      strName = d.DrugDescription       ' strName = GetStoresDescription()  XN 4Jun15 98073 New local stores description
      plingparse strName, "!"
      'askwin "!Delete", "Are you sure you want to delete the details for item " & strNSVcode & Chr$(13) & strName, strAns, k
      askwin "!Delete", "Are you sure you want to delete the details for item " & UCase$(Trim$(d.SisCode)) & Chr$(13) & strName, strAns, k   '31May02 TH Reference nsvcode directly
      If UCase(Trim$(strAns)) = "Y" And Not k.escd Then
         'sarall 3, strNSVcode, "", "", "", "", "", ""  '29Jul02 TH Use NSVcode only
         sarallSQL 3, d.SisCode, "", "", "", "", "", ""    '   "
      End If
   End If

End Sub

Private Sub MnuWSDrugInfo_Click()

    LstDisplay.Clear
    frmSearch.Show 1

End Sub

Private Sub MnuWSLayout_Click(Index As Integer)
'16Apr02 TH Added Edit option for new search and delete rtf (enh1477)
'10Jan17 TH Refactored to use DB (Hosted)

Dim RTFfilename$ ', Layout$, OldLayout$
'Dim OK%

   Select Case Index
      Case 0:    RTFfilename$ = "\WSAlpha.rtf"
      Case 1:    RTFfilename$ = "\WSStock.rtf"
      Case 2:    RTFfilename$ = "\WSSandR.rtf"
      Case 3:    RTFfilename$ = "\WSdct.rtf"
      Case 4:    RTFfilename$ = "\WSDel.rtf"                           '16Apr02 TH (enh1477)
      Case Else: popmessagecr "!Error", "MnuWSLayout_Click called with value" + Str$(Index) & Chr$(13) & "Please report this fault to EMIS Health."
   End Select

   'GetTextFile dispdata$ + RTFfilename$, Layout$, OK
   'GetRTFTextFromDB dispdata$ + RTFfilename$, Layout$, OK '06Dec16 TH Replaced (TFS 157969)


   'If OK Then
   If RTFExistsInDatabase(dispdata$ & RTFfilename$) Then '10Jan17 TH replaced above (Hosted)
      'OldLayout$ = Layout$
      'Hedit 1, Layout$
      'If OldLayout$ <> Layout$ Then PutTextFile dispdata$ + RTFfilename$, Layout$, OK
      'If Not OK Then popmessagecr "!Error", "Failed to write new layout to " & dispdata$ & RTFfilename$
      EditRTFFromDB dispdata$ & RTFfilename$  '10Jan17 TH Replaced (Hosted)
   Else
      'popmessagecr "!Error", "Failed to read the layout file " & dispdata$ & RTFfilename$
      popmessagecr "!Error", "Failed to read the layout '" & RTFfilename$ & "' from the database"
   End If

End Sub

Private Sub MnuWSMissing_Click()

    sarallSQL 2, "", "", "", "", "", "", "" '11Jan02 TH Added new parameter

End Sub

Private Sub MnuWSOBIssue_Click()

Dim tempdrug As drugdetails

'   If lvwMainScreen.SelectedItem.Index > 0 Then
'      PrepareIssue 3, tempdrug, 0, lvwMainScreen.SelectedItem.Index
'   Else
'      PrepareIssue 3, tempdrug, 0, 0
'   End If
   tempdrug = drugs(MainLVWSingleSelectedItemIndex()) '10Sep12 TH Added (TFS 43275)
   'PrepareIssue 3, tempdrug, 0, MainLVWSingleSelectedItemIndex(), False '11Jul11 CKJ equivalent as function returns zero if no line selected
   'PrepareIssue 3, tempdrug, 0, MainLVWSingleSelectedItemIndex(), False, False, 0 '01Sep14 TH new param
   PrepareIssue 3, tempdrug, 0, MainLVWSingleSelectedItemIndex(), False, False, 0 '28Jan15 TH new param
   
End Sub

Private Sub MnuWSOBlkInsert_Click()

'Dim pos&
'
'    '''pos& = lvwMainScreen.RowIndex
'    pos& = lvwMainScreen.SelectedItem.Index
'    BlockInsert pos&
    BlockInsert MainLVWSingleSelectedItemIndex()

End Sub

Private Sub MnuWSOBlockDel_Click()

Dim BlkStart&, BlkEnd&
Dim valid%

    DimensionBlock BlkStart, BlkEnd, valid
    If valid Then DeleteLines BlkStart, BlkEnd, 0 '27Feb02 TH Added parameter (enh1463)

End Sub

Private Sub MnuWSOBReturn_Click()
Dim tempdrug As drugdetails

'   If lvwMainScreen.SelectedItem.Index > 0 Then
'      PrepareIssue 3, tempdrug, -1, lvwMainScreen.SelectedItem.Index
'   Else
'      PrepareIssue 3, tempdrug, -1, 0
'   End If
   tempdrug = drugs(MainLVWSingleSelectedItemIndex()) '10Sep12 TH Added (TFS 43275)
   'PrepareIssue 3, tempdrug, -1, MainLVWSingleSelectedItemIndex(), False   '11Jul11 CKJ equivalent
   'PrepareIssue 3, tempdrug, -1, MainLVWSingleSelectedItemIndex(), False, False '01Sep14 TH new param
   PrepareIssue 3, tempdrug, -1, MainLVWSingleSelectedItemIndex(), False, False, 0 '28Jan15 TH new param
   

End Sub

Private Sub MnuWSOChange_Click()

    EditWardCode "", "", 0

End Sub

Private Sub MnuWSOCopy_Click()

    blockcopy

End Sub

Private Sub MnuWSOCut_Click()
'27Feb02 TH Added (enh1463)
   blockcut
End Sub

Private Sub MnuWSODelete_Click()

Dim CurrentRow As Long

    CurrentRow& = MainLVWSingleSelectedItemIndex()
    If CurrentRow > 0 Then DeleteLines CurrentRow&, CurrentRow&, 0   '27Feb02 TH added parameter (enh1463)

End Sub

Private Sub MnuWSOEnquiry_Click()

   DrugEnquiry
   
End Sub

Private Sub MnuWSOFind_Click()
   findstr ""
End Sub

Private Sub MnuWSOInfo_Click()

    dispdata$ = warddispdata$
    Wardinfo
    dispdata$ = dispdatastore$

End Sub

Private Sub MnuWSOInsert_Click()

Dim linepos&

   linepos& = MainLVWMarqueeRowIndex()
   If lvwMainScreen.ListItems.count < 1 Then linepos& = 1
   InsertLine linepos&

End Sub

Private Sub MnuWSONext_Click()
   findlineMenu '03Nov05 TH (#83727)
End Sub

Private Sub MnuWSOPrint_Click()

   PrintMarkedText

End Sub

Private Sub MnuWSOSaveAs_Click()

    SaveAsNewWard

End Sub

Private Sub MnuWSPrilist_Click(Index As Integer)
'10Jan17 TH Refactored to use DB (Hosted)
Dim RTFfilename$ ', Layout$, OldLayout$
'Dim OK%

   Select Case Index
      Case 0:    RTFfilename$ = "\WSLtop.rtf"
      Case 1:    RTFfilename$ = "\DrugHdr.rtf"
      Case 2:    RTFfilename$ = "\BCodeHdr.rtf"
      Case 3:    RTFfilename$ = "\WSLdrug.rtf"
      Case 4:    RTFfilename$ = "\WSLBcode.rtf"
      Case 5:    RTFfilename$ = "\WSLBttm.rtf"
      Case Else: popmessagecr "!Error", "MnuWSPrilist_Click called with value" + Str$(Index) & Chr$(13) & "Please report this fault to EMIS Health."
      End Select
      
   'GetTextFile dispdata$ + RTFfilename$, Layout$, OK
   'GetRTFTextFromDB dispdata$ + RTFfilename$, Layout$, OK '06Dec16 TH Replaced (TFS 157969)


   'If OK Then
   If RTFExistsInDatabase(dispdata$ & RTFfilename$) Then '10Jan17 TH replaced above (Hosted)
      'OldLayout$ = Layout$
      'Hedit 1, Layout$
      'If OldLayout$ <> Layout$ Then PutTextFile dispdata$ + RTFfilename$, Layout$, OK
      'If Not OK Then popmessagecr "!Error", "Failed to write new layout to " & dispdata$ & RTFfilename$
      EditRTFFromDB dispdata$ & RTFfilename$  '10Jan17 TH Replaced (Hosted)
   Else
      'popmessagecr "!Error", "Failed to read the layout file " & dispdata$ & RTFfilename$
      popmessagecr "!Error", "Failed to read the layout '" & RTFfilename$ & "' from the database"
   End If

End Sub

Private Sub picToolBar_MouseDown(button As Integer, Shift As Integer, X As Single, Y As Single)
'05jan99 CKJ
' XN 08Jun10 F0085853 Menu bar colour now set via config setting (so site dependant)

'Static Colour%

   If button = RIGHT_BUTTON Then
' XN 08Jun10 F0085853 Menu bar colour now set via config setting (so site dependant)
'      ElseIf button = LEFT_BUTTON Then            '05jan99 CKJ test purposes only
'         Colour = (Colour + 1) Mod 16
'         picToolBar.BackColor = QBColor(Colour)
         ConfigureToolBarPopup Me
      End If

End Sub

Private Sub lvwMainScreen_click()

   MainScreenSetTextAndPanels Edittype    '06Jul11 CKJ replaces verbose version

End Sub

Private Sub lvwMainScreen_DblClick()
'28Oct97 EAC Add code to treat double click same as pressing enter key
'        in Ordering side of software apart from in Reconciliation where
'        double click highlights the lines to be reconciled
'18May98 EAC Prevent Subscript out of range
'12Nov98 TH  Code to select individual items to order direct from ammend screen
'02Oct06 TH  If dbl click blank screen no functionality required regardless of mode (SC-06-0768)

   If lvwMainScreen.ListItems.count = 0 Then Exit Sub '02Oct06 TH Moved here as if dbl click blank screen no functionality required regardless of mode (SC-06-0768)
   
   k.escd = False '07Jun12 TH Added DLO
   
   If Not TxtInput.Visible Then    'wardstock
      WardStockEditLine
   Else                            'non-wardstock
      If Abs(Edittype) = 4 Then
         ProcessDrugLine (TxtInput.text), True     '27Jun11 CKJ Replaces TxtInput_KeyPress -13 '25OCt05 TH Replaced above line(#82079)
      Else
         'If edittype = 1 Then k.escd = DLOOrderLineGridCheck("") '07Jun12 TH Added DLO
         If Edittype = 1 Then k.escd = OrderLineGridCheck("") '13Nov12 TH altered
         If Not k.escd Then ProcessDrugLine (TxtInput.text), True '11Dec12 TH Set fromlstview to true    '27Jun11 CKJ Replaces TxtInput_KeyPress 13
      End If
   End If
   
End Sub

Private Sub WardStockEditLine()
'28Oct97 EAC Add code to treat double click same as pressing enter key
'        in Ordering side of software apart from in Reconciliation where
'        double click highlights the lines to be reconciled
'18May98 EAC Prevent Subscript out of range
'12Nov98 TH  Code to select individual items to order direct from ammend screen
'02Oct06 TH  If dbl click blank screen no functionality required regardless of mode (SC-06-0768)
'27Jun11 CKJ Moved out of listview doubleclick event, as the events were very self-referential
'            Uses lvwMainScreen.SelectedItem.Index, but has extra checking before editing.
'            Changed "Set FrmWardStockEdit = New FrmWardStockEdit" & added declare
'            - should not use design time object in this way

Dim dummy%
Dim strTemp As String
Dim lngRow As Long
Dim dlocal As DrugParameters
Dim lngFound As Long
Dim ItemIndex As Long
Dim WardStockEdit As FrmWardStockEdit

   'Sanity Checks
   If TxtInput.Visible Then Exit Sub   'Not wardstock
   
'   If lvwMainScreen.ListItems.count = 0 Then Exit Sub '02Oct06 TH Moved here as if dbl click blank screen no functionality required regardless of mode (SC-06-0768)
'   If (lvwMainScreen.SelectedItem Is Nothing) Then Exit Sub    'no line selected
'   ItemIndex = lvwMainScreen.SelectedItem.Index
'   If Not lvwMainScreen.ListItems(ItemIndex).Selected Then Exit Sub   'Line with focus is NOT highlighted
   ItemIndex = MainLVWSingleSelectedItemIndex()          '27Jun11 CKJ Replaces individual checks
   If ItemIndex = 0 Then Exit Sub
   
   If drugs(ItemIndex).LayoutID < 1 Then Exit Sub '25May06 TH Added
   
   'OK to proceed
   Select Case WardStockPasslvl
      Case 3, 4, 5 '17Oct05 TH (#81967)
         Set WardStockEdit = New FrmWardStockEdit
         WardStockEdit.Caption = "Ward Stock List"
         WardStockEdit.txtDescription = Trim$(drugs(ItemIndex).drugttl)
         WardStockEdit.txtPackSize = Trim$(drugs(ItemIndex).paksize)
         WardStockEdit.txtQuantity = Trim$(drugs(ItemIndex).stklevl)
         WardStockEdit.txtPrintLabel = Trim$(drugs(ItemIndex).prepack)
         dlocal.SisCode = drugs(ItemIndex).catno
         getdrug dlocal, 0, lngFound, False
         If lngFound > 0 Then WardStockEdit.lblUnits.Caption = dlocal.PrintformV
         If WardStockPasslvl = 5 Then
            'Just show prepack
            WardStockEdit.txtDescription.Enabled = False
            WardStockEdit.txtPackSize.Enabled = False
            WardStockEdit.txtQuantity.Enabled = False
         End If
         
         If Trim$(drugs(ItemIndex).catno) = "&" Then     '22May12 TH Added block (DLO)
            WardStockEdit.txtPackSize.Enabled = False
            WardStockEdit.txtQuantity.Enabled = False
            WardStockEdit.txtPrintLabel.Enabled = False
         End If
         
         '22Jun12 TH DLO
         If (TrueFalse(TxtD(dispdata$ & "\winord.ini", "DLO", "N", "AllowDLO", 0)) And (sup.PrintPickTicket = "Y")) Then
            WardStockEdit.lblLabel = "&Label / DLO"
         Else
            WardStockEdit.lblLabel = "Print &Label"
         End If
         
         
         WardStockEdit.Show 1
         
         If WardStockEdit.Tag = "SAVE" Then
            drugs(ItemIndex).drugttl = WardStockEdit.txtDescription
            drugs(ItemIndex).paksize = WardStockEdit.txtPackSize
            drugs(ItemIndex).stklevl = WardStockEdit.txtQuantity
            drugs(ItemIndex).prepack = Trim$(WardStockEdit.txtPrintLabel)
            strTemp = UpdateScreenLine(ItemIndex)
            OInfoStore(ItemIndex) = strTemp
            lngRow = ItemIndex
            RefreshlvwMainScreenRow lngRow, True 'Just Refresh the row in question
            If (WardStockPasslvl <> 5) And (WardStockPasslvl <> 1) Then
               'Update this row in Layout Table
               If Not UpdateLineSQL(drugs(ItemIndex), ward$) Then
                  ''popmessagecr "", "Unable to Save Changes to Database"
                  ''SQL doesn't return ID on update                              '////review
               End If
            End If
         End If
         Unload WardStockEdit             '27Jun11 CKJ Added
         Set WardStockEdit = Nothing
      End Select
   
End Sub


Private Sub lvwMainScreen_KeyDown(KeyCode As Integer, Shift As Integer)
'16Oct97 EAC Add support for the HOME and END key in Ward Stock List
'06Jul11 CKJ Greatly simplified

Dim lngCursor As Long      '27Jun11 CKJ was intCursor as integer
Dim escd As Integer
Dim strAns As String

   If MainLVWMarqueeRowIndex() = 0 Then Exit Sub       'consider if even this is needed; ward stock may need new row if empty & cursor down or PgDn

   ReDim lines$(OTblMaxCols + 1)

   Select Case KeyCode
      Case KEY_RETURN
         KeyCode = 0    '//// uncertain why this is needed
        
      Case KEY_DOWN   '40 'Cursor Down
         Select Case Shift
            Case NO_MASK, SHIFT_MASK
               If TxtInput.Visible Then    'not ward stock
                  '06Jul11 CKJ Removed large amounts of old code, now left with just this to read the next chunk
                  lngCursor = MainLVWMarqueeRowIndex()
                  If lngCursor = lvwMainScreen.ListItems.count Then
                     Printorder True, False
                     MainLVWHighlightSingleRowByIndex lngCursor
                  End If
               Else                      'Ward Stock check if we are at the bottom of the listview. If so we add a line
                  If Shift = NO_MASK Then '27FEb06 TH Added '11Jul11 CKJ corrected, as "If Not SHIFT_MASK Then" was always true
                     If lvwMainScreen.ListItems.count = MainLVWMarqueeRowIndex() Then
                        If WardStockPasslvl <> 1 And WardStockPasslvl <> 2 Then '27Feb06 TH Added ()
                           AskNSVCode strAns, escd, ""
                           If Not escd Then AddLine strAns
                        End If
                     End If
                  End If
               End If
            End Select
            
      Case KEY_PgDn  '34 'PgDn
         If lvwMainScreen.ListItems.count > 0 And TxtInput.Visible Then
            If lvwMainScreen.SelectedItem.Index + OInfoMaxLen > lvwMainScreen.ListItems.count Then
               Printorder True, False '27Jun11 CKJ was False - caused unnecessary redraws        '//// may need to specify line for cursor
               MainLVWHighlightSingleRowByIndex lvwMainScreen.ListItems.count
            End If
         End If

      'Case KEY_F2: TxtInput_KeyUp KEY_F2, Shift '15Jan09 TH (F0042847)  '06Jul11 CKJ removed - already handled in Keyup event
   End Select
    
End Sub

Private Sub lvwMainScreen_KeyPress(KeyAscii As Integer)
'01Jun11 CKJ Removed deprecated BlockMove
Dim lngIndex As Long
Dim lines() As String
Dim Numoflines As Integer

   k.escd = False '07Jun12 TH Added (DLO)
   
   Select Case KeyAscii
      Case 13
         KeyAscii = 0
         If TxtInput.Visible Then
            'Here if amend orders we need to identify DLO lines and warn if one is selected
            If Edittype = 1 Then
'               lngIndex = MainLVWSingleSelectedItemIndex()
'               If lngIndex > 0 Then
'                  ReDim lines(OTblMaxCols + 1)
'                  'A single line is selected - check if DLO or not
'                  deflines OInfoStore(lngIndex), lines$(), "|(*)", 1, Numoflines         '//// ?include next part in the 'IF' ?
'                  If Trim$(lines(10)) <> "" Then
'                     'Question the user
'                     popmessagecr "DLO", "DLO"
'                  End If
'               End If
               'k.escd = DLOOrderLineGridCheck("")
               k.escd = OrderLineGridCheck("")   '13Nov12 TH Replaced
            End If
            
            If Not k.escd Then ProcessDrugLine (TxtInput.text), True    '27Jun11 CKJ Replaces TxtInput_KeyPress -13
         Else            'Wardstock
            WardStockEditLine         '27Jun11 CKJ instead of lvwMainScreen_DblClick
         End If
       
      Case 33 To 126
         If TxtInput.Visible = True Then
            m_blnTxtInputRetainText = True
            TxtInput.SetFocus
            TxtInput.text = Chr(KeyAscii)
            KeyAscii = 0 '07Oct05 stop the bugger sorting and generate extraneous and annoying beeps !!!!
         End If
      Case Else
      End Select

End Sub

Private Sub lvwMainScreen_KeyUp(KeyCode As Integer, Shift As Integer)
'16Oct97 EAC Add support for the HOME and END key in Ward Stock List
'14Jan98 EAC use Shift-F4 menu short cut for a general drug enquiry
'18May98 EAC stop Subscript out of bounds Error
'12Jun98 EAC Barcode issues/returns to be corrected asap, in meantime prevent use
'26Jun98 EAC removed 18May mod that was stopping F5 working on blank table.
'13May99 TH  Now passes correct position to blockmove on F7 in wstock thus should retain correct screenposns
'29May01 TH  Close off F6 option (delete) for wslist lvls < 2
'23Jan02 TH  Include lvl 5 in above mod (#52055)
'27Feb02 TH  Added new parameter to deletelines call (enh1463)
'14Jan10 TH  Added extra clause on suppression of F7 Receive all as the logic was wrong (F0072220)
'11Feb10 TH  Disable delete if there are no rows (F0077289)
'17sep10 TH  Added param to addlinetodisplay and RefreshTblData calls (F0096592)
'11Jun12 TH  DLO Enhancements
'16Jul12 TH  Replaced DLO F7 Msg (TFS 38664)
'10Oct12 TH  Added check to diasble shift-F3 for PSO TFS 41573
'14Nov13 TH  Moved process drug line to allow auto selection of new line (TFS 78314)

Dim tempdrug As drugdetails
Dim Islabel%, IsMarked%, valid%, X%
Dim CurrentRow&, currentline&, BlkStart&, BlkEnd&
Dim intloop As Integer
Dim lclDrug$, lclrecnum&, CurRow&      '//// warning - lcldrug does not appear to be set before use in several cases below
Dim lines$()
Dim Numoflines As Integer
Dim orderptr&
Dim rowline$
Dim drug$
Dim ans$
Dim exitloop As Integer
Dim newitem%
Dim deleteline%
Dim foundPtr&
Dim totalcost!, cost!, temp$, temp1$, anscompare$, CurrentRowPos&
Dim loopvar As Integer
Dim lngOrderID As Long
Dim lngList As Long
Dim intCount As Integer
Dim blnAutoSelect As Boolean
Dim intSelectedloop As Integer
Dim strTemp As String
Dim lngCurrentRow As Long
Dim strDLO As String    '11Jun12 TH DLO
Dim lngLoop As Long     '   "
Dim blnPSO As Boolean   '23Nov12 TH Added


If TxtInput.Visible = False Then             '<<< WARD STOCK ONLY >>>
      If Not WardStockLoaded Then Exit Sub
   
      Select Case KeyCode
         Case KEY_F5, KEY_F11
         Case Else
            currentline = MainLVWMarqueeRowIndex()
            If currentline <= 0 Then Exit Sub                                 'need a current line to work with (not necessarily highlighted though)
            If currentline > UBound(drugs) Then Exit Sub                      '18May98 EAC stop Subscript out of bounds Error
            tempdrug = drugs(currentline&)
            Islabel = (Trim$(drugs(currentline&).catno) = "&")
         End Select
   
      Select Case KeyCode
'         Case 16 'Shift
'         Case 17 'Control
         
         Case KEY_ESCAPE
             '02Jun11 CKJ: ReDim OMarked(1 To ONumToDisplay)
             '02Jun11 CKJ: lvwMainScreen.Refresh
             MainLVWRemoveSelection   '02Jun11 CKJ
         
         'Case KEY_UP      '38 'Cursor Up
         'Case KEY_DOWN    '40 'Cursor Down
         
         Case KEY_F3
            Select Case Shift
               Case NO_MASK  'Ordinary
                  findstr findstring$
               Case SHIFT_MASK
                  findline findstring$, (0)
               End Select
         
         Case KEY_F4
            Select Case Shift
               Case NO_MASK  'Ordinary
                  ODrugInfo$ = drugs(currentline&).catno
                  If Trim$(ODrugInfo$) <> "&" Then
                     k.escd = False 'TH 23Feb05 Added
                     dispdata$ = warddispdata$
                     DisplayDrugEnquiry ODrugInfo$, SiteNumber   ' Removed using DrugInfo.frm as now displayed via ICW desktop F0033906
                     'Load DrugInfo
                     'If Not k.escd Then DrugInfo.Show 1
                     dispdata$ = dispdatastore$
                     'Unload DrugInfo
                  Else
                     popmessagecr "#Sorry", "Cannot display item information for a label."
                  End If
               Case SHIFT_MASK
                  DrugEnquiry
               End Select
         
         Case KEY_F5
             Select Case Shift
                 Case NO_MASK  'Ordinary
                     InsertLine currentline&
                 End Select
         
         Case KEY_F6, KEY_DELETE 'delete line
            Select Case Shift
               Case NO_MASK 'Ordinary
                  If WardStockPasslvl < 2 Or WardStockPasslvl = 5 Then   '23Jan02 TH Added lvl 5 (#52055)
                     popmessagecr "!", "Password Level Insufficient - Cannot delete Ward Stock Lines"  '   "
                  Else
                     CurrentRow& = MainLVWSingleSelectedItemIndex()
                     If CurrentRow Then
                        DeleteLines CurrentRow&, CurrentRow&, 0  '27Feb02 TH added parameter  (enh1463)
                     ElseIf MainLVWAreMultipleSelected Then
                        popmessagecr "!", "Please use Shift+F6 to delete a block of lines" '"Please select one line for deletion"
                     End If
                  End If                                                                              '   "
               Case SHIFT_MASK
                  If WardStockPasslvl < 2 Or WardStockPasslvl = 5 Then   '23Jan02 TH Added lvl 5 (#52055)                                                          '   "
                     popmessagecr "!", "Password Level Insufficient - Cannot delete Ward Stock Lines"  '   "
                  Else                                                                                '   "
                     DimensionBlock BlkStart, BlkEnd, valid
                     If valid Then DeleteLines BlkStart, BlkEnd, 0 '27Feb02 TH added parameter (enh1463)
                  End If                                                                              '   "
                End Select
         
         'Case KEY_F7   no action here
         
         Case KEY_F8 'issues
             Select Case Shift
                 Case NO_MASK 'Ordinary
                     'If Not Islabel Then PrepareIssue 1, tempdrug, 0, currentline&, False       ' dont ask for item
                     'If Not Islabel Then PrepareIssue 1, tempdrug, 0, currentline&, False, False  '01Sep14 TH new param
                     If Not Islabel Then PrepareIssue 1, tempdrug, 0, currentline&, False, False, 0  '28Jan15 TH new param
                     '28Jan15 TH new param
                 Case SHIFT_MASK
                     '12Jun98 EAC Barcodes to be correct asap, in meantime prevent use
                     'popmessagecr "Barcode Issue", "Sorry this facility is not available in this version of the software."
                     'PrepareIssue 3, tempdrug, 0, currentline&        ' ask for item
                     'PrepareIssue 3, tempdrug, False, currentline&, False  '21Oct05 TH Set return flag appropriately '02Apr07 TH Properly this time !
                     'PrepareIssue 3, tempdrug, False, currentline&, False, False  '01Sep14 TH new param
                     PrepareIssue 3, tempdrug, False, currentline&, False, False, 0  '28Jan15 TH new param
             End Select
         
         Case KEY_F9 'Returns
             Select Case Shift
                 Case NO_MASK  'Ordinary
                     'If Not Islabel Then PrepareIssue 1, tempdrug, -1, currentline&, False        ' assume current line
                     'If Not Islabel Then PrepareIssue 1, tempdrug, -1, currentline&, False, False   '01Sep14 TH new param
                     If Not Islabel Then PrepareIssue 1, tempdrug, -1, currentline&, False, False, 0     '28Jan15 TH new param
                 Case SHIFT_MASK
                     '12Jun98 EAC Barcodes to be correct asap, in meantime prevent use
                     'popmessagecr "Barcode Return", "Sorry this facility is not available in this version of the software."
                     'PrepareIssue 3, tempdrug, -1, currentline&, False        ' ask for item
                     'PrepareIssue 3, tempdrug, -1, currentline&, False, False    '01Sep14 TH new param
                     PrepareIssue 3, tempdrug, -1, currentline&, False, False, 0      '28Jan15 TH new param
                End Select
         
         Case KEY_F11
            Select Case Shift
                Case NO_MASK  'Ordinary
                   PopupMenu mnuWSOptions
                End Select
         End Select ' Select KeyCode
           
   Else          '~~~~~~~~~~~~~~~~~~~~~~<<< NON WARD STOCK >>>~~~~~~~~~~~~~~~~~~~~~~'
   
      ReDim lines$(OTblMaxCols + 1)
   
      Select Case KeyCode
         Case KEY_UP, KEY_DOWN, KEY_PgUp, KEY_PgDn, KEY_HOME, KEY_END
            MainScreenSetTextAndPanels Edittype
         
         Case KEY_F2
            Select Case Shift
               Case NO_MASK
                  If Edittype <> -3 Then   '11Feb05 TH Added check on supplementary orders (#77255)
                     If TxtInput.text <> "" Then
                        Select Case Abs(Edittype)
                           Case 1, 4, 6  '(#80456) removed 9 (credit notes) for F2)
                              CheckExitVal (-60), True, lclDrug$, 0
                           Case 5
                              If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "N", "AllSupChangeForReq", 0)) Then CheckExitVal (-60), True, lclDrug$, 0
                           Case 3
                              CheckExitVal (-60), False, lclDrug$, lclrecnum&
                           End Select
                     Else
                        popmessagecr "#", "Please select an item"
                     End If
                  End If
               End Select
           
           Case KEY_F3
               Select Case Shift
                  Case NO_MASK   '06Jul11 CKJ Simplified
                     CurrentRowFurtherInfo
                     
                  Case SHIFT_MASK      '22Apr02 SF added for Minimum Order Value (enh#1555)
                     'If edittype = 1 Then
                     If Edittype = 1 And Not getPSO() Then '10Oct12 TH Added check to diasble shift-F3 for PSO TFS 41573
                        If osite$ = "A" Then
                           popmessagecr "#", "Must be against a specific supplier"
                        Else
                           MinOrderValue osite$, blnAutoSelect
                        End If
                     End If
                  End Select
                   
            Case KEY_F4
               Select Case Shift
                  Case NO_MASK
                     Select Case Abs(Edittype)
                        Case 1, 3, 4, 5, 6, 9
                           If MainLVWSingleSelectedItemIndex() Then
                              If TxtInput.text = "" Then
                                 EnterDrug drug$, "Item Enquiry"
                                 If k.escd Then Exit Sub
                              Else
                                 drug$ = TxtInput.text
                              End If
   
                              ODrugInfo$ = drug$
                              DisplayDrugEnquiry drug$, SiteNumber   ' Removed using DrugInfo.frm as now displayed via ICW desktop F0033906
                              'Load DrugInfo
                              'If Not k.escd Then DrugInfo.Show 1
                              'Unload DrugInfo
                           ElseIf MainLVWAreMultipleSelected() Then
                              popmessagecr "#Item Enquiry", "Cannot display item information with more than one row selected"
                           End If
                        End Select
                        
                   Case SHIFT_MASK
                       '14Jan98 EAC use Shift-F4 menu as default so commented out below
                       'Select Case Abs(Edittype)
                       '    Case 1, 3, 4, 5, 6, 9
                       '       EnterDrug drug$, "Item Enquiry"
                       '        If k.escd Then Exit Sub
                       '        ODrugInfo$ = drug$
                       '        Load DrugInfo
                       '        If Not k.escd Then DrugInfo.Show 1
                       '        Unload DrugInfo
                       '    End Select
                       '---
   
                   End Select
   
            Case KEY_F5
               Select Case Shift
                  Case NO_MASK
                     ActionKeyF5 Edittype   '11Jul11 CKJ was CheckExitVal (-63), True, "", 0
                  End Select
                   
            Case KEY_F6, KEY_DELETE
               Select Case Shift
                  Case NO_MASK, SHIFT_MASK
                     '07Jun12 TH Stop deletes on DLO order lines
                     
                     DeleteMarkedRows Shift
                  End Select
           
            Case KEY_F7
               Select Case Shift
                   Case NO_MASK
                       Select Case Abs(Edittype)
                           Case 1
                              If Edittype = 1 And MnuOrdersAuth.Enabled = True Then  '12Nov98 TH
                                 If osite$ = "A" Then
                                    popmessagecr "!", crlf & "Can selectively order from only one supplier at a time" & crlf & crlf & "            Please select a single supplier first" & crlf
                                    Exit Sub '10Feb99 TH
                                 End If
                                 '23Nov12 TH PSO Suppress this check (PSO also has the field number used as DLO flag (TFS 49877)
                                 If Not getPSO() Then '23Nov12 TH
                                    '11Jun12 TH DLO (now check that all is OK)
                                    strDLO = "**********"
                                    For lngLoop = 1 To MainScreen.lvwMainScreen.ListItems.count    '11Jul11 CKJ corrected logic error - lngLoop was NOT used in the loop & repeated same action every time
   '                                   'If Trim$(UCase$(ord.Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.SelectedItem.Text)) And OMarked(MainScreen.lvwMainScreen.SelectedItem.Index) Then include = True                 '02Jun11 CKJ
   '                                   If Trim$(UCase$(ord.Code)) = Trim$(UCase$(MainScreen.lvwMainScreen.SelectedItem.Text)) And MainLVWIsItemSelected(MainScreen.lvwMainScreen.SelectedItem.Index) Then include = True    '    "
                                       '//// still for review
                                       
                                       If MainLVWIsItemSelected(lngLoop) Then
                                          
                                          deflines OInfoStore(lngLoop), lines$(), "|(*)", 1, Numoflines
                                          If strDLO <> "**********" Then
                                             If strDLO <> lines$(10) Then
                                                'here we have a difference
                                                popmessagecr "", "You cannot selectively order from more than one DLO Ward or for standard and DLO orders combined"
                                                k.escd = True
                                                Exit For
                                             End If
                                          End If
                                          strDLO = lines$(10)
                                          
                                       End If
                                    Next
                                 End If '23Nov12 TH
                                 If Not k.escd Then
                                    ans = "N"
                                    Confirm "?EMIS Health", "Order Selected Items", ans$, k      '12Nov98 TH
                                 End If
                                 blnPSO = getPSO()
                                 If Not k.escd And ans$ = "Y" Then                        '12Nov98 TH
                                    'If sup.method = "D" Or sup.method = "F" Then       '12Nov98 TH
                                    PartsOrder = True                            '12Nov98 TH
                                    Do While Not exitloop                        '12Nov98 TH
                                       'SQL ForgetPrinterList                         '12Nov98 TH
                                       Selectforsupplier 1, SiteNumber, exitloop, blnPSO
                                    Loop                                         '12Nov98 TH
                                    PartsOrder = False                           '12Nov98 TH
                                    'refresh amend screen                        '12Nov98 TH
                                    Edittype = 1                                 '12Nov98 TH
                                    'osite$ = sup.code                            '12Nov98 TH  '14Jan02 TH Removed (#58045)
                                    Screen.MousePointer = HOURGLASS          '12Nov98 TH
                                    'ChangeTable "blank", False  '14Aug12 TH Added Param '17Oct05 TH Added
                                    ChangeTable "blank", blnPSO  '23Nov12 TH use PSO
                                    Clearprintedorders                           '12Nov98 TH
                                    ordernum$ = "A"                              '12Nov98 TH
                                    'DisplayOrders 1, False   '27Jun11 CKJ Removed unused args: ordernum$, , osite$, SiteNumber, "", "", OASCcode$(), ORecNo&(), Oordering$()
                                    DisplayOrders 1, blnPSO   '23Nov12 TH use PSO
                                    'LblGrid.Caption = "Amend Orders to Supplier " & Trim$(osite$)  '13Aug98 SF
                                    LblGrid.Caption = "Amend" & IIf(blnPSO, " Patient Specific", "") & " Orders to Supplier " & Trim$(osite$) '13Aug98 SF
                                    PositionLblGrid                              '12Nov98 TH
                                    lvwMainScreen.SetFocus               '12Nov98 TH
                                    Screen.MousePointer = STDCURSOR          '12Nov98 TH
                                    
'                                    If lvwMainScreen.ListItems.count > 0 Then
'                                       If lvwMainScreen.SelectedItem.Index > 0 Then   '11Jan99 TH
'                                          'If OMarked(lvwMainScreen.SelectedItem.Index) Then lvwMainScreen_mouseup 2, 0, 0, 0    '08Dec98 TH   '02Jun11 CKJ
'                                          If MainLVWIsItemSelected(lvwMainScreen.SelectedItem.Index) Then lvwMainScreenRightClick              '   "
'                                          MainScreenSetTextAndPanels
'                                       End If                                    '11Jan99 TH
'                                    End If
                                    
                                    If MainLVWIsItemSelected(MainLVWMarqueeRowIndex) Then
                                       lvwMainScreenRightClick
                                       MainScreenSetTextAndPanels Edittype
                                    End If
                                    lvwMainScreen.Refresh                                                    '08Dec98 TH
                                    'End If                                          '12Nov98 TH
                                 End If                                                '12Nov98 TH
                                 k.escd = False                                           '12Nov98 TH
                              End If                                                      '12Nov98 TH
                              
                           Case 3, 6
                              If Edittype = 6 Or (Edittype = 3 And Not TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "DisableF7ReceiveAll", 0))) Then '31May09 TH Added (F0041582)'14Jan10 TH Added extra clause cos the logic was wrong (F0072220)
                                 '29Jun12 TH DLO Added check to disable issue all for DLO req.
                                 If Edittype = 6 And ordernum$ <> "A" And GetPickingTicketDLO(Val(ordernum$)) Then
                                    k.escd = True
                                    'popmessagecr "!Direct Location Order", "This is a DLO (Direct Location Order) requisition. Issue all is not allowed for a DLO requestion."
                                    popmessagecr "!Direct Location Order", "Issue all is not allowed for a Direct Location Order (DLO) requisition" '16Jul12 TH Replaced above (TFS 38664)
                                 End If
                                 If Not k.escd Then
                                    If TxtInput.text <> "" Then
                                       CheckExitVal (-65), False, lclDrug$, lclrecnum&
                                       If Not k.escd Then      '23Feb99 TH Do not reinitialise screen if flagged from checkexitval
                                          Clearprintedorders
                                          'printorder 0, False '0, 0, 0, 0, OASCcode$(), ORecNo&()  31Mar04 CKJ {SP1} No params were in use
                                          Printorder 0, getPSO() '16Nov12 TH Added after cancel from multi PSO receipt
                                          MainScreenSetTextAndPanels Edittype
                                       Else                 '   "
                                          k.escd = False    '   "
                                       End If               '   "
                                    Else
                                       popmessagecr "#", "Please select an item"
                                    End If
                                 Else
                                    k.escd = False
                                 End If
                              End If '31May09 TH (F0041582)
                           End Select
                  End Select
           
         Case KEY_F8
            Select Case Shift
               Case NO_MASK
                  Select Case Abs(Edittype)
                     Case 6
                        If TxtInput.text <> "" Then
                           k.exitval = -66         '////
                           drug$ = TxtInput.text
                           Editord drug$, newitem%, deleteline%, 0, 0, False '05Jun08 TH Added param
                           If deleteline% <> -2 Then '26Aug05 TH
                              Clearprintedorders
                              Printorder 0, False '0, 0, 0, 0, OASCcode$(), ORecNo&()  31Mar04 CKJ {SP1} No params were in use
                              MainScreenSetTextAndPanels Edittype
                           End If
                           lvwMainScreen.SetFocus
                        Else
                           popmessagecr "#", "Please select an item"
                        End If
                        
                     Case 1                                                   '19Nov98 TH
                        DisplayTotalOrderCost
                     
                     Case 3                              'Free Receive
                        If entercostonreceipt$ <> "Y" Then                    '26Oct99 AE Only allow receive free using F8 if not using entercostonrecipt
                           freeflag = True                                 '28Jan99 TH
                           ProcessDrugLine (TxtInput.text), False          '27Jun11 CKJ Replaces TxtInput_KeyPress (13)
                           freeflag = False                                '  "
                        End If
                     End Select
                        
               Case SHIFT_MASK
                  Select Case Abs(Edittype)
                     Case 1                              'manual price entry   28Jan99 TH
                        ManualPriceEntry
                     End Select
               End Select
           
         Case KEY_F9
            Select Case Shift
               Case NO_MASK
                  ToggleTradeNames
               End Select
   
         'Case KEY_F10  'NB cannot use as VB grabs this for the menu
         End Select
   End If

   If blnAutoSelect Then
      k.escd = False '03Jun08 TH Added (F0015768/F0015286)
      'First navigate to existing line if one is there
      For intSelectedloop = 1 To lvwMainScreen.ListItems.count
         If Trim$(LCase$(lvwMainScreen.ListItems(intSelectedloop).ListSubItems(1).text)) = Trim$(LCase$(TxtInput.text)) Then
            If MainLVWHighlightSingleRowByIndex(intSelectedloop) Then
               MainScreenSetTextAndPanels Edittype
               'ProcessDrugLine (TxtInput.Text), False       '27Jun11 CKJ Replaces TxtInput_KeyPress 13  'Used to auto populate from MinOrder Routine '17May05 TH
               Exit For
            End If
         End If
      Next
      ProcessDrugLine (TxtInput.text), False  '14Nov13 TH Moved from above to allow auto selection of new line (TFS 78314)
   End If
   
End Sub


Private Sub lvwMainScreen_mouseup(button As Integer, Shift As Integer, X As Single, Y As Single)
'02Jun11 CKJ simplified & deleted old comments

   Select Case button
      Case 1   'left

      Case 2   'right
         lvwMainScreenRightClick       '02Jun11 CKJ simplified
         
      End Select
   
End Sub

Private Sub lvwMainScreenRightClick()
'05Mar98 ASC/EAC section added for sorting true grid display
'05Mar98 CFY Added extra parameter to shell sort.
'26Mar98 CFY/EAC Removed the loop which occurs prior to the shellsort as it sometimes caused an
'                infinite loop to occur. Replaced with code which stops this occuring but now
'                only sorts a screen at a time.
'12Nov98 TH  Right click in Amend screen to order selected items
'02Jun11 CKJ Moved Right-click menu handling to separate procedure.
'            Note it still is driven by global ordernum$, not directly the line clicked

Dim lastordernum$
Dim blnPSO As Boolean  '11Dec12 TH Added

   If WardStockLoaded Then
      PopupMenu mnuWSOptions
   Else
      blnPSO = getPSO()
      Select Case Edittype
         'Case 3:  MainOptions "4", SiteNumber, False
         Case 3:  MainOptions "4", SiteNumber, blnPSO
         'Case -3: MainOptions "12", SiteNumber, False
         Case -3: MainOptions "12", SiteNumber, blnPSO
         
         Case 4, -4
            Select Case Storepasslvl
               Case 4, 5, 8
                  lastordernum$ = ordernum$
                  If Edittype = 4 Then
                     DisplayReconcilInfo blnPSO  '03Sep12 TH Added PSO
                  Else
                     DisplayCreditInfo
                  End If
                  If k.escd Then ordernum$ = lastordernum$
               Case Else
                  nopass
               End Select

         Case 5: MainOptions "5", SiteNumber, blnPSO
         Case 6: MainOptions "7", SiteNumber, blnPSO
         End Select
   End If
   
End Sub

'//// proc not used, but before deletion check that equivalent validation is done in frmWardStockEdit
Private Sub TODO_lvwMainScreen_Validate(Row As Long, Col As Integer, Value As String, Cancel As Integer)
    
Dim found%, Islabel%, loopvar%   '01Jun02 ALL/ATW
    
   Islabel = (Trim$(drugs(Row&).catno) = "&")

   Select Case Col
      Case 1
         'If Not Islabel Then Cancel = True
         Cancel = False
      
      Case 2
         If Islabel Then
            Cancel = True
         Else
            'check for non numeric entry
            For loopvar = 1 To Len(Value$)
               If Not IsAlpha(Mid$(Value$, loopvar, 1)) Then
                  Cancel = True
                  Exit For
               End If
            Next
         End If
      
      Case 3
         If Islabel Then
            Cancel = True
         Else
            Cancel = False
         End If
      
      Case 4  'Print Label field
         If Islabel Then
            Cancel = True
         Else
            If Trim$(Value$) = "" Or Trim$(UCase$(Value$)) = "P" Or Trim$(UCase$(Value$)) = "B" Then
               Cancel = False
               Value$ = UCase$(Value$)
            Else
               popmessagecr "ERROR", "Please type ""P"",""B"" or nothing in this field"
               Cancel = True
            End If
         End If
      
      Case 5 'NSVCode
         Select Case WardStockPasslvl
            Case 3, 4
               If Trim$(Value$) = "&" Then
                  found = True
               Else
                  dispdata$ = warddispdata$
                  findrdrug Value$, 1, d, 0, found, False, False, False 'foundptr%, found%, False  '01Jun02 ALL/ATW
                  dispdata$ = dispdatastore$
                  Value$ = d.SisCode
               End If
         
               If Not found Then
                  Cancel = True
               Else
                  Cancel = False
               End If
            Case Else
               Cancel = False
         End Select
            
      Case Else
         Cancel = False
      End Select

   If Cancel Then
       Cancel = False                  'This is necessary: if cancel = true then grid stays in edit mode which we don't want.
       ''lvwMainScreen.Modified = False
       ''lvwMainScreen.EditActive = False
   End If
   
End Sub

Private Sub TxtInput_GotFocus()
'11Feb99 TH  Added TxtInput update for credit confirmation screen
'11Jul11 CKJ Used MainScreenSetTextAndPanels for convenience
'            - original did not set panels, just text box

   If Not TxtInput.Visible Then Exit Sub
   
   If m_blnTxtInputRetainText Then
      m_blnTxtInputRetainText = False
      TxtInput.SelStart = 1
   Else
      MainScreenSetTextAndPanels Edittype
   End If

End Sub

Private Sub TxtInput_KeyDown(KeyCode As Integer, Shift As Integer)

'28Oct97 EAC Added code to eat INSERT,DELETE,HOME and END key presses

Dim dummy%
Dim intline As Integer
Dim rowline$, Numoflines As Integer, lngOrderID As Long

   If lvwMainScreen.ListItems.count > 0 Then
      If lvwMainScreen.SelectedItem.Index > ONumToDisplay Then Exit Sub       '//// unclear if this is still necessary
   End If
                                   
   Select Case KeyCode
      '28Oct97 EAC
      Case KEY_INSERT    '27Jun11 CKJ Simplified, removed  KEY_DELETE, KEY_END, KEY_HOME
          KeyCode = 0     'eat keystrokes
      
      Case 32 'Space
         'Select Case Shift
            'Case 0  'Ordinary
            'Case SHIFT_MASK
               '27Jun11 CKJ Removed. Setting txtInput = "Code" not used. May need alternative kbd way of toggling highlight
         'End Select
      
      Case 34
         KeyCode = 0
         lvwMainScreen.SetFocus
         SendKeys "{PGDN}"
         
      Case 34 'PG UP
          KeyCode = 0
          lvwMainScreen.SetFocus
          SendKeys "{PGUP}"
      
      Case 38 'Up arrow
         If Not MainLVWHighlightSingleRowByIndex(MainLVWMarqueeRowIndex() - 1) Then   '27Jun11 CKJ Try highlighting row above, otherwise
            MainLVWHighlightSingleRowByIndex 1                                        '            try first row (will fail if no rows present)
         End If
         MainScreenSetTextAndPanels Edittype
         lvwMainScreen.SetFocus
      
      Case 40 'down arrow
         If Not MainLVWHighlightSingleRowByIndex(MainLVWMarqueeRowIndex() + 1) Then   '27Jun11 CKJ Similar to above
            MainLVWHighlightSingleRowByIndex 1
         End If
         MainScreenSetTextAndPanels Edittype
         lvwMainScreen.SetFocus
      End Select

End Sub

Private Sub TxtInput_KeyPress(KeyAscii As Integer)
'27Jun11 CKJ Split out the active code, to allow rationalisation of this area to begin
'            Originally was called directly from code with KeyAscii of 13 or -13, where
'            negative was a flag to indicate it was called from the listview via code
'            and not from the normal event. Removed all such calls.
'21Feb13 TH  Added fencepost around array (TFS 51949,52608)

Dim blnFromlstView As Boolean   '11Dec12 TH Added
Dim lines$()
Dim Numoflines As Integer

   k.escd = False '07Jun12 TH Added DLO
   blnFromlstView = False  '11Dec12 TH Added
   
   If KeyAscii = 13 Then   'Enter key
      KeyAscii = 0
      'If edittype = 1 Then k.escd = DLOOrderLineGridCheck(TxtInput.Text)       '07Jun12 TH Added DLO
      If Edittype = 1 Then k.escd = OrderLineGridCheck(TxtInput.text)       '13Nov12 TH Replaced
      If Not k.escd Then
         'for receipts if the code in the input box matches that on the active line of the listview
         'then assume this should find that line, so assume this is essentially driven from the
         'lstview
         '11Dec12 TH Added block
         If Edittype = 3 And ONumToDisplay > 0 Then '21Feb13 TH Added fencepost around array (TFS 51949,52608)
            ReDim lines$(OTblMaxCols + 1)
            deflines OInfoStore(MainScreen.lvwMainScreen.SelectedItem.Index), lines$(), "|(*)", 1, Numoflines  '   "       for the same item on the same order for the same supplier, and
            If UCase$(Trim$(TxtInput.text)) = UCase$(Trim$(lines$(OTblMaxCols + 1))) Then blnFromlstView = True
         End If
         '-----
         
         'ProcessDrugLine (TxtInput.Text), False
         ProcessDrugLine (TxtInput.text), blnFromlstView '11Dec12 TH Replaced above
      End If
   End If
         
End Sub

Private Sub ProcessDrugLine(drug As String, blnFromListView As Boolean)
'12jan98 EAC timing problem with using rowindex property of truegrid use LastRowIndex& instead
'29Jan98 EAC Having set order number in the program update LastRowIndex& to match
'            item position in new screen
'12Feb98 EAC Added check to prevent update when item has been added for different supplier and no items on this suppliers screen
'05May98 CKJ removed dim paydate$ as not used here
'16Jan02 TH  Added screen refresh to allow for possible change of supplier on line edit (#51913)
'17sep10 TH  Added param to addlinetodisplay and RefreshTblData calls (F0096592)
'27Jun11 CKJ Was TxtInput_KeyPress(KeyAscii As Integer) but ONLY for Return key (13)
'            Split from the txt event to allow it to be simplified
'            Params:
'            drug                exits if blank for edittype 3,-3,4,-4,6
'            blnFromListView     set true if called from ListView, else leave as false
'16Jul12 TH  Added checks to ensure correct rows highlighted with DLO and None DLO lines in the amend screen. (TFS 38657)
'26Sep12 TH  Added fencepost to DLO check to stop when no line selected (i.e. new)(TFS 45129)
'15Sep15 TH  Ensure PSO partial invoices (per order) are handled correctly (TFS 127187)

'TODO: '////
' Needs careful review - it appears to be driven by the drug param, but is heavily dependent on the listview
' - consider which is the master, whether checks are needed for the highlighted line &/or the text box
'   being the same as the code passed in, whether the current line is actually selected, and whether multiply
'   selected lines should abort any action.

Dim newitem%, errored%, Numoflines%, partorder%
Dim LastRowIndex&, orderpointer&
Dim StoredOrdNum$             '29Jan98 EAC
Dim intSelected As Integer
Dim lngLoop As Long
Dim strTemp As String
Dim strNSVCode As String
Dim lngLoop2 As Long
Dim blnFound As Boolean
Dim blnItemFound As Boolean
Dim lngLocalWOrderID As Long
Dim blnDLO As Boolean '16Jul12 TH Added
Dim dlcl As DrugParameters   '08Jan13 TH Added
Dim intFound As Integer      '    "
Dim strDesc  As String       '    "

   ReDim lines$(OTblMaxCols + 1)

   LastRowIndex& = MainLVWMarqueeRowIndex
      
   k.exitval = 13
   k.escd = False
   
   If (Abs(Edittype) = 3 Or Abs(Edittype) = 4 Or Edittype = 6) And (Trim$(drug$) = "") Then Exit Sub
   
   Select Case Edittype
      Case -3
         AddToOrder drug$, SiteNumber
         If Not k.escd Then Clearprintedorders
      Case -4, 4
         '22May05 TH Addded section
         If Len(TxtInput.text) = 7 And Not blnFromListView Then         'using txtinput, search the grid & highlight first matching row
            If Trim$(LCase$(TxtInput.text)) <> Trim$(LCase$(lvwMainScreen.SelectedItem.text)) Then
               For lngLoop = 1 To lvwMainScreen.ListItems.count
                  If Trim$(LCase$(lvwMainScreen.ListItems(lngLoop).text)) = Trim$(LCase$(TxtInput.text)) Then
                     MainLVWRemoveSelection
                     MainLVWHighlightSingleRowByIndex lngLoop
                     blnItemFound = True '17Oct05 TH added
                     Exit For
                  End If
               Next
               
               If Not blnItemFound Then      '17Oct05 TH added section
                  popmessagecr "!Reconciliation", TxtInput.text & "  does not correspond to any item code on the current " & Iff(Edittype = 4, "invoice", "credit note")
                  Exit Sub
               End If
            End If
         ElseIf Not blnFromListView Then  '08Jan13 TH we are doing a search driven from the input box
            'first do the drug search
            
            'now search the item - we assume it is on the list as the user has refined the page to only one order here
            If Trim$(TxtInput.text) = "" Then  '02Oct06 TH Added to prevent BNF search firing (as there is no BNF search anymore) (SC-06-0768)
               blnFound = 0            '   "
            Else                       '   "
               dlcl.Code = TxtInput.text '???
               findrdrug (TxtInput.text), True, dlcl, 0, intFound, 0, False, False
            End If                     '   "
            If intFound <> 0 Then
               If Trim$(LCase$(dlcl.SisCode)) <> Trim$(LCase$(lvwMainScreen.SelectedItem.text)) Then
                  blnItemFound = False
                  For lngLoop = 1 To lvwMainScreen.ListItems.count
                     If Trim$(LCase$(lvwMainScreen.ListItems(lngLoop).text)) = Trim$(LCase$(TxtInput.text)) Then
                        MainLVWRemoveSelection
                        MainLVWHighlightSingleRowByIndex lngLoop
                        blnItemFound = True '17Oct05 TH added
                        Exit For
                     End If
                  Next
                  
                  If Not blnItemFound Then      '17Oct05 TH added section
                     'strDesc = dlcl.storesdescription          XN 4Jun15 98073 New local stores description
                     'If Trim$(strDesc) = "" Then strDesc = dlcl.Description
                                         strDesc = dlcl.DrugDescription
                     plingparse strDesc, "!"
                     popmessagecr "!Reconciliation", dlcl.SisCode & " - " & Trim$(strDesc) & " does not correspond to any item code on the current " & Iff(Edittype = 4, "invoice", "credit note")
                     Exit Sub
                  End If
               End If
            Else
               popmessagecr "!Reconciliation", "Item Not Found"
               Exit Sub
            End If
         End If
         '22May05 TH ---------
         
         FinEditOrd
         If Not k.escd Then
            Clearprintedorders
''                  If lvwMainScreen.ListItems.count = 0 Then
''                     TxtInput.Text = ""
''                  Else
''                     deflines OInfoStore(1), lines$(), "|(*)", 1, numoflines
''                     TxtInput.SelStart = 0
''                     TxtInput.Text = lines$(1)
''                     TxtInput.SelLength = Len(TxtInput.Text)
''                  End If
         End If
         
      Case Else
         errored = False
         If UCase$(osite$) = "A" And Edittype <> 1 And Edittype <> 3 And Edittype <> 4 And Edittype <> 6 And Edittype <> 9 Then
            popmessagecr "!n!iABORTING", "To enter new orders the site must be entered"
            errored = True
         End If
         
         If UCase$(ordernum$) = "A" And Edittype <> 1 And Edittype <> 3 And Edittype <> 4 And Edittype <> 9 Then
            '!!** Picking ticket number not always right since picking tickets not looked for just nsvcodes
            If Edittype = 6 Then
                  popmessagecr "!n!iABORTING", "Picking ticket number must be entered" ', for this item  =" + STR$(ord.pickno)
                  errored = True
               Else
                  popmessagecr "!n!iABORTING", "To enter new orders the requisition number must be entered"
                  errored = True
               End If
            k.escd = True
         End If
                  
         If Not errored Then
            intSelected = 0
            If lvwMainScreen.ListItems.count > 0 And Edittype = 3 Then
               For lngLoop = 1 To lvwMainScreen.ListItems.count
                  If lvwMainScreen.ListItems(lngLoop).Selected Then intSelected = intSelected + 1
                  If intSelected > 1 Then Exit For
               Next
            End If
            If intSelected > 1 Then
               popmessagecr "", "Can only receive from one line at a time"
            Else
               StoredOrdNum$ = ordernum$
               If UCase$(osite$) = "A" And (Edittype = 3 Or Edittype = 1) And Len(drug$) = 7 Then
                  If lvwMainScreen.ListItems.count > 0 Then LastRowIndex& = lvwMainScreen.SelectedItem.Index
                  If LastRowIndex& > 0 Then deflines OInfoStore(LastRowIndex&), lines$(), "|(*)", 1, Numoflines         '//// ?include next part in the 'IF' ?
                  If drug$ = lines$(1) Then
                     drug$ = drug$ & Chr(160) & lines$(OTblMaxCols + 1)
                  End If
                  If Edittype = 3 And drug$ = d.SisCode Then '02Mar05 TH
                  'If Edittype = 3 And drug$ = ord.Code Then '11Dec12 TH
                     drug$ = drug$ & Chr(160) & lines$(OTblMaxCols + 1)          '//// why add another block - should this be 'OR' ?
                  End If
               ElseIf UCase$(osite$) <> "A" And Edittype = 1 And Len(drug$) = 7 Then '16Jul12 TH Added section to ensure correct highlighting after addition
                  'Capture DLO
                  If lvwMainScreen.ListItems.count > 0 Then    '26Sep12 TH (TFS 45129)
                     deflines OInfoStore(lvwMainScreen.SelectedItem.Index), lines$(), "|(*)", 1, Numoflines
                     blnDLO = Len(Trim$(lines$(10))) > 0
                  Else                                         '26Sep12 TH (TFS 45129)
                     blnDLO = False                            '  "
                  End If                                       '  "
               End If
               'Editord drug$, newitem%, partorder%, lngLocalWOrderID, ord.num '05Jun08 TH Added param to tighten receipt on order selected (F0015293)
               'Editord drug$, newitem%, partorder%, lngLocalWOrderID, Val(ord.num) '05Jun08 TH Added param to tighten receipt on order selected (F0015293)'09Jun08 TH added val (as ord.num may be null here)
               Editord drug$, newitem%, partorder%, lngLocalWOrderID, Val(ord.num), blnFromListView '11Dec12 TH Added Param
               '25Jul97 EAC - no longer needed
               If Len(drug$) > 7 Then drug$ = Left$(drug$, 7) '10Nov05 TH
               If newitem = 2 Then                                  '16Jan02 TH Added to allow for possible change of supplier  (#51913)
                  If Not k.escd Then '07Oct04 TH Added
                     OrderStartPos& = 0
                     ReDim OInfoStore(1 To 1)                       '   "
                     ONumToDisplay = 0                              '   "
                     If lvwMainScreen.ListItems.count > 0 Then LastRowIndex& = lvwMainScreen.SelectedItem.Index
                     Clearprintedorders
                     'printorder 0, False '0, 0, 0, 0, OASCcode$(), ORecNo&()   31Mar04 CKJ {SP1} No params were in use
                     Printorder 0, getPSO() '21Aug12 TH Added PSO
                  End If
               End If
            End If
            '---
         Else
            k.escd = True
         End If
      End Select
      
   'TxtInput.Text = ""
   If Not k.escd Then
      '12Jan98 EAC seem to have a timing problem where RowIndex is zero
      'CurRow& = Me.lvwMainScreen.RowIndex
      'If CurRow& > 0 Then deflines OInfoStore(CurRow&), lines$(), "|(*)", 1, numoflines
      '29Jan98 EAC
''               If StoredOrdNum$ <> ordernum$ Then
''                     If lvwMainScreen.ListItems.count > 0 Then
''                        LastRowIndex& = lvwMainScreen.SelectedItem.Index
''                     Else
''                        LastRowIndex& = 0
''                     End If
''                  End If
      '---
      'If lvwMainScreen.ListItems.count > 0 Then  'v93
      'LastRowIndex& = lvwMainScreen.SelectedItem.Index
      If LastRowIndex& > lvwMainScreen.ListItems.count Then LastRowIndex& = lvwMainScreen.ListItems.count
      If LastRowIndex& > 0 Then deflines OInfoStore(LastRowIndex&), lines$(), "|(*)", 1, Numoflines
            '//// looks like it should use lines$() here
      'End If                                               'v93
      '---

      Select Case Edittype
         Case 3, 6               '27Jun11 CKJ removed -20, as it is not a valid edittype
            If partorder Then
               '13Feb07 TH Use the returned drug$ to pilot to the right row
'''                           For intloop = 1 To lvwMainScreen.ListItems.count
'''                                 If lvwMainScreen.ListItems(intloop).Text = drug$ Then
'''                                    lvwMainScreen.ListItems(intloop).Selected = True
'''                                    lvwMainScreen.FullRowSelect = intloop
'''                                    lvwMainScreen.ListItems(intloop).EnsureVisible
'''                                    OMarked(intloop) = True
'''                                 End If
'''                              Next

               orderpointer& = Val(lines$(OTblMaxCols + 1))    '//// too removed from line selection code
                  
               '13Feb07 TH Added
               If (lngLocalWOrderID <> orderpointer&) And (lngLocalWOrderID > 0) Then
                  'then we need to navigate the grid
                  For lngLoop = 1 To lvwMainScreen.ListItems.count
                     deflines OInfoStore(lngLoop), lines$(), "|(*)", 1, Numoflines
                     If lngLocalWOrderID = Val(lines$(OTblMaxCols + 1)) Then
                        orderpointer& = lngLocalWOrderID
                        lvwMainScreen.ListItems(lngLoop).Selected = True
                        '11Jul11 CKJ lvwMainScreen.FullRowSelect = intloop
                        lvwMainScreen.ListItems(lngLoop).EnsureVisible
                        LastRowIndex& = lngLoop
                        '02Jun11 CKJ: OMarked(intloop) = True
                        getorder ord, lngLocalWOrderID, Edittype%, False         '//// Why? It's in a tight loop and will be overwritten
                        UpdatePanels ord, Abs(Edittype)                          '////
                     Else
                        lvwMainScreen.ListItems(lngLoop).Selected = False
                        '02Jun11 CKJ: OMarked(intloop) = False
                     End If
                  Next
               End If
               '13Feb07 TH --------
                     
               '12Jan98 EAC timing problem using current RowIndex
               'AddLineToDisplay edittype%, orderpointer&, 0, CurRow&
               'AddLineToDisplay edittype%, orderpointer&, 0, LastRowIndex&, sup.ptn, False '17sep10 TH Added param (F0096592)
               AddLineToDisplay Edittype%, orderpointer&, 0, LastRowIndex&, sup.ptn, getPSO() '17sep10 TH Added param (F0096592)
               'Me.lvwMainScreen.RefreshRow = CurRow&
               ''Me.lvwMainScreen.SelectedItem = LastRowIndex&
               RefreshlvwMainScreenRow LastRowIndex&, False
               lvwMainScreen.ListItems(LastRowIndex&).Selected = True
               '02Jun11 CKJ: OMarked(LastRowIndex&) = True '13Feb07 TH
               lvwMainScreen.SetFocus
               '---
               
            Else     'Whole order
               '''SQL RemoveLineFromDisplay
               Clearprintedorders
               'printorder 0, False '0, 0, 0, 0, OASCcode$(), ORecNo&()    31Mar04 CKJ {SP1} No params were in use
               Printorder 0, getPSO() '21Aug12 TH Added PSO
''                           If lvwMainScreen.ListItems.count <> 0 Then 'V93
''                              If lvwMainScreen.SelectedItem.Index > lvwMainScreen.ListItems.count Then lvwMainScreen.SelectedItem = lvwMainScreen.ListItems.count
''                              If LastRowIndex& > lvwMainScreen.ListItems.count Then LastRowIndex& = lvwMainScreen.ListItems.count
''                              If lvwMainScreen.SelectedItem.Index = 0 And lvwMainScreen.ListItems.count > 0 Then lvwMainScreen.SelectedItem = LastRowIndex&
''
''                              ''If newitem Then lvwMainScreen.FullRowSelect = lvwMainScreen.ListItems.count
''                           End If 'V93
               '''RefreshlvwMainScreen newitem
               
               '11Jul06 TH Added section to retain screen position if possible
               'If (LastRowIndex& > 0) And (lvwMainScreen.ListItems.count >= LastRowIndex&) Then '25Aug05 TH (#)
                  'MainLVWRemoveSelection                                         '//// why cancel all highlighting?
                  'lvwMainScreen.ListItems(LastRowIndex&).Selected = True
                  'lvwMainScreen.FullRowSelect = LastRowIndex&
                  'lvwMainScreen.ListItems(LastRowIndex&).EnsureVisible
                  '02Jun11 CKJ: OMarked(LastRowIndex&) = True
               'End If
               MainLVWHighlightSingleRowByIndex LastRowIndex
               MainScreenSetTextAndPanels Edittype
               lvwMainScreen.SetFocus
            End If
                  
         Case 1, 5, 9, 10, -3 '25Nov98 TH
            If Edittype = -3 Or Edittype = 9 Then newitem = True '13Nov05 TH Added 9
            If newitem Then
               If newitem = 2 Then           '03Jun08 TH Added
                  strNSVCode = ""            '     "
               Else                          '     "
                  strNSVCode = d.SisCode
               End If                        '     "
               Clearprintedorders  '19May05 TH Added
               Printorder 0, False '0, 0, 0, 0, OASCcode$(), ORecNo&()    31Mar04 CKJ {SP1} No params were in use
               If lvwMainScreen.ListItems.count > 0 Then 'V93
                  If LastRowIndex& > lvwMainScreen.ListItems.count Then LastRowIndex& = lvwMainScreen.ListItems.count
                  If lvwMainScreen.SelectedItem.Index = 0 Then lvwMainScreen.SelectedItem = LastRowIndex&         '////
                  If (Edittype = -3) Or (Edittype = 9) Then lvwMainScreen.ListItems(lvwMainScreen.ListItems.count).Selected = True
               End If 'V93
                     
               'deflines OInfoStore(lvwMainScreen.SelectedItem.index), lines$(), "|(*)", 1, numoflines
               'orderpointer& = Val(lines$(OTblMaxCols + 1))
               ''''' getorder ord, Val(lines$(OTblMaxCols + 1)), 1, 0
               'getorder ord, orderpointer&, edittype, 0
               If osite$ <> "A" And TrueFalse(TxtD$(dispdata$ & "\Winord.ini", "Defaults", "Y", "OrderValuetoHeap", 0)) Then
                  strTemp = CalculateWOrderValue(osite$)
                  Heap 10, gPRNheapID, "TotalOrderValue", strTemp, 0
               Else
                  Heap 10, gPRNheapID, "TotalOrderValue", "", 0 '31May05 TH (#80783)
               End If
               
               If newitem And lvwMainScreen.ListItems.count > 0 Then
                  MainLVWRemoveSelection     'unselect everything first
                  'If strNSVCode <> "" And TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "N", "OrderAmendbyDescription", 0)) Then
                  'If strNSVCode <> "" Then '03Jun08 TH Removed above (F0015768/F0015286)
                  If strNSVCode <> "" And Not blnDLO Then '03Jun08 TH Removed above (F0015768/F0015286)
                  
                     For lngLoop = 1 To lvwMainScreen.ListItems.count
                        If lvwMainScreen.ListItems(lngLoop).text = strNSVCode Then
                           If Edittype = 1 Then  '16Jul12 TH Added to stop inappropriate multi-select now that this screen can support multiple drug lines (TFS 38657)
                              deflines OInfoStore(lngLoop), lines$(), "|(*)", 1, Numoflines
                              blnDLO = Len(Trim$(lines$(10))) > 0
                           Else
                              blnDLO = False
                           End If
                           If Not blnDLO Then '16Jul12 TH Utilise above check (TFS 38657)
                              lvwMainScreen.ListItems(lngLoop).Selected = True                     '//// almost but not quite same as common code block
                              '11Jul11 CKJ lvwMainScreen.FullRowSelect = intloop
                              lvwMainScreen.ListItems(lngLoop).EnsureVisible
                              '02Jun11 CKJ: OMarked(intloop) = True
                              '''MainLVWHighlightSingleRowByIndex lngLoop
                              ord.Code = strNSVCode '03Jun08 TH Added (F0015768/F0015286)
                           End If
                        End If
                     Next
                  Else
                     'lvwMainScreen.ListItems(lvwMainScreen.ListItems.count).Selected = True
                     '11Jul11 CKJ lvwMainScreen.FullRowSelect = lvwMainScreen.ListItems.count
                     'lvwMainScreen.ListItems(lvwMainScreen.ListItems.count).EnsureVisible
                     MainLVWHighlightSingleRowByIndex lvwMainScreen.ListItems.count             '//// may be better leaving no row highlighted?
                  End If
               End If
               
               MainScreenSetTextAndPanels Edittype
               
            Else
               If ONumToDisplay > 0 Then    '12Feb98 EAC Added to prevent update when item has been added for different supplier and no items on this suppliers screen
                  '03Jun08 TH Added to refresh the screen properly if we have edited an existing line (F0015768/F0015286)
                  If (lngLocalWOrderID <> orderpointer&) And (lngLocalWOrderID > 0) Then
                     'then we need to navigate the grid
                     For lngLoop = 1 To lvwMainScreen.ListItems.count
                        deflines OInfoStore(lngLoop), lines$(), "|(*)", 1, Numoflines
                        If lngLocalWOrderID = Val(lines$(OTblMaxCols + 1)) Then
                           orderpointer& = lngLocalWOrderID
                           lvwMainScreen.ListItems(lngLoop).Selected = True
                           '11Jul11 CKJ lvwMainScreen.FullRowSelect = intloop
                           lvwMainScreen.ListItems(lngLoop).EnsureVisible
                           LastRowIndex& = lngLoop
                           '02Jun11 CKJ: OMarked(intloop) = True
                           getorder ord, lngLocalWOrderID, Edittype%, False
                           TxtInput.text = ord.Code
                        Else
                           lvwMainScreen.ListItems(lngLoop).Selected = False
                           '02Jun11 CKJ: OMarked(intloop) = False
                        End If
                     Next
                  Else
                     '13Feb07 TH --------
                     orderpointer& = Val(lines$(OTblMaxCols + 1))
                     '12Jan98 EAC timing problem using current RowIndex
                     'AddLineToDisplay edittype%, orderpointer&, 0, CurRow&
                     getorder ord, orderpointer&, 1, 0
                  End If
                  If osite$ <> "A" And TrueFalse(TxtD$(dispdata$ & "\Winord.ini", "Defaults", "Y", "OrderValuetoHeap", 0)) Then
                     strTemp = CalculateWOrderValue(osite$)
                     Heap 10, gPRNheapID, "TotalOrderValue", strTemp, 0
                  End If
                  UpdatePanels ord, Abs(Edittype) '02Dec04 TH
                  AddLineToDisplay Edittype%, orderpointer&, 0, LastRowIndex&, sup.ptn, False '17sep10 TH Added param (F0096592)
                  If Not newitem Then
                     RefreshlvwMainScreenRow LastRowIndex&, False
                  Else
                     RefreshLVWMainScreen newitem, False
                  End If
                  'Me.lvwMainScreen.FullRowSelect = LastRowIndex&
                  '''Me.lvwMainScreen.ListItems.item(LastRowIndex&).selected = True
                  If LastRowIndex& > 1 And lvwMainScreen.ListItems.count > 0 Then
                     lvwMainScreen.ListItems(1).Selected = False
                     '02Jun11 CKJ: OMarked(1) = False
                     lvwMainScreen.ListItems(LastRowIndex&).Selected = True
                     '02Jun11 CKJ: OMarked(CInt(LastRowIndex&)) = True
                  End If
                  ''OMarked(intLoop)
                  lvwMainScreen.SetFocus
                  '---
               End If
            End If
            
         Case Else
            'printorder 0, False '0, 0, 0, 0, OASCcode$(), ORecNo&()  31Mar04 CKJ {SP1} No params were in use    '11Jul11 CKJ Why add 60 more lines here?  '////
            Printorder 0, getPSO() '15Sep15 TH Ensure PSO partial invoices (per order) are handled correctly (TFS 127187)
            lvwMainScreen.SetFocus
            MainScreenSetTextAndPanels Edittype                            '11Jul11 CKJ use line which has the focus
         End Select

   Else
      If lvwMainScreen.ListItems.count > 0 Then
         'If LastRowIndex& > lvwMainScreen.ListItems.count Then LastRowIndex& = lvwMainScreen.ListItems.count
         '11Jul11 CKJ lvwMainScreen.FullRowSelect = LastRowIndex&
         MainLVWHighlightSingleRowByIndex LastRowIndex
         MainScreenSetTextAndPanels Edittype
         lvwMainScreen.SetFocus
      Else
         TxtInput.text = ""
      End If
   End If

End Sub

Private Sub TxtInput_KeyUp(KeyCode As Integer, Shift As Integer)
'11Feb10 TH (F0077298) Removed F2 set qty functionality from supplementary order screen.
'17sep10 TH  Added param to addlinetodisplay and RefreshTblData calls (F0096592)
'01Jun11 CKJ Removed unused static SavedPageNo and ArrowKeyPressed
'27Jun11 CKJ Simplified. KEY_DELETE (46) was in the list 3 times

Dim ord As orderstruct
Dim CurrentRowPos&, orderptr&
Dim rowline$, drug$, lclDrug$
Dim Numoflines%, newitem%
Dim deleteline%, loopvar%
Dim lclrecnum&, CurRow&
Dim ans$, exitloop%, X%, totalcost!, cost!, temp$  '16Nov98 TH Added  '05jan99 CKJ changed cost% to cost! '01Jun02 ALL/ATW
Dim temp1$  '27Jan99 TH
Dim anscompare$  '01Feb99 TH
Dim lngOrderID As Long

Dim foundPtr As Long   '01Jun02 ALL/ATW
Dim blnAutoSelect As Boolean  '17May05 TH Added

'each KeyCode may require one or more of...
   'Case SHIFT_MASK
   '   Case NO_MASK
   '   Case SHIFT_MASK
   '   Case CTRL_MASK
   '   Case ALT_MASK

   ReDim lines$(OTblMaxCols + 1)

   Select Case KeyCode
      Case 9 'Tab
         lvwMainScreen.SetFocus
      
      Case KEY_INSERT     '27Jun11 CKJ Removed , KEY_DELETE, KEY_END, KEY_HOME - these should be allowed to be used (no insert/overwrite support though)
         KeyCode = 0     'eat keystrokes
      
'      Case 32 'Space
'          Select Case Shift
'              'Case NO_MASK  'Ordinary
'              Case SHIFT_MASK
'                  If Abs(edittype) = 4 Then    '27Jun11 CKJ Removed
'                      KeyCode = 0
'                      TxtInput.Text = lvwMainScreen.ListItems.Item(lvwMainScreen.SelectedItem.Index).Text
'                      TxtInput.SelStart = 0
'                      TxtInput.SelLength = Len(TxtInput.Text)
'                  End If
'          End Select
      'Case 38 'Up arrow
      'Case 40 'down arrow
      'Case 33 'PgUp
      'Case 34 'PgDn
      'Case KEY_DELETE '46
      'Case KEY_F1
      
      Case KEY_F2
         Select Case Shift
            Case NO_MASK
               If TxtInput.text <> "" Then
                  Select Case Abs(Edittype)
                     Case 1, 4, 6, 9
                        CheckExitVal (-60), True, lclDrug$, 0
                     Case 5
                        If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "N", "AllSupChangeForReq", 0)) Then CheckExitVal (-60), True, lclDrug$, 0
                     Case 3
                        If Edittype <> -3 Then    '11Feb10 TH (F0077298)
                           CheckExitVal (-60), False, lclDrug$, lclrecnum&
                        End If
                     End Select
               Else
                   popmessagecr "#", "Please select an item"
               End If

         End Select
      
      Case KEY_F3
         Select Case Shift
            Case NO_MASK   '06Jul11 CKJ Simplified
               CurrentRowFurtherInfo
                            
            Case SHIFT_MASK                        '22Apr02 SF added for Minimum Order Value (enh#1555)
               If Edittype = 1 Then
                  If osite$ <> "A" Then
                     MinOrderValue osite$, blnAutoSelect
                  Else
                     popmessagecr "#", "Must be against a specific supplier"
                  End If
               End If
               
            End Select
      
      Case KEY_F4
         Select Case Shift
            Case NO_MASK
               Select Case Abs(Edittype)
                  Case 1, 3, 4, 5, 6, 9
                     If TxtInput.text = "" Then
                         EnterDrug drug$, "Item Enquiry"
                         If k.escd Then Exit Sub
                     Else
                         drug$ = TxtInput.text
                     End If

                     ODrugInfo$ = drug$
                     DisplayDrugEnquiry drug$, SiteNumber        ' Removed using DrugInfo.frm as now displayed via ICW desktop F0033906
                     'Load DrugInfo
                     'If Not k.escd Then DrugInfo.Show 1
                     'Unload DrugInfo
                  End Select
                
              Case SHIFT_MASK
                  '14Jan98 EAC use Shift-F4 menu as default so commented out below
                  'Select Case Abs(Edittype)
                  '    Case 1, 3, 4, 5, 6, 9
                  '       EnterDrug drug$, "Item Enquiry"
                  '        If k.escd Then Exit Sub
                  '        ODrugInfo$ = drug$
                  '        Load DrugInfo
                  '        If Not k.escd Then DrugInfo.Show 1
                  '        Unload DrugInfo
                  '    End Select
                  '---

              End Select

      Case KEY_F5
         Select Case Shift
            Case NO_MASK
               ActionKeyF5 Edittype   '11Jul11 CKJ was CheckExitVal (-63), True, "", 0
            End Select
      
      Case KEY_F6
         Select Case Shift
            Case NO_MASK, SHIFT_MASK
               DeleteMarkedRows Shift
            End Select
            
      Case KEY_F7
         Select Case Shift
            Case NO_MASK
               Select Case Abs(Edittype)
                  Case 1
                     If Edittype = 1 And MnuOrdersAuth.Enabled = True Then  '12Nov98 TH
                        If osite$ = "A" Then popmessagecr "", "Can Only Selectively order from One supplier at a time": Exit Sub '10Feb99 TH
                        Confirm "?EMIS Health", "Order Selected Items", ans$, k      '12Nov98 TH
                        If Not k.escd And ans$ = "Y" Then                        '12Nov98 TH
                           'If sup.method = "D" Or sup.method = "F" Then       '12Nov98 TH
                           PartsOrder = True                            '12Nov98 TH
                           Do While Not exitloop                        '12Nov98 TH
                              ' ForgetPrinterList                         '12Nov98 TH
                              Selectforsupplier 1, SiteNumber, exitloop, getPSO()
                           Loop                                         '12Nov98 TH
                           PartsOrder = False                           '12Nov98 TH
                           'refresh amend screen                        '12Nov98 TH
                           'osite$ = sup.code                            '12Nov98 TH  '14Jan02 TH Removed (#58045)
                           Screen.MousePointer = HOURGLASS          '12Nov98 TH
                           Clearprintedorders                           '12Nov98 TH
                           ordernum$ = "A"                              '12Nov98 TH
                           DisplayOrders 1, False   '27Jun11 CKJ Removed unused args: ordernum$, , osite$, SiteNumber, "", "", OASCcode$(), ORecNo&(), Oordering$()
                           LblGrid.Caption = "Amend Orders to Supplier " & Trim$(osite$)  '13Aug98 SF
                           PositionLblGrid                              '12Nov98 TH
                           lvwMainScreen.SetFocus               '12Nov98 TH
                           Screen.MousePointer = STDCURSOR          '12Nov98 TH
                           'If OMarked(lvwMainScreen.SelectedItem.Index) Then lvwMainScreen_mouseup 2, 0, 0, 0    '08Dec98 TH   '02Jun11 CKJ
                           If MainLVWIsItemSelected(MainLVWMarqueeRowIndex) Then lvwMainScreenRightClick        '11Jul11 CKJ simplified  '//// to test
                           lvwMainScreen.Refresh                                                    '08Dec98 TH
                        End If                                                '12Nov98 TH
                        k.escd = False                                           '12Nov98 TH
                     End If                                                      '12Nov98 TH
                         
                  Case 3, 6
                     If Edittype = 6 Or TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "DisableF7ReceiveAll", 0)) Then '31May09 TH Added (F0041582)
                        If TxtInput.text <> "" Then
                           CheckExitVal (-65), False, lclDrug$, lclrecnum&
                           If Not k.escd Then      '23Feb99 TH Do not reinitialise screen if flagged from checkexitval
                              Clearprintedorders
                              Printorder 0, False '0, 0, 0, 0, OASCcode$(), ORecNo&()  31Mar04 CKJ {SP1} No params were in use
                              MainScreenSetTextAndPanels Edittype
                           Else                 '   "
                              k.escd = False    '   "
                           End If               '   "
                        Else
                            popmessagecr "#", "Please select an item"
                        End If
                     End If
                              
                  End Select
            End Select
      
      Case KEY_F8
         Select Case Shift
            Case NO_MASK
               Select Case Abs(Edittype)
                  Case 6
                     If TxtInput.text <> "" Then
                        k.exitval = -66
                        drug$ = TxtInput.text
                        Editord drug$, newitem%, deleteline%, 0, 0, False '05Jun08 TH Added param
                        Clearprintedorders
                        Printorder 0, False '0, 0, 0, 0, OASCcode$(), ORecNo&()  31Mar04 CKJ {SP1} No params were in use
                            
                     Else
                         popmessagecr "#", "Please select an item"
                     End If
                      
                  Case 1
                     DisplayTotalOrderCost

                  Case 3                         'Free Receive
                     If entercostonreceipt$ <> "Y" Then                   '26Oct99 AE Only allow receive free using F8 if not using entercostonrecipt
                        freeflag = True                                '28Jan99 TH
                        ProcessDrugLine (TxtInput.text), False         '27Jun11 CKJ Replaces TxtInput_KeyPress (13)
                        freeflag = False                               '  "
                     End If
                  End Select
                      
            Case SHIFT_MASK
               Select Case Abs(Edittype)
                  Case 1
                     ManualPriceEntry
                  End Select
            End Select
      
      Case KEY_F9
         Select Case Shift
            Case NO_MASK
               ToggleTradeNames
            End Select

      'Case KEY_F10  'NB cannot use as VB grabs this for the menu
      End Select

   k.escd = False
   If blnAutoSelect Then TxtInput_KeyDown 13, 0 'Used to auto populate from MinOrder Routine '17May05 TH    '////  should not call event directly
   
 End Sub
 
 Sub ToggleTradeNames()
 '11Jul11 CKJ Moved here to avoid duplication.
 
 Dim CurrentRowPos As Long
 Dim blnCrednote As Boolean

   If Edittype = -4 Then               '10Jan02 TH TH Added to allow tradename toggle for Confirmation notes (#49091)
         blnCrednote = True            '   "
         Edittype = Abs(Edittype)      '   "
      End If                           '   "
   
   Select Case Edittype
      Case 1, 3, 4, 9
         Screen.MousePointer = HOURGLASS
         OPrintTradeNames = Not OPrintTradeNames
         If OPrintTradeNames Then
               '''LblHelpPrompt.Segment = LblHelpPrompt.Segments - 1              '//// why is this not updated?
               '''LblHelpPrompt.SegCaption = "F9 Display Drug Descriptions"
           Else
               '''LblHelpPrompt.Segment = LblHelpPrompt.Segments - 1
               '''LblHelpPrompt.SegCaption = "F9 Display TradeNames"
           End If
        CurrentRowPos = MainLVWMarqueeRowIndex()
        RefreshTblData sup.ptn '17sep10 TH Added param (F0096592)
        RefreshLVWMainScreen False, False
        Screen.MousePointer = STDCURSOR
        MainLVWHighlightSingleRowByIndex CurrentRowPos
      End Select
   
   If blnCrednote Then Edittype = -4   '10Jan02 TH Added
   
 End Sub
 
 Private Sub findlineMenu()
   findline findstring$, (0)
 End Sub
 
Private Sub CurrentRowFurtherInfo()
'06Jul11 CKJ Replaced four calls with this.

Dim lngCurrentRow As Long
Dim lclrecnum As Long
Dim lclDrug As String
Dim Numoflines As Integer
Dim udt_ord As orderstruct
Dim lines() As String

   ReDim lines(OTblMaxCols + 1) As String
   lngCurrentRow = MainLVWSingleSelectedItemIndex()
   If lngCurrentRow Then
      Select Case Abs(Edittype)
         Case 1, 3, 4, 5, 6, 9
            deflines (OInfoStore(lngCurrentRow)), lines$(), "|(*)", 1, Numoflines
            lclrecnum& = Val(lines$(OTblMaxCols + 1))
            getorder udt_ord, lclrecnum&, Edittype, False
            lclDrug$ = Trim$(udt_ord.Code)
            If Len(Trim$(lclDrug$)) Then
               furtherinfo Edittype, udt_ord
            Else
               popmessagecr "#", "Please select an item"
            End If
         End Select
   ElseIf MainLVWAreMultipleSelected() Then
      popmessagecr "#Information", "Cannot display information with more than one row selected"
   End If

End Sub

Sub DisplayTotalOrderCost()
'06Jul11 CKJ Centralised to avoid duplication
'            Uses global osite and sup
'08Jun12 TH  Overhauled to allow for DLO "Layering"
Dim temp As String

   If osite$ <> "A" Then
      temp$ = CalculateWOrderValueDLO(osite$)
      If Val(sup.discountval) <> 0 Then                    '20Jan99 TH
         temp$ = temp$ & crlf & crlf & "Discount level is        " & TB & money(5) & Trim$(sup.discountval)  '20Jan99 TH
      End If                                            '20Jan99 TH
      popmessagecr "#", Trim$(temp$)   '21Jan99 TH
   Else
      popmessagecr "!", "Total cost only available for orders to single suppliers"
   End If

End Sub

Sub ManualPriceEntry()
'06Jul11 CKJ Centralised to avoid duplication
'            Version from listview has extra checks, works in £ not pence, and puts value on the heap. Version from txtinput binned.
'11Jul11 CKJ

Dim foundPtr As Long
Dim temp1 As String
Dim temp As String
Dim rowline As String
Dim Numoflines As Integer
Dim lclrecnum As Long
Dim ans As String
Dim anscompare As String
Dim loopvar As Integer
Dim SelectedRow As Long
Dim title As String

   title = "#Information"
   If MainLVWAreMultipleSelected Then
      popmessagecr title, "Cannot enter price with more than one row selected"
   Else
      If sup.Method = "D" Or sup.Method = "F" Or (sup.Method = "E" And TrueFalse(TxtD(dispdata$ & "\winord.ini", "defaults", "N", "EDIEnterPrice", 0))) Then  '11Jan02 TH Added ini switch to allow manual entry for Electronic Orders (#54468)
         SelectedRow = MainLVWSingleSelectedItemIndex()
         If SelectedRow > 0 Then
            BlankWProduct d
            d.SisCode = Trim$(lvwMainScreen.ListItems.Item(SelectedRow).text)
            If osite$ <> "A" Then                                        '           Ord.supcode not correct here
               getdrugsup d, 0, foundPtr&, False, osite$                  '           must be osite$ if applicable '01Jun02 ALL/ATW
            Else
               getdrug d, 0, foundPtr&, False   '01Jun02 ALL/ATW
            End If
            
            If foundPtr& Then
               'temp1$ = Trim$(d.Description)  XN 4Jun15 98073 New local stores description
               'If Trim$(d.storesdescription) <> "" Then temp1$ = Trim$(d.storesdescription)
                           temp1$ = Trim$(d.DrugDescription)
               replace temp1$, "!", " ", 0
               temp$ = "Enter New Cost For " & temp1$
               If Trim$(d.convfact) <> "" Then
                  temp$ = temp$ & "  1 x " & Trim$(d.convfact) & " " & Trim$(d.PrintformV)
               End If
               
               'temp$ = temp$ & "  (" & Trim$(d.siscode) & ")"                              '26Jul99 TH Replaced with below
               'temp$ = temp$ & crlf & crlf & "  (" & Trim$(d.SisCode) & ") in " & money(4)  '   "
               ''temp$ = temp$ & crlf & crlf & "  (" & Trim$(d.SisCode) & ")    in " & money(2)  '01May05 TH
               
               rowline$ = OInfoStore(SelectedRow)
               ReDim lines$(OTblMaxCols + 1)
               deflines rowline$, lines$(), "|(*)", 1, Numoflines        '27Jun11 CKJ added (*)
               lclrecnum& = Val(lines$(OTblMaxCols + 1))
               getorder ord, lclrecnum&, Edittype, False
               If ord.pflag = "M" Then
                  ans$ = Str$(Format(Val(ord.cost), "#.00"))
               Else
                  If Trim$(d.contprice) <> "" Then
                     ans$ = Format(Val(d.contprice), "#.00")
                  ElseIf Trim$(d.sislistprice) <> "" And UCase$(Trim$(d.sisstock)) = "N" Then
                     ans$ = Format(Val(d.sislistprice), "#.00")
                  Else
                     ans$ = Format(Val(d.cost), "#.00")
                  End If
               End If
            End If
            
            ''SQLans$ = Format(Val(ans$), "0.00")
            ''ans$ = Format(Val(ans$), "0.00")
            ans$ = Format(Val(ans$) / 100, "0.00")
            temp$ = temp$ & crlf & crlf & "  ( Current price for 1 x " & Trim$(d.convfact) & " " & Trim$(d.PrintformV) & "  =  " & money(5) & " " & ans$ & " )" '21Jul05 TH (#81574)
      
            Unload frmEnhTxtWin
                                                            
            frmEnhTxtWin.txtBox.Left = 400
            frmEnhTxtWin.txtBox = ans$
            frmEnhTxtWin.Caption = "Manual order price entry   (" & Trim$(d.SisCode) & ")"
            frmEnhTxtWin.lblbox.Caption = temp$ & crlf & crlf & crlf & crlf & " " & money(5)
            frmEnhTxtWin.txtBox.SelStart = 0
            frmEnhTxtWin.txtBox.SelLength = Len(frmEnhTxtWin.txtBox)
            frmEnhTxtWin.txtBox.Width = Int(frmEnhTxtWin.txtBox.Width / 1.5) '01May05 TH
            HorizCentreForm frmEnhTxtWin
            frmEnhTxtWin.txtBox.Top = (frmEnhTxtWin.lblExtra.Top + 350)
            anscompare$ = ans$
            k.escd = False    '08Mar02 TH (#56352,54364)
            k.Max = 20        '   "
            k.nums = True     '   "
            k.decimals = True '   "
      
            frmEnhTxtWin.txtBox.Tag = "2sigfigs" '16Oct05 TH Crude masking (#81782)
            ShowFrmEnhTxtWin                   '08Mar02 TH Use new wrapper (#56352,54364)
            frmEnhTxtWin.txtBox.Tag = "" '16Oct05 TH Clean up
            ans$ = Trim$(frmEnhTxtWin.txtBox)
            If Val(Trim$(ans$)) < 0 Then                                           '19Feb99 TH  Check to stop -ve prices in manual entry
               popmessagecr "", "Cannot Order Items For Less Than 0 " & money(6)   '  "
               k.escd = True
            End If                                                                 '  "
                                       
            'If Not gk.escd And Val(Trim$(ans$)) <> Val(Trim$(anscompare$)) Then   '01Feb99 TH Replaced
            'If Not gk.escd And Val(Trim$(ans$)) <> Val(Trim$(anscompare$)) And Trim$(ans$) <> "" Then  '22Feb99 TH Replaced
            If Not k.escd And Val(Trim$(ans$)) <> Val(Trim$(anscompare$)) And Trim$(ans$) <> "" Then  '08Mar02 TH Replaced kbd ref (#56352,54364)
               ans$ = Format$(Val(ans$) * 100) '01May05 TH Added
            
               rowline$ = OInfoStore(SelectedRow)
               deflines rowline$, lines$(), "|(*)", 1, Numoflines    '27Jun11 CKJ added (*)
               lclrecnum& = Val(lines$(OTblMaxCols + 1))
               getorder ord, lclrecnum&, Edittype, True
               ord.pflag = "M"
               ord.cost = Str$(Val(ans$))
               lclrecnum& = PutOrder(ord, lclrecnum&, "WOrder")
               If Val(Trim$(ans$)) = 0 Then  '23Feb99 TH
                  lines$(8) = "F"         '   "
               Else                       '   "
                  lines$(8) = "M"
               End If                     '   "
               OInfoStore(SelectedRow) = lines$(1)
               For loopvar = 2 To OTblMaxCols + 1
                  OInfoStore(SelectedRow) = OInfoStore(SelectedRow) & "|" & lines$(loopvar) '//// caution if we change the array composition
               Next
               
               RefreshLVWMainScreen False, False
               If Edittype = 1 And osite$ <> "A" And TrueFalse(TxtD$(dispdata$ & "\Winord.ini", "Defaults", "Y", "OrderValuetoHeap", 0)) Then
                  Heap 10, gPRNheapID, "TotalOrderValue", CalculateWOrderValue(osite$), 0
               End If
               UpdatePanels ord, Abs(Edittype)
            End If
            Unload frmEnhTxtWin
         Else
            popmessagecr title, "Please select a single row for manual price entry"
         End If
      Else
         If UCase$(osite$) = "A" Then
            popmessagecr title, "Please select a specific supplier for manual price entry"
         Else
            popmessagecr title, "Manual price entry not allowed for this supplier method"
         End If
      End If
   End If

End Sub

Sub DeleteMarkedRows(ByVal Shift As Integer)
'11Jul11 CKJ replaces separate (non-identical) copies of code. Now consistent with ward stock
'            F6 or Del deletes one row, but warns if multiple rows are selecetd
'            shift-F6 or shift-Del deletes any number of highlighted rows, after confirmation
'            No message for deleting just one row, otherwise confirm first
'07Jun12 TH  Stop DLO deletion
'15Nov12 TH  Reversed this checking as PSO was being caught by the wider DLO check (TFS 49055)
   
Dim lngCurrentRow As Long
Dim lngLoop As Long
Dim multiple As Boolean
Dim ans As String
Dim strAns As String
Dim strMsg As String

   Select Case Edittype     'don't try to delete supplementary orders
      Case 1, 3, 5, 6, 9
         If MainLVWAreAnySelected() Then    '11Feb10 TH there is nothing there to delete (F0077289)
            ans = "Y"
            k.escd = False
            
            lngCurrentRow = MainLVWMarqueeRowIndex()       'current row may not be highlighted
            multiple = MainLVWAreMultipleSelected()
            If multiple And Shift <> SHIFT_MASK Then
               popmessagecr "#Delete", "Please use Shift-F6 to delete multiple rows"
               ans = "N"
            ElseIf multiple Then
               ans = "N"
               askwin "?Delete Multiple Rows", "Are you sure you want to delete all highlighted rows?", ans$, k
            Else
               If Not lvwMainScreen.ListItems(lngCurrentRow).Selected Then       'single item has to be highlighted and current
                  ans = "N"
                  popmessagecr "#Delete Row", "Current row must be highlighted before it can be deleted"
               End If
            End If
            
            If ans = "Y" And Not k.escd Then
               ReDim lines$(OTblMaxCols + 1)
               If multiple Then
                  For lngLoop = 1 To lvwMainScreen.ListItems.count
                     If lvwMainScreen.ListItems(lngLoop).Selected Then
                        deflines OInfoStore(lngLoop), lines$(), "|(*)", 1, 0
                        '07Jun12 TH DLO
                        k.escd = False
                        If Edittype = 1 And Trim$(lines$(10)) <> "" Then
                           If TrueFalse(TxtD(dispdata$ & "\winord.ini", "DLO", "N", "AllowDLOOrderLineDelete", 0)) Then
                              strAns = "N"
                              strMsg = "A Direct Order Location (DLO) Line should not be deleted. If you continue you could prevent this ward supply" & crlf & _
                              "Are you sure you wish to continue?"
                              askwin "?EMIS Health", TxtD(dispdata$ & "\Winord.ini", "DLO", strMsg, "DeleteDLOOrderQuestion", 0), strAns, k
                              If strAns = "N" Then k.escd = True
                           Else
                              popmessagecr "!EMIS Health", "A Direct Order Location (DLO) Line can not be deleted"
                              k.escd = True
                           End If
                        ElseIf Edittype = 1 And getPSO() Then '15Nov12 TH (TFS 49097)
                           If TrueFalse(TxtD(dispdata$ & "\winord.ini", "PSO", "N", "AllowPSOOrderLineDelete", 0)) Then
                              strAns = "N"
                              strMsg = "A Patient Specific Order (PSO) Line should not be deleted. If you continue you could prevent this patient supply" & crlf & _
                              "Are you sure you wish to continue?"
                              askwin "?EMIS Health", TxtD(dispdata$ & "\Winord.ini", "PSO", strMsg, "DeletePSOOrderQuestion", 0), strAns, k
                              If strAns = "N" Then k.escd = True
                           Else
                              popmessagecr "!EMIS Health", "A Patient Specific Order (PSO) Line can not be deleted"
                              k.escd = True
                           End If
                        End If
                        
                        If Not k.escd Then DeleteSingleRow Val(lines$(OTblMaxCols + 1)), lines$(1)  '11Jul11 CKJ replaces   CheckExitVal (-64), True, lcldrug$, 0
                     End If
                  Next
               Else     'just current row on its own
                  deflines OInfoStore(lngCurrentRow), lines$(), "|(*)", 1, 0
                  '07Jun12 TH Stop DLO deletion '15Nov12 TH Reversed this checking as PSO was being caught by the wider DLO check (TFS 49055)
                  If Edittype = 1 And getPSO() Then
                     If TrueFalse(TxtD(dispdata$ & "\winord.ini", "PSO", "N", "AllowPSOOrderLineDelete", 0)) Then
                        strAns = "N"
                        strMsg = "A Patient Specific Order (PSO) Line should not be deleted. If you continue you could prevent this patient supply" & crlf & _
                        "Are you sure you wish to continue?"
                        askwin "?EMIS Health", TxtD(dispdata$ & "\Winord.ini", "PSO", strMsg, "DeletePSOOrderQuestion", 0), strAns, k
                        If strAns = "N" Then k.escd = True
                     Else
                        popmessagecr "!EMIS Health", "A Patient Specific Order (PSO) Line can not be deleted"
                        k.escd = True
                     End If
                  ElseIf Edittype = 1 And Trim$(lines$(10)) <> "" Then
                     If TrueFalse(TxtD(dispdata$ & "\winord.ini", "DLO", "N", "AllowDLOOrderLineDelete", 0)) Then
                        strAns = "N"
                        strMsg = "A Direct Order Location (DLO) Line should not be deleted. If you continue you could prevent this ward supply" & crlf & _
                        "Are you sure you wish to continue?"
                        askwin "?EMIS Health", TxtD(dispdata$ & "\Winord.ini", "DLO", strMsg, "DeleteDLOOrderQuestion", 0), strAns, k
                        If strAns = "N" Then k.escd = True
                     Else
                        popmessagecr "!EMIS Health", "A Direct Order Location (DLO) Line can not be deleted"
                        k.escd = True
                     End If
                  End If
                  If Not k.escd Then DeleteSingleRow Val(lines$(OTblMaxCols + 1)), lines$(1)
               End If
               
               OrderStartPos& = 0      'reload screen from fresh
               ReDim OInfoStore(1 To 1)
               ONumToDisplay = 0
               'printorder 0, False '0, 0, 0, 0, OASCcode$(), ORecNo&()  31Mar04 CKJ {SP1} No params were in use
               Printorder 0, getPSO() '22Aug12 TH PSO Added as this can be in PSO mode now (should you be able to delete these ?
               
               MainLVWHighlightSingleRowByIndex lngCurrentRow       'safe even if this row doesn't exist anymore
               MainScreenSetTextAndPanels Edittype
            End If
         Else
            popmessagecr "#Delete Row", "Please select an item"
         End If
         
   Case 4
      popmessagecr "!Invoice Reconciliation", "You cannot delete items ready for Reconciliation"
   Case -4
      popmessagecr "!Credit Note Confirmation", "You cannot delete items ready for Confirmation"
   End Select
   
End Sub

Function OrderLineGridCheck(ByVal strCode As String) As Boolean
'13Nov12 TH Changed name of function so as to encompass PSO as well as DLO
'           THe way of identifying a DLO line is a bit provisional
'           if the order grid is expanded again this probably will need review

Dim lngIndex As Long
Dim lines() As String
Dim blnResult As Boolean
Dim strMsg As String
Dim strAns As String
Dim Numoflines As Integer
   If getPSO() Then
      popmessagecr "!EMIS Health Patient Specific Ordering", "You cannot alter a Patient Specific Order line."
      blnResult = True
   Else
      blnResult = False
      lngIndex = MainLVWSingleSelectedItemIndex()
      If lngIndex > 0 Then
         ReDim lines(OTblMaxCols + 1)
         'A single line is selected - check if DLO or not
         deflines OInfoStore(lngIndex), lines$(), "|(*)", 1, Numoflines         '//// ?include next part in the 'IF' ?
         If Trim$(lines(10)) <> "" Then
            If strCode = "" Or (strCode <> "" And strCode = lines$(1)) Then
               'Question the user
               
               If osite$ = "A" Or getPSO() Then  '13Jun12 TH DLO Added after testing from Ken '13Nov12 TH Cannot edit PSO
                  
                  popmessagecr "!EMIS Health", "You cannot alter a DLO line from the amend all orders page. If you wish to order this item please do so with a specific supplier."
                  blnResult = True
               Else
                  strAns = "Y"
                  strMsg = "A Direct Order Location (DLO) Line is selected. You cannot alter a DLO line. If you continue you can only add or edit a none DLO order" & crlf & _
                  "Do you wish to continue?"
                  askwin "?EMIS Health", TxtD(dispdata$ & "\Winord.ini", "DLO", strMsg, "AmendDLOOrderQuestion", 0), strAns, k
                  If strAns = "N" Or k.escd Then
                     blnResult = True
                  End If
               End If
            End If
         End If
      End If
   End If
   OrderLineGridCheck = blnResult
   
End Function

