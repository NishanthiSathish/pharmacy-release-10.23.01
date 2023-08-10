VERSION 5.00
Begin VB.Form Ques 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   ClientHeight    =   6825
   ClientLeft      =   30
   ClientTop       =   315
   ClientWidth     =   9510
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
   Icon            =   "QUESCROL.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6825
   ScaleWidth      =   9510
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Left            =   2640
      Top             =   4080
   End
   Begin VB.CommandButton cmdPrint 
      Appearance      =   0  'Flat
      Caption         =   "&Print"
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
      Height          =   375
      Left            =   270
      Style           =   1  'Graphical
      TabIndex        =   11
      TabStop         =   0   'False
      Top             =   4095
      Visible         =   0   'False
      Width           =   1320
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
      Height          =   375
      Left            =   6000
      Style           =   1  'Graphical
      TabIndex        =   5
      Top             =   4080
      Width           =   1335
   End
   Begin VB.VScrollBar ScrollBar 
      Height          =   3855
      Left            =   9180
      TabIndex        =   6
      TabStop         =   0   'False
      Top             =   120
      Visible         =   0   'False
      Width           =   255
   End
   Begin VB.CommandButton cmdOK 
      Appearance      =   0  'Flat
      Caption         =   "&OK"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   4200
      Style           =   1  'Graphical
      TabIndex        =   1
      Top             =   4080
      Width           =   1335
   End
   Begin VB.Frame F3D1 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      ForeColor       =   &H00000000&
      Height          =   3975
      Left            =   120
      TabIndex        =   0
      Top             =   0
      Width           =   9000
      Begin VB.PictureBox Background 
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
         ForeColor       =   &H80000008&
         Height          =   2235
         Left            =   120
         ScaleHeight     =   2235
         ScaleWidth      =   8805
         TabIndex        =   4
         TabStop         =   0   'False
         Top             =   240
         Visible         =   0   'False
         Width           =   8805
         Begin VB.TextBox txtQ 
            Appearance      =   0  'Flat
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
            Height          =   285
            Index           =   0
            Left            =   3960
            TabIndex        =   12
            Top             =   360
            Visible         =   0   'False
            Width           =   4695
         End
         Begin VB.ComboBox cmbQ 
            Appearance      =   0  'Flat
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
            Height          =   315
            Index           =   0
            Left            =   3960
            Style           =   1  'Simple Combo
            TabIndex        =   10
            Top             =   900
            Visible         =   0   'False
            Width           =   3015
         End
         Begin VB.ListBox lst1 
            Appearance      =   0  'Flat
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   225
            Index           =   0
            Left            =   3960
            TabIndex        =   9
            Top             =   660
            Visible         =   0   'False
            Width           =   3375
         End
         Begin VB.CommandButton cmdQ 
            Appearance      =   0  'Flat
            Caption         =   "Enter"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   375
            Index           =   0
            Left            =   3960
            Style           =   1  'Graphical
            TabIndex        =   7
            Top             =   0
            Visible         =   0   'False
            Width           =   735
         End
         Begin VB.Label lblInfo 
            Appearance      =   0  'Flat
            AutoSize        =   -1  'True
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
            Height          =   195
            Index           =   0
            Left            =   3960
            TabIndex        =   8
            Top             =   120
            Visible         =   0   'False
            Width           =   45
         End
         Begin VB.Label lblDesc 
            Appearance      =   0  'Flat
            AutoSize        =   -1  'True
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
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
            Height          =   195
            Index           =   0
            Left            =   90
            TabIndex        =   3
            Top             =   120
            Visible         =   0   'False
            Width           =   45
         End
      End
      Begin VB.TextBox ZoomText 
         Appearance      =   0  'Flat
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   975
         Left            =   300
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   2
         Top             =   2700
         Visible         =   0   'False
         Width           =   1815
      End
   End
End
Attribute VB_Name = "Ques"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'------------------------------------------------------------------------------------------------
'                                        QuesScrl.frm
'
'This form displays label, masked input, command button and combo box arrays,
'and allows data validation via the callback procedure Ques_Callback.
'The controls are contained within a picture control to facilitate scrolling.
'
'Do not show this form directly, it must be set up and shown via the following;
'  QuesMakeCtrl
'  QuesSetCtrl
'  QuesShow
'
'On completion the user presses OK or Cancel, returning Ques.tag = "-1" or ""
'
'29Jul96 CKJ Released for limited use and testing
'22Oct96 CKJ Added QueryUnload
'28Oct96 CKJ/EAC Added Callback on OK button - Index is set to 0, and Tag ="-1"
'            If the form cannot be accepted at this time, present message to
'            user, then set Tag="" and do a setfocus to the appropriate control.
' 4Nov96 CKJ Modified to allow UP/DN keys
' 5Nov96 CKJ Added Shift F1 facility to text box
'12Aug97 CKJ Added Print button. To use call QuesSetCtrl
'            Widened size of text box and moved form fractionally to avoid clipping
'            bottom line on display
'04Mar99 CFY Changed to use windows colours
'20Apr99 CKJ Corrected above mod: removed bold from right hand label
'24may04 CKJ aligned lblInfo with text boxes & made autosizing
'            made lblDesc autosizing
'09May05 CKJ replaced MHmasked input with plain text box - not operational yet
'15Jun05 CKJ Enabled basic use without masked input for V9.3
'16Jun05 CKJ All mask types enabled, but type 8 is not positional. It only acts as a list of valid chars
'            Insert by Ctrl-V and Shift-Ins are trapped, but not when using right click or drag/drop
'------------------------------------------------------------------------------------------------
Option Explicit
DefInt A-Z

Const BACKHEIGHT = 32768         ' Height of the background picture control, in twips

Dim Delta As Single              ' Space between control rows, in twips
Dim Initialized As Integer       ' Flag used by Form_Paint handler to set focus upon start-up
Dim ZoomIndex As Integer         ' Active text box indices
Dim ScrollVisible As Integer     ' Visible states for mode-specific controls
Dim SaveZoomText As Integer      ' Save flag for zoomed text
'

Private Sub cmbQ_GotFocus(index As Integer)

   CtrlSetFocus index

   If cmbQ(index).ListIndex = -1 And cmbQ(index).ListCount > 0 Then
      cmbQ(index).ListIndex = 0
   End If

End Sub

Private Sub cmbQ_KeyDown(index As Integer, KeyCode As Integer, Shift As Integer)

   If Shift = 0 Then
      Select Case KeyCode  'L 37 R 39 U 38 D 40
         Case 38                'U -> shift tab
            TabNext index, False
            KeyCode = 0
         Case 40                'D -> tab
            TabNext index, True
            KeyCode = 0
         Case 37: KeyCode = 38  'L -> U
         Case 39: KeyCode = 40  'R -> D
         End Select
   End If

End Sub

Private Sub cmbQ_KeyPress(index As Integer, Keyascii As Integer)
Dim ch$, i%, posn%, found%

   found = 0
   ch$ = UCase$(Chr$(Keyascii))
   posn = cmbQ(index).ListIndex
   
   For i = posn + 1 To cmbQ(index).ListCount - 1
      If ch$ = UCase$(Left$(cmbQ(index).List(i), 1)) Then
            found = i
            Exit For
         End If
   Next
   
   If i = cmbQ(index).ListCount Then ' failed to match
      For i = 0 To posn
         If ch$ = UCase$(Left$(cmbQ(index).List(i), 1)) Then
            found = i
            Exit For
         End If
      Next
   End If
   
   If found Then cmbQ(index).ListIndex = found
   Keyascii = 0
             
End Sub

Private Sub cmbQ_LostFocus(index As Integer)

   Ques_Callback index

End Sub

Private Sub cmdCancel_Click()
   
   Hide

End Sub

Private Sub cmdOK_Click()
'28Oct96 CKJ/EAC Added Callback on OK button

   Tag = "-1"
   Ques_Callback 0     'Index 0 indicates OK button pressed

   If Tag = "-1" Then  'If Callback has cleared the Tag then stay
      Me.Hide
   End If

End Sub

Private Sub CmdPrint_Click()
'12Aug97 CKJ Added

   Ques_Callback 1000     'Print requested

End Sub

Private Sub cmdQ_Click(index As Integer)

   Ques_Callback index

End Sub

Private Sub cmdQ_GotFocus(index As Integer)

   CtrlSetFocus index
   cmdOK.default = False

End Sub

Private Sub cmdQ_LostFocus(index As Integer)

   cmdOK.default = True

End Sub

Private Sub CtrlSetFocus(index)
'Make the control visible if it has scrolled out of view

   If Not ScrollBar.Visible Then Exit Sub

   If index < ScrollBar.Value Then
      ScrollBar.Value = index
   ElseIf index > (ScrollBar.Value + Val(F3D1.Tag) - ScrollBar.Max) Then
      ScrollBar.Value = index - Val(F3D1.Tag) + ScrollBar.Max
   End If

End Sub

Private Sub Form_Activate()
'31Jan03 TH (PBSv4) Allow Tag to alter focus of button
   
   If CmdCancel.Tag = "DEFAULT" Then     '31Jan03 TH (PBSv4)
      On Error Resume Next               '    "   Cheap way to get around interference with doevents
      CmdCancel.SetFocus
      If Err Then
         Err = 0
      End If
      On Error GoTo 0
      CmdCancel.default = True
   Else
      cmdOK.default = True
   End If
   
   If Me.Tag = "timeoutoff" Then  '20Mar07 TH
      TimeoutOff Timer1
   Else
      TimeoutOn Timer1
   End If
   
   Tag = ""
   

End Sub

Private Sub Form_Deactivate()

   TimeoutOff Timer1

End Sub

Private Sub Form_Load()
'
   SetChrome Me
   Screen.MousePointer = HOURGLASS ' Switch to the hourglass cursor while loading
   Initialized = False

   Delta = txtQ(0).Height + 15      '15Jun05 CKJ Added + 15
  
End Sub

Private Sub Form_Paint()
' If this is the first time this event was fired, finish
' initializing the form; otherwise, do nothing.

   If Not Initialized Then
      Initialized = True

      On Error Resume Next   'Set focus to the first visible control
      txtQ(1).SetFocus
      cmdQ(1).SetFocus
      lst1(1).SetFocus
      cmbQ(1).SetFocus
      On Error GoTo 0
      Screen.MousePointer = False
   End If

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
'22Oct96 CKJ Added

   If UnloadMode <> 1 Then
      Cancel = True
      Me.Hide
   End If

End Sub

Private Sub Form_Resize()
'scaleheight 5730   height 5175   top 5280
' diff           555           105
'11Mar13 TH Reduced size of active portion by 120 to account for padding on buttons (TFS 58135)

Dim ht As Integer
Dim NeedScroll%

   ht = Ques.ScaleHeight - 555
   If ht > 500 Then
      Ques.F3D1.Height = ht - 120  '11Mar13 TH Reduced size by 120 to account for padding below (TFS 58135)
      Ques.cmdOK.top = ht + 120
      Ques.CmdCancel.top = ht + 120
      Ques.cmdPrint.top = ht + 120         '12Aug97 CKJ
   End If

   If Me.Width < 1200 Then Exit Sub

   Background.Visible = False
   ScrollBar.Visible = False

   ' Undo any prior scrolling
   Background.top = 0

   ' Make the height of the picture control as large as possible
   ' so that control array elements which were not originally
   ' visible will be scrolled into view
   Background.Height = BACKHEIGHT

   ' Assume no scroll bar initially
   NeedScroll% = False

   ' If a scroll bar is needed, move it to the far right of the
   ' form and adjust the size of the picture control accordingly

   If ScrollBarNeeded(Me) Then
      ScrollBar.top = F3D1.top + 90
      ScrollBar.Left = Me.Width - ScrollBar.Width - 2 * 120 '#
      ScrollBar.Height = F3D1.Height - 90
      ScrollBar.Value = 1
      ScrollBar.min = 1
      ScrollBar.Max = ScrollBarMax()
      ScrollBar.LargeChange = (F3D1.Height - 240) / Delta   '12Aug97 CKJ Added for PgUp PgDn
      NeedScroll% = True
      Ques.F3D1.Width = ScrollBar.Left - F3D1.Left - 120

      'Otherwise, extend the picture control to the end of the form
   Else
      Ques.F3D1.Width = Me.ScaleWidth - F3D1.Left - 120
   End If
   
   Background.Width = F3D1.Width - 2 * Background.Left

   ' Make the controls visible, if required

   ScrollBar.Visible = NeedScroll%
   Background.Visible = True

   ' Give the first input control focus

   On Error Resume Next
   txtQ(1).SetFocus
   cmdQ(1).SetFocus
   lst1(1).SetFocus
   On Error GoTo 0

End Sub

Private Sub lst1_GotFocus(index As Integer)

   CtrlSetFocus index

End Sub

Private Sub lst1_LostFocus(index As Integer)

   Ques_Callback index

End Sub

Private Sub Timer1_Timer()

   If TimedOut() Then cmdCancel_Click

End Sub

Private Sub ScrollBar_Change()
' Scroll the label and text controls by moving the background picture control

   Background.top = -Delta * (ScrollBar.Value - 1)   '#

End Sub

Private Sub ScrollBar_KeyDown(KeyCode As Integer, Shift As Integer)
   
   If Shift = 0 Then
      Select Case KeyCode  'L 37 R 39 U 38 D 40
         Case KEY_LEFT
            KeyCode = 0           '12Aug97 CKJ added
            SendKeys "{Tab}"
         End Select
   End If

End Sub

Private Function ScrollBarMax() As Integer
'Return the maximum value for the scroll bar (at least 2)

Dim n%

   n = Val(F3D1.Tag) - (F3D1.Height - 240) / Delta + 1

   If n > 1 Then
      ScrollBarMax = n
   Else
      ScrollBarMax = 2
   End If

End Function

Private Function ScrollBarNeeded(This As Form) As Integer
' Return FALSE if all controls fit on the form, TRUE otherwise

Dim i As Integer
    
   i = Val(F3D1.Tag) + 1

   If Delta * i > F3D1.Height Then
      ScrollBarNeeded = True
   Else
      ScrollBarNeeded = False
   End If

End Function

Private Sub TabNext(index%, NextOne%)
'!!** Does not check that last entry is visible

   If NextOne Then
      If index < Val(F3D1.Tag) Then SendKeys "{Tab}"
   Else
      If index > 1 Then SendKeys "+{Tab}"
   End If
   
   Me.Refresh                '12Aug97 CKJ added

End Sub

Private Sub txtQ_GotFocus(index As Integer)
'Uses MicroHelp Masked Input control (MhMI)
'15Jun05 CKJ now uses plain TextBox

   CtrlSetFocus index

   txtQ(index).SelStart = 0
   txtQ(index).SelLength = Len(txtQ(index))
            
End Sub

Private Sub txtQ_KeyDown(index As Integer, KeyCode As Integer, Shift As Integer)
'16Jun05 CKJ Basic mask chacks added

   Select Case Shift
      Case 0
         Select Case KeyCode  'L 37 R 39 U 38 D 40
            Case 38: TabNext index, False
            Case 40: TabNext index, True
            Case KEY_PgUp     '!! needed but too complex just now
               'MsgBox Str$(ScrollBarMax())
               'ScrollBar.Value = ScrollBar.Value - ScrollBar.LargeChange
            Case KEY_PgDn     '!!
               'ScrollBar.Value = ScrollBar.Value + 5' ScrollBar.LargeChange
            End Select
      
      Case vbShiftMask
         Select Case KeyCode                 'Shift-Insert
            Case vbKeyInsert                 'check if insert allowed
               If Not ClipboardValidForPaste(txtQ(index)) Then KeyCode = 0
            End Select
      
      Case vbCtrlMask
         Select Case KeyCode                 'Ctrl-V
            Case vbKeyV                      'check if insert allowed
               If Not ClipboardValidForPaste(txtQ(index)) Then KeyCode = 0
            End Select
            
      End Select

End Sub

Private Sub txtQ_KeyPress(index As Integer, Keyascii As Integer)
'15Jun05 CKJ Basic mask added now that a plain textbox is used
'            NB: does NOT yet prevent pasting of invalid characters
   
Dim masktext As String
Dim maskcase As String
Dim masktype As String
Dim LeftText As String
Dim PartText As String

   With txtQ(index)
      masktype = Left$(.Tag, 2)      'XX.........
      maskcase = Mid$(.Tag, 3, 1)    '..X........
      masktext = Mid$(.Tag, 4)       '...XXXXXXXX
   
      LeftText = Left$(.text, .SelStart)                                            'xxXXXyyyy' => 'xx'
      PartText = Left$(.text, .SelStart) & Mid$(.text, 1 + .SelStart + .SelLength)  'xxXXXyyyy' => 'xxyyyy'
   End With
   
   If maskcase = "^" Then                             'force uppercase '10Oct05 TH Moved from below
      Select Case Keyascii
         Case 97 To 122: Keyascii = Keyascii - 32
         End Select
   End If
      
   Select Case Keyascii
      Case vbKeyBack, vbKeyReturn
         'allow through
      Case Else
         Select Case masktype
            Case "01", "02"
               If InStr(masktext, Chr$(Keyascii)) = 0 Then        'key not in list allowed
                  Keyascii = 0
               ElseIf masktype = "01" Then                        'numeric mask
                  If InStr(masktext, ".") Then                    'decimal point allowed
                     If Keyascii = Asc(".") Then                  'decimal point key pressed
                        If InStr(PartText, ".") Then              'but we've already got one (not in highlight)
                           Keyascii = 0
                        End If
                     End If
                  End If
                  
                  If InStr(masktext, "-") Then                    'minus sign allowed
                     If Keyascii = Asc("-") Then                  'minus key pressed
                        If InStr(PartText, "-") Then              'already got a minus sign (not in highlight)
                           Keyascii = 0
                        ElseIf Len(LeftText) Then                 'already got digits or '-' to left of cursor
                           Keyascii = 0
                        End If
                     End If
                  End If
      
               End If
            End Select
      End Select
   
''   If maskcase = "^" Then                             'force uppercase
''      Select Case Keyascii
''         Case 97 To 122: Keyascii = Keyascii - 32
''         End Select
''   End If

End Sub

Private Sub txtQ_KeyUp(index As Integer, KeyCode As Integer, Shift As Integer)
' 5Nov96 CKJ Added Shift F1 facility to text box - does callback with negative Index

   If Shift = 1 And KeyCode = KEY_F1 Then
      KeyCode = 0                      '12Aug97 CKJ
      Shift = 0
      Ques_Callback -index
   End If
   
End Sub

Private Sub txtQ_LostFocus(index As Integer)

   Ques_Callback index

End Sub

Private Sub txtQ_MouseDown(index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)
'Need to trap paste by mouse & drag/drop

   'Stop !!**
   
End Sub

Private Sub txtQ_MouseUp(index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)
'Need to trap paste by mouse & drag/drop

   'Stop !!**
   
End Sub

Private Function ClipboardValidForPaste(ctlTextbox As TextBox) As Boolean
'NB Does not force upper case here - needs to be checked later

Dim ClipboardText As String
Dim IsValid As Boolean
Dim iLoop As Integer
Dim char As String

Dim masktext As String
Dim maskcase As String
Dim masktype As String
Dim LeftText As String
Dim PartText As String

   IsValid = True
   ClipboardText = Clipboard.GetText
   
   With ctlTextbox
      masktype = Left$(.Tag, 2)      'XX.........
      maskcase = Mid$(.Tag, 3, 1)    '..X........
      masktext = Mid$(.Tag, 4)       '...XXXXXXXX
   
      LeftText = Left$(.text, .SelStart)                                            'xxXXXyyyy' => 'xx'
      PartText = Left$(.text, .SelStart) & Mid$(.text, 1 + .SelStart + .SelLength)  'xxXXXyyyy' => 'xxyyyy'
   End With
      
   Select Case masktype
      Case "01", "02"
         For iLoop = 1 To Len(ClipboardText)
            char = Mid$(ClipboardText, iLoop, 1)               'check each character individually
            
            If InStr(masktext, char) = 0 Then                  'char not in list allowed
               IsValid = False
               Exit For
            End If
         
            If masktype = "01" Then                            'numeric mask
               If InStr(masktext, ".") Then                    'decimal point allowed
                  If char = "." Then                           'decimal point key pressed
                     If InStr(PartText, ".") Then              'but we've already got one (not in highlight)
                        IsValid = False
                        Exit For
                     End If
                  End If
               End If
               
               If InStr(masktext, "-") Then                    'minus sign allowed
                  If char = "-" Then                           'minus key pressed
                     If InStr(PartText, "-") Then              'already got a minus sign (not in highlight)
                        IsValid = False
                        Exit For
                     ElseIf Len(LeftText) Then                 'already got digits or '-' to left of cursor
                        IsValid = False
                        Exit For
                     End If
                  End If
               End If
            End If
            
            LeftText = LeftText & char                         'imagine character pasted to left, now consider next one
         Next
      
      End Select
      
   ClipboardValidForPaste = IsValid
   
End Function
