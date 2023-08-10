VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form RoqAndRol 
   Appearance      =   0  'Flat
   Caption         =   "Roq and Rol"
   ClientHeight    =   6150
   ClientLeft      =   3555
   ClientTop       =   4575
   ClientWidth     =   13245
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
   Icon            =   "ROQROL.frx":0000
   LinkTopic       =   "Form1"
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6150
   ScaleWidth      =   13245
   Begin MSComDlg.CommonDialog dlgRoqAndRol 
      Left            =   6360
      Top             =   5040
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin MSComctlLib.ListView lvwRoqRol 
      Height          =   4575
      Left            =   0
      TabIndex        =   6
      Top             =   1030
      Width           =   13245
      _ExtentX        =   23363
      _ExtentY        =   8070
      LabelWrap       =   0   'False
      HideSelection   =   -1  'True
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
   End
   Begin VB.PictureBox dlgRoqAndRolx 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   480
      Left            =   8880
      ScaleHeight     =   450
      ScaleWidth      =   1170
      TabIndex        =   5
      Top             =   5040
      Width           =   1200
   End
   Begin VB.PictureBox picFooter 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
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
      Height          =   495
      Left            =   0
      ScaleHeight     =   465
      ScaleWidth      =   13185
      TabIndex        =   4
      TabStop         =   0   'False
      Top             =   5640
      Width           =   13215
      Begin MSComctlLib.ProgressBar progressBar 
         Height          =   495
         Left            =   3480
         TabIndex        =   8
         Top             =   0
         Visible         =   0   'False
         Width           =   9735
         _ExtentX        =   17171
         _ExtentY        =   873
         _Version        =   393216
         Appearance      =   1
      End
   End
   Begin VB.PictureBox picHeader 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
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
      Height          =   330
      Left            =   0
      ScaleHeight     =   300
      ScaleWidth      =   13215
      TabIndex        =   1
      Top             =   0
      Width           =   13245
      Begin VB.PictureBox picToolBar 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
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
         Left            =   0
         ScaleHeight     =   285
         ScaleWidth      =   4245
         TabIndex        =   2
         Top             =   0
         Width           =   4245
         Begin VB.PictureBox cmdToolbar 
            Appearance      =   0  'Flat
            AutoSize        =   -1  'True
            BackColor       =   &H80000005&
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
            ForeColor       =   &H80000008&
            Height          =   285
            Index           =   0
            Left            =   0
            ScaleHeight     =   255
            ScaleWidth      =   795
            TabIndex        =   3
            TabStop         =   0   'False
            Top             =   0
            Visible         =   0   'False
            Width           =   825
         End
         Begin VB.Line lineToolBar 
            Visible         =   0   'False
            X1              =   990
            X2              =   1710
            Y1              =   135
            Y2              =   135
         End
      End
   End
   Begin VB.PictureBox TblDisplay 
      Appearance      =   0  'Flat
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
      Height          =   1800
      Left            =   0
      ScaleHeight     =   1770
      ScaleWidth      =   11775
      TabIndex        =   0
      Top             =   2115
      Width           =   11805
   End
   Begin VB.Label lblHeading 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00800000&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label1"
      ForeColor       =   &H80000008&
      Height          =   705
      Index           =   0
      Left            =   0
      TabIndex        =   7
      Top             =   360
      Visible         =   0   'False
      Width           =   1935
      WordWrap        =   -1  'True
   End
   Begin VB.Line Line1 
      X1              =   0
      X2              =   11880
      Y1              =   0
      Y2              =   0
   End
   Begin VB.Menu MnuFileTop 
      Caption         =   "&File"
      Begin VB.Menu mnuRoqAndRol 
         Caption         =   "&Print"
         Index           =   0
         Shortcut        =   ^P
      End
      Begin VB.Menu mnuRoqAndRol 
         Caption         =   "&Export"
         Index           =   1
         Shortcut        =   ^E
      End
      Begin VB.Menu mnuRoqAndRol 
         Caption         =   "P&rint and Update"
         Index           =   2
         Shortcut        =   ^R
      End
      Begin VB.Menu mnuRoqAndRol 
         Caption         =   "&Update"
         Index           =   3
         Shortcut        =   ^U
      End
      Begin VB.Menu mnuRoqAndRol 
         Caption         =   "-"
         Index           =   4
      End
      Begin VB.Menu mnuRoqAndRol 
         Caption         =   "E&xit"
         Index           =   5
         Shortcut        =   ^X
      End
   End
   Begin VB.Menu mnuOptionsTop 
      Caption         =   "&Options"
      Begin VB.Menu mnuRoqAndRolOptions 
         Caption         =   "&Lines Per Sheet"
         Index           =   0
      End
   End
   Begin VB.Menu mnuHelphdg 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelp 
         Caption         =   "&Contents                             F1"
         Index           =   0
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "&Search For Help On ..."
         Index           =   1
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "&How To Use Help"
         Index           =   2
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "-"
         Index           =   3
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "&About"
         Index           =   4
      End
   End
End
Attribute VB_Name = "RoqAndRol"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'-------------------------------------------------------------------------------------------------------------
'                    ROQ and ROL Form
'
'16Jan07 PJC Created (RR enh)
'08Mar07 PJC Form_Load: Changes to stock level column width, column width and form width are now configurable following AS initial testing. (RR enh)
'23Jun08 XN  F0033906 Now used the ICW desktop F4 screens.
'23Apr10 XN  F0058248 Added progress bar to Roq and Rol form
'07Aug11 TH  Form_Activate: F0124679 Added error suppression as this was causing an error when called from re-initialisation from a library module
'                           Not sure why, but seems a standard problem according to forums. Resume seems cheapest effective option.

'-------------------------------------------------------------------------------------------------------------

Option Explicit
DefInt A-Z

Const modulename$ = "ROQROL.FRM"

Dim mintLinesPerPage As Integer
Dim mlngForeColour As Long
Dim mlngBackColour As Long

Private Sub cmdToolbar_Click(Index As Integer)
'16Jan07 PJC Created (RR enh)

   DoToolBarButton (cmdToolbar(Index).Tag)

End Sub

Private Sub Form_Activate()
'29Sep10 TH F0097121 ensure the first line in the table is highlighted
'07Aug11 TH F0124679 Added error suppression as this was causing an error when called from re-initialisation from a library module
'                    Not sure why, but seems a standard problem according to forums. Resume seems cheapest effective option.
   On Error Resume Next
   
   Me.lvwRoqRol.SetFocus '29Sep10 TH F0097121
   On Error GoTo 0
End Sub

Private Sub Form_Load()
'16Jan07 PJC created, set up the grid for the roq and rol form (RR enh)
'08Mar07 PJC Changes to stock level column width, column width and form width are now configurable following AS initial testing. (RR enh)
Dim X As Integer
Dim found%
Dim tempnum%
Dim blnHLCells As Integer
Dim intHLSingleCell As Integer
Dim colwidth As Integer
Dim intloop As Integer
Dim lvwItem As ListItem
   
   SetChrome Me
   
   mintLinesPerPage = Val(TxtD(dispdata$ & "\Winord.INI", "RoqAndRol", "20", "LinesPerPage", 0))
   colwidth = 80
''   TblDisplay.Width = Me.ScaleWidth
''   TblDisplay.Rows = 0
''
''   TblDisplay.ColumnName(1) = "Sup"
''   TblDisplay.ColumnName(2) = "Loc"
''   TblDisplay.ColumnName(3) = "Description"
''   TblDisplay.ColumnName(4) = "Code"
''   'TblDisplay.ColumnName(5) = "Stocked"       '08Mar07 PJC Replaced by below following AS initial testing.
''   TblDisplay.ColumnName(5) = "Stk"            '08Mar07 PJC Added
''   TblDisplay.ColumnName(6) = "Cur ROL"
''   TblDisplay.ColumnName(7) = "Sug ROL"
''   TblDisplay.ColumnName(8) = "Cur ROQ"
''   TblDisplay.ColumnName(9) = "Sug ROQ"
''   TblDisplay.ColumnName(10) = "Lead Time"
''   TblDisplay.ColumnName(11) = "Annual use"
''   TblDisplay.ColumnName(12) = "Stk Lvl"
''   TblDisplay.ColumnName(13) = "Cycle Days"
''   TblDisplay.ColumnName(14) = "Update"
Me.lvwRoqRol.View = lvwReport
      Me.lvwRoqRol.ListItems.Clear
      Me.lvwRoqRol.ColumnHeaders.Clear
   
   Me.lvwRoqRol.ColumnHeaders.Add , "H:1", "Sup", 12 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:2", "Loc", 7 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:3", "Description", 51 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:4", "Code", 13 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:5", "Stk", 5 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:6", "Cur ROL", 7 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:7", "Sug ROL", 12 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:8", "Cur ROQ", 7 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:9", "Sug ROQ", 11 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:10", "Lead Time", 6 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:11", "Annual use", 8 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:12", "Stk Lvl", 9 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:13", "Cycle Days", 6 * colwidth
   Me.lvwRoqRol.ColumnHeaders.Add , "H:14", "Update", 7 * colwidth
   'Me.lvwMainScreen.ColumnHeaders.Add , "H:1", "Sup", 480
   'Me.lvwMainScreen.ColumnHeaders.Add , "H:1", "Sup", 480
   Me.lvwRoqRol.GridLines = True
   tempnum% = 14

   blnHLCells = TrueFalse(TxtD(dispdata$ & "\Winord.INI", "RoqAndRol", "Y", "HighlightCells", 0))
   mlngForeColour = Val(TxtD(dispdata$ & "\Winord.INI", "RoqAndRol", "&HFFFFFF", "HLForeColour", 0))
   mlngBackColour = Val(TxtD(dispdata$ & "\Winord.INI", "RoqAndRol", "&HFF", "HLBackColour", 0))
   intHLSingleCell = Val(TxtD(dispdata$ & "\Winord.INI", "RoqAndRol", "14", "HighlightSingleCell", 0))

''   For x = 1 To tempnum%
''      If x <= 13 Then
''            'TblDisplay.ColumnWidth(X) = Choose(X, 8, 5, 45, 10, 8, 5, 10, 5, 10, 5, 9, 7, 6)       '08Mar07 PJC Replaced by below. Change to Stocked and stock level column width following AS initial testing.
''            TblDisplay.ColumnWidth(x) = Choose(x, 8, 5, 45, 10, 3, 6, 11, 6, 10, 5, 9, 9, 6)        '          "
''         Else
''            TblDisplay.ColumnWidth(x) = Choose(x - 13, 8)
''         End If
''
''      '08Mar07 PJC Added to make all column widths configurable. overiding the defaults above after AS initial testing..
''      TblDisplay.ColumnWidth(x) = Val(TxtD(dispdata$ & "\Winord.INI", "RoqAndRol", Format$(TblDisplay.ColumnWidth(x)), "ColumnWidth" & Format$(x), 0))
''
''      TblDisplay.ColumnVisible(x) = True
''      Select Case x
''         Case 5, 10, 14:                  TblDisplay.ColumnStyle(x) = 1 + 8192 + &H20  'Centered, readonly, centred heading
''         Case 3, 4:                         TblDisplay.ColumnStyle(x) = 8192 + &H20      'readonly, centred heading
''         Case 1, 2, 7, 9, 11, 12, 13:  TblDisplay.ColumnStyle(x) = 2 + 8192 + &H20  'right justified, readonly, centred heading
''         Case 6, 8:                       TblDisplay.ColumnStyle(x) = 5 + 8192 + &H20  'right justified, readonly, centred heading
''      End Select
''      If blnHLCells = True Then
''            If intHLSingleCell = 0 Or intHLSingleCell = x Then
''                  TblDisplay.ColumnCellAttrs(x) = True
''               End If
''         End If
''   Next
   
   HeaderDisplay Me, Me.lvwRoqRol, Create, 20

''   TblDisplay.SelectedBackColor = QBColor(7)
''   TblDisplay.SelectMode = 0
''   TblDisplay.MarqueeStyle = 3
''
''   TblDisplay.ParamBackColor = QBColor(7) ' Grey
''   TblDisplay.ParamStatus = -1            ' Apply to all cells
   
   Me.Width = Val(TxtD(dispdata$ & "\Winord.INI", "RoqAndRol", Format$(Me.Width), "FormWidth", 0))         '08Mar07 PJC Added to resize form width if required after AS initial testing.


fillrqroltable Me





   CentreForm Me
'''   For intloop = 1 To UBound(RoqAndRolLines)
'''      lngPtr = RoqAndRolLines(intloop, 1)                             '        "
'''      getdrug d, lngPtr, found&, False                               '        "
'''
'''      If found& Then
'''         strKey = "R" & CStr(lngRow)
'''         Set lvwRoqRol = Me.lvwRoqRol.ListItems.Add(, strKey & ":C1", Trim$(d.supcode))
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C2", Trim$(d.loccode)
'''         strValue = trimz$(GetStoresDescription())
'''               plingparse strValue, "!"
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C3", strValue
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C4", Trim$(d.SisCode)
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C5", Trim$(d.sisstock)
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C6", Trim$(d.reorderlvl)
'''         RoqAndRolCalc d, lngRoq, lngRol
'''         strValue = Format$(lngRol) & " " & Trim$(d.PrintformV)
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C7", strValue
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C8", Trim$(d.reorderqty)
'''         RoqAndRolCalc d, lngRoq, lngRol
'''         strValue = Format$(lngRoq) & " x " & Trim$(d.convfact)
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C9", strValue
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C10", Trim$(d.leadtime)
'''         DoEOPAnnualUseCalc d
'''         strValue = Format$(d.anuse, "#0")
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C11", strValue
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C12", Trim$(d.stocklvl)
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C13", Trim$(d.cyclelength)
'''         strValue = Iff(RoqAndRolLines(intRow, 2) = -1, "Y", "N")
'''         lvwRoqRol.ListSubItems.Add , strKey & ":C14", strValue
'''      End If
'''   Next
   
               
''         Select Case intCol
''            Case 1: strValue = Trim$(d.supcode)
''            Case 2: strValue = Trim$(d.loccode)
''            Case 3
''               strValue = trimz$(GetStoresDescription())
''               plingparse strValue, "!"
''            Case 4: strValue = Trim$(d.SisCode)
''            Case 5: strValue = Trim$(d.sisstock)
''            Case 6: strValue = Trim$(d.reorderlvl)
''            Case 7:
''               RoqAndRolCalc d, lngRoq, lngRol
''               strValue = Format$(lngRol) & " " & Trim$(d.PrintformV)
''            Case 8: strValue = Trim$(d.reorderqty)
''            Case 9:
''               RoqAndRolCalc d, lngRoq, lngRol
''               strValue = Format$(lngRoq) & " x " & Trim$(d.convfact)
''            Case 10: strValue = Trim$(d.leadtime)
''            Case 11
''                  DoEOPAnnualUseCalc d
''                  strValue = Format$(d.anuse, "#0")
''            Case 12: strValue = Trim$(d.stocklvl)
''            Case 13: strValue = Format$(d.cyclelength) 'ordercycle As String * 2  OR cyclelength As Integer
''            'Case 14: strValue = RoqAndRolLines(intRow, 2)                          '08Mar07 PJC RoqAndRolLines array now stores position of drug.
''            Case 14: strValue = Iff(RoqAndRolLines(intRow, 2) = -1, "Y", "N")       '        "
''         For intloop = 2 To intNumofColumns 'Loop through the columns
''               'set the key (rX:cX)
''               ''If blnNewItem Then
''                  lvwItem.ListSubItems.Add , strKey & ":C" & CStr(intloop), lines$(intloop)
''
''               ''Else
''                  'lvwItem.ListSubItems.item (":C1" & CStr(intLoop))
''               ''End If
''            Next
''         End Select
''      End If
''   Next
''
''   If ONumToDisplay > 0 Then
''      For lngRow = 1 To UBound(OInfoStore)
''         If (lngRow + (DispPgNo * OInfoMaxLen)) <= UBound(OInfoStore) Then
''            rowline$ = OInfoStore(lngRow + (DispPgNo * OInfoMaxLen))
''            replace rowline$, "||", "| |", 0
''            'rowline$ = replace(rowline$, "||", "| |", 1, 0, 0)
''            deflines rowline$, lines$(), "|(*)", 1, intNumofColumns
''            'set the key here for row and column to enter the row data
''            'Value = Trim$(lines$(col))
''            strKey = "R" & CStr(lngRow)
''            ''If blnNewItem Then
''               Set lvwItem = MainScreen.lvwMainScreen.ListItems.Add(, strKey & ":C1", lines$(1))
''               If blnWardStock And lines$(5) = "&" Then '08Nov05 Complicated switch to ensure titles are bold for WSList. Hack . Sorry
''                  lines$(5) = ""
''                  lvwItem.Bold = True
''               End If
''
''            ''Else
''            ''   'Set lvwItem = lvwMainScreen.FindItem(strKey & ":C1")
''            ''   Set lvwItem = MainScreen.lvwMainScreen.ListItems.item(lngRow)
''            ''   lvwItem.Text = lines$(1)
''            ''End If
''            'lvwItem.ListSubItems.Add , strKey & ":C1", lines$(1)
''
''            For intloop = 2 To intNumofColumns 'Loop through the columns
''               'set the key (rX:cX)
''               ''If blnNewItem Then
''                  lvwItem.ListSubItems.Add , strKey & ":C" & CStr(intloop), lines$(intloop)
''
''               ''Else
''                  'lvwItem.ListSubItems.item (":C1" & CStr(intLoop))
''               ''End If
''            Next
''        End If
''        Next
''
''   SetToolBarIniFile Me, dispdata$ & "\winordtb.ini"
''   SetToolBarView Me, "RoqandRol"
''   TblDisplay.Rows = NumberOfRoqAndRolLines()
''   TblDisplay.RowIndex = 1

ReDim Preserve clr(Me.lvwRoqRol.ListItems.count)
   'Initialise the subclassing
   g_MaxItems = Me.lvwRoqRol.ListItems.count - 1
   g_addProcOld = SetWindowLong(Hwnd, GWL_WNDPROC, AddressOf WindowProc)
   
   '02Dec08 TH (F0039482)
   If Me.lvwRoqRol.ListItems.count > 0 Then
      For intloop = 1 To lvwRoqRol.ListItems.count
         Set lvwItem = Me.lvwRoqRol.ListItems(intloop)
         SetLIBackColor Me.lvwRoqRol, intloop, White
         SetLIForeColor Me.lvwRoqRol, lvwItem.Index, Black '21Nov08 TH Added
      Next
   End If
   '-------------
   
   SetPicFooter 0
''   TblDisplay.Refresh
   Screen.MousePointer = STDCURSOR
   
   
   
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
'16Jan07 PJC Created (RR enh)
    
   If UnloadMode <> 1 Then    'anything except unload by code
         Cancel = True
         Me.Hide
      End If

End Sub

Private Sub Form_Resize()
'16Jan07 PJC Created (RR enh)

   On Error Resume Next
   picHeader.Width = Me.ScaleWidth
   TblDisplay.Width = Me.ScaleWidth
   picFooter.Width = Me.ScaleWidth
   picFooter.Height = Me.ScaleHeight - picFooter.Top
   progressBar.Height = Me.ScaleHeight - picFooter.Top  ' 23Apr10 XN F0058248 Added progress bar to Roq and Rol form
   On Error GoTo 0

End Sub

Private Function IncludeNonUpdatesInRoqAndRolOutput(blnExport As Integer) As Integer
'16Jan07 PJC Created (RR enh)
Dim blnRet As Integer
Dim strAns As String

   blnRet = True
   If TrueFalse(TxtD(dispdata$ & "\Winord.INI", "RoqAndRol", "N", "AskOutPutNonUpdate", 0)) Then
         strAns = "N"
         askwin "?EMIS Health", "Exclude products not to be updated from appearing " & Iff(blnExport, "in the export", "on the print out") & "?", strAns, k
         If Not k.escd And strAns = "Y" Then
               blnRet = False
            End If
      End If
   IncludeNonUpdatesInRoqAndRolOutput = blnRet
End Function

Private Sub Form_Unload(Cancel As Integer)
   SetWindowLong Hwnd, GWL_WNDPROC, g_addProcOld
End Sub

Private Sub lvwRoqRol_DblClick()
Dim intloop As Integer
Dim lvwItem As ListItem
   For intloop = 1 To lvwRoqRol.ListItems.count
      If lvwRoqRol.ListItems(intloop).Selected = True Then
         'intLoop = LvwMainScreen.SelectedItem.Index
         If intloop Then                           'Authorise changes here
            'StockTakeAdjustLevel SiteCode$, STname$, stnsv(intloop), "", intloop
            '''strValue = RoqAndRolUpdateValue(Val(TblDisplay.RowIndex))
            'lvwMainScreen_RowChange intloop
            If lvwRoqRol.ListItems(intloop).ListSubItems.Item(13).Text = "Y" Then
               lvwRoqRol.ListItems(intloop).ListSubItems.Item(13).Text = "N"
               'set to right
                Set lvwItem = lvwRoqRol.SelectedItem
               If Len(Trim(lvwItem.Text)) = 0 Then Exit Sub
               SetLIBackColor lvwRoqRol, lvwItem.Index, Red
               SetLIForeColor lvwRoqRol, lvwItem.Index, White '21Nov08 TH Added
            Else
               lvwRoqRol.ListItems(intloop).ListSubItems.Item(13).Text = "Y"
               'set to red
               'SetLIBackColor lvwRoqRol, intloop, Red
               Set lvwItem = lvwRoqRol.SelectedItem
               If Len(Trim(lvwItem.Text)) = 0 Then Exit Sub
               'SetLIBackColor lvwRoqRol, lvwItem.Index, vbRed
               SetLIBackColor lvwRoqRol, lvwItem.Index, White
               SetLIForeColor lvwRoqRol, lvwItem.Index, Black '21Nov08 TH Added
               'SetLIBackColor lvwItem, 13, vbRed
            End If
            UpdateRoqAndRolArray CLng(intloop), lvwRoqRol.ListItems(intloop).ListSubItems.Item(13).Text
            'MsgBox lvwRoqRol.ListItems(intloop).ListSubItems.Item(13).Text 'Add, strKey & ":C" & CStr(Col), strValue
         End If
      End If
   Next
End Sub

Private Sub lvwRoqRol_KeyPress(KeyAscii As Integer)
If KeyAscii = 13 Then
   lvwRoqRol_DblClick
End If
End Sub

Private Sub lvwRoqRol_KeyUp(KeyCode As Integer, Shift As Integer)
'21Nov08 TH added F4 to ROQROL screen (F0038966)

Select Case KeyCode
   Case KEY_F4
      Select Case Shift
          Case 0  'Ordinary
              ODrugInfo$ = Me.lvwRoqRol.SelectedItem.ListSubItems(3).Text
              If Trim$(ODrugInfo$) <> "" Then
                 DisplayDrugEnquiry ODrugInfo$, SiteNumber  ' Removed using DrugInfo.frm as now displayed via ICW desktop F0033906
                 '     k.escd = False 'TH 23Feb05 Added
                 '     Load DrugInfo
                 '     If Not k.escd Then DrugInfo.Show 1
                 '     Unload DrugInfo
              Else
                  popmessagecr "Sorry", "Cannot display item information for a label."
              End If
          Case SHIFT_MASK
               
          Case CTRL_MASK
          Case ALT_MASK
      End Select
   End Select
End Sub

Private Sub mnuHelp_Click(Index As Integer)
'16Jan07 PJC Created (RR enh)

''   Select Case Index
''      Case 0: Help 0                       '&Contents    F1
''      Case 1: HelpSearch                   '&Search for Help on...
''      Case 2: HelpGet HELP_HELPONHELP, 0   '&How to use Help
''      Case 3                               'separator
''      Case 4: ShowAboutBox Me, "ASCribe"   'About
''   End Select
   Select Case Index
      Case 0: SendKeys "{F1}"  'Help 0
      Case 1: HelpSearch Me.Hwnd
      Case 2: HelpGet Me.Hwnd, HELP_HELPONHELP, 0
      Case 4: ShowAboutBox "Stock Control"
   End Select

End Sub

Private Sub mnuRoqAndRol_Click(Index As Integer)
'16Jan07 PJC Created (RR enh)
Dim blnIncludeNonUpdates As Integer

Dim strAns As String

   setinput 0, k
   k.escd = False
   SetPicFooter (1 + Index)
   
   EnableControls False ' 23Apr10 XN F0058248 Added progress bar to Roq and Rol form

   Select Case Index
      Case 0, 1, 2, 3
         blnIncludeNonUpdates = IncludeNonUpdatesInRoqAndRolOutput((Index = 1))
         If Not k.escd Then
            Select Case Index
               Case 0    'Print
                  PrintRoqAndRol True, False, mintLinesPerPage, blnIncludeNonUpdates, progressBar   ' 23Apr10 XN F0058248 Added progress bar to Roq and Rol form

               Case 1    'Export
                  ExportRoqAndRol Me, blnIncludeNonUpdates
         
               Case 2, 3   'Print and Update , or update
               
                  strAns = "N"
                  askwin "?EMIS Health", "Are you sure you want to update Annual use, Re-order level and Re-order quantity values?", strAns, k
                  If Not k.escd And strAns = "Y" Then
                     PrintRoqAndRol (Index = 2), True, mintLinesPerPage, blnIncludeNonUpdates, progressBar  ' 23Apr10 XN F0058248 Added progress bar to Roq and Rol form
                     Me.Hide
                  End If
            End Select
         End If
      Case 5   'Exit
         Me.Hide
   End Select
   SetPicFooter 0

   EnableControls True  ' 23Apr10 XN F0058248 Added progress bar to Roq and Rol form
End Sub

Private Sub mnuRoqAndRolOptions_Click(Index As Integer)
'16Jan07 PJC Created (RR enh)

Dim strLinesPerPage  As String

   Select Case Index
      Case 0
         setinput 0, k
         k.min = 1
         k.Max = 3
         k.nums = True
         strLinesPerPage = Format$(mintLinesPerPage)
         'inputwin "Authorise Order", "Enter special instructions for supplier", strLinesPerPage, k
         inputwin "Reorder calculations", "Enter number of lines per page", strLinesPerPage, k
         
         If Not k.escd And Val(strLinesPerPage) > 0 Then
            mintLinesPerPage = Val(strLinesPerPage)
            WritePrivateIniFile "RoqAndRol", "LinesPerPage", strLinesPerPage, dispdata$ & "\Winord.INI", 0
         End If
   End Select
   
End Sub

Private Sub SetPicFooter(intmode As Integer)
'16Jan07 PJC Created (RR enh)

   picFooter.Cls
   Select Case intmode
      Case 1  'Printing
         picFooter.Print " Printing Roq and Rol Report..."
      Case 2  'Exporting
         picFooter.Print " Exporting Roq and Rol data..."
      Case 3  'Printing & Updating
         picFooter.Print " Printing and Updating Roq and Rol data..."
      Case 4  'Updating
         picFooter.Print " Updating Roq and Rol data..."
      Case Else 'Display totals and info
         picFooter.Print " " & Format$(NumberOfRoqAndRolLines()) & " products listed."
         picFooter.Print " Double Click or press Return to change the Update status of a product."
   End Select
   picFooter.Refresh
End Sub

''Private Sub TblDisplay_DblClick()
'16Jan07 PJC Created (RR enh)

''Dim strValue As String
''
''   strValue = RoqAndRolUpdateValue(Val(TblDisplay.RowIndex))
''   TblDisplay_Update Val(TblDisplay.RowIndex), 14, strValue


''End Sub
''
''Private Sub TblDisplay_Fetch(Row As Long, Col As Integer, Value As String)
'16Jan07 PJC Created (RR enh)
   
''   TblRoqRolDisplayFetch Row, Col, Value

''End Sub
''
''Private Sub TblDisplay_FetchAttributes(status As Integer, Split As Integer, Row As Long, Col As Integer, FgColor As Long, BgColor As Long, FontStyle As Integer)
'16Jan07 PJC Created (RR enh)

''Dim strValue As String
''
''   strValue = TblDisplay.ColumnText(14)
''
''   If strValue = "N" Then
''         BgColor = mlngBackColour
''         FgColor = mlngForeColour
''      End If

''End Sub
''
''Private Sub TblDisplay_KeyDown(KeyCode As Integer, Shift As Integer)
'16Jan07 PJC Created (RR enh)

''   If KeyCode = 13 Then KeyCode = 0
   
''End Sub
''
''Private Sub TblDisplay_KeyPress(Keyascii As Integer)
'16Jan07 PJC Created (RR enh)

''   Select Case Keyascii
''      Case 13
''         TblDisplay_DblClick
''         Keyascii = 0
''      End Select

''End Sub
''
''Private Sub TblDisplay_KeyUp(KeyCode As Integer, Shift As Integer)
'16Jan07 PJC Created (RR enh)


''   Select Case KeyCode
''      'Case 33 'pg up
''      '   KeyCode = 0
''      'Case 34 'pg dwn
''      '   KeyCode = 0
''
''      Case 35 'end
''         KeyCode = 0
''         Select Case Shift
''            Case 0: TblDisplay.RowIndex = TblDisplay.Rows  'no shift
''            End Select
''      Case 36 'home
''         KeyCode = 0
''         Select Case Shift
''            Case 0: TblDisplay.RowIndex = 1                'no shift
''            End Select
''      End Select

''End Sub
''
''Private Sub TblDisplay_Update(Row As Long, Col As Integer, Value As String)
'16Jan07 PJC Created (RR enh)

''   UpdateRoqAndRolArray Row&, Value
''   TblDisplay.RefreshRow = Row&

''End Sub

''Private Sub TblDisplay_Validate(Row As Long, Col As Integer, Value As String, Cancel As Integer)
'''16Jan07 PJC Created (RR enh)

''   If Col = 13 Then
''         Value = UCase$(Value)
''         If Value <> "Y" And Value <> "N" Then
''               popmessagecr "#", "Y or N values only"
''               Cancel = True
''            End If
''      End If

''End Sub

' Enables\disables all the controls in the form including the menu
' 23Apr10 XN F0058248 Added progress bar to Roq and Rol form
Private Sub EnableControls(ByVal Enabled As Boolean)
    MnuFileTop.Enabled = Enabled
    mnuOptionsTop.Enabled = Enabled
    mnuHelphdg.Enabled = Enabled
    lvwRoqRol.Enabled = Enabled
End Sub
