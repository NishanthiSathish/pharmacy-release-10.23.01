VERSION 5.00
Object = "{0CA5A680-1874-11D0-99B4-00550076453D}#1.0#0"; "h5ocx32.ocx"
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
   Icon            =   "HighEditPrintJob.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6495
   ScaleWidth      =   9480
   WindowState     =   2  'Maximized
   Begin H5ocxLibCtl.HighEditPro HE 
      Height          =   5295
      Left            =   0
      OleObjectBlob   =   "HighEditPrintJob.frx":08CA
      TabIndex        =   1
      Top             =   0
      Width           =   9495
   End
   Begin VB.CommandButton CmdCancel 
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
      Begin VB.Menu mnuSep7 
         Caption         =   "-"
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
         Caption         =   "Remove Page &Break"
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
      Begin VB.Menu mnuTable 
         Caption         =   "Insert &Table ..."
      End
      Begin VB.Menu mnuInsRow 
         Caption         =   "Insert Table Row"
      End
      Begin VB.Menu mnuDelRow 
         Caption         =   "Delete Table Row"
      End
      Begin VB.Menu mnuColWidth 
         Caption         =   "Set Column &Width ..."
      End
      Begin VB.Menu mnuSep5 
         Caption         =   "-"
      End
      Begin VB.Menu mnuPicture 
         Caption         =   "Insert Pi&cture ..."
      End
      Begin VB.Menu mnuFrame 
         Caption         =   "Show as &Frame"
      End
   End
   Begin VB.Menu mnuOptions 
      Caption         =   "&Options"
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
      Begin VB.Menu mnuSep6 
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
'-----------------------------------------------------------------------------
'        HighEditPrintJob.frm
'       ----------------------
'
'17Sep10 CKJ written
'            Supports only the minimalist print job handler AscribePrintJob
'15Dec10 CKJ Added Ascribe icon to form
'            Removed Common Dialog            (RCN P0573 F0104170 10.5 branch)
'-----------------------------------------------------------------------------

Option Explicit
DefBool A-Z

Dim success As Boolean

Private Sub cmdCancel_Click()
'NB This is the save & exit option, not Cancel!!

'   MnuSave_Click

End Sub

Private Sub Form_Activate()
Dim viewonly%, preview%

   viewonly = HE.ReadOnly()
   preview = HE.IsPreview()
   
   If preview Or viewonly Then
         mnuEdit.Enabled = False
         mnuSearch.Enabled = False
         mnuFormat.Enabled = False
      End If

   If viewonly Then
         mnuEdit.Visible = False
         mnuSearch.Visible = False
         mnuFormat.Visible = False
         MnuSave.Enabled = False
         MnuSave.Visible = False
         MnuExit.Caption = "E&xit"
         'HE.IconBar = False            '09May05 not supported
      End If

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
   
   If UnloadMode <> 1 Then      'not unloaded from code
         Cancel = True
         Me.Tag = "exit"  ' 6Nov96 CKJ added   13Apr10 CKJ changed from HighEdit.Tag
         HE.SetModified False     'clear the edited flag
         Hide
      End If

End Sub

Private Sub Form_Resize()

   HE.Move 0, 0, Me.ScaleWidth, Me.ScaleHeight

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

   pnShowBox = False   '**
   
End Sub

Private Sub HE_ErrorMemory(ShowBox As Integer)

   ShowBox = True

End Sub

Private Sub HE_ErrorNotFound(pnShowBox As Integer)
   
   pnShowBox = True

End Sub

Private Sub HE_ErrorPrinter(ShowBox As Integer)
'No windows default printer has been set up - this is needed for HighEdit

   ShowBox = True
'   popmessagecr "!Edit Workspace", "Until a default printer has been configured this module cannot run"
'   SendKeys "%{F4}"  'Send Alt-F4

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

Private Sub HE_KeyDown(KeyCode As Integer, Shift As Integer)
' 5Aug97 CKJ Added to convert cut/copy/paste keystokes into HE commands

   Select Case Shift
      Case SHIFT_MASK
         Select Case KeyCode
            Case KEY_DELETE                  'Shift Del
               KeyCode = 0
               Shift = 0
               mnuCut_Click
            Case KEY_INSERT                  'Shift Ins
               KeyCode = 0
               Shift = 0
               mnuPaste_Click
            End Select

      Case CTRL_MASK
         If KeyCode = KEY_INSERT Then        'Ctrl Ins
               KeyCode = 0
               Shift = 0
               mnuCopy_Click
            End If
      End Select

End Sub

Private Sub HE_LowResources(ResourcePercent As Integer, ShowBox As Integer)

   ShowBox = True

End Sub

Private Sub HE_MouseDown(button As Integer, Shift As Integer, x As Single, Y As Single)
'28Oct97 CKJ Written

   If button = RIGHT_BUTTON Then
         'mnuPopup(0).Visible = True     'for testing only
         'Load mnuPopup(1)
         'mnuPopup(1).Visible = True
         'mnuPopup(1).Caption = "Insert " & mnuInsert(1).Caption
         'Load mnuPopup(2)
         'mnuPopup(2).Visible = True
         'mnuPopup(2).Caption = "Insert " & mnuInsert(2).Caption
         
         PopupMenu Me.mnuEdit           '13Apr10 CKJ changed from HighEdit.Tag

         'mnuPopup(0).Visible = False
         'Unload mnuPopup(1)
         'Unload mnuPopup(2)

         button = 0
      End If

End Sub

Private Sub mnuColWidth_Click()
' 9Nov96 CKJ Added, but can't get the HEGetColumnWidth to work
'10Nov96 CKJ Added inches
''
''Dim colwidth%, ans$, txt$
''
''  ' success = HEGetColumnWidth(HighEdit.HE.hWnd, 0, 3, 0, colwidth)
''  success = HE.GetColumnWidth(colwidth)
''  If success Then
''         ans$ = Format$(colwidth / 1000!)
''         'ans$ = "3"  '3cm OR 3" until HEGetColumnWidth can be made to work
''         k.nums = True
''         k.decimals = True
''         k.Max = 4
''         If HE.Unit = UNIT_CM Then txt$ = "centimetres" Else txt$ = "inches"
''         inputwin "Edit Table", "Set column width in " & txt$, ans$, k
''         If Not k.escd Then
''               If Val(ans$) < 0 Then k.escd = True
''               If Val(ans$) > 32.767 And HE.Unit = UNIT_CM Then
''                     popmessagecr "Incorrect Entry", "Column width must be in the range 0 to 32 cm"
''                     k.escd = True
''                  End If
''               If Val(ans$) > 12.9 And HE.Unit = UNIT_IN Then
''                     popmessagecr "Incorrect Entry", "Column width must be in the range 0 to 12.9 inches"
''                     k.escd = True
''                  End If
''               If Not k.escd Then
''                  colwidth = Val(ans$) * 1000
''                  success = HE.SetColumnWidth(colwidth)                 '(HighEdit.HE.hWnd, 0, 3, 0, colwidth)
''                  'success = HEAdjustTable(HighEdit.HE.hWnd, TABLE_ADJUSTCOLUMNS + TABLE_ADJUSTROWS + TABLE_ADJUSTREDRAW)     !!V93!! unsupported?
''               End If
''            End If
''      End If
''   k.escd = False

End Sub

Private Sub mnuCopy_Click()

   HE.Copy

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

Private Sub mnuExit_Click()
'menu Exit Without saving

Dim ans$, OK%

''   OK = False
''   If Me.Tag = "preview" Then           '13Apr10 CKJ changed from HighEdit.Tag
''         OK = True
''      ElseIf HE.ReadOnly() Then
''         OK = True
''      ElseIf Not HE.IsModified() Then
''         OK = True
''      Else
''         ans$ = "Y"
''         Confirm "Exit", "exit without saving", ans$, k
''         If ans$ = "Y" And Not k.escd Then OK = True
''      End If
''
''   If OK Then
      Me.Tag = "exit"
         HE.SetModified False       'clear the edited flag
         Hide
''      End If

End Sub

Private Sub mnuFile_Click()

   mnuPreview.Checked = HE.IsPreview()
   
   If HE.IsModified() Then
         MnuExit.Caption = "E&xit without saving"
         MnuSave.Enabled = True
         'mnuSave.Visible = True     not allowed to do this here
      Else
         MnuExit.Caption = "E&xit"
         MnuSave.Enabled = False
         'mnuSave.Visible = False    not allowed to do this here
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
   mnuInsRow.Enabled = HE.IsTableActive()
   mnuDelRow.Enabled = mnuInsRow.Enabled
   mnuColWidth.Enabled = mnuInsRow.Enabled
   mnuPicture.Enabled = Not mnuInsRow.Enabled
   
   mnuDelFF.Enabled = HE.IsFormfeed()
   mnuInsFF.Enabled = Not mnuDelFF.Enabled
   
   mnuFrame.Checked = HE.PictureAsFrame

   'MenuOptGrayBk.Checked = HighEdit.GrayBk             other things to add later
   'MenuOptLineGhost.Checked = HighEdit.GhostLines
   'MenuOptLineBreak.Checked = HighEdit.LineBreak

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

'   HEdit_Callback Index

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
''   If Not success Then popmessagecr "!", "Could not insert image"

End Sub

Private Sub mnuPopup_Click(Index As Integer)
'28Oct97 CKJ Added

'   HEdit_Callback Index

End Sub

Private Sub mnuPreview_Click()

   HE.preview
   
   mnuEdit.Enabled = Not HE.IsPreview()
   mnuSearch.Enabled = Not HE.IsPreview()
   mnuFormat.Enabled = Not HE.IsPreview()

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
'   'success = HEPrintSetupDlg(HighEdit.HE.hWnd)  does not set printer as default
'
'  '' HE.WinIniChange "Windows"
'   HE.PrintSetupDlg '15Dec05 TH Sadly WininiChange seemingly not supported in new ocx for VB
'   HE.Redraw True

''   If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "HEPrintSetupDebug", 0)) Then
''      On Error Resume Next
''      CMDialog1.Flags = &H40  'Printer Setup dialog only
''      CMDialog1.Action = 5
''      On Error GoTo 0
''   Else
''      On Error Resume Next
''      On Error GoTo 0
''      HE.PrintSetupDlg
''   End If
''   HE.Redraw True

End Sub

Private Sub mnuRePage_Click()

   HE.Paginate
   HE.Redraw True

End Sub

Private Sub mnuReplace_Click()

   success = HE.ReplaceDlg()

End Sub

''Private Sub MnuSave_Click()
'''Save & Exit from menu or pressing Escape
''
''Dim ans$, OK%, Cancel%
''
''   OK = False
''   Cancel = False
''
''   If Me.Tag = "preview" Then                    '13Apr10 CKJ changed from HighEdit.Tag
''         OK = True
''         Cancel = True
''      ElseIf HE.ReadOnly() Then
''         OK = True
''         Cancel = True
''      ElseIf Not HE.IsModified() Then
''         OK = True
''         Cancel = True
''      Else
''         ans$ = "Y"
''         Confirm "?Saving", "save changes", ans$, k
''         If Not k.escd Then
''               If ans$ = "N" Then Cancel = True
''               OK = True
''            End If
''      End If
''
''   If OK Then
''         If Cancel Then
''               Me.Tag = "exit"               '13Apr10 CKJ changed from HighEdit.Tag
''               HE.SetModified False         'clear the edited flag
''            End If
''         Hide
''      End If
''
''End Sub

Private Sub mnuSelectAll_Click()
    
   success = HE.SelectAll(False)        'set TRUE to select just th etable cell

End Sub

Private Sub mnuTable_Click()

   '!!V93!! what is the return type?
   HE.TableInsertDlg
     
End Sub

Private Sub mnuUndo_Click()

   success = HE.HEUndo(0)

End Sub

