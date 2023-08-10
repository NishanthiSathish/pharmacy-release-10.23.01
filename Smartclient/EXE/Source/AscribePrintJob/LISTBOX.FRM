VERSION 5.00
Begin VB.Form LstBoxFrm 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   ClientHeight    =   5385
   ClientLeft      =   1605
   ClientTop       =   315
   ClientWidth     =   8115
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   9.75
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H00000000&
   Icon            =   "LISTBOX.frx":0000
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5385
   ScaleWidth      =   8115
   Visible         =   0   'False
   Begin VB.Timer Timer1 
      Left            =   120
      Top             =   4680
   End
   Begin VB.ListBox LstHdr 
      Appearance      =   0  'Flat
      BackColor       =   &H00800000&
      Enabled         =   0   'False
      ForeColor       =   &H00FFFFFF&
      Height          =   270
      Left            =   120
      TabIndex        =   5
      TabStop         =   0   'False
      Top             =   120
      Visible         =   0   'False
      Width           =   7935
   End
   Begin VB.CommandButton CmdOk 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Caption         =   "&OK"
      Default         =   -1  'True
      Height          =   360
      Left            =   3000
      Style           =   1  'Graphical
      TabIndex        =   1
      Top             =   4800
      Width           =   960
   End
   Begin VB.CommandButton CmdCancel 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   360
      Left            =   4080
      Style           =   1  'Graphical
      TabIndex        =   2
      Top             =   4800
      Width           =   960
   End
   Begin VB.ListBox LstBox 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      ForeColor       =   &H00000000&
      Height          =   4110
      Left            =   120
      TabIndex        =   0
      Top             =   465
      Width           =   7935
   End
   Begin VB.Label lblTitle 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      ForeColor       =   &H80000008&
      Height          =   195
      Left            =   120
      TabIndex        =   3
      Top             =   0
      Width           =   75
   End
   Begin VB.Label lblHead 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      ForeColor       =   &H80000008&
      Height          =   195
      Left            =   120
      TabIndex        =   4
      Top             =   0
      Visible         =   0   'False
      Width           =   75
   End
End
Attribute VB_Name = "LstBoxFrm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------------------------------------------------------------
'                                 LISTBOX.FRM
'18Aug95 CKJ Written as a simple generic list box
'            Form name       LstBoxFrm
'            Caption         LstBoxFrm.Caption
'            Main Heading    LstBoxFrm.lblTitle
'            Column Heading  LstBoxFrm.lblHead                 (add Tabs as required)
'            List box name   LstBoxFrm.LstBox                  (add Tabs as required)
'            fill with       LstBoxFrm.LstBox.additem item$
'            to show use     LstBoxShow                        (Don't use .Show directly)
'            line chosen in  LineChosen = LstBoxFrm.LstBox.ListIndex + 1
'            text answer in  LstBoxFrm.tag  ("" if escaped)
'            after use       Unload LstBoxFrm (or use .removeitem 0 until empty)
'12Aug96 CKJ Font changed from Terminal & FixedSys 9pt to MS Linedraw 9.75pt
'13Aug96 CKJ Corrected unloading, resizing etc. Added timeout.
'12Sep96 CKJ Added k.norefresh
'28Sep96 CKJ Added tabstops.
' 4Nov96 CKJ Added search by first character
' 6Nov96 CKJ Header width now matches width of main list
'19Nov96 CKJ Supports use of popup menu on right click.
'            Fill menu with calls to PopMenu, and check on completion of
'            LstBoxShow for menu result in LstBoxFrm.LstBox.Tag. The line
'            highlighted at the tim ei sreturned in the normal way too, so
'            failure to check for right click & menu selection will resemble
'            a normal double click.
'            menu line in    MenuChosen = LstBoxFrm.LstBox.Tag
'22Oct97 CKJ Changed IIF to Iff
'12Jul98 CKJ Removed Minimise box
'04Mar99 CFY Changed to use windows colours
'18Jul00 CKJ Increased height of window at design time to 768 pixels
'09May05 CKJ replaced mhtimer with timer
'27May11 XN  F087364 Added methods SetKeyUpCallBackProc which allows external methods
'            to set a call back function to pick up key unhandled key presses from list box
'            Rem call back method needs to be of form KeyUpCallBack(ByVal Param1 as Long, ByVal Param2 as Long, ByVal Param3 as Long, ByVal Param4 as Long)
'11Jul11 TH  Merged CKJ mods below (F0030791)
'01Dec10 CKJ removed LstBoxFrm. where inappropriate & replaced remainder with Me.
'            resize: added error trap
'25Jun12 CKJ LstBox_MouseDown: Added block to highlight clicked row, or remove highlight if click is in listbox whitespace
'            (Note: equivalent for enhLstBox needed but not included in this fix)               TFS37033
'08Oct13 TH/CKJ LstBox_MouseDown: overhaul to ensure right click works when scrollbar moves
'               active area below primary loaded area (TFS 75383)
'03May16 XN	 Added ability to select printer (so moved this file from main pharmacy) 123082
'-----------------------------------------------------------------------------
Option Explicit
DefInt A-Z

Const LB_ITEMFROMPOINT = &H1A9   '08Oct13 TH/CKJ (TFS 75383)

Private lngKeyUpCallBackProc As Long    '27May11 XN  F087364

' 27May11 XN  F087364
' Allows setting call back function for unhandled key press events from this form
Public Sub SetKeyUpCallBackProc(ByVal lngProcAddress As Long)
    lngKeyUpCallBackProc = lngProcAddress
End Sub

Private Sub cmdCancel_Click()

   LstBox.ListIndex = -1
   Me.Tag = ""
   Me.Hide

End Sub

Private Sub cmdOK_Click()

   If LstBox.ListCount > 0 Then
         Me.Tag = LstBox.List(LstBox.ListIndex)
      Else
         Me.Tag = ""
      End If
   Me.Hide

End Sub

Private Sub Form_Activate()

   CmdOk.Tag = "-1"
   'TimeoutOn Timer1

End Sub

Private Sub Form_Deactivate()

   'TimeoutOff Timer1

End Sub

Private Sub Form_Load()
   SetChrome Me
   lngKeyUpCallBackProc = 0 '27May11 XN  F087364
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
                    
   If UnloadMode <> 1 Then  'anything other than unload by main prog
         Cancel = True
         LstBox.ListIndex = -1
         Me.Tag = ""
         Me.Hide
      End If

End Sub

Private Sub Form_Resize()
'NB May be able to use Me.Visible instead of the tag
'22Oct97 CKJ Changed IIF to Iff
'01Dec10 CKJ added error trap

Dim X As Long

   On Error Resume Next
   X = Me.ScaleHeight - LstBox.Top - CmdOk.Height - 240
   If X < 360 Then X = 360
   LstBox.Height = X
   CmdOk.Top = LstBox.Top + X + 120
   CmdCancel.Top = CmdOk.Top
   If Me.ScaleWidth > 360 Then
     LstBox.Width = Me.ScaleWidth - 240
   Else
     LstBox.Width = 120
   End If
   LstHdr.Width = LstBox.Width      '6Nov96 CKJ added
   On Error GoTo 0

End Sub

Private Sub LstBox_DblClick()

    cmdOK_Click

End Sub

Private Sub LstBox_KeyPress(KeyAscii As Integer)
' 4Nov96 CKJ Added search by first character
Dim ptr%, start%, char$

   char$ = UCase$(Chr$(KeyAscii))
   If LstBox.ListCount > 1 And char$ <> "" Then
         start = LstBox.ListIndex + 1
         
         For ptr = start To start + LstBox.ListCount - 1
            If UCase$(Left$(Trim$(LstBox.List(ptr Mod LstBox.ListCount)), 1)) = char$ Then
                  LstBox.ListIndex = ptr Mod LstBox.ListCount
                  Exit For
               End If
         Next
      End If

End Sub

Private Sub LstBox_KeyUp(KeyCode As Integer, Shift As Integer)
'27May11 XN  F087364 call call back method defined and key up is unhandled on form
Dim ans$
   
   If KeyCode = KEY_F1 And Shift = SHIFT_MASK Then
         'PopMenuShow ans$, 0, 0 '##
         If ans$ <> "" Then
               LstBox.Tag = ans$
               cmdOK_Click
            End If
    ElseIf lngKeyUpCallBackProc <> 0 Then
   '      CallWindowProc lngKeyUpCallBackProc, KeyCode, Shift, 0, 0      '27May11 XN  F087364
      End If

End Sub

Private Sub LstBox_MouseDown(button As Integer, Shift As Integer, X As Single, Y As Single)
'08Oct13 TH/CKJ overhaul to ensure right click works when scrollbar moves
'               active area below primary loaded area (TFS 75383)
   
Dim ans$
Dim lngPos As Long
Dim Xpos As Long
Dim Ypos As Long


   If button = 2 Then
      '25Jun12 CKJ Added block to highlight clicked row, or remove highlight if click is in listbox whitespace
      'LstBoxFrm.Caption = Str$(LstBox.ListIndex) & "   " & Str$(Y) & "  " & Str$(Y \ TxtHeight(LstBox)) DEBUG only
      'If Y \ TxtHeight(LstBox) + 1 <= LstBox.ListCount Then       '[0 to n-1] + 1 <= n
      '   LstBox.ListIndex = Y \ TxtHeight(LstBox)
      'Else
      '   LstBox.ListIndex = -1
      'End If
      '07Oct13 TH corrected logic when vertical scroll bar is shown
      Xpos = X \ Screen.TwipsPerPixelX
      Ypos = Y \ Screen.TwipsPerPixelY
      lngPos = SendMessage(LstBox.Hwnd, LB_ITEMFROMPOINT, 0, ByVal (Ypos * 65536 + Xpos))
      'LstBoxFrm.Caption = str$(lngPos) & "   " & str$(Y)  'DEBUG only
      
      If lngPos >= 0 And lngPos < LstBox.ListCount Then    '[0 to n-1]
         LstBox.ListIndex = lngPos
      Else
         LstBox.ListIndex = -1
      End If

      'PopMenuShow ans$, 0, 0
      If ans$ <> "" Then
         LstBox.Tag = ans$
         cmdOK_Click
      End If
   End If
   
   
End Sub

Private Sub Timer1_Timer()
   
   'If TimedOut() Then cmdCancel_Click 'assume Esc pressed
   
End Sub

