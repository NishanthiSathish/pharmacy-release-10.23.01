VERSION 5.00
Object = "{0CA5A680-1874-11D0-99B4-00550076453D}#1.0#0"; "h5ocx32.ocx"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form HighEdit 
   Appearance      =   0  'Flat
   BackColor       =   &H80000005&
   Caption         =   "Edit "
   ClientHeight    =   6495
   ClientLeft      =   60
   ClientTop       =   630
   ClientWidth     =   9480
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
   Icon            =   "HIGHEDIT.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6495
   ScaleWidth      =   9480
   WindowState     =   2  'Maximized
   Begin VB.PictureBox picBlank 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   330
      Index           =   1
      Left            =   5295
      ScaleHeight     =   330
      ScaleWidth      =   345
      TabIndex        =   3
      TabStop         =   0   'False
      Top             =   75
      Width           =   345
   End
   Begin VB.PictureBox picBlank 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   330
      Index           =   0
      Left            =   435
      ScaleHeight     =   330
      ScaleWidth      =   705
      TabIndex        =   2
      TabStop         =   0   'False
      Top             =   75
      Width           =   705
   End
   Begin H5ocxLibCtl.HighEditPro HE 
      Height          =   5295
      Left            =   0
      OleObjectBlob   =   "HIGHEDIT.frx":030A
      TabIndex        =   1
      Top             =   0
      Width           =   9495
   End
   Begin MSComDlg.CommonDialog CMDialog1 
      Left            =   300
      Top             =   5280
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
      FontSize        =   0
      MaxFileSize     =   256
   End
   Begin VB.CommandButton CmdEscape 
      Appearance      =   0  'Flat
      Cancel          =   -1  'True
      Caption         =   "Esc"
      Height          =   285
      Left            =   6030
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   5340
      Width           =   1140
   End
   Begin VB.Menu MnuFile 
      Caption         =   "&File"
      Begin VB.Menu mnuPrintSetup 
         Caption         =   "P&rint Setup ..."
      End
      Begin VB.Menu mnuPreview 
         Caption         =   "Print Pre&view"
      End
      Begin VB.Menu mnuPrint 
         Caption         =   "&Print ..."
      End
      Begin VB.Menu mnuSep1 
         Caption         =   "-"
      End
      Begin VB.Menu MnuSave 
         Caption         =   "&Save and Exit"
      End
      Begin VB.Menu MnuExit 
         Caption         =   "E&xit without saving"
      End
   End
   Begin VB.Menu mnuEdit 
      Caption         =   "&Edit"
      Begin VB.Menu mnuUndo 
         Caption         =   "&Undo"
         Shortcut        =   ^Z
      End
      Begin VB.Menu mnuSep2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuCut 
         Caption         =   "Cu&t"
         Shortcut        =   ^X
      End
      Begin VB.Menu mnuCopy 
         Caption         =   "&Copy"
         Shortcut        =   ^C
      End
      Begin VB.Menu mnuPaste 
         Caption         =   "&Paste"
         Shortcut        =   ^V
      End
      Begin VB.Menu mnuDel 
         Caption         =   "&Delete"
      End
      Begin VB.Menu mnuSelectAll 
         Caption         =   "Select &All"
         Shortcut        =   ^A
      End
      Begin VB.Menu mnuPopup 
         Caption         =   "-"
         Index           =   0
         Visible         =   0   'False
      End
   End
   Begin VB.Menu mnuInsertHdg 
      Caption         =   "&Insert"
      Enabled         =   0   'False
      Visible         =   0   'False
      Begin VB.Menu mnuInsert 
         Caption         =   "Dummy Item"
         Index           =   0
      End
   End
   Begin VB.Menu mnuSearch 
      Caption         =   "&Search"
      Begin VB.Menu mnuFind 
         Caption         =   "&Find ..."
         Shortcut        =   ^F
      End
      Begin VB.Menu mnuFindNext 
         Caption         =   "Find &Next"
         Shortcut        =   {F3}
      End
      Begin VB.Menu mnuReplace 
         Caption         =   "&Replace ..."
         Shortcut        =   ^R
      End
   End
   Begin VB.Menu mnuFormat 
      Caption         =   "F&ormat"
      Begin VB.Menu MnuFonts 
         Caption         =   "&Font ..."
      End
      Begin VB.Menu mnuParagraph 
         Caption         =   "&Paragraph ..."
      End
      Begin VB.Menu mnuInsFF 
         Caption         =   "Insert Page &Break"
      End
      Begin VB.Menu mnuDelFF 
         Caption         =   "Remove Page Break"
      End
      Begin VB.Menu mnuSep3 
         Caption         =   "-"
      End
      Begin VB.Menu mnuHead 
         Caption         =   "&Header && Footer"
      End
      Begin VB.Menu mnuPage 
         Caption         =   "Page &Layout ..."
      End
      Begin VB.Menu mnuRePage 
         Caption         =   "Repa&ginate"
      End
      Begin VB.Menu mnuDocInfo 
         Caption         =   "Document &Info ..."
      End
      Begin VB.Menu mnuSep4 
         Caption         =   "-"
      End
      Begin VB.Menu mnuPicture 
         Caption         =   "Insert Pi&cture ..."
      End
      Begin VB.Menu mnuFrame 
         Caption         =   "Show as Frame"
      End
   End
   Begin VB.Menu mnuTableHdg 
      Caption         =   "&Table"
      Begin VB.Menu mnuTableSelect 
         Caption         =   "&Select Table"
      End
      Begin VB.Menu mnuTable 
         Caption         =   "Insert &Table ..."
      End
      Begin VB.Menu mnuSep5 
         Caption         =   "-"
      End
      Begin VB.Menu mnuInsRow 
         Caption         =   "Insert Row"
      End
      Begin VB.Menu mnuDelRow 
         Caption         =   "Delete Row"
      End
      Begin VB.Menu mnuTableColumnInsert 
         Caption         =   "Insert Column"
      End
      Begin VB.Menu mnuTableColumnAppend 
         Caption         =   "Add Column"
      End
      Begin VB.Menu mnuTableColumnDelete 
         Caption         =   "Delete Column"
      End
      Begin VB.Menu mnuSep6 
         Caption         =   "-"
      End
      Begin VB.Menu mnuTableCellMerge 
         Caption         =   "Merge Cells"
      End
      Begin VB.Menu mnuTableCellSplit 
         Caption         =   "Split Cells"
      End
      Begin VB.Menu mnuColWidth 
         Caption         =   "Set Column &Width ..."
      End
      Begin VB.Menu mnuCellHeightWidth 
         Caption         =   "Cell &Height && Width ..."
      End
      Begin VB.Menu mnuSep8 
         Caption         =   "-"
      End
      Begin VB.Menu mnuTableBordersShading 
         Caption         =   "Borders && Shading ..."
      End
      Begin VB.Menu mnuTableBordersNarrow 
         Caption         =   "Set Table &Borders"
      End
      Begin VB.Menu mnuTableBordersNarrowAll 
         Caption         =   "Set &All Table Borders"
      End
   End
   Begin VB.Menu mnuOptions 
      Caption         =   "O&ptions"
      Begin VB.Menu mnuCtrlChars 
         Caption         =   "Show &Tabs"
         Index           =   0
      End
      Begin VB.Menu mnuCtrlChars 
         Caption         =   "Show &Spaces"
         Index           =   1
      End
      Begin VB.Menu mnuCtrlChars 
         Caption         =   "Show &Returns"
         Index           =   2
      End
      Begin VB.Menu mnuSep7 
         Caption         =   "-"
      End
      Begin VB.Menu mnuInch 
         Caption         =   "Inches"
      End
      Begin VB.Menu mnuMetric 
         Caption         =   "Centimetres"
      End
   End
   Begin VB.Menu MnuHelp 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelpContents 
         Caption         =   "&Help"
      End
   End
End
Attribute VB_Name = "HighEdit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------------------------------------------------
'        HighEdit.frm
'??Jul96 ASC Written
'26Sep96 CKJ Corrected QueryUnload
'23Oct96 CKJ Added Common Dialog for Print Setup
' 2Nov96 CKJ Help link added
' 6Nov96 CKJ Merged ASC's changes. NB uses TABLE.frm
' 6Nov96 CKJ Another correction to exiting
' 9Nov96 CKJ Many changes & new features. See HighEdit.bas for info
'            Removed Table.frm, now uses a dialog instead
' 5Aug97 CKJ Added Print dialog, Select All, Show Tabs/Spaces/Returns
'28Oct97 CKJ Added Lookup options, HEdit_Callback, right click menu
'19Nov08 CKJ mnuPrintSetup_Click: Noted that the common dialog is not used. In V8 this ensured
'            that the changes were done correctly to the default printer. Added debug option.   (F0039104)
'17Jan10 CKJ Changed HighEdit. to Me. and set defbool
'            Added Table options with borders, shading, merge, split
'            Made exit more Windows standard, with Alt-F4 & [x] asking if changes should be saved
'            Covered up the file open and fields buttons (except in view-only mode)
'            Save button is shown when there is at least one change to save, action is same as save & exit
'              (File operations are under program control, fields not used)
'            Made date button return '17-Mar-2010 ' instead of '17.03.110'
'            Removed fraOverlaySave_DragDrop as no such control exists
'            HE.keydown & MouseDown are not named like this in 32 bit se were not invoked
'              cut/copy/paste work anyway, and popup menu steals focus, so both removed
'            HE.lowresources not supported - removed
'            added errorstart, errorfont, etc for all error... routines
'            Toggle preview from button now sets menus correctly
'            View-only now disables button bar & style bar
'            mnuColWidth: Prevented column width of -0.001

'Mods needed
'-----------
' Does not 'feel' right - escape assumes you're saving
' Save & Exit feels like escape should
'/Repagination will be neeeded
' tables in head/foot are not recognised
' may be able to imrove printer attributes & margin handling
'-----------------------------------------------------------------

Option Explicit
DefBool A-Z

Const BORDER_POS_ALL = &HFFFF
Const BORDER_STYLE_HAIR = 1

Const MT_ABSOLUTE = &H0
Const MT_RELATIVE = &H100

Const MT_CHAROFFSET = &H3
Const MT_TABLE = &H5

' Event_MenuBarCommand - lCommandID
Const STYLEBAR_HIGHEST_NOTIFYCODE = 9

Const IBN_NEW = (STYLEBAR_HIGHEST_NOTIFYCODE + 10)
Const IBN_OPEN = (STYLEBAR_HIGHEST_NOTIFYCODE + 11)
Const IBN_SAVE = (STYLEBAR_HIGHEST_NOTIFYCODE + 12)

Const IBN_PRINT = (STYLEBAR_HIGHEST_NOTIFYCODE + 15)
Const IBN_PREVIEW = (STYLEBAR_HIGHEST_NOTIFYCODE + 16)
Const IBN_SPELL = (STYLEBAR_HIGHEST_NOTIFYCODE + 17)

Const IBN_CUT = (STYLEBAR_HIGHEST_NOTIFYCODE + 20)
Const IBN_COPY = (STYLEBAR_HIGHEST_NOTIFYCODE + 21)
Const IBN_PASTE = (STYLEBAR_HIGHEST_NOTIFYCODE + 22)

Const IBN_UNDO = (STYLEBAR_HIGHEST_NOTIFYCODE + 25)
Const IBN_SEARCH = (STYLEBAR_HIGHEST_NOTIFYCODE + 30)

Const IBN_TABLE = (STYLEBAR_HIGHEST_NOTIFYCODE + 35)
Const IBN_PICTURE = (STYLEBAR_HIGHEST_NOTIFYCODE + 36)

Const IBN_FIELD = (STYLEBAR_HIGHEST_NOTIFYCODE + 37)
Const IBN_DATE = (STYLEBAR_HIGHEST_NOTIFYCODE + 38)
Const IBN_TIME = (STYLEBAR_HIGHEST_NOTIFYCODE + 39)

Const IBN_HEADFOOT = (STYLEBAR_HIGHEST_NOTIFYCODE + 45)
Const IBN_DISPLAY = (STYLEBAR_HIGHEST_NOTIFYCODE + 46)

Dim success As Boolean

Private Sub cmdEscape_Click()
'NB This is the save & exit option, triggered by the [Esc] key

   QuerySaveAndExit

End Sub

Private Sub Form_Activate()
Dim viewonly%, preview%

   viewonly = HE.ReadOnly()
   preview = HE.IsPreview()
   
   mnuPreview.Checked = preview
   
   If preview Or viewonly Then
      mnuEdit.Enabled = False
      mnuSearch.Enabled = False
      mnuFormat.Enabled = False
      mnuTableHdg.Enabled = False
   End If

   If viewonly Then
      mnuEdit.Visible = False
      mnuSearch.Visible = False
      mnuFormat.Visible = False
      mnuTableHdg.Visible = False
      MnuSave.Enabled = False
      MnuSave.Visible = False
      MnuExit.Caption = "E&xit"
      HE.MenuBar = False
      HE.StyleBar = False
      picBlank(0).Visible = False
      picBlank(1).Visible = False
   End If

End Sub

Private Sub Form_Load()
   setHETag "" '22Oct09 TH Added
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
   
   If UnloadMode <> 1 Then      'not unloaded from code
      Cancel = True
         
'      Me.Tag = "exit"  ' 6Nov96 CKJ added
'      HE.SetModified False     'clear the edited flag
'      Hide
   
      'Ask before quitting when user uses Alt-F4 or [x] if changes have been made
      QuerySaveAndExit
   End If

End Sub

Private Sub Form_Resize()

   HE.Move 0, 0, Me.ScaleWidth, Me.ScaleHeight

End Sub

Private Sub Form_Unload(Cancel As Integer)
   setHETag Me.Tag '22Oct09 TH Added
End Sub

Private Sub HE_ErrorBlockMark(pnShowBox As Integer)

   pnShowBox = True
   
End Sub

Private Sub HE_ErrorFont(pnShowBox As Integer)

   pnShowBox = True
   
End Sub

Private Sub HE_ErrorHEFile(pnShowBox As Integer)
   
   pnShowBox = True

End Sub

Private Sub HE_ErrorLoad(pnShowBox As Integer)

   pnShowBox = True
   
End Sub

Private Sub HE_ErrorMemory(ShowBox As Integer)

   ShowBox = True

End Sub

Private Sub HE_ErrorNotFound(pnShowBox As Integer)
   
   pnShowBox = True

End Sub

Private Sub HE_ErrorPrinter(ShowBox As Integer)
'No windows default printer has been set up - this is needed for HighEdit

   ShowBox = False
   popmessagecr "!Edit Workspace", "Until a default printer has been configured this module cannot run"
   SendKeys "%{F4}"  'Send Alt-F4

End Sub

Private Sub HE_ErrorRTFFile(pnShowBox As Integer)
   
   pnShowBox = True

End Sub

Private Sub HE_ErrorSave(pnShowBox As Integer)
   
   pnShowBox = True

End Sub

Private Sub HE_ErrorSearch(pnShowBox As Integer)
   
   pnShowBox = True

End Sub

Private Sub HE_ErrorStart(ShowBox As Integer)

   ShowBox = True

End Sub

Private Sub HE_ErrorTmpClose(ShowBox As Integer)

   ShowBox = True

End Sub

Private Sub HE_ErrorTmpOpen(ShowBox As Integer)

   ShowBox = True

End Sub

Private Sub HE_ErrorTmpSpace(ShowBox As Integer)

   ShowBox = True

End Sub

Private Sub HE_ErrorWriteAccess(ShowBox As Integer)
'!!** More Needed

   ShowBox = True

End Sub

Private Sub HE_LowMemory(ShowBox As Integer)

   ShowBox = True

End Sub

''Private Sub HE_MouseDown(button As Integer, Shift As Integer, x As Single, Y As Single)
'''28Oct97 CKJ Written
''
''   If button = RIGHT_BUTTON Then
''         'mnuPopup(0).Visible = True     'for testing only
''         'Load mnuPopup(1)
''         'mnuPopup(1).Visible = True
''         'mnuPopup(1).Caption = "Insert " & mnuInsert(1).Caption
''         'Load mnuPopup(2)
''         'mnuPopup(2).Visible = True
''         'mnuPopup(2).Caption = "Insert " & mnuInsert(2).Caption
''
''         PopupMenu Me.mnuEdit
''
''         'mnuPopup(0).Visible = False
''         'Unload mnuPopup(1)
''         'Unload mnuPopup(2)
''
''         button = 0
''      End If
''
''End Sub

Private Sub HE_MenuBarCommand(ByVal lCommandID As Long, pnDefault As Integer)

Dim sText As String
Dim ans As String

   Select Case lCommandID
      Case IBN_NEW            'allow new after confirmation
         pnDefault = False
         If Not HE.IsPreview Then
            ans$ = "N"
            askwin ".CAUTION", crlf & "This action will wipe everything and replace it a blank page" & crlf & crlf & "Are you sure you want to erase the whole document?" & crlf, ans$, k
            If Not k.escd And ans$ = "Y" Then
               HE.InitNewDoc
               HE.SetModified False          'mark as NOT modified, preventing overwriting with a totally blank document (unless user types & then explicitly erases)
             End If
          End If
          
      Case IBN_DATE           'insert date in format dd-Mmm-ccyy
         pnDefault = False
         sText = Format$(Now(), "dd-Mmm-yyyy ")
         Clipboard.SetText sText, ClipBoardConstants.vbCFText
         HE.Paste
         
      Case IBN_PREVIEW        'disable menus as well, disallow if started in preview only mode
         pnDefault = False
         If mnuPreview.Enabled Then
            TogglePreview
         End If
         
      Case IBN_SAVE
         pnDefault = False
         If Not HE.IsPreview Then
            QuerySaveAndExit
         End If
         
      Case IBN_OPEN, IBN_FIELD, IBN_SPELL    'suppress completely
         pnDefault = False
      End Select
      
End Sub

Private Sub HE_Modify()
'fires when the IsModified property changes

   picBlank(0).Width = Iff(HE.IsModified, 350, 705)      'show/hide the save button
      
End Sub

Private Sub mnuCellHeightWidth_Click()

   If HE.IsCellActive() Or HE.IsTableSelected() Then
      success = HE.CellDimDlg()
   End If

End Sub

Private Sub mnuColWidth_Click()
' 9Nov96 CKJ Added, but can't get the HEGetColumnWidth to work
'10Nov96 CKJ Added inches

Dim colwidth%, ans$, txt$

  success = HE.GetColumnWidth(colwidth)
  If success Then
      ans$ = ""
      If colwidth > 0 Then
         ans$ = Format$(colwidth / 1000!)
      End If
      k.nums = True
      k.decimals = True
      k.Max = 4
      If HE.Unit = UNIT_CM Then txt$ = "centimetres" Else txt$ = "inches"
      inputwin "Edit Table", "Set column width in " & txt$, ans$, k
      If Not k.escd Then
         If Val(ans$) < 0 Or Len(ans$) = 0 Then k.escd = True
         If Val(ans$) > 32.767 And HE.Unit = UNIT_CM Then
            popmessagecr "Incorrect Entry", "Column width must be in the range 0 to 32 cm"
            k.escd = True
         End If
         If Val(ans$) > 12.9 And HE.Unit = UNIT_IN Then
            popmessagecr "Incorrect Entry", "Column width must be in the range 0 to 12.9 inches"
            k.escd = True
         End If
         If Not k.escd Then
            colwidth = Val(ans$) * 1000
            success = HE.SetColumnWidth(colwidth)                 '(Me.HE.hWnd, 0, 3, 0, colwidth)
         End If
      End If
   End If
   k.escd = False

End Sub

Private Sub mnuCopy_Click()

   HE.copy

End Sub

Private Sub mnuCtrlChars_Click(Index As Integer)
'5Aug97 CKJ Added
   
   Select Case Index
      Case 0: HE.TabsVisible = Not HE.TabsVisible
      Case 1: HE.SpacesVisible = Not HE.SpacesVisible
      Case 2: HE.ReturnsVisible = Not HE.ReturnsVisible
      End Select

End Sub

Private Sub mnuCut_Click()

   HE.Cut

End Sub

Private Sub mnuDel_Click()
' 5Aug97 CKJ {Del} places text in clipboard - now deletes without copying

   'SendKeys "{Del}"
   HE.Clear

End Sub

Private Sub mnuDelFF_Click()

   success = HE.ToggleFormfeed()

End Sub

Private Sub mnuDelRow_Click()

   success = HE.DeleteTableRow()

End Sub

Private Sub mnuDocInfo_Click()

   success = HE.DocInfoDlg()

End Sub

Private Sub mnuEdit_Click()

   If HE.CanCopy() = True Then
         mnuCopy.Enabled = True
         mnuCut.Enabled = True
      Else
         mnuCopy.Enabled = False
         mnuCut.Enabled = False
      End If

   mnuPaste.Enabled = HE.CanPaste()
   mnuUndo.Enabled = HE.CanUndo()

End Sub

Private Sub QuerySaveAndExit()
'Save & Exit from menu, pressing Escape, Alt-F4 or [x]

Dim ans$, OK%, Cancel%

   OK = False
   Cancel = False

   If Me.Tag = "preview" Or HE.ReadOnly() Then  'exit immediately if started as view-only or preview mode
      OK = True
      Cancel = True
   Else                                         'normal edit mode (may be edited or not, in preview or not)
      If HE.IsPreview() Then
         TogglePreview                          'just leave preview and return to editing
      Else                                      'already in normal edit mode
         If Not HE.IsModified() Then
            OK = True
            Cancel = True
         Else                                   'ask if changes should be saved, Y/N/cancel
            ans$ = "Y"
            askwin "?Exit", crlf & "        OK to save changes?" & crlf, ans$, k
            If Not k.escd Then
               If ans$ = "N" Then Cancel = True
               OK = True
            End If
         End If
      End If
   End If

   If OK Then
      If Cancel Then
         Me.Tag = "exit"
         HE.SetModified False         'clear the edited flag
      End If
      Hide
   End If

End Sub

Private Sub mnuExit_Click()
'menu Exit Without saving

Dim ans$, OK%

   OK = False
   If Me.Tag = "preview" Or HE.ReadOnly() Then           'started in view-only or preview mode - just exit
      OK = True
   ElseIf HE.IsPreview Then                              'started in edit, now in preview - quit preview
      TogglePreview
   ElseIf Not HE.IsModified() Then                       'started in edit but not changed - exit
      OK = True
   Else                                                  'modified so ask
      ans$ = "Y"
      askwin "!Exit", crlf & "      OK to exit without saving?" & crlf, ans$, k
      If ans$ = "Y" And Not k.escd Then OK = True
   End If

   If OK Then
      Me.Tag = "exit"
      HE.SetModified False       'clear the edited flag
      Hide
   End If

End Sub

Private Sub mnuFile_Click()

   mnuPreview.Checked = HE.IsPreview()
      
   If mnuPreview.Checked And Me.Tag <> "Preview" Then       'in preview but got here from editing
      MnuSave.Enabled = False
      MnuExit.Caption = "E&xit preview"
   Else
      If HE.IsModified() Then
            MnuSave.Enabled = True
            MnuExit.Caption = "E&xit without saving"
         Else
            MnuSave.Enabled = False
            MnuExit.Caption = "E&xit"
         End If
   End If
   
End Sub

Private Sub mnuFind_Click()

   success = HE.SearchDlg()

End Sub

Private Sub mnuFindNext_Click()
   
   success = HE.SearchContinue(True)

End Sub

Private Sub MnuFonts_Click()

   success = HE.FontDlg()
            
End Sub

Private Sub mnuFormat_Click()

   mnuHead.Enabled = HE.HeadFoot
   mnuHead.Checked = HE.IsHeadFootVisible()
   
   mnuPicture.Enabled = True                           'HE.IsTableActive()
   
   mnuDelFF.Enabled = HE.IsFormfeed()
   mnuInsFF.Enabled = Not mnuDelFF.Enabled
   
   mnuFrame.Checked = HE.PictureAsFrame

   'MenuOptGrayBk.Checked = Me.GrayBk             other things to add later
   'MenuOptLineGhost.Checked = Me.GhostLines
   'MenuOptLineBreak.Checked = Me.LineBreak

End Sub

Private Sub mnuFrame_Click()

   HE.PictureAsFrame = Not HE.PictureAsFrame

End Sub

Private Sub mnuHead_Click()

   success = HE.ShowHeadFoot(Not HE.IsHeadFootVisible())

End Sub

Private Sub mnuHelpContents_Click()

   SendKeys "{F1}"

End Sub

Private Sub mnuInch_Click()

   HE.Unit = UNIT_IN

End Sub

Private Sub mnuInsert_Click(Index As Integer)
'28Oct97 CKJ Added

   HEdit_Callback Index

End Sub

Private Sub mnuInsFF_Click()
   
   success = HE.ToggleFormfeed()

End Sub

Private Sub mnuInsRow_Click()

   success = HE.InsertTableRow()

End Sub

Private Sub mnuMetric_Click()

   HE.Unit = UNIT_CM

End Sub

Private Sub mnuOptions_Click()
'5Aug97 CKJ Added
   
   mnuMetric.Checked = (HE.Unit = UNIT_CM)
   mnuInch.Checked = Not mnuMetric.Checked
   
   mnuCtrlChars(0).Checked = HE.TabsVisible
   mnuCtrlChars(1).Checked = HE.SpacesVisible
   mnuCtrlChars(2).Checked = HE.ReturnsVisible

End Sub

Private Sub mnuPage_Click()

   success = HE.FormatDocDlg()

End Sub

Private Sub mnuParagraph_Click()

   success = HE.ParagraphDlg()

End Sub

Private Sub mnuPaste_Click()

   HE.Paste

End Sub

Private Sub mnuPicture_Click()

   success = HE.PictureDlg()
   If Not success Then popmessagecr "!", "Could not insert image" & crlf & "Check that file is of type '.bmp'"

End Sub

Private Sub mnuPopup_Click(Index As Integer)
'28Oct97 CKJ Added

   HEdit_Callback Index

End Sub

Private Sub mnuPreview_Click()

   TogglePreview
   
End Sub

Private Sub TogglePreview()

   HE.preview
   
   mnuEdit.Enabled = Not HE.IsPreview()
   mnuSearch.Enabled = Not HE.IsPreview()
   mnuFormat.Enabled = Not HE.IsPreview()
   mnuTableHdg.Enabled = Not HE.IsPreview()

   mnuPreview.Checked = HE.IsPreview()
   
End Sub

Private Sub mnuPrint_Click()
' 5Aug97 CKJ Added

   success = HE.PrintDlg()

End Sub

Private Sub mnuPrintSetup_Click()
'Call the printer setup routine in the cmdialog control
'19Nov08 CKJ Noted that the common dialog is not used, yet in V8 this ensured that the changes
'            were done correctly to the default printer, persisting after the HE window closed.
'            For V10 RCNP0008, added a debug option to allow this to be reviewed, with a view to
'            raising an RFC if this proves to be the preferable option. The default behaviour
'            is completely unchanged from V9, to the extent that the code has been duplicated
'            somewhat pedantically below.
'            To turn on the debug option, set wConfiguration ascribe [] HEPrintSetupDebug="Y"
'            default is "N"
   
'   On Error Resume Next
'   'CMDialog1.Flags = &H40  'Printer Setup dialog only
'   'CMDialog1.Action = 5
'   On Error GoTo 0
'
'   'success = HEPrintSetupDlg(Me.HE.hWnd)  does not set printer as default
'
'  '' HE.WinIniChange "Windows"
'   HE.PrintSetupDlg '15Dec05 TH Sadly WininiChange seemingly not supported in new ocx for VB
'   HE.Redraw True

   If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "HEPrintSetupDebug", 0)) Then
      On Error Resume Next
      CMDialog1.Flags = &H40  'Printer Setup dialog only
      CMDialog1.Action = 5
      On Error GoTo 0
   Else
      On Error Resume Next
      On Error GoTo 0
      HE.PrintSetupDlg
   End If
   HE.Redraw True

End Sub

Private Sub mnuRePage_Click()

   HE.Paginate
   HE.Redraw True

End Sub

Private Sub mnuReplace_Click()

   success = HE.ReplaceDlg()

End Sub

Private Sub MnuSave_Click()

   QuerySaveAndExit

End Sub

Private Sub mnuSelectAll_Click()
    
   success = HE.SelectAll(False)        'set TRUE to select just the table cell

End Sub

Private Sub mnuTableBordersShading_Click()

   success = HE.BorderDlg()

End Sub

Private Sub mnuTableBordersNarrow_Click()

   If HE.IsTableActive Then
      If HE.SelectTable() Then
         success = HE.SetBorder(BORDER_POS_ALL, BORDER_STYLE_HAIR, 15, 0)
      End If
   End If

End Sub

Private Sub mnuTableBordersNarrowAll_Click()

Dim iTable As Integer
Dim CurPos As Long

   'Save the cursor position
   CurPos = HE.GetCharOffset

   For iTable = 0 To HE.GetTableCount() - 1
      success = HE.MoveTo(MT_TABLE Or MT_ABSOLUTE, iTable)
      
      If HE.IsTableActive() Then                               'highlight table if available
         If HE.SelectTable() Then
            success = HE.SetBorder(BORDER_POS_ALL, BORDER_STYLE_HAIR, 15, 0)
         End If
      End If
   Next

   'Restore the cursor position
   HE.MoveTo MT_CHAROFFSET, CurPos

End Sub

Private Sub mnuTableCellMerge_Click()

   If HE.IsTableSelected() Then
      success = HE.LinkCells()
   End If
   
End Sub

Private Sub mnuTableCellSplit_Click()

   If HE.IsCellActive() Or HE.IsTableSelected() Then
      success = HE.SplitCellsDlg()
   End If

End Sub

Private Sub mnuTableHdg_Click()

Dim TableActive As Boolean

   TableActive = HE.IsTableActive()
   
   mnuTableSelect.Enabled = (HE.GetTableCount() > 0)
   mnuTable.Enabled = Not TableActive
   mnuInsRow.Enabled = TableActive
   mnuDelRow.Enabled = TableActive
   mnuTableColumnInsert.Enabled = TableActive
   mnuTableColumnAppend.Enabled = TableActive
   mnuTableColumnDelete.Enabled = TableActive
   mnuTableCellMerge.Enabled = HE.IsTableSelected()
   mnuTableCellSplit.Enabled = HE.IsCellActive() Or HE.IsTableSelected()
   mnuColWidth.Enabled = HE.IsCellActive() Or HE.IsTableSelected()  'was TableActive
   mnuCellHeightWidth = HE.IsCellActive() Or HE.IsTableSelected()
   mnuTableBordersShading = TableActive
   mnuTableBordersNarrow = TableActive
   mnuTableBordersNarrowAll = (HE.GetTableCount() > 0)

End Sub

Private Sub mnuTable_Click()

   HE.TableInsertDlg
     
End Sub

Private Sub mnuTableColumnAppend_Click()

   success = HE.AppendTableColumn()
   
End Sub

Private Sub mnuTableColumnDelete_Click()

   success = HE.DeleteTableColumn()

End Sub

Private Sub mnuTableColumnInsert_Click()

   success = HE.InsertTableColumn()
   
End Sub

Private Sub mnuTableSelect_Click()

   If Not HE.IsTableActive() Then                           'not currently in a table, so find next
      success = HE.MoveTo(MT_TABLE Or MT_RELATIVE, 1)
   End If
   
   If Not HE.IsTableActive() Then                           'no table between cursor & end of document, so find first
      success = HE.MoveTo(MT_TABLE Or MT_ABSOLUTE, 0)
   End If
   
   If HE.IsTableActive() Then                               'highlight table if available
      success = HE.SelectTable
   End If
   
End Sub

Private Sub mnuUndo_Click()

   success = HE.HEUndo(0)

End Sub

