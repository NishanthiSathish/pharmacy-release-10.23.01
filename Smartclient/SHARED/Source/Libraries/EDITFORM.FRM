VERSION 5.00
Begin VB.Form Editor 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   ClientHeight    =   5565
   ClientLeft      =   525
   ClientTop       =   990
   ClientWidth     =   9540
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   8.25
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H00000000&
   Icon            =   "EDITFORM.frx":0000
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5565
   ScaleWidth      =   9540
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Left            =   8880
      Top             =   4560
   End
   Begin VB.CommandButton cmdBtn 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      Caption         =   "&Print"
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
      Index           =   1
      Left            =   5220
      Style           =   1  'Graphical
      TabIndex        =   7
      Top             =   5130
      Width           =   1320
   End
   Begin VB.Frame Frame1 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      ForeColor       =   &H00000000&
      Height          =   480
      Left            =   60
      TabIndex        =   4
      Top             =   5040
      Visible         =   0   'False
      Width           =   5055
      Begin VB.Label lblCode 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H00808000&
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
         ForeColor       =   &H00000000&
         Height          =   195
         Left            =   120
         TabIndex        =   5
         Top             =   180
         Width           =   45
      End
   End
   Begin VB.TextBox Txt1 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      ForeColor       =   &H00000000&
      Height          =   2775
      Left            =   960
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Top             =   1020
      Visible         =   0   'False
      Width           =   7635
   End
   Begin VB.CommandButton cmdExit 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      Cancel          =   -1  'True
      Caption         =   "E&xit [Esc]"
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
      Left            =   8100
      Style           =   1  'Graphical
      TabIndex        =   1
      Top             =   5130
      Width           =   1320
   End
   Begin VB.CommandButton cmdBtn 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      Caption         =   "&Help"
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
      Left            =   6660
      Style           =   1  'Graphical
      TabIndex        =   2
      Top             =   5130
      Width           =   1320
   End
   Begin VB.Label Label1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "....:....1....:....2....:....3....:....4....:....5....:....6"
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   1020
      TabIndex        =   6
      Top             =   780
      Visible         =   0   'False
      Width           =   7575
   End
   Begin VB.Label lblTitle 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00808080&
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
      ForeColor       =   &H00000000&
      Height          =   495
      Left            =   45
      TabIndex        =   3
      Top             =   210
      Width           =   9420
   End
End
Attribute VB_Name = "Editor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------------------------------------------------------------
'                                Editor Form
'
'  Provide routines for displaying and editing data as per Notepad.
'  Includes cut & paste, full help and predefined function keys.
'
'12Mar95 CKJ Written
'?????95 ASC Added label facilities & printing
'20Jun95 CKJ Doesn't now ask OK to exit if view only
'            Print command disabled unless needed
'20Jul95 CKJ Limit free format labels to 10 lines
'22Nov95 CKJ Print facility removed. If required then link with EditFrmP.frm
'            which retains this capability.
'            Does not need a copy of the text in the tag when view only.
' 4Sep96 CKJ Mods made for windows
'            Since size is now a function of font etc. not lines/columns, the
'            text box is sized for our labels by setting Editor.tag non null
'            for 10 lines & 60 columns, or leave blank for max size.
'            The fullpage and print buttons now removed.
'            The ini file has been changed to EditorsW.INI, since line graphics
'            from DOS won't work in most fonts in Windows.
'28Nov96 CKJ Form_Resize: Changed labelling font from MS Linedraw, size to 9.75
' 7Mar97 CKJ Added Timeout
'17Mar98 CKJ Replaced popmessage with sendkeys. Added print button
'             Labels are printed with context FFlabel using FFlabels.rtf,
'             others with context SysMaint using StdPrint.rtf
'13Jun98 ASC removed dim k
'26Nov98 CFY cmdBtn_Click: Can now print to both standard printer or label printer. If printing
'            to a label printer the output is wrapped using the vernier calipers.
'            Label output requires the file 'blanklbl.rtf' to be present.
'24Feb99 SF  Txt1_KeyPress: Limit number of lines to number in GetNumEditorLines%()
'11Mar99 CFY Changed to use Windows colours
'30Mar04 CKJ Txt1_KeyUp: PopFreeMem has been a dummy proc for ages, so removed it {SP1}
'09May05 CKJ replaced mhtimer with timer
'23Jul12 CKJ Increased height of lblTitle to allow two lines          TFS37640
'-----------------------------------------------------------------------------
' Use the following procedure in the calling program
'-----------------------------------------------------------------------------
'DEFINT A-Z
'SUB TextEdit (title$, body$, code$, label%, change%)
'12Mar95 CKJ Written
'  Title$ - top line of screen
'  Body$  - main body text, up to 32K max
'           individual lines are <cr><lf> separated
'  Code$  - Fixed message box at lower left of screen (optional)
'  Label  - True for 10 line fixed box, false for full page editor
'           NB font changes too, monospaced for label else proportional
'  Change - On entry: False for view only;  Returns false on exit
'                     True  allows editing; Returns true if altered
'
'   Editor.txt1.text = body$
'   Editor.lblCode.caption = code$
'   Editor.lblTitle.caption = title$
'   Editor.Tag = iif(label,"10","")      'set label size or full screeen
'   IF change = 0 THEN                   'view only
'         Editor.cmdExit.default = true
'      ELSE                              'editable
'         Editor.txt1.tag = body$
'      END IF
'   CentreForm Editor
'   Editor.SHOW 1
'   change = VAL(Editor.cmdExit.tag)
'   if change then body$ = Editor.txt1.text
'   UNLOAD Editor
'END SUB
'-----------------------------------------------------------------------------
Option Explicit
DefInt A-Z

Dim Keystroke%
Dim lines$()

Private Sub cmdBtn_Click(Index As Integer)
'17Mar98 CKJ Replaced popmessage with sendkeys. Added print
'26Nov98 CFY Can now print to both standard printer or label printer. If printing
'            to a label printer the output is wrapped using the vernier calipers.
'            Label output requires the file 'blanklbl.rtf' to be present.
Dim tmp$
Dim result$
Dim FontNumber%, LinesAcheived%, TextOut$, i%, numoflines%

   Select Case Index
      Case 0
         SendKeys "{f1}"
      Case 1
         If Me.Tag = "" Then   ' Full page editor/viewer
               frmoptionset -1, "Choose Destination"
               frmoptionset 1, "Label Printer"
               frmoptionset 1, "Standard Printer"
               frmoptionshow "1", result$
               frmoptionset 0, ""
               If Not k.escd Then
                     TextOut$ = Txt1.text
                     Select Case Val(result$)
                        Case 1:
                           FormatLabel Txt1.text, 0, 36, FontNumber%, LinesAcheived%, TextOut$, False '04Aug14 TH Added param
                           replace TextOut$, cr, " \par ", 0
                           Heap 10, gPRNheapID, "LblText", TextOut$, 0
                           'ParseThenPrint "DispLabel", dispdata$ & "\blanklbl.rtf", 1, 0
                           'ParseThenPrint "DispLabel", dispdata$ & "\blanklbl.rtf", 1, 0, False  '27May11 TH Added param (F0088129)
                           ParseThenPrint "DispLabel", dispdata$ & "\blanklbl.rtf", 1, 0, False, False '04Jan17 TH Use the DB template
                        Case 2:
                           tmp$ = Txt1.text
                           replace tmp$, cr, "[cr]", 0
                           replace tmp$, lf, "", 0
                           replace tmp$, TB, "[Tab]", 0
                           Heap 10, gPRNheapID, "InternalText", tmp$, 0
                           Heap 10, gPRNheapID, "InternalTitle", (Me.Caption), 0
                           Heap 10, gPRNheapID, "InternalHeading", lblCode & "[cr]", 0
                           Heap 10, gPRNheapID, "InternalHeader", "", 0
                           Heap 10, gPRNheapID, "InternalFooter", "", 0
                           'ParseThenPrint "SysMaint", dispdata$ & "\stdprint.rtf", 1, 0
                           'ParseThenPrint "SysMaint", dispdata$ & "\stdprint.rtf", 1, 0, False  '27May11 TH Added param (F0088129)
                           ParseThenPrint "SysMaint", dispdata$ & "\stdprint.rtf", 1, 0, False, False '04Jan17 TH Use the DB template
                     End Select
                  End If
            Else               ' Just for labels
               printlabels (Txt1.text), 1
            End If
      End Select
   
   Txt1.SetFocus

End Sub

Private Sub cmdExit_Click()

Dim done%

   cmdExit.Tag = "0"
   done = True

   '20Jun95 CKJ Changed order of questions
   If cmdExit.default = False Then                            ' not view only
         If Txt1.Tag <> Txt1.text Then                        ' edited
               Select Case MessageBox("OK to save changes?", 3 + MB_ICONQUESTION, "Exit")
                  Case 6:    cmdExit.Tag = "-1"               ' yes
                  Case 7:    Txt1.text = Txt1.Tag             ' no
                  Case Else: done = False
                  End Select
            End If
      End If

   If done Then
         TimeoutOff Timer1
         Editor.Hide
      Else
         Txt1.SetFocus
      End If

End Sub

Private Sub Form_Activate()

   TimeoutOn Timer1
   On Error Resume Next
   Txt1.SetFocus
   On Error GoTo 0

End Sub

Private Sub Form_Deactivate()

   TimeoutOff Timer1

End Sub

Private Sub Form_Load()

   SetChrome Me
   
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then
         Cancel = True
         cmdExit_Click
      End If

End Sub

Private Sub Form_Resize()
'28Nov96 CKJ Changed labelling font from MS Linedraw

Dim posn%
   
   TimeoutOn Timer1
   If Me.Tag = "" Then   ' Full page editor/viewer
         Txt1.Top = 60
         Txt1.Left = 60
         If Me.ScaleWidth > 120 Then Txt1.Width = ScaleWidth - 120
         If Me.ScaleHeight > 600 Then Txt1.Height = ScaleHeight - 600
         posn = ScaleHeight - 440
         cmdExit.Top = posn
         cmdBtn(0).Top = posn
         cmdBtn(1).Top = posn
         Frame1.Top = posn - 100
      Else               ' Just for labels
         On Error Resume Next
         With Txt1
            .FontName = "Courier New"
            .FontBold = False
            .FontSize = 9.75
         End With
         With Label1
            .Visible = True
            .FontName = "Courier New"     '18Nov05 CKJ added .fontxxxx to counteract SetChrome
            .FontBold = False
            .FontSize = 9.75
         End With
         On Error GoTo 0
      End If
      
   Txt1.Visible = True

End Sub

Private Sub lblCode_Change()

Dim lencode%, framewidth%

   TimeoutOn Timer1
   lencode = Len(lblCode.Caption)
   If lencode Then
         Frame1.Visible = True
         framewidth% = txtwidth(lblCode, (lblCode.Caption)) + 240
         If framewidth% < Frame1.Width Then Frame1.Width = framewidth%
         If framewidth% <= 240 Then Frame1.Visible = False
      Else
         Frame1.Visible = False
      End If
   
End Sub

Private Sub Timer1_Timer()

   If TimedOut() Then cmdExit_Click

End Sub

Private Sub Txt1_Change()
'17Mar98 CKJ Added

   cmdBtn(1).Enabled = (Len(Txt1.text) > 0)

End Sub

Private Sub Txt1_KeyDown(KeyCode As Integer, Shift As Integer)

   TimeoutOn Timer1
   Keystroke = 0
   If cmdExit.default And Shift = SHIFT_MASK Then    'view only...
         If KeyCode = 45 Then KeyCode = 0            'shift INS pressed = Paste
         If KeyCode = 46 Then KeyCode = 0            'shift DEL pressed = Cut
      End If

End Sub

Private Sub Txt1_KeyPress(KeyAscii As Integer)
'20Jul95 CKJ Limit free format labels to 10 lines
'24Feb99 SF  Limit number of lines to number in GetNumEditorLines%()

Dim numCRs%, CRposn%

   Keystroke = KeyAscii
   If cmdExit.default Then KeyAscii = 0       'view only
   If KeyAscii = 34 Then Beep: KeyAscii = 39  'double quotes -> single quotes
   If KeyAscii = 13 And Me.Tag <> "" And Txt1.text <> "" Then 'return key on FF label
         numCRs = 0
         CRposn = 0
         Do
            CRposn = InStr(CRposn + 1, Txt1.text, Chr$(13))
            If CRposn Then numCRs = numCRs + 1
         Loop While CRposn
         
         If numCRs >= (GetNumEditorLines%() - 1) Then
               popmessagecr "#Label Editor", "Maximum of " & GetNumEditorLines%() & " lines allowed"
               KeyAscii = 0
            End If
      End If

End Sub

Private Sub Txt1_KeyUp(KeyCode As Integer, Shift As Integer)

Dim found%, header$

   If Keystroke = 0 Then
         Select Case KeyCode
            Case KEY_F2 To KEY_F12  '113 To 123 = F2 to F12  plain, shift, ctrl, alt, etc
               If cmdExit.default = False Then    'not view only
                     header$ = TxtD(dispdata$ + "\editorsw.ini", "", "", "Shift" + LTrim$(Str$(Shift)), found)
                     Txt1.SelText = TxtD(dispdata$ + "\editorsw.ini", "", "", header$ + LTrim$(Str$(KeyCode - 111)), found)
                  End If
            End Select
      End If
   If cmdExit.default Then KeyCode = 0       'view only

End Sub

