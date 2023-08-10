VERSION 5.00
Begin VB.Form frmVA 
   Appearance      =   0  'Flat
   BackColor       =   &H00C0C0C0&
   Caption         =   "View/Adjust Regimen"
   ClientHeight    =   8430
   ClientLeft      =   0
   ClientTop       =   570
   ClientWidth     =   12000
   ClipControls    =   0   'False
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
   Icon            =   "VIEWADJ.frx":0000
   LinkTopic       =   "Form1"
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   8430
   ScaleWidth      =   12000
   Begin VB.CommandButton cmdVA 
      Appearance      =   0  'Flat
      Height          =   325
      Index           =   6
      Left            =   9600
      TabIndex        =   10
      Top             =   0
      Width           =   1575
   End
   Begin VB.PictureBox F3D1 
      Appearance      =   0  'Flat
      ForeColor       =   &H80000008&
      Height          =   510
      Left            =   0
      ScaleHeight     =   480
      ScaleWidth      =   11955
      TabIndex        =   1
      Top             =   6210
      Width           =   11985
   End
   Begin VB.PictureBox F3D2 
      Appearance      =   0  'Flat
      ForeColor       =   &H80000008&
      Height          =   510
      Left            =   0
      ScaleHeight     =   480
      ScaleWidth      =   11460
      TabIndex        =   7
      Top             =   5715
      Width           =   11490
   End
   Begin VB.PictureBox CMDialog1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   480
      Left            =   9945
      ScaleHeight     =   450
      ScaleWidth      =   1170
      TabIndex        =   11
      Top             =   2610
      Width           =   1200
   End
   Begin VB.PictureBox tgdVA 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   5265
      Left            =   0
      ScaleHeight     =   5235
      ScaleWidth      =   9585
      TabIndex        =   0
      Top             =   360
      Width           =   9615
   End
   Begin VB.CommandButton cmdVA 
      Appearance      =   0  'Flat
      Height          =   325
      Index           =   5
      Left            =   8040
      TabIndex        =   9
      Top             =   0
      Width           =   1575
   End
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   510
      Left            =   11475
      Picture         =   "VIEWADJ.frx":030A
      ScaleHeight     =   32
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   32
      TabIndex        =   8
      TabStop         =   0   'False
      Top             =   5715
      Width           =   510
   End
   Begin VB.PictureBox MhTimer1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Enabled         =   0   'False
      ForeColor       =   &H80000008&
      Height          =   420
      Left            =   9000
      ScaleHeight     =   390
      ScaleWidth      =   390
      TabIndex        =   12
      Top             =   5160
      Width           =   420
   End
   Begin VB.CommandButton cmdVA 
      Appearance      =   0  'Flat
      Height          =   325
      Index           =   4
      Left            =   6480
      TabIndex        =   6
      Top             =   0
      Width           =   1575
   End
   Begin VB.CommandButton cmdVA 
      Appearance      =   0  'Flat
      Height          =   330
      Index           =   3
      Left            =   4860
      TabIndex        =   5
      Top             =   0
      Width           =   1635
   End
   Begin VB.CommandButton cmdVA 
      Appearance      =   0  'Flat
      Height          =   330
      Index           =   2
      Left            =   3120
      TabIndex        =   4
      Top             =   0
      Width           =   1755
   End
   Begin VB.CommandButton cmdVA 
      Appearance      =   0  'Flat
      Height          =   325
      Index           =   1
      Left            =   1560
      TabIndex        =   3
      Top             =   0
      Width           =   1575
   End
   Begin VB.CommandButton cmdVA 
      Appearance      =   0  'Flat
      Height          =   330
      Index           =   0
      Left            =   0
      TabIndex        =   2
      Top             =   0
      Width           =   1575
   End
   Begin VB.Image Image1 
      Appearance      =   0  'Flat
      BorderStyle     =   1  'Fixed Single
      Enabled         =   0   'False
      Height          =   510
      Index           =   0
      Left            =   10485
      Picture         =   "VIEWADJ.frx":0614
      Top             =   3285
      Visible         =   0   'False
      Width           =   510
   End
   Begin VB.Image Image1 
      Appearance      =   0  'Flat
      BorderStyle     =   1  'Fixed Single
      Enabled         =   0   'False
      Height          =   510
      Index           =   1
      Left            =   9945
      Picture         =   "VIEWADJ.frx":091E
      Top             =   3285
      Visible         =   0   'False
      Width           =   510
   End
   Begin VB.Menu mnuFile 
      Caption         =   "&File"
      Begin VB.Menu mnuSave 
         Caption         =   "&Save"
      End
      Begin VB.Menu mnuAuth 
         Caption         =   "&Authorise"
      End
      Begin VB.Menu mnuSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuPrintSetup 
         Caption         =   "P&rint Setup"
      End
      Begin VB.Menu mnuPrnOpts 
         Caption         =   "Print &Options ..."
      End
      Begin VB.Menu mnuPrint 
         Caption         =   "&Print"
         Begin VB.Menu mnuWSheet 
            Caption         =   "Worksheet"
         End
         Begin VB.Menu mnuScript 
            Caption         =   "Prescription"
         End
         Begin VB.Menu mnuNotes 
            Caption         =   "Insert for Notes"
         End
         Begin VB.Menu mnuLabels 
            Caption         =   "Labels"
         End
         Begin VB.Menu mnuInvoice 
            Caption         =   "Invoice"
         End
         Begin VB.Menu mnuBaxa 
            Caption         =   "Authorise Baxa File"
            Enabled         =   0   'False
         End
      End
      Begin VB.Menu mnuSep2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuExit 
         Caption         =   "E&xit"
         Shortcut        =   ^X
      End
   End
   Begin VB.Menu mnuEdit 
      Caption         =   "&Edit"
      Begin VB.Menu mnuClinDet 
         Caption         =   "&Clinical Details"
      End
      Begin VB.Menu menuPrescription 
         Caption         =   "&Prescription"
      End
      Begin VB.Menu mnuStdReg 
         Caption         =   "&Standard Regimen"
         Shortcut        =   ^R
      End
      Begin VB.Menu menuRegimenDetails 
         Caption         =   "&Regimen Details"
      End
      Begin VB.Menu mnuSep4 
         Caption         =   "-"
      End
      Begin VB.Menu mnuAddmls 
         Caption         =   "&Add by ml Product"
         Shortcut        =   ^A
      End
      Begin VB.Menu mnuAddP 
         Caption         =   "Add by &Product"
         Shortcut        =   ^P
      End
      Begin VB.Menu mnuAddI 
         Caption         =   "Add by &Ingredient"
         Shortcut        =   ^I
      End
      Begin VB.Menu mnuVol 
         Caption         =   "&Volume"
         Shortcut        =   ^V
      End
      Begin VB.Menu mnuCals 
         Caption         =   "&Calories"
         Shortcut        =   ^C
      End
      Begin VB.Menu ScaleRegimen 
         Caption         =   "&Multiply by Factor"
         Shortcut        =   ^M
      End
      Begin VB.Menu mnuReplace 
         Caption         =   "&Replace Product"
      End
      Begin VB.Menu mnuSep5 
         Caption         =   "-"
      End
      Begin VB.Menu mnuAddEnteral 
         Caption         =   "Add Enteral Product"
      End
      Begin VB.Menu mnuInfusion 
         Caption         =   "Add Other Infusion Product"
      End
      Begin VB.Menu mnuSep3 
         Caption         =   "-"
      End
      Begin VB.Menu mnuDel 
         Caption         =   "&Delete Product"
         Shortcut        =   ^D
      End
      Begin VB.Menu mnuNew 
         Caption         =   "&New Regimen"
         Index           =   1
         Shortcut        =   ^N
      End
      Begin VB.Menu mnuNew 
         Caption         =   "Remove Enteral Products"
         Index           =   2
      End
      Begin VB.Menu mnuNew 
         Caption         =   "Remove Other Infusions"
         Index           =   3
      End
   End
   Begin VB.Menu mnuSpecial 
      Caption         =   "&Special"
      Begin VB.Menu mnuGlucose 
         Caption         =   "Glucose by Rate"
         Enabled         =   0   'False
         Index           =   1
         Shortcut        =   ^G
         Visible         =   0   'False
      End
      Begin VB.Menu mnuGlucose 
         Caption         =   "Glucose by Percentage"
         Index           =   2
      End
      Begin VB.Menu mnuSep9 
         Caption         =   "-"
      End
      Begin VB.Menu mnuOverage 
         Caption         =   "Aqueous overage to given volume"
         Index           =   1
      End
      Begin VB.Menu mnuOverage 
         Caption         =   "Lipid overage to given volume"
         Index           =   2
      End
   End
   Begin VB.Menu mnuView 
      Caption         =   "&View"
      Begin VB.Menu mnuUnit 
         Caption         =   "Show &Units"
         Shortcut        =   ^U
      End
      Begin VB.Menu mnuTips 
         Caption         =   "Show &Tips"
         Shortcut        =   ^T
      End
      Begin VB.Menu mnuShowConfig 
         Caption         =   "Show Configuration"
      End
      Begin VB.Menu mnuSep8 
         Caption         =   "-"
      End
      Begin VB.Menu mnuScriptInfo 
         Caption         =   "&Prescription Summary"
      End
      Begin VB.Menu mnuInfo 
         Caption         =   "&Clinical Summary"
         Shortcut        =   ^S
      End
      Begin VB.Menu mnuRegInfo 
         Caption         =   "&Regimen Summary"
      End
      Begin VB.Menu mnuWeight 
         Caption         =   "&Weight of Products"
         Shortcut        =   ^W
      End
      Begin VB.Menu mnuSep6 
         Caption         =   "-"
      End
      Begin VB.Menu mnuElec 
         Caption         =   "&Electrolytes"
         Shortcut        =   ^E
      End
   End
   Begin VB.Menu mnuIssue 
      Caption         =   "&Issue"
      Begin VB.Menu mnuIss 
         Caption         =   "&Issue regimen"
      End
      Begin VB.Menu mnuRet 
         Caption         =   "&Return regimen"
      End
   End
   Begin VB.Menu mnuHlp 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelp 
         Caption         =   "&Contents      F1"
      End
      Begin VB.Menu mnuHelpSch 
         Caption         =   "&Search for Help on ..."
      End
      Begin VB.Menu mnuHelpOnHelp 
         Caption         =   "&How to Use Help"
      End
      Begin VB.Menu mnuSep7 
         Caption         =   "-"
      End
      Begin VB.Menu mnuAbout 
         Caption         =   "&About"
      End
   End
End
Attribute VB_Name = "frmVA"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'--------------------------------------------------------------
' TPN View & Adjust form
'
'23Oct96 CKJ Added Print Setup
' 3Jan97 CKJ Form_Load: Added lines to display OEM logo first
'28May97 CKJ Added StopEvents & updated tooltips
' 1Jul97 CKJ Added param to IssueRegimen
'12Jul97 CKJ Replaced fixed visible text TPN with PN
'14Oct98 CKJ F3D1/2 are now picture boxes, not frames. Removed lblPID and lblReg
'20Apr99 CKJ Form_Load: Enabled Baxa output
'05Jun00 CKJ Increased height of bottom bar to accomodate two lines of text
'            Added cmdVA(6) for the exit button
'            mnuWeight_Click: added parameters to SpGravCalc
'             added call to AdjPrint
'18Jul00 CKJ Form_Load: Added batch check for ml/kg column
'            MnuGlucose_Click: Needed cals per g gluc, but kcalPerGramGlucose not in
'             scope therefore moved code to tpn module to avoid adding another global
'            mnuShowConfig_Click: Added option to view database and rtf files from within PN
'25Jul00 CKJ Picture1_Click: Prevent editing when view only
'--------------------------------------------------------------

'!!** need TimeoutON MhTimer1 elsewhere
            
Option Explicit
DefInt A-Z

Dim EditPending As Integer
Dim PicOnView%
Dim ShowTips%

Private Sub cmdVA_Click(Index As Integer)
'05Jun00 CKJ Added exit button
''
''   TimeoutOn MhTimer1
''   tgdVA.SetFocus
''
''   Select Case Index
''      Case 0: menuEnterDetails
''      Case 1: menuPrescription
''      Case 2: menuStdReg
''      Case 3: menuRegimenDetails
''      Case 4: SaveRegimen True        'authorise
''      Case 5: menuPrint
''      Case 6: Unload Me               '05Jun00 CKJ Added
''      End Select

End Sub

Private Sub cmdVA_MouseMove(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
   
''   If Not ShowTips Then Exit Sub
''   Select Case Index
''      Case 0: ShowTip "Enter or amend Clinical information" & cr & "for prescribing rules", Me
''      Case 1: ShowTip "Enter or amend Prescription" & cr & "defined as grams, mmol etc of each ingredient", Me
''      Case 2: ShowTip "Enter or amend Standard Regimen" & cr & "defined as mls of each product", Me
''      Case 3: ShowTip "Enter or amend Regimen Details" & cr & "including regimen name, route and expiry", Me
''      Case 4: ShowTip "Authorise Regimen" & cr & "and check against defined rules", Me
''      Case 5: ShowTip "Print worksheet, labels," & cr & "clinical and invoice details", Me
''      End Select

End Sub

Private Sub F3D1_Click()
'23Oct96 CKJ/NAH Added

''   TimeoutOn MhTimer1
''   PatientInfo
''   tgdVA.SetFocus

End Sub


Private Sub Form_Load()
' 3Jan97 CKJ Added lines to display OEM logo first
'20Apr99 CKJ Enabled Baxa output
'18Jul00 CKJ Added batch check for ml/kg column

''Dim i As Integer, X$
''
''   tgdVA.Rows = 1
''
''   'If screen.Width / screen.TwipsPerPixelX > 640 Then i = 40  '25Mar98 CKJ
''   i = Iff(displaysize < 2, 30, 39)
''   tgdVA.ColumnSize(1) = i           '5Oct96 CKJ Was 20   '12Mar98 CKJ was 29
''   tgdVA.ColumnWidth(1) = i + 1      '5Oct96 CKJ Was 26   '12Mar98 CKJ was 30
''   tgdVA.ColumnName(1) = " Product"
''
''   For i = 2 To IgMax + 2            '16  '@@
''      tgdVA.ColumnSize(i) = 4
''      tgdVA.ColumnWidth(i) = Iff(displaysize < 2, 5, 6)
''      tgdVA.ColumnStyle(i) = &H22    'heading CJ, text RJ
''      X$ = Format$(i - 2)
''      tgdVA.ColumnName(i) = tp("igA" & X$) & cr$ & tp("Uabr" + tp("igU" + X$))
''   Next
''   'tgdVA.ColumnWidth(2) = 6
''   'tgdVA.ColumnFontStyle(1) = 1     'turn bold off
''
''   'If 1 = 1 Then  'if weight is known '!!**                     '18Jul00 CKJ Removed temporary line
''   If UCase$(pid.sex) <> "B" Then                                '18Jul00 CKJ Added batch check
''         i = IgMax + 3
''         tgdVA.ColumnSize(i) = 5
''         tgdVA.ColumnWidth(i) = Iff(displaysize < 2, 6, 6)       '05Oct96 CKJ was 7
''         tgdVA.ColumnStyle(i) = &H32    'heading RJ, text RJ
''         X$ = Format$(i - 2)
''         tgdVA.ColumnName(i) = "ml/kg"  'tp("")
''      End If
''
''   tgdVA.RowIndex = 1
''   tgdVA.ColumnIndex = 2
''   tgdVA.MarqueeStyle = 2
''
''   tgdVA.HeadingHeight = 1
''   tgdVA.HeadFontStyle = 2           'bold
''
''   If TpnVO Then
''         frmVA.tgdVA.Editable = False
''         frmVA.mnuSave.Enabled = False
''         frmVA.mnuEdit.Enabled = False
''         frmVA.mnuIssue.Enabled = False
''         frmVA.cmdVA(1).Enabled = False
''         frmVA.cmdVA(2).Enabled = False
''         frmVA.cmdVA(4).Enabled = False
''      End If
''   If Val(tpnini("ShowUnits", "-1")) Then mnuUnit_Click
''
''   PicOnView = 1                                      '3Jan97 CKJ Added - display OEM logo first
''   Picture1.Picture = Image1(PicOnView).Picture       '  "
''
''   frmVA.mnuBaxa.Enabled = MDIEvents.MnuTPN(2).Enabled   '20Apr99 CKJ Added to enable Baxa output
''
''   AdjPrint

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

''   SaveRegimen False     'Ask before exit if mods made
''   If k.escd Then Cancel = True

End Sub

Private Sub Form_Resize()
'''14Oct98 CKJ F3D1/2 are now picture boxes, not frames
''
''   On Error Resume Next
''   'tgdVA.Width = Me.ScaleWidth
''   'F3D1.Width = Me.ScaleWidth - 30
''   'Picture1.Left = Me.ScaleWidth - 30 - Picture1.Width
''   'F3D2.Width = Picture1.Left - 30
''   '
''   'F3D1.Top = Me.ScaleHeight - F3D1.Height - 30
''   'F3D2.Top = F3D1.Top - F3D2.Height + 15
''   'Picture1.Top = F3D2.Top + 60
''   'tgdVA.Height = F3D2.Top - tgdVA.Top
''
''   tgdVA.Width = Me.ScaleWidth
''   F3D1.Width = Me.ScaleWidth
''   Picture1.Left = Me.ScaleWidth - Picture1.Width
''   F3D2.Width = Picture1.Left + 15
''
''   F3D1.Top = Me.ScaleHeight - F3D1.Height
''   F3D2.Top = F3D1.Top - F3D2.Height + 15
''   Picture1.Top = F3D2.Top
''   tgdVA.Height = F3D2.Top - tgdVA.Top
''   On Error GoTo 0

End Sub

Private Sub menuPrescription_Click()

   ''menuPrescription

End Sub

Private Sub menuRegimenDetails_Click()

   ''menuRegimenDetails

End Sub

Private Sub MhTimer1_Timer()

   ''If TimedOut() Then mnuExit_Click

End Sub

Private Sub mnuAbout_Click()

   'ShowAboutBox Me, "ASCribe TPN Module " & Chr$(169) & " ASC Computer Software Ltd 1983-1996"
   ''ShowAboutBox Me, "ASCribe PN Module"

End Sub

Private Sub mnuAddEnteral_Click()
'Choose an enteral product

   ''AddAProduct 0, 3

End Sub

Private Sub mnuAddI_Click()

   ''SelectFromAllIgs

End Sub

Private Sub mnuAddmls_Click()
'24Oct96 CKJ

   ''AddAProduct 1, 1

End Sub

Private Sub mnuAddP_Click()

  '' AddAProduct 0, 1

End Sub

Private Sub mnuAuth_Click()

   ''SaveRegimen True        'ask if OK to authorise

End Sub

Private Sub mnuBaxa_Click()

   ''BaxaFile

End Sub

Private Sub mnuCals_Click()

   ''Calories 0

End Sub

Private Sub mnuClinDet_Click()

   ''menuEnterDetails

End Sub

Private Sub mnuDel_Click()

   ''DeleteItem

End Sub

Private Sub mnuElec_Click()

   ''menuElect

End Sub

Private Sub mnuExit_Click()
   
   ''Unload Me

End Sub

Private Sub mnuGlucose_Click(Index As Integer)
'20Mar98 CKJ Added
'18Jul00 CKJ Needed cals per g gluc, but kcalPerGramGlucose not in scope here
'            therefore moved code to tpn module to avoid adding another global

'Dim totGlperkg$, volof!
'Dim tmp$
''
''   Select Case Index
''      Case 1              'Glucose by rate
''         EnterGlucoseByRate                                                     '18Jul00 CKJ
''         'totGlperkg$ = VAxy(5, RowsUsed + 2)                                   '   "
''         'EnterGlucoseRate totGlperkg$                                          '   "
''         'If totGlperkg$ <> VAxy(5, RowsUsed + 2) Then                          '   "
''         '      volof! = Val(VAxy(2, RowsUsed + 1))                             '   "
''         '      mixglucose volof!, Val(totGlperkg$) * Val(pid.weight) * 4 'grams Gl per kg per 24 hrs  *  weight in kg  *  calories per gram Gl
''         '   End If                                                             '   "
''
''      Case 2              'Glucose by percentage
''         GlucosePercent
''
''      End Select

End Sub

Private Sub mnuHelp_Click()

''   Help 0
   
End Sub

Private Sub mnuHelpOnHelp_Click()

''   HelpGet HELP_HELPONHELP, 0

End Sub

Private Sub mnuHelpSch_Click()

''   HelpSearch
   
End Sub

Private Sub mnuInfo_Click()

''   PatientInfo

End Sub

Private Sub mnuInfusion_Click()
'Choose other infusion

''   AddAProduct 0, 2

End Sub

Private Sub mnuInvoice_Click()

''   PrintInvoice

End Sub

Private Sub mnuIss_Click()

''   issueregimen True, 1       ' 1Jul97 CKJ Added NumOfBags

End Sub

Private Sub mnuLabels_Click()

''   PrintTPNlabel

End Sub

Private Sub MnuNew_Click(Index As Integer)
'05Aug9 CKJ Added Index

''   NewRegimen Index

End Sub

Private Sub mnuNotes_Click()
   
''   menuPrintScriptNotes False
   
End Sub

Private Sub mnuOverage_Click(Index As Integer)

''   AdjustOverage Index

End Sub

Private Sub mnuPrintSetup_Click()
'Call the printer setup routine in the cmdialog control
''Dim success%
''
''   On Error Resume Next
''   CMDialog1.Flags = &H40  'Printer Setup dialog only
''   CMDialog1.action = 5
''   On Error GoTo 0
''
''   'Alternative uses HighEdit, but does not set chosen printer as default
''   'success = HEPrintSetupDlg(HighEdit.HE.hWnd)
''
End Sub

Private Sub mnuPrnOpts_Click()

''   menuPrint

End Sub

Private Sub mnuRegInfo_Click()
'24Oct 96 CKJ

 ''  RegimenInfo

End Sub

Private Sub mnuReplace_Click()

''   menuReplace

End Sub

Private Sub mnuRet_Click()

''   issueregimen False, 1       ' 1Jul97 CKJ Added NumOfBags

End Sub

Private Sub MnuSave_Click()

''   SaveRegimen False           'ask

End Sub

Private Sub mnuScript_Click()

''   menuPrintScriptNotes True

End Sub

Private Sub mnuScriptInfo_Click()
''
 ''  ShowPrescriptionInfo

End Sub

Private Sub mnuShowConfig_Click()
'18Jul00 CKJ Added option to view database and rtf files from within PN

''   ViewDB

End Sub

Private Sub mnuSpecial_Click()
'14Apr98 CKJ

''   If PNlabelscombined() Then
''         mnuOverage(1).Caption = "Set overage to given volume"
''         mnuOverage(2).Enabled = False
''      Else
''         mnuOverage(1).Caption = "Aqueous overage to given volume"
''         mnuOverage(2).Enabled = True
''      End If
''
''   If adult(pid.sex) Then
''         mnuOverage(1).Enabled = False
''         mnuOverage(2).Enabled = False
''      End If

End Sub

Private Sub mnuStdReg_Click()

''   menuStdReg

End Sub

Private Sub mnuTips_Click()

''   ShowTips = Not ShowTips
''
''   'Select Case tgdVA.ColumnFontStyle(1)
''   '   Case 1: tgdVA.ColumnFontStyle(1) = 2
''   '   Case Else: tgdVA.ColumnFontStyle(1) = 1
''   '   End Select

End Sub

Private Sub mnuUnit_Click()

''   tgdVA.HeadingHeight = 1 - (tgdVA.HeadingHeight = 1) 'alternates 1 line, 2 lines
''   tgdVA.HeadFontStyle = 1 - (tgdVA.HeadingHeight = 1) 'alternates 1 norm, 2 bold
''   mnuUnit.Checked = (tgdVA.HeadingHeight <> 1)

End Sub

Private Sub mnuView_Click()

''   mnuTips.Checked = ShowTips

End Sub

Private Sub mnuVol_Click()

''   volume 0

End Sub

Private Sub mnuWeight_Click()

''   SpGravCalc True, 0, "", 0, ""    '05Jun00 CKJ added parameters
''   AdjPrint                         '05Jun00 CKJ Moved to here from SpGravCalc


End Sub

Private Sub mnuWSheet_Click()

''   menuWSheet

End Sub

Private Sub Picture1_Click()
'25Jul00 CKJ Prevent editing when view only

''Dim iregs As RegType, oregs As RegType
''
''   If TpnVO Then Exit Sub            '25Jul00 CKJ Added to prevent editing
''
''   PicOnView = 1 - PicOnView
''   Picture1.Picture = Image1(PicOnView).Picture
''   iregs.ax = &H200                  ' get kbd special flags
''   interrupt &H16, iregs, oregs      ' BIOS kbd handler
''   Select Case oregs.ax And 3        ' shift keys
''      Case 0: AddAProduct 1, 1       ' no shift keys
''      Case 2: AddAProduct 2, 1       ' left shift only
''      Case 1: SetDebug 0             ' right shift only
''      Case 3: SetDebug 1             ' both shift keys
''      End Select
''
''   tgdVA.SetFocus

End Sub

Private Sub Picture1_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
   
''   If Not ShowTips Then Exit Sub
''   ShowTip "Click once to enter products by total ml[cr]Hold Left Shift and click once to enter products by ml/kg", Me

End Sub

Private Sub ScaleRegimen_Click()

''   ScaleRegimen

End Sub

Private Sub tgdVA_DblClick()

''   TimeoutOn MhTimer1
''
''   If tgdVA.EditActive = False Then
''         EditPending = True
''         tgdVA_KeyPress 13
''      End If
      
End Sub

Private Sub tgdVA_EnterEdit()
         
''   tgdVA.SelStart = 0
''   tgdVA.SelLength = Len(tgdVA.Text)

End Sub

Private Sub tgdVA_Fetch(Row As Long, col As Integer, Value As String)
               
 ''  Value = VAxy(col, Row)
   
End Sub

Private Sub tgdVA_KeyDown(KeyCode As Integer, Shift As Integer)

''

End Sub


