VERSION 5.00
Begin VB.Form Barcodes 
   Appearance      =   0  'Flat
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Supplementary Barcodes"
   ClientHeight    =   6690
   ClientLeft      =   1860
   ClientTop       =   1065
   ClientWidth     =   5295
   ControlBox      =   0   'False
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
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6690
   ScaleWidth      =   5295
   Begin VB.ListBox lstBCR 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      ForeColor       =   &H00000000&
      Height          =   2565
      Left            =   120
      Sorted          =   -1  'True
      TabIndex        =   4
      TabStop         =   0   'False
      Top             =   3240
      Width           =   5040
   End
   Begin VB.TextBox txtBCR 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      ForeColor       =   &H00000000&
      Height          =   285
      Left            =   240
      TabIndex        =   1
      Top             =   2160
      Width           =   1920
   End
   Begin VB.CommandButton cmdExit 
      Appearance      =   0  'Flat
      BackColor       =   &H00808000&
      Caption         =   "E&xit"
      Height          =   420
      Left            =   4200
      TabIndex        =   7
      Top             =   5940
      Width           =   960
   End
   Begin VB.CommandButton cmdDel 
      Appearance      =   0  'Flat
      BackColor       =   &H00808000&
      Caption         =   "&Delete"
      Height          =   420
      Left            =   1680
      TabIndex        =   6
      Top             =   6000
      Visible         =   0   'False
      Width           =   960
   End
   Begin VB.TextBox txtSupp 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      ForeColor       =   &H00000000&
      Height          =   285
      Left            =   2520
      TabIndex        =   3
      Top             =   2160
      Visible         =   0   'False
      Width           =   960
   End
   Begin VB.CommandButton cmdAdd 
      Appearance      =   0  'Flat
      BackColor       =   &H00808000&
      Caption         =   "&Add"
      Height          =   420
      Left            =   120
      TabIndex        =   5
      Top             =   6000
      Visible         =   0   'False
      Width           =   1080
   End
   Begin VB.Label lblInstructions 
      Height          =   1455
      Left            =   120
      TabIndex        =   9
      Top             =   120
      Width           =   4935
   End
   Begin VB.Label Label1 
      Caption         =   "Currently available Secondary Barcodes"
      Height          =   375
      Left            =   120
      TabIndex        =   8
      Top             =   2760
      Width           =   5055
   End
   Begin VB.Label lblBCR 
      Appearance      =   0  'Flat
      BackColor       =   &H00808000&
      BackStyle       =   0  'Transparent
      Caption         =   "&Barcode"
      ForeColor       =   &H00000000&
      Height          =   240
      Left            =   240
      TabIndex        =   0
      Top             =   1920
      Width           =   1440
   End
   Begin VB.Label lblSupp 
      Appearance      =   0  'Flat
      BackColor       =   &H00808000&
      BackStyle       =   0  'Transparent
      Caption         =   "&Supplier"
      ForeColor       =   &H00000000&
      Height          =   240
      Left            =   2520
      TabIndex        =   2
      Top             =   1920
      Visible         =   0   'False
      Width           =   960
   End
End
Attribute VB_Name = "Barcodes"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------------------------------------------------------------
'                        Supplementary Barcodes Editor
'14Mar95 CKJ Written
' 7Mar97 CKJ Modified to use tabstops in listbox
'
'mods wanted
'/exit without needing Alt key eg esc when boxes empty
'-----------------------------------------------------------------------------
Option Explicit  '01Jun02 All/CKJ
DefInt A-Z
Const posSupp = 15

'                   <Tab>     <Tab>
'list "3254789526854     10020     12-12-94"

Private Sub CmdAdd_Click()
'New valid barcode to be added

Dim strNewitem   As String   '01Jun02 All/CKJ
Dim lngSiteProductDataAlias As Long

   If lstBCR.ListIndex = -1 Then
         Select Case Len(txtBCR.text)
            Case 8, 13
               strNewitem = pad$((txtBCR.text), 13) '& TB
               'newitem$ = newitem$ + pad$((txtSupp.text), 5) & TB
               'newitem$ = newitem$ + Mid$(date$, 4, 3) + Left$(date$, 3) + Right$(date$, 2)
               lngSiteProductDataAlias = AddAlternativeBarcode(d.SiteProductDataID, strNewitem)
               lstBCR.AddItem strNewitem, lstBCR.ListCount
               lstBCR.ItemData(Barcodes.lstBCR.ListCount - 1) = lngSiteProductDataAlias
            
               lstBCR.ListIndex = lstBCR.ListCount - 1
               cmdAdd.Visible = False
               cmdDel.Visible = True
               lstBCR.Refresh
               Barcodes.Tag = "-1"
            End Select
      End If

End Sub

Private Sub cmdDel_Click()
'Delete highlighted line
Dim lngResult As Long

   If lstBCR.ListIndex > -1 Then
         lngResult = DeleteAlternativeBarcode(lstBCR.ItemData(lstBCR.ListIndex))
         lstBCR.RemoveItem lstBCR.ListIndex
         lstBCR.ListIndex = -1
         UpdateTxt
         lstBCR.Refresh
         Barcodes.Tag = "-1"
      End If
                       
End Sub

Private Sub CmdExit_Click()

   Barcodes.Hide

End Sub

Private Sub cmdHelp_Click()

   'formhelp "", 2000  '!!**
   SendKeys "{F1}"
   txtBCR.SetFocus

End Sub

Private Sub ListUpDown(KeyCode As Integer, Shift As Integer)

   If lstBCR.ListCount > 0 And Shift = 0 Then
         Select Case KeyCode
            Case 40                       'csr down
               If lstBCR.ListIndex < lstBCR.ListCount - 1 Then
                     UpdateSupp
                     lstBCR.ListIndex = lstBCR.ListIndex + 1
                  End If
            Case 38                       'csr up
               If lstBCR.ListIndex > 0 Then
                     UpdateSupp
                     lstBCR.ListIndex = lstBCR.ListIndex - 1
                  End If
            End Select
      End If

   If KeyCode = 40 Then KeyCode = 0

End Sub

Private Sub Form_Load()
Dim strMsg As String
SetChrome Me

strMsg = "To Add New Barcode : Enter new alternative barcodes of 8 or 13 character length and press Add. " & crlf & _
"To Delete Existing Barcode : Highlight line in the list and press Delete"

lblInstructions.Caption = strMsg
End Sub

Private Sub lstBCR_Click()
'Warning: this event fires EVERY time the highlight bar is set or moved,
'         not just with a mouse event.

   If lstBCR.ListIndex > -1 Then
   cmdAdd.Visible = False '01Apr07 TH
   UpdateTxt
   End If

End Sub

Private Sub txtBCR_Change()

Dim xcount As Integer      '01Jun02 All/CKJ

   For xcount = 1 To lstBCR.ListCount
      If RTrim$(txtBCR.text) = RTrim$(Left$(lstBCR.List(xcount - 1), 13)) Then
            lstBCR.ListIndex = xcount - 1
            cmdDel.Visible = True
            Exit For
         End If
   Next
   If xcount > lstBCR.ListCount Then
         lstBCR.ListIndex = -1
         cmdDel.Visible = False
         Select Case Len(txtBCR.text)
            Case 8, 13: cmdAdd.Visible = True
            Case Else: cmdAdd.Visible = False
            End Select
      End If

End Sub

Private Sub txtBCR_KeyPress(Keyascii As Integer)

   Select Case Keyascii
      Case 27     'Esc
         Keyascii = 0
         If lstBCR.ListIndex = -1 Then
                  CmdExit_Click
               Else
                  lstBCR.ListIndex = -1
               End If
      Case 8, 127 'BS, DEL
         '
      Case 48 To 57   '0-9
         If Len(txtBCR.text) >= 13 Then
               Beep
               Keyascii = 0
            End If
      Case 13     'CR
         Keyascii = 0
         If cmdAdd.Visible Then
            CmdAdd_Click
         End If
         
         'txtSupp.SetFocus
      Case Else
         Keyascii = 0
      End Select

End Sub

Private Sub txtBCR_KeyUp(KeyCode As Integer, Shift As Integer)

   ListUpDown KeyCode, Shift

End Sub

Private Sub txtSupp_KeyPress(Keyascii As Integer)

   Keyascii = Asc(UCase$(Chr$(Keyascii)))

   Select Case Keyascii
      Case 27     'Esc
         Keyascii = 0
         If lstBCR.ListIndex = -1 Then
                  CmdExit_Click
               Else
                  lstBCR.ListIndex = -1
               End If
      Case 8, 127  'BS, DEL
         '
      Case 48 To 57, 65 To 90     '0-9 A-Z
         If Len(txtSupp.text) >= 5 Then
               Beep
               Keyascii = 0
            End If
      Case 13      'CR
         Keyascii = 0
         If cmdAdd.Visible Then
               CmdAdd_Click
            Else
               UpdateSupp
               txtBCR.SetFocus
            End If
      Case Else
         Keyascii = 0
      End Select

End Sub

Private Sub txtSupp_KeyUp(KeyCode As Integer, Shift As Integer)

   ListUpDown KeyCode, Shift

End Sub

Private Sub UpdateSupp()
'Check that highlighted line has same supp code as txtSupp, update if not.
'No action if no line highlighted.

Dim tmp$    '01Jun02 All/CKJ

''   If lstBCR.ListIndex > -1 Then
''         If txtSupp.text <> RTrim$(Mid$(lstBCR.List(lstBCR.ListIndex), posSupp, 5)) Then
''               tmp$ = lstBCR.List(lstBCR.ListIndex)
''               Mid$(tmp$, posSupp, 5) = txtSupp.text + "     "
''               lstBCR.List(lstBCR.ListIndex) = tmp$
''               Barcodes.Tag = "-1"
''            End If
''      End If

End Sub

Private Sub UpdateTxt()
'Given a change such as add, delete, click on list box or csr up/down
'update the text boxes. Set focus to txtBCR

   If lstBCR.ListIndex > -1 Then
         txtBCR.text = RTrim$(Left$(lstBCR.List(lstBCR.ListIndex), 13))
         'txtSupp.text = RTrim$(Mid$(lstBCR.List(lstBCR.ListIndex), posSupp, 5))
      Else
         txtBCR.text = ""
         'txtSupp.text = ""
      End If
   txtBCR.SetFocus

End Sub

