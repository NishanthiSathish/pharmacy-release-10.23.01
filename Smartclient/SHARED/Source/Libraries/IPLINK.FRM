VERSION 5.00
Begin VB.Form frmIPlink 
   Appearance      =   0  'Flat
   AutoRedraw      =   -1  'True
   BackColor       =   &H8000000A&
   Caption         =   "ASCribe IP Link"
   ClientHeight    =   1320
   ClientLeft      =   1095
   ClientTop       =   2880
   ClientWidth     =   7365
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
   Icon            =   "IPLINK.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1320
   ScaleWidth      =   7365
   Visible         =   0   'False
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   100
      Left            =   4260
      Top             =   690
   End
   Begin VB.TextBox txtStatus 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
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
      Height          =   1305
      Index           =   1
      Left            =   0
      MultiLine       =   -1  'True
      TabIndex        =   3
      Top             =   0
      Width           =   2535
   End
   Begin VB.CommandButton cmdCancel 
      Appearance      =   0  'Flat
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
      Height          =   300
      Left            =   2910
      TabIndex        =   0
      Top             =   750
      Visible         =   0   'False
      Width           =   1155
   End
   Begin VB.TextBox txtStatus 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1305
      Index           =   0
      Left            =   0
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   1
      Top             =   0
      Visible         =   0   'False
      Width           =   2535
   End
   Begin VB.Label lblMessage 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   405
      Left            =   5340
      TabIndex        =   4
      Top             =   120
      Visible         =   0   'False
      Width           =   1695
   End
   Begin VB.Label lblStatus 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   405
      Left            =   3450
      TabIndex        =   2
      Top             =   120
      Visible         =   0   'False
      Width           =   1665
   End
   Begin VB.Menu mnuFile 
      Caption         =   "&File"
      Begin VB.Menu mnuStoreSize 
         Caption         =   "&Store Position"
      End
      Begin VB.Menu sep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuClose 
         Caption         =   "&Close"
      End
   End
   Begin VB.Menu mnuViewHdg 
      Caption         =   "&View"
      Begin VB.Menu mnuView 
         Caption         =   "&View Messages"
         Index           =   0
      End
   End
   Begin VB.Menu mnuHelpHdg 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelp 
         Caption         =   "&Contents                             F1"
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
      Begin VB.Menu mnuHelp 
         Caption         =   "&About"
         Index           =   4
      End
   End
End
Attribute VB_Name = "frmIPlink"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'                         IPlink.frm
'                         ----------
'24nov03 CKJ Written
'            Support for IP based data transfer using IP*Works V4 IPport control
'            DO NOT call the design time copy of this form. There may be more than one robot
'            connected and each one must be handled through an instance of this form.
'            Create an instance and refer to each separately by name or index number as appropriate.
'            Use the MechDisp.bas handlers to refer to the form
'11Mar04 CKJ Released
'16jun04 CKJ Form_QueryUnload: Use IPlinkCloseConnection instead of duplicated code
'12Aug05 CKJ Extended interface. See Mechdisp for details.
'05Oct05 CKJ Set default display buffer size from 30KB to just 10KB, but editable up to 30K max       (#78364)
'#######################################################################
'19Dec06 CKJ Ported from V8.6 to V9.7
'10Feb07 CKJ Revised to use ascribeTcpipComms. Removed IPPortV4.
'11Feb07 CKJ Note that mobjIPClient does not support setting WinsockLoaded - lines commented out but may need revision
'06Mar07 CKJ Added error traps for mobjIPClient (ascribeTcpipComms.IpClient)
'            Corrected SetWindowWord Int to Long

Option Explicit
DefInt A-Z

Public WithEvents mobjIPClient As ascribeTcpipComms.IpClient    '10Feb07 CKJ
Attribute mobjIPClient.VB_VarHelpID = -1

Private Declare Function SetWindowWord Lib "user32" (ByVal Hwnd As Long, ByVal cmd As Long, ByVal nVal As Long) As Long
Const SWW_PARENT = -8

Dim OldParenthWnd As Long           '06Mar07 CKJ
Dim MessageBusy As Integer          'flags to prevent re-entrant calls
Dim StatusBusy As Integer           '  "
Dim MaxDisplayBufferSize As Long    '05Oct05 CKJ

Private Sub cmdCancel_Click()

   IPlinkHide Me

End Sub

Private Sub Form_Activate()
   
   IPlinkResize Me

End Sub

Private Sub Form_GotFocus()

   IPlinkResize Me
   
End Sub

Private Sub Form_Initialize()
'06Mar07 CKJ Added error trap

   On Error GoTo Form_Initialize_Err
   Set mobjIPClient = CreateObject("ascribeTcpipComms.IpClient")
   On Error GoTo 0
   
Form_Initialize_Exit:
Exit Sub

Form_Initialize_Err:
   MsgBox "Robot Interface needs to be installed and registered on this terminal" & vbCrLf & "Missing component is the 'AscribeTcpipComms' client", vbCritical + vbOKOnly, "Mechanical Dispensing"
Resume Form_Initialize_Exit

End Sub

Private Sub Form_KeyPress(KeyAscii As Integer)

   If KeyAscii = KEY_ESCAPE Then
      IPlinkHide Me
   End If

End Sub

Private Sub Form_Load()
'22Jun04 CKJ revised parent.hwnd handling - cannot get hwnd for Winord so now do a call back
'23Jun04 CKJ incorporated Exename

Dim L As Long, t As Long, w As Long, h As Long
Dim prefix As String

   'Set as floating application topmost form
   'SetLastError to 0                                                       'may be needed
   'OldParenthWnd = SetWindowWord(Me.hWnd, SWW_PARENT, GetHWndParent())     'e.g. MDIevents.hWnd
   ''popmessagecr "", Format$(GetHWndParent()) & "  " & Format$(MainScreen.hWnd)
   'if success=0 and GetLastError <>0 then failed                           'may be needed
   
   OldParenthWnd = SetWindowWord(Me.Hwnd, SWW_PARENT, GetNewParentHWnd())   'e.g. MDIevents.hWnd or MainScreen.hWnd

   SetTextBoxReadOnly txtStatus(0), True
   SetTextBoxReadOnly txtStatus(1), True

   On Error Resume Next
   prefix = App.EXEName & "IPlink"
   L = CLng(terminal$(prefix & "Left", Format$(Me.Left)))
   t = CLng(terminal$(prefix & "Top", Format$(Me.top)))
   w = CLng(terminal$(prefix & "Width", Format$(Me.Width)))
   h = CLng(terminal$(prefix & "Height", Format$(Me.Height)))
   Me.Move L, t, w, h
   
   MaxDisplayBufferSize = Val(terminal$(prefix & "DisplayBuffer", "5000"))      '05Oct05 CKJ added
   On Error GoTo 0

End Sub

Private Sub Form_Paint()
   
   IPlinkResize Me

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
'16Jun04 CKJ Call to IPlinkCloseConnection instead of duplicated code

Dim dummy As Integer

   If UnloadMode = 1 Then                             'unload from code
         'If IPclient.WinsockLoaded Then
         '      If IPclient.Connected Then
         '            IPclient.KeepAlive = False
         '            IPclient.Connected = False
         '            IPclient.Linger = False
         '            DoEvents
         '         End If
         '      IPclient.WinsockLoaded = False
         '   End If
         dummy = IPlinkCloseConnection(Me)
 '!!**11feb07        mobjIPClient.WinsockLoaded = False
      Else
         Cancel = True
         IPlinkHide Me
      End If
   
End Sub

Private Sub Form_Resize()
   
   IPlinkResize Me

End Sub

Private Sub Form_Terminate()
'10Feb07 CKJ

   If Not mobjIPClient Is Nothing Then        '06Mar07 CKJ added
      Set mobjIPClient = Nothing
   End If

End Sub

Private Sub Form_Unload(Cancel As Integer)

Dim retval As Long      '06Mar07 CKJ

    retval = SetWindowWord(Me.Hwnd, SWW_PARENT, OldParenthWnd)
   
End Sub

Private Sub mobjIPClient_Connected(ByVal StatusCode As Integer, ByVal Description As String)
'12Aug05 CKJ !!** May need to raise event in calling routine

   lblStatus.Caption = "Connection " & Iff(StatusCode, "failed: Status =" & Str$(StatusCode), "accepted") & ":  " & Description
   
End Sub

Private Sub mobjIPClient_DataIn(ByVal Text As String, ByVal EOL As Boolean)
'12Aug05 CKJ not tied to MLLP encapsulation
'            !!** may need to append when EOL not used

  'If EOL Then Text = Text & Chr$(&H1C) & Chr$(&HD)      'replace the end of line chars
   If EOL Then Text = Text & mobjIPClient.EOL                'replace the end of line chars  '12Aug05 CKJ not tied to MLLP encapsulation
   lblStatus.Caption = "Reply: " & FormatCtrlChars(Text) 'Show it

  'LastReply True, Text                                  'Store message 18Aug05 CKJ removed
   LastReply 1, Text                                     '18Aug05 CKJ Append message
       
   If Val(cmdCancel.Tag) Then                            'shown modally, so hide now
         If EOL Or mobjIPClient.EOL = "" Then                '18Aug05 CKJ Added
               IPlinkHide Me
            End If
      End If

End Sub


Private Sub mobjIPClient_Disconnected(ByVal StatusCode As Integer, ByVal Description As String)

   lblStatus.Caption = "Disconnected: [Code " & Format$(StatusCode) & "] " & Description

End Sub

Private Sub mobjIPClient_Error(ByVal ErrorCode As Integer, ByVal Description As String)

   lblStatus.Caption = "ERROR: [" & Format$(ErrorCode) & "] " & Description

End Sub

Private Sub mobjIPClient_ReadyToSend()

   lblStatus.Caption = "Ready to Send"

End Sub

Private Sub lblMessage_Change()

Dim lngLength As Long

   If Not MessageBusy Then
         MessageBusy = True

         If lblMessage.Caption = Chr$(12) Then
               txtStatus(1).Text = ""
            Else
               If Len(lblMessage.Caption) Then
                     MechDispLog Me.Tag, "M", (lblMessage.Caption)
                  End If
               
               lngLength = Len(txtStatus(1).Text) + Len(lblMessage.Caption)
               If lngLength > MaxDisplayBufferSize Then                                                      '05Oct05 CKJ was 30000
                     txtStatus(1).Text = "..." & Mid$(txtStatus(1).Text, lngLength - MaxDisplayBufferSize)   '   "
                  End If
               txtStatus(1).Text = txtStatus(1).Text & lblMessage.Caption
            End If

         txtStatus(1).Refresh
         txtStatus(1).SelStart = 0
         txtStatus(1).SelLength = 0
         lblMessage.Caption = ""
         MessageBusy = False
      End If

End Sub

Private Sub lblStatus_Change()

Dim strDateTime As String
Dim vbNow As Variant
Dim dblTimer As Double
Dim lngLength As Long

   If Not StatusBusy Then
         StatusBusy = True

         Do
            dblTimer = Timer
            vbNow = Now
         Loop While dblTimer <> Timer  'ensure that the timer has not ticked to the next 1/18th of a second
         strDateTime = Format$(vbNow, "dd-mm-yyyy hh:nn:ss") & Right$(Format$(dblTimer, ".00"), 3)
         
         MechDispLog Me.Tag, "S", strDateTime & " " & lblStatus.Caption
         
         lngLength = Len(txtStatus(0).Text) + Len(lblStatus.Caption)
         If lngLength > MaxDisplayBufferSize Then                                                         '05Oct05 CKJ was 30000
               txtStatus(0).Text = "..." & Mid$(txtStatus(0).Text, lngLength - MaxDisplayBufferSize)
            End If
         txtStatus(0).Text = txtStatus(0).Text & strDateTime & " " & lblStatus.Caption & crlf
         txtStatus(0).Refresh
         txtStatus(0).SelStart = 32767
         txtStatus(0).SelLength = 0
         
         lblStatus.Caption = ""
         StatusBusy = False
      End If
      
End Sub

Private Sub mnuClose_Click()

   IPlinkHide Me

End Sub

Private Sub mnuHelp_Click(Index As Integer)
   
   Select Case Index
      Case 0: SendKeys "{F1}"
      Case 1: HelpSearch Me.Hwnd
      Case 2: HelpGet Me.Hwnd, HELP_HELPONHELP, 0
     'Case 3  'separator
      Case 4: ShowAboutBox "IP-Link Interface"
      End Select

End Sub

Private Sub mnuStoreSize_Click()
'23Jun04 CKJ incorporated Exename

Dim iniSection As String
Dim iniFile As String
Dim prefix As String

   On Error Resume Next
   prefix = App.EXEName & "IPlink"
   iniFile$ = dispdata$ & "\terminal.ini"
   iniSection$ = ASCTerminalName$()
   WritePrivateIniFile iniSection$, prefix & "Left", Format$(Me.Left), iniFile$, 0
   WritePrivateIniFile iniSection$, prefix & "Top", Format$(Me.top), iniFile$, 0
   WritePrivateIniFile iniSection$, prefix & "Width", Format$(Me.Width), iniFile$, 0
   WritePrivateIniFile iniSection$, prefix & "Height", Format$(Me.Height), iniFile$, 0
   On Error GoTo 0

End Sub

Private Sub mnuView_Click(Index As Integer)

   txtStatus(0).Visible = Not txtStatus(0).Visible
   txtStatus(1).Visible = Not txtStatus(1).Visible
   mnuView(0).Checked = txtStatus(0).Visible

End Sub

Private Sub mnuViewHdg_Click()

   mnuView(0).Checked = txtStatus(0).Visible

End Sub

Private Sub Timer1_Timer()
'07mar04 ckj
'        Cannot reliably hide the form automatically
'        so use a timer to allow normal event queue to be serviced
'        then hide here

   IPlinkHide Me

End Sub

