VERSION 5.00
Begin VB.Form frmEnhTxtWin 
   Appearance      =   0  'Flat
   BackColor       =   &H00C0C0C0&
   ClientHeight    =   1590
   ClientLeft      =   3315
   ClientTop       =   3270
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
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1590
   ScaleWidth      =   5985
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Left            =   5400
      Top             =   240
   End
   Begin VB.CheckBox Check1 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Caption         =   "Check1"
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   240
      TabIndex        =   4
      Top             =   840
      Visible         =   0   'False
      Width           =   5535
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
      TabIndex        =   1
      Top             =   1200
      Width           =   855
   End
   Begin VB.Label lblExtra 
      BackStyle       =   0  'Transparent
      Height          =   375
      Left            =   3000
      TabIndex        =   5
      Top             =   970
      Width           =   2415
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
      Width           =   75
   End
End
Attribute VB_Name = "frmEnhTxtWin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'------------------------------------------------------------------------------------------------
'            ENHTXTWIN Form
'------------------------------------------------------------------------------------------------
'17Oct97 Derived from TxtWinFrm
'23Dec97 Shift - F1 function moved to Form Key-Up procedure
'        Key Preview turned on for form
'18Jan02 TH Form_KeyUp: Added to show configurable selection screen rather than standard ward selector (#47763)
'21Jan02 TH Form_KeyUp: Use local param (utdSup) to prevent compilation errors with some modules
'09May05 CKJ replaced mhtimer with timer
'            removed frmTxtWin. and frmEnhTxtWin
'11Aug11 CKJ Added extra checks on exit, as paste from clipboard bypasses normal traps. (TFS10806)

Option Explicit
DefInt A-Z

Dim XKeyCode As Integer, XShift As Integer, XKeyAscii As Integer

Private Sub cmdExit_Click()

   gk.exitval = 27
   gk.escd = True
   TimeoutOff Timer1
   Me.Hide
   If Not gk.norefresh Then ScreenRefresh

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
   
   If Len(txtBox.Text) < gk.min Then
      ''MsgBox "Minimum number of characters is" & Str$(gk.min), 16, "This entry is too short"
      popmessagecr ".", "Minimum number of characters is" & Str$(gk.min) & crlf & crlf & "This entry is too short"
      OK = False
   ElseIf Len(txtBox.Text) > gk.Max And gk.Max > 0 Then
      popmessagecr ".", "Maximum number of characters is" & Str$(gk.Max) & crlf & crlf & "This entry is too long"
      OK = False
   ElseIf vch Then
      txtBox.Text = UCase$(txtBox.Text)
      For iLoop = 1 To Len(txtBox.Text)
         If InStr(validchars, Mid$(txtBox.Text, iLoop, 1)) = 0 Then
            OK = False
            Exit For
         End If
      Next
      If Not OK Then popmessagecr ".", "Valid characters allowed are '" & validchars & "'" & msg
   ElseIf gk.decimals Then
      OK = PatternMatch(txtBox.Text, String$(Len(txtBox.Text), "0"))    '0-9 and .
      If Not OK Then
         popmessagecr ".", "Only digits 0 to 9 and . are allowed" & msg
      Else
         posn = InStr(txtBox.Text, ".")
         If posn Then
            posn = InStr(posn + 1, txtBox.Text, ".")
            If posn Then         '2nd deimal point found
               OK = False
               popmessagecr ".", "Only one decimal point is allowed" & msg
            Else                 'only 1 decimal point
               If txtBox.Tag = "2sigfigs" Then
                  If Len(txtBox.Text) > InStr(txtBox.Text, ".") + 2 Then      ' xxx.123 gives 7>4+2  xxxx.12 gives 7=5+2
                     OK = False
                     popmessagecr ".", "Maximum of two digits allowed after the decimal point" & msg
                  End If
               End If
            End If
         End If
      End If
   ElseIf gk.nums Then
      OK = PatternMatch(txtBox.Text, String$(Len(txtBox.Text), "9"))    '0-9 only
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

Dim wdth%

   If gk.timeout Then TimeoutOn Timer1
   
   If gk.Max Then
         txtBox.MaxLength = gk.Max
      Else
         txtBox.MaxLength = 78   'max length in DOS version  !!**
      End If

   wdth = txtwidth(txtBox, String$(txtBox.MaxLength + 1, "M"))
   If wdth < txtBox.Width Then txtBox.Width = wdth
    
End Sub

Private Sub Form_Deactivate()

   TimeoutOff Timer1

End Sub

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)

'23Dec97 EAC moved from Text box key up procedure
'18Jan02 TH Added to show configurable selection screen rather than standard ward selector (#47763)
'21Jan02 TH Use local param (utdSup) to prevent compilation errors with some modules

Dim Code$, desc$
Dim inuse%
Dim udtSup As supplierstruct  '21Jan02 TH Added

    Select Case KeyCode
      Case KEY_F1
          If Shift = 1 Then       'Shift F1
             Select Case Val(Me.Tag)
                Case 1
                   If TrueFalse(TxtD(dispdata$ & "\winord.ini", "Defaults", "N", "ConfiguredAdhocScreen", 0)) Then  '18Jan02 TH Added to show configurable selection screen
                      asksupplier Code$, 0, "W", "Enter Ward Code", inuse%, udtSup, False   '15Nov12 TH Added PSO param                             '   "       rather than standard ward selector (#47763)  '21Jan02 TH Use local param to prevent compilation errors
                   Else
                      AskSupplierWard Code$, desc$, inuse%
                   End If
                   If Trim$(Code$) <> "" Then
                      txtBox.Text = Code$
                   End If
                 Case Else
             End Select
          End If
      Case Else
    End Select

End Sub

Private Sub Form_Load()
SetChrome Me
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then  'all exit methods except Unload from code
      Cancel = True
      gk.exitval = 27
      txtBox.Text = ""     '!!** keep or remove?
      Me.Hide
      If Not gk.norefresh Then ScreenRefresh
   End If

End Sub

Private Sub lblbox_Change()
'Resize form, & move text box, OK & exit buttons
'Default form height = 2000
'29Apr99 TH Increased height of box in reconciliation
Dim HtOffset As Integer

   If Me.Tag = "reconcil" Then                             '01Feb99 TH Use checkbox in nonstock reconciliation
         'Me.Height = lblbox.Height + 1650                 '   "
         Me.Height = lblbox.Height + 1250 '1750            '29Apr99 TH Boosted
         HtOffset = Me.Height - 2000 ' current height less default height
         If HtOffset < 0 Then HtOffset = 0                 '   "
                                                           '   "
         txtBox.Top = lblbox.Top + lblbox.Height + 200  '!!** 01Mar96 KR Cludge deluxe but very temp!
         cmdOK.Top = txtBox.Top                            '   "
         cmdExit.Top = cmdOK.Top                           '   "
         Check1.Visible = True                             '   "
         ''Check1.top = txtBox.top + 400                     '   "
         Check1.Top = txtBox.Top + 150 '350 '14Jul05 TH
         Check1.Width = 3000
                                                           '   "
         If lblbox.Width > 6100 - 400 Then                 '   "
               Me.Width = lblbox.Width + 400               '   "
            Else                                           '   "
               Me.Width = 6100                             '   "
            End If                                         '   "
      Else                                                 '   "
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
      End If                                               '   "
End Sub

Private Sub Timer1_Timer()

   If TimedOut() Then cmdExit_Click

End Sub

Private Sub txtBox_GotFocus()
'
Dim wdth As Integer

   If gk.Max Then
         txtBox.MaxLength = gk.Max
      Else
         txtBox.MaxLength = 78   'max length in DOS version  !!**
      End If

   If gk.decimals Then gk.nums = True  'can't have decimals without digits!

   wdth = txtwidth(txtBox, String$(txtBox.MaxLength + 1, "M"))
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
                           If InStr(txtBox.Text, ".") > 0 And InStr(txtBox.SelText, ".") = 0 Then
                                 If InStr(txtBox, ".") > 0 Then
                                       KeyAscii = 0  ' got one already
                                       Beep
                                    End If
                                 
                                 
                              End If
                        ElseIf InStr("0123456789", ch$) = 0 Then
                           KeyAscii = 0  ' not valid
                           Beep
                        ElseIf txtBox.Tag = "2sigfigs" Then  '16Oct05 TH Crude masking (#81782)
                           If Left$(Right$(txtBox.Text, 3), 1) = "." Then
                              KeyAscii = 0  ' not valid
                              Beep
                           End If
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

Dim Code$, desc$, inuse%

   If XKeyAscii > 0 Then                'printable chars only
         XKeyAscii = 0
         'KeyCode, allow through
         If gk.Max = 1 Then             'one char only allowed, so highlight it again
               txtBox.SelStart = 0
               txtBox.SelLength = 1
            End If
      Else                              'non printable keycode eg F1-F12, cursor etc
        Select Case KeyCode
            Case Else
        End Select
      End If

End Sub

