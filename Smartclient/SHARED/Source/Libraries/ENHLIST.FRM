VERSION 5.00
Begin VB.Form EnhLstFrm 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   ClientHeight    =   4650
   ClientLeft      =   1050
   ClientTop       =   1320
   ClientWidth     =   6600
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
   Icon            =   "ENHLIST.frx":0000
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4650
   ScaleWidth      =   6600
   Visible         =   0   'False
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Left            =   5880
      Top             =   3960
   End
   Begin VB.CommandButton CmdOk 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Caption         =   "&OK"
      Default         =   -1  'True
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   3600
      Style           =   1  'Graphical
      TabIndex        =   7
      Top             =   4080
      Width           =   960
   End
   Begin VB.TextBox TxtInput 
      Appearance      =   0  'Flat
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Left            =   1920
      TabIndex        =   0
      Top             =   4080
      Width           =   1155
   End
   Begin VB.ListBox LstHdr 
      Appearance      =   0  'Flat
      BackColor       =   &H00800000&
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00C0C0C0&
      Height          =   225
      Left            =   120
      TabIndex        =   5
      TabStop         =   0   'False
      Top             =   120
      Visible         =   0   'False
      Width           =   6375
   End
   Begin VB.CommandButton CmdCancel 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Caption         =   "&Cancel"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   360
      Left            =   4680
      Style           =   1  'Graphical
      TabIndex        =   2
      Top             =   4080
      Width           =   960
   End
   Begin VB.ListBox LstBox 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
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
      Height          =   3345
      Left            =   120
      Sorted          =   -1  'True
      TabIndex        =   1
      Top             =   360
      Width           =   6375
   End
   Begin VB.Image CmdDropDown 
      Appearance      =   0  'Flat
      Enabled         =   0   'False
      Height          =   315
      Left            =   3120
      Picture         =   "ENHLIST.frx":030A
      Top             =   4080
      Visible         =   0   'False
      Width           =   285
   End
   Begin VB.Label lblInput 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Enter Code"
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
      Height          =   195
      Left            =   870
      TabIndex        =   6
      Top             =   4140
      Width           =   960
   End
   Begin VB.Label lblTitle 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
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
      Height          =   195
      Left            =   120
      TabIndex        =   4
      Top             =   0
      Width           =   75
   End
End
Attribute VB_Name = "EnhLstFrm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------------------------------------------------------------
'                                 ENHLISTBOX.FRM
'??????? EAC EnhLstBoxFrm derived from LstBoxFrm
'26Jun97 CKJ Set the Shift-F1 using CmdDropDown.Visible instead of tag
'22Oct97 CKJ Changed IIF to Iff
'19Jan98 EAC Use SendMessage and LB_FINDSTRING to find matching entry in LstBox
'11Feb98 CKJ Changed caption 'Enter Supplier code' to just 'Enter code'
'04Mar99 CFY Changed form colour to pick up windows colours
'29Apr99 AE  LstBox_DblClick.Made selection by double clicking work
'05Nov99 CKJ EnhLstFrm: Set Sorted=True on listbox
'09May05 CKJ replaced mhtimer with timer
'16Apr10 XN  F0065193 Allow user to reorder list by clicking header
'26Apr10 XN  Added handling of non sortable items like <New> and <All>
'06Sep10 XN  F0095829 EnhListBox sorting should be case insensitive
'-----------------------------------------------------------------------------
Option Explicit
DefInt A-Z

Dim intLastCol As Long
Dim objColumnSortTypes() As String
Dim boolTopItemNonSortable As Boolean
Dim blngAllowTextBoxLookup As Boolean

Private Sub cmdCancel_Click()

   TxtInput_KeyPress KEY_ESCAPE

End Sub

Private Sub CmdDropDown_Click()

   TxtInput_KeyUp KEY_F1, SHIFT_MASK

End Sub

Private Sub cmdOK_Click()

   TxtInput_KeyPress KEY_RETURN

End Sub

Private Sub Form_Activate()

   blngAllowTextBoxLookup = True
   CmdOk.Tag = "-1"
   TimeoutOn Timer1
   If EnhLstFrm.LstBox.ListCount > 0 And EnhLstFrm.LstBox.ListIndex > -1 Then EnhLstFrm.LstBox.ListIndex = 0

End Sub

Private Sub Form_Deactivate()

   TimeoutOff Timer1

End Sub

Private Sub Form_Load()
   SetChrome Me
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
                    
   If UnloadMode <> 1 Then  'anything other than unload by main prog
         Cancel = True
         LstBox.ListIndex = -1
         EnhLstFrm.Tag = ""
         EnhLstFrm.Hide
         If Not k.norefresh Then ScreenRefresh  '12Sep96 CKJ Added
      End If

End Sub

Private Sub Form_Resize()
'NB May be able to use Me.Visible instead of the tag
'22Oct97 CKJ Changed IIF to Iff

Dim X As Long

   If CmdOk.Tag = "-1" Then
      X = EnhLstFrm.ScaleHeight - LstBox.top - TxtInput.Height - 240
      If X < 240 Then X = 240
      LstBox.Height = X
      TxtInput.top = LstBox.top + X + 120
      LblInput.top = TxtInput.top
      CmdDropDown.top = TxtInput.top
      
      CmdOk.top = TxtInput.top - ((CmdOk.Height - TxtInput.Height) / 2)
      CmdCancel.top = CmdOk.top
      LstBox.Width = Iff(EnhLstFrm.ScaleWidth > 360, EnhLstFrm.ScaleWidth - 240, 120)
      EnhLstFrm.LstHdr.Width = EnhLstFrm.LstBox.Width '6Nov96 CKJ added
      
      EnhLstFrm.CmdCancel.Left = EnhLstFrm.LstBox.Left + EnhLstFrm.LstBox.Width - EnhLstFrm.CmdCancel.Width - 200
      EnhLstFrm.CmdOk.Left = EnhLstFrm.CmdCancel.Left - EnhLstFrm.CmdOk.Width - 100
      EnhLstFrm.TxtInput.Left = EnhLstFrm.CmdOk.Left - EnhLstFrm.TxtInput.Width - EnhLstFrm.CmdDropDown.Width - 200
      EnhLstFrm.CmdDropDown.Left = EnhLstFrm.TxtInput.Left + EnhLstFrm.TxtInput.Width
      EnhLstFrm.LblInput.Left = EnhLstFrm.TxtInput.Left - EnhLstFrm.LblInput.Width - 100
   End If
      
End Sub

Private Sub LstBox_Click()

   If TxtInput.Visible Then TxtInput.SetFocus

End Sub

Private Sub LstBox_DblClick()
'29Apr99 AE appended tab character to end of string, since not all entries will have one
    'cmdOK_Click
Dim temp$
Dim posn%

   temp$ = LstBox.List(LstBox.ListIndex) & Chr$(9)
   posn = InStr(temp$, Chr$(9))

   If posn > 0 Then
         temp$ = Mid$(temp$, 1, posn - 1)
         blngAllowTextBoxLookup = False
         TxtInput.Text = temp$
         blngAllowTextBoxLookup = True
         TxtInput_KeyPress 13
      End If
    

End Sub

Private Sub LstBox_MouseDown(button As Integer, Shift As Integer, X As Single, Y As Single)
Dim ans$

   If button = 2 Then
         PopMenuShow ans$, 0, 0
         If ans$ <> "" Then
               LstBox.Tag = ans$
               cmdOK_Click
            End If
      End If

End Sub

' Call this method to enable column header to be clickable to allow sorting the list by that column
' columnSortTypes   - TAB delimited string that defines the columns types used for sorting
'                     (blank entry assumes TEXT column) type can also be NUMBER, or DATE
' topItemNonSortable- If top item is non sortable then it always to appear at the top of the list e.g. <All> or <New>
' 16Apr10 XN F0065193
' 26Apr10 XN Added handling of non sortable items like <New> and <All>
' 06Sep10 XN  F0095829 EnhListBox sorting should be case insensitive
Public Sub AllowSortableHeaders(Optional columnSortTypes As String = "", Optional topItemNonSortable As Boolean = False)
    LstHdr.Enabled = True
    objColumnSortTypes = Split(columnSortTypes, TB)
    boolTopItemNonSortable = topItemNonSortable
End Sub

' Clicking the header causes the list to be sorted by that column
' 16Apr10 XN F0065193
' 26Apr10 XN Added handling of non sortable items like <New> and <All>
Private Sub LstHdr_Click()
    Dim txtHeader() As String
    Dim strHeaderColumn As String
    Dim lngColumnIndex As Long
    Dim c As Long
    Dim pos As POINTAPI
    Dim lstItems() As String
    Dim strSortType As String
    Dim strSelectedRows As String
    Dim strTopItem As String
    
    ' Get the index of the column header that was clicked (1 based index)
    lngColumnIndex = -1
    
    txtHeader = Split(LstHdr.Text, TB)
    
    GetCursorPos pos
    
    For c = LBound(txtHeader) To UBound(txtHeader)
        strHeaderColumn = strHeaderColumn + txtHeader(c)
                    
        If (TextWidth(strHeaderColumn) + Me.Left) > (pos.x * Screen.TwipsPerPixelX) Then
            lngColumnIndex = c + 1
            Exit For
        End If
    Next c
    
    
    ' If valid column index then sort list by that column
    If lngColumnIndex <> -1 Then
        LstBox.Visible = False
        
        ' If the item at top of list is not sortable, then remove so that it does form part of this sorting
        If boolTopItemNonSortable Then
            strTopItem = LstBox.List(0)
            If LstBox.Selected(0) Then strSelectedRows = LstBox.List(0)
            LstBox.RemoveItem (0)
        End If
        
        ' Move the list contents to a separate array (also store the selected row)
        ReDim lstItems(1 To LstBox.ListCount) As String
        For c = 0 To (LstBox.ListCount - 1)
            lstItems(c + 1) = LstBox.List(c)
            
            If LstBox.Selected(c) Then strSelectedRows = LstBox.List(c)
        Next c
        
        ' Get the column type for sorting
        strSortType = "TEXT"
        If lngColumnIndex < UBound(objColumnSortTypes) Then
            strSortType = objColumnSortTypes(lngColumnIndex)
        End If
        
        ' Sort the list
        ' 06Sep10 XN  F0095829 EnhListBox sorting should be case insensitive
        shellsort lstItems, LstBox.ListCount, lngColumnIndex, TB, strSortType, True
        ' End of 06Sep10 XN  F0095829
        
        ' Update the list with the new sort order (and reset selected column)
        If intLastCol <> lngColumnIndex Then
            ' Ascending
            For c = 0 To (LstBox.ListCount - 1)
                LstBox.List(c) = lstItems(c + 1)
                LstBox.Selected(c) = (LstBox.List(c) = strSelectedRows)
            Next c
            
            intLastCol = lngColumnIndex
        Else
            ' Descending
            For c = 0 To (LstBox.ListCount - 1)
                LstBox.List(c) = lstItems(LstBox.ListCount - c)
                LstBox.Selected(c) = (LstBox.List(c) = strSelectedRows)
            Next c
            
            intLastCol = 0
        End If
        
        ' If the item at top of list is not sortable, then it was deleted at the start of this process so readd
        If boolTopItemNonSortable Then
            LstBox.AddItem strTopItem, 0
            LstBox.Selected(0) = (LstBox.List(0) = strSelectedRows)
            If Not LstBox.Selected(0) Then LstBox.TopIndex = LstBox.TopIndex + 1
        End If
        
        LstBox.Visible = True
    End If
End Sub

Private Sub Timer1_Timer()
   
   If TimedOut() Then cmdCancel_Click 'assume Esc pressed
   
End Sub

Private Sub TxtInput_Change()
'19Jan98 EAC Use SendMessage and LB_FINDSTRING to find matching entry in LstBox

Dim tofind$
Dim nIndex%

    If blngAllowTextBoxLookup Then
        tofind$ = TxtInput.Text
        nIndex = SendMessage(LstBox.Hwnd, LB_FINDSTRING, -1, ByVal tofind$)
        
        If nIndex < 0 Then
              LstBox.ListIndex = -1
        Else
              'Make matching item the selected one
              LstBox.ListIndex = nIndex
        End If
    End If
End Sub

Private Sub TxtInput_GotFocus()

Dim temp$, posn%
          
   temp$ = LstBox.List(LstBox.ListIndex)
   
   If Trim$(temp$) = "" Then Exit Sub
   posn = InStr(temp$, Chr$(9))

   blngAllowTextBoxLookup = False
   If posn > 0 Then
         temp$ = Mid$(temp$, 1, posn - 1)
         TxtInput.Text = Trim$(temp$)
   Else
         TxtInput.Text = Trim$(temp$)
   End If
   blngAllowTextBoxLookup = True

   TxtInput.SelStart = 0
   TxtInput.SelLength = Len(temp$)

End Sub

Private Sub TxtInput_KeyPress(KeyAscii As Integer)

   Select Case KeyAscii
      Case 13  'Enter
         If LstBox.ListIndex = -1 Then
               LstBox.Tag = TxtInput.Text
            Else
               LstBox.Tag = LstBox.List(LstBox.ListIndex)
            End If
         
         Me.Hide
         If Not k.norefresh Then ScreenRefresh  '12Sep96 CKJ Added
         
      Case 27  'Esc
         Me.Hide
         LstBox.Tag = ""
         LstBox.ListIndex = -1
      Case Else
   End Select

End Sub

Private Sub TxtInput_KeyUp(KeyCode As Integer, Shift As Integer)
'26Jun97 CKJ Set the Shift-F1 using CmdDropDown.Visible instead of tag

Dim ans$, temp$, supcode$, supdesc$
Dim posn%

   If KeyCode = KEY_F1 And Shift = SHIFT_MASK Then
         If CmdDropDown.Visible Then
               ChooseSupplier supcode$, supdesc$
               supcode$ = Trim$(supcode$)
               If supcode$ <> "" Then
                     blngAllowTextBoxLookup = False
                     TxtInput.Text = supcode$
                     blngAllowTextBoxLookup = True
                     LstBox.ListIndex = -1
                  End If
            Else
               PopMenuShow ans$, 0, 0 '##
               If ans$ <> "" Then
                     LstBox.Tag = ans$
                     cmdOK_Click
                  End If
            End If
      End If

   If (KeyCode = 37 Or KeyCode = 38) And Shift = 0 Then  'UP Arrow
         If LstBox.ListIndex - 1 >= 0 Then
               LstBox.ListIndex = LstBox.ListIndex - 1
               temp$ = LstBox.List(LstBox.ListIndex)
               posn% = InStr(temp$, TB)
               
               blngAllowTextBoxLookup = False
               If posn Then
                     temp$ = Mid$(temp$, 1, posn - 1)
                     TxtInput.Text = Trim$(temp$)
               Else
                     TxtInput.Text = Trim$(temp$)
               End If
               blngAllowTextBoxLookup = True
            End If
         TxtInput.SelStart = 0
         TxtInput.SelLength = Len(TxtInput.Text)
      End If

   If (KeyCode = 39 Or KeyCode = 40) And Shift = 0 Then  'DOWN Arrow
         If LstBox.ListIndex < (LstBox.ListCount - 1) Then
               LstBox.ListIndex = LstBox.ListIndex + 1
               temp$ = LstBox.List(LstBox.ListIndex)
               posn% = InStr(temp$, TB)
               
               blngAllowTextBoxLookup = False
               If posn Then
                     temp$ = Mid$(temp$, 1, posn - 1)
                     TxtInput.Text = Trim$(temp$)
               Else
                     TxtInput.Text = Trim$(temp$)
               End If
               blngAllowTextBoxLookup = True
            End If
         TxtInput.SelStart = 0
         TxtInput.SelLength = Len(TxtInput.Text)
      End If

End Sub

