VERSION 5.00
Begin VB.Form frmLogView 
   Caption         =   "Log Viewer"
   ClientHeight    =   8460
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   9435
   Icon            =   "frmLogView.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   8460
   ScaleWidth      =   9435
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton cmdCancel 
      Caption         =   "&Cancel"
      Height          =   375
      Left            =   7920
      TabIndex        =   53
      Top             =   7800
      Width           =   1095
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   375
      Left            =   6480
      TabIndex        =   52
      Top             =   7800
      Width           =   1215
   End
   Begin VB.Frame fraCombined 
      Caption         =   "Combined Log Criteria"
      Height          =   3255
      Left            =   3360
      TabIndex        =   49
      Top             =   4080
      Width           =   5655
      Begin VB.TextBox txtCombinedBatchNumber 
         Height          =   285
         Left            =   2280
         TabIndex        =   50
         Top             =   840
         Width           =   1935
      End
      Begin VB.Label lblCombinedBatch 
         Caption         =   "Batch Number"
         Height          =   375
         Left            =   360
         TabIndex        =   51
         Top             =   840
         Width           =   1695
      End
   End
   Begin VB.Frame FraTrans 
      Caption         =   "Transaction Log Criteria"
      Height          =   3255
      Left            =   3360
      TabIndex        =   32
      Top             =   4080
      Width           =   5655
      Begin VB.TextBox txtInternalOrderNumber 
         Height          =   285
         Left            =   4080
         MaxLength       =   10
         TabIndex        =   57
         Top             =   2760
         Width           =   1335
      End
      Begin VB.TextBox txtNHNumber 
         Height          =   285
         Left            =   4080
         TabIndex        =   56
         Top             =   480
         Width           =   1335
      End
      Begin VB.TextBox txtTransBatchNumber 
         Height          =   285
         Left            =   4080
         TabIndex        =   46
         Top             =   1680
         Width           =   1335
      End
      Begin VB.TextBox txtTransKind 
         Height          =   285
         Left            =   1440
         MaxLength       =   1
         TabIndex        =   44
         Top             =   2250
         Width           =   375
      End
      Begin VB.TextBox txtLabeltype 
         Height          =   285
         Left            =   1440
         MaxLength       =   1
         TabIndex        =   42
         Top             =   1680
         Width           =   375
      End
      Begin VB.TextBox txtSpecialty 
         Height          =   285
         Left            =   4080
         MaxLength       =   5
         TabIndex        =   40
         Top             =   1080
         Width           =   1335
      End
      Begin VB.TextBox txtConsultant 
         Height          =   285
         Left            =   4080
         MaxLength       =   5
         TabIndex        =   38
         Top             =   2250
         Width           =   1335
      End
      Begin VB.TextBox txtWard 
         Height          =   285
         Left            =   1440
         MaxLength       =   5
         TabIndex        =   36
         Top             =   1080
         Width           =   735
      End
      Begin VB.TextBox txtCaseNo 
         Height          =   285
         Left            =   1440
         MaxLength       =   10
         TabIndex        =   34
         Top             =   480
         Width           =   1215
      End
      Begin VB.Label Label10 
         Caption         =   "Internal Order Number"
         Height          =   375
         Left            =   2160
         TabIndex        =   58
         Top             =   2820
         Width           =   1695
      End
      Begin VB.Label lblNHNumber 
         Caption         =   "NH Number"
         Height          =   375
         Left            =   2880
         TabIndex        =   55
         Top             =   510
         Width           =   1095
      End
      Begin VB.Image ImgWard 
         Appearance      =   0  'Flat
         Height          =   315
         Left            =   1200
         Picture         =   "frmLogView.frx":030A
         Top             =   1080
         Width           =   285
      End
      Begin VB.Label lblTransBatchNumber 
         Caption         =   "Batch Number"
         Height          =   375
         Left            =   2880
         TabIndex        =   45
         Top             =   1710
         Width           =   1215
      End
      Begin VB.Label lblTransKind 
         Caption         =   "Kind"
         Height          =   375
         Left            =   240
         TabIndex        =   43
         Top             =   2310
         Width           =   975
      End
      Begin VB.Label lblLabelType 
         Caption         =   "Label Type"
         Height          =   375
         Left            =   240
         TabIndex        =   41
         Top             =   1725
         Width           =   855
      End
      Begin VB.Label lblSpecialty 
         Caption         =   "Specialty"
         Height          =   375
         Left            =   2880
         TabIndex        =   39
         Top             =   1110
         Width           =   1335
      End
      Begin VB.Label Label9 
         Caption         =   "Consultant"
         Height          =   375
         Left            =   2880
         TabIndex        =   37
         Top             =   2325
         Width           =   1095
      End
      Begin VB.Label Label8 
         Caption         =   " Ward"
         Height          =   375
         Left            =   210
         TabIndex        =   35
         Top             =   1110
         Width           =   1335
      End
      Begin VB.Label lblCaseNo 
         Caption         =   "Case Number"
         Height          =   375
         Left            =   240
         TabIndex        =   33
         Top             =   510
         Width           =   1335
      End
   End
   Begin VB.Frame FraOrder 
      Caption         =   "Order Log Criteria"
      Height          =   3255
      Left            =   3360
      TabIndex        =   19
      Top             =   4080
      Width           =   5655
      Begin VB.TextBox txtReason 
         Height          =   285
         Left            =   1320
         MaxLength       =   5
         TabIndex        =   54
         Top             =   2400
         Width           =   855
      End
      Begin VB.TextBox txtKind 
         Height          =   285
         Left            =   1320
         MaxLength       =   1
         TabIndex        =   31
         Top             =   1560
         Width           =   375
      End
      Begin VB.TextBox txtInvoiceNumber 
         Height          =   285
         Left            =   3960
         MaxLength       =   20
         TabIndex        =   28
         Top             =   1560
         Width           =   1455
      End
      Begin VB.TextBox txtOrderNumber 
         Height          =   285
         Left            =   3960
         MaxLength       =   10
         TabIndex        =   26
         Top             =   600
         Width           =   1455
      End
      Begin VB.TextBox txtBatchNumber 
         Height          =   285
         Left            =   3960
         TabIndex        =   24
         Top             =   2400
         Width           =   1455
      End
      Begin VB.TextBox txtSupplier 
         Height          =   285
         Left            =   1320
         MaxLength       =   5
         TabIndex        =   21
         Top             =   600
         Width           =   855
      End
      Begin VB.Image imgReason 
         Appearance      =   0  'Flat
         Height          =   315
         Left            =   1080
         Picture         =   "frmLogView.frx":08F0
         Top             =   2400
         Width           =   285
      End
      Begin VB.Label Label7 
         Caption         =   "Reason Code"
         Height          =   375
         Left            =   240
         TabIndex        =   29
         Top             =   2370
         Width           =   735
      End
      Begin VB.Label lblInvioceNumber 
         Caption         =   "Invoice Number"
         Height          =   255
         Left            =   2640
         TabIndex        =   27
         Top             =   1600
         Width           =   1215
      End
      Begin VB.Label lblOrderNumber 
         Caption         =   "Order Number"
         Height          =   375
         Left            =   2640
         TabIndex        =   25
         Top             =   630
         Width           =   1095
      End
      Begin VB.Label lblBatchNumber 
         Caption         =   "Batch Number"
         Height          =   375
         Left            =   2640
         TabIndex        =   23
         Top             =   2430
         Width           =   1095
      End
      Begin VB.Label lblKind 
         Caption         =   "Kind"
         Height          =   375
         Left            =   240
         TabIndex        =   22
         Top             =   1600
         Width           =   855
      End
      Begin VB.Image imgSupplier 
         Appearance      =   0  'Flat
         Height          =   315
         Left            =   1080
         Picture         =   "frmLogView.frx":0ED6
         Top             =   600
         Width           =   285
      End
      Begin VB.Label lblSupplier 
         Caption         =   "Supplier"
         Height          =   285
         Left            =   240
         TabIndex        =   20
         Top             =   630
         Width           =   855
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Criteria"
      Height          =   3255
      Left            =   360
      TabIndex        =   10
      Top             =   4080
      Width           =   2535
      Begin VB.CheckBox chkGroupBy 
         Height          =   255
         Left            =   1920
         TabIndex        =   48
         Top             =   1560
         Width           =   375
      End
      Begin VB.TextBox txtUser 
         Height          =   285
         Left            =   1080
         MaxLength       =   3
         TabIndex        =   18
         Top             =   2640
         Width           =   1095
      End
      Begin VB.TextBox txtTerminal 
         Height          =   285
         Left            =   1080
         MaxLength       =   15
         TabIndex        =   16
         Top             =   2040
         Width           =   1095
      End
      Begin VB.TextBox txtDrug 
         Height          =   285
         Left            =   1080
         MaxLength       =   7
         TabIndex        =   14
         Top             =   1080
         Width           =   1095
      End
      Begin VB.TextBox txtSite 
         Height          =   285
         Left            =   1080
         MaxLength       =   3
         TabIndex        =   12
         Top             =   480
         Width           =   1095
      End
      Begin VB.Label lblGroupby 
         Caption         =   "Group By"
         Height          =   255
         Left            =   840
         TabIndex        =   47
         Top             =   1560
         Width           =   975
      End
      Begin VB.Label Label6 
         Caption         =   "UserID"
         Height          =   375
         Left            =   240
         TabIndex        =   17
         Top             =   2640
         Width           =   735
      End
      Begin VB.Label Label5 
         Caption         =   "Terminal"
         Height          =   375
         Left            =   240
         TabIndex        =   15
         Top             =   2040
         Width           =   615
      End
      Begin VB.Image ImgDrug 
         Appearance      =   0  'Flat
         Height          =   315
         Left            =   840
         Picture         =   "frmLogView.frx":14BC
         Top             =   1080
         Width           =   285
      End
      Begin VB.Label Label4 
         Caption         =   "Drug"
         Height          =   495
         Left            =   240
         TabIndex        =   13
         Top             =   1080
         Width           =   855
      End
      Begin VB.Label Label3 
         Caption         =   "Site"
         Height          =   495
         Left            =   240
         TabIndex        =   11
         Top             =   480
         Width           =   975
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Date Range"
      Height          =   2175
      Left            =   3360
      TabIndex        =   4
      Top             =   1200
      Width           =   5655
      Begin VB.TextBox txtDateTo 
         Height          =   285
         Left            =   960
         TabIndex        =   6
         Top             =   1320
         Width           =   1335
      End
      Begin VB.TextBox txtDateFrom 
         Height          =   285
         Left            =   960
         TabIndex        =   5
         Top             =   720
         Width           =   1335
      End
      Begin VB.Label lblDAte 
         Caption         =   $"frmLogView.frx":1AA2
         Height          =   1335
         Left            =   2760
         TabIndex        =   30
         Top             =   600
         Width           =   2415
      End
      Begin VB.Label lblDateTo 
         Caption         =   "To"
         Height          =   375
         Left            =   240
         TabIndex        =   8
         Top             =   1320
         Width           =   615
      End
      Begin VB.Label Label1 
         Caption         =   "From"
         Height          =   375
         Left            =   240
         TabIndex        =   7
         Top             =   840
         Width           =   1215
      End
   End
   Begin VB.Frame frmLogType 
      Caption         =   "Log Type"
      Height          =   2175
      Left            =   360
      TabIndex        =   0
      Top             =   1200
      Width           =   2535
      Begin VB.OptionButton optLogType 
         Caption         =   "Combined"
         Height          =   495
         Index           =   3
         Left            =   480
         TabIndex        =   3
         Top             =   1440
         Width           =   1695
      End
      Begin VB.OptionButton optLogType 
         Caption         =   "Orders"
         Height          =   495
         Index           =   2
         Left            =   480
         TabIndex        =   2
         Top             =   960
         Width           =   1695
      End
      Begin VB.OptionButton optLogType 
         Caption         =   "Transaction"
         Height          =   495
         Index           =   1
         Left            =   480
         TabIndex        =   1
         Top             =   480
         Width           =   1695
      End
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   "User Log Viewer"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   18
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   1560
      TabIndex        =   9
      Top             =   240
      Width           =   5775
   End
End
Attribute VB_Name = "frmLogView"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'15Oct08 TH Extended invoicenumber entry to max 20 chars.
'07Mar14 TH Added internal Order Number search TFS 81586
'11Feb16 TH ImgDrug_Click: Allow ALL items to be picked, stores only and out of use included (TFS 144716)
'11Feb16 TH txtDrug_KeyPress: Allow ALL items to be picked stores only and out of use included (TFS 144716)
Dim M_Runningviewer As Boolean

Private Sub cmdCancel_Click()
   Unload Me
End Sub

Private Sub cmdOK_Click()
Dim valid As Integer
Dim strEndDate As String
Dim ndbd&
   'Validate the dates
   Dim strStartDate As String
   
      strStartDate = txtDateFrom.text
   
   'parsedate strStartDate, startyyyymm$, "mmyyyy", valid
   Storesparsedate (strStartDate), strStartDate, "dd mmm yyyy", valid
   If Not valid Then
      BadDate
      txtDateFrom.SelStart = 0
      txtDateFrom.SelLength = Len(txtDateFrom.text)
      txtDateFrom.SetFocus
   Else
      'parsedate (strStartDate), strStartDate, (DateFormat$), valid
      'Storesparsedate (strStartDate), strStartDate, "dd mmm yyyy", valid
      txtDateFrom.text = strStartDate
   End If
   
   If valid Then
      'parsedate strStartDate, startyyyymm$, "mmyyyy", valid
      strStartDate = txtDateTo.text
      Storesparsedate (strStartDate), strStartDate, "dd mmm yyyy", valid
      If Not valid Then
         BadDate
         txtDateTo.SelStart = 0
         txtDateTo.SelLength = Len(txtDateFrom.text)
         txtDateTo.SetFocus
      Else
         'parsedate (strStartDate), strStartDate, (DateFormat$), valid
         'Storesparsedate (strStartDate), strStartDate, "dd mmm yyyy", valid
         txtDateTo.text = strStartDate
      End If
   End If
   
   'Other validation here ?
   If valid Then
      'check the dates are contiguous
      parsedate (txtDateFrom.text), strStartDate, ("dd mm yyyy"), 0
      parsedate (txtDateTo.text), strEndDate, ("dd mm yyyy"), 0
      datetodays strStartDate, strEndDate, ndbd&, 0, "", 0
      If ndbd& < 0 Then
         popmessagecr "Log Viewer", "Start date from should be before end date"
         valid = False
         txtDateFrom.SelStart = 0
         txtDateFrom.SelLength = Len(txtDateFrom.text)
         txtDateFrom.SetFocus
      End If
   End If
   
   If TrueFalse(TxtD(dispdata$ & "\winord.ini", "LogView", "Y", "ValidateSiscode", 0)) Then
      If Trim$(txtDrug.text) <> "" Then
         If Not PatternMatch(txtDrug.text, NSVpattern$()) Then
            popmessagecr "Log Viewer", "Drug Code is in incorrect format"
            valid = False
         End If
      End If
   End If
   
   If valid Then NewUserLogViewer
   
   
   
End Sub

Private Sub Form_Load()
   SetChrome Me
   CentreForm Me
   txtDateFrom.text = Format$(Now, "dd mmm yyyy")
   txtDateTo.text = Format$(Now, "dd mmm yyyy")
   txtSite.text = Format$(SiteNumber)
   lblNHNumber.Caption = GetNHSNumberDisplayName() '17May12 TH Added
   
End Sub

Private Sub ImgDrug_Click()
'11Feb16 TH Allow ALL items to be picked, sotres only and out of use included (TFS 144716)

Dim dlocal As DrugParameters
Dim intFound As Integer
Dim strNSV As String
Dim intloop As Integer
Dim blnOK As Boolean

strNSV = Me.txtDrug.text
         'If Trim$(strNSV) <> "" Then
            'change the site here if necessary
            blnOK = True
            If Trim$(txtSite.text) <> "" Then
               'strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, SiteNumber)
   
               'gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
               'Must check site exists first
               blnOK = False
               For intloop = 0 To UBound(sitenos%)
               ''popmessagecr "", Format$(sitenos%(intloop))
               If Val(Trim$(txtSite.text)) = sitenos%(intloop) Then blnOK = True
               Next
               If blnOK = False Then
                  popmessagecr "Logviewer", "Site " & Trim$(txtSite.text) & " cannot be found"
               Else
                  SetDispdata (Val(Me.txtSite.text))
               End If
            End If
            If blnOK Then
               'findrdrug strNSV, 0, dlocal, 0, intFound, False, False, False
               'findrdrug strNSV, True, dlocal, 0, intFound, False, False, False, True, (strNSV = "") '01May14 TH Allow Stores only to be picked (TFS 90135)
               findrdrug strNSV, 1, dlocal, 0, intFound, False, False, False, True, (strNSV = "") '11Feb16 TH Allow ALL items to be picked (TFS 144716)
               'Change site back
               SetDispdata 0
               If intFound Then
                  Me.txtDrug.text = dlocal.SisCode
               End If
            End If
         'End If

End Sub

Private Sub imgReason_Click()
Dim strReason As String

   If Trim$(txtSite.text) <> "" Then
      'Must check site exists first
      blnOK = False
      For intloop = 0 To UBound(sitenos%)
      If Val(Trim$(txtSite.text)) = sitenos%(intloop) Then blnOK = True
      Next
      If blnOK = False Then
         popmessagecr "Logviewer", "Site " & Trim$(txtSite.text) & " cannot be found"
      Else
         SetDispdata (Val(Me.txtSite.text))
      End If
   End If
   AskReasonCode "Choose Reason Code", strReason
   SetDispdata 0
   txtReason.text = strReason
   
End Sub

Private Sub imgSupplier_Click()
Dim strSupCode As String
Dim lclsup As supplierstruct

   If Trim$(txtSite.text) <> "" Then
      'Must check site exists first
      blnOK = False
      For intloop = 0 To UBound(sitenos%)
      If Val(Trim$(txtSite.text)) = sitenos%(intloop) Then blnOK = True
      Next
      If blnOK = False Then
         popmessagecr "Logviewer", "Site " & Trim$(txtSite.text) & " cannot be found"
      Else
         SetDispdata (Val(Me.txtSite.text))
      End If
   End If
   asksupplier strSupCode, 0, "SE", "Select a Supplier", False, lclsup, False  '15Nov12 TH Added PSO param'10Jan08 TH Added Stores suppliers in Filter (F0011632) '20Feb12 use local sup struct
   SetDispdata 0
   If Not k.escd Then
      txtSupplier.text = strSupCode
   End If
End Sub

Private Sub ImgWard_Click()
Dim strSupCode As String

   If Trim$(txtSite.text) <> "" Then
      'Must check site exists first
      blnOK = False
      For intloop = 0 To UBound(sitenos%)
      If Val(Trim$(txtSite.text)) = sitenos%(intloop) Then blnOK = True
      Next
      If blnOK = False Then
         popmessagecr "Logviewer", "Site " & Trim$(txtSite.text) & " cannot be found"
      Else
         SetDispdata (Val(Me.txtSite.text))
      End If
   End If
   AskSupplierWard strSupCode, "Select a ward", 0
   SetDispdata 0
   If Not k.escd Then
      txtWard.text = strSupCode
   End If
End Sub

Private Sub OptLogType_Click(Index As Integer)

'Display appropriate parts of the screen
   Select Case Index
   
      Case 1 ' Transaction
         FraOrder.Visible = False
         FraTrans.Visible = True
         fraCombined.Visible = False
      Case 2 ' Order log
         FraOrder.Visible = True
         FraTrans.Visible = False
         fraCombined.Visible = False
      Case 3 ' Combined log
         FraOrder.Visible = False
         FraTrans.Visible = False
         fraCombined.Visible = True
         
   
   End Select
End Sub

Private Sub txtBatchNumber_KeyPress(KeyAscii As Integer)
If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub

Private Sub txtCaseNo_KeyPress(KeyAscii As Integer)
If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub

Private Sub txtCombinedBatchNumber_KeyPress(KeyAscii As Integer)
If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub

Private Sub txtConsultant_KeyPress(KeyAscii As Integer)
If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub

Private Sub txtDateFrom_GotFocus()
M_Runningviewer = False

End Sub

Private Sub txtDateFrom_KeyPress(KeyAscii As Integer)
Dim strStartDate As String
Dim valid As Integer
Dim strOut As String

If KeyAscii = 13 And Not M_Runningviewer Then
   strStartDate = txtDateFrom.text
   
   'parsedate strStartDate, startyyyymm$, "mmyyyy", valid
   Storesparsedate (strStartDate), strStartDate, "dd mmm yyyy", valid
   If Not valid Then
      BadDate
   Else
      'parsedate (strStartDate), strStartDate, (DateFormat$), valid
      'Storesparsedate strStartDate, strOut, "dd mmm yyyy", valid
      txtDateFrom.text = strStartDate
   End If
End If
End Sub

Private Sub txtDateFrom_LostFocus()
Dim strStartDate As String
Dim valid As Integer
Dim strOut As String

   strStartDate = txtDateFrom.text
   
   'parsedate strStartDate, startyyyymm$, "mmyyyy", valid
   Storesparsedate (strStartDate), strStartDate, "dd mmm yyyy", valid
   If Not valid Then
      'BadDate
   Else
      'parsedate (strStartDate), strStartDate, (DateFormat$), valid
      'Storesparsedate strStartDate, strOut, "dd mmm yyyy", valid
      txtDateFrom.text = strStartDate
   End If
   
   
End Sub

Private Sub txtDateTo_GotFocus()
M_Runningviewer = False

End Sub

Private Sub txtDateTo_KeyPress(KeyAscii As Integer)
Dim strStartDate As String
Dim valid As Integer
Dim strOut As String

If KeyAscii = 13 And Not M_Runningviewer Then
   strStartDate = txtDateTo.text
   
   'parsedate strStartDate, startyyyymm$, "mmyyyy", valid
   Storesparsedate (strStartDate), strStartDate, "dd mmm yyyy", valid
   If Not valid Then
      BadDate
   Else
      'parsedate (strStartDate), strStartDate, (DateFormat$), valid
      'Storesparsedate strStartDate, strOut, "dd mmm yyyy", valid
      txtDateTo.text = strStartDate
   End If
End If
End Sub

Private Sub txtDateTo_LostFocus()
Dim strStartDate As String
Dim valid As Integer

   strStartDate = txtDateTo.text
   
   'parsedate strStartDate, startyyyymm$, "mmyyyy", valid
   Storesparsedate (strStartDate), strStartDate, "dd mmm yyyy", valid
   If Not valid Then
      'BadDate
   Else
      'parsedate (strStartDate), strStartDate, (DateFormat$), valid
      'Storesparsedate (strStartDate), strStartDate, "dd mmm yyyy", valid
      txtDateTo.text = strStartDate
   End If
   
End Sub

Private Sub txtDrug_KeyPress(KeyAscii As Integer)
'11Feb16 TH Allow ALL items to be picked stores only and out of use included (TFS 144716)

Dim dlocal As DrugParameters
Dim intFound As Integer
Dim strNSV As String
Dim intloop As Integer
Dim blnOK As Boolean

   Select Case KeyAscii
      Case 13
         strNSV = Me.txtDrug.text
         If Trim$(strNSV) <> "" Then
            'change the site here if necessary
            blnOK = True
            If Trim$(txtSite.text) <> "" Then
               'strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, SiteNumber)
   
               'gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
               'Must check site exists first
               blnOK = False
               For intloop = 0 To UBound(sitenos%)
               ''popmessagecr "", Format$(sitenos%(intloop))
               If Val(Trim$(txtSite.text)) = sitenos%(intloop) Then blnOK = True
               Next
               If blnOK = False Then
                  popmessagecr "Logviewer", "Site " & Trim$(txtSite.text) & " cannot be found"
               Else
                  SetDispdata (Val(Me.txtSite.text))
               End If
            End If
            If blnOK Then
               'findrdrug strNSV, 0, dlocal, 0, intFound, False, False, False
               findrdrug strNSV, 1, dlocal, 0, intFound, False, False, False '11Feb16 TH Allow ALL items to be picked stores only and out of use included (TFS 144716)
               'Change site back
               SetDispdata 0
               If intFound Then
                  Me.txtDrug.text = dlocal.SisCode
               End If
            End If
         End If
      Case 39, 59
         KeyAscii = 0
   End Select
End Sub



Private Sub txtInternalOrderNumber_KeyPress(KeyAscii As Integer)
   If (KeyAscii < 48 Or KeyAscii > 57) Then KeyAscii = 0 'Numeric masking
   
End Sub

Private Sub txtInvoiceNumber_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub



Private Sub txtKind_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub



Private Sub txtLabeltype_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub



Private Sub txtNHNumber_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub

Private Sub txtOrderNumber_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub



Private Sub txtReason_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub

Private Sub txtSite_KeyPress(KeyAscii As Integer)

   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
   
End Sub



Private Sub txtSpecialty_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub



Private Sub txtSupplier_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub

Private Sub txtTerminal_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub

Private Sub txtTransBatchNumber_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub


Private Sub txtTransKind_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub


Private Sub txtUser_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub



Private Sub txtWard_KeyPress(KeyAscii As Integer)
   If (KeyAscii = 39 Or KeyAscii = 59) Then KeyAscii = 0
End Sub
