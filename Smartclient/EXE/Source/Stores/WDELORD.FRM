VERSION 5.00
Begin VB.MDIForm MDIEvents 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000C&
   Caption         =   "V7.3 beta"
   ClientHeight    =   5580
   ClientLeft      =   2070
   ClientTop       =   2175
   ClientWidth     =   5940
   Icon            =   "WDELORD.frx":0000
   LinkTopic       =   "MDIForm1"
   Visible         =   0   'False
   WindowState     =   2  'Maximized
   Begin VB.PictureBox StatusBar 
      Align           =   2  'Align Bottom
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      FillColor       =   &H8000000F&
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
      Height          =   600
      Left            =   0
      ScaleHeight     =   38
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   394
      TabIndex        =   0
      Top             =   4980
      Width           =   5940
   End
   Begin VB.Menu mnuFile 
      Caption         =   "&File"
      Begin VB.Menu MnuExit 
         Caption         =   "E&xit"
         Shortcut        =   ^X
      End
   End
   Begin VB.Menu mnuReIndex 
      Caption         =   "&Index"
      Begin VB.Menu mnuIndex 
         Caption         =   "&Tidy Order Index"
         Index           =   0
      End
      Begin VB.Menu mnuIndex 
         Caption         =   "Tidy Re&quisition Index"
         Index           =   1
      End
      Begin VB.Menu mnuIndex 
         Caption         =   "Tidy &Reconciliation Index"
         Index           =   2
      End
      Begin VB.Menu IndexSep 
         Caption         =   "-"
      End
      Begin VB.Menu mnuFullIndex 
         Caption         =   "&Full Order Re-index"
      End
   End
   Begin VB.Menu mnuOptionsTop 
      Caption         =   "&Options"
      Begin VB.Menu MnuOption 
         Caption         =   "Delete &Delivery Notes Older than 7 days"
         Index           =   0
      End
      Begin VB.Menu OptionsSep1 
         Caption         =   "-"
      End
      Begin VB.Menu MnuOptTidyReprints 
         Caption         =   "Tidy &Stores Reprints"
         Index           =   1
      End
      Begin VB.Menu MnuOptTidyReprints 
         Caption         =   "Tidy Dispensary &Reprints"
         Index           =   2
      End
      Begin VB.Menu MnuOptSetDuration 
         Caption         =   "Set &File Duration"
         Index           =   3
      End
   End
   Begin VB.Menu mnuHelpHdg 
      Caption         =   "&Help"
      WindowList      =   -1  'True
      Begin VB.Menu mnuHelp 
         Caption         =   "&Contents                     F1"
         Index           =   0
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "&Search for Help on ..."
         Index           =   1
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "&How to use Help"
         Index           =   2
      End
      Begin VB.Menu HelpSep 
         Caption         =   "-"
      End
      Begin VB.Menu MnuAbout 
         Caption         =   "&About"
      End
   End
End
Attribute VB_Name = "MDIEvents"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
''
'''----------------------------------------------------------------------
'''  Stores Maintenance Program
'''----------------------------------------------------------------------
'''30Oct98 EAC removed old code to change drive
'''26Jan99 EAC MDIForm_Unload: Add semaphore file that will be left as a dropping if the index process fails
'''17May99 AE  Added MnuOptSetDuration. Allows user to set reprint linger times on disk.
'''25Jan00 AE  mnuFullIndex_Click:Added parameters to call to Delord.
'''25Jan00 AE  mnuOption_Click: added line to set iDeleteDeliv.
'''25Jan00 AE  mnuOptTidyReprints_Click:  Added parameters
'''----------------------------------------------------------------------
''DefInt A-Z
''Option Explicit
''
''Const MAX_CHAR = 2      '17May99 AE Max number of characters allowed in text boxes on FrmEnterDur
''
''Private Sub MDIForm_Load()
'''25Jul96 KR  Added ability to run duplicate instance in debug mode
'''23Sep96 CKJ Jet ver error - does not end now
'''27Oct96 KR  Added check for teamwork so disable Teamwork options on Main menu if applicable.
'''15Jan97 EAC Made Ward Stock invisible and disabled by license file
'''            Added general help page
'''30Oct98 EAC removed old code to change drive
''
''Dim Handle As Integer, menuhandle As Integer, result As Integer
''Dim x As Long, done As Integer, i%
''Dim SaveTitle$
''
''   Screen.MousePointer = 11
''
''   '26Jan99 EAC This functionality should appear in Sub Main()
''   'If InStr(Command, "/debug") = 0 Then
''   '     'Check for duplicate instance    28Mar96  KR Added
''   '      If app.PrevInstance Then
''   '           SaveTitle$ = app.Title
''   '           app.Title = SaveTitle$ & "... duplicate instance."      '03Dec96 CKJ Added 'SaveTitle$ &'
''   '           Me.Caption = SaveTitle$ & "... duplicate instance."     '   "
''   '           AppActivate SaveTitle$
''   '           SendKeys "% R", True
''   '           End
''   '         End If
''   '   End If
''   '
''   'app.HelpFile = app.Path & "\ASCSHELL.HLP"   '15Jan97 EAC add general help page
''   '---
''
''   Show
''
''   Screen.MousePointer = 0
''
''End Sub
''
''
''
''Private Sub mnuAbout_Click()
''
'''   ShowAboutBox Me, "ASCribe Maintenance"
''
''End Sub
''
''Private Sub mnuExit_Click()
''
''   Unload Me
''
''End Sub
''
''Private Sub mnuFullIndex_Click()
''
'''25Jan00 AE Added parameters to call to Delord.
''
'''Dim txt$, ans$, opt$
'''
'''   txt$ = "Rebuilding index requires exclusive use of the system"
'''   If MnuOption(0).Checked Then
'''         opt$ = cr$ & cr$ & "Options selected : " & cr$
'''         If MnuOption(0).Checked Then opt$ = opt$ & "     Delete Delivery Notes Older than 7 days." & cr$
'''      End If
'''   txt$ = "SYSTEM MANAGER ONLY" & cr & cr & txt$ & opt$ & cr & cr & "OK to start re-indexing now?"
'''
'''   ans$ = "N"
'''   askwin "Re-build Stock Control Files", txt$, ans$, k
'''
'''   If UCase$(Trim$(ans$)) = "Y" And Not k.escd Then
'''         MDIEvents.Enabled = False
'''         Screen.MousePointer = 11
'''         Delord 1, False               '25Jan00 AE  Added parameters
'''         Delord 2, False               '       "
'''         Delord 3, False               '       "
'''         Screen.MousePointer = 0
'''         MDIEvents.Enabled = True
'''      End If
'''
'''   DelordPrint "Finished", "", "", ""
'''
'''   Me.SetFocus
''
''End Sub
''
''Private Sub mnuHelp_Click(Index As Integer)
''
''   Select Case Index
''      Case 0: Help 0
''      Case 1: HelpSearch
''      Case 2: HelpGet HELP_HELPONHELP, 0
''   End Select
''
''   Me.SetFocus
''
''End Sub
''
''Private Sub mnuIndex_Click(Index As Integer)
''
'''Dim txt$, ans$, Title$
'''
'''
'''   Select Case Index
'''      Case 0: Title$ = "Re-index Order File"
'''      Case 1: Title$ = "Re-index Requisition File"
'''      Case 2: Title$ = "Re-index Reconciliation File"
'''   End Select
'''
'''   txt$ = "Tidying the index can be done during the day"
'''   txt$ = "SYSTEM MANAGER ONLY" & cr & cr & txt$ & cr & cr & "OK to start re-indexing now?"
'''
'''   ans$ = "N"
'''   askwin Title$, txt$, ans$, k
'''
'''   If UCase$(Trim$(ans$)) = "Y" And Not k.escd Then
'''         MDIEvents.Enabled = False
'''         Screen.MousePointer = 11
'''         Select Case Index
'''            Case 0: buildordreqindex 1, False
'''            Case 1: buildordreqindex 5, False
'''            Case 2: buildordreqindex 4, False
'''         End Select
'''         Screen.MousePointer = 0
'''         MDIEvents.Enabled = True
'''      End If
'''
'''   DelordPrint "Finished", "", "", ""
'''
'''   Me.SetFocus
''
''End Sub
''
''Private Sub MnuOption_Click(Index As Integer)
''
'''Dim success%
'''
'''   MnuOption(Index).Checked = Not MnuOption(Index).Checked
'''   iDeleteDeliv = MnuOption(0).Checked                      '25Jan00 AE  added
'''   WritePrivateIniFile "", "DeleteDelNotes", Format$(MnuOption(0).Checked), dispdata$ & iniFile$, success%
''
''End Sub
''
''Private Sub MnuOptSetDuration_Click(Index As Integer)
''
''''17May99 AE Written
'''
'''Dim msg$, msg1$, success%
'''Dim fm$, T$, x%, Value$, MaxLength%
'''
'''   T$ = "!Warning!"
'''   msg$ = "Unable to save new settings. The system will" & cr$
'''   msg$ = msg$ & "revert to default settings upon exiting" & cr$
'''   msg$ = msg$ & "this program." & cr$
'''   msg$ = msg$ & "Please contact your System Administrator." & cr$ & cr$
'''   msg$ = msg$ & "(Could not find or write to " & iniFile$ & " )"
'''
'''   msg1$ = "Unable to find current settings. Please " & cr$
'''   msg1$ = msg1$ & "contact your System Administrator." & cr$ & cr$
'''   msg$ = msg$ & "(Could not find or write to " & iniFile$ & " )"
'''
'''   fm$ = "##0"   'Format for displaying in textboxes
'''   success% = True
'''   MaxLength = MAX_CHAR
'''
''''Set up FrmEnterDur Before showing it...
'''
'''  'Fill text boxes with current values
'''   success% = ReadWriteDuration("S_DLV", Value$, "")
'''   If Len(Value$) > MaxLength Then MaxLength = Len(Value$)
'''   If success Then FrmEnterDur.TxtDelNote.Text = Value$
'''
'''   If success Then
'''      success% = ReadWriteDuration("S_ORD", Value$, "")
'''      If Len(Value$) > MaxLength Then MaxLength = Len(Value$)
'''      FrmEnterDur.TxtOrderNote.Text = Value$
'''   End If
'''
'''   If success Then
'''      success% = ReadWriteDuration("S_RQS", Value$, "")
'''      If Len(Value$) > MaxLength Then MaxLength = Len(Value$)
'''      FrmEnterDur.TxtRequisition.Text = Value$
'''   End If
'''
'''   If success Then
'''      success% = ReadWriteDuration("S_RET", Value$, "")
'''      If Len(Value$) > MaxLength Then MaxLength = Len(Value$)
'''      FrmEnterDur.TxtReturnNote.Text = Value$
'''   End If
'''
'''   If success Then
'''      success% = ReadWriteDuration("D_WKS", Value$, "")
'''      If Len(Value$) > MaxLength Then MaxLength = Len(Value$)
'''      FrmEnterDur.TxtWorksht.Text = Value$
'''   End If
'''
'''   If success Then
'''      success% = ReadWriteDuration("D_LBL", Value$, "")
'''      If Len(Value$) > MaxLength Then MaxLength = Len(Value$)
'''      FrmEnterDur.TxtLabels.Text = Value$
'''   End If
'''
'''   If Not success Then
'''      popmessagecr T$, msg1$
'''      Unload FrmEnterDur
'''      Set FrmEnterDur = Nothing
'''   End If
'''
'''   FrmEnterDur.TxtDelNote.MaxLength = MaxLength      'Limit the text boxes to MAX_CHAR characters
'''   FrmEnterDur.TxtOrderNote.MaxLength = MaxLength    'unless a longer entry is present in the
'''   FrmEnterDur.TxtRequisition.MaxLength = MaxLength  'ini file.
'''   FrmEnterDur.TxtReturnNote.MaxLength = MaxLength
'''   FrmEnterDur.TxtWorksht.MaxLength = MaxLength
'''   FrmEnterDur.TxtLabels.MaxLength = MaxLength
'''
'''   FrmEnterDur.Show 1
'''
'''   If FrmEnterDur.Tag = "1" Then      'Ok button was pressed, commit changes to ini file
'''       success% = ReadWriteDuration("S_DLV", "", (FrmEnterDur.TxtDelNote.Text))
'''       If success% Then success% = ReadWriteDuration("S_RQS", "", (FrmEnterDur.TxtRequisition.Text))
'''       If success% Then success% = ReadWriteDuration("S_RET", "", (FrmEnterDur.TxtReturnNote.Text))
'''       If success% Then success% = ReadWriteDuration("S_ORD", "", (FrmEnterDur.TxtOrderNote.Text))
'''       If success% Then success% = ReadWriteDuration("D_WKS", "", (FrmEnterDur.TxtWorksht.Text))
'''       If success% Then success% = ReadWriteDuration("D_LBL", "", (FrmEnterDur.TxtLabels.Text))
'''       FlushIniCache
'''   End If
'''
'''   Unload FrmEnterDur
'''   Set FrmEnterDur = Nothing
''
''End Sub
''
''Private Sub MnuOptTidyReprints_Click(Index As Integer)
'''
'''   Select Case Index
'''      Case 1:
'''         TidyStoreReprints False    ''25Jan00 AE  Added parameters
'''      Case 2:
'''         TidyDispReprints False    ''25Jan00 AE  Added parameters
'''   End Select
''
''End Sub
''
''Private Sub MnuSubHelp_Click()
''
'''   SendKeys "{F1}"
''
''End Sub
''
