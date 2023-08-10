VERSION 5.00
Begin VB.Form frmTxtWin 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   ClientHeight    =   1590
   ClientLeft      =   1095
   ClientTop       =   1485
   ClientWidth     =   5985
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
   Icon            =   "TXTWIN.frx":0000
   LinkTopic       =   "Form1"
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1590
   ScaleWidth      =   5985
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   65535
      Left            =   5280
      Top             =   120
   End
   Begin VB.TextBox txtBox 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   240
      MaxLength       =   78
      TabIndex        =   0
      Top             =   1200
      Width           =   3135
   End
   Begin VB.CommandButton cmdExit 
      Appearance      =   0  'Flat
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   295
      Left            =   4920
      Style           =   1  'Graphical
      TabIndex        =   2
      Top             =   1200
      Width           =   855
   End
   Begin VB.CommandButton cmdOK 
      Appearance      =   0  'Flat
      Caption         =   "&OK"
      Default         =   -1  'True
      Height          =   295
      Left            =   3840
      Style           =   1  'Graphical
      TabIndex        =   1
      Top             =   1200
      Width           =   855
   End
   Begin VB.Label lblbox 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      ForeColor       =   &H80000008&
      Height          =   195
      Left            =   120
      TabIndex        =   3
      Top             =   120
      UseMnemonic     =   0   'False
      Width           =   75
   End
End
Attribute VB_Name = "frmTxtWin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'------------------------------------------------------------------------------------------------
'            TXTWIN Form
'------------------------------------------------------------------------------------------------
'31Jan96 CKJ Written. NB Not recursive
'            Generic replacement for InputBox plus compatibility with
'            simple Popmessage/Pickwindow,Printwcr,Inputline,Closewindow
'            InputLine and InputCharCR
'15Mar96 CKJ Mods to allow k.validchars etc
'13Aug96 CKJ Added timeout
'12Sep96 CKJ Added norefresh
'13Sep96 CKJ Allow the decimal point key when there is one already ONLY if the
'            highlighted text contains a decimal point which is about to be replaced.
'            Don't beep if text at max length, if any part is highlighted
'30Sep96 CKJ Managed to stop that annoying beep on 1st character - note that this only happens
'            if k.max = 0, which should rarely be the case!
'20Nov98 TH  Added tag check to allow for change to default buttons
'04Mar99 CFY Changed to use Windows colours
'04Jun04 CKJ 32bit
'08oct08 CKJ Turned usemnemonic off for the label
'11Aug11 CKJ Added extra checks on exit, as paste from clipboard bypasses normal traps. (TFS10806)
'08Jun15 XN  Update txtBox_GotFocus to limit textbox width to 32767
'Bug 209300: Pharmacy manufacturing - Formula window throws an "Invalid Use of Null" error on searching with a single lettter input
Option Explicit
DefInt A-Z

Dim XKeyCode As Integer, XShift As Integer, XKeyAscii As Integer

Public cancelClicked As Boolean

Private Sub cmdExit_Click()
   
   cancelClicked = True
   gk.exitval = 27
   gk.escd = True
   TimeoutOff Timer1
   Me.Hide
   If Not gk.norefresh Then ScreenRefresh  '12Sep96 CKJ Added

End Sub

Private Sub cmdOK_Click()
'11Aug11 CKJ Added extra checks, as paste from clipboard bypasses normal traps. (TFS10806)

Dim OK As Integer
Dim posn As Integer
Dim msg As String
Dim vch As Integer
Dim iLoop As Integer
Dim validchars As String

   OK = True
   vch = Len(asciiz(RTrim$(gk.validchars)))       'number of valid chars NB not just asciiz as trailing spaces should not be counted
   validchars = UCase$(Left$(gk.validchars, vch)) 'ignore nulls etc at end
   msg = crlf & crlf & "Please change or choose Cancel"
   
   If Len(Trim$(txtBox.text)) < gk.min Then
      ''MsgBox "Minimum number of characters is" & Str$(gk.min), 16, "This entry is too short"
      popmessagecr ".", "Minimum number of characters is" & Str$(gk.min) & crlf & crlf & "This entry is too short"
      OK = False
   ElseIf Len(txtBox.text) > gk.Max And gk.Max > 0 Then
      popmessagecr ".", "Maximum number of characters is" & Str$(gk.Max) & crlf & crlf & "This entry is too long"
      OK = False
   ElseIf vch Then
      txtBox.text = UCase$(txtBox.text)
      For iLoop = 1 To Len(txtBox.text)
         If InStr(validchars, Mid$(txtBox.text, iLoop, 1)) = 0 Then
            OK = False
            Exit For
         End If
      Next
      If Not OK Then popmessagecr ".", "Valid characters allowed are '" & validchars & "'" & msg
   ElseIf gk.decimals Then
      OK = PatternMatch(txtBox.text, String$(Len(txtBox.text), "0"))    '0-9 and .
      If Not OK Then
         popmessagecr ".", "Only digits 0 to 9 and . are allowed" & msg
      Else
         posn = InStr(txtBox.text, ".")
         If posn Then
            posn = InStr(posn + 1, txtBox.text, ".")
            If posn Then
               OK = False
               popmessagecr ".", "Only one decimal point is allowed" & msg
            End If
         End If
      End If
   ElseIf gk.nums Then
      OK = PatternMatch(txtBox.text, String$(Len(txtBox.text), "9"))    '0-9 only
      If Not OK Then popmessagecr ".", "Only digits 0 to 9 are allowed" & msg
   End If

   If OK Then
      gk.exitval = 13
      Me.Hide
      If Not gk.norefresh Then ScreenRefresh  '12Sep96 CKJ Added
   Else
      Beep
   End If

End Sub

Private Sub Form_Activate()
   
   cancelClicked = False
   If gk.timeout Then TimeoutOn Timer1
   If Me.Tag = "reconcil" Then   '20Nov98 TH
         cmdExit.SetFocus               '20Nov98 TH
      End If                            '20Nov98 TH

End Sub

Private Sub Form_Deactivate()

   TimeoutOff Timer1

End Sub

Private Sub Form_Load()
   SetChrome Me
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then  'all exit methods except Unload from code
         Cancel = True
         gk.exitval = 27
         txtBox.text = ""     '!!** keep or remove?
         Me.Hide
         If Not gk.norefresh Then ScreenRefresh  '12Sep96 CKJ Added
      End If

End Sub

Private Sub lblbox_Change()
'Resize form, & move text box, OK & exit buttons
'Default form height = 2000
Dim HtOffset As Integer

   Me.Height = lblbox.Height + 1250
   HtOffset = Me.Height - 2000 ' current height less default height
   If HtOffset < 0 Then HtOffset = 0
   
   txtBox.Top = lblbox.Top + lblbox.Height + 200  '!!** 01Mar96 KR Cludge deluxe but very temp!
   cmdOK.Top = txtBox.Top
   cmdExit.Top = cmdOK.Top
   
   If lblbox.Width > 6100 - 400 Then
         Me.Width = lblbox.Width + 400
      Else
         Me.Width = 6100
      End If
   
End Sub

Private Sub Timer1_Timer()

   If TimedOut() Then cmdExit_Click

End Sub

Private Sub txtBox_GotFocus()
' Dim wdth As Integer
Dim wdth As Single

   If gk.Max Then
         txtBox.MaxLength = gk.Max
      Else
         txtBox.MaxLength = 78   'max length in DOS version  !!**
      End If

   If gk.decimals Then gk.nums = True  'can't have decimals without digits!

   wdth = txtwidth(txtBox, String$(txtBox.MaxLength + 1, "M"))
   If wdth > 32767 Then wdth = 32767    ' XN 08Jun15 Limit to prevent crash on some resolutions
   If wdth < txtBox.Width Then txtBox.Width = wdth

End Sub

Private Sub txtBox_KeyDown(KeyCode As Integer, Shift As Integer)
'fires every time on autorepeat

   If gk.timeout Then TimeoutOn Timer1

   XKeyCode = KeyCode
   XShift = Shift
   XKeyAscii = 0

End Sub

Private Sub txtBox_KeyPress(KeyAscii As Integer)
'deal here with printable keys (incl backspace, [8])
'fires every time on autorepeat
'
'13Sep96 CKJ Allow the decimal point key when there is one already ONLY if the
'            highlighted text contains a decimal point which is about to be replaced.
'            Don't beep if text at max length, if any part is highlighted
'30Sep96 CKJ Added gk.max > 0 to stop that annoying beep on 1st character

Dim vch As Integer, vchs As String, ch$, posn As Integer
   
   Select Case KeyAscii
      Case 8    'no action; backspace
      Case Else
         XKeyAscii = KeyAscii 'remember the key for use in KeyUp
         
         vch = Len(asciiz(RTrim$(gk.validchars)))      'number of valid chars '11Aug11 CKJ Added rtrim (TFS10806)
         ch$ = UCase$(Chr$(KeyAscii))          'uppercase char for validation
         If vch Then                           'Validchars set, ie InputCharCR equivalent
            Select Case InStr(gk.validchars, ch$)
               Case 0, Is > vch
                  KeyAscii = 0         'not a valid character
                  popmessagecr "Note", "Valid keys are  " & Left$(gk.validchars, vch)
               Case Else
                  KeyAscii = Asc(ch$)  'return upper case letters only
               End Select
         Else
            If Len(txtBox) = gk.Max And gk.Max > 0 And txtBox.SelLength = 0 Then  '30Sep96 CKJ Added gk.max > 0
               Beep
            End If
            If gk.nums Then
               If gk.decimals And ch$ = "." Then
                  '13Sep96 CKJ
                  'Allow the decimal point key when there is one already ONLY if the
                  'highlighted text contains a decimal point which is about to be replaced.
                  If InStr(txtBox.text, ".") > 0 And InStr(txtBox.SelText, ".") = 0 Then
                     If InStr(txtBox, ".") > 0 Then
                        KeyAscii = 0  ' got one already
                        Beep
                     End If
                  End If
               ElseIf InStr("0123456789", ch$) = 0 Then
                  KeyAscii = 0  ' not valid
                  Beep
               End If
            End If
         End If
      End Select

End Sub

Private Sub txtBox_KeyUp(KeyCode As Integer, Shift As Integer)
'fires once on releasing key
'F1 = 112  F12 = 123
'PgUp, PgDn, End, Home, Cursor L/U/R/D  33 - 40
'shift = 1  Ctrl = 2  Alt = 4

   If XKeyAscii > 0 Then                'printable chars only
         XKeyAscii = 0
         'KeyCode, allow through
         If gk.Max = 1 Then             'one char only allowed, so highlight it again
               txtBox.SelStart = 0
               txtBox.SelLength = 1
            End If
      Else                              'non printable keycode eg F1-F12, cursor etc
        '
      End If

End Sub

