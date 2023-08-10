VERSION 5.00
Begin VB.Form FrmIssue 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   ClientHeight    =   4275
   ClientLeft      =   1170
   ClientTop       =   1800
   ClientWidth     =   5910
   ControlBox      =   0   'False
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
   Icon            =   "ISSUE.frx":0000
   KeyPreview      =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4275
   ScaleWidth      =   5910
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   4260
      Left            =   -90
      ScaleHeight     =   4260
      ScaleWidth      =   6015
      TabIndex        =   16
      TabStop         =   0   'False
      Top             =   0
      Visible         =   0   'False
      Width           =   6015
      Begin VB.Timer MhTimer1 
         Enabled         =   0   'False
         Left            =   2760
         Top             =   3600
      End
      Begin VB.CheckBox chkMechDisp 
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
         Left            =   4440
         TabIndex        =   20
         Top             =   3810
         Visible         =   0   'False
         Width           =   1500
      End
      Begin VB.Frame Frmlabels 
         Caption         =   "Labels To Print"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   2175
         Left            =   135
         TabIndex        =   2
         Top             =   1350
         Width           =   5820
         Begin VB.ComboBox cmbAltLabel 
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
            Left            =   3045
            Style           =   2  'Dropdown List
            TabIndex        =   13
            Top             =   1770
            Width           =   2700
         End
         Begin VB.CheckBox ChkPrintStockLbl 
            Caption         =   "Print S&tock Label"
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
            Left            =   240
            TabIndex        =   11
            Top             =   1455
            Visible         =   0   'False
            Width           =   2310
         End
         Begin VB.CheckBox Chk3DPrintOnly 
            Caption         =   "&Print Labels Only"
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
            Left            =   3045
            TabIndex        =   10
            Top             =   1455
            Width           =   2265
         End
         Begin VB.TextBox TxtLabels 
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
            Left            =   5310
            TabIndex        =   5
            Top             =   270
            Width           =   420
         End
         Begin VB.PictureBox picLabelConfig 
            Appearance      =   0  'Flat
            AutoRedraw      =   -1  'True
            BackColor       =   &H80000005&
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
            Height          =   1110
            Left            =   120
            ScaleHeight     =   1080
            ScaleWidth      =   2745
            TabIndex        =   3
            TabStop         =   0   'False
            Top             =   270
            Width           =   2775
         End
         Begin VB.TextBox TxtLabelSets 
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
            Left            =   5310
            TabIndex        =   7
            Text            =   "1"
            Top             =   675
            Width           =   420
         End
         Begin VB.TextBox TxtBagLabels 
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
            Left            =   5310
            TabIndex        =   9
            Text            =   "0"
            Top             =   1065
            Width           =   420
         End
         Begin VB.Label lblAltLabel 
            Alignment       =   1  'Right Justify
            Caption         =   "Label &Template"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   225
            Left            =   1305
            TabIndex        =   12
            Top             =   1845
            Width           =   1545
         End
         Begin VB.Label Label2 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "Number of Containers to &Label"
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
            Left            =   3060
            TabIndex        =   4
            Top             =   315
            Width           =   2340
            WordWrap        =   -1  'True
         End
         Begin VB.Label Label1 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "Number of &Sets of Labels"
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
            Left            =   3060
            TabIndex        =   6
            Top             =   705
            Width           =   2340
         End
         Begin VB.Label lblBagLabelQuantity 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "Number of &Bag Labels [F7]"
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
            Left            =   3060
            TabIndex        =   8
            Top             =   1095
            Width           =   2340
         End
      End
      Begin VB.Frame FraIssue 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   1230
         Left            =   135
         TabIndex        =   0
         Top             =   45
         Width           =   5820
         Begin VB.TextBox TxtIssue 
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
            HideSelection   =   0   'False
            Left            =   3240
            TabIndex        =   1
            Top             =   600
            Width           =   1560
         End
         Begin VB.Label lblPackSize 
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
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
            Left            =   3240
            TabIndex        =   21
            Top             =   960
            Width           =   1485
         End
         Begin VB.Label LblTopLine 
            Appearance      =   0  'Flat
            BackColor       =   &H00FFFFFF&
            BackStyle       =   0  'Transparent
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
            Left            =   90
            TabIndex        =   19
            Top             =   270
            Width           =   5640
         End
         Begin VB.Label LblPrintForm 
            Appearance      =   0  'Flat
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
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
            Height          =   225
            Left            =   4995
            TabIndex        =   18
            Top             =   630
            Width           =   720
         End
         Begin VB.Label LblDrug 
            Appearance      =   0  'Flat
            BackColor       =   &H00C0C0C0&
            BackStyle       =   0  'Transparent
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
            Height          =   225
            Left            =   90
            TabIndex        =   17
            Top             =   630
            Width           =   3165
         End
      End
      Begin VB.CommandButton CmdCancel 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
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
         Height          =   375
         Left            =   3060
         TabIndex        =   15
         TabStop         =   0   'False
         Top             =   3765
         Width           =   1140
      End
      Begin VB.CommandButton CmdOk 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         Caption         =   "&OK"
         Default         =   -1  'True
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
         Left            =   1710
         TabIndex        =   14
         TabStop         =   0   'False
         Top             =   3765
         Width           =   1140
      End
      Begin VB.Label lblBagLabelPrompt 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "[F7] Bag Label"
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
         Left            =   180
         TabIndex        =   22
         Top             =   3840
         Visible         =   0   'False
         Width           =   1485
      End
   End
End
Attribute VB_Name = "FrmIssue"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'****************************************************************************
'* Modification History
'****************************************************************************
'21May96 KR  Removed reference to MDIEvents form from cancel button
'04Mar97 KR  Made timeout aware.
'06May97 KR  Ensured that the entire form resizes correctly in LblDrug_Change event
'            if large drug label
'09May97 KR  Moved CalculateLabels from Patmed.bas.
'            Replaced DoEvents in CalculateLabels with screen refresh
'13May97 KR  Table1_Click.  Added code to override default insert editing behaviour.
'05Jun97 KR  Set Duplicates check box and Print only check box to false when
'            user presses cancel.  Also added TextBoxHiLight to the qty gotfocus event.
'08Jun97 KR  Replaced Msgbox call in Table_Update with popmessagecr and a more meaningful message.
'16Oct97 CKJ LblDrug_Change: Replaced the Consts with locally declared
'            variables as this appears to prevent the form unloading.
'            Table1_Validate: replaced MsgBox
'            Enabled Option Explicit
'23Dec97 EAC Prevent the whole of the Issue quantity box from being highlighted
'            if an 'x' or '*' character is present
'29Dec97 EAC Adjusting the Issue qty automatically generates the correct number of
'            labels assuming each label will be for the pack size
'27Jan98 EAC changing label qty first time didn't always work - fixed
'30Jan98 ASC height of true grid in Table1 increase from 1335 to 1360
'05Feb98 CFY CalculateLabels: Extra condition at start to stop code firing if
'            we are printing ad-hoc free format labels
'17Feb98 CFY CalculateLabels: Now handles labels qty's of less than one.
'12Mar98 CFY Now always defaults to 1 label. This is to correct the problem which arose when
'            issuing <= 0.5 of an item.
'03Dec98 TH  CalculateLabels: Added abs in numoflabels calculation to handle returns
'24Feb99 SF  cmdCancel_Click: sets the cancel button tag to true
'04Mar99 CFY Changed to use windows colours
'25Mar99 TH  Chk3DPrintOnly_Click: Changed value
'08Apr99 TH  CalculateLabels: Code to allow for entry of 0 labels to print after screen loads
'08Apr99 TH  TxtLabels_Changed: Trapped for neg numbers and allowed 0 to be entered after for loads
'16Feb04 CKJ Added chkMechDisp
'            Removed "FrmIssue." from all controls
'09Mar04 CKJ Added pack size label
'14apr04 CKJ Added F7 Bag label prompt
'13May04 CKJ ChkPrintStockLbl: set not visible at design time
'            Double click 'bag label [F7]' prompt to print bag label
'25Jun12 CKJ Added Alternative label combo
'****************************************************************************

DefInt A-Z
Option Explicit

Dim calculatedlabels As Integer  '29Dec97 EAC
Dim manualchange As Integer      '08Apr99 TH Added

Private Sub CalculateLabels(ChangeLabelQty As Boolean)
'09May97 KR  Replaced DoEvents with screen refresh
'29Dec97 EAC each label will only contain upto the pack size number of issue units unless
'            the number of labels is explicitly set
'27Jan98 EAC reset control variable to allow num of labels to be calculated if the labels qty is changed
'05Feb98 CFY Extra condition at start to stop code firing if we are printing ad-hoc free format labels
'17Feb98 CFY Now handles labels qty's of less than one.
'12Mar98 CFY Now always defaults to 1 label. This is to correct the problem which arose when
'            issuing <= 0.5 of an item.
'03Dec98 TH  Added abs in numoflabels calculation to handle returns
'08Apr99 TH  Code to allow for entry of 0 labels to print after screen loads
'09May05 CKJ Modified to use description instead of TrueGrid
'            Traps various logic & overflow errors, eg more labels requested than items to issue.

Dim remainder As Long, answer As Long, NumLabels As Long, i As Long
Dim posn As Integer, Qty&, PackSize&, IssueQty$
Dim FinalLabelDifferent As Boolean
Dim NumIdenticalLabels As Integer

   If Trim$(d.SisCode) <> "" Then
      On Error GoTo CalculateError
      posn = InStr(UCase$(TxtIssue.text), "X")
      If posn = 0 Then posn = InStr(TxtIssue.text, "*")
   
      If posn = 0 Then
         IssueQty$ = TxtIssue.text
      Else
         PackSize& = Val(Mid$(TxtIssue.text, posn + 1))
         Qty& = Val(Mid$(TxtIssue.text, 1, posn - 1))
         IssueQty$ = Format$(Qty& * PackSize&)
      End If
   
      If Not ChangeLabelQty Then
         NumLabels = Val(TxtLabels.text)
         
         If NumLabels > Val(IssueQty$) Then
            NumLabels = Val(IssueQty$)
            calculatedlabels = True
            TxtLabels.text = Format$(NumLabels)
            TxtLabels.SelStart = 32767
            calculatedlabels = False
         End If
      Else
         If Val(d.convfact) <> 0 Then
            NumLabels = Abs(Val(IssueQty$)) \ Val(d.convfact)      '03Dec98 TH Added abs to handle returns
            If Val(IssueQty$) Mod Val(d.convfact) <> 0 Then NumLabels = NumLabels + 1
         Else
            popmessagecr "!Warning", "Pack size is zero. This must be corrected before stock can be issued."
         End If
            
         If NumLabels = 0 Then NumLabels = 1
      End If
         
Continue:
      On Error GoTo ErrorHandler
      
      Erase LabelValues
      ReDim LabelValues(NumLabels) As Single
      
      '29Dec97 EAC each label will only contain upto the pack size number of issue units unless
      '            the number of labels is explicitly set
      If Val(IssueQty$) < 1 Then IssueQty$ = "1"
      
      If Not ChangeLabelQty Then
         If Val(TxtLabels.text) = 0 Then
            answer = 0
            remainder = 0
         Else
''            answer = Val(IssueQty$) \ Val(TxtLabels.Text) 'integer division      09May05 Superceded - last label must hold remainder
''            remainder = Val(IssueQty$) Mod Val(TxtLabels.Text)
''            For i = 1 To NumLabels
''               LabelValues(i) = answer
''               If remainder <> 0 Then
''                     LabelValues(i) = LabelValues(i) + 1
''                     remainder = remainder - 1
''                  End If
''            Next
            answer = Val(IssueQty$) \ Val(TxtLabels.text)        'integer division
            remainder = Val(IssueQty$) Mod Val(TxtLabels.text)
            For i = 1 To NumLabels
               LabelValues(i) = answer
            Next
            If remainder > 0 Then
               LabelValues(NumLabels) = LabelValues(NumLabels) + remainder
            End If
         End If
      Else
         If Val(d.convfact) <> 0 Then   '29Jul98 ASC
            For i = 1 To Val(IssueQty$) \ Val(d.convfact)
               LabelValues(i) = Val(d.convfact)
            Next
            If Val(IssueQty$) Mod Val(d.convfact) <> 0 Then LabelValues(NumLabels) = Val(IssueQty$) - (Val(d.convfact) * (Val(IssueQty$) \ Val(d.convfact)))  'NB Cannot use MOD as this converts to integers!!
         End If
         calculatedlabels = True   '29Dec97 EAC added to stop recalculation in TxtLabels_Change event
         TxtLabels.text = Format$(NumLabels)
         calculatedlabels = False  '27Jan98 EAC reset variable to allow recalculation to work in TxtLabels_change event
      End If

      picLabelConfig.Cls
      picLabelConfig.Print
      FinalLabelDifferent = False
      NumIdenticalLabels = NumLabels
      If Val(TxtIssue.text) = 0 Then                              'NumLabels can be 1 when qty to issue is 0 or blank
         NumIdenticalLabels = 0
      Else
         If NumLabels > 1 Then
            If LabelValues(1) <> LabelValues(NumLabels) Then
               FinalLabelDifferent = True
               NumIdenticalLabels = NumLabels - 1
            End If
         End If
      End If
         
      Select Case NumIdenticalLabels
         Case 0:      If NumLabels = 0 Then picLabelConfig.Print " No labels to print"
         Case 1:      picLabelConfig.Print " 1 label with quantity"; LabelValues(1)
         Case Is > 1: picLabelConfig.Print NumIdenticalLabels; "labels with quantity"; LabelValues(1)
         End Select
      picLabelConfig.Print
      
      If FinalLabelDifferent Then
         'If NumIdenticalLabels Then picLabelConfig.Print " and";
         picLabelConfig.Print " 1 label with quantity"; LabelValues(NumLabels)
      End If
      
      ScreenRefresh
   End If

Cleanup:
Exit Sub

ErrorHandler:
Resume Cleanup

CalculateError:
   NumLabels = 1
Resume Continue
   
End Sub

Private Sub CmdCancel_Click()
'05Jun97 KR added
'24Feb99 SF sets the cancel button tag to true
   
   TxtLabelSets.text = "1"
   Chk3DPrintOnly.Value = False
   cmdCancel.Tag = True
   TxtIssue.text = ""
   ScreenRefresh
   Me.Hide

End Sub

Private Sub cmdOK_Click()

   Me.Hide
   ScreenRefresh

End Sub

Private Sub Form_Activate()
   
   Picture1.Visible = True
   'TxtIssue.SetFocus
   TimeoutOn MHTimer1

End Sub

Private Sub Form_Deactivate()
   
   Picture1.Visible = False
   TimeoutOff MHTimer1

End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
'14apr04 CKJ

   Select Case KeyCode
      Case KEY_F7
         If Shift = 0 Then
               If ActionIssueConfig() = 1 Then    'either do nothing, print now or increment bag counter
                  TxtBagLabels.text = Format$(Val(TxtBagLabels.text) + 1)
               End If
            End If
      End Select

End Sub

Private Sub Form_Load()

   SetChrome Me  '08Jun05 TH Added
   CentreForm Me
   manualchange = False

End Sub

Private Sub Form_Resize()
'16Feb04 CKJ Added chkMechDisp

   chkMechDisp.Move cmdCancel.Left + 1380, cmdCancel.Top + 45

End Sub

Private Sub lblBagLabelPrompt_DblClick()
'13May04 CKJ Added

Dim dummy As Integer

   dummy = ActionIssueConfig()      'either do nothing or print label now

End Sub

Private Sub LblDrug_Change()
'06May97 KR  Ensured that the entire form resizes correctly if the drug label large
'16Oct97 CKJ Replaced the Consts with locally declared variables as this appears to
'            prevent the form unloading.

Dim txtwidth As Integer, Diff As Integer

Dim DefFormWidth%                  'Default form width
Dim DefFrameWidth%                 'Default frame width
Dim DefLabelWidth%                 'Default LabelWidth
Dim DefTxtIssueLeft%
Dim DefPrintformLeft%
Dim DefCmdOKLeft%
Dim DefCmdCancelLeft%
Dim DefPictureWidth%

   DefFormWidth = 6135             'Default form width
   DefFrameWidth = 5820            'Default frame width
   DefLabelWidth = 3165            'Default LabelWidth
   DefTxtIssueLeft = 3340
   DefPrintformLeft = 4995
   DefCmdOKLeft = 1665
   DefCmdCancelLeft = 3060
   DefPictureWidth = 6015

   txtwidth = Me.TextWidth(Trim$(LblDrug.Caption))
   If txtwidth > DefLabelWidth Then
         Diff = txtwidth - DefLabelWidth
         Me.Picture1.Width = Me.Picture1.Width + Diff
         Me.Frmlabels.Width = Me.Frmlabels.Width + Diff
         Me.Width = Me.Width + Diff
         Me.FraIssue.Width = Me.FraIssue.Width + Diff
         Me.LblDrug.Width = txtwidth
         Me.CmdOk.Left = Me.CmdOk.Left + (Diff \ 2)
         Me.cmdCancel.Left = Me.cmdCancel.Left + (Diff \ 2)
         Me.TxtIssue.Left = Me.TxtIssue.Left + Diff
         Me.LblPrintForm.Left = Me.LblPrintForm.Left + Diff
      Else
         Me.Width = DefFormWidth
         Me.FraIssue.Width = DefFrameWidth
         Me.LblDrug.Width = DefLabelWidth
         Me.CmdOk.Left = DefCmdOKLeft
         Me.cmdCancel.Left = DefCmdCancelLeft
         Me.TxtIssue.Left = DefTxtIssueLeft
         Me.LblPrintForm.Left = DefPrintformLeft
         Me.Picture1.Width = DefPictureWidth
         Me.Frmlabels.Width = DefFrameWidth
      End If
   
   Me.lblPackSize.Left = Me.TxtIssue.Left
   CentreForm Me

End Sub

Private Sub MhTimer1_Timer()
'04Mar97 KR Added

   If TimedOut() Then
         Me.Hide
      End If

End Sub

''Private Sub Table1_Click()
'''13May97 KR Added.  Overrides default insert editing behaviour.
''
''   Table1.Modified = False
''   Table1.EditActive = False
''
''End Sub
''
''Private Sub Table1_EnterEdit()
''
''  fieldedit = True
''
''End Sub
''
''Private Sub Table1_Fetch(Row As Long, Col As Integer, Value As String)
''
''   If Col = 1 Then
''         Value = "Label " & Str$(Row)
''      Else
''         Value = Str$(LabelValues(Row))
''      End If
''
''
''End Sub
''
''Private Sub Table1_Update(Row As Long, Col As Integer, Value As String)
'''08Jun97 KR Replace Msgbox call with popmessagecr and a more meaningful message.
''
''Dim NumLabels%, remainder!, temp!, msg$, i%
''
''   If Col = 2 Then
''         temp! = LabelValues(Row)
''         LabelValues(Row) = Val(Value)
''         'Table1.Refresh
''         If Table1.ColumnSum(2) < Val(TxtIssue.Text) Then
''
''               remainder! = Val(TxtIssue.Text) - Table1.ColumnSum(2)
''               NumLabels% = TxtLabels.Text
''               If Row <> NumLabels Then
''                     Do
''                        For i = Row To NumLabels
''                           If i > Row And remainder > 0 Then
''
''                                 LabelValues(i) = LabelValues(i) + 1
''                                 remainder = remainder - 1
''                              End If
''                        Next
''                     Loop Until (remainder = 0)
''                  Else
''                     NumLabels% = NumLabels% + 1
''                     ReDim Preserve LabelValues(NumLabels%)
''                     LabelValues(NumLabels%) = remainder
''                     TxtLabels.Text = Trim$(Str$(NumLabels%))
''                     Table1.Rows = NumLabels
''                  End If
''
''            ElseIf Table1.ColumnSum(2) > Val(TxtIssue.Text) Then
''               '08Jun97 KR added
''               msg$ = "The amount entered on the label would make the" & crlf
''               msg$ = msg$ & "total quantity to be printed greater than" & crlf
''               msg$ = msg$ & "the total quantity to be issued.  Either adjust" & crlf
''               msg$ = msg$ & "the label quantity or the total quantity" & crlf
''               msg$ = msg$ & "to be issued."
''               popmessagecr "Label Quantities", msg$
''
''               'MsgBox "Value too high"
''               LabelValues(Row) = temp!
''               Table1.Modified = False
''               Table1.EditActive = False
''            End If
''         Table1.Refresh
''         fieldedit = False
''
''      End If
''
''End Sub
''
''Private Sub Table1_Validate(Row As Long, Col As Integer, Value As String, Cancel As Integer)
'''16Oct97 CKJ replaced msgbox
''
''   If Not IsNumeric(Value) Then
''         popmessagecr "", "Numeric Values only"         '16Oct97 CKJ replaced msgbox
''         Cancel = True
''      End If
''
''   If Cancel Then
''         Table1.Modified = False
''         Table1.EditActive = False
''      End If
''
''End Sub

Private Sub TxtBagLabels_GotFocus()

   TextBoxHiLight

End Sub

Private Sub TxtBagLabels_KeyPress(KeyAscii As Integer)
   
   Select Case KeyAscii
      Case 8, 48 To 57    '0' to '9' and BS, no action needed
      Case Else           'letters punctuation etc
         KeyAscii = 0
      End Select

End Sub

Private Sub TxtIssue_Change()
   
   'If Val(TxtIssue.Text) > 0 And Val(TxtLabels) > 0 And Not fieldedit Then 29Dec97 EAC allow for times packsize
   If Val(TxtLabels) > 0 Then
         CalculateLabels True
      End If
   
End Sub

Private Sub TxtIssue_GotFocus()
'23Dec97 EAC prevent selection of all text when contains * or "x"
'02Feb98 EAC Added decimal point to list of valid numerals

Dim xposn%, loopvar%, sellen%

    '23Dec97 EAC check for Y x packsize and highlight only "Y"
    'TextBoxHiLight
    TxtIssue.SelStart = 0
    TxtIssue.text = Trim$(TxtIssue.text)
    xposn = InStr(UCase$(TxtIssue.text), "X")
    If xposn = 0 Then xposn = InStr(TxtIssue.text, "*")
    If xposn > 0 Then
            sellen = 0
            For loopvar = 1 To xposn
                Select Case Mid$(TxtIssue.text, loopvar, 1)
                    Case "0" To "9", "."        '02Feb98 EAC Added decimal point
                        sellen = sellen + 1
                    Case Else
                        Exit For
                End Select
            Next
            TxtIssue.SelLength = sellen
        Else
            TxtIssue.SelLength = Len(TxtIssue.text)
        End If

End Sub

Private Sub TxtIssue_KeyPress(KeyAscii As Integer)
'23Dec97 EAC limit key strokes that user can enter
Dim posn%

   Select Case KeyAscii
      Case Asc("0") To Asc("9"), Asc("."), 8 'Allow backspace as well
          'Do nothing
      Case Asc("x"), Asc("X"), Asc("*")
          posn = InStr(UCase$(TxtIssue.text), "X")
          If posn = 0 Then posn = InStr(TxtIssue.text, "*")
          If posn > 0 Then KeyAscii = 0
      Case Else
          KeyAscii = 0
       End Select

End Sub

Private Sub TxtLabels_Change()
'29Dec97 EAC added CalculatedLabels
'27Jan98 EAC correct calculation of num of labels
'12Mar98 CFY Now always defaults to 1 label. This is to correct the problem which arose when
'            issuing <= 0.5 of an item.
'08Apr99 TH  Trapped for neg numbers and allowed 0 to be entered after for loads

   If (Val(TxtLabels.text) = 0 And Not manualchange) Or Val(TxtLabels.text) < 0 Then
      TxtLabels.text = 1    '08Apr99 TH Trapped for neg numbers and allowed 0 to be entered after for loads
   End If

   If Not calculatedlabels Then
      CalculateLabels False
   End If

End Sub

Private Sub TxtLabels_GotFocus()
   
   TextBoxHiLight
   manualchange = True

End Sub

Private Sub TxtLabels_KeyPress(KeyAscii As Integer)

   Select Case KeyAscii
      Case 8, 48 To 57                 '0' to '9' and BS, no action needed
      Case Else: KeyAscii = 0          'letters punctuation etc
      End Select
      
End Sub

Private Sub TxtLabels_LostFocus()

   manualchange = False

End Sub

Private Sub TxtLabelSets_GotFocus()

   TextBoxHiLight

End Sub

Private Sub TxtLabelSets_KeyPress(KeyAscii As Integer)
   
   Select Case KeyAscii
      Case 8, 48 To 57                 '0' to '9' and BS, no action needed
      Case Else: KeyAscii = 0          'letters punctuation etc
      End Select

End Sub
