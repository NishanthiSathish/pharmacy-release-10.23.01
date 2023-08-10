VERSION 5.00
Begin VB.Form AboutBox 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "About EMIS Health..."
   ClientHeight    =   4740
   ClientLeft      =   3810
   ClientTop       =   3030
   ClientWidth     =   5640
   ClipControls    =   0   'False
   BeginProperty Font 
      Name            =   "System"
      Size            =   9.75
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   Icon            =   "ABOUTBOX.frx":0000
   KeyPreview      =   -1  'True
   LinkMode        =   1  'Source
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4740
   ScaleWidth      =   5640
   Begin VB.CommandButton Cmd_OK 
      Appearance      =   0  'Flat
      Caption         =   "&Print Screen"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   360
      Index           =   1
      Left            =   4200
      Style           =   1  'Graphical
      TabIndex        =   7
      Top             =   2610
      Width           =   1215
   End
   Begin VB.PictureBox Pic_ApplicationIcon 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
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
      Height          =   480
      Left            =   135
      MouseIcon       =   "ABOUTBOX.frx":030A
      MousePointer    =   99  'Custom
      Picture         =   "ABOUTBOX.frx":0614
      ScaleHeight     =   480
      ScaleWidth      =   480
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   210
      Width           =   480
   End
   Begin VB.CommandButton Cmd_OK 
      Appearance      =   0  'Flat
      Cancel          =   -1  'True
      Caption         =   "&OK"
      Default         =   -1  'True
      Height          =   360
      Index           =   0
      Left            =   4185
      Style           =   1  'Graphical
      TabIndex        =   6
      Top             =   3105
      Width           =   1215
   End
   Begin VB.Line lin_HorizontalLine1 
      BorderWidth     =   2
      X1              =   765
      X2              =   5400
      Y1              =   1995
      Y2              =   1995
   End
   Begin VB.Label LblTitle 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   18
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   825
      Left            =   780
      TabIndex        =   0
      Top             =   180
      Width           =   4800
   End
   Begin VB.Label LblVersion 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Version "
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
      Height          =   390
      Left            =   765
      TabIndex        =   2
      Top             =   1080
      Width           =   4845
   End
   Begin VB.Label Lbl_Microsoft 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "EMIS Health.  Copyright 1983-"
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
      Height          =   435
      Left            =   765
      TabIndex        =   3
      Top             =   1455
      Width           =   4815
   End
   Begin VB.Label Lbl_Info 
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
      Height          =   2625
      Left            =   765
      TabIndex        =   4
      Top             =   2175
      Width           =   4785
   End
   Begin VB.Label Lbl_InfoValues 
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
      Height          =   2625
      Left            =   2745
      TabIndex        =   5
      Top             =   2175
      Width           =   2850
   End
End
Attribute VB_Name = "AboutBox"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'---------------------------------------------------------------------------------
'     ABOUT Box
'
'19Dec96 CKJ Corrected the copyright dates - now programmed, and over two lines
'13May97 CKJ Added PrintScreen option - temporary for testing at this time
'18May97 CKJ Added largest free memory block
'23May97 CKJ Added user & terminal info
'26Oct97 CKJ Shift-F1 for debugging information. Added Option Explicit
'            WARNING: Do not call this form directly - use ShowAboutBox()
'13Jan98 CKJ Copyright changed from '© 1983-1997' to '© 1983-1998'
'27Nov98 CKJ Added open channel and loaded forms to debug page
'            Added site name & number to front page in place of GDI/user resources
'11Mar99 CFY Changed to Windows colours
'24May99 CKJ AboutDebug: Replaced ProgsDrv with AppPathNoSlash
'24May99 TH  AboutDebug: change to above mod
'06Sep99 CKJ AboutDebug: Extended to include acquirelock & named channels
'            Updated to '© 1983-1998' to '© 1983-1999'
'            Aligned labels correctly.
'27Sep99 CKJ Added CountTerminals
'28Oct99 CKJ Added right click menu to icon: offers Heap debug screens
'03Feb00 CKJ Updated to 2000
'05Apr00 AE  AboutDebug:Added build number
'04Jan01 JN  AboutDebug: Updated '© 1983-2000' to '© 1983-2001'
'10Jan02 TH  Use Global year (from Winver) (#58157) for copyright
'24Feb04 CKJ added Flushinicache
'30Mar04 CKJ {SP1}
'10Sep12 CKJ AboutDebug: Added transport type
'17Nov14 XN  Removed Build Number from debug, and added correct version number, and copyright 59672
'---------------------------------------------------------------------------------

Option Explicit
DefInt A-Z
'

Private Sub AboutDebug()
'24May99 CKJ Replaced ProgsDrv with AppPathNoSlash
'24May99 TH  change to above mod
'06Sep99 CKJ Extended to include acquirelock & named channels
'27Sep99 CKJ Added CountTerminals
'05Apr00 AE  Added build number

Dim msg$, totsize&, freeroom&, tmp$, country%, WinFlags As Long, temp%, count%

   Screen.MousePointer = HOURGLASS
   msg = "DESCRIPTION:" & Space$(9) & TB & "VALUE:" & Space$(45) & cr
   msg = msg & "Current path" & TB & CurDir$ & cr
   msg = msg & "Application path" & TB & App.Path & cr
   msg = msg & "Application name" & TB & App.EXEName & cr
   msg = msg & "Application title" & TB & App.title & cr
   'msg = msg & "Build Number" & TB & ASCBuildNo & cr$                                    '17nov14 XN removed 59672               '05Apr00 AE Added
   'msg = msg & "Version" & TB & App.Major & "." & App.Minor & "." & App.Revision & cr$   '17nov14 XN updated 59672
   msg = msg & "Version" & TB & App.Major & "." & App.Minor & ".0." & App.Revision & cr$
   msg = msg & "Copyright Year" & TB & CopyrightYear & cr                                 '17nov14 XN added 59672
   'msg = msg & "Version" & TB & App. & cr$

   msg = msg & "Application helpfile" & TB & App.HelpFile & cr
   msg = msg & "Previous instance" & TB & YesNo$((App.PrevInstance)) & cr
   msg = msg & cr
   msg = msg & "Site name" & TB & hospname1$ & cr
   msg = msg & TB & hospname2$ & cr
   msg = msg & "Abbreviation" & TB & hospabbr$ & cr
   msg = msg & "Command line" & TB & Command$ & cr
   msg = msg & "Site number" & TB & Format$(SiteNumber, "000") & cr
   msg = msg & "LocationID_Site (Dept)" & TB & Format$(gDispSite) & cr
   msg = msg & "LocationID_Site (Patient)" & TB & Format$(gPatientSite) & cr
   'msg = msg & "Single user" & TB & YesNo$(singleuseronly) & cr ' not exposed here
''   CountTerminals tmp$, ""
''   msg = msg & "Total terminals used" & TB & tmp$ & cr
   msg = msg & cr
   
   GetCountry country
   msg = msg & "Country code" & TB & Format$(country) & cr
   msg = msg & "Monetary units" & TB & money(8) & "    " & money(7) & "     Sales Tax: " & money(9) & cr
   msg = msg & "Programs path" & TB & AppPathNoSlash() & cr
   msg = msg & "Root path" & TB & rootpath$ & cr
   msg = msg & "Dispdata path" & TB & dispdata$ & cr
   msg = msg & "Patdata path" & TB & patdatapath$ & cr
   msg = msg & "Translog path" & TB & transpath$ & cr
   msg = msg & "Orderlog path" & TB & orderlogpath$ & cr
   msg = msg & "Terminal name" & TB & ASCTerminalName() & cr     'txtd("C:\ASCTERM.INI", "", "Default", "TerminalName", 0) & cr
   msg = msg & "User ID" & TB & UserID$ & cr
   msg = msg & "User Name" & TB & UserFullName$ & cr
   msg = msg & "Configuration" & TB & acclevels$ & cr & cr
   
   msg = msg & "SessionID" & TB & Format$(g_SessionID) & cr
   msg = msg & "RequestID_Prescription" & TB & Format$(gRequestID_Prescription) & cr
   msg = msg & "RequestID_Dispensing" & TB & Format$(gRequestID_Dispensing) & cr
   On Error Resume Next
   msg = msg & "EpisodeID" & TB & Format$(GetState(g_SessionID, StateType.Episode)) & cr
   msg = msg & "WPatientID" & TB & Format$(GetState(g_SessionID, StateType.Entity)) & cr
   On Error GoTo 0
            
   msg = msg & cr & "Loaded Forms:" & cr            '26Nov98 CKJ Added form debug info
   For count = 0 To Forms.count - 1
      'msg = msg & "      " & vbGetCtrlName(Forms(Count)) & TB & Forms(Count).Caption & Iff((Forms(Count).Visible), " (Visible)", " (Hidden)") & cr
      msg = msg & "      " & Forms(count).name & TB & Forms(count).Caption & Iff((Forms(count).Visible), " (Visible)", " (Hidden)") & cr
   Next
   
   '10Sep12 CKJ Added block
   Select Case gTransportType()
      Case 0:    tmp = "None"
      Case 1:    tmp = "Direct"
      Case 2:    tmp = "Web"
      Case Else: tmp = "Unknown"
      End Select
   msg = msg & cr & "SQL Transport:" & TB & tmp & cr
   
   msg = msg & cr & "Open File Channels" & TB & "Handle" & TB & "Mode" & cr     '27Nov98 CKJ Moved from Wident
   On Error Resume Next
   For count = 1 To 30                              'first 30 channels only, for speed
      temp = False                                  'assume channel not in use
      temp = FileAttr(count, 2)                     'error occurs if handle not allocated
      If temp Then                                  'no error, so print channel in use
            msg = msg & "      " & Format$(count) & TB & Format$(temp) & TB & Format$(FileAttr(count, 1)) & "    "
            Select Case FileAttr(count, 1)
               Case 1:  msg = msg & "Input"
               Case 2:  msg = msg & "Output"
               Case 4:  msg = msg & "Random"
               Case 8:  msg = msg & "Append"
               Case 32: msg = msg & "Binary"
               End Select
            msg = msg & cr
         End If
   Next
   On Error GoTo 0

   AcquireLock tmp$, 100, 0       '06Sep99 CKJ debug mode
   msg = msg & cr & "AcquireLock on Channel" & TB & "Status" & TB & "File" & cr & tmp$ & cr
   
   ListOpenedFiles tmp$           '06Sep99 CKJ added
   msg = msg & cr & "File Channels Opened for Binary Access (Note: May not be in current use)" & cr & tmp$ & cr

''   freespace "C", totsize&, freeroom&
''   msg = msg & "Size of disk C:" & TB & Format$(totsize&, "0,0") & " bytes" & cr
''   msg = msg & "Free space on C:" & TB & Format$(freeroom&, "0,0") & " bytes" & cr
''   tmp$ = Left$(CurDir$, 1)
''   If tmp$ <> "C" Then
''         freespace tmp$, totsize&, freeroom&
''         msg = msg & "Size of disk " & tmp$ & ":" & TB & Format$(totsize&, "0,0") & " bytes" & cr
''         msg = msg & "Free space on " & tmp$ & ":" & TB & Format$(freeroom&, "0,0") & " bytes" & cr
''      End If

'»   WinFlags = GetWinFlags()               'Get current Windows configuration
   msg = msg & "Windows version" & TB & WindowsVersion() '»  & "   (DOS " & DosVersion() & ")" & cr
'»   msg = msg & "Maths co-processor" & TB & Iff(WinFlags And WF_80x87, "Present", "None") & cr
'»   msg = msg & "GDI resources" & TB & Format$(GetFreeSystemResources(GFSR_GDIRESOURCES)) & "% free" & cr
'»   msg = msg & "User resources" & TB & Format$(GetFreeSystemResources(GFSR_USERRESOURCES)) & "% free" & cr
'»   msg = msg & "Free memory" & TB & Format$(GetFreeSpace(0), "#,#") & " bytes" & cr
'»   msg = msg & "Largest free block" & TB & Format$(GlobalCompact(&HFFFFFFFF), "#,#") & " bytes" & cr
   
'»   WinFlags = GetRAMSize(tmp$)
'http://support.microsoft.com/default.aspx?scid=kb;en-us;106553
'http://www.faqs.org/faqs/visual-basic-faq/windows/

   msg = msg & tmp$

   Screen.MousePointer = STDCURSOR

   popmessagecr "#", msg

End Sub

Private Sub Cmd_OK_Click(Index)
   
   If Index = 1 Then  'PrintScreen
         Me.Hide
         ScreenRefresh

         PrintScreen
      End If

   Unload Me

End Sub

''Private Sub CountTerminals(TotalTerminals$, TerminalNames$)
'''27Sep99 CKJ Written
'''            Returns a count of terminal sections in Terminal.ini
'''            plus a string containing the terminal names, each followed by CRLF
''
''Dim sFilename As String
''Dim sLine As String
''Dim iPosn As Integer
''Dim iTerms As Integer
''Dim iChan As Integer
''
''   iTerms = 0
''   TerminalNames$ = ""
''   sFilename = dispdata$ & "\terminal.ini"
''   If fileexists(sFilename) Then
''         iChan = FreeFile
''         Open sFilename For Input As #iChan
''         Do While Not EOF(iChan)
''            Line Input #iChan, sLine
''            If Left$(sLine, 1) = "[" Then
''                  sLine = Mid$(sLine, 2)
''                  iPosn = InStr(sLine, "]")
''                  If iPosn Then
''                        sLine = Left$(sLine, iPosn - 1)
''                        If Len(sLine) Then
''                              If UCase$(sLine) <> "DEFAULT" Then
''                                    TerminalNames$ = TerminalNames$ & sLine & crlf
''                                    iTerms = iTerms + 1
''                                 End If
''                           End If
''                     End If
''               End If
''         Loop
''         Close #iChan
''      End If
''
''   TotalTerminals$ = Format$(iTerms)
''
''End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)

   If Shift = SHIFT_MASK And KeyCode = KEY_F1 Then
         KeyCode = 0
         AboutDebug
      End If

End Sub

Private Sub Form_Load()

Dim PercentGDI%, PercentUser%, TerminalName$

   SetChrome Me
   CentreForm Me
   
   'PercentGDI = GetFreeSystemResources(GFSR_GDIRESOURCES)
   'PercentUser = GetFreeSystemResources(GFSR_USERRESOURCES)
   'Lbl_Info = "Free Memory:" & cr & "User Resources:" & cr & "GDI Resources:" & cr & cr
   'Lbl_Info = "Site name:" & cr & "    " & hospname1$ & cr & "    " & hospname2$ & cr & "Abbreviation:" & cr & "Site Number:" & cr & cr
   Lbl_Info = "Site name:    " & hospname1$ & cr & "                    " & hospname2$ & cr & cr & "Abbreviation:" & cr & "Site Number:" & cr & cr
   Lbl_Info = Lbl_Info & "User ID:" & cr & "User Name:" & cr & "Terminal Name:" & cr & "Terminal Date and Time:" & cr & cr & "Press Shift-F1 or double click icon above for details"
   
   'Lbl_InfoValues = Format$(GetFreeSpace(0) \ 1024, "#,#") & " Kb" & cr & Format$(PercentGDI) & "% Free" & cr & Trim$(Str$(PercentUser)) & "% Free"
   Lbl_InfoValues = cr & cr & cr & hospabbr$ & cr & Format$(SiteNumber)
''   TerminalName$ = txtd("C:\ASCTERM.INI", "", "Default", "TerminalName", 0)
   Lbl_InfoValues = Lbl_InfoValues & cr & cr & UserID$ & cr & UserFullName$ & cr & ASCTerminalName() & cr & Format$(Now, "ddd.  dd mmm yyyy  hh:nn")

   'Lbl_Microsoft = "ASC Computer Software Ltd.  Copyright © 1983-" & CopyrightYear & cr & "All trademarks acknowledged"  '17nov14 XN updated 59672 '10Jan02 TH Use Global year (from Winver) (#58157)
   Lbl_Microsoft = App.LegalCopyright & cr & "All trademarks acknowledged"  '10Jan02 TH Use Global year (from Winver) (#58157)

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then 'not unloading from code
         Cancel = True
         SendKeys "{esc}"
      End If

End Sub

Private Sub Pic_ApplicationIcon_Click()
   
   Cmd_OK(0).SetFocus

End Sub

Private Sub Pic_ApplicationIcon_DblClick()

   AboutDebug

End Sub

Private Sub Pic_ApplicationIcon_MouseDown(button As Integer, Shift As Integer, X As Single, Y As Single)

Dim iCount As Integer
Dim sTmp1 As String
Dim sTmp2 As String
Dim iHeapCount As Integer
Dim ans As String

   If button = RIGHT_BUTTON Then
         button = 0
         popmenu 0, "", 0, 0

         Heap 20, iHeapCount, sTmp1, sTmp2, 0
         replace sTmp1, "|", cr & "Heap: ", 0
         popmenu 2, "Heap: " & sTmp1, 0, 0
         
         popmenu 1, String$(45, "-"), 0, 0
         popmenu 1, "Clear Item and File caches ", True, 0
         popmenu 1, "Clear WLookUps cache ", True, 0

         PopMenuShow ans$, 0, 0
         Select Case Val(ans$)
            Case 1 To iHeapCount
               ReDim sLines(iHeapCount) As String
               deflines sTmp2, sLines(), "|", 1, iHeapCount
               Heap 100, Val(sLines(Val(ans$))), "", "", 0
            Case iHeapCount + 2
               FlushIniCache
            Case iHeapCount + 3
               FlushLookupCache
            End Select

         popmenu 0, "", 0, 0
      End If

End Sub

