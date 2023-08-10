VERSION 5.00
Begin VB.Form KeyPad 
   Appearance      =   0  'Flat
   AutoRedraw      =   -1  'True
   BackColor       =   &H8000000A&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Dose Entry"
   ClientHeight    =   3360
   ClientLeft      =   3915
   ClientTop       =   3765
   ClientWidth     =   2475
   ControlBox      =   0   'False
   ForeColor       =   &H00000000&
   Icon            =   "WKEYDOSE.frx":0000
   KeyPreview      =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3360
   ScaleWidth      =   2475
   Tag             =   "2565"
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
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
      Height          =   6900
      Left            =   0
      ScaleHeight     =   6900
      ScaleWidth      =   2445
      TabIndex        =   20
      Top             =   0
      Visible         =   0   'False
      Width           =   2445
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "."
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   500
         Index           =   10
         Left            =   1125
         Style           =   1  'Graphical
         TabIndex        =   3
         Top             =   2205
         Width           =   500
      End
      Begin VB.CommandButton cmdDelete 
         Caption         =   "Del"
         Height          =   315
         Left            =   1920
         Style           =   1  'Graphical
         TabIndex        =   18
         Top             =   120
         Width           =   495
      End
      Begin VB.TextBox LCD 
         Appearance      =   0  'Flat
         Height          =   285
         Left            =   135
         TabIndex        =   0
         Top             =   135
         Width           =   1230
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "&BNF"
         Enabled         =   0   'False
         Height          =   400
         Index           =   21
         Left            =   1800
         Style           =   1  'Graphical
         TabIndex        =   16
         Top             =   1260
         Visible         =   0   'False
         Width           =   500
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "&Info"
         Enabled         =   0   'False
         Height          =   400
         Index           =   13
         Left            =   1800
         Style           =   1  'Graphical
         TabIndex        =   17
         Top             =   765
         Visible         =   0   'False
         Width           =   500
      End
      Begin VB.CommandButton xcmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "/&Kg"
         Enabled         =   0   'False
         Height          =   400
         Index           =   20
         Left            =   1800
         Style           =   1  'Graphical
         TabIndex        =   15
         Top             =   1755
         Visible         =   0   'False
         Width           =   500
      End
      Begin VB.CommandButton xcmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "/&m²"
         Enabled         =   0   'False
         Height          =   400
         Index           =   19
         Left            =   1800
         Style           =   1  'Graphical
         TabIndex        =   14
         Top             =   2250
         Visible         =   0   'False
         Width           =   500
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "&OK"
         Default         =   -1  'True
         Height          =   405
         Index           =   14
         Left            =   360
         Style           =   1  'Graphical
         TabIndex        =   1
         Top             =   2835
         Width           =   675
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Cancel          =   -1  'True
         Caption         =   "&Cancel"
         Height          =   405
         Index           =   11
         Left            =   1440
         Style           =   1  'Graphical
         TabIndex        =   2
         Top             =   2835
         Width           =   675
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "7"
         Height          =   500
         Index           =   7
         Left            =   135
         Style           =   1  'Graphical
         TabIndex        =   11
         Top             =   720
         Width           =   500
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "8"
         Height          =   500
         Index           =   8
         Left            =   630
         Style           =   1  'Graphical
         TabIndex        =   12
         Top             =   720
         Width           =   500
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "9"
         Height          =   500
         Index           =   9
         Left            =   1125
         Style           =   1  'Graphical
         TabIndex        =   13
         Top             =   720
         Width           =   500
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "5"
         Height          =   500
         Index           =   5
         Left            =   630
         Style           =   1  'Graphical
         TabIndex        =   9
         Top             =   1215
         Width           =   500
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "4"
         Height          =   500
         Index           =   4
         Left            =   135
         Style           =   1  'Graphical
         TabIndex        =   8
         Top             =   1215
         Width           =   500
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "1"
         Height          =   500
         Index           =   1
         Left            =   135
         Style           =   1  'Graphical
         TabIndex        =   5
         Top             =   1710
         Width           =   500
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "2"
         Height          =   500
         Index           =   2
         Left            =   630
         Style           =   1  'Graphical
         TabIndex        =   6
         Top             =   1710
         Width           =   500
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "3"
         Height          =   500
         Index           =   3
         Left            =   1125
         Style           =   1  'Graphical
         TabIndex        =   7
         Top             =   1710
         Width           =   500
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "6"
         Height          =   500
         Index           =   6
         Left            =   1125
         Style           =   1  'Graphical
         TabIndex        =   10
         Top             =   1215
         Width           =   500
      End
      Begin VB.CommandButton cmdBtn 
         Appearance      =   0  'Flat
         Caption         =   "0"
         Height          =   500
         Index           =   0
         Left            =   135
         Style           =   1  'Graphical
         TabIndex        =   4
         Top             =   2205
         Width           =   990
      End
      Begin VB.Label LblUnits 
         Appearance      =   0  'Flat
         BackColor       =   &H00FF0000&
         BackStyle       =   0  'Transparent
         ForeColor       =   &H00000000&
         Height          =   240
         Left            =   1395
         TabIndex        =   19
         Top             =   180
         Width           =   480
      End
   End
End
Attribute VB_Name = "KeyPad"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'------------------------------------------------------------------------
' WKEYDOSE.FRM   Numeric KeyPad for ASCribe
'
'02Nov95 CKJ written
' To preset a number in the display, set
'   KeyPad.LCD.text="1234.5"
'
' Answer is returned in the label
'   KeyPad.LCD.text
' If answer is valid (ie Enter pressed, not Esc or Close)
'   KeyPad.tag = "-1"
' otherwise is is set to ""
'
' The form is hidden on completion but not unloaded unless
' the user choses Alt-F4
'30Nov95     Adapted for use as a dose entry form
'16Dec96 ASC delete tool added for keyboard-less use
'11Jun97 KR  Added screenrefresh in form unload event.
'11Mar98 CKJ Local Formulary was set as default help file, but never removed
'            Now uses '\dispdata.xxx\frmulary.hlp' instead of BM2.hlp if the file exists
'            and sets it back to the default afterwards.
'            ShowInfo now trims desc$ & uses standard call
'14Oct98 CKJ Squared symbol from country.044
'04Mar99 CFY Changed to use Windows colours
'23Oct01 CKJ Removed proc ShowHelp as it was not visible & did not work
'            Removed button 12 which was associated with ShowHelp
'            Removed buttons 15 (Back), 16 (Del), 17 (Enter) & 18 (Command1)
'            which weren't visible & had no action, but had hotkeys & tabstops
'30Oct01 CKJ Added option for 2 or 3 lines of prompt text attached to picture1.tag
'07Nov01 CKJ Set back colour to Windows default
'19Mar02 TH  Added modular bolean to retain picturebox on form when modal message fires (#59667)
'            Form_Deactivate: Read flag to maintain picturebox if just launching modal message (#59667)
'            Form_Load: Explicitly set new flag (#59667)
'            LCD_KeyPress: Added code to only allow numerical entry on dose entry (if tagged as dose entry) (#59667)
'05apr02 CKJ LCD_KeyPress: Corrected spelling error
'            Allow '.' when it is highlighted as replace will be invoked
'            EntryValidated: written. Traps invalid chars, max length and duplicate decimal points
'            LCD_Change: written
'            CmdBtn_Keypress: added validation check
'            Corrected button spacing and tab order

'Mods wanted:
'/Restrict length when typed as well as with the keypad
' Prevent the {cr} if Cancel selected
'------------------------------------------------------------------------
Option Explicit
DefInt A-Z
Dim blnKeepPicture As Integer   '19Mar02 TH Added (#59667)

Private Sub cmdBtn_Click(index As Integer)

   Select Case index
      Case 0 To 9:  CmdBtn_Keypress index, index + 48
      Case 10:      CmdBtn_Keypress index, Asc(".")
      Case Is > 10: CmdBtn_Keypress index, -1 * index
      End Select

End Sub

Private Sub CmdBtn_Keypress(index As Integer, KeyAscii As Integer)
'05Apr02 CKJ added validation check

Dim dose$

   Select Case KeyAscii
      Case 48 To 57: If Len(LCD.Text) < 12 Then LCD.Text = LCD.Text + Chr$(KeyAscii)
      Case 46:       If InStr(LCD.Text, ".") = 0 Then LCD.Text = LCD.Text + "."
      Case -11, 27:  Me.Hide
      Case 8:        If Len(LCD.Text) Then LCD.Text = Left$(LCD.Text, Len(LCD.Text) - 1)
      Case -13:      ShowInfo
      'Case -14, 13:  Me.Tag = "-1": Me.Hide                    '05Apr02 CKJ removed
      Case -14, 13                                              '   "        added validation check
         If EntryValidated() Then
               Me.Tag = "-1"
               Me.Hide
            Else
               LCD.Text = ""
            End If
''      Case -20:      dose$ = LCD.Text: DoseFromKg dose$: LCD.Text = dose$
''      Case -19:      dose$ = LCD.Text: DoseFromMsq dose$: LCD.Text = dose$
      Case -21:      LoadBNF      '28sep96 ASC starts BNF at correct drug (nearly)
      End Select

   KeyAscii = 0

   On Error Resume Next           '23Oct01 CKJ added
   LCD.SetFocus
   LCD.SelStart = 32767
   On Error GoTo 0

End Sub

Private Sub cmdBtn_KeyUp(index As Integer, KeyCode As Integer, Shift As Integer)

   cmdBtn(14).default = True

End Sub

Private Sub CmdDelete_Click()

   LCD.Text = ""
   LCD.SetFocus

End Sub

Private Function EntryValidated() As Integer
'05Apr02 CKJ Written
'            Trap max length and when in numeric entry trap invalid chars & duplicate decimal points
'            NB: Specifically handles positive reals only, but could be extended.

Dim strMsg As String
Dim blnValid As Integer
Dim strChr As String
Dim intPosn As Integer
   
   strMsg = ""
   If Len(LCD.Text) > 12 Then
         strMsg = "is too long" & crlf & "Please enter no more than twelve characters"
      ElseIf LCD.Tag = "1." Then                            'digits and . only
         intPosn = InStr(LCD.Text, ".")
         intPosn = InStr(intPosn + 1, LCD.Text, ".")
         If intPosn Then                                    'more than one '.'
               strMsg = "has more than one decimal point" & crlf & "Please enter a valid number"
            Else
               For intPosn = 1 To Len(LCD.Text)
                  Select Case Mid$(LCD.Text, intPosn, 1)
                     Case "0" To "9", "."                   'no action
                     Case Else
                        strMsg = "is not a valid number" & crlf & "Please enter a valid number"
                        Exit For
                     End Select
               Next
         End If
      End If

   If Len(strMsg) Then
         Beep
         blnKeepPicture = True
         popmessagecr "!Invalid Entry", "'" & LCD.Text & "' " & strMsg
         blnKeepPicture = False
         On Error Resume Next
         LCD.SetFocus
         On Error GoTo 0
         EntryValidated = False
      Else
         EntryValidated = True
      End If

End Function

Private Sub Form_Activate()
'30Oct01 CKJ Added option for 2 or 3 lines of prompt text attached to picture1.tag

   If Len(Picture1.Tag) Then                           '30Oct01 CKJ Added
         Me.Print Picture1.Tag
         Picture1.Tag = ""
         Picture1.top = 800
         Me.Height = Me.Height + 800
      End If
   
   App.HelpFile = cmdBtn(1).Tag
   Picture1.Visible = True
   Me.Refresh

End Sub

Private Sub Form_Deactivate()
   
   'picture1.Visible = False                             '18Mar02 TH Added flag to keep picturebox visible when displaying
   If Not blnKeepPicture Then Picture1.Visible = False   '           Modal messages (#59667)
   App.HelpFile = cmdBtn(0).Tag

End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)

   If KeyCode = KEY_F4 Then
         SendKeys "{BS}"
      End If

End Sub

Private Sub Form_Load()
'14Oct98 CKJ Squared symbol from country.044

   'CmdBtn(11).Cancel = true       'exit
   'CmdBtn(14).default = true      'enter
   Me.Tag = ""
   
   'app.HelpFile = dispdata$ & "\bm2.hlp"              '11Mar98 CKJ replaced
   cmdBtn(0).Tag = App.HelpFile
   cmdBtn(1).Tag = App.HelpFile
   If fileexists(dispdata$ & "\Frmulary.hlp") Then
         cmdBtn(1).Tag = dispdata$ & "\Frmulary.hlp"
      End If

''   cmdBtn(19).Caption = "/&m" & TxtD("country", "", "²", "Squared", 0) '14Oct98 CKJ
   
   blnKeepPicture = False  '18Mar02 TH Explicitly set new flag  (#59667)
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
'11Mar98 CKJ written

   If UnloadMode <> 1 Then
         Cancel = True
         Me.Hide
      End If

End Sub

Private Sub Form_Unload(Cancel As Integer)

   ScreenRefresh        '11June97 KR Added

End Sub

Private Sub LCD_Change()
'05Apr02 CKJ written
   
   If Not EntryValidated() Then
         LCD.Text = ""
      End If

End Sub

Private Sub LCD_KeyPress(KeyAscii As Integer)
'15Mar02 TH  Added code to only allow numerical entry on dose entry (#59667)
'05apr02 CKJ Corrected spelling error
'            Allow '.' when it is highlighted as replace will be invoked

Dim strChr As String
Dim blnValid As Integer
Dim strMsg As String

   blnValid = True
   If LCD.Tag = "1." Then                                                  'digits and . only
         Select Case KeyAscii
            Case 8, 48 To 57                                               'Backspace and '0' to '9' allowed
               'no action
            Case 46                                                        '.' present in the text but not highlighted
               If InStr(LCD.Text, ".") > 0 And InStr(LCD.SelText, ".") = 0 Then
                     blnValid = False
                     strMsg = "Decimal point already present."
                  End If
            Case Else
               blnValid = False
               strMsg = "Please enter a number."
            End Select
      End If

   If Not blnValid Then
         KeyAscii = 0
         Beep
         blnKeepPicture = True
         popmessagecr "!", "Invalid key pressed." & crlf & strMsg
         blnKeepPicture = False
      End If
               
End Sub

