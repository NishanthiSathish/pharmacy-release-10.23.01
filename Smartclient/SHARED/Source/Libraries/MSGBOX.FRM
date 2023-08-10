VERSION 5.00
Begin VB.Form frmMsgBox 
   Appearance      =   0  'Flat
   Caption         =   "EMIS Health"
   ClientHeight    =   5865
   ClientLeft      =   2100
   ClientTop       =   2280
   ClientWidth     =   7410
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
   Icon            =   "MSGBOX.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5865
   ScaleWidth      =   7410
   Begin VB.Timer MHTimer1 
      Left            =   120
      Top             =   5400
   End
   Begin VB.PictureBox Picture2 
      Appearance      =   0  'Flat
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   555
      Left            =   1980
      ScaleHeight     =   555
      ScaleWidth      =   3570
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   5310
      Width           =   3570
      Begin VB.CommandButton cmd 
         Appearance      =   0  'Flat
         Caption         =   "Btn 3"
         Enabled         =   0   'False
         Height          =   375
         Index           =   3
         Left            =   2520
         Style           =   1  'Graphical
         TabIndex        =   4
         Top             =   90
         Visible         =   0   'False
         Width           =   1050
      End
      Begin VB.CommandButton cmd 
         Appearance      =   0  'Flat
         Caption         =   "Btn 2"
         Enabled         =   0   'False
         Height          =   375
         Index           =   2
         Left            =   1260
         Style           =   1  'Graphical
         TabIndex        =   3
         Top             =   90
         Visible         =   0   'False
         Width           =   1050
      End
      Begin VB.CommandButton cmd 
         Appearance      =   0  'Flat
         Cancel          =   -1  'True
         Caption         =   "Btn 1"
         Default         =   -1  'True
         Height          =   375
         Index           =   1
         Left            =   0
         Style           =   1  'Graphical
         TabIndex        =   2
         Top             =   90
         Width           =   1050
      End
   End
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'None
      ClipControls    =   0   'False
      Enabled         =   0   'False
      ForeColor       =   &H80000008&
      Height          =   510
      Left            =   135
      ScaleHeight     =   510
      ScaleWidth      =   510
      TabIndex        =   6
      TabStop         =   0   'False
      Top             =   135
      Visible         =   0   'False
      Width           =   510
   End
   Begin VB.TextBox txtBox 
      Appearance      =   0  'Flat
      BackColor       =   &H00E0E0E0&
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
      Height          =   5325
      Index           =   1
      Left            =   0
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Top             =   0
      Visible         =   0   'False
      Width           =   7395
   End
   Begin VB.TextBox txtBox 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000F&
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
      Height          =   5205
      Index           =   0
      Left            =   135
      MultiLine       =   -1  'True
      TabIndex        =   5
      Top             =   135
      Width           =   7170
   End
   Begin VB.Line Line1 
      X1              =   0
      X2              =   32767
      Y1              =   0
      Y2              =   0
   End
   Begin VB.Menu mnuHdgHelp 
      Caption         =   "&Help"
      Begin VB.Menu mnuFont 
         Caption         =   "Smaller Font                           -"
         Index           =   0
      End
      Begin VB.Menu mnuFont 
         Caption         =   "Larger Font                            +"
         Index           =   1
      End
      Begin VB.Menu mnuFont 
         Caption         =   "Store Font Setting"
         Index           =   2
      End
      Begin VB.Menu Sep0 
         Caption         =   "-"
      End
      Begin VB.Menu mnuCopy 
         Caption         =   "&Copy to clipboard"
         Shortcut        =   ^C
      End
      Begin VB.Menu Sep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "Help &Contents                        F1"
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
      Begin VB.Menu mnuHelp 
         Caption         =   "-"
         Index           =   3
      End
      Begin VB.Menu mnuAbout 
         Caption         =   "&About"
      End
   End
End
Attribute VB_Name = "frmMsgBox"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'---------------------------------------------------------------------------------------
'           MSGBOX.FRM/FRX
'
'25Sep97 CKJ Replacement for MsgBox. Features;
'  * Self sizing, up to full screen width/height
'  * Column aware; tabs in first line determine tab settings (max 100)
'  * Scroll bars enabled automatically
'  * Navigate with cursor keys, PgUp/PgDn, Home/End and Ctrl+cursor keys
'  * Up to 32K of text displayed
'  * Menu with Edit/Copy and Help/About/Printscreen options
'  * Highlight any contiguous block then copy with right click
'  * Sizeable border
'  * Timeout enabled
'  * Icons extracted from Windows, consistent with system messages
'  * Button text is language aware (except abort/retry/ignore)
'  * Caption width affects width of form ('MsgBox trucates mess...')
'  * Multiple line messages can be separated by CR, LF or CRLF (not LFCR)
'  * Title defaults to 'ASCribe' if non given
'  * Recursive; allows MessageBox to call MessageBox again
'
'12Oct97 CKJ Released for alpha test.
'            WARNING: Do NOT use this form directly - it must be called via
'            the handler function MessageBox(text$, buttons%, title$)
'26Oct97 CKJ Consolidated both menu headings into just one.
'            Corrected error when setting form tag with button code.
'            Added queryunload handling
'19Nov97 CKJ Corrected background colour - now set to &H8000000F&
'02Oct98 CKJ Amend font size, and store in terminal.ini
'04Jun04 CKJ 32bit
'
'mods wanted
'-----------
'/set default button correctly
' language options for menu (also for abort/retry/ignore)
' scroll bars to appear if form is resized smaller
'/ignore keystrokes for a 200 millisecs after displaying
' add ScreenRefresh but honour k.norefresh
'/highlight buttons on single letter press
' width is sometimes too narrow in spite of being set by TextWidth
'---------------------------------------------------------------------------------------
DefInt A-Z
Option Explicit

Dim ticks As Single

Private Sub cmd_Click(index As Integer)

   TimeoutOff MHTimer1
   If Timer > ticks Then
         Me.Tag = cmd(index).Tag                '26Oct97 CKJ was frmMsgBox
         Me.Hide
      End If

End Sub

Private Sub cmd_KeyPress(index As Integer, Keyascii As Integer)
Dim i%

   For i = 1 To 3
      If Not cmd(i).Enabled Then Exit For
      If InStr(UCase$(cmd(i).Caption), UCase$("&" & Chr$(Keyascii))) Then
            Keyascii = 0
            cmd(i).SetFocus
         End If
   Next
   TimeoutOn MHTimer1

End Sub

Private Sub Form_Activate()

Dim i%

   SetTextBoxReadOnly txtBox(0), True
   SetTextBoxReadOnly txtBox(1), True
   txtBox(0).SelStart = 0
   txtBox(1).SelStart = 0

   For i = 1 To 3
      If Not cmd(i).Enabled Then Exit For
      If cmd(i).Default = True Then
            cmd(i).SetFocus
            Exit For
         End If
   Next

   ticks = Timer + 0.2
   TimeoutOn MHTimer1

End Sub

Private Sub Form_Deactivate()

   TimeoutOff MHTimer1

End Sub

Private Sub Form_KeyPress(Keyascii As Integer)
'02Oct98 CKJ Added

   If Keyascii = 45 Then         ' - key
         Keyascii = 0
         mnuFont_Click 0
      End If
   
   If Keyascii = 43 Then         ' + key
         Keyascii = 0
         mnuFont_Click 1
      End If

End Sub

Private Sub Form_Load()

   SetChrome Me
   
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then 'not unloading from code
         Cancel = True
         SendKeys "{esc}"
      End If

End Sub

Private Sub Form_Resize()
'left offset:
' simple box   135
' simple+icon  135 + icon + 135
' scroll bars  0
' scroll+icon  135 + icon + 135

Dim Loffset%

   On Error Resume Next
   Picture2.Move (Me.ScaleWidth - Picture2.Width) \ 2, Me.ScaleHeight - Picture2.Height
   Loffset = Iff(Picture1.Tag = "1", Picture1.Left + Picture1.Width, 0)
   
   txtBox(0).Left = Loffset + 135
   txtBox(0).Width = Me.ScaleWidth - txtBox(0).Left - 135  '135 is the right border
   txtBox(0).Height = Picture2.top - txtBox(0).top
   
   txtBox(1).Left = Iff(Loffset, Loffset + 135, 0)
   txtBox(1).Width = Me.ScaleWidth - txtBox(1).Left
   txtBox(1).Height = Picture2.top - txtBox(1).top
   
   If Loffset Then Picture1.Visible = True
   On Error GoTo 0
               
End Sub

Private Sub Form_Unload(Cancel As Integer)
   
   TimeoutOff MHTimer1

End Sub

Private Sub MhTimer1_Timer()

   If TimedOut() Then SendKeys "{esc}"

End Sub

Private Sub mnuAbout_Click()

   ShowAboutBox "EMIS Health"
   TimeoutOn MHTimer1

End Sub

Private Sub mnuCopy_Click()
Dim i%

   If txtBox(0).Visible Then i = 0 Else i = 1

   If txtBox(i).SelText = "" Then
         Clipboard.SetText txtBox(i).Text
      Else
         UndoCutCopyPasteDel 3       'Copy selected text
      End If
   
   TimeoutOn MHTimer1

End Sub

Private Sub mnuExit_Click()

   SendKeys "{esc}"

End Sub

Private Sub mnuFont_Click(index As Integer)
'02Oct98 CKJ Added

Dim font As Single, fontwas As Single

   Select Case index
      Case 0, 1
         fontwas = txtBox(0).FontSize
         font = fontwas
         Do
            font = font + Iff(index, 1, -0.25)
            On Error Resume Next
            txtBox(0).FontSize = font
            On Error GoTo 0
         Loop While font <= 36 And font >= 4 And fontwas = txtBox(0).FontSize
         txtBox(1).FontSize = txtBox(0).FontSize
      Case 2
         WritePrivateIniFile ASCTerminalName(), "MsgBoxFontSize", Format$(txtBox(0).FontSize), dispdata$ & "\TERMINAL.INI", 0
         FlushIniCache
      End Select

End Sub

Private Sub mnuHdgHelp_Click()
'02Oct98 CKJ Added


   mnuFont(2).Caption = "Store Font Setting    (" & Format$(txtBox(0).FontSize) & "pt)"

End Sub

Private Sub mnuHelp_Click(index As Integer)
 
   Select Case index
      Case 0: Help Me.hWnd, 0                       '&Contents    F1
      Case 1: HelpSearch Me.hWnd                    '&Search for Help on...
      Case 2: HelpGet Me.hWnd, HELP_HELPONHELP, 0   '&How to use Help
      End Select

End Sub

Private Sub txtBox_Click(index%)

   TimeoutOn MHTimer1

End Sub

Private Sub txtBox_KeyDown(index%, KeyCode As Integer, Shift As Integer)

   TimeoutOn MHTimer1

End Sub

Private Sub txtBox_KeyPress(index As Integer, Keyascii As Integer)

   cmd_KeyPress 1, Keyascii

End Sub

