VERSION 2.00
Begin Form FrmList 
   BackColor       =   &H8000000A&
   Caption         =   "Select Patient"
   ClientHeight    =   6795
   ClientLeft      =   1065
   ClientTop       =   345
   ClientWidth     =   9495
   Height          =   7215
   Icon            =   FRMLIST.FRX:0000
   KeyPreview      =   -1  'True
   Left            =   1005
   LinkTopic       =   "Form1"
   MinButton       =   0   'False
   ScaleHeight     =   6795
   ScaleWidth      =   9495
   Top             =   -15
   Width           =   9615
   Begin ColumnListbox LstPatients 
      Height          =   6495
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   9255
   End
   Begin MhTimer MhTimer1 
      Height          =   420
      Interval        =   0
      Left            =   8340
      Top             =   6360
      Width           =   420
   End
   Begin PictureBox Picture1 
      BorderStyle     =   0  'None
      Height          =   315
      Left            =   8880
      Picture         =   FRMLIST.FRX:0302
      ScaleHeight     =   315
      ScaleWidth      =   345
      TabIndex        =   1
      Top             =   6480
      Width           =   345
   End
   Begin Label Label1 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   60
      TabIndex        =   2
      Top             =   5580
      Width           =   8835
   End
End
'************************************************************************************************
'* Modification History
'************************************************************************************************
'01Nov96  KR Added Mhtimer & appropriate code so that form times out.
' 4Dec96 CKJ Well! A bit of a faff but it now works with Collist.vbx.
'            Problems with page down mean that it has to be handled in code,
'            Hence the hidden picture box, to get focus & receive keystrokes.
'29Mar97 CKJ Form_KeyDown - changed number of lines per page
'04Mar99 CFY Now picks up windows colours
' 5Nov99 CKJ LstPatients_Click: Changed to = 3.11, since NT4 reports WindowsVersion as 3.10
'             This prevented double click selection under NT4
'01Jun02 All/CKJ Added defint a-z
'************************************************************************************************
Option Explicit
DefInt A-Z

Dim KeyInput As String
Dim AllowPgDn As Integer

Sub Form_Activate ()
'02Apr96 KR Highlight so ensure correct highlighting on page down.

   AllowPgDn = (Me.Tag = "-1")
   Me.Tag = ""
   LstPatients.Tag = ""
   'If LstPatients.ListIndex <> -1 Then LstPatients.ListIndex = LstPatients.ListCount - 1 '02Apr96 KR removed
   TimeoutOn MhTimer1  '01Nov96 KR Added
   If Val(Label1.Tag) Then
         SortColumn Val(Label1.Tag) - 1
      End If
   Label1.Tag = ""

End Sub

Sub Form_Deactivate ()
   
   TimeoutOff MhTimer1 '01Nov96 KR Added

End Sub

Sub Form_KeyDown (KeyCode As Integer, Shift As Integer)

Dim linsperscreen%, lin%
   
   If Shift = 0 Then
         Select Case KeyCode
            Case KEY_ESCAPE
               KeyCode = 0
               Hide
   
            Case KEY_RETURN
               KeyCode = 0
               If LstPatients.ListIndex > -1 Then
                     LstPatients.Tag = Format$(LstPatients.ListIndex)
                  End If
               Hide

            Case Else
               linsperscreen = LstPatients.Height \ TxtHeight(LstPatients) - 4 '29Mar97 CKJ was '- 2'
               If linsperscreen < 1 Then linsperscreen = 1
               lin = LstPatients.ListIndex
               Select Case KeyCode
                  Case KEY_UP:   lin = lin - 1
                  Case KEY_HOME: lin = 0
                  Case KEY_END:  lin = 32767
                  Case KEY_PgUp: lin = lin - linsperscreen
                  Case KEY_PgDn, KEY_DOWN
                     If AllowPgDn And LstPatients.ListIndex = LstPatients.ListCount - 1 Then
                           Me.Tag = "-1"
                           AllowPgDn = False
                           Me.Hide
                        Else
                           If KeyCode = KEY_DOWN Then
                                 lin = lin + 1
                              Else
                                 lin = lin + linsperscreen
                              End If
                        End If
                  End Select
               If lin >= LstPatients.ListCount Then lin = LstPatients.ListCount - 1
               If lin < 0 Then lin = 0
               If lin <> LstPatients.ListCount Then LstPatients.ListIndex = lin
            End Select
      End If
   TimeoutOn MhTimer1  '01Nov96 KR Added

End Sub

Sub Form_KeyUp (KeyCode As Integer, Shift As Integer)
Dim i%, ColumnNo%

   Select Case Shift
      Case 0
         Select Case KeyCode
            Case 65 To 90, 48 To 57, 8, 46 'a-z 0-9
               Select Case KeyCode
                  Case 8, 46
                     If KeyInput <> "" Then
                           KeyInput = Left$(KeyInput, Len(KeyInput) - 1)
                        End If
                  Case Else
                     KeyInput = KeyInput & UCase$(Chr$(KeyCode))
                  End Select
               
               For i = 0 To LstPatients.ListCount - 1
                  If InStr(UCase$(Left$(LstPatients.List(i), 4)), KeyInput) = 1 Then
                     LstPatients.ListIndex = i
                     Exit For
                  Else
                     LstPatients.ListIndex = -1
                  End If
               Next
               KeyCode = 0
            End Select

      Case 1        'Shift
         If KeyCode = KEY_F1 Then LstPatients_ClickRight 0, 0, 0

      Case 4        'Alt-letter
         ColumnNo = InStr("CFSXTDWCP", Chr$(KeyCode)) - 1
         If ColumnNo >= 0 Then SortColumn ColumnNo                 'now sort as req'd
      End Select
   TimeoutOn MhTimer1  '01Nov96 KR Added

End Sub

Sub Form_Load ()
   
   KeyInput = ""           'used to determine entry selected
   CentreForm Me           '23Feb96  KR  Widened form and centred it.

End Sub

Sub Form_MouseDown (Button As Integer, Shift As Integer, X As Single, Y As Single)
   
   TimeoutOn MhTimer1

End Sub

Sub Form_QueryUnload (Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then
         Cancel = True
         Hide
      End If

End Sub

Sub Form_Resize ()
'4Dec96 CKJ Added
Dim ht%

   LstPatients.Width = Me.ScaleWidth
   ht = Me.ScaleHeight - Picture1.Height
   If ht > 0 Then LstPatients.Height = ht
   Picture1.Top = LstPatients.Height
   Label1.Top = LstPatients.Height + 60

End Sub

Sub LstPatients_Click ()
'14Dec96 CKJ Added: essential for 3.11, must be removed for 95
' 5Nov99 CKJ Changed to = 3.11, since NT4 reports WindowsVersion as 3.10

   'If windowsversion() <= 3.11 Then
   If windowsversion() = 3.11 Then
         SendKeys "{Tab}"
      End If

End Sub

Sub LstPatients_ClickRight (intIndex As Integer, X As Integer, Y As Integer)
'
Dim ans$

   PopMenu 0, "", 0, 0
   PopMenu 2, "Sort by Case Number[cr]Sort by Forename[cr]Sort by Surname[cr]Sort by Sex[cr]Sort by Status[cr]Sort by Date of Birth[cr]Sort by Ward[cr]Sort by Consultant[cr]Sort by Previous Case Number", 0, 0
   PopMenuShow ans$, X, Y
   If Val(ans$) Then
         'If ans$ = "1" Then LstPatients.SortByColumn = 8      'force change first
         'LstPatients.SortByColumn = Val(ans$) - 1             'now sort as req'd
         SortColumn Val(ans$) - 1                              'now sort as req'd
      End If
   PopMenu 0, "", 0, 0

End Sub

Sub LstPatients_DblClick ()
   
   If LstPatients.ListIndex > -1 Then
         LstPatients.Tag = Format$(LstPatients.ListIndex)
      End If
   Hide

End Sub

Sub LstPatients_GotFocus ()
   
   SendKeys "{Tab}"
   
End Sub

Sub LstPatients_MouseUp (Button As Integer, Shift As Integer, X As Single, Y As Single)
'
End Sub

Sub LstPatients_Sort (intColumn As Integer, strItem1 As String, strItem2 As String, blnItem2Less As Integer)
'only used for date
Dim s1$, s2$

   s1$ = Right$("          " & strItem1, 10)
   s2$ = Right$("          " & strItem2, 10)
   s1$ = Mid$(s1$, 7, 4) & Mid$(s1$, 4, 2) & Left$(s1$, 2)
   s2$ = Mid$(s2$, 7, 4) & Mid$(s2$, 4, 2) & Left$(s2$, 2)
   If s2$ < s1$ Then blnItem2Less = True

End Sub

Sub MhTimer1_Timer ()
'01Nov96 KR Added
   
   If TimedOut() Then Hide    'assume Esc pressed

End Sub

Sub Picture1_Click ()
'Page down
   
   If AllowPgDn Then
         Me.Tag = "-1"
         AllowPgDn = False
         Me.Hide
      Else
         LstPatients.ListIndex = LstPatients.ListCount - 1
      End If

End Sub

Sub SortColumn (ColumnNo%)
'ColumnNo = 0 to 8
         
   If ColumnNo = LstPatients.SortByColumn Then                    'force change first
         LstPatients.SortByColumn = ColumnNo + 1
      End If
   If ColumnNo >= 0 Then LstPatients.SortByColumn = ColumnNo      'now sort as req'd

End Sub

