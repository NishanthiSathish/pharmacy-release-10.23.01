VERSION 5.00
Begin VB.Form frmSearch 
   Appearance      =   0  'Flat
   BackColor       =   &H80000005&
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Search and Replace Across Wards"
   ClientHeight    =   7545
   ClientLeft      =   1935
   ClientTop       =   2865
   ClientWidth     =   7875
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
   Icon            =   "SAR.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   7545
   ScaleWidth      =   7875
   ShowInTaskbar   =   0   'False
   Begin VB.Frame fraSearchOld 
      BackColor       =   &H00C0C0C0&
      Height          =   1905
      Left            =   -15
      TabIndex        =   0
      Top             =   -90
      Width           =   7900
      Begin VB.CommandButton cmdSearchItemOld 
         Caption         =   "Search"
         Height          =   315
         Left            =   4560
         TabIndex        =   7
         Top             =   1365
         Width           =   1215
      End
      Begin VB.TextBox txtSearchItemOld 
         Appearance      =   0  'Flat
         Height          =   315
         Left            =   3960
         MaxLength       =   7
         TabIndex        =   5
         Top             =   240
         Width           =   1845
      End
      Begin VB.Label lblItemOld 
         Height          =   915
         Left            =   720
         TabIndex        =   6
         Top             =   765
         Width           =   5535
      End
      Begin VB.Label Label1 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Select product to be &updated"
         ForeColor       =   &H00000000&
         Height          =   195
         Left            =   255
         TabIndex        =   4
         Top             =   300
         Width           =   3555
      End
   End
   Begin VB.Frame fraSearchNew 
      BackColor       =   &H00C0C0C0&
      Height          =   1980
      Left            =   -15
      MousePointer    =   1  'Arrow
      TabIndex        =   1
      Top             =   1600
      Width           =   7900
      Begin VB.TextBox txtSearchItemNew 
         Appearance      =   0  'Flat
         Height          =   300
         Left            =   3930
         TabIndex        =   9
         Top             =   315
         Width           =   1815
      End
      Begin VB.CommandButton cmdSearchItemNew 
         Caption         =   "Search"
         Height          =   315
         Left            =   4560
         TabIndex        =   11
         Top             =   1440
         Width           =   1200
      End
      Begin VB.Label lblItemNew 
         Height          =   915
         Left            =   720
         TabIndex        =   10
         Top             =   840
         Width           =   5505
      End
      Begin VB.Label Label3 
         BackStyle       =   0  'Transparent
         Caption         =   "Select &new product    (Optional)"
         Height          =   315
         Left            =   255
         TabIndex        =   8
         Top             =   360
         Width           =   3135
      End
   End
   Begin VB.Frame fraDetails 
      BackColor       =   &H00C0C0C0&
      Height          =   3255
      Left            =   -15
      TabIndex        =   2
      Top             =   3450
      Width           =   7900
      Begin VB.CheckBox ChkNewData 
         Caption         =   "New Stock &Level"
         Enabled         =   0   'False
         Height          =   255
         Index           =   1
         Left            =   180
         TabIndex        =   17
         Top             =   1080
         Width           =   2160
      End
      Begin VB.CheckBox ChkNewData 
         BackColor       =   &H8000000A&
         Caption         =   "New &Pre-pack Status"
         Enabled         =   0   'False
         Height          =   315
         Index           =   5
         Left            =   180
         TabIndex        =   23
         Top             =   2160
         Width           =   2160
      End
      Begin VB.CheckBox ChkNewData 
         Caption         =   "New &Barcode"
         Enabled         =   0   'False
         Height          =   255
         Index           =   4
         Left            =   180
         TabIndex        =   21
         Top             =   1800
         Width           =   2160
      End
      Begin VB.CheckBox ChkNewData 
         Caption         =   "New Product Code"
         Enabled         =   0   'False
         Height          =   255
         Index           =   3
         Left            =   180
         TabIndex        =   13
         TabStop         =   0   'False
         Top             =   360
         Width           =   2160
      End
      Begin VB.CheckBox ChkNewData 
         Caption         =   "New Pack &Size"
         Enabled         =   0   'False
         Height          =   255
         Index           =   2
         Left            =   180
         TabIndex        =   19
         Top             =   1440
         Width           =   2160
      End
      Begin VB.CheckBox ChkNewData 
         Caption         =   "New &Description"
         Enabled         =   0   'False
         Height          =   255
         Index           =   0
         Left            =   180
         TabIndex        =   15
         Top             =   720
         Width           =   2160
      End
      Begin VB.TextBox TxtNewData 
         Appearance      =   0  'Flat
         Height          =   285
         Index           =   0
         Left            =   2400
         MaxLength       =   56
         TabIndex        =   16
         Top             =   720
         Width           =   5355
      End
      Begin VB.TextBox TxtNewData 
         Appearance      =   0  'Flat
         Height          =   285
         Index           =   2
         Left            =   2400
         MaxLength       =   6
         TabIndex        =   20
         Top             =   1440
         Width           =   2600
      End
      Begin VB.TextBox TxtNewData 
         Appearance      =   0  'Flat
         Height          =   285
         Index           =   3
         Left            =   2400
         TabIndex        =   14
         TabStop         =   0   'False
         Top             =   360
         Width           =   2600
      End
      Begin VB.TextBox TxtNewData 
         Appearance      =   0  'Flat
         Height          =   285
         Index           =   1
         Left            =   2400
         MaxLength       =   6
         TabIndex        =   18
         Top             =   1080
         Width           =   2600
      End
      Begin VB.OptionButton OptPrePack 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         Caption         =   "None"
         Enabled         =   0   'False
         ForeColor       =   &H00000000&
         Height          =   315
         Index           =   0
         Left            =   2400
         TabIndex        =   24
         Top             =   2160
         Width           =   2355
      End
      Begin VB.OptionButton OptPrePack 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         Caption         =   "Pre-pack"
         Enabled         =   0   'False
         ForeColor       =   &H80000008&
         Height          =   315
         Index           =   1
         Left            =   2400
         TabIndex        =   25
         TabStop         =   0   'False
         Top             =   2450
         Width           =   2355
      End
      Begin VB.OptionButton OptPrePack 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         Caption         =   "Bulk"
         Enabled         =   0   'False
         ForeColor       =   &H80000008&
         Height          =   315
         Index           =   2
         Left            =   2400
         TabIndex        =   26
         TabStop         =   0   'False
         Top             =   2740
         Width           =   2355
      End
      Begin VB.TextBox TxtNewData 
         Appearance      =   0  'Flat
         Height          =   285
         Index           =   4
         Left            =   2400
         MaxLength       =   13
         TabIndex        =   22
         Top             =   1800
         Width           =   2600
      End
      Begin VB.Label Label2 
         Caption         =   "New Product Code"
         Height          =   255
         Left            =   450
         TabIndex        =   12
         Top             =   375
         Width           =   1755
      End
   End
   Begin VB.Frame fraBottom 
      BackColor       =   &H00C0C0C0&
      Height          =   975
      Left            =   -15
      TabIndex        =   3
      Top             =   6580
      Width           =   7900
      Begin VB.CommandButton cmdReplace 
         Appearance      =   0  'Flat
         Caption         =   "&Replace"
         Enabled         =   0   'False
         Height          =   435
         Left            =   2130
         TabIndex        =   27
         Top             =   300
         Width           =   1335
      End
      Begin VB.CommandButton CmdExit 
         Appearance      =   0  'Flat
         Cancel          =   -1  'True
         Caption         =   "E&xit"
         Height          =   435
         Left            =   4770
         TabIndex        =   28
         Top             =   300
         Width           =   1335
      End
   End
End
Attribute VB_Name = "frmSearch"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'--------------------------------------- SAR Search And Replace Ward Stock (frmSearch)-----------------------------------
'17Oct97 EAC added Alt Key support
'26Mar98 EAC CmdSearch_Click: Preprint passes through "~" instead of "" if update of Prepack is selected
'28Jun98 CmdSearch_Click: CFY/EAC Code to stop user changing the NSV code to a code that doesn't exist in the drug file
'11Jan02 TH  CmdSearch_Click: Added new inputs for barcode (#52902)
'11Jan02 TH  TxtSearch_KeyPress: Added new control for barcode (#52902)
'19Mar10 CKJ Overhaul - separate lookups for each drug code, new-look screen, more validation   (RCN P0007 F0052571)

Option Explicit
DefBool A-Z       '22Jan10 CKJ

Dim dNew As DrugParameters
Dim dNewSet As Boolean           'true when a second drug has been selected

Private Sub ChkNewData_Click(Index As Integer)

Dim iLoop As Integer
Dim dlocal As DrugParameters
Dim Enabled As Boolean
Dim sTemp As String

   Select Case Index
      Case 0, 1, 2, 4      'text boxes
         Enabled = TrueFalse(ChkNewData(Index).Value)
         TxtNewData(Index).BackColor = Iff(Enabled, &HFFFFFF, &H8000000F)
         SetTextBoxReadOnly TxtNewData(Index), Not Enabled
         TxtNewData(Index).tabstop = Enabled
         
         If Enabled Then
            If dNewSet Then
               LSet dlocal = dNew
            Else
               LSet dlocal = d
            End If
            
            Select Case Index
               Case 0      'description
                  'sTemp = trimz$(Iff(Len(trimz$(dlocal.storesdescription)), dlocal.storesdescription, dlocal.Description))     XN 4Jun15 98073 New local stores description
                                  sTemp = trimz$(dlocal.DrugDescription)
                  plingparse sTemp, "!"
                  TxtNewData(Index).text = sTemp
               Case 1      'stock level
                  'no action
               Case 2      'pack size
                  TxtNewData(Index).text = trimz$(dlocal.convfact)
               Case 4      'barcode
                  TxtNewData(Index).text = trimz$(dlocal.barcode)
               End Select
      
            SetFocusTo TxtNewData(Index)
         End If
                  
      Case 5               'option buttons
         For iLoop = 0 To 2
            OptPrePack(iLoop).Enabled = TrueFalse(ChkNewData(Index).Value)
         Next
         
         If OptPrePack(2).Value = True Then
            SetFocusTo OptPrePack(2)
         ElseIf OptPrePack(1).Value = True Then
            SetFocusTo OptPrePack(1)
         Else
            SetFocusTo OptPrePack(0)
         End If
      End Select
      
   cmdReplace.Enabled = False
   For iLoop = 0 To 5
      If ChkNewData(iLoop).Value Then
         cmdReplace.Enabled = True
         Exit For
      End If
   Next
   
End Sub

Private Sub ChkNewData_KeyPress(Index As Integer, KeyAscii As Integer)
   
   Select Case KeyAscii
      Case 13
         KeyAscii = 0
         ChkNewData(Index).Value = 1 - ChkNewData(Index).Value       'toggle as if [space] was pressed
   End Select

End Sub

Private Sub cmdExit_Click()

    Unload frmSearch
    
End Sub

Private Sub cmdSearchItemNew_Click()

   SearchItemNew
   
End Sub

Private Sub cmdSearchItemOld_Click()
   
   SearchItemOld

End Sub

Private Sub Form_Load()

   SetChrome Me
   CentreForm frmSearch
   
   SetScreen 0, False

End Sub

Private Sub TxtNewData_GotFocus(Index As Integer)

   If Index = 3 Then
      SendKeys "{tab}"
   ElseIf ChkNewData(Index).Value = 1 Then       'text box enabled
      Select Case Index
         Case 0, 2, 4 'description packsize barcode
            TxtNewData(Index).SelStart = Len(TxtNewData(Index).text)
            TxtNewData(Index).SelLength = 0
         Case Else
            TxtNewData(Index).SelStart = 0
            TxtNewData(Index).SelLength = Len(TxtNewData(Index).text)
         End Select
   Else
      SendKeys "{tab}"     'slide past readonly txt boxes
   End If
      
End Sub

Private Sub TxtNewData_KeyPress(Index As Integer, KeyAscii As Integer)

   Select Case KeyAscii
      Case 13
         KeyAscii = 0
         SendKeys "{tab}"
   End Select

End Sub

Sub SearchItemOld()

Dim found As Integer
Dim sTemp As String
   
   findrdrug (txtSearchItemOld.text), 1, d, 0, found, False, False, False      '22Mar10 CKJ set stores=1 to allow all items to be searched

   If found Then
      txtSearchItemOld.text = d.SisCode
      
      sTemp = d.DrugDescription         'sTemp = GetStoresDescription()  XN 4Jun15 98073 New local stores description
      plingparse sTemp, "!"
      lblItemOld.Caption = sTemp & crlf & _
                           "Pack size    " & Trim$(d.convfact) & " " & Trim$(d.PrintformV) & crlf & _
                           "Barcode      " & d.barcode & Space$(6) & "In Use    " & d.inuse & crlf & _
                           "Code           " & d.SisCode & Space$(16) & "Stores   " & d.sisstock

      TxtNewData(3) = d.SisCode
               
      SetScreen 1, True
      SetScreen 2, True
      SetFocusTo txtSearchItemNew
      
   Else
      SetScreen 0, False            'turn everything off
      SetFocusTo txtSearchItemOld
   End If

End Sub

Sub SearchItemNew()

Dim found As Integer
Dim iLoop As Integer
Dim sTemp As String
            
   findrdrug (txtSearchItemNew.text), True, dNew, 0, found, False, False, False

   If found Then
      txtSearchItemNew.text = dNew.SisCode
      
      'sTemp = Iff(Len(trimz$(dNew.storesdescription)), dNew.storesdescription, dNew.Description) XN 4Jun15 98073 New local stores description
          sTemp = dNew.DrugDescription
      plingparse sTemp, "!"
      lblItemNew.Caption = sTemp & crlf & _
                           "Pack size    " & Trim$(dNew.convfact) & " " & Trim$(dNew.PrintformV) & crlf & _
                           "Barcode      " & dNew.barcode & Space$(6) & "In Use    " & dNew.inuse & crlf & _
                           "Code           " & dNew.SisCode & Space$(16) & "Stores   " & dNew.sisstock

      For iLoop = 0 To 4
         TxtNewData(iLoop).text = ""
      Next
            
      For iLoop = 0 To 5
         ChkNewData(iLoop).Value = 0
      Next
            
      For iLoop = 0 To 2
         OptPrePack(iLoop).Value = False
      Next
            
      TxtNewData(3) = dNew.SisCode
      ChkNewData(3).Value = 1
      dNewSet = True
      
      ChkNewData(0).Value = 1       'description
      ChkNewData(2).Value = 1       'pack size
      ChkNewData(4).Value = 1       'barcode
            
      SetFocusTo ChkNewData(1)      'description check box
   Else
      dNewSet = False
   End If

End Sub

Sub SetScreen(ByVal ScreenElement As Integer, ByVal Enable As Boolean)

Dim iLoop As Integer
Dim enableTxt As Boolean

   Select Case ScreenElement
      Case 0                     'all except SearchItemOld
         SetScreen 1, Enable     'Search Item New
         SetScreen 2, Enable     'Check boxes
         SetScreen 3, Enable     'Text boxes & option buttons
                  
         cmdSearchItemNew.Enabled = Enable
         cmdReplace.Enabled = Enable
         
      Case 1                     'Search Item New
         txtSearchItemNew.BackColor = Iff(Enable, &HFFFFFF, &H8000000F)
         SetTextBoxReadOnly txtSearchItemNew, Not Enable
      
      Case 2                     'Check boxes
         For iLoop = 0 To 5
            ChkNewData(iLoop).Enabled = Iff(iLoop = 3, False, Enable)      '3 is new NSV code
         Next
         ChkNewData(3).Width = Iff(Enable, 270, 2160)

      Case 3                     'Text Boxes and Option buttons
         For iLoop = 0 To 4
            enableTxt = Iff(iLoop = 3, False, Enable)                      '3 is new NSV code, always 'greyed out'
            SetTextBoxReadOnly TxtNewData(iLoop), Not (enableTxt)
            TxtNewData(iLoop).BackColor = Iff(enableTxt, &HFFFFFF, &H8000000F)
         Next
         TxtNewData(3).BackColor = Me.BackColor
         
         For iLoop = 0 To 2
            OptPrePack(iLoop).Enabled = Enable
         Next
      
      End Select
      
End Sub

Private Sub txtSearchItemNew_Change()

   cmdSearchItemNew.Enabled = (Len(Trim(txtSearchItemNew.text)) > 0)
         
End Sub

Private Sub txtSearchItemNew_GotFocus()

    txtSearchItemNew.SelStart = 0
    txtSearchItemNew.SelLength = Len(txtSearchItemNew.text)

End Sub

Private Sub txtSearchItemNew_KeyPress(KeyAscii As Integer)

   Select Case KeyAscii
      Case 13
         KeyAscii = 0
         If Len(Trim(txtSearchItemNew.text)) Then
            SearchItemNew
         Else
            SetFocusTo ChkNewData(0)
         End If
      Case Else
   End Select

End Sub

Private Sub txtSearchItemOld_GotFocus()

    txtSearchItemOld.SelStart = 0
    txtSearchItemOld.SelLength = Len(txtSearchItemOld.text)

End Sub

Private Sub txtSearchItemOld_KeyPress(KeyAscii As Integer)
   
   Select Case KeyAscii
      Case 13
         KeyAscii = 0
         SearchItemOld
      Case Else
   End Select

End Sub
'04Sep12 removed - moved to StoresPSO to support addition of WLabelIO
''Sub SetFocusTo(ctrl As Control)
''
''   On Error Resume Next
''   If ctrl.Visible And ctrl.Enabled Then
''      ctrl.SetFocus
''   End If
''   On Error GoTo 0
''
''End Sub

Private Sub CmdReplace_Click()
'26Mar98 EAC Preprint passes through "~" instead of "" if update of Prepack is selected
'28Jun98 CFY/EAC Code to stop user changing the NSV code to a code that doesn't exist in the drug file
'11Jan02 TH  Added new inputs for barcode (#52902)
'22Jan10 CKJ corrected: swapped chk boxes so 4 does barcode & 5 does prepack

Dim allempty%, loopvar%
Dim searchcatno$, NewCatno$, NewDesc$, newstcklvl$, NewPackSize$, newprepak$, ans$
Dim NewBarcode As String  '11Jan02 TH
Dim foundPtr As Long
Dim msg As String

   msg = ""
   searchcatno$ = UCase$(txtSearchItemOld.text)
   
   NewDesc = ""
   newstcklvl = Nul     'only these two fields can be replaced with blank
   NewPackSize = Nul    'so use Nul to distinguish between set to "" and not set
   NewCatno = ""
   NewBarcode = ""
   newprepak = ""
   
   allempty = True
   For loopvar = 0 To 5 '11Jan02 TH increased to 5 (#52902)
      If ChkNewData(loopvar).Value Then allempty = False: Exit For
   Next
   If allempty Then msg = msg & "No fields selected for updating" & crlf
 
   If ChkNewData(0).Value Then
      NewDesc$ = Trim$(TxtNewData(0).text)
      If NewDesc = "" Then msg = msg & "Description cannot be blank" & crlf
   End If
   
   If ChkNewData(1).Value Then
      newstcklvl$ = Trim$(TxtNewData(1).text)
      If Not IsDigits(newstcklvl) Then msg = msg & "Stock level must contain digits only (no decimals)" & crlf
   End If
   
   If ChkNewData(2).Value Then
      NewPackSize$ = Trim$(TxtNewData(2).text)
      If Not IsDigits(NewPackSize) Then msg = msg & "Pack size must contain digits only (no decimals)" & crlf
   End If
   
   If ChkNewData(3).Value Then NewCatno$ = Trim$(TxtNewData(3).text)
   
   If ChkNewData(4).Value Then
      NewBarcode = Trim$(TxtNewData(4).text)   '11Jan02 TH (#52902)
      Select Case Len(NewBarcode)
         Case 0:     msg = msg & "Barcode cannot be blank" & crlf
         Case 8, 13, 14: If Not IsDigits(NewBarcode) Then msg = msg & "Barcode must contain digits only" & crlf
         Case Else:  msg = msg & "Barcode must be 8, 13 or 14 digits" & crlf
         End Select
   End If
   
   If ChkNewData(5).Value Then
      If OptPrePack(0).Value Then
         newprepak$ = "~"          '26Mar98 EAC changed from "" to "~"
      ElseIf OptPrePack(1).Value Then
         newprepak$ = "P"
      ElseIf OptPrePack(2).Value Then
         newprepak$ = "B"
      Else
         msg = msg & "Pre-pack status has not been selected" & crlf
      End If
   End If
   
   If Len(msg) Then
      popmessagecr "!Update", crlf & msg
   
   Else          '19Mar10 CKJ Removed confirm dialog as there are still steps before it begins the search
      
      sarallSQL 1, searchcatno$, NewDesc$, NewPackSize$, newstcklvl$, NewCatno$, newprepak$, NewBarcode
      
      SetFocusTo CmdExit
   End If

End Sub


