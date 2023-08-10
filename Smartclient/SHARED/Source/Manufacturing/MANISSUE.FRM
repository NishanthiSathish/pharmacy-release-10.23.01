VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form ManIssue 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   Caption         =   "Manufacturing Issue"
   ClientHeight    =   10110
   ClientLeft      =   765
   ClientTop       =   735
   ClientWidth     =   14370
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
   Icon            =   "MANISSUE.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   10110
   ScaleWidth      =   14370
   Begin VB.PictureBox Picture1 
      BorderStyle     =   0  'None
      Height          =   735
      Left            =   960
      ScaleHeight     =   735
      ScaleWidth      =   975
      TabIndex        =   32
      Top             =   10560
      Width           =   975
   End
   Begin VB.TextBox Text3 
      Height          =   285
      Left            =   1560
      TabIndex        =   20
      Top             =   10680
      Width           =   180
   End
   Begin VB.TextBox Text2 
      Height          =   285
      Left            =   1320
      TabIndex        =   26
      Top             =   10680
      Width           =   180
   End
   Begin VB.TextBox Text1 
      Height          =   285
      Left            =   1080
      TabIndex        =   22
      Top             =   10680
      Width           =   180
   End
   Begin VB.Frame Frame4 
      Caption         =   "  Calculated  Expiry"
      Height          =   1095
      Left            =   4080
      TabIndex        =   30
      Top             =   1920
      Width           =   2775
      Begin VB.Label lblExpiry 
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   420
         Left            =   240
         TabIndex        =   31
         Top             =   480
         Width           =   2175
      End
   End
   Begin VB.PictureBox PicInfo1 
      BackColor       =   &H0080FFFF&
      Height          =   15
      Left            =   6840
      ScaleHeight     =   15
      ScaleWidth      =   7215
      TabIndex        =   29
      Top             =   7920
      Visible         =   0   'False
      Width           =   7215
   End
   Begin VB.Frame FraBatchnumber 
      Caption         =   "Enter &Batch Number"
      Height          =   1095
      Left            =   6960
      TabIndex        =   27
      Top             =   1920
      Width           =   2175
      Begin VB.TextBox txtBatchNumber 
         Height          =   420
         Left            =   120
         TabIndex        =   28
         Top             =   480
         Width           =   1935
      End
   End
   Begin VB.Frame fraOptions 
      Caption         =   "Manufacturing Options"
      Height          =   2200
      Left            =   9240
      TabIndex        =   14
      Top             =   840
      Width           =   4850
      Begin VB.OptionButton Option1 
         Caption         =   "Print worksheet and labels only (No issues)"
         Height          =   255
         Index           =   5
         Left            =   240
         TabIndex        =   19
         Top             =   1800
         Width           =   4455
      End
      Begin VB.OptionButton Option1 
         Caption         =   "Print labels only (No issues)"
         Height          =   255
         Index           =   4
         Left            =   240
         TabIndex        =   18
         Top             =   1440
         Width           =   4455
      End
      Begin VB.OptionButton Option1 
         Caption         =   "Print worksheet only (No issues)"
         Height          =   255
         Index           =   3
         Left            =   240
         TabIndex        =   17
         Top             =   1080
         Width           =   4455
      End
      Begin VB.OptionButton Option1 
         Caption         =   "Print and issue with labels only"
         Height          =   255
         Index           =   2
         Left            =   240
         TabIndex        =   16
         Top             =   720
         Width           =   4455
      End
      Begin VB.OptionButton Option1 
         Caption         =   "Print and issue with worksheet and labels"
         Height          =   255
         Index           =   1
         Left            =   240
         TabIndex        =   15
         Top             =   360
         Width           =   4455
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Edit Ingredient"
      Height          =   1575
      Left            =   120
      TabIndex        =   9
      Top             =   7800
      Width           =   6015
      Begin VB.TextBox txtQty 
         BackColor       =   &H00FFFFFF&
         Height          =   375
         Left            =   240
         TabIndex        =   11
         Top             =   860
         Width           =   1095
      End
      Begin VB.Label lblStockLevel 
         Height          =   375
         Left            =   2640
         TabIndex        =   13
         Top             =   960
         Width           =   2895
      End
      Begin VB.Label lblUnits 
         Height          =   375
         Left            =   1440
         TabIndex        =   12
         Top             =   960
         Width           =   975
      End
      Begin VB.Label lblStoresDesc 
         Height          =   495
         Left            =   360
         TabIndex        =   10
         Top             =   360
         Width           =   5055
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "DATE and TIME of manufacture"
      Height          =   1095
      Left            =   120
      TabIndex        =   8
      Top             =   1920
      Width           =   3855
      Begin VB.Label lblTime 
         BackColor       =   &H80000005&
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   420
         Left            =   2640
         TabIndex        =   25
         Top             =   480
         Width           =   1095
      End
      Begin VB.Label lblDate 
         BackColor       =   &H80000005&
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   420
         Left            =   600
         TabIndex        =   23
         Top             =   480
         Width           =   1455
      End
      Begin VB.Label Label5 
         Caption         =   "&Time"
         Height          =   255
         Left            =   2160
         TabIndex        =   24
         Top             =   600
         Width           =   735
      End
      Begin VB.Label Label4 
         Caption         =   "&Date"
         Height          =   255
         Left            =   120
         TabIndex        =   21
         Top             =   600
         Width           =   735
      End
   End
   Begin MSComctlLib.ListView IssueGrid 
      Height          =   3735
      Left            =   120
      TabIndex        =   6
      Top             =   3840
      Width           =   14055
      _ExtentX        =   24791
      _ExtentY        =   6588
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
   End
   Begin VB.CommandButton CmdCancel 
      Appearance      =   0  'Flat
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   315
      Left            =   13155
      TabIndex        =   1
      Top             =   9600
      Width           =   915
   End
   Begin VB.CommandButton CmdOK 
      Appearance      =   0  'Flat
      Caption         =   "&OK"
      Default         =   -1  'True
      Height          =   315
      Left            =   12120
      TabIndex        =   0
      Top             =   9600
      Width           =   915
   End
   Begin VB.Label lblHeading 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000003&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label1"
      ForeColor       =   &H80000008&
      Height          =   540
      Index           =   0
      Left            =   0
      TabIndex        =   7
      Top             =   0
      Visible         =   0   'False
      Width           =   1935
      WordWrap        =   -1  'True
   End
   Begin VB.Label LblPatientName 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "**** Patient Not Found ****"
      ForeColor       =   &H80000008&
      Height          =   320
      Left            =   1320
      TabIndex        =   5
      Top             =   1260
      Width           =   7515
   End
   Begin VB.Label LblDrugName 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "**** Drug Not Found ****"
      ForeColor       =   &H80000008&
      Height          =   405
      Left            =   1260
      TabIndex        =   4
      Top             =   135
      Width           =   12870
   End
   Begin VB.Label Label2 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Drug Name :"
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
      Left            =   135
      TabIndex        =   3
      Top             =   135
      Width           =   1455
   End
   Begin VB.Label LblPatient 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Patient Name :"
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
      Height          =   260
      Left            =   135
      TabIndex        =   2
      Top             =   1260
      Width           =   1140
   End
End
Attribute VB_Name = "ManIssue"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-------------------------------------------------------------------------
'              ManIssue.frm
'              ------------
'
'
'22Jan97 ASC added Defint A-Z and made Ok button default.
'13Feb98 CFY Tightened control of cursor movement on truegrid to restrict
'            to only the QTY column.
'            Changes to error handling.
'28Aug98 TH  Issuegrid_fetch: Changed format of qty to suppress stray decimal points
'24Sep98 TH  Issuegrid_fetch:Changed formats
'24Oct01 TH  Issuegrid_validate: Extra check (And) to prevent error on 15th line with formulas using all available lines (#53508)
'11Mar02 TH  Form_QueryUnload: Added code to trap escape from manuf issue and flag for calling routine (#59106)
'10Jun02 TH  Increased height of form and grid so as to show all 15 potential lines without need of scroll bar (#59743)
'24Apr12 TH  Changed back colour of date and time labels for windows 7 (TFS 32575)
'19Aug15 XN  Moved code from IssueGrid_KeyDown to IssueGrid_KeyPress so pressing number keys in grid works better 118279
'19Jan16 TH  Form_Load, lblDate_Click,lblTime_Click : Changes to allow for caching of PrepDate TFS 124077
'09May16 TH  Form_Load: Mod to above -removed line that overwrote the cached time if available (TFS 124077)
'28Apr17 XN  Form_Activate: Patient or drug not loaded in manufacturing (158691)
'-------------------------------------------------------------------------

Option Explicit
DefInt A-Z

Const GRS_LEFT = 0         'Left justify column
Const GRS_CENTER = 1       'Center column
Const GRS_RIGHT = 2        'Right justify column
Const GRS_HSAME = &H0      'Heading same as column
Const GRS_HLEFT = &H10     'Left justify heading
Const GRS_HCENTER = &H20   'Center heading
Const GRS_HRIGHT = &H30    'Right justify heading
Const GRS_READONLY = 8192  'Disable editing for column
Dim lngRow As Long         '18Oct05 TH Set as modular rather than static


Private Sub cmdCancel_Click()
   Me.Tag = True
   k.escd = True
   Me.Hide
End Sub

Private Sub cmdOK_Click()
'First run validation checks then set the various stuff


   Me.Tag = False
   Me.Hide
End Sub

Private Sub Command1_Click()
 lblDate_Click

End Sub

Private Sub Command1_GotFocus()
lblDate_Click
End Sub

Private Sub Command2_Click()
lblTime_Click
End Sub

Private Sub Command2_GotFocus()
lblTime_Click
End Sub

Private Sub Command3_Click()
On Error Resume Next
txtBatchNumber.SetFocus
On Error GoTo 0
End Sub

Private Sub Command3_GotFocus()
On Error Resume Next
txtBatchNumber.SetFocus
On Error GoTo 0
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
'''MsgBox Format$(KeyCode) & "    " & Format$(Shift)
End Sub

Private Sub Form_Activate()
'28Apr17 XN 158691 Patient or drug not loaded in manufacturing
    If InStr(LCase$(lblPatientName.Caption), "patient not found") > 0 Or InStr(LblDrugName.Caption, "Drug Not Found") > 0 Then
        popmessagecr ".Manufacturing", "Patient or drug data not found." + vbNewLine + "Manufacturing can not continue." + vbNewLine + "Reload patient and try again."
        k.escd = True
        Unload Me
    End If
End Sub

Private Sub Form_Load()
'19Jan16 TH Changes to allow for caching of PrepDate TFS 124077
'09May16 TH Mod to above -removed line that overwrote the cached time if available (TFS 124077)

Dim intWidthMultiplier As Integer
Dim lngExtra As Long
Dim intFullGrid As Integer
Dim strDate As String
Dim strTime As String
Dim strbatchexpiry As String
Dim optDefault As Integer
Dim rsPrepDate As ADODB.Recordset   '15Jan16 TH
Dim blnCachedDate As Boolean        '  "
Dim td As DateAndTime   '19Jan16 TH Added (TFS)
Dim dt As DateAndTime   '     "

''Const intWidthMultiplier = 110 '80
''   'Setup Form/control positions and sizes
   IssueGrid_RowChange 0
   Me.Width = Screen.Width
   intWidthMultiplier = Screen.Width / 130
   CentreForm Me
   IssueGrid.Width = Me.Width - 340
   IssueGrid.Left = 120
   CmdCancel.Left = IssueGrid.Left + IssueGrid.Width - CmdCancel.Width
   CmdOK.Left = IssueGrid.Left + IssueGrid.Width - CmdCancel.Width - 120 - CmdOK.Width
   fraOptions.Left = IssueGrid.Width - 4900
   optDefault = Val(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "1", "AllPossibilitiesDefault", 0))
   If optDefault > 0 And optDefault < 5 Then
      Option1(optDefault).Value = True
   End If
   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "N", "AllPossibilities", 0)) Then
      fraOptions.Visible = True
   Else
      fraOptions.Visible = False
   End If
   'Setup and initialise TrueGrid
   txtBatchNumber.text = getbatchnum()
   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "N", "PromptBatchNum", 0)) Then
      FraBatchnumber.Visible = True
   Else
      FraBatchnumber.Visible = True 'still allow it to be visible
      Text3.Enabled = False
      txtBatchNumber.Enabled = False
   End If

   SetChrome Me

   
   'set column headings and widths for each column
   IssueGrid.View = lvwReport
   IssueGrid.ListItems.Clear
   IssueGrid.ColumnHeaders.Clear
   'lngExtra = (45 * intWidthMultiplier) + (7 * intWidthMultiplier) + (6 * intWidthMultiplier)
   lngExtra = (60 * intWidthMultiplier) + (7 * intWidthMultiplier) + (6 * intWidthMultiplier)
   intFullGrid = Screen.Width - (460 + lngExtra)
   'ssueGrid.ColumnHeaders.Add , "H:1", "Description", (45 * intWidthMultiplier), GRS_LEFT
   IssueGrid.ColumnHeaders.Add , "H:1", "Description", (60 * intWidthMultiplier), GRS_LEFT
   IssueGrid.ColumnHeaders.Add , "H:2", "Qty", (7 * intWidthMultiplier), GRS_RIGHT
   IssueGrid.ColumnHeaders.Add , "H:3", "", (6 * intWidthMultiplier), GRS_LEFT
   ''IssueGrid.ColumnHeaders.Add , "H:4", "Errors", (60 * intWidthMultiplier), GRS_LEFT
   IssueGrid.ColumnHeaders.Add , "H:4", "Errors", (intFullGrid), GRS_LEFT
   IssueGrid.ColumnHeaders.Add , "H:5", "", (0 * intWidthMultiplier)
   IssueGrid.ColumnHeaders.Add , "H:6", "", (0 * intWidthMultiplier)
   IssueGrid.ColumnHeaders.Add , "H:7", "", (0 * intWidthMultiplier)
   HeaderDisplay Me, Me.IssueGrid, Create, 20
   

   

   'IssueGrid.ColumnStyle(1) = GRS_LEFT + GRS_READONLY
   'IssueGrid.ColumnStyle(2) = GRS_RIGHT
   'IssueGrid.ColumnStyle(3) = GRS_LEFT + GRS_READONLY
   'IssueGrid.ColumnStyle(4) = GRS_LEFT + GRS_READONLY
   'IssueGrid.ColumnVisible(5) = False
   'IssueGrid.ColumnVisible(6) = False
   'IssueGrid.ColumnVisible(7) = False
   IssueGrid.FullRowSelect = True
   'IssueGrid.Rows = 15
   'IssueGrid.Refresh

   'IssueGrid.RowIndex = 1
   'IssueGrid.ColumnIndex = 2
   ''IssueGrid_FetchRow
   ''If Me.IssueGrid.SelectedItem.Index > 0 Then IssueGrid_RowChange Me.IssueGrid.SelectedItem.Index
   ''IssueGrid_RowChange 1
   
   'Fill in the date and time boxes for expiry
   '15Jan16 TH Here we will derive prepdate from the cached prep date IF configured and there is a cached date on either this terminal or this session
   strDate = ""
   
   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "Y", "PreparationDateCache", 0)) Then
      'We could be using Prep Date Caching so see if there is one
      Set rsPrepDate = gTransport.ExecuteSelectSP(g_SessionID, "pWManufacturingPreparationDateCacheSelect", "")
      If Not rsPrepDate Is Nothing Then
         If rsPrepDate.State = adStateOpen Then
            If rsPrepDate.RecordCount <> 0 Then
               strDate = RtrimGetField(rsPrepDate!PreparationDate)
               strTime = RtrimGetField(rsPrepDate!PreparationTime)
               blnCachedDate = True
            End If
            rsPrepDate.Close
         End If
         Set rsPrepDate = Nothing
      End If
   End If
   If blnCachedDate Then
      lblDate.font.Italic = True
      lblTime.font.Italic = True
      lblDate.BackColor = &H80C0FF
      lblTime.BackColor = &H80C0FF
   Else
      lblDate.font.Italic = False
      lblTime.font.Italic = False
      lblDate.BackColor = &HFFFFFF
      lblTime.BackColor = &HFFFFFF
      strDate = Mid$(date$, 4, 2) & "/" & Left$(date$, 2) & "/" + Right$(date$, 4)
      strTime = Left$(Time$, 5)
   End If
   
   'strDate = Mid$(date$, 4, 2) & "/" & Left$(date$, 2) & "/" + Right$(date$, 4) 'Only Done above if not Cached
   parsedate strDate, strDate, "8", 0
   'txtDate.text = strDate
   lblDate.Caption = strDate
   'strTime = Left$(Time$, 5)   '09May16 TH This has been sorted above here it overwrote the cached time if available (TFS 124077)
   parsetime strTime, strTime, "1", 0
   'txtTime.text = strTime
   'WE also need to check if prepdate is in past if so the red the background &H8080FF
   If blnCachedDate Then
         StringToDate strDate, dt
         StringToTime strTime, dt
         datetomins dt
         today td
         If dt.mint <= td.mint Then
            lblDate.BackColor = &H8080FF
            lblTime.BackColor = &H8080FF
         End If
   End If
   
   
   lblDate.Caption = strDate
   lblTime.Caption = strTime
   'Now calculate the expiry
   MakeExpiry k, strDate, strTime, strbatchexpiry
   ''Set dForm = d
   setexpirydate strbatchexpiry
   lblExpiry.Caption = strbatchexpiry
   
   'Me.IssueGrid.SetFocus
   If IssueGrid.ListItems.count > 0 Then
   IssueGrid.ListItems(1).Selected = True
   End If
   ''IssueGrid_RowChange 1
   If TrueFalse(terminal("DisplayManufacturingPanel", "Y")) Then
''      MainScreen.PicInfo1.Left = MainScreen.lvwMainScreen.Left
''      MainScreen.PicInfo1.Width = (MainScreen.lvwMainScreen.Width - 200) / 2
''      MainScreen.PicInfo1.top = (MainScreen.lvwMainScreen.top + MainScreen.lvwMainScreen.Height + 700)
''      MainScreen.PicInfo1.Height = 400
   End If
   
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then   '11Mar02 TH Added to trap escape from manuf issue (#59106)
         Me.Tag = True       '    "
         k.escd = True       '    "
         Me.Hide             '    "
         
      End If


End Sub

Private Sub IssueGrid_ColumnChange()
'12Feb98 CFY Added to restrict cursor to the qty column.

''   IssueGrid.ColumnIndex = 2

End Sub

Private Sub IssueGrid_Fetch(Row As Long, Col As Integer, Value As String)
'28Aug98 TH  Changed format of qty to suppress stray decimal points
'24Sep98 TH  Changed formats
Dim AllErrors$, Numoflines%, temp$
   
   ReDim ErrorLines$(5)

   Select Case Col
      Case 1:
         Value = IssueSummary(Row).desc
      Case 2:
         If IssueSummary(Row).Qty <> 0 Then
               'Value = Str$(IssueSummary(row).Qty)
               'Value = Format$(IssueSummary(row).Qty, "0.#####") '13Jun98 ASC
               'Value = Format$(IssueSummary(row).Qty) '28Aug98 TH
               temp$ = Format$(IssueSummary(Row).Qty, "0.#####")  '24Sep98 TH
               'Value = Format$(IssueSummary(row).Qty) '28Aug98 TH
               Value = Format$(temp$) '24Sep98 TH


            End If
      Case 3:
         Value = IssueSummary(Row).Unit
      Case 4:
         Value = IssueSummary(Row).Error
      Case 5:
         Value = IssueSummary(Row).SisCode
      Case 6:
         Value = IssueSummary(Row).barcode
      Case 7:
         Value = IssueSummary(Row).IssType
   End Select

End Sub

Private Sub IssueGrid_Click()
   If Me.IssueGrid.ListItems.count > 0 Then
      If Me.IssueGrid.SelectedItem.index = 0 Then
         IssueGrid_RowChange 1
      Else
         IssueGrid_RowChange Me.IssueGrid.SelectedItem.index
      End If
   End If
End Sub

Private Sub IssueGrid_ItemClick(ByVal Item As MSComctlLib.ListItem)
'MsgBox Item.text
If Me.IssueGrid.ListItems.count > 0 Then
   IssueGrid_RowChange Me.IssueGrid.SelectedItem.index
End If
End Sub





Private Sub IssueGrid_Validate_2Do(Row As Long, Col As Integer, Value As String, Cancel As Integer)
'13Feb98 CFY Code changes due to way error handling has altered.
'24Oct01 TH  Extra check (And) to prevent error on 15th line with formulas using all available lines (#53508)

Dim Errors$, FatalErr%, i%
   
   Select Case Col
      Case 2:
''         IssueSummary(Row).Qty = Val(Value)
''         i = 1
''         Me.cmdOK.Enabled = True
''         Do While Trim$(IssueSummary(i).SisCode) <> "" And i <= 15 '24Oct01 TH Extra check (And) to prevent error on 15th line
''            d.SisCode = IssueSummary(i).SisCode
''            d.Barcode = IssueSummary(i).Barcode
''            DoChkIssue IssueSummary(i).Qty, d, IssueSummary(i).IssType, Errors$
''            If Not k.escd Then
''                  IssueSummary(i).Error = Errors$
''                  i = i + 1
''                Else
''                  cmdCancel_Click
''                  Exit Sub                         '<--- WAY OUT
''            End If
''         Loop
''
''         IssueGrid.Refresh
   
   End Select

         
End Sub
Public Sub IssueGrid_FetchRow()
'28Aug98 TH  Changed format of qty to suppress stray decimal points
'24Sep98 TH  Changed formats
Dim AllErrors$, Numoflines%, temp$
Dim intRowLoop As Integer
Dim strKey As String
Dim strValue As String
Dim Col As Integer
Dim IssueItem       As ListItem
Dim IssueSubItem    As ListSubItem
   ReDim ErrorLines$(5)
   
   IssueGrid.ListItems.Clear
For intRowLoop = 1 To 15
   strKey = "R" & CStr(intRowLoop)
   'strValue = Right$(IssueSummary(intRowLoop).desc, Len(IssueSummary(intRowLoop).desc) - 8) '24Apr04 TH just show desc
   strValue = Right$(IssueSummary(intRowLoop).desc, Len(IssueSummary(intRowLoop).desc) - 8) '24Apr04 TH just show desc
   Set IssueItem = Me.IssueGrid.ListItems.Add(, strKey & ":C1", strValue)
   For Col = 2 To 7
   ''strValue = ""
   Select Case Col
      'Case 1:
      '   strValue = IssueSummary(intRowLoop).desc
      Case 2:
         'If IssueSummary(intRowLoop).Qty <> 0 Then
         If (InStr(IssueSummary(intRowLoop).SisCode, Chr(0)) = 0) And (Trim$(IssueSummary(intRowLoop).SisCode) <> "") Then
            'Value = Str$(IssueSummary(row).Qty)
            'Value = Format$(IssueSummary(row).Qty, "0.#####") '13Jun98 ASC
            'Value = Format$(IssueSummary(row).Qty) '28Aug98 TH
            strValue = Format$(IssueSummary(intRowLoop).Qty, "0.#####")  '24Sep98 TH
            'Value = Format$(IssueSummary(row).Qty) '28Aug98 TH
            strValue = Format$(strValue) '24Sep98 TH
         'Else                 '04May05 TH Added
         '   strValue = 0      '   "
         End If
      Case 3:
         strValue = IssueSummary(intRowLoop).Unit
      Case 4:
         strValue = IssueSummary(intRowLoop).Error
      Case 5:
         strValue = IssueSummary(intRowLoop).SisCode
      Case 6:
         strValue = IssueSummary(intRowLoop).barcode
      Case 7:
         strValue = IssueSummary(intRowLoop).IssType
   End Select
   strValue = Trim$(strValue)
   IssueItem.ListSubItems.Add , strKey & ":C" & CStr(Col), strValue
   Next

Next
   
End Sub
Public Sub issuegridupdateQty()
Dim intRow As Integer
Dim lvwItem       As ListItem
Dim lvwSubItem    As ListSubItem
intRow = IssueGrid.SelectedItem.index
      Set lvwItem = IssueGrid.ListItems(intRow)
      
         Set lvwSubItem = lvwItem.ListSubItems(1)
         lvwSubItem.text = Format$(Val(txtQty.text))
         Set lvwSubItem = lvwItem.ListSubItems(3)
         lvwSubItem.text = IssueSummary(intRow).Error
        
End Sub

Private Sub Text1_GotFocus()
lblDate_Click
End Sub

Public Sub Text1_KeyDown(KeyCode As Integer, Shift As Integer)
'MsgBox "yow"
End Sub
Public Sub IssueGrid_RowChange(ByVal lngNewRow As Long)
'

''Dim snap As snapshot
''Dim SQL$, criteria$,
Dim default$

Dim strParams As String
Dim dlocal As DrugParameters
Dim strDescription As String

   If lngNewRow = 0 Then lngRow = 0: Exit Sub
   ''If lngRow <> Me.LvwMainScreen.SelectedItem.Index Then
''   If blnChangeFlag Then UpdateStockLevels
   If lngRow <> lngNewRow Then
      ''lngRow = Me.LvwMainScreen.SelectedItem.Index
      lngRow = lngNewRow
      
      
      If lngRow Then
         If trimz(IssueSummary(lngRow).SisCode) <> "" Then
            dlocal.SisCode = trimz(IssueSummary(lngRow).SisCode)
            getdrug dlocal, 0, 0, False
            UpdatePanel dlocal
            'If PicInfo1.Visible = True Then PicInfo1.Height = Frame2.Height - 80
            
            'strDescription = dlocal.storesdescription
            'If Trim$(strDescription) = "" Then strDescription = dlocal.Description
			strDescription = dlocal.DrugDescription
            plingparse strDescription, "!"
            lblStoresDesc.Caption = strDescription
            lblUnits.Caption = IssueSummary(lngRow).Unit
            lblStockLevel.Caption = " Current Stock Level :  " & Trim$(dlocal.stocklvl) & " " & Trim$(IssueSummary(lngRow).Unit)
            txtQty.text = IssueSummary(lngRow).Qty
            txtQty.Visible = True
         Else
            lblStoresDesc.Caption = ""
            lblUnits.Caption = ""
            txtQty.Visible = False
            lblStockLevel.Caption = ""
            'clear panel
            PicInfo1.Visible = False
         End If
      End If

   End If
   
   If Trim$(lblStoresDesc.Caption) = "" Then
      txtQty.Visible = False
      lblStockLevel.Caption = ""
   End If
   
End Sub
Private Sub IssueGrid_KeyDown(KeyCode As Integer, Shift As Integer)
Dim lngRow As Long
Dim intloop As Integer
   Select Case KeyCode
''   Text1.text = IssueGrid.ListItems(IssueGrid.SelectedItem.Index).ListSubItems(1).text
''   Text1_KeyDown KeyCode, Shift
''   IssueGrid.ListItems(IssueGrid.SelectedItem.Index).ListSubItems(1).text = Text1.text
      Case 13:
         k.escd = 0
''         If mnuStockTake(5).Checked Then              'Authorise stock level
''            ''lngRow = LvwMainScreen.RowIndex
''            For intloop = 1 To lvwMainScreen.ListItems.count
''               If lvwMainScreen.ListItems(intloop).Selected = True Then
''                  'intLoop = LvwMainScreen.SelectedItem.Index
''                  If intloop Then                           'Authorise changes here
''                     StockTakeAdjustLevel SiteCode$, STname$, stnsv(intloop), "", intloop
''                     ''LvwMainScreen.RefreshRow = 0
''                     lvwMainScreen_RowChange intloop
''                     If k.escd Then Exit For
''                  End If
''               End If
''            Next
''         End If
         KeyCode = 0
         k.escd = 0
      Case 38:
         If Me.IssueGrid.SelectedItem.index > 0 Then '''1 Then
            'Me.LvwMainScreen.ListItems(Me.LvwMainScreen.SelectedItem.Index).selected = False
            ''lngRow = Me.LvwMainScreen.SelectedItem.Index - 1
            lngRow = Me.IssueGrid.SelectedItem.index
            ''Me.LvwMainScreen.ListItems(Me.LvwMainScreen.SelectedItem.Index).selected = False ''''
            IssueGrid.SetFocus
            'Me.LvwMainScreen.ListItems(lngRow).selected = True
            IssueGrid_RowChange (lngRow)
            ''If GetMStockTakeMode = 1 Then txtStockLvl1.SetFocus
         End If
      
      Case 40
         ''If Me.LvwMainScreen.SelectedItem.Index < Me.LvwMainScreen.ListItems.count Then
         If Me.IssueGrid.SelectedItem.index <= Me.IssueGrid.ListItems.count Then
            ''lngRow = Me.LvwMainScreen.SelectedItem.Index + 1
            '''Me.LvwMainScreen.ListItems(Me.LvwMainScreen.SelectedItem.Index).selected = False ''''
            lngRow = Me.IssueGrid.SelectedItem.index
            IssueGrid.SetFocus
            IssueGrid_RowChange (lngRow)
         End If
      'Move this to KeyPress so works better XN 19Aug15 118279
      'Case Else
         'If KeyCode > 47 And KeyCode < 58 Or KeyCode = 46 Or KeyCode = 190 Then
               'txtStockLvl1.SetFocus
               ''blnChangeFlag = True
          '     txtQty.text = Chr(KeyCode)
           '    txtQty.SetFocus
'            End If
   End Select
End Sub

'When user types number of grid move to the qty screen
'XN 19Aug15 118279
Private Sub IssueGrid_KeyPress(KeyAscii As Integer)
    If KeyAscii > 47 And KeyAscii < 58 Or KeyAscii = 46 Then
       txtQty.SetFocus
       txtQty.text = Chr(KeyAscii)
       txtQty.SelStart = 2
    End If
End Sub

Private Sub Label4_Click()
   lblDate_Click
End Sub

Private Sub lblDate_Click()
'19Jan16 TH Changes to allow for caching of PrepDate TFS 124077
Dim strAns As String
Dim strWorkingdate As String
Dim strbatchexpiry As String
Dim valid As Integer
Dim strResult As String    '19Jan16 TH (TFS 124077)
Dim strParams As String    '    "
Dim lngOK As Long          '    "
Dim strDate As String      '19Jan16 TH Added (TFS 124077)
Dim strTime As String      '    "
Dim td As DateAndTime      '19Jan16 TH Added (TFS 124077)
Dim dt As DateAndTime      '    "


   strAns = lblDate.Caption
   'IssueGrid.SetFocus
   If CmdOK.Enabled Then
      On Error Resume Next
      CmdOK.SetFocus
      On Error GoTo 0
   Else
      On Error Resume Next
      CmdCancel.SetFocus
      On Error GoTo 0
   End If
   Do
      inputwin "Calculate expiry", "Enter DATE when stock will be manufactured", strAns, k
      If k.escd Then k.escd = False: Exit Sub    '24Feb99 SF added
      parsedate strAns, strWorkingdate, "8", valid
      If strWorkingdate <> strAns Then valid = False: strAns = strWorkingdate
   Loop Until valid
   
   '19Jan16 TH Here we now need to offer to store this for the terminal/session.(TFS 124077)
   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "Y", "PreparationDateCache", 0)) Then
      frmoptionset -1, "Manufacturing - Preparation Date and Time"
      
      frmoptionset 1, "Use this preparation date and time for this issue only"
      frmoptionset 1, "Retain this preparation date and time for this use this session"
      frmoptionset 1, "Retain this preparation date and time for this use on this terminal"
      
      frmoptionshow "1", strResult
      frmoptionset 0, ""
      Select Case strResult
      Case "1" 'Clean out the cache for this session and terminal
            lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWManufacturingPreparationDateCacheClear", "")
      Case "2" ' Save in the cache table under this sessionID
            strParams = gTransport.CreateInputParameterXML("PreparationDate", trnDataTypeVarChar, 10, strAns) & _
            gTransport.CreateInputParameterXML("PreparationTime", trnDataTypeVarChar, 10, lblTime.Caption)
            lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWManufacturingPreparationDateCacheSessionWrite", strParams)
      Case "3" ' Save in the cache table under the current terminalID
            strParams = gTransport.CreateInputParameterXML("PreparationDate", trnDataTypeVarChar, 10, strAns) & _
            gTransport.CreateInputParameterXML("PreparationTime", trnDataTypeVarChar, 10, lblTime.Caption)
            lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWManufacturingPreparationDateCacheTerminalWrite", strParams)
      End Select
   
   End If
   
   lblDate.Caption = strAns
   
   'is the date/time in the past ?
      strDate = lblDate.Caption
   parsedate strDate, strDate, "8", 0
      
   strTime = lblTime.Caption
   parsetime strTime, strTime, "1", 0
   
   
   StringToDate strDate, dt
   StringToTime strTime, dt
   datetomins dt
   today td
   If dt.mint <= td.mint Then
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "Y", "PreparationDatePastWarning", 0)) Then
         popmessagecr "!Manufacturing Preparation Date", TxtD(dispdata$ & "\patmed.ini", "manufacturing", "Preparation date is set in the past", "PreparationDatePastWarningMsg", 0)
      End If
      lblDate.BackColor = &H8080FF
      lblTime.BackColor = &H8080FF
   Else
      lblDate.BackColor = &H80C0FF
      lblTime.BackColor = &H80C0FF
   End If
   lblDate.font.Italic = True
   lblTime.font.Italic = True
   
   'Now calculate the expiry
   Heap 11, gPRNheapID, "ProductNSV", d.SisCode, 0
   getdrug d, 0, 0, False
   MakeExpiry k, lblDate.Caption, lblTime.Caption, strbatchexpiry
   setexpirydate strbatchexpiry
   lblExpiry.Caption = strbatchexpiry
   
End Sub

Private Sub lblTime_Click()
'19Jan16 TH Changes to allow for caching of PrepDate TFS 124077

Dim strAns As String
Dim strWorkingTime As String
Dim strbatchexpiry As String
Dim valid As Integer
Dim strResult As String  '19Jan16 TH (TFS 124077)
Dim strParams As String  '    "
Dim lngOK As Long        '    "
Dim strDate As String      '19Jan16 TH Added (TFS 124077)
Dim strTime As String      '    "
Dim td As DateAndTime      '19Jan16 TH Added (TFS 124077)
Dim dt As DateAndTime      '    "

   strAns = lblTime.Caption
   'IssueGrid.SetFocus
   If CmdOK.Enabled Then
      On Error Resume Next
      CmdOK.SetFocus
      On Error GoTo 0
   Else
      On Error Resume Next
      CmdCancel.SetFocus
      On Error GoTo 0
   End If
   Do
      inputwin "Calculate expiry", "Enter TIME when stock will be manufactured", strAns, k
      If k.escd Then k.escd = False: Exit Sub     '24Feb99 SF added
      parsetime strAns, strWorkingTime, "1", valid
      If strWorkingTime <> strAns Then valid = False: strAns = strWorkingTime
   Loop Until valid
   
   '19Jan16 TH Here we now need to offer to store this for the terminal/session.(TFS 124077)
   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "Y", "PreparationDateCache", 0)) Then
      frmoptionset -1, "Manufacturing - Preparation Date and Time"
      
      frmoptionset 1, "Use this preparation date and time for this issue only"
      frmoptionset 1, "Retain this preparation date and time for this use this session"
      frmoptionset 1, "Retain this preparation date and time for this use on this terminal"
      
      frmoptionshow "1", strResult
      frmoptionset 0, ""
      Select Case strResult
      Case "1" 'Clean out the cache for this session and terminal
            lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWManufacturingPreparationDateCacheClear", "")
      Case "2" ' Save in the cache table under this sessionID
            strParams = gTransport.CreateInputParameterXML("PreparationDate", trnDataTypeVarChar, 10, lblDate.Caption) & _
            gTransport.CreateInputParameterXML("PreparationTime", trnDataTypeVarChar, 10, strAns)
            lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWManufacturingPreparationDateCacheSessionWrite", strParams)
      Case "3" ' Save in the cache table under the current terminalID
            strParams = gTransport.CreateInputParameterXML("PreparationDate", trnDataTypeVarChar, 10, lblDate.Caption) & _
            gTransport.CreateInputParameterXML("PreparationTime", trnDataTypeVarChar, 10, strAns)
            lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWManufacturingPreparationDateCacheTerminalWrite", strParams)
      End Select
   
   End If
   lblTime.Caption = strAns
   
   'is the date/time in the past ?
   strDate = lblDate.Caption
   parsedate strDate, strDate, "8", 0
      
   strTime = lblTime.Caption
   parsetime strTime, strTime, "1", 0
   
   StringToDate strDate, dt
   StringToTime strTime, dt
   datetomins dt
   today td
   If dt.mint <= td.mint Then
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "Y", "PreparationDatePastWarning", 0)) Then
         popmessagecr "!Manufacturing Preparation Date", TxtD(dispdata$ & "\patmed.ini", "manufacturing", "Preparation date is set in the past", "PreparationDatePastWarningMsg", 0)
      End If
      lblDate.BackColor = &H8080FF
      lblTime.BackColor = &H8080FF
   Else
      lblDate.BackColor = &H80C0FF
      lblTime.BackColor = &H80C0FF
   End If
   lblDate.font.Italic = True
   lblTime.font.Italic = True
      
   'Now calculate the expiry
   Heap 11, gPRNheapID, "ProductNSV", d.SisCode, 0
   getdrug d, 0, 0, False
   MakeExpiry k, lblDate.Caption, lblTime.Caption, strbatchexpiry
   setexpirydate strbatchexpiry
   lblExpiry.Caption = strbatchexpiry
   
   

End Sub

Private Sub Text1_KeyPress(KeyAscii As Integer)
MsgBox "yow"
End Sub

Private Sub Text2_GotFocus()
lblTime_Click
End Sub

Private Sub Text3_GotFocus()
On Error Resume Next
txtBatchNumber.SetFocus
If Err Then
   CmdOK.SetFocus
End If
On Error GoTo 0
End Sub

Private Sub TxtQty_Change()
Dim intRow As Integer
Dim i As Integer
Dim Errors$

intRow = IssueGrid.SelectedItem.index

If Val(IssueSummary(intRow).Qty) <> Val(txtQty.text) Then

         IssueSummary(intRow).Qty = Val(txtQty.text)
         i = 1
         Me.CmdOK.Enabled = True
         Do While Trim$(IssueSummary(i).SisCode) <> "" And i <= 15 '24Oct01 TH Extra check (And) to prevent error on 15th line
            d.SisCode = IssueSummary(i).SisCode
            d.barcode = IssueSummary(i).barcode
            DoChkIssue IssueSummary(i).Qty, d, IssueSummary(i).IssType, Errors$
            If Not k.escd Then
                  IssueSummary(i).Error = Errors$
                  i = i + 1
                Else
                  cmdCancel_Click
                  Exit Sub                         '<--- WAY OUT
            End If
         Loop
         
         'IssueGrid_Refresh
         issuegridupdateQty
   
End If
End Sub

Private Sub TxtQty_KeyDown(KeyCode As Integer, Shift As Integer)
Dim intline As Integer
Select Case KeyCode
Case 38 'cursor up
   If Shift = 0 Then
      If IssueGrid.ListItems.count > 0 Then
         If IssueGrid.SelectedItem.index > 1 Then
            intline = IssueGrid.SelectedItem.index
            IssueGrid.ListItems(intline).Selected = False
            IssueGrid.ListItems(intline - 1).Selected = True
         End If
         ''If blnChangeFlag And (GetMStockTakeMode() = 1) Then UpdateStockLevels
         IssueGrid_KeyDown KeyCode, Shift

         IssueGrid.SetFocus
      End If
   End If
Case 40 'cursor down
   If Shift = 0 Then
      ''LvwMainScreen.SetFocus
      If IssueGrid.ListItems.count > 0 Then
         If IssueGrid.SelectedItem.index < IssueGrid.ListItems.count Then
            intline = IssueGrid.SelectedItem.index
            IssueGrid.ListItems(intline).Selected = False
            IssueGrid.ListItems(intline + 1).Selected = True
         End If
''         If blnChangeFlag And (GetMStockTakeMode() = 1) Then UpdateStockLevels
         IssueGrid_KeyDown KeyCode, Shift
         IssueGrid.SetFocus
      End If
   End If
Case Else
   
End Select
End Sub
