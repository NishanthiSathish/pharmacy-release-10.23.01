VERSION 5.00
Begin VB.Form frmExtraLabel 
   Caption         =   "Extended Label Details"
   ClientHeight    =   7185
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4965
   LinkTopic       =   "Form1"
   ScaleHeight     =   7185
   ScaleWidth      =   4965
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton cmdCancel 
      Caption         =   "&Cancel"
      Height          =   375
      Left            =   3480
      TabIndex        =   18
      Top             =   6480
      Width           =   1215
   End
   Begin VB.CommandButton cmbOK 
      Caption         =   "&OK"
      Height          =   375
      Left            =   1800
      TabIndex        =   17
      Top             =   6480
      Width           =   1335
   End
   Begin VB.Frame fraLabel 
      Height          =   4635
      Left            =   240
      TabIndex        =   0
      Top             =   960
      Width           =   4515
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   15
         Left            =   60
         TabIndex        =   16
         Top             =   4185
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   14
         Left            =   60
         TabIndex        =   15
         Top             =   3900
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   13
         Left            =   60
         TabIndex        =   14
         Top             =   3620
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   12
         Left            =   60
         TabIndex        =   13
         Top             =   3330
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   11
         Left            =   60
         TabIndex        =   12
         Top             =   3060
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   10
         Left            =   60
         TabIndex        =   11
         Top             =   2810
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   0
         Left            =   60
         TabIndex        =   10
         Top             =   125
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   1
         Left            =   60
         TabIndex        =   9
         Top             =   380
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   7
         Left            =   60
         TabIndex        =   8
         Top             =   2000
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   8
         Left            =   60
         TabIndex        =   7
         Top             =   2270
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   3
         Left            =   60
         TabIndex        =   6
         Top             =   920
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   2
         Left            =   60
         TabIndex        =   5
         Top             =   650
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   6
         Left            =   60
         TabIndex        =   4
         Top             =   1730
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   5
         Left            =   60
         TabIndex        =   3
         Top             =   1460
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   4
         Left            =   60
         TabIndex        =   2
         Top             =   1190
         Width           =   4380
      End
      Begin VB.TextBox TxtLabel 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   9
         Left            =   60
         TabIndex        =   1
         Top             =   2520
         Width           =   4380
      End
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      Caption         =   "Two labels will be printed as direction text is too long to fit onto a single label"
      Height          =   495
      Left            =   960
      TabIndex        =   19
      Top             =   240
      Width           =   3015
   End
End
Attribute VB_Name = "frmExtraLabel"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmbOK_Click()
Dim ans$, temp$
Dim tempval As Integer
'Set te flag and store

'ASk and question

setLabelExtraLabelFlag True

For intloop = 0 To 15 '05Aug14 TH

   ans$ = TxtLabel(intloop).text
   rightuprite ans$
   TxtLabel(Index).text = ans$
   temp$ = ""
   tempval = StoredColour((TxtLabel(intloop).ForeColor))
   If tempval > 0 Then
      temp$ = Trim$(Format$(tempval)) & "!"
   End If
   labelline$(intloop) = temp$ & RTrim$(ans$)
   Me.Hide
Next


End Sub

Private Sub CmdCancel_Click()
   Me.Hide
End Sub

Private Sub Form_Activate()

   If Me.Tag = "fromload" Then
      Me.cmdCancel.Visible = False
      
   Else
      Me.cmdCancel.Visible = True
   End If
   
   Me.cmbOK.SetFocus
   
End Sub

Private Sub Form_Load()
Dim intloop As Integer
   SetChrome Me
   CentreForm Me
   'reset fonts
   For intloop = 0 To 15 '05Aug14 TH
      Me.TxtLabel(intloop).font = "Courier New"
   Next
   
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If Me.cmdCancel.Visible = False Then
      cmbOK_Click
   End If
   
End Sub

Private Sub TxtLabel_Change(Index As Integer)
'03Jul97 ASC   - Wordwrapping now works correctly
'13Jun98 ASC copes with word wrapping when no spaces on line
'17Mar99 TH  Use second drug description if blank and move directions up
'18Mar99 TH  Retain word on next line if moving directions up
'18Mar99 TH  Fill Third line on label if blank with long directions

Dim temp%, numofspaces%, strlen%, X%, ans$, tabpos%
Dim tmp$, pos%, pos2%  '18Mar99 TH

   TxtLabelChanged = True
   StopEvents = False  '13May14 TH
   'will always change for a new label as it is loaded!!!
   If Not StopEvents Then      ' 1Nov96 ASC stops recursion
         StopEvents = True     '28Jul97 CKJ moved from below
         If Index < 15 Then '05Aug14 TH
               strlen = Len(TxtLabel(Index).text)
               tmp$ = TxtLabel(Index).text        '18Mar99 TH
               If strlen > 35 Then     'find the first space available back from end of line
                     If InStr(TxtLabel(Index).text, " ") Then  '13Jun98 ASC copes when no spaces on line
                           For X = strlen To 0 Step -1
                              If Mid$(TxtLabel(Index).text, X, 1) = " " Then Exit For
                           Next
                           If X <= 0 Then X = 34
                           ans$ = TxtLabel(Index).text
                           temp% = TxtLabel(Index).SelStart  'store position of curser (caret)
                           TxtLabel(Index).text = Left$(ans$, X - 1)
                           numofspaces% = 0
                           If Index < 12 Then '05Aug14 TH
                                 'wrap text if necessary
                                 numofspaces% = -1 * ((Len(TxtLabel(Index + 1).text) > 1) And Len(LTrim$(Right$(ans$, strlen - X))) > 0)
                                 TxtLabel(Index + 1).text = LTrim$(Right$(ans$, strlen - X) & Space$(numofspaces%) & TxtLabel(Index + 1).text)
                                 TxtLabel(Index).SelStart = temp%
                               Else
                                 If TxtLabel(2).text = "" Or TxtLabel(3).text = "" Then   '18Mar99 TH Also Check third line
                                       If TxtLabel(2).text = "" Then
                                             For X = 3 To 14
                                                TxtLabel(X - 1).text = TxtLabel(X).text '  "
                                             Next
                                          Else
                                             For X = 4 To 14
                                                TxtLabel(X - 1).text = TxtLabel(X).text
                                             Next
                                          End If
                                       TxtLabel(5).text = ""
                                       pos2 = 35                             '18Mar99 TH Retain word on next line
                                       pos = 0
                                       Do
                                          If pos > 1 Then pos2 = pos
                                          pos = InStr(pos + 1, tmp$, " ")
                                       Loop While pos > 0
                                       tmp$ = Mid$(tmp$, pos2 + 1)
                                       TxtLabel(5).text = tmp$
                                       TxtLabel(5).SelStart = Len(tmp$)
                                       Index = 4
                                    Else
                                       '13May14 TH There still isnt enough room
                                       
                                       popmessagecr "!", "Insufficient room on label"
                                    End If
                               End If
                         End If
                     'move cursor to the next line and to the end of he wrapped text
                     If TxtLabel(Index).SelStart = Len(TxtLabel(Index).text) And TxtLabel(Index + 1).Visible Then
                           SetFocusTo TxtLabel(Index + 1)
                           tabpos = temp% - Len(TxtLabel(Index).text) - 1 '7Jul97 ASC stops negative positions for cursor
                           If tabpos < 0 Then tabpos = 0
                           TxtLabel(Index + 1).SelStart = tabpos
                        End If
                  End If
            End If
         
         StopEvents = False
      End If
         
   TxtLabel(Index).FontBold = False
   ''If Len(Trim$(TxtLabel(Index).text)) < 23 And Index > 0 And Index < 7 Then
   'If Len(Trim$(TxtLabel(Index).text)) < 23 And Index > 0 And Index < 18 Then
   If Len(Trim$(TxtLabel(Index).text)) < 23 And Index > 0 And Index < 16 Then
         TxtLabel(Index).FontSize = 12
      Else
         TxtLabel(Index).FontSize = 10
      End If
   
End Sub

Private Sub TxtLabel_DblClick(Index As Integer)


   If L.IssType = "C" And passlvl <> 8 Then                                               '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then    '         "
         Exit Sub                                                                         '         "
      End If                                                                              '         "
   ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
      Exit Sub
   End If
   '27May08 TH -----------
   
   '20Jul12 TH Added (TFS 26712)
   If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
      Exit Sub
   End If
   '20Jul12 TH --------

   Select Case Index
      Case 0
         ChooseInstructionCode
         setforecolour 0, True, True
         ans$ = RTrim$(labelline$(0))
         If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
         frmExtraLabel.TxtLabel(0).text = ans$
            
      Case 12 To 14
         'save current label first ?
         ChooseWarningCode
         'Now we need to rebuild the warning
         For X = 14 To 14  '05Aug14 TH
            setforecolour X, True, True
            ans$ = RTrim$(labelline$(X))
            If Mid$(ans$, 2, 1) = "!" Then ans$ = Right$(ans$, Len(ans$) - 2)
            frmExtraLabel.TxtLabel(X).text = ans$
         Next
      End Select
End Sub

Private Sub TxtLabel_KeyDown(Index As Integer, KeyCode As Integer, Shift As Integer)
'28Jul97 CKJ Moved Case 38 & 40 from the KeyUp event, and added KeyCode=0
'            This prevents the cursor wandering sideways during vertical movement.
'16Feb00 AE  Code to show pop-up menu if using highlightdescriptionlines mod.
'15Jun11 TH added switch to stop label editing (F0109779)

Dim found&, startpos%, ans$, carry$, linx%, done%, X%, splitpoint%

   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                               '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then    '        "
         KeyCode = 0                                                                      '        "
         Exit Sub                                                                         '        "
      End If                                                                              '        "
   ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
      KeyCode = 0
      Exit Sub
   End If                                                                                 '        "
   '27May08 TH --------
   
   '20Jul12 TH Added (TFS 26712)
   If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
      KeyCode = 0
      Exit Sub
   End If
   '20Jul12 TH --------
   
   Select Case KeyCode
      Case 38     'Key_up
         If Index > 1 Then
               KeyCode = 0    '28Jul97 CKJ Added
               SetFocusTo TxtLabel(Index - 1)
            End If
            
      Case 40     'Key_Down
         KeyCode = 0          '28Jul97 CKJ Added
         ''If Index < 5 Then
         If Index < 14 Then
               SetFocusTo TxtLabel(Index + 1)
            Else
               ''''SetFocusTo TxtPrompt
            End If
            
      Case 13 'Return
         found& = 0
''         AddDirCodeToLabel index, found&            '09May05 Removed ability to add direction codes here (requested by AS)
         If found& = 0 Then
               If Index = 5 Then
                     ''SetFocusTo TxtPrompt
                  End If
               startpos = TxtLabel(Index).SelStart
               ans$ = TxtLabel(Index).text
               ans$ = RTrim$(ans$)
               'If Len(ans$) - startpos > 0 And Index < 5 Then
               If Len(ans$) - startpos > 0 And Index < 16 Then
                     carry$ = Right$(ans$, Len(ans$) - startpos)
                     ans$ = Left$(ans$, startpos)
                     rightuprite ans$
                     TxtLabel(Index).text = ans$
                     linx = 0
                     done = True
                     Do
                        'If Len(carry$) And Index + linx < 5 Then
                        If Len(carry$) And Index + linx < 16 Then
                              done = False
                              linx = linx + 1
                              ans$ = RTrim$(TxtLabel(Index + linx).text)
                              'plingparse ans$, "°"
                              ans$ = RTrim$(ans$)
                              ans$ = carry$ + " " + ans$
                              If Len(RTrim$(ans$)) > 35 Then
                                    X = 0
                                    Do
                                       splitpoint = X
                                       X = InStr(splitpoint + 1, ans$, " ")
                                    Loop Until X > 35 Or X = 0
                                  Else
                                    If Len(ans$) < 23 Then rightuprite ans$
                                    done = True
                                    TxtLabel(Index + linx).text = LTrim$(ans$)
                                    Exit Do
                                 End If
                              carry$ = Right$(ans$, Len(ans$) - splitpoint)
                              TxtLabel(Index + linx).text = RTrim$(LTrim$(Left$(ans$, splitpoint)))
                              If Len(RTrim$(TxtLabel(Index + linx).text)) < 23 Then
                                    ans$ = RTrim$(TxtLabel(Index + linx).text)
                                    rightuprite ans$
                                    TxtLabel(Index + linx).text = LTrim$(ans$)
                                 End If
                           End If
                     'Loop Until Index + linx > 4 Or done
                     Loop Until Index + linx > 13 Or done
         
                     If Not done Then popmessagecr "WARNING", "No room for " & carry$
                  End If
            End If

      Case 27 'Escape
         'SetFocusTo TxtPrompt
         'Need to work out what to do on escape

      Case KEY_F2   'Shift + F2
         If Shift = 1 And Index > 0 Then
            ShowColourAndDescriptionSplitMenu Index, True
         End If

      End Select

End Sub

Private Sub TxtLabel_KeyPress(Index As Integer, KeyAscii As Integer)
'15Jun11 TH added switch to stop label editing (F0109779)
   
   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                               '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then    '           "
         KeyAscii = 0                                                                     '           "
         Exit Sub                                                                         '           "
      End If                                                                              '           "
   ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
      KeyAscii = 0
      Exit Sub
   End If                                                                                 '           "
   '27May08 TH ------------
   
   '20Jul12 TH Added (TFS 26712)
   If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
      KeyAscii = 0
      Exit Sub
   End If
   '20Jul12 TH --------
   
   Select Case KeyAscii
      Case 13, 27: KeyAscii = 0
      End Select
End Sub

Private Sub TxtLabel_KeyUp(Index As Integer, KeyCode As Integer, Shift As Integer)
'22Jun96 ASC Took procedure from DOS release and made delete work by adding keycode 46 to word wrap case statemeent
'28Jul97 CKJ Moved Case 38 & 40 to the KeyDown event
'8Aug97 CKJ/KR Added check to prevent 1st line of warnings moving upwards
'15Jan99 EAC Enhancement 603

''Static tempforundel$                        '!!** NOT ADVISABLE! stops the form unloading
Dim ans$, GlueText%, X%, splitpoint%

   '27May08 TH Ported from v8 (F001810)
   If L.IssType = "C" And passlvl <> 8 Then                                                  '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then       '       "
         KeyCode = 0                                                                         '       "
         Exit Sub                                                                            '       "
      End If                                                                                 '       "
   ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
      KeyCode = 0
      Exit Sub
   End If                                                                                    '       "
   '27May08 TH --------------
   
   '20Jul12 TH Added (TFS 26712)
   If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
      KeyCode = 0
      Exit Sub
   End If
   '20Jul12 TH --------

   If KeyCode = 127 And TxtLabel(Index).SelStart = Len(TxtLabel(Index).text) Then
         TxtLabelChanged = False
      End If

   If Not TxtLabelChanged Then
         Select Case KeyCode
''            Case 117    ' F6 delete
''               tempforundel$ = TxtLabel(index).Text
''               TxtLabel(index).Text = ""
''               ans$ = TxtLabel(index).Text
''               rightuprite ans$
''               TxtLabel(index).Text = ans$
''               LabelAmended = True
''
''            Case 118    ' F7 Un-delete
''               TxtLabel(index).Text = tempforundel$
               
''09May05 Removed ability to add direction codes here (requested by AS)
''            Case 112    ' ^F1
''               SelectDirs index     '2Feb95 CKJ added index
            
            'Case 38     'Key_up
            '   If Index > 1 Then TxtLabel(Index - 1).SetFocus
            
            'Case 40     'Key_Down
            '   If Index < 5 Then
            '         TxtLabel(Index + 1).SetFocus
            '      Else
            '         If passlvl = 3 Then TGLabelList.SetFocus  Else TxtPromptSetFocus
            '      End If
            
            Case 8, 127, 46  'Back space/Delete  N.B. delete=46 in VBwin
               If Index < 5 Then
                  If TxtLabel(Index).SelStart = Len(TxtLabel(Index).text) And Index > 0 Then
                        Index = Index + 1
                        GlueText = True
                     End If
   
                  If TxtLabel(Index).SelStart = 0 And Index > 1 Then
                        GlueText = True
                     End If
      
                  If GlueText Then
                     ans$ = TxtLabel(Index - 1).text
                     'plingparse ans$, "°"
                     ans$ = RTrim$(ans$)
                     If Len(ans$) Then ans$ = ans$ + " "
                     ans$ = RTrim$(ans$ & TxtLabel(Index).text)
                     If Len(ans$) > 35 Then
                        X = 0
                        Do
                           splitpoint = X
                           X = InStr(splitpoint + 1, ans$, " ")
                        Loop Until X > 36 Or X = 0                                        '12Oct05 CKJ was 35
'                        TxtLabel(index).Text = Right$(ans$, Len(ans$) - splitpoint)
'                        TxtLabel(index - 1).Text = Left$(ans$, splitpoint)
                        TxtLabel(Index).text = Mid$(ans$, splitpoint + 1)                 '   "        functionally unchanged
                        TxtLabel(Index - 1).text = Left$(ans$, splitpoint - 1)            '   "        don't include the space
                     Else
                        KeyCode = 0    '28Jul97 CKJ Added
                        TxtLabel(Index).text = ""
                        TxtLabel(Index - 1).text = ans$
                        SetFocusTo TxtLabel(Index - 1)
                     End If
                  End If
               End If

            Case Else 'ASC 03Nov95
               LabelAmended = True
               
            End Select
      End If
   TxtLabelChanged = False
End Sub

Private Sub TxtLabel_MouseDown(Index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)
'16Feb00 AE  Written
'Show pop-up menu on mouse right click on highlighted direction text.
'This will only be active if the ini setting HighlightPMRDescriptionLines=Y
'is present in patmed.ini. If not, DescriptionSplitLine will return 0,
'hence the criteria for showing the menu will never be fulfilled.
'Notice the slight fiddle required to avoid the inbuilt context menu
'appearing first.
'-------------------------------------------------------------------------
'19Jul11 TH Disable this if required (F0123219)

Dim iBut As Integer

   '19Jul11 TH Disable this if required (F0123219)
   If L.IssType = "C" And passlvl <> 8 Then                                                  '12Jan07 TH Locking of the CIVAS label (DR-06-0271, enh78042)
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "StopCivasEdits", 0)) Then       '       "
         If button = 2 Then
            LockWindowUpdate TxtLabel(Index).Hwnd
            TxtLabel(Index).Enabled = False
            popmessagecr "", "This action has been disabled"
            TxtLabel(Index).Enabled = True
            LockWindowUpdate 0
         End If
         button = 0
         Exit Sub                                                                            '       "
      End If                                                                                 '       "
   ElseIf passlvl <> 8 And (InStr(TxtD(dispdata$ & "\patmed.ini", "", "", "StopIssTypeEdits", 0), L.IssType) > 0) Then '15Jun11 TH added (F0109779)
      If button = 2 Then
         LockWindowUpdate TxtLabel(Index).Hwnd
         TxtLabel(Index).Enabled = False
         popmessagecr "", "This action has been disabled"
         TxtLabel(Index).Enabled = True
         LockWindowUpdate 0
      End If
      button = 0
      Exit Sub
   End If
   '19Jul11 TH End
   
   '20Jul12 TH Added (TFS 26712)
   If passlvl <> 8 And (InStr(GetLabelTypesPreventEdit(), L.IssType) > 0) Then
      If button = 2 Then
         LockWindowUpdate TxtLabel(Index).Hwnd
         TxtLabel(Index).Enabled = False
         popmessagecr "", "This action has been disabled"
         TxtLabel(Index).Enabled = True
         LockWindowUpdate 0
      End If
      button = 0
      Exit Sub
   End If
   '20Jul12 TH --------
   
   If Index > 0 Then      'Set button to 0 and disable text box to prevent the inbuilt context menu from firing.
         iBut = button
         button = 0
         If iBut And RIGHT_BUTTON Then
''            TxtLabel(index).Enabled = False         '!!** actually needed!
            TxtLabel(Index).Enabled = True
            ShowColourAndDescriptionSplitMenu Index, True
         End If
      End If

End Sub
