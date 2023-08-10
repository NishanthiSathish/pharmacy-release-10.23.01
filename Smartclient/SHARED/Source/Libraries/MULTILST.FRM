VERSION 5.00
Begin VB.Form MultiList 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   ClientHeight    =   11010
   ClientLeft      =   45
   ClientTop       =   525
   ClientWidth     =   12000
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
   Icon            =   "MULTILST.frx":0000
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   11010
   ScaleWidth      =   12000
   Begin VB.ListBox LstSelected 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
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
      Height          =   3735
      Left            =   5520
      TabIndex        =   9
      Top             =   945
      Width           =   3840
   End
   Begin VB.CommandButton CmdAdd 
      Appearance      =   0  'Flat
      Caption         =   "&Add >"
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
      Height          =   390
      Left            =   3960
      Style           =   1  'Graphical
      TabIndex        =   5
      Top             =   1485
      Width           =   1440
   End
   Begin VB.CommandButton CmdRemove 
      Appearance      =   0  'Flat
      Caption         =   "< &Remove "
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
      Height          =   390
      Left            =   3960
      Style           =   1  'Graphical
      TabIndex        =   7
      Top             =   3165
      Width           =   1440
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
      Left            =   7830
      Style           =   1  'Graphical
      TabIndex        =   10
      Top             =   4860
      Width           =   1440
   End
   Begin VB.CommandButton CmdOK 
      Appearance      =   0  'Flat
      Caption         =   "&OK"
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
      Left            =   6255
      Style           =   1  'Graphical
      TabIndex        =   11
      Top             =   4860
      Width           =   1440
   End
   Begin VB.CommandButton cmdAddAll 
      Appearance      =   0  'Flat
      Caption         =   "All >>"
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
      Height          =   390
      Left            =   3960
      Style           =   1  'Graphical
      TabIndex        =   6
      Top             =   1920
      Width           =   1440
   End
   Begin VB.CommandButton cmdRemoveAll 
      Appearance      =   0  'Flat
      Caption         =   "<< All "
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
      Height          =   390
      Left            =   3960
      Style           =   1  'Graphical
      TabIndex        =   8
      Top             =   3600
      Width           =   1440
   End
   Begin VB.ListBox LstUnselected 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
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
      Height          =   3735
      Left            =   60
      Sorted          =   -1  'True
      TabIndex        =   4
      Top             =   945
      Width           =   3795
   End
   Begin VB.Label lblLine 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
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
      Height          =   240
      Index           =   0
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   9360
   End
   Begin VB.Label lblLine 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00808000&
      BackStyle       =   0  'Transparent
      ForeColor       =   &H00000000&
      Height          =   240
      Index           =   1
      Left            =   0
      TabIndex        =   1
      Top             =   240
      Width           =   9360
   End
   Begin VB.Label lblLine 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
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
      Height          =   240
      Index           =   2
      Left            =   0
      TabIndex        =   2
      Top             =   480
      Width           =   9360
   End
   Begin VB.Label lblLine 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
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
      Height          =   240
      Index           =   3
      Left            =   0
      TabIndex        =   3
      Top             =   720
      Width           =   9360
   End
   Begin VB.Label lblSel 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      BackColor       =   &H00808000&
      BackStyle       =   0  'Transparent
      ForeColor       =   &H00808080&
      Height          =   240
      Left            =   4800
      TabIndex        =   13
      Top             =   4410
      Width           =   720
   End
   Begin VB.Label lblUnSel 
      Appearance      =   0  'Flat
      BackColor       =   &H00808000&
      BackStyle       =   0  'Transparent
      ForeColor       =   &H00C0C0C0&
      Height          =   240
      Left            =   3870
      TabIndex        =   12
      Top             =   4410
      Visible         =   0   'False
      Width           =   720
   End
   Begin VB.Menu mnuHdgFile 
      Caption         =   "&File"
      Begin VB.Menu mnuExit 
         Caption         =   "E&xit"
      End
   End
   Begin VB.Menu mnuHdgOptions 
      Caption         =   "&Options"
      Enabled         =   0   'False
      Visible         =   0   'False
      Begin VB.Menu mnuOptions 
         Caption         =   "Option0"
         Index           =   0
      End
   End
   Begin VB.Menu mnuHdgHelp 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelp 
         Caption         =   "&Help Contents                        F1"
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
Attribute VB_Name = "MultiList"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------------------------------------------------------------
'                               MultiList Form
'
'11May95 CKJ Written
'
'Details
' Form name : MultiLst.frm, MultiList
' Text lines: lblLine(0-3).caption, lblLine(0-3).alignment=0/1/[2]
' List boxes: lstUnselected, lstSelected (.Sorted=[T]/F)
' Max. items: MultiList.Tag="n" where n is the maximum number selectable
'
'Returns
' valid = VAL(MultiList.Tag)   set "-1" if valid on exit
' MultiList.lstSelected        holds all items chosen (even if Escaped)
'
'Note: If the form is not unloaded between calls then the main program will
' have to empty both list boxes before refilling them.
'
'26May95 CKJ Added max items
' 5Jun95 CKJ Show count of items in both boxes
' 2Jul97 CKJ resized buttons & made boxes white. Added icon
'04Mar99 CFY Changed to use windows colours and removed bold text
'17Sep99 AE  CmdAdd_Click & CmdRemove_Click:Added line to copy itemdata along
'            with the item text
'10nov01 CKJ Made form resizable and now occupies more screen area.
'            Replaced references to "multilist." with "Me."
'            Trapped QueryUnload event, added Option Explicit
'            Changed MsgBox to popmessagecr
'            Hide the AddAll and RemoveAll buttons if maxitems is <=5
'            Allow non-selectable headings in the Unselected column - include
'            an ASCII 160 anywhere in the line. This displays as a space.
'            Added File/Options/Help menus
'            Swapped OK/Cancel buttons to conform to normal layout
'            Set lstSelected to be non-sorted. It now retains the order in
'            which the user selected items.
'14feb03 CKJ lblline(3) sized as per the others
'-----------------------------------------------------------------------------
DefInt A-Z
Option Explicit

Dim maxitems As Integer

Private Sub CmdAdd_Click()
'17Sep99 AE  Added line to copy itemdata along with the item text
'10Nov01 CKJ added trap for char 160, which displays as a space.
'            Only add lines which do not contain ASCII 160, as this is used as the marker for headings

Dim ptr As Integer

   If LstSelected.ListCount < maxitems Then
         If LstUnselected.ListCount Then
               If LstUnselected.ListIndex = -1 Then LstUnselected.ListIndex = 0
               ptr = LstUnselected.ListIndex
               If InStr(LstUnselected.Text, Chr$(160)) = 0 Then                          '10Nov01 CKJ added
                     If ptr > -1 Then
                           LstSelected.AddItem LstUnselected.Text
                           LstSelected.ItemData(LstSelected.NewIndex) = LstUnselected.ItemData(LstUnselected.ListIndex)  '17Sep99 AE Added
                           LstUnselected.RemoveItem ptr
                           SetCounts
                        End If
                  End If                                                                 '10Nov01 CKJ added
            End If
         Else
            '10Nov01 CKJ Changed MsgBox to popmessagecr
            'MsgBox "Maximum number of items have already been selected", 0, "Maximum number of items allowed =" & Str$(maxitems)
            popmessagecr "!", "Maximum number of items have already been selected" & crlf & "Number of items allowed is" & Str$(maxitems)
         End If

   If LstUnselected.ListCount = 0 Or LstSelected.ListCount >= maxitems Then
         CmdAdd.Enabled = False
         cmdAddAll.Enabled = False
         LstSelected.SetFocus
      ElseIf ptr <= LstUnselected.ListCount - 1 Then
         LstUnselected.ListIndex = ptr
         LstUnselected.SetFocus
      Else
         LstUnselected.ListIndex = LstUnselected.ListCount - 1
         LstUnselected.SetFocus
      End If

   If LstSelected.ListCount Then
         CmdRemove.Enabled = True
         cmdRemoveAll.Enabled = cmdRemoveAll.Visible     '10Nov01 CKJ was '= True'
         CmdOK.Enabled = True
         CmdOK.Default = True
      End If

End Sub

Private Sub cmdAddAll_Click()

   Do While LstUnselected.ListCount > 0 And LstSelected.ListCount < maxitems
      LstUnselected.ListIndex = 0
      CmdAdd_Click
   Loop

End Sub

Private Sub cmdCancel_Click()

   Me.Hide

End Sub

Private Sub cmdOK_Click()

   Me.Tag = "-1"
   Me.Hide

End Sub

Private Sub CmdRemove_Click()
'17Sep99 AE Added line to copy itemdata along with the item text

Dim ptr As Integer
           
   If LstSelected.ListCount Then
         If LstSelected.ListIndex = -1 Then LstSelected.ListIndex = 0

         ptr = LstSelected.ListIndex
         If ptr > -1 Then
               LstUnselected.AddItem LstSelected.Text
               LstUnselected.ItemData(LstUnselected.NewIndex) = LstSelected.ItemData(LstSelected.ListIndex)  '17Sep99 AE Added
               LstSelected.RemoveItem ptr
               SetCounts
            End If
      End If

   If LstSelected.ListCount = 0 Then
         CmdRemove.Enabled = False
         cmdRemoveAll.Enabled = False
         CmdOK.Enabled = False
         CmdOK.Default = False
         LstUnselected.SetFocus
      ElseIf ptr <= LstSelected.ListCount - 1 Then
         LstSelected.ListIndex = ptr
         LstSelected.SetFocus
      Else
         LstSelected.ListIndex = LstSelected.ListCount - 1
         LstSelected.SetFocus
      End If

   If LstUnselected.ListCount > 0 And LstSelected.ListCount < maxitems Then
         CmdAdd.Enabled = True
         cmdAddAll.Enabled = cmdAddAll.Visible      '10Nov01 CKJ was '= True'
      End If

End Sub

Private Sub cmdRemoveAll_Click()

   Do While LstSelected.ListCount
      LstSelected.ListIndex = 0
      CmdRemove_Click
   Loop

End Sub

Private Sub Form_Load()

   SetChrome Me
   
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
'10Nov01 CKJ written

   If UnloadMode <> 1 Then
         Cancel = True
         Me.Hide
      End If

End Sub

Private Sub Form_Resize()
'10nov01 ckj written
'14feb03 CKJ lblline(3) sized as per the others

Dim intloop As Integer

   On Error Resume Next
   cmdCancel.top = Me.ScaleHeight - CmdOK.Height - 120
   cmdCancel.Left = Me.ScaleWidth - CmdOK.Width - 120
   CmdOK.top = cmdCancel.top
   CmdOK.Left = cmdCancel.Left - CmdOK.Width - 120

   'lblLine(0).Width = Me.ScaleWidth                  '14feb03 ckj
   'lblLine(1).Width = Me.ScaleWidth
   'lblLine(2).Width = Me.ScaleWidth
   For intloop = 0 To 3
      lblLine(intloop).Width = Me.ScaleWidth
   Next                                               '14feb03 ---
   
   LstUnselected.Height = CmdOK.top - LstUnselected.top - 60
   LstSelected.Height = LstUnselected.Height
   LstUnselected.Width = (Me.ScaleWidth - CmdAdd.Width - 240) \ 2
   LstSelected.Width = LstUnselected.Width
   CmdAdd.Left = LstUnselected.Left + LstUnselected.Width + 60
   cmdAddAll.Left = CmdAdd.Left
   CmdRemove.Left = CmdAdd.Left
   cmdRemoveAll.Left = CmdAdd.Left
   LstSelected.Left = CmdAdd.Left + CmdAdd.Width + 60
   lblUnSel.Move LstUnselected.Left + LstUnselected.Width, LstUnselected.top + LstUnselected.Height - lblUnSel.Height
   lblSel.Move LstSelected.Left - lblSel.Width, lblUnSel.top
   On Error GoTo 0

End Sub

Private Sub LstSelected_DblClick()

   CmdRemove_Click

End Sub

Private Sub LstSelected_GotFocus()

   LstUnselected.ListIndex = -1
   If LstSelected.ListIndex = -1 And LstSelected.ListCount > 0 Then
         LstSelected.ListIndex = 0
      End If

End Sub

Private Sub LstSelected_KeyPress(Keyascii As Integer)

   If Keyascii = 32 Then CmdRemove_Click

End Sub

Private Sub LstSelected_KeyUp(KeyCode As Integer, Shift As Integer)

   If KeyCode = 37 And Shift = 0 Then           'left arrow
         If LstUnselected.ListCount Then LstUnselected.SetFocus
      End If

End Sub

Private Sub LstUnSelected_DblClick()

   CmdAdd_Click

End Sub

Private Sub LstUnSelected_GotFocus()
'This section is equivalent to form load, but fires on first activating the screen

  'IF maxitems = 0 THEN                             '26May95 CKJ Added section
   If Me.Tag <> "0" Then                     'blank or number
         If Val(Me.Tag) > 0 Then
               maxitems = Val(Me.Tag)
            Else
               maxitems = LstUnselected.ListCount + LstSelected.ListCount
            End If
         If maxitems <= 5 Then                           '10Nov01 CKJ Added to reduce screen clutter
               cmdAddAll.Enabled = False
               cmdAddAll.Visible = False
               cmdRemoveAll.Enabled = False
               cmdRemoveAll.Visible = False
            End If
      End If

   Me.Tag = "0"
   If LstUnselected.ListCount And LstSelected.ListCount < maxitems Then
         CmdAdd.Enabled = True
         cmdAddAll.Enabled = cmdAddAll.Visible           '10Nov01 CKJ was '= True'
         LstUnselected.ListIndex = 0
      End If
   If LstSelected.ListCount Then
         CmdRemove.Enabled = True
         cmdRemoveAll.Enabled = cmdRemoveAll.Visible     '10Nov01 CKJ was '= True'
      End If

   LstSelected.ListIndex = -1
   If LstUnselected.ListIndex = -1 And LstUnselected.ListCount > 0 Then
         LstUnselected.ListIndex = 0
      End If

   SetCounts

End Sub

Private Sub LstUnSelected_KeyPress(Keyascii As Integer)

   If Keyascii = 32 Then CmdAdd_Click
   If Keyascii = 13 Then
         CmdAdd_Click
         LstSelected.SetFocus
      End If

End Sub

Private Sub LstUnselected_KeyUp(KeyCode As Integer, Shift As Integer)

   If KeyCode = 39 And Shift = 0 Then          'right arrow
         If LstSelected.ListCount Then LstSelected.SetFocus
      End If
   
End Sub

Private Sub mnuExit_Click()
'10Nov01 CKJ added

   Me.Hide

End Sub

Private Sub mnuHelp_Click(index As Integer)
'10Nov01 CKJ Added

   Select Case index
      Case 0: SendKeys "{F1}"  'Help 0
      Case 1: HelpSearch Me.hWnd
      Case 2: HelpGet Me.hWnd, HELP_HELPONHELP, 0
      Case 3  'separator
      Case 4: ShowAboutBox "EMIS Health"
      End Select

End Sub

Private Sub SetCounts()
' 5Jun95 CKJ Written

   If LstUnselected.ListCount >= 10 Then
         lblUnSel.Caption = LTrim$(Str$(LstUnselected.ListCount))
      Else
         lblUnSel.Caption = ""
      End If

   If LstSelected.ListCount >= 10 Then
         lblSel.Caption = Str$(LstSelected.ListCount)
      Else
         lblSel.Caption = ""
      End If

End Sub

